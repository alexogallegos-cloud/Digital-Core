CREATE PROCEDURE "informix".consctestjt(pEmpresa char(3), pNumeroCuenta char(26), pNumeroCliente char(20))
	-- DATOS A REGRESAR --
	RETURNING
	char(5),     -- Codigo de retorno
	char(20),    -- # Cliente
	char(26),    -- Apellido paterno
	char(26),    -- Apellido materno
	char(26),    -- Nombre 1
	char(26),    -- Nombre 2
	char(13),    -- RFC
	char(16),    -- # Tarjeta
	char(5),     -- Fecha vencimiento
	money(14,2), -- Limite de retiro maximo por mes
	char(1),     -- Status tarjeta
	char(8);     -- Tipo de cliente

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
	DEFINE vRFC_alterno char(13);

	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  = "000";
	LET vCantReg = 0;
	LET vRFC_alterno = "";

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3 ;

	-- BUSCAR QUE TIPO DE CLIENTE ES [ TITULAR O FIRMANTE] --
	LET	vTipCte = "";

	SELECT
		'T' AS tipo_cliente, sc_mcq.num_cte
	INTO
		vTipCte, vNumCte
	FROM
		bdicheq:sc_maechq AS sc_mcq
	WHERE
		sc_mcq.empresa = pEmpresa AND
		sc_mcq.cuenta  = pNumeroCuenta AND
		sc_mcq.num_cte = pNumeroCliente;



	IF vTipCte = 'T' THEN
		-- CICLO PARA OBTENER AL TITULAR Y LOS FIRMANTES Y LAS TARJETAS DE CREDITO EN CASO DE QUE TENGAN --
		FOREACH
			SELECT DISTINCT
				si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno, 'Titular' AS tipo_cliente
			FROM
				bdicheq:sc_maechq AS sc_mcq,
				bdinteg:si_cliente AS si_cte
			WHERE
				sc_mcq.empresa = pEmpresa AND sc_mcq.cuenta =  pNumeroCuenta AND
				sc_mcq.num_cte = si_cte.numcte AND  si_cte.empresa = pEmpresa

			UNION ALL

			SELECT DISTINCT
				si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno, 'Firmante' AS tipo_cliente
			INTO
				vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vTipoCte
			FROM
				bdicheq:sc_firmantes AS sc_fir,
				bdinteg:si_cliente AS si_cte
			WHERE
				sc_fir.empresa =  pEmpresa AND sc_fir.cuenta =  pNumeroCuenta AND sc_fir.numcte != vNumCte AND
				sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa

			IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
               LET vRFC = vRFC_alterno;
            END IF;			
			
			-- OBTENER LA TARJETA DEL TITULAR O FIRMANTE --
			SELECT
				sc_tjt.num_tarjeta, SUBSTRING(TO_CHAR(sc_tjt.expiracion, "%y-%m-%d") FROM 1 FOR 5), sc_tjt.limite_aut, sc_tjt.status_tar
			INTO
				vNumTarj, vFecVenc, vLimTar, vStatTjt
			FROM
				bdicheq:sc_tarjeta AS sc_tjt
			WHERE
				sc_tjt.empresa = pEmpresa AND
				sc_tjt.cuenta = pNumeroCuenta AND
				sc_tjt.numcte = vNumCte AND
				sc_tjt.secuencia = (SELECT MAX(sc_tjt.secuencia) FROM bdicheq:sc_tarjeta AS sc_tjt WHERE sc_tjt.empresa = pEmpresa AND sc_tjt.cuenta = pNumeroCuenta AND sc_tjt.numcte = vNumCte);


			IF vNumTarj IS NULL THEN
				LET vNumTarj = "Sin tarjeta";
				LET vLimTar  = 0;
				LET vStatTjt = "";
			END IF

			LET vCantReg = vCantReg + 1;

			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, vFecVenc, vLimTar, vStatTjt, vTipoCte WITH RESUME;
		END FOREACH;
	ELSE
		-- OBTENER LAS TARJETAS DEL FIRMANTE
		SELECT DISTINCT
			si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno, 'Firmante' AS tipo_cliente
		INTO
			vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vTipoCte
		FROM
			bdicheq:sc_firmantes AS sc_fir,
			bdinteg:si_cliente AS si_cte
		WHERE
			sc_fir.empresa =  pEmpresa AND sc_fir.cuenta =  pNumeroCuenta AND sc_fir.numcte = pNumeroCliente AND
			sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa;

        IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
           LET vRFC = vRFC_alterno;
        END IF;		
			
		-- OBTENER LA TARJETA DEL FIRMANTE --
		SELECT DISTINCT
			sc_tjt.num_tarjeta, SUBSTRING(TO_CHAR(sc_tjt.expiracion, "%y-%m-%d") FROM 1 FOR 5), sc_tjt.limite_aut, sc_tjt.status_tar
		INTO
			vNumTarj, vFecVenc, vLimTar, vStatTjt
		FROM
			bdicheq:sc_tarjeta AS sc_tjt
		WHERE
			sc_tjt.empresa = pEmpresa AND
			sc_tjt.cuenta = pNumeroCuenta AND
			sc_tjt.numcte = vNumCte AND
			sc_tjt.secuencia = (SELECT MAX(sc_tjt.secuencia) FROM bdicheq:sc_tarjeta AS sc_tjt WHERE sc_tjt.empresa = pEmpresa AND sc_tjt.cuenta = pNumeroCuenta AND sc_tjt.numcte = vNumCte);


		IF vNumTarj IS NULL THEN
			LET vNumTarj = "Sin tarjeta";
			LET vLimTar  = 0;
			LET vStatTjt = "";
		END IF

		LET vCantReg = vCantReg + 1;

		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, vFecVenc, vLimTar, vStatTjt, vTipoCte;
	END IF

	IF vCantReg = 0 THEN
		LET vCodRet  = "141";
		LET vNumCte  = "";
		LET vApePat  = "";
		LET vApeMat  = "";
		LET vNombre1 = "";
		LET vNombre2 = "";
		LET vRFC     = "";
		LET vNumTarj = "";
		LET vLimTar  = 0;
		LET vStatTjt = "";
		LET vTipoCte = "";
		LET vFecVenc = "";

		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, vFecVenc, vLimTar, vStatTjt, vTipoCte;
	END IF
END PROCEDURE
;