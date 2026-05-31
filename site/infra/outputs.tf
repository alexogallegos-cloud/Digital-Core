output "bucket_name" {
  description = "Nombre del bucket S3 (destino de aws s3 sync)"
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_domain" {
  description = "URL pública vía CloudFront (siempre disponible)"
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "site_url" {
  description = "URL final del sitio (dominio propio si está configurado, si no CloudFront)"
  value       = local.use_domain ? "https://${var.domain_name}" : "https://${aws_cloudfront_distribution.site.domain_name}"
}

# Para DNS EXTERNO (sin Route53): registros de validación ACM a crear a mano
output "acm_validation_records" {
  description = "Si usas DNS externo: crea estos CNAME para validar el certificado ACM"
  value       = local.use_domain && !local.use_route53 ? aws_acm_certificate.cert[0].domain_validation_options : null
}

# Para DNS EXTERNO: apunta tu dominio (CNAME/ALIAS) a este destino
output "cloudfront_target" {
  description = "Si usas DNS externo: apunta tu dominio (CNAME) a este host"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID de la distribución (para invalidaciones)"
  value       = aws_cloudfront_distribution.site.id
}

output "deploy_hint" {
  description = "Comandos de despliegue del contenido"
  value       = <<-EOT
    # 1) subir el contenido (desde site/):
    aws s3 sync .. s3://${aws_s3_bucket.site.bucket} --delete --exclude "infra/*" --exclude "_build.py"
    # 2) invalidar caché de CloudFront:
    aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.site.id} --paths "/*"
  EOT
}