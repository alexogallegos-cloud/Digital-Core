CREATE PROCEDURE "informix".sp_param_remesas_cpl(pClaveEstado CHAR(2), pTipoConsulta CHAR (1))
RETURNING CHAR(5) AS cCodRet, CHAR(5) AS cTransaccInt, CHAR(5) AS cTransServicio,CHAR (1) AS cNumIntentos,CHAR(3) AS cApprizaCode, CHAR(3) AS cChannelID, CHAR(3) AS cLocationUnit ,CHAR(3) AS cTypeCode, CHAR (3) AS cStateCode ,CHAR (3) AS cCountryCode;

--
	DEFINE sql_err			INTEGER;
	DEFINE cCodRet			CHAR(5);
	DEFINE cTransaccInt		CHAR(5);
	DEFINE cTransServicio	CHAR(5);
	DEFINE cApprizaCode		CHAR(3);
	DEFINE cChannelID		CHAR(3);
	DEFINE cTypeCode		CHAR(3);
	DEFINE cCountryCode		CHAR(3);
	DEFINE cStateCode		CHAR(3);
	DEFINE cLocationUnit	CHAR(3);
	DEFINE cNumIntentos		INT;
	DEFINE iCodParamAppriza	INT;
	DEFINE iCodParamChanID	INT;
	DEFINE iCodParamTypCode	INT;
	DEFINE iCodParamIdPais	INT;
	DEFINE iCodParamLocUnit	INT;
	DEFINE cSPCodRet 		CHAR(5);
	DEFINE iMensaje 		CHAR(50);
	DEFINE cid_ptf 			CHAR(5);
	DEFINE ccve_pais 		CHAR(3);
	DEFINE cnompais 		CHAR(20);
	DEFINE ccalle 			VARCHAR(100);
	DEFINE cnum_ext 		VARCHAR(6);
	DEFINE cnum_int 		VARCHAR(5);
	DEFINE ccve_col 		CHAR(8);
	DEFINE cnomcol 			VARCHAR(100);
	DEFINE ccve_mun 		CHAR(3);
	DEFINE cnommunicipio 	VARCHAR(60);
	DEFINE ccve_localidad 	CHAR(14);
	DEFINE cnomlocalidad 	VARCHAR(60);
	DEFINE ccp 				CHAR(5);
	DEFINE ccve_ciudad 		CHAR(3);
	DEFINE cnomciudad 		VARCHAR(60);
	DEFINE ccve_estado 		CHAR(2);
	DEFINE cnomestado 		VARCHAR(30);
	DEFINE ctel1 			VARCHAR(14);
	DEFINE ctel2 			VARCHAR(14);
	DEFINE ctipo 			VARCHAR(5);

	LET sql_err				= 0;
	LET cCodRet				= '00000';
	LET cTransaccInt		= '';
	LET cTransServicio		= '';
	LET cApprizaCode		= '';
	LET cChannelID			= '';
	LET cTypeCode			= '';
	LET cCountryCode		= '';
	LET cStateCode			= '';
	LET cLocationUnit		= '';
	LET cNumIntentos		= '';
	LET iCodParamAppriza	= 87117;
	LET iCodParamChanID		= 87123;
	LET iCodParamLocUnit	= 87118;
	LET iCodParamTypCode	= 87105;
	LET iCodParamIdPais		= 87106;

	LET cSPCodRet = '00000';
	LET iMensaje = '';
	LET cid_ptf = '';
	LET ccve_pais = '';
	LET cnompais = '';
	LET ccalle = '';
	LET cnum_ext = '';
	LET cnum_int = '';
	LET ccve_col = '';
	LET cnomcol = '';
	LET ccve_mun = '';
	LET cnommunicipio = '';
	LET ccve_localidad = '';
	LET cnomlocalidad = '';
	LET ccp = '';
	LET ccve_ciudad = '';
	LET cnomciudad = '';
	LET ccve_estado = '';
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';

--------------------------------------------------------------------------
--SET DEBUG FILE TO "/informix/BDHS/homologacionCPL/logs/sp_param_remesas_cpl.log";
--    TRACE ON;
--------------------------------------------------------------------------

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
	    RETURN cCodRet, cTransaccInt, cTransServicio, cNumIntentos,cApprizaCode, cChannelID, cLocationUnit,cTypeCode, cStateCode,cCountryCode;
      END IF;
END EXCEPTION;

	SELECT TRIM(valor)
	INTO cApprizaCode
    FROM BDISAC:"informix".sac_param
    WHERE cod_param = iCodParamAppriza;


	SELECT TRIM(valor)
	INTO cChannelID
    FROM BDISAC:"informix".sac_param
    WHERE cod_param = iCodParamChanID;

	SELECT TRIM(valor)
	INTO cLocationUnit
    FROM BDISAC:"informix".sac_param
    WHERE cod_param = iCodParamLocUnit;

	SELECT TRIM(valor)
	INTO cTypeCode
    FROM BDISAC:"informix".sac_param
    WHERE cod_param = iCodParamTypCode;

	SELECT TRIM(valor)
	INTO cCountryCode
    FROM BDISAC:"informix".sac_param
    WHERE cod_param = iCodParamIdPais;

	SELECT trans_interact, trans_servicio,campo_codresp::INT
	INTO cTransaccInt,cTransServicio,cNumIntentos
	FROM BDISAC:"informix".sac_intrfz_serv
	WHERE numcategoria = '07'
	AND numconvenio = '009'
	AND num_trama = pTipoConsulta;

	SELECT state_cd
	INTO cStateCode
	FROM BDISAC:"informix".sac_app_catestados
	WHERE cve_estado = pClaveEstado;

	IF cTransaccInt IS NULL OR cTransServicio IS NULL  OR cApprizaCode IS NULL OR cChannelID IS NULL OR cTypeCode IS NULL OR cCountryCode IS NULL OR cStateCode IS NULL THEN
		LET cCodRet = '99999';
	END IF;
	--
	RETURN cCodRet, cTransaccInt, cTransServicio, cNumIntentos,cApprizaCode, cChannelID, cLocationUnit,cTypeCode, cStateCode,cCountryCode;


   END;
END PROCEDURE;