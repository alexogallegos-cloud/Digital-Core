CREATE PROCEDURE "informix".sp_administrabeneficiarios_web(pEmpresa CHAR(3),pNumeroCuenta CHAR(20),pNumCte CHAR(20),pNombre CHAR(40), pPorcentaje CHAR(6), 
	pParentesco CHAR(20), pTipOper SMALLINT)

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5);  	-- Codigo de Retorno

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr      INTEGER;
	DEFINE cCodRet		CHAR(5);
	DEFINE vSecuencia	SMALLINT;
	DEFINE vContador    INTEGER;

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr		= 0;
	LET cCodRet 	= "00000";
	LET vSecuencia	= 0;
	LET vContador	= 0;

   --SET DEBUG FILE TO "/tmp/sp_administrabeneficiarios.out";
   --TRACE ON;

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF  pEmpresa IS NULL OR TRIM(pEmpresa) = '' OR pNumeroCuenta IS NULL OR TRIM(pNumeroCuenta) = '' OR pNumCte IS NULL OR TRIM(pNumCte) = '' OR
	    pTipOper IS NULL OR pTipOper NOT IN(1,2,3) THEN
			LET cCodRet = '00086';
			RETURN cCodRet;
	END IF;	
	
	IF pTipOper = 1 THEN
		IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
			LET cCodRet = '00087';
			RETURN cCodRet;
		END IF;
	END IF;
	
	IF pTipOper = 1 OR pTipOper = 2 THEN
		IF pPorcentaje IS NULL OR TRIM(pPorcentaje) = '' OR pParentesco IS NULL OR TRIM(pParentesco) = ''  THEN
			LET cCodRet = '00088';
			RETURN cCodRet;
		END IF;
	END IF;	
	
	LET vContador = (SELECT count(1) FROM bdinvers:"informix".sv_benefic WHERE empresa = pEmpresa AND cuenta = pNumeroCuenta AND numcte = pNumCte);

	IF (vContador > 0 ) THEN
		IF pTipOper = 1 OR pTipOper = 2 THEN		
			UPDATE bdinvers:"informix".sv_benefic SET parentesco = pParentesco, porcentaje = pPorcentaje WHERE empresa = pEmpresa AND cuenta = pNumeroCuenta AND numcte = pNumCte;
		ELIF pTipOper = 3 THEN 
			DELETE FROM  bdinvers:"informix".sv_benefic WHERE empresa = pEmpresa AND cuenta = pNumeroCuenta AND numcte = pNumCte;
		END IF;
	ELSE
		IF pTipOper = 1 THEN
		
			SELECT MAX(numero) INTO vSecuencia FROM bdinvers:"informix".sv_benefic WHERE empresa = pEmpresa AND cuenta = pNumeroCuenta;
			
			IF vSecuencia IS NULL OR vSecuencia = 0 OR vSecuencia = '' THEN
				LET vSecuencia = 1;
			ELSE
				LET vSecuencia = vSecuencia + 1;
			END IF;
			
			INSERT INTO bdinvers:"informix".sv_benefic (empresa, cuenta, numero, nombre, parentesco, porcentaje, numcte) 
			VALUES(pEmpresa,pNumeroCuenta,vSecuencia, pNombre,pParentesco,pPorcentaje,pNumCte );
			
		ELSE		
			LET cCodRet = '00089';
		END IF;
	END IF;

	RETURN cCodRet;
 END;	
END PROCEDURE 


