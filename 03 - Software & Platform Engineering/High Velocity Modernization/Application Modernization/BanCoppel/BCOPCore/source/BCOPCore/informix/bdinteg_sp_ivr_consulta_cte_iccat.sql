CREATE PROCEDURE "informix".sp_ivr_consulta_cte_iccat(pnumtelefono CHAR(10))
RETURNING 
    CHAR(5),   -- CÃDIGO DE RETORNO
    CHAR(9);   -- NÃMERO DE CLIENTE

-- DEFINICIÃN DE VARIABLES
DEFINE vcodret       CHAR(5);
DEFINE vnumcliente   CHAR(9);
DEFINE Sql_Err       INTEGER;
DEFINE Isam_Err      INTEGER;
DEFINE Desc_Err      CHAR(50);

-- INICIALIZACIÃN DE VARIABLES
LET vcodret = '00000';
LET vnumcliente = '';
LET Sql_Err = 0;
LET Isam_Err = 0;
LET Desc_Err = '';

 --SET DEBUG FILE TO "/tmp/clizarraga/ivr_consulta_cte_iccat.out";
 --TRACE ON;

BEGIN
    -- MANEJO DE EXCEPCIONES
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        IF Sql_Err <> 0 THEN
            RETURN Sql_Err, vnumcliente;
        END IF;
    END EXCEPTION;

    -- CONFIGURACIÃN DE TRANSACTABILIDAD
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- CONSULTA PRINCIPAL
    SELECT {+INDEX(bdivr:"informix".si_cliente_iccat idx_si_cliente_iccat)} numcliente 
    INTO vnumcliente 
    FROM bdivr:si_cliente_iccat
    WHERE telefono = pnumtelefono
        AND fecha = (SELECT {+INDEX(bdivr:"informix".si_cliente_iccat idx_si_cliente_iccat)} MAX(fecha) FROM bdivr:si_cliente_iccat WHERE telefono = pnumtelefono);

    -- VALIDACIÃN DE RESULTADOS
    IF vnumcliente IS NULL OR vnumcliente = '' OR pnumtelefono IS NULL OR pnumtelefono = '' THEN
        LET vcodret = '00017';
    END IF;

    RETURN vcodret, vnumcliente;
END;
END PROCEDURE;