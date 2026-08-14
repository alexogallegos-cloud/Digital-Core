CREATE PROCEDURE "informix".sp_reportes_agex_resultado(pFecha DATE)
--RETURNING CHAR(6) AS codigo_retorno;
RETURNING CHAR(6), CHAR(80); 
          
DEFINE cCodRet             CHAR(6); 
DEFINE cMensajeRet         CHAR(80);
DEFINE iSqlErr             INTEGER;
DEFINE iIsamErr            INTEGER;
DEFINE cErrorInfo          CHAR(80);
DEFINE cSql                CHAR(2204);
DEFINE cNombreArchivo1     CHAR(50); 
DEFINE cNombreArchivo      CHAR(50);
DEFINE cRuta               CHAR(100);
DEFINE iDatos              INTEGER;
DEFINE cEmpresa            CHAR(3);
DEFINE cSeparador          CHAR(1);
DEFINE cSql_c              CHAR(250);
DEFINE cSql_lgo            CHAR(1000);
DEFINE cMensaje            CHAR(80);
DEFINE iParam              SMALLINT;
DEFINE vproceso			   CHAR(06);
DEFINE cCod_RetIB          CHAR(6);
DEFINE dtFecha_ini         DATE;
DEFINE dtFecha_fin         DATE;
DEFINE dtFecha_hoy         DATE;
DEFINE cMes                CHAR(2);
DEFINE dtDiaFin_MesAnterior  DATE;
DEFINE cArch_asignacion    CHAR(50);
DEFINE cArch_asignacion_2  CHAR(50);
DEFINE cArch_pagos_cob     CHAR(50);
DEFINE cArch_pagos_cob_2   CHAR(50);
DEFINE cArch_pagos_cob_3   CHAR(50);
DEFINE cArch_pagos_cob_4   CHAR(50);
DEFINE cArch_moras_cob	   CHAR(50); 
DEFINE cArch_moras_cob_2   CHAR(50);
DEFINE dtFecha_asignacion  DATE; 	  
DEFINE iDia_fecha_asignacion SMALLINT;
DEFINE dtFecha_asignacion_2 DATE;
DEFINE cArch_encabezado     CHAR(30);
DEFINE cArch_encabezado_2   CHAR(30);
DEFINE cArch_encabezado_3   CHAR(30);
DEFINE cNombreArchivo_temp  CHAR(80);
DEFINE cCodRetIB            CHAR(6);
DEFINE dtMesAnterior        DATE;
DEFINE dtMesAnterior_ini    DATE;
DEFINE cNum_credito         CHAR(20);
DEFINE cNum_credito_actual  CHAR(20);
DEFINE i_mto_fin_ven_trasp  INTEGER;
DEFINE iCont_numvencs       INTEGER;
DEFINE iExisteTabla         INTEGER;

LET cCodRet                = "000000"; 
LET cMensajeRet            = 'PROCESO EXITOSO'; 
LET iSqlErr                = 0;
LET iIsamErr               = 0;
LET cErrorInfo             = "";
LET cSql                   = "";
LET cNombreArchivo1        = "";
LET cNombreArchivo         = "";
LET cRuta                  = "";
LET iDatos                 = 0;
LET cEmpresa               = '001';
LET cSeparador             = '';
LET cSql_c                 = "";
LET cSql_lgo               = "";
LET cMensaje               = "";
LET iParam                 = 0;
LET vproceso			   = "0091";
LET cCod_RetIB             = '000000';
LET dtFecha_ini            = date(1);
LET dtFecha_fin            = date(1); 
LET dtFecha_hoy            = date(1);
LET cMes                   = '';
LET dtDiaFin_MesAnterior   = date(1);
LET cArch_asignacion       = '';
LET cArch_asignacion_2     = '';
LET cArch_pagos_cob        = '';
LET cArch_pagos_cob_2      = '';
LET cArch_pagos_cob_3      = '';
LET cArch_pagos_cob_4      = '';
LET cArch_moras_cob	       = '';
LET cArch_moras_cob_2      = '';
LET dtFecha_asignacion     = date(1);
LET iDia_fecha_asignacion  = 0;
LET dtFecha_asignacion_2   = date(1);
LET cArch_encabezado       = 'encabezado_asigcart.txt';
LET cArch_encabezado_2     = 'encabezado_pagoscob.txt';
LET cArch_encabezado_3     = 'encabezado_morascob.txt';
LET cNombreArchivo_temp    = '';
LET cCodRetIB              = "000000";
LET dtMesAnterior          = date(1);
LET dtMesAnterior_ini      = date(1);
LET cNum_credito           = '';
LET cNum_credito_actual    = ''; 
LET i_mto_fin_ven_trasp    = 0;
LET iCont_numvencs         = 0;
LET iExisteTabla           = 0;
    
-----------------------Descripcion de Errores controlados----------------------------
--104001	Es necesario proporcionar todos los parametros de ejecucion                     
--104002	La empresa proporcionada es invalida                                            
--104003	El tipo de campaña indicado no existe                                           
--104004	No se encuentra el parametro con el caracter de separador de archivo            
--104005	No se encuentra la ruta para almacenar el archivo                               
--104006	No se encuentra el parametro para nombrar el archivo                            
--104007	Es necesario proporcionar la empresa                                            
--104008	Es necesario indicar la fecha a consultar                                       
--104009	No se encontraron clientes marcados como excluidos                              
-------------------------------------------------------------------------------------
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
        LET cCodRet     = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCodRet,cMensajeRet,"02")
                     INTO cCodRetIB;
       RETURN cCodRet, trim(cMensajeRet); 
    END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  --SET DEBUG FILE TO 'sp_reportes_agex_resultado.trc';
  --TRACE ON;
 
 /*SELECT fecha_hoy INTO dtFecha_hoy
    FROM bdicred:sd_fechas
    WHERE empresa = cEmpresa; 
 */
 
 IF NVL(pFecha,'') <> '' THEN
    LET dtFecha_hoy = pFecha;
 ELSE
    LET dtFecha_hoy = today;
 END IF;
 
 --LET dtFecha_hoy = mdy(2,8,2020); -- SOLO TEST MACF
 
 EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,"000000","PROC. INI. REPS AGEX RESULTADO","02")
             INTO cCodRetIB;
 

 -- obtener la ruta donde se almacenara el archivo que sera enviado a buro de credito
 SELECT valor_alfabetico 
  INTO cRuta
  FROM bdicobranza:cb_param_campania
 WHERE empresa         = cEmpresa
   AND tipo_campania   = '1'
   AND grupo_parametro = 'ARCHIVOS'
   AND num_parametro   = 3;


 IF NVL(cRuta,"")    = "" THEN
    LET cCodRet     = "104005";
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCodRet,cMensaje,"02")
                  INTO cCodRetIB;
    RETURN cCodRet, trim(cMensaje); 
 END IF;

  
 -- Para obtener los rangos de fechas para los productos de tipo cobranza R
 IF DAY(dtFecha_hoy) = 8 OR DAY(dtFecha_hoy) = 15 OR DAY(dtFecha_hoy) = 22  THEN
 
    LET dtFecha_fin = dtFecha_hoy - 1 UNITS DAY;
	LET dtFecha_ini = dtFecha_hoy - 7 UNITS DAY;
		
 ELIF DAY(dtFecha_hoy) = 1 THEN

    LET dtDiaFin_MesAnterior = dtFecha_hoy -1 UNITS DAY;
	LET dtFecha_ini = LPAD(MONTH(dtDiaFin_MesAnterior),2,0) || '/22/' || YEAR(dtDiaFin_MesAnterior);
    LET dtFecha_fin = dtDiaFin_MesAnterior;
	
 END IF;
 

-- Se obtiene el separador de los campos
SELECT valor_alfabetico 
  INTO cSeparador
  FROM bdicobranza:cb_param_campania
 WHERE empresa         = cEmpresa
   AND tipo_campania   = '1'
   AND grupo_parametro = 'ARCHIVOS'
   AND num_parametro   = 2;

	IF NVL(cSeparador,"") = "" THEN
        LET cCodRet     = "104004";
     SELECT descripcion
       INTO cMensaje
       FROM bdicobranza:"informix".cb_errores
      WHERE origen       = 3
        AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet, trim(cMensaje); 
    END IF;

	-- Saco la fecha máxima indicando el producto 8100 pq es día 18, para que tome de ahí en adelante (incluyendo el 20)
	SELECT MAX(fecha_insert) INTO dtFecha_asignacion
	  FROM bdicobranza:cb_cat_directorio_cte
	 WHERE empresa = cEmpresa
	   AND num_producto = '8100'
	   AND tipo_cobranza = 'A'; 
	
	IF DAY(dtFecha_hoy) = 1 OR DAY(dtFecha_hoy) = 8 OR DAY(dtFecha_hoy) = 15 OR DAY(dtFecha_hoy) = 22  THEN
	
		----------------------------------------------------- Archivo:   Asignacion_Prueba_Cob_ddmmaaaa.txt.gz
		-- Se obtiene del nombre del archivo
	   SELECT valor_alfabetico INTO cNombreArchivo_temp 
		 FROM bdicobranza:cb_param_campania
		WHERE empresa         = cEmpresa
		  AND tipo_campania   = '1'
		  AND grupo_parametro = 'ARCHIVOS'
		  AND num_parametro   = 90;

		  
		IF NVL(cNombreArchivo_temp,"") = "" THEN
			LET cCodRet = "104006";
			SELECT descripcion
			  INTO cMensaje
			  FROM bdicobranza:"informix".cb_errores
			 WHERE origen       = 3
			   AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

			EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCodRet,cMensaje,"02")
						 INTO cCodRetIB;
			RETURN cCodRet, trim(cMensaje); 
		END IF;
		 

		/*SELECT MAX(fecha_insert) INTO dtFecha_asignacion
		  FROM bdicobranza:cb_cat_directorio_cte
		 WHERE empresa = cEmpresa
		   AND num_producto = '8100'
		   AND tipo_cobranza = 'A'; 
		 */ 
		
		LET iDia_fecha_asignacion = day(dtFecha_asignacion); 
		
		IF DAY(dtFecha_hoy) < iDia_fecha_asignacion THEN
		   LET dtFecha_asignacion_2 = dtFecha_asignacion - 1 UNITS MONTH; --   mdy(month(vfecha_fin_mes_ant),vDiacorte,year(vfecha_fin_mes_ant)); 
		ELIF DAY(dtFecha_hoy) >= iDia_fecha_asignacion THEN
		   LET dtFecha_asignacion_2 = dtFecha_asignacion;
		END IF;	
		
		
		--IF day(dtFecha_ini) >= 1 and DAY(dtFecha_fin) <= 18 THEN

		LET cArch_asignacion = TRIM(cNombreArchivo_temp)|| LPAD(TRIM(DAY(dtFecha_fin)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_fin)::CHAR(2)),2,'0') || YEAR(dtFecha_fin) || '_temp.txt';
		LET cArch_asignacion_2 = TRIM(cNombreArchivo_temp)|| LPAD(TRIM(DAY(dtFecha_fin)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_fin)::CHAR(2)),2,'0') || YEAR(dtFecha_fin) || '.txt';
		
		LET cSql_c = 'echo "Cliente|Credito|Producto|FechaAsignacion|CanalAsignacion|MesesVencido|" > '|| TRIM(cRuta) || cArch_encabezado;
		SYSTEM trim(cSql_c);
		
		LET cSql_c = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| TRIM(cRuta) || trim(cArch_asignacion) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query_asigcart_1.sql';
		SYSTEM trim(cSql_c);
		
		-- TIPOS COBRANZA A Y R
		LET cSql_lgo = 'echo " SELECT numcte, num_credito, num_producto, to_char(fecha_insert, ''' || '%d/%m/%Y' || '''), canal, pago_venc '	
						|| 'FROM bdicobranza:cb_cat_directorio_cte '
						|| 'WHERE tipo_cobranza = ''' || 'A' || "' "
						|| 'AND fecha_insert >= ' || "'" || dtFecha_asignacion_2 || "' "
						|| ' UNION '   
						|| 'SELECT numcte, num_credito, num_producto, to_char(fecha_insert, ''' || '%d/%m/%Y' || '''), canal, pago_venc ' 
						|| 'FROM bdicobranza:cb_cat_directorio_cte '
						|| 'WHERE tipo_cobranza = ''' || 'R' || "' "
						|| ' AND fecha_insert BETWEEN ' || "'" || dtFecha_ini || "'" || ' AND ' || "'" ||dtFecha_fin || "'" || '" >> ' || trim(cRuta)|| 'query_asigcart_1.sql';
		SYSTEM trim(cSql_lgo);

		LET cSql_c = ''; 
		LET cSql_c = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query_asigcart_1.sql'; 
		SYSTEM trim(cSql_c);
		
		LET cSql_c = ''; 
		LET cSql_c = 'cat ' || trim(cRuta) || trim(cArch_encabezado) || ' ' || trim(cRuta) || trim(cArch_asignacion)  || '>' ||trim(cRuta) || trim(cArch_asignacion_2); 
		SYSTEM trim(cSql_c);
		
		LET cSql_c = '';
		LET cSql_c = "gzip -f " ||trim(cRuta)|| trim(cArch_asignacion_2);
		SYSTEM trim(cSql_c);
		
		LET cSql_c = '';
		LET cSql_c = "rm " ||trim(cRuta)|| trim(cArch_asignacion);
		SYSTEM trim(cSql_c);
		
		----------------------------------------------------------------------------------------------------------------------------------------------------------
		----------------------------------------------------- Archivo:  Pruebas_Pagos_Cob_ddmmaaaa.txt.gz  -------------------------------------------------------
		-- B) Reporte en el cual se muestren los pagos diarios realizados a las cuentas que se han asignado a
		-- los distintos canales de cobranza.
		SELECT valor_alfabetico INTO cNombreArchivo_temp 
		 FROM bdicobranza:cb_param_campania
		WHERE empresa         = cEmpresa
		  AND tipo_campania   = '1'
		  AND grupo_parametro = 'ARCHIVOS'
		  AND num_parametro   = 91;
		  
		  
		IF NVL(cNombreArchivo_temp,"") = "" THEN
			LET cCodRet = "104006";
			SELECT descripcion
			  INTO cMensaje
			  FROM bdicobranza:"informix".cb_errores
			 WHERE origen       = 3
			   AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

			EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCodRet,cMensaje,"02")
						 INTO cCodRetIB;
			RETURN cCodRet, trim(cMensaje); 
		END IF;
		
		LET cArch_pagos_cob = TRIM(cNombreArchivo_temp)|| LPAD(TRIM(DAY(dtFecha_fin)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_fin)::CHAR(2)),2,'0') || YEAR(dtFecha_fin) || '_temp.txt';
		LET cArch_pagos_cob_2 = TRIM(cNombreArchivo_temp)|| LPAD(TRIM(DAY(dtFecha_fin)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_fin)::CHAR(2)),2,'0') || YEAR(dtFecha_fin) || '_A.txt';

		LET cSql_c = ''; 
		LET cSql_c = 'echo "Cliente|Credito|Producto|Fecha|ImportePago|CapitalVencido|CapitalVigente|" > '|| TRIM(cRuta) || cArch_encabezado_2;
		SYSTEM trim(cSql_c);
		
		LET cSql_c = '';
		LET cSql_c = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| TRIM(cRuta) || trim(cArch_pagos_cob) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query_pagoscob.sql';
		SYSTEM trim(cSql_c);
		
		LET cSql_lgo = '';
		/*LET cSql_lgo = 'echo "SELECT a.numcte, a.num_credito, a.num_producto, to_char(c.fecha_mov, ''' || '%d/%m/%Y' || '''), SUM(c.monto),'
					 || 'nvl(b.monto_vencido,0)+nvl(b.mto_venc_trasp,0), nvl(b.sdo_capital,0)+nvl(b.cap_tras_no_venci,0) '
					 || 'FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_maesdos b, bdicred:sd_movhis c ' 
					 || 'WHERE a.num_credito = b.num_credito and a.num_credito = c.num_credito ' 
					 || 'AND c.empresa = ' || "'" || cEmpresa || "'"   
					 || ' AND c.fecha_mov BETWEEN ' || "'" || dtFecha_ini || "'" || ' AND ' || "'" ||dtFecha_fin || "' "
					 || 'AND a.num_credito >= ''' || '600000000001' || "' "
					 || 'AND c.codigo_fun IN(SELECT cod_fun FROM bdicred:sd_conceptospagomanual) '
					 || 'AND c.codigo_ref = 1 ' 
					 || 'AND c.reversado = ''' || 'N' || "' " 
					 || 'AND a.tipo_cobranza = ''' || 'A' || "' " 
					 || 'AND a.fecha_insert >= ' || "'" || dtFecha_asignacion_2 || "' "
					 || 'group by 1,2,3,4,6,7 ' || '" >> ' || trim(cRuta)||'query_pagoscob.sql';
		*/
        /*
		LET cSql_lgo = 'echo "SELECT a.numcte, a.num_credito, a.num_producto, to_char(a.fecha_ult_pago, ''' || '%d/%m/%Y' || '''), a.monto_ult_pago_periodo,'
					 || 'nvl(b.monto_vencido,0)+nvl(b.mto_venc_trasp,0), nvl(b.sdo_capital,0)+nvl(b.cap_tras_no_venci,0) '
					 || 'FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_maesdos b ' 
					 || 'WHERE a.num_credito = b.num_credito ' 
					 || 'AND a.num_credito >= ''' || '600000000001' || "' "
					 || 'AND a.tipo_cobranza = ''' || 'A' || "' " 
					 || 'AND a.fecha_insert >= ' || "'" || dtFecha_asignacion_2 || "' " || '" >> ' || trim(cRuta)||'query_pagoscob.sql';
					 
					 --|| 'group by 1,2,3,4,6,7 ' || '" >> ' || trim(cRuta)||'query_pagoscob.sql';
		
		SYSTEM trim(cSql_lgo);
		*/
		
		LET cSql_lgo = 'echo "SELECT a.numcte, a.num_credito, a.num_producto, to_char(c.fecha_insert, ''' || '%d/%m/%Y' || '''),' 
                    || 'c.pago_realizado, nvl(b.monto_vencido,0)+nvl(b.mto_venc_trasp,0) capital_venc,'
                    || 'nvl(b.sdo_capital,0)+nvl(b.cap_tras_no_venci,0) capital_vig ' 
                    || 'FROM bdicobranza:cb_cat_directorio_cte a,' 
                    || ' bdicred:sd_maesdos b,'
                    || ' bdicobranza:cb_evaluacion_objetiva_his c '
                    || 'WHERE a.num_credito = b.num_credito AND a.num_credito = c.num_credito ' 
                    || 'AND a.num_credito >= ''' || '600000000001' || "' "
                    || 'AND a.tipo_cobranza = ''' || 'A' || "' "
                    || 'AND a.fecha_insert >= ' || "'" || dtFecha_asignacion_2 || "' "
					|| 'AND c.fecha_insert BETWEEN ' || "'" || dtFecha_ini || "'" || ' AND ' || "'" ||dtFecha_fin || "' "
                    || 'AND c.reversado = ''' || 'N' || "' " || '" >> ' || trim(cRuta)||'query_pagoscob.sql';
		
		SYSTEM trim(cSql_lgo);

		LET cSql_c = ''; 
		LET cSql_c = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query_pagoscob.sql'; 
		SYSTEM trim(cSql_c);
		
		LET cSql_c = ''; 
		LET cSql_c = 'cat ' || trim(cRuta) || trim(cArch_encabezado_2) || ' ' || trim(cRuta) || trim(cArch_pagos_cob)  || '>' ||trim(cRuta) || trim(cArch_pagos_cob_2); 
		SYSTEM trim(cSql_c);

		
		--LET cSql_c = '';
		--LET cSql_c = "gzip -f " ||trim(cRuta)|| trim(cArch_pagos_cob_2);
		--SYSTEM trim(cSql_c); 				 
		
		
		LET cSql_c = ''; 
		LET cSql_c = 'rm ' || trim(cRuta) || trim(cArch_pagos_cob);	
		SYSTEM trim(cSql_c);  

		LET cArch_pagos_cob_4 = TRIM(cNombreArchivo_temp)|| LPAD(TRIM(DAY(dtFecha_fin)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_fin)::CHAR(2)),2,'0') || YEAR(dtFecha_fin) || '.txt';
		LET cArch_pagos_cob_3 = TRIM(cNombreArchivo_temp)|| LPAD(TRIM(DAY(dtFecha_fin)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_fin)::CHAR(2)),2,'0') || YEAR(dtFecha_fin) || '_R.txt'; 
		
		LET cSql_c = '';
		LET cSql_c = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| TRIM(cRuta) || trim(cArch_pagos_cob_3) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query_pagoscob_2.sql';
		SYSTEM trim(cSql_c);
		
		LET cSql_lgo = '';
		LET cSql_lgo = 'echo "SELECT a.numcte, a.num_credito, a.num_producto, to_char(c.fecha_mov, ''' || '%d/%m/%Y' || '''), SUM(c.monto),'
					 || 'nvl(b.monto_vencido,0)+nvl(b.mto_venc_trasp,0), nvl(b.sdo_capital,0)+nvl(b.cap_tras_no_venci,0) '
					 || 'FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_maesdoscrd b, bdicred:sd_movhiscrd c ' 
					 || 'WHERE a.num_credito = b.num_credito and a.num_credito = c.num_credito ' 
					 || 'AND c.empresa = ' || "'" || cEmpresa || "'"   
					 || ' AND c.fecha_mov BETWEEN ' || "'" || dtFecha_ini || "'" || ' AND ' || "'" ||dtFecha_fin || "' "
					 || 'AND a.num_credito >= ''' || '600000000001' || "' "
					 || 'AND c.codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd where num_producto = c.num_producto) '
					 || 'AND c.codigo_ref = 1 ' 
					 || 'AND c.reversado = ''' || 'N' || "' " 
					 || ' AND a.tipo_cobranza = ''' || 'R' || "' " 
					 --|| 'AND a.fecha_insert BETWEEN ' || "'" || dtFecha_ini || "'" || ' AND ' || "'" ||dtFecha_fin || "' "
					 || 'group by 1,2,3,4,6,7 ' || '" >> ' || trim(cRuta)||'query_pagoscob_2.sql';	
        

		SYSTEM trim(cSql_lgo);
		
		LET cSql_c = ''; 
		LET cSql_c = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query_pagoscob_2.sql'; 
		SYSTEM trim(cSql_c);
		
		LET cSql_c = '';
		LET cSql_c = 'cat ' || trim(cRuta) || trim(cArch_pagos_cob_2) || ' ' || trim(cRuta) || trim(cArch_pagos_cob_3)  || '>' ||trim(cRuta) || trim(cArch_pagos_cob_4); 
		SYSTEM trim(cSql_c);

		LET cSql_c = '';
		LET cSql_c = "gzip -f " ||trim(cRuta)|| trim(cArch_pagos_cob_4);
		SYSTEM trim(cSql_c); 				 

		LET cSql_c = ''; 
		LET cSql_c = 'rm ' || trim(cRuta) || trim(cArch_pagos_cob_2) || ' ' || trim(cRuta) || trim(cArch_pagos_cob_3);	
		SYSTEM trim(cSql_c);  
	
	ELIF DAY(dtFecha_hoy) = 2 THEN
	----------------------------------------------------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------- Archivo:  Reporte_Mora_Prueba_Cob_ddmmaaaa.txt.gz  -------------------------------------------------------
    --Reporte donde se muestra la situación del cliente al inicio y al final de cada mes, este reporte se generará de forma mensual, es decir deberá mostrar
 	-- la situación del crédito al inicio del mes y cómo cierra el mes.
		SELECT valor_alfabetico INTO cNombreArchivo_temp 
		 FROM bdicobranza:cb_param_campania
		WHERE empresa         = cEmpresa
		  AND tipo_campania   = '1'
		  AND grupo_parametro = 'ARCHIVOS'
		  AND num_parametro   = 92;
		  
		  
		IF NVL(cNombreArchivo_temp,"") = "" THEN
			LET cCodRet = "104006";
			SELECT descripcion
			  INTO cMensaje
			  FROM bdicobranza:"informix".cb_errores
			 WHERE origen       = 3
			   AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

			EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCodRet,cMensaje,"02")
						 INTO cCodRetIB;
			RETURN cCodRet, trim(cMensaje); 
		END IF;
		
		LET dtMesAnterior = dtFecha_hoy - 2 UNITS DAY;   --COMENTADO SOLO PARA TEST MACF
		--LET dtMesAnterior = MDY(10,28,2019);  -- SOLO TEST
		LET dtMesAnterior_ini = LPAD(MONTH(dtMesAnterior),2,0) || '/01/' || YEAR(dtMesAnterior);
		
		LET cSql_c = ''; 
		LET cSql_c = 'echo "Cliente|Credito|MoraInicio|MoraFin|" > '|| TRIM(cRuta) || cArch_encabezado_3;
		SYSTEM trim(cSql_c);
			
		LET cArch_moras_cob = TRIM(cNombreArchivo_temp)|| LPAD(TRIM(DAY(dtFecha_hoy)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_hoy)::CHAR(2)),2,'0') || YEAR(dtFecha_hoy) || '_temp.txt';
		LET cArch_moras_cob_2 = TRIM(cNombreArchivo_temp)|| LPAD(TRIM(DAY(dtFecha_hoy)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_hoy)::CHAR(2)),2,'0') || YEAR(dtFecha_hoy) || '.txt';

		LET cSql_c = '';
		LET cSql_c = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| TRIM(cRuta) || trim(cArch_moras_cob) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query_morascob.sql';
		SYSTEM trim(cSql_c);

		
		SELECT count(*) into iExisteTabla
		  FROM systables 
         WHERE tabname= 'cb_mora_cob_temp';
    
        IF iExisteTabla > 0 THEN
           DROP TABLE "informix".cb_mora_cob_temp;
        END IF;
		
		create table "informix".cb_mora_cob_temp(
		 num_credito char(20),
		 mora_ini    integer default 0,
		 mora_fin    integer default 0
		);
		
		
		CREATE INDEX "informix".idx_cb_mora_cob_temp ON "informix".cb_mora_cob_temp(num_credito) online;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_mora_cob_temp;
		
		FOREACH WITH HOLD
			SELECT b.num_credito, b.mto_fin_ven_trasp INTO  cNum_credito, i_mto_fin_ven_trasp 
			  FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_maesdoshistcrd b
			 WHERE a.num_credito = b.num_credito
			   AND a.fecha_insert BETWEEN dtMesAnterior_ini AND dtMesAnterior
			   AND a.tipo_cobranza = 'R'
			   AND b.fecha BETWEEN dtMesAnterior_ini AND dtMesAnterior
			   --AND a.fecha_insert >= dtFecha_asignacion  (error)
			   --AND a.fecha_insert >= dtMesAnterior_ini
			 order by b.num_credito, b.fecha
			 
		 
			 IF cNum_credito_actual = cNum_credito THEN
			    BEGIN;
			      UPDATE "informix".cb_mora_cob_temp SET mora_fin = i_mto_fin_ven_trasp
				  WHERE num_credito = cNum_credito_actual;
				COMMIT;
			 ELSE
			    BEGIN;
				 INSERT INTO "informix".cb_mora_cob_temp (num_credito, mora_ini)
				   VALUES(cNum_credito, i_mto_fin_ven_trasp);
				COMMIT;
			 END IF;
			 LET iCont_numvencs = iCont_numvencs + 1;
			 
			 LET cNum_credito_actual = cNum_credito;
		 
			 
		END FOREACH;

		
		IF DAY(dtMesAnterior) = 30 THEN 
		
			LET cSql_lgo = '';
			LET cSql_lgo = 'echo "SELECT a.numcte, a.num_credito, b.meses_vencidos1, b.meses_vencidos30 '
						 || 'FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_sdodiario b '   
						 || 'WHERE a.num_credito = b.num_credito '
						 || 'AND b.fecha = ' || "'" || dtMesAnterior_ini || "' " 
						 || 'AND a.tipo_cobranza = ''' || 'A' || "' "
						 || 'AND a.fecha_insert >= ''' || dtFecha_asignacion || "' "
                         || 'UNION ' 
                         || 'SELECT a.numcte, a.num_credito, b.mora_ini, b.mora_fin '   
						 || 'FROM bdicobranza:cb_cat_directorio_cte a, cb_mora_cob_temp b '
                         || 'WHERE a.num_credito = b.num_credito '
                         || 'AND a.fecha_insert BETWEEN ' || "'" || dtMesAnterior_ini || "' " || 'AND' || " '" || dtMesAnterior || "' " 
                         || 'AND a.tipo_cobranza = ''' || 'R' || "'" || '" >> ' || trim(cRuta)||'query_morascob.sql';	
						 
			SYSTEM trim(cSql_lgo);

			LET cSql_c = ''; 
			LET cSql_c = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query_morascob.sql'; 
			SYSTEM trim(cSql_c);
			
			/*LET cSql_c = '';
			LET cSql_c = 'cat ' || trim(cRuta) || trim(cArch_encabezado_3) || ' ' || trim(cRuta) || trim(cArch_moras_cob)  || '>' ||trim(cRuta) || trim(cArch_moras_cob_2); 
			SYSTEM trim(cSql_c);
			
			LET cSql_c = '';
			LET cSql_c = "gzip -f " ||trim(cRuta)|| trim(cArch_moras_cob_2);
			SYSTEM trim(cSql_c); 
			
			LET cSql_c = ''; 
		    LET cSql_c = 'rm ' || trim(cRuta) || trim(cArch_moras_cob);	
		    SYSTEM trim(cSql_c);*/
		
		ELIF DAY(dtMesAnterior) = 31 THEN
		
			LET cSql_lgo = '';
			LET cSql_lgo = 'echo "SELECT a.numcte, a.num_credito, b.meses_vencidos1, b.meses_vencidos31 '
						 || 'FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_sdodiario b '   
						 || 'WHERE a.num_credito = b.num_credito '
						 || 'AND b.fecha = ' || "'" || dtMesAnterior_ini || "' " 
						 || 'AND a.tipo_cobranza = ''' || 'A' || "' "
						 || 'AND a.fecha_insert >= ''' || dtFecha_asignacion || "' "
                         || 'UNION ' 
                         || 'SELECT a.numcte, a.num_credito, b.mora_ini, b.mora_fin '   
						 || 'FROM bdicobranza:cb_cat_directorio_cte a, cb_mora_cob_temp b '
                         || 'WHERE a.num_credito = b.num_credito '
                         || 'AND a.fecha_insert BETWEEN ' || "'" || dtMesAnterior_ini || "' " || 'AND' || " '" || dtMesAnterior || "' " 
                         || 'AND a.tipo_cobranza = ''' || 'R' || "'" || '" >> ' || trim(cRuta)||'query_morascob.sql';	
				 
			SYSTEM trim(cSql_lgo);

			--LET cMensajeRet = trim(cMensajeRet); -- || 'Regs. proc. = '  || iCont_numvencs; 
		    --RETURN cCodRet, trim(cMensajeRet); 
			
			LET cSql_c = ''; 
			LET cSql_c = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query_morascob.sql'; 
			SYSTEM trim(cSql_c);
			
			/*LET cSql_c = '';
			LET cSql_c = 'cat ' || trim(cRuta) || trim(cArch_encabezado_3) || ' ' || trim(cRuta) || trim(cArch_moras_cob)  || '>' ||trim(cRuta) || trim(cArch_moras_cob_2); 
			SYSTEM trim(cSql_c);
			
			LET cSql_c = '';
			LET cSql_c = "gzip -f " ||trim(cRuta)|| trim(cArch_moras_cob_2);
			SYSTEM trim(cSql_c); 

		    LET cSql_c = ''; 
		    LET cSql_c = 'rm ' || trim(cRuta) || trim(cArch_moras_cob);	
		    SYSTEM trim(cSql_c);
		    */
		
		ELIF DAY(dtMesAnterior) = 28 THEN
		
		    LET cSql_lgo = '';
			LET cSql_lgo = 'echo "SELECT a.numcte, a.num_credito, b.meses_vencidos1, b.meses_vencidos28 '
						 || 'FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_sdodiario b '   
						 || 'WHERE a.num_credito = b.num_credito '
						 || 'AND b.fecha = ' || "'" || dtMesAnterior_ini || "' " 
						 || 'AND a.tipo_cobranza = ''' || 'A' || "' "
						 || 'AND a.fecha_insert >= ''' || dtFecha_asignacion || "' "
                         || 'UNION ' 
                         || 'SELECT a.numcte, a.num_credito, b.mora_ini, b.mora_fin '   
						 || 'FROM bdicobranza:cb_cat_directorio_cte a, cb_mora_cob_temp b '
                         || 'WHERE a.num_credito = b.num_credito '
                         || 'AND a.fecha_insert BETWEEN ' || "'" || dtMesAnterior_ini || "' " || 'AND' || " '" || dtMesAnterior || "' " 
                         || 'AND a.tipo_cobranza = ''' || 'R' || "'" || '" >> ' || trim(cRuta)||'query_morascob.sql';	
				 
			SYSTEM trim(cSql_lgo);

			--LET cMensajeRet = trim(cMensajeRet); -- || 'Regs. proc. = '  || iCont_numvencs; 
		    --RETURN cCodRet, trim(cMensajeRet); 
			
			LET cSql_c = ''; 
			LET cSql_c = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query_morascob.sql'; 
			SYSTEM trim(cSql_c);
			
			/*LET cSql_c = '';
			LET cSql_c = 'cat ' || trim(cRuta) || trim(cArch_encabezado_3) || ' ' || trim(cRuta) || trim(cArch_moras_cob)  || '>' ||trim(cRuta) || trim(cArch_moras_cob_2); 
			SYSTEM trim(cSql_c);
			
			LET cSql_c = '';
			LET cSql_c = "gzip -f " ||trim(cRuta)|| trim(cArch_moras_cob_2);
			SYSTEM trim(cSql_c); 

		    LET cSql_c = ''; 
		    LET cSql_c = 'rm ' || trim(cRuta) || trim(cArch_moras_cob);	
		    SYSTEM trim(cSql_c);
		    */
			
		ELIF DAY(dtMesAnterior) = 29 THEN
		
		    LET cSql_lgo = '';
			LET cSql_lgo = 'echo "SELECT a.numcte, a.num_credito, b.meses_vencidos1, b.meses_vencidos29 '
						 || 'FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_sdodiario b '   
						 || 'WHERE a.num_credito = b.num_credito '
						 || 'AND b.fecha = ' || "'" || dtMesAnterior_ini || "' " 
						 || 'AND a.tipo_cobranza = ''' || 'A' || "' "
						 || 'AND a.fecha_insert >= ''' || dtFecha_asignacion || "' "
                         || 'UNION ' 
                         || 'SELECT a.numcte, a.num_credito, b.mora_ini, b.mora_fin '   
						 || 'FROM bdicobranza:cb_cat_directorio_cte a, cb_mora_cob_temp b '
                         || 'WHERE a.num_credito = b.num_credito '
                         || 'AND a.fecha_insert BETWEEN ' || "'" || dtMesAnterior_ini || "' " || 'AND' || " '" || dtMesAnterior || "' " 
                         || 'AND a.tipo_cobranza = ''' || 'R' || "'" || '" >> ' || trim(cRuta)||'query_morascob.sql';	
				 
			SYSTEM trim(cSql_lgo);

			--LET cMensajeRet = trim(cMensajeRet); -- || 'Regs. proc. = '  || iCont_numvencs; 
		    --RETURN cCodRet, trim(cMensajeRet); 
			
			LET cSql_c = ''; 
			LET cSql_c = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query_morascob.sql'; 
			SYSTEM trim(cSql_c);
			
			/*LET cSql_c = '';
			LET cSql_c = 'cat ' || trim(cRuta) || trim(cArch_encabezado_3) || ' ' || trim(cRuta) || trim(cArch_moras_cob)  || '>' ||trim(cRuta) || trim(cArch_moras_cob_2); 
			SYSTEM trim(cSql_c);
			
			LET cSql_c = '';
			LET cSql_c = "gzip -f " ||trim(cRuta)|| trim(cArch_moras_cob_2);
			SYSTEM trim(cSql_c); 

		    LET cSql_c = ''; 
		    LET cSql_c = 'rm ' || trim(cRuta) || trim(cArch_moras_cob);	
		    SYSTEM trim(cSql_c);
		    */
		
		END IF;
	
	    LET cSql_c = '';
		LET cSql_c = 'cat ' || trim(cRuta) || trim(cArch_encabezado_3) || ' ' || trim(cRuta) || trim(cArch_moras_cob)  || '>' ||trim(cRuta) || trim(cArch_moras_cob_2); 
		SYSTEM trim(cSql_c);
			
		LET cSql_c = '';
		LET cSql_c = "gzip -f " ||trim(cRuta)|| trim(cArch_moras_cob_2);
		SYSTEM trim(cSql_c); 
			
		LET cSql_c = ''; 
		LET cSql_c = 'rm ' || trim(cRuta) || trim(cArch_moras_cob);	
		SYSTEM trim(cSql_c);
	
        --DROP TABLE "informix".cb_mora_cob_temp;   -- COMENTAR SOLO TEST
		
	END IF;
	
	
	EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCodRet,cMensajeRet,"03") INTO cCod_RetIB;
	
RETURN cCodRet, trim(cMensajeRet);

END
END PROCEDURE
DOCUMENT 
'Genera archivo de asignación cartera cobranza todos los canales',
'AUTOR : Marco A. Campos',
'FECHA : 2019/11/15',
'VERSION:20191113.1420',
'BD    : BDICOBRANZA',
'Modif: 2020-01-23';

CREATE PROCEDURE "informix".sp_marcaracuerdoscumplidos( pEmpresa char(3), pTipo char(1), pFecha date )
RETURNING CHAR(5);

--Fecha de creación: 13/01/2009
--Programó: Anselmo Verdugo
--Objetivo: Store Procedure que realiza el marcaje de los compromisos y acuerdos que ya fueron
--cumplidos o en su defecto los que ya s evencieron.

--Fecha de Modificación: 24/01/2009
--Programó: Walber Castro
--Objetivo: Se agregan 2 parámetros de entrada al spl; una fecha y un tipo de
--ejecución que puede ser 0 (cero para automático) o 1 (uno para manual).
--Tomar la fecha de ejecución de la tabla bdinteg:si_fechas (campo
--fecha_hoy)y considerarla para el procesamiento de los Compromisos / Acuerdos
--cuando el parámetro de tipo de ejecución sea cero. En otro caso considerar
--como fecha de ejecución la fecha que pasa como parámetro.

--Fecha de Modificación: 07/02/2009
--Programó: Bernardo Carlos Baez Gonzalez
--Objetivo: Se modifica para que se actualize el campo flag_pago de el compromizo de pago 
--en base a los campos numcuenta y fecha_compac ya que antes solo se validaba el campo numcuenta
--Se modifica el borrado para que se borren los mismos registros que se han pasado al historico

--Fecha de Modificación: 09/03/2009
--Programó: Bernardo Carlos Baez Gonzalez
--Objetivo: Se modifica para que para que sean procesados, únicamente, los Compromisos y Acuerdos 
--que se vencen en la fecha de ejecución del proceso.

/*Fecha de Modificación: 03/11/2009
  Faviola Martínez Juárez
  Se integra monto pagado cuando un convenio es cumplido 
*/
 
--Modifico: Adilene Lara                                                                               
--Fecha: 17/03/2010                                                                                    
--Se modifica para que en caso de ocurrir un error guarde el detalle del convenio en cb_compac_error y en la cb_bitacora_cob
-- ademas de registrar el inicio y el fin del proceso en la tabla cb_bitacora_cob                                                 

/*Fecha de Modificación: 30/12/2010
  Enrique Lizárraga Lugo
  Se añade validación para evitar que se marque mas de un convenio en caso de que esté repetido. Se marca únicamente el convenio
  que tenga el valor mayor en keyx.
*/
--Modificó³: Marco A. Campos
--Fecha: 2011-06-23
--Se modifica condición de fecha_compac de obtención de compromisos y acuerdos para que diario se califiquen los convenios que reciben pago y  aún no es su fecha de vencimiento  

--Modificó³: Abrham Lopez L
--Fecha: 2013-08-01
--Se modifica agrega condición del campo hora_mov de la tabla sd_movhis sea > hora_inser de la tabla cb_compac

/*Modificó: Carlos Valenzuela
  Fecha: 2016-04-14
  Se modifica el proceso para que solo realiza el marcaje de los compromisos y acuerdos que ya fueron
  cumplidos o en su defecto los que ya se vencieron solo para el producto 6001(TDC), ya que se creara 
  otro proceso para los productos a plazos(sp_marcaracuerdoscumplidoscrd).
*/

DEFINE vcCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE vdFechaHoy DATE;
DEFINE vdFechaAcuerdo DATE;
DEFINE vFechaCumplimiento DATE;

DEFINE vcNumCuenta CHAR(20);
DEFINE vmSumaPagos  MONEY(16,2);
DEFINE vmSuma   MONEY(16,2);
DEFINE vmCantidadAcordada   DECIMAL(14,2);
DEFINE vcEsTransaccion  CHAR(1);
DEFINE vOrigen SMALLINT;
DEFINE vProceso CHAR(30);
DEFINE cMensaje CHAR(80);
DEFINE vMensaje CHAR(150);
DEFINE isam_err INTEGER;
DEFINE error_info CHAR(80);
DEFINE vdia DATE;
DEFINE vHora CHAR(8);
DEFINE vmaxkeyx INTEGER;
DEFINE vPlazo char(2);
DEFINE vlFlagPago char(1);
DEFINE vHorainsert DATETIME HOUR to FRACTION(3);
DEFINE vCuentaPagosProg  SMALLINT;
DEFINE vPagoProgramado char(1);
DEFINE cuentas_procesar INTEGER;
DEFINE cuentas_cumplio INTEGER;
DEFINE cuentas_nocumplido INTEGER;
DEFINE dFecha_promesarota  DATE;
DEFINE dFecha_cifrado DATE;
DEFINE iCuenta_creds smallint;
define dtFechaIni       date; ---- Evaluación Objetiva
define dtFechaFin       date;
define iCteAsisteSuc    integer;
define cOrigen          char(10);
define pSucursalOrig    char(4);
define psucursal        char(4);
define pfechasistema    date;
define pefectuo_compac  integer;
define pnombre_efectuo  char(40);
define pnumcuenta       char(20);
define pnumproducto		char(4); 
define pplazo           char(2);
define porigen	        smallint;
define ptipo_compac     char(1);
define pimporte         decimal(18,2);
define dImp_pagado      decimal(18,2);
define cBorra_conv      char(1);
define dFecha_cumpl_max date;
 
LET viSqlErr = 0;
LET vOrigen = 4;
LET vProceso = 'MAC';
LET cMensaje = 'PROCESO EXITOSO';
LET isam_err = 0;
LET error_info = '';
LET vdFechaAcuerdo = '01/01/1900';
LET vdFechaHoy = CURRENT::DATE;
LET vcCodRet = '00000';
LET vcNumCuenta = '';
LET vmSumaPagos = 0.00;
LET vmCantidadAcordada = 0.00;
LET vmSuma = 0.00;
LET vcEsTransaccion = 'N';
LET vmaxkeyx = 0;
LET vPlazo = '';
LET vlFlagPago = '0';
LET vHorainsert = CURRENT;
LET vFechaCumplimiento = '01/01/1900';
LET vCuentaPagosProg = 0;
LET vPagoProgramado = '';
LET cuentas_procesar = 0;
LET cuentas_cumplio = 0;
LET cuentas_nocumplido = 0;
LET vMensaje = '';
LET dFecha_promesarota = date(1);
LET dFecha_cifrado = date(1);
let iCuenta_creds = 0;
let dtFechaIni       = date(1); ---- Evaluación Objetiva
let dtFechaFin       = date(1);
let iCteAsisteSuc    = 0;
let cOrigen          = '';
let pSucursalOrig    = '';
let psucursal        = ''; 
let pfechasistema    = date(1); 
let pefectuo_compac  = 0;
let pnombre_efectuo  = '';
let pnumcuenta       = '';
let pnumproducto     = '';
let pplazo           = '';
let porigen          = 0;
let ptipo_compac     = '';
let pimporte         = 0;  
let dImp_pagado      = 0;
let cBorra_conv      = '';
let dFecha_cumpl_max = date(1);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN    
	ON EXCEPTION SET viSqlErr, isam_err, error_info
		LET vcCodret = viSqlErr;
		LET cMensaje = error_info;
		CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodRet, cMensaje, '02');
		RETURN vcCodRet;            
	END EXCEPTION;

   --SET DEBUG FILE TO "/ifxsif01/macf/sp_marcaracuerdoscumplidos.trc";
   --TRACE ON;

    CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodret, cMensaje, '01');

	IF pEmpresa IS NULL OR pEmpresa = "" THEN
		LET vcCodRet = '00001';
		LET viSqlErr = '00001';
		LET cMensaje = 'FALTA PARAMETRO EMPRESA';
	ELSE
		IF pTipo = "0" OR pTipo = "" THEN
			SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)} fecha_hoy, pri_dia_mes, ult_dia_mes
			INTO vdFechaHoy, dtFechaIni, dtFechaFin
			FROM bdinteg:si_fechas
			WHERE empresa = pEmpresa;
		ELSE
			IF pFecha IS NULL OR pFecha = "" THEN
				LET vcCodRet = '00002';      --CÓDIGO DE ERROR PARÁMETRO INCORRECTO
				LET viSqlErr = '00002';
				LET cMensaje = 'FALTA PARAMETRO FECHA';
			ELSE
				LET vdFechaHoy = pFecha;
			END IF;
		END IF;

		
		IF vcCodRet = '00000' THEN
	--        BEGIN WORK;
			LET vcEsTransaccion = 'S';

			--let dFecha_cumpl_max = date(vdFechaHoy + 28 units day);
			
			FOREACH WITH HOLD
			    -- Obtener también el campo imp_pagado
				SELECT {+INDEX(bdicobranza:cb_compac idx_compac3)} a.numcuenta, a.importe, a.fecha_compac, a.plazo, a.hora_insert, a.imp_pagado
				INTO vcNumCuenta, vmCantidadAcordada, vdFechaAcuerdo, vPlazo, vHorainsert, dImp_pagado 
				FROM BDICOBRANZA:CB_COMPAC a
				     INNER JOIN bdicred:sd_maecred b ON (b.empresa = a.empresa AND b.num_credito = a.numcuenta)
				WHERE a.empresa = pEmpresa 
				AND ( vdFechaHoy + ( a.plazo * 7 ) ) >= a.fecha_compac
				AND a.activo = 1
				
				LET cuentas_procesar = cuentas_procesar + 1;
			   
				LET vFechaCumplimiento = vdFechaAcuerdo + (vPlazo * 7) UNITS DAY; 
				
				--A.L.L Sacamos si la fecha es inhabil para sumarle un dia
				SELECT fecha into dFecha_cifrado
				  FROM bdinteg:si_feriado 
				 WHERE pais = '001' and fecha = vFechaCumplimiento AND laborable = 'N';
				
				if NVL(dFecha_cifrado,'') <> '' and dFecha_cifrado <> mdy('01','01','1900') then
				   LET vFechaCumplimiento = vFechaCumplimiento - 1 UNITS DAY; 
				end if;
				
				--IF EXISTS (SELECT fecha FROM bdinteg:si_feriado WHERE pais = '001' and fecha = vFechaCumplimiento AND laborable = 'N') THEN
				--	LET vFechaCumplimiento = vFechaCumplimiento - 1 UNITS DAY; 
				--END IF;
				
				SELECT max(keyx)
				INTO vmaxkeyx
				FROM bdicobranza:cb_compac
				where empresa = pEmpresa and fecha_compac = vdFechaAcuerdo and numcuenta = vcNumCuenta;
				
				LET vmSumaPagos = 0.00;
				LET vmSuma = 0.00;
				
				select count(*) into iCuenta_creds
				  from cb_compac_his where numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo;
				
				if iCuenta_creds = 0 then
				--IF NOT EXISTS (select numcuenta from cb_compac_his where numcuenta = vcNumCuenta AND fecha_compac = vdFechaAcuerdo) THEN
				
					-- No importa si el convenio es del día actual
					-- SUMA DE LOS PAGOS DEL DÍA ACTUAL (sd_movdia) POR VENTANILLA, INTERNET y CHEQUES.
					--IF vdFechaAcuerdo = vdFechaHoy THEN  --EVALOBJ
						--SELECT {+INDEX(bdicred:sd_movdia mov3)} NVL(SUM(monto),0) 
						SELECT NVL(SUM(monto),0)
						INTO vmSuma 
						FROM bdicred:sd_movdia     --SOLO PRUEBAS sd_movhis
						WHERE empresa = pEmpresa AND num_credito = vcNumCuenta 
						AND fecha_mov = vdFechaHoy
						AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual where cod_fun >= '')
						AND codigo_ref = 1
						AND reversado = 'N';
						--AND hora_mov > vHorainsert;  -- No importa la hora
	  
						IF (vmSuma is null) THEN
							LET vmSuma = 0;
						END IF;
				   
						LET vmSumaPagos = vmSuma;
					/*ELSE  --EVALOBJ
						-- EVALOBJ Al parecer solo necesitaré los del día actual pq se irán acumulando en cb_compac hasta que llegue su fecha vencim.
						-- SUMA DE LOS PAGOS DE LOS DÍAS ANTERIORES (sc_movhis)  POR VENTANILLA, INTERNET y CHEQUES.
						SELECT {+INDEX(bdicred:sd_movdia mov3)} NVL(SUM(monto),0) 
						INTO vmSuma 
						FROM bdicred:sd_movdia 
						WHERE empresa = pEmpresa AND num_credito = vcNumCuenta
						AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)--in ('033', '334', '335', '336', '337')
						AND codigo_ref = 1
						AND fecha_mov > vdFechaAcuerdo   -- MACF En prod esta >, pero para lo de pp ponerlo como >=
						AND reversado = 'N';
						
						IF (vmSuma is null) THEN
							LET vmSuma = 0;
						END IF;
						
						LET vmSumaPagos = vmSuma;

						SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) 
						INTO vmSuma 
						FROM bdicred:sd_movhis
						WHERE empresa = pEmpresa and num_credito = vcNumCuenta
						and codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)--in ('033', '334', '335', '336', '337')
						and codigo_ref = 1
						and fecha_mov > vdFechaAcuerdo 
						and reversado = 'N';

						LET vmSumaPagos = vmSumaPagos + vmSuma;
						
					END IF;
			        */
					--- Esto continúa igual ya que en el rqm no hacen mención que se deba cambiar
					--- Revisar si hay registrado algún pago programado
					select {+MULTI_INDEX(bdiprog:pp_pagoprog)} count(*) INTO vCuentaPagosProg
					from bdicred:sd_tarjeta a,
					 bdiprog:pp_pagoprog b,
					 bdicred:sd_movdia c
					where a.empresa = pEmpresa
					and a.num_tarjeta = b.cuenta_destino
					and b.cve_cuenta_dest = '04' 
					and b.cve_canal = '01' 
					and b.fecha_inicio = vdFechaHoy 
					and b.fecha_fin = vdFechaHoy 
					and a.empresa = c.empresa
					and a.num_credito = c.num_credito
					and c.codigo_fun = '337'
					and c.codigo_ref = 1
					and b.importe = c.monto
					and c.num_credito = vcNumCuenta
					AND (b.fecha_fin - b.fecha_insert) = 1;

					IF vCuentaPagosProg > 0 THEN 
					   LET vPagoProgramado = 'S'; 
					ELSE 
					   LET vPagoProgramado = '';
					END IF;
                    
					--- 1.- Si fecha hoy es mayor o igual a fecha cumplimiento, es momento de evaluar el convenio  (no importa si pagó o no)
                    --IF vmSumaPagos > 0 and (vdFechaHoy  >=  vFechaCumplimiento) THEN
					IF vdFechaHoy  >=  vFechaCumplimiento THEN

					   BEGIN WORK;
					   let cBorra_conv = 'S';
					   
                       IF (dImp_pagado+vmSumaPagos >= vmCantidadAcordada and vPagoProgramado = '') THEN
					      -- Se actualiza en cb_compac el imp_pagado con dImp_pagado+vmSumaPagos y flag_pago a 1 (CUMPLIDO)
                          update bdicobranza:cb_compac set flag_pago = 1, imp_pagado = nvl(imp_pagado,0) + vmSumaPagos, pago_programado = vPagoProgramado
						      --fecha_insert = vdFechaHoy
						  where empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;
						  
						  let vlFlagPago = '1';
						  let cuentas_cumplio = cuentas_cumplio + 1;
					   ELSE 
					      -- Se actualiza en cb_compac el imp_pagado con dImp_pagado+vmSumaPagos y flag_pago a 0 (NO CUMPLIDO) 
						  update bdicobranza:cb_compac set flag_pago = 0, imp_pagado = nvl(imp_pagado,0) + vmSumaPagos, pago_programado = vPagoProgramado
						     --fecha_insert = vdFechaHoy
						  where empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;

                          let vlFlagPago = '0';
						  let cuentas_nocumplido = cuentas_nocumplido + 1;
								
						  -- RQM 09 473 Triad MACF
						  let dFecha_promesarota = vFechaCumplimiento; 
						  -- RQM 09 473 Triad MACF						  
					
					   END IF; 
					   -- y se pasa a cb_compac_his el registro
					       INSERT INTO bdicobranza:cb_compac_his(empresa, sucursal, origen, empleado_captura, numcliente, numcuenta, plazo, importe, tipo_compac, activo, flag_pago,
									  efectuo_compac, tipo_movto, nombre_efectuo,  fecha_compac, fecha_insert, keyx, quien_convenio, nom_convenio, email,
									  referenciacoppel, imp_pagado, hora_insert, pago_programado, pago_minimo)

							SELECT empresa, sucursal, origen, empleado_captura, numcliente, numcuenta, plazo, importe, tipo_compac, '0', flag_pago,
								   efectuo_compac, '', nombre_efectuo,  fecha_compac, fecha_insert, keyx, quien_convenio, nom_convenio, email,
								   referenciacoppel, nvl(imp_pagado, 0), hora_insert, pago_programado, pago_minimo
							  FROM bdicobranza:CB_COMPAC 
							 WHERE empresa = pEmpresa AND numcuenta = vcNumCuenta AND fecha_compac = vdFechaAcuerdo AND keyx = vmaxkeyx;
					    
					   -- Se actualiza la tabla de indicadores
						 UPDATE bdicred:sd_indicador_cred SET cumplio_convenio = vlFlagPago, fecha_promesa_rota = dFecha_promesarota
						  WHERE empresa = pEmpresa AND num_credito = vcNumCuenta;
							
					   -- El sistema elimina los compromisos vencidos
							DELETE FROM BDICOBRANZA:CB_COMPAC 
							WHERE empresa = pEmpresa AND numcuenta = vcNumCuenta AND fecha_compac = vdFechaAcuerdo AND keyx = vmaxkeyx;
					   
					   COMMIT WORK;
					   
					--- 1b.- Si no solo se actualizará el monto recibido, y el convenio sigue vivo en cb_compac
					ELIF  vmSumaPagos > 0 THEN 
					 BEGIN WORK;  
					   let cBorra_conv = 'N';
					   update bdicobranza:cb_compac set imp_pagado = nvl(imp_pagado,0) + vmSumaPagos, pago_programado = vPagoProgramado,
					      fecha_insert = vdFechaHoy
					    where empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;
					
					 COMMIT WORK;
					
					END IF;

				END IF;
				
		let vCuentaPagosProg = 0;
		let vPagoProgramado = '';

		END FOREACH;

		let vcEsTransaccion = 'N';
        END IF;
    END IF;
		
	LET vMensaje = 'CUENTAS PROCESADAS = '||cuentas_procesar;
	CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodret, TRIM(vMensaje), '02');
	LET vMensaje = '';
	LET vMensaje = 'CUENTAS CONVENIO CUMPLIDO = '||cuentas_cumplio;
	LET vMensaje = TRIM(vMensaje)||'  CUENTAS CONVENIO NO CUMPLIDO = '||cuentas_nocumplido;
	CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodret, TRIM(vMensaje), '02');

	--IF vcCodRet <> '00000' then

	CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vproceso, vcCodret, cMensaje, '03');

	--END IF;

	RETURN vcCodRet;
END;
END PROCEDURE;