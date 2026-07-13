CREATE PROCEDURE "informix".sp_consultacatalogotiposdepago()
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(100); --- codigo  mas descripcion del banco

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(100);

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

    --RETURN "01850", NULL;  --Este return estaba descomentado 

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:PP_MENSAJES
	WHERE cve_mensaje = "00";

	--IF EXISTS (SELECT cve_pago FROM BDIPROG:PP_TPPAGO WHERE cve_pago = "05") THEN
		--FOREACH
			SELECT cve_pago|| "  " ||descripcion
			INTO v_CodDesc
			FROM  BDIPROG:PP_TPPAGO WHERE cve_pago = "05"; --Se agrego el WHERE para que solo muestre Pago de Tarjeta de Credito Bancoppel Visa
			RETURN v_cod_ret, v_CodDesc; --WITH RESUME;

		--END FOREACH;
	--ELSE
		--RETURN "99999", NULL;
	--END IF

END;
--##############################################################################
--## Procedimiento   : sp_ConsultaCatalogoTiposDePago
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃÂÃÂ³n
--## Fecha creacion  : Diciembre de 2008
--##Descripcion : Consulta del catalogo de los tipos de pago existentes en el banco
--##############################################################################
END PROCEDURE;