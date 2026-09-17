CREATE PROCEDURE "informix".sp_desencripta_folios_masivo(pnIdStatus SMALLINT)
RETURNING CHAR(5),CHAR(55);

	DEFINE vc_numcte CHAR(20);
	DEFINE vc_numcte_trim CHAR(20);
	DEFINE vc_folio_contrato CHAR(55);
	DEFINE vs_folio_claro CHAR(12);
	DEFINE vsCodRet  CHAR(5);
	DEFINE viSqlErr  SMALLINT;
	DEFINE vsMesage  CHAR(55);	

	
	
	LET vsCodRet = '00000';
	LET viSqlErr = 0;
	LET vsMesage = '';
	
	
	--SET DEBUG FILE TO '/informix/JuanRivera/Traces/sp_desenc_folio_masivo.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
    ON EXCEPTION SET viSqlErr
        IF viSqlErr <> 0 then
            LET vsCodRet = viSqlErr;
            RETURN vsCodRet,vsMesage;
        END IF;
    END EXCEPTION;
	
    IF pnIdStatus IS NULL THEN
	 
		LET vsMesage = 'Datos de entrada incorrectos';	
		RETURN vsCodRet, TRIM(vsMesage);	
	 
	END IF;
    --Campos con valor
        FOREACH  
			SELECT folio_contrato, numcte INTO vc_folio_contrato, vc_numcte
			FROM bdinteg:si_bpiusuarios
			WHERE id_status = pnIdStatus
			AND f_encriptado = TODAY
			AND length(folio_contrato) = 36  
		    
            EXECUTE PROCEDURE bdibpi:sp_desencripta_folio_contrato_bpi(vc_folio_contrato) INTO vsCodRet, vs_folio_claro;
					
					UPDATE bdinteg:si_bpiusuarios SET folio_contrato = vs_folio_claro, f_encriptado= NULL WHERE numcte = vc_numcte AND  id_status = pnIdStatus;
						
        END FOREACH;        

    LET vsMesage = 'Desncriptacion exitosa';	
    	
	RETURN vsCodRet, TRIM(vsMesage);	
	
	END;
END PROCEDURE
DOCUMENT
"Desencripta folio contrato",
"Autor : Juan Rivera",
"FECHA : 04/Oct/2022",
"Descripcion de la modificacion: DesencriptaciÃ³n de forma controlada los folios encriptados";

CREATE PROCEDURE "informix".sp_monitorear_indicadores_sucursal()
	RETURNING 
	CHAR(6), 
	CHAR(100);

	--Definicion de Variables
	DEFINE iSqlErr          	INTEGER;
	DEFINE iSamErr 				INTEGER;
	DEFINE cVarDataErr			CHAR(100);
	DEFINE cCodRet          	CHAR(6);
	
	DEFINE dfecha_alerta 		DATE;
	DEFINE iCorreopen 			INT;
	DEFINE iCorreoCap			INT;
	DEFINE iPorcentCorreo   	INT;
	DEFINE sCod_correoPen   	SMALLINT;
	DEFINE cCodRetSP        	CHAR(6);
	DEFINE cVarDataErrSP    	CHAR(100);
	DEFINE cProceso				CHAR(100);
	DEFINE cEvento				CHAR(100);
	DEFINE cCod_envCorreoPen    CHAR(50);
	DEFINE cFechaProcesar		CHAR(100);
	DEFINE sContFechasProc      SMALLINT;
	DEFINE dHoraInicio		DATETIME HOUR TO MINUTE; --Variables de tiempo
	DEFINE dCurrentTime		DATETIME HOUR TO MINUTE;
	DEFINE dMaxTime			INTEGER;
	DEFINE intervalo 		INTERVAL minute(9) TO MINUTE;
	DEFINE cadena 			VARCHAR(12);
	DEFINE entero 			INTEGER;
	
	--Inicializa Variables
	LET cCodRet = '000000';
	LET cVarDataErr = 'EJECUCION EXITOSA';
	LET dfecha_alerta 	= '';
	LET iCorreopen		= 0;
	LET iCorreoCap		= 0;
	LET iPorcentCorreo 	= 0;
	LET sCod_correoPen 	= 0;
	LET cProceso = '';
	LET cEvento = '';
	LET cCod_envCorreoPen = '';
	LET cCodRetSP		  = '';
	LET cVarDataErrSP     = '';
	LET cFechaProcesar    = '';
	LET sContFechasProc   = 0;
	LET dHoraInicio			= CURRENT hour to minute;
	LET dCurrentTime		= NULL;
	LET dMaxTime			= 120;
	
	--SET DEBUG FILE TO "/respaldosbd/Pedro/1509/sp_monitorear_indicadores_sucursal.out";
	--TRACE ON;
BEGIN
	--Manejo del error
	ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
			
			INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
			VALUES (CURRENT, cProceso, cEvento, cCodRet, cVarDataErr);
				
			RETURN cCodRet, iSamErr || ' ' ||cVarDataErr;
		END IF;
	END EXCEPTION;
			
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET cProceso = 'sp_monitorear_indicadores_sucursal';
	LET cEvento	= 'OBTENCIÓN DE ALARMAS ACTIVAS';

	SELECT valor 
	INTO sCod_correoPen
	FROM "informix".si_param 
	WHERE empresa='001'
	AND cod_param='377';
	
	SELECT valor 
	INTO cCod_envCorreoPen
	FROM "informix".si_param 
	WHERE empresa='001'
	AND cod_param='379';
	
	LET cEvento = 'RECALCULANDO DE INDICADORES';
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	FOREACH WITH HOLD 
	
		SELECT fecha 
		INTO dfecha_alerta
		FROM "informix".si_alertas_indicadores 
		WHERE activa= "V"
		GROUP BY fecha
	   
		
		-- SE ACTUALIZA LA FECHA MONITOREO DE TODAS LAS ALARMAS EVALUADAS.
		UPDATE "informix".si_alertas_indicadores SET fecha_ult_monitoreo = CURRENT WHERE fecha = dfecha_alerta;
		
		SELECT SUM(correo_pen),SUM(correo_cap) 
		INTO iCorreopen,iCorreoCap
		FROM "informix".si_indicadores_ctes_nvos 
		WHERE fecha = dfecha_alerta;
		
		IF NVL(iCorreopen, 0) = 0 OR NVL(iCorreoCap, 0) = 0 THEN
			LET iPorcentCorreo=0;
		ELSE
			LET iPorcentCorreo= (iCorreopen/iCorreoCap)*100;
		END IF;
		
		IF 	iPorcentCorreo >= sCod_correoPen THEN	--1509::DSB-Antonio Cebreros 
			LET cEvento	= 'EJECUCION DE SP sp_recalcula_indicadores_ctes';	
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			EXECUTE PROCEDURE "informix".sp_recalcula_indicadores_ctes(dfecha_alerta,dfecha_alerta)
			INTO cCodRetSP, cVarDataErrSP; 
			
			IF cCodRetSP = '000000' THEN
				--1509::DSB-Antonio Cebreros 
				SELECT SUM(correo_pen),SUM(correo_cap) 
				INTO iCorreopen,iCorreoCap
				FROM "informix".si_indicadores_ctes_nvos 
				WHERE fecha = dfecha_alerta;
				
				IF NVL(iCorreopen, 0) = 0 OR NVL(iCorreoCap, 0) = 0 THEN
					LET iPorcentCorreo=0;
				ELSE
					LET iPorcentCorreo= (iCorreopen/iCorreoCap)*100;
				END IF;
				
				--1509::DSB-Antonio Cebreros 				
				IF 	iPorcentCorreo < sCod_correoPen THEN	--1509::DSB-Antonio Cebreros 
					UPDATE "informix".si_alertas_indicadores SET activa = "F", fecha_cambio = CURRENT, fecha_ult_monitoreo = CURRENT 
					WHERE fecha = dfecha_alerta AND activa= "V";					
					--CONTINUE FOREACH;
				
				
					LET sContFechasProc=sContFechasProc + 1; 

					--1509::DSB-Antonio Cebreros 
					IF LENGTH (cFechaProcesar) < 1 THEN
						LET cFechaProcesar = SUBSTRING(dfecha_alerta FROM 7 FOR 4)||'/'||SUBSTRING(dfecha_alerta FROM 1 FOR 2) ||'/'||SUBSTRING(dfecha_alerta FROM 4 FOR 2);
					ELSE
						LET cFechaProcesar = TRIM(cFechaProcesar)||','||SUBSTRING(dfecha_alerta FROM 7 FOR 4)||'/'||SUBSTRING(dfecha_alerta FROM 1 FOR 2) ||'/'||SUBSTRING(dfecha_alerta FROM 4 FOR 2);
					END IF;				
					--1509::DSB-Antonio Cebreros 
					
					LET cEvento	= 'ENVÍO DE NOTIFICACIÓN DE INDICADORES RECALCULADOS.';	
					IF sContFechasProc = 9 THEN
					
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod('1', 'BI_EMAIL', 'NOT_BI',cCod_envCorreoPen, '','', '1', '','','','','','','','','', cFechaProcesar,'','',1,0,0,0,0,'','')
						INTO cCodRetSP;				 
				 
						LET cFechaProcesar = '';
						LET sContFechasProc = 0;
					
						IF cCodRetSP <> '00000' THEN
							LET cVarDataErr = 'sp_registra_evento';
							INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
							VALUES (CURRENT, cProceso, cEvento, cCodRetSP, cVarDataErr);
						END IF; 
					END IF;
				END IF;
			ELSE 
				
				LET cCodRet = cCodRetSP;
				LET cVarDataErr = cVarDataErrSP;
				INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (CURRENT, cProceso, cEvento, cCodRet, cVarDataErr);
			END IF;
			
		ELSE
		
			--1509::DSB-Antonio Cebreros 
			UPDATE "informix".si_alertas_indicadores SET activa = "F", fecha_cambio = CURRENT, fecha_ult_monitoreo = CURRENT 
			WHERE fecha = dfecha_alerta AND activa= "V";	
			
			LET sContFechasProc=sContFechasProc + 1; 

			
			IF LENGTH (cFechaProcesar) < 1 THEN
				LET cFechaProcesar = SUBSTRING(dfecha_alerta FROM 7 FOR 4)||'/'||SUBSTRING(dfecha_alerta FROM 1 FOR 2) ||'/'||SUBSTRING(dfecha_alerta FROM 4 FOR 2);
			ELSE
				LET cFechaProcesar = TRIM(cFechaProcesar)||','||SUBSTRING(dfecha_alerta FROM 7 FOR 4)||'/'||SUBSTRING(dfecha_alerta FROM 1 FOR 2) ||'/'||SUBSTRING(dfecha_alerta FROM 4 FOR 2);
			END IF;				
			
			
			LET cEvento	= 'ENVÍO DE NOTIFICACIÓN DE INDICADORES RECALCULADOS.';	
			IF sContFechasProc = 9 THEN
			
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1', 'BI_EMAIL', 'NOT_BI',cCod_envCorreoPen, '','', '1', '','','','','','','','','', cFechaProcesar,'','',1,0,0,0,0,'','')
				INTO cCodRetSP;				 
		 
				LET cFechaProcesar = '';
				LET sContFechasProc = 0;
			
				IF cCodRetSP <> '00000' THEN
					LET cVarDataErr = 'sp_registra_evento';
					INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
					VALUES (CURRENT, cProceso, cEvento, cCodRetSP, cVarDataErr);
				END IF; 
			END IF;
			
		END IF;
		
		--Se consulta el tiempo que lleva ejecutandose el proceso para detenerlo en caso de que haya llegado al limite establecido
		select 
		DBINFO('utc_to_datetime', sh_curtime) 
		into dCurrentTime
		from sysmaster:"informix".sysshmvals;
		
		LET intervalo= (dCurrentTime - dHoraInicio)::interval minute(9) to minute;
		LET cadena=intervalo::VARCHAR(12);
		LET entero=cadena::INTEGER;
		IF (entero >= dMaxTime) THEN
			--Se fuerza la terminación del for each por exceso de tiempo
			EXIT FOREACH;
		END IF;
		
	END FOREACH;
	
    -- SI HUBO FECHAS PENDIENTES Y SE DESACTIVO LA ALERTA ENVIAMOS LA NOTIFICACION	
	IF sContFechasProc > 0 AND sContFechasProc < 9  THEN
		LET cEvento	= 'ENVÍO DE NOTIFICACIÓN DE INDICADORES RECALCULADOS.';	
		
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1', 'BI_EMAIL', 'NOT_BI',cCod_envCorreoPen, '','', '1', '','','','','','','','','', cFechaProcesar,'','',1,0,0,0,0,'','')
		INTO cCodRetSP;				 

		IF cCodRetSP <> '00000' THEN
			LET cCodRet = cCodRetSP;
			LET cVarDataErr = 'sp_registra_evento';
			INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
			VALUES (CURRENT, cProceso, cEvento, cCodRetSP, cVarDataErr);
		END IF;		
	END IF;	
	RETURN cCodRet,cVarDataErr;		
END;
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1509-MonitoreoIndcSuc',
'DESCRIPCION: Obtiene las alertas generadas en la tabla si_alertas_indicadores, obtiene el porcentaje si es menor o igual al valor parametrizado, recalcular los indicadores y actualiza el campo activa y la fecha_ult_monitoreo.',
'FECHA: 06/11/2015',
'SUSTENTO: Se definio con Jose Angel López Adams en el requerimiento',
'RQI 64 123 - Monitoreo de indicadores de sucursal',
'BD: BDINTEG',
'MODIFICÓ: 96273763 - Antonio Cebreros Pérez',
'DESCRIPCIÓN: Se agregan validaciones para concatenación de fechas de correos pendientes a ser enviados y modificada validacion de porcentaje de correos pendientes.',
'BD: BDINTEG',
'MODIFICÓ: 90238760 - Uriel Amador Islas',
'DESCRIPCIÓN: Se agrega validación para que se ejecute en un tiempo máximo determinado de 2 hrs',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_capintafecha_ipab_esp( pCuenta CHAR(20), pFecha DATE )
RETURNING  CHAR(10), DECIMAL(14,2), DECIMAL(14,2);

    DEFINE cCodret      CHAR(5);
    DEFINE cCodret2     CHAR(5);
    DEFINE cCodret3     CHAR(50);
    DEFINE cSQL_ERR     INTEGER;
    DEFINE cISAM_ERR    INTEGER;
    DEFINE cDESC_ERR    CHAR(50);
    DEFINE vCapital     DECIMAL(14,2);
    DEFINE vInteres     DECIMAL(14,2);

    LET cCodret   = '000';
    LET cCodret2  = '';
    LET cCodret3  = '';
    LET cSQL_ERR  = 0;
    LET cISAM_ERR = 0;
    LET cDESC_ERR = '';
    LET vCapital  = 0.00;
    LET vInteres  = 0.00;

    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_capintafecha_ipab_esp.out';
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET cSQL_ERR, cISAM_ERR, cDESC_ERR
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_capintafecha_ipab_esp.err';
        TRACE ON;
        LET cCodret = cSQL_ERR;
        LET cCodret2 = cISAM_ERR;
        LET cCodret3 = cDESC_ERR;
        RETURN cCodret, vCapital, vInteres;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT saldook, saldo_act_int
      INTO vCapital, vInteres
      FROM bdinteg:tab_ipab_pba_pums
     WHERE cuenta = pCuenta
       AND fecha = pFecha;
    
    IF vCapital is null OR vInteres is null THEN
        -- // CUENTA NO EXISTE EN FECHA
        LET cCodret = '100'; 
        LET vCapital = 0.00;
        LET vInteres = 0.00;
    END IF;

    RETURN cCodret, vCapital, vInteres;

    END;

END PROCEDURE;