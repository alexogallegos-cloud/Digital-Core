CREATE PROCEDURE "informix".ins_consulta_buro2_apolo(pempresa CHAR(3),psucursal CHAR(3), pusuario CHAR(8), pInstitucion CHAR(2),pnum_solicitud VARCHAR(25))
RETURNING	CHAR(6);

--Declaraciones   Generales
DEFINE inicio,item_cadena,item_valor,etiq_size,tamamax,tamres,tamfin,long_etiq INT;
DEFINE etiqueta CHAR(4);
DEFINE valor_cadena lvarchar;
DEFINE sql_err,i,j,flag INT;
DEFINE paso VARCHAR(30);
DEFINE fecha DATE;
DEFINE cod_ret CHAR(6);
DEFINE pnum_cliente VARCHAR(25);  --IPCB autenticador
DEFINE vhora datetime HOUR TO fraction(3);
DEFINE csolicitud   CHAR (20);
DEFINE iconsulta    SMALLINT; 
DEFINE cOrigenSol   CHAR (1); 
--Deficicion tabla br_pn
DEFINE pnpn,pn00,pn01,pn02,pn03,pn04 VARCHAR(26);
DEFINE pn05 VARCHAR(13); DEFINE pn06,pn07 VARCHAR(4); DEFINE pn08,pn16,pn17 CHAR(2);
DEFINE pn09,pn11,pn12 CHAR(1); DEFINE pn10,pn13,pn14,pn15 VARCHAR(20); DEFINE pn18 VARCHAR(30);
DEFINE pn19,pn20 VARCHAR(8);
--Deficicion tabla br_pa
DEFINE papa,pa00,pa01,pa02,pa03 VARCHAR(40); DEFINE pa04 VARCHAR(4);
DEFINE pa05 CHAR(5); DEFINE pa06,pa08,pa12 CHAR(8); DEFINE pa07,pa09 VARCHAR(11);
DEFINE pa10,pa11 CHAR(1);
DEFINE pacodpais VARCHAR(20);
--Campo para respaldar valor cuando hay mas de una incidencia de un concepto
DEFINE respalda_papa VARCHAR(40);
--Deficicion tabla br_pe
DEFINE pepe,pe00,pe01,pe02,pe03,pe04 VARCHAR(40); DEFINE pe05 VARCHAR(4);
DEFINE pe06 CHAR(5); DEFINE pe07,pe09 VARCHAR(11); DEFINE pe08 VARCHAR(8);
DEFINE pe10 VARCHAR(30); DEFINE pe11 CHAR(8); DEFINE pe12 CHAR(2); DEFINE pe13 VARCHAR(9);
DEFINE pe14 VARCHAR(1); DEFINE pe15 VARCHAR(15); DEFINE pe16,pe17,pe18 CHAR(8);
DEFINE pe19 CHAR(1);
DEFINE pecodpais VARCHAR(20);
--Campo para respaldar valor cuando hay mas de una incidencia de un concepto
DEFINE respalda_pepe VARCHAR(40);
--Deficicion tabla br_tl
DEFINE tltl CHAR(8); DEFINE tl00 CHAR(4); DEFINE tl01 CHAR(10); DEFINE tl02 VARCHAR(16);
DEFINE tl03 VARCHAR(11); DEFINE tl04 VARCHAR(25); DEFINE tl05,tl06,tl11,tl18 CHAR(1);
DEFINE tl07,tl08 CHAR(2); DEFINE tl09,tl12 VARCHAR(9); DEFINE tl10 VARCHAR(4);
DEFINE tl13,tl14,tl15,tl16,tl17,tl19 CHAR(8); DEFINE tl20 VARCHAR(40);
DEFINE tl21,tl22,tl23,tl24 VARCHAR(9); DEFINE tl25 VARCHAR(4);
DEFINE tl26 CHAR(2); DEFINE tl27 VARCHAR(24);
DEFINE tl28,tl29 CHAR(8); DEFINE tl30 CHAR(2);
DEFINE tl31 CHAR(3); DEFINE tl32,tl33,tl34 CHAR(2);
DEFINE tl35 CHAR(2); DEFINE tl36 VARCHAR(9);
DEFINE tl37 CHAR(8); DEFINE tl38 CHAR(2);
DEFINE tl42 CHAR(8);
DEFINE tl45 VARCHAR(9);
--Campo para respaldar valor cuando hay mas de una incidencia de un concepto
DEFINE respalda_tltl CHAR(8);
--Deficicion tabla br_iq
DEFINE iqiq  CHAR(8);  DEFINE iq00 CHAR(4); DEFINE iq01 CHAR(10); DEFINE iq02 VARCHAR(16);
DEFINE iq03 VARCHAR(11); DEFINE iq04,iq05 CHAR(2); DEFINE iq06 VARCHAR(9);
DEFINE iq07,iq08 CHAR(1); DEFINE iq09 VARCHAR(25);
--Campo para respaldar valor cuando hay mas de una incidencia de un concepto
DEFINE respalda_iqiq CHAR(8); DEFINE entro CHAR(1);
--Deficicion tabla br_rs
DEFINE rsrs CHAR(8);
DEFINE rs00,rs01,rs02,rs03,rs04,rs05,rs06,rs07,rs08 CHAR(2);
DEFINE rs09,rs10,rs11,rs12,rs13,rs14 CHAR(4);
DEFINE rs15,rs16 CHAR(2); DEFINE rs17 CHAR(1);  DEFINE rs18 CHAR(8); DEFINE rs19 CHAR(1);
DEFINE rs20 CHAR(2);
DEFINE rs21,rs22,rs24,rs25,rs27,rs29,rs30 VARCHAR(9);
DEFINE rs23 VARCHAR(10); DEFINE rs26 VARCHAR(3); DEFINE rs28 VARCHAR(10);
DEFINE rs31,rs32,rs33,rs36,rs38,rs40 CHAR(2); DEFINE rs34,rs35,rs37,rs39,rs41 CHAR(8);
--Campo para respaldar valor cuando hay mas de una incidencia de un concepto
DEFINE respalda_rsrs CHAR(8);
--Deficicion tabla br_hi
DEFINE hihi CHAR(8); DEFINE hi00 CHAR(3); DEFINE hi01 VARCHAR(16); DEFINE hi02 VARCHAR(48);
--Campo para respaldar valor cuando hay mas de una incidencia de un concepto
DEFINE respalda_hihi CHAR(8); --Deficicion tabla br_hr
DEFINE hrhr CHAR(8); DEFINE hr00 CHAR(3); DEFINE hr01 VARCHAR(16); DEFINE hr02 VARCHAR(48);
--Campo para respaldar valor cuando hay mas de una incidencia de un concepto
DEFINE respalda_hrhr CHAR(8);
--Deficicion tabla br_cr
DEFINE crcr VARCHAR(4); DEFINE cr00 lvarchar;
--Deficicion tabla br_sc
DEFINE scsc  VARCHAR(30); DEFINE sc00,sc02,sc03,sc04 VARCHAR(3); DEFINE sc01 VARCHAR(4);
DEFINE sc06 VARCHAR(2);
--Campo para respaldar valor cuando hay mas de una incidencia de un concepto
DEFINE respalda_scsc VARCHAR(30);
--Etiqueta Error ERRRUR25
DEFINE verrorburo CHAR(8); DEFINE nrows SMALLINT; DEFINE vFechaHoy DATE; DEFINE pcadena CHAR(250);
DEFINE pcadena1 CHAR(250); DEFINE pcadena2 CHAR(250); DEFINE regre SMALLINT;
DEFINE vstatus CHAR(1); DEFINE sEs01 VARCHAR(9);
DEFINE sEs02 VARCHAR(4); DEFINE sEs03 VARCHAR(99); DEFINE sEs04 VARCHAR(6);
--APR
DEFINE cNumSolSic CHAR(20); DEFINE cInstitucionSIC CHAR(2);
DEFINE dtFechaSic DATE; DEFINE p_cod_ret CHAR(6);
--HASS
DEFINE cTpsol, vvalbloq CHAR(1); DEFINE cStatusSol CHAR(2); DEFINE vcDescripcionError CHAR(100);
DEFINE cTipoSol, vetiq CHAR(2); DEFINE cDescMttoBCyCC CHAR(50);
--FICO SCORE
DEFINE vfecha_bc_sic DATE;
DEFINE l_cadena_es  INTEGER;
DEFINE dif_long_es INTEGER;
DEFINE long_es3 INTEGER;
DEFINE pos_ini_es4 INTEGER;
DEFINE pcadena_es VARCHAR(201);DEFINE long_get_cadenas INTEGER;
--IPCB junio2017 //Error credito bloqueado separacion de incremento y solicitud, rechazo de solicitud.
DEFINE csolicitud_sic CHAR(20);
--IPCB Noviembre 2018// Almacenamiento de folios consultas sics  en la ss_solicitudes_sic
DEFINE sEs03_bc VARCHAR(99); DEFINE sEs03_cc VARCHAR(99); DEFINE flag_solo_cc integer;
DEFINE cSolMixta CHAR(20); 
DEFINE cEstatusSol CHAR(2);
-- Consulta a las SICs.
DEFINE cFlujo_cc     CHAR(1);
DEFINE status_consul           	CHAR(2);
DEFINE cCanalSol	CHAR (2);
DEFINE cCalifica    CHAR(1);
DEFINE vMensaje     VARCHAR(255);
DEFINE dCompromisos DECIMAL(14,2);
DEFINE tipo_acceso_bc CHAR (03);
DEFINE usu_orden2   CHAR(10);
DEFINE pass_orden2  CHAR(8);
DEFINE vfechaServ DATE;
DEFINE cEnvioparametrico CHAR(1);
DEFINE cStatusSolactual CHAR(2);
DEFINE cNumproducto CHAR(4);
--REEVALUACION---------------
DEFINE cCodReRub      CHAR(6);
DEFINE cNumcte        CHAR(9);
DEFINE vMsg_Reasig    VARCHAR(100);
DEFINE v_Reasig_rubro CHAR (1);
DEFINE iBanPreAprobado INTEGER;
DEFINE vlinea_cred DECIMAL(14,2);
DEFINE vcapacidad_pago DECIMAL(14,2);
DEFINE vplazo INTEGER;
DEFINE v_grupo CHAR(1);
DEFINE v_min_score DECIMAL(14,2);
DEFINE v_score DECIMAL(14,2);
DEFINE v_tp_tarjeta CHAR(1);
DEFINE vFalloSIC	INTEGER;DEFINE cTipo VARCHAR(5); 
DEFINE v_hit CHAR(1);
DEFINE iContScore INTEGER;
DEFINE iCountProspecteo SMALLINT;
DEFINE v_rowid INTEGER;

LET cFlujo_cc           = '1';
LET status_consul = '';
LET cCanalSol = '';
LET cEnvioparametrico='';
LET cStatusSolactual ='';
LET cNumproducto='';
--REEVALUACION---------------
LET cNumcte             = '';
LET cCodReRub           = '000000';
LET cod_ret				= '000000';
LET vMsg_Reasig         = '';
LET v_Reasig_rubro      = '0';
LET iBanPreAprobado = 0;
LET vlinea_cred = 0;
LET vcapacidad_pago = 0;
LET vplazo = 0;
LET v_grupo = '';
LET v_min_score = 0;
LET v_score=0;
LET cTipo = '';
LET v_tp_tarjeta = '';
LET v_hit = '';
LET iContScore = 0;
LET vFalloSIC	= 0;
LET iCountProspecteo = 0;
LET v_rowid=0;

--SET DEBUG FILE TO '/home/sysifx/Oscar/ins_consulta_buro2_apolo_'||TRIM(pnum_solicitud)||'.out';
--TRACE ON;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--- Valida si se debe aplicar desglose o no Rocket
IF (select count(*) from bdisolic:ss_prospecteo_solicitudes a inner join bdisolic:ss_solicitudes_sic b
    on a.numcte = b.numcte and a.num_solicitud = b.num_solicitud and a.num_solicitud = b.num_solicitud_sic  and fecha_sic is not null
    where  a.num_solicitud = pnum_solicitud and canal_sol = 4) > 0 THEN
	LET cod_ret = '112';
    RETURN cod_ret; 
END IF;

SELECT fecha_hoy INTO vFechaHoy 
FROM bdicred:"informix".sd_fechas WHERE empresa='001';

SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
INTO vfechaServ
FROM sysmaster:sysshmvals;

IF vFechaHoy < vfechaServ THEN
	LET vFechaHoy = vfechaServ;
END IF;

LET vhora = extend(CURRENT,HOUR TO fraction(3));
LET nrows = 0; 
LET tamamax = 0;
LET long_get_cadenas = 250;

SELECT status INTO vstatus
FROM "informix".br_respuesta_aprocesar WHERE institucion = pInstitucion 
AND num_solicitud = pnum_solicitud;

IF vstatus = "3" THEN
	INSERT INTO "informix".br_auditor VALUES(pInstitucion,pnum_solicitud,vFechaHoy,vhora,"Problemas de coneccion");
    LET cod_ret = '113';
	RETURN cod_ret; 
END IF

SELECT SUM(LENGTH(regreso)) INTO tamamax FROM "informix".br_respuesta WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;

IF tamamax IS NULL THEN 
	LET tamamax=0; 
ELSE 
	LET tamamax = tamAmax -1; 
END IF

IF tamamax = 0 THEN 
    LET cod_ret = '114';
	RETURN cod_ret; 
END IF

IF tamamax > 251 THEN
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  1, long_get_cadenas) into pcadena;
ELSE
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  1, tamamax) into pcadena;
END IF

INSERT INTO "informix".br_auditor VALUES(pInstitucion,pnum_solicitud,vFechaHoy,vhora,"Iniciamos");
LET csolicitud= ""; LET iconsulta = 0; LET cOrigenSol = ""; LET papa = " ";
LET pa00,pa01,pa02,pa03,pa04,pa05 = " "," "," "," "," "," ";
LET pa06 = NULL; LET pa07,pa08,pa09,pa10,pa11 = " "," "," "," "," ";
LET pa12 = NULL; LET pepe = " ";
LET pacodpais = " ";
LET pe00,pe01,pe02,pe03,pe04,pe05,pe06,pe07,pe08,pe09,pe10 = " "," "," "," "," "," "," "," "," "," "," ";
LET pe11 = NULL; LET pe12 = " "; LET pe13 = 0; LET pe14 = " "; LET pe15 = " ";
LET pe16 = NULL; LET pe17 = NULL; LET pe18 = NULL; LET pe19 = " "; LET pecodpais = " "; LET tltl = NULL;
LET tl00,tl01,tl02,tl03,tl04,tl05,tl06,tl07,tl08 = " "," "," "," "," "," "," "," "," ";
LET tl09 = 0; LET tl10 = 0; LET tl11 = " "; LET tl12 =  0; LET tl13 = NULL;
LET tl14 = NULL; LET tl15 = NULL; LET tl16 = NULL; LET tl17 = NULL; LET tl18 = " ";
LET tl19 = NULL; LET tl20 = " "; LET tl21 = 0; LET tl22 = 0; LET tl23 = 0;
LET tl24 = 0; LET tl25 = 0; LET tl26 = " "; LET tl27 = " "; LET tl28 = NULL;
LET tl29 = NULL; LET tl30 = " "; LET tl31 = 0; LET tl32 = 0; LET tl33 = 0;
LET tl34 = 0; LET tl35 = 0; LET tl36 = 0; LET tl37 = NULL; LET tl38 = " ";
LET tl42 = NULL; LET tl45 = NULL; LET iqiq = NULL; LET iq00 = " "; LET iq01 = " "; LET iq02 = " ";
LET iq03 = " "; LET iq04 = " "; LET iq05 = " "; LET iq06 = 0; LET iq07 = " "; LET iq08 = " ";
LET iq09 = " "; LET rsrs = NULL; LET rs00,rs01,rs02,rs03,rs04,rs05,rs06,rs07 = 0,0,0,0,0,0,0,0;
LET rs08,rs09,rs10,rs11,rs12,rs13,rs14,rs15,rs16 = 0,0,0,0,0,0,0,0,0;
LET rs17 = " "; LET rs18 = " "; LET rs19 = " "; LET rs20 = " ";
LET rs21,rs22,rs23,rs24,rs25,rs26,rs27,rs28,rs29,rs30,rs31,rs32,rs33 = 0,0,0,0,0,0,0,0,0,0,0,0,0;
LET rs34 = NULL; LET rs35 = NULL; LET rs36 = 0; LET rs37 = NULL; LET rs38 = 0;
LET rs39 = NULL; LET rs40 = 0; LET rs41 = NULL; LET hihi = NULL; LET hi00 = " ";
LET hi01 = " "; LET hi02 = " "; LET hrhr = NULL; LET hr00 = " "; LET hr01 = " "; LET hr02 = " ";
LET crcr =  " "; LET scsc = " "; LET sc00 = " "; LET sc01 = " "; LET sc02 = " ";
LET sc03 = " "; LET sc04 = " "; LET sc06 = " "; LET paso = " "; LET etiqueta = " ";
LET fecha = " "; LET pnum_cliente = ""; LET item_cadena = ""; LET sEs01 = " ";
LET sEs02 = " "; LET sEs03 = " "; LET sEs04 = " "; LET cNumSolSic = ""; LET cInstitucionSIC = "";
LET dtFechaSic = DATE(1); LET p_cod_ret = "000000"; LET cTpsol = ''; LET cStatusSol = '';
LET vcDescripcionError = ''; LET cTipoSol = ''; LET cDescMttoBCyCC = '';
LET vfecha_bc_sic = DATE(1);
LET l_cadena_es  = 0;
LET dif_long_es = 0;
LET long_es3 = 0;
LET pos_ini_es4 =0;
LET pcadena_es ="";
LET csolicitud_sic ="";
LET flag_solo_cc = 0;LET sEs03_bc = ""; LET sEs03_cc = "";
LET cSolMixta = "";
LET cEstatusSol = '';

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			INSERT INTO "informix".br_cadena_error VALUES (pInstitucion,pnum_cliente,fecha, sql_err,paso,
			item_cadena,SUBSTR(pcadena,1,item_cadena + 10),vFechaHoy);
			IF EXISTS(SELECT * FROM bdisolic:ss_paso_cred_sol WHERE num_solicitud_sic = pnum_solicitud AND institucion_proc = pInstitucion ) THEN
				DELETE bdisolic:ss_paso_cred_sol WHERE num_solicitud_sic = pnum_solicitud AND institucion_proc = pInstitucion;
			END IF;
			RETURN cod_ret;
		END IF
	END EXCEPTION;
	--datos insuficientes
	IF TRIM(pcadena) = "" OR pcadena IS NULL THEN 
		LET cod_ret = "110"; 
		RETURN cod_ret; 
	END IF
	LET paso ="numcte";
	SELECT numcte INTO pnum_cliente FROM bdisolic:"informix".ss_solicitudes
	WHERE empresa = "001" AND num_solicitud = pnum_solicitud;

	--IPCB autenticador
	IF pnum_cliente is null THEN
	LET pnum_cliente = pnum_solicitud;
	END IF;

	LET paso = "Fecha";
	SELECT fecha_hoy INTO fecha FROM bdicred:"informix".sd_fechas WHERE empresa='001';
	IF fecha < vfechaServ THEN
		LET fecha = vfechaServ;
	END IF;

	--Verificacion de existencia de cliente
	LET paso = "Existe";
	--Inicializacion Par empezar a trabajar
	LET inicio = 50; LET  item_cadena = inicio; LET  etiq_size = 4; LET  long_etiq = etiq_size;
	--Si Hubo Error el el Mensaje Regresa 110
	LET verrorburo = SUBSTR(pcadena,1,4);
	LET vetiq = SUBSTR(pcadena,34,2);
	LET vvalbloq = SUBSTR(pcadena,38,1);

	--SET DEBUG FILE TO '/informix/Fperaza/traces/ins_consulta_buro2'||pnum_solicitud||'.out';
	--TRACE ON;
	--//RECHAZO POR CREDITO BLOQUEADO RCB --Se separa la respuesta de error para incrementos de linea y para solicitudes de credito.
	IF verrorburo = 'ERRR' and vetiq = '20' AND vvalbloq = 'Y' THEN
		--//RECHAZO POR CREDITO BLOQUEADO RCB --INCREMENTOS:  Cuando la respuesta de error es de un incremento se realiza el rechazo del incremento, no en la solicitud
		IF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_solicitudes_aumlincred_sucursal WHERE num_credito = pnum_solicitud AND empresa = pempresa AND (fecha_respuesta >= today - 31 or fecha_respuesta IS NULL)) THEN
			FOREACH WITH HOLD
				SELECT a.num_solicitud  INTO csolicitud_sic
				FROM bdisolic:"informix".ss_solicitudes_sic a INNER JOIN bdicred:"informix".sd_bitacora_aumlincred  b
				ON a.numcte = b.numcte and a.num_solicitud = b.num_solicitud and b.status = 'BC'
				WHERE a.numcte =pnum_cliente AND a.num_solicitud_sic = pnum_solicitud  AND  a.fecha_insert = vFechaHoy AND fecha_sic IS NULL AND institucion = pInstitucion

				UPDATE bdicred:"informix".sd_bitacora_aumlincred
				SET status          = 'RT',
					causa_status 	= 'RCB',
					fecha_status    = today,
					hora_status     = CURRENT,
					revisioncac     = 0
				WHERE fecha_insert  = vFechaHoy
				AND numcte          = pnum_cliente
				AND num_solicitud   = csolicitud_sic
				AND empresa         = pEmpresa;

				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac)
				VALUES(pEmpresa, csolicitud_sic, 'RT', 'RCB', 'sistema', vFechaHoy, vFechaHoy, 0);

				IF EXISTS (SELECT fecha_sic  FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = pnum_cliente and num_Solicitud = csolicitud_sic and fecha_sic is null) THEN
					UPDATE bdisolic:"informix".ss_solicitudes_sic set fecha_sic = vFechaHoy, causa_rt = 'RCB'
					WHERE numcte = pnum_cliente and num_Solicitud = csolicitud_sic and fecha_sic is null;
				END IF
			END FOREACH
			--IPCB junio2017 //SOLICITUDES DE CREDITO
		ELSE
			FOREACH WITH HOLD
				SELECT a.num_solicitud INTO csolicitud_sic
				FROM bdisolic:"informix".ss_solicitudes_sic a INNER JOIN bdisolic:"informix".ss_solicitudes b
				ON a.numcte = b.numcte  AND a.num_Solicitud_sic = b.num_Solicitud
				WHERE a.numcte =pnum_cliente AND  num_solicitud_sic = pnum_solicitud AND fecha_sic IS NULL AND institucion = pInstitucion AND  a.fecha_insert = vFechaHoy

				EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pempresa, 'sistema',csolicitud_sic, 'RT', 'RCB', 'RECHAZO POR CREDITO BLOQUEADO') INTO p_cod_ret;

				IF EXISTS (SELECT fecha_sic  FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = pnum_cliente and num_Solicitud = csolicitud_sic and fecha_sic is null) THEN
					UPDATE bdisolic:"informix".ss_solicitudes_sic set fecha_sic = vFechaHoy, causa_rt = 'RCB'
					WHERE numcte = pnum_cliente and num_Solicitud = csolicitud_sic and fecha_sic is null;
				END IF
			END FOREACH
		END IF;
	END IF;

	IF verrorburo = "ERRR" THEN
		-- Actualizando la bitacora de reenvios a SIC con el estatus actual
		UPDATE bdisolic:"informix".ss_mon_buro_rep SET estatus_fin = pInstitucion WHERE empresa = pempresa
		AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_mon_buro_rep WHERE numsolicitud = pnum_solicitud )
		AND numsolicitud = pnum_solicitud;
		LET cod_ret = "111"; 
		RETURN cod_ret; 
	END IF

	LET etiqueta = SUBSTR(pcadena,item_cadena,long_etiq);
	LET item_cadena = item_cadena + long_etiq; LET item_valor = item_cadena; LET long_etiq = SUBSTR(etiqueta,3,2);
	LET item_cadena = item_cadena + long_etiq; LET flag = 0; LET tamfin = 0; LET regre = 0; LET entro = "N"; LET pnpn = " ";
	LET pn00,pn01,pn02,pn03 = " "," "," "," "; LET pn04 = NULL;
	LET pn05,pn06,pn07,pn08,pn09,pn10,pn11,pn12,pn13,pn14 = " "," "," "," "," "," "," "," "," "," ";
	LET pn15,pn16,pn17,pn18 = " "," "," "," "; LET pn19 = NULL; LET pn20 = NULL;

	WHILE  (SUBSTR(etiqueta,1,2) != "PA" AND SUBSTR(etiqueta,1,2) != "PE"
	AND SUBSTR(etiqueta,1,2) != "TL" AND SUBSTR(etiqueta,1,2) != "IQ"
	AND SUBSTR(etiqueta,1,2) != "RS" AND SUBSTR(etiqueta,1,2) != "HI"
	AND SUBSTR(etiqueta,1,2) != "HR" AND SUBSTR(etiqueta,1,2) != "CR"
	AND SUBSTR(etiqueta,1,2) != "SC" AND SUBSTR(etiqueta,1,2) != "ES")
		LET paso = "PN"; 	LET entro = "S";
		IF (item_valor + long_etiq) > 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_valor - 1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_valor = 1;
			LET item_cadena = item_valor + long_etiq;
		END IF

		LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);

		IF (SUBSTR(etiqueta,1,2) = "PN") THEN LET pnpn = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "00") THEN LET pn00 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "01") THEN LET pn01 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "02") THEN LET pn02 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "03") THEN LET pn03 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "04") THEN LET pn04 = valor_cadena;
			IF (pn04 = "00000000")  THEN LET pn04 = NULL;  END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "05") THEN LET pn05 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "06") THEN LET pn06 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "07") THEN LET pn07 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "08") THEN LET pn08 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "09") THEN LET pn09 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "10") THEN LET pn10 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "11") THEN LET pn11 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "12") THEN LET pn12 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "13") THEN LET pn13 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "14") THEN LET pn14 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "15") THEN LET pn15 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "16") THEN LET pn16 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "17") THEN LET pn17 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "18") THEN LET pn18 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "19") THEN LET pn19 = valor_cadena;
			IF (pn19 = "00000000") THEN LET pn19 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "20") THEN LET pn20 = valor_cadena;
			IF (pn20 = "00000000") THEN LET pn20 = NULL; END IF;
			LET flag = 1;
		END IF;
		IF (item_cadena + etiq_size) >= 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_cadena - 1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_cadena = 1; LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET item_cadena = item_cadena + etiq_size; LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2); LET item_cadena = item_cadena + long_etiq; LET regre = item_cadena - 1;
		ELSE
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size); LET regre = etiq_size; LET item_cadena = item_cadena + etiq_size;
			LET item_valor=item_cadena; LET long_etiq = SUBSTR(etiqueta,3,2); LET regre=regre + long_etiq; LET item_cadena = item_cadena + long_etiq;
		END IF
	END WHILE;

	IF (flag <> 0) THEN
		INSERT INTO "informix".br_pn  VALUES(pInstitucion,pnum_cliente,fecha,pnpn,pn00,pn01,pn02,pn03,TO_DATE(pn04,"%d%m%Y"),
		pn05,pn06,pn07,pn08,pn09,pn10,pn11,pn12,pn13,pn14,pn15,pn16,pn17,pn18,
		TO_DATE(pn19,"%d%m%Y"),TO_DATE(pn20,"%d%m%Y"));
	END IF;

	LET flag = 0; LET pcadena2 = pcadena; LET pcadena = "";
	IF entro = "S" THEN LET tamfin = tamfin + item_cadena - regre; END IF
	LET entro = "N";
	IF (tamfin + 250) <= tamamax THEN
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	END IF

	LET item_cadena = 1; LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
	LET item_cadena = item_cadena + etiq_size; LET item_valor = item_cadena;
	LET long_etiq = SUBSTR(etiqueta,3,2); LET regre = regre + long_etiq; LET item_cadena = item_cadena + long_etiq;

	WHILE  (SUBSTR(etiqueta,1,2) != "PN" AND SUBSTR(etiqueta,1,2) != "PE"
		AND SUBSTR(etiqueta,1,2) != "TL" AND SUBSTR(etiqueta,1,2) != "IQ"
		AND SUBSTR(etiqueta,1,2) != "RS" AND SUBSTR(etiqueta,1,2) != "HI"
		AND SUBSTR(etiqueta,1,2) != "HR" AND SUBSTR(etiqueta,1,2) != "CR"
		AND SUBSTR(etiqueta,1,2) != "SC" AND SUBSTR(etiqueta,1,2) != "ES")	
		LET regre = 0;	LET entro = "S"; LET paso = "PA";
		IF (item_valor + long_etiq) > 250 THEN
			LET pcadena = ""; LET tamfin = tamfin + item_valor -1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_valor = 1; LET item_cadena = item_valor + long_etiq;
		END IF
		LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);
		IF (SUBSTR(etiqueta,1,2) = "PA") THEN LET respalda_papa = valor_cadena; END IF;
		IF (SUBSTR(etiqueta,1,2) = "PA") THEN LET papa = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "00") THEN LET pa00 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "01") THEN LET pa01 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "02") THEN LET pa02 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "03") THEN LET pa03 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "04") THEN LET pa04 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "05") THEN LET pa05 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "06") THEN LET pa06 = valor_cadena;
			IF (pa06 = "00000000")  THEN LET pa06 = NULL;  END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "07") THEN LET pa07 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "08") THEN LET pa08 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "09") THEN LET pa09 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "10") THEN LET pa10 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "11") THEN LET pa11 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "12") THEN LET pa12 = valor_cadena;
			IF (pa12 = "00000000") THEN LET pa12 = NULL; END IF;
			LET flag = 1;
		END IF;
		IF (item_cadena + etiq_size) >= 250 THEN
			LET pcadena = ""; LET tamfin = tamfin + item_cadena - 1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_cadena = 1; LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size); LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena; LET long_etiq = SUBSTR(etiqueta,3,2); LET item_cadena = item_cadena + long_etiq; LET regre = item_cadena - 1;
		ELSE
				LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size); LET regre = etiq_size; LET item_cadena = item_cadena + etiq_size;
				LET item_valor = item_cadena; LET long_etiq = SUBSTR(etiqueta,3,2); LET regre = regre + long_etiq; LET item_cadena = item_cadena + long_etiq;
		END IF
		IF ( SUBSTR(etiqueta,1,2) = "PA" )	THEN
			INSERT INTO "informix".br_pa  VALUES (pInstitucion,pnum_cliente,respalda_papa,pa00,pa01,pa02,pa03,pa04,pa05,TO_DATE(pa06,"%d%m%Y"),pa07,pa08,pa09,pa10,pa11,TO_DATE(pa12,"%d%m%Y"),vFechaHoy,pacodpais);
			LET pa00,pa01,pa02,pa03,pa04,pa05 = " "," "," "," "," "," "; LET pa06 = NULL;
			LET pa07,pa08,pa09,pa10,pa11 = " "," "," "," "," "; LET pa12 = NULL; LET valor_cadena = NULL;
		END IF;
	END WHILE;

	IF (flag <> 0) THEN
		INSERT INTO  "informix".br_pa  VALUES (pInstitucion,pnum_cliente,papa,pa00,pa01,pa02,pa03,pa04,pa05,
		TO_DATE(pa06,"%d%m%Y"),pa07,pa08,pa09,pa10,pa11,TO_DATE(pa12,"%d%m%Y"),vFechaHoy,pacodpais);
		LET  nrows = dbinfo("sqlca.sqlerrd2");
	END IF;
	IF entro = "S" THEN LET tamfin = tamfin + item_cadena - regre - 1; END IF
	LET entro = "N"; LET pcadena = "";
	IF (tamfin + 250) <= tamamax THEN
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	END IF
	LET item_cadena = 1;
	LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
	LET item_cadena = item_cadena + etiq_size;
	LET item_valor = item_cadena;
	LET long_etiq = SUBSTR(etiqueta,3,2);
	LET regre = regre + long_etiq;
	LET item_cadena = item_cadena + long_etiq;
	LET flag = 0;
	WHILE  (SUBSTR(etiqueta,1,2) != "PN" AND SUBSTR(etiqueta,1,2) != "PA"
		AND SUBSTR(etiqueta,1,2) != "TL" AND SUBSTR(etiqueta,1,2) != "IQ"
		AND SUBSTR(etiqueta,1,2) != "RS" AND SUBSTR(etiqueta,1,2) != "HI"
		AND SUBSTR(etiqueta,1,2) != "HR" AND SUBSTR(etiqueta,1,2) != "CR"
		AND SUBSTR(etiqueta,1,2) != "SC" AND SUBSTR(etiqueta,1,2) != "ES")
		LET regre =0;	LET entro = "S";	LET paso = "PE";
		IF (item_valor + long_etiq) > 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_valor -1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_valor = 1; LET item_cadena = item_valor + long_etiq;
		END IF
		LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);
		IF (SUBSTR(etiqueta,1,2) = "PE") THEN LET respalda_pepe = valor_cadena; END IF;
		IF (SUBSTR(etiqueta,1,2) = "PE") THEN LET pepe = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "00") THEN LET pe00 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "01") THEN LET pe01 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "02") THEN LET pe02 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "03") THEN LET pe03 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "04") THEN LET pe04 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "05") THEN LET pe05 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "06") THEN LET pe06 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "07") THEN LET pe07 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "08") THEN LET pe08 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "09") THEN LET pe09 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "10") THEN LET pe10 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "11") THEN LET pe11 = valor_cadena;
			IF (pe11 = "00000000") THEN LET pe11 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "12") THEN LET pe12 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "13") THEN LET pe13 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "14") THEN LET pe14 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "15") THEN LET pe15 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "16") THEN LET pe16 = valor_cadena;
			IF (pe16 = "00000000") THEN LET pe16 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "17") THEN LET pe17 = valor_cadena;
			IF (pe17 = "00000000") THEN LET pe17 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "18") THEN LET pe18 = valor_cadena;
			IF (pe18 = "00000000") THEN LET pe18 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "19") THEN LET pe19 = valor_cadena;
			LET flag = 1;
		END IF;
		IF (item_cadena + etiq_size) >= 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_cadena - 1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_cadena = 1;
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET item_cadena = item_cadena + long_etiq;
			LET regre = item_cadena - 1;
		ELSE
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET regre = etiq_size;
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET regre = regre + long_etiq;
			LET item_cadena = item_cadena + long_etiq;
		END IF
		IF ( SUBSTR(etiqueta,1,2) = "PE" ) 	THEN
			INSERT INTO  "informix".br_pe VALUES (pInstitucion,pnum_cliente,respalda_pepe,pe00,pe01,pa02,pe03,pe04,pe05,
			pe06,pe07,pe08,pe09,pe10,TO_DATE(pe11,"%d%m%Y"),pe12,num_valor(pe13),
			pe14,pe15,TO_DATE(pe16,"%d%m%Y"),TO_DATE(pe17,"%d%m%Y"),TO_DATE(pe18,"%d%m%Y"),pe19,vFechaHoy,pecodpais);
			LET pe00 = " ";	LET pe01 = " ";
			LET pe02 = " ";	LET pe03 = " ";
			LET pe04 = " ";	LET pe05 = " ";
			LET pe06 = " ";	LET pe07 = " ";
			LET pe08 = " ";	LET pe09 = " ";
			LET pe10 = " ";	LET pe11 = NULL;
			LET pe12 = " ";	LET pe13 = 0;
			LET pe14 = " ";	LET pe15 = " ";
			LET pe16 = NULL; LET pe17 = NULL;
			LET pe18 = NULL; LET pe19 = " ";
			LET valor_cadena = NULL;
		END IF;
	END WHILE;
	IF (flag <> 0) THEN
		INSERT INTO  "informix".br_pe VALUES (pInstitucion,pnum_cliente,pepe,pe00,pe01,pa02,pe03,pe04,pe05,pe06,pe07,pe08,pe09,pe10,
		TO_DATE(pe11,"%d%m%Y"),pe12,pe13,pe14,pe15,TO_DATE(pe16,"%d%m%Y"),TO_DATE(pe17,"%d%m%Y"), TO_DATE(pe18,"%d%m%Y"),pe19,vFechaHoy,pecodpais);
	END IF;
	LET pcadena = "";
	IF entro = "S" THEN
		LET tamfin = tamfin + item_cadena - regre - 1;
	END IF
	LET entro ="N";
	IF (tamfin + 250) <= tamamax THEN
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	END IF
	LET item_cadena = 1;
	LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
	LET item_cadena = item_cadena + etiq_size;
	LET item_valor = item_cadena;
	LET long_etiq = SUBSTR(etiqueta,3,2);
	LET regre = regre + long_etiq;
	LET item_cadena = item_cadena + long_etiq;
	LET flag = 0 ;
	WHILE  (SUBSTR(etiqueta,1,2) != "PN" AND SUBSTR(etiqueta,1,2) != "PA"
		AND SUBSTR(etiqueta,1,2) != "PE" AND SUBSTR(etiqueta,1,2) != "IQ"
		AND SUBSTR(etiqueta,1,2) != "RS" AND SUBSTR(etiqueta,1,2) != "HI"
		AND SUBSTR(etiqueta,1,2) != "HR" AND SUBSTR(etiqueta,1,2) != "CR"
		AND SUBSTR(etiqueta,1,2) != "SC" AND SUBSTR(etiqueta,1,2) != "ES")
		LET entro = "S";
		LET regre = 0;
		LET flag = 0;
		LET paso = "TL";
		IF (item_valor + long_etiq) > 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_valor -1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_valor = 1;	LET item_cadena = item_valor + long_etiq;
		END IF
		LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);
		IF (SUBSTR(etiqueta,1,2) = "TL") THEN LET respalda_tltl = valor_cadena; END IF;
		IF (SUBSTR(etiqueta,1,2) = "TL") THEN LET tltl = valor_cadena;
			IF (tltl = "00000000")  THEN LET tltl = NULL;  END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "00") THEN LET tl00 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "01") THEN LET tl01 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "02") THEN LET tl02 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "03") THEN LET tl03 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "04") THEN LET tl04 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "05") THEN LET tl05 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "06") THEN LET tl06 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "07") THEN LET tl07 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "08") THEN LET tl08 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "09") THEN LET tl09 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "10") THEN LET tl10 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "11") THEN LET tl11 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "12") THEN LET tl12 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "13") THEN LET tl13 = valor_cadena;
			IF (tl13 = "00000000") THEN LET tl13 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "14") THEN LET tl14 = valor_cadena;
			IF (tl14 = "00000000") THEN LET tl14 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "15") THEN LET tl15 = valor_cadena;
			IF (tl15 = "00000000") THEN LET tl15 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "16") THEN LET tl16 = valor_cadena;
			IF (tl16 = "00000000") THEN LET tl16 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "17") THEN LET tl17 = valor_cadena;
			IF (tl17 = "00000000") THEN LET tl17 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "18") THEN LET tl18 = valor_cadena;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "19") THEN LET tl19 = valor_cadena;
			IF (tl19 = "00000000") THEN LET tl19 = NULL; END IF;
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "20") THEN LET tl20 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "21") THEN LET tl21 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "22") THEN LET tl22 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "23") THEN LET tl23 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "24") THEN LET tl24 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "25") THEN LET tl25 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "26") THEN LET tl26 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "27") THEN LET tl27 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "28") THEN LET tl28 = valor_cadena; 
			IF (tl28 = "00000000") THEN 
				LET tl28 = NULL;
			END IF; 
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "29") THEN 
			LET tl29 = valor_cadena; 
			IF (tl29 = "00000000") THEN 
				LET tl29 = NULL;  
			END IF; 
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "30") THEN LET tl30 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "31") THEN LET tl31 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "32") THEN LET tl32 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "33") THEN LET tl33 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "34") THEN LET tl34 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "35") THEN LET tl35 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "36") THEN LET tl36 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "37") THEN LET tl37 = valor_cadena; 
			IF (tl37 = "00000000") THEN 
				LET tl37 = NULL;  
			END IF; 
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "38") THEN LET tl38 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "42") THEN LET tl42 = valor_cadena; 
			IF (tl42 = "00000000") THEN 
				LET tl42 = NULL;  
			END IF; 
			LET flag = 1;
		END IF;
		IF (item_cadena + etiq_size) >= 250 THEN
			LET pcadena = ""; 	LET tamfin = tamfin + item_cadena - 1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_cadena = 1;
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET item_cadena = item_cadena + long_etiq;
			LET regre = item_cadena - 1;
		ELSE
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET regre = etiq_size;
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET regre = regre + long_etiq;
			LET item_cadena = item_cadena + long_etiq;
		END IF
		IF ( SUBSTR(etiqueta,1,2) = "TL" ) THEN
			INSERT INTO  "informix".br_tl VALUES(pInstitucion,pnum_cliente,TO_DATE(respalda_tltl,"%d%m%Y"),tl00,tl01,tl02,
			tl03,tl04,tl05,tl06,tl07,tl08,num_valor(tl09),num_valor(tl10),tl11,num_valor(tl12),
			TO_DATE(tl13,"%d%m%Y"),TO_DATE(tl14,"%d%m%Y"),TO_DATE(tl15,"%d%m%Y"),
			TO_DATE(tl16,"%d%m%Y"),TO_DATE(tl17,"%d%m%Y"),tl18,TO_DATE(tl19,"%d%m%Y"),
			tl20,num_valor(tl21),num_valor(tl22),num_valor(tl23),num_valor(tl24),num_valor(tl25),tl26,tl27,
			TO_DATE(tl28,"%d%m%Y"),TO_DATE(tl29,"%d%m%Y"),tl30,num_valor(tl31),num_valor(tl32),
			num_valor(tl33),num_valor(tl34),num_valor(tl35),
			num_valor(tl36),TO_DATE(tl37,"%d%m%Y"),tl38,TO_DATE(tl42,"%d%m%Y"),vFechaHoy,tl45);
			LET tl00 = " ";	LET tl01 = " ";
			LET tl02 = " "; LET tl03 = " ";
			LET tl04 = " ";	LET tl05 = " ";
			LET tl06 = " ";	LET tl07 = " ";
			LET tl08 = " ";	LET tl09 = 0;
			LET tl10 = 0;	LET tl11 = " ";
			LET tl12 = 0;	LET tl13 = NULL;
			LET tl14 = NULL; LET tl15 = NULL;
			LET tl16 = NULL; LET tl17 = NULL;
			LET tl18 = " "; LET tl19 = NULL;
			LET tl20 = " "; LET tl21 = 0;
			LET tl22 = 0;	LET tl23 = 0;
			LET tl24 =  0;	 LET tl25 = 0;
			LET tl26 = " "; LET tl27 = " ";
			LET tl28 = NULL; LET tl29 = NULL;
			LET tl30 = " "; LET tl31 = 0;
			LET tl32 = 0; LET tl33 = 0;
			LET tl34 = 0; LET tl35 = 0;
			LET tl36 = 0; LET tl37 = NULL;
			LET tl38 = " "; LET tl42 = NULL;
			LET valor_cadena = NULL;
		END IF;
	END WHILE;

	IF (flag <> 0) THEN
		INSERT INTO  "informix".br_tl VALUES (pInstitucion,pnum_cliente,TO_DATE(tltl,"%d%m%Y"),tl00,tl01,tl02,tl03,tl04,tl05,tl06,tl07,tl08,tl09,
		num_valor(tl10),tl11,num_valor(tl12),TO_DATE(tl13,"%d%m%Y"),TO_DATE(tl14,"%d%m%Y"),
		TO_DATE(tl15,"%d%m%Y"),TO_DATE(tl16,"%d%m%Y"),TO_DATE(tl17,"%d%m%Y"),tl18,
		TO_DATE(tl19,"%d%m%Y"),tl20,num_valor(tl21),num_valor(tl22),tl23,tl24,tl25,tl26,tl27,
		TO_DATE(tl28,"%d%m%Y"),TO_DATE(tl29,"%d%m%Y"),tl30,num_valor(tl31),num_valor(tl32),
		num_valor(tl33),num_valor(tl34),num_valor(tl35),num_valor(tl36),TO_DATE(tl37,"%d%m%Y"),
		tl38,TO_DATE(tl42,"%d%m%Y"),vFechaHoy,tl45);
	END IF;
	LET pcadena = "";
	IF entro = "S" THEN
		LET tamfin = tamfin + item_cadena - regre - 1;
	END IF
	LET entro = "N";
	IF (tamfin + 250) <= tamamax THEN
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	END IF
	LET item_cadena = 1;
	LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
	LET item_cadena = item_cadena + etiq_size;
	LET item_valor = item_cadena;
	LET long_etiq = SUBSTR(etiqueta,3,2);
	LET regre = regre + long_etiq;
	LET item_cadena = item_cadena + long_etiq;
	LET flag = 0;

	WHILE (SUBSTR(etiqueta,1,2) != "PN" AND SUBSTR(etiqueta,1,2) != "PA"
		AND SUBSTR(etiqueta,1,2) != "PE" AND SUBSTR(etiqueta,1,2) != "TL"
		AND SUBSTR(etiqueta,1,2) != "RS" AND SUBSTR(etiqueta,1,2) != "HI"
		AND SUBSTR(etiqueta,1,2) != "HR" AND SUBSTR(etiqueta,1,2) != "CR"
		AND SUBSTR(etiqueta,1,2) != "SC" AND SUBSTR(etiqueta,1,2) != "ES")
		LET paso = "IQ";	LET regre = 0;	LET entro = "S";
		IF (item_valor + long_etiq) > 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_valor -1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_valor = 1; LET item_cadena = item_valor + long_etiq;
		END IF

		LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);
		IF (SUBSTR(etiqueta,1,2) = "IQ") THEN LET respalda_iqiq = valor_cadena; END IF;
		IF (SUBSTR(etiqueta,1,2) = "IQ") THEN LET iqiq = valor_cadena; 
			IF (iqiq = "00000000")	THEN 
				LET iqiq = NULL;  
			END IF; 
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "00") THEN LET iq00 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "01") THEN LET iq01 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "02") THEN LET iq02 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "03") THEN LET iq03 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "04") THEN LET iq04 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "05") THEN LET iq05 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "06") THEN LET iq06 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "07") THEN LET iq07 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "08") THEN LET iq08 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "09") THEN LET iq09 = valor_cadena; LET flag = 1;
		END IF;
		IF (item_cadena + etiq_size) >= 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_cadena - 1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_cadena = 1;
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET item_cadena = item_cadena + long_etiq;
			LET regre = item_cadena - 1 ;
		ELSE
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET regre = etiq_size;
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET regre = regre + long_etiq;
			LET item_cadena = item_cadena + long_etiq;
		END IF
		IF ( SUBSTR(etiqueta,1,2) = "IQ" ) 	THEN
			INSERT INTO  "informix".br_iq  VALUES (pInstitucion,pnum_cliente,TO_DATE(respalda_iqiq,"%d%m%Y"),
			iq00,iq01,iq02,iq03,iq04,iq05,num_valor(iq06),iq07,iq08,iq09,vFechaHoy);
			LET iq00 = " "; LET iq01 = " ";
			LET iq02 = " ";	LET iq03 = " ";
			LET iq04 = " ";	LET iq05 = " ";
			LET iq06 = 0;	LET iq07 = " ";
			LET iq08 = " "; LET iq09 = " ";
			LET valor_cadena =  NULL;	
		END IF;
	END WHILE;
	IF ( flag <> 0) THEN
		INSERT INTO  "informix".br_iq  VALUES (pInstitucion,pnum_cliente,TO_DATE(iqiq,"%d%m%Y"),iq00,iq01,iq02,iq03,iq04,iq05,
		num_valor(iq06),iq07,iq08,iq09,vFechaHoy);
	END IF;
	LET pcadena = "";
	IF entro = "S" THEN
		LET tamfin = tamfin + item_cadena - regre - 1;
	END IF
	LET entro = "N";
	IF (tamfin + 250) <= tamamax THEN
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	END IF
	LET item_cadena = 1;
	LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
	LET item_cadena = item_cadena + etiq_size;
	LET item_valor = item_cadena;
	LET long_etiq = SUBSTR(etiqueta,3,2);
	LET regre = regre + long_etiq;
	LET item_cadena = item_cadena + long_etiq;
	LET flag = 0;

	WHILE  (SUBSTR(etiqueta,1,2) != "PN" AND SUBSTR(etiqueta,1,2) != "PA"
		AND SUBSTR(etiqueta,1,2) != "PE" AND SUBSTR(etiqueta,1,2) != "TL"
		AND SUBSTR(etiqueta,1,2) != "IQ" AND SUBSTR(etiqueta,1,2) != "HI"
		AND SUBSTR(etiqueta,1,2) != "HR" AND SUBSTR(etiqueta,1,2) != "CR"
		AND SUBSTR(etiqueta,1,2) != "SC" AND SUBSTR(etiqueta,1,2) != "ES")
		LET paso = "RS"; 	LET regre = 0; 	LET entro = "S";
		IF (item_valor + long_etiq) > 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_valor -1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_valor = 1;
			LET item_cadena = item_valor + long_etiq;
		END IF
		LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);
		LET regre = 0;
		IF (SUBSTR(etiqueta,1,2) = "RS") THEN LET respalda_rsrs = valor_cadena; END IF;
		IF (SUBSTR(etiqueta,1,2) = "RS") THEN LET rsrs = valor_cadena;  LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "00") THEN LET rs00 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "01") THEN LET rs01 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "02") THEN LET rs02 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "03") THEN LET rs03 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "04") THEN LET rs04 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "05") THEN LET rs05 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "06") THEN LET rs06 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "07") THEN LET rs07 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "08") THEN LET rs08 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "09") THEN LET rs09 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "10") THEN LET rs10 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "11") THEN LET rs11 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "12") THEN LET rs12 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "13") THEN LET rs13 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "14") THEN LET rs14 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "15") THEN LET rs15 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "16") THEN LET rs16 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "17") THEN LET rs17 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "18") THEN LET rs18 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "19") THEN LET rs19 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "20") THEN LET rs20 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "21") THEN LET rs21 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "22") THEN LET rs22 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "23") THEN LET rs23 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "24") THEN LET rs24 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "25") THEN LET rs25 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "26") THEN LET rs26 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "27") THEN LET rs27 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "28") THEN LET rs28 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "29") THEN LET rs29 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "30") THEN LET rs30 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "31") THEN LET rs31 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "32") THEN LET rs32 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "33") THEN LET rs33 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "34") THEN LET rs34 = valor_cadena; 
			IF (rs34 = "00000000") THEN 
				LET rs34 = NULL; 
			END IF; 
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "35") THEN 
			LET rs35 = valor_cadena; 
			IF (rs35 = "00000000") THEN 
				LET rs35 = NULL;  
			END IF; 
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "36") THEN LET rs36 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "37") THEN LET rs37 = valor_cadena; 
			IF (rs37 = "00000000") THEN 
				LET rs37 = NULL;  
			END IF; 
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "38") THEN LET rs38 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "39") THEN LET rs39 = valor_cadena; 
			IF (rs39 = "00000000") THEN 
				LET rs39 = NULL;  
			END IF; 
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "40") THEN LET rs40 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "41") THEN LET rs41= valor_cadena;  
			IF (rs41 = "00000000") THEN 
				LET rs41 = NULL; 
			END IF; 
			LET flag = 1;
		END IF;
		IF (item_cadena + etiq_size) >= 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_cadena - 1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_cadena = 1;
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET item_cadena = item_cadena + long_etiq;
			LET regre = item_cadena-1;
		ELSE
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET regre = etiq_size;
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET regre = regre + long_etiq;
			LET item_cadena = item_cadena + long_etiq;
		END IF
		IF ( SUBSTR(etiqueta,1,2) = "RS" )	THEN
			INSERT INTO  br_rs VALUES (pInstitucion,pnum_cliente,TO_DATE(respalda_rsrs,"%d%m%Y") ,num_valor(rs00) ,
			num_valor(rs01) ,num_valor(rs02),num_valor(rs03) ,num_valor(rs04) , num_valor(rs05) ,
			num_valor(rs06) , num_valor(rs07) , num_valor(rs08) , num_valor(rs09) , num_valor(rs10) ,
			num_valor(rs11) , num_valor(rs12) , num_valor(rs13) , num_valor(rs14) , num_valor(rs15) ,
			num_valor(rs16) ,rs17 , rs18 , rs19 , rs20 , num_valor(rs21) , num_valor(rs22) ,
			num_valor(rs23) , num_valor(rs24) , num_valor(rs25) , num_valor(rs26) ,
			num_valor(rs27) , num_valor(rs28) , num_valor(rs29) , num_valor(rs30) , num_valor(rs31) ,
			num_valor(rs32) , num_valor(rs33) , TO_DATE(rs34,"%d%m%Y")  , TO_DATE(rs35,"%d%m%Y")  ,
			num_valor(rs36) , TO_DATE(rs37,"%d%m%Y")  , num_valor(rs38) , TO_DATE(rs39 ,"%d%m%Y") ,
			num_valor(rs40) , TO_DATE(rs41,"%d%m%Y"),vFechaHoy  );
			LET rs20 = " ";	LET rs21 = 0;	LET rs22 = 0;	LET rs23 = 0;	LET rs24 = 0;
			LET rs25 = 0;	LET rs26 = 0;	LET rs27 = 0;	LET rs28 = 0;	LET rs29 = 0;
			LET rs30 = 0; 	LET valor_cadena = NULL;
		END IF;
	END WHILE;
	IF (flag <> 0) THEN
		INSERT INTO  "informix".br_rs VALUES (pInstitucion,pnum_cliente,TO_DATE(rsrs,"%d%m%Y") , num_valor(rs00) , num_valor(rs01) ,
		num_valor(rs02) , num_valor(rs03) , num_valor(rs04) , num_valor(rs05) , num_valor(rs06) , num_valor(rs07) ,
		num_valor(rs08) , num_valor(rs09) , num_valor(rs10) , num_valor(rs11) , num_valor(rs12) , num_valor(rs13) ,
		num_valor(rs14) , num_valor(rs15) , num_valor(rs16) , rs17 , rs18 , rs19 , rs20 , num_valor(rs21) ,
		num_valor(rs22) , num_valor(rs23) , num_valor(rs24) , num_valor(rs25) , num_valor(rs26) , num_valor(rs27) ,
		num_valor(rs28) , num_valor(rs29) , num_valor(rs30) , num_valor(rs31) , num_valor(rs32) , num_valor(rs33) ,
		TO_DATE(rs34,"%d%m%Y")  , TO_DATE(rs35,"%d%m%Y")  ,   num_valor(rs36) , TO_DATE(rs37,"%d%m%Y")  ,
		num_valor(rs38) , TO_DATE(rs39 ,"%d%m%Y") , num_valor(rs40) , TO_DATE(rs41,"%d%m%Y"), vFechaHoy  );
	END IF;
	LET pcadena = "";
	IF entro = "S" THEN
		LET tamfin = tamfin + item_cadena - regre - 1;
	END IF
	LET entro = "N";
	IF (tamfin + 250) <= tamamax THEN
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	END IF
	LET item_cadena = 1;
	LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
	LET item_cadena = item_cadena + etiq_size;
	LET item_valor = item_cadena;
	LET long_etiq = SUBSTR(etiqueta,3,2);
	LET regre = regre + long_etiq;
	LET item_cadena = item_cadena + long_etiq;
	LET flag = 0;
	WHILE  (SUBSTR(etiqueta,1,2) != "PN" AND SUBSTR(etiqueta,1,2) != "PA"
		AND SUBSTR(etiqueta,1,2) != "PE" AND SUBSTR(etiqueta,1,2) != "TL"
		AND SUBSTR(etiqueta,1,2) != "IQ" AND SUBSTR(etiqueta,1,2) != "RS"
		AND SUBSTR(etiqueta,1,2) != "HR" AND SUBSTR(etiqueta,1,2) != "CR"
		AND SUBSTR(etiqueta,1,2) != "SC" AND SUBSTR(etiqueta,1,2) != "ES")
		LET regre = 0;	LET entro = "S";	LET paso = "HI";
		IF (item_valor + long_etiq) > 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_valor -1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_valor = 1; LET item_cadena = item_valor + long_etiq;
		END IF
		LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);
		IF (SUBSTR(etiqueta,1,2) = "HI") THEN LET respalda_hihi = valor_cadena; END IF;
		IF (SUBSTR(etiqueta,1,2) = "HI") THEN LET hihi = valor_cadena; 
			IF (hihi = "00000000") THEN 
				LET hihi = NULL;  
			END IF; 
			LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "00") THEN LET hi00 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "01") THEN LET hi01 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "02") THEN LET hi02 = valor_cadena; LET flag = 1;
		END IF;
		IF (item_cadena + etiq_size) >= 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_cadena - 1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_cadena = 1;
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET item_cadena = item_cadena + long_etiq;
			LET regre = item_cadena - 1 ;
		ELSE
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET regre = etiq_size;
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET regre = regre + long_etiq;
			LET item_cadena = item_cadena + long_etiq;
		END IF
		IF ( SUBSTR(etiqueta,1,2) = "HI" )	THEN
			INSERT INTO  "informix".br_hi  VALUES (pInstitucion,pnum_cliente,TO_DATE(respalda_hihi,"%d%m%Y") ,hi00,hi01,hi02,vFechaHoy);
			LET hi00 = " ";	LET hi01 = " "; LET hi02 = " "; LET valor_cadena = NULL;
		END IF;
	END WHILE;
	IF ( flag <> 0) THEN
		INSERT INTO "informix".br_hi  VALUES (pInstitucion,pnum_cliente,TO_DATE(hihi,"%d%m%Y") ,hi00,hi01,hi02,vFechaHoy);
	END IF;
	IF entro = "S" THEN LET tamfin = tamfin + item_cadena - regre - 1; END IF
	LET entro = "N"; LET pcadena = "";
	IF (tamfin + 250) <= tamamax THEN
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	END IF
	LET item_cadena = 1;
	LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
	LET item_cadena = item_cadena + etiq_size;
	LET item_valor = item_cadena;
	LET long_etiq = SUBSTR(etiqueta,3,2);
	LET regre = regre + long_etiq;
	LET item_cadena = item_cadena + long_etiq;
	LET flag = 0;
	WHILE (SUBSTR(etiqueta,1,2) != "PN" AND SUBSTR(etiqueta,1,2) != "PA"
		AND SUBSTR(etiqueta,1,2) != "PE" AND SUBSTR(etiqueta,1,2) != "TL"
		AND SUBSTR(etiqueta,1,2) != "IQ" AND SUBSTR(etiqueta,1,2) != "RS"
		AND SUBSTR(etiqueta,1,2) != "HI" AND SUBSTR(etiqueta,1,2) != "CR"
		AND SUBSTR(etiqueta,1,2) != "SC" AND SUBSTR(etiqueta,1,2) != "ES")
		LET paso = "HR"; 	LET regre = 0;	LET entro = "S";
		IF (item_valor + long_etiq) > 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_valor -1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_valor = 1; LET item_cadena = item_valor + long_etiq;
		END IF
		LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);
		IF (SUBSTR(etiqueta,1,2) = "HR") THEN LET respalda_hrhr = valor_cadena; END IF;
		IF (SUBSTR(etiqueta,1,2) = "HR") THEN LET hrhr = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "00") THEN LET hr00 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "01") THEN LET hr01 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "02") THEN LET hr02 = valor_cadena; LET flag = 1;
		END IF;
		IF (item_cadena + etiq_size) >= 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_cadena - 1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_cadena = 1;
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET item_cadena = item_cadena + long_etiq;
			LET regre = item_cadena - 1 ;
		ELSE
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET regre = etiq_size;
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET regre = regre + long_etiq;
			LET item_cadena = item_cadena + long_etiq;
		END IF
		IF ( SUBSTR(etiqueta,1,2) = "HR" )	THEN
			INSERT INTO "informix".br_hr  VALUES (pInstitucion,pnum_cliente,TO_DATE(respalda_hrhr,"%d%m%Y") ,hr00,hr01,hr02,vFechaHoy);
			LET hr00 = " ";	LET hr01 = " ";	LET hr02 = " ";	LET valor_cadena = NULL;
		END IF;
	END WHILE;
	IF (flag <> 0) THEN
		INSERT INTO  "informix".br_hr VALUES (pInstitucion,pnum_cliente,TO_DATE(hrhr,"%d%m%Y") ,hr00,hr01,hr02,vFechaHoy);
	END IF;
	IF entro = "S" THEN
		LET tamfin = tamfin + item_cadena - regre - 1;
	END IF
	LET entro = "N"; LET pcadena = "";
	IF (tamfin + 250) <= tamamax THEN
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	END IF
	LET item_cadena = 1;
	LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
	LET item_cadena = item_cadena + etiq_size;
	LET item_valor = item_cadena;
	LET long_etiq = SUBSTR(etiqueta,3,2);
	LET regre = regre + long_etiq;
	LET item_cadena = item_cadena + long_etiq;
	LET flag = 0;
	LET tamfin = tamfin;
	WHILE (SUBSTR(etiqueta,1,2) != "PN" AND SUBSTR(etiqueta,1,2) != "PA"
		AND SUBSTR(etiqueta,1,2) != "PE" AND SUBSTR(etiqueta,1,2) != "TL"
		AND SUBSTR(etiqueta,1,2) != "IQ" AND SUBSTR(etiqueta,1,2) != "RS"
		AND SUBSTR(etiqueta,1,2) != "HI" AND SUBSTR(etiqueta,1,2) != "HR"
		AND SUBSTR(etiqueta,1,2) != "SC" AND SUBSTR(etiqueta,1,2) != "ES")
		LET regre = 0;	LET paso = "CR";	LET entro = "S"; 	LET crcr = "CR";
		LET cr00 = ""; 	LET entro = "S";
		LET j = SUBSTR(pcadena,5,4);
		LET tamfin = tamfin + 12 ;
		WHILE j > 0
			EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			LET cr00 = cr00||SUBSTR(pcadena,1,1); 
			LET tamfin = tamfin + 1 ;
			LET j = j - 1;
		END WHILE;
		INSERT INTO  "informix".br_cr  VALUES (pInstitucion,pnum_cliente,crcr,cr00,vFechaHoy);
		LET pcadena = "";
		IF (tamfin + 250) <= tamamax THEN
			EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
		ELSE
			LET tamres = tamamax - tamfin;
			EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
		END IF
		LET item_cadena = 1;
		LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
		LET item_cadena = item_cadena + etiq_size;
		LET item_valor = item_cadena;
		LET long_etiq = SUBSTR(etiqueta,3,2);
		LET item_cadena = item_cadena + long_etiq;
		LET regre = item_cadena - 1;
		LET flag = 0;
	END WHILE;
	IF entro = "S" THEN
		LET tamfin = tamfin + item_cadena - regre - 1;
	END IF
	LET entro = "N";  LET pcadena = "";
	IF (tamfin + 250) <= tamamax THEN
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	END IF
	LET item_cadena = 1;
	LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
	LET item_cadena = item_cadena + etiq_size;
	LET item_valor = item_cadena;
	LET long_etiq = SUBSTR(etiqueta,3,2);
	LET regre = regre + long_etiq;
	LET item_cadena = item_cadena + long_etiq;
	LET flag = 0;
	WHILE  (SUBSTR(etiqueta,1,2) != "PN" AND SUBSTR(etiqueta,1,2) != "PA"
		AND SUBSTR(etiqueta,1,2) != "PE" AND SUBSTR(etiqueta,1,2) != "TL"
		AND SUBSTR(etiqueta,1,2) != "IQ" AND SUBSTR(etiqueta,1,2) != "RS"
		AND SUBSTR(etiqueta,1,2) != "HI" AND SUBSTR(etiqueta,1,2) != "HR"
		AND SUBSTR(etiqueta,1,2) != "CR" AND SUBSTR(etiqueta,1,2) != "ES")
		LET paso = "SC";	LET regre = 0; LET entro = "S";
		IF (item_valor + long_etiq) > 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_valor -1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_valor = 1; LET item_cadena = item_valor + long_etiq;
		END IF
		LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);
		LET regre = 0; LET entro = "S";
		IF (SUBSTR(etiqueta,1,2) = "SC") THEN LET respalda_scsc = valor_cadena; END IF;
		IF (SUBSTR(etiqueta,1,2) = "SC") THEN LET scsc = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "00") THEN LET sc00 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "01") THEN LET sc01 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "02") THEN LET sc02 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "03") THEN LET sc03 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "04") THEN LET sc04 = valor_cadena; LET flag = 1;
		ELIF (SUBSTR(etiqueta,1,2) = "06") THEN LET sc06 = valor_cadena; LET flag = 1;
		END IF;
		IF (item_cadena + etiq_size) >= 250 THEN
			LET pcadena = "";
			LET tamfin = tamfin + item_cadena - 1;
			IF (tamfin + 250) <= tamamax THEN
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			ELSE
				LET tamres = tamamax - tamfin;
				EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			END IF
			LET item_cadena = 1;
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET item_cadena = item_cadena + long_etiq;
			LET regre = item_cadena-1;
		ELSE
			LET etiqueta = SUBSTR(pcadena,item_cadena, etiq_size);
			LET regre = etiq_size;
			LET item_cadena = item_cadena + etiq_size;
			LET item_valor = item_cadena;
			LET long_etiq = SUBSTR(etiqueta,3,2);
			LET regre = regre + long_etiq;
			LET item_cadena = item_cadena + long_etiq;
		END IF
		IF ( SUBSTR(etiqueta,1,2) = "SC" )	THEN
			INSERT INTO  "informix".br_sc  VALUES (pInstitucion,pnum_cliente,respalda_scsc,sc00,sc01,sc02,sc03,sc04,sc06,vFechaHoy);
			LET sc00 = " ";	LET sc01 = " ";	LET sc02 = " ";	LET sc03 = " ";
			LET sc04 = " ";	LET sc06 = " ";	LET valor_cadena = NULL;
		END IF;
	END WHILE;
	IF (flag <>0)
		THEN INSERT INTO "informix".br_sc VALUES (pInstitucion,pnum_cliente,scsc,sc00,sc01,sc02,sc03,sc04,sc06,vFechaHoy);
	END IF;

	LET etiqueta = etiqueta;
	LET pcadena = pcadena;
	IF (SUBSTR(etiqueta,1,2) = "ES")  THEN
		IF pInstitucion = 'BC'  THEN      --IPCB_ES Ajunte extraccion segmento ES para Buro y Ciruculo
			let l_cadena_es = 29;
		ELIF  pInstitucion = 'CC' THEN
			let l_cadena_es = 29;
		END IF;

		LET pcadena = SUBSTR(pcadena ,item_cadena-9,l_cadena_es);
		LET pos_ini_es4 = (l_cadena_es-5);
		LET long_es3 = (pos_ini_es4-14);

		IF (SUBSTR(pcadena, l_cadena_es-1, 2) = "**" ) THEN
			LET sEs01 = SUBSTR(pcadena,1,9); LET sEs02 = SUBSTR(pcadena,10,4);LET sEs03 = SUBSTR(pcadena,14,long_es3); LET sEs04 = SUBSTR(pcadena,pos_ini_es4,6);

			INSERT INTO "informix".br_es VALUES (pInstitucion,pnum_cliente,sEs01,sEs02,sEs03,sEs04,vFechaHoy);
			LET cod_ret = "000";	LET paso = "0000";

		ELSE
			LET pcadena_es = SUBSTR(pcadena ,item_cadena-9,201);
			LET l_cadena_es = length(pcadena_es);
			LET dif_long_es = l_cadena_es - 107;
			LET long_es3 = 9+dif_long_es;
			LET pos_ini_es4 =14 +long_es3 ;

			IF entro = "S" THEN LET tamfin = tamfin + item_cadena - regre -1; END IF

			EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
			LET sEs01 = SUBSTR(pcadena,1,9); LET sEs02 = SUBSTR(pcadena,10,4);LET sEs03 = SUBSTR(pcadena,14,long_es3); LET sEs04 = SUBSTR(pcadena,pos_ini_es4,6);
			IF (SUBSTR(pcadena,1,2) = "ES") THEN
				LET pnum_cliente = pnum_cliente;
				INSERT INTO "informix".br_es VALUES (pInstitucion,pnum_cliente,sEs01,sEs02,sEs03,sEs04,vFechaHoy);
			END IF;
			LET cod_ret = "000";	LET paso = "0000";
		END IF;
		IF pInstitucion = 'BC' THEN
			LET sEs03_bc = sEs03;
		ELIF  pInstitucion = 'CC' THEN
			LET sEs03_cc = sEs03;
		END IF;
	ELSE
		LET cod_ret = "111";LET paso = "PNES";
		INSERT INTO "informix".br_cadena_error VALUES (pInstitucion,pnum_cliente,fecha, "SIN PN/ES", " ",0,SUBSTR(pcadena,1,item_cadena + 10),vFechaHoy);
	END IF;

	UPDATE bdisolic:"informix".ss_solicitudes_sic
	SET fecha_sic = vFechaHoy,		
		folio_bc = (CASE WHEN pInstitucion = 'BC' THEN sEs03_bc ELSE folio_bc END),
		folio_cc = (CASE WHEN pInstitucion = 'CC' THEN sEs03_cc ELSE folio_cc END)
	WHERE empresa = pempresa
	AND numcte = pnum_cliente
	AND num_solicitud = pnum_solicitud
	AND (fecha_sic IS NULL OR (pInstitucion = 'BC' AND folio_bc IS NULL) OR (pInstitucion = 'CC' AND folio_cc IS NULL));

	--Fin Caja Unica. Viridiana
	UPDATE "informix".br_auditor SET comentario = ""
	WHERE institucion = pInstitucion AND solicitud = pnum_solicitud;
	RETURN cod_ret; 
END;
END PROCEDURE 
DOCUMENT "Version 1.00.000",
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'DESCRIPCION: Se genera procedimiento copia de ins_consulta_buro2 productivo, conservando',
'solo el proceso de destrame de la respuesta de buro de credito.',
'AUTOR: Oscar Marquez',
'BD: BDIBURO',
'FECHA: 25/03/2024',
'APOLO TDC',
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".burocred_apolo(pEmpresa CHAR(3),pSucursal CHAR(4), pUsuario CHAR(8), pSolicitud CHAR(20), pMontoSol MONEY(14,2))
RETURNING  CHAR(05) AS codret,
		   CHAR(20) AS nocte,
		   CHAR(20) AS solicitud,
		   CHAR(255) AS trama,
		   CHAR(2255) AS trama1,
		   CHAR(255) AS trama2;
---------------DECLARACION DE VARIABLES
	DEFINE vregistro CHAR(255);
	DEFINE vregistro1 CHAR(255);
    DEFINE vregistro2 CHAR(255);
	DEFINE vcliente CHAR(20);
							
	DEFINE vlen INTEGER;
	DEFINE vpos CHAR(2);
	DEFINE vpo1 CHAR(5);
	DEFINE vdia CHAR(2);
	DEFINE vmes CHAR(2);
	DEFINE vanio CHAR(4);
	-- Variables para ver si se va a Buro o no --
	DEFINE vf1mes DATE;
	DEFINE vstatus CHAR(2);
	DEFINE vcodret CHAR(5);
	DEFINE vecampo1 CHAR(4);
	DEFINE vecampo2 CHAR(2);
	DEFINE vecampo3 CHAR(25);
	DEFINE vecampo4 CHAR(3);
	DEFINE vecampo5 CHAR(2);
	DEFINE vecampo6 CHAR(4);
	DEFINE vecampo7 CHAR(10);
	DEFINE vecampo8 CHAR(8);
	DEFINE vecampo9 CHAR(1);
	DEFINE vecampo10 CHAR(2);
	DEFINE vecampo11 CHAR(2);
	DEFINE vecampo12 CHAR(9);
	DEFINE vecampo13 CHAR(2);
	DEFINE vecampo14 CHAR(2);
	DEFINE vecampo15 CHAR(1);
	DEFINE vecampo16 CHAR(4);
	DEFINE vecampo17 CHAR(7);
	DEFINE vexiste INTEGER;
	DEFINE vcodini INTEGER;
	DEFINE vcodfin INTEGER;
	-- Datos del Cliente --
	DEFINE vdcampo1 CHAR(2);
	DEFINE vdcampo2 CHAR(26);
	DEFINE vdcampo3 CHAR(26);
	DEFINE vdcampo4 CHAR(26);
	DEFINE vdcampo5 CHAR(26);
	DEFINE vdcampo6 CHAR(10);
	DEFINE vdcampo7 CHAR(13);
	DEFINE vdcampo8 CHAR(2);
	DEFINE vdcampo9 CHAR(1);
	DEFINE vdcampo10 CHAR(1);
	DEFINE vdcampo11 CHAR(1);
	DEFINE vdcampo12 CHAR(2);
	DEFINE vscampo1 CHAR(2);
	DEFINE vscampo2 CHAR(40);
	DEFINE vscampo3 CHAR(40);
	DEFINE vscampo3_1 CHAR(40);
	DEFINE vscampo3_2 CHAR(40);
	DEFINE vscampo4 CHAR(40);
	DEFINE vscampo5 CHAR(40);
	DEFINE vscampo6 CHAR(40);
	DEFINE vscampo7 CHAR(4);
	DEFINE vscampo8 CHAR(5);
	DEFINE vscampo8a INTEGER;
	DEFINE vscampo9 CHAR(1);
	DEFINE vexiste1 SMALLINT;
	DEFINE vquita CHAR(40);
	DEFINE vespacio CHAR(1);
	DEFINE vmanzana SMALLINT;
	DEFINE vandador SMALLINT;
	DEFINE vlote SMALLINT;
	DEFINE vedificio SMALLINT;
	DEFINE ventrada SMALLINT;
	DEFINE vsecuencia SMALLINT;
	DEFINE vcomentario CHAR(80);
	DEFINE vhora datetime HOUR TO fraction(3);
	DEFINE vfecha DATE;
	DEFINE status_1      CHAR(2);  ---cambio CAS
	DEFINE status_2      CHAR(2);  ---cambio CAS
	DEFINE producto_sol  CHAR(20);
	DEFINE siglas_producto  CHAR(2);
	DEFINE cResultado  CHAR(6);
	DEFINE cMensajeRes  CHAR(8);
	DEFINE iSql_err      INTEGER;
	
    DEFINE vnumerocalle INTEGER;
	DEFINE iFlag2credito         SMALLINT;
	
	DEFINE valida_hit CHAR(1);
    DEFINE wBegin       CHAR(1);
	
	-- RQM 09 554 - Consulta a las SICÃÂ¯ÃÂ¿ÃÂ½s.
	DEFINE cFlujo_cc CHAR(1);
	DEFINE status_consul           	CHAR(2);
	DEFINE solicitudes_sic		CHAR(2);
	DEFINE cCanalSol	CHAR (2);
	-- RQI Originacion solicitudes 24 x 7
	DEFINE vfechaServ DATE;
	DEFINE vConsAleat	INTEGER;	DEFINE vFalloSIC	INTEGER;
---------------INICIALIZACION DE VARIABLES
	LET vhora = extend(CURRENT,HOUR TO fraction(3));
	LET vregistro ="";
	LET vregistro1="";
	LET vregistro2="";
	LET vcliente ="";
					
	LET vlen =0;
	LET vpos="";
	LET vdia="";
	LET vmes="";
	LET vanio="";
	LET vf1mes="";
	LET vstatus="";
	LET vcodret="000";
    LET status_1="00";
    LET status_2="00";
    LET producto_sol = "";
    LET siglas_producto = "";
	LET cResultado = "";
	LET cMensajeRes = "";
	LET iSql_err        = 0 ;
	LET vpo1 = "";
	LET vecampo1 = "";
	LET vecampo2 = "";
	LET vecampo3 = "";
	LET vecampo4 = "";
	LET vecampo5 = "";
	LET vecampo6 = "";
	LET vecampo7 = "";
	LET vecampo8 = "";
	LET vecampo9 = "";
	LET vecampo10 = "";
	LET vecampo11 = "";
	LET vecampo12 = "";
	LET vecampo13 = "";
	LET vecampo14 = "";
	LET vecampo15 = "";
	LET vecampo16 = "";
	LET vecampo17 = "";
	LET vexiste = 0;
	LET vcodini = 0;
	LET vcodfin = 0;
	LET vdcampo1 = "";
	LET vdcampo2 = "";
	LET vdcampo3 = "";
	LET vdcampo4 = "";
	LET vdcampo5 = "";
	LET vdcampo6 = "";
	LET vdcampo7 = "";
	LET vdcampo8 = "";
	LET vdcampo9 = "";
	LET vdcampo10 = "";
	LET vdcampo11 = "";
	LET vdcampo12 = "";
	LET vscampo1 = "";
	LET vscampo2 = "";
	LET vscampo3 = "";
	LET vscampo3_1 = "";
	LET vscampo3_2 = "";
	LET vscampo4 = "";
	LET vscampo5 = "";
	LET vscampo6 = "";
	LET vscampo7 = "";
	LET vscampo8 = "";
	LET vscampo8a = 0;
	LET vscampo9 = "";
	LET vexiste1 = 0;
	LET vquita = "";
	LET vespacio = "";
	LET vmanzana = 0;
	LET vandador = 0;
	LET vlote = 0;
	LET vedificio = 0;
	LET ventrada = 0;
	LET vsecuencia = 0;
	LET vcomentario = "";

    LET vnumerocalle = 0;
	LET iFlag2credito = 0;
	
	LET valida_hit ="";
	LET wBegin = "N";
	
	LET cFlujo_cc = '0';
	LET status_consul ='';
	LET solicitudes_sic ='';
	LET cCanalSol = '';
	LET vConsAleat	= 0;	
	LET vFalloSIC	= 0;
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET vcodret = iSql_err;		
			RETURN vcodret,vcliente,pSolicitud,vregistro,vregistro1,vregistro2;
		END IF;
	END EXCEPTION;
	
	 ON EXCEPTION IN (-535)
      LET wBegin = "S";
     -- ROLLBACK WORK;
	 commit work;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;
 
begin work;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--set debug file to '/home/c90039427/burocred_apolo.out';
--trace on;
	
	SELECT fecha_hoy 
	INTO vfecha 
	FROM bdicred:"informix".sd_fechas
  WHERE empresa='001';
  
    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;
	
	IF vfecha < vfechaServ THEN
		LET vfecha = vfechaServ;
	END IF;
	
	IF psucursal = '0001' THEN   -- SE CAMBIA PARA QUE RECIBA 0001 AL IGUAL QUE EL SP QUE LE MANDA ESTA CADENA.
		SELECT numcte,num_producto
		INTO vcliente,producto_sol
		FROM bdicred:"informix".sd_maecred
		WHERE num_credito = pSolicitud
		AND empresa = pempresa;
		
		LET vstatus = pusuario;
	ELSE
						  
		SELECT a.numcte,a.num_producto,a.status_solicitud,NVL(c.flag2credito,0)
			INTO vcliente,producto_sol,vstatus, iFlag2credito
			FROM bdisolic:"informix".ss_solicitudes a
			INNER JOIN bdisolic:"informix".ss_resum_scor_fin b ON ( b.num_solicitud = a.num_solicitud) 
			LEFT  JOIN bdisolic:"informix".ss_revision_determinacion c ON ( c.num_solicitud = a.num_solicitud) 
			WHERE a.empresa = "001" 
			AND a.num_solicitud =pSolicitud;
		 
			--RQM 09 308 Se agrega validacion para cuando sea una solicitud aperturada se consulte la tabla de incremento
			IF vstatus = "AP" THEN
				SELECT DISTINCT(numcte),num_producto,status
				INTO vcliente,producto_sol,vstatus
				FROM  bdicred:"informix".sd_bitacora_aumlincred 
				WHERE empresa = "001" AND num_solicitud =pSolicitud
                AND fecha_insert = (SELECT MAX(fecha_insert)  FROM  bdicred:"informix".sd_bitacora_aumlincred 
                                     WHERE empresa = "001" AND num_solicitud =pSolicitud AND status IN ('BC','CC'));
			END IF;
		
	END IF;
		
	IF vstatus <> "BC" AND vstatus <> "CC" and psucursal = "8802" THEN
	    LET vstatus ="BC";
	END IF;
    IF TRIM(vstatus) = "RR" THEN
           LET vregistro="ERRRUR25";
           LET vcodret="260";
	  RETURN vcodret,vcliente,pSolicitud,vregistro,vregistro1,vregistro2;
    END IF
   -- Declaracion de Constantes para Generacion de Registros desea ver que significa cada campo
   -- Favor de consultar el manual -->
	LET vecampo1="INTL";
	LET vecampo2="11";
--- COLOCACION DE NUMERO DE SOLICITUD
	LET vecampo3 =pSolicitud||"     ";
	LET vecampo4="001";
	LET vecampo5="MX";
	LET vecampo6="0000";
	LET vecampo7    = "";
	LET vecampo8    = "";
	LET vecampo9="I";
	LET vecampo10="";	LET vecampo11="MX";
	LET vecampo12="0"; --monto solicitado
	LET vecampo13="SP";
	LET vecampo14="03";	LET vecampo15=" ";
	LET vecampo16="    ";
	LET vecampo17="0000000";
	LET vexiste=0;
	LET vcomentario = "";
-- Consulta las siglas correspondientes al producto solicitado
       SELECT codigo
         INTO siglas_producto
         FROM "informix".br_tltco
        WHERE num_producto = producto_sol;

        LET vecampo10 = siglas_producto;
		
--ini CAS consulta de institucion
		
		SELECT canal_sol INTO cCanalSol FROM bdisolic:"informix".ss_solicitudes 
		WHERE numcte = vcliente AND num_solicitud = pSolicitud;
		
		/*SELECT insti1 INTO status_consul FROM bdisolic:"informix".ss_canales_solic 
		WHERE canal_solic = cCanalSol;*/
		
		--Inicio: RQM 09 606 consulta sic aleatorio y Fallo de SIC
		--Tomar la ultima solicitud de la SIC
		SELECT institucion, FalloSIC, consul_aleatoria
			INTO status_consul, vFalloSIC, vConsAleat
			FROM bdisolic:"informix".ss_solicitudes_sic
			WHERE numcte= vcliente
				AND num_solicitud = pSolicitud
				AND fecha_insert = (SELECT MAX(fecha_insert)
						   FROM bdisolic:"informix".ss_solicitudes_sic
						   WHERE numcte= vcliente
							AND num_solicitud = pSolicitud);
		
		IF status_consul IS NULL THEN  --Valida que se tenga registro de la solicitud
			LET vregistro="NOSIC";
			LET vcodret="001";
			RETURN vcodret,vcliente,pSolicitud,vregistro,vregistro1,vregistro2;
		END IF;
		--Validar si la solicitud no trae fallo por ser BCScore
		/*IF status_consul = 'CC' AND vFalloSIC = 0 THEN
			--Validar si en el historial tiene envio a BC
			IF EXISTS (SELECT status_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = pSolicitud AND status_solicitud = 'BC') THEN
				LET status_consul = 'BC';--Es respuesta de BCScore
			END IF;
		END IF;*/
		--Fin: RQM 09 606 consulta sic aleatorio y Fallo de SIC
		
		IF status_consul = 'CC' THEN
			LET cFlujo_cc = '1';
		END IF;
		
		IF cFlujo_cc = '1' THEN
			SELECT status_solicitud
			INTO status_2
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="1";

			SELECT status_solicitud
			INTO status_1
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="2";
		
		ELSE
			SELECT status_solicitud
			INTO status_2
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="2";

			SELECT status_solicitud
			INTO status_1
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="1";
		
		END IF;
		
            IF vstatus="CC" THEN
                SELECT TRIM(valor) INTO vecampo7
                  FROM "informix".br_param
                  WHERE cod_param = 1;
                SELECT TRIM(valor) INTO vecampo8
                  FROM "informix".br_param
                  WHERE cod_param = 2;
--IPCB Marzo2016 RQM 09 398-0 FICO Extended				  
				SELECT  evalua_cc  INTO  valida_hit
                  FROM  bdisolic:ss_resum_scor_fin
                  WHERE num_solicitud = pSolicitud;
				
				--IF  valida_hit <> "X" THEN
				--IF  valida_hit IS NULL OR valida_hit <> "X" THEN
				--IPCBjul15 --FICO SCORE               
					IF cFlujo_cc = '0' THEN
					   SELECT TRIM(valor)INTO vecampo4
						  FROM bdiburo:br_param
						  WHERE cod_param = 141;
					ELSE
					--Consultar nuevo parametro de consulta a CC
                          /*SELECT TRIM(valor)INTO vecampo4
                              FROM bdiburo:br_param
                              WHERE cod_param = 152;*/
							  
						SELECT prodcc INTO vecampo4
						FROM bdisolic:"informix".ss_canales_solic 
						WHERE canal_solic = cCanalSol;
						
					END IF;
				--ELSE 
				--IPCB Marzo2016--FICO Extended	
              	/*SELECT TRIM(valor)INTO vecampo4
                  FROM bdiburo:br_param
                 WHERE cod_param = 142;
				END IF;*/
            ELIF vstatus='BC' THEN
			
				IF cFlujo_cc = '0' THEN
					SELECT TRIM(valor) INTO vecampo7
					  FROM "informix".br_param
					  WHERE cod_param = 124;
					SELECT TRIM(valor) INTO vecampo8
					  FROM "informix".br_param
					  WHERE cod_param = 125;
				
					IF iFlag2credito =1 THEN
						-- JMAH INI ICC
						SELECT TRIM(valor) INTO vecampo4
						FROM "informix".br_param
						WHERE cod_param = 11;
						-- JMAH INI BCSCORE
					ELSE				
						-- JOM INI BCSCORE
						SELECT TRIM(valor) INTO vecampo4
						FROM "informix".br_param
						WHERE cod_param = 126;

						-- JOM INI BCSCORE
					END IF;
					
				ELSE
					IF iFlag2credito =1 THEN
						SELECT TRIM(valor) INTO vecampo7
						  FROM "informix".br_param
					     WHERE cod_param = 124;
						 
						SELECT TRIM(valor) INTO vecampo8
					      FROM "informix".br_param
					     WHERE cod_param = 125;
						 
						-- JMAH INI ICC
						SELECT TRIM(valor) INTO vecampo4
						FROM "informix".br_param
						WHERE cod_param = 11;
						-- JMAH INI BCSCORE
					ELSE
						--Usuario Prospector
						select trim(valor) into vecampo7
						from bdiburo:br_param
						where cod_param = 154; 
						
						--Password Prospector
						select trim(valor) into vecampo8
						from bdiburo:br_param
						where cod_param = 155;   
						
						--Numero de producto Prospector
						select trim(valor) into vecampo4
						from bdiburo:br_param
						where cod_param = 153;  
					END IF;  
				END IF;
				
            END IF;
			
  LET vecampo12=LPAD(round(pMontoSol,0),9,"0");
  LET vregistro= vecampo1||vecampo2||vecampo3||vecampo4||vecampo5||
	     vecampo6||vecampo7||vecampo8||vecampo9||vecampo10||vecampo11||vecampo12||vecampo13||
	     vecampo14||vecampo15||vecampo16||vecampo17;
	-- Datos del Cliente --
	LET vdcampo1="PN"; --Identificador de cadena--
	LET vdcampo2=""; --Apellido Paterno PN--
	LET vdcampo3=""; --Apellido Materno 00--
	LET vdcampo4=""; --Primer Nombre 02--
	LET vdcampo5=""; --Segundo Nombre 03--
	LET vdcampo6=""; --Fecha de Nacimiento 04--
	LET vdcampo7=""; --RFC 05--
	LET vdcampo8="MX"; --Nacionalidad MX o EX 08--
	LET vdcampo9=""; --Residencia o Tipo Vivienda 09 1=Prop 2=Renta 3=Pension--
	LET vdcampo10=""; --Estado Civil 11 --
	LET vdcampo11=""; --Sexo 12--
	LET vdcampo12=""; --Dependiente 17--
	-- Direccion del Cliente --
	LET vscampo1="PA"; --Identificador de cadena--
	LET vscampo2=""; --Direccion Linea 1 PA--
	LET vscampo3=""; --Direccion Linea 2 00--
	LET vscampo3_1=""; --Direccion Linea 2 00--EXT
	LET vscampo3_2=""; --Direccion Linea 2 00--INT
	LET vscampo4=""; --Colonia o Poblacion 01--
	LET vscampo5=""; --Delegacion o Municipio 02--
	LET vscampo6=""; --Nombre Ciudad 03--
	LET vscampo7=""; --Estado 04--
	LET vscampo8=""; --Codigo Postal 05--
	LET vscampo9=""; --Tipo de Domicilio 10--

	SELECT TRIM(apell_paterno), TRIM(apell_materno), TRIM(nombre1),
  	        TRIM(nombre2),fecha_nac, CASE WHEN LENGTH(trim(rfc_alterno)) = 13 THEN rfc_alterno ELSE rfc END, TRIM(habita_en),
  	         TRIM(estado_civil),TRIM(sexo), NVL(dependientes,"0")
		    INTO vdcampo2,vdcampo3,vdcampo4,
                        vdcampo5,vdcampo6,vdcampo7,vdcampo9,
                        vdcampo10,vdcampo11,vdcampo12
		    FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b
		    WHERE a.numcte = b.numcte  AND b.numcte = vcliente;

	  -- Cambia las Ã de los Nombres y Apellidos --
         IF vdcampo2 IS NULL THEN LET vdcampo2 = ""; LET vcomentario = "Apellido paterno nulo"; END IF;
         IF vdcampo3 IS NULL THEN LET vdcampo3 = "NO PROPORCIONADO"; END IF;
         IF vdcampo4 IS NULL THEN LET vdcampo4 = ""; LET vcomentario = TRIM(vcomentario)||" Sin nombre"; END IF;
         IF vdcampo5 IS NULL THEN LET vdcampo5 = ""; END IF;
         IF vdcampo6 IS NULL THEN LET vdcampo6 = ""; END IF;
         IF vdcampo7 IS NULL THEN LET vdcampo7 = ""; END IF;
         IF vdcampo9 IS NULL THEN LET vdcampo9 = ""; END IF;
         IF vdcampo10 IS NULL THEN LET vdcampo10 = ""; END IF;
         IF vdcampo11 IS NULL THEN LET vdcampo11 = ""; END IF;
         IF vdcampo12 IS NULL THEN LET vdcampo12 = "0"; END IF;
         LET vexiste = LENGTH(vdcampo2);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo2[1,1]="~" OR vdcampo2[1,1]=" " OR vdcampo2[1,1]="." OR
           vdcampo2[1,1]="-"  THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo2[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo2[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo2 = vdcampo2[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo2 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo3);
     --- CAMBIO DE APELLIDO MATERNO
         IF vexiste = 0 THEN
            LET vdcampo3 = "NO PROPORCIONADO";
            LET vexiste = LENGTH(vdcampo3);
         END IF
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo3[1,1]="~" OR vdcampo3[1,1]=" " OR vdcampo3[1,1]="." OR
            vdcampo3[1,1]="-" THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo3[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo3[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo3 = vdcampo3[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo3 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo4);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo4[1,1]="~" OR vdcampo4[1,1]=" "  OR vdcampo4[1,1]="." OR
            vdcampo4[1,1]="-" THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo4[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo4[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo4 = vdcampo4[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo4 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo5);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio =" ";
         WHILE vexiste1 < vexiste
           IF vdcampo5[1,1]="~" OR vdcampo5[1,1]=" " OR vdcampo5[1,1]="." OR
            vdcampo5[1,1]="-" THEN
              LET vespacio ="F";
           ELSE
            IF vespacio = "F" THEN
               IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo5[1,1];
               END IF
	       LET vespacio ="";
            ELSE
               IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo5[1,1];
               END IF
            END IF
           END IF;
           LET vdcampo5 = vdcampo5[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo5 = TRIM(vquita);
         IF vdcampo9 ="P" OR vdcampo9 ="G" THEN
	       	   LET vdcampo9="1";
	 ELSE
	   IF vdcampo9 ="R" THEN 
	    LET vdcampo9="2";
	   ELSE
	     IF vdcampo9 ="F"  OR vdcampo9 = "H" THEN 
	       LET vdcampo9="3";
	     ELSE
	      LET vdcampo9="";
	     END IF
	   END IF
	 END IF
         IF vdcampo10 ="D" THEN
	       	   LET vdcampo10="D";
	 ELSE
	   IF vdcampo10 ="U" THEN
	    LET vdcampo10="F";
	   ELSE
	     IF vdcampo10 ="C" THEN
	       LET vdcampo10="M";
	     ELSE
	      IF vdcampo10 ="S" THEN
	         LET vdcampo10="S";
	      ELSE
	         IF vdcampo10 ="V" THEN
		    LET vdcampo10="W";
	         END IF
	      END IF
	     END IF
	   END IF
	 END IF
	-- Carga los datos de la Direccion del Cliente --
    --SELECT MAX(secuencia) INTO vsecuencia
    --  FROM bdinteg:"informix".si_direcciones
	--           WHERE  numcte=vcliente AND tipo_dir='1';


     -- SELECT TRIM(f.nombrecalle),
	  SELECT trim(f.nombrecalle), --case when substr(f.nombrecalle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(f.nombrecalle) else trim(f.nombrecalle) end nombrecalle,
          -- REPLACE(NVL(TRIM(a.numeroextcalle)," ")||" "||NVL(TRIM(a.numerointcalle)," "),'	',''),--Se quitan los tabuladores INC 21 119
		   REPLACE(NVL(TRIM(a.numeroextcalle)," "),'	',''),
		   REPLACE(NVL(TRIM(a.numerointcalle)," "),'	',''),
           TRIM(g.nombrezona), 
       TRIM(g.municipiozona), TRIM(c.estado), lpad(TRIM(a.cod_postal),5,"0"), a.tipo_dir,
           manzana,andador,lote,edificio,entrada,codini,codfin, nvl(a.numerocalle,0)
       INTO   vscampo2, vscampo3_1,vscampo3_2, vscampo4,
              vscampo6, vscampo7,vscampo8,vscampo9,
              vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin, vnumerocalle
       FROM  bdinteg:"informix".si_direcciones_actual as a,
                 bdisolic:"informix".ss_circulo_edos as c,
                 bdinteg:"informix".si_catcalles f,
                 bdinteg:"informix".si_catzonas g
       WHERE  a.numcte=vcliente 
        AND a.tipo_dir = '1' 
        AND c.clave = a.estado 
        AND g.numerociudad = a.numerociudad
        AND f.numerocalle = a.numerocalle
        AND g.mnpio_spmx <> ''
        AND g.nombrezona= upper (a.colonia)           
        LIMIT 1;

	      LET vscampo4 = REPLACE(REPLACE(vscampo4, '(' ,''), ')', '');
		IF (vscampo2 is null or vnumerocalle = 0) and (SELECT COUNT(num_solicitud) 					
				FROM bdisolic:"informix".ss_solicitudes_movil							
				WHERE 	empresa  = pEmpresa 
				AND  num_solicitud = pSolicitud
				AND status <> '3' ) > 0 THEN				
				
                --SELECT TRIM(a.calle),
				SELECT trim(a.calle), --case when substr(a.calle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(a.calle) else trim(a.calle) end nombrecalle,
                --REPLACE(NVL(TRIM(a.numeroextcalle)," ")||" "||NVL(TRIM(a.numerointcalle)," "),'	',''),--Se quitan los tabuladores INC 21 119
				REPLACE(NVL(TRIM(a.numeroextcalle)," "),'	',''),
				REPLACE(NVL(TRIM(a.numerointcalle)," "),'	',''),
                TRIM(g.nombrezona), 
                TRIM(g.municipiozona), TRIM(c.estado), lpad(TRIM(a.cod_postal),5,"0"), a.tipo_dir,
                manzana,andador,lote,edificio,entrada,codini,codfin 
                INTO   vscampo2, vscampo3_1,vscampo3_2, vscampo4,
                vscampo6, vscampo7,vscampo8,vscampo9,
                vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin
                FROM  bdinteg:"informix".si_direcciones_actual as a,
                     bdisolic:"informix".ss_circulo_edos as c,					 
                     bdinteg:"informix".si_catzonas g
                WHERE  a.numcte=vcliente AND a.tipo_dir = '1' 
                AND c.clave = a.estado 
                AND g.numerociudad = a.numerociudad
                AND g.numerocolonia = a.numerocolonia;	
	        LET vscampo4 = REPLACE(REPLACE(vscampo4, '(' ,''), ')', '');
		END IF;	

		IF (substr(vscampo2,1,1) in('0','1','2','3','4','5','6','7','8','9')) then 
			LET vscampo2 = "CALLE "||trim(vscampo2);
		END IF;
	
	   	
       IF vscampo2 IS NULL THEN LET vscampo2 = "";  LET vcomentario = TRIM(vcomentario)||" Sin calle "; END IF;
       --IF vscampo3 IS NULL THEN LET vscampo3 = ""; END IF;
	   IF    vscampo3_1 IS NULL     OR nvl(vscampo3_1,'') = ''    OR nvl(vscampo3_1,'') = 'S/N' or
		 nvl(vscampo3_1,'') = 'S/n' or nvl(vscampo3_1,'') = 's/N' or nvl(vscampo3_1,'') = 's/n' or
				vscampo3_1 = '0'   or         vscampo3_1 = '00'  or     vscampo3_1 = '000'     or 
				vscampo3_1 = '0000' THEN  LET vscampo3_1 = "SN"; END IF;
				 
	   IF    vscampo3_2 IS NULL     OR nvl(vscampo3_2,'') = ''    OR nvl(vscampo3_2,'') = 'S/N' or
	     nvl(vscampo3_2,'') = 'S/n' or nvl(vscampo3_2,'') = 's/N' or nvl(vscampo3_2,'') = 's/n' or
                 vscampo3_2 = '0'   or         vscampo3_2 = '00'  or     vscampo3_2 = '000'     or 
				 vscampo3_2 = '0000' THEN  LET vscampo3_2 = "SN"; END IF;
				 
	   LET vscampo3=  REPLACE(NVL(TRIM(vscampo3_1)," ")||" "||NVL(TRIM(vscampo3_2)," "),'	','');
       IF vscampo4 IS NULL THEN LET vscampo4 = ""; END IF;
       IF vscampo5 IS NULL THEN LET vscampo5 = ""; END IF;
       IF vscampo6 IS NULL THEN LET vscampo6 = ""; LET vcomentario = TRIM(vcomentario)||" Sin localidad "; END IF;
       IF vscampo7 IS NULL THEN LET vscampo7 = ""; LET vcomentario = TRIM(vcomentario)||" Sin estado "; END IF;
       IF vscampo8 IS NULL THEN LET vscampo8 = ""; LET vcomentario = TRIM(vcomentario)||" Sin codigo postal "; END IF;
       IF vscampo9 IS NULL THEN LET vscampo9 = ""; END IF;
       LET vscampo2 = TRIM(vscampo2)||" "||TRIM(vscampo3);
       LET vexiste = LENGTH(vscampo2);
       IF vexiste < 40 THEN
         LET vscampo3 = "";
         IF vmanzana > 0 THEN
           LET vscampo3 ="mza "||vmanzana;
         END IF
         IF vandador > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"AND "||vandador;
         END IF
         IF vlote > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"lt "||vlote;
         END IF
         IF vedificio > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"ed "||vedificio;
         END IF
         IF ventrada > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"ent "||ventrada;
         END IF
       LET vscampo2 = TRIM(vscampo2)||' '||TRIM(vscampo3);
       END IF
       LET vscampo2 = TRIM(vscampo2);
       LET vexiste = LENGTH(vscampo2);
       LET vexiste1 = 0;
       LET vquita = "";
       LET vespacio = " ";
       WHILE vexiste1 < vexiste
        IF vscampo2[1,1]="~" OR vscampo2[1,1]=" " OR vscampo2[1,1]="." OR
         vscampo2[1,1]="-" THEN
           LET vespacio = "F";
        ELSE
          IF vespacio = "F" THEN
            IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "Â¥" THEN
              LET vquita = TRIM(vquita)||" Ã";
            ELSE
              LET vquita = TRIM(vquita)||" "||vscampo2[1,1];
            END IF
            LET vespacio = "";
          ELSE
            IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "Â¥" THEN
              LET vquita = TRIM(vquita)||"Ã";
            ELSE
              LET vquita = TRIM(vquita)||vscampo2[1,1];
            END IF
          END IF
        END IF;
        LET vscampo2 = vscampo2[2,40];
        LET vexiste1 = vexiste1 + 1;
       END WHILE;
       LET vscampo2 = TRIM(vquita);
       IF vscampo9 ="1" THEN
	   LET vscampo9="H";
       ELSE
         IF vscampo9 ="2" THEN
           LET vscampo9="B";
         ELSE
           LET vscampo9="H";
         END IF
       END IF

    LET vregistro=TRIM(vregistro)||vdcampo1;
    LET vlen=LENGTH(vdcampo2);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||vpos||vdcampo2;
    LET vlen=LENGTH(vdcampo3);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"00"||vpos||vdcampo3;
    LET vlen=LENGTH(vdcampo4);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"02"||vpos||vdcampo4;
    LET vlen=LENGTH(vdcampo5);
    LET vpos=LPAD(vlen,2,"0");
    IF vlen  > 0 THEN
      LET vregistro=TRIM(vregistro)||"03"||vpos||vdcampo5;
    END IF

    LET vlen=LENGTH(vdcampo6);
    IF vlen  > 0 THEN
    LET vdia=vdcampo6[4,5];
    LET vdia=LPAD(vdia,2,"0");
    LET vmes=vdcampo6[1,2];
    LET vmes=LPAD(vmes,2,"0");
    LET vanio=vdcampo6[7,10];
    LET vdcampo6=vdia||vmes||vanio;
    LET vlen=LENGTH(vdcampo6);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"04"||vpos||vdcampo6;
    END IF;
    LET vlen=LENGTH(vdcampo7);
    IF vlen  > 0 THEN
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"05"||vpos||vdcampo7;
    END IF;
    LET vlen=LENGTH(vdcampo8);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"08"||vpos||vdcampo8;
 --- Este es el campo correspondiente a la residencia
    IF vdcampo9 = "1" OR vdcampo9 = "2" OR vdcampo9 = "3" THEN
     LET vlen=LENGTH(vdcampo9);
     LET vpos=LPAD(vlen,2,"0");
     LET vregistro=TRIM(vregistro)||"09"||vpos||vdcampo9;
    END IF
    LET vlen =LENGTH(vdcampo10);
    IF vlen  > 0 THEN
      LET vpos=LPAD(vlen,2,"0");
      LET vregistro=TRIM(vregistro)||"11"||vpos||vdcampo10;
    END IF
    LET vlen=LENGTH(vdcampo11);
    IF vlen  > 0 THEN
      LET vpos=LPAD(vlen,2,"0");
      LET vregistro=TRIM(vregistro)||"12"||vpos||vdcampo11;
    END IF
    IF TRIM(vdcampo12) != "0" THEN
       IF LENGTH(TRIM(vdcampo12)) < 2 THEN
         LET vdcampo12 = "0"||TRIM(vdcampo12);
       END IF
       LET vlen=LENGTH(vdcampo12);
       LET vpos=LPAD(vlen,2,"0");
       LET vregistro=TRIM(vregistro)||"17"||vpos||vdcampo12;
    ELSE
       LET vregistro=TRIM(vregistro)||"170201";
    END IF
    LET vregistro=TRIM(vregistro)||vscampo1;
    LET vlen=LENGTH(vscampo2);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro1=vpos||vscampo2;
    LET vscampo3 = "";
    LET vexiste = LENGTH(vscampo3);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo3[1,1]="~" OR vscampo3[1,1]=" " OR vscampo3[1,1]="." OR
      vscampo3[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "Â¥" THEN
           LET vquita = TRIM(vquita)||" Ã";
        ELSE
           LET vquita = TRIM(vquita)||" "||vscampo3[1,1];
        END IF
	LET vespacio = "";
      ELSE
        IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "Â¥" THEN
	   LET vquita = TRIM(vquita)||"Ã";
        ELSE
	   LET vquita = TRIM(vquita)||vscampo3[1,1];
        END IF
      END IF
     END IF;
     LET vscampo3 = vscampo3[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo3 = TRIM(vquita);
    LET vlen=LENGTH(vscampo3);
    LET vpos=LPAD(vlen,2,"0");
    --LET vregistro1='00'||vpos|| vscampo3;
    LET vexiste = LENGTH(vscampo4);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo4[1,1]="~" OR vscampo4[1,1]=" " OR vscampo4[1,1]="." OR
      vscampo4[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||" Ã";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo4[1,1];
        END IF
        LET vespacio = "";
      ELSE
        IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||"Ã";
        ELSE
	  LET vquita = TRIM(vquita)||vscampo4[1,1];
        END IF
      END IF
     END IF;
     LET vscampo4 = vscampo4[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo4= TRIM(vquita);
    LET vlen=LENGTH(vscampo4);
    LET vpos= LPAD(vlen,2,"0");
    IF vlen > 0 THEN
    LET vregistro1= TRIM(vregistro1)||"01"||vpos|| vscampo4;
    END IF
{    LET vexiste = LENGTH(vscampo5);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo5[1,1]="~" OR vscampo5[1,1]=" " OR vscampo5[1,1]="." THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo5[1,1] = "#" OR vscampo5[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||" Ã ";
	  LET vespacio = "";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo5[1,1];
	  LET vespacio = "";
        END IF
      ELSE
        IF vscampo5[1,1] = "#" OR vscampo5[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||"Ã";
        ELSE
	  LET vquita = TRIM(vquita)||vscmpo5[1,1];
        END IF
      END IF
     END IF;
     LET vscampo5 = vscampo5[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo5 = TRIM(vquita);
    LET vlen= LENGTH(vscampo5);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro1= TRIM(vregistro1)||'02'||vpos||vscampo5;
}
    LET vexiste = LENGTH(vscampo6);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo6[1,1]="~" OR vscampo6[1,1]=" " OR vscampo6[1,1]="." OR
      vscampo6[1,1]="-" THEN
       LET vespacio = "F";
       LET vexiste1 = vexiste1 + 1;
       LET vscampo6 = vscampo6[2,26];
     ELSE
      IF vespacio = "F" THEN
        IF vscampo6[1,22] = "MUNICIPIO DE ( OTROS )" THEN
	    LET vquita = TRIM(vquita);
            LET vexiste1 = vexiste1 + 22;
            LET vscampo6 = vscampo6[23,26];
        ELSE
          IF vscampo6[1,12] = "MUNICIPIO DE"  THEN
	    LET vquita = TRIM(vquita);
            LET vexiste1 = vexiste1 + 12;
            LET vscampo6 = vscampo6[13,26];
          ELSE
           IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "Â¥" THEN
	     LET vquita = TRIM(vquita)||" Ã";
           ELSE
	     LET vquita = TRIM(vquita)||" "||vscampo6[1,1];
           END IF
	   LET vespacio = "";
           LET vexiste1 = vexiste1 + 1;
           LET vscampo6 = vscampo6[2,26];
          END IF;
        END IF;
      ELSE
        IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||"Ã";
        ELSE
	  LET vquita = TRIM(vquita)||vscampo6[1,1];
        END IF
        LET vexiste1 = vexiste1 + 1;
        LET vscampo6 = vscampo6[2,26];
      END IF
     END IF;
    END WHILE;
    LET vscampo6 = TRIM(vquita);
    LET vlen= LENGTH(vscampo6);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro1= TRIM(vregistro1)||"03"||vpos||vscampo6;
    LET vexiste = LENGTH(vscampo7);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo7[1,1]="~" OR vscampo7[1,1]=" " OR vscampo7[1,1]="." OR
      vscampo7[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||" Ã";
          LET vespacio = "";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo7[1,1];
	  LET vespacio = "";
        END IF
      ELSE
        IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "Â¥" THEN
	   LET vquita = TRIM(vquita)||vscampo7[1,1];
        ELSE
	   LET vquita = TRIM(vquita)||vscampo7[1,1];
        END IF
      END IF
     END IF;
     LET vscampo7 = vscampo7[2,4];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo7 = TRIM(vquita);
    LET vlen= LENGTH(vscampo7);
    LET vpos= LPAD(vlen,2,"0");
    LET vregistro1= TRIM(vregistro1)||"04"||vpos||vscampo7;
{    IF vscampo8[1,1] = 1 OR vscampo8[1,1] = 2 OR vscampo8[1,1] = 3 OR vscampo8[1,1] = 4 OR vscampo8[1,1] = 5 OR vscampo8[1,1] = 6 OR
     vscampo8[1,1] = 7 OR vscampo8[1,1] = 8 OR vscampo8[1,1] = 9  THEN
      LET vscampo8a = vscampo8[1,1] * 10000;
    ELSE
      LET vscampo8a = 0;
    END IF
    IF vscampo8[2,2] = 1 OR vscampo8[2,2] = 2 OR vscampo8[2,2] = 3 OR vscampo8[2,2] = 4 OR vscampo8[2,2] = 5 OR vscampo8[2,2] = 6 OR
     vscampo8[2,2] = 7 OR vscampo8[2,2] = 8 OR vscampo8[2,2] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[2,2] * 1000;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[3,3] = 1 OR vscampo8[3,3] = 2 OR vscampo8[3,3] = 3 OR vscampo8[3,3] = 4 OR vscampo8[3,3] = 5 OR vscampo8[3,3] = 6 OR
     vscampo8[3,3] = 7 OR vscampo8[3,3] = 8 OR vscampo8[3,3] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[3,3] * 100;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[4,4] = 1 OR vscampo8[4,4] = 2 OR vscampo8[4,4] = 3 OR vscampo8[4,4] = 4 OR vscampo8[4,4] = 5 OR vscampo8[4,4] = 6 OR
     vscampo8[4,4] = 7 OR vscampo8[4,4] = 8 OR vscampo8[4,4] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[4,4] * 10;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[5,5] = 1 OR vscampo8[5,5] = 2 OR vscampo8[5,5] = 3 OR vscampo8[5,5] = 4 OR vscampo8[5,5] = 5 OR vscampo8[5,5] = 6 OR
     vscampo8[5,5] = 7 OR vscampo8[5,5] = 8 OR vscampo8[5,5] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[5,5] ;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8a < vcodini OR vscampo8a > vcodfin THEN
       LET vscampo8 = LPAD(round(vcodini),5,"0");
    END IF }
    LET vlen= LENGTH(vscampo8);
    LET vpos= LPAD(vlen,2,"0");
    LET vregistro2='05'||vpos||vscampo8;
    LET vlen= LENGTH(vscampo9);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro2=TRIM(vregistro2)||'10'||vpos||vscampo9;
    -- Marca el FIN de Trailer -->
   LET vlen= LENGTH(vregistro)+LENGTH(vregistro1)+LENGTH(vregistro2);
   LET vlen= TRUNC(vlen + 15);
   LET vpo1= LPAD(vlen,5,'0');
   LET vregistro2=TRIM(vregistro2)||'ES05'||vpo1||'0002**';
   LET vregistro = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(vregistro, 'Ã', 'N'), 'Ã±', 'N'), '#','N'), '$', 'N'),'%', 'N' );
   LET vregistro1 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(vregistro1, 'Ã', 'N'), 'Ã±', 'N'), '#','N'), '$', 'N'),'%', 'N' );
   
--INI CAS CAMBIO DE ORDEN DE CONSULTA BURO Y CIRCULO
   IF vstatus=status_1 THEN
		   ---mandamos llamar el sp para respaldar la informaciÃ³n de la consulta previa a buro del cliente       --JMAH
		    EXECUTE PROCEDURE "informix".sp_generarespaldoshistoricosic(vcliente,pSolicitud,status_1,1) INTO cResultado,cMensajeRes;	
			EXECUTE PROCEDURE "informix".sp_generarespaldoshistoricosic(vcliente,pSolicitud,status_2,1) INTO cResultado,cMensajeRes;
   
				DELETE FROM "informix".br_traslado WHERE num_solicitud = pSolicitud;
				DELETE FROM "informix".sb_regreso WHERE num_solicitud = pSolicitud;
		--IPCB Mayo2016 Reingenieria de Demonios.
				DELETE FROM "informix".br_respuesta WHERE num_solicitud = pSolicitud;
				DELETE FROM "informix".br_respuesta_aprocesar WHERE num_solicitud = pSolicitud;   
				DELETE FROM "informix".br_respuesta_aprocesar_aux WHERE num_solicitud = pSolicitud; 			
		--IPCB Mayo2016 Reingenieria de Demonios.
					   
				--ini cas
				DELETE FROM "informix".br_cr WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_hi WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_hr WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_iq WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_pa WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_pe WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_pn WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_rs WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_sc WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_tl WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_ar WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_ur WHERE institucion in ('BC','CC') AND num_cliente= vcliente;
		  DELETE FROM "informix".br_es WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_error WHERE institucion in ('BC','CC') AND num_cliente= vcliente;
			--fin cas
			IF psucursal = "0001" THEN --JMAH
				DELETE FROM "informix".br_cr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hi_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_iq_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pa_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pe_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pn_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_rs_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_sc_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_tl_bc WHERE institucion = status_2 AND num_cliente= vcliente;  
			END IF;
           UPDATE "informix".br_auditor SET comentario = "" WHERE institucion=status_1 AND solicitud = pSolicitud;

           IF LENGTH(NVL(vcomentario,"")) = 0 THEN
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_1,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,2,vfecha);
           ELSE
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_1,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,4,vfecha);
             INSERT INTO "informix".br_auditor VALUES(status_1,pSolicitud,vfecha,vhora,vcomentario);
           END IF
    ELSE
			---mandamos llamar el sp para respaldar la informaciÃ³n de la consulta previa a buro del cliente       --JMAH
			EXECUTE PROCEDURE "informix".sp_generarespaldoshistoricosic(vcliente,pSolicitud,status_2,1) INTO cResultado,cMensajeRes;																													  
																														   
			
				DELETE FROM "informix".br_traslado WHERE institucion = status_2 AND num_solicitud = pSolicitud;
				DELETE FROM "informix".sb_regreso WHERE institucion = status_2 AND num_solicitud = pSolicitud;
	--IPCB Mayo2016 Reingenieria de Demonios.
				DELETE FROM "informix".br_respuesta WHERE institucion = status_2 AND num_solicitud = pSolicitud;
				DELETE FROM "informix".br_respuesta_aprocesar WHERE institucion = status_2 AND num_solicitud = pSolicitud;
				DELETE FROM "informix".br_respuesta_aprocesar_aux WHERE institucion = status_2 AND num_solicitud = pSolicitud;		
	--IPCB Mayo2016 Reingenieria de Demonios.		
				
				--ini cas
				DELETE FROM "informix".br_cr WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_hi WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_hr WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_iq WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_pa WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_pe WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_pn WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_rs WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_sc WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_tl WHERE institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_ar WHERE  institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_ur WHERE  institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_es WHERE  institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_error WHERE institucion=status_2 AND num_cliente= vcliente;
			IF psucursal = "0001" THEN --JMAH
				DELETE FROM "informix".br_cr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hi_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_iq_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pa_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pe_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pn_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_rs_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_sc_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_tl_bc WHERE institucion = status_2 AND num_cliente= vcliente;
			END IF;
		
           UPDATE "informix".br_auditor set comentario = "" WHERE solicitud = pSolicitud;

           IF LENGTH(NVL(vcomentario,"")) = 0 THEN
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_2,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,2,vfecha);
           ELSE
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_2,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,4,vfecha);
             INSERT INTO "informix".br_auditor VALUES(status_2,pSolicitud,vfecha,vhora,vcomentario);
           END IF;
    END IF;
--FIN CAS CAMBIO DE ORDEN DE CONSULTA BURO Y CIRCULO
   LET vexiste1 = 0;
   LET vexiste = 10;

	COMMIT WORK;
	IF wbegin = 'S' THEN
	    BEGIN WORK;
	END IF;
RETURN vcodret,vcliente,pSolicitud,vregistro,vregistro1,vregistro2;

END;
END PROCEDURE
DOCUMENT

' Autor: Kevin JesÃºs GarcÃ­a RÃ­os' ,
' ModificaciÃ³n: Se versiona burocred para retornar tramas de buro' ,
' Fecha: 22-03-2024' ,
' Proyecto: Apolo Onboarding (Unity)' ,
'----------------------------------------------------------------------------------';


create procedure            "informix".ins_consulta_buropba( pempresa char(03),
psucursal char(03), pusuario char(08),pnum_solicitud char(20));
--returning char(5);
--------- Declaraciones   Generales
define inicio int;
define item_cadena int;
define item_valor  int;
define etiqueta_size int;
define tamamax int;
define tamares int;
define tamafin int;
define longitud_etiqueta int;
define etiqueta char(04);
define valor_cadena lvarchar;
define sql_err int;
define paso varchar(10);
define salva char(04);
define i int;
define fecha date;
define encuentra int;
define bandera int;
define continua int;
define cod_ret char(5);
define pnum_cliente char(20);
define vhora datetime hour to fraction(3);
---- Deficicion tabla br_pn
define pnpn varchar(26);
define pn00 varchar(26);
define pn01 varchar(26);
define pn02 varchar(26);
define pn03 varchar(26);
define pn04 varchar(8);
define pn05 varchar(13);
define pn06 varchar(04);
define pn07 varchar(04);
define pn08 char(02);
define pn09 char(1);
define pn10 varchar(20);
define pn11 char(1);
define pn12 char(1);
define pn13 varchar(20);
define pn14 varchar(20);
define pn15 varchar(20);
define pn16 char(2);
define pn17 char(2);
define pn18 varchar(30);
define pn19 varchar(8);
define pn20 varchar(8);
---- Deficicion tabla br_pa
define papa varchar(40);
define pa00 varchar(40);
define pa01 varchar(40);
define pa02 varchar(40);
define pa03 varchar(40);
define pa04 varchar(04);
define pa05 char(05);
define pa06 char(8);
define pa07 varchar(11);
define pa08 varchar(08);
define pa09 varchar(11);
define pa10 char(1);
define pa11 char(1);
define pa12 char(8);
---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_papa varchar(40);
---- Deficicion tabla br_pe
define pepe varchar(40);
define pe00 varchar(40);
define pe01 varchar(40);
define pe02 varchar(40);
define pe03 varchar(40);
define pe04 varchar(40);
define pe05 varchar(04);
define pe06 char(05);
define pe07 varchar(11);
define pe08 varchar(08);
define pe09 varchar(11);
define pe10 varchar(30);
define pe11 char(08);
define pe12 char(02);
define pe13 varchar(09);
define pe14 varchar(01);
define pe15 varchar(15);
define pe16 char(08);
define pe17 char(08);
define pe18 char(08);
define pe19 char(01);
---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_pepe varchar(40);
---- Deficicion tabla br_tl
define tltl char(08);
define tl00 char(04);
define tl01 char(10);
define tl02 varchar(16);
define tl03 varchar(11);
define tl04 varchar(25);
define tl05 char(01);
define tl06 char(01);
define tl07 char(02);
define tl08 char(02);
define tl09 varchar(09);
define tl10 varchar(04);
define tl11 char(1);
define tl12 varchar(9);
define tl13 char(08);
define tl14 char(08);
define tl15 char(08);
define tl16 char(08);
define tl17 char(08);
define tl18 char(01);
define tl19 char(08);
define tl20 varchar(40);
define tl21 varchar(09);
define tl22 varchar(09);
define tl23 varchar(09);
define tl24 varchar(09);
define tl25 varchar(04);
define tl26 char(02);
define tl27 varchar(24);
define tl28 char(08);
define tl29 char(08);
define tl30 char(02);
define tl31 char(03);
define tl32 char(02);
define tl33 char(02);
define tl34 char(02);
define tl35 char(02);
define tl36 varchar(09);
define tl37 char(08);
define tl38 char(02);
define tl42 char(08);
---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_tltl char(08);
---- Deficicion tabla br_iq
define iqiq  char(08);
define iq00 char(04);
define iq01 char(10);
define iq02 varchar(16);
define iq03 varchar(11);
define iq04 char(02);
define iq05 char(02);
define iq06 varchar(09);
define iq07 char(01);
define iq08 char(01);
define iq09 varchar(25);
---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_iqiq char(08);
define entro char(1);
---- Deficicion tabla br_rs
define rsrs char(08);
define rs00 char(02);
define rs01 char(02);
define rs02 char(02);
define rs03 char(02);
define rs04 char(02);
define rs05 char(02);
define rs06 char(02);
define rs07 char(02);
define rs08 char(02);
define rs09 char(04);
define rs10 varchar(04);
define rs11 char(04);
define rs12 char(04);
define rs13 char(04);
define rs14 char(04);
define rs15 char(02);
define rs16 char(02);
define rs17 char(01);
define rs18 char(08);
define rs19 char(01);
define rs20 char(02);
define rs21 varchar(09);
define rs22 varchar(09);
define rs23 varchar(10);
define rs24 varchar(09);
define rs25 varchar(09);
define rs26 varchar(03);
define rs27 varchar(09);
define rs28 varchar(10);
define rs29 varchar(09);
define rs30 varchar(09);
define rs31 char(02);
define rs32 char(02);
define rs33 char(02);
define rs34 char(08);
define rs35 char(08);
define rs36 char(02);
define rs37 char(08);
define rs38 char(02);
define rs39 char(08);
define rs40 char(02);
define rs41 char(08);
---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_rsrs char(08);
---- Deficicion tabla br_hi
define hihi char(08);
define hi00 char(03);
define hi01 varchar(16);
define hi02 varchar(48);
---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_hihi char(08);
---- Deficicion tabla br_hr
define hrhr char(08);
define hr00 char(03);
define hr01 varchar(16);
define hr02 varchar(48);
---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_hrhr char(08);
---- Deficicion tabla br_cr
define crcr varchar(04);
define cr00 lvarchar;
---- Deficicion tabla br_sc
define scsc  varchar(30);
define sc00 varchar(03);
define sc01 varchar(04);
define sc02 varchar(03);
define sc03 varchar(03);
define sc04 varchar(03);
define sc06 varchar(02);
---- Campo para respaldar valor cuando hay mas de una insidencia de un concepto
define respalda_scsc varchar(30);
---- Etiqueta Error ERRRUR25
define verrorburo char(8);
define nrows smallint;
define vfecha_hoy date;
define pcadena char(250);
define pcadena1 char(250);
define pcadena2 char(250);
define regre smallint;
define varchivo char(200);
define vstatus char(1);
let varchivo = "/pisa/pisabanco/pisa_ftes/ins_consutl"||pnum_solicitud;
--set debug file to varchivo;
--trace on;
select fecha_hoy into vfecha_hoy from bdicred:sd_fechas;
let verrorburo = "";
let vhora = extend(current,hour to fraction(3));
let nrows = 0;
let tamamax = 0;
let pnum_solicitud = pnum_solicitud;
select status into vstatus
from sb_regreso
  where num_solicitud = pnum_solicitud;
if vstatus = "3" then
insert into br_auditor values(pnum_solicitud,vfecha_hoy,vhora,"Problemas de coneccion");
return;
end if
select length(regreso) into tamamax
from sb_regreso
  where num_solicitud = pnum_solicitud;
if tamamax is null then
   let tamamax = 0;
else
   let tamamax = tamamax -1;
end if
if tamamax = 0 then
insert into br_auditor values(pnum_solicitud,vfecha_hoy,vhora,"Problemas de coneccion");
return;
end if
if tamamax > 251 then
  select substr(regreso,1,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  select substr(regreso,1,tamamax) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
insert into br_auditor values(pnum_solicitud,vfecha_hoy,vhora,"");
----  Inicializaciòn de valores para tabla br_pn
let pnpn = " ";
let pn00 = " ";
let pn01 = " ";
let pn02 = " ";
let pn03 = " ";
let pn04 = null;
let pn05 = " ";
let pn06 = " ";
let pn07 = " ";
let pn08 = " ";
let pn09 = " ";
let pn10 = " ";
let pn11 = " ";
let pn12 = " ";
let pn13 = " ";
let pn14 = " ";
let pn15 = " ";
let pn16 = " ";
let pn17 = " ";
let pn18 = " ";
let pn19 = null;
let pn20 = null;

----  Inicializaciòn de valores para tabla br_pa
let papa = " ";
let pa00 = " ";
let pa01 = " ";
let pa02 = " ";
let pa03 = " ";
let pa04 = " ";
let pa05 = " ";
let pa06 = null;
let pa07 = " ";
let pa08 = " ";
let pa09 = " ";
let pa10 = " ";
let pa11 = " ";
let pa12 = null;

----  Inicializaciòn de valores para tabla br_pe
let pepe = " ";
let pe00 = " ";
let pe01 = " ";
let pe02 = " ";
let pe03 = " ";
let pe04 = " ";
let pe05 = " ";
let pe06 = " ";
let pe07 = " ";
let pe08 = " ";
let pe09 = " ";
let pe10 = " ";
let pe11 = null;
let pe12 = " ";
let pe13 = 0;
let pe14 = " ";
let pe15 = " ";
let pe16 = null;
let pe17 = null;
let pe18 = null;
let pe19 = " ";

----  Inicializaciòn de valores para tabla br_tl
let tltl = null;
let tl00 = " ";
let tl01 =  " ";
let tl02 =  " ";
let tl03 =  " ";
let tl04 =  " ";
let tl05 =  " ";
let tl06 =  " ";
let tl07 =  " ";
let tl08 =  " ";
let tl09 =  0;
let tl10 =  0;
let tl11 =  " ";
let tl12 =  0;
let tl13 = null;
let tl14 = null;
let tl15 = null;
let tl16 = null;
let tl17 = null;
let tl18 =  " ";
let tl19 = null;
let tl20 =  " ";
let tl21 =  0;
let tl22 =  0;
let tl23 =  0;
let tl24 =  0;
let tl25 =  0;
let tl26 =  " ";
let tl27 =  " ";
let tl28 = null;
let tl29 = null;
let tl30 =  " ";
let tl31 =  0;
let tl32 =  0;
let tl33 =  0;
let tl34 =  0;
let tl35 =  0;
let tl36 =  0;
let tl37 = null;
let tl38 =  " ";
let tl42 = null;

----  Inicializaciòn de valores para tabla br_iq
let iqiq = null;
let iq00 = " ";
let iq01 = " ";
let iq02 = " ";
let iq03 = " ";
let iq04 = " ";
let iq05 = " ";
let iq06 = 0;
let iq07 = " ";
let iq08 = " ";
let iq09 = " ";

----  Inicializaciòn de valores para tabla br_rs
let rsrs = null;
let rs00 = 0;
let rs01 = 0;
let rs02 = 0;
let rs03 = 0;
let rs04 = 0;
let rs05 = 0;
let rs06 = 0;
let rs07 = 0;
let rs08 = 0;
let rs09 = 0;
let rs10 = 0;
let rs11 = 0;
let rs12 = 0;
let rs13 = 0;
let rs14 = 0;
let rs15 = 0;
let rs16 = 0;
let rs17 = " ";
let rs18 = " ";
let rs19 = " ";
let rs20 = " ";
let rs21 = 0;
let rs22 = 0;
let rs23 = 0;
let rs24 = 0;
let rs25 = 0;
let rs26 = 0;
let rs27 = 0;
let rs28 = 0;
let rs29 = 0;
let rs30 = 0;
let rs31 = 0;
let rs32 = 0;
let rs33 = 0;
let rs34 = null;
let rs35 = null;
let rs36 = 0;
let rs37 = null;
let rs38 = 0;
let rs39 = null;
let rs40 = 0;
let rs41 = null;

----  Inicializaciòn de valores para tabla br_hi
let hihi = null;
let hi00 = " ";
let hi01 = " ";
let hi02 = " ";

----  Inicializaciòn de valores para tabla br_hr
let hrhr = null;
let hr00 = " ";
let hr01 = " ";
let hr02 = " ";

----  Inicializaciòn de valores para tabla br_cr
let crcr =  " ";
let cr00 = " ";

----  Inicializaciòn de valores para tabla br_sc
let scsc = " ";
let sc00 = " ";
let sc01 = " ";
let sc02 = " ";
let sc03 = " ";
let sc04 = " ";
let sc06 = " ";
--- Inicializaciòn de variables complementarias
let paso = " ";
let etiqueta = " ";
let fecha = " ";
let pnum_cliente = "";
let item_cadena = "";

--BEGIN WORK;
BEGIN

ON EXCEPTION SET sql_err
   if sql_err <> 0 then
      --ROLLBACK WORK;
       --- Borrado e insersion de error por registro, para no generar registros inecesarios
      insert into br_cadena_error values (pnum_cliente,fecha,
sql_err,paso,item_cadena,substr(pcadena,1,item_cadena + 10),vfecha_hoy);
      RETURN ;
   end if
END EXCEPTION;

-- Valida si la cadena viene nulla regresa datos insuficientes
if Trim(pcadena) = "" or pcadena is null then
   LET cod_ret = "110";
   RETURN ;
end if

---Obtencion Nuero de cliente

let paso ="numcte";

select numcte into pnum_cliente from bdisolic:ss_solicitudes
where num_solicitud = pnum_solicitud;

--- Obtencion de fecha
let paso = "Fecha";

select fecha_hoy   into fecha from bdicred:sd_fechas;

--- Verificacion de existencia de cliente
let paso = "Existe";

-- Inicializacion Par empezar a trabajar
let inicio = 50;
let  item_cadena = inicio;
let  etiqueta_size = 4;
let  longitud_etiqueta = etiqueta_size;
--  Si Hubo Error el el Mensaje Regresa 110
let verrorburo = substr(pcadena,1,8);
if verrorburo = "ERRRUR25" then
   LET cod_ret = "111";
   let verrorburo = substr(pcadena,1,80);
   update br_auditor
      set comentario =verrorburo
    where solicitud = pnum_solicitud
        and fecha = vfecha_hoy
        and hora = vhora;
   RETURN ;
end if

let etiqueta = substr(pcadena,item_cadena,longitud_etiqueta);
let item_cadena = item_cadena + longitud_etiqueta;
let item_valor = item_cadena;
let longitud_etiqueta = substr(etiqueta,3,2);
let item_cadena = item_cadena + longitud_etiqueta;
let continua = 0;
let bandera = 0;
let tamafin = 0;
let regre = 0;
let entro = "N";
while  (substr(etiqueta,1,2)  != "PA" and substr(etiqueta,1,2)  != "PE"
    and substr(etiqueta,1,2)  != "TL" and substr(etiqueta,1,2)  != "IQ"
    and substr(etiqueta,1,2)  != "RS" and substr(etiqueta,1,2)  != "HR"
    and substr(etiqueta,1,2)  != "HI" and substr(etiqueta,1,2)  != "CR"
    and substr(etiqueta,1,2)  != "SC" and substr(etiqueta,1,2)  != "ES")

   let paso = "PN";
let entro = "S";

   let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);
if (substr(etiqueta,1,2) = "PN") then let pnpn = valor_cadena; let bandera =
1;
   elif (substr(etiqueta,1,2) = "00")  then let pn00 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let pn01 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let pn02 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let pn03 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let pn04 = valor_cadena;
       if (pn04 = "00000000")  then let pn04 = null;  end if;
       let bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let pn05 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let pn06 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let pn07 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let pn08 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let pn09 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "10")  then let pn10 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "11")  then let pn11 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "12")  then let pn12 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "13")  then let pn13 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "14")  then let pn14 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "15")  then let pn15 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "16")  then let pn16 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "17")  then let pn17 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "18")  then let pn18 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "19")  then let pn19 = valor_cadena;
      if (pn19 = "00000000")  then let pn19 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "20")  then let pn20 = valor_cadena;
      if (pn20 = "00000000")  then let pn20 = null;  end if;
      let bandera = 1;
   end if;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
end while;

if (bandera <> 0)
then
  insert into  br_pn
values(pnum_cliente,fecha,pnpn,pn00,pn01,pn02,pn03,to_date(pn04,"%d%m%Y"),
  pn05,pn06,pn07,pn08,pn09,pn10,pn11,pn12,pn13,pn14,pn15,pn16,pn17,pn18,
  to_date(pn19,"%d%m%Y"),to_date(pn20,"%d%m%Y"));
let continua = 1;

end if;

let bandera = 0;
let pcadena2 = pcadena;
let pcadena = "";
if entro = "S" then
   let tamafin = tamafin + item_cadena - regre;
end if
let entro = "N" ;
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
while  (substr(etiqueta,1,2)  != "PE" and continua <> 0
        and substr(etiqueta,1,2)  != "TL" and substr(etiqueta,1,2)  != "IQ"
        and substr(etiqueta,1,2)  != "RS" and substr(etiqueta,1,2)  != "HR"
        and substr(etiqueta,1,2)  != "HI" and substr(etiqueta,1,2)  != "CR"
        and substr(etiqueta,1,2)  != "SC" and substr(etiqueta,1,2)  != "ES"
        and substr(etiqueta,1,2)  != "PN"
        )
       let regre = 0;
let entro = "S" ;
       let paso = "PA";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

if (substr(etiqueta,1,2) = "PA") then let respalda_papa = valor_cadena; end
if;

if (substr(etiqueta,1,2) = "PA") then let papa = valor_cadena; let bandera =
1;
   elif (substr(etiqueta,1,2) = "00")  then let pa00 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let pa01 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let pa02 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let pa03 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let pa04 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let pa05 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let pa06 = valor_cadena;
       if (pa06 = "00000000")  then let pa06 = null;  end if;
       let bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let pa07 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let pa08 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let pa09 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "10")  then let pa10 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "11")  then let pa11 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "12")  then let pa12 = valor_cadena;
      if (pa12 = "00000000")  then let pa12 = null;  end if;
      let bandera = 1;
end if;


   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
   let pa06 = pa06;

            if ( substr(etiqueta,1,2) = "PA" )
          then

                insert into  br_pa  values
(pnum_cliente,respalda_papa,pa00,pa01,pa02,pa03,pa04,pa05,to_date(pa06,"%d%m%Y"),pa07,pa08,pa09,pa10,pa11,to_date(pa12,"%d%m%Y"),vfecha_hoy);
	let pa00 = " ";
	let pa01 = " ";
	let pa02 = " ";
	let pa03 = " ";
	let pa04 = " ";
	let pa05 = " ";
	let pa06 = null;
	let pa07 = " ";
	let pa08 = " ";
	let pa09 = " ";
	let pa10 = " ";
	let pa11 = " ";
	let pa12 = null;
                let valor_cadena = null;
let bandera = 0;
let pcadena2 = pcadena;
let pcadena = "";
if entro = "S" then
   let tamafin = tamafin + item_cadena - regre -1;
end if
let entro = "N" ;
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
            end if;


end while;

if (bandera <> 0)
then
  insert into  br_pa  values
(pnum_cliente,papa,pa00,pa01,pa02,pa03,pa04,pa05,

to_date(pa06,"%d%m%Y"),pa07,pa08,pa09,pa10,pa11,to_date(pa12,"%d%m%Y"),vfecha_hoy);
  let  nrows = dbinfo("sqlca.sqlerrd2");
  let  nrows = nrows;

end if;
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
let pcadena = "";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "TL"  and continua <> 0
       and substr(etiqueta,1,2)  != "IQ" and substr(etiqueta,1,2)  != "PA"
       and substr(etiqueta,1,2)  != "RS" and substr(etiqueta,1,2)  != "HR"
       and substr(etiqueta,1,2)  != "HI" and substr(etiqueta,1,2)  != "CR"
       and substr(etiqueta,1,2)  != "SC" and substr(etiqueta,1,2)  != "ES"
       and substr(etiqueta,1,2)  != "PN")
       let regre =0;
       let entro = "S";
       let paso = "PE";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

if (substr(etiqueta,1,2) = "PE") then let respalda_pepe = valor_cadena; end
if;

if (substr(etiqueta,1,2) = "PE") then let pepe = valor_cadena; let bandera =
1;
   elif (substr(etiqueta,1,2) = "00")  then let pe00 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let pe01 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let pe02 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let pe03 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let pe04 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let pe05 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let pe06 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let pe07 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let pe08 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let pe09 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "10")  then let pe10 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "11")  then let pe11 = valor_cadena;
      if (pe11 = "00000000")  then let pe11 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "12")  then let pe12 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "13")  then let pe13 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "14")  then let pe14 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "15")  then let pe15 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "16")  then let pe16 = valor_cadena;
      if (pe16 = "00000000")  then let pe16 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "17")  then let pe17 = valor_cadena;
      if (pe17 = "00000000")  then let pe17 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "18")  then let pe18 = valor_cadena;
      if (pe18 = "00000000")  then let pe18 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "19")  then let pe19 = valor_cadena;
      let bandera = 1;
end if;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;


            if ( substr(etiqueta,1,2) = "PE" )
          then
                insert into  br_pe values
(pnum_cliente,respalda_pepe,pe00,pe01,pa02,pe03,pe04,pe05,

pe06,pe07,pe08,pe09,pe10,to_date(pe11,"%d%m%Y"),pe12,num_valor(pe13),

pe14,pe15,to_date(pe16,"%d%m%Y"),to_date(pe17,"%d%m%Y"),to_date(pe18,"%d%m%Y"),pe19,vfecha_hoy);
	let pe00 = " ";
	let pe01 = " ";
	let pe02 = " ";
	let pe03 = " ";
	let pe04 = " ";
	let pe05 = " ";
	let pe06 = " ";
	let pe07 = " ";
	let pe08 = " ";
	let pe09 = " ";
	let pe10 = " ";
	let pe11 = null;
	let pe12 = " ";
  	let pe13 = 0;
	let pe14 = " ";
	let pe15 = " ";
	let pe16 = null;
	let pe17 = null;
	let pe18 = null;
	let pe19 = " ";
                let valor_cadena = null;
let bandera = 0;
let pcadena2 = pcadena;
let pcadena = "";
if entro = "S" then
   let tamafin = tamafin + item_cadena - regre -1;
end if
let entro = "N" ;
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
            end if;
end while;

if (bandera <> 0)
then
insert into  br_pe values
(pnum_cliente,pepe,pe00,pe01,pa02,pe03,pe04,pe05,pe06,pe07,pe08,pe09,pe10,
to_date(pe11,"%d%m%Y"),pe12,pe13,pe14,pe15,to_date(pe16,"%d%m%Y"),to_date(pe17,"%d%m%Y"),
to_date(pe18,"%d%m%Y"),pe19,vfecha_hoy);
end if;
let pcadena = "";
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro ="N";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0 ;
while  (substr(etiqueta,1,2)  != "IQ" and continua<> 0
        and substr(etiqueta,1,2)  != "PA" and substr(etiqueta,1,2)  != "PE"
        and substr(etiqueta,1,2)  != "RS" and substr(etiqueta,1,2)  != "HR"
        and substr(etiqueta,1,2)  != "HI" and substr(etiqueta,1,2)  != "CR"
        and substr(etiqueta,1,2)  != "SC" and substr(etiqueta,1,2)  != "ES"
        and substr(etiqueta,1,2)  != "PN")
let entro = "S";
let regre = 0;
       let bandera = 0;
       let paso = "TL";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

if (substr(etiqueta,1,2) = "TL") then let respalda_tltl = valor_cadena; end
if;

if (substr(etiqueta,1,2) = "TL") then let tltl = valor_cadena;
    if (tltl = "00000000")  then let tltl = null;  end if;
    let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let tl00 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let tl01 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let tl02 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let tl03 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let tl04 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let tl05 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let tl06 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let tl07 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let tl08 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let tl09 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "10")  then let tl10 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "11")  then let tl11 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "12")  then let tl12 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "13")  then let tl13 = valor_cadena;
      if (tl13 = "00000000")  then let tl13 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "14")  then let tl14 = valor_cadena;
      if (tl14 = "00000000")  then let tl14 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "15")  then let tl15 = valor_cadena;
      if (tl15 = "00000000")  then let tl15 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "16")  then let tl16 = valor_cadena;
      if (tl16 = "00000000")  then let tl16 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "17")  then let tl17 = valor_cadena;
      if (tl17 = "00000000")  then let tl17 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "18")  then let tl18 = valor_cadena;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "19")  then let tl19 = valor_cadena;
      if (tl19 = "00000000")  then let tl19 = null;  end if;
      let bandera = 1;
   elif (substr(etiqueta,1,2) = "20")  then let tl20 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "21")  then let tl21 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "22")  then let tl22 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "23")  then let tl23 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "24")  then let tl24 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "25")  then let tl25 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "26")  then let tl26 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "27")  then let tl27 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "28")  then let tl28 = valor_cadena; if
(tl28 = "00000000")  then let tl28 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "29")  then let tl29 = valor_cadena; if
(tl29 = "00000000")  then let tl29 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "30")  then let tl30 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "31")  then let tl31 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "32")  then let tl32 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "33")  then let tl33 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "34")  then let tl34 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "35")  then let tl35 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "36")  then let tl36 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "37")  then let tl37 = valor_cadena; if
(tl37 = "00000000")  then let tl37 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "38")  then let tl38 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "42")  then let tl42 = valor_cadena; if
(tl42 = "00000000")  then let tl42 = null;  end if; let bandera = 1;
end if;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;


            if ( substr(etiqueta,1,2) = "TL" )
          then

                insert into  br_tl
values(pnum_cliente,to_date(respalda_tltl,"%d%m%Y"),tl00,tl01,tl02,

tl03,tl04,tl05,tl06,tl07,tl08,num_valor(tl09),num_valor(tl10),tl11,num_valor(tl12),

to_date(tl13,"%d%m%Y"),to_date(tl14,"%d%m%Y"),to_date(tl15,"%d%m%Y"),

to_date(tl16,"%d%m%Y"),to_date(tl17,"%d%m%Y"),tl18,to_date(tl19,"%d%m%Y"),

tl20,num_valor(tl21),num_valor(tl22),num_valor(tl23),num_valor(tl24),num_valor(tl25),tl26,tl27,

to_date(tl28,"%d%m%Y"),to_date(tl29,"%d%m%Y"),tl30,num_valor(tl31),num_valor(tl32),
                num_valor(tl33),num_valor(tl34),num_valor(tl35),

num_valor(tl36),to_date(tl37,"%d%m%Y"),tl38,to_date(tl42,"%d%m%Y"),vfecha_hoy);

	let tl00 = " ";
	let tl01 =  " ";
	let tl02 =  " ";
	let tl03 =  " ";
	let tl04 =  " ";
	let tl05 =  " ";
	let tl06 =  " ";
	let tl07 =  " ";
	let tl08 =  " ";
	let tl09 =  0;
	let tl10 =  0;
	let tl11 =  " ";
	let tl12 =  0;
	let tl13 = null;
	let tl14 = null;
	let tl15 = null;
	let tl16 = null;
	let tl17 = null;
	let tl18 =  " ";
	let tl19 = null;
	let tl20 =  " ";
	let tl21 =  0;
	let tl22 =  0;
	let tl23 =  0;
	let tl24 =  0;
	let tl25 =  0;
	let tl26 =  " ";
	let tl27 =  " ";
	let tl28 = null;
	let tl29 = null;
	let tl30 =  " ";
	let tl31 =  0;
	let tl32 =  0;
	let tl33 =  0;
	let tl34 =  0;
	let tl35 =  0;
	let tl36 =  0;
	let tl37 = null;
	let tl38 =  " ";
	let tl42 = null;
                let valor_cadena = null;
let bandera = 0;
let pcadena2 = pcadena;
let pcadena = "";
if entro = "S" then
   let tamafin = tamafin + item_cadena - regre -1;
end if
let entro = "N" ;
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
            end if;


end while;

if (bandera <> 0)
then
insert into  br_tl values
(pnum_cliente,to_date(tltl,"%d%m%Y"),tl00,tl01,tl02,tl03,tl04,tl05,tl06,tl07,tl08,tl09,

num_valor(tl10),tl11,num_valor(tl12),to_date(tl13,"%d%m%Y"),to_date(tl14,"%d%m%Y"),

to_date(tl15,"%d%m%Y"),to_date(tl16,"%d%m%Y"),to_date(tl17,"%d%m%Y"),tl18,

to_date(tl19,"%d%m%Y"),tl20,num_valor(tl21),num_valor(tl22),tl23,tl24,tl25,tl26,tl27,

to_date(tl28,"%d%m%Y"),to_date(tl29,"%d%m%Y"),tl30,num_valor(tl31),num_valor(tl32),

num_valor(tl33),num_valor(tl34),num_valor(tl35),num_valor(tl36),to_date(tl37,"%d%m%Y"),
                           tl38,to_date(tl42,"%d%m%Y"),vfecha_hoy);
end if;
let pcadena = "";
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "RS" and substr(etiqueta,1,2)  != "HI"
    and substr(etiqueta,1,2)  != "HR" and substr(etiqueta,1,2)  != "HI"
    and substr(etiqueta,1,2)  != "CR" and substr(etiqueta,1,2)  != "SC"
    and substr(etiqueta,1,2)  != "ES"  and continua <> 0)
let regre = 0;
let entro = "S";
       let paso = "IQ";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);


if (substr(etiqueta,1,2) = "IQ") then let respalda_iqiq = valor_cadena; end
if;

if (substr(etiqueta,1,2) = "IQ") then let iqiq = valor_cadena; if (iqiq =
"00000000")  then let iqiq = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let iq00 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let iq01 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let iq02 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let iq03 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let iq04 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let iq05 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let iq06 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let iq07 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let iq08 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let iq09 = valor_cadena; let
bandera = 1;
end if;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;


          if ( substr(etiqueta,1,2) = "IQ" )
          then

                insert into  br_iq  values
(pnum_cliente,to_date(respalda_iqiq,"%d%m%Y"),

iq00,iq01,iq02,iq03,iq04,iq05,num_valor(iq06),iq07,iq08,iq09,vfecha_hoy);
	let iq00 = " ";
	let iq01 = " ";
	let iq02 = " ";
	let iq03 = " ";
	let iq04 = " ";
	let iq05 = " ";
	let iq06 = 0;
	let iq07 = " ";
	let iq08 = " ";
	let iq09 = " ";
                let valor_cadena =  null;
let bandera = 0;
let pcadena2 = pcadena;
let pcadena = "";
if entro = "S" then
   let tamafin = tamafin + item_cadena - regre -1;
end if
let entro = "N" ;
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
          end if;


end while;

if ( bandera <> 0)
then
insert into  br_iq  values
(pnum_cliente,to_date(iqiq,"%d%m%Y"),iq00,iq01,iq02,iq03,iq04,iq05,
num_valor(iq06),iq07,iq08,iq09,vfecha_hoy);
end if;
let pcadena = "";
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "HI"  and  substr(etiqueta,1,2)  != "HR"
and substr(etiqueta,1,2)  != "CR" and substr(etiqueta,1,2)  != "SC" and
substr(etiqueta,1,2)  != "ES" and continua <> 0)
       let paso = "RS";
let entro = "S";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);
let regre = 0;

if (substr(etiqueta,1,2) = "RS") then let respalda_rsrs = valor_cadena; end
if;

if (substr(etiqueta,1,2) = "RS") then let rsrs = valor_cadena;  let bandera
= 1;
   elif (substr(etiqueta,1,2) = "00")  then let rs00 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let rs01 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let rs02 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let rs03 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let rs04 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "05")  then let rs05 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let rs06 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "07")  then let rs07 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "08")  then let rs08 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "09")  then let rs09 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "10")  then let rs10 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "11")  then let rs11 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "12")  then let rs12 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "13")  then let rs13 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "14")  then let rs14 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "15")  then let rs15 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "16")  then let rs16 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "17")  then let rs17 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "18")  then let rs18 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "19")  then let rs19 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "20")  then let rs20 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "21")  then let rs21 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "22")  then let rs22 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "23")  then let rs23 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "24")  then let rs24 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "25")  then let rs25 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "26")  then let rs26 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "27")  then let rs27 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "28")  then let rs28 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "29")  then let rs29 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "30")  then let rs30 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "31")  then let rs31 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "32")  then let rs32 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "33")  then let rs33 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "34")  then let rs34 = valor_cadena; if
(rs34 = "00000000")  then let rs34 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "35")  then let rs35 = valor_cadena; if
(rs35 = "00000000")  then let rs35 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "36")  then let rs36 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "37")  then let rs37 = valor_cadena; if
(rs37 = "00000000")  then let rs37 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "38")  then let rs38 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "39")  then let rs39 = valor_cadena; if
(rs39 = "00000000")  then let rs39 = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "40")  then let rs40 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "41")  then let rs41= valor_cadena;  if
(rs41 = "00000000")  then let rs41 = null;  end if; let bandera = 1;
end if;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;

            if ( substr(etiqueta,1,2) = "RS" )
          then

                insert into  br_rs values
(pnum_cliente,to_date(respalda_rsrs,"%d%m%Y") ,num_valor(rs00) ,
                num_valor(rs01) ,num_valor(rs02),num_valor(rs03)
,num_valor(rs04) , num_valor(rs05) ,
                num_valor(rs06) , num_valor(rs07) , num_valor(rs08) ,
num_valor(rs09) , num_valor(rs10) ,
                num_valor(rs11) , num_valor(rs12) , num_valor(rs13) ,
num_valor(rs14) , num_valor(rs15) ,
                num_valor(rs16) ,rs17 , rs18 , rs19 , rs20 , num_valor(rs21)
, num_valor(rs22) ,
                num_valor(rs23) , num_valor(rs24) , num_valor(rs25) ,
num_valor(rs26) ,
                num_valor(rs27) , num_valor(rs28) , num_valor(rs29) ,
num_valor(rs30) , num_valor(rs31) ,
                num_valor(rs32) , num_valor(rs33) , to_date(rs34,"%d%m%Y")
, to_date(rs35,"%d%m%Y")  ,
                num_valor(rs36) , to_date(rs37,"%d%m%Y")  , num_valor(rs38)
, to_date(rs39 ,"%d%m%Y") ,
                num_valor(rs40) , to_date(rs41,"%d%m%Y"),vfecha_hoy  );

	let rs20 = " ";
	let rs21 = 0;
	let rs22 = 0;
	let rs23 = 0;
	let rs24 = 0;
	let rs25 = 0;
	let rs26 = 0;
	let rs27 = 0;
	let rs28 = 0;
	let rs29 = 0;
                let rs30 = 0;
                let valor_cadena = null;
let bandera = 0;
let pcadena2 = pcadena;
let pcadena = "";
if entro = "S" then
   let tamafin = tamafin + item_cadena - regre -1;
end if
let entro = "N" ;
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
            end if;


end while;


if (bandera <> 0)
then
insert into  br_rs values (pnum_cliente,to_date(rsrs,"%d%m%Y") ,
num_valor(rs00) , num_valor(rs01) ,
num_valor(rs02) , num_valor(rs03) , num_valor(rs04) , num_valor(rs05) ,
num_valor(rs06) , num_valor(rs07) ,
num_valor(rs08) , num_valor(rs09) , num_valor(rs10) , num_valor(rs11) ,
num_valor(rs12) , num_valor(rs13) ,
num_valor(rs14) , num_valor(rs15) , num_valor(rs16) , rs17 , rs18 , rs19 ,
rs20 , num_valor(rs21) ,
num_valor(rs22) , num_valor(rs23) , num_valor(rs24) , num_valor(rs25) ,
num_valor(rs26) , num_valor(rs27) ,
num_valor(rs28) , num_valor(rs29) , num_valor(rs30) , num_valor(rs31) ,
num_valor(rs32) , num_valor(rs33) ,
to_date(rs34,"%d%m%Y")  , to_date(rs35,"%d%m%Y")  ,   num_valor(rs36) ,
to_date(rs37,"%d%m%Y")  ,
num_valor(rs38) , to_date(rs39 ,"%d%m%Y") , num_valor(rs40) ,
to_date(rs41,"%d%m%Y"), vfecha_hoy  );
end if;
let pcadena = "";
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "HR" and substr(etiqueta,1,2)  != "CR"
    and substr(etiqueta,1,2)  != "SC"  and substr(etiqueta,1,2)  != "ES"
    and continua <> 0  )
let regre = 0;
let entro = "S";
       let paso = "HI";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

if (substr(etiqueta,1,2) = "HI") then let respalda_hihi = valor_cadena; end
if;

if (substr(etiqueta,1,2) = "HI") then let hihi = valor_cadena; if (hihi =
"00000000")  then let hihi = null;  end if; let bandera = 1;
   elif (substr(etiqueta,1,2) = "00")  then let hi00 = valor_cadena;  let
bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let hi01 = valor_cadena;  let
bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let hi02 = valor_cadena;  let
bandera = 1;
end if;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;

            if ( substr(etiqueta,1,2) = "HI" )
          then

                insert into  br_hi  values
(pnum_cliente,to_date(respalda_hihi,"%d%m%Y") ,hi00,hi01,hi02,vfecha_hoy);
	let hi00 = " ";
	let hi01 = " ";
	let hi02 = " ";
	let valor_cadena = null;
let bandera = 0;
let pcadena2 = pcadena;
let pcadena = "";
if entro = "S" then
   let tamafin = tamafin + item_cadena - regre -1;
end if
let entro = "N" ;
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
            end if;

end while;

if ( bandera <> 0)
then
insert into  br_hi  values (pnum_cliente,to_date(hihi,"%d%m%Y")
,hi00,hi01,hi02,vfecha_hoy);
end if;
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
let pcadena = "";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "CR"  and substr(etiqueta,1,2)  != "SC"
and substr(etiqueta,1,2)  != "ES" and continua <> 0 )

       let paso = "HR";
let entro = "S";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

if (substr(etiqueta,1,2) = "HR") then let respalda_hrhr = valor_cadena; end
if;

if (substr(etiqueta,1,2) = "HR") then let hrhr = valor_cadena; let bandera =
1;
   elif (substr(etiqueta,1,2) = "00")  then let hr00 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let hr01 = valor_cadena; let
bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let hr02 = valor_cadena; let
bandera = 1;
end if;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;


            if ( substr(etiqueta,1,2) = "HR" )
          then
                insert into  br_hr  values
(pnum_cliente,to_date(respalda_hrhr,"%d%m%Y") ,hr00,hr01,hr02,vfecha_hoy);
	let hr00 = " ";
	let hr01 = " ";
	let hr02 = " ";
	let valor_cadena = null;
let bandera = 0;
let pcadena2 = pcadena;
let pcadena = "";
if entro = "S" then
   let tamafin = tamafin + item_cadena - regre -1;
end if
let entro = "N" ;
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
            end if;


end while;

if (bandera <> 0)
then insert into  br_hr  values (pnum_cliente,to_date(hrhr,"%d%m%Y")
,hr00,hr01,hr02,vfecha_hoy);
end if;
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
let pcadena = "";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (substr(etiqueta,1,2)  != "SC"  and substr(etiqueta,1,2)  != "ES"
and continua <> 0)

let regre = 0;
       let paso = "CR";
let entro = "S";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);

if (substr(etiqueta,1,2) = "CR") then let crcr = valor_cadena;  end if; let
bandera = 1;

   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let regre = etiqueta_size;
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;

            if ( etiqueta = "0000" )
            then
              for i = 1    to 2000 step 1
                let salva = substr(pcadena, item_valor + i - 1 ,4);
                   if (salva = "SC08" or salva = "ES05")
                   then
                        let longitud_etiqueta =  (i - 1);
                        EXIT FOR;
                   end if;
                end for;
               let valor_cadena = substr(pcadena,
item_valor,longitud_etiqueta);
               if (substr(etiqueta,1,2) = "00")  then let cr00 =
valor_cadena; end if; let bandera = 1;
               let item_cadena = item_cadena + longitud_etiqueta;
               let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
               let item_cadena = item_cadena + etiqueta_size;
               let item_valor = item_cadena;
               let longitud_etiqueta = substr(etiqueta,3,2);
               let regre = etiqueta_size + longitud_etiqueta;
               let item_cadena = item_cadena + longitud_etiqueta;
               EXIT WHILE;
            end if;

end while;

if (bandera <> 0)
then insert into  br_cr  values (pnum_cliente,crcr,cr00,vfecha_hoy);
end if;
if entro = "S" then
let tamafin = tamafin + item_cadena - regre - 1;
end if
let entro = "N";
let pcadena = "";
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
let bandera = 0;
while  (etiqueta  != "ES05"  and continua <> 0 )
       let paso = "SC";
       let valor_cadena = substr(pcadena, item_valor,longitud_etiqueta);
let regre = 0;
let entro = "S";

if (substr(etiqueta,1,2) = "SC") then let respalda_scsc = valor_cadena; end
if;

if (substr(etiqueta,1,2) = "SC") then let scsc = valor_cadena; let bandera =
1;
   elif (substr(etiqueta,1,2) = "00")  then let sc00 = valor_cadena;  let
bandera = 1;
   elif (substr(etiqueta,1,2) = "01")  then let sc01 = valor_cadena;  let
bandera = 1;
   elif (substr(etiqueta,1,2) = "02")  then let sc02 = valor_cadena;  let
bandera = 1;
   elif (substr(etiqueta,1,2) = "03")  then let sc03 = valor_cadena;  let
bandera = 1;
   elif (substr(etiqueta,1,2) = "04")  then let sc04 = valor_cadena;  let
bandera = 1;
   elif (substr(etiqueta,1,2) = "06")  then let sc06 = valor_cadena;  let
bandera = 1;
end if;


   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let item_cadena = item_cadena + longitud_etiqueta;
   let regre = etiqueta_size + longitud_etiqueta;
            if ( substr(etiqueta,1,2) = "SC" )
          then

                insert into  br_sc  values
(pnum_cliente,respalda_scsc,sc00,sc01,sc02,sc03,sc04,sc06,vfecha_hoy);
	let sc00 = " ";
	let sc01 = " ";
	let sc02 = " ";
	let sc03 = " ";
	let sc04 = " ";
	let sc06 = " ";
	let valor_cadena = null;
let bandera = 0;
let pcadena2 = pcadena;
let pcadena = "";
if entro = "S" then
   let tamafin = tamafin + item_cadena - regre -1;
end if
let entro = "N" ;
if (tamafin + 250) <= tamamax then
  select substr(regreso,tamafin,250) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
else
  let tamares = tamamax - tamafin;
  select substr(regreso,tamafin) into pcadena
  from sb_regreso
  where num_solicitud = pnum_solicitud;
end if
   let item_cadena = 1;
   let etiqueta = substr(pcadena,item_cadena, etiqueta_size);
   let item_cadena = item_cadena + etiqueta_size;
   let item_valor = item_cadena;
   let longitud_etiqueta = substr(etiqueta,3,2);
   let regre = regre + longitud_etiqueta;
   let item_cadena = item_cadena + longitud_etiqueta;
            end if;


end while;

if (bandera <>0)
then  insert into  br_sc  values
(pnum_cliente,scsc,sc00,sc01,sc02,sc03,sc04,sc06,vfecha_hoy);
end if;

if (substr(etiqueta,1,2) = "ES" and  substr(pcadena, item_valor + 22, 2) =
"**" and continua <> 0)
then
   let cod_ret = "000";
   let paso = "0000";
else
  let cod_ret = "111";
  let paso = "PNES";
  insert into br_cadena_error values (pnum_cliente,fecha, "SIN PN/ES", " ",0,substr(pcadena,1,item_cadena + 10),vfecha_hoy);
end if;
call bdisolic:califica_scoring2("001", pnum_solicitud)
returning cod_ret;
return  ;
END;
end procedure;