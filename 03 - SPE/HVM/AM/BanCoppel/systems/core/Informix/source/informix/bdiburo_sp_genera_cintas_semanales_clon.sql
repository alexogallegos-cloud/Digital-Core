CREATE PROCEDURE "informix".sp_genera_cintas_semanales_clon()
RETURNING CHAR(6),
          CHAR(100);

DEFINE vcodret                       CHAR(6);
DEFINE vfecha_hoy                    DATE;
DEFINE vPriDiaMes                    DATE;
DEFINE vheader                       CHAR(150);
DEFINE vanio                         CHAR(4);
DEFINE vmes                          CHAR(2);
DEFINE vdia                          CHAR(2);
DEFINE vencabezado1                  CHAR(4);
DEFINE vversion                      CHAR(2);
DEFINE vclave_usu                 	 CHAR(10);
DEFINE vclave_usu_bc                 CHAR(10);
DEFINE vnombre_usu                   CHAR(16);
DEFINE vciclo                        CHAR(2);
DEFINE vfecha_reporte                CHAR(8);
DEFINE vfechaup                		 CHAR(8);
DEFINE vuso_futuro                   CHAR(10);
DEFINE vinf_adicional                CHAR(98);
DEFINE vsql                          CHAR(2000);
DEFINE vnumreg                       INTEGER;
DEFINE dtFechaProxReporte            DATE;
DEFINE sProceso                      SMALLINT;
DEFINE cStatusProc                   CHAR(1);
DEFINE cMensajeFin                   CHAR(100);
DEFINE iTotalProcesados              INTEGER;
DEFINE isqlErr                   	 INTEGER;

LET dtFechaProxReporte      = DATE(1);
LET sProceso                = 0;
LET cStatusProc             = "";
LET iTotalProcesados        = 0;
LET vclave_usu       		= '';
LET vclave_usu_bc    		= '';
LET cMensajeFin 			= 'El proceso CINTAS PAGOS PARCIALES CTAS. REVOLVENTES se ejecutó exitosamente.';


BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
      LET vcodret = iSqlErr;

      LET cMensajeFin = 'Proceso CINTAS PAGOS PARCIALES CTAS. REVOLVENTES cancelado';

      RETURN vcodret,cMensajeFin;

      ROLLBACK WORK;

   END IF;
END EXCEPTION;

LET vcodret = "000000";
LET vsql = "";

--SET DEBUG FILE TO "sp_genera_cintas_semanales.out";
--TRACE ON; 

   SELECT UPPER(valor) 
     INTO vclave_usu
     FROM br_param
    WHERE cod_param = 1;

    SELECT UPPER(valor) 
      INTO vclave_usu_bc
      FROM br_param
     WHERE cod_param = 127;
	
/*
   SELECT UPPER(valor) 
     INTO vencabezado1
     FROM br_param
    WHERE cod_param = 3;

   SELECT UPPER(valor) 
     INTO vversion
     FROM br_param
    WHERE cod_param = 4;

   SELECT UPPER(valor) 
     INTO vnombre_usu
     FROM br_param
    WHERE cod_param = 6;

   SELECT UPPER(valor) 
     INTO vciclo
     FROM br_param
    WHERE cod_param = 7;

    SELECT UPPER(valor) 
      INTO vuso_futuro
      FROM br_param
     WHERE cod_param = 8;

     LET vinf_adicional = "&";

     SELECT fecha_hoy,pri_dia_mes
       INTO vfecha_hoy,vPriDiaMes
       FROM bdicred:sd_fechas
      WHERE empresa='001';
*/

    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT substr(registro,35,8) INTO vfecha_reporte
	FROM bdiburo:br_burofisicas_cortos_clon
	WHERE numreg=1;
	IF vfecha_reporte IS NULL OR vfecha_reporte = '' THEN
		LET vcodret = '000001';
		LET cMensajeFin = 'Proceso CINTAS PAGOS PARCIALES CTAS. REVOLVENTES sin información.';
		RETURN vcodret,cMensajeFin;
	end if;
-- Extracción Círculo de Crédito	
    LET vsql = '';
    LET vsql = 'echo " UNLOAD TO /resplogifx/burodecredito/enviodepagos/xburofiscortos_clon.unl' ||
--             ' SELECT registro FROM bdiburo:br_burofisicas_cortos WHERE numreg=1 ' ||
					' SELECT replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||''') FROM bdiburo:br_burofisicas_cortos_clon where numreg=1' ||			 
                    ' UNION ' ||
                    ' SELECT CASE WHEN substr(a.registro,1,2)='||'''TL'''||' AND a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
                    ' THEN trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-3))::lvarchar ||' || 
					    ' trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-2))::lvarchar ||' || 
						' trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-1))::lvarchar||' || 
						' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar|| ' ||  
						' trim((replace(registro,'||'''3002CV9903FIN'''||','||'''3002NV9903FIN'''||')))::lvarchar '  ||
                    ' ELSE trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-3))::lvarchar||' ||  
					    ' trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-2))::lvarchar||' ||  
						' trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-1))::lvarchar||' ||  
						' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar ' ||  
--						' trim(registro)::lvarchar' ||  
                    ' END' ||  
                    ' FROM bdiburo:br_burofisicas_cortos_clon a where substr(a.registro,1,2)='||'''TL'''||' '||  
                    ' UNION ' ||  
                    ' SELECT '||'''TRLR'''||'||lpad(sum(saldo_actual)::DEC(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::DEC(14,0),14,'||'''0'''||')' ||  
                    ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
                    ' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
                    ' FROM bdiburo:br_burofisicas_describe_cortos_clon;' ||
                    ' " > /resplogifx/burodecredito/enviodepagos/genburofiscortos_clon.sql';
    SYSTEM vsql;

    LET vsql = '';
    LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/enviodepagos/genburofiscortos_clon.sql';
    SYSTEM vsql;

    LET vsql = "sed 's/&/ /g' /resplogifx/burodecredito/enviodepagos/xburofiscortos_clon.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos_clon.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/enviodepagos/xburofis1cortos_clon.unl > /resplogifx/burodecredito/enviodepagos/xburofis2cortos_clon.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/|//g' /resplogifx/burodecredito/enviodepagos/xburofis2cortos_clon.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos_clon.unl ";
    SYSTEM vsql;

    LET vsql = "cat /resplogifx/burodecredito/enviodepagos/xburofis1cortos_clon.unl | tr -d '\n' > /resplogifx/burodecredito/enviodepagos/cintafispagos_circulo"||vfecha_reporte||"_PARCIAL_clon.txt ";
    SYSTEM vsql;

    LET vsql = "rm /resplogifx/burodecredito/enviodepagos/xburofiscortos_clon.unl /resplogifx/burodecredito/enviodepagos/xburofis1cortos_clon.unl /resplogifx/burodecredito/enviodepagos/xburofis2cortos_clon.unl /resplogifx/burodecredito/enviodepagos/genburofiscortos_clon.sql";
    SYSTEM vsql;

    LET vsql = "gzip /resplogifx/burodecredito/enviodepagos/cintafispagos_circulo"||vfecha_reporte||"_PARCIAL_clon.txt ";
    SYSTEM vsql;

-- Extracción Buró de Crédito
    LET vsql = '';
    LET vsql = 'echo " UNLOAD TO /resplogifx/burodecredito/enviodepagos/xburofiscortos_bc_clon.unl' ||
             ' SELECT registro FROM bdiburo:br_burofisicas_cortos_clon WHERE numreg=1 ' ||
                    ' UNION ' ||
                    ' SELECT CASE WHEN substr(a.registro,1,2)='||'''TL'''||' AND a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
                    ' THEN trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-3))::lvarchar ||' || 
					' trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-2))::lvarchar ||' || 
                    ' trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-1))::lvarchar||' || 
                    ' trim((replace(registro,'||'''3002CV9903FIN'''||','||'''3002NV9903FIN'''||')))::lvarchar '  ||
                    ' ELSE trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-3))::lvarchar||' ||  
					' trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-2))::lvarchar||' ||  
                    ' trim((select registro from bdiburo:br_burofisicas_cortos_clon where numreg=a.numreg-1))::lvarchar||' ||  
                    ' trim(registro)::lvarchar' ||  
                    ' END' ||  
                    ' FROM bdiburo:br_burofisicas_cortos_clon a where substr(a.registro,1,2)='||'''TL'''||' '||  
                    ' UNION ' ||  
                    ' SELECT '||'''TRLR'''||'||lpad(sum(saldo_actual)::DEC(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::DEC(14,0),14,'||'''0'''||')' ||  
                    ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
                    ' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
                    ' FROM bdiburo:br_burofisicas_describe_cortos_clon;' ||
                    ' " > /resplogifx/burodecredito/enviodepagos/genburofiscortos_bc_clon.sql';
    SYSTEM vsql;

    LET vsql = '';
    LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/enviodepagos/genburofiscortos_bc_clon.sql';
    SYSTEM vsql;

    LET vsql = "sed 's/&/ /g' /resplogifx/burodecredito/enviodepagos/xburofiscortos_bc_clon.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos_bc_clon.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/enviodepagos/xburofis1cortos_bc_clon.unl > /resplogifx/burodecredito/enviodepagos/xburofis2cortos_bc_clon.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/|//g' /resplogifx/burodecredito/enviodepagos/xburofis2cortos_bc_clon.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos_bc_clon.unl ";
    SYSTEM vsql;

    LET vsql = "cat /resplogifx/burodecredito/enviodepagos/xburofis1cortos_bc_clon.unl | tr -d '\n' > /resplogifx/burodecredito/enviodepagos/cintafispagos_buro"||vfecha_reporte||"_clon.txt ";
    SYSTEM vsql;

    LET vsql = "rm /resplogifx/burodecredito/enviodepagos/xburofiscortos_bc_clon.unl /resplogifx/burodecredito/enviodepagos/xburofis1cortos_bc_clon.unl /resplogifx/burodecredito/enviodepagos/xburofis2cortos_bc_clon.unl /resplogifx/burodecredito/enviodepagos/genburofiscortos_bc_clon.sql";
    SYSTEM vsql;

    LET vsql = "gzip /resplogifx/burodecredito/enviodepagos/cintafispagos_buro"||vfecha_reporte||"_clon.txt ";
    SYSTEM vsql;

RETURN vcodret,cMensajeFin;

END;
END PROCEDURE;