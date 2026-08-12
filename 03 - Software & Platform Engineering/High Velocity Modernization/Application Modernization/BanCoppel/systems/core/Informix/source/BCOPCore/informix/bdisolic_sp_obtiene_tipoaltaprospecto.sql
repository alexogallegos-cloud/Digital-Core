CREATE PROCEDURE "informix".sp_obtiene_tipoaltaprospecto(pEmpresa CHAR(3),pTpConsulta CHAR(2),pFiltro VARCHAR(4),pProducto CHAR(4),pFechaIni DATE,pFechaFin DATE,pEstatus CHAR(2),pretedocd CHAR(2))
RETURNING
	CHAR(6) AS cod_ret, VARCHAR(80,1) AS mensaje_ret, VARCHAR(200,1) AS descripcion_status, VARCHAR(3,1) AS status_sol, DECIMAL(18,2) AS grupo1_hit,
	DECIMAL(18,2) AS grupo1_no_hit, DECIMAL(18,2) AS grupo2_hit, DECIMAL(18,2) AS grupo2_no_hit, DECIMAL(18,2) AS grupo3_hit, DECIMAL(18,2) AS grupo3_no_hit,
	DECIMAL(18,2) AS grupo5_hit, DECIMAL(18,2) AS grupo5_no_hit, DECIMAL(18,2) AS grupo6_hit, DECIMAL(18,2) AS grupo6_no_hit, 
	DECIMAL(18,2) AS grupoA_hit, DECIMAL(18,2) AS grupoA_no_hit, DECIMAL(18,2) AS grupo7_hit, DECIMAL(18,2) AS grupo7_no_hit, 
    DECIMAL(18,2) AS grupo8_hit, DECIMAL(18,2) AS grupo8_no_hit,DECIMAL(18,2) AS grupo9_hit, DECIMAL(18,2) AS grupo9_no_hit, DECIMAL(18,2) AS total_x_estatus_hit,
	DECIMAL(18,2) AS total_x_estatus_no_hit, DECIMAL(18,2) AS porc_status_hit, DECIMAL(18,2) AS porc_status_no_hit, DECIMAL(18,2) AS total_x_estatus,
	DECIMAL(18,2) AS porc_status;

DEFINE iSqlErr, iIsamErr,total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit INTEGER;
DEFINE cErrorInfo CHAR(80); DEFINE cCodRet CHAR(6); DEFINE cMensajeRet VARCHAR(80,1); DEFINE cEmpresa CHAR(3);
DEFINE cStatusSol VARCHAR(3,1); DEFINE cDescripcion VARCHAR(200,1); DEFINE dSituacionPago DECIMAL(5,2);
DEFINE dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit ,dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit, dTotalStatus, dTotalGenStatus DECIMAL(18,2);
DEFINE dGrupo6_hit, dGrupo6_no_hit, dGrupoA_hit, dGrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit, dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,ptotal_x_status,ptotal_x_status_hit,ptotal_x_status_no_hit DECIMAL(18,2);
DEFINE cBanCausa,cBanTmp CHAR(1); DEFINE cCausaSol VARCHAR(3,1); DEFINE num_registros SMALLINT;

LET iSqlErr = 0; LET iIsamErr = 0; LET cErrorInfo = ''; LET cCodRet = '000000'; LET cMensajeRet = 'Se ejecutÃÂ³ la consulta correctamente';
LET cEmpresa = ''; LET cStatusSol = ''; LET cDescripcion = ''; LET dSituacionPago = 0; LET dgrupo1_hit = 0; LET dgrupo1_no_hit = 0; LET dgrupo2_hit = 0;
LET dgrupo2_no_hit = 0; LET dgrupo3_hit = 0; LET dgrupo3_no_hit = 0; LET dGrupo5_hit = 0; LET dGrupo5_no_hit = 0; LET dgrupo8_hit = 0; LET dgrupo8_no_hit = 0;LET dgrupo9_hit=0;LEt dgrupo9_no_hit=0;
LET dgrupo6_no_hit = 0; LET dgrupo6_hit = 0; LET dgrupoA_no_hit = 0; LET dgrupoA_hit = 0; LET dgrupo7_hit = 0; LET dgrupo7_no_hit = 0; 
LET dTotalStatus = 0; LET dTotalGenStatus = 0; LET cBanCausa = "";
LET cBanTmp = "N"; LET cCausaSol = ""; LET total_sol_rep = 0; LET total_sol_rep_hit = 0; LET total_sol_rep_no_hit = 0; LET dporc_status_hit = 0; LET dporc_status_no_hit = 0;
LET num_registros = 0; LET dtotal_status_hit = 0; LET dtotal_status_no_hit = 0; LET ptotal_x_status = 0; LET ptotal_x_status_hit = 0; LET ptotal_x_status_no_hit = 0;

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

	IF iSqlErr != 0 THEN
		IF cBanTmp = "S" THEN DROP TABLE total; DROP TABLE total_sol_group;

			IF pTpConsulta = '04' THEN DROP TABLE total_sucursal; DROP TABLE resultado_sucursal;
				ELIF pTpConsulta = '01' THEN DROP TABLE total_estado; DROP TABLE resultado_estado;
				ELIF pTpConsulta = '02' THEN DROP TABLE total_ciudad; DROP TABLE resultado_ciudad;
				ELIF pTpConsulta = '03' THEN DROP TABLE total_region; DROP TABLE resultado_region;
				ELIF pTpConsulta = '06' THEN DROP TABLE total_canal; DROP TABLE resultado_canal;			END IF
		END IF;
		LET cCodRet= iSqlErr; LET cMensajeRet= cErrorInfo;
		RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
	END IF;
END EXCEPTION;



--SET DEBUG FILE TO "/informix/Israel/sp_obtiene_tipoaltaprospecto.out";
--TRACE ON;

IF NVL(pEmpresa,'') = '' THEN
	LET cCodRet = '000001'; LET cMensajeRet = 'Es necesario indicar la empresa para ejecutar el proceso';
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
END IF;

SELECT empresa INTO cEmpresa FROM bdinteg:si_empresas WHERE empresa = pEmpresa;

IF NVL(cEmpresa,'') = '' THEN
	LET cCodRet = '000002'; LET cMensajeRet = 'La empresa indicada no es valida';
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
END IF;

IF NVL(pTpConsulta,"") = "" THEN
	LET cCodRet = "000003"; LET cMensajeRet = "Es necesario indicar el tipo de consulta a realizar";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
END IF;

IF NVL(pFechaIni,"") = "" AND NVL(pFechaFin, "") = "" THEN
	LET cCodRet = "000004"; LET cMensajeRet = "Es necesario indicar al menos una fecha";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
END IF;

IF (NVL(pFechaIni,"") <> "" AND NVL(pFechaFin, "") <> "") AND (pFechaIni > pFechaFin) THEN
	LET cCodRet = "000005"; LET cMensajeRet = "La fecha inicial no debe ser mayor a la fecha final";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus;
END IF;

LET cBanTmp = "S";

IF pFechaIni IS NULL THEN LET pFechaIni = DATE(1); END IF; 
IF pFechaFin IS NULL THEN LET pFechaFin = pFechaIni; END IF;
	IF pEstatus IN ('AT','AP') THEN
		create temp table sol5
		(numcte char(20),status_solicitud char(2), sucursal char(4),abonomensualropa money , abonomensualmuebles money, abonomensualprestamos money, compromisos_bco decimal (14,2),fecha_insert date , canal_sol CHAR(1),
			autoriza_gte integer,confirmado  CHAR(1),--JMAH RQM 09 420
			grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,
			grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer,grupo7_hit integer, grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,
			cantidad integer,cantidad_hit integer,cantidad_no_hit integer) with no log;

		create temp table sol4
			( numcte char(20),
			  tipo_alta char(3)
			) with no log;

		create temp table sol3
		(numcte char(20),status_solicitud char(2), sucursal char(4),abonomensualropa money , abonomensualmuebles money, abonomensualprestamos money, compromisos_bco decimal (14,2),fecha_insert date , canal_sol CHAR(1),
			autoriza_gte integer,confirmado  CHAR(1),--JMAH RQM 09 420
			grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,
			grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer,grupo7_hit integer, grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,
			cantidad integer,cantidad_hit integer,cantidad_no_hit integer,tipo_alta char(3),tipo_alta_causa char(3)--JMAH RQM 09 420
		) with no log;

		create temp table total
		(numcte char(20),status_solicitud char(2), sucursal char(4),abonomensualropa money , abonomensualmuebles money, abonomensualprestamos money, compromisos_bco decimal (14,2),fecha_insert date , canal_sol CHAR(1),
			autoriza_gte integer,confirmado  CHAR(1),--JMAH RQM 09 420
			grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,
			grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer,grupo7_hit integer, grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,
			cantidad integer,cantidad_hit integer,cantidad_no_hit integer,tipo_alta char(3),tipo_alta_causa char(3), --JMAH RQM 09 420
			descripcion char(40),orden_reporte smallint,ciudad char(3),estado char(2),numero_region smallint
		) with no log;

		insert into sol5
		SELECT a.numcte,a.status_solicitud, a.sucursal,b.abonomensualropa, b.abonomensualmuebles, b.abonomensualprestamos, b.compromisos_bco,a.fecha_insert,a.canal_sol,
		(CASE WHEN (nvl(c.causa_solicitud,'') <> '') AND cau.tipo_auto <> 3 THEN 1 
			ELSE  CASE WHEN (nvl(c.causa_solicitud,'') <> '') AND cau.tipo_auto = 3 THEN 2
			ELSE CASE WHEN (nvl(c.causa_solicitud,'') = '') AND a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitud_os) THEN 3
			ELSE CASE WHEN (nvl(c.causa_solicitud,'') = '')  THEN 5
			ELSE 4 END END END END ) autoriza_gte,
			CASE WHEN (	SELECT COUNT(*)
				FROM bdinteg:"informix".si_telefonos
				WHERE numcte = a.numcte
				AND tipo_tel in (1,2) 
				AND status_tel = 'A' 
				AND NVL(verificado,'F') = 'V') >= 1 THEN 'V' ELSE 'F'END ,   
            sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND b.evalua_cc IN ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END ) grupo1_hit,
            sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(b.evalua_cc,'') IN ('X','')  and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END) grupo1_no_hit,
            sum(CASE WHEN (nvl(b.grupo,'') = '2') AND b.evalua_cc IN ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END) grupo2_hit,
            sum(CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(b.evalua_cc,'') IN ('X','') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END) grupo2_no_hit,
            sum(CASE WHEN (nvl(b.grupo,'') = '3') AND b.evalua_cc IN ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END) grupo3_hit,
            sum(CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(b.evalua_cc,'') IN ('X','') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END) grupo3_no_hit,
            sum(CASE WHEN (nvl(b.grupo,'') = '5') AND not(NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and b.evalua_cc in ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END) grupo5_hit,
            sum(CASE WHEN (nvl(b.grupo,'') = '5') AND not(NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and NVL(b.evalua_cc,'') IN ('X','') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END) grupo5_no_hit,
            sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND b.evalua_cc IN ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END) grupo6_hit,
            sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(b.evalua_cc,'') IN ('X','') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END) grupo6_no_hit,
            sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND not(NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and b.evalua_cc IN ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END) grupoA_hit,
            sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND not(NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and NVL(b.evalua_cc,'') IN ('X','') and   NVL(rev.excluye_validacion,0) = 0    THEN 1 ELSE 0 END) grupoA_no_hit,
            0 grupo7_hit, 
            SUM(CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END ) grupo7_no_hit,
            SUM(CASE WHEN (nvl(b.Grupo,'') = '8') AND b.evalua_cc IN ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END ) grupo8_hit,
            SUM(CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(b.evalua_cc,'') IN ('X','')and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END ) grupo8_no_hit,
            SUM(CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN ('0','1','2','3','4') THEN 1 ELSE 0 END ) grupo9_hit,
            SUM(CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN ('X','') THEN 1 ELSE 0 END ) grupo9_no_hit,
            sum(CASE WHEN (nvl(b.grupo,'') in ('1','4'))and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.grupo,'') = '2')and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.grupo,'') = '3')and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.grupo,'') = '5') and not(NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.Grupo,'') = '6') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END + 
                CASE WHEN (nvl(b.Grupo,'') = 'A') and not(NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.Grupo,'') = '8')  and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +(CASE WHEN rev.excluye_validacion = 1 THEN 1 ELSE 0 END ) )  cantidad,
            sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND b.evalua_cc IN ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.grupo,'') = '2') AND b.evalua_cc IN ('0','1','2','3','4')and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.grupo,'') = '3') AND b.evalua_cc IN ('0','1','2','3','4')and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.grupo,'') = '5') AND not(NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and b.evalua_cc in ('0','1','2','3','4')and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.Grupo,'') = '6') AND b.evalua_cc IN ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END + 
                CASE WHEN (nvl(b.Grupo,'') = 'A') AND not(NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and b.evalua_cc IN ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.Grupo,'') = '8') AND b.evalua_cc IN ('0','1','2','3','4') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END  + (CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN ('0','1','2','3','4') THEN 1 ELSE 0 END ) ) 
                 cantidad_hit,
            sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(b.evalua_cc,'') IN ('X','') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(b.evalua_cc,'') IN ('X','')and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(b.evalua_cc,'') IN ('X','')and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.grupo,'') = '5') AND not(NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and NVL(b.evalua_cc,'') IN ('X','') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(b.evalua_cc,'') IN ('X','') and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END + 
                CASE WHEN (nvl(b.Grupo,'') = 'A') AND not(NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and NVL(b.evalua_cc,'') IN ('X','')  and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(c.cliente_pros,'') <> '' and nvl(a.num_producto,'') = '6500') and NVL(rev.excluye_validacion,0) = 0 THEN 1 ELSE 0 END +
                CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(b.evalua_cc,'') IN ('X','')and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END  +  (CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN  ('X','') THEN 1 ELSE 0 END ))  cantidad_no_hit
		from bdisolic:ss_solicitudes a
		join bdisolic:ss_resum_scor_fin b on (a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud)
		join bdisolic:ss_autorizacion c on (a.empresa = c.empresa AND a.num_solicitud = c.num_solicitud AND a.status_solicitud = c.status_solicitud)
		left outer join "informix".ss_causas_sol cau on (cau.status_solicitud = a.status_solicitud and cau.causa_solicitud = c.causa_solicitud)
		left outer join  "informix".ss_revision_determinacion rev on (rev.empresa= a.empresa and rev.num_solicitud= a.num_solicitud)
		WHERE c.fecha_entrada = (select max(fecha_entrada) from bdisolic:ss_autorizacion where a.empresa = empresa and a.num_solicitud = num_solicitud and a.status_solicitud = status_solicitud)
		AND a.num_producto = 	pProducto AND a.fecha_insert >= pFechaIni AND a.fecha_insert <= pFechaFin AND a.status_solicitud = pEstatus 
		GROUP BY 1,2,3,4,5,6,7,8,9,10; -- INTO temp sol5 WITH NO LOG;
		
		--Aperturadas sin entregar  - s 206 ASE
		--Aperturada con lineas minimas - s 207	  ALM

		IF pProducto = '6500' AND pEstatus ='AP' THEN 
				insert into sol4
				SELECT a.numcte,(CASE WHEN c.causa_sitesp = 206 THEN 'ASE' 
								 WHEN c.causa_sitesp = 207 THEN  'ALM' ELSE 'APN' END) as tipo_alta
					FROM bdisolic:ss_solicitudes a, sol5 b, bdisolic:ss_nuevo_parametrico c
					WHERE a.numcte = b.numcte
					and a.num_solicitud= c.num_solicitud
					and a.num_solicitud= c.num_solicitud
					and a.num_producto =pProducto
					AND a.fecha_insert >= pFechaIni 
					AND a.fecha_insert <= pFechaFin 
					AND a.status_solicitud = pEstatus;
		END IF;			
		
		insert into sol4
		SELECT a.numcte,(CASE WHEN a.tipo_alta = 1 AND b.autoriza_gte = 0 THEN 'ASP' 
							WHEN a.tipo_alta = 1 AND b.autoriza_gte = 1 THEN 'ASG'
							WHEN a.tipo_alta = 2 AND b.autoriza_gte = 0 THEN 'ACP' 
							WHEN a.tipo_alta = 2 AND b.autoriza_gte = 1 THEN 'ACG'
							WHEN a.tipo_alta = 0 AND b.autoriza_gte = 3 THEN 'ACP'
							WHEN a.tipo_alta = 0 AND b.autoriza_gte = 1 THEN 'ACG'
							WHEN a.tipo_alta = 1 AND b.autoriza_gte = 3 THEN 'ACP'
							WHEN a.tipo_alta = 2 AND b.autoriza_gte = 3 THEN 'ACP'
							WHEN b.autoriza_gte = 5 THEN 'APN'  ELSE a.tipo_alta END) as tipo_alta
			FROM bdiprospectos:pr_cliente a, sol5 b WHERE a.numcte = b.numcte
			and a.numcte not in (select  numcte from sol4);
		


		insert into  sol3	
		SELECT a.*, (CASE WHEN nvl(b.tipo_alta, '') <> '' THEN b.tipo_alta 
						WHEN nvl(b.tipo_alta, '') = '' AND a.autoriza_gte = 1 THEN 'ASG'
						WHEN nvl(b.tipo_alta, '') = '' AND a.autoriza_gte = 2 THEN 'ACG'
						WHEN nvl(b.tipo_alta, '') = '' AND a.autoriza_gte = 3 THEN 'ACP' 
						WHEN nvl(b.tipo_alta, '') = '' AND a.autoriza_gte = 4 THEN 'ASP' 
						WHEN nvl(b.tipo_alta, '') = '' AND a.autoriza_gte = 5 THEN 'APN' ELSE '' END) as tipo_alta ,
						CASE WHEN NVL(a.confirmado,'') =  'V'  THEN 'CTC' ELSE 'STC' END
			FROM sol5 a LEFT OUTER JOIN sol4 b ON a.numcte = b.numcte;
	END IF;
	
    insert into total
	SELECT a.*,b.descripcion, b.orden_reporte, c.ciudad, c.estado, r.numero_region
		FROM sol3 a,bdisolic:ss_status_sol b,bdinteg:si_sucursales s,bdinteg:si_ciudades c ,bdinteg:si_catciudades t
		left outer join bdinteg:si_regiones r on ( t.numero_region = r.numero_region)
	WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND activa_reporte = "1" AND a.sucursal = s.sucursal 
	AND s.ciudad = c.ciudad AND s.pais = c.pais AND s.estado = c.estado AND c.ciudad_coppel = t.numerociudad; 
	--INTO temp total with no log;
	
	create temp table total_sol_group
	( descripcion char(100),  tipo_alta  char(3),   tipo_alta_causa  char(3), grupo1_hit integer,grupo1_no_hit integer, grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,
		grupo3_no_hit integer, grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,  grupoA_hit integer,grupoA_no_hit integer,grupo7_hit integer,grupo7_no_hit integer,
		grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,total_x_status_hit integer,total_x_status_no_hit integer,porc_status_hit decimal (14,2),porc_status_no_hit decimal (14,2),
		total_x_status	integer,porc_status decimal (14,2),orden_reporte smallint
	) with no log;

	create temp table total_sol_group2
	( descripcion char(100),  tipo_alta  char(3),   tipo_alta_causa  char(3), grupo1_hit integer,grupo1_no_hit integer, grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,
		grupo3_no_hit integer, grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,  grupoA_hit integer,grupoA_no_hit integer,grupo7_hit integer,grupo7_no_hit integer,
		grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,total_x_status_hit integer,total_x_status_no_hit integer,porc_status_hit decimal (14,2),porc_status_no_hit decimal (14,2),
		total_x_status	integer,porc_status decimal (14,2),orden_reporte smallint
	) with no log;

	IF pTpConsulta = '04' THEN ---SUCURSAL
		create temp table total_sucursal
	    (  sucursal char(4),
		   total integer,
		   total_hit integer,
		   total_no_hit integer
	     ) with no log;
		 
		create temp table resultado_sucursal
		(numcte char(20),status_solicitud char(2), sucursal char(4),abonomensualropa money , abonomensualmuebles money, abonomensualprestamos money, compromisos_bco decimal (14,2),fecha_insert date ,
			autoriza_gte integer,confirmado  CHAR(1),--JMAH RQM 09 420
			grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,
			grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer,grupo7_hit integer, grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,
			cantidad integer,cantidad_hit integer,cantidad_no_hit integer,tipo_alta char(3),tipo_alta_causa char(3), --JMAH RQM 09 420
			descripcion char(40),orden_reporte smallint,ciudad char(3),estado char(2),numero_region smallint,total_porcentaje decimal(5,2) , total_porc_hit decimal(5,2),total_porc_no_hit decimal(5,2)
		) with no log;

		insert INTO  total_sucursal
		SELECT sucursal, sum(cantidad) total,sum(cantidad_hit) total_hit,sum(cantidad_no_hit) total_no_hit FROM total group by 1; --INTO temp total_sucursal with no log;
		
		IF pFiltro <> '' AND pEstatus <> '' THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE sucursal = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_sucursal;
		END IF;
		
		insert into resultado_sucursal
		SELECT a.*, round(cantidad / total * 100,2) total_porcentaje, CASE WHEN total_hit > 0 THEN round(cantidad_hit / total_hit * 100,2) ELSE 0 END total_porc_hit,CASE WHEN total_no_hit > 0 THEN round(cantidad_no_hit / total_no_hit * 100,2) ELSE 0 END total_porc_no_hit
		FROM total a, bdisolic:ss_status_sol b, total_sucursal c
		WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND a.sucursal = c.sucursal AND activa_reporte = "1";
		--INTO temp resultado_sucursal WITH NO LOG;

		IF (pFiltro = '' AND pEstatus <> '') or (pFiltro <> '' AND pEstatus <> '') THEN	--DETALLE
			
			insert into total_sol_group
			SELECT c.descripcion,a.tipo_alta,'', sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit, sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			 sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud
			AND a.tipo_alta = c.causa_solicitud AND ( a.sucursal = pFiltro or pFiltro='')
			AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte
			AND b.activa_reporte = "1"
		GROUP BY c.descripcion,a.tipo_alta,c.orden_reporte;
		
			
			insert into total_sol_group2
			SELECT c.descripcion,a.tipo_alta,a.tipo_alta_causa, sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit, sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			 sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud
			AND a.tipo_alta = c.causa_solicitud AND ( a.sucursal = pFiltro or pFiltro='')
			AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte
			AND b.activa_reporte = "1"
		GROUP BY c.descripcion,a.tipo_alta,a.tipo_alta_causa,c.orden_reporte; --ORDER BY c.orden_reporte  --INTO temp total_sol_group WITH NO LOG;
		END IF;
	END IF;

	IF pTpConsulta	 = '01' THEN ---ESTADO
	create temp table total_estado
	    (  estado char(2),
		   total integer,
		   total_hit integer,
		   total_no_hit integer
	     ) with no log;
		 
create temp table resultado_estado
(numcte char(20),
status_solicitud char(2), 
sucursal char(4),
abonomensualropa money , 
abonomensualmuebles money, 
abonomensualprestamos money, 
compromisos_bco decimal (14,2),
fecha_insert date ,
autoriza_gte integer,
confirmado  CHAR(1),--JMAH RQM 09 420
grupo1_hit integer,
grupo1_no_hit integer,
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer, 
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer,
tipo_alta char(3),
tipo_alta_causa char(3), --JMAH RQM 09 420
descripcion char(40),
orden_reporte smallint,
ciudad char(3),
estado char(2),
numero_region smallint,
total_porcentaje decimal(5,2) , 
total_porc_hit decimal(5,2),
total_porc_no_hit decimal(5,2)
) with no log;
		 
			insert into total_estado
			SELECT estado, sum(cantidad) total,sum(cantidad_hit) total_hit,sum(cantidad_no_hit) total_no_hit FROM total GROUP BY 1; -- INTO temp total_estado with no log;
			insert into resultado_estado
			SELECT a.*, round(cantidad / total * 100,2) total_porcentaje, CASE WHEN total_hit > 0 THEN round(cantidad_hit / total_hit * 100,2) ELSE 0 END total_porc_hit, CASE WHEN total_no_hit > 0 THEN round(cantidad_no_hit / total_no_hit * 100,2) ELSE 0 END total_porc_no_hit
			FROM total a, bdisolic:ss_status_sol b, total_estado c
			WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND a.estado = c.estado AND activa_reporte = "1"; -- INTO temp resultado_estado WITH NO LOG;

		IF pFiltro <> '' AND pEstatus <> '' THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE estado = pFiltro AND status_solicitud = pEstatus;
		ELSE 
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_estado;
		END IF;

		IF (pFiltro = '' AND pEstatus <> '') or (pFiltro <> '' AND pEstatus <> '') THEN
			insert into total_sol_group
			SELECT c.descripcion,a.tipo_alta,'',sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			 sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.estado = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,c.orden_reporte; --ORDER BY c.orden_reporte;  --INTO temp total_sol_group WITH NO LOG;
			
			insert into total_sol_group2
			SELECT c.descripcion,a.tipo_alta,a.tipo_alta_causa,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.estado = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,a.tipo_alta_causa,c.orden_reporte; --ORDER BY c.orden_reporte;  --INTO temp total_sol_group WITH NO LOG;
			
			
		END IF;
	END IF;

	IF pTpConsulta	 = '02' THEN ---CIUDAD
	create temp table total_ciudad
	    (  ciudad char(3),
		   estado char(2),
		   total integer,
		   total_hit integer,
		   total_no_hit integer
	     ) with no log;		 
create temp table resultado_ciudad
(numcte char(20),
status_solicitud char(2), 
sucursal char(4),
abonomensualropa money , 
abonomensualmuebles money, 
abonomensualprestamos money, 
compromisos_bco decimal (14,2),
fecha_insert date ,
autoriza_gte integer,
confirmado  CHAR(1),--JMAH RQM 09 420
grupo1_hit integer,
grupo1_no_hit integer,
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer, 
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer,
tipo_alta char(3),
tipo_alta_causa char(3), --JMAH RQM 09 420
descripcion char(40),
orden_reporte smallint,
ciudad char(3),
estado char(2),
numero_region smallint,
total_porcentaje decimal(5,2) , 
total_porc_hit decimal(5,2),
total_porc_no_hit decimal(5,2)
) with no log;
		insert into total_ciudad
		SELECT ciudad,estado, sum(cantidad) total, sum(cantidad_hit) total_hit, sum(cantidad_no_hit) total_no_hit FROM total group by 1,2; -- into temp total_ciudad with no log;
		
		insert into resultado_ciudad
		SELECT a.*, round(cantidad / total * 100,2) total_porcentaje, CASE WHEN total_hit > 0 THEN round(cantidad_hit / total_hit * 100,2) ELSE 0 END total_porc_hit, CASE WHEN total_no_hit > 0 THEN round(cantidad_no_hit / total_no_hit * 100,2) ELSE 0 END total_porc_no_hit
		FROM total a, bdisolic:ss_status_sol b, total_ciudad c
		WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND a.ciudad = c.ciudad AND a.estado = c.estado AND activa_reporte = "1" ;
		--INTO temp resultado_ciudad with no log;

		IF pFiltro <> '' AND pEstatus <> '' THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE estado = pretedocd and ciudad = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_ciudad;
		END IF;

		IF (pFiltro = '' AND pEstatus <> '') or (pFiltro <> '' AND pEstatus <> '') THEN ----DETALLE
		   
		   insert into total_sol_group
			SELECT c.descripcion,a.tipo_alta,'', sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(a.grupo5_hit) as grupo5_hit,sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(a.grupo7_hit) as grupo7_hit,sum(a.grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.estado = pretedocd or pretedocd='') AND (a.ciudad = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='')
			AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,c.orden_reporte; -- ORDER BY c.orden_reporte
			--into temp total_sol_group with no log;
			
			
		   
		   insert into total_sol_group2
			SELECT c.descripcion,a.tipo_alta,a.tipo_alta_causa, sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(a.grupo5_hit) as grupo5_hit,sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(a.grupo7_hit) as grupo7_hit,sum(a.grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.estado = pretedocd or pretedocd='') AND (a.ciudad = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='')
			AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,tipo_alta_causa,c.orden_reporte; -- ORDER BY c.orden_reporte
			--into temp total_sol_group with no log;
		END IF;
	END IF;
	IF pTpConsulta	 = '03' THEN ---REGION
	create temp table total_region
	    (  numero_region smallint,
		   total integer,
		   total_hit integer,
		   total_no_hit integer
	     ) with no log;
		 
create temp table resultado_region
(numcte char(20),
status_solicitud char(2), 
sucursal char(4),
abonomensualropa money , 
abonomensualmuebles money, 
abonomensualprestamos money, 
compromisos_bco decimal (14,2),
fecha_insert date ,
autoriza_gte integer,
confirmado  CHAR(1),--JMAH RQM 09 420
grupo1_hit integer,
grupo1_no_hit integer,
grupo2_hit integer,
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,
grupo5_hit integer,
grupo5_no_hit integer,
grupo6_hit integer,
grupo6_no_hit integer,
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer, 
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer,
tipo_alta char(3),
tipo_alta_causa char(3), --JMAH RQM 09 420
descripcion char(40),
orden_reporte smallint,
ciudad char(3),
estado char(2),
numero_region smallint,
total_porcentaje decimal(5,2) , 
total_porc_hit decimal(5,2),
total_porc_no_hit decimal(5,2)
) with no log;		 
		 
		insert into total_region
		SELECT numero_region, sum(cantidad) total, sum(cantidad_hit) total_hit, sum(cantidad_no_hit) total_no_hit FROM total group by 1;
		 --INTO temp total_region with no log;
		insert into resultado_region
		SELECT a.*, round(cantidad / total * 100,2) total_porcentaje, CASE WHEN total_hit > 0 THEN round(cantidad_hit / total_hit * 100,2) ELSE 0 END total_porc_hit, CASE WHEN total_no_hit > 0 THEN round(cantidad_no_hit / total_no_hit * 100,2) ELSE 0 END total_porc_no_hit
		FROM total a, bdisolic:ss_status_sol b, total_region c
		WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND a.numero_region = c.numero_region AND activa_reporte = "1";
		--INTO temp resultado_region WITH NO LOG;

		IF pFiltro <> '' AND pEstatus <> '' THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE numero_region = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_region;
		END IF;

		IF (pFiltro = '' AND pEstatus <> '') or (pFiltro <> '' AND pEstatus <> '') THEN --DETALLE
			insert into total_sol_group
			SELECT c.descripcion,a.tipo_alta,'', sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit, sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit, sum(a.grupo5_hit) as grupo5_hit, sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(a.grupo7_hit) as grupo7_hit, sum(a.grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status, 
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.numero_region = pFiltro or pFiltro ='') AND (a.status_solicitud = pEstatus OR pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,c.orden_reporte; --ORDER BY c.orden_reporte; -- INTO temp total_sol_group WITH NO LOG;
		
		
			insert into total_sol_group2
			SELECT c.descripcion,a.tipo_alta,a.tipo_alta_causa, sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit, sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit, sum(a.grupo5_hit) as grupo5_hit, sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(a.grupo7_hit) as grupo7_hit, sum(a.grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status, 
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.tipo_alta = c.causa_solicitud
			AND (a.numero_region = pFiltro or pFiltro ='') AND (a.status_solicitud = pEstatus OR pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.tipo_alta,a.tipo_alta_causa,c.orden_reporte; --ORDER BY c.orden_reporte; -- INTO temp total_sol_group WITH NO LOG;
		
		
		END IF;
	END IF;
	IF pTpConsulta = '06' THEN ---CANAL  RQM 10 679-2 Agregar filtro por canal
		create temp table total_canal
	    (  canal_sol char(1),
		   total integer,
		   total_hit integer,
		   total_no_hit integer
	     ) with no log;
		 
		create temp table resultado_canal
		(numcte char(20),status_solicitud char(2), sucursal char(4),abonomensualropa money , abonomensualmuebles money, abonomensualprestamos money, compromisos_bco decimal (14,2),fecha_insert date , canal_sol CHAR(1),
			autoriza_gte integer,confirmado  CHAR(1),--JMAH RQM 09 420
			grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,
			grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer,grupo7_hit integer, grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,
			cantidad integer,cantidad_hit integer,cantidad_no_hit integer,tipo_alta char(3),tipo_alta_causa char(3), --JMAH RQM 09 420
			descripcion char(40),orden_reporte smallint,ciudad char(3),estado char(2),numero_region smallint,total_porcentaje decimal(5,2) , total_porc_hit decimal(5,2),total_porc_no_hit decimal(5,2)
		) with no log;

		insert INTO  total_canal
		SELECT canal_sol, sum(cantidad) total,sum(cantidad_hit) total_hit,sum(cantidad_no_hit) total_no_hit FROM total group by 1; --INTO temp total_canal with no log;
		
		IF pFiltro <> '' AND pEstatus <> '' THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE canal_sol = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_canal;
		END IF;
		
		insert into resultado_canal
		SELECT a.*, round(cantidad / total * 100,2) total_porcentaje, CASE WHEN total_hit > 0 THEN round(cantidad_hit / total_hit * 100,2) ELSE 0 END total_porc_hit,CASE WHEN total_no_hit > 0 THEN round(cantidad_no_hit / total_no_hit * 100,2) ELSE 0 END total_porc_no_hit
		FROM total a, bdisolic:ss_status_sol b, total_canal c
		WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND a.canal_sol = c.canal_sol AND activa_reporte = "1";
		--INTO temp total_canal WITH NO LOG;

		IF (pFiltro = '' AND pEstatus <> '') or (pFiltro <> '' AND pEstatus <> '') THEN	--DETALLE
			
			insert into total_sol_group
			SELECT c.descripcion,a.tipo_alta,'', sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit, sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			 sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud
			AND a.tipo_alta = c.causa_solicitud AND ( a.canal_sol = pFiltro or pFiltro='')
			AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte
			AND b.activa_reporte = "1"
		GROUP BY c.descripcion,a.tipo_alta,c.orden_reporte;
		
			
			insert into total_sol_group2
			SELECT c.descripcion,a.tipo_alta,a.tipo_alta_causa, sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit, sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,
            sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit,
			 sum(a.grupo9_hit) as grupo9_hit,sum(a.grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			c.orden_reporte --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud
			AND a.tipo_alta = c.causa_solicitud AND ( a.canal_sol = pFiltro or pFiltro='')
			AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte
			AND b.activa_reporte = "1"
		GROUP BY c.descripcion,a.tipo_alta,a.tipo_alta_causa,c.orden_reporte; --ORDER BY c.orden_reporte  --INTO temp total_sol_group WITH NO LOG;
		END IF;
	END IF;	
	
	
create temp table total_sol_group_aux(
descripcion char(30),
tipo_alta char(3),
tipo_alta_causa char(3),
grupo1_hit integer, 
grupo1_no_hit integer,
grupo2_hit integer, 
grupo2_no_hit integer,
grupo3_hit integer,
grupo3_no_hit integer,  
grupo5_hit integer, 
grupo5_no_hit integer,
grupo6_hit integer, 
grupo6_no_hit integer, 
grupoA_hit integer,
grupoA_no_hit integer,
grupo7_hit integer,
grupo7_no_hit integer,
grupo8_hit integer, 
grupo8_no_hit integer,
grupo9_hit integer,
grupo9_no_hit integer,
total_x_status_hit integer,
total_x_status_no_hit integer, 
porc_status_hit DECIMAL(18,2),
porc_status_no_hit DECIMAL(18,2),
total_x_status integer, 
porc_status DECIMAL(18,2), 
orden_rerpote smallint
) with no log;

---------FIN EVALUACIONES DE LA CLASIFICACION DE LA CAUSA CPS
		insert into total_sol_group_aux
		SELECT 'Total Solicitudes' descripcion,'' tipo_alta, '',sum(grupo1_hit) grupo1_hit, sum(grupo1_no_hit ) grupo1_no_hit, sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit) grupo2_no_hit, sum(grupo3_hit) grupo3_hit, sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit) grupo5_no_hit,
			sum(grupo6_hit) as grupo6_hit, sum(grupo6_no_hit) as grupo6_no_hit, sum(grupoA_hit) as grupoA_hit,sum(grupoA_no_hit) as grupoA_no_hit,sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit,sum(grupo8_hit) grupo8_hit, sum(grupo8_no_hit) grupo8_no_hit,
			sum(grupo9_hit) as grupo9_hit,sum(grupo9_no_hit) as grupo9_no_hit,
			sum(grupo1_hit+grupo2_hit+grupo3_hit+grupo5_hit+grupo6_hit+grupoa_hit+grupo7_hit+grupo8_hit+grupo9_hit) total_x_status_hit,
			sum(grupo1_no_hit+grupo2_no_hit+grupo3_no_hit+grupo5_no_hit+grupo6_no_hit+grupoA_no_hit+grupo7_no_hit+grupo8_no_hit+grupo9_no_hit) total_x_status_no_hit, sum(porc_status_hit) porc_status_hit,sum(porc_status_no_hit) porc_status_no_hit,
			sum(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+grupo6_no_hit+grupoA_hit+grupoA_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit+grupo9_hit+grupo9_no_hit) total_x_status, sum(porc_status) porc_status, 997 orden_rerpote
		FROM total_sol_group; -- INTO temp total_sol_group_aux;

		select sum(total_x_status) INTO ptotal_x_status from total_sol_group_aux;
		select sum(total_x_status_hit) INTO ptotal_x_status_hit from total_sol_group_aux;
		select sum(total_x_status_no_hit) INTO ptotal_x_status_no_hit from total_sol_group_aux;

		IF ptotal_x_status = 0 THEN LET ptotal_x_status = 1;
		ELIF ptotal_x_status_hit = 0 THEN LET ptotal_x_status_hit = 1;
		ELIF ptotal_x_status_no_hit = 0 THEN LET ptotal_x_status_no_hit = 1;
		END IF;

		INSERT INTO total_sol_group_aux
		SELECT '% de Solicitudes' descripcion,'' tipo_alta, '',
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100,round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo2_hit)/(ptotal_x_status),2) * 100,round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100,round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupo5_hit)/(ptotal_x_status),2) * 100,round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo6_hit)/(ptotal_x_status),2) * 100,round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupoA_hit)/(ptotal_x_status),2) * 100,round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo7_hit)/(ptotal_x_status),2) * 100,round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupo8_hit)/(ptotal_x_status),2) * 100,round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupo9_hit)/(ptotal_x_status),2) * 100,round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, --cada uno de los status		
		round(sum(grupo1_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status_hit),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status_hit),2) * 100+
		round(sum(grupo6_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo7_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status_hit),2) * 100, --total x status_hit
		round(sum(grupo1_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status_no_hit),2) * 100+
		round(sum(grupo3_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status_no_hit),2) * 100+
		round(sum(grupo6_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status_no_hit),2) * 100, --total x status_no_hit
		round(sum(grupo1_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status_hit),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status_hit),2) * 100+
		round(sum(grupo6_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo7_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status_hit),2) * 100, --porc de total x status_hit
		round(sum(grupo1_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status_no_hit),2) * 100+
		round(sum(grupo3_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status_no_hit),2) * 100+
		round(sum(grupo6_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status_no_hit),2) * 100, --porc de total x status_hit
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100+round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo6_hit)/(ptotal_x_status),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, ---total x status
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100+round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo6_hit)/(ptotal_x_status),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, 998 ----porc de total x status
		FROM total_sol_group_aux; 

		INSERT INTO total_sol_group 
		SELECT * FROM total_sol_group_aux;
--/*
		SELECT COUNT(*) INTO num_registros FROM total_sol_group;
		IF num_registros > 2 THEN
			IF pEstatus <> '' THEN
			FOREACH WITH HOLD
				SELECT descripcion,tipo_alta,grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit,grupo6_hit,grupo6_no_hit,grupoA_hit,grupoA_no_hit,grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit,grupo9_hit,grupo9_no_hit,total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status
				INTO cDescripcion,cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus
				FROM total_sol_group ORDER BY orden_reporte
				
				RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit, dgrupo2_hit,dgrupo2_no_hit, dgrupo3_hit,dgrupo3_no_hit, dgrupo5_hit, dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit, dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus WITH RESUME;
				FOREACH WITH HOLD
					SELECT descripcion,tipo_alta_causa,grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit,grupo6_hit,grupo6_no_hit,grupoA_hit,grupoA_no_hit,grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit,grupo9_hit,grupo9_no_hit,total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status
					INTO cDescripcion,cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus
					FROM total_sol_group2
					WHERE tipo_alta = cStatusSol
					ORDER BY orden_reporte
					
					IF cStatusSol = "CTC" THEN
						LET cDescripcion = ".     Con TelÃÂ©fono Confirmado";
					ELSE
						LET cDescripcion = ".     Sin TelÃÂ©fono Confirmado";
					END IF;
					
				RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit, dgrupo2_hit,dgrupo2_no_hit, dgrupo3_hit,dgrupo3_no_hit, dgrupo5_hit, dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit, dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus WITH RESUME;
				END FOREACH;				
				
		
			END FOREACH;
			ELSE
			FOREACH WITH HOLD
				SELECT descripcion,status_solicitud,grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit,grupo6_hit,grupo6_no_hit,grupoA_hit,grupoA_no_hit,grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit,grupo9_hit,grupo9_no_hit,total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status
				INTO cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus
				FROM total_sol_group ORDER BY orden_reporte
				RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit, dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus WITH RESUME;
			END FOREACH;
			END IF;
		ELSE
			LET cCodRet = '000006'; LET cMensajeRet = 'No hay informacion para este producto en este periodo';
			RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit,dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus WITH RESUME;
		END IF
--*/
		DROP TABLE total; DROP TABLE total_sol_group;  DROP TABLE total_sol_group2; DROP TABLE total_sol_group_aux;

		DROP TABLE sol3; DROP TABLE sol4; DROP TABLE sol5;

		IF pTpConsulta = '04' THEN DROP TABLE total_sucursal; DROP TABLE resultado_sucursal;
		ELIF pTpConsulta = '01' THEN DROP TABLE total_estado; DROP TABLE resultado_estado;
		ELIF pTpConsulta = '02' THEN DROP TABLE total_ciudad; DROP TABLE resultado_ciudad;
		ELIF pTpConsulta = '03' THEN DROP TABLE total_region; DROP TABLE resultado_region;
		ELIF pTpConsulta = '06' THEN DROP TABLE total_canal; DROP TABLE resultado_canal;		END IF;

END
END PROCEDURE
