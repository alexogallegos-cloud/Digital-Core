CREATE PROCEDURE "informix".sp_actualizappspeiferiados (pAnio CHAR (4))
RETURNING
	CHAR (6) AS Codigo_retorno,
	CHAR (50) AS Mensaje_retorno;

----->>>> Declaración de variables <<<<-----
DEFINE cCodRet			CHAR (6);
DEFINE cMsgRet			CHAR (50);
DEFINE cPagoProg		CHAR (10);
DEFINE iConsecutivo		INTEGER;
DEFINE dFechaProg		DATE;
DEFINE cEstado			CHAR (2);
DEFINE dFechaInsert		DATE;
DEFINE iContador		INTEGER;
DEFINE iTotalReg		INTEGER;
DEFINE dFechaHabil		DATE;
DEFINE iSqlErr			INTEGER;
DEFINE cCodRet2			CHAR (3);
DEFINE iBandera			INTEGER;
DEFINE cCodRetBita		CHAR (5);
DEFINE dFechaIni		DATE;
DEFINE dFechaFin		DATE;
DEFINE dFechaAux		DATE;

----->>>> Inicialización de variables <<<<-----
LET cCodRet			= '000000';
LET cMsgRet			= '';
LET cPagoProg		= '';
LET iConsecutivo	= 0;
LET dFechaProg		= DATE (1);
LET cEstado			= '';
LET dFechaInsert	= DATE (1);
LET iContador		= 0;
LET iTotalReg		= 0;
LET dFechaHabil		= DATE (1);
LET iSqlErr			= 0;
LET cCodRet2		= '';
LET iBandera 		= 0;
LET cCodRetBita		= '';
LET dFechaIni		= DATE (1);
LET dFechaFin		= DATE (1);
LET dFechaAux		= DATE (1);

BEGIN
		-----Control de Errores de Informix
	ON EXCEPTION SET iSqlErr 
		IF iBandera = 1 THEN
			ROLLBACK WORK;
			LET iBandera = 0;
		END IF;
		
		IF iSqlErr <> 0 THEN
			IF iSqlErr = '-206' THEN
				LET cCodret = '000002';
				LET cMsgRet= 'Proceso fallo no existe tabla bitacora.';
			ELSE
				LET cCodret = '000003';
				LET cMsgRet= 'Error no controlado en informix'||' '||iSqlErr||'.';
			END IF
		
			IF cCodRet <> '000000' THEN
				LET cCodRetBita = SUBSTR (cCodret,2,5);
				
				IF iTotalReg > 0 THEN
				    LET cMsgRet = cMsgRet ||' Registros actualizados con exito: '||iTotalReg;
				END IF;
				
				INSERT INTO "informix".pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
				VALUES ('sp_actualizappspeiferiados', '', cCodRetBita, cMsgRet,USER, dFechaInsert, CURRENT HOUR TO SECOND);
			END IF;
		END IF;
		
		RETURN TRIM(cCodret), NVL(cMsgRet,'');
	END EXCEPTION 
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	------- Válidar parámetro -------
	IF NVL (pAnio,'') = '' THEN
		LET cCodret = '000005';
		LET cMsgRet = 'Parametro de entrada incorrecto.';
		RETURN TRIM(cCodret), NVL(cMsgRet,'');
	END IF;
	
	LET dFechaIni = mdy(1,1,pAnio);
	LET dFechaFin = mdy(12,31,pAnio);
	
	SELECT fecha_hoy
	INTO dFechaInsert
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = '001';
	
	FOREACH WITH HOLD

		SELECT a.cve_pagoprog, a.consecutivo, a.fecha_prog, a.estado
		INTO cPagoProg, iConsecutivo, dFechaProg, cEstado
		FROM "informix".pp_pagospend a
		INNER JOIN bdinteg:"informix".si_feriado b ON ( b.fecha = a.fecha_prog AND b.pais = '001' AND b.empresa = '001')
		INNER JOIN "informix".pp_pagoprog c ON (c.cve_pago = '03' AND  c.cve_pagoprog = a.cve_pagoprog)
		WHERE  a.estado = '03'
		AND a.cve_pagoprog >= '0'
		AND a.fecha_prog >= dFechaIni
		AND a.fecha_prog <= dFechaFin
		ORDER BY a.fecha_prog
		
		LET iContador = iContador + 1;
				
		IF iContador = 1 THEN
			BEGIN WORK;
			LET iBandera = 1;
		END IF		
		
	    -- CALCULA EL SIGUIENTE DIA HABIL DE LA FECHA INDICADA	
		IF dFechaProg <> dFechaAux THEN   
			EXECUTE PROCEDURE bdispei:"informix".sp_validafecha("001",dFechaProg )
			INTO cCodRet2, dFechaHabil;
			
			LET dFechaAux = dFechaProg;
			
			------ VALIDA SI VIENE CON ERROR EL sp_validafecha
			IF cCodRet2 <> '000' THEN
				
				ROLLBACK WORK;
				LET cCodRet = '000004'; 
				LET cMsgRet = 'Error no controlado en bdispei:"informix".sp_validafecha.';
				LET cCodRetBita = SUBSTR (cCodret,2,5);
				
				IF iTotalReg > 0 THEN
				    LET cMsgRet = cMsgRet ||' Registros actualizados con exito: '||iTotalReg;
				END IF;
				
				INSERT INTO "informix".pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
				VALUES ('sp_actualizappspeiferiados', '', cCodRetBita, cMsgRet,USER, dFechaInsert, CURRENT HOUR TO SECOND);
				
				RETURN TRIM(cCodret), NVL(cMsgRet,'');
			END IF
		END IF;
		
		----->>>>>Inserta información en la tabla
		INSERT INTO "informix".pp_pagospend_feriados (cve_pagoprog, consecutivo, fecha_prog, estado, fecha_insert, hora_insert)
		VALUES (cPagoProg, iConsecutivo, dFechaProg, cEstado, dFechaInsert, CURRENT HOUR TO SECOND);
		
		---->>>> ACTUALIZA LA FECHA PROGRAMADA AL SIGUIENTE DIA HÁBIL <<<<----
		UPDATE "informix".pp_pagospend
		SET fecha_prog = dFechaHabil
		WHERE cve_pagoprog= cPagoProg 
		AND consecutivo = iConsecutivo 
		AND fecha_prog = dFechaProg
		AND estado = '03';
		
		IF iContador = 1000 THEN
			COMMIT WORK;
			LET iBandera = 0;
			LET iTotalReg = iTotalReg + iContador;
			LET iContador = 0;
		END IF;
		
	END FOREACH;

	------->>>> Verifica si encontró algun registro.
	IF iContador = 0 AND iTotalReg = 0 THEN
		LET cCodret = '000001';
		LET cMsgRet = 'No se encontraron pagos SPEI en dias feriados.';
	ELSE 
		IF iContador > 0 THEN
			COMMIT WORK;
			LET iTotalReg = iTotalReg + iContador;
			LET iContador = 0;
			LET iBandera = 0;
		END IF;
		LET cCodret = '000000';
		LET cMsgRet = 'Proceso exitoso.';
	END IF;
		
	IF cCodret = '000000' THEN
		LET cCodRetBita = SUBSTR (cCodret,2,5);
		INSERT INTO "informix".pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
		VALUES ('sp_actualizappspeiferiados', '', cCodRetBita, TRIM(cMsgRet)||'  Registros actualizados: '||iTotalReg,USER, dFechaInsert, CURRENT HOUR TO SECOND);
	ELSE
		LET cCodRetBita = SUBSTR (cCodret,2,5);
		INSERT INTO "informix".pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
		VALUES ('sp_actualizappspeiferiados', '', cCodRetBita, TRIM(cMsgRet),USER, dFechaInsert, CURRENT HOUR TO SECOND);
	END IF;
	
	RETURN TRIM(cCodret), NVL(cMsgRet,'');
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: CAMBIA LOS DÍAS NO HÁBILES POR DIAS HÁBILES',
'FECHA DE CREACIÓN: 23-ABRIL-2013',
'BASE DE DATOS: BDIPROG',
'AUTOR: MARIO GAMALIEL OLIVO URIAS',
'VERSION: 20130423.1539';

CREATE PROCEDURE "informix".sp_aforecancelarprocejecpagos(p_NombreArchivo CHAR(24), p_Usuario CHAR(8), p_TipoMovimiento SMALLINT)

	RETURNING CHAR(6); --cod retorno
	--p_TipoMovimiento: 1.- Suspencion Temporal, 2.- Cancelacion(o suspencion definitiva)

	--Declaracion de variables
	DEFINE v_codret 	CHAR(6);
	DEFINE v_sqlerr 	INTEGER;
    DEFINE v_SamErr		INTEGER;
    DEFINE v_DesErr		CHAR(100);

	DEFINE v_fecha_hoy 	DATE;
	DEFINE v_Status		CHAR(2);
	DEFINE cNomProceso 	CHAR(10);

	--Set debug file to '/tmp/sp_AforeCancelarProcEjecPagos.out';
	--trace on;

	--Inicializacion de variables
	LET v_codret = "00000";
	LET v_sqlerr = 0;
	LET cNomProceso = '';

	BEGIN
	    ON EXCEPTION SET v_sqlerr, v_SamErr, v_DesErr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret;
	        END IF;
	    END EXCEPTION;

		--El procedimiento obtiene la fecha del sistema central.
		SELECT fecha_hoy INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = '001';
		
		IF p_TipoMovimiento = 1 THEN
			LET cNomProceso = 'AforeSus'||SUBSTR(p_NombreArchivo, 23, 2);
		END IF
		IF p_TipoMovimiento = 2 THEN
			LET cNomProceso = 'AforeCan'||SUBSTR(p_NombreArchivo, 23, 2);
		END IF 

		IF p_NombreArchivo = '' OR p_NombreArchivo IS NULL OR p_Usuario = '' OR p_Usuario IS NULL OR p_TipoMovimiento IS NULL THEN

			LET v_codret = '10015';	--Faltan parametros

			--El procedimiento guarda el error en bitacora del sistema.
			INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
			VALUES (cNomProceso, p_NombreArchivo, v_codret, 'Faltan parametros', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));

			RETURN v_codret;

		ELSE
			--El procedimiento valida que el proceso de recepción de archivo ya ha sido ejecutado.
			IF EXISTS (SELECT proceso FROM bdiprog:pp_procesos WHERE proceso = 'AforeVal'||SUBSTR(p_NombreArchivo, 23, 2) AND fech_proceso = v_fecha_hoy ) THEN
				--El procedimiento valida que el proceso de Cancelación de la Ejecución de Pagos Pendientes ya ha sido ejecutado.
				IF EXISTS (SELECT proceso FROM bdiprog:pp_procesos WHERE proceso = cNomProceso AND fech_proceso = v_fecha_hoy) THEN

					--El procedimiento recupera el satutus del proceso de Cancelación de la Ejecución de Pagos Pendientes
					SELECT NVL(status, '0')
					INTO v_Status
					FROM bdiprog:pp_procesos
					WHERE proceso = cNomProceso
						AND fech_proceso = v_fecha_hoy;

					--El procedimiento valida que el proceso de Cancelación de la Ejecución de Pagos Pendientes termino de manera incorrecta.
					IF v_Status = '1' THEN
						--Tipo de cancelación "Suspensión Temporal".
						IF p_TipoMovimiento = 1 THEN
							--El procedimiento modifica el estado del archivo a procesar a estado 09 en la lista de archivos de afore.
							UPDATE bdiprog:pp_arch_afore
							SET status = '09'
							WHERE nombre_arch = p_NombreArchivo;

							--El procedimiento guarda el fin del procedimiento de Cancelación de la Ejecución de Pagos Pendientes.
							UPDATE bdiprog:pp_procesos
							SET status = '2'
							WHERE proceso = cNomProceso
								AND fech_proceso = v_fecha_hoy;

						--Tipo de cancelación "Cancelación".
						ELIF p_TipoMovimiento = 2 THEN
							--El procedimiento modifica el estado del archivo a procesar a estado 08 en la lista de archivos de afore.
							UPDATE bdiprog:pp_arch_afore
							SET status = '08'
							WHERE nombre_arch = p_NombreArchivo;

							--El procedimiento modifica el estado de los registros incluidos en el archivo en la seccion de detalles a estado 08.
							UPDATE bdiprog:pp_detalle
							SET status = '08'
							WHERE nombre_arch = p_NombreArchivo;

							--El procedimiento guarda el fin del procedimiento de Cancelación de la Ejecución de Pagos Pendientes.
							UPDATE bdiprog:pp_procesos
							SET status = '2'
							WHERE proceso = cNomProceso
								AND fech_proceso = v_fecha_hoy;

						ELSE
							LET v_codret = '10025';	--Tipo de movimiento incorrecto

							--El procedimiento guarda el error en bitacora del sistema.
							INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
							VALUES (cNomProceso, p_NombreArchivo, v_codret, 'Tipo de movimiento incorrecto', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));

							RETURN v_codret;
						END IF;

					ELIF v_Status = '2' THEN
						LET v_codret = '10028';	--Ya fue cancelado el archivo

						INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
						VALUES (cNomProceso, p_NombreArchivo, v_codret, 'Ya fue cancelado el archivo', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));

						RETURN v_codret;

					ELSE
						LET v_codret = '10026';	--Status incorrecto

						--El procedimiento guarda el error en bitacora del sistema.
						INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
						VALUES (cNomProceso, p_NombreArchivo, v_codret, 'Status incorrecto', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));

						RETURN v_codret;
					END IF;
				ELSE
					--El procedimiento registra el inicio del proceso en la lista de procesos.
					INSERT INTO bdiprog:pp_procesos (proceso, fech_proceso, status, user_insert, fecha_insert)
					VALUES (cNomProceso, v_fecha_hoy, '1', p_Usuario, v_fecha_hoy);

					--Tipo de cancelación "Suspensión Temporal".
					IF p_TipoMovimiento = 1 THEN
						--El procedimiento modifica el estado del archivo a procesar a estado 09 en la lista de archivos de afore.
						UPDATE bdiprog:pp_arch_afore
						SET status = '09'
						WHERE nombre_arch = p_NombreArchivo;

						--El procedimiento guarda el fin del procedimiento.
						UPDATE bdiprog:pp_procesos
						SET status = '2'
						WHERE proceso = cNomProceso
							AND fech_proceso = v_fecha_hoy;

					--Tipo de cancelación "Cancelación".
					ELIF p_TipoMovimiento = 2 THEN
						--El procedimiento modifica el estado del archivo a procesar a estado 08 en la lista de archivos de afore.
						UPDATE bdiprog:pp_arch_afore
						SET status = '08'
						WHERE nombre_arch = p_NombreArchivo;

						--El procedimiento modifica el estado de los registros incluidos en el archivo en la seccion de detalles a estado 08.
						UPDATE bdiprog:pp_detalle
						SET status = '08'
						WHERE nombre_arch = p_NombreArchivo;

						--El procedimiento guarda el fin del procedimiento.
						UPDATE bdiprog:pp_procesos
						SET status = '2'
						WHERE proceso = cNomProceso
							AND fech_proceso = v_fecha_hoy;

					ELSE
						LET v_codret = '10025';	--Tipo de movimiento incorrecto

						--El procedimiento guarda el error en bitacora del sistema.
						INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
						VALUES (cNomProceso, p_NombreArchivo, v_codret, 'Tipo de movimiento incorrecto', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));

						RETURN v_codret;
					END IF;
				END IF;
			ELSE
				--- No se a ejecutado el proceso de recepción de archivo
				LET v_codret = '10024';

				INSERT INTO bdiprog:pp_bitacora (proceso, archivo, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
				VALUES (cNomProceso,p_NombreArchivo, v_codret,'No se Ejecuto el proceso de Recepcion de Archivos con anterioridad', p_Usuario, v_fecha_hoy, SUBSTR(CURRENT, 12, 8));		

				RETURN v_codret;
			END IF;
			RETURN v_codret;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Suspender de manera provisional y/o cancelar de manera definitiva la ejecución del proceso automático Ejecución de', 
'Pagos Pendientes que se encarga de realizar la dispersión de pagos pendientes enviados por Afore Coppel',
'Solicito : Armando Mercado',	
'AUTOR: Abraham Ayala Aguilar',
'FECHA: 20 Mayo 2009',
'VERSION: 20090520',
'BD: BDIPROG',
'DESCRIPCION: Se realizo la separacion de procesos dado a que un proceso se puede suspender temporalmente y cancelar definitivo,',
'se analizo que era necesario separarse en Aforesus## y Aforecan## para cumplir con la necesidad del cliente.',
'Solicito : Armando Mercado',	
'MODIFICO: ANTONIO BASTIDAS',
'FECHA: 23 junio 2009',
'VERSION: 20090623.1827',
'BD: BDIPROG';

CREATE PROCEDURE "informix".sp_consulta_telefonosfrec_bpi(p_NumCte CHAR(20), p_CveCuenta CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(6) as cod_ret, ---cod_ret
	 CHAR(20) as cuenta, ---cuenta	 
     CHAR(20) as desc_cuenta, ---desc cuenta
     CHAR(1) as digito_ver, ---digito ver
	 CHAR(1) as a,
	 MONEY(16,2) as monto_maximo,  --Monto Máximo
	 INTEGER as caducidad;	-- Tipo de caducidad
	 
--#############################################################################################################
-- SP clonado para la reingeniería, donde se agrega parámetro de salida para el tipo de caducidad
-- Bibiana Gaxiola Verdugo
-- 19/12/2012
-- Se agrega filtro para que no presente en la lista los teléfonos frecuentes que no tienen digito verificador
-- Bibiana Gaxiola Verdugo
-- 05/03/2014
--#############################################################################################################

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);	
	DEFINE v_CtaDestino			CHAR(20);	
	DEFINE v_DescCta			CHAR(20);    
	DEFINE v_Digito				CHAR(1);
	DEFINE v_Inhabil			CHAR(1);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_ContReg			INTEGER;
	DEFINE v_FechaInsert		DATE;
	DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
	DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;	
	DEFINE v_MontoMaximo		MONEY(16,2);
	DEFINE v_CveCaducidad		INTEGER;   -- Tipo de caducidad

	LET v_cod_ret			    = "";	
	LET v_CtaDestino			= "";
	LET v_DescCta				= "";
    LET v_Digito                = "";
	LET v_Inhabil				= "";
	LET v_ContReg				= 0;
	LET v_Canal					= "";
	LET v_MontoMaximo			= 0.00;
	LET v_CveCaducidad			= '';
	
	SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;                
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consulta_telefonosfrec_bpi.out";
--TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CveCuenta <> "" AND p_CveCuenta IS NOT NULL)  THEN
 		IF EXISTS (SELECT ct.cuenta FROM bdiprog:"informix".pp_ctasterceros ct WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = p_CveCuenta)  THEN
            IF TRIM(p_CveCuenta) = '05' THEN
				FOREACH
                    SELECT ct.cuenta, ct.descrip_cta, ct.digito_ver, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0), ct.cve_caducidad
                    INTO v_CtaDestino,v_DescCta, v_Digito, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad
                    FROM bdiprog:"informix".pp_ctasterceros ct
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = '201'
                    AND ct.cve_cuenta = p_CveCuenta                    
                    AND ct.cve_estado = '01'	
					AND ct.digito_ver <> ''
					AND (current - ( YEAR(fecha_insert) || '-' || MONTH(fecha_insert) || '-' || DAY(fecha_insert) || ' ' || hora_insert)::DATETIME YEAR TO FRACTION) < '0 00:30:00'
					ORDER BY ct.descrip_cta ASC, ct.cuenta
					
					LET v_Inhabil = '';
					LET v_ContReg = v_ContReg + 1;
					
					IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
						CONTINUE FOREACH;
					ELSE													
						-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
						IF v_Canal = '03' THEN							
							LET v_Inhabil = '1';							
						END IF;						
					END IF;
				
					RETURN v_cod_ret, v_CtaDestino,v_DescCta,v_Digito,v_Inhabil,v_MontoMaximo, v_CveCaducidad WITH RESUME;
				END FOREACH;
				
				LET v_Inhabil = '';
                FOREACH
                    SELECT ct.cuenta, ct.descrip_cta, ct.digito_ver, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0), ct.cve_caducidad
                    INTO v_CtaDestino,v_DescCta, v_Digito, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad
                    FROM bdiprog:"informix".pp_ctasterceros ct
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = '201'
                    AND ct.cve_cuenta = p_CveCuenta                    
                    AND ct.cve_estado = '01'
					AND ct.digito_ver <> ''					
					AND (current - ( YEAR(fecha_insert) || '-' || MONTH(fecha_insert) || '-' || DAY(fecha_insert) || ' ' || hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00'
					ORDER BY ct.descrip_cta ASC, ct.cuenta	

					LET v_ContReg = v_ContReg + 1;				
					
					IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
						CONTINUE FOREACH;									
					END IF;
										
					RETURN v_cod_ret, v_CtaDestino,v_DescCta,v_Digito,v_Inhabil, v_MontoMaximo, v_CveCaducidad WITH RESUME;
                END FOREACH;
			END IF;
        ELSE            
            SELECT cod_ret
            INTO v_cod_ret
            FROM  BDIPROG:"informix".PP_MENSAJES
            WHERE cve_mensaje = "13";

            RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL;
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
END;
END PROCEDURE;