# Catálogo de Reglas de Negocio — AppMovil Canal Móvil BanCoppel
> **Proyecto**: BanCoppel Application Modernization · `SPE-AM-001`
> **Generado**: 2026-08-14 desde `brain.db::rules` por `extract-rules-java.py v1.0.0`
> **Total reglas**: 2509 · Con clasificación regulatoria: 268
>
> **ADR-SPE-AM-009**: ID canónico `BR-AM-{msa_abbr}-{line}` — anclado a fuente. msa_abbr = slug funcional del MSA (ej. `codi-pay`, `sess-man`, `freq-acc`).
> **ADR-SPE-AM-010**: `business_name = null` pendiente de síntesis LLM (swarm de enriquecimiento).

---

## Resumen por Tipo

| Tipo | Reglas |
|------|--------|
| ANOTACIÓN | 1501 |
| VALIDACIÓN | 466 |
| CONFIGURACIÓN | 406 |
| UMBRAL | 128 |
| CÓDIGO_ERROR | 8 |

---

## VALIDACIÓN (466 reglas)

_Guard clauses — excepciones de negocio lanzadas en servicios_

| ID | Clase | Dominio | SP / Clase | Línea | Regulación | Sub-tipo | Código fuente |
|----|-------|---------|------------|-------|------------|----------|---------------|
| BR-AM-appl-agr-65 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-agreement:S | 65 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-appl-b-53 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data-b:Secu | 53 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-appl-dat-91 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data:Securi | 91 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-appl-dat-112 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data:Securi | 112 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-codi-ope-214 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-codi-log-operations:Cod | 214 | Banxico CoDi — Circular 14/2017 Banxico CoDi | TimeOutException | `throw new TimeOutException(errorResolverConstants.getMessageApiTimeOutException(` |
| BR-AM-exec-ope-225 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-executive-operations:Ex | 225 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-serv-b-103 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-service-payment-validat | 103 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-serv-b-63 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-service-payment-validat | 63 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-serv-val-83 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-service-payment-validat | 83 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-serv-val-63 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-service-payment-validat | 63 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-addr-cat-196 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-address-data-catalogs:D | 196 | — | BadRequestException | `default -> throw new BadRequestException(` |
| BR-AM-cred-b-186 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 186 | — | BadRequestException | `throw new BadRequestException(apiValues.getBadRequestMessage(), new ArrayList<>(` |
| BR-AM-cred-b-225 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 225 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-b-232 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 232 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-mov-162 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 162 | — | BadRequestException | `throw new BadRequestException(apiValues.getBadRequestMessage(), new ArrayList<St` |
| BR-AM-cred-mov-194 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 194 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-cred-b-424 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 424 | — | NoResourceFoundException | `throw new NoResourceFoundException();` |
| BR-AM-cred-b-426 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 426 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-b-457 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 457 | — | NoResourceFoundException | `throw new NoResourceFoundException();` |
| BR-AM-cred-b-459 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 459 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-b-494 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 494 | — | NoResourceFoundException | `throw new NoResourceFoundException();` |
| BR-AM-cred-b-496 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 496 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-b-534 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 534 | — | NoResourceFoundException | `throw new NoResourceFoundException();` |
| BR-AM-cred-b-536 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 536 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-det-408 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 408 | — | DownstreamException | `throw new DownstreamException(ApiConstants.CODE_NOT_FOUND, apiConstants.getMsjDo` |
| BR-AM-cred-b-235 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-b | 235 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-b-399 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-b | 399 | — | RequestTimeoutException | `throw new RequestTimeoutException();` |
| BR-AM-cred-b-409 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-b | 409 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-b-492 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-b | 492 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-det-366 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-d | 366 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-cred-det-451 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-d | 451 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-depo-b-278 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 278 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-depo-b-357 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 357 | — | BadRequestException | `throw new BadRequestException(StringUtils.EMPTY, new ArrayList<>());` |
| BR-AM-depo-b-365 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 365 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-depo-mov-362 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 362 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-freq-acc-505 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:AddFr | 505 | — | BadRequestException | `throw new BadRequestException(` |
| BR-AM-freq-acc-160 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 160 | — | BadRequestException | `throw new BadRequestException(apiValue.getRequestValidatorInvalidArguments(),` |
| BR-AM-freq-acc-138 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Redis | 138 | — | DownstreamException | `throw new DownstreamException(HttpStatus.FORBIDDEN.value(), errorRsp);` |
| BR-AM-tran-b-132 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 132 | — | DownstreamException | `throw new DownstreamException(HttpStatus.FORBIDDEN.value(), errorRsp);` |
| BR-AM-tran-b-205 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 205 | — | BadRequestException | `throw new BadRequestException(` |
| BR-AM-tran-b-155 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 155 | — | BadRequestException | `throw new BadRequestException(` |
| BR-AM-tran-b-213 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 213 | — | DownstreamException | `throw new DownstreamException(status, errorRsp);` |
| BR-AM-tran-acc-134 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 134 | — | DownstreamException | `throw new DownstreamException(HttpStatus.FORBIDDEN.value(), errorRsp);` |
| BR-AM-tran-acc-204 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 204 | — | DownstreamException | `throw new DownstreamException(HttpStatus.FORBIDDEN.value(), errorRsp);` |
| BR-AM-tran-acc-216 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 216 | — | BadRequestException | `throw new BadRequestException(` |
| BR-AM-tran-acc-223 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 223 | — | BadRequestException | `throw new BadRequestException(` |
| BR-AM-tran-acc-209 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 209 | — | DownstreamException | `throw new DownstreamException(status, errorRsp);` |
| BR-AM-tran-b-191 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 191 | — | BadRequestException | `throw new BadRequestException(` |
| BR-AM-tran-b-148 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 148 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_INVALID_AMOUNT, fields);` |
| BR-AM-tran-b-157 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 157 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_INVALID_AMOUNT, fields);` |
| BR-AM-tran-b-178 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 178 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_ALIAS_NOT_EMPTY, fields);` |
| BR-AM-tran-acc-184 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 184 | — | BadRequestException | `throw new BadRequestException(` |
| BR-AM-tran-acc-147 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 147 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_INVALID_AMOUNT, fields);` |
| BR-AM-tran-acc-156 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 156 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_INVALID_AMOUNT, fields);` |
| BR-AM-tran-acc-194 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 194 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_ALIAS_NOT_EMPTY, fields);` |
| BR-AM-tran-acc-378 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 378 | — | BadRequestException | `throw new BadRequestException(` |
| BR-AM-tran-acc-117 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:A | 117 | — | BadRequestException | `throw new BadRequestException(MessagesConstants.WRONG_AMOUNT_FORMAT_MESSAGE, bad` |
| BR-AM-tran-acc-71 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:C | 71 | — | UnauthorizedException | `throw new UnauthorizedException(MessagesConstants.AUTHENTICATION_FAILURE_MESSAGE` |
| BR-AM-otp-aut-138 | NEGOCIO | Canal / Channel Infrastructure | msach-d-security-otp-control-authorizati | 138 | — | BadRequestException | `throw new BadRequestException(` |
| BR-AM-cred-b-213 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-credit-cards-accounts-b | 213 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-b-217 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-credit-cards-accounts-b | 217 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-b-53-2 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-credit-cards-accounts-b | 53 | — | UnauthorizedException | `throw new UnauthorizedException(MessagesConstants.MSG_ERROR_AUTHENTICATION_FAILU` |
| BR-AM-cred-acc-52 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-credit-cards-accounts:C | 52 | — | UnauthorizedException | `throw new UnauthorizedException(MessagesConstants.MSG_ERROR_AUTHENTICATION_FAILU` |
| BR-AM-depo-b-236 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-deposit-accounts-b:Depo | 236 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-b-242 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-deposit-accounts-b:Depo | 242 | — | RequestTimeoutException | `throw new RequestTimeoutException();` |
| BR-AM-depo-acc-196 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-deposit-accounts:Deposi | 196 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-acc-202 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-deposit-accounts:Deposi | 202 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-phon-b-104 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-security-phone-validations-b:Sec | 104 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-phon-val-58 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-security-phone-validations:Secur | 58 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-card-val-136 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-card-direct-debit-valid | 136 | — | BadRequestException | `throw new BadRequestException("Header faltante en la peticion: " + Constants.CON` |
| BR-AM-card-val-256 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-card-direct-debit-valid | 256 | — | BadRequestException | `throw new BadRequestException(Constants.CARD_NUMBER_EMPTY_ERROR_MESSAGE,` |
| BR-AM-card-val-264 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-card-direct-debit-valid | 264 | — | BadRequestException | `throw new BadRequestException(Constants.CARD_NUMBER_LENGTH_ERROR_MESSAGE,` |
| BR-AM-codi-b-92-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:Util | 92 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException("Formato invalido para [amount], debería ser #.##"` |
| BR-AM-codi-b-102 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:Util | 102 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException("Formato invalido para [amount], debería ser #.##"` |
| BR-AM-codi-b-238 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:Validati | 238 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException(apiValues.getMsgValuesMissing(), fields);` |
| BR-AM-codi-b-686 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:Validati | 686 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException(ApiValues.INVALID_CONCEPT, fields);` |
| BR-AM-codi-b-699 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:Validati | 699 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException(ApiValues.VALID_CONCEPT, fields);` |
| BR-AM-codi-pay-96 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:Util | 96 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException("Formato invalido para [amount], debería ser #.##"` |
| BR-AM-codi-pay-106-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:Util | 106 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException("Formato invalido para [amount], debería ser #.##"` |
| BR-AM-codi-pay-278 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:Validation | 278 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException(apiValues.getMsgValuesMissing(), fields);` |
| BR-AM-codi-pay-804 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:Validation | 804 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException(ApiValues.INVALID_CONCEPT, fields);` |
| BR-AM-codi-pay-817 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:Validation | 817 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException(ApiValues.VALID_CONCEPT, fields);` |
| BR-AM-codi-ope-253 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 253 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException(SpecialCharacterConstants.EMPTY_STRING, errorField` |
| BR-AM-codi-rep-92 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:Util | 92 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException("Formato invalido para [amount], debería ser #.##"` |
| BR-AM-codi-rep-102 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:Util | 102 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException("Formato invalido para [amount], debería ser #.##"` |
| BR-AM-codi-rep-119 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-repayment:Util | 119 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException("El campo [concept] contiene caracteres invalidos!` |
| BR-AM-codi-rep-134 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-repayment:Util | 134 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException("No puede estar nulo o en blanco [trackingKey]", f` |
| BR-AM-codi-rep-245 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:Validati | 245 | Banxico CoDi — Circular 14/2017 Banxico CoDi | BadRequestException | `throw new BadRequestException(apiValues.getMsgValuesMissing(), fields);` |
| BR-AM-cred-b-137 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-credit-account-validati | 137 | — | BadRequestException | `throw new BadRequestException(message, badFields);` |
| BR-AM-cred-val-111 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-credit-account-validati | 111 | — | BadRequestException | `throw new BadRequestException(message, badFields);` |
| BR-AM-cvv-act-317 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Cvv | 317 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | DownstreamException | `throw new DownstreamException(HttpStatus.FORBIDDEN.value(),` |
| BR-AM-cvv-act-349 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Cvv | 349 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | DownstreamException | `throw new DownstreamException(HttpStatus.FORBIDDEN.value(),` |
| BR-AM-cvv-act-77 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Cvv | 77 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | UnauthorizedException | `throw new UnauthorizedException(Constants.ERROR_CUSTOMER);` |
| BR-AM-cvv-b-184 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:Clie | 184 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cvv-b-269 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:Clie | 269 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-val-592 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-deposit-account-validat | 592 | — | DepositAccountDataApiDataNotFoundException | `throw new DepositAccountDataApiDataNotFoundException();` |
| BR-AM-depo-val-105 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-deposit-account-validat | 105 | — | ContingecySpeiApiDataNotFoundException | `throw new ContingecySpeiApiDataNotFoundException();` |
| BR-AM-depo-val-149 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-deposit-account-validat | 149 | — | DepositAccountDataApiDataNotFoundException | `throw new DepositAccountDataApiDataNotFoundException();` |
| BR-AM-inte-b-319 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 319 | — | DownstreamException | `throw new DownstreamException(HttpStatus.FORBIDDEN.value(), errorResponse);` |
| BR-AM-inte-b-336 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 336 | — | BadRequestException | `throw new BadRequestException(errorConstants.getAliasRequiered(),` |
| BR-AM-inte-b-350 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 350 | — | DownstreamException | `throw new DownstreamException(HttpStatus.FORBIDDEN.value(), errorResponse);` |
| BR-AM-inte-b-115 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 115 | — | DownstreamException | `throw new DownstreamException(HttpStatus.FORBIDDEN.value(), errorResponse);` |
| BR-AM-inte-pay-84 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment: | 84 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-intr-b-133 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 133 | — | BadRequestException | `throw new BadRequestException("Formato de monto invalido, debería ser #.##", fie` |
| BR-AM-intr-b-143 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 143 | — | BadRequestException | `throw new BadRequestException("Formato de monto invalido, debería ser #.##", fie` |
| BR-AM-intr-b-163 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 163 | — | BadRequestException | `throw new BadRequestException("El campo alias no puede ir nulo ni vacío", fields` |
| BR-AM-intr-pay-126 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment: | 126 | — | BadRequestException | `throw new BadRequestException("Invalid amount format, must be #.##", fields);` |
| BR-AM-intr-pay-136 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment: | 136 | — | BadRequestException | `throw new BadRequestException("Invalid amount format, must be #.##", fields);` |
| BR-AM-own-pay-572 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-own-card-payment:Paymen | 572 | — | BadRequestException | `throw new BadRequestException(Constants.MSG_CURLY_BRACKETS_AMOUNT, new ArrayList` |
| BR-AM-own-pay-583 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-own-card-payment:Paymen | 583 | — | BadRequestException | `throw new BadRequestException(Constants.MSG_CURLY_BRACKETS_AMOUNT, new ArrayList` |
| BR-AM-paym-val-116 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-payment-register-valida | 116 | — | UnauthorizedException | `throw new UnauthorizedException(CodiCvvConstants.UNAUTHORIZED);` |
| BR-AM-paym-val-163 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-payment-register-valida | 163 | — | UnauthorizedException | `throw new UnauthorizedException(CodiCvvConstants.UNAUTHORIZED);` |
| BR-AM-paym-val-179 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-payment-register-valida | 179 | Banxico CoDi — Circular 14/2017 Banxico CoDi; PCI-DSS — PCI- | BadRequestException | `case null, default     -> throw new BadRequestException(` |
| BR-AM-serv-b-242 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Erro | 242 | — | DownstreamException | `throw new DownstreamException();` |
| BR-AM-cell-b-74 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 74 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-cell-b-121 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 121 | — | NotValidHeadersException | `throw new NotValidHeadersException(ApiConstants.USER_AGENT);` |
| BR-AM-cell-aut-94 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 94 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-cell-aut-157 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 157 | Banxico SPEI — Circular 14/2017 Banxico SPEI | NotValidHeadersException | `throw new NotValidHeadersException(headerError);` |
| BR-AM-cell-aut-171 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 171 | — | NotValidHeadersException | `throw new NotValidHeadersException(ApiConstants.USER_AGENT);` |
| BR-AM-cell-aut-185 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 185 | — | NotValidHeadersException | `throw new NotValidHeadersException(ApiConstants.DEVICE_INFORMATION);` |
| BR-AM-phon-b-93 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-b:Serv | 93 | — | DownstreamException | `throw new DownstreamException(ex);` |
| BR-AM-phon-b-128 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-b:Serv | 128 | — | DownstreamException | `throw new DownstreamException(ex);` |
| BR-AM-phon-b-619 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 619 | — | NotValidHeadersException | `throw new NotValidHeadersException(ApiConstants.DEVICE_INFORMATION);` |
| BR-AM-phon-b-623 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 623 | — | NotValidHeadersException | `throw new NotValidHeadersException(ApiConstants.USER_AGENT);` |
| BR-AM-phon-b-912 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 912 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-phon-b-72 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 72 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-phon-b-161 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 161 | — | DownstreamException | `throw new DownstreamException((DownstreamException) throwable);` |
| BR-AM-phon-b-290 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 290 | — | BadRequestException | `throw new BadRequestException(ApiConstants.BAD_REQUEST,` |
| BR-AM-phon-b-295 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 295 | — | BadRequestException | `throw new BadRequestException(ApiConstants.BAD_REQUEST,` |
| BR-AM-phon-con-483 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 483 | — | NotValidHeadersException | `throw new NotValidHeadersException(ApiConstants.DEVICE_INFORMATION);` |
| BR-AM-phon-con-487 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 487 | — | NotValidHeadersException | `throw new NotValidHeadersException(ApiConstants.USER_AGENT);` |
| BR-AM-phon-con-218 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 218 | — | DownstreamException | `throw new DownstreamException((DownstreamException) ex);` |
| BR-AM-phon-con-241 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 241 | — | BadRequestException | `throw new BadRequestException(ApiConstants.BAD_REQUEST,` |
| BR-AM-phon-con-246 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 246 | — | BadRequestException | `throw new BadRequestException(ApiConstants.BAD_REQUEST,` |
| BR-AM-phon-enr-150 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment:Util | 150 | — | DownstreamException | `throw new DownstreamException((DownstreamException) throwable);` |
| BR-AM-appl-b-78 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-p-security-application-validations | 78 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-appl-b-180 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-application-validations | 180 | — | MongoDataNotFoundException | `throw new MongoDataNotFoundException();` |
| BR-AM-appl-val-70 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-p-security-application-validations | 70 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-appl-val-184 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-application-validations | 184 | — | MongoDataNotFoundException | `throw new MongoDataNotFoundException();` |
| BR-AM-phon-tok-325 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-gemalto-token:Gem | 325 | — | UnauthorizedException | `throw new UnauthorizedException(ApiConstants.ERROR_OTP_VALIDATION_MSG);` |
| BR-AM-phon-tok-193 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-p-security-phone-gemalto-token:Gem | 193 | — | UnauthorizedException | `throw new UnauthorizedException(ApiConstants.NOT_ENROLLED_TOKEN_MSG);` |
| BR-AM-phon-tok-180 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-p-security-phone-token:CellphoneTo | 180 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(ApiConstants.ACCEPT));` |
| BR-AM-phon-tok-187 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CellphoneTo | 187 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | BadRequestException | `throw new BadRequestException(ex.getMessage(), Arrays.asList(phoneTokenRequest.g` |
| BR-AM-phon-tok-183 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-p-security-phone-token:Util | 183 | — | NotValidHeadersException | `throw new NotValidHeadersException(errorsHeaders);` |
| BR-AM-cred-act-97 | INFRAESTRUCTURA | Credit | msacr-b-business-credit-card-activation: | 97 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.GEOLOCATION_LATITUDE)` |
| BR-AM-cred-act-101 | INFRAESTRUCTURA | Credit | msacr-b-business-credit-card-activation: | 101 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.GEOLOCATION_LONGITUDE` |
| BR-AM-cred-act-549 | NEGOCIO | Credit | msacr-b-business-credit-card-activation: | 549 | — | TimeoutException | `throw new TimeoutException(exception.getMessage());` |
| BR-AM-cred-act-559 | NEGOCIO | Credit | msacr-b-business-credit-card-activation: | 559 | — | TimeoutException | `throw new TimeoutException(exception.getMessage());` |
| BR-AM-cred-b-119 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-b:C | 119 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-b-146 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-b:C | 146 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-det-92 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-det | 92 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-det-106 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 106 | — | BadRequestException | `throw new BadRequestException(Constants.CREDIT_NUMBER_MANDATORY, new ArrayList<>` |
| BR-AM-cred-det-82 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-det | 82 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-det-80 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-det | 80 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-det-73 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 73 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-det-73-1 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 73 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-det-103 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-det | 103 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-det-81 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 81 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-det-97 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 97 | — | BadRequestException | `throw new BadRequestException(Constants.ERROR_MSG_EMPTY_FIELDS, Arrays` |
| BR-AM-cred-det-107 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 107 | — | TimeOutException | `throw new TimeOutException();` |
| BR-AM-cred-mov-129 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-mov | 129 | — | BadRequestException | `throw new BadRequestException(apiValue.getBadRequestExceptionMessage(), new Arra` |
| BR-AM-cred-mov-138 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-mov | 138 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ApiConstants.ERROR_DB_TIMEOUT, ex);` |
| BR-AM-cred-mov-179 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-mov | 179 | — | BadRequestException | `throw new BadRequestException(apiValue.getBadRequestExceptionMessage(), new Arra` |
| BR-AM-cred-acc-103 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts:Cre | 103 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-acc-96 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts:Cre | 96 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-inte-dat-124 | NEGOCIO | Credit | msacr-d-domain-intercard-data:IntercardD | 124 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-card-val-90 | INFRAESTRUCTURA | Credit | msacr-d-security-card-data-validation:Se | 90 | — | UnauthorizedException | `throw new UnauthorizedException(Constants.ERROR_CHANNEL_INVALID);` |
| BR-AM-amor-inf-123 | INFRAESTRUCTURA | Cross-domain | msaxd-b-business-amortization-informatio | 123 | — | BadRequestException | `throw new BadRequestException(Constants.MSG_CREDIT_NUMBER_EMPTY,` |
| BR-AM-amor-inf-202 | INFRAESTRUCTURA | Cross-domain | msaxd-b-business-amortization-informatio | 202 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ApiConstants.TIMEOUT_DOMAIN);` |
| BR-AM-amor-inf-153 | INFRAESTRUCTURA | Cross-domain | msaxd-b-business-amortization-informatio | 153 | — | BadRequestException | `throw new BadRequestException(Constants.MSG_CREDIT_NUMBER_EMPTY,` |
| BR-AM-amor-inf-531 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 531 | — | BadRequestException | `throw new BadRequestException(ApiConstants.ERROR_LIMITES,` |
| BR-AM-amor-inf-88 | INFRAESTRUCTURA | Cross-domain | msaxd-b-business-amortization-informatio | 88 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ApiConstants.TIMEOUT_DOMAIN);` |
| BR-AM-amor-inf-138 | INFRAESTRUCTURA | Cross-domain | msaxd-b-business-amortization-informatio | 138 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ApiConstants.TIMEOUT_DOMAIN);` |
| BR-AM-amor-inf-192 | INFRAESTRUCTURA | Cross-domain | msaxd-b-business-amortization-informatio | 192 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ApiConstants.TIMEOUT_DOMAIN);` |
| BR-AM-amor-inf-250 | INFRAESTRUCTURA | Cross-domain | msaxd-b-business-amortization-informatio | 250 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ApiConstants.TIMEOUT_DOMAIN);` |
| BR-AM-cred-dat-214 | INFRAESTRUCTURA | Cross-domain | msaxd-b-business-credit-agreement-data:R | 214 | — | BadRequestException | `throw new BadRequestException(Constants.MESSAGE_EMPTY_ASSOCIATED_ACCOUNT, fields` |
| BR-AM-cred-dat-226 | NEGOCIO | Cross-domain | msaxd-b-business-credit-agreement-data:R | 226 | — | NotValidHeadersException | `throw new NotValidHeadersException(HttpHeaders.CONTENT_TYPE);` |
| BR-AM-amor-inf-133 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 133 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-amor-inf-180 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 180 | — | BadRequestException | `throw new BadRequestException(Constants.MSG_CURRENT_DATE_NULL_EMPTY,` |
| BR-AM-amor-inf-108 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 108 | — | BadRequestException | `throw new BadRequestException(Constants.BAD_REQUEST,` |
| BR-AM-amor-inf-124 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-amortization-information: | 124 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cust-sum-113 | NEGOCIO | Cross-domain | msaxd-d-domain-customer-accounts-summary | 113 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(LogConstants.ERROR_TIMEOUT);` |
| BR-AM-holi-que-97 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-holiday-query:HolidayServ | 97 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage(), exception);` |
| BR-AM-holi-que-125 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-holiday-query:HolidayServ | 125 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(e.getMessage(), e);` |
| BR-AM-holi-que-170 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-holiday-query:HolidayServ | 170 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception);` |
| BR-AM-inte-sta-119 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-interbank-services-status | 119 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-inte-sta-133 | NEGOCIO | Cross-domain | msaxd-d-domain-interbank-services-status | 133 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ApiConstants.ERROR_DB_TIMEOUT, ex);` |
| BR-AM-unus-ope-93 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-unusual-operations:Unusua | 93 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cred-sta-149 | NEGOCIO | Customer Management | msacm-b-business-credit-rating-state:Dig | 149 | — | UnauthorizedException | `throw new UnauthorizedException(ex);` |
| BR-AM-cred-sta-266 | NEGOCIO | Customer Management | msacm-b-business-credit-rating-state:Dig | 266 | — | UnauthorizedException | `throw new UnauthorizedException(exception);` |
| BR-AM-cred-sta-300 | NEGOCIO | Customer Management | msacm-b-business-credit-rating-state:Dig | 300 | — | UnauthorizedException | `throw new UnauthorizedException(exception);` |
| BR-AM-cust-dat-66 | INFRAESTRUCTURA | Customer Management | msacm-b-business-customer-personal-data: | 66 | — | UnauthorizedException | `throw new UnauthorizedException(errorResolverConstants.getUnauthorizedExceptionM` |
| BR-AM-cust-dat-122 | INFRAESTRUCTURA | Customer Management | msacm-b-business-customer-personal-data: | 122 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-cust-dat-191 | INFRAESTRUCTURA | Customer Management | msacm-b-business-customer-personal-data: | 191 | — | BadRequestException | `throw new BadRequestException(errorResolver.getBadRequestExceptionMessage(),` |
| BR-AM-digi-dat-460 | INFRAESTRUCTURA | Customer Management | msacm-b-business-digital-agreement-servi | 460 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-digi-dat-465 | INFRAESTRUCTURA | Customer Management | msacm-b-business-digital-agreement-servi | 465 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-digi-dat-682 | INFRAESTRUCTURA | Customer Management | msacm-b-business-digital-agreement-servi | 682 | — | FadDownstreamException | `throw new FadDownstreamException(resp.getStatusCodeValue(), requisitionsInfoResp` |
| BR-AM-offe-pro-61 | INFRAESTRUCTURA | Customer Management | msacm-b-business-offer-products:AuthAOP | 61 | — | UnauthorizedException | `throw new UnauthorizedException(errorResolverConstants.getUnauthorizedExceptionM` |
| BR-AM-biom-val-231 | NEGOCIO | Customer Management | msacm-d-business-biometric-identity-vali | 231 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-cust-b-82 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-data-name-b:Se | 82 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-cust-nam-73 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-data-name:Secu | 73 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-cust-val-163 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-data-validatio | 163 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-cust-val-77 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-data-validatio | 77 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-cust-dat-207 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-proposition-da | 207 | — | FeignTimeoutException | `throw new FeignTimeoutException(ErrorResolverConstants.FEIGN_TIMEOUT_MESSAGE);` |
| BR-AM-cust-dat-259 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-proposition-da | 259 | — | DownstreamException | `throw new DownstreamException();` |
| BR-AM-cust-dat-268 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-proposition-da | 268 | — | FeignTimeoutException | `throw new FeignTimeoutException(ErrorResolverConstants.FEIGN_TIMEOUT_MESSAGE);` |
| BR-AM-cust-dat-298 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-proposition-da | 298 | — | UnauthorizedException | `throw new UnauthorizedException(ex.getMessage());` |
| BR-AM-iden-rec-202 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 202 | — | BadRequestException | `throw new BadRequestException(SpecialCharacterConstants.EMPTY_STRING,` |
| BR-AM-iden-rec-366 | INFRAESTRUCTURA | Customer Management | msacm-d-business-identity-data-recovery: | 366 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-iden-rec-378 | INFRAESTRUCTURA | Customer Management | msacm-d-business-identity-data-recovery: | 378 | — | BadRequestException | `throw new BadRequestException(cause.getMessage(), new ArrayList<>());` |
| BR-AM-iden-rec-95 | INFRAESTRUCTURA | Customer Management | msacm-d-business-identity-data-recovery: | 95 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-iden-ret-68 | INFRAESTRUCTURA | Customer Management | msacm-d-business-identity-data-retrive:A | 68 | — | UnauthorizedException | `throw new UnauthorizedException(errorResolverConstants.getUnauthorizedExceptionM` |
| BR-AM-iden-val-307 | INFRAESTRUCTURA | Customer Management | msacm-d-business-identity-data-validatio | 307 | — | BadRequestException | `throw new BadRequestException(ex.getCause().getMessage(), new ArrayList<>());` |
| BR-AM-blac-val-29 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-black-lists-validation:Pa | 29 | — | BadRequestException | `throw new BadRequestException(String.format(Constants.PARAMETER_INVALID_MESSAGE,` |
| BR-AM-blac-val-109 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-black-lists-validation:Va | 109 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-blac-val-93 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-black-lists-validation:Va | 93 | — | BadRequestException | `throw new BadRequestException(Constants.DATE_CONVERSION_ERROR_MESSAGE,` |
| BR-AM-blac-val-105 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-black-lists-validation:Va | 105 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-cust-ope-80 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-cellphone-operat | 80 | — | TimeoutException | `throw new TimeoutException(exception);` |
| BR-AM-cust-ope-100 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-cellphone-operat | 100 | — | TimeoutException | `throw new TimeoutException(exception);` |
| BR-AM-cust-ope-97 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-cellphone-operat | 97 | — | TimeoutException | `throw new TimeoutException(exception);` |
| BR-AM-cust-dat-163 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-data:CustomerDat | 163 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cust-b-103 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 103 | — | TimeoutException | `throw new TimeoutException("Error al ejecutar metodo");` |
| BR-AM-cust-b-108 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 108 | — | TimeoutException | `throw new TimeoutException("Error al ejecutar metodo");` |
| BR-AM-cust-b-96 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 96 | — | TimeoutException | `throw new TimeoutException("Error al ejecutar metodo");` |
| BR-AM-cust-b-125 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 125 | — | BadRequestException | `throw new BadRequestException(Constants.BAD_REQUEST_DESCRIPTION);` |
| BR-AM-cust-b-209 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 209 | — | BadRequestException | `throw new BadRequestException(ApiConstants.BAD_REQUEST,` |
| BR-AM-cust-sta-113 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 113 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cust-sta-194 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 194 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cust-sta-257 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 257 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cust-sta-160 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 160 | — | NotValidHeadersException | `throw new NotValidHeadersException(header);` |
| BR-AM-cust-sta-67 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 67 | — | NotValidHeadersException | `throw new NotValidHeadersException(ApiConstants.CHANNEL_ID);` |
| BR-AM-cust-man-140 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-identification-m | 140 | — | BadRequestException | `throw new BadRequestException("Header faltante en la peticion: " + HttpHeaders.C` |
| BR-AM-cust-man-102 | NEGOCIO | Customer Management | msacm-d-domain-customer-identification-m | 102 | — | BadRequestException | `throw new BadRequestException(LogConstants.ERROR_BAD_REQUEST, errorFields);` |
| BR-AM-cust-man-107 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-identification-m | 107 | — | BadRequestException | `throw new BadRequestException(LogConstants.ERROR_BAD_REQUEST, errorFields);` |
| BR-AM-cust-man-118 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-identification-m | 118 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(LogConstants.ERROR_TIMEOUT);` |
| BR-AM-cust-man-144 | NEGOCIO | Customer Management | msacm-d-domain-customer-identification-m | 144 | — | BadRequestException | `throw new BadRequestException(LogConstants.ERROR_BAD_REQUEST, errorFields);` |
| BR-AM-cust-man-155 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-identification-m | 155 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(LogConstants.ERROR_TIMEOUT);` |
| BR-AM-cust-pro-92 | NEGOCIO | Customer Management | msacm-d-domain-customer-products:Custome | 92 | — | CustomerAccountBadRequestException | `throw new CustomerAccountBadRequestException(ApiConstants.LENGTH_NO_VALID_CUSTOM` |
| BR-AM-cust-pro-96 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-products:Custome | 96 | — | CustomerAccountBadRequestException | `throw new CustomerAccountBadRequestException(ApiConstants.LENGTH_NO_VALID_COMPAN` |
| BR-AM-cust-pro-103 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-products:Custome | 103 | — | CustomerAccountBadRequestException | `throw new CustomerAccountBadRequestException(ApiConstants.LENGTH_NO_VALID_CUSTOM` |
| BR-AM-cust-dat-103 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-proposition-data | 103 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-cust-dat-165 | NEGOCIO | Customer Management | msacm-d-domain-customer-proposition-data | 165 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-cust-dat-184 | NEGOCIO | Customer Management | msacm-d-domain-customer-proposition-data | 184 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-cust-ver-345 | INFRAESTRUCTURA | Customer Management | msacm-d-platform-customer-enrollment-ver | 345 | — | BadRequestException | `throw new BadRequestException(apiConstants.getResponseCustomerNotValid(),` |
| BR-AM-cust-man-196 | INFRAESTRUCTURA | Customer Management | msacm-d-security-customer-access-managme | 196 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-cust-man-226 | INFRAESTRUCTURA | Customer Management | msacm-d-security-customer-access-managme | 226 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-push-ser-158 | INFRAESTRUCTURA | Customer Management | msacm-d-security-push-notifications-serv | 158 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-push-ser-259 | INFRAESTRUCTURA | Customer Management | msacm-d-security-push-notifications-serv | 259 | — | CheckHeadersException | `throw new CheckHeadersException(Constants.BAD_FORMAT_HEADER_MSG.concat(Constants` |
| BR-AM-push-ser-279 | INFRAESTRUCTURA | Customer Management | msacm-d-security-push-notifications-serv | 279 | — | CheckHeadersException | `throw new CheckHeadersException(` |
| BR-AM-push-ser-545 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 545 | — | LatiniaTimeoutException | `throw new LatiniaTimeoutException();` |
| BR-AM-push-ser-248 | INFRAESTRUCTURA | Customer Management | msacm-d-security-push-notifications-serv | 248 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-push-ser-428 | INFRAESTRUCTURA | Customer Management | msacm-d-security-push-notifications-serv | 428 | — | LatiniaTimeoutException | `throw new LatiniaTimeoutException();` |
| BR-AM-push-ser-144 | INFRAESTRUCTURA | Customer Management | msacm-d-security-push-notifications-serv | 144 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-push-ser-196 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 196 | — | LatiniaTimeoutException | `throw new LatiniaTimeoutException();` |
| BR-AM-phon-otp-211 | INFRAESTRUCTURA | Customer Management | msacm-i-security-phone-otp:ValidateOtpBu | 211 | — | OtpUnauthorizedException | `throw new OtpUnauthorizedException();` |
| BR-AM-sess-man-133 | NEGOCIO | Customer Management | msacm-p-security-session-management:Cust | 133 | — | UnauthorizedException | `throw new UnauthorizedException(Constants.MSG_AUTHENTICATION_ERROR);` |
| BR-AM-sess-man-137 | NEGOCIO | Customer Management | msacm-p-security-session-management:Cust | 137 | — | UnauthorizedException | `throw new UnauthorizedException(Constants.MSG_AUTHENTICATION_ERROR);` |
| BR-AM-sess-man-280 | INFRAESTRUCTURA | Customer Management | msacm-p-security-session-management:Open | 280 | — | OpenSessionUnauthorizedException | `throw new OpenSessionUnauthorizedException(ssoOpenSessionRequest.getUserName(), ` |
| BR-AM-acco-ben-211 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 211 | — | BadRequestException | `throw new BadRequestException(errorResolver.getBadRequestExceptionMessage(),` |
| BR-AM-acco-ben-361 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 361 | — | BadRequestException | `throw new BadRequestException(errorResolver.getBadRequestExceptionMessage(),` |
| BR-AM-acco-ben-65 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 65 | — | UnauthorizedException | `throw new UnauthorizedException(errorResolverConstants.getUnauthorizedExceptionM` |
| BR-AM-acco-ben-36 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-account-beneficiaries:V | 36 | — | NotValidHeadersException | `throw new NotValidHeadersException(header);` |
| BR-AM-depo-b-211 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 211 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-depo-b-238 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 238 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-depo-b-276 | NEGOCIO | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 276 | — | BadRequestException | `throw new BadRequestException(Constants.EMPTY_DATA + request.getReference(),` |
| BR-AM-depo-det-211 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 211 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-depo-det-238 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 238 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-depo-det-276 | NEGOCIO | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 276 | — | BadRequestException | `throw new BadRequestException(Constants.EMPTY_DATA + request.getReference(),` |
| BR-AM-digi-man-143 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 143 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-digi-man-235 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 235 | — | TimeoutException | `throw new TimeoutException(LoggerConstants.ERROR_DIGITAL_ENVELOPE_UNKNOWN_CREATE` |
| BR-AM-digi-man-137 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 137 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-digi-man-216 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 216 | — | TimeoutException | `throw new TimeoutException(LoggerConstants.ERROR_DIGITAL_ENVELOPE_UNKNOWN_CUSTOM` |
| BR-AM-digi-man-167 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 167 | — | BadRequestException | `throw new BadRequestException(LoggerConstants.ERROR_REQUEST_BODY_VALIDATION, fie` |
| BR-AM-digi-man-387 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 387 | — | BadRequestException | `throw new BadRequestException(LoggerConstants.ERROR_REQUEST_BODY_VALIDATION, fie` |
| BR-AM-digi-man-401 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 401 | — | BadRequestException | `throw new BadRequestException(LoggerConstants.ERROR_REQUEST_BODY_VALIDATION,` |
| BR-AM-digi-man-143-1 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 143 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-digi-man-218 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 218 | — | TimeoutException | `throw new TimeoutException(LoggerConstants.ERROR_DIGITAL_ENVELOPE_UNKNOWN_UPDATE` |
| BR-AM-digi-man-60 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 60 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-digi-man-92 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 92 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-digi-man-99 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 99 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-digi-mov-82 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-moveme | 82 | — | BadRequestException | `throw new BadRequestException(this.errorResolverConstants.getExceptionMessage(),` |
| BR-AM-digi-tra-146 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-transa | 146 | — | BadRequestException | `throw new BadRequestException(this.errorResolverConstants.getExceptionMessage(),` |
| BR-AM-digi-tra-158 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-transa | 158 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getExceptionMessage(),` |
| BR-AM-inve-ope-76 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-investment-account-open | 76 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-inve-ope-367 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-investment-account-open | 367 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.GEOLOCATION_LATITUDE)` |
| BR-AM-inve-ope-371 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-investment-account-open | 371 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.GEOLOCATION_LONGITUDE` |
| BR-AM-inve-ope-376 | NEGOCIO | Deposit & Transfer | msadp-b-business-investment-account-open | 376 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.XX_APLICATION_NAME));` |
| BR-AM-inve-acc-177 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-investments-accounts:In | 177 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-prom-ope-68 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-promissory-account-open | 68 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-prom-ope-354 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-account-open | 354 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.APPLICATION_NAME));` |
| BR-AM-prom-ope-358 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-promissory-account-open | 358 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.GEOLOCATION_LATITUDE)` |
| BR-AM-prom-ope-362 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-promissory-account-open | 362 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.GEOLOCATION_LONGITUDE` |
| BR-AM-prom-b-163 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 163 | — | TimeoutException | `throw new TimeoutException(LogConstants.ERROR_SERVICE_UNAVAILABLE);` |
| BR-AM-prom-mov-146 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 146 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-prom-acc-169 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 169 | — | UnauthorizedException | `throw new UnauthorizedException(ex.getMessage());` |
| BR-AM-leve-acc-207 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 207 | — | BadRequestException | `throw new BadRequestException(cause.getMessage(), new ArrayList<String>());` |
| BR-AM-leve-acc-276 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 276 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-leve-acc-76 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 76 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-leve-acc-177 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 177 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-leve-acc-286 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 286 | — | BadRequestException | `throw new BadRequestException(Constants.CELLPHONENUMBER_MESSAGE,` |
| BR-AM-appl-tra-121 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 121 | — | BadRequestException | `throw new BadRequestException(` |
| BR-AM-appl-tra-48 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 48 | — | AcquireTimeoutException | `throw new AcquireTimeoutException("Timed out waiting for a permit after " + time` |
| BR-AM-appl-tra-80 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 80 | — | BadRequestException | `throw new BadRequestException();` |
| BR-AM-appl-tra-98 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 98 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-appl-tra-151 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 151 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ex.getMessage());` |
| BR-AM-depo-b-86 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-b:Deposi | 86 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-b-111 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-b:Deposi | 111 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-b-107 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 107 | — | BadRequestException | `throw new BadRequestException(ApiDocumentationConstants.FIELD_BENEFICIARIES_VALI` |
| BR-AM-depo-b-116 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 116 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-b-205 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 205 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-ben-98 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 98 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-b-127 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 127 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-depo-b-141 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 141 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getCause());` |
| BR-AM-depo-b-157 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 157 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getCause());` |
| BR-AM-depo-det-106 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 106 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException("Timeout al obtener el número de tarjeta de o` |
| BR-AM-depo-det-109 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 109 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException("Timeout al obtener el número de tarjeta de o` |
| BR-AM-depo-det-96 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 96 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-det-105 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 105 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-det-149 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 149 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-depo-det-177 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 177 | — | BadRequestException | `throw new BadRequestException(ApiConstants.MSG_REFERENCE_MUST_NOT_BE_BLANK,` |
| BR-AM-depo-det-89 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 89 | — | BadRequestException | `throw new BadRequestException("Folio Branch Office is required",` |
| BR-AM-depo-mov-134 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 134 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-depo-mov-191 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 191 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(StringUtils.EMPTY, ex);` |
| BR-AM-depo-acc-113 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts:Deposits | 113 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-depo-acc-207 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts:Deposits | 207 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-digi-acc-88 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-digital-envelope-accounts | 88 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-digi-acc-108 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-digital-envelope-accounts | 108 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-digi-acc-166 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-digital-envelope-accounts | 166 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-inve-ope-101 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-investment-account-openin | 101 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-inve-ope-145 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-investment-account-openin | 145 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ex.getMessage());` |
| BR-AM-inve-acc-90 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-investments-accounts:Inve | 90 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-prom-ope-84 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 84 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-prom-b-116 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 116 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(StringUtils.EMPTY, exception);` |
| BR-AM-prom-mov-158 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 158 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(StringUtils.EMPTY, ex);` |
| BR-AM-prom-acc-93 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 93 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-push-man-375 | INFRAESTRUCTURA | Infrastructure Messaging | msaim-p-platform-push-notifications-serv | 375 | — | LatiniaTimeoutException | `throw new LatiniaTimeoutException();` |
| BR-AM-digi-pro-266 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-digital-loan-provisioni | 266 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-pers-b-305 | NEGOCIO | Lending / Loans | msalo-b-business-personal-loan-provision | 305 | — | TimeoutException | `throw new TimeoutException(error);` |
| BR-AM-pers-b-120 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-personal-loan-provision | 120 | — | TimeoutException | `throw new TimeoutException(ex.getMessage());` |
| BR-AM-pers-b-154 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-personal-loan-provision | 154 | — | TimeoutException | `throw new TimeoutException(LogConstants.LOG_TIMEOUT_ERROR);` |
| BR-AM-pers-b-130 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-personal-loan-provision | 130 | — | TimeoutException | `throw new TimeoutException(Constants.TIME_OUT_UNAVAILABLE_DEPOSIT);` |
| BR-AM-pers-b-75 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-personal-loan-provision | 75 | — | NotValidHeadersException | `throw new NotValidHeadersException(Collections.singletonList(Constants.GEOLOCATI` |
| BR-AM-pers-b-79 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-personal-loan-provision | 79 | — | NotValidHeadersException | `throw new NotValidHeadersException(` |
| BR-AM-pers-b-104 | NEGOCIO | Lending / Loans | msalo-b-business-personal-loan-provision | 104 | — | NotValidHeadersException | `throw new NotValidHeadersException(new ArrayList<>(badFields));` |
| BR-AM-sala-con-59 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-salary-advance-confirm: | 59 | — | NotValidHeadersException | `throw new NotValidHeadersException(header);` |
| BR-AM-sala-rec-59 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-salary-advance-receptio | 59 | — | NotValidHeadersException | `throw new NotValidHeadersException(header);` |
| BR-AM-cred-det-88 | NEGOCIO | Lending / Loans | msalo-d-domain-credit-loans-accounts-det | 88 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception);` |
| BR-AM-cred-acc-98 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-credit-loans-accounts:Loa | 98 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cust-val-103 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 103 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-cust-val-104 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 104 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-digi-pro-112 | NEGOCIO | Lending / Loans | msalo-d-domain-digital-loan-provisioning | 112 | — | ExecuteSplException | `throw new ExecuteSplException(SqlConstants.MSG_SP_FAIL, resultSp.getCodRet());` |
| BR-AM-digi-pro-164 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-digital-loan-provisioning | 164 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-digi-det-88 | NEGOCIO | Lending / Loans | msalo-d-domain-digital-loans-accounts-de | 88 | — | DataBaseTimeOutException | `throw new DataBaseTimeOutException();` |
| BR-AM-loan-b-106 | NEGOCIO | Lending / Loans | msalo-d-domain-loans-accounts-movements- | 106 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-loan-b-163 | NEGOCIO | Lending / Loans | msalo-d-domain-loans-accounts-movements- | 163 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-sala-act-70 | NEGOCIO | Lending / Loans | msalo-d-domain-salary-advance-activation | 70 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-sala-req-54 | NEGOCIO | Lending / Loans | msalo-d-domain-salary-advance-request:Re | 54 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-sala-req-64 | NEGOCIO | Lending / Loans | msalo-d-domain-salary-advance-request:Re | 64 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-sala-req-75 | NEGOCIO | Lending / Loans | msalo-d-domain-salary-advance-request:Re | 75 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getBadRequestExceptionMessa` |
| BR-AM-send-doc-152 | NEGOCIO | Messaging | msamg-p-platform-send-customer-documents | 152 | — | DownstreamException | `throw new DownstreamException();` |
| BR-AM-copp-pay-119 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ApiValid | 119 | — | BadRequestException | `throw new BadRequestException(errorResolverConstants.getWalletAmountsNomatch(),` |
| BR-AM-copp-pay-170 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ApiValid | 170 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_EMPTY_CARD_REQUEST, new ArrayList` |
| BR-AM-copp-pay-266 | INFRAESTRUCTURA | Payments | msapy-b-business-coppel-payment:ApiValid | 266 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.XX_APPLICATION_NAME))` |
| BR-AM-copp-pay-270 | INFRAESTRUCTURA | Payments | msapy-b-business-coppel-payment:ApiValid | 270 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.GEOLOCATION_LATITUDE)` |
| BR-AM-copp-pay-274 | INFRAESTRUCTURA | Payments | msapy-b-business-coppel-payment:ApiValid | 274 | — | NotValidHeadersException | `throw new NotValidHeadersException(Arrays.asList(Constants.GEOLOCATION_LONGITUDE` |
| BR-AM-copp-pay-124 | NEGOCIO | Payments | msapy-b-business-coppel-payment:CoppelAu | 124 | — | TimeoutException | `throw new TimeoutException(LogConstants.LOG_OMNICANAL_SESON_FAIL);` |
| BR-AM-remi-pay-260 | INFRAESTRUCTURA | Payments | msapy-b-business-remittance-payment:Paym | 260 | — | RemittanceMotorTimeoutException | `throw new RemittanceMotorTimeoutException(LogConstants.ENGINE_TIMEOUT_ERROR);` |
| BR-AM-remi-pay-398 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 398 | — | BadRequestException | `throw new BadRequestException(LogConstants.MSG_OTP_FAILED, Arrays.asList(LogCons` |
| BR-AM-remi-pay-401 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 401 | — | BadRequestException | `throw new BadRequestException(LogConstants.MSG_REMITTANCE_KEY_FAILED,` |
| BR-AM-remi-pay-405 | INFRAESTRUCTURA | Payments | msapy-b-business-remittance-payment:Paym | 405 | — | BadRequestException | `throw new BadRequestException(LogConstants.MSG_ACCOUNT_NUMBER_FAILED,` |
| BR-AM-remi-pay-409 | INFRAESTRUCTURA | Payments | msapy-b-business-remittance-payment:Paym | 409 | — | BadRequestException | `throw new BadRequestException(LogConstants.MSG_INVOICE_BRANCH_FAILED,` |
| BR-AM-remi-pay-205 | INFRAESTRUCTURA | Payments | msapy-b-business-remittance-payment:Vali | 205 | — | RemittanceMotorTimeoutException | `throw new RemittanceMotorTimeoutException(LogConstants.ENGINE_TIMEOUT_ERROR);` |
| BR-AM-remi-pay-321 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Vali | 321 | — | BadRequestException | `throw new BadRequestException(LogConstants.MSG_REMITTANCE_KEY_FAILED,` |
| BR-AM-remi-pay-328 | INFRAESTRUCTURA | Payments | msapy-b-business-remittance-payment:Vali | 328 | — | BadRequestException | `throw new BadRequestException(LogConstants.MSG_REMITTANCE_KEY_LENGTH_FAILED,` |
| BR-AM-codi-pay-90 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:InterbankCod | 90 | Banxico CoDi — Circular 14/2017 Banxico CoDi | TimeoutException | `throw new TimeoutException("00004");` |
| BR-AM-codi-pay-94 | NEGOCIO | Payments | msapy-d-domain-codi-payment:InterbankCod | 94 | Banxico CoDi — Circular 14/2017 Banxico CoDi | ExecuteSplException | `throw new ExecuteSplException(result.getFirstCode(), apiValues.getNameSpInterban` |
| BR-AM-codi-pay-86 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:IntrabankCod | 86 | Banxico CoDi — Circular 14/2017 Banxico CoDi | TimeoutException | `throw new TimeoutException("00004");` |
| BR-AM-codi-pay-90-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:IntrabankCod | 90 | Banxico CoDi — Circular 14/2017 Banxico CoDi | ExecuteSplException | `throw new ExecuteSplException(result.getFirstCode(), apiValues.getNameSpIntraban` |
| BR-AM-inte-pay-169 | INFRAESTRUCTURA | Payments | msapy-d-domain-interbank-card-payment:Pa | 169 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception);` |
| BR-AM-intr-pay-108 | INFRAESTRUCTURA | Payments | msapy-d-domain-intrabank-card-payment:In | 108 | — | ExecuteSplException | `throw new ExecuteSplException(spResponse, Constants.SQL_INTRABANK_EXCEPTION);` |
| BR-AM-serv-ope-62 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment-transact | 62 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-serv-ope-92 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 92 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-serv-ope-72 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment-transact | 72 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-serv-pay-83 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:Confirma | 83 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-serv-pay-128 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:Confirma | 128 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-serv-pay-136 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:Services | 136 | — | BadRequestException | `throw new BadRequestException(ServicePaymentsConstants.PAYMENT_TYPE_NOT_VALIDATE` |
| BR-AM-serv-pay-164-1 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:Services | 164 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-serv-pay-198 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:Services | 198 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-serv-pay-230 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:Services | 230 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-serv-pay-263 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:Services | 263 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-serv-pay-297 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:Services | 297 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-serv-pay-341 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:Services | 341 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-dire-man-148 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-process-ma | 148 | — | TimeoutException | `throw new TimeoutException(LogConstants.LOG_TIMEMOUT_MESSAGE);` |
| BR-AM-dire-man-126 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-process-ma | 126 | — | BadRequestException | `throw new BadRequestException(stringLog,` |
| BR-AM-dire-man-229 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 229 | — | BadRequestException | `throw new BadRequestException(Constants.AMOUNT_ERROR_MESSAGE,` |
| BR-AM-dire-man-457 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-process-ma | 457 | — | BadRequestException | `throw new BadRequestException(stringLog,` |
| BR-AM-dire-man-343 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 343 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_MAX_CANCEL_DETAIL, badFields);` |
| BR-AM-dire-man-471 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 471 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_DIRECT_DEBIT_PAYMENT_TYPE,` |
| BR-AM-dire-man-94 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-process-ma | 94 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_DIRECT_DEBIT_PAYMENT_TYPE,` |
| BR-AM-dire-man-95 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-process-ma | 95 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_DIRECT_DEBIT_PAYMENT_TYPE,` |
| BR-AM-dire-man-184 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-process-ma | 184 | — | BadRequestException | `throw new BadRequestException(strBuilder.toString(),` |
| BR-AM-dire-man-275 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-process-ma | 275 | — | BadRequestException | `throw new BadRequestException(strBuilder.toString(),` |
| BR-AM-dire-man-297 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-process-ma | 297 | — | BadRequestException | `throw new BadRequestException(strBuilder.toString(),` |
| BR-AM-dire-man-96 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-process-ma | 96 | — | BadRequestException | `throw new BadRequestException(LogConstants.LOG_DIRECT_DEBIT_PAYMENT_TYPE,` |
| BR-AM-dire-que-232 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-query:Dire | 232 | — | EngineTimeoutException | `throw new EngineTimeoutException(LogConstants.LOG_ENGINE_TIMEOUT_MESSAGE);` |
| BR-AM-dire-que-226 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-query:Exte | 226 | — | EngineTimeoutException | `throw new EngineTimeoutException(LogConstants.LOG_ENGINE_TIMEOUT_MESSAGE);` |
| BR-AM-acco-sta-106 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-account-interbank-statu | 106 | — | DataNotFoundException | `throw new DataNotFoundException(errorResolverConstants.getMessageDataNotFoundExc` |
| BR-AM-card-mov-155 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 155 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-card-mov-169 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 169 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-card-mov-187 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 187 | — | BadRequestException | `throw new BadRequestException(Constants.FIELD_EMPTY, badFields);` |
| BR-AM-card-mov-192 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 192 | — | BadRequestException | `throw new BadRequestException(Constants.FIELD_EMPTY, badFields);` |
| BR-AM-card-wit-78 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-cardless-withdrawal:Gen | 78 | — | UnauthorizedException | `throw new UnauthorizedException();` |
| BR-AM-card-wit-118 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-cardless-withdrawal:Req | 118 | — | BadRequestException | `throw new BadRequestException(Constants.OTP_EMPTY, badFields);` |
| BR-AM-card-wit-245 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-cardless-withdrawal:Req | 245 | — | BadRequestException | `throw new BadRequestException(Constants.VALID_CARD_NUMBER, badFields);` |
| BR-AM-card-wit-262 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-cardless-withdrawal:Req | 262 | — | BadRequestException | `throw new BadRequestException(Constants.VALID_ACCOUNT_NUMBER, badFields);` |
| BR-AM-bank-cat-121 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-banks-catalog:BanksBusine | 121 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-bank-cat-159 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-banks-catalog:BanksBusine | 159 | — | BadRequestException | `throw new BadRequestException(ApiConstants.FLAG_REQUEST_ERROR_MESSAGE,` |
| BR-AM-bank-cat-182 | NEGOCIO | Services / ATM | msasr-d-domain-banks-catalog:BanksBusine | 182 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-bank-cat-193 | NEGOCIO | Services / ATM | msasr-d-domain-banks-catalog:BanksBusine | 193 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-bank-cat-231 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-banks-catalog:BanksBusine | 231 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-card-b-86 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-cards-status-options-b:Re | 86 | — | TimeoutException | `throw new TimeoutException("fallo el metodo");` |
| BR-AM-card-b-177 | NEGOCIO | Services / ATM | msasr-d-domain-cards-status-options-b:Up | 177 | — | TimeoutException | `throw new TimeoutException(Constants.FIND_RETRIEVE_STATUS_FALLBACK);` |
| BR-AM-card-b-193 | NEGOCIO | Services / ATM | msasr-d-domain-cards-status-options-b:Up | 193 | — | TimeoutException | `throw new TimeoutException(Constants.FIND_RETRIEVE_STATUS_FALLBACK);` |
| BR-AM-card-b-221 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-cards-status-options-b:Up | 221 | — | TimeoutException | `throw new TimeoutException(Constants.FIND_RETRIEVE_STATUS_FALLBACK);` |
| BR-AM-codi-opt-97 | NEGOCIO | Services / ATM | msasr-d-domain-codi-log-options:CodiLogO | 97 | Banxico CoDi — Circular 14/2017 Banxico CoDi | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cust-act-83 | NEGOCIO | Services / ATM | msasr-d-domain-customer-cards-active:Cus | 83 | — | TimeoutException | `throw new TimeoutException(exception);` |
| BR-AM-cvv-car-105 | NEGOCIO | Services / ATM | msasr-d-domain-cvv-client-cards:CvvClien | 105 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-cvv-reg-85 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-cvv-client-register:Regis | 85 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception);` |
| BR-AM-dire-man-132 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-direct-debit-management:D | 132 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(e.getMessage());` |
| BR-AM-freq-b-125 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 125 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(e.getMessage());` |
| BR-AM-freq-b-157 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 157 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-b-75 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 75 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-b-105 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 105 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-b-129 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 129 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-b-165 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 165 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-acc-136 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 136 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ex);` |
| BR-AM-freq-acc-93 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 93 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ex);` |
| BR-AM-freq-acc-183 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 183 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ex);` |
| BR-AM-freq-acc-201 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 201 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ex);` |
| BR-AM-freq-acc-100 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 100 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-acc-111 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-service-accounts | 111 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-acc-193 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-service-accounts | 193 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-acc-236 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 236 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-acc-254 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 254 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-acc-302 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-service-accounts | 302 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-acc-331 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-service-accounts | 331 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage());` |
| BR-AM-freq-acc-359 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-service-accounts | 359 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(e.getMessage());` |
| BR-AM-freq-acc-108 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-service-accounts | 108 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage(), exception);` |
| BR-AM-freq-acc-132 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-service-accounts | 132 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception.getMessage(), exception);` |
| BR-AM-mess-not-248 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-messaging-notifications:O | 248 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(ex.getMessage());` |
| BR-AM-serv-agr-90 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-agreement:Agreem | 90 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-serv-agr-102 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-agreement:Agreem | 102 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-serv-agr-111 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-agreement:Agreem | 111 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-serv-val-92 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-banking-validati | 92 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-serv-val-123 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-banking-validati | 123 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-serv-val-166 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-banking-validati | 166 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-serv-val-192 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-banking-validati | 192 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-serv-val-97 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-payment-validati | 97 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception);` |
| BR-AM-serv-val-114 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-payment-validati | 114 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception);` |
| BR-AM-serv-ope-86 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-transaction-oper | 86 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-tran-mov-114 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-transaction-operation-mov | 114 | — | TimeoutException | `throw new TimeoutException(ex);` |
| BR-AM-bank-dat-75 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-bank-data:IdentifyBankBusin | 75 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-bank-dat-77 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-bank-data:RetrieveBankBusin | 77 | — | TimeoutException | `throw new TimeoutException();` |
| BR-AM-clie-dat-75 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-client-data:PortabilityAcco | 75 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException(exception);` |
| BR-AM-clie-dat-62 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-client-data:ReviewingAccoun | 62 | — | DatabaseTimeoutException | `throw new DatabaseTimeoutException();` |
| BR-AM-proc-dat-78 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-processing-data:RecoverPort | 78 | — | TimeoutException | `throw new TimeoutException();` |

## UMBRAL (128 reglas)

_Límites operativos — anotaciones `@Min/@Max/@DecimalMin/@Size` en DTOs_

| ID | Clase | Dominio | SP / Clase | Línea | Regulación | Sub-tipo | Código fuente |
|----|-------|---------|------------|-------|------------|----------|---------------|
| BR-AM-codi-dev-prop-29 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-codi-register-device:pr | 29 | Banxico CoDi — Circular 14/2017 Banxico CoDi | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=30000` |
| BR-AM-cred-b-prop-49 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 49 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=300000` |
| BR-AM-cred-mov-prop-24 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 24 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=300000` |
| BR-AM-cred-mov-prop-28 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 28 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=300000` |
| BR-AM-cred-det-60 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 60 | — | MAX | `@Max(ApiConstants.MAX_BALANCE_TYPE) private int balanceType;` |
| BR-AM-cred-det-prop-26 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 26 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds: 50000` |
| BR-AM-cred-b-prop-12 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-d | 12 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds= 300000` |
| BR-AM-freq-acc-58 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 58 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_PAGE_NUMBER_MIN_VALUE) private Integ` |
| BR-AM-freq-acc-64 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 64 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_REGISTER_NUMBER_MIN_VALUE) private I` |
| BR-AM-freq-acc-17 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 17 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_REGISTER_NUMBER_MIN_VALUE) @Positive` |
| BR-AM-freq-acc-23 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 23 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_PAGE_NUMBER_MIN_VALUE) @Positive` |
| BR-AM-freq-acc-61 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 61 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_REGISTER_NUMBER_MIN_VALUE) @Positive` |
| BR-AM-freq-acc-67 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 67 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_PAGE_NUMBER_MIN_VALUE) private Integ` |
| BR-AM-tran-acc-prop-23 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:p | 23 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds = 30000` |
| BR-AM-tran-acc-prop-27 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:p | 27 | — | TIMEOUT_OPERATIVO | `constants.api.timeout.async=10000` |
| BR-AM-capt-val-51 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-captureline-validate:Ca | 51 | — | MIN | `@Min(value = 0L, message = "The value amount be positive") private String amount` |
| BR-AM-codi-b-92 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 92 | Banxico CoDi — Circular 14/2017 Banxico CoDi | SIZE | `@Size(max = ApiValues.LENGHT_REFERENCE, message = ApiValues.VALID_REFERENCE) @No` |
| BR-AM-codi-pay-92 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 92 | Banxico CoDi — Circular 14/2017 Banxico CoDi | SIZE | `@Size(max = ApiValues.LENGHT_REFERENCE, message = ApiValues.VALID_REFERENCE) @No` |
| BR-AM-codi-ope-60 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 60 | Banxico CoDi — Circular 14/2017 Banxico CoDi | MAX | `@Max(7007) private String operationId;` |
| BR-AM-inte-pay-65 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment: | 65 | — | MIN | `@Min(value = 1) private BigDecimal amount;` |
| BR-AM-serv-b-38 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Serv | 38 | — | SIZE | `@Size(min = 10, max = 30, message = Constants.LOG_BADREQUEST_PHONEREFERENCE) @Js` |
| BR-AM-serv-b-22 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Spei | 22 | — | MIN | `@Min(value = 0) private BigDecimal agreementAmount;` |
| BR-AM-serv-b-32 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Spei | 32 | — | MIN | `@Min(value = 0) private BigDecimal customerAmount;` |
| BR-AM-serv-b-37 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Spei | 37 | — | MIN | `@Min(value = 0) private BigDecimal customerTaxAmount;` |
| BR-AM-serv-b-70 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Spei | 70 | — | SIZE | `@Size(min = 3, max = 3, message = Constants.LOG_BADREQUEST_SERVICEID) private St` |
| BR-AM-serv-b-77 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Spei | 77 | — | SIZE | `@Size(min = 10, max = 30, message = Constants.LOG_BADREQUEST_PHONEREFERENCE) @Js` |
| BR-AM-serv-b-24 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 24 | — | SIZE | `@Size(min = 10, max = 30, message = Constants.LOG_BADREQUEST_PHONEREFERENCE) @Js` |
| BR-AM-serv-b-prop-60 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-services-payment-b:prop | 60 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=30000` |
| BR-AM-serv-pay-51 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:SpeiTr | 51 | — | SIZE | `@Size(min = 3, max = 3, message = Constants.LOG_BADREQUEST_SERVICEID) private St` |
| BR-AM-serv-pay-56 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:SpeiTr | 56 | — | SIZE | `@Size(min = 10, max = 30, message = Constants.LOG_BADREQUEST_PHONEREFERENCE) @Js` |
| BR-AM-serv-pay-prop-33 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-services-payment:proper | 33 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=30000` |
| BR-AM-phon-b-60 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-b:Cust | 60 | — | MAX | `@Max(SpecialCharacterConstants.INT_ONE_VALUE) private int register;` |
| BR-AM-phon-enr-45 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment:Custom | 45 | — | MAX | `@Max(SpecialCharacterConstants.INT_ONE_VALUE) private int register;` |
| BR-AM-cred-det-82-1 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 82 | — | MAX | `@Max(ApiConstants.MAX_BALANCE_TYPE) private int balanceType;` |
| BR-AM-cred-det-62-1 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 62 | — | SIZE | `@Size(min = ApiConstants.MIN_CREDIT_NUMBER, max = ApiConstants.MAX_CREDIT_NUMBER` |
| BR-AM-cred-det-prop-110 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-det | 110 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=18000` |
| BR-AM-cred-mov-76 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-mov | 76 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_PAGE_NUMBER_MIN_VALUE) private Integ` |
| BR-AM-cred-mov-83 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-mov | 83 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_REGISTER_NUMBER_MIN_VALUE) @Positive` |
| BR-AM-cust-dat-55 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 55 | — | SIZE | `@Size(max = 40, message = "El nombre de la calle no puede tener más de 40 caráct` |
| BR-AM-cust-dat-63 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 63 | — | SIZE | `@Size(max = 60, message = "El nombre de la colonia no puede tener más de 60 cará` |
| BR-AM-cust-dat-108 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 108 | — | SIZE | `@Size(max = 40, message = "La clave del municipio no puede tener más de 40 carác` |
| BR-AM-cust-dat-117 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 117 | — | SIZE | `@Size(max = 5, message = "La clave de la colonia no puede tener más de 5 carácte` |
| BR-AM-cust-dat-164 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 164 | — | SIZE | `@Size(min = 5, max = 5, message = "El Código Postal solo puede tener 5 carácter"` |
| BR-AM-cust-b-prop-68 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-data-b:propertie | 68 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=30000` |
| BR-AM-cust-dat-prop-45 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-data:properties | 45 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=30000` |
| BR-AM-cust-pro-prop-18 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-products:propert | 18 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=8000` |
| BR-AM-cust-dat-prop-128 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-proposition-data | 128 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=18000` |
| BR-AM-cust-val-44 | NEGOCIO | Customer Management | msacm-o-business-customer-cellphone-vali | 44 | — | MIN | `@Min(value = SpecialCharacterConstants.INT_ONE_VALUE) private Integer cellphoneR` |
| BR-AM-acco-ben-42 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 42 | — | SIZE | `@Size(max = 20, message = "El número de cuenta no puede tener más de 20 carácter` |
| BR-AM-acco-ben-55 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 55 | — | SIZE | `@Size(max = 26, message = "El primer nombre no puede tener más de 26 carácter") ` |
| BR-AM-acco-ben-65-1 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 65 | — | SIZE | `@Size(max = 26, message = "El segundo nombre no puede tener más de 26 carácter")` |
| BR-AM-acco-ben-37 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 37 | — | SIZE | `@Size(max = 40, message = "El nombre de la calle no puede tener más de 40 caráct` |
| BR-AM-acco-ben-47 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 47 | — | SIZE | `@Size(max = 60, message = "El nombre de la colonia no puede tener más de 60 cará` |
| BR-AM-acco-ben-86 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 86 | — | SIZE | `@Size(max = 40, message = "El nombre del municipio no puede tener más de 40 cará` |
| BR-AM-acco-ben-95-1 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 95 | — | SIZE | `@Size(max = 5, message = "La clave de la colonia no puede tener más de 5 carácte` |
| BR-AM-acco-ben-104 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 104 | — | SIZE | `@Size(min = 5, max = 5, message = "El Código Postal solo puede tener 5 carácter"` |
| BR-AM-acco-ben-60 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:R | 60 | — | SIZE | `@Size(max = 20, message = "El número de cuenta no puede tener más de 20 carácter` |
| BR-AM-acco-ben-69 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:R | 69 | — | SIZE | `@Size(max = 20, message = "El número de cliente no puede tener más de 20 carácte` |
| BR-AM-prom-mov-46 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 46 | — | MIN | `@Min(value = SpecialCharacterConstants.INT_ONE_VALUE, message = ApiValues.MSG_ER` |
| BR-AM-leve-acc-73 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 73 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_ONE_VALUE) private Stri` |
| BR-AM-leve-acc-80 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 80 | — | SIZE | `@Size(min = Constants.INT_EIGHTEEN_VALUE, max = Constants.INT_EIGHTEEN_VALUE) pr` |
| BR-AM-leve-acc-87 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 87 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_THREE_VALUE) private St` |
| BR-AM-leve-acc-94 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 94 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_TWO_VALUE) private Stri` |
| BR-AM-leve-acc-101 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 101 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_TWO_VALUE) private Stri` |
| BR-AM-leve-acc-108 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 108 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_FORTY_VALUE) private St` |
| BR-AM-leve-acc-115 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 115 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_SIXTY_VALUE) private St` |
| BR-AM-leve-acc-122 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 122 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_FORTY_VALUE) private St` |
| BR-AM-leve-acc-129 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 129 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_FIVE_VALUE) private Str` |
| BR-AM-leve-acc-135 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 135 | — | SIZE | `@Size(min = Constants.INT_ZERO_VALUE, max = Constants.INT_TEN_VALUE) private Str` |
| BR-AM-leve-acc-141 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 141 | — | SIZE | `@Size(min = Constants.INT_ZERO_VALUE, max = Constants.INT_TEN_VALUE) private Str` |
| BR-AM-leve-acc-148 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 148 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_TEN_VALUE) private Stri` |
| BR-AM-leve-acc-161 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 161 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_FIVE_VALUE) private Str` |
| BR-AM-leve-acc-174 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 174 | — | SIZE | `@Size(min = Constants.INT_ONE_VALUE, max = Constants.INT_ONE_VALUE) private Stri` |
| BR-AM-leve-acc-188 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 188 | — | SIZE | `@Size(min = Constants.INT_TWO_VALUE, max = Constants.INT_TWO_VALUE) private Stri` |
| BR-AM-appl-tra-prop-66 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 66 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=20000` |
| BR-AM-appl-tra-prop-119 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 119 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=20000` |
| BR-AM-depo-b-57-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 57 | — | SIZE | `@Size(max = 20, message = "El número de cuenta no puede tener más de 20 carácter` |
| BR-AM-depo-b-66 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 66 | — | SIZE | `@Size(max = 20, message = "El número de cliente no puede tener más de 20 carácte` |
| BR-AM-depo-mov-52 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 52 | — | MIN | `@Min(value = ApiConstants.ZERO_LONG) private Integer requestedPage;` |
| BR-AM-depo-mov-58 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 58 | — | MIN | `@Min(value = ApiConstants.ONE_LONG) private Integer requestedRecordsNumber;` |
| BR-AM-depo-mov-64 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 64 | — | MIN | `@Min(value = ApiConstants.ONE_LONG) private Integer requestedDays;` |
| BR-AM-depo-mov-prop-28 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 28 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=18000` |
| BR-AM-depo-acc-prop-125 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts:properti | 125 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=18000` |
| BR-AM-inve-ope-prop-131 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-investment-account-openin | 131 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=28000` |
| BR-AM-prom-b-87 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 87 | — | MIN | `@Min(value = SpecialCharacterConstants.INT_ONE_VALUE, message = Constants.MSG_ER` |
| BR-AM-prom-b-74-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 74 | — | MIN | `@Min(value = SpecialCharacterConstants.INT_ONE_VALUE, message = Constants.MSG_ER` |
| BR-AM-prom-b-75 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 75 | — | MAX | `@Max(value = Constants.THIRTY, message = Constants.MSG_ERROR_DAYS_MAX) private I` |
| BR-AM-prom-mov-46-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 46 | — | MIN | `@Min(value = SpecialCharacterConstants.INT_ONE_VALUE, message = ApiValues.MSG_ER` |
| BR-AM-prom-mov-prop-49 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 49 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=1` |
| BR-AM-prom-acc-prop-130 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 130 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=18000` |
| BR-AM-cust-val-prop-146 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 146 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=28000` |
| BR-AM-digi-pro-prop-122 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-digital-loan-provisioning | 122 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=18000` |
| BR-AM-loan-mov-prop-58 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-loans-accounts-movements: | 58 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=30000` |
| BR-AM-codi-pay-prop-105 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:properties | 105 | Banxico CoDi — Circular 14/2017 Banxico CoDi | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=20000` |
| BR-AM-inte-pay-68 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 68 | — | SIZE | `@Size(min = SpecialCharacterConstants.INT_ELEVEN, max = SpecialCharacterConstant` |
| BR-AM-inte-pay-76 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 76 | — | SIZE | `@Size(min = SpecialCharacterConstants.INT_NINE, max = SpecialCharacterConstants.` |
| BR-AM-inte-pay-193 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 193 | — | SIZE | `@Size(min = SpecialCharacterConstants.INT_FIFTEEN, max = SpecialCharacterConstan` |
| BR-AM-intr-pay-106 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 106 | — | MIN | `@Min(value = (long) 1.00) private BigDecimal paymentAmount;` |
| BR-AM-intr-pay-prop-40 | INFRAESTRUCTURA | Payments | msapy-d-domain-intrabank-card-payment:pr | 40 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=180000` |
| BR-AM-serv-ope-prop-145 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment-transact | 145 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=19000` |
| BR-AM-serv-pay-prop-29 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:properti | 29 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=300` |
| BR-AM-card-mov-65 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 65 | — | DECIMALMIN | `@DecimalMin(value = SpecialCharacterConstants.ONE_VALUE_STRING) @DecimalMax(valu` |
| BR-AM-card-mov-66 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 66 | — | DECIMALMAX | `@DecimalMax(value = SpecialCharacterConstants.FOUR_VALUE_STRING) private Integer` |
| BR-AM-card-mov-74 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 74 | — | DECIMALMAX | `@DecimalMax(value = SpecialCharacterConstants.NINETY_VALUE_STRING) private Integ` |
| BR-AM-capt-ope-prop-50 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-captureline-operations:pr | 50 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=20000` |
| BR-AM-card-b-68 | NEGOCIO | Services / ATM | msasr-d-domain-cards-status-options-b:Ca | 68 | — | MIN | `@Min(value = ApiConstants.MIN_CUSTOMER_NUMBER, message = ApiConstants.CUSTOMER_V` |
| BR-AM-codi-opt-prop-116 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-codi-log-options:properti | 116 | Banxico CoDi — Circular 14/2017 Banxico CoDi | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=18000` |
| BR-AM-cvv-car-prop-80 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-cvv-client-cards:properti | 80 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=18000` |
| BR-AM-cvv-reg-56 | NEGOCIO | Services / ATM | msasr-d-domain-cvv-client-register:Regis | 56 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | SIZE | `@Size(min = 9, max = 9) private String customerNumber;` |
| BR-AM-freq-b-67-1 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 67 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_PAGE_NUMBER_MIN_VALUE) private Integ` |
| BR-AM-freq-b-73-1 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 73 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_REGISTER_NUMBER_MIN_VALUE) @Positive` |
| BR-AM-freq-acc-69-2 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 69 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_PAGE_NUMBER_MIN_VALUE) private Integ` |
| BR-AM-freq-acc-75-2 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 75 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_REGISTER_NUMBER_MIN_VALUE) @Positive` |
| BR-AM-freq-acc-prop-120 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-accounts:propert | 120 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=28000` |
| BR-AM-freq-acc-75-3 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 75 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_PAGE_NUMBER_MIN_VALUE) private Integ` |
| BR-AM-freq-acc-81-2 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 81 | — | DECIMALMIN | `@DecimalMin(ApiConstants.REQUEST_VALIDATION_REGISTER_NUMBER_MIN_VALUE) @Positive` |
| BR-AM-freq-acc-prop-10 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-service-accounts | 10 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=300000` |
| BR-AM-serv-val-prop-41 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-banking-validati | 41 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=30000` |
| BR-AM-serv-val-prop-10 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-payment-validati | 10 | — | TIMEOUT_OPERATIVO | `hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=300000` |
| BR-AM-serv-ope-33 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 33 | — | SIZE | `@Size(min = 8, max = 8) private String transactionId;` |
| BR-AM-serv-ope-42-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 42 | — | SIZE | `@Size(min = 9, max = 9) private String customerNumber;` |
| BR-AM-serv-ope-23-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 23 | — | SIZE | `@Size(min = 8, max = 8) private String transactionId;` |
| BR-AM-serv-ope-31-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 31 | — | SIZE | `@Size(min = 9, max = 9) private String customerNumber;` |
| BR-AM-serv-ope-40-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 40 | — | DECIMALMIN | `@DecimalMin(value = "0.0", inclusive = false) @Digits(integer = 6, fraction = 2)` |
| BR-AM-tran-mov-73 | NEGOCIO | Services / ATM | msasr-d-domain-transaction-operation-mov | 73 | — | MIN | `@Min(value = SpecialCharacterConstants.INT_ZERO_VALUE) private Integer requested` |
| BR-AM-tran-mov-80 | NEGOCIO | Services / ATM | msasr-d-domain-transaction-operation-mov | 80 | — | MIN | `@Min(value = SpecialCharacterConstants.INT_ONE_VALUE) private Integer requestedR` |
| BR-AM-tran-mov-87 | NEGOCIO | Services / ATM | msasr-d-domain-transaction-operation-mov | 87 | — | MIN | `@Min(value = Constants.MIN_QUERY_ORDERING, message = Constants.MESSAGE_IVALID_OR` |
| BR-AM-tran-mov-88 | NEGOCIO | Services / ATM | msasr-d-domain-transaction-operation-mov | 88 | — | MAX | `@Max(value = Constants.MAX_QUERY_ORDERING, message = Constants.MESSAGE_IVALID_OR` |

## CÓDIGO_ERROR (8 reglas)

_Catálogo de errores — mapeo excepción → código operativo en properties_

| ID | Clase | Dominio | SP / Clase | Línea | Regulación | Sub-tipo | Código fuente |
|----|-------|---------|------------|-------|------------|----------|---------------|
| BR-AM-tran-b-prop-145 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 145 | — | CÓDIGOS_RETORNO_INFORMIX | `constants.api.codes.sp=00004` |
| BR-AM-tran-b-prop-146 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 146 | — | CÓDIGOS_RETORNO_INFORMIX | `constants.api.codes.sp.third.limit=035` |
| BR-AM-tran-acc-prop-159 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 159 | — | CÓDIGOS_RETORNO_INFORMIX | `constants.api.codes.sp=00004` |
| BR-AM-tran-acc-prop-160 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 160 | — | CÓDIGOS_RETORNO_INFORMIX | `constants.api.codes.sp.third.limit=035` |
| BR-AM-tran-acc-prop-91 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:p | 91 | — | CÓDIGOS_RETORNO_INFORMIX | `constants.api.codes.sp=00004` |
| BR-AM-codi-pay-prop-41 | NEGOCIO | Payments | msapy-d-domain-codi-payment:properties | 41 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CÓDIGOS_RETORNO_INFORMIX | `constants.api.codes.charge.seventeen=999,100,40034,200,375,374,301` |
| BR-AM-codi-pay-prop-42 | NEGOCIO | Payments | msapy-d-domain-codi-payment:properties | 42 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CÓDIGOS_RETORNO_INFORMIX | `constants.api.codes.charge.thirdteen=420,397,371,959,401` |
| BR-AM-card-b-prop-133 | NEGOCIO | Services / ATM | msasr-d-domain-cards-status-options-b:pr | 133 | — | CÓDIGOS_RETORNO_INFORMIX | `constants.api.codes.status.card=BLO,BLT,ACT` |

## CONFIGURACIÓN (406 reglas)

_Parámetros operativos — claves de negocio en `application*.properties`_

| ID | Clase | Dominio | SP / Clase | Línea | Regulación | Sub-tipo | Código fuente |
|----|-------|---------|------------|-------|------------|----------|---------------|
| BR-AM-appl-agr-prop-70 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-agreement:p | 70 | — | PARÁMETRO_OPERATIVO | `validate.headers.validateMessagesVersion=Authorization,deviceId,channel_id,Accep` |
| BR-AM-appl-agr-prop-71 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-agreement:p | 71 | — | PARÁMETRO_OPERATIVO | `validate.headers.generalHeaders=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-appl-agr-prop-73 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-agreement:p | 73 | — | PARÁMETRO_OPERATIVO | `validate.headers.validateMessagesVersion=Authorization,deviceId,channel_id,Accep` |
| BR-AM-appl-agr-prop-73-1 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-agreement:p | 73 | — | PARÁMETRO_OPERATIVO | `validate.headers.validateMessagesVersion=Authorization,deviceId,channel_id,Accep` |
| BR-AM-appl-agr-prop-74 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-agreement:p | 74 | — | PARÁMETRO_OPERATIVO | `validate.headers.generalHeaders=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-appl-agr-prop-74-1 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-agreement:p | 74 | — | PARÁMETRO_OPERATIVO | `validate.headers.generalHeaders=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-appl-agr-prop-94 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-agreement:p | 94 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-appl-agr-prop-94-1 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-agreement:p | 94 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-appl-b-prop-114 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-configurati | 114 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId` |
| BR-AM-appl-b-prop-115 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-configurati | 115 | — | PARÁMETRO_OPERATIVO | `constants.errorResolver.validate.headers=accept,authorization,uuid,type,deviceid` |
| BR-AM-appl-b-prop-120 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-configurati | 120 | — | PARÁMETRO_OPERATIVO | `constants.api.namespace=negocio` |
| BR-AM-appl-con-prop-116 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-configurati | 116 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,XX-Application-Name` |
| BR-AM-appl-con-prop-117 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-configurati | 117 | — | PARÁMETRO_OPERATIVO | `constants.errorResolver.validate.headers=accept,authorization,uuid,type,deviceid` |
| BR-AM-appl-con-prop-122 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-configurati | 122 | — | PARÁMETRO_OPERATIVO | `constants.api.namespace=negocio` |
| BR-AM-appl-b-prop-68 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data-b:prop | 68 | — | PARÁMETRO_OPERATIVO | `validate.headers.validateMessagesVersion=Authorization,deviceId,channel_id,Accep` |
| BR-AM-appl-b-prop-69 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data-b:prop | 69 | — | PARÁMETRO_OPERATIVO | `validate.headers.retrieveSensorialMessages=Authorization,deviceId,channel_id,Acc` |
| BR-AM-appl-b-prop-70 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data-b:prop | 70 | — | PARÁMETRO_OPERATIVO | `validate.headers.generalHeaders=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-appl-b-prop-83 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data-b:prop | 83 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-appl-dat-prop-110 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data:proper | 110 | — | PARÁMETRO_OPERATIVO | `validate.headers.validateMessagesVersion=Authorization,deviceId,channel_id,Accep` |
| BR-AM-appl-dat-prop-111 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data:proper | 111 | — | PARÁMETRO_OPERATIVO | `validate.headers.retrieveSensorialMessages=Authorization,deviceId,channel_id,Acc` |
| BR-AM-appl-dat-prop-112 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data:proper | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers.generalHeaders=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-appl-dat-prop-125 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-application-data:proper | 125 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-codi-ope-prop-131 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-codi-log-operations:pro | 131 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type` |
| BR-AM-codi-dev-prop-93 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-codi-register-device:pr | 93 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,Content-Type` |
| BR-AM-codi-dev-prop-100 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-codi-register-device:pr | 100 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers.register=Accept,Authorization,uuid,deviceId` |
| BR-AM-codi-rep-prop-130 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 130 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId` |
| BR-AM-codi-tra-prop-128 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-codi-transactions:prope | 128 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-copp-inf-prop-158 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-coppel-information:prop | 158 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,channel_id` |
| BR-AM-deli-kit-prop-143 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-delivery-credit-kit:pro | 143 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId` |
| BR-AM-exec-ope-prop-117 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-executive-operations:pr | 117 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-serv-b-prop-136 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-service-payment-validat | 136 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,uuid` |
| BR-AM-serv-b-prop-137 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-service-payment-validat | 137 | — | PARÁMETRO_OPERATIVO | `validate.headers.paymentValidation=Accept,Authorization,uuid` |
| BR-AM-serv-val-prop-118 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-service-payment-validat | 118 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,uuid` |
| BR-AM-serv-val-prop-119 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-service-payment-validat | 119 | — | PARÁMETRO_OPERATIVO | `validate.headers.paymentValidation=Accept,Authorization,uuid` |
| BR-AM-term-cod-prop-89 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-terms-conditions-cvv-co | 89 | Banxico CoDi — Circular 14/2017 Banxico CoDi; PCI-DSS — PCI- | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,deviceId,uuid,Content-Type` |
| BR-AM-toke-ser-prop-159 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-b-business-token-digital-services: | 159 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,Content-Type,XX-Application-` |
| BR-AM-cred-b-prop-109 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 109 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,channel_id,uuid,deviceId,Accept,Content-Type` |
| BR-AM-cred-mov-prop-66 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 66 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,channel_id,uuid,deviceId,Accept,Content-Type` |
| BR-AM-cred-mov-prop-76 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 76 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,channel_id,uuid,deviceId,Accept,Content-Type` |
| BR-AM-cred-b-prop-111 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 111 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cred-b-prop-180 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 180 | — | PARÁMETRO_OPERATIVO | `constants.api.name.detail.account=msacr-d-domain-credit-card-account-detail` |
| BR-AM-cred-det-prop-66 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 66 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cred-b-prop-81 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-b | 81 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,uuid,Accept,deviceId,channel_id` |
| BR-AM-cred-b-prop-81-1 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-d | 81 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cred-det-prop-149 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-d | 149 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cred-acc-prop-74 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts:p | 74 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,uuid,Accept,Content-Type,deviceId,channel_id` |
| BR-AM-depo-b-prop-98 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 98 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,channel_id` |
| BR-AM-depo-mov-prop-87 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 87 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-freq-acc-prop-17 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 17 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id` |
| BR-AM-freq-acc-prop-21 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 21 | — | PARÁMETRO_OPERATIVO | `constants.api.payment-type.transfer=TRANSFER` |
| BR-AM-freq-acc-prop-22 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 22 | — | PARÁMETRO_OPERATIVO | `constants.api.payment-type.transfer.payment-keys=02,03` |
| BR-AM-freq-acc-prop-23 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 23 | — | PARÁMETRO_OPERATIVO | `constants.api.payment-type.credit-card=CREDIT_CARD` |
| BR-AM-freq-acc-prop-24 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 24 | — | PARÁMETRO_OPERATIVO | `constants.api.payment-type.credit-card.payment-keys=05,06` |
| BR-AM-freq-acc-prop-25 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 25 | — | PARÁMETRO_OPERATIVO | `constants.api.payment-type.regex=(${constants.api.payment-type.transfer}&#124;${` |
| BR-AM-freq-acc-prop-137 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 137 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept, Authorization, Content-Type, uuid, deviceId, channel_id` |
| BR-AM-freq-acc-prop-142 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 142 | — | PARÁMETRO_OPERATIVO | `constants.api.payment-type.transfer=TRANSFER` |
| BR-AM-freq-acc-prop-143 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 143 | — | PARÁMETRO_OPERATIVO | `constants.api.payment-type.transfer.payment-keys=02,03` |
| BR-AM-freq-acc-prop-144 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 144 | — | PARÁMETRO_OPERATIVO | `constants.api.payment-type.credit-card=CREDIT_CARD` |
| BR-AM-freq-acc-prop-145 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 145 | — | PARÁMETRO_OPERATIVO | `constants.api.payment-type.credit-card.payment-keys=05,06` |
| BR-AM-freq-acc-prop-146 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 146 | — | PARÁMETRO_OPERATIVO | `constants.api.payment-type.regex=(${constants.api.payment-type.transfer}&#124;${` |
| BR-AM-freq-acc-prop-285 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:prope | 285 | — | PARÁMETRO_OPERATIVO | `constants.api.name=validate` |
| BR-AM-freq-acc-prop-128 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 128 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId` |
| BR-AM-tran-b-prop-160 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 160 | — | PARÁMETRO_OPERATIVO | `validate.headers=Content-Type,Accept,Authorization,uuid,XX-Application-Name,Geol` |
| BR-AM-tran-acc-prop-163 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 163 | — | PARÁMETRO_OPERATIVO | `validate.headers=Content-Type,Accept,Authorization,uuid,XX-Application-Name,Geol` |
| BR-AM-tran-b-prop-142 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 142 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id,XX-A` |
| BR-AM-tran-b-prop-155 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 155 | — | PARÁMETRO_OPERATIVO | `constants.api.paymentType.third=THIRD_TRANS` |
| BR-AM-tran-acc-prop-156 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 156 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id,XX-A` |
| BR-AM-tran-acc-prop-169 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 169 | — | PARÁMETRO_OPERATIVO | `constants.api.paymentType.third=THIRD_TRANS` |
| BR-AM-tran-acc-prop-82 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:p | 82 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,Accept,uuid,Content-Type,deviceId` |
| BR-AM-tran-acc-prop-88 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:p | 88 | — | PARÁMETRO_OPERATIVO | `validate.headers = Authorization,channel_id,Accept,uuid,Content-Type` |
| BR-AM-otp-aut-prop-111 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-d-security-otp-control-authorizati | 111 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cred-b-prop-108 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-credit-cards-accounts-b | 108 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-cred-acc-prop-73 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-credit-cards-accounts:p | 73 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,deviceId,channel_id,Accept,uuid` |
| BR-AM-depo-b-prop-134 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-deposit-accounts-b:prop | 134 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type` |
| BR-AM-depo-acc-prop-133 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-business-deposit-accounts:proper | 133 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,XX-Application-Name,uuid,deviceId` |
| BR-AM-phon-b-prop-133 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-security-phone-validations-b:pro | 133 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization, Accept, deviceId,channel_id` |
| BR-AM-phon-b-prop-134 | NEGOCIO | Canal / Channel Infrastructure | msach-i-security-phone-validations-b:pro | 134 | — | PARÁMETRO_OPERATIVO | `validate.headers.private=Authorization, Accept, deviceId, Content-Type` |
| BR-AM-phon-b-prop-135 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-security-phone-validations-b:pro | 135 | — | PARÁMETRO_OPERATIVO | `validate.headers.public=Authorization, Accept, deviceId, Content-Type,channel_id` |
| BR-AM-phon-b-prop-136 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-security-phone-validations-b:pro | 136 | — | PARÁMETRO_OPERATIVO | `validate.headers.locked=Authorization, Accept, deviceId,channel_id` |
| BR-AM-phon-val-prop-109 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-security-phone-validations:prope | 109 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization, Accept, uuid, deviceId,channel_id` |
| BR-AM-phon-val-prop-110 | NEGOCIO | Canal / Channel Infrastructure | msach-i-security-phone-validations:prope | 110 | — | PARÁMETRO_OPERATIVO | `validate.headers.private=Authorization, Accept, uuid, deviceId, Content-Type` |
| BR-AM-phon-val-prop-111 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-security-phone-validations:prope | 111 | — | PARÁMETRO_OPERATIVO | `validate.headers.public=Authorization, Accept, deviceId, Content-Type,channel_id` |
| BR-AM-phon-val-prop-112 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-i-security-phone-validations:prope | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers.locked=Authorization, Accept, uuid, deviceId,channel_id` |
| BR-AM-capt-val-prop-134 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-captureline-validate:pr | 134 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,deviceId,uuid,Content-Type` |
| BR-AM-card-val-prop-135 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-card-account-validation | 135 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-card-val-prop-121 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-card-direct-debit-valid | 121 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,uuid,deviceId,XX-Application-Name` |
| BR-AM-codi-b-prop-127 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:properti | 127 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-codi-b-prop-144 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:properti | 144 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `constants.api.paymentTransaction=0448` |
| BR-AM-codi-b-prop-152 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:properti | 152 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `constants.api.paymentKey=02` |
| BR-AM-codi-pay-prop-160 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-payment:properties | 160 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,XX-Application-Name` |
| BR-AM-codi-pay-prop-180 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-payment:properties | 180 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `constants.api.paymentTransaction=0448` |
| BR-AM-codi-pay-prop-188 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-payment:properties | 188 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `constants.api.paymentKey=02` |
| BR-AM-codi-ope-prop-111 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 111 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,channel_id,deviceId` |
| BR-AM-codi-rep-prop-169 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-repayment:properti | 169 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,Content-Type` |
| BR-AM-codi-rep-prop-188 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-repayment:properti | 188 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `constants.api.paymentTransaction=0448` |
| BR-AM-codi-rep-prop-196 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-repayment:properti | 196 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `constants.api.paymentKey=02` |
| BR-AM-codi-rep-prop-197 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-codi-repayment:properti | 197 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `constants.api.limit.payment.udis=3000` |
| BR-AM-cred-b-prop-105 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-credit-account-validati | 105 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id` |
| BR-AM-cred-b-prop-113 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-credit-account-validati | 113 | — | PARÁMETRO_OPERATIVO | `constants.api.status.valid=AA,BA,BT,E1,E2,E3` |
| BR-AM-cred-val-prop-73 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-credit-account-validati | 73 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cred-val-prop-86 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-credit-account-validati | 86 | — | PARÁMETRO_OPERATIVO | `constants.api.status.valid=AA,BA,BT` |
| BR-AM-cvv-act-prop-124 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:pro | 124 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,XX-Application-Name,Geolocat` |
| BR-AM-cvv-b-prop-111 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:prop | 111 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,channel_id,deviceId` |
| BR-AM-cvv-b-prop-117 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:prop | 117 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | PARÁMETRO_OPERATIVO | `constants.api.status.card=ACT,BLO,BLT` |
| BR-AM-cvv-b-prop-118 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:prop | 118 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | PARÁMETRO_OPERATIVO | `constants.api.status.card.update=ACT,BLT` |
| BR-AM-cvv-b-prop-188 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:prop | 188 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | PARÁMETRO_OPERATIVO | `constants.api.name.cvvAccountsFeignName=getCvvClientCards` |
| BR-AM-cvv-b-prop-189 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:prop | 189 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | PARÁMETRO_OPERATIVO | `constants.api.name.cvvCardStatusFeignName=putCvvCardStatus` |
| BR-AM-depo-val-prop-13 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-deposit-account-validat | 13 | — | PARÁMETRO_OPERATIVO | `validate.headers=Date,Accept,Accept-Charset,Accept-Encoding,Accept-Language,Auth` |
| BR-AM-depo-val-prop-153 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-deposit-account-validat | 153 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id` |
| BR-AM-inte-b-prop-104 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 104 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,XX-Application-Name,Geol` |
| BR-AM-inte-b-prop-233 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 233 | — | PARÁMETRO_OPERATIVO | `constants.api.paymentKeys=05,06` |
| BR-AM-inte-b-prop-240 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 240 | — | CANAL_VÁLIDO | `constants.api.typeReversion=A` |
| BR-AM-inte-b-prop-250 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 250 | — | PARÁMETRO_OPERATIVO | `constants.api.namespace=Negocio` |
| BR-AM-inte-pay-prop-96 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment: | 96 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-inte-pay-prop-190 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment: | 190 | — | PARÁMETRO_OPERATIVO | `constants.api.paymentKeys=05,06` |
| BR-AM-inte-pay-prop-197 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment: | 197 | — | CANAL_VÁLIDO | `constants.api.typeReversion=A` |
| BR-AM-inte-pay-prop-207 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment: | 207 | — | PARÁMETRO_OPERATIVO | `constants.api.namespace=Negocio` |
| BR-AM-intr-b-prop-70 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 70 | — | PARÁMETRO_OPERATIVO | `constants.api.paymentKey=05` |
| BR-AM-intr-b-prop-76 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 76 | — | PARÁMETRO_OPERATIVO | `constants.api.paymentType.third=PAY_THIRD` |
| BR-AM-intr-b-prop-90 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 90 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id,XX-A` |
| BR-AM-own-pay-prop-38 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-own-card-payment:proper | 38 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id` |
| BR-AM-paym-val-prop-87 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-payment-register-valida | 87 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId` |
| BR-AM-serv-b-prop-294 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-services-payment-b:prop | 294 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,channel_id,uuid,deviceId,Accept,Content-Type` |
| BR-AM-serv-pay-prop-165 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-business-services-payment:proper | 165 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,channel_id,uuid,deviceId,Accept,Content-Type` |
| BR-AM-cell-b-prop-107 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 107 | — | PARÁMETRO_OPERATIVO | `validate.headers.login=Authorization,channel_id,uuid,deviceId,Accept,Content-Typ` |
| BR-AM-cell-b-prop-108 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 108 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,channel_id,uuid,deviceId,Accept,User-Agent` |
| BR-AM-cell-b-prop-109 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 109 | — | PARÁMETRO_OPERATIVO | `validate.headers.close=Authorization,channel_id,uuid,deviceId,Accept,refresh_tok` |
| BR-AM-cell-aut-prop-117 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 117 | — | PARÁMETRO_OPERATIVO | `validate.headers.login=Authorization,channel_id,uuid,deviceId,Accept,Content-Typ` |
| BR-AM-cell-aut-prop-118 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 118 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,channel_id,uuid,deviceId,Accept,User-Agent` |
| BR-AM-cell-aut-prop-119 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 119 | — | PARÁMETRO_OPERATIVO | `validate.headers.close=Authorization,channel_id,uuid,deviceId,Accept,refresh_tok` |
| BR-AM-phon-b-prop-174 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-b:prop | 174 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-phon-b-prop-223 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 223 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId,User` |
| BR-AM-phon-con-prop-258 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 258 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId,User` |
| BR-AM-phon-enr-prop-190 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-o-security-phone-enrollment:proper | 190 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-appl-b-prop-86 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-p-security-application-validations | 86 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type,deviceId,channel_id` |
| BR-AM-appl-val-prop-84 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-p-security-application-validations | 84 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type,deviceId,channel_id` |
| BR-AM-phon-tok-prop-108 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-p-security-phone-gemalto-token:pro | 108 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-phon-tok-prop-77 | INFRAESTRUCTURA | Canal / Channel Infrastructure | msach-p-security-phone-token:properties | 77 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,deviceId,uuid,Content-Type,User` |
| BR-AM-cred-b-prop-115 | INFRAESTRUCTURA | Credit | msacr-b-business-credit-account-opening- | 115 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,XX-Application-Name` |
| BR-AM-cred-b-prop-125 | INFRAESTRUCTURA | Credit | msacr-b-business-credit-account-opening- | 125 | — | PARÁMETRO_OPERATIVO | `constants.api.paymentFrequency=1` |
| BR-AM-cred-ope-prop-119 | INFRAESTRUCTURA | Credit | msacr-b-business-credit-account-opening: | 119 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,XX-Application-Name` |
| BR-AM-cred-ope-prop-125 | INFRAESTRUCTURA | Credit | msacr-b-business-credit-account-opening: | 125 | — | PARÁMETRO_OPERATIVO | `constants.api.namespace=Negocio` |
| BR-AM-cred-ope-prop-145 | INFRAESTRUCTURA | Credit | msacr-b-business-credit-account-opening: | 145 | — | PARÁMETRO_OPERATIVO | `constants.api.paymentFrequency=1` |
| BR-AM-cred-act-prop-116 | INFRAESTRUCTURA | Credit | msacr-b-business-credit-card-activation: | 116 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,XX-Application-Name` |
| BR-AM-upgr-car-prop-112 | NEGOCIO | Credit | msacr-b-business-upgrade-credit-card:pro | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Accept-Charset,Accept-Encoding,Accept-Language,Authoriza` |
| BR-AM-upgr-car-prop-117 | INFRAESTRUCTURA | Credit | msacr-b-business-upgrade-credit-card:pro | 117 | — | PARÁMETRO_OPERATIVO | `constants.api.nameSpace=Negocio` |
| BR-AM-cred-b-prop-95 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-b:p | 95 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cred-b-prop-133 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-b:p | 133 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://${INFORMIX_HOST}:${INFORMIX_PORT}/bdi` |
| BR-AM-cred-det-prop-88 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-det | 88 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cred-det-prop-99 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-det | 99 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdicred:INFORMIXSE` |
| BR-AM-cred-mov-prop-114 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-mov | 114 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cred-mov-prop-152 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts-mov | 152 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdicred:INFORMIXS` |
| BR-AM-cred-acc-prop-97 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts:pro | 97 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cred-acc-prop-143 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-cards-accounts:pro | 143 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicheq:INFORMIXS` |
| BR-AM-cred-del-prop-120 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-kit-delivery:prope | 120 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,Accept,Content-Type,uuid` |
| BR-AM-cred-del-prop-153 | INFRAESTRUCTURA | Credit | msacr-d-domain-credit-kit-delivery:prope | 153 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/intercard:INFORMI` |
| BR-AM-inte-dat-prop-126 | INFRAESTRUCTURA | Credit | msacr-d-domain-intercard-data:properties | 126 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-inte-dat-prop-191 | INFRAESTRUCTURA | Credit | msacr-d-domain-intercard-data:properties | 191 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdinteg:INFORMIXS` |
| BR-AM-reco-pro-prop-113 | INFRAESTRUCTURA | Credit | msacr-d-domain-record-credit-product:pro | 113 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-reco-pro-prop-131 | INFRAESTRUCTURA | Credit | msacr-d-domain-record-credit-product:pro | 131 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdisac:INFORMIXSER` |
| BR-AM-upda-rec-prop-113 | INFRAESTRUCTURA | Credit | msacr-d-domain-update-credit-record:prop | 113 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-upda-rec-prop-159 | INFRAESTRUCTURA | Credit | msacr-d-domain-update-credit-record:prop | 159 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdinteg:INFORMIXS` |
| BR-AM-upgr-dat-prop-120 | INFRAESTRUCTURA | Credit | msacr-d-domain-upgrade-credit-data:prope | 120 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-upgr-dat-prop-139 | INFRAESTRUCTURA | Credit | msacr-d-domain-upgrade-credit-data:prope | 139 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdisac:INFORMIXSE` |
| BR-AM-card-val-prop-124 | INFRAESTRUCTURA | Credit | msacr-d-security-card-data-validation:pr | 124 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,channel_id,uuid,deviceId` |
| BR-AM-msac-con-prop-125 | INFRAESTRUCTURA | Cross-domain | msacsm-b-business-application-account-co | 125 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-msac-con-prop-126 | INFRAESTRUCTURA | Cross-domain | msacsm-b-business-application-account-co | 126 | — | PARÁMETRO_OPERATIVO | `constants.errorResolver.validate.headers=accept,authorization,uuid,type,deviceid` |
| BR-AM-msac-con-prop-133 | INFRAESTRUCTURA | Cross-domain | msacsm-b-business-application-account-co | 133 | — | PARÁMETRO_OPERATIVO | `constants.api.namespace=negocio` |
| BR-AM-amor-inf-prop-118 | INFRAESTRUCTURA | Cross-domain | msaxd-b-business-amortization-informatio | 118 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cred-dat-prop-111 | INFRAESTRUCTURA | Cross-domain | msaxd-b-business-credit-agreement-data:p | 111 | — | PARÁMETRO_OPERATIVO | `validate.headers = Accept,Authorization,uuid,deviceId` |
| BR-AM-amor-inf-prop-148 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-amortization-information: | 148 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-amor-inf-prop-183 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-amortization-information: | 183 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.27.22.176:1770/bdicred:INFORMIXSER` |
| BR-AM-amor-inf-prop-188 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 188 | — | SP_REFERENCIA | `constants.api.name.sp.pro.pres.cred=bdisolic:sp_proyecta_prestamos` |
| BR-AM-amor-inf-prop-189 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 189 | — | SP_REFERENCIA | `constants.api.name.sp.pro.pres.call={CALL  bdisolic:sp_proyecta_prestamos(?,?,?,` |
| BR-AM-amor-inf-prop-193 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-amortization-information: | 193 | — | SP_REFERENCIA | `constants.api.name.sp.amortization.table.name=bdicred:sp_obtiene_tabla_amortizac` |
| BR-AM-amor-inf-prop-194 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-amortization-information: | 194 | — | SP_REFERENCIA | `constants.api.name.sp.amortization.table.pdn.name=bdicred:sp_obtiene_tabla_amort` |
| BR-AM-amor-inf-prop-195 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-amortization-information: | 195 | — | SP_REFERENCIA | `constants.api.name.sp.amortization.table.call={CALL  bdicred:sp_obtiene_tabla_am` |
| BR-AM-amor-inf-prop-196 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-amortization-information: | 196 | — | SP_REFERENCIA | `constants.api.name.sp.amortization.table.pdn.call={CALL  bdicred:sp_obtiene_tabl` |
| BR-AM-cust-sum-prop-111 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-customer-accounts-summary | 111 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Content-Type,Authorization,uuid` |
| BR-AM-cust-sum-prop-207 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-customer-accounts-summary | 207 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdicred:INFORMIXS` |
| BR-AM-holi-que-prop-114 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-holiday-query:properties | 114 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-holi-que-prop-137 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-holiday-query:properties | 137 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-inte-sta-prop-107 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-interbank-services-status | 107 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-inte-sta-prop-120 | NEGOCIO | Cross-domain | msaxd-d-domain-interbank-services-status | 120 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdispei:INFORMIXS` |
| BR-AM-unus-ope-prop-94 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-unusual-operations:proper | 94 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type` |
| BR-AM-unus-ope-prop-103 | INFRAESTRUCTURA | Cross-domain | msaxd-d-domain-unusual-operations:proper | 103 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-cred-sta-prop-110 | INFRAESTRUCTURA | Customer Management | msacm-b-business-credit-rating-state:pro | 110 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,XX-Application-Name,User-Age` |
| BR-AM-cust-dat-prop-119 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 119 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Accept-Charset,Accept-Encoding,Accept-Language,Authoriza` |
| BR-AM-digi-dat-prop-107 | INFRAESTRUCTURA | Customer Management | msacm-b-business-digital-agreement-servi | 107 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId` |
| BR-AM-digi-dat-prop-269 | INFRAESTRUCTURA | Customer Management | msacm-b-business-digital-agreement-servi | 269 | — | CANAL_VÁLIDO | `constants.api.type=8` |
| BR-AM-digi-dat-prop-270 | INFRAESTRUCTURA | Customer Management | msacm-b-business-digital-agreement-servi | 270 | — | PARÁMETRO_OPERATIVO | `constants.api.statusToken=300` |
| BR-AM-offe-pro-prop-142 | NEGOCIO | Customer Management | msacm-b-business-offer-products:properti | 142 | — | PARÁMETRO_OPERATIVO | `validate.headers=Date,Accept,Accept-Charset,Accept-Encoding,Authorization,Host,c` |
| BR-AM-sms-con-prop-116 | INFRAESTRUCTURA | Customer Management | msacm-b-domain-sms-cellphone-control:pro | 116 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-sms-con-prop-156 | INFRAESTRUCTURA | Customer Management | msacm-b-domain-sms-cellphone-control:pro | 156 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-remi-enr-prop-130 | INFRAESTRUCTURA | Customer Management | msacm-b-security-remittance-enrollment:p | 130 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,XX-Application-Name` |
| BR-AM-biom-val-prop-131 | INFRAESTRUCTURA | Customer Management | msacm-d-business-biometric-identity-vali | 131 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,uuid,deviceId` |
| BR-AM-cust-b-prop-107 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-data-name-b:pr | 107 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,uuid,deviceId` |
| BR-AM-cust-nam-prop-102 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-data-name:prop | 102 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,uuid,deviceId` |
| BR-AM-cust-val-prop-124 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-data-validatio | 124 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,channel_id` |
| BR-AM-cust-val-prop-137 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-data-validatio | 137 | — | PARÁMETRO_OPERATIVO | `constants.api.namespace=negocio` |
| BR-AM-cust-dat-prop-108 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-information-da | 108 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cust-dat-prop-115 | INFRAESTRUCTURA | Customer Management | msacm-d-business-customer-proposition-da | 115 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,uuid,deviceId,channel_id,XX-Application-Name` |
| BR-AM-iden-rec-prop-150 | INFRAESTRUCTURA | Customer Management | msacm-d-business-identity-data-recovery: | 150 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id` |
| BR-AM-iden-val-prop-133 | INFRAESTRUCTURA | Customer Management | msacm-d-business-identity-data-validatio | 133 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-blac-val-prop-163 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-black-lists-validation:pr | 163 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-blac-val-prop-184 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-black-lists-validation:pr | 184 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdiauditor:INFORMI` |
| BR-AM-cust-ope-prop-132 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-cellphone-operat | 132 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cust-ope-prop-186 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-cellphone-operat | 186 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-cust-b-prop-124 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-data-b:propertie | 124 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,Accept,Content-Type,uuid` |
| BR-AM-cust-b-prop-141 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-data-b:propertie | 141 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdinteg:INFORMIXSE` |
| BR-AM-cust-dat-prop-87 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-data:properties | 87 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,Accept,Content-Type,Host,uuid` |
| BR-AM-cust-dat-prop-95 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-data:properties | 95 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdinteg:INFORMIXSE` |
| BR-AM-cust-b-prop-137 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 137 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,uuid,deviceId,User-Agent` |
| BR-AM-cust-b-prop-210 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 210 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30015/bdibpi:INFORMIXSE` |
| BR-AM-cust-sta-prop-112 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cust-sta-prop-132 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 132 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cust-sta-prop-181 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 181 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:h2:mem:testdb;DATABASE_TO_UPPER=false;DB_CLOSE_DELAY=` |
| BR-AM-cust-sta-prop-204 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-enrollment-statu | 204 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdibpi:INFORMIXSER` |
| BR-AM-cust-man-prop-114 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-identification-m | 114 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,uuid,channel_id,authorization,deviceId` |
| BR-AM-cust-man-prop-152 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-identification-m | 152 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:300232/bdinteg:INFORMIX` |
| BR-AM-cust-pro-prop-61 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-products:propert | 61 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,Accept,Content-Type,uuid` |
| BR-AM-cust-pro-prop-64 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-products:propert | 64 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://localhost:12345/bdicheq:INFORMIXSERVE` |
| BR-AM-cust-dat-prop-115-1 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-proposition-data | 115 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-cust-dat-prop-138 | INFRAESTRUCTURA | Customer Management | msacm-d-domain-customer-proposition-data | 138 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdinteg:INFORMIXSE` |
| BR-AM-cust-ver-prop-112 | INFRAESTRUCTURA | Customer Management | msacm-d-platform-customer-enrollment-ver | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cust-ver-prop-150 | INFRAESTRUCTURA | Customer Management | msacm-d-platform-customer-enrollment-ver | 150 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cust-ver-prop-181 | INFRAESTRUCTURA | Customer Management | msacm-d-platform-customer-enrollment-ver | 181 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:h2:mem:testdb;DATABASE_TO_UPPER=false;DB_CLOSE_DELAY=` |
| BR-AM-cust-ver-prop-219 | INFRAESTRUCTURA | Customer Management | msacm-d-platform-customer-enrollment-ver | 219 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:30010/bdicheq:INFORMIXSE` |
| BR-AM-cust-man-prop-65 | INFRAESTRUCTURA | Customer Management | msacm-d-security-customer-access-managme | 65 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id` |
| BR-AM-push-ser-prop-121 | INFRAESTRUCTURA | Customer Management | msacm-d-security-push-notifications-serv | 121 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,XX-Application-Name,Authorization,Content-Type,uuid,devi` |
| BR-AM-phon-otp-prop-157 | INFRAESTRUCTURA | Customer Management | msacm-i-security-phone-otp:properties | 157 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-cust-val-prop-77 | INFRAESTRUCTURA | Customer Management | msacm-o-business-customer-cellphone-vali | 77 | — | CANAL_VÁLIDO | `constants.api.type.otp=REGISTER` |
| BR-AM-sess-man-prop-39 | INFRAESTRUCTURA | Customer Management | msacm-p-security-session-management:prop | 39 | — | PARÁMETRO_OPERATIVO | `constants.api.channel.close.session=BEX` |
| BR-AM-sess-man-prop-90 | INFRAESTRUCTURA | Customer Management | msacm-p-security-session-management:prop | 90 | — | PARÁMETRO_OPERATIVO | `validate.headers=channel_id,Content-Type,deviceId,uuid,Authorization,Accept` |
| BR-AM-acco-ben-prop-136 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:p | 136 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Accept-Charset,Accept-Encoding,Accept-Language,Authoriza` |
| BR-AM-acco-ben-prop-137 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:p | 137 | — | PARÁMETRO_OPERATIVO | `validate.headers.get=Accept,Accept-Charset,Accept-Encoding,Accept-Language,Autho` |
| BR-AM-acco-ben-prop-139 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-account-beneficiaries:p | 139 | — | PARÁMETRO_OPERATIVO | `constants.api.limitReturnBeneficiaries=4` |
| BR-AM-acco-ben-prop-140 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-account-beneficiaries:p | 140 | — | PARÁMETRO_OPERATIVO | `constants.api.limitSendBeneficiaries=4` |
| BR-AM-depo-b-prop-126 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 126 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-depo-det-prop-118 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 118 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-digi-acc-prop-106 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-digital-envelope-accoun | 106 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Geolocation-Latitude,Geolocation-Long` |
| BR-AM-digi-man-prop-161 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 161 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,XX-Application-Name,uuid,Geolocation-Longi` |
| BR-AM-digi-mov-prop-110 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-digital-envelope-moveme | 110 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,Geolocation-Latitude,Geo` |
| BR-AM-digi-tra-prop-108 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-digital-envelope-transa | 108 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,Geolocation-Latitude,Geo` |
| BR-AM-inve-ope-prop-132 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-investment-account-open | 132 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-inve-ope-prop-193 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-investment-account-open | 193 | — | PARÁMETRO_OPERATIVO | `constants.api.payment.reference=DEPOSITO INICIAL` |
| BR-AM-inve-ope-prop-205 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-investment-account-open | 205 | — | PARÁMETRO_OPERATIVO | `constants.api.status.list.account=1,4` |
| BR-AM-inve-acc-prop-115 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-investments-accounts:pr | 115 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId` |
| BR-AM-prom-ope-prop-131 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-promissory-account-open | 131 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,XX-Application-` |
| BR-AM-prom-b-prop-139 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 139 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id` |
| BR-AM-prom-mov-prop-123 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 123 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId` |
| BR-AM-prom-acc-prop-113 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 113 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,channel_id` |
| BR-AM-prom-acc-prop-179 | INFRAESTRUCTURA | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 179 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdinteg:INFORMIXSE` |
| BR-AM-appl-tra-prop-52 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 52 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdispei:INFORMIXSE` |
| BR-AM-appl-tra-prop-149 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 149 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-appl-tra-prop-150 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 150 | Banxico SPEI — Circular 14/2017 Banxico SPEI | SP_REFERENCIA | `constants.api.name.sp.trans.cuentas.spei=bdispei:sp_regordenctecte_bex` |
| BR-AM-appl-tra-prop-151 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 151 | Banxico SPEI — Circular 14/2017 Banxico SPEI | SP_REFERENCIA | `constants.api.name.sp.trans.cuentas.spei.call={call sp_regordenctecte_bex(?, ?, ` |
| BR-AM-appl-tra-prop-57 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 57 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-appl-tra-prop-59 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 59 | — | SP_REFERENCIA | `constants.api.name.sp.trans.cuentas.propias=bdicheq:spsctransctaspropias_bex` |
| BR-AM-appl-tra-prop-60 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 60 | — | SP_REFERENCIA | `constants.api.name.sp.trans.cuentas.propias.call={call spsctransctaspropias_bex(` |
| BR-AM-appl-tra-prop-108 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 108 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdicheq:INFORMIXSE` |
| BR-AM-depo-b-prop-102 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-b:proper | 102 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-depo-b-prop-111 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-b:proper | 111 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdicred:INFORMIXS` |
| BR-AM-depo-ben-prop-109 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 109 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-depo-ben-prop-157 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 157 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://localhost:12345/bdinteg:INFORMIXSERVE` |
| BR-AM-depo-b-prop-111-1 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 111 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-depo-b-prop-114 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 114 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://${INFORMIX_HOST}:${INFORMIX_PORT}/bdi` |
| BR-AM-depo-det-prop-117 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 117 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-depo-det-prop-147 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 147 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://${INFORMIX_HOST}:${INFORMIX_PORT}/bdi` |
| BR-AM-depo-mov-prop-44 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 44 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdicheq:INFORMIXSE` |
| BR-AM-depo-mov-prop-109 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 109 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-depo-acc-prop-98 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts:properti | 98 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-depo-acc-prop-105 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-deposit-accounts:properti | 105 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdicheq:INFORMIXSE` |
| BR-AM-digi-acc-prop-124 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-digital-envelope-accounts | 124 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-digi-acc-prop-177 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-digital-envelope-accounts | 177 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdicred:INFORMIXS` |
| BR-AM-inve-ope-prop-112 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-investment-account-openin | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-inve-ope-prop-139 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-investment-account-openin | 139 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdicheq:INFORMIXSE` |
| BR-AM-inve-acc-prop-110 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-investments-accounts:prop | 110 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-inve-acc-prop-124 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-investments-accounts:prop | 124 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdicred:INFORMIXS` |
| BR-AM-prom-ope-prop-112 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-prom-ope-prop-156 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 156 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdinvers:INFORMIXS` |
| BR-AM-prom-b-prop-74 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 74 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdinteg:INFORMIXS` |
| BR-AM-prom-b-prop-141 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 141 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-prom-mov-prop-58 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 58 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdinteg:INFORMIXSE` |
| BR-AM-prom-mov-prop-134 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 134 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-prom-acc-prop-112 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-prom-acc-prop-138 | INFRAESTRUCTURA | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 138 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://localhost:12345/bdinteg:INFORMIXSERVE` |
| BR-AM-push-man-prop-120 | INFRAESTRUCTURA | Infrastructure Messaging | msaim-p-platform-push-notifications-serv | 120 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,uuid,channel_id` |
| BR-AM-digi-pro-prop-135 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-digital-loan-provisioni | 135 | — | PARÁMETRO_OPERATIVO | `validate.headers=XX-Application-Name,Accept,Authorization,channel_id,uuid,device` |
| BR-AM-digi-pro-prop-148 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-digital-loan-provisioni | 148 | — | PARÁMETRO_OPERATIVO | `constants.api.channels={BEX:23,WEB:03}` |
| BR-AM-pers-b-prop-180 | INFRAESTRUCTURA | Lending / Loans | msalo-b-business-personal-loan-provision | 180 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,deviceId,XX-Application-Name,channel_` |
| BR-AM-pers-b-prop-181 | NEGOCIO | Lending / Loans | msalo-b-business-personal-loan-provision | 181 | — | PARÁMETRO_OPERATIVO | `validate.headers.customerValidationLegacy=Date,Accept,Accept-Charset,Accept-Enco` |
| BR-AM-pers-b-prop-182 | NEGOCIO | Lending / Loans | msalo-b-business-personal-loan-provision | 182 | — | PARÁMETRO_OPERATIVO | `validate.headers.customerValidationV3=Date,Accept,Accept-Charset,Accept-Encoding` |
| BR-AM-pers-b-prop-183 | NEGOCIO | Lending / Loans | msalo-b-business-personal-loan-provision | 183 | — | PARÁMETRO_OPERATIVO | `validate.headers.loanSimulator=Date,Accept,Accept-Charset,Accept-Encoding,Accept` |
| BR-AM-pers-b-prop-184 | NEGOCIO | Lending / Loans | msalo-b-business-personal-loan-provision | 184 | — | PARÁMETRO_OPERATIVO | `validate.headers.approveLoan=Date,Accept,Accept-Charset,Accept-Encoding,Accept-L` |
| BR-AM-sala-con-prop-96 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-confirm: | 96 | — | PARÁMETRO_OPERATIVO | `validate.headers.get=Date,Accept,Accept-Charset,Accept-Encoding,Accept-Language,` |
| BR-AM-sala-con-prop-97 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-confirm: | 97 | — | PARÁMETRO_OPERATIVO | `validate.headers.post=Date,Accept,Accept-Charset,Accept-Encoding,Accept-Language` |
| BR-AM-sala-rec-prop-86 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 86 | — | PARÁMETRO_OPERATIVO | `validate.headers.get=Date,Accept,Accept-Charset,Accept-Encoding,Accept-Language,` |
| BR-AM-sala-rec-prop-87 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 87 | — | PARÁMETRO_OPERATIVO | `validate.headers.post=Date,Accept,Accept-Charset,Accept-Encoding,Accept-Language` |
| BR-AM-cred-det-prop-94 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-credit-loans-accounts-det | 94 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cred-det-prop-106 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-credit-loans-accounts-det | 106 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-cred-acc-prop-138 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-credit-loans-accounts:pro | 138 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cred-acc-prop-164 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-credit-loans-accounts:pro | 164 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.27.22.176:1770/bdicred:INFORMIXSER` |
| BR-AM-cust-val-prop-114 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 114 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cust-val-prop-125 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 125 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdibpi:INFORMIXSER` |
| BR-AM-cust-val-prop-156 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 156 | — | SP_REFERENCIA | `constants.api.name.sp.pro.pres.call={CALL bdicred:informix.sp_evaldispefec_cred(` |
| BR-AM-cust-val-prop-157 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 157 | — | SP_REFERENCIA | `constants.api.name.sp.commission.tdc.call={CALL bdicred:informix.comdistdc(?,?,?` |
| BR-AM-digi-pro-prop-107 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-digital-loan-provisioning | 107 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,Accept,uuid,Content-Type` |
| BR-AM-digi-pro-prop-131 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-digital-loan-provisioning | 131 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdicred:INFORMIXSE` |
| BR-AM-digi-det-prop-15 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-digital-loans-accounts-de | 15 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicheq:INFORMIXS` |
| BR-AM-digi-det-prop-77 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-digital-loans-accounts-de | 77 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-loan-b-prop-109 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-loans-accounts-movements- | 109 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,Accept,uuid,Content-Type` |
| BR-AM-loan-b-prop-148 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-loans-accounts-movements- | 148 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-loan-mov-prop-30 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-loans-accounts-movements: | 30 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdicred:INFORMIXSE` |
| BR-AM-loan-mov-prop-43 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-loans-accounts-movements: | 43 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdicred:INFORMIXSE` |
| BR-AM-loan-mov-prop-57 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-loans-accounts-movements: | 57 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,Accept,uuid,Content-Type` |
| BR-AM-loan-mov-prop-104 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-loans-accounts-movements: | 104 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,Accept,uuid,Content-Type` |
| BR-AM-sala-act-prop-37 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-salary-advance-activation | 37 | — | PARÁMETRO_OPERATIVO | `validate.headers=uuid` |
| BR-AM-sala-act-prop-91 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-salary-advance-activation | 91 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdisolic:INFORMIX` |
| BR-AM-sala-req-prop-127 | INFRAESTRUCTURA | Lending / Loans | msalo-d-domain-salary-advance-request:pr | 127 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdisolic:INFORMIX` |
| BR-AM-sala-min-prop-107 | INFRAESTRUCTURA | Lending / Loans | msalo-p-security-salary-advance-minu:pro | 107 | — | PARÁMETRO_OPERATIVO | `validate.headers=uuid` |
| BR-AM-send-b-prop-112 | INFRAESTRUCTURA | Messaging | msamg-d-business-send-messaging-attachme | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,XX-Application-` |
| BR-AM-send-att-prop-109 | INFRAESTRUCTURA | Messaging | msamg-d-business-send-messaging-attachme | 109 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId` |
| BR-AM-send-log-prop-111 | INFRAESTRUCTURA | Messaging | msamg-p-platform-send-codi-process-log:p | 111 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-remi-pay-prop-132 | INFRAESTRUCTURA | Payments | msapy-b-business-remittance-payment:prop | 132 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,XX-Application-Name,uuid,deviceId,User-Age` |
| BR-AM-codi-pay-prop-40 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:properties | 40 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `constants.api.status.charge=962,100,777,404,200,614,400` |
| BR-AM-codi-pay-prop-44 | NEGOCIO | Payments | msapy-d-domain-codi-payment:properties | 44 | Banxico CoDi — Circular 14/2017 Banxico CoDi | SP_REFERENCIA | `constants.api.name.spinterbank=bdicheq:spsctransctaspropiascodi_bex` |
| BR-AM-codi-pay-prop-86 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:properties | 86 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-codi-pay-prop-87 | NEGOCIO | Payments | msapy-d-domain-codi-payment:properties | 87 | Banxico CoDi — Circular 14/2017 Banxico CoDi | SP_REFERENCIA | `constants.api.name.spcargo=bdicheq:cargo_ref` |
| BR-AM-codi-pay-prop-88 | NEGOCIO | Payments | msapy-d-domain-codi-payment:properties | 88 | Banxico CoDi — Circular 14/2017 Banxico CoDi | SP_REFERENCIA | `constants.api.name.spabono=bdicheq:abono_ref` |
| BR-AM-codi-pay-prop-89 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:properties | 89 | Banxico CoDi — Circular 14/2017 Banxico CoDi | SP_REFERENCIA | `constants.api.name.spMtu=bdicheq:sp_validacionmtu_bpi` |
| BR-AM-codi-pay-prop-90 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:properties | 90 | Banxico CoDi — Circular 14/2017 Banxico CoDi | SP_REFERENCIA | `constants.api.name.spMtuLog=bdicheq:sp_bitacoramtu_bpi` |
| BR-AM-codi-pay-prop-91 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:properties | 91 | Banxico CoDi — Circular 14/2017 Banxico CoDi | SP_REFERENCIA | `constants.api.name.spreversion=bdicheq:reversion` |
| BR-AM-codi-pay-prop-92 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:properties | 92 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CANAL_VÁLIDO | `constants.api.type.reversion=A` |
| BR-AM-codi-pay-prop-93 | NEGOCIO | Payments | msapy-d-domain-codi-payment:properties | 93 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_PAGO | `constants.api.pindbenef=02` |
| BR-AM-codi-pay-prop-94 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:properties | 94 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_PAGO | `constants.api.payment.comission=0` |
| BR-AM-codi-pay-prop-96 | NEGOCIO | Payments | msapy-d-domain-codi-payment:properties | 96 | Banxico CoDi — Circular 14/2017 Banxico CoDi | SP_REFERENCIA | `constants.api.name.spintrabank=bdicheq:spsctransctaspropiascodi_bex` |
| BR-AM-codi-pay-prop-124 | INFRAESTRUCTURA | Payments | msapy-d-domain-codi-payment:properties | 124 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-inte-pay-prop-112 | INFRAESTRUCTURA | Payments | msapy-d-domain-interbank-card-payment:pr | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type` |
| BR-AM-inte-pay-prop-112-1 | INFRAESTRUCTURA | Payments | msapy-d-domain-interbank-card-payment:pr | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type` |
| BR-AM-inte-pay-prop-137 | INFRAESTRUCTURA | Payments | msapy-d-domain-interbank-card-payment:pr | 137 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://localhost:12345/bdibpi:INFORMIXSERVER` |
| BR-AM-inte-pay-prop-137-1 | INFRAESTRUCTURA | Payments | msapy-d-domain-interbank-card-payment:pr | 137 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://localhost:12345/bdibpi:INFORMIXSERVER` |
| BR-AM-intr-pay-prop-128 | INFRAESTRUCTURA | Payments | msapy-d-domain-intrabank-card-payment:pr | 128 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-intr-pay-prop-138 | INFRAESTRUCTURA | Payments | msapy-d-domain-intrabank-card-payment:pr | 138 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdicheq:INFORMIXSE` |
| BR-AM-serv-ope-prop-110 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment-transact | 110 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept, Authorization, Content-Type, uuid` |
| BR-AM-serv-ope-prop-129 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment-transact | 129 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdisac:INFORMIXSER` |
| BR-AM-serv-pay-prop-75 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:properti | 75 | — | PARÁMETRO_OPERATIVO | `validate.headers = Authorization,Accept,Content-Type,uuid` |
| BR-AM-serv-pay-prop-92 | INFRAESTRUCTURA | Payments | msapy-d-domain-services-payment:properti | 92 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:jdbc:informix-sqli://10.26.162.22:11830/bdinteg:INFOR` |
| BR-AM-atm-con-prop-108 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-atm-data-configuration: | 108 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,uuid,deviceId` |
| BR-AM-card-inf-prop-137 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-cardless-withdrawal-inf | 137 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,uuid,deviceId` |
| BR-AM-dire-man-prop-152 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-process-ma | 152 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,XX-Application-Name,Content-Type,uuid,devi` |
| BR-AM-dire-que-prop-157 | INFRAESTRUCTURA | Services / ATM | msasr-b-business-direct-debit-query:prop | 157 | — | PARÁMETRO_OPERATIVO | `validate.headers=Authorization,XX-Application-Name,uuid,deviceId` |
| BR-AM-eval-dat-prop-135 | INFRAESTRUCTURA | Services / ATM | msasr-b-serv-evaluate-portability-data:p | 135 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,uuid,deviceId` |
| BR-AM-acco-sta-prop-142 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-account-interbank-statu | 142 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,channel_id,deviceId` |
| BR-AM-card-mov-prop-119 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 119 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid,deviceId,channel_id` |
| BR-AM-card-wit-prop-161 | INFRAESTRUCTURA | Services / ATM | msasr-d-business-cardless-withdrawal:pro | 161 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId,XX-A` |
| BR-AM-bank-cat-prop-51 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-banks-catalog:properties | 51 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type` |
| BR-AM-bank-cat-prop-140 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-banks-catalog:properties | 140 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-capt-ope-prop-151 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-captureline-operations:pr | 151 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type` |
| BR-AM-capt-ope-prop-157 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-captureline-operations:pr | 157 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdisac:INFORMIXSER` |
| BR-AM-card-b-prop-124 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-cards-status-options-b:pr | 124 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-card-b-prop-161 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-cards-status-options-b:pr | 161 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-codi-opt-prop-106 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-codi-log-options:properti | 106 | Banxico CoDi — Circular 14/2017 Banxico CoDi | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-codi-opt-prop-125 | NEGOCIO | Services / ATM | msasr-d-domain-codi-log-options:properti | 125 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdispei:INFORMIXSE` |
| BR-AM-cust-act-prop-106 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-customer-cards-active:pro | 106 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-cust-act-prop-106-1 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-customer-cards-active:pro | 106 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-cust-act-prop-136 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-customer-cards-active:pro | 136 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://localhost:12345/intercard:INFORMIXSER` |
| BR-AM-cust-act-prop-136-1 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-customer-cards-active:pro | 136 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://localhost:12345/intercard:INFORMIXSER` |
| BR-AM-cvv-car-prop-71 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-cvv-client-cards:properti | 71 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-cvv-car-prop-105 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-cvv-client-cards:properti | 105 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-cvv-reg-prop-126 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-cvv-client-register:prope | 126 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type` |
| BR-AM-cvv-reg-prop-143 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-cvv-client-register:prope | 143 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-dire-man-prop-127 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-direct-debit-management:p | 127 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-dire-man-prop-133 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-direct-debit-management:p | 133 | — | PARÁMETRO_OPERATIVO | `constants.api.namestoredprocedure=sp_registra_crecta_cobroaut` |
| BR-AM-dire-man-prop-153 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-direct-debit-management:p | 153 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdicred:INFORMIXS` |
| BR-AM-freq-b-prop-120 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-accounts-b:prope | 120 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-freq-b-prop-159 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-accounts-b:prope | 159 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdiprog:INFORMIXS` |
| BR-AM-freq-acc-prop-108 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-accounts:propert | 108 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-freq-acc-prop-136 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-accounts:propert | 136 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdiprog:INFORMIXSE` |
| BR-AM-freq-acc-prop-27 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-service-accounts | 27 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdiprog:INFORMIXS` |
| BR-AM-freq-acc-prop-105 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-frequent-service-accounts | 105 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-mess-not-prop-88 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-messaging-notifications:p | 88 | — | PARÁMETRO_OPERATIVO | `validate.headers=Content-Type,Accept,Authorization,uuid` |
| BR-AM-mess-not-prop-97 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-messaging-notifications:p | 97 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://localhost:12345/bdicheq:INFORMIXSERVE` |
| BR-AM-mess-not-prop-129 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-messaging-notifications:p | 129 | — | SP_REFERENCIA | `constants.api.name.sp.event.register={CALL bdimnsj:informix.sp_registra_evento(?` |
| BR-AM-serv-agr-prop-126 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-agreement:proper | 126 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid,Content-Type` |
| BR-AM-serv-agr-prop-135 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-agreement:proper | 135 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdinteg:INFORMIXS` |
| BR-AM-serv-val-prop-71 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-banking-validati | 71 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdicheq:INFORMIXS` |
| BR-AM-serv-val-prop-86 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-banking-validati | 86 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-serv-val-prop-28 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-payment-validati | 28 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30501/bdiprog:INFORMIXS` |
| BR-AM-serv-val-prop-104 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-payment-validati | 104 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-serv-ope-prop-52 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-transaction-oper | 52 | — | CONEXIÓN_BD | `conf-spring.datasource.url=jdbc:informix-sqli://10.27.22.180:1525/bdirst:INFORMI` |
| BR-AM-serv-ope-prop-108 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-transaction-oper | 108 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-serv-ope-prop-146 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-services-transaction-oper | 146 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,Content-Type,uuid` |
| BR-AM-tran-con-prop-112 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-transaction-operation-con | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-tran-con-prop-112-1 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-transaction-operation-con | 112 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,uuid` |
| BR-AM-tran-con-prop-133 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-transaction-operation-con | 133 | — | CONEXIÓN_BD | `conf-spring.datasource.url=jdbc:informix-sqli://10.26.169.37:30015/bdirst:INFORM` |
| BR-AM-tran-con-prop-133-1 | INFRAESTRUCTURA | Services / ATM | msasr-d-domain-transaction-operation-con | 133 | — | CONEXIÓN_BD | `conf-spring.datasource.url=jdbc:informix-sqli://10.26.169.37:30015/bdirst:INFORM` |
| BR-AM-bank-dat-prop-114 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-bank-data:properties | 114 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Content-Type,uuid` |
| BR-AM-bank-dat-prop-148 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-bank-data:properties | 148 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdicheq:INFORMIXS` |
| BR-AM-clie-dat-prop-110 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-client-data:properties | 110 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Authorization,channel_id,Content-Type,uuid,deviceId` |
| BR-AM-clie-dat-prop-116 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-client-data:properties | 116 | — | PARÁMETRO_OPERATIVO | `constants.api.status.rejection=3,4,5,6` |
| BR-AM-clie-dat-prop-117 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-client-data:properties | 117 | — | PARÁMETRO_OPERATIVO | `constants.api.status.dates.params=10000` |
| BR-AM-clie-dat-prop-119 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-client-data:properties | 119 | — | PARÁMETRO_OPERATIVO | `constants.api.statusList=1,4` |
| BR-AM-clie-dat-prop-185 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-client-data:properties | 185 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.26.169.37:21525/bdicheq:INFORMIXSE` |
| BR-AM-proc-dat-prop-114 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-processing-data:properties | 114 | — | PARÁMETRO_OPERATIVO | `validate.headers=Accept,Content-Type,uuid` |
| BR-AM-proc-dat-prop-150 | INFRAESTRUCTURA | Services / ATM | msasr-d-serv-processing-data:properties | 150 | — | CONEXIÓN_BD | `spring.datasource.url=jdbc:informix-sqli://10.28.212.229:30023/bdicheq:INFORMIXS` |

## ANOTACIÓN (1501 reglas)

_Campos obligatorios — `@NotNull/@NotBlank/@NotEmpty` en DTOs financieros_

| ID | Clase | Dominio | SP / Clase | Línea | Regulación | Sub-tipo | Código fuente |
|----|-------|---------|------------|-------|------------|----------|---------------|
| BR-AM-appl-b-48 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-application-configurati | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private List<AccountNumberModel> debitAccountNumbers;` |
| BR-AM-appl-b-54 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-application-configurati | 54 | — | CAMPO_OBLIGATORIO | `@NotNull private List<CardNumberModel> creditCardAccountNumbers;` |
| BR-AM-appl-b-60 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-application-configurati | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private List<LoanNumberModel> loanAccountNumbers;` |
| BR-AM-appl-b-66 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-application-configurati | 66 | — | CAMPO_OBLIGATORIO | `@NotNull private List<InvestmentAccountModel> investmentAccountNumbers;` |
| BR-AM-appl-b-72 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-application-configurati | 72 | — | CAMPO_OBLIGATORIO | `@NotNull private List<PromissoryNotesAccountNumber> promissoryNotesAccountNumber` |
| BR-AM-appl-con-59 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-application-configurati | 59 | — | CAMPO_OBLIGATORIO | `@NotNull private List<AccountNumberModel> debitAccountNumbers;` |
| BR-AM-appl-con-65 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-application-configurati | 65 | — | CAMPO_OBLIGATORIO | `@NotNull private List<CardNumberModel> creditCardAccountNumbers;` |
| BR-AM-appl-con-71 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-application-configurati | 71 | — | CAMPO_OBLIGATORIO | `@NotNull private List<LoanNumberModel> loanAccountNumbers;` |
| BR-AM-appl-con-77 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-application-configurati | 77 | — | CAMPO_OBLIGATORIO | `@NotNull private List<InvestmentAccountModel> investmentAccountNumbers;` |
| BR-AM-appl-con-83 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-application-configurati | 83 | — | CAMPO_OBLIGATORIO | `@NotNull private List<PromissoryNotesAccountNumber> promissoryNotesAccountNumber` |
| BR-AM-codi-dev-39 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-register-device:Co | 39 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-codi-dev-40 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-register-device:Co | 40 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-codi-dev-53 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-register-device:Co | 53 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String version;` |
| BR-AM-codi-dev-54 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-register-device:Co | 54 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String version;` |
| BR-AM-codi-dev-60 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-register-device:Co | 60 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String manufacture;` |
| BR-AM-codi-dev-61 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-register-device:Co | 61 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String manufacture;` |
| BR-AM-codi-dev-67 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-register-device:Co | 67 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String model;` |
| BR-AM-codi-dev-68 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-register-device:Co | 68 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String model;` |
| BR-AM-codi-rep-46 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 46 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-codi-rep-47 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 47 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-codi-rep-78 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 78 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String returnAmount;` |
| BR-AM-codi-rep-79 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 79 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String returnAmount;` |
| BR-AM-codi-rep-109 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 109 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String payerAccount;` |
| BR-AM-codi-rep-110 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 110 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String payerAccount;` |
| BR-AM-codi-rep-123 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 123 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String payerAccountType;` |
| BR-AM-codi-rep-124 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 124 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String payerAccountType;` |
| BR-AM-codi-rep-130 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 130 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String payerAlias;` |
| BR-AM-codi-rep-131 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 131 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String payerAlias;` |
| BR-AM-codi-rep-142 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 142 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String beneficiaryAccount;` |
| BR-AM-codi-rep-143 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 143 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String beneficiaryAccount;` |
| BR-AM-codi-rep-156 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 156 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String beneficiaryAccountType;` |
| BR-AM-codi-rep-157 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 157 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String beneficiaryAccountType;` |
| BR-AM-codi-rep-163 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 163 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String beneficiaryAlias;` |
| BR-AM-codi-rep-164 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 164 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String beneficiaryAlias;` |
| BR-AM-codi-rep-48 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 48 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-codi-rep-49 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 49 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-codi-rep-60 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 60 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String operationType;` |
| BR-AM-codi-rep-61 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transaction-repaym | 61 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String operationType;` |
| BR-AM-codi-tra-43 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 43 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String cellPhoneNumber;` |
| BR-AM-codi-tra-44 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 44 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String cellPhoneNumber;` |
| BR-AM-codi-tra-62 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 62 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String amount;` |
| BR-AM-codi-tra-63 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 63 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String amount;` |
| BR-AM-codi-tra-69 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 69 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String operationDate;` |
| BR-AM-codi-tra-70 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 70 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String operationDate;` |
| BR-AM-codi-tra-76 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 76 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String sellerAccountType;` |
| BR-AM-codi-tra-77 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 77 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String sellerAccountType;` |
| BR-AM-codi-tra-90 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 90 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String movementType;` |
| BR-AM-codi-tra-91 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 91 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String movementType;` |
| BR-AM-codi-tra-103 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 103 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String sellerAlias;` |
| BR-AM-codi-tra-115 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 115 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String sellerAccount;` |
| BR-AM-codi-tra-121 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 121 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String timeStamp;` |
| BR-AM-codi-tra-133 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 133 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String paymentType;` |
| BR-AM-codi-tra-145 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 145 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String messageStatus;` |
| BR-AM-codi-tra-151 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 151 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String messageType;` |
| BR-AM-codi-tra-163 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 163 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String accountType;` |
| BR-AM-codi-tra-169 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 169 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String account;` |
| BR-AM-codi-tra-175 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 175 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String bankSpeiKey;` |
| BR-AM-codi-tra-205 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 205 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String beneficiaryAlias;` |
| BR-AM-codi-tra-211 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 211 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String beneficiaryAccountType;` |
| BR-AM-codi-tra-235 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 235 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String receptionType;` |
| BR-AM-codi-tra-247 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 247 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String requestTimeStamp;` |
| BR-AM-codi-tra-253 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 253 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String processingTimeStamp;` |
| BR-AM-codi-tra-283 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 283 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String buyerAlias;` |
| BR-AM-codi-tra-289 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 289 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String buyerAccountType;` |
| BR-AM-codi-tra-313 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 313 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String operationType;` |
| BR-AM-codi-tra-314 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 314 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String operationType;` |
| BR-AM-codi-tra-42 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 42 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String cellPhoneNumber;` |
| BR-AM-codi-tra-43-1 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 43 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String cellPhoneNumber;` |
| BR-AM-codi-tra-54 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 54 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String type;` |
| BR-AM-codi-tra-60 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 60 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String operationType;` |
| BR-AM-codi-tra-61 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-codi-transactions:CodiT | 61 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String operationType;` |
| BR-AM-deli-kit-23 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-delivery-credit-kit:Dat | 23 | — | CAMPO_OBLIGATORIO | `@NotBlank private String zipCode;` |
| BR-AM-deli-kit-23-1 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-delivery-credit-kit:Pho | 23 | — | CAMPO_OBLIGATORIO | `@NotBlank private String phoneContact;` |
| BR-AM-exec-ope-31 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-executive-operations:Ex | 31 | — | CAMPO_OBLIGATORIO | `@NotNull private String operationId;` |
| BR-AM-exec-ope-32 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-executive-operations:Ex | 32 | — | CAMPO_OBLIGATORIO | `@NotBlank private String operationId;` |
| BR-AM-exec-ope-34 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-executive-operations:Ex | 34 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String executiveData;` |
| BR-AM-term-cod-49 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-terms-conditions-cvv-co | 49 | Banxico CoDi — Circular 14/2017 Banxico CoDi; PCI-DSS — PCI- | CAMPO_OBLIGATORIO | `@NotBlank private String contractType;` |
| BR-AM-toke-ser-55 | NEGOCIO | Canal / Channel Infrastructure | msach-b-business-token-digital-services: | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-addr-cat-48 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-address-data-catalogs:A | 48 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String catalogType;` |
| BR-AM-cred-b-58 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 58 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String creditNumber;` |
| BR-AM-cred-b-59 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 59 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = "No puede estar vacio.") private String creditNumber;` |
| BR-AM-cred-b-60 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 60 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String creditNumber;` |
| BR-AM-cred-b-66 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 66 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private Integer requestedDays;` |
| BR-AM-cred-b-72 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 72 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private Integer requestedPage;` |
| BR-AM-cred-b-78 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 78 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private Integer requestedRecordsNumber;` |
| BR-AM-cred-b-53 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-cred-b-54 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-cred-b-60-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private int requestedDays;` |
| BR-AM-cred-b-66-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 66 | — | CAMPO_OBLIGATORIO | `@NotNull private int requestedPage;` |
| BR-AM-cred-b-72-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 72 | — | CAMPO_OBLIGATORIO | `@NotNull private String requestedRecordsNumber;` |
| BR-AM-cred-b-73 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 73 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String requestedRecordsNumber;` |
| BR-AM-cred-b-53-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-cred-b-54-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-cred-mov-42 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 42 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String creditNumber;` |
| BR-AM-cred-mov-43 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 43 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = "No puede estar vacio.") private String creditNumber;` |
| BR-AM-cred-mov-44 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 44 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String creditNumber;` |
| BR-AM-cred-mov-50 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 50 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private Integer requestedDays;` |
| BR-AM-cred-mov-56 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 56 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private Integer requestedPage;` |
| BR-AM-cred-mov-62 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 62 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private Integer requestedRecordsNumber;` |
| BR-AM-cred-mov-39 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 39 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-cred-mov-40 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 40 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-cred-mov-46 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private int requestedDays;` |
| BR-AM-cred-mov-52 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private int requestedPage;` |
| BR-AM-cred-mov-58 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 58 | — | CAMPO_OBLIGATORIO | `@NotNull private String requestedRecordsNumber;` |
| BR-AM-cred-mov-59 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 59 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String requestedRecordsNumber;` |
| BR-AM-cred-mov-39-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 39 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-cred-mov-40-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-accounts-movemen | 40 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-cred-b-55 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 55 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NO_NULL) private String creditNumber;` |
| BR-AM-cred-b-56 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 56 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.NOT_BLANK) private String creditNumber;` |
| BR-AM-cred-det-39 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 39 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.NO_NULL) private String creditNumber;` |
| BR-AM-cred-det-40 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 40 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiConstants.NOT_BLANK) private String creditNumber;` |
| BR-AM-cred-det-44 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 44 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.NO_NULL) private String creditNumber;` |
| BR-AM-cred-det-45 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 45 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiConstants.NOT_BLANK) private String creditNumber;` |
| BR-AM-cred-det-50 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 50 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.NO_NULL) private String company;` |
| BR-AM-cred-det-51 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiConstants.NOT_BLANK) private String company;` |
| BR-AM-cred-det-58 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-cards-accounts-d | 58 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.NO_NULL) private int balanceType;` |
| BR-AM-cred-b-33 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-d | 33 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-cred-b-34 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-d | 34 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-cred-det-46 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-d | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-cred-det-47 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-credit-loans-accounts-d | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-depo-b-56 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 56 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String ac` |
| BR-AM-depo-b-57 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 57 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiConstants.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String a` |
| BR-AM-depo-b-63 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 63 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.MSG_ERROR_DAYS_NULL) private String requestedDay` |
| BR-AM-depo-b-64 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 64 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiConstants.MSG_ERROR_DAYS_NULL) private String requestedDa` |
| BR-AM-depo-b-70 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 70 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.MSG_ERROR_PAGE_NUMBER_NULL) private Integer requ` |
| BR-AM-depo-b-76 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 76 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.MSG_ERROR_REGISTER_NUMBER_NULL) private Integer ` |
| BR-AM-depo-mov-43 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 43 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String accou` |
| BR-AM-depo-mov-44 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 44 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String acco` |
| BR-AM-depo-mov-50 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 50 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_DAYS_NULL) private String requestedDays;` |
| BR-AM-depo-mov-51 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.MSG_ERROR_DAYS_NULL) private String requestedDays;` |
| BR-AM-depo-mov-57 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 57 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_PAGE_NUMBER_NULL) private Integer request` |
| BR-AM-depo-mov-63 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-deposit-accounts-moveme | 63 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_REGISTER_NUMBER_NULL) private Integer req` |
| BR-AM-freq-acc-45-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:AddFr | 45 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountName;` |
| BR-AM-freq-acc-63 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 63 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-freq-acc-53 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 53 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-freq-acc-51 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank private String paymentType;` |
| BR-AM-freq-acc-45 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-freq-acc-51-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-freq-acc-57 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountKey;` |
| BR-AM-freq-acc-69 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String alias;` |
| BR-AM-freq-acc-75 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 75 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountName;` |
| BR-AM-freq-acc-81 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-accounts:Frequ | 81 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String status;` |
| BR-AM-freq-acc-34 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 34 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-freq-acc-35 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 35 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-freq-acc-38 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 38 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-freq-acc-39 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 39 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-freq-acc-40 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 40 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-freq-acc-56 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountName;` |
| BR-AM-freq-acc-57-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountName;` |
| BR-AM-freq-acc-58-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-frequent-service-accoun | 58 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountName;` |
| BR-AM-tran-b-45 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-tran-b-51 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-tran-b-57 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountKey;` |
| BR-AM-tran-b-69 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String alias;` |
| BR-AM-tran-b-75 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 75 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountName;` |
| BR-AM-tran-b-81 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 81 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String status;` |
| BR-AM-tran-b-58 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 58 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-tran-b-66 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 66 | — | CAMPO_OBLIGATORIO | `@NotBlank private String destinationAccountNumber;` |
| BR-AM-tran-b-95 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 95 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-tran-acc-45 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-tran-acc-51 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-tran-acc-57 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountKey;` |
| BR-AM-tran-acc-69 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String alias;` |
| BR-AM-tran-acc-75 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 75 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountName;` |
| BR-AM-tran-acc-81 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 81 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String status;` |
| BR-AM-tran-acc-45-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-tran-acc-51-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-tran-acc-57-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountKey;` |
| BR-AM-tran-acc-69-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String alias;` |
| BR-AM-tran-acc-75-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 75 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountName;` |
| BR-AM-tran-acc-81-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 81 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String status;` |
| BR-AM-tran-acc-58 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 58 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-tran-acc-66 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 66 | — | CAMPO_OBLIGATORIO | `@NotBlank private String destinationAccountNumber;` |
| BR-AM-tran-acc-95 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 95 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-tran-acc-57-2 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 57 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-tran-acc-65 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 65 | — | CAMPO_OBLIGATORIO | `@NotBlank private String destinationAccountNumber;` |
| BR-AM-tran-acc-93 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-interbank-acco | 93 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-tran-b-45-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-tran-b-51-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-tran-b-57-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountKey;` |
| BR-AM-tran-b-69-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String alias;` |
| BR-AM-tran-b-75-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 75 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountName;` |
| BR-AM-tran-b-81-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 81 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String status;` |
| BR-AM-tran-b-53 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 53 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-tran-b-60 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 60 | — | CAMPO_OBLIGATORIO | `@NotBlank private String destinationAccountNumber;` |
| BR-AM-tran-b-67 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 67 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.ERROR_NULL_PARAMETER) private BigDecimal amount;` |
| BR-AM-tran-b-52 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 52 | — | CAMPO_OBLIGATORIO | `@NotBlank private String invoiceBranch;` |
| BR-AM-tran-acc-53 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 53 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-tran-acc-60 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 60 | — | CAMPO_OBLIGATORIO | `@NotBlank private String destinationAccountNumber;` |
| BR-AM-tran-acc-67 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 67 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.ERROR_NULL_PARAMETER) private BigDecimal amount;` |
| BR-AM-tran-acc-52 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-intrabank-acco | 52 | — | CAMPO_OBLIGATORIO | `@NotBlank private String invoiceBranch;` |
| BR-AM-tran-acc-47 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:E | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String type;` |
| BR-AM-tran-acc-48 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:E | 48 | — | CAMPO_OBLIGATORIO | `@NotBlank private String type;` |
| BR-AM-tran-acc-54 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:E | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String code;` |
| BR-AM-tran-acc-55 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:E | 55 | — | CAMPO_OBLIGATORIO | `@NotBlank private String code;` |
| BR-AM-tran-acc-76 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:E | 76 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String uuid;` |
| BR-AM-tran-acc-77 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:E | 77 | — | CAMPO_OBLIGATORIO | `@NotBlank private String uuid;` |
| BR-AM-tran-acc-46 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:I | 46 | — | CAMPO_OBLIGATORIO | `@NotBlank private String invoiceBranch;` |
| BR-AM-tran-acc-47-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:I | 47 | — | CAMPO_OBLIGATORIO | `@NotNull private String invoiceBranch;` |
| BR-AM-tran-acc-55-1 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:O | 55 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-tran-acc-56 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:O | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private String originAccountNumber;` |
| BR-AM-tran-acc-62 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:O | 62 | — | CAMPO_OBLIGATORIO | `@NotBlank private String destinationAccountNumber;` |
| BR-AM-tran-acc-63 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:O | 63 | — | CAMPO_OBLIGATORIO | `@NotNull private String destinationAccountNumber;` |
| BR-AM-tran-acc-69-2 | NEGOCIO | Canal / Channel Infrastructure | msach-d-business-transfer-own-accounts:O | 69 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-otp-aut-73 | NEGOCIO | Canal / Channel Infrastructure | msach-d-security-otp-control-authorizati | 73 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String operation;` |
| BR-AM-otp-aut-74 | NEGOCIO | Canal / Channel Infrastructure | msach-d-security-otp-control-authorizati | 74 | — | CAMPO_OBLIGATORIO | `@NotNull private String operation;` |
| BR-AM-cred-b-43 | NEGOCIO | Canal / Channel Infrastructure | msach-i-business-credit-cards-accounts-b | 43 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-cred-b-49 | NEGOCIO | Canal / Channel Infrastructure | msach-i-business-credit-cards-accounts-b | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String branch;` |
| BR-AM-cred-b-55-1 | NEGOCIO | Canal / Channel Infrastructure | msach-i-business-credit-cards-accounts-b | 55 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-cred-b-61 | NEGOCIO | Canal / Channel Infrastructure | msach-i-business-credit-cards-accounts-b | 61 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-phon-b-48 | NEGOCIO | Canal / Channel Infrastructure | msach-i-security-phone-validations-b:Enr | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-phon-b-49 | NEGOCIO | Canal / Channel Infrastructure | msach-i-security-phone-validations-b:Enr | 49 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-phon-b-48-1 | NEGOCIO | Canal / Channel Infrastructure | msach-i-security-phone-validations-b:Pho | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerId;` |
| BR-AM-phon-b-49-1 | NEGOCIO | Canal / Channel Infrastructure | msach-i-security-phone-validations-b:Pho | 49 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerId;` |
| BR-AM-phon-b-57 | NEGOCIO | Canal / Channel Infrastructure | msach-i-security-phone-validations-b:Sec | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private List<RiskAssessment> trusteerData;` |
| BR-AM-phon-val-32 | NEGOCIO | Canal / Channel Infrastructure | msach-i-security-phone-validations:Enrol | 32 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-phon-val-33 | NEGOCIO | Canal / Channel Infrastructure | msach-i-security-phone-validations:Enrol | 33 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-phon-val-30 | NEGOCIO | Canal / Channel Infrastructure | msach-i-security-phone-validations:Phone | 30 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerId;` |
| BR-AM-capt-val-50 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-captureline-validate:Ca | 50 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String amount;` |
| BR-AM-capt-val-54 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-captureline-validate:Re | 54 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-card-val-51 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-card-account-validation | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-card-val-57 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-card-account-validation | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationCardNumber;` |
| BR-AM-card-val-51-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-card-direct-debit-valid | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumber;` |
| BR-AM-codi-b-22 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:Accounts | 22 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal accumulatedAmount;` |
| BR-AM-codi-b-52 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 52 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String originAccountNumber;` |
| BR-AM-codi-b-53 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 53 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String originAccountNumber;` |
| BR-AM-codi-b-59 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 59 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String destinationAccountNumber;` |
| BR-AM-codi-b-60-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 60 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String destinationAccountNumber` |
| BR-AM-codi-b-65 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 65 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private BigDecimal amount;` |
| BR-AM-codi-b-99 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 99 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String speiKey;` |
| BR-AM-codi-b-100 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 100 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String speiKey;` |
| BR-AM-codi-b-106 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 106 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String paymentType;` |
| BR-AM-codi-b-114 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 114 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String folioIdc;` |
| BR-AM-codi-b-115 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 115 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String folioIdc;` |
| BR-AM-codi-b-121 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 121 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String cellphoneOrigin;` |
| BR-AM-codi-b-122 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 122 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String cellphoneOrigin;` |
| BR-AM-codi-b-128 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 128 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String cellphoneDestiny;` |
| BR-AM-codi-b-129 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:CodiPaym | 129 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String cellphoneDestiny;` |
| BR-AM-codi-b-54 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:DepositA | 54 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal currentBalance;` |
| BR-AM-codi-b-60 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:DepositA | 60 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal retainedBalance;` |
| BR-AM-codi-b-66 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment-b:DepositA | 66 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal frozenBalance;` |
| BR-AM-codi-pay-21 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:AccountsLi | 21 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal accumulatedAmount;` |
| BR-AM-codi-pay-52-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 52 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String originAccountNumber;` |
| BR-AM-codi-pay-53 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 53 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String originAccountNumber;` |
| BR-AM-codi-pay-59 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 59 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String destinationAccountNumber;` |
| BR-AM-codi-pay-60 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 60 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String destinationAccountNumber` |
| BR-AM-codi-pay-65 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 65 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private BigDecimal amount;` |
| BR-AM-codi-pay-99 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 99 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String speiKey;` |
| BR-AM-codi-pay-100 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 100 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String speiKey;` |
| BR-AM-codi-pay-106 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 106 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String paymentType;` |
| BR-AM-codi-pay-114 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 114 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String folioIdc;` |
| BR-AM-codi-pay-115 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:CodiPaymen | 115 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String folioIdc;` |
| BR-AM-codi-pay-52 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:DepositAcc | 52 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal currentBalance;` |
| BR-AM-codi-pay-58 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:DepositAcc | 58 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal retainedBalance;` |
| BR-AM-codi-pay-64 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-payment:DepositAcc | 64 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal frozenBalance;` |
| BR-AM-codi-ope-17 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 17 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank private String alias;` |
| BR-AM-codi-ope-57 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 57 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String operationId;` |
| BR-AM-codi-ope-58 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 58 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String operationId;` |
| BR-AM-codi-ope-84 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 84 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String banxCode;` |
| BR-AM-codi-ope-90 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 90 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String codiAlias;` |
| BR-AM-codi-ope-108 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 108 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String bankingAccount;` |
| BR-AM-codi-ope-114 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 114 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String accountType;` |
| BR-AM-codi-ope-144 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-register-operation | 144 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String verificationStatus;` |
| BR-AM-codi-rep-72 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 72 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private BigDecimal amount;` |
| BR-AM-codi-rep-79-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 79 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private BigDecimal amountRepayment;` |
| BR-AM-codi-rep-93 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 93 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String notificationType;` |
| BR-AM-codi-rep-94 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 94 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String notificationType;` |
| BR-AM-codi-rep-114 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 114 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String destinationAccountNumber;` |
| BR-AM-codi-rep-115 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 115 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String destinationAccountNumber` |
| BR-AM-codi-rep-128 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 128 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String beneficiaryAccountType;` |
| BR-AM-codi-rep-129 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 129 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String beneficiaryAccountType;` |
| BR-AM-codi-rep-142-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 142 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String beneficiaryCellphoneNumber;` |
| BR-AM-codi-rep-143-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 143 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String beneficiaryCellphoneNumb` |
| BR-AM-codi-rep-149 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 149 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String paymentDate;` |
| BR-AM-codi-rep-150 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 150 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String paymentDate;` |
| BR-AM-codi-rep-156-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 156 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String paymentType;` |
| BR-AM-codi-rep-157-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 157 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String paymentType;` |
| BR-AM-codi-rep-163-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 163 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String repaymentDate;` |
| BR-AM-codi-rep-164-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 164 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String repaymentDate;` |
| BR-AM-codi-rep-183 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 183 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.NO_NULL) private String originAccount;` |
| BR-AM-codi-rep-184 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:CodiRepa | 184 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.NOT_BLANK) private String originAccount;` |
| BR-AM-codi-rep-51 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:DepositA | 51 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal currentBalance;` |
| BR-AM-codi-rep-57 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:DepositA | 57 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal retainedBalance;` |
| BR-AM-codi-rep-63 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-codi-repayment:DepositA | 63 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal frozenBalance;` |
| BR-AM-cred-b-38 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-credit-account-validati | 38 | — | CAMPO_OBLIGATORIO | `@NotNull private String destinationCreditCardNumber;` |
| BR-AM-cred-b-39 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-credit-account-validati | 39 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationCreditCardNumber;` |
| BR-AM-cred-val-37 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-credit-account-validati | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private String destinationCreditCardNumber;` |
| BR-AM-cred-val-38 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-credit-account-validati | 38 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationCreditCardNumber;` |
| BR-AM-cvv-act-26 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Mes | 26 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull private String tipoMensaje;` |
| BR-AM-cvv-act-39 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Mes | 39 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull private String cliente;` |
| BR-AM-cvv-act-45 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Mes | 45 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull private String cuenta;` |
| BR-AM-cvv-act-66 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Mes | 66 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull private String fechaHoraRegistro;` |
| BR-AM-cvv-act-72 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Mes | 72 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull private String fechaHoraRecuperado;` |
| BR-AM-cvv-act-78 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Mes | 78 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull private String message1;` |
| BR-AM-cvv-act-143 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Mes | 143 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal importe1;` |
| BR-AM-cvv-act-169 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Mes | 169 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull private String fecha1;` |
| BR-AM-cvv-act-175 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-activate:Mes | 175 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull private String fecha2;` |
| BR-AM-cvv-b-56 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:Card | 56 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_NOT_VALUE) private String cardNumber;` |
| BR-AM-cvv-b-57 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:Card | 57 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_NOT_VALUE) private String cardNumber;` |
| BR-AM-cvv-b-58 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:Card | 58 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String cardNumber;` |
| BR-AM-cvv-b-61 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:Card | 61 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_NOT_VALUE) private String cardStatus;` |
| BR-AM-cvv-b-62 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:Card | 62 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_NOT_VALUE) private String cardStatus;` |
| BR-AM-cvv-b-63 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-cvv-client-cards-b:Card | 63 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String cardStatus;` |
| BR-AM-depo-val-46 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-deposit-account-validat | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-depo-val-52 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-deposit-account-validat | 52 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationAccountNumber;` |
| BR-AM-inte-b-37 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 37 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-inte-b-43 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 43 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-inte-b-49 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountKey;` |
| BR-AM-inte-b-61-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 61 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String alias;` |
| BR-AM-inte-b-67 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 67 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountName;` |
| BR-AM-inte-b-73 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 73 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String status;` |
| BR-AM-inte-b-41 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 41 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-inte-b-46 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationCreditCardNumber;` |
| BR-AM-inte-b-61 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment- | 61 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-inte-pay-43 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment: | 43 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-inte-pay-48 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment: | 48 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationCreditCardNumber;` |
| BR-AM-inte-pay-63 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-interbank-card-payment: | 63 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-intr-b-49 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-intr-b-55 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-intr-b-61 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 61 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountKey;` |
| BR-AM-intr-b-73 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 73 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String alias;` |
| BR-AM-intr-b-79 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 79 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountName;` |
| BR-AM-intr-b-85 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 85 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String status;` |
| BR-AM-intr-b-58 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 58 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String originAccountChecksNumbe` |
| BR-AM-intr-b-59 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 59 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String originAccountChe` |
| BR-AM-intr-b-65 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 65 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String destinationAccountCredit` |
| BR-AM-intr-b-66 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 66 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String destinationAccou` |
| BR-AM-intr-b-71 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 71 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private BigDecimal amount;` |
| BR-AM-intr-b-56 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private String invoiceBranch;` |
| BR-AM-intr-b-57 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String invoiceBranch;` |
| BR-AM-intr-b-58-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment- | 58 | — | CAMPO_OBLIGATORIO | `@NotBlank private String invoiceBranch;` |
| BR-AM-intr-pay-46 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment: | 46 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String originAccountChecksNumbe` |
| BR-AM-intr-pay-47 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment: | 47 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String originAccountChe` |
| BR-AM-intr-pay-53 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment: | 53 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String destinationAccountCredit` |
| BR-AM-intr-pay-54 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment: | 54 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String destinationAccou` |
| BR-AM-intr-pay-59 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment: | 59 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private BigDecimal amount;` |
| BR-AM-intr-pay-44 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment: | 44 | — | CAMPO_OBLIGATORIO | `@NotNull private String invoiceBranch;` |
| BR-AM-intr-pay-45 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment: | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String invoiceBranch;` |
| BR-AM-intr-pay-46-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-intrabank-card-payment: | 46 | — | CAMPO_OBLIGATORIO | `@NotBlank private String invoiceBranch;` |
| BR-AM-own-pay-55 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-own-card-payment:Paymen | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_ORIGIN_NUMBER_MUST_NOT_BE_NULL) private String` |
| BR-AM-own-pay-60 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-own-card-payment:Paymen | 60 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_DETINATION_NUMBER_MUST_NOT_BE_NULL) private St` |
| BR-AM-own-pay-65 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-own-card-payment:Paymen | 65 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private BigDecimal amount;` |
| BR-AM-paym-val-21 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-payment-register-valida | 21 | — | CAMPO_OBLIGATORIO | `@NotBlank private String cellphoneNumber;` |
| BR-AM-paym-val-23 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-payment-register-valida | 23 | — | CAMPO_OBLIGATORIO | `@NotBlank private String contractType;` |
| BR-AM-serv-b-41 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Mess | 41 | — | CAMPO_OBLIGATORIO | `@NotNull private String tipoMensaje;` |
| BR-AM-serv-b-54 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Mess | 54 | — | CAMPO_OBLIGATORIO | `@NotNull private String cliente;` |
| BR-AM-serv-b-60 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Mess | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private String cuenta;` |
| BR-AM-serv-b-81 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Mess | 81 | — | CAMPO_OBLIGATORIO | `@NotNull private String fechaHoraRegistro;` |
| BR-AM-serv-b-87 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Mess | 87 | — | CAMPO_OBLIGATORIO | `@NotNull private String fechaHoraRecuperado;` |
| BR-AM-serv-b-93 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Mess | 93 | — | CAMPO_OBLIGATORIO | `@NotNull private String message1;` |
| BR-AM-serv-b-158 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Mess | 158 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal importe1;` |
| BR-AM-serv-b-184 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Mess | 184 | — | CAMPO_OBLIGATORIO | `@NotNull private String fecha1;` |
| BR-AM-serv-b-190 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Mess | 190 | — | CAMPO_OBLIGATORIO | `@NotNull private String fecha2;` |
| BR-AM-serv-b-44 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Serv | 44 | — | CAMPO_OBLIGATORIO | `@NotNull private String originAccountNumber;` |
| BR-AM-serv-b-45 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Serv | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-serv-b-46 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Serv | 46 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-serv-b-50 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Spei | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-serv-b-61 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Spei | 61 | — | CAMPO_OBLIGATORIO | `@NotNull private String originAccountNumber;` |
| BR-AM-serv-b-62 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Spei | 62 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-serv-b-63-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Spei | 63 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-serv-b-21 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 21 | — | CAMPO_OBLIGATORIO | `@NotNull private String folioSuc;` |
| BR-AM-serv-b-22-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 22 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String folioSuc;` |
| BR-AM-serv-b-23 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 23 | — | CAMPO_OBLIGATORIO | `@NotBlank private String folioSuc;` |
| BR-AM-serv-b-26 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 26 | — | CAMPO_OBLIGATORIO | `@NotNull private String formaPago;` |
| BR-AM-serv-b-27 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 27 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String formaPago;` |
| BR-AM-serv-b-28 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 28 | — | CAMPO_OBLIGATORIO | `@NotBlank private String formaPago;` |
| BR-AM-serv-b-31 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 31 | — | CAMPO_OBLIGATORIO | `@NotNull private String importe;` |
| BR-AM-serv-b-32-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 32 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String importe;` |
| BR-AM-serv-b-33 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 33 | — | CAMPO_OBLIGATORIO | `@NotBlank private String importe;` |
| BR-AM-serv-b-18 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 18 | — | CAMPO_OBLIGATORIO | `@NotNull protected TelmexIntegrationBusRequestCabecera cabecera;` |
| BR-AM-serv-b-28-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 28 | — | CAMPO_OBLIGATORIO | `@NotNull protected String usuario;` |
| BR-AM-serv-b-29 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 29 | — | CAMPO_OBLIGATORIO | `@NotEmpty protected String usuario;` |
| BR-AM-serv-b-30 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 30 | — | CAMPO_OBLIGATORIO | `@NotBlank protected String usuario;` |
| BR-AM-serv-b-33-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 33 | — | CAMPO_OBLIGATORIO | `@NotNull protected String sucursal;` |
| BR-AM-serv-b-34 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 34 | — | CAMPO_OBLIGATORIO | `@NotEmpty protected String sucursal;` |
| BR-AM-serv-b-35 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 35 | — | CAMPO_OBLIGATORIO | `@NotBlank protected String sucursal;` |
| BR-AM-serv-b-38-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 38 | — | CAMPO_OBLIGATORIO | `@NotNull protected String fecha;` |
| BR-AM-serv-b-39 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 39 | — | CAMPO_OBLIGATORIO | `@NotEmpty protected String fecha;` |
| BR-AM-serv-b-40 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 40 | — | CAMPO_OBLIGATORIO | `@NotBlank protected String fecha;` |
| BR-AM-serv-b-43 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 43 | — | CAMPO_OBLIGATORIO | `@NotNull protected String hora;` |
| BR-AM-serv-b-44-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 44 | — | CAMPO_OBLIGATORIO | `@NotEmpty protected String hora;` |
| BR-AM-serv-b-45-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 45 | — | CAMPO_OBLIGATORIO | `@NotBlank protected String hora;` |
| BR-AM-serv-b-32-2 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 32 | — | CAMPO_OBLIGATORIO | `@NotNull private String idTrxGlobal;` |
| BR-AM-serv-b-33-2 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 33 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String idTrxGlobal;` |
| BR-AM-serv-b-34-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 34 | — | CAMPO_OBLIGATORIO | `@NotBlank private String idTrxGlobal;` |
| BR-AM-serv-b-37-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private String sistemaOrigen;` |
| BR-AM-serv-b-38-2 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 38 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String sistemaOrigen;` |
| BR-AM-serv-b-39-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment-b:Telm | 39 | — | CAMPO_OBLIGATORIO | `@NotBlank private String sistemaOrigen;` |
| BR-AM-serv-pay-47 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:Messag | 47 | — | CAMPO_OBLIGATORIO | `@NotNull private String tipoMensaje;` |
| BR-AM-serv-pay-60 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:Messag | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private String cliente;` |
| BR-AM-serv-pay-66 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:Messag | 66 | — | CAMPO_OBLIGATORIO | `@NotNull private String cuenta;` |
| BR-AM-serv-pay-87 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:Messag | 87 | — | CAMPO_OBLIGATORIO | `@NotNull private String fechaHoraRegistro;` |
| BR-AM-serv-pay-93 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:Messag | 93 | — | CAMPO_OBLIGATORIO | `@NotNull private String fechaHoraRecuperado;` |
| BR-AM-serv-pay-99 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:Messag | 99 | — | CAMPO_OBLIGATORIO | `@NotNull private String message1;` |
| BR-AM-serv-pay-164 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:Messag | 164 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal importe1;` |
| BR-AM-serv-pay-190 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:Messag | 190 | — | CAMPO_OBLIGATORIO | `@NotNull private String fecha1;` |
| BR-AM-serv-pay-196 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:Messag | 196 | — | CAMPO_OBLIGATORIO | `@NotNull private String fecha2;` |
| BR-AM-serv-pay-38 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:SpeiTr | 38 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-serv-pay-44 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:SpeiTr | 44 | — | CAMPO_OBLIGATORIO | `@NotNull private String originAccountNumber;` |
| BR-AM-serv-pay-45 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:SpeiTr | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-serv-pay-46 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:SpeiTr | 46 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-serv-pay-54 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:SpeiTr | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String phoneReference;` |
| BR-AM-serv-pay-55 | NEGOCIO | Canal / Channel Infrastructure | msach-o-business-services-payment:SpeiTr | 55 | — | CAMPO_OBLIGATORIO | `@NotBlank private String phoneReference;` |
| BR-AM-cell-b-34 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 34 | — | CAMPO_OBLIGATORIO | `@NotNull private TypeCloseSession type;` |
| BR-AM-cell-b-36 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 36 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerName;` |
| BR-AM-cell-b-47 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerLastName;` |
| BR-AM-cell-b-58 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 58 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthDate;` |
| BR-AM-cell-b-41 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 41 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String password;` |
| BR-AM-cell-b-42 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 42 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = "No puede estar vacio.") private String password;` |
| BR-AM-cell-b-43 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 43 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String password;` |
| BR-AM-cell-b-49 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 49 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String cellphoneNumber;` |
| BR-AM-cell-b-50 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 50 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = "No puede estar vacio.") private String cellphoneNumber;` |
| BR-AM-cell-b-51 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String cellphoneNumber;` |
| BR-AM-cell-aut-53 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private TypeCloseSession type;` |
| BR-AM-cell-aut-62 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 62 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_NULL_MSG) private String password;` |
| BR-AM-cell-aut-63 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 63 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.NOT_EMPTY_MSG) private String password;` |
| BR-AM-cell-aut-64 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 64 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.NOT_BLANK_MSG) private String password;` |
| BR-AM-cell-aut-70 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 70 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_NULL_MSG) private String cellphoneNumber;` |
| BR-AM-cell-aut-71 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 71 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.NOT_EMPTY_MSG) private String cellphoneNumber;` |
| BR-AM-cell-aut-72 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-cellphone-authenticatio | 72 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.NOT_BLANK_MSG) private String cellphoneNumber;` |
| BR-AM-phon-b-62 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-b:Cust | 62 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthday;` |
| BR-AM-phon-b-63 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-b:Cust | 63 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthday;` |
| BR-AM-phon-b-44 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 44 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthday;` |
| BR-AM-phon-b-33 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 33 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphone;` |
| BR-AM-phon-b-40-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 40 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-phon-b-36 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 36 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphone;` |
| BR-AM-phon-b-43 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-phon-b-57-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String osversion;` |
| BR-AM-phon-b-64 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 64 | — | CAMPO_OBLIGATORIO | `@NotNull private String appVersion;` |
| BR-AM-phon-b-71 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 71 | — | CAMPO_OBLIGATORIO | `@NotNull private String phoneModel;` |
| BR-AM-phon-b-78 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 78 | — | CAMPO_OBLIGATORIO | `@NotNull private String nombreApp;` |
| BR-AM-phon-b-85 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 85 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originCall;` |
| BR-AM-phon-b-33-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 33 | — | CAMPO_OBLIGATORIO | `@NotNull private int code;` |
| BR-AM-phon-b-40-2 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 40 | — | CAMPO_OBLIGATORIO | `@NotNull private String result;` |
| BR-AM-phon-b-40 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 40 | — | CAMPO_OBLIGATORIO | `@NotNull private String password;` |
| BR-AM-phon-b-41 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 41 | — | CAMPO_OBLIGATORIO | `@NotBlank private String password;` |
| BR-AM-phon-b-46 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String passwordConfirm;` |
| BR-AM-phon-b-47 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 47 | — | CAMPO_OBLIGATORIO | `@NotBlank private String passwordConfirm;` |
| BR-AM-phon-con-41 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 41 | — | CAMPO_OBLIGATORIO | `@NotNull private String password;` |
| BR-AM-phon-con-42 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 42 | — | CAMPO_OBLIGATORIO | `@NotBlank private String password;` |
| BR-AM-phon-con-48 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String passwordConfirm;` |
| BR-AM-phon-con-49 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 49 | — | CAMPO_OBLIGATORIO | `@NotBlank private String passwordConfirm;` |
| BR-AM-phon-con-42-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 42 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphone;` |
| BR-AM-phon-con-48-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-phon-con-62 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 62 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphone;` |
| BR-AM-phon-con-68 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 68 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-phon-con-80 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 80 | — | CAMPO_OBLIGATORIO | `@NotNull private String osversion;` |
| BR-AM-phon-con-86 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 86 | — | CAMPO_OBLIGATORIO | `@NotNull private String appVersion;` |
| BR-AM-phon-con-93 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 93 | — | CAMPO_OBLIGATORIO | `@NotNull private String phoneModel;` |
| BR-AM-phon-con-100 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 100 | — | CAMPO_OBLIGATORIO | `@NotNull private String nombreApp;` |
| BR-AM-phon-con-106 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 106 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originCall;` |
| BR-AM-phon-con-59-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 59 | — | CAMPO_OBLIGATORIO | `@NotNull private int code;` |
| BR-AM-phon-con-65-1 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 65 | — | CAMPO_OBLIGATORIO | `@NotNull private String result;` |
| BR-AM-phon-con-58 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 58 | — | CAMPO_OBLIGATORIO | `@NotNull private String password;` |
| BR-AM-phon-con-59 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 59 | — | CAMPO_OBLIGATORIO | `@NotBlank private String password;` |
| BR-AM-phon-con-64 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 64 | — | CAMPO_OBLIGATORIO | `@NotNull private String passwordConfirm;` |
| BR-AM-phon-con-65 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment-confir | 65 | — | CAMPO_OBLIGATORIO | `@NotBlank private String passwordConfirm;` |
| BR-AM-phon-enr-47 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment:Custom | 47 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthday;` |
| BR-AM-phon-enr-48 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment:Custom | 48 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthday;` |
| BR-AM-phon-enr-35 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment:Custom | 35 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerName;` |
| BR-AM-phon-enr-46 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment:Custom | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerLastName;` |
| BR-AM-phon-enr-57 | NEGOCIO | Canal / Channel Infrastructure | msach-o-security-phone-enrollment:Custom | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthDate;` |
| BR-AM-appl-b-40 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-application-validations | 40 | — | CAMPO_OBLIGATORIO | `@NotNull private Version version;` |
| BR-AM-appl-b-34 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-application-validations | 34 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String code;` |
| BR-AM-appl-val-40 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-application-validations | 40 | — | CAMPO_OBLIGATORIO | `@NotNull private Version version;` |
| BR-AM-appl-val-34 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-application-validations | 34 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String code;` |
| BR-AM-phon-tok-64 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-gemalto-token:Tok | 64 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.ERROR_NULL_FIELD_MESSAGE) private String custome` |
| BR-AM-phon-tok-70 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-gemalto-token:Tok | 70 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.ERROR_NULL_FIELD_MESSAGE) private String cvvName` |
| BR-AM-phon-tok-71 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-gemalto-token:Tok | 71 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = ApiConstants.ERROR_EMPTY_FIELD_MESSAGE) private String cvvNa` |
| BR-AM-phon-tok-63 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-gemalto-token:Val | 63 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.ERROR_NULL_FIELD_MESSAGE) private String custome` |
| BR-AM-phon-tok-50 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerEnr | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphone;` |
| BR-AM-phon-tok-57 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerEnr | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-phon-tok-50-1 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerSta | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphone;` |
| BR-AM-phon-tok-57-1 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerSta | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-phon-tok-71-1 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerSta | 71 | — | CAMPO_OBLIGATORIO | `@NotNull private String osversion;` |
| BR-AM-phon-tok-78 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerSta | 78 | — | CAMPO_OBLIGATORIO | `@NotNull private String appVersion;` |
| BR-AM-phon-tok-85 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerSta | 85 | — | CAMPO_OBLIGATORIO | `@NotNull private String phoneModel;` |
| BR-AM-phon-tok-92 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerSta | 92 | — | CAMPO_OBLIGATORIO | `@NotNull private String nombreApp;` |
| BR-AM-phon-tok-99 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerSta | 99 | — | CAMPO_OBLIGATORIO | `@NotNull private String originCall;` |
| BR-AM-phon-tok-50-2 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerSta | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private int code;` |
| BR-AM-phon-tok-57-2 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:CustomerSta | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String result;` |
| BR-AM-phon-tok-56 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:PhoneTokenR | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private String cvvName;` |
| BR-AM-phon-tok-57-3 | NEGOCIO | Canal / Channel Infrastructure | msach-p-security-phone-token:PhoneTokenR | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cvvName;` |
| BR-AM-cred-b-35 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 35 | — | CAMPO_OBLIGATORIO | `@NotNull private String associatedAccount;` |
| BR-AM-cred-b-36 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 36 | — | CAMPO_OBLIGATORIO | `@NotBlank private String associatedAccount;` |
| BR-AM-cred-b-37 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-cred-b-38-1 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 38 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-cred-b-34-1 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 34 | — | CAMPO_OBLIGATORIO | `@NotNull private String companyNumber;` |
| BR-AM-cred-b-35-1 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 35 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-cred-b-38-2 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 38 | — | CAMPO_OBLIGATORIO | `@NotNull private String applicationNumber;` |
| BR-AM-cred-b-39-1 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 39 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String applicationNumber;` |
| BR-AM-cred-b-42 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 42 | — | CAMPO_OBLIGATORIO | `@NotNull private String productNumber;` |
| BR-AM-cred-b-43-1 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 43 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-cred-b-46 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String associatedAccount;` |
| BR-AM-cred-b-47 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String associatedAccount;` |
| BR-AM-cred-b-50 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String registrationStatus;` |
| BR-AM-cred-b-51 | NEGOCIO | Credit | msacr-b-business-credit-account-opening- | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String registrationStatus;` |
| BR-AM-cred-ope-45 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 45 | — | CAMPO_OBLIGATORIO | `@NotNull private String associatedAccount;` |
| BR-AM-cred-ope-46 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 46 | — | CAMPO_OBLIGATORIO | `@NotBlank private String associatedAccount;` |
| BR-AM-cred-ope-46-1 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-cred-ope-47 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-cred-ope-44 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 44 | — | CAMPO_OBLIGATORIO | `@NotNull private String companyNumber;` |
| BR-AM-cred-ope-45-1 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-cred-ope-48 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String applicationNumber;` |
| BR-AM-cred-ope-49 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String applicationNumber;` |
| BR-AM-cred-ope-52 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private String productNumber;` |
| BR-AM-cred-ope-53 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 53 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-cred-ope-56 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private String associatedAccount;` |
| BR-AM-cred-ope-57 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String associatedAccount;` |
| BR-AM-cred-ope-60 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private String registrationStatus;` |
| BR-AM-cred-ope-61 | NEGOCIO | Credit | msacr-b-business-credit-account-opening: | 61 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String registrationStatus;` |
| BR-AM-upgr-car-53 | NEGOCIO | Credit | msacr-b-business-upgrade-credit-card:Sta | 53 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String phoneContact;` |
| BR-AM-upgr-car-54 | NEGOCIO | Credit | msacr-b-business-upgrade-credit-card:Sta | 54 | — | CAMPO_OBLIGATORIO | `@NotBlank private String phoneContact;` |
| BR-AM-upgr-car-60 | NEGOCIO | Credit | msacr-b-business-upgrade-credit-card:Sta | 60 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String email;` |
| BR-AM-upgr-car-61 | NEGOCIO | Credit | msacr-b-business-upgrade-credit-card:Sta | 61 | — | CAMPO_OBLIGATORIO | `@NotBlank private String email;` |
| BR-AM-upgr-car-102 | NEGOCIO | Credit | msacr-b-business-upgrade-credit-card:Sta | 102 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String codezip;` |
| BR-AM-upgr-car-103 | NEGOCIO | Credit | msacr-b-business-upgrade-credit-card:Sta | 103 | — | CAMPO_OBLIGATORIO | `@NotBlank private String codezip;` |
| BR-AM-upgr-car-109 | NEGOCIO | Credit | msacr-b-business-upgrade-credit-card:Sta | 109 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String upgradeProduct;` |
| BR-AM-upgr-car-110 | NEGOCIO | Credit | msacr-b-business-upgrade-credit-card:Sta | 110 | — | CAMPO_OBLIGATORIO | `@NotBlank private String upgradeProduct;` |
| BR-AM-cred-b-57 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-b:C | 57 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-cred-det-62 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 62 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.NO_NULL) private String company;` |
| BR-AM-cred-det-63 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 63 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiConstants.NOT_BLANK) private String company;` |
| BR-AM-cred-det-71 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 71 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.NO_NULL) private String creditNumber;` |
| BR-AM-cred-det-72 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 72 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiConstants.NOT_BLANK) private String creditNumber;` |
| BR-AM-cred-det-80-1 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 80 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.NO_NULL) private int balanceType;` |
| BR-AM-cred-det-60-1 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 60 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiConstants.NO_NULL) private String creditNumber;` |
| BR-AM-cred-det-61 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 61 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiConstants.NOT_BLANK) private String creditNumber;` |
| BR-AM-cred-det-56 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-cred-det-62-2 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 62 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-cred-det-68 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 68 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-cred-det-74 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-det | 74 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String serviceType;` |
| BR-AM-cred-mov-61 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-mov | 61 | — | CAMPO_OBLIGATORIO | `@NotBlank private String creditNumber;` |
| BR-AM-cred-mov-68 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-mov | 68 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedDays;` |
| BR-AM-cred-mov-75 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-mov | 75 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedPage;` |
| BR-AM-cred-mov-82 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts-mov | 82 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedRecordsNumber;` |
| BR-AM-cred-acc-51 | NEGOCIO | Credit | msacr-d-domain-credit-cards-accounts:Cre | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-cred-del-11 | NEGOCIO | Credit | msacr-d-domain-credit-kit-delivery:GetSt | 11 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "creditNumber no puede ser vació/nulo.") private String cred` |
| BR-AM-cred-del-13 | NEGOCIO | Credit | msacr-d-domain-credit-kit-delivery:GetSt | 13 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "customerNumber no puede ser vació/nulo.") private String cu` |
| BR-AM-cred-del-15 | NEGOCIO | Credit | msacr-d-domain-credit-kit-delivery:GetSt | 15 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "product no puede ser vació/nulo.") private String product;` |
| BR-AM-cred-del-17 | NEGOCIO | Credit | msacr-d-domain-credit-kit-delivery:GetSt | 17 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "idProduct no puede ser vació/nulo.") private String idProdu` |
| BR-AM-cred-del-30 | NEGOCIO | Credit | msacr-d-domain-credit-kit-delivery:Maqui | 30 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "customerNumber no puede ser vació/nulo.") private String cu` |
| BR-AM-cred-del-30-1 | NEGOCIO | Credit | msacr-d-domain-credit-kit-delivery:Phone | 30 | — | CAMPO_OBLIGATORIO | `@NotBlank( private String phoneContact;` |
| BR-AM-cred-del-47 | NEGOCIO | Credit | msacr-d-domain-credit-kit-delivery:Phone | 47 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingPhoneValidConstants.TYPE_FIELD_NAME + " no puede ser ` |
| BR-AM-cred-del-24 | NEGOCIO | Credit | msacr-d-domain-credit-kit-delivery:Zipco | 24 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "zipCode no puede ser vació/nulo.") private String zipCode;` |
| BR-AM-inte-dat-44 | NEGOCIO | Credit | msacr-d-domain-intercard-data:IntercardD | 44 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_NOT_VALUE) private String customerNumber;` |
| BR-AM-inte-dat-45 | NEGOCIO | Credit | msacr-d-domain-intercard-data:IntercardD | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_NOT_VALUE) private String customerNumber;` |
| BR-AM-inte-dat-46 | NEGOCIO | Credit | msacr-d-domain-intercard-data:IntercardD | 46 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String customerNumber;` |
| BR-AM-inte-dat-52 | NEGOCIO | Credit | msacr-d-domain-intercard-data:IntercardD | 52 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_NOT_VALUE) private List<String> cardStatus;` |
| BR-AM-inte-dat-53 | NEGOCIO | Credit | msacr-d-domain-intercard-data:IntercardD | 53 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private List<String> cardStatus;` |
| BR-AM-reco-pro-34 | NEGOCIO | Credit | msacr-d-domain-record-credit-product:Cre | 34 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingConstants.COMPANY_FIELD_NAME + " no puede ser vació/n` |
| BR-AM-reco-pro-42 | NEGOCIO | Credit | msacr-d-domain-record-credit-product:Cre | 42 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingConstants.PRODUCT_FIELD_NAME +" no puede ser vació/nu` |
| BR-AM-reco-pro-46 | NEGOCIO | Credit | msacr-d-domain-record-credit-product:Cre | 46 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingConstants.CREDIT_NUMBER_FIELD_NAME + " no puede ser v` |
| BR-AM-reco-pro-50 | NEGOCIO | Credit | msacr-d-domain-record-credit-product:Cre | 50 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingConstants.CARD_NUMBER_FIELD_NAME + " no puede ser vac` |
| BR-AM-reco-pro-54 | NEGOCIO | Credit | msacr-d-domain-record-credit-product:Cre | 54 | — | CAMPO_OBLIGATORIO | `@NotBlank( message = MappingConstants.NEW_CARD_NUMBER_FIELD_NAME + " no puede se` |
| BR-AM-upda-rec-35 | NEGOCIO | Credit | msacr-d-domain-update-credit-record:Reco | 35 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingConstants.COMPANY_FIELD_NAME + " no puede ser vació/n` |
| BR-AM-upda-rec-39 | NEGOCIO | Credit | msacr-d-domain-update-credit-record:Reco | 39 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingConstants.CREDIT_NUMBER_FIELD_NAME +" no puede ser va` |
| BR-AM-upda-rec-43 | NEGOCIO | Credit | msacr-d-domain-update-credit-record:Reco | 43 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingConstants.CUSTOMER_NUMBER_FIELD_NAME + " no puede ser` |
| BR-AM-upda-rec-47 | NEGOCIO | Credit | msacr-d-domain-update-credit-record:Reco | 47 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingConstants.CARD_NUMBER_FIELD_NAME +" no puede ser vaci` |
| BR-AM-upda-rec-55 | NEGOCIO | Credit | msacr-d-domain-update-credit-record:Reco | 55 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingConstants.FULL_NAME_FIELD_NAME+ " no puede ser vació/` |
| BR-AM-upda-rec-75 | NEGOCIO | Credit | msacr-d-domain-update-credit-record:Reco | 75 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = " no puede ser vació/nulo.") private String typeProcess;` |
| BR-AM-upda-rec-78 | NEGOCIO | Credit | msacr-d-domain-update-credit-record:Reco | 78 | — | CAMPO_OBLIGATORIO | `@NotNull(message = MappingConstants.FILE_NAME_FIELD_NAME + " no puede ser nulo."` |
| BR-AM-upda-rec-82 | NEGOCIO | Credit | msacr-d-domain-update-credit-record:Reco | 82 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = MappingConstants.PROD_UPGRADE_FIELD_NAME + " no puede ser va` |
| BR-AM-upgr-dat-29 | NEGOCIO | Credit | msacr-d-domain-upgrade-credit-data:DataC | 29 | — | CAMPO_OBLIGATORIO | `@NotBlank private String creditNumber;` |
| BR-AM-upgr-dat-31 | NEGOCIO | Credit | msacr-d-domain-upgrade-credit-data:DataC | 31 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-upgr-dat-33 | NEGOCIO | Credit | msacr-d-domain-upgrade-credit-data:DataC | 33 | — | CAMPO_OBLIGATORIO | `@NotBlank private String prodUpgrade;` |
| BR-AM-upgr-dat-29-1 | NEGOCIO | Credit | msacr-d-domain-upgrade-credit-data:DataC | 29 | — | CAMPO_OBLIGATORIO | `@NotBlank private String cardNumber;` |
| BR-AM-upgr-dat-31-1 | NEGOCIO | Credit | msacr-d-domain-upgrade-credit-data:DataC | 31 | — | CAMPO_OBLIGATORIO | `@NotBlank private String idProduct;` |
| BR-AM-upgr-dat-33-1 | NEGOCIO | Credit | msacr-d-domain-upgrade-credit-data:DataC | 33 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-upgr-dat-35 | NEGOCIO | Credit | msacr-d-domain-upgrade-credit-data:DataC | 35 | — | CAMPO_OBLIGATORIO | `@NotBlank private String creditNumber;` |
| BR-AM-card-val-52 | NEGOCIO | Credit | msacr-d-security-card-data-validation:Ca | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private String cardNumberSuffix;` |
| BR-AM-card-val-53 | NEGOCIO | Credit | msacr-d-security-card-data-validation:Ca | 53 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumberSuffix;` |
| BR-AM-card-val-59 | NEGOCIO | Credit | msacr-d-security-card-data-validation:Ca | 59 | — | CAMPO_OBLIGATORIO | `@NotNull private String cardNumberPin;` |
| BR-AM-card-val-60 | NEGOCIO | Credit | msacr-d-security-card-data-validation:Ca | 60 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumberPin;` |
| BR-AM-card-val-66 | NEGOCIO | Credit | msacr-d-security-card-data-validation:Ca | 66 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-card-val-67 | NEGOCIO | Credit | msacr-d-security-card-data-validation:Ca | 67 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-card-val-52-1 | NEGOCIO | Credit | msacr-d-security-card-data-validation:Ca | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private CardDataValidation cardDataValidation;` |
| BR-AM-msac-con-60 | NEGOCIO | Cross-domain | msacsm-b-business-application-account-co | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private List<AccountNumberModel> debitAccountNumbers;` |
| BR-AM-msac-con-66 | NEGOCIO | Cross-domain | msacsm-b-business-application-account-co | 66 | — | CAMPO_OBLIGATORIO | `@NotNull private List<CardNumberModel> creditCardAccountNumbers;` |
| BR-AM-msac-con-72 | NEGOCIO | Cross-domain | msacsm-b-business-application-account-co | 72 | — | CAMPO_OBLIGATORIO | `@NotNull private List<LoanNumberModel> loanAccountNumbers;` |
| BR-AM-msac-con-78 | NEGOCIO | Cross-domain | msacsm-b-business-application-account-co | 78 | — | CAMPO_OBLIGATORIO | `@NotNull private List<InvestmentAccountModel> investmentAccountNumbers;` |
| BR-AM-msac-con-84 | NEGOCIO | Cross-domain | msacsm-b-business-application-account-co | 84 | — | CAMPO_OBLIGATORIO | `@NotNull private List<PromissoryNotesAccountNumber> promissoryNotesAccountNumber` |
| BR-AM-amor-inf-36 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 36 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-amor-inf-42 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 42 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-amor-inf-35 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 35 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-amor-inf-41 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 41 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer loanPeriod;` |
| BR-AM-amor-inf-53 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 53 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-amor-inf-59 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 59 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String branch;` |
| BR-AM-amor-inf-65 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 65 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String returnType;` |
| BR-AM-amor-inf-71 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 71 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String requests;` |
| BR-AM-amor-inf-77 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 77 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-amor-inf-33 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 33 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-amor-inf-44 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 44 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-amor-inf-19 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 19 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-amor-inf-25 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 25 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-amor-inf-31 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 31 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String branch;` |
| BR-AM-amor-inf-37 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal tableRecordsRequest;` |
| BR-AM-amor-inf-43 | NEGOCIO | Cross-domain | msaxd-b-business-amortization-informatio | 43 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-cred-dat-36 | NEGOCIO | Cross-domain | msaxd-b-business-credit-agreement-data:R | 36 | — | CAMPO_OBLIGATORIO | `@NotNull private List<AgreementData> agreementData;` |
| BR-AM-amor-inf-54 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 54 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-amor-inf-60 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer loanPeriod;` |
| BR-AM-amor-inf-72 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 72 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-amor-inf-78 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 78 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String branch;` |
| BR-AM-amor-inf-84 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 84 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String returnType;` |
| BR-AM-amor-inf-90 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 90 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String requests;` |
| BR-AM-amor-inf-96 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 96 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-amor-inf-55 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-amor-inf-61 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 61 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-amor-inf-67 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 67 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String branch;` |
| BR-AM-amor-inf-73 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 73 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal tableRecordsRequest;` |
| BR-AM-amor-inf-80 | NEGOCIO | Cross-domain | msaxd-d-domain-amortization-information: | 80 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-cust-sum-33 | NEGOCIO | Cross-domain | msaxd-d-domain-customer-accounts-summary | 33 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-cust-sum-34 | NEGOCIO | Cross-domain | msaxd-d-domain-customer-accounts-summary | 34 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-holi-que-53 | NEGOCIO | Cross-domain | msaxd-d-domain-holiday-query:HolidayRequ | 53 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-unus-ope-46 | NEGOCIO | Cross-domain | msaxd-d-domain-unusual-operations:Unusua | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String registrationDate;` |
| BR-AM-unus-ope-52 | NEGOCIO | Cross-domain | msaxd-d-domain-unusual-operations:Unusua | 52 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String operationId;` |
| BR-AM-unus-ope-58 | NEGOCIO | Cross-domain | msaxd-d-domain-unusual-operations:Unusua | 58 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-unus-ope-64 | NEGOCIO | Cross-domain | msaxd-d-domain-unusual-operations:Unusua | 64 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationAccountNumber;` |
| BR-AM-unus-ope-70 | NEGOCIO | Cross-domain | msaxd-d-domain-unusual-operations:Unusua | 70 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String returnError;` |
| BR-AM-unus-ope-76 | NEGOCIO | Cross-domain | msaxd-d-domain-unusual-operations:Unusua | 76 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String errorDescription;` |
| BR-AM-cred-off-19 | NEGOCIO | Cross-domain | msaxd-s-platform-credit-offer:MessagingN | 19 | — | CAMPO_OBLIGATORIO | `@NotNull private String response;` |
| BR-AM-cred-off-20 | NEGOCIO | Cross-domain | msaxd-s-platform-credit-offer:MessagingN | 20 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String response;` |
| BR-AM-cred-off-21 | NEGOCIO | Cross-domain | msaxd-s-platform-credit-offer:MessagingN | 21 | — | CAMPO_OBLIGATORIO | `@NotBlank private String response;` |
| BR-AM-cust-dat-54 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 54 | — | CAMPO_OBLIGATORIO | `@NotBlank private String street;` |
| BR-AM-cust-dat-62 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 62 | — | CAMPO_OBLIGATORIO | `@NotBlank private String neighborhood;` |
| BR-AM-cust-dat-78 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 78 | — | CAMPO_OBLIGATORIO | `@NotBlank private String countryCode;` |
| BR-AM-cust-dat-98 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 98 | — | CAMPO_OBLIGATORIO | `@NotBlank private String cityCode;` |
| BR-AM-cust-dat-107 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 107 | — | CAMPO_OBLIGATORIO | `@NotBlank private String municipalityCode;` |
| BR-AM-cust-dat-115 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 115 | — | CAMPO_OBLIGATORIO | `@NotBlank private String neighborhoodCode;` |
| BR-AM-cust-dat-172 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 172 | — | CAMPO_OBLIGATORIO | `@NotBlank private String numberExtStreet;` |
| BR-AM-cust-dat-200 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 200 | — | CAMPO_OBLIGATORIO | `@NotBlank private String addresType;` |
| BR-AM-cust-dat-51 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-cust-dat-58 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 58 | — | CAMPO_OBLIGATORIO | `@NotBlank private String street;` |
| BR-AM-cust-dat-65 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 65 | — | CAMPO_OBLIGATORIO | `@NotBlank private String neighborhood;` |
| BR-AM-cust-dat-78-1 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 78 | — | CAMPO_OBLIGATORIO | `@NotBlank private String countryCode;` |
| BR-AM-cust-dat-85 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 85 | — | CAMPO_OBLIGATORIO | `@NotBlank private String stateCode;` |
| BR-AM-cust-dat-92 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 92 | — | CAMPO_OBLIGATORIO | `@NotBlank private String cityCode;` |
| BR-AM-cust-dat-99 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 99 | — | CAMPO_OBLIGATORIO | `@NotBlank private String municipalityCode;` |
| BR-AM-cust-dat-106 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 106 | — | CAMPO_OBLIGATORIO | `@NotBlank private String neighborhoodCode;` |
| BR-AM-cust-dat-151 | NEGOCIO | Customer Management | msacm-b-business-customer-personal-data: | 151 | — | CAMPO_OBLIGATORIO | `@NotBlank private String postalCode;` |
| BR-AM-digi-dat-44 | NEGOCIO | Customer Management | msacm-b-business-digital-agreement-servi | 44 | — | CAMPO_OBLIGATORIO | `@NotNull private String digitalSignatureStatus;` |
| BR-AM-digi-dat-45 | NEGOCIO | Customer Management | msacm-b-business-digital-agreement-servi | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String digitalSignatureStatus;` |
| BR-AM-sms-con-48 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Ins | 48 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-sms-con-49 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Ins | 49 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-sms-con-55 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Ins | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-sms-con-56 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Ins | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-sms-con-69 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Ins | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String branch;` |
| BR-AM-sms-con-70 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Ins | 70 | — | CAMPO_OBLIGATORIO | `@NotNull private String branch;` |
| BR-AM-sms-con-46 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Sea | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-sms-con-47 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Sea | 47 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-sms-con-53 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Sea | 53 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-sms-con-54 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Sea | 54 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-sms-con-47-1 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Upd | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-sms-con-48-1 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Upd | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-sms-con-54-1 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Upd | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-sms-con-55-1 | NEGOCIO | Customer Management | msacm-b-domain-sms-cellphone-control:Upd | 55 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-biom-val-77 | NEGOCIO | Customer Management | msacm-d-business-biometric-identity-vali | 77 | — | CAMPO_OBLIGATORIO | `@NotNull private MultipartFile biometricProfileImage;` |
| BR-AM-biom-val-83 | NEGOCIO | Customer Management | msacm-d-business-biometric-identity-vali | 83 | — | CAMPO_OBLIGATORIO | `@NotNull private String biometricProfileImageMd5;` |
| BR-AM-biom-val-84 | NEGOCIO | Customer Management | msacm-d-business-biometric-identity-vali | 84 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String biometricProfileImageMd5;` |
| BR-AM-biom-val-90 | NEGOCIO | Customer Management | msacm-d-business-biometric-identity-vali | 90 | — | CAMPO_OBLIGATORIO | `@NotNull private Boolean consentIdentityDataVerification;` |
| BR-AM-cust-val-47 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 47 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNames;` |
| BR-AM-cust-val-48 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 48 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNames;` |
| BR-AM-cust-val-49 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNames;` |
| BR-AM-cust-val-55 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 55 | — | CAMPO_OBLIGATORIO | `@NotNull private String lastName;` |
| BR-AM-cust-val-56 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 56 | — | CAMPO_OBLIGATORIO | `@NotBlank private String lastName;` |
| BR-AM-cust-val-57 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String lastName;` |
| BR-AM-cust-val-68 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 68 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-cust-val-69 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 69 | — | CAMPO_OBLIGATORIO | `@NotBlank private String cellphoneNumber;` |
| BR-AM-cust-val-70 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 70 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-cust-val-76 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 76 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthDate;` |
| BR-AM-cust-val-77-1 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 77 | — | CAMPO_OBLIGATORIO | `@NotBlank private String birthDate;` |
| BR-AM-cust-val-78 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 78 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthDate;` |
| BR-AM-cust-val-84 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 84 | — | CAMPO_OBLIGATORIO | `@NotNull private String uniquePopulationRegistryCode;` |
| BR-AM-cust-val-85 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 85 | — | CAMPO_OBLIGATORIO | `@NotBlank private String uniquePopulationRegistryCode;` |
| BR-AM-cust-val-86 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 86 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String uniquePopulationRegistryCode;` |
| BR-AM-cust-val-92 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 92 | — | CAMPO_OBLIGATORIO | `@NotNull private String gender;` |
| BR-AM-cust-val-93 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 93 | — | CAMPO_OBLIGATORIO | `@NotBlank private String gender;` |
| BR-AM-cust-val-94 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 94 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String gender;` |
| BR-AM-cust-val-100 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 100 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthEntity;` |
| BR-AM-cust-val-101 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 101 | — | CAMPO_OBLIGATORIO | `@NotBlank private String birthEntity;` |
| BR-AM-cust-val-102 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 102 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthEntity;` |
| BR-AM-cust-val-17 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 17 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNames;` |
| BR-AM-cust-val-18 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 18 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNames;` |
| BR-AM-cust-val-19 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 19 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNames;` |
| BR-AM-cust-val-26 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 26 | — | CAMPO_OBLIGATORIO | `@NotNull private String lastName;` |
| BR-AM-cust-val-27 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 27 | — | CAMPO_OBLIGATORIO | `@NotBlank private String lastName;` |
| BR-AM-cust-val-28 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 28 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String lastName;` |
| BR-AM-cust-val-41 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 41 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-cust-val-42 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 42 | — | CAMPO_OBLIGATORIO | `@NotBlank private String cellphoneNumber;` |
| BR-AM-cust-val-43 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 43 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-cust-val-50 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthDate;` |
| BR-AM-cust-val-57-1 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String uniquePopulationRegistryCode;` |
| BR-AM-cust-val-58 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 58 | — | CAMPO_OBLIGATORIO | `@NotBlank private String uniquePopulationRegistryCode;` |
| BR-AM-cust-val-59 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 59 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String uniquePopulationRegistryCode;` |
| BR-AM-cust-val-66 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 66 | — | CAMPO_OBLIGATORIO | `@NotNull private String gender;` |
| BR-AM-cust-val-67 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 67 | — | CAMPO_OBLIGATORIO | `@NotBlank private String gender;` |
| BR-AM-cust-val-68-1 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 68 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String gender;` |
| BR-AM-cust-val-75 | NEGOCIO | Customer Management | msacm-d-business-customer-data-validatio | 75 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthEntity;` |
| BR-AM-cust-dat-21 | NEGOCIO | Customer Management | msacm-d-business-customer-proposition-da | 21 | — | CAMPO_OBLIGATORIO | `@NotNull private Boolean acceptedProposition;` |
| BR-AM-iden-rec-19 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 19 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphone;` |
| BR-AM-iden-rec-20 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 20 | — | CAMPO_OBLIGATORIO | `@NotBlank private String cellphone;` |
| BR-AM-iden-rec-24 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 24 | — | CAMPO_OBLIGATORIO | `@NotNull private String email;` |
| BR-AM-iden-rec-25 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 25 | — | CAMPO_OBLIGATORIO | `@NotBlank private String email;` |
| BR-AM-iden-rec-47 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 47 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-iden-rec-48 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 48 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-iden-rec-84 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 84 | — | CAMPO_OBLIGATORIO | `@NotNull private MultipartFile biometricProfileImage;` |
| BR-AM-iden-rec-90 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 90 | — | CAMPO_OBLIGATORIO | `@NotNull private String biometricProfileImageMd5;` |
| BR-AM-iden-rec-91 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 91 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String biometricProfileImageMd5;` |
| BR-AM-iden-rec-97 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 97 | — | CAMPO_OBLIGATORIO | `@NotNull private Boolean consentIdentityDataVerification;` |
| BR-AM-iden-rec-37 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-iden-rec-38 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 38 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-iden-rec-43 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private MultipartFile frontDocument;` |
| BR-AM-iden-rec-53 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private String frontMD5;` |
| BR-AM-iden-rec-54 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String frontMD5;` |
| BR-AM-iden-rec-63 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 63 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerEmail;` |
| BR-AM-iden-rec-64 | NEGOCIO | Customer Management | msacm-d-business-identity-data-recovery: | 64 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerEmail;` |
| BR-AM-iden-ret-20 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 20 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-iden-ret-21 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 21 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-iden-ret-22 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 22 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-iden-ret-25 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 25 | — | CAMPO_OBLIGATORIO | `@NotNull private String productNumber;` |
| BR-AM-iden-ret-26 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 26 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-iden-ret-27 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 27 | — | CAMPO_OBLIGATORIO | `@NotBlank private String productNumber;` |
| BR-AM-iden-ret-30 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 30 | — | CAMPO_OBLIGATORIO | `@NotNull private String productName;` |
| BR-AM-iden-ret-31 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 31 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productName;` |
| BR-AM-iden-ret-32 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 32 | — | CAMPO_OBLIGATORIO | `@NotBlank private String productName;` |
| BR-AM-iden-ret-54 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 54 | — | CAMPO_OBLIGATORIO | `@NotNull private String frontMD5Ine;` |
| BR-AM-iden-ret-55 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String frontMD5Ine;` |
| BR-AM-iden-ret-56 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 56 | — | CAMPO_OBLIGATORIO | `@NotBlank private String frontMD5Ine;` |
| BR-AM-iden-ret-61 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 61 | — | CAMPO_OBLIGATORIO | `@NotNull private String reverseMD5Ine;` |
| BR-AM-iden-ret-62 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 62 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String reverseMD5Ine;` |
| BR-AM-iden-ret-63 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:I | 63 | — | CAMPO_OBLIGATORIO | `@NotBlank private String reverseMD5Ine;` |
| BR-AM-iden-ret-40 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:V | 40 | — | CAMPO_OBLIGATORIO | `@NotNull private String frontmd5Ine;` |
| BR-AM-iden-ret-41 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:V | 41 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String frontmd5Ine;` |
| BR-AM-iden-ret-42 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:V | 42 | — | CAMPO_OBLIGATORIO | `@NotBlank private String frontmd5Ine;` |
| BR-AM-iden-ret-48 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:V | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String reversemd5Ine;` |
| BR-AM-iden-ret-49 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:V | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String reversemd5Ine;` |
| BR-AM-iden-ret-50 | NEGOCIO | Customer Management | msacm-d-business-identity-data-retrive:V | 50 | — | CAMPO_OBLIGATORIO | `@NotBlank private String reversemd5Ine;` |
| BR-AM-iden-val-37 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private MultipartFile frontDocument;` |
| BR-AM-iden-val-43 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private MultipartFile reverseDocument;` |
| BR-AM-iden-val-49 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 49 | — | CAMPO_OBLIGATORIO | `@NotNull private String frontMD5;` |
| BR-AM-iden-val-50 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 50 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String frontMD5;` |
| BR-AM-iden-val-56 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private String reverseMD5;` |
| BR-AM-iden-val-57 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String reverseMD5;` |
| BR-AM-iden-val-36 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 36 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNames;` |
| BR-AM-iden-val-37-1 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 37 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNames;` |
| BR-AM-iden-val-43-1 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerLastName;` |
| BR-AM-iden-val-44 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 44 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerLastName;` |
| BR-AM-iden-val-50-1 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerSecondLastName;` |
| BR-AM-iden-val-51 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerSecondLastName;` |
| BR-AM-iden-val-57-1 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String uniquePopulationRegistryCode;` |
| BR-AM-iden-val-58 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 58 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String uniquePopulationRegistryCode;` |
| BR-AM-iden-val-64 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 64 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthDate;` |
| BR-AM-iden-val-65 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 65 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthDate;` |
| BR-AM-iden-val-71 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 71 | — | CAMPO_OBLIGATORIO | `@NotNull private String postalCode;` |
| BR-AM-iden-val-72 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 72 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String postalCode;` |
| BR-AM-iden-val-78 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 78 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerGender;` |
| BR-AM-iden-val-79 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 79 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerGender;` |
| BR-AM-iden-val-85 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 85 | — | CAMPO_OBLIGATORIO | `@NotNull private String credentialIdentificationCode;` |
| BR-AM-iden-val-86 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 86 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String credentialIdentificationCode;` |
| BR-AM-iden-val-92 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 92 | — | CAMPO_OBLIGATORIO | `@NotNull private String opticalCharacterRecognition;` |
| BR-AM-iden-val-93 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 93 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String opticalCharacterRecognition;` |
| BR-AM-iden-val-99 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 99 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthEntityId;` |
| BR-AM-iden-val-100 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 100 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthEntityId;` |
| BR-AM-iden-val-106 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 106 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthEntity;` |
| BR-AM-iden-val-107 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 107 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthEntity;` |
| BR-AM-iden-val-113 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 113 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-iden-val-114 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 114 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-iden-val-120 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 120 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerEmail;` |
| BR-AM-iden-val-121 | NEGOCIO | Customer Management | msacm-d-business-identity-data-validatio | 121 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerEmail;` |
| BR-AM-blac-val-48 | NEGOCIO | Customer Management | msacm-d-domain-black-lists-validation:Cu | 48 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerName;` |
| BR-AM-blac-val-60 | NEGOCIO | Customer Management | msacm-d-domain-black-lists-validation:Cu | 60 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerLastName;` |
| BR-AM-cust-ope-49 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 49 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-cust-ope-55 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 55 | — | CAMPO_OBLIGATORIO | `@NotBlank private String cellphone;` |
| BR-AM-cust-ope-61 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 61 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer type;` |
| BR-AM-cust-ope-68 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 68 | — | CAMPO_OBLIGATORIO | `@NotBlank private String status;` |
| BR-AM-cust-ope-74 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 74 | — | CAMPO_OBLIGATORIO | `@NotBlank private String verifiedStatus;` |
| BR-AM-cust-ope-48 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer operationType;` |
| BR-AM-cust-ope-55-1 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 55 | — | CAMPO_OBLIGATORIO | `@NotBlank private String company;` |
| BR-AM-cust-ope-61-1 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 61 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-cust-ope-67 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 67 | — | CAMPO_OBLIGATORIO | `@NotBlank private String cellphone;` |
| BR-AM-cust-ope-73 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 73 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer type;` |
| BR-AM-cust-ope-86 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 86 | — | CAMPO_OBLIGATORIO | `@NotBlank private String status;` |
| BR-AM-cust-ope-92 | NEGOCIO | Customer Management | msacm-d-domain-customer-cellphone-operat | 92 | — | CAMPO_OBLIGATORIO | `@NotBlank private String emailStatus;` |
| BR-AM-cust-b-65 | NEGOCIO | Customer Management | msacm-d-domain-customer-data-b:CustomerD | 65 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerId;` |
| BR-AM-cust-b-66 | NEGOCIO | Customer Management | msacm-d-domain-customer-data-b:CustomerD | 66 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerId;` |
| BR-AM-cust-b-67 | NEGOCIO | Customer Management | msacm-d-domain-customer-data-b:CustomerD | 67 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerId;` |
| BR-AM-cust-b-67-1 | NEGOCIO | Customer Management | msacm-d-domain-customer-data-b:CustomerN | 67 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.CANNOT_BE_EMPTY) private String cellphone;` |
| BR-AM-cust-b-68 | NEGOCIO | Customer Management | msacm-d-domain-customer-data-b:CustomerN | 68 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CANNOT_BE_NULL) private String cellphone;` |
| BR-AM-cust-b-52 | NEGOCIO | Customer Management | msacm-d-domain-customer-data-b:DigitalSe | 52 | — | CAMPO_OBLIGATORIO | `@NotBlank private String companyNumber;` |
| BR-AM-cust-b-58 | NEGOCIO | Customer Management | msacm-d-domain-customer-data-b:DigitalSe | 58 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-cust-b-64 | NEGOCIO | Customer Management | msacm-d-domain-customer-data-b:DigitalSe | 64 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer contractStatusId;` |
| BR-AM-cust-b-76 | NEGOCIO | Customer Management | msacm-d-domain-customer-data-b:DigitalSe | 76 | — | CAMPO_OBLIGATORIO | `@NotBlank private String branch;` |
| BR-AM-cust-dat-48 | NEGOCIO | Customer Management | msacm-d-domain-customer-data:CustomerDat | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerId;` |
| BR-AM-cust-dat-49 | NEGOCIO | Customer Management | msacm-d-domain-customer-data:CustomerDat | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerId;` |
| BR-AM-cust-dat-50 | NEGOCIO | Customer Management | msacm-d-domain-customer-data:CustomerDat | 50 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerId;` |
| BR-AM-cust-dat-44 | NEGOCIO | Customer Management | msacm-d-domain-customer-data:CustomerNum | 44 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "Can't be empty.") private String cellphone;` |
| BR-AM-cust-dat-45 | NEGOCIO | Customer Management | msacm-d-domain-customer-data:CustomerNum | 45 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "Can't be null.") private String cellphone;` |
| BR-AM-cust-b-30 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 30 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String customerNumber;` |
| BR-AM-cust-b-31 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 31 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_NOT_VALUE) private String customerNumber;` |
| BR-AM-cust-b-51 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-cust-b-57 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphone;` |
| BR-AM-cust-b-71 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 71 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String osversion;` |
| BR-AM-cust-b-77 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 77 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String appversion;` |
| BR-AM-cust-b-83 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 83 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String phonemodel;` |
| BR-AM-cust-b-89 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 89 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originCall;` |
| BR-AM-cust-sta-36 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 36 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-cust-sta-42 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 42 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphone;` |
| BR-AM-cust-sta-54 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String osversion;` |
| BR-AM-cust-sta-60 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 60 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String appversion;` |
| BR-AM-cust-sta-66 | NEGOCIO | Customer Management | msacm-d-domain-customer-enrollment-statu | 66 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String phonemodel;` |
| BR-AM-cust-man-62 | NEGOCIO | Customer Management | msacm-d-domain-customer-identification-m | 62 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-cust-man-69 | NEGOCIO | Customer Management | msacm-d-domain-customer-identification-m | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerId;` |
| BR-AM-cust-pro-49 | NEGOCIO | Customer Management | msacm-d-domain-customer-products:Custome | 49 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerId;` |
| BR-AM-cust-pro-50 | NEGOCIO | Customer Management | msacm-d-domain-customer-products:Custome | 50 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerId;` |
| BR-AM-cust-pro-56 | NEGOCIO | Customer Management | msacm-d-domain-customer-products:Custome | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private String company;` |
| BR-AM-cust-pro-57 | NEGOCIO | Customer Management | msacm-d-domain-customer-products:Custome | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String company;` |
| BR-AM-cust-dat-43 | NEGOCIO | Customer Management | msacm-d-domain-customer-proposition-data | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-cust-dat-44-1 | NEGOCIO | Customer Management | msacm-d-domain-customer-proposition-data | 44 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-cust-dat-45-1 | NEGOCIO | Customer Management | msacm-d-domain-customer-proposition-data | 45 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-cust-dat-51-1 | NEGOCIO | Customer Management | msacm-d-domain-customer-proposition-data | 51 | — | CAMPO_OBLIGATORIO | `@NotNull private Boolean acceptedProposition;` |
| BR-AM-cust-dat-57 | NEGOCIO | Customer Management | msacm-d-domain-customer-proposition-data | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String channelCode;` |
| BR-AM-cust-ver-30 | NEGOCIO | Customer Management | msacm-d-platform-customer-enrollment-ver | 30 | — | CAMPO_OBLIGATORIO | `@NotNull private TypeCloseSessionEnum type;` |
| BR-AM-cust-ver-16 | NEGOCIO | Customer Management | msacm-d-platform-customer-enrollment-ver | 16 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphone;` |
| BR-AM-cust-ver-22 | NEGOCIO | Customer Management | msacm-d-platform-customer-enrollment-ver | 22 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String custResponse;` |
| BR-AM-cust-ver-49 | NEGOCIO | Customer Management | msacm-d-platform-customer-enrollment-ver | 49 | — | CAMPO_OBLIGATORIO | `@NotNull private Customer customer;` |
| BR-AM-cust-man-46 | NEGOCIO | Customer Management | msacm-d-security-customer-access-managme | 46 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private String password;` |
| BR-AM-cust-man-47 | NEGOCIO | Customer Management | msacm-d-security-customer-access-managme | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_MUST_NOT_BE_NULL) private String password;` |
| BR-AM-cust-man-48 | NEGOCIO | Customer Management | msacm-d-security-customer-access-managme | 48 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_MUST_NOT_BE_NULL) private String password;` |
| BR-AM-cust-man-52 | NEGOCIO | Customer Management | msacm-d-security-customer-access-managme | 52 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private String passwordConfir` |
| BR-AM-cust-man-53 | NEGOCIO | Customer Management | msacm-d-security-customer-access-managme | 53 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_MUST_NOT_BE_NULL) private String passwordConfi` |
| BR-AM-cust-man-54 | NEGOCIO | Customer Management | msacm-d-security-customer-access-managme | 54 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_MUST_NOT_BE_NULL) private String passwordConfi` |
| BR-AM-cust-man-51 | NEGOCIO | Customer Management | msacm-d-security-customer-access-managme | 51 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private String password;` |
| BR-AM-cust-man-52-1 | NEGOCIO | Customer Management | msacm-d-security-customer-access-managme | 52 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_MUST_NOT_BE_NULL) private String password;` |
| BR-AM-cust-man-53-1 | NEGOCIO | Customer Management | msacm-d-security-customer-access-managme | 53 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_MUST_NOT_BE_NULL) private String password;` |
| BR-AM-push-ser-53 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerName;` |
| BR-AM-push-ser-74 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 74 | — | CAMPO_OBLIGATORIO | `@NotNull private String companyName;` |
| BR-AM-push-ser-53-1 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private String companyName;` |
| BR-AM-push-ser-47 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 47 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerName;` |
| BR-AM-push-ser-48 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 48 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerName;` |
| BR-AM-push-ser-68 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 68 | — | CAMPO_OBLIGATORIO | `@NotNull private String companyName;` |
| BR-AM-push-ser-69 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyName;` |
| BR-AM-push-ser-60 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private String providerChannel;` |
| BR-AM-push-ser-61 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 61 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String providerChannel;` |
| BR-AM-push-ser-65 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 65 | — | CAMPO_OBLIGATORIO | `@NotNull private String providerChannel;` |
| BR-AM-push-ser-46 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String companyName;` |
| BR-AM-push-ser-47-1 | NEGOCIO | Customer Management | msacm-d-security-push-notifications-serv | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyName;` |
| BR-AM-phon-otp-46 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:InsertRegistr | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-phon-otp-47 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:InsertRegistr | 47 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-phon-otp-53 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:InsertRegistr | 53 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-phon-otp-54 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:InsertRegistr | 54 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-phon-otp-67 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:InsertRegistr | 67 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String branch;` |
| BR-AM-phon-otp-68 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:InsertRegistr | 68 | — | CAMPO_OBLIGATORIO | `@NotNull private String branch;` |
| BR-AM-phon-otp-52 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:RequestOtp | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-phon-otp-53-1 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:RequestOtp | 53 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-phon-otp-59 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:RequestOtp | 59 | — | CAMPO_OBLIGATORIO | `@NotNull private String type;` |
| BR-AM-phon-otp-45 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:RequestSendOt | 45 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-phon-otp-46-1 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:RequestSendOt | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-phon-otp-52-1 | NEGOCIO | Customer Management | msacm-i-security-phone-otp:RequestSendOt | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private String type;` |
| BR-AM-cust-val-36 | NEGOCIO | Customer Management | msacm-o-business-customer-cellphone-vali | 36 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-cust-val-37 | NEGOCIO | Customer Management | msacm-o-business-customer-cellphone-vali | 37 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-cust-val-43-1 | NEGOCIO | Customer Management | msacm-o-business-customer-cellphone-vali | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer cellphoneRepeat;` |
| BR-AM-cust-val-50-1 | NEGOCIO | Customer Management | msacm-o-business-customer-cellphone-vali | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-cust-val-51 | NEGOCIO | Customer Management | msacm-o-business-customer-cellphone-vali | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank private String cellphoneNumber;` |
| BR-AM-sess-man-53 | NEGOCIO | Customer Management | msacm-p-security-session-management:Clos | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private TypeCloseSessionEnum type;` |
| BR-AM-sess-man-51 | NEGOCIO | Customer Management | msacm-p-security-session-management:Data | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-sess-man-52 | NEGOCIO | Customer Management | msacm-p-security-session-management:Data | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-sess-man-58 | NEGOCIO | Customer Management | msacm-p-security-session-management:Data | 58 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerId;` |
| BR-AM-sess-man-59 | NEGOCIO | Customer Management | msacm-p-security-session-management:Data | 59 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerId;` |
| BR-AM-sess-man-73 | NEGOCIO | Customer Management | msacm-p-security-session-management:Open | 73 | — | CAMPO_OBLIGATORIO | `@NotNull private CustomerBody customer;` |
| BR-AM-sess-man-94 | NEGOCIO | Customer Management | msacm-p-security-session-management:Open | 94 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerPhonenumber;` |
| BR-AM-sess-man-100 | NEGOCIO | Customer Management | msacm-p-security-session-management:Open | 100 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerPassword;` |
| BR-AM-sess-man-101 | NEGOCIO | Customer Management | msacm-p-security-session-management:Open | 101 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerPassword;` |
| BR-AM-acco-ben-95 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 95 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthdate;` |
| BR-AM-acco-ben-36-1 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 36 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String street;` |
| BR-AM-acco-ben-93 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 93 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String neighborhoodCode;` |
| BR-AM-acco-ben-112 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:A | 112 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String numberExtStreet;` |
| BR-AM-acco-ben-49 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:R | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-acco-ben-46 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:R | 46 | — | CAMPO_OBLIGATORIO | `@NotBlank private String companyNumber;` |
| BR-AM-acco-ben-47-1 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:R | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-acco-ben-64 | NEGOCIO | Deposit & Transfer | msadp-b-business-account-beneficiaries:R | 64 | — | CAMPO_OBLIGATORIO | `@NotEmpty private List<@Valid AccountSendBeneficiary> accountSendBeneficiary;` |
| BR-AM-depo-b-52 | NEGOCIO | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 52 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-depo-b-64-1 | NEGOCIO | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 64 | — | CAMPO_OBLIGATORIO | `@NotBlank private String dischargeDate;` |
| BR-AM-depo-b-71 | NEGOCIO | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 71 | — | CAMPO_OBLIGATORIO | `@NotBlank private String transactionNumber;` |
| BR-AM-depo-det-52 | NEGOCIO | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 52 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-depo-det-64 | NEGOCIO | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 64 | — | CAMPO_OBLIGATORIO | `@NotBlank private String dischargeDate;` |
| BR-AM-depo-det-71 | NEGOCIO | Deposit & Transfer | msadp-b-business-deposit-accounts-moveme | 71 | — | CAMPO_OBLIGATORIO | `@NotBlank private String transactionNumber;` |
| BR-AM-digi-man-56 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private String originAccountNumber;` |
| BR-AM-digi-man-57 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 57 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-digi-man-104 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 104 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal targetAmount;` |
| BR-AM-digi-man-110 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 110 | — | CAMPO_OBLIGATORIO | `@NotNull private String targetDate;` |
| BR-AM-digi-man-111 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 111 | — | CAMPO_OBLIGATORIO | `@NotBlank private String targetDate;` |
| BR-AM-digi-man-117 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 117 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal automaticSavingsAmount;` |
| BR-AM-digi-man-53 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private String originAccountNumber;` |
| BR-AM-digi-man-54 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 54 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originAccountNumber;` |
| BR-AM-digi-man-60-1 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private String digitalEnvelopeAccount;` |
| BR-AM-digi-man-61 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-manage | 61 | — | CAMPO_OBLIGATORIO | `@NotBlank private String digitalEnvelopeAccount;` |
| BR-AM-digi-tra-54 | NEGOCIO | Deposit & Transfer | msadp-b-business-digital-envelope-transa | 54 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal transactionAmount;` |
| BR-AM-inve-ope-63 | NEGOCIO | Deposit & Transfer | msadp-b-business-investment-account-open | 63 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-inve-ope-69 | NEGOCIO | Deposit & Transfer | msadp-b-business-investment-account-open | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-inve-ope-75 | NEGOCIO | Deposit & Transfer | msadp-b-business-investment-account-open | 75 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerEmail;` |
| BR-AM-inve-ope-45 | NEGOCIO | Deposit & Transfer | msadp-b-business-investment-account-open | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-prom-ope-44 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-account-open | 44 | — | CAMPO_OBLIGATORIO | `@NotBlank private String expirationDate;` |
| BR-AM-prom-ope-56 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-account-open | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-prom-ope-62 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-account-open | 62 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-prom-ope-68-1 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-account-open | 68 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerEmail;` |
| BR-AM-prom-ope-32 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-account-open | 32 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-prom-b-52 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 52 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String accou` |
| BR-AM-prom-b-53 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 53 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String acco` |
| BR-AM-prom-b-61 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 61 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_DAYS_NULL) private Integer requestedDays;` |
| BR-AM-prom-b-69 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 69 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_PAGE_NUMBER_NULL) private Integer request` |
| BR-AM-prom-b-77 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 77 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_REGISTER_NUMBER_NULL) private Integer req` |
| BR-AM-prom-mov-38 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 38 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String accou` |
| BR-AM-prom-mov-39 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 39 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String acco` |
| BR-AM-prom-mov-45 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 45 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_DAYS_NULL) private Integer requestedDays;` |
| BR-AM-prom-mov-52 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 52 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_PAGE_NUMBER_NULL) private Integer request` |
| BR-AM-prom-mov-60 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 60 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_REGISTER_NUMBER_NULL) private Integer req` |
| BR-AM-prom-acc-55 | NEGOCIO | Deposit & Transfer | msadp-b-business-promissory-notes-accoun | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-leve-acc-13 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 13 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-leve-acc-19 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 19 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String requestId;` |
| BR-AM-leve-acc-37 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 37 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String uuid;` |
| BR-AM-leve-acc-43 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 43 | — | CAMPO_OBLIGATORIO | `@NotEmpty private Boolean biometricProfileMatch;` |
| BR-AM-leve-acc-13-1 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 13 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String model;` |
| BR-AM-leve-acc-25 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 25 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String osVersion;` |
| BR-AM-leve-acc-44 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 44 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String firstName;` |
| BR-AM-leve-acc-55 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String lastName;` |
| BR-AM-leve-acc-66 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 66 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthDate;` |
| BR-AM-leve-acc-72 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 72 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String gender;` |
| BR-AM-leve-acc-79 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 79 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String uniquePopulationRegistryCode;` |
| BR-AM-leve-acc-86 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 86 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String nationality;` |
| BR-AM-leve-acc-93 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 93 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String identificationCode;` |
| BR-AM-leve-acc-100 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 100 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String entity;` |
| BR-AM-leve-acc-107 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 107 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String street;` |
| BR-AM-leve-acc-114 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 114 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String neighborhoodName;` |
| BR-AM-leve-acc-121 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 121 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String municipalityName;` |
| BR-AM-leve-acc-128 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 128 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String postalCode;` |
| BR-AM-leve-acc-147 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 147 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String neighborhoodId;` |
| BR-AM-leve-acc-154 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 154 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cellphoneNumber;` |
| BR-AM-leve-acc-160 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 160 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String telephoneCarrier;` |
| BR-AM-leve-acc-167 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 167 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String email;` |
| BR-AM-leve-acc-173 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 173 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String validationType;` |
| BR-AM-leve-acc-187 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 187 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String birthEntity;` |
| BR-AM-leve-acc-194 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 194 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String requestId;` |
| BR-AM-leve-acc-200 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 200 | — | CAMPO_OBLIGATORIO | `@NotNull private String imageMd5;` |
| BR-AM-leve-acc-206 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 206 | — | CAMPO_OBLIGATORIO | `@NotNull private Boolean noticeOfPrivacity;` |
| BR-AM-leve-acc-212 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 212 | — | CAMPO_OBLIGATORIO | `@NotNull private Boolean termsAndConditions;` |
| BR-AM-leve-acc-218 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 218 | — | CAMPO_OBLIGATORIO | `@NotNull private Boolean accountOpeningAgreement;` |
| BR-AM-leve-acc-224 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 224 | — | CAMPO_OBLIGATORIO | `@NotNull private Boolean digitalServiceContract;` |
| BR-AM-leve-acc-230 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 230 | — | CAMPO_OBLIGATORIO | `@NotNull private Boolean cvvTermsAndConditions;` |
| BR-AM-leve-acc-236 | NEGOCIO | Deposit & Transfer | msadp-d-business-level-two-digital-accou | 236 | — | CAMPO_OBLIGATORIO | `@NotNull private MultipartFile biometricProfileImage;` |
| BR-AM-appl-tra-54 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 54 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String originAccountNumber;` |
| BR-AM-appl-tra-55 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-appl-tra-61 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 61 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String originCustomerNumber;` |
| BR-AM-appl-tra-62 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 62 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originCustomerNumber;` |
| BR-AM-appl-tra-68 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 68 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String destinationAccountNum` |
| BR-AM-appl-tra-69 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationAccountNumber;` |
| BR-AM-appl-tra-75 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 75 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private BigDecimal amount;` |
| BR-AM-appl-tra-106 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 106 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private BigDecimal commissionIva;` |
| BR-AM-appl-tra-113 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 113 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String customerName;` |
| BR-AM-appl-tra-114 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 114 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerName;` |
| BR-AM-appl-tra-120 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 120 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private Integer typeAccountPayer;` |
| BR-AM-appl-tra-126 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 126 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String originCustomerRfc;` |
| BR-AM-appl-tra-127 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 127 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originCustomerRfc;` |
| BR-AM-appl-tra-141 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 141 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private Integer typeBeneficiaryAccou` |
| BR-AM-appl-tra-147 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 147 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private BigDecimal iva;` |
| BR-AM-appl-tra-153 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 153 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String virtualBranch;` |
| BR-AM-appl-tra-154 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 154 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String virtualBranch;` |
| BR-AM-appl-tra-167 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 167 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String speiTransferNumber;` |
| BR-AM-appl-tra-168 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 168 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String speiTransferNumber;` |
| BR-AM-appl-tra-181 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-interbank-transfer: | 181 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_NOT_VALUE) private String beneficiaryRfc;` |
| BR-AM-appl-tra-34 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 34 | — | CAMPO_OBLIGATORIO | `@NotNull private String originAccountNumber;` |
| BR-AM-appl-tra-37 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private String originCustomerNumber;` |
| BR-AM-appl-tra-40 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 40 | — | CAMPO_OBLIGATORIO | `@NotNull private String destinationAccountNumber;` |
| BR-AM-appl-tra-43 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-appl-tra-49 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 49 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal totalAmount;` |
| BR-AM-appl-tra-52 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal firmAmount;` |
| BR-AM-appl-tra-55-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 55 | — | CAMPO_OBLIGATORIO | `@NotNull private String virtualBranch;` |
| BR-AM-appl-tra-61-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 61 | — | CAMPO_OBLIGATORIO | `@NotNull private String cargoTransaction;` |
| BR-AM-appl-tra-64 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 64 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditTransaction;` |
| BR-AM-appl-tra-70 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 70 | — | CAMPO_OBLIGATORIO | `@NotNull private String branchTransaction;` |
| BR-AM-appl-tra-82 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 82 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal sbcAmount;` |
| BR-AM-appl-tra-86 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 86 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal remAmount;` |
| BR-AM-appl-tra-90 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 90 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer retDays;` |
| BR-AM-appl-tra-97 | NEGOCIO | Deposit & Transfer | msadp-d-domain-apply-intrabank-transfer: | 97 | — | CAMPO_OBLIGATORIO | `@NotNull private String typeReversion;` |
| BR-AM-depo-b-32 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-b:Deposi | 32 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String deviceAccess;` |
| BR-AM-depo-b-34 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-b:Deposi | 34 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-depo-b-46 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 46 | — | CAMPO_OBLIGATORIO | `@NotBlank private String companyNumber;` |
| BR-AM-depo-ben-43 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 43 | — | CAMPO_OBLIGATORIO | `@NotBlank private String companyNumber;` |
| BR-AM-depo-ben-50 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-benefici | 50 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-depo-b-46-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-depo-b-53 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedPage;` |
| BR-AM-depo-b-60 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedRecordsNumber;` |
| BR-AM-depo-b-67 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 67 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedDays;` |
| BR-AM-depo-det-51 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-depo-det-57 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 57 | — | CAMPO_OBLIGATORIO | `@NotBlank private String dischargeDate;` |
| BR-AM-depo-det-69 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 69 | — | CAMPO_OBLIGATORIO | `@NotBlank private String companyNumber;` |
| BR-AM-depo-det-75 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 75 | — | CAMPO_OBLIGATORIO | `@NotBlank private String transactionNumber;` |
| BR-AM-depo-mov-46 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts-movement | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-depo-acc-32 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts:DepositA | 32 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String deviceAccess;` |
| BR-AM-depo-acc-34 | NEGOCIO | Deposit & Transfer | msadp-d-domain-deposit-accounts:DepositA | 34 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-inve-ope-39 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 39 | — | CAMPO_OBLIGATORIO | `@NotNull private String companyNumber;` |
| BR-AM-inve-ope-40 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 40 | — | CAMPO_OBLIGATORIO | `@NotBlank private String companyNumber;` |
| BR-AM-inve-ope-46 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String branch;` |
| BR-AM-inve-ope-47 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 47 | — | CAMPO_OBLIGATORIO | `@NotBlank private String branch;` |
| BR-AM-inve-ope-60 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditorTransaction;` |
| BR-AM-inve-ope-61 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 61 | — | CAMPO_OBLIGATORIO | `@NotBlank private String creditorTransaction;` |
| BR-AM-inve-ope-67 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 67 | — | CAMPO_OBLIGATORIO | `@NotNull private String branchTransaction;` |
| BR-AM-inve-ope-68 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 68 | — | CAMPO_OBLIGATORIO | `@NotBlank private String branchTransaction;` |
| BR-AM-inve-ope-74 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 74 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-inve-ope-75-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 75 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-inve-ope-87 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 87 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-inve-ope-93 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 93 | — | CAMPO_OBLIGATORIO | `@NotNull private String currencyType;` |
| BR-AM-inve-ope-94 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 94 | — | CAMPO_OBLIGATORIO | `@NotBlank private String currencyType;` |
| BR-AM-inve-ope-107 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 107 | — | CAMPO_OBLIGATORIO | `@NotNull private String cardNumber;` |
| BR-AM-inve-ope-119 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 119 | — | CAMPO_OBLIGATORIO | `@NotNull private String productNumber;` |
| BR-AM-inve-ope-120 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 120 | — | CAMPO_OBLIGATORIO | `@NotBlank private String productNumber;` |
| BR-AM-inve-ope-126 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 126 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-inve-ope-127 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 127 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-inve-ope-133 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 133 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountStatus;` |
| BR-AM-inve-ope-134 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 134 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountStatus;` |
| BR-AM-inve-ope-140 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 140 | — | CAMPO_OBLIGATORIO | `@NotNull private String signatureRegister;` |
| BR-AM-inve-ope-141 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 141 | — | CAMPO_OBLIGATORIO | `@NotBlank private String signatureRegister;` |
| BR-AM-inve-ope-160 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 160 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountExpirationInstructions;` |
| BR-AM-inve-ope-166 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 166 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer shippingAddressNumber;` |
| BR-AM-inve-ope-172 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 172 | — | CAMPO_OBLIGATORIO | `@NotNull private String capitalInstructionNumber;` |
| BR-AM-inve-ope-178 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 178 | — | CAMPO_OBLIGATORIO | `@NotNull private String capitalInstructionAccount;` |
| BR-AM-inve-ope-179 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 179 | — | CAMPO_OBLIGATORIO | `@NotBlank private String capitalInstructionAccount;` |
| BR-AM-inve-ope-185 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 185 | — | CAMPO_OBLIGATORIO | `@NotNull private String interestInstructionNumber;` |
| BR-AM-inve-ope-191 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 191 | — | CAMPO_OBLIGATORIO | `@NotNull private String interestInstructionAccount;` |
| BR-AM-inve-ope-197 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 197 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer loanPeriod;` |
| BR-AM-inve-ope-203 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 203 | — | CAMPO_OBLIGATORIO | `@NotNull private String isrFlag;` |
| BR-AM-inve-ope-204 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 204 | — | CAMPO_OBLIGATORIO | `@NotBlank private String isrFlag;` |
| BR-AM-inve-ope-224 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 224 | — | CAMPO_OBLIGATORIO | `@NotNull private String monthlyAmount;` |
| BR-AM-inve-ope-225 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 225 | — | CAMPO_OBLIGATORIO | `@NotBlank private String monthlyAmount;` |
| BR-AM-inve-ope-231 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 231 | — | CAMPO_OBLIGATORIO | `@NotNull private String depositCounter;` |
| BR-AM-inve-ope-232 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 232 | — | CAMPO_OBLIGATORIO | `@NotBlank private String depositCounter;` |
| BR-AM-inve-ope-238 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 238 | — | CAMPO_OBLIGATORIO | `@NotNull private String depositsAmount;` |
| BR-AM-inve-ope-239 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 239 | — | CAMPO_OBLIGATORIO | `@NotBlank private String depositsAmount;` |
| BR-AM-inve-ope-245 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 245 | — | CAMPO_OBLIGATORIO | `@NotNull private String withdrawalsNumberTotal;` |
| BR-AM-inve-ope-246 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 246 | — | CAMPO_OBLIGATORIO | `@NotBlank private String withdrawalsNumberTotal;` |
| BR-AM-inve-ope-252 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 252 | — | CAMPO_OBLIGATORIO | `@NotNull private String withdrawalAmount;` |
| BR-AM-inve-ope-253 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 253 | — | CAMPO_OBLIGATORIO | `@NotBlank private String withdrawalAmount;` |
| BR-AM-inve-ope-266 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 266 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amountOpening;` |
| BR-AM-inve-ope-272 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 272 | — | CAMPO_OBLIGATORIO | `@NotNull private String debtorTransaction;` |
| BR-AM-inve-ope-273 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 273 | — | CAMPO_OBLIGATORIO | `@NotBlank private String debtorTransaction;` |
| BR-AM-inve-ope-279 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 279 | — | CAMPO_OBLIGATORIO | `@NotNull private String branchDebtorTransaction;` |
| BR-AM-inve-ope-280 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 280 | — | CAMPO_OBLIGATORIO | `@NotBlank private String branchDebtorTransaction;` |
| BR-AM-inve-ope-292 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 292 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal totalAmount;` |
| BR-AM-inve-ope-298 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 298 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal firmAmount;` |
| BR-AM-inve-ope-304 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 304 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal contributionBaseSalaryAmount;` |
| BR-AM-inve-ope-310 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investment-account-openin | 310 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal remAmount;` |
| BR-AM-inve-acc-52 | NEGOCIO | Deposit & Transfer | msadp-d-domain-investments-accounts:Inve | 52 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-prom-ope-49 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 49 | — | CAMPO_OBLIGATORIO | `@NotBlank private String companyNumber;` |
| BR-AM-prom-ope-56-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 56 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-prom-ope-70 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 70 | — | CAMPO_OBLIGATORIO | `@NotBlank private String branch;` |
| BR-AM-prom-ope-84-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 84 | — | CAMPO_OBLIGATORIO | `@NotBlank private String signatureRegister;` |
| BR-AM-prom-ope-98 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 98 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer shippingAddressNumber;` |
| BR-AM-prom-ope-105 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 105 | — | CAMPO_OBLIGATORIO | `@NotBlank private String isrFlag;` |
| BR-AM-prom-ope-112 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 112 | — | CAMPO_OBLIGATORIO | `@NotBlank private String productNumber;` |
| BR-AM-prom-ope-126 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 126 | — | CAMPO_OBLIGATORIO | `@NotBlank private String specialAccount;` |
| BR-AM-prom-ope-147 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 147 | — | CAMPO_OBLIGATORIO | `@NotBlank private String expirationDate;` |
| BR-AM-prom-ope-154 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 154 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal capitalAmount;` |
| BR-AM-prom-ope-168 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 168 | — | CAMPO_OBLIGATORIO | `@NotBlank private String interestRate;` |
| BR-AM-prom-ope-175 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 175 | — | CAMPO_OBLIGATORIO | `@NotBlank private String depositCounter;` |
| BR-AM-prom-ope-182 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 182 | — | CAMPO_OBLIGATORIO | `@NotBlank private String checkingAccount;` |
| BR-AM-prom-ope-189 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 189 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-prom-ope-196 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 196 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal additionalPoints;` |
| BR-AM-prom-ope-210 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 210 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountEventInstructionsFrt;` |
| BR-AM-prom-ope-224 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 224 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountEventInstructionsSnd;` |
| BR-AM-prom-ope-231 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 231 | — | CAMPO_OBLIGATORIO | `@NotNull private List<BeneficiariesDetailResponse> accountBeneficiary;` |
| BR-AM-prom-ope-240 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 240 | — | CAMPO_OBLIGATORIO | `@NotNull private String coaccountFrt;` |
| BR-AM-prom-ope-247 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 247 | — | CAMPO_OBLIGATORIO | `@NotNull private String relationshipCoaccountFrt;` |
| BR-AM-prom-ope-254 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 254 | — | CAMPO_OBLIGATORIO | `@NotNull private String coaccountSnd;` |
| BR-AM-prom-ope-261 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 261 | — | CAMPO_OBLIGATORIO | `@NotNull private String relationshipCoaccountSnd;` |
| BR-AM-prom-ope-268 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 268 | — | CAMPO_OBLIGATORIO | `@NotBlank private String currencyType;` |
| BR-AM-prom-ope-275 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-account-openin | 275 | — | CAMPO_OBLIGATORIO | `@NotBlank private String creditorTransaction;` |
| BR-AM-prom-b-49 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 49 | — | CAMPO_OBLIGATORIO | `@NotNull private String type;` |
| BR-AM-prom-b-50 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 50 | — | CAMPO_OBLIGATORIO | `@NotBlank private String type;` |
| BR-AM-prom-b-55 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 55 | — | CAMPO_OBLIGATORIO | `@NotNull private String code;` |
| BR-AM-prom-b-56 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 56 | — | CAMPO_OBLIGATORIO | `@NotBlank private String code;` |
| BR-AM-prom-b-73 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 73 | — | CAMPO_OBLIGATORIO | `@NotNull private String uuid;` |
| BR-AM-prom-b-74 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 74 | — | CAMPO_OBLIGATORIO | `@NotBlank private String uuid;` |
| BR-AM-prom-b-68 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 68 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_DATE_NULL) private String date;` |
| BR-AM-prom-b-69-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 69 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_ERROR_DATE_NULL) private String date;` |
| BR-AM-prom-b-86 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 86 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_AMOUNT_NULL) private BigDecimal amount;` |
| BR-AM-prom-b-95 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 95 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_TRANSACTION_NULL) private String transact` |
| BR-AM-prom-b-96 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 96 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_ERROR_TRANSACTION_NULL) private String transac` |
| BR-AM-prom-b-50-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 50 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String accou` |
| BR-AM-prom-b-51 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String acco` |
| BR-AM-prom-b-57 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 57 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_PAGE_NUMBER_NULL) private Integer request` |
| BR-AM-prom-b-65 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 65 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_REGISTER_NUMBER_NULL) private Integer req` |
| BR-AM-prom-b-73-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 73 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_DAYS_NULL) private Integer requestedDays;` |
| BR-AM-prom-b-67 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 67 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_ERROR_LIST_ACCMOVEMENTS) private List<AccountAc` |
| BR-AM-prom-b-68-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 68 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_ERROR_LIST_ACCMOVEMENTS) private List<AccountA` |
| BR-AM-prom-mov-38-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 38 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String accou` |
| BR-AM-prom-mov-39-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 39 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = ApiValues.MSG_ERROR_ACCOUNT_NUMBER_NULL) private String acco` |
| BR-AM-prom-mov-45-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 45 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_DAYS_NULL) private Integer requestedDays;` |
| BR-AM-prom-mov-52-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 52 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_PAGE_NUMBER_NULL) private Integer request` |
| BR-AM-prom-mov-60-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 60 | — | CAMPO_OBLIGATORIO | `@NotNull(message = ApiValues.MSG_ERROR_REGISTER_NUMBER_NULL) private Integer req` |
| BR-AM-prom-acc-55-1 | NEGOCIO | Deposit & Transfer | msadp-d-domain-promissory-notes-accounts | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-digi-pro-55 | NEGOCIO | Lending / Loans | msalo-b-business-digital-loan-provisioni | 55 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-digi-pro-52 | NEGOCIO | Lending / Loans | msalo-b-business-digital-loan-provisioni | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal authorizedBalance;` |
| BR-AM-digi-pro-62 | NEGOCIO | Lending / Loans | msalo-b-business-digital-loan-provisioni | 62 | — | CAMPO_OBLIGATORIO | `@NotNull private Float interestRate;` |
| BR-AM-digi-pro-72 | NEGOCIO | Lending / Loans | msalo-b-business-digital-loan-provisioni | 72 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer loanPeriod;` |
| BR-AM-digi-pro-82 | NEGOCIO | Lending / Loans | msalo-b-business-digital-loan-provisioni | 82 | — | CAMPO_OBLIGATORIO | `@NotNull private String folio;` |
| BR-AM-digi-pro-92 | NEGOCIO | Lending / Loans | msalo-b-business-digital-loan-provisioni | 92 | — | CAMPO_OBLIGATORIO | `@NotNull private String productNumber;` |
| BR-AM-pers-b-53 | NEGOCIO | Lending / Loans | msalo-b-business-personal-loan-provision | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-pers-b-61 | NEGOCIO | Lending / Loans | msalo-b-business-personal-loan-provision | 61 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumber;` |
| BR-AM-pers-b-69 | NEGOCIO | Lending / Loans | msalo-b-business-personal-loan-provision | 69 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String loanPeriod;` |
| BR-AM-pers-b-55 | NEGOCIO | Lending / Loans | msalo-b-business-personal-loan-provision | 55 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-sala-con-28 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-confirm: | 28 | — | CAMPO_OBLIGATORIO | `@NotNull private Double amount;` |
| BR-AM-sala-con-32 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-confirm: | 32 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-sala-rec-26 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 26 | — | CAMPO_OBLIGATORIO | `@NotNull private String company;` |
| BR-AM-sala-rec-28 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 28 | — | CAMPO_OBLIGATORIO | `@NotNull private String requestNumber;` |
| BR-AM-sala-rec-30 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 30 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerRef1;` |
| BR-AM-sala-rec-32 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 32 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerRef2;` |
| BR-AM-sala-rec-50 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String phoneRef1;` |
| BR-AM-sala-rec-52 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private String phoneRef2;` |
| BR-AM-sala-rec-31 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 31 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-sala-rec-33 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 33 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-sala-rec-32-1 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 32 | — | CAMPO_OBLIGATORIO | `@NotEmpty @NotNull private String requestNumber;` |
| BR-AM-sala-rec-26-1 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 26 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-sala-rec-28-1 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 28 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-sala-rec-32-2 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 32 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-sala-rec-33-1 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 33 | — | CAMPO_OBLIGATORIO | `@NotNull private String company;` |
| BR-AM-sala-rec-35 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 35 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-sala-rec-37 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-sala-rec-39 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 39 | — | CAMPO_OBLIGATORIO | `@NotNull private String cellphoneNumber;` |
| BR-AM-sala-rec-41 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 41 | — | CAMPO_OBLIGATORIO | `@NotNull private String company2;` |
| BR-AM-sala-rec-32-3 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 32 | — | CAMPO_OBLIGATORIO | `@NotNull @NotEmpty private String cellphoneNumber;` |
| BR-AM-sala-rec-34 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 34 | — | CAMPO_OBLIGATORIO | `@NotNull @NotEmpty private String disposeAmount;` |
| BR-AM-sala-rec-25 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 25 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-sala-rec-27 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 27 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-sala-rec-29 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 29 | — | CAMPO_OBLIGATORIO | `@NotNull private String requestNumber;` |
| BR-AM-sala-rec-31-1 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 31 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer datePay;` |
| BR-AM-sala-rec-44 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 44 | — | CAMPO_OBLIGATORIO | `@NotNull private LocalDate dateOpen;` |
| BR-AM-sala-rec-46 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String firstName;` |
| BR-AM-sala-rec-48 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String lastName;` |
| BR-AM-sala-rec-50-1 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String gender;` |
| BR-AM-sala-rec-52-1 | NEGOCIO | Lending / Loans | msalo-b-business-salary-advance-receptio | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private String productNumber;` |
| BR-AM-cred-det-45-1 | NEGOCIO | Lending / Loans | msalo-d-domain-credit-loans-accounts-det | 45 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-cred-acc-54 | NEGOCIO | Lending / Loans | msalo-d-domain-credit-loans-accounts:Cre | 54 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-cust-val-61 | NEGOCIO | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 61 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-cust-val-67-1 | NEGOCIO | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 67 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String branch;` |
| BR-AM-cust-val-73 | NEGOCIO | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 73 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-cust-val-79 | NEGOCIO | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 79 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-cust-val-58-1 | NEGOCIO | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 58 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-cust-val-64 | NEGOCIO | Lending / Loans | msalo-d-domain-customer-loan-cash-dispos | 64 | — | CAMPO_OBLIGATORIO | `@NotNull private Double amount;` |
| BR-AM-digi-pro-37 | NEGOCIO | Lending / Loans | msalo-d-domain-digital-loan-provisioning | 37 | — | CAMPO_OBLIGATORIO | `@NotBlank private String companyNumber;` |
| BR-AM-digi-pro-38 | NEGOCIO | Lending / Loans | msalo-d-domain-digital-loan-provisioning | 38 | — | CAMPO_OBLIGATORIO | `@NotNull private String companyNumber;` |
| BR-AM-digi-pro-51 | NEGOCIO | Lending / Loans | msalo-d-domain-digital-loan-provisioning | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank private String deviceAccess;` |
| BR-AM-digi-pro-52-1 | NEGOCIO | Lending / Loans | msalo-d-domain-digital-loan-provisioning | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private String deviceAccess;` |
| BR-AM-digi-pro-58 | NEGOCIO | Lending / Loans | msalo-d-domain-digital-loan-provisioning | 58 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-digi-det-54 | NEGOCIO | Lending / Loans | msalo-d-domain-digital-loans-accounts-de | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-loan-b-65 | NEGOCIO | Lending / Loans | msalo-d-domain-loans-accounts-movements- | 65 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-loan-b-66 | NEGOCIO | Lending / Loans | msalo-d-domain-loans-accounts-movements- | 66 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-loan-b-78 | NEGOCIO | Lending / Loans | msalo-d-domain-loans-accounts-movements- | 78 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedPage;` |
| BR-AM-loan-b-83 | NEGOCIO | Lending / Loans | msalo-d-domain-loans-accounts-movements- | 83 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedRecordsNumber;` |
| BR-AM-loan-mov-48 | NEGOCIO | Lending / Loans | msalo-d-domain-loans-accounts-movements: | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String creditNumber;` |
| BR-AM-loan-mov-49 | NEGOCIO | Lending / Loans | msalo-d-domain-loans-accounts-movements: | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String creditNumber;` |
| BR-AM-loan-mov-60 | NEGOCIO | Lending / Loans | msalo-d-domain-loans-accounts-movements: | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedPage;` |
| BR-AM-loan-mov-65 | NEGOCIO | Lending / Loans | msalo-d-domain-loans-accounts-movements: | 65 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedRecordsNumber;` |
| BR-AM-sala-min-28 | NEGOCIO | Lending / Loans | msalo-p-security-salary-advance-minu:Con | 28 | — | CAMPO_OBLIGATORIO | `@NotNull private String amountPayment;` |
| BR-AM-sala-min-30 | NEGOCIO | Lending / Loans | msalo-p-security-salary-advance-minu:Con | 30 | — | CAMPO_OBLIGATORIO | `@NotNull private String dispersalDate;` |
| BR-AM-sala-min-32 | NEGOCIO | Lending / Loans | msalo-p-security-salary-advance-minu:Con | 32 | — | CAMPO_OBLIGATORIO | `@NotNull private String idOperation;` |
| BR-AM-sala-min-40 | NEGOCIO | Lending / Loans | msalo-p-security-salary-advance-minu:Val | 40 | — | CAMPO_OBLIGATORIO | `@NotNull private String dateOpen;` |
| BR-AM-sala-min-42 | NEGOCIO | Lending / Loans | msalo-p-security-salary-advance-minu:Val | 42 | — | CAMPO_OBLIGATORIO | `@NotNull private String firstName;` |
| BR-AM-sala-min-44 | NEGOCIO | Lending / Loans | msalo-p-security-salary-advance-minu:Val | 44 | — | CAMPO_OBLIGATORIO | `@NotNull private String lastName;` |
| BR-AM-sala-min-46 | NEGOCIO | Lending / Loans | msalo-p-security-salary-advance-minu:Val | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String gender;` |
| BR-AM-sala-min-48 | NEGOCIO | Lending / Loans | msalo-p-security-salary-advance-minu:Val | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String productNumber;` |
| BR-AM-send-b-43 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private String contractId;` |
| BR-AM-send-b-44 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 44 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String contractId;` |
| BR-AM-send-b-51 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 51 | — | CAMPO_OBLIGATORIO | `@NotNull private String templateId;` |
| BR-AM-send-b-52 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 52 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String templateId;` |
| BR-AM-send-b-65 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 65 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerEmail;` |
| BR-AM-send-b-66 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 66 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerEmail;` |
| BR-AM-send-b-79 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 79 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-send-b-80 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 80 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-send-b-87 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 87 | — | CAMPO_OBLIGATORIO | `@NotNull private MultipartFile file1;` |
| BR-AM-send-att-39 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 39 | — | CAMPO_OBLIGATORIO | `@NotNull private String contractId;` |
| BR-AM-send-att-40 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 40 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String contractId;` |
| BR-AM-send-att-46 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String templateId;` |
| BR-AM-send-att-47 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String templateId;` |
| BR-AM-send-att-58 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 58 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerEmail;` |
| BR-AM-send-att-59 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 59 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerEmail;` |
| BR-AM-send-att-70 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 70 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-send-att-71 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 71 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-send-att-77 | NEGOCIO | Messaging | msamg-d-business-send-messaging-attachme | 77 | — | CAMPO_OBLIGATORIO | `@NotNull private MultipartFile file1;` |
| BR-AM-copp-pay-10 | NEGOCIO | Payments | msapy-b-business-coppel-payment:DepositA | 10 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-copp-pay-11 | NEGOCIO | Payments | msapy-b-business-coppel-payment:DepositA | 11 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-copp-pay-47 | NEGOCIO | Payments | msapy-b-business-coppel-payment:Intraban | 47 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String originAccountNumber;` |
| BR-AM-copp-pay-48 | NEGOCIO | Payments | msapy-b-business-coppel-payment:Intraban | 48 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String originAccountNum` |
| BR-AM-copp-pay-59 | NEGOCIO | Payments | msapy-b-business-coppel-payment:Intraban | 59 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String destinationAccountNumber` |
| BR-AM-copp-pay-60 | NEGOCIO | Payments | msapy-b-business-coppel-payment:Intraban | 60 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String destinationAccou` |
| BR-AM-copp-pay-65 | NEGOCIO | Payments | msapy-b-business-coppel-payment:Intraban | 65 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private BigDecimal amount;` |
| BR-AM-copp-pay-26 | NEGOCIO | Payments | msapy-b-business-coppel-payment:Intraban | 26 | — | CAMPO_OBLIGATORIO | `@NotNull private String invoiceBranch;` |
| BR-AM-copp-pay-27 | NEGOCIO | Payments | msapy-b-business-coppel-payment:Intraban | 27 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String invoiceBranch;` |
| BR-AM-copp-pay-28 | NEGOCIO | Payments | msapy-b-business-coppel-payment:Intraban | 28 | — | CAMPO_OBLIGATORIO | `@NotBlank private String invoiceBranch;` |
| BR-AM-copp-pay-29 | NEGOCIO | Payments | msapy-b-business-coppel-payment:PaymentR | 29 | — | CAMPO_OBLIGATORIO | `@NotNull private BigInteger payAmount;` |
| BR-AM-copp-pay-35 | NEGOCIO | Payments | msapy-b-business-coppel-payment:PaymentR | 35 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String paymentFolio;` |
| BR-AM-copp-pay-41 | NEGOCIO | Payments | msapy-b-business-coppel-payment:PaymentR | 41 | — | CAMPO_OBLIGATORIO | `@NotNull private ArrayList<DebtsDetailsRequest> debtDetails;` |
| BR-AM-copp-pay-42 | NEGOCIO | Payments | msapy-b-business-coppel-payment:PaymentR | 42 | — | CAMPO_OBLIGATORIO | `@NotEmpty private ArrayList<DebtsDetailsRequest> debtDetails;` |
| BR-AM-copp-pay-54 | NEGOCIO | Payments | msapy-b-business-coppel-payment:PaymentR | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-copp-pay-60-1 | NEGOCIO | Payments | msapy-b-business-coppel-payment:PaymentR | 60 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumber;` |
| BR-AM-copp-pay-43 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 43 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String companyNumber;` |
| BR-AM-copp-pay-44 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 44 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String companyNumber;` |
| BR-AM-copp-pay-50 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 50 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String virtualBranch;` |
| BR-AM-copp-pay-51 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String virtualBranch;` |
| BR-AM-copp-pay-65-1 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 65 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String invoiceBranch;` |
| BR-AM-copp-pay-66 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 66 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String invoiceBranch;` |
| BR-AM-copp-pay-72 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 72 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "No puede ser nulo.") private String reversionType;` |
| BR-AM-copp-pay-73 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 73 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "No puede estar en blanco.") private String reversionType;` |
| BR-AM-copp-pay-27-1 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 27 | — | CAMPO_OBLIGATORIO | `@NotNull private String response;` |
| BR-AM-copp-pay-28-1 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 28 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String response;` |
| BR-AM-copp-pay-29-1 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ReversaT | 29 | — | CAMPO_OBLIGATORIO | `@NotBlank private String response;` |
| BR-AM-copp-pay-41-1 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ThirdPar | 41 | — | CAMPO_OBLIGATORIO | `@NotNull private String invoiceBranch;` |
| BR-AM-copp-pay-42-1 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ThirdPar | 42 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String invoiceBranch;` |
| BR-AM-copp-pay-43-1 | NEGOCIO | Payments | msapy-b-business-coppel-payment:ThirdPar | 43 | — | CAMPO_OBLIGATORIO | `@NotBlank private String invoiceBranch;` |
| BR-AM-remi-pay-36-2 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Clie | 36 | — | CAMPO_OBLIGATORIO | `@NotNull private String clientNumber;` |
| BR-AM-remi-pay-50-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Clie | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-remi-pay-57-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Clie | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String clientName;` |
| BR-AM-remi-pay-64-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Clie | 64 | — | CAMPO_OBLIGATORIO | `@NotNull private String birthDate;` |
| BR-AM-remi-pay-36 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Cust | 36 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-remi-pay-43-2 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Offi | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private String userName;` |
| BR-AM-remi-pay-50-2 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Offi | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String terminal;` |
| BR-AM-remi-pay-52-2 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Offi | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private String userNameReverse;` |
| BR-AM-remi-pay-59-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Offi | 59 | — | CAMPO_OBLIGATORIO | `@NotNull private String terminal;` |
| BR-AM-remi-pay-36-3 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Oper | 36 | — | CAMPO_OBLIGATORIO | `@NotNull private String code;` |
| BR-AM-remi-pay-53 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private String remittanceKey;` |
| BR-AM-remi-pay-54 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 54 | — | CAMPO_OBLIGATORIO | `@NotBlank private String remittanceKey;` |
| BR-AM-remi-pay-60 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 60 | — | CAMPO_OBLIGATORIO | `@NotNull private String invoiceBranch;` |
| BR-AM-remi-pay-61 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 61 | — | CAMPO_OBLIGATORIO | `@NotBlank private String invoiceBranch;` |
| BR-AM-remi-pay-67 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 67 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-remi-pay-73 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 73 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-remi-pay-74 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 74 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-remi-pay-37 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private String branchFolio;` |
| BR-AM-remi-pay-44 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 44 | — | CAMPO_OBLIGATORIO | `@NotNull private RemittanceRequest remittance;` |
| BR-AM-remi-pay-58 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 58 | — | CAMPO_OBLIGATORIO | `@NotNull private OfficeBranch branchOffice;` |
| BR-AM-remi-pay-65 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 65 | — | CAMPO_OBLIGATORIO | `@NotNull private String paymentDate;` |
| BR-AM-remi-pay-79 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Paym | 79 | — | CAMPO_OBLIGATORIO | `@NotNull private String sourceChannel;` |
| BR-AM-remi-pay-36-4 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Remi | 36 | — | CAMPO_OBLIGATORIO | `@NotNull private String typeRemittence;` |
| BR-AM-remi-pay-50-3 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Remi | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String remittenceAmount;` |
| BR-AM-remi-pay-57-2 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Remi | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String remitterName;` |
| BR-AM-remi-pay-43 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Remi | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private String remittanceAmount;` |
| BR-AM-remi-pay-52 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Remi | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private OfficeBranch branchOffice;` |
| BR-AM-remi-pay-59 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Remi | 59 | — | CAMPO_OBLIGATORIO | `@NotNull private String date;` |
| BR-AM-remi-pay-73-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Remi | 73 | — | CAMPO_OBLIGATORIO | `@NotNull private String originChannel;` |
| BR-AM-remi-pay-38 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Remi | 38 | — | CAMPO_OBLIGATORIO | `@NotNull private Remittance remittance;` |
| BR-AM-remi-pay-45 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Remi | 45 | — | CAMPO_OBLIGATORIO | `@NotNull private OperationResult operationResult;` |
| BR-AM-remi-pay-52-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Remi | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private String folioSuc;` |
| BR-AM-remi-pay-37-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Reve | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private String branchFolio;` |
| BR-AM-remi-pay-44-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Reve | 44 | — | CAMPO_OBLIGATORIO | `@NotNull private RemittanceRequest remittance;` |
| BR-AM-remi-pay-51 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Reve | 51 | — | CAMPO_OBLIGATORIO | `@NotNull private OfficeBranchReverse branchOffice;` |
| BR-AM-remi-pay-58-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Reve | 58 | — | CAMPO_OBLIGATORIO | `@NotNull private String reversetDate;` |
| BR-AM-remi-pay-72 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Reve | 72 | — | CAMPO_OBLIGATORIO | `@NotNull private String sourceChannel;` |
| BR-AM-remi-pay-37-2 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Vali | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private String remittanceKey;` |
| BR-AM-remi-pay-38-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Vali | 38 | — | CAMPO_OBLIGATORIO | `@NotBlank private String remittanceKey;` |
| BR-AM-remi-pay-36-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Vali | 36 | — | CAMPO_OBLIGATORIO | `@NotNull private String remittanceKey;` |
| BR-AM-remi-pay-43-1 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Vali | 43 | — | CAMPO_OBLIGATORIO | `@NotNull private String typeRemittance;` |
| BR-AM-remi-pay-50 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Vali | 50 | — | CAMPO_OBLIGATORIO | `@NotNull private String amount;` |
| BR-AM-remi-pay-57 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Vali | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String remitterName;` |
| BR-AM-remi-pay-64 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Vali | 64 | — | CAMPO_OBLIGATORIO | `@NotNull private String invoiceBranch;` |
| BR-AM-remi-pay-71 | NEGOCIO | Payments | msapy-b-business-remittance-payment:Vali | 71 | — | CAMPO_OBLIGATORIO | `@NotNull private String currentDate;` |
| BR-AM-codi-pay-60-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:Beneficiary | 60 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private Integer accountType;` |
| BR-AM-codi-pay-24 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 24 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_BE_NULL) private LocalDateTime fechaMov;` |
| BR-AM-codi-pay-36 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 36 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_BE_NULL) private String numCteOrigin;` |
| BR-AM-codi-pay-37 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 37 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.NOT_BE_EMPTY) private String numCteOrigin;` |
| BR-AM-codi-pay-50 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 50 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_BE_NULL) private BigDecimal ammount;` |
| BR-AM-codi-pay-56 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 56 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_BE_NULL) private String codOperation;` |
| BR-AM-codi-pay-57 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 57 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.NOT_BE_EMPTY) private String codOperation;` |
| BR-AM-codi-pay-63 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 63 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_BE_NULL) private String channel;` |
| BR-AM-codi-pay-64-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 64 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.NOT_BE_EMPTY) private String channel;` |
| BR-AM-codi-pay-70 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 70 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_BE_NULL) private String folioSuc;` |
| BR-AM-codi-pay-71 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 71 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.NOT_BE_EMPTY) private String folioSuc;` |
| BR-AM-codi-pay-30 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 30 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_BE_NULL) private String numAccountOrigin;` |
| BR-AM-codi-pay-31 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 31 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.NOT_BE_EMPTY) private String numAccountOrigin;` |
| BR-AM-codi-pay-37-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 37 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_BE_NULL) private BigDecimal ammount;` |
| BR-AM-codi-pay-43 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 43 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NOT_BE_NULL) private String channel;` |
| BR-AM-codi-pay-44 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiLimitTra | 44 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.NOT_BE_EMPTY) private String channel;` |
| BR-AM-codi-pay-50-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 50 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String branch;` |
| BR-AM-codi-pay-56-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 56 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String transCargo;` |
| BR-AM-codi-pay-59-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 59 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String transAbono;` |
| BR-AM-codi-pay-62 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 62 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String branchTrans;` |
| BR-AM-codi-pay-65-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 65 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String originCustomerNumber;` |
| BR-AM-codi-pay-68 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 68 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String originAccountNumber;` |
| BR-AM-codi-pay-71-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 71 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String destinationAccountNumber;` |
| BR-AM-codi-pay-83 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 83 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-codi-pay-92-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 92 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal totalAmount;` |
| BR-AM-codi-pay-95 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 95 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal firmAmount;` |
| BR-AM-codi-pay-98 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 98 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal sbcAmount;` |
| BR-AM-codi-pay-101 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 101 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal remAmount;` |
| BR-AM-codi-pay-104 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 104 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private Integer retDays;` |
| BR-AM-codi-pay-110 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 110 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String transferType;` |
| BR-AM-codi-pay-111 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 111 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String transferType;` |
| BR-AM-codi-pay-120 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 120 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String dateMessageCharge;` |
| BR-AM-codi-pay-121 | NEGOCIO | Payments | msapy-d-domain-codi-payment:CodiPaymentR | 121 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String dateMessageCharge;` |
| BR-AM-codi-pay-54 | NEGOCIO | Payments | msapy-d-domain-codi-payment:InterbankInf | 54 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal ivaComission;` |
| BR-AM-codi-pay-57-1 | NEGOCIO | Payments | msapy-d-domain-codi-payment:InterbankInf | 57 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal ivaAmount;` |
| BR-AM-codi-pay-64-2 | NEGOCIO | Payments | msapy-d-domain-codi-payment:InterbankInf | 64 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String paymentType;` |
| BR-AM-codi-pay-71-2 | NEGOCIO | Payments | msapy-d-domain-codi-payment:InterbankInf | 71 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private String invoiceIdc;` |
| BR-AM-codi-pay-72 | NEGOCIO | Payments | msapy-d-domain-codi-payment:InterbankInf | 72 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotEmpty private String invoiceIdc;` |
| BR-AM-codi-pay-49 | NEGOCIO | Payments | msapy-d-domain-codi-payment:Remitter | 49 | Banxico CoDi — Circular 14/2017 Banxico CoDi | CAMPO_OBLIGATORIO | `@NotNull private Integer accountType;` |
| BR-AM-inte-pay-66 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 66 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private String originAccountNumber` |
| BR-AM-inte-pay-67 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 67 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.CAN_NOT_BE_EMPTY) private String originAccountNumb` |
| BR-AM-inte-pay-74 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 74 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private String originCustomerNumbe` |
| BR-AM-inte-pay-75 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 75 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.CAN_NOT_BE_EMPTY) private String originCustomerNum` |
| BR-AM-inte-pay-82 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 82 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private BigDecimal paymentAmount;` |
| BR-AM-inte-pay-88 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 88 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private BigDecimal totalAmount;` |
| BR-AM-inte-pay-94 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 94 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private BigDecimal firmAmount;` |
| BR-AM-inte-pay-100 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 100 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private String virtualBranch;` |
| BR-AM-inte-pay-101 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 101 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.CAN_NOT_BE_EMPTY) private String virtualBranch;` |
| BR-AM-inte-pay-114 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 114 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private String cargoTransaction;` |
| BR-AM-inte-pay-115 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 115 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.CAN_NOT_BE_EMPTY) private String cargoTransaction;` |
| BR-AM-inte-pay-121 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 121 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private String creditTransaction;` |
| BR-AM-inte-pay-122 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 122 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.CAN_NOT_BE_EMPTY) private String creditTransaction` |
| BR-AM-inte-pay-135 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 135 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private String branchTransaction;` |
| BR-AM-inte-pay-147 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 147 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private String currencyType;` |
| BR-AM-inte-pay-148 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 148 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.CAN_NOT_BE_EMPTY) private String currencyType;` |
| BR-AM-inte-pay-160 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 160 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private BigDecimal sbcAmount;` |
| BR-AM-inte-pay-166 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 166 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private BigDecimal remittanceAmoun` |
| BR-AM-inte-pay-184 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 184 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private String reversionType;` |
| BR-AM-inte-pay-185 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 185 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.CAN_NOT_BE_EMPTY) private String reversionType;` |
| BR-AM-inte-pay-191 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 191 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.CAN_NOT_BE_NULL) private String destinationCreditCa` |
| BR-AM-inte-pay-192 | NEGOCIO | Payments | msapy-d-domain-interbank-card-payment:Ap | 192 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.CAN_NOT_BE_EMPTY) private String destinationCredit` |
| BR-AM-intr-pay-53-1 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private String virtualBranch;` |
| BR-AM-intr-pay-55 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String virtualBranch;` |
| BR-AM-intr-pay-73 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 73 | — | CAMPO_OBLIGATORIO | `@NotNull private String debtorTransaction;` |
| BR-AM-intr-pay-74 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 74 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String debtorTransaction;` |
| BR-AM-intr-pay-85 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 85 | — | CAMPO_OBLIGATORIO | `@NotNull private String originAccountNumber;` |
| BR-AM-intr-pay-86 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 86 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-intr-pay-92 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 92 | — | CAMPO_OBLIGATORIO | `@NotNull private String destinationCreditAccountNumber;` |
| BR-AM-intr-pay-93 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 93 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationCreditAccountNumber;` |
| BR-AM-intr-pay-105 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 105 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal paymentAmount;` |
| BR-AM-intr-pay-112 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 112 | — | CAMPO_OBLIGATORIO | `@NotNull private String currencyType;` |
| BR-AM-intr-pay-113 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 113 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String currencyType;` |
| BR-AM-intr-pay-134 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 134 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer paymentType;` |
| BR-AM-intr-pay-160 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 160 | — | CAMPO_OBLIGATORIO | `@NotNull private String originCustomerNumber;` |
| BR-AM-intr-pay-161 | NEGOCIO | Payments | msapy-d-domain-intrabank-card-payment:In | 161 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originCustomerNumber;` |
| BR-AM-serv-ope-41 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 41 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountNumber;` |
| BR-AM-serv-ope-54 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 54 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-serv-ope-38 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 38 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-serv-ope-44 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 44 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String virtualBranch;` |
| BR-AM-serv-ope-56 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 56 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String invoiceBranch;` |
| BR-AM-serv-ope-62-1 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 62 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String reversionType;` |
| BR-AM-serv-ope-28 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 28 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationAccountNumber;` |
| BR-AM-serv-ope-42 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 42 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amountAll;` |
| BR-AM-serv-ope-49 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 49 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal firmAmount;` |
| BR-AM-serv-ope-56-1 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amountSbc;` |
| BR-AM-serv-ope-63 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 63 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amountRem;` |
| BR-AM-serv-ope-20 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 20 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-serv-ope-27 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 27 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-serv-ope-34 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 34 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String virtualBranch;` |
| BR-AM-serv-ope-48 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 48 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String transactionNumber;` |
| BR-AM-serv-ope-55 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 55 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String branchTransaction;` |
| BR-AM-serv-ope-68 | NEGOCIO | Payments | msapy-d-domain-services-payment-transact | 68 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String currencyType;` |
| BR-AM-serv-pay-49 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 49 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "originCustomerNumber no puede ser vació/nulo.") private Str` |
| BR-AM-serv-pay-63 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 63 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "virtualBranch no puede ser vació/nulo.") private String vir` |
| BR-AM-serv-pay-77 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 77 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "transCarg no puede ser vació/nulo.") private String cargoTr` |
| BR-AM-serv-pay-84 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 84 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "transPayment no puede ser vació/nulo.") private String abon` |
| BR-AM-serv-pay-91 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 91 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "transBranch no puede ser nulo.") private String branchTransa` |
| BR-AM-serv-pay-98 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 98 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "originAccountNumber no puede ser vació/nulo.") private Stri` |
| BR-AM-serv-pay-105 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 105 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "destinationAccountNumber no puede ser vació/nulo.") private` |
| BR-AM-serv-pay-119 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 119 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "amount no puede ser nulo.") private BigDecimal amount;` |
| BR-AM-serv-pay-140 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 140 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "numCardOrigin no puede ser nulo.") private String originCard` |
| BR-AM-serv-pay-147 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 147 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "numCardDestination no puede ser nulo.") private String desti` |
| BR-AM-serv-pay-161 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 161 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "amountAll no puede ser nulo.") private BigDecimal totalAmoun` |
| BR-AM-serv-pay-168 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 168 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "amountFirme no puede ser nulo.") private BigDecimal firmAmou` |
| BR-AM-serv-pay-175 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 175 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "amountSBS no puede ser nulo.") private BigDecimal sbcAmount;` |
| BR-AM-serv-pay-182 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 182 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "amountRem no puede ser nulo.") private BigDecimal remAmount;` |
| BR-AM-serv-pay-189 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 189 | — | CAMPO_OBLIGATORIO | `@NotNull(message = "daysRet no puede ser nulo.") private Integer retDays;` |
| BR-AM-serv-pay-238 | NEGOCIO | Payments | msapy-d-domain-services-payment:Services | 238 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = "paymentType no puede ser vació/nulo.") private String payme` |
| BR-AM-card-inf-47 | NEGOCIO | Services / ATM | msasr-b-business-cardless-withdrawal-inf | 47 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.NO_NULL) private String cardNumber;` |
| BR-AM-card-inf-48 | NEGOCIO | Services / ATM | msasr-b-business-cardless-withdrawal-inf | 48 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.NOT_BLANK) private String cardNumber;` |
| BR-AM-dire-man-67 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 67 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String activationInvoice;` |
| BR-AM-dire-man-72 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 72 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal maxAmount;` |
| BR-AM-dire-man-78 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 78 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String paymentType;` |
| BR-AM-dire-man-79 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 79 | — | CAMPO_OBLIGATORIO | `@NotBlank private String paymentType;` |
| BR-AM-dire-man-85 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 85 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal amount;` |
| BR-AM-dire-man-91 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 91 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String paymentDate;` |
| BR-AM-dire-man-92 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 92 | — | CAMPO_OBLIGATORIO | `@NotBlank private String paymentDate;` |
| BR-AM-dire-man-99 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 99 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String destinationCardNumber;` |
| BR-AM-dire-man-100 | NEGOCIO | Services / ATM | msasr-b-business-direct-debit-process-ma | 100 | — | CAMPO_OBLIGATORIO | `@NotBlank private String destinationCardNumber;` |
| BR-AM-eval-dat-32 | NEGOCIO | Services / ATM | msasr-b-serv-evaluate-portability-data:P | 32 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccount;` |
| BR-AM-card-mov-52 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 52 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumber;` |
| BR-AM-card-mov-58 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 58 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String status;` |
| BR-AM-card-mov-80 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 80 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedPage;` |
| BR-AM-card-mov-87 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 87 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedRecordsNumber;` |
| BR-AM-card-mov-51 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumber;` |
| BR-AM-card-mov-57 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 57 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String status;` |
| BR-AM-card-mov-75 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 75 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedPage;` |
| BR-AM-card-mov-81 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal-mov | 81 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedRecordsNumber;` |
| BR-AM-card-wit-40 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 40 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private String invoiceBranch;` |
| BR-AM-card-wit-41 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 41 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_MUST_NOT_BE_EMPTY) private String invoiceBranc` |
| BR-AM-card-wit-42 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 42 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_MUST_NOT_BE_BLANK) private String invoiceBranc` |
| BR-AM-card-wit-48 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 48 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private String codeOtp;` |
| BR-AM-card-wit-49 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_MUST_NOT_BE_EMPTY) private String codeOtp;` |
| BR-AM-card-wit-50 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 50 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_MUST_NOT_BE_BLANK) private String codeOtp;` |
| BR-AM-card-wit-45 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 45 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private String cardNumber;` |
| BR-AM-card-wit-46 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_MUST_NOT_BE_EMPTY) private String cardNumber;` |
| BR-AM-card-wit-47 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 47 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_MUST_NOT_BE_BLANK) private String cardNumber;` |
| BR-AM-card-wit-53 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 53 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private String accountNumber;` |
| BR-AM-card-wit-54 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty(message = Constants.MSG_MUST_NOT_BE_EMPTY) private String accountNumbe` |
| BR-AM-card-wit-55 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 55 | — | CAMPO_OBLIGATORIO | `@NotBlank(message = Constants.MSG_MUST_NOT_BE_BLANK) private String accountNumbe` |
| BR-AM-card-wit-61 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 61 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private BigDecimal minAmount;` |
| BR-AM-card-wit-70 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 70 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private BigDecimal maxAmount;` |
| BR-AM-card-wit-79 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 79 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private BigDecimal amount;` |
| BR-AM-card-wit-111 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Car | 111 | — | CAMPO_OBLIGATORIO | `@NotNull(message = Constants.MSG_MUST_NOT_BE_NULL) private Integer activeCode;` |
| BR-AM-card-wit-56 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Dep | 56 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal currentBalance;` |
| BR-AM-card-wit-63 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Dep | 63 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal retainedBalance;` |
| BR-AM-card-wit-70-1 | NEGOCIO | Services / ATM | msasr-d-business-cardless-withdrawal:Dep | 70 | — | CAMPO_OBLIGATORIO | `@NotNull private BigDecimal frozenBalance;` |
| BR-AM-capt-ope-66 | NEGOCIO | Services / ATM | msasr-d-domain-captureline-operations:De | 66 | — | CAMPO_OBLIGATORIO | `@NotNull private String amount;` |
| BR-AM-capt-ope-80 | NEGOCIO | Services / ATM | msasr-d-domain-captureline-operations:De | 80 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-card-b-48 | NEGOCIO | Services / ATM | msasr-d-domain-cards-status-options-b:Ca | 48 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumber;` |
| BR-AM-card-b-53 | NEGOCIO | Services / ATM | msasr-d-domain-cards-status-options-b:Ca | 53 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumber;` |
| BR-AM-card-b-61 | NEGOCIO | Services / ATM | msasr-d-domain-cards-status-options-b:Ca | 61 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardStatus;` |
| BR-AM-card-b-67 | NEGOCIO | Services / ATM | msasr-d-domain-cards-status-options-b:Ca | 67 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-cvv-car-53 | NEGOCIO | Services / ATM | msasr-d-domain-cvv-client-cards:CvvClien | 53 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-cvv-car-54 | NEGOCIO | Services / ATM | msasr-d-domain-cvv-client-cards:CvvClien | 54 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-cvv-reg-55 | NEGOCIO | Services / ATM | msasr-d-domain-cvv-client-register:Regis | 55 | PCI-DSS — PCI-DSS v4.0 Datos de tarjeta | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-dire-man-45 | NEGOCIO | Services / ATM | msasr-d-domain-direct-debit-management:D | 45 | — | CAMPO_OBLIGATORIO | `@NotNull private String companyNumber;` |
| BR-AM-dire-man-46 | NEGOCIO | Services / ATM | msasr-d-domain-direct-debit-management:D | 46 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String companyNumber;` |
| BR-AM-dire-man-49 | NEGOCIO | Services / ATM | msasr-d-domain-direct-debit-management:D | 49 | — | CAMPO_OBLIGATORIO | `@NotNull private String applicationNumber;` |
| BR-AM-dire-man-50 | NEGOCIO | Services / ATM | msasr-d-domain-direct-debit-management:D | 50 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String applicationNumber;` |
| BR-AM-dire-man-53 | NEGOCIO | Services / ATM | msasr-d-domain-direct-debit-management:D | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private String productNumber;` |
| BR-AM-dire-man-54 | NEGOCIO | Services / ATM | msasr-d-domain-direct-debit-management:D | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String productNumber;` |
| BR-AM-dire-man-57 | NEGOCIO | Services / ATM | msasr-d-domain-direct-debit-management:D | 57 | — | CAMPO_OBLIGATORIO | `@NotNull private String associatedAccount;` |
| BR-AM-dire-man-58 | NEGOCIO | Services / ATM | msasr-d-domain-direct-debit-management:D | 58 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String associatedAccount;` |
| BR-AM-dire-man-61 | NEGOCIO | Services / ATM | msasr-d-domain-direct-debit-management:D | 61 | — | CAMPO_OBLIGATORIO | `@NotNull private String registrationStatus;` |
| BR-AM-dire-man-62 | NEGOCIO | Services / ATM | msasr-d-domain-direct-debit-management:D | 62 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String registrationStatus;` |
| BR-AM-freq-b-41 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 41 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-freq-b-47 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 47 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-freq-b-43 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 43 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-freq-b-49 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 49 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-freq-b-55 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 55 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountKey;` |
| BR-AM-freq-b-67 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 67 | — | CAMPO_OBLIGATORIO | `@NotBlank private String alias;` |
| BR-AM-freq-b-73 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 73 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountName;` |
| BR-AM-freq-b-79 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 79 | — | CAMPO_OBLIGATORIO | `@NotNull private FrequentAccountStatus status;` |
| BR-AM-freq-b-42 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 42 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-freq-b-48 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 48 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-freq-b-50 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts-b:Frequ | 50 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-freq-acc-43 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 43 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-freq-acc-49 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 49 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-freq-acc-45-2 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 45 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-freq-acc-51-2 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 51 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-freq-acc-57-2 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 57 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountKey;` |
| BR-AM-freq-acc-69-1 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 69 | — | CAMPO_OBLIGATORIO | `@NotBlank private String alias;` |
| BR-AM-freq-acc-75-1 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 75 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountName;` |
| BR-AM-freq-acc-81-1 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 81 | — | CAMPO_OBLIGATORIO | `@NotNull private FrequentAccountStatus status;` |
| BR-AM-freq-acc-44 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 44 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-freq-acc-50 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 50 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-freq-acc-52 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-accounts:Frequen | 52 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerNumber;` |
| BR-AM-freq-acc-47 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 47 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originCustomerNumber;` |
| BR-AM-freq-acc-53-1 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 53 | — | CAMPO_OBLIGATORIO | `@NotNull private String originCustomerNumber;` |
| BR-AM-freq-acc-54 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 54 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originCustomerNumber;` |
| BR-AM-freq-acc-58-2 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 58 | — | CAMPO_OBLIGATORIO | `@NotNull private String idAccount;` |
| BR-AM-freq-acc-59 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 59 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String idAccount;` |
| BR-AM-freq-acc-47-1 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 47 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originCustomerNumber;` |
| BR-AM-freq-acc-53-2 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 53 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-freq-acc-47-2 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 47 | — | CAMPO_OBLIGATORIO | `@NotBlank private String originCustomerNumber;` |
| BR-AM-freq-acc-53-3 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 53 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-freq-acc-65 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 65 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountName;` |
| BR-AM-freq-acc-71 | NEGOCIO | Services / ATM | msasr-d-domain-frequent-service-accounts | 71 | — | CAMPO_OBLIGATORIO | `@NotBlank private String customerName;` |
| BR-AM-serv-val-46 | NEGOCIO | Services / ATM | msasr-d-domain-services-payment-validati | 46 | — | CAMPO_OBLIGATORIO | `@NotBlank private String accountNumber;` |
| BR-AM-serv-ope-23 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 23 | — | CAMPO_OBLIGATORIO | `@NotNull private String invoiceBranch;` |
| BR-AM-serv-ope-24 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 24 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String invoiceBranch;` |
| BR-AM-serv-ope-30 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 30 | — | CAMPO_OBLIGATORIO | `@NotNull private String transactionId;` |
| BR-AM-serv-ope-31 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 31 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String transactionId;` |
| BR-AM-serv-ope-39 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 39 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-serv-ope-40 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 40 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-serv-ope-48-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 48 | — | CAMPO_OBLIGATORIO | `@NotNull private String channel;` |
| BR-AM-serv-ope-49-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 49 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String channel;` |
| BR-AM-serv-ope-20-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 20 | — | CAMPO_OBLIGATORIO | `@NotNull private String transactionId;` |
| BR-AM-serv-ope-21 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 21 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String transactionId;` |
| BR-AM-serv-ope-25 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 25 | — | CAMPO_OBLIGATORIO | `@NotNull private String channel;` |
| BR-AM-serv-ope-26 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 26 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String channel;` |
| BR-AM-serv-ope-28-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 28 | — | CAMPO_OBLIGATORIO | `@NotNull private String customerNumber;` |
| BR-AM-serv-ope-29 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 29 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-serv-ope-33-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 33 | — | CAMPO_OBLIGATORIO | `@NotNull private String accountNumber;` |
| BR-AM-serv-ope-34-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 34 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String accountNumber;` |
| BR-AM-serv-ope-37 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 37 | — | CAMPO_OBLIGATORIO | `@NotNull private String cardNumber;` |
| BR-AM-serv-ope-38-1 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 38 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumber;` |
| BR-AM-serv-ope-46 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String applicationDate;` |
| BR-AM-serv-ope-52 | NEGOCIO | Services / ATM | msasr-d-domain-services-transaction-oper | 52 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer activeCode;` |
| BR-AM-tran-con-39 | NEGOCIO | Services / ATM | msasr-d-domain-transaction-operation-con | 39 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String channel;` |
| BR-AM-tran-mov-43 | NEGOCIO | Services / ATM | msasr-d-domain-transaction-operation-mov | 43 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String customerNumber;` |
| BR-AM-tran-mov-51 | NEGOCIO | Services / ATM | msasr-d-domain-transaction-operation-mov | 51 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String cardNumber;` |
| BR-AM-tran-mov-59 | NEGOCIO | Services / ATM | msasr-d-domain-transaction-operation-mov | 59 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String status;` |
| BR-AM-tran-mov-72 | NEGOCIO | Services / ATM | msasr-d-domain-transaction-operation-mov | 72 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedPage;` |
| BR-AM-tran-mov-79 | NEGOCIO | Services / ATM | msasr-d-domain-transaction-operation-mov | 79 | — | CAMPO_OBLIGATORIO | `@NotNull private Integer requestedRecordsNumber;` |
| BR-AM-bank-dat-47 | NEGOCIO | Services / ATM | msasr-d-serv-bank-data:PortabilityBankRe | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String bankAccount;` |
| BR-AM-clie-dat-46 | NEGOCIO | Services / ATM | msasr-d-serv-client-data:PortabilityPaye | 46 | — | CAMPO_OBLIGATORIO | `@NotNull private String originAccount;` |
| BR-AM-clie-dat-47 | NEGOCIO | Services / ATM | msasr-d-serv-client-data:PortabilityPaye | 47 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccount;` |
| BR-AM-proc-dat-37 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 37 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String company;` |
| BR-AM-proc-dat-44 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 44 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String transactionNumber;` |
| BR-AM-proc-dat-50 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 50 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String branchOffice;` |
| BR-AM-proc-dat-64 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 64 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originBankCode;` |
| BR-AM-proc-dat-71 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 71 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccount;` |
| BR-AM-proc-dat-78-1 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 78 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String originAccountType;` |
| BR-AM-proc-dat-84 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 84 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String receivingBankCode;` |
| BR-AM-proc-dat-98 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 98 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String receivingAccountType;` |
| BR-AM-proc-dat-104 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 104 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String transactionDate;` |
| BR-AM-proc-dat-110 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 110 | — | CAMPO_OBLIGATORIO | `@NotNull private String companyRfc;` |
| BR-AM-proc-dat-123 | NEGOCIO | Services / ATM | msasr-d-serv-processing-data:Portability | 123 | — | CAMPO_OBLIGATORIO | `@NotEmpty private String portabilityStatus;` |

---

## Notas de Migración

### Riesgos de Equivalencia Detectados

| ID | Riesgo |
|----|--------|
| BR-AM-cred-det-366 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-cred-det-73 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-amor-inf-531 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-cust-dat-163 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cust-sta-113 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cust-sta-194 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cust-sta-257 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-appl-tra-151 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-depo-mov-191 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-depo-acc-113 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-depo-acc-207 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-inve-ope-145 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-prom-mov-158 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-digi-pro-164 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-serv-pay-198 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-dire-man-229 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-freq-acc-136 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-freq-acc-93 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-freq-acc-183 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-freq-acc-201 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-serv-ope-86 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-codi-dev-prop-29 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cred-b-prop-49 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cred-mov-prop-24 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cred-mov-prop-28 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cred-det-prop-26 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cred-b-prop-12 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-tran-acc-prop-23 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-inte-pay-65 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-serv-b-22 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-serv-b-32 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-serv-b-37 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-serv-b-prop-60 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-serv-pay-prop-33 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cred-det-prop-110 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cust-b-prop-68 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cust-dat-prop-45 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cust-pro-prop-18 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cust-dat-prop-128 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-appl-tra-prop-66 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-appl-tra-prop-119 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-depo-mov-prop-28 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-depo-acc-prop-125 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-inve-ope-prop-131 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-prom-b-87 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-prom-mov-prop-49 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-prom-acc-prop-130 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cust-val-prop-146 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-digi-pro-prop-122 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-loan-mov-prop-58 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-codi-pay-prop-105 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-intr-pay-106 | BigDecimal→double conversión: riesgo de redondeo financiero |
| BR-AM-intr-pay-prop-40 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-serv-ope-prop-145 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-serv-pay-prop-29 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-capt-ope-prop-50 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-codi-opt-prop-116 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-cvv-car-prop-80 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-freq-acc-prop-120 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-freq-acc-prop-10 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-serv-val-prop-41 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-serv-val-prop-10 | Timeout: valor hardcoded en properties; target debe respetar mismo valor |
| BR-AM-codi-pay-prop-87 | SP crítico cargo_ref/abono_ref: semántica contable; requiere equivalencia funcional |
| BR-AM-codi-pay-prop-88 | SP crítico cargo_ref/abono_ref: semántica contable; requiere equivalencia funcional |

---

## Pendiente — Enriquecimiento business_name (ADR-SPE-AM-010)

Todas las reglas tienen `business_name = null`. El swarm de enriquecimiento LLM debe:
1. Leer cada regla desde `brain.db::rules`
2. Sintetizar el `business_name` en español de negocio (no código técnico)
3. Registrar cada cambio en `rule_enrichment_log` con `method='llm-synthesis'`
4. Gate de calidad: `COUNT(*) WHERE business_name IS NULL = 0` antes de entregar el catálogo

*Generado por `generators/extract-rules-java.py` · 2026-08-14 · v1.0.0*
*Ancla metodológica: extract-rules-v2.py (Informix) + ADR-SPE-AM-009 + ADR-SPE-AM-010*