CREATE PROCEDURE "informix".sp_repcob_cdadcampcat()
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;		
			
		---DECLARACIONES
		DEFINE iSqlErr, iIsamErr				                INTEGER;
		DEFINE cTabla		      	                        CHAR(1);
		DEFINE v_empresa                                CHAR(3);
    DEFINE cProceso                                 CHAR(4);
    DEFINE cfin					                            CHAR(5); 
    DEFINE cCodRet,vvcCod_ret, cCod_RESULT          CHAR(6);
    DEFINE vnumempleado                             CHAR(8);
		DEFINE cMensajeRet, cNombreArchivo, cRuta, cDescrip, cCalfLlamad, cJerarquia			CHAR(80);
    DEFINE cHora, cHoraAsign, cHoraReal, cHora2, cHoraAsign2, cHoraReal2				      CHAR(80);						
		DEFINE cConsulta		  	                        CHAR(2200);
		DEFINE cSql           		                      CHAR(1024);
		DEFINE sTipoFechaCorte, sTipLog, sJerarquia, sTipolog		                          SMALLINT;
		DEFINE cContador, cContador2, cContador3, iCont, iTipLogTot, iTotxDia             INTEGER;
		DEFINE log_1, log_2, log_3, log_4, log_5, log_6, log_7, log_8, log_9				      INTEGER;
		DEFINE iTot1, iTot2, iTot3, iTot4, iTot5, iTot6, iTot7, iTot8, iTot9				      INTEGER;
		DEFINE iTotReg1_1, iTotReg1_2, iTotReg1_3, iTotReg1_4, iTotReg1_5			            INTEGER;
		DEFINE iTotReg1_6, iTotReg1_7, iTotReg1_8, iTotReg1_9 		                        INTEGER;
		DEFINE iTotReg2_1, iTotReg2_2, iTotReg2_3, iTotReg2_4, iTotReg2_5			            INTEGER;
		DEFINE iTotReg2_6, iTotReg2_7, iTotReg2_8, iTotReg2_9, iTotReg2                   INTEGER;
		DEFINE iTotReg3, cTotReg, cTotReg3, cTotReg4, cTotReg5, iTotReg4, iTotReg5				INTEGER;
		DEFINE iRegTotxCamp, iTotRegProcXCamp, iRegTotxCamp2, iTotRegProcXCamp2			      INTEGER;
		DEFINE iNumsEmpl, iTotGen,	iTotReg, iCamActivas, iRegistros                      INTEGER;
		DEFINE iExito, iNoExito, iExitoTot1, iExitoTot2, iExitoTot, iTipo, iTotAvance		  INTEGER;
    DEFINE dProm				                                                              DECIMAL(14,2);
		DEFINE dtFechaHoy, dtFechaDiaAnt, dtFechaMax, dtFechaMaxCart	                    DATE;
		DEFINE iConlog				                                                            SMALLINT;
	
		---INICIALIZACIONES
		LET iIsamErr         = 0;   LET iSqlErr          	= 0;
		LET sTipoFechaCorte  = 0;   LET cContador			    = 0;   LET cContador2			    = 0;  LET cContador3			= 0;	
		LET iCont				     = 0; 	LET sJerarquia		    = 0;   LET sTipolog			      = 0;  LET iTipLogTot			= 0;
		LET log_1				     = 0; 	LET log_2				      = 0;   LET log_3				      = 0; 	LET log_4				    = 0; 	LET log_5				= 0;
		LET log_6				     = 0; 	LET log_7				      = 0; 	 LET log_8				      = 0; 	LET log_9				    = 0; 	LET iTot1				= 0;
		LET iTot2				     = 0; 	LET iTot3				      = 0; 	 LET iTot4				      = 0; 	LET iTot5				    = 0; 	LET iTot6				= 0;
		LET iTot7				     = 0; 	LET iTot8				      = 0; 	 LET iTot9				      = 0; 	LET iRegTotxCamp		= 0;  LET iTotxDia		= 0; 
		LET iRegTotxCamp2	   = 0; 	LET iTotRegProcXCamp	= 0; 	 LET iTotRegProcXCamp2	= 0; 	LET iTotReg				  = 0;  LET iTotGen	    = 0;
		LET iCamActivas		   = 0;		LET dProm				      = 0.0; 
		LET iTotReg1_1			 = 0; 	LET iTotReg1_2			  = 0; 	 LET iTotReg1_3			    = 0; 	LET iTotReg1_4			= 0;	LET iTotReg1_5	= 0; 	
    LET iTotReg1_6			 = 0; 	LET iTotReg1_7			  = 0; 	 LET iTotReg1_8			    = 0;	LET iTotReg1_9			= 0; 	LET iTotReg2_1  = 0; 	 
    LET iTotReg2_2			 = 0; 	LET iTotReg2_3			  = 0; 	 LET iTotReg2_4			    = 0; 	LET iTotReg2_5		  = 0; 	LET iTotReg2_6	= 0; 	
    LET iTotReg2_7			 = 0;		LET iTotReg2_8			  = 0; 	 LET iTotReg2_9			    = 0; 	LET iTotReg2	      = 0;
		
		LET iTotReg3			   = 0;		LET iNumsEmpl			    = 0;   LET iExito				      = 0; 	LET iNoExito			  = 0;  LET iExitoTot1	= 0; 	
    LET iExitoTot2			 = 0; 	LET iExitoTot			    = 0;   LET iTotReg4			      = 0;  LET iTotReg5			  = 0;  LET iTipo			  = 0;
		LET iTotAvance			 = 0;   LET iConlog				    = 0;   LET iRegistros         = 0;  		
		 	
		LET v_empresa        = '001';   LET cProceso    = '0076';  LET cTabla		 		= "N";     LET cCodRet        = "000000";    
		LET cMensajeRet			 = "PROCESO EXITOSO";                  LET dtFechaMax   = date(1); LET dtFechaMaxCart = date(1);
    
    LET cNombreArchivo 	 = "";      LET cConsulta	 		= "";    LET cSql		 		  = "";      LET cRuta		 		  = "";
    LET cHora				     = "";	    LET cHoraAsign	  = "";    LET cHoraReal		= ""; 	   LET cHora2				  = "";
    LET cHoraAsign2			 = "";	    LET cHoraReal2	  = "";    LET cfin				  = "";      LET cTotReg			  = "";
    LET cTotReg3			   = "";      LET cTotReg4		  = "";  	 LET cTotReg5			= "";      LET dtFechaDiaAnt  = "";
    LET vnumempleado     = '';      LET vvcCod_ret    = '';    LET dtFechaHoy   = "";      LET cCod_RESULT		= ""; 
		LET cCalfLlamad			 = "";		  LET cJerarquia	  = "";

    
			BEGIN 
				ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
					IF iSqlErr != 0 THEN
						LET cCodRet = iSqlErr;	
						LET cMensajeRet = cMensajeRet;			  				
						--SE BORRA LA TABLA TEMPORAL EN CASO DE QUE EL PROCEDIMIENTO CAIGA EN UN CASO DE ERROR
						IF cTabla ="S" THEN
							DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA;
						END IF;
					
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
            RETURNING vvcCod_ret;
          			
					  RETURN cCodRet, cMensajeRet;
						
				  END IF;
				END EXCEPTION;

				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/respaldosbd/josue/sp_repcob_cdadcampcat.out";
		--SET DEBUG FILE TO "/informix/macf/sp_repcob_cdadcampcat.trc";
		--TRACE ON; 
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
		
		 IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'TMP_ENCABEZADOSEXCELCAMPCATXDIA'  AND dbsname = 'bdicobranza' AND partnum >1048577) THEN
        DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA;
    END IF;
		
		SELECT max(fecha_insert) INTO dtFechaMax 
      FROM bdicobranza:"informix".cb_cat_directorio_cte
     WHERE tipo_cobranza = 'A';
		
		SELECT max(date(fechacartera)) INTO dtFechaMaxCart
		  FROM bdicobranza:"informix".cb_cat_movimientos
		 WHERE tipocobranza = 'A';
		
		--SE OBTIENE LA FECHA DE HOY.
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
    WHERE empresa = v_empresa;
		 
		--LET dtFechaHoy = mdy('01','31','2013');   --- TEST MACF  mdy('12','13','2012') 214 
		
		LET dtFechaDiaAnt = dtFechaHoy - 1 UNITS DAY;
	
		--SE CREA LA TABLA TEMPORAL PARA INSERTAR LOS DATOS QUE LLEVARÁ EL REPORTE.		
		CREATE TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA(					
																		Cod_RESULT 	CHAR(80),
																		Cal_llam 	CHAR(80),
																		Tipo_log_1	CHAR(80),
																		Tipo_log_2  CHAR(80),
																		Tipo_log_3  CHAR(80),
																		Tipo_log_4  CHAR(80),
																		Tipo_log_5  CHAR(80),
																		Tipo_log_6  CHAR(80),
																		Tipo_log_7  CHAR(80),
																		Tipo_log_8  CHAR(80),
																		Tipo_log_9	CHAR(80),
																		Total		CHAR(80),
																		Camp_CAT_act CHAR(80),
																		Promedio    CHAR(80)
																	);			
		LET cTabla="S";			
		
		--SE AGREGA ENCABEZADO "TITULO Y FECHA DEL REPORTE"
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
		--VALUES("","","","Calidad de Campañas CAT del Día","","","","","","",""||dtFechaHoy,"","","");
		VALUES("","","","Calidad de Campañas CAT del Día","","","","","","",""||day(dtFechaDiaAnt)||"/" ||month(dtFechaDiaAnt)|| "/" ||year(dtFechaDiaAnt),"","","");   --by MACF
		
		--SE AGREGA ENCABEZADO DE CADA COLUMNA PARA TABLA DEL REPORTE EN ARCHIVO EXCEL.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
		VALUES("Cod RESULT","CALIFICACIÓN LLAMADA","","","","","","","","","","Total","Campañas CAT Activas","Promedio");	
		
		--SE BUSCA EL NOMBRE DE CADA CAMPAÑA ACTIVA SI LO ENCUENTRA LO AGREGA Y SI NO AGREGA "VALOR TIPO-LOGICA" Y EL NÚMERO DE CADA COLUMNA DE LA TABLA POR TIPO_LOGICA
		FOREACH		
			SELECT valor_numerico,descripcion
				INTO sTipLog,cDescrip
				FROM bdicobranza:"informix".cb_param_campania
				WHERE grupo_parametro = 'LOGICA'
			
			IF sTipLog = 1 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = "Valor Tipo_logica 1" WHERE Cod_RESULT = "Cod RESULT";
				END IF;
			ELIF sTipLog = 2 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = TRIM(cDescrip)WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = "Valor Tipo_logica 2" WHERE Cod_RESULT = "Cod RESULT";
				END IF;
			ELIF sTipLog = 3 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = "Valor Tipo_logica 3" WHERE Cod_RESULT = "Cod RESULT";
				END IF;
			ELIF sTipLog = 4 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = "Valor Tipo_logica 4" WHERE Cod_RESULT = "Cod RESULT";
				END IF;				
			ELIF sTipLog = 5 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = "Valor Tipo_logica 5" WHERE Cod_RESULT = "Cod RESULT";
				END IF;				
			ELIF sTipLog = 6 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = "Valor Tipo_logica 6" WHERE Cod_RESULT = "Cod RESULT";
				END IF;				
			ELIF sTipLog = 7 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = "Valor Tipo_logica 7" WHERE Cod_RESULT = "Cod RESULT";
				END IF;				
			ELIF sTipLog = 8 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = "Valor Tipo_logica 8" WHERE Cod_RESULT = "Cod RESULT";
				END IF;					
			ELIF sTipLog = 9 THEN 	
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";     
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = "Valor Tipo_logica 9" WHERE Cod_RESULT = "Cod RESULT";
				END IF;
			END IF; 
			LET cContador = cContador + 1;
				
		END FOREACH;
			
		LET cContador2 = 9 - cContador; 
		LET cContador3 = cContador2;
		
		FOR iCont = cContador2 to 9 
		
		    IF cContador2 = 1 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";
			ELIF cContador2 = 2 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";
			ELIF cContador2 = 3 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 4 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 5 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 6 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 7 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 8 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 9 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";			
			END IF;
			
			LET cContador2 = cContador2 + 1;	
			LET cContador3 = cContador3 + 1;			
		END FOR
					
		-- SE CONSULTA LA DESCRIPCION Y CÓDIGO DE LOS RESULTADOS QUE SE PUEDA OBTENER EN CADA LLAMADA
		FOREACH 					
			SELECT id_jerarquia, descripcion 
				INTO cCod_RESULT, cCalfLlamad
			FROM bdicobranza:"informix".cb_cat_tipo_resultado 
			ORDER BY id_jerarquia
			-- SE INSERTA LA INFORMACION DE CADA REGISTRO EN DICHA TABLA
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES(cCod_RESULT,cCalfLlamad,"0","0","0","0","0","0","0","0","0","","","");
			
		END FOREACH;
				
		-- SE CONSULTAN LOS TOTALES DE CADA REGISTRO POR TIPO DE LÓGICA
		FOREACH 
			SELECT  CodResult, TipLogica,NVL(TipLogTot,0)
			  INTO sJerarquia,sTipolog,iTipLogTot 
			  FROM TABLE(MULTISET(SELECT b.id_jerarquia AS CodResult,
									                 a.tipologica AS TipLogica,
            						     COUNT(a.tipologica) AS TipLogTot 
            								  FROM bdicobranza: "informix".cb_cat_movimientos a,
            										   bdicobranza: "informix".cb_cat_tipo_resultado b,
            										   bdicobranza: "informix".cb_param_campania c
            								 WHERE a.finllamada = b.codigo_resultado 
            								   AND a.tipocobranza = "A"
            								   AND a.cvemovimiento = "L"
            								   AND a.tipomovimiento = 1
            								   AND a.tipologica = c.valor_numerico      --- by MACF
            								   AND c.grupo_parametro = 'LOGICA'         --- by MACF
            								   AND a.fechacartera::DATE = dtFechaMaxCart
            								   AND a.horainicio::DATE = dtFechaDiaAnt   --- by MACF
            								GROUP BY 1,2
            								ORDER BY 1,2 ASC
						))
						
			--SE ACTUALIZA LOS TOTALIZADOS POR CADA TIPO DE LÓGICA.
			IF sTipolog = 1 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 2 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 3 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 4 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 5 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 6 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 7 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 8 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 9 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			END IF 
		END FOREACH;
		
		LET iCont = 0;
		
		-- OBTENEMOS EL TOTAL DE LOS REGISTROS PARA OBTENER EL NÚMERO DE RENGLON EN DONDE SE INSERTARÁ LOS REGITROS DE LOS RESULTADOS DE LAS CAMPAÑAS
			SELECT  COUNT(Cod_RESULT) INTO iTotReg 
			FROM bdicobranza: "informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA; 			
			LET iTotReg = iTotReg - 1;
			
			--SE INSERTAN LOS REGITROS DONDE SE ACTUALIZARÁN LOS RESULTADOS DE LAS CAMPAÑAS
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","TOTAL GENERAL","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","REGISTROS TOTALES POR CAMPAÑA","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","REGISTROS PROCESADOS POR CAMPAÑA","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","TOTAL REGISTROS PENDIENTES","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","HORA DE ASIGNACIÓN DE CAMPAÑA","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","HORA DE PAUSA/TERMINO DE CAMPAÑA","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","SUPERVISORES ASIGNADOS","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","AVANCE EN ETAPA TREN DE GESTIÓN","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","LlAMADAS EXITOSAS POR CAMPAÑA","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","LlAMADAS NO EXITOSAS POR CAMPAÑA","","","","","","","","","","","","");
						
			LET iTotReg = iTotReg - 2;
			
		  -- SE OBTIENE EL TOTAL DE CADA TIPO DE LÓGICA Y EL TOTAL POR CADA TIPO DE RESULTADO
			FOR iCont = 0  TO iTotReg
				LET iCamActivas = 0;
			
				SELECT NVL(Tipo_log_1:: INTEGER,0), NVL(Tipo_log_2:: INTEGER,0),NVL(Tipo_log_3:: INTEGER,0),
				       NVL(Tipo_log_4:: INTEGER,0), NVL(Tipo_log_5:: INTEGER,0),NVL(Tipo_log_6:: INTEGER,0),
				       NVL(Tipo_log_7:: INTEGER,0), NVL(Tipo_log_8:: INTEGER,0),NVL(Tipo_log_9:: INTEGER,0)				
					INTO log_1,log_2,log_3,log_4,log_5,log_6,log_7,log_8,log_9	
					
				FROM bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA
				WHERE Cod_RESULT = iCont:: CHAR(80);
				
				LET iTotxDia = log_1 + log_2 + log_3 + log_4 + log_5 + log_6 + log_7 + log_8 + log_9;
				LET iTotGen = iTotGen + iTotxDia;
				LET iTot1 = iTot1 + NVL(log_1,0);
				LET iTot2 = iTot2 + NVL(log_2,0);
				LET iTot3 = iTot3 + NVL(log_3,0);
				LET iTot4 = iTot4 + NVL(log_4,0);
				LET iTot5 = iTot5 + NVL(log_5,0);
				LET iTot6 = iTot6 + NVL(log_6,0);
				LET iTot7 = iTot7 + NVL(log_7,0);
				LET iTot8 = iTot8 + NVL(log_8,0);
				LET iTot9 = iTot9 + NVL(log_9,0);
				
				-- SE OBTIENE EL TOTAL DE CAMPAÑAS ACTIVAS POR CADA TIPO DE LÓGICA
				IF log_1 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_2 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_3 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_4 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_5 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_6 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_7 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_8 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_9 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;
				
				-- SE INSERTA EL TOTAL Y PROMEDIO DE CADA LÓGICA Y CADA TIPO DE RESULTADO
				IF iCamActivas <> 0 THEN
					LET dProm = iTotxDia / iCamActivas;
					LET dProm = ROUND(dProm);
				ELSE
					LET iTotxDia = 0;
					LET dProm = 0;
				END IF;
				--SE ACTUALIZA EL TOTAL Y PROMEDIO DE CADA LÓGICA Y CADA TIPO DE RESULTADO
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA 
					SET Total = NVL(iTotxDia,0), Camp_CAT_act = NVL(iCamActivas,0), Promedio = NVL(dProm,0)
				WHERE Cod_RESULT = iCont:: CHAR(80);
								
			END FOR
			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA 
					SET Tipo_log_1 = NVL(iTot1,0),Tipo_log_2 = NVL(iTot2,0),Tipo_log_3 = NVL(iTot3,0),Tipo_log_4 = NVL(iTot4,0),Tipo_log_5 = NVL(iTot5,0),Tipo_log_6 = NVL(iTot6,0),Tipo_log_7 = NVL(iTot7,0),Tipo_log_8 = NVL(iTot8,0),Tipo_log_9 = NVL(iTot9,0),Total = NVL(iTotGen,0)
				WHERE Cal_llam = "TOTAL GENERAL";
		
		LET iCont = 1;
		LET iTotReg = iTotReg + 2;
		
		-- SE OBTIENEN LOS REGISTROS TOTALES POR CAMPAÑA POR CADA TIPO DE LÓGICA
		FOR  iCont = 1  TO 9
			SELECT  COUNT(tipo_logica)
				INTO iRegTotxCamp
			FROM bdicobranza:"informix".cb_cat_directorio_cte 
			WHERE tipo_cobranza = "A"              --- by MACF
      AND tipo_logica = iCont
			AND fecha_insert = dtFechaMax; 
			
			--SE ACTUALIZAN LOS REGISTROS TOTALES POR CAMPAÑA POR CADA TIPO DE LÓGICA
			IF iCont = 1 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iRegTotxCamp,0) WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_1 = iTotReg1_1 + iRegTotxCamp;
			END IF;
			IF iCont = 2 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(iRegTotxCamp,0) WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_2 = iTotReg1_2 + iRegTotxCamp;
			END IF;
			IF iCont = 3 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_3 = iTotReg1_3 + iRegTotxCamp;
			END IF;
			IF iCont = 4 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_4 = iTotReg1_4 + iRegTotxCamp;
			END IF;
			IF iCont = 5 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_5 = iTotReg1_5 + iRegTotxCamp;
			END IF;
			IF iCont = 6 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_6 = iTotReg1_6 + iRegTotxCamp;
			END IF;
			IF iCont = 7 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_7 = iTotReg1_7 + iRegTotxCamp;
			END IF;
			IF iCont = 8 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_8 = iTotReg1_8 + iRegTotxCamp;
			END IF;
			IF iCont = 9 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(iRegTotxCamp,0) WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_9 = NVL(iTotReg1_9,0) + NVL(iRegTotxCamp,0);
			END IF;
			LET iRegTotxCamp2 = NVL(iRegTotxCamp2,0) + NVL(iRegTotxCamp,0);
		END FOR
		
		UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Total = NVL(iRegTotxCamp2,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
		
		
		LET iTotReg = iTotReg + 1;
		
		--SE OBTIENEN LOS REGISTROS PROCESADOS POR CAMPAÑA POR CADA TIPO DE LÓGICA
		FOREACH
				SELECT COUNT(tipologica),tipologica
					INTO  iTotRegProcXCamp,iConlog
				FROM bdicobranza:"informix".cb_cat_movimientos
				WHERE horainicio::DATE = dtFechaDiaAnt
        AND fechacartera::DATE = dtFechaMaxCart 
				AND tipocobranza = 'A'
				AND cvemovimiento = 'L'
				AND tipomovimiento = 1
				GROUP BY tipologica
				ORDER BY tipologica ASC
				
				--SE ACTUALIZAN LOS REGISTROS PROCESADOS POR CAMPAÑA POR CADA TIPO DE LÓGICA
				IF iConlog = 1 THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_1 =  NVL(iTotReg1_1,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 2 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(iTotRegProcXCamp,0) WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_2 = NVL(iTotReg1_2,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 3 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_3 = NVL(iTotReg1_3,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 4 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_4 = NVL(iTotReg1_4,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 5 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_5 = NVL(iTotReg1_5,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 6 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_6 = NVL(iTotReg1_6,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 7 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_7 = NVL(iTotReg1_7,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 8 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_8 = NVL(iTotReg1_8,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 9 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(iTotRegProcXCamp,0) WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_9 = NVL(iTotReg1_9,0) - NVL(iTotRegProcXCamp,0);				
				END IF;
				--SE OBTIENE EL TOTAL DE REGISTROS PROCESADOS POR CAMPAÑA
				LET iTotRegProcXCamp2 = NVL(iTotRegProcXCamp2,0) + NVL(iTotRegProcXCamp,0);	
			END FOREACH
		
				LET iTotReg2 = iTotReg2_1 + iTotReg2_2 + iTotReg2_3	+ iTotReg2_4 + iTotReg2_5 + iTotReg2_6 + iTotReg2_7 + iTotReg2_8 + iTotReg2_9;
				
				--SE ACTUALIZA EL TOTAL  DE REGISTROS PROCESADOS POR CAMPAÑA
		UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Total = NVL(iTotRegProcXCamp2,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
		
		LET iTotReg = iTotReg + 1;	
		
		--SE ACTUALIZAN LOS TOTALIZADOS DE TOTAL REGISTROS PENDIENTES DE CADA TIPO DE LÓGICA
		UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iTotReg2_1,0),Tipo_log_2 = NVL(iTotReg2_2,0),Tipo_log_3 = NVL(iTotReg2_3,0),Tipo_log_4 = NVL(iTotReg2_4,0),Tipo_log_5 = NVL(iTotReg2_5,0),Tipo_log_6 = NVL(iTotReg2_6,0),Tipo_log_7 = NVL(iTotReg2_7,0),Tipo_log_8 = NVL(iTotReg2_8,0),Tipo_log_9 = NVL(iTotReg2_9,0),Total = NVL(iTotReg2,0) WHERE Cal_llam = "TOTAL REGISTROS PENDIENTES";		
		LET iCont = 1;
		LET iTotReg = iTotReg + 1;
		
		-- SE OBTIENE LA HORA DE INICIO Y FIN DE CADA CAMPAÑA
		FOR  iCont = 1  TO 9
			SELECT SUBSTR(MIN(horainicio),12,2), SUBSTR(MAX(horafin),12,2)
				INTO cHora, cfin
			FROM bdicobranza:"informix".cb_cat_movimientos
			WHERE fechacartera::DATE = dtFechaMaxCart
			AND horainicio::DATE = dtFechaDiaAnt
			AND  tipologica = iCont;
			
		-- SE VALIDA LA HORA PARA SABER SI ES "AM" Ó "PM"
			LET cHoraReal = SUBSTR(cHora, 1,2);
			
			IF trim(cHoraReal) = "00" THEN
				  LET cHoraAsign = "12AM";
			ELSE
				IF cHoraReal:: INTEGER >= 12 THEN					
					LET cHoraReal = cHoraReal:: INTEGER - 12;
					LET cHoraAsign = TRIM(cHoraReal)||"PM";								
				ELSE
					LET cHoraAsign = TRIM(cHoraReal)||"AM";
				END IF;	
			END IF;	
			
			LET cHoraReal2 = SUBSTR(cfin, 1,2);
				
			IF trim(cHoraReal2) = "00" THEN
				  LET cHoraAsign2 = "12AM";
			ELSE	
				IF cHoraReal2:: INTEGER >= 12 THEN				
					LET cHoraReal2 = cHoraReal2:: INTEGER - 12;
					LET cHoraAsign2 = TRIM(cHoraReal2)||"PM";								
				ELSE
					LET cHoraAsign2 = TRIM(cHoraReal2)||"AM";
				END IF;
			END IF;	
			
			LET iTotReg3 = iTotReg + 1;
			LET cTotReg  =  iTotReg:: CHAR(80);
			LET cTotReg3 = iTotReg3:: CHAR(80);
			
			-- SE ACTUALIZA LA HORA DE INICIO Y FIN DE CADA CAMPAÑA EN LA TABLA TEMPORAL
			IF iCont = 1 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(cHoraAsign2,"00")	WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";				
			END IF;
			IF iCont = 2 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(cHoraAsign,"00") WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(cHoraAsign2,"00")	WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 3 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(cHoraAsign2,"00")	WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 4 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(cHoraAsign2,"00")	WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 5 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(cHoraAsign2,"00")	WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 6 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(cHoraAsign2,"00")WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 7 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(cHoraAsign2,"00")WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 8 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(cHoraAsign2,"00")WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";	
			END IF;
			IF iCont = 9 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(cHoraAsign,"00") WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(cHoraAsign2,"00") WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			LET cHora     = "";
			LET cHoraReal = "";
			LET cHora2     = "";
			LET cHoraReal2 = "";
		END FOR
		
		LET iCont = 1;
		LET iTotReg3 = iTotReg3 + 1;
		LET cTotReg3 = iTotReg3:: CHAR(80);
		
		-- SE OBTIENE EL NÚMERO DE "SUPERVISORES ASIGNADOS"  POR CADA CAMPAÑA
      
		FOR  iCont = 1  TO 9
		   LET iNumsEmpl = 0; 
		   FOREACH
    			    --SELECT COUNT(numempleado)
    			 SELECT  numempleado
    				INTO vnumempleado
    	 		 FROM bdicobranza:"informix".cb_cat_movimientos
    	 		 WHERE fechacartera::DATE = dtFechaMaxCart
    	 		 AND  horainicio::DATE = dtFechaDiaAnt        --- by MACF y 3 sigs. filtros
    	 		 AND  cvemovimiento = 'L'
    	 		 AND  tipomovimiento = 1
           AND  tipocobranza = 'A'    
    			 AND  tipologica = iCont
    			 GROUP BY numempleado
    			 
			     --LET iNumsEmpl = iNumsEmpl +1;
			     
			     LET iRegistros=dbinfo("sqlca.sqlerrd2");
			     LET iNumsEmpl = iNumsEmpl + iRegistros;
       END FOREACH
       			 
			 -- SE ACTUALIZA EL NÚMERO DE "SUPERVISORES ASIGNADOS"  POR CADA CAMPAÑA EN LA TABLA TEMPORAL
			 IF iCont = 1 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 2 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 3 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 4 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 5 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 6 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 7 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 8 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 9 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;
		END FOR
		 
		LET iCont = 1;
		LET iTotReg3 = iTotReg3 + 1;
		LET iTotReg4 = iTotReg3 + 1;
		LET iTotReg5 = iTotReg4 + 1;
		
		LET cTotReg3 = iTotReg3:: CHAR(80);
		
		LET cTotReg4 = iTotReg4:: CHAR(10);
		
		LET cTotReg5 = iTotReg5:: CHAR(10);
		
		-- SE OBTIENE EL TOTAL DE LLAMADAS EXITOSAS O NO EXITOSAS DE CADA TIPO DE LÓGICA
		FOREACH
			SELECT SUM(CASE WHEN finllamada IN(1,2,3,4,5,6,7,10,14,15) THEN 1 ELSE 0 END),
				   --SUM(CASE WHEN finllamada IN(8,9,11,12,13,16) THEN 1 ELSE 0 END),tipologica 
				   SUM(CASE WHEN finllamada IN(8,9,11,12,13,16,17,18) THEN 1 ELSE 0 END),tipologica   -- by MACF
			INTO iExito,iNoExito, iTipo
			FROM bdicobranza:"informix".cb_cat_movimientos
			WHERE fechacartera::DATE = dtFechaMaxCart
	 		 AND  horainicio::DATE = dtFechaDiaAnt       --- by MACF y 3 sigs. filtros
	 		 AND  cvemovimiento = 'L'
       AND  tipocobranza = 'A'  
			GROUP BY tipologica
			ORDER BY tipologica
			
			-- SE OBTIENE "AVANCE EN ETAPA TREN DE GESTIÓN" DE CADA TIPO LÓGICA O CAMPAÑA
			LET iExitoTot1 = iExitoTot1 + iExito;
			LET iExitoTot2 = iExitoTot2 + iNoExito;
			LET iExitoTot = iExito + iNoExito;
			LET iTotAvance = iExitoTot2 + iExitoTot1;
			
			-- SE ACTUALIZAN EL TOTAL DE LLAMADAS EXITOSAS,NO EXITOSAS Y AVANCE EN ETAPA TREN DE GESTIÓN DE CADA CAMPAÑA
			IF iTipo = 1 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";								
			END IF;	
			IF iTipo = 2 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 3 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 4 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 5 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 6 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 7 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 8 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 9 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;
		END FOREACH;
		
		--SE OBTIENE EL NOMBRE DEL ARCHIVO.		
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = 78;

		--SE OBTINE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
			AND grupo_parametro = "RUTAS" 
			AND num_parametro = 1;
		
		-- SE CREA EL ARCHIVO EXCEL EN LA RUTA OBTENIDA
		--LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||MONTH(dtFechaHoy)||DAY(dtFechaHoy);
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio FROM bdicobranza: 'informix'.TMP_ENCABEZADOSEXCELCAMPCATXDIA";		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		-- SE BORRA LA TABLA TEMPORAL DESPÚES DE VACIAR LOS DATOS EN EL ARCHIVO EXCEL
		IF cTabla = "S" THEN
			DROP TABLE bdicobranza: "informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA;
		END IF;
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';					
		
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
    		
		RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener la Calidad de Campañas CAT del día.', 
'AUTOR: Josué R. Zazueta',
'FECHA: Noviembre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121122.1527';

create procedure "informix".sp_latinia_contador(pcampania char(10),pcontador integer)
returning VARCHAR(6);

DEFINE cCod_ret  	smallint;
DEFINE cMensaje  	char (100);
DEFINE SQL_ERR         INTEGER;
DEFINE ISAM_ERR        INTEGER;
DEFINE ERROR_INFO      VARCHAR(80);
DEFINE P_COD_RET      	VARCHAR(6);
DEFINE P_MENSAJE       	VARCHAR(80);
define vmaxfecha 		date;
define vfecha			date;

	let P_COD_RET = '000000';
	let cCod_ret = '';
    let cMensaje = '';
	let SQL_ERR            = 0;
	let ISAM_ERR           = 0;
	let ERROR_INFO         = '';
	let P_MENSAJE          = '';
	let vmaxfecha = date(1);
	let vfecha = date(1);


BEGIN 
  
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
     RETURN P_COD_RET;
     END exception;
-- SET DEBUG FILE TO 'compac.out';
-- TRACE ON;
		
	select fecha_hoy into vfecha from bdicred:sd_fechas where empresa = '001';
		
		if exists (select fecha_insert from  bdicred:sd_totalcte_campania where month(fecha_insert) = month(vfecha)
						and year(fecha_insert) = year(vfecha)	and tipocampania = pcampania) then
		
			update bdicred:sd_totalcte_campania  set total = total + pcontador 
				where month(fecha_insert) = month(vfecha) and year(fecha_insert) = year(vfecha)
				and tipocampania = pcampania ;
		else
			insert into bdicred:sd_totalcte_campania (empresa,fecha_insert,tipocampania,total)  
			values('001',today,pcampania,pcontador);
		end if;
	
	
end
RETURN P_COD_RET;
END PROCEDURE;