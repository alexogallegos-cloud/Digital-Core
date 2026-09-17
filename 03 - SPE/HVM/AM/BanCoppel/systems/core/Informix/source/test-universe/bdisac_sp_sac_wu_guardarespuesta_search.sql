CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_search
(
pForeignRsRefNumRq    	CHAR(16),
pMtcn              	    CHAR(10),
pRetCode         		CHAR(5),
pEmisorNameType     	CHAR(1),
pBenefNameType 			CHAR(1),
pMoneyTransKey      	CHAR(10),
pNewMtcn            	CHAR(16),
pForeignRsRefNumRp      CHAR(16),
pDescError              CHAR(250),
pUserInsert             CHAR(8),
pMontoOrigen        	CHAR(10),
pFusionStatus       	CHAR(4),
pEmisorCodMoneda    	CHAR(3),
pBenefEdo           	CHAR(40),
pSucursal				CHAR(4),
pForeignRsSystemIdRp  	CHAR(11),
pUsuario				CHAR(8)
)

RETURNING CHAR(5) AS cod_err, CHAR(30) AS error_desc;

--DEFINICION DE VARIABLES--
    DEFINE	iSql_Err		INTEGER;
	DEFINE 	iIsamErr		INTEGER;
    DEFINE	cCodRet			CHAR(5);
	DEFINE  cRetCode		CHAR(5);
	DEFINE  cDesc_Error		CHAR(250);
	DEFINE	cCodRetAux		CHAR(5);
	DEFINE	cTxnStatus		CHAR(1);
	DEFINE	cNombreSP		CHAR(45);
	DEFINE 	cCadena_ent		CHAR(100);
	DEFINE cError_Desc  	CHAR(30);
	DEFINE cChannelType 	CHAR(3);
    DEFINE cChannelName 	CHAR(3); 
    DEFINE cChannelVersion	CHAR(4);  
	DEFINE cFechaProceso    DATETIME YEAR TO SECOND;
	DEFINE cStatus			CHAR(1);
	DEFINE cNumconvenio		CHAR(3);
	DEFINE cCod_estado_sucursal CHAR(2);
	DEFINE cCod_estado_remesa		CHAR(2);
	DEFINE vCodRet          CHAR(5);
	
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
	DEFINE vCategoria CHAR(2);
	DEFINE vConvenio  CHAR(5);
	
	/*VARIABLES PARA ELIMINAR SELECT DE IF*/
	DEFINE cvalidaselif INTEGER;
	LET cvalidaselif =0;
	
--INICIALIZACION DE VARIABLES--
    LET	iSql_Err		 = 0;
	LET	iIsamErr 		 = 0;
    LET cCodRet			 = '00000';
	LET cRetCode		 = '00000';
	LET cDesc_Error		 = "";
	LET cCodRetAux		 = '00000';
	LET cTxnStatus		 = 'C';
	LET	cNombreSP		 = 'sp_sac_wu_guardarespuesta_search';
	LET cCadena_ent		 =  TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pForeignRsSystemIdRp,'NULL'))||'|'||TRIM(NVL(pMtcn,'NULL'));
	LET cError_Desc	     = "Error en el proceso";
	LET cChannelType 	 ="";	
    LET cChannelName 	 ="";	 
    LET cChannelVersion	 ="";  
	LET cFechaProceso	 = CURRENT::DATETIME YEAR TO SECOND;
	LET cStatus		     ="";
	LET cNumconvenio     ="";
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
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';
	LET vCategoria				= '07';
	LET vConvenio				= '999';
	LET vCodRet					= '000000';
	
--SET DEBUG FILE TO '/tmp/adrian/sp_sac_guardarespuesta_search.out';
--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
BEGIN
	ON EXCEPTION SET iSql_Err, iIsamErr
	IF iSql_Err <> 0 THEN
		LET cCodRet = iSql_Err;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
		INTO cCodRetAux;
		
		IF cCodRetAux <> '00000' THEN
		   LET cCodRet = cCodRetAux;
		END IF;
--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
			LET cTxnStatus		 = 'C';
--	2014.11.11 FRG-f

		INSERT INTO bdisac:"informix".sac_wu_search	
			(txn_status,foreign_rs_refnum_rq,mtcn,retcode,emisor_nametype,benef_nametype,money_transfer_key,new_mtcn,foreign_rs_refnum_rp,
			desc_error,user_insert,fecha_insert)
		VALUES(cTxnStatus,pForeignRsRefNumRq,pMtcn,cRetCode,pEmisorNameType,pBenefNameType,pMoneyTransKey,pNewMtcn,pForeignRsRefNumRp,
			pDescError,pUserInsert,current);
			
		RETURN cCodRet,cError_Desc;
	END IF;
		
    END EXCEPTION;

	/*	
	--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (2,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso)  
	--INTO cCodRetAux;
	
	IF cCodRetAux <> '00000' OR pRetCode <> '00000' THEN
		LET	cTxnStatus	= 'C';		
		LET cCodRet = '00001';
	ELSE
		LET	cTxnStatus	= 'A';
	END IF
	*/
	IF pRetCode = '504' THEN
	    LET cRetCode = '99999';
		LET pDescError = 'Aplicativo WU no activo, validar';
	END  IF;
	
	IF pRetCode <>  '504' AND pRetCode <> '00000' AND pRetCode <> '66666'  THEN		
		LET cRetCode = '99998';
		LET pDescError = 'Sin respuesta del aplicativo, validar';
	END IF;
	IF pRetCode = '66666' THEN
		LET cDesc_Error = pDescError;
		LET cRetCode = pRetCode;
	END IF;
  
	SELECT valor
	INTO cChannelType
	FROM bdisac:"informix".sac_param 
	WHERE cod_param = '87050';  
	 
	SELECT valor
	INTO cChannelName
	FROM bdisac:"informix".sac_param 
	WHERE cod_param = '87051'; 
	 
	SELECT valor
	INTO cChannelVersion
	FROM bdisac:"informix".sac_param 
	WHERE cod_param = '87052'; 
																		
--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
			LET	cTxnStatus	= 'A';
--	2014.11.11 FRG-f

		INSERT INTO bdisac:"informix".sac_wu_search	
			(txn_status,foreign_rs_refnum_rq,mtcn,retcode,emisor_nametype,benef_nametype,money_transfer_key,new_mtcn,foreign_rs_refnum_rp,
			desc_error,user_insert,fecha_insert)
		VALUES(cTxnStatus,pForeignRsRefNumRq,pMtcn,cRetCode,pEmisorNameType,pBenefNameType,pMoneyTransKey,pNewMtcn,pForeignRsRefNumRp,
			pDescError,pUserInsert,current);
		
		--Se guardan datos adicionales de remesas para validacion de Limites de remesas
		EXECUTE PROCEDURE bdisac:"informix".sp_grabaremadic(vCategoria, vConvenio, pMtcn, pEmisorCodMoneda, pMontoOrigen)
		INTO vCodRet;
						
		SELECT status_cancelado 
		INTO cStatus 
		FROM bdisac:sac_movimientos 
		WHERE numcategoria = '07' AND numconvenio = cNumconvenio 
		AND referencia1 = pMtcn
		AND flag_confirmacion_sucursal = '0'
		AND status_cancelado = 'N' ;

		IF cStatus ='N' AND pFusionStatus = 'W/C' THEN -- Si encontr? un intento de pago previo y no ha sido reversado			   
			   LET cCodRet = '00023'; -- Se tiene que reversar primero antes de intentar el pago nuevamente
		END IF;

		IF  cCodRet <> '00000' THEN	
		    --EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,cDesc_Error,iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
		    --INTO cCodRetAux;
			
			IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
				RETURN cCodRet,cError_Desc;	
			END IF;
            
			
/*			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
*/
			IF cCodRet <>  '00023'  THEN		
				LET cCodRet = '00001';
			END IF;
            RETURN cCodRet,cError_Desc;		
	    ELSE	
/*
		    --EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (3,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
	        --INTO cCodRetAux;	
			
			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF;
*/		
			
	    END IF;	

		IF pRetCode = '00000' THEN
			--SELECT estado INTO cCod_estado_sucursal FROM bdinteg:"informix".si_sucursales where sucursal=pSucursal;
			execute procedure bdisac:"informix".sp_sac_consucursales(TRIM(pSucursal)) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,cCod_estado_sucursal,cnomestado,ctel1,ctel2,ctipo;
			IF cSPCodRet <> '00000' THEN
				RETURN cCodRet,cError_Desc;		
			END IF;
			SELECT cod_estado INTO  cCod_estado_remesa FROM "informix".sac_estaremesasorig where cve_prov_estado=TRIM(pBenefEdo) AND remesadora='WUN';
			
			SELECT COUNT(*) INTO cvalidaselif from "informix".sac_estaremesasorig where cve_prov_estado = TRIM(pBenefEdo)  and remesadora='WUN';
			IF cvalidaselif > 0 THEN
				IF cCod_estado_sucursal = cCod_estado_remesa THEN
					RETURN cCodRet,cError_Desc;
				ELSE
					LET cvalidaselif = 0;
					SELECT COUNT(*) INTO cvalidaselif FROM "informix".sac_edosremorigexcep WHERE cod_estado = cCod_estado_remesa and remesadora = 'WUN';
					IF cvalidaselif > 0 THEN
						LET cvalidaselif = 0;
						SELECT COUNT(*) INTO cvalidaselif FROM "informix".sac_edosremorigexcep WHERE remesadora ='WUN' and cod_estado = cCod_estado_remesa and ((cod_excep = TO_CHAR(pSucursal) AND tipo_excep = 'S') OR (cod_excep = cCod_estado_sucursal AND tipo_excep = 'E'));
						IF cvalidaselif > 0 THEN
							RETURN cCodRet,cError_Desc;
						ELSE
							INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pSucursal,cCod_estado_sucursal,pBenefEdo,cCod_estado_remesa,'001',pMtcn,'WUN',CURRENT);
							LET cCodRet = '00005';
							RETURN cCodRet,cError_Desc;	
						END IF;
					ELSE						
						INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pSucursal,cCod_estado_sucursal,pBenefEdo,cCod_estado_remesa,'001',pMtcn,'WUN',CURRENT);
						LET cCodRet = '00005';						
						RETURN cCodRet,cError_Desc;						
					END IF;
				END IF;
			ELSE
				/*
				INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pSucursal,cCod_estado_sucursal,pBenefEdo,cCod_estado_remesa,'002',pMtcn,'WUN',CURRENT);
				LET cCodRet = '00004';
				*/
				RETURN cCodRet,cError_Desc;
			END IF;
		ELSE
		RETURN cCodRet,cError_Desc;
		END IF;
END;
END PROCEDURE;