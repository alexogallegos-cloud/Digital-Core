CREATE PROCEDURE "informix".sp_valida_comprobante(pEmpresa     CHAR(3),
                                                  pNumCte      CHAR(20),
												  pNumSol      CHAR(20))
RETURNING CHAR(6)           AS cod_ret,
          VARCHAR(100,1)    AS mensaje_ret,
          SMALLINT          AS Valido; --0 no digitalizo comproante de ingreso, 1 si digitalizo

DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      VARCHAR(255,1);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(100,1);

DEFINE dtFechavalida  		DATE; 
DEFINE dtFechaHoy   		DATE;
DEFINE dcSalariomin 		DECIMAL(14,2);
DEFINE dcDiaspromedio 		DECIMAL(14,2);
DEFINE dcVeces_smb 			DECIMAL(14,2);
DEFINE dcIngresoRevisionCAC  DECIMAL(18,2);
DEFINE dcIngreso  			DECIMAL(18,2);
DEFINE iComproboingreso  	INTEGER;
DEFINE iValido  			INTEGER;
DEFINE dtHora_sistema  		DATETIME HOUR TO SECOND;
DEFINE dtHora_inicio  		DATETIME HOUR TO SECOND;
DEFINE dtHora_fin 			DATETIME HOUR TO SECOND;

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET cMensajeRet        = "Consulta exitosa";

LET dtFechavalida  		= DATE(1);
LET dtFechaHoy  		= DATE(1);
LET dcSalariomin  		= 0.00;
LET dcDiaspromedio  	= 0.00;
LET dcVeces_smb  		= 0.00;
LET dcIngresoRevisionCAC = 0.00;
LET dcIngreso  			= 0;
LET iComproboingreso  	= 0;
LET iValido  			= 0;

LET dtHora_sistema  	= '00:00:00';
LET dtHora_inicio  		= '00:00:00';
LET dtHora_fin  		= '00:00:00';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN TRIM(cCodRet),cMensajeRet,NVL(iValido,0);
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/respaldosbd/josue/sp_valida_comprobante.out';
--TRACE ON;

IF  NVL(pEmpresa,"") = "" OR NVL(pNumCte,"") = "" OR NVL(pNumSol,"") = ""  THEN
	LET cCodRet            = "000001";
	LET cMensajeRet        = "FALTA PARÃMETRO DE ENTREDA REQUERIDO PARA CONSULTA";
	RETURN  TRIM(cCodRet),cMensajeRet,NVL(iValido,0);
END IF;

	-- SE TOMA LA HORA DE EL SISTEMA
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
	INTO dtHora_sistema
	FROM sysmaster:"informix".sysshmvals;	

		-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			LET cCodRet = "452";
			LET cMensajeRet = "";
			RETURN  TRIM(cCodRet),cMensajeRet,NVL(iValido,0);
		END IF;     

	-- SE TOMA LA HORA DE INICIO DE ATENCIÃN DE MESA DE CONTROL
	SELECT valor INTO dtHora_inicio FROM "informix".ss_param WHERE secuencia = '368'; 

		-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			LET cCodRet = "452";
			LET cMensajeRet = "";
			RETURN  TRIM(cCodRet),cMensajeRet,NVL(iValido,0);
		END IF;
		
		
	-- SE TOMA LA HORA DE FIN DE ATENCIÃN DE MESA DE CONTROL
	SELECT valor INTO dtHora_fin FROM "informix".ss_param WHERE secuencia = '369';

		-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			LET cCodRet = "452";
			LET cMensajeRet = "";
			RETURN  TRIM(cCodRet),cMensajeRet,NVL(iValido,0);
		END IF;
	
	-- SE VALIDA QUE EL HORARIO DE EL SISTEMA ESTE DENTRO DE EL HORARIO PERMITIDO SI NO SE REGRESA UN CÃDIGO Y MENSAJE DE ERROR
	IF dtHora_sistema < dtHora_inicio OR dtHora_sistema > dtHora_fin THEN
		LET cCodRet = "000002";
		LET cMensajeRet = "HORARIO NO PERMITIDO POR MC";
		RETURN  TRIM(cCodRet),cMensajeRet,NVL(iValido,0);
	END IF
	 
	-- SE CONSULTA EL SALARIO MINIMO BASE
	SELECT valor::DECIMAL(14,2)
      INTO dcSalariomin 
	  FROM "informix".ss_param
	 WHERE empresa = pEmpresa
	   AND secuencia = 354;
	
	-- SE VALIDA QUE NO ESTE VACÃO EL SALARIO MINIMO BASE
	IF dcSalariomin IS NULL THEN
		LET cCodRet = "452";
		RETURN  TRIM(cCodRet),cMensajeRet,NVL(iValido,0);
	END IF;
	
	-- SE CONSULTA LOS DIAS PROMEDIO
	SELECT valor::DECIMAL(14,2)
      INTO dcDiaspromedio 
	  FROM "informix".ss_param
	 WHERE empresa = pEmpresa
	   AND secuencia = 355;

	-- SE VALIDA QUE NO ESTE VACÃO LOS DIAS PROMEDIO
	IF dcDiaspromedio IS NULL THEN
		LET cCodRet = "452";
		RETURN  TRIM(cCodRet),cMensajeRet,NVL(iValido,0);
	END IF;
	
	-- SE CONSULTA VECES SALARIOS MINIMO BASE PARA INGRESO A LC
	SELECT valor::DECIMAL(14,2)
      INTO dcVeces_smb 
	  FROM "informix".ss_param
	 WHERE empresa = pEmpresa
	   AND secuencia = 364;
	
	-- SE VALIDA QUE NO ESTE VACÃO VECES SALARIOS MINIMO BASE PARA INGRESO A LC
	IF dcDiaspromedio IS NULL THEN
		LET cCodRet = "452";
		RETURN  TRIM(cCodRet),cMensajeRet,NVL(iValido,0);
	END IF;
	
	-- SE CALCULA dcIngresoRevisionCAC
	LET dcIngresoRevisionCAC  = round(dcVeces_smb * dcSalariomin * dcDiaspromedio,-2) ;
   
   -- SE CONSULTA EL ingreso_mensual
	SELECT NVL(ingreso_mensual,0)
		INTO dcIngreso
	FROM "informix".ss_resum_scor_fin
	WHERE empresa = pEmpresa
	AND num_solicitud = pNumSol;

	-- SI EL INGRESO MENSUAL ES MENOR A dcIngresoRevisionCAC SE REGRESA QUE NO EXISTE UN COMPROBANTE VÃLIDO
	IF dcIngreso < dcIngresoRevisionCAC THEN
		LET iValido = 0;		
	ELSE
		-- SE CUENTAN LOS REGISTROS QUE EXISTAN DE LA SOLICITUD 
		SELECT COUNT(*)
		INTO iComproboingreso
		FROM "informix".ss_detalle_scoring
		WHERE empresa = pEmpresa
		AND num_solicitud = pNumSol
		AND seccion = 2
		AND grupo = 38
		AND elemento > 1;
		
		-- SI LA CONSULTA ANTERIOR ES NULA O IGUAL A CERO, SE REGRESA QUE NO EXISTE UN COMPROBANTE VÃLIDO
		IF iComproboingreso IS NULL THEN
			LET iComproboingreso = 0;
		END IF;

		IF iComproboingreso = 0 THEN --EN CASO DE QUE EL CLIENTE NO DIGITALICE UN COMPROBANTE DE INGRESOS AL MOMENTO DE LA SOLICITUD
			--PARA VALIDAR SI CUENTA CON UN COMPROBANTE DE INGRESOS  EN UN PERIODO DE 90 DIAS
			
			-- SE CONSULTA LA FECHA ACTUAL
			SELECT fecha_hoy
			INTO dtFechaHoy
			FROM bdicred:"informix".sd_fechas
			WHERE empresa = pEmpresa;
			
			-- SE CALCULA LA FECHA VALIDA PARA TOMAR EN CUANTA DESDE 90 DIAS ANTES A LA FECHA ACTUAL
			LET dtFechavalida = dtFechaHoy - 90 UNITS DAY;
			
			-- SE VERIFÃCA SI SE LE DIGITALIZÃ COMPROBANTE VÃLIDO O NO
			SELECT count(a.prod_nombre) 
	          INTO iComproboingreso
	          --FROM bdidigital@coppelimg_tcp:"informix".dg_expediente a
			  FROM bdidigital@coppelimg_app:"informix".dg_expediente a
			  --INNER JOIN bdidigital@coppelimg_tcp:"informix".dg_tipodocumento b	ON ( a.cod_docto = b.cod_docto AND b.cod_grupo = "006" )
			  INNER JOIN bdidigital@coppelimg_app:"informix".dg_tipodocumento b	ON ( a.cod_docto = b.cod_docto AND b.cod_grupo = "006" )
	          -- WHERE a.empresa = pEmpresa
	          WHERE a.cliente = pNumcte 
			  AND a.fecha_alta > dtFechavalida;    
			
			-- SI COMPROBANTE VÃLIDO ES NULO SE DEJA EN CERO
			IF iComproboingreso IS NULL THEN
				LET iComproboingreso = 0;
			END IF;
			
			-- SI COMPROBANTE VÃLIDO ES IGUAL A CERO SE REGRESA QUE NO EXISTE 
			IF iComproboingreso = 0 THEN 
				LET iValido = 0;
			ELSE
				LET iValido = 1;
			END IF;
			
		ELSE
			LET iValido = 1;
		END IF;
		
	END IF;

	-- SE RETORNA CÃDIGO, MENSAJE Y SI EXISTE COMPROBANTE VÃLIDO (iValido = 1) O SI NO EXISTE COMPROBANTE VÃLIDO (iValido = 0)
RETURN  TRIM(cCodRet),cMensajeRet,NVL(iValido,0);
			
END
END PROCEDURE
