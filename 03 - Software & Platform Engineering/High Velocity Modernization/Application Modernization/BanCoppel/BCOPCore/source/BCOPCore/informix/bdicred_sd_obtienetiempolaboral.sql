CREATE PROCEDURE "informix".sd_obtienetiempolaboral(pnumcredito CHAR(20))
RETURNING CHAR(5),VARCHAR(80),VARCHAR(80);

--------------------------------------------------------------
--ACTIVIDAD:Obtiene el tiempo de ocupacion actual y anterior
--del cliente.
--------------------------------------------------------------

DEFINE    chrcodret             CHAR(5);
DEFINE    intcodret             INTEGER;
DEFINE    intcontador           SMALLINT;
DEFINE    vchrtiempotrabact     VARCHAR(80);
DEFINE    vchrtiempotrabant     VARCHAR(80);
DEFINE    vchrrespuesta         VARCHAR(80);

--DEBUG FLAG
--SET debug file to "/tmp/sd_obtienetiempolaboral.out";
--TRACE ON;

set isolation to dirty read;

BEGIN

    ON EXCEPTION SET intcodret
        IF intcodret <> 0 THEN
            LET chrcodret=intcodret;
            RETURN chrcodret,vchrtiempotrabact,vchrtiempotrabant;
		END IF;
    END EXCEPTION;

    LET    chrcodret            ="000";
    LET    intcontador          =0;
    LET    intcodret            =0;
    LET    vchrtiempotrabact    ="";
    LET    vchrtiempotrabant    ="";
    LET    vchrrespuesta        ="";

    FOREACH
            SELECT FIRST 1 TRIM(c.descripcion) INTO vchrrespuesta
            FROM bdisolic:ss_scoring_grupo a, bdisolic:ss_detalle_scoring b, bdisolic:ss_scoring_element c
            WHERE a.empresa = '001' AND a.seccion = '2' AND a.grupo IN(8,9)
            AND b.num_solicitud = pnumcredito AND b.tpo_persona = '01'
            AND a.empresa = b.empresa AND a.seccion = b.seccion
            AND a.seccion = c.seccion AND a.grupo = b.grupo
            AND a.grupo = c.grupo AND b.elemento = c.elemento
            AND b.tpo_persona = c.tpo_persona
            ORDER BY b.seccion, b.grupo, b.elemento

            IF intcontador = 0 THEN
                LET intcontador = 1;
                LET vchrtiempotrabact = vchrrespuesta;
            ELSE
                LET intcontador = 0;
                LET vchrtiempotrabant = vchrrespuesta;
            END IF;
    END FOREACH;

RETURN chrcodret,vchrtiempotrabact,vchrtiempotrabant;
END;

END PROCEDURE;