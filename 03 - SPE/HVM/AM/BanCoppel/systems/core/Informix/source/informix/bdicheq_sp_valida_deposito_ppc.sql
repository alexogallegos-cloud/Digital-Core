CREATE PROCEDURE "informix".sp_valida_deposito_ppc(pnumcte CHAR(20), pfolioPres CHAR(20), pTarjeta CHAR(4))
       RETURNING CHAR(5) AS cCodRet, MONEY AS rMonto;

	  
	   
DEFINE cCodRet			CHAR(5); 
DEFINE rMonto			MONEY;
DEFINE iSqlErr          INTEGER; 
DEFINE iMonto           MONEY;
DEFINE cCuenta			CHAR(20);
DEFINE cFoliosuc        CHAR(16);

LET cCodRet = "00000";
LET rMonto = 0;
LET iSqlErr = 0;
LET iMonto = 0;
LET cCuenta = "";
LET cFoliosuc = "";

BEGIN

   ON EXCEPTION SET iSqlErr
        LET cCodRet=iSqlErr;
        RETURN cCodRet, rMonto;
    
    END EXCEPTION;
	
	IF pnumcte ='' THEN
	  LET cCodRet='00001'; -- Parametro de entrada vacio
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT 
		monto_autorizado
		
	INTO 
		iMonto
		
	FROM 
		bdisolic:ss_prestamoscoppel 
	WHERE 
		numcte = pnumcte 
		AND folio_prestamo = pfolioPres 
		AND status_solicitud='P';
	 
	IF iMonto > 0 or iMonto is not null THEN
			SELECT 
				cuenta 
			INTO  
				cCuenta 
			FROM 
				BDICHEQ:sc_tarjeta 
			WHERE 
				numcte = pnumcte 
				AND substr(num_tarjeta,13,4) = pTarjeta 
				AND status_tar = 'A';
	  
		IF cCuenta is not null or cCuenta <> '' THEN
				SELECT 
					FIRST 1 folio_suc 
				INTO 
					cFoliosuc
				FROM 
					bdicheq:sc_movdia 
				WHERE 
					sucursal = '5006' 
					AND cuenta = cCuenta 
					AND monto_tot = iMonto;

	  	END IF
		
		IF NVL(cFoliosuc,'') = '' THEN
			LET cCodRet='00003'; -- NO se encontro el deposito			  
            RETURN cCodRet, rMonto;
			
		ELSE			    
 		    
			LET cCodRet='00000'; -- Si se encontro el deposito
			LET rMonto = iMonto;

        END IF
	ELSE
	 LET cCodRet ='00002'; -- No existe el registro
	END IF;
	RETURN cCodRet, rMonto;
END;
END PROCEDURE
;