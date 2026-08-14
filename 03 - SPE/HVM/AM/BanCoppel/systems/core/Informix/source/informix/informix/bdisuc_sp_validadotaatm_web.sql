CREATE PROCEDURE "informix".sp_validadotaatm_web(pempresa CHAR(3),pcajero CHAR(4),pSucursal CHAR(5),pFec DATE)
RETURNING CHAR(5), MONEY;

    DEFINE monto 	  MONEY;
    DEFINE cCodRet 	  CHAR(5);
    DEFINE iSqlErr 	  INTEGER; 
    DEFINE iIsamErr   INTEGER;
    DEFINE vv  		  CHAR(10);
    DEFINE fecha_oper DATE;
    DEFINE monto2 	  MONEY;

    LET monto 	   = 0;
    LET cCodRet    = '00000';
	LET iSqlErr    = 0;
	LET iIsamErr   = 0;
    LET vv		   = '';
    LET fecha_oper = '';
    LET monto2     = 0;

	BEGIN	
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN 
				LET cCodRet = iSqlErr;
				--ROLLBACK;
				RETURN cCodRet,monto2;
			END IF;
		END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
--SET DEBUG FILE TO '/tmp/dota.out';
--TRACE ON;

    SELECT LIMIT 1 cod_trans,fecha_operacion
    INTO vv, fecha_oper 
	FROM ss_operaciones a, ss_mae_entradasalida b
    WHERE a.sucursal = pcajero 
    AND a.folio_oper = b.folio_oper
    AND a.fecha_entrega = pFec
    AND b.status IN ('01','03','11');

    LET vv = NVL(vv,'');

    IF vv = '' THEN
        Let cCodRet = '00001';
    END IF;

    FOREACH 
        SELECT a.monto
        INTO monto
        FROM ss_operaciones a, ss_mae_entradasalida b
        WHERE a.sucursal = pcajero 
        AND a.sucursal = b.sucursal 
        AND a.folio_oper = b.folio_oper
        AND b.status in ('01','03','11')
        AND a.reversado = '0'

        LET monto2= monto2+monto;    
    END FOREACH;
   
RETURN cCodRet,monto2;

END
END PROCEDURE;