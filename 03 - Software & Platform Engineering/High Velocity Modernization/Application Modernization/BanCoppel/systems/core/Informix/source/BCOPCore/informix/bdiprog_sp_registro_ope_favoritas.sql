CREATE PROCEDURE "informix".sp_registro_ope_favoritas(pnumCte CHAR(20), pctaOrigen CHAR(20), pctaDestino CHAR(20), ptipoOperacion CHAR(50), pdescOperacion CHAR(50),  pconcepto CHAR (40), preferenciaBene CHAR (50), pestatus CHAR(1), pimporte MONEY(16,2), poperaciones_max INTEGER)
    RETURNING CHAR(5);

    DEFINE sql_err 		INTEGER ;
    DEFINE cCod_ret 	CHAR(5);
	DEFINE vEstatus 	VARCHAR(9);
	DEFINE vOpeCount	INTEGER;
	
	LET cCod_ret  		= '00000';
	LET vOpeCount = 0; -- Se inicializa variable por PDRH.
	LET vEstatus = ''; -- Se inicializa variable por PDRH.
	
	--SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_registro_ope_favorita.out";
	--TRACE ON;
	
BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			let cCod_ret = sql_err;
			RETURN cCod_ret;
		END IF;
	END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	LET pnumCte =  NVL(pnumCte,'');
	LET pctaOrigen = NVL(pctaOrigen,'');
	LET pctaDestino = NVL(pctaDestino,'');
	LET ptipoOperacion = NVL(ptipoOperacion,'');
	LET pdescOperacion = NVL(pdescOperacion,'');
	LET pconcepto = NVL(pconcepto,'');
	LET preferenciaBene = NVL(preferenciaBene,'');
	LET pestatus = NVL(pestatus,''); 

	IF pnumCte <> '' AND pctaOrigen <> '' AND pctaDestino <> '' AND ptipoOperacion <> '' AND pdescOperacion <> '' AND pestatus <> ''   THEN 
		
		--Verifica si el usuario cuenta con el maximo de operaciones fav. registradas.
		SELECT count(num_cte)
		INTO vOpeCount
		FROM bdiprog:"informix".pp_registro_favoritos
		WHERE num_cte = pnumCte
		AND estatus = '1';
		
		--Verifica si existe operación favorita
		SELECT estatus
		INTO vEstatus
		FROM bdiprog:"informix".pp_registro_favoritos
		WHERE num_cte = pnumCte 
		AND cta_origen = pctaOrigen
		AND cta_destino = pctaDestino;
			
		LET vEstatus = nvl(vEstatus,'');
		
		IF vOpeCount >= poperaciones_max AND ( vEstatus = '' OR vEstatus = '2' ) THEN
			-- Ya tiene registrado el maximo de operaciones favoritas y no existe la operacion
			LET cCod_Ret = '00003'; 
		ELSE
		
			IF vEstatus = '' THEN 
				--Inserta la nueva Operacion Favorita.
					INSERT INTO bdiprog:"informix".pp_registro_favoritos(num_cte,cta_origen,cta_destino,tipo_operacion,fecha_modificado,fecha_alta,desc_operacion,concepto,referencia_bene,estatus,importe)
					VALUES (pnumCte,pctaOrigen,pctaDestino,ptipoOperacion,CURRENT,CURRENT,pdescOperacion,pconcepto,preferenciaBene,pestatus, pimporte);
	
				
			ELSE
				--Actualiza la operación favorita del cliente
					UPDATE bdiprog:"informix".pp_registro_favoritos
					SET fecha_modificado = CURRENT, desc_operacion = pdescOperacion, concepto = pconcepto, referencia_bene = preferenciaBene, estatus = pestatus, importe = pimporte
					WHERE num_cte = pnumCte 
					AND cta_origen = pctaOrigen
					AND cta_destino = pctaDestino;
			
				
			END IF;
			
		END IF;
		
	ELSE
		LET cCod_Ret = '00002'; -- Parametros incorrectos
	END IF;
     
	RETURN cCod_ret;
END
END PROCEDURE

/*DOCUMENT
'FOLIO: 522 BPI - Registro de operacioens favoritas',
'AUTOR: Juan Pablo Soto',
'FECHA: 02/01/2018',
'SE CREA PROCEDIMIENTO PARA REGISTRAR Y ACTUALIZAR OPERACIONES FAVORITAS',
'DB: BDIPROG '*/;

CREATE PROCEDURE "informix".sp_consulta_ctasfrec_bpi(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(6) as cod_ret, ---cod_ret
	 CHAR(20) as cuenta, ---cuenta
	 CHAR(100) as nombre, ---nombre
	 CHAR(50) as banco, ---banco
	 CHAR(2) as compania_cel, ---compaÃÂ±ia celular
	 CHAR(10) as celular, ---numero celular
	 CHAR(40) as correo_elec, ---correo electronico
	 CHAR(2) as cve_cuenta, ---cve cuenta
     CHAR(20) as desc_cuenta, ---desc cuenta
     CHAR(13) as rfc , ---rfc
	 MONEY(16,2) as monto_maximo, ---Monto MÃÂ¡ximo
	 CHAR(1) as cve_caducidad; -- tipo de caducidad

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
	DEFINE v_CorreoE			CHAR(40);
	DEFINE v_CveCuenta			CHAR(2);
	DEFINE v_ContReg			SMALLINT;
	DEFINE v_DescCta			CHAR(20);
    DEFINE v_Rfc                CHAR(13);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_FechaInsert		DATE;
	DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
	DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;
	DEFINE v_MontoMaximo		MONEY(16,2);
	DEFINE v_CveCaducidad		INTEGER;
	DEFINE i_count		 		INTEGER;

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
	LET v_MontoMaximo			= 0.00;
	LET v_CveCaducidad			= "";
	LET i_count			 		= 0;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

--	SET DEBUG FILE TO "/informix/gaby/Outoptimizados/sp_consulta_ctasfrec_bpi.out";
	--TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  bdiprog:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	/*SELECT banco || " " ||
		(CASE
			WHEN TRIM(vchrnombrecorto) = ''
				THEN descripcion
			ELSE
				vchrnombrecorto
		END) 
	INTO v_Banco
	FROM bdinteg:"informix".si_bancos
	WHERE banco = "137";*/


	--IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL)  THEN
 		--IF EXISTS (SELECT ct.cuenta FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp 
			--WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta)  THEN
           
		LET p_NumCte = TRIM(NVL(p_NumCte,""));
		LET p_CvePago = TRIM(NVL(p_CvePago,""));

		IF (p_NumCte <> "") AND (p_CvePago <> "")  THEN
		
		SELECT count(ct.cuenta)
		INTO i_count
		FROM "informix".pp_ctasterceros ct
		INNER JOIN "informix".pp_cuentapago cp 
		ON (ct.cve_cuenta = cp.cve_cuenta)
		WHERE ct.num_cte = p_NumCte;

		IF (i_count > 0)  THEN
		   IF (p_CvePago) = '04' THEN
                FOREACH
                    SELECT ct.cuenta, ct.nombre, ct.cve_banco, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0),ct.cve_caducidad
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = '031'
                    AND cp.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'
					

--                    LET v_ContReg = v_ContReg + 1;

--                  IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
--                       CONTINUE FOREACH;
--                    END IF;
					
															
                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;					

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad  WITH RESUME;
                END FOREACH;
            ELSE
                FOREACH
                    SELECT ct.cuenta, ct.nombre, b.banco|| "  " ||
					(CASE
						WHEN TRIM(vchrnombrecorto) = ''
						THEN descripcion
					ELSE
					vchrnombrecorto
					END), ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0), ct.cve_caducidad
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdinteg:"informix".si_bancos b, bdiprog:"informix".pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = b.banco
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'
                    UNION
                    --SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,'','','1900-01-01'::date, current hour to second
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,'','',mdy(1,1,1900), current hour to second,0,'0'
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago = '05'
					ORDER BY ct.descrip_cta, ct.nombre

--                    LET v_ContReg = v_ContReg + 1;

--                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
--                        CONTINUE FOREACH;
--                    END IF;
					
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

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc, v_MontoMaximo, v_CveCaducidad  WITH RESUME;
                END FOREACH;
            END IF;
        ELSE
            --IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta Where numcte == p_NumCte )  THEN
			SELECT count(num_tarjeta) 
        	INTO i_count
        	FROM bdicred:"informix".sd_tarjeta 
        	WHERE numcte == p_NumCte;
			IF (i_count > 0)  THEN
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

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo, v_CveCaducidad  WITH RESUME;
                END FOREACH;
            ELSE
                SELECT cod_ret
                INTO v_cod_ret
                FROM  BDIPROG:"informix".PP_MENSAJES
                WHERE cve_mensaje = "13";

                RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
            END IF
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
END;
--##############################################################################
-- Se clona el SP sp_consultacuentasdestino_bpi para el proyecto de ReingenierÃÂ­a BPI
-- agregando como dato de salida la caducidad
-- Bibiana Gaxiola Verdugo 
-- 19/12/2012
--
--Se optimiza spl por contingenica
--Gabriela Aguilar
--30-12-2018
--Se Agregan validaciones para Tiempo Aire
--Gabriela Aguilar
--09-10-2019
--##############################################################################
END PROCEDURE;