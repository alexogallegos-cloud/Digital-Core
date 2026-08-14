CREATE PROCEDURE "informix".sp_obtienesolosresos(pEmpresa CHAR(3),pTpConsulta CHAR(2),pFiltro VARCHAR(4),pProducto CHAR(4),
												pFechaIni DATE,pFechaFin DATE, pDesglose SMALLINT) 
	RETURNING 
	CHAR(6)			AS codret, 
	CHAR(100)		AS descripcion,  
	CHAR (4)		AS status_solicitud, 
	DECIMAL(18,2)	AS grupo1_hit, 	DECIMAL(18,2) AS grupo1_no_hit,
	DECIMAL(18,2)	AS grupo2_hit, 	DECIMAL(18,2) AS grupo2_no_hit,
	DECIMAL(18,2)	AS grupo3_hit, 	DECIMAL(18,2) AS grupo3_no_hit,
	DECIMAL(18,2)	AS grupo5_hit, 	DECIMAL(18,2) AS grupo5_no_hit,
	DECIMAL(18,2)	AS grupo6_hit, 	DECIMAL(18,2) AS grupo6_no_hit,
	DECIMAL(18,2)	AS grupoA_hit, 	DECIMAL(18,2) AS grupoA_no_hit,
	DECIMAL(18,2)	AS grupo7_hit, 	DECIMAL(18,2) AS grupo7_no_hit,
	DECIMAL(18,2)	AS grupo8_hit, 	DECIMAL(18,2) AS grupo8_no_hit,
	DECIMAL(18,2)	AS total_estatus_hit, 
	DECIMAL(18,2)	AS total_estatus_no_hit, 
	DECIMAL(18,2)	AS porc_total_hit, 
	DECIMAL(18,2)	AS porc_total_no_hit, 
	DECIMAL(18,2)	AS total_ordenes, 
	DECIMAL(18,2)	AS porcentaje_total_ordenes;

	---DECLARACION DE VARIABLES
	DEFINE cCodRet CHAR(6);
	DEFINE cDescripcion    CHAR(100);	 
	DEFINE cStatus_solicitud,  cEstado, cCiudad, cSucursal,  cCausa   CHAR(4); 
	DEFINE dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit,dgrupo2_no_hit,dgrupo3_hit,dgrupo3_no_hit,
			dGrupo5_hit, dGrupo5_no_hit, dGrupo6_hit ,dGrupo6_no_hit,dGrupoa_hit, dGrupoa_no_hit, dgrupo7_hit ,dgrupo7_no_hit, 
      dgrupo8_hit ,dgrupo8_no_hit,dtotal_status_hit , 
			dtotal_status_no_hit, dPorc_hit, dPorc_no_hit,dGranTotal_status_hit,dGranTotal_status_no_hit, dTotalHit, 
			dTotalNoHit, dTotalOS,dTotalHitT, dTotalNoHitT, dTotalOST, dPorcTotal,dPorcTotalT, dGranTotal, dTotalGlobal, 
			dPorcentajeDesglose DECIMAL(18,2); 
	DEFINE VSQL CHAR(6000);
	DEFINE i, iSqlErr, iRegion, iCausaOrden INTEGER;
	DEFINE dDetalle, dPaso SMALLINT;
	DEFINE dTotalHitDes DECIMAL(18,2); 
	DEFINE dTotalNoHitDes DECIMAL (18,2); 
	DEFINE dPorcenHit DECIMAL(18,2); 
	DEFINE dPorcenNoHit DECIMAL(18,2);
	DEFINE dTotalFinal DECIMAL (18,2);
	DEFINE error_info CHAR(80);
	DEFINE isam_err INTEGER;
	--VARIABLES PARA GUARDAR EL ACUMULADO
	DEFINE vlgrupo, vlGrupoAct SMALLINT;
	DEFINE vestado char(2);
	DEFINE vnumerociudad smallint;
	DEFINE vnumero_region smallint;
	---INICIALIZACION DE VARIABLES
	LET cCodRet = '000000';
	LET cStatus_solicitud = '';
	LET dgrupo1_hit = 0; LET dgrupo1_no_hit = 0; LET dgrupo2_hit = 0; LET dgrupo2_no_hit = 0;
	LET dgrupo3_hit  = 0; LET dgrupo3_no_hit = 0;
	LET dGrupo5_hit  = 0; LET dGrupo5_no_hit  = 0; LET dGrupo6_hit = 0; LET dGrupo6_no_hit  = 0;
	LET dGrupoa_hit = 0; LET dGrupoa_no_hit = 0; LET dgrupo7_hit= 0; LET dgrupo7_no_hit  = 0; LET dgrupo8_hit= 0; LET dgrupo8_no_hit  = 0; 
  LET dtotal_status_hit = 0; LET dtotal_status_no_hit = 0;
	LET VSQL = ''; LET i = 0 ; LET cDescripcion= ''; LET iSqlErr = 0;

	LET dPorc_hit  = 0; 
	LET dPorc_no_hit = 0;  
	LET dGranTotal_status_hit = 0; LET dGranTotal_status_no_hit   = 0; LET dTotalHit = 0; LET dTotalNoHit = 0; 
	LET dTotalOS   = 0; LET dPorcTotal  = 0; LET dGranTotal = 0 ; LET dTotalGlobal = 0; 
	LET cEstado = ''; LET cCiudad  = ''; LET iRegion = 0 ; LET iCausaOrden = 0 ; LET cSucursal= ''; 
	--VARIABLES PARA GUARDAR EL ACUMULADO	
	LET dTotalHitDes  = 0;LET dTotalNoHitDes = 0; 
	LET dPorcenHit = 0; LET dPorcenNoHit = 0; 	
	LET  dTotalFinal= 0; LET dDetalle = 0;
	LET vlgrupo = 0;  LET vlGrupoAct = 0;
	LET dPaso = 0;
	LET vestado = '';
	LET vnumerociudad=0; 
	LET vnumero_region=0;
	BEGIN	
	ON EXCEPTION SET iSqlErr, isam_err, error_info
	   IF iSqlErr <> 0 THEN LET cCodRet= iSqlErr;
		if dPaso = 1 then
			drop table  "informix".ss_arbolsolicitudestmp;
			drop table  "informix".SolDetalleEstado;
		end if;
		if dPaso = 2 then
			drop table  "informix".ss_arbolsolicitudestmp;
			drop table  "informix".SolDetalleEstado;
			drop table  "informix".ss_arbolsolicitudestmp2;
		end if;
		if dPaso = 3 then
			drop table  "informix".ss_arbolsolicitudestmp;
			drop table  "informix".SolDetalleEstado;
			drop table  "informix".ss_arbolsolicitudestmp2;
			drop table  "informix".ss_arbolsolicitudes_tmp;
		end if;
		if dPaso = 4 then
			drop table  "informix".ss_arbolsolicitudestmp;
			drop table  "informix".SolDetalleEstado;		   
			drop table  "informix".ss_arbolsolicitudestmp2;
			drop table  "informix".ss_arbolsolicitudes_tmp;
			drop table  "informix".tdesglose;
			drop table  "informix".tdesglose2;
		end if;

			--DELETE "informix".ss_arbolsolicitudes_tmp;  
			LET cDescripcion = error_info;
		 RETURN cCodRet, cDescripcion, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
	   END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO 'sp_obtienesolosresos.out';
	--TRACE ON;
	
	IF NVL(pEmpresa,'') = '' OR  NVL(pTpConsulta,'') = '' OR NVL(pFechaIni,DATE(1)) = DATE(1) OR NVL(pFechaFin, DATE(1)) = DATE(1) OR NVL(pDesglose, '') = '' THEN LET cCodRet = '001'; LET cDescripcion = 'VERIFIQUE LOS PARAMETROS'; RETURN cCodRet, cDescripcion, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; END IF;

	IF pTpConsulta NOT IN('01','02','03','04') THEN
		LET cCodRet = '000001'; LET cDescripcion = 'TIPO DE CONSULTA INEXISTENTE'; RETURN cCodRet, cDescripcion, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
	END IF;

	IF pDesglose NOT IN(1,2,3,4) THEN
		LET cCodRet = '000002'; LET cDescripcion = 'TIPO DE DESGLOSE INEXISTENTE'; RETURN cCodRet, cDescripcion, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
	END IF;

	--SE VALIDA EL PARAMETRO POR EL CUAL SE REALIZA LA CONSULTA
	IF pTpConsulta = '01' THEN LET cEstado = pFiltro::CHAR(4); 	
	ELIF pTpConsulta = '02' THEN LET cCiudad = pFiltro::CHAR(4);
	ELIF pTpConsulta = '03' THEN
		IF NVL(pFiltro,'') = '' THEN LET iRegion = 0; ELSE LET iRegion = pFiltro::INTEGER; END IF;
	ELIF pTpConsulta = '04' THEN LET cSucursal= pFiltro::CHAR(4);	
	END IF;

	
create temp table ss_arbolsolicitudestmp
( descripcion char(100),
clave_status char(4),
clave_orden integer,
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
grupoa_hit integer,
grupoa_no_hit integer,
grupo7_hit integer,
grupo7_no_hit integer,
grupo8_hit integer,
grupo8_no_hit integer,
total_status_hit integer,
total_status_no_hit integer,
porcentaje_hit decimal(5,2),
porcentaje_no_hit decimal(5,2),
total_os integer,
porcentaje_os decimal(5,2),
grupo smallint
) with no log;

create temp table SolDetalleEstado (
sucursal char(4),
causa_solicitud char(4),
grupo1_hit smallint,
grupo1_no_hit smallint,
grupo2_hit smallint,
grupo2_no_hit smallint,
grupo3_hit smallint,
grupo3_no_hit smallint,
grupo5_hit smallint,
grupo5_no_hit smallint,
grupo6_hit smallint,
grupo6_no_hit smallint,
grupoA_hit smallint,
grupoA_no_hit smallint,
grupo7_hit smallint, 
grupo7_no_hit smallint,
grupo8_hit smallint,
grupo8_no_hit smallint,
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer ) with no log; 

create temp table ss_arbolsolicitudestmp2
(
causa_solicitud char(4),  
grupo1_hit integer , 
grupo1_no_hit integer, 
grupo2_hit integer, 
grupo2_no_hit integer, 
grupo3_hit integer, 
grupo3_no_hit integer, 
grupo5_hit integer, 
grupo5_no_hit integer, 
grupo6_hit  integer, 
grupo6_no_hit integer, 
grupoa_hit integer, 
grupoa_no_hit integer, 
grupo7_hit integer, 
grupo7_no_hit integer, 
grupo8_hit integer, 
grupo8_no_hit integer, 
total_status_no_hit integer,
total_status_hit integer, 
total_os integer) with no log;

create temp table ss_arbolsolicitudes_tmp
(descripcion char(100), 
clave_status char(5), 
clave_orden integer, 
grupo1_hit integer, 
grupo1_no_hit  integer, 
grupo2_hit integer, 
grupo2_no_hit integer, 
grupo3_hit integer, 
grupo3_no_hit integer, 
grupo5_hit integer, 
grupo5_no_hit integer, 
grupo6_hit integer,
grupo6_no_hit integer, 
grupoa_hit integer, 
grupoa_no_hit integer, 
grupo7_hit integer, 
grupo7_no_hit integer, 
grupo8_hit integer, 
grupo8_no_hit integer,
total_status_hit integer, 
total_status_no_hit integer,
porcentaje_hit decimal(5,2),
porcentaje_no_hit decimal(5,2),
total_os integer, 
porcentaje_os decimal(5,2), 
detalle smallint
) with no log;

--causasituacionespecial char(10), 

if pDesglose = 4 then
create temp table tdesglose
(sucursal char(4),
status_solicitud char(2) ,
DescripcionCausa char(50), 
Causa char(4),
CausaOrden integer,
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
cantidad integer,
cantidad_hit integer,
cantidad_no_hit integer) with no log;

create temp table tdesglose2 
(status_solicitud char(2), 
DescripcionCausa char(50), 
causa char(4), 
CausaOrden integer, 
grupo1_hit integer , 
grupo1_no_hit integer, 
grupo2_hit integer, 
grupo2_no_hit integer,
grupo3_hit integer, 
grupo3_no_hit integer, 
grupo5_hit integer, 
grupo5_no_hit integer,
grupo6_hit integer, 
grupo6_no_hit integer, 
grupoa_hit integer, 
grupoa_no_hit integer, 
grupo7_hit integer, 
grupo7_no_hit integer, 
grupo8_hit integer, 
grupo8_no_hit integer,
total_status_no_hit integer,
total_status_hit integer, 
total_os integer ) with no log;
end if;
LET dPaso = 1;	
	
insert into ss_arbolsolicitudestmp values ('OS No Enviadas','OSN',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 13  );  
insert into ss_arbolsolicitudestmp values ('   EE No Enviadas','EEN',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 7  );  
insert into ss_arbolsolicitudestmp values ('       En Estudio de Supervisión','EE',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1   );  
insert into ss_arbolsolicitudestmp values ('       Canceladas en Estudio de Supervisión','CEE',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1   );  
insert into ss_arbolsolicitudestmp values ('   CE No Enviadas','CEN',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8   );  
insert into ss_arbolsolicitudestmp values ('       Catálogo de Domicilio en Estudio','CE',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,2  );  
insert into ss_arbolsolicitudestmp values ('       Canceladas en Catálogo de Domicilio en Estudio','CCE',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,2  );  
insert into ss_arbolsolicitudestmp values ('OS Enviadas','OSE',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,15  );  
insert into ss_arbolsolicitudestmp values ('   OS Atendidas','OSA',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,14  );  
insert into ss_arbolsolicitudestmp values ('       OS Autorizadas','ATOS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,9  );  
insert into ss_arbolsolicitudestmp values ('           Entregadas','OSAP',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,3  );  
insert into ss_arbolsolicitudestmp values ('           Autorizadas','OSAT',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,3  );  
insert into ss_arbolsolicitudestmp values ('           Canceladas','CVOS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,3  );  
insert into ss_arbolsolicitudestmp values ('       OS Rechazadas','RTOS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10   );  
insert into ss_arbolsolicitudestmp values ('           Rechazadas','ROS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,4  );  
--insert into ss_arbolsolicitudestmp values ('           	Rechazadas','ROS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,4  );  									
insert into ss_arbolsolicitudestmp values ('           Canceladas','CROS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,4  );  
insert into ss_arbolsolicitudestmp values ('       OS En Aclaración','OAOS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,11  );  
insert into ss_arbolsolicitudestmp values ('           En Aclaración','OA',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,5  );  
insert into ss_arbolsolicitudestmp values ('           Canceladas','COA',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,5  );  
insert into ss_arbolsolicitudestmp values ('   OS No Atendidas','OSNA',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,12  );  
insert into ss_arbolsolicitudestmp values ('       OS Pendientes','OS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,6  );  
insert into ss_arbolsolicitudestmp values ('       OS Canceladas','COS',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,6  );  
insert into ss_arbolsolicitudestmp values ('Total de Órdenes de Supervisión','',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16 );  

insert into SolDetalleEstado
SELECT a.sucursal,
		case when a.status_solicitud = 'AT' and a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitud_os) then 'OSAT' 
			 when a.status_solicitud = 'AP' and a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitud_os) then 'OSAP' 
			 when a.status_solicitud = 'RT' and c.causa_solicitud = 'ROS' then 'ROS' else a.status_solicitud end causa_solicitud,
		--DECODE(a.status_solicitud, 'AT', 'OSAT', 'AP', 'OSAP','RT','ROS', a.status_solicitud ) causa_solicitud,  --a.status_solicitud, 
		--  a.status_solicitud, 
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END ) grupo1_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo1_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '2') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo2_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo2_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '3') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo3_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo3_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '5') AND evalua_cc in ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo5_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo5_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo6_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(evalua_cc,'') IN ('X','') THEN 1 ELSE 0 END) grupo6_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupoA_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupoA_no_hit,
		0 grupo7_hit, SUM(CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END) grupo7_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '8') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo8_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo8_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = 'A') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END+
			CASE WHEN (nvl(b.Grupo,'') = '8') THEN 1 ELSE 0 END) cantidad,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND evalua_cc in ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END + CASE WHEN (nvl(b.Grupo,'') = 'A') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '8') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) cantidad_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(evalua_cc,'') IN ('X','') THEN 1 ELSE 0 END + CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END+
			CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) cantidad_no_hit
		--into vestado , vnumerociudad,  vnumero_region, cStatus_solicitud, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo4_hit,dgrupo4_no_hit,dgrupo5_hit,dgrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit,dGrupoa_hit, dGrupoa_no_hit,
		--dTotalFinal, dTotalHitDes, dTotalNoHitDes
		FROM bdisolic:ss_resum_scor_fin b, bdisolic:ss_autorizacion c, /*bdisolic:ss_solicitud_os os,*/ bdisolic:ss_solicitudes a, outer bdiprospectos:pr_cliente pr
			--left outer join bdinteg:si_direcciones_actual dir on ( dir.numcte = a.numcte and dir.tipo_dir = 1 )
			--left outer join bdinteg:si_catciudades ciu on (dir.numerociudad = ciu.numerociudad )
		WHERE a.empresa = b.empresa 
		AND a.num_solicitud = b.num_solicitud AND a.num_solicitud = c.num_solicitud AND a.status_solicitud = c.status_solicitud and a.numcte = pr.numcte
		--AND A.empresa = os.empresa
		--and A.num_solicitud = os.num_solicitud
		--and (A.num_solicitud in (select num_solicitud from bdisolic:ss_osclientesupervisar) and a.status_solicitud not in ('RT','OA'))
		AND c.fecha_entrada = (select max(fecha_entrada) from bdisolic:ss_autorizacion where a.empresa = empresa and a.num_solicitud = num_solicitud and a.status_solicitud = status_solicitud)
		AND a.num_producto = 	pProducto AND a.fecha_insert >= pFechaIni AND a.fecha_insert <= pFechaFin and pr.tipo_alta = '2'
		AND  a.status_solicitud in ('EE','CE','OS','AP','AT','RT','OA' )
		and (
				((pTpConsulta = '04'  and a.sucursal = cSucursal ) or (cSucursal ='') )
			)
		--and os.secuenciaos in (select max(secuenciaos) from bdisolic:ss_solicitud_os where empresa ='001' and num_solicitud =  os.num_solicitud )
		GROUP BY 1,2;
--UNION all
insert into SolDetalleEstado
SELECT a.sucursal,DECODE(c.causa_solicitud, 'CV', 'CVOS', 'CR', 'CROS', c.causa_solicitud) causa_solicitud,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END ) grupo1_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo1_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '2') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo2_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo2_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '3') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo3_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo3_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '5') AND evalua_cc in ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo5_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo5_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo6_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(evalua_cc,'') IN ('X','') THEN 1 ELSE 0 END) grupo6_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupoA_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupoA_no_hit,
		0 grupo7_hit, SUM(CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END) grupo7_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '8') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo8_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo8_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = 'A') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END+
			CASE WHEN (nvl(b.Grupo,'') = '8') THEN 1 ELSE 0 END) cantidad,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND evalua_cc in ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END + CASE WHEN (nvl(b.Grupo,'') = 'A') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
      CASE WHEN (nvl(b.Grupo,'') = '8') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) cantidad_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(evalua_cc,'') IN ('X','') THEN 1 ELSE 0 END + CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END+
      CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END ) cantidad_no_hit
		FROM bdisolic:ss_resum_scor_fin b, bdisolic:ss_autorizacion c , /*bdisolic:ss_solicitud_os os,*/ bdisolic:ss_solicitudes a, outer bdiprospectos:pr_cliente pr
			--left outer join bdinteg:si_direcciones_actual dir on ( dir.numcte = a.numcte and dir.tipo_dir = 1 )
			--left outer join bdinteg:si_catciudades ciu on (dir.numerociudad = ciu.numerociudad )
		WHERE a.empresa = b.empresa 
		AND a.num_solicitud = b.num_solicitud AND a.num_solicitud = c.num_solicitud AND a.status_solicitud = c.status_solicitud and a.numcte = pr.numcte
		--AND A.empresa = os.empresa
		--and A.num_solicitud = os.num_solicitud
		AND c.fecha_entrada = (select max(fecha_entrada) from bdisolic:ss_autorizacion where a.empresa = empresa and a.num_solicitud = num_solicitud and a.status_solicitud = status_solicitud)		  
		AND a.num_producto = 	pProducto AND a.fecha_insert >= pFechaIni AND a.fecha_insert <= pFechaFin and pr.tipo_alta = '2'
		and (
				((pTpConsulta = '04'  and a.sucursal = cSucursal ) or (cSucursal ='') )
			)
		AND A.status_solicitud ='CN'  and C.status_solicitud ='CN' AND C.causa_solicitud in ('CCE', 'CEE','CV','CR','COA','COS')
		--and os.secuenciaos in (select max(secuenciaos) from bdisolic:ss_solicitud_os where empresa ='001' and num_solicitud =  os.num_solicitud )
		GROUP BY 1,2;
		--into temp SolDetalleEstado with no log;

LET dPaso = 2;
  IF pTpConsulta = '01' THEN 
/*
	select causa_solicitud, sum(grupo1_hit) grupo1_hit , sum(grupo1_no_hit) grupo1_no_hit , sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit ) grupo2_no_hit, 
			sum(grupo3_hit) grupo3_hit , sum(grupo3_no_hit) grupo3_no_hit, sum(grupo4_hit) grupo4_hit, sum(grupo4_no_hit) grupo4_no_hit , sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit)  grupo5_no_hit, 
			sum(grupo6_hit) grupo6_hit , sum(grupo6_no_hit)grupo6_no_hit , sum(grupoa_hit)grupoa_hit , sum(grupoa_no_hit)grupoa_no_hit , sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad_hit)total_status_hit, sum(cantidad)  total_os
    from SolDetalleEstado
	where ( estado = cEstado or cEstado ='' )
	group by 1*/
	insert into ss_arbolsolicitudestmp2
	SELECT causa_solicitud, sum(grupo1_hit) grupo1_hit , sum(grupo1_no_hit) grupo1_no_hit , sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit ) grupo2_no_hit, 
			sum(grupo3_hit) grupo3_hit , sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit) grupo5_no_hit, 
			sum(grupo6_hit) grupo6_hit , sum(grupo6_no_hit)grupo6_no_hit , sum(grupoa_hit)grupoa_hit , sum(grupoa_no_hit)grupoa_no_hit, sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit, 
      sum(grupo8_hit) grupo8_hit, sum(grupo8_no_hit) grupo8_no_hit, sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad_hit)total_status_hit, sum(cantidad) total_os
	FROM SolDetalleEstado a, bdinteg:si_sucursales s,bdinteg:si_ciudades c ,bdinteg:si_catciudades t
	left outer join bdinteg:si_regiones r on ( t.numero_region    = r.numero_region)
	WHERE s.empresa = pEmpresa /*AND a.status_solicitud = b.status_solicitud AND activa_reporte = "1"*/ AND a.sucursal = s.sucursal 
	AND s.ciudad = c.ciudad AND s.pais = c.pais AND s.estado = c.estado AND c.ciudad_coppel = t.numerociudad 
	AND ( c.estado = cEstado or cEstado ='' )
	group by 1;
	--into temp ss_arbolsolicitudestmp2 with no log;

  ELIF pTpConsulta = '02' THEN LET cCiudad = pFiltro::CHAR(4);
	/*select causa_solicitud, sum(grupo1_hit) grupo1_hit , sum(grupo1_no_hit) grupo1_no_hit , sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit ) grupo2_no_hit,
			sum(grupo3_hit) grupo3_hit , sum(grupo3_no_hit) grupo3_no_hit, sum(grupo4_hit) grupo4_hit, sum(grupo4_no_hit) grupo4_no_hit , sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit)  grupo5_no_hit,
			sum(grupo6_hit) grupo6_hit , sum(grupo6_no_hit)grupo6_no_hit , sum(grupoa_hit)grupoa_hit , sum(grupoa_no_hit)grupoa_no_hit , sum(cantidad_hit)total_status_hit , sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad) total_os
	from SolDetalleEstado
	where ( numerociudad = cCiudad or cCiudad ='' )
	group by 1*/
	insert into ss_arbolsolicitudestmp2
	SELECT causa_solicitud, sum(grupo1_hit) grupo1_hit , sum(grupo1_no_hit) grupo1_no_hit , sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit ) grupo2_no_hit, 
			sum(grupo3_hit) grupo3_hit , sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit)  grupo5_no_hit, 
			sum(grupo6_hit) grupo6_hit , sum(grupo6_no_hit)grupo6_no_hit , sum(grupoa_hit)grupoa_hit , sum(grupoa_no_hit)grupoa_no_hit, sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit, 
      sum(grupo8_hit)grupo8_hit , sum(grupo8_no_hit)grupo8_no_hit,sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad_hit)total_status_hit, sum(cantidad) total_os
	FROM SolDetalleEstado a, bdinteg:si_sucursales s,bdinteg:si_ciudades c ,bdinteg:si_catciudades t
	left outer join bdinteg:si_regiones r on ( t.numero_region    = r.numero_region)
	WHERE s.empresa = pEmpresa /*AND a.status_solicitud = b.status_solicitud AND activa_reporte = "1"*/ AND a.sucursal = s.sucursal
	AND s.ciudad = c.ciudad AND s.pais = c.pais AND s.estado = c.estado AND c.ciudad_coppel = t.numerociudad
	AND ( t.numerociudad = cCiudad or cCiudad ='' )
	group by 1;
	--into temp ss_arbolsolicitudestmp2 with no log;
  ELIF pTpConsulta = '03' THEN
	/*select   causa_solicitud, sum(grupo1_hit) grupo1_hit , sum(grupo1_no_hit) grupo1_no_hit , sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit ) grupo2_no_hit, 
			sum(grupo3_hit) grupo3_hit , sum(grupo3_no_hit) grupo3_no_hit, sum(grupo4_hit) grupo4_hit, sum(grupo4_no_hit) grupo4_no_hit , sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit)  grupo5_no_hit, 
			sum(grupo6_hit) grupo6_hit , sum(grupo6_no_hit)grupo6_no_hit , sum(grupoa_hit)grupoa_hit , sum(grupoa_no_hit)grupoa_no_hit , sum(cantidad_hit)total_status_hit , sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad)  total_os
	from SolDetalleEstado
	where ( numero_region = iRegion or iRegion =0 )
	group by 1*/
	insert into ss_arbolsolicitudestmp2
	SELECT causa_solicitud, sum(grupo1_hit) grupo1_hit , sum(grupo1_no_hit) grupo1_no_hit , sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit ) grupo2_no_hit,
			sum(grupo3_hit) grupo3_hit , sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit) grupo5_no_hit,
			sum(grupo6_hit) grupo6_hit , sum(grupo6_no_hit)grupo6_no_hit , sum(grupoa_hit)grupoa_hit , sum(grupoa_no_hit)grupoa_no_hit, sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit, 
      sum(grupo8_hit)grupo8_hit , sum(grupo8_no_hit)grupo8_no_hit, sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad_hit)total_status_hit, sum(cantidad) total_os
	FROM SolDetalleEstado a, bdinteg:si_sucursales s,bdinteg:si_ciudades c ,bdinteg:si_catciudades t
	left outer join bdinteg:si_regiones r on ( t.numero_region    = r.numero_region)
	WHERE s.empresa = pEmpresa /*AND a.status_solicitud = b.status_solicitud AND activa_reporte = "1"*/ AND a.sucursal = s.sucursal
	AND s.ciudad = c.ciudad AND s.pais = c.pais AND s.estado = c.estado AND c.ciudad_coppel = t.numerociudad 
	and ( r.numero_region = iRegion or iRegion =0 )
	group by 1;
	--into temp ss_arbolsolicitudestmp2 with no log;
  ELIF pTpConsulta = '04' THEN
  insert into ss_arbolsolicitudestmp2
		select causa_solicitud, sum(grupo1_hit) grupo1_hit , sum(grupo1_no_hit) grupo1_no_hit , sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit ) grupo2_no_hit,
			sum(grupo3_hit) grupo3_hit , sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit) grupo5_no_hit,
			sum(grupo6_hit) grupo6_hit , sum(grupo6_no_hit)grupo6_no_hit , sum(grupoa_hit)grupoa_hit , sum(grupoa_no_hit)grupoa_no_hit, sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit, 
      sum(grupo8_hit)grupo8_hit , sum(grupo8_no_hit)grupo8_no_hit, sum(cantidad_hit)total_status_hit , sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad)  total_os
		from SolDetalleEstado
		--where ( numero_region = iRegion or iRegion =0 )
		group by 1;
		--into temp ss_arbolsolicitudestmp2 with no log;
  END IF;
LET dPaso = 3;
FOREACH
	select causa_solicitud, sum(grupo1_hit), sum(grupo1_no_hit), sum(grupo2_hit), sum(grupo2_no_hit ),
			sum(grupo3_hit), sum(grupo3_no_hit), sum(grupo5_hit), sum(grupo5_no_hit),
			sum(grupo6_hit), sum(grupo6_no_hit), sum(grupoa_hit), sum(grupoa_no_hit), sum(grupo7_hit), sum(grupo7_no_hit), sum(grupo8_hit), sum(grupo8_no_hit), sum(total_status_hit) , sum(total_status_no_hit),
			sum(total_os)
	into cStatus_solicitud, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit,dGrupoa_hit, dGrupoa_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,	    
		dTotalHitDes, dTotalNoHitDes, dTotalFinal
	from ss_arbolsolicitudestmp2
	group by 1

	update ss_arbolsolicitudestmp
	set grupo1_hit = dgrupo1_hit,
		grupo1_no_hit = dgrupo1_no_hit,
		grupo2_hit = dgrupo2_hit,
		grupo2_no_hit =dgrupo2_no_hit,
		grupo3_hit = dgrupo3_hit,
		grupo3_no_hit = dgrupo3_no_hit,
		grupo5_hit = dgrupo5_hit,
		grupo5_no_hit = dgrupo5_no_hit,
		grupo6_hit = dGrupo6_hit,
		grupo6_no_hit = dGrupo6_no_hit,
		grupoa_hit =dGrupoa_hit,
		grupoa_no_hit = dGrupoa_no_hit,
		grupo7_hit = dgrupo7_hit,
		grupo7_no_hit =dgrupo7_no_hit,
		grupo8_hit = dgrupo8_hit,
		grupo8_no_hit =dgrupo8_no_hit,
		total_status_hit = dTotalHitDes,
		total_status_no_hit = dTotalNoHitDes,
		total_os = dTotalFinal 
	where clave_status = cStatus_solicitud;
END FOREACH;

FOREACH with hold
	select grupo, 
			sum(grupo1_hit), sum(grupo1_no_hit), sum(grupo2_hit),
			sum(grupo2_no_hit), sum(grupo3_hit), sum(grupo3_no_hit),
			sum(grupo5_hit),sum(grupo5_no_hit), sum(grupo6_hit),
			sum(grupo6_no_hit), sum(grupoa_hit), sum(grupoa_no_hit),
			sum(grupo7_hit), sum(grupo7_no_hit), sum(grupo8_hit), sum(grupo8_no_hit),  
      sum(total_status_hit), sum(total_status_no_hit), sum(total_os)
		into vlgrupo, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,
			dgrupo5_hit,dgrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit,dGrupoa_hit, dGrupoa_no_hit, dgrupo7_hit,dgrupo7_no_hit,
			dgrupo8_hit,dgrupo8_no_hit,
			dTotalHitDes, dTotalNoHitDes, dTotalFinal
	from ss_arbolsolicitudestmp
	where grupo <=6 and grupo >0
	group by grupo
	order by grupo

	begin work;
	update ss_arbolsolicitudestmp 
		set grupo1_hit = grupo1_hit + dgrupo1_hit,
		grupo1_no_hit = grupo1_no_hit +dgrupo1_no_hit,
		grupo2_hit =  grupo2_hit +dgrupo2_hit,
		grupo2_no_hit = grupo2_no_hit + dgrupo2_no_hit,
		grupo3_hit = grupo3_hit + dgrupo3_hit,
		grupo3_no_hit = grupo3_no_hit+ dgrupo3_no_hit,
		grupo5_hit = grupo5_hit + dgrupo5_hit,
		grupo5_no_hit = grupo5_no_hit+ dgrupo5_no_hit, 
		grupo6_hit = grupo6_hit +dGrupo6_hit, 
		grupo6_no_hit = grupo6_no_hit+ dGrupo6_no_hit,
		grupoa_hit = grupoa_hit +dGrupoa_hit,
		grupoa_no_hit = grupoa_no_hit +dGrupoa_no_hit,
		grupo7_hit = grupo7_hit + dgrupo7_hit,
		grupo7_no_hit =grupo7_no_hit +dgrupo7_no_hit,
		grupo8_hit = grupo8_hit + dgrupo8_hit,
		grupo8_no_hit =grupo8_no_hit +dgrupo8_no_hit,
		total_status_hit = total_status_hit+ dTotalHitDes,
		total_status_no_hit = total_status_no_hit+ dTotalNoHitDes,
		total_os = total_os + dTotalFinal
		where grupo  = vlgrupo +6 or grupo = 16;
		 --insert into bdicobranza:cb_bitacora (mensaje) values (vlGrupo||'Mensaje 1'||vlgrupo +6 )

		if vlgrupo in (3,4,5,1,2)  then 
		--if vlgrupo in (1,2)  then 
		  if vlgrupo in (1,2)  then 
			let vlGrupoAct = 13;
		  else let vlGrupoAct = 14;
		  end if;
		update ss_arbolsolicitudestmp
		set grupo1_hit = grupo1_hit + dgrupo1_hit,
		grupo1_no_hit = grupo1_no_hit +dgrupo1_no_hit, 
		grupo2_hit =  grupo2_hit +dgrupo2_hit,
		grupo2_no_hit = grupo2_no_hit + dgrupo2_no_hit,
		grupo3_hit = grupo3_hit + dgrupo3_hit,
		grupo3_no_hit = grupo3_no_hit+ dgrupo3_no_hit,
		grupo5_hit = grupo5_hit + dgrupo5_hit,
		grupo5_no_hit = grupo5_no_hit+ dgrupo5_no_hit,
		grupo6_hit = grupo6_hit +dGrupo6_hit,
		grupo6_no_hit = grupo6_no_hit+ dGrupo6_no_hit,
		grupoa_hit = grupoa_hit +dGrupoa_hit,
		grupoa_no_hit = grupoa_no_hit +dGrupoa_no_hit,
		grupo7_hit = grupo7_hit + dgrupo7_hit,
		grupo7_no_hit =grupo7_no_hit +dgrupo7_no_hit,
		grupo8_hit = grupo8_hit + dgrupo8_hit,
		grupo8_no_hit =grupo8_no_hit +dgrupo8_no_hit,
		total_status_hit = total_status_hit+ dTotalHitDes,
        total_status_no_hit = total_status_no_hit+ dTotalNoHitDes,
		total_os = total_os + dTotalFinal
		where grupo  = vlGrupoAct;
		end if;
		if vlgrupo in (3,4,5,6)  then
		   let vlGrupoAct = 15;
		update ss_arbolsolicitudestmp
		set grupo1_hit = grupo1_hit + dgrupo1_hit,
			grupo1_no_hit = grupo1_no_hit +dgrupo1_no_hit,
			grupo2_hit =  grupo2_hit +dgrupo2_hit,
			grupo2_no_hit = grupo2_no_hit + dgrupo2_no_hit,
			grupo3_hit = grupo3_hit + dgrupo3_hit,
			grupo3_no_hit = grupo3_no_hit+ dgrupo3_no_hit,
			grupo5_hit = grupo5_hit + dgrupo5_hit,
			grupo5_no_hit = grupo5_no_hit+ dgrupo5_no_hit,
			grupo6_hit = grupo6_hit +dGrupo6_hit,
			grupo6_no_hit = grupo6_no_hit+ dGrupo6_no_hit,
			grupoa_hit = grupoa_hit +dGrupoa_hit,
			grupoa_no_hit = grupoa_no_hit +dGrupoa_no_hit,
			grupo7_hit = grupo7_hit + dgrupo7_hit,
			grupo7_no_hit =grupo7_no_hit +dgrupo7_no_hit,
			grupo8_hit = grupo8_hit + dgrupo8_hit,
			grupo8_no_hit =grupo8_no_hit +dgrupo8_no_hit,
			total_status_hit = total_status_hit+ dTotalHitDes,
			total_status_no_hit = total_status_no_hit+ dTotalNoHitDes,
			total_os = total_os + dTotalFinal
		where grupo  = vlGrupoAct ;
		end if;
		commit work;
END FOREACH;
 ---Obtiene el valor total de las OS por hit, no hit y total para sacar los porcentajes
 select  total_status_hit,total_status_no_hit, total_os
   into  dTotalHitT, dTotalNoHitT, dTotalOST
   from ss_arbolsolicitudestmp
  where grupo = 16;

insert into ss_arbolsolicitudes_tmp  
select  descripcion, clave_status, clave_orden, grupo1_hit, grupo1_no_hit , grupo2_hit, grupo2_no_hit, 
		grupo3_hit, grupo3_no_hit, grupo5_hit, grupo5_no_hit, 
		grupo6_hit,grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit, 
    grupo8_hit, grupo8_no_hit,total_status_hit, total_status_no_hit,
		porcentaje_hit,porcentaje_no_hit,total_os, porcentaje_os, 0 detalle
from ss_arbolsolicitudestmp;
--into temp ss_arbolsolicitudes_tmp with no log;

---Validacion en caso de que la informacion no exista
  if dTotalOST = 0 then
	drop table  "informix".ss_arbolsolicitudestmp;
	drop table  "informix".SolDetalleEstado;
	drop table  "informix".ss_arbolsolicitudestmp2;
	drop table  "informix".ss_arbolsolicitudes_tmp;
	LET cCodRet = '000009';
	LET cDescripcion = 'CONSULTA SIN RESULTADOS';
	RETURN cCodRet, cDescripcion, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
  END IF;

LET dPaso = 4;
if pDesglose = 4 then
    insert into tdesglose
	SELECT a.sucursal,
		a.status_solicitud,
		nvl((select descripcion from bdisolic:ss_param_solicitudes where grupo_parametro = 'CAUSAS_OS' and valor_numerico = os.causasituacionespecial),'Sin Descripcion') DescripcionCausa, 
		nvl((select trim(valor_alfabetico) ||'-'|| valor_numerico::integer from bdisolic:ss_param_solicitudes where grupo_parametro = 'CAUSAS_OS' and valor_numerico = os.causasituacionespecial), os.causasituacionespecial::char(3)) Causa,
		nvl((select valor_numerico::integer from bdisolic:ss_param_solicitudes where grupo_parametro = 'CAUSAS_OS' and valor_numerico = os.causasituacionespecial), os.causasituacionespecial::integer) CausaOrden,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END ) grupo1_hit, 
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo1_no_hit, 
		sum(CASE WHEN (nvl(b.grupo,'') = '2') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo2_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo2_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '3') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo3_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo3_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '5') AND evalua_cc in ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo5_hit,
		sum(CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo5_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo6_hit, 
		sum(CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(evalua_cc,'') IN ('X','') THEN 1 ELSE 0 END) grupo6_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupoA_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupoA_no_hit,
		0 grupo7_hit, SUM(CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END) grupo7_no_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '8') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) grupo8_hit,
		sum(CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) grupo8_no_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = 'A') THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END+
			CASE WHEN (nvl(b.Grupo,'') = '8') THEN 1 ELSE 0 END) cantidad,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND evalua_cc in ('0','1','2','3','4')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END + CASE WHEN (nvl(b.Grupo,'') = 'A') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END+ 
      CASE WHEN (nvl(b.Grupo,'') = '8') AND evalua_cc IN ('0','1','2','3','4')  THEN 1 ELSE 0 END) cantidad_hit,
		sum(CASE WHEN (nvl(b.grupo,'') in ('1','4')) AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '2') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '3') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.grupo,'') = '5') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '6') AND NVL(evalua_cc,'') IN ('X','') THEN 1 ELSE 0 END + CASE WHEN (nvl(b.Grupo,'') = 'A') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END +
			CASE WHEN (nvl(b.Grupo,'') = '7') OR (NVL(pr.tipo_alta,'') = '2' and nvl(a.num_producto,'') = '6500') THEN 1 ELSE 0 END+
      CASE WHEN (nvl(b.Grupo,'') = '8') AND NVL(evalua_cc,'') IN ('X','')  THEN 1 ELSE 0 END) cantidad_no_hit

		--into  cStatus_solicitud, cDescripcion, ccausa, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo4_hit,dgrupo4_no_hit,dgrupo5_hit,dgrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit,dGrupoa_hit, dGrupoa_no_hit,
			--dTotalFinal, dTotalHitDes, dTotalNoHitDes
		
		FROM bdisolic:ss_resum_scor_fin b, bdisolic:ss_autorizacion c , bdisolic:ss_solicitud_os os, bdisolic:ss_solicitudes a, outer bdiprospectos:pr_cliente pr
		WHERE a.empresa = b.empresa 
		AND a.num_solicitud = b.num_solicitud AND a.num_solicitud = c.num_solicitud AND a.status_solicitud = c.status_solicitud
		AND A.empresa = os.empresa
		and A.num_solicitud = os.num_solicitud and a.numcte = pr.numcte
		AND c.fecha_entrada = (select max(fecha_entrada) from bdisolic:ss_autorizacion where a.empresa = empresa and a.num_solicitud = num_solicitud and a.status_solicitud = status_solicitud)
		AND a.num_producto = 	pProducto AND a.fecha_insert >= pFechaIni AND a.fecha_insert <= pFechaFin and pr.tipo_alta = '2'
		and (
				 ((pTpConsulta = '04'  and a.sucursal = cSucursal ) or (cSucursal ='') )
			)
		-- AND  a.status_solicitud in ('RT','OA' )  
		AND ((a.status_solicitud ='RT' and c.causa_solicitud = 'ROS')  or (a.status_solicitud  = 'OA'))
		and os.secuenciaos in (select max(secuenciaos) from bdisolic:ss_solicitud_os where empresa ='001' and num_solicitud =  os.num_solicitud )
		and os.secuenciaos =os.secuenciaos
		GROUP BY 1 ,2 ,3,4,5;
	--into temp tdesglose with no log;

  IF pTpConsulta = '01' THEN
    insert into tdesglose2
	SELECT status_solicitud, DescripcionCausa, causa, CausaOrden, sum(grupo1_hit) grupo1_hit , sum(grupo1_no_hit) grupo1_no_hit , sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit ) grupo2_no_hit,
			sum(grupo3_hit) grupo3_hit , sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit)  grupo5_no_hit,
			sum(grupo6_hit) grupo6_hit , sum(grupo6_no_hit)grupo6_no_hit , sum(grupoa_hit)grupoa_hit , sum(grupoa_no_hit)grupoa_no_hit , sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit, 
      sum(grupo8_hit) grupo8_hit, sum(grupo8_no_hit) grupo8_no_hit,sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad_hit)total_status_hit, sum(cantidad)  total_os
	FROM tdesglose a, bdinteg:si_sucursales s,bdinteg:si_ciudades c ,bdinteg:si_catciudades t
	left outer join bdinteg:si_regiones r on ( t.numero_region    = r.numero_region)
	WHERE s.empresa = pEmpresa /*AND a.status_solicitud = b.status_solicitud AND activa_reporte = "1"*/ AND a.sucursal = s.sucursal
	AND s.ciudad = c.ciudad AND s.pais = c.pais AND s.estado = c.estado AND c.ciudad_coppel = t.numerociudad
	AND ( c.estado = cEstado or cEstado ='' )
	group by 1,2,3,4;
	--into temp tdesglose2 with no log;

  ELIF pTpConsulta = '02' THEN LET cCiudad = pFiltro::CHAR(4);
     insert into tdesglose2
	SELECT  status_solicitud, DescripcionCausa, causa, CausaOrden, sum(grupo1_hit) grupo1_hit , sum(grupo1_no_hit) grupo1_no_hit , sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit ) grupo2_no_hit,
			sum(grupo3_hit) grupo3_hit , sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit)  grupo5_no_hit,
			sum(grupo6_hit) grupo6_hit , sum(grupo6_no_hit)grupo6_no_hit , sum(grupoa_hit)grupoa_hit , sum(grupoa_no_hit)grupoa_no_hit, sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit, 
      sum(grupo8_hit) grupo8_hit, sum(grupo8_no_hit) grupo8_no_hit, sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad_hit)total_status_hit, sum(cantidad)  total_os
	FROM tdesglose a, bdinteg:si_sucursales s,bdinteg:si_ciudades c ,bdinteg:si_catciudades t
	left outer join bdinteg:si_regiones r on (t.numero_region = r.numero_region)
	WHERE s.empresa = pEmpresa /*AND a.status_solicitud = b.status_solicitud AND activa_reporte = "1"*/ AND a.sucursal = s.sucursal
	AND s.ciudad = c.ciudad AND s.pais = c.pais AND s.estado = c.estado AND c.ciudad_coppel = t.numerociudad
	AND ( t.numerociudad = cCiudad or cCiudad ='' )
	group by 1,2,3,4;
	--into temp tdesglose2 with no log;
  ELIF pTpConsulta = '03' THEN
    insert into tdesglose2
	SELECT status_solicitud, DescripcionCausa, causa, CausaOrden, sum(grupo1_hit) grupo1_hit , sum(grupo1_no_hit) grupo1_no_hit , sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit ) grupo2_no_hit,
			sum(grupo3_hit) grupo3_hit , sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit)  grupo5_no_hit,
			sum(grupo6_hit) grupo6_hit , sum(grupo6_no_hit)grupo6_no_hit , sum(grupoa_hit)grupoa_hit , sum(grupoa_no_hit)grupoa_no_hit, sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit, 
      sum(grupo8_hit) grupo8_hit, sum(grupo8_no_hit) grupo8_no_hit, sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad_hit)total_status_hit, sum(cantidad) total_os
	FROM tdesglose a, bdinteg:si_sucursales s,bdinteg:si_ciudades c ,bdinteg:si_catciudades t
	left outer join bdinteg:si_regiones r on ( t.numero_region = r.numero_region)
	WHERE s.empresa = pEmpresa /*AND a.status_solicitud = b.status_solicitud AND activa_reporte = "1"*/ AND a.sucursal = s.sucursal
	AND s.ciudad = c.ciudad AND s.pais = c.pais AND s.estado = c.estado AND c.ciudad_coppel = t.numerociudad
	and ( r.numero_region = iRegion or iRegion =0)
	group by 1,2,3,4;
	--into temp tdesglose2 with no log;
  ELIF pTpConsulta = '04' THEN
   insert into tdesglose2
	select status_solicitud, DescripcionCausa, causa, CausaOrden, sum(grupo1_hit) grupo1_hit, sum(grupo1_no_hit) grupo1_no_hit, sum(grupo2_hit) grupo2_hit, sum(grupo2_no_hit) grupo2_no_hit,
			sum(grupo3_hit) grupo3_hit, sum(grupo3_no_hit) grupo3_no_hit, sum(grupo5_hit) grupo5_hit, sum(grupo5_no_hit) grupo5_no_hit,
			sum(grupo6_hit) grupo6_hit, sum(grupo6_no_hit)grupo6_no_hit, sum(grupoa_hit)grupoa_hit, sum(grupoa_no_hit)grupoa_no_hit, sum(grupo7_hit) grupo7_hit, sum(grupo7_no_hit) grupo7_no_hit, 
      sum(grupo8_hit) grupo8_hit, sum(grupo8_no_hit) grupo8_no_hit,sum(cantidad_hit)total_status_hit, sum(cantidad_no_hit) total_status_no_hit,
			sum(cantidad)  total_os
	from tdesglose
	group by 1,2,3,4;
	--into temp tdesglose2 with no log;
	END IF;

FOREACH
	select status_solicitud, DescripcionCausa, causa, CausaOrden, grupo1_hit, grupo1_no_hit, grupo2_hit, grupo2_no_hit,
			grupo3_hit, grupo3_no_hit, grupo5_hit, grupo5_no_hit,
			grupo6_hit, grupo6_no_hit, grupoa_hit, grupoa_no_hit, grupo7_hit, grupo7_no_hit, grupo8_hit, grupo8_no_hit,total_status_hit, total_status_no_hit,
			total_os
	into cStatus_solicitud, cDescripcion, ccausa, iCausaOrden, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit,dGrupoa_hit, dGrupoa_no_hit, dgrupo7_hit,dgrupo7_no_hit,
	    dgrupo8_hit,dgrupo8_no_hit,
		 dTotalHitDes, dTotalNoHitDes, dTotalFinal
	from tdesglose2

		if cStatus_solicitud ='RT' then
			let dDetalle = 1;
		elif cStatus_solicitud ='OA' then
			let dDetalle = 2;
		end if;
		INSERT INTO ss_arbolsolicitudes_tmp
		VALUES( '                 '||cDescripcion, ccausa, iCausaOrden, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit,dGrupoa_hit, dGrupoa_no_hit,dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit,
		dTotalHitDes,dTotalNoHitDes, 0,0, dTotalFinal, 0,dDetalle );
  END FOREACH;
  
end if;

---Actualiza los porcentajes
FOREACH --with hold
	 select clave_status, detalle, total_status_hit,total_status_no_hit, total_os
		into cStatus_solicitud, dDetalle, dTotalHit, dTotalNoHit, dTotalOS  
	 from ss_arbolsolicitudes_tmp

	if dTotalHitT = 0 then let dTotalHitT = 1; end if;
	if dTotalNoHitT = 0 then let dTotalNoHitT = 1; end if;
	if dTotalOST = 0 then let  dTotalOST = 1; end if;

	let dPorcenHit   =(dTotalHit/dTotalHitT)* 100;
	let dPorcenNoHit = (dTotalNoHit/ dTotalNoHitT)*100;
	let dPorcTotal   = (dTotalOS/dTotalOST)* 100 ;

	 --begin work;
	 update ss_arbolsolicitudes_tmp 
		set 
		porcentaje_hit = dPorcenHit,
		porcentaje_no_hit = dPorcenNoHit,
		porcentaje_os = dPorcTotal
		where clave_status = cStatus_solicitud and detalle = dDetalle;
		--commit work;
END FOREACH;

------------------------------------RETORNO DE RESULTADOS *******

	LET VSQL=''; LET i = 0;
	--SE HACEN LOS SELECTS A LA TABLA TEMPORAL EN EL ORDEN QUE SE DESEA QUE APAREZCAN EN PANTALLA
	WHILE i <= 24
	LET i = i + 1; LET VSQL = '';
	IF i = 1 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "OSN" ';
	ELIF i = 2 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "EEN" ';
	ELIF i = 3 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "EE" ';
	ELIF i = 4 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "CEE" ';
	ELIF i = 5 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "CEN" ';
	ELIF i = 6 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "CE" ';
	ELIF i = 7 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "CCE" ';
	ELIF i = 8 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "OSE" ';
	ELIF i = 9 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "OSA" ';
	ELIF i = 10 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "ATOS" ';
	ELIF i = 11 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "OSAP" ';
	ELIF i = 12 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "OSAT" ';
	ELIF i = 13 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "CVOS" ';
	ELIF i = 14 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "RTOS" ';
	ELIF i = 15 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "ROS" ';
	--ELIF i = 16 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE SUBSTR(clave_status,1,1) = "P" ';
	ELIF i = 16 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE detalle = 1 order by clave_orden ';
	ELIF i = 17 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "CROS" ';
	ELIF i = 18 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "OAOS" ';
	ELIF i = 19 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "OA" ';
	--ELIF i = 20 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE SUBSTR(clave_status,1,1) = "L" ';
	ELIF i = 20 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE detalle = 2 order by clave_orden ';
	ELIF i = 21 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "COA" ';
	ELIF i = 22 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "OSNA" '; 
	ELIF i = 23 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "OS" ';
	ELIF i = 24 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "COS" ';
	ELIF i = 25 THEN LET VSQL = 'SELECT * FROM "informix".ss_arbolsolicitudes_tmp WHERE clave_status = "" ';
	END IF;
	--system  ' echo "'||VSQL ||' "> querycoppel4.sql'; 			
	PREPARE xsql FROM TRIM(VSQL); DECLARE xcur CURSOR FOR xsql; OPEN xcur;		
	FETCH  xcur INTO cDescripcion, cStatus_solicitud, iCausaOrden, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit, dGrupoa_hit, dGrupoa_no_hit, dgrupo7_hit,dgrupo7_no_hit, dgrupo8_hit,dgrupo8_no_hit, dtotal_status_hit,dtotal_status_no_hit, dPorc_hit, dPorc_no_hit, dTotalOS, dPorcTotal, dDetalle; 
	
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN --PARAQ LOS CASOS DONDE i = 16 / i = 20
		CLOSE xcur; FREE xcur; FREE xsql;
		CONTINUE WHILE;
	END IF;
		
	WHILE  SQLCODE= 0 --ENTRA SI SIGUE ENCONTRANDO ELEMENTOS EL CURSOR
		RETURN cCodRet, cDescripcion, cStatus_solicitud, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit, dGrupoa_hit, dGrupoa_no_hit, dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit, dtotal_status_hit,dtotal_status_no_hit, dPorc_hit, dPorc_no_hit,dTotalOS, dPorcTotal WITH RESUME;
	FETCH  xcur INTO cDescripcion, cStatus_solicitud, iCausaOrden, dgrupo1_hit, dgrupo1_no_hit, dgrupo2_hit, dgrupo2_no_hit, dgrupo3_hit, dgrupo3_no_hit,dgrupo5_hit,dgrupo5_no_hit, dGrupo6_hit, dGrupo6_no_hit, dGrupoa_hit, dGrupoa_no_hit, dgrupo7_hit,dgrupo7_no_hit,dgrupo8_hit,dgrupo8_no_hit, dtotal_status_hit,dtotal_status_no_hit, dPorc_hit, dPorc_no_hit,dTotalOS, dPorcTotal, dDetalle;	
END WHILE--FIN DEL WHILE DEL CURSOR

	CLOSE xcur; FREE xcur; FREE xsql;
	END WHILE

	--SE ELIMINA LA TABLA TEMPORAL
	drop table  "informix".ss_arbolsolicitudestmp;
	drop table  "informix".SolDetalleEstado;
	drop table  "informix".ss_arbolsolicitudestmp2;
	drop table  "informix".ss_arbolsolicitudes_tmp;
	if pDesglose = 4 then
		drop table  "informix".tdesglose;
		drop table  "informix".tdesglose2;
	end if;
END
END PROCEDURE
