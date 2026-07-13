CREATE PROCEDURE "informix".asigna_numsolp(o_empresa CHAR(3))
RETURNING CHAR(5),CHAR(20);


-- DEFINICION DE VARIABLES
DEFINE vsqlerr INTEGER;
DEFINE vcodret CHAR(5);
DEFINE vnum_solicitud CHAR(20);
DEFINE vcuantas SMALLINT;
DEFINE vlongsol SMALLINT;
DEFINE vdivisa CHAR(2);
define vsignumsol integer;
define vdiferencia,i smallint;
define v_digito CHAR(1);

-- ASIGNACION DE VARIABLES
LET vsqlerr = 0;
LET vcodret = "00000";
LET vnum_solicitud ="???????????????";
LET v_digito ="?";
LET vcuantas = 0;

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
    --  DROP TABLE signumero;
      LET vcodret=vsqlerr;
      RETURN vcodret,vnum_solicitud;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/asigna_numsolp.out";
--TRACE ON;

-- *********** INICIA PROCESO DE ASIGNACION ******************
   select valor into vlongsol
      from   bdicred:sd_param
      where  cod_param ="8";
   let vlongsol = vlongsol -1;

   select valor into vsignumsol
      from bdicred:sd_param
      where cod_param ="6";

   if vlongsol is null or vsignumsol is null then
      let vcodret="105";
      RETURN vcodret,vnum_solicitud;
   else
      let vnum_solicitud = vsignumsol;
      let vsignumsol = vsignumsol + 1;

      update bdicred:sd_param
         set valor = vsignumsol
         where  cod_param ="6";

      let vdiferencia = vlongsol - length(vnum_solicitud) - 1;
      if vdiferencia > 0 then
         for i = 1 to vdiferencia
             let vnum_solicitud = "0" || vnum_solicitud;
         end for;
      end if
      --let vnum_solicitud = "6"||trim(vnum_solicitud);
      let vnum_solicitud = trim(vnum_solicitud);
      let vnum_solicitud = "61"||substr(vnum_solicitud,2,length(vnum_solicitud));
   end if;

   EXECUTE PROCEDURE bdicred:digvermod10(vnum_solicitud)
         INTO vcodret, v_digito;

   LET vnum_solicitud = TRIM(vnum_solicitud) || v_digito;



   RETURN vcodret, vnum_solicitud;
END
END PROCEDURE;