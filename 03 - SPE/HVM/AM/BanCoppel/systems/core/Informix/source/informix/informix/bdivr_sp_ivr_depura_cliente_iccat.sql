CREATE PROCEDURE "informix".sp_ivr_depura_cliente_iccat(p_Periodo INT, p_Bloque INT)
RETURNING CHAR(5) AS CodRet,-- CÃDIGO DE RETORNO
          CHAR(12)AS Registros; --REGISTROS

-- DECLARACIÃN DE VARIABLES
DEFINE error_sql 			INTEGER;
DEFINE vcodret				VARCHAR(5);
DEFINE i_count 				INT;
DEFINE d_inicio 			DATE;
DEFINE v_id_row             INT;
DEFINE vregistros           INT; 

-- INICIALIZACIÃN DE VARIABLES
LET vcodret = '00000';
LET vregistros = 0;

-- SET DEBUG FILE TO "/tmp/misael/sp_ivr_depura_cliente_iccat.out";
-- TRACE ON;

BEGIN
    ON EXCEPTION SET error_sql
        IF error_sql != 0 THEN
            LET vcodret = error_sql;
            RETURN vcodret, 0;
        END IF;

        IF EXISTS(SELECT 1 FROM tmp_si_cliente_iccat) THEN
            DROP TABLE tmp_si_cliente_iccat;
        END IF;
    END EXCEPTION;
        
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    IF p_Periodo <> 0 AND p_Bloque <> 0 THEN 
    
        CREATE TEMP TABLE tmp_si_cliente_iccat (
        id serial) WITH NO LOG;
        CREATE INDEX idx_tmp_si_cliente_iccat ON tmp_si_cliente_iccat (id);

        LET d_inicio = TODAY - p_Periodo UNITS day;

        INSERT INTO tmp_si_cliente_iccat (id)
        SELECT {+INDEX(bdivr:"informix".si_cliente_iccat idx_si_cliente_iccat)} FIRST p_Bloque id 
        FROM bdivr:si_cliente_iccat
        WHERE fecha <= d_inicio;            

        IF DBINFO('sqlca.sqlerrd2') > 0 THEN
            DELETE FROM bdivr:si_cliente_iccat
            WHERE id IN (SELECT id FROM tmp_si_cliente_iccat);
        END IF;
        DROP TABLE tmp_si_cliente_iccat;

        SELECT {+INDEX(bdivr:"informix".si_cliente_iccat idx_si_cliente_iccat)} COUNT (*) 
        INTO vregistros
        FROM bdivr:si_cliente_iccat
        WHERE fecha <= d_inicio;

    ELSE
       LET vcodret = '00001'; --Falta de parametros 
    END IF;   
END;
RETURN vcodret,vregistros;
END PROCEDURE;