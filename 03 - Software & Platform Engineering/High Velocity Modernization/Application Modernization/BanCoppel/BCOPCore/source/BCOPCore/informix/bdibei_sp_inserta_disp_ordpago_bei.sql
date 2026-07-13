CREATE PROCEDURE "informix".sp_inserta_disp_ordpago_bei(pNumCliente CHAR(9), pTipoDisp INTEGER, pFecha VARCHAR(10), pNumReferencia VARCHAR(16), pConcepto VARCHAR(30), pArchivo VARCHAR(12), pCta_origen VARCHAR(12), pAlias VARCHAR(20), pNombre_Completo VARCHAR(104), pImporte MONEY(14,2), pClave_Envio VARCHAR(12))
	RETURNING CHAR(5);

	--Declaración de variables
	DEFINE vCodRet CHAR(5);
	DEFINE sql_err INTEGER;

	--Inicializar variables
	LET vCodRet='00000';

	--****************************************************************************************************
	-- DESCRIPCION: Inserta Dispersion de Nomina
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

	    IF(LENGTH(TRIM(NVL(pNumReferencia,''))) = 0) THEN
	        LET vCodRet="00004";
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

        IF(LENGTH(TRIM(NVL(pNombre_Completo,''))) = 0) THEN
	        LET vCodRet="00009";
            RETURN vCodRet;
	    END IF;

        IF(NVL(pImporte,0) = 0) THEN
	        LET vCodRet="00010";
            RETURN vCodRet;
	    END IF;




	    SET LOCK MODE TO WAIT 4;

	    INSERT INTO bdibei:"informix".bei_dispersiones_odp(
            num_cliente,
	        tipo_dispersion,
	        fecha,
	        num_referencia,
	        concepto,
	        archivo,
            cta_origen,
            alias,
            nombre_completo,
            importe,
	        clave_envio)
		VALUES(
	        pNumCliente,
	        pTipoDisp,
            to_date(pFecha,'%d/%m/%Y'),
	        pNumReferencia,
	        pConcepto,
	        pArchivo,
            pCta_origen,
            pAlias,
            pNombre_Completo,
            pImporte,
            pClave_Envio
            );

	    RETURN vCodRet;
	END
END PROCEDURE;