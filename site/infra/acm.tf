###############################################################################
# Dominio propio (opcional) — ACM en us-east-1 + validación DNS + Route53 alias
# - Si var.domain_name == ""        -> no se crea nada (CloudFront usa cert default).
# - Si domain_name set, zone vacío  -> crea el cert; valida MANUAL (DNS externo).
# - Si domain_name set, zone set    -> valida y enruta TODO automático (Route53).
###############################################################################

# Certificado para CloudFront DEBE estar en us-east-1
resource "aws_acm_certificate" "cert" {
  count                     = local.use_domain ? 1 : 0
  provider                  = aws.use1
  domain_name               = var.domain_name
  subject_alternative_names = var.domain_aliases
  validation_method         = "DNS"
  tags                      = var.tags
  lifecycle { create_before_destroy = true }
}

# --- Validación automática vía Route53 (solo si se da la zona) --------------
resource "aws_route53_record" "cert_validation" {
  for_each = local.use_route53 ? {
    for dvo in aws_acm_certificate.cert[0].domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id         = var.route53_zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "cert" {
  count                   = local.use_route53 ? 1 : 0
  provider                = aws.use1
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# --- Registro alias A/AAAA al CloudFront (solo Route53) ---------------------
resource "aws_route53_record" "alias_a" {
  count   = local.use_route53 ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alias_aaaa" {
  count   = local.use_route53 ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}