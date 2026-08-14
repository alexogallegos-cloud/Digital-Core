CREATE PROCEDURE "informix".sp_traeinffolio(pempresa CHAR(3), pFolio CHAR(20))
RETURNING CHAR(5), CHAR(20), CHAR(20), DATE;

DEFINE vcodret 		CHAR(5);
DEFINE vsqlerr 		INTEGER;
DEFINE cOperador 	CHAR(20);
DEFINE cMonto 		CHAR(20);
DEFINE cfecha 		DATE;

LET vcodret = "000";
LET vsqlerr = 0;
LET cOperador='';
LET cMonto='';
LET cfecha='';

BEGIN
ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
			LET vcodret='001';
            Return vcodret, cOperador,cMonto,cfecha;
		END IF;	
END EXCEPTION;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT usuario_recepcion, monto , fecha_recepcion 
INTO cOperador,cMonto,cfecha
FROM bdisuc:ss_mae_entradasalida 
WHERE folio_oper=pFolio;

LET cOperador=NVL(cOperador,'');

IF cOperador='' THEN
    Let vcodret='002';
    RETURN vcodret, cOperador,cMonto,cfecha;
END IF;

RETURN vcodret, cOperador,cMonto,cfecha;

END
END PROCEDURE;