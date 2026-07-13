CREATE PROCEDURE "informix".sp_consulta_cargo_recurrente(p_num_tarjeta CHAR(16), p_folio_suc char(15))
     RETURNING  VARCHAR (4) AS cCodRet, --Salida de codigo de retorno
                VARCHAR(2) AS  indicador_recurrente; -- Salida de indicador de cargo recurrente
    --definicion de variables-- 
    DEFINE ind_cargo_rec CHAR(2); 
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(3); 
    DEFINE indicador_recurrente CHAR (2);
    DEFINE esBinCredito INTEGER;
--  Inicializacion de las variables.
    LET cCodRet = '000';
    LET esBinCredito=0;
    LET indicador_recurrente = 'F';

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET ind_cargo_rec = '';
                RETURN iSqlErr,ind_cargo_rec;
            END IF;
        END EXCEPTION;
        LET esBinCredito = (SELECT count (bin) FROM intercard:bines b WHERE b.bin = SUBSTR (p_num_tarjeta, 1, 6) and b.creditodebito = 'C');
	    IF esBinCredito = 1 THEN 
             IF EXISTS (SELECT * FROM intercard:movimiento
	                    WHERE numtarjeta = p_num_tarjeta
	                    AND secuenciaextendida = p_folio_suc
	                    AND fechahorainauthj between today-90 and today
	                    AND prodind = '02' 
	                    AND tipotransaccionposdigitada  = 'CA' 
	                    AND codigoiso = '00' 
	                    AND movconciliado = 'V' 
	                    AND codreversa = '0' 
	                    AND movreversado = 'F')
	         THEN 
	            LET indicador_recurrente = 'V';
	         ELSE IF EXISTS (SELECT * FROM intercard:movimientohistorico
	                        WHERE numtarjeta = p_num_tarjeta
	                        AND secuenciaextendida = p_folio_suc
 	                        AND fechahorainauthj between today-90 and today
	                        AND prodind = '02' 
	                        AND tipotransaccionposdigitada  = 'CA'
	                        AND codigoiso = '00' 
	                        AND movconciliado = 'V' 
	                        AND codreversa = '0' 
	                        AND movreversado = 'F') 
	            THEN
	                 LET indicador_recurrente = 'V';
	            END IF;
	         END IF;
           END IF;
        return  cCodRet||',',indicador_recurrente;
    END;
END PROCEDURE;