CREATE PROCEDURE "informix".sp_rpt_sol_cel()
returning char(5) as CodRet;

DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err     INT;
DEFINE sFecha       CHAR(10);
DEFINE sFechaArch   CHAR(10);
DEFINE cCons1        CHAR(1000);
DEFINE cCons2        CHAR(1000);
DEFINE cCons3        CHAR(1000);
DEFINE cCons4        CHAR(1000);
DEFINE cCons5        CHAR(1000);
DEFINE cCons6        CHAR(1000);
DEFINE cCons7        CHAR(1000);
DEFINE cCons8        CHAR(8000);
DEFINE cQuery        CHAR(10000);
DEFINE pArchDescarga CHAR(100);
DEFINE sDia         CHAR(2);
DEFINE sMes         CHAR(2);
DEFINE sYear        CHAR(4);
DEFINE cnom_Sql   CHAR(100);
DEFINE cSQL3      CHAR(200);
define cRuta		char(100);

LET cCodRet 		='00000';
LET iSql_err        =0;
LET sFecha          ='';
LET cCons1           ='';
LET cCons2           ='';
LET cCons3           ='';
LET cCons4           ='';
LET cCons5           ='';
LET cCons6           ='';
LET cCons7           ='';
LET cCons8           ='';
LET pArchDescarga   ='';
LET sFechaArch      ='';
LET sDia            ='';
LET sMes            ='';
LET sYear           ='';
LET cQuery			='';
LET cnom_Sql      = "";
LET cSQL3         = "";
LET cRuta		 = "/RESPALDOSNEW/";


BEGIN

    ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
  
	--SET DEBUG FILE TO '/ifxsif01/sp_rpt_sol_cel.out';
    --TRACE ON;
	
    LET sfecha = (select fecha_hoy from bdinteg:si_fechas where fecha_hoy = today);

	
    LET sDia=(select day(fecha_hoy) from bdinteg:si_fechas where fecha_hoy = today);
    LET sMes=(select month(fecha_hoy) from bdinteg:si_fechas where fecha_hoy = today);
    LET sYear=(select year(fecha_hoy) from bdinteg:si_fechas where fecha_hoy = today);

	  IF LENGTH(sDia)<2 THEN
         LET sDia="0"||sDia;
    END IF;

    IF LENGTH(sMes)<2 THEN
         LET sMes="0"||sMes;
    END IF;

    LET sFechaArch=sDia||sMes||sYear;
	LET cnom_Sql = 'Reporte_aux.sql';
	LET pArchDescarga= "/RESPALDOSNEW/rep_sol_cel_"||TRIM(sFechaArch)||".csv";

	-- Aperturadas Cel. Confirmado
    LET cCons1 = "select 'Aperturadas Cel. Confirmado', sum(case when num_producto <> '6500' then 1 else 0 end), "
		||  " sum(case when num_producto = '6500' then 1 else 0 end) "
		||	" FROM bdisolic:ss_solicitudes a "
		||	" INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud "
		||	" AND a.status_solicitud=b.status_solicitud and b.fecha_insert=today  "
		||	" AND b.fecha_entrada = (select MAX(fecha_entrada) "
		||	" from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud "
		||	" AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert)) "
		||	" INNER JOIN bdinteg:'informix'.si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado = 'V') "
		||	" WHERE a.empresa='001' "
		||	" AND a.status_solicitud='AP' "
		||	" AND num_producto <> '6011' ";
	
	-- Autorizadas Cel. Confirmado
    LET cCons2 = "select  'Autorizadas Cel. Confirmado', sum(case when num_producto <> '6500' then 1 else 0 end), "
		||	" sum(case when num_producto = '6500' then 1 else 0 end) "
		||	" FROM bdisolic:ss_solicitudes a "
		||	" INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud "
		||	" AND a.status_solicitud=b.status_solicitud and b.fecha_insert=today  "
		||	" AND b.fecha_entrada = (select MAX(fecha_entrada) "
		||	" from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud "
		||	" AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert)) "
		||	" INNER JOIN bdinteg:'informix'.si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado = 'V') "
		||	" WHERE a.empresa='001' "
		||	" AND a.status_solicitud='AT' ";

	-- 	Rechazadas Cel. Confirmado
	LET cCons3 = "select  'Rechazadas Cel. Confirmado', sum(case when num_producto <> '6500' then 1 else 0 end), "
		||	" sum(case when num_producto = '6500' then 1 else 0 end) "
        ||	" FROM bdisolic:ss_solicitudes a "
        ||	" INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud "
		||	" AND a.status_solicitud=b.status_solicitud and b.fecha_insert=today  "
		||	" AND b.fecha_entrada = (select MAX(fecha_entrada) "
		||	" from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud "
		||	" AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert)) "
        ||	" INNER JOIN bdinteg:'informix'.si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado = 'V') "
        ||	" WHERE a.empresa='001' "
        ||	" AND a.status_solicitud='RT' ";
		
	-- 	Otras solicitudes en proceso Cel. Confirmado
	LET cCons4 = "select 'Otras solicitudes en proceso Cel. Confirmado', sum(case when num_producto <> '6500' then 1 else 0 end), "
		||	" sum(case when num_producto = '6500' then 1 else 0 end)  "
        ||	"FROM bdisolic:ss_solicitudes a "
        ||	"INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud "
		||	"AND a.status_solicitud=b.status_solicitud and b.fecha_insert=today  "
		||	"AND b.fecha_entrada = (select MAX(fecha_entrada) "
		||	"from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud "
		||	"AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert)) "
        ||	"INNER JOIN bdinteg:'informix'.si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado = 'V') "
        ||	"WHERE a.empresa='001' "
        ||	"AND a.status_solicitud not in ('AN','PC','AT','AP','CN','CM','RT') ";
		
	-- 	Autorizadas Cel. NO Confirmado
	LET cCons5 = "select 'Autorizadas Cel. NO Confirmado',  sum(case when num_producto <> '6500' then 1 else 0 end), "
		||	" sum(case when num_producto = '6500' then 1 else 0 end) "
        ||	" FROM bdisolic:ss_solicitudes a "
        ||	" INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud "
		||	" AND a.status_solicitud=b.status_solicitud and b.fecha_insert=today  "
		||	" AND b.fecha_entrada = (select MAX(fecha_entrada) "
		||	" from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud "
		||	" AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert)) "
        ||	" INNER JOIN bdinteg:'informix'.si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado <> 'V') "
        ||	" WHERE a.empresa='001' "
        ||	" AND a.status_solicitud='AT' ";

    -- 	Rechazadas Cel. NO Confirmado
	LET cCons6 = "select 'Rechazadas Cel. NO Confirmado', sum(case when num_producto <> '6500' then 1 else 0 end), "
		||	"sum(case when num_producto = '6500' then 1 else 0 end)  "
        ||	"FROM bdisolic:ss_solicitudes a "
        ||	"INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud "
		||	"AND a.status_solicitud=b.status_solicitud and b.fecha_insert=today  "
		||	"AND b.fecha_entrada = (select MAX(fecha_entrada) "
		||	"from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud "
		||	"AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert)) "
        ||	"INNER JOIN bdinteg:'informix'.si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado <> 'V') "
        ||	"WHERE a.empresa='001' "
        ||	"AND a.status_solicitud='RT' ";

    -- 	Otras solicitudes en proceso (Cel. NO Confirmado)
	LET cCons7 = "select 'Otras solicitudes en proceso Cel. NO Confirmado', sum(case when num_producto <> '6500' then 1 else 0 end), "
		||	"sum(case when num_producto = '6500' then 1 else 0 end)  "
        ||	"FROM bdisolic:ss_solicitudes a "
        ||	"INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud "
		||	"AND a.status_solicitud=b.status_solicitud and b.fecha_insert=today  "
		||	"AND b.fecha_entrada = (select MAX(fecha_entrada) "
		||	"from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud "
		||	"AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert)) "
        ||	"INNER JOIN bdinteg:'informix'.si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado <> 'V') "
        ||	"WHERE a.empresa='001' "
        ||	"AND a.status_solicitud not in ('AN','PC','AT','AP','CN','CM','RT') ";
	
	LET cCons8 = TRIM(cCons1)||" UNION ALL "||TRIM(cCons2)||" UNION ALL "||TRIM(cCons3)||" UNION ALL "||TRIM(cCons4)||" UNION ALL "||TRIM(cCons5)||" UNION ALL "||TRIM(cCons6)||" UNION ALL "||TRIM(cCons7);

	LET pArchDescarga = pArchDescarga;
	LET cSQL3 = '">'||TRIM(cRuta)|| cnom_Sql;
	
    LET cQuery = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||" delimiter ','  "||TRIM(cCons8) || " " || cSQL3;
	
    SYSTEM TRIM(cQuery);

	
	LET cQuery='chmod 777 '|| TRIM(cRuta)|| cnom_Sql;
    System cQuery;

    let cQuery = 'dbaccess bdinteg ' || TRIM(cRuta) || cnom_Sql;
    System cQuery;
	
	
	
RETURN cCodRet;
END;
END PROCEDURE;