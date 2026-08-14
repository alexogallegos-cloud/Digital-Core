CREATE PROCEDURE "informix".sp_reversioncap_pba(pUsuario char(10), 
					    pIdFuncion char(10), 
					    pFolioMovimiento char(16), 
					    pSucursalFolio char(4),
						pTransacc char(4))
       RETURNING char(5) as codret;
	
DEFINE cCodRet char(5);
DEFINE cConstante char(1);
DEFINE cEmpresa char(3);
DEFINE iSqlErr int;
DEFINE cReversable char(1);
	
LET cCodRet = '00000';
LET cConstante = 'M';
LET cEmpresa = '001';
LET iSqlErr = 0;
LET cReversable = '';
	
BEGIN
		
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;


	IF pUsuario = ''
	 OR pIdFuncion = '' 
	 OR pFolioMovimiento = '' 
	 OR pSucursalFolio = ''  
	 OR pTransacc = ''
	THEN
		LET cCodRet = '00003';
		RETURN cCodRet;
	END IF;
		
	-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, 
							               pIdFuncion) 
		INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet;
	END IF;
	
	-- Validacion de la transaccion para ver si puede ser reversable
	SELECT reversable
	INTO cReversable
	FROM bdinteg:"informix".si_transacc
	WHERE numero = pTransacc;

	IF cReversable IS NULL OR cReversable='' THEN
		LET cReversable='N';
	END IF;
	
	IF cReversable <> "S" THEN
		LET cCodRet = '00152'; -- No se permite realizar un reverso de esta transaccion
		RETURN cCodRet;
	END IF;
		
	EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, 
					    		pSucursalFolio, 
					    		pUsuario, 
					    		pFolioMovimiento, 
					    		cConstante) 
		INTO cCodRet;
		
	IF cCodRet = '000' THEN
                LET cCodRet = '00000';
        END IF;
        IF cCodRet = '170' THEN
		LET cCodRet = '00112';
	END IF;
	IF cCodRet = '413' THEN
		LET cCodRet = '00113';
	END IF;
	IF cCodRet = '00036' THEN
		LET cCodRet = '00003';
	END IF;
	IF cCodRet = '00030' THEN
		LET cCodRet = '00114';
	END IF;
	IF cCodRet = '00037' THEN
		LET cCodRet = '00115';
	END IF;
	IF cCodRet = '00035' THEN
		LET cCodRet = '00116';
	END IF;
	IF cCodRet = '001' THEN
		LET cCodRet = '00117';
	END IF;
		
	RETURN cCodRet;
		
END;

END PROCEDURE;