CREATE PROCEDURE "informix".sp_trans_bitac_envios_depurar( pFechaBusqInicial DATETIME YEAR TO SECOND, pFechaBusqFinal DATETIME YEAR TO SECOND, pAnio CHAR(4) )
    RETURNING CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE error_info CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vRegistros               INTEGER;
    DEFINE vId                              INTEGER;
    DEFINE vfecha_oper      DATE;
    DEFINE vSecuencial INTEGER;
    DEFINE vIdProceso VARCHAR(50) ;
    DEFINE vNumTarjeta VARCHAR(16);
    DEFINE vFechaInsert DATETIME YEAR to SECOND;    
    
    
    LET vcodret1        = '00000';
    LET sql_err             = 0;
    LET isam_err        = 0;
    LET vcontador1      = -1;
    LET vcontador2      = 0;
    LET vRegistros      = 0;
    LET vId                         = 0;
    LET vIdProceso      ='';
    LET vNumTarjeta     ='';
    LET vFechaInsert ='';
    LET vSecuencial = 0;
    

    BEGIN

        ON EXCEPTION SET sql_err, isam_err
            SET DEBUG FILE TO "/RESPALDOSNEW/exc_sp_trans_bitac_envios_depurar.err.out";
            TRACE ON;
            
            IF vcontador1 > -1 THEN
                COMMIT WORK;
            END IF
        
                IF sql_err <> 0 THEN
                        LET vcodret1 = sql_err;
                        LET vcontador1 = isam_err;
                        RETURN vcodret1, vcontador1;
                END IF
        END EXCEPTION

        --SET DEBUG FILE TO "/RESPALDOSNEW/sp_trans_bitac_envios_depurar.out";
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 4;
        
        FOREACH curIterarSTAT WITH HOLD FOR

            SELECT secuencial, id_proceso, tarjeta, fecha_insert
                INTO vSecuencial, vIdProceso, vNumTarjeta, vFechaInsert
            FROM intercard:"informix".tbl_bit_envios_pivote  
            WHERE numero = 0
            ORDER BY secuencial

            IF vcontador1 = -1 THEN
                    LET vcontador1 = 0;
                    BEGIN WORK;
            END IF;

            DELETE FROM intercard:"informix".bitacoraenvios_tjts 
                    WHERE secuencial = vSecuencial
                AND id_proceso = vIdProceso 
                    AND tarjeta = vNumTarjeta 
                AND fecha_insert BETWEEN pFechaBusqInicial AND pFechaBusqFinal;
                    --AND fechaconciliacion BETWEEN pFechaBusqInicial AND pFechaBusqFinal;                       
                    --AND fechaconciliacion BETWEEN '2019-10-01 00:00:00.00000' AND '2019-10-31 23:59:59.99999';                       

            UPDATE intercard:"informix".tbl_bit_envios_pivote 
                SET numero = 1 
            WHERE secuencial = vSecuencial
                AND id_proceso = vIdProceso 
                    AND tarjeta = vNumTarjeta                
                AND fecha_insert = vFechaInsert;
                --BETWEEN pFechaBusqInicial AND pFechaBusqFinal;
                    
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

             IF vcontador2 >= 1000 THEN
                    LET vcontador2 = 0;
                    COMMIT WORK;
                    BEGIN WORK;
             END IF;

            COMMIT WORK;
            BEGIN WORK;

        END FOREACH;
        
        IF vcontador1 > -1 THEN
                COMMIT WORK;
        END IF

        RETURN vcodret1, vcontador1;
    END;
END PROCEDURE;