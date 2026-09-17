CREATE PROCEDURE "informix".consctesfircaja_web(pEmpresa char(3), pNumeroCuenta char(20), pNumeroCliente char(20))
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
	date,    	--	Expiracion
	char(4),    -- Producto tarjeta
	money(14,2),-- Limite de retiro maximo por mes
	char(1),    -- Status tarjeta
	char(8),    -- Tipo de cliente
	char(10),   -- Fecha de Nacimiento
	char(4),    -- Producto de la cuenta
	char(2);    -- Parentesco

	-- VARIABLES --
	DEFINE vCodRet  char(5);
	DEFINE vTipCte  char(1);
	Define vSecuencia char(1);
	DEFINE vNumCte	char(20);
	DEFINE vApePat  char(26);
	DEFINE vApeMat  char(26);
	DEFINE vNombre1 char(26);
	DEFINE vNombre2 char(26);
	DEFINE vRFC     char(13);
	DEFINE vNumTarj char(16);
	DEFINE Vexpiracion date;
	DEFINE Vprodtarjeta char(4);
	DEFINE vLimTar  money(14,2);
	DEFINE vTipoCte char(8);
	DEFINE vStatTjt char(1);
	DEFINE vFechaNac char(10);
	DEFINE vProductoCuenta char(4);
	DEFINE vCantReg smallint;
	DEFINE vParentesco char(2);

--set debug file to "/respaldosbd/consctesfircaja.out";
--trace on;
	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  = "00000";
	LET vCantReg = 0;
	LET vTipCte = "";
	LET vNumCte = "";
	LET vApePat = "";
	LET vApeMat = "";
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vRFC = "";
	LET vNumTarj = "";
	LET Vexpiracion = "";
	LET Vprodtarjeta = "";
	LET vLimTar = "";
	LET vTipoCte = "";
	LET vStatTjt = "";
	LET vFechaNac = "";
	LET vProductoCuenta = "";
	LET vParentesco = "";
	LET vSecuencia = "";
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;

	-- CICLO PARA OBTENER A LOS FIRMANTES Y LAS TARJETAS DE DEBITO EN CASO DE QUE TENGAN --
	FOREACH
		SELECT DISTINCT
			sc_fir.secuencia,si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 'Firmante' AS tipo_cliente,si_pf.fecha_nac, sc_mcq.producto, sc_fir.parentesco
		INTO
			vSecuencia, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte, vFechaNac, vProductoCuenta, vParentesco
		FROM
			bdicheq:"informix".sc_maechq sc_mcq,
			bdicheq:"informix".sc_firmantes AS sc_fir,
			bdinteg:"informix".si_cliente AS si_cte,
			bdinteg:"informix".si_ctepf AS si_pf
		WHERE
			sc_fir.empresa =  pEmpresa AND sc_fir.cuenta =  pNumeroCuenta AND sc_fir.numcte = si_cte.numcte 
			AND si_cte.empresa = pEmpresa AND sc_fir.numcte = si_pf.numcte  AND
			sc_mcq.empresa = pEmpresa AND sc_mcq.cuenta = pNumeroCuenta
			Order By sc_fir.secuencia

		-- OBTENER LA TARJETA DEL FIRMANTE --
		SELECT DISTINCT
			sc_tjt.expiracion, sc_tjt.prodtarjeta, sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
		INTO
			Vexpiracion, Vprodtarjeta, vNumTarj, vLimTar, vStatTjt
		FROM
			bdicheq:"informix".sc_tarjeta AS sc_tjt
		WHERE
			sc_tjt.empresa = pEmpresa AND
			sc_tjt.cuenta = pNumeroCuenta AND
			sc_tjt.numcte = vNumCte AND
			sc_tjt.status_tar = 'A' AND				  
			sc_tjt.tipo_tarjeta = 'A';

		IF vNumTarj IS NULL THEN
			LET vNumTarj = "Sin tarjeta";
			LET vLimTar = 0;
			LET vStatTjt = "";
		END IF

		LET vCantReg = vCantReg + 1;

		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco  WITH RESUME;
	END FOREACH;

	IF vCantReg = 0 THEN
		LET vCodRet  = "00001";
		LET vNumCte  = "-";
		LET vApePat  = "-";
		LET vApeMat  = "-";
		LET vNombre1 = "-";
		LET vNombre2 = "-";
		LET vRFC     = "-";
		LET vNumTarj = "0";
		LET Vexpiracion = "01-01-1990";
		LET Vprodtarjeta = "0";
		LET vLimTar  = 0;
		LET vStatTjt = "0";
		LET vTipoCte = "0";
		LET vFechaNac = "01-01-1990";
		LET vParentesco  = "0";

		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco;
	END IF
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica para que consulte todos los status de tarjetas',
'             incluyendo las tarjetas canceladas',
'EJECUTADO O LLAMADO POR: AsigAdic.exe',
'AUTOR : Martin Eduardo Miranda Miranda',
'FECHA : 14/Septiembre/2010',
'BD    : BDICHEQ',
'DESCRIPCION: Se modifica para que muestre el titular y los firmantes ademas de que se ordene por secuencia',
'AUTOR : Martin Eduardo Miranda Miranda',
'FECHA : 07/abril/2011',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".consnumctapornumcte_web(pEmpresa CHAR(3), pNumCliente CHAR(20))

	RETURNING
	CHAR(5) ,  -- Codigo de retorno
	CHAR(20); -- Numero de cuenta

	DEFINE v_cod_ret CHAR(5);
	DEFINE v_cuenta  CHAR(20);
	DEFINE v_ciclo   INTEGER;
	

	LET v_cod_ret = "00000";
	LET v_cuenta  = "";
	LET v_ciclo   = 0;
	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;

	FOREACH
		SELECT {+INDEX(sc_firmantes fir2)} cuenta
		INTO v_cuenta
		FROM bdicheq:sc_firmantes
		WHERE empresa = pEmpresa 
                AND numcte = pNumCliente
		ORDER BY cuenta

		IF NOT v_cuenta is null THEN
			LET v_ciclo = v_ciclo + 1;

			RETURN v_cod_ret, v_cuenta WITH RESUME;
		END IF

	END FOREACH;

	IF  v_ciclo = 0 THEN
		RETURN "00101", "No hay cuentas";
	END IF

END PROCEDURE;