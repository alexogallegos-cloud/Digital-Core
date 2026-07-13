CREATE PROCEDURE "informix".sp_borrardatos(v_usuario CHAR(10))

    DEFINE v_rowid INTEGER;
    DEFINE vsFlagEnTransaccion  CHAR(1);
    DEFINE viContadorRegistros INTEGER;

    LET v_rowid = 0;
    LET vsFlagEnTransaccion = 'F';
    LET viContadorRegistros = 0;

    SET LOCK MODE TO WAIT;
    SET ISOLATION TO DIRTY READ; 

    BEGIN
        --delete co_libmadet   	
        FOREACH WITH HOLD
          SELECT {+INDEX (co_libmadet idxco_libmadet)} rowid 
          INTO v_rowid  
          FROM bdicont:"informix".co_libmadet 
          WHERE usuario_rep = TRIM(v_usuario)

          --ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
                 LET vsFlagEnTransaccion = 'V';
            END IF;

            DELETE {+INDEX (co_libmadet idxco_libmadet)} FROM bdicont:"informix".co_libmadet WHERE rowid = v_rowid;

            LET viContadorRegistros = viContadorRegistros + 1;

            --TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
                LET viContadorRegistros = 0;
                CONTINUE FOREACH;
            END IF;    
        END FOREACH;

        -- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;

        LET v_rowid = 0;
        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;

    --delete  co_libsdoaux
        FOREACH WITH HOLD

          SELECT {+INDEX (co_libsdoaux idx01co_libsdoaux)} rowid
          INTO v_rowid  
          FROM bdicont:"informix".co_libsdoaux 
          WHERE usuario = TRIM(v_usuario)

          --ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
                 LET vsFlagEnTransaccion = 'V';
            END IF;

            DELETE {+INDEX (co_libsdoaux idx01co_libsdoaux)} FROM bdicont:"informix".co_libsdoaux WHERE rowid = v_rowid;

            LET viContadorRegistros = viContadorRegistros + 1;

            --TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
            IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
                LET viContadorRegistros = 0;
                CONTINUE FOREACH;
            END IF;    
        END FOREACH;

        -- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;

    END;
END PROCEDURE;