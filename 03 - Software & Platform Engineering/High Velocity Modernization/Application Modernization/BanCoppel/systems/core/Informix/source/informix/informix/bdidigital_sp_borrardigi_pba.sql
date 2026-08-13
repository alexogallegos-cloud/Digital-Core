CREATE PROCEDURE "informix".sp_borrardigi_pba(p_sempresa CHAR(3), pCliente CHAR(20),pCuenta CHAR(20),pProducto CHAR(4), pDocto CHAR(4))
       RETURNING CHAR(5);

DEFINE v_sconfirma CHAR(5);
DEFINE v_secuencia CHAR(2);
 --******************************************************
 -- Debug del Procedure                               --*
 -- SET DEBUG FILE TO "/tmp/sp_borrardigi.out";       --*
 -- TRACE ON;                                         --*
 --******************************************************

       LET v_sconfirma = '00001';

       BEGIN
                SET ISOLATION DIRTY READ;
                SET LOCK MODE TO WAIT 3;

        foreach with hold
            SELECT secuencia
              INTO v_secuencia
              FROM bdidigital@coppelimg_crx:dg_expediente
             WHERE empresa = p_sempresa
               AND cliente = pCliente
               AND cuenta = pCuenta
               AND producto = pProducto
               AND cod_docto = pDocto

             LET v_sconfirma = '00000';

        end foreach;

               RETURN v_sconfirma;

                END

END PROCEDURE
;