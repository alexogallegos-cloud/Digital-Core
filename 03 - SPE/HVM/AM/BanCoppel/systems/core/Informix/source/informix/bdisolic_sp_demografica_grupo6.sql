CREATE PROCEDURE "informix".sp_demografica_grupo6()
-- execute PROCEDURE "informix".sp_demografica_grupo6();

returning   char(06),
            char(70); 
--Declaracion de variables
DEFINE chrcodret			char(06);
DEFINE chrmensaje           char(70);
DEFINE chrnumsolicitud		char(20);
DEFINE chrsucursal			char(4);
DEFINE chrappaterno			char(26);
DEFINE chrapmaterno			char(26);
DEFINE chrnombre1			char(26);
DEFINE chrnombre2			char(26);
DEFINE chrstatussol			char(2);
DEFINE chrnumproducto		char(4);
DEFINE chrsitesp			char(1);
DEFINE chrrespuesta			char(1);
DEFINE chrnumcte			char(20);
DEFINE chrnumctecoppel		char(20);
DEFINE chrejecutivo			char(30);
DEFINE chrdescsitesp		char(80);
DEFINE chrrfc				char(13);
DEFINE chrnombrezona		char(30);
DEFINE chrnombrecalle		char(30);
DEFINE chrentrecalles		char(40);
DEFINE chrcodpostal			char(5);
DEFINE chrnumext			char(10);
DEFINE chrnumint			char(10);
DEFINE chrobservaciones	    char(80);
DEFINE chrestado            char(30);
DEFINE chrnombresuc         char(40);
DEFINE chrtelsuc            char(14);
DEFINE chrnombregte         char(40);
DEFINE chrtelefono          char(13);
DEFINE vchrpregunta         varchar(80);
DEFINE vchrrespuesta		varchar(80);
DEFINE vchrrespuesta1		varchar(80);
DEFINE vchrrespuesta2		varchar(80);
DEFINE vchrrespuesta3		varchar(80);
DEFINE vchrrespuesta4		varchar(80);
DEFINE vchrrespuesta5		varchar(80);
DEFINE vchrrespuesta6		varchar(80);
DEFINE vchrrespuesta7		varchar(80);
DEFINE vchrrespuesta8		varchar(80);
DEFINE vchrrespuesta9		varchar(80);
DEFINE vchrrespuesta10		varchar(80);
DEFINE vchrrespuesta13		varchar(80);
DEFINE vchrrespuesta15      varchar(80);
DEFINE vchrrespuesta16      varchar(80);
DEFINE vchrpregunta17       varchar(80);
DEFINE vchrrespuesta17      varchar(80);DEFINE varpuntuarespuesta2 varchar(80);DEFINE varpuntuarespuesta3 varchar(80);DEFINE varpuntuarespuesta4 varchar(80);DEFINE varpuntuarespuesta5 varchar(80);DEFINE varpuntuarespuesta6 varchar(80);DEFINE varpuntuarespuesta7 varchar(80);DEFINE varpuntuarespuesta8 varchar(80);DEFINE varpuntuarespuesta9 varchar(80);DEFINE varpuntuarespuesta10 varchar(80);DEFINE varpuntuarespuesta11 varchar(80);
DEFINE varpuntuarespuesta13 varchar(80);
DEFINE varpuntuarespuesta15 varchar(80);DEFINE varpuntuarespuesta16 varchar(80);DEFINE vchrrespuesta18      varchar(80);
DEFINE vchrrespuesta19      varchar(80);
DEFINE vchrrespuesta20      varchar(80);
DEFINE vchrrespuesta21      varchar(80);
DEFINE vchrrespuesta22      varchar(80);
DEFINE vchrrespuesta23      varchar(80);
DEFINE vchrrespuesta24      varchar(80);
DEFINE vchrrespuesta25      varchar(80);
DEFINE vchrrespuesta26      varchar(80);
DEFINE vchrrespuesta27      varchar(80);
DEFINE vchrrespuesta28      varchar(80);
DEFINE vchrrespuesta29      varchar(80);
DEFINE vchrrespuestacc		varchar(100);
DEFINE vchrciudad           varchar(200);
DEFINE vchrclaciucobr       varchar(10);
DEFINE vchrclaedocobr       varchar(10);
DEFINE varpuntual18 		decimal(10,4);
DEFINE varpuntual19 		decimal(10,4);
DEFINE varpuntual20 		decimal(10,4);
DEFINE varpuntual21 		decimal(10,4);
DEFINE varpuntual22 		decimal(10,4);
DEFINE varpuntual23 		decimal(10,4);
DEFINE varpuntual24 		decimal(10,4);
DEFINE varpuntual25 		decimal(10,4);
DEFINE varpuntual26 		decimal(10,4);
DEFINE varpuntual27 		decimal(10,4);
DEFINE varpuntual28 		decimal(10,4);
DEFINE varpuntual29 		decimal(10,4);
DEFINE declincred			decimal(18,2);
DEFINE deceficponderada		decimal(5,2);
DEFINE decvalor				decimal(10,4);
DEFINE decvalor1			decimal(10,4);
DEFINE decvalor2			decimal(10,4);
DEFINE decvalor3			decimal(10,4);
DEFINE decvalor4			decimal(10,4);
DEFINE decvalor5			decimal(10,4);
DEFINE decvalor6			decimal(10,4);
DEFINE decvalor7			decimal(10,4);
DEFINE decvalor8			decimal(10,4);
DEFINE decvalor9			decimal(10,4);
DEFINE decvalor10			decimal(10,4);
DEFINE decvalor13			decimal(10,4);
DEFINE decvalor15			decimal(10,4);
DEFINE decvalor16			decimal(10,4);
DEFINE decvalor17			decimal(10,4);
DEFINE decvalor18			decimal(10,4);
DEFINE decvalor19			decimal(10,4);
DEFINE decvalor20			decimal(10,4);
DEFINE decvalor21			decimal(10,4);
DEFINE decvalor22			decimal(10,4);
DEFINE decvalor23			decimal(10,4);
DEFINE decvalor24			decimal(10,4);
DEFINE decvalor25			decimal(10,4);
DEFINE decvalor26			decimal(10,4);
DEFINE decvalor27			decimal(10,4);
DEFINE decvalor28			decimal(10,4);
DEFINE decvalor29			decimal(10,4);
DEFINE decseccion1			decimal(14,4);
DEFINE decseccion2			decimal(14,4);
DEFINE decsuma				decimal(14,4);
DEFINE decauxsec2			decimal(10,4);
DEFINE intmeses			    smallint;
DEFINE intcausasitesp		smallint;
DEFINE intcontador			smallint;
DEFINE intgrupo             smallint;
DEFINE intelemento			smallint;
DEFINE intsmb               smallint;
DEFINE intgrupoaux          smallint;
DEFINE intelementoaux       smallint;
DEFINE intelementoaux2       smallint;
DEFINE intcont              smallint;
DEFINE intnumcobranza       smallint;
DEFINE dtefechasol			date;
DEFINE dtefecharesp			date;
DEFINE dtefechanac			date;
DEFINE dtefechacc           date;
DEFINE intcodret			integer;
DEFINE mnyingreso           money(14,2);
DEFINE mnyingresosmb        money(14,2);
DEFINE mnyimporte           money(9,2);

DEFINE dEvaluacion1         decimal(14,4);
DEFINE dEvaluacion2         decimal(14,4);
DEFINE dSuma                decimal(14,4);
DEFINE iCantidad            integer;

DEFINE icontadorcommit      integer;

DEFINE dSdoropa             decimal(14,2);
DEFINE dSdomuebles          decimal(14,2);
DEFINE dSdoprestamo         decimal(14,2);
DEFINE dSdolineatienda      decimal(14,2);
DEFINE cPrueba              char(03);
DEFINE cFiltroC             char(10);
DEFINE cbcscore             char(04);
DEFINE ctipoc               char(03);
DEFINE vfecha        DATE;
DEFINE v_compromisos DECIMAL(14,2);
DEFINE v_causa           VARCHAR(255);
DEFINE v_status       VARCHAR(255);
DEFINE v_fecha_apert     DATE;
DEFINE v_edad            SMALLINT;
DEFINE v_email           CHAR(60);
DEFINE v_tel_ofi         CHAR(13);
DEFINE v_tel_cel         CHAR(13);
DEFINE v_fuente          CHAR(10);
DEFINE vardecl_imptos CHAR(40);
DEFINE  varvalor_decl_imptos CHAR(40);
DEFINE varIngreso_cte CHAR(40);
DEFINE varrango_Ingreso_cte CHAR(40);DEFINE varvalor_Ingreso_cte CHAR(40);
DEFINE varlincred CHAR(40);
DEFINE varScore_nhnc CHAR(40);
DEFINE varStatusAprobado CHAR(40);
DEFINE varregion CHAR(40);
DEFINE varrangoregion CHAR(40);DEFINE varvalorregion  CHAR(40);
DEFINE varmeses_ult_cons CHAR(40);
DEFINE varrango_meses_ult_cons CHAR(40);DEFINE varvalor_meses_ult_cons CHAR(40);
DEFINE varrango_edad CHAR(40);DEFINE varvalor_edad CHAR(40);
DEFINE varrango_resp_tmpedo_civil CHAR(40);DEFINE varvalor_tmpedo_civil decimal(10,4);
DEFINE varrango_tipo_resid CHAR(40);DEFINE varvalor_tipo_residencia CHAR(40);
DEFINE vchsvariable			varchar(80);
DEFINE decvalor_punt		decimal(10,4);
DEFINE mnyabonomensualmuebles      money(14,2);
DEFINE mnyabonomensualropa         money(14,2); 
DEFINE mnyabonomensualprestamos    money(14,2);
DEFINE mnypago_minimo              money(14,2);
DEFINE chrevalua_cc                char(1);
DEFINE  vproceso			CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
define sPaso smallint;
define pfechacorte  date;
define vlNumInsert smallint;
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cErrornfo           CHAR(80);
DEFINE iBandera           INTEGER;
DEFINE varrango_escolaridad_nhnc           CHAR(40);DEFINE varvalor_escolaridad_nhnc           CHAR(40);
define vpeso_grupo 			 INTEGER;
define velemento_final		 INTEGER;

--set debug file to "/informix/sp_demografica_grupo6.out";
--trace on;
				
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso	            = '2088';
LET cruta                   = "";
LET cnombre		   			 = "";
LET cnomarchivo             = "";
LET cnomarchivo1            = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "|";
let sPaso = 0;
let pfechacorte = date(1);
let vlNumInsert = 0;
let iBandera = 0;
let varrango_escolaridad_nhnc = '';
let varvalor_escolaridad_nhnc = '';
LET varregion ='';
LET varrangoregion='';
LET varvalorregion='';
--debug flag
LET vpeso_grupo 			=0;
LET velemento_final			=0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02')RETURNING cCod_ret;
        RETURN  sql_err,cMensaje;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret;
	
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 26;
	
	--Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM bdicobranza:cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
         RETURN  cCod_ret,cMensaje;
	END IF;
	
		
	select trim(valor_alfabetico) into cruta
	from bdicobranza:cb_param_campania 
	where tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 36;
	
	--Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM bdicobranza:cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
         RETURN  cCod_ret,cMensaje;
	END IF;
	
-----------GUARDA EN TEMPORAL PARA SELECCIONAR ELEMENTO-------------
	select grupo, elemento, peso_grupo6, rango_min, rango_max,rango_riesgos
	from bdisolic:ss_parametricos 
	where tipo_parametrico =1 and tp_solicitud ='T'
	INTO TEMP elemento;
--------------------------------------------------------------------
	
--Inicializacion de variables
LET chrcodret			="000000";
LET chrmensaje          = 'El proceso REPORTE DE SOLICITUDES se ejecutÃ³ exitosamente';
LET chrnumsolicitud		="";
LET chrsucursal			="";
LET chrappaterno		="";
LET chrapmaterno		="";
LET chrnombre1			="";
LET chrnombre2			="";
LET chrstatussol		="";
LET chrnumproducto		="";
LET chrsitesp			="";
LET chrrespuesta		="";
LET chrnumcte			="";
LET chrnumctecoppel		="";
LET chrejecutivo		="";
LET chrdescsitesp		="";
LET chrrfc				="";
LET chrnombrezona		="";
LET chrnombrecalle		="";
LET chrentrecalles		="";
LET chrcodpostal		="";
LET chrnumext			="";
LET chrnumint			="";
LET chrobservaciones	="";
LET chrestado           ="";
LET chrnombresuc        ="";
LET chrtelsuc           ="";
LET chrnombregte        ="";
LET chrtelefono         ="";
LET vchrpregunta		="";
LET vchrrespuesta		="";
LET vchrrespuesta1		="";
LET vchrrespuesta2		="";
LET vchrrespuesta3		="";
LET vchrrespuesta4		="";
LET vchrrespuesta5		="";
LET vchrrespuesta6		="";
LET vchrrespuesta7		="";
LET vchrrespuesta8		="";
LET vchrrespuesta9		="";
LET vchrrespuesta10		="";
LET vchrrespuesta13		="";
--PQ
LET vchrrespuesta15		="";
LET vchrrespuesta16		="";
LET vchrpregunta17		="";
LET vchrrespuesta17		="";
--PQ
--JMAH
LET varpuntuarespuesta2 ="";
LET varpuntuarespuesta3 ="";
LET varpuntuarespuesta4 ="";
LET varpuntuarespuesta5 ="";
LET varpuntuarespuesta6 ="";
LET varpuntuarespuesta7 ="";
LET varpuntuarespuesta8 ="";
LET varpuntuarespuesta9 ="";
LET varpuntuarespuesta10 ="";
LET varpuntuarespuesta11 ="";
LET varpuntuarespuesta13 ="";
LET varpuntuarespuesta15 ="";
LET varpuntuarespuesta16 ="";
--JMAH
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
LET vchrrespuesta18		="";
LET vchrrespuesta19 	="";
LET vchrrespuesta20		="";
LET vchrrespuesta21		="";
LET vchrrespuesta22		="";
LET vchrrespuesta23		="";
LET vchrrespuesta24		="";
LET vchrrespuesta25		="";
LET vchrrespuesta26		="";
LET vchrrespuesta27		="";
LET vchrrespuesta28		="";
LET vchrrespuesta29		="";
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO

LET vchrrespuestacc		="";
LET vchrciudad          ="";
--jom claves de cobranza
LET vchrclaciucobr      ="";
LET vchrclaedocobr      ="";
--MJPC Valores Puntuales
LET varpuntual18 		=0;
LET varpuntual19 		=0;
LET varpuntual20 		=0;
LET varpuntual21 		=0;
LET varpuntual22 		=0;
LET varpuntual23 		=0;
LET varpuntual24 		=0;
LET varpuntual25 		=0;
LET varpuntual26 		=0;
LET varpuntual27 		=0;
LET varpuntual28 		=0;
LET varpuntual29 		=0;

--jom claves de cobranza
LET declincred			=0;
LET deceficponderada	=0;
LET decvalor			=0;
LET decvalor1			=0;
LET decvalor2			=0;
LET decvalor3			=0;
LET decvalor4			=0;
LET decvalor5			=0;
LET decvalor6			=0;
LET decvalor7			=0;
LET decvalor8			=0;
LET decvalor9			=0;
LET decvalor10			=0;
LET decvalor13			=0;
--PQ
LET decvalor15			=0;
LET decvalor16			=0;
LET decvalor17			=0;
--PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
LET decvalor18         =0;
LET decvalor19         =0;
LET decvalor20         =0;
LET decvalor21         =0;
LET decvalor22         =0;
LET decvalor23         =0;
LET decvalor24         =0;
LET decvalor25         =0;
LET decvalor26         =0;
LET decvalor27         =0;
LET decvalor28         =0;
LET decvalor29         =0;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
LET decseccion1			=0;
LET decseccion2			=0;
LET decsuma				=0;
LET intmeses			=0;
LET intcausasitesp		=0;
LET intcontador			=0;
LET intcodret			=0;
LET intgrupo            =0;
LET intelemento			=0;
LET intsmb              =0;
LET intgrupoaux         =0;
LET intelementoaux      =0;
LET intelementoaux2      =0;
LET intcont             =0;
-- jom LET intnumcobranza   =0;
LET decauxsec2			=0;
LET mnyingreso          =0;
LET mnyingresosmb       =0;
LET mnyimporte          =0;

--PQ
LET dEvaluacion1        =0;
LET dEvaluacion2        =0;
LET dSuma               =0;
LET iCantidad           =0;
--PQ
LET icontadorcommit     =0;
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
LET dSdoropa             =0;
LET dSdomuebles          =0;
LET dSdoprestamo         =0;
LET dSdolineatienda      =0;
LET cPrueba              = '';
LET cFiltroC             = '';
LET cbcscore             = '';
LET ctipoc               = '';
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO


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
LET vchsvariable = "";
LET decvalor_punt = 0;

-- AGREGAR VARIABLES RQM 07 048-02 Adendum Modificaciones al SolicAAAAMMDD
LET mnyabonomensualmuebles   =0;
LET mnyabonomensualropa      =0; 
LET mnyabonomensualprestamos =0;
LET mnypago_minimo           =0;
LET chrevalua_cc        ="";

LET  vardecl_imptos ="";
LET   varvalor_decl_imptos ="";
LET  varIngreso_cte ="";
LET  varrango_Ingreso_cte ="";
LET  varvalor_Ingreso_cte ="";
LET  varlincred ="";
LET  varScore_nhnc ="";
LET  varStatusAprobado ="";
LET  varregion ="";
LET  varmeses_ult_cons ="";
LET  varrango_meses_ult_cons ="";
LET  varvalor_meses_ult_cons ="";
LET  varrango_edad ="";
LET  varvalor_edad ="";
LET  varrango_resp_tmpedo_civil ="";
LET  varvalor_tmpedo_civil ="";
LET  varrango_tipo_resid ="";
LET varvalor_tipo_residencia  ="";	
--	begin work;

	-------------------------------GENERA TABLA-------------------------------------
SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'ss_riesgos_grupo6';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE ss_riesgos_grupo6;
            END IF;

    CREATE TABLE "informix".ss_riesgos_grupo6 (
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
		respuestacc   	VARCHAR(100),
		sexo    	VARCHAR(80),
		valor_sexo        	DECIMAL(10,4),
		estado_civil    	VARCHAR(80),
		rango_estado_civil    	VARCHAR(80), --JMAH
		valor_estado_civil        	DECIMAL(10,4),
		tmpo_edo_civ_act    	VARCHAR(80),
		rango_tmpo_edo_civ_act    	VARCHAR(80),	 --JMAH
		valor_tmpo_edo_civ_act        	DECIMAL(10,4),
		tipo_residencia    	VARCHAR(80),
		rango_tipo_residencia 	VARCHAR(80),  --JMAH
		valor_tipo_residencia        	DECIMAL(10,4),
		tmpo_dom_act    	VARCHAR(80),
		rango_tmpo_dom_act	VARCHAR(80),  --JMAH
		valor_tmpo_dom_act        	DECIMAL(10,4),
		ocupacion    	VARCHAR(80),
		rango_ocupacion    	VARCHAR(80),  --JMAH
		valor_ocupacion        	DECIMAL(10,4),
		tmpo_ocup_act    	VARCHAR(80),
		rango_tmpo_ocup_act        	VARCHAR(80),  --JMAH
		valor_tmpo_ocup_act        	DECIMAL(10,4),
		tmpo_ocup_ant    	VARCHAR(80),
		rango_tmpo_ocup_ant    	VARCHAR(80),  --JMAH
		valor_tmpo_ocup_ant        	DECIMAL(10,4),
		edad    	VARCHAR(80),
		rango_edad    	VARCHAR(80),  --JMAH
		valor_edad        	DECIMAL(10,4),
		depend_econ   	VARCHAR(80),
		rango_depend_econ   	VARCHAR(80),  --JMAH
		valor_depend_econ       	DECIMAL(10,4),
	--	pregunta_11	VARCHAR(80), --JMAH
		--rango_pregunta_11	VARCHAR(80),  --JMAH
		--valor_pregunta_11	DECIMAL(5,2), --JMAH
		decl_imptos	VARCHAR(80), --JMAH
		valor_decl_imptos	DECIMAL(10,4), --JMAH
		seguro_popular   	VARCHAR(80),
		valor_seguro_popular       	DECIMAL(10,4),
		Ingreso_cte	VARCHAR(80), --JMAH
		rango_Ingreso_cte	VARCHAR(80),  --JMAH
		valor_Ingreso_cte	DECIMAL(10,4), --JMAH
		escolaridad   	VARCHAR(80) DEFAULT '',
		rango_escolaridad   	VARCHAR(80),  --JMAH
		valor_escolaridad       	DECIMAL(10,4) DEFAULT 0.00,
		hab_domic   	VARCHAR(80) DEFAULT '',
		rango_hab_domic	VARCHAR(80),  --JMAH
		valor_hab_domic       	DECIMAL(10,4) DEFAULT 0.00,		
		ant_plaza    	VARCHAR(80) DEFAULT '',--antiguedad plaza----JMAH
		rango_ant_plaza   	VARCHAR(80) DEFAULT '',--antiguedad plaza ----JMAH
		valor_ant_plaza       	DECIMAL(10,4) DEFAULT 0.00, --antiguedad plaza ----JMAH
		--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
		--pregunta18    	VARCHAR(80) DEFAULT '',
		BC_1   	VARCHAR(80) DEFAULT '',
		puntual_BC_1		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_1      	DECIMAL(10,4) DEFAULT 0.00,
		BC_101   	VARCHAR(80) DEFAULT '',
		puntual_BC_101		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_101       	DECIMAL(10,4) DEFAULT 0.00,
		BC_117   	VARCHAR(80) DEFAULT '',
		puntual_BC_117		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_117      	DECIMAL(10,4) DEFAULT 0.00,
		BC_119   	VARCHAR(80) DEFAULT '',
		puntual_BC_119		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_119      	DECIMAL(10,4) DEFAULT 0.00,
		BC_20   	VARCHAR(80) DEFAULT '',
		puntual_BC_20		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_20       	DECIMAL(10,4) DEFAULT 0.00,
		BC_421   	VARCHAR(80) DEFAULT '',
		puntual_BC_421		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_421       	DECIMAL(10,4) DEFAULT 0.00,
		BC_85   	VARCHAR(80) DEFAULT '',
		puntual_BC_85		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_85       	DECIMAL(10,4) DEFAULT 0.00,
		BC_93   	VARCHAR(80) DEFAULT '',
		puntual_BC_93		DECIMAL(10,4) DEFAULT 0.00,
		valor_BC_93       	DECIMAL(10,4) DEFAULT 0.00,
		calc_PCT_saldo_linea		VARCHAR(80) DEFAULT '',
		puntual_calc_PCT_saldo_linea		DECIMAL(10,4) DEFAULT 0.00,
		valor_calc_PCT_saldo_linea       	DECIMAL(10,4) DEFAULT 0.00,
		meses_historia   	VARCHAR(80) DEFAULT '',
		puntual_meses_historia		DECIMAL(10,4) DEFAULT 0.00,
		valor_meses_historia       	DECIMAL(10,4) DEFAULT 0.00,
		situacion_pago   	VARCHAR(80) DEFAULT '',
		puntual_situacion_pago		DECIMAL(10,4) DEFAULT 0.00,
		valor_situacion_pago       	DECIMAL(10,4) DEFAULT 0.00,
		ratio_saldo_credit_limit   	VARCHAR(80) DEFAULT '',
		puntual_ratio_saldo_credit_limit		DECIMAL(10,4) DEFAULT 0.00,
		valor_ratio_saldo_credit_limit      	DECIMAL(10,4) DEFAULT 0.00,
		--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
		seccion1      	DECIMAL(14,2),
		seccion2      	DECIMAL(14,2),
		sumascoring   	DECIMAL(14,2),
		causa           VARCHAR(255),----JMAH
		status       VARCHAR(255),----JMAH
		compromisos     DECIMAL(14,2),----JMAH
		fecha_apert     DATE,----JMAH
		lincred_recom     	DECIMAL(5,2) DEFAULT 0.00,
		Score_nhnc     	DECIMAL(5,2) DEFAULT 0.00,
		StatusAprobado			CHAR(30),	
		region			CHAR(40),
		rangoregion	CHAR(40),
		valorregion	CHAR(40),
		meses_ult_cons		CHAR(40),	
		rango_meses_ult_cons	CHAR(40),	
		valor_meses_ult_cons CHAR(40),	
		rango_edad_nhnc		CHAR(40),	
		valor_edad_nhnc	CHAR(40),	
		rango_resp_tmpedo_civil	CHAR(40),		
		valor_tmpedo_civil   CHAR(40),	
		rango_tipo_resid_nhnc 	CHAR(40),	
		valor_tipo_residencia_nhnc	CHAR(40),
		varrango_escolaridad_nhnc CHAR(40),
		varvalor_escolaridad_nhnc CHAR(40)
		);

	select fecha_hoy  into pfechacorte
	from bdicred:sd_fechas where empresa = '001';

	set isolation to dirty read;
	foreach with hold
        select nvl(trim(sol.num_solicitud),''),nvl(trim(sol.numcte),''),nvl(trim(sol.sucursal),''),nvl(trim(suc.nombre),''),
               nvl(trim(suc.telefono1),''),nvl(trim(suc.gerente),''),nvl(trim(cli.apell_paterno),''),nvl(trim(cli.apell_materno),''),
               nvl(trim(cli.nombre1),''),nvl(trim(cli.nombre2),''),nvl(trim(cli.numcte_ref),''),nvl(trim(cli.rfc),''),
               cte.fecha_nac,trim(sol.status_solicitud),sol.fecha_insert,trim(sol.num_producto),nvl(sol.monto_solicitado,0),
               nvl(res.situacion_pago,0),nvl(res.meses_historia,0),nvl(trim(sol.user_insert),''),nvl(trim(res.motivo_cc),''),
               nvl(res.saldoropa,0), nvl(res.saldomuebles,0), nvl(res.saldoprestamos,0), nvl(res.linea_tienda,0),case when dia_para_revisar is not null or dia_para_revisar <> '' then 'E84' else '' end,--cPrueba
               DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit'),
			   --case when evalua_cc = 'X' then 'NO HIT' else 'HIT' end,          --cFiltroC
               case when meses_historia >= 13 and situacion_pago >= 85 then 'I'
                    when meses_historia >= 6 and situacion_pago >= 85 then 'II'
               else 'III' end
        into chrnumsolicitud,chrnumcte,chrsucursal,chrnombresuc,
             chrtelsuc,chrnombregte,chrappaterno,chrapmaterno,
             chrnombre1,chrnombre2,chrnumctecoppel,chrrfc,
             dtefechanac,chrstatussol,dtefechasol,chrnumproducto,declincred,
             deceficponderada,intmeses,chrejecutivo,vchrrespuestacc,
             dSdoropa,dSdomuebles,dSdoprestamo,dSdolineatienda, cPrueba, cFiltroC,ctipoc
		from bdisolic:ss_solicitudes sol
        join bdinteg:si_cliente cli on(cli.numcte=sol.numcte)
        join bdisolic:ss_resum_scor_fin res on ( res.empresa=sol.empresa and res.num_solicitud=sol.num_solicitud and  res.grupo = '6')
        join bdinteg:si_ctepf cte on(cte.numcte=cli.numcte)
        join bdinteg:si_sucursales suc on(suc.sucursal=sol.sucursal and suc.empresa=sol.empresa)
        where sol.empresa='001' and cli.tpo_persona='01'  and sol.fecha_insert >= today - 120
		

        if (icontadorcommit = 0) then
         -- begin work;
        end if;
		LET varStatusAprobado = chrstatussol;
		----- jpc
		select trim(e.descripcion),
              (select descripcion from ss_status_sol where empresa='001' and status_solicitud = a.status_solicitud),
--            c.comentario , 
			b.fecha_apertura, 
			trunc((a.fecha_insert - cte.fecha_nac)/365,0) edad,  			           
			decode(f.fuente,'T','TIENDA','B','BANCO','','BANCO'),pago_minimo
				into v_causa, v_status, v_fecha_apert, v_edad,  v_fuente, v_compromisos	 
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

					select limit 1 correo_elec
					INTO v_email
					from bdinteg:si_correos
					where numcte = chrnumcte
					AND status_correo = 'A';
				
				select LIMIT 1 a.telefono, b.telefono ,d.telefono
				  into chrtelefono,v_tel_ofi, v_tel_cel
			  	  from bdinteg:si_telefonos_actual a
					   left outer join bdinteg:si_telefonos_actual b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 2 AND b.status_tel = 'A' and b.cofetel = 'V') 
					   left outer join bdinteg:si_telefonos_actual d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 3 AND d.status_tel = 'A' and d.cofetel = 'V') 
				where a.empresa = '001' 
				  and a.numcte = chrnumcte 
				  and a.tipo_tel = 1
				  AND a.status_tel = 'A' 
		          and a.cofetel = 'V' ;
				
				
        if v_causa is null then LET v_causa = ''; end if;    if v_status is null then LET v_status = ''; end if;    if v_fecha_apert is null then LET v_fecha_apert = ''; end if;
        if v_edad is null then LET v_edad = ''; end if;    if v_email is null then LET v_email = ''; end if;    if v_tel_ofi is null then LET v_tel_ofi = ''; end if;
        if v_tel_cel is null then LET v_tel_cel = ''; end if;    if v_fuente is null then LET v_fuente = ''; end if;    if v_compromisos is null then LET v_compromisos = 0; end if;

        --Obtiene la direccion del cliente(persona fisica)
        select nvl(trim(replace(dir.entre_calles,'|','')),''),nvl(trim(dir.cod_postal),''),nvl(trim(dir.numeroextcalle),''),
               nvl(trim(dir.numerointcalle),''),nvl(trim(cal.nombrecalle),''),nvl(trim(zon.nombrezona),''),
               nvl(trim(replace(dir.observaciones,'|','')),''),nvl(trim(edo.nombre),''),nvl(trim(ciu.nombre),''),
--JOM          nvl(zon.numerocobranzas,0)
               dir.numerociudad || '-' || trim(catciu.inicialciudad) Ciudad, -- Clave ciudad
               catciu.numeroestado || '-' || trim(catciu.inicialestado) Estado,-- Clave estado
			   reg.nombre_region
        into chrentrecalles,chrcodpostal,chrnumext,
             chrnumint,chrnombrecalle,chrnombrezona,
             chrobservaciones,chrestado,vchrciudad,
--JOM        intnumcobranza
             vchrclaciucobr, vchrclaedocobr,varregion
		from bdinteg:si_direcciones_actual dir
        left outer join bdinteg:si_catcalles cal on(cal.numerocalle=dir.numerocalle)
        left outer join bdinteg:si_catzonas zon on(zon.numerociudad=dir.numerociudad and zon.numerocolonia=dir.numerocolonia)
        left outer join bdinteg:si_estados edo on(edo.pais='001' and edo.estado=dir.estado)
        left outer join bdinteg:si_ciudades ciu on(ciu.pais=dir.pais and ciu.estado=dir.estado and ciu.ciudad=dir.ciudad)
        left outer join bdinteg:si_catciudades catciu on (dir.numerociudad = catciu.numerociudad)
		left outer join bdinteg:si_regiones reg on (reg.numero_region = catciu.numero_region  )
		where dir.numcte=chrnumcte and dir.tipo_dir='1';
 		
 
        --Obtiene la respuesta de la os y su fecha
        select nvl(trim(status),''),fecha_respuesta
		into chrrespuesta,dtefecharesp
		from bdisolic:ss_solicitud_os
		where empresa='001' and num_solicitud = chrnumsolicitud and
		fecha_solicitud =
		(
			select max(fecha_solicitud) from bdisolic:ss_solicitud_os
			where empresa='001' and num_solicitud = chrnumsolicitud and fecha_solicitud > date(0)
		);

        if chrrespuesta is null then
            LET chrrespuesta = '';
        end if;

		--Obtiene la situacion especial de la os y su causa
        select nvl(trim(situacionespecial),''),nvl(causasituacionespecial,0)
		into chrsitesp,intcausasitesp
		from bdisolic:ss_osclientesupervisar
		where empresa='001' and num_solicitud = chrnumsolicitud and
		fechasolicitud =
		(
			select max(fechasolicitud) from bdisolic:ss_osclientesupervisar
			where empresa='001' and num_solicitud = chrnumsolicitud and fechasolicitud > date(0)
		);

        if chrsitesp is not null and intcausasitesp is not null then
            --Obtiene la explicacion de la causa de la situacion especial del cliente
            if exists (select nvl(trim(descripcion),'') from bdicred:sd_causas_os
                where empresa = '001' and situacion = chrsitesp and causa = intcausasitesp) then

                select nvl(trim(descripcion),'') into chrdescsitesp from bdicred:sd_causas_os
                where empresa = '001' and situacion = chrsitesp and causa = intcausasitesp;
            else
                LET chrdescsitesp = '';
            end if;
        else
            LET intcausasitesp = 0;
            LET chrsitesp = '';
            LET chrdescsitesp = '';
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

        LET mnyingresosmb = round(nvl(mnyingreso,0)/intsmb);
		

		--Obtiene el detalle del scoring seccion 2
        LET vchrrespuesta1      ="";
        LET vchrrespuesta2      ="";
        LET vchrrespuesta3      ="";
        LET vchrrespuesta4      ="";
        LET vchrrespuesta5      ="";
        LET vchrrespuesta6      ="";
        LET vchrrespuesta7      ="";
        LET vchrrespuesta8      ="";
        LET vchrrespuesta9      ="";
        LET vchrrespuesta10     ="";
        LET vchrrespuesta13     ="";
        --PQ
        LET vchrrespuesta15     ="";
        --LET vchrpregunta16      ="";
        LET vchrrespuesta16     ="";
        LET vchrpregunta17      ="";
        LET vchrrespuesta17     ="";
        --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        LET vchrrespuesta18     ="";
        LET vchrrespuesta19     ="";
        LET vchrrespuesta20     ="";
        LET vchrrespuesta21     ="";
        LET vchrrespuesta22     ="";
        LET vchrrespuesta23     ="";
        LET vchrrespuesta24     ="";
        LET vchrrespuesta25     ="";
        LET vchrrespuesta26     ="";
        LET vchrrespuesta27     ="";
        LET vchrrespuesta28     ="";
        LET vchrrespuesta29     ="";
--MJPC Valores putuales
		LET varpuntual18         =0;
        LET varpuntual19         =0;
        LET varpuntual20         =0;
        LET varpuntual21         =0;
        LET varpuntual22         =0;
        LET varpuntual23         =0;
        LET varpuntual24         =0;
        LET varpuntual25         =0;
        LET varpuntual26         =0;
        LET varpuntual27         =0;
        LET varpuntual28         =0;
        LET varpuntual29         =0;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
        LET decvalor1           =0;
        LET decvalor2           =0;
        LET decvalor3           =0;
        LET decvalor4           =0;
        LET decvalor5           =0;
        LET decvalor6           =0;
        LET decvalor7           =0;
        LET decvalor8           =0;
        LET decvalor9           =0;
        LET decvalor10          =0;
        --LET decvalor11          =0;
        --LET decvalor12          =0;
        LET decvalor13          =0;
        --PQ
        --LET decvalor14         =0;
        LET decvalor15         =0;
        LET decvalor16         =0;
        LET decvalor17         =0;
        --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        LET decvalor18         =0;
        LET decvalor19         =0;
        LET decvalor20         =0;
        LET decvalor21         =0;
        LET decvalor22         =0;
        LET decvalor23         =0;
        LET decvalor24         =0;
        LET decvalor25         =0;
        LET decvalor26         =0;
        LET decvalor27         =0;
        LET decvalor28         =0;
        LET decvalor29         =0;
		
		LET varpuntuarespuesta2 ="";
		LET varpuntuarespuesta3 ="";
		LET varpuntuarespuesta4 ="";
		LET varpuntuarespuesta5 ="";
		LET varpuntuarespuesta6 ="";
		LET varpuntuarespuesta7 ="";
		LET varpuntuarespuesta8 ="";
		LET varpuntuarespuesta9 ="";
		LET varpuntuarespuesta10 ="";
		LET varpuntuarespuesta11 ="";
		LET varpuntuarespuesta13 ="";
		LET varpuntuarespuesta15 ="";
		LET varpuntuarespuesta16 ="";
		
		LET  vardecl_imptos ="";
		LET   varvalor_decl_imptos ="";
		LET  varIngreso_cte ="";
		LET  varrango_Ingreso_cte ="";
		LET  varvalor_Ingreso_cte ="";
		LET  varlincred ="";
		LET  varScore_nhnc ="";
		LET  varmeses_ult_cons ="";
		LET  varrango_meses_ult_cons ="";
		LET  varvalor_meses_ult_cons ="";
		LET  varrango_edad ="";
		LET  varvalor_edad ="";
		LET  varrango_resp_tmpedo_civil ="";
		LET  varvalor_tmpedo_civil =0;
		LET  varrango_tipo_resid ="";
		LET varvalor_tipo_residencia  ="";	
		let varrango_escolaridad_nhnc = '';
		let varvalor_escolaridad_nhnc = '';
		LET varregion ='';
		LET varrangoregion='';
		LET varvalorregion='';
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO

--Obtener la edad como valor puntual respuesta9
		select case when month(fecha_nac) < month(a.fecha_insert)
						then year(a.fecha_insert) - year(fecha_nac)
				else case when month(fecha_nac) = month(a.fecha_insert) and day(fecha_nac) <= day(a.fecha_insert) 
						then year(a.fecha_insert) - year(fecha_nac)
		    else year(a.fecha_insert) - year(fecha_nac) - 1 
				end 
		end edad
		into vchrrespuesta9
		from bdisolic:ss_solicitudes a
		inner join bdinteg:si_ctepf cte on(cte.empresa = a.empresa and cte.numcte=a.numcte)
		where a.empresa='001' and a.num_solicitud= chrnumsolicitud;
		
        LET intcontador        =0;
		foreach
		select variable,nvl(valor,0) 
		into vchsvariable,decvalor_punt 
		from bdisolic:ss_detalle_modelo where empresa = '001'
			   and num_solicitud = chrnumsolicitud 
			   
		if vchsvariable = 'BC_1' then
			LET varpuntual18 = decvalor_punt;
		elif vchsvariable = 'BC_101' then
			LET varpuntual19 = decvalor_punt;
		elif vchsvariable = 'BC_117' then
			LET varpuntual20 = decvalor_punt;
		elif vchsvariable = 'BC_119' then
			LET varpuntual21 = decvalor_punt;
		elif vchsvariable = 'BC_20' then
			LET varpuntual22 = decvalor_punt;
		elif vchsvariable = 'BC_421' then
			LET varpuntual23 = decvalor_punt;
		elif vchsvariable = 'BC_85' then
			LET varpuntual24 = decvalor_punt;
		elif vchsvariable = 'BC_93' then
			LET varpuntual25 = decvalor_punt;
		elif vchsvariable = 'CALC_PCT_SALDO_LIMIT' then
			LET varpuntual29 = decvalor_punt;
		elif vchsvariable = 'CALC_PCT_SALDO_LINEA' then
			LET varpuntual26 = decvalor_punt;
		elif vchsvariable = 'PMESESHIST' then
			LET varpuntual27 = decvalor_punt;
		elif vchsvariable = 'PSITUACIONPAGOCOPPEL' then
			LET varpuntual28 = decvalor_punt;
		end if;
		end foreach; 
		foreach--informacion actual con el nuevo parametrico
			select trim(a.descripcion),trim(c.descripcion),nvl(b.valor,0),a.grupo,c.elemento
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
			
	/*	select limit 1 peso_grupo6 into vpeso_grupo 
		from elemento
		where grupo = intgrupo and elemento = intelemento;
		
		select max(elemento) into velemento_final
		from elemento
		where grupo = intgrupo and peso_grupo6 = vpeso_grupo;
	*/	
		select limit 1 rango_riesgos into velemento_final 
		from elemento
		where grupo = intgrupo and elemento = intelemento;
		
			if intgrupo = 2 then--sexo				
				LET vchrrespuesta1 = vchrrespuesta;
				LET decvalor1 = decvalor;
			elif intgrupo = 3 then--Estado Civil
                LET intelementoaux = intelemento;
                LET intgrupoaux = intgrupo;
				--LET vchrrespuesta2 = vchrpregunta;
				LET vchrrespuesta2 = vchrrespuesta;
				--LET varpuntuarespuesta2 = vchrrespuesta;
				LET varpuntuarespuesta2 = velemento_final;				LET decvalor2 = decvalor;	
			elif intgrupo = 4 then--tiempo Estado Civil
            --    LET vchrrespuesta3 = vchrpregunta ;
				LET vchrrespuesta3 = vchrrespuesta ;
				--LET varrango_resp_tmpedo_civil = vchrrespuesta;
				LET varrango_resp_tmpedo_civil = velemento_final;                LET varvalor_tmpedo_civil = decvalor;
				LET intelementoaux2 = intelemento;
			elif intgrupo = 5 then--Tipo de Residencia
			--	LET vchrrespuesta4 = vchrpregunta;
				LET vchrrespuesta4 = vchrrespuesta;
				--LET varrango_tipo_resid = vchrrespuesta;
				LET varrango_tipo_resid = velemento_final;				LET varvalor_tipo_residencia = decvalor;
			elif intgrupo = 6 then----tiempo residencia
			--	LET vchrrespuesta5 = vchrpregunta;
				LET vchrrespuesta5 = vchrrespuesta;
			--		LET varpuntuarespuesta5 = vchrrespuesta;
				LET varpuntuarespuesta5 = velemento_final; ---fmj valida el tamaÃ±o los aÃ±os.
				let varpuntuarespuesta5 = substr(varpuntuarespuesta5,1,7 );
				LET decvalor5 = decvalor;
			elif intgrupo = 7 then--Ocupacion
			--	LET vchrrespuesta6 = vchrpregunta;
				LET vchrrespuesta6 = vchrrespuesta;
				--LET varpuntuarespuesta6 = vchrrespuesta;-------------------------------------rango_ocupacion
				LET varpuntuarespuesta6 = velemento_final;
				LET decvalor6 = decvalor;
			/*elif intgrupo = 8 then--Â¿CuÃ¡nto tiempo tiene trabajando en su empleo actual? (aÃ±os)
               -- LET intelementoaux = intelemento;
                LET intgrupoaux = intgrupo;
				LET varpuntuarespuesta7 = vchrrespuesta;
				LET vchrrespuesta7 = vchrpregunta;
				LET decvalor7 = decvalor;*/
			elif intgrupo = 9 then--Â¿CuÃ¡nto tiempo estuvo trabajando en su empleo anterior? (aÃ±os)
            --    LET vchrrespuesta8 = vchrpregunta;
				LET vchrrespuesta8 = vchrrespuesta;
			--	LET varpuntuarespuesta8 = vchrrespuesta;--------------------------------rango_tmpo_ocup_ant
				LET varpuntuarespuesta8 = velemento_final;
                LET decvalor8 = decvalor;
            elif intgrupo = 10 then --edad
				LET varvalor_edad = decvalor;
				--LET varrango_edad = vchrrespuesta;
				LET varrango_edad = velemento_final;			elif intgrupo = 11 then--Dependientes Economicos
			--	LET vchrrespuesta10 = vchrpregunta;
				LET vchrrespuesta10 = vchrrespuesta;
				--LET varpuntuarespuesta10 = vchrrespuesta;-----------------------------rango_depend_econ
				LET varpuntuarespuesta10 = velemento_final;
				LET decvalor10 = decvalor;
			--PQ
			elif intgrupo = 16 then--Seguro Popular (Comprobante)
				LET vchrrespuesta13 = vchrpregunta;
				LET varpuntuarespuesta13 = vchrrespuesta;
				LET decvalor13 = decvalor;
			elif intgrupo = 20  then--Ingreso del Cliente
				LET varIngreso_cte = vchrpregunta;
				--LET varrango_Ingreso_cte = vchrrespuesta;-----------------------------------------------
				LET varrango_Ingreso_cte = velemento_final;
				LET varvalor_Ingreso_cte = decvalor;
            --PQ
			elif intgrupo = 21  then--Escolaridad
			--	LET vchrrespuesta15 = vchrpregunta;
				LET vchrrespuesta15 = vchrrespuesta;
				--LET varpuntuarespuesta15 = vchrrespuesta;------------------------------rango_escolaridad
				LET varpuntuarespuesta15 = velemento_final;
				LET decvalor15 = decvalor;
			elif intgrupo = 22  then--Habitantes en el domicilio
			--	LET vchrrespuesta16 = vchrpregunta;
				LET vchrrespuesta16 = vchrrespuesta;
			--	LET varpuntuarespuesta16 = vchrrespuesta;------------------------------rango_hab_domic
				LET varpuntuarespuesta16 = velemento_final;
				LET decvalor16 = decvalor;
			elif intgrupo = 23  then --Antiguedad de la Plaza + Nivel de vencido
				LET vchrpregunta17 = vchrpregunta;
				LET vchrrespuesta17 = vchrrespuesta;				LET vchrrespuesta17 = velemento_final;
				LET decvalor17 = decvalor;
            --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
			elif intgrupo = 26  then--BC_1 Edad de la Cuenta mÃ¡s Vieja.
				LET vchrrespuesta18 = vchrrespuesta;
				LET decvalor18 = decvalor;
			elif intgrupo = 27  then--BC_101 Peor MOP HistÃ³rico (Bancario)
				LET vchrrespuesta19 = vchrrespuesta;
				LET decvalor19 = decvalor;
			elif intgrupo = 28  then--BC_117 NÃºmero de Cuentas HistÃ³rico 30 + DPD (Revolvente Bancaria)
				LET vchrrespuesta20 = vchrrespuesta;
				LET decvalor20 = decvalor;
			elif intgrupo = 29  then--BC_119 NÃºmero de Cuentas HistÃ³rico 60+ DPD (No Celulares y No Servicios)
				LET vchrrespuesta21 = vchrrespuesta;
				LET decvalor21 = decvalor;
			elif intgrupo = 30  then--BC_20 NÃºmero de Cuentas Abiertas en los Ãltimos 12 meses (No Celulares y No Serv
				LET vchrrespuesta22 = vchrrespuesta;
				LET decvalor22 = decvalor;
			elif intgrupo = 31  then--BC_421 Meses desde la Ãltima Solicitud de InformaciÃ³n
				LET vchrrespuesta23 = vchrrespuesta;
				LET decvalor23 = decvalor;
			elif intgrupo = 32  then--BC_85 Peor MOP en los Ãltimos 12 meses (No Bancarios Revolventes)
				LET vchrrespuesta24 = vchrrespuesta;
				LET decvalor24 = decvalor;
			elif intgrupo = 33  then--BC_93 Peor MOP
				LET vchrrespuesta25 = vchrrespuesta;
				LET decvalor25 = decvalor;
			elif intgrupo = 34  then--CALC_PCT_SALDO_LINEA Calculo Porcentaje Saldo LÃ­nea
				LET vchrrespuesta26 = vchrrespuesta;
				LET decvalor26 = decvalor;
			elif intgrupo = 35  then--Meses de Historia en Tienda (MESES_HISTORIA)
				LET vchrrespuesta27 = vchrrespuesta;
				LET decvalor27 = decvalor;
			elif intgrupo = 36  then--SituaciÃ³n de Pago (SITUACION_PAGO)
				LET vchrrespuesta28 = vchrrespuesta;
				LET decvalor28 = decvalor;
			elif intgrupo = 37  then--Ratio of Saldo to Credit Limit (CALC_PCT_SALDO_LIMIT)
				LET vchrrespuesta29 = vchrrespuesta;
				LET decvalor29 = decvalor;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
			elif intgrupo = 43  then--Meses Ultima Consulta Buro IQ
				LET varmeses_ult_cons =vchrrespuesta;
				LET varrango_meses_ult_cons=intelemento;				LET varrango_meses_ult_cons=velemento_final;
				LET varvalor_meses_ult_cons=decvalor;	
			elif intgrupo = 41  AND intelementoaux = 6 AND (intelementoaux2 in (0,5)) then --tiempo Meses Estado Civil               					   												
				
				LET varrango_resp_tmpedo_civil = "Menor a un aÃ±o" ;	
                LET varvalor_tmpedo_civil = decvalor;								
            elif intgrupo = 42  then--Region cobranza				
				LET varregion =vchrrespuesta;
				--LET varrangoregion=intelemento;
				LET varrangoregion=velemento_final;
				LET varvalorregion=decvalor;
			end if;
			
		end foreach;
               LET iBandera =0;	
		LET decvalor3 =0;
		foreach--informacion actual con el nuevo parametrico
			select trim(a.descripcion),trim(c.descripcion),nvl(b.valor,0),a.grupo,c.elemento
			into vchrpregunta,vchrrespuesta,decvalor,intgrupo,intelemento
			from ss_scoring_grupo a, ss_detalle_scoring_rechazo b, ss_scoring_element c
            where a.empresa = '001' and a.seccion = 2
			and b.num_solicitud = chrnumsolicitud
			and b.tpo_persona = '01'
			and a.empresa = b.empresa
            and a.grupo <> 25 --JCP Grupo OS Telefonica
			and a.grupo in (4,5,10,21,41)
			and a.grupo = b.grupo
			and a.grupo = c.grupo
			and a.seccion = b.seccion
			and a.seccion = c.seccion
			and b.elemento = c.elemento
			and b.tpo_persona = c.tpo_persona
			order by b.seccion, b.grupo, b.elemento
		/*
			select limit 1 peso_grupo6 into vpeso_grupo 
			from elemento
			where grupo = intgrupo and elemento = intelemento;
		
			select max(elemento) into velemento_final
			from elemento
			where grupo = intgrupo and peso_grupo6 = vpeso_grupo;
		*/	
			select limit 1 rango_riesgos into velemento_final 
			from elemento
			where grupo = intgrupo and elemento = intelemento;
			
			if intgrupo  = 4 then--tiempo Estado Civil
            --    LET varpuntuarespuesta3 = vchrrespuesta;---------------------------------------rango_tmpo_edo_civ_act
				LET varpuntuarespuesta3 = velemento_final;
				LET decvalor3 = decvalor;
				LET iBandera = 1;
			elif intgrupo = 5 then--Tipo de Residencia
			--	LET varpuntuarespuesta4 = vchrrespuesta;
			LET varpuntuarespuesta4 = velemento_final;				LET decvalor4 = decvalor;
			elif intgrupo = 10 then----edad
			--	LET varpuntuarespuesta9 = vchrrespuesta;-----------------------------------rango_edad
				LET varpuntuarespuesta9 = velemento_final;
				LET decvalor9 = decvalor;		
			elif intgrupo = 10 then----escolaridad
				--LET varrango_escolaridad_nhnc = vchrrespuesta;
				LET varrango_escolaridad_nhnc = velemento_final;				LET varvalor_escolaridad_nhnc = decvalor;
            elif intgrupo = 8 then--Â¿CuÃ¡nto tiempo tiene trabajando en su empleo actual? (aÃ±os)               
                LET intgrupoaux = intgrupo;
				--LET varpuntuarespuesta7 = vchrrespuesta;--------------------------------rango_tmpo_ocup_act
				LET varpuntuarespuesta7 = velemento_final;
				LET vchrrespuesta7 = vchrpregunta;
				LET decvalor7 = decvalor;				
			elif intgrupo  = 41 AND intelementoaux = 6 AND (intelementoaux2 in (0,5))  then--tiempo Estado Civil en caso de que sea casado y tenga la respuesta de menor a un aÃ±o 
					IF intelementoaux = 6  THEN 
						LET vchrrespuesta = "Menor a un aÃ±o" ;				
				    END IF	
				--LET varpuntuarespuesta3 = vchrrespuesta;----------------------------------------------rango_tmpo_edo_civ_act
				LET varpuntuarespuesta3 = velemento_final;
				LET decvalor3 = decvalor;
			end if;			
		end foreach;
		LET intelementoaux2=0;
		LET intelementoaux = 0;
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
				               
				/*IF iCantidad = 2 THEN
                        LET decseccion1= dEvaluacion1;
                        LET decseccion2= dEvaluacion2;
                       -- LET decsuma= dSuma; --suma modelo grupo6
						LET varScore_nhnc = dSuma;
                ELSE
                        --Obtiene el total del scoring de la seccion 2      
                        LET decseccion2 = decvalor1 + decvalor2 + decvalor3 + decvalor4 + decvalor5 + decvalor6 + decvalor7 +
                                          decvalor8 + decvalor9 + decvalor10 + decvalor13 +
                                          decvalor15 +  decvalor16 + decvalor17;
                        
                        LET decseccion1 = dEvaluacion2 - decseccion2;
                        --Obtiene el total del scoring del cliente
                        LET varScore_nhnc = decode(decseccion1,-1,0,decseccion1) + decseccion2;

                 END IF;
				 --valor original de seccion 2
				 SELECT SUM(valor) INTO dEvaluacion2 FROM bdisolic:ss_detalle_scoring where num_solicitud = chrnumsolicitud;
				 LET decsuma = dEvaluacion1+dEvaluacion2;*/
				 IF iCantidad = 2 THEN
                        LET decseccion1= dEvaluacion1;
                        LET decsuma= dEvaluacion2;
                       -- LET decsuma= dSuma; --suma modelo grupo6
						LET varScore_nhnc = dSuma;
                ELSE
                        --Obtiene el total del scoring de la seccion 2      
                        LET decsuma = decvalor1 + decvalor2 + decvalor3 + decvalor4 + decvalor5 + decvalor6 + decvalor7 +
                                          decvalor8 + decvalor9 + decvalor10 + decvalor13 +
                                          decvalor15 +  decvalor16 + decvalor17;
                        
                        LET decseccion1 = dEvaluacion2 - decsuma;
                        --Obtiene el total del scoring del cliente
                        LET varScore_nhnc = decode(decseccion1,-1,0,decseccion1) + decsuma;

                 END IF;
				 --valor original de seccion 2
				 SELECT SUM(valor) INTO dEvaluacion2 FROM bdisolic:ss_detalle_scoring_rechazo where num_solicitud = chrnumsolicitud;
				 LET decseccion2 = decode(dEvaluacion1,-1,0,dEvaluacion1)+dEvaluacion2;
                 --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        select first 1 nvl(sc01,'')
          into cbcscore
          from bdiburo:br_sc
         where num_cliente = chrnumcte;
	
		--Inserta en ss_riesgos_os para consulta del area de Riesgos        
		

		INSERT INTO "informix".ss_riesgos_grupo6 
	   (numsolicitud,numcte, numctecoppel ,sucursal,nombresuc , telsuc,nombregte,appaterno , apmaterno,nombre1, nombre2,rfc,fechanac,
	   calle,numext, numint,colonia,claciucobr , claedocobr,codpostal,entrecalles,telefono,estado,localidad,observaciones,
	   statussol,fechasol, numproducto,respuesta,  fecharesp,ejecutivo,ingresomensual,ingresosmb,lincred,eficponderada,meses,sitesp,causasitesp,descsitesp,
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        tipocliente,filtrocliente,saldoropa,saldomuebles,saldoprestamo,lineatienda,bcscore,prueba,
		respuestacc,sexo,valor_sexo,
		estado_civil,rango_estado_civil,valor_estado_civil,
		tmpo_edo_civ_act,rango_tmpo_edo_civ_act,valor_tmpo_edo_civ_act,
		tipo_residencia,rango_tipo_residencia,valor_tipo_residencia,
		tmpo_dom_act,rango_tmpo_dom_act,valor_tmpo_dom_act,
		ocupacion,rango_ocupacion,valor_ocupacion,
		tmpo_ocup_act,rango_tmpo_ocup_act, valor_tmpo_ocup_act,
		tmpo_ocup_ant,rango_tmpo_ocup_ant,valor_tmpo_ocup_ant,
		edad,rango_edad,valor_edad,
		depend_econ,rango_depend_econ,valor_depend_econ,
		--pregunta_11,rango_pregunta_11,valor_pregunta_11,
		decl_imptos,valor_decl_imptos,
		seguro_popular,valor_seguro_popular,
		Ingreso_cte,rango_Ingreso_cte,valor_Ingreso_cte,
		escolaridad,rango_escolaridad,valor_escolaridad,
		hab_domic,rango_hab_domic,valor_hab_domic,
		ant_plaza,rango_ant_plaza,valor_ant_plaza,
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        BC_1,puntual_BC_1,valor_BC_1,
		BC_101,puntual_BC_101,valor_BC_101,
		BC_117,puntual_BC_117,valor_BC_117,
		BC_119,puntual_BC_119,valor_BC_119,
		BC_20,puntual_BC_20, valor_BC_20,
		BC_421,puntual_BC_421,valor_BC_421,
		BC_85,puntual_BC_85, valor_BC_85,
		BC_93,puntual_BC_93,valor_BC_93,
		calc_PCT_saldo_linea,puntual_calc_PCT_saldo_linea,valor_calc_PCT_saldo_linea,
		meses_historia,puntual_meses_historia,valor_meses_historia,
		situacion_pago  , 	puntual_situacion_pago,valor_situacion_pago,
		ratio_saldo_credit_limit,puntual_ratio_saldo_credit_limit,valor_ratio_saldo_credit_limit ,  	
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
        seccion1,seccion2,sumascoring,causa,status,compromisos,fecha_apert,
		lincred_recom, Score_nhnc,StatusAprobado,
		region,	rangoregion	,valorregion,
		meses_ult_cons,rango_meses_ult_cons,valor_meses_ult_cons,
		rango_edad_nhnc,valor_edad_nhnc,
		rango_resp_tmpedo_civil,valor_tmpedo_civil,
		rango_tipo_resid_nhnc  ,valor_tipo_residencia_nhnc,
		varrango_escolaridad_nhnc ,	varvalor_escolaridad_nhnc )
		VALUES(
		chrnumsolicitud,chrnumcte,chrnumctecoppel,chrsucursal,chrnombresuc,chrtelsuc,chrnombregte,chrappaterno,chrapmaterno,chrnombre1,chrnombre2,chrrfc,dtefechanac,
		chrnombrecalle,chrnumext,chrnumint,chrnombrezona,vchrclaciucobr,vchrclaedocobr,chrcodpostal,chrentrecalles,chrtelefono,chrestado,vchrciudad,chrobservaciones,
		chrstatussol,dtefechasol,chrnumproducto,chrrespuesta,dtefecharesp,chrejecutivo,mnyingreso,mnyingresosmb,declincred,deceficponderada,intmeses,chrsitesp,intcausasitesp,chrdescsitesp,
		--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
		ctipoc,cFiltroC,dSdoropa,dSdomuebles,dSdoprestamo,dSdolineatienda,cbcscore,cPrueba,		
		vchrrespuestacc,vchrrespuesta1,decvalor1,--sexo
		vchrrespuesta2,varpuntuarespuesta2,decvalor2,--estado_civil
		vchrrespuesta3,varpuntuarespuesta3 ,decvalor3,--tmpo_edo_civ_act 
		vchrrespuesta4,varpuntuarespuesta4,decvalor4,--tipo_residencia
		vchrrespuesta5,varpuntuarespuesta5,decvalor5,--tmpo_dom_act
		vchrrespuesta6,varpuntuarespuesta6,decvalor6,--ocupacion
		vchrrespuesta7,varpuntuarespuesta7,decvalor7,--tmpo_ocup_act
		vchrrespuesta8,varpuntuarespuesta8,decvalor8,--tmpo_ocup_ant
		vchrrespuesta9,varpuntuarespuesta9,decvalor9,--edad --falta rango y valor del primer modelo
		vchrrespuesta10,varpuntuarespuesta10,decvalor10,--depend_econ
		--vchrrespuesta11,varpuntuarespuesta11,decvalor11,--pregunta 11-la misma?
		vardecl_imptos,varvalor_decl_imptos,--declaracion de impuestos
		varpuntuarespuesta13,decvalor13,--valor_seguro_popular
		varIngreso_cte,varrango_Ingreso_cte,varvalor_Ingreso_cte,--ingreso del cliente
		vchrrespuesta15,varpuntuarespuesta15,decvalor15,--escolaridad
		vchrrespuesta16,varpuntuarespuesta16,decvalor16,--hab_domic
		vchrpregunta17,vchrrespuesta17,decvalor17, --pregunta17
		--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
		vchrrespuesta18,varpuntual18,decvalor18,--BC_1
		vchrrespuesta19,varpuntual19,decvalor19,--BC_101
		vchrrespuesta20,varpuntual20,decvalor20, --BC_117
		vchrrespuesta21,varpuntual21,decvalor21,--BC_119
		vchrrespuesta22,varpuntual22,decvalor22,--BC_20
		vchrrespuesta23,varpuntual23,decvalor23, --BC_421
		vchrrespuesta24,varpuntual24,decvalor24,--BC_85
		vchrrespuesta25,varpuntual25,decvalor25,--BC_93
		vchrrespuesta26,varpuntual26,decvalor26, --calc_PCT_saldo_linea
		vchrrespuesta27,varpuntual27,decvalor27,--meses_historia
		vchrrespuesta28,varpuntual28,decvalor28,--situacion_pago
		vchrrespuesta29,varpuntual29,decvalor29, --ratio_saldo_credit_limit
		--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
		decseccion1,decseccion2,decsuma,v_causa, v_status,v_compromisos,v_fecha_apert,
		varlincred,varScore_nhnc,varStatusAprobado,--faltan
		varregion, varrangoregion, varvalorregion,
		varmeses_ult_cons,varrango_meses_ult_cons,varvalor_meses_ult_cons,
		varrango_edad,varvalor_edad,--faltan
		varrango_resp_tmpedo_civil,varvalor_tmpedo_civil,--faltan
		varrango_tipo_resid ,varvalor_tipo_residencia,--faltan
		varrango_escolaridad_nhnc ,varvalor_escolaridad_nhnc
		);
                LET icontadorcommit = icontadorcommit + 1;

                if (icontadorcommit >= 70000) then
                   --commit work;
                   LET icontadorcommit = 0;
                   update statistics medium for table "informix".ss_riesgos_grupo6;
                end if;
	
	end foreach;

    if ( icontadorcommit > 0) then
        --commit work;
    end if;
   
---------------------------------------GENERAR ARCHIVO------------------------------------------------------------------
	
	--LET cruta = '/informix/fmartinez_2/';
	LET cnombre = 'rep_demografica_grupo6_';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pfechacorte,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.txt';
---encabezados
	LET cSql='';
	LET csql = 'echo "numsolicitud'||'|'||'numcte'||'|'||'numctecoppel'||'|'||'sucursal'||'|'||'nombresuc'||'|'||
			'telsuc'||'|'||'nombregte'||'|'||'appaterno'||'|'||'apmaterno'||'|'||
			'nombre1'||'|'||'nombre2'||'|'||'rfc'||'|'||'fechanac'||'|'||'calle'||'|'||'numext'||'|'||
			'numint'||'|'||'colonia'||'|'||'claciucobr'||'|'||'claedocobr'||'|'||				 
			'codpostal'||'|'||'entrecalles'||'|'||'telefono'||'|'||'estado'||'|'||'localidad'||'|'||'observaciones'||'|'||
			'statussol'||'|'||'fechasol'||'|'||'numproducto'||'|'||'respuesta'||'|'||
			'fecharesp'||'|'||'ejecutivo'||'|'||'ingresomensual'||'|'||'ingresosmb'||'|'||'lincred'||'|'||'eficponderada'||'|'||
			'meses'||'|'||'sitesp'||'|'||'causasitesp'||'|'||'descsitesp'||'|'||
			'tipocliente'||'|'||'filtrocliente'||'|'||'saldoropa'||'|'||'saldomuebles'||'|'||'saldoprestamo'||'|'||'lineatienda'||'|'||
			'bcscore'||'|'||'prueba'||'|'||'respuestacc'||'|'||'sexo'||'|'||
			'valor_sexo'||'|'||'estado_civil'||'|'||'rango_estado_civil'||'|'||'valor_estado_civil'||'|'||'tmpo_edo_civ_act'||'|'||'rango_tmpo_edo_civ_act'||'|'||
			'valor_tmpo_edo_civ_act'||'|'||'tipo_residencia'||'|'||'rango_tipo_residencia'||'|'||'valor_tipo_residencia'||'|'||
			'tmpo_dom_act'||'|'||'rango_tmpo_dom_act'||'|'||'valor_tmpo_dom_act'||'|'||'ocupacion'||'|'||'rango_ocupacion'||'|'||'valor_ocupacion'||'|'||
			'tmpo_ocup_act'||'|'||'rango_tmpo_ocup_act'||'|'||'valor_tmpo_ocup_act'||'|'||'tmpo_ocup_ant'||'|'||				 
			'rango_tmpo_ocup_ant'||'|'||'valor_tmpo_ocup_ant'||'|'||'edad'||'|'||'rango_edad'||'|'||'valor_edad'||'|'||'depend_econ'||'|'||
			'rango_depend_econ'||'|'||'valor_depend_econ'||'|'||
			'decl_imptos'||'|'||'valor_decl_imptos'||'|'||'seguro_popular'||'|'||'valor_seguro_popular'||'|'||'Ingreso_cte'||'|'||
			'rango_Ingreso_cte'||'|'||'valor_Ingreso_cte'||'|'||'escolaridad'||'|'||'rango_escolaridad'||'|'||
			'valor_escolaridad'||'|'||'hab_domic'||'|'||'rango_hab_domic'||'|'||'valor_hab_domic'||'|'||
			'ant_plaza'||'|'||'rango_ant_plaza'||'|'||'valor_ant_plaza'||'|'||
			'BC_1'||'|'||'puntual_BC_1'||'|'||'valor_BC_1'||'|'||'BC_101'||'|'||'puntual_BC_101'||'|'||'valor_BC_101'||'|'||
			'BC_117'||'|'||'puntual_BC_117'||'|'||'valor_BC_117'||'|'||'BC_119'||'|'||'puntual_BC_119'||'|'||'valor_BC_119'||'|'||
			'BC_20'||'|'||'puntual_BC_20'||'|'||'valor_BC_20'||'|'||'BC_421'||'|'||'puntual_BC_421'||'|'||'valor_BC_421'||'|'||
			'BC_85'||'|'||'puntual_BC_85'||'|'||'valor_BC_85'||'|'||'BC_93'||'|'||'puntual_BC_93'||'|'||'valor_BC_93'||'|'||				
			'calc_PCT_saldo_linea'||'|'||'puntual_calc_PCT_saldo_linea'||'|'||'valor_calc_PCT_saldo_linea'||'|'||
			'meses_historia'||'|'||'puntual_meses_historia'||'|'||'valor_meses_historia'||'|'||
			'situacion_pago'||'|'||'puntual_situacion_pago'||'|'||'valor_situacion_pago'||'|'||
			'ratio_saldo_credit_limit'||'|'||'puntual_ratio_saldo_credit_limit'||'|'||'valor_ratio_saldo_credit_limit'||'|'||
			'seccion1'||'|'||'seccion2'||'|'||'sumascoring'||'|'||'causa'||'|'||'status'||'|'||'compromisos'||'|'||
			'fecha_apert'||'|'||'lincred_recom'||'|'||'Score_nhnc'||'|'||'StatusAprobado'||'|'||'region'||'|'||'rangoregion'||'|'||'valorregion'||'|'||
			'meses_ult_cons'||'|'||
			'rango_meses_ult_cons'||'|'||'valor_meses_ult_cons'||'|'||'rango_edad_nhnc'||'|'||'valor_edad_nhnc'||'|'||'rango_resp_tmpedo_civil'||'|'||'valor_tmpedo_civil'||'|'||
			'rango_tipo_resid_nhnc'||'|'||'valor_tipo_residencia_nhnc'||'|'||'varrango_escolaridad_nhnc'||'|'||'varvalor_escolaridad_nhnc'||'|'||				
			'" >'||TRIM(cruta)|| cnomarchivo;		 	
			
		SYSTEM csql;

	
	LET cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = " select * from bdisolic:ss_riesgos_grupo6 ";
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_demografica.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_demografica.sql';
    System cSQL;

    LET cSQL = 'dbaccess bdisolic ' || TRIM(cRuta) || 'Ejecuta_demografica.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	
	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_demografica.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;  

	--DROP TABLE "informix".ss_riesgos_grupo6;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03')RETURNING cCod_ret;
	
--	commit work;

return chrcodret,chrmensaje;
end;

end procedure;