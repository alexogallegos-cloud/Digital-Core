CREATE PROCEDURE "informix".cteppesfamilia(pempresa CHAR(3),
                                               pfuncion CHAR(1),
                                               pnumcte CHAR(20),
                                               psecuencia CHAR(2),
                                               pnumctefamilia CHAR(20),
                                               pnombrefamilia CHAR(60),
                                               pparentesco CHAR(3),
                                               puserinsert CHAR(8),
                                               pfechainsert DATE)
  RETURNING CHAR(5),CHAR(20);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vexiste CHAR(1);
DEFINE vsecuencia INTEGER;


LET vcodret = "000";

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,pnumcte;
   END IF;
END EXCEPTION;

--- Verifica recepcion correcta de datos
IF pempresa IS NULL
   OR pnumcte IS NULL OR psecuencia IS NULL
   OR pnumctefamilia IS NULL OR pnombrefamilia IS NULL
   OR puserinsert IS NULL OR pfechainsert IS NULL THEN
   LET vcodret = "110";
   RETURN vcodret,pnumcte;
END IF;

-- ****************** Actualizacion de Parametros *****************
IF pFuncion != "A" OR pFuncion != "C" THEN
    IF pfuncion="A" THEN
        
        SELECT MAX(secuencia) INTO vsecuencia
        FROM si_ppefamilia
        WHERE empresa=pempresa and numcte=pnumcte;

        IF vsecuencia >= 4 THEN
		RETURN vcodret,pnumcte;
        END IF;

        IF vsecuencia = 0 OR vsecuencia IS NULL THEN
            LET vsecuencia = 1;
        ELSE
            LET vsecuencia = vsecuencia + 1;
        END IF;

        BEGIN
            INSERT INTO si_ppefamilia
                (empresa,numcte,secuencia,numctefamiliar,nombrefamiliar,parentesco,usuario_insert,fecha_insert)
            VALUES
                (pempresa,pnumcte,vsecuencia,pnumctefamilia,pnombrefamilia,pparentesco,puserinsert,pfechainsert);
        END;

        RETURN vcodret,pnumcte;
    ELSE
        SELECT 1 INTO vexiste FROM si_cliente
            WHERE numcte = pnumcte;
        IF vexiste IS NULL THEN
            LET vcodret="104";
            RETURN vcodret,pnumcte;
        END IF;

        IF psecuencia = 0 THEN
            LET vcodret = "188";
        ELSE
            BEGIN
                    UPDATE si_ppefamilia
                    SET
                        (numctefamiliar,nombrefamiliar)
                    =
                        (pnumctefamilia,pnombrefamilia)
                    WHERE numcte = pnumcte AND empresa = pempresa AND secuencia = psecuencia;
            END;
        END IF;
    END IF;
ELSE
    LET vcodret = "177";
END IF;
RETURN vcodret,pnumcte;
END;
END PROCEDURE

DOCUMENT
"Alta y/o Cambio de datos de los representantes legales de la persona moral ",
"AutOR : Julio Cesar Polanco Inzunza.",
"SOLICITO: Lic.Jose G. Mendoza",
"FECHA : 13/Diciembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".consapoderado(pempresa char(3),
                           pnumcte char(20))

       returning 	char(5),smallint, char(20),char(60), char(8), date;

define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;

define vsecuencia smallint;
define vnumcteapoderado char(20);
define vnombreapoderado char(60);
define vuser_insert 	char(8);
define vfecha_insert	date;



let vciclo = 0;
let vcodret = "000";
let  vsqlerr = 0;

let vsecuencia = 0;
let vnumcteapoderado = "";
let vnombreapoderado = "";
let vuser_insert = "";
let vfecha_insert = "";




begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret, vsecuencia , vnumcteapoderado, vnombreapoderado, vuser_insert, vfecha_insert;

      end if;
   end exception;

   foreach
      SELECT   secuencia, numcteapoderado ,nombreapoderado, user_insert, fecha_insert

      INTO      vsecuencia, vnumcteapoderado,vnombreapoderado, vuser_insert, vfecha_insert

      FROM si_apoderado
         WHERE numcte = pnumcte


      return    vcodret, vsecuencia, vnumcteapoderado,vnombreapoderado, vuser_insert, vfecha_insert with resume;

   end foreach;

end
end procedure
;