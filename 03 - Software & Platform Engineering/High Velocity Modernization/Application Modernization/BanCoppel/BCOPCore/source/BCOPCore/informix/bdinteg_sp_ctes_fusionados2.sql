CREATE PROCEDURE "informix".sp_ctes_fusionados2(
			pFechIni DATE, 
			pFechFin DATE,
			pRegistros INTEGER,
			pRecuperacion INTEGER)
			
		RETURNING INTEGER as CodErr, 
			CHAR(10) as Fecha, 
			INTEGER as Fusionados, 
			INTEGER as No_Fusionados, 
			INTEGER as Total

DEFINE iSqlErr                  INTEGER;
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
                    select SKIP pRegistros FIRST pRecuperacion fecha_proceso, sum(procesados) as Total, sum(fusionados) as fusionados, sum(no_fusionados) as no_fusionados
                    into dFecha, iTotal, iFusionados, iNoFusionados
                    from si_estadistica_fusiones where fecha_proceso between pFechIni and pFechFin
                    group by 1 order by 1

                RETURN iSqlErr, dFecha, iFusionados, iNoFusionados, iTotal WITH RESUME;
            END FOREACH;
END
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 04/12/2015',
'DESCRIPCION: Se realiza modificaciÃ³n para realizar ordenamiento por fecha',
'BD: bdicnweb';

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