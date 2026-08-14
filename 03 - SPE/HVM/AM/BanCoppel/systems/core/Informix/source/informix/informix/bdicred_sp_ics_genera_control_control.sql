CREATE PROCEDURE "informix".sp_ics_genera_control_control()
RETURNING CHAR(5) as codret, CHAR (300) as mensaje;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE iIsamError INTEGER;
DEFINE cCod_err CHAR(5);
DEFINE vsMensaje CHAR(100);

DEFINE vContador INTEGER;
DEFINE vtransaccion SMALLINT;
DEFINE vNumcte CHAR(9);
DEFINE v_num_credito CHAR(12);
DEFINE vStatus_cred CHAR(2);
DEFINE v_count_cred INTEGER;
DEFINE v_sql CHAR(1000);
DEFINE vstmt CHAR(250);

DEFINE c_fecha_actual DATE;
DEFINE c_fecha_actual_2 DATE;
DEFINE iDia_corte INTEGER;
DEFINE vSec_dir CHAR(9);
DEFINE vSec_tel CHAR(9);
DEFINE vSec_dir_old CHAR(9);
DEFINE vSec_tel_old CHAR(9);
DEFINE horaActual DATETIME YEAR TO FRACTION(5);
DEFINE v_proceso CHAR(20);
DEFINE vEjecucionSemanal INTEGER;
DEFINE vEjecucionMensual INTEGER;
DEFINE vDiasNoComparaSecuencia INTEGER;

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err = '00000';
LET vsMensaje = 'PROCESO EXITOSO';

LET vContador = 0;
LET vtransaccion = 0;
LET vNumcte = '';
LET v_num_credito = '';
LET vStatus_cred = '';
LET v_count_cred = 0;
LET v_sql= '';
LET vstmt= '';

LET c_fecha_actual = NULL;
LET c_fecha_actual_2 = NULL;
LET iDia_corte = NULL;

LET horaActual = NULL;
LET v_proceso ='';
LET vEjecucionSemanal=0;
LET vEjecucionMensual=0;
LET vDiasNoComparaSecuencia=0;

    --SET DEBUG FILE TO '/RESPALDOSNEW/noe/ics/sp_ics_genera_control.out';
    --TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError,vsMensaje
		SET DEBUG FILE TO '/RESPALDOSNEW/sp_ics_genera_control.out';
		TRACE ON;

		SELECT DBINFO("utc_to_datetime", sh_curtime)
			INTO horaActual
		FROM sysmaster:sysshmvals;

		INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto, descripcion_error, proceso, fecha_insert)
		VALUES(v_num_credito, vNumcte, '', iSqlErr, v_proceso, horaActual);

		IF iSqlErr <> 0 THEN
			LET cCod_err = iSqlErr;
			RETURN cCod_err, trim(vsMensaje);
		END IF;

	END EXCEPTION;

	ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	LET v_proceso ='Inicio iCS_ctrl';

--REGISTRA INICIO EN BITACORA
	LET v_proceso ='Fecha Actual';

	SELECT DBINFO("utc_to_datetime", sh_curtime)
		INTO horaActual
	FROM sysmaster:sysshmvals;
	INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, 'INICIO ICS_CONTROL');

	LET v_proceso ='Obtiene Parametros';

--OBTIENE FECHA ACTUAL
	SELECT fecha_hoy, (fecha_hoy + 1),  day(fecha_hoy)
		INTO c_fecha_actual, c_fecha_actual_2, iDia_corte
	FROM bdinteg:si_fechas where empresa = '001';

--VALIDA SI ES EJECUCION COMPLETA DE ACUERDO AL PARAMETRO

	SELECT SUM(CASE WHEN valor like '%' || DECODE(WEEKDAY(c_fecha_actual),0,'D',1,'L',2,'M',3,'X',4,'J',5,'V',6,'S') || '%' THEN 1 ELSE 0 END) semanal
		  ,SUM(CASE WHEN valor like '%d' || DAY(c_fecha_actual) || '%' THEN 1 ELSE 0 END) mensual
	INTO vEjecucionSemanal, vEjecucionMensual
	FROM "informix".ics_parametros WHERE cod_param=1;

	SELECT valor::INTEGER dias INTO vDiasNoComparaSecuencia FROM "informix".ics_parametros WHERE cod_param=2;

	LET v_proceso ='Creditos iCS';

	SELECT DBINFO("utc_to_datetime", sh_curtime)
		INTO horaActual
	FROM sysmaster:sysshmvals;
	INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

--OBTIENE CREDITOS EN iCS
	DROP TABLE IF EXISTS tmp_creds_ics;

	SELECT num_credito FROM "informix".ics_maectrl INTO TEMP tmp_creds_ics WITH NO LOG;

	LET v_proceso ='Creditos Nuevos';

	SELECT DBINFO("utc_to_datetime", sh_curtime)
		INTO horaActual
	FROM sysmaster:sysshmvals;
	INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

--OBTIENE REGISTRO NUEVOS
	DROP TABLE IF EXISTS tmp_creds_nvos;

	SELECT S.num_credito FROM bdicred:"informix".sd_maesdos S
    LEFT JOIN tmp_creds_ics I ON S.num_credito=I.num_credito
    WHERE sdo_cap_insoluto > 0
    AND I.num_credito IS NULL
    UNION
    SELECT S.num_credito FROM bdicred:"informix".sd_maesdoscrd S
    LEFT JOIN tmp_creds_ics I ON S.num_credito=I.num_credito
    WHERE sdo_cap_insoluto > 0
    AND I.num_credito IS NULL
    INTO temp tmp_creds_nvos WITH NO LOG;

	LET v_proceso ='Creditos Sin Mora';

	SELECT DBINFO("utc_to_datetime", sh_curtime)
		INTO horaActual
	FROM sysmaster:sysshmvals;
	INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

--OBTIENE REGISTRO QUE YA NO ESTAN EN MORA
    DROP TABLE IF EXISTS tmp_creds_sin_mora;

	SELECT S.num_credito FROM bdicred:"informix".sd_maesdos S
    LEFT JOIN tmp_creds_ics I ON S.num_credito=I.num_credito
    WHERE sdo_cap_insoluto <= 0
    AND I.num_credito IS NOT null
    UNION
    SELECT S.num_credito FROM bdicred:"informix".sd_maesdoscrd S
    LEFT JOIN tmp_creds_ics I ON S.num_credito=I.num_credito
    WHERE sdo_cap_insoluto <= 0
    AND I.num_credito IS NOT NULL
    INTO temp tmp_creds_sin_mora WITH NO LOG;

	BEGIN WORK;

	LET v_proceso ='Inserta Nuevos';

	SELECT DBINFO("utc_to_datetime", sh_curtime)
		INTO horaActual
	FROM sysmaster:sysshmvals;
	INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

	FOREACH WITH HOLD SELECT num_credito INTO v_num_credito FROM tmp_creds_nvos

		LET v_count_cred = 0;

		SELECT numcte, status_cred, COUNT(*) INTO vNumcte, vStatus_cred, v_count_cred FROM "informix".sd_maecred M, "informix".sd_maecredanexo X
		WHERE M.num_credito = v_num_credito AND X.num_credito=M.num_credito
		AND (X.fecha_proceso = c_fecha_actual OR X.fecha_proceso = c_fecha_actual_2) GROUP BY 1,2;

		IF v_count_cred > 0 THEN

			SELECT
			sum(case when tipo_dir='1' then secuencia else 0 end)
			|| sum(case when tipo_dir='2' then secuencia else 0 end)
			|| sum(case when tipo_dir='3' then secuencia else 0 end) sec_dir INTO vSec_dir
			FROM bdinteg:"informix".si_direcciones_actual  where numcte=vNumcte;

			SELECT
			sum(case when tipo_tel='1' then secuencia else 0 end)
			|| sum(case when tipo_tel='2' then secuencia else 0 end)
			|| sum(case when tipo_tel='3' then secuencia else 0 end) sec_tel INTO vSec_tel
			FROM bdinteg:"informix".si_telefonos_actual where numcte=vNumcte and tipo_tel in('1','2','3') and status_tel='A';

			INSERT INTO "informix".ics_maectrl(num_credito, numcte, status_cred, tipo_cred, secuencia_direccion, secuencia_telefono, enviado_ics, activo_ics, envia_pagos_ics, fecha_act_secuencia_telefono, fecha_act_secuencia_direccion, fecha_insert)
    		VALUES(v_num_credito, vNumcte, vStatus_cred, 1, vSec_dir, vSec_tel, 'f', 't', 'f', TODAY, TODAY, TODAY);

			LET vContador = vContador + 1;

		ELSE

			SELECT numcte, status_cred, COUNT(*) INTO vNumcte, vStatus_cred, v_count_cred FROM "informix".sd_maecredcrd M, "informix".sd_maecredanexocrd X
			WHERE M.num_credito = v_num_credito AND X.num_credito=M.num_credito
			AND (X.fecha_proceso = c_fecha_actual OR X.fecha_proceso = c_fecha_actual_2) GROUP BY 1,2;

			IF v_count_cred > 0 THEN

				SELECT
				sum(case when tipo_dir='1' then secuencia else 0 end)
				|| sum(case when tipo_dir='2' then secuencia else 0 end)
				|| sum(case when tipo_dir='3' then secuencia else 0 end) sec_dir INTO vSec_dir
				FROM bdinteg:"informix".si_direcciones_actual  where numcte=vNumcte;

				SELECT
				sum(case when tipo_tel='1' then secuencia else 0 end)
				|| sum(case when tipo_tel='2' then secuencia else 0 end)
				|| sum(case when tipo_tel='3' then secuencia else 0 end) sec_tel INTO vSec_tel
				FROM bdinteg:"informix".si_telefonos_actual where numcte=vNumcte and tipo_tel in('1','2','3') and status_tel='A';

				INSERT INTO "informix".ics_maectrl(num_credito, numcte, status_cred, tipo_cred, secuencia_direccion, secuencia_telefono, enviado_ics, activo_ics, envia_pagos_ics, fecha_act_secuencia_telefono, fecha_act_secuencia_direccion, fecha_insert)
	    		VALUES(v_num_credito, vNumcte, vStatus_cred, 2, vSec_dir, vSec_tel, 'f', 't', 'f', TODAY, TODAY, TODAY);

			LET vContador = vContador + 1;

			END IF;

		END IF;

		IF vContador >= 5000 THEN
			COMMIT WORK;
			LET vContador = 0;
			BEGIN WORK;
		END IF;

	END FOREACH;

	IF vContador < 5000 THEN
		COMMIT WORK;
		LET vContador = 0;
	END IF;

--COMPARA SECUENCIAS DE TELEFONO Y DIRECCION
	LET v_proceso ='Compara Secuencias';

	SELECT DBINFO("utc_to_datetime", sh_curtime)
		INTO horaActual
	FROM sysmaster:sysshmvals;
	INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

	BEGIN WORK;

	--FOREACH vCursor WITH HOLD FOR SELECT numcte, nvl(secuencia_telefono,'0'), nvl(secuencia_direccion,'0')
	FOREACH WITH HOLD SELECT DISTINCT numcte, nvl(secuencia_telefono,'0'), nvl(secuencia_direccion,'0')
		INTO vNumcte, vSec_tel_old, vSec_dir_old
		FROM "informix".ics_maectrl WHERE activo_ics and enviado_ics and (((today - fecha_act_secuencia_telefono) > vDiasNoComparaSecuencia)
														OR ((today - fecha_act_secuencia_direccion) > vDiasNoComparaSecuencia))

		SELECT nvl(sum(case when tipo_dir='1' then secuencia else 0 end)
		|| sum(case when tipo_dir='2' then secuencia else 0 end)
		|| sum(case when tipo_dir='3' then secuencia else 0 end),'0') sec_dir INTO vSec_dir
		FROM bdinteg:"informix".si_direcciones_actual  where numcte=vNumcte;

		SELECT nvl(sum(case when tipo_tel='1' then secuencia else 0 end)
		|| sum(case when tipo_tel='2' then secuencia else 0 end)
		|| sum(case when tipo_tel='3' then secuencia else 0 end),'0') sec_tel INTO vSec_tel
		FROM bdinteg:"informix".si_telefonos_actual where numcte=vNumcte and tipo_tel in('1','2','3') and status_tel='A';

		IF (TRIM(vSec_tel_old) <> TRIM(vSec_tel)) OR (TRIM(vSec_dir_old) <> TRIM(vSec_dir)) THEN

			IF (TRIM(vSec_tel_old) <> TRIM(vSec_tel)) AND (TRIM(vSec_dir_old) <> TRIM(vSec_dir)) THEN
				UPDATE "informix".ics_maectrl
				SET secuencia_telefono = TRIM(vSec_tel)
					, secuencia_direccion = TRIM(vSec_dir)
					, fecha_act_secuencia_telefono = TODAY
					, fecha_act_secuencia_direccion = TODAY
					, enviado_ics = 'f'
				--WHERE CURRENT OF vCursor;
				WHERE numcte = vNumcte;
			END IF;

			IF (TRIM(vSec_tel_old) = TRIM(vSec_tel)) AND (TRIM(vSec_dir_old) <> TRIM(vSec_dir)) THEN
				UPDATE "informix".ics_maectrl
				SET secuencia_direccion = TRIM(vSec_dir)
					, fecha_act_secuencia_direccion = TODAY
					, enviado_ics = 'f'
				--WHERE CURRENT OF vCursor;
				WHERE numcte = vNumcte;
			END IF;

			IF (TRIM(vSec_tel_old) <> TRIM(vSec_tel)) AND (TRIM(vSec_dir_old) = TRIM(vSec_dir)) THEN
				UPDATE "informix".ics_maectrl
				SET secuencia_telefono = TRIM(vSec_tel)
					, fecha_act_secuencia_telefono = TODAY
					, enviado_ics = 'f'
				--WHERE CURRENT OF vCursor;
				WHERE numcte = vNumcte;
			END IF;

			IF vContador >= 5000 THEN
				COMMIT WORK;
				LET vContador = 0;
				BEGIN WORK;
			END IF;

		END IF;

	END FOREACH;

	IF vContador < 5000 THEN
		COMMIT WORK;
		LET vContador = 0;
	END IF;

--DESACTIVA CREDITOS EN ICS
	LET v_proceso ='Desactiva Creditos';

	SELECT DBINFO("utc_to_datetime", sh_curtime)
		INTO horaActual
	FROM sysmaster:sysshmvals;
	INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

	BEGIN WORK;

	FOREACH WITH HOLD SELECT num_credito INTO v_num_credito FROM tmp_creds_sin_mora

		UPDATE "informix".ics_maectrl
		SET activo_ics = 'f'
			, fecha_desactivado_ics = TODAY +1
			, enviado_ics = 'f'
		WHERE num_credito = v_num_credito;

		IF vContador >= 5000 THEN
			COMMIT WORK;
			LET vContador = 0;
			BEGIN WORK;
		END IF;

	END FOREACH;

	IF vContador < 5000 THEN
		COMMIT WORK;
		LET vContador = 0;
	END IF;

--CAMBIA BANDERAS EN TABLA MAESTRA SEGUN EL DIA DE EJECUCION

	IF (vEjecucionSemanal=1 OR vEjecucionMensual=1) THEN

		--ACTUALIZA LAS BANDERAS SI ES DIA DE EJECUCION COMPLETA
		LET v_proceso ='Actualiza Banderas';

		SELECT DBINFO("utc_to_datetime", sh_curtime)
			INTO horaActual
		FROM sysmaster:sysshmvals;
		INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

		BEGIN WORK;
		--FOREACH vCursor WITH HOLD FOR SELECT num_credito INTO v_num_credito FROM "informix".ics_maectrl WHERE activo_ics='t' and enviado_ics
		FOREACH WITH HOLD SELECT num_credito INTO v_num_credito FROM "informix".ics_maectrl WHERE activo_ics='t' and enviado_ics

			--UPDATE "informix".ics_maectrl SET enviado_ics = 'f' WHERE CURRENT OF vCursor;
			UPDATE "informix".ics_maectrl SET enviado_ics = 'f' WHERE num_credito = v_num_credito;

			IF vContador >= 5000 THEN
				COMMIT WORK;
				LET vContador = 0;
				BEGIN WORK;
			END IF;

		END FOREACH;

		IF vContador < 5000 THEN
			COMMIT WORK;
			LET vContador = 0;
		END IF;

	END IF;

--BUSCA MOVIMIENTOS EN SD_INDICADOR_CRED

	IF (vEjecucionSemanal = 0 AND vEjecucionMensual = 0) THEN

		LET v_proceso ='Valida Movtos Creds';

		SELECT DBINFO("utc_to_datetime", sh_curtime)
			INTO horaActual
		FROM sysmaster:sysshmvals;
		INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, v_proceso);

		DROP TABLE IF EXISTS tmp_creds_ctrl;
		DROP TABLE IF EXISTS tmp_pagos_creds;

		SELECT DISTINCT num_credito FROM ics_maectrl WHERE activo_ics='t' and tipo_cred='1' into temp tmp_creds_ctrl WITH NO LOG;

		SELECT C.num_credito FROM tmp_creds_ctrl C
		LEFT JOIN sd_indicador_cred I ON C.num_credito=I.num_credito
		WHERE monto_ultimo_pago > 0 
		--and (fecha_ultima_compra = c_fecha_actual OR atm_disp_fecha = c_fecha_actual OR fecha_ultimo_pago = c_fecha_actual)
		AND (fecha_ultima_compra = MDY(3,1,2022) OR atm_disp_fecha = MDY(3,1,2022) OR fecha_ultimo_pago = MDY(3,1,2022)) ---QUITAR AL LIBERAR
		AND I.num_credito IS NOT NULL
		INTO TEMP tmp_pagos_creds WITH NO LOG;

		IF (SELECT COUNT(*) FROM tmp_pagos_creds) > 0 THEN

			BEGIN WORK;

			FOREACH WITH HOLD SELECT num_credito INTO v_num_credito FROM tmp_pagos_creds

				UPDATE "informix".ics_maectrl SET enviado_ics = 'f', envia_pagos_ics ='t' WHERE num_credito=v_num_credito;

				IF vContador >= 5000 THEN
					COMMIT WORK;
					LET vContador = 0;
					BEGIN WORK;
				END IF;

			END FOREACH;

			IF vContador < 5000 THEN
				COMMIT WORK;
				LET vContador = 0;
			END IF;

		END IF;

	END IF;

--REGISTRA FIN EN BITACORA
	LET v_proceso ='Fin iCS_ctrl';

	SELECT DBINFO("utc_to_datetime", sh_curtime)
		INTO horaActual
	FROM sysmaster:sysshmvals;
	INSERT INTO "informix".ics_tiempos (num_registro, hora, proceso) VALUES (0, horaActual, 'FIN ICS_CONTROL');

	RETURN cCod_err, TRIM(vsMensaje);

END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Inserta/actualiza Creditos en tabla de control de iCS',
'AUTOR : Noe Medina',
'FECHA : 04 Marzo 2022',
'VERSION: 1.0';

create procedure "informix".sp_rep_crednorevolventes_pbajj()
-- execute procedure "informix".sp_rep_crednorevolventes_pbajj();
returning VARCHAR(6), char(50);  
-- returning VARCHAR(6),char(50);--pruebas

DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
DEFINE cProceso  char(4);
DEFINE cMensaje  char (50);
DEFINE cCod_ret  smallint;
DEFINE sPaso				integer;
DEFINE cSQL                 CHAR(2204);
DEFINE vsql					CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cruta                CHAR(100);
DEFINE cdelimitador         CHAR(1);
DEFINE cnombre          CHAR(100);

DEFINE pnumcredito   char(20);
DEFINE pnumcte		 char(20);
DEFINE vsdoprin      DECIMAL(18,2);
define vpagmes 		 DECIMAL(18,2);
define vparteprin	 DECIMAL(18,2);
define vparteint 	 DECIMAL(18,2);
define vtasaint 	 DECIMAL(6,2);
DEFINE vfecha_venci	date;
DEFINE vstatus		char(2);
DEFINE vgrado		char(2);
DEFINE vnumprod		char(4);
define pfechahoy   	 date;
define vpri_dia_mes   date;
define vfecha		 date;
define vdia_corte	smallint;
define vfecha_rev	date;
define vcred		char(20);
define vult_dia_mes  date;
--IPCB 10062014: nuevas variables campos requeridos RQM 07 263-2
define v_saldototal      decimal(18,2);
define v_partecapital_act decimal(18,2);
define v_partecapital_ven decimal(18,2);
define v_partecapital    decimal(18,2);
define v_intvig decimal(18,2);
define v_invenc decimal(18,2);
define v_parteinteres    decimal(18,2);
define vfecha_apertura   date;
define vbandera_anticipo smallint;

	let P_COD_RET = '000000';
	let cCod_ret = '';
  let cMensaje = 'PROCESO EXITOSO';
	let cproceso = '2081';
	let SQL_ERR            = 0;
	let ISAM_ERR           = 0;
	let ERROR_INFO         = '';
	let P_MENSAJE          = '';
	let sPaso 			=0;
let cSQL            = '';
let vsql			= '';
let cSQL1           = '';
let cSQL2           = '';
let cSQL3           = '';
let cruta           = '';
let cdelimitador    = '|';
let cnombre         = '';
	
let pnumcredito  	= '';
let pnumcte			= '';
let vsdoprin    	=0;
let vpagmes 		=0;
let vparteprin		=0;
let vparteint 		=0;
let vtasaint 		=0;
let vfecha_venci	=date(1);
let vstatus			= '';
let vgrado			= '';
let vnumprod		= '';
let pfechahoy   	 = date(1);
let vpri_dia_mes	 = date(1);
let vfecha			 = date(1);
let vdia_corte 		= 0;
let vfecha_rev		= date(1);
let vcred			= '';
let vult_dia_mes	= date(1);
--IPCB 10062014: nuevas variables campos requeridos RQM 07 263-2
let v_saldototal      = 0;
let v_partecapital_act = 0;
let v_partecapital_ven = 0;
let v_partecapital    = 0;
let v_intvig		  = 0;	
let v_invenc          = 0;
let v_parteinteres    = 0;
let vfecha_apertura   = date(1);
let vbandera_anticipo = 0;
	

BEGIN 
  

  ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
   /* CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, P_COD_RET, P_MENSAJE, '02')
        RETURNING P_COD_RET;*/
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        --RETURN P_COD_RET;
        RETURN P_COD_RET, trim(pnumcte) || " - " || trim(pnumcredito); 
     END exception;
	 
-- SET DEBUG FILE TO 'repnorev.out';
-- TRACE ON;	
	
	--seleccionar la ruta del archivo
	select trim(valor) into cruta
	from bdicred:sd_param
	where empresa = '001'
	and cod_param = '49';
			
  /*  CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '01')
        RETURNING P_COD_RET;*/ 

	set isolation to dirty read;

	
	select date(pri_dia_mes) - 1 units day,fecha_hoy, ult_dia_mes 
		into vpri_dia_mes,pfechahoy ,vult_dia_mes
	 from bdicred:sd_fechas where empresa = '001';
--let pfechahoy = '10-06-2014';   -- pruebas
--let vpri_dia_mes = '09-30-2014'; -- pruebas
--let vult_dia_mes = '10-31-2014'; -- pruebas	
if not exists (select fecha from sd_cred_revolventes where fecha = vpri_dia_mes) then
		truncate sd_cred_revolventes;
	end if;
	
--IPCB 10062014: universo créditos con pago anticipado RQM 07 263-2
select {+INDEX(bdicred:sd_movhiscrd inx_movcrd)} num_credito
from bdicred:sd_movhiscrd
where empresa = '001'
--and fecha_mov between date(1) and vpri_dia_mes
and fecha_mov <= vpri_dia_mes
and num_credito >= ''
and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd)
and codigo_ref = 1
and reversado = 'N'
and referencia = 'ANTICIPO'
INTO temp cred_anticipo WITH NO LOG;

begin;
create index idx_cred_anticipo on cred_anticipo(num_credito) online;
update statistics high for table cred_anticipo;
commit;

	
	foreach WITH HOLD
--IPCB 10062014: Se integran nuevos campos solicitados, fecha apertura RQM 07 263-2
	select  mae.num_credito,mae.numcte,/*maes.sdo_capital,*/NVL(maes.sdo_cap_insoluto,0) vsdoprin,mae.tasa_interes,mae.fecha_vencim,
			mae.status_cred,mae.num_producto,anex.dia_corte,mae.fecha_apertura
	into pnumcredito,pnumcte,vsdoprin,vtasaint,vfecha_venci,vstatus,vnumprod,vdia_corte,vfecha_apertura
	from bdicred:sd_maecredcontcrd mae,bdicred:sd_maesdoscontcrd maes,bdicred:sd_maecredanexocrd anex
	where mae.fecha = vpri_dia_mes and mae.fecha = maes.fecha 
	and mae.empresa = maes.empresa and mae.num_credito = maes.num_credito
	and anex.empresa = mae.empresa and anex.num_credito = mae.num_credito 
	and mae.num_producto in ('6011','6300','6400') 
    And mae.campo_trab3 <> 'BAJA'
	and mae.num_credito not in (select num_credito from sd_cred_revolventes)
--pruebas
--and mae.sucursal in ('0223','0392','0109')


  if pnumcredito is null or pnumcredito = '' then
     continue foreach; 
  end if

	
	let vbandera_anticipo = 0;
		
	if (vdia_corte > day(vult_dia_mes)) then
			let vdia_corte = day(vult_dia_mes);
    end if;
	
	let vfecha = mdy(month(pfechahoy),vdia_corte,year(pfechahoy));
	
	select limit 1 capital_mto_cuota, capital_debe, interes_debe 
	into vpagmes,vparteprin,vparteint
	from bdicred:sd_amortiza_creditocrd 
	where empresa = '001' and num_credito = pnumcredito
		and fecha_cuota = vfecha;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN  
		select status_cred into vstatus
		from  bdicred:sd_maecredcrd where empresa = '001' and num_credito = pnumcredito;
	end if;
	
--IPCB 10062014: Asignación de parte parte de capital y de interes RQM 07 263-2	(sol_correo)
IF vnumprod <> '6011' THEN
	--IF DBINFO("sqlca.sqlerrd2") = 1 THEN  
		select his.grado_riesgo, saldo_cierre ,saldo_insoluto, (intereses_vigente+intereses_devengados+intereses_vencidos),pago_minimo
        into vgrado,v_saldototal, v_partecapital,v_parteinteres,vpagmes
		from bdicred:sd_hist_reserva_cnr his 
		where his.empresa= '001' and his.num_credito = pnumcredito and his.fecha_cierre = vpri_dia_mes;
	--end if;
END IF
			
	if exists (select num_credito from cred_anticipo where num_credito = pnumcredito) then
	   let vbandera_anticipo= 1;
	end if;
	
--IPCB 10062014: Se modifica el insert a la sd_cred_revolventes RQM 07 263-2		
	begin work;	
		INSERT INTO bdicred:sd_cred_revolventes 
		VALUES('001',pnumcredito,pnumcte,vsdoprin,vpagmes,vparteprin,vparteint,vtasaint,vfecha_venci,vstatus,vgrado,vnumprod,vpri_dia_mes,v_saldototal,v_partecapital,v_parteinteres,vfecha_apertura,vbandera_anticipo);
	commit work;
	 
	end foreach 

	--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
--let cruta = '/informix/eli/'; -- pruebas

	
	let cnombre = 'rep_creditonorevolvente_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
		let vsql = '';
		let cSql='';
		LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'archivo_revolventes.unl' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
		--LET cSQL2 = " select num_credito,numcte,sdoprincipal,pagomes,parteprincipal,parteinteres,tasainteres,fecha_vencimiento,status,grado_riesgo,num_producto from sd_cred_revolventes;";
		LET cSQL2 = " select num_credito,numcte,sdototal,capmes,intmes,pagomes,parteprincipal,parteinteres,tasainteres,fecha_apertura,fecha_vencimiento,status,grado_riesgo,num_producto, pago_ant from sd_cred_revolventes;";
		LET cSQL3 = '">'||TRIM(cRuta)||'archivo_revolventes.sql';
		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		System cSQL;
	
		LET vsql='chmod 777 '|| TRIM(cRuta)||'archivo_revolventes.sql';
		System vsql;
		let vsql = '';
		let vsql= 'dbaccess bdicred ' || TRIM(cruta)||'archivo_revolventes.sql';
		system vsql;
		let vsql ='';
		let vsql ='rm '|| TRIM(cruta)||'archivo_revolventes.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' "||TRIM(cruta)||"archivo_revolventes.unl >>"||TRIM(cruta)|| cnombre;		
		system vsql;
		let vsql ='rm '|| TRIM(cruta)||'archivo_revolventes.unl ' ;
		system vsql; 
		--SE COMPRIME EL ARCHIVO	
		LET vsql='chmod 777 '|| TRIM(cRuta)||cnombre;
		System vsql;
		LET cSql = "gzip " || trim(cruta) || trim(cnombre); 
		system cSql;

	/*CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '03')
  let cMensajeFin = cnombre  ;
    RETURNING P_COD_RET;*/
	
end
RETURN P_COD_RET, cMensaje;
--RETURN P_COD_RET,cnombre; --Pruebas
END PROCEDURE;