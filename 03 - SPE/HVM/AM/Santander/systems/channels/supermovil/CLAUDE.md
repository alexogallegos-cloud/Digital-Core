# SuperMóvil — Application Modernization Agent
# togaf_type: channels
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: mobile-banking
# bian_domains: ["mobile-banking", "digital-channels", "payment-initiation"]
# discovered: 2026-09-17 · fuente: App Store / Google Play (público)

> Canal móvil principal de Santander México · iOS + Android
> Agente especializado del sistema. Para vista federada: `../../santander-brain/CLAUDE.md`

---

## IDENTIDAD DEL SISTEMA

| Campo | Valor |
|-------|-------|
| Nombre real | SuperMóvil |
| Tipo TOGAF | channels — System of Differentiation (SoD) |
| Estado | Baseline (en producción) |
| Plataformas | iOS (Swift probable) · Android (Kotlin probable) · React Native posible |
| Usuarios | ~8M activos estimados |
| Disponibilidad SLO | ≥ 99.9% |
| Regulación | CNBV canales digitales · PCI-DSS (pagos) · CONDUSEF |

---

## CAPACIDADES CONOCIDAS (PÚBLICAS)

| Capacidad | Estado | Notas |
|-----------|--------|-------|
| Consulta de saldo e historial | CONFIRMED | Función básica |
| Transferencias SPEI | CONFIRMED | Público en App Store |
| Pagos DiMo | CONFIRMED | Público en App Store |
| Pago de servicios | CONFIRMED | CFE, Telmex, etc. |
| CoDi (QR) | CONFIRMED | Público |
| Depósito de cheque móvil | CONFIRMED | Público |
| Bloqueo de tarjeta | CONFIRMED | Self-service |
| Solicitud de crédito | PROBABLE | Por confirmar |
| Inversiones / fondos | PROBABLE | Por confirmar |
| Biometría / Face ID | CONFIRMED | Estándar iOS/Android |

---

## DEPENDENCIAS CONOCIDAS (SCAFFOLD)

| Sistema | Tipo de dependencia | Dirección | Criticidad |
|---------|--------------------|-----------|----|
| Core Banking | calls | outbound | CRÍTICA |
| Payments Engine | calls | outbound | CRÍTICA |
| Card Platform | calls | outbound | ALTA |
| API Gateway | calls (via) | outbound | CRÍTICA |
| IAM | calls (auth) | outbound | CRÍTICA |
| Banxico SPEI/DiMo | feeds (via Payments) | outbound | ALTA |

---

## FUENTES DE INFORMACIÓN REQUERIDAS

Para construir el brain de SuperMóvil se necesita:
- Código fuente (repos iOS/Android o RN)
- API specs del backend (OpenAPI/Swagger)
- Logs de errores y analytics de uso
- Catálogo de pantallas / flows

---

## PRÓXIMOS PASOS

- [ ] Obtener acceso al repositorio de código fuente
- [ ] Documentar flows de pantallas principales
- [ ] Mapear APIs consumidas (endpoints del backend)
- [ ] Construir `digital-brain/brain.db`
- [ ] Ejecutar análisis de métricas App Store vs. competidores

---

*Última actualización: 2026-09-17 · v0.1 · Stub inicial — sistema confirmado (App Store), brain pendiente*
