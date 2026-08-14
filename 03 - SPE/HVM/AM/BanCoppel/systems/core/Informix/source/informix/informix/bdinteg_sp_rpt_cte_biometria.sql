CREATE PROCEDURE "informix".sp_rpt_cte_biometria()
returning char(5) as CodRet;

DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err     INT;
DEFINE sFecha       CHAR(10);
DEFINE sfechaInicial CHAR(10);
DEFINE sfechaFinal   CHAR(10);
DEFINE sFechaArch   CHAR(10);
DEFINE cCmd1        CHAR(10000);
DEFINE cCmd2        CHAR(10000);
DEFINE cCmd3        CHAR(10000);
DEFINE cCmd4        CHAR(10000);
DEFINE cCmd5        CHAR(10000);
DEFINE cCmd6        CHAR(10000);
DEFINE cCmd7        CHAR(10000);
DEFINE cCmd8        CHAR(10000);
DEFINE cCmd9        CHAR(10000);
DEFINE cCmd11        CHAR(10000);
DEFINE cCmd12       CHAR(10000);
DEFINE cQuery        CHAR(10000);
DEFINE cQueryD        CHAR(10000);
DEFINE cQueryM        CHAR(10000);
DEFINE cQueryMB        CHAR(10000);
DEFINE cQueryMD        CHAR(10000);
DEFINE cQueryMBD        CHAR(10000);
DEFINE pArchDescarga CHAR(100);
DEFINE pArchDescargaG CHAR(100);
DEFINE pArchDescargaM CHAR(100);
DEFINE pArchDescargaMG CHAR(100);
DEFINE pArchDescargaMB CHAR(100);
DEFINE sDia          CHAR(2);
DEFINE sMes          CHAR(2);
DEFINE sYear         CHAR(4);
DEFINE dFbio         INT;

LET cCodRet 		='00000';
LET iSql_err        =0;
LET sFecha          ='';
LET sfechaInicial   ='';
LET sfechaFinal     ='';
LET cCmd1           ='';
LET cCmd2           ='';
LET cCmd3           ='';
LET cCmd4           ='';
LET cCmd5           ='';
LET cCmd6           ='';
LET cCmd7           ='';
LET cCmd8           ='';
LET cCmd9           ='';
LET cCmd11           ='';
LET cCmd12          ='';
LET pArchDescarga   ='';
LET pArchDescargaG   ='';
LET pArchDescargaM  ='';
LET pArchDescargaMG  ='';
LET pArchDescargaMB  ='';
LET sFechaArch      ='';
LET sDia            ='';
LET sMes            ='';
LET sYear           ='';
LET cQuery			='';
LET cQueryD			='';
LET cQueryM			='';
LET cQueryMB	    ='';
LET cQueryMD	    ='';
LET cQueryMBD	    ='';
LET dFbio           =0;

BEGIN

    ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
    
    ---SET DEBUG FILE TO '/RESPALDOSNEW/sp_rpt_cte_biometria.out';
    ---TRACE ON;
	
	
    LET sfecha = (select fecha_hoy from si_fechas WHERE empresa = "001");
    --LET sFechaArch=(select REPLACE(fecha_hoy,'/','') from si_fechas);

    LET sDia=(select day(fecha_hoy) from si_fechas);
    LET sMes=(select month(fecha_hoy) from si_fechas);
    LET sYear=(select year(fecha_hoy) from si_fechas);

    LET sfechaInicial = (SELECT TO_CHAR(fecha_hoy - 1 units month, '%m/%d/%Y') FROM bdinteg:si_fechas WHERE empresa = "001");
	LET sfechaFinal = (SELECT TO_CHAR(fecha_ant, '%m/%d/%Y') FROM bdinteg:si_fechas WHERE empresa = "001");
    IF LENGTH(sDia)<2 THEN
         LET sDia="0"||sDia;
    END IF;

    IF LENGTH(sMes)<2 THEN
         LET sMes="0"||sMes;
    END IF;

    LET sFechaArch=sDia||sMes||sYear;

    LET pArchDescarga='"/RESPALDOSNEW/reporte_clientes_biometria_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
	LET pArchDescargaG='"/RESPALDOSNEW/reporte_clientes_biometria_gral_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
	LET pArchDescargaM='"/RESPALDOSNEW/reporte_clientes_biometria_mes_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
	LET pArchDescargaMG='"/RESPALDOSNEW/reporte_clientes_biometria_mes_gral_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
	LET pArchDescargaMB='"/RESPALDOSNEW/reporte_clientes_biometria_mes_dfb_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
		

                ---Se consulta la tabla principal y se crea la tabla temporal con los indices.
        ---LET cCmd1 ='select numcte,tipo_cliente,tpo_persona,tpo_biometria,fecha_insert FROM bdinteg:si_cliente WHERE tipo_cliente="1" and tpo_persona="01" and fecha_insert<today INTO TEMP si_cliente_bio with no log; CREATE INDEX si_cliente_temp_idx on si_cliente_bio (numcte,tipo_cliente,tpo_persona,tpo_biometria,fecha_insert);';
			
		 		---De la tabla pricipal se obtiene el total de clientes titulares, total de clientes titulares con biometria.
		LET cCmd2 = 'select count(*) from bdinteg:si_cliente where tipo_cliente="1" and tpo_persona="01" and tpo_biometria="1" and fecha_insert< "'||sFecha||'"';
		LET cCmd3 = 'select count(*) from bdinteg:si_cliente where tipo_cliente="1" and tpo_persona="01" and fecha_insert< "'||sFecha||'"';
	
			    ---De la tabla pricipal se obtiene el total de clientes titulares y total de clientes titulares con biometria del mes.
     	
		LET cCmd4 = 'select count(*) from bdinteg:si_cliente where tipo_cliente="1" and tpo_persona="01" and tpo_biometria="1" and fecha_insert between "'||sfechaInicial||'" and "'||sfechaFinal||'"';	
       	LET cCmd5 = 'select count(*) from bdinteg:si_cliente where tipo_cliente="1" and tpo_persona="01" and tpo_biometria="0" and fecha_insert between "'||sfechaInicial||'" and "'||sfechaFinal||'"';
		
		
		---Se obtiene el total de cliente con fecha alta diferente a la fecha registro de biometria.
		LET cCmd6 = 'select count(cte.numcte) from bdinteg:si_cliente cte inner join bdirostros@coppelimg_tcp:si_cte_rostro bio on cte.numcte=bio.numcte and cte.fecha_insert<>bio.fecha_alta and cte.fecha_insert between "'||sfechaInicial||'" and "'||sfechaFinal||'" where cte.tipo_cliente= "1" and cte.tpo_biometria= "1"';
	
	
	 ---Se realiza la union de las dos consultas generales
	    ---LET cCmd7 = TRIM(cCmd2)||" UNION "||TRIM(cCmd3);
		LET cCmd7 = TRIM(cCmd2);
		LET cCmd11 = TRIM(cCmd3);
		LET cQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO "||TRIM(pArchDescarga)||"  "||TRIM(cCmd7)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
		LET cQueryD = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescargaG)||"  "||TRIM(cCmd11)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
		---LET cQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; " || TRIM(cCmd2)||" UNION "||TRIM(cCmd3)|| " " || " UNLOAD TO "||TRIM(pArchDescarga)||"  "||TRIM(cCmd7)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
	    ---LET cQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; " || TRIM(cCmd1)||" " || " UNLOAD TO "||TRIM(pArchDescarga)||"  "||TRIM(cCmd7)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
	  
	 ---Se realiza la union de las consultas por mes
	    LET cCmd8 = TRIM(cCmd4);
		LET cCmd12 = TRIM(cCmd5);
		LET cQueryM = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescargaM)||"  "||TRIM(cCmd8)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 "; 	  	 	 
		LET cQueryMD = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescargaMG)||"  "||TRIM(cCmd12)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 "; 	  	 	 
	    ----LET cQueryM = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; " || TRIM(cCmd1)||" " || " UNLOAD TO "||TRIM(pArchDescargaM)||"  "||TRIM(cCmd8)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";

	---Se descarga el resultado de la consulta entre la bdinteg:si_cliente y la bdidigital@coppelimg_tcp:si_cte_rostro.
	    LET cCmd9 = TRIM(cCmd6);
		LET cQueryMB = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescargaMB)||"  "||TRIM(cCmd9)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
		---LET cQueryMB = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; " || TRIM(cCmd6)||" " || " UNLOAD TO "||TRIM(pArchDescargaMB)||"  "||TRIM(cCmd9)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
	    ---LET cQueryMB = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; " || TRIM(cCmd1)||" " || " UNLOAD TO "||TRIM(pArchDescargaMB)||"  "||TRIM(cCmd9)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
	 
	    SYSTEM TRIM(cQuery);
	    SYSTEM TRIM(cQueryD);
        SYSTEM TRIM(cQueryM);
		SYSTEM TRIM(cQueryMD);
	    SYSTEM TRIM(cQueryMB);
		

	

RETURN cCodRet;
END;
END PROCEDURE;