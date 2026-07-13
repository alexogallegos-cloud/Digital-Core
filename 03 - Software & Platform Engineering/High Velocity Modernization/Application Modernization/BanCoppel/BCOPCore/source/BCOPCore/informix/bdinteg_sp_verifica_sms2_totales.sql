CREATE PROCEDURE "informix".sp_verifica_sms2_totales(
	pFechIni DATE, 
	pFechFin DATE
	)
	
RETURNING INTEGER AS CodErr, INTEGER AS total_registros;

DEFINE iSqlErr         INTEGER;
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
                select COUNT(*)
                    into i_NoRegistros
                from si_indicadores_ctes_nvos
                    where fecha between pFechIni and pFechFin;

                RETURN iSqlErr, i_NoRegistros;
            
END
END PROCEDURE;