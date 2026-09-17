CREATE PROCEDURE "informix".sp_validarfc(p_sRfc CHAR(13))
	RETURNING CHAR(5);
	 --*************************************************
     --Creado por: Alejandro Osuna                   			--*
     -- Actividad: Valida que el RFC en su formato sea correcto
     --  Solicitó: Jorge Nuñes                    			--*
     --     Fecha: 19 de enero de 2009

	DEFINE v_sCodRet   		CHAR(5);
	DEFINE v_sPrimerRFC    CHAR(4);
	DEFINE v_sSegundoRFC    CHAR(6);
	DEFINE v_sTercerRFC		CHAR(3);
	DEFINE v_sCadena		CHAR(13);
	DEFINE v_sCadenados		CHAR(13);
	DEFINE v_iLongitud		INTEGER;
	DEFINE v_iInicio		INTEGER;
	DEFINE v_sfinciclo		CHAR(1);
	DEFINE p_svalor			CHAR(1);
	DEFINE v_sLongRFC		INTEGER;
	DEFINE v_sLongPri		INTEGER;
	DEFINE v_sLongSeg		INTEGER;
	DEFINE v_sLongTer		INTEGER;


	LET v_scadena = '';
	LET  v_sTercerRFC	= '';
	LET v_sSegundoRFC = '';
	LET v_sPrimerRFC = '';
	LET v_sCodRet = '';
	LET p_svalor = '';

	--SET DEBUG FILE TO "/tmp/sp_validarfc.out";
	--TRACE ON;

	--- Se Divide el RFC en partes
		--PRimera parte solo debe de contener Caracteres y debe de tener un tamaño de 4 caracteres
	LET  v_sPrimerRFC = SUBSTR(p_sRfc,1,4);
		--Segunda parte solo debe de contener digitos y debe de tener un tamaño de 6 caracteres
	LET v_sSegundoRFC = SUBSTR(p_sRfc,5,6);
		--TErcera parte solo debe de contener alfanumericos y debe de tener un tamaño de 3 caracteres
	LET v_sTercerRFC = SUBSTR(p_sRfc,11,3);

		--se valida la longitud de las cadenas.
	LET v_sLongRFC = LENGTH(p_sRfc);
	LET v_sLongPri = LENGTH(v_sPrimerRFC);
	LET v_sLongSeg = LENGTH(v_sSegundoRFC);
	LET v_sLongTer = LENGTH(v_sTercerRFC);
	IF (v_sLongRFC = 13 ) AND (v_sLongPri = 4 ) AND (v_sLongSeg = 6 ) AND (v_sLongTer = 3 ) THEN
	ELSE
		LET v_sCodRet = '004';
		RETURN v_sCodRet;
	END IF;

	--se valida la primera parte
	LET v_sCadena = TRIM(v_sPrimerRFC);
	LET v_iLongitud = LENGTH(v_sCadena);
	LET v_iInicio = 1;
	LET v_sfinciclo = 'F';

	while (v_iInicio <= v_iLongitud) and (v_sfinciclo = 'F')
		LET v_sCadenados = substr(v_sCadena,v_iInicio,1);
		IF ((v_sCadenados >= 'A') and (v_sCadenados <= 'Z')) or ((v_sCadenados >= 'a') and (v_sCadenados <= 'z')) AND (v_sCadenados <> '') THEN
			LET p_svalor = 'A';
		ELSE
			LET p_svalor = 'B';
			LET v_sfinciclo = 'T';
		END IF;
		LET v_iInicio = (v_iInicio + 1);
	END WHILE;
	IF  p_svalor = 'B' THEN
		--SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '40';
		LET v_sCodRet = '001';
		RETURN v_sCodRet;
	END IF;

	--se valida la segunda parte
	LET v_sCadena = '';
	LET v_iLongitud = '';
	LET v_sCadena = TRIM(v_sSegundoRFC);
	LET v_iLongitud = length(v_sCadena);
	LET v_iInicio = 1;
	LET v_sfinciclo = 'F';

	while (v_iInicio <= v_iLongitud) and (v_sfinciclo = 'F')
		LET v_sCadenados = substr(v_sCadena,v_iInicio,1);
		IF ((v_sCadenados >= '0')  and (v_sCadenados <= '9')) AND (v_sCadenados <> '') THEN
			LET p_svalor = 'A';
		ELSE
			LET p_svalor = 'B';
			LET v_sfinciclo = 'T';
		END IF;
		LET v_iInicio = (v_iInicio + 1);
	END WHILE;
	IF  p_svalor = 'B' THEN
		--SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '40';
		LET v_sCodRet = '002';
		RETURN v_sCodRet;
	END IF;

	--	 se valida la tercera parte
	LET v_sCadena = '';
	LET v_iLongitud = '';
	LET v_sCadena = TRIM(v_sTercerRFC);
	LET v_iLongitud = length(v_sCadena);
	LET v_iInicio = 1;
	LET v_sfinciclo = 'F';

	while (v_iInicio <= v_iLongitud) and (v_sfinciclo = 'F')
		LET v_sCadenados = substr(v_sCadena,v_iInicio,1);
		IF ((v_sCadenados >= 'A') and (v_sCadenados <= 'Z')) or ((v_sCadenados >= 'a') and (v_sCadenados <= 'z')) or ((v_sCadenados >= '0')  and (v_sCadenados <= '9')) AND (v_sCadenados <> '') THEN
			LET p_svalor = 'A';
		ELSE
			LET p_svalor = 'B';
			LET v_sfinciclo = 'T';
		END IF;
		LET v_iInicio = (v_iInicio + 1);
	END WHILE;
	IF  p_svalor = 'B' THEN
		--SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '40';
		LET v_sCodRet = '003';
		RETURN v_sCodRet;
	END IF;

	LET v_sCodRet = '000';
	RETURN v_sCodRet;

END PROCEDURE;