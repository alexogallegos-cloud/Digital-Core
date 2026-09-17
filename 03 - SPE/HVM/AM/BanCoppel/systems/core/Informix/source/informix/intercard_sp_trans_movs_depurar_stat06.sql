CREATE PROCEDURE "informix".sp_trans_movs_depurar_stat06( pFechaBusqInicial DATETIME YEAR to FRACTION(5), pFechaBusqFinal DATETIME YEAR to FRACTION(5) )
    RETURNING CHAR(5),INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE error_info CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vRegistros               INTEGER;
    DEFINE vId                              INTEGER;
    DEFINE vfecha_oper      DATE;
    DEFINE vKeyX INTEGER;
    DEFINE vST_Secuencia varchar(12) ;
    DEFINE vST_Numtarjeta varchar(16);
    DEFINE vST_Fechaconciliacion DATETIME YEAR to FRACTION(5);    
    DEFINE vST_Autorizacion  VARCHAR(6);
    
    LET vcodret1        = '00000';
    LET sql_err             = 0;
    LET isam_err        = 0;
    LET vcontador1      = -1;
    LET vcontador2      = 0;
    LET vRegistros      = 0;
    LET vId                         = 0;
    LET vST_Secuencia      ='';
    LET vST_Numtarjeta     ='';
    LET vST_Fechaconciliacion ='';
    LET vKeyX = 0;
    LET vST_Autorizacion = '';

    BEGIN

        ON EXCEPTION SET sql_err, isam_err
            SET DEBUG FILE TO "/RESPALDOSNEW/exc_sp_trans_movs_depurar_stat06.err.out";
            TRACE ON;
            
                IF sql_err <> 0 THEN
                        LET vcodret1 = sql_err;
                        LET vcontador1 = isam_err;
                        RETURN vcodret1, vcontador1;
                END IF
        END EXCEPTION

        --SET DEBUG FILE TO "/RESPALDOSNEW/sp_trans_movs_depurar_stat06.out";
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 4;
        
        FOREACH curIterarSTAT WITH HOLD FOR

            SELECT keyx,fechaconciliacion,secuencia,numtarjeta
                INTO vKeyX, vST_Fechaconciliacion, vST_Secuencia, vST_Numtarjeta
            FROM intercard:"informix".tbl_cnc_stat_06_pivote  
            WHERE numero = 0
            ORDER BY keyx

            IF vcontador1 = -1 THEN
                    LET vcontador1 = 0;
                    BEGIN WORK;
            END IF;

            DELETE FROM intercard:"informix".conciliacion_atm_stat06 
                    WHERE keyx = vKeyX
                AND fechaconciliacion = vST_Fechaconciliacion 
                    AND secuencia = vST_Secuencia 
                AND numtarjeta = vST_Numtarjeta                    
                    AND fechaconciliacion BETWEEN pFechaBusqInicial AND pFechaBusqFinal;                       
                    --AND fechaconciliacion BETWEEN '2019-10-01 00:00:00.00000' AND '2019-10-31 23:59:59.99999';                       

            UPDATE intercard:"informix".tbl_cnc_stat_06_pivote 
                SET numero = 1 
            WHERE keyx = vKeyX
                AND fechaconciliacion = vST_Fechaconciliacion 
                    AND secuencia = vST_Secuencia 
                AND numtarjeta = vST_Numtarjeta;
                    
                    
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