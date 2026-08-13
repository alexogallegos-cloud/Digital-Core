CREATE PROCEDURE "informix".sp_obtenercuentascolocacion(p_sEmpresa CHAR(3), p_sNumCliente CHAR(20))

	RETURNING 	CHAR(6) AS retorno, CHAR(3) AS empresa, CHAR(20) AS numcredito, CHAR(20) AS numcliente,
				CHAR(1) AS identificador;

	--VARIABLES DE ERROR DEL SP
    DEFINE cVarDataErr			VARCHAR(255);
    DEFINE iSqlErr				INTEGER;
    DEFINE iSamErr				INTEGER;

	--DECLARACIÓN DE VARIABLES DE USO DEL SP
	DEFINE v_sValRetorno		CHAR(6);
	DEFINE v_sEmpresa			CHAR(3);
	DEFINE v_sNumcredito		CHAR(20);
	DEFINE v_sNumCliente		CHAR(20);
	DEFINE v_sIdentificador		CHAR(1);

	-----------------------------------------------------------------------
	--Creado por: Vladimir Félix Gálvez
	--Fecha de Creación: 07-Agosto-2009
	--Caso de uso asociado: 
	--Obtiene las cuentas de credito de los clientes.
	--Debug del Procedure
	--SET DEBUG FILE TO "/tmp/vladi/sp_obtenercuentascolocacion.out";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno 		= '000001';
	LET v_sEmpresa			= '';
	LET v_sNumcredito		= '';
	LET v_sNumCliente		= '';
	LET v_sIdentificador	= '';

	BEGIN

		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;
				RETURN v_sValRetorno,'','','','';
			END IF;
		END EXCEPTION;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumCliente, '') = '' THEN
			RETURN v_sValRetorno,'','','','';
		END IF;

		LET p_sNumCliente = LPAD(TRIM(p_sNumCliente),9,'0');
		--Consultar la información del catalogo de nomina de las empresas.
		FOREACH
			SELECT empresa, num_credito, numcte, 'C'
			INTO v_sEmpresa, v_sNumcredito, v_sNumCliente, v_sIdentificador
			FROM bdicred:sd_maecred 
			WHERE empresa = p_sEmpresa
			AND numcte = p_sNumCliente
			

			LET v_sValRetorno = '000000';
			RETURN  v_sValRetorno, v_sEmpresa, v_sNumcredito, v_sNumCliente, v_sIdentificador WITH RESUME;

		END FOREACH;
	END;
END PROCEDURE;