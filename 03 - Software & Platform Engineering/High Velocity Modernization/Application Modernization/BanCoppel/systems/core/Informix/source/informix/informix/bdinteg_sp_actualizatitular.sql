CREATE PROCEDURE "informix".sp_actualizatitular(
cEmpresa CHAR(3),
cNumCteTitular CHAR(9)
)

RETURNING CHAR(5) AS codret;

--****************************************************************************************************
-- DESCRIPCION: Confirma el alta del Cliente Titular.
-- AUTOR : Héctor Manuel Bojórquez Ruelas
-- FECHA : 03/04/2009
-- BD: bdinteg
-- SISTEMA : Caja Unica
--****************************************************************************************************

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);
DEFINE cNumHab CHAR(60);
DEFINE cCodIden CHAR(2);
DEFINE cNumIden CHAR(30);
DEFINE cHabitaEn CHAR(2);

LET iSqlErr = 0;
LET cCodRet = '';
LET cNumCte = '';
LET cNumHab = '';
LET cCodIden = '';
LET cNumIden = '';
LET cHabitaEn = '';

--SET DEBUG FILE TO "/tmp/sp_ActualizaTitular.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
    IF iSqlErr <> 0 THEN
    RETURN iSqlErr;
    END IF;
END EXCEPTION;

IF EXISTS (SELECT numcte
			FROM bdinteg:si_cliente
			WHERE empresa = cEmpresa AND numcte = cNumCteTitular
			AND numcte = (SELECT numcte FROM si_ctepf WHERE numcte = cNumCteTitular)
			AND numcte = (SELECT numcte FROM si_direcciones_actual WHERE numcte = cNumCteTitular AND tipo_dir='1')-- secuencia = (SELECT MAX(secuencia) FROM si_direcciones WHERE numcte = cNumCteTitular AND tipo_dir = '1'))
			AND numcte = (SELECT numcte FROM si_cte_huella WHERE numcte = cNumCteTitular AND estado = 'A')) THEN

                    SELECT a.string2, b.codidentifi, b.numidentifi, b.habita_en
                    INTO cNumHab, cCodIden, cNumIden, cHabitaEn
                    FROM bdinteg:si_cliente a, bdinteg:si_ctepf b
                    WHERE a.empresa = '001' AND a.numcte = cNumCteTitular  AND a.numcte = b.numcte;

                    IF NVL(cNumHab, '')  <> '' AND NVL(cCodIden, '') <> '' AND NVL(cNumIden, '') <> '' AND NVL(cHabitaEn, '') <> '' THEN
                                UPDATE bdinteg:si_cliente SET tipo_cliente = "1" WHERE empresa = cEmpresa AND numcte = cNumCteTitular;
                                --La operación se realizo de manera exitosa.
                                LET cCodRet = '00000';
                     ELSE
                                --El cliente buscado no fue encontrado.
                                LET cCodRet = '00001';
                    END IF;                    
 ELSE
            --El cliente buscado no fue encontrado.
            LET cCodRet = '00001';
END IF;

RETURN cCodRet;

END
END PROCEDURE;