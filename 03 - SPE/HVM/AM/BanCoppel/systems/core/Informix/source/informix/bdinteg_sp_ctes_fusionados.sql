CREATE PROCEDURE "informix".sp_ctes_fusionados(pFechIni DATE, pFechFin DATE)
RETURNING	 INTEGER as CodErr, CHAR(10) as Fecha, INTEGER as Fusionados, INTEGER as No_Fusionados, INTEGER as Total

DEFINE iSqlErr			INTEGER;
DEFINE iFusionados      INTEGER;
DEFINE iNoFusionados    INTEGER;
DEFINE iTotal           INTEGER;
DEFINE dFecha           CHAR(10);


LEt iSqlErr              =0;
LEt iFusionados          =0;
LEt iNoFusionados        =0;
LEt iTotal               =0;
LEt dFecha               ='';

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr, dFecha, iFusionados, iNoFusionados, iTotal;
			END IF;
		END EXCEPTION;

			SET ISOLATION TO DIRTY READ;
            FOREACH c1 FOR
                    select fecha_proceso, sum(procesados) as Total, sum(fusionados) as fusionados, sum(no_fusionados) as no_fusionados
                    into dFecha, iTotal, iFusionados, iNoFusionados
                    from si_estadistica_fusiones where fecha_proceso between pFechIni and pFechFin
                    group by fecha_proceso

                RETURN iSqlErr, dFecha, iFusionados, iNoFusionados, iTotal WITH RESUME;
            END FOREACH;
END
END PROCEDURE;