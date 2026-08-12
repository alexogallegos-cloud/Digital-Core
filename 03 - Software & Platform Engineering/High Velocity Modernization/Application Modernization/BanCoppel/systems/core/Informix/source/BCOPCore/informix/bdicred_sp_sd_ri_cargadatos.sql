CREATE PROCEDURE "informix".sp_sd_ri_cargadatos()   
--RETURNING CHAR(06) AS resultado,    CHAR(80) AS mensaje;
RETURNING CHAR(06) AS resultado;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: RQI 28 194 - Proceso de automatizaciÃ³n de RI a demanda
	--Modificado por: 98769022 Miguel Alejandro Sanchez Mojica
	--Fecha de modificaciÃ³n: 19/07/2019
	--ModificaciÃ³n: Se realiza un pequeÃ±o ajuste para que en las tablas sd_ri_altarecompensa_aux y sd_ri_rangorecompensa_aux, la fecha de ejecuciÃ³n se actualice como NULL. Se modifica DELETE por TRUNCATE.
	--BD: bdicred
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1287 - AplicaciÃ³n de monto variable de CashBack
	--Modificado por: 98769022 Miguel Alejandro Sanchez Mojica
	--Fecha de modificaciÃ³n: 13/12/2019
	--ModificaciÃ³n: Se agrega el campo monto_variable en las tablas sd_ri_archivos, sd_ri_archivos_aux y sd_ri_carga_archivos_historico para guardar el monto que se aplicarÃ¡ para la recompensa de monto variable.
	--BD: bdicred
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES ERROR                     *
-- ****************************************************************************
	DEFINE cCodRet      		     CHAR(6); 
	DEFINE vNumSOL     			     CHAR(20);
	DEFINE iSqlErr      		     INTEGER;
	DEFINE iIsamErr     		     INTEGER;
	DEFINE p_fecha_fin			     DATE;
	DEFINE cMsjError      		     CHAR(500);
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE cId_carga_altarecompensa      	INTEGER;
	DEFINE cId_carga_altarecompensa_ant  	INTEGER;
	DEFINE cId_carga_rangorecompensa 		INTEGER;
	DEFINE cId_carga_rangorecompensa_ant	INTEGER;
	DEFINE cId_tipo_recompensa	     		INTEGER;
	DEFINE cNombre_campana        	 		CHAR(145);
	DEFINE cFecha_inicio          	 		DATE;
	DEFINE cFecha_final           	 		DATE;
	DEFINE cId_periodo            	 		INTEGER;
	DEFINE cRango                	 		INTEGER;
	DEFINE cNumero_op_inicial        		CHAR(2);
	DEFINE cNumero_op_final       	 		CHAR(2);
	DEFINE cId_tipo_transacc         		CHAR(2);
	DEFINE cMonto_op_inicial      	 		MONEY;
	DEFINE cMonto_op_final        	 		MONEY;
	DEFINE cTotal_recompensas     	 		INTEGER;
	DEFINE cMonto_recompensa      	 		CHAR(10);
	DEFINE cStatus                	 		CHAR(20);
	DEFINE cId_campana_actual		 		INTEGER;
	DEFINE cId_campana_anterior    	 		INTEGER;
	DEFINE cId_rango_actual			 		INTEGER;
	DEFINE cId_rango_anterior		 		INTEGER;
	DEFINE cAcumulador   			 		INTEGER;
	DEFINE dFechaHoy             	 		DATE;
	DEFINE cPky_id_archivo 			 		INTEGER;
	DEFINE cNum_credito 			 		CHAR(20);
	DEFINE vNum_credito 			 		CHAR(20);	-- RQI 28 194
	DEFINE vStatus		 			 		CHAR(20);	-- RQI 28 194
	DEFINE vMonto_variable					INTEGER;	-- RQM 10 1287
	DEFINE cStatus_archivo           		CHAR(20);
	DEFINE cExiste					 		INTEGER;
	DEFINE cExistenReg				 		INTEGER;
	DEFINE sFechaArch			     		CHAR(10);
	DEFINE sFechaArch2			     		CHAR(10);
	DEFINE cCons1				     		CHAR(1000);
	DEFINE cCons2				     		CHAR(1000);
	DEFINE cQuery				     		CHAR(6000);
	DEFINE cQuery2				     		CHAR(6000);
	DEFINE pArchDescarga		     		CHAR(150);
	DEFINE pArchDescarga2		     		CHAR(150);
	DEFINE sDia					     		CHAR(2);
	DEFINE sMes					     		CHAR(2);
	DEFINE sYear				     		CHAR(4);
	DEFINE cnom_Sql				     		CHAR(100);
	DEFINE cnom_Sql2			     		CHAR(100);
	DEFINE cSQL1				     		CHAR(200);
	DEFINE cSQL2				     		CHAR(200);
	DEFINE cRuta				     		CHAR(100);
	DEFINE cSQL                      		CHAR(100) ;
	DEFINE wBegin					 		CHAR (1);  	LET wBegin = ''; 

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	LET cCodRet      			= '00000';
	LET iSqlErr      			= 0;
	LET iIsamErr     			= 0;
	LET vNumSOL     			= '';
	LET p_fecha_fin				= DATE(1);
	LET cMsjError 			    ='';
-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET cId_carga_altarecompensa  	    = 0;
	LET cId_carga_altarecompensa_ant  	= 0;
	LET cId_carga_rangorecompensa	    = 0;
	LET cId_carga_rangorecompensa_ant	= 0;
	LET cId_tipo_recompensa	    	    = 0;
	LET cNombre_campana        		    ='';
	LET cFecha_inicio          		    = DATE(1);
	LET cFecha_final           	        = DATE(1);
	LET cId_periodo            		    = 0;
	LET cRango                		    = 0;
	LET cNumero_op_inicial      	    ='';
	LET cNumero_op_final       		    ='';
	LET cId_tipo_transacc       	    ='';
	LET cMonto_op_inicial      		    =0.00;
	LET cMonto_op_final        		    =0.00;
	LET cTotal_recompensas     	        = 0;
	LET cMonto_recompensa      	        ='';
	LET cStatus                	        ='';
	LET cId_campana_actual			    =0;
	LET cId_campana_anterior    	    =0;
	LET cId_rango_actual			    =0;
	LET cId_rango_anterior			    =0;
	LET cAcumulador                     =0;
	LET dFechaHoy               	    =DATE(1);
	LET cPky_id_archivo 			    =0;
	LET cNum_credito 			        ='';
	LET vNum_credito 			        ='';	-- RQI 28 194
	LET vStatus		 			        ='';	-- RQI 28 194
	LET cStatus_archivo                 ='';
	LET cExiste							=0;
	LET sFechaArch				        = "";
	LET sFechaArch2				        = "";
	LET cCons1					        = "";
	LET cCons2					        = "";
	LET cQuery					        = "";
	LET cQuery2					        = "";
	LET pArchDescarga			        = "";
	LET pArchDescarga2			        = "";
	LET sDia					        = "";
	LET sMes					        = "";
	LET sYear					        = "";
	LET cSQL1					        = "";
	LET cSQL2					        = "";
	LET cRuta		 			        = "/resplogifx/Credito_RI/"; 
	LET cnom_Sql 						= 'ri_p_altarec_' ;
	LET cnom_Sql2 						= 'ri_p_altaarchivos_' ; 
	LET cExistenReg				        = 0;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				--LET cCodRet = iSqlErr;
				LET cCodRet = '00000';	
				
				TRUNCATE TABLE bdicred:"informix".sd_ri_archivos_aux;			-- RQI 28 194
				TRUNCATE TABLE bdicred:"informix".sd_ri_rangorecompensa_aux;	-- RQI 28 194
				TRUNCATE TABLE bdicred:"informix".sd_ri_altarecompensa_aux;		-- RQI 28 194
				
				ROLLBACK WORK;
				--RETURN cCodRet,cMsjError;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-668)  SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRet = '00000';		
				LET cMsjError = 'NO SE PUEDE PROCESAR EL ARCHIVO. VALIDAR SALTOS DE LINEA. VERIFICAR EL FORMATO';
				
				TRUNCATE TABLE bdicred:"informix".sd_ri_carga_altarecompensa;	-- RQI 28 194
				TRUNCATE TABLE bdicred:"informix".sd_ri_carga_archivos;			-- RQI 28 194
				
				LET cCons1 = cMsjError; 
				LET cSQL   = '">'||TRIM(cRuta)|| TRIM(cnom_Sql)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
				LET cSQL2   = '">'||TRIM(cRuta)|| TRIM(cnom_Sql2)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
				LET cQuery  = ' echo "'||TRIM(cCons1) || "" || cSQL;
				SYSTEM TRIM(cQuery);
				LET cQuery  = ' echo "'||TRIM(cCons1) || "" || cSQL2;
				SYSTEM TRIM(cQuery);
				--RETURN cCodRet,cMsjError;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-1207)  SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRet = '00000';		
				LET cMsjError = 'NO SE PUEDE PROCESAR EL ARCHIVO. VALIDAR SALTOS DE LINEA. VERIFICAR EL FORMATO';
				
				TRUNCATE TABLE bdicred:"informix".sd_ri_carga_altarecompensa;	-- RQI 28 194
				TRUNCATE TABLE bdicred:"informix".sd_ri_carga_archivos;			-- RQI 28 194
				
				LET cCons1 = cMsjError; 
				LET cSQL   = '">'||TRIM(cRuta)|| TRIM(cnom_Sql)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
				LET cSQL2   = '">'||TRIM(cRuta)|| TRIM(cnom_Sql2)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
				LET cQuery  = ' echo "'||TRIM(cCons1) || "" || cSQL;
				SYSTEM TRIM(cQuery);
				LET cQuery  = ' echo "'||TRIM(cCons1) || "" || cSQL2;
				SYSTEM TRIM(cQuery);
				--RETURN cCodRet,cMsjError;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-268)  SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRet = '00000';		
				LET cMsjError = 'NO SE PUEDE PROCESAR EL ARCHIVO. VALIDAR REGISTROS DUPLICADOS';
				
				TRUNCATE TABLE bdicred:"informix".sd_ri_carga_altarecompensa;	-- RQI 28 194
				TRUNCATE TABLE bdicred:"informix".sd_ri_carga_archivos;			-- RQI 28 194
				
				LET cCons1 = cMsjError; 
				LET cSQL   = '">'||TRIM(cRuta)|| TRIM(cnom_Sql)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
				LET cSQL2   = '">'||TRIM(cRuta)|| TRIM(cnom_Sql2)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
				LET cQuery  = ' echo "'||TRIM(cCons1) || "" || cSQL;
				SYSTEM TRIM(cQuery);
				LET cQuery  = ' echo "'||TRIM(cCons1) || "" || cSQL2;
				SYSTEM TRIM(cQuery);
				--RETURN cCodRet,cMsjError;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-691)  SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRet = '00000';		
				LET cMsjError = 'NO SE PUEDE PROCESAR EL ARCHIVO VALIDAR DATOS VALIDOS';
				
				TRUNCATE TABLE bdicred:"informix".sd_ri_carga_altarecompensa;	-- RQI 28 194
				TRUNCATE TABLE bdicred:"informix".sd_ri_carga_archivos;			-- RQI 28 194
				
				LET cCons1 = cMsjError; 
				LET cSQL   = '">'||TRIM(cRuta)|| TRIM(cnom_Sql)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
				LET cSQL2   = '">'||TRIM(cRuta)|| TRIM(cnom_Sql2)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
				LET cQuery  = ' echo "'||TRIM(cCons1) || "" || cSQL;
				SYSTEM TRIM(cQuery);
				LET cQuery  = ' echo "'||TRIM(cCons1) || "" || cSQL2;
				SYSTEM TRIM(cQuery);
				--RETURN cCodRet,cMsjError;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
	
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/informix/PLL/RI/Log/sp_sd_ri_cargadatos.out';
		--TRACE ON; 
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
		
		/* Iniciar valores de archivos */
		
		SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = '001';
		
		TRUNCATE TABLE bdicred:"informix".sd_ri_carga_altarecompensa;												-- RQI 28 194
		TRUNCATE TABLE bdicred:"informix".sd_ri_carga_archivos;														-- RQI 28 194
		TRUNCATE TABLE bdicred:"informix".sd_ri_rangorecompensa_aux;												-- RQI 28 194
		TRUNCATE TABLE bdicred:"informix".sd_ri_archivos_aux;														-- RQI 28 194
		TRUNCATE TABLE bdicred:"informix".sd_ri_altarecompensa_aux;													-- RQI 28 194
				
		-- RQI 28 194 Inicio
		FOREACH WITH HOLD

			SELECT 	{+INDEX (bdicred:sd_ri_carga_archivos_historico )}
					num_credito, status, monto_variable
			INTO 	vNum_credito, vStatus, vMonto_variable				-- RQM 10 1287
			FROM 	bdicred:"informix".sd_ri_carga_archivos_historico
			WHERE	fecha_proceso < TODAY-180

			BEGIN WORK;

				DELETE 
				FROM 	bdicred:"informix".sd_ri_carga_archivos_historico 
				WHERE	num_credito = vNum_credito AND status = vStatus;

			COMMIT WORK;

		END FOREACH;
		-- RQI 28 194 Fin
		
		BEGIN;
			DELETE bdicred:"informix".sd_ri_carga_altarecompensa_historico WHERE FECHA_PROCESO < TODAY-180 ;	
		COMMIT;
		

		/* SE MANDA LLAMAR EL SP sp_sd_ri_unload_tabla CAMPANA*/


		EXECUTE PROCEDURE bdicred:"informix".sp_sd_ri_load_tabla('ri_c_altarec_','sd_ri_carga_altarecompensa',TRIM(cRuta))
		--  EXECUTE PROCEDURE bdicred:"informix".sp_sd_ri_dbload_tabla('ri_c_altarec_','sd_ri_carga_altarecompensa',TRIM(cRuta),15)
		INTO iSqlErr,cMsjError;

		EXECUTE PROCEDURE bdicred:"informix".sp_sd_ri_load_tabla('ri_c_altaarchivos_','sd_ri_carga_archivos',TRIM(cRuta))			-- RQM 10 1287
		-- EXECUTE PROCEDURE bdicred:"informix".sp_sd_ri_dbload_tabla('ri_c_altaarchivos_','sd_ri_carga_archivos',TRIM(cRuta),4) 	-- RQM 10 1287
		INTO iSqlErr,cMsjError;


		SELECT MAX(pky_id_altarecompensa)+1  INTO cId_campana_actual  FROM bdicred:"informix".sd_ri_altarecompensa;	
		SELECT MAX(pky_id_rangorecompensa)+1 INTO cId_rango_actual    FROM bdicred:"informix".sd_ri_rangorecompensa;

		FOREACH WITH HOLD

			SELECT 	pky_id_carga_altarecompensa,pky_id_carga_rangorecompensa,fky_id_tipo_recompensa,nombre_campana,
					fecha_inicio,fecha_final,id_periodo,numero_op_inicial,numero_op_final,fky_id_tipo_transacc,
					monto_op_inicial,monto_op_final,total_recompensas,monto_recompensa,status  
			INTO  	cId_carga_altarecompensa,cId_carga_rangorecompensa,cId_tipo_recompensa,cNombre_campana,
					cFecha_inicio, cFecha_final,cId_periodo,cNumero_op_inicial,cNumero_op_final,cId_tipo_transacc,cMonto_op_inicial,
					cMonto_op_final,cTotal_recompensas,cMonto_recompensa,cStatus
			FROM 	bdicred:"informix".sd_ri_carga_altarecompensa

			SELECT count(*) INTO cExiste FROM  bdicred:"informix".sd_ri_carga_archivos WHERE pky_id_archivo = cId_carga_altarecompensa;


			IF (cFecha_inicio < cFecha_Final OR cFecha_inicio <=  dFechaHoy ) THEN	-- RQI 28 194
		
				IF (cExiste > 0) THEN
			
					IF  cId_carga_altarecompensa_ant  != cId_carga_altarecompensa THEN
							
						LET cMsjError = 'INSERTA CAMPAÃA' || cId_campana_actual ;		
			
						/* Insertar las campanias */
						INSERT INTO bdicred:"informix".sd_ri_altarecompensa_aux(pky_id_altarecompensa,activo,fecha_alta,nombre_campana,fecha_inicio,
														fecha_final,fky_id_tipo_recompensa,carga_archivo,fky_id_archivo,id_tp_producto,id_producto_tarjeta,fky_id_campana_inicio,fky_id_campana_fin,id_regional,id_tipo_transacc,fecha_ejecucion)
						VALUES(cId_campana_actual,1,today,cNombre_campana,cFecha_inicio,cFecha_final,cId_tipo_recompensa,1,cId_campana_actual,'','',5,5,'',cId_tipo_transacc,today);


						LET cMsjError = 'INSERTA TABLA CREDITOS'; 	
						INSERT INTO bdicred:"informix".sd_ri_archivos_aux (pky_id_archivo,fky_id_altarecompensa,total_op,num_credito,recompensado,fecha_redencion,monto_variable)		-- RQM 10 1287
						SELECT distinct pky_id_archivo,pky_id_archivo,0,num_credito,0,'',monto_variable from bdicred:"informix".sd_ri_carga_archivos									-- RQM 10 1287
						where pky_id_archivo = cId_carga_altarecompensa;

						UPDATE bdicred:"informix".sd_ri_archivos_aux SET pky_id_archivo =  cId_campana_actual, fky_id_altarecompensa = cId_campana_actual
						where pky_id_archivo = cId_carga_altarecompensa;


						/* ACTUALIZA STATUS CARGA_ARCHIVOS */

						UPDATE bdicred:"informix".sd_ri_carga_archivos SET status = 'CAM '|| cId_campana_actual
						WHERE pky_id_archivo = cId_carga_altarecompensa;


						UPDATE 		bdicred:"informix".sd_ri_carga_archivos SET status = 'REGISTRO DUPLICADO CAM ' || cId_campana_actual
						WHERE 		num_credito IN (select num_credito from bdicred:"informix".sd_ri_carga_archivos 
						GROUP BY  	pky_id_archivo,num_credito,status HAVING count(*) > 1);

					ELSE 
						LET cId_campana_actual = cId_campana_actual-1;
			
					END IF;

					/* Insertar las Rangos */
					INSERT INTO bdicred:"informix".sd_ri_rangorecompensa_aux(pky_id_rangorecompensa,activo,fky_id_altarecompensa,fky_id_tipo_recompensa,
										monto_op_inicial,monto_op_final,total_recompensas,total_redenciones,numero_op_inicial,numero_op_final,id_periodo,monto_recompensa,fky_id_tiempoaire,fky_id_dinero_e,id_monto_dinero_e,fecha_ejecucion)
					VALUES(cId_rango_actual,1,cId_campana_actual,cId_tipo_recompensa,cMonto_op_inicial,cMonto_op_final,cTotal_recompensas,0,cNumero_op_inicial,cNumero_op_final,cId_periodo,cMonto_recompensa,'','','',today);

					LET cMsjError = 'INSERTA RANGO' || cId_rango_actual;

					/* ACTUALIZA STATUS CARGA CAMPANA*/
					UPDATE bdicred:"informix".sd_ri_carga_altarecompensa SET status = 'CAM '|| cId_campana_actual ||' RAN '||  cId_rango_actual
					WHERE pky_id_carga_altarecompensa = cId_carga_altarecompensa AND pky_id_carga_rangorecompensa = cId_carga_rangorecompensa;
					
					/* ACTUALIZA VARIABLES*/

					LET cId_carga_altarecompensa_ant  = cId_carga_altarecompensa;	
					LET cId_carga_rangorecompensa_ant  = cId_carga_rangorecompensa;			
					LET cId_campana_anterior = cId_campana_actual; 
					LET cId_campana_actual = cId_campana_actual+1;
					LET cId_rango_actual = cId_rango_actual+1;
					LET cAcumulador= cAcumulador+1;

				ELSE
					UPDATE 	bdicred:"informix".sd_ri_carga_altarecompensa SET status = 'NO HAY CREDITOS ASOCIADOS'
					WHERE 	pky_id_carga_altarecompensa = cId_carga_altarecompensa
					AND 	pky_id_carga_rangorecompensa = cId_carga_rangorecompensa;

				END IF;

			ELSE
				UPDATE 	bdicred:"informix".sd_ri_carga_altarecompensa SET status = 'VALIDAR FECHA DE INICIO'
				WHERE 	pky_id_carga_altarecompensa = cId_carga_altarecompensa
				AND 	pky_id_carga_rangorecompensa = cId_carga_rangorecompensa;
				
			END IF;
				
		END FOREACH;

		BEGIN WORK;
		
			UPDATE bdicred:"informix".sd_ri_altarecompensa_aux SET fecha_ejecucion = NULL;	-- RQI 28 194
			INSERT INTO bdicred:"informix".sd_ri_altarecompensa
			SELECT * FROM bdicred:"informix".sd_ri_altarecompensa_aux;
			
			LET cMsjError = 'RANGOS FINALES';
			UPDATE bdicred:"informix".sd_ri_rangorecompensa_aux SET fecha_ejecucion = NULL;	-- RQI 28 194
			INSERT INTO bdicred:"informix".sd_ri_rangorecompensa
			SELECT * FROM bdicred:"informix".sd_ri_rangorecompensa_aux;
			
			LET cMsjError = 'CREDITOS FINALES'; 
			INSERT INTO   bdicred:"informix".sd_ri_archivos
			SELECT * FROM bdicred:"informix".sd_ri_archivos_aux;
				
				
			/* Insertar en Historico */
			LET cMsjError = 'INSERTA HISTORICO CAMP'; 
			INSERT INTO bdicred:"informix".sd_ri_carga_altarecompensa_historico
			SELECT distinct *,current  FROM bdicred:"informix".sd_ri_carga_altarecompensa;
			
			LET cMsjError = 'INSERTA HISTORICO  CREDITO'; 
			
			INSERT INTO bdicred:"informix".sd_ri_carga_archivos_historico
			SELECT pky_id_archivo, num_credito, status, current, monto_variable FROM bdicred:"informix".sd_ri_carga_archivos; -- RQM 10 1287
						
			
			LET cMsjError = 'ACTUALIZACION DE STATUS'; 
			
			UPDATE bdicred:"informix".sd_ri_carga_altarecompensa_historico SET STATUS = 'NO PROCESADO VALIDAR DATOS'
			WHERE STATUS  = '0';
			
			UPDATE bdicred:"informix".sd_ri_carga_archivos_historico SET STATUS = 'NO PROCESADO VALIDAR DATOS'
			WHERE STATUS  = '0';

		COMMIT WORK; 

		LET cMsjError = 'GENERACION DE REPORTES DE  CREDITO'; 

		/* ELIMINAR REGISTROS PROCESADOS */
		TRUNCATE TABLE bdicred:"informix".sd_ri_archivos_aux;			-- RQI 28 194
		TRUNCATE TABLE bdicred:"informix".sd_ri_rangorecompensa_aux;	-- RQI 28 194
		TRUNCATE TABLE bdicred:"informix".sd_ri_altarecompensa_aux;		-- RQI 28 194

		--- CampaÃ±as
		LET cCons1 = "SELECT * FROM sd_ri_carga_altarecompensa_historico WHERE FECHA_PROCESO >= TODAY;";

		--- Creditos
		LET cCons2 = "SELECT * FROM  sd_ri_carga_archivos_historico WHERE  fecha_proceso >= TODAY;" ;
				
		--- Reportes Salida
		LET pArchDescarga  = cnom_Sql; 
		LET pArchDescarga2 = cnom_Sql2;
		--LET cRuta =  '/informix/PLL/RI/';
		LET cnom_Sql = 'salida_recompensa.sql';
		LET cnom_Sql2 = 'salida_creditos.sql';
		LET cSQL1 = '">'||TRIM(cRuta)|| cnom_Sql;
		LET cSQL2 = '">'||TRIM(cRuta)|| cnom_Sql2;
		
		LET pArchDescarga = TRIM(pArchDescarga)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
		LET cQuery = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(cRuta)||TRIM(pArchDescarga)||" delimiter '|'  "||TRIM(cCons1) || "" || cSQL1;
		SYSTEM TRIM(cQuery);

		LET cQuery='chmod 777 '|| TRIM(cRuta)|| cnom_Sql;
		System cQuery;

		LET cQuery = 'dbaccess bdicred ' || TRIM(cRuta) || cnom_Sql;
		SYSTEM cQuery;
		
		LET cSQL = '';
		LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cnom_Sql);
		SYSTEM cSQL;

		--- Reporte creditos 		

		LET pArchDescarga2 = TRIM(pArchDescarga2)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
		LET cQuery2 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(cRuta) ||TRIM(pArchDescarga2)||" delimiter '|'  "||TRIM(cCons2) || "" || cSQL2;
		SYSTEM TRIM(cQuery2);

		LET cQuery2='chmod 777 '|| TRIM(cRuta)|| cnom_Sql2;
		System cQuery2;

		LET cQuery2 = 'dbaccess bdicred ' || TRIM(cRuta) || cnom_Sql2;
		System cQuery2;		

		LET cMsjError = "REPORTE GENERADO OK";

		LET cSQL2 = '' ;
		LET cSQL2 = 'rm ' || TRIM(cRuta) || TRIM(cnom_Sql2);
		SYSTEM cSQL2;

		--RETURN cCodRet,cMsjError;
		RETURN cCodRet;
	END
END PROCEDURE;