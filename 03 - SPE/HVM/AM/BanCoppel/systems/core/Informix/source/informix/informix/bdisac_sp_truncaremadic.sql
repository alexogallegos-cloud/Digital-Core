CREATE PROCEDURE "informix".sp_truncaremadic()
RETURNING CHAR(5), CHAR(80);

	--Definicion de Variables
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr 		INTEGER;
    DEFINE cInfoErr         CHAR(100);
	DEFINE vCuenta			INTEGER;
	DEFINE cMensaje			CHAR(80);

	-- Inicializa variables
	LET cCodRet            	= "00000";
	LET cMensaje			= 'PROCESO EXITOSO';
	LET vCuenta				= 0;
	
	--SET DEBUG FILE TO '/tmp/sp_grabaremadic.out';
	--TRACE ON;

    BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envío codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_truncaremadic");
				
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP";
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Borro los datos de la tabla sac_remesas_adic
		TRUNCATE bdisac:sac_remesas_adic;
		UPDATE STATISTICS MEDIUM FOR TABLE bdisac:sac_remesas_adic;
		
		RETURN cCodRet, cMensaje;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de truncar la tabla sac_remesas_adic',
'FECHA CREACION : 13 de Junio de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_guardarespuestaqryi(pSucursal CHAR (4), 
                                        pTxn_Status CHAR(1), 
										pConfirmation_nm CHAR (11), 
										pUser_name CHAR (20), 
										pTerminal CHAR(15),
                                        pAgent_Dt CHAR(8), 
										pAgent_Tm CHAR(6), 
										pOpCode CHAR(4), 
										pProcess_Msg CHAR(255), 
										pError_Param_Full_Name CHAR(255), 
										pTrans_Status_Cd CHAR(3), 
	                                    pTrans_Status_Dt CHAR(8), 
										pProcess_Dt CHAR(8), 
										pProcess_Tm CHAR(6), 
										pService_Cd CHAR(3), 
										pPayment_Type_Cd CHAR(3), 
	                                    pOrig_Country_Cd CHAR(3), 
										pOrig_Currency_Cd CHAR(3), 
										pDest_Country_Cd CHAR(3), 
										pDest_Currency_Cd CHAR(3), 
										pOrigin_Am CHAR(20), 
                                    	pDestination_Am CHAR(20), 
										pExch_Rate_Fx CHAR(21), 
										pS_Agent_Cd CHAR(3), 
										pS_Payment_Type_Cd CHAR(3), 
										pS_Account_Type_Cd CHAR(3), 
	                                    pS_Account_Nm CHAR(30), 
										pS_Bank_Cd CHAR(30), 
										pS_Bank_Ref_Nm CHAR(20), 
										pR_Account_Type_Cd CHAR(3), 
										pR_Account_Nm CHAR(30),
										pR_Agent_Cd CHAR(3), 
										pR_Agent_Region_Sd CHAR(15), 
										pR_Agent_Branch_Sd CHAR(15), 
										pS_First_Name CHAR(40), 
										pS_Middle_Name CHAR(40),
										pS_Last_Name CHAR(40), 
										pS_Mother_M_Name CHAR(40), 
										pS_Address CHAR(80), 
										pS_City CHAR(40), 
										pS_State_Cd CHAR(3), 
										pS_Country_Cd CHAR(3), 
										pS_Zip_Code CHAR(10), 
										pS_Phone CHAR(15), 
										pR_First_Name CHAR(40), 
										pR_Middle_Name CHAR(40), 
										pR_Last_Name CHAR(40), 
										pR_Mother_M_Name CHAR(40), 
										pR_Identif_Type_Cd CHAR(3), 
										pR_Identif_Nm CHAR(20), 
										pF_First_Name CHAR(40), 
										pF_Middle_Name CHAR(40), 
										pF_Last_Name CHAR(40), 
										pF_Mother_M_Name CHAR(40), 
										pR_Address CHAR(80), 
										pR_City CHAR(40), 
										pR_State_Cd CHAR(3), 
										pR_Country_Cd CHAR(3), 
										pR_Zip_Code CHAR(10), 
										pR_Phone CHAR(15), 
										pR_Type_Cd CHAR(3), 
										pR_Issuer_Cd CHAR(3), 
										pR_Issuer_State_Cd CHAR(3), 
										pR_Issuer_Country_Cd CHAR(3), 
	                                    pRi_Identif_Nm CHAR(20), 
										pR_Expiration_Dt CHAR(8), 
										pS_Type_Cd CHAR(3), 
										pS_Issuer_Cd CHAR(3), 
										pS_Issuer_State_Cd CHAR(3),	
										pS_Issuer_Country_Cd CHAR(3), 
										pS_Identif_Nm CHAR(20), 
										pS_Expiration_Dt CHAR(8), 
										pUsuario CHAR(8),
										pModo SMALLINT)

	--DATOS A REGRESAR---
    RETURNING
    CHAR(5);   -- Codigo de Retorno
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err                INT;
    DEFINE cCodRet                CHAR(5);
	DEFINE cAgent_Trans_Type_Code CHAR(4);
	DEFINE cAgent_Cd              CHAR(3);
	DEFINE cRegion_Sd             CHAR(15);
	DEFINE cBranch_Sd             CHAR(15);
	DEFINE cState_Cd              CHAR(3);
	DEFINE cCountry_Cd            CHAR(3);
    DEFINE cStatus                CHAR(1);
	DEFINE cCod_estado_sucursal CHAR(2);
	DEFINE cCod_estado_remesa		CHAR(2);
	
	DEFINE cSPCodRet CHAR(5); 
	DEFINE iMensaje CHAR(50);
	DEFINE cid_ptf CHAR(5); 
	DEFINE ccve_pais CHAR(3);
	DEFINE cnompais CHAR(20);
	DEFINE ccalle VARCHAR(100); 
	DEFINE cnum_ext VARCHAR(6); 
	DEFINE cnum_int VARCHAR(5); 
	DEFINE ccve_col CHAR(8);
	DEFINE cnomcol VARCHAR(100);
	DEFINE ccve_mun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE ccve_localidad CHAR(14);
	DEFINE cnomlocalidad VARCHAR(60);
	DEFINE ccp CHAR(5); 
	DEFINE ccve_ciudad CHAR(3);
	DEFINE cnomciudad VARCHAR(60);
	DEFINE ccve_estado CHAR(2); 
	DEFINE cnomestado VARCHAR(30);
	DEFINE ctel1 VARCHAR(14); 
	DEFINE ctel2 VARCHAR(14);
	DEFINE ctipo VARCHAR(5);	
	DEFINE vCodRet          CHAR(5);
	DEFINE vCategoria			CHAR(2);
	DEFINE vConvenio			CHAR(5);
	
	/*VARIABLES PARA ELIMINAR SELECT DE IF*/
	DEFINE cvalidaselif INTEGER;
	LET cvalidaselif =0;
	
    --INICIALIZACION DE VARIABLES--
    LET sql_err                = 0;
    LET cCodRet                = '00000';
	LET cAgent_Trans_Type_Code = 'QRYI';
	LET cAgent_Cd              = '';
	LET cRegion_Sd             = '';
	LET cBranch_Sd             = '';
	LET cState_Cd              = '';
	LET cCountry_Cd            = '';
	LET cStatus = '';
	LET cCod_estado_sucursal = '';
	LET cCod_estado_remesa = '';
	
	LET cSPCodRet = '00000';
	LET iMensaje = '';
	LET cid_ptf = '';
	LET ccve_pais = '';
	LET cnompais = '';
	LET ccalle = '';
	LET cnum_ext = ''; 
	LET cnum_int = '';
	LET ccve_col = '';
	LET cnomcol = '';
	LET ccve_mun = '';
	LET cnommunicipio = '';
	LET ccve_localidad = '';
	LET cnomlocalidad = '';
	LET ccp = '';
	LET ccve_ciudad = '';
	LET cnomciudad = '';
	LET ccve_estado = ''; 
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';	
	LET vCodRet = '00000';
	LET vCategoria				= '07';
	LET vConvenio				= '004';
	
	--SET DEBUG FILE TO '/tmp/adrian/sp_guardarespuestaqryi.out';
    --TRACE ON;
	
	BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	IF pSucursal = "" OR  pSucursal IS NULL OR pTxn_Status = "" OR pTxn_Status IS NULL OR pConfirmation_nm = "" OR pConfirmation_nm IS NULL 
	    OR pUser_name = "" OR pUser_name IS NULL OR pTerminal = "" OR pTerminal IS NULL OR pAgent_Dt = "" OR pAgent_Dt IS NULL 
		OR pAgent_Tm = "" OR pAgent_Tm IS NULL OR pUsuario = "" OR pUsuario IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet;
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	EXECUTE PROCEDURE BDISAC:sp_consultasucursal (pSucursal) 
	INTO cCodRet, cAgent_Cd, cRegion_Sd, cBranch_Sd, cState_Cd, cCountry_Cd;
	IF cCodRet = "00000" THEN
		INSERT INTO sac_bts_qryi (txn_status, agent_trans_type_code, agent_cd, confirmation_nm, region_sd, branch_sd, state_cd, country_cd, user_name, terminal, 
	             agent_dt, agent_tm, opcode, process_msg, error_param_full_name, trans_status_cd, trans_status_dt, process_dt, process_tm, service_cd, payment_type_cd,
	             orig_country_cd, orig_currency_cd, dest_country_cd, dest_currency_cd, origin_am, destination_am, exch_Rate_fx, s_agent_cd, s_payment_type_cd,
	             s_account_type_cd, s_account_nm, s_bank_cd, s_bank_Ref_nm, r_account_type_cd, r_account_nm, r_agent_cd, r_agent_region_sd, r_agent_branch_sd, 
	             s_first_name, s_middle_name, s_last_name, s_mother_m_name, s_address, s_city, s_state_cd, s_country_cd, s_zip_code, s_phone, r_first_name,
	             r_middle_name, r_last_name, r_mother_m_name, r_identif_type_cd, r_identif_nm, f_first_name, f_middle_name, f_last_name, f_mother_m_name,
	             r_address, r_city, r_state_cd, r_country_cd, r_zip_code, r_phone, r_type_cd, r_issuer_cd, r_issuer_state_cd, r_issuer_country_cd, ri_identif_nm, 
	             r_expiration_dt, s_type_cd, s_issuer_cd, s_issuer_state_cd, s_issuer_country_cd, s_identif_nm, s_expiration_dt, user_insert, fecha_insert)
		VALUES(pTxn_Status, cAgent_Trans_Type_Code, cAgent_Cd, pConfirmation_nm, cRegion_Sd, cBranch_Sd, cState_cd, cCountry_cd, pUser_name, pTerminal, 
	             pAgent_Dt, pAgent_tm, pOpCode, pProcess_Msg, pError_Param_Full_Name, pTrans_Status_Cd, pTrans_Status_Dt, pProcess_Dt, pProcess_Tm, pService_Cd, pPayment_Type_Cd,
	             pOrig_Country_Cd, pOrig_Currency_Cd, pDest_Country_Cd, pDest_Currency_Cd, pOrigin_Am, pDestination_Am, pExch_Rate_Fx, pS_Agent_Cd, pS_Payment_Type_Cd,
	             pS_Account_Type_Cd, pS_Account_Nm, pS_bank_Cd, pS_Bank_Ref_Nm, pR_Account_Type_Cd, pR_Account_Nm, pR_Agent_Cd, pR_Agent_Region_Sd, pR_Agent_Branch_Sd, 
	             pS_First_Name, pS_Middle_Name, pS_Last_Name, pS_Mother_M_Name, pS_Address, pS_City, pS_State_Cd, pS_Country_Cd, pS_Zip_Code, pS_Phone, pR_First_Name,
	             pR_Middle_Name, pR_Last_Name, pR_Mother_M_Name, pR_Identif_Type_Cd, pR_Identif_Nm, pF_First_Name, pF_Middle_Name, pF_Last_Name, pF_Mother_M_Name,
	             pR_Address, pR_City, pR_State_Cd, pR_Country_Cd, pR_Zip_Code, pR_Phone, pR_Type_Cd, pR_Issuer_Cd, pR_Issuer_State_Cd, pR_Issuer_Country_Cd, pRi_Identif_Nm, 
	             pR_Expiration_Dt, pS_Type_Cd, pS_Issuer_Cd, pS_Issuer_State_Cd, pS_Issuer_Country_Cd, pS_Identif_Nm, pS_Expiration_Dt, pUsuario, CURRENT);			 
	
		--Se guardan datos adicionales de remesas para validacion de Limites de remesas
		EXECUTE PROCEDURE bdisac:"informix".sp_grabaremadic(vCategoria, vConvenio, pConfirmation_nm, pOrig_Currency_Cd, pOrigin_Am)
		INTO vCodRet;
		
	-- Nueva validaci?n por duplicidad de pagos. JGP. 26-Sep-11
		SELECT status_cancelado INTO cStatus FROM bdisac:sac_movimientos 
			WHERE numcategoria = '07' AND numconvenio = '004' AND referencia1 = pConfirmation_nm 
			AND status_cancelado = 'N' AND flag_confirmacion_sucursal = '0';
			IF cStatus ='N' AND pTrans_Status_Cd = 'ONP' THEN -- Si encontr? un intento de pago previo y no ha sido reversado
			   LET cCodRet = '00756'; -- Se tiene que reversar primero antes de intentar el pago nuevamente
			   RETURN cCodRet;
			END IF;
   		IF pPayment_Type_Cd = 'ACC' AND cBranch_Sd <> '9250' THEN -- La remesa es para abono en cuenta
		   LET cCodRet = '00756'; -- No se permite el pago
		   RETURN cCodRet;
		END IF;
	END IF;
	
	 IF pOpCode = '1000' AND TRIM(pTrans_Status_Cd) = 'ONP' THEN
				--SELECT estado INTO cCod_estado_sucursal FROM bdinteg:"informix".si_sucursales where sucursal=pSucursal;
				execute procedure bdisac:"informix".sp_sac_consucursales(TRIM(pSucursal)) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,cCod_estado_sucursal,cnomestado,ctel1,ctel2,ctipo;
				IF cSPCodRet <> '00000' THEN
					RETURN cCodRet;	
				END IF;
				SELECT cod_estado INTO  cCod_estado_remesa FROM "informix".sac_estaremesasorig where cve_prov_estado=pR_State_Cd AND remesadora='BTS';
				
				Select COUNT(*) INTO cvalidaselif from "informix".sac_estaremesasorig where cve_prov_estado = pR_State_Cd  and remesadora='BTS';
				IF cvalidaselif > 0 THEN
					IF cCod_estado_sucursal = cCod_estado_remesa THEN
						return cCodRet;
					ELSE
						LET cvalidaselif = 0;
						SELECT COUNT(*) INTO cvalidaselif FROM "informix".sac_edosremorigexcep WHERE cod_estado = cCod_estado_remesa and remesadora = 'BTS';
						IF cvalidaselif > 0 THEN 
							LET cvalidaselif = 0;
							SELECT COUNT(*) INTO cvalidaselif FROM "informix".sac_edosremorigexcep WHERE remesadora ='BTS' and cod_estado = cCod_estado_remesa and ((cod_excep = TO_CHAR(pSucursal) AND tipo_excep = 'S') OR (cod_excep = cCod_estado_sucursal AND tipo_excep = 'E'));
							IF cvalidaselif > 0 THEN	
								RETURN cCodRet;
							ELSE
								INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pSucursal,cCod_estado_sucursal,pR_State_Cd,cCod_estado_remesa,'001',pConfirmation_nm,'BTS',CURRENT);
								LET cCodRet = '00005';
								RETURN cCodRet;
							END IF;
						ELSE
							INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pSucursal,cCod_estado_sucursal,pR_State_Cd,cCod_estado_remesa,'001',pConfirmation_nm,'BTS',CURRENT);
							LET cCodRet = '00005';
							RETURN cCodRet;
						END IF;
					END IF;
				ELSE
					/*
					INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pSucursal,cCod_estado_sucursal,pR_State_Cd,cCod_estado_remesa,'002',pConfirmation_nm,'BTS',CURRENT);
					LET cCodRet = '00004';
					*/
					RETURN cCodRet;
				END IF;
	ELSE
			RETURN cCodRet;
	END IF;
END;
END PROCEDURE;