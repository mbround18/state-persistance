#---------------------------------------------------------------------------------------------------
# IAM Policy
# See below for permissions necessary to run Terraform.
# https://www.terraform.io/docs/backends/types/s3.html#example-configuration
#---------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "tf" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject", 
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.state.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]

    resources = [
      aws_dynamodb_table.lock.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:ListKeys"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]

    resources = [
      aws_kms_key.this.arn
    ]
  }
}

resource "aws_iam_policy" "terraform" {
  name_prefix = var.terraform_iam_policy_name_prefix
  policy = data.aws_iam_policy_document.tf.json
}
