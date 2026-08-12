CREATE PROCEDURE "informix".sp_consulta_huella_dec_temp(
pNumcte CHAR(20)
)

RETURNING
CHAR(5)    AS cCodigoRet,
SMALLINT   AS sSecuencia,
SMALLINT   AS sIdTemplate,
CHAR(1000) AS cTemplate,
CHAR(25)   AS cImagen,
CHAR(50)   AS cRutaimg;

DEFINE sql_err INTEGER;
DEFINE cCodigoRet CHAR(5);
DEFINE sSecuencia SMALLINT;
DEFINE sIdTemplate SMALLINT;
DEFINE cTemplate CHAR(1000);
DEFINE cImagen CHAR(25);
DEFINE cRutaimg CHAR(50);
DEFINE sSecuenciaCambiar SMALLINT;
DEFINE sIdTemplateCambiar SMALLINT;
DEFINE cTemplateCambiar CHAR(1000);
DEFINE cImagenCambiar CHAR(25);
DEFINE cRutaimgCambiar CHAR(50);

LET cCodigoRet = '00000';
LET sSecuencia = 0;
LET sIdTemplate = 0;
LET cTemplate = '';
LET cImagen = '';
LET cRutaimg = '';
LET sSecuenciaCambiar = 0;
LET sIdTemplateCambiar = 0;
LET cTemplateCambiar = '';
LET cImagenCambiar = '';
LET cRutaimgCambiar = '';

BEGIN
 
    ON EXCEPTION SET sql_err

		RETURN sql_err, sSecuencia, sIdTemplate, cTemplate, cImagen, cRutaimg;

    END EXCEPTION;

	-- SET DEBUG FILE TO "/home/sysifx/Mario/trace.sql";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--VALIDAR DATOS VACIOS
	IF NVL(pNumcte,'') = '' THEN	
		LET cCodigoRet = '00001'; --Datos vacios
		RETURN cCodigoRet, sSecuencia, sIdTemplate, cTemplate, cImagen, cRutaimg;
	ELSE 	
		FOREACH
			SELECT secuencia, id_template, Template, Imagen, Rutaimg 
			INTO sSecuenciaCambiar, sIdTemplateCambiar, cTemplateCambiar, cImagenCambiar, cRutaimgCambiar 
			FROM "informix".si_cte_huella_dec_temp WHERE numcte = pNumcte
			LET sSecuencia = sSecuenciaCambiar;
			LET sIdTemplate = sIdTemplateCambiar;
			LET cTemplate = cTemplateCambiar;
			LET cImagen = cImagenCambiar;
			LET cRutaimg = cRutaimgCambiar;
			RETURN cCodigoRet, sSecuencia, sIdTemplate, cTemplate, cImagen, cRutaimg WITH RESUME;
		END FOREACH;
	END IF;
 
END;
END PROCEDURE;