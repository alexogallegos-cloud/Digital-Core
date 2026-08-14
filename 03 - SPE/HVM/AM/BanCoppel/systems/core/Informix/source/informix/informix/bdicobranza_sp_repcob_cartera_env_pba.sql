CREATE PROCEDURE "informix".sp_repcob_cartera_env_pba()
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;		
			
		---DECLARACIONES
		DEFINE iSqlErr				                               INTEGER;
		DEFINE iIsamErr				                               INTEGER;
		DEFINE iPagoVenc			                               INTEGER;
		DEFINE cTabla		      	                             CHAR(1);
		DEFINE cStatusCred			                             CHAR(2);
		DEFINE cCiudad, v_empresa				                     CHAR(3);
		DEFINE cProceso                                      CHAR(4);
		DEFINE cCodRet,vvcCod_ret                            CHAR(6);
		DEFINE vhora                                         CHAR(8);
		DEFINE cNumcte, cNumCredito, cNumTarjeta				     CHAR(20);
    DEFINE vHora3                                        CHAR(22);
		DEFINE vCurrent                                      CHAR(25);
    DEFINE cNombreRegion		                             CHAR(30);
		DEFINE cDescripcion			                             CHAR(50);
		DEFINE cDescripcionFinllam                           CHAR(50);
		DEFINE vcNombre				                               VARCHAR(60);
		DEFINE cMensajeRet, cNombreArchivo, cRuta			       CHAR(80);						
    DEFINE cTipoLogica			                             CHAR(100);
    DEFINE cSql          		                             CHAR(1024); 
		DEFINE cConsulta		  	                             CHAR(2200);
		   										
		DEFINE dtFechaHoy, dtFechaCorteIniCte  			         DATE;
		DEFINE dtFechaCorteFinCte, dtFechaUltPago	           DATE;
		DEFINE dtFechaMax, dtFechaMaxCart                    DATE;
		define vdia                                          DATE;
		
		DEFINE sNumVencidos, sNumPagos			                 SMALLINT;
		DEFINE sFinLlamada			                             SMALLINT;
		DEFINE sTipo_logica                                  SMALLINT;
		
		DEFINE dMoratorio, dSaldoTotal, dSdoVencidoTot		   DECIMAL(18,2);
		DEFINE dPagoMinimo, dMensActual, dPagoUnaMora 		   DECIMAL(18,2);
		DEFINE dMontoPagos			                             DECIMAL(18,2);
    DEFINE iCuenta                                       INTEGER;
    --DEFINE vHoraFinLLamada DATETIME HOUR to FRACTION(3);
    DEFINE vHoraFinLLamada DATETIME HOUR to second;
                
		---INICIALIZACIONES
		LET iSqlErr      = 0;   LET iIsamErr      = 0;    LET dMoratorio      = 0.00;   LET dSaldoTotal      = 0.00;
		LET iPagoVenc		 = 0;	  LET sNumVencidos	= 0; 		LET dSdoVencidoTot  = 0.00; 	LET dPagoMinimo			 = 0.00;
		LET dMensActual	 = 0.00;LET dPagoUnaMora  = 0.00;	LET sNumPagos			  = 0;   		LET dMontoPagos			= 0.00;
		LET sFinLlamada	 = 0;
    
    LET cCodRet      = "000000";    LET cMensajeRet      = "Proceso exitoso";  		LET v_empresa          = '001'; 		LET cProceso            = '0073';
		LET cTabla		 	 = "N";         LET cNombreArchivo 	 = "";                		LET cConsulta	         = "";  		  LET cSql		 		        = "";
 		LET cRuta		 		 =  "";		      LET dtFechaHoy       = ""; 	                  LET dtFechaCorteIniCte = "";        LET dtFechaCorteFinCte  = "";
		LET cNumcte 		 = "";  		    LET cNumCredito			 = ""; 		                LET cNumTarjeta			   = "";        LET cDescripcion		    = ""; 
		LET cStatusCred	 = ""; 		      LET dtFechaUltPago	 = "";  		              LET cCiudad				     = "";        LET cNombreRegion		    = "";      
		LET vcNombre		 = "";		      LET cTipoLogica			 = "";                    LET vvcCod_ret         = '';        LET vdia                = '';  
		LET vhora        = '';          LET vCurrent         = '';                    LET vHora3             = '';        LET cDescripcionFinllam = '';   
    LET dtFechaMax   = date(1);     LET dtFechaMaxCart   = date(1);               LET iCuenta            = 0;         LET sTipo_logica        = 0;
    LET vHoraFinLLamada = CURRENT;
    	
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;	
				LET cMensajeRet = TRIM(cMensajeRet) || '--> ' || cNumcte || cNumCredito;			  				
     			
			 RETURN cCodRet, cMensajeRet;
				
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		--SET DEBUG FILE TO "/informix/macf/sp_repcob_cartera_env.trc";
		--TRACE ON;
		 
		--DETERMINACION DE FECHA CORTE:
		SELECT fecha_hoy   INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = v_empresa;
		
		SELECT max(fecha_insert) INTO dtFechaMax 
               FROM bdicobranza:"informix".cb_cat_directorio_cte
               WHERE tipo_cobranza = 'A';
    
    SELECT max(date(fechacartera)) INTO dtFechaMaxCart
		   FROM bdicobranza:"informix".cb_cat_movimientos
		   WHERE tipocobranza = 'A';  
		
   
    TRUNCATE bdicobranza:cb_encabezadosexcelenviada; 
    			 					
		--SE AGREGA ENCABEZADO AL REPORTE PARA EL ARCHIVO EXCEL.
		INSERT INTO bdicobranza:"informix".cb_encabezadosexcelenviada (NumeroCliente,NumeroCredito,NumeroTarjeta,InteresMoratorio,SdoTotalLiquidacion,SdoVencidoTotal,PagoMinimo,MensualidadActual,NumVencidosInicial,NumVencidosFinal,StatusCred,FechaUltPago,PagoUnaMora,Ciudad,Descripcion,Region,LogicaCampana,NumPagos,MontoPagos,ResultGestion,NombreGestion)
		VALUES("No. De cliente","No. De credito","No. Tarjeta","Int. Moratorio","Sdo. Tot. Liquidacion","Sdo. Vencido Tot.","Pago min.","Mens. Actual","No. Vencidos inicial","No. Vencidos final","Status cred.","Fech. Ult Pago","Pago 1 mora","Ciudad","Descripcion","Region","Logica o campana","No. Pagos","Monto pagos","Resultado de gestion","Nombre de gestion");		
	
		SELECT empresa,
           numcte,
           num_credito, 
           SUM(NVL(moratorio,0.00)) AS IntMoratorio,
           SUM(NVL(saldo_total,0.00)) AS SdoTotLiqui,
			     SUM(NVL(NVL(monto_vencido,0.00) + NVL(mto_venc_trasp,0.00) + NVL(moratorio,0.00) + NVL(interes_iva,0.00),0.00)) AS SdoVencidoTot,
				   SUM(NVL(pago_minimo,0.00)) AS PagMinimo,
				   SUM(NVL((NVL(pago_minimo,0.00) + NVL(mto_venc_trasp,0.00) + NVL(moratorio,0.00)),0.00)) AS MensActual,
				   SUM(NVL(pago_venc,0)) AS NumVencIni,
           NVL(fecha_ult_pago,"") AS FechUltPag,
           SUM(NVL(pago_una_mora,0.00)) AS Pago1Mora,
           SUM(NVL(num_pagos,0)) AS NumPagos,
           SUM(NVL(monto_pagos,0)) AS MontosPag,
           NVL(ciudad,"") AS Ciudad,
           NVL(tipo_logica,0) tipo_logica, NVL(codigo_resultado,0) codigo_resultado
      FROM bdicobranza:cb_cat_directorio_cte 
      WHERE tipo_cobranza = "A"    
        AND fecha_insert >= dtFechaMax
        AND status_cliente <> "NT" AND status_cliente <> "TE"
        AND tipo_logica = 2                --- TEST MACF  49,814
      GROUP BY empresa, numcte, num_credito, fecha_ult_pago, ciudad, tipo_logica, codigo_resultado, tipo_cobranza
			 INTO TEMP paso_catdir WITH NO LOG;

      begin;
      CREATE INDEX idx_paso_catdir ON paso_catdir (numcte, num_credito) ONLINE;
      commit;

      begin;
      CREATE INDEX idx_paso_catdir2 ON paso_catdir (tipo_logica) ONLINE;
      commit;

      begin;
      CREATE INDEX idx_paso_catdir3 ON paso_catdir (codigo_resultado) ONLINE;
      commit;

      UPDATE statistics HIGH FOR TABLE "informix".paso_catdir;    

		--SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora3 from sysmaster:sysshmvals;
    --INSERT INTO bdicobranza:cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
    --VALUES(v_empresa, cProceso, today, '000000', 'Termina creación de tabla temporal paso_catdir', 'informix', vdia, vHora3);
		
		FOREACH WITH HOLD
		 			SELECT NVL(a.numcte,""),  NVL(a.num_credito,""), a.intmoratorio,
                 a.sdototliqui, a.sdovencidotot, a.pagminimo, a.mensactual, a.numvencini,  
                 a.fechultpag, a.pago1mora, a.ciudad, NVL(e.descripcion,""), a.numpagos,
                 a.montospag, NVL(g.descripcion,""), a.tipo_logica				   
    			INTO cNumcte, cNumCredito, dMoratorio, dSaldoTotal, dSdoVencidoTot, dPagoMinimo, dMensActual,iPagoVenc, dtFechaUltPago, dPagoUnaMora,
               cCiudad, cTipoLogica, sNumPagos, dMontoPagos, cDescripcion, sTipo_logica				 				 
    			FROM "informix".paso_catdir a
		            LEFT OUTER JOIN bdicobranza:cb_param_campania e ON(e.valor_numerico = a.tipo_logica and e.grupo_parametro = 'LOGICA')
		            LEFT OUTER JOIN bdicobranza:cb_cat_tipo_resultado g	ON (g.codigo_resultado = a.codigo_resultado)
		      /*      
    			SELECT NVL(a.numcte,"") AS NumDeCliente, NVL(a.num_credito,"") AS NumDeCredito, NVL(c.num_tarjeta,"") AS NumTarjeta, a.intmoratorio AS IntMoratorio,
                 a.sdototliqui AS SdoTotLiqui, a.sdovencidotot, a.pagminimo AS PagMinimo,
    				     a.mensactual AS MensActual, a.numvencini AS NumVencIni, NVL(d.num_vencidos,0) AS NumVencFin, NVL(b.status_cred,"") AS StatusCred, 
                 a.fechultpag AS FechUltPag, a.pago1mora AS Pago1Mora, a.ciudad AS Ciudad, NVL(e.descripcion,"") AS LogicaCampana, a.numpagos AS NumPagos,
                 a.montospag AS MontosPag, NVL(g.descripcion,"") AS NombreGestion				   
    			INTO cNumcte,cNumCredito,cNumTarjeta,dMoratorio,dSaldoTotal,dSdoVencidoTot,dPagoMinimo,dMensActual,iPagoVenc,sNumVencidos,cStatusCred,dtFechaUltPago,
    			 	   dPagoUnaMora,cCiudad,cTipoLogica,sNumPagos,dMontoPagos,cDescripcion  --sFinLlamada,cDescripcion				 				 
    			FROM "informix".paso_catdir a
    				LEFT OUTER JOIN bdicred:"informix".sd_maecred b ON( b.num_credito = a.num_credito)
    				INNER join bdicred:sd_tarjeta c on a.empresa = c.empresa and a.num_credito = c.num_credito and c.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where a.empresa = empresa AND a.num_credito = num_credito and tipo_tarjeta = 'T' AND status_tar = 'A')
    				LEFT OUTER JOIN bdicred:"informix".sd_indicador_cred d ON(d.num_credito = a.num_credito)			
    				LEFT OUTER JOIN bdicobranza:"informix".cb_param_campania e ON(e.valor_numerico = a.tipo_logica)
    				LEFT OUTER JOIN  bdicobranza:"informix".cb_cat_movimientos f ON( LPAD(TRIM(f.cliente),9,"0") = a.numcte )
    				LEFT OUTER JOIN bdicobranza:"informix".cb_cat_tipo_resultado g	ON (g.codigo_resultado = a.codigo_resultado)
    			WHERE b.num_producto = "6001" 
    				AND b.num_producto = c.prodtarjeta
    				AND e.grupo_parametro = "LOGICA"
    				AND f.tipologica = a.tipo_logica
    				AND f.tipocobranza = "A"
    				AND date(f.fechacartera) >= dtFechaMaxCart
          */
          
          SELECT LIMIT 1 nvl(m.finllamada,0) as finllamada, nvl(c.descripcion,'') as descripcion,
                   (SELECT MAX(horafinllamada) FROM bdicobranza:cb_cat_movimientos WHERE cvemovimiento = m.cvemovimiento AND cliente = m.cliente 
                                                AND tipologica = m.tipologica AND tipocobranza = m.tipocobranza
                                                AND date(fechacartera) = date(m.fechacartera) ) AS HoraFinLLamada  
              INTO sFinLlamada, cDescripcionFinllam, vHoraFinLLamada
              FROM bdicobranza:cb_cat_movimientos m, 
                   bdicobranza:cb_cat_tipo_resultado c
             WHERE m.cvemovimiento = 'L' 
               --AND m.cliente = cNumcte  -- no coincide porque m.cliente no tiene ceros a la izq.
               AND m.tienda = cNumCredito 
               AND m.tipologica = sTipo_logica 
               AND m.tipocobranza = 'A'
               /*AND m.horafinllamada = (SELECT MAX(horafinllamada) 
                                         FROM bdicobranza:cb_cat_movimientos 
                                        WHERE cvemovimiento = m.cvemovimiento 
                                          AND cliente = m.cliente 
                                          AND tipologica = m.tipologica
                                          AND tipocobranza = m.tipocobranza
                                          --AND horafinllamada = horafinllamada
                                          AND date(fechacartera) = date(m.fechacartera) --dtFechaMaxCart
                                             
               )*/ 
               AND date(m.fechacartera) = dtFechaMaxCart
               AND m.finllamada = c.codigo_resultado;
               
               IF nvl(sFinLlamada,'') = '' THEN continue foreach; END IF;  
          
          --SELECT NVL(num_tarjeta,"") INTO cNumTarjeta 
          SELECT LIMIT 1 NVL(num_tarjeta,""), m.status_cred INTO cNumTarjeta, cStatusCred 
    			  FROM bdicred:sd_tarjeta a, bdicred:sd_maecred m 
    			 WHERE a.empresa = v_empresa
             AND a.empresa = m.empresa  
             AND a.num_credito = cNumCredito
             AND a.num_credito = m.num_credito
             AND a.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
                                 where empresa = a.empresa AND num_credito = a.num_credito and tipo_tarjeta = 'T' AND status_tar = 'A'); 
			
			    SELECT NVL(num_vencidos,0) INTO sNumVencidos 
            FROM bdicred:sd_indicador_cred 
           WHERE empresa = v_empresa
             AND num_credito = cNumCredito;
			
      			--SELECT LIMIT 1 nvl(m.finllamada,0) finllamada, nvl(c.descripcion,'') descripcion INTO sFinLlamada, cDescripcion   -- NEW BY MACF
            --  FROM bdicobranza:cb_cat_movimientos m, 
            --       bdicobranza:cb_cat_tipo_resultado c 
            -- WHERE date(m.fechacartera) = dtFechaMaxCart 
            --   AND m.tienda = cNumCredito 
            --   AND m.cvemovimiento = 'L'
            --   AND m.horafinllamada = (SELECT MAX(horafinllamada) FROM bdicobranza:cb_cat_movimientos 
            --                            WHERE date(fechacartera) = dtFechaMaxCart 
            --                              AND tienda = cNumCredito and cvemovimiento = 'L')
            --   AND c.codigo_resultado = m.finllamada ; 
            
            --- modif 2013/07/05   
            
			
      			SELECT LIMIT 1 NVL(b.nombre,"") AS NombreCiudad,NVL(c.nombre_region,"") AS NombreRegion  
      			INTO vcNombre,cNombreRegion
      			FROM bdinteg:"informix".si_catciudades a
      				               LEFT OUTER JOIN bdinteg:"informix".si_ciudades b ON(b.ciudad_coppel::INT = a.numerociudad) 	
      				               LEFT OUTER JOIN bdinteg:"informix".si_regiones c ON(c.numero_region	= a.regioncobranzas)
      			WHERE a.numerociudad = cCiudad::INT;
			
      			BEGIN WORK;
              --SE INSERTA TODA LA INFORMACION EN LA TABLA FINAL.
        			INSERT INTO bdicobranza:"informix".cb_encabezadosexcelenviada (NumeroCliente, NumeroCredito, NumeroTarjeta, InteresMoratorio, SdoTotalLiquidacion,
                         SdoVencidoTotal, PagoMinimo, MensualidadActual, NumVencidosInicial, NumVencidosFinal, StatusCred, FechaUltPago, PagoUnaMora, Ciudad,
                         Descripcion, Region, LogicaCampana, NumPagos, MontoPagos, ResultGestion, NombreGestion)
        			--VALUES(cNumcte,cNumCredito,cNumTarjeta,dMoratorio,dSaldoTotal,dSdoVencidoTot,dPagoMinimo,dMensActual,iPagoVenc,sNumVencidos,cStatusCred,dtFechaUltPago,dPagoUnaMora,cCiudad,vcNombre,cNombreRegion,cTipoLogica,sNumPagos,dMontoPagos,sFinLlamada,cDescripcion);
        		  VALUES( "'" || lpad(TRIM(cNumcte),9,'000000000'), cNumCredito, cNumTarjeta, dMoratorio, dSaldoTotal, dSdoVencidoTot, dPagoMinimo, dMensActual,
                     iPagoVenc, sNumVencidos, cStatusCred, dtFechaUltPago, dPagoUnaMora, cCiudad, vcNombre, cNombreRegion, cTipoLogica, sNumPagos, dMontoPagos, 
                     sFinLlamada,cDescripcionFinllam);
            COMMIT WORK;
    
            		  
		END FOREACH
						
		--SE OBTIENE EL NOMBRE DEL ARCHIVO.
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = 73;	

		--SE OBTINE LA RUTA DONDE SE GENERARÁ EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
			AND grupo_parametro = "RUTAS" 
			AND num_parametro = 1;

-- COMENTAR QUE SE GENERE EL ARCHIVO PARA QUE SE GUARDE TODO EN LA TABLA cb_encabezadosexcelenviada Y VER QUE CANT. DE REGS. GENERA
			
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0); 
		-- lpad(trim(NumeroCliente),9,'00000000')
		LET cConsulta = "SELECT NumeroCliente,NumeroCredito,NumeroTarjeta,InteresMoratorio,SdoTotalLiquidacion,SdoVencidoTotal,PagoMinimo,MensualidadActual,NumVencidosInicial,NumVencidosFinal,StatusCred,FechaUltPago,PagoUnaMora,Ciudad,Descripcion,Region,LogicaCampana,NumPagos,MontoPagos,ResultGestion,NombreGestion FROM bdicobranza:'informix'.cb_encabezadosexcelenviada";		
    
    LET cSql = '';
		LET cSql = 'echo "set isolation to dirty read; UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		--IF cTabla="S" THEN
		--		DROP TABLE bdicobranza:"informix".cb_encabezadosexcelenviada;
		--END IF;
		
    LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';					
		
    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;  --TEST
    		
		RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el Resultado de cartera enviada.', 
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121106.0842',
'Fecha: 2013/10/25. Autor:MACF. Desc.:Tabla fija y dividir queries para optimizar.';

CREATE FUNCTION "informix".convert_to_date(dt int8)
RETURNING datetime year to second
WITH (NOT VARIANT)
define d_return date;

ON EXCEPTION
    begin
        let d_return = today + 1 units day;
        return d_return;
    end
end exception

let d_return = to_date(to_char(dt),"%Y%m%d%H%M%S");
return d_return;
END FUNCTION;

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