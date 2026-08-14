CREATE PROCEDURE "informix".sp_buscasdosretenido(pEmpresa CHAR(3),pCuenta CHAR(20))
	RETURNING  
		CHAR(6) 	AS COD_RET,
		DATE        AS FECHA_COMPRA,
		CHAR(16)    AS FOLIO_OPERACION,
		MONEY(17,2) AS IMPORTE,
		CHAR(40)    AS REFERENCIA,
		CHAR(12)	AS DIAS_RESTANTES;

	--DECLARACION DE VARIABLES.
	DEFINE cCodRet 			CHAR(6);
	DEFINE iSqlErr 			INTEGER;
	DEFINE iNRows 			INTEGER;
	DEFINE cEmpresa 		CHAR(3);
	DEFINE cCuenta 			CHAR(20);
	DEFINE dFechaActual		DATE;
	DEFINE dFechaCompra		DATE;
	DEFINE cFolioOperacion	CHAR(16);
	DEFINE mImporte			MONEY(17,2);
	DEFINE cReferencia		CHAR(40);
	DEFINE cDiasRest		CHAR(12);
			
	--INICIALIZACION DE VARIABLES.
	LET cCodRet 			= '00000';
	LET iSqlErr          	= 0;
	LET iNRows          	= 0;	
	LET cEmpresa          	= '';	
	LET cCuenta          	= '';	
	LET dFechaActual      	= '';	
	LET dFechaCompra      	= '01-01-1900';
	LET cFolioOperacion     = '';
	LET mImporte      		= 0.00;
	LET cReferencia    		= '';
	LET cDiasRest    		= '';
		
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;				
				RETURN TRIM(cCodRet),NVL(dFechaCompra,''),NVL(TRIM(cFolioOperacion),''),NVL(mImporte,0.00),NVL(TRIM(cReferencia),''),NVL(cDiasRest,'');
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/sysifx/SPsPAYAN/sp_buscasdosretenido.out";
		--TRACE ON;	
		
		SET LOCK MODE TO WAIT 3;		
		SET ISOLATION TO DIRTY READ;		
		
		IF NVL(pEmpresa,'') = '' OR NVL(pCuenta, '') = '' THEN
		    LET cCodRet = '000001';			RETURN TRIM(cCodRet),NVL(dFechaCompra,''),NVL(TRIM(cFolioOperacion),''),NVL(mImporte,0.00),NVL(TRIM(cReferencia),''),NVL(cDiasRest,'');
		END IF;
		
		--SE CONSULTA LA EMPRESA.
		SELECT empresa
		INTO cEmpresa 
		FROM bdinteg:'informix'.si_empresas
		WHERE empresa = pEmpresa;
		
		--SE VALIDA QUE EXISTA LA EMPRESA.
		IF cEmpresa = '' OR cEmpresa IS NULL THEN			
			LET cCodRet = '000002'; --LA EMPRESA NO EXISTE EN EL CATALOGO.
			RETURN TRIM(cCodRet),NVL(dFechaCompra,''),NVL(TRIM(cFolioOperacion),''),NVL(mImporte,0.00),NVL(TRIM(cReferencia),''),NVL(cDiasRest,'');
		END IF 
		
		--SE CONSULTA LA CUENTA.
		FOREACH
		SELECT cuenta
		INTO cCuenta
		FROM bdicheq:"informix".sc_maechq
		WHERE empresa = pEmpresa
		AND cuenta = pCuenta
		UNION
		SELECT cuenta_tf
		FROM bditransfer:"informix".tf_maecte
		WHERE cuenta_tf = pCuenta
		END FOREACH;
		
		--SE VALIDA QUE EXISTA LA CUENTA.
		IF cCuenta = '' OR cCuenta IS NULL THEN			
			LET cCodRet = '000003'; --LA CUENTA NO EXISTE.
			RETURN TRIM(cCodRet),NVL(dFechaCompra,''),NVL(TRIM(cFolioOperacion),''),NVL(mImporte,0.00),NVL(TRIM(cReferencia),''),NVL(cDiasRest,'');
		END IF 
		
		-- // OBTIENE LAS FECHAS DEL SISTEMA
		SELECT fecha_hoy
		INTO dFechaActual
		FROM bdicheq:'informix'.sc_fechas
		WHERE empresa = pEmpresa;
		
						
		FOREACH 
			--OBTENGO LA INFORMACION DE LOS SALDOS RETENIDOS PARA LA CUENTA ESPECIFICADA.
			SELECT fecha_alta,folio_suc,monto,referencia,(dias_ret-(dFechaActual - fecha_alta))			
			INTO dFechaCompra,cFolioOperacion,mImporte,cReferencia,cDiasRest
			FROM bdicheq:'informix'.sc_docret
			WHERE cuenta = pCuenta
			AND (transacc = '0801' OR transacc = '0881' or transacc = '0805')
			AND cancelado = 'P'
			ORDER BY fecha_alta ASC 
					
			--SE RETORNA CADA REGISTRO.
			RETURN TRIM(cCodRet),NVL(dFechaCompra,''),NVL(TRIM(cFolioOperacion),''),NVL(mImporte,0.00),NVL(TRIM(cReferencia),''),NVL(cDiasRest,'') WITH RESUME;			
		END FOREACH;

		
		--SE VALIDA QUE REGRESE INFORMACION EL PROCEDIMIENTO.						
		LET iNRows = dbinfo("sqlca.sqlerrd2");				
		IF iNRows = 0 THEN
			LET cCodRet = "000004";			RETURN TRIM(cCodRet),NVL(dFechaCompra,''),NVL(TRIM(cFolioOperacion),''),NVL(mImporte,0.00),NVL(TRIM(cReferencia),''),NVL(cDiasRest,'');
		END IF;	
			
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene la información de los saldos retenidos de la cuenta recibida', 
'AUTOR: Guadalupe Payan',
'FECHA DE CREACION: 15 de Diciembre del 2011',
'VERSION: 20111215.0858',
'BD: bdicheq',
'',
'DESCRIPCION: Se incluye en la recuperación los saldos retenidos del cash Back', 
'AUTOR: Ricardo Reséndiz Martinez',
'FECHA DE CREACION: 25 de Septiembre del 2013',
'VERSION: 20130925.1116',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_transfer_online_serial( pCuenta     CHAR(20),
                                                       pFolioSuc   CHAR(16),
                                                       pIdTransacc CHAR(5) ) 
RETURNING CHAR(5), INTEGER; 
    
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vSqlErr      INTEGER; 
    DEFINE vIsamErr     INTEGER;
    DEFINE vDescErr     CHAR(50);
    DEFINE iSerial      INTEGER;
    
    LET vCodRet1 = '';
    LET vCodRet2 = '';
    LET vCodRet3 = '';
    LET vSqlErr  = 0;
    LET vIsamErr = 0;
    LET vDescErr = '';
    LET iSerial  = 0;
    
    --- SET DEBUG FILE TO "/ids10_2uc5/jivan/spei/sp_transfer_online_serial.out";
    --- TRACE ON;
    
    BEGIN  
    
    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_online_serial.err";
        TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            RETURN vCodRet1, iSerial; 
        END IF;
    END EXCEPTION;   
    
    SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 3; 
    
    SELECT MAX(no_serial)
      INTO iSerial
      FROM sc_transfer_serial;
      
    IF iSerial is null THEN
        LET iSerial = 0;
    END IF;
    
    LET iSerial = iSerial + 1;
    
    INSERT INTO sc_transfer_serial
    ( no_serial, cuenta, folio_suc, id_transacc )
    VALUES
    ( iSerial, pCuenta, pFolioSuc, pIdTransacc );
    
    IF dbinfo('sqlca.sqlerrd2') > 0  THEN
        LET iSerial  = iSerial;
        LET vCodRet1 = '000';
    ELSE
        LET iSerial  = 0;
        LET vCodRet1 = '999';
    END IF;
    
    END;
    
    RETURN vCodRet1, iSerial;
    
END PROCEDURE;