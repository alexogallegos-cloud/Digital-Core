CREATE PROCEDURE "informix".sp_consultadiassemana()
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(2),
	 CHAR(50); --- codigo  mas descripcion del banco

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_Cve				CHAR(2);
	DEFINE v_CodDesc			CHAR(50);

	LET v_CodDesc			 = "";
	LET v_Cve				 = "";

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL;
    END EXCEPTION;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:PP_MENSAJES
	WHERE cve_mensaje = "00";

	IF EXISTS (select  cve_dia  from  bdiprog: pp_diassemana) THEN
		FOREACH
			SELECT cve_dia ,descripcion
			INTO v_Cve,v_CodDesc
			FROM  bdiprog: pp_diassemana
			RETURN v_cod_ret, v_Cve, v_CodDesc WITH RESUME;

		END FOREACH;
	ELSE
		RETURN "99999", NULL,NULL;
	END IF

END;
--##############################################################################
--## Procedimiento   : sp_ConsultaDiasSemana
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--##Descripcion : Consulta del catalogo de dias de la semana
--##############################################################################
END PROCEDURE;