CREATE PROCEDURE "informix".sp_consultarprogramaciondetallada_bpi(PCVE_PROG CHAR(10), PCVE_ESTADO CHAR(2),  siRegistros SMALLINT)
RETURNING
     CHAR(6), ---cod_ret
	 INTEGER, ---consecutivo
	 DATE, ---fecha prog
	 CHAR(30), ---edescripcion del stado
	 DATE; ---fecha estado

    DEFINE v_cod_ret            CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              VARCHAR(60);
	DEFINE v_consecutivo		INTEGER;
	DEFINE v_fecha_prog			DATE;
	DEFINE v_DescEstado			CHAR(30);
	DEFINE v_FechaEstado		DATE;
    DEFINE siCiclo              SMALLINT;

    LET siCiclo               = 0;

	SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret,NULL,NULL,NULL,NULL;
    END EXCEPTION;


	SELECT cod_ret, desc_mensaje
	INTO v_cod_ret,vDesErr
	FROM  BDIPROG:PP_MENSAJES
	WHERE cve_mensaje = "00";

	LET v_consecutivo		= 0;
	LET v_fecha_prog		= "";
	LET v_DescEstado		= "";
	LET v_FechaEstado		= "";


	IF (PCVE_PROG IS NOT NULL AND PCVE_PROG <> "") AND (PCVE_ESTADO IS NOT NULL AND PCVE_ESTADO <> "") THEN
		IF EXISTS(SELECT CVE_PAGOPROG FROM BDIPROG:PP_PAGOSPEND WHERE CVE_PAGOPROG = PCVE_PROG) THEN
			IF EXISTS(SELECT cve_estado FROM BDIPROG:PP_ESTADOS WHERE cve_estado = PCVE_ESTADO) OR PCVE_ESTADO = "99" THEN
				IF EXISTS(SELECT CVE_PAGOPROG FROM BDIPROG:PP_PAGOSPEND WHERE CVE_PAGOPROG = PCVE_PROG AND ESTADO = DECODE(PCVE_ESTADO,"99",ESTADO,PCVE_ESTADO) ) THEN
					FOREACH
						SELECT SKIP siRegistros FIRST 10 consecutivo, fecha_prog, e.descripcion, DECODE(ppe.estado,'02',ppe.fecha_cancela,'06',ppe.fecha_cancela,'05',ppe.fecha_aplic)
						INTO v_consecutivo, v_fecha_prog, v_DescEstado, v_FechaEstado
						FROM BDIPROG:PP_PAGOSPEND ppe, bdiprog: pp_estados e
						WHERE ppe.CVE_PAGOPROG = PCVE_PROG
						AND ppe.ESTADO = DECODE(PCVE_ESTADO,"99",ESTADO,PCVE_ESTADO)
						and ppe.estado = e.cve_estado
                        ORDER BY consecutivo

                       -- LET siCiclo = siCiclo + 1;

                        --IF siCiclo <= siRegistros THEN
                        --CONTINUE FOREACH;
                        --END IF;

						RETURN v_cod_ret,v_consecutivo, v_fecha_prog, v_DescEstado, v_FechaEstado WITH RESUME;

					END FOREACH;

				ELSE
					SELECT cod_ret
					INTO v_cod_ret
					FROM  BDIPROG:PP_MENSAJES
					WHERE cve_mensaje = "94";

					RETURN v_cod_ret,NULL,NULL,NULL,NULL;
				END IF
			ELSE
				SELECT cod_ret
				INTO v_cod_ret
				FROM  BDIPROG:PP_MENSAJES
				WHERE cve_mensaje = "87";

				RETURN v_cod_ret,NULL,NULL,NULL,NULL;
			END IF
		ELSE
			SELECT cod_ret
			INTO v_cod_ret
			FROM  BDIPROG:PP_MENSAJES
			WHERE cve_mensaje = "92";

			RETURN v_cod_ret,NULL,NULL,NULL,NULL;
		END IF

	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM BDIPROG:PP_MENSAJES
		WHERE cve_mensaje = "01";

		RETURN v_cod_ret,NULL,NULL,NULL,NULL;
	END IF

END;
--##############################################################################
--## Procedimiento   : sp_ConsultarProgramacionDetalladaVersion2
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--##Descripcion : Consulta el detalle de la programacion de una clave
--## Version: 20090119.0949
--##############################################################################
END PROCEDURE;