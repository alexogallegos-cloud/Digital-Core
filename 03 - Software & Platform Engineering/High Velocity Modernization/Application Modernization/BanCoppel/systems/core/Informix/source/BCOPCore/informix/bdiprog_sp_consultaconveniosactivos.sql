CREATE PROCEDURE "informix".sp_consultaconveniosactivos()

RETURNING
     CHAR(6), ---cod_ret
	 CHAR(5), --- numero de categoria mas numero de convenio
     CHAR(50), ---descripcion
     CHAR(13); --- RFC

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_Cve				CHAR(5);
	DEFINE v_CodDesc			CHAR(40);
    DEFINE v_RFCEmpresa         CHAR(13);

	LET v_CodDesc			 = "";
	LET v_Cve				 = "";

	SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL;
    END EXCEPTION;

	SELECT {+INDEX (bdiprog:pp_mensajes 106_11)} cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:PP_MENSAJES
	WHERE cve_mensaje = "00";

	IF EXISTS (SELECT {+INDEX (bdisac: sac_convenios 103_9)} numconvenio FROM  bdisac: sac_convenios WHERE statusconvenio = "A" AND pagos_prog=1) THEN
		FOREACH
            SELECT {+INDEX (bdisac: sac_convenios 103_9)} numcategoria || numconvenio, nomconvenio, rfcempresa
            INTO v_Cve,v_CodDesc, v_RFCEmpresa
			FROM  bdisac: sac_convenios
			WHERE statusconvenio = "A" AND pagos_prog=1
			order by numcategoria,numconvenio

            RETURN v_cod_ret, v_Cve, v_CodDesc, v_RFCEmpresa WITH RESUME;

		END FOREACH;
	ELSE
        RETURN "99999", NULL,NULL,NULL;
	END IF

END;
--##############################################################################
--## Procedimiento   : sp_ConsultaConveniosActivos
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--##Descripcion : Consulta del catalogo de los convenios activos del banco
--## Modificado por  : Raul Ruiz
--## Fecha modificacion: Abril de 2009
--##############################################################################
END PROCEDURE;