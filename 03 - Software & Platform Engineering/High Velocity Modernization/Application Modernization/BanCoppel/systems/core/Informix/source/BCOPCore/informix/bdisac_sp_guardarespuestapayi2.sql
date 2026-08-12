CREATE PROCEDURE "informix".sp_guardarespuestapayi2
(
    pSucursal 		            CHAR (4), 
    pTxn_Status					CHAR(1), 
    pConfirmation_nm 			CHAR (11), 
    pBank_Ref_Num			 	CHAR(20), 
    pUser_name 					CHAR(20), 
    pTerminal 					CHAR(15), 
    pAgent_Dt 					CHAR(8), 
    pAgent_Tm 					CHAR(6), 
    pR_First_Name				CHAR(40), 
    pR_Middle_Name 				CHAR(40), 
    pR_Last_Name 				CHAR(40), 
    pR_Mother_M_Name 			CHAR(40),
    pR_Type_Cd 					CHAR(3), 
    pR_Issuer_Cd 				CHAR(3), 
    pR_Issuer_State_Cd			CHAR(3), 
    pR_Issuer_Country_Cd		CHAR(3), 
    pR_Identif_Type				CHAR(5),
    pR_Identif_Nm 				CHAR(20), 
    pR_Expiration_Dt			CHAR(8),
    pR_Fecha_Nac 				CHAR(8),
    pR_Nacionalidad 			CHAR(50),
    pR_pais_nac 				CHAR(20),	
    pR_Nom_Calle 				CHAR(50),
    pR_Num_Ext 					CHAR(5),
    pR_Num_Int 					CHAR(5),
    pR_Depto 					CHAR(10),
    pR_Colonia					CHAR(80),
    pR_Cp						CHAR(5),
    pR_Mncpo_Delg 				CHAR(50),
    pR_Ciudad					CHAR(50),
    pR_Estado 					CHAR(50),
    pR_Telefono 				CHAR(15),
    pTipo_Pago 					CHAR(1),
    pOpCode 					CHAR(4), 
    pProcess_Msg		 		CHAR(255), 	
    pError_Param_Full_Name		CHAR(255), 
    pTrans_Status_Cd			CHAR(3), 
    pTrans_Status_Dt 			CHAR(8),
    pProcess_Dt 				CHAR(8), 
    pProcess_Tm 				CHAR(6), 
    pUsuario 					CHAR(8),
    pNumCte						CHAR(20)
)


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
	DEFINE vfec_nac				  DATE;
	DEFINE vCodRet				CHAR(5);
	DEFINE vcuenta				INTEGER;
	DEFINE p_moneda_origen 		CHAR(3);
	DEFINE p_importe_origen 	MONEY;
	DEFINE vCategoria			CHAR(2);
	DEFINE vConvenio			CHAR(5);
	
	
	
        --INICIALIZACION DE VARIABLES--
    LET sql_err                = 0;
    LET cCodRet                = '00000';
	LET cAgent_Trans_Type_Code = 'PAYI';
	LET cAgent_Cd              = '';
	LET cRegion_Sd             = '';
	LET cBranch_Sd             = '';
	LET cState_Cd              = '';
	LET cCountry_Cd            = '';
	LET vcuenta					= 0;
	LET vCodRet					= '00000';
	LET p_moneda_origen			= '';
	LET p_importe_origen		= 0;
	LET vCategoria				= '07';
	LET vConvenio				= '004';
	
	
	--SET DEBUG FILE TO "/respaldosbd/Dulce/sp_GuardaRespuestaPayi2.out";
    --TRACE ON;

    
	--SET DEBUG FILE TO "/ifxsif01/ENP/sp_GuardaRespuestaPayi2.out";
    --TRACE ON;

    
	
	BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	IF pSucursal = "" OR  pSucursal IS NULL OR pTxn_Status = "" OR pTxn_Status IS NULL OR pConfirmation_nm = "" OR pConfirmation_nm IS NULL 
	    OR pBank_Ref_Num = "" OR pBank_Ref_Num IS NULL OR pUser_name = "" OR pUser_name IS NULL OR pTerminal = "" OR pTerminal IS NULL 
		OR pAgent_Dt = "" OR pAgent_Dt IS NULL OR pAgent_Tm = "" OR pAgent_Tm IS NULL 
		OR pR_First_Name = "" OR pR_First_Name IS NULL OR pR_Last_Name = "" OR pR_Last_Name IS NULL 
		OR pR_Type_Cd = "" OR pR_Type_Cd IS NULL OR pR_Issuer_Cd = "" OR pR_Issuer_Cd IS NULL 
		OR pR_Issuer_State_Cd = "" OR pR_Issuer_State_Cd IS NULL OR pR_Issuer_Country_Cd = "" OR pR_Issuer_Country_Cd IS NULL 
		OR pR_Identif_Nm = "" OR pR_Identif_Nm IS NULL OR pR_Expiration_Dt = "" OR pR_Expiration_Dt IS NULL 
		OR pUsuario = "" OR pUsuario IS NULL OR pR_pais_nac = "" OR pR_pais_nac IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet;
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	EXECUTE PROCEDURE bdisac:"informix".sp_consultasucursal (pSucursal) 
	INTO cCodRet, cAgent_Cd, cRegion_Sd, cBranch_Sd, cState_Cd, cCountry_Cd;
	IF cCodRet = "00000" THEN
		INSERT INTO "informix".sac_bts_payi (txn_status, agent_trans_type_code, agent_cd, confirmation_nm, bank_ref_nm, region_sd, branch_sd, state_cd, 
		        country_cd, user_name, terminal, agent_dt, agent_tm, r_first_name, r_middle_name, r_last_name, r_mother_m_name, r_type_cd, 
				r_issuer_cd, r_issuer_state_cd, r_issuer_country_cd, r_identif_type, r_identif_nm, r_expiration_dt, r_fecha_nac, r_nacionalidad, r_pais_nac,
				r_nom_calle, r_num_ext, r_num_int, r_depto, r_colonia, r_cp, r_mncpo_deleg, r_ciudad, r_estado, r_telefono, tipo_pago, sucursal,
				opcode, process_msg, error_param_full_name, trans_status_cd, trans_status_dt, process_dt, process_tm, user_insert, fecha_insert,numcte)
		VALUES(pTxn_Status, cAgent_Trans_Type_Code, cAgent_Cd, pConfirmation_Nm, pBank_Ref_Num, cRegion_Sd, cBranch_Sd, cState_Cd,
         		cCountry_Cd, pUser_Name, pTerminal, pAgent_Dt, pAgent_Tm, pR_First_Name, pR_Middle_Name, pR_Last_Name, pR_Mother_M_Name, pR_Type_Cd,  
				pR_Issuer_Cd, pR_Issuer_State_Cd, pR_Issuer_Country_Cd, pR_Identif_Type, pR_Identif_Nm, pR_Expiration_Dt, pR_Fecha_Nac, pR_Nacionalidad, pR_pais_nac,
				pR_Nom_Calle, pR_Num_Ext, pR_Num_Int, pR_Depto, pR_Colonia, pR_Cp, pR_Mncpo_Delg, pR_Ciudad, pR_Estado, pR_Telefono, pTipo_Pago, pSucursal, 
				pOpCode, pProcess_Msg, pError_Param_Full_Name, pTrans_Status_Cd, pTrans_Status_Dt, pProcess_Dt, pProcess_Tm, pUsuario, CURRENT,pNumCte);
				
		--Busco datos de query
		EXECUTE PROCEDURE bdisac:"informix".sp_obtieneremadic(vCategoria, vConvenio, pConfirmation_Nm)
		INTO vCodRet, p_moneda_origen, p_importe_origen;
		
		--Actualizo tabla de datos para limites de remesas mensuales
		LET vfec_nac = MDY(SUBSTRING(pR_Fecha_Nac FROM 5 FOR 2), SUBSTRING(pR_Fecha_Nac FROM 7 FOR 2), SUBSTRING(pR_Fecha_Nac FROM 1 FOR 4));
		EXECUTE PROCEDURE bdisac:"informix".sp_actualizaremesa(vCategoria, vConvenio, pConfirmation_Nm, pR_First_Name, pR_Middle_Name, pR_Last_Name, pR_Mother_M_Name, vfec_nac, p_moneda_origen, p_importe_origen)
		INTO vCodRet, vcuenta;

            ---------------------------------------------------------------------------------
        IF
            pSucursal <> '' or pSucursal IS NOT NULL THEN
            IF EXISTS (SELECT * FROM bdinteg:"informix".si_sucursales WHERE sucursal NOT IN ('9250', '9251', '9764','5011','5003') AND sucursal = pSucursal) THEN
                EXECUTE PROCEDURE bdinteg:"informix".sp_inserta_msjafore(pNumcte,'',pSucursal,'') INTO cCodRet;
                IF 
                    cCodRet <> '00000' THEN
                    INSERT INTO bdisac:"informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
                    VALUES ('sp_pago_wu_web', CURRENT, '0', 'informix', CURRENT, NULL, 'sp_inserta_msjafore', 'Codigo retorno: '|| cCodRet);
                END IF;
            END IF;
        END IF;
        ----------------------------------------------------------------------------------
       
		
	END IF;
	
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para guardar los datos de envio y recepciÃÂ³n del mensaje PAYI de BTS',
'AUTOR : Dulce Ramirez',
'FECHA : 05/Enero/2011',
'Ver.  : 1.1',
'BD    : bdisac',
'VER   : 1.1',
'MODIFICO: Felipe Urias',
'FECHA : 12/Abril/2012',
'DESCRIPCION: se agrego el campo r_pais_nac como parametro a guardar en tabla',
'MODIFICO: FRG',
'FECHA : 09/Mayo/2012',
'DESCRIPCION: se clona el SP con nombre sp_guardarespuestapayi2.sql',
'para no afectar el flujo actual en Prod. al guardar el campo r_pais_nac',
'****************************************************************************************************',
'DescripciÃÂ³n: Se inserta campo numcte para utilizar en remesas',
'Autor      : Geovani Garcia Ochoa',
'FECHA DE CREACION    : 28/02/2017',
'BD         : bdisac',
'FOLIO		: 198 - RQM 10 784 B ASE DE DATOS PARA EL ALTA DE USUARIOS DE REMESAS',
'-------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_soldespagoskyonline(pFolioSuc char(16)) 
	--RETORNOS
	RETURNING
	CHAR(5) AS cCodigoRet, CHAR(850) AS cTrama; 
	
	--Definicion de Variables
	DEFINE cCodigoRet  	CHAR(5);
	DEFINE cTrama    	CHAR(850);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cEnte_id 			CHAR(3);
	DEFINE cNumero_cuenta 	    CHAR(12);
	DEFINE cFecha_depo_banco    CHAR(10);
	DEFINE cImporte_transaccion CHAR(13);
	DEFINE cAutorizacion 	CHAR(10);
	DEFINE cMpel_id 		CHAR(15);
	DEFINE cUsoFuturo1 		CHAR(256);
	DEFINE cUsoFuturo2 		CHAR(256);
	DEFINE cUsoFuturo3 		CHAR(256);
	DEFINE cFolio_pago 		CHAR(10);
	DEFINE cTrancinterac    CHAR(5);
	DEFINE cTrancservice    CHAR(5);
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET cTrama = '';
	LET iSqlErr = 0;
	LET cEnte_id ='';
	LET cNumero_cuenta ='';
	LET cFecha_depo_banco ='';
	LET cImporte_transaccion ='';
	LET cAutorizacion =''; 	
	LET cMpel_id ='';		
	LET cUsoFuturo1 	='';	
	LET cUsoFuturo2 	=''; 		
	LET cUsoFuturo3 	='';
	LET cFolio_pago 	=''; 
	LET cTrancinterac 	='';
	LET cTrancservice   ='';
	
	--SET DEBUG FILE TO '/home/sysifx/JesusAlbertoLI';
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN TRIM(NVL(cCodigoRet,"")),TRIM( NVL(cTrama,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		
		--Validamos parÃ¡metros para que no sean nulos
		IF NVL(pFolioSuc,'') = '' THEN
			 LET cCodigoRet = '00001';			 RETURN TRIM(NVL(cCodigoRet,"")),TRIM( NVL(cTrama,""));
        ELSE
		
		if (SELECT COUNT(*) FROM "informix".sac_sky_wsgpago  WHERE folio_suc = pFolioSuc AND id_respuesta ='000'  ) = 0 then 
			 LET cCodigoRet = '00002';			 RETURN TRIM(NVL(cCodigoRet,"")),TRIM( NVL(cTrama,""));
		END IF;
		SELECT trans_interact
		INTO cTrancinterac		
		FROM bdisac: "informix".sac_intrfz_serv  
		WHERE numcategoria = '06' and numconvenio='001' and num_trama = '2';
		
		
		SELECT trans_servicio
		INTO cTrancservice		
		FROM bdisac: "informix".sac_intrfz_serv  
		WHERE numcategoria = '06' and numconvenio='001' and num_trama = '2';
		
		
		SELECT valor 
		INTO cEnte_id 
		FROM bdisac: "informix".sac_param 
		WHERE cod_param = '114';
		
		SELECT referencia1 
		INTO cNumero_cuenta 
		FROM bdisac: "informix".sac_movimientos 
		WHERE folio_suc = pFolioSuc;
		
		--Fecha actual del sistema
		LET cfecha_depo_banco =
		SUBSTR(CURRENT, 9,  2)     ||'/'|| -- DD 
		SUBSTR(CURRENT, 6,  2)     ||'/'|| -- MM  
		SUBSTR(CURRENT, 1,  4)     ||' '|| -- AAAA   
					'';
		
		SELECT importe_pago 
		INTO cImporte_transaccion 
		FROM bdisac: "informix".sac_movimientos 
		WHERE folio_suc = pFolioSuc;
		
		LET cFolio_pago = SUBSTR(pFolioSuc, 7,  10);
		
		SELECT autorizacion
		INTO cAutorizacion
		FROM bdisac: "informix".sac_sky_wsgpago 
		WHERE folio_suc = pFolioSuc;
		
		SELECT mpel_id 
		INTO cMpel_id
		FROM bdisac: "informix".sac_sky_wsgpago 
		WHERE folio_suc = pFolioSuc;
		
		--concatenar todas la variables en cTrama
LET cTrama = NVL(cTrancinterac,'') || NVL(cTrancservice,'') || NVL(cEnte_id,'') || NVL(cNumero_cuenta,'') || NVL(cFecha_depo_banco,'') || NVL(SUBSTR(cImporte_transaccion,2,12),'0.00') || NVL(cFolio_pago,'') || NVL(cAutorizacion,'') || NVL(cMpel_id,'') || NVL(cUsoFuturo1,'') || NVL(cUsoFuturo2,'') || NVL(cUsoFuturo3,'');	
 
	END IF;
	
	RETURN TRIM(NVL(cCodigoRet,'')),NVL(cTrama,'');
	
	END;
END PROCEDURE;