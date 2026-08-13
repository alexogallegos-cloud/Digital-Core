CREATE PROCEDURE "informix".sp_rpt_dotacionesatm_sucursal()
RETURNING CHAR(5) AS cod_ret, CHAR(150) AS msj_ret;
--VARIABLES DE CONTROL DE ERROR
DEFINE iSqlErr    INTEGER;
DEFINE iIsamErr   INTEGER;
DEFINE iPasoErr   INTEGER;
DEFINE cCod_ret	  CHAR(5);
DEFINE cMsj_ret	  CHAR(150);
DEFINE cCmd		  CHAR(500);
--VARIABLES DE ARCHIVOS
DEFINE cRuta 	  CHAR(30);
DEFINE cPrefijo   CHAR(21);
DEFINE cExtension CHAR(4);
DEFINE cArchivo  CHAR(63);
DEFINE dFecha_ant DATE;
DEFINE cDia		  CHAR(2);
DEFINE cMes		  CHAR(2);
DEFINE cAno		  CHAR(4);
DEFINE cFechaRpt  CHAR(8);
--VARIABLES
DEFINE cFolio          CHAR(8);
DEFINE cCodTrans       CHAR(4);
DEFINE cDesTrans       CHAR(35);
DEFINE cTransaccion    CHAR(40);
DEFINE cIdAtm          CHAR(6);
DEFINE cAtm            CHAR(4);
DEFINE cNomBre         CHAR(40);
DEFINE mImporte        MONEY(14,2);
DEFINE iBilletes500    INTEGER;
DEFINE mTotal500       MONEY(14,2);
DEFINE iBilletes200    INTEGER;
DEFINE mTotal200       MONEY(14,2);
DEFINE iBilletes100    INTEGER;
DEFINE mTotal100       MONEY(14,2);
DEFINE iBilletes50     INTEGER;
DEFINE mTotal50        MONEY(14,2);
DEFINE cReverso        CHAR(1);
DEFINE cReversada      CHAR(2);
DEFINE dFechaSolicitud DATE;
DEFINE cHoraSolicitud  CHAR(5);
DEFINE cNumEmpSol      CHAR(8);
DEFINE dFechaEnvio     DATE;
DEFINE cHoraEnvio      CHAR(5);
DEFINE cNumEmpEnv      CHAR(8);
DEFINE dFechaRecepcion DATE;
DEFINE cHoraRecepcion  CHAR(5);
DEFINE cNumEmpRec      CHAR(8);
DEFINE cCodStatus      CHAR(2);
DEFINE cCodPlaza       CHAR(3);
DEFINE cDescPlaza      CHAR(30);
DEFINE cPlaza		   CHAR(33);
DEFINE cNomEmp         CHAR(45);
DEFINE cDescStatus     CHAR(30);
DEFINE cStatus         CHAR(32);
DEFINE cFecHorSol      CHAR(16);
DEFINE cFecHorEnv      CHAR(16);
DEFINE cFecHorRec      CHAR(16);
DEFINE cEmpSol         CHAR(54);
DEFINE cEmpEnv         CHAR(54);
DEFINE cEmpRec         CHAR(54);

LET cFolio          = '';
LET cCodTrans       = '';
LET cDesTrans       = '';
LET cTransaccion    = '';
LET cIdAtm          = '';
LET cAtm            = '';
LET cNomBre         = '';
LET mImporte        = 0;
LET iBilletes500    = 0;
LET mTotal500       = 0;
LET iBilletes200    = 0;
LET mTotal200       = 0;
LET iBilletes100    = 0;
LET mTotal100       = 0;
LET iBilletes50     = 0;
LET mTotal50        = 0;
LET cReverso        = '';
LET cReversada      = '';
LET dFechaSolicitud = '';
LET cHoraSolicitud  = '';
LET cNumEmpSol      = '';
LET dFechaEnvio     = '';
LET cHoraEnvio      = '';
LET cNumEmpEnv      = '';
LET dFechaRecepcion = '';
LET cHoraRecepcion  = '';
LET cNumEmpRec      = '';
LET cCodStatus      = '';
LET cCodPlaza       = '';
LET cDescPlaza      = '';
LET cPlaza			= '';
LET cNomEmp         = '';
LET cDescStatus     = '';
LET cStatus         = '';
LET cFecHorSol      = '';
LET cFecHorEnv      = '';
LET cFecHorRec      = '';
LET cEmpSol         = '';
LET cEmpEnv         = '';
LET cEmpRec         = '';

LET iPasoErr = 0;
LET cCod_ret = '';
LET cMsj_ret = '';
LET cCmd = '';

LET cDia = '';
LET cMes = '';
LET cAno = '';
LET cFechaRpt = '';
LET cRuta = '/resplogifx/OFIConciliacion';
LET cExtension = '.txt';
LET cArchivo = '';

--SET DEBUG FILE TO "/resplogifx/OFIConciliacion/sp_rpt_dotacionesatm_sucursal.out";
--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
				TRUNCATE TABLE rpt_operacionatm_bancoppel_tmp;
				TRUNCATE TABLE rpt_dotacionatm_bancoppel_tmp;
				DROP TABLE IF EXISTS atms_administrados_bancoppel;
				RETURN iSqlErr, iIsamErr||' En paso: '||iPasoErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--ELIMINA INFORMACION DE LAS TABLAS DE PASO
		TRUNCATE TABLE rpt_operacionatm_bancoppel_tmp;
		TRUNCATE TABLE rpt_dotacionatm_bancoppel_tmp;
		DROP TABLE IF EXISTS atms_administrados_bancoppel;
		
		--OBTIENE LA FECHA DEL DÃA ANTERIOR DE LA FECHA ACTUAL
		SELECT fecha_ant INTO dFecha_ant FROM bdinteg:"informix".si_fechas;
		LET cDia = LPAD(DAY(dFecha_ant), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_ant), 2, '0');
		LET cAno = YEAR(dFecha_ant);
		
		--DA FORMATO 'AAAAMMDD' A LA FECHA
		LET cFechaRpt = cAno||cMes||cDia;
		
		SELECT {+INDEX (bdinteg:"informix".si_sucursales idx_si_sucursales_empzon)} sucursal FROM bdinteg:"informix".si_sucursales 
		WHERE tpo_sucursal = 'C' AND plaza_cajagen IS NOT NULL AND sucursal NOT IN (SELECT cod_atm FROM bdisuc:"informix".ss_atms_sucursal) 
		INTO TEMP atms_administrados_bancoppel;
		
		LET cPrefijo = '/OperacionesSucursal_';
		
		--NOMBRE COMPLETO DEL ARCHIVO
		LET cArchivo = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cFechaRpt)||TRIM(cExtension);

		FOREACH
			SELECT folio_oper, cod_trans, sucursal, monto, cantidad_2, (denominacion_2 * cantidad_2), cantidad_3, (denominacion_3 * cantidad_3), cantidad_4, (denominacion_4 * cantidad_4), cantidad_5, (denominacion_5 * cantidad_5), reversado
			INTO	cFolio, cCodTrans, cAtm, mImporte, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50, cReverso
			FROM bdisuc:"informix".ss_operaciones 
			WHERE fecha_operacion = (
				SELECT fecha_ant FROM bdinteg:"informix".si_fechas)
			AND sucursal IN (SELECT sucursal FROM atms_administrados_bancoppel)
			
			SELECT descripcion INTO cDesTrans FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = cCodTrans;
			
			SELECT {+INDEX (bdisuc:"informix".ss_relacionccid idx_relacioncc)} id INTO cIdAtm FROM bdisuc:"informix".ss_relacionccid WHERE cc = cAtm;
			
			SELECT nombre INTO cNombre FROM bdinteg:"informix".si_sucursales WHERE sucursal = cAtm;
			
			IF cReverso = '0' THEN
				LET cReversada = 'NO';
			ELSE
				LET cReversada = 'SI';
			END IF;
			
			LET cTransaccion = TRIM(cCodTrans)||' '||UPPER(TRIM(cDesTrans));
			LET cNombre = UPPER(TRIM(cNombre));
			
			INSERT INTO rpt_operacionatm_bancoppel_tmp VALUES (
			cFolio, cTransaccion, cIdAtm, cAtm, cNombre, mImporte, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50, cReversada);
			
		END FOREACH;
			
		LET iPasoErr = 1;
		LET cCmd= '';
		LET cCmd= 'echo "UNLOAD TO '||TRIM(cArchivo)||' DELIMITER '||"'|'"||' SELECT * FROM rpt_operacionatm_bancoppel_tmp ORDER BY folio;" >> '||TRIM(cRuta)||'/rpt_operacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 2;
		LET cCmd = '';
		LET cCmd = 'dbaccess bdisuc '||TRIM(cRuta)||'/rpt_operacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 3;
		LET cCmd = '';
		LET cCmd = 'rm -f '||TRIM(cRuta)||'/rpt_operacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET cPrefijo = '/DotacionesSucursal_';
		
		--NOMBRE COMPLETO DEL ARCHIVO
		LET cArchivo = TRIM(cRuta)||TRIM(cPrefijo)||TRIM(cFechaRpt)||TRIM(cExtension);

		FOREACH
			SELECT {+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_oper, sucursal, fecha_solicitud, hora_solicitud, usuario_solicitud, fecha_envio, hora_envio, usuario_envio, fecha_recepcion, hora_recepcion, usuario_recepcion, status, monto
			INTO cFolio, cAtm, dFechaSolicitud, cHoraSolicitud, cNumEmpSol, dFechaEnvio, cHoraEnvio, cNumEmpEnv, dFechaRecepcion, cHoraRecepcion, cNumEmpRec, cCodStatus, mImporte
			FROM bdisuc:"informix".ss_mae_entradasalida WHERE fecha_solicitud = (
				SELECT fecha_ant FROM bdinteg:"informix".si_fechas)
			AND sucursal IN (SELECT sucursal FROM atms_administrados_bancoppel)
			
			SELECT cod_trans, cantidad_2, (denominacion_2 * cantidad_2), cantidad_3, (denominacion_3 * cantidad_3), cantidad_4, (denominacion_4 * cantidad_4), cantidad_5, (denominacion_5 * cantidad_5)
			INTO cCodTrans, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50
			FROM bdisuc:"informix".ss_operaciones WHERE folio_oper = cFolio;
			
			SELECT {+INDEX (bdisuc:"informix".ss_relacionccid idx_relacioncc)} id INTO cIdAtm FROM bdisuc:"informix".ss_relacionccid WHERE cc = cAtm;
			
			SELECT nombre, plaza_cajagen INTO cNombre, cCodPlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = cAtm;
			
			SELECT descripcion INTO cDescPlaza FROM bdisuc:"informix".ss_proveedores WHERE plaza = cCodPlaza;
			
			SELECT descripcion INTO cDesTrans FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = cCodTrans;
			
			SELECT nombre INTO cNomEmp FROM bdinteg:si_ejecut WHERE ejecutivo = cNumEmpSol;
			
			LET cEmpSol = TRIM(NVL(cNumEmpSol, ''))||' '||UPPER(TRIM(NVL(cNomEmp, '')));
			
			SELECT nombre INTO cNomEmp FROM bdinteg:si_ejecut WHERE ejecutivo = cNumEmpEnv;
			
			LET cEmpEnv = TRIM(NVL(cNumEmpEnv, ''))||' '||UPPER(TRIM(NVL(cNomEmp, '')));
			
			SELECT nombre INTO cNomEmp FROM bdinteg:si_ejecut WHERE ejecutivo = cNumEmpRec;
			
			LET cEmpRec = TRIM(NVL(cNumEmpRec, ''))||' '||UPPER(TRIM(NVL(cNomEmp, '')));
			
			IF cCodStatus = '01' THEN
				LET cDescStatus = 'SOLICITUD DE DOTACION ATM';
			ELIF cCodStatus = '11' THEN
				LET cDescStatus = 'DOTACION ATM APROBADA CG';
			ELIF cCodStatus = '05' THEN
				LET cDescStatus = 'RECEPCION DE DOTACION ATM';
			ELSE 
				SELECT descripcion INTO cDescStatus FROM bdisuc:"informix".ss_catstatus WHERE status = cCodStatus;
			END IF;
			
			LET cPlaza = TRIM(cCodPlaza)||' '||UPPER(TRIM(cDescPlaza));
			LET cTransaccion = TRIM(cCodTrans)||' '||UPPER(TRIM(cDesTrans));
			LET cNombre = UPPER(TRIM(cNombre));
			LET cStatus = TRIM(cCodStatus)||' '||UPPER(TRIM(cDescStatus));
			LET cFecHorSol = dFechaSolicitud||' '||cHoraSolicitud;
			LET cFecHorEnv = NVL(dFechaEnvio, '')||' '||NVL(cHoraEnvio, '');
			LET cFecHorRec = NVL(dFechaRecepcion, '')||' '||NVL(cHoraRecepcion, '');
			
			INSERT INTO rpt_dotacionatm_bancoppel_tmp VALUES (
			cIdAtm, cAtm, cNombre, cPlaza, cTransaccion, cStatus, cFolio, cFecHorSol, cEmpSol, cFecHorEnv, cEmpEnv, cFecHorRec, cEmpRec, mImporte, iBilletes500, mTotal500, iBilletes200, mTotal200, iBilletes100, mTotal100, iBilletes50, mTotal50);	
		END FOREACH;
		
		LET iPasoErr = 4;
		LET cCmd= '';
		LET cCmd= 'echo "UNLOAD TO '||TRIM(cArchivo)||' DELIMITER '||"'|'"||' SELECT * FROM rpt_dotacionatm_bancoppel_tmp ORDER BY folio;" >> '||TRIM(cRuta)||'/descarga_rpt_dotacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 5;
		LET cCmd = '';
		LET cCmd = 'dbaccess bdisuc '||TRIM(cRuta)||'/descarga_rpt_dotacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET iPasoErr = 6;
		LET cCmd = '';
		LET cCmd = 'rm -f '||TRIM(cRuta)||'/descarga_rpt_dotacionatm_bancoppel.sql';
		SYSTEM cCmd;
		
		LET cCod_ret = '00000';
		LET cMsj_ret = 'REPORTES GENERADOS: OperacionesSucursal y DotacionesSucursal DEL DÃA '||dFecha_ant;
		
		TRUNCATE TABLE rpt_operacionatm_bancoppel_tmp;
		TRUNCATE TABLE rpt_dotacionatm_bancoppel_tmp;
		DROP TABLE atms_administrados_bancoppel;
			
		RETURN cCod_ret, cMsj_ret;
		
	END;
END PROCEDURE;