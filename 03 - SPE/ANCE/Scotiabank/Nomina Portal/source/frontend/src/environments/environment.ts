/**
 * Environment de produccion (placeholder).
 * En prod el base URL de la API y el mecanismo de auth (SSO federado OIDC)
 * dependen de ADR-ANCE-004 / ADR-ANCE-007. Valores DATO-REQUERIDO.
 */
export const environment = {
  production: true,
  apiBaseUrl: '/api/v1',
  authMode: 'oidc' as 'mock' | 'oidc'
};
