CREATE PROCEDURE "informix".sp_validavtacredito_web(pEmpresa CHAR(3), pNumCred CHAR(20))
RETURNING CHAR (5)    AS CodRet,
		  CHAR (1)    AS Status;
		  
	DEFINE iSqlErr       	INTEGER;
	DEFINE cCodRet       	CHAR(5);
	DEFINE cStatus_Cred		CHAR(2);
	DEFINE cFechaHoy		CHAR(6);
	DEFINE cNumProd			CHAR(6);
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaRpt		DATE;
	DEFINE iId_Origen		INTEGER;
	DEFINE iRows			INTEGER;
	DEFINE cBand			CHAR(1);
	DEFINE cFechaRpt		CHAR(6);
	DEFINE bConsulta		BOOLEAN;
							  
	
							 
	LET iSqlErr       		= 0;
	LET cCodRet       		= '00000';
	LET cStatus_Cred    	= '';
	LET dtFechaHoy 			= '';	
	LET cFechaHoy 			= '';
	LET cNumProd 			= '';
	LET iId_Origen       	= 0;
	LET iRows       		= 0;
	LET cBand 				= '';
	LET dtFechaRpt 			= '';
	LET cFechaRpt 			= '';
	LET bConsulta 			= 'f';
	
	--SET DEBUG FILE TO '/tmp/sp_validavtacredito_web.out';
	--TRACE ON;
	
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pNumCred,'')) = '' THEN
		LET cCodRet = '00001';
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
	ELSE
	
		SELECT fecha_hoy INTO dtFechaHoy FROM "informix".sd_fechas;
		
		LET iRows = dbinfo("sqlca.sqlerrd2");
		
		IF NVL(iRows,0) <> 0 THEN
			LET cFechaHoy = LPAD(YEAR(dtFechaHoy),4,"0") || LPAD(MONTH(dtFechaHoy),2,"0");
		ELSE
			LET cCodRet = '00004';
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
		END IF;
		
		LET iRows = 0;
		
		SELECT DISTINCT num_producto,status_cred,id_unidad_prod
		INTO cNumProd,cStatus_Cred,iId_Origen
		FROM "informix".sd_maecred 
																									   
		WHERE num_credito = TRIM(NVL(pNumCred,'')) AND empresa = TRIM(NVL(pEmpresa,''));
		
		LET iRows = dbinfo("sqlca.sqlerrd2");
		
		IF NVL(iRows,0) = 0 THEN
		
			LET iRows = 0;
			
			SELECT DISTINCT num_producto,status_cred,id_origen
			INTO cNumProd,cStatus_Cred,iId_Origen
			FROM "informix".sd_maecredcrd 
																										   
			WHERE num_credito = TRIM(NVL(pNumCred,'')) AND empresa = TRIM(NVL(pEmpresa,''));
			
			LET iRows = dbinfo("sqlca.sqlerrd2");
			
			IF NVL(iRows,0) = 0 THEN
				LET cCodRet = '00002';
				LET cBand 	= '';
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
			END IF;
			
		END IF;	
		
		LET iRows = 0;

		IF TRIM(NVL(cNumProd,'')) <> '6500' THEN
		
			IF TRIM(NVL(cNumProd,'')) = '6011'THEN
				IF cStatus_Cred IN ('BT','VP','E2','E3') AND NVL(iId_Origen,0) = 1 THEN
					LET bConsulta = 't';
				END IF;
			ELSE
				IF cStatus_Cred IN ('BT','E2','E3') AND NVL(iId_Origen,0) = 1 THEN
					LET bConsulta = 't';
				END IF;			
			END IF;
			
			IF bConsulta = 't' THEN
				IF EXISTS(SELECT MAX(fechareporte) FROM bdicobranza: "informix".cb_rep_cart_quebrantar
				WHERE num_credito = TRIM(NVL(pNumCred,''))) THEN
					LET cBand = '2';	
				ELSE
					LET cBand = '3';		
				END IF;
			ELIF TRIM(NVL(cStatus_Cred,'')) = 'CV' THEN	
				LET cBand = '1';
			ELSE
				LET cBand = '3';
			END IF;
		ELSE
			LET cBand = '4';	
		END IF;
		
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cBand,''));
		
	END IF;
			  
END	
END PROCEDURE
DOCUMENT
'AUTOR: ISARAI BOJORQUEZ',
'FECHA: 06/06/2016',
'MODIFICACION: ESTE PROCEDIMIENTO INDICA SI EL CRÃDITO QUE SE CONSULTA EN LA CAJA ESTA EN PROCESO DE VENTA O VENDIDO',
'BD: BDICRED';

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
    -- Objetivo:			Consulta la cuentas de crÃ©dito del cliente y obtiene el status del servicio de estado de cuenta fiscal de cada cuenta
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
				ON (tr.empresa = pempresa AND mc.num_credito = tr.num_credito AND tr.tipo_tarjeta = 'T' AND mc.status_cred in ('AA','BA','BT','E1','E2','E3') 
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
			AND mcr.status_cred IN('AA','BA','BT','VP','E1','E2','E3')

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