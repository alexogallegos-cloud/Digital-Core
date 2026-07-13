CREATE PROCEDURE "informix".sp_tramapago_dish(pNumCategoria CHAR (2), pNumConvenio CHAR (3), pFolioSucursal CHAR (16), pRef1 CHAR (40), pId_Sucursal CHAR (4), pFecha_Pago DATE, pNumTrama INTEGER,pTimeStamp CHAR (10))
RETURNING CHAR (5) AS cCodRet, CHAR (35) AS cTrama;

--Variables
DEFINE cCodRet CHAR(5);
DEFINE cTrama CHAR(35);
DEFINE iSqlErr INTEGER;
DEFINE cTrans_MotorS CHAR(5); -- Trans_Motors
DEFINE cTrans_Suc CHAR(4);
DEFINE cTrans_Central CHAR(5);
DEFINE cTrans_Interact CHAR(5);
DEFINE cNum_Sucursal CHAR (4);
DEFINE cReferencia CHAR(14);
DEFINE cUser_Insert CHAR(10);
DEFINE cFolioConsultaDish CHAR(10);
DEFINE cImportePago CHAR(10);
DEFINE cClienteDish CHAR(10);

LET cCodRet		= '00000';
LET iSqlErr		= 0;
LET cTrama		= '';
LET cTrans_MotorS	= '';	
LET cTrans_Suc = '';
LET cTrans_Central = '';
LET cTrans_Interact = '';
LET cClienteDish = '';
LET cFolioConsultaDish = '';
LET cImportePago = '';
LET cNum_Sucursal = pId_Sucursal;
LET cReferencia = TRIM(pRef1);
LET cUser_Insert = 'Informix';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/RESPALDOSNEW/meg/sp_tramapagodish.out';
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
		
	--Obtenemos los parametros de la sac_msw_respuesta para la generacion de la trama
	SELECT campo2, campo7 INTO cClienteDish, cFolioConsultaDish FROM  bdisac:"informix".sac_msw_respuesta  WHERE numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND folio_suc = pFolioSucursal AND num_trama = 1;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cClienteDish = '' OR cFolioConsultaDish = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '');
	END IF;				
		
	--Obtenemos el monto a pagar
	SELECT REPLACE(importe_pago,'$', '') INTO cImportePago FROM bdisac:"informix".sac_movimientos WHERE numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND folio_suc = pFolioSucursal;

	--Agrupa los datos para la generacion de la trama
	LET cTrama = cTrans_MotorS||cFolioConsultaDish||cImportePago||cClienteDish;
	
	SELECT trans_suc_efectivo, trans_cen_efectivo_cliente INTO cTrans_Suc, cTrans_Central FROM   bdisac: "informix".sac_convenios WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Suc= '' Or  cTrans_Central=''THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '0');
	END IF;
	
/*	
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
		cClienteDish,
		cImportePago,
		cFolioConsultaDish,
		pTimeStamp,
		'','','','','','','','','',
		'','','','', '', '', '', '', '',
		'', '', '', '', '', '', '', '', '',
		'', '', '', '', '', '',
		cUser_Insert,
		current);		*/
	  
	RETURN cCodRet, NVL(cTrama, '');
END;
END PROCEDURE
;