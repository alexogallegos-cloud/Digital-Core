CREATE PROCEDURE "informix".ss_reportesolicitudes()
RETURNING CHAR(6), VARCHAR(70);


---------------------------------------------------------
--Autor: Julio Cesar Polanco Inzunza
--Fecha: 21/08/2007
--Actividad: Genera informacion de reporte de solicitudes
--para el area de Riesgos.
----------------------------------------------------------
----------------------------------------------------------
--Autor: Paul Ivan Quintero Varela
--Fecha: 15/08/2008
--Modificaciï¿½n:  Se modifica el sp para que contemple la informaciï¿½n
--correspondiente a las preguntas del paramï¿½trico nuevas:(Pregunta, Respuesta y Puntuaciï¿½n);
-- Ingreso del Cliente, Escolaridad, Habitantes en el domicilio y Antigï¿½edad de la plaza + nivel de vencido
-- ademas el total del scoring de la seccion 2 y el total del scoring contemplen dichos campos,
-- asi como la resolucion de la incidencia con la suma del scoring de la seccion 1 y 2 con los nuevos
-- cambios al parametrico.
--------------------------------------------------------
---------------------------------------------------------
--Autor: Julio Cesar Polanco Inzunza
--Fecha: 04/03/2009
--Actividad: Se modifica para contemplar cambios en la tabla ss_scoring_grupo
-- para descartar el grupo de la os telefonica, sugeridos por caja unica.
----------------------------------------------------------
---------------------------------------------------------------------------------
-- Autor: Luis ï¿½?ngel JuÃ¡rez VÃ¡zquez, Gustavo Fuentes LÃ³pez
-- Modificacion: Se ha agregado la validaciÃ³n de producto para realizar nueva evaluaciÃ³n de parametros .
-- Fecha de Modificacion: 20-08-2022.
-- Peticion: Prestamo Personal
---------------------------------------------------------------------------------

--Declaracion de variables
DEFINE chrcodret               CHAR(6);
DEFINE chrmensaje              CHAR(70);
DEFINE chrnumsolicitud         CHAR(20);
DEFINE chrsucursal             CHAR(4);
DEFINE chrappaterno            CHAR(26);
DEFINE chrapmaterno            CHAR(26);
DEFINE chrnombre1              CHAR(26);
DEFINE chrnombre2              CHAR(26);
DEFINE chrstatussol            CHAR(2);
DEFINE chrnumproducto          CHAR(4);
DEFINE chrsitesp               CHAR(1);
DEFINE chrrespuesta            CHAR(1);
DEFINE chrnumcte               CHAR(20);
DEFINE chrnumctecoppel         CHAR(20);
DEFINE chrejecutivo            CHAR(30);
DEFINE chrdescsitesp           CHAR(80);
DEFINE chrrfc                  CHAR(13);
DEFINE chrnombrezona           CHAR(30);
DEFINE chrnombrecalle          CHAR(30);
DEFINE chrentrecalles          CHAR(40);
DEFINE chrcodpostal            CHAR(5);
DEFINE chrnumext               CHAR(10);
DEFINE chrnumint               CHAR(10);
DEFINE chrobservaciones        CHAR(80);
DEFINE chrestado               CHAR(30);
DEFINE chrnombresuc            CHAR(40);
DEFINE chrtelsuc               CHAR(14);
DEFINE chrnombregte            CHAR(40);
DEFINE chrtelefono             CHAR(13);
DEFINE chrmop                  CHAR(2);
DEFINE chrclavecc1             CHAR(2);

DEFINE vchrpregunta            VARCHAR(80);
DEFINE vchrrespuesta           VARCHAR(80);
DEFINE vchrrespuesta1          VARCHAR(80);
DEFINE vchrrespuesta2          VARCHAR(80);
DEFINE vchrrespuesta3          VARCHAR(80);
DEFINE vchrrespuesta4          VARCHAR(80);
DEFINE vchrrespuesta5          VARCHAR(80);
DEFINE vchrrespuesta6          VARCHAR(80);
DEFINE vchrrespuesta7          VARCHAR(80);
DEFINE vchrrespuesta8          VARCHAR(80);
DEFINE vchrrespuesta9          VARCHAR(80);
DEFINE vchrrespuesta10         VARCHAR(80);
DEFINE vchrrespuesta13         VARCHAR(80);

DEFINE vchrrespuesta15         VARCHAR(80);
DEFINE vchrrespuesta16         VARCHAR(80);
DEFINE vchrpregunta17          VARCHAR(80);
DEFINE vchrrespuesta17         VARCHAR(80);

--INI AGREGAR VARIABLES PRUEBA TESTIGO
DEFINE vchrrespuesta18         VARCHAR(80);
DEFINE vchrrespuesta19         VARCHAR(80);
DEFINE vchrrespuesta20         VARCHAR(80);
DEFINE vchrrespuesta21         VARCHAR(80);
DEFINE vchrrespuesta22         VARCHAR(80);
DEFINE vchrrespuesta23         VARCHAR(80);
DEFINE vchrrespuesta24         VARCHAR(80);
DEFINE vchrrespuesta25         VARCHAR(80);
DEFINE vchrrespuesta26         VARCHAR(80);
DEFINE vchrrespuesta27         VARCHAR(80);
DEFINE vchrrespuesta28         VARCHAR(80);
DEFINE vchrrespuesta29         VARCHAR(80);
DEFINE vchrrespuesta30         VARCHAR(80); -- INI se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
DEFINE vchrrespuesta31         VARCHAR(80);
DEFINE vchrrespuesta32         VARCHAR(80);
DEFINE vchrrespuesta33         VARCHAR(80);
DEFINE vchrrespuesta34         VARCHAR(80);
DEFINE vchrrespuesta35         VARCHAR(80); -- FIN se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03

--Agregar variables para reporte solic_credito
DEFINE vchrrespuesta36         VARCHAR(80);
DEFINE vchrrespuesta37         VARCHAR(80);
DEFINE vchrrespuesta38         VARCHAR(80);
DEFINE vchrrespuesta39         VARCHAR(80);
DEFINE vchrrespuesta40         VARCHAR(80);
DEFINE vchrrespuesta41         VARCHAR(80);
DEFINE vchrrespuesta42         VARCHAR(80);
DEFINE vchrrespuesta43         VARCHAR(80);
DEFINE vchrrespuesta44         VARCHAR(80);
DEFINE vchrrespuesta45         VARCHAR(80);
DEFINE vchrrespuesta46         VARCHAR(80);
DEFINE vchrrespuesta47         VARCHAR(80);
DEFINE vchrrespuesta48         VARCHAR(80);
DEFINE vchrrespuesta49         VARCHAR(80);
DEFINE vchrrespuesta50         VARCHAR(80);

--FIN AGREGAR VARIABLES PRUEBA TESTIGO
DEFINE vchrrespuestacc        VARCHAR(100);
DEFINE vchrciudad             VARCHAR(200);

DEFINE vchrclaciucobr         VARCHAR(10);
DEFINE vchrclaedocobr         VARCHAR(10);

--Valores Puntuales
DEFINE varpuntual18          DECIMAL(10,4);
DEFINE varpuntual19          DECIMAL(10,4);
DEFINE varpuntual20          DECIMAL(10,4);
DEFINE varpuntual21          DECIMAL(10,4);
DEFINE varpuntual22          DECIMAL(10,4);
DEFINE varpuntual23          DECIMAL(10,4);
DEFINE varpuntual24          DECIMAL(10,4);
DEFINE varpuntual25          DECIMAL(10,4);
DEFINE varpuntual26          DECIMAL(10,4);
DEFINE varpuntual27          DECIMAL(10,4);
DEFINE varpuntual28          DECIMAL(10,4);
DEFINE varpuntual29          DECIMAL(10,4);
DEFINE varpuntual30          DECIMAL(10,4); -- INI se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
DEFINE varpuntual31          DECIMAL(10,4);
DEFINE varpuntual32          DECIMAL(10,4);
DEFINE varpuntual33          DECIMAL(10,4);
DEFINE varpuntual35          DECIMAL(10,4); -- FIN se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03

--Agregar variables para reporte solic_credito
DEFINE varpuntual36         DECIMAL(10,4);
DEFINE varpuntual37         DECIMAL(10,4);
DEFINE varpuntual38         DECIMAL(10,4);
DEFINE varpuntual39         DECIMAL(10,4);
DEFINE varpuntual40         DECIMAL(10,4);
DEFINE varpuntual41         DECIMAL(10,4);
DEFINE varpuntual42         DECIMAL(10,4);
DEFINE varpuntual43         DECIMAL(10,4);

DEFINE declincred           DECIMAL(18,2);
DEFINE deceficponderada     DECIMAL(5,2);
DEFINE decvalor             DECIMAL(5,2);
DEFINE decvalor1            DECIMAL(5,2);
DEFINE decvalor2            DECIMAL(5,2);
DEFINE decvalor3            DECIMAL(5,2);
DEFINE decvalor4            DECIMAL(5,2);
DEFINE decvalor5            DECIMAL(5,2);
DEFINE decvalor6            DECIMAL(5,2);
DEFINE decvalor7            DECIMAL(5,2);
DEFINE decvalor8            DECIMAL(5,2);
DEFINE decvalor9            DECIMAL(5,2);
DEFINE decvalor10           DECIMAL(5,2);
DEFINE decvalor13           DECIMAL(5,2);

DEFINE decvalor15           DECIMAL(5,2);
DEFINE decvalor16           DECIMAL(5,2);
DEFINE decvalor17           DECIMAL(5,2);

--INI AGREGAR VARIABLES PRUEBA TESTIGO
DEFINE decvalor18          DECIMAL(5,2);
DEFINE decvalor19          DECIMAL(5,2);
DEFINE decvalor20          DECIMAL(5,2);
DEFINE decvalor21          DECIMAL(5,2);
DEFINE decvalor22          DECIMAL(5,2);
DEFINE decvalor23          DECIMAL(5,2);
DEFINE decvalor24          DECIMAL(5,2);
DEFINE decvalor25          DECIMAL(5,2);
DEFINE decvalor26          DECIMAL(5,2);
DEFINE decvalor27          DECIMAL(5,2);
DEFINE decvalor28          DECIMAL(5,2);
DEFINE decvalor29          DECIMAL(5,2);
DEFINE decvalor30          DECIMAL(5,2);
DEFINE decvalor31          DECIMAL(5,2);
DEFINE decvalor32          DECIMAL(5,2);
DEFINE decvalor33          DECIMAL(5,2);
DEFINE decvalor34          DECIMAL(5,2);
DEFINE decvalor35          DECIMAL(5,2);

--Agregar variables para reporte solic_credito
DEFINE decvalor36          DECIMAL(5,2);
DEFINE decvalor37          DECIMAL(5,2);
DEFINE decvalor38          DECIMAL(5,2);
DEFINE decvalor39          DECIMAL(5,2);
DEFINE decvalor40          DECIMAL(5,2);
DEFINE decvalor41          DECIMAL(5,2);
DEFINE decvalor42          DECIMAL(5,2);
DEFINE decvalor43          DECIMAL(5,2);
DEFINE decvalor44          DECIMAL(5,2);
DEFINE decvalor45          DECIMAL(5,2);
DEFINE decvalor46          DECIMAL(5,2);
DEFINE decvalor47          DECIMAL(5,2);
DEFINE decvalor48          DECIMAL(5,2);
DEFINE decvalor49          DECIMAL(5,2);
DEFINE decvalor50          DECIMAL(5,2);
DEFINE cStatus_Ini         CHAR(2);
DEFINE cRevisado           CHAR(2);
DEFINE cIdbox              SMALLINT;
DEFINE cIfe                CHAR(2);
DEFINE intDiasContador     INTEGER;

--FIN AGREGAR VARIABLES PRUEBA TESTIGO
DEFINE decseccion1         DECIMAL(14,2);
DEFINE decseccion2         DECIMAL(14,2);
DEFINE decsuma             DECIMAL(14,2);
DEFINE decauxsec2          DECIMAL(5,2);

DEFINE intmeses            SMALLINT;
DEFINE intcausasitesp      SMALLINT;
DEFINE intcontador         SMALLINT;
DEFINE intgrupo            SMALLINT;
DEFINE intelemento         SMALLINT;
DEFINE intsmb              SMALLINT;
DEFINE intgrupoaux         SMALLINT;
DEFINE intelementoaux      SMALLINT;
DEFINE intcont             SMALLINT;
DEFINE intnumcobranza              SMALLINT;

DEFINE dtefechasol                 DATE;
DEFINE dtefeCHAResp                DATE;
DEFINE dtefechanac                 DATE;
DEFINE dtefechacc                  DATE;
DEFINE intcodret                   INTEGER;

DEFINE mnyingreso                  MONEY(14,2);
DEFINE mnyingresosmb               MONEY(14,2);
DEFINE mnyimporte                  MONEY(9,2);

DEFINE dEvaluacion1                DECIMAL(14,2);
DEFINE dEvaluacion2                DECIMAL(14,2);
DEFINE dSuma                       DECIMAL(14,2);
DEFINE iCantidad                   INTEGER;
DEFINE icontadorcommit             INTEGER;
DEFINE ibanderaIndice              INTEGER;

--INI AGREGAR VARIABLES PRUEBA TESTIGO
DEFINE dSdoropa                    DECIMAL(14,2);
DEFINE dSdomuebles                 DECIMAL(14,2);
DEFINE dSdoprestamo                DECIMAL(14,2);
DEFINE dSdolineatienda             DECIMAL(14,2);
DEFINE cPrueba                     CHAR(03);
DEFINE cFiltroC                    CHAR(10);
DEFINE cbcscore                    CHAR(04);
DEFINE ctipoc                      CHAR(03);
--FIN AGREGAR VARIABLES PRUEBA TESTIGO

--INI AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS
DEFINE vfecha                      DATE;
DEFINE v_compromisos               DECIMAL(14,2);
DEFINE v_causa                     VARCHAR(255);
DEFINE v_status                    VARCHAR(255);
DEFINE v_fecha_apert               DATE;
DEFINE v_edad                      SMALLINT;
DEFINE v_email                     CHAR(60);
DEFINE v_tel_ofi                   CHAR(13);
DEFINE v_tel_cel                   CHAR(13);
DEFINE v_fuente                    CHAR(10);

--FIN AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS
--respuestas puntuales
DEFINE vchsvariable                VARCHAR(80);
DEFINE decvalor_punt               DECIMAL(10,4);

-- AGREGAR VARIABLES RQM 07 048-02 Adendum Modificaciones al SolicAAAAMMDD.
DEFINE mnyabonomensualmuebles      MONEY(14,2);
DEFINE mnyabonomensualropa         MONEY(14,2);
DEFINE mnyabonomensualprestamos    MONEY(14,2);
DEFINE mnypago_minimo              MONEY(14,2);
DEFINE chrevalua_cc                CHAR(1);
DEFINE vDia                        CHAR(10);
DEFINE vHora                       CHAR(28);
DEFINE iIsamErr	                   INTEGER;
DEFINE cMensajeRet                 CHAR(100);
DEFINE cgrupo_solic                CHAR(1);

--398-0 FICO Extended
DEFINE dEvaluacion3                DECIMAL(14,2);
DEFINE dEvaluacion4                DECIMAL(14,2);
DEFINE dEvaluacion5                DECIMAL(14,2);

--IPCB Marzo2016 RQM 09 398-0 FICO Extended
DEFINE cFlag2Credito               CHAR(60);
DEFINE vtipoModeloHit              CHAR(5);


--Inicializacion de variables
LET chrcodret                 = "000000";
LET chrmensaje                = 'El proceso REPORTE DE SOLICITUDES se ejecutÃ³ exitosamente';
LET chrnumsolicitud           = "";
LET chrsucursal               = "";
LET chrappaterno              = "";
LET chrapmaterno              = "";
LET chrnombre1                = "";
LET chrnombre2                = "";
LET chrstatussol              = "";
LET chrnumproducto            = "";
LET chrsitesp                 = "";
LET chrrespuesta              = "";
LET chrnumcte                 = "";
LET chrnumctecoppel           = "";
LET chrejecutivo              = "";
LET chrdescsitesp             = "";
LET chrrfc                    = "";
LET chrnombrezona             = "";
LET chrnombrecalle            = "";
LET chrentrecalles            = "";
LET chrcodpostal              = "";
LET chrnumext                 = "";
LET chrnumint                 = "";
LET chrobservaciones          = "";
LET chrestado                 = "";
LET chrnombresuc              = "";
LET chrtelsuc                 = "";
LET chrnombregte              = "";
LET chrtelefono               = "";
LET chrmop                    = "";
LET vchrpregunta              = "";
LET vchrrespuesta             = "";
LET vchrrespuesta1            = "";
LET vchrrespuesta2            = "";
LET vchrrespuesta3            = "";
LET vchrrespuesta4            = "";
LET vchrrespuesta5            = "";
LET vchrrespuesta6            = "";
LET vchrrespuesta7            = "";
LET vchrrespuesta8            = "";
LET vchrrespuesta9            = "";
LET vchrrespuesta10           = "";
LET vchrrespuesta13           = "";

LET vchrrespuesta15           = "";
LET vchrrespuesta16           = "";
LET vchrpregunta17            = "";
LET vchrrespuesta17           = "";

--INI AGREGAR VARIABLES PRUEBA TESTIGO
LET vchrrespuesta18           = "";
LET vchrrespuesta19           = "";
LET vchrrespuesta20           = "";
LET vchrrespuesta21           = "";
LET vchrrespuesta22           = "";
LET vchrrespuesta23           = "";
LET vchrrespuesta24           = "";
LET vchrrespuesta25           = "";
LET vchrrespuesta26           = "";
LET vchrrespuesta27           = "";
LET vchrrespuesta28           = "";
LET vchrrespuesta29           = "";
LET vchrrespuesta30           = "";
LET vchrrespuesta31           = "";
LET vchrrespuesta32           = "";
LET vchrrespuesta33           = "";
LET vchrrespuesta34           = "";
LET vchrrespuesta35           = "";

--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
--MJPC agregar variables para reporte solic_credito
LET vchrrespuesta36           = "";
LET vchrrespuesta37           = "";
LET vchrrespuesta38           = "";
LET vchrrespuesta39           = "";
LET vchrrespuesta40           = "";
LET vchrrespuesta41           = "";
LET vchrrespuesta42           = "";
LET vchrrespuesta43           = "";
LET vchrrespuesta44           = "";
LET vchrrespuesta45           = "";
LET vchrrespuesta46           = "";
LET vchrrespuesta47           = "";
LET vchrrespuesta48           = "";
LET vchrrespuesta49           = "";
LET vchrrespuesta50           = "";
LET vchrrespuestacc           = "";
LET vchrciudad                = "";

--Claves de cobranza
LET vchrclaciucobr            = "";
LET vchrclaedocobr            = "";

--Valores Puntuales
LET varpuntual18              = 0;
LET varpuntual19              = 0;
LET varpuntual20              = 0;
LET varpuntual21              = 0;
LET varpuntual22              = 0;
LET varpuntual23              = 0;
LET varpuntual24              = 0;
LET varpuntual25              = 0;
LET varpuntual26              = 0;
LET varpuntual27              = 0;
LET varpuntual28              = 0;
LET varpuntual29              = 0;
LET varpuntual30              = 0;
LET varpuntual31              = 0;
LET varpuntual32              = 0;
LET varpuntual33              = 0;
LET varpuntual35              = 0;

--Agregar variables para reporte solic_credito
LET varpuntual36              = 0;
LET varpuntual37              = 0;
LET varpuntual38              = 0;
LET varpuntual39              = 0;
LET varpuntual40              = 0;
LET varpuntual41              = 0;
LET varpuntual42              = 0;
LET varpuntual43              = 0;

--Claves de cobranza
LET declincred                = 0;
LET deceficponderada          = 0;
LET decvalor                  = 0;
LET decvalor1                 = 0;
LET decvalor2                 = 0;
LET decvalor3                 = 0;
LET decvalor4                 = 0;
LET decvalor5                 = 0;
LET decvalor6                 = 0;
LET decvalor7                 = 0;
LET decvalor8                 = 0;
LET decvalor9                 = 0;
LET decvalor10                = 0;
LET decvalor13                = 0;
LET decvalor15                = 0;
LET decvalor16                = 0;
LET decvalor17                = 0;

--INI AGREGAR VARIABLES PRUEBA TESTIGO
LET decvalor18                = 0;
LET decvalor19                = 0;
LET decvalor20                = 0;
LET decvalor21                = 0;
LET decvalor22                = 0;
LET decvalor23                = 0;
LET decvalor24                = 0;
LET decvalor25                = 0;
LET decvalor26                = 0;
LET decvalor27                = 0;
LET decvalor28                = 0;
LET decvalor29                = 0;
LET decvalor30                = 0;
LET decvalor31                = 0;
LET decvalor32                = 0;
LET decvalor33                = 0;
LET decvalor34                = 0;
LET decvalor35                = 0;

--FIN AGREGAR VARIABLES PRUEBA TESTIGO
--Agregar variables para reporte solic_credito
LET decvalor36                = 0;
LET decvalor37                = 0;
LET decvalor38                = 0;
LET decvalor39                = 0;
LET decvalor40                = 0;
LET decvalor41                = 0;
LET decvalor42                = 0;
LET decvalor43                = 0;
LET decvalor44                = 0;
LET decvalor45                = 0;
LET decvalor46                = 0;
LET decvalor47                = 0;
LET decvalor48                = 0;
LET decvalor49                = 0;
LET cStatus_Ini               = "";
LET cRevisado                 = "";
LET cIdbox                    = 0;
LET cIfe                      = "";

LET decseccion1               = 0;
LET decseccion2               = 0;
LET decsuma                   = 0;
LET intmeses                  = 0;
LET intcausasitesp            = 0;
LET intcontador               = 0;
LET intcodret                 = 0;
LET intgrupo                  = 0;
LET intelemento               = 0;
LET intsmb                    = 0;
LET intgrupoaux               = 0;
LET intelementoaux            = 0;
LET intcont                   = 0;
LET decauxsec2                = 0;
LET mnyingreso                = 0;
LET mnyingresosmb             = 0;
LET mnyimporte                = 0;
LET dEvaluacion1              = 0;
LET dEvaluacion2              = 0;
LET dSuma                     = 0;
LET iCantidad                 = 0;
LET icontadorcommit           = 0;
LET ibanderaIndice            = 0;

--INI AGREGAR VARIABLES PRUEBA TESTIGO
LET dSdoropa                  = 0;
LET dSdomuebles               = 0;
LET dSdoprestamo              = 0;
LET dSdolineatienda           = 0;
LET cPrueba                   = '';
LET cFiltroC                  = '';
LET cbcscore                  = '';
LET ctipoc                    = '';
--FIN AGREGAR VARIABLES PRUEBA TESTIGO

--398-0 FICO Extended
LET dEvaluacion3              = 0;
LET dEvaluacion4              = 0;
LET dEvaluacion5              = 0;
--398-0 FICO Extended

--INI AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS
LET v_compromisos             = 0;
LET v_causa                   = "";
LET v_status                  = "";
LET v_fecha_apert             = DATE(1);
LET v_edad                    = 0;
LET v_email                   = "";
LET v_tel_ofi                 = "";
LET v_tel_cel                 = "";
LET v_fuente                  = "";
--FIN AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS

--Respuestas puntuales
LET vchsvariable              = '';
LET decvalor_punt             = 0;

-- AGREGAR VARIABLES RQM 07 048-02 Adendum Modificaciones al SolicAAAAMMDD
LET mnyabonomensualmuebles    = 0;
LET mnyabonomensualropa       = 0;
LET mnyabonomensualprestamos  = 0;
LET mnypago_minimo            = 0;
LET chrevalua_cc              = '';
LET vDia                      = '';
LET vHora                     = '';
LET cMensajeRet               = '';
LET cgrupo_solic              = '';
LET cFlag2Credito             = '';
LET vtipoModeloHit            = '';
LET iIsamErr                  = 0;
LET intDiasContador           = 0;


BEGIN

   ON EXCEPTION SET intcodret, iIsamErr, cMensajeRet
      IF intcodret <> 0 THEN
         LET chrcodret  = intcodret;

         SELECT DBINFO('utc_to_DATEtime', sh_curtime)::DATE INTO vDia FROM sysmaster:sysshmvals;
         SELECT DBINFO('utc_to_DATEtime', sh_curtime)::DATETIME YEAR TO FRACTION INTO vHora FROM sysmaster:sysshmvals;

         INSERT INTO bdisolic:ss_bitacora_os(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
              VALUES ('Reporte de Solicitudes', SUBSTR(chrcodret,2,5), cMensajeRet || ', Error ' ||
                     ibanderaIndice || ', intDiasContador '|| intDiasContador || ', icontadorcommit' ||
                     icontadorcommit, 'informix', TODAY, vHora);

         LET chrmensaje = 'Error en la ejecuciÃ³n del REPORTE DE SOLICITUDES ' || chrnumsolicitud;

         ROLLBACK WORK;

         RETURN chrcodret, chrmensaje;
      END IF;
   END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   --SET DEBUG FILE TO "/home/sysaccapp4/ss_reportesolicitudes.out";
   --TRACE ON;

   SELECT DBINFO('utc_to_DATEtime', sh_curtime)::DATE  INTO vDia FROM sysmaster:sysshmvals;
   SELECT DBINFO('utc_to_DATEtime', sh_curtime)::DATETIME YEAR TO FRACTION INTO vHora FROM sysmaster:sysshmvals;

   INSERT INTO bdisolic:ss_bitacora_os(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES ('Reporte de Solicitudes', '00000', 'Inicio del proceso', 'informix', TODAY, vHora);

   DROP TABLE IF EXISTS bdisolic:ss_riesgos_os2;

/*
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
Tabla en disco
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
*/
CREATE TABLE bdisolic:ss_riesgos_os2 (
    numsolicitud                          CHAR(20),
    numcte                                CHAR(20),
    numctecoppel                          CHAR(20),
    sucursal                              CHAR(4),
    nombresuc                             CHAR(40),
    telsuc                                CHAR(14),
    nombregte                             CHAR(40),
    appaterno                             CHAR(26),
    apmaterno                             CHAR(26),
    nombre1                               CHAR(26),
    nombre2                               CHAR(26),
    rfc                                   CHAR(13),
    fechanac                              DATE,
    calle                                 CHAR(30),
    numext                                CHAR(10),
    numint                                CHAR(10),
    colonia                               CHAR(30),
    claciucobr                            CHAR(10),
    claedocobr                            CHAR(10),
    codpostal                             CHAR(5),
    entrecalles                           CHAR(40),
    telefono                              CHAR(13),
    estado                                CHAR(30),
    localidad                             VARCHAR(200),
    observaciones                         CHAR(80),
    statussol                             CHAR(2),
    fechasol                              DATE,
    numproducto                           CHAR(4),
    respuesta                             CHAR(1),
    feCHAResp                             DATE,
    ejecutivo                             CHAR(30),
    ingresomensual                        MONEY,
    ingresosmb                            MONEY,
    lincred                               DECIMAL(18,2),
    eficponderada                         DECIMAL(5,2),
    meses                                 SMALLINT,
    sitesp                                CHAR(1),
    causasitesp                           SMALLINT,
    descsitesp                            CHAR(80),
    tipocliente                           CHAR(03),
    filtrocliente                         CHAR(10),
    saldoropa                             DECIMAL(18,2),
    saldomuebles                          DECIMAL(18,2),
    saldoprestamo                         DECIMAL(18,2),
    lineatienda                           DECIMAL(18,2),
    bcscore                               CHAR(04),
    prueba                                CHAR(03),
    causa                                 VARCHAR(255),
    status                                VARCHAR(255),
    compromisos                           DECIMAL(14,2),
    fecha_apert                           DATE,
    edad_1                                SMALLINT,
    email                                 CHAR(60),
    tel_ofi                               CHAR(13),
    tel_cel                               CHAR(13),
    fuente                                CHAR(10),
    respuestacc                           VARCHAR(100),
    sexo                                  VARCHAR(80),
    valor_sexo                            DECIMAL(5,2),
    estado_civil                          VARCHAR(80),
    valor_estado_civil                    DECIMAL(5,2),
    tmpo_edo_civ_act                      VARCHAR(80),
    valor_tmpo_edo_civ_act                DECIMAL(5,2),
    tipo_residencia                       VARCHAR(80),
    valor_tipo_residencia                 DECIMAL(5,2),
    tmpo_dom_act                          VARCHAR(80),
    valor_tmpo_dom_act                    DECIMAL(5,2),
    ocupacion                             VARCHAR(80),
    valor_ocupacion                       DECIMAL(5,2),
    tmpo_ocup_act                         VARCHAR(80),
    valor_tmpo_ocup_act                   DECIMAL(5,2),
    tmpo_ocup_ant                         VARCHAR(80),
    valor_tmpo_ocup_ant                   DECIMAL(5,2),
    edad                                  VARCHAR(80),
    valor_edad                            DECIMAL(5,2),
    depend_econ                           VARCHAR(80),
    valor_depend_econ                     DECIMAL(5,2),
    seguro_popular                        VARCHAR(80),
    valor_seguro_popular                  DECIMAL(5,2),
    escolaridad                           VARCHAR(80) DEFAULT '',
    valor_escolaridad                     DECIMAL(5,2) DEFAULT 0.00,
    hab_domic                             VARCHAR(80) DEFAULT '',
    valor_hab_domic                       DECIMAL(5,2) DEFAULT 0.00,
    pregunta17                            VARCHAR(80) DEFAULT '',
    respuesta17                           VARCHAR(80) DEFAULT '',
    valor17                               DECIMAL(5,2) DEFAULT 0.00,
    BC_1   	                          VARCHAR(80) DEFAULT '',
    puntual_BC_1                          DECIMAL(10,4) DEFAULT 0.00,
    valor_BC_1                            DECIMAL(5,2) DEFAULT 0.00,
    BC_101                                VARCHAR(80) DEFAULT '',
    puntual_BC_101                        DECIMAL(10,4) DEFAULT 0.00,
    valor_BC_101                          DECIMAL(5,2) DEFAULT 0.00,
    BC_117                                VARCHAR(80) DEFAULT '',
    puntual_BC_117                        DECIMAL(10,4) DEFAULT 0.00,
    valor_BC_117                          DECIMAL(5,2) DEFAULT 0.00,
    BC_119                                VARCHAR(80) DEFAULT '',
    puntual_BC_119                        DECIMAL(10,4) DEFAULT 0.00,
    valor_BC_119                          DECIMAL(5,2) DEFAULT 0.00,
    BC_20                                 VARCHAR(80) DEFAULT '',
    puntual_BC_20                         DECIMAL(10,4) DEFAULT 0.00,
    valor_BC_20                           DECIMAL(5,2) DEFAULT 0.00,
    BC_421                                VARCHAR(80) DEFAULT '',
    puntual_BC_421                        DECIMAL(10,4) DEFAULT 0.00,
    valor_BC_421                          DECIMAL(5,2) DEFAULT 0.00,
    BC_85                                 VARCHAR(80) DEFAULT '',
    puntual_BC_85                         DECIMAL(10,4) DEFAULT 0.00,
    valor_BC_85                           DECIMAL(5,2) DEFAULT 0.00,
    BC_93                                 VARCHAR(80) DEFAULT '',
    puntual_BC_93                         DECIMAL(10,4) DEFAULT 0.00,
    valor_BC_93                           DECIMAL(5,2) DEFAULT 0.00,
    calc_PCT_saldo_linea                  VARCHAR(80) DEFAULT '',
    puntual_calc_PCT_saldo_linea          DECIMAL(10,4) DEFAULT 0.00,
    valor_calc_PCT_saldo_linea            DECIMAL(5,2) DEFAULT 0.00,
    meses_historia                        VARCHAR(80) DEFAULT '',
    puntual_meses_historia                DECIMAL(10,4) DEFAULT 0.00,
    valor_meses_historia                  DECIMAL(5,2) DEFAULT 0.00,
    situacion_pago                        VARCHAR(80) DEFAULT '',
    puntual_situacion_pago                DECIMAL(10,4) DEFAULT 0.00,
    valor_situacion_pago                  DECIMAL(5,2) DEFAULT 0.00,
    ratio_saldo_credit_limit              VARCHAR(80) DEFAULT '',
    puntual_ratio_saldo_credit_limit      DECIMAL(10,4) DEFAULT 0.00,
    valor_ratio_saldo_credit_limit        DECIMAL(5,2) DEFAULT 0.00,
    seccion1                              DECIMAL(14,2),
    seccion2                              DECIMAL(14,2),
    sumascoring                           DECIMAL(14,2),
    abono_muebles                         MONEY(14,2), -- abonomensualmuebles
    abono_ropa                            MONEY(14,2), -- abonomensualropa
    abono_prestamos                       MONEY(14,2), -- abonomensualprestamos
    compromisos_mensuales                 MONEY(14,2), -- pago_minimo
    evalua_cc                             CHAR(1),
    VI_EdoCiv_TmpoEdoCiv                  VARCHAR(80) DEFAULT '',
    puntual_VI_EdoCiv_TmpoEdoCiv          DECIMAL(10,4) DEFAULT 0.00,
    valor_VI_EdoCiv_TmpoEdoCiv            DECIMAL(5,2) DEFAULT 0.00,
    VI_MesesHist_CteNvo                   VARCHAR(80) DEFAULT '',
    puntual_VI_MesesHist_CteNvo           DECIMAL(10,4) DEFAULT 0.00,
    valor_VI_MesesHist_CteNvo             DECIMAL(5,2) DEFAULT 0.00,
    VI_CalcPctSdoLin_CteNvo               VARCHAR(80) DEFAULT '',
    puntual_VI_CalcPctSdoLin_CteNvo       DECIMAL(10,4) DEFAULT 0.00,
    valor_VI_CalcPctSdoLin_CteNvo         DECIMAL(5,2) DEFAULT 0.00,
    VI_SitPago_CteNvo                     VARCHAR(80) DEFAULT '',
    puntual_VI_SitPago_CteNvo             DECIMAL(10,4) DEFAULT 0.00,
    valor_VI_SitPago_CteNvo               DECIMAL(5,2) DEFAULT 0.00,
    region_cobranza                       VARCHAR(80),
    valor_region_cobranza                 DECIMAL(5,2),
    Meses_ult_cons_buro_iq                VARCHAR(80) DEFAULT '',
    puntual_Meses_ult_cons_buro_iq        DECIMAL(10,4) DEFAULT 0.00,
    valor_Meses_ult_cons_buro_iq          DECIMAL(5,2) DEFAULT 0.00,
    grupo                                 CHAR(1),
    hr0048                                VARCHAR(80) DEFAULT '',
    puntual_hr0048                        DECIMAL(10,4) DEFAULT 0.00,
    valor_hr0048                          DECIMAL(5,2) DEFAULT 0.00,
    ut0034                                VARCHAR(80) DEFAULT '',
    puntual_ut0034                        DECIMAL(10,4) DEFAULT 0.00,
    valor_ut0034                          DECIMAL(5,2) DEFAULT 0.00,
    vi_ocup_tmpo_ocup                     VARCHAR(80) DEFAULT '',
    puntual_vi_ocup_tmpo_ocup             DECIMAL(10,4) DEFAULT 0.00,
    valor_vi_ocup_tmpo_ocup               DECIMAL(5,2) DEFAULT 0.00,
    hr0050                                VARCHAR(80) DEFAULT '',
    puntual_hr0050                        DECIMAL(10,4) DEFAULT 0.00,
    valor_hr0050                          DECIMAL(5,2) DEFAULT 0.00,
    iv_trd_oldest_average_age             VARCHAR(80) DEFAULT '',
    puntual_iv_trd_oldest_average_age     DECIMAL(10,4) DEFAULT 0.00,
    valor_iv_trd_oldest_average_age       DECIMAL(5,2) DEFAULT 0.00,
    rat_monto_otorgado_CP                 VARCHAR(80) DEFAULT '',
    puntual_rat_monto_otorgado_CP         DECIMAL(10,4) DEFAULT 0.00,
    valor_rat_monto_otorgado_CP           DECIMAL(5,2) DEFAULT 0.00,
    iq0002                                VARCHAR(80) DEFAULT '',
    puntual_iq0002                        DECIMAL(10,4) DEFAULT 0.00,
    valor_iq0002                          DECIMAL(5,2) DEFAULT 0.00,
    iv_ocup_escolar                       VARCHAR(80) DEFAULT '',
    puntual_iv_ocup_escolar               DECIMAL(10,4) DEFAULT 0.00,
    valor_iv_ocup_escolar                 DECIMAL(5,2) DEFAULT 0.00,
    grupo_originacion                     VARCHAR(80) DEFAULT '',
    valor_grupo_originacion               DECIMAL(5,2) DEFAULT 0.00,
    ingreso_mensual                       VARCHAR(80) DEFAULT '',
    valor_ingreso_mensual                 DECIMAL(5,2) DEFAULT 0.00,
    iv_sexo_edad                          VARCHAR(80) DEFAULT '',
    valor_iv_sexo_edad                    DECIMAL(5,2) DEFAULT 0.00,
    iv_entidad_localidad                  VARCHAR(80) DEFAULT '',
    valor_iv_entidad_localidad            DECIMAL(5,2) DEFAULT 0.00,
    iv_sexo_ocupacion                     VARCHAR(80) DEFAULT '',
    valor_iv_sexo_ocupacion               DECIMAL(5,2) DEFAULT 0.00,
    iv_edociv_escolaridad                 VARCHAR(80) DEFAULT '',
    valor_iv_edociv_escolaridad           DECIMAL(5,2) DEFAULT 0.00,
    iv_edad_escolaridad                   VARCHAR(80) DEFAULT '',
    valor_iv_edad_escolaridad             DECIMAL(5,2) DEFAULT 0.00,
    seccion3                              DECIMAL(14,2),
    seccion4                              DECIMAL(14,2),
    seccion5                              DECIMAL(14,2),
    flag2creditoicc                       CHAR(60),
    statusini                             CHAR(2),
    revisado                              CHAR(2),
    ife                                   CHAR(2),
    tipo_modelo_hit                       CHAR(5)
    ) IN dbssc_sdodiarioc02;

/*
----------------------------------------------------------------------------------------------
Tabla Temporal
----------------------------------------------------------------------------------------------
*/
	CREATE TEMP TABLE ss_riesgos_os_temp2 (
		numsolicitud  	CHAR(20),
		numcte        	CHAR(20),
		numctecoppel  	CHAR(20),
		sucursal      	CHAR(4),
		nombresuc     	CHAR(40),
		telsuc        	CHAR(14),
		nombregte     	CHAR(40),
		appaterno     	CHAR(26),
		apmaterno     	CHAR(26),
		nombre1       	CHAR(26),
		nombre2       	CHAR(26),
		rfc           	CHAR(13),
		fechanac      	DATE,
		calle         	CHAR(30),
		numext        	CHAR(10),
		numint        	CHAR(10),
		colonia       	CHAR(30),
		claciucobr    	CHAR(10),
		claedocobr    	CHAR(10),
		codpostal     	CHAR(5),
		entrecalles   	CHAR(40),
		telefono      	CHAR(13),
		estado        	CHAR(30),
		localidad     	VARCHAR(200),
		observaciones 	CHAR(80),
		statussol     	CHAR(2),
		fechasol      	DATE,
		numproducto   	CHAR(4),
		respuesta     	CHAR(1),
		feCHAResp     	DATE,
		ejecutivo     	CHAR(30),
		ingresomensual	MONEY,
		ingresosmb    	MONEY,
		lincred       	DECIMAL(18,2),
		eficponderada 	DECIMAL(5,2),
		meses         	SMALLINT,
		sitesp        	CHAR(1),
		causasitesp   	SMALLINT,
		descsitesp    	CHAR(80),
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
		tipocliente     CHAR(03),
		filtrocliente   CHAR(10),
		saldoropa       DECIMAL(18,2),
		saldomuebles    DECIMAL(18,2),
		saldoprestamo   DECIMAL(18,2),
		lineatienda     DECIMAL(18,2),
		bcscore         CHAR(04),
		prueba          CHAR(03),
--JANETH SE AGREGAN CAMPOS : CAUSAS/CANCELACION-RECHAZO, COMENTARIO STATUS, COMPROMISO MENSUAL, FECHA APERTURA, EDAD, E-MAIL, TEL OFIC, TEL CEL.	Y FUENTE
		causa           VARCHAR(255),
		status       	VARCHAR(255),
		compromisos     DECIMAL(14,2),
		fecha_apert     DATE,
		edad_1          SMALLINT,
		email           CHAR(60),
		tel_ofi         CHAR(13),
		tel_cel         CHAR(13),
		fuente          CHAR(10),
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
		respuestacc   			VARCHAR(100),
		sexo    				VARCHAR(80),
		valor_sexo        		DECIMAL(5,2),
		estado_civil    		VARCHAR(80),
		valor_estado_civil      DECIMAL(5,2),
		tmpo_edo_civ_act    	VARCHAR(80),
		valor_tmpo_edo_civ_act  DECIMAL(5,2),
		tipo_residencia    		VARCHAR(80),
		valor_tipo_residencia   DECIMAL(5,2),
		tmpo_dom_act    		VARCHAR(80),
		valor_tmpo_dom_act      DECIMAL(5,2),
		ocupacion    			VARCHAR(80),
		valor_ocupacion        	DECIMAL(5,2),
		tmpo_ocup_act    		VARCHAR(80),
		valor_tmpo_ocup_act     DECIMAL(5,2),
		tmpo_ocup_ant    		VARCHAR(80),
		valor_tmpo_ocup_ant     DECIMAL(5,2),
		edad    				VARCHAR(80),
		valor_edad        		DECIMAL(5,2),
		depend_econ   			VARCHAR(80),
		valor_depend_econ      	DECIMAL(5,2),
		seguro_popular   		VARCHAR(80),
		valor_seguro_popular    DECIMAL(5,2),
		escolaridad   			VARCHAR(80) DEFAULT '',
		valor_escolaridad      	DECIMAL(5,2) DEFAULT 0.00,
		hab_domic   			VARCHAR(80) DEFAULT '',
		valor_hab_domic       	DECIMAL(5,2) DEFAULT 0.00,
		pregunta17    			VARCHAR(80) DEFAULT '',
		respuesta17   			VARCHAR(80) DEFAULT '',
		valor17       			DECIMAL(5,2) DEFAULT 0.00,
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
		--pregunta18    	VARCHAR(80) DEFAULT '',
		BC_1   				VARCHAR(80) DEFAULT '',
		puntual_BC_1		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_1      	DECIMAL(5,2) DEFAULT 0.00,
		BC_101   			VARCHAR(80) DEFAULT '',
		puntual_BC_101		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_101       	DECIMAL(5,2) DEFAULT 0.00,
		BC_117   			VARCHAR(80) DEFAULT '',
		puntual_BC_117		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_117      	DECIMAL(5,2) DEFAULT 0.00,
		BC_119   			VARCHAR(80) DEFAULT '',
		puntual_BC_119		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_119      	DECIMAL(5,2) DEFAULT 0.00,
		BC_20   			VARCHAR(80) DEFAULT '',
		puntual_BC_20		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_20       	DECIMAL(5,2) DEFAULT 0.00,
		BC_421   			VARCHAR(80) DEFAULT '',
		puntual_BC_421		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_421       	DECIMAL(5,2) DEFAULT 0.00,
		BC_85   			VARCHAR(80) DEFAULT '',
		puntual_BC_85		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_85       	DECIMAL(5,2) DEFAULT 0.00,
		BC_93   			VARCHAR(80) DEFAULT '',
		puntual_BC_93		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_93       	DECIMAL(5,2) DEFAULT 0.00,
		calc_PCT_saldo_linea				VARCHAR(80) DEFAULT '',
		puntual_calc_PCT_saldo_linea		DECIMAL(10,4) DEFAULT 0.00,
		valor_calc_PCT_saldo_linea       	DECIMAL(5,2) DEFAULT 0.00,
		meses_historia   			VARCHAR(80) DEFAULT '',
		puntual_meses_historia		DECIMAL(10,4) DEFAULT 0.00,
		valor_meses_historia       	DECIMAL(5,2) DEFAULT 0.00,
		situacion_pago   			VARCHAR(80) DEFAULT '',
		puntual_situacion_pago		DECIMAL(10,4) DEFAULT 0.00,
		valor_situacion_pago       	DECIMAL(5,2) DEFAULT 0.00,
		ratio_saldo_credit_limit   	VARCHAR(80) DEFAULT '',
		puntual_ratio_saldo_credit_limit		DECIMAL(10,4) DEFAULT 0.00,
		valor_ratio_saldo_credit_limit      	DECIMAL(5,2) DEFAULT 0.00,
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
		seccion1      	DECIMAL(14,2),
		seccion2      	DECIMAL(14,2),
		sumascoring   	DECIMAL(14,2),
-- AGREGAR VARIABLES RQM 07 048-02 Adendum Modificaciones al SolicAAAAMMDD. sept 2012
		abono_muebles                MONEY(14,2), -- abonomensualmuebles
		abono_ropa                   MONEY(14,2), -- abonomensualropa
		abono_prestamos              MONEY(14,2), -- abonomensualprestamos
		compromisos_mensuales        MONEY(14,2), -- pago_minimo
		evalua_cc                    CHAR(1),
		VI_EdoCiv_TmpoEdoCiv            VARCHAR(80) DEFAULT '',
		puntual_VI_EdoCiv_TmpoEdoCiv	DECIMAL(10,4) DEFAULT 0.00,
		valor_VI_EdoCiv_TmpoEdoCiv      DECIMAL(5,2) DEFAULT 0.00,
		VI_MesesHist_CteNvo             VARCHAR(80) DEFAULT '',
		puntual_VI_MesesHist_CteNvo     DECIMAL(10,4) DEFAULT 0.00,
		valor_VI_MesesHist_CteNvo       DECIMAL(5,2) DEFAULT 0.00,
		VI_CalcPctSdoLin_CteNvo   		VARCHAR(80) DEFAULT '',
		puntual_VI_CalcPctSdoLin_CteNvo DECIMAL(10,4) DEFAULT 0.00,
		valor_VI_CalcPctSdoLin_CteNvo   DECIMAL(5,2) DEFAULT 0.00,
		VI_SitPago_CteNvo   			VARCHAR(80) DEFAULT '',
		puntual_VI_SitPago_CteNvo       DECIMAL(10,4) DEFAULT 0.00,
		valor_VI_SitPago_CteNvo         DECIMAL(5,2) DEFAULT 0.00,
		region_cobranza                 VARCHAR(80),
		valor_region_cobranza           DECIMAL(5,2),
		Meses_ult_cons_buro_iq   		VARCHAR(80) DEFAULT '',
		puntual_Meses_ult_cons_buro_iq	DECIMAL(10,4) DEFAULT 0.00,
		valor_Meses_ult_cons_buro_iq     DECIMAL(5,2) DEFAULT 0.00,
		grupo                           CHAR(1),
--MJPC agregar variables para reporte solic_credito
		hr0048							VARCHAR(80) DEFAULT '',
		puntual_hr0048					DECIMAL(10,4) DEFAULT 0.00,
		valor_hr0048					DECIMAL(5,2) DEFAULT 0.00,
		ut0034							VARCHAR(80) DEFAULT '',
		puntual_ut0034					DECIMAL(10,4) DEFAULT 0.00,
		valor_ut0034					DECIMAL(5,2) DEFAULT 0.00,
		vi_ocup_tmpo_ocup				VARCHAR(80) DEFAULT '',
		puntual_vi_ocup_tmpo_ocup		DECIMAL(10,4) DEFAULT 0.00,
		valor_vi_ocup_tmpo_ocup			DECIMAL(5,2) DEFAULT 0.00,
		hr0050							VARCHAR(80) DEFAULT '',
		puntual_hr0050					DECIMAL(10,4) DEFAULT 0.00,
		valor_hr0050					DECIMAL(5,2) DEFAULT 0.00,
		iv_trd_oldest_average_age			VARCHAR(80) DEFAULT '',
		puntual_iv_trd_oldest_average_age	DECIMAL(10,4) DEFAULT 0.00,
		valor_iv_trd_oldest_average_age		DECIMAL(5,2) DEFAULT 0.00,
		rat_monto_otorgado_CP				VARCHAR(80) DEFAULT '',
		puntual_rat_monto_otorgado_CP		DECIMAL(10,4) DEFAULT 0.00,
		valor_rat_monto_otorgado_CP			DECIMAL(5,2) DEFAULT 0.00,
		iq0002								VARCHAR(80) DEFAULT '',
		puntual_iq0002						DECIMAL(10,4) DEFAULT 0.00,
		valor_iq0002						DECIMAL(5,2) DEFAULT 0.00,
		iv_ocup_escolar						VARCHAR(80) DEFAULT '',
		puntual_iv_ocup_escolar				DECIMAL(10,4) DEFAULT 0.00,
		valor_iv_ocup_escolar				DECIMAL(5,2) DEFAULT 0.00,
--MJPC variables Anexo Solic
		grupo_originacion					VARCHAR(80) DEFAULT '',
		valor_grupo_originacion				DECIMAL(5,2) DEFAULT 0.00,
		ingreso_mensual						VARCHAR(80) DEFAULT '',
		valor_ingreso_mensual				DECIMAL(5,2) DEFAULT 0.00,
		iv_sexo_edad						VARCHAR(80) DEFAULT '',
		valor_iv_sexo_edad					DECIMAL(5,2) DEFAULT 0.00,
		iv_entidad_localidad						VARCHAR(80) DEFAULT '',
		valor_iv_entidad_localidad					DECIMAL(5,2) DEFAULT 0.00,
		iv_sexo_ocupacion							VARCHAR(80) DEFAULT '',
		valor_iv_sexo_ocupacion						DECIMAL(5,2) DEFAULT 0.00,
		iv_edociv_escolaridad							VARCHAR(80) DEFAULT '',
		valor_iv_edociv_escolaridad						DECIMAL(5,2) DEFAULT 0.00,
		iv_edad_escolaridad								VARCHAR(80) DEFAULT '',
		valor_iv_edad_escolaridad						DECIMAL(5,2) DEFAULT 0.00,
--IPCB Marzo2016 RQM 09 398-0 FICO Extended
		seccion3  				DECIMAL(14,2),
		seccion4  				DECIMAL(14,2),
		seccion5				DECIMAL(14,2),
		flag2creditoicc         CHAR(60),
		statusini CHAR(2),
		revisado CHAR(2),
		ife CHAR(2),
		tipo_modelo_hit CHAR(5)
		) WITH NO LOG;

/*
----------------------------------------------------------------------------------------------
Fin de Tabla Temporal
----------------------------------------------------------------------------------------------
*/


--    alter table ss_riesgos_os2 type (RAW);

   FOREACH cur_00a WITH HOLD FOR
      SELECT TRIM(sol.num_solicitud), TRIM(sol.numcte), TRIM(sol.sucursal),
             TRIM(cli.apell_paterno), TRIM(cli.apell_materno), TRIM(cli.nombre1),
             TRIM(cli.nombre2), TRIM(cli.numcte_ref), TRIM(cli.rfc),
             cte.fecha_nac, TRIM(sol.status_solicitud), sol.fecha_insert,
             TRIM(sol.num_producto), sol.monto_solicitado,
             TRIM(sol.user_insert), NVL(sol.dia_para_revisar,'')
        INTO chrnumsolicitud, chrnumcte, chrsucursal, chrappaterno, chrapmaterno,
             chrnombre1, chrnombre2, chrnumctecoppel, chrrfc, dtefechanac, chrstatussol,
             dtefechasol, chrnumproducto, declincred, chrejecutivo, cPrueba
        FROM bdisolic:ss_solicitudes sol
       INNER JOIN bdinteg:si_cliente cli ON sol.numcte = cli.numcte
       INNER JOIN bdinteg:si_ctepf cte ON cli.numcte = cte.numcte
       WHERE cli.tpo_persona = '01'
         AND sol.empresa = '001'
         AND sol.fecha_insert >= TODAY - 35
         AND sol.empresa = '001'


      SELECT NVL(res.situacion_pago,0), NVL(res.meses_historia,0), NVL(TRIM(res.motivo_cc),''),
             NVL(res.saldoropa,0), NVL(res.saldomuebles,0), NVL(res.saldoprestamos,0),
             NVL(res.linea_tienda,0), (res.evalua_cc), '', res.grupo
        INTO deceficponderada, intmeses, vchrrespuestacc, dSdoropa, dSdomuebles, dSdoprestamo,
             dSdolineatienda, cFiltroC, ctipoc, cgrupo_solic
        FROM bdisolic:ss_resum_scor_fin res
       WHERE res.num_solicitud = chrnumsolicitud
         AND res.empresa = '001';


      SELECT CASE WHEN res2.flag2creditoicc = '1' THEN 'EvaluaciÃ³n de Segundo producto de crÃ©dito en adelante'
                ELSE ' '
             END
        INTO cFlag2Credito
        FROM bdisolic:ss_revision_determinacion res2
       WHERE res2.empresa = '001'
         AND res2.num_solicitud = chrnumsolicitud;


      SELECT TRIM(nombre), TRIM(telefono1), TRIM(gerente)
        INTO chrnombresuc, chrtelsuc, chrnombregte
        FROM bdinteg:si_sucursales
       WHERE sucursal = chrsucursal;


      IF cPrueba <> '' THEN
         LET cPrueba = 'E84';
      END IF;

      IF cFiltroC = 'X' THEN
         LET cFiltroC = 'NO HIT';
      ELSE
         LET cFiltroC = 'HIT';
      END IF;

      IF intmeses >= 13 AND deceficponderada >= 85 THEN
         LET ctipoc = 'I';
      ELIF intmeses >= 6 AND deceficponderada >= 85 THEN
         LET ctipoc = 'II';
      ELSE
         LET ctipoc = 'II';
      END IF;

      IF (icontadorcommit = 0) THEN
         BEGIN WORK;
      END IF;

      SELECT e.descripcion,
             (SELECT descripcion FROM ss_status_sol WHERE empresa = '001' AND status_solicitud = a.status_solicitud),
             b.fecha_apertura, TRUNC((a.fecha_insert - cte.fecha_nac) / 365,0) edad,
             (SELECT telefono FROM bdinteg:si_telefonos_actual b
               WHERE a.empresa = b.empresa AND a.numcte = b.numcte AND b.tipo_tel = '4') tel_ofi,
             (SELECT telefono FROM bdinteg:si_telefonos_actual b
               WHERE a.empresa = b.empresa AND a.numcte = b.numcte AND b.tipo_tel = '2') tel_cel,
             DECODE(f.fuente,'T','TIENDA','B','BANCO','','BANCO'), pago_minimo
        INTO v_causa, v_status, v_fecha_apert, v_edad, v_tel_ofi, v_tel_cel, v_fuente, v_compromisos
        FROM bdisolic:ss_solicitudes a
        LEFT JOIN bdicred:sd_maecred b ON (a.empresa = b.empresa AND a.num_solicitud = b.num_credito)
       INNER JOIN bdisolic:ss_autorizacion c ON (c.empresa = a.empresa
                                                 AND c.num_solicitud = a.num_solicitud
                                                 AND c.status_solicitud = a.status_solicitud
                                                 AND c.rowid = (SELECT MAX(rowid)
                                                                  FROM bdisolic:ss_autorizacion
                                                                 WHERE empresa = a.empresa
                                                                   AND num_solicitud = a.num_solicitud
                                                                   AND status_solicitud = a.status_solicitud))
        LEFT OUTER JOIN bdisolic:ss_causas_sol e ON (a.empresa = e.empresa
                                                     AND e.status_solicitud = c.status_solicitud
                                                     AND e.causa_solicitud = c.causa_solicitud)
       INNER JOIN bdinteg:si_ctepf cte ON (a.numcte = cte.numcte)
       INNER JOIN bdisolic:ss_resum_scor_fin f ON (a.empresa = f.empresa
                                                   AND a.num_solicitud = f.num_solicitud)
       WHERE a.empresa = '001'
         AND a.num_solicitud = chrnumsolicitud;

      LET v_causa = trim(v_causa);

      IF v_causa IS NULL THEN LET v_causa = ''; END IF;
      IF v_status IS NULL THEN LET v_status = ''; END IF;
      IF v_fecha_apert IS NULL THEN LET v_fecha_apert = ''; END IF;
      IF v_edad IS NULL THEN LET v_edad = ''; END IF;
      IF v_tel_ofi IS NULL THEN LET v_tel_ofi = ''; END IF;
      IF v_tel_cel IS NULL THEN LET v_tel_cel = ''; END IF;
      IF v_fuente IS NULL THEN LET v_fuente = ''; END IF;
      IF v_compromisos IS NULL THEN LET v_compromisos = 0; END IF;

      --Obtengo el email
      SELECT corre.correo_elec INTO v_email
        FROM bdinteg:si_correos corre
       WHERE corre.empresa = '001'
         AND corre.numcte = chrnumcte
         AND corre.status_correo = 'A'
         AND corre.secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_correos
                                 WHERE empresa = corre.empresa
                                   AND numcte = chrnumcte
                                   AND status_correo = corre.status_correo);

      LET v_email = TRIM(v_email);

      IF v_email IS NULL THEN LET v_email = ''; END IF;

      --Obtiene la direccion del cliente(persona fisica)
      SELECT NVL(TRIM(REPLACE(dir.entre_calles,'|','')),''), NVL(TRIM(dir.cod_postal),''),
             NVL(TRIM(dir.numeroextcalle),''), NVL(TRIM(dir.numerointcalle),''),
             NVL(TRIM(cal.nombrecalle),''), NVL(TRIM(zon.nombrezona),''),
             NVL(TRIM(REPLACE(dir.observaciones,'|','')),''), NVL(TRIM(edo.nombre),''),
             NVL(TRIM(ciu.nombre),''), NVL(TRIM(tel.telefono),''),
             dir.numerociudad || '-' || TRIM(catciu.inicialciudad) Ciudad, -- Clave ciudad
             catciu.numeroestado || '-' || TRIM(catciu.inicialestado) Estado -- Clave estado
        INTO chrentrecalles, chrcodpostal, chrnumext, chrnumint, chrnombrecalle, chrnombrezona,
             chrobservaciones, chrestado, vchrciudad, chrtelefono, vchrclaciucobr, vchrclaedocobr
        FROM bdinteg:si_direcciones_actual dir
        LEFT OUTER JOIN bdinteg:si_telefonos_actual tel ON (tel.empresa = '001'
                                                            AND dir.numcte = tel.numcte AND tipo_tel = '1')
        LEFT OUTER JOIN bdinteg:si_catcalles cal ON (cal.numerocalle = dir.numerocalle)
        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad
                                                    AND zon.numerocolonia = dir.numerocolonia)
        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.pais = '001' AND edo.estado = dir.estado)
        LEFT OUTER JOIN bdinteg:si_ciudades ciu ON (ciu.pais = dir.pais AND ciu.estado = dir.estado
                                                    AND ciu.ciudad = dir.ciudad)
        LEFT OUTER JOIN bdinteg:si_catciudades catciu ON (dir.numerociudad = catciu.numerociudad)
       WHERE dir.numcte = chrnumcte
         AND dir.tipo_dir = '1';

      --Obtiene la respuesta de la os y su fecha
      SELECT status, fecha_respuesta INTO chrrespuesta,dtefeCHAResp
        FROM bdisolic:ss_solicitud_os
       WHERE empresa = '001'
         AND num_solicitud = chrnumsolicitud
         AND secuenciaos = (SELECT MAX(secuenciaos)
                              FROM bdisolic:ss_solicitud_os
                             WHERE empresa = '001'
                               AND num_solicitud = chrnumsolicitud
                               AND fecha_solicitud > DATE(0))
         AND fecha_solicitud = (SELECT MAX(fecha_solicitud)
                                  FROM bdisolic:ss_solicitud_os
                                 WHERE empresa = '001'
                                   AND num_solicitud = chrnumsolicitud);

      LET chrrespuesta = TRIM(chrrespuesta);

      IF chrrespuesta IS NULL THEN
         LET chrrespuesta = '';
      END IF;


      --Obtiene la situacion especial de la os y su causa
      SELECT situacionespecial, NVL(causasituacionespecial,0) INTO chrsitesp, intcausasitesp
        FROM bdisolic:ss_osclientesupervisar
       WHERE empresa = '001'
         AND num_solicitud = chrnumsolicitud
         AND fechasolicitud = (SELECT MAX(fechasolicitud)
                                 FROM bdisolic:ss_osclientesupervisar
                                WHERE empresa = '001'
                                  AND num_solicitud = chrnumsolicitud
                                  AND fechasolicitud > DATE(0));


      LET chrsitesp = TRIM(chrsitesp);

      IF chrsitesp IS NOT NULL AND intcausasitesp IS NOT NULL THEN
         --Obtiene la explicacion de la causa de la situacion especial del cliente
         SELECT NVL(descripcion,'') INTO chrdescsitesp
           FROM bdicred:sd_causas_os
          WHERE empresa = '001'
            AND situacion = chrsitesp
            AND causa = intcausasitesp;

         LET chrdescsitesp = TRIM(chrdescsitesp);

         IF chrdescsitesp <> '' THEN
            SELECT NVL(descripcion,'') INTO chrdescsitesp
              FROM bdicred:sd_causas_os
             WHERE empresa = '001'
               AND situacion = chrsitesp
               AND causa = intcausasitesp;

            LET chrdescsitesp = TRIM(chrdescsitesp);

         ELSE
            LET chrdescsitesp = '';
         END IF;
      ELSE
         LET intcausasitesp = 0;
         LET chrsitesp = '';
         LET chrdescsitesp = '';
      END IF;

      --Obtiene el parametro del Salario Minimo BanCoppel
      SELECT NVL(valor,0) * 1 INTO intsmb
        FROM bdisolic:ss_param
       WHERE secuencia = 303
         AND empresa = '001';

      --Obtiene el ingreso mensual declarado por el cliente y el ingreso en SMB
      --Obtener los abonosmensuales en ropa, muebles y prestamo, el pago minimo y evalua_cc
      SELECT ROUND(NVL(ingreso_mensual,0),2), NVL(abonomensualmuebles,0), NVL(abonomensualropa,0),
             NVL(abonomensualprestamos,0), NVL(pago_minimo,0), evalua_cc
        INTO mnyingreso, mnyabonomensualmuebles, mnyabonomensualropa, mnyabonomensualprestamos,
             mnypago_minimo, chrevalua_cc
        FROM bdisolic:ss_resum_scor_fin
       WHERE empresa = '001'
         AND num_solicitud = chrnumsolicitud;

      --Obtiene el ingreso mensual declarado por el cliente y el ingreso en SMB
      SELECT ROUND(NVL(ingreso_mensual,0),2) INTO mnyingreso
        FROM bdisolic:ss_resum_scor_fin
       WHERE empresa = '001'
         AND num_solicitud = chrnumsolicitud;

      LET mnyingresosmb = ROUND(NVL(mnyingreso,0)/intsmb);

      --Obtiene el detalle del scoring seccion 2
      LET vchrrespuesta1       = '';
      LET vchrrespuesta2       = '';
      LET vchrrespuesta3       = '';
      LET vchrrespuesta4       = '';
      LET vchrrespuesta5       = '';
      LET vchrrespuesta6       = '';
      LET vchrrespuesta7       = '';
      LET vchrrespuesta8       = '';
      LET vchrrespuesta9       = '';
      LET vchrrespuesta10      = '';
      LET vchrrespuesta13      = '';
      LET vchrrespuesta15      = '';
      LET vchrrespuesta16      = '';
      LET vchrpregunta17       = '';
      LET vchrrespuesta17      = '';
      LET vchrrespuesta18      = '';
      LET vchrrespuesta19      = '';
      LET vchrrespuesta20      = '';
      LET vchrrespuesta21      = '';
      LET vchrrespuesta22      = '';
      LET vchrrespuesta23      = '';
      LET vchrrespuesta24      = '';
      LET vchrrespuesta25      = '';
      LET vchrrespuesta26      = '';
      LET vchrrespuesta27      = '';
      LET vchrrespuesta28      = '';
      LET vchrrespuesta29      = '';
      LET vchrrespuesta30      = '';
      LET vchrrespuesta31      = '';
      LET vchrrespuesta32      = '';
      LET vchrrespuesta33      = '';
      LET vchrrespuesta34      = '';
      LET vchrrespuesta35      = '';
      LET vchrrespuesta36      = '';
      LET vchrrespuesta37      = '';
      LET vchrrespuesta38      = '';
      LET vchrrespuesta39      = '';
      LET vchrrespuesta40      = '';
      LET vchrrespuesta41      = '';
      LET vchrrespuesta42      = '';
      LET vchrrespuesta43      = '';
      LET vchrrespuesta44      = '';
      LET vchrrespuesta45      = '';
      LET vchrrespuesta46      = '';
      LET vchrrespuesta47      = '';
      LET vchrrespuesta48      = '';
      LET vchrrespuesta49      = '';
      LET vchrrespuesta50      = '';
      LET varpuntual18         = 0;
      LET varpuntual19         = 0;
      LET varpuntual20         = 0;
      LET varpuntual21         = 0;
      LET varpuntual22         = 0;
      LET varpuntual23         = 0;
      LET varpuntual24         = 0;
      LET varpuntual25         = 0;
      LET varpuntual26         = 0;
      LET varpuntual27         = 0;
      LET varpuntual28         = 0;
      LET varpuntual29         = 0;
      LET varpuntual30         = 0;
      LET varpuntual31         = 0;
      LET varpuntual32         = 0;
      LET varpuntual33         = 0;
      LET varpuntual35         = 0;
      LET varpuntual36         = 0;
      LET varpuntual37         = 0;
      LET varpuntual38         = 0;
      LET varpuntual39         = 0;
      LET varpuntual40         = 0;
      LET varpuntual41         = 0;
      LET varpuntual42         = 0;
      LET varpuntual43         = 0;
      LET decvalor1            = 0;
      LET decvalor2            = 0;
      LET decvalor3            = 0;
      LET decvalor4            = 0;
      LET decvalor5            = 0;
      LET decvalor6            = 0;
      LET decvalor7            = 0;
      LET decvalor8            = 0;
      LET decvalor9            = 0;
      LET decvalor10           = 0;
      LET decvalor13           = 0;
      LET decvalor15           = 0;
      LET decvalor16           = 0;
      LET decvalor17           = 0;
      LET decvalor18           = 0;
      LET decvalor19           = 0;
      LET decvalor20           = 0;
      LET decvalor21           = 0;
      LET decvalor22           = 0;
      LET decvalor23           = 0;
      LET decvalor24           = 0;
      LET decvalor25           = 0;
      LET decvalor26           = 0;
      LET decvalor27           = 0;
      LET decvalor28           = 0;
      LET decvalor29           = 0;
      LET decvalor30           = 0;
      LET decvalor31           = 0;
      LET decvalor32           = 0;
      LET decvalor33           = 0;
      LET decvalor34           = 0;
      LET decvalor35           = 0;
      LET decvalor36           = 0;
      LET decvalor37           = 0;
      LET decvalor38           = 0;
      LET decvalor39           = 0;
      LET decvalor40           = 0;
      LET decvalor41           = 0;
      LET decvalor42           = 0;
      LET decvalor43           = 0;
      LET decvalor44           = 0;
      LET decvalor45           = 0;
      LET decvalor46           = 0;
      LET decvalor47           = 0;
      LET decvalor48           = 0;
      LET decvalor49           = 0;
      LET decvalor50           = 0;
      LET cStatus_Ini          = '';
      LET cRevisado            = '';
      LET cIdbox               = 0;
      LET cIfe                 = '';

      --Obtener la edad como valor puntual respuesta9
      SELECT YEAR(a.fecha_insert) - YEAR(fecha_nac) INTO vchrrespuesta9
        FROM bdisolic:ss_solicitudes a
       INNER JOIN bdinteg:si_ctepf cte ON (cte.numcte = a.numcte)
       WHERE a.empresa = '001'
         AND a.num_solicitud = chrnumsolicitud;


      FOREACH
         SELECT variable, NVL(valor,0) INTO vchsvariable, decvalor_punt
           FROM bdisolic:ss_detalle_modelo
          WHERE empresa = '001'
            AND num_solicitud = chrnumsolicitud

         IF vchsvariable = 'BC_1' THEN
            LET varpuntual18 = decvalor_punt;
         ELIF vchsvariable = 'BC_101' THEN
            LET varpuntual19 = decvalor_punt;
         ELIF vchsvariable = 'BC_117' THEN
            LET varpuntual20 = decvalor_punt;
         ELIF vchsvariable = 'BC_119' THEN
            LET varpuntual21 = decvalor_punt;
         ELIF vchsvariable = 'BC_20' THEN
            LET varpuntual22 = decvalor_punt;
         ELIF vchsvariable = 'BC_421' THEN
            LET varpuntual23 = decvalor_punt;
         ELIF vchsvariable = 'BC_85' THEN
            LET varpuntual24 = decvalor_punt;
         ELIF vchsvariable = 'BC_93' THEN
            LET varpuntual25 = decvalor_punt;
         ELIF vchsvariable = 'CALC_PCT_SALDO_LIMIT' THEN
            LET varpuntual29 = decvalor_punt;
         ELIF vchsvariable = 'CALC_PCT_SALDO_LINEA' THEN
            LET varpuntual26 = decvalor_punt;
         ELIF vchsvariable = 'PMESESHIST' THEN
            LET varpuntual27 = decvalor_punt;
         ELIF vchsvariable = 'PSITUACIONPAGOCOPPEL' THEN
            LET varpuntual28 = decvalor_punt;
         ELIF vchsvariable = 'EDO_CIVIL_&_TIEMPO_ESTADO_CIVIL' THEN
            LET varpuntual30 = decvalor_punt;
         ELIF vchsvariable = 'MESES_HISTORIA_&_CLIENTE_NUEVO' THEN
            LET varpuntual31 = decvalor_punt;
         ELIF vchsvariable = 'CALC_PCT_SALDO_LINEA_&_CLIENTE_NUEVO' THEN
            LET varpuntual32 = decvalor_punt;
         ELIF vchsvariable = 'SITUACION_PAGO_&_CLIENTE_NUEVO' THEN
            LET varpuntual33 = decvalor_punt;
         ELIF vchsvariable = 'MESES_ULTIMA_CONSULTA' THEN
            LET varpuntual35 = decvalor_punt;
         ELIF vchsvariable = 'HR0048' THEN
            LET varpuntual36 = decvalor_punt;
         ELIF vchsvariable = 'UT0034' THEN
            LET varpuntual37 = decvalor_punt;
         --valor puntual OCUPACION_&_TIEMPO_OCUPACION
         ELIF vchsvariable = 'OCUPACION_&_TIEMPO_OCUPACION' THEN
            LET varpuntual38 = decvalor_punt;
         --valor puntual HR0050
         ELIF vchsvariable = 'HR0050' THEN
            LET varpuntual39 = decvalor_punt;
         --valor puntual IV_TRD_OLDEST_AVERAGE_AGE
         ELIF vchsvariable = 'IV_TRD_OLDEST_AVERAGE_AGE' THEN
            LET varpuntual40 = decvalor_punt;
         --valor puntual RAT_MONTO_OTORGADO_CP
         ELIF vchsvariable = 'RAT_MONTO_OTORGADO_CP' THEN
            LET varpuntual41 = decvalor_punt;
         --valor puntual IQ0002
         ELIF vchsvariable = 'IQ0002' THEN
            LET varpuntual42 = decvalor_punt;
         --valor puntual IV_OCUP_ESCOL
         ELIF vchsvariable = 'IV_OCUP_ESCOL' THEN
            LET varpuntual43 = decvalor_punt;
         END IF;
      END FOREACH;


      FOREACH
         SELECT a.descripcion, c.descripcion, NVL(b.valor,0), a.grupo, c.elemento
           INTO vchrpregunta, vchrrespuesta, decvalor, intgrupo, intelemento
           FROM ss_scoring_grupo a, ss_detalle_scoring b, ss_scoring_element c
          WHERE a.empresa = '001'
            AND a.seccion = 2
            AND b.num_solicitud = chrnumsolicitud
            AND b.tpo_persona = '01'
            AND a.empresa = b.empresa
            AND a.grupo <> 25       --Grupo OS Telefonica
            AND a.grupo = b.grupo
            AND a.grupo = c.grupo
            AND a.seccion = b.seccion
            AND a.seccion = c.seccion
            AND b.elemento = c.elemento
            AND b.tpo_persona = c.tpo_persona
          ORDER BY b.seccion, b.grupo, b.elemento

         LET vchrpregunta = TRIM(vchrpregunta);
         LET vchrrespuesta = TRIM(vchrrespuesta);

         IF intgrupo = 2 THEN
            LET vchrrespuesta1 = vchrrespuesta;
            LET decvalor1 = decvalor;
         ELIF intgrupo = 3 THEN
            LET intelementoaux = intelemento;
            LET intgrupoaux = intgrupo;
            LET vchrrespuesta2 = vchrrespuesta;
            LET decvalor2 = decvalor;
         ELIF intgrupo = 4 THEN
            LET vchrrespuesta3 = vchrrespuesta;
            LET decvalor3 = decvalor;
         ELIF intgrupo = 5 THEN
            LET vchrrespuesta4 = vchrrespuesta;
            LET decvalor4 = decvalor;
         ELIF intgrupo = 6 THEN
            LET vchrrespuesta5 = vchrrespuesta;
            LET decvalor5 = decvalor;
         ELIF intgrupo = 7 THEN
            LET vchrrespuesta6 = vchrrespuesta;
            LET decvalor6 = decvalor;
         ELIF intgrupo = 8 THEN
            LET intelementoaux = intelemento;
            LET intgrupoaux = intgrupo;
            LET vchrrespuesta7 = vchrrespuesta;
            LET decvalor7 = decvalor;
         ELIF intgrupo = 9 THEN
            LET vchrrespuesta8 = vchrrespuesta;
            LET decvalor8 = decvalor;
         ELIF intgrupo = 10 THEN
            LET decvalor9 = decvalor;
         ELIF intgrupo = 11 THEN
            LET vchrrespuesta10 = vchrrespuesta;
            LET decvalor10 = decvalor;
         ELIF intgrupo = 16 THEN
            LET vchrrespuesta13 = vchrrespuesta;
            LET decvalor13 = decvalor;
         ELIF intgrupo = 21 THEN
            LET vchrrespuesta15 = vchrrespuesta;
            LET decvalor15 = decvalor;
         ELIF intgrupo = 22 THEN
            LET vchrrespuesta16 = vchrrespuesta;
            LET decvalor16 = decvalor;
         ELIF intgrupo = 23 THEN
            LET vchrpregunta17 = vchrpregunta;
            LET vchrrespuesta17 = vchrrespuesta;
            LET decvalor17 = decvalor;
         ELIF intgrupo = 26 THEN
            LET vchrrespuesta18 = vchrrespuesta;
            LET decvalor18 = decvalor;
         ELIF intgrupo = 27 THEN
            LET vchrrespuesta19 = vchrrespuesta;
            LET decvalor19 = decvalor;
         ELIF intgrupo = 28 THEN
            LET vchrrespuesta20 = vchrrespuesta;
            LET decvalor20 = decvalor;
         ELIF intgrupo = 29 THEN
            LET vchrrespuesta21 = vchrrespuesta;
            LET decvalor21 = decvalor;
         ELIF intgrupo = 30 THEN
            LET vchrrespuesta22 = vchrrespuesta;
            LET decvalor22 = decvalor;
         ELIF intgrupo = 31 THEN
            LET vchrrespuesta23 = vchrrespuesta;
            LET decvalor23 = decvalor;
         ELIF intgrupo = 32 THEN
            LET vchrrespuesta24 = vchrrespuesta;
            LET decvalor24 = decvalor;
         ELIF intgrupo = 33 THEN
            LET vchrrespuesta25 = vchrrespuesta;
            LET decvalor25 = decvalor;
         ELIF intgrupo = 34 THEN
            LET vchrrespuesta26 = vchrrespuesta;
            LET decvalor26 = decvalor;
         ELIF intgrupo = 35 THEN
            LET vchrrespuesta27 = vchrrespuesta;
            LET decvalor27 = decvalor;
         ELIF intgrupo = 36 THEN
            LET vchrrespuesta28 = vchrrespuesta;
            LET decvalor28 = decvalor;
         ELIF intgrupo = 37 THEN
            LET vchrrespuesta29 = vchrrespuesta;
            LET decvalor29 = decvalor;
         ELIF intgrupo = 44 THEN
            LET vchrrespuesta30 = vchrrespuesta;
            LET decvalor30 = decvalor;
         ELIF intgrupo = 45 THEN
            LET vchrrespuesta31 = vchrrespuesta;
            LET decvalor31 = decvalor;
         ELIF intgrupo = 46 THEN
            LET vchrrespuesta32= vchrrespuesta;
            LET decvalor32 = decvalor;
         ELIF intgrupo = 47 THEN
            LET vchrrespuesta33 = vchrrespuesta;
            LET decvalor33 = decvalor;
         ELIF intgrupo = 42 THEN
            LET vchrrespuesta34 = vchrrespuesta;
            LET decvalor34 = decvalor;
         ELIF intgrupo = 43 THEN
            LET vchrrespuesta35 = vchrrespuesta;
            LET decvalor35 = decvalor;
         ELIF intgrupo = 50 THEN
            LET vchrrespuesta36 = vchrrespuesta;
            LET decvalor36 = decvalor;
         ELIF intgrupo = 51 THEN
            LET vchrrespuesta37 = vchrrespuesta;
            LET decvalor37 = decvalor;
         ELIF intgrupo = 52 THEN
            LET vchrrespuesta38 = vchrrespuesta;
            LET decvalor38 = decvalor;
         --HR0050 # de cuentas abiertas en los ultimos 6 meses o mas
         ELIF intgrupo = 53 THEN
            LET vchrrespuesta39 = vchrrespuesta;
            LET decvalor39 = decvalor;
         --Variable interactiva: IV_TRD_OLDEST_AVERAGE_AGE
         ELIF intgrupo = 54 THEN
            LET vchrrespuesta40 = vchrrespuesta;
            LET decvalor40 = decvalor;
         -- RAT_MONTO_OTORGADO_CP: Monto otorgado y capacidad de pago
         ELIF intgrupo = 55 THEN
            LET vchrrespuesta41 = vchrrespuesta;
            LET decvalor41 = decvalor;
         --IQ0002: Num. de consultas en los ultimos 3 meses
         ELIF intgrupo = 56 THEN
            LET vchrrespuesta42 = vchrrespuesta;
            LET decvalor42 = decvalor;
         --Variable interactiva: OcupaciÃ³n y escolaridad
         ELIF intgrupo = 57 THEN
            LET vchrrespuesta43 = vchrrespuesta;
            LET decvalor43 = decvalor;
         --Grupo Originacion
         ELIF intgrupo = 49 THEN
            LET vchrrespuesta44 = vchrrespuesta;
            LET decvalor44 = decvalor;
         --Ingreso
         ELIF intgrupo = 63 THEN
            LET vchrrespuesta45 = vchrrespuesta;
            LET decvalor45 = decvalor;
         --Variable interactiva: Genero & Edad
         ELIF intgrupo = 64 THEN
            LET vchrrespuesta46 = vchrrespuesta;
            LET decvalor46 = decvalor;
         --Variable interactiva: Sexo & Ocupacion
         ELIF intgrupo = 65 THEN
            LET vchrrespuesta47 = vchrrespuesta;
            LET decvalor47 = decvalor;
         --Variable interactiva: Edo Civil & Escolaridad
         ELIF intgrupo = 66 THEN
            LET vchrrespuesta48 = vchrrespuesta;
            LET decvalor48 = decvalor;
         --Variable interactiva: Edad & Escolaridad
         ELIF intgrupo = 67 THEN
            LET vchrrespuesta49 = vchrrespuesta;
            LET decvalor49 = decvalor;
         --Variable interactiva: Entidad & Localidad
         ELIF intgrupo = 68 THEN
            LET vchrrespuesta50 = vchrrespuesta;
            LET decvalor50 = decvalor;
         END IF;
      END FOREACH;


      SELECT NVL(SUM(decode(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
             NVL(SUM(decode(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
             NVL(SUM(nvl(evaluacion, 0)),0) AS Suma,
             COUNT(num_solicitud) AS Cantidad
        INTO dEvaluacion1, dEvaluacion2, dSuma, iCantidad
        FROM bdisolic:ss_resumen_scoring
       WHERE empresa = '001'
         AND seccion IN ('1', '2')
         AND num_solicitud = chrnumsolicitud;


      SELECT nvl(SUM(decode(seccion, '3', nvl(evaluacion,0), 0)),0) AS seccion3,
             nvl(SUM(decode(seccion, '4', nvl(evaluacion,0), 0)),0) AS seccion4,
             nvl(SUM(decode(seccion, '5', nvl(evaluacion,0), 0)),0) AS seccion5
        INTO dEvaluacion3, dEvaluacion4,dEvaluacion5
        FROM bdisolic:ss_resumen_scoring
       WHERE empresa = '001'
         AND seccion IN ('3', '4','5')
         AND num_solicitud = chrnumsolicitud;


      IF iCantidad = 2 THEN
         LET decseccion1 = dEvaluacion1;
         LET decseccion2 = dEvaluacion2;
         LET decsuma= dSuma;
      ELSE

{
                        --Obtiene el total del scoring de la seccion 1
                        select nvl(sum(nvl(puntuacion,0)),0)
                        into decseccion1
                        from bdisolic:ss_scoring_financ sf, bdisolic:ss_resum_scor_fin rsf
                        where rsf.empresa = '001' and rsf.num_solicitud = chrnumsolicitud and rsf.empresa = sf.empresa
                        and upper(sf.tp_solicitud) = 'T' and sf.circulo_credito = evalua_cc
                        and sf.min_mes_hist <= rsf.meses_historia
                        and sf.max_mes_hist >= rsf.meses_historia
                        and sf.min_porc_pago <= rsf.situacion_pago
                        and sf.max_porc_pago >= rsf.situacion_pago;
}

         --Obtiene el total del scoring de la seccion 2
         LET decseccion2 = decvalor1 + decvalor2 + decvalor3 + decvalor4 + decvalor5 +
                           decvalor6 + decvalor7 + decvalor8 + decvalor9 + decvalor10 +
                           decvalor13 + decvalor15 +  decvalor16 + decvalor17;

         LET decseccion1 = dEvaluacion2 - decseccion2;

         --Obtiene el total del scoring del cliente
         LET decsuma = decseccion1 + decseccion2;

      END IF;

      SELECT FIRST 1 NVL(sc01,'') INTO cbcscore
        FROM bdiburo:br_sc
       WHERE num_cliente = chrnumcte;


      SELECT status_ini INTO cStatus_Ini
        FROM bdisolic:ss_solicitudes_mc
       WHERE empresa = '001'
         AND num_solicitud = chrnumsolicitud;

      IF cStatus_Ini IS NULL THEN
         LET cStatus_Ini = ' ';
      END IF;


      SELECT revisado INTO cRevisado
        FROM bdisolic:ss_solicitudes_mc
       WHERE empresa = '001'
         AND num_solicitud = chrnumsolicitud;

      IF cRevisado IS NULL THEN
         LET cRevisado = ' ';
      ELIF cRevisado = 'N' THEN
         LET cRevisado = 'C';
      ELSE
         LET cRevisado = 'R';
      END IF;

      SELECT COUNT(*) INTO cIdbox
        FROM bdisolic:ss_solicitudes_mc a
       RIGHT OUTER JOIN bdinteg:si_bitacora_ife b ON (a.numcte = b.numcte AND
                                                      b.fecha = (SELECT MAX(fecha)
                                                                   FROM bdinteg:si_bitacora_ife
                                                                  WHERE numcte = a.numcte))
       WHERE empresa = '001'
         AND num_solicitud = chrnumsolicitud;

      IF cIdbox >= 1 THEN
         LET cIFE = 'Si';
      ELSE
         LET cIFE = 'No';
      END IF;


      SELECT (CASE WHEN tp_gen_planpago = '3' THEN '0'
                   WHEN tp_gen_planpago = '2' THEN '> 3'
                   WHEN tp_gen_planpago = '1' THEN '<= 3' ELSE '' END)
        INTO vtipoModeloHit
        FROM bdisolic:ss_solicitudes
       WHERE empresa = '001'
         AND num_solicitud = chrnumsolicitud;


      --Inserta en ss_riesgos_os2 para consulta del area de Riesgos
      --Se sustituye la tabla temporal
      --insert into bdisolic:ss_riesgos_os2 (numsolicitud,numcte,numctecoppel,sucursal,appaterno,apmaterno,nombre1,


      INSERT INTO bdisolic:ss_riesgos_os_temp2 (numsolicitud, numcte, numctecoppel, sucursal, appaterno,
                           apmaterno, nombre1, nombre2, statussol, numproducto, sitesp, respuesta,
                           ejecutivo, descsitesp, lincred, eficponderada, meses, causasitesp, fechasol,
                           feCHAResp, seccion1, seccion2, sumascoring, respuestacc, sexo, valor_sexo,
                           estado_civil, valor_estado_civil, tmpo_edo_civ_act, valor_tmpo_edo_civ_act,
                           tipo_residencia, valor_tipo_residencia, tmpo_dom_act, valor_tmpo_dom_act,
                           ocupacion, valor_ocupacion, tmpo_ocup_act, valor_tmpo_ocup_act, tmpo_ocup_ant,
                           valor_tmpo_ocup_ant, edad, valor_edad, depend_econ, valor_depend_econ,
                           seguro_popular, valor_seguro_popular, escolaridad, valor_escolaridad,
                           hab_domic, valor_hab_domic, pregunta17, respuesta17, valor17, BC_1,
                           puntual_BC_1, valor_BC_1, BC_101, puntual_BC_101, valor_BC_101, BC_117,
                           puntual_BC_117, valor_BC_117, BC_119, puntual_BC_119, valor_BC_119, BC_20,
                           puntual_BC_20, valor_BC_20, BC_421, puntual_BC_421, valor_BC_421, BC_85,
                           puntual_BC_85, valor_BC_85, BC_93, puntual_BC_93, valor_BC_93,
                           calc_PCT_saldo_linea, puntual_calc_PCT_saldo_linea, valor_calc_PCT_saldo_linea,
                           meses_historia, puntual_meses_historia, valor_meses_historia, situacion_pago,
                           puntual_situacion_pago, valor_situacion_pago, ratio_saldo_credit_limit,
                           puntual_ratio_saldo_credit_limit, valor_ratio_saldo_credit_limit,
                           tipocliente, filtrocliente, saldoropa, saldomuebles, saldoprestamo,
                           lineatienda, bcscore, prueba, causa, status, compromisos, fecha_apert,
                           edad_1, email, tel_ofi, tel_cel, fuente, calle, numext, numint, colonia,
                           codpostal, entrecalles, observaciones, estado, localidad, nombresuc, telsuc,
                           nombregte, telefono, ingresomensual, ingresosmb, rfc, fechanac, claciucobr,
                           claedocobr, abono_muebles, abono_ropa, abono_prestamos, compromisos_mensuales,
                           evalua_cc, VI_EdoCiv_TmpoEdoCiv, puntual_VI_EdoCiv_TmpoEdoCiv,
                           valor_VI_EdoCiv_TmpoEdoCiv, VI_MesesHist_CteNvo, puntual_VI_MesesHist_CteNvo,
                           valor_VI_MesesHist_CteNvo, VI_CalcPctSdoLin_CteNvo, puntual_VI_CalcPctSdoLin_CteNvo,
                           valor_VI_CalcPctSdoLin_CteNvo, VI_SitPago_CteNvo, puntual_VI_SitPago_CteNvo,
                           valor_VI_SitPago_CteNvo, region_cobranza, valor_region_cobranza,
                           Meses_ult_cons_buro_iq, puntual_Meses_ult_cons_buro_iq, valor_Meses_ult_cons_buro_iq,
                           hr0048, puntual_hr0048, valor_hr0048, ut0034, puntual_ut0034, valor_ut0034,
                           vi_ocup_tmpo_ocup, puntual_vi_ocup_tmpo_ocup, valor_vi_ocup_tmpo_ocup,
                           hr0050, puntual_hr0050, valor_hr0050, iv_trd_oldest_average_age,
                           puntual_iv_trd_oldest_average_age, valor_iv_trd_oldest_average_age,
                           rat_monto_otorgado_CP, puntual_rat_monto_otorgado_CP, valor_rat_monto_otorgado_CP,
                           iq0002, puntual_iq0002, valor_iq0002, iv_ocup_escolar, puntual_iv_ocup_escolar,
                           valor_iv_ocup_escolar, grupo_originacion, valor_grupo_originacion, ingreso_mensual,
                           valor_ingreso_mensual, iv_sexo_edad, valor_iv_sexo_edad, iv_entidad_localidad,
                           valor_iv_entidad_localidad, iv_sexo_ocupacion, valor_iv_sexo_ocupacion,
                           iv_edociv_escolaridad, valor_iv_edociv_escolaridad, iv_edad_escolaridad,
                           valor_iv_edad_escolaridad, grupo, seccion3, seccion4, seccion5,
                           flag2creditoicc, statusini, revisado, ife, tipo_modelo_hit)
             VALUES (chrnumsolicitud, chrnumcte, chrnumctecoppel, chrsucursal, chrappaterno, chrapmaterno,
                     chrnombre1, chrnombre2, chrstatussol, chrnumproducto, chrsitesp, chrrespuesta,
                     chrejecutivo, chrdescsitesp, declincred, deceficponderada, intmeses, intcausasitesp,
                     dtefechasol, dtefeCHAResp, decseccion1, decseccion2, decsuma, vchrrespuestacc,
                     vchrrespuesta1, decvalor1, vchrrespuesta2, decvalor2, vchrrespuesta3, decvalor3,
                     vchrrespuesta4, decvalor4, vchrrespuesta5, decvalor5, vchrrespuesta6, decvalor6,
                     vchrrespuesta7, decvalor7, vchrrespuesta8, decvalor8, vchrrespuesta9, decvalor9,
                     vchrrespuesta10, decvalor10, vchrrespuesta13, decvalor13, vchrrespuesta15,
                     decvalor15, vchrrespuesta16, decvalor16, vchrpregunta17, vchrrespuesta17,
                     decvalor17, vchrrespuesta18, varpuntual18, decvalor18, vchrrespuesta19,
                     varpuntual19, decvalor19, vchrrespuesta20, varpuntual20, decvalor20,
                     vchrrespuesta21, varpuntual21, decvalor21, vchrrespuesta22, varpuntual22,
                     decvalor22, vchrrespuesta23, varpuntual23, decvalor23, vchrrespuesta24,
                     varpuntual24, decvalor24, vchrrespuesta25, varpuntual25, decvalor25,
                     vchrrespuesta26, varpuntual26, decvalor26, vchrrespuesta27, varpuntual27,
                     decvalor27, vchrrespuesta28, varpuntual28, decvalor28, vchrrespuesta29,
                     varpuntual29, decvalor29, ctipoc, cFiltroC, dSdoropa, dSdomuebles, dSdoprestamo,
                     dSdolineatienda, cbcscore, cPrueba, v_causa, v_status, v_compromisos,
                     v_fecha_apert, v_edad, v_email, v_tel_ofi, v_tel_cel, v_fuente, chrnombrecalle,
                     chrnumext, chrnumint, chrnombrezona, chrcodpostal, chrentrecalles, chrobservaciones,
                     chrestado, vchrciudad, chrnombresuc, chrtelsuc, chrnombregte, chrtelefono,
                     mnyingreso, mnyingresosmb, chrrfc, dtefechanac, vchrclaciucobr, vchrclaedocobr,
                     mnyabonomensualmuebles, mnyabonomensualropa, mnyabonomensualprestamos, mnypago_minimo,
                     chrevalua_cc, vchrrespuesta30, varpuntual30, decvalor30, vchrrespuesta31,
                     varpuntual31, decvalor31, vchrrespuesta32, varpuntual32, decvalor32, vchrrespuesta33,
                     varpuntual33, decvalor33, vchrrespuesta34, decvalor34, vchrrespuesta35, varpuntual35,
                     decvalor35, vchrrespuesta36, varpuntual36, decvalor36, vchrrespuesta37, varpuntual37,
                     decvalor37, vchrrespuesta38, varpuntual38, decvalor38, vchrrespuesta39, varpuntual39,
                     decvalor39, vchrrespuesta40, varpuntual40, decvalor40, vchrrespuesta41, varpuntual41,
                     decvalor41, vchrrespuesta42, varpuntual42, decvalor42, vchrrespuesta43, varpuntual43,
                     decvalor43, vchrrespuesta44, decvalor44, vchrrespuesta45, decvalor45, vchrrespuesta46,
                     decvalor46, vchrrespuesta47, decvalor47, vchrrespuesta48, decvalor48, vchrrespuesta49,
                     decvalor49, vchrrespuesta50, decvalor50, cgrupo_solic, dEvaluacion3, dEvaluacion4,
                     dEvaluacion5, cFlag2Credito, cStatus_Ini, cRevisado, cIfe, vtipoModeloHit);

      LET icontadorcommit = icontadorcommit + 1;

      IF (icontadorcommit >= 100) THEN
         COMMIT WORK;
         LET icontadorcommit = 0;
      END IF;

   END FOREACH;


   SELECT DBINFO('utc_to_DATEtime', sh_curtime)::DATETIME YEAR TO FRACTION INTO vHora FROM sysmaster:sysshmvals;

   INSERT INTO ss_bitacora_os (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES ('Reporte de Solicitudes', SUBSTR(chrcodret,2,5), 'Fuera del FOR LOOP Bitacora '||
                'intDiasContador: '||intDiasContador||', icontadorcommit: '||icontadorcommit,
                'informix', TODAY, vHora);

   IF (icontadorcommit > 0) THEN
      COMMIT WORK;
   END IF;

   LET ibanderaIndice = 1;

--EPVP
   BEGIN WORK;

   LOCK TABLE ss_riesgos_os2 IN EXCLUSIVE MODE;

   INSERT INTO ss_riesgos_os2
   SELECT *
     FROM ss_riesgos_os_temp2;

   COMMIT WORK;
--EPVP

   LET ibanderaIndice = 2;

   CREATE INDEX inx_ss_riesgos_os2 ON ss_riesgos_os2(numsolicitud) IN dbs_movhis_idx5;

   LET ibanderaIndice = 3;

   UPDATE STATISTICS MEDIUM FOR TABLE ss_riesgos_os2;

   LET ibanderaIndice = 4;

   SELECT DBINFO('utc_to_DATEtime', sh_curtime)::DATETIME YEAR TO FRACTION INTO vHora FROM sysmaster:sysshmvals;

   INSERT INTO ss_bitacora_os (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES ('Reporte de Solicitudes', SUBSTR(chrcodret,2,5), 'Termina proceso', 'informix', TODAY, vHora);

   --COMMIT WORK;

   RETURN chrcodret, chrmensaje;

END;

END PROCEDURE;