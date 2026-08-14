CREATE PROCEDURE "informix".ctasbloq_309(pempresa char(3))

RETURNING CHAR(5);

    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vcuenta		CHAR(20);
    DEFINE vsql			CHAR(100);

    LET vcodret = "000";

    BEGIN

    ON EXCEPTION
        SET sql_err
        IF sql_err <> 0 THEN
 	    LET vcodret = sql_err;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "./ctasbloq_309.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    CREATE TABLE ctas_309(
	empresa              char(3),
	cuenta               char(20),
	tipo_mov             char(1),
	motivo               char(2),
	opcion               integer,
	importe              money(16,2),
	usuario              char(8),
	fecha                date,
	hora                 datetime hour to fraction(3),
	clave                char(5),
	status_blo           char(1),
	folio_suc            char(16),
	referencia           char(20));
    CREATE INDEX idx_ctas ON ctas_309 (cuenta) USING BTREE FILLFACTOR 99;
   
    FOREACH
	SELECT UNIQUE cuenta
	  INTO vcuenta
	  FROM sc_histbloq
	 WHERE cuenta IN(select cuenta from sc_maechq
                          where status_cta = "3" and motivo = "09")
	   AND cuenta NOT IN(select cuenta from cuentas)
           AND status_blo = "B"
	   AND tipo_mov = "B"
           AND empresa = pempresa
	   AND motivo = "09"

        INSERT INTO ctas_309
	SELECT *
	  FROM sc_histbloq
	 WHERE cuenta = vcuenta
	   AND status_blo = "B"
	   AND tipo_mov = "B"
           AND empresa = pempresa
           AND fecha = (SELECT MAX(fecha) FROM sc_histbloq WHERE cuenta = vcuenta)
	   AND hora = (SELECT MAX(hora) FROM sc_histbloq WHERE cuenta = vcuenta);

    END FOREACH;

    LET vsql = "";
    LET vsql = 'echo "UNLOAD TO ctasbloq_309.unl SELECT * FROM ctas_309 WHERE cuenta IS NOT NULL" > ctas_309.sql';
    SYSTEM vsql;
 
    LET vsql = "";
    LET vsql = "dbaccess bdicheq ctas_309.sql";
    -- LET vsql = "/ifxsif01/bin/dbaccess bdicheq cargos.sql";
    SYSTEM vsql;
    LET vsql = "";

    END;

    DROP TABLE ctas_309;
 
    RETURN vcodret;

END PROCEDURE;