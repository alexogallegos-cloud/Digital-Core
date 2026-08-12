CREATE PROCEDURE "informix".sp_cons_cap_cfdi_bpi(pempresa CHAR(3), pnum_cte CHAR(20), pRegistro SMALLINT )
	returning char(5) as codRet, 
			  char(20) as numCta, 
			  char(20) as numTarjeta, 
			  char(55) as descripcion, 
			  char(1) as statusServ;

    -- Definición de variables
    DEFINE sql_err			integer;
    DEFINE iCont			integer;
	DEFINE vCodRet			char(5);
    DEFINE vCuenta			char(20);
	DEFINE vTarjeta			char(20);
	DEFINE vDescripcion		char(55);
    DEFINE vProducto		char(4);
    DEFINE vProdNom			char(35);
	DEFINE vedo_cta			char(1);
	DEFINE vstatus_serv		char(1);

    --- Inicializa Variables de Salida
    LET iCont			= 0;
	LET vCodRet			= "000";
    LET vCuenta			= "";
	LET vTarjeta		= "";
    LET vDescripcion	= "";
    LET vProducto		= " ";
    LET vProdNom		= " ";
	LET vedo_cta		= "";
	LET vstatus_serv	= "";
	
	-- ******************************************************************************************************************************************************
    -- Creado por:			L.I. Manuel Ramos Figueroa
    -- Fecha: 2014/03/05
    -- Objetivo:			Consulta la cuentas de captación del cliente y obtiene el status del servicio de estado de cuenta fiscal de cada cuenta
	-- Modificacion: GSM III Internet
	-- Fecha: 2020/06/16
	-- Se agrega script para consultar las cuentas de Pagaré
    -- ******************************************************************************************************************************************************

    BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN vCodRet, vCuenta, vTarjeta, vDescripcion, vstatus_serv;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/cons_sdos1.out";
		--TRACE ON;

		--- Valida que el cliente no sea Blanco
		IF pnum_cte = "000000000" THEN
			LET vCodRet = "110";
			RETURN vCodRet, vCuenta, vTarjeta, vDescripcion, vstatus_serv;
		END IF;

		SET ISOLATION DIRTY READ ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT SKIP pRegistro FIRST 10 cuenta,producto,nombre 
              INTO vCuenta, vProducto, vProdNom
            FROM
			(SELECT mc.cuenta, mc.producto, pr.nombre--, tr.num_tarjeta
			--INTO vCuenta, vProducto, vProdNom--, vTarjeta
			FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr--, bdicheq:"informix".sc_tarjeta as tr
			WHERE mc.num_cte = pnum_cte
			AND mc.status_cta in ('1', '3', '4', '5')
			AND pr.empresa = mc.empresa 
			AND pr.producto = mc.producto
			--AND tr.cuenta = mc.cuenta
			--ORDER BY mc.cuenta
            UNION  --Consulta para buscar cuentas Pagare
            SELECT  mv.cuenta,mv.cod_instrum, pr.nombre
            FROM     bdinvers:"informix".sv_maeinv  AS mv,
                     bdinvers:"informix".sv_instrum AS pr
            WHERE  mv.num_cte     = pnum_cte
            AND    mv.empresa='001'
            AND    mv.secuencia ='1'
            AND    mv.status_cta  IN ('4','2')
            AND    pr.empresa      = mv.empresa
            AND    pr.cod_instrum = mv.cod_instrum ) cuentas_cap

			SELECT num_tarjeta
			INTO vTarjeta
			FROM bdicheq:"informix".sc_tarjeta
			WHERE cuenta = vCuenta and status_tar = 'A' AND tipo_tarjeta='T';

			IF NVL(vTarjeta, "") = "" THEN
				LET vTarjeta = "No Aplica";
			END IF;

			SELECT status_serv_elec
			INTO vstatus_serv
			FROM bdiedoelec:"informix".edelec_alta_serv
			WHERE cuenta = vCuenta;

			LET iCont = iCont + 1;
			LET vDescripcion = vProducto || " " || vProdNom;

			RETURN vCodRet, vCuenta, vTarjeta, vDescripcion, NVL(vstatus_serv, "") WITH RESUME;
		END FOREACH;
		
		IF ( iCont = 0 AND pRegistro = 0 ) THEN
			LET vCodRet = '101'; --- Cliente No tiene cuentas
			RETURN vCodRet, vCuenta, vTarjeta, vDescripcion, vstatus_serv;
		END IF;
    END
END PROCEDURE;