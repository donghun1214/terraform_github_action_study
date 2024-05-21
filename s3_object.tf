resource "aws_s3_bucket" "s3-bucket" {
   bucket = "terraform-study-s3-bucket"
    tags = {
        Name = "terraform-study-s3-bucket"
    }
}

# html, js, css 파일 업로드
resource "aws_s3_object" "s3-object-html" {
  bucket = aws_s3_bucket.s3-bucket.id
  key    = "index.html"     #저장될 S3 경로 지정.
  source = "static_files/index.html"   #tf 파일 기준 로컬에 저장되어있는 파일 위치 
  content_type    = "text/html"
  etag = filemd5("./index.html")  #로컬에 있는 객체와 S3에 있는 객체가 불일치할 때 업로드 수행함. 일치하면 수행하지 않음.
}

# html, js, css 파일 업로드
resource "aws_s3_object" "s3-object-css" {
  bucket = aws_s3_bucket.s3-bucket.id
  key    = "style.css"     
  source = "static_files/style.css"   
  content_type    = "text/css"
  etag = filemd5("./style.css")  
}

# html, js, css 파일 업로드
resource "aws_s3_object" "s3-object" {
  bucket = aws_s3_bucket.s3-bucket.id
  key    = "script.js"    
  source = "static_files/script.js"   
  content_type    = "application/javascript"
  etag = filemd5("./script.js") 
}

## 웹 호스팅
resource "aws_s3_bucket_website_configuration" "s3-bucket-web" {
  bucket = aws_s3_bucket.s3-bucket.id

  index_document {
    suffix = "index.html"
  }
}

## IAM 정책설정
data "aws_iam_policy_document" "terraformstudy-s3-permissions" {
    statement {
        actions   = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.s3-bucket.arn}/*"]  #.arn 이란 리소스를 고유하게 식별할 수 있는 포맷이다.

        principals {
            type        = "*"
            identifiers = ["*"]
        }
    }
}

# public access for objects
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.s3-bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "s3-policy" {
  bucket = aws_s3_bucket.s3-bucket.id
  policy = data.aws_iam_policy_document.terraformstudy-s3-permissions.json
}

resource "aws_cloudfront_distribution" "cloudfront" {
  origin {
    domain_name = aws_s3_bucket.s3-bucket.bucket_domain_name
    origin_id   = "s3-bucket"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = [ "TLSv1.2"]
    }
  }

  origin {
    domain_name = "ecs-loadbalancer-skkudinginfra-264635261.ap-northeast-2.elb.amazonaws.com"
    origin_id = "alb"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "terraform-study"
  http_version = "http2and3"

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    target_origin_id         = "s3-bucket" 
    viewer_protocol_policy   = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern             = "/api/*"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    target_origin_id         = "alb"
    viewer_protocol_policy   = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" # Allow cache from all countries
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}