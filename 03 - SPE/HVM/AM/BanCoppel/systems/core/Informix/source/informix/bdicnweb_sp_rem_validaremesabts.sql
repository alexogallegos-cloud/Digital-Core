CREATE PROCEDURE "informix".sp_rem_validaremesabts(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumBts CHAR(11), pFolioSucursal CHAR(16), pFechaRealPago DATE)
    RETURNING CHAR(5) AS codRet,
		CHAR(15) AS Sucursal,
		CHAR(15) AS Terminal,
		CHAR(3)  AS R_Type_Cd,
		CHAR(20) AS R_Identif_Nm,
		CHAR(50) AS Nom_Calle,
		CHAR(5)  AS Num_Ext,
		CHAR(5)  AS Num_Int,
		CHAR(10) AS Depto,
		CHAR(80) AS Colonia,
		CHAR(5)  AS Cp,
		CHAR(50) AS Mncpo_Deleg,
		CHAR(50) AS Ciudad,
		CHAR(50) AS Estado,
		CHAR(3)  AS Issuer_Country_Cd,
		CHAR(15) AS Telefono,
		CHAR(1)  AS Tipo_Pago,
		CHAR(8)  AS Fecha_Nac,
		CHAR(50) AS Nacionalidad,
		CHAR(20) AS Pais_Nac,
		CHAR(20) AS Folio_Sucursal,
		CHAR(21) AS R_Issuer_Cd,
		CHAR(22) AS R_Expiration_Dt;
	
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INT;
	DEFINE cCodRetSp 			CHAR(6);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE cDescCodRet 			CHAR(80);
	DEFINE cEmpresa 			CHAR(3);
	
	DEFINE cSucursal            CHAR(15);
	DEFINE cTerminal            CHAR(15);
	DEFINE cR_Type_Cd           CHAR(3);
	DEFINE cR_Identif_Nm        CHAR(20);
	DEFINE cR_Nom_Calle         CHAR(50);
	DEFINE cR_Num_Ext           CHAR(5);
	DEFINE cR_Num_Int           CHAR(5);
	DEFINE cR_Depto             CHAR(10);
	DEFINE cR_Colonia           CHAR(80);
	DEFINE cR_Cp                CHAR(5);
	DEFINE cR_Mncpo_Deleg       CHAR(50);
	DEFINE cR_Ciudad            CHAR(50);
	DEFINE cR_Estado            CHAR(50);
	DEFINE cR_Issuer_Country_Cd CHAR(3);
	DEFINE cR_Telefono          CHAR(15);
	DEFINE cTipo_Pago           CHAR(1);
	DEFINE cR_Fecha_Nac         CHAR(8);
	DEFINE cR_Nacionalidad      CHAR(50);
	DEFINE cR_Pais_Nac			CHAR(20);
	DEFINE cFolio_Sucursal      CHAR(20);
	DEFINE cR_Issuer_Cd         CHAR(21);
	DEFINE cR_Expiration_Dt     CHAR(22);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cDescCodRet 			= '';
	LET cEmpresa 				= '001';
	
	LET cSucursal               = '';
	LET cTerminal               = '';
	LET cR_Type_Cd              = '';
	LET cR_Identif_Nm           = '';
	LET cR_Nom_Calle            = '';
	LET cR_Num_Ext              = '';
	LET cR_Num_Int              = '';
	LET cR_Depto                = '';
	LET cR_Colonia              = '';
	LET cR_Cp                   = '';
	LET cR_Mncpo_Deleg          = '';
	LET cR_Ciudad               = '';
	LET cR_Estado               = '';
	LET cR_Issuer_Country_Cd    = '';
	LET cR_Telefono             = '';
	LET cTipo_Pago              = '';
	LET cR_Fecha_Nac            = '';
	LET cR_Nacionalidad         = '';
	LET cR_Pais_Nac				= '';
	LET cFolio_Sucursal			= '';
	LET cR_Issuer_Cd            = '';
	LET cR_Expiration_Dt		= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
				cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
				cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
				cR_Issuer_Cd,cR_Expiration_Dt;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_validaremesabts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumBts = '' OR pFolioSucursal = '' OR pFechaRealPago IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
			cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
			cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
			cR_Issuer_Cd,cR_Expiration_Dt;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
			cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
			cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
			cR_Issuer_Cd,cR_Expiration_Dt;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_validarembtsensac(pNumBts,pFolioSucursal,pFechaRealPago)
		INTO cCodRetSp,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
		cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
		cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
		cR_Issuer_Cd,cR_Expiration_Dt;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_validarembtsensac';
		ELIF cCodRetSp::INTEGER > 0 THEN
			IF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 4 THEN
				LET cCodRet = '00971'; --FECHA REAL DEL PAGO INVALIDA, VERIFIQUE
			ELSE
				LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR
			END IF;
		ELIF cCodRetSp::INTEGER = 0 THEN
			IF cFolio_Sucursal <> '' AND (pFolioSucursal = cFolio_Sucursal) THEN
				LET cCodRet = '00000';
			ELSE
				LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR
			END IF;
		END IF;
		
		RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
		cR_Depto,UPPER(cR_Colonia),cR_Cp,UPPER(cR_Mncpo_Deleg),UPPER(cR_Ciudad),UPPER(cR_Estado),UPPER(cR_Issuer_Country_Cd),
		cR_Telefono,UPPER(cTipo_Pago),cR_Fecha_Nac,UPPER(cR_Nacionalidad),UPPER(cR_Pais_Nac),cFolio_Sucursal,		
		UPPER(cR_Issuer_Cd),cR_Expiration_Dt;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de validar que exista la remesa que se desea pagar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesamensajeserrorwu(pUsuario CHAR(8), pIdFuncion CHAR(10), pCode CHAR(6), pDescripcion CHAR(255))
		RETURNING CHAR(5) AS codret,
		CHAR(6)     AS codError,       
		CHAR(255)   AS traduccion;
	
	DEFINE cCodRet      CHAR(5);
	DEFINE iSqlErr      INTEGER;
	DEFINE cCodError    CHAR(6);  
	DEFINE cTraduccion  CHAR(255);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet         = '00000';
	LET iSqlErr         = 0;
	LET cCodError       = '';  
	LET cTraduccion     = '';
	LET iNoRegistros    = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCodError,cTraduccion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesamensajeserrorwu.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pCode = '' OR pDescripcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCodError,cTraduccion;
		END IF;
		 
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCodError,cTraduccion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF EXISTS(SELECT coderror FROM intercard:"informix".wswesternunionerrores WHERE coderror = pCode) THEN
				
			SELECT coderror,NVL(traduccion,'') INTO cCodError,cTraduccion
			FROM intercard:"informix".wswesternunionerrores WHERE coderror=pCode;
							
			RETURN cCodRet,cCodError,cTraduccion;
		
		ELSE
						
			INSERT INTO intercard:"informix".wswesternunionerrores(coderror,traduccion) VALUES(pCode,pDescripcion);
	
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF; 
				
			RETURN cCodRet,pCode,pDescripcion;

				
		END IF;
			
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 06/06/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: Consulta de Remesas WU',
'DESCRIPCION: SPL que consulta o inserta en el catálogo de mensajes',
'AUTOR: L. Montserrat León Amador',
'FECHA: 21/08/2017',
'DESCRIPCION: Se modifica spl para corregir validación de parámetros de entrada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesasguardarespuestawu(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pMarca					CHAR(2),
pForeignRsRefNumRq    	CHAR(16),
pMtcn              	    CHAR(10),
pFechaHoraRq       	    CHAR(25),
pRetCode         		CHAR(5),
pEmisorNameType     	CHAR(1),
pEmisorNombre1          CHAR(40),
pEmisorNombre2          CHAR(40),
pEmisorApPaterno    	CHAR(40),
pEmisorApMaterno    	CHAR(40),
pEmisorCiudad       	CHAR(20),
pEmisorEdo          	CHAR(40),
pEmisorCodPais      	CHAR(3),
pEmisorCodMoneda    	CHAR(3),
pEmisorCp           	CHAR(8), 
pEmisorCalle        	CHAR(30), 
pEmisorTel          	CHAR(15), 
pBenefNameType 			CHAR(1),
pBenefNombre1           CHAR(40),
pBenefNombre2           CHAR(40),
pBenefApaterno      	CHAR(40), 
pBenefAmaterno      	CHAR(40),
pBenefCiudad        	CHAR(20), 
pBenefEdo           	CHAR(40), 
pBenefCodPais       	CHAR(3),
pBenefCodMoneda     	CHAR(3), 
pBenefCp            	CHAR(8), 
pBenefCalle         	CHAR(30), 
pBenefTelPart       	CHAR(15),
pBenefTelCel       		CHAR(10), 
pMontoTotalOrigen  		CHAR(10),
pMontoToTDestino    	CHAR(10),
pMontoOrigen        	CHAR(10),
pMontoCargos        	CHAR(10), 
pCdOrigenPago       	CHAR(30), 
pTipoCambio         	CHAR(10),
pFechaAltaRemesa    	CHAR(8),
pHoraAltaRemesa     	CHAR(16), 
pMoneyTransKey      	CHAR(10),
pEstatusRemesa      	CHAR(4), 
pNewMtcn            	CHAR(16),
pFusionStatus       	CHAR(4),
pNoPaginas          	CHAR(2),
pPaginaActual       	CHAR(2), 
pNumCoincidencias   	CHAR(2), 
pForeignRsSystemIdRp  	CHAR(11), 
pForeignRsRefNumRp      CHAR(16), 
pForeingRsCantIdRp      CHAR(11),
pDescError              CHAR(250),
pPartnerIdErr           CHAR(10) 
)
RETURNING CHAR(5) AS codret;

DEFINE cCodRet   CHAR(5);
DEFINE iSqlErr   INTEGER;
DEFINE cCodRetSp CHAR(3);
DEFINE iCodRetSp INTEGER;
DEFINE iNoRegistros INTEGER;
DEFINE cEmpresa     CHAR(3);
DEFINE cError_Desc  CHAR(30);
	
	
LET cCodRet = '00000';
LET iSqlErr = 0;
LET cCodRetSp = '';
LET iCodRetSp = 0;
LET iNoRegistros = 0;
LET cEmpresa='001';
LET cError_Desc	 = '';

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesasguardarespuestawu.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_search(cEmpresa,pUsuario,pMarca,pForeignRsRefNumRq,pMtcn,pFechaHoraRq,pRetCode,pEmisorNameType,pEmisorNombre1,
		pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,pEmisorTel,pBenefNameType,pBenefNombre1,
		pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,
		pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,
		pNumCoincidencias,pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,current,pUsuario,current)--pFechaHoraRp
		INTO cCodRetSp ,cError_Desc;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisac:sp_sac_wu_guardarespuesta_search";
		ELIF iCodRetSp = 27 THEN
			LET cCodRet = '00976'; -- USUARIO NO TIENE ID. ASIGNADO
		ELIF iCodRetSp = 26 THEN
			LET cCodRet = '00025'; -- NO EXISTE USUARIO, 			 	EL USUARIO NO EXISTE
		ELIF iCodRetSp = 23 THEN
			LET cCodRet = '00978'; -- SE TIENE QUE REVERSAR PRIMERO ANTES DE INTENTAR EL PAGO NUEVAMENTE	
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00977'; -- NO EXISTE MARCA EN SAC PARAM	
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00770'; -- ERROR EN EL PROCESO, 				PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
		END IF;
				
		RETURN cCodRet; 
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 05/05/2017',
'MODULO: Remesas',
'FUNCIONALIDAD: Remesas - Consulta Remesas WU',
'DESCRIPCION: Guarda respuesta de transaccion en bdisac:sac_wu_search',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_actlimiteremesa_edo_suc(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), pIdRemesadora SMALLINT, pValor CHAR(4), 
pPesos MONEY(16,2), pUsd MONEY(16,2), pStatus SMALLINT)
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAbreviatura CHAR(20);
	DEFINE cMarca CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAbreviatura = '';
	LET cMarca = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_actlimiteremesa_edo_suc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pIdRemesadora IS NULL OR pValor = '' OR 
		pPesos IS NULL OR pUsd IS NULL OR pStatus IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pIdRemesadora = 1 THEN
			LET cAbreviatura = 'APP_DIA_';
			LET cMarca = 'APP';
		ELIF pIdRemesadora = 2 THEN
			LET cAbreviatura = 'BTS_DIA_';
			LET cMarca = 'BTS';
		ELIF pIdRemesadora = 3 THEN
			LET cAbreviatura = 'WU_DIA_';
			LET cMarca = 'WU';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Actualiza Estado
		IF pIdEjecucion = '1' THEN
		
			UPDATE bdisac:"informix".sac_limite_edo SET pesos = pPesos, usd = pUsd, status = pStatus--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura) AND estado = TRIM(pValor);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
				
		--Actualiza Sucursal 
		ELIF pIdEjecucion = '2' THEN
		
			UPDATE bdisac:"informix".sac_limite_suc SET pesos = pPesos, usd = pUsd, status = pStatus--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura) AND sucursal = TRIM(pValor);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		--Guarda Sucursal 
		ELIF pIdEjecucion = '3' THEN
			
			INSERT INTO bdisac:"informix".sac_limite_suc (abreviatura,sucursal,pesos,usd,marca,status,descripcion,fecha_insert) 
			VALUES(TRIM(cAbreviatura),TRIM(pValor),pPesos,pUsd,TRIM(cMarca),pStatus,'Limite por operaciones',CURRENT YEAR TO FRACTION(3));
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
			END IF;
			
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de guardar/actualizar el valor del límite en UDS y PESOS y el status, dependiendo del tipo de remesadora y estado o sucursal seleccionados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_catalogoestado(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS id_estado,
			CHAR(30) AS desc_estado;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdEstado CHAR(2);
	DEFINE cDescEstado CHAR(30);
	DEFINE cMarca CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdEstado = 0;
	LET cDescEstado = '';
	LET cMarca = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdEstado, cDescEstado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_catalogoestado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdEstado, cDescEstado;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdEstado, cDescEstado;
		END IF;
		
		IF pIdConsulta = '1' THEN
			LET cMarca = 'APP';
		ELIF pIdConsulta = '2' THEN
			LET cMarca = 'BTS';
		ELIF pIdConsulta = '3' THEN
			LET cMarca = 'WU';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT a.estado, b.nombre
			INTO cIdEstado, cDescEstado
			FROM bdisac:"informix".sac_limite_edo AS a, bdinteg:"informix".si_estados As b 
			WHERE a.estado = b.estado AND a.marca = TRIM(cMarca) ORDER BY a.estado ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cIdEstado, TRIM(UPPER(cDescEstado)) WITH RESUME;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdEstado, cDescEstado;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo estado, dependiendo del tipo de remesadora seleccionada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_catalogoremesadora(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1))
		RETURNING CHAR(5) AS codret,
			SMALLINT AS id_remesadora,
			CHAR(100) AS desc_remesadora;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdRemesadora SMALLINT;
	DEFINE cDescRemesadora CHAR(100);
	DEFINE cGpoRemesadora CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdRemesadora = 0;
	LET cDescRemesadora = '';
	LET cGpoRemesadora = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_catalogoremesadora.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdConsulta = '1' THEN
			LET cGpoRemesadora = 'A';
		ELIF pIdConsulta = '3' THEN
			LET cGpoRemesadora = 'C';
		END IF;
		
		IF pIdConsulta = '1' OR pIdConsulta = '3' THEN
			FOREACH
				
				SELECT id_remesadora, desc_remesadora
				INTO cIdRemesadora, cDescRemesadora
				FROM bdicnweb:"informix".sw_rem_remesadora
				WHERE grupo_remesadora = TRIM(cGpoRemesadora)
				ORDER BY desc_remesadora ASC
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cIdRemesadora, TRIM(UPPER(cDescRemesadora)) WITH RESUME;
				
			END FOREACH;
		
		ELIF pIdConsulta = '2' THEN
		
			FOREACH
				
				SELECT id_remesadora, desc_remesadora
				INTO cIdRemesadora, cDescRemesadora
				FROM bdicnweb:"informix".sw_rem_remesadora
				WHERE grupo_remesadora IN ('A','B')
				ORDER BY desc_remesadora ASC
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cIdRemesadora, TRIM(UPPER(cDescRemesadora)) WITH RESUME;
				
			END FOREACH;
			
		ELIF pIdConsulta = '4' THEN
		
			FOREACH
				
				SELECT id_remesadora, desc_remesadora
				INTO cIdRemesadora, cDescRemesadora
				FROM bdicnweb:"informix".sw_rem_remesadora
				WHERE grupo_remesadora IN ('A','B','C')
				ORDER BY desc_remesadora ASC
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cIdRemesadora, TRIM(UPPER(cDescRemesadora)) WITH RESUME;
				
			END FOREACH;
			
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo remesadora dependiendo del tipo de límite seleccionado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_catalogostatus(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			SMALLINT AS id_status,
			CHAR(12) AS desc_status;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdStatus CHAR(2);
	DEFINE cDescStatus CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdStatus = 0;
	LET cDescStatus = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdStatus, cDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_catalogostatus.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT id_status,desc_status 
			INTO cIdStatus, cDescStatus
			FROM bdicnweb:"informix".sw_rem_statuslimite
			ORDER BY id_status ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cIdStatus, TRIM(UPPER(cDescStatus)) WITH RESUME;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar los status disponibles del límite de remesas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consactlimiteremesa_monto_acum(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), 
pTipoMonto CHAR(1), pIdRemesadora SMALLINT, pPesos MONEY(16,2), pUsd MONEY(16,2), pStatus SMALLINT)
		RETURNING CHAR(5) AS codret,
			MONEY(16,2) AS usd,
			MONEY(16,2) AS pesos,
			SMALLINT AS status;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAbreviatura CHAR(20);
	DEFINE mUsd MONEY(16,2);
	DEFINE mPesos MONEY(16,2);
	DEFINE sStatus SMALLINT;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAbreviatura = '';
	LET mUsd = 0.00;
	LET mPesos = 0.00;
	LET sStatus = NULL;
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, mUsd, mPesos, sStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consactlimiteremesa_monto_acum.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pTipoMonto = '' OR pIdRemesadora IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, mUsd, mPesos, sStatus;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, mUsd, mPesos, sStatus;
		END IF;
		
		IF pTipoMonto = 'D' THEN
		
			IF pIdRemesadora = 1 THEN
				LET cAbreviatura = 'APP_DIA_';
			ELIF pIdRemesadora = 2 THEN
				LET cAbreviatura = 'BTS_DIA_';
			ELIF pIdRemesadora = 3 THEN
				LET cAbreviatura = 'WU_DIA_';
			ELIF pIdRemesadora = 4 THEN
				LET cAbreviatura = 'APP_DIA_AUT_';
			ELIF pIdRemesadora = 5 THEN
				LET cAbreviatura = 'BTS_DIA_AUT_';
			END IF;
		
		ELIF pTipoMonto = 'M' THEN
		
			IF pIdRemesadora = 1 THEN
				LET cAbreviatura = 'APP_MES_';
			ELIF pIdRemesadora = 2 THEN
				LET cAbreviatura = 'BTS_MES_';
			ELIF pIdRemesadora = 3 THEN
				LET cAbreviatura = 'WU_MES_';
			ELIF pIdRemesadora = 4 THEN
				LET cAbreviatura = 'APP_MES_AUT_';
			ELIF pIdRemesadora = 5 THEN
				LET cAbreviatura = 'BTS_MES_AUT_';
			END IF;
			
		ELIF pTipoMonto = 'A' THEN
		
			IF pIdRemesadora = 6 THEN
				LET cAbreviatura = 'TODAS_';
			END IF;
			
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Consulta
		IF pIdEjecucion = '1' THEN 
		
			SELECT usd, pesos, status 
			INTO mUsd, mPesos, sStatus
			FROM bdisac:"informix".sac_limite_monto
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00017';
			END IF;
				
		--Actualiza
		ELIF pIdEjecucion = '2' THEN 
		
			IF pPesos IS NULL OR pUsd IS NULL OR pStatus IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, mUsd, mPesos, sStatus;
			END IF;
		
			UPDATE bdisac:"informix".sac_limite_monto SET pesos = pPesos, usd = pUsd, status = pStatus--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		END IF;
		
		RETURN cCodRet, mUsd, mPesos, sStatus;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 20/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar/actualizar el valor del límite en UDS y PESOS y el status, dependiendo del tipo de remesadora seleccionada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consactlimiteremesa_numtrans(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), pIdRemesadora SMALLINT, pNoTransacciones SMALLINT)
		RETURNING CHAR(5) AS codret,
			SMALLINT AS no_transacciones;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAbreviatura CHAR(20);
	DEFINE sNoTransacciones SMALLINT;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAbreviatura = '';
	LET sNoTransacciones = NULL;
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sNoTransacciones;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consactlimiteremesa_numtrans.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pIdRemesadora IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sNoTransacciones;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sNoTransacciones;
		END IF;
		
		IF pIdRemesadora = 1 THEN
			LET cAbreviatura = 'APP_MES_';
		ELIF pIdRemesadora = 2 THEN
			LET cAbreviatura = 'BTS_MES_';
		ELIF pIdRemesadora = 3 THEN
			LET cAbreviatura = 'WU_MES_';
		ELIF pIdRemesadora = 4 THEN
			LET cAbreviatura = 'APP_MES_AUT_';
		ELIF pIdRemesadora = 5 THEN
			LET cAbreviatura = 'BTS_MES_AUT_';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Consulta
		IF pIdEjecucion = '1' THEN 
		
			SELECT operaciones
			INTO sNoTransacciones
			FROM bdisac:"informix".sac_limite_monto
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00017';
			END IF;
				
		--Actualiza
		ELIF pIdEjecucion = '2' THEN 
		
			IF pNoTransacciones IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, sNoTransacciones;
			END IF;
		
			UPDATE bdisac:"informix".sac_limite_monto SET operaciones = pNoTransacciones--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		END IF;
		
		RETURN cCodRet, sNoTransacciones;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 19/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar/actualizar el número de transacciones, dependiendo del tipo de remesadora seleccionada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_generarepremesasnopagadas(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1),
pIdLimite SMALLINT, pFechaInicio DATE, pFechaFin DATE, pClaveId CHAR(100), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS limite,
		DATE AS fecha_env,
		CHAR(40) AS nombre1_ord,
		CHAR(40) AS nombre2_ord,
		CHAR(40) AS appaterno_ord,
		CHAR(40) AS apmaterno_ord,
		CHAR(80) AS direccion_ord,
		CHAR(80) AS colonia_ord,
		CHAR(40) AS ciudad_ord,
		CHAR(3) AS estado_ord,
		CHAR(3) AS pais_ord,
		CHAR(3) AS tipoid_ord,
		CHAR(20) AS numeroid_ord,
		CHAR(3) AS ciudadid_ord,
		CHAR(3) AS paisid_ord,
		CHAR(3) AS moneda_ord,
		CHAR(20) AS monto_origen,
		CHAR(20) AS monto_pesos,
		CHAR(40) AS nombre1_ben,
		CHAR(40) AS nombre2_ben,
		CHAR(40) AS appaterno_ben,
		CHAR(40) AS apmaterno_ben,
		CHAR(8) AS fechanacimiento_ben,
		CHAR(80) AS direccion_ben,
		CHAR(80) AS colonia_ben,
		CHAR(40) AS ciudad_ben,
		CHAR(40) AS estado_ben,
		CHAR(15) AS telefono_ben,
		CHAR(3) AS tipoid_ben,
		CHAR(20) AS numeroid_ben,
		CHAR(4) AS numeroid_suc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	DEFINE cAutoridad CHAR(8);
	DEFINE cReporte CHAR(35);
	DEFINE cDescripcion CHAR(100);
	DEFINE cStatus CHAR(1);
	DEFINE cDescStatus CHAR(10);
	
	DEFINE iSerial INTEGER;
	DEFINE cRespMensaje CHAR(45);
	
	DEFINE iRegistros INTEGER;
	DEFINE iGraba INTEGER;
	DEFINE iFormatoAnt INTEGER;
	DEFINE cDato CHAR(25);
	DEFINE cDatoFormat CHAR(20);
	DEFINE cRenglon CHAR(255);
	DEFINE cFormat CHAR(11);
	DEFINE cSeleccion CHAR(255);
	DEFINE cQuery CHAR(255);
	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE iCountRep INTEGER;
	DEFINE iProcesaRep INT;
	DEFINE iArmaReporte INT;
	
	DEFINE cArchivoCP CHAR(45);
	DEFINE cCmdQuery CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE dFechaEnv DATE;
	DEFINE cNombre1Ord CHAR(40);
	DEFINE cNombre2Ord CHAR(40);
	DEFINE cApPaternoOrd CHAR(40);
	DEFINE cApMaternoOrd CHAR(40);
	DEFINE cDireccionOrd CHAR(80);		
	DEFINE cColoniaOrd CHAR(80);    	
	DEFINE cCiudadOrd CHAR(40);			
	DEFINE cEstadoOrd CHAR(3);	
	DEFINE cPaisOrd CHAR(3);	
	DEFINE cTipoIdOrd CHAR(3);	
	DEFINE cNumeroIdOrd CHAR(20);	
	DEFINE cCiudadIdOrd CHAR(3);	
	DEFINE cPaisIdOrd CHAR(3);	
	DEFINE cMonedaOrd CHAR(3);	
	DEFINE cMontoOrigen CHAR(20);		
	DEFINE cMontoPesos CHAR(20);		
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cFechaNacimientoBen CHAR(8);
	DEFINE cDireccionBen CHAR(80);		
	DEFINE cColoniaBen CHAR(80);    	
	DEFINE cCiudadBen CHAR(40);	    	
	DEFINE cEstadoBen CHAR(40);     	
	DEFINE cTelefonoBen CHAR(15);	
	DEFINE cTipoIdBen CHAR(3);      	
	DEFINE cNumeroIdBen CHAR(20);   	
	DEFINE cNumeroIdSuc CHAR(4);
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cClaveId CHAR(100);
	DEFINE cLimite CHAR(100);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	LET cAutoridad = '';
	LET cReporte = '';
	LET cDescripcion = '';
	LET cStatus = '';
	LET cDescStatus = '';
	
	LET iSerial = 0;
	LET cRespMensaje = '';
	
	LET iRegistros = 0;
	LET iGraba = 0;
	LET iFormatoAnt = 0;
	LET cDato = '';
	LET cDatoFormat = '';
	LET cRenglon = '';
	LET cFormat = '';
	LET cSeleccion = '';
	LET cQuery = '';
	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/informix/bin/';
	LET iCountRep = 0;
	LET iProcesaRep = 0;
	LET iArmaReporte = 0;

	LET cArchivoCP = '';
	LET cCmdQuery = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET dFechaEnv = '';
	LET cNombre1Ord = '';
	LET cNombre2Ord = '';
	LET cApPaternoOrd = '';
	LET cApMaternoOrd = '';
	LET cDireccionOrd = '';
	LET cColoniaOrd = '';
	LET cCiudadOrd = '';
	LET cEstadoOrd = '';
	LET cPaisOrd = '';
	LET cTipoIdOrd = '';
	LET cNumeroIdOrd = '';
	LET cCiudadIdOrd = '';
	LET cPaisIdOrd = '';
	LET cMonedaOrd = '';
	LET cMontoOrigen = '';
	LET cMontoPesos = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cFechaNacimientoBen = '';
	LET cDireccionBen = '';
	LET cColoniaBen = '';
	LET cCiudadBen = '';
	LET cEstadoBen = '';
	LET cTelefonoBen = '';
	LET cTipoIdBen = '';
	LET cNumeroIdBen = '';
	LET cNumeroIdSuc = '';
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET cClaveId = 'REMNOPAGADAS'||TRIM(pUsuario)||TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	LET cLimite = '';
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
				cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
				cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_generarepremesasnopagadas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pIdLimite IS NULL OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pClaveId = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		IF pIdLimite = 8 THEN
			LET pIdLimite = NULL;
		END IF;
		
		FOREACH
		
			SELECT SKIP pRegistros FIRST pRecuperacion limite,fecha_env,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,
			tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,
			fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc
			INTO cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc				
			FROM bdicnweb:"informix".sw_detalleremesasnopagadas
			WHERE id_limite = (CASE WHEN pIdLimite IS NULL THEN id_limite ELSE pIdLimite END)
			AND fecha_env BETWEEN pFechaInicio AND pFechaFin
			AND usuario_insert = pUsuario AND clave_id = TRIM(pClaveId)
			ORDER BY limite,fecha_env ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc WITH RESUME;
			
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA DE REMESAS NO PAGADAS',
'DESCRIPCION: Spl encargado de consultar el detalle de las remesas no pagadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_verificastatusremesasnopagadas(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS num_registros,
			  CHAR(100) AS clave_id,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iNumRegistros INTEGER;
	DEFINE cClaveId CHAR(100);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iNumRegistros = 0;
	LET cClaveId = '';
	LET cErrorProceso = '';
	LET cError = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_verificastatusremesasnopagadas.out';
		--TRACE ON;
		
		--VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,num_registros,clave_id,error_proceso,error
		INTO cStatus,iNumRegistros,cClaveId,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_statusprocesoremnopag WHERE usuario_insert = TRIM(pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I',0,'','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/01/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA DE REMESAS NO PAGADAS',
'DESCRIPCION: Spl encargado de verificar el status del proceso de consulta de las remesas no pagadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallefacturacionos_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pNumCte CHAR(9), 
pFechaInicio CHAR(10), pFechaFin CHAR(10), pTipoFecha SMALLINT, pTipoConsulta SMALLINT)
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;	
	
	DEFINE cCodRet 		  CHAR(5);
	DEFINE iSqlErr 		  INTEGER;
	DEFINE cCodRetSp 	  CHAR(6);
	DEFINE cDesCodRetSp   CHAR(50);
	DEFINE cEmpresa 	  CHAR(3);
	DEFINE cSucursal      CHAR (4);
	DEFINE iTotalEnviadas INTEGER;
	DEFINE iImpresas      INTEGER;
	DEFINE dImpresasPor   DECIMAL(5,2);
	DEFINE iNoImpresas    INTEGER;
	DEFINE dNoImpresasPor DECIMAL(5,2);
	DEFINE iStatusA       INTEGER;
	DEFINE dStatusAPor    DECIMAL(5,2);
	DEFINE iStatusR       INTEGER;
	DEFINE dStatusRPor    DECIMAL(5,2);
	DEFINE iStatusD       INTEGER;
	DEFINE dStatusDPor    DECIMAL(5,2);
	DEFINE iStatusS       INTEGER;
	DEFINE dStatusSPor    DECIMAL(5,2);
	DEFINE iBancoppel     INTEGER;
	DEFINE iCoppel        INTEGER;
	DEFINE iMixta         INTEGER;
	DEFINE iTotal         INTEGER;
	DEFINE iNumRegistros  INTEGER;
	DEFINE iRecuperacion  INTEGER;
	
	LET cCodRet 		  = '00000';
	LET iSqlErr           = 0;
	LET cCodRetSp 		  = '';
	LET cDesCodRetSp 	  = '';
	LET cEmpresa 		  = '001';
	LET cSucursal         = '';
	LET iTotalEnviadas    = 0;
	LET iImpresas         = 0;
	LET dImpresasPor      = 0;
	LET iNoImpresas       = 0;
	LET dNoImpresasPor    = 0;
	LET iStatusA          = 0;
	LET dStatusAPor       = 0;
	LET iStatusR          = 0;
	LET dStatusRPor       = 0;
	LET iStatusD          = 0;
	LET dStatusDPor       = 0;
	LET iStatusS          = 0;
	LET dStatusSPor       = 0;
	LET iBancoppel        = 0;
	LET iCoppel           = 0;
	LET iMixta            = 0;
	LET iTotal            = 0;
	LET iNumRegistros     = 0;
	LET iRecuperacion	  = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallefacturacionos_totales.out';
		--TRACE ON;

		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_statusproceso_os WHERE usuario = pUsuario;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3; 
		INSERT INTO bdicnweb:"informix".sw_statusproceso_os(usuario,status,num_registros,error_proceso,error)
		VALUES(pUsuario,'I',0,'',TRIM(cCodRet)); 
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pTipoFecha IS NULL OR pTipoConsulta IS NULL THEN
			LET cCodRet = '00003';
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_facturacion_os WHERE usuario_insert = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
			EXECUTE PROCEDURE bdisolic:"informix".sp_consultarfacturacionos2(cEmpresa,pSucursal,pNumCte,pFechaInicio,pFechaFin,pTipoFecha,pTipoConsulta,0,0)
			INTO cCodRetSp, cSucursal, iTotalEnviadas, iImpresas, dImpresasPor, iNoImpresas, dNoImpresasPor, iStatusA, dStatusAPor, 
			iStatusR, dStatusRPor, iStatusD, dStatusDPor, iStatusS, dStatusSPor, iBancoppel, iCoppel, iMixta, iTotal
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_consultarfacturacionos2';
			ELIF cCodRetSp::INTEGER = 1 OR cCodRetSp::INTEGER = 4 THEN 
				LET cCodRet = '00044'; --EL TIPO DE BUSQUEDA ES INCORRECTO
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			ELIF cCodRetSp::INTEGER = 2 OR cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '00003';
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			ELIF cCodRetSp::INTEGER = 5 THEN 
				LET cCodRet = '00154'; --LA FECHA INICIAL ES MAYOR A LA FECHA FINAL
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			ELIF cCodRetSp::INTEGER = 6 THEN 
				LET cCodRet = '00017';
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			END IF;
				
			LET iRecuperacion = iRecuperacion + 1;
			INSERT INTO bdicnweb:"informix".sw_facturacion_os(sucursal,total_enviadas,impresas_n,impresas_p,no_impresas_n,no_impresas_p,
			statusA_n,statusA_p,statusR_n,statusR_p,statusD_n,statusD_p,statusS_n,statusS_p,bancoppel,coppel,mixta,total,usuario_insert)
			VALUES(cSucursal,iTotalEnviadas,iImpresas,dImpresasPor,iNoImpresas,dNoImpresasPor,iStatusA,dStatusAPor,iStatusR,dStatusRPor, 
			iStatusD,dStatusDPor,iStatusS,dStatusSPor,iBancoppel,iCoppel,iMixta,iTotal,pUsuario);
		END FOREACH;
		
		SELECT COUNT(*) 
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_facturacion_os 
		WHERE usuario_insert = pUsuario;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END IF;
		
		UPDATE bdicnweb:"informix".sw_statusproceso_os
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario = TRIM(pUsuario);  
		RETURN cCodRet, NVL(iNumRegistros,0);
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 20/09/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: FACTURACIÓN DE ÓRDENES DE SUPERVISIÓN',
'DESCRIPCION: Spl encargado de consultar el número total de facturaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catcalles_consecutivo(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		INTEGER AS secuencia;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iSecuencia INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iSecuencia=0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iSecuencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catcalles_consecutivo.out';
		--TRACE ON;
		
		IF pUsuario = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iSecuencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iSecuencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		INSERT INTO sw_cli_calles_consecutivo(us_insert,fecha_insert) VALUES(pUsuario, CURRENT);
		
		SELECT MAX(id_serial) INTO iSecuencia FROM sw_cli_calles_consecutivo;
		
		RETURN cCodRet, iSecuencia;
	
	END;
	
END PROCEDURE;