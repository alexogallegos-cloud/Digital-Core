variable "region" {
  description = "Región AWS para el bucket S3"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Prefijo de nombres de recursos"
  type        = string
  default     = "digital-core"
}

variable "suffix" {
  description = "Sufijo único para el nombre del bucket (debe ser globalmente único en S3)"
  type        = string
  # ej: tus iniciales + fecha. Sin default a propósito: se pasa en apply.
}

variable "domain_name" {
  description = "Dominio propio del sitio (ej: digitalcore.midominio.com). Vacío = usar URL de CloudFront."
  type        = string
  default     = ""
}

variable "domain_aliases" {
  description = "Dominios adicionales (SAN del cert + aliases CloudFront), ej: [\"www.digitalcore.midominio.com\"]"
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "Hosted Zone ID de Route53 para validar el cert y crear el alias automáticamente. Vacío = validación/DNS manual (DNS externo)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default = {
    Project   = "digital-core-site"
    Owner     = "alejandro.gallegos"
    ManagedBy = "terraform"
    Use       = "internal"
  }
}