CREATE PROCEDURE "informix".sp_asignacuenta_edomex(pPrefijo CHAR(6))
RETURNING CHAR(6) AS CodRet,CHAR(40) AS Descripcion,CHAR(20) AS NumCta;

	DEFINE iSqlErr			INTEGER;
	DEFINE cCod_ret			CHAR(5);
	DEFINE cConcepto		CHAR(40);
	DEFINE cCuenta			CHAR(20);

	LET cCod_ret			= '00000';
	LET cConcepto			= '';
	LET cCuenta				= '';
	
	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO '/home/sysifx/Hugo_vaz/1468/sp_asignacuenta_edomex.out';
-- TRACE ON;

    BEGIN

   	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCod_ret = iSqlErr;
			RETURN cCod_ret,NVL(cConcepto,''), NVL(cCuenta,'');
		END IF;
	END EXCEPTION;


	IF TRIM(NVL(pPrefijo,'')) = '' OR pPrefijo IS null THEN
		LET cCod_ret         = '00001';
		RETURN cCod_ret,NVL(cConcepto,''), NVL(cCuenta,'');
	END IF


	LET pPrefijo = substr (pPrefijo,1,3);

    SELECT concepto, cuenta
	INTO cConcepto, cCuenta
	FROM bdisac:"informix".sac_edomex_cuentas
	WHERE prefijo =  pPrefijo;
	
	
	IF cCuenta = '' OR cCuenta IS null THEN
		SELECT concepto, cuenta
		INTO cConcepto, cCuenta
		FROM bdisac:"informix".sac_edomex_cuentas
		WHERE prefijo =  '000';
	END IF;

	
	IF cCuenta = '' OR cCuenta IS NULL THEN
		LET cCod_ret = '00002';
	END IF;

	RETURN cCod_ret,NVL(cConcepto,''), NVL(cCuenta,'');
	

	END;
END PROCEDURE
DOCUMENT
'Folio: 1468',
'Autor: Hugo Vazquez',
'Fecha: 20/02/2015',
'Descripción: Se crea procedimiento para obtener la descripción y la cuenta prestadora de pagos de sercivios EDOMEX',
'Sustento: PgImpMex_RQM_10525_PagoImpEdoMex_v1.0.doc',
'BD: bdisac',
'Folio: 1468',
'Modificò: Jesus Isaias Bueno',
'Fecha: 23/03/2015',
'Descripción: Se modifica procedimiento para obtener la descripción y la cuenta prestadora de pagos de sercivios EDOMEX',
'Sustento: PgImpMex_RQM_10525_PagoImpEdoMex_v1.0.doc',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_confirmacionbitacoratae(pFolioSucursal CHAR (16), pId_Sucursal CHAR (4), pFecha_Pago DATE)
RETURNING CHAR(5) as CodRet;

-- DeclaraciÃ³n de variables 
DEFINE cCodRet 		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE cCodResp		CHAR(5);
DEFINE iExisteCod	INTEGER;
DEFINE iNumTrama 	INTEGER;

LET cCodRet 	= '00000';
LET iSqlErr 	= 0;
LET cCodResp	= '';
LET iExisteCod	= 0;
LET iNumTrama 	= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN

			LET cCodRet = iSqlErr;
			RETURN cCodRet;	
				
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/Gilberto/1485/sp_confirmacionbitacoratae.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT cod_resp INTO cCodResp FROM bdisac:"informix".sac_pagostae WHERE id_sucursal = pId_Sucursal AND fechapago = pFecha_Pago AND folio_suc = pFolioSucursal AND num_trama = (SELECT max(num_trama) FROM bdisac:"informix".sac_pagostae where folio_suc=pFolioSucursal and id_sucursal =pId_Sucursal AND fechapago = pFecha_Pago);
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00000';
	ELSE
		SELECT fn_instr(valor, cCodResp, 1) INTO iExisteCod FROM  bdisac: "informix".sac_param where cod_param = '106';
		
		IF iExisteCod > 0 THEN
			LET cCodRet = '00001';
		ELSE
			LET cCodRet = '00000';
		END IF;
	END IF;

	RETURN cCodRet;
	
END
END PROCEDURE
DOCUMENT
'AUTOR : 95347143- Jesus Isaias Bueno',
'DESCRIPCION:  SP para consultar la bitacora de TAE y decidir si se puede reversar en base al codigo de respuesta ',
'FOLIO: 1485 - ModificacionVtaTiempoAireDobleConsulta',
'FECHA : 22/05/2015',
'VERSION: 20150522.1315',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_inserta_msw_respuesta( pNumCategoria  CHAR(2),
													  pNumConvenio	 CHAR(3),
													  pId_Sucursal	 CHAR(4),
													  pFolioSucursal CHAR (16),
													  pFechaPago	 DATE,
													  pNumTrama		 INTEGER,
													  pCadena_Req	 CHAR (1620),
													  pCadena_Rply	 CHAR (1620)
													)
   RETURNING CHAR(5) as cCodRet, CHAR(40) as cCodigoRespuesta;
   
-- DeclaraciÃ³n de variables 
	DEFINE cCodigoRespuesta CHAR (40);
	DEFINE cCodigoRespu CHAR (40);
	DEFINE cCodigoResp  CHAR (10);
	DEFINE cCodRet 		CHAR(5);
	DEFINE cCodReto		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iNumCamp 	INTEGER;
	DEFINE iLong_c		INTEGER;
	DEFINE cNomCamp 	CHAR(10);
	DEFINE iLong_aux	INTEGER;
	DEFINE cCampoAux	CHAR (40);
	DEFINE cTran_suc	CHAR (4);
	DEFINE cTran_cent	CHAR(4);
	DEFINE cTrans_Inte	CHAR(5);
	DEFINE cUser		CHAR(8);
	Define cCadena_Rp	CHAR(1620);
	DEFINE cNomSp_escenarios CHAR(100);
	DEFINE cQry			CHAR(200);
	DEFINE cCampo1  CHAR(40); DEFINE cCampo2  CHAR(40); DEFINE cCampo3  CHAR(40); DEFINE cCampo4  CHAR(40); DEFINE cCampo5  CHAR(40); 
	DEFINE cCampo6  CHAR(40); DEFINE cCampo7  CHAR(40); DEFINE cCampo8  CHAR(40); DEFINE cCampo9  CHAR(40); DEFINE cCampo10 CHAR(40);
	DEFINE cCampo11 CHAR(40); DEFINE cCampo12 CHAR(40); DEFINE cCampo13 CHAR(40); DEFINE cCampo14 CHAR(40); DEFINE cCampo15 CHAR(40);
	DEFINE cCampo16 CHAR(40); DEFINE cCampo17 CHAR(40); DEFINE cCampo18 CHAR(40); DEFINE cCampo19 CHAR(40); DEFINE cCampo20 CHAR(40); 
	DEFINE cCampo21 CHAR(40); DEFINE cCampo22 CHAR(40); DEFINE cCampo23 CHAR(40); DEFINE cCampo24 CHAR(40); DEFINE cCampo25 CHAR(40); 
	DEFINE cCampo26 CHAR(40); DEFINE cCampo27 CHAR(40); DEFINE cCampo28 CHAR(40); DEFINE cCampo29 CHAR(40); DEFINE cCampo30 CHAR(40);
	DEFINE cCampo31 CHAR(40); DEFINE cCampo32 CHAR(40); DEFINE cCampo33 CHAR(40); DEFINE cCampo34 CHAR(40); DEFINE cCampo35 CHAR(40);
	DEFINE cCampo36 CHAR(40); DEFINE cCampo37 CHAR(40); DEFINE cCampo38 CHAR(40); DEFINE cCampo39 CHAR(40); DEFINE cCampo40 CHAR(40); 
	

	LET cCodRet		= '00000';
	LET cCodReto	= '00000';
	LET cCodigoRespuesta = '';
	LET cCodigoRespu = '';
	LET cCodigoResp = '';
	LET cCadena_Rp	= pCadena_Rply;
	LET iSqlErr		= 0;
	LET iNumCamp	= 1;
	LET iLong_c		= 0;
	LET cNomCamp 	= '';
	LET iLong_aux	= 1;
	LET cCampoAux	= '';
	LET cTran_suc	= '';
	LET cTran_cent	= '';
	LET cTrans_Inte	= '';
	lET cUser		= '';
	Let cQry		= '';
	LET cNomSp_escenarios ='';
	LET cCampo1  =''; LET cCampo2  =''; LET cCampo3  =''; LET cCampo4  =''; LET cCampo5  =''; 
	LET cCampo6  =''; LET cCampo7  =''; LET cCampo8  =''; LET cCampo9  =''; LET cCampo10 ='';
	LET cCampo11 =''; LET cCampo12 =''; LET cCampo13 =''; LET cCampo14 =''; LET cCampo15 ='';
	LET cCampo16 =''; LET cCampo17 =''; LET cCampo18 =''; LET cCampo19 =''; LET cCampo20 =''; 
	LET cCampo21 =''; LET cCampo22 =''; LET cCampo23 =''; LET cCampo24 =''; LET cCampo25 =''; 
	LET cCampo26 =''; LET cCampo27 =''; LET cCampo28 =''; LET cCampo29 =''; LET cCampo30 ='';
	LET cCampo31 =''; LET cCampo32 =''; LET cCampo33 =''; LET cCampo34 =''; LET cCampo35 ='';
	LET cCampo36 =''; LET cCampo37 =''; LET cCampo38 =''; LET cCampo39 =''; LET cCampo40 =''; 
	
				
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0  THEN
			IF iSqlErr <> -674 THEN
				LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet, cCodigoRespuesta;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/Trinidad/sp_inserta_msw_respuesta.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		
		IF NVL (pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL (pFolioSucursal, '') = '' 
		  OR NVL (pId_Sucursal, '') = '' OR NVL (pFechaPago, '') = ''   OR NVL (pCadena_Req, '') = ''   THEN
			 LET cCodRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodRet, NVL(cCodigoRespuesta, '');
		END IF;
			
			--Saca la posicion del Codigo de respuesta correspondientes a las tablas bdisac: sac_intrfz_serv 
			SELECT campo_codresp INTO cCodigoResp FROM  bdisac: "informix".sac_intrfz_serv WHERE numcategoria= pNumCategoria AND numconvenio=pNumConvenio AND num_trama= pNumTrama;
		
			FOREACH
					-- OPtiene el campo y la lonjitud de los campos para ser separados
					SELECT campo, longitud INTO cNomCamp, iLong_c FROM bdisac: "informix".sac_intrfz_serv_det_resp WHERE numcategoria= pNumCategoria AND numconvenio= pNumConvenio AND num_trama= pNumTrama ORDER BY id_campo ASC
							
					
						LET cCampoAux = SUBSTR(cCadena_Rp,iLong_aux,iLong_c);
						LET iLong_aux = iLong_c + iLong_aux;	
						IF cCodigoResp = cNomCamp THEN
							LET cCodigoRespuesta = cCampoAux;
						END IF;

					IF iNumCamp =   1  THEN 
						LET cCampo1  = cCampoAux;
					ELIF iNumCamp = 2  THEN 
						LET cCampo2  = cCampoAux;
					ELIF iNumCamp = 3  THEN 
						LET cCampo3  = cCampoAux;
					ELIF iNumCamp = 4  THEN 
						LET cCampo4  = cCampoAux;	
					ELIF iNumCamp = 5  THEN 
						LET cCampo5  = cCampoAux; 		
					ELIF iNumCamp = 6  THEN 
						LET cCampo6  = cCampoAux;	
					ELIF iNumCamp = 7  THEN 
						LET cCampo7  = cCampoAux;	
					ELIF iNumCamp = 8  THEN 
						LET cCampo8  = cCampoAux;	
					ELIF iNumCamp = 9  THEN 
						LET cCampo9  = cCampoAux;	
					ELIF iNumCamp = 10 THEN 
						LET cCampo10 = cCampoAux;	
					ELIF iNumCamp = 11 THEN 
						LET cCampo11 = cCampoAux;
					ELIF iNumCamp = 12 THEN 
						LET cCampo12 = cCampoAux;	
					ELIF iNumCamp = 13 THEN 
						LET cCampo13 = cCampoAux;	
					ELIF iNumCamp = 14 THEN 
						LET cCampo14 = cCampoAux;	
					ELIF iNumCamp = 15 THEN 
						LET cCampo15 = cCampoAux;	
					ELIF iNumCamp = 16 THEN 
						LET cCampo16 = cCampoAux;	
					ELIF iNumCamp = 17 THEN 
						LET cCampo17 = cCampoAux;	
					ELIF iNumCamp = 18 THEN 
						LET cCampo18 = cCampoAux;	
					ELIF iNumCamp = 19 THEN 
						LET cCampo19 = cCampoAux;	
					ELIF iNumCamp = 20 THEN 
						LET cCampo20 = cCampoAux;	
					ELIF iNumCamp = 21 THEN 
						LET cCampo21 = cCampoAux;	
					ELIF iNumCamp = 22 THEN 
						LET cCampo22 = cCampoAux;	
					ELIF iNumCamp = 23 THEN 
						LET cCampo23 = cCampoAux;	
					ELIF iNumCamp = 24 THEN 
						LET cCampo24 = cCampoAux;	
					ELIF iNumCamp = 25 THEN 
						LET cCampo25 = cCampoAux;	
					ELIF iNumCamp = 26 THEN 
						LET cCampo26 = cCampoAux;	
					ELIF iNumCamp = 27 THEN 
						LET cCampo27 = cCampoAux;	
					ELIF iNumCamp = 28 THEN 
						LET cCampo28 = cCampoAux;	
					ELIF iNumCamp = 29 THEN 
						LET cCampo29 = cCampoAux;	
					ELIF iNumCamp = 30 THEN 
						LET cCampo30 = cCampoAux;	
					ELIF iNumCamp = 31 THEN 
						LET cCampo31 = cCampoAux;	
					ELIF iNumCamp = 32 THEN 
						LET cCampo32 = cCampoAux;	
					ELIF iNumCamp = 33 THEN 
						LET cCampo33 = cCampoAux;	
					ELIF iNumCamp = 34 THEN 
						LET cCampo34 = cCampoAux;	
					ELIF iNumCamp = 35 THEN 
						LET cCampo35 = cCampoAux;	
					ELIF iNumCamp = 36 THEN 
						LET cCampo36 = cCampoAux;	
					ELIF iNumCamp = 37 THEN 
						LET cCampo37 = cCampoAux;	
					ELIF iNumCamp = 38 THEN 
						LET cCampo38 = cCampoAux;	
					ELIF iNumCamp = 39 THEN 
						LET cCampo39 = cCampoAux;	
					ELIF iNumCamp = 40 THEN 
						LET cCampo40 = cCampoAux;	
					ELSE 
						LET cCodRet= '00001';
					END IF;
							
					LET iNumCamp = iNumCamp + 1;
			END FOREACH;
			
			If  NVL (cCodigoResp, '') = '' THEN
				LET cCodigoRespuesta = cCampo1;
			END IF;

			
			-- Solicita y guarda el valor de trans_suc_efectivo de bdisac: sac_convenios
			SELECT trans_suc_efectivo INTO cTran_suc FROM bdisac: "informix".sac_convenios WHERE numcategoria= pNumCategoria and numconvenio= pNumConvenio;

			-- Colicita y guarda el valor de trans_interact de bdisac: sac_intrfz_serv
			SELECT trans_interact, sp_escenarios INTO   cTrans_Inte, cNomSp_escenarios FROM  bdisac: "informix".sac_intrfz_serv WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND num_trama= pNumTrama;
				
			--Solicita y guarda el valor de usuario de bdisac: sac_movimientos 
			SELECT usuario INTO cUser FROM bdisac: "informix".sac_movimientos WHERE id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND fecha_pago= pFechaPago;
				
			SELECT trans_central INTO cTran_cent FROM bdisac: "informix".sac_msw_solicitud where   numcategoria= pNumCategoria and numconvenio= pNumConvenio and folio_suc= pFolioSucursal and fecha_pago= pFechaPago AND num_trama= pNumTrama;
				
				IF cCodRet <> '00000' THEN
					LET cCodigoRespuesta = '';
				ELSE 
					-- Inserta los valores de la trama (pCadena_Rply) a la bdisac: sac_msw_respuesta
					 INSERT INTO bdisac: "informix".sac_msw_respuesta(numcategoria, numconvenio, id_sucursal, trans_suc, trans_central, trans_interact, folio_suc, fecha_pago, num_trama, campo1, campo2, campo3, campo4, campo5, campo6 , campo7, campo8, campo9, campo10, campo11, campo12, campo13, campo14, campo15, campo16, campo17, campo18, campo19, campo20, campo21, campo22, campo23, campo24, campo25, campo26, campo27, campo28, campo29, campo30, campo31, campo32, campo33, campo34, campo35, campo36, campo37, campo38, campo39, campo40, cadena_req, cadena_rply, user_insert, fecha_insert)
					VALUES (pNumCategoria, pNumConvenio, pId_Sucursal, cTran_suc, cTran_cent, cTrans_Inte, pFolioSucursal, pFechaPago, pNumTrama,cCampo1, cCampo2, cCampo3, cCampo4, cCampo5, cCampo6, cCampo7, cCampo8, cCampo9, cCampo10, cCampo11, cCampo12, cCampo13, cCampo14, cCampo15, cCampo16, cCampo17, cCampo18, cCampo19, cCampo20, cCampo21, cCampo22, cCampo23, cCampo24, cCampo25, cCampo26, cCampo27, cCampo28, cCampo29, cCampo30, cCampo31, cCampo32, cCampo33, cCampo34, cCampo35, cCampo36, cCampo37, cCampo38, cCampo39, cCampo40, pCadena_Req, pCadena_Rply, cUser, current );
				END IF;
				
		IF (TRIM(cNomSp_escenarios) <> '') AND (cNomSp_escenarios <> ' ' ) Then
			LET cQry = 'EXECUTE PROCEDURE bdisac: "informix".'||cNomSp_escenarios;
			
			PREPARE stmt_id FROM cQry;
			DECLARE cust_cur cursor FOR stmt_id;
			OPEN cust_cur USING pNumCategoria, pNumConvenio, pId_Sucursal,  pFolioSucursal, pFechaPago,  pNumTrama;
			FETCH cust_cur INTO cCodReto, cCodigoRespuesta;
			
			-- cerrar el cursor "cust_cur"
			CLOSE cust_cur;
			-- Libera los recursos asignados para el cursor "cust_cur"
			FREE cust_cur ;
			-- Libera los recursos asignados para la declaraciÃ³n "statement_id"
			FREE stmt_id ;		
			
			IF cCodReto <> '00000' THEN
				If pNumTrama = 1 THEN
					LET cCodigoRespuesta = '00009';
				else 
					LET cCodigoRespuesta = '00010';
				End If;
			End IF;
		END IF;
		
		RETURN cCodRet, NVL(cCodigoRespuesta, '');
			
END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: SP separa los campos de la trama que regresa como resultado el central de acuerdo con la configuraciÃ³n de la tabla bdisac: sac_intrfz_serv_det_resp.',
'FOLIO: 1485- ModificacionVtaTiempoAireDobleConsulta',
'FECHA : 21/05/2015',
'VERSION: 20150521.1621',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtiene_intrfz_serv( pNumCategoria Char(2),
													pNumConvenio Char(3),
													pNumTama INTEGER)
   RETURNING CHAR(5) as CodRet, CHAR(5) as Trans_Interact, CHAR(16) as Ip, INTEGER as Puerto, INTEGER as TimeOut, CHAR(4) as Cod_cons_trama, CHAR(100) as sp_escenarios, CHAR(30) as Campo_codresp, CHAR(4) as Cod_cons_codresp, CHAR(4) as Cod_cons_bitacora, CHAR(40) as Codresp_noenviada, CHAR(40) as Codresp_timeout, CHAR(1) as Aidaban, CHAR(4) as Cod_cons_idtran;

-- DeclaraciÃ³n de variables 
DEFINE cCodRet 			 CHAR(5);
DEFINE cTrans_Interact	 CHAR(5);
DEFINE cIp 				 CHAR(16);
DEFINE iPuerto 			 INTEGER;
DEFINE iTimeOut 		 INTEGER;
DEFINE cCod_cons_trama 	 CHAR(4);
DEFINE cSp_escenarios	 CHAR(100);
DEFINE cCampo_codresp  	 CHAR(30);
DEFINE cCod_cons_codresp CHAR(4);
DEFINE iSqlErr           INTEGER;
DEFINE cCod_cons_bitacora CHAR (4);
DEFINE cCodresp_noenviada CHAR(40);
DEFINE cCodresp_timeout	 CHAR(40);
DEFINE cAidaban			 CHAR(1);
DEFINE cCod_cons_idtran	 CHAR(4);

LET cCodRet 		  = '00001';
LET cTrans_Interact   ='';
LET cIp 			  ='';
LET iPuerto 		  = 0;
LET iTimeOut 		  = 0;
LET cCod_cons_trama   ='';
LET cSp_escenarios	  ='';
LET cCampo_codresp 	  ='';
LET cCod_cons_codresp ='';
LET iSqlErr 		  = 0;
LET cCod_cons_bitacora = '';
LET cCodresp_noenviada ='';
LET cCodresp_timeout  ='';
LET cAidaban		  ='';
LET cCod_cons_idtran  ='';
  
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTrans_Interact, cIp, iPuerto, iTimeOut, cCod_cons_trama, cSp_escenarios, cCampo_codresp, cCod_cons_codresp, cCod_cons_bitacora, cCodresp_noenviada, cCodresp_timeout, cAidaban, cCod_cons_idtran;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_obtiene_intrfz_serv.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  	

	SELECT trans_interact, ip, puerto, time_out, cod_cons_trama, sp_escenarios, campo_codresp, cod_cons_codresp,cod_cons_bitacora, codresp_noenviada, codresp_timeout, aidaban, cod_cons_idtran
	INTO cTrans_Interact, cIp, iPuerto, iTimeOut, cCod_cons_trama, cSp_escenarios, cCampo_codresp, cCod_cons_codresp,cCod_cons_bitacora, cCodresp_noenviada, cCodresp_timeout, cAidaban, cCod_cons_idtran
	FROM bdisac: "informix".sac_intrfz_serv where numcategoria= pNumCategoria and numconvenio= pNumConvenio and num_trama = pNumTama;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 OR cTrans_Interact= '' OR cIp = '' OR iPuerto= '' OR iTimeOut= '' OR cCod_cons_trama= '' THEN
		LET cCodRet = '00001';
	ELSE
		LET cCodRet = '00000';
	END IF
	
	RETURN cCodRet, cTrans_Interact, cIp, iPuerto, iTimeOut, cCod_cons_trama, cSp_escenarios, cCampo_codresp, cCod_cons_codresp, cCod_cons_bitacora, cCodresp_noenviada, cCodresp_timeout, cAidaban, cCod_cons_idtran;
		
	END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION:  Con el numero de categorÃ­a y numero de convenio obtendrÃ¡ la configuraciÃ³n desde la tabla bdisac: sac_intrfz_serv.',
'FOLIO: 1485 - ModificacionVtaTiempoAireDobleConsulta',
'FECHA : 20/05/2015',
'VERSION: 20150209.1452',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtiene_msw_validacion( pCodigoRespuesta	Char(40),
												  pNumCategoria  CHAR(2),
												  pNumConvenio	 CHAR(3),
												  pNumTrama		 INTEGER)
   RETURNING CHAR(5) as cCodRet, INTEGER as iEnviaTrama, CHAR (1) as cReversa, CHAR (4) as cCod_err, CHAR (4) as cCod_err_reversa, CHAR(80) as cEnc_errores;

-- DeclaraciÃ³n de variables 
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cReversa			CHAR (1);
	DEFINE cCod_err			CHAR (4);
	DEFINE cCod_err_reversa	CHAR (4);
	DEFINE cEnc_errores		CHAR (80);
	DEFINE iEnviaTrama		INTEGER;

	LET cCodRet				= '11111';
	LET iSqlErr				= 0;
	LET cReversa			= '';
	LET cCod_err			= '';
	LET cCod_err_reversa	= '';
	LET cEnc_errores		= '';
	LET iEnviaTrama			= 0;
						
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iEnviaTrama, cReversa, cCod_err, cCod_err_reversa, cEnc_errores;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/sp_obtiene_msw_validacion.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		  
    IF NVL (pCodigoRespuesta, '') = '' OR NVL (pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' THEN
			 LET cCodRet = '00001';
	ELSE
		SELECT envia_trama, reversa, cod_err, cod_err_reversa, enc_errores 
		INTO iEnviaTrama, cReversa, cCod_err, cCod_err_reversa, cEnc_errores 
		FROM bdisac: "informix".sac_msw_validacion  
		WHERE clave= pCodigoRespuesta AND numcategoria= pNumCategoria AND numconvenio= pNumConvenio AND num_trama= pNumTrama;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
		ELSE 
			LET cCodRet = '00000';
		END IF;
	END IF;
	
	RETURN cCodRet, iEnviaTrama, cReversa, cCod_err, cCod_err_reversa, cEnc_errores;
		
END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: SP regresa los datos de error que se almacenaron en bdisac: sac_msw_validacion con respecto al codigo de respuesta, nÃºmero de categoria, y nÃºmero de convenio.',
'FOLIO: 1468- ModificacionVtaTiempoAireDobleConsulta',
'FECHA : 20/05/2015',
'VERSION: 20150520.1621',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtiene_tae_catrespws( pCodigoRespuesta	Char(40), pNumTrama INTEGER)
   RETURNING CHAR(5) as cCodRet, CHAR(80) as cConseptoRespuesta;
      
-- DeclaraciÃ³n de variables 
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cConseptoRespuesta	CHAR(80);

	LET cCodRet				= '00000';
	LET iSqlErr				= 0;
	LET cConseptoRespuesta	= '';
					
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cConseptoRespuesta;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/sp_obtiene_tae_catrespws.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		  
    IF NVL (pCodigoRespuesta, '') = '' THEN
			 LET cCodRet = '00001';
	ELSE
		SELECT concepto INTO cConseptoRespuesta FROM  bdisac: "informix".sac_tae_catrespws where clave= pCodigoRespuesta and num_trama = pNumTrama;
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
		ELSE 
			LET cCodRet = '00000';
		END IF;
	END IF;
	
	RETURN cCodRet, NVL(cConseptoRespuesta, '');
		
END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: SP regresa el concepto de el codigo de respuesta a consultar de bdisac: sac_tae_catrespws.',
'FOLIO: 1485 - ModificacionVtaTiempoAireDobleConsulta',
'FECHA : 19/05/2015',
'VERSION: 20150212.1621',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtienefolio_tae()
   RETURNING CHAR(5) as cCodRet, CHAR (9) as cFolio;
   
-- DeclaraciÃ³n de variables 
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cInfoErr     CHAR(100);
	DEFINE iIsamErr     INTEGER;
	DEFINE iContInc		INTEGER;
	DEFINE iContFin		INTEGER;
	DEFINE cFolio		CHAR (9);
	DEFINE bBegin 	     	BOOLEAN;
	
	LET cCodRet		= '00000';
	LET iSqlErr		= 0;
	LET cInfoErr	= '';
	LET iIsamErr	= 0;
	LET iContInc	= 0;
	LET iContFin	= 0;
	LET cFolio		= '';
	LET bBegin = 'F';
		
	--SET DEBUG FILE TO '/respaldosbd/Trinidad/sp_obtienefolio_tae.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
	
	BEGIN
	             
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_obtieneFolioCoppel");
				IF (bBegin = 'F') THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet, -1;
			END IF;
		END EXCEPTION;
		
		--EXCEPTION CIERRA SI LA TRANSACION ESTA ABIERTA.
		ON EXCEPTION IN (-535)
			LET bBegin = 'T';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		BEGIN WORK;
			-- Consultar los parametros del rango del folio		
			SELECT cast(valor as int) INTO iContInc FROM bdisac: "informix".sac_recibo_coppel where cod_param = 3;
			SELECT cast(valor as int) INTO iContFin FROM bdisac: "informix".sac_recibo_coppel where cod_param = 4;
						
			IF iContInc < iContFin THEN
				LET cFolio = CAST(iContInc as varchar(10));
				LET iContInc = iContInc + 1;
				UPDATE bdisac: "informix".sac_recibo_coppel SET valor= iContInc  WHERE cod_param = 3;
			ELSE 
				IF iContInc = iContFin THEN
					LET cFolio = CAST(iContInc as varchar(10));
					LET iContInc = 1;
					UPDATE bdisac: "informix".sac_recibo_coppel SET valor=iContInc WHERE cod_param = 3;
				END IF;
			END IF;
			
		COMMIT WORK;
			IF bBegin = 'T' THEN
				BEGIN WORK;
			END IF	
			
			RETURN cCodRet, cFolio;
	END;
 END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: Obtiene los consecutivos del folio y el id de la transacciÃ³n de la tabla sac_recibo_coppel de la bdisac',
'FOLIO: 1485 - ModificacionVtaTiempoAireDobleConsulta',
'FECHA : 18/05/2015',
'VERSION: 20150518.1204',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_sacreportecobranzasucursal (cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE, siRegistros SMALLINT,stipo smallint)

-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno,            --Codigo de Retorno
CHAR(40) AS nombre,             --Nombre convenio
CHAR(5)  AS IdConvenio,
CHAR(16) AS folio_suc,          --Folio de sucursal
CHAR(40) AS referencia1,        --Num telefono (Telmex), Num cliente(Coppel)
CHAR(40) AS referencia2,        --DV (Telmex), Recibo(Coppel)
CHAR(30) AS IdReferencia1,      --Nombre Referencia 1
CHAR(30) AS IdReferencia2,      --Nombre Referencia 2
MONEY(16,2) AS montoCargo,      --Monto de cargo a cuenta
MONEY(16,2) AS montoEfectivo,   --Monto de pago en efectivo
CHAR(1) AS forma_pago,
CHAR(40) AS region,             --Region de la sucursal
CHAR(4) AS sucursal,            --Numero de la sucursal
SMALLINT AS ciclo;

-- DEFINICION DE VARIABLES
DEFINE cCodRet                  CHAR(5);
DEFINE iSqlErr                  INTEGER;
DEFINE iIsamErr                 INTEGER;

DEFINE iTransCargoTelmex	INTEGER;
DEFINE iTransCargoCoppel	INTEGER;
DEFINE iTransEfecTelmex		INTEGER;
DEFINE iTransEfecCoppel		INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iRegistrosHoy		INTEGER;
DEFINE iRegistrosAnt		INTEGER;
DEFINE cTransCargoTelmex	CHAR(4);
DEFINE cTransCargoCoppel	CHAR(4);
DEFINE cTransEfecTelmex		CHAR(4);
DEFINE cTransEfecCoppel		CHAR(4);
DEFINE cInfoErr				CHAR(100);
DEFINE cCodRetParam			CHAR(5);
DEFINE cIdConvenio			CHAR(5);
DEFINE cFormaPago			CHAR(3);
DEFINE cNumTransaccEfec		CHAR(4);
DEFINE cIdReferencia1		CHAR(100);
DEFINE cIdReferencia2		CHAR(100);
DEFINE cRegion				CHAR(40);
DEFINE cFolioSuc			CHAR(16);
DEFINE cReferencia1			CHAR(40);
DEFINE cReferencia2			CHAR(40);
DEFINE cNomconvenio			CHAR(40);
DEFINE mCargoCuenta			MONEY(16,2);
DEFINE mCargoEfectivo		MONEY(16,2);
DEFINE siCiclo				SMALLINT;
DEFINE cFecha_Hoy			CHAR(10);
DEFINE ctransEfecEnvioOrden			CHAR(4);
DEFINE ctransEfecEnvioComision		CHAR(4);
DEFINE ctransEfecEnvioIVA			CHAR(4);
DEFINE ctransCargoEnvioOrden		CHAR(4);
DEFINE ctransCargoEnvioComision		CHAR(4);
DEFINE ctransCargoEnvioIVA			CHAR(4);
DEFINE ctransEfecPagoOrden			CHAR(4);
DEFINE ctransEfecCancelacionOrden	CHAR(4);
DEFINE cTransCargoSky    			CHAR(4);
DEFINE cTransEfecSky            	CHAR(4);
DEFINE itransEfecEnvioOrden			INTEGER;
DEFINE itransEfecEnvioComision		INTEGER;
DEFINE itransEfecEnvioIVA			INTEGER;
DEFINE itransCargoEnvioOrden		INTEGER;
DEFINE itransCargoEnvioComision		INTEGER;
DEFINE itransCargoEnvioIVA			INTEGER;
DEFINE itransEfecPagoOrden			INTEGER;
DEFINE itransEfecCancelacionOrden	INTEGER;
DEFINE cTransCargo					CHAR(4);
DEFINE cTransEfec					CHAR(4);
DEFINE siProcesoAutomatico			SMALLINT;
DEFINE cConsmovhis      			CHAR(10);
--HOMOLOGACION GDF
DEFINE cTranCredPGDF   				CHAR(100);
--HOMOLOGACION CLUB DE PROTECCION
DEFINE cTranCredPCP   				CHAR(100);

--HOMOLOGACION TAE
DEFINE cTranCredPTAE   				CHAR(100);

--HOMOLOGACION EDOMEX
DEFINE cTranCredEDOMEX				CHAR(100);

DEFINE mCargoCuentaCred			    MONEY(16,2);

--INICIALIZACION DE VARIABLES--
LET cCodRet               = "00000";
LET cCodRetParam          = "";
LET cIdConvenio           = "";
LET cIdReferencia1        = "";
LET cIdReferencia2        = "";
LET cFolioSuc             = "";
LET cReferencia1          = "";
LET cReferencia2          = "";
LET cNomconvenio          = "";
LET cFormaPago            = "0";
LET cRegion               = "";
LET cTransCargoTelmex     = "";
LET cTransCargoCoppel     = "";
LET cTransEfecTelmex	  = "";
LET cTransEfecCoppel	  = "";

LET ctransEfecEnvioOrden		= "";
LET ctransEfecEnvioComision     = "";
LET ctransEfecEnvioIVA			= "";
LET ctransCargoEnvioOrden		= "";
LET ctransCargoEnvioComision    = "";
LET ctransCargoEnvioIVA			= "";
LET ctransEfecPagoOrden			= "";
LET ctransEfecCancelacionOrden  = "";
LET cTransCargoSky    			= "";
LET cTransEfecSky            	= "";

/*
LET iTransCargoTelmex     = 0;
LET iTransCargoCoppel     = 0;
LET iTransEfecTelmex     = 0;
LET iTransEfecCoppel     = 0;

LET itransEfecEnvioOrden		= 0;
LET itransEfecEnvioComision		= 0;
LET itransEfecEnvioIVA			= 0;
LET itransCargoEnvioOrden		= 0;
LET itransCargoEnvioComision	= 0;
LET itransCargoEnvioIVA			= 0;
LET itransEfecPagoOrden			= 0;
LET itransEfecCancelacionOrden  = 0;
*/
LET mCargoCuenta          = 0;
LET mCargoEfectivo        = 0;
LET siCiclo               = 0;
LET iCuantos			  = 0;
LET cFecha_Hoy            = "";
LET iRegistrosHoy		 = 0;
LET iRegistrosAnt		 = 0;
LET cTransCargo			 = "";
LET cTransEfec			 = "";
LET siProcesoAutomatico	 = 0;
--HOMOLOGACION GDF
LET cTranCredPGDF   	 = "";
--HOMOLOGACION CLUB DE PROTECCION
LET cTranCredPCP		= ""; 
LET mCargoCuentaCred	 = 0;
--HOMOLOGACION TAE
LET cTranCredPTAE   	 = "";
LET cTranCredEDOMEX 	 ="";

BEGIN


	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportecobranzasucursal");
				RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo;
		END IF;

	END EXCEPTION;


--SET DEBUG FILE TO  '/respaldosbd/Martha/sacreporte_suc.out';
--TRACE ON;
	SET LOCK MODE TO WAIT 5;

	IF  cSucursal = "" OR LENGTH(cSucursal) <> 4 THEN
			LET cCodRet = "00001";
			RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo;
	ELSE
		SET ISOLATION TO DIRTY READ ;
		SELECT  fecha_hoy
		INTO cFecha_hoy
		FROM bdisac:"informix".sac_fechas;

		SELECT COUNT(*)
		INTO iRegistrosHoy
		FROM bdisac:"informix".sac_movimientos
		WHERE fecha_pago = cFecha_hoy
		AND id_sucursal = cSucursal;

		SELECT valor
		INTO cConsmovhis
		FROM bdicheq:"informix".sc_param
		WHERE codparam = 'fechcon_movhis' AND empresa = '001';

		SET ISOLATION TO DIRTY READ;

		SELECT LPAD (TRIM(CAST(NVL(SUM(CAST(transCargoTelmex AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoTelmex,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoCoppel AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoCoppel,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecCoppel AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecCoppel,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecTelmex AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecTelmex,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecEnvioOrden AS INTEGER)), 0)AS CHAR(4))), 4, '0') AS transEfecEnvioOrden,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecEnvioComision AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecEnvioComision,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecEnvioIVA AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecEnvioIVA,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoEnvioOrden AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoEnvioOrden,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoEnvioComision AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoEnvioComision,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoEnvioIVA AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoEnvioIVA,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecPagoOrden AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecPagoOrden,
			LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecCancelacionOrden AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecCancelacionOrden,
			LPAD (TRIM(CAST(NVL(SUM(CAST(transCargoSky AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoSky,
			LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecSky AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecSky
		INTO cTransCargoTelmex,
				cTransCargoCoppel,
				cTransEfecCoppel,
				cTransEfecTelmex,
				ctransEfecEnvioOrden,
				ctransEfecEnvioComision,
				ctransEfecEnvioIVA,
				ctransCargoEnvioOrden,
				ctransCargoEnvioComision,
				ctransCargoEnvioIVA,
				ctransEfecPagoOrden,
				ctransEfecCancelacionOrden,
				cTransCargoSky,
				cTransEfecSky
		FROM TABLE(MULTISET(SELECT CASE WHEN cod_param = 80001 THEN TRIM(VALOR) END AS transCargoTelmex,
									CASE WHEN cod_param = 80002 THEN TRIM(VALOR) END AS transCargoCoppel,
									CASE WHEN cod_param = 901001 THEN TRIM(VALOR) END AS transEfecCoppel,
									CASE WHEN cod_param = 902001 THEN TRIM(VALOR) END AS transEfecTelmex,
									CASE WHEN cod_param = 5070011 THEN TRIM(VALOR) END AS transEfecEnvioOrden,
									CASE WHEN cod_param = 511070011 THEN TRIM(VALOR) END AS transEfecEnvioComision,
									CASE WHEN cod_param = 510070011 THEN TRIM(VALOR) END AS transEfecEnvioIVA,
									CASE WHEN cod_param = 5070012 THEN TRIM(VALOR) END AS transCargoEnvioOrden,
									CASE WHEN cod_param = 511070012 THEN TRIM(VALOR) END AS transCargoEnvioComision,
									CASE WHEN cod_param = 510070012 THEN TRIM(VALOR) END AS transCargoEnvioIVA,
									CASE WHEN cod_param = 41407002 THEN TRIM(VALOR) END AS transEfecPagoOrden,
				CASE WHEN cod_param = 41507003 THEN TRIM(VALOR) END AS transEfecCancelacionOrden,
				CASE WHEN cod_param = 80006 THEN TRIM(VALOR) END AS transCargoSky,
				CASE WHEN cod_param = 906001 THEN TRIM(VALOR) END AS transEfecSky
		FROM bdisac:"informix".sac_param));

		IF dFechaIni < cFecha_hoy THEN

			SELECT COUNT(*)
			INTO iRegistrosAnt
			FROM bdisac:"informix".sac_movimientoshistorial
			WHERE fecha_pago BETWEEN dFechaIni AND dFechaFin;

			SET LOCK MODE TO WAIT  ;
			SET ISOLATION TO DIRTY READ ;

			SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc2)} COUNT(*) INTO iCuantos
			FROM bdisac:"informix".sac_movhissuc
			WHERE sucursal = cSucursal
			AND fech_alt = dFechaIni;

			IF iCuantos = 0 THEN

				SET ISOLATION TO DIRTY READ ;
				IF dFechaIni >= cConsmovhis THEN
					SELECT sucursal, transacc, monto_tot, fech_alt, folio_suc
					FROM bdicheq:"informix".sc_movhis
					WHERE empresa = '001'
					AND cuenta IS NOT NULL
					AND fech_alt = dFechaIni
					AND cancelad IS NOT NULL
					AND transacc IN (cTransCargoCoppel,
										cTransCargoTelmex,
										cTransEfecTelmex,
										cTransEfecCoppel,
										ctransEfecEnvioOrden,
										ctransEfecEnvioComision,
										ctransEfecEnvioIVA,
										ctransCargoEnvioOrden,
										ctransCargoEnvioComision,
										ctransCargoEnvioIVA,
										ctransEfecPagoOrden,
										ctransEfecCancelacionOrden,
										cTransCargoSky,
										cTransEfecSky)
					AND sucursal = cSucursal
					INTO TEMP tmp_sac_movhis
					WITH NO LOG;
				 ELSE
					SELECT sucursal, transacc, monto_tot, fech_alt, folio_suc
											FROM bdicheq:"informix".sc_movhis_old
											WHERE empresa = '001'
											AND cuenta IS NOT NULL
											AND fech_alt = dFechaIni
											AND cancelad IS NOT NULL
											AND transacc IN (cTransCargoCoppel,
																cTransCargoTelmex,
																cTransEfecTelmex,
																cTransEfecCoppel,
																ctransEfecEnvioOrden,
																ctransEfecEnvioComision,
																ctransEfecEnvioIVA,
																ctransCargoEnvioOrden,
																ctransCargoEnvioComision,
																ctransCargoEnvioIVA,
																ctransEfecPagoOrden,
																ctransEfecCancelacionOrden,
																cTransCargoSky,
																cTransEfecSky)
											AND sucursal = cSucursal
											INTO TEMP tmp_sac_movhis
											WITH NO LOG;
				 END IF;

				DELETE FROM bdisac:"informix".sac_movhissuc WHERE sucursal = cSucursal;

				SET LOCK MODE TO WAIT  ;
				SET ISOLATION TO DIRTY READ ;

				INSERT INTO bdisac:"informix".sac_movhissuc(sucursal, transacc, monto_tot, fech_alt, folio_suc)
				SELECT sucursal, transacc, monto_tot, fech_alt, folio_suc
				FROM bdisac:"informix".tmp_sac_movhis;

				DROP TABLE bdisac:"informix".tmp_sac_movhis;

			END IF;
			IF iRegistrosHoy > 0 OR  iRegistrosAnt > 0 THEN
				SET ISOLATION TO DIRTY READ ;
				FOREACH
					SELECT  b.folio_suc, f.numcategoria||f.numconvenio AS numconvenio, f.nomconvenio, b.referencia1,
						b.referencia2, b.forma_pago, e.nombre, f.trans_cen_cargo_cliente, f.trans_cen_efectivo_cliente, f.proceso_automatico,
						f.nombre_referencia1, f.nombre_referencia2
					INTO cFolioSuc, cIdConvenio, cNomconvenio,cReferencia1, cReferencia2, cFormaPago, cRegion, cTransCargo, cTransEfec,
						siProcesoAutomatico, cIdReferencia1, cIdReferencia2
					FROM bdisac:"informix".sac_movimientos b, bdinteg:"informix".si_sucursales c, bdinteg:"informix".si_plazas d, bdinteg:"informix".si_regional e, bdisac:"informix".sac_convenios f
					WHERE b.id_sucursal = cSucursal
					AND b.numcategoria = f.numcategoria
					AND b.numconvenio = f.numconvenio
					AND b.status_cancelado <> 'S'
					AND c.sucursal = b.id_sucursal
					AND d.plaza = c.plaza
					AND e.empresa IS NOT NULL
					AND e.regional = d.regional
					UNION ALL
					SELECT  b.folio_suc, f.numcategoria||f.numconvenio AS numconvenio, f.nomconvenio, b.referencia1,
						b.referencia2, b.forma_pago, e.nombre, f.trans_cen_cargo_cliente, f.trans_cen_efectivo_cliente, f.proceso_automatico,
						f.nombre_referencia1, f.nombre_referencia2
					FROM bdisac:"informix".sac_movimientoshistorial b, bdinteg:"informix".si_sucursales c, bdinteg:"informix".si_plazas d, bdinteg:"informix".si_regional e, bdisac:"informix".sac_convenios f
					WHERE b.numcategoria = f.numcategoria
					AND b.id_sucursal = cSucursal
					AND b.numconvenio = f.numconvenio
					AND b.status_cancelado <> 'S'
					AND b.fecha_pago BETWEEN dFechaIni AND  dFechaFin
					AND c.sucursal = b.id_sucursal
					AND d.plaza = c.plaza
					AND e.empresa IS NOT NULL
					AND e.regional = d.regional
					ORDER BY folio_suc
					IF siProcesoAutomatico = 1 THEN

						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = cTransCargo  THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = cTransEfec  THEN monto_tot END AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE folio_suc = cFolioSuc and empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = cTransCargo  THEN monto_tot END AS monto_totCargo,
													CASE WHEN transacc = cTransEfec  THEN monto_tot END AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc
											WHERE  folio_suc = cFolioSuc));						
						 
						--HOMOLOGACION GDF
						--20130109.1030 inicio
						IF	cIdConvenio = '08001' THEN

							SELECT NVL(TRIM(valor),'')
							INTO cTranCredPGDF 
							FROM bdisac:"informix".sac_param 
							WHERE cod_param = '87033';

							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
							INTO mCargoCuentaCred
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredPGDF  
												THEN monto END AS monto_totCargo
												FROM bdicred:"informix".sd_movdia
												WHERE folio_suc = cFolioSuc AND empresa='001'));

						END IF;
						--20130109.1030 fin
					  
						--HOMOLOGACION CLUB DE PROTECCION
						--20140902.1256 inicio									
						IF	cIdConvenio = '01002' THEN
						 
							SELECT NVL(TRIM(valor),'')
							INTO cTranCredPCP 
							FROM bdisac:"informix".sac_param 
							WHERE cod_param = 80;
							
							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
							INTO mCargoCuentaCred
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredPCP  
												THEN monto END AS monto_totCargo
												FROM bdicred:"informix".sd_movdia
												WHERE folio_suc = cFolioSuc AND empresa='001'));

						END IF;
						--20140902.1256 fin
						
						--HOMOLOGACION TAE
						--20150120.1506 inicio
						IF	cIdConvenio = '03001' THEN

							SELECT NVL(TRIM(valor),'')
							INTO cTranCredPTAE 
							FROM bdisac:"informix".sac_param 
							WHERE cod_param = 22;

							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
							INTO mCargoCuentaCred
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredPTAE  
												THEN monto END AS monto_totCargo
												FROM bdicred:"informix".sd_movdia
												WHERE folio_suc = cFolioSuc AND empresa='001'));

						END IF;
						--20150120.1506 FIN
						
						--HOMOLOGACION EDOMEX
						--20150216.1534 inicio
						IF	cIdConvenio = '08002' THEN

							SELECT NVL(TRIM(valor),'')
							INTO cTranCredEDOMEX 
							FROM bdisac:"informix".sac_param 
							WHERE cod_param = 23;

							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
							INTO mCargoCuentaCred
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredEDOMEX  
												THEN monto END AS monto_totCargo
												FROM bdicred:"informix".sd_movdia
												WHERE folio_suc = cFolioSuc AND empresa='001'));

						END IF;
						--20150216.1534 FIN
						
					ELSE

					SET ISOLATION TO DIRTY READ ;
					SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
					INTO cIdReferencia1
					FROM bdisac:"informix".sac_param
					WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = cIdConvenio
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '1';

					SET ISOLATION TO DIRTY READ ;
					SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
					INTO cIdReferencia2
					FROM bdisac:"informix".sac_param
					WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = cIdConvenio
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '2';

					IF cIdConvenio = '01001' THEN

						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = cTransCargoCoppel  THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = cTransEfecCoppel  THEN monto_tot END AS totEfectivo
											FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = cTransCargoCoppel THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = cTransEfecCoppel  THEN monto_tot END AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc WHERE   folio_suc = cFolioSuc ));

					ELIF cIdConvenio = '02001' THEN
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = cTransCargoTelmex  THEN monto_tot END AS monto_totCargo,
												   CASE WHEN transacc = cTransEfecTelmex  THEN monto_tot END AS totEfectivo
											FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = cTransCargoTelmex  THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = cTransEfecTelmex  THEN monto_tot END AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc WHERE  folio_suc = cFolioSuc ));

						ELIF cIdConvenio = '06001' THEN
							SET ISOLATION TO DIRTY READ ;
							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
							INTO mCargoCuenta, mCargoEfectivo
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc = cTransCargoSky  THEN monto_tot END AS monto_totCargo,
													   CASE WHEN transacc = cTransEfecSky  THEN monto_tot END AS totEfectivo
												FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'
												UNION ALL
												SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = cTransCargoSky  THEN monto_tot END AS monto_totCargo,
													CASE WHEN transacc = cTransEfecSky  THEN monto_tot END AS totEfectivo
												FROM bdisac:"informix".sac_movhissuc WHERE  folio_suc = cFolioSuc ));
					ELIF cIdConvenio = '07001' THEN
-- MODIFICACION
						 LET cReferencia1='********'||SUBSTRING (cReferencia1 FROM 9 FOR 4);

						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_CargoEnvioOrden), 0) + NVL(SUM(monto_CargoEnvioComision), 0) + NVL(SUM(monto_CargoEnvioIVA), 0) AS totCargo,
								NVL(SUM(monto_EfecEnvioOrden), 0) + NVL(SUM(monto_EfecEnvioComision), 0) + NVL(SUM(monto_EfecEnvioIVA), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(ctransCargoEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioOrden,
												CASE WHEN transacc = CAST(ctransCargoEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioComision,
												CASE WHEN transacc = CAST(ctransCargoEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioIVA,
												CASE WHEN transacc = CAST(ctransEfecEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioOrden,
												CASE WHEN transacc = CAST(ctransEfecEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioComision,
												CASE WHEN transacc = CAST(ctransEfecEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioIVA
											FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = CAST(ctransCargoEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioOrden,
												CASE WHEN transacc = CAST(ctransCargoEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioComision,
												CASE WHEN transacc = CAST(ctransCargoEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioIVA,
												CASE WHEN transacc = CAST(ctransEfecEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioOrden,
												CASE WHEN transacc = CAST(ctransEfecEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioComision,
												CASE WHEN transacc = CAST(ctransEfecEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioIVA
											FROM bdisac:"informix".sac_movhissuc WHERE folio_suc = cFolioSuc));


					ELIF cIdConvenio = '07002' THEN
						LET mCargoCuenta = 0;
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM TABLE(MULTISET(SELECT monto_tot AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE transacc = ctransEfecPagoOrden
											AND folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} monto_tot AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc
											WHERE transacc = ctransEfecPagoOrden
											AND folio_suc = cFolioSuc));

					ELIF cIdConvenio = '07003' THEN
						LET mCargoCuenta = 0;
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM TABLE(MULTISET(SELECT monto_tot AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE transacc = ctransEfecCancelacionOrden
											AND folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} monto_tot AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc
											WHERE transacc = ctransEfecCancelacionOrden
											AND folio_suc = cFolioSuc));

						END IF;
					END IF;

					LET siCiclo = siCiclo + 1;

		-- PAGINACION
					IF siCiclo <= siRegistros THEN
						CONTINUE FOREACH;
					END IF;
--HOMOLOGACION GDF					
					RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, TRIM(cIdReferencia1), TRIM(cIdReferencia2), mCargoCuenta + mCargoCuentaCred, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo
					WITH RESUME;
				END FOREACH;
			ELSE
				RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, TRIM(cIdReferencia1), TRIM(cIdReferencia2), mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo;
			END IF;
		ELSE

			IF iRegistrosHoy > 0 THEN
				SET ISOLATION TO DIRTY READ ;

				FOREACH

					SELECT  b.folio_suc, f.numcategoria||f.numconvenio AS numconvenio, f.nomconvenio, b.referencia1,
						b.referencia2, b.forma_pago, e.nombre, f.trans_cen_cargo_cliente, f.trans_cen_efectivo_cliente, f.proceso_automatico,
						f.nombre_referencia1, f.nombre_referencia2
					INTO cFolioSuc, cIdConvenio, cNomconvenio,cReferencia1, cReferencia2, cFormaPago, cRegion, cTransCargo, cTransEfec,
						siProcesoAutomatico, cIdReferencia1, cIdReferencia2
					FROM bdisac:"informix".sac_movimientos b, bdinteg:"informix".si_sucursales c, bdinteg:"informix".si_plazas d, bdinteg:"informix".si_regional e, bdisac:"informix".sac_convenios f
					WHERE b.id_sucursal = cSucursal
					AND b.numcategoria = f.numcategoria
					AND b.numconvenio = f.numconvenio
					AND b.status_cancelado <> 'S'
					AND c.sucursal = b.id_sucursal
					AND d.plaza = c.plaza
					AND e.regional = d.regional
					ORDER BY folio_suc
					IF siProcesoAutomatico = 1 THEN

						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = cTransCargo  THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = cTransEfec  THEN monto_tot END AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = cTransCargo  THEN monto_tot END AS monto_totCargo,
													CASE WHEN transacc = cTransEfec  THEN monto_tot END AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc
											WHERE  folio_suc = cFolioSuc));
						 --20130109.1030 inicio
						 IF	cIdConvenio = '08001' THEN
						 
							SELECT NVL(TRIM(valor),'')
							INTO cTranCredPGDF 
							FROM bdisac:"informix".sac_param 
							WHERE cod_param = '87033';
							
							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
							INTO mCargoCuentaCred
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredPGDF  
												THEN monto END AS monto_totCargo
												FROM bdicred:"informix".sd_movdia
												WHERE folio_suc = cFolioSuc AND empresa='001'));
				
						END IF;
					 --20130109.1030 fin
					 
						--HOMOLOGACION CLUB DE PROTECCION					 
						--20140902.1315 inicio
						IF	cIdConvenio = '01002' THEN

							SELECT NVL(TRIM(valor),'')
							INTO cTranCredPCP 
							FROM bdisac:"informix".sac_param 
							WHERE cod_param = 80;

							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
							INTO mCargoCuentaCred
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredPCP  
												THEN monto END AS monto_totCargo
												FROM bdicred:"informix".sd_movdia
												WHERE folio_suc = cFolioSuc AND empresa='001'));

						END IF;
						--20140902.1315 fin
					 
					 	--HOMOLOGACION TAE
						--20150120.1510 inicio
						IF	cIdConvenio = '03001' THEN

							SELECT NVL(TRIM(valor),'')
							INTO cTranCredPTAE 
							FROM bdisac:"informix".sac_param 
							WHERE cod_param = 22;

							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
							INTO mCargoCuentaCred
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredPTAE  
												THEN monto END AS monto_totCargo
												FROM bdicred:"informix".sd_movdia
												WHERE folio_suc = cFolioSuc AND empresa='001'));

						END IF;
						--20150120.1510 FIN
						
						
						--HOMOLOGACION EDOMEX
						--20150216.1537 inicio
						IF	cIdConvenio = '08002' THEN

							SELECT NVL(TRIM(valor),'')
							INTO cTranCredEDOMEX
							FROM bdisac:"informix".sac_param 
							WHERE cod_param = 23;

							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
							INTO mCargoCuentaCred
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredEDOMEX  
												THEN monto END AS monto_totCargo
												FROM bdicred:"informix".sd_movdia
												WHERE folio_suc = cFolioSuc AND empresa='001'));

						END IF;
						--20150216.1537 FIN
						
					ELSE

					SET ISOLATION TO DIRTY READ ;
					SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
					INTO cIdReferencia1
					FROM bdisac:"informix".sac_param
					WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = cIdConvenio
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '1';

					SET ISOLATION TO DIRTY READ ;
					SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
					INTO cIdReferencia2
					FROM bdisac:"informix".sac_param
					WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = cIdConvenio
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '2';

					IF cIdConvenio = '01001' THEN

						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(cTransCargoCoppel AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = CAST(cTransEfecCoppel AS CHAR(4)) THEN monto_tot END AS totEfectivo
											FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'));

					ELIF cIdConvenio = '02001' THEN
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(cTransCargoTelmex AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = CAST(cTransEfecTelmex AS CHAR(4)) THEN monto_tot END AS totEfectivo
												FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'));
					ELIF cIdConvenio = '06001' THEN
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(cTransCargoSky AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
													CASE WHEN transacc = CAST(cTransEfecSky AS CHAR(4)) THEN monto_tot END AS totEfectivo
												FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'));

					ELIF cIdConvenio = '07001' THEN
-- MODIFICACION
						LET cReferencia1='********'||SUBSTRING (cReferencia1 FROM 9 FOR 4);
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_CargoEnvioOrden), 0) + NVL(SUM(monto_CargoEnvioComision), 0) + NVL(SUM(monto_CargoEnvioIVA), 0) AS totCargo,
								NVL(SUM(monto_EfecEnvioOrden), 0) + NVL(SUM(monto_EfecEnvioComision), 0) + NVL(SUM(monto_EfecEnvioIVA), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(ctransCargoEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioOrden,
												CASE WHEN transacc = CAST(ctransCargoEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioComision,
												CASE WHEN transacc = CAST(ctransCargoEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioIVA,
												CASE WHEN transacc = CAST(ctransEfecEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioOrden,
												CASE WHEN transacc = CAST(ctransEfecEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioComision,
												CASE WHEN transacc = CAST(ctransEfecEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioIVA
											FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'));

					ELIF cIdConvenio = '07002' THEN
						LET mCargoCuenta = 0;
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM TABLE(MULTISET(SELECT monto_tot AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE transacc = ctransEfecPagoOrden
											AND folio_suc = cFolioSuc AND empresa='001'));

					ELIF cIdConvenio = '07003' THEN
						LET mCargoCuenta = 0;
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM TABLE(MULTISET(SELECT monto_tot AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE transacc = ctransEfecCancelacionOrden
											AND folio_suc = cFolioSuc AND empresa='001'));
						END IF;
					END IF;

					LET siCiclo = siCiclo + 1;

					-- PAGINACION
					IF siCiclo <= siRegistros THEN
						CONTINUE FOREACH;
					END IF;

					RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, TRIM(cIdReferencia1), TRIM(cIdReferencia2), mCargoCuenta + mCargoCuentaCred, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo
					WITH RESUME;
				END FOREACH;
			ELSE
				RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, TRIM(cIdReferencia1), TRIM(cIdReferencia2), mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo;
			END IF;
		END IF;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener la conciliacion por convenio y sucursales en un rango de fechas especIFicas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080906',
'BD    : bdisac',
'FECHA ULTIMA MODIFICACION: 20090123',
'AUTOR ULTIMA MODIFICACION: Jose Angel Lopez Adams',
'FECHA ULTIMA MODIFICACION: 15 Octubre 2009',
'FECHA ULTIMA MODIFICACION: 20091016',
'MODIFICACION: Se agregó en las consultas (Querys) un UNION ALL para que tambien se consulten las tablas de historial',
'              asi como tambien el manejo de la fecha de sucursal.',
'AUTOR ULTIMA MODIFICACION: Héctor Manuel Bojórquez Ruelas',
'MODIFICACION: Se modifica para agregar directivas Dirty read en las consultas',
'              asi como tambien el manejo de la fecha de sucursal.',
'AUTOR ULTIMA MODIFICACION: Héctor Manuel Bojórquez Ruelas',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Se agregan validaciones para que contemple los movimientos para ordenes de pago',
'VERSION DE CAMBIO: 20100420.1700',
'MODIFICA : Dulce Ramirez',
'DESCRIPCION: Se agregan validaciones para que contemple los movimientos para pagos de servicios sky',
'VERSION DE CAMBIO: 20100521.1618',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Junto con la integracion de Pagos MVS se integra la modificacion para los convenios en proceso automatico para su funcionamiento dinamico',
'VERSION DE CAMBIO: 20100923.1843',
'                                    ',
'MODIFICA : Martín Eduardo Miranda',
'DESCRIPCION: Se agrega nuevo retorno "cIdConvenio" para ordenar el reporte diario de Servicios por sucursal',
'VERSION DE CAMBIO: 20120830.1629',

'MODIFICA : Martha Aguirre',
'DESCRIPCION: Se agrega búsqueda de monto para el movimiento de cargo en cuenta de crédito para el cIdConvenio 8001',
'             "Pago de Servicios del Gobierno del Distrito Federal"',
'VERSION DE CAMBIO: 20130109.1030',
'',
'DESCRIPCION: Se modifica Procemiento Almacenado para agregarle nueva variable en la cual se almacena el importe de Cargo a Cuenta de',
'             las Transacciones de Crédito',
'MODIFICO: Martha Aguirre',
'FECHA: 12 de Marzo del 2013',
'Folio:1570',
'Autor:95142134 Mario Gallardo',
'Fecha:24/01/2014',
'Modificación: Se modifica referencia1 y referencia2 a 40 carcateres.',
'Sustento: RQI 62 064-Reingeniería_PagoServicios -  (Pagina 2 a 36)',
'Solicita: Jaime Gonzalez',
'BD: bdisac',
'MODIFICA : Rigoberto Gonzalez Llanes',
'DESCRIPCION: Se agrega búsqueda de monto para el movimiento de cargo en cuenta de crédito para el cIdConvenio 01002',
'             Pago de Servicios club de proteccion coppel',
'VERSION DE CAMBIO: 20140902.1315',
'MODIFICA : Jesus Isaias Bueno',
'DESCRIPCION: Se agrega búsqueda de monto para el movimiento de cargo en cuenta de crédito para el cIdConvenio 03001',
'             Pago de tiempo aire',
'VERSION DE CAMBIO: 20151002.0915',
'MODIFICA : Jesus Isaias Bueno',
'DESCRIPCION: Se agrega búsqueda de monto para el movimiento de cargo en cuenta de crédito para el cIdConvenio 08002',
'             Pago EDOMEX',
'VERSION DE CAMBIO: 20151602.1540';

CREATE PROCEDURE "informix".sp_sacreportemensualtae(pConvenio CHAR(5), pPeriodo CHAR(6))
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

-- SET DEBUG FILE TO  '/home/sysifx/JesusBueno/sp_sacreportemensualtae.out';
-- TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualtae");
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
'AUTOR : JesÃºs Isaias Bueno',
'DESCRIPCIÃN: Obtiene la informacion para la generacion del reporte mensual de pago de Tiempo Aire',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 22 Enero 2015',
'VERSIÃN: 20150122.1740',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesemanaltae(pConvenio CHAR (5),pConsecutivo INTEGER)
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
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanaltae");
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
'AUTOR : JesÃºs Isaias Bueno',
'DESCRIPCIÃN: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos TAE',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 22 Enero 2015',
'VERSIÃN: 20150122.1746',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_tramacomunicacionemex
(
	pNumCategoria   CHAR (2),
	pNumConvenio    CHAR (3),
	pFolioSucursal	CHAR (16),
	pRef1			CHAR (40),
	pId_Sucursal	CHAR (4),
	pFecha_Pago		DATE
)
RETURNING CHAR (5) AS cCodRet, CHAR (269) AS cTrama;

--Declaracion de variables
		DEFINE cCodRet 		    CHAR(6);
        DEFINE cDescription     CHAR(40);
		DEFINE cTrans_Interact  CHAR(5);
		DEFINE cTrans_Servicio  CHAR(5);
		DEFINE cClave_Medio	    CHAR(2);
		DEFINE cClave_Centro    CHAR(2);
		DEFINE cSucursal	    CHAR(30);
		DEFINE cCuenta_Deposito CHAR(20);
		DEFINE cForma_pago	    CHAR(2);
		DEFINE cRefer1		    CHAR(27);
		DEFINE cImporte		    CHAR(16);
		DEFINE cFecha_Pago	    CHAR(10);
		DEFINE cFecha_Aplica    CHAR(10);
		DEFINE cAutoriza	    CHAR(60); --folio_Suc from sac_movimientos
		DEFINE cPlazo		    CHAR(2);  --valor from sac_param
		DEFINE cTrama			CHAR(269);
		DEFINE iSqlErr			INTEGER;
		DEFINE cTran_suc		CHAR (4);
		DEFINE cTran_cent		CHAR(4);
		DEFINE cUser			CHAR(8);
		DEFINE iValida			INTEGER;

		LET cCodRet 			= '00000'; --Codigo 00000 = OK; 00001 = No hubo datos; 00002 = Cualquier otro error
        LET cDescription        = '';
        LET cTrans_Interact		= '';
        LET cTrans_Servicio		= '';
        LET cClave_Medio		= '';      --Identificacion del medio de pago. Siempre serÃ¡ parametrizado 2 para ventanilla, 1 en Linea.
        LET cClave_Centro		= '';    --Identificacion del centro de pago. Siempre serÃ¡ 36, el cliente definia para BanCoppel.
        LET cSucursal			= '';
        LET cCuenta_Deposito  	= '';
        LET cForma_pago			= '';
        LET cRefer1				= '';
        LET cImporte			= '';
        LET cFecha_Pago			= '';
        LET cFecha_Aplica		= '';
        LET cAutoriza			= '';     --Folio_Suc
        LET cPlazo				= '';
		LET cTrama				= '';
		LET cTran_suc			='';
		LET cTran_cent			='';
		LET cUser				='';
		Let iValida				= 0;
		LET iSqlErr				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTrama;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/sp_tramacomunicacionemex.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		IF NVL (pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL (pFolioSucursal, '') = ''
		   OR NVL (pRef1, '') = '' OR NVL (pId_Sucursal, '') = '' OR NVL (pFecha_Pago, '') = ''  THEN
			 LET cCodRet = '00002';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodRet, NVL(cTrama, '');
		END IF;

		--Obtenemos los campos requeridos  de bdisac: sac_intrfz_serv
		SELECT trans_interact, trans_servicio
		INTO   cTrans_Interact, cTrans_Servicio
		FROM    bdisac: "informix".sac_intrfz_serv
		WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			END IF;


		--FORMA DE PAGO: EFECTIVO (1 = '04')
		--FORMA DE PAGO: CARGO CUENTA (2 = '08')
		--FORMA DE PAGO: CARGO TARJETA DE CREDITO (5 = '02')
		--FORMA NO ENCONTRADA (NINGUNA DE LAS ANTERIORES = default: '-1')
		SELECT DECODE (forma_pago, '1', '04', '2', '08', '5', '02', '-1')
		INTO cForma_pago --Para decidir que forma de pago enviar en base a validacion con sac_movimientos.forma_pago
		FROM  bdisac: "informix".sac_movimientos
		WHERE id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND numcategoria = pNumCategoria
			   AND numconvenio = pNumConvenio AND referencia1 = pRef1 AND fecha_pago=pFecha_Pago; --Activa idxsac_mov114 (Indice)

			--cForma_pago = '-1' es una forma de pago no vÃ?Â¡lida, no encontrada.
			IF DBINFO("sqlca.sqlerrd2") = 0 OR cForma_pago = '-1' THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			END IF;

		IF cForma_pago = '04' THEN
			SELECT  trans_cen_efectivo_cliente INTO  cTran_cent FROM bdisac: "informix".sac_convenios WHERE numcategoria=pNumCategoria and numconvenio=pNumConvenio;
		ELSE
			IF cForma_pago = '08' THEN
				SELECT  trans_cen_cargo_cliente INTO  cTran_cent FROM bdisac: "informix".sac_convenios WHERE numcategoria=pNumCategoria and numconvenio=pNumConvenio;
			ELSE
				IF cForma_pago = '02' THEN
					SELECT valor INTO  cTran_cent FROM bdisac: "informix".sac_param where cod_param = 25;
				ELSE
					LET cTran_cent = ' ';
				END IF;
			END IF;
		END IF;
		SELECT fn_instr(valor, pId_Sucursal) INTO iValida FROM  bdisac: "informix".sac_param where cod_param = '28';

			IF iValida > 0 THEN
				SELECT valor INTO cClave_Medio FROM bdisac: "informix".sac_param where cod_param = '27';
			ELSE
				SELECT valor INTO cClave_Medio FROM bdisac: "informix".sac_param where cod_param = '26';
			END IF;

		SELECT valor INTO cClave_Centro FROM  bdisac: "informix".sac_param where cod_param = '29';

		--Replace quita los '.' y ',' del importe_pago. To_Char convierte la fecha al estÃ?Â¡ndar solicitado por el cliente. 1468-EdoMex.
		SELECT id_sucursal, referencia1,
			   RPAD (REPLACE(REPLACE(REPLACE (importe_pago, '.', ''), ',', ''), '$', ''), 16, ' '),
			   TO_CHAR(fecha_pago, "%d%m%Y"), RPAD(folio_suc, 88, ' ')
		INTO   cSucursal, cRefer1, cImporte, cFecha_Pago, cAutoriza --cAutoriza = (folio_suc)
		FROM    bdisac: "informix".sac_movimientos
		WHERE  id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND numcategoria = pNumCategoria
			   AND numconvenio = pNumConvenio AND referencia1 = pRef1 AND fecha_pago=pFecha_Pago;
		--WHERE  id_sucursal = pId_Sucursal AND numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND referencia1 = pRef1;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			ELSE
				LET cFecha_Aplica =  cFecha_Pago; --fecha_pago se aplica a cFecha_Pago y a cFecha_Aplica.
			END IF;

		-- El cÃ³digo comentado en las dos secciones de continuaciÃ³n son parte importante a futuro ya que se definirÃ¡ el plazo parametrizado lo cual no ha sido definido hasta el momento
		/*SELECT valor
		INTO   cPlazo
		FROM   sac_param
		WHERE  cod_param = '01'; --Inicialmente '00' hasta que el cliente responda que valor fijo va en cod_param.
		*/
		LET cPlazo = '00';

		/*IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
		END IF;	*/

	/*	SELECT cuenta
		INTO cCuenta_Deposito
		FROM bdisac: "informix".sac_edomex_cuentas
		WHERE SUBSTRING(prefijo FROM 1 FOR 6) LIKE SUBSTRING(pRef1 FROM 1 FOR 6);
		--LOS PRIMEROS 6 CARACTERES DE LA REFERENCIA 1, SON EL PREFIJO A BUSCAR.*/

        EXECUTE PROCEDURE "informix".sp_asignacuenta_edomex(SUBSTRING(pRef1 FROM 1 FOR 6))
		INTO cCodRet,cDescription,cCuenta_Deposito;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00002';
					RETURN cCodRet, NVL(cCuenta_Deposito, '');
		ELSE
			LET cTrama = cTrans_Servicio||cClave_Medio||cClave_Centro||TRIM(cSucursal)||TRIM(cCuenta_Deposito)||cForma_pago||cRefer1||cImporte||TRIM(cFecha_Pago)||TRIM(cFecha_Aplica)||cAutoriza||cPlazo;


			-- Solicita y guarda el valor de trans_suc_efectivo de bdisac: sac_convenios
			SELECT trans_suc_efectivo INTO cTran_suc FROM bdisac: "informix".sac_convenios WHERE numcategoria=pNumCategoria and numconvenio=pNumConvenio;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
					RETURN cCodRet, NVL(cCuenta_Deposito, '');
			END IF;
			--Solicita y guarda el valor de usuario de bdisac: sac_movimientos
			SELECT usuario INTO cUser FROM bdisac: "informix".sac_movimientos where id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND referencia1 = pRef1 AND fecha_pago=pFecha_Pago;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
					RETURN cCodRet, NVL(cCuenta_Deposito, '');
			END IF;

			--Almacenar datos en bdisac: sac_msw_solicitud
			INSERT INTO bdisac: "informix".sac_msw_solicitud(numcategoria, numconvenio, id_sucursal, trans_suc, trans_central, trans_interact, folio_suc, fecha_pago, campo1, campo2, campo3, campo4, campo5, campo6 , campo7, campo8, campo9, campo10, campo11, campo12, campo13, campo14, campo15, campo16, campo17, campo18, campo19, campo20, campo21, campo22, campo23, campo24, campo25, campo26, campo27, campo28, campo29, campo30, campo31, campo32, campo33, campo34, campo35, campo36, campo37, campo38, campo39, campo40, user_insert, fecha_insert) VALUES (pNumCategoria, pNumConvenio, pId_Sucursal, cTran_suc, cTran_cent, cTrans_Interact, pFolioSucursal, pFecha_Pago,  cTrans_Servicio, cClave_Medio, cClave_Centro, cSucursal, cCuenta_Deposito, cForma_pago, cRefer1 , cImporte, cFecha_Pago, cFecha_Aplica, cAutoriza, cPlazo, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',  cUser, current );

		RETURN cCodRet, NVL(cTrama, '');
		END IF;


END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: SPL que recupera datos (EdoMex) para generar la trama a enviar a Interact.',
'FOLIO: 1468-PagosRef_PagoImpEdoMex',
'FECHA : 10 de Febrero de 2015',
'VERSION: 20150202.1000',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consultaconceptogdf(pClave CHAR(2))

--DATOS A REGRESAR---
RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(20)  AS Leyenda;

--DECLARACION DE VARIABLES			
DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cLeyenda     CHAR(20);

--ASIGNACION DE VALORES
LET iSqlerr = 0;
LET cCodRet = '00000';
LET cLeyenda = '';
 
   --SET DEBUG FILE TO "/respaldosbd/Martha/sp_consultaconceptogdf.out";
   --TRACE ON;   
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	IF NVL(pClave,'') = '' THEN		
		LET cCodRet = '00001';
	END IF;
	
	SELECT leyenda 
	INTO cLeyenda
	FROM bdisac:"informix".sac_catconceptosgdf
	WHERE clave = pClave;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
		LET cCodRet = '00002';
	END IF;  

	RETURN cCodRet, cLeyenda;
	
END
END PROCEDURE

DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 08/01/2013",
"Descripcion: Valida si la clave recibida es vÃ¡lida",
"	          consultando en el catalago de conceptos",
"             de pagos del gobierno del distrito federal",
"Ver.  : 1.0",
"BD    : bdisac",
'MODIFICACION : 11/02/2013',
'MODIFICO :Felipe Urias  ',
'DESCRIPCION: se agrega como retorno la leyenda de conceptos de sac_catconceptosgdf';

CREATE PROCEDURE "informix".sp_consultaempleadowu
(
	pSucursal CHAR(4), 	pEmpleado CHAR(8), pCategoria CHAR(2), 	pConvenio CHAR(3), pModo SMALLINT
)
--		pSucursal		CHAR(4);   Parámetro obligatorio.
--		pEmpleado		CHAR(8);   Parámetro obligatorio.
--		pCategoria		CHAR(2);   Parámetro Obligatorio para modalidad 2.
--		pConvenio 		CHAR(3);   Parámetro obligatorio para modalidad 2.
--		pModo			SMALLINT;  Parámetro obligatorio.
		
RETURNING
	CHAR(5)  AS cCodRet,	    	
	SMALLINT AS sValor,	
	CHAR(30) AS cDescripcion,
	CHAR(1)  AS cMsg;

DEFINE cCodRet		  CHAR(5);
DEFINE iSqlErr  	  INTEGER;
DEFINE sValor		  SMALLINT;
DEFINE cDescripcion   CHAR(30);
DEFINE cMsg			  CHAR(1);
DEFINE cEdoFronterizo CHAR(2); --Estado fronterizo.
DEFINE dFecha_hoy	  DATETIME YEAR TO FRACTION;

LET cCodRet		   = '00002'; --Inicializado como código de error en caso de no entrar al cuerpo del sp.
LET iSqlErr  	   = 0;
LET sValor		   = 0;
LET cDescripcion   = '';
LET cMsg		   = '';	
LET cEdoFronterizo = '';
LET dFecha_hoy	   = CURRENT;

	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sValor, cDescripcion, cMsg;	
		END IF;
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1508/sp_consultaempleadowu.out';
		--TRACE ON;
			 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;  

		--Validamos parámetros obligatorios
		IF NVL(pSucursal, '') = '' OR NVL(pEmpleado, '') = '' OR NVL(pModo, '') = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet, sValor, cDescripcion, cMsg;			
		ELSE
			--Obtenemos la fecha de bdinteg:"informix".si_fechas (campo fecha_hoy) y la guardamos en la variable dFecha_hoy para uso posterior.
			SELECT fecha_hoy
			INTO dFecha_hoy
			FROM bdinteg:"informix".si_fechas;
			
			IF pModo = '1' THEN				
				--Validamos que la sucursal recibida como parámetro exista en bdinteg:"informix".si_sucursales.
				IF NOT EXISTS(SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal) THEN
					LET cCodRet = '00002';
					RETURN cCodRet, sValor, cDescripcion, cMsg;
				ELSE
					SELECT estado 
					INTO cEdoFronterizo
					FROM bdinteg:"informix".si_sucursales 
					WHERE sucursal = pSucursal;
								
					--Validamos si la sucursal está o no en un estado fronterizo
					------------------------------------------------------------------------------------------------------------------
					IF EXISTS 
					(SELECT descripcion FROM "informix".sac_param WHERE  TRIM(valor) LIKE '%' || TRIM(cEdoFronterizo) || '%' AND cod_param = '87084' ) THEN
						--Sí es estado fronterizo
						--Validamos si el empleado ha aceptado los términos de WU (Western Union) antes de la transacción actual.
						IF EXISTS( SELECT usuario FROM "informix".sac_registraempleadowu WHERE usuario = pEmpleado AND sucursal = pSucursal 
								   AND fecha = dFecha_hoy
								 ) THEN
							--Si ha aceptado los términos.
							LET cCodRet		 = '00000';
							LET sValor 		 = 1;
							LET cDescripcion = 'Sucursal fronteriza';
							LET cMsg 		 = 1;				
							RETURN cCodRet, sValor, cDescripcion, cMsg;					
						ELSE
							--No ha aceptado los términos (primer pago de remesa extranjera del empleado actual)
							LET cCodRet		 = '00000';
							LET sValor 		 = 1;
							LET cDescripcion = 'Sucursal fronteriza';
							LET cMsg 		 = 0;				
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						END IF;						
					ELSE
						--No es estado fronterizo
						LET cCodRet = '00000';
						LET sValor = 0;
						LET cDescripcion = 'Sucursal no fronteriza';
						LET cMsg = 0;				
						RETURN cCodRet, sValor, cDescripcion, cMsg;	
					END IF;
				END IF;
					------------------------------------------------------------------------------------------------------------------
			ELIF pModo = '2' THEN
				--En esta modalidad se registrará al empleado en la nueva tabla bdisac:"informix".sac_registraempleadowu.
				IF NVL(pCategoria,'') = '' OR NVL(pConvenio,'') = '' THEN
					LET cCodRet = '00001';
					RETURN cCodRet, sValor, cDescripcion, cMsg;
				ELSE					
					INSERT INTO "informix".sac_registraempleadowu (numcategoria, numconvenio, usuario, sucursal, fecha, fecha_hora, status)
					VALUES (pCategoria, pConvenio, pEmpleado, pSucursal, dFecha_hoy, CURRENT, 0);
						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
							LET cCodret = '00003'; --NO INSERTÓ EL REGISTRO.
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						ELSE
							LET cCodRet = '00000';
							LET sValor = 0;
							LET cDescripcion = 'Empleado Registrado correctamente.';
							LET cMsg = 0;
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						END IF;					
				END IF;
			ELSE
				LET cCodRet = '00001';
				RETURN cCodRet, sValor, cDescripcion, cMsg;
			END IF;
		END IF;		
	END
END PROCEDURE
DOCUMENT
'AUTOR: 96273763, Antonio Cebreros Perez',
'FOLIO: 230202 - 1508 - MttoRemWUyOVoVFrontNte',
'DESCRIPCION: Verifica si el estado es fronterizo, de ser así verificará si el empleado ya ha aceptado los términos impuestos por WU, en caso de no haber aceptado aún, registrará al empleado en la nueva tabla bdisac:sac_registraempleadowu.',
'FECHA: 31/10/2015',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_pay 
(
	pEmpresa			CHAR(3), 
	pMarca              CHAR(2),
	pUsuario			CHAR(8),  
	pBenefNameType 		CHAR(1), 
	pBenefNombreUno		CHAR(40), 
	pBenefNombreDos		CHAR(40), 
	pBenefApaterno		CHAR(40), 
	pBenefAmaterno		CHAR(40), 
	pBenefCiudad 		CHAR(24),-- se adapta a la longitud del campo benef_ciudad  
	pBenefEdo  			CHAR(40), 
	pBeneCP				CHAR(9),-- se adapta a la longitud del campo benef_cp
	pBenefIdType  		CHAR(1), 
	pBenefIdPaisExpedi	CHAR(45), 
	pBenefIdNumber  	CHAR(20), 
	pBenefTieneFechVenc	CHAR(1), 
	pBenefFechaVenc  	CHAR(8),
	pBenefFechNac  		CHAR(8), 
	pBenefOcupacion  	CHAR(30), 
	pBenefCalleNum  	CHAR(40), 
	pBenefColDelMun  	CHAR(40), 
	pBenefPais  		CHAR(45), 
	pBenefTelPart 		CHAR(20), -- se adapta a la longitud del campo benef_tel_particular 
	pBenefTelCel  		CHAR(20), -- se adapta a la longitud del campo benef_tel_celular 
	pBenefEmail  		CHAR(40), 
	pBenefPaisNac  		CHAR(2), 
	pBenefNacionalidad 	CHAR(15), 
	pBenefSexo  		CHAR(1), 
	pBenefCiudadNac		CHAR(20), 
	pBenefEdoNac		CHAR(20), 
	pBenefCodPais		CHAR(3), 
	pBenefCodMoneda		CHAR(3), 
	pMontoOrigen		CHAR(10), 
	pMontoDestino		CHAR(10), 
	pMoneyTransferKey	CHAR(10), 
	pNewMtcn			CHAR(16), 
	pMtcn				CHAR(10), 
	pConfPago			CHAR(1), 
	pForeignRefNumRq	CHAR(16), 
	pFechaHrRq			DATETIME YEAR TO SECOND, 
	pRetCode			CHAR(5), 
	pDatosBufer			CHAR(500), 
	pMtcnRp				CHAR(10), 
	pPuntosGanados		CHAR(4), 
	pWuFechaPago		CHAR(16), 
	pForeignSystemIdRp	CHAR(11), 
	pForeingRefNumRp	CHAR(16), 
	pForeignRsCantIdRp	CHAR(11), 
	pDesError			CHAR(250), 
	pPartnerIdErr		CHAR(10), 
	pFechaHoraRp		DATETIME YEAR TO SECOND, 
	pUserInsert			CHAR(8), 
	pFechaInsert		DATETIME YEAR TO SECOND,
	pSecondIdType		CHAR(1),  --DSB: 03/11/2015 (1508) Antonio Cebreros Pérez.
	pSecondPaisExp		CHAR(44), --DSB: 03/11/2015 (1508) Antonio Cebreros Pérez.
	pSecondIDNumber   	CHAR(30)  --DSB: 03/11/2015 (1508) Antonio Cebreros Pérez.
)

RETURNING  CHAR(5) AS cod_err, CHAR(30) AS error_desc;

	--DEFINICION DE VARIABLES--
    DEFINE	iSqlErr				INTEGER;
	DEFINE 	iIsamErr			INTEGER;
    DEFINE	cCodRet				CHAR(5);
	DEFINE  cRetCode			CHAR(5);
	DEFINE  cDesc_Error         CHAR(250);
	DEFINE	cCodRetAux			CHAR(5);
	DEFINE	cTxnStatus			CHAR(1);
	DEFINE	cNombreSP			CHAR(45);
	DEFINE 	cCadena_ent			CHAR(100);
	DEFINE cError_Desc  		CHAR(30);
	DEFINE dFechaProceso    	DATETIME YEAR TO SECOND;
	DEFINE cChannelType 		CHAR(3);
    DEFINE cChannelName 		CHAR(3); 
    DEFINE cChannelVersion		CHAR(4);
	DEFINE cForeignSystemId		CHAR(11); 
	DEFINE cForeignRsCntRq  	CHAR(11);
	DEFINE cTemplateId          CHAR(10);
	DEFINE cSucursal		CHAR(4);
	
	--INICIALIZACION DE VARIABLES--
    LET	iSqlErr				= 0;
	LET	iIsamErr 			= 0;
    LET cCodRet				= '00000';
	LET cRetCode			= '00000';
	LET cDesc_Error			= "";
	LET cCodRetAux			= '00000';
	LET cTxnStatus			= 'C';
	LET	cNombreSP			= 'sp_sac_wu_guardarespuesta_pay';
	LET cCadena_ent			= TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pMoneyTransferKey,'NULL'))||'|'||TRIM(NVL(pNewMtcn,'NULL'));
    LET cError_Desc 		= "Error en el proceso";
	LET dFechaProceso		=  CURRENT::DATETIME YEAR TO SECOND;
	LET cChannelType 	 	= "";	
    LET cChannelName 	 	= "";	 
    LET cChannelVersion	 	= "";
	LET cForeignSystemId 	= ""; 
	LET cForeignRsCntRq  	= "" ;
	LET cTemplateId			= "";
	LET cSucursal 			= "";

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;

			EXECUTE PROCEDURE "informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSqlErr,iIsamErr,cCadena_ent,pUsuario,dFechaProceso) 
			INTO cCodRetAux;

			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
			--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
				LET cTxnStatus		 = 'C';
			--	2014.11.11 FRG-f

			INSERT INTO "informix".sac_wu_pay
					(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1,    benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type, benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago, foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp, puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert, benef_second_id_type, benef_second_pais_expedicion, benef_second_id_number)
			
			VALUES
					(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun, pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac,  pBenefNacionalidad, pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey, pNewMtcn, pMtcn, pConfPago, cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, pRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago,pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp, pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current, pSecondIdType, pSecondPaisExp, pSecondIDNumber);

			RETURN cCodRet, cError_Desc;
		END IF;

	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_pay.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF pRetCode = '504' THEN
	    LET cRetCode = '99999';
		LET pDesError = 'Aplicativo WU no activo, validar';
		
	END  IF;

	IF pRetCode <>  '504' AND pRetCode <> '00000' AND pRetCode <> '66666' THEN		
        IF pRetCode <> '20001' then
            LET cRetCode = '99998';
            LET pDesError = 'Sin respuesta del aplicativo, validar';
        ELIF pRetCode = '20001' then
            LET cRetCode = '20001';
            LET pDesError = 'Caracter invalido en la cadena';
        END IF;
	END IF;

	IF pRetCode = '66666' THEN
		LET cDesc_Error = pDesError;
		LET cRetCode = pRetCode;
	END IF
	
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
		IF (SELECT valor FROM "informix".sac_param WHERE cod_param ='87054') = pMarca
		OR (SELECT valor FROM "informix".sac_param WHERE cod_param ='87055') = pMarca
		OR (SELECT valor FROM "informix".sac_param WHERE cod_param ='87056') = pMarca THEN
			IF pUsuario = "sys_wu" THEN
				LET cSucursal = '9250';
			ELSE
				SELECT sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
			END IF;
			IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN
			
				SELECT fsid ,counter_id
				INTO cForeignSystemId ,cForeignRsCntRq
				FROM "informix".sac_wu_identificadores
				WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = cSucursal;

				IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
					LET cCodRet = '00027';
					LET cError_Desc	= 'Usuario no tiene Id. Asignado';
				END IF;
			ELSE
				LET	cCodRet = '00026'; --- Usuario no se encuentra
				LET cError_Desc	= 'NO EXISTE USUARIO';
		   END IF;
		ELSE
			LET	cCodRet = '00003'; --- Marca Inválida
			LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';
		END IF;
		
		SELECT valor
		INTO cChannelType
		FROM "informix".sac_param 
		WHERE cod_param = '87050';  
		 
		SELECT valor
		INTO cChannelName
		FROM "informix".sac_param 
		WHERE cod_param = '87051'; 
		 
		SELECT valor
		INTO cChannelVersion
		FROM "informix".sac_param 
		WHERE cod_param = '87052'; 
		
		SELECT valor
		INTO cTemplateId
		FROM "informix".sac_param 
		WHERE cod_param = '87063';

		--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
			LET	cTxnStatus	= 'A';
		--	2014.11.11 FRG-f
	
		INSERT INTO "informix".sac_wu_pay	
				(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1, benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type,benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago,foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp,puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err,fecha_hora_rp, user_insert, fecha_insert, benef_second_id_type, benef_second_pais_expedicion, benef_second_id_number)
						
		VALUES
				(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun,pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac, pBenefNacionalidad,pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey,pNewMtcn, pMtcn, pConfPago,cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, cRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago, pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp,pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current, pSecondIdType, pSecondPaisExp, pSecondIDNumber);
					   
		IF  cCodRet <> '00000' THEN
			
			IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
				RETURN cCodRet,cError_Desc;	
			END IF;
		  
            RETURN cCodRet,cError_Desc;		
	    ELSE	
			
			IF cCodRet = '00000' THEN
				LET cError_Desc = "Ejecucion SP exitosa";
			END IF;	
			
           RETURN cCodRet,cError_Desc;
	    END IF;	
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje  <receive-money-pay> (request-reply) en la tabla bdisac:sac_wu_pay',  
'AUTOR: Christian Echavarria',			
'FECHA: 17/Jul/2013',
'DESCRIPCION: Se modifica para que consulte los campos counter_id y  fsid de sac_wu_identificadores',  
'AUTOR: Mario Gallardo',			
'FECHA: 03/10/2013',
'DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
'AUTOR: FRG',
'FECHA: 30/Jul/2014',
'BD: bdisac',
'AUTOR: Mario Olivo',
'Empleado: 95358919',
'Folio: 1457',
'Centro: 230202',
'Descripcion: Se aumenta la longitud del parametro pBenefPais por que se aumento la longitud en la tabla sac_wu_pay para',
'			  guardar el nombre completo del pais.',
'Fecha:10/SEP/2014',
'Version: 20140910.1627',
'AUTOR: Pedro Jimenez',
'Empleado: 95689966',
'Folio: 1485',
'Centro: 230202',
'Descripcion: Se aumenta la longitud de los parametro pBenefCiudad,pBeneCP,pBenefTelPart,pBenefTelCel  por que se aumento la longitud en la tabla sac_wu_pay',
'Fecha:26/02/2015',
'Version: 20150226.1651',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------',
'AUTOR: Antonio Cebreros',
'Empleado: 96273763',
'Folio: 1508 - MttoRemWUyOVoVFrontNte',
'Centro: 230202',
'Descripcion: Se agregan 3 parámetros de entrada al sp debido a que tales parámetros representan 3 nuevas columnas para la tabla sac_wu_pay. En tal caso también se modificaron los insert del sp agregando las columnas correspondientes. Se cambia prefijo de variable productiva cFechaProceso por dFechaProceso.',
'Fecha:04/11/2015',
'Version: 20151104.1200';

CREATE PROCEDURE "informix".sac_bts_movspaso (vempresa char (3))

RETURNING CHAR (5), CHAR (100), CHAR (1), CHAR (1), CHAR (1), CHAR (1), CHAR (1), INTEGER, INTEGER, INTEGER;

--****************************************************************************************************
-- DESCRIPCION:  Proceso de movimientos histórico a tablas _paso para Conciliación Remesas BTS.
-- AUTOR : FRG
-- FECHA : 21/Ene/2014
-- BD: BDISAC
-- SISTEMA : BTS
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE ccodret 				CHAR (5);
DEFINE itot_movssac 		INTEGER;
DEFINE itot_movschqs 		INTEGER;
DEFINE itot_movsbts 		INTEGER;
DEFINE isqlerr      		INTEGER;
DEFINE iisamerr     		INTEGER;
DEFINE cinfoerr     		CHAR (100);
DEFINE cstatussac			CHAR (1);
DEFINE cstatmvhst			CHAR (1);
DEFINE ccuenta_bts			CHAR (20);
DEFINE ctrns_ctrl_efecte	CHAR (4);
DEFINE ctrns_ctrl_crgocte 	CHAR (4);
DEFINE imovsbts_payi		INTEGER;
DEFINE imovsbts_payc		INTEGER;
DEFINE cflg_sac				CHAR (1);
DEFINE cflg_chqs			CHAR (1);
DEFINE cflg_btscj			CHAR (1);
DEFINE cflg_btsab			CHAR (1);
DEFINE cflg_btsrev			CHAR (1);
DEFINE cproceso				CHAR (8);
DEFINE dfechamovs			DATE;
DEFINE iprocsac				INTEGER;
DEFINE cdiamovs				CHAR (2);
DEFINE cmesmovs				CHAR (2);
DEFINE cstmovsbts			CHAR (1);
-- 2014.02.11 FRG-i
DEFINE caniomovs			CHAR (4);
DEFINE cbts_dt				CHAR (8);
-- 2014.02.11 FRG-f

--2014.05.06 EPG
DEFINE cReferencia1         CHAR(20);	
DEFINE iFlagCen             INTEGER;
DEFINE iFlagSuc             INTEGER;
DEFINE cFolio               CHAR(16);
DEFINE dFecha_Pago           DATE;
DEFINE iCuantos             INTEGER;
DEFINE cDescripcionSPJ	 	CHAR(100);
	
	--SET DEBUG FILE TO  '/informix/adrian/sac_bts_movspaso.out';
	--TRACE ON;

/* INICIALIZACION DE VARIABLES */
LET ccodret 				= '00000';
LET itot_movssac 			= 0;
LET itot_movschqs 			= 0;
LET itot_movsbts  			= 0;
LET isqlerr  				= 0;
LET iisamerr  				= 0;
LET cinfoerr 				= "";
LET cstatussac				= "";
LET cstatmvhst				= "";
LET ccuenta_bts				= "";
LET ctrns_ctrl_efecte		= "";
LET ctrns_ctrl_crgocte 		= "";
LET imovsbts_payi			= 0;
LET imovsbts_payc			= 0;
LET cflg_sac				= "0";
LET cflg_chqs				= "0";
LET cflg_btscj				= "0";
LET cflg_btsab				= "0";
LET cflg_btsrev				= "0";
LET cproceso				= "MOVS_BTS";
LET dfechamovs				= CURRENT;
LET iprocsac				= 0;
LET cdiamovs				= "";
LET cmesmovs				= "";
LET cstmovsbts				= "";
-- 2014.02.11 FRG-i
LET caniomovs				= "";
LET cbts_dt			    	= "";
-- 2014.02.11 FRG-i

--2014.05.06 EPG
LET cReferencia1  		    = '';
LET iFlagCen      		    = 0;                 
LET iFlagSuc      		    = 0; 
LET cFolio        		    = ''; 
LET dFecha_Pago             = DATE(1);	
LET	iCuantos      		    = 0;
LET cDescripcionSPJ	 		= 'Inserta movimientos historicos (T-1) BTS a tablas de paso';

	BEGIN
    ON EXCEPTION SET isqlerr, iisamerr, cinfoerr
        IF isqlerr <> 0 THEN
            LET ccodret = isqlerr;
            EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
            RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
        END IF;
    END EXCEPTION;

/*
	Obtención fecha-SAC:
*/
	set isolation to dirty read;
	select {+INDEX(bdisac:sac_fechas 105_11)}
	fecha_hoy 
	into dfechamovs
	from bdisac:sac_fechas
	where empresa = vempresa;
	
	LET dfechamovs = dfechamovs-1;
	
	let cdiamovs = SUBSTR (dfechamovs, 4, 2);
	let cmesmovs = SUBSTR (dfechamovs, 1, 2);
	let caniomovs = SUBSTR (dfechamovs, 7, 4);
	let cbts_dt = caniomovs||cmesmovs||cdiamovs;	
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_BTS_MP', dfechamovs, '0', 'informix', 'sac_bts_movspaso', cDescripcionSPJ);

	if	cmesmovs = '01' AND cdiamovs = '01'
		then
			LET dfechamovs = dfechamovs-1;
		else
			if	cmesmovs = '12' AND cdiamovs = '25'
				then
					LET dfechamovs = dfechamovs-1;
			end if;
	end if;

/*
	Validación término exitoso en proceso de pase movimientos SAC al histórico:
*/
	set isolation to dirty read;
	select count (*) into iprocsac
	from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
	if iprocsac > 0
		then
			select status into cstatussac
			from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
			if cstatussac <> "1"
				then
					update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';					
				else
			end if;
		else
			INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			values (cproceso, dfechamovs, '0', 'informix', current);
	end if;
/*
	Obtención valores parametrizados de transacciones BTS:
*/
	set isolation to dirty read;
	select {+INDEX(bdisac:sac_convenios 103_4)}
	cuenta_prestadora, trans_cen_efectivo_cliente, trans_cen_cargo_cliente
	into ccuenta_bts, ctrns_ctrl_efecte, ctrns_ctrl_crgocte
	from bdisac:sac_convenios
	where numcategoria = '07' and numconvenio = '004';

/*
	Validación termino exitoso en proceso de pase movimientos Cheques al histórico:
*/
	set isolation to dirty read;
	select {+INDEX(bdinteg:sx_contproc 255_612)}
	status_proc into cstatmvhst
	from bdinteg:sx_contproc where fecha = dfechamovs and proceso = 'PasaMovsHist' and sistema = '01';
	
	select status into cstatussac
		from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
	if	cstatussac <> "1" or cstatussac is null
		then
			LET ccodret = "00001";
			LET isqlerr = 0;
			LET iisamerr = 0;
			LET cinfoerr = "Pase de Movimientos Servicios del día a Histórico no ha concluido.";
            EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
            RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
		else
		if	cstatmvhst <> "F" or cstatmvhst is null
			then
				set isolation to dirty read;
				select count (*) into iprocsac
				from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
				if iprocsac > 0
					then
						select status into cstatussac
						from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
						if cstatussac <> "1" or cstatussac is null
							then
								update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';								
							else
								INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
								values (cproceso, dfechamovs, '0', 'informix', current);
						end if;
					else
						INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
						values (cproceso, dfechamovs, '0', 'informix', current);
				end if;
			LET ccodret = "00002";
			LET isqlerr = 0;
			LET iisamerr = 0;
			LET cinfoerr = "Pase de Movimientos Dia a Histórico no ha concluido.";
			EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
			RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
			else
			
			select status into cstmovsbts
			from bdisac:sac_Procesos where proceso = cproceso and fecha_proceso = dfechamovs;
			if cstmovsbts = '1'
				then
					LET ccodret = "00003";
					LET isqlerr = 0;
					LET iisamerr = 0;
					LET cinfoerr = "Pase de Movimientos a tablas _paso ya ha sido ejecutado exitosamente el dia de hoy.";
					EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
				else
					if cstmovsbts = '0'
						then
							update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = cproceso;							
						else
							INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
							values (cproceso, dfechamovs, '0', 'informix', current);
					end if;
			end if;
			
/*
	se confirma flag_confirmacion_sucursal='1' si la remesa esta en cheques y servicios
*/
    FOREACH
        SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1,flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
			INTO  cReferencia1, iFlagCen, iFlagSuc, cFolio, dFecha_Pago
        FROM bdisac:sac_movimientoshistorial
        WHERE numcategoria = '07'
            AND numconvenio = '004'
            AND fecha_pago = dfechamovs
            AND status_cancelado <> 'S'
            AND flag_confirmacion_sucursal = 0

        IF iFlagCen = 0 or iFlagSuc =0 THEN
            SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
            IF iCuantos = 0 THEN
                SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago;   
                IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                END IF;
            END IF;
            IF iCuantos > 0 THEN            
                UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
                WHERE numcategoria = '07'
                    AND numconvenio = '004'
                    AND fecha_pago = dFecha_Pago
                    AND folio_suc = cFolio
                    AND referencia1 = cReferencia1
                    AND status_cancelado <> 'S'
                    AND flag_confirmacion_sucursal = 0;             
            END IF;
        END IF;
	END FOREACH;			
			
/*
	Conteo de registros BTS-SAC del día T-1:
*/
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
			count (*) into itot_movssac		
			from bdisac:sac_movimientoshistorial 
			where 
			numcategoria = '07' and numconvenio = '004'
			and fecha_pago = dfechamovs;

/*
	Conteo de registros BTS-Cheques del día T-1:
*/		
			set isolation to dirty read;
			select {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
			count (*) into itot_movschqs
			from bdicheq:sc_movhis
			where 
			empresa = vempresa and 
			fech_alt = dfechamovs
			and cuenta = ccuenta_bts
			and transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte);

/*
	Conteo de registros BTS-Payi del día T-1:
*/			
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_bts_payi idx_sac_bts_payi3)}
			count (*) into imovsbts_payi
			from "informix".sac_bts_payi
			where 
-- 2014.02.11 FRG-i
			--	fecha_insert::DATE = dfechamovs
			agent_dt = cbts_dt
-- 2014.02.11 FRG-f
			and opcode = '1100';

/*
	Conteo de registros BTS-Payc del día T-1:
*/			
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_bts_payc idx_sac_bts_payc)}
			count (*) into imovsbts_payc
			from "informix".sac_bts_payc
			where 
-- 2014.02.11 FRG-i
			--fecha_insert::DATE = dfechamovs
			agent_dt = cbts_dt
-- 2014.02.11 FRG-f
			and opcode = '1100';
			
			LET itot_movsbts = imovsbts_payi + imovsbts_payc;
			
/*
	Proceso de Inserción de registros del día T-1 en tablas _paso:
*/
			set isolation to dirty read;
			INSERT INTO bdisac:"informix".sac_cheques_paso
				SELECT {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
				folio_suc, fech_alt
				FROM bdicheq:"informix".sc_movhis
				WHERE cuenta = ccuenta_bts
				AND fech_alt = dfechamovs 
				AND transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte)
				and cancelad <> 'S';
				
			set isolation to dirty read;
			INSERT INTO bdisac:"informix".sac_chequesrev_paso
				SELECT {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
				folio_suc, fech_alt
				FROM bdicheq:"informix".sc_movhis
				WHERE cuenta = ccuenta_bts
				AND fech_alt = dfechamovs 
				AND transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte)
				and cancelad = 'S'
				and referencia = 'REV';
			
			LET cflg_chqs = "1";
			
			INSERT INTO bdisac:"informix".sac_servicios_paso
				SELECT {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
				folio_suc, referencia1, status_cancelado, flag_confirmacion_sucursal, fecha_pago, fecha_insert
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria= '07'  
				AND numconvenio='004'
				AND fecha_pago= dfechamovs;
				
			INSERT INTO bdisac:"informix".sac_serviciosrev_paso
				SELECT {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
				folio_suc, referencia1, status_cancelado, fecha_pago
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria= '07'  
				AND numconvenio='004'
				AND fecha_pago= dfechamovs
				AND status_cancelado = 'S';
			
			LET cflg_sac = "1";
			
			INSERT INTO bdisac:"informix".sac_abono_paso
				SELECT {+INDEX(bdisac:sac_bts_payc idx_sac_bts_payc)}
				confirmation_nm, bank_ref_nm, 
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_payc
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1100'
				and process_type_code = 'PAYC';
			
			LET cflg_btsab = "1";
			
			INSERT INTO bdisac:"informix".sac_btscaja_paso
-- 2014.02.11 FRG-i
				--	SELECT confirmation_nm, bank_ref_nm, fecha_insert
				SELECT confirmation_nm, bank_ref_nm, --agent_dt::date
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_payi
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1100';
			
			LET cflg_btscj = "1";
			
			INSERT INTO bdisac:"informix".sac_btsrevi_paso
				SELECT confirmation_nm, bank_ref_nm, --fecha_insert
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_revi
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1200';
			
			LET cflg_btsrev = "1";
			
			if	cflg_chqs = "1" and cflg_sac = "1" and cflg_btsab = "1" and cflg_btscj = "1" and cflg_btsrev = "1"
				then
					LET cinfoerr = 'Inserción en tablas _paso exitoso.';
					update bdisac:sac_procesos set status = '1' where proceso = cproceso and fecha_proceso::date = dfechamovs;
					--ACTUALIZA STATUS EN BITACORA
					EXECUTE PROCEDURE "informix".sp_bitacoraspj (1, 'IND_BTS_MP', dfechamovs, '1', 'informix', 'sac_bts_movspaso', cDescripcionSPJ);
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
				else
					LET ccodret = "00002";
					LET cinfoerr = 'Error en proceso inserción en tablas _paso. Validar Tabla sac_MensajeError.';
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
			end if;
		end if;
	end if;
	END;	
END PROCEDURE;