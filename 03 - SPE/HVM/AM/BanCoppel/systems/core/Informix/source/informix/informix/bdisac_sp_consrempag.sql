CREATE PROCEDURE "informix".sp_consrempag(pConfirmation_nm CHAR (11), pTrans_Status_Dt DATE)
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
-- 2012.11.14.FRG.I Se agrega numconvenio = '005' (BTS-Ab. Directo en Cta).
	DEFINE cSucursalsif         CHAR(15);
	DEFINE cTerminalsif         CHAR(15);
-- 2012.11.14.FRG.F Se agrega numconvenio = '005' (BTS-Ab. Directo en Cta).
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


        --INICIALIZACION DE VARIABLES--
    LET sql_err                 = 0;
    LET cCodRet                 = '00000';
	LET cSucursal               = '';
	LET cTerminal               = '';
-- 2012.11.14.FRG.I Se agrega numconvenio = '005' (BTS-Ab. Directo en Cta).
	LET cSucursalsif            = '';
	LET cTerminalsif            = '';
-- 2012.11.14.FRG.F Se agrega numconvenio = '005' (BTS-Ab. Directo en Cta).
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

	--SET DEBUG FILE TO "/informix/frg/sp_consrempag.out";
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
    FROM bdisac:"informix".sac_fechas
	where empresa = '001';

	LET cProcess_Dt  = SUBSTRING(pTrans_Status_Dt FROM 7 FOR 4)||SUBSTRING(pTrans_Status_Dt FROM 1 FOR 2)||SUBSTRING(pTrans_Status_Dt FROM 4 FOR 2);

-- 2012.12.11.FRG.I Se agrega numconvenio = '005' (BTS-Ab. Directo en Cta. por si hace falta).
	select valor into cTerminalsif from bdisac:sac_param where empresa = '001' and cod_param = '87016';
-- 2012.12.11.FRG.F
	
	IF pTrans_Status_Dt = dFechaHoy THEN
		SELECT limit 1 NVL(folio_suc,''), id_sucursal
		INTO cFolio_Suc, cSucursalsif
		FROM bdisac:"informix".sac_movimientos
		WHERE numcategoria = '07'
-- 2012.11.14.FRG.I Se agrega numconvenio = '005' (BTS-Ab. Directo en Cta).
		--	AND numconvenio = '004'
		AND numconvenio in ('004', '005')
-- 2012.11.14.FRG.F
		AND referencia1 = pConfirmation_nm
		AND status_cancelado = 'N'
		AND flag_confirmacion_sucursal='1'
		AND flag_confirmacion_central='1'
		AND fecha_insert = (SELECT MAX(fecha_insert)
					FROM bdisac:"informix".sac_movimientos
					WHERE numcategoria = '07'
-- 2012.11.14.FRG.I Se agrega numconvenio = '005' (BTS-Ab. Directo en Cta).
					--					AND numconvenio = '004'
					AND numconvenio in ('004', '005')
-- 2012.11.14.FRG.F
					AND referencia1 = pConfirmation_nm
					AND status_cancelado = 'N'
					AND flag_confirmacion_sucursal='1'
					AND flag_confirmacion_central='1');

    ELIF pTrans_Status_Dt < dFechaHoy THEN
	    SELECT limit 1 NVL(folio_suc,''), id_sucursal
		INTO cFolio_Suc, cSucursalsif
		FROM bdisac:"informix".sac_movimientoshistorial
		WHERE numcategoria = '07'
-- 2012.11.14.FRG.I Se agrega numconvenio = '005' (BTS-Ab. Directo en Cta).
		--	AND numconvenio = '004'
		AND numconvenio in ('004', '005')
-- 2012.11.14.FRG.F
		AND referencia1 = pConfirmation_nm
		AND status_cancelado = 'N'
		AND flag_confirmacion_sucursal='1'
		AND flag_confirmacion_central='1'
		AND ROWID = (SELECT MAX(ROWID)
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = '07'
-- 2012.11.14.FRG.I Se agrega numconvenio = '005' (BTS-Ab. Directo en Cta).
					--					AND numconvenio = '004'
					AND numconvenio in ('004', '005')
-- 2012.11.14.FRG.F					
					AND referencia1 = pConfirmation_nm
					AND status_cancelado = 'N'
					AND flag_confirmacion_sucursal='1'
					AND flag_confirmacion_central='1');								
	ELIF pTrans_Status_Dt > dFechaHoy THEN
	     LET cCodRet = '00002'; -- fecha invalida
	END IF;
	
	IF pTrans_Status_Dt < dFechaHoy AND (cFolio_Suc = '' OR cFolio_Suc IS NULL) THEN
		SELECT limit 1 NVL(folio_suc,''), id_sucursal
		INTO cFolio_Suc, cSucursalsif
		FROM bdisac:"informix".sac_movimientoshistorial_old
		WHERE numcategoria = '07'
		AND numconvenio in ('004', '005')
		AND referencia1 = pConfirmation_nm
		AND status_cancelado = 'N'
		AND flag_confirmacion_sucursal='1'
		AND flag_confirmacion_central='1'
		AND fecha_insert = (SELECT MAX(fecha_insert)
		FROM bdisac:"informix".sac_movimientoshistorial_old
		WHERE numcategoria = '07'
		AND numconvenio in ('004', '005')
		AND referencia1 = pConfirmation_nm
		AND status_cancelado = 'N'
		AND flag_confirmacion_sucursal='1'
		AND flag_confirmacion_central='1');
		
	END IF;

-- 2012.11.14.FRG.I Se agrega numconvenio = '005' (BTS-Ab. Directo en Cta).
	IF	SUBSTR (cFolio_Suc, 1, 7) = 'sys_bts' THEN
		LET cFolio_SucPayi = cFolio_Suc;
		LET cSucursal = cSucursalsif;
		LET cTerminal = cTerminalsif;
		RETURN cCodRet, TRIM(NVL(cSucursal,'')), TRIM(NVL(cTerminal,'')), TRIM(NVL(cR_Type_Cd,'')), TRIM(NVL(cR_Identif_Nm,'')), TRIM(NVL(cR_Nom_Calle,'')), TRIM(NVL(cR_Num_Ext,'')), TRIM(NVL(cR_Num_Int,'')), TRIM(NVL(cR_Depto,'')), TRIM(NVL(cR_Colonia,'')),
		TRIM(NVL(cR_Cp,'')), TRIM(NVL(cR_Mncpo_Deleg,'')), TRIM(NVL(cR_Ciudad,'')), TRIM(NVL(cR_Estado,'')), TRIM(NVL(cR_Issuer_Country_Cd,'')), TRIM(NVL(cR_Telefono,'')), TRIM(NVL(cTipo_Pago,'')), TRIM(NVL(cR_Fecha_Nac,'')), TRIM(NVL(cR_Nacionalidad,'')),
		TRIM(NVL(cR_pais_nac,'')), TRIM(NVL(cFolio_SucPayi,''));
	ELSE
-- 2012.11.14.FRG.F
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
		ELIF EXISTS(SELECT sucursal FROM bdisac:"informix".sac_bts_payi_old WHERE confirmation_nm = pConfirmation_nm
	        AND bank_ref_nm = cFolio_Suc AND opcode = '1100' AND process_dt = cProcess_Dt) THEN
			SELECT branch_sd, terminal, r_type_cd, r_identif_nm, R_nom_calle, R_num_ext, R_num_int, R_depto, R_colonia,
			R_cp, R_mncpo_deleg, R_ciudad, R_estado, r_issuer_country_cd, R_telefono, Tipo_pago, R_fecha_nac,  R_nacionalidad,
			r_pais_nac, bank_ref_nm
			INTO cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, cR_Depto, cR_Colonia,
			cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad,
			cR_pais_nac, cFolio_SucPayi
			FROM bdisac:"informix".sac_bts_payi_old
			WHERE confirmation_nm = pConfirmation_nm
			AND bank_ref_nm = cFolio_Suc
			AND opcode = '1100'
			AND process_dt = cProcess_Dt
			AND fecha_insert = (SELECT MAX(fecha_insert)
			FROM bdisac:"informix".sac_bts_payi_old
			WHERE confirmation_nm = pConfirmation_nm
			AND bank_ref_nm = cFolio_Suc
			AND opcode = '1100'
			AND process_dt = cProcess_Dt);
		ELSE
			LET cCodRet = '00003';
			END IF;
		ELSE
	    LET cCodRet = '00004';
		END IF;
	END IF;
--	2014.03.26 -FRG-i	se asigna el ÃÂÃÂºltimo TipoId y NoId registrado en la tabla de pagos BTS (para el caso en que la Remesa estÃÂÃÂ¡ pagada para Banco, y No Pagada en BTS).
	if 
		cCodRet = '00003'
		then
			SELECT 
				FIRST 1 (r_type_cd)
					into cr_type_cd
				FROM bdisac:"informix".sac_bts_payi
				WHERE confirmation_nm = pConfirmation_nm
				AND bank_ref_nm = cFolio_Suc;
			SELECT 
				FIRST 1 (r_identif_nm)
					into cR_Identif_Nm
				FROM bdisac:"informix".sac_bts_payi
				WHERE confirmation_nm = pConfirmation_nm
				AND bank_ref_nm = cFolio_Suc;
			--let cCodRet = '00000';
			
			IF (cr_type_cd = '' OR cr_type_cd IS NULL) AND (cR_Identif_Nm = '' OR cR_Identif_Nm IS NULL) THEN
				SELECT 
				FIRST 1 (r_type_cd)
					into cr_type_cd
				FROM bdisac:"informix".sac_bts_payi_old
				WHERE confirmation_nm = pConfirmation_nm
				AND bank_ref_nm = cFolio_Suc;
			SELECT 
				FIRST 1 (r_identif_nm)
					into cR_Identif_Nm
				FROM bdisac:"informix".sac_bts_payi_old
				WHERE confirmation_nm = pConfirmation_nm
				AND bank_ref_nm = cFolio_Suc;
			END IF;
			let cCodRet = '00000';			
			
		else
	end if;	
--	2014.03.26 -FRG-f	
	
	RETURN cCodRet, TRIM(NVL(cSucursal,'')), TRIM(NVL(cTerminal,'')), TRIM(NVL(cR_Type_Cd,'')), TRIM(NVL(cR_Identif_Nm,'')), TRIM(NVL(cR_Nom_Calle,'')), TRIM(NVL(cR_Num_Ext,'')), TRIM(NVL(cR_Num_Int,'')), TRIM(NVL(cR_Depto,'')), TRIM(NVL(cR_Colonia,'')),
	TRIM(NVL(cR_Cp,'')), TRIM(NVL(cR_Mncpo_Deleg,'')), TRIM(NVL(cR_Ciudad,'')), TRIM(NVL(cR_Estado,'')), TRIM(NVL(cR_Issuer_Country_Cd,'')), TRIM(NVL(cR_Telefono,'')), TRIM(NVL(cTipo_Pago,'')), TRIM(NVL(cR_Fecha_Nac,'')), TRIM(NVL(cR_Nacionalidad,'')),
	TRIM(NVL(cR_pais_nac,'')), TRIM(NVL(cFolio_SucPayi,''));
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener informacion del registro de una remesa pagada cuando se consulta desde plataforma',
'AUTOR: Dulce Ramirez',
'FECHA: 10/Enero/2011',
'Ver: 1.1',
'MODIFICO: Felipe Urias',
'FECHA: 12/Abril/2012',
'DESCRIPCION: se agrego el campo r_pais_nac a la consulta  y al retorno',
'MODIFICO: Jesus Aguilar',
'FECHA: 12/Septiembre/2012',
'DESCRIPCION: se agrego filtro para validar que se obtenga un registro en las tablas de bitÃÂÃÂ¡coras y movtos',
'MODIFICO: FRG',
'FECHA: 26/Marzo/2014',
'DESCRIPCION: se agrega bÃÂÃÂºsqueda para obtener el Tipo_Id y No_Id de una remesa pagada en Banco y No Pagada en BTS.',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_dinya_insertaenvios 
	(pNumeroControl CHAR(12),
	pEfectivo MONEY(16,2),
	pMontoCargo MONEY(16,2),
	pCuentaCargo CHAR(20),
	pSucursal CHAR(4),
	pFolioSuc CHAR(16))

	RETURNING  CHAR(5), CHAR(16);

	DEFINE cCodRet 			 		CHAR(5);
	DEFINE iSqlErr			 		INTEGER;
	DEFINE cCuentaPrestadora 		CHAR(20);
	DEFINE cCuentaReceptora	 		CHAR(20);
	DEFINE cTransaccAbonoEnvio		CHAR(4);
	DEFINE cTransaccAbonoIva		CHAR(4);
	DEFINE cTransaccAbonoComision	CHAR(4);
	DEFINE mTotComision				MONEY (16,2);
	DEFINE mTotIVA					MONEY (16,2);
	DEFINE mTotIvaComision			MONEY (16,2);
	DEFINE pImporte					MONEY (16,2);
	DEFINE mTotalaCobrar			MONEY (16,2);
	DEFINE cTransaccSuc				CHAR(4);
	DEFINE mMontoEnvio				MONEY(16,2);
	DEFINE cEjecutivo				CHAR(8);
	DEFINE dFecha_hoy				DATE;
	DEFINE isam_error				INTEGER;
	DEFINE cDescripcion				CHAR(200);
	DEFINE cTransaccCargocomi		CHAR(4);
	DEFINE cTransaccCargoIVA		CHAR(4);
	DEFINE ctranret					CHAR(4);
	DEFINE dfechoy					DATE;
	DEFINE msdodisp					MONEY (14,2);
	DEFINE mmontoret				MONEY (14,2);
	-- 20110906-I
	DEFINE cCadena_ent              CHAR (100);
	-- 20110906-F


	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr,isam_error,cDescripcion
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				INSERT INTO bdisac: "informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (iSqlErr,isam_error,cDescripcion,'sp_dinya_insertaenvios',dFecha_hoy,CURRENT );
				RETURN cCodRet, pFolioSuc;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/sysifx/Trinidad/homo_APP/sp_dinya_insertaenvios.out";
		--TRACE ON;

		LET cCodRet 			   = '00000';
		LET iSqlErr			 	   = 0;
		LET cCuentaPrestadora 	   = '';
		LET cCuentaReceptora       = '';
		LET cTransaccAbonoEnvio	   = '';
		LET cTransaccAbonoIva	   = '';
		LET cTransaccAbonoComision = '';
		LET mTotComision		   = '';
		LET mTotIVA				   = '';
		LET mTotIvaComision 	   = '';
		LET pImporte			   = '';
		LET mTotalaCobrar		   = '';	
		LET cTransaccSuc		   = '';
		LET mMontoEnvio			   = '';
		LET cEjecutivo			   = SUBSTR(pFolioSuc,1,8);
		LET dFecha_hoy			   = '';
		LET isam_error			   = '';
		LET cDescripcion		   = '';
		LET cTransaccCargocomi		='';
		LET cTransaccCargoIVA		='';
		LET ctranret				='';
		LET dfechoy					='';
		LET msdodisp				='';
		LET mmontoret				='';

	-- 20110906-I
		LET cCadena_ent = pNumeroControl||'|'||pEfectivo||'|'||pMontoCargo||'|'||pCuentaCargo||'|'||pSucursal||'|'||pFolioSuc;
	-- 20110906-F.	
		
		--Validaciones
		IF pNumeroControl = '' Or pNumeroControl IS NULL THEN
			LET cCodRet = 00004;
			RETURN cCodRet,pFolioSuc;
		END IF;

		IF pMontoCargo IS NULL THEN
			LET cCodRet = 00004;
			RETURN cCodRet,pFolioSuc;
		END IF;

		IF pMontoCargo= '' THEN
			LET pMontoCargo = 0;
		END IF;

		IF pEfectivo IS NULL THEN
			LET cCodRet = 00004;
			RETURN cCodRet,pFolioSuc;
		END IF;

		IF pEfectivo= ''  THEN
			LET pEfectivo = 0;
		END IF;

		IF pSucursal IS NULL OR pSucursal = '' THEN
			LET cCodRet = 00004;
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Obtiene parametros
		SELECT valor INTO cCuentaPrestadora
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='75';

		SELECT valor INTO cTransaccAbonoEnvio
		FROM Bdisac:"informix".sac_param
		WHERE cod_param='5070011';

		SELECT valor INTO cTransaccAbonoComision
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='511070011';

		SELECT valor INTO cTransaccAbonoIva
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='510070011';

		SELECT valor INTO cTransaccSuc
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='807001';	

		SELECT {+INDEX (bdisac: "informix".sac_enviosdineroya idxsac_envdinya13_1)} importe_envio INTO mMontoEnvio
		FROM Bdisac: "informix".sac_enviosdineroya
		WHERE no_control = pNumeroControl and estatus is not null;

		SELECT valor INTO cTransaccCargocomi
		FROM Bdisac:"informix".sac_param
		WHERE cod_param='413070012';

		SELECT valor INTO cTransaccCargoiva
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='4070012';

		SELECT fecha_hoy 
		INTO dFecha_hoy
		FROM Bdisac: "informix".sac_fechas;		
		
		
		IF pSucursal = '5003' THEN
		
			-- Obtiene el ejecutivo
			select usua_envio 
			into cEjecutivo
			from bdisac:"informix".sac_enviosdineroya
			where no_control = pNumeroControl;
			
			--Calcula la comision e Iva bpi
			
			CALL  bdisac:"informix".sp_dinya_calcularcomisioniva_bpi ('07', '001', mMontoEnvio)
			RETURNING cCodRet,pImporte,mTotIVA,mTotComision,mTotalaCobrar,mTotIvaComision;  
			
			LET mTotalaCobrar=pImporte+mTotIvaComision;
			
		ELIF pSucursal = '5008' THEN
		
			-- Obtiene el ejecutivo
			select usua_envio 
			into cEjecutivo
			from bdisac:"informix".sac_enviosdineroya
			where no_control = pNumeroControl;
			
			CALL  bdisac:"informix".sp_dinya_calcularcomisioniva_bei ('07', '001', mMontoEnvio)
			RETURNING cCodRet,pImporte,mTotIVA,mTotComision,mTotalaCobrar,mTotIvaComision;  
			
			--Validar si la cuenta es un producto tasa 0 para establecer las comisiones en 0
			IF (SELECT COUNT(1) FROM bdicheq:sc_maechq WHERE cuenta = TRIM(pCuentaCargo) AND producto IN ('1600')) > 0 THEN
				LET mTotIvaComision = 0;
				LET mTotIVA = 0;
				LET mTotComision = 0;
			END IF;

			LET mTotalaCobrar=mMontoEnvio+mTotIvaComision;
		
		ELSE
			--Calcula la comision e Iva
			CALL  bdisac: "informix".sp_DinYa_CalcularComisionIva ('07001',mMontoEnvio,pSucursal)
			RETURNING cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
			
		END IF;
		
		IF cCodRet <> 0 THEN
			LET cCodRet = '00005'; --Error en el calculo de comision e iva
			RETURN cCodRet,pFolioSuc;
		END IF;

			LET pEfectivo= pEfectivo; --De pruebas quietarlos
			LET pMontoCargo=pMontoCargo;
		
		
		IF (pEfectivo + pMontoCargo) <> (mMontoEnvio+mTotIvaComision) THEN
			LET cCodRet = '00006'; 
			RETURN cCodRet,pFolioSuc;
		END IF;
		

		IF pMontoCargo = 0 THEN
			
			--Abono a la cuenta prestadora de servicios por el monto del Envio
			CALL bdicheq: "informix".abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoEnvio, cTransaccSuc , pFolioSuc, cCuentaPrestadora,
			0, mMontoEnvio, mMontoEnvio, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;  
			IF cCodRet <> 0 THEN
	-- 20110906-I:
	--                  INSERT INTO bdisac:sac_log_envios VALUES ('Abono por Envio', pFolioSuc, mMontoEnvio, cCodRet, dFecha_hoy, current);
						INSERT INTO bdisac:"informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
							values ('Abono por Envio', pFolioSuc, mMontoEnvio, cCodRet, cCadena_ent, dFecha_hoy, CURRENT);            
	-- 20110906-F.
				LET cCodRet = '00007'; --Error en el abono de el importe
				RETURN cCodRet,pFolioSuc;
			END IF;		

			--Abono a la cuenta prestadora (Comision)
			CALL bdicheq: "informix".abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoComision ,cTransaccSuc , pFolioSuc, cCuentaPrestadora,
			0, mTotComision, mTotComision, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;
			IF cCodRet <> 0 THEN
			--LLamado a realizar la reversion.
	-- 20110906-I:
			--	INSERT INTO bdisac:sac_log_envios VALUES ('Abono Comisiï¿½n', pFolioSuc, mTotComision, cCodRet, dFecha_hoy, current);
				INSERT INTO bdisac:"informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
					values ('Abono Comisiï¿½n', pFolioSuc, mTotComision, cCodRet, cCadena_ent, dFecha_hoy, CURRENT);            
	-- 20110906-F.		
				CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
				LET cCodRet = '00008'; --Error en el abono de la comision
				RETURN cCodRet,pFolioSuc;
			END IF;

				--Cargo a la cuenta prestadora por comision		
			CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargocomi, cTransaccSuc, pFolioSuc, 
			cCuentaPrestadora, 0, mTotComision,"01", " ", '', cEjecutivo) 
			Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;
				IF cCodRet <> 0 THEN
			--LLamado a realizar la reversion.
	-- 20110906-I:
			--	INSERT INTO bdisac:sac_log_envios VALUES ('Cargo Comisiï¿½n', pFolioSuc, mTotComision, cCodRet, dFecha_hoy, current);
				INSERT INTO bdisac:"informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
					values ('Cargo Comisiï¿½n', pFolioSuc, mTotComision, cCodRet, cCadena_ent, dFecha_hoy, CURRENT);            
	-- 20110906-F
			CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
				LET cCodRet = '00025'; --Error en el cargo por el Iva
				RETURN cCodRet,pFolioSuc;
			END IF;

			--Abono a la cuenta prestadora (Iva)
			CALL bdicheq: "informix".abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoIva , cTransaccSuc , pFolioSuc, cCuentaPrestadora,
			0, mTotIVA, mTotIVA, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;
			IF cCodRet <> 0 THEN
	-- 20110906-I:
			-- INSERT INTO bdisac:sac_log_envios VALUES ('Abono IVA', pFolioSuc, mTotIVA, cCodRet, dFecha_hoy, current);		
				INSERT INTO bdisac:"informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
					values ('Abono IVA', pFolioSuc, mTotIVA, cCodRet, cCadena_ent, dFecha_hoy, CURRENT);            
	-- 20110906-I:
			--LLamado a realizar la reversion.
				CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
				LET cCodRet = '00009'; --Error en el abono del iva
				RETURN cCodRet,pFolioSuc;
			END IF;

			--Cargo a la cuenta prestadora por comision		
			CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoiva, cTransaccSuc, pFolioSuc, 
			cCuentaPrestadora, 0, mTotIVA,"01", " ", '', cEjecutivo) 
			Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;
			IF cCodRet <> 0 THEN
			--LLamado a realizar la reversion.
	-- 20110906-I:
		 -- INSERT INTO bdisac:sac_log_envios VALUES ('Cargo IVA', pFolioSuc, mTotIVA, cCodRet, dFecha_hoy, current);
			INSERT INTO bdisac:"informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
				values ('Cargo IVA', pFolioSuc, mTotIVA, cCodRet, cCadena_ent, dFecha_hoy, CURRENT);            
	-- 20110906-F:
			CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
				LET cCodRet = '00026'; --Error en el cargo por el Iva
				RETURN cCodRet,pFolioSuc;
			END IF;

			UPDATE {+INDEX (bdisac: "informix".sac_enviosdineroya idxsac_envdinya13_1)} bdisac: "informix".sac_enviosdineroya 
			SET estatus = '01'
			WHERE no_control = pNumeroControl and estatus is not null;

			

			
		ELIF pEfectivo > 0 AND  pMontoCargo > 0  THEN
		
			IF pEfectivo >= mTotIvaComision THEN		

				CALL bdisac:sp_dinya_InsertaEnvios2 (mMontoEnvio,pMontoCargo,pEfectivo,pCuentaCargo,
				pSucursal, cEjecutivo, pFolioSuc) Returning cCodRet,pFolioSuc;	
				IF cCodRet <> 0 THEN	
					RETURN cCodRet,pFolioSuc;
				END IF;
			ELSE 
				LET cCodRet = '00022'; --El efectivo no cubre la comision e iva.
				RETURN cCodRet,pFolioSuc;
			END IF;		

			UPDATE {+INDEX (bdisac: "informix".sac_enviosdineroya idxsac_envdinya13_1)} bdisac: "informix".sac_enviosdineroya 
			SET estatus = '01'
			WHERE no_control = pNumeroControl and estatus is not null;


		ELIF pEfectivo = 0 THEN
			
			CALL bdisac: "informix".sp_dinya_InsertaEnvios3 (mMontoEnvio,pMontoCargo,pCuentaCargo,
			pSucursal, cEjecutivo, pFolioSuc,pNumeroControl) Returning cCodRet,pFolioSuc;

			IF cCodRet <> 0 THEN			
				RETURN cCodRet,pFolioSuc;
			END IF;		

			UPDATE {+INDEX (bdisac: "informix".sac_enviosdineroya idxsac_envdinya13_1)} bdisac:"informix".sac_enviosdineroya 
			SET estatus = '01'
			WHERE no_control = pNumeroControl and estatus is not null;

		END IF;

		RETURN cCodRet,pFolioSuc;

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: GENERA EL ENVIO CON PAGO EN EFECTIVO DE MONTO ENVIO, COMISION E IVA, ACTIVA ENVIO EN SAC_ENVIOSDINEROYA', 
'AUTOR: ABIGAIL VASAVILBAZO CAï¿½EDO',
'FECHA: DICIEMBRE 2009',
'MODIFICACION: SE AGREGA CARGO PARA COMISION E IVA A CTA PRESTADORA Y SE UTILIZAN DIFERENTES TRANSACCIONES PARA ABONO DE PAGO EN EFECTIVO Y DE CARGO', 
'AUTOR: ABIGAIL VASAVILBAZO CAï¿½EDO',
'FECHA: ENERO 2010',
'VERSION: 20100126.0854',
'MODIFICACION: Se agrega campo "cadena_ent" a la tabla "sac_log_envios" para guardar los datos de entrada al SP.', 
'AUTOR: FRG',
'FECHA: Septiembre 2011',
'VERSION: 20110906.0951',
'MODIFICACION: Se agrega validacion para ejecutar el sp sp_dinya_calcularcomisioniva_bpi cuando se realize una orden de pago desde la BPI', 
'AUTOR: Ilse Gomez',
'FECHA: 15 de enero de 2015',
'VERSION: 20141216.0900',
'BD: BDISAC',
'AUTOR : Viridiana PR',
'DESCRIPCION: Se envia el parï¿½metro ï¿½pNumeroControlï¿½ al procedimiento sp_dinya_insertaenvios3',
'FECHA : MAYO 2015',
'VERSION: 20150528',
'BD    : bdisac',
'',
'DESCRIPCION: "Homologaciï¿½n de caja appriza con RQM 10-239-5 Y RQM 10-495 y cambio BTS_parametro sucursal"; Homologaciï¿½n con Vers. Prod., Pago de remesas Appriza',
'MODIFICADO : Trinidad Hernï¿½ndez',
'folio: 73',
'FECHA : 16/06/2016',
'VERSION: 20160616.1528',
'BD    : bdisac',
'',
'AUTOR: Marco Tinajero',
'DESCRIPCION: Se agrega validacion por cuenta para omitir cobro de comisiones cuando es producto 1600 para Empresanet - 5008, debido a que son tasa 0',
'FECHA: 23 OCTUBRE 2024',
'SOLICITO : Armando Barrientos - GSM3',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_dinya_insertaenvios3 
	(mMontoEnvio MONEY(16,2),
	pMontoCargo MONEY(16,2),
	pCuentaCargo CHAR(20),
	pSucursal CHAR(4),
	cEjecutivo CHAR(8),
	pFolioSuc CHAR(16),
	pNumeroControl CHAR(12))

	RETURNING  CHAR(5), CHAR(16);

	DEFINE cCodRet 			 		CHAR(5);
	DEFINE iSqlErr			 		INTEGER;
	DEFINE cCuentaPrestadora 		CHAR(20);
	DEFINE cTransaccAbonoEnvio		CHAR(4);
	DEFINE cTransaccAbonoIva		CHAR(4);
	DEFINE cTransaccAbonoComision	CHAR(4);
	DEFINE mTotComision				MONEY (16,2);
	DEFINE mTotIVA					MONEY (16,2);
	DEFINE mTotIvaComision			MONEY (16,2);
	DEFINE pImporte					MONEY (16,2);
	DEFINE mTotalaCobrar			MONEY (16,2);
	DEFINE cTransaccSuc				CHAR(4);
	DEFINE cTransaccCargoEnvio 		CHAR(4);
	DEFINE ctranret					CHAR(4);
	DEFINE dfechoy					DATE;
	DEFINE msdodisp					MONEY (14,2);
	DEFINE mmontoret				MONEY (14,2);
	DEFINE dFecha_hoy				DATE;
	DEFINE isam_error				INTEGER;
	DEFINE cDescripcion				CHAR(200);
	DEFINE cTransaccCargoiva		CHAR(4);
	DEFINE cTransaccCargocomi		CHAR(4);
	DEFINE cTransaccCargocomiCte	CHAR(4);
	DEFINE cTransaccCargoivaCte		CHAR(4);
	DEFINE iFlgProdTasa0			INTEGER;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				INSERT INTO bdisac: "informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (iSqlErr,isam_error,cDescripcion,'sp_dinya_insertaenvios3',dFecha_hoy,CURRENT );
				RETURN cCodRet, pFolioSuc;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/informix/bibiana/sp_dinya_InsertaEnvios3.out";
		--TRACE ON;

		LET cCodRet 			   = '00000';
		LET iSqlErr			 	   = 0;
		LET cCuentaPrestadora 	   = '';
		LET cTransaccAbonoEnvio	   = '';
		LET cTransaccAbonoIva	   = '';
		LET cTransaccAbonoComision = '';
		LET mTotComision		   = '';
		LET mTotIVA				   = '';
		LET mTotIvaComision 	   = '';
		LET pImporte			   = '';
		LET mTotalaCobrar		   = '';	
		LET cTransaccSuc		   = '';
		LET cTransaccCargoEnvio	   = '';
		LET ctranret			   = '';
		LET dfechoy				   = '';
		LET msdodisp			   = '';
		LET mmontoret			   = '';
		LET dFecha_hoy			   = '';
		LET isam_error			   = '';
		LET cDescripcion		   = '';
		LET cTransaccCargoiva	='';
		LET cTransaccCargocomi	='';
		LET cTransaccCargocomiCte	='';
		LET cTransaccCargoivaCte		='';
		LET iFlgProdTasa0 = 0; --El valor de la bandera sera 0 siempre salvo cambie a 1 por un producto 1600 para la sucursal 5008

		--Obtiene parametros
		SELECT valor INTO cCuentaPrestadora
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='75';

		SELECT valor INTO cTransaccAbonoEnvio
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='5070012';

		SELECT valor INTO cTransaccCargoEnvio
		FROM Bdisac:"informix".sac_param
		WHERE cod_param='414070021';

		SELECT valor INTO cTransaccAbonoComision
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='511070012';

		SELECT valor INTO cTransaccAbonoIva
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='510070012';

		SELECT valor INTO cTransaccSuc
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='807001';	

		SELECT valor INTO cTransaccCargocomiCte
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='413070011';

		SELECT valor INTO cTransaccCargoivaCte
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='4070011';

		SELECT valor INTO cTransaccCargocomi
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='413070012';

		SELECT valor INTO cTransaccCargoiva
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='4070012';		
		
		SELECT fecha_hoy 
		INTO dFecha_hoy
		FROM Bdisac: "informix".sac_fechas;			

		
		IF pSucursal = '5003' THEN

			--Calcula la comision e Iva bpi
			CALL  bdisac:"informix".sp_dinya_calcularcomisioniva_bpi ('07', '001', mMontoEnvio)
			RETURNING cCodRet,pImporte,mTotIVA,mTotComision,mTotalaCobrar,mTotIvaComision;  
			
			LET mTotalaCobrar=pImporte+mTotIvaComision;
			
		ELIF pSucursal = '5008' THEN
		
			CALL  bdisac:"informix".sp_dinya_calcularcomisioniva_bei ('07', '001', mMontoEnvio)
			RETURNING cCodRet,pImporte,mTotIVA,mTotComision,mTotalaCobrar,mTotIvaComision;  
			
			--Validar si la cuenta es un producto tasa 0 para establecer las comisiones en 0
			SELECT COUNT(1) INTO iFlgProdTasa0 
			FROM bdicheq:sc_maechq 
			WHERE cuenta = TRIM(pCuentaCargo) AND producto IN ('1600');

			IF iFlgProdTasa0 > 0 THEN
				LET mTotIvaComision = 0;
				LET mTotIVA = 0;
				LET mTotComision = 0;
			END IF;

			LET mTotalaCobrar=pImporte+mTotIvaComision;	
			
		ELSE
		
			--Calcula la comision e Iva
			CALL  bdisac: "informix".sp_DinYa_CalcularComisionIva ('07001',mMontoEnvio,pSucursal)
			RETURNING cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
			
		END IF;
		
		IF cCodRet <> 0 THEN
			LET cCodRet = '00015'; --Error en el calculo de comision e iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta del cte por orden de pago	
		LET pMontoCargo= pMontoCargo- mTotIvaComision;
		CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoEnvio, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, pMontoCargo,"01", pNumeroControl, '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
			LET cCodRet = '00016'; --Error en el cargo de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;	

		--Abono a la cuenta prestadora de servicios por el monto del Envio
		CALL bdicheq: "informix".abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoEnvio, cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, pMontoCargo, mMontoEnvio, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;  

		IF cCodRet <> 0 THEN
			CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00017'; --Error en el abono de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;		
		
		-- Si la cuenta del cliente es un producto 1600 el valor de la bandera sera 1 y omitira el cargo a la cuenta del cliente y el abono a la cuenta prestadora, caso contrario ejecutara los cargos y abonos
		IF iFlgProdTasa0 != 1 THEN
			--Cargo a la cte del cliente por el monto de la comision
			CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargocomiCte, cTransaccSuc, pFolioSuc,pCuentaCargo, 0, mTotComision,"01", pNumeroControl, '', cEjecutivo) 
			Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

			IF cCodRet <> 0 THEN
			--LLamado a realizar la reversion.
				CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
				LET cCodRet = '00018'; --Error en el cargo de la comision
				RETURN cCodRet,pFolioSuc;
			END IF;

			--Abono a la cuenta receptora (Comision)
			CALL bdicheq: "informix".abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoComision ,cTransaccSuc , pFolioSuc, 
			cCuentaPrestadora,0, mTotComision, mTotComision, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;

			IF cCodRet <> 0 THEN
			--LLamado a realizar la reversion.
				CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
				LET cCodRet = '00019'; --Error en el abono de la comision
				RETURN cCodRet,pFolioSuc;
			END IF;

			--Cargo a la cuenta del cliente por el Iva			
			CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoivaCte, cTransaccSuc, pFolioSuc,pCuentaCargo, 0, mTotIVA,"01", pNumeroControl, '', cEjecutivo) 
			Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

			IF cCodRet <> 0 THEN
			--LLamado a realizar la reversion.
				CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
				LET cCodRet = '00020'; --Error en el cargo por el Iva
				RETURN cCodRet,pFolioSuc;
			END IF;

			--Abono a la cuenta receptora (Iva)
			CALL bdicheq: "informix".abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoIva , cTransaccSuc , pFolioSuc, 
			cCuentaPrestadora,0, mTotIVA, mTotIVA, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;

			IF cCodRet <> 0 THEN
			--LLamado a realizar la reversion del abono y cargo
				CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
				LET cCodRet = '00021'; --Error en el abono del iva
				RETURN cCodRet,pFolioSuc;
			END IF;

			--Cargo a la cuenta prestadora por la comision			
			CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargocomi, cTransaccSuc, pFolioSuc, 
			cCuentaPrestadora, 0, mTotComision,"01", "", '', cEjecutivo) 
			Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

			IF cCodRet <> 0 THEN
			--LLamado a realizar la reversion.
				CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
				LET cCodRet = '00023'; --Error en el cargo por el Iva
				RETURN cCodRet,pFolioSuc;
			END IF;

			--Cargo a la cuenta prestadora por el iva		
			CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoiva, cTransaccSuc, pFolioSuc, 
			cCuentaPrestadora, 0, mTotIVA,"01", "", '', cEjecutivo) 
			Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

			IF cCodRet <> 0 THEN
			--LLamado a realizar la reversion.
				CALL bdicheq: "informix".reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
				LET cCodRet = '00024'; --Error en el cargo por el Iva
				RETURN cCodRet,pFolioSuc;
			END IF;
		END IF;

		RETURN cCodRet,pFolioSuc; 

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: GENERA EL ENVIO CON PAGO CON CARGO A CUENTA DE MONTO ENVIO, COMISION E IVA, ACTIVA ENVIO EN SAC_ENVIOSDINEROYA', 
'AUTOR: ABIGAIL VASAVILBAZO CAï¿½EDO',
'FECHA: DICIEMBRE 2009',
'VERSION: 20100125.1024',
'MODIFICACION: Se agrega validacion para ejecutar el sp sp_dinya_calcularcomisioniva_bpi cuando se realize una orden de pago desde la BPI', 
'AUTOR: Ilse Gomez',
'FECHA: 15 de enero de 2015',
'VERSION: 20141216.0900',
'BD: BDISAC',
'AUTOR : Viridiana PR',
'DESCRIPCION: Se agrego parï¿½metro ï¿½pNumeroControlï¿½ para pasar el numero de control a cargo_ref en la parte del 	parï¿½metro pReferencia',
'FECHA : MAYO 2015',
'VERSION: 20150528',
'BD    : bdisac',
'MODIFICACION -- DSB-TH-17/06/2016',
'DESCRIPCION: "Homologaciï¿½n de caja appriza con RQM 10-239-5 Y RQM 10-495 y cambio BTS_parametro sucursal"; Homologaciï¿½n con Vers. Prod., Pago de remesas Appriza',
'MODIFICA: Trinidad Hernï¿½ndez',
'folio: 73',
'FECHA : 17/06/2016',
'VERSION: 20160617.1720',
'BD    : bdisac',
'',
'AUTOR: Marco Tinajero',
'DESCRIPCION: Se agrega validacion por cuenta para omitir cobro de comisiones cuando es producto 1600 para Empresanet - 5008, debido a que son tasa 0',
'FECHA: 23 OCTUBRE 2024',
'SOLICITO : Armando Barrientos - GSM3',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_decodifica_linea_base_principal(pCaptura CHAR(20), pImporte CHAR(20), pNumCuenta CHAR(20), pLlaveGDF INTEGER)
    RETURNING CHAR(5) AS CodRetorno,
    CHAR AS LlevaDatosAdicionales,
    CHAR(700)  AS RespuestaAMostrar,
    CHAR(2000)  AS RespuestaDecodificada;

    -- ELABORO:     ING CRUZ
    -- FECHA:       13-05-2013
    -- PROYECTO:    PAGOS GDF BPI
    -- DESCRIPCION: DECODIFICA LA LINEA BASE

    --Definicion de Variables
    DEFINE iSqlErr                  INTEGER;
    DEFINE cCodRet                  CHAR(5);
    DEFINE cCodRet2                 CHAR(5);
    DEFINE i                        INTEGER;
    DEFINE k                        CHAR(1);
    DEFINE cCadena                  CHAR(20);
    DEFINE cConcepto                CHAR(250);
    DEFINE cLeyenda                 CHAR(20);
    DEFINE cTipoLicencia            CHAR(1);
    DEFINE cTipoReferencia          CHAR(10);
    DEFINE cDescripcionConcepto     CHAR(300);

    DEFINE cPeriodo                 CHAR(300);
    DEFINE cPlaca                   CHAR(20);   --*
    DEFINE cModelo                  CHAR(15);
    DEFINE cFolio                   CHAR(25);   --*
    DEFINE cModeloFolio             CHAR(15);
    DEFINE cCantidad                CHAR(15);
    DEFINE cFolioInfraccion         CHAR(15);
    DEFINE cAnioInfraccion          CHAR(10);
    DEFINE cTipoHolograma           CHAR(150);
    DEFINE cMarca                   CHAR(50);
    DEFINE cVerificentro            CHAR(10);

    DEFINE cReferencia              CHAR(50);   --*
    DEFINE cEjercicioFiscal         CHAR(4);

    DEFINE cRFC                     CHAR(12);
    DEFINE cMES                     CHAR(50);
    DEFINE cPredial                 CHAR(25);   --*
    DEFINE cTipoOperacion           CHAR(50);
    DEFINE cTramite                 CHAR(300);
    DEFINE cSubconcepto             CHAR(300);
    DEFINE cTipoDeclaracion         CHAR(300);
    DEFINE cVigencia                CHAR(30);

    DEFINE cRespuestaMostrar        CHAR(700);
    DEFINE cRespuestaDecodificada   CHAR(2000);

    DEFINE cOrigen                  CHAR(40);
    DEFINE cPrecio                  CHAR(40);
    DEFINE cAdmonTributaria         CHAR(55);
    DEFINE cEjercicio               CHAR(120);
    DEFINE cBimestre                CHAR(20);
    DEFINE cLlevaDatosAdicionales   CHAR;
    DEFINE v_folio_suc              INTEGER;
    DEFINE v_cta_sac                INTEGER;


    --Inicializacion de Variables
    LET iSqlErr                 = 0;
    LET cCodRet                 = '00000';
    LET cCodRet2                = '';
    LET i                       = 0;
    LET cCadena                 = '';
    LET k                       = '';
    LET cConcepto               = '';
    LET cLeyenda                = '';
    LET cTipoLicencia           = '';
    LET cTipoReferencia         = '';
    LET cDescripcionConcepto    = '';
    LET cPeriodo                = '';
    LET cFolio                  = '';

    LET cPeriodo                = '';
    LET cPlaca                  = '';
    LET cModeloFolio            = '';
    LET cCantidad               = '';
    LET cFolioInfraccion        = '';
    LET cAnioInfraccion         = '';
    LET cTipoHolograma          = '';
    LET cMarca                  = '';
    LET cVerificentro           = '';

    LET cReferencia             = '';
    LET cEjercicioFiscal        = '';

    LET cRFC                    = '';
    LET cMES                    = '';
    LET cPredial                = '';
    LET cTipoOperacion          = '';
    LET cTramite                = '';
    LET cSubconcepto            = '';
    LET cTipoDeclaracion        = '';
    LET cVigencia               = '';

    LET cRespuestaMostrar       = '';
    LET cRespuestaDecodificada  = '';

    LET cOrigen                 = '';
    LET cPrecio                 = '';
    LET cAdmonTributaria        = '';
    LET cEjercicio              = '';
    LET cBimestre               = '';
    LET cLlevaDatosAdicionales  = '0';
    LET v_folio_suc             = 0;
    LET v_cta_sac               = 0;

    --SET DEBUG FILE TO '/home/c90305365/sp_decodifica_linea_base_principal.out';
    --TRACE ON;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET  cCodRet = iSqlErr;
                RETURN cCodRet, cLlevaDatosAdicionales, cRespuestaMostrar,cRespuestaDecodificada;
            END IF;
        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;

        IF (pImporte::INTEGER < 10) THEN
            --EL IMPORTE DEL PAGO ES MENOR A 10 PESOS
            LET cCodRet = '00001';

        ELSE
    
            IF(LENGTH(TRIM(NVL(pCaptura,'')))==20) THEN
            
            SELECT count (*) INTO  v_folio_suc FROM bdisac:"informix".sac_movimientos where referencia1 = pCaptura and numcategoria = '08' and numconvenio = '001';
            SELECT count (*) INTO v_cta_sac FROM bdisac:"informix".sac_gdf_pagos WHERE linea_captura = pCaptura;
                
            If (v_folio_suc > 0 or v_cta_sac > 0) THEN
                --LA LINEA DE CAPTURA YA FUE PROCESADA
                    LET cCodRet = '00200';
                ELIF(pCaptura[1,2] IN ('01','02','04','05','07','09','11','13','14'))THEN
                --TRANSITO, VIALIDAD Y MEDIO AMBIENTE LICENCIAS
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_licencias(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cTipoLicencia, cPeriodo, cTipoReferencia, cDescripcionConcepto;
                    LET cCodRet = cCodRet2;
                    If (pCaptura[1,2] IN ('02','04'))THEN
                        LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
                        LET cRespuestaDecodificada = '|Tipo='||TRIM(NVL(cTipoLicencia,''))||'|Periodo='||TRIM(NVL(cPeriodo,''))||'|Referencia='||TRIM(NVL(cTipoReferencia,''))||'|';
                    else
                        LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
                        LET cRespuestaDecodificada = '|Tipo='||TRIM(NVL(cTipoLicencia,''))||'|Periodo='||TRIM(NVL(cPeriodo,''))||'|Referencia='||TRIM(NVL(cTipoReferencia,''))||'|';
                    end if;
				--LICENCIAS PERMANENTES	
				ELIF(pCaptura[1,2] IN ('03')) THEN	
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_licencias_permanentes(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cTipoLicencia, cPeriodo, cTipoReferencia, cDescripcionConcepto, cTramite;
                    LET cCodRet = cCodRet2;
				    LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
                    LET cRespuestaDecodificada = '|Tipo='||TRIM(NVL(cTipoLicencia,''))||'|Periodo='||TRIM(NVL(cPeriodo,''))||'|Referencia='||TRIM(NVL(cTipoReferencia,''))||'|Tramite='||TRIM(NVL(cTramite,''))||'|';	
                ELIF(pCaptura[1,2] IN ('20','21','22','23'))THEN 
                --PERMISOS ADMINISTRATIVOS TEMPORALES REVOCABLES 
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodificadatospermisosadmintemrevo(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio;
                    LET cCodRet = cCodRet2;
                        If (pCaptura[1,2] IN ('22'))THEN
                            LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
                            LET cRespuestaDecodificada = '|Unidad='||TRIM(NVL(cFolio,''))||'|';
                        else
                            LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
                            LET cRespuestaDecodificada = '|Folio='||TRIM(NVL(cFolio,''))||'|';
                        end if;
                        
                    
                ELIF(pCaptura[1,2] IN ('36','38','39','40','42','45','46'))THEN --- Se quita el concepto 48 BGV-- se quita 44 GAM
                --TRAMITES DE VEHICULOS PARTICULARES
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosTramitesVehiculares(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cOrigen, cReferencia, cMarca, cModelo, cPlaca;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
                    LET cRespuestaDecodificada = '|' || TRIM(NVL(cOrigen,'')) || '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cMarca,'')) || '|' || TRIM(NVL(cModelo,'')) || '|' || TRIM(NVL(cPlaca,'')) || '|';
                ----------------------------------------------------------------------- 
                ELIF(pCaptura[1,2] IN ('37'))THEN --- TAXIS (CLAVE 37-15)
                --TRAMITES DE VEHICULOS PARTICULARES
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodificadatostramitesvehiculares(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cOrigen, cReferencia, cMarca, cModelo, cPlaca;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					-- La placa = anio revista
                    LET cRespuestaDecodificada = '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cModelo,'')) || '|' || TRIM(NVL(cMarca,'')) || '|' || TRIM(NVL(cPlaca,'')) || '|';
                ELIF(pCaptura[1,2] IN ('41'))THEN --- BICICLETAS Y MOTOCICLETAS ADAPTADAS (CLAVE 41-02)
                --TRAMITES BICICLETAS Y MOTOCICLETAS ADAPTADAS (CLAVE 41-02)
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodificadatostramitesvehiculares(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cOrigen, cReferencia, cMarca, cModelo, cPlaca;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
                    LET cRespuestaDecodificada = '|' || TRIM(NVL(cReferencia,'')) || '|';
				ELIF(pCaptura[1,2] IN ('43'))THEN --- PERMISOS TRANSPORTE MERCANTIL CARGA Y PASAJEROS (CLAVE 43-12)
                --TRAMITES TRANSPORTE MERCANTIL CARGA Y PASAJEROS
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodificadatostramitesvehiculares(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cOrigen, cReferencia, cMarca, cModelo, cPlaca;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
                    LET cRespuestaDecodificada = '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cPlaca,'')) || '|';
                ----------------------------------------------------------------------- 
                ELIF(pCaptura[1,2] IN ('49'))THEN
                --MULTAS DE TRANSITO
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_multas(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
                    LET cRespuestaDecodificada = '|Folio Infraccion='||TRIM(NVL(cFolio,''))||'|';
                ELIF(pCaptura[1,2] IN ('50','51','52','53'))THEN
                --MEDIO AMBIENTE
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_medio(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cPlaca, cModelo, cMarca, cFolioInfraccion, cAnioInfraccion, cVerificentro, cTipoHolograma, cCantidad,cFolio;
                    LET cCodRet = cCodRet2;
				    IF(pCaptura[1,2] IN ('52'))THEN	
                        LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
                        LET cRespuestaDecodificada = '|Tipo Holograma='||TRIM(NVL(cTipoHolograma,''))||'|Centro de verificaciÃ³n vehicular='||TRIM(NVL(cVerificentro,''))||'|Folio='||TRIM(NVL(cFolio,''))||'|Hologramas vendidos='||TRIM(NVL(cCantidad,''))||'|';
                    ELSE
				        LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
                        LET cRespuestaDecodificada = '|Placa='||TRIM(NVL(cPlaca,''))||'|Modelo='||TRIM(NVL(cModelo,''))||'|Marca='||TRIM(NVL(cMarca,''))||'|Folio InfracciÃ³n='||TRIM(NVL(cFolioInfraccion,''))||'|AÃ±o InfracciÃ³n='||TRIM(NVL(cAnioInfraccion,''))||'|Clave Verificentro='||TRIM(NVL(cVerificentro,''))||'|Tipo Holograma='||TRIM(NVL(cTipoHolograma,''))||'|Cantidad='||TRIM(NVL(cCantidad,''))||'|Folio='||TRIM(NVL(cFolio,''))||'|';
				    END IF;
				
				ELIF(pCaptura[1,2] IN ('54','55','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74','75','76','77'))THEN
                --TRAMITES DEL REGISTRO CIVIL
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosRegistroCivil(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio, cCantidad, cPrecio, cReferencia, cAdmonTributaria, cConcepto;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
                    IF(pCaptura[1,2] == ('77')) THEN
                    --SE OMITE '|' || TRIM(NVL(cAdmonTributaria,'')) || VIENE EN EL PDF PERO NO EN EL RECIBO OFICIAL
                       -- LET cRespuestaDecodificada = '|' || TRIM(NVL(cAdmonTributaria,'')) || '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cFolio,'')) || '|' || TRIM(NVL(cCantidad,'')) || '|' || TRIM(NVL(cPrecio,'')) || '|' || TRIM(NVL(cConcepto,'')) || '|';
						LET cRespuestaDecodificada = '|' || TRIM(NVL(cConcepto,'')) || '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cFolio,'')) || '|' ;
                    ELSE
                        LET cRespuestaDecodificada = '|' || TRIM(NVL(cFolio,'')) || '|' || TRIM(NVL(cCantidad,'')) || '|' || TRIM(NVL(cPrecio,'')) || '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cAdmonTributaria,'')) || '|' || TRIM(NVL(cConcepto,'')) || '|';
                    END IF;

                ELIF(pCaptura[1,2] IN ('78','79'))THEN
                --SERVICIOS DE LA POLICIA
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosServicioPolicia(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
                    LET cRespuestaDecodificada = '|' || TRIM(NVL(cFolio,'')) || '|';
                ELIF(pCaptura[1,2] IN ('80','81'))THEN
                --IMPUESTO PREDIAL
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosImpuestoPredial(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cPredial, cEjercicio, cBimestre;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
                    LET cRespuestaDecodificada = '|' || TRIM(NVL(cPredial,'')) || '|' || TRIM(NVL(cEjercicio,'')) || '|' || TRIM(NVL(cBimestre,'')) || '|';
                ELIF(pCaptura[1,2] IN ('82','83'))THEN
                --DERECHOS POR SUMINISTRO DE AGUA
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosServicioAgua(pCaptura, pImporte, pNumCuenta, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cEjercicio, cBimestre;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
                    LET cRespuestaDecodificada = '|' || TRIM(NVL(cEjercicio,'')) || '|' || TRIM(NVL(cBimestre,'')) || '|';
                    LET cLlevaDatosAdicionales = '1';
                ELIF(pCaptura[1,2] IN ('84','85','86','87'))THEN
                --TENENCIA Y DERECHOS VEHICULARES
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_vehicular(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto,  cReferencia, cModeloFolio, cEjercicioFiscal;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
                    LET cRespuestaDecodificada = '|Referencia='||TRIM(NVL(cReferencia,''))||'|Modelo o Folio='||TRIM(NVL(cModeloFolio,''))||'|Ejercicio Fiscal='||TRIM(NVL(cEjercicioFiscal,''))||'|';
                    LET cLlevaDatosAdicionales = '1';
                ELIF(pCaptura[1,2] IN ('88','96','89','90','91','92','93','94','95','97','98'))THEN 
                --OTRAS CONTRIBUCIONES
                    EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_otras(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cRFC, cEjercicioFiscal, cMes, cPredial, cTipoOperacion, cFolio, cTramite,cSubconcepto,cReferencia,   cTipoDeclaracion, cVigencia, cLlevaDatosAdicionales;
                    LET cCodRet = cCodRet2;
                    LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|Subconcepto='||TRIM(NVL(cSubconcepto,''))||'|';
                    LET cRespuestaDecodificada = '|RFC='||TRIM(NVL(cRFC,''))||'|Ejercicio='||TRIM(NVL(cEjercicioFiscal,''))||'|Mes='||TRIM(NVL(cMes,''))||'|Cuenta Predial='||TRIM(NVL(cPredial,''))||'|Tipo de Operacion='||TRIM(NVL(cTipoOperacion,''))||'|Folio='||TRIM(NVL(cFolio,''))||'|Tramite='||TRIM(NVL(cTramite,''))||'|Referencia='||TRIM(NVL(cReferencia,''))||'|Tipo de DeclaraciÃ³n='||TRIM(NVL(cTipoDeclaracion,''))||'|Vigencia='||TRIM(NVL(cVigencia,''))||'|';
                    IF(pCaptura[1,2] IN('91','94','95','97','98')AND(cLlevaDatosAdicionales='0'))THEN
                        LET cLlevaDatosAdicionales = '0';
                    ELSE
                        LET cLlevaDatosAdicionales = '1';
                    END IF;
                ELSE
                    --LA CLAVE DE PAGO NO CORRESPONDE A LAS OPERACIONES VALIDAS
                    LET cCodRet = '00002';
                END IF;
            ELSE
                --LA LONGITUD DE LA LINEA DE CAPTURA ES DIFERENTE A 20 CARACTERES
                LET cCodRet = '00001';
            END IF;

        END IF;
        --LET cCodRet = '00000';
        RETURN cCodRet, cLlevaDatosAdicionales, cRespuestaMostrar,cRespuestaDecodificada;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: DECODIFICA LA LINEA BASE Y LISTA LOS CAMPOS A MOSTRAR',
'AUTOR : Ing. Cruz',
'FECHA : 14-05-2013',
'VERSION: 20130514.13',
'BD: bdisac',
'Folio: 1448',
'Autor: 95734511 - L.S.C. Jose Magdiel Martinez',
'Fecha: 09-04-2014',
'Modificacion: Se aÃade un nuevo parametro quen contiene la llave de decodificacion de la linea base.',
'Sustento: Reimpresion GDF',
'Modificacion: Se agrega validacion de importe, para que no se puedan hacer pagos de menos de 10 pesos',
'Bibiana Gaxiola Verdugo',
'Fecha: 25/Agosto/2014',
'Modificacion: Se agrega concepto 94 para Derechos Varios',
'Fecha: 05/12/2017',
'Modificacion: Se agrega concepto 23 ',
'Fecha: 11/12/2018',
'Modificacion: Se agrega concepto 55 y se quita el 44 ',
'Sustento: certificacion GDF 2021',
'Fecha: 13/11/2020',
'Irma Ureta',
'Modificacion: Se agrega periodo a respuesta decodificada para claves 02 y 04 ',
'Sustento: certificacion GDF 2022',
'Fecha: 08/11/2022',
'Paulina Gonzalez',
'Eudez Lopez Morales',
'Victor Manuel Hernandez Lopez',
'Modificacion: Se agrega periodo a respuesta decodificada para claves 37, 41, 43, 77, 52 ',
'Sustento: certificacion GDF 2025',
'Fecha: 12/11/2024';

CREATE PROCEDURE "informix".sp_decodifica_linea_base_medio(pCaptura CHAR(20), pImporte CHAR(20), pLlaveGDF INTEGER)
	RETURNING CHAR(5)   AS CodRetorno, 
	          CHAR(300) AS DescripcionConcepto,
	          CHAR(15)  AS Placa,
	          CHAR(15)  AS Modelo,
	          CHAR(50)  AS Marca,
	          CHAR(15)  AS FolioInfraccion, 
	          CHAR(10)  AS AnioInfraccion,
	          CHAR(10)  AS Verificentro,
	          CHAR(150) AS TipoHolograma, 
	          CHAR(10)  AS Cantidad,
	          CHAR(15)  AS Folio;

-- ELABORO: 	ING CRUZ
-- FECHA:		13-05-2013
-- PROYECTO: 	PAGOS GDF BPI
-- DESCRIPCION:	DECODIFICA LA LINEA BASE CLAVES 50 - 52

--Definicion de Variables
DEFINE iSqlErr 		            INTEGER;		--
DEFINE cCodRet 		            CHAR(5);		--
DEFINE cCodRet2     	        CHAR(5);		--
DEFINE cCadena 			        CHAR(20);		--
DEFINE cLeyenda     	        CHAR(20);		--
DEFINE cPlaca 			        CHAR(15);		--
DEFINE diferente 			    CHAR(15);		--		  
DEFINE cModelo		 		    CHAR(15);		--
DEFINE cFolio		   		    CHAR(15);		--
DEFINE cMarca 				    CHAR(50);		--
DEFINE cDescripcionConcepto  	CHAR(300);		--
DEFINE cPeriodo			        CHAR(300);		--
DEFINE cCantidad 		        CHAR(10);		--
DEFINE cFolioInfraccion         CHAR(15);		--
DEFINE cAnioInfraccion          CHAR(10);		--
DEFINE cTipoHolograma           CHAR(150);		--
DEFINE cVerificentro            CHAR(10);		--
DEFINE cVerificentro2           CHAR(10);	    --

--Inicializacion de Variables
LET iSqlErr 			        = 0;
LET cCodRet 			        = '00000';
LET cCodRet2    		        = '';
LET cLeyenda    		        = '';
LET cCadena 			        = '';
LET cDescripcionConcepto        = '';
LET cPeriodo			        = '';
LET cPlaca 				        = '';
LET diferente 			        = '';					   
LET cModelo		                = '';
LET cFolio				        = '';
LET cCantidad 			        = '';
LET cFolioInfraccion 	        = '';
LET cAnioInfraccion 	        = '';
LET cTipoHolograma 		        = '';
LET cMarca 				        = '';
LET cVerificentro 		        = '';
LET cVerificentro2 		        = '';

  --SET DEBUG FILE TO '/informix/VIMA/CERT2025/Verificentros/sp_decodifica_linea_base_medio.out';
  --TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, cDescripcionConcepto, cPlaca, cModelo, cMarca, cFolioInfraccion, cAnioInfraccion, cVerificentro, cTipoHolograma, cCantidad, cFolio;
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ; 
	-- SE LEE EL CONCEPTO DE PAGO Y LA LINEA BASE
	EXECUTE PROCEDURE bdisac:"informix".sp_obtienelineabase_bpi(pCaptura,pImporte, pLlaveGDF) INTO cCodRet2, cLeyenda, cCadena;
	--LET cCodRet2 = '00000';
	IF cCodRet2 <> '00000' THEN
			LET cCodRet = cCodRet2;
	ELSE
		
		IF(cCadena[1,2] == '50') THEN
			--MULTA POR VERIFICACIÃN EXTEMPORÃNEA 50
			--Placa, modelo y marca
			
			EXECUTE PROCEDURE bdisac:"informix".sp_consulta_marca_gdf(cCadena[3,3]) INTO cCodRet2, cMarca;
			/*IF cCodRet2 <> '00000' THEN
				LET cCodRet = cCodRet2;
			END IF;
			*/
			
			LET cPlaca = pCaptura[4,13];
			
			LET cPlaca = REPLACE(cPlaca,'X','');
			EXECUTE PROCEDURE bdisac:"informix".sp_isnumeric_int(cPlaca) INTO cCodRet2;
			IF (cCodRet2 == '00000') THEN
				--LA PLACA NO CONTIENE LETRAS
				IF(TRIM(cPlaca)==4) THEN 
					LET cPlaca = 'X'||TRIM(NVL(cPlaca,''));
				END IF;			
			END IF;
			--LECTURA DEL MODELO O FOLIO
			
			LET cModelo = YEAR(CURRENT);
			/*EXECUTE PROCEDURE bdisac:"informix".sp_isnumeric_int(TRIM(NVL(cCadena[17,18],''))) INTO cCodRet2;
			IF (cCodRet2 == '00000') THEN
				EXECUTE PROCEDURE bdisac:"informix".sp_asignaanio(TRIM(NVL(cCadena[17,18],''))) INTO cCodRet2, cModelo;
				IF (cCodRet2 <> '00000') THEN
					LET cCodRet = cCodRet2;
				END IF;	
				
				
			ELSE
				--AMBOS DIGITOS DEBEN SER NUMERICOS PARA FORMAR EL MODELO
				LET cCodRet = '00001';
			END IF;*/
			
			
		ELIF(cCadena[1,2] == '51') THEN	
			--MULTA POR VEHÃCULOS CONTAMINANTES 51
			--FOLIO Y AÃO DE INFRACCION
			LET cFolioInfraccion  = cCadena[6,13];
			LET cAnioInfraccion = YEAR(CURRENT);
			EXECUTE PROCEDURE bdisac:"informix".sp_isnumeric_int(TRIM(NVL(cCadena[4,5],''))) INTO cCodRet2;
			IF (cCodRet2 == '00000') THEN				
				EXECUTE PROCEDURE bdisac:"informix".sp_asignaanio(TRIM(NVL(cCadena[4,5],''))) INTO cCodRet2, cAnioInfraccion;
			--	IF (cCodRet2 <> '00000') THEN
			--		LET cCodRet = cCodRet2;
			--	END IF;
			--ELSE
				--AMBOS DIGITOS DEBEN SER NUMERICOS PARA FORMAR EL AÃO
				--LET cCodRet = '00001';
			END IF;
			
		ELIF(cCadena[1,2] == '52') THEN	
			--VENTA DE HOLOGRAMAS A VERIFICENTROS 52
			--CLAVE VERIFICENTRO, TIPO HOLOGRAMA, CANTIDAD, FOLIO
			LET cFolio = cCadena[3,6];
			
			LET cCantidad = cCadena[7,9]::INTEGER;
			
			LET cVerificentro = cCadena[10,12]::INTEGER;
			
			 SELECT Verificentro
             INTO  cVerificentro2		 
			 FROM  bdisac:"informix".sac_verificentrosgdf 
			 WHERE clave = cVerificentro;
			
			LET cVerificentro = cVerificentro2;
			
			
			
/* 			LET cCantidad = cCadena[7,10]::INTEGER;
			IF(cCadena[11,12]=='A1')THEN
				LET cVerificentro = '1069';
			ELIF(cCadena[11,12]=='A2')THEN
				LET cVerificentro = '1070';
			ELIF(cCadena[11,12]=='A3')THEN
				LET cVerificentro = '1071';
			ELSE
				
				IF((cCadena[11,12]::int)>1 and (cCadena[11,12]::int<99))THEN
					LET cVerificentro = '90'||TRIM(cCadena[11,12]); 
				END IF;				
				
			END IF; */
			
			
			
			
			
			EXECUTE PROCEDURE bdisac:"informix".sp_consulta_holograma_gdf_bpi(TRIM(NVL(cCadena[13,13],''))) INTO cCodRet2, cTipoHolograma;
			
			/*IF (cCodRet2 <> '00000') THEN
				LET cCodRet = cCodRet2;
			END IF;*/

		ELIF (cCadena[1,2] == '53') THEN --OBTIENE CLAVE
		     
		    IF(cCadena[3,4] == '01') THEN --OBTIENE SUBCLAVE 01
			 
			  
                LET cPlaca = pCaptura[5,13]; --OBTIENE LA PLACA
		      
			  --SE DEBEN DESCARTAR LAS LETRAS X
			
			    LET diferente = 1;
			  --ENCUENTRA LA POSICION DE LA PRIMER LETRA DIFERENTE A X
			    WHILE SUBSTRING (cPlaca FROM diferente FOR 1) = 'X'
			
		          LET diferente = diferente +1;
		        END WHILE;
			  --OBTIENE LA SUBCADENA A PARTIR DE ESA POSICION
			      LET cPlaca = SUBSTRING(cPlaca FROM diferente);
			
			  
		      --UNICAMENTE PARA EL CASO DE LAS PLACAS, 
		      --SI LA LONGITUD RESULTANTE ES DE 4 DÃGITOS 
		      --SE AÃADIRA UNA âXâ AL PRINCIPIO DE LA CADENA.
			  
              IF (cPlaca [5] == ' ' ) THEN
			  LET cPlaca = 'X'||TRIM(NVL(cPlaca,''));
			  END IF; 
			  
            ELSE

			    IF(cCadena[3,4] == '02') THEN --OBTIENE SUBCLAVE 02
				
				LET cFolio = cCadena[5,9]; --OBTIENE FOLIO DE LA LINEA DE CAPTURA
			    LET cCantidad = cCadena[10,13]::INTEGER; --OBTIENE EL NUMERO DE HOLOGRAMAS
			   
		        END IF;  
			
	        END IF;
			
			ELSE 
				LET cCodRet = '00001';
			END IF; --CIERRE FINAL
		
		EXECUTE PROCEDURE bdisac:"informix".sp_consultaconceptogdf_bpi(pCaptura[1,2])INTO cCodRet2, cPeriodo, cDescripcionConcepto;
		IF cCodRet2 <> '00000' THEN
			IF (cCodRet2 == '00001') THEN
				LET cDescripcionConcepto = 'Centro de Servicio';
			ELSE
				LET cCodRet = cCodRet2;
			END IF;
			
		END IF;
		IF (cCadena[1,2] == '53') THEN
			LET cDescripcionConcepto = 'Reposicion de constancia de verificacion vehicular (certificado y holograma) y Canje de constancias de verificacion vehicular (holograma)';
			
			IF(cCadena[3,4] == '02') THEN
				LET cDescripcionConcepto = 'Compra de constancias (hologramas) de los programas de autorregulacion (diesel y electromovilidad)';
			END IF;
		END IF;
	END IF;
	
	RETURN cCodRet, cDescripcionConcepto, cPlaca, cModelo, cMarca, cFolioInfraccion, cAnioInfraccion, cVerificentro, cTipoHolograma, cCantidad, cFolio;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: DECODIFICA LA LINEA BASE CLASIFICACION C.',
'AUTOR : Ing. Cruz',
'FECHA : 13-05-2013',
'VERSION: 20130513.1243',
'BD: bdisac',
'DESCRIPCION: HOMOLOGACIÃN CON LA FUNCIONALIDAD EN CAJA SIN VALIDACIONES DE DATOS DECODIFICADOS',
'AUTOR: ING CRUZ 10-10-2013',
'Folio: 1448',
'Autor: 95734511 - L.S.C. JosÃ© Magdiel MartÃ­nez',
'Fecha: 09-04-2014',
'ModificaciÃ³n: Se aÃ±ade un nuevo parÃ¡metro quen contiene la llave de decodificaciÃ³n de la linea base.',
'Sustento: Reimpresion GDF';

CREATE PROCEDURE "informix".sp_decodificadatosregistrocivil(pLineaCaptura CHAR(20), pImporte CHAR(16), pLlaveGDF INTEGER)
	RETURNING CHAR(5) AS CodRetorno, CHAR(140) AS Leyenda, CHAR(15) AS Folio, CHAR(15) AS Cantidad, CHAR(40) AS Precio, CHAR(20) AS Referencia, CHAR(55) AS AdmonTributaria, CHAR(250) AS Concepto2;
	
	--Definicion de Variables
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cCodRet2				CHAR(5);
	DEFINE cConcepto			CHAR(2);
	DEFINE cLeyenda				CHAR(140);
	DEFINE cLineaCapturaBase	CHAR(20);
	DEFINE cFolio				CHAR(15);
	DEFINE cCantidad			CHAR(15);
	DEFINE cPrecio				CHAR(40);
	DEFINE cReferencia			CHAR(20);
	DEFINE cAdmonTributaria		CHAR(55);
	DEFINE cConcepto2			CHAR(250);
	DEFINE cRefA				CHAR(4);
	DEFINE cRefB				CHAR(2);
	DEFINE cDato				CHAR(2);
	
	--Inicializacion de Variables
	LET iSqlErr 			= 0;
	LET cCodRet 			= '00000';
	LET cCodRet2			= '00000';
	LET cConcepto			= '';
	LET cLeyenda			= '';
	LET cLineaCapturaBase	= '';
	LET cFolio				= '';
	LET cCantidad			= '';
	LET cPrecio				= '';
	LET cReferencia			= '';
	LET cAdmonTributaria	= '';
	LET cConcepto2			= '';
	LET cRefA				= '';
	LET cRefB				= '';
	LET cDato				= '';
	
    --SET DEBUG FILE TO "/informix/VIMA/CERT2025/Clave77/sp_decodificaDatosRegistroCivil.out";
	--TRACE ON;

	
	BEGIN
		--Control de excepciones
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet, '', '', '', '', '', '', '';
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;					  
		
		--Se valida que la Linea de Captura y el Importe tengan el formato correcto
		IF TRIM(NVL(pLineaCaptura,'')) = '' OR LENGTH(TRIM(pLineaCaptura)) <> 20 OR TRIM(NVL(pImporte,'')) = '' THEN
			LET cCodRet = '00001';
		ELSE
			--Se valida que sea una Linea de Captura apta para ser procesada y la Linea de Captura Base 
			--para decodificar los datos necesarios
			EXECUTE PROCEDURE bdisac:"informix".sp_obtienelineabase_bpi(pLineaCaptura, pImporte, pLlaveGDF)
			INTO cCodRet2, cLeyenda, cLineaCapturaBase;
			
			IF NVL(cCodRet2, '') = '00000' THEN
				--Se obtiene el Concepto de Pago de la Linea de Captura
				LET cConcepto = SUBSTR(pLineaCaptura, 1, 2);

				SELECT descripcion 
				INTO cLeyenda 
				FROM bdisac:"informix".sac_catconceptosgdf
				WHERE clave = cConcepto;

				LET cLeyenda = 'Concepto=' || cLeyenda;

				IF cConcepto = '54' THEN
					LET cCantidad = SUBSTR(cLineaCapturaBase, 3, 2);
					
					--Se valida que el valor Cantidad sea correcto, verificando que la divisiÃÂ³n entre el Importe y la Cantidad de como resultado un entero.
					IF MOD( cCantidad::integer,  pImporte::money) = 0 THEN
						LET cFolio = "Folio=" || SUBSTR(cLineaCapturaBase, 6, 8);
						LET cPrecio = "Precio unitario=" || pImporte::money / cCantidad::integer;
						LET cCantidad = "Cantidad=" || cCantidad; 
					ELSE
						--El dato Cantidad es incorrecto
						LET cCantidad = '';
						LET cCodRet = '00003';
					END IF;
					
				ELIF cConcepto = '55' THEN
					LET cFolio = "Folio=" || SUBSTR(cLineaCapturaBase, 6, 7);	
					
				ELIF cConcepto::integer >= 57 AND cConcepto <= 76 THEN
					LET cFolio = "Folio=" || SUBSTR(cLineaCapturaBase, 6, 8);
				ELIF cConcepto = '77' THEN
					LET cRefA = SUBSTR(cLineaCapturaBase, 3, 4);
					LET cRefB = SUBSTR(cLineaCapturaBase, 17, 2);
					LET cReferencia = "Referencia=" || cRefB || cRefA;
					
					SELECT descripcion
					INTO cConcepto2
					FROM bdisac:"informix".sac_catfuncionesdecobrogdf
					WHERE funcion = cRefA;
					
					IF TRIM(NVL(cConcepto2, '')) <> '' THEN
						LET cConcepto2 = "Concepto=" || cConcepto2;
					ELSE
						LET cConcepto2 = "Concepto=PAGO A TESORERÃA";
					END IF;
					
					LET cDato = SUBSTR(cLineaCapturaBase, 7, 2);
					
					SELECT descripcion
					INTO cAdmonTributaria
					FROM bdisac:"informix".sac_catadminstributariasgdf
					WHERE id = cDato;
					
					IF TRIM(NVL(cAdmonTributaria, '')) <> '' THEN
						LET cAdmonTributaria = "AdministraciÃ³n Tributaria=" || cAdmonTributaria;
					ELSE
						LET cAdmonTributaria = "AdministraciÃ³n Tributaria=No Definida";						
					END IF;
					
					
					IF cConcepto = '77' THEN
					LET cFolio = "Folio=" || SUBSTR(cLineaCapturaBase, 7, 7);
					
					ELSE
										
					LET cFolio = "Folio=" || SUBSTR(cLineaCapturaBase, 9, 5);
					
					END IF;
				END IF;
			ELSE
				LET cCodRet = cCodRet2;
			END IF;
		END IF;
		
		RETURN cCodRet, cLeyenda, cFolio, cCantidad, cPrecio, cReferencia, cAdmonTributaria, cConcepto2;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para decodificar datos de la Linea de Captura Base de Pagos de Impuesto de GDF ',
'				(Tramites Registro Civil, Conceptos 54 - 77).',
'AUTOR : Manuel Ramos Figueroa',
'FECHA : 06 de Mayo 2013',
'BD: bdisac',
'Folio: 1448',
'Autor: 95734511 - L.S.C. JosÃ© Magdiel MartÃ­nez',
'Fecha: 09-04-2014',
'ModificaciÃ³n: Se aÃ±ade un nuevo parÃ¡metro quen contiene la llave de decodificaciÃ³n de la linea base.',
'Sustento: Reimpresion GDF',
'Fecha: 13-11-2020',
'ModificaciÃ³n: Se aÃ±ade el nuevo parÃ¡metro 55 de la linea base.',
'Sustento: certificacion 2021 GDF';

CREATE PROCEDURE "informix".sp_aplica_pago_con_cargo_msw(pOrigen CHAR(4),pTransaccion CHAR(5),pCategoria CHAR(2),pConvenio CHAR(3),pSucursal_tienda CHAR(4),
	pCajero CHAR(8),pCaja CHAR(3),pFecha CHAR(8),pHora CHAR(6),pFolio_peracion CHAR(18),pReferencia_1 CHAR(40),pReferencia_2 CHAR(40),pReferencia_3 CHAR(40),
	pReferencia_4 CHAR(40),pImporte CHAR(10),pFormapago CHAR(1), pCuenta_cargo CHAR(20), pRealizar_cargo CHAR(1))
	RETURNING 	CHAR(5) 	AS codigo,
				CHAR(30) 	AS mensaje,
				CHAR(16)	AS folio_suc;

	--CONTROL DE EXCEPCIONES
    DEFINE iSqlErr					INTEGER;
    DEFINE iIsamErr					SMALLINT;
    DEFINE cErrorInfo				CHAR(80);
	--RETORNO
	DEFINE cCodRet					CHAR(5);
	DEFINE cMensaje					CHAR(30);
	DEFINE cFolioSuc				CHAR(16);
	--CONSULTA DE SALDO DISPONIBLE
    DEFINE cCons_sdo1           	CHAR(5);
    DEFINE cCons_sdo2           	CHAR(20);
    DEFINE cCons_sdo3           	CHAR(20);
    DEFINE cCons_sdo4           	CHAR(26);
    DEFINE cCons_sdo5           	CHAR(26);
    DEFINE cCons_sdo6           	CHAR(26);
    DEFINE cCons_sdo7           	CHAR(26);
    DEFINE cCons_sdo8           	CHAR(60);
    DEFINE cCons_sdo9           	CHAR(1);
    DEFINE mCons_sdo10          	MONEY(14,2);
    DEFINE mCons_sdo11          	MONEY(14,2);
    DEFINE mCons_sdo12          	MONEY(14,2);
    DEFINE mCons_sdo13          	MONEY(14,2);
    DEFINE mCons_sdo14          	MONEY(14,2);
    DEFINE cCons_sdo15          	CHAR(1);
    DEFINE cCons_sdo16          	CHAR(40);
    DEFINE cCons_sdo17          	CHAR(40); 
    DEFINE mCons_sdo18          	MONEY(14,2);
    DEFINE mCons_sdo19          	MONEY(14,2);
    DEFINE mCons_sdo20          	MONEY(14,2);
    DEFINE cCons_sdo21          	CHAR(8);
    DEFINE dCons_sdo22          	DATE;
    DEFINE cCons_sdo23          	CHAR(16);
    DEFINE cCons_sdo24          	CHAR(18);
	--PROCESO DE CARGO
    DEFINE cTranret         		CHAR(4);
    DEFINE dFechoy          		DATE;
    DEFINE mSdodisp         		MONEY(14,2);
	DEFINE mMontoret        		MONEY(14,2);
	--ADICIONALES
	DEFINE cCodRetErr				CHAR(5);
	DEFINE bInicia					BOOLEAN;
	DEFINE iTransaccion				INTEGER;
	DEFINE cSucursal_bcpl			CHAR(4);
	DEFINE cCajero					CHAR(8);
	DEFINE cNumCte					CHAR(20);
	DEFINE dFecha					DATE;
	DEFINE dFecha_actual			DATE;
	DEFINE dFecha_actual_chq		DATE;
	DEFINE cCatCon					CHAR(5);
	DEFINE iContMov					INTEGER;
	DEFINE cRealizar_cargo			CHAR(1);
	DEFINE cEmpresa					CHAR(3);
	DEFINE cTrans_cargo				CHAR(4);
	DEFINE cTrans_suc				CHAR(4);	
	DEFINE cCuenta_cargo			CHAR(20);
	DEFINE deImpComisionConvenio	DECIMAL (6,2);
	DEFINE deIvaComisionConvenio	DECIMAL (6,2);
	DEFINE deImpComisionCliente		DECIMAL (6,2);
	DEFINE deIvaComisionCliente		DECIMAL (6,2);	
	DEFINE cCategoriaConvenio		CHAR(40);
	DEFINE cTrans_abono				CHAR(4);
	DEFINE cCta_prestadora			CHAR(20);
	DEFINE cRef_abono				CHAR(40);
	DEFINE cFolioTae				CHAR(9);	
	DEFINE cLaborable				CHAR(1);

	--INICIAR VARIABLES
	LET iSqlErr                 = 0;
	LET iIsamErr                = 0;
	LET cErrorInfo              = "";	
	LET cCodRet					= "00000";
	LET cMensaje                = "Exitoso";
	LET cFolioSuc				= NVL(pFolio_peracion, "");
	LET cCons_sdo1              = "";
	LET cCons_sdo2              = "";
	LET cCons_sdo3              = "";
	LET cCons_sdo4              = "";
	LET cCons_sdo5              = "";
	LET cCons_sdo6              = "";
	LET cCons_sdo7              = "";
	LET cCons_sdo8              = "";
	LET cCons_sdo9              = "";
	LET mCons_sdo10             = 0;
	LET mCons_sdo11             = 0;
	LET mCons_sdo12             = 0;
	LET mCons_sdo13             = 0;
	LET mCons_sdo14             = 0;
	LET cCons_sdo15             = "";
	LET cCons_sdo16             = "";
	LET cCons_sdo17             = "";
	LET mCons_sdo18             = 0;
	LET mCons_sdo19             = 0;
	LET mCons_sdo20             = 0;
	LET cCons_sdo21             = "";
	LET dCons_sdo22             = "";
	LET cCons_sdo23             = "";
	LET cCons_sdo24             = "";	
	LET cTranret                = "";
	LET dFechoy                 = "";
	LET mSdodisp                = 0;
	LET mMontoret               = 0;
	LET cCodRetErr				= "00000";
	LET bInicia                 = "F";
	LET iTransaccion            = 0;
	LET cSucursal_bcpl          = "";
	LET cCajero                 = "";
	LET cNumCte                 = "";
	LET dFecha                  = mdy(SUBSTR(pFecha,5,2),SUBSTR(pFecha,7,2),SUBSTR(pFecha,1,4));
	LET dFecha_actual           = "";
	LET dFecha_actual_chq       = "";	
	LET cCatCon                 = "";
	LET iContMov                = 0;
	LET cRealizar_cargo 		= UPPER(NVL(pRealizar_cargo, "N"));
	LET cEmpresa                = "001";
	LET cTrans_cargo            = "";
	LET cTrans_suc              = "";	
	LET cCuenta_cargo			= "";
	LET deImpComisionConvenio	= 0;
	LET deIvaComisionConvenio	= 0;
	LET deImpComisionCliente    = 0;
	LET deIvaComisionCliente    = 0;	
	LET cCategoriaConvenio		= "";
	LET cTrans_abono            = "";
	LET cCta_prestadora			= "";
	LET cRef_abono				= "";
	LET cFolioTae				= "";
	LET cLaborable				= "";
	
	BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
            IF  iSqlErr != 0 THEN
                --SET DEBUG FILE TO "/home/e90034397/trace/sp_aplica_pago_con_cargo_msw_err.txt";
                --TRACE ON;
                LET cCodRet    = iSqlErr;                
                LET cMensaje = 'Error:sp_aplica_pago_con_cargo_msw';

				IF bInicia = "T" THEN
					ROLLBACK WORK;
                END IF;

				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cErrorInfo, "sp_aplica_pago_con_cargo_msw");

                IF bInicia = "T" AND iTransaccion = 1 THEN
                    BEGIN WORK;
                END IF;

                RETURN cCodRet, cMensaje, cFolioSuc;
            END IF;
        END EXCEPTION;

        ON EXCEPTION IN (-535)
            LET iTransaccion = 1;
        END EXCEPTION WITH resume;
		        
        --SET DEBUG FILE TO "/home/e90034397/trace/sp_aplica_pago_con_cargo_msw.txt";
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		--VALIDACION PARAMETROS DE ENTRADA
		IF NVL(pOrigen, "") = "" OR NVL(pTransaccion, "") = "" OR NVL(pCategoria, "") = "" OR NVL(pConvenio, "") = "" OR NVL(pSucursal_tienda, "") = "" OR 
			NVL(pCajero, "") = "" OR NVL(pImporte, "") = "" OR NVL(pfecha, "") = "" OR NVL(dfecha, "") = "" OR NVL(pFolio_peracion, "") = "" OR 
			NVL(pReferencia_1, "") = "" OR NVL(pReferencia_2, "") = "" OR NVL(pCuenta_cargo, "") = "" THEN
			LET cCodRet = "00300";
			LET cMensaje = 'Parametro entrada vacio';
			LET cFolioSuc = pFolio_peracion;
            RETURN cCodRet, cMensaje, cFolioSuc;
		END IF;

		--VALIDA QUE EL CANAL SEA DESDE LA BEX
		IF UPPER(pOrigen) <> "BEX" THEN
			LET cCodRet = "00302";
			LET cMensaje = 'Origen Desconocido';
			LET cFolioSuc = pFolio_peracion;
            RETURN cCodRet, cMensaje, cFolioSuc;
		END IF;

		--OBTIENE LA SUCURSAL DE BANCOPPEL
		SELECT valor
		INTO cSucursal_bcpl
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '9997';

		--OBTIENE LA FECHA ACTUAL
		SELECT fecha_hoy
		INTO dFecha_actual
		FROM bdisac:"informix".sac_fechas
		WHERE empresa = cEmpresa;

		--OBTIENE LA FECHA ACTUAL DE CAPTACION
        SELECT fecha_hoy
		INTO dFecha_actual_chq
		FROM bdicheq:"informix".sc_fechas
		WHERE empresa = cEmpresa;
	
	
		SELECT Laborable
		INTO cLaborable
		FROM bdinteg:"informix".si_feriado
		WHERE empresa = cEmpresa AND pais = "001" AND fecha = dFecha;
		
		
		IF NVL(cLaborable,"S") = "N" THEN
			LET dfecha = dfecha + 1;
		END IF;
		
		IF dFecha <> dFecha_actual OR dFecha <> dFecha_actual_chq THEN
			LET cCodRet = "00301";
			LET cMensaje = 'Error:Actualizar fecha';
			LET cFolioSuc = pFolio_peracion;
            RETURN cCodRet, cMensaje, cFolioSuc;
		END IF;

		--OBTIENE EL CATEGORIA Y CONVENIO		
		SELECT (numcategoria || numconvenio)		 
		INTO cCatCon
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = pCategoria
			AND numconvenio = pConvenio
			AND statusconvenio ='A';
		
		IF NVL(pFormapago, "") <> "2" OR NVL(cCatCon,"") = "" OR cRealizar_cargo <> "S" THEN
			LET cCodRet = "00304";
			LET cMensaje = 'Parametro entrada valor incorrecto';
			LET cFolioSuc = pFolio_peracion;
			RETURN cCodRet, cMensaje, cFolioSuc;
		END IF;

        --VALIDA QUE EL FOLIO VENGA DEL MOTOR
        IF LENGTH(TRIM(pFolio_peracion)) <> 7 THEN
            LET cCodRet = "00308";
            LET cMensaje = 'Longitud de folio invalida';
            LET cFolioSuc = pFolio_peracion;
            RETURN cCodRet, cMensaje, cFolioSuc;
        END IF;

        --OBTIENE NUMERO DE CLIENTE DE LA CUENTA EJE
        SELECT TRIM(num_cte)
        INTO   cNumCte
        FROM bdicheq:"informix".sc_maechq 
        WHERE  cuenta = pCuenta_cargo;

        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "00309";
            LET cMensaje = 'Cuenta eje invalida';
            LET cFolioSuc = pFolio_peracion;
            RETURN cCodRet, cMensaje, cFolioSuc;
        END IF;

        LET cFolioSuc = TRIM(cNumCte) || TRIM(pFolio_peracion);

        SELECT COUNT(*) 
        INTO iContMov
        FROM bdisac:"informix".sac_movimientos
        WHERE id_sucursal = pSucursal_tienda
            AND origen = pOrigen  
            AND referencia1 = pReferencia_1
            AND fecha_pago = dFecha
            AND caja_cpl = pCaja
            AND folio_operacion = cFolioSuc;
        
        --VALIDA SI EL MOVIMIENTO ESTA DUPLICADO
        IF iContMov > 0 THEN
            LET cCodRet = "00303";
            LET cMensaje = 'Folio operacion duplicado';
            LET cFolioSuc = pFolio_peracion;
            RETURN cCodRet, cMensaje, cFolioSuc;
        END IF;

        SELECT FIRST 1 cuenta 
        INTO cCuenta_cargo 
        FROM bdicheq:"informix".sc_movdia 
        WHERE folio_suc = cFolioSuc;

        --VALIDA SI EXISTE CARGO A LA CUENTA CON PROCESO DE CARGO ACTIVO
        IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
            LET cCodRet = "00306";
            LET cMensaje = 'Intento de cargo duplicado';
            LET cFolioSuc = pFolio_peracion;
            RETURN cCodRet, cMensaje, cFolioSuc;
        END IF;

        SELECT trans_cargo_cliente, trans_suc_efectivo, trans_cen_abono_convenio, cuenta_prestadora, imp_com_trans_conv, iva_convenio
        INTO cTrans_cargo, cTrans_suc, cTrans_abono, cCta_prestadora, deImpComisionConvenio, deIvaComisionConvenio
        FROM bdisac:"informix".sac_control_convenios_canales
        WHERE numcategoria = pCategoria
            AND numconvenio = pConvenio
            AND canal = pOrigen;
        
        IF iTransaccion = 1 THEN
            COMMIT WORK;
        END IF;

        BEGIN WORK;
        LET bInicia = "T";

        --VALIDA EL SALDO DISPONIBLE DE LA CUENTA EJE
        EXECUTE PROCEDURE bdicheq:"informix".cons_sdos1(cEmpresa,pCuenta_cargo,'')
        INTO cCons_sdo1,cCons_sdo2,cCons_sdo3,cCons_sdo4,cCons_sdo5,cCons_sdo6,cCons_sdo7,cCons_sdo8,cCons_sdo9,mCons_sdo10,mCons_sdo11,mCons_sdo12,mCons_sdo13,mCons_sdo14,cCons_sdo15,cCons_sdo16,cCons_sdo17,mCons_sdo18,mCons_sdo19,mCons_sdo20,cCons_sdo21,dCons_sdo22,cCons_sdo23,cCons_sdo24;

        IF (pImporte > mCons_sdo10) THEN
            LET cCodRet = "00305";
            LET cMensaje = 'Cuenta insuficiente de saldo';
            LET cFolioSuc = pFolio_peracion;
            RETURN cCodRet, cMensaje, cFolioSuc;
        END IF;

        --SE INVOCA EL PROCESO DE CARGO
        EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(cEmpresa,           -- empresa
                                            pSucursal_tienda,   -- sucursal
                                            pCajero,            -- usuario
                                            cTrans_cargo,       -- transaccion central
                                            cTrans_suc,         -- transaccion sucursal
                                            cFolioSuc,          -- folio
                                            pCuenta_cargo,      -- cuenta
                                            0,                  -- cheque
                                            pImporte,           -- monto transaccion
                                            "01",               -- divisa
                                            pReferencia_2,      -- referencia
                                            " ",                -- no. tarjeta
                                            " ")                -- usuario autoriza
        INTO cCodRet, cTranret, dFechoy, mSdodisp, mMontoret;

        --VALIDA FALLO EN EL CARGO A LA CUENTA
        IF cCodRet <> "000" THEN
            ROLLBACK WORK;

			LET cCodRetErr = cCodRet;

            --REVERSO DE FOLIO_OPERACION
            EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, pSucursal_tienda, pCajero, cFolioSuc, '')
            INTO cCodRet;

            LET cMensaje = cCodRetErr || ':Reversion (cargo_ref)';

            IF cCodRet = "000" THEN
                LET cCodRet = "00320";
                LET cMensaje = cCodRetErr || ':Reversado (cargo_ref)';
            END IF;

            LET bInicia = "F";				

            IF iTransaccion = 1 THEN
                BEGIN WORK;
            END IF;

            RETURN cCodRet, cMensaje, cFolioSuc;
        END IF;

		SELECT FIRST 1 cuenta 
		INTO cCuenta_cargo 
		FROM bdicheq:"informix".sc_movdia 
		WHERE folio_suc = cFolioSuc;
		
		--VALIDA SI SE REALIZO EL CARGO
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			ROLLBACK WORK;

			--REVERSO DE FOLIO_OPERACION
			EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, pSucursal_tienda, pCajero, cFolioSuc, '')
			INTO cCodRet;

			LET cMensaje = 'Error:Reversion (cargo_ref)';

			IF cCodRet = "000" THEN
				LET cCodRet = "00320";
				LET cMensaje = 'Error:Reversado (cargo_ref)';
			END IF;

			LET bInicia = "F";

			IF iTransaccion = 1 THEN
				BEGIN WORK;
			END IF;

			RETURN cCodRet, cMensaje, cFolioSuc;
		END IF;

		LET deIvaComisionConvenio = round (deImpComisionConvenio * (deIvaComisionConvenio/100),2);

		EXECUTE PROCEDURE bdisac:"informix".sp_grabapagoservicio_hs(pSucursal_tienda, pCategoria, pConvenio, pReferencia_1, pReferencia_2, pFormapago, pImporte, deImpComisionConvenio,
			deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente, cCuenta_cargo, pCajero, cFolioSuc, cTrans_abono, dFecha, pOrigen, pSucursal_tienda, pCaja, pTransaccion, pHora, 
			cFolioSuc, pReferencia_3, pReferencia_4)
		INTO cCodRet;

		--VALIDA EL GUARDADO PAGO DE SERVICIO
		IF cCodRet <> "00000" THEN
			ROLLBACK WORK;

			LET cCodRetErr = cCodRet;

			--REVERSO DE FOLIO_OPERACION
			EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, pSucursal_tienda, pCajero, cFolioSuc, '')
			INTO cCodRet;

			LET cMensaje = cCodRetErr || ':Reversion (grabapago)';

			IF cCodRet = "000" THEN
				LET cCodRet = "00320";
				LET cMensaje = cCodRetErr || ':Reversado (grabapago)';
			END IF;

			LET bInicia = "F";

			IF iTransaccion = 1 THEN
				BEGIN WORK;
			END IF;

			RETURN cCodRet, cMensaje, cFolioSuc;
		END IF;

		IF pCategoria = '03' THEN
			LET cCategoriaConvenio = 'TA_'||pCategoria||pConvenio||'_';
		ELSE 
			LET cCategoriaConvenio = 'PS_'||pCategoria||pConvenio||'_';
		END IF;

		LET cRef_abono = TRIM(cCategoriaConvenio)||TRIM(cFolioSuc)||'_'||TRIM(pReferencia_4);

		EXECUTE PROCEDURE bdicheq:"informix".abono_ref(cEmpresa, 			-- empresa
											pSucursal_tienda, 	-- sucursal
											pCajero, 			-- usuario
											cTrans_abono,		-- transaccion
											cTrans_abono,		-- transacc suc
											cFolioSuc,          -- folio
											cCta_prestadora,	-- cuenta
											0, 					-- cheque
											pImporte, 			-- monto
											pImporte, 			-- monto firme
											0, 					-- monto sbc
											0, 					-- monto rem
											0, 					-- dias ret
											'01',				-- divisa
											cRef_abono,			-- referencia
											'',					-- num tarjeta
											'')					-- autoriza
		INTO cCodRet;

		--VALIDA EL SI SE REALIZO EL ABONO
		IF cCodRet = "000" THEN
            LET cCodRet = "00000";
            LET cMensaje = 'Exitoso';
        ELSE
			ROLLBACK WORK;

			LET cCodRetErr = cCodRet;

			--REVERSO DE FOLIO_OPERACION
			EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, pSucursal_tienda, pCajero, cFolioSuc, '')
			INTO cCodRet;

			LET cMensaje = cCodRetErr || ':Reversion (abono_ref)';

			IF cCodRet = "000" THEN
				LET cCodRet = "00320";
				LET cMensaje = cCodRetErr || ':Reversado (abono_ref)';
			END IF;

			LET bInicia = "F";

			IF iTransaccion = 1 THEN
				BEGIN WORK;
			END IF;

			RETURN cCodRet, cMensaje, cFolioSuc;
		END IF;

		IF TRIM(pCategoria) = "03" AND TRIM(pConvenio) = "001" THEN
			EXECUTE PROCEDURE bdisac:"informix".sp_obtienefolio_tae()
			INTO cCodRet, cFolioTae;

			LET cMensaje = TRIM(cMensaje)||'|'||TRIM(cFolioTae);
			
			--VALIDA LA OBTENCION DEL FOLIO PARA TAE
			IF cCodRet <> "00000" THEN
				ROLLBACK WORK;

				LET cCodRetErr = cCodRet;

				--REVERSO DE FOLIO_OPERACION
				EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, pSucursal_tienda, pCajero, cFolioSuc, '')
				INTO cCodRet;

				LET cMensaje = cCodRetErr || ':Reversion (folio_tae)';

				IF cCodRet = "000" THEN
					LET cCodRet = "00320";
					LET cMensaje = cCodRetErr || ':Reversado (folio_tae)';
				END IF;

				LET bInicia = "F";

				IF iTransaccion = 1 THEN
					BEGIN WORK;
				END IF;

				RETURN cCodRet, cMensaje, cFolioSuc;
		
			END IF;
		END IF;

		COMMIT WORK;

        IF iTransaccion = 1 THEN
            BEGIN WORK;
        END IF;

		RETURN cCodRet, cMensaje, cFolioSuc;
	END;
END PROCEDURE
DOCUMENT
'FOLIO: INICIATIVA - PAGO TAE COPPEL.',
'MODIFICACION: SE CREA PROCEDIMIENTO PARA APLICAR EL CARGO Y ABONO DE TAE.',
'AUTOR: 90034397 - BRANDO GARCIA. / 90155378 - JORGE RIVAS.',
'FECHA: 18/05/2023',
'BD: BDISAC',
'FOLIO: INICIATIVA - PAGO TAE COPPEL.',
'MODIFICACION: SE MODIFICA PARA CONSIDERAR EL DIA NO LABORABLE.',
'AUTOR: 90034397 - BRANDO GARCIA. / 90155378 - JORGE RIVAS.',
'FECHA: 25/12/2023',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_grabapagocoppel_td(tipo_ejecucion SMALLINT, 
												  vFolio_abono_td CHAR(40), 
												  vSubfolio INTEGER, 
												  vSucursal SMALLINT, 
												  vCliente INTEGER,
												  vTienda INTEGER,
												  vSecuencia SMALLINT,
												  vTipo_cuenta SMALLINT,
												  vCartera CHAR(40),
												  vImporte INTEGER,
												  vFactura INTEGER,
												  vFecha_abono DATE
												  )

RETURNING CHAR(5);


    DEFINE cCodRet     CHAR(5);
    DEFINE iSqlErr     INTEGER;
    DEFINE iIsamErr    INTEGER;
	DEFINE cInfoErr    CHAR(100);

	DEFINE CdRetVerSis CHAR (5);
	DEFINE IndCrreCred CHAR (1);
	DEFINE IndDispCred CHAR (1);
	DEFINE IndCrreChqs CHAR (1);
	DEFINE IndDispChqs CHAR (1);
	DEFINE IndCrreInvs CHAR (1);
	DEFINE IndDispInvs CHAR (1);
	DEFINE IndCrreSrvs CHAR (1);

	LET CdRetVerSis		= '';
	LET IndCrreCred 	= '';
	LET IndDispCred 	= '';
	LET IndCrreChqs 	= '';
	LET IndDispChqs 	= '';
	LET IndCrreInvs 	= '';
	LET IndDispInvs 	= '';
	LET IndCrreSrvs 	= '';

   	--SET DEBUG FILE TO '/informix/luisBeltran/BDISAC/pagocoppel.out';
   	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;		
	SET LOCK MODE TO WAIT 3; 


    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_GrabaPagoCoppel");
                    RETURN cCodRet;
                END IF;
        END EXCEPTION;


	EXECUTE FUNCTION bdinteg:verifica_sistemas() -- Se validan cierres de los sistemas antes de iniciar proceso de PGPROG:
	INTO CdRetVerSis, IndCrreCred, IndDispCred, IndCrreChqs, IndDispChqs, IndCrreInvs, IndDispInvs, IndCrreSrvs;
		
		if IndCrreSrvs <> '1'
			then
				LET cCodRet = '00060';
				LET iSqlErr = 0;
				LET iIsamErr = 0;
				LET cInfoErr = 'Sistema Servicios No Disponible.';
                EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_GrabaPagoCoppel");
                RETURN cCodRet;
			else
		end if;
		

        LET cCodRet = '00000';
		IF(tipo_ejecucion = 1) THEN
		  IF vFolio_abono_td <> '' AND vCliente <> 0  AND vSucursal <> 0 AND vCartera <> '' AND vImporte <> 0 AND vFecha_abono IS NOT NULL THEN -- AND vCliente <> 0 AND vSucursal <> 0 AND vCartera <> '' AND vImporte <> 0 AND vFecha_abono <> '' THEN
            
			INSERT INTO sac_movimientos_detalle_td (folio_abono,subfolio,cliente,sucursal,tienda,secuencia,tipo_cuenta,cartera,importe,factura,status_coppel,fecha_abono,fecha_insert)
            VALUES(vFolio_abono_td,'',vCliente,vSucursal,vTienda,vSecuencia,vTipo_cuenta,vCartera,vImporte,vFactura,'0',vFecha_abono,CURRENT);
			LET cCodRet = '00000';
			
			ELSE
				LET cCodRet = '00002';
			END IF;
		ELIF  (tipo_ejecucion = 2) THEN
			IF EXISTS(SELECT 1 FROM sac_movimientos_detalle_td WHERE folio_abono = vFolio_abono_td AND cliente = vCliente AND sucursal=vSucursal) THEN
				UPDATE  sac_movimientos_detalle_td  SET subfolio = vSubfolio , status_coppel = '1' WHERE  folio_abono = vFolio_abono_td AND cliente = vCliente AND sucursal=vSucursal;
				LET cCodRet = '00000';
				ELSE
				LET cCodRet = '00001';
			
			END IF;
			
		
		ELIF  (tipo_ejecucion < 0 OR tipo_ejecucion >2) THEN
            LET cCodRet = '00004';
		
        END IF;
        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Luis Alberto Beltran Rodriguez',
'DESCRIPCION: Se encarga de guardar en tablas el detalle de los movimientos generados por Coppel al aplicar abonos en cartera',
'FECHA : 29 - Noviembre - 2021',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_app_recuperapayment(pRegs_recup 		INTEGER,
												   pUsuario 		CHAR(15),
												   pFecha_peticion 	CHAR(8),
												   pHora_peticion 	CHAR(6))
												   
--DATOS A REGRESAR---
RETURNING 	
			CHAR(5)  AS cCodRet , 
			CHAR(50) AS Descripcion ,
			CHAR(16) AS UniqueReferenceNumber , 
			CHAR(30) AS ReferenceNumber ,
			CHAR(3)  AS ProcessReasonTypeCode,
			CHAR(3)  AS Code ,
			CHAR(3)  AS ChannelId	,
			CHAR(20) AS TaxIdentificationNumber, 
			CHAR(15) AS cLocationUnit ,
			CHAR(15) AS Number, 
			CHAR(3)  AS TypeCode , 
			CHAR(3)  AS CountryCode	,
			CHAR(3)  AS StateCode, 
			CHAR(20) AS UserId ,
			CHAR(20) AS SupervisorId , 
			CHAR(15) AS TerminalId	, 
			CHAR(8)  AS ProcessDate ,
			CHAR(6)  AS ProcessTime;

--DEFINICION DE VARIABLES--
DEFINE cCodRet 				       CHAR(5);
DEFINE cUniqueReferenceNumber      CHAR(16);
DEFINE cCode                       CHAR(3);
DEFINE cChannelId                  CHAR(3);
DEFINE cTaxIdentificationNumber    CHAR(20);
DEFINE cTypeCode                   CHAR(3);
DEFINE cCountryCode	               CHAR(3);
DEFINE cNombreSPL   			   CHAR(30);
DEFINE cCadena_ent        		   CHAR(100);
DEFINE iSqlErr 					   INTEGER;
DEFINE iIsamErr 				   INTEGER;
DEFINE cValocUn 				   CHAR(100);
DEFINE cCoutrycod				   CHAR(100);
DEFINE cValNum 					   CHAR(100);
DEFINE cValStaCod         		   CHAR (100);
DEFINE cValUseId     			   CHAR(100);
DEFINE cTaxIdentifNumber 		   CHAR(100);
DEFINE cTermine 				   CHAR(200);
DEFINE cCodRet2                    CHAR(5);
DEFINE cHoraInsert	   		   	   CHAR(6);
DEFINE cTypeCod 				   char(100);
DEFINE cParam					   CHAR(100);
DEFINE cValor       		       CHAR(100);
DEFINE cAgnt_branch_sd 			   CHAR(100);
DEFINE cAgnt_termina 			   CHAR(100);
DEFINE cProcessDateDetail 		   CHAR(8);
DEFINE cProcessTimeDetail 		   CHAR (6);
DEFINE cEstatus_dsp 		       CHAR(3);
DEFINE cBank_ref_nm			       CHAR(20);
DEFINE cBank_concept1		       CHAR(40);
DEFINE iIntentos 				   INTEGER;
DEFINE cDescripcion				   CHAR(255);
DEFINE cOpCode					   CHAR(4);
DEFINE cValCod    				   CHAR(100);
DEFINE cChannelId_2                CHAR(3);
DEFINE iRemesas					   INTEGER;
DEFINE vChannelid				   CHAR(3);
DEFINE vHora					   INTEGER;
DEFINE cNum_confirmacion		   CHAR(12);
DEFINE cEstatus_sdep			   CHAR(2);



--INICIALIZACION DE VARIABLES--												   
LET cCodRet = '00000';
LET cUniqueReferenceNumber= '';
LET cCode = ''; 
LET cChannelId= '';
LET cTaxIdentificationNumber = '';
LET cTypeCode = ''; 
LET cCountryCode	= '';
LET cNombreSPL = 'sp_app_recuperapayment';
LET cCadena_ent			 = TRIM(NVL(pRegs_Recup,'NULL'))||'|'||TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pFecha_Peticion,'NULL'))||'|'||TRIM(NVL(pHora_Peticion,'NULL'));
LET iSqlErr 			 = 0;
LET iIsamErr			 = 0;
LET cValocUn = '';
LET cCoutrycod = '';
LET cValNum = '';
LET cValStaCod = '';
LET cValUseId = '';
LET cTaxIdentifNumber = '';
LET cTermine ='';
LET cCodRet2 = '';
LET cHoraInsert   = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cTypeCod = '';
LET cParam = '';
LET cValor = '';
LET cAgnt_branch_sd = '';
LET cAgnt_termina = '';
LET cProcessDateDetail = '';
LET cEstatus_dsp = '';
LET cBank_ref_nm= '';
LET cBank_concept1 = '';
LET iIntentos = 0;
LET cDescripcion = '';
LET cOpCode = '';
LET cValCod = '';
LET cChannelId_2 = '';
LET iRemesas = 0;
LET vChannelid = '';
LET vHora = 0;
LET cNum_confirmacion = '';
LET cEstatus_sdep = '';


--	SET DEBUG FILE TO '/informix/adrian/sp_app_recuperapayment.out';
--	TRACE ON;


BEGIN
	ON EXCEPTION
		SET iSqlErr,iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombreSPL, cCodRet, '',iSqlErr,iIsamErr, cCadena_ent,pUsuario,pFecha_Peticion,pHora_Peticion)
			INTO cCodRet2;
			RETURN LPAD(cCodRet,5,'0'),'','','','','','','','','','','','','','','','','';
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	--Validacion status 12
	
	SELECT COUNT(*)
	INTO iRemesas
	FROM bdisac:"informix".sac_app_getorder
	WHERE estatus_getorder IN ('12')
	AND fecha_insert >=TODAY
	AND replace(SUBSTR(TRIM((CURRENT -fecha_insert)::CHAR(30)),3,12),':','')::INTEGER>200;
	
	IF iRemesas >= 1 THEN
	
		DROP TABLE IF EXISTS sac_app_pemporal2;
		SELECT MIN(channelid) channelid, 
		MIN(REPLACE(SUBSTR(TRIM((CURRENT -fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) hora,
		estatus_getorder,
		NVL(uniquereferencenumber,'') AS uniquereferencenumber
		FROM bdisac:"informix".sac_app_getorder
		WHERE estatus_getorder IN ('12')
		AND fecha_insert >=TODAY
		AND replace(SUBSTR(TRIM((CURRENT -fecha_insert)::CHAR(30)),3,12),':','')::INTEGER>200
		GROUP BY 3,4
		INTO TEMP sac_app_pemporal2 WITH NO LOG;
		
		FOREACH WITH HOLD SELECT channelid, hora, estatus_getorder, uniquereferencenumber INTO vChannelid, vHora, cEstatus_sdep, cNum_confirmacion FROM sac_app_pemporal2
		
				IF TRIM(cEstatus_sdep) ='12' THEN
		
				--SI ESTATUS 12 AND DEBITADO THEN ESTATUS 03, INTENTOS_ENVIO= 0 WHERE CHANNELID=MIN(CHANNELID)
		
					IF EXISTS (SELECT C.folio_suc FROM 
									(SELECT distinct SD.folio_suc FROM bdicheq:sc_movdia SD, sac_movimientos MH 
										WHERE SD.folio_suc=MH.folio_suc and fech_alt = TODAY and referencia1 = TRIM(cNum_confirmacion) and cancelad <> 'S' --and status_cancelado <> 'S'
									    UNION ALL 
									    SELECT distinct SD.folio_suc FROM bdicred:sd_movdia SD, sac_movimientos MH 
										WHERE SD.folio_suc=MH.folio_suc and fecha_mov = TODAY and referencia1 = TRIM(cNum_confirmacion) and reversado <> 'S' --and status_cancelado <> 'S'
									 ) C
								) THEN
		
						UPDATE sac_app_getorder SET estatus_getorder='03' 
						WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 
						AND channelid = vChannelid
						--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT - fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) = vHora
						;
		
						EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(0, 0, 'Actualiza Estatus RemAPP: ' || TRIM(cNum_confirmacion) || ' de ' || TRIM(cEstatus_sdep) || ' a 03', 'sp_app_confirmpayment');
		
						UPDATE sac_app_getorder SET estatus_getorder='09'
						WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 
						AND channelid <> vChannelid
						--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT - fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) <> vHora
						;
		
					ELSE
						--SI ESTATUS 12 AND REVERSADO THEN ESTATUS 04, INTENTOS_ENVIO= 0 WHERE CHANNELID=MIN(CHANNELID)
		
							IF EXISTS (SELECT C.folio_suc FROM 
										(SELECT distinct SD.folio_suc FROM bdicheq:sc_movdia SD, sac_movimientos MH 
											WHERE SD.folio_suc=MH.folio_suc and fech_alt = TODAY and referencia1 = TRIM(cNum_confirmacion) and cancelad <> 'S' --and status_cancelado <> 'S'
										    UNION ALL 
										    SELECT distinct SD.folio_suc FROM bdicred:sd_movdia SD, sac_movimientos MH 
											WHERE SD.folio_suc=MH.folio_suc and fecha_mov = TODAY and referencia1 = TRIM(cNum_confirmacion) and reversado <> 'S' --and status_cancelado <> 'S'
										    UNION ALL
										    SELECT numconfirmacion FROM sac_remesaslimitepld_app WHERE fecha >= TODAY AND numconfirmacion = TRIM(cNum_confirmacion)
										) C,
										(SELECT estatus_getorder FROM sac_app_getorder WHERE uniquereferencenumber = TRIM(cNum_confirmacion)) A
										) THEN
		
								UPDATE sac_app_getorder SET estatus_getorder='04' 
								WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 
								AND channelid = vChannelid
								--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT - fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) = vHora
								;
		
								EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(0, 0, 'Actualiza Estatus RemAPP: ' || TRIM(cNum_confirmacion) || ' de ' || TRIM(cEstatus_sdep) || ' a 04', 'sp_app_confirmpayment');
		
								UPDATE sac_app_getorder SET estatus_getorder='09' 
								WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 
								AND channelid <> vChannelid
								--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT - fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) <> vHora
								;
		
		
							END IF;
		
					END IF;
		
				END IF;
		
		END FOREACH;
	
	END IF;
	
	--Fin validacion status 12
	
	--INSERT INTO bdisac:"informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	--VALUES (cNombreSPL,pFecha_Peticion,pHora_Peticion,'0',cCodRet,pUsuario,current::date,cHoraInsert);
	
	-- Validamos que los paramtros de entrada no vengan vacios	
	IF pRegs_Recup > 0 THEN

				SELECT NVL(valor,'0')
				INTO cValor
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87013';

				
				SELECT NVL(valor,'0')
				INTO cValCod
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87102';
				
				--LocationUnit , 87104   
				SELECT NVL(valor,'0')
				INTO cValocUn
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87104';
				
				-- TypeCode
				SELECT NVL(valor,'0')
				INTO cTypeCod
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87105';
				
				--CountryCode
				SELECT NVL(valor,'0')
				INTO cCoutrycod
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87106';
				
				--Number
				SELECT valor
				INTO cValNum
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87112';
				
				--TaxIdentificationNumber
				SELECT NVL(valor,'0')
				INTO cTaxIdentifNumber
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87113';
								
				--StateCode 87114
				SELECT valor
				INTO cValStaCod
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87114';
				
				--UserId , 87115 
				SELECT valor
				INTO cValUseId
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87115';
				
				-- num categoria num convenio
				SELECT NVL(valor,'0')
				INTO cParam
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87116';
				
				--TERMINELID 112 y 115
				LET cTermine = TRIM(cValNum) || TRIM(cValUseId);
				
				IF pHora_Peticion > '210000' THEN
					IF NOT EXISTS (SELECT fecha_proceso FROM bdisac:"informix".sac_ws_procesos WHERE proceso = 'recupera_findedia' AND fecha_insert = current::date) THEN
						INSERT INTO bdisac:"informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
							VALUES ('recupera_findedia',pFecha_Peticion,pHora_Peticion,'0',cCodRet,pUsuario,current::date,cHoraInsert);
						LET cValor = '100'; -- Para recuperar todas las remesas pendientes de enviar
					END IF;
				END IF;


				SELECT valor
					INTO cAgnt_branch_sd
					FROM bdisac:"informix".sac_param
					WHERE cod_param = '87015';

				SELECT valor
					INTO cAgnt_termina
					FROM bdisac:"informix".sac_param
					WHERE cod_param = '87016';
					
				lET cChannelId_2 = SUBSTR (pUsuario,9,3);
		        LET pUsuario     = SUBSTR (pUsuario,1,7);
				
				FOREACH
					SELECT  LIMIT pRegs_Recup
					a.UniqueReferenceNumber,
					a.CountryCode,
					a.ProcessDateDetail,
					a.ProcessTimeDetail,
					a.Code,
					a.ChannelId,
					a.TaxIdentificationNumber,
					a.TypeCode,
					NVL(a.intentos_envio,0),
					DECODE(estatus_getorder,'03','','04','IAC') AS cEstatus_dsp 
					INTO cUniqueReferenceNumber,cCountryCode,cProcessDateDetail,
						 cProcessTimeDetail,cCode,cChannelId,cTaxIdentificationNumber,cTypeCode,iIntentos,cEstatus_dsp
					FROM bdisac:"informix".sac_app_getorder a
					WHERE a.estatus_getorder IN('03','04')
					AND a.intentos_envio <= cValor
					AND a.ChannelId = cChannelId_2

					SELECT  b.folio_suc INTO cBank_ref_nm
					FROM bdisac:"informix".sac_movimientos b
					WHERE b.referencia1 = cUniqueReferenceNumber
					AND b.numcategoria = LPAD(SUBSTR(TRIM(cParam),2,1),2,'0')
					AND b.numconvenio = LPAD(SUBSTR(TRIM(cParam),3,2),3,'0')
					AND b.flag_confirmacion_central = '1'
					AND b.flag_confirmacion_sucursal = '1'
					AND b.status_cancelado = 'N';
					
					--QUITAR AL FINAL SOLO SIRVE PARA VERIFICAR INFORMACION
					--let cAgnt_branch_sd =	NVL(iIntentos,0);

					
					LET cCadena_ent = TRIM(NVL(pRegs_Recup,'NULL'))||'|'||TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(cUniqueReferenceNumber,'NULL'))||'|'||TRIM(NVL(pFecha_Peticion,'NULL'))||'|'||TRIM(NVL(pHora_Peticion,'NULL'));

					IF TRIM(cBank_ref_nm)='' OR cBank_ref_nm IS NULL THEN
						LET cBank_ref_nm = '0000000000000000';
						LET cBank_concept1 = 'Remesa Rechazada: ' || cUniqueReferenceNumber;
					ELSE
						LET cBank_concept1 = 'Pago de Remesa: ' || cUniqueReferenceNumber;
					END IF;

					LET iIntentos = NVL(iIntentos,0) + 1;

					UPDATE bdisac:"informix".sac_app_getorder
					SET intentos_envio = iIntentos
					WHERE UniqueReferenceNumber = cUniqueReferenceNumber and estatus_getorder IN('03','04');

					UPDATE bdisac:"informix".sac_app_getorder
					SET estatus_getorder = '12'
					WHERE UniqueReferenceNumber = cUniqueReferenceNumber and estatus_getorder IN('03','04');

					LET cDescripcion = 'RecuperaciÃÂ³n CFPA exitosa';

					RETURN LPAD (cCodRet,5,'0'),cDescripcion,cUniqueReferenceNumber,cBank_ref_nm,cEstatus_dsp,cValCod,cChannelId,cTaxIdentifNumber,cValocUn,cValNum,cTypeCod,cCoutrycod,cValStaCod,cValUseId,'',cTermine,cProcessDateDetail,cProcessTimeDetail with resume; 


				END FOREACH;

				IF  DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '1100';
				END IF;
	ELSE
		LET cCodRet = '1100';
	END IF;

	IF cCodRet = '00000' THEN
		--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombreSPL, LPAD(cCodRet,5,'0'), cDescripcion,'','', cCadena_ent,pUsuario,pFecha_Peticion,pHora_Peticion)
		--INTO cCodRet2;
	ELSE
		SELECT NVL(opcode, ''),NVL(opcode_ds,'')
		INTO cOpCode,cDescripcion
		FROM bdisac:"informix".sac_app_cat_mensajes
		WHERE agent_trans_type_code = 'CFPA'
		AND opcode = cCodRet;

		IF cOpCode IS NULL THEN
			LET cDescripcion = 'CÃÂ³digo no registrado en catÃÂ¡logo.';
		END IF;

		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombreSPL, LPAD(cCodRet,5,'0'), cDescripcion,'','', cCadena_ent,pUsuario,pFecha_Peticion,pHora_Peticion)
		INTO cCodRet2;

		IF cCodRet2 <> '00000' THEN
			LET cCodRet = cCodRet2;
		END IF
		RETURN LPAD(cCodRet,5,'0'),NVL(cDescripcion,''),'','','','','','','','','','','','','','','','';
	END IF;
	
END;	
END PROCEDURE
DOCUMENT
"FOLIO: 230142-150, RQM 10 809 ? Pago de Remesas Appriza con abono automÃÂ¡tico en cuentas de captaciÃÂ³n",
"AUTOR : Viridiana Paredes Romero",
"FECHA : 15/11/2016",
"DESCRIPCION: Se crea stored procedure para consultar sac_app_getorder con estatus 03 y 04",
"BD: bdisac";

CREATE PROCEDURE "informix".sp_sacreportetotalporconvenios (cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE)
    -- DATOS A REGRESAR
    RETURNING
    CHAR(5)  AS retorno, --Codigo de Retorno
    INTEGER AS numpagos, 
	CHAR(40) AS nomconvenio, 
	MONEY(16,2) AS importe_pago, 
	MONEY(16,2) AS importe_comision_convenio, 
	MONEY(16,2) AS iva_comision_convenio, 
	MONEY(16,2) AS importe_comision_cte,
    MONEY(16,2) AS iva_comision_cte, 
	INTEGER AS flag_confirmacion_central, 
	INTEGER AS flag_confirmacion_sucursal;


    -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE cNumcategoria            CHAR(2);
	DEFINE cCategoria	            CHAR(2);
    DEFINE cNumconvenio             CHAR(3);
    DEFINE cNomconvenio             CHAR(40);
    DEFINE mImpComisionConvenio     MONEY(16,2);
    DEFINE mIVAComisionConvenio     MONEY(16,2);
    DEFINE mImpComisionCte          MONEY(16,2);
    DEFINE mIVAComisionCte          MONEY(16,2);
    DEFINE mImportePago             MONEY(16,2);
    DEFINE iConfirmacionCentral     INTEGER;
    DEFINE iConfirmacionSucursal    INTEGER;
    DEFINE iNumPagos                INTEGER;
    DEFINE mPcomision               DECIMAL;
    DEFINE mPiva                    INTEGER;
	
    	--SET DEBUG FILE TO "/tmp/sp_sacreportetotalporconvenios.out";
    	--TRACE ON;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet               = "00000";
    LET cNumcategoria         = SUBSTRING(cConvenio FROM 1 FOR 2);
    LET cNumconvenio          = SUBSTRING(cConvenio FROM 3 FOR 3);
    LET cNomConvenio          = "";
    LET mImportePago         = 0;
    LET mImpComisionConvenio = 0;
    LET mIVAComisionConvenio = 0;
    LET mImpComisionCte      = 0;
    LET mIVAComisionCte      = 0;
    LET iConfirmacionCentral  = 0;
    LET iConfirmacionSucursal = 0;
    LET iNumPagos             = 0;
    LET mPcomision            = 0;
    LET mPiva                 = 0;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
            END IF;
        END EXCEPTION;
        SET LOCK MODE TO WAIT 2;

        IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
                LET cCodRet = "00001";
                RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
        ELSE
            IF cConvenio = "00000" THEN      -- Todos los convenios
                IF cSucursal = "0000"  THEN   -- Todos los convenios y todas las sucursales
					SET ISOLATION TO DIRTY READ;
                    FOREACH
						SELECT TRIM(NVL(nomconvenio,'')), TRIM(NVL(numcategoria,'')), TRIM(NVL(numconvenio,'')),NVL(porc_com_trans_conv,0),NVL(iva_convenio,0)
						INTO cNomConvenio, cNumcategoria, cNumconvenio, mPcomision, mPiva
                        FROM bdisac:sac_convenios

						SET ISOLATION TO DIRTY READ;
                        IF cNumcategoria = "06" AND cNumconvenio="001" THEN
                            SELECT NVL(COUNT(referencia1),0), NVL(SUM(importe_pago),0),( NVL(SUM(importe_pago),0)*mPcomision)/100,
                                (((NVL(SUM(importe_pago),0)*mPcomision)/100)*mPiva)/100, NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0),
                                NVL(SUM(flag_confirmacion_central),0), NVL(SUM(flag_confirmacion_sucursal),0)
                            INTO iNumPagos, mImportePago,mImpComisionConvenio,mIVAComisionConvenio,mImpComisionCte,mIVAComisionCte,
                                iConfirmacionCentral, iConfirmacionSucursal
                            FROM bdisac:sac_movimientoshistorial
                            WHERE fecha_pago::DATE  >= dFechaIni AND fecha_pago::DATE  <= dFechaFin AND status_cancelado <> 'S' AND
                            numcategoria = cNumcategoria AND numconvenio = cNumconvenio 
                            AND flag_confirmacion_central = 1
                            AND flag_confirmacion_sucursal = 1;
                        
						ELSE

                            SELECT NVL(COUNT(referencia1),0), NVL(SUM(importe_pago),0), NVL(SUM(importe_comision_convenio),0),
                                NVL(SUM(iva_comision_convenio),0), NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0),
                                NVL(SUM(flag_confirmacion_central),0), NVL(SUM(flag_confirmacion_sucursal),0)
                            INTO iNumPagos, mImportePago,mImpComisionConvenio,mIVAComisionConvenio,mImpComisionCte,mIVAComisionCte,
                                iConfirmacionCentral, iConfirmacionSucursal
                            FROM bdisac:sac_movimientoshistorial
                            WHERE fecha_pago::DATE  >= dFechaIni AND fecha_pago::DATE  <= dFechaFin AND status_cancelado <> 'S' AND
                                numcategoria = cNumcategoria AND numconvenio = cNumconvenio
                            AND flag_confirmacion_central = 1
                            AND flag_confirmacion_sucursal = 1;
                        END IF;    

						RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte,
                                mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
                        WITH RESUME;
                    END FOREACH;
				ELSE   --Todos los convenios y una sucursal
					SET ISOLATION TO DIRTY READ;
					FOREACH
 						SELECT TRIM(NVL(nomconvenio,'')), TRIM(NVL(numcategoria,'')), TRIM(NVL(numconvenio,'')),NVL(porc_com_trans_conv,0),NVL(iva_convenio,0)
						INTO cNomConvenio, cNumcategoria, cNumconvenio, mPcomision, mPiva
                        FROM bdisac:sac_convenios

                        SET ISOLATION TO DIRTY READ;
                        IF cNumcategoria = "06" AND cNumconvenio="001" THEN
                            SELECT NVL(COUNT(referencia1),0), NVL(SUM(importe_pago),0),( NVL(SUM(importe_pago),0)*mPcomision)/100,
                                (((NVL(SUM(importe_pago),0)*mPcomision)/100)*mPiva)/100, NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0),
                                NVL(SUM(flag_confirmacion_central),0), NVL(SUM(flag_confirmacion_sucursal),0)
                            INTO iNumPagos, mImportePago,mImpComisionConvenio,mIVAComisionConvenio,mImpComisionCte,mIVAComisionCte,
                                iConfirmacionCentral, iConfirmacionSucursal
                            FROM bdisac:sac_movimientoshistorial
                            WHERE fecha_pago::DATE  >= dFechaIni AND fecha_pago::DATE  <= dFechaFin AND status_cancelado <> 'S' AND
                            numcategoria = cNumcategoria AND numconvenio = cNumconvenio AND id_sucursal = cSucursal 
                            AND flag_confirmacion_central = 1
                            AND flag_confirmacion_sucursal = 1;
							
						ELSE

                            SELECT NVL(COUNT(referencia1),0), NVL(SUM(importe_pago),0), NVL(SUM(importe_comision_convenio),0),
                                NVL(SUM(iva_comision_convenio),0), NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0),
                                NVL(SUM(flag_confirmacion_central),0), NVL(SUM(flag_confirmacion_sucursal),0)
                            INTO iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
                            FROM bdisac:sac_movimientoshistorial
                            WHERE fecha_pago::DATE >= dFechaIni AND fecha_pago::DATE  <= dFechaFin AND numcategoria = cNumcategoria AND
                                numconvenio = cNumConvenio AND id_sucursal = cSucursal AND status_cancelado <> 'S'
                            AND flag_confirmacion_central = 1
                            AND flag_confirmacion_sucursal = 1;
                        END IF;
						RETURN cCodRet, iNumPagos,  cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte,
							mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal WITH RESUME;
                        END FOREACH;
					END IF;
			ELSE -- Un convenio todas las sucursales (TIEMPO AIRE ELECTRONICO)
				    
				 IF cNumcategoria = "03" AND cNumconvenio= "001" THEN  --INICIA PROCESO PARA REPORTE DE TIEMPO AIRE
					 
					 IF cSucursal = "0000"  THEN   -- Todas las sucursales
					    SET ISOLATION TO DIRTY READ;
--					
 						   SELECT  TRIM(NVL(numcategoria,'')), TRIM(NVL(numconvenio,'')),NVL(porc_com_trans_conv,0),NVL(iva_convenio,0)
						   INTO  cNumcategoria, cNumconvenio, mPcomision, mPiva
                           FROM bdisac:sac_convenios
                           WHERE numcategoria = cNumcategoria AND numconvenio = cNumconvenio;


					    SET ISOLATION TO DIRTY READ;
                        
				        FOREACH
                            SELECT  NVL(COUNT(referencia1),0), TRIM(NVL(referencia2,'')), NVL(SUM(importe_pago),0),NVL(SUM(importe_comision_convenio),0),
                                    NVL(SUM(iva_comision_convenio),0), NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0),
                                    NVL(SUM(flag_confirmacion_central),0), NVL(SUM(flag_confirmacion_sucursal),0)
                            INTO iNumPagos,cNomConvenio, mImportePago,mImpComisionConvenio,mIVAComisionConvenio,mImpComisionCte,mIVAComisionCte,
                                iConfirmacionCentral, iConfirmacionSucursal
                            FROM bdisac:sac_movimientoshistorial
                            WHERE fecha_pago::DATE  >= dFechaIni AND fecha_pago::DATE  <= dFechaFin AND status_cancelado <> 'S' AND
                            numcategoria = cNumcategoria AND numconvenio = cNumconvenio 
                            AND flag_confirmacion_central = 1
                            AND flag_confirmacion_sucursal = 1
							GROUP BY referencia2
						
					         RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte,
						     mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal WITH RESUME;
				        END FOREACH;


                    ELSE --Tiempo aire electronico y Una sucursal

					
					SET ISOLATION TO DIRTY READ;
--					
 						SELECT  TRIM(NVL(numcategoria,'')), TRIM(NVL(numconvenio,'')),NVL(porc_com_trans_conv,0),NVL(iva_convenio,0)
						INTO  cNumcategoria, cNumconvenio, mPcomision, mPiva
                        FROM bdisac:sac_convenios
                        WHERE numcategoria = cNumcategoria AND numconvenio = cNumconvenio;


					SET ISOLATION TO DIRTY READ;
                        
				        FOREACH
                            SELECT  NVL(COUNT(referencia1),0), TRIM(NVL(referencia2,'')), NVL(SUM(importe_pago),0),NVL(SUM(importe_comision_convenio),0),
                                    NVL(SUM(iva_comision_convenio),0), NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0),
                                    NVL(SUM(flag_confirmacion_central),0), NVL(SUM(flag_confirmacion_sucursal),0)
							INTO iNumPagos,cNomConvenio, mImportePago,mImpComisionConvenio,mIVAComisionConvenio,mImpComisionCte,mIVAComisionCte,
                                iConfirmacionCentral, iConfirmacionSucursal
                            FROM bdisac:sac_movimientoshistorial
                            WHERE fecha_pago::DATE  >= dFechaIni AND fecha_pago::DATE  <= dFechaFin AND status_cancelado <> 'S' 
							AND numcategoria = cNumcategoria AND numconvenio = cNumconvenio 
							AND id_sucursal = cSucursal
                            AND flag_confirmacion_central = 1
                            AND flag_confirmacion_sucursal = 1
							GROUP BY referencia2
						
					         RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte,
						     mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal WITH RESUME;
				        END FOREACH;
                  
                     END IF; --- TERMINA PROCESO PARA TIEMPO AIRE ELECTRONICO
				
				
				ELSE --Cualquier convenio diferente a tiempo aire
				
			             IF cSucursal = "0000"  THEN   -- Un convenio y todas las sucursales
					     SET ISOLATION TO DIRTY READ;
--					     SELECT TRIM(NVL(nomconvenio,'')) INTO cNomConvenio FROM bdisac:sac_convenios
--					     WHERE numcategoria = cNumcategoria AND numconvenio = cNumconvenio;
 						SELECT TRIM(NVL(nomconvenio,'')), TRIM(NVL(numcategoria,'')), TRIM(NVL(numconvenio,'')),NVL(porc_com_trans_conv,0),NVL(iva_convenio,0)
						INTO cNomConvenio, cNumcategoria, cNumconvenio, mPcomision, mPiva
                        FROM bdisac:sac_convenios
                        WHERE numcategoria = cNumcategoria AND numconvenio = cNumconvenio;


					SET ISOLATION TO DIRTY READ;
                        IF cNumcategoria = "06" AND cNumconvenio="001" THEN
                            SELECT NVL(COUNT(referencia1),0), NVL(SUM(importe_pago),0),( NVL(SUM(importe_pago),0)*mPcomision)/100,
                                (((NVL(SUM(importe_pago),0)*mPcomision)/100)*mPiva)/100, NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0),
                                NVL(SUM(flag_confirmacion_central),0), NVL(SUM(flag_confirmacion_sucursal),0)
                            INTO iNumPagos, mImportePago,mImpComisionConvenio,mIVAComisionConvenio,mImpComisionCte,mIVAComisionCte,
                                iConfirmacionCentral, iConfirmacionSucursal
                            FROM bdisac:sac_movimientoshistorial
                            WHERE fecha_pago::DATE  >= dFechaIni AND fecha_pago::DATE  <= dFechaFin AND status_cancelado <> 'S' AND
                            numcategoria = cNumcategoria AND numconvenio = cNumconvenio 
                            AND flag_confirmacion_central = 1
                            AND flag_confirmacion_sucursal = 1;
                        ELSE

                            SELECT NVL(COUNT(referencia1),0), NVL(SUM(importe_pago),0),NVL(SUM(importe_comision_convenio),0),
                                NVL(SUM(iva_comision_convenio),0), NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0),
                                NVL(SUM(flag_confirmacion_central),0), NVL(SUM(flag_confirmacion_sucursal),0)
                            INTO iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
                                iConfirmacionCentral, iConfirmacionSucursal
                            FROM bdisac:sac_movimientoshistorial
                            WHERE fecha_pago::DATE  >= dFechaIni AND fecha_pago::DATE  <= dFechaFin AND numcategoria = cNumcategoria AND
                                status_cancelado <> 'S' AND numconvenio = cNumConvenio
                            AND flag_confirmacion_central = 1
                            AND flag_confirmacion_sucursal = 1;
                        END IF;
					RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte,
						mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
				ELSE   --Un convenio y una sucursal
					SET ISOLATION TO DIRTY READ;
					--SELECT TRIM(NVL(nomconvenio,'')) INTO cNomConvenio FROM bdisac:sac_convenios
					--WHERE numcategoria = cNumcategoria AND numconvenio = cNumconvenio;

 						SELECT TRIM(NVL(nomconvenio,'')), TRIM(NVL(numcategoria,'')), TRIM(NVL(numconvenio,'')),NVL(porc_com_trans_conv,0),NVL(iva_convenio,0)
						INTO cNomConvenio, cNumcategoria, cNumconvenio, mPcomision, mPiva
                        FROM bdisac:sac_convenios
                        WHERE numcategoria = cNumcategoria AND numconvenio = cNumconvenio;

					SET ISOLATION TO DIRTY READ;

                        IF cNumcategoria = "06" AND cNumconvenio="001" THEN
                            SELECT NVL(COUNT(referencia1),0), NVL(SUM(importe_pago),0),( NVL(SUM(importe_pago),0)*mPcomision)/100,
                                (((NVL(SUM(importe_pago),0)*mPcomision)/100)*mPiva)/100, NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0),
                                NVL(SUM(flag_confirmacion_central),0), NVL(SUM(flag_confirmacion_sucursal),0)
                            INTO iNumPagos, mImportePago,mImpComisionConvenio,mIVAComisionConvenio,mImpComisionCte,mIVAComisionCte,
                                iConfirmacionCentral, iConfirmacionSucursal
                            FROM bdisac:sac_movimientoshistorial
                            WHERE fecha_pago::DATE  >= dFechaIni AND fecha_pago::DATE  <= dFechaFin AND status_cancelado <> 'S' AND
                            numcategoria = cNumcategoria AND numconvenio = cNumconvenio AND id_sucursal = cSucursal 
                            AND flag_confirmacion_central = 1
                            AND flag_confirmacion_sucursal = 1;
                        ELSE

                            SELECT NVL(COUNT(referencia1),0), NVL(SUM(importe_pago),0), NVL(SUM(importe_comision_convenio),0),
                                NVL(SUM(iva_comision_convenio),0), NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0),
                                NVL(SUM(flag_confirmacion_central),0), NVL(SUM(flag_confirmacion_sucursal),0)
                            INTO iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
                                iConfirmacionCentral, iConfirmacionSucursal
                            FROM bdisac:sac_movimientoshistorial
                            WHERE fecha_pago::DATE  >= dFechaIni AND fecha_pago::DATE  <= dFechaFin AND numcategoria = cNumcategoria AND
                                numconvenio = cNumconvenio AND id_sucursal = cSucursal AND status_cancelado <> 'S'
                            AND flag_confirmacion_central = 1
                            AND flag_confirmacion_sucursal = 1;
                        END IF;

					RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte,
						mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
				    END IF;
			    END IF;
			END IF;
		END IF;
	END;
	END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener los totales captados por convenio en un rango de fechas especificas',
'de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080905',
'MODIFICO : Mario Gallardo',
'DESCRIPCION:  Se agrega filtro  por sucursal para la consulta de categoria "06" y convenio "001"  ',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Septiembre de 2013',
'VERSION: 20130825',
'MODIFICO : Mario Gallardo',
'DESCRIPCION:  Se quita filtro  por sucursal para la consulta de categoria "06" y convenio "001"  en caso de que cSucursal = "0000"   ',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Octubre de 2013',
'VERSION: 20131015',
'BD    : bdisac',
'MODIFICO : Ing. Victor Manuel Hernandez Lopez',
'DESCRIPCION:  Se modifica el reporte de venta de tiempo aire electronico para mostrar los valores por compaÃ±ia',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Febrero de 2025',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_dinya_obtenerenviospagos
	(pConvenio CHAR(3),
	pImporte1 CHAR (16),
	pImporte2 CHAR (16),
	pSucursal_Origen CHAR(4),
	pNombre1_rem CHAR(26),
	pNombre2_rem CHAR(26),
	pApellido1_rem CHAR(26),
	pApellido2_rem CHAR(26),
	pFechaEnvio1 DATE,
	pFechaEnvio2 DATE,
	pNombre1_ben CHAR(26),
	pNombre2_ben CHAR(26),
	pApellido1_ben CHAR(26),
	pApellido2_ben CHAR(26))
RETURNING  CHAR(5),CHAR(12),DATE,CHAR(4),CHAR(26),CHAR(26),CHAR(26),CHAR(26),MONEY (16,2),CHAR(20);

DEFINE cCodRet 			CHAR(5);
DEFINE dFechaEnvio 		DATE;
DEFINE cSucursalOrigen 	CHAR(4);
DEFINE cNombre1Rem 		CHAR(26);
DEFINE cNombre2Rem 		CHAR(26);
DEFINE cApellido1Rem 	CHAR(26);
DEFINE cApellido2Rem 	CHAR(26);
DEFINE mImporteEnviado 	MONEY (16,2);
DEFINE cStatus 			CHAR(20);
DEFINE cNoControl		CHAR(12);
DEFINE iSqlErr			INTEGER;
DEFINE isam_error		INTEGER;
DEFINE cMensaje			CHAR(50);
DEFINE dfechoy			DATE;

BEGIN

	ON EXCEPTION SET iSqlErr,isam_error,cMensaje
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (iSqlErr,isam_error,cMensaje,'sp_DinYa_ObtenerEnviosPagos',dfechoy,CURRENT );
			RETURN cCodRet,cNoControl,dFechaEnvio,cSucursalOrigen,cNombre1Rem,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus;
		END IF;
	END EXCEPTION;

--SET DEBUG FILE TO "/tmp/Antonio/sp_DinYa_ObtenerEnviosPagos.out";
--TRACE ON;

 LET cCodRet 			= '00000';
 LET dFechaEnvio 		= '';
 LET cSucursalOrigen 	= '';
 LET cNombre1Rem 		= '';
 LET cNombre2Rem 		= '';
 LET cApellido1Rem 		= '';
 LET cApellido2Rem 		= '';
 LET mImporteEnviado 	= '0.00';
 LET cStatus 			= '';
 LET cNoControl			= '';
 LET cMensaje			= '';
 LET dfechoy			= '';
 LET iSqlErr			= 0;
 LET isam_error			= 0;


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;



 IF pConvenio = '' THEN
	LET pConvenio = '001';
 END IF;

 SELECT fecha_hoy INTO dfechoy FROM bdisac:sac_fechas;

 IF pImporte1 = '0.00' AND pImporte2 = '0.00' OR pImporte1 = '' AND pImporte2 = '' THEN
	FOREACH WITH HOLD
		SELECT  DISTINCT(LPAD(envio.no_control,12,'0')),envio.fecha_envio,envio.suc_origen,envio.pri_nom_rem,envio.seg_nom_rem,envio.apell_pat_rem,envio.apell_mat_rem,envio.importe_envio,est.descripcion
		INTO cNoControl,dFechaEnvio,cSucursalOrigen,cNombre1Rem,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus
		FROM sac_enviosdineroya envio,
		OUTER sac_movimientos mov,
		OUTER sac_movimientoshistorial his,
			  sac_estatus est
		WHERE envio.no_control = mov.referencia1
				AND envio.no_control = his.referencia1
				AND (his.numconvenio = pConvenio AND mov.numconvenio = pConvenio)
				AND envio.fecha_envio >= 	pFechaEnvio1
				AND envio.fecha_envio <= 	pFechaEnvio2
				AND envio.estatus = est.estatus
				AND envio.suc_origen = CASE WHEN pSucursal_Origen = "" THEN envio.suc_origen  ELSE pSucursal_Origen END
				AND envio.pri_nom_rem = CASE WHEN pNombre1_rem = "" THEN envio.pri_nom_rem  ELSE pNombre1_rem END
				AND envio.seg_nom_rem = CASE WHEN pNombre2_rem = "" THEN envio.seg_nom_rem  ELSE pNombre2_rem END
				AND envio.apell_pat_rem = CASE WHEN pApellido1_rem = "" THEN envio.apell_pat_rem  ELSE pApellido1_rem END
				AND envio.apell_mat_rem = CASE WHEN pApellido2_rem = "" THEN envio.apell_mat_rem  ELSE pApellido2_rem END
				AND envio.pri_nom_ben = CASE WHEN pNombre1_ben = "" THEN envio.pri_nom_ben  ELSE pNombre1_ben END
				AND envio.seg_nom_ben = CASE WHEN pNombre2_ben = "" THEN envio.seg_nom_ben  ELSE pNombre2_ben END
				AND envio.apell_pat_ben = CASE WHEN pApellido1_ben = "" THEN envio.apell_pat_ben  ELSE pApellido1_ben END
				AND envio.apell_mat_ben = CASE WHEN pApellido2_ben = "" THEN envio.apell_mat_ben  ELSE pApellido2_ben END

		UNION ALL

		SELECT  DISTINCT(LPAD(envio.no_control,12,'0')),envio.fecha_envio,envio.suc_origen,envio.pri_nom_rem,envio.seg_nom_rem,envio.apell_pat_rem,envio.apell_mat_rem,envio.importe_envio,est.descripcion
		FROM sac_enviosdineroyahis envio,
		OUTER sac_movimientos mov,
		OUTER sac_movimientoshistorial his,
		      sac_estatus est
		WHERE envio.no_control = mov.referencia1
				AND envio.no_control = his.referencia1
				AND (his.numconvenio = pConvenio AND mov.numconvenio = pConvenio)
				AND  envio.fecha_envio >= 	pFechaEnvio1
				AND envio.fecha_envio <= 	pFechaEnvio2
				AND envio.estatus = est.estatus
				AND envio.suc_origen = CASE WHEN pSucursal_Origen = "" THEN envio.suc_origen  ELSE pSucursal_Origen END
				AND envio.pri_nom_rem = CASE WHEN pNombre1_rem = "" THEN envio.pri_nom_rem  ELSE pNombre1_rem END
				AND envio.seg_nom_rem = CASE WHEN pNombre2_rem = "" THEN envio.seg_nom_rem  ELSE pNombre2_rem END
				AND envio.apell_pat_rem = CASE WHEN pApellido1_rem = "" THEN envio.apell_pat_rem  ELSE pApellido1_rem END
				AND envio.apell_mat_rem = CASE WHEN pApellido2_rem = "" THEN envio.apell_mat_rem  ELSE pApellido2_rem END
				AND envio.pri_nom_ben = CASE WHEN pNombre1_ben = "" THEN envio.pri_nom_ben  ELSE pNombre1_ben END
				AND envio.seg_nom_ben = CASE WHEN pNombre2_ben = "" THEN envio.seg_nom_ben  ELSE pNombre2_ben END
				AND envio.apell_pat_ben = CASE WHEN pApellido1_ben = "" THEN envio.apell_pat_ben  ELSE pApellido1_ben END
				AND envio.apell_mat_ben = CASE WHEN pApellido2_ben = "" THEN envio.apell_mat_ben  ELSE pApellido2_ben END

		RETURN cCodRet,cNoControl,dFechaEnvio,cSucursalOrigen,cNombre1Rem,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus WITH RESUME;
	 END FOREACH;
 ELSE
	FOREACH WITH HOLD
		SELECT  DISTINCT(LPAD(envio.no_control,12,'0')),envio.fecha_envio,envio.suc_origen,envio.pri_nom_rem,envio.seg_nom_rem,envio.apell_pat_rem,envio.apell_mat_rem,envio.importe_envio,est.descripcion
		INTO cNoControl,dFechaEnvio,cSucursalOrigen,cNombre1Rem,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus
		FROM sac_enviosdineroya envio,
		OUTER sac_movimientos mov,
		OUTER sac_movimientoshistorial his,
		      sac_estatus est
		WHERE envio.no_control = mov.referencia1
				AND envio.no_control = his.referencia1
				AND (his.numconvenio = pConvenio AND mov.numconvenio = pConvenio)
				AND  envio.fecha_envio >= 	pFechaEnvio1
				AND envio.fecha_envio <= 	pFechaEnvio2
				AND envio.importe_envio >= pImporte1
			    AND envio.importe_envio <=  pImporte2
				AND envio.estatus = est.estatus
				AND envio.suc_origen = CASE WHEN pSucursal_Origen = "" THEN envio.suc_origen  ELSE pSucursal_Origen END
				AND envio.pri_nom_rem = CASE WHEN pNombre1_rem = "" THEN envio.pri_nom_rem  ELSE pNombre1_rem END
				AND envio.seg_nom_rem = CASE WHEN pNombre2_rem = "" THEN envio.seg_nom_rem  ELSE pNombre2_rem END
				AND envio.apell_pat_rem = CASE WHEN pApellido1_rem = "" THEN envio.apell_pat_rem  ELSE pApellido1_rem END
				AND envio.apell_mat_rem = CASE WHEN pApellido2_rem = "" THEN envio.apell_mat_rem  ELSE pApellido2_rem END
				AND envio.pri_nom_ben = CASE WHEN pNombre1_ben = "" THEN envio.pri_nom_ben  ELSE pNombre1_ben END
				AND envio.seg_nom_ben = CASE WHEN pNombre2_ben = "" THEN envio.seg_nom_ben  ELSE pNombre2_ben END
				AND envio.apell_pat_ben = CASE WHEN pApellido1_ben = "" THEN envio.apell_pat_ben  ELSE pApellido1_ben END
				AND envio.apell_mat_ben = CASE WHEN pApellido2_ben = "" THEN envio.apell_mat_ben  ELSE pApellido2_ben END

		UNION ALL

		SELECT  DISTINCT(LPAD(envio.no_control,12,'0')),envio.fecha_envio,envio.suc_origen,envio.pri_nom_rem,envio.seg_nom_rem,envio.apell_pat_rem,envio.apell_mat_rem,envio.importe_envio,est.descripcion
		FROM sac_enviosdineroyahis envio,
		OUTER sac_movimientos mov,
		OUTER sac_movimientoshistorial his,
		      sac_estatus est
		WHERE envio.no_control = mov.referencia1
				AND envio.no_control = his.referencia1
				AND envio.importe_envio >= pImporte1
			    AND envio.importe_envio <=  pImporte2
				AND (his.numconvenio = pConvenio AND mov.numconvenio = pConvenio)
				AND  envio.fecha_envio >= 	pFechaEnvio1
				AND envio.fecha_envio <= 	pFechaEnvio2
				AND envio.estatus = est.estatus
				AND envio.suc_origen = CASE WHEN pSucursal_Origen = "" THEN envio.suc_origen  ELSE pSucursal_Origen END
				AND envio.pri_nom_rem = CASE WHEN pNombre1_rem = "" THEN envio.pri_nom_rem  ELSE pNombre1_rem END
				AND envio.seg_nom_rem = CASE WHEN pNombre2_rem = "" THEN envio.seg_nom_rem  ELSE pNombre2_rem END
				AND envio.apell_pat_rem = CASE WHEN pApellido1_rem = "" THEN envio.apell_pat_rem  ELSE pApellido1_rem END
				AND envio.apell_mat_rem = CASE WHEN pApellido2_rem = "" THEN envio.apell_mat_rem  ELSE pApellido2_rem END
				AND envio.pri_nom_ben = CASE WHEN pNombre1_ben = "" THEN envio.pri_nom_ben  ELSE pNombre1_ben END
				AND envio.seg_nom_ben = CASE WHEN pNombre2_ben = "" THEN envio.seg_nom_ben  ELSE pNombre2_ben END
				AND envio.apell_pat_ben = CASE WHEN pApellido1_ben = "" THEN envio.apell_pat_ben  ELSE pApellido1_ben END
				AND envio.apell_mat_ben = CASE WHEN pApellido2_ben = "" THEN envio.apell_mat_ben  ELSE pApellido2_ben END

		RETURN cCodRet,cNoControl,dFechaEnvio,cSucursalOrigen,cNombre1Rem,cNombre2Rem,cApellido1Rem,cApellido2Rem,mImporteEnviado,cStatus WITH RESUME;
	 END FOREACH;
 END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta los envios del convenio 001',
'AUTOR: Antonio Bastidas',
'FECHA: 11 de Noviembre de 2009',
'MODIFICO: Armando Mercado',
'DESCRIPCION: Se modifica para que en lugar de regresar el codigo del estatus regresara la descripcion del estatus',
'BD: BDISAC',
'VERSION: 20100428.1851';

CREATE PROCEDURE "informix".sp_app_valmonto(pEmpresa CHAR(3), pNombre1 CHAR(40), pNombre2 CHAR(40), pApellPat CHAR(40), pApellMat CHAR(40), pFechaNac CHAR(8), pFechaHoy CHAR(10), pMontoPaga CHAR(20),pSucursal CHAR(4),p_moneda CHAR(3),cMontoDolares Money(16,2),pNum_confirmacion CHAR(16))

	RETURNING 
	CHAR(6) AS CodRet;
	
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err      				INTEGER;
    DEFINE cCodRet      				CHAR(6);
	DEFINE vCodRet						CHAR(5);
	DEFINE cAnio						CHAR(4);
	DEFINE cDia							CHAR(2);
	DEFINE cMes             			CHAR(2);
	DEFINE cAnioFecHoy					CHAR(4);
	DEFINE dTotalMensual				DECIMAL(16,2);
	DEFINE dPri_dia_mes					DATE;	
	DEFINE cMaxDiario					DECIMAL(16,2);
	DEFINE cMaxMes						DECIMAL(16,2);
	DEFINE iMaxOperaciones				INTEGER;
	DEFINE cMaxSuc	        			MONEY(16,2); 
	DEFINE dTotalDiario					DECIMAL(8,2);
	DEFINE iCont						INTEGER;
	DEFINE iNumOperDia					INTEGER;	
	DEFINE iNumOperMes					INTEGER;
	DEFINE cImpDia						DECIMAL(16,2);
	DEFINE cImpMes						DECIMAL(16,2);
	DEFINE dMaxDiarioDolar  			DECIMAL(16,2); --222
	DEFINE dImpPagoDolar 				DECIMAL(16,2);
	DEFINE dImpPagoMesDolar 			DECIMAL(16,2);
	DEFINE dMaxMesDolar 				DECIMAL(16,2);
	DEFINE mMaxSucDolar	    			MONEY(16,2);
	DEFINE mMaxEdo						MONEY(16,2);
	DEFINE mMaxEdoDolar	    			MONEY(16,2);
	DEFINE cNumEdo						CHAR(5);
	DEFINE dImpDiaDolar 				DECIMAL(16,2);
	DEFINE mImpMesDolar 				MONEY(16,2);
	DEFINE iNumMovsNoUSDHist			INTEGER;
	DEFINE iNumMovsNoUSD				INTEGER;
	DEFINE cFechaHoy					CHAR(10);
	DEFINE dFechaHoy					DATE;
	DEFINE cRfc							CHAR(13);
	DEFINE cNombres						CHAR(85);
	DEFINE dFechaNac					DATE;
	DEFINE vimporte_pago_dia_usd    	MONEY(16,2);
	DEFINE vimporte_origen_dia_usd  	MONEY(16,2);
	DEFINE vcuenta_dia_usd				INTEGER;
	DEFINE vimporte_pago_dia_no_usd    	MONEY(16,2);
	DEFINE vimporte_origen_dia_no_usd	MONEY(16,2);
	DEFINE vcuenta_dia_no_usd			INTEGER;
	DEFINE vimporte_pago_mes_usd    	MONEY(16,2);
	DEFINE vimporte_origen_mes_usd  	MONEY(16,2);
	DEFINE vcuenta_mes_usd				INTEGER;
	DEFINE vimporte_pago_mes_no_usd    	MONEY(16,2);
	DEFINE vimporte_origen_mes_no_usd	MONEY(16,2);
	DEFINE vcuenta_mes_no_usd			INTEGER;
	DEFINE iCuentasListasNegras			INTEGER;
	DEFINE iRfc_val						INTEGER;
	DEFINE cUsr							CHAR(4);
	LET iCuentasListasNegras			= 0;
	
	--INICIALIZACION DE VARIABLES--
    LET sql_err 						= 0;
    LET cCodRet 						= '000000';
	LET cAnio							= '';
	LET cDia							= '';
	LET cMes            				= '';
	LET cAnioFecHoy						= '';
	LET dTotalMensual     				= 0.00;
	LET dPri_dia_mes					= '';	
	LET cMaxDiario						= 0.00;
	LET cMaxMes							= 0.00;
	LET iMaxOperaciones 				= 0;
	LET cMaxSuc         				= 0.00;
	LET dTotalDiario       				= 0.00;
	LET iCont							= 1;
	LET iNumOperDia						= 0;	
	LET iNumOperMes						= 0;
	LET cImpDia							= 0.00;
	LET cImpMes							= 0.00;
	LET dMaxDiarioDolar 				= 0.00;
	LET dImpPagoDolar 					= 0.00;
	LET dImpPagoMesDolar				= 0.00;
	LET dMaxMesDolar 					=0.00;
	LET mMaxSucDolar    				= 0.00;
	LET mMaxEdo							=0.00;
	LET mMaxEdoDolar					=0.00;
	LET cNumEdo 						='';
	LET dImpDiaDolar 					= 0.00;
	let mImpMesDolar 					= 0.00;
	LET iNumMovsNoUSDHist				= 0;
	LET iNumMovsNoUSD					= 0;
	LET cFechaHoy       				= '';
	LET dFechaHoy						= '';
	LET cRfc							= '';
	LET cNombres						= '';
	LET dFechaNac						= '';
	LET iRfc_val						= 0;
	LET cUsr							= '';
	
	--SET DEBUG FILE TO '/informix/RPT/prueba_sp_val_monto.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Valida Parametros 
		IF NVL(pEmpresa,'') = '' OR NVL(pNombre1,'') = '' OR NVL(pApellPat,'') = '' OR NVL(pFechaNac,'') = '' OR NVL(pFechaHoy,'')='' OR NVL(pMontoPaga,'')='' THEN
			LET cCodRet =   '00170'; --Faltan parametros
			RETURN cCodRet;
		END IF;
		
	-- validar los primeros 4 caracteres correspondan al anio es decir que sea mayor al anio 1900 hasta el anio actual, aaaammdd.
		LET cAnio = SUBSTR(pFechaNac,1,4);
		LET cDia = SUBSTR(pFechaNac,7,2);
		LET cMes = SUBSTR(pFechaNac,5,2);
			
			--PRODUCTIVO
			IF YEAR(pFechaHoy)<= YEAR(CURRENT) THEN
				LET cAnioFecHoy= YEAR(pFechaHoy); --Anio actual
			END IF;
		
			--PRUEBAS 
			--IF YEAR(pFechaHoy)<= YEAR(CURRENT) THEN
				--LET cAnioFecHoy=  SUBSTR(pFechaHoy,7,10); --Anio actual
				--LET cAnioFecHoy=  SUBSTR(pFechaHoy,5,4); --Anio actual
			--END IF; 
			
			IF cAnio BETWEEN 1900 AND cAnioFecHoy AND cMes BETWEEN 01 AND 12 AND cDia BETWEEN 01 AND 31 THEN
			LET cFechaHoy = SUBSTRING(pFechaHoy FROM 5 FOR 4)||SUBSTRING(pFechaHoy FROM 1 FOR 2)||SUBSTRING(pFechaHoy FROM 3 FOR 2);
			SELECT pri_dia_mes 
			INTO dPri_dia_mes
			FROM "informix".sac_fechas;
					
					
				LET cNombres  = TRIM(pNombre1) || " " || TRIM(pNombre2);
				LET dFechaNac = MDY(SUBSTRING(pFechaNac FROM 5 FOR 2) ,SUBSTRING(pFechaNac FROM 7 FOR 2) ,SUBSTRING(pFechaNac FROM 1 FOR 4));
				--Calculo el RFC del beneficiario
				EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(pApellPat, pApellMat, cNombres, dFechaNac)
				INTO vCodRet, cRfc;
				
				SELECT COUNT(*) INTO iRfc_val FROM bdinteg:"informix".si_cliente WHERE rfc = cRfc;
				
				IF iRfc_val = 0 THEN --Separamos los limites de los clientes y de los usuarios
					--Limites por usuario
					
					SELECT PESOS,USD 
					INTO cMaxDiario,dMaxDiarioDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_DIA_'
					AND status = 1;
					
					SELECT PESOS,USD 
					INTO cMaxMes,dMaxMesDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_MES_'
					AND status = 1;
					
					SELECT operaciones 
					INTO iMaxOperaciones
					FROM "informix".sac_limite_monto
					where abreviatura = 'APP_MES_'
					and status = 1;
					
					SELECT pesos,usd 
					INTO cMaxSuc,mMaxSucDolar
					FROM "informix".sac_limite_suc_usuario 
					WHERE abreviatura = 'APP_DIA_' 
					AND sucursal = pSucursal --(buscar la suc
					AND status = 1;
					
					--limite por estado
					SELECT estado
					INTO cNumEdo
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = pSucursal;
					
					SELECT PESOS,USD 
					INTO mMaxEdo, mMaxEdoDolar
					FROM "informix".sac_limite_edo_usuario 
					WHERE abreviatura = 'APP_DIA_'
					AND estado = cNumEdo
					AND status = 1;
					
					LET cUsr = '_USR';
					
				ELIF iRfc_val >= 1 THEN --EPG 25032025
					--Limites por cliente
				
					SELECT PESOS,USD 
					INTO cMaxDiario,dMaxDiarioDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_DIA_'
					AND status = 1;
				
					SELECT PESOS,USD 
					INTO cMaxMes,dMaxMesDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_MES_'
					AND status = 1;
				
					SELECT operaciones 
					INTO iMaxOperaciones
					FROM "informix".sac_limite_monto
					where abreviatura = 'APP_MES_'
					and status = 1;						
				
					SELECT pesos,usd 
					INTO cMaxSuc,mMaxSucDolar
					FROM "informix".sac_limite_suc 
					WHERE abreviatura = 'APP_DIA_' 
					AND sucursal = pSucursal --(buscar la sucursal en donde se esta realizando la remesa) 
					AND status = 1;
					
					--limite por estado
					SELECT estado
					INTO cNumEdo
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = pSucursal;
					
					SELECT PESOS,USD 
					INTO mMaxEdo, mMaxEdoDolar
					FROM "informix".sac_limite_edo
					WHERE abreviatura = 'APP_DIA_'
					AND estado = cNumEdo
					AND status = 1;
					
				END IF; --Fin validacion de limites por ususario y cliente
				
				IF cMaxSuc IS NULL OR cMaxSuc = '' THEN
					LET cMaxSuc = 0;
				END IF;
				
				IF mMaxSucDolar IS NULL OR mMaxSucDolar = '' THEN
					LET mMaxSucDolar = 0;
				END IF;
				
				LET dFechaHoy = TODAY;
				
				
				--Obtengo cifras pagadas durante el mes para el beneficiario
				SELECT NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_dia_usd,
					   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_dia_usd,
					   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN 1 ELSE 0 END),0) cuenta_dia_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_dia_no_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_dia_no_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN 1 ELSE 0 END),0) cuenta_dia_no_usd,
					   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_mes_usd,
					   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_usd,
					   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_mes_no_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD'  AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_no_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_no_usd
				INTO   vimporte_pago_dia_usd, vimporte_origen_dia_usd, vcuenta_dia_usd, vimporte_pago_dia_no_usd, vimporte_origen_dia_no_usd, vcuenta_dia_no_usd,
					   vimporte_pago_mes_usd, vimporte_origen_mes_usd, vcuenta_mes_usd, vimporte_pago_mes_no_usd, vimporte_origen_mes_no_usd, vcuenta_mes_no_usd
				FROM   sac_remesas_estadistica
				WHERE  rfc               =  cRfc
				AND    numcategoria      =  '07'
				AND    numconvenio       IN ('009')
				AND    fecha_pago       >=  dPri_dia_mes
				AND    fecha_pago       <=  dFechaHoy
				AND    status_cancelado !=  'S'
				AND    origen            in ('V','T');
				
				--Determino el numero de movimientos hechos en moneda distinta de dolares
				LET iNumMovsNoUSDHist = vcuenta_dia_no_usd + vcuenta_mes_no_usd;
				
				--Determino el numero de operaciones del mes
				LET iNumOperMes	= vcuenta_dia_usd + vcuenta_dia_no_usd + vcuenta_mes_usd + vcuenta_mes_no_usd;
				
				--Determino el numero de operaciones del dia
				LET iNumOperDia = vcuenta_dia_usd + vcuenta_dia_no_usd;
			
				--Reviso si esta en listas negras
				SELECT COUNT(*)
				INTO   iCuentasListasNegras
				FROM   bdiauditor:"informix".tbl_listainterna
				WHERE  rfc = cRfc;
				
				--222 si existe por lo menos uno distintio de USD OBTENEMOS LOS VALORES EN PESOS
				IF iNumMovsNoUSDHist > 0 OR p_moneda <> 'USD' THEN
				
					LET cImpDia	= vimporte_pago_dia_usd + vimporte_pago_dia_no_usd;
					LET cImpMes	= vimporte_pago_mes_usd + vimporte_pago_mes_no_usd;
				
					--Caso de que algun movimiento (incluyendo el de la peticion) sea diferente de dolares
					LET dTotalDiario  = cImpDia + pMontoPaga;
					LET dTotalMensual = cImpMes + dTotalDiario;
					
					--1. Limite por nÃ?Â?Ã?Âºmero de transacciones (mensual)
					IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales
						LET cCodRet= '000157';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperMes, cImpMes + cImpDia, 'APP_MES_OPE' || cUsr,pNum_confirmacion);
				
						--2. Limite diario por sucursal pesos
					ELIF cMaxSuc > 0 AND (dTotalDiario > cMaxSuc) THEN  --valida monto diario por sucursal
						LET cCodRet= '000158';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_DIA_SUC_MN' || cUsr,pNum_confirmacion);		
				
						--3. Limite por estado pesos
					ELIF mMaxEdo > 0 AND (dTotalDiario > mMaxEdo) THEN  --valida monto diario por 
						LET cCodRet= '000159';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_DIA_EDO_MN' || cUsr,pNum_confirmacion);		
					
						--4. Restriccion de listas negras
					ELIF iCuentasListasNegras > 0 THEN
						LET cCodRet= '000160';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_LISTA' || cUsr,pNum_confirmacion);			
				
						--5. Limite diario pesos
					ELIF dTotalDiario > cMaxDiario THEN  --valida monto diario					
						LET cCodRet= '000161';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_DIA_MN' || cUsr,pNum_confirmacion);			
				
						--6. LiÃ?Â­mite mensual  pesos
					ELIF dTotalMensual > cMaxMes THEN --valida acumulado mensual
						LET cCodRet= '000162';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperMes, cImpMes + cImpDia, 'APP_MES_MN' || cUsr,pNum_confirmacion);					
					END IF;				
				ELSE
					
					LET dImpDiaDolar = vimporte_origen_dia_usd + vimporte_origen_dia_no_usd;
					LET mImpMesDolar = vimporte_origen_mes_usd + vimporte_origen_mes_no_usd;
															
					LET dImpPagoDolar = dImpDiaDolar + cMontoDolares;
					LET dImpPagoMesDolar = mImpMesDolar + dImpPagoDolar;
					
					IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales
						LET cCodRet= '000164';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperMes, mImpMesDolar + dImpDiaDolar, 'APP_MES_OPE' || cUsr,pNum_confirmacion);
						
						--2. LiÃ?Â­mite diario por sucursal dolares
					ELIF mMaxSucDolar > 0 AND (dImpPagoDolar > mMaxSucDolar) THEN  --valida monto diario por sucursal
						LET cCodRet= '000165';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_DIA_SUC_USD' || cUsr,pNum_confirmacion);		
				
						--3. Limite por estado dolares
					ELIF mMaxEdoDolar > 0 AND (dImpPagoDolar > mMaxEdoDolar) THEN  --valida monto diario por sucursal
						LET cCodRet= '000166';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_DIA_EDO_USD' || cUsr,pNum_confirmacion);	
					
						--4. Restriccion de listas negras
					ELIF iCuentasListasNegras > 0 THEN
						LET cCodRet= '000160';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_LISTA' || cUsr,pNum_confirmacion);
										
						--5. Limite diario dolares
					ELIF dImpPagoDolar > dMaxDiarioDolar THEN  --valida monto diario					
						LET cCodRet= '000167';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_DIA_USD' || cUsr,pNum_confirmacion);			
				
						--6. LiÃ?Â­mite mensual dolares
					ELIF dImpPagoMesDolar > dMaxMesDolar THEN --valida acumulado mensual
						LET cCodRet= '000168';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperMes,mImpMesDolar + dImpDiaDolar, 'APP_MES_USD' || cUsr,pNum_confirmacion);
						
					End if;
				
				END if;
				----7. LiÃ?Â­mite acumulado en todas las remesas
				IF cCodRet = '000000' THEN						
					EXECUTE PROCEDURE bdisac:"informix".sp_validamontos(pEmpresa,pNombre1,pNombre2,pApellPat,pApellMat,pFechaNac,cFechaHoy,pMontoPaga,pSucursal,p_moneda,cMontoDolares,'APP' || cUsr,pNum_confirmacion,cRfc,dPri_dia_mes)
					INTO cCodRet;
					
					IF cCodRet = '00001' THEN  --Se excedio en dolares
						LET cCodRet = '000169';
					END IF;
					
					IF cCodRet = '00002' THEN  --Se excedio en pesos
						LET cCodRet = '000163';
					END IF;
				END IF;	
						
			ELSE 
				LET cCodRet= '000170';
			END IF;
		RETURN cCodRet;
		
	END 
END PROCEDURE
DOCUMENT
'Obtiene el monto diario y mensual para cobros Appriza',
'AUTOR : Pedro G Jimenez Guzman',
'FECHA : 13-abril-2016',
'BD    : BDISAC',
'Se agrega nueva validacion de dolares y agregan nuevas a pesos',
'AUTOR : Viridiana Paredes Romero',
'FECHA : 29-05-2017',
'BD    : BDISAC',
'Se agrega nueva validacion para los RFC duplicados',
'AUTOR : Eduardo Pineda Guzman',
'FECHA : 25-03-2025',
'BD    : BDISAC';

CREATE PROCEDURE "informix".sp_consulta_cardif_nuevolm(pNumcte CHAR(20), pAsegurado_Nombre1 CHAR(26), pAsegurado_Nombre2 CHAR(26), pAsegurado_Apell_Pat CHAR(26), pAsegurado_Apell_Mat CHAR(26), pAsegurado_FechaNac DATE)

RETURNING
CHAR(5)	    AS  cCodRet,
CHAR(20)    AS  cNumcte,
CHAR(26)    AS  cNombre1,
CHAR(26)    AS  cNombre2,
CHAR(26)    AS  cApell_paterno,
CHAR(26)    AS  cApell_materno,
CHAR(13)    AS  cRfc,
CHAR(2)	    AS	cEstado,
CHAR(3)	    AS  cCiudad,
CHAR(11)    AS  cColonia,
CHAR(11)    AS  cCalle,
CHAR(10)    AS  cNumExt,
CHAR(10)    AS  cNumInt,
CHAR(5)	    AS  cCP,
CHAR(13)    AS  cCelular,
CHAR(100)   AS  cCorreo, 
CHAR(1)	    AS  cFlagSeguro,
CHAR(50)    AS  cNumPoliza,
CHAR(1024)	AS  cTramaMigrantesBD,
DATE 		AS  cFechaNacimiento

--Variables de retorno
DEFINE cCodRet			 CHAR(5);
DEFINE cNumcte           CHAR(20);
DEFINE cNombre1          CHAR(26);
DEFINE cNombre2          CHAR(26);
DEFINE cApell_paterno    CHAR(26);
DEFINE cApell_materno    CHAR(26);
DEFINE cRfc              CHAR(13);
DEFINE cEstado           CHAR(2);  
DEFINE cCiudad           CHAR(3);  
DEFINE cColonia          CHAR(11);
DEFINE cCalle            CHAR(11);
DEFINE cNumExt           CHAR(10);
DEFINE cNumInt           CHAR(10);
DEFINE cCP               CHAR(5);  
DEFINE cCelular          CHAR(13);
DEFINE cCorreo           CHAR(100);
DEFINE cFlagSeguro       CHAR(1);  
DEFINE cNumPoliza        CHAR(50);
DEFINE cTramaMigrantesBD CHAR(1024);
DEFINE cFechaNacimiento  DATE ;

--Variables internas
DEFINE iExisteCte 	 INTEGER;
DEFINE iExisteCteRem INTEGER;
DEFINE iSqlErr       INTEGER; 
DEFINE iIsamErr    	 INTEGER; 
DEFINE cInfoErr 	 CHAR(10); 
DEFINE cCodRetRfc	 CHAR(5);
DEFINE cTramaMigrantesAux CHAR(1024);
DEFINE iSecDireccion INTEGER;
DEFINE cStatuConv	 CHAR(1);
DEFINE cNombresAseg	 CHAR(70);
DEFINE iSegActivos   INTEGER;
DEFINE cEstatusMig	 CHAR(2);

DEFINE v_Conteo		INTEGER;

--SET DEBUG FILE TO "/informix/HMLG/sp_consulta_cardif.out";
--TRACE ON;	

--Asignacion de valores default
LET cCodRet			  = "00000";
LET cNumcte           = "";
LET cNombre1          = "";
LET cNombre2          = "";
LET cApell_paterno    = "";
LET cApell_materno    = "";
LET cRfc              = "";
LET cEstado           = "";
LET cCiudad           = "";
LET cColonia          = "";
LET cCalle            = "";
LET cNumExt           = "";
LET cNumInt           = "";
LET cCP               = "";
LET cCelular          = "";
LET cCorreo           = ""; 
LET cFlagSeguro       = "0";
LET cNumPoliza        = "";
LET cTramaMigrantesBD = "";
LET cNombresAseg	  = "";
LET iSegActivos		  = 0;

LET iExisteCte		  = 0;
LET iExisteCteRem	  = 0;
LET cTramaMigrantesAux= "";
LET cFechaNacimiento  ="";

LET v_Conteo		  = 0;


--SET DEBUG FILE TO "/informix/MarcoR/CARDIF/BDISAC/SP/TRACE/sp_consulta_cardif.out";
--TRACE ON;	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,cFlagSeguro,cNumPoliza,cTramaMigrantesBD,cFechaNacimiento; 
		END IF;
	END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--Valida que algunos de los dos tipo de busqueda cumpla con los campos minimos
	IF (TRIM(pNumcte) = "") THEN
		IF (TRIM(pAsegurado_Nombre1) = "" OR TRIM(pAsegurado_Apell_Pat) = "" OR pAsegurado_FechaNac IS NULL) THEN
			LET cCodRet= "00001"; --alguno de los dos metodos de busqueda le faltan datos.
			RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,cFlagSeguro,cNumPoliza,cTramaMigrantesBD,cFechaNacimiento;
		END IF;
	END IF;
	
	--Se valida que el servicio este activo
	SELECT statusconvenio 
	INTO cStatuConv
	FROM bdisac:"informix".sac_convenios
	WHERE numcategoria = "09" and numconvenio = "023";
	
	IF TRIM(cStatuConv) = "I" THEN
		LET cFlagSeguro = "9";
		LET cCodRet = "128";
		RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,cFlagSeguro,cNumPoliza,cTramaMigrantesBD,cFechaNacimiento;
	END IF;
	
	IF TRIM(pNumcte) = "" THEN
		
		LET cNombresAseg = TRIM(pAsegurado_Nombre1)||' '||TRIM(pAsegurado_Nombre2);
		LET pAsegurado_Apell_Pat = TRIM(pAsegurado_Apell_Pat);
		LET pAsegurado_Apell_Mat = TRIM(pAsegurado_Apell_Mat);
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_calcularrfc(pAsegurado_Apell_Pat,pAsegurado_Apell_Mat,cNombresAseg,pAsegurado_FechaNac) INTO cCodRetRfc, cRfc;
		
		IF NVL(cCodRetRfc,"") <> "00000" THEN
			LET cCodRet = cCodRetRfc;
		ELSE
			SELECT cte.numcte, count(cte.numcte), count(rem.numcte)
			INTO pNumcte, iExisteCte, iExisteCteRem
			FROM bdinteg:"informix".si_cliente cte LEFT JOIN
			bdisac:"informix".sac_cte_remesas rem ON rem.numcte = cte.numcte
			WHERE cte.rfc = cRfc
			GROUP BY cte.numcte;
		END IF;
	END IF;
	
	LET cNumcte = pNumcte;
	
	SELECT COUNT(cte.numcte), COUNT(rem.numcte)
	INTO iExisteCte, iExisteCteRem
	FROM bdinteg:"informix".si_cliente cte LEFT JOIN
	bdisac:"informix".sac_cte_remesas rem ON rem.numcte = cte.numcte
	WHERE cte.numcte = pNumcte;
	
	IF iExisteCte = 0 THEN
		LET cCodRet = "00002";
	ELIF iExisteCteRem = 0 THEN
		LET cCodRet = "00003";
	END IF;
	
	IF TRIM(cCodRet) = "00000" THEN
		
		/*Se aÃÂ±ade UPDATE para no mostrar operaciones inconclusas por time out de proveredor para cliente especifico */
			
			LET iExisteCte = 0;
			
			SELECT COUNT(*) 
			INTO iExisteCte
			FROM bdisac:"informix".sac_cardif_migrante
			WHERE numcte = pNumcte
			AND estatus = 1
			AND folio_suc IS NULL
			AND num_certificado = ''
			AND num_poliza = '';
			
			IF iExisteCte <> 0 THEN
				UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 5, observ_siniestro = 'Cambio estatus 1 a 5 Operacion Inconclusa Oper'
				WHERE numcte = pNumcte
				AND estatus = 1
				AND folio_suc IS NULL
				AND num_certificado = ''
				AND num_poliza = '';
			END IF;	
			
		/*-------*/
		
	
		SELECT MAX(secuencia) INTO iSecDireccion 
		FROM bdinteg:"informix".si_direcciones_actual WHERE numcte= pNumcte AND tipo_dir = 1;
		
		SELECT cte.nombre1,cte.nombre2,cte.apell_paterno,cte.apell_materno,cte.rfc,dir.estado,dir.ciudad,dir.numerocolonia,dir.numerocalle,dir.numeroextcalle,dir.numerointcalle,dir.cod_postal
		INTO cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP
		FROM bdinteg:"informix".si_cliente cte
		INNER JOIN bdisac:"informix".sac_cte_remesas rem ON rem.numcte = cte.numcte 
		INNER JOIN bdinteg:"informix".si_direcciones_actual dir ON dir.numcte = cte.numcte AND dir.tipo_dir = 1 AND dir.secuencia = iSecDireccion
		WHERE numcte = pNumcte;
		
		IF NVL(cEstado,"") = "" OR NVL(cCiudad,"") = "" OR NVL(cColonia,"") = "" OR NVL(cCalle,"") = "" OR NVL(cNumExt,"") = "" OR NVL(cCP,"") = "" THEN
			LET cCodRet = "00005";
		ELSE
			SELECT telefono INTO cCelular FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumcte AND tel.tipo_tel = 2 AND tel.status_tel = "A";
			SELECT fecha_nac INTO cFechaNacimiento FROM bdinteg:"informix".si_ctepf WHERE numcte = pNumcte;
		
		END IF;
	
		SELECT COUNT(numcte), trim(num_certificado) || "|" || trim(num_poliza)
		INTO cFlagSeguro, cNumPoliza
		FROM bdisac:"informix".sac_cardif_contratante
		WHERE numcte = pNumcte
		GROUP BY num_certificado,num_poliza;
		
		IF cFlagSeguro <> "0" THEN
			SELECT celular, correo
			INTO cCelular, cCorreo
			FROM bdisac:"informix".sac_cardif_contratante
			WHERE numcte = pNumcte;
			LET cFlagSeguro = 1;
		ELSE
			SELECT correo_elec 
			INTO cCorreo
			FROM bdinteg:"informix".si_correos 
			WHERE empresa='001' AND tipo_correo=1 AND status_correo='A' AND numcte=pNumcte AND secuencia=(SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE empresa='001' AND tipo_correo=1 AND numcte=pNumcte AND status_correo='A');
		END IF;
			
		IF cFlagSeguro <> "0" THEN
			
			FOREACH WITH HOLD
				SELECT TRIM(num_certificado) || "|" || TRIM(num_poliza) || "|" || TRIM(estatus) || "|" || TRIM(nombre1) || "|" || TRIM(nombre2) || "|" || 
				TRIM(apell_paterno) || "|" || TRIM(apell_materno) || "|" || TRIM(tipo_plan) || "|" || TRIM(TO_CHAR(fecha_alta,"%d/%m/%Y")) || "|" || 
				TRIM(TO_CHAR(fecha_vencimiento,"%d/%m/%Y")) || "|" || "" || "|" || TRIM(parentesco), TRIM(estatus)
				INTO cTramaMigrantesAux, cEstatusMig
				FROM bdisac:"informix".sac_cardif_migrante WHERE numcte = pNumcte AND estatus IN ("1","2")
				
				LET cTramaMigrantesBD = TRIM(cTramaMigrantesBD) || TRIM(cTramaMigrantesAux) || ">>";
				
				IF (TRIM(cEstatusMig) = "1") OR (TRIM(cEstatusMig) = "2") THEN
					LET iSegActivos = iSegActivos + 1;
				END IF;
				
			END FOREACH;
			
			IF iSegActivos = 0 THEN
				LET cFlagSeguro = 0;
				LET cNumPoliza = "";
			END IF;
		END IF;
	END IF;
	RETURN cCodRet,NVL(cNumcte,""),cNombre1,cNombre2,cApell_paterno,cApell_materno,cRfc,cEstado,cCiudad,cColonia,cCalle,cNumExt,cNumInt,cCP,cCelular,cCorreo,NVL(cFlagSeguro,"0"),NVL(cNumPoliza,""),cTramaMigrantesBD,cFechaNacimiento;
END;
END PROCEDURE;