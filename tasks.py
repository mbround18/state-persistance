import json
from os import path, walk, system, name, remove
from invoke import task


script_path = path.dirname(path.realpath(__file__))
@task
def backend(c):
    results = c.run("terraform output -json", hide=True, warn=True)
    state = json.loads(results.stdout)
    state_file = "terraform.tfstate"
    bucket_arn = state["state_bucket"]["value"]["arn"]
    region = state["state_bucket"]["value"]["region"]
    kms_key = state["kms_key"]["value"]["key_id"]
    backend = [
        f"bucket = \"{bucket_arn}\"",
        f"key = \"{state_file}\"",
        f"region = \"{region}\"",
        "encrypt = true",
        f"kms_key_id = \"{kms_key}\""
    ]

    print("terraform {\n\tbackend \"s3\" {\n\t\t" +
          "\n\t\t".join(backend) + "\n\t}\n}")
