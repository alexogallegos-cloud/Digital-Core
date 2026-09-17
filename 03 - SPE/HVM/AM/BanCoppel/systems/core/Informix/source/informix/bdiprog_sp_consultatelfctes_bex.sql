CREATE PROCEDURE "informix".sp_consultatelfctes_bex(p_NumCte CHAR(20), p_CveCuenta CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(20), ---cuenta	 
     CHAR(20), ---desc cuenta
     CHAR(1), ---digito ver
	 CHAR(1),
	 MONEY(16,2);	 --Monto MÃ¡ximo

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

	LET v_cod_ret			    = "";	
	LET v_CtaDestino			= "";
	LET v_DescCta				= "";
    LET v_Digito                = "";
	LET v_Inhabil				= "";
	LET v_ContReg				= 0;
	LET v_Canal					= "";
	LET v_MontoMaximo			= 0.00;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;                
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/ireb/bdiprog/bex/sp_consultatelfctes_bex.out";
	--TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CveCuenta <> "" AND p_CveCuenta IS NOT NULL)  THEN
 		IF EXISTS (SELECT ct.cuenta FROM bdiprog:"informix".pp_ctasterceros_bex ct WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = p_CveCuenta)  THEN
            IF TRIM(p_CveCuenta) = '05' THEN
				FOREACH
                    SELECT ct.cuenta, ct.descrip_cta, ct.digito_ver, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0)
                    INTO v_CtaDestino,v_DescCta, v_Digito, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo
                    FROM bdiprog:"informix".pp_ctasterceros_bex ct
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = '201'
                    AND ct.cve_cuenta = p_CveCuenta                    
                    AND ct.cve_estado = '01'					
					--AND (current - ( YEAR(fecha_insert) || '-' || MONTH(fecha_insert) || '-' || DAY(fecha_insert) || ' ' || hora_insert)::DATETIME YEAR TO FRACTION) < '0 00:30:00'
					ORDER BY ct.descrip_cta ASC, ct.cuenta
					
					LET v_Inhabil = '';
					LET v_ContReg = v_ContReg + 1;
					
					IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
						CONTINUE FOREACH;
					/*ELSE													
						-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
						IF v_Canal = '03' THEN							
							LET v_Inhabil = '1';							
						END IF;						*/
					END IF;
					RETURN v_cod_ret, v_CtaDestino,v_DescCta,v_Digito,v_Inhabil,v_MontoMaximo WITH RESUME;
				END FOREACH;	
			/*	LET v_Inhabil = '';
                FOREACH
                    SELECT ct.cuenta, ct.descrip_cta, ct.digito_ver, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0)
                    INTO v_CtaDestino,v_DescCta, v_Digito, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo
                    FROM bdiprog:"informix".pp_ctasterceros_bex ct
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = '201'
                    AND ct.cve_cuenta = p_CveCuenta                    
                    AND ct.cve_estado = '01'		
					--AND (current - ( YEAR(fecha_insert) || '-' || MONTH(fecha_insert) || '-' || DAY(fecha_insert) || ' ' || hora_insert)::DATETIME YEAR TO FRACTION) > '0 00:30:00'
					ORDER BY ct.descrip_cta ASC, ct.cuenta					
					
					LET v_ContReg = v_ContReg + 1;				
					
					IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
						CONTINUE FOREACH;									
					END IF;
					RETURN v_cod_ret, v_CtaDestino,v_DescCta,v_Digito,v_Inhabil, v_MontoMaximo WITH RESUME;
                END FOREACH;*/
			END IF;
        ELSE            
            SELECT cod_ret
            INTO v_cod_ret
            FROM  BDIPROG:"informix".PP_MENSAJES
            WHERE cve_mensaje = "13";

            RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL;
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL;
	END IF
END;
END PROCEDURE;