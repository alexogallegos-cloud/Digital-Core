CREATE PROCEDURE "informix".sp_consultacatalogotipocuentas()
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(50); --- codigo  mas descripcion del banco

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);

	LET v_CodDesc			 = "";

	SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL;
    END EXCEPTION;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:PP_MENSAJES
	WHERE cve_mensaje = "00";

	IF EXISTS (SELECT cve_cuenta FROM BDIPROG:PP_TPCUENTA) THEN
		FOREACH
			SELECT cve_cuenta|| "  " ||descripcion
			INTO v_CodDesc
			FROM  BDIPROG:PP_TPCUENTA
			RETURN v_cod_ret, v_CodDesc WITH RESUME;

		END FOREACH;
	ELSE
		RETURN "99999",  NULL;
	END IF

END;
--##############################################################################
--## Procedimiento   : sp_ConsultaCatalogoTipoCuentas
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--##Descripcion : Consulta del catalogo de los tipos de cuentas existentes en el banco
--##############################################################################
END PROCEDURE;