CREATE PROCEDURE "informix".sp_obtiene_direccion_envio(pNumCte CHAR(9), pNvaDir INTEGER)
	RETURNING CHAR(5), INTEGER, CHAR(200);

----------------------------------------------------------------------------------------------------------------------------------------
-- Realizó: Manuel Ramos Figueroa
-- Actividad: Obtiene la secuencia de la ultima direccion de envio de dispositivo token para obtener la dirección mediante la
--				ejecución del sp sp_obt_dir_admtoken.
-- Solicitó: Walber Castrof
-- Fecha de Solicitud: 23/12/2013
----------------------------------------------------------------------------------------------------------------------------------------
-- Se modifican los valores de retorno para que se muestre en pantalla el número interior y el departamento en caso de que haya sido capturado.
-- Bibiana Gaxiola Verdugo.
-- 17/01/2014
-----------------------------------------------------------------------------------------------------------------------------------------
-- Se modifican los valores de retorno del SP sp_obt_dir_admtoken, ya que fue actualizado dicho SP para funcionalidad del Admon token
-- Bibiana Gaxiola Verdugo
-- 21/10/2014
-----------------------------------------------------------------------------------------------------------------------------------------

-- Se se agrega validación para que retorne la dirección de persona moral
-- Gabriela Aguilar
-- 09/08/2016
-----------------------------------------------------------------------------------------------------------------------------------------

	DEFINE cCodRet			CHAR(5);
	DEFINE cCodRet2			CHAR(5);
	DEFINE iSql_err			INTEGER;
	DEFINE iSecDomicilio	INTEGER;
	DEFINE cDomicilio		CHAR(200);
	DEFINE cNumSolicitud	CHAR(10);

	DEFINE vCliente			CHAR(9);
	DEFINE vEstado			CHAR(30);
	DEFINE vCiudad			CHAR(60);
	DEFINE vMunicipio		CHAR(25);
	DEFINE vColonia			CHAR(30);
	DEFINE vCalle			CHAR(30);
	DEFINE vCalleCom		CHAR(30);
	DEFINE vEmail			CHAR(60);
	DEFINE vNumExterior		CHAR(10);
	DEFINE vNumInterior		CHAR(10);
	DEFINE vTel				CHAR(22);
	DEFINE vCodPostal		CHAR(5);
	DEFINE vManzana			CHAR(6);
	DEFINE vAndador			CHAR(6);
	DEFINE vEtapa			CHAR(6);
	DEFINE vLote			CHAR(6);
	DEFINE vEdificio		CHAR(6);
	DEFINE vEntrada			CHAR(6);
	DEFINE vOtros			CHAR(6);
	DEFINE vObservaciones	CHAR(80);
	DEFINE vid_estado	    CHAR(5);
	
	LET cCodRet				= '00000';
	LET cCodRet2				= '00000';
	LET iSql_err			= 0;
	LET iSecDomicilio		= 0;
	LET cDomicilio			= '';
	LET cNumSolicitud		= '';

	LET vCliente			= '';
	LET vEstado				= '';
	LET vCiudad				= '';
	LET vMunicipio			= '';
	LET vColonia			= '';
	LET vCalle				= '';
	LET vCalleCom			= '';
	LET vEmail				= '';
	LET vNumExterior		= '';
	LET vNumInterior		= '';
	LET vTel				= '';
	LET vCodPostal			= '';
	LET vAndador			= '';
	LET vEtapa				= '';
	LET vLote				= '';
	LET vEdificio			= '';
	LET vEntrada			= '';
	LET vOtros				= '';
	LET vObservaciones		= '';
	LET vid_estado   		= '';

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_obtiene_direccion_envio.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet, 0, '';
			END IF;
		END EXCEPTION;
	

		IF pNvaDir == 0 THEN
			SELECT MAX(solicitud)
			INTO cNumSolicitud
			FROM bdibpi:"informix".bpi_tokensolicitud
			WHERE numcte = pNumCte;

			SELECT sec_domicilio
			INTO iSecDomicilio
			FROM bdibpi:"informix".bpi_tokensolicitud
			WHERE numcte = pNumCte
			AND solicitud = cNumSolicitud;
		ELIF pNvaDir == 1 THEN
			SELECT MAX(secuencia)
			INTO iSecDomicilio
			FROM bdinteg:"informix".si_direcciones
			WHERE numcte = pNumCte;
		ELIF pNvaDir == 2 THEN
			SELECT MAX(secuencia)
			INTO iSecDomicilio
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = pNumCte and tipo_dir='1';
		
		END IF;

		IF NVL(iSecDomicilio, 0) > 0 THEN
			EXECUTE PROCEDURE bdibpi:"informix".sp_obt_dir_admtoken(pNumCte, iSecDomicilio)
			INTO cCodRet2, vCliente, vEstado, vCiudad, vMunicipio, vColonia, vCalle, vCalleCom, vEmail, vNumExterior,
					vNumInterior, vTel, vCodPostal,vManzana,vAndador,vEtapa,vLote,vEdificio,vEntrada,vOtros,vObservaciones, vid_estado;
		ELSE
			LET cCodRet = '00001';
		END IF;

		IF cCodRet2 == "000" THEN
			--- LET cDomicilio = TRIM(NVL(vCalle, '')) || ' ' || TRIM(NVL(vNumExterior, '')) || ' ' || TRIM(NVL(vColonia, '')) || ', ' ||
			LET cDomicilio = TRIM(NVL(vCalle, '')) || ' ' || TRIM(NVL(vNumExterior, '')) || ' ' || TRIM(NVL(vNumInterior, '')) || ' ' || TRIM(NVL(vColonia, '')) || ', ' ||
								TRIM(NVL(vCiudad, '')) || ', ' || TRIM(NVL(vEstado, '')) || ', ' || TRIM(NVL(vCodPostal, ''));
		ELSE
			LET cCodRet = '00001';
		END IF;

		RETURN cCodRet, iSecDomicilio, cDomicilio;
	END
END PROCEDURE;