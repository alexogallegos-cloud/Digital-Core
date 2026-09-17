CREATE PROCEDURE "informix".sp_consultacatalogobancos(p_Registros smallint)
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(50); --- codigo  mas descripcion del banco

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);
	DEFINE v_ContReg			SMALLINT;

	LET v_CodDesc			 	= "";
	LET v_ContReg			 	= 0;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL;
    END EXCEPTION;
	
	--SET DEBUG FILE TO  "/home/informix/ivonne/sp_consultacatalogobancos.out";
	--TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:PP_MENSAJES
	WHERE cve_mensaje = "00";

	IF EXISTS (SELECT BANCO FROM BDINTEG:SI_BANCOS) THEN
		FOREACH
			select banco || " " ||
				(CASE
					WHEN TRIM(vchrnombrecorto) = ''
				THEN descripcion
				ELSE
					vchrnombrecorto
					END) 
			INTO v_CodDesc
			FROM  BDINTEG:SI_BANCOS WHERE banco <> '001'
			ORDER BY banco

			LET v_ContReg = v_ContReg + 1;

			IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
				CONTINUE FOREACH;
            END IF;

			RETURN v_cod_ret, v_CodDesc WITH RESUME;


		END FOREACH;
	ELSE
		RETURN "99999", NULL;
	END IF


END;
--##############################################################################
--## Procedimiento   : sp_ConsultaCatalogoBancos
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--##Descripcion : Consulta del catalogo de bancos de la integral
--##############################################################################
END PROCEDURE;