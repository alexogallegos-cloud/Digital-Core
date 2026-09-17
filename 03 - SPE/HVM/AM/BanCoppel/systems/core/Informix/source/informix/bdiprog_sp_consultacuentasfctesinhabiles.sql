CREATE PROCEDURE "informix".sp_consultacuentasfctesinhabiles(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(20), ---cuenta
	 CHAR(100), ---nombre
	 CHAR(50), ---banco
	 CHAR(2), ---compaÃÂ±ia celular
	 CHAR(10), ---numero celular
	 CHAR(40), ---correo electronico
	 CHAR(2), ---cve cuenta
     CHAR(20), ---desc cuenta
     CHAR(13); ---rfc	 
	 
--##############################################################################
--##CreÃ?		 : Walber Castro
--##Fecha        : 23/09/2010
--##Descripcion  : Se crea con el proposito de consultar las cuentas que aÃÂ¼n no estan disponibles 
--##porque no han transcurrido los 30 minutos de tolerancia despuÃÂ©s de haber sido dada de alta (Solo para Internet).
--##############################################################################

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
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

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

	--SET DEBUG FILE TO "//informix/gaby/ArchivosOut/sp_consultacuentasfctesinhabiles.out";
	--TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:PP_MENSAJES
	WHERE cve_mensaje = "00";

	select banco || " " ||
		(CASE
			WHEN TRIM(vchrnombrecorto) = ''
			THEN descripcion
		ELSE
			vchrnombrecorto
		END) 
	INTO v_Banco
	FROM bdinteg:si_bancos
	WHERE banco = "137";


	IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL)  THEN
 		IF EXISTS (SELECT ct.cuenta FROM bdiprog: pp_ctasterceros ct, pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta)  THEN
            IF TRIM(p_CvePago) = '04' THEN
                FOREACH
                    SELECT ct.cuenta, ct.nombre, '000 NO APLICA', ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert
                    FROM bdiprog: pp_ctasterceros ct, pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = '000'
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'
					ORDER BY ct.descrip_cta ASC, ct.nombre
					
					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
					IF v_Canal = '03' THEN
						LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN							
							LET v_ContReg = v_ContReg + 1;					

							IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
								CONTINUE FOREACH;
							ELSE
								RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc  WITH RESUME;
							END IF;							
						END IF;
					END IF;
                    
                END FOREACH;
            ELSE
                FOREACH
                    SELECT ct.cuenta, ct.nombre, b.banco|| "  " ||
					(CASE
						WHEN TRIM(vchrnombrecorto) = ''
					THEN descripcion
					ELSE
						vchrnombrecorto
					END), ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert
                    FROM bdiprog: pp_ctasterceros ct, bdinteg:si_bancos b, pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = b.banco
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'
                    UNION
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,'','','1900-01-01'::date, current hour to second
                    FROM bdicred:sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago = '05'
					ORDER BY ct.descrip_cta ASC, ct.nombre
					
				--- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
					IF (v_Canal = '03') OR (v_Canal = '18') THEN
                        IF ( v_CveCuenta = '03') THEN
                            IF (LENGTH(v_ctaDestino) = 10) THEN
                               LET v_CveCuenta = '07';
                            ELIF (LENGTH(v_ctaDestino) = 18) THEN
                            	LET v_CveCuenta = '02';
                            ELIF (LENGTH(v_ctaDestino) = 16) THEN
                            	LET v_CveCuenta = '03';
                           END IF;
                        END IF;						
					END IF;

                    IF v_Canal = '03' THEN
                        LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
							LET v_ContReg = v_ContReg + 1;					

							IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
								CONTINUE FOREACH;
							ELSE
								RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc  WITH RESUME;
							END IF;							
						END IF;
                     END IF;
                    
                END FOREACH;
            END IF;
        ELSE            
            SELECT cod_ret
            INTO v_cod_ret
            FROM  BDIPROG:PP_MENSAJES
            WHERE cve_mensaje = "13";

            RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;            
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
END;
END PROCEDURE;