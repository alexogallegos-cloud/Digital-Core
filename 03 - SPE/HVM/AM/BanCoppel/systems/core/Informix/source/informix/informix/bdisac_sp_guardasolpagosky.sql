CREATE PROCEDURE "informix".sp_guardasolpagosky
(
			pEnteId char (3), pNumCuenta char(12), pImporteTransaccion char(12), pFechaHoraTrans datetime year to second, pFechaDepoBanco char(10), pCaja char(4), pTienda char(6), 
			pOperador char(4), pPlaza char(30), pMoneda char(3), pPaisId char(2), pNombre char(100), pFolioSuc char(16), pUsuario char(8)
	
)
	--RETORNOS
	RETURNING
	CHAR(5)  AS cCodigoRet;
	
				
			
				
	--Definicion de Variables
	
	DEFINE cCodigoRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	--DEFINE dFechaHoraTrans date;
	DEFINE dFechaDepositoBanco date;
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET iSqlErr = 0;
	--LET dFechaHoraTrans = '';
	
	--SET DEBUG FILE TO '/home/sysifx/Geovani'; 
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN  TRIM( NVL(cCodigoRet,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
			
	
					
					
		IF NVL(pEnteId, '') = '' OR NVL(pNumCuenta, '') = '' OR NVL(pImporteTransaccion, '') = '' OR NVL(pFechaHoraTrans, '') = '' OR NVL(pFechaDepoBanco, '') = '' 
		OR NVL(pCaja, '') = '' OR NVL(pTienda, '') = '' OR NVL(pOperador, '') = '' OR NVL(pPlaza, '') = '' OR NVL(pFolioSuc, '') = '' OR NVL(pMoneda, '') = '' 
		OR NVL(pPaisId, '') = '' OR NVL(pNombre, '') = '' OR NVL(pFolioSuc, '') = '' OR NVL(pUsuario, '') = '' THEN
			 LET cCodigoRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodigoRet;
			 
		ELSE
		
		--LET dFechaHoraTrans = TO_DATE(pFechaHoraTrans,  "%Y-%m-%d %H:%M ");
		LET dFechaDepositoBanco = TO_DATE(pFechaDepoBanco,  "%Y-%m-%d ");
		
				insert into  "informix".sac_sky_wsgpago 
				(	txn_status,	ente_id,	numcuenta, importetrans, fechahoratrans, fechadepbanco, caja, tienda,
					operador, 	plaza, 	folio_pago, 	moneda,	pais_id,	nombre,	uso_futuro1,uso_futuro2,uso_futuro3,folio_suc, usuario_insert ,	fecha_insert)
				values ('C', pEnteId,	pNumCuenta,	pImporteTransaccion, pFechaHoraTrans, dFechaDepositoBanco,	pCaja,	pTienda,	pOperador,	pPlaza,substr(pFolioSuc,7,10),	pMoneda
				, pPaisId,	pNombre,'','','', pFolioSuc, pUsuario,	today );
				
				IF dbinfo('sqlca.sqlerrd2') = 0 THEN
					LET cCodigoRet = '00003';
				END IF;
							
		END IF;		
					
		RETURN  TRIM( NVL(cCodigoRet,""));
		
	END;
END PROCEDURE;