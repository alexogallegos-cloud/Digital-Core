CREATE PROCEDURE "informix".sp_inserta_bendispmanco_odp_bei(pIdMancomunidad INTEGER,pNumCliente CHAR(9), pTipoDisp INTEGER, pFecha DATE, pConcepto VARCHAR(30), 
pCta_origen VARCHAR(12), pAlias VARCHAR(20), pPrimerNombre VARCHAR(30),pSegundoNombre VARCHAR(30), pApellidoPaterno VARCHAR(30), pApellidoMaterno VARCHAR(30), pImporte MONEY(14,2), pTelefono VARCHAR(25), pDireccion VARCHAR(100))
	RETURNING CHAR(5);

	--Declaración de variables
	DEFINE vCodRet CHAR(5);
	DEFINE sql_err INTEGER;

	--Inicializar variables
	LET vCodRet='00000';

	--****************************************************************************************************
	-- DESCRIPCION: Inserta Dispersion de Orden de Pago
	-- AUTOR: Jesus Ferruzca Luna
	-- FECHA: 24/02/2015
	-- BD: bdibei
	--***************************************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN vCodRet;
			END IF ;
		END EXCEPTION ;

		IF(LENGTH(TRIM(NVL(pNumCliente,''))) = 0) THEN
	        LET vCodRet="00001";
            RETURN vCodRet;
	    END IF;

	    IF(nvl(pTipoDisp,0) <= 0) THEN
	        LET vCodRet="00002";
            RETURN vCodRet;
	    END IF;

	    IF(NVL(pFecha,'') = '') THEN
	        LET vCodRet="00003";
            RETURN vCodRet;
	    END IF;

	    IF(LENGTH(TRIM(NVL(pCta_origen,''))) = 0) THEN
	        LET vCodRet="00007";
            RETURN vCodRet;
	    END IF;

        IF(LENGTH(TRIM(NVL(pAlias,''))) = 0) THEN
	        LET vCodRet="00008";
            RETURN vCodRet;
	    END IF;

        IF(LENGTH(TRIM(NVL(pPrimerNombre,''))) = 0) THEN
	        LET vCodRet="00009";
            RETURN vCodRet;
	    END IF;

        IF(NVL(pImporte,0) = 0) THEN
	        LET vCodRet="00010";
            RETURN vCodRet;
	    END IF;

        IF(NVL(pIdMancomunidad,0) = 0) THEN
	        LET vCodRet="00011";
            RETURN vCodRet;
	    END IF;


	    SET LOCK MODE TO WAIT 4;

        INSERT INTO bdibei:"informix".bei_beneficiariosmanco_odp(
            id_dispmanco,
            id_mancomunidad,
            num_cliente,
	        tipo_dispersion,
	        fecha,
	        concepto,
            cta_origen,
            alias,
            primer_nombre,
            segundo_nombre,
            apellido_paterno,
            apellido_materno,
            importe,
            telefono,
            direccion)
		VALUES(
            0,
            pIdMancomunidad,
	        pNumCliente,
	        pTipoDisp,
	        pFecha,
	        pConcepto,
            pCta_origen,
            pAlias,
            pPrimerNombre,
            pSegundoNombre,
            pApellidoPaterno,
            pApellidoMaterno,
            pImporte,
            pTelefono,
            pDireccion
            );

	    RETURN vCodRet;
	END
END PROCEDURE;