CREATE PROCEDURE  "informix".sp_calculadvdish(pNumReferencia CHAR(14))
RETURNING 
	CHAR (5) AS CodigoRetorno,
	SMALLINT AS IerrcomCodigo,
	SMALLINT AS IerrcomSistema;
	
--DEFINICION DE LAS VARIABLES
DEFINE iSqlErr			 INTEGER;
DEFINE sI 		    	 SMALLINT;
DEFINE iNoPeso      	 INTEGER;
DEFINE iValorDigito 	 INTEGER;  
DEFINE iSuma			 INTEGER;
DEFINE iAux				 INTEGER;
DEFINE cCodRet			 CHAR(5); --SE CAMBIO DE INTEGER A CHAR.
DEFINE cNum1			 CHAR(2);
DEFINE cNum2			 CHAR(2);
DEFINE cNum3			 CHAR(2);
DEFINE cNum4			 CHAR(2);
DEFINE iDigVerCapturado  INTEGER;
DEFINE iDigVerCalculado  INTEGER;
DEFINE sFijo			 SMALLINT;
DEFINE iResiduo			 INTEGER;
DEFINE sIerrcomCodigo	 SMALLINT;
DEFINE sIerrcomSistema	 SMALLINT;
DEFINE iSumaReferencia   INTEGER;
DEFINE referenciaDish 	 CHAR(13);

--INICIALIZACION DE LAS VARIABLES
LET cCodRet        	 = '00004';
LET iSqlErr        	 = 0;
LET sI 		    	 = 0;	
LET iNoPeso      	 = 60;
LET iValorDigito 	 = 0;
LET iSuma			 = 0;
LET iAux			 = 0;	
LET iDigVerCapturado = 0;
LET iDigVerCalculado = 0;
LET sFijo			 = 24;
LET iResiduo		 = 0;
LET sIerrcomCodigo   = 0;
LET sIerrcomSistema  = 0;
LET iSumaReferencia	 = 0;
LET referenciaDish	 = '';


BEGIN

	ON EXCEPTION SET iSqlErr
		   IF (iSqlErr != 0) THEN
			  LET cCodRet = iSqlErr;
			  RETURN cCodRet, sIerrcomCodigo, sIerrcomSistema;
		   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/RESPALDOSNEW/meg/sp_calculadvdish.out';
	--TRACE ON;		
	
	SET ISOLATION TO DIRTY READ;

	IF LENGTH(TRIM(pNumReferencia))= 14 THEN
		
		LET cNum1 = substr(pNumReferencia,11,1);
		LET cNum2 = substr(pNumReferencia,12,1);
		LET cNum3 = substr(pNumReferencia,13,1);
		LET cNum4 = substr(pNumReferencia,14,1);

		LET iSumaReferencia = (cNum1::SMALLINT) + (cNum2::SMALLINT) + (cNum3::SMALLINT) + (cNum4::SMALLINT);

		IF iSumaReferencia = 0 THEN
			LET cCodRet = '00000';
		ELSE
			LET referenciaDish = substr(pNumReferencia,2,14);
			LET sFijo = SUBSTR(referenciaDish, 1, 2)::SMALLINT;		
			--		IF sFijo = 21 THEN
		
			LET iDigVerCapturado = SUBSTR(referenciaDish,13,1)::SMALLINT;
				FOR sI = 1 TO 12 
	
					LET iValorDigito = SUBSTR(referenciaDish,sI,1)::SMALLINT;

					IF MOD(sI,2)= 1 THEN
						LET iNoPeso = 1;
					ELSE
						LET iNoPeso = 2;
					END IF;
				
					LET iAux = iValorDigito * iNoPeso;
					   
					IF iAux > 9 THEN
						--raise notice ''Multiplicacion Mayor a 9 = %'', iAux ;
						LET cNum1 = SUBSTR(iAux::CHAR(2),1,1) ;
						LET cNum2 = SUBSTR(iAux::CHAR(2),2,1) ;
						LET iAux = (cNum1::SMALLINT) + (cNum2::SMALLINT);
					END IF; 
									
					LET iSuma = iSuma + iAux;		
					
				END FOR;
								
				LET iResiduo = MOD(iSuma , 10);

				IF iResiduo > 0 THEN
					
					LET iValorDigito = 10 - iResiduo;
					
					IF iValorDigito =  iDigVerCapturado THEN
						LET cCodRet = '00000';						
					ELSE
						LET cCodRet = '00001';
						LET sIerrcomCodigo = 91;
						LET sIerrcomSistema = 24;
					END IF;
				ELSE
					IF iResiduo =  iDigVerCapturado THEN
						LET cCodRet = '00000';
					ELSE
						LET cCodRet = '00001';
						LET sIerrcomCodigo = 91;
						LET sIerrcomSistema = 24;
					END IF;
				
				END IF;
		END IF;		
	ELSE	
	--ESCENARIO: LONGITUD DE REFERENCIA INCORRECTA.
		LET cCodRet 		= '00002';
		LET sIerrcomCodigo  = 47;
		LET sIerrcomSistema = 24;

	END IF;

	RETURN cCodRet, sIerrcomCodigo, sIerrcomSistema;

END;
END PROCEDURE
DOCUMENT
'-------------------------------------------------------------------------------------------------------------',
'DESCRIPCION: Se convierte una funcion de sucursal a una rutina de central, atendiendo el folio 1483-MttoValRefPagServAVON', 
'(procedimiento en central para validar el digito verificador para pago de servicios Dish)',
'MODIFICO: Antonio Cebreros Perez',
'FECHA: 24/02/2015',
'Cambio para aceptar referencias de 14 digitos',
'MODIFICO: Mario Enriquez',
'FECHA: 19/09/2019',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_tramaconsulta_dish(pNumCategoria CHAR (2), pNumConvenio CHAR (3), pFolioSucursal CHAR (16), pRef1 CHAR (40), pId_Sucursal CHAR (4), pFecha_Pago DATE, pNumTrama INTEGER, pTimeStamp CHAR (10))
RETURNING CHAR (5) AS cCodRet, CHAR (21) AS cTrama;

--Variables
DEFINE cCodRet CHAR(5);
DEFINE cTrama CHAR(21);
DEFINE iSqlErr INTEGER;
DEFINE cTrans_MotorS CHAR(5); -- Trans_Motors
DEFINE cTrans_Suc CHAR(4);
DEFINE cTrans_Central CHAR(5);
DEFINE cTrans_Interact CHAR(5);
DEFINE cTienda CHAR(2);
DEFINE cNum_Sucursal CHAR (4);
DEFINE cReferencia CHAR(14);
DEFINE cUser_Insert CHAR(10);

LET cCodRet		= '00000';
LET iSqlErr		= 0;
LET cTrama		= '';
LET cTrans_MotorS	= '';	
LET cTrans_Suc = '';
LET cTrans_Central = '';
LET cTrans_Interact = '';
LET cTienda = '1';
LET cNum_Sucursal = pId_Sucursal;
LET cReferencia = TRIM(pRef1);
LET cUser_Insert = 'Informix';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/RESPALDOSNEW/meg/sp_tramaconsultadish.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(cTrama, '');
		END IF;
	END EXCEPTION;

	IF NVL(pFecha_Pago, '') = '' OR NVL(pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL(pFolioSucursal, '') = '' OR NVL (pRef1, '') = '' OR NVL(pId_Sucursal, '') = '' OR NVL(pNumTrama, '') = '' THEN
		LET cCodRet = '00002'; --DATOS VACIOS, ERROR.
		RETURN cCodRet, NVL(cTrama, '');
	END IF;
		
	--Obtenemos la codigo del interac requeridos  de bdisac:"informix".sac_intrfz_serv
	SELECT trans_interact, trans_servicio INTO  cTrans_Interact, cTrans_MotorS FROM   bdisac: "informix".sac_intrfz_serv WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND num_trama = pNumTrama;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Interact= '' Or cTrans_MotorS= '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '');
	END IF;
		
		--Obtenemos los parametros de la sac_param para la generacion de la trama
	SELECT TRIM(valor) INTO cTienda FROM  bdisac:"informix".sac_param  where cod_param = 060021;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTienda = ''THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '');
	END IF;				
		
	LET cTienda = RPAD(cTienda,2,' ');

	--Agrupa los datos para la generacion de la trama
	LET cTrama = cTrans_MotorS||cReferencia||cTienda;
	
	SELECT trans_suc_efectivo, trans_cen_efectivo_cliente INTO cTrans_Suc, cTrans_Central FROM   bdisac: "informix".sac_convenios WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Suc= '' Or  cTrans_Central=''THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '0');
	END IF;
	
	INSERT INTO bdisac: "informix".sac_msw_solicitud(
		numcategoria,
		numconvenio, 
		id_sucursal, 
		trans_suc, 
		trans_central, 
		trans_interact, 
		folio_suc, 
		fecha_pago, 
		num_trama, 
		campo1, 
		campo2, 
		campo3, 
		campo4,
		campo5,campo6,campo7,campo8,campo9,campo10,campo11,campo12,campo13,campo14,
		campo15,campo16,campo17,campo18,campo19,campo20,campo21,campo22,campo23,campo24,
		campo25,campo26,campo27,campo28,campo29,campo30,campo31,campo32,campo33,campo34,
		campo35,campo36,campo37,campo38,campo39,campo40,
		user_insert,
		fecha_insert) 
		VALUES (
		pNumCategoria, 
		pNumConvenio, 
		pId_Sucursal, 
		cTrans_Suc, 
		cTrans_Central, 
		cTrans_Interact, 
		pFolioSucursal, 
		pFecha_Pago,
		pNumTrama,
		cTrans_MotorS,
		cNum_Sucursal,
		cReferencia,
		cTienda,
		pTimeStamp,
		'','','','','','','','','','','',
		'','','','', '', '', '', '', '',
		'', '', '', '', '', '', '', '', '',
		'', '', '', '', '', '',
		cUser_Insert,
		current);		
	  
	RETURN cCodRet, NVL(cTrama, '');
END;
END PROCEDURE
DOCUMENT
'AUTOR : 90020599 - Mario Enriquez Gallegos',
'DESCRIPCION: SPL que recupera datos (Dish) para generar la trama de consulta y enviar a Interact.',
'FECHA : 02-10-2019',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_valida_respuesta_ws_dish(pNumCategoria CHAR   (2),  pNumConvenio CHAR (3), pId_Sucursal CHAR (4), 
		pFolioSucursal CHAR (16),  pFecha_Pago  DATE,     pNumTrama    INTEGER)
RETURNING CHAR(5) as cCodRet, CHAR(40) as cCodigoRespuesta;
      
-- Declaracion de variables 
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodigoRespuesta CHAR(40);
	DEFINE vCampoTres CHAR(40);	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodigoRespuesta	= '';
	LET vCampoTres = '';
					
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigoRespuesta;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/meg/sp_valida_respuesta_ws_dish.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF  NVL(pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL(pId_Sucursal, '') = '' OR NVL(pFolioSucursal, '') = '' OR NVL(pFecha_Pago, '') = '' OR NVL(pNumTrama, '') = '' THEN
		LET cCodRet = '00002'; 
		RETURN cCodRet, NVL(cCodigoRespuesta, '');
	END IF;

	SELECT TRIM(campo3) INTO vCampoTres FROM bdisac: "informix".sac_msw_respuesta
	WHERE numcategoria= pNumCategoria AND numconvenio = pNumConvenio AND folio_suc = pFolioSucursal AND num_trama = pNumTrama;
		  
    SELECT codigoRetorno INTO cCodigoRespuesta FROM bdisac: "informix".sac_dish_cat_respuestaws where codigoRespuesta = vCampoTres AND trama = pNumTrama;
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
	ELSE 
		LET cCodRet = '00000';
	END IF;
	
	RETURN cCodRet, NVL(cCodigoRespuesta, '');
		
END;
END PROCEDURE
DOCUMENT
'AUTOR : 90020599 - Mario Enriquez Gallegos',
'DESCRIPCION: SP regresa el concepto de el codigo de respuesta a consultar de bdisac: sac_dish_cat_respuestaws',
'FECHA : 08-10-2019',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_pagos_activos_msw(pOrigen CHAR(4))
	RETURNING
	CHAR(5)	 AS codigo,	
	CHAR(30) AS mensaje,	
	CHAR(2)	 AS categoria,	
	CHAR(3)	 AS convenio,	
	CHAR(20) AS descripcion,	
	CHAR(8)	 AS fecha;

	DEFINE iSqlErr       INTEGER;
    DEFINE iIsamErr      INTEGER;
    DEFINE cInfoErr      CHAR(100);
	DEFINE cCodRet       CHAR(5);
	DEFINE cMensaje		 CHAR(30);
	DEFINE cCategoria	 CHAR(2);
	DEFINE cConvenio	 CHAR(3);
	DEFINE cDescripcion	 CHAR(20);
	DEFINE dFecha		 DATE;
	DEFINE cFechaFormat	 CHAR(8);
	DEFINE cMensaje1     CHAR(20);
	
	--SET DEBUG FILE TO  '/informix/EPG/sp_pagos_activos_msw_epg.out';
	--TRACE ON;

	LET cCodRet      = "00000";
	LET cMensaje     = "Exitoso";
	LET cCategoria   = '';
	LET cConvenio    = '';
	LET cDescripcion = '';
	LET dFecha       = '';
	LET cFechaFormat = '';
	LET cMensaje1 = '';
	
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "Error";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_pagos_activos_msw_epg");
                RETURN cCodRet, cMensaje,  cCategoria,  cConvenio,  cDescripcion, cFechaFormat;
            END IF;
        END EXCEPTION;
		
		LET cMensaje1 = pOrigen;
		
		IF pOrigen = "" THEN
            LET cCodRet = "00100";
			LET cMensaje = "Error";
            RETURN cCodRet, cMensaje,  cCategoria,  cConvenio,  cDescripcion, '';
		END IF;

		IF pOrigen = 'CPL' OR pOrigen = 'cpl' THEN
			FOREACH
				SELECT a.numcategoria, a.numconvenio, TRIM(SUBSTR(b.nomconvenio,1,20)), b.fechaactualizacion
				INTO cCategoria, cConvenio, cDescripcion, dFecha
				FROM bdisac:"informix".sac_servicios_cpl a, bdisac:"informix".sac_convenios b, bdisac:sac_controlconvenios C
				WHERE (a.numcategoria = b.numcategoria AND a.numconvenio = b.numconvenio)--nmr
                  and (a.numcategoria = c.numcategoria AND a.numconvenio = c.numconvenio)--nmr
                  AND c.status_cpl = 'A'--nmr
				ORDER BY a.numcategoria, a.numconvenio
				
				LET cFechaFormat = YEAR(dFecha) || LPAD(MONTH(dFecha),2,0) || LPAD(DAY(dFecha),2,0) ;
				
				RETURN cCodRet, cMensaje, cCategoria, cConvenio, cDescripcion, cFechaFormat
				WITH RESUME;
			END FOREACH;

            ELIF pOrigen = 'BCPL' OR pOrigen = 'bcpl' THEN
                FOREACH
                    SELECT a.numcategoria, a.numconvenio, TRIM(SUBSTR(b.nomconvenio,1,20)), b.fechaactualizacion
                    INTO cCategoria, cConvenio, cDescripcion, dFecha
                    FROM bdisac:"informix".sac_controlconvenios a, bdisac:"informix".sac_convenios b
                    WHERE a.estatus = 'A'
                    AND a.numcategoria = b.numcategoria
                    AND a.numconvenio = b.numconvenio
                    AND a.status_cpl = 'A'

                    ORDER BY a.numcategoria, a.numconvenio

                    LET cFechaFormat = YEAR(dFecha) || LPAD(MONTH(dFecha),2,0) || LPAD(DAY(dFecha),2,0) ;

                    RETURN cCodRet, cMensaje, cCategoria, cConvenio, cDescripcion, cFechaFormat
                    WITH RESUME;
                END FOREACH;
			ELSE
                LET cCodRet = "00101";
                LET cMensaje = "Origen desconocido";
                RETURN cCodRet, cMensaje,  cCategoria,  cConvenio,  cDescripcion, '';
		END IF;	
		
	END;
END PROCEDURE;