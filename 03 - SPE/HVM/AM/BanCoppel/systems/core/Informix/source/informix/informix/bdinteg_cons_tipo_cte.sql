CREATE PROCEDURE "informix".cons_tipo_cte(cEmpresa CHAR(3),cNumcte CHAR(20))

RETURNING CHAR(5),CHAR(1),INTEGER;


    -- // DECLARACION DE VARIABLES
    DEFINE cCodret CHAR(5);
    DEFINE cTipocliente CHAR(1);
    DEFINE iSecCte INTEGER;
    -- // INICIALIZACIÃ??Ã?Â¿N DE VARIABLES
    LET cCodret = '00000';
    LET cTipocliente='';
    LET iSecCte = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	--SET DEBUG FILE TO '/informix/c91691184/direccionbeneficiario.out';
	--TRACE ON;

    BEGIN

	IF (cEmpresa = '' or cNumcte = '') THEN
		LET cCodret = '00001'; -- Parametros en blanco
		RETURN cCodret,cTipocliente,iSecCte;

	END IF;

    IF EXISTS ( SELECT 1
                  FROM bdinteg:si_cliente
                 WHERE empresa = cEmpresa
                   AND numcte = cNumcte ) THEN
        SELECT tipo_cliente
          INTO cTipocliente FROM si_cliente
         WHERE numcte = cNumcte;

           SELECT MAX (secuencia) 
              INTO iSecCte 
              FROM bdinteg:si_direcciones_actual 
             WHERE numcte = cNumcte 
              AND tipo_dir = 1; 
    ELSE
      LET cCodret = '00001';
    END IF;

    RETURN cCodret,cTipocliente,iSecCte;

    END;

END PROCEDURE;