CREATE PROCEDURE "informix".sp_depura_arch_movimientos(pFolio CHAR(25)) 
RETURNING CHAR(5) AS cod_ret;
--************************************************************************************************************************************
-- DESCRIPCION: Depurar los registros de movimientos por folio de un archivo de movimientos generado sobre bdibei:bei_movimientos_cons
-- AUTOR : Marco Tinajero - BanCoppel - Internet.
-- BD: bdibei
-- FECHA DE CREACION: 06/Agosto/2025
-- INC 03 501 EmpresaNet - Optimizacion Generacion Archivo de Movimientos
--**************************************************************************************************************************************

    -- Variables para manejo de excepcion/resultado
    DEFINE vIntSqlErr INTEGER;
    DEFINE vChrCodRet CHAR(5);

    -- Variables para consulta de movimientos
    DEFINE vIntIdMovimiento INTEGER;
    DEFINE vChrFolio CHAR(25);

    -- Variables para manejo de excepcion/resultado
    DEFINE vIntContadorMovs INTEGER;
    DEFINE vIntIniciarBegin INTEGER;
    DEFINE vIntRegistros INTEGER;

    -- Inicializar variables
    LET vChrCodRet = "00000";
    LET vIntContadorMovs = 0;
    LET vIntIniciarBegin = 1;
    LET vIntRegistros = 1000;

    BEGIN
        -- Manejo de excepcion
        ON EXCEPTION SET vIntSqlErr
            IF vIntSqlErr <> 0 THEN
                LET vChrCodRet = vIntSqlErr;
                RETURN vChrCodRet;
            END IF ;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        FOREACH WITH HOLD
            SELECT id_movimientos, folio
            INTO vIntIdMovimiento, vChrFolio
            FROM bdibei:"informix".bei_movimientos_cons 
            WHERE folio = pFolio 
            ORDER BY id_movimientos

            IF vIntIniciarBegin = 1 THEN
                BEGIN WORK;
                LET vIntIniciarBegin = 0;
            END IF;

            LET vIntContadorMovs = vIntContadorMovs + 1;

            DELETE {+INDEX(bdibei:"informix".bei_movimientos_cons movimientos)}
            FROM bdibei:"informix".bei_movimientos_cons 
            WHERE id_movimientos = vIntIdMovimiento AND folio = vChrFolio;

            -- Se realiza el commit work al alcanzar los 1000 registros
            IF (vIntContadorMovs >= vIntRegistros) THEN
                COMMIT WORK;
                LET vIntIniciarBegin = 1;
                LET vIntContadorMovs = 0;
            END IF;        

            CONTINUE FOREACH;
        END FOREACH;

        -- Si al terminar la ejecucion del foreach se creo un BEGIN WORK y no se genero el COMMIT WORK con mas de 1000 regs, se ejecutara aqui
        IF (vIntIniciarBegin = 0) THEN
            COMMIT WORK;
        END IF;

        RETURN vChrCodRet;
    END;
END PROCEDURE;