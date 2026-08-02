/**
 * Environment de desarrollo — apunta al mock API local (localhost:8080).
 * El mock levanta el backend Java (SPE-ANCE-002) o un mock server generado
 * desde el contrato OpenAPI. Auth en modo mock (IAM propio · ADR-ANCE-004).
 */
export const environment = {
  production: false,
  apiBaseUrl: 'http://localhost:8080/api/v1',
  authMode: 'mock' as 'mock' | 'oidc'
};
