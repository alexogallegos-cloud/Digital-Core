CREATE PROCEDURE "informix".considentificacion_web(p_numcte char(10))
   RETURNING CHAR(5), CHAR(20), CHAR(20);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_tipoIdent		CHAR(50);
   DEFINE v_noIdent			CHAR(50);

   LET v_tipoIdent = "";
   LET v_noIdent   = "";
	

	--SET DEBUG FILE TO "/respaldosbd/mario/trace.sql";
	--TRACE ON;
BEGIN	
	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cod_ret = sql_err;
		RETURN  NVL(cod_ret,'00001'),NVL(v_tipoIdent,''), NVL(v_noIdent,'');
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET cod_ret = '00000';
	LET p_mensaje = "Operacion Realizada Exitosamente";	

	SELECT trim(tipo_ident),trim(num_ident)
	INTO v_tipoIdent,v_noIdent 
	FROM "informix".si_bitmant_huellarostro
    	WHERE numcte = trim(p_numcte) AND  fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:"informix".si_bitmant_huellarostro WHERE NUMCTE = trim(p_numcte));
    
    IF trim(v_noIdent) is null then
		let cod_ret = "00104";
		RETURN  NVL(cod_ret,'00001'),NVL(v_tipoIdent,''), NVL(v_noIdent,'');
    end if

    RETURN  NVL(cod_ret,'00001'),NVL(v_tipoIdent,''), NVL(v_noIdent,'');
END
END PROCEDURE

DOCUMENT
'SPL Extrae tipo y numero de identificacion ingresados en manhuella',
"MODIFICO : CRISTIAN IBARRA",
"FECHA : 27/Febrero/2021",
"Ver.  : 1.0",
"BD    : bdinteg";

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