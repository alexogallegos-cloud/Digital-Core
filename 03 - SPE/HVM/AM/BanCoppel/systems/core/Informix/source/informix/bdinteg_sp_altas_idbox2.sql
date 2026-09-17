CREATE PROCEDURE "informix".sp_altas_idbox2(
	pFechIni DATE, 
	pFechFin DATE,
	pRegistros INTEGER,
	pRecuperacion INTEGER)
	
RETURNING        INTEGER as CodErr, CHAR(5) as sucursal, INTEGER as Altas_Total, INTEGER as Tot_Idb

DEFINE iSqlErr                  INTEGER;
DEFINE csucural         CHAR(5);
DEFINE cAltas_Total      INTEGER;
DEFINE cTot_Idb          INTEGER;
DEFINE cTot_Sin_Idbx     INTEGER;


LEt iSqlErr           =0;
LET csucural          ='';
LET cAltas_Total      =0;
LET cTot_Idb          =0;
LET cTot_Sin_Idbx     =0;


BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                RETURN iSqlErr, csucural, cAltas_Total, cTot_Idb;
                        END IF;
                END EXCEPTION;
        
			-- Elimina tabla temporal si existe
				DROP TABLE IF EXISTS tmp_idbx;          
            --TOTAL DE ALTAS CON IDBOX
			SET ISOLATION TO DIRTY READ;
            SELECT {+INDEX (bdinteg:"informix".si_sucursales idx_sucursal2)} a.sucursal, nvl(c.total,0) as Altas_Total, nvl(b.total,0) as Tot_Idb
            FROM si_sucursales a
            LEFT JOIN(  --OBTENIENDO TODOS LOS CLIENTES TITULARES DE LA TABLA DE SI_CLIENTE EN UN RANGO DE FECHAS
                        SELECT clientes.sucursal AS sucursal, count(DISTINCT(clientes.numcte)) AS total FROM 
                            (SELECT distinct (numcte), sucursal 
                            FROM si_cliente   
                            WHERE tipo_cliente='1' AND fecha_insert BETWEEN pFechIni AND pFechFin ) clientes
                        INNER JOIN
                        --OBTENIENDO LOS DATOS DE LA BITACORA DE IDBOX
                            (SELECT numcte, sucursal 
                            FROM si_bitacora_ife
                            WHERE date(fecha) BETWEEN pFechIni AND pFechFin ) bitacora
                        ON clientes.numcte=bitacora.numcte AND clientes.sucursal=bitacora.sucursal
                        GROUP BY clientes.sucursal
                    ) b ON a.sucursal=b.sucursal
            LEFT JOIN (--OBTENIENDO ALTAS POR SUCURSAL
                        SELECT sucursal, COUNT(DISTINCT (numcte)) AS total
                                        FROM si_cliente
                                        WHERE tipo_cliente='1' AND fecha_insert BETWEEN pFechIni AND pFechFin
                        GROUP BY sucursal
                        )C ON a.sucursal=C.sucursal
            WHERE a.empresa ='001'						
            AND a.sucursal IN (SELECT DISTINCT(sucursal) FROM si_bitacora_ife)
            AND a.tpo_sucursal='S'						
            INTO temp tmp_idbx WITH NO LOG;
    
			SET ISOLATION TO DIRTY READ;
            FOREACH c1 FOR
                SELECT SKIP pRegistros FIRST pRecuperacion sucursal, Altas_Total, Tot_Idb 
                    INTO csucural, cAltas_Total, cTot_Idb
                FROM tmp_idbx
                
                RETURN iSqlErr, csucural, cAltas_Total, cTot_Idb WITH RESUME;
            END FOREACH;
END
END PROCEDURE;