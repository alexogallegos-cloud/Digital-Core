CREATE PROCEDURE "informix".sp_guardaultimosdotf(pEmpresa CHAR(3), pNumCtetf CHAR(20), pNumCtatf CHAR(20), pUltimoSaldo MONEY(14,2))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(6)	  AS  CodRet,
	CHAR(60)  AS  Mensaje;
	
	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(6);
	DEFINE cMensaje				CHAR(60);
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr 			= 0;
	LET cCodRet 			= '000000';
	LET cMensaje			= 'PROCESO EJECUTADO EXITOSAMENTE';
	
	--SET DEBUG FILE TO "/home/sysifx/Pedro/sp_guardaultimosdotf.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE VALIDA SI LO PARAMETROS VIENE VACIOS.
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCtetf,'') = '' OR NVL(pNumCtatf,'') = '' OR 
			NVL(pUltimoSaldo,'') = '' THEN 
		
			LET cCodRet = '000001';
			LET cMensaje = 'ERROR PARAMETROS VACIOS';
			RETURN  cCodRet,cMensaje;
			
		END IF;
			
		--SE VALIDA SI NUMERO DE CLIENTE Y CUENTA EXISTE.
		IF EXISTS (SELECT numcte_tf, cuenta_tf FROM "informix".tf_maecte 
					WHERE empresa = pEmpresa AND numcte_tf = pNumCtetf AND cuenta_tf = pNumCtatf) THEN 
			
				UPDATE "informix".tf_maecte SET ultimo_saldo = pUltimoSaldo 
				WHERE empresa = pEmpresa AND cuenta_tf = pNumCtatf AND numcte_tf = pNumCtetf;

		END IF;	
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000002';
			LET cMensaje = 'NO SE ENCONTRARON DATOS';
		END IF;
		
		RETURN  cCodRet,cMensaje;
	
	END	
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1440',
'DESCRIPCION: Actualiza el ultimo_saldo del cliente',
'FECHA: 17/06/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_identificarctetfbco(pEmpresa CHAR(3), pNumTelefono CHAR(13))
	RETURNING 
	CHAR(6) 	AS CodigoRet, 
	CHAR(60) 	AS Mensaje,
	INTEGER 	AS ClienteTransfer,
    INTEGER 	AS ClienteBanco;	

	-- DEFINICION DE VARIABLES.
	DEFINE cCodRet		CHAR(6);
	DEFINE cMensaje		CHAR(60);
	DEFINE iSqlErr		INTEGER;
	DEFINE iCteTransfer	INTEGER;
	DEFINE iCteBanco	INTEGER;
	
	-- INICIALIZACION DE VARIABLES.
	LET cCodRet 		= '000000';
	LET cMensaje 		= 'EJECUTADO EXITOSAMENTE';
	LET iSqlErr 		= 0;
	LET iCteTransfer 	= 0;
	LET iCteBanco 		= 0;
	
	--SET DEBUG FILE TO '/respaldosbd/Guadalupe/sp_identificarctetfbco.out';
	--TRACE ON;

	BEGIN
		--SE VALIDAN LAS EXCEPCIONES DEL INFORMIX Y SE INFORMAN RETORNANDO LOS CODIGOS DE ERRORES.
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = 'OCURRIO UN ERROR DE INFORMIX';
				RETURN cCodRet, cMensaje,NVL(iCteTransfer,0), NVL(iCteBanco,0);
			END IF;
		END EXCEPTION;
		
		--SE VALIDAN LOS PARAMETROS DE ENTRADA QUE NO VENGAN VACIOS.
		IF NVL(pEmpresa,'') = '' OR  NVL(pNumTelefono,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensaje = 'PARAMETRO VACIO';
			RETURN cCodRet, cMensaje,NVL(iCteTransfer,0), NVL(iCteBanco,0);
		END IF;
	
		--SE DETERMINAR SI EL CLIENTE ES TRANSFER O CLIENTE BANCOPPEL.	
		SELECT CASE WHEN numcte_tf > 0 THEN 1 ELSE 0 END AS EsCteTransfer,CASE WHEN numcte > 0 THEN 1 ELSE 0 END AS EsCteBanco
		INTO iCteTransfer, iCteBanco
		FROM 'informix'.tf_maecte
		WHERE empresa = pEmpresa  
			AND telefono = pNumTelefono
			AND	status_cta=1 ;

		
		-- SE VALIDA SI EXISTE EL NUMERO DE TELEFONO.
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN				
			LET cCodRet = '000002';
			LET cMensaje = 'NO SE ENCONTRARON RESULTADOS';
		END IF;
		
		--SE RETORNAN LOS VALORES OBTENIDOS.
		RETURN cCodRet, cMensaje,NVL(iCteTransfer,0), NVL(iCteBanco,0);
	
	END
END PROCEDURE
DOCUMENT
'AUTOR: 93928475 - Guadalupe Payan Camacho',
'FOLIO: 1440',
'DESCRIPCION: Determina la clasificacion del cliente si es cliente transfer o si es cliente banco.',
'FECHA: 11/06/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_buscardetallectatf(pEmpresa CHAR(3), pNumCteTf CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(6) AS  	CodRet,
	CHAR(60) AS  	Mensaje,
	CHAR(20) AS 	NumCteTf,
	CHAR(20) AS 	NumCtaTf,
	CHAR(16) AS 	NumTarjeta,
	CHAR(4) AS 		NumProd,
	DATE AS			FechaAlta,
	CHAR(1) AS		StatusCta,
	MONEY(14,2) AS  UltimoSaldo;

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(6);
	DEFINE cMensaje				CHAR(60);
	DEFINE cNumCteTf			CHAR(20);
	DEFINE cNumCtaTf			CHAR(20);
	DEFINE cNumTarjeta			CHAR(16);
	DEFINE cNumProd				CHAR(4);
	DEFINE dFechaAlta			DATE;
	DEFINE cStatusCta			CHAR(1);
	DEFINE mUltimoSaldo			MONEY(14,2);
	
	
	--INICIALIZACION DE VARIABLES--
	LET iSqlErr 			= 0;
	LET cCodRet 			= '000000';
	LET cMensaje			= 'EJECUTADO EXITOSAMENTE';
	LET cNumCteTf			= '';
	LET cNumCtaTf			= '';
	LET cNumTarjeta			= '';
	LET cNumProd			= '';
	LET dFechaAlta			= DATE(1);
	LET cStatusCta			= '';
	LET mUltimoSaldo		= 0.00;
	
	--SET DEBUG FILE TO "/home/sysifx/Pedro/sp_buscardetallectatf.out";
	--TRACE ON;
	BEGIN
		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = 'OCURRIO UN ERROR NO CONTROLADO';
				RETURN cCodRet,cMensaje,cNumCteTf,cNumCtaTf,cNumTarjeta,cNumProd,dFechaAlta,cStatusCta,NVL(mUltimoSaldo,0.00);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE VALIDA SI LO PARAMETROS VIENE VACIOS.
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCteTf,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensaje = 'ERROR PARAMETROS VACIOS';
			RETURN cCodRet,cMensaje,cNumCteTf,cNumCtaTf,cNumTarjeta,cNumProd,dFechaAlta,cStatusCta,NVL(mUltimoSaldo,0.00);
		END IF;
		
		FOREACH
		
			SELECT numcte_tf, cuenta_tf, num_tarjeta, producto, fec_alta, status_cta, ultimo_saldo
				INTO cNumCteTf, cNumCtaTf, cNumTarjeta, cNumProd, dFechaAlta, cStatusCta, mUltimoSaldo
				FROM "informix".tf_maecte
				WHERE empresa = pEmpresa 
				AND numcte_tf = pNumCteTf
			
			RETURN cCodRet,cMensaje,cNumCteTf,cNumCtaTf,cNumTarjeta,cNumProd,dFechaAlta,cStatusCta,NVL(mUltimoSaldo,0.00) WITH RESUME;
			
		END FOREACH

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000002';
			LET cMensaje = 'NO SE ENCONTRARON DATOS';
			RETURN cCodRet,cMensaje,cNumCteTf,cNumCtaTf,cNumTarjeta,cNumProd,dFechaAlta,cStatusCta,NVL(mUltimoSaldo,0.00);
		END IF;

	END	
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1440',
'DESCRIPCION: Realiza una consulta para obtener detalles de la cuenta del cliente',
'FECHA: 11/06/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_consulta_codret(pCodError CHAR(5))
RETURNING 
CHAR(5)   AS CodRetorno,
CHAR(170) AS Descripcion;

-- DEFINICION DE VARIABLES
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cDescripcion CHAR(170);

-- INICIALIZACION DE VARIABLES
LET iSqlErr = 0;
LET cCodRet = '00000';
LET cDescripcion = '';

--SET DEBUG FILE TO '/home/sysifx/Pedro/sp_consulta_codret.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(cDescripcion,'');
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pCodError,'') = '' THEN
		LET cCodRet = '00001'; -- PARAMETRO VACIO
	ELSE
		SELECT TRIM(descripcion) INTO cDescripcion
		FROM 'informix'.tf_codret
		WHERE cod_error = pCodError;
		
		IF dbinfo('sqlca.sqlerrd2') = 0 THEN 
			LET cCodRet = '00002'; -- NO EXISTE
		END IF;
	END IF;

	RETURN cCodRet, NVL(cDescripcion,'');
END;
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1440',
'DESCRIPCION: Consulta la descripcion del error del catalogo de transfer',
'FECHA: 07/07/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_actualizadatos_ctetf(
						pEmpresa 			CHAR(3),
						pNumCteTransf 		CHAR(20), 
						pNumCteBco 			CHAR(20), 
						pNumTelefono 		CHAR (13),
						pCuentaTf 			CHAR(20), 
						pTipoCorreoTf 		SMALLINT,
						pCanalTf 			SMALLINT, 
						pDescCorreo 		CHAR(100), 
						pDescIdentiTf 		CHAR(50), 
						pCodIdentifiTf		CHAR(1), -- Nuevo parametro DSB 05/08/2014
						pNumIdentiTf 		CHAR(50), 
						pDescCalle 			CHAR(100), 
						pNumExterno 		CHAR(15),
						pNumInterno 		CHAR(15), 
						pNumDepto 			CHAR(15), 
						pDescColonia 		CHAR(100),
						pDescCiudadTf 		CHAR(50), 
						pNumMunicipio 		CHAR(5), 
						pDescEstadoTf  		CHAR(100), 
						pCodPostalTf 		INTEGER, 
						pTipoCliente 		SMALLINT, 
						pUserInsert 		CHAR(8),
						pEntreCallesDir 	CHAR(40),    
						pNumPaisDir     	CHAR(3),     
						pNumEntidadDir  	CHAR(2),     
						pNumLocalidadDir	CHAR(3),     
						pCodPostalDir       CHAR(5),	   
						pNumCiudadCoppelDir SMALLINT,    						
						pNumCalleDir        INTEGER,     
						pNumColoniaDir      INTEGER,     
						pFechaInsertDir     DATE,        
						pSucursalDir        CHAR(4) 						
						)																											
	RETURNING 
	CHAR(6) AS CodigoRet, 
	CHAR(100) AS Mensaje;	
		
	-- DEFINICION DE VARIABLES.
	DEFINE cCodRet			CHAR(6);
	DEFINE cMensaje			CHAR(100);
	DEFINE iSqlErr			INTEGER;
	DEFINE cCodRetCorreo	CHAR(5);
	DEFINE cCodRetDirec		CHAR(5);
	DEFINE cBegin			CHAR(5);
	DEFINE cBanMaeCtetf		CHAR(1);
	DEFINE cBanDirecTf		CHAR(1);
	
		
	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		LET cMensaje = "OCURRIO UN ERROR DE INFORMIX";
		ROLLBACK WORK;
		IF (cBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN cCodRet, cMensaje;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		LET cBegin = "S";
		ROLLBACK WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	LET cBegin 			= "N";
	
	BEGIN WORK;
		-- INICIALIZACION DE VARIABLES.
		LET cCodRet 		= "000000";
		LET cMensaje 		= "PROCESO EJECUTADO EXITOSAMENTE";
		LET iSqlErr 		= 0;
		LET cCodRetCorreo 	= "00000";
		LET cCodRetDirec 	= "00000";	
		LET cBanMaeCtetf 	= "0";	
		LET cBanDirecTf 	= "0";	
		
		--SET DEBUG FILE TO "/respaldosbd/CarlosAguirre/sp_actualizadatos_ctetf.out";
		--TRACE ON;
		
		--SE VALIDA QUE EL TIPO DE CLIENTE TENGA UN VALOR PERMITIDO.
		IF NVL(pTipoCliente,0) = 0 OR pTipoCliente NOT IN (1,2) THEN 
			LET cCodRet = "000001";
			LET cMensaje = "TIPO DE CLIENTE INVALIDO";
			RETURN cCodRet, cMensaje;			
		END IF;
		
		--SE VALIDA QUE EL TIPO DE CLIENTE TENGA UN VALOR PERMITIDO.
		IF NVL(pEmpresa,"") = "" THEN 
			LET cCodRet = "000002";
			LET cMensaje = "EMPRESA INVALIDA";
			RETURN cCodRet, cMensaje;			
		END IF;
		
		--SE VALIDA QUE LA CUENTA TRANSFER NO ESTE VACIA O NULA.
		IF NVL(pCuentaTf,"") = "" THEN 
			LET cCodRet = "000003";
			LET cMensaje = "CUENTA TRANSFER VACIA O NULA";
			RETURN cCodRet, cMensaje;			
		END IF;
		
		--SE VALIDA QUE EL TELEFONO NO ESTE VACIO O NULO.
		IF NVL(pNumTelefono,"") = "" THEN 
			LET cCodRet = "000004";
			LET cMensaje = "NUMERO DE TELEFONO VACIO O NULO";
			RETURN cCodRet, cMensaje;			
		END IF;
		
		--SE VALIDA QUE EL CLIENTE BANCO NO ESTE VACIO O NULO.
		IF NVL(pTipoCliente,"") = 2 THEN 
			IF NVL(pNumCteBco,"") = "" THEN 
				LET cCodRet = "000005";
				LET cMensaje = "NUMERO DE CLIENTE BANCO VACIO O NULO";
				RETURN cCodRet, cMensaje;			
			END IF;
		END IF ;
		
		--SE VALIDA QUE EL CLIENTE TRANSFER NO ESTE VACIO O NULO.
		IF NVL(pNumCteTransf,"") = "" THEN 
			LET cCodRet = "000006";
			LET cMensaje = "NUMERO DE CLIENTE TRANSFER VACIO O NULO";
			RETURN cCodRet, cMensaje;			
		END IF;
						
----------------------------------------- CLIENTE TRANSFER ------------------------------------------------------		
		IF NVL(pNumIdentiTf,"") <> "" AND NVL(pDescIdentiTf,"") <> "" AND NVL(pDescCorreo,"") <> ""  THEN 							
			--SE ACTUALIZA CORREO, IDENTIFICACION Y NUMERO DE IDENTIFICACION.
			UPDATE "informix".tf_maecte 
			SET num_identificacion = pNumIdentiTf, identificacion = pDescIdentiTf, correo = pDescCorreo
			WHERE empresa 		= pEmpresa
				AND cuenta_tf 	= pCuentaTf
				AND telefono 	= pNumTelefono
				--AND numcte 		= pNumCteBco
				AND numcte_tf 	= pNumCteTransf;
				
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;
			-- SE ACTIVA LA BANDERA CUANDO VIENEN TODOS LOS PARAMETROS DE LA INFORMACION DEL CLIENTE CON VALOR.
			LET cBanMaeCtetf = "1";
	    END IF;
		
		IF NVL(pNumIdentiTf,"") <> "" AND cBanMaeCtetf = "0" THEN
			--SE ACTUALIZA NUMERO DE IDENTIFICACION.
			UPDATE "informix".tf_maecte 
			SET num_identificacion = pNumIdentiTf
			WHERE empresa 		= pEmpresa
				AND cuenta_tf 	= pCuentaTf
				AND telefono 	= pNumTelefono
				--AND numcte 		= pNumCteBco
				AND numcte_tf 	= pNumCteTransf;
			
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;
		END IF;
		
		IF NVL(pDescIdentiTf,"") <> "" AND cBanMaeCtetf = "0" THEN 
			--SE ACTUALIZA IDENTIFICACION.
			UPDATE "informix".tf_maecte 
			SET identificacion = pDescIdentiTf
			WHERE empresa 		= pEmpresa
				AND cuenta_tf 	= pCuentaTf
				AND telefono 	= pNumTelefono
				--AND numcte 		= pNumCteBco
				AND numcte_tf 	= pNumCteTransf;
			
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;
		END IF;
		
		IF NVL(pDescCorreo,"") <> "" AND cBanMaeCtetf = "0" THEN
							
			--SE ACTUALIZA CORREO.
			UPDATE "informix".tf_maecte 
			SET correo = pDescCorreo
			WHERE empresa 		= pEmpresa
				AND cuenta_tf 	= pCuentaTf
				AND telefono 	= pNumTelefono
				--AND numcte 		= pNumCteBco
				AND numcte_tf 	= pNumCteTransf;
			
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;			
		END IF;
		
		--SE VALIDAN LOS CAMPOS QUE SE VAN ACTUALIZAR DE LA DIRECCION DEL CLIENTE TRANSFER.
		IF NVL(pDescEstadoTf,"") <> "" AND NVL(pDescCiudadTf,"") <> "" AND NVL(pDescColonia,"") <> "" AND NVL(pDescCalle,"") <> "" 
		   AND NVL(pNumExterno,"") <> "" 
		   --AND NVL(pNumInterno,"") <> "" AND NVL(pNumDepto,"") <> "" --se modifico 04/11/2014
		   AND NVL(pCodPostalTf,0) <> 0 THEN 		   
			--SE ACTUALIZA LA DIRECCION DEL CLIENTE TRANSFER.
			UPDATE "informix".tf_direcciones 
			SET estado = pDescEstadoTf, municipio = pDescCiudadTf, colonia = pDescColonia, calle = pDescCalle,
				num_externo = pNumExterno,num_interno = pNumInterno ,num_depto = pNumDepto,
				cod_postal = pCodPostalTf 
			WHERE cuenta_tf = pCuentaTf
				AND numcte_tf = pNumCteTransf;	
				
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;							
			END IF;	
			-- SE ACTIVA LA BANDERA CUANDO VIENEN TODOS LOS PARAMETROS DE LA DIRECCION CON VALOR.
			LET cBanDirecTf = "1";
		END IF;
		
		IF NVL(pDescEstadoTf,"") <> "" AND cBanDirecTf = "0" THEN 		   
		   --SE ACTUALIZA LA DIRECCION (ESTADO) DEL CLIENTE TRANSFER.
			UPDATE "informix".tf_direcciones 
			SET estado = pDescEstadoTf
			WHERE cuenta_tf = pCuentaTf
				AND numcte_tf = pNumCteTransf;	
			
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;							
			END IF;			
		END IF;
		
		IF NVL(pDescCiudadTf,"") <> "" AND cBanDirecTf = "0" THEN 		   
			--SE ACTUALIZA LA DIRECCION (CIUDAD) DEL CLIENTE TRANSFER.
			UPDATE "informix".tf_direcciones 
			SET municipio = pDescCiudadTf
			WHERE cuenta_tf = pCuentaTf
				AND numcte_tf = pNumCteTransf;			
			
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;
		END IF;
		
		IF NVL(pDescColonia,"") <> "" AND cBanDirecTf = "0" THEN 		   
			--SE ACTUALIZA LA DIRECCION (COLONIA) DEL CLIENTE TRANSFER.
			UPDATE "informix".tf_direcciones 
			SET colonia = pDescColonia
			WHERE cuenta_tf = pCuentaTf
				AND numcte_tf = pNumCteTransf;	
			
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;
		END IF;
		
		IF NVL(pDescCalle,"") <> "" AND cBanDirecTf = "0" THEN 		   		
			--SE ACTUALIZA LA DIRECCION (CALLE) DEL CLIENTE TRANSFER.
			UPDATE "informix".tf_direcciones 
			SET calle = pDescCalle
			WHERE cuenta_tf = pCuentaTf
				AND numcte_tf = pNumCteTransf;	
			
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;			
		END IF;
		
		IF NVL(pNumExterno,"") <> "" AND cBanDirecTf = "0" THEN 		   
			--SE ACTUALIZA LA DIRECCION (NUMERO EXTERNO) DEL CLIENTE TRANSFER.
			UPDATE "informix".tf_direcciones 
			SET num_externo = pNumExterno
			WHERE cuenta_tf = pCuentaTf
				AND numcte_tf = pNumCteTransf;	
			
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;
		END IF;
		
		IF NVL(pNumInterno,"") <> "" AND cBanDirecTf = "0" THEN 		   
			--SE ACTUALIZA LA DIRECCION (NUMERO INTERNO) DEL CLIENTE TRANSFER.
			UPDATE "informix".tf_direcciones 
			SET num_interno = pNumInterno
			WHERE cuenta_tf = pCuentaTf
				AND numcte_tf = pNumCteTransf;	
			
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;
		END IF;
		
		IF NVL(pNumDepto,"") <> "" AND cBanDirecTf = "0" THEN 		   
			--SE ACTUALIZA LA DIRECCION (NUMERO DE DEPARTAMENTO) DEL CLIENTE TRANSFER.
			UPDATE "informix".tf_direcciones 
			SET num_depto = pNumDepto
			WHERE cuenta_tf = pCuentaTf
				AND numcte_tf = pNumCteTransf;	
			
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;
		END IF;
		
		IF NVL(pCodPostalTf,0) <> 0 AND cBanDirecTf = "0" THEN 		   
			--SE ACTUALIZA LA DIRECCION (CODIGO POSTAL) DEL CLIENTE TRANSFER.
			UPDATE "informix".tf_direcciones 
			SET cod_postal = pCodPostalTf
			WHERE cuenta_tf = pCuentaTf
				AND numcte_tf = pNumCteTransf;	
				
			-- SE VALIDA SI SE HACE LA ACTUALIZACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN	
				--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO.				
				LET cCodRet = "000007";
				LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
				ROLLBACK WORK;
				IF (cBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, cMensaje;			
			END IF;			
		END IF;
		
		-- SI SE ACTUALIZARON LOS DATOS, SE ACTUALIZA LA FECHA DE MODIFICACION DSB 05/08/2014
		IF cCodRet = "000000" THEN
			UPDATE "informix".tf_maecte SET fec_modific = CURRENT 
			WHERE empresa = pEmpresa AND numcte_tf = pNumCteTransf AND cuenta_tf = pCuentaTf AND telefono = pNumTelefono;
		END IF;

------------------------------ CLIENTE BANCOPPEL -----------------------------------------
		IF pTipoCliente = 2 THEN 				
			-- SE VALIDA QUE POR LO MENOS UN CAMPO SE HALLA MODIFICADO.		
			IF NVL(pDescCalle,"") <> "" OR NVL(pDescColonia,"") <> "" OR NVL(pNumMunicipio,"") <> "" OR NVL(pEntreCallesDir,"") <> "" OR 
			   NVL(pNumPaisDir,"") <> "" OR NVL(pNumEntidadDir,"") <> "" OR NVL(pNumLocalidadDir,"") <> "" OR NVL(pCodPostalDir,"") <> "" OR
			   NVL(pNumCiudadCoppelDir,0) <> 0 OR NVL(pNumExterno,"") <> "" OR NVL(pNumInterno,"") <> "" OR NVL(pNumDepto,"") <> "" OR 
			   NVL(pNumCalleDir,0) <> 0 OR NVL(pNumColoniaDir,0) <> 0 THEN 
			   
				--SE ACTUALIZA LA DIRECCION DEL CLIENTE BANCOPPEL.
				EXECUTE PROCEDURE bdinteg:"informix".direcciones(
					pEmpresa,"A",pNumCteBco,NULL,"1",pDescCalle,pDescColonia,
					pNumMunicipio,pEntreCallesDir,pNumPaisDir,
					pNumEntidadDir,pNumLocalidadDir,pCodPostalDir,
					"", "", "", "", "", "", "", "", "", "",
					pNumCiudadCoppelDir,pNumExterno,pNumInterno,
					pNumDepto,pNumCalleDir,pNumColoniaDir,
					"", "", 0, 0, 0, 0, 0, 0, 0, "",
					pUserInsert,pFechaInsertDir,pSucursalDir,0)
				 
				INTO cCodRetDirec;
				IF CAST(cCodRetDirec AS INT) <> 0 THEN				
					LET cCodRet = "000008";
					LET cMensaje = "OCURRIO UN ERROR EN EL PROCEDIMIENTO bdinteg:direcciones";
					ROLLBACK WORK;
					IF (cBegin = "S") THEN
						BEGIN WORK;
					END IF;
					RETURN cCodRet, cMensaje;			
				END IF;
			END IF; 
				
			--SE VALIDA SI EL CORREO VIENE CON VALOR PARA HACER SUS ACTUALIZACIONES CORRESPONDIENTES.
			IF NVL(pDescCorreo,"") <> "" THEN 
				
				IF NVL(pTipoCorreoTf,0) = 0 OR NVL(pCanalTf,0) = 0 OR NVL(pUserInsert,"") = ""THEN							   					
					LET cCodRet = "000009";
					LET cMensaje = "PARAMETROS INVALIDOS PARA EJECUTAR EL PROCEDIMIENTO bdinteg:sp_registra_correos";
					ROLLBACK WORK;
					IF (cBegin = "S") THEN
						BEGIN WORK;
					END IF;
					RETURN cCodRet, cMensaje;	
				ELSE			
					--REALIZA LAS ACTUALIZACIONES CORRESPONDIENTES DEL CORREO DEL CLIENTE BANCOPPEL.
					EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos(pEmpresa,pNumCteBco,pDescCorreo,pTipoCorreoTf,pCanalTf,pUserInsert)			
					INTO cCodRetCorreo;
	
					IF CAST(cCodRetCorreo AS INT) <> 0 THEN						
						LET cCodRet = "000010";
						LET cMensaje = "OCURRIO UN ERROR EN EL PROCEDIMIENTO bdinteg:sp_registra_correos";
						ROLLBACK WORK;
						IF (cBegin = "S") THEN
							BEGIN WORK;
						END IF;
						RETURN cCodRet, cMensaje;									
					END IF;					
				END IF;
				
			END IF;
			
			-- SE ACTUALIZA EL CODIGO DE IDENTIFICACION Y NUMERO DE IDENTIFICACION DSB 05/08/2014
			IF NVL(pCodIdentifiTf,"") <> "" OR NVL(pNumIdentiTf,"") <> "" THEN
				UPDATE bdinteg:"informix".si_ctepf 
					SET codidentifi = TRIM(pCodIdentifiTf), numidentifi = TRIM(pNumIdentiTf)
				WHERE empresa = pEmpresa AND numcte = pNumCteBco;
				
				-- SE VALIDA SI SE HACE LA ACTUALIZACION
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					--SI NO SE REALIZA LA ACTUALIZACION SE EJECUTA EL ROLLBACK PARA REESTABLECER LO REALIZADO
					LET cCodRet = "000007";
					LET cMensaje = "OCURRIO UN ERROR EN LA ACTUALIZACION DE LOS DATOS, SE REESTABLECE LA INFORMACION";
					ROLLBACK WORK;
					IF (cBegin = "S") THEN
						BEGIN WORK;
					END IF;
					RETURN cCodRet, cMensaje;
				END IF;
			END IF;
			
		END IF;
		
	COMMIT WORK;
	
	IF (cBegin = "S") THEN
	   BEGIN WORK;
	END IF;
	
	RETURN cCodRet, cMensaje;	
	
END PROCEDURE
DOCUMENT
"AUTOR: 93928475 - Guadalupe Payan Camacho",
"FOLIO: 1440",
"DESCRIPCION: Realiza las actualizaciones correspondientes de los datos del cliente transfer.",
"FECHA: 20/06/2014",
"SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento",
"RQI 63 050 Procesos Transfer Sucursal v1 4.pdf",
"BD: BDITRANSFER",
"-----------------------------------------------------------------------------------------------",
"AUTOR: 95337997 - Carlos Aguirre Vega",
"FOLIO: 1440",
"DESCRIPCION: Se quitan los filtros de numcte banco que se utilizan en el flujo que transfer.",
"Realiza el UPDATE para actualizar al campo fec_modific = CURRENT cuando se actualizen los datos correctamente.",
"Se actualiza en la bdinteg:si_ctepf los campos codidentifi y numidentifi.",
"FECHA: 05/08/2014",
"SUSTENTO: Se atienden las peticiones del archivo Evidencias y defectos_v1.xlsx",
"RQI 63 050 Procesos Transfer Sucursal v1 4.pdf",
"BD: BDITRANSFER";

CREATE PROCEDURE "informix".sp_ctes_modif(pNumCta 		  	CHAR(11),
										  pNumCtaCbe 	  	CHAR(18),
										  pTelefono 	  	CHAR(13), 
										  --pNumCteTransfer 	CHAR(20),
										  pEsRegistro 	  	CHAR(1),
										  pNombreServ 		CHAR(128),
										  pIdentificadorBanco 	CHAR(3),
										  pMetodoAcceso 	CHAR(3),
										  pApellidoPaterno 	CHAR(128),
										  pApellidoMaterno 	CHAR(128),
										  pNombre 			CHAR(64),
										  pFechaNac 		CHAR (15),
										  pCalle 			CHAR(100),
										  pNumExterno	    CHAR(15),
										  pIdentificacion 	CHAR(1),
										  pNumIdentificacion CHAR(15),
										  pFechaSistema		DATE)
RETURNING CHAR(6) AS ReturnCode_2,
		CHAR(256) AS ErrorDescription_2,
		CHAR (12) AS CustomerNumber_2;
	
---DECLARACION DE VARIABLES
DEFINE iSqlErr      		INTEGER;
DEFINE cPCodRet             CHAR(6);
DEFINE cCodRet      		CHAR(3);
DEFINE cCodRetSp            CHAR(3);
DEFINE cError               CHAR(3);
DEFINE cDescripcion         CHAR(256);
DEFINE cApell_Paterno 		CHAR(26);
DEFINE cApell_Materno 		CHAR(26);
DEFINE cNombre1 			CHAR(26);
DEFINE cNombre2 			CHAR(26);
DEFINE dFecha_Nac 			DATE;
DEFINE cCalle 				CHAR(100);
DEFINE cNum_Exterior 		CHAR(15);
DEFINE cNum_Interno 		CHAR(15);
DEFINE cNum_Depto 			CHAR(15);
DEFINE cColonia 			CHAR(100);
DEFINE cMunicipio 			CHAR(50);
DEFINE cEstado 				CHAR(100);
DEFINE cCod_Postal 			CHAR(5);
DEFINE cMet_Notificacion 	CHAR(15);
DEFINE cCorreo 				CHAR(50);
DEFINE cId_Us_Captura 		CHAR(8);
DEFINE cNumeroCta           CHAR(20);
DEFINE cCuenta_Clabe        CHAR(18);
DEFINE cNum_cliente_tf      CHAR(20);
DEFINE cCalle_Dir 	    	CHAR(100);
DEFINE cNum_Externo_Dir 	CHAR(15);
DEFINE cNum_Interno_Dir 	CHAR(15);
DEFINE cNum_Depto_Dir   	CHAR(15);
DEFINE cColonia_Dir     	CHAR(100);
DEFINE cMunicipio_Dir   	CHAR(50);
DEFINE cEstado_Dir  		CHAR(100);
DEFINE cCod_postal_Dir  	CHAR(5);
DEFINE cEmpresa         	CHAR(3);
DEFINE cNumCte           	CHAR(9);
DEFINE cNombre1_Ban      	CHAR(26);
DEFINE cNombre2_Ban      	CHAR(26);
DEFINE cApell_Pat        	CHAR(26);
DEFINE cApell_mat        	CHAR(26);
DEFINE dFecha_Nac_Ban    	DATE;
DEFINE cTelefono_Tele    	CHAR(13);
DEFINE cCorreoTienda     	CHAR(50);
DEFINE cTelefonoAnterior    CHAR(13);
DEFINE iSecuencia           INTEGER;
DEFINE cIdentificacion		CHAR(50);
DEFINE cNum_Identificacion	CHAR(50);
DEFINE cNum_tarjeta			CHAR(16);
DEFINE cFec_cancelac		DATE;
DEFINE cFec_modific			DATE;
DEFINE cMSISDNrecepcion		CHAR(12);
DEFINE cTelefonica           CHAR(4);
DEFINE cTipoAsociacion       CHAR(1);

---INICIALIZACION DE VARIABLES
LET iSqlErr      	    = 0;
LET cPCodRet            = '0';
LET cCodRet       		= '0';
LET cCodRetSp           = '0';
LET cError              = '0';
LET cDescripcion        = '';
LET cApell_Paterno 		= '';
LET cApell_Materno 		= '';
LET cNombre1 			= '';
LET cNombre2 			= '';
LET dFecha_Nac 			= DATE(1);
LET cCalle 				= '';
LET cNum_Exterior 		= '';
LET cNum_Interno 		= '';
LET cNum_Depto 			= '';
LET cColonia 			= '';
LET cMunicipio 			= '';
LET cEstado 			= '';
LET cCod_Postal 		= '';
LET cMet_Notificacion 	= '';
LET cCorreo 			= '';
LET cId_Us_Captura 		= 'CAT-Trf';
LET cNumeroCta          = '';
LET cCuenta_Clabe       = '';
LET cNum_cliente_tf     = '';
LET cCalle_Dir          = '';
LET cNum_Externo_Dir    = '';
LET cNum_Interno_Dir    = '';
LET cNum_Depto_Dir      = '';
LET cColonia_Dir        = '';
LET cMunicipio_Dir      = '';
LET cEstado_Dir  	    = '';
LET cCod_postal_Dir     = '';
LET cEmpresa            = '';
LET cNumCte             = '';
LET cNombre1_Ban        = '';
LET cNombre2_Ban        = '';
LET cApell_Pat          = '';
LET cApell_mat          = '';
LET dFecha_Nac_Ban      = DATE(1);
LET cTelefono_Tele      = '';
LET cCorreoTienda       = '';
LET cTelefonoAnterior   = '';
LET iSecuencia          = 0;
LET cIdentificacion		= '';
LET cNum_Identificacion	= 0;
LET cNum_tarjeta		= 0;
LET	cFec_cancelac		='';
LET	cFec_modific			='';
LET cMSISDNrecepcion = '';
LET cTelefonica    = ''; 
LET cTipoAsociacion = '';

--SET DEBUG FILE TO '/informix/andrescrespo/sp_ctes_modif.out';
--tRACE ON;

--se identifica errores de sql	
BEGIN
    ON EXCEPTION 
	SET iSqlErr
	IF 	iSqlErr <> 0 THEN
		LET cCodRet = '950';
		LET cPCodRet = iSqlErr;
		
		--consulta el código de retornos en el catálogo
		SELECT descripcion 
		INTO  cDescripcion
		FROM  "informix".tf_codret 
		WHERE cod_error = cCodRet;
		
		--asigna una secuencia al en la tabla online
			LET pNumCta=pNumCta;
			LET pTelefono=pTelefono;
		SELECT MAX(id)
		INTO iSecuencia
		FROM "informix".tf_cte_online
		WHERE cuenta_tf = TRIM(pNumCta)
		AND telefono = TRIM(pTelefono);
		--AND id_persona = TRIM(pNumCteTransfer);

		--actualiza el codigo de error de la tabla online
		UPDATE "informix".tf_cte_online 
		SET cod_error = TRIM(cCodRet), desc_error = TRIM(cDescripcion)  
		WHERE cuenta_tf = TRIM(pNumCta)
		AND telefono = TRIM(pTelefono)
		AND id = iSecuencia;		
		--AND id_persona = TRIM(pNumCteTransfer)
		--regresa el codigo de error de sql, descripción y el número de cliente Transfer
		RETURN trim(cPCodRet),trim(cDescripcion),trim(cNum_cliente_tf);
		
	END IF
END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--al no detectar erro de sql, valida que no esten vacios los siguientes campos:
	IF TRIM(NVL(pNumCta,'')) <> '' 
		AND  TRIM(NVL(pNumCtaCbe,'')) <> '' 
		AND TRIM(NVL(pTelefono,'')) <> '' 
		AND TRIM(NVL(pEsRegistro,'')) <> '' 
		--AND NVL(pNumCteTransfer,'') <> ''
		AND TRIM(NVL(pNombreServ,''))<>''
		AND TRIM(NVL(pIdentificadorBanco,''))<>''
		AND TRIM(NVL(pMetodoAcceso,''))<>''
		AND TRIM(NVL(pApellidoPaterno,''))<>''
		AND TRIM(NVL(pApellidoMaterno,''))<>''
		AND TRIM(NVL(pNombre,''))<>''
		AND TRIM(NVL(pFechaNac,''))<>''
		AND TRIM(NVL(pCalle,''))<>''
		--AND TRIM(NVL(pNumExterno,''))<>''
		THEN
			
			
		--le asigna una secuencia al registro
		SELECT MAX(id)
		INTO iSecuencia
		FROM "informix".tf_cte_online
		WHERE cuenta_tf = TRIM(pNumCta)
		AND telefono = TRIM(pTelefono);
		--AND id_persona = TRIM(pNumCteTransfer);

             
		--si todos los campos estan informados, inserta cada valor en la tabla online
		SELECT upper(apell_paterno),upper(apell_materno),upper(nombre1),upper(nombre2),fecha_nac,calle,num_exterior,num_interno,num_depto,colonia,municipio,estado,cod_postal,correo,met_notificacion,identificacion,num_identificacion,num_tarjeta,MSISDNrecepcion,Telefonica,TipoAsociacion
		INTO cApell_Paterno,cApell_Materno,cNombre1,cNombre2,dFecha_Nac,cCalle,cNum_Exterior,cNum_Interno,cNum_Depto,cColonia,cMunicipio,cEstado,cCod_Postal,cCorreo,cMet_Notificacion,cIdentificacion,cNum_Identificacion,cNum_tarjeta,cMSISDNrecepcion,cTelefonica,cTipoAsociacion
		FROM "informix".tf_cte_online
		WHERE cuenta_tf  = pNumCta
		AND   cta_clabe  = pNumCtaCbe
		AND   telefono   = pTelefono
		AND   esregistro = pEsRegistro
		--AND   id_persona = pNumCteTransfer
		AND   fec_sistema= pFechaSistema
		and id=iSecuencia;
		
		

		-- compara si existe en la tabla tf_maecte 
		SELECT cuenta_tf,cta_clabe, telefono
		INTO cNumeroCta,cCuenta_Clabe, cTelefonoAnterior
		FROM "informix".tf_maecte
		WHERE cuenta_tf   = TRIM(pNumCta)
		AND   cta_clabe   = TRIM(pNumCtaCbe);
		--AND   numcte_tf   = TRIM(pNumCteTransfer);
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
		
			--si no existe, identifica codigo de error en el catálogo
			SELECT cod_error,descripcion
			INTO   cError,cDescripcion
			FROM "informix".tf_codret
			WHERE cod_error = '100';
			
			--actualiza el error de respuesta en la tabla online
			UPDATE "informix".tf_cte_online 
			SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion)
			WHERE cuenta_tf = TRIM(pNumCta) 
			AND telefono = TRIM(pTelefono) 
			--AND id_persona = TRIM(pNumCteTransfer)
			AND id = iSecuencia;
			LET cPCodRet = cError;
		ELSE		
			--si si existe en la tabla maestra, actualiza los siguientes campos
			UPDATE "informix".tf_maecte 
			SET met_notificacion = TRIM(cMet_Notificacion),correo = TRIM(cCorreo),telefono = TRIM(pTelefono),fec_modific = CURRENT 
			WHERE cuenta_tf = TRIM(pNumCta) 
			AND cta_clabe = TRIM(pNumCtaCbe) 
			--AND numcte_tf = TRIM(pNumCteTransfer) 
			AND telefono = TRIM(cTelefonoAnterior);
			
			--identifica al cliente en la tabla direcciones y realiza actualizaciones en los campos:
			SELECT	calle,num_externo,num_interno,num_depto,colonia,municipio,estado,cod_postal
			INTO  cCalle_Dir,cNum_Externo_Dir,cNum_Interno_Dir,cNum_Depto_Dir,cColonia_Dir,cMunicipio_Dir,cEstado_Dir,cCod_postal_Dir
			FROM "informix".tf_direcciones
			WHERE cuenta_tf = pNumCta
			AND   calle = cCalle
			AND   num_externo = cNum_Exterior 
			AND   num_interno = cNum_Interno
			AND   num_depto  = cNum_Depto
			AND   colonia    =   cColonia
			AND   municipio  = cMunicipio
			AND   estado     =  cEstado
			AND   cod_postal = cCod_Postal;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				
				--identifica al cliente en la tabla direcciones y realiza actualizaciones en los campos:
				UPDATE "informix".tf_direcciones 
				SET calle = TRIM(cCalle), num_externo = TRIM(cNum_Exterior), num_interno = TRIM(cNum_Interno), num_depto = TRIM(cNum_Depto), colonia = TRIM(cColonia), municipio  = TRIM(cMunicipio), estado =  TRIM(cEstado), cod_postal = TRIM(cCod_Postal)
				WHERE cuenta_tf = TRIM(pNumCta); 
				--AND numcte_tf = TRIM(pNumCteTransfer);
				
				--identificar empresa "Bancoppel" 001
				SELECT empresa 
				INTO cEmpresa
				FROM bdinteg:"informix".si_empresas;
				
				--busca en las tablas de clientes Bancoppel y si lo encuentra realiza la actualizaciónd de los siguientes campos:
				SELECT a.numcte,a.nombre1,a.nombre2,a.apell_paterno,a.apell_materno,b.fecha_nac 
				INTO cNumCte,cNombre1_Ban,cNombre2_Ban,cApell_Pat,cApell_mat,dFecha_Nac_Ban
				FROM bdinteg:"informix".si_cliente a,
					 bdinteg:"informix". si_ctepf b
				WHERE a.empresa = cEmpresa 
				AND a.nombre1 = TRIM(cNombre1)
				AND a.nombre2 = TRIM(cNombre2)
				AND a.apell_paterno = TRIM(cApell_Paterno)
				AND a.apell_materno = TRIM(cApell_Materno)
				AND b.numcte = a.numcte
				AND b.fecha_nac = dFecha_Nac;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				
				    --identifica el error en el catálogo
					SELECT cod_error,descripcion
					INTO   cError,cDescripcion
					FROM "informix".tf_codret
					WHERE cod_error = '0';
					--actualiza el codigo de retorno en la tabla online
					UPDATE "informix".tf_cte_online 
					SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion)
					WHERE cuenta_tf = TRIM(pNumCta) 
					AND telefono = TRIM(pTelefono) 
					--AND id_persona = TRIM(pNumCteTransfer)
					AND id = iSecuencia;
				
				ELSE
					--busca por empresa y número de cliente bancoppel e inserta el teléfono celular, activo
					SELECT telefono
					INTO cTelefono_Tele 
					FROM bdinteg:"informix".si_telefonos
					WHERE empresa= cEmpresa 
					AND numcte = cNumCte
					AND tipo_tel = 2 
					AND status_tel = 'A';
					
					--si detecta que esta vacio el teléfono
					IF TRIM(NVL(cTelefono_Tele,'')) <>  TRIM(pTelefono) THEN
						--Registrar Telefono con el proceso ya existente
						EXECUTE PROCEDURE bdinteg:"informix".sp_registra_telefonos(cEmpresa, cNumCte, pTelefono , 2, '', 1,  1, cId_Us_Captura)
						INTO cCodRetSp;
						IF TRIM(NVL(cCodRetSp,'')) = '0' THEN
							
							--inserta correo activo del cliente bancoppel
							SELECT correo_elec 
							INTO cCorreoTienda
							FROM bdinteg:"informix".si_correos  
							WHERE empresa = cEmpresa 
							AND numcte = cNumCte 
							AND status_correo  = 'A';
							
							--esta vacio el correo
							IF TRIM(NVL(cCorreoTienda,'')) <> TRIM(NVL(cCorreo,'')) THEN
								
								--Registra correo con el proceso existente
								EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos(cEmpresa, cNumCte, cCorreo,1,1, cId_Us_Captura)
								INTO cCodRetSp;
								--si es exitoso
								IF TRIM(NVL(cCodRetSp,'')) = '0' THEN
									--identifica el error en el catálogo
									SELECT cod_error,descripcion
									INTO cError,cDescripcion
									FROM "informix".tf_codret
									WHERE cod_error = '0';
									
									--actualiza error en la tabla online
									UPDATE "informix".tf_cte_online 
									SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion)
									WHERE cuenta_tf = TRIM(pNumCta) 
									AND telefono = TRIM(pTelefono) 
									--AND id_persona = TRIM(pNumCteTransfer)
									AND id = iSecuencia;
																					
								ELSE
									--identifica error en el catálogo
									SELECT cod_error,descripcion
									INTO cError,cDescripcion
									FROM "informix".tf_codret
									WHERE cod_error = '954';
									
									--actualiza la tabla online con el codigo de retorno
									UPDATE "informix".tf_cte_online 
									SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
									WHERE  cuenta_tf = TRIM(pNumCta) 
									AND telefono = TRIM(pTelefono) 
									--AND id_persona = TRIM(pNumCteTransfer)
									AND id = iSecuencia;
									
									LET cPCodRet = cError;
								
								END IF;
							ELSE
								--si se actualizo exitosamente se consulta el catálogo de errores
								SELECT cod_error,descripcion
								INTO cError,cDescripcion
								FROM "informix".tf_codret
								WHERE cod_error = '0';

								--actualiza la tabla online el codigo de error
								UPDATE "informix".tf_cte_online 
								SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
								WHERE  cuenta_tf = TRIM(pNumCta) 
								AND telefono = TRIM(pTelefono) 
								--AND id_persona = TRIM(pNumCteTransfer)
								AND id = iSecuencia;
				
					END IF;
						ELSE
							SELECT cod_error,descripcion
							INTO cError,cDescripcion
							FROM "informix".tf_codret
							WHERE cod_error = '953';
							
							UPDATE "informix".tf_cte_online 
							SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
							WHERE  cuenta_tf = TRIM(pNumCta) 
							AND telefono = TRIM(pTelefono) 
							AND id_persona = TRIM(pNumCteTransfer)
							AND id = iSecuencia;
							
							LET cPCodRet = cError;
							
						END IF;
						
					ELSE
						--inserta correo activo
						SELECT correo_elec 
						INTO cCorreoTienda
						FROM bdinteg:"informix".si_correos 
						WHERE empresa = cEmpresa 
						AND numcte = cNumCte 
						AND status_correo  = 'A';
						--si esta vacio
						IF TRIM(NVL(cCorreoTienda,'')) <> TRIM(NVL(cCorreo,'')) THEN
							--Registra correo por el proceso existente
							EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos(cEmpresa, cNumCte, cCorreo,1,1, cId_Us_Captura)
							INTO cCodRetSp;
							--identifica el codigo de error en el catálogo
							IF TRIM(NVL(cCodRetSp,'')) = '0' THEN
								SELECT cod_error,descripcion
								INTO cError,cDescripcion
								FROM "informix".tf_codret
								WHERE cod_error = '0';					
								
								--actualiza el error en la tabla online
								UPDATE "informix".tf_cte_online 
								SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
								WHERE  cuenta_tf = TRIM(pNumCta) 
								AND telefono = TRIM(pTelefono) 
								--AND id_persona = TRIM(pNumCteTransfer)
								AND id = iSecuencia;
								
							ELSE
								--si no es exitoso identifica el error en el catálogo
								SELECT cod_error,descripcion
								INTO cError,cDescripcion
								FROM "informix".tf_codret
								WHERE cod_error = '954';
								
								--actualiza el error en la tabla online
								UPDATE "informix".tf_cte_online 
								SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
								WHERE  cuenta_tf = TRIM(pNumCta) 
								AND telefono = TRIM(pTelefono) 
								--AND id_persona = TRIM(pNumCteTransfer)
								AND id = iSecuencia;
								
								LET cPCodRet = cError;
							
							END IF;
						ELSE
							--identifica error en el catálogo
							SELECT cod_error,descripcion
							INTO cError,cDescripcion
							FROM "informix".tf_codret
							WHERE cod_error = '0';

							--actualiza erroe en la tabla online
							UPDATE "informix".tf_cte_online SET cod_error = cError,desc_error = cDescripcion WHERE  cuenta_tf = pNumCta AND telefono = pTelefono AND id_persona = pNumCteTransfer;UPDATE bditransfer:"informix".tf_cte_online 
							SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
							WHERE  cuenta_tf = TRIM(pNumCta) 
							AND telefono = TRIM(pTelefono) 
							--AND id_persona = TRIM(pNumCteTransfer)
							AND id = iSecuencia;
							
						END IF;				
					END IF;	
				END IF;
			ELSE -------Si la direccion es la misma--------
				----FLUJO DE VALIDACION DE BANCOPPEL
				SELECT empresa 
				INTO cEmpresa
				FROM bdinteg:"informix".si_empresas;
				
				SELECT a.numcte,a.nombre1,a.nombre2,a.apell_paterno,a.apell_materno,b.fecha_nac 
				INTO cNumCte,cNombre1_Ban,cNombre2_Ban,cApell_Pat,cApell_mat,dFecha_Nac_Ban
				FROM bdinteg:"informix".si_cliente a,
					 bdinteg:"informix". si_ctepf b
				WHERE a.empresa = cEmpresa 
				AND a.nombre1 = TRIM(cNombre1)
				AND a.nombre2 = TRIM(cNombre2)
				AND a.apell_paterno = TRIM(cApell_Paterno)
				AND a.apell_materno = TRIM(cApell_Materno)
				AND b.numcte = a.numcte
				AND b.fecha_nac = dFecha_Nac;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				
					SELECT cod_error,descripcion
					INTO   cError,cDescripcion
					FROM "informix".tf_codret
					WHERE cod_error = '0';
					
					UPDATE "informix".tf_cte_online 
					SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
					WHERE  cuenta_tf = TRIM(pNumCta) 
					AND telefono = TRIM(pTelefono) 
					--AND id_persona = TRIM(pNumCteTransfer)
					AND id = iSecuencia;
					
				ELSE
					SELECT telefono
					INTO cTelefono_Tele 
					FROM bdinteg:"informix".si_telefonos
					WHERE empresa= cEmpresa 
					AND numcte = cNumCte
					AND tipo_tel = 2 
					AND status_tel =  'A';
					
					IF TRIM(NVL(cTelefono_Tele,'')) <>  TRIM(pTelefono) THEN
					 --Registrar Telefono
						EXECUTE PROCEDURE bdinteg:"informix".sp_registra_telefonos(cEmpresa, cNumCte, pTelefono , 2, '', 1,  1, cId_Us_Captura)
						INTO cCodRetSp;
						IF TRIM(NVL(cCodRetSp,'')) = '0' THEN
							
							SELECT correo_elec 
							INTO cCorreoTienda
							FROM bdinteg:"informix".si_correos 
							WHERE empresa = cEmpresa 
							AND numcte = cNumCte 
							AND status_correo  = 'A';
							
							IF TRIM(NVL(cCorreoTienda,'')) <> TRIM(NVL(cCorreo,'')) THEN
								--Registra correo
								EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos(cEmpresa, cNumCte, cCorreo,1,1, cId_Us_Captura)
								INTO cCodRetSp;
								
								IF TRIM(NVL(cCodRetSp,'')) = '0' THEN
									SELECT cod_error,descripcion
									INTO cError,cDescripcion
									FROM "informix".tf_codret
									WHERE cod_error = '0';
									
									UPDATE "informix".tf_cte_online 
									SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
									WHERE  cuenta_tf = TRIM(pNumCta) 
									AND telefono = TRIM(pTelefono) 
									--AND id_persona = TRIM(pNumCteTransfer)
									AND id = iSecuencia;

									
								ELSE
									SELECT cod_error,descripcion
									INTO cError,cDescripcion
									FROM "informix".tf_codret
									WHERE cod_error = '954';
									
									UPDATE "informix".tf_cte_online 
									SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
									WHERE  cuenta_tf = TRIM(pNumCta) 
									AND telefono = TRIM(pTelefono) 
									--AND id_persona = TRIM(pNumCteTransfer)
									AND id = iSecuencia;
								
									LET cPCodRet = cError;
								
								END IF;
							ELSE
								SELECT cod_error,descripcion
								INTO cError,cDescripcion
								FROM "informix".tf_codret
								WHERE cod_error = '0';

								UPDATE "informix".tf_cte_online 
								SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
								WHERE  cuenta_tf = TRIM(pNumCta) 
								AND telefono = TRIM(pTelefono) 
								--AND id_persona = TRIM(pNumCteTransfer)
								AND id = iSecuencia;
								
							END IF;
						ELSE
							SELECT cod_error,descripcion
							INTO cError,cDescripcion
							FROM "informix".tf_codret
							WHERE cod_error = '953';
							
							UPDATE "informix".tf_cte_online 
							SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
							WHERE  cuenta_tf = TRIM(pNumCta) 
							AND telefono = TRIM(pTelefono) 
							--AND id_persona = TRIM(pNumCteTransfer)
							AND id = iSecuencia;
							
							LET cPCodRet = cError;
													
						END IF;
					ELSE
						--FLUJO DE VALIDACION DE CORREO SI SON IGUALES LOS TELEFONOS
						SELECT correo_elec 
						INTO cCorreoTienda
						FROM bdinteg:"informix".si_correos 
						WHERE empresa = cEmpresa 
						AND numcte = cNumCte 
						AND status_correo  = 'A';
						
						IF TRIM(NVL(cCorreoTienda,'')) <> TRIM(NVL(cCorreo,'')) THEN
							--Registra correo
							EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos(cEmpresa, cNumCte, cCorreo,1,1, cId_Us_Captura)
							INTO cCodRetSp;
							
							IF TRIM(NVL(cCodRetSp,'')) = '0' THEN
								SELECT cod_error,descripcion
								INTO cError,cDescripcion
								FROM "informix".tf_codret
								WHERE cod_error = '0';					
								
								UPDATE "informix".tf_cte_online 
								SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
								WHERE  cuenta_tf = TRIM(pNumCta) 
								AND telefono = TRIM(pTelefono) 
								--AND id_persona = TRIM(pNumCteTransfer)
								AND id = iSecuencia;
								
							ELSE
								SELECT cod_error,descripcion
								INTO cError,cDescripcion
								FROM "informix".tf_codret
								WHERE cod_error = '954';
								
								UPDATE "informix".tf_cte_online 
								SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
								WHERE  cuenta_tf = TRIM(pNumCta) 
								AND telefono = TRIM(pTelefono) 
								--AND id_persona = TRIM(pNumCteTransfer)
								AND id = iSecuencia;
							
								LET cPCodRet = cError;
							
							END IF;
						ELSE
							SELECT cod_error,descripcion
							INTO cError,cDescripcion
							FROM "informix".tf_codret
							WHERE cod_error = '0';

							UPDATE "informix".tf_cte_online 
							SET cod_error = TRIM(cError),desc_error = TRIM(cDescripcion) 
							WHERE  cuenta_tf = TRIM(pNumCta) 
							AND telefono = TRIM(pTelefono) 
							--AND id_persona = TRIM(pNumCteTransfer)
							AND id = iSecuencia;
							
						END IF;				
					END IF;	
				END IF;
			END IF;	
		END IF;
	ELSE 
		LET cPCodRet = '600';
		SELECT descripcion 
		INTO  cDescripcion
		FROM  "informix".tf_codret 
		WHERE cod_error = cPCodRet;
		
		SELECT MAX(id)
		INTO iSecuencia
		FROM "informix".tf_cte_online
		WHERE cuenta_tf = pNumCta
		AND telefono = pTelefono;
		
		UPDATE "informix".tf_cte_online 
		SET cod_error = cPCodRet, desc_error = cDescripcion  
		WHERE cuenta_tf = pNumCta
		AND telefono = pTelefono
		AND id = iSecuencia;
		
		SELECT numcte_tf
		INTO cNum_cliente_tf
		FROM "informix".tf_maecte
		WHERE cuenta_tf = pNumCta;
	END IF;
	
		SELECT numcte_tf
		INTO cNum_cliente_tf
		FROM "informix".tf_maecte
		WHERE cuenta_tf = pNumCta;

	RETURN trim(cPCodRet),trim(cDescripcion),trim(cNum_cliente_tf);
	
END;
END PROCEDURE
DOCUMENT
'Folio:1589',
'Autor:95594213 Leonardo Plata',
'Fecha:10-Marzo-2014',
'Modificación: Se crea sp con el objetivo de generar la modificación de un cliente Transfer',
'Sustento: RQI 63 049 Procesos Transfer Central.pdf ',
'Solicita: Manuel Osuna',
'Folio:1604',
'Modifico:Felipe Urias',
'Fecha:22/04/2014',
'Modificación: se agrega consulta de maxima secuencia para evitar las actualizacion a mas de un registro de tf_cte_online ',
'Sustento: Evidencias Ciclo 1.ods',
'Solicita: Gabriela Gudiño',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_guarda_renapo_curp( 	pcCodigoError        CHAR(4),
													pcTipoError		     CHAR(2),       
													pcErrorDescripcion   CHAR(100),     
													pcStatusOpe          CHAR(8),       
													pcSessionIDRenapo	 CHAR(100),     
													pcCurp               CHAR(18),
													pcApePat             CHAR(50),        
													pcApeMat             CHAR(50),      
													pcNombre             CHAR(50),      
													pcSexo               CHAR(1),       
													pcFecNac        	 CHAR(10),--<fechNac>18/10/1989</fechNac>
													pcNacionalidad       CHAR(5),      
													pcdocProbatorio      CHAR(1),    
													pcAnioReg            CHAR(4),	    
													pcFoja               CHAR(10),
													pctomo		         CHAR(10),      
													pcLibro              CHAR(10),      
													pcNumActa            CHAR(10), 	    
													pcCrip               CHAR(15),	
													pcNumEntidadReg	   	 CHAR(5),       
													pcCveMunicipioReg    CHAR(10),
													pcNumRegExtranjeros	 CHAR(10),
													pcFolioCarta	 	 CHAR(20),
													pcCveEntidadNac      CHAR(5),      
													pcCveEntidadEmisora  CHAR(8),
													pcStatusCurp		 CHAR(2))
												

RETURNING
CHAR(4) 	AS cCodigoError,   
CHAR(2)  	AS cTipoError, 
CHAR(100) 	AS cErrorDescription,     
CHAR(8)  	AS cStatusOpe, 
CHAR(100) 	AS cSessionIDRenapo, 
CHAR(18) 	AS cCurp,               
CHAR(50) 	AS cApellidoPaterno,             
CHAR(50) 	AS cApellidoMaterno,             
CHAR(50) 	AS cNombre,             
CHAR(1)  	AS cSexo,               
CHAR(10) 	AS cFecNac, 
CHAR(5)  	AS cCveEntidadNac,       	 
CHAR(5)  	AS cNacionalidad,   
CHAR(4) 	AS cdocProbatorio,     
CHAR(10) 	AS cAnioReg,           
CHAR(10) 	AS cFoja,               
CHAR(10) 	AS ctomo,		         
CHAR(10) 	AS cLibro,             
CHAR(15) 	AS cNumActa,           
CHAR(5) 	AS cCrip,              
CHAR(10) 	AS cNumEntidadReg,  
CHAR(10) 	AS cCveMunicipioReg ,  
CHAR(20) 	AS cNumRegExtranjeros,	 
CHAR(5)  	AS cCveEntidadEmisora , 
CHAR(8) 	AS cFolioCarta,	
CHAR(2) 	AS cStatusCurp;		 

		
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  			INTEGER;
	DEFINE cPCodRet 			CHAR(5);
	DEFINE cCodigoError	 		CHAR (4);
	DEFINE cErrorDescription 	CHAR (100);
	DEFINE cApellidoPaterno 	CHAR (50);
	DEFINE cApellidoMaterno 	CHAR (50);
	DEFINE cNombre 				CHAR (50);
	DEFINE cfechaNacimiento 	CHAR (10);
	DEFINE cCurp 				CHAR (18);
	DEFINE cFechaValidacionRenapo CHAR (10);
	DEFINE cStatusRenapo 		CHAR (2);
	DEFINE cUsuario				CHAR(12);
	DEFINE cPassword			CHAR(8);
	DEFINE cAgent_cd			CHAR(3);
	DEFINE vcUsuario			CHAR(8);
	DEFINE vcPassword			CHAR(8);
	DEFINE cIp_origen			CHAR(15);
	DEFINE cId_sesion_act		CHAR(30);
	DEFINE dtFecha_dia			DATE;
	DEFINE dFechaNueva 	 		CHAR(10);
	DEFINE cFecNac				CHAR(10);
	DEFINE cDia         		CHAR(2);
	DEFINE cMes         		CHAR(2);
	DEFINE cAnio        		CHAR(4);
	DEFINE cDiaNac				CHAR(2);
	DEFINE cMesNac              CHAR(2);
	DEFINE cAnioNac             CHAR(4);
	DEFINE cTipoError			CHAR(2);
	DEFINE cStatusOpe 			CHAR(8);
	DEFINE cSexo				CHAR(1);
	DEFINE cCrip				CHAR(5);
	
	---INICIALIZACION DE VARIABLES
	LET cAgent_cd ='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET dtFecha_dia   = CURRENT::DATE;
	LET dFechaNueva   = DATE(1);
	LET cFecNac = DATE(1);
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET cCodigoError = '0000';
	LET cErrorDescription = 'Consulta exitosa';
	LET cApellidoPaterno=TRIM(pcApePat);
    LET cApellidoMaterno=TRIM(pcApeMat);
	LET cNombre=TRIM(pcNombre);
	LET cCurp=TRIM(pcCurp);
	LET cFechaValidacionRenapo=CURRENT::DATE;
	LET cfechaNacimiento=date(1);
	LET cStatusRenapo=TRIM(pcStatusCurp);
	LET cCrip=SUBSTR(pcCrip,1,5);
	LET	cDiaNac='';
	LET	cMesNac=''; 
	LET	cAnioNac='';
	LET	cDia='';
	LET	cMes=''; 
	LET	cAnio='';
	LET cTipoError=pcTipoError;
	LET cStatusOpe=pcStatusOpe;
	LET cSexo=pcsexo;
				
--SET DEBUG FILE TO '/informix/andrescrespo/sp_guarda_renapo_curp.out';
--TRACE ON;

    BEGIN
    -- 
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
		
			LET cCodigoError = '300';
			let cErrorDescription='Error al validar la CURP';
			
			RETURN cCodigoError,cTipoError,cErrorDescription,cStatusOpe,pcSessionIDRenapo,cCurp,cApellidoPaterno,cApellidoMaterno,cNombre,cSexo,cfechaNacimiento,pcCveEntidadNac,pcNacionalidad,pcdocProbatorio,pcAnioReg,pcFoja,pctomo,pcLibro,pcNumActa,cCrip,pcNumEntidadReg,
			pcCveMunicipioReg,pcNumRegExtranjeros,pcCveEntidadEmisora,pcFolioCarta,pcStatusCurp;
			

        END IF;
    END EXCEPTION;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 10;


			
			
		IF (pcCodigoError::int!=0 or pcCodigoError!='')
			THEN
			LET cCodigoError ='9991';
			LET cErrorDescription = "Error de parametros de entrada o algun dato es invalido";
			
		ELIF (pcCodigoError='' OR pcCodigoError::int=0) THEN
			LET cDiaNac=SUBSTR(pcFecNac,1,2);
			LET cMesNac=SUBSTR(pcFecNac,4,2);
			LET cAnioNac=SUBSTR(pcFecNac,7,4);
			LET cFecNac=mdy(cMesNac,cDiaNac,cAnioNac); --ddmmyyyy se necesita dmy para el wsdl renapo
			LET cfechaNacimiento=(cDiaNac||'/'||cMesNac||'/'||cAnioNac);
			
						
			INSERT INTO "informix".tf_renapo(Apellido_paterno,Apellido_materno,Nombre,Sexo,Fecha_nacimiento,Nacionalidad,Municipio,Num_Registro_Extranjero,CURP,cStatusRenapo,fecha_validacion)
			VALUES (cApellidoPaterno,cApellidoMaterno,cNombre,pcSexo,cFecNac,pcNacionalidad,pcCveEntidadNac,pcNumRegExtranjeros, pcCurp,cStatusRenapo,cFechaValidacionRenapo);
						
						
			RETURN cCodigoError,cTipoError,cErrorDescription,cStatusOpe,pcSessionIDRenapo,cCurp,cApellidoPaterno,cApellidoMaterno,cNombre,cSexo,cfechaNacimiento,pcCveEntidadNac,pcNacionalidad,pcdocProbatorio,pcAnioReg,pcFoja,pctomo,pcLibro,pcNumActa,cCrip,pcNumEntidadReg,
			pcCveMunicipioReg,pcNumRegExtranjeros,pcCveEntidadEmisora,pcFolioCarta,pcStatusCurp;
		END IF;
	
	RETURN cCodigoError,cTipoError,cErrorDescription,cStatusOpe,pcSessionIDRenapo,cCurp,cApellidoPaterno,cApellidoMaterno,cNombre,cSexo,cfechaNacimiento,pcCveEntidadNac,pcNacionalidad,pcdocProbatorio,pcAnioReg,pcFoja,pctomo,pcLibro,pcNumActa,cCrip,pcNumEntidadReg,
			pcCveMunicipioReg,pcNumRegExtranjeros,pcCveEntidadEmisora,pcFolioCarta,pcStatusCurp;
	
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Servicio OT que recibe datos de transfer y ejecuta un web service RENAPO para validar la curp. ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_validacion_cta(
										pcAgent_trans_type_code CHAR(10),
										pcAgent_cd              CHAR(6),
										pcUsuario               CHAR(8),
										pcPassword              CHAR(8),
										pcIp_origen             CHAR(15),
										pcSession_id            CHAR(30),
                                        pcServiceName 			CHAR (128),
										pcSystemDate 			CHAR (15),
                                        pcCountryCode 			CHAR (3),
                                        pcBankId 				CHAR (3),
										pcAccessMethod 			CHAR (3),
                                        pcMedioAcceso 			CHAR (2),
										pcNumCelularSPEI 		CHAR(12))
	RETURNING
		CHAR (5) AS cReturnCode,
		CHAR (100) AS cErrorDescription,
		CHAR(12) AS Casociar;
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  INTEGER;
	DEFINE cPCodRet CHAR(5);
	DEFINE cReturnCode CHAR (5);
	DEFINE cErrorDescription CHAR (256);
	DEFINE cnumCelularSPEI CHAR (12);
	DEFINE Iasociar integer;
	DEFINE cUsuario				CHAR(12);
	DEFINE cPassword			CHAR(8);
	DEFINE cAgent_cd			CHAR(3);
	DEFINE vcUsuario			CHAR(12);
	DEFINE vcPassword			CHAR(8);
	DEFINE cIp_origen			CHAR(15);
	DEFINE cId_sesion_act		CHAR(30);
	DEFINE dtFecha_dia			DATE;
	DEFINE dFechaNueva 	 		CHAR(10);
	DEFINE cDia         		CHAR(2);
	DEFINE cMes         		CHAR(2);
	DEFINE cAnio        		CHAR(4);
	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cReturnCode = '0';
	LET cErrorDescription = 'Consulta exitosa';
	LET cnumCelularSPEI=pcNumCelularSPEI;
	LET Iasociar=0;
	
	LET cAgent_cd ='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET dtFecha_dia   = CURRENT::DATE;
	LET pcSystemDate=replace(pcSystemDate,'/','');
	LET dFechaNueva   = DATE(1);
	LET cPCodRet = '0';
	LET cErrorDescription = 'Consulta exitosa';
	LET	cDia='';
	LET	cMes=''; 
	LET	cAnio='';
--SET DEBUG FILE TO '/informix/andrescrespo/sp_valida.out';
--TRACE ON;
    BEGIN
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
			LET cReturnCode = iSqlErr;
			LET cPCodRet = iSqlErr;
			SELECT descripcion
			INTO  cErrorDescription
			FROM  tf_codret
			WHERE cod_error = cReturnCode;
            RETURN trim(cPCodRet),trim(cErrorDescription),Iasociar;
        END IF;
    END EXCEPTION;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
		IF (NVL(pcServiceName,'?')= '?' OR NVL(pcCountryCode,'?')= '?' OR NVL(pcAgent_cd,'?')= '?' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcBankId,'?')= '?' OR NVL(pcAccessMethod,'?')= '?'  OR NVL(pcAgent_trans_type_code,'?')= '?' OR NVL(pcPassword,'?')= '?'	
			OR NVL(pcIp_origen,'')='' OR NVL(pcSession_id,'')=''OR NVL(pcNumCelularSPEI,'?')= '?'  OR NVL(pcIp_origen,'?')= '?' OR NVL(pcMedioAcceso,'?')='?')
			THEN
			LET cReturnCode ='9996';
			LET cErrorDescription = "Error de parametros de entrada";
				
		ELSE
			IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
			   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = trim(pcusuario) AND activa = 'S' ) THEN
				--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
				SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
				INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
				FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and fecha_insert = dtFecha_dia;
				
				IF  (pcBankId='002' or pcBankId='036' or pcBankId='012' or pcBankId='137' or pcBankId='044' )  then
					IF pcCountryCode='484'  then
						IF pcAccessMethod='115'  THEN
							IF length(pcNumCelularSPEI)=12 THEN
								IF cAgent_cd = pcAgent_cd THEN
									IF cUsuario = pcUsuario   THEN
										IF cPassword = pcPassword THEN
											IF cIp_origen = pcIp_origen THEN
												IF cId_sesion_act::CHAR(30) = pcSession_id THEN
													IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = trim(pcusuario) and fecha_insert = dtFecha_dia) THEN
														IF pcSystemDate!='' THEN
															LET cDia=SUBSTR(pcSystemDate,1,2);
															LET cMes=SUBSTR(pcSystemDate,3,2);
															LET cAnio=SUBSTR(pcSystemDate,5,4);
															LET dFechaNueva = mdy(cMes,cDia,cAnio);
															IF  NVL(dFechaNueva,'')!='' AND dFechaNueva::DATE=today THEN
																
																IF EXISTS (	SELECT telefono
																			FROM bdicheq:"informix".sc_cuenta_telefono
																			WHERE telefono=SUBSTR(pcNumCelularSPEI,3,10)) THEN
																			
																			let Iasociar=1;
																			LET cErrorDescription = "El telefono ya esta asociado.";
															
																	RETURN trim(cReturnCode),trim(cErrorDescription),Iasociar;
																	
																ELSE 
																	
																	RETURN trim(cReturnCode),trim(cErrorDescription),Iasociar;
																END IF;
															ELSE
																LET cReturnCode = '9996';
																LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";
															END IF;
														ELSE
															LET cReturnCode = '9996';
															LET cErrorDescription = "Consulta no exitosa. Fecha inválida.";
														END IF;
													ELSE
														LET cReturnCode = '9975';
														LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
													END IF;
												ELSE
													LET cReturnCode = '9975';
													LET cErrorDescription = "Error autenticación. Id de sesión inválido.";
												END IF;
											ELSE
												LET cReturnCode = '9976';
												LET cErrorDescription = "Error autenticación. IP origen inválida ";
											END IF;
										ELSE
											LET cReturnCode = '9979';
											LET cErrorDescription = " Error autenticación. Password no existe.";
										END IF;
									ELSE
										LET cReturnCode = '9980';
										LET cErrorDescription = 'Error autenticación. Usuario no existe';
									END IF;
								ELSE
									LET cReturnCode = '9998';
									LET cErrorDescription = "Autenticación fallida. Código de agente inválido.";
								END IF;
								
							ELSE
								LET cReturnCode ='9996';
								LET cErrorDescription = " Error de parametros de entrada. pcNumCelular";
							END IF;
							
						ELSE
							LET cReturnCode ='9996';
							LET cErrorDescription = " Error de parametros de entrada. AccessMethod";
						END IF;
					ELSE
						LET cReturnCode ='9996';
						LET cErrorDescription = " Error de parametros de entrada. CountryCode";
					END IF;
				ELSE
					LET cReturnCode ='9996';
					LET cErrorDescription = " Error de parametros de entrada. BankId";
				END IF;
							
			ELSE
				LET cReturnCode ='9982';
				LET cErrorDescription = " Consulta no exitosa. Transacción no definida.";
			END IF;
		END IF;
	RETURN trim(cReturnCode),trim(cErrorDescription),Iasociar;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Validacion celular',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_guarda_renapo( 	pcCodigoError        CHAR(4),
												pcTipoError		     CHAR(2),
												pcErrorDescripcion   CHAR(100),
												pcStatusOpe          CHAR(8),
												pcSessionIDRenapo	 CHAR(100),
												pcCurp               CHAR(18),
												pcApePat             CHAR(50),
												pcApeMat             CHAR(50),
												pcNombre             CHAR(50),
												pcSexo               CHAR(1),
												pcFecNac        	 CHAR(10),--<fechNac>18/10/1989</fechNac>
												pcNacionalidad       CHAR(5),
												pcdocProbatorio      CHAR(1),
												pcAnioReg            CHAR(4),
												pcFoja               CHAR(10),
												pctomo		         CHAR(10),
												pcLibro              CHAR(10),
												pcNumActa            CHAR(10),
												pcCrip               CHAR(15),
												pcNumEntidadReg	   	 CHAR(5),
												pcCveMunicipioReg    CHAR(10),
												pcNumRegExtranjeros	 CHAR(10),
												pcFolioCarta	 	 CHAR(20),
												pcCveEntidadNac      CHAR(5),
												pcCveEntidadEmisora  CHAR(8),
												pcStatusCurp		 CHAR(2))
RETURNING
		CHAR (5) AS cCodigoError,
		CHAR (100)AS cErrorDescription,
		CHAR (50) AS cApellidoPaterno,
		CHAR (50) AS cApellidoMaterno,
		CHAR (50) AS cNombre,
		CHAR (15) AS cfechaNacimiento,
		CHAR (12) AS cNumCelular,
		CHAR (16) AS cNumeroTarjeta,
		CHAR (18) AS cCurp,
		CHAR (10) AS cFechaValidacionRenapo,
		CHAR (3)  AS cStatusRenapo;


	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  			INTEGER;
	DEFINE cPCodRet 			CHAR(5);
	DEFINE cCodigoError	 		CHAR (5);
	DEFINE cErrorDescription 	CHAR (100);
	DEFINE cApellidoPaterno 	CHAR (50);
	DEFINE cApellidoMaterno 	CHAR (50);
	DEFINE cNombre 				CHAR (50);
	DEFINE cfechaNacimiento 	CHAR (15);
	DEFINE cNumCelular 			CHAR (12);
	DEFINE cNumeroTarjeta	 	CHAR (16);
	DEFINE cCurp 				CHAR (18);
	DEFINE cFechaValidacionRenapo CHAR (10);
	DEFINE cStatusRenapo 		CHAR (3);
	DEFINE cUsuario				CHAR(12);
	DEFINE cIpRenapo			CHAR(15);
	DEFINE cPassword			CHAR(8);
	DEFINE cTipoTransaccion		CHAR(1);
	DEFINE cAgent_cd			CHAR(3);
	DEFINE cIp_origen			CHAR(15);
	DEFINE cId_sesion_act		CHAR(30);
	DEFINE dtFecha_dia			DATE;
	DEFINE dFechaNueva 	 		CHAR(10);
	DEFINE cFecNac				CHAR(10);
	DEFINE cDia         		CHAR(2);
	DEFINE cMes         		CHAR(2);
	DEFINE cAnio        		CHAR(4);
	DEFINE cDiaNac				CHAR(2);
	DEFINE cMesNac              CHAR(2);
	DEFINE cAnioNac             CHAR(4);
	DEFINE CCLAVE 				CHAR(2);
	DEFINE cEntidadEmisora 		CHAR(2);
	DEFINE maxid				INTEGER;
	---INICIALIZACION DE VARIABLES
	LET cAgent_cd ='';
	LET CCLAVE='';
	LET cUsuario ='';
	LET cPassword ='';
	LET cIp_origeN ='';
	LET cId_sesion_act ='';
	LET dtFecha_dia   = CURRENT::DATE;
	LET dFechaNueva   = DATE(1); --  01/01/1900
	LET cFecNac = DATE(1);
	LET cTipoTransaccion='6';
	LET cIpRenapo='201.158.207.46';
	LET cEntidadEmisora='30';
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET cCodigoError = 0;
	LET cErrorDescription = 'Consulta exitosa';
	LET cApellidoPaterno=pcApePat;
    LET cApellidoMaterno=pcApeMat;
	LET cNombre=pcNombre;
	LET cNumCelular='';
	LET cNumeroTarjeta='';
	LET cCurp=pcCurp;
	LET cFechaValidacionRenapo=CURRENT::DATE;
	LET cfechaNacimiento=date(1); --  01/01/1900
	LET cStatusRenapo=pcStatusCurp;
	LET	cDiaNac='';
	LET	cMesNac='';
	LET	cAnioNac='';
	LET	cDia='';
	LET	cMes='';
	LET	cAnio='';
	LET maxid=0;

--SET DEBUG FILE TO '/informix/andrescrespo/sp_guarda_renapo.out';
--TRACE ON;

    BEGIN
    -- 
    ON EXCEPTION SET iSqlErr
       IF iSqlErr <> 0 THEN--manejador de errores
			if iSqlErr='-1204' then
			let cCodigoError='0';
			LET cErrorDescription = 'servicio no activo';
			else 			
			LET cCodigoError = iSqlErr;
			LET cErrorDescription = 'Error desconocido';
			end if;
			
			RETURN cCodigoError, trim(cErrorDescription),cApellidoPaterno, cApellidoMaterno, cNombre, cfechaNacimiento, cNumCelular, cNumeroTarjeta, cCurp, cFechaValidacionRenapo, cStatusRenapo;

        END IF;
    END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 10;


			--IF pcFecNac is null OR pcFecNac='' THEN pcFecNac='01/01/1900';
			--END IF;
--or (pcCodigoError!='9996')
		IF (pcCodigoError)='9996' THEN
			LET cCodigoError="9996";
			LET cErrorDescription = "Parametro de entrada invalido.";

			select max(id)
			into maxid
			from "informix".tf_renapo;

			select num_celular,num_tarjeta
			into cNumCelular,cNumeroTarjeta
			from "informix".tf_renapo
			where id=maxid;

			LET cNumCelular='52'||cNumCelular;
		
		ELIF (pcCodigoError)='20' THEN
			LET cCodigoError="0";
			LET cErrorDescription = "Consulta Exitosa";
		
			select max(id)
			into maxid
			from "informix".tf_renapo;

			select num_celular,num_tarjeta
			into cNumCelular,cNumeroTarjeta
			from "informix".tf_renapo
			where id=maxid;

			LET cNumCelular='52'||cNumCelular;
		
		ELIF (pcCodigoError)='9975' THEN
			LET cCodigoError="9975";
			LET cErrorDescription = "Error id session";
		
			select max(id)
			into maxid
			from "informix".tf_renapo;

			select num_celular,num_tarjeta
			into cNumCelular,cNumeroTarjeta
			from "informix".tf_renapo
			where id=maxid;

			LET cNumCelular='52'||cNumCelular;
			

        ELIF (pcCodigoError::int!=0 or pcCodigoError!='')
			THEN
			LET cCodigoError ="9"||SUBSTR(pcCodigoError,1,2)||pcTipoError;
			LET cErrorDescription = TRIM(pcErrorDescripcion);

			select max(id)
			into maxid
			from "informix".tf_renapo;

			select num_celular,num_tarjeta
			into cNumCelular,cNumeroTarjeta
			from "informix".tf_renapo
			where id=maxid;

			LET cNumCelular='52'||cNumCelular;
		
		

		ELIF (pcCodigoError='' OR pcCodigoError::int=0) THEN
			--  01/01/1900
			LET cDiaNac=SUBSTR(pcFecNac,1,2);
			LET cMesNac=SUBSTR(pcFecNac,4,2);
			LET cAnioNac=SUBSTR(pcFecNac,7,4);
			LET cFecNac=mdy(cMesNac,cDiaNac,cAnioNac); --ddmmyyyy se necesita dmy para el wsdl renapo
			LET cfechaNacimiento=(cDiaNac||'/'||cMesNac||'/'||cAnioNac);

			select max(id)
			into maxid
			from "informix".tf_renapo;

			UPDATE "informix".tf_renapo set Nacionalidad=pcNacionalidad,Num_Registro_Extranjero=nvl(pcNumRegExtranjeros,''),CURP=pcCurp,cStatusRenapo=cStatusRenapo,fecha_validacion=cFechaValidacionRenapo
			where Apellido_paterno=trim(cApellidoPaterno) and Apellido_materno=trim(cApellidoMaterno) and Nombre=trim(cNombre) and Fecha_nacimiento=cFecNac and id=maxid;

			select num_celular,num_tarjeta
			into cNumCelular,cNumeroTarjeta
			from "informix".tf_renapo
			where id=maxid;

				IF EXISTS (SELECT telefono FROM "informix".tf_maecte
				WHERE empresa = '001' AND telefono = cNumCelular AND status_cta=1) THEN
						LET cCodigoError = '955';
						LET cErrorDescription = "Cliente Transfer existente con el mismo teléfono ingresado";
				END IF;
				
			LET cNumCelular='52'||cNumCelular;

			RETURN cCodigoError, trim(cErrorDescription),cApellidoPaterno, cApellidoMaterno, cNombre, cfechaNacimiento, cNumCelular, cNumeroTarjeta, cCurp, cFechaValidacionRenapo, cStatusRenapo;

		END IF;
	RETURN cCodigoError, trim(cErrorDescription),cApellidoPaterno, cApellidoMaterno, cNombre, cfechaNacimiento, cNumCelular, cNumeroTarjeta, cCurp, cFechaValidacionRenapo, cStatusRenapo;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: 96103817, Carlos Andres Crespo',
'DESCRIPCION: Servicio OT que recibe datos de transfer y ejecuta un web service RENAPO para validar la curp. ',
'FECHA: 29/08/2014',
'SOLICITO:Manuel Osuna',
'RQI 63 070 WS-PUB Transfer ',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_online_hist()
RETURNING 
CHAR(6) AS CodigoRet, 
CHAR(60) AS Mensaje;
-- DEFINICION DE VARIABLES.
DEFINE cCodRet		CHAR(6);
DEFINE cMensaje		CHAR(60);
DEFINE iSqlErr		INTEGER;
DEFINE dFechaHoy	DATE;
DEFINE cParamDias	CHAR(2);
DEFINE dFechaHist	DATE;

-- INICIALIZACION DE VARIABLES.
LET cCodRet 	= '000000';
LET cMensaje 	= 'PROCESO EJECUTADO EXITOSAMENTE';
LET iSqlErr 	= 0;
LET dFechaHoy 	= DATE(1);
LET cParamDias 	= '';
LET dFechaHist 	= DATE(1);

--SET DEBUG FILE TO '/informix/andrescrespo/sp_online_hist.out';
--TRACE ON;
BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = 'OCURRIO UN ERROR DE INFORMIX';
			RETURN cCodRet, cMensaje;
		END IF;
	END EXCEPTION;

	-- OBTENER FECHA HOY.
	SELECT fecha_hoy 
	INTO dFechaHoy	
	FROM bdinteg:'informix'.si_fechas;
	
	-- OBTENER EL PARAMETRO DEL VALOR MES PARA RESTARLO A LA FECHA HOY.
	SELECT TRIM(valor) 
	INTO cParamDias 
	FROM 'informix'.tf_param 
	WHERE cod_param = 3;
	
	-- CALCULAR LA FECHA DE CONSULTA, SE RESTA EL MES PARAMETRIZADO (valor = 2).
	LET dFechaHist = dFechaHoy - cParamDias UNITS DAY;
	
	-- INSERTAR EN LA TABLA HISTORICA LOS REGISTROS DE LA TABLA PRINCIPAL
	-- TOMANDO LOS REGISTROS QUE ESTEN CON LA fec_sistema ANTES DE LOS ULTIMOS DOS MESES
	-- Y QUE EL CAMPO cte_conciliado = 1.
	INSERT INTO 'informix'.tf_online_hist		
	SELECT id,nom_servicio,codigo_ciudad,cliente_mps,cuenta_tf,id_banco,	
	nombre1,nombre2,apell_paterno,apell_materno,
	calle,num_exterior,num_interno,num_depto,colonia,municipio,estado,cod_postal,
	fecha_nac,telefono,correo,esregistro,rfc,met_notificacion,metodo_acceso,fec_sistema,num_tarjeta,
	id_persona,identificacion,num_identificacion,genero,entidad_nac,curp,status_cta,fec_valrenapo,
	comentarios,num_confronta,cta_clabe,cte_conciliado,cte_fusionado,cod_error,desc_error,err_conciliacion,
	MSISDNrecepcion,Telefonica,TipoAsociacion
	FROM 'informix'.tf_cte_online		                                                                    
	WHERE cte_conciliado = '1'                                                                         
	AND fec_sistema < dFechaHist;
	
	-- SI HUBO REGISTROS SE BORRAN LOS REGISTROS QUE SE INSERTARON EN TABLA HISTORICA
	IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
		-- BORRAR LOS REGISTROS CONCILIADOS DE LA TABLA PRINCIPAL 
		DELETE FROM 'informix'.tf_cte_online
		WHERE cte_conciliado = '1' 
			AND fec_sistema < dFechaHist;
	ELSE
		LET cCodRet = '000001';
		LET cMensaje = 'NO HAY REGISTROS POR PROCESAR';
	END IF;
	
	RETURN cCodRet, cMensaje;

END
END PROCEDURE
DOCUMENT
'AUTOR: 93928475 - Guadalupe Payan Camacho',
'FOLIO: 1440',
'DESCRIPCION: Generar historial de registros de la tabla tf_cte_online a la tabla tf_online_hist todos aquellos que su fec_sistema sea antes de los dos ultimos meses en comparacion a la fecha_hoy',
'FECHA: 20/05/2014',
'SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento',
'RQI 63 050 Procesos Transfer Sucursal v1 4.pdf',
'BD: BDITRANSFER';

CREATE PROCEDURE "informix".sp_transfer_bono_alta( pEmpresa CHAR(3) )
RETURNING CHAR(5);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE vActivo      CHAR(8);
    DEFINE vFechaHoy    DATE;
    DEFINE vFechaAnt    DATE;
    DEFINE vMonto       MONEY(14,2);
    DEFINE vHora        CHAR(15);
    DEFINE vFolio       CHAR(16);
    DEFINE vCuenta      CHAR(20);
    DEFINE vFechaAlta   DATE;
    DEFINE cCodRetAbono CHAR(5);
    
    LET cCodRet      = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr      = 0;
    LET iSamErr      = 0;
    LET cDesErr      = 0;
    LET vActivo      = '0';
    LET vFechaHoy    = '';
    LET vFechaAnt    = '';
    LET vMonto       = 0.00;
    LET vHora        = '';
    LET vFolio       = '';
    LET vCuenta      = '';
    LET vFechaAlta   = '';
    LET cCodRetAbono = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_bono_alta.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_bono_alta.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor
      INTO vActivo
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'VigBonoAltaTransfer';
       
    IF vActivo = '1' THEN
        SELECT fecha_hoy, fecha_ant
          INTO vFechaHoy, vFechaAnt
          FROM bdicheq:sc_fechas
         WHERE empresa = pEmpresa;
        
        SELECT valor
          INTO vMonto
          FROM bdicheq:sc_param
         WHERE empresa = pEmpresa
           AND codparam = 'MtoBonoAltaTransfer';
         
        LET vHora = CURRENT HOUR TO FRACTION;
        LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
         
        FOREACH WITH HOLD
            SELECT cuenta_tf, fec_alta
              INTO vCuenta, vFechaAlta
              FROM tf_maecte
             WHERE status_cta = '1'
               AND fec_alta = vFechaAnt
            
            EXECUTE PROCEDURE bdicheq:abono_ref(pEmpresa,'9250','informix','0327','0000',vFolio,vCuenta,0,vMonto,vMonto,0,0,0,'01','BONO DE BIENVENIDA TRANSFER','','')
            INTO cCodRetAbono;
            
            IF cCodRetAbono = '000' THEN
                INSERT INTO tf_bonos_transfer VALUES( vFechaHoy, 'BONO DE BIENVENIDA', vCuenta, vFechaAlta, vMonto, cCodRetAbono, 'BONO APLICADO' );
            ELSE
                INSERT INTO tf_bonos_transfer VALUES( vFechaHoy, 'BONO DE BIENVENIDA', vCuenta, vFechaAlta, vMonto, cCodRetAbono, 'BONO NO APLICADO' );
            END IF;
        END FOREACH;
    END IF;
    
    END;
    
    RETURN cCodRet; 
    
END PROCEDURE;