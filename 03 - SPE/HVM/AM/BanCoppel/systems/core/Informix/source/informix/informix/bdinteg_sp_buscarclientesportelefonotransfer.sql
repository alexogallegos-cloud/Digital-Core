CREATE PROCEDURE "informix".sp_buscarclientesportelefonotransfer (p_sNumeroTelefonoTransfer CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--	    
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
	DEFINE resultado_primerNombre		CHAR(30);
	DEFINE resultado_segundoNombre		CHAR(30);
	DEFINE telefono_Transfer		CHAR(30);
	DEFINE iSqlErr                     	INTEGER;
	
    -- Inicialización de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
	LET telefono_Transfer = '';
	
    SET ISOLATION TO DIRTY READ;
		
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';
                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;
        
            SELECT numcte
            INTO resultado_numeroCliente
            FROM bditransfer:tf_maecte
            WHERE empresa = '001'
              AND telefono = p_sNumeroTelefonoTransfer;
           
	     
	
		IF ( resultado_numeroCliente IS NULL ) THEN
           let resultado_numeroCliente = '';
        ELSE
            SELECT si_cliente.numcte, nombre1, nombre2, apell_paterno, apell_materno
              INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
              FROM bdinteg:si_cliente
             WHERE numcte = resultado_numeroCliente;
{
            IF ( resultado_numeroCliente IS NULL ) THEN
               
				LET resultado_numeroCliente = '';
				LET resultado_primerApellido = '';
				LET resultado_segundoApellido = '';
				LET resultado_primerNombre = '';
				LET resultado_segundoNombre = '';
				
            END IF;
}
        END IF;

        RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;

	END
END PROCEDURE;