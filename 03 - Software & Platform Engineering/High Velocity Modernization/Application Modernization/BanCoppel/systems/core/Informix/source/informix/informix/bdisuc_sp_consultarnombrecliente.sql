CREATE PROCEDURE "informix".sp_consultarnombrecliente(p_sEmpresa CHAR(3), p_sNumcte CHAR(20))
	RETURNING 	CHAR(6) AS retorno,
				CHAR(3) AS empresa, 
				CHAR(20) AS numcte, 
				CHAR(2) AS status_cte, 
				CHAR(4) AS sucursal, 
				CHAR(2) AS tpo_persona,
				CHAR(1) AS tipo_cliente,
				CHAR(26) AS apell_paterno, 
				CHAR(26) AS apell_materno,
				CHAR(26) AS nombre1, 
				CHAR(26) AS nombre2, 
				CHAR(60) AS razon_social,
				CHAR(13) AS rfc,
				DATE AS fecha_alta,
				CHAR(20) AS numcte_ref;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(6);
	DEFINE v_sEmpresa 		CHAR(3);
	DEFINE v_sNumCte		CHAR(20);
	DEFINE v_sStatusCte		CHAR(2);
	DEFINE v_sSucursal		CHAR(4);
	DEFINE v_sTipoPersona	CHAR(2);
	DEFINE v_sTipoCliente	CHAR(1);
	DEFINE v_sApellPaterno	CHAR(26);
	DEFINE v_sApellMaterno	CHAR(26);
	DEFINE v_sNombre1		CHAR(26);
	DEFINE v_sNombre2		CHAR(26);
	DEFINE v_sRazonSocial	CHAR(60);
	DEFINE v_sRfc			CHAR(13);
	DEFINE v_dFechaAlta		DATE;
	DEFINE v_sNumCteRef		CHAR(20);
	------------------------------------------------------------------------------------------
	--Creado por Erick Zamora 03/Agosto/2009
	--Obtiene los datos del cliente especificado, o de todas los clientes del catalogo
	--Caso de uso asociado: PCU-bdinteg\CU-0104-ConsultarNombreCliente-SPL
	--SET DEBUG FILE TO "/tmp/sp_consultarNombreCliente.out"; 
	--TRACE ON;
	------------------------------------------------------------------------------------------
	LET v_sValRetorno = '000001';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
		
		--DEBE PROPORCIONARSE LA EMPRESA
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumcte,'') = '' THEN
			RETURN v_sValRetorno,'','','','','','','','','','','','','','';
		END IF;
		
		LET p_sNumcte = LPAD(TRIM(p_sNumcte),9,'0');
		
		FOREACH
			SELECT empresa, numcte, status_cte, sucursal, tpo_persona, tipo_cliente, apell_paterno,
			apell_materno, nombre1, nombre2, razon_social, rfc, fecha_alta, numcte_ref
			INTO v_sEmpresa, v_sNumCte, v_sStatusCte, v_sSucursal, v_sTipoPersona, v_sTipoCliente, v_sApellPaterno,
			v_sApellMaterno, v_sNombre1, v_sNombre2, v_sRazonSocial, v_sRfc, v_dFechaAlta, v_sNumCteRef
			FROM bdinteg:si_cliente
			WHERE empresa = p_sEmpresa AND numcte = p_sNumcte

			LET v_sValRetorno = '000000';
			RETURN v_sValRetorno,v_sEmpresa, v_sNumCte, v_sStatusCte, v_sSucursal, v_sTipoPersona, v_sTipoCliente, v_sApellPaterno,
			v_sApellMaterno, v_sNombre1, v_sNombre2, v_sRazonSocial, v_sRfc, v_dFechaAlta, v_sNumCteRef WITH RESUME;
		END FOREACH;
	END
END PROCEDURE;