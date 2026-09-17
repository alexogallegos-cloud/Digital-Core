CREATE PROCEDURE "informix".sp_obtenerctas_cte_ppcoppel(pEmpresa CHAR(3),
                            pNumCte CHAR(10))	
--DATOS A REGRESAR---
RETURNING CHAR(6)  AS cCod_ret,
          CHAR(1)   AS Retorno;
  	
    -- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************

    DEFINE cCod_ret char(6);
    DEFINE iCuentasEncontradas     	 INTEGER;	
	DEFINE iSqlErr      	 INTEGER;	
    DEFINE Retorno char(1);
    DEFINE p_fecha DATE;
	
	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************

    LET iSqlErr				= 0;
	LET iCuentasEncontradas	=0;
    LET cCod_ret     	  	= '000000';	
    LET Retorno     	  	= '0';	
    LET p_fecha				= TODAY;

BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCod_ret = iSqlErr;
				
				RETURN cCod_ret,Retorno;	
			END IF;
		END EXCEPTION;
 
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
    
	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************

	SELECT fecha_hoy INTO p_fecha FROM bdinteg: si_fechas;
        
    SELECT count(*) as cuentasCte into iCuentasEncontradas 
		FROM bdicheq:"informix".sc_maechq
    WHERE num_cte = pNumCte
		AND empresa = pEmpresa
		AND status_cta IN ('1','3','4','5')
		AND producto='2000'
		AND fec_ult_mov=p_fecha;

	IF iCuentasEncontradas > 0 THEN
		LET Retorno='1';
    ELSE
		LET Retorno='0';
        LET cCod_ret='000001';
    END IF 
      
    RETURN cCod_ret,Retorno;	
 
	END;
END PROCEDURE;