CREATE PROCEDURE "informix".sp_bajausuariomovil_inactivo()
	RETURNING CHAR (6) AS codRetorno;
			  
	DEFINE iSqlErr		INTEGER;
	DEFINE cCodRetorno		CHAR (6);
	DEFINE cEjecutivo		CHAR (8); 		
	DEFINE cFechaInsert		DATE; 		
	
	LET iSqlErr			=0;
	LET cCodRetorno		='000001';
	LET cEjecutivo		='';
	LET cFechaInsert = null;
		
	--SET DEBUG FILE TO "/tem/sp_bajausuariomovil_inactivo.out";	
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF (iSqlErr !=0) THEN 
				LET cCodRetorno =iSqlErr;
				RETURN cCodRetorno;
			END IF;
		END EXCEPTION;
	 
	 SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;
	 
		FOREACH
		
			SELECT ejecutivo 
			INTO	cEjecutivo
			FROM  bdinteg:"informix".si_usuario_movil 
			WHERE activo = '1'
			
			SELECT max(fecha_insert)
			INTO cFechaInsert
			FROM  bdinteg:"informix".si_solicitud_movil
			WHERE ejecutivo = cEjecutivo;
			
			IF (TODAY - cFechaInsert) >=31  THEN
				UPDATE bdinteg:"informix".si_usuario_movil 
				SET activo = 0, fecha_baja = CURRENT, user_baja = 'informix'
				WHERE ejecutivo = cEjecutivo; 
			END IF;
						
			LET cCodRetorno ='000000';
					    
        END FOREACH; 
				
		RETURN cCodRetorno; 
			
	END;
END PROCEDURE

DOCUMENT
'AUTOR      : Irma Ureta',
'DESCRIPCION: Se crea procedimiento para dar de baja a los usuarios inactivos los cuales ya cuenten con una inactividad igual o mayor a 31 días transcurridos,',
'para esto se deben de actualizar los campos activo = 0, fecha_baja = fecha actual y usuario_baja = informix.',
'FECHA      : 26/04/2018',
'BD         : bdinteg';

CREATE PROCEDURE "informix".sp_ctedigital_duplicados()
--RETORNOS-
RETURNING CHAR(6)    AS cod_ret;

--DECLARACION DE VARIABLES--
DEFINE iSql_err		    				INTEGER; 
DEFINE cCodret		    				CHAR(6);
DEFINE iConsecutivo     				INTEGER;
DEFINE cNoCteBco                        CHAR(20);
DEFINE cConsecMin                       INTEGER;
DEFINE cNoCteBcoMax                     CHAR(20);
DEFINE cConsecMax                       INTEGER;
DEFINE cNoCteBcoUpdt                    CHAR(20);
DEFINE cConsecUpdt                   	INTEGER;
DEFINE cCommit                          INTEGER;

--INICIALIZACION DE VARIABLES--
LET iSql_err		    				= 0;
LET cCodret		        				= '000000';
LET iConsecutivo        				= 0;
LET cNoCteBco		        			= '';
LET cConsecMin	        				= 0;
LET cNoCteBcoMax	        			= '';
LET cConsecMax          				= 0;
LET cNoCteBcoUpdt		        		= '';
LET cConsecUpdt 	        			= 0;
LET cCommit     	        			= 0;

BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;

            IF (cCommit = 0) THEN
                 ROLLBACK WORK;
            END IF;

			RETURN TRIM(cCodret);
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/tmp/cyrv/sp_ctedigital_duplicados.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    DROP TABLE IF EXISTS ctedigdoble;
    DROP TABLE IF EXISTS consecutivosMaximos;

	
	--SE INSERTAN CLIENTES DUPLICADOS EN TABLA TEMPORAL
    SELECT num_cte_banco
    FROM si_clientes_digital
    GROUP BY num_cte_banco
    HAVING COUNT(num_cte_banco) >= 2
    INTO TEMP ctedigdoble;

    CREATE TEMP TABLE consecutivosMaximos(
        ctebcoMax       CHAR(20),
        consecutMax     INT,
        PRIMARY KEY(consecutMax)
    );

	--SE INSERTAN CLIENTES DUPLICADOS EN TABLA TEMPORAL, UNICAMENTE SI MAXIMO CONSECUTIVO
    FOREACH

        SELECT num_cte_banco, MAX(consecutivo)
        INTO cNoCteBcoMax, cConsecMax
        FROM si_clientes_digital
        WHERE num_cte_banco IN (SELECT num_cte_banco FROM ctedigdoble)
        GROUP BY num_cte_banco
        HAVING COUNT(num_cte_banco) >= 2

        INSERT INTO consecutivosMaximos (ctebcoMax , consecutMax) VALUES (cNoCteBcoMax, cConsecMax);

    END FOREACH

    /*
    IF (cCommit = 0) THEN
        BEGIN WORK;
    END IF;
    */

	--SE ACTUALIZA EL ESTATUS DEL CLIENTE PARA QUE EL DEMONIO NO LO TOME
    FOREACH WITH HOLD

       SELECT ctebcoMax, consecutMax
       INTO cNoCteBcoUpdt, cConsecUpdt
       FROM consecutivosMaximos

       LET cCommit = cCommit + 1;

       UPDATE si_clientes_digital 
       SET estatus_envio = 2, error = 'El cliente ya cuenta con un correo registrado.'  
       WHERE num_cte_banco = cNoCteBcoUpdt
        AND consecutivo <> cConsecUpdt;

		/*
       IF (cCommit >= 1000) THEN
          COMMIT WORK;
            LET cCommit = 0; 
          BEGIN WORK;
       END IF;
		*/

    END FOREACH

    --TRAMA GENERADA CORRECTAMENTE	
	RETURN TRIM(cCodret);

END;
END PROCEDURE;