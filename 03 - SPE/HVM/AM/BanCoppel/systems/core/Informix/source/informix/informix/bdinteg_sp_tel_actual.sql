CREATE PROCEDURE "informix".sp_tel_actual( pEmpresa     CHAR(3),
                                           pNumCte      CHAR(20), 
                                           pTelefono    CHAR(13), 
                                           pTipoTel    	SMALLINT,
                                           pStatusTel  	CHAR(1), 
                                           pSecuencia   SMALLINT, 
                                           pExtension   CHAR(5),
                                           pCarrier     SMALLINT,
                                           pCanal       SMALLINT,
                                           pContacto    SMALLINT, 
                                           pCofetel     CHAR(1), 
                                           pFechaHora  	CHAR(23),
                                           pUserInsert 	CHAR(8) )										   
    --DEFINICION DE VARIABLES
    DEFINE cCodRet1     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr     	INTEGER;
    DEFINE iExisteTel  	INTEGER;
    DEFINE cMovilFijo   CHAR(1);
    DEFINE cStatusTel   CHAR(1);
	DEFINE v_tel_confirmado CHAR(1);
	DEFINE vfech_confirmado DATE;
    
	--INICIALIZACION DE VARIABLES
    LET cCodRet1    = '000';
    LET iSqlErr	    = 0;
    LET iSamErr    	= 0;
    LET iExisteTel 	= 0;
    LET cMovilFijo 	= '0';
    LET cStatusTel 	= '';
 	LET v_tel_confirmado = '';
	LET vfech_confirmado = '';
	
	--SET DEBUG FILE TO "/tmp/sp_tel_actual.out";
    --TRACE ON;
    
    BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
				LET cCodRet1 = iSqlErr;
			END IF;
		END EXCEPTION;  

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		SELECT numcte
		  INTO iExisteTel
		  FROM "informix".si_telefonos_actual
		 WHERE numcte = pNumCte
		   AND tipo_tel = pTipoTel;
		
		SELECT movil_fijo,status_stel 
		INTO cMovilFijo, cStatusTel 
		FROM "informix".si_telefonos 
		WHERE numcte = pNumCte AND telefono = pTelefono
		AND tipo_tel = pTipoTel AND secuencia = pSecuencia;
		
		IF iExisteTel > 0 THEN
			UPDATE "informix".si_telefonos_actual
			   SET telefono    = pTelefono,
				   status_tel  = pStatusTel,
				   secuencia   = pSecuencia,
				   extension   = pExtension,
				   carrier     = pCarrier,
				   canal       = pCanal,
				   contacto    = pContacto,
				   cofetel     = pCofetel,
				   fecha_hora  = pFechaHora,
				   user_insert = pUserInsert,
				   movil_fijo  = cMovilFijo,
				   status_stel = cStatusTel
			 WHERE numcte = pNumCte
			   AND tipo_tel = pTipoTel;
		ELSE
			INSERT INTO "informix".si_telefonos_actual
			( empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado)
			VALUES
			( pEmpresa, pNumCte, pTelefono, pTipoTel, pStatusTel, pSecuencia, pExtension, pCarrier, pCanal, pContacto, pCofetel, pFechaHora, pUserInsert, cMovilFijo, cStatusTel, v_tel_confirmado, vfech_confirmado);
		END IF;    
		
		IF EXISTS (SELECT numcte FROM bdisolic:"informix".ss_adn_solicitudcuenta WHERE numcte =pNumCte AND num_solicitud <> '') AND pTipoTel = 2 THEN
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET movil_cuenta = ptelefono ,
			compania = pcarrier
			WHERE numcte =pNumCte;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_12' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', ptelefono, 0, 0,0, 0, 0, current, current) INTO cCodRet1;	
				
		END IF;
		
    END;
END PROCEDURE
DOCUMENT
'Modifico: Claudio Almodovar',
'Fecha: 19/04/2013',
'BDD: bdinteg',
'Descripcion: Se modifica UPDATE E INSERT para agregar parametros cMovilFijo, cStatusTel';

CREATE PROCEDURE "informix".sp_get_indicadores_sms(dFechaProceso DATE, cTipoRp CHAR(2),  iIdRp INTEGER)
	
	DEFINE cCodRet	CHAR(6);
	DEFINE cMensaje	CHAR(100);
	DEFINE iSqlErr 	INTEGER;
	DEFINE iSamErr	INTEGER;
	
	DEFINE cProceso	CHAR(100);
	DEFINE cEvento	CHAR(100);
	
	DEFINE iSms_no_val	INTEGER;
	DEFINE iSms_total	INTEGER;
	DEFINE iSms_val		INTEGER;
	DEFINE cFlag		CHAR(1);
	
	DEFINE bEnTransaccion	BOOLEAN;
		
	LET cCodRet = '000000';	
	LET cMensaje = 'PROCESO EXITOSO';
	
	LET iSms_no_val = 0;
	LET iSms_total = 0;
	LET iSms_val = 0;
	LET cFlag = '';
	
	LET bEnTransaccion = 'f';
	
	--SET DEBUG FILE TO '/tmp/josea/64171/sp_get_indicadores_sms.out';
	--TRACE ON;		
	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cMensaje
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
				
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
					LET bEnTransaccion = 'f';
				END IF;
				
				UPDATE si_controlproc_indicadores
				SET fecha_cargafin = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), 
					maxfecha_cargada = '',
					flagfinalizado = 'F',
					coderror = cCodRet, 
					msgerror = cMensaje
				WHERE tipo = cTipoRp 
					AND  id_proc = iIdRp
					AND fecha_procesoIni = dFechaProceso 
					AND fecha_procesoFin = dFechaProceso;
					
				INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (dFechaProceso, cProceso, cEvento, cCodRet, cMensaje);				
			END IF;
		END EXCEPTION;
		
		SELECT nombre_proceso 
		INTO cProceso
		FROM si_proc_indicadores
		WHERE tipo = cTipoRp AND identificador = iIdRp;
		
		LET cEvento = 'VALIDACION DE PARAMETROS';
		
		IF NVL(dFechaProceso,' ') = ' ' THEN
			LET cCodRet = '000001';
			LET cMensaje = 'FECHA INVALIDA';
		ELIF NVL(cTipoRp,' ') = ' ' THEN
			LET cCodRet = '000002';
			LET cMensaje = 'TIPO INDICADOR INVALIDO';
		ELIF NVL(iIdRp,0) = 0 THEN
			LET cCodRet = '000003';
			LET cMensaje = 'ID INDICADOR INVALIDO';
		ELIF NOT EXISTS (SELECT 1 FROM si_proc_indicadores WHERE  tipo = cTipoRp AND  identificador = iIdRp) THEN
			LET cCodRet = '000004';
			LET cMensaje = 'INDICADOR NO REGISTRADO EN SI_PROC_INDICADORES';	
		ELIF EXISTS (SELECT 1 FROM si_proc_indicadores WHERE estatus_proceso = 'I' AND tipo = cTipoRp AND  identificador = iIdRp) THEN
			LET cCodRet = '000005';
			LET cMensaje = 'INDICADOR INACTIVO';
		END IF;
		
		LET cEvento = 'CONSULTA ESTATUS EN SI_CONTROLPROC_INDICADORES';
		SELECT flagfinalizado INTO  cFlag
		FROM  si_controlproc_indicadores 
		WHERE tipo = cTipoRp AND id_proc = iIdRp AND fecha_procesoIni = dFechaProceso AND fecha_procesoFin = dFechaProceso;

		IF NVL(cFlag,'') = '' THEN
			INSERT INTO si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
			VALUES (dFechaProceso, dFechaProceso, cTipoRp, iIdRp, NVL(cProceso,''), (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), NULL, NULL, 'F', NULL, NULL );
		END IF;
		
		IF cCodRet::INTEGER = 0 THEN
			BEGIN WORK;
				LET bEnTransaccion = 't';
								
				--IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_estadistica_sms WHERE fecha = dFechaproceso) THEN
				
				LET cEvento = 'VALIDACION DE TABLA TEMPORAL';
					
				IF NOT EXISTS(SELECT 1 FROM si_tmp_telefonos WHERE fecha = dFechaproceso) THEN
					LET cEvento = 'GENERACION DE INFORMACION TEMPORAL';
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					INSERT INTO si_tmp_telefonos
					SELECT {+INDEX (bdinteg:"informix".si_telefonos idx_fecha_tel )} *, dFechaproceso::DATE AS fecha
					FROM si_telefonos
					WHERE fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND);
				END IF;
					
				LET cEvento = 'OBTENCION DE INDICADORES EN SI_TELEFONOS';
				
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				SELECT COUNT(*) AS sms_val
				INTO iSms_val 
				FROM bdinteg:si_tmp_telefonos WHERE telefono IN (SELECT {+INDEX (bdimnsj:"informix".mnsjr_trx_online inx_fh_idmsg)} celular_alterno 			
															 FROM bdimnsj:"informix".mnsjr_trx_online 
															 WHERE id_mensaje = 'OFI_AVSMS' 
															 AND fecha_hora_registro BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND))
				AND tipo_tel='2' 
				AND verificado='V' 
				AND fecha = dFechaproceso;
				
				--SI_TELEFONOS_ACTUAL
				LET cEvento = 'OBTENCION DE INDICADORES EN SI_TELEFONOS_ACTUAL';
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;			
				SELECT COUNT(*) AS sms_total
				INTO iSms_total 
				FROM bdinteg:si_telefonos_actual WHERE telefono IN (SELECT {+INDEX (bdimnsj:"informix".mnsjr_trx_online inx_fh_idmsg)} celular_alterno 
																	FROM bdimnsj:"informix".mnsjr_trx_online 
																	WHERE id_mensaje = 'OFI_AVSMS' 
																	AND fecha_hora_registro BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)) 
				AND cofetel='V' 
				AND tipo_tel='2' 
				AND fecha_hora::DATE=dFechaproceso; 
					
				LET iSms_no_val = iSms_total - iSms_val;
				
				IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_estadistica_sms WHERE fecha = dFechaproceso) THEN	
					LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_SMS';
					INSERT INTO bdinteg:"informix".si_estadistica_sms(fecha, sms_val, sms_no_val, total, porc_val, porc_no_val, user_insert, fecha_insert)
					VALUES (dFechaproceso, iSms_val, iSms_no_val, iSms_total, NVL(((NULLIF(iSms_val,0)/ NULLIF(iSms_total,0))*100),0), NVL(((NULLIF(iSms_no_val,0)/ NULLIF(iSms_total,0))*100),0), USER, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));
				ELSE
					LET cEvento = 'ACTUALIZACION DE INDICADORES EN SI_ESTADISTICA_SMS';
					UPDATE bdinteg:si_estadistica_sms
					SET sms_val = iSms_val, 
						sms_no_val = iSms_no_val, 
						total = iSms_total, 
						porc_val = NVL(((NULLIF(iSms_val,0)/ NULLIF(iSms_total,0))*100),0), 
						porc_no_val =  NVL(((NULLIF(iSms_no_val,0)/ NULLIF(iSms_total,0))*100),0),
						fecha_insert = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals)
					WHERE fecha = dFechaproceso;
				END IF;

			COMMIT WORK;
			LET bEnTransaccion = 'f';
		END IF;

		UPDATE si_controlproc_indicadores
		SET fecha_cargafin = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), 
			maxfecha_cargada = DECODE (cCodRet,'000000',dFechaProceso,NULL),
			flagfinalizado = DECODE (cCodRet,'000000','V','F'),
			coderror = cCodRet, 
			msgerror = cMensaje
		WHERE tipo = cTipoRp 
			AND  id_proc = iIdRp
			AND fecha_procesoIni = dFechaProceso 
			AND fecha_procesoFin = dFechaProceso;
	END;
END PROCEDURE;