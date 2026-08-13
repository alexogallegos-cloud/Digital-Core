CREATE PROCEDURE "informix".sp_repcob_cat_bncpl()
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;		
			
		---DECLARACIONES
		DEFINE iSqlErr				      INTEGER;
		DEFINE iIsamErr				      INTEGER;
		DEFINE cTabla		      	    CHAR(1);
    DEFINE v_empresa            CHAR(3);
		DEFINE cProceso             CHAR(4);
		DEFINE cCodRet,vvcCod_ret		CHAR(6);
		DEFINE cMensajeRet, cNombreArchivo, cRuta			    CHAR(80);		
		DEFINE sMaxMora, sMora, sCiclo               			SMALLINT;
		DEFINE cConsulta		  	    CHAR(2200);
		DEFINE cSql           		  CHAR(1024);
		DEFINE dVolumenCtes, dPagMinPagPer, dPendMesAnt, dInteresesPer, dInteresesMor, dPagMinReqTotPag			        DECIMAL(18,2);
		DEFINE dSaldoTot, dVolumenCtesTot, dPagMinPagPerTot, dPendMesAntTot, dInteresesPerTot, dInteresesMorTot			DECIMAL(18,2);
		DEFINE dPagMinReqTotPagTot, dSaldoTotTot	                                                                  DECIMAL(18,2);
		DEFINE iBandera				      INTEGER;	
		DEFINE dtFechaHoy, dtFechaHist, dtFechaCorteIniCte, dtFechaCorteFinCte, dtFechaMax			                    DATE;		
	
    	
		---INICIALIZACIONES
		LET iSqlErr  = 0;   LET iIsamErr = 0;   		LET sMaxMora 			= 0;
		LET sCiclo	 = 0;   LET sMora		 = 0;		    LET iBandera		 	= 0; 
		LET cCodRet   = "000000";
		LET cMensajeRet	= "Proceso exitoso";
		LET cNombreArchivo 	= "";   LET cConsulta		= "";    LET cSql	= "";    		  LET cTabla	= "N";
		LET cRuta		 		= "";   		LET dtFechaHoy  = "";		 LET dtFechaHist = "";	LET dtFechaCorteIniCte  = "";				
		LET dtFechaCorteFinCte  = "";
		LET dVolumenCtes		= 0.00;		LET dPagMinPagPer		= 0.00;		LET dPendMesAnt	 		= 0.00;
		LET dInteresesPer	 	= 0.00;		LET dInteresesMor	 	= 0.00;		LET dPagMinReqTotPag	= 0.00;
		LET dSaldoTot	 		= 0.00;			LET dVolumenCtesTot	= 0.00;		LET dPagMinPagPerTot	= 0.00;
		LET dPendMesAntTot	 	= 0.00;	LET dInteresesPerTot	= 0.00;	LET dInteresesMorTot	= 0.00;
		LET dPagMinReqTotPagTot	= 0.00;		LET dSaldoTotTot	= 0.00;		
		LET v_empresa = '001';
		LET cProceso = '0072';
    LET vvcCod_ret = '';
    LET dtFechaMax = date(1);
    		
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;	
				LET cMensajeRet = cMensajeRet;
			  
				--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallecarteraenviada" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
					DROP  TABLE tmp_detallecarteraenviada;
				END IF;								
												
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallecarteraenviada2" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
					DROP  TABLE tmp_detallecarteraenviada2;
				END IF;
				
				IF cTabla="S" THEN
					DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELDETALLE;
				END IF;
				
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
        RETURNING vvcCod_ret;
        		
			RETURN cCodRet, cMensajeRet;
				
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_repcob_cat_bncpl.out";
		--TRACE ON;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
     
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallecarteraenviada" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP  TABLE tmp_detallecarteraenviada;
		END IF;								
										
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallecarteraenviada2" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP  TABLE tmp_detallecarteraenviada2;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "TMP_ENCABEZADOSEXCELDETALLE" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP  TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELDETALLE;
		END IF;
		
		--DETERMINACION DE FECHA CORTE:
		SELECT fecha_hoy
		  INTO dtFechaHoy
		  FROM bdicred:"informix".sd_fechas
     WHERE empresa = v_empresa;
							
		--LET dtFechaHoy = mdy('11','22','2012');    ----TEST MACF
		
		SELECT max(fecha_insert) INTO dtFechaMax 
      FROM bdicobranza:"informix".cb_cat_directorio_cte
     WHERE tipo_cobranza = 'A';
		
						
		--SE OBTIENE LA MAXIMA MORA.	
		SELECT total
		INTO sMaxMora
		FROM TABLE(MULTISET(
							SELECT LIMIT 1 MAX(NVL(b.mto_fin_ven_trasp::INT,0)) AS total							
							FROM bdicobranza:"informix".cb_cat_directorio_cte a
								LEFT OUTER JOIN bdicred:"informix".sd_maesdoshist b ON (b.num_credito = a.num_credito)
							--WHERE a.fecha_insert >= dtFechaCorteIniCte AND a.fecha_insert <= dtFechaCorteFinCte
							  WHERE a.fecha_insert = dtFechaMax
								AND b.fecha = dtFechaHist
								AND b.mto_fin_ven_trasp::INT > 0  
							GROUP BY a.numcte
							ORDER BY total DESC
							));
		--SE VALIDA SI EXISTEN MORAS.
		IF NVL(sMaxMora,0) = 0 THEN 
			LET cCodRet = '000001';
			LET cMensajeRet = 'Por el momento no existen moras';
			--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallecarteraenviada" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
				DROP  TABLE tmp_detallecarteraenviada;
			END IF;								
											
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallecarteraenviada2" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
				DROP  TABLE tmp_detallecarteraenviada2;
			END IF;
			
			-- Si no existen moras lo registra en la bitácora pero termina normal.
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
        RETURNING vvcCod_ret;
			
      LET cCodRet = "000000";
			LET cMensajeRet	= "Proceso exitoso";
			
			RETURN cCodRet, cMensajeRet;
		END IF;
				
		--SE OBTIENE EL TOTAL DE MORAS POR CREDITO.		
		SELECT NVL(b.mto_fin_ven_trasp::INT,0) AS total,NVL(a.numcte,"") AS numcte,NVL(a.num_credito,"") AS num_credito,SUM(NVL(b.monto_financiado,0.00)) AS monto_financiado,SUM(NVL(b.monto_vencido,0.00)) AS monto_vencido, 
			   SUM(NVL(b.sdo_retenido,0.00)) AS sdo_retenido,SUM(NVL(b.mto_venc_trasp,0.00)) AS mto_venc_trasp, SUM(NVL(b.sdo_intereses,0.00)) AS sdo_intereses,SUM(NVL(b.sdo_cap_insoluto,0.00)) AS sdo_cap_insoluto,
			   estado AS estado,ciudad AS ciudad
		FROM bdicobranza:"informix".cb_cat_directorio_cte a
		    LEFT OUTER JOIN bdicred:"informix".sd_maesdoshist b ON(b.num_credito = a.num_credito)
		WHERE b.mto_fin_ven_trasp::INT > 0
			--AND a.fecha_insert >= dtFechaCorteIniCte AND a.fecha_insert <= dtFechaCorteFinCte
			AND a.fecha_insert = dtFechaMax
			AND b.fecha = dtFechaHist
		GROUP BY 1,a.numcte ,a.num_credito,estado,ciudad
		ORDER BY total ASC
		INTO TEMP tmp_detallecarteraenviada WITH NO LOG;	 
																
		FOR sCiclo = 1 TO sMaxMora				
			IF iBandera = 0 THEN 				
				--SE OBTIENE EL TOTALIZADO POR MORA Y SE CREA LA TEMPORAL PARA GUARDAR LA INFORMACION.							
				SELECT Mora,COUNT(VolumenCtes) AS VolumenCtes,SUM(PagMinPagPer) AS PagMinPagPer,SUM(PendMesAnt) AS PendMesAnt,SUM(InteresesPer) AS InteresesPer,SUM(InteresesMor) AS InteresesMor,SUM(PagMinReqTotPag) AS PagMinReqTotPag,SUM(SaldoTot) AS SaldoTot
				FROM TABLE(MULTISET(SELECT sCiclo AS Mora,
										NVL(a.numcte,"") AS VolumenCtes,
										NVL(SUM(NVL(a.monto_financiado,0) + (NVL(b.interes_debe,0) - NVL(b.interes_pagado,0)) + (NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0) + NVL(b.mora_sdo_ordi,0) - NVL(b.mora_sdo_ordi_pag,0) +
											NVL(b.mora_sdo_cope,0) - NVL(b.mora_sdo_cope_pag,0)) + (NVL(b.iva_debe,0) - NVL(b.iva_pagado,0)) + (NVL(b.mora_iva_debe,0) + NVL(b.mora_iva_pagado,0) + NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0)) * NVL(c.iva,0)),0) AS PagMinPagPer,											
										NVL(SUM(NVL(a.monto_vencido,0) + NVL(a.mto_venc_trasp,0)),0) AS PendMesAnt,										
										NVL(SUM(NVL(a.sdo_intereses,0) * 1 + NVL(c.iva,0)),0) AS InteresesPer,										
										NVL(SUM(NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0) + NVL(b.mora_sdo_ordi,0) - NVL(b.mora_sdo_ordi_pag,0) + NVL(b.mora_sdo_cope,0) - NVL(b.mora_sdo_cope_pag,0)),0) AS InteresesMor,										
										NVL(SUM(NVL(a.monto_financiado,0) + (NVL(b.interes_debe,0) - NVL(b.interes_pagado,0)) + (NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0) + NVL(b.mora_sdo_ordi,0) - NVL(b.mora_sdo_ordi_pag,0) +
											NVL(b.mora_sdo_cope,0) - NVL(b.mora_sdo_cope_pag,0)) + (NVL(b.iva_debe,0) - NVL(b.iva_pagado,0)) + (NVL(b.mora_iva_debe,0) + NVL(b.mora_iva_pagado,0) + NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0)) * NVL(c.iva,0)) +
											SUM(NVL(a.monto_vencido,0) + NVL(a.mto_venc_trasp,0)) +
											SUM(NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0) + NVL(b.mora_sdo_ordi,0) - NVL(b.mora_sdo_ordi_pag,0) + NVL(b.mora_sdo_cope,0) - NVL(b.mora_sdo_cope_pag,0)),0) AS PagMinReqTotPag,																														
										NVL(SUM((NVL(a.sdo_cap_insoluto,0) + NVL(b.interes_debe,0) - NVL(b.interes_pagado,0) + NVL(b.iva_debe,0) - NVL(b.iva_pagado,0) + NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0) + NVL(b.mora_sdo_ordi,0) - NVL(b.mora_sdo_ordi_pag,0) +
											NVL(b.mora_sdo_cope,0) - NVL(b.mora_sdo_cope_pag,0)) + (NVL(b.mora_iva_debe,0) - NVL(b.mora_iva_pagado,0) + NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0)) * NVL(c.iva,0) + NVL(a.sdo_retenido,0)),0) AS SaldoTot
								FROM tmp_detallecarteraenviada a
									 LEFT OUTER JOIN bdicred:"informix".sd_amortiza_credito b ON(b.num_credito = a.num_credito)	
									 LEFT OUTER JOIN bdinteg:"informix".si_sucursales c ON(c.estado = a.estado AND c.ciudad = a.ciudad)
									 LEFT OUTER JOIN bdicred:"informix".sd_maecred d ON(d.num_credito = a.num_credito AND d.sucursal = c.sucursal)									 
								WHERE a.total = sCiclo																							
									AND b.capital_status IN(2,7,6)									
								GROUP BY 1,a.numcte
						))
				GROUP BY 1
				INTO TEMP tmp_detallecarteraenviada2 WITH NO LOG;					
				LET iBandera = 1;	
								
			ELSE
				--SE OBTIENE EL TOTALIZADO POR MORA.												
				INSERT INTO tmp_detallecarteraenviada2			
				SELECT Mora,COUNT(VolumenCtes) AS VolumenCtes,SUM(PagMinPagPer) AS PagMinPagPer,SUM(PendMesAnt) AS PendMesAnt,SUM(InteresesPer) AS InteresesPer,SUM(InteresesMor) AS InteresesMor,SUM(PagMinReqTotPag) AS PagMinReqTotPag,SUM(SaldoTot) AS SaldoTot
				FROM TABLE(MULTISET(SELECT sCiclo AS Mora,
										NVL(a.numcte,"") AS VolumenCtes,
										NVL(SUM(NVL(a.monto_financiado,0) + (NVL(b.interes_debe,0) - NVL(b.interes_pagado,0)) + (NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0) + NVL(b.mora_sdo_ordi,0) - NVL(b.mora_sdo_ordi_pag,0) +
											NVL(b.mora_sdo_cope,0) - NVL(b.mora_sdo_cope_pag,0)) + (NVL(b.iva_debe,0) - NVL(b.iva_pagado,0)) + (NVL(b.mora_iva_debe,0) + NVL(b.mora_iva_pagado,0) + NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0)) * NVL(c.iva,0)),0) AS PagMinPagPer,											
										NVL(SUM(NVL(a.monto_vencido,0) + NVL(a.mto_venc_trasp,0)),0) AS PendMesAnt,										
										NVL(SUM(NVL(a.sdo_intereses,0) * 1 + NVL(c.iva,0)),0) AS InteresesPer,										
										NVL(SUM(NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0) + NVL(b.mora_sdo_ordi,0) - NVL(b.mora_sdo_ordi_pag,0) + NVL(b.mora_sdo_cope,0) - NVL(b.mora_sdo_cope_pag,0)),0) AS InteresesMor,										
										NVL(SUM(NVL(a.monto_financiado,0) + (NVL(b.interes_debe,0) - NVL(b.interes_pagado,0)) + (NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0) + NVL(b.mora_sdo_ordi,0) - NVL(b.mora_sdo_ordi_pag,0) +
											NVL(b.mora_sdo_cope,0) - NVL(b.mora_sdo_cope_pag,0)) + (NVL(b.iva_debe,0) - NVL(b.iva_pagado,0)) + (NVL(b.mora_iva_debe,0) + NVL(b.mora_iva_pagado,0) + NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0)) * NVL(c.iva,0)) +
											SUM(NVL(a.monto_vencido,0) + NVL(a.mto_venc_trasp,0)) +
											SUM(NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0) + NVL(b.mora_sdo_ordi,0) - NVL(b.mora_sdo_ordi_pag,0) + NVL(b.mora_sdo_cope,0) - NVL(b.mora_sdo_cope_pag,0)),0) AS PagMinReqTotPag,																														
										NVL(SUM((NVL(a.sdo_cap_insoluto,0) + NVL(b.interes_debe,0) - NVL(b.interes_pagado,0) + NVL(b.iva_debe,0) - NVL(b.iva_pagado,0) + NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0) + NVL(b.mora_sdo_ordi,0) - NVL(b.mora_sdo_ordi_pag,0) +
											NVL(b.mora_sdo_cope,0) - NVL(b.mora_sdo_cope_pag,0)) + (NVL(b.mora_iva_debe,0) - NVL(b.mora_iva_pagado,0) + NVL(b.mora_provi_ordi,0) + NVL(b.mora_provi_cope,0)) * NVL(c.iva,0) + NVL(a.sdo_retenido,0)),0) AS SaldoTot
								FROM tmp_detallecarteraenviada a
									 LEFT OUTER JOIN bdicred:"informix".sd_amortiza_credito b ON(b.num_credito = a.num_credito)	
									 LEFT OUTER JOIN bdinteg:"informix".si_sucursales c ON(c.estado = a.estado AND c.ciudad = a.ciudad)
									 LEFT OUTER JOIN bdicred:"informix".sd_maecred d ON(d.num_credito = a.num_credito AND d.sucursal = c.sucursal)									 
								WHERE a.total = sCiclo																							
									AND b.capital_status IN(2,7,6)									
								GROUP BY 1,a.numcte
						))
				GROUP BY 1;
			END IF  
		END FOR		
		
		--SE CREA LA TEMPORAL PARA INSERTAR LOS ENCABEZADOS QUE LLEVARA EL REPORTE.
		CREATE TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELDETALLE(
																			Mora 			CHAR(10),
																			VolumenClientes CHAR(80),
																			PagMinPagPrd 	CHAR(80),
																			PenMesAnt 		CHAR(80),
																			IntPrd 			CHAR(80),
																			IntMort 		CHAR(80),
																			PagMinReqTotPag	CHAR(80),
																			SdoTot		 	CHAR(80)
																		);			
		LET cTabla="S";
		
		--SE AGREGA ENCABEZADO AL REPORTE PARA EL ARCHIVO EXCEL.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELDETALLE (Mora,VolumenClientes,PagMinPagPrd,PenMesAnt,IntPrd,IntMort,PagMinReqTotPag,SdoTot)
		VALUES("Mora","Volumen de clientes","Pago minimo/Pago del periodo","Pendiente del mes anterior","Intereses Del periodo","Intereses Moratorios","Pago minimo requerido/Total del pago","Saldo total" );						
		
		--SE ELIMINAN LOS REGISTROS DONDE TODOS LOS TOTALES POR MORA SEAN CEROS YA QUE ESA INFORMACION NO SERA UTIL EN EL ARCHIVO.		
		DELETE tmp_detallecarteraenviada2
		WHERE VolumenCtes = 0
			  AND PagMinPagPer = 0
			  AND PendMesAnt = 0
			  AND InteresesPer	= 0
			  AND InteresesMor = 0 
			  AND PagMinReqTotPag = 0 
			  AND SaldoTot = 0 ;
				 
		--BARRER LA INFORMACION FINAL PARA INSERTARLA EN LA TABLA FINAL.
		FOREACH 
			SELECT Mora,VolumenCtes,PagMinPagPer,PendMesAnt,InteresesPer,InteresesMor,PagMinReqTotPag,SaldoTot
			INTO sMora,dVolumenCtes,dPagMinPagPer,dPendMesAnt,dInteresesPer,dInteresesMor,dPagMinReqTotPag,dSaldoTot
			FROM tmp_detallecarteraenviada2
			ORDER BY mora ASC
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELDETALLE (Mora,VolumenClientes,PagMinPagPrd,PenMesAnt,IntPrd,IntMort,PagMinReqTotPag,SdoTot)
			VALUES(sMora,dVolumenCtes,dPagMinPagPer,dPendMesAnt,dInteresesPer,dInteresesMor,dPagMinReqTotPag,dSaldoTot);					
		END FOREACH;
				
		--SE OBTIENEN LOS TOTALIZADOS DE TODAS LAS COLUMNAS.
		SELECT SUM(VolumenCtes),SUM(PagMinPagPer),SUM(PendMesAnt),SUM(InteresesPer),SUM(InteresesMor),SUM(PagMinReqTotPag),SUM(SaldoTot)
		INTO dVolumenCtesTot,dPagMinPagPerTot,dPendMesAntTot,dInteresesPerTot,dInteresesMorTot,dPagMinReqTotPagTot,dSaldoTotTot
		FROM tmp_detallecarteraenviada2;
						
		--SE INSERTAN LOS TOTALES DE CADA COLUMNA EN LA TABLA DE ENCABEZADOS.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELDETALLE (Mora,VolumenClientes,PagMinPagPrd,PenMesAnt,IntPrd,IntMort,PagMinReqTotPag,SdoTot)
		VALUES("Total",dVolumenCtesTot,dPagMinPagPerTot,dPendMesAntTot,dInteresesPerTot,dInteresesMorTot,dPagMinReqTotPagTot,dSaldoTotTot);	
		
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallecarteraenviada" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP  TABLE tmp_detallecarteraenviada;
		END IF;								
										
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallecarteraenviada2" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP  TABLE tmp_detallecarteraenviada2;
		END IF;
		
		--SE OBTIENE EL NOMBRE DEL ARCHIVO.
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = 72;	
			
		--SE OBTINE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
			AND grupo_parametro = "RUTAS" 
			AND num_parametro = 1;
				
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT Mora,VolumenClientes,PagMinPagPrd,PenMesAnt,IntPrd,IntMort,PagMinReqTotPag,SdoTot FROM bdicobranza:'informix'.TMP_ENCABEZADOSEXCELDETALLE";		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		IF cTabla="S" THEN
				DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELDETALLE;
		END IF;
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';					
		
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
    		
		RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el detalle de cartera enviada.', 
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121105.1550';

CREATE PROCEDURE "informix".sp_reporte_evaluacion_objetiva_convenios(pFechaIni date, pFechaFin date)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  CHAR(80) AS Nombre_archivo,
		  CHAR(80) AS Nombre_archivo2;  		  

-- Definicion Generacion Archivo
DEFINE cNombreArchivo	CHAR(80);
DEFINE cNombreArchivo2	CHAR(80);
DEFINE cTipoArchivo	    CHAR(80);
DEFINE cRuta		    CHAR(80);
DEFINE dtFecha_hoy      DATE;
DEFINE cSql		 		CHAR(2000);
DEFINE cSql2	 		CHAR(2000);

DEFINE cCodRet        	CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cErrorInfo       CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;

DEFINE cProceso         CHAR(4);
DEFINE cMensajeFin      CHAR(100);
DEFINE vvcCod_ret       CHAR(6);


-- Definiciones Evaluacion Objetiva
DEFINE pEmpresa				CHAR(3);
DEFINE cSucursal        	CHAR(4);
DEFINE cSucursalPago    	CHAR(4);
DEFINE cSucursalConv    	CHAR(4);
DEFINE dFechaCompac			DATE;
DEFINE cCajero				CHAR(8);
DEFINE cNomCajero			CHAR(45);
DEFINE cNumcuenta       	CHAR(20); 
DEFINE cProducto			CHAR(4);
DEFINE cOrigen      		CHAR(10);
DEFINE iTipoCompac  		INTEGER;
DEFINE iPlazo       		INTEGER;
DEFINE dImporte     		DECIMAL(14,2);
DEFINE dImpPagado   		DECIMAL(14,2);
DEFINE dConvenioMonto		DECIMAL(14,2);
DEFINE dConvenioAbono		DECIMAL(14,2);
DEFINE iCteVencido  		INTEGER;
DEFINE iNumConvenios  		INTEGER;
DEFINE iNumPMRealizados 	INTEGER;
DEFINE iNumPMNoRealizados 	INTEGER;
DEFINE cCalificacion		CHAR(11);

DEFINE iSucursalConvSuc 	INTEGER;
DEFINE cOrigenSuc			CHAR(10);
DEFINE iTipoCompacSuc  		INTEGER;
DEFINE iPlazoSuc       		INTEGER;
DEFINE dConvenioMontoSuc	DECIMAL(14,2);
DEFINE dConvenioAbonoSuc	DECIMAL(14,2);
DEFINE iCteVencidoSuc		INTEGER;
DEFINE iNumConveniosSuc  	INTEGER;


DEFINE cPagoProgramado  CHAR(1);
DEFINE iNumSesion       INTEGER;

DEFINE cValor           char(1);
DEFINE vFechaMov        DATE;

DEFINE v_count_emp      CHAR(10);
DEFINE cImporte         CHAR(20);
DEFINE cImpPagado       CHAR(20);
DEFINE cFechaCompac     CHAR(20);
DEFINE cFechaIns        CHAR(20);
DEFINE cPagoProgramado_2 CHAR(45);
DEFINE cUsuario         CHAR(8);
DEFINE dt_pri_dia_mes   DATE;
DEFINE dt_ult_dia_mes   DATE;
DEFINE c_Periodicidad   CHAR(1);
DEFINE dFechaini        DATE;
DEFINE dFechafin        DATE;
DEFINE cExtArchivo      CHAR(4);
DEFINE cArch_encabezado CHAR(20);
DEFINE cArch_encabezado_2   CHAR(20);
DEFINE cNombreArchivo_temp  CHAR(80);
DEFINE cNombreArchivo2_temp CHAR(80);
DEFINE cNomArch_caj_tdc	 CHAR(100);
DEFINE cNomArch_suc_tdc	 CHAR(100);
DEFINE cNomArch_caj_crd	 CHAR(100);
DEFINE cNomArch_suc_crd	 CHAR(100);
DEFINE dtFecha_dia_ant   DATE;
 
-- Definicion Generacion Archivo
LET cNombreArchivo_temp	 = "Reporte_Convenios_Cajero_Nuevo_temp_";
LET cNombreArchivo		 = "Reporte_Convenios_Cajero_Nuevo_";
LET cNombreArchivo2_temp = "Reporte_Convenios_Suc_Nuevo_temp_";
LET cNombreArchivo2		 = "Reporte_Convenios_Suc_Nuevo_";


LET cNomArch_caj_tdc	 = "Reporte_Convenios_Cajero_Nuevo_tdc_";
LET cNomArch_suc_tdc	 = "Reporte_Convenios_Suc_Nuevo_tdc_";

LET cNomArch_caj_crd	 = "Reporte_Convenios_Cajero_Nuevo_crd_";
LET cNomArch_suc_crd	 = "Reporte_Convenios_Suc_Nuevo_crd_";


LET cExtArchivo          = '.txt';
LET cTipoArchivo 		 = 'txt';
LET cRuta				 = '';
LET dtFecha_hoy			 = DATE(1);

LET cSql				= '';
LET cSql2				= '';
LET cCodRet             = "000000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET cErrorInfo          = "";
LET iSqlErr             = 0;
LET iIsamErr            = 0;

LET cProceso            = '2079';
LET cMensajeFin         = 'PROCESO TERMINADO EXITOSAMENTE';
LET vvcCod_ret          = '';

 
-- Inicializacion Evaluacion Objetiva
LET pEmpresa			= '001';
LET cSucursal           = '';
LET cSucursalPago       = '';
LET cSucursalConv       = '';
LET dFechaCompac        = DATE(1);
LET cCajero				= '';
LET cNomCajero			= '';
LET cNumcuenta          = '';
LET cProducto			= '';
LET cOrigen             = '';
LET iTipoCompac         = 0;
LET iPlazo              = 0;
LET dImporte            = 0;
LET dImpPagado          = 0;
LET dConvenioMonto		= 0;
LET dConvenioAbono		= 0;
LET iCteVencido  		= 0;
LET iNumConvenios  		= 0;
LET iNumPMRealizados 	= 0;
LET iNumPMNoRealizados 	= 0;
LET cCalificacion		= '';

LET iSucursalConvSuc	= 0;
LET cOrigenSuc			= '';
LET iTipoCompacSuc      = 0;
LET iPlazoSuc           = 0;
LET dConvenioMontoSuc	= 0;
LET dConvenioAbonoSuc	= 0;
LET iCteVencidoSuc 		= 0;
LET iNumConveniosSuc	= 0;



LET cPagoProgramado     = '';
LET iNumSesion          = 0;

LET cValor              = '';
LET vFechaMov           = DATE(1);
LET v_count_emp         = '';
LET cImporte            = '';
LET cImpPagado          = '';
LET cFechaCompac        = '';
LET cFechaIns           = '';
LET cPagoProgramado_2   = '';
LET cUsuario            = '';

LET dt_pri_dia_mes      = DATE(1);
LET dt_ult_dia_mes      = DATE(1);
--LET c_Periodicidad      = pPeriodicidad;
LET cArch_encabezado    = 'encabezado.txt';
LET cArch_encabezado_2  = 'encabezado_2.txt';
LET dtFecha_dia_ant     = DATE(1);
LET dFechaini           = pFechaIni;
LET dFechafin           = pFechaFin;


BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		LET cCodRet= iSqlErr;
		LET cMensajeRet = cErrorInfo;
		
	  RETURN cCodRet, cMensajeRet,"","";
	END EXCEPTION;

	--SET DEBUG FILE TO '/ifxsif01/macf/sp_reporte_evaluacion_objetiva_convenios.trc';
	--TRACE ON;
  
	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeFin, '01') RETURNING vvcCod_ret;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
	--IF  (pFechaIni <> '' and  pFechaFin <> '') and (c_Periodicidad = '' or c_Periodicidad = 'P') then
	IF  (nvl(dFechaini,'') <> '' and  nvl(dFechafin,'') <> '') then
	    LET dtFecha_dia_ant = today-1;
	ELSE    
	
		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes 
		  INTO dtFecha_hoy, dt_pri_dia_mes, dt_ult_dia_mes
		  FROM bdinteg:si_fechas
		 WHERE empresa = pEmpresa;

		---Notas, El reporte se generará: Diario (acumulando diariamente)
		--let dtFecha_hoy = mdy(8,1,2019);  -- SOLO TEST
		--let dt_pri_dia_mes = mdy(8,1,2019); -- SOLO TEST
		--let dt_ult_dia_mes = mdy(8,31,2019); -- SOLO TEST

		--let dtFecha_hoy = mdy(8,20,2021); -- SOLO TEST
		--let dt_pri_dia_mes = mdy(8,31,2021); -- SOLO TEST
		
        if day(dtFecha_hoy) = 1 then
		   let dFechafin = date(dt_pri_dia_mes -1 units day);
		   let dFechaini = month(dFechafin)||'/01/'||year(dFechafin);
		else
		   LET dFechaini = dt_pri_dia_mes; -- dtFecha_hoy;
	       LET dFechafin = dt_ult_dia_mes; -- dtFecha_hoy;		
		end if;
		
		LET dtFecha_dia_ant = today-1;
		
		--LET dFechaini = MDY(6,29,2019); -- TEST MACF
		--LET dFechafin = MDY(7,4,2019);  -- TEST MACF
		
	END IF;
		
	
		SELECT TRIM(valor_alfabetico) INTO cRuta
		  FROM bdicobranza:cb_param_campania
		 WHERE tipo_campania = 11  
		   AND grupo_parametro = 'RUTAS'
		   AND num_parametro =1;
		
		--LET cRuta = "/ifxsif01/roman/IFRS";   -- TEST
		
		
        ------------------------------------------------------------------ CAJERO TDC INI

		LET cNombreArchivo_temp = TRIM(cNombreArchivo_temp)|| LPAD(TRIM(DAY(dtFecha_dia_ant)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_dia_ant)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_dia_ant),3,2);
		LET cNomArch_caj_tdc = TRIM(cNomArch_caj_tdc)|| LPAD(TRIM(DAY(dtFecha_dia_ant)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_dia_ant)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_dia_ant),3,2);
		
	  
		--LET cSql = 'echo "sucursal|fecha_insert|empleado_captura|nombre_efectuo|origen|tipo_compac|plazo|num_credito|num_producto|cte_con_vencido|num_convenios|pct_ctes_convenios|convenio_miles|abono_miles|pct_rec_convenio|calificacion|" > '|| TRIM(cRuta) || trim(cArch_encabezado);
		LET cSql = 'echo "sucursal|fecha_insert|fecha_compac|empleado_captura|nombre_efectuo|origen|tipo_compac|plazo|num_credito|num_producto|cte_con_vencido|num_convenios|pct_ctes_convenios|convenio_miles|abono_miles|pct_rec_convenio|calificacion|" > '|| TRIM(cRuta) || trim(cArch_encabezado);
		SYSTEM trim(cSql);
		
		LET cSql = '';
		-- Reporte de Convenios por Numero de Credito: Tarjeta de credito y Plazo  (CAJERO)
		--LET cSql = 'echo "UNLOAD TO '''||trim(cNombreArchivo)||'.'||trim(cTipoArchivo) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query1.sql';

		LET cSql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| TRIM(cRuta) || trim(cNombreArchivo_temp)|| cExtArchivo || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query10.sql';
		SYSTEM trim(cSql);
		
		LET cSql = '';
		--LET cSql = 'echo "select a.sucursal_origen, a.fecha_insert, a.cajero, a.nom_cajero, a.origen, a.tipo_compac, a.plazo, a.num_credito, a.num_producto, a.cte_con_vencido,'
		LET cSql = 'echo "select a.sucursal_origen,to_char(fecha_insert, ''' || '%d/%m/%Y' || '''), to_char(fecha_compac, ''' || '%d/%m/%Y' || '''), a.cajero, a.nom_cajero, '
		                 || ' a.origen, a.tipo_compac, a.plazo, a.num_credito, a.num_producto,'
						 || ' a.cte_con_vencido,'
						 ||    'a.num_convenios, case when a.cte_con_vencido = 0 then 0 else round((a.num_convenios/a.cte_con_vencido)*100,2) end,'
						 || ' a.convenio_monto, a.convenio_abono,'
						 || ' case when a.convenio_abono = 0 then 0 '
						 || '      else case when (a.convenio_abono/a.convenio_monto)*100 > 100 then 100 else round((a.convenio_abono/a.convenio_monto)*100,2) end end,'
						 || ' a.calificacion ' 
						 || 'from bdicobranza:cb_evaluacion_objetiva_convenios a ' 	       
						 ||           'INNER JOIN bdicred:sd_maecred b ON (b.num_credito = a.num_credito)' 
						 --|| ' where b.num_producto in(''' || '6001' ||''','''||'6600'||''','''||'7000'||''','''||'8100'||''')' 
						 || ' where b.num_producto in(''' || '6001' ||''','''||'6600'||''','''||'7000'||''','''||'8100'||''','''||'8500'||''')'
						 || '   and b.status_cred IN('''||'AA'||''','''||'BA'||''','''||'BT'||''','''||'E1'||''','''||'E2'||''','''||'E3'||''')'
						 || '   and a.fecha_vencim between ' || "'" || dFechaini || "'" || ' and ' || "'" || dFechafin || "'" || '" >> ' || trim(cRuta)|| 'query10.sql';  
						 		
		SYSTEM trim(cSql);
		
		LET cSql = ''; 
		LET cSql = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query10.sql'; 
		SYSTEM trim(cSql);
		
		-- Borrado de temporales que fueron usados para la creacion del archivo	
		--LET cSQL = "rm " ||trim(cRuta)||'query10.sql';
		--SYSTEM trim(cSql); 
		--LET cSql  = '';

		LET cNombreArchivo_temp  = trim(cNombreArchivo_temp)|| cExtArchivo;
		
		--LET cSql = 'cat ' ||trim(cRuta) || trim(cArch_encabezado) || ' ' || trim(cNombreArchivo_temp)  || '>' ||trim(cRuta) || trim(cNombreArchivo) || cExtArchivo; 
		LET cSql = 'cat ' || trim(cRuta) || trim(cArch_encabezado) || ' ' || trim(cRuta) || trim(cNombreArchivo_temp)  || '>' ||trim(cRuta) || trim(cNomArch_caj_tdc) || cExtArchivo; 
		SYSTEM trim(cSql);

		LET cSql = '';
		LET cSql = "gzip -f " ||trim(cRuta)|| trim(cNomArch_caj_tdc) || trim(cExtArchivo);
		SYSTEM trim(cSql);
	   
		LET cNomArch_caj_tdc  = trim(cNomArch_caj_tdc)||'.txt.gz';
		
		------------------------------------------------------------------ CAJERO TDC FIN

		
		
		------------------------------------------------------------------ CAJERO CNR INI
		
		--LET cNombreArchivo_temp = TRIM(cNombreArchivo_temp)|| LPAD(TRIM(DAY(dtFecha_hoy)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_hoy)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_hoy),3,2);
		LET cNomArch_caj_crd = TRIM(cNomArch_caj_crd)|| LPAD(TRIM(DAY(dtFecha_dia_ant)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_dia_ant)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_dia_ant),3,2);
		

		LET cSql = '';
		-- Reporte de Convenios por Numero de Credito: Tarjeta de credito y Plazo  (CAJERO)
		--LET cSql = 'echo "UNLOAD TO '''||trim(cNombreArchivo)||'.'||trim(cTipoArchivo) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query1.sql';

		LET cSql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| TRIM(cRuta) || trim(cNombreArchivo_temp) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query11.sql';
		SYSTEM trim(cSql);
		
		LET cSql = '';
		--LET cSql = 'echo "select a.sucursal_origen,to_char(fecha_insert, ''' || '%d/%m/%Y' || '''), a.cajero, a.nom_cajero, a.origen, a.tipo_compac, a.plazo, a.num_credito, a.num_producto, a.cte_con_vencido,'		 
		LET cSql = 'echo "select a.sucursal_origen,to_char(fecha_insert, ''' || '%d/%m/%Y' || '''), to_char(fecha_compac, ''' || '%d/%m/%Y' || '''), a.cajero, a.nom_cajero,'
                         ||   'a.origen, a.tipo_compac, a.plazo, a.num_credito, a.num_producto,'		 
						 ||   'a.cte_con_vencido,'
						 ||   'a.num_convenios,'
						 ||   'case when a.cte_con_vencido = 0 then 0 else round((a.num_convenios/a.cte_con_vencido)*100,2) end,'
						 ||   'a.convenio_monto, a.convenio_abono, '
						 || ' case when a.convenio_abono = 0 then 0 '
						 || '      else case when round((a.convenio_abono/a.convenio_monto)*100,2) > 100 then 100 '
						 || '          else round((a.convenio_abono/a.convenio_monto)*100,2) end end,'
						 || ' a.calificacion ' 
						 ||   'from bdicobranza:cb_evaluacion_objetiva_convenios_crd a '
						 ||       'INNER JOIN bdicred:sd_maecredcrd b ON (b.num_credito = a.num_credito) ' 
						 --|| ' where b.num_producto in(''' || '6300' ||''','''|| '6011' ||''','''|| '7600' ||''','''|| '7700' ||''',''' ||'6400'||''')'
						 || ' where b.num_producto in(''' || '6300' ||''','''|| '6011' ||''','''|| '7600' ||''','''|| '7700' ||''',''' || '6800' ||''',''' ||'6400'||''')'
					 	 || ' and b.status_cred IN('''||'AA'||''','''||'BA'||''','''||'BT'||''','''||'VP'||''','''||'E1'||''','''||'E2'||''','''||'E3'||''')'
						 || '  and a.fecha_vencim between ' || "'" || dFechaini || "'" || ' and ' || "'" || dFechafin || "'" || '" >> ' || trim(cRuta)|| 'query11.sql';
		
		
		SYSTEM trim(cSql);
		
		LET cSql = ''; 
		LET cSql = 'dbaccess bdicobranza ' ||trim(cRuta)|| 'query11.sql'; 
		SYSTEM trim(cSql);
		
		-- Borrado de temporales que fueron usados para la creacion del archivo	
		--LET cSQL = "rm " ||trim(cRuta)||'query11.sql';
		--SYSTEM trim(cSql); 
		LET cSql  = '';

				
		--LET cSql = 'cat ' ||trim(cRuta) || trim(cArch_encabezado) || ' ' || trim(cNombreArchivo_temp)  || '>' ||trim(cRuta) || trim(cNombreArchivo) || cExtArchivo; 
		LET cSql = 'cat ' || trim(cRuta) || trim(cArch_encabezado) || ' ' || trim(cRuta) || trim(cNombreArchivo_temp)  || '>' ||trim(cRuta) || trim(cNomArch_caj_crd) || cExtArchivo; 
		SYSTEM trim(cSql);

		LET cSql = '';
		LET cSql = "gzip -f " ||trim(cRuta)|| trim(cNomArch_caj_crd) || trim(cExtArchivo);
		SYSTEM trim(cSql);
	   
		LET cNomArch_caj_crd  = trim(cNomArch_caj_crd)||'.gz';
				
		
		------------------------------------------------------------------ CAJERO CNR FIN

    
		
        ------------------------------------------------------------------ SUCURSAL TDC INI

		--LET cSql = 'echo "sucursal|fecha_insert|origen|tipo_compac|plazo|cte_con_vencido|num_convenios|pct_ctes_convenios|sum_num_pago_completo_pm|sum_num_pago_parcial_pm|'
		LET cSql = 'echo "sucursal|fecha_insert|fecha_compac|origen|tipo_compac|plazo|cte_con_vencido|num_convenios|pct_ctes_convenios|sum_num_pago_completo_pm|sum_num_pago_parcial_pm|'
				   || 'pct_cumplim_nums_pms|convenio_miles|abono_miles|pct_recup_convenio|calificacion|" > '|| TRIM(cRuta) || trim(cArch_encabezado_2);
		SYSTEM trim(cSql);
		
		LET cNombreArchivo2_temp = TRIM(cNombreArchivo2_temp)|| LPAD(TRIM(DAY(dtFecha_dia_ant)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_dia_ant)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_dia_ant),3,2);
		LET cNomArch_suc_tdc = TRIM(cNomArch_suc_tdc)|| LPAD(TRIM(DAY(dtFecha_dia_ant)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_dia_ant)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_dia_ant),3,2);
		--LET cSql2 = 'echo "UNLOAD TO '''||trim(cNombreArchivo2)||'.'||trim(cTipoArchivo) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query2.sql';

		LET cSql2 = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| TRIM(cRuta) || trim(cNombreArchivo2_temp)|| cExtArchivo || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query12.sql';
		SYSTEM trim(cSql2);
		
		LET cSql2 = '';          
		--LET cSql2 = 'echo " SELECT 	sucursal_convenio, fecha_insert, origen, tipo_compac, plazo,'
		--LET cSql2 = 'echo " SELECT 	sucursal_convenio, origen, tipo_compac, plazo,'
		LET cSql2 = 'echo " SELECT 	sucursal_convenio, to_char(fecha_insert, ''' || '%d/%m/%Y' || '''), to_char(fecha_compac, ''' || '%d/%m/%Y' || '''), '
                        || ' origen, tipo_compac, plazo,'
						--|| ' round(SUM(case when cte_con_vencido = 0 then 1 else cte_con_vencido end),0) cte_con_vencido,'
						|| ' round(sum(cte_con_vencido),0) cte_con_vencido,'
						|| ' round(sum(num_convenios),0) num_convenios,'
					    || ' case when sum(cte_con_vencido) <= 0 then 0 else round((sum(num_convenios)/ sum(cte_con_vencido)*100),2) end pct_ctes_convenio,'
						|| ' round(sum(num_pm_realizados),0) sum_num_pm_realizados, round(sum(num_pm_no_realizados),0) sum_num_pm_no_realizados,'
						|| ' case when sum(num_pm_no_realizados) <= 0 then 0 ' 
						|| '   else case when round((sum(num_pm_realizados)/ sum(num_pm_no_realizados)*100),2) > 100 then 100 '
                        || '      else round((sum(num_pm_realizados)/ sum(num_pm_no_realizados)*100),2) end end pct_cumplim_nums_pms,'
						|| ' round(sum(convenio_monto),2) convenios_miles, round(sum(convenio_abono),2) abono_miles,'
						|| ' case when round( (sum(convenio_abono) / sum(convenio_monto)) *100,2) > 100 then 100 '
						|| '    else round( (sum(convenio_abono) / sum(convenio_monto)) *100,2) end pct_recup_convenio,'
					    || ' calificacion ' 
						|| 'FROM bdicobranza:cb_evaluacion_objetiva_convenios '
						|| 'WHERE fecha_vencim between ' || "'" || dFechaini || "'" || ' and ' || "'" || dFechafin || "' "
						--|| 'GROUP BY 1,2,3,4,14 " >> '||trim(cRuta)||'query12.sql';
						|| 'GROUP BY 1,2,3,4,5,6,16 " >> '||trim(cRuta)||'query12.sql';
				
			
		SYSTEM trim(cSql2); 
		
		LET cSql2 = "dbaccess bdicobranza "||trim(cRuta)|| 'query12.sql'; 
		SYSTEM trim(cSql2);
		
		-- Borrado de temporales que fueron usados para la creacion del archivo	

		--LET cSQL2 = "rm " ||trim(cRuta)||'query12.sql';
		--SYSTEM trim(cSql2);
		--LET cSql2 = '';

		LET cNombreArchivo2_temp = trim(cNombreArchivo2_temp)|| cExtArchivo;
		
	
		LET cSql2 = 'cat ' || trim(cRuta) || trim(cArch_encabezado_2) || ' ' || trim(cRuta) || trim(cNombreArchivo2_temp)  || '>' ||trim(cRuta) || trim(cNomArch_suc_tdc) || cExtArchivo; 
		SYSTEM trim(cSql2);

		LET cSql2 = '';
		LET cSql2 = "gzip -f " ||trim(cRuta)|| trim(cNomArch_suc_tdc)||cExtArchivo;
		SYSTEM trim(cSql2);
		
		--LET cNomArch_suc_tdc = trim(cNomArch_suc_tdc)||'.gz';
		LET cNomArch_suc_tdc = trim(cNomArch_suc_tdc)||'.txt.gz';
		
		------------------------------------------------------------------ SUCURSAL TDC FIN
		
		
		------------------------------------------------------------------ SUCURSAL CNR INI
		LET cNomArch_suc_crd = TRIM(cNomArch_suc_crd)|| LPAD(TRIM(DAY(dtFecha_dia_ant)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha_dia_ant)::CHAR(2)),2,'0') || substr(YEAR(dtFecha_dia_ant),3,2);
		--LET cSql2 = 'echo "UNLOAD TO '''||trim(cNombreArchivo2)||'.'||trim(cTipoArchivo) || ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query2.sql';

		LET cSql2 = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '''|| TRIM(cRuta) || trim(cNombreArchivo2_temp)|| ''' DELIMITER '''|| '|'||'''" > '||trim(cRuta)||'query13.sql';
		SYSTEM trim(cSql2);
		                 ---- Probar agregándole fecha_insert
		LET cSql2 = '';          
		--LET cSql2 = 'echo " SELECT sucursal_convenio, fecha_insert, origen, tipo_compac, plazo,'
		--LET cSql2 = 'echo " SELECT sucursal_convenio, origen, tipo_compac, plazo,'
		LET cSql2 = 'echo " SELECT sucursal_convenio, to_char(fecha_insert, ''' || '%d/%m/%Y' || '''), to_char(fecha_compac, ''' || '%d/%m/%Y' || '''), '
		                || ' origen, tipo_compac, plazo,'
						--|| ' round(SUM(case when cte_con_vencido = 0 then 1 else cte_con_vencido end),0) cte_con_vencido,'
						|| ' round(sum(cte_con_vencido),0) cte_con_vencido,'
						|| ' round(sum(num_convenios),0) num_convenios,'
					    || ' case when sum(cte_con_vencido) <= 0 then 0 else round((sum(num_convenios)/ sum(cte_con_vencido)*100),2) end pct_ctes_convenio,'
						|| ' round(sum(num_pm_realizados),0) sum_num_pm_realizados, round(sum(num_pm_no_realizados),0) sum_num_pm_no_realizados,'
						|| ' case when sum(num_pm_no_realizados) <= 0 then 0 ' 
						|| '   else case when round((sum(num_pm_realizados)/ sum(num_pm_no_realizados)*100),2) > 100 then 100 '
                        || '      else round((sum(num_pm_realizados)/ sum(num_pm_no_realizados)*100),2) end end pct_cumplim_nums_pms,'
						|| ' round(sum(convenio_monto),2) convenios_miles, round(sum(convenio_abono),2) abono_miles,'
						|| ' case when round( (sum(convenio_abono) / sum(convenio_monto)) *100,2) > 100 then 100 ' 
						|| '      else round( (sum(convenio_abono) / sum(convenio_monto)) *100,2) end pct_recup_convenio,'
						|| ' calificacion ' 
						|| 'FROM bdicobranza:cb_evaluacion_objetiva_convenios_crd '
						|| 'WHERE fecha_vencim between ' || "'" || dFechaini || "'" || ' and ' || "'" || dFechafin || "' "
						--|| 'GROUP BY 1,2,3,4,14 " >> '||trim(cRuta)||'query13.sql'; 
						|| 'GROUP BY 1,2,3,4,5,6,16 " >> '||trim(cRuta)||'query13.sql'; 
		
		
		SYSTEM trim(cSql2); 
		
		LET cSql2 = "dbaccess bdicobranza "||trim(cRuta)|| 'query13.sql'; 
		SYSTEM trim(cSql2);
		
		-- Borrado de temporales que fueron usados para la creacion del archivo	

		--LET cSQL2 = "rm " ||trim(cRuta)||'query13.sql';
		--SYSTEM trim(cSql2);
		--LET cSql2 = '';

	
		LET cSql2 = 'cat ' || trim(cRuta) || trim(cArch_encabezado_2) || ' ' || trim(cRuta) || trim(cNombreArchivo2_temp)  || '>' ||trim(cRuta) || trim(cNomArch_suc_crd) || cExtArchivo; 
		SYSTEM trim(cSql2);

		LET cSql2 = '';
		LET cSql2 = "gzip -f " ||trim(cRuta)|| trim(cNomArch_suc_crd)||cExtArchivo;
		SYSTEM trim(cSql2);
		
		LET cNomArch_suc_crd = trim(cNomArch_suc_crd)||'.gz';
					
		
		------------------------------------------------------------------ SUCURSAL CNR FIN
		

    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeFin, '03')  RETURNING vvcCod_ret;
       
		RETURN cCodRet, cMensajeRet,cNomArch_caj_tdc,cNomArch_suc_tdc;
END
END PROCEDURE
 
;