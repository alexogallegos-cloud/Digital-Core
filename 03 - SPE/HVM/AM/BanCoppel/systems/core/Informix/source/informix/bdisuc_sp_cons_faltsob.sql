CREATE PROCEDURE "informix".sp_cons_faltsob(pempresa CHAR(3),
                                            pfolio   CHAR(8))

RETURNING CHAR(5),CHAR(30),CHAR(30),CHAR(4),MONEY(14,2),CHAR(2);

DEFINE vcodret           CHAR(5);
DEFINE vsqlerr,visamerr  INTEGER;
DEFINE vcod_trans        CHAR(4);
DEFINE vmotiv_afecta     CHAR(2);
DEFINE vsucursal	     CHAR(4);
DEFINE vmonto		     MONEY(14,2);
DEFINE vdescripcion      CHAR(30);
DEFINE vdescmotivo       CHAR(30);
DEFINE vtpo_afecta       CHAR(2);
DEFINE vmov_aplicado     SMALLINT;

LET vcodret    = "000";
LET vcod_trans = "";
LET vsucursal  = "";
LET vmonto      = 0;
LET vdescripcion = "";
LET vdescmotivo = "";
LET vtpo_afecta = "";
LET vmov_aplicado = 0;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ; 

BEGIN

    ON EXCEPTION SET vsqlerr,visamerr
       IF vsqlerr != 0 THEN
          LET vcodret=vsqlerr;
          RETURN vcodret,vdescripcion,vdescmotivo,vsucursal,vmonto,vtpo_afecta;
       END IF;
    END EXCEPTION;

    --SET debug file to "/tmp/sp_cons_faltsob.out";
    --trace on;

    --- Verifica recepcion correcta de datos
    IF pempresa = '0' OR pempresa = '' OR pfolio = '0' OR pfolio = '' THEN
       LET vcodret = "110";
    ELSE
        IF EXISTS(select 1 from ss_operaciones where folio_oper = pfolio) THEN

            SELECT cod_trans,motiv_afecta,sucursal,monto,mov_aplicado
            INTO vcod_trans,vmotiv_afecta,vsucursal,vmonto,vmov_aplicado
            FROM bdisuc:"informix".ss_operaciones
            WHERE folio_oper = pfolio;

            IF vmov_aplicado = 1 THEN
                LET vcodret = 109;
			END IF;

            IF vmotiv_afecta IS NULL OR vmotiv_afecta ='' OR vcod_trans NOT IN ('0038','0039') THEN
                LET vcodret = "108";
            ELSE
                SELECT descripcion 
                  INTO vdescripcion
                  FROM bdisuc:"informix".ss_param_cajagen
                 WHERE codigo = vcod_trans;

                SELECT codigo||" "||descripcion,tpo_afecta 
                  INTO vdescmotivo, vtpo_afecta
                  FROM bdisuc:"informix".ss_motiv_afecta
                 WHERE codigo = vmotiv_afecta
				   AND tpo_afecta <> '';
            END IF;
        ELSE
            LET vcodret = "100";
        END IF

        RETURN vcodret,vdescripcion,vdescmotivo,vsucursal,vmonto,vtpo_afecta;

    END IF;
END;
END PROCEDURE;