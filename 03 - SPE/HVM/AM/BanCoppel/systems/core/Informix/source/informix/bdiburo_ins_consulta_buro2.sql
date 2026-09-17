CREATE PROCEDURE "informix".ins_consulta_buro2(pempresa CHAR(3),psucursal CHAR(3), pusuario CHAR(8), pInstitucion CHAR(2),pnum_solicitud VARCHAR(25))

--Declaraciones   Generales
DEFINE inicio,item_cadena,item_valor,etiq_size,tamamax,tamres,tamfin,long_etiq INT;
DEFINE etiqueta CHAR(4);
DEFINE valor_cadena lvarchar;
DEFINE sql_err,i,j,flag INT;
--DEFINE paso varchar(10);
DEFINE paso VARCHAR(30);
DEFINE fecha DATE;
DEFINE cod_ret CHAR(5);
DEFINE pnum_cliente VARCHAR(25);  --IPCB autenticador
DEFINE vhora datetime HOUR TO fraction(3);
DEFINE csolicitud   CHAR (20); -- Caja Unica. Viridiana
DEFINE iconsulta    SMALLINT;  -- Caja Unica. Viridiana
DEFINE cOrigenSol   CHAR (1);  -- Caja Unica. Viridiana
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
DEFINE vstatus CHAR(1); DEFINE s_regreso CHAR(1); DEFINE sEs01 VARCHAR(9);
DEFINE sEs02 VARCHAR(4); DEFINE sEs03 VARCHAR(99); DEFINE sEs04 VARCHAR(6);
--APR
DEFINE cNumSolSic CHAR(20); DEFINE cInstitucionSIC CHAR(2);
DEFINE dtFechaSic DATE; DEFINE p_cod_ret CHAR(6);
--HASS
DEFINE cTpsol, vvalbloq CHAR(1); DEFINE cStatusSol CHAR(2); DEFINE vcDescripcionError CHAR(100);
-- 1370-MttoBCyCC, RQM  09 308
DEFINE cTipoSol, vetiq CHAR(2); DEFINE cDescMttoBCyCC CHAR(50);

--IPCB 16jun2015 --FICO SCORE
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
DEFINE cSolMixta CHAR(20); --598
DEFINE cEstatusSol CHAR(2);

-- RQM 09 554 - Consulta a las SICs.
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


--SET DEBUG file to '/RESPALDOS/ipcb/tasf/ins_consulta_buro23.out';
--SET DEBUG file to '/informix/AldoE/ins_consulta_buro23.out';
--SET DEBUG file to '/informix/mc/Fernandorb/ins_consulta_buro/trace_ins_consulta_buro2.out';
--TRACE ON;

--SET DEBUG FILE TO '/home/e_vvalen/ins_consulta_buro2'||pnum_solicitud||'.out';
--	TRACE ON;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--IPCB Dic2019-Valida si se debe aplicar desglose o no Rocket
IF (select count(*) from bdisolic:ss_prospecteo_solicitudes a inner join bdisolic:ss_solicitudes_sic b
    on a.numcte = b.numcte and a.num_solicitud = b.num_solicitud and a.num_solicitud = b.num_solicitud_sic  and fecha_sic is not null
    where  a.num_solicitud = pnum_solicitud and canal_sol = 4) > 0 THEN

RETURN;

END IF;

LET s_regreso  = '0';
SELECT fecha_hoy INTO vFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa='001';

--RQI 21 246  Originacion de solicitudes 24 x 7 INI
SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
INTO vfechaServ
FROM sysmaster:sysshmvals;

IF vFechaHoy < vfechaServ THEN
	LET vFechaHoy = vfechaServ;
	--LET fecha = vfechaServ;
END IF;
--RQI 21 246  Originacion de solicitudes 24 x 7 FIN

LET vhora = extend(CURRENT,HOUR TO fraction(3));
LET nrows = 0; LET tamamax = 0;LET long_get_cadenas=250;
SELECT status INTO vstatus
FROM "informix".br_respuesta_aprocesar WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
IF vstatus = "3" THEN
INSERT INTO "informix".br_auditor VALUES(pInstitucion,pnum_solicitud,vFechaHoy,vhora,"Problemas de coneccion");
RETURN;
END IF
--SELECT LENGTH(regreso) INTO tamamax FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;

SELECT SUM(LENGTH(regreso)) INTO tamamax FROM "informix".br_respuesta WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;

IF tamamax IS NULL THEN LET tamamax=0; ELSE LET tamamax = tamAmax -1; END IF
IF tamamax = 0 THEN RETURN; END IF
IF tamamax > 251 THEN
--SELECT SUBSTR(regreso,1,250) INTO pcadena  FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  1, long_get_cadenas) into pcadena;
ELSE
--SELECT SUBSTR(regreso,1,tamamax) INTO pcadena  FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
LET cSolMixta = "";		--598
LET cEstatusSol = '';

BEGIN
ON EXCEPTION SET sql_err
IF sql_err <> 0 THEN
	INSERT INTO "informix".br_cadena_error VALUES (pInstitucion,pnum_cliente,fecha, sql_err,paso,
	item_cadena,SUBSTR(pcadena,1,item_cadena + 10),vFechaHoy);
	IF EXISTS(SELECT * FROM bdisolic:ss_paso_cred_sol WHERE num_solicitud_sic = pnum_solicitud AND institucion_proc = pInstitucion ) THEN
		DELETE bdisolic:ss_paso_cred_sol WHERE num_solicitud_sic = pnum_solicitud AND institucion_proc = pInstitucion;
	END IF;
	RETURN;
END IF
END EXCEPTION;
--datos insuficientes
IF TRIM(pcadena) = "" OR pcadena IS NULL THEN LET cod_ret = "110"; RETURN; END IF
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
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB --Se separa la respuesta de error para incrementos de linea y para solicitudes de credito.
IF verrorburo = 'ERRR' and vetiq = '20' AND vvalbloq = 'Y' THEN
--IPCB junio2017 //RECHAZO POR CREDITO BLOQUEADO RCB --INCREMENTOS:  Cuando la respuesta de error es de un incremento se realiza el rechazo del incremento, no en la solicitud
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
	LET cod_ret = "111"; RETURN;
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
		--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena
		--FROM "informix".sb_regreso
		--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;

	ELSE
		LET tamres = tamamax - tamfin;
		--SELECT SUBSTR(regreso,tamfin) INTO pcadena
		--FROM "informix".sb_regreso
		--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
		--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena
		--FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		--SELECT SUBSTR(regreso,tamfin) INTO pcadena
		--FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
IF (flag <> 0)
THEN
INSERT INTO "informix".br_pn  VALUES(pInstitucion,pnum_cliente,fecha,pnpn,pn00,pn01,pn02,pn03,TO_DATE(pn04,"%d%m%Y"),
pn05,pn06,pn07,pn08,pn09,pn10,pn11,pn12,pn13,pn14,pn15,pn16,pn17,pn18,
TO_DATE(pn19,"%d%m%Y"),TO_DATE(pn20,"%d%m%Y"));
END IF;
LET flag = 0; LET pcadena2 = pcadena; LET pcadena = "";
IF entro = "S" THEN LET tamfin = tamfin + item_cadena - regre; END IF
LET entro = "N";
IF (tamfin + 250) <= tamamax THEN
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena	FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena	FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
 ELSE
	LET tamres = tamamax - tamfin;
	--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
			--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
			EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
		ELSE
			LET tamres = tamamax - tamfin;
			--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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

IF (flag <> 0)
THEN
INSERT INTO  "informix".br_pa  VALUES (pInstitucion,pnum_cliente,papa,pa00,pa01,pa02,pa03,pa04,pa05,
TO_DATE(pa06,"%d%m%Y"),pa07,pa08,pa09,pa10,pa11,TO_DATE(pa12,"%d%m%Y"),vFechaHoy,pacodpais);
LET  nrows = dbinfo("sqlca.sqlerrd2");
END IF;
IF entro = "S" THEN LET tamfin = tamfin + item_cadena - regre - 1; END IF
LET entro = "N"; LET pcadena = "";
IF (tamfin + 250) <= tamamax THEN
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
		--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena
		--FROM "informix".sb_regreso
		--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		--SELECT SUBSTR(regreso,tamfin) INTO pcadena
		--FROM "informix".sb_regreso
		--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena
	--FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
	LET tamres = tamamax - tamfin;
	--SELECT SUBSTR(regreso,tamfin) INTO pcadena
	--FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena  FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena  FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena
	--FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
	LET tamres = tamamax - tamfin;
	--SELECT SUBSTR(regreso,tamfin) INTO pcadena
	--FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
ELIF (SUBSTR(etiqueta,1,2) = "28") THEN LET tl28 = valor_cadena; IF (tl28 = "00000000")
THEN LET tl28 = NULL; END IF; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "29") THEN LET tl29 = valor_cadena; IF (tl29 = "00000000")
THEN LET tl29 = NULL;  END IF; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "30") THEN LET tl30 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "31") THEN LET tl31 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "32") THEN LET tl32 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "33") THEN LET tl33 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "34") THEN LET tl34 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "35") THEN LET tl35 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "36") THEN LET tl36 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "37") THEN LET tl37 = valor_cadena; IF (tl37 = "00000000")
THEN LET tl37 = NULL;  END IF; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "38") THEN LET tl38 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "42") THEN LET tl42 = valor_cadena; IF (tl42 = "00000000")
THEN LET tl42 = NULL;  END IF; LET flag = 1;
END IF;
IF (item_cadena + etiq_size) >= 250 THEN
LET pcadena = ""; 	LET tamfin = tamfin + item_cadena - 1;
IF (tamfin + 250) <= tamamax THEN
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena	FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
	LET tamres = tamamax - tamfin;
	--SELECT SUBSTR(regreso,tamfin) INTO pcadena	FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena  FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena  FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena
	--FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena	FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
END IF
LET item_valor = 1; LET item_cadena = item_valor + long_etiq;
END IF
LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);
IF (SUBSTR(etiqueta,1,2) = "IQ") THEN LET respalda_iqiq = valor_cadena; END IF;
IF (SUBSTR(etiqueta,1,2) = "IQ") THEN LET iqiq = valor_cadena; IF (iqiq = "00000000")
THEN LET iqiq = NULL;  END IF; LET flag = 1;
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
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
	LET tamres = tamamax - tamfin;
	--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
LET valor_cadena =  NULL;	END IF;
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
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena  FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena	FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena	FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
ELIF (SUBSTR(etiqueta,1,2) = "34") THEN LET rs34 = valor_cadena; IF (rs34 = "00000000")
	THEN LET rs34 = NULL; END IF; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "35") THEN LET rs35 = valor_cadena; IF (rs35 = "00000000")
THEN LET rs35 = NULL;  END IF; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "36") THEN LET rs36 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "37") THEN LET rs37 = valor_cadena; IF (rs37 = "00000000")
THEN LET rs37 = NULL;  END IF; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "38") THEN LET rs38 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "39") THEN LET rs39 = valor_cadena; IF (rs39 = "00000000")
THEN LET rs39 = NULL;  END IF; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "40") THEN LET rs40 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "41") THEN LET rs41= valor_cadena;  IF (rs41 = "00000000")
 THEN LET rs41 = NULL; END IF; LET flag = 1;
END IF;
IF (item_cadena + etiq_size) >= 250 THEN
LET pcadena = "";
LET tamfin = tamfin + item_cadena - 1;
IF (tamfin + 250) <= tamamax THEN
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena	FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena	FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
IF (flag <> 0)
THEN
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
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena
--FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
	LET tamres = tamamax - tamfin;
	--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
END IF
LET item_valor = 1; LET item_cadena = item_valor + long_etiq;
END IF
LET valor_cadena = SUBSTR(pcadena, item_valor,long_etiq);
IF (SUBSTR(etiqueta,1,2) = "HI") THEN LET respalda_hihi = valor_cadena; END IF;
IF (SUBSTR(etiqueta,1,2) = "HI") THEN LET hihi = valor_cadena; IF (hihi = "00000000")
THEN LET hihi = NULL;  END IF; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "00") THEN LET hi00 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "01") THEN LET hi01 = valor_cadena; LET flag = 1;
ELIF (SUBSTR(etiqueta,1,2) = "02") THEN LET hi02 = valor_cadena; LET flag = 1;
END IF;
IF (item_cadena + etiq_size) >= 250 THEN
LET pcadena = "";
LET tamfin = tamfin + item_cadena - 1;
IF (tamfin + 250) <= tamamax THEN
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena
--FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena
--FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena
--FROM "informix".sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena
--FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena
--FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena
--FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
	LET tamres = tamamax - tamfin;
	--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena  FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena  FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
--SELECT SUBSTR(regreso,tamfin,1) INTO pcadena
--FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
--EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, 1) into pcadena;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
LET cr00 = cr00||SUBSTR(pcadena,1,1); --LET cr00 = TRIM(cr00)||SUBSTR(pcadena,1,1);
LET tamfin = tamfin + 1 ;
LET j = j - 1;
END WHILE;
INSERT INTO  "informix".br_cr  VALUES (pInstitucion,pnum_cliente,crcr,cr00,vFechaHoy);
LET pcadena = "";
IF (tamfin + 250) <= tamamax THEN
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena	FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena	FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
LET tamres = tamamax - tamfin;
--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso
--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
		--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena FROM "informix".sb_regreso
		--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
		EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
	ELSE
		LET tamres = tamamax - tamfin;
		--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso
		--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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
	--SELECT SUBSTR(regreso,tamfin,250) INTO pcadena FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
	EXECUTE PROCEDURE "informix".sp_regreso_respuesta(pInstitucion,pnum_solicitud,  tamfin, long_get_cadenas) into pcadena;
ELSE
	LET tamres = tamamax - tamfin;
	--SELECT SUBSTR(regreso,tamfin) INTO pcadena FROM "informix".sb_regreso
	--WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
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

	--SET DEBUG FILE TO '/informix/Fperaza/traces/ins_consulta_buro2'||pnum_solicitud||'.out';
	--TRACE ON;
--IPCB Autenticador

--SET DEBUG FILE TO '/informix/mc/ins_consulta_buro2'||pnum_solicitud||'.out';
--TRACE ON;

SELECT COUNT(num_solicitud)
	INTO iBanPreAprobado
	FROM bdisolic:"informix".ss_solicitudes
	WHERE num_solicitud = pnum_solicitud AND user_insert="sys_cred";
	
IF iBanPreAprobado <> 0 THEN
	
	 EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(pempresa, pnum_cliente,pnum_solicitud)
     INTO p_cod_ret, v_hit, dCompromisos, vMensaje; -- X - 0 - 1 - 9
	 
	 SELECT tipo_solicitud INTO  v_tp_tarjeta
	 FROM  bdisolic:ss_solicitudes 
	 WHERE num_Solicitud =  pnum_solicitud;
	 
	 SELECT grupo INTO v_grupo
	 FROM bdisolic:"informix".ss_resum_scor_fin
	 WHERE num_solicitud = pnum_solicitud ;

	 SELECT min_score INTO v_min_score 
	 FROM bdisolic:"informix".ss_perfil_riesgo 
	 WHERE empresa = pempresa AND
	 grupo = ''|| v_grupo AND hit_buro = '' || v_hit AND 
	 id_riesgo = 3 AND tp_solicitud = '' || v_tp_tarjeta
	 AND id_modelo = 0 and tipo_producto = ' 'AND grupo_info = ' ';
	 
	 SELECT COUNT(*) INTO iContScore 
	 FROM bdisolic:ss_resumen_scoring 
	 WHERE num_solicitud = pnum_solicitud;
	 
	---score oneclick 26/07/2023
	  SELECT MAX(rowid) INTO v_rowid
	  FROM bdiburo:"informix".br_sc  
	  WHERE institucion = 'BC' 
	  AND num_cliente= pnum_cliente 
	  AND sc00 <> "004";
									
	  SELECT sc01::INTEGER
	  INTO v_score
	  FROM bdiburo:"informix".br_sc 
	  WHERE rowid =v_rowid 
	  AND institucion = 'BC'
	  AND num_cliente = pnum_cliente AND sc00 <> "004"; 
	  
	  IF v_score IS NULL THEN
		 LET v_score = 0;             
	  END IF;	
	  	     -- Se inserta valor de la seccion 1
      INSERT INTO bdisolic:ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
      VALUES (pempresa, pnum_solicitud, 1, v_score);
	 
	  -- Como no hay parametrico se obtiene un score default en base al perfil de riesgo,grupo y hit de burO
	  IF iContScore = 0 AND v_min_score IS NOT NULL  THEN
	   INSERT INTO bdisolic:"informix".ss_resumen_scoring(empresa,num_solicitud,seccion,evaluacion) 
	   VALUES (pempresa,pnum_solicitud,2,v_min_score);
	  END IF;
	
	  UPDATE bdisolic:"informix".ss_resum_scor_fin
      SET evalua_cc = v_hit,
          motivo_cc = vMensaje,
          pago_minimo = dCompromisos
      WHERE empresa = pempresa
      AND num_solicitud = pnum_solicitud;
	  
	  UPDATE bdisolic:"informix".ss_revision_determinacion
      SET evalua_cc = v_hit,
	      bs_score= v_score, 
	      compromiso_sic=dCompromisos
      WHERE empresa = pempresa
      AND num_solicitud = pnum_solicitud;

	  SELECT MAX(fecha_salida) INTO vfecha_bc_sic
	  FROM bdisolic:ss_autorizacion
	  WHERE  empresa = pempresa
	  AND num_solicitud = pnum_solicitud
	  AND status_solicitud = 'BC';
	  
	  SELECT FIRST 1 es03 INTO  sEs03_bc
	  FROM bdiburo:br_es
	  WHERE institucion = 'BC' AND num_cliente = pnum_cliente AND 
	  fecha = (SELECT MAX(fecha) FROM bdiburo:br_es
			   WHERE institucion = 'BC' AND 
			   num_cliente = pnum_cliente);

	  UPDATE bdisolic:"informix".ss_solicitudes_sic
	  SET fecha_sic = vfecha_bc_sic, folio_bc=sEs03_bc, folio_cc=sEs03_cc
      WHERE empresa = pempresa
	  AND numcte = pnum_cliente
	  AND num_solicitud = pnum_solicitud
	  AND fecha_sic IS NULL;
		
		--Se agrego SP donde se registra la respuesta del buro .
	 
	  IF p_cod_ret = '000' THEN
		 IF v_hit = '0' OR v_hit = 'X' AND dCompromisos IS NOT NULL  THEN -- Que los compromisos sean <> a null
		    EXECUTE PROCEDURE bdisolic:determina_lincred_tc_cjunk(pempresa,pnum_solicitud,0) INTO p_cod_ret,vlinea_cred,vcapacidad_pago,vplazo;
			 IF p_cod_ret = '000' THEN
			   LET cTipo = '0';
			 ELIF p_cod_ret = '010' THEN
				LET cTipo = '2';
			 ELSE 
				LET cTipo = '1';
			 END IF;
		 ELSE
			LET cTipo = '1';
		 END IF;
	 END IF;
	  
	  EXECUTE PROCEDURE bdicred:"informix".sp_guardaresburooc(pnum_cliente, pnum_solicitud, cTipo) INTO p_cod_ret;
	  
      EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema',pnum_solicitud, 'AT','ASP', 'Autorizada')  
	  INTO p_cod_ret;
	
	RETURN;
END IF;


IF pnum_cliente = pnum_solicitud  THEN
	UPDATE "informix".br_auditor SET comentario = ""
	WHERE institucion = pInstitucion AND solicitud = pnum_solicitud;
	
	IF pInstitucion = 'CC' THEN
		EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk2(pempresa, pnum_cliente,pnum_solicitud)
			INTO p_cod_ret, cCalifica, dCompromisos, vMensaje;
			
			IF cCalifica <>'X' THEN
				
				--SELECT cambio_sic INTO vFalloSIC FROM bdinteg:"informix".si_datos_aleatorio_sic WHERE folio_autenticacion = pnum_solicitud; --RQM 09 606 consulta sic aleatorio, valida tabla de Trabajo del autenticador
				
				--IF vFalloSIC = 0 THEN --RQM 09 606
				
					--buenos antecedentes o malos antecedentes
					--Numero de producto
					select trim(valor) into tipo_acceso_bc
					from bdiburo:br_param
					where cod_param = 153;  
				
					--Usuario Prospector
					select trim(valor) into usu_orden2
					from bdiburo:br_param
					where cod_param = 154;   
				
					--Password Prospector
					select trim(valor) into pass_orden2
					from bdiburo:br_param
					where cod_param = 155;                           

					INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
					SELECT 'BC', pnum_cliente,pnum_solicitud,  substr(envio,1,31)||tipo_acceso_bc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',vFechaHoy FROM br_traslado WHERE institucion = pInstitucion AND
					num_solicitud = pnum_solicitud;
					
				--END IF; --FalloSIC --RQM 09 606

			END IF;
			
	END IF;
	
	RETURN;
END IF;

--PRUEBA IPCB FICO
--SET DEBUG file to '/RESPALDOS/ipcb/fico/inc_13/ins_consulta_buro2_pam.out';   TRACE ON;

-- INI Bloque de codigo obtener todos los canales

SELECT canal_sol INTO cCanalSol FROM bdisolic:"informix".ss_solicitudes 
WHERE numcte = pnum_cliente AND num_solicitud = pnum_solicitud;

/*SELECT insti1 INTO status_consul FROM bdisolic:"informix".ss_canales_solic 
WHERE canal_solic = cCanalSol;*/
------------------------------------------------------------------------------------------------------------------------------------------------
--Inicio: RQM 09 606 consulta sic aleatorio y Fallo de SIC
--Tomar la ultima solicitud de la SIC
SELECT institucion, NVL(FalloSIC,0)
	INTO status_consul, vFalloSIC
	FROM bdisolic:"informix".ss_solicitudes_sic
	WHERE ROWID = (SELECT MAX(rowid)
				   FROM bdisolic:"informix".ss_solicitudes_sic
				   WHERE numcte= pnum_cliente
					AND num_solicitud = pnum_solicitud);
					
IF status_consul IS NULL THEN  --Valida que se tenga registro de la solicitud
	RETURN;END IF;
--Validar si la solicitud no trae fallo por ser BCScore
/*IF status_consul = 'CC' AND vFalloSIC = 0 THEN
	--Validar si en el historial tiene envio a BC
	IF EXISTS (SELECT status_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = pnum_solicitud AND status_solicitud = 'BC') THEN
		LET status_consul = 'BC';--Es respuesta de BCScore
	END IF;
END IF;*/
--Fin: RQM 09 606 consulta sic aleatorio y Fallo de SIC
------------------------------------------------------------------------------------------------------------------------------------------------

IF status_consul = 'CC' THEN
	LET cflujo_cc = '1';
ELSE
	LET cflujo_cc = '0';
END IF;


	--SET DEBUG FILE TO '/home/e_vvalen/ins_consulta_buro2'||pnum_solicitud||'.out';
	--TRACE ON;
-- FIN Bloque de codigo obtener todos los canales
IF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_solicitudes_aumlincred_sucursal
		WHERE num_credito = pnum_solicitud AND empresa = pempresa AND (fecha_respuesta >= today - 31 or fecha_respuesta IS NULL)) THEN
LET cflujo_cc = '0';CALL "informix".ins_buro_credito_aumlincred(pInstitucion,pempresa,pnum_solicitud,pnum_cliente,fecha,vFechaHoy,pcadena,item_cadena,paso,'0') RETURNING s_regreso;
LET cTipoSol = '2';
ELSE
CALL "informix".ins_buro_credito(pInstitucion,pempresa,pnum_solicitud,pnum_cliente,fecha,vFechaHoy,pcadena,item_cadena,paso,'0') RETURNING s_regreso;
LET cTipoSol = '1';
END IF;

EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_statusmttobcycc( pempresa, pnum_solicitud,cTipoSol ) INTO cod_ret, cDescMttoBCyCC;
IF s_regreso = '0' THEN

	IF EXISTS(SELECT * FROM bdisolic:ss_paso_cred_sol WHERE num_solicitud_sic = pnum_solicitud AND institucion_proc = pInstitucion ) THEN
		DELETE bdisolic:ss_paso_cred_sol WHERE num_solicitud_sic = pnum_solicitud AND institucion_proc = pInstitucion;
	END IF;

	INSERT INTO bdisolic:ss_paso_cred_sol
	SELECT ss.num_solicitud,ss.num_solicitud_sic,ss.fecha_sic,ss.institucion,sol.tipo_solicitud,sol.status_solicitud ,pinstitucion
		FROM bdisolic:"informix".ss_solicitudes_sic ss
	INNER JOIN bdisolic:"informix".ss_solicitudes sol ON (sol.empresa = pempresa  AND sol.numcte= pnum_cliente  AND sol.num_solicitud = ss.num_solicitud)
	WHERE ss.numcte = pnum_cliente AND ss.num_solicitud_sic = pnum_solicitud AND ss.fecha_sic IS NULL
	GROUP BY 1,2,3,4,5,6,7;  --IPCB Agosto2015 //se incluye agrupado para evitar conflictos

	IF pinstitucion = 'CC' and NOT EXISTS(SELECT * FROM bdisolic:ss_paso_cred_sol WHERE num_solicitud_sic = pnum_solicitud AND institucion_proc = pInstitucion ) THEN
		INSERT INTO bdisolic:ss_paso_cred_sol
		SELECT ss.num_solicitud,ss.num_solicitud,ss.fecha_sic,ss.institucion,sol.tipo_solicitud,sol.status_solicitud ,pinstitucion
		FROM bdisolic:"informix".ss_solicitudes_sic ss
		INNER JOIN bdisolic:"informix".ss_solicitudes sol ON (sol.empresa = pempresa  AND sol.numcte= pnum_cliente  AND sol.num_solicitud = ss.num_solicitud)
		WHERE ss.numcte = pnum_cliente AND ss.num_solicitud = pnum_solicitud AND ss.fecha_sic IS NOT NULL
		GROUP BY 1,2,3,4,5,6,7;  --IPCB Agosto2015 //se incluye agrupado para evitar conflictos

		LET flag_solo_cc = 1;
	END IF;
	
	SELECT COUNT(*) INTO iCountProspecteo FROM bdisolic:ss_prospecteo_solicitudes a 
	INNER JOIN bdisolic:ss_solicitudes_sic b ON a.numcte = b.numcte AND a.num_solicitud = b.num_solicitud AND a.num_solicitud = b.num_solicitud_sic  AND fecha_sic IS NOT NULL
    WHERE  a.num_solicitud = pnum_solicitud AND canal_sol = 4;														
	IF iCountProspecteo > 0 AND cFlujo_cc = '1' THEN  -- RQM 09 554																														 
		INSERT INTO bdisolic:ss_paso_cred_sol
			SELECT ss.num_solicitud,ss.num_solicitud,ss.fecha_sic,ss.institucion,sol.tipo_solicitud,sol.status_solicitud ,pinstitucion
			FROM bdisolic:"informix".ss_solicitudes_sic ss
			INNER JOIN bdisolic:"informix".ss_solicitudes sol ON (sol.empresa = pempresa  AND sol.numcte= pnum_cliente  AND sol.num_solicitud = ss.num_solicitud)
			WHERE ss.numcte = pnum_cliente AND ss.num_solicitud = pnum_solicitud AND ss.fecha_sic IS NOT NULL
			GROUP BY 1,2,3,4,5,6,7;  --IPCB Agosto2015 //se incluye agrupado para evitar conflictos
	
	END IF;
	

	FOREACH with hold
		SELECT num_solicitud,num_solicitud_sic,fecha_sic,institucion,tipo_solicitud,status_solicitud
		INTO csolicitud,cNumSolSic,dtFechaSic,cInstitucionSIC,cTpsol,cStatusSol
		FROM bdisolic:ss_paso_cred_sol
		WHERE num_solicitud_sic = pnum_solicitud AND institucion_proc = pInstitucion
        
		

	--IPCB Mayo2015 RQM 09 384-0 FICO SCORE
		IF pInstitucion = 'CC' THEN
			-- RQM 09 554
			IF cflujo_cc = 0 THEN 
				LET cflujo_cc = '0'; -- RQM 09 554 - Consulta a las SICs.
				 select MAX(fecha_salida) INTO vfecha_bc_sic
				   from bdisolic:ss_autorizacion
				  where empresa = pempresa
				 and num_solicitud =csolicitud
				 and status_solicitud = 'BC';
			 ELSE
			 select MAX(fecha_salida) INTO vfecha_bc_sic
				   from bdisolic:ss_autorizacion
				  where empresa = pempresa
				 and num_solicitud =csolicitud
				 and status_solicitud = 'CC';
			 END IF;

			--IF csolicitud = cNumSolSic THEN
			IF flag_solo_cc = 0 THEN
				IF  csolicitud = cNumSolSic THEN

					SELECT first 1 es03 INTO  sEs03_bc
					FROM bdiburo:br_es
					WHERE institucion = 'BC' AND num_cliente = pnum_cliente AND fecha = (select MAX(fecha)
																						 from bdiburo:br_es
																						 WHERE institucion = 'BC'
																						 AND num_cliente = pnum_cliente);

					 update bdisolic:"informix".ss_solicitudes_sic
						set fecha_sic = vfecha_bc_sic, folio_bc=sEs03_bc, folio_cc=sEs03_cc
					  where empresa = pempresa
						and numcte = pnum_cliente
						and num_solicitud = csolicitud
						and fecha_sic is null;
				ELSE
					update bdisolic:"informix".ss_solicitudes_sic
						set fecha_sic = vfecha_bc_sic
					  where empresa = pempresa
						and numcte = pnum_cliente
						and num_solicitud = csolicitud
						and fecha_sic is null;
				END IF;
			ELSE
				 update bdisolic:"informix".ss_solicitudes_sic
					set folio_cc=sEs03_cc
				  where empresa = pempresa
					and numcte = pnum_cliente
					and num_solicitud = csolicitud
					and fecha_sic IS NOT NULL;
			END IF;
		ELSE
			IF csolicitud = cNumSolSic THEN
				-- RQM 09 554
				IF cflujo_cc = '1' THEN
				
				   select MAX(fecha_salida) INTO vfecha_bc_sic
				   from bdisolic:ss_autorizacion
				   where empresa = pempresa
				   and num_solicitud =csolicitud
				   and status_solicitud = 'CC';

                	SELECT first 1 es03 INTO  sEs03_cc
					FROM bdiburo:br_es
					WHERE institucion = 'CC' AND num_cliente = pnum_cliente AND fecha = (select MAX(fecha)
																						 from bdiburo:br_es
																						 WHERE institucion = 'CC'
																						 AND num_cliente = pnum_cliente);
					update bdisolic:"informix".ss_solicitudes_sic
						set fecha_sic = vfecha_bc_sic, folio_bc=sEs03_bc, folio_cc=sEs03_cc
					  where empresa = pempresa
						and numcte = pnum_cliente
						and num_solicitud = csolicitud
						and fecha_sic is null;
				ELSE
					update bdisolic:"informix".ss_solicitudes_sic set fecha_sic = vFechaHoy,folio_bc=sEs03_bc
					where empresa = pempresa
						and numcte = pnum_cliente
						and num_solicitud = csolicitud
						and fecha_sic is null;
				END IF;
			ELSE
				update bdisolic:"informix".ss_solicitudes_sic set fecha_sic = vFechaHoy
				where empresa = pempresa
				and numcte = pnum_cliente
				and num_solicitud = csolicitud
				and fecha_sic is null;
			END IF;
		END IF;

		-------------------------------------------------------------------------------
		-----------------Valida tipo de producto y si es mixta-------------------------			
		SELECT A.num_producto,B.num_solicitud_ref,A.numcte
		INTO cNumproducto,cSolMixta,cNumcte
		FROM bdisolic:ss_solicitudes A
        LEFT OUTER JOIN bdisolic:"informix".ss_resum_scor_fin B ON B.empresa= A.empresa AND B.num_solicitud = A.num_solicitud
		WHERE A.empresa = pempresa AND A.num_solicitud = csolicitud;
		
		-------------------------------------------------------------------------------
		-------------------------------------------------------------------------------
		
		
		LET cSolMixta = TRIM(NVL(cSolMixta,''));
		IF (pInstitucion = 'CC' and cNumSolSic <> csolicitud) AND cStatusSol <> "AP" and cTpsol <> "C" THEN
			EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pempresa,'sistema',csolicitud,pInstitucion,'','SOLICITUD ENVIADA A CIRCULO DE CREDITO') INTO p_cod_ret;
		END IF;
	
		IF cTpsol = "C" THEN
					IF cSolMixta <> '' THEN
						
						--SE AGREGA LA LOGICA QUE SE TIENE EN EL ACTUALIZA ESTATUS SOL
							SELECT status_solicitud
							INTO cEstatusSol
							FROM bdisolic:"informix".ss_solicitudes 
							WHERE empresa = pempresa
							AND num_solicitud = cSolMixta;
							
							LET cEstatusSol = TRIM(NVL(cEstatusSol,''));
							
							IF cEstatusSol in ('BC','CC') THEN --EN CASO DE QUE LA SOLICITUD DE BANCO AUN NO TENGA RESPUESTA SE PROCEDE A DEJAR EN 5 LA DE COPPEL
								--SE ACTUALIZA A 5 PARA DETENER EL ENVIO AL PARAMETRICO COPPEL HASTA QUE SE TENGA RESPUESTA DE LA SOLICITUD DE BANCO
								UPDATE bdisolic: "informix".ss_solicitudes SET envio_parametrico = '5' WHERE num_solicitud = csolicitud AND empresa = pempresa AND envio_parametrico IS NULL;
							ELSE
							    EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pempresa,'sistema',csolicitud,'EC','','Solicitud enviada a Evaluacion Coppel')
								INTO p_cod_ret;
								
								UPDATE bdisolic: "informix".ss_solicitudes SET envio_parametrico = '1' WHERE num_solicitud = csolicitud AND empresa = pempresa AND envio_parametrico IS NULL;
								
							END IF;
					ELSE
							UPDATE bdisolic:"informix".ss_solicitudes SET envio_parametrico = "1" WHERE num_solicitud = csolicitud AND empresa = pempresa;
							
							 IF cStatusSol <> 'EC' THEN
								EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pempresa,'sistema',csolicitud,'EC','','Solicitud enviada a Evaluacion Coppel')
								INTO p_cod_ret;
							END IF;
					END IF;
					
		ELSE
				IF cStatusSol <> "AP" THEN
					
					  EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk2(pempresa, pnum_cliente,pnum_solicitud)
					  INTO p_cod_ret, cCalifica, dCompromisos, vMensaje;
					  
                    ------------------------------REEVALUACION-------------------------------------------------------------
					IF cCalifica = 'X' AND cTpsol = 'T' AND cNumproducto ='6001' THEN
						
						
					     -- Realiza la reevaluacion del modelo si es No Hit y cumple con las condiciones de variables BC_# se cambia Hit
					      EXECUTE PROCEDURE bdisolic:"informix".sp_reevalua_rubro_sols(pempresa, csolicitud, vMensaje) INTO cCodReRub, vMsg_Reasig, v_Reasig_rubro;

					       LET cCodReRub = '000000';
					      IF v_Reasig_rubro = '1' THEN    -- Si se realiza cambio de rubro se cambian datos
					        LET cCalifica = '0';
					        LET vMensaje = vMsg_Reasig;
					      END IF

					     		
 					   LET cCalifica = cCalifica;								
					END IF;
					
					
	                ----------------------------------------------------------------------------------------------------------
	                
					-- 39461 Obtencion del Score Telcos para input BRM TDC (Solucion intermedia) - Para validar si es hit y no hit y procesar scoreTelcos
					-- 09/07/2024
					IF cCalifica = 'X' AND cTpsol = 'T' AND cNumproducto ='6001' THEN
	                	LET cCalifica = '0';
	                END IF;
					 IF cCalifica = '0' THEN
					     --SI ES SOLICITUD BANCO CON BUEN COMPORTAMIENTO ENTONCES ACTUALIZA EL ESTATUS A EC
					      IF cTpsol = 'T' AND cNumproducto = '6001' THEN
						   EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pempresa,'sistema',csolicitud,'EC','','Solicitud enviada a Evaluacion Coppel')
						   INTO p_cod_ret;
						  END IF;
						
						IF cSolMixta <> '' THEN
							 
							   --SI LA SOLICITUD A PROCESAR ES TIPO BANCO LE CAMBIA PARAMETRICO 5, SI LLA SOLICITUD ES PRESTAMO SE VA A EVALUAR DIRECTAMENTE 
                             IF cTpsol = 'T' AND cNumproducto = '6001'  THEN
							   UPDATE bdisolic: "informix".ss_solicitudes SET envio_parametrico = '5' WHERE num_solicitud = csolicitud AND empresa = pempresa AND envio_parametrico IS NULL;
							 
							 ELSE 
						        EXECUTE PROCEDURE bdisolic:"informix".califica_scoring2_cjunk("001", csolicitud) INTO cod_ret;
						        LET cTipoSol = '1';
                              END IF;
							  
						
						    --CONSULTA DATOS DE LA SOLICITUD COPPEL
							SELECT status_solicitud,envio_parametrico
							INTO cEstatusSol,cEnvioparametrico
							FROM bdisolic:"informix".ss_solicitudes 
							WHERE empresa = pempresa
							AND num_solicitud = cSolMixta;
							
							LET cEstatusSol = TRIM(NVL(cEstatusSol,''));
						    
							--SI LA SOLICITUD COPPEL TIENE ESTATUS BC Y ENVIO PARAMETRICO DIFERENTE DE NULO QUIERE DECIR QUE YA PASO LA PRIMERA VUELTA Y HAY QUE CAMBIARLE A EC
	                        --IF cEstatusSol = 'BC'  OR (cEstatusSol = 'CC' AND vFalloSIC = 1) AND cEnvioparametrico IS NOT NULL THEN --RQM 09 606 Se agrego la condicion de estatus CC y falloSic
							IF (cEstatusSol = 'BC'  OR cEstatusSol = 'CC') AND cEnvioparametrico IS NOT NULL THEN --RQM 09 606 Se agrego la condicion de estatus CC y falloSic																															 
							   EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pempresa,'sistema',cSolMixta,'EC','','Solicitud enviada a Evaluacion Coppel')
							   INTO p_cod_ret;
							END IF;
							
							--SI LA SOLICITUD COPPEL YA TIENE ESTATUS EC Y NO TIENE PARAMETRICO 1, SE LE COLOCA PARA QUE SE LA LLEVE EL DEMONIO YA QUE VIENE CON 5 EN LA PRIMERA VUELTA
							IF cEstatusSol = 'EC' AND cEnvioparametrico <> '1' THEN									
							   UPDATE bdisolic: "informix".ss_solicitudes SET envio_parametrico = '1' WHERE num_solicitud = cSolMixta AND empresa = pempresa;
							END IF;						
                         
							
						ELSE	
						    --SI LA SOLICITUD NO ES MIXTA Y ES BANDO SE ACTUALIZA EL PARAMETRICO 1 PARA QUE SE LA LLEVE EL DEMONIO, SI NO ES BANCO ENTONCES PASA DIRECTO A EVALUACION
						    IF cTpsol = 'T' AND cNumproducto = '6001'  THEN    
							  UPDATE bdisolic: "informix".ss_solicitudes SET envio_parametrico = '1' WHERE num_solicitud = csolicitud AND empresa = pempresa AND envio_parametrico IS NULL;
						    ELSE
							 EXECUTE PROCEDURE bdisolic:"informix".califica_scoring2_cjunk("001", csolicitud) INTO cod_ret;
						     LET cTipoSol = '1';
							END IF;                       
						
						
						END IF;
					
					 ELSE
					    --SI NO ES BUEN COMPORTAMIENTO PASA DIRECTO A EVALUACION
						EXECUTE PROCEDURE bdisolic:"informix".califica_scoring2_cjunk("001", csolicitud) INTO cod_ret;
						LET cTipoSol = '1';
						
						 
						 --SI NO TIENE BUEN COMPORTAMIENTO SE CONSULTA SI ES MIXTA PARA ACTUALIZAR EL ESTATUS Y EL PARAMETRICO DE LA COPPEL				
						 IF cSolMixta <> '' THEN
							 --CONSULTA DATOS DE LA SOLICITUD COPPEL
							SELECT status_solicitud,envio_parametrico
							INTO cEstatusSol,cEnvioparametrico
							FROM bdisolic:"informix".ss_solicitudes 
							WHERE empresa = pempresa
							AND num_solicitud = cSolMixta;
							
							LET cEstatusSol = TRIM(NVL(cEstatusSol,''));
						    
							--SI LA SOLICITUD COPPEL TIENE ESTATUS BC Y ENVIO PARAMETRICO DIFERENTE DE NULO QUIERE DECIR QUE YA PASO LA PRIMERA VUELTA Y HAY QUE CAMBIARLE A EC
	                        --IF cEstatusSol = 'BC' OR (cEstatusSol = 'CC' AND vFalloSIC = 1) AND cEnvioparametrico IS NOT NULL THEN --RQM 09 606 Se agrego la condicion de estatus CC y falloSic
							IF (cEstatusSol = 'BC' OR cEstatusSol = 'CC') AND cEnvioparametrico IS NOT NULL THEN --RQM 09 606 Se agrego la condicion de estatus CC y falloSic																															
							   EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pempresa,'sistema',cSolMixta,'EC','','Solicitud enviada a Evaluacion Coppel')
							   INTO p_cod_ret;
							   						   
							   UPDATE bdisolic: "informix".ss_solicitudes SET envio_parametrico = '1' WHERE num_solicitud = cSolMixta AND empresa = pempresa;
							END IF;
						 END IF;
						 
					 END IF;

				ELSE
						EXECUTE PROCEDURE "informix".sp_valida_respuesta_bc_ofi(pEmpresa,csolicitud) INTO cod_ret,vcDescripcionError;
						LET cTipoSol = '2';					
						
				END IF;
				--1370-MttoBCyCC, RQM 09 308,Obtener el estatus actual de la solicitud
				EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_statusmttobcycc( pempresa, csolicitud, cTipoSol )
				INTO cod_ret, cDescMttoBCyCC;
		END IF;
					
	END FOREACH;
	
	DELETE bdisolic:ss_paso_cred_sol WHERE num_solicitud_sic = pnum_solicitud AND institucion_proc = pInstitucion;
END IF;
--Fin Caja Unica. Viridiana
UPDATE "informix".br_auditor SET comentario = ""
WHERE institucion = pInstitucion AND solicitud = pnum_solicitud;
RETURN;
END;
END PROCEDURE 
DOCUMENT "Version 1.00.000",
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'DESCRIPCION: SE AGREGO VALIDACION PARA CUANDO SE TRATA DE SOLICITUDES MIXTAS, SE CAMBIE  ',
' CAMPO EL envio_parametrico = 5 PARA DETENER POR UN MOMENTO EL ENVIO AL PARAMETRICO. ',
'AUTOR: RODOLFO TORTOLERO',
'BD: BDIBURO',
'FECHA: 02/04/2019',
'SOLICITA:ABRAHAM NARVAEZ',
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------', 
'PROYECTO: Peticion 598.1 - RQM 09 488-3 IMPLEMENTACION - ADENDUM - Homologacion de Clientes BanCoppel - Coppel en alta Unica (Mensaje PP y % inicial de pago)',
'DESCRIPCION: SE AGREGA VALIDACIONES PARA DETENER EL ENVIO DE LA INFORMACION AL PARAMETRICO COPPEL, HASTA QUE SE REALICE LA EVALUACION DE LA SOLICITUD DE BANCO',
'AUTOR: ISARAI BOJORQUEZ',
'BD: BDIBURO',
'FECHA: 09/08/2019',
'SOLICITA:ABRAHAM NARVAEZ',
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Autor:  Francisco Javier Peraza',
'Modifica: Se modifica orden de consulta a las instituciones de credito',
'para canales 0,1,2,3 ',
'Fecha: 15-04-2020',
'Peticion: RQM 09 554 - Consulta a las SICs',
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Autor:  Miguel Angel Espinoza Salmoran',
'Modifica: Se agrega flujo para solicitudes PreAprobadas',
'Fecha: 10-05-2022',
'Peticion: OneClick PreAprobados',
'---------------------------------------------------------------------------------',
'-- Autor: Luis Angel Juarez Vazquez, Gustavo Fuentes Lopez',
'-- Modificacion: Se ha agregado la validacion de producto para realizar nueva evaluacion de parametros .',
'-- Fecha de Modificacion: 20-08-2022.',
'-- Peticion: Prestamo Personal',
'---------------------------------------------------------------------------------',
'-- Autor: Luis Angel Juarez Vazquez, Gustavo Fuentes Lopez',
'-- Modificacion: Se ha agregado la validacion de producto para realizar nueva evaluacion de parametros .',
'-- Fecha de Modificacion: 20-08-2022.',
'-- Peticion: Prestamo Personal',
'---------------------------------------------------------------------------------',
'Autor:  Miguel Angel Espinoza Salmoran',
'Modifica: Se modifica flujo OneClick para agregar clientes con X para',
'posible aumento de linea.',
'Fecha: 10-05-2022',
'Peticion: OneClick PreAprobados',
'---------------------------------------------------------------------------------',
'Autor:  Felix Ignacio Leyva Gamez.',
'Modifica: Se agrega consulta aleatoria a las SICs, ,con las banderas de fallosic y vigencia',
'Fecha: 06-01-2023.',
'Peticion: RQM 09 606 - Consulta aleatoria a las SICs cadena 2x1 - Originacion',
'------------------------------------------------------------------------------------',
'Autor:  Felipe Antonio Ruiz AcuÃ±a.',
'Modifica: Se agrega validacion de la variable cCalifica = X para corroborar si la solicitud es HIT o NO HIT',
'Fecha: 09-07-2024.',
'Peticion: RQM 39461 ObtenciÃ³n del Score Telcos para input BRM TDC (SoluciÃ³n intermedia)',
'------------------------------------------------------------------------------------';