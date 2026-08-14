CREATE PROCEDURE "informix".sp_notif_cub_vent_upd(
	pSucursal VARCHAR(4),pTransacc VARCHAR(4),
	pTransacc_suc VARCHAR(4),pCuenta VARCHAR(20),
	pMonto_tot	MONEY,pFolio_suc VARCHAR(16),pParam_up INTEGER,
	pOp1 VARCHAR(50), pOp2 VARCHAR(50), pOp3 VARCHAR(50))
	
	RETURNING CHAR(5) AS iCodRet,
		char(50) as iMensaje,
		VARCHAR(50) AS cOp1,
		VARCHAR(50) AS cOp2,
		VARCHAR(50) AS cOp3;
	
	
	
	DEFINE iCodRet 			CHAR(5);
	DEFINE iMensaje			CHAR(50);
	DEFINE iSqlErr 			INTEGER;
	DEFINE iIsamErr 		INTEGER;
	DEFINE iInfoErr         CHAR(100);
	
	DEFINE cSucursal	   VARCHAR(4);
	DEFINE cTransacc       VARCHAR(4);
	DEFINE cTransacc_suc   VARCHAR(4);
    DEFINE cCuenta         VARCHAR(20);
	DEFINE cMonto_tot	   MONEY;
	DEFINE cFolio_suc      VARCHAR(16);
	DEFINE cParam_up	   INTEGER;
	DEFINE vtransaccion	   SMALLINT;

	
	DEFINE cOp1			   VARCHAR(50);
	DEFINE cOp2			   VARCHAR(50);
	DEFINE cOp3			   VARCHAR(50);
	
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_notif_cub_vent_upd.out';
	--TRACE ON; 

	
	LET iCodRet = "00000";
	LET iMensaje = "";
	LET iInfoErr = "";
	LET iSqlErr = 0;
	LET iIsamErr = 0;
	LET vtransaccion = 0;
	
	LET cSucursal = '';
	LET cTransacc = '';
	LET cTransacc_suc = '';
	LET cCuenta = '';
	LET cMonto_tot = 0;
	LET cFolio_suc = '';
	LET cParam_up = 0;

	
	LET cOp1 ='';
	LET cOp2 ='';
	LET cOp3 ='';
	 

	
	BEGIN
		
		
		ON EXCEPTION SET iSqlErr,iIsamErr,iInfoErr
			IF (iSqlErr != 0) THEN
				LET iCodRet = iSqlErr;
				LET iMensaje = "Error BD";
				LET cOp1 = iIsamErr;
				LET cOp2 = iInfoErr;
				RETURN iCodRet,iMensaje,cOp1,cOp2,cOp3;
			END IF;
		END EXCEPTION;
		
		
			--Manejo de transacciones
		ON EXCEPTION IN (-535,-243,-244)
			LET vtransaccion = 1;
			--LET iSqlErr = 0;
			LET cParam_up = 9;
		END EXCEPTION WITH RESUME;
		
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;
		
		
		SET LOCK MODE TO WAIT 5;
		SET ISOLATION TO DIRTY READ;
		
		LET cSucursal = NVL(pSucursal,'');
		LET cTransacc = NVL(pTransacc,'');
		LET cTransacc_suc = NVL(pTransacc_suc,'');
		LET cCuenta = NVL(pCuenta,'');
		LET cMonto_tot = NVL(pMonto_tot,0);
		LET cFolio_suc = NVL(pFolio_suc,'');
		LET cParam_up = NVL(pParam_up,0);
	
		
		IF cSucursal = '' OR cTransacc = '' OR cTransacc_suc = '' OR cCuenta = '' OR cMonto_tot = 0 OR cFolio_suc = '' OR cParam_up = 0 THEN
			
			LET iMensaje = 'Parametros de Entrada Invalidos';	
			LET iCodRet = '00001';
	
		END IF;
		
		
		
		IF iCodRet = '00000' THEN 
		
			UPDATE sc_notif_cub_vent SET estatus = cParam_up
			WHERE folio_suc = cFolio_suc AND cuenta = cCuenta
			AND sucursal = cSucursal AND transacc = cTransacc AND transacc_suc = cTransacc_suc AND monto_tot = cMonto_tot;
				
			LET iMensaje = 'Actualizacion Exitosa';	
			LET iCodRet = '00000';
			
		ELIF iCodRet = '00001' THEN
			
			UPDATE sc_notif_cub_vent SET estatus = cParam_up
			WHERE folio_suc = cFolio_suc AND sucursal = cSucursal AND transacc = cTransacc AND transacc_suc = cTransacc_suc AND monto_tot = cMonto_tot;
				
			LET iMensaje = 'Actualizacion 2 Exitosa';	
			LET iCodRet = '00000';
		ELSE
			LET iMensaje = 'Parametros de Entrada Invalidos';	
			LET iCodRet = '00002';
		END IF;
		
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;
		
		RETURN iCodRet,iMensaje,cOp1,cOp2,cOp3;
			
	END;

END PROCEDURE;