CREATE PROCEDURE "informix".sp_consremcambiost(pConfirmation_nm CHAR (11), pTrans_Status_Dt DATE)
	--DATOS A REGRESAR---
    RETURNING
    CHAR(5), CHAR(15), CHAR(15), CHAR(3), CHAR(20), CHAR(50), CHAR(5), CHAR(5), CHAR(10), CHAR(80),
	CHAR(5), CHAR(50), CHAR(50), CHAR(50), CHAR(3), CHAR(15), CHAR(1), CHAR(8), CHAR(20), CHAR(50),
	CHAR(20);

	--DEFINICION DE VARIABLES--
    DEFINE sql_err              INT;
    DEFINE cCodRet              CHAR(5);
	DEFINE cSucursal            CHAR(15);
	DEFINE cTerminal            CHAR(15);
	DEFINE cSucursalsif         CHAR(15);
	DEFINE cTerminalsif         CHAR(15);
	DEFINE cR_Type_Cd           CHAR(3);
	DEFINE cR_Identif_Nm        CHAR(20);
	DEFINE cR_Nom_Calle         CHAR(50);
	DEFINE cR_Num_Ext           CHAR(5);
	DEFINE cR_Num_Int           CHAR(5);
	DEFINE cR_Depto             CHAR(10);
	DEFINE cR_Colonia           CHAR(80);
	DEFINE cR_Cp                CHAR(5);
	DEFINE cR_Mncpo_Deleg       CHAR(50);
	DEFINE cR_Ciudad            CHAR(50);
	DEFINE cR_Estado            CHAR(50);
	DEFINE cR_Issuer_Country_Cd CHAR(3);
	DEFINE cR_Telefono          CHAR(15);
	DEFINE cTipo_Pago           CHAR(1);
	DEFINE cR_Fecha_Nac         CHAR(8);
	DEFINE cR_Nacionalidad      CHAR(50);
	DEFINE cR_pais_nac			CHAR(20);
	DEFINE dFechaHoy            DATE;
	DEFINE cFolio_Suc           CHAR(20);
	DEFINE cProcess_Dt          CHAR(8);
	DEFINE cFolio_SucPayi       CHAR(20);
	DEFINE cSucursalBts         CHAR(4);
	DEFINE iCount         		INT;
	DEFINE iCountPayi			INT;
	DEFINE iCountRevi			INT;

    --INICIALIZACION DE VARIABLES--
    LET sql_err                 = 0;
    LET cCodRet                 = '00000';
	LET cSucursal               = '';
	LET cTerminal               = '';
	LET cSucursalsif            = '';
	LET cTerminalsif            = '';
	LET cR_Type_Cd              = '';
	LET cR_Identif_Nm           = '';
	LET cR_Nom_Calle            = '';
	LET cR_Num_Ext              = '';
	LET cR_Num_Int              = '';
	LET cR_Depto                = '';
	LET cR_Colonia              = '';
	LET cR_Cp                   = '';
	LET cR_Mncpo_Deleg          = '';
	LET cR_Ciudad               = '';
	LET cR_Estado               = '';
	LET cR_Issuer_Country_Cd    = '';
	LET cR_Telefono             = '';
	LET cTipo_Pago              = '';
	LET cR_Fecha_Nac            = '';
	LET cR_Nacionalidad         = '';
	LET cR_pais_nac				= '';
	LET dFechaHoy               = "01-01-1900";
	LET cFolio_Suc              = '';
	LET cProcess_Dt             = '';
	LET cFolio_SucPayi          = '';
	LET cSucursalBts            = '';
	LET iCount                  = 0;
	LET iCountPayi              = 0;
	LET iCountRevi              = 0;

		--SET DEBUG FILE TO "/tmp/JA/sp_consremcambiost.out";
    	--TRACE ON;

	BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
                RETURN cCodRet, TRIM(NVL(cSucursal,'')), TRIM(NVL(cTerminal,'')), TRIM(NVL(cR_Type_Cd,'')), TRIM(NVL(cR_Identif_Nm,'')), TRIM(NVL(cR_Nom_Calle,'')), TRIM(NVL(cR_Num_Ext,'')), TRIM(NVL(cR_Num_Int,'')), TRIM(NVL(cR_Depto,'')), TRIM(NVL(cR_Colonia,'')),
                TRIM(NVL(cR_Cp,'')), TRIM(NVL(cR_Mncpo_Deleg,'')), TRIM(NVL(cR_Ciudad,'')), TRIM(NVL(cR_Estado,'')), TRIM(NVL(cR_Issuer_Country_Cd,'')), TRIM(NVL(cR_Telefono,'')), TRIM(NVL(cTipo_Pago,'')), TRIM(NVL(cR_Fecha_Nac,'')), TRIM(NVL(cR_Nacionalidad,'')),
                TRIM(NVL(cR_pais_nac,'')), TRIM(NVL(cFolio_SucPayi,''));
        END IF;
    END EXCEPTION;

	IF pConfirmation_nm = "" OR pConfirmation_nm IS NULL OR pTrans_Status_Dt = "" OR pTrans_Status_Dt IS NULL THEN
	    LET cCodRet = '00001';
	    RETURN cCodRet, cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, cR_Depto, cR_Colonia,
		cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad,
		cR_pais_nac, cFolio_SucPayi;
	END IF;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	SELECT fecha_hoy
    INTO dFechaHoy
    FROM bdisac:"informix".sac_fechas;

	LET cProcess_Dt  = SUBSTRING(pTrans_Status_Dt FROM 7 FOR 4)||SUBSTRING(pTrans_Status_Dt FROM 1 FOR 2)||SUBSTRING(pTrans_Status_Dt FROM 4 FOR 2);

	SELECT valor INTO cTerminalsif FROM bdisac:sac_param WHERE cod_param = '87016';
	
	IF pTrans_Status_Dt = dFechaHoy THEN
		SELECT LIMIT 1 NVL(folio_suc,''), id_sucursal
		INTO cFolio_Suc, cSucursalsif
		FROM bdisac:"informix".sac_movimientos
		WHERE numcategoria = '07'
		AND numconvenio IN ('004', '005')
		AND referencia1 = pConfirmation_nm
		AND flag_confirmacion_central='1'
		AND fecha_insert = (SELECT MAX(fecha_insert)
					FROM bdisac:"informix".sac_movimientos
					WHERE numcategoria = '07'
					AND numconvenio IN ('004', '005')
					AND referencia1 = pConfirmation_nm
					AND flag_confirmacion_central='1');

    ELIF pTrans_Status_Dt < dFechaHoy THEN
	    SELECT LIMIT 1 NVL(folio_suc,''), id_sucursal
		INTO cFolio_Suc, cSucursalsif
		FROM bdisac:"informix".sac_movimientoshistorial
		WHERE numcategoria = '07'
		AND numconvenio IN ('004', '005')
		AND referencia1 = pConfirmation_nm
		AND flag_confirmacion_central='1'
		AND ROWID = (SELECT MAX(ROWID)
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = '07'
					AND numconvenio IN ('004', '005')			
					AND referencia1 = pConfirmation_nm
					AND flag_confirmacion_central='1');

	ELIF pTrans_Status_Dt > dFechaHoy THEN
	     LET cCodRet = '00002'; -- FECHA INVALIDA
	END IF;

	IF cCodRet = '00000' THEN
		SELECT valor 
		INTO cSucursalBts
		FROM bdisac:"informix".sac_param 
		WHERE cod_param = '999';
		
		SELECT COUNT(*)
		INTO iCountPayi
		FROM bdisac:"informix".sac_bts_payi
		WHERE confirmation_nm = pConfirmation_nm
		AND opcode = '1100'
		AND branch_sd = cSucursalBts;
		
		SELECT COUNT(*)
		INTO iCountRevi
		FROM bdisac:"informix".sac_bts_revi
		WHERE confirmation_nm = pConfirmation_nm
		AND opcode = '1200'
		AND branch_sd = cSucursalBts;
		
		LET iCount = iCountPayi + iCountRevi;
		IF(iCount > 1) THEN
			LET cCodRet = '00005';
		END IF;
	END IF;
	
	IF cCodRet = '00000' THEN
		IF	SUBSTR (cFolio_Suc, 1, 7) = 'sys_bts' THEN
			LET cFolio_SucPayi = cFolio_Suc;
			LET cSucursal = cSucursalsif;
			LET cTerminal = cTerminalsif;
			RETURN cCodRet, TRIM(NVL(cSucursal,'')), TRIM(NVL(cTerminal,'')), TRIM(NVL(cR_Type_Cd,'')), TRIM(NVL(cR_Identif_Nm,'')), TRIM(NVL(cR_Nom_Calle,'')), TRIM(NVL(cR_Num_Ext,'')), TRIM(NVL(cR_Num_Int,'')), TRIM(NVL(cR_Depto,'')), TRIM(NVL(cR_Colonia,'')),
			TRIM(NVL(cR_Cp,'')), TRIM(NVL(cR_Mncpo_Deleg,'')), TRIM(NVL(cR_Ciudad,'')), TRIM(NVL(cR_Estado,'')), TRIM(NVL(cR_Issuer_Country_Cd,'')), TRIM(NVL(cR_Telefono,'')), TRIM(NVL(cTipo_Pago,'')), TRIM(NVL(cR_Fecha_Nac,'')), TRIM(NVL(cR_Nacionalidad,'')),
			TRIM(NVL(cR_pais_nac,'')), TRIM(NVL(cFolio_SucPayi,''));
		ELSE
			IF cFolio_Suc <> '' AND cFolio_Suc IS NOT NULL THEN
				IF EXISTS(SELECT sucursal FROM bdisac:"informix".sac_bts_payi WHERE confirmation_nm = pConfirmation_nm
					   AND bank_ref_nm = cFolio_Suc AND opcode = '1100' AND process_dt = cProcess_Dt) THEN

					SELECT branch_sd, terminal, r_type_cd, r_identif_nm, R_nom_calle, R_num_ext, R_num_int, R_depto, R_colonia,
					   R_cp, R_mncpo_deleg, R_ciudad, R_estado, r_issuer_country_cd, R_telefono, Tipo_pago, R_fecha_nac,  R_nacionalidad,
					   r_pais_nac, bank_ref_nm
					INTO cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, cR_Depto, cR_Colonia,
					  cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad,
					  cR_pais_nac, cFolio_SucPayi
					FROM bdisac:"informix".sac_bts_payi
					WHERE confirmation_nm = pConfirmation_nm
					AND bank_ref_nm = cFolio_Suc
					AND opcode = '1100'
					AND process_dt = cProcess_Dt
					AND ROWID = (SELECT MAX(ROWID)
							FROM bdisac:"informix".sac_bts_payi
							WHERE confirmation_nm = pConfirmation_nm
							AND bank_ref_nm = cFolio_Suc
							AND opcode = '1100'
							AND process_dt = cProcess_Dt);
				ELIF EXISTS(SELECT sucursal FROM bdisac:"informix".sac_bts_payi WHERE confirmation_nm = pConfirmation_nm
					   AND bank_ref_nm = cFolio_Suc) THEN

					SELECT branch_sd, terminal, r_type_cd, r_identif_nm, R_nom_calle, R_num_ext, R_num_int, R_depto, R_colonia,
					   R_cp, R_mncpo_deleg, R_ciudad, R_estado, r_issuer_country_cd, R_telefono, Tipo_pago, R_fecha_nac,  R_nacionalidad,
					   r_pais_nac, bank_ref_nm
					INTO cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, cR_Depto, cR_Colonia,
					  cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad,
					  cR_pais_nac, cFolio_SucPayi
					FROM bdisac:"informix".sac_bts_payi
					WHERE confirmation_nm = pConfirmation_nm
					AND bank_ref_nm = cFolio_Suc
					AND ROWID = (SELECT MAX(ROWID)
							FROM bdisac:"informix".sac_bts_payi
							WHERE confirmation_nm = pConfirmation_nm
							AND bank_ref_nm = cFolio_Suc);
				ELSE
					LET cCodRet = '00003';
				END IF;
			ELSE
			LET cCodRet = '00004';
				IF EXISTS(SELECT sucursal FROM bdisac:"informix".sac_bts_payi WHERE confirmation_nm = pConfirmation_nm 
							AND branch_sd = cSucursalBts AND process_dt = cprocess_dt) THEN
					LET cCodRet = '00006';
				END IF;
			END IF;
		END IF;
	END IF;
	RETURN cCodRet, TRIM(NVL(cSucursal,'')), TRIM(NVL(cTerminal,'')), TRIM(NVL(cR_Type_Cd,'')), TRIM(NVL(cR_Identif_Nm,'')), TRIM(NVL(cR_Nom_Calle,'')), TRIM(NVL(cR_Num_Ext,'')), TRIM(NVL(cR_Num_Int,'')), TRIM(NVL(cR_Depto,'')), TRIM(NVL(cR_Colonia,'')),
	TRIM(NVL(cR_Cp,'')), TRIM(NVL(cR_Mncpo_Deleg,'')), TRIM(NVL(cR_Ciudad,'')), TRIM(NVL(cR_Estado,'')), TRIM(NVL(cR_Issuer_Country_Cd,'')), TRIM(NVL(cR_Telefono,'')), TRIM(NVL(cTipo_Pago,'')), TRIM(NVL(cR_Fecha_Nac,'')), TRIM(NVL(cR_Nacionalidad,'')),
	TRIM(NVL(cR_pais_nac,'')), TRIM(NVL(cFolio_SucPayi,''));
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener informacion del registro de una remesa pagada cuando se consulta desde plataforma',
'AUTOR : Jose Angel Gaxiola',
'FECHA : 22/Abril/2013',
'Ver.  : 1.1',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_validarembtsensac(pNumConfirmation CHAR(11), pFolioSucursal CHAR(16), pFechaTransStatus DATE)
	-- DATOS A REGRESAR --
	RETURNING
		CHAR(6)  AS CodRet, 
		CHAR(15) AS Sucursal,
		CHAR(15) AS Terminal,
		CHAR(3)  AS R_Type_Cd,
		CHAR(20) AS R_Identif_Nm,
		CHAR(50) AS Nom_Calle,
		CHAR(5)  AS Num_Ext,
		CHAR(5)  AS Num_Int,
		CHAR(10) AS Depto,
		CHAR(80) AS Colonia,
		CHAR(5)  AS CP,
		CHAR(50) AS Mncpo_Deleg,
		CHAR(50) AS Ciudad,
		CHAR(50) AS Estado,
		CHAR(3)  AS Issuer_Country_Cd,
		CHAR(15) AS Telefono,
		CHAR(1)  AS Tipo_pago,
		CHAR(8)  AS Fecha_Nac,
		CHAR(50) AS Nacionalidad,
		CHAR(20) AS Pais_NAC,
		CHAR(20) AS FolioSucursal,
		CHAR(21) AS R_issuer_cd,
		CHAR(22) AS R_expiration_dt;
		
	-- DEFINICION DE VARIABLES 
    DEFINE iSqlErr              INTEGER;
    DEFINE cCodRet              CHAR(6);
	DEFINE dFechaHoy            DATE;
	DEFINE cSucursal            CHAR(15);
	DEFINE cTerminal            CHAR(15);
	DEFINE cR_Type_Cd           CHAR(3);
	DEFINE cR_Identif_Nm        CHAR(20);
	DEFINE cR_Nom_Calle         CHAR(50);
	DEFINE cR_Num_Ext           CHAR(5);
	DEFINE cR_Num_Int           CHAR(5);
	DEFINE cR_Depto             CHAR(10);
	DEFINE cR_Colonia           CHAR(80);
	DEFINE cR_Cp                CHAR(5);
	DEFINE cR_Mncpo_Deleg       CHAR(50);
	DEFINE cR_Ciudad            CHAR(50);
	DEFINE cR_Estado            CHAR(50);
	DEFINE cR_Issuer_Country_Cd CHAR(3);
	DEFINE cR_Telefono          CHAR(15);
	DEFINE cTipo_Pago           CHAR(1);
	DEFINE cR_Fecha_Nac         CHAR(8);
	DEFINE cR_Nacionalidad      CHAR(50);
	DEFINE cR_pais_nac			CHAR(20);
	DEFINE cFolioSucursal       CHAR(20);
	DEFINE cProcess_Dt          CHAR(8);
	DEFINE cR_issuer_cd         CHAR(3);
	DEFINE cR_expiration_dt     CHAR(8);
	
	-- INICIALIZACION DE VARIABLES
    LET iSqlErr                 = 0;
    LET cCodRet                 = '000000';
	LET dFechaHoy               = DATE(1);
	
	LET cSucursal               = '';
	LET cTerminal               = '';
	LET cR_Type_Cd              = '';
	LET cR_Identif_Nm           = '';
	LET cR_Nom_Calle            = '';
	LET cR_Num_Ext              = '';
	LET cR_Num_Int              = '';
	LET cR_Depto                = '';
	LET cR_Colonia              = '';
	LET cR_Cp                   = '';
	LET cR_Mncpo_Deleg          = '';
	LET cR_Ciudad               = '';
	LET cR_Estado               = '';
	LET cR_Issuer_Country_Cd    = '';
	LET cR_Telefono             = '';
	LET cTipo_Pago              = '';
	LET cR_Fecha_Nac            = '';
	LET cR_Nacionalidad         = '';
	LET cR_pais_nac				= '';
	LET cFolioSucursal			= '';
	LET cProcess_Dt             = '';
	LET cR_issuer_cd            = '';
	LET cR_expiration_dt		= '';
	
		--SET DEBUG FILE TO "/tmp/JA/sp_validarembtsensac.out";
		--TRACE ON;
	
BEGIN
	
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet, TRIM(NVL(cSucursal,'')), TRIM(NVL(cTerminal,'')), TRIM(NVL(cR_Type_Cd,'')), TRIM(NVL(cR_Identif_Nm,'')), TRIM(NVL(cR_Nom_Calle,'')), TRIM(NVL(cR_Num_Ext,'')), TRIM(NVL(cR_Num_Int,'')), TRIM(NVL(cR_Depto,'')), TRIM(NVL(cR_Colonia,'')),
				   TRIM(NVL(cR_Cp,'')), TRIM(NVL(cR_Mncpo_Deleg,'')), TRIM(NVL(cR_Ciudad,'')), TRIM(NVL(cR_Estado,'')), TRIM(NVL(cR_Issuer_Country_Cd,'')), TRIM(NVL(cR_Telefono,'')), TRIM(NVL(cTipo_Pago,'')), TRIM(NVL(cR_Fecha_Nac,'')), TRIM(NVL(cR_Nacionalidad,'')),
				   TRIM(NVL(cR_pais_nac,'')), TRIM(NVL(cFolioSucursal,'')), TRIM(NVL(cR_issuer_cd,'')),TRIM(NVL(cR_expiration_dt,''));
        END IF;
    END EXCEPTION;
	
	IF TRIM(NVL(pNumConfirmation,"")) = "" OR TRIM(NVL(pFolioSucursal,"")) = ""  OR TRIM(NVL(pFechaTransStatus,"")) = "" THEN
	    LET cCodRet = '000001'; -- FALTAN PARAMETROS OBLIGATORIOS.
		RETURN cCodRet, TRIM(NVL(cSucursal,'')), TRIM(NVL(cTerminal,'')), TRIM(NVL(cR_Type_Cd,'')), TRIM(NVL(cR_Identif_Nm,'')), TRIM(NVL(cR_Nom_Calle,'')), TRIM(NVL(cR_Num_Ext,'')), TRIM(NVL(cR_Num_Int,'')), TRIM(NVL(cR_Depto,'')), TRIM(NVL(cR_Colonia,'')),
			   TRIM(NVL(cR_Cp,'')), TRIM(NVL(cR_Mncpo_Deleg,'')), TRIM(NVL(cR_Ciudad,'')), TRIM(NVL(cR_Estado,'')), TRIM(NVL(cR_Issuer_Country_Cd,'')), TRIM(NVL(cR_Telefono,'')), TRIM(NVL(cTipo_Pago,'')), TRIM(NVL(cR_Fecha_Nac,'')), TRIM(NVL(cR_Nacionalidad,'')),
			   TRIM(NVL(cR_pais_nac,'')), TRIM(NVL(cFolioSucursal,'')), TRIM(NVL(cR_issuer_cd,'')),TRIM(NVL(cR_expiration_dt,''));
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	-- OBTENEMOS LA FECHA ACTUAL.
	SELECT fecha_hoy
    INTO dFechaHoy
    FROM bdisac:"informix".sac_fechas;
	
	-- OBTENEMOS LA FECHA PROCESO.
	LET cProcess_Dt  = SUBSTRING(pFechaTransStatus FROM 7 FOR 4)||SUBSTRING(pFechaTransStatus FROM 1 FOR 2)||SUBSTRING(pFechaTransStatus FROM 4 FOR 2);
	
	IF pFechaTransStatus = dFechaHoy THEN
		SELECT LIMIT 1 NVL(folio_suc,'') 
		INTO cFolioSucursal
		FROM bdisac:"informix".sac_movimientos 
		WHERE fecha_pago = pFechaTransStatus
		  AND numcategoria = '07' 
		  AND numconvenio = '004'
		  AND referencia1 = TRIM(pNumConfirmation)
		  AND folio_suc = TRIM(pFolioSucursal);
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000002'; -- NO EXISTE LA REMESA EN LA TABLA DE SAC MOVIMIENTOS ACTUAL.
		END IF
		
    ELIF pFechaTransStatus < dFechaHoy THEN    
	    SELECT LIMIT 1 NVL(folio_suc,'')
		INTO cFolioSucursal
		FROM bdisac:"informix".sac_movimientoshistorial 
		WHERE fecha_pago = pFechaTransStatus
		  AND numcategoria = '07' 
		  AND numconvenio = '004'
		  AND referencia1 = TRIM(pNumConfirmation)
		  AND folio_suc = TRIM(pFolioSucursal);
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000003'; -- NO EXISTE LA REMESA EN LA TABLA DE SAC MOVIMIENTOS HISTORIAL.
		END IF
		
	ELIF pFechaTransStatus > dFechaHoy THEN    
	     LET cCodRet = '000004'; -- FECHA INVALIDA
	END IF;
	
	-- CONSULTAMOS LOS ADICIONALES DE LA REMESA QUE SE DESEA PAGAR.
	IF TRIM(NVL(cFolioSucursal,'')) <> '' THEN	
		IF EXISTS(SELECT sucursal FROM bdisac:"informix".sac_bts_payi WHERE confirmation_nm = pNumConfirmation AND bank_ref_nm = cFolioSucursal /*AND process_dt = cProcess_Dt*/) THEN
		
			SELECT branch_sd, terminal, r_type_cd, r_identif_nm, R_nom_calle, R_num_ext, R_num_int, R_depto, R_colonia,
				   R_cp, R_mncpo_deleg, R_ciudad, R_estado, r_issuer_country_cd, R_telefono, Tipo_pago, R_fecha_nac,  R_nacionalidad,
				   r_pais_nac, bank_ref_nm, r_issuer_cd, r_expiration_dt
			INTO cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, cR_Depto, cR_Colonia,
				 cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad, 
				 cR_pais_nac, cFolioSucursal, cR_issuer_cd, cR_expiration_dt
			FROM bdisac:"informix".sac_bts_payi 
			WHERE confirmation_nm = TRIM(pNumConfirmation)
			  AND bank_ref_nm = TRIM(cFolioSucursal)
			  AND ROWID = (SELECT MAX(ROWID)
						   FROM bdisac:"informix".sac_bts_payi
						   WHERE confirmation_nm = TRIM(pNumConfirmation)
							 AND bank_ref_nm = TRIM(cFolioSucursal));
							 /*AND process_dt = cProcess_Dt);*/
			
		ELSE
				LET cCodRet = '000005'; -- NO SE ENCUENTRA LA REMESA EN LA TABLA SAC_BTS_PAYI 
		END IF;
	END IF;
	
	RETURN cCodRet, TRIM(NVL(cSucursal,'')), TRIM(NVL(cTerminal,'')), TRIM(NVL(cR_Type_Cd,'')), TRIM(NVL(cR_Identif_Nm,'')), TRIM(NVL(cR_Nom_Calle,'')), TRIM(NVL(cR_Num_Ext,'')), TRIM(NVL(cR_Num_Int,'')), TRIM(NVL(cR_Depto,'')), TRIM(NVL(cR_Colonia,'')),
	   TRIM(NVL(cR_Cp,'')), TRIM(NVL(cR_Mncpo_Deleg,'')), TRIM(NVL(cR_Ciudad,'')), TRIM(NVL(cR_Estado,'')), TRIM(NVL(cR_Issuer_Country_Cd,'')), TRIM(NVL(cR_Telefono,'')), TRIM(NVL(cTipo_Pago,'')), TRIM(NVL(cR_Fecha_Nac,'')), TRIM(NVL(cR_Nacionalidad,'')),
	   TRIM(NVL(cR_pais_nac,'')), TRIM(NVL(cFolioSucursal,'')), TRIM(NVL(cR_issuer_cd,'')),TRIM(NVL(cR_expiration_dt,''));
	   
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que realiza una consulta a las tablas de sac_movimientos o sac_movimientoshistorial para confirmar',
'			  que exista la remesa que se desea pagar y tambien consulta los valores adicionales de la tabla bdisac:sac_bts_payi ',
'AUTOR : Valentin López',
'FECHA : 12/Noviembre/2012',
'BD    : bdisac',
'VERSION: 20120212.1223',
'MODIFICO: Jose Angel Gaxiola Gaxiola',
'FECHA : 16/Mayo/2013',
'DESCRIPCION: Se modifica agregando retornos: "cR_issuer_cd" Para llenar dato "COD. TIPO IDENTIFICACIÓN"',
'             y retorno "cR_expiration_dt" para llenar dato  "FECHA VENC. IDENTIFICACIÓN" en pantalla',
'             del aplicativo "ActEstatusBTS.exe"';

CREATE PROCEDURE "informix".sp_genreporbenefrem(pcEmpresa CHAR(3),pcAnio CHAR(4))
	-- DATOS A REGRESAR --
	RETURNING CHAR(5); -- CODIGO DE RETORNO

	-- DEFINICION DE VARIABLES
	DEFINE cCod_ret					CHAR(5);
	DEFINE cAnio_curso 				CHAR(4);
	DEFINE cMes 					CHAR(2);
	DEFINE cNumcte_suc				CHAR(9);
	DEFINE cNumcte_cta				CHAR(9);
	DEFINE cFecha_nac_cta2			CHAR(8);
	DEFINE cFecha_Nacimiento_fin  	CHAR(8);
	DEFINE cFecha_Nacimiento_fin2 	CHAR(8);
	DEFINE cNum_Cte_fin				CHAR(9);
	DEFINE cSeparador				CHAR(7);
	DEFINE cTelefono_cta			CHAR(15);
	DEFINE cFecha_Ini_trim 			CHAR(10);
	DEFINE cFecha_Ini_trim_cta		CHAR(10);
	DEFINE cFecha_fin_trim 			CHAR(10);
	DEFINE cFecha_fin_trim_cta		CHAR(10);
	DEFINE cNombreArchivo  			CHAR(20);
	DEFINE cR_telefono_suc			CHAR(15);
	DEFINE cR_last_name_suc			CHAR(40);
	DEFINE cR_mother_m_name_suc		CHAR(40);
	DEFINE cR_first_name_suc		CHAR(40);
	DEFINE cR_middle_name_suc		CHAR(40);
    DEFINE cR_fecha_nac_suc			CHAR(10);
	DEFINE cNum_confirmacion_cta	CHAR(20);
	DEFINE cReferencia1_suc			CHAR(20);
	DEFINE cCuenta_benef_cta		CHAR(20);
	DEFINE cApell_paterno_cta		CHAR(40);
	DEFINE cApell_materno_cta		CHAR(40);
	DEFINE cNombre1_cta				CHAR(40);
	DEFINE cNombre2_cta				CHAR(40);
	DEFINE cFecha_nac_cta			CHAR(10);
	DEFINE cR_fecha_nac_suc2		CHAR(10);
	DEFINE cTelefono_fin 			CHAR(15);
	DEFINE cApellido_Paterno_fin  	CHAR(40);
	DEFINE cApellido_Materno_fin  	CHAR(40);
	DEFINE cPrimer_Nombre_fin 	  	CHAR(40);
	DEFINE cSegundo_Nombre_fin 	  	CHAR(40);
	DEFINE cCorreo_elec_suc			CHAR(100);
	DEFINE cCorreo_cta				CHAR(100);
	DEFINE cCorreo_Electronico_fin 	CHAR(100);
	DEFINE cSql 					CHAR(1024);
	DEFINE vRuta      				VARCHAR(50);
	DEFINE mImporte_pago_suc		MONEY(16,2);
	DEFINE mMonto_destino_cta		MONEY(16,2);
	DEFINE mImporte_Pago_fin 		MONEY(16,2);
	DEFINE mRem_1trim 				MONEY(16,2);
	DEFINE mImp_rem_1trim 			MONEY(16,2);
	DEFINE mRem_2trim 				MONEY(16,2);
	DEFINE mImp_rem_2trim 			MONEY(16,2);
	DEFINE mRem_3trim 				MONEY(16,2);
	DEFINE mImp_rem_3trim 			MONEY(16,2);
	DEFINE mRem_4trim 				MONEY(16,2);
	DEFINE mImp_rem_4trim 			MONEY(16,2);
	DEFINE mMonto_Acum 				MONEY(16,2);
	DEFINE iSql_err   				INTEGER;
	DEFINE iTrimestre 				INTEGER;
	DEFINE iContador_Trim			INTEGER;
	DEFINE iCont					INTEGER;
	DEFINE iKeyx					INTEGER;
	DEFINE iNum_Trim				INTEGER;
	DEFINE iNum_Trim2				INTEGER;
	DEFINE iKeyx_fin				INTEGER;
	DEFINE iNumero_Trimestre 		INTEGER;
	DEFINE iContador_rem 			INTEGER;
	DEFINE iVolumen_Acum 			INTEGER;
	DEFINE dFechaHoy 				DATE;
	DEFINE iValidaAnio		 		INTEGER;
	
	DEFINE cr_trim INTEGER; 
	DEFINE c_cont INTEGER;
	
	-- INICIALIZACION DE VARIABLES
	LET cCod_ret  				= '00000';
	LET cAnio_curso 			= '';
	LET cMes 					= '';
	LET cNumcte_suc				= '';
	LET cNumcte_cta				= '';
	LET cFecha_nac_cta2			= '';
	LET cFecha_Nacimiento_fin 	= '';
	LET cFecha_Nacimiento_fin2 	= '';
	LET cNum_Cte_fin 			= '';
	LET cSeparador 				= "';   '";
	LET cTelefono_cta			= '';
	LET cFecha_Ini_trim 		= '';
	LET cFecha_Ini_trim_cta		= '';
	LET cFecha_fin_trim 		= '';
	LET cFecha_fin_trim_cta		= '';
	LET cNombreArchivo 			= "Reporte_bts_";
	LET cR_telefono_suc			= '';
	LET cR_last_name_suc		= '';
	LET cR_mother_m_name_suc	= '';
	LET cR_first_name_suc		= '';
	LET cR_middle_name_suc		= '';
	LET cR_fecha_nac_suc		= '';
	LET cNum_confirmacion_cta	= '';
	LET cReferencia1_suc		= '';
	LET cCuenta_benef_cta		= '';
	LET cApell_paterno_cta		= '';
	LET cApell_materno_cta		= '';
	LET cNombre1_cta			= '';
	LET cNombre2_cta			= '';
	LET cFecha_nac_cta			= '';
	LET cR_fecha_nac_suc2		= '';
	LET cTelefono_fin 			= '';
	LET cApellido_Paterno_fin 	= '';
	LET cApellido_Materno_fin 	= '';
	LET cPrimer_Nombre_fin 		= '';
	LET cSegundo_Nombre_fin 	= '';
	LET cCorreo_elec_suc		= '';
	LET cCorreo_cta				= '';
	LET cCorreo_Electronico_fin = '';
	LET cSql 					= '';
	LET vRuta   				= '';
	LET mImporte_pago_suc		= 0;
	LET mMonto_destino_cta		= 0;
	LET mImporte_Pago_fin 		= 0;
	LET mRem_1trim 				= 0;
	LET mImp_rem_1trim 			= 0;
	LET mRem_2trim 				= 0;
	LET mImp_rem_2trim 			= 0;
	LET mRem_3trim 				= 0;
	LET mImp_rem_3trim 			= 0;
	LET mRem_4trim 				= 0;
	LET mImp_rem_4trim 			= 0;
	LET mMonto_Acum 			= 0;
	LET iSql_err  				= 0;
	LET iTrimestre 				= 0;
	LET iContador_Trim			= 0;
	LET iCont					= 0;
	LET iKeyx					= 1;
	LET iNum_Trim				= 0;
	LET iNum_Trim2				= 0;
	LET iKeyx_fin				= 0;
	LET iNumero_Trimestre 		= 0;
	LET iContador_rem 			= 0;
	LET iVolumen_Acum 			= 0;
	LET dFechaHoy 				= '';
	LET iValidaAnio				= 0;
	
	LET cr_trim = 0; 
	LET c_cont = 0;
	
	--SET DEBUG FILE TO "/informix/sp_genreporb.out";
	--TRACE ON;
	
BEGIN

    ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCod_ret = iSql_err;
			RETURN cCod_ret;
		END IF
    END EXCEPTION;

	--VALIDA QUE LOS PARAMETROS NO ESTEN NULOS O VACIOS
   	IF TRIM(NVL(pcEmpresa,"")) = "" OR TRIM(NVL(pcAnio,"")) = "" THEN
	    LET cCod_ret = '00001'; --FALTAN PARAMETROS OBLIGATORIOS.
	END IF;
   
   IF cCod_ret = '00000' THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--SE OBTIENE LA FECHA DE HOY
		SELECT fecha_hoy
		INTO dFechaHoy
		FROM bdinteg:si_fechas
		WHERE empresa = pcEmpresa;
		
		--VALIDA QUE LA FECHA OBTENIDA NO SEA NULO O EN BLANCO
		IF TRIM(NVL(dFechaHoy,"")) = "" THEN
			LET cCod_ret = '00002'; --FALTA FECHA HOY
		END IF;
		
		IF cCod_ret = '00000' THEN			
			--VALIDA QUE LA TABLA TEMPORAL TME_GENREPORBENEFREM NO EXISTA
			IF EXISTS(SELECT tabname FROM sysmaster:systabnames  WHERE tabname = 'tme_genreporbenefrem') THEN
				DELETE  tme_genreporbenefrem;
			ELSE
				--CREACION DE TABLA TEMPORAL PARA ALMACENAR LOS DATOS DE REMESAS
				CREATE TABLE tme_genreporbenefrem( keyx INTEGER,nombre1 CHAR(26),nombre2 CHAR(26),
				apellido CHAR(26),fechanac CHAR(10),celular CHAR(13),email CHAR(50),rem_1trim CHAR(20),imp_rem_1trim CHAR(20),
				rem_2trim CHAR(20),imp_rem_2trim CHAR(20),rem_3trim CHAR(20),imp_rem_3trim CHAR(20),rem_4trim CHAR(20),
				imp_rem_4trim CHAR(20),rem_total CHAR(20),imp_rem_total CHAR(20), PRIMARY KEY(keyx));
			END IF;
	
			--VALIDA QUE PARAMETRO DE ENTRADA SEA IGUAL A AÑO EN CURSO
			LET cAnio_curso = YEAR(dFechaHoy);
			IF cAnio_curso = pcAnio THEN
				--VALIDAR EN QUE TRIMESTRE SE ESTA TRABAJANDO
				LET cMes = LPAD(MONTH(dFechaHoy),2,0);
				IF cMes >= '04' AND cMes <= '06' THEN
					LET iContador_Trim = 1;
					LET cFecha_Ini_trim		= '01/01/'||pcAnio;
					LET cFecha_fin_trim		= '03/31/'||pcAnio;
					LET cFecha_Ini_trim_cta = pcAnio||'0101';
					LET cFecha_fin_trim_cta = pcAnio||'0331';
				ELIF cMes >= '07' AND cMes <= '09' THEN
					LET iContador_Trim = 1;
					LET cFecha_Ini_trim 	= '01/01/'||pcAnio;
					LET cFecha_fin_trim 	= '06/30/'||pcAnio;
					LET cFecha_Ini_trim_cta = pcAnio||'0101';
					LET cFecha_fin_trim_cta = pcAnio||'0630';
				ELIF cMes >= '10' AND cMes <= '12' THEN
					LET cFecha_Ini_trim 	= '01/01/'||pcAnio;
					LET cFecha_fin_trim 	= '09/30/'||pcAnio;
					LET cFecha_Ini_trim_cta = pcAnio||'0101';
					LET cFecha_fin_trim_cta = pcAnio||'0930';
					LET iContador_Trim = 1;
				END IF;
			ELIF cAnio_curso > pcAnio THEN
				LET iContador_Trim = 1;
				LET iValidaAnio = 1;
				LET cFecha_Ini_trim 	= '01/01/'||pcAnio;
				LET cFecha_fin_trim 	= '12/31/'||pcAnio;
				LET cFecha_Ini_trim_cta = pcAnio||'0101';
				LET cFecha_fin_trim_cta = pcAnio||'1231';
			END IF;

			IF iContador_Trim <> 0 THEN
				FOR iCont = 1 TO iContador_Trim
				
					-- ******************************************************************
					-- *	R E M E S A S    P A G A D A S    E N    S U C U R S A L	*
					-- ******************************************************************
					IF iValidaAnio = 0 THEN
						FOREACH
							SELECT payi.r_last_name, payi.r_mother_m_name, payi.r_first_name, payi.r_middle_name, payi.r_fecha_nac, payi.r_telefono, 
							decode(month(movhis.fecha_pago),'1',1,'2',1,'3',1,'4',2,'5',2,'6',2,'7',3,'8',3,'9',3,'10',4,'11',4,'12',4) , 
							count(payi.r_last_name), sum(movhis.importe_pago)
							INTO cR_last_name_suc,cR_mother_m_name_suc,cR_first_name_suc,cR_middle_name_suc,cR_fecha_nac_suc,cR_telefono_suc,cr_trim, c_cont, mImporte_pago_suc
							FROM bdisac:sac_movimientoshistorial movhis, bdisac:sac_bts_payi payi
							WHERE movhis.folio_suc = payi.bank_ref_nm
							AND movhis.referencia1 = payi.confirmation_nm
							AND movhis.numcategoria = '07'
							AND movhis.numconvenio = '004'
							AND movhis.fecha_pago >= cFecha_Ini_trim 
							AND movhis.fecha_pago <= cFecha_fin_trim
							AND movhis.status_cancelado <> 'S'
							AND payi.opcode = '1100'
							group by 1,2,3,4,5,6,7

							UNION ALL
							
							SELECT payi.r_last_name, payi.r_mother_m_name, payi.r_first_name, payi.r_middle_name, payi.r_fecha_nac, payi.r_telefono, 
							decode(month(movhis_old.fecha_pago),'1',1,'2',1,'3',1,'4',2,'5',2,'6',2,'7',3,'8',3,'9',3,'10',4,'11',4,'12',4), 
							count(payi.r_last_name), sum(movhis_old.importe_pago)
							FROM bdisac:sac_movimientoshistorial_old movhis_old, bdisac:sac_bts_payi payi
							WHERE movhis_old.folio_suc = payi.bank_ref_nm
							AND movhis_old.referencia1 = payi.confirmation_nm
							AND movhis_old.numcategoria = '07'
							AND movhis_old.numconvenio = '004'
							AND movhis_old.fecha_pago >= cFecha_Ini_trim 
							AND movhis_old.fecha_pago <= cFecha_fin_trim
							AND movhis_old.status_cancelado <> 'S'
							AND payi.opcode = '1100'
							group by 1,2,3,4,5,6,7
							order by 7
							
							LET cR_fecha_nac_suc2 = SUBSTR(cR_fecha_nac_suc,5,2) || '-' ||SUBSTR(cR_fecha_nac_suc,7,2) || '-' || SUBSTR(cR_fecha_nac_suc,1,4);

							--SE OBTIENE NUMERO DE CLIENTE PARA REMESAS PAGADAS DESDE SUCURAL
							SELECT first 1 cliente.numcte
							INTO cNumcte_suc
							FROM bdinteg:si_cliente cliente, bdinteg:si_ctepf ctepf
							WHERE cliente.numcte = ctepf.numcte
							AND cliente.apell_paterno = cR_last_name_suc
							AND cliente.apell_materno = cR_mother_m_name_suc
							AND cliente.nombre1 = cR_first_name_suc
							AND cliente.nombre2 = cR_middle_name_suc
							AND ctepf.fecha_nac = cR_fecha_nac_suc2;
							
							--SE OBTIENE CORREO ELECTRONICO DEL CLIENTE
							SELECT first 1 correo.correo_elec
							INTO cCorreo_elec_suc
							FROM bdinteg:si_correos correo
							WHERE correo.tipo_correo = '1'
							AND correo.status_correo = 'A'
							AND correo.numcte = cNumcte_suc;
							
							IF cr_trim = 1 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,cR_first_name_suc,cR_middle_name_suc,cR_mother_m_name_suc,cR_fecha_nac_suc2,cR_telefono_suc,NVL(cCorreo_elec_suc,''),c_cont,mImporte_pago_suc,"","","","","","","","");
								LET iKeyx = iKeyx + 1;
							END IF;
							IF cr_trim = 2 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,cR_first_name_suc,cR_middle_name_suc,cR_mother_m_name_suc,cR_fecha_nac_suc2,cR_telefono_suc,NVL(cCorreo_elec_suc,''),"","",c_cont,mImporte_pago_suc,"","","","","","");
								LET iKeyx = iKeyx + 1;
							END IF;
							IF cr_trim = 3 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,cR_first_name_suc,cR_middle_name_suc,cR_mother_m_name_suc,cR_fecha_nac_suc2,cR_telefono_suc,NVL(cCorreo_elec_suc,''),"","","","",c_cont,mImporte_pago_suc,"","","","");
								LET iKeyx = iKeyx + 1;
							END IF;
							IF cr_trim = 4 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,cR_first_name_suc,cR_middle_name_suc,cR_mother_m_name_suc,cR_fecha_nac_suc2,cR_telefono_suc,NVL(cCorreo_elec_suc,''),"","","","","","",c_cont,mImporte_pago_suc,"","");
								LET iKeyx = iKeyx + 1;
							END IF;

						END FOREACH;
					ELIF iValidaAnio = 1 THEN
						FOREACH
							SELECT payi.r_last_name, payi.r_mother_m_name, payi.r_first_name, payi.r_middle_name, payi.r_fecha_nac, payi.r_telefono, 
							decode(month(movhis_old.fecha_pago),'1',1,'2',1,'3',1,'4',2,'5',2,'6',2,'7',3,'8',3,'9',3,'10',4,'11',4,'12',4), 
							count(payi.r_last_name), sum(movhis_old.importe_pago)
							INTO cR_last_name_suc,cR_mother_m_name_suc,cR_first_name_suc,cR_middle_name_suc,cR_fecha_nac_suc,cR_telefono_suc,cr_trim, c_cont, mImporte_pago_suc
							FROM bdisac:sac_movimientoshistorial_old movhis_old, bdisac:sac_bts_payi payi
							WHERE movhis_old.folio_suc = payi.bank_ref_nm
							AND movhis_old.referencia1 = payi.confirmation_nm
							AND movhis_old.numcategoria = '07'
							AND movhis_old.numconvenio = '004'
							AND movhis_old.fecha_pago >= cFecha_Ini_trim 
							AND movhis_old.fecha_pago <= cFecha_fin_trim
							AND movhis_old.status_cancelado <> 'S'
							AND payi.opcode = '1100'
							group by 1,2,3,4,5,6,7
							order by 7
							
							LET cR_fecha_nac_suc2 = SUBSTR(cR_fecha_nac_suc,5,2) || '-' ||SUBSTR(cR_fecha_nac_suc,7,2) || '-' || SUBSTR(cR_fecha_nac_suc,1,4);

							--SE OBTIENE NUMERO DE CLIENTE PARA REMESAS PAGADAS DESDE SUCURAL
							SELECT first 1 cliente.numcte
							INTO cNumcte_suc
							FROM bdinteg:si_cliente cliente, bdinteg:si_ctepf ctepf
							WHERE cliente.numcte = ctepf.numcte
							AND cliente.apell_paterno = cR_last_name_suc
							AND cliente.apell_materno = cR_mother_m_name_suc
							AND cliente.nombre1 = cR_first_name_suc
							AND cliente.nombre2 = cR_middle_name_suc
							AND ctepf.fecha_nac = cR_fecha_nac_suc2;
							
							--SE OBTIENE CORREO ELECTRONICO DEL CLIENTE
							SELECT first 1 correo.correo_elec
							INTO cCorreo_elec_suc
							FROM bdinteg:si_correos correo
							WHERE correo.tipo_correo = '1'
							AND correo.status_correo = 'A'
							AND correo.numcte = cNumcte_suc;
							
							IF cr_trim = 1 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,cR_first_name_suc,cR_middle_name_suc,cR_mother_m_name_suc,cR_fecha_nac_suc2,cR_telefono_suc,NVL(cCorreo_elec_suc,''),c_cont,mImporte_pago_suc,"","","","","","","","");
								LET iKeyx = iKeyx + 1;
							END IF;
							IF cr_trim = 2 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,cR_first_name_suc,cR_middle_name_suc,cR_mother_m_name_suc,cR_fecha_nac_suc2,cR_telefono_suc,NVL(cCorreo_elec_suc,''),"","",c_cont,mImporte_pago_suc,"","","","","","");
								LET iKeyx = iKeyx + 1;
							END IF;
							IF cr_trim = 3 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,cR_first_name_suc,cR_middle_name_suc,cR_mother_m_name_suc,cR_fecha_nac_suc2,cR_telefono_suc,NVL(cCorreo_elec_suc,''),"","","","",c_cont,mImporte_pago_suc,"","","","");
								LET iKeyx = iKeyx + 1;
							END IF;
							IF cr_trim = 4 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,cR_first_name_suc,cR_middle_name_suc,cR_mother_m_name_suc,cR_fecha_nac_suc2,cR_telefono_suc,NVL(cCorreo_elec_suc,''),"","","","","","",c_cont,mImporte_pago_suc,"","");
								LET iKeyx = iKeyx + 1;
							END IF;
						END FOREACH;
					END IF

				-- ******************************************************************************
				-- *	R E M E S A S    P A G A D A S    E N    A B O N O    C U E N T A		*
				-- ******************************************************************************
					FOREACH
						SELECT sdep.cuenta_benef,
						decode(SUBSTRING(sdep.fecha_proceso from 5 FOR 2),'01',1,'02',1,'03',1,'04',2,'05',2,'06',2,'07',3,'08',3,'09',3,'10',4,'11',4,'12',4) mes,
						count(agent_cd) cuantas, sum(sdep.monto_destino::money) suma
						INTO cCuenta_benef_cta, cr_trim, c_cont, mMonto_destino_cta
						FROM bdisac:sac_bts_sdep sdep
						WHERE sdep.fecha_proceso >= cFecha_Ini_trim_cta 
						AND sdep.fecha_proceso <= cFecha_fin_trim_cta
						AND sdep.estatus_sdep = '05'
						group by 1,2

						--SE OBTIENE EL NUMERO DE CLIENTE
						IF LENGTH(cCuenta_benef_cta) = 16 THEN
							SELECT tarjeta.numcte
							INTO cNumcte_cta
							FROM bdicheq:sc_tarjeta tarjeta
							WHERE tarjeta.empresa = pcEmpresa
							AND tarjeta.num_tarjeta = cCuenta_benef_cta;
						ELSE
							SELECT maechq.num_cte
							INTO cNumcte_cta
							FROM bdicheq:sc_maechq maechq
							WHERE maechq.cuenta = cCuenta_benef_cta;
						END IF;

						--SE OBTIENE NOMBRES,APELLIDOS Y FECHA DE NACIMIENTO POR CLIENTE
						SELECT cliente.apell_paterno,cliente.apell_materno,cliente.nombre1,cliente.nombre2, ctepf.fecha_nac
						INTO cApell_paterno_cta,cApell_materno_cta,cNombre1_cta,cNombre2_cta,cFecha_nac_cta
						FROM bdinteg:si_cliente cliente, bdinteg:si_ctepf ctepf
						WHERE cliente.numcte = ctepf.numcte
						AND cliente.numcte = cNumcte_cta;

						LET cFecha_nac_cta2 = SUBSTR(cFecha_nac_cta,7,4) || '' ||SUBSTR(cFecha_nac_cta,1,2) || '' ||SUBSTR(cFecha_nac_cta,4,2);
						
						--SE OBTIENE EL NUMERO DE TELEFONO DEL CLIENTE
						SELECT first 1 tel.telefono
						INTO cTelefono_cta
						FROM bdinteg:si_telefonos_actual tel
						WHERE tel.tipo_tel = '2'
						AND tel.status_tel = 'A'
						AND tel.numcte = cNumcte_cta;

						--SE OBTIENE CORREO ELECTRONICO DEL CLIENTE
						SELECT first 1 correo.correo_elec
						INTO cCorreo_cta
						FROM bdinteg:si_correos correo
						WHERE correo.tipo_correo = '1'
						AND correo.status_correo = 'A'
						AND correo.numcte = cNumcte_cta;

						--SE INSERTA INFORMACION EN TABLA TEMPORAL TME_REMESAPAGOCTA
						IF cr_trim = 1 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,nvl(cNombre1_cta,''),nvl(cApell_paterno_cta,''),NVL(cApell_materno_cta,''),NVL(cFecha_nac_cta2,''),NVL(cTelefono_cta,''),NVL(cCorreo_cta,''),c_cont,mMonto_destino_cta,"","","","","","","","");
								LET iKeyx = iKeyx + 1;
							END IF;
							IF cr_trim = 2 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,nvl(cNombre1_cta,''),nvl(cApell_paterno_cta,''),NVL(cApell_materno_cta,''),NVL(cFecha_nac_cta2,''),NVL(cTelefono_cta,''),NVL(cCorreo_cta,''),"","",c_cont,mMonto_destino_cta,"","","","","","");
								LET iKeyx = iKeyx + 1;
							END IF;
							IF cr_trim = 3 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,nvl(cNombre1_cta,''),nvl(cApell_paterno_cta,''),NVL(cApell_materno_cta,''),NVL(cFecha_nac_cta2,''),NVL(cTelefono_cta,''),NVL(cCorreo_cta,''),"","","","",c_cont,mMonto_destino_cta,"","","","");
								LET iKeyx = iKeyx + 1;
							END IF;
							IF cr_trim = 4 THEN
								INSERT INTO tme_genreporbenefrem (keyx,nombre1,nombre2,apellido,fechanac,celular,email,rem_1trim,
								imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim,rem_total,imp_rem_total)
								VALUES(iKeyx,nvl(cNombre1_cta,''),nvl(cApell_paterno_cta,''),NVL(cApell_materno_cta,''),NVL(cFecha_nac_cta2,''),NVL(cTelefono_cta,''),NVL(cCorreo_cta,''),"","","","","","",c_cont,mMonto_destino_cta,"","");
								LET iKeyx = iKeyx + 1;
							END IF;

					END FOREACH;
				END FOR;
				
				FOREACH
					--SE ACTUALIZA VOLUMEN ACUMULADO y MONTO ACUMULADO SUMANDO REMESAS POR CLIENTE
					SELECT keyx,rem_1trim, imp_rem_1trim,rem_2trim,imp_rem_2trim,rem_3trim,imp_rem_3trim,rem_4trim,imp_rem_4trim
					INTO iKeyx_fin,mRem_1trim,mImp_rem_1trim,mRem_2trim,mImp_rem_2trim,mRem_3trim,mImp_rem_3trim,mRem_4trim,mImp_rem_4trim
					FROM tme_genreporbenefrem
					
					LET iVolumen_Acum = NVL(mRem_1trim,0) + NVL(mRem_2trim, 0) + NVL(mRem_3trim,0) + NVL(mRem_4trim,0);
					LET mMonto_Acum = NVL(mImp_rem_1trim,0) + NVL(mImp_rem_2trim,0) + NVL(mImp_rem_3trim,0) + NVL(mImp_rem_4trim,0);
					
					UPDATE tme_genreporbenefrem 
					SET rem_total = iVolumen_Acum, imp_rem_total = mMonto_Acum
					WHERE keyx = iKeyx_fin;
					
				END FOREACH;
				--DROP TABLE tmp_cargaremesas;*/
			END IF;
			
			-- OBTENGO LA RUTA DONDE SE VA A GENERAR EL REPORTE DE REMESAS
			SELECT TRIM(valor) 
			INTO vRuta 
			FROM bdisac:sac_param 
			WHERE empresa = pcEmpresa 
			AND cod_param = '050';
			
			--VALIDA QUE LA RUTA OBTENIDA NO SEA NULO O EN BLANCO
			IF TRIM(NVL(vRuta,"")) = "" THEN
				LET cCod_ret = '00003'; --FALTA RUTA DESTINO DEL ARCHIVO PLANO
			END IF;

			-- SE CREA EL ARCHIVO .TXT EN LA RUTA OBTENIDA
			IF cCod_ret = '00000' THEN
				-- SE ASIGNA NOMBRE AL ARCHIVO .TXT A GENERAR
				LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dFechaHoy)||LPAD(MONTH(dFechaHoy),2,0)||LPAD(DAY(dFechaHoy),2,0);
				-- SE INSERTAN ENCABEZADOS AL ARCHIVO		
				LET cSql = 'echo " 											  FECHA DE											      ENERO/MARZO				     ABRIL/JUNIO				   JULIO/SEPTIEMBRE				     OCT/DICIEMBRE		      VOLUMEN		       MONTO	" > '||(vRuta)||TRIM(cNombreArchivo)||'.txt';
				SYSTEM cSql;
				LET cSql = "";
				
				LET cSql = 'echo " NOMBRE1		    NOMBRE2			  APELLIDO			 NACIMIENTO	 CELULAR	CORREO ELECTRONICO					  REMESAS		  MONTO			REMESAS			MONTO			REMESAS			MONTO			REMESAS			MONTO		     ACUMULADO		     ACUMULADO" >> '||(vRuta)||TRIM(cNombreArchivo)||'.txt';
				SYSTEM cSql;
				LET cSql = "";
				
				LET cSql=  'echo "UNLOAD TO '||TRIM(vRuta)||'Reporte_bts_.txt SELECT nombre1||'||cSeparador||'||nombre2||'||cSeparador||'||apellido||'||cSeparador||'||fechanac||'||cSeparador||'||celular||'||cSeparador||'||email||'||cSeparador||'||rem_1trim||'||cSeparador||'||SUBSTR(imp_rem_1trim,2,20)||'||cSeparador||'||rem_2trim||'||cSeparador||'||SUBSTR(imp_rem_2trim,2,20)||'||cSeparador||'||rem_3trim||'||cSeparador||'||SUBSTR(imp_rem_3trim,2,20)||'||cSeparador||'||rem_4trim||'||cSeparador||'||SUBSTR(imp_rem_4trim,2,20)||'||cSeparador||'||rem_total||'||cSeparador||'||SUBSTR(imp_rem_total,2,20) FROM tme_genreporbenefrem;"> '||TRIM(vRuta)||'query1.sql'; 
				SYSTEM cSql;
				LET cSql = '';
				
				LET cSql= "dbaccess bdisac " ||TRIM(vRuta)||"query1.sql";
				SYSTEM cSql;
				LET cSql ='';
				
				LET cSql ="rm " ||TRIM(vRuta)||"query1.sql";
				SYSTEM cSql;
				LET cSql ='';
				
				LET cSql = "sed 's/|$//g' "||TRIM(vRuta)||"Reporte_bts_.txt >>"||TRIM(vRuta)||""||TRIM(cNombreArchivo)||".txt";
				SYSTEM cSql;
				LET cSql ='rm  '||TRIM(vRuta)||'Reporte_bts_.txt';
				SYSTEM cSql;		
			END IF;
			-- SE BORRAN LAS TABLAS TEMPORALES DESPÚES DE VACIAR LOS DATOS
			
		END IF;
	END IF;	
  RETURN cCod_ret;  
  
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que genera un reporte en formato .txt, de los clientes que realizaron pagos de remesas ya sea desde sucursal  ',
'			  o pagos en abono cuenta, el reporte se genera por trimestre con informacion del cliente; Nombre,fecha de nacimiento,celular y correo electronico',
'AUTOR : Jose Angel Gaxiola Gaxiola',
'FECHA : 11/JUNIO/2013',
'VERSION: 20130611.0920',
'MODIFICO: Jose Angel Gaxiola Gaxiola',
'DESCRIPCION: Se agregan mejoras al SP agregando busqueda a tabla: "sac_movimientoshistorial_old" cuando la información a consultar sea mayor a tres meses de Fecha hoy',
'FECHA : 25/JUNIO/2013',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_bitacoragdf(pLinea_Captura 	CHAR(20),
										   pReferencia 		CHAR(12),
										   pTipo_pago 		CHAR(2),
										   pSucursal 		CHAR(10),
										   pImporte 		CHAR(10),
										   pUsuario 		CHAR(10),
										   pPassword 		CHAR(32),
										   pSecuencia_trans INTEGER,
										   pOpcode 		 	INTEGER,
										   pDescripcion  	CHAR(60))
	RETURNING CHAR(5) AS CodRetorno;


--Definicion de Variables
DEFINE iSqlErr   	   INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cInfoErr        CHAR(100);
DEFINE cCodRet 		   CHAR(5);
DEFINE cCnxn_status    CHAR(1);
DEFINE cTipo_Pago 	   CHAR(2);
DEFINE cSucursal 	   CHAR(10);
DEFINE cImporte 	   CHAR(10);
DEFINE cUsuario 	   CHAR(10);
DEFINE cPassword 	   CHAR(32);
DEFINE cDescripcion    CHAR(60);
DEFINE iOpcode         INTEGER;
DEFINE iSecuenciaTrans INTEGER;


--Inicializacion de Variables
LET iSqlErr 		= 0;
LET iIsamErr 		= 0;
LET cInfoErr 		= '';
LET cCodRet 		= '00000';
LET cCnxn_status 	= 'A';
LET cTipo_Pago 		= '';
LET cSucursal 		= '';
LET cImporte 		= '';
LET cUsuario 		= '';
LET cPassword 		= '';
LET cDescripcion 	= '';
LET iOpcode         = 0;
LET iSecuenciaTrans = 0;

--SET DEBUG FILE TO '/respaldosbd/martin/sp_bitacoragdf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCnxn_status = 'C'; 
			
			INSERT INTO "informix".sac_gdf_pagos (cnxn_status,linea_captura,referencia,tipo_pago,sucursal,importe,usuario,password,secuencia_trans,opcode,descripcion,fecha_insert) 
			VALUES (cCnxn_status,TRIM(pLinea_Captura),TRIM(pReferencia),TRIM(cTipo_Pago),TRIM(cSucursal),TRIM(cImporte),TRIM(cUsuario),TRIM(cPassword),iSecuenciaTrans,iOpcode,TRIM(pDescripcion),CURRENT);

			LET cCodRet = iSqlErr;
			
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, TRIM(pLinea_Captura));

			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pLinea_Captura,'') = '' THEN
		LET cCnxn_status = 'C';
	ELIF NVL(pReferencia,'') = '' THEN 
		LET cCnxn_status = 'C';
	ELIF NVL(pTipo_pago,'') = ''  THEN
		LET cCnxn_status = 'C';
	ELIF NVL(pSucursal,'') = '' THEN 
		LET cCnxn_status = 'C';
	ELIF NVL(pImporte,'') = '' THEN
		LET cCnxn_status = 'C';
	ELIF NVL(pUsuario,'') = '' THEN 
		LET cCnxn_status = 'C';
	ELIF NVL(pPassword,'') = '' THEN
		LET cCnxn_status = 'C';
	END IF;
	
	IF pOpcode <> 0 THEN
	
		IF NVL(pDescripcion,'') = '' THEN
			LET pDescripcion = 'Sin respuesta a la petición del mensaje';
		END IF;
		
		LET iOpcode = 1;
		LET cCnxn_status = 'C';
	ELSE
		LET cCnxn_status = 'A';
	END IF;
		
		INSERT INTO "informix".sac_gdf_pagos (cnxn_status,linea_captura,referencia,tipo_pago,sucursal,importe,usuario,password,secuencia_trans,opcode,descripcion,fecha_insert) 
		VALUES (cCnxn_status,TRIM(pLinea_Captura),TRIM(pReferencia),LPAD(TRIM(pTipo_pago),2,'0'),LPAD(TRIM(pSucursal),10,'0'),LPAD(TRIM(pImporte),10,'0'),TRIM(pUsuario),TRIM(pPassword),pSecuencia_trans,pOpcode,TRIM(pDescripcion),CURRENT);
		
	RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para guardar una bitácora de los pagos de Impuestos del Gobierno de DF.',
'AUTOR : Martín Eduardo Miranda',
'FECHA : 08 de Enero del 2013',
'VERSION: 20120108.09',
'BD: BDISAC',
'',
'DESCRIPCION: Se modifica Procedimiento Almacenado para guardar la descripcion "Sin respuesta a la petición del mensaje", cuando',
'             ocurra un error en el envío al WS el Pago del Impuesto,',
'MOFICIÓ    : Martín Eduardo Miranda',
'FECHA      : 12 de Marzo del 2013',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_confirmacionbitacorapgdf(pFolioSuc CHAR(16))

	RETURNING CHAR(5) AS CodRet,
			 CHAR(50) AS Descripcion;
	
	--DEFINICION DE VARIABLES
	DEFINE cCodRet			CHAR(5);
	DEFINE isql_err			INTEGER;
	DEFINE cDescripcion     CHAR (50);
	DEFINE cInfoError		CHAR (80);
	DEFINE iIsamErr         INTEGER;
	DEFINE cLinea			CHAR(20);
	DEFINE cReferencia 		CHAR(20);
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet 		='00000';
	LET isql_err 		= 0;
	LET cDescripcion    = '';
	LET cInfoError 		= '';
	LET iIsamErr		= 0;
	LET cLinea			= '';
	LET cReferencia		= '';
	
	
	
	BEGIN
		ON EXCEPTION SET isql_err,iIsamErr,cInfoError
			IF isql_err <> 0 THEN
			
				LET cCodRet = isql_err;
				LET cDescripcion = cInfoError;
				
				RETURN cCodRet,NVL(cDescripcion,'') WITH RESUME;	
				
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/respaldosbd/eduardo/sp_confirmacionbitacorapgdf.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pFolioSuc,'') = '' THEN 
			
			LET cCodRet = '00000'; --El parametro viene vacio
			LET cDescripcion = 'No se puede reversar';
			
			RETURN cCodRet,cDescripcion WITH RESUME;
		END IF;
		
		SELECT referencia1 
		INTO cReferencia
		FROM bdisac:"informix".sac_movimientos
		WHERE folio_suc = pFolioSuc;
		
		IF NVL(cReferencia,"") <> "" THEN 
		
			IF EXISTS (SELECT linea_captura FROM bdisac:"informix".sac_gdf_pagos
				WHERE linea_captura = cReferencia ) THEN 
			
				LET cCodRet = '00001'; --Si existe el registro
				LET cDescripcion = 'La transaccion se encuentra registrada';
				
			ELSE
			
				LET cCodRet = '00000';
				LET cDescripcion = 'No se puede reversar';
				
			END IF;
		ELSE
			LET cCodRet = '00000';
			LET cDescripcion = 'No se puede reversar';
		END IF;
		
		RETURN cCodRet,cDescripcion WITH RESUME;		
	END 
	
END PROCEDURE	
DOCUMENT
'DESCRIPCION: Se crea procedimiento para consultar si la transaccion se encuentra registrada',
'AUTOR :Eduardo López',
'FECHA : 08/01/2013',
'BD    : bdisac',
'VER   : 1.0';

CREATE PROCEDURE "informix".sp_consdatosticketpgdf(pFolioSuc CHAR(20))

    --DATOS A REGRESAR---
    RETURNING CHAR(5),CHAR(20),CHAR(1),CHAR(20);  

    --DEFINICION DE VARIABLES--
    DEFINE sql_err           INT;
    DEFINE cCodRet           CHAR(5);
	DEFINE cFormaPago        CHAR(1);
	DEFINE cNumConfirmacion  CHAR(20);
	DEFINE cLeyenda          CHAR(20);
	DEFINE cClave            CHAR(2);
	
		
    --INICIALIZACION DE VARIABLES--
    LET sql_err            = 0;
    LET cCodRet            = '00000';	
	LET cFormaPago         = "";
	LET cNumConfirmacion   = "";	
    LET cLeyenda           = "";
	LET cClave             = "";
 
	
    
BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet,cNumConfirmacion,cFormaPago,cLeyenda WITH RESUME;  
        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/respaldosbd/eduardo/sp_consdatosticketpgdf.out";
   --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    IF NVL(pFolioSuc,'') = '' THEN
		LET cCodRet =   '00001'; --Faltan parámetros
		RETURN cCodRet,cNumConfirmacion,cFormaPago, cLeyenda WITH RESUME;  
	END IF;

	IF EXISTS (SELECT referencia1 FROM bdisac:"informix".sac_movimientos WHERE folio_suc = pFolioSuc AND status_cancelado = "N" 
	          AND numcategoria = '08' AND numconvenio = '001') THEN
        SELECT NVL(forma_pago,''), NVL(referencia1,'')
		INTO cFormaPago, cNumConfirmacion
	    FROM bdisac:"informix".sac_movimientos 
		WHERE folio_suc = pFolioSuc
		AND numcategoria = '08' 
		AND numconvenio = '001'
		AND status_cancelado = "N";
		
		LET cClave = SUBSTR(cNumConfirmacion,1,2);
		
        SELECT leyenda 
        INTO cLeyenda
        FROM bdisac:"informix".sac_catconceptosgdf
        WHERE clave = cClave;
		
	ELSE
	    LET cCodRet =   '00002'; 
    END IF;
	
	
    RETURN cCodRet,cNumConfirmacion,cFormaPago,cLeyenda WITH RESUME;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para consultar la forma de pago y el numero de confirmación para la categoria 08',
'AUTOR : Eduardo López ',
'FECHA : 28/Diciembre/2012',
'Ver.  : 1.0',
'BD    : bdisac',
'MODIFICACION : 11/02/2013',
'MODIFICO :Felipe Urias  ',
'DESCRIPCION: se agrega como retorno la leyenda de conceptos de sac_catconceptosgdf';

CREATE PROCEDURE "informix".sp_sacreportemensualgdf(pConvenio CHAR(5), pPeriodo CHAR(6))
RETURNING
		CHAR (6) 	  AS retorno,
		CHAR(6) 	  AS aniomes,
		DATE 	 	  AS fecha,
		INTEGER       AS num_operaciones,
		MONEY (16,2)  AS comision,
		MONEY (16,2)  AS iva;

--Definicion de Variables
DEFINE cCodRet			 CHAR(6);
DEFINE cAnioMes			 CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE dFecha			 DATE;
DEFINE iNumOperaciones	 INTEGER;
DEFINE iSqlErr			 INTEGER;
DEFINE iIsamErr			 INTEGER;
DEFINE mComision		 MONEY(16,2);
DEFINE mIva				 MONEY(16,2);

--Inicializacion de Variables
LET cCodRet				 = '000000';
LET cAnioMes			 = '';
LET dFecha				 = DATE (1);
LET iNumOperaciones		 = 0;
LET mComision			 = 0;
LET mIva				 = 0;
LET iSqlErr				 = 0;
LET iIsamErr			 = 0;
LET cInfoErr			 = '';

-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualgdf.out';
-- TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualdyclass");
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	IF  pPeriodo = "" OR LENGTH(pPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE
		SET ISOLATION TO DIRTY READ;
		FOREACH

			SELECT aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac:"informix".sac_liquidacionmensual
			WHERE aniomes = pPeriodo
			AND id_convenio = pConvenio
			ORDER BY fecha

			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Jasmin Soto F.',
'DESCRIPCIÓN: Obtiene la informacion para la generacion del reporte mensual de pago de impuestos del GDF',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 02 Enero 2013',
'VERSIÓN: 20120705.1454',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesemanalgdf(pConvenio CHAR (5),pConsecutivo INTEGER)
	RETURNING
			CHAR (6) 	AS retorno,
			INTEGER 	AS rec_lunes ,
			INTEGER 	AS rec_martes,
			INTEGER 	AS rec_miercoles,
			INTEGER 	AS rec_jueves,
			INTEGER 	AS rec_viernes,
			INTEGER 	AS rec_sabado,
			INTEGER 	AS rec_domingo,
			MONEY(16,2) AS cob_lunes,
			MONEY(16,2) AS cob_martes,
			MONEY(16,2) AS cob_miercoles,
			MONEY(16,2) AS cob_jueves,
			MONEY(16,2) AS cob_viernes,
			MONEY(16,2) AS cob_sabado,
			MONEY(16,2) AS cob_domingo,
			INTEGER 	AS rec_efectivo,
			INTEGER 	AS rec_chequemb,
			INTEGER 	AS rec_chequeob,
			INTEGER 	AS rec_tarcred,
			MONEY(16,2) AS cob_efectivo,
			MONEY(16,2) AS cob_cheqmb,
			MONEY(16,2) AS cob_cheqob,
			MONEY(16,2) AS cob_tarcred,
			MONEY(16,2) AS liq_miercoles,
			MONEY(16,2) AS liq_jueves,
			MONEY(16,2) AS liq_viernes,
			MONEY(16,2) AS liq_sabado,
			MONEY(16,2) AS liq_domingo,
			MONEY(16,2) AS liq_lunes,
			MONEY(16,2) AS liq_martes,
			MONEY(16,2) AS aclaraciones,
			MONEY(16,2) AS comision,
			MONEY(16,2) AS iva_comision,
			DATE        AS fec_iniperiodo,
			DATE 	    AS fec_finperiodo,
			INTEGER 	AS keyx;
 --Definicion de Variables
	DEFINE cCodRet			CHAR (6);
	DEFINE cInfoErr         CHAR(100);
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE iRecLunes		INTEGER;
	DEFINE iRecMartes		INTEGER;
	DEFINE iRecMiercoles	INTEGER;
	DEFINE iRecJueves		INTEGER;
	DEFINE iRecViernes		INTEGER;
	DEFINE iRecSabado		INTEGER;
	DEFINE iRecDomingo		INTEGER;
	DEFINE iRecEfectivo		INTEGER;
	DEFINE iRecChequemb		INTEGER;
	DEFINE iRecChequeob		INTEGER;
	DEFINE iRecTarcred		INTEGER;
	DEFINE iCobEfectivo		INTEGER;
	DEFINE dFecIniPeriodo	DATE;
	DEFINE dFecFinPeriodo	DATE;
	DEFINE mCobLunes		MONEY(16,2);
	DEFINE mCobMartes		MONEY(16,2);
	DEFINE mCobMiercoles	MONEY(16,2);
	DEFINE mCobJueves		MONEY(16,2);
	DEFINE mCobViernes		MONEY(16,2);
	DEFINE mCobSabado		MONEY(16,2);
	DEFINE mCobDomingo		MONEY(16,2);
	DEFINE mCobCheqmb		MONEY(16,2);
	DEFINE mCobCheqob		MONEY(16,2);
	DEFINE mCobTarcred		MONEY(16,2);
	DEFINE mLiqMiercoles	MONEY(16,2);
	DEFINE mLiqJueves		MONEY(16,2);
	DEFINE mLiqViernes		MONEY(16,2);
	DEFINE mLiqSabado       MONEY(16,2);
	DEFINE mLiqDomingo      MONEY(16,2);
	DEFINE mLiqLunes		MONEY(16,2);
	DEFINE mLiqMartes		MONEY(16,2);
	DEFINE mAclaraciones	MONEY(16,2);
	DEFINE mComision		MONEY(16,2);
	DEFINE mIvaComision		MONEY(16,2);
--Inicializacion de Variables
	LET cCodRet			= '000000';
	LET iRecLunes		= 0;
	LET iRecMartes		= 0;
	LET iRecMiercoles	= 0;
	LET iRecJueves		= 0;
	LET iRecViernes		= 0;
	LET iRecSabado		= 0;
	LET iRecDomingo		= 0;
	LET mCobLunes		= 0;
	LET mCobMartes		= 0;
	LET mCobMiercoles	= 0;
	LET mCobJueves		= 0;
	LET mCobViernes		= 0;
	LET mCobSabado		= 0;
	LET mCobDomingo		= 0;
	LET iRecEfectivo	= 0;
	LET iRecChequemb	= 0;
	LET iRecChequeob	= 0;
	LET iRecTarcred		= 0;
	LET iCobEfectivo	= 0;
	LET mCobCheqmb		= 0;
	LET mCobCheqob		= 0;
	LET mCobTarcred		= 0;
	LET mLiqMiercoles	= 0;
	LET mLiqJueves		= 0;
	LET mLiqViernes		= 0;
	LET mLiqSabado      = 0;
	LET mLiqDomingo     = 0;
	LET mLiqLunes		= 0;
	LET mLiqMartes		= 0;
	LET mAclaraciones	= 0;
	LET mComision		= 0;
	LET mIvaComision	= 0;
	LET dFecIniPeriodo	= DATE (1);
	LET dFecFinPeriodo	= DATE (1);
	LET iSqlErr			= 0;
	LET iIsamErr		= 0;
	LET cInfoErr		= '';
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanalgdf");
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo;
		END IF;
	END EXCEPTION;
	SET LOCK MODE TO WAIT 3;
	IF  pConsecutivo IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
			mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
			mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
			mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo;
	ELSE
		SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdisac:"informix".sac_liquidacionsemanal idx_sacliqsem)} rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, cob_martes,
					cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
					cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred, liq_miercoles, liq_jueves, liq_viernes, liq_sabado, liq_domingo, liq_lunes, liq_martes,
					aclaraciones, comision, iva_comision, fec_iniperiodo, fec_finperiodo
				INTO iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo
				FROM bdisac:"informix".sac_liquidacionsemanal
				WHERE id_convenio = pConvenio
				AND  consecutivo_convenio  = pConsecutivo
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo WITH RESUME;
			END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Jasmin Soto F.',
'DESCRIPCIÓN: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos de impuestos del GDF',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 02 Enero 2013',
'VERSIÓN: 20130102.1450',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_validadvgdf(pCaptura CHAR(20))
	RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE i			INTEGER;
DEFINE cP 			INTEGER;
DEFINE iResultado 	INTEGER;
DEFINE iMod     	INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE k 			CHAR(1);
DEFINE cCadena 		CHAR(2);
DEFINE cLetra 		CHAR(1);
DEFINE cDv 			CHAR(2);
DEFINE cK		 	NUMERIC;
DEFINE nSuma        NUMERIC;
DEFINE nCociente  	NUMERIC;
DEFINE dFecha_Hoy 	DATE;

--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET i       	= 0;
LET cK      	= '0';
LET nSuma   	= '0';
LET cCadena 	= '';
LET nCociente	= '0';
LET dFecha_Hoy	= DATE(1);
LET iMod		= 0;
LET cLetra		= '';
LET cP 			= 0;
LET k			= '';
LET iResultado  = 0;
LET cDv         = '';

--SET DEBUG FILE TO '/respaldosbd/martin/sp_validadvgdf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pCaptura,'')) = '' OR LENGTH(TRIM(pCaptura)) <> 20 THEN
		LET cCodRet = '00002';
	ELSE
	
		SELECT fecha_hoy INTO dFecha_Hoy
		FROM bdisac:"informix".sac_fechas;
		
		LET dFecha_Hoy = YEAR(dFecha_Hoy);
		
		FOR i = 1 TO 18

			IF i = 1 THEN 
				LET  k = UPPER(pCaptura[1,1]); 
			ELIF i = 2 THEN 
				LET  k = UPPER(pCaptura[2,2]);
			ELIF i = 3 THEN 
				LET  k = UPPER(pCaptura[3,3]);
			ELIF i = 4 THEN 
				LET  k = UPPER(pCaptura[4,4]);
			ELIF i = 5 THEN 
				LET  k = UPPER(pCaptura[5,5]);
			ELIF i = 6 THEN 
				LET  k = UPPER(pCaptura[6,6]);
			ELIF i = 7 THEN 
				LET  k = UPPER(pCaptura[7,7]);
			ELIF i = 8 THEN 
				LET  k = UPPER(pCaptura[8,8]);
			ELIF i = 9 THEN 
				LET  k = UPPER(pCaptura[9,9]);
			ELIF i = 10 THEN 
				LET  k = UPPER(pCaptura[10,10]);
			ELIF i = 11 THEN 
				LET  k = UPPER(pCaptura[11,11]);
			ELIF i = 12 THEN 
				LET  k = UPPER(pCaptura[12,12]);
			ELIF i = 13 THEN 
				LET  k = UPPER(pCaptura[13,13]);
			ELIF i = 14 THEN 
				LET  k = UPPER(pCaptura[14,14]);
			ELIF i = 15 THEN 
				LET  k = UPPER(pCaptura[15,15]);
			ELIF i = 16 THEN 
				LET  k = UPPER(pCaptura[16,16]);
			ELIF i = 17 THEN 
				LET  k = UPPER(pCaptura[17,17]);
			ELIF i = 18 THEN 
				LET  k = UPPER(pCaptura[18,18]); 
			END IF;

			IF k IS NOT NULL THEN

				SELECT valor 
				INTO cP 
				FROM bdisac:"informix".sac_base36
				WHERE letra = k;

				IF i = 18 OR i = 13 OR i = 8 OR i = 3 THEN
					LET cK = cP * 11;
				ELIF i = 17 OR i = 12 OR i = 7 OR i = 2 THEN
					LET cK = cP * 13;
				ELIF i = 16 OR i = 11 Or i = 6 Or i = 1 THEN
					LET cK = cP * 17;
				ELIF i = 15 OR i = 10 Or i = 5 THEN
					LET cK = cP * 19;
				ELIF i = 14 OR i = 9 Or i = 4 THEN
					LET cK = cP * 23;
				END IF;

				LET nSuma = nSuma + cK;
				
			END IF;
			
	   END FOR;

		LET iResultado = nSuma + dFecha_Hoy ;
		LET iResultado =  MOD(iResultado,887);
		LET nCociente = TRUNC(iResultado / 30);
			SELECT letra 
			INTO cLetra 
			FROM bdisac:"informix".sac_base30 
			WHERE valor = nCociente;
		LET cCadena = cLetra;
		LET iMod = MOD (iResultado,30);
			SELECT letra 
			INTO cLetra 
			FROM bdisac:"informix".sac_base30 
			WHERE valor = iMod;
		LET cDv = TRim(cCadena)||TRIM(cLetra);
		
		IF UPPER(cDv) <> UPPER(pCaptura[19,20]) THEN
			LET cCodRet = '00001';
		END IF;
		
	END IF;
	
	RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para la validación del Dígito Verificador para el Impuesto de GDF.',
'AUTOR : Martín Eduardo Miranda',
'FECHA : 12 de Diciembre 2012',
'VERSION: 20121212.12',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_validalimpago(pCaptura CHAR(20))
	RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE i			INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cK		 	CHAR(2);
DEFINE cDia         CHAR(2);
DEFINE cMes         CHAR(2);
DEFINE cAnio        CHAR(4);
DEFINE k 			CHAR(1);
DEFINE cCadenaB     CHAR(2);
DEFINE dFecha_Hoy 	DATE;
DEFINE dFechaHoy    DATE;
DEFINE dFechaLimite DATE;

--Inicializacion de Variables
LET iSqlErr 	 = 0;
LET cCodRet 	 = '00000';
LET i       	 = 0;
LET cK      	 = '';
LET dFecha_Hoy	 = DATE(1);
LET k			 = '';
LET cCadenaB 	 = '';
LET cDia     	 = '';
LET cMes     	 = '';
LET cAnio    	 = '';
LET dFechaHoy 	 = DATE(1);
LET dFechaLimite = DATE(1);
	
--SET DEBUG FILE TO '/respaldosbd/martin/sp_validalimpago.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	
	SET LOCK MODE TO WAIT 3;
	
	IF (TRIM(NVL(pCaptura,'')) = '' OR LENGTH(TRIM(pCaptura)) <> 20) THEN
		LET cCodRet = '00002';
	ELSE
		SELECT fecha_hoy INTO dFecha_Hoy
		FROM bdisac:"informix".sac_fechas;
		
		LET cAnio = YEAR(dFecha_Hoy);
		LET cMes = MONTH(dFecha_Hoy);
		LET cDia = DAY(dFecha_Hoy);
		LET dFechaHoy = LPAD(TRIM(cMes),2,'0')||'/'||LPAD(TRIM(cDia),2,'0')||'/'||TRIM(cAnio);
		
		
		LET cCadenaB = UPPER(pCaptura[14,15]);
		
		FOR i = 1 TO 2

			IF i = 1 THEN 
				LET  k = cCadenaB[1,1]; 
			ELIF i = 2 THEN 
				LET  k = cCadenaB[2,2];
			END IF;

			IF k IS NOT NULL THEN
				IF k = '1' OR k = '2' OR k = '3' OR k = '4' OR k = '5' OR k = '6' OR k = '7' OR k = '8' OR k = '9' THEN
					SELECT letra 
					INTO k 
					FROM bdisac:"informix".sac_base20
					WHERE valor = k;
				ELIF k = '0' THEN
					LET cCodRet = '00004';
				END IF;
				
				LET cK = TRIM(TRIM(cK) || TRIM(k)) ;
				
			END IF;
			
	    END FOR;
		
			IF cCodRet = '00000' THEN 
			
				SELECT dia,mes
				INTO cDia,cMes
				FROM bdisac:"informix".sac_fecha_condensada
				WHERE combinacion = cK;
				
				LET dFechaLimite = LPAD(TRIM(cMes),2,'0')||'/'||LPAD(TRIM(cDia),2,'0')||'/'||TRIM(cAnio);
				
				IF dFechaHoy <= dFechaLimite THEN
					LET cCodRet = '00000'; 
				ELSE
					LET cCodRet = '00003';
				END IF;
				
			END IF;
	END IF;
	
	RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para la validación de la Fecha Límite de Pago para el Impuesto de GDF.',
'AUTOR : Martín Eduardo Miranda',
'FECHA : 12 de Diciembre 2012',
'VERSION: 20121212.12',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_dinya_obtienemovconciliacion_pba()

RETURNING CHAR(5) AS cRegreso1, 
		  CHAR(10)  AS cRegreso2,
		  MONEY(16,2) AS cRegreso3, 
		  MONEY(16,2) AS cRegreso4,
		  CHAR(20) AS cRegreso5, 
		  MONEY(16,2) AS cRegreso6, 
		  CHAR(20) AS cRegreso7;



DEFINE cCodRet 			CHAR(5);
DEFINE cFechaHoy 		DATE;
DEFINE cFechaAyer 		DATE;
DEFINE mImporteEnviosNoCobrados 	MONEY(16,2);
DEFINE mImporteCuentaContable 	MONEY(16,2);
DEFINE cCuentaContable 	CHAR(20);
DEFINE mImporteCuentaCheques 	MONEY(16,2);
DEFINE cCuentaCheques CHAR(20);
DEFINE iSqlErr INTEGER;
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);

LET cCodRet = '00000';
LET cFechaHoy = CURRENT;
LET cFechaAyer = CURRENT;
LET mImporteCuentaContable = 0.00;
LET cCuentaContable = '';
LET mImporteCuentaCheques = 0.00;
LET cCuentaCheques = '';
LET iSqlErr = 0;
LET isam_err	= '';
LET cMensaje	= '';

BEGIN
	 ON EXCEPTION SET iSqlErr, isam_err, cMensaje
        IF iSqlErr <> 0 THEN
            Let cCodret = iSqlErr;  
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (iSqlerr,isam_err,cMensaje,'sp_dinya_ObtieneMovConciliacion',cFechaHoy,CURRENT );  
			RETURN NVL(cCodRet,'') , NVL(cFechaHoy,'') ,  NVL(mImporteEnviosNoCobrados,'0.00') , NVL(mImporteCuentaContable,'0.00'),NVL(cCuentaContable,'') , NVL(mImporteCuentaCheques,'0.00'),NVL(cCuentaCheques,'') ;
		END IF;
	END EXCEPTION;

	--	SET DEBUG FILE TO "/tmp/sp_dinya_ObtieneMovConciliacion.out";
	--	TRACE ON;
	
	--se obtiene la fecha de la sac_fechas
	SELECT fecha_hoy ,(fecha_hoy -1) INTO cFechaHoy,cFechaAyer FROM sac_fechas WHERE empresa = '001';
	--para sacar la cuenta contable parametrizada--cuenta contable
	SELECT valor INTO cCuentaContable FROM sac_param WHERE empresa = '001'  AND cod_param = '78';
	--la cuenta de cheques
	SELECT valor INTO cCuentaCheques FROM sac_param WHERE empresa = '001'  AND cod_param = '75';
	--se obtiene el saldo de la cuenta de cheques que esta parametrizada con el cod 75
	SET ISOLATION TO DIRTY READ;
	SELECT (sdo_actual -(sdo_cong + sdo_retenido))
	INTO mImporteCuentaCheques
	FROM bdicheq:sc_maechq
	WHERE empresa = '001' AND cuenta = TRIM(cCuentaCheques);
	--se obtiene el parametro de la cuenta contable
	SET ISOLATION TO DIRTY READ;
	Select nvl(Sum(saldo_fin_de_dia),0)
	INTO mImporteCuentaContable
	From bdicont:co_sdodias
	---Where empresa='001' and ccmayor = substr(TRIM(cCuentaContable),1,4)
	Where empresa='001' and ccmayor = substr(cCuentaContable,1,4)
	---And ccsub = substr(TRIM(cCuentaContable),5,2)
	And ccsub = substr(cCuentaContable,5,2)
	---And ccsubsub = substr(TRIM(cCuentaContable),7,2)
	And ccsubsub = substr(cCuentaContable,7,2)
	---And ccssubsub = substr(TRIM(cCuentaContable),9,2)
	And ccssubsub = substr(cCuentaContable,9,2)
	---And ccsssubsub = substr(TRIM(cCuentaContable),11,2)
	And ccsssubsub = substr(cCuentaContable,11,2)
	---And sector = substr(TRIM(cCuentaContable),13,2)
	And sector = substr(cCuentaContable,13,2)
	And mes_dia = cFechaAyer;    
	--obtener el total de los enviops no cobrados
	SET ISOLATION TO DIRTY READ;
	SELECT SUM(importe_envio)
	INTO mImporteEnviosNoCobrados
	FROM bdisac:sac_enviosdineroya AS env
	WHERE fecha_envio <= cFechaHoy
	AND env.estatus IN('01','03');

	RETURN NVL(cCodRet,'') , NVL(cFechaHoy,'') ,  NVL(mImporteEnviosNoCobrados,'0.00') , NVL(mImporteCuentaContable,'0.00'),NVL(cCuentaContable,'') , NVL(mImporteCuentaCheques,'0.00'),NVL(cCuentaCheques,'') ;

END
END PROCEDURE
Document
'DESCRIPCION:  Obtener informacion de los envios pendientes de pago, ademas del saldo de la cuenta prestadora de servicio y la cuenta contable', 
'AUTOR: César Valdéz Figueroa',
'FECHA: 06 de Noviembre de 2009',
'VERSION: 20091112.0730',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sacreportesremesasnoconciliadasbtsrev_pba(Fecha_Inicio DATE, Fecha_Fin DATE, pUsuario CHAR(8))

RETURNING 
		CHAR(5)		AS RetCodigoRet,
		DATE    	AS RetFecha, 
		INTEGER 	AS RetServicios,
		INTEGER 	AS RetCheques, 
		INTEGER 	AS RetBTS,
		CHAR(16)    AS RetDiferencia; 
		
		--DEFINICION DE VARIABLES 
		DEFINE iSqlError 			INTEGER;
		DEFINE cCodRet 				CHAR(5);
		DEFINE dFechaHoy 			DATE ;
		DEFINE iServicios 			INTEGER; 
		DEFINE cDiferencia 			CHAR(16);
		DEFINE dFechaIni 			DATE;
		DEFINE dFechaFin 			DATE;
		DEFINE cFolioSucCheques 	CHAR(16);
		DEFINE cReferencia 			CHAR(11);
		DEFINE cCuentaPrestadora	CHAR(11);	
		DEFINE iSumaServicios		INTEGER;
		DEFINE iCantidadPagos       INTEGER;
		DEFINE cStatus				CHAR(1);
		DEFINE iCantidadPagosServ   INTEGER;
		DEFINE iCantidadPagosREVI   INTEGER;
		DEFINE iCantidadREVI        INTEGER;  
        DEFINE iSumaCantidadREVI    INTEGER;  	
		DEFINE cTransaccEfec        CHAR(4);
		DEFINE cTransaccAbo         CHAR(4);
		
		-- 13-03-2013
		DEFINE cFolioSucServicios   CHAR(16);
		DEFINE cBankRefBTS			CHAR(16);
		DEFINE cConfirmacionBTS 	CHAR(11);
		DEFINE cExiste				CHAR(2);
		DEFINE dFechaMaxima 		DATETIME YEAR TO FRACTION(5);
		DEFINE iCountServicios		INTEGER;
		DEFINE iCount 				INTEGER;
		
		--INICIALIZAMOS LAS VARIABLES
		LET iSqlError = 0; 
		LET cCodRet = '00000';
		LET dFechaHoy = CURRENT;
		LET iServicios = 0;
		LET cDiferencia ="Sin Diferencia";
		LET dFechaIni=CURRENT;
		LET dFechaFin = CURRENT;
		LET cFolioSucCheques = "";
		LET cReferencia ="";
		LET cCuentaPrestadora = "";
		LET iCantidadPagos = 0;
		LET cStatus = "";
		LET iCantidadPagosServ = 0;
		LET iCantidadPagosREVI  = 0;
		LET iCantidadREVI  = 0;
		LET iSumaCantidadREVI  = 0;
		LET cTransaccEfec      = "";
		LET cTransaccAbo      = "";
		
		--13-03-2013
		LET cFolioSucServicios = "";
		LET cBankRefBTS ="";
		LET cConfirmacionBTS = ""; 
		LET cExiste = "NO";
		LET dFechaMaxima = CURRENT;
		LET iCountServicios = 0;
		LET iCount =0;
		
		BEGIN
			ON EXCEPTION SET iSqlError
				IF iSqlError <> 0 THEN
			
					LET cCodRet = iSqlError;

					DELETE FROM bdisac:"informix".sac_chequesrev_paso WHERE usuario = pUsuario;
					DELETE FROM bdisac:"informix".sac_serviciosrev_paso WHERE usuario = pUsuario;
					DELETE FROM bdisac:"informix".sac_btsrevi_paso WHERE usuario = pUsuario;
					DELETE FROM bdisac:"informix".sac_conciliacionrev_paso WHERE usuario = pUsuario; 
					
					------Insertamos en las tablas pagadas  14-03-2013
					DELETE FROM bdisac:"informix".sac_cheques_paso WHERE usuario = pUsuario;
					DELETE FROM bdisac:"informix".sac_servicios_paso WHERE usuario = pUsuario;
					DELETE FROM bdisac:"informix".sac_abono_paso WHERE usuario = pUsuario;
					DELETE FROM bdisac:"informix".sac_conciliacionbts_paso WHERE usuario = pUsuario;
					DELETE FROM bdisac:"informix".sac_btscaja_paso WHERE usuario = pUsuario;
					
					
		
					RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,cDiferencia;	

				END IF;
			END EXCEPTION;
			
			
			--SET DEBUG FILE TO "/respaldosbd/eduardo/sp_sacreportesremesasnoconciliadasbtsrev.out";
			--TRACE ON;
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			IF (Fecha_Inicio =="" OR Fecha_Inicio IS NULL) OR (Fecha_Fin =="" OR Fecha_Fin IS NULL) THEN 
				LET cCodRet = '00001'; --Parametros vacios
				RETURN cCodRet,'','','','','';
	
			ELSE 
			
				DELETE FROM bdisac:"informix".sac_chequesrev_paso WHERE usuario = pUsuario;
				DELETE FROM bdisac:"informix".sac_serviciosrev_paso WHERE usuario = pUsuario;
				DELETE FROM bdisac:"informix".sac_btsrevi_paso WHERE usuario = pUsuario;
				DELETE FROM bdisac:"informix".sac_conciliacionrev_paso WHERE usuario = pUsuario; 
				
				------Insertamos en las tablas pagadas  14-03-2013
				DELETE FROM bdisac:"informix".sac_cheques_paso WHERE usuario = pUsuario;
				DELETE FROM bdisac:"informix".sac_servicios_paso WHERE usuario = pUsuario;
				DELETE FROM bdisac:"informix".sac_abono_paso WHERE usuario = pUsuario;
				DELETE FROM bdisac:"informix".sac_conciliacionbts_paso WHERE usuario = pUsuario;
				DELETE FROM bdisac:"informix".sac_btscaja_paso WHERE usuario = pUsuario;
			
				SELECT fecha_hoy {+INDEX(bdisac:"informix".sac_fechas idx_fechas1)}
				INTO dFechaHoy
				FROM bdisac:"informix".sac_fechas
				WHERE empresa = '001'; 
				
				SELECT cuenta_prestadora, trans_cen_efectivo_cliente, trans_cen_cargo_cliente
				INTO cCuentaPrestadora, cTransaccEfec, cTransaccAbo
				FROM bdisac:"informix".sac_convenios 
				WHERE numcategoria='07' 
				AND numconvenio='004';
				
				--Tomamos los valores de las fecha de los parametros
				LET dFechaIni = Fecha_Inicio;
				LET dFechaFin = Fecha_Fin;
				
				IF dFechaIni = dFechaFin AND dFechaIni = dFechaHoy THEN --Consulta del dÃ­a
					INSERT INTO bdisac:"informix".sac_chequesrev_paso
					SELECT folio_suc, fech_alt, pUsuario
					FROM bdicheq:"informix".sc_movdia 
					WHERE cuenta = cCuentaPrestadora
					AND cancelad = 'S'
					AND fech_alt = dFechaHoy
					AND transacc IN (cTransaccEfec,cTransaccAbo)
					AND referencia = 'REV';
					
					--Insertamos en las tablas pagadas  14-03-2013
					INSERT INTO bdisac:"informix".sac_cheques_paso
					SELECT folio_suc, fech_alt, pUsuario
					FROM bdicheq:"informix".sc_movdia 
					WHERE cuenta = cCuentaPrestadora
					AND fech_alt = dFechaHoy 
					AND cancelad <> 'S'
					AND transacc IN (cTransaccEfec,cTransaccAbo);
					
					INSERT INTO bdisac:"informix".sac_serviciosrev_paso
					SELECT  folio_suc,referencia1,status_cancelado, fecha_pago,fecha_insert, pUsuario --INTO cFolioSucServicios,cReferencia,cStatus
					FROM bdisac:"informix".sac_movimientos
					WHERE numcategoria= '07'  
					AND numconvenio='004'
					AND fecha_pago= dFechaHoy;
					
					--Insertamos en las tablas pagadas  13-03-2013
					INSERT INTO bdisac:"informix".sac_servicios_paso
					SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, pUsuario --se agrego fecha_insert 13-03-2013
					FROM bdisac:"informix".sac_movimientos
					WHERE numcategoria= '07'  
					AND numconvenio='004'
					AND fecha_pago= dFechaHoy;
					
					
				ELIF (dFechaIni <> dFechaFin AND dFechaIni <> dFechaHoy AND dFechaFin <> dFechaHoy) OR (dFechaIni = dFechaFin AND dFechaIni <> dFechaHoy AND dFechaFin <> dFechaHoy) THEN --Consulta del dÃ­a
					INSERT INTO bdisac:"informix".sac_chequesrev_paso
					SELECT folio_suc, fech_alt, pUsuario
					FROM bdicheq:"informix".sc_movhis 
					WHERE cuenta = cCuentaPrestadora
					AND cancelad = 'S'
					AND fech_alt >= dFechaIni
					AND fech_alt <= dFechaFin
					AND transacc IN (cTransaccEfec,cTransaccAbo)
					AND referencia = 'REV';	
					
					----Insertamos en las tablas pagadas  13-03-2013
					INSERT INTO bdisac:"informix".sac_cheques_paso
					SELECT folio_suc, fech_alt, pUsuario
					FROM bdicheq:"informix".sc_movhis 
					WHERE cuenta = cCuentaPrestadora
					AND cancelad <> 'S'
					AND fech_alt >= dFechaIni
					AND fech_alt <= dFechaFin
					AND transacc IN (cTransaccEfec,cTransaccAbo);
					
					INSERT INTO bdisac:"informix".sac_serviciosrev_paso
					SELECT  folio_suc,referencia1,status_cancelado, fecha_pago,fecha_insert, pUsuario --INTO cFolioSucServicios,cReferencia,cStatus
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria= '07'  
					AND numconvenio='004'
					AND fecha_pago >= dFechaIni
					AND fecha_pago <= dFechaFin;
					
					---Insertamos en las tablas pagadas  13-03-2013
					INSERT INTO bdisac:"informix".sac_servicios_paso
					SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, pUsuario --se agrego fecha_insert 13-03-2013
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria= '07'  
					AND numconvenio='004'
					AND fecha_pago >= dFechaIni
					AND fecha_pago <= dFechaFin;
					
				ELSE
				    INSERT INTO bdisac:"informix".sac_chequesrev_paso
					SELECT folio_suc, fech_alt, pUsuario
					FROM bdicheq:"informix".sc_movdia 
					WHERE cuenta = cCuentaPrestadora
					AND cancelad = 'S'
					AND fech_alt = dFechaHoy
					AND transacc IN (cTransaccEfec,cTransaccAbo)
					AND referencia = 'REV';
					
						--Insertamos en las tablas pagadas  13-03-2013
					INSERT INTO bdisac:"informix".sac_cheques_paso
					SELECT folio_suc, fech_alt, pUsuario
					FROM bdicheq:"informix".sc_movdia 
					WHERE cuenta = cCuentaPrestadora
					AND fech_alt = dFechaHoy 
					AND cancelad <> 'S'
					AND transacc IN (cTransaccEfec,cTransaccAbo);
					
					
					INSERT INTO bdisac:"informix".sac_chequesrev_paso
					SELECT folio_suc, fech_alt, pUsuario
					FROM bdicheq:"informix".sc_movhis 
					WHERE cuenta = cCuentaPrestadora
					AND cancelad = 'S'
					AND fech_alt >= dFechaIni
					AND fech_alt <= dFechaFin
					AND transacc IN (cTransaccEfec,cTransaccAbo)
					AND referencia = 'REV';	
					
					----Insertamos en las tablas pagadas  13-03-2013
					INSERT INTO bdisac:"informix".sac_cheques_paso
					SELECT folio_suc, fech_alt, pUsuario
					FROM bdicheq:"informix".sc_movhis 
					WHERE cuenta = cCuentaPrestadora
					AND cancelad <> 'S'
					AND fech_alt >= dFechaIni
					AND fech_alt <= dFechaFin
					AND transacc IN (cTransaccEfec,cTransaccAbo);
					
					
					
					INSERT INTO bdisac:"informix".sac_serviciosrev_paso
					SELECT  folio_suc,referencia1,status_cancelado, fecha_pago,fecha_insert, pUsuario --INTO cFolioSucServicios,cReferencia,cStatus
					FROM bdisac:"informix".sac_movimientos
					WHERE numcategoria= '07'  
					AND numconvenio='004'
					AND fecha_pago= dFechaHoy;
					
						--Insertamos en las tablas pagadas  13-03-2013
					INSERT INTO bdisac:"informix".sac_servicios_paso
					SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, pUsuario --se agrego fecha_insert 13-03-2013
					FROM bdisac:"informix".sac_movimientos
					WHERE numcategoria= '07'  
					AND numconvenio='004'
					AND fecha_pago= dFechaHoy;

					
					INSERT INTO bdisac:"informix".sac_serviciosrev_paso
					SELECT  folio_suc,referencia1,status_cancelado, fecha_pago, fecha_insert,pUsuario --INTO cFolioSucServicios,cReferencia,cStatus
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria= '07'  
					AND numconvenio='004'
					AND fecha_pago >= dFechaIni
					AND fecha_pago <= dFechaFin;
					
					---Insertamos en las tablas pagadas  13-03-2013
					INSERT INTO bdisac:"informix".sac_servicios_paso
					SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, pUsuario --se agrego fecha_insert 13-03-2013
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria= '07'  
					AND numconvenio='004'
					AND fecha_pago >= dFechaIni
					AND fecha_pago <= dFechaFin;
					
				END IF;

				INSERT INTO bdisac:"informix".sac_btsrevi_paso
				SELECT confirmation_nm, bank_ref_nm, fecha_insert, pUsuario--, bank_ref_nm
				FROM bdisac:"informix".sac_bts_revi
				WHERE opcode = '1200'
				AND fecha_insert::DATE >= dFechaIni
				AND fecha_insert::DATE <= dFechaFin;
				
				---Insertamos en las tablas pagadas  14-03-2013
				INSERT INTO bdisac:"informix".sac_abono_paso
				SELECT confirmation_nm, bank_ref_nm, fecha_insert, pUsuario
				FROM bdisac:"informix".sac_bts_payc
				WHERE opcode = '1100'
				AND process_type_code = 'PAYC'
				AND fecha_insert::DATE >= dFechaIni
				AND fecha_insert::DATE <= dFechaFin;
				
				---Insertamos en las tablas pagadas  14-03-2013
				INSERT INTO bdisac:"informix".sac_btscaja_paso
				SELECT confirmation_nm, bank_ref_nm, fecha_insert, pUsuario
				FROM bdisac:"informix".sac_bts_payi
				WHERE opcode = '1100'
				AND fecha_insert::DATE  >= dFechaIni
				AND fecha_insert::DATE  <= dFechaFin;
				
				
				WHILE (dFechaIni <= dFechaFin)

					SELECT COUNT(folio_suc) --SERVICIOS
					INTO iCantidadPagosServ
					FROM bdisac:"informix".sac_serviciosrev_paso
					WHERE fecha_pago = dFechaIni
					AND status_cancelado = 'S'
					AND usuario = pUsuario;
					
					--REALIZAMOS LA BUQUEDA PORFECHAS ANTERIORES
					SELECT COUNT(folio_suc)  --cheques
					INTO iCantidadPagos
					FROM bdisac:"informix".sac_chequesrev_paso
					WHERE fech_alt = dFechaIni
					AND usuario = pUsuario;
					
					SELECT COUNT(confirmation_nm)
					INTO iCantidadPagosREVI
					FROM bdisac:"informix".sac_btsrevi_paso
					WHERE fecha_insert = dFechaIni
					AND usuario = pUsuario;
						
					IF ((iCantidadPagosServ = iCantidadPagos) AND (iCantidadPagosREVI = iCantidadPagosServ)) THEN
						LET cDiferencia = "Sin Diferencia";
						RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,cDiferencia WITH RESUME;
					ELSE
					    DELETE FROM bdisac:"informix".sac_conciliacionrev_paso WHERE usuario = pUsuario;
					    IF (iCantidadPagos > iCantidadPagosServ) THEN
						---checar
							INSERT INTO bdisac:"informix".sac_conciliacionrev_paso
							SELECT cheq.folio_suc ,mov.referencia1, pUsuario 
							FROM bdisac:"informix".sac_chequesrev_paso cheq, bdisac:"informix".sac_serviciosrev_paso mov
							WHERE cheq.fech_alt = dFechaIni
							AND  cheq.fech_alt = mov.fecha_pago
							AND  cheq.folio_suc =  mov.folio_suc
							AND cheq.usuario = pUsuario
							AND cheq.usuario = mov.usuario
							AND cheq.folio_suc NOT IN (SELECT folio_suc
												FROM bdisac:"informix".sac_serviciosrev_paso
												WHERE fecha_pago = dFechaIni
												AND status_cancelado = 'S'
												AND usuario = pUsuario);
						---												
					    END IF;

					    IF (iCantidadPagosServ > iCantidadPagos) THEN
							INSERT INTO bdisac:"informix".sac_conciliacionrev_paso
							SELECT folio_suc, referencia1, pUsuario
							FROM bdisac:"informix".sac_serviciosrev_paso
							WHERE fecha_pago = dFechaIni
							AND status_cancelado = 'S'
							AND usuario = pUsuario
							AND  folio_suc NOT IN(SELECT folio_suc 
												  FROM bdisac:"informix".sac_chequesrev_paso
												  WHERE fech_alt = dFechaIni
												  AND usuario = pUsuario)
							AND folio_suc NOT IN(SELECT folio_suc 
												FROM bdisac:"informix".sac_conciliacionrev_paso
												WHERE usuario = pUsuario);
					    END IF;

 					    IF (iCantidadPagos > iCantidadPagosREVI) THEN
							INSERT INTO bdisac:"informix".sac_conciliacionrev_paso
							SELECT cheq.folio_suc ,mov.referencia1, pUsuario
							FROM bdisac:"informix".sac_chequesrev_paso cheq, bdisac:"informix".sac_serviciosrev_paso mov
							WHERE cheq.fech_alt = dFechaIni
							AND  cheq.fech_alt = mov.fecha_pago
							AND  cheq.folio_suc =  mov.folio_suc
							AND cheq.usuario = pUsuario
							AND cheq.usuario = mov.usuario
							AND cheq.folio_suc NOT IN (SELECT bank_ref_nm 
													FROM bdisac:"informix".sac_btsrevi_paso
													WHERE fecha_insert = dFechaIni
													AND usuario = pUsuario)
							AND cheq.folio_suc NOT IN(SELECT folio_suc 
												FROM bdisac:"informix".sac_conciliacionrev_paso
												WHERE usuario = pUsuario);
					    END IF;

 					    IF (iCantidadPagosServ > iCantidadPagosREVI) THEN
							INSERT INTO bdisac:"informix".sac_conciliacionrev_paso
							SELECT folio_suc, referencia1, pUsuario 
							FROM bdisac:"informix".sac_serviciosrev_paso
							WHERE fecha_pago = dFechaIni
							AND status_cancelado = 'S'
							AND usuario = pUsuario
							AND folio_suc NOT IN (SELECT bank_ref_nm 
												FROM bdisac:"informix".sac_btsrevi_paso
												WHERE fecha_insert = dFechaIni
												AND usuario = pUsuario)
							AND folio_suc NOT IN(SELECT folio_suc 
												FROM bdisac:"informix".sac_conciliacionrev_paso
												WHERE usuario = pUsuario);
					    END IF;

 					    IF (iCantidadPagosREVI  > iCantidadPagos) THEN
							INSERT INTO bdisac:"informix".sac_conciliacionrev_paso
							SELECT bank_ref_nm, confirmation_nm, pUsuario 
							FROM bdisac:"informix".sac_btsrevi_paso
							WHERE fecha_insert = dFechaIni
							AND usuario = pUsuario
							AND bank_ref_nm NOT IN (SELECT folio_suc 
													FROM bdisac:"informix".sac_chequesrev_paso
													WHERE fech_alt = dFechaIni
													AND usuario = pUsuario)
							AND bank_ref_nm NOT IN(SELECT folio_suc 
												FROM bdisac:"informix".sac_conciliacionrev_paso
												WHERE usuario = pUsuario);
					    END IF;

 					    IF (iCantidadPagosREVI  > iCantidadPagosServ) THEN
							INSERT INTO bdisac:"informix".sac_conciliacionrev_paso
							SELECT bank_ref_nm, confirmation_nm, pUsuario
							FROM bdisac:"informix".sac_btsrevi_paso
							WHERE fecha_insert = dFechaIni
							AND usuario = pUsuario
							AND bank_ref_nm NOT IN (SELECT folio_suc
													FROM bdisac:"informix".sac_serviciosrev_paso
													WHERE fecha_pago = dFechaIni
													AND status_cancelado = 'S'
													AND usuario = pUsuario)
							AND bank_ref_nm NOT IN(SELECT folio_suc 
												FROM bdisac:"informix".sac_conciliacionrev_paso
												WHERE usuario = pUsuario);
					    END IF;

				 	    FOREACH 
						
					        SELECT DISTINCT(referencia) 
                            INTO cReferencia
							FROM bdisac:"informix".sac_conciliacionrev_paso
							WHERE usuario = pUsuario
							
							SELECT COUNT(referencia)
							INTO iSumaServicios 
							FROM bdisac:"informix".sac_conciliacionrev_paso
							WHERE referencia = cReferencia
							AND usuario = pUsuario; 
							
							--SE AGREGO 13-03-2013 INICIO
							SELECT COUNT(referencia)
							INTO iCountServicios 
							FROM bdisac:"informix".sac_conciliacionrev_paso
							WHERE usuario = pUsuario; 	 
							
							IF iSumaServicios > 1 THEN 
								LET iCount = iCount + iSumaServicios ;
							ELSE 
								LET iCount = iCount + 1;
							END IF;						
								
							  SELECT MAX(fecha_insert) 
							  INTO dFechaMaxima 
							  FROM bdisac:"informix".sac_servicios_paso 
							  WHERE referencia1 = cReferencia
							  AND fecha_pago = dFechaIni
							  AND usuario = pUsuario;
								
								IF EXISTS (SELECT folio_suc FROM bdisac:"informix".sac_servicios_paso WHERE fecha_insert = dFechaMaxima AND status_cancelado = 'N' AND referencia1 = cReferencia AND usuario = pUsuario) THEN --
								
									SELECT folio_suc 
									INTO cFolioSucServicios
									FROM bdisac:"informix".sac_servicios_paso
									WHERE fecha_insert = dFechaMaxima 
									AND status_cancelado = 'N'
									AND fecha_insert = dFechaMaxima
									AND referencia1 = cReferencia
									AND usuario = pUsuario;
									
									IF EXISTS(SELECT folio_suc FROM bdisac:"informix".sac_cheques_paso  WHERE folio_suc = cFolioSucServicios AND fech_alt = dFechaIni AND usuario = pUsuario) THEN 
										
											IF EXISTS (SELECT bank_ref_nm,confirmation_nm FROM bdisac:"informix".sac_btscaja_paso WHERE bank_ref_nm= cFolioSucServicios AND confirmation_nm = cReferencia AND usuario = pUsuario)THEN --
													
												SELECT bank_ref_nm,confirmation_nm 
												INTO cBankRefBTS, cConfirmacionBTS
												FROM bdisac:"informix".sac_abono_paso
												WHERE bank_ref_nm= cFolioSucServicios
												AND confirmation_nm = cReferencia
												AND usuario = pUsuario;
												
												IF NVL(cBankRefBTS,'') <> '' AND NVL(cConfirmacionBTS,'') <> '' THEN 
													
													LET cExiste = "SI";
												ELSE 
													LET cExiste = "SI";
												END IF;	
												
												 
											ELIF EXISTS (SELECT bank_ref_nm,confirmation_nm FROM bdisac:"informix".sac_abono_paso WHERE bank_ref_nm= cFolioSucServicios AND confirmation_nm = cReferencia AND usuario = pUsuario )THEN --
												
												LET cExiste = "SI";
												
											END IF;
									END IF;	
								END IF;
							
							IF cExiste = "NO" THEN 
							
								IF iSumaServicios > 1 THEN 
									LET cDiferencia = cReferencia || "(" || iSumaServicios||")";
									RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,cDiferencia WITH RESUME;
								ELSE 
									LET cDiferencia = cReferencia;
									RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,cDiferencia WITH RESUME;
								END IF;
								
							ELIF  cExiste = "SI" AND iCount = iCountServicios AND cDiferencia = "Sin Diferencia" THEN 
							--* Si todas las referencias existieron y es el ultimo registro pintamos sin diferencias
							--* Pero si ubo una diferencia antes en la misma fecha pero el ultimo registro si existe  
							
								RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,cDiferencia WITH RESUME;
								
							END IF;
                            
							LET cFolioSucServicios = "";							
							LET cExiste = "NO";
							LET cReferencia = "";
							LET iSumaServicios =0;
							LET cBankRefBTS = "";
							LET cConfirmacionBTS = "";
							--SE AGREGO 13-03-2013 FIN 
                                               
                            /*IF iSumaServicios > 1 THEN
								LET cDiferencia = cReferencia || "(" || iSumaServicios||")";
							ELSE
								LET cDiferencia = cReferencia;
							END IF;
					
							RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,cDiferencia WITH RESUME;
							*/
					    END FOREACH;
						
					END IF;
					
					--AUMENTAMOS UN DIA EN LA dFechaIni
					LET iSumaServicios = 0;
					LET iCantidadPagosServ = 0;
					LET iCantidadPagos =0;
					LET iCantidadPagosREVI = 0;
					LET iCantidadREVI = 0;
					LET iServicios = 0;
					---
					LET iCount = 0;
					LET iCountServicios =0;
					LET cDiferencia = "Sin Diferencia";
					
					LET dFechaIni = dFechaIni + INTERVAL(1) DAY TO DAY;
				END WHILE;
			END IF;		
		END 
		
		DELETE FROM bdisac:"informix".sac_chequesrev_paso WHERE usuario = pUsuario;
		DELETE FROM bdisac:"informix".sac_serviciosrev_paso WHERE usuario = pUsuario;
		DELETE FROM bdisac:"informix".sac_btsrevi_paso WHERE usuario = pUsuario;
		DELETE FROM bdisac:"informix".sac_conciliacionrev_paso WHERE usuario = pUsuario; 
		
		------Insertamos en las tablas pagadas  14-03-2013
		DELETE FROM bdisac:"informix".sac_cheques_paso WHERE usuario = pUsuario;
		DELETE FROM bdisac:"informix".sac_servicios_paso WHERE usuario = pUsuario;
		DELETE FROM bdisac:"informix".sac_abono_paso WHERE usuario = pUsuario;
		DELETE FROM bdisac:"informix".sac_conciliacionbts_paso WHERE usuario = pUsuario;
		DELETE FROM bdisac:"informix".sac_btscaja_paso WHERE usuario = pUsuario;
		
		
END PROCEDURE 
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener los totales para las transacciones REVERSADAS de Servicio,Cheques,BTSCaja ',
'para el reporte de remesas no conciliadas BTS, asu ves mostrar las diferencias si existen entre',
'cada una de las sumatorias',
'AUTOR :Eduardo LÃ³pez',
'FECHA : 07/02/2013',
'Ver.  : 1.0',
'BD    : bdisac',

'MODIFICO: Eduardo LÃ³pez ',
'FECHA: 13/03/2013 ',
'VER. : 1.1 ',
'BD: bdisac',
'MODIFICACION: Se modifica sp, de las diferencias obtenidas validar si se intento un pago posterior y este haya sido exitoso  ',
'en caso de que exista un registro exitoso con la misma referencia no se mostrara en las diferencias, caso contrario se mostrara';

CREATE PROCEDURE "informix".sp_sacreportesemanalcam(pConvenio CHAR (5),pConsecutivo INTEGER)
	RETURNING
			CHAR (6) 	AS retorno,
			INTEGER 	AS rec_lunes ,
			INTEGER 	AS rec_martes,
			INTEGER 	AS rec_miercoles,
			INTEGER 	AS rec_jueves,
			INTEGER 	AS rec_viernes,
			INTEGER 	AS rec_sabado,
			INTEGER 	AS rec_domingo,
			MONEY(16,2) AS cob_lunes,
			MONEY(16,2) AS cob_martes,
			MONEY(16,2) AS cob_miercoles,
			MONEY(16,2) AS cob_jueves,
			MONEY(16,2) AS cob_viernes,
			MONEY(16,2) AS cob_sabado,
			MONEY(16,2) AS cob_domingo,
			INTEGER 	AS rec_efectivo,
			INTEGER 	AS rec_chequemb,
			INTEGER 	AS rec_chequeob,
			INTEGER 	AS rec_tarcred,
			MONEY(16,2) AS cob_efectivo,
			MONEY(16,2) AS cob_cheqmb,
			MONEY(16,2) AS cob_cheqob,
			MONEY(16,2) AS cob_tarcred,
			MONEY(16,2) AS liq_miercoles,
			MONEY(16,2) AS liq_jueves,
			MONEY(16,2) AS liq_viernes,
			MONEY(16,2) AS liq_lunes,
			MONEY(16,2) AS liq_martes,
			MONEY(16,2) AS aclaraciones,
			MONEY(16,2) AS comision,
			MONEY(16,2) AS iva_comision,
			DATE        AS fec_iniperiodo,
			DATE 	    AS fec_finperiodo,
			INTEGER 	AS keyx;

 --Definicion de Variables
	DEFINE cCodRet			CHAR (6);
	DEFINE cInfoErr         CHAR(100);
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE iRecLunes		INTEGER;
	DEFINE iRecMartes		INTEGER;
	DEFINE iRecMiercoles	INTEGER;
	DEFINE iRecJueves		INTEGER;
	DEFINE iRecViernes		INTEGER;
	DEFINE iRecSabado		INTEGER;
	DEFINE iRecDomingo		INTEGER;
	DEFINE iRecEfectivo		INTEGER;
	DEFINE iRecChequemb		INTEGER;
	DEFINE iRecChequeob		INTEGER;
	DEFINE iRecTarcred		INTEGER;
	DEFINE iCobEfectivo		INTEGER;
	DEFINE dFecIniPeriodo	DATE;
	DEFINE dFecFinPeriodo	DATE;
	DEFINE mCobLunes		MONEY(16,2);
	DEFINE mCobMartes		MONEY(16,2);
	DEFINE mCobMiercoles	MONEY(16,2);
	DEFINE mCobJueves		MONEY(16,2);
	DEFINE mCobViernes		MONEY(16,2);
	DEFINE mCobSabado		MONEY(16,2);
	DEFINE mCobDomingo		MONEY(16,2);
	DEFINE mCobCheqmb		MONEY(16,2);
	DEFINE mCobCheqob		MONEY(16,2);
	DEFINE mCobTarcred		MONEY(16,2);
	DEFINE mLiqMiercoles	MONEY(16,2);
	DEFINE mLiqJueves		MONEY(16,2);
	DEFINE mLiqViernes		MONEY(16,2);
	DEFINE mLiqLunes		MONEY(16,2);
	DEFINE mLiqMartes		MONEY(16,2);
	DEFINE mAclaraciones	MONEY(16,2);
	DEFINE mComision		MONEY(16,2);
	DEFINE mIvaComision		MONEY(16,2);

--Inicializacion de Variables
	LET cCodRet			= '000000';
	LET iRecLunes		= 0;
	LET iRecMartes		= 0;
	LET iRecMiercoles	= 0;
	LET iRecJueves		= 0;
	LET iRecViernes		= 0;
	LET iRecSabado		= 0;
	LET iRecDomingo		= 0;
	LET mCobLunes		= 0;
	LET mCobMartes		= 0;
	LET mCobMiercoles	= 0;
	LET mCobJueves		= 0;
	LET mCobViernes		= 0;
	LET mCobSabado		= 0;
	LET mCobDomingo		= 0;
	LET iRecEfectivo	= 0;
	LET iRecChequemb	= 0;
	LET iRecChequeob	= 0;
	LET iRecTarcred		= 0;
	LET iCobEfectivo	= 0;
	LET mCobCheqmb		= 0;
	LET mCobCheqob		= 0;
	LET mCobTarcred		= 0;
	LET mLiqMiercoles	= 0;
	LET mLiqJueves		= 0;
	LET mLiqViernes		= 0;
	LET mLiqLunes		= 0;
	LET mLiqMartes		= 0;
	LET mAclaraciones	= 0;
	LET mComision		= 0;
	LET mIvaComision	= 0;
	LET dFecIniPeriodo	= DATE (1);
	LET dFecFinPeriodo	= DATE (1);
	LET iSqlErr			= 0;
	LET iIsamErr		= 0;
	LET cInfoErr		= '';

	--SET DEBUG FILE TO '/respaldosbd/eduardo/sp_generaarchivocobranzacam.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanalcam");
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo;
		END IF;

	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	IF  pConsecutivo IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
			mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
			mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
			mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo;
	ELSE
		SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdisac:"informix".sac_liquidacionsemanal idx_sacliqsem)} rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, cob_martes,
					cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
					cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred, liq_miercoles, liq_jueves, liq_viernes, liq_lunes, liq_martes,
					aclaraciones, comision, iva_comision, fec_iniperiodo, fec_finperiodo
				INTO iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo
				FROM bdisac:"informix".sac_liquidacionsemanal
				WHERE id_convenio = pConvenio
				AND  consecutivo_convenio  = pConsecutivo


				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo WITH RESUME;
			END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Eduardo López Cuevas',
'DESCRIPCIÓN: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos referenciados (CAMINEMOS)',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 22 de Mayo 2013',
'VERSIÓN: 20130522',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportemensualcam(pConvenio CHAR(5), pPeriodo CHAR(6))
RETURNING
		CHAR (6) 	  AS retorno,
		CHAR(6) 	  AS aniomes,
		DATE 	 	  AS fecha,
		INTEGER       AS num_operaciones,
		MONEY (16,2)  AS comision,
		MONEY (16,2)  AS iva;

--Definicion de Variables
DEFINE cCodRet			 CHAR(6);
DEFINE cAnioMes			 CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE dFecha			 DATE;
DEFINE iNumOperaciones	 INTEGER;
DEFINE iSqlErr			 INTEGER;
DEFINE iIsamErr			 INTEGER;
DEFINE mComision		 MONEY(16,2);
DEFINE mIva				 MONEY(16,2);

--Inicializacion de Variables
LET cCodRet				 = '000000';
LET cAnioMes			 = '';
LET dFecha				 = DATE (1);
LET iNumOperaciones		 = 0;
LET mComision			 = 0;
LET mIva				 = 0;
LET iSqlErr				 = 0;
LET iIsamErr			 = 0;
LET cInfoErr			 = '';

-- SET DEBUG FILE TO  '/respaldosbd/eduardo/sp_sacreportemensualcam.out';
-- TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualcam");
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	IF  pPeriodo = "" OR LENGTH(pPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE
		SET ISOLATION TO DIRTY READ;
		FOREACH

			SELECT aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac:"informix".sac_liquidacionmensual
			WHERE aniomes = pPeriodo
			AND id_convenio = pConvenio
			ORDER BY fecha

			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Eduardo López Cuevas',
'DESCRIPCIÓN: Obtiene la informacion para la generacion del reporte mensual de pagos referenciados (CAMINEMOS)',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 23 de Mayo 2013',
'VERSIÓN: 20130523.0848',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reportewu_conciliacion (pFechaIni DATE, pFechaFin DATE, pConvenio CHAR(5))

RETURNING
DATE 		AS Dia,
CHAR (20) 	AS Forma_Pago,
MONEY 		AS Cargo_Pago_Remesa,
MONEY 		AS Saldo_Cuenta_WU,
CHAR (16) 	AS Folio_Operacion,
CHAR (11) 	AS Clave_Envio,
CHAR (4) 	AS Sucursal,
CHAR (8) 	AS Cajero,
CHAR(20) 	AS Importe_Pago;


/*  DEFINICION DE VARIABLES */
DEFINE dDia 				DATE;
DEFINE cForma_Pago 			CHAR (20);
DEFINE mCargo_Pago_Remesa 	MONEY;
DEFINE mSaldo_Cuenta_WU 	MONEY;
DEFINE cFolio_Operacion 	CHAR (16);
DEFINE cClave_Envio 		CHAR (11);
DEFINE cSucursal 			CHAR (4);
DEFINE cCajero 				CHAR (8);
DEFINE cImportePago 		CHAR (20);
DEFINE iSqlerr 				INTEGER ;
DEFINE cTransacc_Suc		CHAR(4);
DEFINE cTransacc_Efe		CHAR(4);
DEFINE cTransacc_CargCta	CHAR(4);
DEFINE cCategoria 			CHAR(2);
DEFINE cConvenio 			CHAR(3);

/* INICIALIZACION DE VARIABLES */
LET dDia = 					CURRENT;
LET cForma_Pago 			= '';
LET mCargo_Pago_Remesa 		= 0.0;
LET mSaldo_Cuenta_WU 		= 0.0;
LET cFolio_Operacion		= '';
LET cClave_Envio 			= '';
LET cSucursal 				= '';
LET cCajero 				= '';
LET cImportePago 			= '';
LET iSqlerr 				= 0 ;
LET cTransacc_Suc 			= '';
LET cTransacc_Efe			='';
LET cTransacc_CargCta		='';
LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);

BEGIN

	ON EXCEPTION SET iSqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

		RETURN '01/01/1900', iSqlerr, 0.0, 0.0, '', '', '', '', '';

	END EXCEPTION;

	IF ((pFechaIni IS NULL) OR (pFechaFin IS NULL)) OR (cCategoria = "" OR cCategoria IS NULL) OR (cConvenio = "" OR cConvenio IS NULL) THEN
		RETURN '01/01/1900', '', 0.0, 0.0, '', '', '', '', '';

	ELSE
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--SET DEBUG FILE TO "/respaldosbd/eduardo/sp_reportewu_conciliacion.out";
		--TRACE ON;		 
		
		SELECT trans_suc_efectivo,trans_cen_efectivo_cliente, trans_cen_cargo_cliente
		INTO cTransacc_Suc,cTransacc_Efe,cTransacc_CargCta
		FROM bdisac:"informix".sac_convenios 
		WHERE numcategoria= cCategoria
		AND numconvenio= cConvenio;
		
		FOREACH 
			SELECT
            {+INDEX(bdicheq:"informix".sc_movhis  idx_movhisnew6)}
			MOV.fech_alt AS Dia,
			(DECODE(SAC_Movhis.forma_pago, '1', 'EFECTIVO', DECODE(SAC_Movhis.forma_pago, '2', 'CARGO EN CUENTA', DECODE(SAC_Movhis.forma_pago, '3', 'MIXTO', DECODE(SAC_Movhis.forma_pago, '4', 'ABONO EN CUENTA', SAC_Movhis.forma_pago))))),
			SAC_Movhis.importe_pago,
			MOV.sdo_cuenta,
			SAC_Movhis.folio_suc,
			SAC_Movhis.referencia1,
			MOV.sucursal,
			MOV.usuario,
			(SELECT {+INDEX(bdisac:"informix".sac_movimientoshistorial  idxsac_movhisfe)} SUM(importe_pago) FROM bdisac:"informix".sac_movimientoshistorial WHERE fecha_pago BETWEEN pFechaIni AND pFechaFin
			AND status_cancelado = 'N'
			AND flag_confirmacion_central = '1' 
			AND flag_confirmacion_sucursal = '1'
			AND transacc_suc = cTransacc_Suc ) 
            INTO dDia, cForma_Pago, mCargo_Pago_Remesa,  mSaldo_Cuenta_WU, cFolio_Operacion, cClave_Envio, cSucursal, cCajero, cImportePago
			FROM bdicheq:"informix".sc_movhis  MOV, bdisac:"informix".sac_movimientoshistorial SAC_Movhis
			WHERE MOV.fech_alt BETWEEN pFechaIni AND pFechaFin
			AND MOV.folio_suc = SAC_Movhis.folio_suc
			AND MOV.transacc IN (cTransacc_Efe, cTransacc_CargCta)
            AND SAC_Movhis.numcategoria = cCategoria 
			AND SAC_Movhis.numconvenio = cConvenio 
			AND SAC_Movhis.status_cancelado = 'N'
			AND (SAC_Movhis.forma_pago = '1' OR SAC_Movhis.forma_pago = '4')
            			
			UNION ALL
						
			SELECT
            {+INDEX(bdicheq:"informix".sc_movhis_old  idx_movhisnew6_old)}
			MOV.fech_alt AS Dia,
			(DECODE(SAC_Movhis.forma_pago, '1', 'EFECTIVO', DECODE(SAC_Movhis.forma_pago, '2', 'CARGO EN CUENTA', DECODE(SAC_Movhis.forma_pago, '3', 'MIXTO', DECODE(SAC_Movhis.forma_pago, '4', 'ABONO EN CUENTA', SAC_Movhis.forma_pago))))),
			SAC_Movhis.importe_pago ,
			MOV.sdo_cuenta ,
			SAC_Movhis.folio_suc,
			SAC_Movhis.referencia1 ,
			MOV.sucursal ,
			MOV.usuario ,
			(SELECT {+INDEX(bdisac:"informix".sac_movimientoshistorial  idxsac_movhisfe)} SUM(importe_pago) FROM bdisac:"informix".sac_movimientoshistorial WHERE fecha_pago BETWEEN pFechaIni AND pFechaFin
			AND status_cancelado = 'N'
			AND flag_confirmacion_central = '1' 
			AND flag_confirmacion_sucursal = '1'
			AND transacc_suc = cTransacc_Suc) 
            FROM bdicheq:"informix".sc_movhis_old  MOV, bdisac:"informix".sac_movimientoshistorial SAC_Movhis
			WHERE MOV.fech_alt BETWEEN pFechaIni AND pFechaFin
			AND MOV.folio_suc = SAC_Movhis.folio_suc
			AND MOV.transacc IN (cTransacc_Efe,cTransacc_CargCta)  
            AND SAC_Movhis.numcategoria = cCategoria 
			AND SAC_Movhis.numconvenio = cConvenio
			AND SAC_Movhis.status_cancelado = 'N'
			AND (SAC_Movhis.forma_pago = '1' OR SAC_Movhis.forma_pago = '4')
			ORDER BY Dia
			RETURN dDia, cForma_Pago, mCargo_Pago_Remesa,  mSaldo_Cuenta_WU, cFolio_Operacion, cClave_Envio, cSucursal, cCajero, cImportePago WITH RESUME;
		END FOREACH;
		
	END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR: Eduardo Lopez Cuevas',
'Descripcion: GENERA REPORTE DE CONCILIACION DE WU.',
'Fecha: 2013/07/03',
'Version: 20130703.1300',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_reportewu_mensual ( pPeriodo DATE,pConvenio CHAR(5))

RETURNING INTEGER AS Dia, INTEGER AS Tot_Operaciones, MONEY AS Monto;

/*  DEFINICION DE VARIABLES */
DEFINE dFechaIni DATE;
DEFINE dFechaFin DATE;
DEFINE iDia INTEGER;
DEFINE iTot_Operaciones INTEGER;
DEFINE mMonto MONEY;
DEFINE iSqlerr INTEGER ;
DEFINE cCategoria CHAR(2);
DEFINE cConvenio CHAR(3);

/* INICIALIZACION DE VARIABLES */
LET dFechaIni = CURRENT;
LET dFechaFin = CURRENT;
LET iDia = 0;
LET iTot_Operaciones = 0;
LET mMonto = 0.0;
LET iSqlerr = 0 ;
LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);

BEGIN

	ON EXCEPTION SET iSqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

		RETURN iSqlerr, 0, 0.0 ;

	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/respaldosbd/eduardo/sp_reportewu_mensual.out";
	--TRACE ON;

	IF (pPeriodo  IS NULL) OR (cCategoria = "" OR cCategoria IS NULL) OR (cConvenio = "" OR cConvenio IS NULL) THEN
		RETURN 0,0,0.0;
	ELSE

		LET dFechaIni = MONTH(pPeriodo) || '/01/' || YEAR(pPeriodo);
		LET dFechaFin = dFechaIni + INTERVAL (1) MONTH TO MONTH;

		WHILE (dFechaIni < dFechaFin)

			SELECT
			DAY(dFechaIni), NVL(COUNT(importe_pago), 0), NVL(SUM(Importe_Pago),0)
			INTO iDia, iTot_Operaciones, mMonto
			FROM bdisac:"informix".sac_movimientoshistorial
			WHERE fecha_pago = dFechaIni
			AND numcategoria = cCategoria 
			AND numconvenio = cConvenio
			AND status_cancelado = 'N';

			RETURN iDia, iTot_Operaciones, mMonto WITH RESUME;

			LET dFechaIni = dFechaIni + INTERVAL (1) DAY TO DAY;

		END WHILE;


	END IF;

END

END PROCEDURE
DOCUMENT
'AUTOR: Eduardo Lopez Cuevas',
'Descripcion: GENERA REPORTE DE WU MENSUAL.',
'Fecha: 2013/07/03',
'Version: 20130703.1130',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_wu_comparacaracteres(pNombreBan CHAR(40), pNombreWU CHAR(40))
    --DATOS A REGRESAR---
    RETURNING
    CHAR(5),   -- Codigo de Retorno
    CHAR(2); -- Porcentaje

    --DEFINICION DE VARIABLES--
    DEFINE sql_err      INT;
    DEFINE cCodRet      CHAR(5);
	DEFINE i            INTEGER;
	DEFINE iContador    INTEGER;
	DEFINE iCoicidencia INTEGER;
	DEFINE cCarBan      CHAR(1);
	DEFINE cCarWU      CHAR(1);
    
    --INICIALIZACION DE VARIABLES--
    LET sql_err = 0;
    LET cCodRet =   '00000';
    LET i = 0;
	LET iContador = 1;
	LET iCoicidencia = 0;
	LET cCarBan = '';
	LET cCarWU = '';
	
   -- SET DEBUG FILE TO "/respaldosbd/mario/sp_sac_wu_comparacaracteres.out";
    --TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet, iCoicidencia;
        END IF;
    END EXCEPTION;

	--VALIDAR PRIMER NOMBRE CARACTER POR CARACTER
	
	 FOR i = 1 TO LENGTH(pNombreBan)
		LET cCarBan = UPPER(SUBSTRING(pNombreBan FROM i FOR 1));
		LET cCarWU = UPPER(SUBSTRING(pNombreWU FROM iContador FOR 1));
		
		IF cCarBan IN ('á','Á') THEN
			LET cCarBan = 'A';
		ELIF cCarBan IN ('é','É') THEN
			LET cCarBan = 'E';
		ELIF cCarBan IN ('í','Í') THEN
			LET cCarBan = 'I';                      
		ELIF cCarBan IN ('ó','Ó') THEN  
		    LET cCarBan = 'O';                   
		ELIF cCarBan IN ('ú','Ú') THEN
		    LET cCarBan = 'U';
		END IF;
		
		IF cCarWU IN ('á','Á') THEN
			LET cCarWU = 'A';
		ELIF cCarWU IN ('é','É') THEN
			LET cCarWU = 'E';
		ELIF cCarWU IN ('í','Í') THEN
			LET cCarWU = 'I';
		ELIF cCarWU IN ('ó','Ó') THEN
		    LET cCarWU = 'O';
		ELIF cCarWU IN ('ú','Ú') THEN
		    LET cCarWU = 'U';
		END IF;
		
		IF cCarBan = cCarWU THEN
			LET iCoicidencia = iCoicidencia + 1;
			LET iContador =  iContador + 1;
		ELSE
		    LET cCarWU = UPPER(SUBSTRING(pNombreWU FROM iContador + 1 FOR 1));
			
			IF cCarWU IN ('á','Á') THEN
				LET cCarWU = 'A';
			ELIF cCarWU IN ('é','É') THEN
				LET cCarWU = 'E';
			ELIF cCarWU IN ('í','Í') THEN
				LET cCarWU = 'I';
			ELIF cCarWU IN ('ó','Ó') THEN
				LET cCarWU = 'O';
			ELIF cCarWU IN ('ú','Ú') THEN
				LET cCarWU = 'U';
			END IF;
			
			IF cCarBan = cCarWU THEN
			    LET iCoicidencia = iCoicidencia + 1;
				LET iContador = iContador + 2;
			ELSE 	
				LET iContador = iContador + 1;
     		END IF;
			
		END IF;
		--EXIT FOR;
	END FOR
	
    RETURN cCodRet, iCoicidencia;
END
END PROCEDURE
DOCUMENT
'Compara el nombre capturado en Bancoppel contra el que envía wu con desfasamiento en wu',
'para obtener el número de coincidencias',
'AUTOR :Mario Gallardo',
'FECHA : 18/07/2010',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_validamontoremesawu(p_cEmpresa CHAR(3), p_cNombre1 CHAR(40), p_cNombre2 CHAR(40),  p_cApellidoPaterno CHAR(40),p_cApellidoMaterno CHAR(40), p_cFechaNacimiento CHAR(8), p_cFechaHoy CHAR(10), p_cEstado CHAR(2),p_cMontoAPagar CHAR(20))

RETURNING CHAR(5) AS cod_ret;


    --Definicion de Variables
    DEFINE	cCodRet      			CHAR(5);
	DEFINE	iSqlErr					INTEGER;
	DEFINE	cFronterizo				CHAR(1);
	DEFINE	cEstadoFronterizo		CHAR(100);
	DEFINE	cMontoMaximo			CHAR(100);
	DEFINE	mMonto					CHAR(10);
	DEFINE	cNumRef					CHAR(10);
	DEFINE	mTotal					MONEY(16,2);
	DEFINE	mSuma					MONEY(16,2);
	
	-- Inicializa variables
    LET cCodRet 					= "00002";
	LET iSqlErr	 					= 0;
	LET cFronterizo					= "0";
	LET	cEstadoFronterizo			= "";
	LET	cMontoMaximo				= "";
	LET	mMonto						= "";
	LET	cNumRef						= "";
	LET	mTotal						= 0.00;
	LET	mSuma						= 0.00;
	
	--SET DEBUG FILE TO '/respaldosbd/christian/sp_validamontoremesawu.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		IF NVL(p_cEmpresa,"") <> "" AND NVL(p_cNombre1,"") <> "" AND NVL(p_cApellidoPaterno,"") <> "" AND NVL(p_cFechaNacimiento,"") <> "" AND NVL(p_cFechaHoy,"") <> "" AND NVL(p_cEstado,"") <> "" AND NVL(p_cMontoAPagar,"") <> "" THEN
			
						
			SELECT Valor
			INTO cEstadoFronterizo
			FROM bdisac:"informix".sac_param
			WHERE empresa = p_cEmpresa
			AND cod_param = 87084;
			
			IF TRIM(cEstadoFronterizo) LIKE '%' || p_cEstado || '%' THEN
				LET cFronterizo = "1";
			END IF;
						
			IF cFronterizo = "1" THEN
				SELECT Valor
				INTO cMontoMaximo
				FROM bdisac:"informix".sac_param
				WHERE empresa = p_cEmpresa
				AND cod_param = 87082;
				
			ELSE
				SELECT Valor
				INTO cMontoMaximo
				FROM bdisac:"informix".sac_param
				WHERE empresa = p_cEmpresa
				AND cod_param = 87083;
			END IF;
			
			FOREACH
			
				SELECT monto_destino, mtcn
				INTO mMonto , cNumRef
				FROM bdisac:"informix".sac_wu_pay
				WHERE benef_nombre1 = p_cNombre1
				AND benef_nombre2 = p_cNombre2
				AND benef_appaterno = p_cApellidoPaterno
				AND benef_apmaterno = p_cApellidoMaterno
				AND benef_fecha_nac = p_cFechaNacimiento
				AND  SUBSTRING(fecha_hora_rp FROM 1 FOR 10) = p_cFechaHoy
				AND conf_pago = 'P'
				
				IF NVL(cNumRef,"") <> "" THEN
					IF EXISTS(SELECT referencia1
						FROM bdisac:"informix".sac_movimientos
						WHERE referencia1 = cNumRef
						AND status_cancelado <> 'S') THEN
						
						LET mSuma = mSuma + NVL(mMonto,0);
					END IF;
				ELSE
					LET cCodRet = "00003";
				END IF;
			END FOREACH
			
			-- valida si hay datos vacios en la consulta
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			   LET cCodRet = "00000"; 
		    END IF;	
			
		ELSE
		   RETURN cCodRet;
		END IF;	
		
		LET mTotal = mSuma + CAST(p_cMontoAPagar AS MONEY(14,2));
			
		IF mTotal > CAST(cMontoMaximo AS MONEY(14,2)) THEN
			LET cCodRet = "00001";
		ELSE
			LET cCodRet = "00000";
		END IF;
		RETURN cCodRet;
	END;
END PROCEDURE
 DOCUMENT
 'AUTOR: Christian Echavarria',
 'DESCRIPCION: valida si a un Cliente se le permite Cobrar una envio WU dependiendo de un monto maximo por dia.',
 'FECHA: 25/Jul/2013',
 'BD:   bdisac';

CREATE PROCEDURE "informix".sp_altascambioscentral(cNumcategoria CHAR(2), cNumconvenio CHAR(3), cNomconvenio CHAR(40), dFechaapertura DATE, dFechaclausura DATE,
                    cStatusconvenio CHAR(1), cTipo_Referencia CHAR(1), cNomlegalempresa CHAR(40), cRfcempresa CHAR(13), cNomcomercialempresa CHAR(40),
                    cDireccionempresa CHAR(80), cEstado CHAR(2), cCiudad CHAR(3), cCodpostal CHAR(5), cNumtelcorporativo CHAR(10), cNumfaxcorporativo CHAR(10),
                    cNomcontacto1 CHAR(40), cNumtelcontacto1 CHAR(10), cNumextcontacto1 CHAR(7), cEmailcontacto1 CHAR(40), cNomcontacto2 CHAR(40),
                    cNumtelcontacto2 CHAR(10), cNumextcontacto2 CHAR(7), cEmailcontacto2 CHAR(40), cNomcontacto3 CHAR(40), cNumtelcontacto3 CHAR(10),
                    cNumextcontacto3 CHAR(7), cEmailcontacto3 CHAR(40), cNumcuentaclabe CHAR(18), cTipopago CHAR(1), iFrecuenciapago INT, cFlgarchnotificacion CHAR(1),
                    iFrecnotificacion INT, cFlgporccomtrans_conv CHAR(1), dePorc_com_trans_conv DECIMAL, cFlgporccomtotal_conv CHAR(1),
                    dePorc_com_total_conv DECIMAL, cFlgimpcomtrans_conv CHAR(1), mImp_com_trans_conv MONEY(16,2), cFlgimpcomtotal_conv CHAR(1),
                    deImp_com_total_conv MONEY(16,2), cFlgivaincluido_conv CHAR(1), deIva_Convenio INT, cFlgPorcComTrans_Cte CHAR(1), dePorc_com_trans_cte DECIMAL,
                    cFlgImpComTrans_Cte CHAR(1), mImp_com_trans_cte MONEY(16,2), cFlg_Ref1 CHAR(1), iLongitudRef1  INT, cFlgcalculodv_ref1 CHAR(1), cNomrutinadv_ref1  CHAR(30),
                    cFlg_Ref2 CHAR(1), iLongitudRef2 INT, cFlgcalculodv_ref2 CHAR(1), cNomrutinadv_ref2 CHAR(30), cFlgreporte CHAR(1), cNomreporte CHAR(30), cUsuario CHAR(8))
    -- DATOS A REGRESAR
    RETURNING CHAR(5), CHAR(2), CHAR(3);  -- Codigo de Retorno
    -- DEFINICION DE VARIABLES
    DEFINE cCodRet              CHAR(5);
    DEFINE cFechaHoy            DATE;
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(200);
    DEFINE dFecha_ultimo_pago   DATE;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET iIsamErr = 0;
    LET cInfoErr = "";
    LET dFecha_ultimo_pago = '01-01-1900';

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        ROLLBACK WORK;
                        EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_AltasCambiosCentral");
                        RETURN cCodRet, '', '';
                END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO '/respaldosbd/eduardo/sp_altascambioscentral.out';
		--TRACE ON;	
		
		SET ISOLATION TO DIRTY READ;

        BEGIN WORK;
            SELECT fecha_hoy INTO cFechaHoy FROM bdisac:"informix".sac_fechas;

            IF EXISTS (SELECT {+INDEX (bdisac:"informix".sac_convenios 103_4)} * FROM bdisac:"informix".sac_convenios WHERE  numcategoria = cNumcategoria AND numconvenio = cNumconvenio) THEN
                UPDATE {+INDEX (bdisac:"informix".sac_convenios 103_4)} sac_convenios
                SET nomconvenio = cNomconvenio, fechaapertura = dFechaapertura, fechaclausura = dFechaclausura, statusconvenio = cStatusconvenio,
                    tipo_referencia = cTipo_Referencia, nomlegalempresa = cNomlegalempresa, rfcempresa = cRfcempresa, nomcomercialempresa = cNomcomercialempresa,
                    direccionempresa = cDireccionempresa, ciudad = cCiudad, estado = cEstado, codpostal = cCodpostal, numtelcorporativo = cNumtelcorporativo,
                    numfaxcorporativo = cNumfaxcorporativo, nomcontacto1 = cNomcontacto1, numtelcontacto1 = cNumtelcontacto1, numextcontacto1 = cNumextcontacto1,
                    emailcontacto1 = cEmailcontacto1, nomcontacto2 = cNomcontacto2, numtelcontacto2 = cNumtelcontacto2, numextcontacto2 = cNumextcontacto2,
                    emailcontacto2 = cEmailcontacto2, nomcontacto3 = cNomcontacto3, numtelcontacto3 = cNumtelcontacto3, numextcontacto3 = cNumextcontacto3,
                    emailcontacto3 = cEmailcontacto3, numcuentaclabe = cNumcuentaclabe, tipopago = cTipopago, frecuenciapago = iFrecuenciapago, flgarchnotificacion = cFlgarchnotificacion,
                    frecnotificacion = iFrecnotificacion, flgporccomtrans_conv =cFlgporccomtrans_conv, porc_com_trans_conv = dePorc_com_trans_conv,
                    flgporccomtotal_conv = cFlgporccomtotal_conv, porc_com_total_conv = dePorc_com_total_conv, flgimpcomtrans_conv = cFlgimpcomtrans_conv,
                    imp_com_trans_conv = mImp_com_trans_conv, flgimpcomtotal_conv = cFlgimpcomtotal_conv, imp_com_total_conv = deImp_com_total_conv,
                    flgivaincluido_conv = cFlgivaincluido_conv, iva_convenio = deIva_Convenio, flgporccomtrans_cte = cFlgPorcComTrans_cte, porc_com_trans_cte = dePorc_com_trans_cte,
                    flgimpcomtrans_cte = cFlgImpComTrans_cte, imp_com_trans_cte = mImp_com_trans_cte, flg_ref1 = cFlg_Ref1, longitud_ref1 = iLongitudRef1,
                    flgcalculodv_ref1 = cFlgcalculodv_ref1, nomrutinadv_ref1 = cNomrutinadv_ref1, flg_ref2 = cFlg_Ref2, longitud_ref2  = iLongitudRef2,
                    flgcalculodv_ref2 = cFlgcalculodv_ref2, nomrutinadv_ref2 = cNomrutinadv_ref2, flgreporte = cFlgreporte, nomreporte  = cNomreporte,
                    fecha_ultimo_pago = dFecha_ultimo_pago, usuario_actualiza = cUsuario, fechaactualizacion = cFechaHoy
                WHERE numcategoria = cNumcategoria
                AND numconvenio = cNumconvenio;
            ELSE

                SELECT {+INDEX (bdisac:"informix".sac_convenios 103_7)} MAX(numconvenio)
                INTO cNumconvenio
                FROM bdisac:"informix".sac_convenios
                WHERE numcategoria = cNumcategoria;

                IF cNumConvenio IS NULL THEN
                    LET cNumConvenio = '001';
                ELSE
                    LET cNumconvenio  = LPAD(CAST(cNumconvenio AS INTEGER) + 1, 3, '0');
                END IF;

                INSERT INTO bdisac:"informix".sac_convenios (numcategoria, numconvenio, nomconvenio, fechaapertura, fechaclausura, fechaalta, statusconvenio,	tipo_referencia,
	                        nomlegalempresa, rfcempresa,nomcomercialempresa, direccionempresa, ciudad, estado, codpostal, numtelcorporativo, numfaxcorporativo, nomcontacto1, 
							numtelcontacto1, numextcontacto1, emailcontacto1, nomcontacto2, numtelcontacto2, numextcontacto2, emailcontacto2, nomcontacto3, 
							numtelcontacto3, numextcontacto3, emailcontacto3, numcuentaclabe, tipopago, frecuenciapago, flgarchnotificacion, frecnotificacion, 
							flgporccomtrans_conv, porc_com_trans_conv, flgporccomtotal_conv, porc_com_total_conv, flgimpcomtrans_conv, imp_com_trans_conv,	
							flgimpcomtotal_conv, imp_com_total_conv, flgivaincluido_conv, iva_convenio, flgporccomtrans_cte, porc_com_trans_cte, 
							flgimpcomtrans_cte, imp_com_trans_cte, flg_ref1, longitud_ref1, flgcalculodv_ref1, nomrutinadv_ref1, flg_ref2, longitud_ref2, 
							flgcalculodv_ref2, nomrutinadv_ref2, flgreporte, nomreporte, fecha_ultimo_pago, usuario_alta, usuario_actualiza, fechaactualizacion) 
                    VALUES( cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, cFechaHoy, cStatusconvenio, cTipo_Referencia, 
					    	cNomlegalempresa, cRfcempresa, cNomcomercialempresa, cDireccionempresa, cCiudad, cEstado, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1,
                            cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2, cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3,
                            cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago, cFlgarchnotificacion, iFrecnotificacion,
                            cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
                            cFlgimpcomtotal_conv, deImp_com_total_conv, cFlgivaincluido_conv, deIva_Convenio, cFlgPorcComTrans_cte, dePorc_com_trans_cte,
                            cFlgImpComTrans_cte, mImp_com_trans_cte, cFlg_Ref1, iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2,
                            cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte, dFecha_ultimo_pago, cUsuario, cUsuario, cFechaHoy);

                IF cFlgarchnotificacion = '1' THEN 
					INSERT INTO bdisac:"informix".sac_controlarchivoscobranza (numcategoria, numconvenio, nom_rutina, fecha_ultimo_archivo)
					VALUES (cNumcategoria, cNumconvenio,'', dFecha_ultimo_pago);
				END IF;					
            END IF;
        COMMIT WORK;
        RETURN cCodret, cNumcategoria, cNumconvenio;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Hector Bojorquez',
'DESCRIPCION: Se encarga de insertar o actualizar el registro de un convenio en la tabla',
'             bdisac:sac_convenios de Central',
'EJECUTADO O LLAMADO POR: alcsac.exe, cacsac.exe del sistema de administracion de convenios',
'FECHA : Agosto de 2008',
'AUTOR MODIFICACION: Dulce Ramirez',
'DESCRIPCION MODIFICACION: Se especifican los campos de la tabla sac_convenios en el insert,',
'FECHA : Septiembre de 2010',
'VERSION: 20100920',
'BD    : bdisac',
'MODIFICO: Eduardo Lopez Cuevas',
'DESCRIPCION Se agrega condicion para que solo inserte en la tabla sac_controlarchivoscobranza cuando cFlgarchnotificacion = 1 ',
'y se agregan reglan de informix',
'VERSION: 20130712.1455',
'FECHA: 2013/07/12',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_intcajero_recicla
	(cClave CHAR, cTipomovimiento CHAR, iSucursal SMALLINT, iCiudad SMALLINT, iCliente INTEGER,
	iRecibo INTEGER, iFactura INTEGER, iImporte INTEGER, cEjercicio CHAR, iEfectuo INTEGER,
	cMovtoSeguro CHAR, iCantidadMeses INTEGER, iCantidadSeguros INTEGER, iFolioSeguro INTEGER,
	cSexo CHAR, dFechaVencimiento DATE, tipo_ejecc INTEGER)
RETURNING CHAR(5);

    DEFINE cCodRet     CHAR(5);
    DEFINE iSqlErr     INTEGER;
    DEFINE iIsamErr    INTEGER;
	DEFINE iCaja       INTEGER;
    DEFINE dFecha_Hoy  DATE;
    DEFINE cInfoErr    CHAR(100);

--	Datos para tabla bdisac:sac_movimientos:
	DEFINE cSucursal						CHAR (4);
	DEFINE cCategoria						CHAR (2);
	DEFINE cConvenio						CHAR (5);
	DEFINE cReferencia1						CHAR (20);
	DEFINE cReferencia2						CHAR (20);
	DEFINE cFolio_suc						CHAR (16);
	DEFINE cFormaPago						CHAR (1);
	DEFINE deImportePago					MONEY;
	DEFINE deImpComisionConvenio			MONEY;
	DEFINE deIvaComisionConvenio			MONEY;
	DEFINE deImpComisionCliente				MONEY;
	DEFINE deIvaComisionCliente				MONEY;
	DEFINE cTransacc_suc					CHAR (4);
	DEFINE cTransacc_suc_mov				CHAR (4);
	DEFINE cCuentaCargo						CHAR (12);
	DEFINE cusuario							CHAR (8);
	DEFINE choraejec						DATETIME YEAR to FRACTION(5);
	DEFINE chhejec							CHAR (2);
	DEFINE cmmejec							CHAR (2);
	DEFINE cssejec							CHAR (2);
	DEFINE cmsejec							CHAR (2);
	DEFINE cDescripcion						CHAR (200);
	DEFINE Folio_Confirma					CHAR (16);
	DEFINE cEmpresa							CHAR (3);
	DEFINE ccuenta      					CHAR(20);
	DEFINE idocto					        INTEGER;
	DEFINE mmto_tot     					MONEY;
	DEFINE mmto_sbc     					MONEY;
	DEFINE mmto_rem     					MONEY;
	DEFINE sdias_ret					    SMALLINT;
	DEFINE cdivisa						    CHAR(2);
	DEFINE creferencia    					CHAR(40);
	DEFINE cnum_tarjeta 					CHAR(16);
	DEFINE cusuautoriza 					CHAR(8);
--	2013.09.12-I
	DEFINE ctiporev							CHAR (1);
	DEFINE CodRetRev						CHAR (5);
	DEFINE cCodRetAbo						CHAR (5);
	DEFINE transcCentrAbCppl				CHAR (4);
	DEFINE user_abcppl						CHAR (8);
--	2013.09.12-F

--	SET DEBUG FILE TO '/informix/tmp/sp_intcajero_recicla.out';
--	TRACE ON;

    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET iIsamErr = '0';
    LET cInfoErr = 'Ejecucion del proceso exitoso.';
--	Datos para tabla bdisac:sac_movimientos:
	LET cSucursal = LPAD(iSucursal,4,'0');
	LET cCategoria = '01';
	LET cConvenio = '001';
	LET cReferencia1 = iCliente;
	LET cReferencia2 = iRecibo;
	LET cFolio_suc = '';
	LET cFormaPago = '1';
	LET deImportePago = iImporte;
	LET deImpComisionConvenio = 0.00;
	LET deIvaComisionConvenio = 0.00;
	LET deImpComisionCliente = 0.00;
	LET deIvaComisionCliente = 0.00;
	LET cTransacc_suc = '';
	LET cTransacc_suc_mov = '';
	LET cCuentaCargo = '';
	LET cusuario = '';
	LET choraejec = current;
	LET chhejec = substring(choraejec from 12 for 2);
	LET cmmejec = substring(choraejec from 15 for 2);
	LET cssejec = substring(choraejec from 18 for 2);
	LET cmsejec = substring(choraejec from 21 for 2);
	LET cDescripcion = '';
	LET Folio_Confirma = '';
	LET cEmpresa = '';
	LET ccuenta = '';
	LET idocto = 0;
	LET mmto_tot = 0.00;
	LET mmto_sbc = 0.00;
	LET mmto_rem = 0.00;
	LET sdias_ret = 0;
	LET cdivisa = '01';
	LET creferencia = 'Abono Pago Servicio Efectivo';
	LET cnum_tarjeta = '';
	LET cusuautoriza = '';
	--	2013.09.12-I
	LET ctiporev = 'A';
	LET CodRetRev = '000';
	LET cCodRetAbo = '000';
	LET transcCentrAbCppl = '0000';
	LET user_abcppl	= '';
--	2013.09.12-F


	if cClave = '' OR cTipomovimiento = '' OR iSucursal = '' OR iCiudad = '' OR iCliente = '' OR iRecibo = ''
		OR iFactura = '' OR iImporte = ''  OR iEfectuo = '' OR iCantidadMeses = ''
		--OR iCantidadSeguros = '' OR cEjercicio = ''
		OR iFolioSeguro = '' OR cSexo = '' OR dFechaVencimiento is null OR tipo_ejecc = ''
		THEN
			let cCodRet = '01103';
			LET cInfoErr = 'Uno de los parametros de entrada se encuentra vacio, validar.';
			EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (cCodRet, iIsamErr, cInfoErr, "sp_intcajero_recicla");
			RETURN cCodRet;
	end if;

	IF tipo_ejecc > 0 and tipo_ejecc > 2 --	Tipo ejecución inválido.
		then
			LET cCodRet = '01104';
			let cInfoErr = 'Tipo_ejecucion invalido, validar.';
            EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (cCodRet, iIsamErr, cInfoErr, "sp_intcajero_recicla");
            RETURN cCodRet;
	END IF;

	
    SELECT empresa, valor
        INTO cEmpresa,cusuario
    FROM bdisac:sac_param
		where cod_param = '1002';

	select imp_com_total_conv, iva_convenio, imp_com_trans_cte, trans_suc_efectivo,trans_cen_efectivo_cliente,cuenta_prestadora
		into deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, cTransacc_suc,cTransacc_suc_mov,ccuenta
	from bdisac:sac_convenios where numcategoria = cCategoria and numconvenio = cConvenio;

	LET deIvaComisionCliente = deIvaComisionConvenio;
	LET cFolio_suc = cusuario||chhejec||cmmejec||cssejec||cmsejec;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
         IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_intcajero_recicla");
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

	IF tipo_ejecc = 1 --	Grabar Movimiento.	
		THEN	--	Graba movimiento en tabla bdisac:sac_movimientosdetalle (Pagos Coppel)
			IF deImportePago <= 0 then
				LET cCodRet = '01106';
				let cInfoErr = 'Importe menor o igual a 0 , validar.';
				EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (cCodRet, iIsamErr, cInfoErr, "sp_intcajero_recicla");
				RETURN cCodRet;
			END IF;
		
			EXECUTE FUNCTION "informix".sp_grabapagocoppel(cClave, cTipomovimiento, iSucursal, iCiudad, iCliente, iRecibo, iFactura, iImporte,
				cEjercicio, iEfectuo, cMovtoSeguro, iCantidadMeses, iCantidadSeguros, iFolioSeguro, cSexo, dFechaVencimiento) into cCodRet;
			if cCodRet = '00000'	--	Graba movimiento en tabla bdisac:sac_movimientosdetalle (Pagos Coppel)
				then
					EXECUTE FUNCTION "informix".sp_grabapagoservicio(cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, cFormaPago, deImportePago, deImpComisionConvenio,
						deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente, cCuentaCargo, cUsuario, cFolio_suc, cTransacc_suc, current) into cCodRet;
						if cCodRet <> '00000'
							then
								let iSqlErr = cCodRet;
								LET cInfoErr = 'Error en ejecucion del proceso.';
								EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
								RETURN cCodRet;
						end if;
				else
					let iSqlErr = cCodRet;
					LET cInfoErr = 'Error en ejecucion del proceso.';
					EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagocoppel");
					RETURN cCodRet;
			end if;
	END IF;

	IF tipo_ejecc = 2 THEN--	Confirma Movimientos.
		select folio_suc,importe_pago 
          into Folio_Confirma,mmto_tot
		from bdisac:"informix".sac_movimientos
		where id_sucursal = cSucursal
		AND numcategoria = cCategoria
		AND numconvenio = cConvenio
		AND referencia1 = cReferencia1
		AND referencia2 = cReferencia2
        AND folio_suc <> '';

		if Folio_Confirma = '' OR Folio_Confirma IS NULL then
				let iSqlErr = '01105';
				LET cInfoErr = 'No se encontró folio de confirmación.';
			RETURN cCodRet;
        end if;

--	2013.09.12-i	
		select trans_cen_efectivo_cliente 
		into transcCentrAbCppl	
		from bdisac:sac_convenios where numcategoria = '01';
		
		select valor 
		into user_abcppl
		from bdisac:sac_param where cod_param = '1002';
			if (
				select count (*)
				from bdicheq:sc_movdia
				where sucursal = cSucursal
				AND transacc = transcCentrAbCppl
				AND usuario = user_abcppl
				AND folio_suc = Folio_Confirma
				and cancelad <> 'S') = 0
				then
					EXECUTE PROCEDURE bdicheq:abono_ref(cEmpresa,cSucursal,cUsuario,cTransacc_suc_mov,cTransacc_suc,Folio_Confirma,ccuenta,idocto,mmto_tot,mmto_tot,mmto_sbc,
													mmto_rem,sdias_ret,cdivisa,creferencia,cnum_tarjeta,cusuautoriza ) into cCodRetAbo;
					if cCodRetAbo <> '000'
						then
							let cCodRet = cCodRetAbo;
							EXECUTE FUNCTION bdicheq:reversion(cEmpresa, cSucursal, cUsuario, Folio_Confirma, ctiporev) into CodRetRev;
							if CodRetRev <> '000'
								then
									let iSqlErr = CodRetRev;
									LET cInfoErr = 'Error en ejecucion del proceso bdicheq:reversion';
									let cCodRet = CodRetRev;
									EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (iSqlErr, iIsamErr, cInfoErr, "bdicheq:reversion");
									RETURN cCodRet;
								else
								let iSqlErr = cCodRetAbo;
								LET cInfoErr = 'Error en ejecucion del abono a la cuenta.';
								let CodRetRev = cCodRetAbo;
								let cCodRet = cCodRetAbo;
								EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (iSqlErr, iIsamErr, cInfoErr, "bdicheq:abono_ref");
								RETURN cCodRet;
							end if;
						else
							EXECUTE FUNCTION "informix".sp_confpagoservicio(cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, Folio_Confirma) into cCodRet, cDescripcion;
							if cCodRet <> '00000' 
								then
									let cCodRet = cCodRetAbo;
									EXECUTE FUNCTION bdicheq:reversion(cEmpresa, cSucursal, cUsuario, Folio_Confirma, ctiporev) into CodRetRev;
									if CodRetRev <> '000'
										then
											let iSqlErr = CodRetRev;
											LET cInfoErr = 'Error en ejecucion del proceso bdicheq:reversion';
											let cCodRet = CodRetRev;
											EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (iSqlErr, iIsamErr, cInfoErr, "bdicheq:reversion");
											RETURN cCodRet;
										else
											let iSqlErr = cCodRetAbo;
											LET cInfoErr = 'Error en ejecucion del proceso.';
											EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_confpagoservicio");
											RETURN cCodRet;
									end if;
								else
									EXECUTE FUNCTION "informix".sp_confpagocoppel(iSucursal, iRecibo) into cCodRet;
									if cCodRet <> '00000' 
										then
											let cCodRet = cCodRetAbo;
											EXECUTE FUNCTION bdicheq:reversion(cEmpresa, cSucursal, cUsuario, Folio_Confirma, ctiporev) into CodRetRev;
											if CodRetRev <> '000'
												then
													let iSqlErr = CodRetRev;
													LET cInfoErr = 'Error en ejecucion del proceso bdicheq:reversion';
													let cCodRet = CodRetRev;
													EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (iSqlErr, iIsamErr, cInfoErr, "bdicheq:reversion");
													RETURN cCodRet;
												else
													let iSqlErr = cCodRet;
													LET cInfoErr = 'Error en ejecucion del proceso.';
													EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_confpagocoppel");
													RETURN cCodRet;
											end if;
									end if;
							end if;
					end if;
				else
					let cCodRet = '00001';
					let iSqlErr = cCodRet;
					LET cInfoErr = 'Deposito abonado en cuenta anteriormente, no puede abonarse de nuevo.';
					EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror (iSqlErr, iIsamErr, cInfoErr, "bdicheq:abono_ref");
					RETURN cCodRet;
			end if;
	end if;
--	2013.09.12-f
RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Fermin Ramos Garcia',
'DESCRIPCION: SP para grabar movimientos en tablas Abonos Coppel Proyecto Cajero-Reciclador',
'EQUIPO DE TRABAJO: Manntto. IV',
'EJECUTADO O LLAMADO POR: Coppel',
'FECHA : 22-Julio-2013',
'VERSION: 20130722.01',
'BD    : bdisac', 
'AUTOR : Fermin Ramos Garcia',
'DESCRIPCION: se agrega la invocación del SP bdicheq:reversion cuando haya error en algún proceso invocado',
'EQUIPO DE TRABAJO: Manntto. IV',
'EJECUTADO O LLAMADO POR: Coppel',
'FECHA : 12-Septiembre-2013',
'VERSION: 20130912.01',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_asignabimestre(pDato CHAR)
	RETURNING CHAR(5) AS CodRetorno, CHAR(10) AS Bimestre;
	
	--Definicion de Variables
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRet 		CHAR(5);
	DEFINE cBimestre 	CHAR(10);
	DEFINE cDiaActual	INTEGER;
	DEFINE cUltimoDia	INTEGER;
	DEFINE cDiaSemana	INTEGER;
	DEFINE cMesActual	INTEGER;
	
	--Inicializacion de Variables
	LET iSqlErr		= 0;
	LET cCodRet		= '00000';
	LET cBimestre 	= '';
	LET cDiaActual	= 0;
	LET cUltimoDia	= 0;
	LET cDiaSemana	= 0;
	LET cMesActual	= 0;
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_asignaBimestre.out";
	--TRACE ON;
	
	BEGIN
		--Control de excepciones
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet, '';
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		
		--Se valida la Cadena reciba por parametro
		IF TRIM(NVL(pDato,'')) = '' THEN
			LET cCodRet = '00001';
		ELSE
			IF pDato = '0' THEN
				LET cUltimoDia = LAST_DAY(TODAY);
				LET cDiaActual = DAY(TODAY);
				LET cDiaSemana = WEEKDAY(TODAY);
				LET cMesActual = MONTH(TODAY);
				
				IF cMesActual = 1 OR cMesActual = 2 THEN
					IF (cDiaActual = cUltimoDia) AND (cDiaSemana >= 5) THEN
						LET cBimestre = "02 - 06";
					ELSE
						LET cBimestre = "01 - 06";
					END IF;
				ELIF cMesActual = 3 OR cMesActual = 4 THEN
					IF (cDiaActual = cUltimoDia) AND (cDiaSemana >= 5) THEN
						LET cBimestre = "03 - 06";
					ELSE
						LET cBimestre = "02 - 06";
					END IF;
				ELIF cMesActual = 5 OR cMesActual = 6 THEN
					IF (cDiaActual = cUltimoDia) AND (cDiaSemana >= 5) THEN
						LET cBimestre = "04 - 06";
					ELSE
						LET cBimestre = "03 - 06";
					END IF;
				ELIF cMesActual = 7 OR cMesActual = 8 THEN
					IF (cDiaActual = cUltimoDia) AND (cDiaSemana >= 5) THEN
						LET cBimestre = "05 - 06";
					ELSE
						LET cBimestre = "04 - 06";
					END IF;
				ELIF cMesActual = 9 OR cMesActual = 10 THEN
					IF (cDiaActual = cUltimoDia) AND (cDiaSemana >= 5) THEN
						LET cBimestre = "06 - 06";
					ELSE
						LET cBimestre = "05 - 06";
					END IF;
				ELIF cMesActual = 11 OR cMesActual = 12 THEN
					IF (cDiaActual = cUltimoDia) AND (cDiaSemana >= 5) THEN
						LET cBimestre = "06 - 06";
					ELSE
						LET cBimestre = "06 - 06";
					END IF;
				END IF;
			ELIF pDato = '1' OR pDato = '2' OR pDato = '3' OR pDato = '4' OR pDato = '5' OR pDato = '6' THEN
				LET cBimestre = "0" || pDato;
			ELSE
				LET cBimestre = "";
				LET cCodRet = '00002';
			END IF;
		END IF;
		
		RETURN cCodRet, cBimestre;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para obtener un Bimestre en base a un valor obtenido de la Linea de Captura Base para pago de Impuesto',
'				Predial, en pagos de servicios GDF.',
'AUTOR : Manuel Ramos Figueroa',
'FECHA : 06 de Mayo 2013',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_consulta_centro_servicio_bpi(pId CHAR(1))
-- DESCRIPCION: CONSULTA PERIODO Y DESCRIPCION
-- AUTOR: ING. CRUZ
-- FECHA: 08-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(50)  AS Descripcion;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cDescripcion CHAR(50);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cDescripcion =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consulta_centro_servicio_bpi.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cDescripcion;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pId,'')) = '' THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT descripcion
	INTO cDescripcion
	FROM bdisac:"informix".sac_catcentrosserviciogdf
	WHERE id = pId;
	
	IF (cDescripcion is NULL) OR (TRIM(cDescripcion)=='') THEN
		LET cCodRet = '00001';
		--EL CENTRO DE SERVICIO NO SE ENCONTRO EN EL CATALOGO O NO TIENE DESCRIPCION
	END IF;
	
	RETURN cCodRet, cDescripcion;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 08-05-2013",
"Descripcion: Consulta el campo descripcion del catalogo centros de servicio.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_consulta_holograma_gdf_bpi(pId CHAR(4))
-- DESCRIPCION: CONSULTA TIPO DE HOLOGRAMA
-- AUTOR: ING. CRUZ
-- FECHA: 13-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(300)  AS Tramite;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cTipoHolograma CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cTipoHolograma =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consulta_holograma_gdf_bpi.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cTipoHolograma;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pId,'')) = '' THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT tipo
	INTO cTipoHolograma
	FROM bdisac:"informix".sac_cattiposhologramagdf
	WHERE id = TRIM(pId);
	
	IF (cTipoHolograma is NULL) OR (TRIM(cTipoHolograma)=='') THEN
		LET cCodRet = '00001';
		--LA DECLARACION NO SE ENCONTRO EN EL CATALOGO O NO TIENE DESCRIPCION
	END IF;
	
	RETURN cCodRet, cTipoHolograma;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 13-05-2013",
"Descripcion: Consulta el tipo de holograma.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_consulta_marca_gdf(pClave CHAR(2))
-- DESCRIPCION: CONSULTA EL CATALOGO DE MARCAS
-- AUTOR: ING. CRUZ
-- FECHA: 14-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(300)  AS Descripcion;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cMarca CHAR(50);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cMarca =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consulta_marca_gdf.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cMarca;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;
	
	IF TRIM(NVL(pClave,'')) = '' OR pClave::INT = 0 THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT marca
	INTO  cMarca
	FROM bdisac:"informix".sac_catmarcasgdf
	WHERE clave = pClave;
	
	RETURN cCodRet, cMarca;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 14-05-2013",
"Descripcion: Consulta el catalogo de marcas.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_consulta_periodo_lic_gdf_bpi(pClave CHAR(4))
-- DESCRIPCION: CONSULTA TIPO DE HOLOGRAMA
-- AUTOR: ING. CRUZ
-- FECHA: 13-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(300)  AS Tramite;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cPeriodoLic CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cPeriodoLic =''; 

--SET DEBUG FILE TO "/home/solserBD/sp_consulta_periodo_lic_gdf_bpi.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cPeriodoLic;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pClave,'')) = '' THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT tipo
	INTO cPeriodoLic
	FROM bdisac:"informix".sac_periodoslicenciagdf
	WHERE clave = TRIM(pClave);
	
	IF (cPeriodoLic is NULL) OR (TRIM(cPeriodoLic)=='') THEN
		LET cCodRet = '00001';
		--LA DECLARACION NO SE ENCONTRO EN EL CATALOGO O NO TIENE DESCRIPCION
	END IF;
	
	RETURN cCodRet, cPeriodoLic;	
END
END PROCEDURE

DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 13-05-2013",
"Descripcion: Consulta el periodo de la licencia.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_consulta_tipo_impuesto_gdf_bpi(pId CHAR(4))
-- DESCRIPCION: CONSULTA IMPUESTO
-- AUTOR: ING. CRUZ
-- FECHA: 10-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(300)  AS Tramite;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cImpuesto CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cImpuesto =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consulta_tipo_impuesto_gdf_bpi.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cImpuesto;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pId,'')) = '' THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT impuesto
	INTO cImpuesto
	FROM bdisac:"informix".sac_cattipoimpuestogdf
	WHERE tipo = TRIM(pId);
	
	IF (cImpuesto is NULL) OR (TRIM(cImpuesto)=='') THEN
		LET cCodRet = '00001';
		--EL TRAMITE NO SE ENCONTRO EN EL CATALOGO O NO TIENE DESCRIPCION
	END IF;
	
	RETURN cCodRet, cImpuesto;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 10-05-2013",
"Descripcion: Consulta el campo impuesto del catalogo de impuestos.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_consulta_tramite_gdf_bpi(pId CHAR(4))
-- DESCRIPCION: CONSULTA TRAMITE
-- AUTOR: ING. CRUZ
-- FECHA: 10-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(300)  AS Tramite;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cTramite CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cTramite =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consulta_tramite_gdf_bpi.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cTramite;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pId,'')) = '' THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT tramite
	INTO cTramite
	FROM bdisac:"informix".sac_cattipotramitesgdf
	WHERE id = pId;
	
	IF (cTramite is NULL) OR (TRIM(cTramite)=='') THEN
		LET cCodRet = '00001';
		--EL TRAMITE NO SE ENCONTRO EN EL CATALOGO O NO TIENE DESCRIPCION
	END IF;
	
	RETURN cCodRet, cTramite;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 10-05-2013",
"Descripcion: Consulta el campo tramite del catalogo de trÃ¡mites.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_consultaconceptogdf_bpi(pClave CHAR(2))
-- DESCRIPCION: CONSULTA PERIODO Y DESCRIPCION
-- AUTOR: ING. CRUZ
-- FECHA: 08-05-2013
-- SISTEMA: PAGOS GDF BPI

RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(50)  AS Periodo,
CHAR(300)  AS Descripcion;

DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cPeriodo     CHAR(50);
DEFINE cDescripcion CHAR(300);

LET iSqlerr = 0;
LET cCodRet = '00000';
LET cPeriodo = '';
LET cDescripcion =''; 

--SET DEBUG FILE TO "/home/informix/bibiana/sp_consultaconceptogdf.out";
--TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
		RETURN cCodRet, cPeriodo,cDescripcion;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;
	
	IF TRIM(NVL(pClave,'')) = '' OR pClave::INT = 0 THEN
		LET cCodRet = '00001';
	END IF;
	
	SELECT descripcion
	INTO cDescripcion
	FROM bdisac:"informix".sac_catconceptosgdf 
	WHERE clave = pClave;
	
	SELECT periodo
	INTO cPeriodo
	FROM bdisac:"informix".sac_periodoslicenciagdf
	WHERE clave = pClave;	

	RETURN cCodRet, cPeriodo,cDescripcion;	
END
END PROCEDURE
DOCUMENT
"Autor : Ing. Cruz",
"FECHA : 08-05-2013",
"Descripcion: Consulta el campo periodo y descripcion.",
"SISTEMA: PAGOS GDF BPI";

CREATE PROCEDURE "informix".sp_ejercicio_fiscal_gdf(pBase CHAR(20))
	RETURNING CHAR(5) AS CodRetorno,
	CHAR(4) AS EjercicioFiscal;	
	
-- ELABORO: 	ING CRUZ
-- FECHA:		30-10-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	GENERA EL EJERCICIO FISCAL A PARTIR DE LA POSICION 17 DE LA LINEA BASE

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cCodRet2     CHAR(5);
DEFINE cEjercicioFiscal CHAR(4);
DEFINE cAnioActual CHAR(4);
DEFINE cAnioMinimo CHAR(4);
DEFINE cComplemento CHAR(3);
DEFINE cAnioValidador CHAR(4);
DEFINE cComplemento2 CHAR(3);
DEFINE cAnioValidador2 CHAR(4);
--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET cCodRet2    = '';
LET cEjercicioFiscal = '';
LET cAnioActual = '';
LET cAnioMinimo = '';
LET cComplemento = '';
LET cAnioValidador = '';
LET cComplemento2 = '';
LET cAnioValidador2 = '';

--SET DEBUG FILE TO '/home/informix/bibiana/sp_ejercicio_fiscal_gdf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, TRIM(NVL(cEjercicioFiscal,''));		
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ; 
	
	SELECT {+index(sac_fechas idx_sac_fechas)}year(fecha_hoy)
	INTO cAnioActual
	FROM bdisac:"informix".sac_fechas ;	
	
	LET cAnioMinimo = cAnioActual::INT - 5;
	LET cComplemento = cAnioActual[1,3];
	LET cAnioValidador = TRIM(cComplemento)||pBase[17,17];
	IF(cAnioValidador>cAnioActual) THEN
		LET cComplemento2 = cComplemento::INT - 1;
	ELSE
		LET cComplemento2 = TRIM(cComplemento);
	END IF;
	
	LET cAnioValidador2 = TRIM(cComplemento2)||pBase[17,17];
	
	--IF((cAnioValidador2<=cAnioActual) AND (cAnioValidador2>=cAnioMinimo)) THEN
	LET cEjercicioFiscal = TRIM(cAnioValidador2);
	--ELSE
	--	LET cCodRet = '00410';
	--END IF; 
	
	RETURN cCodRet, TRIM(NVL(cEjercicioFiscal,''));	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: GENERA EL EJERCICIO FISCAL A PARTIR DE LA POSICION 17 DE LA LINEA BASE',
'AUTOR : Ing. Cruz',
'FECHA : 30-10-2013',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_grababitacoragdf(pNombre char(50), pDomicilio char(80), pColonia char(40), pCP char(5), pDelegacion char(40), pEstado char(20), pGen1 char(100), 
												pGen2 char(100), pGen3 char(100), pGen4 char(100), pGen5 char(100), pGen6 char(100), pGen7 char(100), pGen8 char(100), pGen9 char(100), pGen10 char(100))
	RETURNING CHAR(5) AS CodRetorno;
	
	--Definicion de Variables
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRet 		CHAR(5);
	
	--Inicializacion de Variables
	LET iSqlErr		= 0;
	LET cCodRet		= '00000';
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_grabaBitacoraGDF.out";
	--TRACE ON;
	
	BEGIN
		--Control de excepciones
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

		INSERT INTO bdisac:"informix".sac_bitacoraGDF (fecha_insert, nombre, domicilio, colonia, cp, delegacion, estado, gen1, gen2, gen3, gen4, gen5, gen6, gen7, gen8, gen9, gen10)
		values (CURRENT, pNombre, pDomicilio, pColonia, pCP, pDelegacion, pEstado, pGen1, pGen2, pGen3, pGen4, pGen5, pGen6, pGen7, pGen8, pGen9, pGen10);		

		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para bitacorisar datos adicionales de los pagos de servicios del Gobierno del Distrito Federal',
'AUTOR : Manuel Ramos Figueroa',
'FECHA : 06 de Mayo 2013',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_indexof_bpi(pCadena CHAR(20),pLetra CHAR(1))
	RETURNING CHAR(5) AS CodRetorno,
	INT AS Posicion;

-- ELABORO: 	ING CRUZ
-- FECHA:		06-05-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	DECODIFICA LA LINEA BASE CLAVES 36 - 45

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE iLength int;
DEFINE iPosicion int;
DEFINE i int;
--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET iLength = 0;
LET iPosicion = -1;
LET i = 0;

--SET DEBUG FILE TO '/home/informix/bibiana/sp_obtienelineabase.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, iPosicion;
		END IF;
	END EXCEPTION;
	
	IF ((TRIM(nvl(pCadena,''))=='')OR(TRIM(NVL(pLetra,''))=='')) THEN
		LET cCodRet = '00001';
	ELSE
		LET iLength = LENGTH(pCadena);
		IF(iLength==1)THEN
			LET cCodRet = '00002';
		ELSE
			FOR i = 1 TO 20

				IF i = 1 THEN 
					IF(pCadena[1,1]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 2 THEN 
					IF(pCadena[2,2]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 3 THEN 
					IF(pCadena[3,3]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 4 THEN 
					IF(pCadena[4,4]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 5 THEN 
					IF(pCadena[5,5]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 6 THEN 
					IF(pCadena[6,6]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 7 THEN 
					IF(pCadena[7,7]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 8 THEN 
					IF(pCadena[8,8]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 9 THEN 
					IF(pCadena[9,9]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 10 THEN 
					IF(pCadena[10,10]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 11 THEN 
					IF(pCadena[11,11]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 12 THEN 
					IF(pCadena[12,12]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 13 THEN 
					IF(pCadena[13,13]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 14 THEN 
					IF(pCadena[14,14]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 15 THEN 
					IF(pCadena[15,15]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 16 THEN 
					IF(pCadena[16,16]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 17 THEN 
					IF(pCadena[17,17]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 18 THEN 
					IF(pCadena[18,18]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 19 THEN 
					IF(pCadena[19,19]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 20 THEN 
					IF(pCadena[20,20]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				END IF;				
		    END FOR;
		END IF;				
	END IF;	
	
	RETURN cCodRet,iPosicion;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: TIPICO INDEXOF DE UNA CADENA.',
'AUTOR : Ing. Cruz',
'FECHA : 08-05-2013',
'VERSION: 20130508.1657',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_indexof_der_bpi(pCadena CHAR(20),pLetra CHAR(1))
	RETURNING CHAR(5) AS CodRetorno,
	INT AS Posicion;

-- ELABORO: 	ING CRUZ
-- FECHA:		06-05-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	DECODIFICA LA LINEA BASE CLAVES 36 - 45

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE iLength int;
DEFINE iPosicion int;
DEFINE i int;
--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET iLength = 0;
LET iPosicion = -1;
LET i = 0;

--SET DEBUG FILE TO '/home/informix/bibiana/sp_indexof_der_bpi.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, iPosicion;
		END IF;
	END EXCEPTION;
	
	IF ((TRIM(nvl(pCadena,''))=='')OR(TRIM(NVL(pLetra,''))=='')) THEN
		LET cCodRet = '00001';
	ELSE
		LET iLength = LENGTH(pCadena);
		IF(iLength==1)THEN
			LET cCodRet = '00002';
		ELSE
			FOR i = 20 TO 1

				IF i = 1 THEN 
					IF(pCadena[1,1]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 2 THEN 
					IF(pCadena[2,2]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 3 THEN 
					IF(pCadena[3,3]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 4 THEN 
					IF(pCadena[4,4]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 5 THEN 
					IF(pCadena[5,5]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 6 THEN 
					IF(pCadena[6,6]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 7 THEN 
					IF(pCadena[7,7]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 8 THEN 
					IF(pCadena[8,8]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 9 THEN 
					IF(pCadena[9,9]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 10 THEN 
					IF(pCadena[10,10]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 11 THEN 
					IF(pCadena[11,11]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 12 THEN 
					IF(pCadena[12,12]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 13 THEN 
					IF(pCadena[13,13]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 14 THEN 
					IF(pCadena[14,14]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 15 THEN 
					IF(pCadena[15,15]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 16 THEN 
					IF(pCadena[16,16]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 17 THEN 
					IF(pCadena[17,17]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 18 THEN 
					IF(pCadena[18,18]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 19 THEN 
					IF(pCadena[19,19]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				ELIF i = 20 THEN 
					IF(pCadena[20,20]==pLetra) THEN
						LET  iPosicion = i; 
						EXIT FOR;
					END IF;
				END IF;				
		    END FOR;
		END IF;				
	END IF;
	
	RETURN cCodRet,iPosicion;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: TIPICO INDEXOF DE UNA CADENA.',
'AUTOR : Ing. Cruz',
'FECHA : 08-05-2013',
'VERSION: 20130508.1657',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_isnumeric(pNumero CHAR(20))
	RETURNING CHAR(5) AS CodRetorno;

-- ELABORO: 	ING CRUZ
-- FECHA:		06-05-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	DECODIFICA LA LINEA BASE CLAVES 36 - 45

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE nNumero 		NUMERIC;
--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET nNumero 	= 0;

--SET DEBUG FILE TO '/home/informix/bibiana/sp_isnumeric.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			IF(iSqlErr=-1215 or iSqlErr=-1213)THEN
				LET iSqlErr = 1;
			END IF;
			LET  cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	IF (TRIM(pNumero)=='') THEN
		LET cCodRet = '2';
	ELSE
		LET nNumero = pNumero;
		IF(nNumero<0)THEN
			LET cCodRet = '2';
		END IF;
	END IF;
	
	RETURN cCodRet;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: VALIDA SI ES NUMERO POSITIVO.',
'AUTOR : Ing. Cruz',
'FECHA : 08-05-2013',
'VERSION: 20130506.11',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_isnumeric_int(pNumero CHAR(16))
	RETURNING CHAR(5) AS CodRetorno;

-- ELABORO: 	ING CRUZ
-- FECHA:		06-05-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	DECODIFICA LA LINEA BASE CLAVES 36 - 45

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);

--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';

--SET DEBUG FILE TO '/home/informix/bibiana/sp_isnumeric_int.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			IF(iSqlErr=-1215 or iSqlErr=-1213)THEN
				LET iSqlErr = 1;
			END IF;
			LET  cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	IF (TRIM(pNumero)=='') OR  (pNumero::INTEGER<0) THEN
		LET cCodRet = '2';
	ELSE
		LET iSqlErr = pNumero;
	END IF;
	
	RETURN cCodRet;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: VALIDA SI ES NUMERO ENTERO POSITIVO.',
'AUTOR : Ing. Cruz',
'FECHA : 06-05-2013',
'VERSION: 20130506.11',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_obtenerdvgdf(pCuenta CHAR(20))
	RETURNING CHAR(5) AS CodRetorno, CHAR AS DV;
	
	--Definicion de Variables
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRet 		CHAR(5);
	DEFINE cDV			CHAR;
	DEFINE cValor		CHAR;
	DEFINE i			INTEGER;
	DEFINE iSuma		INTEGER;
	DEFINE iProducto	INTEGER;
	DEFINE cDigito		CHAR;
	DEFINE cDigito2		CHAR;
	DEFINE cAux			CHAR(3);
	
	--Inicializacion de Variables
	LET iSqlErr		= 0;
	LET cCodRet		= '00000';
	LET cDV			= '';
	LET cValor		= '';
	LET i			= 0;
	LET iSuma		= 0;
	LET iProducto	= 0;
	LET cDigito		= '';
	LET cDigito2	= '';
	LET cAux		= '';
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_obtenerDVGDF.out";
	--TRACE ON;
	
	BEGIN
		--Control de excepciones
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet, '';
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

		--Se valida la Cadena reciba por parametro
		IF TRIM(NVL(pCuenta,'')) = '' THEN
			LET cCodRet = '00001';
		ELSE
			LET i = LENGTH(TRIM(pCuenta));
			WHILE i > 0 
				LET cValor = SUBSTR(TRIM(pCuenta), i, 1);
				
				IF i = 1 OR i = 3 OR i = 5 OR i = 7 OR i = 9 OR i = 11 OR i = 13 OR i = 15 THEN
					LET iProducto = cValor::integer * 2;
				ELSE
					LET iProducto = cValor::integer * 1;
				END IF;
				
				IF iProducto < 10 THEN
					LET iSuma = iSuma + iProducto;
				ELSE
					LET cDigito = SUBSTR(iProducto::char(2), 1, 1);
					LET cDigito2 = SUBSTR(iProducto::char(2), 2, 1);					
					LET iSuma = iSuma + (cDigito::integer + cDigito2::integer);
				END IF;
				
				LET i = i - 1;
			END WHILE;
			LET cAux = iSuma::char(3);
			LET cDigito = SUBSTR(TRIM(cAux), LENGTH(TRIM(cAux)), 1);
			
			IF cDigito <> '0' THEN
				LET cDV = (10 - cDigito::integer)::char;
			ELSE
				LET cDV = '0';
			END IF;
		END IF;
		
		RETURN cCodRet, cDV;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para obtener el digito verificador de una cuenta obtenida para pago de Impuesto',
'				Predial y Servicios de Agua, en pagos de servicios GDF.',
'AUTOR : Manuel Ramos Figueroa',
'FECHA : 06 de Mayo 2013',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_valfecha_banca_gdf(pCodPais 	  CHAR(3),
			    		pFechaActual DATE)
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque


/* 
***************************************************************************
REALIZO: ING CRUZ
FECHA: 21/06/2013
DESCRIPCION: VALIDA SI EL DIA ACTUAL ES FERIADO Y OBTIENE EL SIGUIENTE
			 DIA HABIL.
*************************************************************************** 
*/

DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;

DEFINE cCodRet          CHAR(5);
DEFINE dFechaProx        DATE;

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_sac_valfecha_banca_gdf.out";
	--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 10;
	SET ISOLATION TO DIRTY READ;
	
	SELECT fecha_prox
	INTO dFechaProx       
	FROM bdinteg:si_feriado_banca
	WHERE fecha = pFechaActual
    AND pais = pCodPais and laborable = "N";
	
	IF(TRIM(NVL(dFechaProx,''))=='')THEN
		LET dFechaProx = pFechaActual;
	END IF;
	
   RETURN '000',dFechaProx;
END
END PROCEDURE;