CREATE PROCEDURE "informix".sp_genera_numcte( pEmpresa CHAR(3) )
RETURNING CHAR(5) AS cCodRet, CHAR(20) AS cNumCte;

    -- 1. DefiniciÃ³n de Variables
    -- Solo declaramos las necesarias para que funcione tu bloque de cÃ³digo
    DEFINE cCodret      CHAR(5);
    DEFINE cNumcte      CHAR(20);
    DEFINE iSignumcte   INT;           -- Entero para poder sumar
    DEFINE sLong_cte    SMALLINT;      -- Variable para el parÃ¡metro 7
    DEFINE sDiferencia  SMALLINT;      -- Variable para el cÃ¡lculo de ceros
    DEFINE sI           SMALLINT;      -- Contador del ciclo FOR
    DEFINE iSqlerr      INTEGER;       -- Para control de excepciones

    -- 2. InicializaciÃ³n
    LET cCodret = "000";
    LET cNumcte = "";

BEGIN
    -- Manejo de Excepciones
    ON EXCEPTION SET iSqlerr
        IF iSqlerr <> 0 THEN
            LET cCodret = iSqlerr;
            RETURN cCodret, cNumcte;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    -- 3. TU LÃGICA (Insertada textualmente como solicitaste)
    
          SELECT valor
            INTO sLong_cte
            FROM bdinteg:"informix".si_param
           WHERE cod_param = 7
             AND empresa = pEmpresa;

        IF sLong_cte IS NULL THEN
            LET cCodret = "105";
            RETURN cCodret,cNumcte;
        ELSE
            SELECT valor
              INTO iSignumcte
              FROM bdinteg:"informix".si_param
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            IF iSignumcte IS NULL THEN
                LET iSignumcte = 1;
            END IF

            LET cNumcte = iSignumcte;
            LET iSignumcte = iSignumcte + 1;

            UPDATE bdinteg:"informix".si_param
               SET (valor) = (iSignumcte)
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            -- Nota: AsegÃºrate que cNumcte no tenga espacios al final para que LENGTH funcione bien
            LET sDiferencia = sLong_cte - LENGTH(cNumcte); 

            IF sDiferencia > 0 THEN
                FOR sI = 1 TO sDiferencia
                    LET cNumcte = "0" || cNumcte;
                END FOR;
            END IF
        END IF;

    -- 4. Retorno final (Si todo saliÃ³ bien)
    RETURN cCodret, cNumcte;
    END;

END PROCEDURE;