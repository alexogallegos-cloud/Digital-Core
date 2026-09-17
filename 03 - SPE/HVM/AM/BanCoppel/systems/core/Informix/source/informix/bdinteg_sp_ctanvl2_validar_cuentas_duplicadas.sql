CREATE PROCEDURE "informix".sp_ctanvl2_validar_cuentas_duplicadas()
    RETURNING CHAR(5) AS codret, 
              CHAR(5) AS CodRet2, 
              CHAR(50) AS CodRet3, 
              INTEGER AS Contador1,
              INTEGER AS Contador2;

    DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
    DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
    DEFINE cNumCte CHAR(9);
    DEFINE cCuenta CHAR(20);
    DEFINE iContador1 INTEGER;
    DEFINE iContador2 INTEGER;
    DEFINE cCuentaDuplicada INTEGER;
    DEFINE dias_a_procesar INTEGER;

    LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = 0;
    LET cCodRet = '00000';   -- CÃ³digo de retorno en caso de Ã©xito
    LET cCodRet2 = '000';
    LET cCodRet3 = 'PROCESO FINALIZADO CORRECTAMENTE'; 
    LET iContador1 = 0;
    LET iContador2 = 0;
    LET cCuentaDuplicada = 0;
    LET dias_a_procesar = 5;

    BEGIN

        -- ConfiguraciÃ³n de excepciones para el manejo de errores
       ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
            SET DEBUG FILE TO '/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_validar_cuentas_duplicadas.err';
            TRACE ON;
        
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                LET cCodRet2 = iSamErr;
                LET cCodRet3 = cDesErr;
                RETURN cCodRet, cCodRet2, cCodRet3, iContador1, iContador2;
            END IF;
            
        END EXCEPTION;

        --SET DEBUG FILE TO '/RESPALDOSNEW/Alfredo/reingenieria/sp_ctanvl2_validar_cuentas_duplicadas.out';
        --TRACE ON;


        -- ConfiguraciÃ³n de la transacciÃ³n
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        -- Procedimiento para contar las cuentas duplicadas
        FOREACH WITH HOLD

            SELECT cuenta, COUNT(*) INTO cCuenta, cCuentaDuplicada
            FROM bdinteg:si_tab_con_cuentas_n2
            GROUP BY cuenta
            HAVING COUNT(*) >= dias_a_procesar -- Selecciona cuentas con 5 o mÃ¡s duplicados

            LET iContador1 = iContador1 + 1;

            -- Si se encuentra una cuenta duplicada mÃ¡s de 5 veces, se emite un cÃ³digo de error
            IF cCuentaDuplicada >= dias_a_procesar THEN
                LET cCodRet = '00001';  -- Error por cuentas duplicadas
                LET cCodRet2 = 'ERROR';
                LET cCodRet3 = 'Cuenta duplicada mÃ¡s de 5 veces: ' || cCuenta;
                RETURN cCodRet, cCodRet2, cCodRet3, iContador1, iContador2;
            END IF;

         END FOREACH;

        -- Si no se encontraron cuentas con 5 o mÃ¡s duplicados, se retorna cÃ³digo de Ã©xito
        LET cCodRet = '00000';  -- Todo estÃ¡ correcto
        LET cCodRet2 = 'EXITO';
        LET cCodRet3 = 'No se encontraron errores';

        -- Retornar el resultado
    RETURN cCodRet, cCodRet2, cCodRet3, iContador1, iContador2;

    END; 
END PROCEDURE;