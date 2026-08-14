CREATE PROCEDURE "informix".sp_portanom_cargaarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaRegistro DATE, pRutaArchivo CHAR(50), pArchivo CHAR(50), pCodigoOperacion CHAR(2), pTotalSolicitudes INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(35) AS archivo_respuestas,
				CHAR(50) AS ruta_deposito_archivo_central;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
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
		
        --SET DEBUG FILE TO '/tmp/sp_portanom_car.out';
		--SET DEBUG FILE TO '/resplogifx/conciliachq/sp_portanom_cargaarchivo_rr.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pArchivo = '' OR pCodigoOperacion = '' OR pTotalSolicitudes IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		IF pCodigoOperacion NOT IN ('20', '21') THEN
			LET cCodRet = '00102';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		IF pCodigoOperacion = '20' AND pFechaRegistro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		ELIF pCodigoOperacion = '21' AND pFechaRegistro IS NULL THEN
			LET pFechaRegistro = CURRENT;
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
		
		EXECUTE PROCEDURE bdicheq:'informix'.sp_cargarchivoportab(pFechaRegistro, TRIM(pArchivo), pCodigoOperacion, pTotalSolicitudes)
		INTO cCodRetSp, cArchivoRespuestas, cRutaCentralRespuesta;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:'informix'.sp_cargarchivoportab";
		ELIF iCodRetSp = 191 THEN
			LET cCodRet = '00553';
		ELIF iCodRetSp = 175 THEN -- EXISTE UN TIPO DE REGISTRO QUE NO ES AUTORIZADO
			LET cCodRet = '00687';
		ELIF iCodRetSp = 176 THEN
			LET cCodRet = '00086';
		ELIF iCodRetSp = 177 THEN
			LET cCodRet = '00656';
		ELIF iCodRetSp = 178 THEN
			LET cCodRet = '00657';
		ELIF iCodRetSp = 179 THEN
			LET cCodRet = '00658';
		ELIF iCodRetSp = 180 THEN
			LET cCodRet = '00659';
		ELIF iCodRetSp = 181 THEN -- LA SECUENCIA EN EL DETALLE NO ES CORRECTA
			LET cCodRet = '00688';
		ELIF iCodRetSp = 182 THEN
			LET cCodRet = '00483';
		ELIF iCodRetSp = 200 THEN
			LET cCodRet = '00009';
		ELIF iCodRetSp = 201 THEN
			LET cCodRet = '00104';
		ELIF iCodRetSp = 202 THEN
			LET cCodRet = '00104';
		ELIF iCodRetSp = 203 THEN
			LET cCodRet = '00690';
		ELIF iCodRetSp = 204 THEN
			LET cCodRet = '00691';
		ELIF iCodRetSp = 205 THEN
			LET cCodRet = '00692';
		ELIF iCodRetSp = 333 THEN
			LET cCodRet = '00492';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 08/09/2015',
'MODULO: Operaciones',
'FUNCIONALIDAD: Portabilidad de nomina - Solicitudes',
'DESCRIPCION: Realiza el vaciado de la informaciÃ³n a un archivo',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_valida_status_ppc(pnumcte CHAR(20), pfolioPres CHAR(20), pTarjeta CHAR(4))
       RETURNING CHAR(5) AS cCodRet;

DEFINE cCodRet			CHAR(5); 
DEFINE iSqlErr          INTEGER; 
DEFINE iMonto           MONEY;
DEFINE cCuenta			CHAR(20);
DEFINE cSuc				CHAR(4);
DEFINE cFoliosuc        CHAR(16);

LET cCodRet = "00000";
LET iSqlErr = 0;
LET iMonto = 0;
LET cCuenta = "";
LET cSuc = "";
LET cFoliosuc = "";

BEGIN

   ON EXCEPTION SET iSqlErr
        LET cCodRet=iSqlErr;
        RETURN cCodRet;
    
    END EXCEPTION;
	
	IF pnumcte ='' THEN
	  LET cCodRet='00001'; -- Parametro de entrada vacio
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT 
		monto_autorizado
		, sucursal 
	INTO 
		iMonto
		, cSuc 
	FROM 
		bdisolic:ss_prestamoscoppel 
	WHERE 
		numcte = pnumcte 
		AND folio_prestamo = pfolioPres 
		AND status_solicitud='P';
	 
	IF iMonto > 0 or iMonto is not null THEN
			SELECT 
				cuenta 
			INTO  
				cCuenta 
			FROM 
				BDICHEQ:sc_tarjeta 
			WHERE 
				numcte = pnumcte 
				AND substr(num_tarjeta,13,4) = pTarjeta 
				AND status_tar = 'A';
	  
		IF cCuenta is not null or cCuenta <> '' THEN
				SELECT 
					FIRST 1 folio_suc 
				INTO 
					cFoliosuc
				FROM 
					bdicheq:sc_movdia 
				WHERE 
					sucursal = '5006' 
					AND cuenta = cCuenta 
					AND monto_tot = iMonto;
					--AND producto = '2000' 
					--AND substr(referencia,1,16) = 'TIENDA COPPEL PP';
	  	END IF
		
		IF NVL(cFoliosuc,'') = '' THEN
			LET cCodRet='00003'; -- NO se encontro el prestamo			  
            RETURN cCodRet;
			
		ELSE			    
 		    UPDATE 
				bdisolic:informix.ss_prestamoscoppel 
			SET 
				status_solicitud = 'A'
 		    WHERE 
				numcte = pnumcte 
				AND folio_prestamo = pfolioPres 
				AND sucursal= cSuc 
				AND monto_autorizado = iMonto;

			LET cCodRet='00000'; 

     END IF
	ELSE
	 LET cCodRet ='00002'; -- No existe el registro
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE;