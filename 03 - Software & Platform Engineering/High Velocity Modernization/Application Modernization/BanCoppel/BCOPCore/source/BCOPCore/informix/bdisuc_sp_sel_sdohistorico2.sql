CREATE PROCEDURE "informix".sp_sel_sdohistorico2( pEmpresa CHAR(3), ptipo SMALLINT, pccmayor CHAR(4), pccsub CHAR(2), pccsubsub CHAR(2), pccssubsub CHAR(2), pccsssubsub CHAR(2), psector CHAR(2), pFechaIni DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER )
RETURNING VARCHAR(5), 
                  CHAR(4), 
              VARCHAR(40),
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2),
                  MONEY(14,2)
        --Variables Exception
        DEFINE cVarDataErr                                                      VARCHAR(64);
        DEFINE iSqlErr                                                          INTEGER;
        DEFINE iSamErr                                                          INTEGER;
        DEFINE vCodret                                                          CHAR(5);
        DEFINE vfecha_hoy  DATE;
        DEFINE vsucursal   CHAR(4);
        DEFINE vnombre     VARCHAR(40);
        DEFINE vdia_1      MONEY(14,2);
        DEFINE vdia_2      MONEY(14,2);
        DEFINE vdia_3      MONEY(14,2);
        DEFINE vdia_4      MONEY(14,2);
        DEFINE vdia_5      MONEY(14,2);
        DEFINE vdia_6      MONEY(14,2);
        DEFINE vdia_7      MONEY(14,2);
        DEFINE vdia_8      MONEY(14,2);
        DEFINE vdia_9      MONEY(14,2);
        DEFINE vdia_10     MONEY(14,2);
        DEFINE vdia_11     MONEY(14,2);
        DEFINE vdia_12     MONEY(14,2);
        DEFINE vdia_13     MONEY(14,2);
        DEFINE vdia_14     MONEY(14,2);
        DEFINE vdia_15     MONEY(14,2);
        DEFINE vdia_16     MONEY(14,2);
        DEFINE vdia_17     MONEY(14,2);
        DEFINE vdia_18     MONEY(14,2);
        DEFINE vdia_19     MONEY(14,2);
        DEFINE vdia_20     MONEY(14,2);
        DEFINE vdia_21     MONEY(14,2);
        DEFINE vdia_22     MONEY(14,2);
        DEFINE vdia_23     MONEY(14,2);
        DEFINE vdia_24     MONEY(14,2);
        DEFINE vdia_25     MONEY(14,2);
        DEFINE vdia_26     MONEY(14,2);
        DEFINE vdia_27     MONEY(14,2);
        DEFINE vdia_28     MONEY(14,2);
        DEFINE vdia_29     MONEY(14,2);
        DEFINE vdia_30     MONEY(14,2);
        DEFINE vdia_31     MONEY(14,2);
    --Manejo del error
                ON EXCEPTION
                        SET iSqlErr, iSamErr, cVarDataErr
                        IF iSqlErr <> 0 THEN
                                LET vCodret=iSqlErr;
                                RETURN vCodret, vsucursal, iSamErr || ' ' ||cVarDataErr,
                                           vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                           vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,                
                                           vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,             
                                           vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                           vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31 ;   
                        END IF;
                END EXCEPTION;
    --set debug file to "/tmp/sp_sel_sdohistorico2.out";
    --trace on;
        SET LOCK MODE TO WAIT 4;
        SET ISOLATION TO DIRTY READ;
        LET vCodRet = '000';
        LET vsucursal = '';
        LET vnombre = ''; 
        LET vdia_1  = 0.0;  
        LET vdia_2  = 0.0;    
        LET vdia_3  = 0.0;    
        LET vdia_4  = 0.0;    
        LET vdia_5  = 0.0;    
        LET vdia_6  = 0.0;    
        LET vdia_7  = 0.0;    
        LET vdia_8  = 0.0;    
        LET vdia_9  = 0.0;    
        LET vdia_10 = 0.0;    
        LET vdia_11 = 0.0;    
        LET vdia_12 = 0.0;    
        LET vdia_13 = 0.0;    
        LET vdia_14 = 0.0;    
        LET vdia_15 = 0.0;    
        LET vdia_16 = 0.0;    
        LET vdia_17 = 0.0;    
        LET vdia_18 = 0.0;    
        LET vdia_19 = 0.0;    
        LET vdia_20 = 0.0;    
        LET vdia_21 = 0.0;    
        LET vdia_22 = 0.0;    
        LET vdia_23 = 0.0;    
        LET vdia_24 = 0.0;    
        LET vdia_25 = 0.0;    
        LET vdia_26 = 0.0;    
        LET vdia_27 = 0.0;    
        LET vdia_28 = 0.0;    
        LET vdia_29 = 0.0;    
        LET vdia_30 = 0.0;    
        LET vdia_31 = 0.0;   
        IF ptipo = 0 THEN
                SELECT fecha_hoy 
                  INTO vfecha_hoy 
              FROM bdicont:co_fechas;
                IF MONTH(pFechaIni) = MONTH(vfecha_hoy)  AND  MONTH(pFechaFin) = MONTH(vfecha_hoy) THEN
                        FOREACH
                                SELECT SKIP pRegistros FIRST pRecuperacion s.sucursal,
                                           u.nombre,
                                       SUM(CASE WHEN DAY(mes_dia) = 1 THEN saldo_fin_de_dia ELSE 0 END) AS dia_1, 
                                       SUM(CASE WHEN DAY(mes_dia) = 2 THEN saldo_fin_de_dia ELSE 0 END) AS dia_2,
                                       SUM(CASE WHEN DAY(mes_dia) = 3 THEN saldo_fin_de_dia ELSE 0 END) AS dia_3,
                                       SUM(CASE WHEN DAY(mes_dia) = 4 THEN saldo_fin_de_dia ELSE 0 END) AS dia_4,
                                       SUM(CASE WHEN DAY(mes_dia) = 5 THEN saldo_fin_de_dia ELSE 0 END) AS dia_5,
                                       SUM(CASE WHEN DAY(mes_dia) = 6 THEN saldo_fin_de_dia ELSE 0 END) AS dia_6,
                                       SUM(CASE WHEN DAY(mes_dia) = 7 THEN saldo_fin_de_dia ELSE 0 END) AS dia_7,
                                       SUM(CASE WHEN DAY(mes_dia) = 8 THEN saldo_fin_de_dia ELSE 0 END) AS dia_8,
                                       SUM(CASE WHEN DAY(mes_dia) = 9 THEN saldo_fin_de_dia ELSE 0 END) AS dia_9,
                                       SUM(CASE WHEN DAY(mes_dia) = 10 THEN saldo_fin_de_dia ELSE 0 END) AS dia_10,
                                       SUM(CASE WHEN DAY(mes_dia) = 11 THEN saldo_fin_de_dia ELSE 0 END) AS dia_11,
                                       SUM(CASE WHEN DAY(mes_dia) = 12 THEN saldo_fin_de_dia ELSE 0 END) AS dia_12,
                                       SUM(CASE WHEN DAY(mes_dia) = 13 THEN saldo_fin_de_dia ELSE 0 END) AS dia_13,
                                       SUM(CASE WHEN DAY(mes_dia) = 14 THEN saldo_fin_de_dia ELSE 0 END) AS dia_14,
                                       SUM(CASE WHEN DAY(mes_dia) = 15 THEN saldo_fin_de_dia ELSE 0 END) AS dia_15,
                                       SUM(CASE WHEN DAY(mes_dia) = 16 THEN saldo_fin_de_dia ELSE 0 END) AS dia_16,
                                       SUM(CASE WHEN DAY(mes_dia) = 17 THEN saldo_fin_de_dia ELSE 0 END) AS dia_17,
                                       SUM(CASE WHEN DAY(mes_dia) = 18 THEN saldo_fin_de_dia ELSE 0 END) AS dia_18,
                                       SUM(CASE WHEN DAY(mes_dia) = 19 THEN saldo_fin_de_dia ELSE 0 END) AS dia_19,
                                       SUM(CASE WHEN DAY(mes_dia) = 20 THEN saldo_fin_de_dia ELSE 0 END) AS dia_20,
                                       SUM(CASE WHEN DAY(mes_dia) = 21 THEN saldo_fin_de_dia ELSE 0 END) AS dia_21,
                                       SUM(CASE WHEN DAY(mes_dia) = 22 THEN saldo_fin_de_dia ELSE 0 END) AS dia_22,
                                       SUM(CASE WHEN DAY(mes_dia) = 23 THEN saldo_fin_de_dia ELSE 0 END) AS dia_23,
                                       SUM(CASE WHEN DAY(mes_dia) = 24 THEN saldo_fin_de_dia ELSE 0 END) AS dia_24,
                                       SUM(CASE WHEN DAY(mes_dia) = 25 THEN saldo_fin_de_dia ELSE 0 END) AS dia_25,
                                       SUM(CASE WHEN DAY(mes_dia) = 26 THEN saldo_fin_de_dia ELSE 0 END) AS dia_26,
                                       SUM(CASE WHEN DAY(mes_dia) = 27 THEN saldo_fin_de_dia ELSE 0 END) AS dia_27,
                                       SUM(CASE WHEN DAY(mes_dia) = 28 THEN saldo_fin_de_dia ELSE 0 END) AS dia_28,
                                       SUM(CASE WHEN DAY(mes_dia) = 29 THEN saldo_fin_de_dia ELSE 0 END) AS dia_29,
                                       SUM(CASE WHEN DAY(mes_dia) = 30 THEN saldo_fin_de_dia ELSE 0 END) AS dia_30,
                                       SUM(CASE WHEN DAY(mes_dia) = 31 THEN saldo_fin_de_dia ELSE 0 END) AS dia_31
                                  INTO vsucursal,vnombre,
                                           vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                           vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                           vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                           vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                       vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31
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
                                 GROUP BY s.sucursal,u.nombre
                             ORDER BY s.sucursal ASC
                         RETURN vCodRet,vsucursal,vnombre,
                                                vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                                vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                                vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                                vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                            vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31 WITH RESUME;
                END FOREACH;
                ELSE
                        FOREACH
                                SELECT SKIP pRegistros FIRST pRecuperacion h.sucursal,
                                           u.nombre,
                                       SUM(CASE WHEN DAY(mes_dia) = 1 THEN saldo_fin_de_dia ELSE 0 END) AS dia_1, 
                                       SUM(CASE WHEN DAY(mes_dia) = 2 THEN saldo_fin_de_dia ELSE 0 END) AS dia_2,
                                       SUM(CASE WHEN DAY(mes_dia) = 3 THEN saldo_fin_de_dia ELSE 0 END) AS dia_3,
                                       SUM(CASE WHEN DAY(mes_dia) = 4 THEN saldo_fin_de_dia ELSE 0 END) AS dia_4,
                                       SUM(CASE WHEN DAY(mes_dia) = 5 THEN saldo_fin_de_dia ELSE 0 END) AS dia_5,
                                       SUM(CASE WHEN DAY(mes_dia) = 6 THEN saldo_fin_de_dia ELSE 0 END) AS dia_6,
                                       SUM(CASE WHEN DAY(mes_dia) = 7 THEN saldo_fin_de_dia ELSE 0 END) AS dia_7,
                                       SUM(CASE WHEN DAY(mes_dia) = 8 THEN saldo_fin_de_dia ELSE 0 END) AS dia_8,
                                       SUM(CASE WHEN DAY(mes_dia) = 9 THEN saldo_fin_de_dia ELSE 0 END) AS dia_9,
                                       SUM(CASE WHEN DAY(mes_dia) = 10 THEN saldo_fin_de_dia ELSE 0 END) AS dia_10,
                                       SUM(CASE WHEN DAY(mes_dia) = 11 THEN saldo_fin_de_dia ELSE 0 END) AS dia_11,
                                       SUM(CASE WHEN DAY(mes_dia) = 12 THEN saldo_fin_de_dia ELSE 0 END) AS dia_12,
                                       SUM(CASE WHEN DAY(mes_dia) = 13 THEN saldo_fin_de_dia ELSE 0 END) AS dia_13,
                                       SUM(CASE WHEN DAY(mes_dia) = 14 THEN saldo_fin_de_dia ELSE 0 END) AS dia_14,
                                       SUM(CASE WHEN DAY(mes_dia) = 15 THEN saldo_fin_de_dia ELSE 0 END) AS dia_15,
                                       SUM(CASE WHEN DAY(mes_dia) = 16 THEN saldo_fin_de_dia ELSE 0 END) AS dia_16,
                                       SUM(CASE WHEN DAY(mes_dia) = 17 THEN saldo_fin_de_dia ELSE 0 END) AS dia_17,
                                       SUM(CASE WHEN DAY(mes_dia) = 18 THEN saldo_fin_de_dia ELSE 0 END) AS dia_18,
                                       SUM(CASE WHEN DAY(mes_dia) = 19 THEN saldo_fin_de_dia ELSE 0 END) AS dia_19,
                                       SUM(CASE WHEN DAY(mes_dia) = 20 THEN saldo_fin_de_dia ELSE 0 END) AS dia_20,
                                       SUM(CASE WHEN DAY(mes_dia) = 21 THEN saldo_fin_de_dia ELSE 0 END) AS dia_21,
                                       SUM(CASE WHEN DAY(mes_dia) = 22 THEN saldo_fin_de_dia ELSE 0 END) AS dia_22,
                                       SUM(CASE WHEN DAY(mes_dia) = 23 THEN saldo_fin_de_dia ELSE 0 END) AS dia_23,
                                       SUM(CASE WHEN DAY(mes_dia) = 24 THEN saldo_fin_de_dia ELSE 0 END) AS dia_24,
                                       SUM(CASE WHEN DAY(mes_dia) = 25 THEN saldo_fin_de_dia ELSE 0 END) AS dia_25,
                                       SUM(CASE WHEN DAY(mes_dia) = 26 THEN saldo_fin_de_dia ELSE 0 END) AS dia_26,
                                       SUM(CASE WHEN DAY(mes_dia) = 27 THEN saldo_fin_de_dia ELSE 0 END) AS dia_27,
                                       SUM(CASE WHEN DAY(mes_dia) = 28 THEN saldo_fin_de_dia ELSE 0 END) AS dia_28,
                                       SUM(CASE WHEN DAY(mes_dia) = 29 THEN saldo_fin_de_dia ELSE 0 END) AS dia_29,
                                       SUM(CASE WHEN DAY(mes_dia) = 30 THEN saldo_fin_de_dia ELSE 0 END) AS dia_30,
                                       SUM(CASE WHEN DAY(mes_dia) = 31 THEN saldo_fin_de_dia ELSE 0 END) AS dia_31
                                  INTO vsucursal,vnombre,
                                           vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                           vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                           vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                           vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                       vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31
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
                                GROUP BY h.sucursal,u.nombre
                            ORDER BY h.sucursal ASC
                     RETURN vCodRet,vsucursal,vnombre,
                                    vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                            vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                            vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                            vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                        vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31 WITH RESUME;
                END FOREACH;
                END IF
        ELIF ptipo = 1 THEN
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion s.sucursal,
                                   u.nombre,
                               SUM(CASE WHEN DAY(fecha) = 1 THEN saldo_total ELSE 0 END) AS dia_1,
                               SUM(CASE WHEN DAY(fecha) = 2 THEN saldo_total ELSE 0 END) AS dia_2,
                               SUM(CASE WHEN DAY(fecha) = 3 THEN saldo_total ELSE 0 END) AS dia_3,
                               SUM(CASE WHEN DAY(fecha) = 4 THEN saldo_total ELSE 0 END) AS dia_4,
                               SUM(CASE WHEN DAY(fecha) = 5 THEN saldo_total ELSE 0 END) AS dia_5,
                               SUM(CASE WHEN DAY(fecha) = 6 THEN saldo_total ELSE 0 END) AS dia_6,
                               SUM(CASE WHEN DAY(fecha) = 7 THEN saldo_total ELSE 0 END) AS dia_7,
                               SUM(CASE WHEN DAY(fecha) = 8 THEN saldo_total ELSE 0 END) AS dia_8,
                               SUM(CASE WHEN DAY(fecha) = 9 THEN saldo_total ELSE 0 END) AS dia_9,
                               SUM(CASE WHEN DAY(fecha) = 10 THEN saldo_total ELSE 0 END) AS dia_10,
                               SUM(CASE WHEN DAY(fecha) = 11 THEN saldo_total ELSE 0 END) AS dia_11,
                               SUM(CASE WHEN DAY(fecha) = 12 THEN saldo_total ELSE 0 END) AS dia_12,
                               SUM(CASE WHEN DAY(fecha) = 13 THEN saldo_total ELSE 0 END) AS dia_13,
                               SUM(CASE WHEN DAY(fecha) = 14 THEN saldo_total ELSE 0 END) AS dia_14,
                               SUM(CASE WHEN DAY(fecha) = 15 THEN saldo_total ELSE 0 END) AS dia_15,
                               SUM(CASE WHEN DAY(fecha) = 16 THEN saldo_total ELSE 0 END) AS dia_16,
                               SUM(CASE WHEN DAY(fecha) = 17 THEN saldo_total ELSE 0 END) AS dia_17,
                               SUM(CASE WHEN DAY(fecha) = 18 THEN saldo_total ELSE 0 END) AS dia_18,
                               SUM(CASE WHEN DAY(fecha) = 19 THEN saldo_total ELSE 0 END) AS dia_19,
                               SUM(CASE WHEN DAY(fecha) = 20 THEN saldo_total ELSE 0 END) AS dia_20,
                               SUM(CASE WHEN DAY(fecha) = 21 THEN saldo_total ELSE 0 END) AS dia_21,
                               SUM(CASE WHEN DAY(fecha) = 22 THEN saldo_total ELSE 0 END) AS dia_22,
                               SUM(CASE WHEN DAY(fecha) = 23 THEN saldo_total ELSE 0 END) AS dia_23,
                               SUM(CASE WHEN DAY(fecha) = 24 THEN saldo_total ELSE 0 END) AS dia_24,
                               SUM(CASE WHEN DAY(fecha) = 25 THEN saldo_total ELSE 0 END) AS dia_25,
                               SUM(CASE WHEN DAY(fecha) = 26 THEN saldo_total ELSE 0 END) AS dia_26,
                               SUM(CASE WHEN DAY(fecha) = 27 THEN saldo_total ELSE 0 END) AS dia_27,
                               SUM(CASE WHEN DAY(fecha) = 28 THEN saldo_total ELSE 0 END) AS dia_28,
                               SUM(CASE WHEN DAY(fecha) = 29 THEN saldo_total ELSE 0 END) AS dia_29,
                               SUM(CASE WHEN DAY(fecha) = 30 THEN saldo_total ELSE 0 END) AS dia_30,
                               SUM(CASE WHEN DAY(fecha) = 31 THEN saldo_total ELSE 0 END) AS dia_31
                          INTO vsucursal,vnombre,
                                   vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                   vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                   vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                   vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                   vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31
                           FROM bdisuc:ss_saldossuc s, bdinteg:si_sucursales u 
                          WHERE s.empresa = pEmpresa
                                AND s.sucursal IS NOT NULL
                                AND s.fecha BETWEEN pFechaIni AND pFechaFin
                                AND u.sucursal = s.sucursal
                                AND u.empresa = s.empresa
                      GROUP BY s.sucursal,u.nombre
                          ORDER BY s.sucursal ASC
                 RETURN vCodRet,vsucursal,vnombre,
                                        vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                        vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                        vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                        vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                    vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31 WITH RESUME;
                END FOREACH;
        END IF
END PROCEDURE;