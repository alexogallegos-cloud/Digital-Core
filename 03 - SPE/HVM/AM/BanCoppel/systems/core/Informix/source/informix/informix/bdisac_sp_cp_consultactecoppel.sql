CREATE PROCEDURE "informix".sp_cp_consultactecoppel(pFolioSuc VARCHAR(16))
RETURNING CHAR(5) AS CodigoRetorno,
		  CHAR(40) AS CteCoppel,
		  CHAR(40) AS Recibo,
		  CHAR(4) AS Sucursal,
		  CHAR(3) AS Ciudad,
		  INTEGER AS Importe,
		  INTEGER AS Caja,
		  CHAR(1) AS TpoMov,
		  CHAR(2) AS NumCategoria,
		  CHAR(5) AS NumConvenio,
		  CHAR(4) AS Transaccion,
		  SMALLINT AS FlgConfCentral,
		  SMALLINT AS FlgConfSuc,
		  INTEGER AS Factura; 

	-- DEFINICION DE LAS VARIABLES
	DEFINE cCodRet      	CHAR(5); 
	DEFINE iSqlErr      	INTEGER; 
	DEFINE iIsamErr    		INTEGER; 
	DEFINE cInfoErr     	CHAR(10); 
	
	DEFINE cSucursal 		CHAR(4);
	DEFINE cCiudad 			CHAR(3);
	DEFINE cCteCoppel		CHAR(40);
	DEFINE cReciboPago		CHAR(40);
	DEFINE cNumCategoria 	CHAR(2);
	DEFINE cNumConvenio		CHAR(5);
	DEFINE cTransaccSuc		CHAR(4);
	DEFINE iImporte			INTEGER;
	DEFINE sCaja			INTEGER;
	DEFINE cTpoMov			CHAR(1);
	DEFINE sFlgConfCentral	SMALLINT;
	DEFINE sFlgConfSuc		SMALLINT;
	DEFINE iFactura			INTEGER;
	
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
	
	-- INICIALIZACION DE LAS VARIABLES
	LET cCodRet    		= '00000';
	LET iSqlErr    		= 0;
	LET iIsamErr    	= 0;
	LET cInfoErr    	= '';
	
	LET cSucursal		= '';  
	LET cCiudad			= '';  
	LET cCteCoppel		= '';  
	LET cReciboPago		= '';  
	LET cNumCategoria	= '';  
	LET cNumConvenio	= '';  
	LET cTransaccSuc	= '';  
	LET iImporte		= 0;
	LET sCaja			= 0;
	LET cTpoMov			= '';
	LET sFlgConfCentral	= 0;
	LET sFlgConfSuc		= 0;
	LET iFactura		= 0;
	
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
	
	
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			
			RETURN cCodRet, cCteCoppel, cReciboPago, cSucursal, cCiudad, iImporte, sCaja, cTpoMov, cNumCategoria, cNumConvenio, cTransaccSuc, sFlgConfCentral, sFlgConfSuc, iFactura;
		END IF;
	END EXCEPTION;
	
	-- SET DEBUG FILE TO '/home/sysifx/vlv/sp_cp_consultactecoppel.out';
	-- TRACE ON;	
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- VALIDACIÓN DEL PARAMETRO DE ENTRADA.
	IF TRIM(NVL(pFolioSuc, "")) = "" THEN
		LET cCodRet = "00001";
	ELSE
		-- CONSULTAMOS EL DETALLE DEL PAGO DE SERVICIOS.
		SELECT sac.referencia1, sac.referencia2, sac.id_sucursal, sac.numcategoria, sac.numconvenio, sac.transacc_suc, sac.flag_confirmacion_central, sac.flag_confirmacion_sucursal
		INTO cCteCoppel, cReciboPago, cSucursal, cNumCategoria, cNumConvenio, cTransaccSuc, sFlgConfCentral, sFlgConfSuc
		FROM "informix".sac_movimientos sac		
		WHERE sac.folio_suc = pFolioSuc; 	
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = "00002"; -- NO EXISTEN MOVIMIENTOS EN LA SAC_MOVIMIENTOS.
		ELSE
			SELECT importe, caja, tipomovimiento, folio
			INTO iImporte, sCaja, cTpoMov, iFactura
			FROM "c92357113".sac_movimientosdetalle
			WHERE recibo::CHAR(40) = cReciboPago
			AND fechamovto = (SELECT MAX(fechamovto) FROM "c92357113".sac_movimientosdetalle WHERE recibo::CHAR(40) = cReciboPago);
		END IF
		
		execute procedure bdisac:"informix".sp_sac_consucursales(cSucursal) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,cCiudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;		
		
	END IF
	
	RETURN cCodRet, NVL(cCteCoppel, ""), NVL(cReciboPago, ""), NVL(cSucursal, ""), NVL(cCiudad, ""), NVL(iImporte, 0), NVL(sCaja, 0), NVL(cTpoMov, ""), NVL(cNumCategoria, ""), NVL(cNumConvenio, ""), NVL(cTransaccSuc, ""), NVL(sFlgConfCentral, 0), NVL(sFlgConfSuc, 0), NVL(iFactura, 0);
END;
END PROCEDURE;