CREATE PROCEDURE "informix".sp_verifica_sms2(
	pFechIni DATE, 
	pFechFin DATE,
	pRegistros INTEGER,
	pRecuperacion INTEGER)
	
RETURNING        INTEGER as CodErr, CHAR(10) as Fecha, INTEGER as Validos, INTEGER as No_Validos, INTEGER as Total

DEFINE iSqlErr          INTEGER;
DEFINE iValidos         INTEGER;
DEFINE iNoValidos       INTEGER;
DEFINE iTotal           INTEGER;
DEFINE dFecha           CHAR(10);

LEt iSqlErr           =0;
LEt iValidos          =0;
LEt iNoValidos        =0;
LEt iTotal            =0;
LEt dFecha            ='';

BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                RETURN iSqlErr, dFecha, iValidos, iNoValidos, iTotal;
                        END IF;
                END EXCEPTION;

SET ISOLATION TO DIRTY READ;
            FOREACH c1 FOR
                    select SKIP pRegistros FIRST pRecuperacion fecha, SUM(telcel_ver) as Validado, (SUM(telcel_cap)-SUM(telcel_ver)) as NoValidado, SUM(telcel_cap) as total
                    into dFecha, iValidos, iNoValidos, iTotal
                    from si_indicadores_ctes_nvos
                    where fecha between pFechIni and pFechFin
                    group by 1 order by 1

                RETURN iSqlErr, dFecha, iValidos, iNoValidos, iTotal WITH RESUME;
            END FOREACH;
END
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/12/2015',
'DESCRIPCION: Se realiza modificaciÃ³n para realizar ordenamiento por fecha',
'BD: bdicnweb';

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