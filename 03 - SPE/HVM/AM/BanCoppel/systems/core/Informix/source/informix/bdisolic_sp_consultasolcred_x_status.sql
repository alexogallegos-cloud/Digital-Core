CREATE PROCEDURE "informix".sp_consultasolcred_x_status(pEmpresa CHAR(3),pTpConsulta CHAR(2),pFiltro VARCHAR(4),pProducto CHAR(4),pFechaIni DATE,pFechaFin DATE,pEstatus CHAR(2),pretedocd CHAR(2),psubcausa CHAR(3),  ptipomodelohit CHAR(5))
RETURNING
	CHAR(6) AS cod_ret, VARCHAR(80,1) AS mensaje_ret, VARCHAR(200,1) AS descripcion_status, VARCHAR(3,1) AS status_sol, 
	DECIMAL(18,2) AS grupo1_hit, DECIMAL(18,2) AS grupo1_no_hit, DECIMAL(18,2) AS grupo2_hit, DECIMAL(18,2) AS grupo2_no_hit, DECIMAL(18,2) AS grupo3_hit, DECIMAL(18,2) AS grupo3_no_hit,
	DECIMAL(18,2) AS grupo5_hit, DECIMAL(18,2) AS grupo5_no_hit, DECIMAL(18,2) AS grupo6_hit,DECIMAL(18,2) AS grupo6_no_hit,  DECIMAL(18,2) AS grupoA_hit, DECIMAL(18,2) AS grupoA_no_hit, 
    DECIMAL(18,2) AS grupo7_hit, DECIMAL(18,2) AS grupo7_no_hit, DECIMAL(18,2) AS grupo8_hit, DECIMAL(18,2) AS grupo8_no_hit, DECIMAL(18,2) AS grupo9_hit, DECIMAL(18,2) AS grupo9_no_hit ,DECIMAL(18,2) AS total_x_estatus_hit,
	DECIMAL(18,2) AS total_x_estatus_no_hit, DECIMAL(18,2) AS porc_status_hit, DECIMAL(18,2) AS porc_status_no_hit, DECIMAL(18,2) AS total_x_estatus,
	DECIMAL(18,2) AS porc_status, CHAR(1) AS tiene_causas, CHAR(5) AS tipo_modelo_hit;


	--------- CONTROL DE CAMBIOS
--------------------------------------------------------------------------------
-- Autor: Luis Ãngel JuÃ¡rez VÃ¡zquez, Gustavo Fuentes LÃ³pez
-- CreaciÃ³n: Se ha agregado la columna de tipo modelo hit para identificar si la solicitus es de tipo <=3, >3 o no hit

-- Fecha de CreaciÃ³n: 20-08-2022
-- Proyecto: RQM 09 613- Modelo de prÃ©stamo personal Bancoppel
---------------------------------------------------------------------------------

DEFINE iSqlErr, iIsamErr,total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit INTEGER;
DEFINE cErrorInfo CHAR(80); DEFINE cCodRet CHAR(6); DEFINE cMensajeRet VARCHAR(80,1); DEFINE cEmpresa CHAR(3);
DEFINE cStatusSol VARCHAR(3,1); DEFINE cDescripcion VARCHAR(200,1); DEFINE dSituacionPago DECIMAL(5,2);
DEFINE dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit ,dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit, dTotalStatus, dTotalGenStatus DECIMAL(18,2);
DEFINE dGrupo6_hit, dGrupo6_no_hit, dGrupoA_hit, dGrupoA_no_hit, dgrupo7_hit, dgrupo7_no_hit, dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,ptotal_x_status,ptotal_x_status_hit,ptotal_x_status_no_hit DECIMAL(18,2);
DEFINE cBanCausa,cBanTmp CHAR(1); DEFINE cCausaSol VARCHAR(3,1); DEFINE num_registros SMALLINT; DEFINE vtipo_modelo_hit CHAR(5);

LET iSqlErr = 0; LET iIsamErr = 0; LET cErrorInfo = ''; LET cCodRet = '000000'; LET cMensajeRet = 'Se ejecutï¿½ la consulta correctamente';
LET cEmpresa = ''; LET cStatusSol = ''; LET cDescripcion = ''; LET dSituacionPago = 0; LET dgrupo1_hit = 0; LET dgrupo1_no_hit = 0; LET dgrupo2_hit = 0;
LET dgrupo2_no_hit = 0; LET dgrupo3_hit = 0; LET dgrupo3_no_hit = 0; LET dGrupo5_hit = 0; LET dGrupo5_no_hit = 0; LET dgrupo8_hit = 0; LET dgrupo8_no_hit = 0; LET dgrupo9_hit=0;LEt dgrupo9_no_hit=0; 
LET dgrupo6_no_hit = 0; LET dgrupo6_hit = 0; LET dgrupoA_no_hit = 0; LET dgrupoA_hit = 0; LET dgrupo7_hit = 0; LET dgrupo7_no_hit = 0; LET dTotalStatus = 0; LET dTotalGenStatus = 0; LET cBanCausa = "";
LET cBanTmp = "N"; LET cCausaSol = ""; LET total_sol_rep = 0; LET total_sol_rep_hit = 0; LET total_sol_rep_no_hit = 0; LET dporc_status_hit = 0; LET dporc_status_no_hit = 0;
LET num_registros = 0; LET dtotal_status_hit = 0; LET dtotal_status_no_hit = 0; LET ptotal_x_status = 0; LET ptotal_x_status_hit = 0; LET ptotal_x_status_no_hit = 0; LET vtipo_modelo_hit = '';

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

	IF iSqlErr != 0 THEN
		 IF cBanTmp = "S" THEN DROP TABLE Tsolicitud; DROP TABLE sol2; DROP TABLE total; DROP TABLE total_sol_group;
		 	IF psubcausa <> '' THEN DROP TABLE sol3; DROP TABLE sol4; END IF;
		 	IF pTpConsulta = '04' THEN DROP TABLE total_sucursal;
		 		ELIF pTpConsulta = '01' THEN DROP TABLE total_estado; 
		 		ELIF pTpConsulta = '02' THEN DROP TABLE total_ciudad; 
		 		ELIF pTpConsulta = '03' THEN DROP TABLE total_region; 
		 	END IF
		 END IF;
		LET cCodRet= iSqlErr; LET cMensajeRet= cErrorInfo || '--' ||iIsamErr;
		RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,
               dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa, vtipo_modelo_hit;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/sysifx/marcov/sp_consultasolcred_x_status.out";
--TRACE ON;


IF NVL(pEmpresa,'') = '' THEN
	LET cCodRet = '000001'; LET cMensajeRet = 'Es necesario indicar la empresa para ejecutar el proceso';
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa, vtipo_modelo_hit;
END IF;

SELECT empresa INTO cEmpresa FROM bdinteg:si_empresas WHERE empresa = pEmpresa;

IF NVL(cEmpresa,'') = '' THEN
	LET cCodRet = '000002'; LET cMensajeRet = 'La empresa indicada no es valida';
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa, vtipo_modelo_hit;
END IF;

IF NVL(pTpConsulta,"") = "" THEN
	LET cCodRet = "000003"; LET cMensajeRet = "Es necesario indicar el tipo de consulta a realizar";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa, vtipo_modelo_hit;
END IF;

IF NVL(pFechaIni,"") = "" AND NVL(pFechaFin, "") = "" THEN
	LET cCodRet = "000004"; LET cMensajeRet = "Es necesario indicar al menos una fecha";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa, vtipo_modelo_hit;
END IF;

IF (NVL(pFechaIni,"") <> "" AND NVL(pFechaFin, "") <> "") AND (pFechaIni > pFechaFin) THEN
	LET cCodRet = "000005"; LET cMensajeRet = "La fecha inicial no debe ser mayor a la fecha final";
	RETURN cCodRet,cMensajeRet,cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit,dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,dGrupo5_hit,dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dGrupoA_hit,dGrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus,cBanCausa, vtipo_modelo_hit;
END IF;

LET cBanTmp = "S";

IF pFechaIni IS NULL THEN LET pFechaIni = DATE(1); END IF; 
IF pFechaFin IS NULL THEN LET pFechaFin = pFechaIni; END IF;

 create temp table Tsolicitud (numcte char(20),status_solicitud char(2),causa_solicitud char(3), sucursal char(4),
 	abonomensualropa money,abonomensualmuebles money,abonomensualprestamos money,
 	compromisos_bco decimal (14,2),fecha_insert date,
 	grupo1_hit integer,grupo1_no_hit integer, grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,grupo5_hit integer,
     grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer, grupo7_hit integer, grupo7_no_hit integer,
 	grupo8_hit integer,grupo8_no_hit integer, grupo9_hit integer,grupo9_no_hit integer,cantidad integer,cantidad_hit integer,cantidad_no_hit integer,
 	sub_causa_solicitud char(3), tipo_modelo_hit CHAR(5)) with no log;

 create temp table sol2 (numcte char(20),status_solicitud char(2),causa_solicitud char(3), sucursal char(4),
 	abonomensualropa money,abonomensualmuebles money,abonomensualprestamos money,
 	compromisos_bco decimal (14,2),fecha_insert date,
 	grupo1_hit integer,grupo1_no_hit integer, grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,grupo5_hit integer,
     grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer, grupo7_hit integer, grupo7_no_hit integer,
 	grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,cantidad integer,cantidad_hit integer,cantidad_no_hit integer,
 	sub_causa_solicitud char(3), tipo_modelo_hit CHAR(5)) with no log;	
	
	
		insert into Tsolicitud
			Select * from (SELECT a.numcte,a.status_solicitud, c.causa_solicitud, a.sucursal,b.abonomensualropa, b.abonomensualmuebles, b.abonomensualprestamos, b.compromisos_bco,a.fecha_insert, 
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
                CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(b.evalua_cc,'') IN ('X','')and   NVL(rev.excluye_validacion,0) = 0   THEN 1 ELSE 0 END  +  (CASE WHEN rev.excluye_validacion = 1 AND b.evalua_cc IN  ('X','') THEN 1 ELSE 0 END ))  cantidad_no_hit, '' sub_causa_solicitud,
            	(case when count(d.TL06) = 0 AND pProducto IN ('6300', '6800', '7600', '7700') then '0' 
				else case when count(d.TL06) > 3 AND pProducto IN ('6300', '6800', '7600', '7700') then '> 3' 
				else case when count(d.TL06) <= 3 AND pProducto IN ('6300', '6800', '7600', '7700') then '<= 3' 
				else 'N/A' end end end) AS tipo_modelo_hit
				from bdisolic:ss_solicitudes a
				inner join bdisolic:ss_resum_scor_fin b on a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud 
				inner join bdisolic:ss_autorizacion c on a.empresa = c.empresa AND a.num_solicitud = c.num_solicitud AND a.status_solicitud = c.status_solicitud 
				left outer join "informix".ss_revision_determinacion rev on rev.empresa= a.empresa and rev.num_solicitud= a.num_solicitud
				left join BDIBURO:"informix".BR_TL d on a.numcte = d.num_cliente AND d.TL06 = 'I'
				AND c.fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where a.empresa = empresa and a.num_solicitud = num_solicitud and a.status_solicitud = status_solicitud)
				AND a.num_producto = pProducto AND a.fecha_insert >= pFechaIni AND a.fecha_insert <= pFechaFin 
				AND ((a.status_solicitud = pEstatus or pEstatus = '') AND (causa_solicitud = psubcausa or psubcausa ='')) 
				GROUP BY 1,2,3,4,5,6,7,8,9) tabla where tipo_modelo_hit = ptipomodelohit;  

	IF pEstatus <> '' and psubcausa = '' THEN     	
	insert into sol2
		SELECT '', status_solicitud, causa_solicitud, sucursal,0,0,0,0,date(1),
		sum(grupo1_hit),sum(grupo1_no_hit),	sum(grupo2_hit), sum(grupo2_no_hit),sum(grupo3_hit),sum(grupo3_no_hit),
		sum(grupo5_hit),sum(grupo5_no_hit),sum(grupo6_hit),sum(grupo6_no_hit),sum(grupoA_hit),sum(grupoA_no_hit),
		0 grupo7_hit, sum(grupo7_no_hit),sum(grupo8_hit),sum(grupo8_no_hit),sum(grupo9_hit),sum(grupo9_no_hit),sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit),
		'' sub_causa_solicitud, tipo_modelo_hit
		from Tsolicitud 
		WHERE status_solicitud = pEstatus 
		GROUP BY 2,3,4, tipo_modelo_hit; 
	ELIF pEstatus = '' AND psubcausa = '' THEN	
		insert into sol2
		SELECT '',status_solicitud, '', sucursal,0,0,0,0,date(1),		
		sum(grupo1_hit),sum(grupo1_no_hit),	sum(grupo2_hit), sum(grupo2_no_hit),sum(grupo3_hit),sum(grupo3_no_hit),
		sum(grupo5_hit),sum(grupo5_no_hit),sum(grupo6_hit),sum(grupo6_no_hit),sum(grupoA_hit),sum(grupoA_no_hit),
		0 grupo7_hit, sum(grupo7_no_hit),sum(grupo8_hit),sum(grupo8_no_hit),sum(grupo9_hit),sum(grupo9_no_hit),sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit),
		'' sub_causa_solicitud, tipo_modelo_hit
		from Tsolicitud 		
		GROUP BY 2,4, tipo_modelo_hit;
	ELIF pEstatus <> '' AND psubcausa <> '' THEN
		---sol2
		insert into sol2
		SELECT 
		numcte,status_solicitud, causa_solicitud, sucursal,abonomensualropa, abonomensualmuebles, abonomensualprestamos, compromisos_bco,fecha_insert,
		sum(grupo1_hit),sum(grupo1_no_hit),	sum(grupo2_hit), sum(grupo2_no_hit),sum(grupo3_hit),sum(grupo3_no_hit),
		sum(grupo5_hit),sum(grupo5_no_hit),sum(grupo6_hit),sum(grupo6_no_hit),sum(grupoA_hit),sum(grupoA_no_hit),
		0 grupo7_hit, sum(grupo7_no_hit),sum(grupo8_hit),sum(grupo8_no_hit),sum(grupo9_hit),sum(grupo9_no_hit),sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit),
		'' sub_causa_solicitud, tipo_modelo_hit
		from Tsolicitud
        where status_solicitud = pEstatus AND causa_solicitud = psubcausa 		
		GROUP BY 1,2,3,4,5,6,7,8,9,tipo_modelo_hit;
		create temp table sol4( numcte char(20),institucion char(2) ) with no log;
		
		 create temp table sol3
		 ( numcte char(20), status_solicitud char(2), causa_solicitud char(3),sucursal char(4),
		   abonomensualropa money, abonomensualmuebles money,abonomensualprestamos money,compromisos_bco decimal (14,2),fecha_insert date,
		   grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,  grupo3_no_hit integer,
		   grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer,
		   grupo7_hit integer,  grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,cantidad integer,cantidad_hit integer,
		   cantidad_no_hit integer, sub_causa_solicitud char(3), tipo_modelo_hit CHAR(5), institucion char(2) ) with no log;
		  
		insert into sol4			
		SELECT numcte,max(a.institucion) as institucion FROM bdiburo:br_tl a,sol2 WHERE num_cliente = numcte GROUP BY numcte, tipo_modelo_hit ;
		insert into sol3
		SELECT a.*, b.institucion FROM sol2 a LEFT OUTER JOIN sol4 b ON a.numcte = b.numcte;
		delete from sol2;	
		insert into sol2
		SELECT a.numcte,a.status_solicitud,a.causa_solicitud,a.sucursal,0,0,0,0,date(1),
		       a.grupo1_hit,a.grupo1_no_hit,a.grupo2_hit,a.grupo2_no_hit,a.grupo3_hit,a.grupo3_no_hit,a.grupo5_hit,a.grupo5_no_hit,a.grupo6_hit,a.grupo6_no_hit,a.grupoA_hit,a.grupoA_no_hit,
               a.grupo7_hit,a.grupo7_no_hit,a.grupo8_hit,a.grupo8_no_hit,a.grupo9_hit,grupo9_no_hit,a.cantidad,a.cantidad_hit,a.cantidad_no_hit,
			(CASE WHEN a.institucion in ('BC','CC') AND a.abonomensualropa = 0 AND a.abonomensualmuebles = 0 AND a.abonomensualprestamos = 0 AND a.compromisos_bco = 0 THEN 'RC1'
				WHEN (a.institucion = '' OR a.institucion IS NULL) AND (a.abonomensualropa <> 0 OR a.abonomensualmuebles <> 0 OR a.abonomensualprestamos <> 0) AND a.compromisos_bco = 0 THEN 'RC2'
				WHEN (a.institucion = '' OR a.institucion IS NULL) AND (a.abonomensualropa = 0 OR a.abonomensualmuebles = 0 OR a.abonomensualprestamos = 0) AND a.compromisos_bco <> 0 THEN 'RC3'
				WHEN a.institucion in ('BC','CC') AND (a.abonomensualropa <> 0 OR a.abonomensualmuebles <> 0 OR a.abonomensualprestamos <> 0) AND a.compromisos_bco = 0 THEN 'RC4'
				WHEN a.institucion in ('BC','CC') AND (a.abonomensualropa <> 0 OR a.abonomensualmuebles <> 0 OR a.abonomensualprestamos <> 0) AND a.compromisos_bco <> 0 THEN 'RC5'
				WHEN (a.institucion = '' OR a.institucion IS NULL) AND (a.abonomensualropa <> 0 OR a.abonomensualmuebles <> 0 OR a.abonomensualprestamos <> 0) AND a.compromisos_bco <> 0 THEN 'RC6'
				WHEN a.institucion in ('BC','CC') AND (a.abonomensualropa = 0 OR a.abonomensualmuebles = 0 OR a.abonomensualprestamos = 0) AND a.compromisos_bco <> 0 THEN 'RC7'
			ELSE 'RC8' END) sub_causa_solicitud, tipo_modelo_hit FROM sol3 a;
	END IF;

	
 	create temp table total(numcte char(20),status_solicitud char(2), causa_solicitud char(3) , sucursal char(4),
 	abonomensualropa money,abonomensualmuebles money,abonomensualprestamos money,compromisos_bco decimal (14,2),fecha_insert date,
     grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer,
     grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,grupoA_hit integer,grupoA_no_hit integer,
     grupo7_hit integer,  grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,cantidad integer,cantidad_hit integer,
     cantidad_no_hit integer,sub_causa_solicitud char(3), tipo_modelo_hit CHAR(5), descripcion char (50),orden_reporte smallint, ciudad char(3),
     estado char(2),numero_region smallint) with no log;
	
 create temp table total_sol_group
 ( descripcion char(100),  status_solicitud  char(3), grupo1_hit integer,grupo1_no_hit integer, 
 grupo2_hit integer,grupo2_no_hit integer,grupo3_hit integer,grupo3_no_hit integer, grupo5_hit integer,
 grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,  grupoA_hit integer,grupoA_no_hit integer,
 grupo7_hit integer,grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,total_x_status_hit integer,
 total_x_status_no_hit integer,porc_status_hit decimal (14,2),porc_status_no_hit decimal (14,2),
 total_x_status	integer,porc_status decimal (14,2),tiene_causas integer,orden_reporte smallint, tipo_modelo_hit CHAR(5)) with no log;
	insert into total
	SELECT a.*,/*'',*/b.descripcion, b.orden_reporte, c.ciudad, c.estado, r.numero_region
		FROM sol2 a,bdisolic:ss_status_sol b,bdinteg:si_sucursales s,bdinteg:si_ciudades c ,bdinteg:si_catciudades t
		left outer join bdinteg:si_regiones r on ( t.numero_region = r.numero_region)
	WHERE b.empresa = pEmpresa AND a.status_solicitud = b.status_solicitud AND activa_reporte = "1" AND a.sucursal = s.sucursal
	AND s.ciudad = c.ciudad AND s.pais = c.pais AND s.estado = c.estado AND c.ciudad_coppel = t.numerociudad ;



	IF pTpConsulta = '04' THEN ---SUCURSAL
	create temp table total_sucursal( sucursal char(4),total integer,total_hit integer,total_no_hit integer) with no log;
	    insert into total_sucursal 
		SELECT sucursal, sum(cantidad) total,sum(cantidad_hit) total_hit,sum(cantidad_no_hit) total_no_hit FROM total group by 1,tipo_modelo_hit; 		
		IF pFiltro <> '' AND pEstatus = '' AND psubcausa = '' THEN
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_sucursal WHERE sucursal = pFiltro;
		ELIF pFiltro <> '' AND pEstatus <> '' AND (psubcausa = '' OR psubcausa <> '') THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE sucursal = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_sucursal;
		END IF;
		IF ( pFiltro <> '' AND pEstatus = '' AND psubcausa = '') or (pFiltro = '' AND pEstatus = '' AND psubcausa = '') THEN
			insert into total_sol_group
			SELECT a.descripcion,a.status_solicitud, sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit, 
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit, sum(grupo8_hit) as grupo8_hit,sum(grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit,  sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit, sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status, ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			(CASE WHEN a.status_solicitud IN ('RT','CM','CN','AT','AP') THEN 1 ELSE 0 END) as tiene_causas,b.orden_reporte, a.tipo_modelo_hit
			FROM total a, bdisolic:ss_status_sol b
			WHERE a.status_solicitud = b.status_solicitud and b.activa_reporte = "1" and ( a.sucursal = pFiltro or pFiltro ='' )
			GROUP BY a.descripcion,a.status_solicitud,b.orden_reporte,a.tipo_modelo_hit; 
		ELIF (pFiltro = '' AND pEstatus <> '' AND psubcausa = '') or (pFiltro <> '' AND pEstatus <> '' AND psubcausa = '' ) THEN	--DETALLE
			insert into total_sol_group
			SELECT c.descripcion,a.causa_solicitud, sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(grupo8_hit) as grupo8_hit,sum(grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			sum(CASE WHEN c.status_solicitud = 'RT' AND c.causa_solicitud = 'CPS' THEN 1 ELSE 0 END) as tiene_causas,c.orden_reporte, a.tipo_modelo_hit --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud
			AND a.causa_solicitud = c.causa_solicitud AND ( a.sucursal = pFiltro or pFiltro='')
			AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte
			AND b.activa_reporte = "1"
		GROUP BY c.descripcion,a.causa_solicitud,c.orden_reporte, a.tipo_modelo_hit;
		END IF;
	END IF;
	IF pTpConsulta	 = '01' THEN ---ESTADO
	create temp table total_estado	    (  estado char(2),total integer,total_hit integer,total_no_hit integer) with no log;
			insert into total_estado
			SELECT estado, sum(cantidad) total,sum(cantidad_hit) total_hit,sum(cantidad_no_hit) total_no_hit FROM total GROUP BY 1,tipo_modelo_hit; 
		IF pFiltro <> '' AND pEstatus = '' AND psubcausa = '' THEN
			LET total_sol_rep = 0;
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_estado WHERE estado = pFiltro;
		ELIF pFiltro <> '' AND pEstatus <> '' AND (psubcausa = '' OR psubcausa <> '') THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE estado = pFiltro AND status_solicitud = pEstatus;
		ELSE 
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_estado;
		END IF;
		IF pFiltro <> '' AND pEstatus = '' AND psubcausa = '' THEN
			insert into total_sol_group
			SELECT a.descripcion,a.status_solicitud, sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit, sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit, sum(grupo5_hit) as grupo5_hit, sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit, sum(grupo7_no_hit) as grupo7_no_hit,sum(grupo8_hit) as grupo8_hit, sum(grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status, ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			(CASE WHEN a.status_solicitud IN ('RT','CM','CN','AT','AP') THEN 1 ELSE 0 END) as tiene_causas,b.orden_reporte, a.tipo_modelo_hit
			FROM total a, bdisolic:ss_status_sol b
			WHERE a.status_solicitud = b.status_solicitud AND b.activa_reporte = "1" AND a.estado = pFiltro
			GROUP BY a.descripcion,a.status_solicitud,b.orden_reporte, a.tipo_modelo_hit;
		ELIF pFiltro = '' AND pEstatus = '' AND psubcausa = '' THEN
			insert into total_sol_group
			SELECT a.descripcion,a.status_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(grupo8_hit) as grupo8_hit,sum(grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status, ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			(CASE WHEN a.status_solicitud IN ('RT','CM','CN','AT','AP') THEN 1 ELSE 0 END) as tiene_causas,b.orden_reporte, a.tipo_modelo_hit
			FROM total a, bdisolic:ss_status_sol b
			WHERE a.status_solicitud = b.status_solicitud AND b.activa_reporte = "1" 
			GROUP BY a.descripcion,a.status_solicitud,b.orden_reporte, a.tipo_modelo_hit; 
		ELIF (pFiltro = '' AND pEstatus <> '' AND psubcausa = '') or (pFiltro <> '' AND pEstatus <> '' AND psubcausa = '') THEN
			insert into total_sol_group
			SELECT c.descripcion,a.causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(grupo8_hit) as grupo8_hit,sum(grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			sum(CASE WHEN c.status_solicitud = 'RT' AND c.causa_solicitud = 'CPS' THEN 1 ELSE 0 END) as tiene_causas, c.orden_reporte, a.tipo_modelo_hit
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND (a.estado = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.causa_solicitud,c.orden_reporte, a.tipo_modelo_hit; 
		END IF;
	END IF;
	IF pTpConsulta	 = '02' THEN ---CIUDAD
		create temp table total_ciudad	    (  ciudad char(3), estado char(2),total integer,total_hit integer,total_no_hit integer) with no log;		 
		insert into total_ciudad
		SELECT ciudad,estado, sum(cantidad) total, sum(cantidad_hit) total_hit, sum(cantidad_no_hit) total_no_hit FROM total group by 1,2,tipo_modelo_hit; 		
		IF pFiltro <> '' AND pEstatus = '' AND psubcausa = '' THEN
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_ciudad WHERE estado = pretedocd and ciudad = lpad(pFiltro,3,0);
		ELIF pFiltro <> '' AND pEstatus <> '' AND (psubcausa = '' OR psubcausa <> '') THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE estado = pretedocd and ciudad = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_ciudad;
		END IF;

		IF (pFiltro <> '' AND pEstatus = '' AND psubcausa = '') or (pFiltro = '' AND pEstatus = '' AND psubcausa = '') THEN
			insert into total_sol_group
			SELECT a.descripcion,a.status_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(a.grupo5_hit) as grupo5_hit,sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(a.grupo7_hit) as grupo7_hit,sum(a.grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			(CASE WHEN a.status_solicitud IN ('RT','CM','CN','AT','AP') THEN 1 ELSE 0 END) as tiene_causas,b.orden_reporte, a.tipo_modelo_hit
			FROM total a, bdisolic:ss_status_sol b
			WHERE a.status_solicitud = b.status_solicitud and b.activa_reporte = "1" and (a.estado = pretedocd or pretedocd='') 
			and ( a.ciudad = lpad(pFiltro,3,0) or pFiltro='')
			GROUP BY a.descripcion,a.status_solicitud,b.orden_reporte, a.tipo_modelo_hit; 
		ELIF (pFiltro = '' AND pEstatus <> '' AND psubcausa = '') or (pFiltro <> '' AND pEstatus <> '' AND psubcausa = '') THEN ----DETALLE
			insert into total_sol_group
			SELECT c.descripcion,a.causa_solicitud, sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(a.grupo5_hit) as grupo5_hit,sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(a.grupo7_hit) as grupo7_hit,sum(a.grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit,sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			sum(CASE WHEN c.status_solicitud = 'RT' AND c.causa_solicitud = 'CPS' THEN 1 ELSE 0 END) as tiene_causas,c.orden_reporte, a.tipo_modelo_hit --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND (a.estado = pretedocd or pretedocd='') AND (a.ciudad = pFiltro or pFiltro='') AND (a.status_solicitud = pEstatus or pEstatus='')
			AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.causa_solicitud,c.orden_reporte, a.tipo_modelo_hit;			
		END IF;
	END IF;
	IF pTpConsulta	 = '03' THEN ---REGION
		create temp table total_region (  numero_region smallint,total integer,total_hit integer,total_no_hit integer) with no log;
		insert into total_region
		SELECT numero_region, sum(cantidad) total, sum(cantidad_hit) total_hit, sum(cantidad_no_hit) total_no_hit FROM total group by 1,tipo_modelo_hit;
		
		IF pFiltro <> '' AND pEstatus = '' AND psubcausa = '' THEN
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_region WHERE numero_region = pFiltro;
		ELIF pFiltro <> '' AND pEstatus <> '' AND (psubcausa = '' OR psubcausa <> '') THEN
			SELECT sum(cantidad),sum(cantidad_hit),sum(cantidad_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total WHERE numero_region = pFiltro AND status_solicitud = pEstatus;
		ELSE
			SELECT sum(total),sum(total_hit),sum(total_no_hit) INTO total_sol_rep,total_sol_rep_hit,total_sol_rep_no_hit FROM total_region;
		END IF;
		IF (pFiltro <> '' AND pEstatus = '' AND psubcausa = '') or (pFiltro = '' AND pEstatus = '' AND psubcausa = '' ) THEN
			insert into total_sol_group
			select a.descripcion,a.status_solicitud,sum(a.grupo1_hit) as grupo1_hit, sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit, sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit, sum(a.grupo5_hit) as grupo5_hit, sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(a.grupo7_hit) as grupo7_hit, sum(a.grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status, ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			(CASE WHEN a.status_solicitud IN ('RT','CM','CN','AT','AP') THEN 1 ELSE 0 END) as tiene_causas,b.orden_reporte, a.tipo_modelo_hit
			from total a, bdisolic:ss_status_sol b
			where a.status_solicitud = b.status_solicitud and b.activa_reporte = "1" and (a.numero_region = pFiltro or pFiltro ='')
			GROUP BY a.descripcion,a.status_solicitud,b.orden_reporte, a.tipo_modelo_hit; 
		ELIF (pFiltro = '' AND pEstatus <> '' AND psubcausa = '') or (pFiltro <> '' AND pEstatus <> '' AND psubcausa = '') THEN --DETALLE
			insert into total_sol_group
			SELECT c.descripcion,a.causa_solicitud, sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit, sum(a.grupo2_hit) as grupo2_hit, sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit, sum(a.grupo3_no_hit) as grupo3_no_hit, sum(a.grupo5_hit) as grupo5_hit, sum(a.grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(a.grupo7_hit) as grupo7_hit, sum(a.grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status, 
			sum(CASE WHEN c.status_solicitud = 'RT' AND c.causa_solicitud = 'CPS' THEN 1 ELSE 0 END) as tiene_causas, c.orden_reporte, a.tipo_modelo_hit --MOD
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND (a.numero_region = pFiltro or pFiltro ='') AND (a.status_solicitud = pEstatus OR pEstatus='') AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY c.descripcion,a.causa_solicitud,c.orden_reporte, a.tipo_modelo_hit; 
		END IF;
	END IF;	
--INI EVALUACIONES DE LA CLASIFICACION DE LA CAUSA CPS
		IF pFiltro = '' AND pEstatus <> '' AND psubcausa <> '' AND pretedocd = '' THEN ----TODAS
			insert into total_sol_group
			SELECT trim(c.descripcion) ||' (CPS)' as descripcion,a.sub_causa_solicitud as causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit, sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			0 as tiene_causas,c.orden_reporte, a.tipo_modelo_hit
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud
			AND a.causa_solicitud = c.causa_solicitud AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY a.causa_solicitud,a.sub_causa_solicitud,c.descripcion,c.orden_reporte, a.tipo_modelo_hit; 
		ELIF pTpConsulta = '01' AND pFiltro <> '' AND pEstatus <> '' AND psubcausa <> '' THEN ----ESTADO
			insert into total_sol_group
			SELECT trim(c.descripcion) ||' (CPS)' as descripcion,a.sub_causa_solicitud as causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			0 as tiene_causas,c.orden_reporte, a.tipo_modelo_hit
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND a.estado = pFiltro AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY a.causa_solicitud,a.sub_causa_solicitud,c.descripcion,c.orden_reporte, a.tipo_modelo_hit;
		ELIF pTpConsulta = '02' AND pFiltro <> '' AND pEstatus <> '' AND psubcausa <> '' THEN ----CIUDAD
			insert into total_sol_group
			SELECT trim(c.descripcion) ||' (CPS)' as descripcion,a.sub_causa_solicitud as causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			0 as tiene_causas,c.orden_reporte, a.tipo_modelo_hit
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND a.estado = pretedocd AND a.ciudad = lpad(pFiltro,3,0) AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY a.causa_solicitud,a.sub_causa_solicitud,c.descripcion,c.orden_reporte, a.tipo_modelo_hit; 
		ELIF pTpConsulta = '04' AND pFiltro <> '' AND pEstatus <> '' AND psubcausa <> '' THEN ----SUCURSAL
			insert into total_sol_group
			SELECT trim(c.descripcion) ||' (CPS)' as descripcion,a.sub_causa_solicitud as causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			0 as tiene_causas,c.orden_reporte, a.tipo_modelo_hit
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND a.sucursal = pFiltro AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY a.causa_solicitud,a.sub_causa_solicitud,c.descripcion,c.orden_reporte, a.tipo_modelo_hit; 
		ELIF pTpConsulta = '03' AND pFiltro <> '' AND pEstatus <> '' AND psubcausa <> '' THEN ----REGION
			insert into total_sol_group
			SELECT trim(c.descripcion) ||' (CPS)' as descripcion,a.sub_causa_solicitud as causa_solicitud,sum(a.grupo1_hit) as grupo1_hit,sum(a.grupo1_no_hit) as grupo1_no_hit,sum(a.grupo2_hit) as grupo2_hit,sum(a.grupo2_no_hit) as grupo2_no_hit,
			sum(a.grupo3_hit) as grupo3_hit,sum(a.grupo3_no_hit) as grupo3_no_hit,sum(grupo5_hit) as grupo5_hit,sum(grupo5_no_hit) as grupo5_no_hit,
			sum(a.grupo6_hit) as grupo6_hit,sum(a.grupo6_no_hit) as grupo6_no_hit, sum(a.grupoA_hit) as grupoA_hit,sum(a.grupoA_no_hit) as grupoA_no_hit,
            sum(grupo7_hit) as grupo7_hit,sum(grupo7_no_hit) as grupo7_no_hit,sum(a.grupo8_hit) as grupo8_hit, sum(a.grupo8_no_hit) as grupo8_no_hit, sum(grupo9_hit) as grupo9_hit, sum(grupo9_no_hit) as grupo9_no_hit,
			sum(a.cantidad_hit) as total_x_status_hit,sum(a.cantidad_no_hit) as total_x_status_no_hit,
			ROUND((sum(a.cantidad_hit) / case when total_sol_rep_hit = 0 then 1 else total_sol_rep_hit end) * 100,2) as porc_status_hit,
			ROUND((sum(a.cantidad_no_hit) / case when total_sol_rep_no_hit = 0 then 1 else total_sol_rep_no_hit end) * 100,2) as porc_status_no_hit,
			sum(a.cantidad) as total_x_status,ROUND((sum(a.cantidad) / case when total_sol_rep = 0 then 1 else total_sol_rep end) * 100,2) as porc_status,
			0 as tiene_causas,c.orden_reporte, a.tipo_modelo_hit
			FROM total a, bdisolic:ss_status_sol b,bdisolic:ss_causas_sol c
			WHERE a.status_solicitud = b.status_solicitud AND a.status_solicitud = c.status_solicitud AND a.causa_solicitud = c.causa_solicitud
			AND a.numero_region = pFiltro AND b.activa_reporte = c.activa_reporte AND b.activa_reporte = "1"
			GROUP BY a.causa_solicitud,a.sub_causa_solicitud,c.descripcion,c.orden_reporte, a.tipo_modelo_hit;
		END IF;
		--total_sol_group_aux
		
create temp table total_sol_group_aux
( descripcion char(100),status_solicitud  char(2),grupo1_hit integer,grupo1_no_hit integer,grupo2_hit integer,grupo2_no_hit integer,
grupo3_hit integer,grupo3_no_hit integer, grupo5_hit integer,grupo5_no_hit integer,grupo6_hit integer,grupo6_no_hit integer,  
grupoA_hit integer,grupoA_no_hit integer,grupo7_hit integer,grupo7_no_hit integer,grupo8_hit integer,grupo8_no_hit integer,grupo9_hit integer,grupo9_no_hit integer,
total_x_status_hit integer,total_x_status_no_hit integer,porc_status_hit decimal (14,2),porc_status_no_hit decimal (14,2),
total_x_status	integer,porc_status decimal (14,2),causas integer,orden_reporte	smallint, tipo_modelo_hit CHAR(5)) with no log;		
---------FIN EVALUACIONES DE LA CLASIFICACION DE LA CAUSA CPS

		insert into total_sol_group_aux
		SELECT 'Total Solicitudes' descripcion,'' status_solicitud, sum(grupo1_hit) grupo1_hit, sum(grupo1_no_hit ) grupo1_no_hit, sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit) grupo2_no_hit, sum(grupo3_hit) grupo3_hit, sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit) grupo5_no_hit,
			sum(grupo6_hit) as grupo6_hit, sum(grupo6_no_hit) as grupo6_no_hit, sum(grupoA_hit) as grupoA_hit,sum(grupoA_no_hit) as grupoA_no_hit, 
            sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit,sum(grupo8_hit) as grupo8_hit, sum(grupo8_no_hit) as grupo8_no_hit,
			sum(grupo9_hit) as grupo9_hit,sum(grupo9_no_hit) as grupo9_no_hit,
			sum(grupo1_hit+grupo2_hit+grupo3_hit+grupo5_hit+grupo6_hit+grupoa_hit+grupo7_hit+grupo8_hit+grupo9_hit) total_x_status_hit,
			sum(grupo1_no_hit+grupo2_no_hit+grupo3_no_hit+grupo5_no_hit+grupo6_no_hit+grupoA_no_hit+grupo7_no_hit+grupo8_no_hit+grupo9_no_hit) total_x_status_no_hit, sum(porc_status_hit) porc_status_hit,sum(porc_status_no_hit) porc_status_no_hit,
			sum(grupo1_hit+grupo1_no_hit+grupo2_hit+grupo2_no_hit+grupo3_hit+grupo3_no_hit+grupo5_hit+grupo5_no_hit+grupo6_hit+grupo6_no_hit+grupoA_hit+grupoA_no_hit+grupo7_hit+grupo7_no_hit+grupo8_hit+grupo8_no_hit+grupo9_hit+grupo9_no_hit) total_x_status, 
            sum(porc_status) porc_status,0 causas, 997 orden_rerpote, tipo_modelo_hit
    FROM total_sol_group GROUP BY tipo_modelo_hit;

		select sum(total_x_status) INTO ptotal_x_status from total_sol_group_aux;
		select sum(total_x_status_hit) INTO ptotal_x_status_hit from total_sol_group_aux;
		select sum(total_x_status_no_hit) INTO ptotal_x_status_no_hit from total_sol_group_aux;

		IF ptotal_x_status = 0 THEN LET ptotal_x_status = 1;
		ELIF ptotal_x_status_hit = 0 THEN LET ptotal_x_status_hit = 1;
		ELIF ptotal_x_status_no_hit = 0 THEN LET ptotal_x_status_no_hit = 1;
		END IF;

		INSERT INTO total_sol_group_aux
		SELECT '% de Solicitudes' descripcion,'' status_solicitud,
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100,round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo2_hit)/(ptotal_x_status),2) * 100,round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100,
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100,round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo5_hit)/(ptotal_x_status),2) * 100,round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100,
        round(sum(grupo6_hit)/(ptotal_x_status),2) * 100,round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupoA_hit)/(ptotal_x_status),2) * 100,round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100,
        round(sum(grupo7_hit)/(ptotal_x_status),2) * 100,round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo8_hit)/(ptotal_x_status),2) * 100,round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100,round(sum(grupo9_hit)/(ptotal_x_status),2) * 100,round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, --cada uno de los status
		round(sum(grupo1_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo3_hit)/(ptotal_x_status_hit),2) * 100+
        round(sum(grupo5_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo6_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status_hit),2) * 100+
        round(sum(grupo7_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status_hit),2) * 100, --total x status_hit
		round(sum(grupo1_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status_no_hit),2) * 100+
        round(sum(grupo5_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status_no_hit),2) * 100+
        round(sum(grupo7_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status_no_hit),2) * 100, --total x status_no_hit
		round(sum(grupo1_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo3_hit)/(ptotal_x_status_hit),2) * 100+
        round(sum(grupo5_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo6_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status_hit),2) * 100+
        round(sum(grupo7_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status_hit),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status_hit),2) * 100, --porc de total x status_hit
		round(sum(grupo1_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status_no_hit),2) * 100+
        round(sum(grupo5_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status_no_hit),2) * 100+
        round(sum(grupo7_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status_no_hit),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status_no_hit),2) * 100, --porc de total x status_hit
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100+round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100+
        round(sum(grupo6_hit)/(ptotal_x_status),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100+
        round(sum(grupo7_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, ---total x status
		round(sum(grupo1_hit)/(ptotal_x_status),2) * 100+round(sum(grupo1_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_hit)/(ptotal_x_status),2) * 100+round(sum(grupo2_no_hit)/(ptotal_x_status),2) * 100+
		round(sum(grupo3_hit)/(ptotal_x_status),2) * 100+round(sum(grupo3_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_hit)/(ptotal_x_status),2) * 100+round(sum(grupo5_no_hit)/(ptotal_x_status),2) * 100+
        round(sum(grupo6_hit)/(ptotal_x_status),2) * 100+round(sum(grupo6_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_hit)/(ptotal_x_status),2) * 100+round(sum(grupoA_no_hit)/(ptotal_x_status),2) * 100+
        round(sum(grupo7_hit)/(ptotal_x_status),2) * 100+round(sum(grupo7_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_hit)/(ptotal_x_status),2) * 100+round(sum(grupo8_no_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_hit)/(ptotal_x_status),2) * 100+round(sum(grupo9_no_hit)/(ptotal_x_status),2) * 100, 0,998, tipo_modelo_hit ----porc de total x status
		FROM total_sol_group_aux GROUP BY tipo_modelo_hit; 

		INSERT INTO total_sol_group 
		SELECT * FROM total_sol_group_aux;

		SELECT COUNT(*) INTO num_registros FROM total_sol_group;
		IF num_registros > 2 THEN
			IF pEstatus <> '' THEN
			FOREACH WITH HOLD
				SELECT descripcion,status_solicitud,grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit,grupo6_hit,grupo6_no_hit,grupoA_hit,grupoA_no_hit,grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit,grupo9_hit,grupo9_no_hit, total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status, case when tiene_causas > 0 then 1 else tiene_causas end, tipo_modelo_hit
				INTO cDescripcion,cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus,dTotalGenStatus, cBanCausa, vtipo_modelo_hit
				FROM total_sol_group ORDER BY orden_reporte
			RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol,dgrupo1_hit,dgrupo1_no_hit, dgrupo2_hit,dgrupo2_no_hit, dgrupo3_hit,dgrupo3_no_hit, dgrupo5_hit, dgrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit, dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit, dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus, cBanCausa, vtipo_modelo_hit WITH RESUME;
			END FOREACH;
			ELSE
			FOREACH WITH HOLD
				SELECT descripcion,status_solicitud,grupo1_hit,grupo1_no_hit,grupo2_hit,grupo2_no_hit,grupo3_hit,grupo3_no_hit,grupo5_hit,grupo5_no_hit,grupo6_hit,grupo6_no_hit,grupoA_hit,grupoA_no_hit,grupo7_hit,grupo7_no_hit,grupo8_hit,grupo8_no_hit,grupo9_hit,grupo9_no_hit,total_x_status_hit,total_x_status_no_hit,porc_status_hit,porc_status_no_hit,total_x_status,porc_status, case when tiene_causas > 0 then 1 else tiene_causas end, tipo_modelo_hit
				INTO cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit, dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus, cBanCausa, vtipo_modelo_hit
				FROM total_sol_group ORDER BY orden_reporte
				RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit, dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus, cBanCausa, vtipo_modelo_hit WITH RESUME;
			END FOREACH;
			END IF;
		ELSE
			LET cCodRet = '000006'; LET cMensajeRet = 'No hay informacion para este producto en este periodo';
			RETURN cCodRet, cMensajeRet, cDescripcion, cStatusSol, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit,dgrupo3_hit, dgrupo3_no_hit, dGrupo5_hit, dGrupo5_no_hit,dgrupo6_hit,dgrupo6_no_hit,dgrupoA_hit,dgrupoA_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,dgrupo9_hit,dgrupo9_no_hit,dtotal_status_hit,dtotal_status_no_hit,dporc_status_hit,dporc_status_no_hit,dTotalStatus, dTotalGenStatus, cBanCausa, vtipo_modelo_hit WITH RESUME;
		END IF
		 DROP TABLE Tsolicitud; DROP TABLE sol2; DROP TABLE total; DROP TABLE total_sol_group; DROP TABLE total_sol_group_aux;
        
		 IF psubcausa <> '' THEN DROP TABLE sol3; DROP TABLE sol4; END IF;
		
		 IF pTpConsulta = '04' THEN DROP TABLE total_sucursal; 
		 ELIF pTpConsulta = '01' THEN DROP TABLE total_estado; 
		 ELIF pTpConsulta = '02' THEN DROP TABLE total_ciudad; 
		 ELIF pTpConsulta = '03' THEN DROP TABLE total_region; 
		 END IF;
		
		
END
END PROCEDURE
