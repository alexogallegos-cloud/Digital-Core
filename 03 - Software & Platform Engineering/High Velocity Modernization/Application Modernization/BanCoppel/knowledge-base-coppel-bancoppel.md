# Base de Conocimiento — Grupo Coppel & BanCoppel

> **Propósito:** contexto de negocio del cliente para el proyecto de modernización `SPE-AM-001` (BCOPCore, core bancario Informix). Coppel (el retailer) es el origen de la base de clientes de BanCoppel — su historia de crédito al consumo explica gran parte de la lógica del core. Mantener siempre en cuenta al analizar dominios, journeys, reglas de negocio y decisiones 7R.
>
> **Componente:** BanCoppel BCOPCore · **Investigación web:** 2026-07-06 · fuentes al pie.

---

## 1 · Por qué importa para la modernización

- **La base de clientes de BanCoppel = los clientes de crédito de Coppel.** BanCoppel nació (2007) para bancarizar y gestionar el crédito de la enorme base de clientes de las tiendas Coppel — mercado masivo, muchos sub/no bancarizados. Esto explica el peso del core en **captación, crédito al consumo, nómina, remesas y dispersión** más que en banca corporativa.
- **Modelo de negocio Coppel = crédito al consumo con pagos semanales.** Es el ADN de la empresa desde la posguerra. La lógica de abonos, refinanciamiento, mora y recuperación en el core hereda ese modelo minorista, no un modelo bancario clásico.
- **"Base de datos como aplicación".** El core creció como Stored Procedures Informix a lo largo de ~18 años (2007→hoy), reflejando cada producto y cambio regulatorio como capas de SPs — las "vetas del árbol" (ver `evolution-bcop.html`).
- **Escala operativa crítica.** BanCoppel es la **3ª red bancaria de México por sucursales** (1,300+ en 32 estados, ~2,200 cajeros, 5M+ usuarios de app). La modernización toca un sistema productivo de misión crítica a escala nacional.
- **Riesgo de continuidad probado.** En **abril 2024** Coppel sufrió una **caída mayor de sistemas** que afectó a millones de clientes por varios días — evidencia tangible del riesgo de operar sobre el legacy y argumento de negocio para la modernización (parallel-run, rollback, equivalencia funcional).

---

## 2 · Grupo Coppel — el retailer (línea de tiempo)

| Año | Hito |
|-----|------|
| 1939 | Enrique Coppel Tamayo (con su padre Luis Coppel Rivas) abre **"El Regalo"** en Mazatlán, Sinaloa (regalos, relojes, radios importados). |
| 1941 | Fundación de **Coppel** en Culiacán, Sinaloa. |
| Posguerra | Innovación clave: **venta de muebles a crédito con pagos semanales** — nace el modelo de crédito al consumo que define a la empresa. |
| 1970s | Giro al sector muebles/electrodomésticos; expansión agresiva de sucursales. |
| 1981–82 | Enrique Coppel Tamayo cede el liderazgo a sus hijos (Enrique Coppel Luken dirige). |
| 1989–90 | ~22–24 tiendas · ~USD 100 M en ventas · ~1,800 empleados. |
| 2002 | Adquisición de **Zapaterías Canadá** → entrada al mercado de la Ciudad de México y escala nacional. |
| **2005** | Se crea **Afore Coppel** (administradora de fondos para el retiro). |
| **2007** | Se funda **BanCoppel** (ver §3). |
| 2008 | **Agustín Coppel Luken** asume la dirección general del Grupo. |
| 2010 | Expansión internacional: 3 tiendas en **Brasil** + 3 en **Argentina** (inversión ~USD 100 M). |
| 2015 | Adquiere las **51 tiendas Viana** en Brasil (~MXN 2,500 M). |
| ~2016–18 | **Salida de Brasil** tras ~9 años (el modelo no se adaptó al mercado/fiscalidad brasileña; pérdidas). Argentina se mantiene. |
| 2020 | **Universidad Corporativa Coppel** · impacto de la pandemia. |
| 2024 | **Caída mayor del sistema** (abril) — millones de clientes afectados. |
| 2025 | Renovación de imagen corporativa (junio) y **nueva plataforma de e-commerce**; meta de crecer ventas en línea hacia 2030. |
| Hoy | **1,700+ puntos de venta en México** + ~27 tiendas en Argentina. Muebles, electrónica, ropa, calzado — todo bajo crédito accesible con pagos semanales. |

**Estructura del Grupo (3 unidades):** **Tiendas Coppel** · **BanCoppel** · **Afore Coppel** (esta última da servicio a ~14 M de trabajadores).

---

## 3 · BanCoppel — el banco (línea de tiempo)

| Año | Hito |
|-----|------|
| 2006 (10 nov) | **Constitución** de BanCoppel, S.A., Institución de Banca Múltiple; autorización SHCP, supervisión **CNBV**. |
| **2007 (mayo)** | **Inicio de operaciones.** Objetivo: bancarizar la base de crédito de Coppel y al mercado masivo sub/no bancarizado. Aprovecha la red de tiendas Coppel como puntos de servicio. |
| 2014 | Supera **850 sucursales** y ~9,500 empleados. |
| 2015 | Abre división de **banca empresarial/corporativa**. |
| 2017 | **App BanCoppel** (banca móvil). |
| 2019 | Adopta **CoDi** (cobros digitales QR de Banxico, sobre SPEI). |
| 2020 | Primera **sucursal bancaria independiente** (Atlacomulco) · pandemia → aceleración digital. |
| 2021 | **Carlos López-Moctezuma Jassán** asume la dirección general (perfil de inclusión financiera). |
| 2022 | Cartera corporativa ~MXN 23.8 mil M · **Julio Carranza Bolívar** preside el consejo. |
| 2023 | **3ª red bancaria del país** por sucursales: 1,300+ en 32 estados. |
| Hoy | ~1,372 sucursales · ~2,203 cajeros · **5M+ usuarios mensuales de la app**. |

**Productos ancla:** débito (Cuenta Efectiva Digital, Cuenta Clic), **nómina** sin comisión, **remesas**, crédito al consumo (ligado a Coppel), **CoDi**, SPEI, CVV dinámico, Afore Coppel (estados de cuenta). Correlacionan con los dominios del core: captación (bdisac/bdicheq), crédito (bdicred), SPEI (bdispei), canal digital (bdicnweb), etc.

---

## 4 · Identidad de marca (Design Studio)

Fuente autorizada: `Solutioning/Design - Studio/paleta_clientes.md` + `logos/BanCoppel_logo.png`.

| Rol | Hex | Uso |
|-----|-----|-----|
| **Ancla** (azul eléctrico) | `#122FB1` | color primario de marca |
| **Señal** (amarillo) | `#F0D224` | acento de máximo impacto (la combinación azul+amarillo es la firma de la marca) |
| Papel | `#FFFFFF` | fondo |
| Plano | `#EEF0FA` | superficie azul muy clara |
| Trazo | `#C5CCE8` | bordes/líneas |

Tipografía: **Calibri** (fallback Arial). Personalidad: dinámica, energética, banca de consumo masivo.
> Nota dark-mode: el Ancla `#122FB1` está pensado para slides claros; en fondos oscuros usar tintes más claros del azul para fills (ver `evolution-bcop.html` / `capability-model-bcop.html`).

---

## 5 · Implicaciones para el análisis (7R / dominios / reglas)

- **Crédito al consumo minorista** es el corazón funcional — priorizar equivalencia funcional en cálculo de intereses, abonos, mora y recuperación (dominios bdicred/bdicobranza).
- **Dispersión y remesas** conectan con TESOFE/SPEI y con la base masiva — validar cadenas de pago con los SME reguladores.
- **Regulación aplicable por default:** CNBV (Circular Única de Bancos), Banxico (SPEI/CoDi), CONDUSEF (transparencia/RECO), PLD/Ley Antilavado, más SAT/TESOFE/IPAB según flujo.
- **La caída de abril 2024** es el argumento de negocio más fuerte para el rigor de coexistencia (parallel-run, rollback probado, comparator) del sub-offering HVM.

---

## Fuentes (investigación web 2026-07-06)

- [BanCoppel — Wikipedia (es)](https://es.wikipedia.org/wiki/BanCoppel)
- [Coppel — Wikipedia (en)](https://en.wikipedia.org/wiki/Coppel)
- [¿Quiénes somos? — BanCoppel.com](https://www.bancoppel.com/acerca_bancoppel/quienes_somos.html)
- [La historia de BanCoppel — El Financiero](https://www.elfinanciero.com.mx/opinion/jeanette-leyva/la-historia-de-bancoppel/)
- [Así nació BanCoppel — AméricaRetail](https://americaretail-malls.com/paises/mexico/asi-nacio-bancoppel/)
- [Coppel en México: historia y evolución — The Logistics World](https://thelogisticsworld.com/abastecimiento-y-compras/coppel-en-mexico-la-historia-y-evolucion-de-la-tienda-departamental-lider/)
- [Sale Coppel de Brasil — El Heraldo de Aguascalientes](https://www.heraldo.mx/sale-coppel-de-brasil-sigue-argentina/)
- [Coppel cierra compra de Viana — El Diario de Juárez](https://diario.mx/Economia/2015-03-02_fc474a54/coppel-cierra-compra-de-viana/)
- [Grupo Coppel lanza nueva plataforma de e-commerce (2025) — Coppel Sala de Prensa](https://www.coppel.com/blog/sala-de-prensa/grupo-coppel-lanza-su-nueva-plataforma-digital-de-ecommerce-slp/)
- [Caída del sistema de Coppel (abril 2024) — Milenio](https://www.milenio.com/negocios/caida-de-coppel-a-cuantos-clientes-impacto)
- [Reporte de calificación BanCoppel (ene 2025) — PCR Verum](https://pcrverum.mx/wp-content/uploads/2025/01/BanCoppel_Reporte-de-Calificacion-Ene.24.2025.pdf)

> ⚠ Fechas de expansión internacional con ligera variación entre fuentes (2009 vs 2010); se usó 2010 por consistencia con la cifra de inversión reportada. Validar cifras exactas de sucursales/clientes con el reporte anual de BanCoppel antes de citarlas en propuesta.