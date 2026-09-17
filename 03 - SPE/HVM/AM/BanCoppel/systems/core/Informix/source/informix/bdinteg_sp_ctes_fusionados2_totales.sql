CREATE PROCEDURE "informix".sp_ctes_fusionados2_totales(
			pFechIni DATE, 
			pFechFin DATE
			)
			
		RETURNING INTEGER as CodErr, 
				  INTEGER AS total_registros;

DEFINE iSqlErr INTEGER;
DEFINE  i_NoRegistros  INTEGER;


LEt iSqlErr = 0;
LET i_NoRegistros = 0;

BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                 RETURN iSqlErr, i_NoRegistros;
                        END IF;
                END EXCEPTION;


					SET ISOLATION TO DIRTY READ;
                    SELECT COUNT(*)
                    INTO i_NoRegistros
                    FROM si_estadistica_fusiones WHERE fecha_proceso BETWEEN pFechIni AND pFechFin;                    

                RETURN iSqlErr, i_NoRegistros;
           
END
END PROCEDURE;