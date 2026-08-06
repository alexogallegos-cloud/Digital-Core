# BCOPCore · Auditoría Exhaustiva del Vocabulario — Falsos Positivos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 · **Generado:** 2026-07-06 por `audit-vocab.py`  
> Analizados 6,210 tokens crudos únicos del corpus (nombres + parámetros).

Caza tokens del vocabulario que se interpretan mal por la **segmentación greedy** — igual que `ini`→re**ini**cia, `nomina`→deno**mina**ción, `pase` mal definido. Dos análisis:

---

## A · Tokens que aparecen MÁS como fragmento que como término propio

Estos tokens del vocab matchean dentro de palabras más largas la mayoría de las veces → probable falso positivo. `exact` = veces como token propio · `substr` = veces como fragmento interno.

| Token | Sig. actual | exact | substr | % frag | Aparece dentro de (ejemplos) | Acción sugerida |
|-------|-------------|------:|-------:|-------:|------------------------------|-----------------|
| `id` | identificador (de) | 116 | 3471 | 97% | idfuncion×2103, idusuario×71, idoficio×45, idconsulta×44 | revisar / agregar palabras contenedoras |
| `ro` | ro — Rol Operativo (subsiste | 75 | 1779 | 96% | registros×532, producto×142, productos×25, error×24 | revisar / agregar palabras contenedoras |
| `con` | consulta | 29 | 1695 | 98% | consulta×104, convenio×57, cons×51, idconsulta×44 | revisar / agregar palabras contenedoras |
| `os` | OS — Originación de Solicitu | 3 | 1639 | 100% | registros×532, foliosuc×38, productos×25, tiposucursal×18 | revisar / agregar palabras contenedoras |
| `num` | número (de) | 122 | 1422 | 92% | numcte×306, numcliente×132, numcredito×90, numcuenta×67 | revisar / agregar palabras contenedoras |
| `cons` | consulta | 51 | 1290 | 96% | consulta×104, idconsulta×44, tipoconsulta×32, fechaconsulta× | revisar / agregar palabras contenedoras |
| `fecha` | fecha | 314 | 1208 | 79% | fechafin×273, fechainicio×181, fechafinal×95, fechainicial×9 | revisar / agregar palabras contenedoras |
| `mc` | mc — Mesa de Control (abrevi | 70 | 871 | 93% | numcte×306, numcliente×132, numcredito×90, numcuenta×67 | revisar / agregar palabras contenedoras |
| `rec` | recepción / recibe | 2 | 796 | 100% | recuperacion×525, direccionmac×51, direcc×8, nombrecliente×8 | revisar / agregar palabras contenedoras |
| `reg` | registro | 14 | 743 | 98% | registros×532, registra×23, numregistro×12, regordenctecte×1 | revisar / agregar palabras contenedoras |
| `emp` | Empresa — empleadora del cli | 1 | 734 | 100% | empresa×567, numempleado×34, empleado×11, eempresa×10 | revisar / agregar palabras contenedoras |
| `cte` | cliente | 32 | 667 | 95% | numcte×306, ctetitular×14, ctes×12, regordenctecte×10 | revisar / agregar palabras contenedoras |
| `suc` | sucursal | 24 | 658 | 96% | sucursal×348, foliosuc×38, idsucursal×26, numsucursal×20 | revisar / agregar palabras contenedoras |
| `tipo` | tipo de | 173 | 625 | 78% | tipooperacion×34, tipoconsulta×32, tiporeporte×32, tipoejecu | revisar / agregar palabras contenedoras |
| `nom` | nómina | 24 | 573 | 96% | nombrearchivo×98, nombre×53, nombre1×25, nombre2×23 | revisar / agregar palabras contenedoras |
| `cc` | cc — cuenta corriente (sp_*_ | 33 | 525 | 94% | direccionmac×51, transaccion×33, transacc×27, ccl×13 | revisar / agregar palabras contenedoras |
| `cre` | crédito | 27 | 524 | 95% | numcredito×90, credito×49, cred×37, numcred×24 | revisar / agregar palabras contenedoras |
| `por` | por (criterio) | 6 | 516 | 99% | importe×53, reporte×37, tiporeporte×32, tiporev×11 | revisar / agregar palabras contenedoras |
| `gen` | genera / general | 10 | 476 | 98% | origen×51, genera×20, genrep×18, agent×14 | revisar / agregar palabras contenedoras |
| `rep` | reporte | 46 | 454 | 91% | reporte×37, tiporeporte×32, genrep×18, consultainforeportebc | revisar / agregar palabras contenedoras |
| `ant` | anterior | 4 | 447 | 99% | tituloplantilla×35, idplantilla×30, cantidad×8, plantilla×8 | revisar / agregar palabras contenedoras |
| `arch` | archivo | 16 | 434 | 96% | nombrearchivo×98, archivo×30, archdescarga×18, rutaarchivo×1 | revisar / agregar palabras contenedoras |
| `tar` | Tarjeta (abreviación — bdich | 2 | 417 | 100% | numtarjeta×65, tarjeta×52, comentario×9, numtarjetaorigen×9 | revisar / agregar palabras contenedoras |
| `act` | actualiza | 2 | 378 | 99% | actualiza×20, actividad×13, fechaactual×8, ctetraspasactas×6 | revisar / agregar palabras contenedoras |
| `sol` | solicitud | 23 | 377 | 94% | numsolicitud×46, solicitud×37, numsol×31, idsolicitud×17 | revisar / agregar palabras contenedoras |
| `cta` | cuenta | 42 | 375 | 90% | numcta×17, dictamen×9, numctaorigen×9, numctadestino×9 | revisar / agregar palabras contenedoras |
| `cred` | crédito | 37 | 372 | 91% | numcredito×90, credito×49, numcred×24, aumlincred×10 | revisar / agregar palabras contenedoras |
| `chi` | CHI — formato/protocolo de c | 0 | 362 | 100% | nombrearchivo×98, archivo×30, rutaarchivo×13, snombrearchivo | ⚠ quitar o acortar alcance |
| `cod` | código | 14 | 342 | 96% | codigo×55, code×25, codproveedor×11, retcode×10 | revisar / agregar palabras contenedoras |
| `status` | estatus | 138 | 334 | 71% | estatus×48, statustoken×8, fusionstatus×5, statusinicial×5 | revisar / agregar palabras contenedoras |
| `prod` | producto | 17 | 333 | 95% | producto×142, productos×25, numproducto×22, numprod×10 | revisar / agregar palabras contenedoras |
| `nombre` | nombre | 53 | 323 | 86% | nombrearchivo×98, nombre1×25, nombre2×23, nombreref×16 | revisar / agregar palabras contenedoras |
| `total` | total | 16 | 317 | 95% | totales×212, montototal×7, totalsolicitudes×3, capitaltotal× | revisar / agregar palabras contenedoras |
| `cuenta` | cuenta | 194 | 305 | 61% | numcuenta×67, sistemacuenta×33, numerocuenta×19, cuentas×14 | revisar / agregar palabras contenedoras |
| `com` | Comisión bancaria — cobro de | 2 | 270 | 99% | comision×15, comentario×9, fideicomiso×7, complemento×6 | revisar / agregar palabras contenedoras |
| `trans` | [polisemia] Transferencia (b | 23 | 269 | 92% | transaccion×33, transacc×27, transfer×10, transuc×10 | revisar / agregar palabras contenedoras |
| `ss` | ss — subsistema / canal de m | 1 | 251 | 100% | process×18, issuer×13, macaddress×11, transsuc×10 | revisar / agregar palabras contenedoras |
| `sac` | Servicios de Atención al Cli | 60 | 246 | 80% | transaccion×33, transacc×27, transac×7, transaciva×6 | revisar / agregar palabras contenedoras |
| `cat` | catálogo | 18 | 244 | 93% | categoria×13, iccat×8, sucatm×5, idcatalogo×4 | revisar / agregar palabras contenedoras |
| `solic` | solicitud | 5 | 235 | 98% | numsolicitud×46, solicitud×37, idsolicitud×17, solicitudes×7 | revisar / agregar palabras contenedoras |

---

## B · Tokens del corpus con segmentación sospechosa

Tokens crudos donde un átomo corto deja un fragmento largo sin reconocer → probable **palabra real partida mal** (candidata a agregar completa al vocabulario).

| Token crudo | Frec | Segmentación actual | Palabra(s) real(es) probable(s) |
|-------------|-----:|---------------------|--------------------------------|
| `userinsert` | 11 | ¿user? · ins · ¿ert? | user, ert |
| `macaddress` | 11 | mac · ¿addre? · ss | addre |
| `vchrconceptopago` | 9 | ¿vchr? · concepto · pago | vchr |
| `vchrnombreord` | 9 | ¿vchr? · nombre · ord | vchr |
| `vchrctabenef` | 9 | ¿vchr? · cta · benef | vchr |
| `tipoflujo` | 8 | tipo · ¿flujo? | flujo |
| `tipogestor` | 8 | tipo · ¿gestor? | gestor |
| `account` | 8 | ¿a? · cc · ¿ount? | ount |
| `llavegdf` | 8 | ¿llave? · gdf | llave |
| `partnerid` | 8 | ¿partner? · id | partner |
| `vchrrfcbenef` | 8 | ¿vchr? · rfc · benef | vchr |
| `vchrrefcobranza1` | 8 | ¿vchr? · ref · cobranza · ¿1? | vchr |
| `apercred1` | 7 | ¿aper? · cred · ¿1? | aper |
| `contrasena` | 7 | cont · ¿rasena? | rasena |
| `numguia` | 7 | num · ¿guia? | guia |
| `numsertkn` | 7 | num · ¿sertkn? | sertkn |
| `numejecut` | 7 | num · ¿ejecut? | ejecut |
| `extension` | 7 | ¿e? · x · ¿tension? | tension |
| `identif` | 7 | id · ¿entif? | entif |
| `vchrcuentaord` | 7 | ¿vchr? · cuenta · ord | vchr |
| `digidben` | 7 | digi · ¿dben? | dben |
| `chrfchmjc` | 7 | ¿ch? · rfc · ¿hmjc? | hmjc |
| `intbancodest` | 7 | int · banco · ¿dest? | dest |
| `vchrrfcord` | 7 | ¿vchr? · rfc · ord | vchr |
| `cortos` | 6 | ¿cort? · os | cort |
| `diasret` | 6 | dia · ¿sret? | sret |
| `complemento` | 6 | comp · ¿lemento? | lemento |
| `tipoejec` | 6 | tipo · ¿ejec? | ejec |
| `regimen` | 6 | reg · ¿imen? | imen |
| `numidentif` | 6 | num · id · ¿entif? | entif |
| `institucion` | 6 | ins · ¿titucion? | titucion |
| `segmento` | 6 | seg · ¿mento? | mento |
| `tipoperacion` | 6 | tipo · ¿peracion? | peracion |
| `capital` | 6 | cap · ¿ital? | ital |
| `precalbco` | 6 | ¿p? · rec · ¿albco? | albco |
| `ofertaprodcred` | 6 | ¿oferta? · prod · cred | oferta |
| `numseriecert` | 6 | num · ¿seriecert? | seriecert |
| `mostrar` | 5 | ¿m? · os · ¿trar? | trar |
| `externa` | 5 | ¿e? · x · ¿terna? | terna |
| `newmtcn` | 5 | ¿newm? · tc · ¿n? | newm |
| `foreignrsrefnumrp` | 5 | ¿foreignrs? · ref · num · ¿rp? | foreignrs |
| `foreignrssystemidrp` | 5 | ¿foreignr? · ss · ¿ystem? · id · ¿rp? | foreignr, ystem |
| `resolucion` | 5 | ¿re? · sol · ¿ucion? | ucion |
| `codidentif` | 5 | codi · ¿dentif? | dentif |
| `appaterno` | 5 | app · ¿aterno? | aterno |

---

## Cómo se corrige cada caso

- **Sección A (token = fragmento):** si `exact`=0, el token nunca es término propio → quitarlo del vocab (como hicimos con `ini`). Si aparece a veces solo, agregar las palabras contenedoras completas para que el greedy las prefiera (longest-match).
- **Sección B (palabra partida):** agregar la palabra real completa al vocab con su significado — el greedy la tomará entera y el fragmento desaparece (como `denominacion`, `reinicia`).

*Generado por audit-vocab.py · revisar y aplicar correcciones a sp_vocab.py, luego regenerar el pipeline.*