CREATE PROCEDURE "informix".sp_consultaclienteportarjeta(p_NumTar VARCHAR(20))
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(20), ---num cte
	 CHAR(100); ---nombre cte

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_NumCte				CHAR(20);
	DEFINE v_NomCte				CHAR(100);

	LET v_NumCte				= "";
	LET v_NomCte				= "";

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL, NULL;
    END EXCEPTION;

	---SET DEBUG FILE TO "/tmp/has/sp_ConsultaClientePorTarjeta.out";
	---TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:PP_MENSAJES
	WHERE cve_mensaje = "00";

	IF p_NumTar <> "" AND p_NumTar IS NOT NULL  THEN
		IF EXISTS (SELECT {INDEX (bdicheq:sc_tarjeta ix_tarjeta2)} num_tarjeta FROM bdicheq:sc_tarjeta WHERE num_tarjeta = p_NumTar AND empresa = '001')  THEN
			IF EXISTS(SELECT {INDEX (bdicheq:sc_tarjeta ix_tarjeta2)} c.numcte FROM bdinteg:si_cliente c, bdicheq:sc_tarjeta t WHERE c.empresa= t.empresa AND c.numcte = t.numcte AND t.empresa = '001' AND num_tarjeta = p_NumTar) THEN
				SELECT {INDEX (bdicheq:sc_tarjeta ix_tarjeta2)} c.numcte, (TRIM(c.nombre1)|| "  " ||TRIM(c.nombre2)|| "  " ||TRIM(c.apell_paterno)|| "  " ||TRIM(c.apell_materno))
				INTO v_NumCte, v_NomCte
				FROM bdinteg:si_cliente c, bdicheq:sc_tarjeta t 
				WHERE c.empresa= t.empresa 
				AND c.numcte = t.numcte 
                AND t.empresa = '001'    
				AND num_tarjeta = p_NumTar;
			
				RETURN v_cod_ret, v_NumCte,v_NomCte WITH RESUME;
			ELSE
				SELECT cod_ret
				INTO v_cod_ret
				FROM  BDIPROG:PP_MENSAJES
				WHERE cve_mensaje = "09";
				
				RETURN v_cod_ret, NULL, NULL;
			END IF
		ELSE
			SELECT cod_ret
			INTO v_cod_ret
			FROM  BDIPROG:PP_MENSAJES
			WHERE cve_mensaje = "133";
			
			RETURN v_cod_ret, NULL, NULL;
		END IF 

	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:PP_MENSAJES
		WHERE cve_mensaje = "01";
		
		RETURN v_cod_ret, NULL, NULL;
	END IF

END;
--##############################################################################
--## Procedimiento   : sp_ConsultaClientePorTarjeta
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre del 2008
--##Descripcion : Consulta el cliente atraves del numero de tarjeta
--##############################################################################
END PROCEDURE;