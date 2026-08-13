CREATE PROCEDURE "informix".sp_portanom_cargaarchivocancelaciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaRegistro DATE, pRutaArchivo CHAR(50), pArchivo CHAR(50), pCodigoOperacion CHAR(2), pTotalSolicitudes INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(35) AS archivo_respuestas,
				CHAR(50) AS ruta_deposito_archivo_central;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cArchivoRespuestas CHAR(35);
	DEFINE cRutaCentralRespuesta CHAR(50);
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cArchivoRespuestas = '';
	LET cRutaCentralRespuesta = '';
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
        --SET DEBUG FILE TO '/tmp/mfinis/sp_portanom_cargaarchivocancelaciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pArchivo = '' OR pCodigoOperacion = '' OR pTotalSolicitudes IS NULL OR pFechaRegistro IS NULL  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		IF pCodigoOperacion <>'22' THEN
			LET cCodRet = '00102';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_cargarchivoportab_cancelaciones(pFechaRegistro, TRIM(pArchivo), pCodigoOperacion, pTotalSolicitudes)
		INTO cCodRetSp, cArchivoRespuestas, cRutaCentralRespuesta;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:'informix'.sp_cargarchivoportabcancel";
		ELIF iCodRetSp = 191 THEN --VALIDA QUE EL ARCHIVO EXISTA
			LET cCodRet = '00553';
		ELIF iCodRetSp = 175 THEN --EXISTE UN TIPO DE REGISTRO QUE NO ES AUTORIZADO
			LET cCodRet = '00687';
		ELIF iCodRetSp = 176 THEN --NO EXISTE ENCABEZADO EN EL ARCHIVO
			LET cCodRet = '00086';
		ELIF iCodRetSp = 177 THEN --EXISTE MAS DE UN ENCABEZADO EN EL ARCHIVO
			LET cCodRet = '00656';
		ELIF iCodRetSp = 178 THEN --NO EXISTE SUMARIO EN EL ARCHIVO
			LET cCodRet = '00657';
		ELIF iCodRetSp = 179 THEN --EXISTE MAS DE UN SUMARIO EN EL ARCHIVO
			LET cCodRet = '00658';
		ELIF iCodRetSp = 180 THEN --NO EXISTE DETALLE EN EL ARCHIVO
			LET cCodRet = '00659';
		ELIF iCodRetSp = 181 THEN --LA SECUENCIA EN EL DETALLE NO ES CORRECTA
			LET cCodRet = '00688';
		ELIF iCodRetSp = 182 THEN --ERROR UN VALOR NULLOS EN EL ARCHIVO
			LET cCodRet = '00483';
		ELIF iCodRetSp = 33333 THEN --TRATA DE VOLVER A CARGARLO, EL ARCHIVO YA FUE PROCESADO
			LET cCodRet = '00492';
		ELIF iCodRetSp = 77777 THEN --PARAMETROS VACIOS
			LET cCodRet = '00003';	
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00017';
		END IF;
		
		--IF cCodRet::INT > 0 THEN
		--	IF bInTransaction THEN
		--		BEGIN WORK;
		--	END IF;
		--END IF;
		
		--IF bInTransaction = 't' THEN
		--	BEGIN WORK;
		--END IF;
			
		RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 25/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Portabilidad de nomina - Solicitudes - Cancelaciones',
'DESCRIPCION: Realiza el vaciado de la informaciÃ³n a un archivo',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_obtener_cta_con_cel(pNumCte CHAR(10))
											  
-- Valida si el cliente tiene un número de celular asociado a una cuenta
-- AUTOR : Keevyn Adrian Gil Valenzuela
-- FECHA : 29/11/2016
-- BD    : bdicheq

RETURNING
    CHAR(5),
	CHAR(10),
	CHAR(20);        
	
	-- Declarar variables 
	DEFINE cCodRet char(5);
	DEFINE cNumCel char(10);
	DEFINE cCuenta char(20);
	DEFINE iSql_err integer;

	-- Inicializar variables 
	LET cCodRet  = "";
	LET cNumCel  = "";
	LET cCuenta  = "";
	LET iSql_err = 0;

	
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			let cCodRet = iSql_err;
            RETURN cCodRet,cNumCel,cCuenta;
		END IF;
	END EXCEPTION ;
	
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/respaldosbd/Keevyn/sp_obtener_cta_con_cel.out";
	--TRACE ON;
	
	SELECT cuenta,telefono INTO cCuenta,cNumCel FROM bdicheq:"informix".sc_cuenta_telefono WHERE num_cte=pNumCte;
	IF (TRIM(cCuenta) <> "" OR cCuenta IS NOT NULL) THEN--Tiene celular asociado
		LET cCodRet="00000";
	ELSE
		LET cCodRet = "00001";	END IF	
	RETURN cCodRet,cNumCel,cCuenta;

END
END PROCEDURE;