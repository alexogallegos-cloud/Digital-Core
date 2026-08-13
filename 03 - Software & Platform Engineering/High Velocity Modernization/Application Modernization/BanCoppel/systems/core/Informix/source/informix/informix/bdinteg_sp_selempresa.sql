CREATE PROCEDURE "informix".sp_selempresa(p_sEmpresa CHAR(3))
	
    RETURNING 	CHAR(50) AS razon_social,
				CHAR (13) AS rfc,
				CHAR (40) AS domicilio_fiscal,
				CHAR (5) AS codigo_postal;

	DEFINE v_sRazonSocial 		CHAR(50);
	DEFINE v_sRfc				CHAR(13);
	DEFINE v_sDomicilioFiscal	CHAR(40);
	DEFINE v_sCodigoPostal		CHAR(5);

	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 08/01/2009
	--SET DEBUG FILE TO "/tmp/sp_consultarEmpresa.out
	--TRACE ON;
	--------------------------------------------------------------------------

	BEGIN
		IF p_sEmpresa = '' THEN
			RETURN '', '', '', '';
		END IF

		SELECT razon_social, rfc, domicilio_fiscal, codigo_postal
		INTO v_sRazonSocial, v_sRfc, v_sDomicilioFiscal, v_sCodigoPostal
		FROM bdinteg:"informix".si_empresas
		WHERE empresa = p_sEmpresa;

		RETURN v_sRazonSocial, v_sRfc, v_sDomicilioFiscal, v_sCodigoPostal;

	END
END PROCEDURE;