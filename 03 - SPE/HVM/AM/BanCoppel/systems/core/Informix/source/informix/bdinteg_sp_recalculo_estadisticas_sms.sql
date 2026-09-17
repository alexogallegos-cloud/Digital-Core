CREATE PROCEDURE "informix".sp_recalculo_estadisticas_sms(dfecha_ini DATE, dfecha_fin DATE)
RETURNING CHAR(6), CHAR(100);
--VARIABLES DE ERROR
DEFINE cVarDataErr      	CHAR(100);
DEFINE iSqlErr          	INTEGER;
DEFINE iSamErr          	INTEGER;
DEFINE vCodRet          	CHAR(6);
--DEFINICION DE VARIABLES			
DEFINE isms_val				INTEGER;
DEFINE isms_total			INTEGER;
DEFINE isms_no_val			INTEGER;
DEFINE ivalidos				INTEGER;
DEFINE iinvalidos			INTEGER;
DEFINE isin_validar			INTEGER;
--ASIGNACION DE VARIABLES
LET isms_val=0;				
LET isms_total=0;	
LET isms_no_val=0;	
LET ivalidos=0;			
LET iinvalidos=0;
LET isin_validar=0;

--ASIGNACION DE VARIABLES ERROR
LET vCodRet = '000000';
LET cVarDataErr = 'EL RECALCULO DE ESTADISTICAS DE SMS FUE REALIZADO SATISFACTORIAMENTE';
--SET DEBUG FILE TO '/informix/Ingrid/sp_recalculo_estadisticas_sms.out';
--TRACE ON;
BEGIN
	--Manejo del error
	ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
			LET vCodret=iSqlErr;			
			ROLLBACK;
						
			RETURN vCodret, iSamErr || ' ' ||cVarDataErr;
		END IF;
	END EXCEPTION;
			
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

	
--Estadisticas de SMS
	BEGIN WORK;
		WHILE dfecha_ini <= dfecha_fin
			--SI_TELEFONOS 
			SELECT COUNT(*) AS sms_val
			INTO isms_val 
			FROM bdinteg:si_telefonos WHERE telefono IN (
			SELECT celular_alterno 
			FROM bdimnsj:"informix".mnsjr_trx_online_his 
			WHERE id_mensaje = 'OFI_AVSMS' 
			AND fecha_hora_registro::DATE = dfecha_ini)
			AND tipo_tel='2' AND verificado='V' AND fecha_hora::DATE = dfecha_ini;		
				
			--SI_TELEFONOS_ACTUAL		
			SELECT COUNT(*) AS sms_total
			INTO isms_total 
			FROM bdinteg:si_telefonos_actual WHERE telefono IN (
			SELECT celular_alterno 
			FROM bdimnsj:"informix".mnsjr_trx_online_his 
			WHERE id_mensaje = 'OFI_AVSMS' 
			AND fecha_hora_registro::DATE = dfecha_ini) 
			AND cofetel='V' AND tipo_tel='2' AND fecha_hora::DATE=dfecha_ini; 
			
			LET isms_no_val = isms_total - isms_val;		
			--INSERTA EN LA TABLA DE SMS.
			UPDATE bdinteg:"informix".si_estadistica_sms 
			SET sms_val= isms_val, sms_no_val= isms_no_val, total= isms_total, porc_val = NVL(((NULLIF(isms_val,0)/ NULLIF(isms_total,0))*100),0) , porc_no_val = NVL(((NULLIF(isms_no_val,0)/ NULLIF(isms_total,0))*100),0)
			WHERE fecha = dfecha_ini;
			LET dfecha_ini = dfecha_ini + 1 UNITS DAY;
		END WHILE;
	
	COMMIT WORK;
	
	RETURN vCodRet,cVarDataErr;		
END;
END PROCEDURE
DOCUMENT
'REALIZA:Recalculo de estadisticas de sms',
'EQUIPO:Análisis y diseño de Mannto.4',
'FECHA:02/16/2015',
'SOLICITA:José Ángel López Adams',
'BASE DE DATOS:Bdinteg',
'MODIFICO: Ingrid Pamela Cázarez Villegas',
'DESCRIPCION: Se recalculan las estadisticas de sms de la tabla si_estadistica_sms en el rango de fechas recibido como parametros';

CREATE PROCEDURE "informix".sp_refusiona_telefonos()
RETURNING CHAR(6), CHAR(100);
	DEFINE cCodRet			CHAR(6);
	DEFINE cErrorSQL		CHAR(100);
	DEFINE i_SqlError		INTEGER;
	DEFINE i_iSamError		INTEGER;
	
	DEFINE cCliente_tit		CHAR(20);
	DEFINE cCliente_tras	CHAR(20);
		
	DEFINE iContador		INTEGER;
	DEFINE iContador2		INTEGER;
	DEFINE iMaxSecuencia	INTEGER;
	DEFINE iTrans_abierta	INTEGER;
	DEFINE iTotalReg		INTEGER;
	DEFINE iProcesados		INTEGER;
	DEFINE MAXTRANSACCION	INTEGER;
	
	DEFINE iROWID			INTEGER;
	DEFINE iROWDIDAux		INTEGER;
	DEFINE cTelefono		CHAR(20);
	DEFINE cTelefonoAux		CHAR(20);
	DEFINE iSecuencia		INTEGER;
	DEFINE iSecuenciaAux	INTEGER;
	DEFINE cTipo_tel		CHAR(1);
	DEFINE cTipo_telAux		CHAR(1);
	DEFINE dFecha_Proceso	DATE;
	
	DEFINE c_detalle_mov	CHAR(200);
	
	DEFINE dtFechaInsercion	DATETIME HOUR TO FRACTION;
	
	LET iContador = 0;
	LET iContador2 = 0;
	LET iMaxSecuencia = 0;
	LET cCliente_tit = '';
	LET cCliente_tras = '';
	LET cCodRet = '000000';
	LET MAXTRANSACCION = 3000;	
	LET iProcesados = 0;
	LET iTotalReg= 0;
	LET iTrans_abierta= 0;
	LET cErrorSQL = 'PROCESO TERMINADO SATISFACTORIAMENTE';
	
	--SET DEBUG FILE TO "/informix/josea/sp_refusiona_direcciones.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET i_SqlError,i_iSamError, cErrorSQL
			IF i_SqlError <> 0 THEN				
				IF iTrans_abierta = 1 THEN
					ROLLBACK WORK;
				END IF;
				
				LET cCodRet = i_SqlError;
				SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
				
				LET c_detalle_mov=i_SqlError||'|'||i_iSamError;
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES ("TELEFONOS","si_telefonos",cCliente_tit,cCliente_tras,c_detalle_mov,dtFechaInsercion,USER,dtFechaInsercion::DATE);
				
				IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
					DROP TABLE tmpfusionados;
				END IF;	
				
				RETURN cCodRet, cErrorSQL;
			END IF;
		END EXCEPTION;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
			DROP TABLE tmpfusionados;
		END IF;	
		
		SELECT cliente_tit, cliente_tras, fecha_proceso
		FROM bdinteg:si_fusionaut
		WHERE estatus = '1'
		AND cliente_tit IN(SELECT numcte FROM bdinteg:si_telefonos_actual WHERE status_tel = 'C')
		UNION ALL
		SELECT cliente_titular AS cliente_tit, cliente_traspasar AS cliente_tras, fecha_fusion::DATE AS fecha_proceso
		FROM bdinteg:si_fusbitacora
		WHERE fusion = 'SI'
		AND cliente_titular IN(SELECT numcte FROM bdinteg:si_telefonos_actual WHERE status_tel = 'C')
		INTO TEMP tmpfusionados WITH NO LOG;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
			SELECT COUNT(cliente_tit) INTO iTotalReg FROM tmpfusionados;
		END IF;	
				
		IF iTotalReg > 0 THEN		
			FOREACH WITH HOLD
				SELECT DISTINCT cliente_tit, cliente_tras, fecha_proceso
				INTO cCliente_tit, cCliente_tras, dFecha_Proceso
				FROM tmpfusionados
				ORDER BY fecha_proceso
				
				DELETE FROM bdinteg:si_fustelefonos2 
					WHERE numcte = cCliente_tit;
				
				LET iContador = 0;
				LET iContador2 = 0;			
				
				IF iProcesados = 0 THEN
					BEGIN WORK;
					LET iTrans_abierta = 1;
				END IF;				
				
				IF EXISTS (SELECT numcte FROM bdinteg:si_fustelefonos WHERE numcte = cCliente_tras) THEN				
					
					SELECT NVL(MAX(secuencia),0) 
					INTO iMaxSecuencia 
					FROM bdinteg:si_fustelefonos
					WHERE numcte = cCliente_tras;
					
					IF iMaxSecuencia > 0 THEN
						FOREACH
							SELECT ROWID, telefono,tipo_tel,secuencia
							INTO iROWID, cTelefono,cTipo_tel,iSecuencia
							FROM bdinteg:si_fustelefonos
							WHERE numcte = cCliente_tras 
							ORDER BY secuencia
							
							IF iContador = 0 THEN						
								LET cTelefonoAux = cTelefono;
								LET cTipo_telAux = cTipo_tel;
								LET iSecuenciaAux = iSecuencia;
								
								LET iContador = iContador + 1;								
								LET iROWDIDAux = iROWID;
								
								INSERT INTO bdinteg:si_fustelefonos2(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
								SELECT empresa, cCliente_tit AS numcte,telefono,tipo_tel,'A',secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel,verificado, marcatel, fecha_actualiza
								FROM bdinteg:si_fustelefonos
								WHERE ROWID = iROWDIDAux
									AND numcte = cCliente_tras 
									AND secuencia = iSecuencia;

							ELSE
								LET cTelefonoAux = cTelefono;
								LET cTipo_telAux = cTipo_tel;
								LET iSecuenciaAux = iSecuencia;
								LET iROWDIDAux = iROWID;
								
								LET iContador2 = iContador2 + 1;

								IF NOT EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = cCliente_tit AND telefono = cTelefono AND tipo_tel = cTipo_tel ) THEN
									IF EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = cCliente_tit  AND tipo_tel = cTipo_tel) THEN
										UPDATE bdinteg:si_fustelefonos2 SET status_tel = 'C' 
										WHERE numcte = cCliente_tit 
											AND tipo_tel = cTipo_tel;									
									END IF;
									
									INSERT INTO bdinteg:si_fustelefonos2(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
									SELECT empresa, cCliente_tit AS numcte,telefono,tipo_tel,'A',(SELECT NVL(MAX(secuencia),0)+1 FROM si_fustelefonos2 WHERE numcte = cCliente_tit ) AS secuencia, extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza       
									FROM bdinteg:si_fustelefonos
									WHERE ROWID = iROWDIDAux
										AND numcte = cCliente_tras 
										AND secuencia = iSecuencia;					
								END IF;

								LET iContador = iContador + 1;
							END IF; --If contador
						END FOREACH; --Consulta telefonos cCliente_tras
						
						LET iContador = 0;
						LET iContador2 = 0;
						
						SET ISOLATION TO DIRTY READ;
						
						FOREACH
							SELECT ROWID, telefono,tipo_tel,secuencia
							INTO iROWID, cTelefono,cTipo_tel,iSecuencia
							FROM bdinteg:si_fustelefonos
							WHERE numcte = cCliente_tit 
							ORDER BY secuencia
							
							IF iContador=0 THEN
								LET iROWDIDAux = iROWID;
								LET cTelefonoAux = cTelefono;
								LET cTipo_telAux = cTipo_tel;
								LET iSecuenciaAux = iSecuencia;								
								
								LET iContador = iContador + 1;
								
								IF NOT EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = cCliente_tit AND telefono = cTelefono AND tipo_tel = cTipo_tel) THEN
									IF EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = cCliente_tit  AND tipo_tel = cTipo_tel) THEN
										UPDATE bdinteg:si_fustelefonos2 SET status_tel = 'C' 
										WHERE numcte = cCliente_tit 
											AND tipo_tel = cTipo_tel;
									END IF;
								
									INSERT INTO bdinteg:si_fustelefonos2(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
									SELECT empresa,numcte,telefono,tipo_tel,'A',(SELECT NVL(MAX(secuencia),0)+1 FROM si_fustelefonos2 WHERE numcte = cCliente_tit ) AS secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza    
									FROM bdinteg:si_fustelefonos
									WHERE ROWID = iROWID
									AND numcte = cCliente_tit 
									AND secuencia = iSecuencia;								
								END IF;
							ELSE
								LET cTelefonoAux = cTelefono;
								LET cTipo_telAux = cTipo_tel;
								LET iSecuenciaAux = iSecuencia;
								LET iROWDIDAux = iROWID;
								
								LET iContador=iContador + 1;
								
								IF NOT EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = cCliente_tit AND telefono = cTelefono AND tipo_tel = cTipo_tel) THEN
									IF EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = cCliente_tit  AND tipo_tel = cTipo_tel) THEN
										UPDATE bdinteg:si_fustelefonos2 SET status_tel = 'C' 
										WHERE numcte = cCliente_tit 
											AND tipo_tel = cTipo_tel;
									END IF;

									INSERT INTO bdinteg:si_fustelefonos2(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
									SELECT empresa,numcte,telefono,tipo_tel,'A',(SELECT NVL(MAX(secuencia),0)+1 FROM si_fustelefonos2 WHERE numcte = cCliente_tit ) AS secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza         
									FROM bdinteg:si_fustelefonos
									WHERE ROWID = iROWDIDAux 
										AND numcte = cCliente_tit 
										AND secuencia = iSecuencia;
									
									LET iContador2 = iContador2 + 1;
								END IF;
							 END IF;
						END FOREACH;
						
						SET ISOLATION TO DIRTY READ;
						
						--Para considerar nuevos telefonos en si_telefonos que no se encuentren en si_fustelefonos
						FOREACH
							SELECT telefono,tipo_tel,secuencia
							INTO cTelefono, cTipo_tel, iSecuencia
							FROM bdinteg:si_telefonos
							WHERE numcte = cCliente_tit 
														
							IF NOT EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = cCliente_tit AND telefono = cTelefono AND tipo_tel = cTipo_tel) THEN
								IF EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = cCliente_tit  AND tipo_tel = cTipo_tel) THEN
									UPDATE bdinteg:si_fustelefonos2 SET status_tel = 'C' 
									WHERE numcte = cCliente_tit 
										AND tipo_tel = cTipo_tel;
								END IF;
								
								INSERT INTO bdinteg:si_fustelefonos2(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
								SELECT empresa,numcte,telefono,tipo_tel,'A',(SELECT NVL(MAX(secuencia),0)+1 FROM si_fustelefonos2 WHERE numcte = cCliente_tit ) AS secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza         
								FROM bdinteg:si_telefonos
								WHERE numcte = cCliente_tit 
									AND telefono = cTelefono 
									AND secuencia = iSecuencia;
							END IF;
						END FOREACH;
						
						DELETE FROM bdinteg:si_telefonos 
							WHERE numcte = cCliente_tit;
							
						DELETE FROM bdinteg:si_telefonos_actual 
							WHERE numcte = cCliente_tit;
						
						INSERT INTO bdinteg:si_telefonos(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
						SELECT empresa,numcte,telefono,tipo_tel,status_tel, secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza         
						FROM bdinteg:si_fustelefonos2
						WHERE numcte = cCliente_tit ;
						
						DELETE FROM si_fustelefonos2 WHERE numcte = cCliente_tit;
												
					END IF;	--Maxima Secuencia
				ELSE
					FOREACH 
						SELECT telefono,tipo_tel,secuencia
						INTO cTelefono, cTipo_tel, iSecuencia
						FROM bdinteg:si_telefonos
						WHERE numcte = cCliente_tit 
						
						IF NOT EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = cCliente_tit AND telefono = cTelefono AND tipo_tel = cTipo_tel) THEN
							IF EXISTS (SELECT telefono FROM bdinteg:si_fustelefonos2 WHERE numcte = cCliente_tit  AND tipo_tel = cTipo_tel) THEN
								UPDATE bdinteg:si_fustelefonos2 SET status_tel = 'C' 
								WHERE numcte = cCliente_tit 
									AND tipo_tel = cTipo_tel;
							END IF;
							
							INSERT INTO bdinteg:si_fustelefonos2(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
							SELECT empresa,numcte,telefono,tipo_tel,'A',(SELECT NVL(MAX(secuencia),0)+1 FROM si_fustelefonos2 WHERE numcte = cCliente_tit ) AS secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza         
							FROM bdinteg:si_telefonos
							WHERE numcte = cCliente_tit 
								AND telefono = cTelefono 
								AND secuencia = iSecuencia;
						END IF;
					END FOREACH;	
					DELETE FROM bdinteg:si_telefonos 
						WHERE numcte = cCliente_tit;
						
					DELETE FROM bdinteg:si_telefonos_actual 
						WHERE numcte = cCliente_tit;
					
					INSERT INTO bdinteg:si_telefonos(empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
					SELECT empresa,numcte,telefono,tipo_tel,status_tel, secuencia,extension,carrier,canal,contacto,cofetel,fecha_hora,user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza         
					FROM bdinteg:si_fustelefonos2
					WHERE numcte = cCliente_tit ;
					
					DELETE FROM si_fustelefonos2 WHERE numcte = cCliente_tit;
				END IF; --If exists cCliente_tras
												
				LET iProcesados = iProcesados + 1;
				
				IF iProcesados >= MAXTRANSACCION THEN
					LET iProcesados = 0;
					COMMIT WORK;
					LET iTrans_abierta = 0;
				END IF;
			END FOREACH;
			
			IF iProcesados < MAXTRANSACCION AND  iTotalReg > 0 THEN
				IF iProcesados > 0 THEN
					COMMIT WORK;
					LET iTrans_abierta = 0;
				END IF;
				LET iProcesados = 0;
			END IF;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
			DROP TABLE tmpfusionados;
		END IF;	

		RETURN cCodRet, cErrorSQL;
	END;
END PROCEDURE;