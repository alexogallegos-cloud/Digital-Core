CREATE PROCEDURE "informix".ss_reportesolicitudes_pbajj()
returning   char(06),
            char(70);
     
			
---------------------------------------------------------
--Autor: Julio Cesar Polanco Inzunza
--Fecha: 21/08/2007
--Actividad: Genera informacion de reporte de solicitudes
--para el area de Riesgos.
----------------------------------------------------------
----------------------------------------------------------
--Autor: Paul Ivan Quintero Varela
--Fecha: 15/08/2008
--Modificación:  Se modifica el sp para que contemple la información
--correspondiente a las preguntas del paramétrico nuevas:(Pregunta, Respuesta y Puntuación);
-- Ingreso del Cliente, Escolaridad, Habitantes en el domicilio y Antigüedad de la plaza + nivel de vencido
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


--Declaracion de variables
define chrcodret			char(06);
define chrmensaje           char(70);
define chrnumsolicitud		char(20);
define chrsucursal			char(4);
define chrappaterno			char(26);
define chrapmaterno			char(26);
define chrnombre1			char(26);
define chrnombre2			char(26);
define chrstatussol			char(2);
define chrnumproducto		char(4);
define chrsitesp			char(1);
define chrrespuesta			char(1);
define chrnumcte			char(20);
define chrnumctecoppel		char(20);
define chrejecutivo			char(30);
define chrdescsitesp		char(80);
define chrrfc				char(13);
define chrnombrezona		char(30);
define chrnombrecalle		char(30);
define chrentrecalles		char(40);
define chrcodpostal			char(5);
define chrnumext			char(10);
define chrnumint			char(10);
define chrobservaciones	    char(80);
define chrestado            char(30);
define chrnombresuc         char(40);
define chrtelsuc            char(14);
define chrnombregte         char(40);
define chrtelefono          char(13);
define chrmop               char(2);
define chrclavecc1          char(2);

define vchrpregunta         varchar(80);
define vchrrespuesta		varchar(80);
define vchrrespuesta1		varchar(80);
define vchrrespuesta2		varchar(80);
define vchrrespuesta3		varchar(80);
define vchrrespuesta4		varchar(80);
define vchrrespuesta5		varchar(80);
define vchrrespuesta6		varchar(80);
define vchrrespuesta7		varchar(80);
define vchrrespuesta8		varchar(80);
define vchrrespuesta9		varchar(80);
define vchrrespuesta10		varchar(80);
define vchrrespuesta13		varchar(80);
--PQ
define vchrrespuesta15      varchar(80);
define vchrrespuesta16      varchar(80);
define vchrpregunta17       varchar(80);
define vchrrespuesta17      varchar(80);
--PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
define vchrrespuesta18      varchar(80);
define vchrrespuesta19      varchar(80);
define vchrrespuesta20      varchar(80);
define vchrrespuesta21      varchar(80);
define vchrrespuesta22      varchar(80);
define vchrrespuesta23      varchar(80);
define vchrrespuesta24      varchar(80);
define vchrrespuesta25      varchar(80);
define vchrrespuesta26      varchar(80);
define vchrrespuesta27      varchar(80);
define vchrrespuesta28      varchar(80);
define vchrrespuesta29      varchar(80);
define vchrrespuesta30      varchar(80); -- INI se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
define vchrrespuesta31      varchar(80);
define vchrrespuesta32      varchar(80);
define vchrrespuesta33      varchar(80);
define vchrrespuesta34      varchar(80);
define vchrrespuesta35      varchar(80); -- FIN se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
--MJPC agregar variables para reporte solic_credito
define vchrrespuesta36      varchar(80);
define vchrrespuesta37      varchar(80);
define vchrrespuesta38      varchar(80);
define vchrrespuesta39      varchar(80);
define vchrrespuesta40      varchar(80);
define vchrrespuesta41      varchar(80);
define vchrrespuesta42      varchar(80);
define vchrrespuesta43      varchar(80);
define vchrrespuesta44      varchar(80);
define vchrrespuesta45      varchar(80);
define vchrrespuesta46      varchar(80);
define vchrrespuesta47      varchar(80);
define vchrrespuesta48      varchar(80);
define vchrrespuesta49      varchar(80);
define vchrrespuesta50      varchar(80);
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
define vchrrespuestacc		varchar(100);
define vchrciudad           varchar(200);
--JOM
define vchrclaciucobr       varchar(10);
define vchrclaedocobr       varchar(10);
--MJPC Valores Puntuales
define varpuntual18 		decimal(10,4);
define varpuntual19 		decimal(10,4);
define varpuntual20 		decimal(10,4);
define varpuntual21 		decimal(10,4);
define varpuntual22 		decimal(10,4);
define varpuntual23 		decimal(10,4);
define varpuntual24 		decimal(10,4);
define varpuntual25 		decimal(10,4);
define varpuntual26 		decimal(10,4);
define varpuntual27 		decimal(10,4);
define varpuntual28 		decimal(10,4);
define varpuntual29 		decimal(10,4);
define varpuntual30 		decimal(10,4); -- INI se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
define varpuntual31 		decimal(10,4);
define varpuntual32 		decimal(10,4);
define varpuntual33 		decimal(10,4);
define varpuntual35 		decimal(10,4); -- FIN se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
--MJPC agregar variables para reporte solic_credito
define varpuntual36			decimal(10,4);
define varpuntual37			decimal(10,4);
define varpuntual38			decimal(10,4);
define varpuntual39			decimal(10,4);
define varpuntual40			decimal(10,4);
define varpuntual41			decimal(10,4);
define varpuntual42			decimal(10,4);
define varpuntual43			decimal(10,4);
--JOM
define declincred			decimal(18,2);
define deceficponderada		decimal(5,2);
define decvalor				decimal(5,2);
define decvalor1			decimal(5,2);
define decvalor2			decimal(5,2);
define decvalor3			decimal(5,2);
define decvalor4			decimal(5,2);
define decvalor5			decimal(5,2);
define decvalor6			decimal(5,2);
define decvalor7			decimal(5,2);
define decvalor8			decimal(5,2);
define decvalor9			decimal(5,2);
define decvalor10			decimal(5,2);
define decvalor13			decimal(5,2);
--PQ
define decvalor15			decimal(5,2);
define decvalor16			decimal(5,2);
define decvalor17			decimal(5,2);
--PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
define decvalor18			decimal(5,2);
define decvalor19			decimal(5,2);
define decvalor20			decimal(5,2);
define decvalor21			decimal(5,2);
define decvalor22			decimal(5,2);
define decvalor23			decimal(5,2);
define decvalor24			decimal(5,2);
define decvalor25			decimal(5,2);
define decvalor26			decimal(5,2);
define decvalor27			decimal(5,2);
define decvalor28			decimal(5,2);
define decvalor29			decimal(5,2);
define decvalor30			decimal(5,2);
define decvalor31			decimal(5,2);
define decvalor32			decimal(5,2);
define decvalor33			decimal(5,2);
define decvalor34			decimal(5,2);
define decvalor35			decimal(5,2);
--MJPC agregar variables para reporte solic_credito
define decvalor36			decimal(5,2);
define decvalor37			decimal(5,2);
define decvalor38			decimal(5,2);
define decvalor39			decimal(5,2);
define decvalor40			decimal(5,2);
define decvalor41			decimal(5,2);
define decvalor42			decimal(5,2);
define decvalor43			decimal(5,2);
define decvalor44			decimal(5,2);
define decvalor45			decimal(5,2);
define decvalor46			decimal(5,2);
define decvalor47			decimal(5,2);
define decvalor48			decimal(5,2);
define decvalor49			decimal(5,2);
define decvalor50			decimal(5,2);
DEFINE cStatus_Ini CHAR(2);
DEFINE cRevisado CHAR(2);
DEFINE cIdbox smallint;
DEFINE cIfe CHAR(2);
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
define decseccion1			decimal(14,2);
define decseccion2			decimal(14,2);
define decsuma				decimal(14,2);
define decauxsec2			decimal(5,2);

define intmeses			    smallint;
define intcausasitesp		smallint;
define intcontador			smallint;
define intgrupo             smallint;
define intelemento			smallint;
define intsmb               smallint;
define intgrupoaux          smallint;
define intelementoaux       smallint;
define intcont              smallint;
define intnumcobranza       smallint;

define dtefechasol			date;
define dtefecharesp			date;
define dtefechanac			date;
define dtefechacc           date;

define intcodret			integer;

define mnyingreso           money(14,2);
define mnyingresosmb        money(14,2);
define mnyimporte           money(9,2);

--PQ
define dEvaluacion1         decimal(14,2);
define dEvaluacion2         decimal(14,2);
define dSuma                decimal(14,2);
define iCantidad            integer;
--PQ
define icontadorcommit      integer;
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
define dSdoropa             decimal(14,2);
define dSdomuebles          decimal(14,2);
define dSdoprestamo         decimal(14,2);
define dSdolineatienda      decimal(14,2);
define cPrueba              char(03);
define cFiltroC             char(10);
define cbcscore             char(04);
define ctipoc               char(03);
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO

--JANETH INI AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS
--DEFINE scod_ret      VARCHAR(255);
DEFINE vfecha        	DATE;
DEFINE v_compromisos 	DECIMAL(14,2);
DEFINE v_causa          VARCHAR(255);
DEFINE v_status       	VARCHAR(255);
DEFINE v_fecha_apert     DATE;
DEFINE v_edad            SMALLINT;
DEFINE v_email           CHAR(60);
DEFINE v_tel_ofi         CHAR(13);
DEFINE v_tel_cel         CHAR(13);
DEFINE v_fuente          CHAR(10);

--JANETH FIN AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS
--MJPC respuestas puntuales
define vchsvariable			varchar(80);
define decvalor_punt		decimal(10,4);

-- AGREGAR VARIABLES RQM 07 048-02 Adendum Modificaciones al SolicAAAAMMDD. Septiembre 2012
DEFINE mnyabonomensualmuebles      money(14,2);
DEFINE mnyabonomensualropa         money(14,2); 
DEFINE mnyabonomensualprestamos    money(14,2);
DEFINE mnypago_minimo              money(14,2);
DEFINE chrevalua_cc                char(1);
DEFINE vDia                        char(10);
DEFINE vHora                       char(28);
DEFINE iIsamErr				             integer;
DEFINE cMensajeRet                 char(100);
DEFINE cgrupo_solic                CHAR(1);
--IPCB Marzo2016 RQM 09 398-0 FICO Extended
DEFINE dEvaluacion3         decimal(14,2);
DEFINE dEvaluacion4         decimal(14,2);
DEFINE dEvaluacion5         decimal(14,2);
--IPCB Marzo2016 RQM 09 398-0 FICO Extended 
--RQM 09 392 JMAH
DEFINE cFlag2Credito                CHAR(60);
 --debug flag
 --set debug file to "/informix/janeth/ambiente100/ss_reportesolicitudes.out";
 --trace on;

	--Inicializacion de variables
	let chrcodret			="000000";
    let chrmensaje          = 'El proceso REPORTE DE SOLICITUDES se ejecutó exitosamente';
	let chrnumsolicitud		="";
	let chrsucursal			="";
	let chrappaterno		="";
	let chrapmaterno		="";
	let chrnombre1			="";
	let chrnombre2			="";
	let chrstatussol		="";
	let chrnumproducto		="";
	let chrsitesp			="";
	let chrrespuesta		="";
	let chrnumcte			="";
	let chrnumctecoppel		="";
	let chrejecutivo		="";
	let chrdescsitesp		="";
	let chrrfc				="";
	let chrnombrezona		="";
	let chrnombrecalle		="";
	let chrentrecalles		="";
	let chrcodpostal		="";
	let chrnumext			="";
	let chrnumint			="";
	let chrobservaciones	="";
    let chrestado           ="";
    let chrnombresuc        ="";
    let chrtelsuc           ="";
    let chrnombregte        ="";
    let chrtelefono         ="";
    let chrmop              ="";
	let vchrpregunta		="";
	let vchrrespuesta		="";
	let vchrrespuesta1		="";
	let vchrrespuesta2		="";
	let vchrrespuesta3		="";
	let vchrrespuesta4		="";
	let vchrrespuesta5		="";
	let vchrrespuesta6		="";
	let vchrrespuesta7		="";
	let vchrrespuesta8		="";
	let vchrrespuesta9		="";
	let vchrrespuesta10		="";
	let vchrrespuesta13		="";
--PQ
	let vchrrespuesta15		="";
	let vchrrespuesta16		="";
	let vchrpregunta17		="";
	let vchrrespuesta17		="";
--PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
	let vchrrespuesta18		="";
	let vchrrespuesta19 	="";
	let vchrrespuesta20		="";
	let vchrrespuesta21		="";
	let vchrrespuesta22		="";
	let vchrrespuesta23		="";
	let vchrrespuesta24		="";
	let vchrrespuesta25		="";
	let vchrrespuesta26		="";
	let vchrrespuesta27		="";
	let vchrrespuesta28		="";
	let vchrrespuesta29		="";
	let vchrrespuesta30		="";
	let vchrrespuesta31		="";
	let vchrrespuesta32		="";
	let vchrrespuesta33		="";
	let vchrrespuesta34		="";
	let vchrrespuesta35		="";
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
--MJPC agregar variables para reporte solic_credito
	let vchrrespuesta36		="";
	let vchrrespuesta37		="";
	let vchrrespuesta38		="";
	let vchrrespuesta39		="";
	let vchrrespuesta40		="";
	let vchrrespuesta41		="";
	let vchrrespuesta42		="";
	let vchrrespuesta43		="";
	let vchrrespuesta44		="";
	let vchrrespuesta45		="";
	let vchrrespuesta46		="";
	let vchrrespuesta47		="";
	let vchrrespuesta48		="";
	let vchrrespuesta49		="";
	let vchrrespuesta50		="";
    let vchrrespuestacc		="";
    let vchrciudad          ="";
--jom claves de cobranza
    let vchrclaciucobr      ="";
    let vchrclaedocobr      ="";
--MJPC Valores Puntuales
	let varpuntual18 		=0;
	let varpuntual19 		=0;
	let varpuntual20 		=0;
	let varpuntual21 		=0;
	let varpuntual22 		=0;
	let varpuntual23 		=0;
	let varpuntual24 		=0;
	let varpuntual25 		=0;
	let varpuntual26 		=0;
	let varpuntual27 		=0;
	let varpuntual28 		=0;
	let varpuntual29 		=0;
	let varpuntual30 		=0;
	let varpuntual31 		=0;
	let varpuntual32 		=0;
	let varpuntual33 		=0;
	let varpuntual35 		=0;
--MJPC agregar variables para reporte solic_credito	
	let varpuntual36        =0;
	let varpuntual37        =0;
	let varpuntual38		=0;
	let varpuntual39		=0;
	let varpuntual40		=0;
	let varpuntual41		=0;
	let varpuntual42		=0;
	let varpuntual43		=0;
--jom claves de cobranza
	let declincred			=0;
	let deceficponderada	=0;
	let decvalor			=0;
	let decvalor1			=0;
	let decvalor2			=0;
	let decvalor3			=0;
	let decvalor4			=0;
	let decvalor5			=0;
	let decvalor6			=0;
	let decvalor7			=0;
	let decvalor8			=0;
	let decvalor9			=0;
	let decvalor10			=0;
	let decvalor13			=0;
--PQ
	let decvalor15			=0;
	let decvalor16			=0;
	let decvalor17			=0;
--PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
    let decvalor18         =0;
    let decvalor19         =0;
    let decvalor20         =0;
    let decvalor21         =0;
    let decvalor22         =0;
    let decvalor23         =0;
    let decvalor24         =0;
    let decvalor25         =0;
    let decvalor26         =0;
    let decvalor27         =0;
    let decvalor28         =0;
    let decvalor29         =0;
    let decvalor30         =0;
    let decvalor31         =0;
    let decvalor32         =0;
    let decvalor33         =0;
    let decvalor34         =0;
    let decvalor35         =0;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
--MJPC agregar variables para reporte solic_credito
	let decvalor36         =0;
	let decvalor37         =0;
	let decvalor38         =0;
	let decvalor39         =0;
	let decvalor40         =0;
	let decvalor41         =0;
	let decvalor42         =0;
	let decvalor43         =0;
	let decvalor44         =0;
	let decvalor45         =0;
	let decvalor46         =0;
	let decvalor47         =0;
	let decvalor48         =0;
	let decvalor49         =0;
	LET cStatus_Ini = "";
	LET cRevisado = "";
	LET cIdbox = 0;
	LET cIfe = "";

	let decseccion1			=0;
	let decseccion2			=0;
	let decsuma				=0;
	let intmeses			=0;
	let intcausasitesp		=0;
	let intcontador			=0;
	let intcodret			=0;
	let intgrupo            =0;
	let intelemento			=0;
    let intsmb              =0;
    let intgrupoaux         =0;
    let intelementoaux      =0;
    let intcont             =0;
-- jom let intnumcobranza   =0;
	let decauxsec2			=0;
    let mnyingreso          =0;
    let mnyingresosmb       =0;
    let mnyimporte          =0;

--PQ
    let dEvaluacion1        =0;
    let dEvaluacion2        =0;
    let dSuma               =0;
    let iCantidad           =0;
--PQ
    let icontadorcommit     =0;
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
    let dSdoropa             =0;
    let dSdomuebles          =0;
    let dSdoprestamo         =0;
    let dSdolineatienda      =0;
    let cPrueba              = '';
    let cFiltroC             = '';
    let cbcscore             = '';
    let ctipoc               = '';
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO

--IPCB Marzo2016 RQM 09 398-0 FICO Extended
    let dEvaluacion3        =0;
    let dEvaluacion4        =0;
    let dEvaluacion5        =0;
--IPCB Marzo2016 RQM 09 398-0 FICO Extended

--JANETH INI AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS

	 --LET scod_ret      = "";
     LET v_compromisos = 0;
	 LET v_causa       = "";
	 LET v_status   = "";
     LET v_fecha_apert = DATE(1);
	 LET v_edad        = 0;
	 LET v_email       = "";
	 LET v_tel_ofi     = "";
	 LET v_tel_cel     = "";
	 LET v_fuente      = "";

--JANETH FIN AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS
-- MJPC: Respuestas puntuales
	let vchsvariable = "";
	let decvalor_punt = 0;
	
-- AGREGAR VARIABLES RQM 07 048-02 Adendum Modificaciones al SolicAAAAMMDD
    let mnyabonomensualmuebles   =0;
    let mnyabonomensualropa      =0; 
    let mnyabonomensualprestamos =0;
    let mnypago_minimo           =0;
    let chrevalua_cc        ="";
    let vDia = '';       let vHora = '';
    let iIsamErr = 0;    let cMensajeRet = ''; 
    LET cgrupo_solic = '';
LET cFlag2Credito= '';

begin

    on exception set intcodret,  iIsamErr, cMensajeRet
    if intcodret <> 0 then
        let chrcodret  = intcodret;
        
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vDia FROM sysmaster:sysshmvals;
        --SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO FRACTION INTO vHora FROM sysmaster:sysshmvals;

        INSERT INTO "informix".ss_bitacora_os(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
        VALUES('Reporte de Solicitudes', substr(chrcodret,2,5), cMensajeRet, 'informix', today, vHora);
        
        let chrmensaje = 'Error en la ejecución del REPORTE DE SOLICITUDES ' || chrnumsolicitud;
        rollback work;
        return chrcodret,chrmensaje;
    end if;
 end exception;

  set isolation to dirty read;
  set lock mode to wait 3;
	
	--SET DEBUG FILE TO "/ifxsif01/c91691184/ss_reportesolicitudes.out";
    --TRACE ON; 	

  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vDia FROM sysmaster:sysshmvals;
  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO FRACTION INTO vHora FROM sysmaster:sysshmvals;

  INSERT INTO "informix".ss_bitacora_os(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
    VALUES('Reporte de Solicitudes', '00000', 'Inicio del proceso', 'informix', today, vHora);

--	begin work;

	drop table "informix".ss_riesgos_os;

    CREATE TABLE "informix".ss_riesgos_os (
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
        fecharesp     	DATE,
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
        abono_muebles                money(14,2), -- abonomensualmuebles
        abono_ropa                   money(14,2), -- abonomensualropa
        abono_prestamos              money(14,2), -- abonomensualprestamos
        compromisos_mensuales        money(14,2), -- pago_minimo
        evalua_cc                    char(1),
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
		ife CHAR(2)
        ) in dbssc_sdodiarioc02;

--    alter table ss_riesgos_os type (RAW);

	foreach with hold 
        select sol.num_solicitud, sol.numcte, sol.sucursal, 
			   (select nombre from bdinteg:si_sucursales where sucursal = sol.sucursal),
			   (select telefono1 from bdinteg:si_sucursales where sucursal = sol.sucursal),
			   (select gerente from bdinteg:si_sucursales where sucursal = sol.sucursal),
               cli.apell_paterno, cli.apell_materno,
               cli.nombre1, cli.nombre2, cli.numcte_ref, cli.rfc,
               cte.fecha_nac, sol.status_solicitud,sol.fecha_insert, sol.num_producto, sol.monto_solicitado,
               nvl(res.situacion_pago,0),nvl(res.meses_historia,0), sol.user_insert, res.motivo_cc,
               nvl(res.saldoropa,0), nvl(res.saldomuebles,0), nvl(res.saldoprestamos,0), nvl(res.linea_tienda,0), nvl(dia_para_revisar,''),
               res.evalua_cc, '', res.grupo,DECODE(res2.flag2creditoicc,'1','Evaluación de Segundo producto de crédito en adelante','')
        into chrnumsolicitud,chrnumcte,chrsucursal,chrnombresuc,
             chrtelsuc,chrnombregte,chrappaterno,chrapmaterno,
             chrnombre1,chrnombre2,chrnumctecoppel,chrrfc,
             dtefechanac,chrstatussol,dtefechasol,chrnumproducto,declincred,
             deceficponderada,intmeses,chrejecutivo,vchrrespuestacc,
             dSdoropa,dSdomuebles,dSdoprestamo,dSdolineatienda, cPrueba, cFiltroC,ctipoc, cgrupo_solic,cFlag2Credito
		from bdisolic:ss_solicitudes sol
        left outer join bdinteg:si_cliente cli on(cli.numcte=sol.numcte)
        left outer join bdisolic:ss_resum_scor_fin res on(res.empresa=sol.empresa and res.num_solicitud=sol.num_solicitud)
        left outer join bdisolic:ss_revision_determinacion res2 on(res2.empresa=sol.empresa and res2.num_solicitud=sol.num_solicitud)
		left outer join bdinteg:si_ctepf cte on(cte.numcte=cli.numcte)
        where sol.empresa='001' and cli.tpo_persona='01'  and sol.fecha_insert >= today - 35 
		
		let chrnumsolicitud = trim(chrnumsolicitud);
		let chrnumcte = trim(chrnumcte);
		let chrsucursal = trim(chrsucursal);
		let chrnombresuc = trim(chrnombresuc);
		let chrtelsuc = trim(chrtelsuc);
		let chrnombregte = trim(chrnombregte);
		let chrappaterno = trim(chrappaterno);
		let chrapmaterno = trim(chrapmaterno);
		let chrnombre1 = trim(chrnombre1);
		let chrnombre2 = trim(chrnombre2);
		let chrnumctecoppel = trim(chrnumctecoppel);
		let chrrfc = trim(chrrfc);
		let chrstatussol = trim(chrstatussol);
		let chrnumproducto = trim(chrnumproducto);
		let chrejecutivo = trim(chrejecutivo);
		let vchrrespuestacc = trim(vchrrespuestacc);
		
		if cPrueba <> '' then 
			LET cPrueba = 'E84';
		END IF;
		
		if cFiltroC = 'X' THEN
			LET cFiltroC = 'NO HIT';
		else
			LET cFiltroC = 'HIT';
		END IF;
		
		IF intmeses >= 13 and deceficponderada >= 85 then 
			let ctipoc = 'I';
		elif intmeses >= 6 and deceficponderada >= 85 then
			let ctipoc = 'II';
		else
			let ctipoc = 'II';
		end IF;

        if (icontadorcommit = 0) then
          begin work;
        end if;

		----- jpc
		select e.descripcion,
              (select descripcion from ss_status_sol where empresa='001' and status_solicitud = a.status_solicitud),
--            c.comentario , 
			b.fecha_apertura, 
			trunc((a.fecha_insert - cte.fecha_nac)/365,0) edad,  
            (select telefono from bdinteg:si_telefonos_actual b where a.empresa = b.empresa and a.numcte = b.numcte 
                                                        and b.tipo_tel = '4') tel_ofi,
			(select telefono from bdinteg:si_telefonos_actual b where a.empresa = b.empresa and a.numcte = b.numcte 
                                                       and b.tipo_tel = '2') tel_cel,
			decode(f.fuente,'T','TIENDA','B','BANCO','','BANCO'),pago_minimo
				into v_causa, v_status, v_fecha_apert, v_edad, v_tel_ofi, v_tel_cel, v_fuente, v_compromisos	 
				from  bdisolic:ss_solicitudes a 
                left join bdicred:sd_maecred b on (a.empresa = b.empresa and a.num_solicitud = b.num_credito)  
                inner join bdisolic:ss_autorizacion c on ( c.empresa = a.empresa
                                                    and c.num_solicitud = a.num_solicitud
                                                    and c.status_solicitud = a.status_solicitud
                                                    and c.rowid = (select max(rowid) 
																			 from bdisolic:ss_autorizacion 
																			  where empresa = a.empresa
																				and num_solicitud = a.num_solicitud
																				and status_solicitud = a.status_solicitud))                                                    
                left outer join bdisolic:ss_causas_sol e on (a.empresa = e.empresa 
                                                            and e.status_solicitud  = c.status_solicitud 
                                                            and e.causa_solicitud = c.causa_solicitud)
				inner join bdinteg:si_ctepf cte ON (a.numcte = cte.numcte)
				inner join bdisolic:ss_resum_scor_fin f on (a.empresa=f.empresa and a.num_solicitud=f.num_solicitud)
				where a.empresa = '001' and a.num_solicitud = chrnumsolicitud;
				
		let v_causa = trim(v_causa);

        if v_causa is null then let v_causa = ''; end if;    if v_status is null then let v_status = ''; end if;    if v_fecha_apert is null then let v_fecha_apert = ''; end if;
        if v_edad is null then let v_edad = ''; end if;    if v_tel_ofi is null then let v_tel_ofi = ''; end if;
        if v_tel_cel is null then let v_tel_cel = ''; end if;    if v_fuente is null then let v_fuente = ''; end if;    if v_compromisos is null then let v_compromisos = 0; end if;
		
		--Obtengo el email
		select corre.correo_elec
			into v_email
			from bdinteg:si_correos corre
		   where corre.empresa = '001' 
		    and corre.numcte = chrnumcte
			and corre.status_correo = 'A'
			and corre.secuencia = 
			(
				select max(secuencia) 
				  from bdinteg:si_correos 
			     where empresa = corre.empresa
				   and numcte = chrnumcte
				   and status_correo = corre.status_correo
			);
			
			let v_email = trim(v_email); 
		
		if v_email is null then let v_email = ''; end if;
        --Obtiene la direccion del cliente(persona fisica)
        select nvl(trim(replace(dir.entre_calles,'|','')),''),nvl(trim(dir.cod_postal),''),nvl(trim(dir.numeroextcalle),''),
               nvl(trim(dir.numerointcalle),''),nvl(trim(cal.nombrecalle),''),nvl(trim(zon.nombrezona),''),
               nvl(trim(replace(dir.observaciones,'|','')),''),nvl(trim(edo.nombre),''),nvl(trim(ciu.nombre),''),nvl(trim(tel.telefono),''),
--JOM          nvl(zon.numerocobranzas,0)
               dir.numerociudad || '-' || trim(catciu.inicialciudad) Ciudad, -- Clave ciudad
               catciu.numeroestado || '-' || trim(catciu.inicialestado) Estado -- Clave estado
        into chrentrecalles,chrcodpostal,chrnumext,
             chrnumint,chrnombrecalle,chrnombrezona,
             chrobservaciones,chrestado,vchrciudad,chrtelefono,
--JOM        intnumcobranza
             vchrclaciucobr, vchrclaedocobr
		from bdinteg:si_direcciones_actual dir
		left outer join bdinteg:si_telefonos_actual tel on (tel.empresa='001' and dir.numcte = tel.numcte and tipo_tel='1')
        left outer join bdinteg:si_catcalles cal on(cal.numerocalle=dir.numerocalle)
        left outer join bdinteg:si_catzonas zon on(zon.numerociudad=dir.numerociudad and zon.numerocolonia=dir.numerocolonia)
        left outer join bdinteg:si_estados edo on(edo.pais='001' and edo.estado=dir.estado)
        left outer join bdinteg:si_ciudades ciu on(ciu.pais=dir.pais and ciu.estado=dir.estado and ciu.ciudad=dir.ciudad)
        left outer join bdinteg:si_catciudades catciu on (dir.numerociudad = catciu.numerociudad)
		where dir.numcte=chrnumcte and dir.tipo_dir='1';
 
        --Obtiene la respuesta de la os y su fecha
        select status, fecha_respuesta
		into chrrespuesta,dtefecharesp
		from bdisolic:ss_solicitud_os
		where empresa='001' and num_solicitud = chrnumsolicitud 
		and secuenciaos =
		(
			select max(secuenciaos) from bdisolic:ss_solicitud_os
			where empresa='001' and num_solicitud = chrnumsolicitud and fecha_solicitud > date(0)
		)
		and fecha_solicitud = (
			select max(fecha_solicitud) from bdisolic:ss_solicitud_os
			where empresa='001' and num_solicitud = chrnumsolicitud);
			
		let chrrespuesta = trim(chrrespuesta); 

        if chrrespuesta is null then
            let chrrespuesta = '';
        end if;

		--Obtiene la situacion especial de la os y su causa
        select situacionespecial, nvl(causasituacionespecial,0)
		into chrsitesp,intcausasitesp
		from bdisolic:ss_osclientesupervisar
		where empresa='001' and num_solicitud = chrnumsolicitud and
		fechasolicitud =
		(
			select max(fechasolicitud) from bdisolic:ss_osclientesupervisar
			where empresa='001' and num_solicitud = chrnumsolicitud and fechasolicitud > date(0)
		);
		
		let chrsitesp = trim(chrsitesp); 
		
        if chrsitesp is not null and intcausasitesp is not null then
            --Obtiene la explicacion de la causa de la situacion especial del cliente
			
			select nvl(descripcion,'') into chrdescsitesp from bdicred:sd_causas_os
            where empresa = '001' and situacion = chrsitesp and causa = intcausasitesp;
			
			let chrdescsitesp = trim(chrdescsitesp);
			
            if chrdescsitesp <> '' then
                select nvl(descripcion,'') into chrdescsitesp from bdicred:sd_causas_os
                where empresa = '001' and situacion = chrsitesp and causa = intcausasitesp;
				
				let chrdescsitesp = trim(chrdescsitesp);
				
            else
                let chrdescsitesp = '';
            end if;
        else
            let intcausasitesp = 0;
            let chrsitesp = '';
            let chrdescsitesp = '';
        end if;

        --Obtiene el parametro del Salario Minimo BanCoppel
        select nvl(valor,0)*1 into intsmb
        from bdisolic:ss_param
        where secuencia = 303 and empresa = '001';
		
		--Obtiene el ingreso mensual declarado por el cliente y el ingreso en SMB
        --Obtener los abonosmensuales en ropa, muebles y prestamo, el pago minimo y evalua_cc
        select round(nvl(ingreso_mensual,0),2), nvl(abonomensualmuebles,0), nvl(abonomensualropa,0), nvl(abonomensualprestamos,0), nvl(pago_minimo,0), evalua_cc
        into mnyingreso,mnyabonomensualmuebles,mnyabonomensualropa,mnyabonomensualprestamos,mnypago_minimo,chrevalua_cc
        from bdisolic:ss_resum_scor_fin
        where empresa = '001' and num_solicitud = chrnumsolicitud;
		
        --Obtiene el ingreso mensual declarado por el cliente y el ingreso en SMB
        select round(nvl(ingreso_mensual,0),2) into mnyingreso
        from bdisolic:ss_resum_scor_fin
        where empresa = '001' and num_solicitud = chrnumsolicitud;

        let mnyingresosmb = round(nvl(mnyingreso,0)/intsmb);
		

		--Obtiene el detalle del scoring seccion 2
        let vchrrespuesta1      ="";
        let vchrrespuesta2      ="";
        let vchrrespuesta3      ="";
        let vchrrespuesta4      ="";
        let vchrrespuesta5      ="";
        let vchrrespuesta6      ="";
        let vchrrespuesta7      ="";
        let vchrrespuesta8      ="";
        let vchrrespuesta9      ="";
        let vchrrespuesta10     ="";
        let vchrrespuesta13     ="";
        --PQ
        let vchrrespuesta15     ="";
        --let vchrpregunta16      ="";
        let vchrrespuesta16     ="";
        let vchrpregunta17      ="";
        let vchrrespuesta17     ="";
        --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        let vchrrespuesta18     ="";
        let vchrrespuesta19     ="";
        let vchrrespuesta20     ="";
        let vchrrespuesta21     ="";
        let vchrrespuesta22     ="";
        let vchrrespuesta23     ="";
        let vchrrespuesta24     ="";
        let vchrrespuesta25     ="";
        let vchrrespuesta26     ="";
        let vchrrespuesta27     ="";
        let vchrrespuesta28     ="";
        let vchrrespuesta29     ="";
        let vchrrespuesta30     ="";
        let vchrrespuesta31     ="";
        let vchrrespuesta32     ="";
        let vchrrespuesta33     ="";
        let vchrrespuesta34     ="";
        let vchrrespuesta35     ="";
--MJPC agregar variables para reporte solic_credito
		let vchrrespuesta36		="";
		let vchrrespuesta37		="";
		let vchrrespuesta38		="";
		let vchrrespuesta39		="";
		let vchrrespuesta40		="";
		let vchrrespuesta41		="";
		let vchrrespuesta42		="";
		let vchrrespuesta43		="";
		let vchrrespuesta44		="";
		let vchrrespuesta45		="";
		let vchrrespuesta46		="";
		let vchrrespuesta47		="";
		let vchrrespuesta48		="";
		let vchrrespuesta49		="";
		let vchrrespuesta50		="";
--MJPC Valores putuales
		let varpuntual18         =0;
        let varpuntual19         =0;
        let varpuntual20         =0;
        let varpuntual21         =0;
        let varpuntual22         =0;
        let varpuntual23         =0;
        let varpuntual24         =0;
        let varpuntual25         =0;
        let varpuntual26         =0;
        let varpuntual27         =0;
        let varpuntual28         =0;
        let varpuntual29         =0;
        let varpuntual30         =0;
        let varpuntual31         =0;
        let varpuntual32         =0;
        let varpuntual33         =0;
        let varpuntual35         =0;
	--MJPC agregar variables para reporte solic_credito
		let varpuntual36         =0;
		let varpuntual37         =0;
		let varpuntual38         =0;
		let varpuntual39         =0;
		let varpuntual40         =0;
		let varpuntual41         =0;
		let varpuntual42         =0;
		let varpuntual43         =0;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
        let decvalor1           =0;
        let decvalor2           =0;
        let decvalor3           =0;
        let decvalor4           =0;
        let decvalor5           =0;
        let decvalor6           =0;
        let decvalor7           =0;
        let decvalor8           =0;
        let decvalor9           =0;
        let decvalor10          =0;
        --let decvalor11          =0;
        --let decvalor12          =0;
        let decvalor13          =0;
        --PQ
        --let decvalor14         =0;
        let decvalor15         =0;
        let decvalor16         =0;
        let decvalor17         =0;
        --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        let decvalor18         =0;
        let decvalor19         =0;
        let decvalor20         =0;
        let decvalor21         =0;
        let decvalor22         =0;
        let decvalor23         =0;
        let decvalor24         =0;
        let decvalor25         =0;
        let decvalor26         =0;
        let decvalor27         =0;
        let decvalor28         =0;
        let decvalor29         =0;
        let decvalor30         =0;
        let decvalor31         =0;
        let decvalor32         =0;
        let decvalor33         =0;
        let decvalor34         =0;
        let decvalor35         =0;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
--MJPC agregar variables para reporte solic_credito
		let decvalor36         =0;
		let decvalor37         =0;
		let decvalor38         =0;
		let decvalor39         =0;
		let decvalor40         =0;
		let decvalor41         =0;
		let decvalor42         =0;
		let decvalor43         =0;
		let decvalor44         =0;
		let decvalor45         =0;
		let decvalor46         =0;
		let decvalor47         =0;
		let decvalor48         =0;
		let decvalor49         =0;
		let decvalor50         =0;
		LET cStatus_Ini = "";
		LET cRevisado = "";
		LET cIdbox = 0;
		LET cIfe = "";

--Obtener la edad como valor puntual respuesta9
		select year(a.fecha_insert) - year(fecha_nac)
		into vchrrespuesta9
		from bdisolic:ss_solicitudes a
		inner join bdinteg:si_ctepf cte on(cte.numcte=a.numcte)
		where a.empresa='001' and a.num_solicitud= chrnumsolicitud;
		
        let intcontador        =0;
		foreach
		select variable,nvl(valor,0) 
		into vchsvariable,decvalor_punt 
		from bdisolic:ss_detalle_modelo where empresa = '001'
			   and num_solicitud = chrnumsolicitud 
			   
		if vchsvariable = 'BC_1' then
			let varpuntual18 = decvalor_punt;
		elif vchsvariable = 'BC_101' then
			let varpuntual19 = decvalor_punt;
		elif vchsvariable = 'BC_117' then
			let varpuntual20 = decvalor_punt;
		elif vchsvariable = 'BC_119' then
			let varpuntual21 = decvalor_punt;
		elif vchsvariable = 'BC_20' then
			let varpuntual22 = decvalor_punt;
		elif vchsvariable = 'BC_421' then
			let varpuntual23 = decvalor_punt;
		elif vchsvariable = 'BC_85' then
			let varpuntual24 = decvalor_punt;
		elif vchsvariable = 'BC_93' then
			let varpuntual25 = decvalor_punt;
		elif vchsvariable = 'CALC_PCT_SALDO_LIMIT' then
			let varpuntual29 = decvalor_punt;
		elif vchsvariable = 'CALC_PCT_SALDO_LINEA' then
			let varpuntual26 = decvalor_punt;
		elif vchsvariable = 'PMESESHIST' then
			let varpuntual27 = decvalor_punt;
		elif vchsvariable = 'PSITUACIONPAGOCOPPEL' then
			let varpuntual28 = decvalor_punt;
		elif vchsvariable = 'EDO_CIVIL_&_TIEMPO_ESTADO_CIVIL' then
			let varpuntual30 = decvalor_punt;
		elif vchsvariable = 'MESES_HISTORIA_&_CLIENTE_NUEVO' then
			let varpuntual31 = decvalor_punt;
		elif vchsvariable = 'CALC_PCT_SALDO_LINEA_&_CLIENTE_NUEVO' then
			let varpuntual32 = decvalor_punt;
		elif vchsvariable = 'SITUACION_PAGO_&_CLIENTE_NUEVO' then
			let varpuntual33 = decvalor_punt;
		elif vchsvariable = 'MESES_ULTIMA_CONSULTA' then
			let varpuntual35 = decvalor_punt;
		elif vchsvariable = 'HR0048' then
			let varpuntual36 = decvalor_punt;
		elif vchsvariable = 'UT0034' then
			let varpuntual37 = decvalor_punt;
		--valor puntual OCUPACION_&_TIEMPO_OCUPACION
		elif vchsvariable = 'OCUPACION_&_TIEMPO_OCUPACION' then
			let varpuntual38 = decvalor_punt;
		--valor puntual HR0050
		elif vchsvariable = 'HR0050' then
			let varpuntual39 = decvalor_punt;
		--valor puntual IV_TRD_OLDEST_AVERAGE_AGE
		elif vchsvariable = 'IV_TRD_OLDEST_AVERAGE_AGE' then
			let varpuntual40 = decvalor_punt;
		--valor puntual RAT_MONTO_OTORGADO_CP
		elif vchsvariable = 'RAT_MONTO_OTORGADO_CP' then
			let varpuntual41 = decvalor_punt;
		--valor puntual IQ0002
		elif vchsvariable = 'IQ0002' then
			let varpuntual42 = decvalor_punt;
		--valor puntual IV_OCUP_ESCOL
		elif vchsvariable = 'IV_OCUP_ESCOL' then
			let varpuntual43 = decvalor_punt;
		end if;
		end foreach; 

		foreach
			select a.descripcion, c.descripcion, nvl(b.valor,0),a.grupo,c.elemento
			into vchrpregunta,vchrrespuesta,decvalor,intgrupo,intelemento
			from ss_scoring_grupo a, ss_detalle_scoring b, ss_scoring_element c
            where a.empresa = '001' and a.seccion = 2
			and b.num_solicitud = chrnumsolicitud
			and b.tpo_persona = '01'
			and a.empresa = b.empresa
            and a.grupo <> 25 --JCP Grupo OS Telefonica
			and a.grupo = b.grupo
			and a.grupo = c.grupo
			and a.seccion = b.seccion
			and a.seccion = c.seccion
			and b.elemento = c.elemento
			and b.tpo_persona = c.tpo_persona
			order by b.seccion, b.grupo, b.elemento
			
			let vchrpregunta = trim(vchrpregunta);
			let vchrrespuesta = trim(vchrrespuesta);
			
			if intgrupo = 2 then
				let vchrrespuesta1 = vchrrespuesta;
				let decvalor1 = decvalor;
			elif intgrupo = 3 then
                let intelementoaux = intelemento;
                let intgrupoaux = intgrupo;
				let vchrrespuesta2 = vchrrespuesta;
				let decvalor2 = decvalor;
			elif intgrupo = 4 then
                let vchrrespuesta3 = vchrrespuesta;
                let decvalor3 = decvalor;
			elif intgrupo = 5 then
				let vchrrespuesta4 = vchrrespuesta;
				let decvalor4 = decvalor;
			elif intgrupo = 6 then
				let vchrrespuesta5 = vchrrespuesta;
				let decvalor5 = decvalor;
			elif intgrupo = 7 then
				let vchrrespuesta6 = vchrrespuesta;
				let decvalor6 = decvalor;
			elif intgrupo = 8 then
                let intelementoaux = intelemento;
                let intgrupoaux = intgrupo;
				let vchrrespuesta7 = vchrrespuesta;
				let decvalor7 = decvalor;
			elif intgrupo = 9 then
                let vchrrespuesta8 = vchrrespuesta;
                let decvalor8 = decvalor;
            elif intgrupo = 10 then
				let decvalor9 = decvalor;
			elif intgrupo = 11 then
				let vchrrespuesta10 = vchrrespuesta;
				let decvalor10 = decvalor;
			--PQ
			elif intgrupo = 16 then
				let vchrrespuesta13 = vchrrespuesta;
				let decvalor13 = decvalor;
            --PQ
			elif intgrupo = 21  then
				let vchrrespuesta15 = vchrrespuesta;
				let decvalor15 = decvalor;
			elif intgrupo = 22  then
				let vchrrespuesta16 = vchrrespuesta;
				let decvalor16 = decvalor;
			elif intgrupo = 23  then
				let vchrpregunta17 = vchrpregunta;
				let vchrrespuesta17 = vchrrespuesta;
				let decvalor17 = decvalor;
            --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
			elif intgrupo = 26  then
				let vchrrespuesta18 = vchrrespuesta;
				let decvalor18 = decvalor;
			elif intgrupo = 27  then
				let vchrrespuesta19 = vchrrespuesta;
				let decvalor19 = decvalor;
			elif intgrupo = 28  then
				let vchrrespuesta20 = vchrrespuesta;
				let decvalor20 = decvalor;
			elif intgrupo = 29  then
				let vchrrespuesta21 = vchrrespuesta;
				let decvalor21 = decvalor;
			elif intgrupo = 30  then
				let vchrrespuesta22 = vchrrespuesta;
				let decvalor22 = decvalor;
			elif intgrupo = 31  then
				let vchrrespuesta23 = vchrrespuesta;
				let decvalor23 = decvalor;
			elif intgrupo = 32  then
				let vchrrespuesta24 = vchrrespuesta;
				let decvalor24 = decvalor;
			elif intgrupo = 33  then
				let vchrrespuesta25 = vchrrespuesta;
				let decvalor25 = decvalor;
			elif intgrupo = 34  then
				let vchrrespuesta26 = vchrrespuesta;
				let decvalor26 = decvalor;
			elif intgrupo = 35  then
				let vchrrespuesta27 = vchrrespuesta;
				let decvalor27 = decvalor;
			elif intgrupo = 36  then
				let vchrrespuesta28 = vchrrespuesta;
				let decvalor28 = decvalor;
			elif intgrupo = 37  then
				let vchrrespuesta29 = vchrrespuesta;
				let decvalor29 = decvalor;
			elif intgrupo = 44  then   -- INI se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
				let vchrrespuesta30 = vchrrespuesta;
				let decvalor30 = decvalor;
			elif intgrupo = 45  then
				let vchrrespuesta31 = vchrrespuesta;
				let decvalor31 = decvalor;
			elif intgrupo = 46  then
				let vchrrespuesta32= vchrrespuesta;
				let decvalor32 = decvalor;
			elif intgrupo = 47  then   
				let vchrrespuesta33 = vchrrespuesta;
				let decvalor33 = decvalor;
			elif intgrupo = 42  then   
				let vchrrespuesta34 = vchrrespuesta;
				let decvalor34 = decvalor;
			elif intgrupo = 43  then   
				let vchrrespuesta35 = vchrrespuesta;
				let decvalor35 = decvalor;  -- FIN se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
			--MJPC agregar variables para reporte solic_credito
			-- HR0048 Numero de cuentas abiertas con 12 meses o mas
			elif intgrupo = 50  then
				let vchrrespuesta36 = vchrrespuesta;
				let decvalor36 = decvalor;
			-- UT0034 Porcentaje de utilizacion en cuentas revolventes bancarias
			elif intgrupo = 51  then
				let vchrrespuesta37 = vchrrespuesta;
				let decvalor37 = decvalor;
			--Variable interactiva: Ocupacion & Tiempo Ocupacion Actual
			elif intgrupo = 52  then
				let vchrrespuesta38 = vchrrespuesta;
				let decvalor38 = decvalor;
			--HR0050 # de cuentas abiertas en los ultimos 6 meses o mas
            elif intgrupo = 53  then
				let vchrrespuesta39 = vchrrespuesta;
				let decvalor39 = decvalor;
			--Variable interactiva: IV_TRD_OLDEST_AVERAGE_AGE
            elif intgrupo = 54  then
				let vchrrespuesta40 = vchrrespuesta;
				let decvalor40 = decvalor;
			-- RAT_MONTO_OTORGADO_CP: Monto otorgado y capacidad de pago  
            elif intgrupo = 55  then
				let vchrrespuesta41 = vchrrespuesta;
				let decvalor41 = decvalor;
			--IQ0002: Num. de consultas en los ultimos 3 meses 
            elif intgrupo = 56  then
				let vchrrespuesta42 = vchrrespuesta;
				let decvalor42 = decvalor;
			--Variable interactiva: OcupaciÃ³n y escolaridad
            elif intgrupo = 57  then
				let vchrrespuesta43 = vchrrespuesta;
				let decvalor43 = decvalor;
			--Grupo Originacion	
			elif intgrupo = 49  then
				let vchrrespuesta44 = vchrrespuesta;
				let decvalor44 = decvalor;
			--Ingreso	
			elif intgrupo = 63  then
				let vchrrespuesta45 = vchrrespuesta;
				let decvalor45 = decvalor;
			--Variable interactiva: Genero & Edad
            elif intgrupo = 64  then
				let vchrrespuesta46 = vchrrespuesta;
				let decvalor46 = decvalor;
			--Variable interactiva: Sexo & Ocupacion
            elif intgrupo = 65  then
				let vchrrespuesta47 = vchrrespuesta;
				let decvalor47 = decvalor;
			--Variable interactiva: Edo Civil & Escolaridad 
            elif intgrupo = 66  then
				let vchrrespuesta48 = vchrrespuesta;
				let decvalor48 = decvalor;
			--Variable interactiva: Edad & Escolaridad 
            elif intgrupo = 67  then
				let vchrrespuesta49 = vchrrespuesta;
				let decvalor49 = decvalor;
			--Variable interactiva: Entidad & Localidad
			elif intgrupo = 68  then
				let vchrrespuesta50 = vchrrespuesta;
				let decvalor50 = decvalor;
 --JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
            end if;

		end foreach;


                --PQ
                SELECT
                        nvl(SUM(decode(seccion, '1', nvl(evaluacion,0), 0)),0) AS seccion1,
                        nvl(SUM(decode(seccion, '2', nvl(evaluacion,0), 0)),0) AS seccion2,
                        nvl(SUM(nvl(evaluacion, 0)),0) AS Suma,
                        COUNT(num_solicitud) AS Cantidad
                INTO dEvaluacion1, dEvaluacion2, dSuma, iCantidad
                FROM bdisolic:ss_resumen_scoring
                WHERE empresa= '001'
                AND seccion in ('1', '2')
                AND num_solicitud = chrnumsolicitud;
                --PQ
--IPCB Marzo2016 RQM 09 398-0 FICO Extended
				SELECT  nvl(SUM(decode(seccion, '3', nvl(evaluacion,0), 0)),0) AS seccion3,
                        nvl(SUM(decode(seccion, '4', nvl(evaluacion,0), 0)),0) AS seccion4,
                        nvl(SUM(decode(seccion, '5', nvl(evaluacion,0), 0)),0) AS seccion5
                INTO dEvaluacion3, dEvaluacion4,dEvaluacion5
                FROM bdisolic:ss_resumen_scoring
                WHERE empresa= '001'
                AND seccion in ('3', '4','5')
				AND num_solicitud = chrnumsolicitud;
				
				
				
                --PQ
                IF iCantidad = 2 THEN

                        let decseccion1= dEvaluacion1;
                        let decseccion2= dEvaluacion2;
                        let decsuma= dSuma;

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
                        --PQ

                        let decseccion2 = decvalor1 + decvalor2 + decvalor3 + decvalor4 + decvalor5 + decvalor6 + decvalor7 +
                                          decvalor8 + decvalor9 + decvalor10 + decvalor13 +
                                          decvalor15 +  decvalor16 + decvalor17;
                        --PQ
                        LET decseccion1 = dEvaluacion2 - decseccion2;

                        --Obtiene el total del scoring del cliente
                        let decsuma = decseccion1 + decseccion2;

                 END IF;
                 --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
			select first 1 nvl(sc01,'')
			into cbcscore
			from bdiburo:br_sc
			where num_cliente = chrnumcte;
		 
			-- MODIFICACION REPORTE RQM 09 459-2 (INICIO)
			SELECT status_ini
			INTO cStatus_Ini
			FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			AND num_solicitud = chrnumsolicitud;
			 
			IF cStatus_Ini IS NULL THEN
			   LET cStatus_Ini = ' ';
			END IF;
			
			SELECT revisado
			INTO cRevisado
			FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			AND num_solicitud = chrnumsolicitud;
			
			IF cRevisado IS NULL THEN
				LET cRevisado = ' ';
			ELIF cRevisado = 'N' THEN
				LET cRevisado = 'C';
			ELSE
				LET cRevisado = 'R';
			END IF;
						
			SELECT COUNT(*) 
			INTO cIdbox
			FROM bdisolic:"informix".ss_solicitudes_mc a
			RIGHT OUTER JOIN bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			WHERE empresa = '001'
			AND num_solicitud = chrnumsolicitud;
			 			
			IF cIdbox >= 1 THEN 
				LET cIFE = 'Si';
			ELSE   
				LET cIFE = 'No'; 
			END IF;	
			-- MODIFICACION REPORTE RQM 09 459-2 (FIN)
	
		--Inserta en ss_riesgos_os para consulta del area de Riesgos

		insert into bdisolic:ss_riesgos_os (numsolicitud,numcte,numctecoppel,sucursal,appaterno,apmaterno,nombre1,
					nombre2,statussol,numproducto,sitesp,respuesta,ejecutivo,descsitesp,lincred,eficponderada,
					meses,causasitesp,fechasol,fecharesp,seccion1,seccion2,sumascoring,respuestacc,
					sexo,valor_sexo,estado_civil,valor_estado_civil,tmpo_edo_civ_act,valor_tmpo_edo_civ_act,
					tipo_residencia,valor_tipo_residencia,tmpo_dom_act,valor_tmpo_dom_act,ocupacion,valor_ocupacion,
					tmpo_ocup_act,valor_tmpo_ocup_act,tmpo_ocup_ant,valor_tmpo_ocup_ant,edad,valor_edad,
					depend_econ,valor_depend_econ,
                    seguro_popular,valor_seguro_popular,escolaridad,valor_escolaridad,
                    hab_domic,valor_hab_domic,pregunta17,respuesta17,valor17,
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
                    BC_1,puntual_BC_1,valor_BC_1,BC_101,puntual_BC_101,valor_BC_101,BC_117,puntual_BC_117,valor_BC_117, 
                    BC_119,puntual_BC_119,valor_BC_119,BC_20,puntual_BC_20,valor_BC_20,BC_421,puntual_BC_421,valor_BC_421, 
                    BC_85,puntual_BC_85,valor_BC_85,BC_93,puntual_BC_93,valor_BC_93,calc_PCT_saldo_linea,puntual_calc_PCT_saldo_linea,valor_calc_PCT_saldo_linea, 
                    meses_historia,puntual_meses_historia,valor_meses_historia,situacion_pago,puntual_situacion_pago,valor_situacion_pago,ratio_saldo_credit_limit,puntual_ratio_saldo_credit_limit,valor_ratio_saldo_credit_limit, 
                    tipocliente,filtrocliente,saldoropa,saldomuebles,saldoprestamo,lineatienda,bcscore,prueba,
--AGREGAR VARIABLES JANETH	
					causa,status,compromisos,fecha_apert,edad_1,email,tel_ofi,tel_cel,fuente,				
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
                    calle,numext,numint,colonia,
                    codpostal,entrecalles,observaciones, estado,localidad,nombresuc,telsuc,nombregte,telefono,
                    ingresomensual,ingresosmb,rfc,fechanac, 
--jom               clavecc4,importecc4,fechacc4,mops4,clavecc5,importecc5,fechacc5,mops5,numcobranza)
                    claciucobr,claedocobr,
--agregar variables MJPC sept 2012
					abono_muebles,abono_ropa,abono_prestamos,compromisos_mensuales,evalua_cc,
                    VI_EdoCiv_TmpoEdoCiv, puntual_VI_EdoCiv_TmpoEdoCiv, valor_VI_EdoCiv_TmpoEdoCiv,
                    VI_MesesHist_CteNvo, puntual_VI_MesesHist_CteNvo, valor_VI_MesesHist_CteNvo,
                    VI_CalcPctSdoLin_CteNvo, puntual_VI_CalcPctSdoLin_CteNvo, valor_VI_CalcPctSdoLin_CteNvo,
                    VI_SitPago_CteNvo, puntual_VI_SitPago_CteNvo, valor_VI_SitPago_CteNvo,
                    region_cobranza, valor_region_cobranza,
                    Meses_ult_cons_buro_iq, puntual_Meses_ult_cons_buro_iq, valor_Meses_ult_cons_buro_iq, 
				--MJPC agregar variables para reporte solic_credito
					hr0048,puntual_hr0048,valor_hr0048,ut0034,puntual_ut0034,valor_ut0034,
					vi_ocup_tmpo_ocup,puntual_vi_ocup_tmpo_ocup,valor_vi_ocup_tmpo_ocup,hr0050,puntual_hr0050,valor_hr0050,
					iv_trd_oldest_average_age,puntual_iv_trd_oldest_average_age,valor_iv_trd_oldest_average_age,
					rat_monto_otorgado_CP,puntual_rat_monto_otorgado_CP,valor_rat_monto_otorgado_CP,
					iq0002,puntual_iq0002,valor_iq0002,iv_ocup_escolar,puntual_iv_ocup_escolar,valor_iv_ocup_escolar,
				--MJPC Anexa solic
				    grupo_originacion,valor_grupo_originacion,ingreso_mensual,valor_ingreso_mensual,iv_sexo_edad,valor_iv_sexo_edad,iv_entidad_localidad,valor_iv_entidad_localidad,
					iv_sexo_ocupacion,valor_iv_sexo_ocupacion,iv_edociv_escolaridad,valor_iv_edociv_escolaridad,iv_edad_escolaridad,valor_iv_edad_escolaridad,
					grupo,seccion3 ,seccion4 ,seccion5, flag2creditoicc, statusini, revisado, ife )
		values (chrnumsolicitud,chrnumcte,chrnumctecoppel,chrsucursal,chrappaterno,chrapmaterno,chrnombre1,chrnombre2,
				chrstatussol,chrnumproducto,chrsitesp,chrrespuesta,chrejecutivo,chrdescsitesp,declincred,deceficponderada,
				intmeses,intcausasitesp,dtefechasol,dtefecharesp,decseccion1,decseccion2,decsuma,vchrrespuestacc,
				vchrrespuesta1,decvalor1,vchrrespuesta2,decvalor2,vchrrespuesta3,decvalor3,
				vchrrespuesta4,decvalor4,vchrrespuesta5,decvalor5,vchrrespuesta6,decvalor6,
				vchrrespuesta7,decvalor7,vchrrespuesta8,decvalor8,vchrrespuesta9,decvalor9,
				vchrrespuesta10,decvalor10,
                vchrrespuesta13,decvalor13,vchrrespuesta15,decvalor15,
                vchrrespuesta16,decvalor16,vchrpregunta17,vchrrespuesta17,decvalor17,
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
                vchrrespuesta18,varpuntual18,decvalor18,vchrrespuesta19,varpuntual19,decvalor19,vchrrespuesta20,varpuntual20,decvalor20, 
                vchrrespuesta21,varpuntual21,decvalor21,vchrrespuesta22,varpuntual22,decvalor22,vchrrespuesta23,varpuntual23,decvalor23, 
                vchrrespuesta24,varpuntual24,decvalor24,vchrrespuesta25,varpuntual25,decvalor25,vchrrespuesta26,varpuntual26,decvalor26, 
                vchrrespuesta27,varpuntual27,decvalor27,vchrrespuesta28,varpuntual28,decvalor28,vchrrespuesta29,varpuntual29,decvalor29, 
                ctipoc,cFiltroC,dSdoropa,dSdomuebles,dSdoprestamo,dSdolineatienda,cbcscore,cPrueba,
--AGREGAR VARIABLES JANETH	
				v_causa, v_status,v_compromisos,v_fecha_apert, v_edad, v_email, v_tel_ofi, v_tel_cel, v_fuente,
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
                chrnombrecalle,chrnumext,chrnumint,chrnombrezona,chrcodpostal,chrentrecalles,chrobservaciones,
                chrestado,vchrciudad,chrnombresuc,chrtelsuc,chrnombregte,chrtelefono,mnyingreso,mnyingresosmb,chrrfc,dtefechanac,
--jom           chrclavecc4,mnyimporte4,dtefechacc4,chrmop4,chrclavecc5,mnyimporte5,dtefechacc5,chrmop5,intnumcobranza);
                vchrclaciucobr,vchrclaedocobr,
--agregar variables MJPC sept 2012
				mnyabonomensualmuebles,mnyabonomensualropa,mnyabonomensualprestamos,mnypago_minimo,chrevalua_cc,
                vchrrespuesta30,varpuntual30,decvalor30, vchrrespuesta31,varpuntual31,decvalor31, -- INI se agregan variables interactivas RQM 07 048-03
                vchrrespuesta32,varpuntual32,decvalor32, vchrrespuesta33,varpuntual33,decvalor33,
                vchrrespuesta34,decvalor34, vchrrespuesta35,varpuntual35,decvalor35,
--MJPC agregar variables para reporte solic_credito
				vchrrespuesta36,varpuntual36,decvalor36,vchrrespuesta37,varpuntual37,decvalor37,
				vchrrespuesta38,varpuntual38,decvalor38,vchrrespuesta39,varpuntual39,decvalor39,
				vchrrespuesta40,varpuntual40,decvalor40,
				vchrrespuesta41,varpuntual41,decvalor41,
				vchrrespuesta42,varpuntual42,decvalor42,vchrrespuesta43,varpuntual43,decvalor43,
			--MJPC Anexa campso solic
				vchrrespuesta44,decvalor44,vchrrespuesta45,decvalor45,vchrrespuesta46,decvalor46,
				vchrrespuesta47,decvalor47,vchrrespuesta48,decvalor48,vchrrespuesta49,decvalor49,vchrrespuesta50,decvalor50,
				cgrupo_solic,dEvaluacion3, dEvaluacion4 ,dEvaluacion5,cFlag2Credito, cStatus_Ini, cRevisado, cIfe);
                let icontadorcommit = icontadorcommit + 1;

                if (icontadorcommit >= 100) then
                   commit work;
                   let icontadorcommit = 0;
                end if;

	end foreach;

    if ( icontadorcommit > 0) then
        commit work;
    end if;


    CREATE INDEX "informix".inx_ss_riesgos_os ON "informix".ss_riesgos_os(numsolicitud) in dbs_movhis_idx5;
    update statistics medium for table "informix".ss_riesgos_os;

    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO FRACTION INTO vHora FROM sysmaster:sysshmvals;

    INSERT INTO "informix".ss_bitacora_os(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
    VALUES('Reporte de Solicitudes', substr(chrcodret,2,5), 'Termina proceso', 'informix', today, vHora);

--	commit work;

return chrcodret,chrmensaje;
end;

end procedure;