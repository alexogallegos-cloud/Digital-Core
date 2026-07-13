CREATE PROCEDURE "informix".sp_cat_tpsstatuscte()
		RETURNING CHAR(6),CHAR(100), CHAR(100);

	DEFINE cCodRet				CHAR(6);
	DEFINE iCont				INTEGER;
	DEFINE iSqlErr				INTEGER;
	DEFINE cValAlfabetico		CHAR(100);
	DEFINE cDescripcion			Char(100); 

	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET icont=0;
	LET cValAlfabetico = '';
	LET cDescripcion = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/hector/sp_cat_tpsstatuscte.out';
	--TRACE ON;
	--------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cValAlfabetico = '';
			LET cDescripcion = '';
			RETURN cCodRet,cValAlfabetico,cDescripcion;
		END EXCEPTION;

	set isolation to dirty read;

		FOREACH
			SELECT valor_alfabetico, descripcion
			INTO cValAlfabetico,cDescripcion
			FROM Bdicobranza: cb_param_campania  
			WHERE empresa= '001' 
			AND tipo_campania = 1 
			AND grupo_parametro = 'STATUSCTE'
			LET icont=icont+1;
            RETURN cCodret,cValAlfabetico,cDescripcion WITH RESUME;
		END FOREACH;

        IF icont == 0 THEN
			LET cCodret='000001';
			LET cValAlfabetico='No hay Informacion en la tabla';
			LET cDescripcion = 'No hay Informacion en la tabla';
            RETURN cCodret,cValAlfabetico,cDescripcion WITH RESUME;
        END IF;

	END;
END PROCEDURE

DOCUMENT
'AUTOR       : Héctor Manuel Bojorquez Ruelas',
'DESCRIPCION : Devuelve un listado de los status del cliente de la tabla cb_param_campania',
'FECHA       : 01 de Octubre de 2010',
'VERSION     : 20101001.1015',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_tpsexcepcion()
		RETURNING   
					CHAR(6) AS CodRet,	--codret
					CHAR(6) AS Codigo, --codigo de excepcion
					CHAR(50) AS DesExcepcion;  --Descripcion de la excepcion
		
	--Se definen las variables.
	DEFINE cCodRet 			CHAR(6);
	DEFINE iSqlErr 			INTEGER; 
	DEFINE iCont			INTEGER;
	DEFINE iCodigo			CHAR(6);
	DEFINE cDesExcepcion     CHAR(50);


	-- Se inicializan las variables.
	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET iCont = 0;
	LET iCodigo = '';
	LET cDesExcepcion='';
	
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_cat_tpsexcepcion.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cDesExcepcion='Error de Informix';
			RETURN cCodRet,iCodigo,cDesExcepcion WITH RESUME;
		END EXCEPTION;		
		
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	--Se consultan los datos de la tabla  cb_excepcion_cte para obtener la excpeciones	
		FOREACH   
			SELECT cve_excepcion,descripcion 
			INTO iCodigo,cDesExcepcion
			FROM bdicobranza:cb_excepcion
				RETURN cCodRet,iCodigo,cDesExcepcion WITH RESUME;
		END FOREACH;
		LET iCont = dbinfo("sqlca.sqlerrd2");
		IF iCont = 0 THEN
			LET cCodRet='000001'; 
			LET cDesExcepcion='No Hay Datos';
			RETURN cCodRet,iCodigo,cDesExcepcion;	
		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se consultan información para el llenado del combo de excepciones de la pantalla Disponibilidad de Clientes ',
'FECHA       : 01 de Octubre de 2010',
'VERSION     : 20101001.1550',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_conscartera(pIdCampania CHAR(1))
		RETURNING   
					CHAR(6) AS Codigo,	--codret
					CHAR(40) AS Descripcioncodigo, --Descripcion del codigo
					INTEGER AS CtesTrabajados,  --Total de clientes trabajados
					INTEGER AS CtesNoTrabajados, --Total de clientes no trabajados
					INTEGER AS TotalCtes; -- Total de clientes
		
	--Se definen las variables.
	DEFINE cCodRet 			CHAR(6);
	DEFINE CodRet2			CHAR(6);
	DEFINE iSqlErr 			INTEGER; 
	DEFINE cDesCod			CHAR(40);
	DEFINE iCteTrab         INTEGER;
	DEFINE iCteNoTrab       INTEGER;
	DEFINE iTotalctes		INTEGER;

	-- Se inicializan las variables.
	LET cCodRet = '000000';
	LET CodRet2='';
	LET iSqlErr = 0;
	LET cDesCod='PROCESO EXITOSO';
	LET iCteTrab = 0;
	LET iCteNoTrab=0;
	LET iTotalctes=0;
	
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_cat_conscartera.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cDesCod='Error de Informix';
			RETURN cCodRet,cDesCod,iCteTrab,iCteNoTrab,iTotalCtes WITH RESUME;
		END EXCEPTION;		
		
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	
	--Se ejecuta el sp que actualiza los datos de la tabla cb_cat_compctes
		EXECUTE PROCEDURE sp_cat_cargacartera(pIdCampania) INTO CodRet2;
	--Se valida que el sp se ejecuto de forma correcta.
	IF CodRet2 <> '000000' THEN
		--Si ocurrio algun error en la ejecucion se muestra un mensaje de error
		LET cCodRet=CodRet2;
		LET cDesCod='Ocurrio error en la ejecución del proceso';
	ELSE 
		--Se consultan los datos de la tabla  cb_cat_compctes
			--Se obtiene el total de clientes trabajados
		SELECT Cantidad 
		INTO iCteTrab
		FROM bdicobranza:cb_cat_compctes
		WHERE IdConcepto = 1
		AND IdCampania = pIdCampania;
			--Se obtiene el total de clientes No trabajados
		SELECT Cantidad
		INTO iCteNoTrab
		FROM bdicobranza:cb_cat_compctes
		WHERE IdConcepto = 2
		AND IdCampania = pIdCampania;
		
		--Se obtienen el total de clientes en carteras.
		LET iTotalctes=iCteTrab+iCteNoTrab;
				
	END IF
		RETURN cCodRet,cDesCod,iCteTrab,iCteNoTrab,iTotalctes;	
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se consultan y obtienen los clientes trabajados y clientes no trabajados informcion encontrada en la tabla cb_cat_compctes',
'FECHA       : 01 de Octubre de 2010',
'VERSION     : 20101001.1211',
'BD          : BDICOBRANZA';

CREATE FUNCTION "informix".fn_formaretiquetaxml(pValor VARCHAR(255), pEtiqueta VARCHAR(255))
RETURNING
	VARCHAR(255) AS LINEA_ETIQUETA;
    -- DEFINICIONES
    DEFINE cCadena VARCHAR(255);
	---INICIALIZACIONES
    LET cCadena = "";
BEGIN
	---SET DEBUG FILE TO "/tmp/has/.out";
	---TRACE ON;

    IF NVL(pEtiqueta,"") = "" THEN
        LET cCadena = "103017";
        RETURN cCadena;
    END IF
    
    LET cCadena = "<" || pEtiqueta || ">" || pValor || "</" || pEtiqueta || ">";
    
	RETURN cCadena;
END;
END FUNCTION
DOCUMENT
'DESCRIPCION: Función para agregarle etiqueta inicial y etiqueta final a un valor y formar una línea de etiqueta en formato XML', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2010',
'VERSION: 20101019.0946';

CREATE PROCEDURE "informix".sp_cat_cambia_estatus_cte(cNum_cte CHAR(20), cStatus_cte CHAR(2), iTipo_movto INTEGER, iTipo_cobranza CHAR(1),cEmpresa CHAR(3), cUsuario CHAR(8))
       RETURNING char(6), char(80);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(80);
DEFINE cMensaje 		            CHAR(80);
DEFINE cCod_ret                     CHAR(6);
DEFINE iCont						INTEGER;
DEFINE vnumvuelta                   SMALLINT;
------------------------------------------------------------

      LET cCod_ret        = '000000';
	  LET sql_err         = 0;
	  LET isam_err        = 0;
	  LET error_info      = '';
	  LET cMensaje        = 'PROCESO EXITOSO';
	  LET icont=0;
      LET vnumvuelta=0;
--SET DEBUG FILE TO '/home/sysifx/sp_CausaEsTatus.out';
--TRACE ON;
	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

         IF cStatus_cte ='PR' THEN LET vnumvuelta =1; END IF;
--        SET ISOLATION TO dirty READ;
            UPDATE bdicobranza:cb_cat_directorio_cte
            SET status_cliente= cStatus_cte, tipo_movto= iTipo_movto, 
                num_vuelta = nvl(num_vuelta,0) + vnumvuelta ,
                fecha_modificacion= TODAY, usuario_modifica= cUsuario                
            WHERE empresa = cEmpresa
            AND numcte = cNum_cte
            AND tipo_cobranza= iTipo_cobranza;
			LET iCont = dbinfo("sqlca.sqlerrd2");
			IF iCont = 0 THEN
				LET cCod_ret='000001';
				LET cMensaje='No Hay Datos';
				RETURN cCod_ret,cMensaje;
			END IF;

       RETURN cCod_ret, cMensaje;
    END;
END PROCEDURE
DOCUMENT
'ACTUALIZÓ : Maria Elena Angulo Aispuro',
'MODIFICACION : Se actualiza SP enviado del banco debido a que se quito el parametro de entrada fecha_insert, y en lugar de este se agrego el parametro de entrada cempresa así como la consulta update para que la empresa fuese dinamica y no fija como era anteriormente',
'FECHA       : 05 de Octubre de 2010',
'VERSION     : 20101005.1659',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_consparamcampania()
	returning 	char(6),  			--as CodRetorno,
				date,				--as fecha_hoy
				decimal(18,2),		--as dParamRegGrid,
				CHAR(100);			--as ruta;
								
			--Declararacion de Varibles
		DEFINE cSqlErr				INTEGER;
		DEFINE vCodRet 				CHAR(6);
		DEFINE dFecha               DATE;
		DEFINE dParamRegGrid		INTEGER;
		DEFINE vruta				CHAR(100);
		
			--Inicializacion de variables
		LET cSqlErr = 		0;
		LET vCodRet = 		"00000";
		LET dParamRegGrid = 0;
		LET vruta=	 		"";
		
		--SET DEBUG FILE TO "/home/sysifx/hector/sp_cat_consparamcampania.out";
		--TRACE ON;
		BEGIN
			 ON EXCEPTION SET cSqlErr
		        IF cSqlerr <> 0 THEN
		            Let vCodRet = cSqlErr;
					RETURN vCodRet,dFecha,dParamRegGrid,vruta;
				END IF;
			END EXCEPTION; 
			
			--se obtiene la fecha
			SELECT unique(fecha_hoy) INTO dFecha FROM bdinteg:si_fechas;
			
			--se obtiene la cantidad de registros a regresar en grid
			SELECT valor_numerico INTO dParamRegGrid FROM bdicobranza:cb_param_campania 
			WHERE grupo_parametro = 'MONDISPONI' AND num_parametro = 1;
			
			--se obtiene la ruta
			SELECT TRIM(valor_alfabetico) INTO vruta FROM bdicobranza:cb_param_campania
			WHERE grupo_parametro = 'MONDISPONI' AND num_parametro = 2;
			
			IF vruta IS NULL OR vruta = '' OR dFecha IS NULL OR dFecha = '' OR dParamRegGrid IS NULL OR dParamRegGrid = '' THEN
				LET vCodRet = '00001';
			END IF;
			
			RETURN vCodRet,dFecha,dParamRegGrid,vruta;
		END;
END PROCEDURE
 DOCUMENT
'AUTOR: Héctor Manuel Bojórquez Ruelas',
'Proyecto: ReingenieriaCAT 2',
'Descripcion: Extrae el parametro de registros a regresar en grid y la ruta del archivo',
'Fecha: 2010/10/07',
'Version: 20101007.1413',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_cat_tpsmovtos()
		RETURNING CHAR(6),decimal(18,2), CHAR(100);

	DEFINE cCodRet				CHAR(6);
	DEFINE iCont				INTEGER;
	DEFINE iSqlErr				INTEGER;
	DEFINE cValNumerico			decimal(18,2);
	DEFINE cDescripcion			Char(100); 

	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET icont=0;
	LET cValNumerico = 0;
	LET cDescripcion = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/hector/sp_cat_tpsmovtos.out';
	--TRACE ON;
	--------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cValNumerico = 0;
			LET cDescripcion = '';
			RETURN cCodRet,cValNumerico,cDescripcion;
		END EXCEPTION;

	set isolation to dirty read;

		FOREACH
			SELECT valor_numerico, descripcion
			INTO cValNumerico,cDescripcion
			FROM Bdicobranza: cb_param_campania  
			WHERE empresa= '001' 
			AND tipo_campania = 1 
			AND grupo_parametro = 'TIPOMOVTO'
			LET icont=icont+1;
            RETURN cCodret,cValNumerico,cDescripcion WITH RESUME;
		END FOREACH;

        IF icont == 0 THEN
			LET cCodret='000001';
			LET cValNumerico=0;
			LET cDescripcion = 'No hay Informacion en la tabla';
            RETURN cCodret,cValNumerico,cDescripcion WITH RESUME;
        END IF;

	END;
END PROCEDURE

DOCUMENT
'AUTOR       : Héctor Manuel Bojorquez Ruelas',
'DESCRIPCION : Devuelve un listado de los tipos de movimientos del cliente de la tabla cb_param_campania',
'FECHA       : 01 de Octubre de 2010',
'VERSION     : 20101001.1015',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_validarnumciudad(pEstado char(2),pCodCiudad CHAR(3))
		RETURNING   
					CHAR(6) AS CodRet,	--codret
					CHAR(3) AS Codigo, --codigo de ciudad
					CHAR(60) AS DesCiudad;  --Descripcion de la excepcion
		
	--Se definen las variables.
	DEFINE cCodRet 			CHAR(6);
	DEFINE iSqlErr 			INTEGER; 
	DEFINE iCont			INTEGER;
	DEFINE cDesCiudad     CHAR(60);


	-- Se inicializan las variables.
	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET iCont = 0;
	LET cDesCiudad='';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_cat_validarnumciudad.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cDesCiudad='Error de Informix';
			RETURN cCodRet,pCodCiudad,cDesCiudad;
		END EXCEPTION;		
		
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	--Se consultan los datos de la tabla  si_ciudades para obtener las ciudades	
	SELECT nombre
	INTO cDesCiudad
	FROM bdinteg:si_ciudades 
	WHERE estado=pEstado
	AND ciudad=pCodCiudad;
		LET iCont = dbinfo("sqlca.sqlerrd2");
		IF iCont = 0 THEN
			LET cCodRet='000001'; 
			LET cDesCiudad='CODIGO DE CIUDAD INVALIDO PARA EL ESTADO SELECCIONADO';
			RETURN cCodRet,NVL(pCodCiudad,''),NVL(cDesCiudad,'');	
		END IF;
	RETURN cCodRet,NVL(pCodCiudad,''),NVL(cDesCiudad,'');
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se consultan información para validar que el codigo de ciudad tecleado de la pantalla Disponibilidad de Clientes existe',
'FECHA       : 05 de Octubre de 2010',
'VERSION     : 20101005.1535',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_validartipodatos (pTipoDato CHAR(2), pDato CHAR(255), pTotLongDecimales SMALLINT, pNumeroDecimales SMALLINT)
RETURNING
	CHAR(6) AS COD_RET, 
	CHAR(1) AS RESPUESTA; 

	---DECLARACIONES
    DEFINE iSqlErr                  INTEGER;
    DEFINE iIsamErr                 INTEGER;
    DEFINE cErrorInfo               CHAR(80);
    DEFINE cCodRet                  CHAR(6);
    DEFINE cMensajeRet              CHAR(80);
    DEFINE nrows                    INTEGER;
    DEFINE cRespuesta               CHAR(1);
    DEFINE cExiste                  CHAR(1);
    DEFINE cCodRetPos               CHAR(3);
    DEFINE cCodRetPos2              CHAR(3);
    DEFINE iLongCadProc             INT;
    DEFINE iLongCadProc2            INT;
    DEFINE cPosicion                CHAR(255);
    DEFINE cPosicion2               CHAR(255);
    DEFINE lLongSegmento            INT8;
    DEFINE lLongRestoSeSegmento     INT8;
    DEFINE cEsNegativo              CHAR(1);
    DEFINE iCodRetIs                SMALLINT;
    DEFINE cTipoCad                 CHAR(100);
    DEFINE cAnio                    CHAR(4);
    DEFINE cMes                     CHAR(2);
    DEFINE cDia                     CHAR(2);
    DEFINE cHora                    CHAR(2);
    DEFINE cMinuto                  CHAR(2);
    DEFINE cSegundo                 CHAR(2);
    DEFINE cMiliSegundo             CHAR(3);
    DEFINE iPosicion                INTEGER;
    DEFINE iPosicionTotal           INTEGER;
    DEFINE i                        SMALLINT;
    DEFINE iValidarEnteroCorto      SMALLINT;
    DEFINE iValidarEntero           INTEGER;
    DEFINE cValidarDecimal          VARCHAR(255);
    
	---INICIALIZACIONES
    LET iSqlErr                     = 0;
    LET iIsamErr                    = 0;
    LET cErrorInfo                  = "";
    LET cCodRet                     = "000000";
    LET cMensajeRet                 = "";
    LET nrows                       = 0;
    LET cRespuesta                  = "F";
    LET cExiste                     = "";
    LET cCodRetPos                  = "000";
    LET cCodRetPos2                 = "000";
    LET iLongCadProc                = 0;
    LET iLongCadProc2               = 0;
    LET cPosicion                   = "";
    LET cPosicion2                  = "";
    LET lLongSegmento               = 0;
    LET lLongRestoSeSegmento        = 0;
    LET cEsNegativo                 = "0";
    LET iCodRetIs                   = 0;
    LET cTipoCad                    = "";
    LET cAnio                       = "";
    LET cMes                        = "";
    LET cDia                        = "";
    LET cHora                       = "00";
    LET cMinuto                     = "00";
    LET cSegundo                    = "00";
    LET cMiliSegundo                = "000";
    LET iPosicion                   = 0;
    LET iPosicionTotal              = 0;
    LET i                           = 0;
    LET iValidarEnteroCorto            = 0;
    LET iValidarEntero              = 0;
    LET cValidarDecimal             = "";
    
    
BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF pTipoDato = "EC" THEN
            IF iSqlErr = -1213 OR iSqlErr = -1214 THEN             
                LET cRespuesta = 'F' ; 
                RETURN cCodRet, cRespuesta ;
            END IF; 
        END IF
        IF pTipoDato = "E" THEN
            IF iSqlErr = -1213 OR iSqlErr = -1215 THEN             
                LET cRespuesta = 'F' ; 
                RETURN cCodRet, cRespuesta ;
            END IF; 
        END IF
        IF  pTipoDato = "D" THEN
            IF iSqlErr = -1213 THEN             
                LET cRespuesta = 'F' ; 
                RETURN cCodRet, cRespuesta ;
            END IF; 
        END IF
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/hass/sp_ValidaTipoDatos.out";
	--TRACE ON;
    
    IF NVL(pTipoDato,"") = "" OR NVL(pDato,"") = "" THEN
        LET cCodRet = "000001";
        LET cRespuesta = "";
        RETURN cCodRet, cRespuesta;
    END IF
    
    IF pTipoDato <> "EC" AND pTipoDato <> "E" AND pTipoDato <> "D" AND pTipoDato <> "F1" AND pTipoDato <> "F2" THEN
        LET cCodRet = "000002";
        LET cRespuesta = "";
        RETURN cCodRet, cRespuesta;
    END IF
    
    LET pDato = TRIM(pDato);
    
    LET pDato = SUBSTR(pDato, 1, LENGTH(pDato));
    
    --VALIDA TIPO DE DATOS ENTEROS
    IF pTipoDato = "EC" THEN
        LET iValidarEnteroCorto = pDato;
        LET cRespuesta = 'V';
        RETURN cCodRet, cRespuesta;
    END IF
    
    IF pTipoDato = "E" THEN
        LET iValidarEntero = pDato;
        LET cRespuesta = 'V';
        RETURN cCodRet, cRespuesta;
    END IF	
    
    -- VALIDA TIPO DE DATOS DECIMALES
    IF pTipoDato = "D" THEN
        WHILE 1 = 1
            IF SUBSTR(pDato,1,2) = "-0" THEN
                LET pDato = "-" || SUBSTR(pDato,3);
            ELIF SUBSTR(pDato,1,1) = "0" THEN
                LET pDato = SUBSTR(pDato,2);
            ELSE
                EXIT WHILE;
            END IF
        END WHILE
    
        SELECT FIRST 1 "1" 
        INTO cExiste
        FROM bdicred: sd_fechas 
        WHERE pDato MATCHES "*.*";
        -- EN BUSCA DEL CARACTER MENOS REPETIDOS
        -- OBTIENE TODAS LAS POSICIONES DONDE ENCUENTRA EL CARACTER
        
        LET i = 0;
        FOREACH
            EXECUTE PROCEDURE bdicobranza: sp_obtenerposicion (pDato,"-")
            INTO iPosicion, iPosicionTotal
            LET i = i + 1;
        END FOREACH
        IF i > 1 THEN
            -- MANDA CODIGO QUE CORRESPONDE A QUE HAY MAS DE UN SIGNO MENOS EN EL DATO
            LET cRespuesta = 'F';
            RETURN cCodRet, cRespuesta;
        END IF        
        -- SI NO ENCONTRO EL SIGNO SIGNIFICA QUE LA CADENA ES DE NATURALEZA POSITIVA
        IF iPosicion = -1 THEN
            LET cEsNegativo = "0";
        ELSE
            -- SI ENCONTRO EL SIGNO SIGNIFICA QUE LA CADENA ES DE NATURALEZA NEGATIVA
            LET cEsNegativo = "1";
        END IF
        -- VALIDA QUE SEA UNA CADENA DE NUMEROS PROVOCANDO EL ERROR -1213 DE INFORMIX
        IF (pDato + 1) =  (pDato + 1) THEN 
            LET cRespuesta = 'V';
        ELSE
            LET cRespuesta = 'F';
        END IF  
        
        LET iPosicion = 0;
        -- SI EXISTE EL PUNTO HACE LAS VALIDACIONES A PARTIR DE ESTE
        IF cExiste = "1" THEN 
            LET i = 0;
            FOREACH
                EXECUTE PROCEDURE bdicobranza:sp_obtenerposicion (pDato,".")
                INTO iPosicion, iPosicionTotal
                LET i = i + 1;
            END FOREACH
        
            IF i > 1 THEN
                -- VALIDA SI HUBO ERROR
                LET cCodRet = "000003";
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            -- OBTIENE LA PARTE ENTERA DEL DECIMAL
            LET lLongSegmento = LENGTH(SUBSTR(pDato,1,iPosicion - 1));
            
            IF cEsNegativo = "1" THEN
                LET lLongSegmento = lLongSegmento - 1;
            END IF
            
            IF lLongSegmento > (pTotLongDecimales - pNumeroDecimales) THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            -- OBTIENE LA LONGITUD DE LA PARTE FRACCIONARIA DEL DECIMAL
            LET lLongRestoSeSegmento = LENGTH(SUBSTR(pDato,iPosicion + 1));
            
            IF lLongRestoSeSegmento >  pNumeroDecimales THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
        ELSE
            -- SI NO EXISTE EL PUNTO HACE LAS VALIDACIONES TOMO EN CUENTA SOLO LA PARTE ENTERA
            -- OBTIENE LA PARTE ENTERA DEL DECIMAL
            LET lLongSegmento = LENGTH(pDato);
            
            IF cEsNegativo = "1" THEN
                LET lLongSegmento = lLongSegmento - 1;
            END IF
            
            IF lLongSegmento > (pTotLongDecimales) THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
        END IF
        
        LET cRespuesta = 'V';
        RETURN cCodRet, cRespuesta;
    END IF

    -- VALIDA TIPO DE DATOS DATE
    IF pTipoDato = "F1" THEN
        IF LENGTH(pDato) <> 10 THEN
            LET cRespuesta = 'F';
            RETURN cCodRet, cRespuesta;
        END IF
        
        -- VALIDA QUE SOLO PUEDAN TENER EL CARACTER DIAGONAL Y EL GUION MEDIO
        IF SUBSTR(pDato,3,1) <> "/" AND SUBSTR(pDato,3,1) <> "-" THEN 
            LET cRespuesta = 'F';
            RETURN cCodRet, cRespuesta;
        END IF
        
        IF SUBSTR(pDato,6,1) <> "/" AND SUBSTR(pDato,6,1) <> "-" THEN 
            LET cRespuesta = 'F';
            RETURN cCodRet, cRespuesta;
        END IF                
        
        -- OBTIENE EL MES, DIA Y EL AÑO
        LET cMes = SUBSTR(pDato,1,2);
        LET cDia = SUBSTR(pDato,4,2);
        LET cAnio = SUBSTR(pDato,7,4);
        
        IF bdiprog: isnumeric(cMes) <> 1 THEN
            LET cRespuesta = 'F';
            RETURN cCodRet, cRespuesta;
        END IF
                
        IF bdiprog: isnumeric(cDia) <> 1 THEN
            LET cRespuesta = 'F';
            RETURN cCodRet, cRespuesta;
        END IF

        IF bdiprog: isnumeric(cAnio) <> 1 THEN
            LET cRespuesta = 'F';
            RETURN cCodRet, cRespuesta;
        END IF
        
        IF cMes < 1 OR cMes > 12 THEN
            LET cRespuesta = 'F';
            RETURN cCodRet, cRespuesta;
        END IF
        
        IF cDia < 1 OR cDia > 31 THEN
            LET cRespuesta = 'F';
            RETURN cCodRet, cRespuesta;
        END IF
        
        IF cAnio < 1900 OR cAnio > 2900 THEN
            LET cRespuesta = 'F';
            RETURN cCodRet, cRespuesta;
        END IF    
        
        LET cRespuesta = 'V';
        RETURN cCodRet, cRespuesta;
    END IF
    
    -- VALIDA TIPO DE DATOS DATETIME
    IF pTipoDato = "F2" THEN
        IF pTotLongDecimales = 8 THEN --- VALIDA UN DATETIME HOUR TO FRACTION (5), SOLO LA PARTE DE LA HORA DE UN FECHA
            IF LENGTH(pDato) < 8 OR LENGTH(pDato) > 14 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF SUBSTR(pDato,3,1) <> ":" THEN 
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF SUBSTR(pDato,6,1) <> ":" THEN 
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            LET cHora = SUBSTR(pDato,1,2);
            LET cMinuto = SUBSTR(pDato,4,2);
            LET cSegundo = SUBSTR(pDato,7,2);
            
            IF bdiprog: isnumeric(cHora) <> 1 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF bdiprog: isnumeric(cMinuto) <> 1 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF

            IF bdiprog: isnumeric(cSegundo) <> 1 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
        ELSE
            -- VALIDA UN DATETIME YEAR TO FRACTION (5), FECHA COMPLETA
            IF LENGTH(pDato) < 19 OR LENGTH(pDato) > 23 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            -- VALIDA QUE SOLO PUEDAN TENER EL CARACTER GUION MEDIO
            IF SUBSTR(pDato,5,1) <> "-" THEN 
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF SUBSTR(pDato,8,1) <> "-" THEN 
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF SUBSTR(pDato,11,1) <> " " THEN 
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF SUBSTR(pDato,14,1) <> ":" THEN 
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF SUBSTR(pDato,17,1) <> ":" THEN 
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF LENGTH(pDato) > 19 THEN
                IF SUBSTR(pDato,20,1) <> "." THEN 
                    LET cRespuesta = 'F';
                    RETURN cCodRet, cRespuesta;
                END IF        
            END IF
            
            -- OBTIENE EL AÑO, MES, DIA, HORA, MINUTO, SEGUNO Y MILISEGUNO
            LET cAnio = SUBSTR(pDato,1,4);
            LET cMes = SUBSTR(pDato,6,2);
            LET cDia = SUBSTR(pDato,9,2);
            LET cHora = SUBSTR(pDato,12,2);
            LET cMinuto = SUBSTR(pDato,15,2);
            LET cSegundo = SUBSTR(pDato,18,2);
            IF LENGTH(pDato) > 19 THEN
                LET cMiliSegundo = SUBSTR(pDato,21,3);
            END IF
            
            IF bdiprog: isnumeric(cAnio) <> 1 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF bdiprog: isnumeric(cMes) <> 1 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF bdiprog: isnumeric(cDia) <> 1 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF

            IF bdiprog: isnumeric(cHora) <> 1 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF bdiprog: isnumeric(cMinuto) <> 1 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF

            IF bdiprog: isnumeric(cSegundo) <> 1 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF LENGTH(pDato) > 19 THEN
                IF bdiprog: isnumeric(cMiliSegundo) <> 1 THEN
                    LET cRespuesta = 'F';
                    RETURN cCodRet, cRespuesta;
                END IF
            END IF

            IF cMes::SMALLINT < 1 OR cMes::SMALLINT > 12 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF cDia::SMALLINT < 1 OR cDia::SMALLINT > 31 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF
            
            IF cAnio::SMALLINT < 1900 OR cAnio::SMALLINT > 2900 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF    
            
            IF cHora::SMALLINT > 23 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF    
            
            IF cMinuto::SMALLINT > 59 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF    
            
            IF cSegundo::SMALLINT > 59 THEN
                LET cRespuesta = 'F';
                RETURN cCodRet, cRespuesta;
            END IF    

            IF LENGTH(pDato) > 19 THEN
                IF cMiliSegundo::SMALLINT > 999 THEN
                    LET cRespuesta = 'F';
                    RETURN cCodRet, cRespuesta;
                END IF            
            END IF
        END IF
        
        LET cRespuesta = 'V';
        RETURN cCodRet, cRespuesta;
    END IF
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento hecho para la ReIngenieraCAT que sirve para hacer validación de tipos de datos.',
                'Valida los siguientes tipos de datos:',
                    'E  - Enteros',
                    'D  - Decimales',
                    'F1 - Fechas tipo Date',
                    'F2 - Fechas tipo Datetime year to fraction (5)', 
                    'F2 - Fechas tipo Datetime hour to fraction (5) - aqui se manda un 8 en el parámetro de entrada pTotLongDecimales para indicar que es la parte de horas de una fecha', 
'AUTOR: Mohamed Carreón ',
'VERSION: 20101013.1704';

CREATE PROCEDURE "informix".sp_cat_cargacartera(pIdCampania CHAR(1))
		RETURNING   
					CHAR(6) AS Codigo;	--codret
		
	--Se definen las variables.
	DEFINE cCodRet 			CHAR(6);
	DEFINE iSqlErr 			INTEGER; 
	DEFINE iTotalTrab		INTEGER;
	DEFINE iTotalNoTrab		INTEGER;


	-- Se inicializan las variables.
	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET iTotalTrab=0;
	LET iTotalNoTrab=0;
	
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_cat_cargacartera.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			RETURN cCodRet WITH RESUME;
		END EXCEPTION;		
		
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	-- Se obtiene el total de clientes trabajados
		SELECT COUNT(numcte) 
		INTO iTotalTrab
		FROM cb_cat_directorio_cte
		WHERE status_cliente in ('PR','EX') 
		AND tipo_cobranza=pIdCampania;
		
	--Se obtiene el total de clientes no trabajados
		SELECT COUNT(numcte) 
		INTO iTotalNoTrab
		FROM cb_cat_directorio_cte
		WHERE status_cliente in ('AC','IN','LD','EP')
		AND tipo_cobranza=pIdCampania;
							
		--Se insertan los datos en la tabla  cb_cat_compctes
		DELETE FROM cb_cat_compctes;
				INSERT INTO bdicobranza:cb_cat_compctes(IdCampania,IdConcepto,Descripcion,Cantidad) VALUES (pIdCampania,1,'Trabajados',iTotalTrab);
				INSERT INTO bdicobranza:cb_cat_compctes(IdCampania,IdConcepto,Descripcion,Cantidad) VALUES (pIdCampania,2,'No Trabajados',iTotalNoTrab);
		RETURN cCodRet;	
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se almacena en registros los clientes trabajados y clientes no trabajados en la tabla cb_cat_compctes',
'FECHA       : 01 de Octubre de 2010',
'VERSION     : 20101001.1043',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_consulta_pagos_tc(pEmpresa      CHAR(3),
                                                     pNumCredito   CHAR(20),
                                                     pNumReg       INTEGER)

RETURNING   CHAR(6)          AS cod_ret,
            CHAR(16)         AS folio_suc,
            DATE             AS fecha_pago,
            CHAR(20)         AS num_credito,
            DECIMAL(18,2)    AS importe;
            
-- Declaración de variables
DEFINE cCodRet          CHAR(6);
DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;

DEFINE cMensajeRet      CHAR(80);
DEFINE cNumCredito      CHAR(20);
DEFINE dtFechaPago      DATE;
DEFINE dCapital_vig     DECIMAL(18,2);
DEFINE dCapital_venc    DECIMAL(18,2);
DEFINE dInteres_vig     DECIMAL(18,2);
DEFINE dIva_int_vig     DECIMAL(18,2);
DEFINE dInt_orden_abono DECIMAL(18,2);
DEFINE dIva_orden_abono DECIMAL(18,2);
DEFINE dInteres_mora    DECIMAL(18,2);
DEFINE dIva_mora        DECIMAL(18,2);
DEFINE dImporte         DECIMAL(18,2);
DEFINE cFolioSuc        CHAR(16);
DEFINE iRegistros       INTEGER;
DEFINE iExiste          SMALLINT;
DEFINE iTotal_pagos     INTEGER;

-- Inicializacíón de variables
LET cCodRet             = "000000";
LET iSqlErr             = 0;
LET iIsamErr            = 0;

LET cMensajeRet         = "";
LET cNumCredito         = "";
LET dtFechaPago         = DATE(1);
LET dCapital_vig        = 0;
LET dCapital_venc       = 0;
LET dInteres_vig        = 0;
LET dIva_int_vig        = 0;
LET dInt_orden_abono    = 0;
LET dIva_orden_abono    = 0;
LET dInteres_mora       = 0;
LET dIva_mora           = 0;
LET dImporte            = 0;
LET cFolioSuc           = "";
LET iRegistros          = 0;
LET iExiste             = 0;
LET iTotal_pagos        = 0;


--SET DEBUG FILE TO "/home/sysifx/sp_cat _consulta_pagos_tc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
          LET cCodRet = iSqlErr;
          RETURN  cCodRet, cFolioSuc,dtFechaPago, cNumCredito, dImporte;
    END EXCEPTION;
    
    SELECT COUNT(empresa)
      INTO iExiste
      FROM bdinteg:"informix".si_empresas
     WHERE empresa = pEmpresa;

     IF iExiste = 0 THEN
        LET cCodRet = "101001";
        RETURN cCodRet, cFolioSuc,dtFechaPago, cNumCredito, dImporte;
     END IF;

     SELECT COUNT(num_credito)
       INTO iExiste
       FROM bdicred:"informix".sd_maecred
      WHERE empresa = pEmpresa
        AND num_credito = pNumCredito;

     IF iExiste = 0 THEN
        LET cCodRet = "101009";
        RETURN cCodRet, cFolioSuc,dtFechaPago, cNumCredito, dImporte;
     END IF;

     -- Se obtiene el valor del parámetro del número de pagos a tomar en cuenta en
     -- la consulta     
     SELECT valor_numerico
       INTO iTotal_pagos
       FROM bdicobranza:"informix".cb_param_campania
      WHERE empresa = pEmpresa
        AND tipo_campania = "1"
        AND grupo_parametro = "PAGOS"
        AND num_parametro = 1;

      IF NVL(iTotal_pagos,0) = 0 THEN
        LET cCodRet = "101010";
        RETURN cCodRet, cFolioSuc,dtFechaPago, cNumCredito, dImporte;
      END IF;      


     FOREACH
            EXECUTE PROCEDURE bdicred:"informix".sp_consulta_pagos_recibidos_general(pEmpresa, pNumCredito)
                         INTO   cCodRet, 
                                cMensajeRet,
                                cNumCredito,
                                dtFechaPago,
                                dCapital_vig,
                                dCapital_venc,
                                dInteres_vig,
                                dIva_int_vig,
                                dInt_orden_abono,
                                dIva_orden_abono,
                                dInteres_mora,
                                dIva_mora,
                                dImporte,
                                cFolioSuc

            IF cCodRet <> "000000" THEN
                LET cCodRet = "101011"; --Error al consultar los pagos realizados al crédito.
                RETURN cCodRet, cFolioSuc, dtFechaPago, cNumCredito, dImporte;
            END IF;
            
            LET iRegistros = iRegistros  + 1;
            IF iRegistros <= iTotal_pagos THEN
                IF iRegistros  > pNumReg THEN
                    EXIT FOREACH;
                END IF;
            ELSE
                EXIT FOREACH;
            END IF;

            RETURN cCodRet, cFolioSuc,dtFechaPago, cNumCredito, dImporte WITH RESUME;                              
     END FOREACH;

END

END PROCEDURE
DOCUMENT
"Descripción: Procedimiento que obtiene los pagos realizados a un crédito.",
"BD: bdicobranza",
"Autor: Viridiana Osobampo Aguilar",
"Fecha: 29-Sep-2010";

CREATE PROCEDURE "informix".sp_cat_tpsresultado()
		RETURNING CHAR(6), smallint,CHAR(100);

	DEFINE cCodRet				CHAR(6);
	DEFINE iCont				INTEGER;
	DEFINE iSqlErr				INTEGER;
	DEFINE sCod_Result				SMALLINT;
	DEFINE cDescripcion			Char(100); 
	

	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET icont= 0;
	LET sCod_Result = 0;
	LET cDescripcion = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/hector/sp_cat_tpsresultado.out';
	--TRACE ON;
	--------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET sCod_Result = 0;
			LET cDescripcion = '';
			RETURN cCodRet,sCod_Result,cDescripcion;
		END EXCEPTION;

	set isolation to dirty read;

		FOREACH
			SELECT codigo_resultado,descripcion
			INTO sCod_Result,cDescripcion
			FROM Bdicobranza: cb_cat_tipo_resultado  
			LET icont=icont+1;
            RETURN cCodret,sCod_Result,cDescripcion WITH RESUME;
		END FOREACH;

        IF icont == 0 THEN
			LET cCodret='000001';
			LET sCod_Result = 0;
			LET cDescripcion = 'No hay Información en la tabla cb_cat_tipo_resultado';
            RETURN cCodret,sCod_Result,cDescripcion WITH RESUME;
        END IF;

	END;
END PROCEDURE

DOCUMENT
'AUTOR       : Héctor Manuel Bojorquez Ruelas',
'DESCRIPCION : Devuelve un listado de los tipos de resultados del cliente de la tabla cb_cat_tipo_resultado',
'FECHA       : 01 de Octubre de 2010',
'VERSION     : 20101001.1115',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_obtenerposicion(
    pCadena LVARCHAR, 
    pCaracter VARCHAR(30)
)
RETURNING INTEGER,
          INTEGER;

DEFINE iSalida      INTEGER;
DEFINE iSalida2     INTEGER;
DEFINE cCadenaAux   LVARCHAR;
DEFINE cComparaAux  LVARCHAR;  
DEFINE cCadenaFin   LVARCHAR;  
DEFINE i            INTEGER;
define cComparacion LVARCHAR;
define cCaracter    LVARCHAR;
DEFINE iTotal       INTEGER;
DEFINE cBan         CHAR(1);

LET iSalida         = 0;
LET iSalida2        = 0;
LET cCadenaAux      = "";
LET cComparaAux     = "";  
LET cCadenaFin      = "";  
LET i               = 0;
let cComparacion    = "";
let cCaracter       = ""; 
LET iTotal          = 0;
LET cBan            = 'F';

BEGIN 
--SET DEBUG FILE TO '/tmp/sp_obtenerposicion.out';
--TRACE ON;
    IF  NVL(pCadena,'') = '' THEN 
    LET iSalida = -1;
    LET iSalida2 = -1;
    RETURN iSalida, iSalida2;
    END IF;

    IF  NVL(pCaracter,'') = '' THEN 
    LET iSalida = -1;
    LET iSalida2 = -1;
    RETURN iSalida, iSalida2;
    END IF;

    LET cCadenaAux = pCadena;
    LET cComparaAux = pCaracter;  
    LET cCadenaFin = REPLACE(cCadenaAux,cComparaAux,'º');
    LET cComparacion = LENGTH(cCadenaFin);
    LET iTotal = LENGTH(cComparaAux);

    WHILE i < cComparacion
       LET i = i + 1;
       LET cCaracter = SUBSTR(cCadenaFin,i,1);
            IF cCaracter = 'º' THEN 
               LET iSalida = i;
               LET iSalida2 = (i + iTotal) - 1;
               LET cBan = 'T';
                  RETURN iSalida, iSalida2  WITH RESUME;
            END IF;
    END WHILE;

    IF cBan = 'F' THEN
    LET iSalida = -1;
    LET iSalida2 = -1;
    RETURN iSalida, iSalida2  WITH RESUME;
    END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que te devuelve las posiciones de un caracter',
                'Devuelve:',
                    'iSalida  - La posición inicial del carácter',
                    'iSalida2  - La posición final del carácter',
'AUTOR: Paul Quintero ',
'VERSION: 20101019.1041';

CREATE PROCEDURE "informix".sp_cat_arch_cartbase(pSeparador CHAR(1), ptipo_cobranza CHAR(1))
       RETURNING  CHAR(6), CHAR(150);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info		CHAR(150);
DEFINE cCod_ret         CHAR(6);
DEFINE cMensaje         CHAR(150);
DEFINE cCadena          CHAR (500);
DEFINE vFechaArch       DATE;
DEFINE vNomArch         CHAR(40);
DEFINE vPathOri         CHAR(50);
DEFINE vPath            CHAR(50);
DEFINE vfecha_insert    DATE;
DEFINE vnumcte          CHAR(20);
DEFINE vciudad_coppel   SMALLINT;
DEFINE vstatus          SMALLINT;
DEFINE vtipo_logica     SMALLINT;
DEFINE vempresa         CHAR(3);
DEFINE cProceso         CHAR(30);
--DEFINE pcampania        CHAR(15);
------------------------------------------------------------

    LET cCod_ret      = '000000';
    LET sql_err       = 0;
    LET cMensaje      = '';
    LET cCadena       = '';
    --LET vNomArch      = 'cartera_clientes_';
    LET vPathOri      = '';
    LET vPath         = '';
    LET vempresa      = '001';
    LET cProceso      = '0002';

      BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02');
            drop table cb_tabla_temporal;
        RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

            CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01');
                
    --SET DEBUG FILE TO "/ids10_uc9/jtrujillo/sp_cat_arch_cartbase.out";
    --TRACE ON;

    --drop table cb_tabla_temporal;

    SELECT fecha_hoy
    INTO   vFechaArch
    FROM   bdinteg:si_fechas;

    SELECT valor_alfabetico
    INTO vNomArch
    FROM cb_param_campania 
    WHERE tipo_campania= 1
    AND grupo_parametro= 'ARCHIVOS'
    AND num_parametro= 1;

    /*IF ptipo_cobranza = 'A' THEN
        LET pcampania = '_admin';
    ELSE
        LET pcampania = '_prev';
    END IF;*/

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

    -- ARMAR NOMBRE DEL ARCHIVO TXT
    LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

    -- EXTRAER LA RUTA DEPOSITO DE ARCHIVO
    SELECT valor_alfabetico
    INTO vPathOri
    FROM cb_param_campania 
    WHERE tipo_campania= 1
    AND grupo_parametro= 'ARCHIVOS'
    AND num_parametro= 9;

    LET vPath = TRIM(vPathOri);

            CREATE TABLE informix.cb_tabla_temporal (
                tipo_cobranza     	CHAR(1),
                fecha_insert        DATE,
                numcte              CHAR(20),
                ciudad_coppel       SMALLINT,
                status              SMALLINT,
                tipo_logica         SMALLINT,
                flag                SMALLINT
                );

                FOREACH


                    SELECT  a.fecha_insert , a.numcte, b.ciudad_coppel, a.tipo_logica, (select  valor_numerico
                                                                                FROM cb_param_campania
                                                                                WHERE  tipo_campania = 1
                                                                                AND grupo_parametro ='STATUSCTE'
                                                                                AND TRIM(valor_alfabetico)=status_cliente) status
                    INTO vfecha_insert, vnumcte, vciudad_coppel, vtipo_logica, vstatus
                    FROM bdicobranza:cb_cat_directorio_cte a, bdinteg:si_ciudades b, bdinteg:si_direcciones c
                    WHERE a.numcte = c.numcte
                    AND a.numcte = c.numcte
                    AND c.pais = b.pais
                    AND c.estado = b.estado
                    AND c.ciudad = b.ciudad
                    AND c.tipo_dir = '1'
                    AND c.secuencia = ( SELECT max(secuencia) FROM bdinteg:si_direcciones h
                                        WHERE tipo_dir = '1'
                                        AND a.numcte = h.numcte)
                    AND a.tipo_cobranza = ptipo_cobranza

                    INSERT INTO "informix".cb_tabla_temporal(tipo_cobranza, fecha_insert, numcte, ciudad_coppel, status, tipo_logica, flag)
                    VALUES(ptipo_cobranza, vfecha_insert, vnumcte, vciudad_coppel, vstatus, vtipo_logica, 0);

                END FOREACH;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

            LET cCadena = 'echo "unload to ' || SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(vNomArch,1,LENGTH(vNomArch)) || ' DELIMITER ''' || pSeparador || ''' SELECT * FROM cb_tabla_temporal'
                   || '" > ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'cartera_base.sql';
            System cCadena;
            let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'cartera_base.sql';
            System cCadena;
            let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'cartera_base.sql';
            System cCadena;

            drop table cb_tabla_temporal;

LET cMensaje = TRIM(vNomArch);

CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03');
            
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;