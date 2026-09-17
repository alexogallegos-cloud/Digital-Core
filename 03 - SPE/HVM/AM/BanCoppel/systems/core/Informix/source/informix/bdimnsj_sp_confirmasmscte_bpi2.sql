CREATE PROCEDURE "informix".sp_confirmasmscte_bpi2(pTelCel CHAR(10), pNumCte CHAR(9))
RETURNING 	
		CHAR(4) AS sCod4Digitos, -- CÃÂ³digo verificador de 4 dÃÂ­gitos
		CHAR(6) AS sCod6Digitos; -- CÃÂ³digo verificador de 6 dÃÂ­gitos
		

		
-- MODIFICACION: Se agrega validaciÃÂ³n para que tambiÃÂ©n busque la clave enviada al usuario en la tabla: si_bitsmstelsms_bpi
-- AUTOR : Keevyn Adrian Gil Valenzuela
-- FECHA : 19/12/2016
-- BD    : bdimnsj
				
--DEFINICION DE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cSitEsp 		CHAR(5);
DEFINE cCodRet2		CHAR(6);
DEFINE iExist       INTEGER;
	

--INICIALIZACION DE VARIABLES
LET iSqlErr 	 = 0;
LET cCodRet 	 = "00000";
LET cSitEsp 	 = "00000";
LET cCodRet2	 = "00000";
LET iExist	    =   0;    

--SET DEBUG FILE TO '/tmp/sp_valtel_ctedupout.SQL';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cCodRet2;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(*) INTO iExist FROM bdinteg:"informix".si_bitsmstelsms WHERE numcte=pNumCte AND telefono=pTelCel AND DATE(fecha)=DATE(current) AND bandera='f';
	
	IF (iExist>0) THEN
		foreach
		SELECT LIMIT 1 digito_ver INTO cCodRet
			FROM bdinteg:"informix".si_bitsmstelsms a
			WHERE a.numcte=pNumCte  and a.telefono=pTelCel
			AND DATE(a.fecha)=DATE(current) 
			AND bandera='f'
			ORDER BY a.fecha DESC
		end foreach;
	ELSE
		LET cCodRet='0000';
	END IF;

	SELECT COUNT(*) INTO iExist FROM bdinteg:"informix".si_bitsmstelsms_bpi WHERE numcte=pNumCte AND telefono=pTelCel AND DATE(fecha)=DATE(current) AND bandera='f';
	
	IF (iExist>0) THEN
		foreach
		SELECT LIMIT 1 digito_ver INTO cCodRet2
			FROM bdinteg:"informix".si_bitsmstelsms_bpi a
			WHERE a.numcte=pNumCte  and a.telefono=pTelCel
			AND DATE(a.fecha)=DATE(current) 
			AND bandera='f'
			ORDER BY a.fecha DESC
		end foreach;
	ELSE
		LET cCodRet2='0000';
	END IF;


RETURN cCodRet, cCodRet2; 
END;
END PROCEDURE
