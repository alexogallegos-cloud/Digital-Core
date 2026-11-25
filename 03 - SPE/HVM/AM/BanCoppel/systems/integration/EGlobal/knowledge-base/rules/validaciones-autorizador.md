# Validaciones de negocio del autorizador

Cada autorización de tarjeta atraviesa una secuencia de validaciones que el autorizador registra por número al cerrar la transacción. Este documento es el catálogo de las que se observaron en producción, ordenado por el momento en que aparecen en la secuencia.

El log entrega el número y la posición, no el nombre. Dar significado de negocio a cada identificador requiere documentación del vendor o una sesión con el equipo de tarjetas, y es trabajo pendiente.

> Generado desde `digital-brain/brain.db` por `generators/build-knowledge-base.py`. No editar a mano. Construido el 2026-11-04.
> Las cifras agregan 2 lote(s) de evidencia, 2,861,405 transacciones en total:
> - `authorizerj.eglobal.20261104`: 16,412 transacciones en 20 minutos (00:02:40 a 00:22:39), 30 archivos.
> - `eglobal.authorizer.20261103`: 2,844,993 transacciones en 1438 minutos (00:00:00 a 23:57:42), 118 archivos.

---

## Panorama

Se identificaron 114 validaciones distintas sobre 2,861,405 transacciones. De ellas, 67 se ejecutan prácticamente en toda transacción y 47 dependen del caso.

## Validaciones universales

Se ejecutan en 95 por ciento o más de las transacciones. Forman el troncal del ciclo de autorización.

| Orden | ID | Ejecuciones | Cobertura | Presencia en rechazos | Significado |
|-------|----|-------------|-----------|----------------------|-------------|
| 0 | `103` | 2,861,242 | 100.0% | 22.5% | Pendiente de documentar |
| 1 | `109` | 2,858,200 | 99.9% | 22.5% | Pendiente de documentar |
| 2 | `116` | 2,858,200 | 99.9% | 22.5% | Pendiente de documentar |
| 3 | `125` | 2,858,200 | 99.9% | 22.5% | Pendiente de documentar |
| 4 | `132` | 2,858,200 | 99.9% | 22.5% | Pendiente de documentar |
| 5 | `133` | 2,858,058 | 99.9% | 22.5% | Pendiente de documentar |
| 6 | `216` | 2,828,267 | 98.8% | 21.6% | Pendiente de documentar |
| 7 | `217` | 2,828,267 | 98.8% | 21.6% | Pendiente de documentar |
| 8 | `134` | 2,828,267 | 98.8% | 21.6% | Pendiente de documentar |
| 9 | `135` | 2,812,681 | 98.3% | 21.2% | Pendiente de documentar |
| 10 | `136` | 2,812,681 | 98.3% | 21.2% | Pendiente de documentar |
| 11 | `137` | 2,812,289 | 98.3% | 21.2% | Pendiente de documentar |
| 12 | `138` | 2,812,079 | 98.3% | 21.2% | Pendiente de documentar |
| 13 | `139` | 2,811,634 | 98.3% | 21.2% | Pendiente de documentar |
| 14 | `140` | 2,811,598 | 98.3% | 21.2% | Pendiente de documentar |
| 15 | `141` | 2,803,890 | 98.0% | 21.0% | Pendiente de documentar |
| 16 | `102` | 2,803,887 | 98.0% | 21.0% | Pendiente de documentar |
| 17 | `101` | 2,803,887 | 98.0% | 21.0% | Pendiente de documentar |
| 18 | `105` | 2,803,773 | 98.0% | 20.9% | Pendiente de documentar |
| 19 | `107` | 2,803,773 | 98.0% | 20.9% | Pendiente de documentar |
| 20 | `108` | 2,803,687 | 98.0% | 20.9% | Pendiente de documentar |
| 21 | `110` | 2,803,687 | 98.0% | 20.9% | Pendiente de documentar |
| 22 | `111` | 2,803,590 | 98.0% | 20.9% | Pendiente de documentar |
| 23 | `112` | 2,803,590 | 98.0% | 20.9% | Pendiente de documentar |
| 24 | `113` | 2,803,590 | 98.0% | 20.9% | Pendiente de documentar |
| 25 | `114` | 2,803,590 | 98.0% | 20.9% | Pendiente de documentar |
| 26 | `115` | 2,803,590 | 98.0% | 20.9% | Pendiente de documentar |
| 27 | `119` | 2,803,590 | 98.0% | 20.9% | Pendiente de documentar |
| 28 | `170` | 2,801,794 | 97.9% | 20.9% | Pendiente de documentar |
| 29 | `121` | 2,799,216 | 97.8% | 20.8% | Pendiente de documentar |
| 30 | `122` | 2,799,213 | 97.8% | 20.8% | Pendiente de documentar |
| 31 | `123` | 2,799,189 | 97.8% | 20.8% | Pendiente de documentar |
| 32 | `124` | 2,799,189 | 97.8% | 20.8% | Pendiente de documentar |
| 33 | `126` | 2,792,403 | 97.6% | 20.6% | Pendiente de documentar |
| 34 | `127` | 2,792,403 | 97.6% | 20.6% | Pendiente de documentar |
| 35 | `128` | 2,792,403 | 97.6% | 20.6% | Pendiente de documentar |
| 36 | `129` | 2,792,403 | 97.6% | 20.6% | Pendiente de documentar |
| 37 | `130` | 2,792,403 | 97.6% | 20.6% | Pendiente de documentar |
| 38 | `131` | 2,792,403 | 97.6% | 20.6% | Pendiente de documentar |
| 39 | `142` | 2,792,403 | 97.6% | 20.6% | Pendiente de documentar |
| 40 | `143` | 2,792,380 | 97.6% | 20.6% | Pendiente de documentar |
| 41 | `144` | 2,792,380 | 97.6% | 20.6% | Pendiente de documentar |
| 42 | `145` | 2,791,143 | 97.5% | 20.6% | Pendiente de documentar |
| 43 | `146` | 2,791,143 | 97.5% | 20.6% | Pendiente de documentar |
| 44 | `147` | 2,791,143 | 97.5% | 20.6% | Pendiente de documentar |
| 45 | `148` | 2,791,143 | 97.5% | 20.6% | Pendiente de documentar |
| 46 | `149` | 2,790,717 | 97.5% | 20.6% | Pendiente de documentar |
| 47 | `150` | 2,790,717 | 97.5% | 20.6% | Pendiente de documentar |
| 48 | `151` | 2,790,717 | 97.5% | 20.6% | Pendiente de documentar |
| 49 | `152` | 2,790,717 | 97.5% | 20.6% | Pendiente de documentar |
| 50 | `153` | 2,790,717 | 97.5% | 20.6% | Pendiente de documentar |
| 51 | `154` | 2,790,717 | 97.5% | 20.6% | Pendiente de documentar |
| 52 | `155` | 2,790,717 | 97.5% | 20.6% | Pendiente de documentar |
| 53 | `156` | 2,790,717 | 97.5% | 20.6% | Pendiente de documentar |
| 54 | `157` | 2,790,717 | 97.5% | 20.6% | Pendiente de documentar |
| 55 | `158` | 2,790,717 | 97.5% | 20.6% | Pendiente de documentar |
| 56 | `159` | 2,790,715 | 97.5% | 20.6% | Pendiente de documentar |
| 57 | `160` | 2,790,715 | 97.5% | 20.6% | Pendiente de documentar |
| 58 | `161` | 2,790,715 | 97.5% | 20.6% | Pendiente de documentar |
| 59 | `162` | 2,790,707 | 97.5% | 20.6% | Pendiente de documentar |
| 60 | `163` | 2,790,707 | 97.5% | 20.6% | Pendiente de documentar |
| 61 | `164` | 2,788,868 | 97.5% | 20.5% | Pendiente de documentar |
| 62 | `167` | 2,764,214 | 96.6% | 19.8% | Pendiente de documentar |
| 63 | `168` | 2,764,211 | 96.6% | 19.8% | Pendiente de documentar |
| 64 | `169` | 2,763,926 | 96.6% | 19.8% | Pendiente de documentar |
| 65 | `171` | 2,762,753 | 96.6% | 19.8% | Pendiente de documentar |
| 66 | `120` | 2,721,041 | 95.1% | 18.5% | Pendiente de documentar |

## Validaciones condicionales

Se ejecutan sólo bajo ciertas condiciones de la transacción. La columna de tipos muestra dónde aparecen con más frecuencia, y es la mejor pista disponible sobre qué controlan.

| Orden | ID | Ejecuciones | Cobertura | Dónde aparece |
|-------|----|-------------|-----------|---------------|
| 1 | `104` | 3,027 | 0.1% | compra pos (3,026), validacion cuenta (1) |
| 28 | `117` | 1,053 | 0.0% | retiro atm (857), consulta atm (196) |
| 62 | `165` | 82 | 0.0% | sin etiqueta (82) |
| 67 | `172` | 2,714,940 | 94.9% | compra pos (2,462,004), cash back pos (131,442), retiro atm (61,702) |
| 68 | `173` | 2,714,940 | 94.9% | compra pos (2,462,004), cash back pos (131,442), retiro atm (61,702) |
| 69 | `174` | 2,714,934 | 94.9% | compra pos (2,461,998), cash back pos (131,442), retiro atm (61,702) |
| 70 | `175` | 2,714,934 | 94.9% | compra pos (2,461,998), cash back pos (131,442), retiro atm (61,702) |
| 71 | `176` | 2,714,934 | 94.9% | compra pos (2,461,998), cash back pos (131,442), retiro atm (61,702) |
| 72 | `177` | 2,714,934 | 94.9% | compra pos (2,461,998), cash back pos (131,442), retiro atm (61,702) |
| 73 | `178` | 2,714,934 | 94.9% | compra pos (2,461,998), cash back pos (131,442), retiro atm (61,702) |
| 74 | `179` | 2,714,934 | 94.9% | compra pos (2,461,998), cash back pos (131,442), retiro atm (61,702) |
| 75 | `181` | 2,714,934 | 94.9% | compra pos (2,461,998), cash back pos (131,442), retiro atm (61,702) |
| 76 | `183` | 2,714,934 | 94.9% | compra pos (2,461,998), cash back pos (131,442), retiro atm (61,702) |
| 77 | `184` | 2,714,891 | 94.9% | compra pos (2,461,967), cash back pos (131,440), retiro atm (61,692) |
| 78 | `185` | 2,714,891 | 94.9% | compra pos (2,461,967), cash back pos (131,440), retiro atm (61,692) |
| 79 | `186` | 2,714,891 | 94.9% | compra pos (2,461,967), cash back pos (131,440), retiro atm (61,692) |
| 80 | `187` | 2,714,891 | 94.9% | compra pos (2,461,967), cash back pos (131,440), retiro atm (61,692) |
| 81 | `188` | 2,714,891 | 94.9% | compra pos (2,461,967), cash back pos (131,440), retiro atm (61,692) |
| 82 | `189` | 2,707,753 | 94.6% | compra pos (2,454,829), cash back pos (131,440), retiro atm (61,692) |
| 83 | `190` | 2,707,753 | 94.6% | compra pos (2,454,829), cash back pos (131,440), retiro atm (61,692) |
| 84 | `191` | 2,707,753 | 94.6% | compra pos (2,454,829), cash back pos (131,440), retiro atm (61,692) |
| 85 | `192` | 2,707,753 | 94.6% | compra pos (2,454,829), cash back pos (131,440), retiro atm (61,692) |
| 86 | `193` | 2,707,744 | 94.6% | compra pos (2,454,820), cash back pos (131,440), retiro atm (61,692) |
| 87 | `194` | 2,707,744 | 94.6% | compra pos (2,454,820), cash back pos (131,440), retiro atm (61,692) |
| 88 | `195` | 2,707,744 | 94.6% | compra pos (2,454,820), cash back pos (131,440), retiro atm (61,692) |
| 89 | `196` | 2,707,744 | 94.6% | compra pos (2,454,820), cash back pos (131,440), retiro atm (61,692) |
| 90 | `197` | 2,707,744 | 94.6% | compra pos (2,454,820), cash back pos (131,440), retiro atm (61,692) |
| 91 | `198` | 2,707,744 | 94.6% | compra pos (2,454,820), cash back pos (131,440), retiro atm (61,692) |
| 92 | `199` | 2,707,742 | 94.6% | compra pos (2,454,818), cash back pos (131,440), retiro atm (61,692) |
| 93 | `200` | 2,707,742 | 94.6% | compra pos (2,454,818), cash back pos (131,440), retiro atm (61,692) |
| 94 | `201` | 2,707,742 | 94.6% | compra pos (2,454,818), cash back pos (131,440), retiro atm (61,692) |
| 95 | `202` | 2,707,742 | 94.6% | compra pos (2,454,818), cash back pos (131,440), retiro atm (61,692) |
| 96 | `203` | 2,707,742 | 94.6% | compra pos (2,454,818), cash back pos (131,440), retiro atm (61,692) |
| 97 | `204` | 2,707,742 | 94.6% | compra pos (2,454,818), cash back pos (131,440), retiro atm (61,692) |
| 98 | `209` | 2,706,515 | 94.6% | compra pos (2,453,591), cash back pos (131,440), retiro atm (61,692) |
| 99 | `206` | 2,706,513 | 94.6% | compra pos (2,453,589), cash back pos (131,440), retiro atm (61,692) |
| 100 | `207` | 2,706,050 | 94.6% | compra pos (2,453,126), cash back pos (131,440), retiro atm (61,692) |
| 101 | `210` | 2,706,050 | 94.6% | compra pos (2,453,126), cash back pos (131,440), retiro atm (61,692) |
| 102 | `211` | 2,706,034 | 94.6% | compra pos (2,453,110), cash back pos (131,440), retiro atm (61,692) |
| 103 | `212` | 2,706,024 | 94.6% | compra pos (2,453,110), cash back pos (131,430), retiro atm (61,692) |
| 104 | `213` | 2,706,024 | 94.6% | compra pos (2,453,110), cash back pos (131,430), retiro atm (61,692) |
| 105 | `214` | 2,706,024 | 94.6% | compra pos (2,453,110), cash back pos (131,430), retiro atm (61,692) |
| 106 | `220` | 2,706,024 | 94.6% | compra pos (2,453,110), cash back pos (131,430), retiro atm (61,692) |
| 107 | `221` | 2,706,024 | 94.6% | compra pos (2,453,110), cash back pos (131,430), retiro atm (61,692) |
| 108 | `222` | 2,699,709 | 94.3% | compra pos (2,446,795), cash back pos (131,430), retiro atm (61,692) |
| 109 | `223` | 2,699,709 | 94.3% | compra pos (2,446,795), cash back pos (131,430), retiro atm (61,692) |
| 110 | `224` | 2,699,601 | 94.3% | compra pos (2,446,687), cash back pos (131,430), retiro atm (61,692) |

---

## Lo que estas validaciones NO son

Ninguna de ellas es criptográfica. El autorizador no calcula el NIP, ni el CVV, ni el CVV2, ni el criptograma EMV: los recibe ya resueltos del sistema InterAct, que es el front-end ISO 8583 de la plataforma y ejecuta esa validación contra el HSM antes de entregar el mensaje. El autorizador solo lee el resultado.

Los campos que traen ese resultado, y el número de transacciones donde la validación sí aplicó, son estos. El valor `FF` significa que no aplicaba.

| Campo | Qué valida | Transacciones donde aplicó | Dónde aplica |
|-------|------------|---------------------------|---------------|
| `CVCRc` | El CVV de banda o chip | 1,674,392 | compra pos (1,466,648), cash back pos (132,325), retiro atm (64,567) |
| `ARQCRc` | El criptograma EMV | 1,674,281 | compra pos (1,466,639), cash back pos (132,325), retiro atm (64,516) |
| `CVC2Rc` | El CVV2 impreso | 232,249 | compra pos (202,396), validacion cuenta (29,853) |
| `PINRc` | El NIP | 75,373 | retiro atm (64,567), consulta atm (10,806) |
| `CAVVRc` | La autenticación 3D Secure | 2,942 | compra pos (2,941), validacion cuenta (1) |

Esa tabla verifica la política que InterAct declara en prosa: el NIP solo se valida en cajero, y en punto de venta el CVV se valida cuando hubo banda o chip. Las cifras de ambos sistemas coinciden.

---

## Cómo leer la posición

La posición es el promedio del lugar que ocupa la validación dentro de la lista que el autorizador emite al cerrar cada transacción. Una posición baja indica que la validación corre temprano, cuando todavía no se conoce el resultado del core. Una posición alta indica que corre al final, ya con la respuesta del core en mano.

La presencia en rechazos no implica causalidad. Una validación que aparece en el 90 por ciento de los rechazos puede ser simplemente una validación universal que también corre en las aprobaciones. Para atribuir causa hay que cruzar contra el código de respuesta, y eso vive en `codigos-respuesta.md`.
