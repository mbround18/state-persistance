# Original content pulled from https://github.com/nozaq/terraform-aws-remote-state-s3-backend

locals {
  bucket_name = "${var.project}-s3-${var.bucket_name}"
  define_lifecycle_rule = var.noncurrent_version_expiration != null || length(var.noncurrent_version_transitions) > 0
}

#---------------------------------------------------------------------------------------------------
# KMS Key to Encrypt S3 Bucket
#---------------------------------------------------------------------------------------------------
resource "aws_kms_key" "this" {
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = var.kms_key_enable_key_rotation

  tags = local.global_tags
}

#---------------------------------------------------------------------------------------------------
# Buckets
#---------------------------------------------------------------------------------------------------
data "aws_region" "state" {
}

resource "aws_s3_bucket" "state" {
  bucket        = local.bucket_name
  bucket_prefix = var.state_bucket_prefix
  acl           = "private"
  force_destroy = var.s3_bucket_force_destroy

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.this.arn
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = local.define_lifecycle_rule ? [true] : []

    content {
      enabled = true
      dynamic "noncurrent_version_transition" {
        for_each = var.noncurrent_version_transitions

        content {
          days          = noncurrent_version_transition.value.days
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = var.noncurrent_version_expiration != null ? [var.noncurrent_version_expiration] : []

        content {
          days = noncurrent_version_expiration.value.days
        }
      }
    }
  }

  tags = local.global_tags
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

