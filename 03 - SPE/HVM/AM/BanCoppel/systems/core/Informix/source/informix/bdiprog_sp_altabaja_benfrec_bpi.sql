CREATE PROCEDURE "informix".sp_altabaja_benfrec_bpi(pTipoOper CHAR(2), pNumCte CHAR(20),pCuenta CHAR(20),pClaveBanco CHAR(3), pClaveCuenta CHAR(2),
pDescripcion CHAR(20),pPrimerNom CHAR(26), pSegundoNom CHAR(26), pApellidoPat CHAR(26), pApellidoMat CHAR(26), pDomicilio CHAR(80), pEmail CHAR(40),
pNumCelular CHAR(10), pCveCompaniaCel CHAR(2), pCveEstado CHAR(2), pCanalAlta CHAR(2),pCanalBaja CHAR(2),pUserInsert CHAR(8),pMontoMax MONEY(16,2),pCveCaducidad CHAR(1))
	RETURNING CHAR(5), CHAR(60);

	--Declaracion de variables
	DEFINE cCveCompania CHAR(2);
	DEFINE cCveEstado CHAR(2);
	DEFINE cCodRet CHAR(5);
	DEFINE cMensajeRet CHAR(60);
	DEFINE iCelular INTEGER;
	DEFINE cFinCiclo CHAR(1);
	DEFINE cValor CHAR(1);
	DEFINE iLongCelular INTEGER;
	DEFINE cCelular CHAR(10);
	DEFINE cCodRetEmail CHAR(5);
	DEFINE dFechaCaducidad DATE;
	DEFINE intcodret INTEGER;
	DEFINE cCve_estado CHAR(2);
	DEFINE iValidador INTEGER;
	--Asignacion de variables
	LET cCveCompania = '';
	LET cCveEstado = '';
	LET cCodRet = '00000';
	LET cMensajeRet = '';
	LET iCelular = 0;
	LET cFinCiclo = 'T';
	LET cValor = '';
	LET iLongCelular = 1;
	LET cCelular = '';
	LET cCodRetEmail = '';
	LET dFechaCaducidad = '';
	LET cCve_estado='';
	LET iValidador = 0;

	--Inicio del procedimiento

		--SET DEBUG FILE TO "/home/sysifx/Aastorga/bpi/520/sp_altabaja_benfrec_bpi.out";
		--TRACE ON;
		
	BEGIN
			ON EXCEPTION SET intcodret
				IF intcodret <> 0 THEN
					LET cCodRet  = intcodret;
					RETURN cCodRet, cMensajeRet;
				END IF;
			END EXCEPTION;
			
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Se valida que los parametros no este en blancos o en nulo

		IF (NVL(pTipoOper,'') = '') THEN
			LET pTipoOper = '00';
		END IF;

		IF (pTipoOper <> '01') AND (pTipoOper <> '02')THEN
			LET cCodRet='00001';
			RETURN cCodRet, cMensajeRet;
		END IF;
		IF (NVL(pClaveCuenta,'') = '') THEN
			LET cCodRet='00001';
			RETURN cCodRet, cMensajeRet;
		END IF;
		IF (NVL(pClaveBanco,'') = '') THEN
			LET cCodRet='00001';
			RETURN cCodRet, cMensajeRet;
		END IF;
		IF (NVL(pCuenta,'') = '') THEN
			LET cCodRet='00001';
			RETURN cCodRet, cMensajeRet;
		END IF;
		IF (NVL(pNumCte,'') = '') THEN
			LET cCodRet='00001';
			RETURN cCodRet, cMensajeRet;
		END IF;
		IF (NVL(pCveCompaniaCel,'') = '') THEN
			SELECT cod_ret,desc_mensaje INTO cCodRet, cMensajeRet FROM "informix".pp_mensajes where cve_mensaje = '08';
			RETURN cCodRet, cMensajeRet;
		END IF;

		--Se valida el numero de celular y su longitud
		LET pNumCelular= NVL(pNumCelular,'');
		LET cFinCiclo = 'T';
		LET cValor = '';
		LET iCelular = LENGTH(pNumCelular);
			IF (iCelular < 10 AND iCelular > 0) THEN
				SELECT cod_ret,desc_mensaje INTO cCodRet, cMensajeRet FROM "informix".pp_mensajes where cve_mensaje = '16';
				RETURN cCodRet, cMensajeRet;
			END IF;
		WHILE (iLongCelular <= iCelular) AND (cFinCiclo = 'T')
			LET cCelular = SUBSTR(pNumCelular,iLongCelular,1);
			IF ((cCelular >= '0') AND (cCelular <= '9')) THEN
				LET cValor = 'A';
			ELSE
				LET cValor = 'B';
				LET cFinCiclo = 'F';
			END IF;
			LET iLongCelular = ( iLongCelular + 1);
		END WHILE;
		IF (cValor = 'B') THEN
			SELECT cod_ret,desc_mensaje INTO cCodRet, cMensajeRet FROM "informix".pp_mensajes WHERE cve_mensaje = '207';
			RETURN cCodRet, cMensajeRet;
		END IF;


		--Se valida Email
		IF (NVL(pEmail,'') <> '') THEN
			EXECUTE PROCEDURE "informix".validaEmail(pEmail) INTO cCodRetEmail;
				IF cCodRetEmail <> '00000' THEN
					SELECT cod_ret,desc_mensaje INTO cCodRet, cMensajeRet FROM "informix".pp_mensajes where cve_mensaje = '212';
					RETURN cCodRet, cMensajeRet;
				END IF;
		END IF;

		--Se valida si el tipo de operacion es una alta ('01')
		IF (pTipoOper = '01') THEN
			--Se valida el canal
			SELECT count(cve_canal) INTO iValidador FROM "informix".pp_tpcanal WHERE cve_canal = pCanalAlta;
			IF iValidador = 0 THEN
				SELECT cod_ret,desc_mensaje INTO cCodRet, cMensajeRet FROM "informix".pp_mensajes where cve_mensaje = '18';
				RETURN cCodRet, cMensajeRet;
			END IF;
			IF (NVL(pCanalBaja,'') = '') THEN
				LET pCanalBaja = '00';
			END IF;

			--Se valida que exista el beneficiario con el mismo nombre y apellidos 
			SELECT count(num_cte) 
			INTO iValidador
			FROM "informix".pp_beneficiariosfrec_bpi 
			WHERE num_cte = pNumCte 
				AND cve_banco = pClaveBanco 	
				AND cve_cuenta=pClaveCuenta 
				AND primer_nombre=pPrimerNom 
				AND segundo_nombre=pSegundoNom 
				AND apellido_paterno=pApellidoPat 
				AND apellido_materno=pApellidoMat;

			IF iValidador = 0 THEN
				
				IF (pCveCaducidad = '1') THEN -- Caducidad 48 horas (2 dÃ­as)
					LET dFechaCaducidad = TODAY + 2 UNITS DAY;

				ELIF (pCveCaducidad = '2') THEN -- Caducidad 6 meses
					-- Se utiliza la funcipon monthadd para generar la fecha de caducidad de las cuentas frec tipo 2
					SELECT bdicred:"informix".monthadd(fecha_hoy,6) INTO dFechaCaducidad FROM bdinteg:"informix".si_fechas;
							
				ELIF (pCveCaducidad = '3') THEN -- Caducidad indefinida - 1 aÃ±o
					LET dFechaCaducidad = TODAY + 1 UNITS YEAR;

				ELIF (pCveCaducidad is null) OR (TRIM(pCveCaducidad) = '') THEN -- Cuando la clave caducidad es nula se registra la cuenta con caducidad indefinida automaticamente
					LET pCveCaducidad = '3';
					LET dFechaCaducidad = TODAY + 1 UNITS YEAR;

				ELSE
						LET cCodRet = '00002';
						LET cMensajeRet = 'Caducidad invÃ¡lida';
						RETURN cCodRet, cMensajeRet;
				END IF;
				--INSERT
				INSERT INTO "informix".pp_beneficiariosfrec_bpi(num_cte,cuenta,cve_banco,cve_cuenta,alias,primer_nombre,segundo_nombre,apellido_paterno,apellido_materno,domicilio_ben,email,no_celular,cve_compania,cve_estado,canal_alta,canal_baja,fecha_estado,user_insert,hora_insert,digito_ver,monto_maximo,cve_caducidad,fecha_caducidad,fecha_movtos,fecha_insert)
				VALUES(pNumCte,pCuenta,pClaveBanco,pClaveCuenta,pDescripcion,pPrimerNom,pSegundoNom,pApellidoPat,pApellidoMat,pDomicilio,pEmail,pNumCelular,pCveCompaniaCel,pCveEstado,pCanalAlta,pCanalBaja,TODAY,pUserInsert,CURRENT,"",pMontoMax,pCveCaducidad,dFechaCaducidad,TODAY,current);

				SELECT cod_ret,desc_mensaje INTO cCodRet, cMensajeRet FROM "informix".pp_mensajes where cve_mensaje = '00';
			ELSE 
						SELECT cve_estado
						INTO cCve_estado
						FROM "informix".pp_beneficiariosfrec_bpi WHERE num_cte = pNumCte AND cve_banco = pClaveBanco AND cve_cuenta=pClaveCuenta AND primer_nombre=pPrimerNom AND segundo_nombre=pSegundoNom AND apellido_paterno=pApellidoPat AND apellido_materno=pApellidoMat;
						
						--Se verifica si ya se habia dado de baja y se reactiva
						IF (NVL(cCve_estado,'') ='02')THEN
							IF (pCveCaducidad = '1') THEN -- Caducidad 48 horas (2 dÃ­as)
								LET dFechaCaducidad = TODAY + 2 UNITS DAY;
								
							ELIF (pCveCaducidad = '2') THEN -- Caducidad 6 meses
								-- Se utiliza la funcipon monthadd para generar la fecha de caducidad de las cuentas frec tipo 2
								SELECT bdicred:"informix".monthadd(fecha_hoy,6) INTO dFechaCaducidad FROM bdinteg:"informix".si_fechas;
										
							ELIF (pCveCaducidad = '3') THEN -- Caducidad indefinida - 1 aÃ±o
								LET dFechaCaducidad = TODAY + 1 UNITS YEAR;
								
							ELIF (pCveCaducidad is null) OR (TRIM(pCveCaducidad) = '') THEN -- Cuando la clave caducidad es nula se registra la cuenta con caducidad indefinida automaticamente
								LET pCveCaducidad = '3';
								LET dFechaCaducidad = TODAY + 1 UNITS YEAR;
								
							ELSE
									LET cCodRet = '00002';
									LET cMensajeRet = 'Caducidad invÃ¡lida';
									RETURN cCodRet, cMensajeRet;
							END IF;

							UPDATE "informix".pp_beneficiariosfrec_bpi
							SET cuenta=pCuenta,cve_banco=pClaveBanco,cve_cuenta=pClaveCuenta,alias=pDescripcion,domicilio_ben=pDomicilio,email=pEmail,no_celular=pNumCelular,cve_compania=pCveCompaniaCel,cve_estado='01',canal_alta=pCanalAlta,canal_baja=pCanalBaja,fecha_estado=TODAY,user_insert=pUserInsert,hora_insert=CURRENT,monto_maximo=pMontoMax,cve_caducidad=pCveCaducidad,fecha_caducidad=dFechaCaducidad,fecha_movtos=TODAY,fecha_insert=CURRENT
							WHERE num_cte = pNumCte AND cve_banco = pClaveBanco AND cve_cuenta=pClaveCuenta AND primer_nombre=pPrimerNom AND segundo_nombre=pSegundoNom AND apellido_paterno=pApellidoPat AND apellido_materno=pApellidoMat;

							LET cCodRet = '00000';
							LET cMensajeRet = 'Beneficiario Reactivado';
							RETURN cCodRet, cMensajeRet;
						
						ELSE					
							LET cCodRet = '00001';
							LET cMensajeRet = 'Ya existe beneficiario';
							RETURN cCodRet, cMensajeRet;
						END IF;
			END IF;
		ELSE
			--SE REALIZA LA BAJA DE BENEFICIARIO
			--Se valida el canal
			SELECT count(cve_canal) into iValidador FROM "informix".pp_tpcanal WHERE cve_canal = pCanalBaja;
			IF iValidador > 0 THEN
				LET pCanalAlta = '00';
			ELSE
				SELECT cod_ret,desc_mensaje INTO cCodRet, cMensajeRet FROM "informix".pp_mensajes where cve_mensaje = '18';
				RETURN cCodRet, cMensajeRet;
			END IF;
			--Se valida que exista el estdo del cliente y se manda el codigo de retorno '09' con su descripcion
			SELECT cve_estado INTO cCveEstado FROM "informix".pp_beneficiariosfrec_bpi WHERE num_cte = pNumCte AND cve_banco = pClaveBanco AND cve_cuenta=pClaveCuenta AND cuenta=pCuenta;
			IF (NVL(cCveEstado,'') <> '') THEN
				--Se toma el valor del estado y se valida que el estado sea 01 si el estado es 01 se actualiza y se manda el codigo de retorno '00' con su descripcion sino se manda el codigo de retorno '10' con su descripcion
				
				IF cCveEstado = '01' THEN
					UPDATE "informix".pp_beneficiariosfrec_bpi SET cve_estado='02',canal_baja=pCanalBaja,fecha_estado=current,user_insert=pUserInsert
					WHERE num_cte = pNumCte AND cve_banco = pClaveBanco AND cve_cuenta=pClaveCuenta AND cuenta=pCuenta;
					
					SELECT cod_ret,desc_mensaje INTO cCodRet, cMensajeRet FROM "informix".pp_mensajes where cve_mensaje = '00';
				ELSE
					SELECT cod_ret,desc_mensaje INTO cCodRet, cMensajeRet FROM "informix".pp_mensajes where cve_mensaje = '10';
				END IF;
			ELSE
				SELECT cod_ret,desc_mensaje INTO cCodRet, cMensajeRet FROM "informix".pp_mensajes where cve_mensaje = '09';
			END IF;
		END IF;
		RETURN cCodRet, cMensajeRet;
	END
END PROCEDURE
Document
'DESCRIPCION: Da de alta nuevos beneficiarios frecuentes y realiza la baja de los mismos', 
'AUTOR: Jose Ruben Lopez',
'FECHA: 15 de enero de 2015',
'VERSION: 20141216.0900',
'BD: bdiprog',
'DESCRIPCION: Se realizan mejoras al codigo y se quitan validaciones para el parametro pCveCompaniaCel', 
'AUTOR: Arturo Astorga',
'FECHA: 08/03/2019',
'VERSION: 20190308.1600',
'BD: bdiprog';

CREATE PROCEDURE "informix".sp_consultacuentasdestino2_web(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(5), ---cod_ret
	 CHAR(20), ---cuenta
	 CHAR(100), ---nombre
	 CHAR(50), ---banco
	 CHAR(2), ---compaÃ±ia celular
	 CHAR(10), ---numero celular
	 CHAR(100), ---correo electronico
	 CHAR(2), ---cve cuenta
     CHAR(20), ---desc cuenta
     CHAR(13); ---rfc

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);
	DEFINE v_CvePago			CHAR(2);
	DEFINE v_CtaDestino			CHAR(20);
	DEFINE v_Nombre				CHAR(100);
	DEFINE v_Banco				CHAR(50);
	DEFINE v_CompCel			CHAR(2);
	DEFINE v_NumCel				CHAR(10);
	DEFINE v_CorreoE			CHAR(100);
	DEFINE v_CveCuenta			CHAR(2);
	DEFINE v_ContReg			SMALLINT;
	DEFINE v_DescCta			CHAR(20);
    DEFINE v_Rfc                CHAR(13);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_FechaInsert		DATE;
	DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
	DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;

	LET v_CodDesc			    = "";
	LET v_CvePago				= "";
	LET v_CtaDestino			= "";
	LET v_Nombre				= "";
	LET v_Banco					= "";
	LET v_CompCel				= "";
	LET v_NumCel				= "";
	LET v_CorreoE				= "";
	LET v_CveCuenta				= "";
	LET v_ContReg			 	= 0;
	LET v_DescCta				= "";
    LET v_Rfc                   = "";
	LET v_Canal					= "";

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	--SET DEBUG FILE TO "/tmp/sp_ConsultaCuentasDestino2_web.out";
	--TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	SELECT banco|| "  " ||descripcion
	INTO v_Banco
	FROM bdinteg:"informix".si_bancos
	WHERE banco = "137";


	IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL)  THEN
 		IF(SELECT {+ INDEX (pp_cuentapago 102_51)} count(ct.cuenta) FROM bdiprog:"informix".pp_ctasterceros ct, pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta) > 0 THEN
            IF TRIM(p_CvePago) = '04' THEN
                FOREACH
                    SELECT ct.cuenta, ct.nombre, ct.cve_banco, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert
                    FROM bdiprog:"informix".pp_ctasterceros ct, pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'

					
					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
					IF v_Canal = '03' THEN
						LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
							CONTINUE FOREACH;
						END IF;
					END IF;

                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;					

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc  WITH RESUME;
                END FOREACH;
            ELSE
                FOREACH
                    SELECT ct.cuenta, ct.nombre, b.banco|| "  " ||b.descripcion, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdinteg:si_bancos b, pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = b.banco
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'
                    UNION
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,'','',mdy(1,1,1900), current hour to second
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago = '05'
					ORDER BY ct.descrip_cta, ct.nombre

					
					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
					IF v_Canal = '03' THEN
						LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
							CONTINUE FOREACH;
						END IF;
					END IF;
					
                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;					

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc  WITH RESUME;
                END FOREACH;
            END IF;
        ELSE
            IF(SELECT count(num_tarjeta) FROM bdicred:"informix".sd_tarjeta Where numcte == p_NumCte ) > 0 THEN
                FOREACH
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,''
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago ="05"

                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc  WITH RESUME;
                END FOREACH;
            ELSE
                SELECT cod_ret
                INTO v_cod_ret
                FROM  BDIPROG:"informix".PP_MENSAJES
                WHERE cve_mensaje = "13";

                RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
            END IF
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
END;
--##############################################################################
--## Procedimiento   : sp_consultacuentasdestino2
--## Version         : 1.0
--## Creado por      : Pedro Portugal
--## Fecha creacion  : 23 de Mayo de 2017
--## Descripcion     : Consulta las cuentas destino que tiene registrado un cliente
--##############################################################################
END PROCEDURE;