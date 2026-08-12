CREATE PROCEDURE "informix".sp_insert_candidatosprestamomashistorica ()
RETURNING
	CHAR(6) AS cCodRet;

    --DEFINICION DE VARIABLES DE ERROR
    DEFINE iSqlErr         INTEGER;
    DEFINE iIsamErr        INTEGER;
    DEFINE cCodRet         CHAR(6);
   
    --DEFINICION DE VARIABLES DE CONSULTA
    DEFINE v_numcte_banco   CHAR(20);
    DEFINE v_numcte_coppel  CHAR(20);
    DEFINE v_fecha_corte    DATE;

    --DECLARACION DE VARIABLES DE ERROR
    LET iSqlErr  = 0;
    LET iIsamErr = 0;
    LET cCodRet  ="000000";
   
    --DECLARACION DE VARIABLES DE CONSULTA
    LET v_numcte_banco   = "";
    LET v_numcte_coppel  = "";
    LET v_fecha_corte    = DATE(1);

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet;
       END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --SET debug file to '/home/sysifx/OscarOjeda/sp_insert_bitacorappmas.out';
    --TRACE ON; 

    FOREACH
        SELECT 	cpm.numcte_banco, cpm.numcte_coppel, cpm.fecha_corte 
        INTO 	v_numcte_banco, v_numcte_coppel, v_fecha_corte
        FROM 	bdisolic:informix.candidatosprestamomas AS cpm
        LEFT JOIN 	bdisolic:informix.candidatosprestamomashistorica AS cpmh
            ON      cpmh.numcte_banco = cpm.numcte_banco
            AND     cpmh.numcte_coppel = cpm.numcte_coppel
            AND     cpmh.fecha_corte = cpm.fecha_corte
        WHERE	cpmh.numcte_banco IS NULL
       	ORDER BY cpm.numcte_banco
       	
        -- Inserta los registros nuevos en la tabla candidatosprestamomashistorica
        INSERT INTO bdisolic:informix.candidatosprestamomashistorica (numcte_banco, numcte_coppel, fecha_corte) VALUES (v_numcte_banco, v_numcte_coppel, v_fecha_corte);
    END FOREACH;

	RETURN cCodRet; 
END
END PROCEDURE
