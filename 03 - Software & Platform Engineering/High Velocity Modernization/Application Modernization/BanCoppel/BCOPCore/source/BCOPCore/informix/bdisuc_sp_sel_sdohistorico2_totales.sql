CREATE PROCEDURE "informix".sp_sel_sdohistorico2_totales( pEmpresa CHAR(3), ptipo SMALLINT, pccmayor CHAR(4), pccsub CHAR(2), pccsubsub CHAR(2), pccssubsub CHAR(2), pccsssubsub CHAR(2), psector CHAR(2), pFechaIni DATE, pFechaFin DATE)
RETURNING VARCHAR(5), 
                  INTEGER; 

        --Variables Exception
        DEFINE cVarDataErr                                                      VARCHAR(64);
        DEFINE iSqlErr                                                          INTEGER;
        DEFINE iSamErr                                                          INTEGER;
        DEFINE vCodret                                                          CHAR(5);
		DEFINE iNoRegistros                                                     INTEGER;

        DEFINE vfecha_hoy  DATE;

    --Manejo del error
                ON EXCEPTION
                        SET iSqlErr, iSamErr, cVarDataErr
                        IF iSqlErr <> 0 THEN
                                LET vCodret=iSqlErr;
                                RETURN vCodret, iNoRegistros;   
                        END IF;
                END EXCEPTION;

    --set debug file to "/tmp/mfinis/sp_sel_sdohistorico2_totales.out";
    --trace on;

        SET LOCK MODE TO WAIT 4;
        SET ISOLATION TO DIRTY READ;

        LET vCodRet = '000';
		LET iNoRegistros = 0;
        IF ptipo = 0 THEN

                SELECT fecha_hoy 
                  INTO vfecha_hoy 
              FROM bdicont:co_fechas;

                IF MONTH(pFechaIni) = MONTH(vfecha_hoy)  AND  MONTH(pFechaFin) = MONTH(vfecha_hoy) THEN

							SELECT COUNT(*)
							  INTO iNoRegistros
							FROM (
							SELECT COUNT(*)
							  FROM bdicont:co_sdodias s, bdinteg:si_sucursales u 
							 WHERE s.empresa= pEmpresa
							   AND s.mes_dia BETWEEN pFechaIni and pFechaFin
							   AND s.ccmayor    = pccmayor
							   AND s.ccsub      = pccsub
							   AND s.ccsubsub   = pccsubsub
							   AND s.ccssubsub  = pccssubsub
							   AND s.ccsssubsub = pccsssubsub
							   AND s.sector     = psector
							   AND u.sucursal = s.sucursal
							   AND u.empresa =s.empresa
							 GROUP BY s.sucursal,u.nombre);

					 RETURN vCodret, iNoRegistros;

                ELSE
                        
							SELECT COUNT(*)
							  INTO iNoRegistros
							FROM (
							SELECT COUNT(*)
							FROM bdicont:co_histsdodias h, bdinteg:si_sucursales u 
					   WHERE h.empresa = pEmpresa
						 AND h.mes_dia between pFechaIni and pFechaFin
							 AND h.ccmayor    = pccmayor
							 AND h.ccsub      = pccsub
							 AND h.ccsubsub   = pccsubsub
							 AND h.ccssubsub  = pccssubsub
							 AND h.ccsssubsub = pccsssubsub
							 AND h.sector     = psector
							 AND u.sucursal = h.sucursal
							 AND u.empresa =h.empresa
							GROUP BY h.sucursal,u.nombre);

				 RETURN vCodret, iNoRegistros;

                
                END IF
        ELIF ptipo = 1 THEN
					SELECT COUNT(*)
					INTO iNoRegistros
					FROM 
					(SELECT COUNT(*)
					   FROM bdisuc:ss_saldossuc s, bdinteg:si_sucursales u 
					  WHERE s.empresa = pEmpresa
							AND s.sucursal IS NOT NULL
							AND s.fecha BETWEEN pFechaIni AND pFechaFin
							AND u.sucursal = s.sucursal
							AND u.empresa = s.empresa
				  GROUP BY s.sucursal,u.nombre);

			 RETURN vCodret, iNoRegistros;
        END IF

END PROCEDURE;