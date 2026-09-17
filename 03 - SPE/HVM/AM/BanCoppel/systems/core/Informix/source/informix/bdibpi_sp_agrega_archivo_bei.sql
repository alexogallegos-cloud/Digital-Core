CREATE PROCEDURE "informix".sp_agrega_archivo_bei(pNumCliente char(9),
                          pNomArchivo char(17),
                          pIdEmpresa char(3),
                          pFechaDispersion char(10),
                          pTamArchivo integer,
                          pTipoDispersion integer,
                          pStatus integer,
                          pMotivoPago char(30))

	returning char(5);

	--****************************************************************************************************
	-- DESCRIPCION:  AGREGA EL NOMBRE DEL ARCHIVO A DISPERSAR.
	-- AUTOR : Francisco Rodriguez Ibarra
	-- FECHA : 26/08/2011
	-- BD: bdibpi
	-- SOLICITO :Mauricio Leon
	--****************************************************************************************************

	--Declaracion de variables
   DEFINE vCodRet char(5);
   DEFINE sql_err integer;

   --asigacion de valores a variables
   LET vCodRet='00000';

--SET DEBUG FILE TO '/home/informix/BereniceOut/sp_agrega_archivo_bei.out';
--TRACE ON;

	BEGIN


		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		IF(pNumCliente IS NOT NULL  OR pNumCliente<>'') OR (pNomArchivo IS NOT NULL OR pNomArchivo<>'') THEN
			IF NOT EXISTS(select nombre_archivo from bdibpi:"informix".bpi_dispersarchivo WHERE nombre_archivo=TRIM(pNomArchivo) AND tipo_dispersion='3') THEN

				INSERT INTO bdibpi:"informix".bpi_dispersarchivo(nombre_archivo,f_dispersion,cte_empresa,id_empresa,tamano_archivo,tipo_dispersion,status_dispersion, motivopago)
											   VALUES(TRIM(pNomArchivo),pFechaDispersion,TRIM(pNumCliente),pIdEmpresa,pTamArchivo,pTipoDispersion,pStatus,pMotivoPago);

			ELSE
				UPDATE bdibpi:"informix".bpi_dispersarchivo SET f_dispersion = pFechaDispersion, cte_empresa = TRIM(pNumCliente), id_empresa = pIdEmpresa, tamano_archivo = pTamArchivo,
										tipo_dispersion = pTipoDispersion, status_dispersion = pStatus, motivopago = pMotivoPago WHERE nombre_archivo=TRIM(pNomArchivo) AND tipo_dispersion='3';
			END IF;

		ELSE
			LET vCodRet='00001';

		END IF;
		RETURN vCodRet;
	END;
END PROCEDURE;