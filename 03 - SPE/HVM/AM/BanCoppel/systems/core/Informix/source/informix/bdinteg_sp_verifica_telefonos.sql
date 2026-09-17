CREATE PROCEDURE "informix".sp_verifica_telefonos()
	RETURNING	CHAR(5)	AS cCodRet,
				CHAR(10) AS cRegOnlineHis,
				CHAR(10) AS cRegOnline,
				CHAR(10) AS cRegTel;
    
	--DEFINICION DE VARIABLES
    DEFINE cCodRet		 CHAR(5);
    DEFINE iSqlErr  	 INTEGER;
    DEFINE cTelefono	 CHAR(10);
	DEFINE cRegOnlineHis INTEGER;
	DEFINE cRegOnline    INTEGER;
    DEFINE cRegTel       INTEGER;
	DEFINE vsCont 		 INTEGER;
	
	
	
	
	LET cCodRet			= '00000';
    LET iSqlErr			= 0;
    LET cTelefono		= 0;
	LET cRegOnlineHis 	= 0;
	LET cRegOnline    	= 0;
	LET cRegTel       	= 0;
	LET vsCont 			= 0;
	
	--SET DEBUG FILE TO "/tmp/sp_registra_telefonos.out";
	--TRACE ON;
	
    BEGIN
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cRegOnlineHis,cRegOnline,cRegTel;
			END IF;
		END EXCEPTION;
    
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
		
			IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'si_tmptelefonos_cel') THEN
				DROP TABLE  "informix".si_tmptelefonos_cel;            
			END IF;
			
			-- Se crea tabla temporal de trabajo
			CREATE TABLE "informix".si_tmptelefonos_cel( telefono	CHAR(13));
		 
			--Conteo de telefonos en tabla historica
			SELECT {+INDEX(bdimnsj:"informix".mnsjr_trx_online_his inx_hora_registro_his)} COUNT(*) INTO cRegOnlineHis FROM
			bdimnsj:"informix".mnsjr_trx_online_his
			WHERE id_mensaje = 'OFI_AVSMS' AND estatus = '1' AND fecha_hora_registro = fecha_hora_registro;
			
			--Conteo de telefonos en tabla online
			SELECT {+INDEX(bdimnsj:"informix".mnsjr_trx_online inx_hora_registro)} COUNT(*) INTO cRegOnline FROM
			bdimnsj:"informix".mnsjr_trx_online
			WHERE id_mensaje = 'OFI_AVSMS' AND estatus = '1' AND fecha_hora_registro = fecha_hora_registro;
			
			
			FOREACH 
				SELECT {+INDEX(bdimnsj:"informix".mnsjr_trx_online_his inx_hora_registro_his)} DISTINCT(celular_alterno) INTO cTelefono 
				FROM bdimnsj:"informix".mnsjr_trx_online_his
				WHERE id_mensaje = 'OFI_AVSMS'
				AND estatus = '1'
				AND fecha_hora_registro = fecha_hora_registro
				
				INSERT INTO "informix".si_tmptelefonos_cel(telefono) VALUES(cTelefono);
				
				LET vsCont = vsCont + 1;
				
				IF vsCont = 1000 THEN
					COMMIT WORK;
					LET vsCont = 0;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
		
			IF vsCont < 1000 and vsCont > 0 THEN
				COMMIT WORK;
				LET vsCont = 0;
				BEGIN WORK;
			END IF;
			
			FOREACH
				SELECT {+INDEX(bdimnsj:"informix".mnsjr_trx_online inx_hora_registro)} DISTINCT(celular_alterno) INTO cTelefono 
				FROM bdimnsj:"informix".mnsjr_trx_online
				WHERE id_mensaje = 'OFI_AVSMS'
				AND estatus = '1'
				AND fecha_hora_registro = fecha_hora_registro
				
				INSERT INTO "informix".si_tmptelefonos_cel(telefono) VALUES(cTelefono);
				
				LET vsCont = vsCont + 1;
				
				IF vsCont = 1000 THEN
					COMMIT WORK;
					LET vsCont = 0;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
		
			IF vsCont < 1000 and vsCont > 0 THEN
				COMMIT WORK;
				LET vsCont = 0;
				BEGIN WORK;
			END IF;
			
			
			FOREACH
				
				SELECT DISTINCT(telefono) INTO cTelefono
				FROM "informix".si_tmptelefonos_cel
				
				UPDATE bdinteg:si_telefonos SET verificado = 'V',fecha_actualiza=current
				WHERE tipo_tel = '2'
				AND cofetel = 'V'
				AND telefono = cTelefono;
				
				LET vsCont = vsCont + 1;
				LET cRegTel = cRegTel + 1;
				
				IF vsCont = 1000 THEN
					COMMIT WORK;
					LET vsCont = 0;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
		
			IF vsCont < 1000 and vsCont > 0 THEN
				COMMIT WORK;
			END IF;

							
			DROP TABLE "informix".si_tmptelefonos_cel;
			
			RETURN cCodRet,cRegOnlineHis,cRegOnline,cRegTel;
		
	END;
END PROCEDURE
;