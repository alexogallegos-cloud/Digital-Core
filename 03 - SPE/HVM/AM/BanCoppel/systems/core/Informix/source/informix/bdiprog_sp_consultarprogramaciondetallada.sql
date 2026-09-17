CREATE PROCEDURE "informix".sp_consultarprogramaciondetallada(PCVE_PROG CHAR(10), PCVE_ESTADO CHAR(2))

RETURNING
     CHAR(6), ---cod_ret
     CHAR(100), ---desc
	 CHAR(10), ---clave de prog
	 INTEGER, ---consecutivo
	 DATE, ---fecha prog
	 CHAR(2), ---estado
	 DATE, ---fecha aplic
	 CHAR(16), ---folio suc
	 CHAR(8), ---user insert
	 DATE, ---fecha insert
	 CHAR(8), ---user cancela
	 DATE, ---fecha cancela
	 CHAR(2), ---canal cancela
	 CHAR(2);



--##############################################################################
--## Procedimiento   : sp_ConsultarProgramacionDetallada
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Noviembre de 2008
--##############################################################################

    DEFINE v_cod_ret            CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              VARCHAR(60);
	DEFINE v_cve_pagoprog		CHAR(10);
	DEFINE v_consecutivo		INTEGER;
	DEFINE v_fecha_prog			DATE;
	DEFINE v_estado				CHAR(2);
	DEFINE v_fecha_aplic		DATE;
	DEFINE v_folio_suc			CHAR(16);
	DEFINE v_user_insert		CHAR(8);
	DEFINE v_fecha_insert		DATE;
	DEFINE v_user_cancela		CHAR(8);
	DEFINE v_fecha_cancela		DATE;
	DEFINE v_canal_cancela		CHAR(2);
	DEFINE v_cve_rechazo		CHAR(2);



   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, vDesErr,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;


	SELECT cod_ret, desc_mensaje
	INTO v_cod_ret,vDesErr
	FROM  BDIPROG:PP_MENSAJES
	WHERE cve_mensaje = "00";

	LET v_cve_pagoprog		= "";
	LET v_consecutivo		= 0;
	LET v_fecha_prog		= "";
	LET v_estado			= "";
	LET v_fecha_aplic		= "";
	LET v_folio_suc			= "";
	LET v_user_insert		= "";
	LET v_fecha_insert		= "";
	LET v_user_cancela		= "";
	LET v_fecha_cancela		= "";
	LET v_canal_cancela		= "";
	LET v_cve_rechazo		= "";


	IF (PCVE_PROG IS NOT NULL AND PCVE_PROG <> "") AND (PCVE_ESTADO IS NOT NULL AND PCVE_ESTADO <> "") THEN
		IF EXISTS(SELECT CVE_PAGOPROG FROM BDIPROG:PP_PAGOSPEND WHERE CVE_PAGOPROG = PCVE_PROG) THEN
			IF EXISTS(SELECT cve_estado FROM BDIPROG:PP_ESTADOS WHERE cve_estado = PCVE_ESTADO) OR PCVE_ESTADO = "99" THEN
				IF EXISTS(SELECT CVE_PAGOPROG FROM BDIPROG:PP_PAGOSPEND WHERE CVE_PAGOPROG = PCVE_PROG AND ESTADO = DECODE(PCVE_ESTADO,"99",ESTADO,PCVE_ESTADO) ) THEN
					FOREACH
						SELECT cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela,  canal_cancela, cve_rechazo
						INTO v_cve_pagoprog, v_consecutivo, v_fecha_prog, v_estado, v_fecha_aplic, v_folio_suc, v_user_insert, v_fecha_insert, v_user_cancela, v_fecha_cancela,  v_canal_cancela, v_cve_rechazo
						FROM BDIPROG:PP_PAGOSPEND
						WHERE CVE_PAGOPROG = PCVE_PROG
						AND ESTADO = DECODE(PCVE_ESTADO,"99",ESTADO,PCVE_ESTADO)
						RETURN v_cod_ret,vDesErr, v_cve_pagoprog, v_consecutivo, v_fecha_prog, v_estado, v_fecha_aplic, v_folio_suc, v_user_insert, v_fecha_insert, v_user_cancela, v_fecha_cancela,  v_canal_cancela, v_cve_rechazo
						WITH RESUME;
					END FOREACH;
				ELSE
					SELECT cod_ret, desc_mensaje
					INTO v_cod_ret,vDesErr
					FROM  BDIPROG:PP_MENSAJES
					WHERE cve_mensaje = "94";

					RETURN v_cod_ret,vDesErr,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
				END IF
			ELSE
				SELECT cod_ret, desc_mensaje
				INTO v_cod_ret,vDesErr
				FROM  BDIPROG:PP_MENSAJES
				WHERE cve_mensaje = "87";

				RETURN v_cod_ret,vDesErr,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
			END IF
		ELSE
			SELECT cod_ret, desc_mensaje
			INTO v_cod_ret,vDesErr
			FROM  BDIPROG:PP_MENSAJES
			WHERE cve_mensaje = "92";

			RETURN v_cod_ret,vDesErr,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
		END IF

	ELSE
		SELECT cod_ret, desc_mensaje
		INTO v_cod_ret,vDesErr
		FROM BDIPROG:PP_MENSAJES
		WHERE cve_mensaje = "01";

		RETURN v_cod_ret,vDesErr,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF


END PROCEDURE;