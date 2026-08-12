CREATE PROCEDURE "informix".sp_valida_tarjetacte
(
   pEmpresa CHAR(3),
   pNumCte CHAR(9),
   pNumTarjeta CHAR(20)
)
RETURNING CHAR(6) AS CodRet ;

DEFINE	cCodRet CHAR(6);
DEFINE	iSql_err INTEGER;
DEFINE cNumcte CHAR(9);

LET cCodRet = '000000';
LET iSql_err = 0;
LET cNumcte = '';

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/respaldosbd/mario/sp_valida_tarjetacte.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pNumTarjeta,'') <> ''  THEN
			

		 SELECT  numcte
		 INTO cNumcte
		 FROM bdicheq:"informix".sc_tarjeta
		 WHERE empresa = pEmpresa
		 AND num_tarjeta = pNumTarjeta
		 AND status_tar = "A";

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			SELECT  numcte
			INTO cNumcte
			FROM bdicred:"informix".sd_tarjeta
			WHERE empresa = pEmpresa
			AND num_tarjeta = pNumTarjeta
			AND status_tar = "A";

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000002';
			END IF;
		END IF;
		
		IF cNumcte = pNumCte THEN
			LET cCodRet = '000000'; 
		ELSE
			LET cCodRet = '000003';
		END IF;
	ELSE
		LET cCodRet = '000001'; 
	END IF;	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
"Folio:1602",
"Autor:951421354 Mario Gallardo",
"Fecha:16/05/2014",
"Modificación: Se crea SP para validar que la tarjeta dezliada pertenesca a el cliente .",
"Sustento: RQI 12 231 Edo Cta Emisión Consulta Disponibilización y Respaldo OFI.pdf",
"Solicita: Rodolfo Gómez ",
"BD: bdiedoelec";

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
	--Modificado: Aida Valenzuela Benítez
	--Fecha: 18/09/2014
	--Descripción: Se agrega a la consulta de cuenta de captación el estatus de la tarjeta.
    -- ******************************************************************************************************************************************************

    BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN vCodRet, vCuenta, vTarjeta, vDescripcion, vstatus_serv;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/informix/bibiana/cons_sdos1.out";
		--TRACE ON;

		--- Valida que el cliente no sea Blanco
		IF pnum_cte = "000000000" THEN
			LET vCodRet = "110";
			RETURN vCodRet, vCuenta, vTarjeta, vDescripcion, vstatus_serv;
		END IF;

		SET ISOLATION DIRTY READ ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT SKIP pRegistro FIRST 10  mc.cuenta, mc.producto, pr.nombre--, tr.num_tarjeta
			INTO vCuenta, vProducto, vProdNom--, vTarjeta
			FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr--, bdicheq:"informix".sc_tarjeta as tr
			WHERE mc.num_cte = pnum_cte
			AND mc.status_cta in ('1', '3', '4', '5')
			AND pr.empresa = mc.empresa 
			AND pr.producto = mc.producto
			--AND tr.cuenta = mc.cuenta
			ORDER BY mc.cuenta

			
			SELECT num_tarjeta
			INTO vTarjeta
			FROM bdicheq:"informix".sc_tarjeta
			WHERE cuenta = vCuenta and status_tar='A';
			

 

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