CREATE PROCEDURE "informix".sp_cons_cre_cfdi_bpi(pempresa CHAR(3), pnum_cte CHAR(20))
	returning CHAR(5),CHAR(20),CHAR(20), CHAR(2),CHAR(20),CHAR(1),CHAR(55), CHAR(1);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
	DEFINE cod_ret			CHAR(5);
	DEFINE sql_err			INTEGER;
	DEFINE v_cuenta			CHAR(20);
	DEFINE v_numtarjeta		CHAR(20);
	DEFINE v_status_tar		CHAR(1);
	DEFINE v_status_cred	CHAR(2);
	DEFINE v_nombre_prod	CHAR(55);
	DEFINE v_secuencia		INTEGER;
	DEFINE vstatus_serv		CHAR(1);
	DEFINE v_numcte			CHAR(20);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
	LET cod_ret			= '00000';
	LET v_cuenta		= NULL;
	LET v_numtarjeta	= '';
	LET v_status_tar	= '';
	LET v_status_cred	= '';
	LET v_nombre_prod	= '';
	LET vstatus_serv	= '';
	LET v_numcte		= pnum_cte;
	
	--set debug file to "/home/informix/bibiana/cons_cre_bpi.out";
	--trace on;

	-- ******************************************************************************************************************************************************
    -- Creado por:			L.I. Manuel Ramos Figueroa
    -- Fecha: 2014/03/05
    -- Objetivo:			Consulta la cuentas de crédito del cliente y obtiene el status del servicio de estado de cuenta fiscal de cada cuenta
    -- ******************************************************************************************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cod_ret = sql_err;
				RETURN cod_ret, v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,vstatus_serv;
			END IF;
		END EXCEPTION;

		SET ISOLATION DIRTY READ ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT mc.num_credito,  mc.status_cred,  tr.num_tarjeta, tr.status_tar,  TRIM(df.num_producto) || ' ' || TRIM(df.nombre_prod)
			INTO v_cuenta, v_status_cred, v_numtarjeta, v_status_tar, v_nombre_prod
			FROM bdicred:"informix".sd_maecred mc
			JOIN bdicred:"informix".sd_tarjeta tr 
				ON (tr.empresa = pempresa AND mc.num_credito = tr.num_credito AND tr.tipo_tarjeta = 'T' AND mc.status_cred in ('AA','BA','BT','E1','E2','E3') 	--IFRS 
				AND secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where empresa = pempresa AND mc.num_credito = num_credito AND tipo_tarjeta = 'T'))
			JOIN bdicred:"informix".sd_definicion df 
				ON (df.num_producto = mc.num_producto)
			WHERE mc.numcte = pnum_cte
			UNION
			SELECT mcr.num_credito,  mcr.status_cred,  '', '',  TRIM(df.num_producto) || ' ' || TRIM(df.nombre_prod)
			FROM bdicred:"informix".sd_maecredcrd mcr
			JOIN bdicred:"informix".sd_definicion df 
				ON (df.num_producto = mcr.num_producto)
			WHERE mcr.numcte = pnum_cte
			AND mcr.status_cred IN('AA','BA','BT','VP','E1','E2','E3')	--IFRS 

			IF NVL(v_numtarjeta, "") = "" THEN
				LET v_numtarjeta = "No Aplica";
			END IF;

			SELECT status_serv_elec
			INTO vstatus_serv
			FROM bdiedoelec:"informix".edelec_alta_serv
			WHERE cuenta = v_cuenta;

			RETURN cod_ret, v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv, "") WITH RESUME;
		END FOREACH;

		IF v_cuenta IS NULL THEN
			LET cod_ret = 100;
			RETURN cod_ret, v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv, "");
		END IF;
	END
END PROCEDURE;