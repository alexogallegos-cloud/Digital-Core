CREATE PROCEDURE "informix".validacuenta(p_empresa CHAR (3), p_ccmayor CHAR(4), p_ccsub CHAR(2), p_ccsubsub CHAR(2), p_ccssubsub CHAR(2), p_ccsssubsub CHAR(2), p_sector CHAR(2))

RETURNING INT, CHAR (50), CHAR(1);

DEFINE cod_ret      INT;
DEFINE tRegistros   INT;
DEFINE tMensaje     CHAR(50);
DEFINE tTipo_cuenta CHAR(1);
DEFINE tNombre      CHAR(50);
DEFINE tAuxiliar    CHAR(1);

--*************************************************************
-- Creado por Fabiola Corrales Tapia 22/Mar/2007            --*
-- Modificado por Fabiola Corrales Tapia FCT el 31/Ago/2007 --*
-- Debug del Procedure                                      --*
-- SET DEBUG FILE TO "/tmp/validacuenta.out";               --*
-- TRACE ON;                                                --*
--*************************************************************

    LET cod_ret = 1;
    LET tRegistros = 0;
    LET tMensaje = NULL;
    LET tAuxiliar = '';

    SELECT COUNT(*) INTO tRegistros FROM bdinteg:si_catalog
    WHERE empresa = p_empresa AND ccmayor = p_ccmayor AND ccsub = p_ccsub AND ccsubsub = p_ccsubsub
    AND ccssubsub = p_ccssubsub AND ccsssubsub = p_ccsssubsub AND sector = p_sector;

    IF tRegistros = 1 THEN
        LET cod_ret  = 0;
        LET tMensaje = 'CUENTA CONTABLE VALIDA';

        SELECT tipo_cuenta, nombre, auxiliar INTO tTipo_cuenta, tNombre, tAuxiliar FROM bdinteg:si_catalog
        WHERE empresa = p_empresa AND ccmayor = p_ccmayor AND ccsub = p_ccsub AND ccsubsub = p_ccsubsub
        AND ccssubsub = p_ccssubsub AND ccsssubsub = p_ccsssubsub AND sector = p_sector;

        IF tTipo_cuenta <> 'D' THEN
            LET cod_ret  = 2;
            LET tMensaje = tNombre;
        ELSE
            LET cod_ret  = 0;
            LET tMensaje = tNombre;
        END IF

    ELSE
        IF tRegistros > 1 THEN
            LET cod_ret  = 3;
            LET tMensaje = 'EXISTE MAS DE UN REGISTRO DE LA CUENTA CONTABLE';
        ELSE
            LET cod_ret  = 1;
            LET tMensaje = 'NO EXISTE LA CUENTA CONTABLE';
        END IF
    END IF
    RETURN cod_ret, tMensaje, tAuxiliar;
END PROCEDURE;