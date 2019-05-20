variable "bucket_name" {
  type = "string"
}

resource "aws_s3_bucket" "state" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
