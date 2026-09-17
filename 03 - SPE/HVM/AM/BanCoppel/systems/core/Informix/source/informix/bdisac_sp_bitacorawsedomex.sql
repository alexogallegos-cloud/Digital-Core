CREATE PROCEDURE "informix".sp_bitacorawsedomex( pNumCategoria CHAR(2), pNumConvenio CHAR(3), pId_Sucursal CHAR (4), pFolioSucursal CHAR (16), pFechaPago DATE, pCodigoRespuesta CHAR(40), pConceptoRespuesta CHAR(80), pReferencia CHAR (27))
   RETURNING CHAR(5) as CodRet;
     

-- DeclaraciÃ³n de variables 
DEFINE cCodRet 			CHAR(5);
DEFINE iSqlErr         	INTEGER;
DEFINE cClavemedio		CHAR (2);
DEFINE cClavecentro		CHAR (2);
DEFINE cCuentaDeposito	CHAR (30);
DEFINE cFormaPago		CHAR (2);
DEFINE iImporte			INTEGER;
DEFINE dFechaAplic		DATE;
DEFINE cAutorizacion	CHAR (60);
DEFINE cPlazo			CHAR (2);
DEFINE cUser			CHAR (8);
DEFINE iInserta			INTEGER;
DEFINE iValida			INTEGER;

LET cCodRet 		  = '00000';
LET iSqlErr 		  = 0;
LET cClavemedio		  = '';
LET cClavecentro	  = '';
LET cCuentaDeposito	  = '';
LET cFormaPago		  = '';
LET iImporte		  = 0;
LET dFechaAplic		  = '';
LET cAutorizacion	  = '';
LET cPlazo			  = '00';
LET cUser			  = 'Informix';
LET iInserta		  = 0;
Let iValida			  = 0;
  
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			IF iInserta = 0 THEN
				INSERT INTO bdisac: "informix".sac_edomex_pagos(sucursal, folio_suc, fechapago, referencia, cod_resp) VALUES(pId_Sucursal, pFolioSucursal, pFechaPago, pReferencia, cCodRet);
				LET iInserta = 1;
			END IF;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/respaldosbd/Trinidad/sp_bitacorawsedomex.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  	
	
		IF NVL (pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL (pId_Sucursal, '') = '' OR NVL (pFolioSucursal, '') = '' 
		  OR NVL (pFechaPago, '') = ''   OR NVL (pCodigoRespuesta, '') = ''   OR  NVL (pReferencia, '') = ''  THEN
			 LET cCodRet = '00002';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodRet;
		END IF;
	
		--Obtener Forma de pago de bdisac: sac_msw_solicitud
		SELECT forma_pago, importe_pago, fecha_pago, LPAD(folio_suc, 60,'0') INTO cFormaPago, iImporte, dFechaAplic, cAutorizacion  FROM bdisac: "informix".sac_movimientos WHERE id_sucursal= pId_Sucursal AND numcategoria= pNumCategoria AND numconvenio= pNumConvenio AND folio_suc= pFolioSucursal;
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
		ELSE 
			--obtener la cuenta de depocito de bdisac: sac_edomex_cuentas
			SELECT campo5 INTO cCuentaDeposito FROM bdisac: "informix".sac_msw_solicitud  WHERE campo7= pReferencia and folio_suc = pFolioSucursal;
		END IF;	
	SELECT fn_instr(valor, pId_Sucursal) INTO iValida FROM  bdisac: "informix".sac_param where cod_param = '28';
		
	IF iValida > 0 THEN
		SELECT valor INTO cClavemedio FROM bdisac: sac_param where cod_param = '27';
	ELSE 
		SELECT valor INTO cClavemedio FROM bdisac: sac_param where cod_param = '26';
	END IF;
	
	SELECT valor INTO cClavecentro FROM  bdisac: "informix".sac_param where cod_param = '29';
			
	--Solicita y guarda el valor de usuario de bdisac: sac_movimientos 
	SELECT usuario INTO cUser  FROM bdisac: "informix".sac_movimientos where id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND fecha_pago=pFechaPago;
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
	END IF;
	
	-- Insertar bitacora en bdisac: sac_edomex_pagos
	INSERT INTO bdisac: "informix".sac_edomex_pagos (clavemedio,clavecentro,sucursal,folio_suc,cuentadeposito,formapago,referencia,importe,fechapago,fechaaplic,autorizacion,plazo,cod_resp,opcode,descripcion,user_insert,fecha_insert) VALUES (cClavemedio,cClavecentro,pId_Sucursal,pFolioSucursal,cCuentaDeposito,cFormaPago,pReferencia,iImporte,pFechaPago,dFechaAplic,cAutorizacion,cPlazo,cCodRet,pCodigoRespuesta,pConceptoRespuesta,cUser,current );
	   
	RETURN cCodRet;
END;   
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION:  SP para la bitacora de Edo de mexico que se insertarÃ¡ en la tabla bdisac: sac_edomex_pagos',
'FOLIO: 1468 - PagosRef_PagoImpEdoMex ',
'FECHA : 20/02/2015',
'VERSION: 20150219.2052',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_confirmacionbitacoraedomex(pFolioSuc CHAR(16))

	RETURNING CHAR(5) AS CodRet;
			 ---CHAR(50) AS Descripcion;
	
	--DEFINICION DE VARIABLES
	DEFINE cCodRet			CHAR(5);
	DEFINE isql_err			INTEGER;
	DEFINE cInfoError		CHAR (80);
	DEFINE iIsamErr         INTEGER;
	DEFINE dFechaHoy		DATE;
	
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet 		='00000';
	LET isql_err 		= 0;
	LET cInfoError 		= '';
	LET iIsamErr		= 0;
	LET dFechaHoy 		='';
	
	BEGIN
		ON EXCEPTION SET isql_err,iIsamErr,cInfoError
			IF isql_err <> 0 THEN
			
				LET cCodRet = isql_err;
				RETURN cCodRet WITH RESUME;	
				
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/sysifx/JesusBueno/1468/sp_confirmacionbitacoraedomex.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pFolioSuc,'') = '' OR length(TRIM(pFolioSuc)) <> 16 THEN 
			LET cCodRet = '00001'; --El parametro viene vacio No se reversa
		ELSE
			
			SELECT fecha_hoy 
			INTO dFechaHoy
			FROM bdisac:"informix".sac_fechas;
			
			IF EXISTS (SELECT referencia FROM bdisac:"informix".sac_edomex_pagos
				WHERE folio_suc = pFolioSuc AND fechapago= dFechaHoy) THEN
				LET cCodRet = '00002'; --Si existe el registro No se reversa
			ELSE
				LET cCodRet = '00000'; --No existe registro en la tabla, se reversa.
			END IF;
			
		END IF;	
		
		RETURN cCodRet WITH RESUME;		
	
	END 
	
END PROCEDURE	
DOCUMENT
'DESCRIPCION: Se crea procedimiento para consultar si la transaccion se encuentra registrada ',
'AUTOR :Jesus Isaias Bueno',
'FECHA : 19-02-2015',
'BD    : bdisac',
'VER   : 1.0';

CREATE PROCEDURE "informix".sp_consdatosticketedomex(pFolioSuc CHAR(27))

    --DATOS A REGRESAR---
    RETURNING CHAR(5),CHAR(27),CHAR(1);  

    --DEFINICION DE VARIABLES--
    DEFINE sql_err           INT;
    DEFINE cCodRet           CHAR(5);
	DEFINE cFormaPago        CHAR(1);
	DEFINE cNumConfirmacion  CHAR(27);
	DEFINE cClave            CHAR(6);
	
		
    --INICIALIZACION DE VARIABLES--
    LET sql_err            = 0;
    LET cCodRet            = '00000';	
	LET cFormaPago         = "";
	LET cNumConfirmacion   = "";	
    LET cClave             = "";
 
BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet,cNumConfirmacion,cFormaPago WITH RESUME;  
        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/JesusBueno/1468/sp_consdatosticketedomex.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    IF NVL(pFolioSuc,'') = '' THEN
		LET cCodRet =   '00001'; --Faltan parÃ¡metros
		RETURN cCodRet,cNumConfirmacion,cFormaPago WITH RESUME;  
	END IF;

	IF EXISTS (SELECT referencia1 FROM bdisac:"informix".sac_movimientos WHERE folio_suc = pFolioSuc AND status_cancelado = 'N' 
	          AND numcategoria = '08' AND numconvenio = '002') THEN
        SELECT NVL(forma_pago,''), NVL(referencia1,'')
		INTO cFormaPago, cNumConfirmacion
	    FROM bdisac:"informix".sac_movimientos 
		WHERE folio_suc = pFolioSuc
		AND numcategoria = '08' 
		AND numconvenio = '002'
		AND status_cancelado = 'N';
	ELSE
	    LET cCodRet =   '00002'; 
    END IF;
	
	
    RETURN cCodRet,cNumConfirmacion,cFormaPago WITH RESUME;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para consultar la forma de pago y el numero de confirmaciÃ³n para la categoria 08',
'AUTOR : Hugo Vazquez ',
'FECHA : 02-03-2015',
'Ver.  : 1.0',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_inserta_msw_respuesta( pNumCategoria  CHAR(2),
													  pNumConvenio	 CHAR(3),
													  pId_Sucursal	 CHAR(4),
													  pFolioSucursal CHAR (16),
													  pFechaPago	 DATE,
													  pCadena_Req	 CHAR (1620),
													  pCadena_Rply	 CHAR (1620)
													)
   RETURNING CHAR(5) as cCodRet, CHAR(40) as cCodigoRespuesta;
   
-- DeclaraciÃ³n de variables 
	DEFINE cCodigoRespuesta CHAR (40);
	DEFINE cCodigoResp  CHAR (10);
	DEFINE cCodRet 		CHAR(5);
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
	DEFINE cCampo1  CHAR(40); DEFINE cCampo2  CHAR(40); DEFINE cCampo3  CHAR(40); DEFINE cCampo4  CHAR(40); DEFINE cCampo5  CHAR(40); 
	DEFINE cCampo6  CHAR(40); DEFINE cCampo7  CHAR(40); DEFINE cCampo8  CHAR(40); DEFINE cCampo9  CHAR(40); DEFINE cCampo10 CHAR(40);
	DEFINE cCampo11 CHAR(40); DEFINE cCampo12 CHAR(40); DEFINE cCampo13 CHAR(40); DEFINE cCampo14 CHAR(40); DEFINE cCampo15 CHAR(40);
	DEFINE cCampo16 CHAR(40); DEFINE cCampo17 CHAR(40); DEFINE cCampo18 CHAR(40); DEFINE cCampo19 CHAR(40); DEFINE cCampo20 CHAR(40); 
	DEFINE cCampo21 CHAR(40); DEFINE cCampo22 CHAR(40); DEFINE cCampo23 CHAR(40); DEFINE cCampo24 CHAR(40); DEFINE cCampo25 CHAR(40); 
	DEFINE cCampo26 CHAR(40); DEFINE cCampo27 CHAR(40); DEFINE cCampo28 CHAR(40); DEFINE cCampo29 CHAR(40); DEFINE cCampo30 CHAR(40);
	DEFINE cCampo31 CHAR(40); DEFINE cCampo32 CHAR(40); DEFINE cCampo33 CHAR(40); DEFINE cCampo34 CHAR(40); DEFINE cCampo35 CHAR(40);
	DEFINE cCampo36 CHAR(40); DEFINE cCampo37 CHAR(40); DEFINE cCampo38 CHAR(40); DEFINE cCampo39 CHAR(40); DEFINE cCampo40 CHAR(40); 
	

	LET cCodRet		= '00000';
	LET cCodigoRespuesta = '';
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
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
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
			SELECT campo_codresp INTO cCodigoResp  FROM  bdisac: "informix".sac_intrfz_serv WHERE numcategoria= pNumCategoria AND numconvenio=pNumConvenio;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodigoResp = 'Campo1';
			END IF;
		
			FOREACH
					-- OPtiene el campo y la lonjitud de los campos para ser separados
					SELECT campo, longitud INTO cNomCamp, iLong_c FROM bdisac: "informix".sac_intrfz_serv_det_resp WHERE numcategoria= pNumCategoria AND numconvenio= pNumConvenio ORDER BY id_campo ASC
							
					
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
				
				 -- Solicita y guarda el valor de trans_suc_efectivo de bdisac: sac_convenios
				SELECT trans_suc_efectivo INTO cTran_suc FROM bdisac: "informix".sac_convenios WHERE numcategoria= pNumCategoria and numconvenio= pNumConvenio;

				-- Colicita y guarda el valor de trans_interact de bdisac: sac_intrfz_serv
				SELECT trans_interact INTO   cTrans_Inte FROM  bdisac: "informix".sac_intrfz_serv WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio;
				
				--Solicita y guarda el valor de usuario de bdisac: sac_movimientos 
				SELECT usuario INTO cUser FROM bdisac: "informix".sac_movimientos WHERE id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND fecha_pago= pFechaPago;
				
			SELECT trans_central INTO cTran_cent FROM bdisac: "informix".sac_msw_solicitud where   numcategoria= pNumCategoria and numconvenio= pNumConvenio and folio_suc= pFolioSucursal and fecha_pago= pFechaPago;
				
				IF cCodRet <> '00000' THEN
					LET cCodigoRespuesta = '';
				ELSE 
					-- Inserta los valores de la trama (pCadena_Rply) a la bdisac: sac_msw_respuesta
					 INSERT INTO bdisac: "informix".sac_msw_respuesta(numcategoria, numconvenio, id_sucursal, trans_suc, trans_central, trans_interact, folio_suc, fecha_pago, campo1, campo2, campo3, campo4, campo5, campo6 , campo7, campo8, campo9, campo10, campo11, campo12, campo13, campo14, campo15, campo16, campo17, campo18, campo19, campo20, campo21, campo22, campo23, campo24, campo25, campo26, campo27, campo28, campo29, campo30, campo31, campo32, campo33, campo34, campo35, campo36, campo37, campo38, campo39, campo40, cadena_req, cadena_rply, user_insert, fecha_insert)
					VALUES (pNumCategoria, pNumConvenio, pId_Sucursal, cTran_suc, cTran_cent, cTrans_Inte, pFolioSucursal, pFechaPago, cCampo1, cCampo2, cCampo3, cCampo4, cCampo5, cCampo6, cCampo7, cCampo8, cCampo9, cCampo10, cCampo11, cCampo12, cCampo13, cCampo14, cCampo15, cCampo16, cCampo17, cCampo18, cCampo19, cCampo20, cCampo21, cCampo22, cCampo23, cCampo24, cCampo25, cCampo26, cCampo27, cCampo28, cCampo29, cCampo30, cCampo31, cCampo32, cCampo33, cCampo34, cCampo35, cCampo36, cCampo37, cCampo38, cCampo39, cCampo40, pCadena_Req, pCadena_Rply, cUser, current );
				END IF;
				
				  
			RETURN cCodRet, NVL(cCodigoRespuesta, '');
			
			
		
		
END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: SPL separa los campos de la trama que regresa como resultado el central de acuerdo con la configuraciÃ³n de la tabla bdisac: sac_intrfz_serv_det_resp.',
'FOLIO: 1468-PagosRef_PagoImpEdoMex',
'FECHA : 12 de Febrero de 2015',
'VERSION: 20150212.1621',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtiene_emex_catrespws( pCodigoRespuesta	Char(40))
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
	
	--SET DEBUG FILE TO '/tmp/sp_obtiene_emex_catrespws.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		  
    IF NVL (pCodigoRespuesta, '') = '' THEN
			 LET cCodRet = '00001';
	ELSE
		SELECT concepto INTO cConseptoRespuesta FROM  bdisac: "informix".sac_edomex_catrespws where clave= pCodigoRespuesta;
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
'DESCRIPCION: SP regresa el concepto de el codigo de respuesta a consultar de bdisac: sac_edomex_catrespws.',
'FOLIO: 1468-PagosRef_PagoImpEdoMex',
'FECHA : 12 de Febrero de 2015',
'VERSION: 20150212.1621',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtiene_intrfz_serv( pNumCategoria Char(2),
													pNumConvenio Char(3))
   RETURNING CHAR(5) as CodRet, CHAR(5) as Trans_Interact, CHAR(16) as Ip, INTEGER as Puerto, INTEGER as TimeOut, CHAR(4) as Cod_cons_trama, CHAR(10) as Campo_codresp, CHAR(4) as Cod_cons_codresp, CHAR(4) as Cod_cons_bitacora, CHAR(4) as Cod_cons_validad, CHAR(1) as Noenvia_Resp, CHAR(4) as Cod_eror_noenvia;

-- DeclaraciÃ³n de variables 
DEFINE cCodRet 			 CHAR(5);
DEFINE cTrans_Interact	 CHAR(5);
DEFINE cIp 				 CHAR(16);
DEFINE iPuerto 			 INTEGER;
DEFINE iTimeOut 		 INTEGER;
DEFINE cCod_cons_trama 	 CHAR(4);
DEFINE cCampo_codresp  	 CHAR(10);
DEFINE cCod_cons_codresp CHAR(4);
DEFINE iSqlErr           INTEGER;
DEFINE cNoenvia_Resp	 CHAR (1);
DEFINE cCod_eror_noenvia CHAR(4);
DEFINE cCod_cons_bitacora CHAR (4);
DEFINE cCod_cons_validad CHAR(4);

LET cCodRet 		  = '00001';
LET cTrans_Interact   ='';
LET cIp 			  ='';
LET iPuerto 		  = 0;
LET iTimeOut 		  = 0;
LET cCod_cons_trama   ='';
LET cCampo_codresp 	  ='';
LET cCod_cons_codresp ='';
LET iSqlErr 		  = 0;
LET cNoenvia_Resp	  = '';
LET cCod_eror_noenvia = '';
LET cCod_cons_bitacora = '';
  
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTrans_Interact, cIp, iPuerto, iTimeOut, cCod_cons_trama, cCampo_codresp, cCod_cons_codresp, cCod_cons_bitacora, cCod_cons_validad, cNoenvia_Resp, cCod_eror_noenvia;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_obtiene_intrfz_serv.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  	

	SELECT trans_interact, ip, puerto, time_out, cod_cons_trama, campo_codresp, cod_cons_codresp,cod_cons_bitacora,cod_cons_valida, noenvia_respuesta, cod_error_noenviada
	INTO cTrans_Interact, cIp, iPuerto, iTimeOut, cCod_cons_trama, cCampo_codresp, cCod_cons_codresp,cCod_cons_bitacora, cCod_cons_validad, cNoenvia_Resp, cCod_eror_noenvia
	FROM bdisac: "informix".sac_intrfz_serv where numcategoria= pNumCategoria and numconvenio= pNumConvenio;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 OR cTrans_Interact= '' OR cIp = '' OR iPuerto= '' OR iTimeOut= '' OR cCod_cons_trama= '' OR cCampo_codresp= '' OR cCod_cons_codresp= '' THEN
		LET cCodRet = '00001';
	ELSE
		LET cCodRet = '00000';
	END IF
	
	RETURN cCodRet, cTrans_Interact, cIp, iPuerto, iTimeOut, cCod_cons_trama, cCampo_codresp, cCod_cons_codresp, cCod_cons_bitacora, cCod_cons_validad, cNoenvia_Resp, cCod_eror_noenvia;
		
	END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION:  Con el numero de categorÃ­a y numero de convenio obtendrÃ¡ la configuraciÃ³n desde la tabla bdisac: sac_intrfz_serv.',
'FOLIO: 1468 - PagosRef_PagoImpEdoMex',
'FECHA : 09/02/2015',
'VERSION: 20150209.1452',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtiene_msw_validacion( pCodigoRespuesta	Char(40),
												  pNumCategoria  CHAR(2),
												  pNumConvenio	 CHAR(3))
   RETURNING CHAR(5) as cCodRet, CHAR (1) as cReversa, CHAR (4) as cCod_err, CHAR (4) as cCod_err_reversa, CHAR(80) as cEnc_errores;

-- DeclaraciÃ³n de variables 
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cReversa			CHAR (1);
	DEFINE cCod_err			CHAR (4);
	DEFINE cCod_err_reversa	CHAR (4);
	DEFINE cEnc_errores		CHAR (80);

	LET cCodRet				= '11111';
	LET iSqlErr				= 0;
	LET cReversa			= '';
	LET cCod_err			= '';
	LET cCod_err_reversa	= '';
	LET cEnc_errores		= '';
						
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cReversa, cCod_err, cCod_err_reversa, cEnc_errores;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/sp_obtiene_msw_validacion.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		  
    IF NVL (pCodigoRespuesta, '') = '' OR NVL (pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' THEN
			 LET cCodRet = '00001';
	ELSE
		SELECT reversa, cod_err, cod_err_reversa, enc_errores 
		INTO cReversa, cCod_err, cCod_err_reversa, cEnc_errores 
		FROM bdisac: "informix".sac_msw_validacion  
		WHERE clave= pCodigoRespuesta AND numcategoria= pNumCategoria AND numconvenio= pNumConvenio;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
		ELSE 
			LET cCodRet = '00000';
		END IF;
	END IF;
	
	RETURN cCodRet, cReversa, cCod_err, cCod_err_reversa, cEnc_errores;
		
END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: SP regresa los datos de error que se almacenaron en bdisac: sac_msw_validacion con respecto al codigo de respuesta, nÃºmero de categoria, y nÃºmero de convenio.',
'FOLIO: 1468-PagosRef_PagoImpEdoMex',
'FECHA : 13 de Febrero de 2015',
'VERSION: 20150212.1621',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtienelineabaseedomex(pCaptura CHAR(27),
												pImporte CHAR(20))
	RETURNING CHAR(5) AS CodigoRetorno--, CHAR(4) AS cNumErrCom, CHAR (2) cSistema

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE cCodRet			CHAR(5);
DEFINE i				INTEGER;
DEFINE iSuma        	INTEGER;
DEFINE dFecha_Hoy 		DATE;
DEFINE iAux  			CHAR(20);
DEFINE iMultiplica 		INTEGER;
DEFINE cValidaFecha 	CHAR(4);
DEFINE cDigV        	CHAR(2);
DEFINE iDia				INTEGER;
DEFINE iYear			INTEGER;
DEFINE iMes				INTEGER;
DEFINE iLongDV			INTEGER;
DEFINE iAuxMonto		CHAR(20);
DEFINE cMonto			CHAR(1);
DEFINE iAuxSumaMonto	INTEGER;
--DEFINE cNumErrCom 		CHAR(4);
--DEFINE cSistema			CHAR(2);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET i       		= 0;
LET iSuma			=0;
LET dFecha_Hoy		= DATE(1);
LET iAux  			='';
LET iMultiplica 	= 0;
LET cValidaFecha 	='';
LET cDigV 			= '';
LET iDia			=0;
LET iYear			=0;
LET iMes			=0;
LET iLongDV			=0;
LET iAuxMonto 		='';
LET cMonto			='';	
LET iAuxSumaMonto 	=0;
--LET cNumErrCom 		='0';
--LET cSistema 		='24';

	--SET DEBUG FILE TO '/home/sysifx/JesusBueno/1468/sp_obtienelineabaseedomex.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet;		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF (TRIM(NVL(pCaptura,'')) = '' OR LENGTH(TRIM(pCaptura)) <> 27) THEN
		LET cCodRet = '00002';
	ELSE
		
		
		SELECT fecha_hoy INTO dFecha_Hoy
		FROM bdisac:"informix".sac_fechas;
		
		LET cValidaFecha = pCaptura[20,23];
		LET cDigV = pCaptura[26,27];
		LET cMonto = pCaptura[24,24];
		
		--Valida la fecha
		
		--CALCULA EL DIGITO VERIFICADOR DE LA FECHA
		LET iDia = CAST(SUBSTR(dFecha_Hoy,4,2) AS INTEGER) - 1;
		LET iMes = (CAST(SUBSTR(dFecha_Hoy,1,2) AS INTEGER) -1) * 31;
		LET iYear = (CAST(SUBSTR(dFecha_Hoy,7,4) AS INTEGER) - 2009) * 372;
		LET iSuma =  iDia + iMes + iYear;
	
		IF cValidaFecha < iSuma THEN
			LET cCodRet = '00084'; --FECHA NO COINCIDE
			--LET cNumErrCom ='84'; --Numero a Validar en la ierrcom
			RETURN cCodRet;
		END IF;
			
		--Valida el dv
		LET iSuma = 0;
		LET iMultiplica = 11;
		LET iLongDV = 25;
		
		FOR i = 1 TO iLongDV
			
			LET iAuxSumaMonto = SUBSTRING (pCaptura FROM iLongDV FOR 1) * iMultiplica;
				IF iMultiplica = 11 THEN
					LET iMultiplica = 13;
				ELIF iMultiplica = 13 THEN
					LET iMultiplica = 17;
				ELIF iMultiplica = 17 THEN
					LET iMultiplica = 19;
				ELIF iMultiplica = 19 THEN
					LET iMultiplica = 23;
				ELIF iMultiplica = 23 THEN
					LET iMultiplica = 11;
				END IF;
			LET iSuma = iSuma + iAuxSumaMonto;
			LET iLongDV = iLongDV - 1;
			
		END FOR;
		
		LET iSuma = MOD(iSuma,97) + 1;
		
		IF iSuma <> cDigV THEN
			LET cCodRet = '00082';			--LET cNumErrCom ='82'; --Numero a Validar en la ierrcom
		END IF;
		
		IF  LENGTH (TRIM(pImporte)) = 9 THEN
			--Valida el importe
			
			LET iMultiplica = 7;
			LET iSuma = 0;
			LET iLongDV = LENGTH(pImporte);
			
			FOR i = 1 TO iLongDV  
				
				LET iAuxSumaMonto = SUBSTRING (TRIM(pImporte) FROM iLongDV FOR 1) * iMultiplica;
					IF iMultiplica = 7 THEN
						LET iMultiplica = 3;
					ELIF iMultiplica = 3 THEN
						LET iMultiplica = 1;
					ELIF iMultiplica = 1 THEN
						LET iMultiplica = 7;
					END IF;
				LET iSuma = iSuma + iAuxSumaMonto;
				LET iLongDV = iLongDV - 1;
				
			END FOR;
			
			LET iSuma = MOD(iSuma,10);
			
			IF iSuma <> cMonto THEN
				LET cCodRet = '00004'; --Importe no coincide
			END IF;
		END IF;
	END IF;

	RETURN cCodRet;
END;

END PROCEDURE
DOCUMENT
'Folio: 1468',
'Autor: 95347143, Jesus Isaias Bueno',
'Fecha: 20/02/2015',
'DescripciÃ³n: Se crea procedimiento para validar la linea de captura del EDOMEX',
'Sustento: PgImpMex_RQM_10525_PagoImpEdoMex_v1.0.doc',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sacreportemensualedomex(pConvenio CHAR(5), pPeriodo CHAR(6))
RETURNING
		CHAR (5) 	  AS retorno,
		CHAR(6) 	  AS aniomes,
		DATE 	 	  AS fecha,
		INTEGER       AS num_operaciones,
		MONEY (16,2)  AS comision,
		MONEY (16,2)  AS iva;

--Definicion de Variables
DEFINE cCodRet			 CHAR(5);
DEFINE cAnioMes			 CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE dFecha			 DATE;
DEFINE iNumOperaciones	 INTEGER;
DEFINE iSqlErr			 INTEGER;
DEFINE iIsamErr			 INTEGER;
DEFINE mComision		 MONEY(16,2);
DEFINE mIva				 MONEY(16,2);

--Inicializacion de Variables
LET cCodRet				 = '00000';
LET cAnioMes			 = '';
LET dFecha				 = DATE (1);
LET iNumOperaciones		 = 0;
LET mComision			 = 0;
LET mIva				 = 0;
LET iSqlErr				 = 0;
LET iIsamErr			 = 0;
LET cInfoErr			 = '';

-- SET DEBUG FILE TO  '/home/sysifx/JesusBueno/sp_sacreportemensualedomex.out';
-- TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualedomex");
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
'DESCRIPCIÃN: Obtiene la informacion para la generacion del reporte mensual de pago de EDOMEX',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 17-02-2015',
'VERSIÃN: 20150217.1206',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesemanaledomex(pConvenio CHAR (5),pConsecutivo INTEGER)
	RETURNING
			CHAR (5) 	AS retorno,
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
	DEFINE cCodRet			CHAR (5);
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
	LET cCodRet			= '00000';
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
	
	-- SET DEBUG FILE TO  '/home/sysifx/JesusBueno/sp_sacreportemensualedomex.out';
	-- TRACE ON;
	
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanaledomex");
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
'DESCRIPCIÃN: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos de sericios TAE',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 17 Febrero 2015',
'VERSIÃN: 20150217.1208',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_axtel_validadv(pReferencia CHAR(17))
	RETURNING 
	CHAR (5)  AS cCodRet, 
	CHAR (80) AS Descripcion;

--Definicion de Variables
DEFINE pDigVerificador  CHAR(1);
DEFINE iSqlErr 			INTEGER;
DEFINE cCodRet			CHAR(5);
DEFINE cDescripcion 	CHAR(80);
DEFINE iMultiplo		INTEGER;
DEFINE i 				INTEGER;
DEFINE iNum				INTEGER;
DEFINE iLongDV			INTEGER;
DEFINE iDigVer        	INTEGER;
DEFINE iSuma        	INTEGER;
DEFINE iAux1  			INTEGER;
DEFINE iAux2			INTEGER;
DEFINE iResta			INTEGER;
DEFINE iModulo			INTEGER;
--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cDescripcion	= '';
LET iMultiplo		= 0;
LET i       		= 0;
LET iNum			= 0;
LET iLongDV			= 0;
LET iDigVer			= 0;
LET iSuma			= 0;
LET iAux1  			= 0;
LET iAux2 			= 0;
LET iResta			= 0;
LET iModulo			= 0;

	--SET DEBUG FILE TO '/informix/EPG/sp_validadv_axtel.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet,cDescripcion;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pReferencia,'')) = '' OR LENGTH(TRIM(pReferencia)) < 17 THEN -- OR TRIM(pDigVerificador) = '' THEN
		LET cCodRet = '00002';
		LET cDescripcion = 'Referencia incorrecta, favor de validar';
	ELSE
		LET pDigVerificador = SUBSTR(pReferencia,17,1);
		LET pReferencia     = SUBSTR(pReferencia,1,16);
		LET iLongDV = LENGTH(TRIM(pReferencia));
		LET iMultiplo  = 2;
		FOR i = 1 TO iLongDV 
			LET iNum = SUBSTRING (pReferencia FROM iLongDV FOR 1);
			LET iDigVer = iNum * iMultiplo;
			
			IF iDigVer >= 10 THEN 
				LET iAux1 = SUBSTR(iDigVer,1,1);
				LET iAux2 = SUBSTR(iDigVer,2,1);
				LET iDigVer = iAux1 + iAux2;
			END IF;
			
			IF iMultiplo = 2 THEN 
				LET iMultiplo  = 1;
			ELSE 
				LET iMultiplo  = 2;
			END IF;
			LET iSuma = iSuma + iDigVer;
			LET iLongDV = iLongDV - 1;
		END FOR;
		LET iResta  = 0;
		LET iModulo = MOD(iSuma,10);
		IF iModulo = 0 THEN	    
			LET iResta = 0;
		ELSE  
			LET iResta = 10 - iModulo;
		END IF;
		
		IF iResta <> pDigVerificador THEN
			LET cCodRet = '00437';
			LET cDescripcion = 'Digito verificador incorrecto, favor de validar';
		ELSE 
			LET cCodRet = '00000';
			LET cDescripcion = 'Referencia valida';
			
		END IF;
		
	END IF;
	
	RETURN cCodRet,cDescripcion;
	
END;
	
END PROCEDURE
DOCUMENT
'Folio: 1483',
'Autor: 95347143, Jesus Isaias Bueno',
'Fecha: 15/04/2015',
'DescripciÃ³n: Se crea procedimiento para validar la linea de captura de AXTEL',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_cablemas_validadv( pReferencia CHAR(32))
   RETURNING CHAR(5) as CodRet, CHAR(80) as Descripcion;     

-- DeclaraciÃ³n de variables 
DEFINE cCodRet 			 CHAR(5);
DEFINE iSqlErr         	 INTEGER;
DEFINE cDescripcion 	 CHAR(80);
DEFINE iDigVerif		 INTEGER;
DEFINE cReferencia		 CHAR(31);
DEFINE iContador		 INTEGER;
DEFINE iMultiplo		 INTEGER;
DEFINE iNum				 INTEGER;
DEFINE iSuma			 INTEGER;
DEFINE cDescompone		 VARCHAR(6);
DEFINE iDigVerifRecibido INTEGER;
DEFINE iValida			 SMALLINT;
DEFINE iVal				 SMALLINT;

LET cCodRet 		   	= '00000';
LET iSqlErr 		  	= 0;
LET cDescripcion		= '';
LET iDigVerif 			= 0;
LET cReferencia 		= '';
LET iContador 			= 0;
LET iMultiplo 			= 0;
LET iNum 				= 0;
LET iSuma 				= 0;
LET cDescompone 		= '';
LET iDigVerifRecibido 	= 0;
LET iValida				= 0;
LET iVal				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescripcion;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO  '/informix/EPG/sp_cablemas_validadv.out';
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  	
	
	IF length(pReferencia) = 32 OR NVL (pReferencia, '') = '' THEN 
		--separa de pReferencia la referencia y el digito verificador
		LET iDigVerif		= SUBSTR(pReferencia , 32 , 1);
		LET cReferencia		= SUBSTR(pReferencia , 1  , 31);
		
		-- Calcula el valor del digito verificador para validar 
		FOR iContador = 1 TO 31
			IF iMultiplo >= 9 THEN
				LET iMultiplo = 1;
			ELSE
				LET iMultiplo = iMultiplo + 1;
			END IF;
			
			LET iValida = SUBSTR(cReferencia,iContador,1);
			IF iValida  = '0' THEN
				LET ival = 0;
			ELIF iValida  = '1' THEN
				LET ival = 0;
			ELIF iValida  = '2' THEN
				LET ival = 0;
			ELIF iValida  = '3' THEN
				LET ival = 0;
			ELIF iValida  = '4' THEN
				LET ival = 0;
			ELIF iValida  = '5' THEN
				LET ival = 0;
			ELIF iValida  = '6' THEN
				LET ival = 0;
			ELIF iValida  = '7' THEN
				LET ival = 0;
			ELIF iValida  = '8' THEN
				LET ival = 0;
			ELIF iValida  = '9' THEN
				LET ival = 0;
			ELSE
				LET ival = 1;				
			END IF ;
			
			-- Valida la referencia
			IF ival = 0 THEN
				LET iNum = SUBSTR(cReferencia, iContador, 1);
			ELSE
				LET cCodRet = '00002';
				LET cDescripcion = 'Referencia incorrecta, favor de validar.';
				RETURN cCodRet, cDescripcion;
			END IF;
				
			LET iSuma = iSuma + iNum * iMultiplo;
		END FOR;
		
		LET cDescompone = iSuma;
		LET iDigVerifRecibido = SUBSTR(cDescompone, LENGTH(TRIM(cDescompone)), 1);
		
		-- Verifica el digito verificador y determina si la referencia es valida
		IF iDigVerifRecibido <> iDigVerif THEN
			LET cCodRet = '00437';
			LET cDescripcion = 'Digito verificador incorrecto, favor de validar.';
		ELSE
			LET cDescripcion = 'Referencia valida.';
		END IF;
		
	ELSE
		LET cCodRet = '00002';
		LET cDescripcion = 'Referencia incorrecta, favor de validar.';
	END IF; 
	
	RETURN cCodRet, cDescripcion;
END;   
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION:  Valida referencia de pago de servicio de cablemas',
'FOLIO: 1483 - ValidacionesReferenciasHPS',
'FECHA : 20/04/2015',
'VERSION: 20150420.1050',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_cfe_validadv(pReferencia CHAR(30),pImporte CHAR(10))
	RETURNING 
    CHAR (5)  AS cCodRet,
    CHAR (80) AS Descripcion;

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE cCodRet			CHAR(5);
DEFINE cDescripcion 	CHAR(80);
DEFINE cDigVerRef      	CHAR(1);
DEFINE cFechaRef		CHAR(6);
DEFINE cFechaHoy		CHAR(8);
DEFINE cFechaFinal		CHAR(6);
DEFINE iMultiplo		INTEGER;
DEFINE i 				INTEGER;
DEFINE iNum				INTEGER;
DEFINE iLongDV			INTEGER;
DEFINE iSuma        	INTEGER;
DEFINE iModulo			INTEGER;
DEFINE iDigVer			INTEGER;	
DEFINE cImporte         CHAR(10);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cDescripcion	= '';
LET cDigVerRef		= 0;
LET cFechaRef		= '';
LET cFechaHoy		= '';
LET cFechaFinal		= '';
LET iMultiplo		= 0;
LET i       		= 0;
LET iNum			= 0;
LET iLongDV			= 0;
LET iSuma			= 0;
LET iModulo			= 0;
LET iDigVer			= 0;
let cImporte        = '';

	--SET DEBUG FILE TO '/informix/yuri/sp_validadv_cfe.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet,cDescripcion;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pReferencia,'')) = '' OR LENGTH(TRIM(pReferencia)) < 30 THEN
		LET cCodRet = '00003';
		LET cDescripcion = 'Referencia incorrecta, favor de validar';
	ELSE
		
		SELECT TO_CHAR(fecha_hoy,'%Y%m%d') INTO cFechaHoy
		FROM bdisac:"informix".sac_fechas;	

		--LET cFechaHoy= '20150512';
		
		LET iLongDV = LENGTH(TRIM(pReferencia)) -1 ;
		LET cDigVerRef = SUBSTR (pReferencia, LENGTH(TRIM(pReferencia)), 1);
		LET cFechaRef = SUBSTR(pReferencia,15,6);
        LET cImporte = SUBSTR(pReferencia,21,9);

		LET cFechaFinal  = SUBSTR(cFechaHoy,3,6);

        
        IF (cImporte::money) <> (pImporte::money) THEN
			LET cCodRet = '00001';
			LET cDescripcion = 'El importe es diferente al de la referencia';
            RETURN cCodRet,cDescripcion;
        END IF;
		
		
		IF (cFechaRef - cFechaFinal) < 2 THEN
			LET cCodRet = '00001';
			LET cDescripcion = 'Fecha fuera de rango, favor de validar';
            
		ELSE 
			LET iMultiplo  = 2;
			
			FOR i = 1 TO iLongDV
				LET iNum = SUBSTRING (pReferencia FROM iLongDV FOR 1);
				LET iDigVer = iNum * iMultiplo;
				
				LET iSuma = iSuma + iDigVer;
				LET iLongDV = iLongDV - 1;
				LET iMultiplo = iMultiplo + 1;
				
				IF iMultiplo > 7 THEN 
					LET iMultiplo  = 2;
				END IF;
				
			END FOR;
			
			LET iModulo = MOD(iSuma,11);
			IF iModulo = 10 THEN	    
				LET iModulo = 0;
			END IF;
			
			IF iModulo <> cDigVerRef THEN
				LET cCodRet = '00002';
				LET cDescripcion = 'Digito verificador incorrecto, favor de validar';
			ELSE 
				LET cCodRet = '00000';
				LET cDescripcion = 'Referencia valida';
				
			END IF;
			
		END IF;
		
			
	END IF;
	
	RETURN cCodRet,cDescripcion;
	
END;
	
END PROCEDURE
DOCUMENT
'Folio: 1483',
'Autor: 95347143, Jesus Isaias Bueno',
'Fecha: 15/04/2015',
'DescripciÃ³n: Se crea procedimiento para validar la linea de captura de CFE',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_cons_pagos_msw(pOrigen CHAR(4),pUsuario CHAR(8),pCategoria CHAR(2),pConvenio CHAR(3),pFolio_sucu CHAR(16),pFolio_oper CHAR(18),pSucursal CHAR(4),pCaja CHAR(3),pFecha CHAR(8),pHora CHAR(6))
	RETURNING
	CHAR(5)  AS Codigo,
	CHAR(30) AS Mensaje,
	CHAR(5)  AS Status,
	CHAR(16) AS Folio_sucursal,
	CHAR(10) AS Importe;
	
	DEFINE iSqlErr           INTEGER;
    DEFINE iIsamErr          INTEGER;
    DEFINE cInfoErr          CHAR(100);
	DEFINE cCodRet           CHAR(5);
	DEFINE cMensaje		     CHAR(30);
	DEFINE cFolio_Suc	     CHAR(16);
	DEFINE cImporte		     CHAR(20);
	DEFINE dFecha_Sac	     DATE;
	DEFINE cFechaFormat	     DATE;
	DEFINE iExiste_suc	     INTEGER;
	DEFINE iExiste_ope	     INTEGER;
	DEFINE iExisteHis	     INTEGER;
	DEFINE cStatus_cancelado CHAR(2);
    DEFINE cFolio_oper       INTEGER;
	DEFINE cSucursal_bcpl    CHAR(4);
	
	LET cCodRet           = "00000";
	LET cMensaje          = "Exitoso";
	LET cFolio_Suc	      = '';
	LET cImporte	      = '';
	LET dFecha_Sac	      = '';
	LET cFechaFormat      = '';
	LET iExiste_suc	      = 0;
	LET iExiste_ope	      = 0;
	LET iExisteHis	      = '';
	LET cStatus_cancelado = '';
    LET cFolio_oper       = 0;
	LET cSucursal_bcpl    ='';
	
	--SET DEBUG FILE TO  '/informix/EPG/sp_cons_pagos_msw_epg.out'; 
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "Error:sp_cons_pagos_msw";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_cons_pagos_msw");
                RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
            END IF;
        END EXCEPTION;
		
		    ON EXCEPTION IN (-284)
				LET cCodRet = '00000';
				LET cMensaje = 'Folio operacion duplicado';
				RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
			END EXCEPTION;
		
		SELECT fecha_hoy
		INTO dFecha_Sac
		FROM bdisac:"informix".sac_fechas
		WHERE empresa = "001";
		
		SELECT valor
		INTO cSucursal_bcpl
		FROM bdisac:"informix".sac_param where cod_param = '9997';

        IF pFolio_sucu <> '' AND pFolio_sucu IS NOT NULL THEN
            LET cFolio_oper = 1;
        ELIF pFolio_oper <> '' AND pFolio_oper IS NOT NULL THEN
            LET cFolio_oper = 2;
        ELSE
			LET cCodRet = '00500';
			LET cMensaje = 'Error:No Existe Folio por Consultar';
            RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
        END IF;

		IF pOrigen = "" OR pUsuario = "" OR pCategoria = "" OR pConvenio = "" OR
		   pSucursal = "" OR pCaja = "" OR pFecha = "" OR pHora = "" THEN
			LET cCodRet = '00501';
			LET cMensaje = 'Error:Faltan parametros de entrada';
            RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
		END IF
		
		LET cFechaFormat = MDY(SUBSTR(pFecha,5,2), SUBSTR(pFecha,7,2), SUBSTR(pFecha,1,4));
		
		IF pOrigen = "CPL"  THEN
			IF cFechaFormat = dFecha_Sac THEN
  				--VERIFICA SI EXISTE EL FOLIO OPERACION                  
				
				IF pFolio_sucu <> "" AND pFolio_oper <> "" THEN 
					SELECT COUNT(*)
					  INTO iExiste_suc
					  FROM bdisac:"informix".sac_movimientos
					 WHERE numcategoria = pCategoria AND numconvenio = pConvenio
					   AND folio_suc = pFolio_sucu
					   AND folio_operacion = pFolio_oper
					   AND caja_cpl = pCaja
					   AND id_sucursal  = cSucursal_bcpl
					   AND sucursal_cpl = pSucursal;
			   END IF;
				
	   		   IF pFolio_sucu <> "" AND pFolio_oper = "" THEN  
					SELECT COUNT(*)
					  INTO iExiste_suc
					  FROM bdisac:"informix".sac_movimientos
					 WHERE numcategoria = pCategoria 
                       AND numconvenio = pConvenio
					   AND id_sucursal  = cSucursal_bcpl
                       AND sucursal_cpl = pSucursal
					   AND caja_cpl = pCaja
					   AND folio_suc = pFolio_sucu;
			   END IF;	
				
			   IF pFolio_sucu = "" AND pFolio_oper <> "" THEN  
					SELECT COUNT(*)
					  INTO iExiste_ope
					  FROM bdisac:"informix".sac_movimientos
					 WHERE numcategoria = pCategoria 
                       AND numconvenio = pConvenio
                       AND id_sucursal  = cSucursal_bcpl
                       AND sucursal_cpl = pSucursal
					   AND caja_cpl = pCaja
					   AND folio_operacion = pFolio_oper;
			   END IF;		
 				
				IF iExiste_suc < 1 AND iExiste_ope < 1 THEN
					LET cCodRet = '00000';
					LET cMensaje = 'Exitoso';
					LET cStatus_cancelado = 'NE';
					RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte; 
				END IF;

				IF iExiste_suc = 1 THEN
                    SELECT NVL(folio_suc,''), NVL(importe_pago::CHAR(20),''),  status_cancelado
                    INTO cFolio_Suc, cImporte, cStatus_cancelado
                    FROM bdisac:"informix".sac_movimientos
                    WHERE numcategoria = pCategoria 
                    AND numconvenio = pConvenio
                    AND folio_suc = pFolio_sucu
 				    AND caja_cpl = pCaja
					AND id_sucursal  = cSucursal_bcpl
                    AND sucursal_cpl = pSucursal;
				ELSE
                    SELECT NVL(folio_suc,''), NVL(importe_pago::CHAR(20),''),  status_cancelado
                    INTO cFolio_Suc, cImporte, cStatus_cancelado
                    FROM bdisac:"informix".sac_movimientos
                    WHERE numcategoria = pCategoria 
                    AND numconvenio = pConvenio
                    AND folio_operacion = pFolio_oper
                    AND caja_cpl = pCaja
					AND id_sucursal  = cSucursal_bcpl
                    AND sucursal_cpl = pSucursal;	
                END IF;
			
			ELSE	
				--VERIFICA SI EXISTE EL FOLIO OPERACION HISTORIAL
				
    		   IF pFolio_sucu <> "" AND pFolio_oper <> "" THEN 
					SELECT COUNT(*)
					  INTO iExiste_suc
					  FROM bdisac:"informix".sac_movimientoshistorial
					 WHERE numcategoria = pCategoria AND numconvenio = pConvenio
					   AND folio_suc = pFolio_sucu
                       AND caja_cpl = pCaja
					   AND id_sucursal  = cSucursal_bcpl
                       AND sucursal_cpl = pSucursal
					   AND folio_operacion = pFolio_oper;
			   END IF;
				
	   		   IF pFolio_sucu <> "" AND pFolio_oper = "" THEN  
					SELECT COUNT(*)
					  INTO iExiste_suc
					  FROM bdisac:"informix".sac_movimientoshistorial
					 WHERE numcategoria = pCategoria 
                       AND numconvenio = pConvenio
                       AND caja_cpl = pCaja
					   AND id_sucursal  = cSucursal_bcpl
                       AND sucursal_cpl = pSucursal
					   AND folio_suc = pFolio_sucu;
			   END IF;	
				
			   IF pFolio_sucu = "" AND pFolio_oper <> "" THEN  
					SELECT COUNT(*)
					  INTO iExiste_ope
					  FROM bdisac:"informix".sac_movimientoshistorial
					 WHERE numcategoria = pCategoria 
                       AND numconvenio = pConvenio
					   AND id_sucursal  = cSucursal_bcpl
                       AND sucursal_cpl = pSucursal
					   AND caja_cpl = pCaja
					   AND folio_operacion = pFolio_oper;
			   END IF;		
 				
				IF iExiste_suc < 1 AND iExiste_ope < 1 THEN
					LET cCodRet = '00000';
					LET cMensaje = 'Exitoso';
					LET cStatus_cancelado = 'NE';
					RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte; 
				END IF;

				IF iExiste_suc = 1 THEN
                    SELECT NVL(folio_suc,''), NVL(importe_pago::CHAR(20),''),  status_cancelado
                    INTO cFolio_Suc, cImporte, cStatus_cancelado
                    FROM bdisac:"informix".sac_movimientoshistorial
                    WHERE numcategoria = pCategoria 
                    AND numconvenio = pConvenio
					AND id_sucursal  = cSucursal_bcpl
                    AND sucursal_cpl = pSucursal
  				    AND caja_cpl = pCaja
                    AND folio_suc = pFolio_sucu;
				ELSE
                    SELECT NVL(folio_suc,''), NVL(importe_pago::CHAR(20),''),  status_cancelado
                    INTO cFolio_Suc, cImporte, cStatus_cancelado
                    FROM bdisac:"informix".sac_movimientoshistorial
                    WHERE numcategoria = pCategoria 
                    AND numconvenio = pConvenio
                    AND folio_operacion = pFolio_oper
  				    AND caja_cpl = pCaja
					AND id_sucursal  = cSucursal_bcpl
                    AND sucursal_cpl = pSucursal;					
                END IF;
	        END IF;		

			IF cFolio_Suc = '' OR cFolio_Suc IS NULL OR cImporte = '' OR cImporte IS NULL THEN
				LET cCodRet = '00000'; 
				LET cMensaje = 'exitoso';
				LET cStatus_cancelado = 'NE';
				LET cFolio_Suc = '';
				LET cImporte = '';
				RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
			ELSE
				IF cStatus_cancelado = 'S' THEN
					LET cStatus_cancelado = 'R';
				ELSE
					LET cStatus_cancelado = 'P';
				END IF;	
				RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
			END IF;			
	
		ELSE 
			LET cCodRet = '00505';
			LET cMensaje = 'Origen Desconocido';
            RETURN cCodRet, cMensaje, cStatus_cancelado, cFolio_Suc, cImporte;
		END IF;
		
	END;
	
END PROCEDURE
;