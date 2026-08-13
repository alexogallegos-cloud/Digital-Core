CREATE PROCEDURE "informix".sp_llenaredcarrier()
RETURNING CHAR(5);

--Definición de variables
DEFINE 	sql_err			INTEGER;
DEFINE 	isam_err		INTEGER;
DEFINE 	error_info		CHAR(80);
DEFINE 	cMensaje		CHAR(80);
DEFINE 	cCod_ret		CHAR(6);
DEFINE 	vproceso		CHAR(30);
DEFINE	vempresa		CHAR(3);
DEFINE 	vtelefono 		CHAR(10);
DEFINE	vtelaux			CHAR(3);
DEFINE	vtelaux2		CHAR(13);
DEFINE	vtipored 		CHAR(10);
DEFINE	vnumero_carrier	CHAR(3);
DEFINE 	vCod_ret		CHAR(5);
DEFINE	vnumcte			CHAR(20);
DEFINE	vTipoTel        SMALLINT;
DEFINE  vorigen			SMALLINT;

--Inicialización de variables
LET cCod_ret = '000000';
LET sql_err = 0;
LET isam_err = 0;
LET error_info = '';
LET cMensaje = 'PROCESO EXITOSO';
LET vproceso = 'carr';
LET vempresa = '001';
LET vtelefono = '';
LET vtipored = '';
LET vnumero_carrier = '';
LET vCod_ret = '00000';
LET vnumcte = '';

BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02');
        RETURN cCod_ret;
	END EXCEPTION;

    CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01');

FOREACH

	SELECT SUBSTR(a.telefono,1,3), telefono, telefono , numcte , origen
    INTO vtelaux , vtelefono, vtelaux2 , vnumcte , vorigen
	FROM bdicobranza:cb_telefonos a
	WHERE empresa = '001'
    --AND nvl(numero_carrier,0) =0

	IF vtelaux = '045' THEN
		LET vtelefono = SUBSTR(vtelefono,4,10);
	END IF;

	EXECUTE PROCEDURE bdinteg:"informix".sp_tipored ('001', vtelefono) into vCod_ret , vtipored , vnumero_carrier;

	IF vtelaux ='045' THEN
		UPDATE {+INDEX(bdicobranza:cb_telefonos idx_pk_cb_telefonos)} bdicobranza:"informix".cb_telefonos 
                   SET tipored = vtipored , numero_carrier = vnumero_carrier 
                 WHERE empresa = '001' 
                   and numcte = vnumcte 
                   and telefono = vtelaux2 
                   and origen = vorigen;
	ELSE
		UPDATE {+INDEX(bdicobranza:cb_telefonos idx_pk_cb_telefonos)}  bdicobranza:"informix".cb_telefonos SET tipored = vtipored , numero_carrier = vnumero_carrier WHERE empresa = '001' and numcte = vnumcte and telefono = vtelefono and origen = vorigen;
	END IF;

END FOREACH;

CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '03');

RETURN cCod_ret;

END;
END PROCEDURE;