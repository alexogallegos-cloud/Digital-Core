CREATE PROCEDURE "informix".sp_rpt_sol_movil()
returning char(5) as CodRet;

DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err     INT;
DEFINE sFecha       CHAR(10);
DEFINE sFechaArch   CHAR(10);
DEFINE cCmd1        CHAR(10000);
DEFINE cCmd2        CHAR(10000);
DEFINE cCmd3        CHAR(10000);
DEFINE cCmd4        CHAR(10000);
DEFINE cQuery        CHAR(10000);
DEFINE pArchDescarga CHAR(100);
DEFINE sDia         CHAR(2);
DEFINE sMes         CHAR(2);
DEFINE sYear        CHAR(4);

LET cCodRet 		='00000';
LET iSql_err        =0;
LET sFecha          ='';
LET cCmd1           ='';
LET cCmd2           ='';
LET cCmd3           ='';
LET cCmd4           ='';
LET pArchDescarga   ='';
LET sFechaArch      ='';
LET sDia            ='';
LET sMes            ='';
LET sYear           ='';
LET cQuery			='';

BEGIN

    ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
    
    --SET DEBUG FILE TO '/informix/VH/movil/sp_rpt_sol_movil.out';
    --TRACE ON;

    LET sfecha = (select fecha_hoy from si_fechas);
    --LET sFechaArch=(select REPLACE(fecha_hoy,'/','') from si_fechas);

    LET sDia=(select day(fecha_hoy) from si_fechas);
    LET sMes=(select month(fecha_hoy) from si_fechas);
    LET sYear=(select year(fecha_hoy) from si_fechas);

    IF LENGTH(sDia)<2 THEN
         LET sDia="0"||sDia;
    END IF;

    IF LENGTH(sMes)<2 THEN
         LET sMes="0"||sMes;
    END IF;

    LET sFechaArch=sDia||sMes||sYear;

    LET pArchDescarga='"/RESPALDOSNEW/reporte_de_solicitudes_moviles_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
	-- Solicitudes completas
    LET cCmd1 = 'select a.ejecutivo, d.nombre, a.fecha_insert, d.sucursal, d.centro_costos, b.producto,c.num_solicitud, a.ap_apell_paterno as apellido_paterno, a.ap_apell_materno as apell_materno, a.ap_nombre1 as nombre1, a.ap_nombre2 as nombre2, TO_CHAR(f.fecha_nac, "%d/%m/%Y"),a.telefono, c.status_solicitud, generico1 as Zona from bdinteg:si_solicitud_movil a, bdisolic:ss_solicitudes_movil b, bdisolic:ss_solicitudes c, (select distinct ejecutivo, nombre, sucursal, centro_costos, generico1 from si_usuario_movil where activo=1) d, bdinteg:si_cliente e, bdinteg:si_ctepf f where not a.folio is null and not a.numcte is null and a.folio=b.folio_movil and b.num_solicitud=c.num_solicitud and a.numcte=e.numcte and a.numcte=f.numcte and a.ejecutivo=d.ejecutivo and a.fecha_insert=c.fecha_insert and a.fecha_insert between "'||sFecha||'" and "'||sFecha||'"';
	
	-- Solicitudes rechazadas
    LET cCmd2 = 'select a.ejecutivo, d.nombre, a.fecha_insert, d.sucursal, d.centro_costos, b.producto,b.num_solicitud, a.ap_apell_paterno as apellido_paterno, a.ap_apell_materno as apell_materno, a.ap_nombre1 as nombre1, a.ap_nombre2 as nombre2, TO_CHAR(f.fecha_nac, "%d/%m/%Y"), a.telefono, "RT", generico1 as Zona from bdinteg:si_solicitud_movil a, bdisolic:ss_solicitudes_movil b, (select distinct ejecutivo, nombre, sucursal, centro_costos, generico1 from si_usuario_movil where activo=1) d, bdinteg:si_cliente e, bdinteg:si_ctepf f where not a.folio is null and not a.numcte is null and a.folio=b.folio_movil and b.num_solicitud = "" and a.numcte=e.numcte and a.numcte=f.numcte and a.ejecutivo=d.ejecutivo and a.fecha_insert between "'||sFecha||'" and "'||sFecha||'"';
	
	-- Solicitudes inconclusas
    --LET cCmd3 = 'select  a.ejecutivo, d.nombre, a.fecha_insert, d.sucursal, " "," ", a.apell_paterno as apell_paterno, a.apell_materno as apell_materno, a.nombre1 as nombre1, a.nombre2 as nombre2, a.fecha_nac,a.telefono, "INCONCLUSO", generico1 as Zona from bdinteg:si_solicitud_movil a, (select distinct ejecutivo, nombre, sucursal, generico1 from si_usuario_movil) d where a.folio is null and a.ejecutivo=d.ejecutivo and a.fecha_insert between "'||sFecha||'" and "'||sFecha||'"';
		
	--LET cCmd4 = TRIM(cCmd1)||" UNION "||TRIM(cCmd2)||" UNION "||TRIM(cCmd3)||" ORDER BY 1;";
	  LET cCmd4 = TRIM(cCmd1)||" UNION "||TRIM(cCmd2)||" ORDER BY 1;";
	
	LET cQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescarga)||"  "||TRIM(cCmd4)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
	--LET cQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescarga)||"  "||TRIM(cCmd4)||"' | /informix/bin/dbaccess bdinteg > /dev/null 2>&1";
	
    SYSTEM TRIM(cQuery);

RETURN cCodRet;
END;
END PROCEDURE;