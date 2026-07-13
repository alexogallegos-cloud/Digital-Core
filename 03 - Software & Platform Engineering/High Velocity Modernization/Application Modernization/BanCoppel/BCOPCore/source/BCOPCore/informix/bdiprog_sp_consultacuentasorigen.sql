CREATE PROCEDURE "informix".sp_consultacuentasorigen(p_NumCte CHAR(20), p_ClavePago CHAR(2),iRegistros SMALLINT)
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(20); ---cuenta

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);
	DEFINE v_CtaOrigen			CHAR(20);

	LET v_CodDesc			    = "";
	LET v_CtaOrigen			= "";

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
        RETURN v_cod_ret, NULL;
    END EXCEPTION;

	---SET DEBUG FILE TO "/tmp/has/sp_ConsultaCuentasOrigen.out";
	---TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:PP_MENSAJES
	WHERE cve_mensaje = "00";

	IF p_NumCte <> "" AND p_NumCte IS NOT NULL  THEN
        IF EXISTS (SELECT   DISTINCT cuenta
                   FROM bdicheq:sc_maechq
                   WHERE num_cte = p_NumCte
--                   AND status_cta = 1
		   AND status_cta <> '2'
                   AND producto IN (SELECT producto FROM bdiprog:pp_producperm WHERE cve_pago = p_ClavePago AND permite_prog = 'S'))  THEN
			FOREACH
				SELECT  SKIP iRegistros DISTINCT cuenta
				INTO v_CtaOrigen
				FROM bdicheq:sc_maechq
				WHERE num_cte = p_NumCte
--				AND status_cta = 1
				AND status_cta <> '2'
                AND producto IN (SELECT producto FROM bdiprog:pp_producperm WHERE cve_pago = p_ClavePago AND permite_prog = 'S')

				RETURN v_cod_ret, v_CtaOrigen  WITH RESUME;
			END FOREACH;
		ELSE
			SELECT cod_ret
			INTO v_cod_ret
			FROM  BDIPROG:PP_MENSAJES
			WHERE cve_mensaje = "13";

			RETURN v_cod_ret, NULL;
		END IF

	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:PP_MENSAJES
		WHERE cve_mensaje = "01";

		RETURN v_cod_ret, NULL;
	END IF

END;
--##############################################################################
--## Procedimiento   : sp_ConsultaCuentasOrigen
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Solicito        : Jose Angel Lopez Adams
--## Fecha creacion  : Diciembre de 2008
--##Descripcion : Consulta las cuentas efectivas que tiene  dadas de alta un cliente
--##############################################################################
END PROCEDURE;