

provider "aws" {  
  region                      = var.aws_region
  s3_force_path_style         = var.use_localstack
  skip_requesting_account_id  = var.use_localstack
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack

  # Note: all services are now exposed via a single edge port: https://github.com/localstack/localstack
  dynamic "endpoints" {
    for_each = var.use_localstack ? [var.localstack_host] : []

    content {
      apigateway     = endpoints.value
      cloudformation = endpoints.value
      cloudwatch     = endpoints.value
      dynamodb       = endpoints.value
      es             = endpoints.value
      firehose       = endpoints.value
      iam            = endpoints.value
      kinesis        = endpoints.value
      lambda         = endpoints.value
      route53        = endpoints.value
      redshift       = endpoints.value
      s3             = endpoints.value
      secretsmanager = endpoints.value
      ses            = endpoints.value
      sns            = endpoints.value
      sqs            = endpoints.value
      ssm            = endpoints.value
      stepfunctions  = endpoints.value
      sts            = endpoints.value
      xray           = endpoints.value
    }
  }
}

