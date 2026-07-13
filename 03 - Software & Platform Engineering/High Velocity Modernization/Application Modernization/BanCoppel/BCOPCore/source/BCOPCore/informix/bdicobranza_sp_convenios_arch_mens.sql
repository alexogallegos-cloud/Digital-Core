CREATE PROCEDURE "informix".sp_convenios_arch_mens(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pTipoEjec CHAR(1))
RETURNING CHAR(5)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		      CHAR(80) AS nombre_archivo; 
---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE cMensajeRet      CHAR(80);
DEFINE iSqlErr      	  INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cNombreArchivo	  CHAR(80);
DEFINE cNombreArchivo_2 CHAR(80);
DEFINE cTipoArchivo	    CHAR(10);
DEFINE cConsulta3		    CHAR(2000);
DEFINE cSql		 		      CHAR(2000);
DEFINE cRuta		        CHAR(80);
DEFINE dtFecha		      DATE;
DEFINE dFecha_ini       DATE;
DEFINE dFecha_fin       DATE;
DEFINE cProceso         CHAR(4);
DEFINE cMensajeFin      CHAR(100);
DEFINE vvcCod_ret       CHAR(6);
DEFINE dtFechaPrimerDia    DATE;
DEFINE dtFechaUltDiaMesAnt DATE;
DEFINE cMensajeFin_2    CHAR(100);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "00000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET cNombreArchivo		  = "Reporte_Convenios_Cajero_"; --Reporte_Convenios_Cajero_ddmmaaaa.txt.gz
LET cTipoArchivo     	  = "";
LET cConsulta3			    = "";
LET cRuta				        = "";
LET dtFecha				      = DATE(1);
LET dFecha_ini          = DATE(1);
LET dFecha_fin          = DATE(1);

LET cProceso            = '0140';
LET cMensajeFin         = 'PROCESO TERMINADO EXITOSAMENTE';
LET vvcCod_ret          = '';
LET dtFechaPrimerDia     = DATE(1);
LET dtFechaUltDiaMesAnt  = DATE(1);
LET cNombreArchivo_2     = '';
LET cMensajeFin_2        = '';    
BEGIN

  ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet= iSqlErr;
  	LET cMensajeRet = cErrorInfo;
    LET cMensajeFin = cErrorInfo;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeFin, '02')
          RETURNING vvcCod_ret;  	
    	
      RETURN cCodRet, cMensajeRet,"";
  END EXCEPTION;

  --SET DEBUG FILE TO '/informix/macf/sp_convenios_arch_mens.trc';
  --TRACE ON;

  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeFin, '01') RETURNING vvcCod_ret;

  SELECT fecha_hoy, pri_dia_mes   
		  INTO dtFecha, dtFechaPrimerDia 
		  FROM bdicred:sd_fechas
		 WHERE empresa = pEmpresa;

  IF pTipoEjec = 'A' THEN
    LET dtFechaUltDiaMesAnt = dtFechaPrimerDia - 1 UNITS day; 
    LET dFecha_ini =  mdy(month(dtFechaUltDiaMesAnt),1,year(dtFechaUltDiaMesAnt));
    LET dFecha_fin  = dtFechaUltDiaMesAnt;
  ELSE
    IF NVL(pEmpresa,"") = "" OR  NVL(pFechaIni,"") = "" OR  NVL(pFechaFin,"") = "" THEN
    	LET cCodRet= "00001";
    	LET cMensajeRet = "Parametro no valido para realizar la consulta";
    	RETURN cCodRet, cMensajeRet, "";
    END IF;
  
    LET dFecha_ini  = pFechaIni;
    LET dFecha_fin  = pFechaFin;
  END IF;

  
	SELECT {+ INDEX (bdicobranza:cb_param_campania idx_cb_paramcampania_params1)} TRIM(valor_alfabetico) 
	  INTO cRuta
	  FROM bdicobranza:cb_param_campania
	 WHERE tipo_campania = 11  
	   AND  grupo_parametro = 'RUTAS'
	   AND num_parametro =1;

		 

-- Reporte_Convenios_Cajero_ddmmaaaa.txt.gz
  LET cTipoArchivo = 'txt';
	--LET cNombreArchivo= TRIM(cNombreArchivo)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || YEAR(dtFecha) || '.' || cTipoArchivo;
  LET cNombreArchivo= TRIM(cNombreArchivo)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || substr(YEAR(dtFecha),3,2) || '.' || cTipoArchivo;

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
  IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'ctes_vencido'  AND dbsname = 'bdicobranza') THEN
        DROP TABLE "informix".ctes_vencido;
  END IF;
  
  IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'convenios_suc'  AND dbsname = 'bdicobranza') THEN
        DROP TABLE "informix".convenios_suc;
  END IF;
    
   create table "informix".ctes_vencido(
       sucursal        char(4),
       cant_ctes_venc  integer
   );
   
   create index "informix".idx_cte_vencido on "informix".ctes_vencido(sucursal);
   
   create table "informix".convenios_suc(
       sucursal        char(4),
       cant_convenios  integer
   );
   
   create index "informix".idx_convenios_suc on "informix".convenios_suc(sucursal);
    
    INSERT INTO "informix".ctes_vencido   
    SELECT sucursal, sum(numctes_vencido) cant_ctes_venc 
    FROM bdicred:sd_vencidos_suc 
    WHERE fecha_reg BETWEEN dFecha_ini AND dFecha_fin
    GROUP BY sucursal;
    --INTO temp ctes_vencido with no log;

    INSERT INTO "informix".convenios_suc
    SELECT sucursal, sum(cantidad) cant_convenios
     FROM bdicred:sd_convenios_sucursal
     WHERE fecha BETWEEN dFecha_ini AND dFecha_fin
     GROUP BY sucursal;
     --INTO temp convenios_suc WITH NO log;

     LET cConsulta3 = 'SELECT a.cant_ctes_venc, b.cant_convenios, sp.nombre plaza, sc.nombre ciudad, cch.sucursal,' || 
                             ' cch.empleado_captura, cch.nombre_efectuo, ' ||
                             ' DECODE(cch.origen,1,' || "'" || 'TIENDA' || "'" || ',2,' || "'" || 'SUCURSAL' || "'" || ',3,' || "'" || 'CAT' || "'" || ') origen,' || 
                             ' cch.tipo_compac, cch.plazo,' ||
                             ' cch.importe, CASE WHEN cch.imp_pagado > cch.importe THEN cch.importe ELSE cch.imp_pagado END imp_pagado,' ||
                             ' case when cch.fecha_compac = cch.fecha_insert then ' || "'" || 'MISMO DIA' || "'" ||
                                   ' when cch.flag_pago = 1 and cch.fecha_compac <> cch.fecha_insert then ' || "'" || 'CUMPLIDO' || "'" ||
                                   ' when cch.flag_pago = 0 then ' || "'" || 'NO CUMPLIDO' || "'" || ' end as CALIFICACION,' ||
                             --' case when cch.flag_pago = 1 and cch.fecha_compac <> cch.fecha_insert then ' || "'" || 'CUMPLIDO' || "'" ||
                             --      ' when cch.flag_pago = 1 and cch.fecha_compac = cch.fecha_insert then ' || "'" || 'MISMO DIA' || "'" ||  
                             --      ' when cch.flag_pago = 0 then ' || "'" || 'NO CUMPLIDO' || "'" || ' end as CALIFICACION,' ||
                             'cch.fecha_compac, cch.fecha_insert, cch.pago_programado ' ||
                      'FROM bdicobranza:cb_compac_his cch LEFT OUTER JOIN bdinteg:si_sucursales ss ON (cch.sucursal = ss.sucursal)' || 
                          ' LEFT OUTER JOIN bdinteg:si_plazas sp ON (ss.plaza = sp.plaza) ' || 
                          ' LEFT OUTER JOIN bdinteg:si_ciudades sc ON (ss.pais = sc.pais AND ss.estado = sc.estado AND ss.ciudad = sc.ciudad) ' ||
                          ' LEFT OUTER JOIN ' || "'informix'" || '.ctes_vencido a on (a.sucursal = cch.sucursal) ' ||
                          ' LEFT OUTER JOIN ' || "'informix'" ||'.convenios_suc b on (b.sucursal = cch.sucursal) ' ||
                      'WHERE cch.empresa= ' || "'" || pEmpresa || "' " || 
                       ' AND cch.fecha_insert BETWEEN ' ||  "'" || dFecha_ini  || "'" || ' AND ' || "'" || dFecha_fin || "';";

    
			LET cSql = '';
			
			LET cSql = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreArchivo) || ' DELIMITER '|| '''|'''|| ' ' || trim(cConsulta3)||'" > '|| TRIM(cRuta) ||'query1.sql';
			SYSTEM trim(cSql);
      system 'chmod 777 ' || trim(cRuta) || 'query1.sql';
      			
			LET cSql = '';
			LET cSql = "dbaccess bdicobranza " ||trim(cRuta)||'query1.sql';
			SYSTEM trim(cSql);
   	
			-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
			LET cSql = '';
			LET cSQL = "rm " ||trim(cRuta)||'query1.sql';
			SYSTEM trim(cSql); 
			LET cSql = '';
			--LET cSQL = "rm " ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl';		
			--SYSTEM cSql; 		

		--LET cNombreArchivo= trim(cNombreArchivo)||'.'||trim(cTipoArchivo);
    
    LET cSql = '';
    LET cSQL = "gzip -f " ||trim(cRuta)|| cNombreArchivo;
    SYSTEM trim(cSql);
    
    -- LET cNombreArchivo= trim(cNombreArchivo)||'.gz';
    
    ---- LLamado para que se genere el archivo por Sucursal
    --IF pTipoEjec = 'A' THEN
      CALL bdicred:"informix".sp_rep_convenios_suc(pEmpresa, dFecha_ini, dFecha_fin) returning vvcCod_ret, cMensajeFin_2, cNombreArchivo_2;
    --END IF;
    
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeFin, '03')  RETURNING vvcCod_ret;
       
		RETURN cCodRet, cMensajeRet,cNombreArchivo;
END
END PROCEDURE
;