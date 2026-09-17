CREATE PROCEDURE "informix".sp_amconsultarazonsocial(pRazonSocial CHAR(60))
RETURNING CHAR(5)  AS CodRet,
		  CHAR(3) AS CODIGOEMPRESA,
          CHAR(9)  AS NumeroCliente,
		  CHAR(60) AS RazonSocial,
		  CHAR(13) AS RFC;

-- DECLARA VARIABLES		  
DEFINE cCodret CHAR(5);		-- Codigo de error
DEFINE iSqlErr INTEGER;		-- Codigo de error de informix

DEFINE cNumCte CHAR(9);		-- Numero de Cliente
DEFINE cRazon  CHAR(60);	-- Razon Social
DEFINE cRFC    CHAR(13);		-- RFC
DEFINE cCodigo CHAR(3);

-- INICIALIZA VARIABLES
LET cCodret = '00000';
LET iSqlErr = 0;

LET cNumCte = '';LET cRazon  = '';
LET cRFC    = '';
LET cCodigo = '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0  THEN
			LET cCodRet  = iSqlErr;
			RETURN cCodret, trim(cCodigo), TRIM(cNumCte), TRIM(cRazon), TRIM(cRFC);
		END IF;
	END EXCEPTION;
	
--	SET DEBUG FILE TO "/tmp/sp_AMConsultaRazonSocial.out";
--	TRACE ON;
	
	
	IF pRazonSocial = '' THEN	
		LET cCodRet = '00001';
		LET cRazon = 'ERROR AL NO INGRESAR UNA CADENA A CONSULTAR';
		
		RETURN cCodret, trim(cCodigo), TRIM(cNumCte), TRIM(cRazon), TRIM(cRFC);	
	ELSE
		LET pRazonSocial = UPPER(pRazonSocial);		
	
		FOREACH	
			  SELECT c.codigo, a.razon_social, a.numcte, a.rfc
			  INTO cCodigo, cRazon, cNumCte, cRFC
			  FROM BDINTEG:si_cliente a
			  JOIN BDINTEG:si_ctepm b ON (a.numcte =b.numcte)
			  JOIN sc_nominaempresas c ON (c.numcte =a.numcte) 			  
			  WHERE a.razon_social LIKE "%"||TRIM(pRazonSocial)||"%"
			 			 
			RETURN cCodret, trim(cCodigo), TRIM(cNumCte), TRIM(cRazon), TRIM(cRFC) WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Clemente Angulo Ballardo',
'MODIFICO:Abigail Vasavilbazo Cañedo',
'Descripcion: Consulta clientes morales',
'MODIFCACION: Se agrega join con la sc_nominaempresas ',
'Fecha: 06/04/2010',
'Version: 20101006.1320';

CREATE PROCEDURE "informix".sp_amgeneraarchivorespuesta(pCodEmpresa CHAR(3))
RETURNING   CHAR (5) AS CodigoRetorno,
			CHAR(80) AS MensajeEjecucion,
            CHAR (3) AS CodigoEmpresa,
			CHAR(20) AS FolioArchivo,
			CHAR (1) AS StatusArchivo;
			
DEFINE iSqlErr INTEGER;			-- ERROR DE INFORMIX
DEFINE cCodRet CHAR(5);			-- CODIGO DE ERROR

DEFINE cMensajeEjec 	CHAR(80);						-- MENSAJE DESCRIBIENDO LA EJECUCION DEL PROCEDIMIENTO
DEFINE cCodEmpresa  	CHAR(3);						-- CODIGO DE LA EMPRESA EXTERNA
DEFINE iFolioArch   	INTEGER;						-- FOLIO DEL ARCHIVO PROCESADO
DEFINE cstatus      	CHAR(1);						-- ESTATUS DEL ARCHIVO PROCESADO
DEFINE cHoraAplicado	DATETIME HOUR TO FRACTION (3); 	-- HORA DE APLICACIÃ? DEL ARCHIVO
DEFINE dmaxfecha		DATE;							-- MAXIMA FECHA DE APLICADO DE LOS ARCHIVOS DE LA EMPRESA


LET iSqlErr     = 0;
LET cCodRet     = '00000';

LET cMensajeEjec    = 'PROCESO EJECUTADO EXITOSAMENTE';
LET cCodEmpresa 	= '';
LET iFolioArch  	=  0;
LET cstatus     	= '';
LET cHoraAplicado   = '';
LET dmaxfecha   	= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			LET cMensajeEjec = 'OCURRIO UN ERROR EN LA EJECUCION DEL PROCEDIMIENTO; VERIFIQUE';
			RETURN cCodRet, cMensajeEjec, cCodEmpresa, iFolioArch, cstatus;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/hass/sp_AMGeneraArchivoRespuesta.out";
	--TRACE ON;
	
	IF pCodEmpresa = '' THEN
		LET cCodRet = '00001';
		LET cMensajeEjec = 'ERROR AL NO INGRESAR EL CODIGO DE LA EMPRESA CLIENTE';
		RETURN cCodRet, TRIM(cMensajeEjec), TRIM(cCodEmpresa), iFolioArch, TRIM(cstatus);
	END IF;
	
	SELECT MAX(folio_archivo)
	  INTO iFolioArch
	  FROM bdicheq:sc_AMctrlaltasmasivas 
	 WHERE cod_empresa = pCodEmpresa
	   AND status IN (1, 2);
	   
	IF iFolioArch IS NULL  OR iFolioArch = '' THEN
		LET cCodRet = '00002';
		LET cMensajeEjec = 'NO EXISTEN ARCHIVOS PROCESADOS PARA EL CODIGO DE LA EMPRESA RECIBIDO';
		RETURN cCodRet, TRIM(cMensajeEjec), TRIM(cCodEmpresa), iFolioArch, TRIM(cstatus);
	END IF;	   
	
	SELECT cod_empresa, status
	  INTO cCodEmpresa, cstatus
	  FROM bdicheq:sc_AMctrlaltasmasivas
	 WHERE cod_empresa = pCodEmpresa
	   AND folio_archivo = iFolioArch;
	
	RETURN cCodRet, TRIM(cMensajeEjec), TRIM(cCodEmpresa), iFolioArch, TRIM(cstatus);
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Obtiene los parametros para enviar a los procedimientos que generan los archivos de respuesta',
'AUTOR: Clemente Angulo Ballardo',
'FECHA: 16 de Abril de 2010',
'VERSION: 20100726.1056',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_amobtieneempresasclientenomina(pNumcte CHAR(9))
RETURNING CHAR(5)  AS CodRet,
		  CHAR(3)  AS CodEmpresa,
		  CHAR(50) AS NomEmpresa,
		  CHAR(9)  AS NumEmpresaCliente,
		  CHAR(55) AS CodNomEmpresa;

-- DECLARA VARIABLES
DEFINE cCodRet CHAR(5);		-- Codigo de error
DEFINE iSqlErr INTEGER;		-- Codigo de error de informix

DEFINE cCodEmp CHAR(3);		-- Codigo de la empresa
DEFINE cNumcte CHAR(9);		-- Numero de cliente de la empresa
DEFINE cNomEmp CHAR(50);	-- Nombre de la empresa
DEFINE cUnion  CHAR(55);	-- Concatenacion del codigo y el nombre de la empresa

--INICIALIZACION VARIABLES
LET cCodRet = '00000';
LET iSqlErr	= 0;

LET cCodEmp = '';
LET cNumcte = '';
LET cNomEmp = '';
LET cUnion  = '';

BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0  THEN
			LET cCodRet  = iSqlErr;
			RETURN cCodret, cCodEmp, cNomEmp, cNumcte, cUnion;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_AMObtieneEmpresasClienteNomina.out";
	--TRACE ON;
	
	
	IF pNumcte = '' THEN	
		FOREACH	
			SELECT codigo, numcte, nombre
			  INTO cCodEmp, cNumcte, cNomEmp
			  FROM bdicheq:sc_nominaempresas
			 WHERE codigo > '000'
               AND tipo_empresa = '3'
		  ORDER BY codigo ASC
			 				
			LET cUnion = TRIM(cCodEmp ||' '|| cNomEmp);
				
			RETURN cCodret, TRIM(cCodEmp), TRIM(cNomEmp), TRIM(cNumcte), TRIM(cUnion) WITH RESUME;
		END FOREACH
	ELSE	
		SELECT codigo, numcte, nombre
		  INTO cCodEmp, cNumcte, cNomEmp
		  FROM bdicheq:sc_nominaempresas
		 WHERE codigo > '000'
           AND numcte = pNumcte
		   AND tipo_empresa = '3';
		
		IF cCodEmp IS NULL OR cNumcte IS NULL THEN
			LET cCodret = '00001';
			LET cUnion  = 'EL NUMERO DE CLIENTE NO EXISTE DADO DE ALTA COMO CLIENTE NOMINA';
			RETURN cCodret, TRIM(cCodEmp), TRIM(cNomEmp), TRIM(cNumcte), TRIM(cUnion);
		END IF;
			
		LET cUnion = TRIM(cCodEmp ||' '|| cNomEmp);
			
		RETURN cCodret, TRIM(cCodEmp), TRIM(cNomEmp), TRIM(cNumcte), TRIM(cUnion);
	
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Clemente Angulo Ballardo',
'Descripcion: Obtiene las empresas dadas de alta como clientes con el producto de nomina',
'Fecha: 06/04/2010',
'Version: 20100406.1200';

CREATE PROCEDURE "informix".sp_amrecibearchivo
(	pCodEmpresa 		CHAR(10),
	pNumEmpleado	 	CHAR(10), 
	pFolio			  	INTEGER, 
	pPrimer_Nombre 		CHAR(30), 
	pSegundo_Nombre		CHAR(30), 
	pApellPaterno 		CHAR(30),
	pApellMaterno 		CHAR(30), 
	pFechaNac 			CHAR(10), 
	pRfc 				CHAR(13), 
	pSexo 				CHAR(1), 
	pEstadoCivil 		CHAR(1), 
	pNacionalidad	 	CHAR(3), 
	pIdentificacion 	CHAR(1),
	pNumIdentificacion 	CHAR(30),
	pCtrNumReg			INTEGER,
	pCtrNombreArch		CHAR(20),
	pCtrProcedencia		CHAR(1)
)
	RETURNING 	CHAR(5)		AS RETORNO,
				CHAR(10)	AS FOLIO;

---- VARIABLES  GENERALES---
DEFINE cSqlerr			 	INTEGER;
DEFINE cCodret      	 	CHAR(5);
DEFINE cNombreArchivo    	CHAR(23);
DEFINE vsSQL    			CHAR(100);
Define cSQL 				CHAR(250);
Define cFolio 				CHAR(10);
Define dFechaHoy			DATE;


LET cSqlerr					= 0;
LET cCodret        			= '00000';
LET cNombreArchivo 			= '';
LET vsSQL   				= '';
LET cSQL 					= '';
LET cFolio 					= '';
LET dFechaHoy				= '';


--SET debug FILE TO "/tmp/Antonio/sp_AMRecibeArchivo.out";
--Trace ON;

BEGIN
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;
            RETURN cCodret,cFolio;
        END IF;
	END EXCEPTION;
    IF	pFolio = 0 THEN
		SELECT (MAX(NVL(folio_archivo,0))+ 1) 
		INTO cFolio
		FROM bdicheq:sc_amctrlaltasmasivas 
		WHERE cod_empresa = pCodEmpresa;
			IF cFolio IS NULL OR cFolio = '' THEN
				LET cFolio = 1;
			ELSE
				LET cFolio = cFolio;
			END IF;
		
		SELECT fecha_hoy INTO dFechaHoy FROM bdicheq:sc_fechas WHERE empresa = '001';
		
		INSERT INTO bdicheq:sc_amctrlaltasmasivas 
		(cod_empresa,fecha_genera,hora_genera,folio_archivo,nom_archivo,total_registros,fecha_aplicado,hora_aplicado,status,procedencia)
		VALUES 
		(pCodEmpresa,dFechaHoy,CURRENT HOUR TO SECOND, cFolio,pCtrNombreArch,pCtrNumReg,'','',4,pCtrProcedencia);
		
		DELETE FROM sc_amaltasmasivastemp WHERE cod_empresa = pCodEmpresa;
	ELSE
		LET cFolio = pFolio;		
	END IF;	
    --Se Inserta el registro en la tabla sc_altamasivasTemp
    INSERT INTO bdicheq:sc_AMaltasmasivasTemp 
	(cod_empresa, num_empleado,folio_archivo,primer_nombre,segundo_nombre,apell_pat,apell_mat,
	fecha_nac,Rfc,sexo,estadoCivil,nacionalidad,identificacion,num_identificacion)
    VALUES(pCodEmpresa,pNumEmpleado,cFolio,pPrimer_Nombre,pSegundo_Nombre, pApellPaterno, 
	pApellMaterno, pFechaNac,pRfc,pSexo, pEstadoCivil,pNacionalidad, pIdentificacion,
	pNumIdentificacion);
	
    RETURN cCodret,cFolio;
    
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa, Antonio Bastidas',
'DESCRIPCION: Procedimiento que registrará en el servidor en las tablas temporales la información del archivo. ',
'DESCRIPCION2: Graba información en la tabla de control. ',
'FECHA : 14 Abril de 2010',
'BD    : BDICHEQ',
'VERSION: 20100427.1739';

CREATE PROCEDURE "informix".sp_amregistrainformacion 
	(pEmpresa CHAR(3),pNumCteMoral CHAR(20), pEjecutivo CHAR(8),pNomArchivo CHAR(30))
RETURNING  CHAR(5),CHAR(100);

DEFINE iSqlErr				INTEGER;
DEFINE cCodRetOtroProceso	CHAR(6);
DEFINE cCodRet 				CHAR(5);
DEFINE cNumCliente			CHAR(20);
DEFINE cNumCuenta			CHAR(20);
DEFINE cNombreCompleto		CHAR(120);
DEFINE cNumEmpleado			CHAR(30);
DEFINE cNumEmpresa			CHAR(3);
DEFINE cNombre1				CHAR(30);
DEFINE cNombre2				CHAR(30);
DEFINE cApellPatern			CHAR(30);
DEFINE cApellMatern			CHAR(30);
DEFINE cFecNac 				CHAR(10);
DEFINE cRFC 				CHAR(13);
DEFINE cRFCGenerado			CHAR(13);
DEFINE cSexo 				CHAR(1);
DEFINE cEdoCivil			CHAR(1);
DEFINE cNacionalidad		CHAR(3);
DEFINE cCodIdentity			CHAR(1);
DEFINE cNumIdentity			CHAR(30);
DEFINE cObservaciones		VARCHAR(255);
DEFINE cMensaje				VARCHAR(100);
DEFINE cTipoPersona			CHAR(2);
DEFINE cSucursal 			CHAR(4);
DEFINE iBegin				INTEGER;
DEFINE cTipoCliente			INTEGER;
DEFINE cNumFolio			INTEGER;
DEFINE cProducto 			CHAR(4);
DEFINE cCtaClaBe 			CHAR(20);
DEFINE dFechaHoy 			DATE;
DEFINE dFechaGenera			DATE;
DEFINE iFolioArchivo		INTEGER;
DEFINE iExiste				INTEGER;

LET cCodRetOtroProceso	= '00000';
LET cCodRet 			= '00000';
LET cNumCliente 		= '';
LET cNumCuenta 			= '';
LET cNombreCompleto		= '';
LET cNumEmpleado		= '';
LET cNumEmpresa			= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPatern		= '';
LET cApellMatern		= '';
LET cFecNac 			= '';
LET cRFC 				= '';
LET cRFCGenerado		= '';
LET cSexo 				= '';
LET cEdoCivil			= '';
LET cNacionalidad		= '';
LET cCodIdentity		= '';
LET cNumIdentity		= '';
LET cObservaciones		= '';
LET cMensaje			= '';
LET cTipoPersona		= '';
LET cSucursal			= '';
LET cCtaClaBe			= '';
LET iBegin				= 0;
LET cTipoCliente		= 0;
LET iSqlErr				= 0;
LET cNumFolio			= 0;
LET dFechaHoy			= '';
LET dFechaGenera		= '';
LET iFolioArchivo		= 0;
LET iExiste				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			LET cMensaje = 'OCURRIO UN ERROR NO CONTROLADO';
			IF iBegin = 1 THEN
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet,cMensaje;
		END IF;
	END EXCEPTION;
	
	--SET debug FILE TO "/tmp/Antonio/sp_AMRegistraInformacion.out";
	--Trace ON;
	
	SELECT fecha_hoy INTO dFechaHoy 
	FROM bdicheq:sc_fechas 
	WHERE empresa = '001';
	
	SELECT MAX(fecha_genera),MAX(folio_archivo) 
	INTO dFechaGenera,iFolioArchivo
	FROM bdicheq:sc_amctrlaltasmasivas 
	WHERE cod_empresa = pEmpresa
	AND status = '3'
	AND nom_archivo = CASE WHEN pNomArchivo = '' THEN nom_archivo  ELSE pNomArchivo END ;
	
	SELECT 1 INTO iExiste FROM bdicheq:sc_amctrlaltasmasivas 
	WHERE cod_empresa = pEmpresa 
	AND fecha_genera = dFechaGenera 
	AND folio_archivo = iFolioArchivo 
	AND status = '3'
	AND nom_archivo = CASE WHEN pNomArchivo = '' THEN nom_archivo  ELSE pNomArchivo END; 
	
	IF iExiste IS NULL OR iExiste = '' OR iExiste = 0 OR (SELECT COUNT(observaciones) FROM bdicheq:sc_AMaltasmasivasTemp WHERE cod_empresa = pEmpresa AND observaciones <> '') > 0 THEN
		LET cCodRet = '00001';
		LET cMensaje = 'NO EXISTEN REGISTROS A PROCESAR PARA LA EMPRESA';
		RETURN cCodRet,cMensaje;
	ELSE
		SELECT TRIM(acepta_producto) INTO cProducto FROM bdicheq:sc_nominaempresas WHERE codigo = pEmpresa;
		SELECT tpo_persona INTO cTipoPersona FROM bdinteg:si_tipper WHERE tpo_persona = '01';
		SELECT tipo_cliente INTO cTipoCliente FROM bdinteg:si_tipocte WHERE empresa = '001' AND tipo_cliente = 2;
		SELECT TRIM(valor) INTO cSucursal FROM bdicheq:sc_param WHERE codparam = 'AMSUCURSAL' AND empresa = '001';
			
			IF cTipoPersona IS NULL OR cTipoCliente IS NULL OR cSucursal IS NULL OR cProducto IS NULL THEN
				LET cCodRet = '00002';
				LET cMensaje = 'NO SE OBTUVIERON LOS PARÁMETROS NECESARIOS';
				RETURN cCodRet,cMensaje;
			END IF;
	END IF;
	
	FOREACH WITH HOLD
		-- Consulta las peticiones de aperturas de nómina para que sean procesadas.
		SELECT 	cod_empresa,num_empleado,folio_archivo,nombre1,nombre2,apell_paterno,apell_materno,
				fecha_nac,rfc,sexo,estadocivil,nacionalidad,identificacion,numidentificacion
		INTO	cNumEmpresa,cNumEmpleado,cNumFolio,cNombre1,cNombre2,cApellPatern,cApellMatern,cFecNac,cRFC,cSexo,
				cEdoCivil,cNacionalidad,cCodIdentity,cNumIdentity
		FROM bdicheq:sc_AMaltasmasivas
		WHERE cod_empresa = pEmpresa
		AND numcte = '000000000'
		AND cuenta = '00000000000'
		AND folio_archivo = iFolioArchivo
		
		BEGIN WORK;
		LET iBegin = 1;
		LET cFecNac = cFecNac;
			--LET cFecNac = SUBSTR(cFecNac,4,2)||'/'||SUBSTR(cFecNac,1,2)||'/'||SUBSTR(cFecNac,7,4);
			-- Calcula el RFC.
			CALL bdinteg:sp_calcularfc('001',cApellPatern,cApellMatern,cNombre1,
				 cNombre2,cFecNac) RETURNING cCodRetOtroProceso,cMensaje,cRFCGenerado;
			--Valida que proceso no falló.
			IF cCodRetOtroProceso <> 0 THEN
				LET cCodRet = '00003';
				LET cMensaje = 'FALLÓ EN EL PROCESO AL INTENTAR LA GENERACIÓN DE RFC ';
			END IF;
			--Valida que el generado sea igual al que recibimos por el cliente, si no es el caso se toma el que nosotros generamos.
			IF TRIM(cRFC) <> TRIM(cRFCGenerado) THEN
				LET cRFC = cRFCGenerado;
			END IF;
					
			--Apertura del cliente y dirección.
			CALL bdinteg:sp_altactenominaexterna
			(
			'001', 				--pempresa CHAR(3),
			'A',						--pfuncion CHAR(1),
			pNumCteMoral,				--pnumcte_moral CHAR(20),
			cSucursal,					--cSucursal CHAR(4),
			pEjecutivo,					--pEjecutivo CHAR(8),
			cTipoPersona,				--ptp_persona CHAR (2),
			cTipoCliente,				-- CHAR(1),
			cApellPatern,				--ppaterno CHAR (26),
			cApellMatern,				--pmaterno CHAR (26),
			cNombre1,					--pnombre1 CHAR (26),
			cNombre2,					--pnombre2 CHAR (26),
			'32',						--psector CHAR (2),
			'1',						--presidencia CHAR(1),
			'01',						--pdistrito CHAR(2),
			'00000000000',				--pactividad_esp char(11),
			cFecNac,					--pfecha_nac date, 
			cNacionalidad,			  	--pnacionalidad CHAR(3),
			cEdoCivil,					--EstadoCivil  CHAR(1),
			cCodIdentity,				--Codigo Identificacion CHAR(1),
			cNumIdentity,				--Numero Identificacion 
			'11',						--pprofesion CHAR (3),
			cSexo,						--psexo CHAR(1),
			'P'							--phabita_en CHAR(20))
			) 					
			RETURNING cCodRetOtroProceso, cMensaje, cNumCliente;
			
			IF cCodRetOtroProceso <> 0 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'SE PRODUJO UN ERROR AL INTENTAR GENERAR LA ALTA';
			END IF;
			
			CALL bdicheq:cuenta2
			(
			'001',							--pempresa CHAR(3),
			pEjecutivo,						--pusuario CHAR(8),
			cSucursal,						--psucursal      CHAR(4),
			cProducto,						--pproducto      CHAR(4),			
			cNumCliente,					--pnum_cte       CHAR(20),		
			'02',							--pnum_cot       CHAR(2),
			'1',							--pclase_cta     CHAR(1),
			'3',							--preg_firmas    CHAR(1),
			'001',							--ptipo_bca      CHAR(3),
			pEjecutivo,    					--pEjecutivo CHAR(8),
			'1',							--penvio_direcc  CHAR(1),
			'           ',					--pcuenta        CHAR(20),
			0,								--pdirecc_envio  SMALLINT,
			'',								--pcliente2      CHAR(20),
			'',								--pnombre        CHAR(50),
			'',								--pinstcap       CHAR(2),
			'',								--pcuentacap     CHAR(20),
			'',								--pinstint       CHAR(2),
			'',								--pcuentaint     CHAR(20),
			0,								--pplazo         SMALLINT,
			'N',							--pcobraISr      CHAR(1),
			'02',							--pproced_aperturacta 	CHAR(2),
			'02',							--pproced_mantenercta 	CHAR(2),
			'01',							--pmonto_mensual 	CHAR(2),
			'01',							--pdepositos_cantidad 	CHAR(2),
			'01',							--pdepositos_monto 	CHAR(2),
			'01',							--pretiros_cantidad 	CHAR(2),
			'01',							--pretiros_monto 	CHAR(2),
			'',								--pformaapert            CHAR(2),
			'0.00',							--pmtoapertura           MONEY(14,2),
			cNumEmpresa,					--pempemp                INTEGER,
			cNumEmpleado					--pnomina                INTEGER
			)RETURNING cCodRet,cNumCuenta,cCtaClaBe;
		
		IF cCodRet = 0 THEN
			UPDATE bdicheq:sc_AMaltasmasivas
			SET numcte = cNumCliente, cuenta = cNumCuenta
			WHERE cod_empresa = cNumEmpresa
			AND num_empleado = cNumEmpleado
			AND folio_archivo = cNumFolio;
			COMMIT WORK;
			LET iBegin = 0;
		ELSE
			ROLLBACK WORK;
			LET iBegin = 0;
			CONTINUE FOREACH;
		END IF;
	END FOREACH;
	
	IF cCodRet = 0 THEN
		UPDATE bdicheq:sc_amctrlaltasmasivas 
		SET status = '1',fecha_aplicado = dFechaHoy,hora_aplicado = CURRENT HOUR TO SECOND
		WHERE cod_empresa = cNumEmpresa
		AND fecha_genera = dFechaGenera
		AND folio_archivo = iFolioArchivo;
	END IF;
	RETURN cCodRet,cMensaje;


END
END PROCEDURE
Document
'DESCRIPCION: Registra las altas de cliente, dirección y apertura su cuenta para cada registro de la empresa', 
'AUTOR: Antonio Bastidas',
'FECHA: 14 de Abril de 2010',
'VERSION: 20100427.1316',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_amvalidaarchivocliente (pEmpresa CHAR(3))	
RETURNING  CHAR(5);
--RETURNING  CHAR(5),CHAR(2000);

DEFINE cCodRet 				CHAR(5);
DEFINE cEscritura 			CHAR(5);
DEFINE cObservacionesTOTAL	CHAR(32000);
DEFINE cObservaciones		VARCHAR(255);
DEFINE cObservaciones1		VARCHAR(255);
DEFINE iRetornoFunction		SMALLINT;
DEFINE iSqlErr				INTEGER;
DEFINE iIndicadorComas		INTEGER;
DEFINE iIndicadorComas2		INTEGER;
DEFINE iIndicadorComas3		INTEGER;
DEFINE iIndicadorComas4		INTEGER;
DEFINE iRetorno				INTEGER;
DEFINE iMotivoRechazos		INTEGER;
DEFINE iExiste				INTEGER;
DEFINE idROW				INT8;
DEFINE cNumEmpresa			CHAR(3);
DEFINE cNumEmpleado			CHAR(30);
DEFINE cNombre1				CHAR(30);
DEFINE cNombre2				CHAR(30);
DEFINE cApellPatern			CHAR(30);
DEFINE cApellMatern			CHAR(30);
DEFINE cFecNac 				CHAR(10);
DEFINE cFecNacCorta			CHAR(8);
DEFINE cRFC 				CHAR(13);
DEFINE cRFCCalculado		CHAR(13);
DEFINE cSexo 				CHAR(1);
DEFINE cEdoCivil			CHAR(1);
DEFINE cNacionalidad		CHAR(3);
DEFINE cTipoIdentificacion	CHAR(2);
DEFINE cNumidentificacion	CHAR(30);
DEFINE cAuxiliar			CHAR(20);
DEFINE cMensaje				CHAR(100);
DEFINE cProductosPermitidos	CHAR(50);
DEFINE dcEdadCliente		CHAR(6);
DEFINE cStatus				CHAR(1);
DEFINE dFechaGenera			DATE;
DEFINE iFolioArchivo		INTEGER;
DEFINE iRegistroDuplicado	INTEGER;
DEFINE iRegistroDuplicado1	INTEGER;
DEFINE iRegistroDuplicado2	INTEGER;
DEFINE iBanderaFechaOK		INTEGER;
DEFINE dFechaHoy			DATE;




LET cCodRet 			= '00002';
LET cEscritura 			= '';
LET cObservaciones		= '';
LET cObservaciones1		= '';
LET iSqlErr				= 0;
LET iIndicadorComas		= 0;
LET iIndicadorComas2	= 0;
LET iIndicadorComas3	= 0;
LET iIndicadorComas4	= 0;
LET iRetornoFunction	= 0;
LET iRetorno			= 0;
LET idROW				= 0;
LET iMotivoRechazos		= 0;
LET iExiste				= 0;
LET cNumEmpresa			= '';
LET cNumEmpleado		= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPatern		= '';
LET cApellMatern		= '';
LET cFecNac 			= '';
LET cFecNacCorta		= '';
LET cRFC 				= '';
LET cRFCCalculado		= '';
LET cSexo 				= '';
LET cEdoCivil			= '';
LET cNacionalidad		= '';
LET cTipoIdentificacion	= '';
LET cNumidentificacion	= '';
LET cAuxiliar			= '';
LET cMensaje			= '';
LET cProductosPermitidos= '';
LET dcEdadCliente		= '0.00';
LET cStatus				= '';
LET dFechaGenera		= '';
LET dFechaHoy			= '';
LET iFolioArchivo		= 0;
LET iRegistroDuplicado	= 0;
LET iRegistroDuplicado1	= 0;
LET iRegistroDuplicado2	= 0;
LET iBanderaFechaOK		= 1;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			--RETURN cCodRet,cObservaciones;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/Antonio/sp_AMValidaArchivoCliente.out";
    --TRACE ON;
	
	SELECT fecha_hoy INTO dFechaHoy
	FROM bdicheq:sc_fechas WHERE empresa = '001';
	
	SELECT MAX(fecha_genera),MAX(folio_archivo) 
	INTO dFechaGenera,iFolioArchivo
	FROM bdicheq:sc_amctrlaltasmasivas 
	WHERE cod_empresa = pEmpresa
	AND status = '4';
	
	SELECT 1 INTO iExiste FROM bdicheq:sc_amctrlaltasmasivas 
	WHERE cod_empresa = pEmpresa 
	AND fecha_genera = dFechaGenera 
	AND folio_archivo = iFolioArchivo 
	AND status = '4';
	
	IF iExiste IS NULL OR iExiste = '' OR iExiste = 0 THEN
		  LET cCodRet = '00002';
		  LET iExiste = 0;
		  RETURN cCodRet;
	END IF;		   
	
	LET iExiste = 0;
	
	FOREACH WITH HOLD
		SELECT {+INDEX(sc_AMaltasmasivasTemp idxamaltamasivastmp1)}	cod_empresa,num_empleado,primer_nombre,segundo_nombre,apell_pat,apell_mat,fecha_nac,rfc,sexo,
				estadocivil,nacionalidad,identificacion,num_identificacion,ROWID
		INTO	cNumEmpresa,cNumEmpleado,cNombre1,cNombre2,cApellPatern,cApellMatern,cFecNac,cRFC,cSexo,
				cEdoCivil,cNacionalidad,cTipoIdentificacion,cNumidentificacion,idROW
		FROM bdicheq:sc_AMaltasmasivasTemp
		WHERE cod_empresa = pEmpresa
            
        
		LET iIndicadorComas		= 0;
		LET iIndicadorComas2	= 0;
		LET iIndicadorComas3	= 0;
		LET iIndicadorComas4	= 0;
		LET iRegistroDuplicado  = 0;
		LET iRegistroDuplicado1 = 0;
		LET iRegistroDuplicado2 = 0;
		LET iBanderaFechaOK		= 1;
		
		-- *************************************************************************************************************
		-- ********************************* Validaciones que la informacion se obtenga completa. *************************************
		-- *************************************************************************************************************
			LET cObservaciones =  '';
		  IF cNumEmpresa = '' OR cNumEmpleado = '' OR cNombre1 = '' OR cApellPatern = '' OR cFecNac = '' OR cRFC = '' 
		  OR cSexo = '' OR cEdoCivil = '' OR cNacionalidad = '' OR cTipoIdentificacion = '' THEN
		  
			LET cObservaciones = 'DATO VACÍO- ESTE DATO ES REQUERIDO:';
			
			  IF cNumEmpresa = '' THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', EMPRESA';
				ELSE
					LET cObservaciones = TRIM(cObservaciones) ||' EMPRESA';
				END IF;
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
			  
			  IF cNumEmpleado = '' THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', EMPLEADO';
				ELSE
					LET cObservaciones = TRIM(cObservaciones) ||' EMPLEADO';
				END IF;
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
			  
			  IF cNombre1 = '' THEN 
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', 1ER NOMBRE';
				ELSE
					LET cObservaciones = TRIM(cObservaciones) ||' 1ER NOMBRE';
				END IF;
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
			  
			  IF  cApellPatern = '' THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', 1ER APELLIDO';
				ELSE 
					LET cObservaciones = TRIM(cObservaciones) ||' 1ER APELLIDO';
				END IF;
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
			  
			  IF cFecNac = '' THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', FECHA';
				ELSE 
					LET cObservaciones = TRIM(cObservaciones) ||' FECHA';
				END IF;
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
			  
			  IF cRFC = '' THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', RFC';
				ELSE
					LET cObservaciones = TRIM(cObservaciones) ||' RFC';
				END IF;
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
			  
			  IF cSexo = '' THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', SEXO';
				ELSE
					LET cObservaciones = TRIM(cObservaciones) ||' SEXO';
				END IF;
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
			  
			  IF cEdoCivil = '' THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) || ', EDO CIVIL';
				ELSE
					LET cObservaciones = TRIM(cObservaciones) || ' EDO CIVIL';
				END IF;	
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
			  
			  IF cNacionalidad = '' THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', NACIONALIDAD';
				ELSE 
					LET cObservaciones = TRIM(cObservaciones) ||' NACIONALIDAD';
				END IF;
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
			  
			  IF cTipoIdentificacion = '' THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', IDENTIFICACION';
				ELSE 
					LET cObservaciones = TRIM(cObservaciones) ||' IDENTIFICACION';
				END IF;
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
			  
			  IF cNumidentificacion = '' THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', NUMERO IDENTIFICACION';
				ELSE 
					LET cObservaciones = TRIM(cObservaciones) ||' NUMERO IDENTIFICACION';
				END IF;
				LET iIndicadorComas = iIndicadorComas + 1;
			  END IF;
		  END IF;
		  
		  
		-- *************************************************************************************************************
		-- ******************************FIN Validaciones que la informacion se obtenga completa. *************************************
		-- *************************************************************************************************************
		-- *************************************************************************************************************
		-- *************************************************************************************************************
		-- ******************************  Valida que los campos de tipo enteros sean números los que se reciben****************************
		-- *************************************************************************************************************
			IF bdiprog:isnumeric(cNumEmpleado) = 1 THEN 
				IF cNumEmpleado::INTEGER <= 0 THEN
					LET iExiste = 1;
				ELSE
					LET iExiste = 0;
				END IF;
			END IF;
			
				 
			IF bdiprog:isnumeric(cNumEmpresa) = 0 OR bdiprog:isnumeric(cNumEmpleado) = 0 OR iExiste = 1 OR bdiprog:isnumeric(cNacionalidad) = 0 THEN
				IF iIndicadorComas > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', DATO INVALIDO- SOLO NÚMEROS:';
				ELSE
					LET cObservaciones = TRIM(cObservaciones) ||' DATO INVALIDO- SOLO NÚMEROS:';
				END IF;
				
				 
				IF bdiprog:isnumeric(cNumEmpresa) = 0 THEN 
					LET cObservaciones = TRIM(cObservaciones) ||' EMPRESA';
					LET iIndicadorComas2 = iIndicadorComas2 + 1;
				END IF;
				
				
				 
				IF bdiprog:isnumeric(cNumEmpleado) = 0 THEN 
					IF iIndicadorComas2 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', EMPLEADO';
					ELSE
						LET cObservaciones = TRIM(cObservaciones) ||' EMPLEADO';
					END IF;
					LET iIndicadorComas2 = iIndicadorComas2 + 1;
				END IF;
								
				IF iExiste = 1 THEN
					IF iIndicadorComas2 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', NUMERO DE EMPLEADO MENOR DE 1';
					ELSE
						LET cObservaciones = TRIM(cObservaciones) ||' NUMERO DE EMPLEADO MENOR DE 1';
					END IF;
					LET iIndicadorComas2 = iIndicadorComas2 + 1;
				END IF;  
				
				 
				IF bdiprog:isnumeric(cNacionalidad) = 0 THEN 
					IF iIndicadorComas2 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', NACIONALIDAD';
					ELSE
						LET cObservaciones = TRIM(cObservaciones) ||' NACIONALIDAD';
					END IF;
					LET iIndicadorComas2 = iIndicadorComas2 + 1;
				END IF;  
			END IF;
			
		-- *************************************************************************************************************
		-- *************************** FIN Valida que los campos de tipo enteros sean números los que se reciben****************************
		-- *************************************************************************************************************
		-- *************************************************************************************************************
		-- *************************************Valida que la información sea de su tipo*********************************************
		-- *************************************************************************************************************

			LET cFecNacCorta = SUBSTR(cFecNac,1,4) || SUBSTR (cFecNac,6,2) || SUBSTR (cFecNac,9,2);
			LET cAuxiliar = SUBSTR(cFecNac,3,1)||SUBSTR(cFecNac,6,1);
			
			LET iExiste = 0;
			CALL bdicheq:ischar(SUBSTR(TRIM(cRFC),1,4)) RETURNING iRetornoFunction,cEscritura;
				IF iRetornoFunction <> 0 OR SUBSTR(cEscritura,5) <> 0 THEN
					LET iExiste = iExiste+1;			
				END IF;
				
			CALL bdicheq:ischar(SUBSTR(TRIM(cRFC),7,2)) RETURNING iRetornoFunction,cEscritura;
				IF iRetornoFunction = 1 AND SUBSTR(cEscritura,5) = 1 THEN
					IF (SUBSTR(TRIM(cRFC),7,2)) = 00  OR (SUBSTR(TRIM(cRFC),7,2)) > 12 THEN
						LET iExiste = iExiste+1;								
					END IF;
				ELSE
					LET iExiste = iExiste+1;				
				END IF;
			
			
			CALL bdicheq:ischar(SUBSTR(TRIM(cRFC),9,2)) RETURNING iRetornoFunction,cEscritura;
				IF iRetornoFunction = 1 AND SUBSTR(cEscritura,5) = 1 THEN
					IF (SUBSTR(TRIM(cRFC),9,2)) = 00  OR (SUBSTR(TRIM(cRFC),9,2)) > 31 THEN
						LET iExiste = iExiste+1;					
					END IF;
				ELSE
					LET iExiste = iExiste+1;									
				END IF;
				
				IF (SUBSTR(TRIM(cRFC),11,3)) = '   ' OR (SUBSTR(TRIM(cRFC),11,3)) = ''  THEN
					LET iExiste = iExiste+1;
				END IF;	
			
			CALL bdicheq:ischar(TRIM(cNombre1)||TRIM(cNombre2)||TRIM(cApellPatern)||TRIM(cApellMatern)||TRIM(cSexo)||TRIM(cEdoCivil)) RETURNING iRetornoFunction,cEscritura;
			IF iRetornoFunction <> 0 OR (SUBSTR(cEscritura,5) <> 0 AND SUBSTR(cEscritura,5) <> 7)OR (cSexo <> 'M' AND cSexo <> 'F') 
				OR (cEdoCivil <> 'S' AND cEdoCivil <> 'C') OR (bdiprog:isnumeric(cFecNacCorta) = 0) OR (SUBSTR(TRIM(cFecNacCorta),5,2)) = 00  
				OR (SUBSTR(TRIM(cFecNacCorta),5,2)) > 12 OR (SUBSTR(TRIM(cFecNacCorta),7,2)) = 00 OR (SUBSTR(TRIM(cFecNacCorta),7,2)) > 31
				OR iExiste > 0 OR LENGTH(TRIM(cNombre1)) > 27 OR LENGTH(TRIM(cNombre2)) > 27 OR LENGTH(TRIM(cApellPatern)) > 27
				OR LENGTH(TRIM(cApellMatern)) > 27 THEN	
				IF iIndicadorComas > 1 OR iIndicadorComas2 > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', FORMATO INVALIDO:';
				ELSE
					LET cObservaciones = TRIM(cObservaciones) ||' FORMATO INVALIDO:';
				END IF;
					LET iIndicadorComas2 = iIndicadorComas2 + 1;
				
				CALL bdicheq:ischar(TRIM(cNombre1)) RETURNING iRetornoFunction,cEscritura;
				IF iRetornoFunction <> 0 OR (SUBSTR(cEscritura,5) <> 0 AND SUBSTR(cEscritura,5) <> 7) THEN
						LET cObservaciones = TRIM(cObservaciones) ||' NOMBRE1';
					LET iIndicadorComas3 = iIndicadorComas3 + 1;
				END IF;
				
				IF cNombre2 <> "" THEN
					CALL bdicheq:ischar(cNombre2) RETURNING iRetornoFunction,cEscritura;
					IF iRetornoFunction <> 0 OR (SUBSTR(cEscritura,5) <> 0 AND SUBSTR(cEscritura,5) <> 7) THEN
						IF iIndicadorComas3 > 0 THEN
							LET cObservaciones = TRIM(cObservaciones) ||', NOMBRE2';
						ELSE 
							LET cObservaciones = TRIM(cObservaciones) ||' NOMBRE2';
						END IF;
						LET iIndicadorComas3 = iIndicadorComas3 + 1;
					END IF;
				END IF;
				
				CALL bdicheq:ischar(cApellPatern) RETURNING iRetornoFunction,cEscritura;
				IF iRetornoFunction <> 0 OR (SUBSTR(cEscritura,5) <> 0 AND SUBSTR(cEscritura,5) <> 7) THEN
					IF iIndicadorComas3 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', APELLIDO PATERNO';
					ELSE 
						LET cObservaciones = TRIM(cObservaciones) ||' APELLIDO PATERNO';
					END IF;
					LET iIndicadorComas3 = iIndicadorComas3 + 1;
				END IF;
				
				IF cApellMatern <> "" THEN
					CALL bdicheq:ischar(cApellMatern) RETURNING iRetornoFunction,cEscritura;
					IF iRetornoFunction <> 0 OR (SUBSTR(cEscritura,5) <> 0 AND SUBSTR(cEscritura,5) <> 7) THEN
						IF iIndicadorComas3 > 0 THEN
							LET cObservaciones = TRIM(cObservaciones) ||', APELLIDO MATERNO';
						ELSE 
							LET cObservaciones = TRIM(cObservaciones) ||' APELLIDO MATERNO';
						END IF;
						LET iIndicadorComas3 = iIndicadorComas3 + 1;
					END IF;
				END IF;
						
				IF (cSexo <> 'M' AND cSexo <> 'F') THEN
					IF iIndicadorComas3 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', SEXO SOLO M O F';
					ELSE 
						LET cObservaciones = TRIM(cObservaciones) ||' SEXO SOLO M O F';
					END IF;
					LET iIndicadorComas3 = iIndicadorComas3 + 1;
				END IF;
				
				IF (cEdoCivil <> 'S' AND cEdoCivil <> 'C') THEN 
						IF iIndicadorComas3 > 0 THEN
							LET cObservaciones = TRIM(cObservaciones) ||', ESTADO CIVIL SOLO S O C';
						ELSE 
							LET cObservaciones = TRIM(cObservaciones) ||' ESTADO CIVIL SOLO S O C';
						END IF;
						LET iIndicadorComas3 = iIndicadorComas3 + 1;
				END IF;
				
				 
				IF bdiprog:isnumeric(cFecNacCorta) = 0 OR(SUBSTR(TRIM(cFecNacCorta),5,2)) = 00 OR 
				   (SUBSTR(TRIM(cFecNacCorta),5,2)) > 12 OR (SUBSTR(TRIM(cFecNacCorta),7,2)) = 00 
					OR (SUBSTR(TRIM(cFecNacCorta),7,2)) > 31  THEN 
					LET iBanderaFechaOK = 0;
					IF iIndicadorComas3 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', FECHA';
					ELSE
						LET cObservaciones = TRIM(cObservaciones) ||' FECHA';
					END IF;
					LET iIndicadorComas3 = iIndicadorComas3 + 1;
				END IF;
				
				
					IF iExiste > 0 THEN
						IF iIndicadorComas3 > 0 THEN
							LET cObservaciones = TRIM(cObservaciones) ||', RFC';
						ELSE 
							LET cObservaciones = TRIM(cObservaciones) ||' RFC';
						END IF;
						LET iIndicadorComas3 = iIndicadorComas3 + 1;				
					END IF;
					
				IF LENGTH(TRIM(cNombre1)) > 27 THEN 
					IF iIndicadorComas3 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', NOMBRE1 LONGITUD SUPERADA';
					ELSE 
						LET cObservaciones = TRIM(cObservaciones) ||' NOMBRE1 LONGITUD SUPERADA';
					END IF;
					LET iIndicadorComas3 = iIndicadorComas3 + 1;	
				END IF;
				
				IF LENGTH(TRIM(cNombre2)) > 27 THEN 
					IF iIndicadorComas3 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', NOMBRE2 LONGITUD SUPERADA';
					ELSE 
						LET cObservaciones = TRIM(cObservaciones) ||' NOMBRE2 LONGITUD SUPERADA';
					END IF;
					LET iIndicadorComas3 = iIndicadorComas3 + 1;	
				END IF;
				
				IF LENGTH(TRIM(cNombre2)) > 27 THEN 
					IF iIndicadorComas3 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', NOMBRE2 LONGITUD SUPERADA';
					ELSE 
						LET cObservaciones = TRIM(cObservaciones) ||' NOMBRE2 LONGITUD SUPERADA';
					END IF;
					LET iIndicadorComas3 = iIndicadorComas3 + 1;	
				END IF;
				
				IF LENGTH(TRIM(cApellPatern)) > 27 THEN 
					IF iIndicadorComas3 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', APELLIDO PATERNO LONGITUD SUPERADA';
					ELSE 
						LET cObservaciones = TRIM(cObservaciones) ||' APELLIDO PATERNO LONGITUD SUPERADA';
					END IF;
					LET iIndicadorComas3 = iIndicadorComas3 + 1;	
				END IF;
				
				IF LENGTH(TRIM(cApellMatern)) > 27 THEN 
					IF iIndicadorComas3 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', APELLIDO MATERNO LONGITUD SUPERADA';
					ELSE 
						LET cObservaciones = TRIM(cObservaciones) ||' APELLIDO MATERNO LONGITUD SUPERADA';
					END IF;
					LET iIndicadorComas3 = iIndicadorComas3 + 1;	
				END IF;
			END IF;
			

		-- ************************************************************************************************************
		-- **********************************FIN Valida que la información sea de su tipo******************************************
		-- ************************************************************************************************************
		-- *************************************************************************************************************
		-- *************************************Valida que la informacion exista en tablas******************************************
		-- *************************************************************************************************************
			
			CALL bdicheq:ischar(cTipoIdentificacion) RETURNING iRetornoFunction,cEscritura;
			LET cFecNac = cFecNac;
			LET cFecNac = SUBSTR(cFecNac,6,2)||'-'||SUBSTR(cFecNac,9,2)||'-'||SUBSTR(cFecNac,1,4);
			
			IF iBanderaFechaOK = 1 THEN
				CALL bdinteg:sp_calcularfc('001',cApellPatern,cApellMatern,cNombre1,cNombre2,cFecNac) RETURNING iRetornoFunction,cMensaje,cRFCCalculado;
			END IF;
			LET cFecNac = SUBSTR(cFecNac,7,4)||'-'||SUBSTR(cFecNac,1,2)||'-'||SUBSTR(cFecNac,4,2);
			
			-- Obtiene los productos
			SELECT 1,acepta_producto 
			INTO iExiste,cProductosPermitidos 
			FROM bdicheq:sc_nominaempresas 
			WHERE codigo = cNumEmpresa;
			
			IF iBanderaFechaOK = 1 THEN
				--Calculo de la edad entre la fecha del sistema y la de nacimiento.
				SELECT  ((DAY(Fecha_hoy)/31) + (MONTH(Fecha_hoy)/12) + (YEAR(Fecha_hoy))- 
						((SUBSTR(cFecNac,9,2)/31) + (SUBSTR(cFecNac,6,2)/12) + (SUBSTR(cFecNac,1,4)))) 
				INTO dcEdadCliente
				FROM bdicheq:sc_fechas WHERE empresa = '001';
			END IF;
				
			SELECT COUNT(*) - 1 INTO iRegistroDuplicado1
			FROM  bdicheq:sc_AMaltasmasivasTemp 
			WHERE cod_empresa = cNumEmpresa
			AND num_empleado = cNumEmpleado
			AND folio_archivo = iFolioArchivo;
			
			IF iBanderaFechaOK = 1 THEN
				SELECT COUNT(*) - 1 INTO iRegistroDuplicado2
				FROM  bdicheq:sc_AMaltasmasivasTemp 
				WHERE cod_empresa = cNumEmpresa
				AND primer_nombre = cNombre1
				AND segundo_nombre = cNombre2
				AND apell_pat = cApellPatern 
				AND apell_Mat = cApellMatern
				AND fecha_nac = SUBSTR(cFecNac,1,4)||'/'||SUBSTR(cFecNac,6,2)||'/'||SUBSTR(cFecNac,9,2);
			END IF;
				
			LET iRegistroDuplicado = iRegistroDuplicado1 + iRegistroDuplicado2;
			
			-- Consulta si el cliente se encuentra con la edad correspondiente para dicho producto.	
			SELECT {+INDEX(sc_producto idxscproductopba)} COUNT(*) INTO iExiste
			FROM bdicheq:sc_producto 
			WHERE producto LIKE TRIM(cProductosPermitidos)
			AND dcEdadCliente::INTEGER BETWEEN edad_minima AND edad_maxima;
			
			IF (NOT EXISTS (SELECT * FROM bdicheq:sc_nominaempresas WHERE codigo = cNumEmpresa) OR iRetornoFunction <> 0) OR 
				NOT EXISTS(SELECT 1 FROM  bdinteg:si_tipoidentif WHERE codidentif = cTipoIdentificacion) OR iRegistroDuplicado <> 0
				OR NOT EXISTS (SELECT 1 FROM  bdinteg:si_nacion WHERE nacion = cNacionalidad) OR (LENGTH(TRIM(cRFC)) < 13) OR 
				(SELECT COUNT(rfc) FROM bdinteg:si_cliente WHERE empresa = '001' AND numcte = numcte AND rfc = cRFCCalculado) > 0 
				OR iExiste = 0 OR cProductosPermitidos IS NULL OR TRIM(cProductosPermitidos) = '' THEN
				IF iIndicadorComas > 0 OR iIndicadorComas2 > 0 OR iIndicadorComas3 > 0 THEN
					LET cObservaciones = TRIM(cObservaciones) ||', DATO INVALIDO:';
				ELSE
					LET cObservaciones = TRIM(cObservaciones) ||' DATO INVALIDO:';
				END IF;
				LET iIndicadorComas3 = iIndicadorComas3 + 1;
				
				IF iRetornoFunction <> 0 OR SUBSTR(cEscritura,5) <> 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||' CALCULO RFC';
						LET iIndicadorComas4 = iIndicadorComas4 + 1;
					END IF;

				CALL bdicheq:ischar(cTipoIdentificacion) RETURNING iRetornoFunction,cEscritura;
					IF iRetornoFunction <> 0 OR SUBSTR(cEscritura,5) <> 0 OR 
					NOT EXISTS(SELECT 1 FROM  bdinteg:si_tipoidentif WHERE codidentif = cTipoIdentificacion) THEN
						LET cObservaciones = TRIM(cObservaciones) ||' IDENTIFICACION';
						LET iIndicadorComas4 = iIndicadorComas4 + 1;
					END IF;
					
				IF cProductosPermitidos IS NULL OR TRIM(cProductosPermitidos) = '' THEN
					IF iIndicadorComas4 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', EMPRESA';
					ELSE 
						LET cObservaciones = TRIM(cObservaciones) ||' EMPRESA';
					END IF;
					LET iIndicadorComas4 = iIndicadorComas4 + 1;
				END IF;
				
				IF NOT EXISTS (SELECT 1 FROM  bdinteg:si_nacion WHERE nacion = cNacionalidad) THEN
					IF iIndicadorComas4 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', NACIONALIDAD';
					ELSE 
						LET cObservaciones = TRIM(cObservaciones) ||' NACIONALIDAD';
					END IF;
					LET iIndicadorComas4 = iIndicadorComas4 + 1;
				END IF;
				IF (LENGTH(TRIM(cRFC)) < 13) THEN
					IF iIndicadorComas4 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', RFC DATO INCOMPLETO';
					ELSE
						LET cObservaciones = TRIM(cObservaciones) ||' RFC DATO INCOMPLETO';
					END IF;
					LET iIndicadorComas4 = iIndicadorComas4 + 1;
				END IF;
				
				IF (SELECT COUNT(rfc) FROM bdinteg:si_cliente WHERE empresa = '001' AND numcte = numcte AND rfc = cRFCCalculado) > 0 THEN
				   IF iIndicadorComas4 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', CLIENTE YA EXISTENTE';
					ELSE
						LET cObservaciones = TRIM(cObservaciones) ||' CLIENTE YA EXISTENTE';
					END IF;
					LET iIndicadorComas4 = iIndicadorComas4 + 1;
				END IF;
				
				IF iRegistroDuplicado <> 0  THEN
					IF iIndicadorComas4 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', REGISTRO DUPLICADO';
					ELSE
						LET cObservaciones = TRIM(cObservaciones) ||' REGISTRO DUPLICADO';
					END IF;
					LET iIndicadorComas4 = iIndicadorComas4 + 1;
				END IF;
				
				IF iExiste = 0  THEN
					IF iIndicadorComas4 > 0 THEN
						LET cObservaciones = TRIM(cObservaciones) ||', EDAD';
					ELSE
						LET cObservaciones = TRIM(cObservaciones) ||' EDAD';
					END IF;
					LET iIndicadorComas4 = iIndicadorComas4 + 1;
				END IF;	
			END IF;
			
			
			
		-- *************************************************************************************************************
		-- **********************************FIN Valida que la informacion exista en tablas******************************************
		-- *************************************************************************************************************
		LET iIndicadorComas = iIndicadorComas;
		LET iIndicadorComas2 = iIndicadorComas2;
		LET iIndicadorComas3 = iIndicadorComas3 ;
		LET iIndicadorComas4 = iIndicadorComas4;
		LET iMotivoRechazos = iMotivoRechazos + iIndicadorComas + iIndicadorComas2 + iIndicadorComas3 + iIndicadorComas4;
		
			IF iMotivoRechazos <= 0  THEN
				LET cCodRet = '00000';
				LET cStatus = '3';
			ELSE
				LET cCodRet = '00001';
				LET cStatus = '2';
			END IF;
				UPDATE bdicheq:sc_AMaltasmasivasTemp 
				SET observaciones = cObservaciones 
				WHERE ROWID = idROW;
				
			
			--RETURN cCodRet, cObservaciones WITH RESUME;
	END FOREACH;
	
	IF cStatus = '3' AND cCodRet = '00000' THEN
		INSERT INTO sc_amaltasmasivas 
		(cod_empresa,
		num_empleado,
		folio_archivo,
		nombre1,
		nombre2,
		apell_paterno,
		apell_materno,
		numcte,
		cuenta,
		fecha_nac,
		rfc,
		sexo,
		estadocivil,
		nacionalidad,
		identificacion,
		numidentificacion)
		SELECT 	
		cod_empresa,
		num_empleado,
		folio_archivo,
		primer_nombre,
		segundo_nombre,
		apell_pat,
		apell_mat,
		'000000000',
		'00000000000',
		SUBSTR(fecha_nac,6,2)||'/'||SUBSTR(fecha_nac,9,2)||'/'||SUBSTR(fecha_nac,1,4),
		rfc,
		sexo,
		estadocivil,
		nacionalidad,
		identificacion,
		num_identificacion
		FROM sc_amaltasmasivastemp 
		WHERE cod_empresa = cNumEmpresa;
	END IF;
	/*
	SELECT COUNT(*) INTO iExiste 
	FROM bdicheq:sc_amaltasmasivastemp 
	WHERE cod_empresa = pEmpresa 
	AND folio_archivo::INTEGER = iFolioArchivo;
	*/
	UPDATE bdicheq:sc_amctrlaltasmasivas 
	SET status = cStatus,fecha_aplicado = dFechaHoy,hora_aplicado = CURRENT HOUR TO SECOND
	WHERE cod_empresa = cNumEmpresa
	AND fecha_genera = dFechaGenera
	AND folio_archivo = iFolioArchivo;
	
	--RETURN cCodRet, cObservaciones;
	RETURN cCodRet;
	END
END PROCEDURE
Document
'DESCRIPCION: realizar la respuesta al cliente con las fallas en la lógica del archivo', 
'Por ejemplo: nombre1 = ANTONIO4 = FORMATO INVALIDO:NOMBRE1 y así sucesivamente acumulando los errores',
'encontrados por las validaciones estos se grabaran en el campo de observaciones de la sc_AMaltasmasivasTemp.',
'AUTOR: Antonio Bastidas',
'FECHA: 05 de abril de 2010',
'VERSION: 20100506.1751',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_generaredoctaeje(pEmpresa char(3))
RETURNING CHAR(5);
        
    DEFINE vcSql char(600);
    DEFINE vcStmt char(250);
    DEFINE vInserto CHAR(15);
    DEFINE vNombre_cte CHAR(150);
    DEFINE vcodret, vCP CHAR(5);
    DEFINE vNum_Tarjeta CHAR(16);
    DEFINE vRFC_Cliente CHAR(13);
    DEFINE vSucursal_num, anioFechaEmision CHAR(4);
    DEFINE  vdescripcion CHAR(180);
    DEFINE vDireccion_cte CHAR(200);
    DEFINE vSucursal_nombre CHAR(40);
    DEFINE vfechaAltaMes, vfechaAltaDia, mesFechaEmision CHAR(2);
    DEFINE cFech_param, cFech_param_ini CHAR(10);
    DEFINE vempresa, vexiste_genedoctaeje CHAR(3);
    DEFINE vCve_ruta, vCve_ahorro, vClabe, vCurp CHAR(60);
    DEFINE vcortSig, vMensajeProducto, vPiePagina CHAR(255);
    DEFINE vDireccion_col, vDireccion_del, vEdo_cd CHAR(120);
    DEFINE vmensajegeneraArch, cErrorInfo, vErrorInfo CHAR(80);
    DEFINE vaniomes, vcodRetspCortSig, vcodRetgeneraArch CHAR(6);
    DEFINE vcodretDet, vcodretEnc, vmin_aniomes, vmax_aniomes CHAR(6);
    DEFINE vcuenta, vnumCte, vNum_cte, vexiste_invcrec, vexiste_pagare CHAR(20);
    DEFINE vexiste_credito, vexiste_movhis, vexiste_movhisold, vmin_cta, vmax_cta CHAR(20);
    
    DEFINE bInicia BOOLEAN;
    DEFINE vTasaBruta, vGAT DECIMAL(9, 6);
    DEFINE vdiaSdo, iIsamErr, viDias, vDiaMesiversario SMALLINT;
    DEFINE vSaldoProm, vacumSdo, vsdocuenta, vdeposito, vretiro MONEY(14,2);
    DEFINE vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vInteresesNetos, vTotRetirosEfec, vTotOtrosCargos  DECIMAL(18,2);
    DEFINE vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros, vOtrosCargos, vRetencionIsr DECIMAL(18,2);
    DEFINE vcortSig2, vsecuencia, vnlinea, vidreg, vsqlerr, visamerr, vmesiversario, vaniversario INTEGER;
    DEFINE vultejec, vfecha_hoy, vfecha_ant, vfechaAlta, vultDiaMes, vPrimDiaMes, vfechCortSig, vfechealt, vhorainicio, vFecha_emision DATE;
    DEFINE vFechaAltaEnc, vFechaInicio, vfechaFinal, dFechaInicioMovimientos, dFechaFinMovimientos, dFechaCorte, dFechaEmision, dFechaNacimiento DATE;

    LET vaniomes = "";                              LET vcodretDet = "";                        LET vcodretEnC = "";
    LET vhorainicio = "";                           LET cErrorInfo="";                          LET vErrorInfo= "INICIO DEL PROCESO";
    LET vcortSig2 = 0;                              LET vcortSig = "";                          LET vsecuencia = 0;
    LET vnlinea =0;                                 LET vidreg = 0;                             LET vultejec = '';
    LET vmensajegeneraArch = "";                    LET vsqlerr = 0;                            LET vdeposito = 0;
    LET vretiro = 0;                                LET vfechealt = "";                         LET vsdocuenta = 0;
    LET vdescripcion = "";                          LET vempresa = "";                          LET vnumCte= "";
    LET vcuenta = "";                               LET vfechaAlta = "";                        LET vcodret = "000";
    LET vfecha_hoy = "";                            LET vfecha_ant = "";                        LET vultDiaMes = "";
    LET vmesiversario = 0;                          LET vaniversario = 0;                       LET vfechaAltaMes = "";
    LET vfechaAltaDia = "";                         LET bInicia = "F";                          LET iIsamErr = 0;
    LET vFecha_emision = "01-01-1900";              LET vNum_cte = "";                          LET vNum_Tarjeta = "";
    LET vNombre_cte = "";                           LET vDireccion_cte = "";                    LET vDireccion_col = "";
    LET vDireccion_del = "";                        LET vEdo_cd = "";                           LET vCve_ruta = "";
    LET vSucursal_nombre = "";                      LET vSucursal_num  = "";                    LET vRFC_Cliente = "";
    LET vCP = "";                                   LET vCve_ahorro = "";                       LET vClabe = "";
    LET vCurp = "";                                 LET vFechaAlta = "";                        LET vFechaInicio = "";
    LET vMensajeProducto = "";                      LET vInserto = "";                          LET vSaldoAnterior = 0;
    LET vDepositos = 0;                             LET vInteresesPagados = 0;                  LET vRetiros = 0;
    LET vOtrosCargos = 0;                           LET vIvaOtrosCargos = 0;                    LET vSaldoCorte = 0;
    LET vSaldoPromedio = 0;                         LET vRetencionIsr = 0;                      LET vInteresesNetos = 0;
    LET viDias = 0;                                 LET vTasaBruta = 0;                         LET vPiePagina  = "";
    LET vfechaFinal = "";                           LET vcSql = "";                             LET vcStmt = "";         
    LET vmin_cta = '';                              LET vmax_cta = '';
    LET dFechaInicioMovimientos = '01-01-1900';     LET dFechaFinMovimientos = '01-01-1900';    LET dFechaCorte = '01-01-1900';
    LET vDiaMesiversario = 0;                       LET dFechaEmision = '01-01-1900';           LET dFechaNacimiento = '01-01-1900';
    LET vTotRetirosEfec = 0;                        LET vTotOtrosCargos = 0;                    LET vGAT = 0; 
    LET mesFechaEmision = '';                       LET anioFechaEmision = '';
    
    --- SET DEBUG FILE TO "/tmp/sp_generaredoctaeje.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "./sp_generaredoctaeje.err";
            TRACE ON;
            
            LET vcodret = vsqlerr;
            LET vErrorInfo = cErrorInfo;
            
            IF bInicia = "T" THEN
                ROLLBACK WORK;
            END IF;
            
            LET vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                        'SET status_proc = '''||'C'||''','||
                        'cod_ret = '''||vcodret||''','||
                        'mensaje = '''||vErrorInfo||''','||
                        'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                        'WHERE fecha = '''||vfecha_hoy||''' '||
                        'AND  status_proc = '''||'I'||''' '||
                        'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta.sql';
            SYSTEM vcSql;
            LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
            SYSTEM vcStmt;
            
            RETURN vcodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;

    IF pEmpresa IS NULL  THEN
        LET vcodret = '001';
        RETURN vcodret;
    END IF; 
    
    -- // obtener la fecha de ayer y hoy
    SELECT fecha_ant, fecha_hoy
      INTO vfecha_ant, vfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = "001";
     
    SELECT valor
      INTO cFech_param
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO cFech_param_ini
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmin_cta, vmax_cta
      FROM sc_maehis;
      
    SELECT MIN(aniomes), MAX(aniomes)
      INTO vmin_aniomes, vmax_aniomes
      FROM sc_maehis;

    -- // obtener el dia en que se descargan los archivos de texto
    SELECT dia_mesiversario
      INTO vDiaMesiversario
      FROM sc_configuracion_edocta
     WHERE dia_mesiversario IS NOT NULL;

    -- // armar la fecha de emision
    IF DAY(vfecha_ant) < vdiaMesiversario THEN
    
        LET dFechaEmision = MDY( MONTH(vfecha_ant), vDiaMesiversario, YEAR(vfecha_ant) );
        
    ELSE
        --- LET dFechaEmision = MDY( MONTH(vfecha_ant + 1 UNITS MONTH), vDiaMesiversario, YEAR(vfecha_ant) );
        
        LET mesFechaEmision = LPAD(MONTH(vfecha_ant) + 1, 2, '0');
        LET anioFechaEmision = YEAR(vfecha_ant);
        
        IF mesFechaEmision > '12' THEN
           LET mesFechaEmision = '01';
           LET anioFechaEmision = YEAR(vfecha_ant) + 1;
        END IF;
        
        LET dFechaEmision = MDY( mesFechaEmision, vDiaMesiversario, anioFechaEmision );         
    END IF;

    -- // obtener la fecha en que se ejecutó por última vez.
    SELECT NVL(MAX(fecha),vfecha_ant)
      INTO vultejec
      FROM sc_contproc_edocta
     WHERE proceso = 'GENERA EDO CTA EJE'
       AND empresa = pEmpresa
       AND status_proc = 'F'
       AND tipo_proc   = 'D';

    IF vultejec >= vfecha_hoy THEN -- // si no se ejecuto hoy
        LET vcodret = '000';
        RETURN vcodret;
    END IF;
    
    -- // si no hay registro de que el proceso haya quedado inconcluso se inserta uno nuevo, sino solo se actualiza
    SELECT empresa
      INTO vexiste_genedoctaeje
      FROM sc_contproc_edocta
     WHERE proceso = 'GENERA EDO CTA EJE'
       AND fecha   = vfecha_hoy
       AND empresa = pEmpresa
       AND status_proc in('I','C')
       AND tipo_proc   = 'D';
       
    IF vexiste_genedoctaeje is null OR vexiste_genedoctaeje = '' THEN
        LET vcSql = 'echo " INSERT INTO bdicheq:sc_contproc_edocta (empresa, proceso, fecha, tipo_proc, status_proc, ejecutivo, hora_inicio, hora_fin, cod_ret, mensaje) '||
                    'VALUES('''||pempresa||''', '''||'GENERA EDO CTA EJE'||''', '''||vfecha_hoy||''', '''||'D'||''', '''||'I'||''', USER,'||
                    '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||'''),'||
                    'NULL,'''||vcodret||''', '''||vErrorInfo||''');" > /tmp/contproc_edocta.sql';
        SYSTEM vcSql;
        LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
        SYSTEM vcStmt;
    ELSE
        LET vcSql = 'echo " UPDATE bdicheq:sc_contproc_edocta '||
                    'SET status_proc =  '''||'I'||''','||
                    'hora_inicio = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||'''),'||
                    'hora_fin = NULL '||
                    'WHERE fecha = '''||vfecha_hoy||''' AND status_proc = '''||'C'||''' AND  tipo_proc = '''||'D'||''';" > /tmp/contproc_edocta.sql';
        SYSTEM vcSql;
        LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
        SYSTEM vcStmt;
    END IF;
    
    CREATE TEMP TABLE tmp_ctesno( num_cte CHAR(20) ) WITH NO LOG;
    CREATE INDEX idx_ctesno ON tmp_ctesno(num_cte) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctesno;
    
    INSERT INTO tmp_ctesno
    SELECT num_cte
      FROM sc_maechq 
     WHERE empresa = pEmpresa
       AND producto = '1100'
       AND status_cta <> '2';
    
    INSERT INTO tmp_ctesno
    SELECT num_cte
      FROM bdinvers:sv_maeinv 
     WHERE empresa = pEmpresa
       AND status_cta = '1';
    
    INSERT INTO tmp_ctesno
    SELECT numcte
      FROM bdicred:sd_maecred 
     WHERE numcte = vnumCte;
    
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctesno;
    
    SELECT UNIQUE num_cte
      FROM tmp_ctesno
      INTO TEMP tmp_ctesexcluidos WITH NO LOG;
    CREATE INDEX idx_ctesexc ON tmp_ctesexcluidos(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctesexcluidos;
    
    FOREACH WITH HOLD -- // obtener las cuentas que sean participantes y que cumplan su aniversario o mesiversario
        SELECT {+INDEX(sc_maehis maehis1)}
               mae.aniomes, mae.cuenta, mae.num_cte, mae.fechaini, mae.fechafin, mae.acum_sdo_pos, mae.dia_sdo_pos
          INTO vaniomes, vcuenta, vnumCte, dFechaInicioMovimientos, dFechaFinMovimientos, vacumSdo, vdiaSdo
          FROM sc_maehis AS mae,
               sc_prod_participan_edocta AS prod
         WHERE mae.aniomes BETWEEN vmin_aniomes and vmax_aniomes
           AND mae.cuenta BETWEEN vmin_cta AND vmax_cta
           AND mae.cuenta NOT IN ( SELECT ee.num_cuenta 
                                     FROM bdicheq:sc_encabezado_edocta ee
                                    WHERE ee.num_cuenta = mae.cuenta 
                                      AND ee.fechafinal = vfecha_ant )
           AND mae.fechaini < vfecha_ant
           AND mae.fechafin BETWEEN vultejec AND vfecha_ant
           AND mae.num_cte NOT IN( SELECT num_cte 
                                     FROM tmp_ctesexcluidos AS ctes
                                    WHERE ctes.num_cte = mae.num_cte )
           AND prod.producto = mae.producto
           AND prod.gpo_producto = 'CH'
                
        -- // calcular saldo promedio de la cuenta
        IF vdiaSdo <>  0 THEN
            LET vSaldoProm = vacumSdo / vdiaSdo;
        ELSE
            LET vSaldoProm = 0;
        END IF;

        BEGIN WORK;
        LET bInicia = "T";

        IF vSaldoProm > 50 THEN
            -- // ejecutar el store para llenar el encabezado
            SELECT NVL(MAX(idreg), 0) + 1
              INTO vidreg
              FROM sc_encabezado_edocta;

            EXECUTE PROCEDURE sp_generaredoctaejeencabezado(pEmpresa, vcuenta, vaniomes)
            INTO vcodretEnc, vFecha_emision, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del,
                 vEdo_cd, vCve_ruta, vSucursal_nombre, vRFC_Cliente, vCP, vCve_ahorro, vClabe, vCurp, vFechaAltaEnc, vFechaInicio,
                 vMensajeProducto, vInserto, vfechaFinal, vSucursal_num, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                 vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta, 
                 vPiePagina, vTotRetirosEfec, vTotOtrosCargos, vGAT;
         
            IF trim(vcodretEnc) = '000' THEN -- // hacer las inserciones si el resultado del SP_generarEdoCtaejeencabezado fue satisfactorio
                
                INSERT INTO sc_encabezado_edocta 
                (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, 
                 direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta, sucursal_nombre, rfc, cp, 
                 cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vNum_cte, vNum_Tarjeta, vNombre_cte,
                 vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, vCve_ruta, vSucursal_nombre, vRFC_Cliente, vCP,
                 vCve_ahorro, vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vMensajeProducto, vinserto, vfechaFinal, vSucursal_num);
                
                INSERT INTO sc_encabezado2_edocta
                (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros,
                 otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                 vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta);

                LET vsecuencia = 1;
                LET vnlinea = 1;

                INSERT INTO sc_piepagina_edocta 
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
                
                INSERT INTO sc_mensajes_edocta
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, 'Cuando utilices un cajero automático no aceptes ayuda de nadie.');
                
                INSERT INTO sc_mensajes_edocta
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea + 1, 'No se deje sorprender por llamadas telefónicas, mensajes por teléfono o mensajes en su correo electrónico en los que se le solicite su número de tarjeta de débito.');
                
                INSERT INTO sc_mensajes_edocta
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea + 2, 'Al pagar con su tarjeta de débito y antes de firmar el recibo, verifique que el monto total de la compra sea el correcto.');
                
                INSERT INTO sc_grafica
                (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vSaldoCorte, vTotRetirosEfec, vDepositos, vInteresesPagados, vOtrosCargos, vIvaOtrosCargos, vTotOtrosCargos, vGAT);
                
            ELSE -- // si el resultado no fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecución
            
                ROLLBACK WORK;
                
                LET bInicia = "F";
                LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
                LET vcodret = '003';
                
                LET vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                            'SET status_proc = '''||'C'||''','||
                            'cod_ret = '''||vcodret||''','||
                            'mensaje = '''||vErrorInfo||''','||
                            'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                            'WHERE fecha = '''||vfecha_hoy||''' '||
                            'AND  status_proc = '''||'I'||''' '||
                            'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta.sql';
                SYSTEM vcSql;
                LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
                SYSTEM vcStmt;
                
                RETURN vcodret;
                
            END IF;

            -- // ejecutar store para el detalle
            LET vsecuencia = 0;

            FOREACH
                EXECUTE PROCEDURE sp_generaredoctaejedetalle(pEmpresa, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos)
                INTO vcodretDet,vdescripcion,vsdocuenta,vfechealt,vdeposito,vretiro
                
                IF trim(vcodretDet) = '000' THEN -- // si el resultado fue satisfactorio hacer las inserciones para los detalles
                    LET vsecuencia = vsecuencia + 1;
                    LET vnlinea = 0;

                    FOREACH -- // cortar los detalles en lineas
                        EXECUTE PROCEDURE bdicred:corta_linea(vdescripcion, 40)
                        INTO vcortSig, vcortsig2

                        LET  vnlinea =vnlinea + 1;

                        IF vnlinea > 1 THEN
                            LET vretiro = 0.00;
                            LET vdeposito = 0.00;
                            LET vsdocuenta = 0.00;
                            LET vfechealt = '01-01-1900';
                        END IF;

                        INSERT INTO bdicheq:sc_detalle_edocta
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vfechealt, vcortSig, vretiro, vdeposito, vsdocuenta);
                    END FOREACH;
                ELSE -- // si el resultado no fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecución
                    IF trim(vcodretDet) <> '002' THEN -- // 002 la cuenta no tiene movimientos
                        ROLLBACK WORK;
                        
                        LET bInicia = "F";
                        LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL DETALLE ' || vcodretDet;
                        LET vcodret = '004';
                        
                        LET vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                                    'SET status_proc = '''||'C'||''','||
                                    'cod_ret = '''||vcodret||''','||
                                    'mensaje = '''||vErrorInfo||''','||
                                    'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                                    'WHERE fecha = '''||vfecha_hoy||''' '||
                                    'AND  status_proc = '''||'I'||''' '||
                                    'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta.sql';
                        SYSTEM vcSql;
                        LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
                        SYSTEM vcStmt;
                        
                        RETURN vcodret;
                    END IF;
                END IF;
            END FOREACH;
        
        ELSE  -- // saldo de la cuenta menor o igual a 50
            -- // obtener la fecha de alta de la cuenta para saber si es su aniversario
            SELECT fecha_alta
              INTO vfechaAlta
              FROM bdicheq:sc_maenoc
             WHERE cuenta = vcuenta
               AND empresa = pEmpresa;

            -- // obtener el mes y dia de corte para compararlo con la fech_alt
            LET dFechaNacimiento = dFechaFinMovimientos + 1 UNITS DAY;

            IF TO_CHAR(vfechaAlta, '%m%d') = TO_CHAR(dFechaNacimiento, '%m%d' ) THEN
                LET  vaniversario = 1;
            ELIF
                TO_CHAR(vfechaAlta,'%m%d')  = '0229' AND TO_CHAR(dFechaNacimiento + 1 UNITS DAY, '%m%d') <> '0229' THEN
                IF TO_CHAR(dFechaNacimiento,'%m%d' ) = '0228' THEN
                    LET vaniversario = 1;
                END IF;
            END IF;

            IF vaniversario = 1 THEN
                -- // verificar que la cuenta no tenga movimientos en los últimos 6 meses.
                EXECUTE PROCEDURE bdicheq:sp_cortesig(dFechaFinMovimientos, -6)
                INTO vcodRetspCortSig, vfechCortSig;
                
                SELECT {+INDEX(sc_movhis idx_movhisnew1)} FIRST 1 cuenta
                  INTO vexiste_movhis
                  FROM bdicheq:sc_movhis
                 WHERE empresa = pEmpresa
                   AND cuenta = vcuenta
                   AND fech_alt BETWEEN vfechCortSig AND dFechaFinMovimientos
                   AND fech_alt >= cFech_param
                   AND cancelad <> 'S';
                
                SELECT {+INDEX(sc_movhis_old idx_movhis)} FIRST 1 cuenta
                  INTO vexiste_movhisold
                  FROM bdicheq:sc_movhis_old
                 WHERE empresa = pEmpresa
                   AND cuenta = vcuenta
                   AND fech_alt BETWEEN vfechCortSig AND dFechaFinMovimientos
                   AND fech_alt >= cFech_param_ini
                   AND fech_alt < cFech_param
                   AND cancelad <> 'S';
                   
                IF (vexiste_movhis is null OR vexiste_movhis = '') AND (vexiste_movhisold is null OR vexiste_movhisold = '')THEN
                    -- // ejecutar el store para llenar encabezado
                    SELECT NVL(MAX(idreg),0) + 1
                      INTO vidreg
                      FROM bdicheq:sc_encabezado_edocta;

                    EXECUTE PROCEDURE sp_generaredoctaejeencabezado(pEmpresa, vcuenta, vaniomes)
                    INTO vcodretEnc,vFecha_emision,vNum_cte,vNum_Tarjeta,vNombre_cte,vDireccion_cte,vDireccion_col,vDireccion_del,vEdo_cd,
                         vCve_ruta,vSucursal_nombre,vRFC_Cliente,vCP,vCve_ahorro,vClabe,vCurp,vFechaAltaEnc,vFechaInicio,vMensajeProducto,
                         vInserto,vfechaFinal,vSucursal_num,vSaldoAnterior,vDepositos,vInteresesPagados,vRetiros,vOtrosCargos,vIvaOtrosCargos,
                         vSaldoCorte,vSaldoPromedio,vRetencionIsr,vInteresesNetos,viDias,vTasaBruta,vPiePagina, vTotRetirosEfec, vTotOtrosCargos, vGAT;
                 
                    -- // si el resultado fue satisfactorio hacer las inserciones
                    IF trim(vcodretEnc) = '000' THEN
                    
                        INSERT INTO sc_encabezado_edocta
                        (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte,
                         direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta, sucursal_nombre, rfc, cp,
                         cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vNum_cte, vNum_Tarjeta, vNombre_cte,
                         vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, vCve_ruta, vSucursal_nombre, vRFC_Cliente, vCP,
                         vCve_ahorro, vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vMensajeProducto, vInserto, vfechaFinal, vSucursal_num);
                         
                        INSERT INTO sc_encabezado2_edocta
                        (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros,
                         otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias, tasabruta)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                         vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta);

                        LET vsecuencia = 1;
                        LET vnlinea = 1;

                        INSERT INTO sc_piepagina_edocta 
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
                        
                        INSERT INTO sc_mensajes_edocta
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, 'Cuando utilices un cajero automático no aceptes ayuda de nadie.');
                        
                        INSERT INTO sc_mensajes_edocta
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea + 1, 'No se deje sorprender por llamadas telefónicas, mensajes por teléfono o mensajes en su correo electrónico en los que se le solicite su número de tarjeta de débito.');
                        
                        INSERT INTO sc_mensajes_edocta
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea + 2, 'Al pagar con su tarjeta de débito y antes de firmar el recibo, verifique que el monto total de la compra sea el correcto.');
                        
                        INSERT INTO sc_grafica
                        (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vSaldoCorte, vTotRetirosEfec, vDepositos, vInteresesPagados, vOtrosCargos, vIvaOtrosCargos, vTotOtrosCargos, vGAT);
                        
                    ELSE  -- // si el resultado no fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecución
                    
                        ROLLBACK WORK;
                        
                        LET bInicia = "F";
                        LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
                        LET vcodret = '005' ;
                        
                        LET vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                                    'SET status_proc = '''||'C'||''','||
                                    'cod_ret = '''||vcodret||''','||
                                    'mensaje = '''||vErrorInfo||''','||
                                    'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                                    'WHERE fecha = '''||vfecha_hoy||''' '||
                                    'AND  status_proc = '''||'I'||''' '||
                                    'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta.sql';
                        SYSTEM vcSql;
                        LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
                        SYSTEM vcStmt;
                        
                        RETURN vcodret;
                        
                    END IF;
                END IF; 
            END IF; 
        END IF; 

        COMMIT WORK;
        LET bInicia = "F";        
    END FOREACH;
    
    -- // actualizar el control de proceso
    LET vErrorInfo = 'PROCESO EXITOSO';
    LET vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                'SET status_proc = '''||'F'||''','||
                'cod_ret = '''||vcodret||''','||
                'mensaje = '''||vErrorInfo||''','||
                'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                'WHERE fecha = '''||vfecha_hoy||''' '||
                'AND  status_proc = '''||'I'||''' '||
                'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta.sql';
    SYSTEM vcSql;
    LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
    SYSTEM vcStmt;
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE;