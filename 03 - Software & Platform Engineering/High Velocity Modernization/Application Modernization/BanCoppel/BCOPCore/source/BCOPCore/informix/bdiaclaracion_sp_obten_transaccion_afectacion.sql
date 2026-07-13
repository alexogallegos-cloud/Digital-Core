CREATE PROCEDURE "informix".sp_obten_transaccion_afectacion(numero_transaccion CHAR(4))

     RETURNING	CHAR(50) AS descripcion, CHAR(2) AS sistema;

	--definicion de variables--	    
	DEFINE des_transaccion  CHAR(50);
    DEFINE producto  CHAR(2);
    	DEFINE iSqlErr                   	INTEGER;
     
     -- InicializaciÃ³n de las variables.
	LET des_transaccion  = '';
    LET producto  = '';
	
    SET ISOLATION TO DIRTY READ;

	BEGIN
         ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET des_transaccion  = '';
                LET producto  = '';
                RETURN des_transaccion,producto;
            END IF;
        END EXCEPTION;
     
        
            SELECT  descripcion,sistema
            INTO des_transaccion,producto
            FROM bdinteg:si_transacc 
                WHERE numero = numero_transaccion
                AND  sistema in(1,3,6)
                AND  se_emite_edocta='S';
                ---Seccion del parser
                    IF producto='01' THEN
						-- Debito
                       LET producto='2';    
                    END IF;
                    IF producto='06' THEN
					   -- Credito
                       LET producto='1';
                    END IF;
                     IF producto='03' THEN
					   -- Inversion
                       LET producto='3';
                    END IF;

            RETURN des_transaccion,producto;			     
	END 
END PROCEDURE;