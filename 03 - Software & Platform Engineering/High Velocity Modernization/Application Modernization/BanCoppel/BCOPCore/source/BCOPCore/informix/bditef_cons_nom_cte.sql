CREATE PROCEDURE "informix".cons_nom_cte(pempresa char(3),pnumcte char(20))

RETURNING char(5),char(2), char(52),char(26), char(26),char(13),char(20), date, char(3), date;

define vcodret       char(5);
define vesfisica     char(1);
define vpaterno      char(15);
define vmaterno      char(15);
define vnombre1      char(15);
define vnombre2      char(15);
define vrazon_social char(60);
define vnomcte       char(60);
define vsqlerr       integer;
define vtpo_persona  char(2);
define vrfc          char(13);
define vcurp         char(20);
define vfecha_nacimiento date;
define vnacionalidad char(3);
define vfec_alta     date;



let vnomcte = "";
let vpaterno = "";
let vmaterno = "";
let vcodret = "000";
let vrfc = "";
let vcurp = "";
let vtpo_persona = "";
let vnacionalidad = "";
let vfec_alta = "";

begin

   on exception set vsqlerr
      IF vsqlerr <> 0 then
         let vcodret = vsqlerr;
         RETURN vcodret, vtpo_persona, vnomcte, null, null, null, null, null , '', '';
      END IF
   END exception;

  -- SET DEBUG FILE TO "/tmp/cons_nom_cte.out";
  -- TRACE ON;   
   

   SELECT cliente.tpo_persona, nvl(apell_paterno," "), nvl(apell_materno," "),
          nvl(nombre1," "), nvl(nombre2," "), nvl(razon_social," "),
          cliente.rfc,tipper.es_fisica,
       CASE WHEN (es_fisica = 'S') THEN
           PerFis.Fecha_Nac
       ELSE
           PerMor.Fecha_Constitct
       END FechaNacimiento, 
       CASE WHEN (es_fisica = 'S') THEN
           PerFis.nacionalidad
       ELSE
           lpad(PerMor.nacionalidad,3,'0')::char(3)
       END nacionalidad, cliente.fecha_alta       
     INTO vtpo_persona,vpaterno,vmaterno,
          vnombre1,vnombre2,vrazon_social,
          vrfc, vesfisica, vfecha_nacimiento,
          vnacionalidad, vfec_alta     
     FROM bdinteg:si_cliente cliente,
          bdinteg:si_tipper tipper,
          OUTER bdinteg:si_ctepf PerFis,
          OUTER bdinteg:si_ctepm PerMor
    WHERE cliente.empresa = pempresa
      AND cliente.numcte = pnumcte
      AND tipper.tpo_persona = cliente.tpo_persona
      AND PerFis.NumCte = cliente.NumCte
      AND PerMor.NumCte = cliente.NumCte;

   IF vtpo_persona = "" or vtpo_persona is null then
      let vcodret = "800";
      RETURN vcodret, vtpo_persona, vnomcte, vpaterno, vmaterno, vrfc, vcurp, null, '', '';
   ELSE
      IF vesfisica <> "S" then
         let vnomcte = trim(vrazon_social);
      ELSE
         let vnomcte = trim(vnombre1)||" "||trim(vnombre2);
      END IF;
   END IF

   IF vesfisica="S" then
     SELECT nvl(curp," ")
     INTO vcurp
          FROM bdinteg:si_ctepf
          WHERE empresa = pempresa and numcte = pnumcte;
   END IF

   RETURN vcodret, vtpo_persona, vnomcte, vpaterno, vmaterno, vrfc, vcurp, vfecha_nacimiento,vnacionalidad,vfec_alta;
END
END procedure;