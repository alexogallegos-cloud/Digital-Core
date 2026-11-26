# Estudio histórico de Banco del Bajío

> Regla B26. Versión 0.1, 25 de noviembre de 2026.
> Corpus: exclusivamente información pública. Ningún documento del cliente,
> ninguna entrevista, ningún código.

## Para qué existe este documento

La historia explica el porqué del código. Una regla que hoy parece arbitraria
suele responder a una circular derogada, y la heterogeneidad tecnológica de un
banco casi siempre se explica por adquisiciones que nunca se integraron. Por eso
el estudio histórico es el primer artefacto de DISCOVER y se escribe antes de
leer una sola línea de código.

En BanBajío el estudio arroja un resultado poco común, y conviene enunciarlo de
entrada porque orienta todo lo demás: no hay fusiones ni adquisiciones en el
corpus público. Si eso se confirma, este banco no arrastra la deuda de
integración que define el estate de casi cualquier banco mexicano comparable.

## Cómo se conecta al brain

Cada hecho fechado de este documento vive como fila de `business_milestones`
con su nivel de certeza y su fuente. Lo que aquí se narra con matices, allá se
consulta con precisión. Los dos relojes de la Regla B40 se aplican: el año en
que ocurrió es el reloj del negocio, y la fecha en que este brain lo supo es el
reloj del brain.

El nivel de cada afirmación no es decorativo. La fecha de fundación está en
bronze porque tres fuentes públicas dan tres fechas distintas, y mientras siga
así no puede anclar nada.

## Dimensión 1 — Fundación y modelo de negocio original

El banco se constituyó en 1994 en León, Guanajuato, por iniciativa de un grupo
de empresarios del Bajío junto con inversionistas de la Ciudad de México, y
arrancó con veintiocho empleados. La fecha exacta está en disputa: hay fuentes
que señalan el 2 de diciembre de 1994 y el perfil institucional del propio banco
indica el 4 de julio del mismo año. Queda declarado como hueco.

Dos rasgos del origen siguen vigentes treinta y dos años después. El primero es
que nació fuera de la Ciudad de México, con vocación regional explícita hacia el
centro y el norte del país. El segundo es que nació con clientela empresarial,
no de consumo masivo, y esa elección sigue marcando qué capacidades tiene
desarrolladas y cuáles no.

El momento del arranque importa más de lo que parece. El banco empezó a operar
justo cuando estallaba la peor crisis del sistema bancario mexicano moderno. La
consecuencia que vale la pena verificar contra el estate real es que un banco
constituido en 1994 no tiene por qué cargar plataformas de los años setenta ni
la cartera heredada que obligó al rescate de los bancos ya establecidos. Es una
hipótesis con consecuencias directas sobre cualquier conversación de
modernización, y hoy es solo eso, una hipótesis.

## Dimensión 2 — Hitos de crecimiento y expansión

El crecimiento documentado es orgánico. El hito que parte la historia en dos es
la salida a bolsa: las acciones comenzaron a cotizar el 8 de junio de 2017,
después de una oferta global que colocó 24.04% del capital social a 29.50 pesos
por acción, por hasta 9,089 millones de pesos contando la sobreasignación, con
la mitad en México y la mitad en mercados internacionales. En la parte
secundaria, un fondo soberano asiático redujo su participación.

La salida a bolsa es también la razón por la que este brain tiene algo que leer.
Al convertirse en emisora, el banco quedó obligado a publicar reportes
trimestrales, un reporte anual y eventos relevantes. Las siete fuentes activas
del catálogo dependen de esa obligación.

El ciclo actual arrancó en 2026 con el relevo en la dirección general, decidido
en abril y efectivo en mayo, acompañado de una reestructura organizacional
reportada ante la bolsa. La estrategia declarada desde entonces cambia la
geografía del banco: duplicar el negocio empresarial en la Ciudad de México
hacia 2030 y desplegarse con fuerza también en Monterrey y Guadalajara. Un banco
que nació regional se propone dejar de serlo.

Las cifras al cierre de septiembre de 2026 muestran el pulso de ese ciclo. La
cartera llegó a 312,368 millones de pesos, con crecimiento anual de 16.5%, cerca
de 1.8 veces el ritmo del sistema. Los depósitos sumaron 310,315 millones. La
utilidad del trimestre, en cambio, cayó 21.4% contra el mismo trimestre del año
anterior. Crecer al doble del sistema mientras la utilidad trimestral baja es
una tensión que merece explicación, y el corpus público no la da.

## Dimensión 3 — Eventos regulatorios

No hay en el corpus público ninguna sanción ni medida correctiva dirigida a esta
institución. Lo que sí aplica es el marco general: como institución de banca
múltiple responde ante la CNBV, el Banco de México, la CONDUSEF, el IPAB y la
UIF, y como emisora, además, ante el régimen de revelación bursátil.

Hay un rasgo regulatorio propio de su modelo. La línea agropecuaria opera con
fondeo, garantías y apoyos de banca de desarrollo de segundo piso, lo que mete
al banco en un régimen de reporte y supervisión adicional al de un crédito
comercial ordinario. Y buena parte de la colocación al productor pequeño viaja
por un segundo intermediario, de modo que el expediente, la verificación y la
trazabilidad no ocurren en la sucursal. Para efectos regulatorios eso no reduce
la responsabilidad del banco, y para efectos tecnológicos implica integración
con terceros que no son el cliente final.

En 2026 entró en vigor un acuerdo de simplificación de trámites en materia de
prevención de lavado de dinero, de alcance general para el sistema.

## Dimensión 4 — Decisiones tecnológicas históricas

Esta es la dimensión más pobre del estudio, y esa pobreza es el hallazgo.

De lo poco documentado, tres cosas. La primera es que el canal digital se
convirtió en el canal principal del banco en 2024, con crecimiento anual de 30%,
y que 83% de las transacciones ocurren hoy en canales no asistidos, sumando
banca digital y cajero automático. La segunda es que el banco modernizó el
procesamiento de pagos y los pagos masivos con una plataforma de Volante
Technologies, que es el único componente de tecnología con nombre propio en todo
el corpus. La tercera es organizativa: la antigua Dirección de Transformación
Digital se convirtió en Dirección Ejecutiva de Tecnología y se creó una
Dirección Corporativa de Banca Digital, ambas reportando a la Dirección General.
Que la tecnología reporte directo al primer nivel es una señal sobre cuánto pesa
en las decisiones.

Hay además una nota de prensa, sin fecha confiable, sobre una inversión inicial
de 250 millones de pesos dentro de un proyecto de tres años para renovar todos
los canales electrónicos, y una cifra total de 2,150 millones. No se cargó al
brain como medición precisamente porque no se puede fechar, y fecharla sería lo
único que la haría útil.

Del núcleo bancario no hay absolutamente nada. Ni qué plataforma es, ni de qué
año, ni si alguna vez se reemplazó. Mientras eso siga así, el brain puede
razonar sobre el negocio de BanBajío pero no sobre su tecnología.

## Dimensión 5 — Cultura organizacional y poder

Lo que el corpus público permite afirmar es modesto y conviene no estirarlo.

El banco se describe a sí mismo como el octavo del sistema por activos,
depósitos y cartera, y como el tercero más grande de control mexicano. Esa
autodescripción, repetida, sugiere que la identidad de banco de capital nacional
es parte de cómo se presenta al mercado. La ambición declarada en 2026 de entrar
al grupo de los ocho bancos más grandes convive con esa autodescripción de forma
algo tensa, y resolver esa tensión requiere preguntarle al cliente, no deducirla.

El segmento define la cultura técnica más de lo que suele reconocerse. Un banco
cuyo cliente es la empresa, el productor agropecuario y el gobierno opera con
ciclos de decisión de crédito largos, expedientes densos y relación personal con
ejecutivo asignado. Eso produce una tecnología distinta de la de un banco de
consumo masivo: menos presión de volumen transaccional, más presión de
flexibilidad en el expediente y en la estructuración del crédito.

El origen regional y el nuevo mandato de crecer en las tres grandes zonas
metropolitanas son fuerzas que apuntan en direcciones distintas. Cómo se resuelva
esa tensión es, probablemente, lo que más va a determinar las decisiones de
tecnología de los próximos años.

## Huecos abiertos por este estudio

Este estudio abrió o confirmó seis huecos, todos registrados en el brain con su
pregunta concreta: la fecha exacta de constitución (`GAP-BBAJIO-002`), el número
real de sucursales (`GAP-BBAJIO-003`), la clave de cotización y su serie
(`GAP-BBAJIO-004`), la estructura accionaria vigente (`GAP-BBAJIO-005`), la
fecha y el alcance de la inversión en canales electrónicos (`GAP-BBAJIO-014`) y,
sobre todos ellos, la identidad del núcleo bancario (`GAP-BBAJIO-001`).

Queda además una pregunta que el corpus público no puede responder y que vale
más que varias de las anteriores: por qué la utilidad trimestral cae mientras la
cartera crece al doble del sistema.
