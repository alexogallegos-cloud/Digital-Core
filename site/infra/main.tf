###############################################################################
# Digital Core — static site (S3 privado + CloudFront OAC, acceso público)
# IaC-First. Bucket NO público; CloudFront (OAC) es el único lector y sirve
# el sitio por HTTPS. Contenido: solo material SIN IP de cliente (sintético).
###############################################################################

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.region
}

# CloudFront ACM (us-east-1) — solo necesario si se usa dominio propio (opcional)
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

locals {
  bucket_name = "${var.project}-site-${var.suffix}"
  use_domain  = var.domain_name != ""
  use_route53 = var.domain_name != "" && var.route53_zone_id != ""
  aliases     = local.use_domain ? concat([var.domain_name], var.domain_aliases) : []
  # cert validado (Route53) o cert sin validar (DNS externo) o ninguno
  cert_arn = local.use_route53 ? try(aws_acm_certificate_validation.cert[0].certificate_arn, null) : (local.use_domain ? try(aws_acm_certificate.cert[0].arn, null) : null)
}

# --- S3: bucket privado para el contenido del sitio -------------------------
resource "aws_s3_bucket" "site" {
  bucket        = local.bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- CloudFront Origin Access Control (OAC, sigv4) --------------------------
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.project}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Cache policy gestionada "CachingOptimized"
data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  default_root_object = "index.html"
  comment             = "${var.project} — Digital Core static site"
  price_class         = "PriceClass_100"
  aliases             = local.aliases
  tags                = var.tags

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-${local.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-${local.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.optimized.id
    compress               = true
  }

  # 403/404 -> index.html del sitio (navegación SPA-friendly; los enlaces son explícitos .html)
  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = local.use_domain ? null : true
    acm_certificate_arn            = local.cert_arn
    ssl_support_method             = local.use_domain ? "sni-only" : null
    minimum_protocol_version       = local.use_domain ? "TLSv1.2_2021" : null
  }
}

# --- Bucket policy: solo CloudFront (OAC) puede leer ------------------------
data "aws_iam_policy_document" "site" {
  statement {
    sid       = "AllowCloudFrontOAC"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site.json
}