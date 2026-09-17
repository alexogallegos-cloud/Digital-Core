CREATE PROCEDURE "informix".consctestjt(pEmpresa char(3), pNumeroCuenta char(26), pNumeroCliente char(20))
	-- DATOS A REGRESAR --
	RETURNING
	char(5),    -- Codigo de retorno
	char(20),   -- # Cliente
	char(26),   -- Apellido paterno
	char(26),   -- Apellido materno
	char(26),   -- Nombre 1
	char(26),   -- Nombre 2
	char(13),   -- RFC
	char(16),   -- # Tarjeta
	char(5),     -- Fecha vencimiento
	money(14,2), -- Limite de retiro maximo por mes
	char(1),    -- Status tarjeta
	char(8);    -- Tipo de cliente

	-- VARIABLES --
	DEFINE vCodRet  char(5);
	DEFINE vTipCte  char(1);
	DEFINE vNumCte	char(20);
	DEFINE vApePat  char(26);
	DEFINE vApeMat  char(26);
	DEFINE vNombre1 char(26);
	DEFINE vNombre2 char(26);
	DEFINE vRFC     char(13);
	DEFINE vNumTarj char(16);
	DEFINE vFecVenc char(5);
	DEFINE vLimTar  money(14,2);
	DEFINE vTipoCte char(8);
	DEFINE vStatTjt char(1);
	DEFINE vCantReg smallint;

	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  = "000";
	LET vCantReg = 0;

   --SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/consctestjt.out";
   --TRACE ON;

	-- BUSCAR QUE TIPO DE CLIENTE ES [ TITULAR O FIRMANTE] --
	LET	vTipCte = "";

	SELECT
		'T' AS tipo_cliente, sc_cred.numcte
	INTO
		vTipCte, vNumCte
	FROM
		bdicred:"informix".sd_maecred AS sc_cred
	WHERE
		sc_cred.empresa = pEmpresa AND
		sc_cred.num_credito  = pNumeroCuenta AND
		sc_cred.numcte = pNumeroCliente;



	IF vTipCte = 'T' THEN
		-- CICLO PARA OBTENER AL TITULAR Y LOS FIRMANTES Y LAS TARJETAS DE CREDITO EN CASO DE QUE TENGAN --
		FOREACH
			SELECT
				si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 'Titular' AS tipo_cliente
			FROM
				bdicred:"informix".sd_maecred AS sc_cred,
				bdinteg:"informix".si_cliente AS si_cte
			WHERE
				sc_cred.empresa = pEmpresa AND sc_cred.num_credito =  pNumeroCuenta AND
				sc_cred.numcte = si_cte.numcte AND  si_cte.empresa = pEmpresa

			UNION

			SELECT
				si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 'Firmante' AS tipo_cliente
			INTO
				vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte
			FROM
				bdicred:"informix".sd_tarjeta AS sd_tar,
				bdinteg:"informix".si_cliente AS si_cte
			WHERE
				sd_tar.empresa =  pEmpresa AND sd_tar.num_credito =  pNumeroCuenta AND sd_tar.numcte != vNumCte AND
				sd_tar.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa
            order by tipo_cliente desc


			-- OBTENER LA TARJETA DEL TITULAR O FIRMANTE --
			SELECT
					sd_tar.num_tarjeta, SUBSTRING(TO_CHAR(sd_tar.expiracion, "%y-%m-%d") FROM 1 FOR 5), sd_tar.limite_aut, sd_tar.status_tar
			INTO
					vNumTarj, vFecVenc, vLimTar, vStatTjt
			FROM
					bdicred:"informix".sd_tarjeta AS sd_tar
			WHERE
					sd_tar.empresa = pEmpresa AND
					sd_tar.num_credito = pNumeroCuenta AND
					sd_tar.numcte = vNumCte AND
					sd_tar.secuencia = (SELECT MAX(sd_tar.secuencia) FROM bdicred:sd_tarjeta AS sd_tar WHERE sd_tar.empresa = pEmpresa AND sd_tar.num_credito = pNumeroCuenta AND sd_tar.numcte = vNumCte);

			IF vNumTarj IS NULL THEN
				LET vNumTarj = "Sin tarjeta";
				LET vLimTar  = 0;
				LET vStatTjt = "";
			END IF

			LET vCantReg = vCantReg + 1;

			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, vFecVenc, vLimTar, vStatTjt, vTipoCte WITH RESUME;
		END FOREACH;
	ELSE

		-- OBTENER LOS DATOS DEL FIRMANTE
		SELECT
			si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 'Firmante' AS tipo_cliente,
			sd_tar.num_tarjeta, SUBSTRING(TO_CHAR(sd_tar.expiracion, "%y-%m-%d") FROM 1 FOR 5), NVL(sd_tar.limite_aut,0), sd_tar.status_tar

		INTO
			vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte,
			vNumTarj, vFecVenc, vLimTar, vStatTjt

		FROM
			bdicred:"informix".sd_tarjeta AS sd_tar,
			bdinteg:"informix".si_cliente AS si_cte
		WHERE
			sd_tar.empresa =  pEmpresa AND
			sd_tar.num_credito =  pNumeroCuenta AND
			sd_tar.numcte = pNumeroCliente AND
			sd_tar.numcte = si_cte.numcte AND
            sd_tar.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE empresa = pEmpresa AND num_credito = pNumeroCuenta AND numcte = pNumeroCliente) AND
			si_cte.empresa = pEmpresa;




		-- OBTENER LA TARJETA DEL FIRMANTE --
		/*SELECT
				sd_tar.num_tarjeta, SUBSTRING(TO_CHAR(sd_tar.expiracion, "%y-%m-%d") FROM 1 FOR 5), sd_tar.limite_aut, sd_tar.status_tar
		INTO
				vNumTarj, vFecVenc, vLimTar, vStatTjt
		FROM
				bdicred:sd_tarjeta AS sd_tar
		WHERE
				sd_tar.empresa = pEmpresa AND
				sd_tar.num_credito = pNumeroCuenta AND
				sd_tar.numcte = vNumCte AND
				sd_tar.secuencia = (SELECT MAX(sd_tar.secuencia) FROM bdicred:sd_tarjeta AS sd_tar WHERE sd_tar.empresa = pEmpresa AND sd_tar.num_credito = pNumeroCuenta AND sd_tar.numcte = vNumCte);*/


		IF vNumTarj IS NULL THEN
			LET vNumTarj = "Sin tarjeta";
			LET vLimTar  = 0;
			LET vStatTjt = "";
		END IF

		LET vCantReg = vCantReg + 1;

		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, vFecVenc, vLimTar, vStatTjt, vTipoCte;
	END IF

	IF vCantReg = 0 THEN
		LET vCodRet  = "151";
		LET vNumCte  = "";
		LET vApePat  = "";
		LET vApeMat  = "";
		LET vNombre1 = "";
		LET vNombre2 = "";
		LET vRFC     = "";
		LET vNumTarj = "";
		LET vFecVenc = "";
		LET vLimTar  = 0;
		LET vStatTjt = "";
		LET vTipoCte = "";

		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, vFecVenc, vLimTar, vStatTjt, vTipoCte;
	END IF
END PROCEDURE;