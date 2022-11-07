## Bucket/Website config

# http://multilayer-reports.s3-website-eu-west-1.amazonaws.com/
resource aws_s3_bucket reports {
  bucket = "multilayer-reports"
}
resource "aws_s3_bucket_acl" "reports" {
  bucket = aws_s3_bucket.reports.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "reports" {
  bucket = aws_s3_bucket.reports.bucket

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource aws_s3_bucket_policy reports {
  bucket = aws_s3_bucket.reports.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "s3:*" ],
      "Resource": [
        "${aws_s3_bucket.reports.arn}",
        "${aws_s3_bucket.reports.arn}/*"
      ],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "34.244.96.147/32",
            "3.248.170.11/32",
            "34.244.165.106/32",
            "52.210.68.117/32"
          ]
        }
      },
      "Principal": "*"
    }
  ]
}
EOF
}

## Files
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.reports.id
  key    = "index.html"
  source = "files/index.html"
  etag = filemd5("files/index.html")
  content_type = "text/html"
}
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.reports.id
  key    = "error.html"
  source = "files/error.html"
  etag = filemd5("files/error.html")
  content_type = "text/html"
}

resource "aws_s3_object" "test" {
  bucket = aws_s3_bucket.reports.id
  key    = "test.html"
  source = "files/test.html"
  etag = filemd5("files/test.html")
  content_type = "text/html"
}

## Outputs
output website_endpoint {
  value = aws_s3_bucket.reports.website_endpoint
}

## Provider
terraform {
  required_providers {
    aws = "4.36.1"
  }

  backend "s3" {
    encrypt = true
    bucket  = "multilayer-terraform"
    region  = "eu-west-1"
    key     = "reports.tfstate"
  }
}

provider "aws" {
  region = "eu-west-1"
}

