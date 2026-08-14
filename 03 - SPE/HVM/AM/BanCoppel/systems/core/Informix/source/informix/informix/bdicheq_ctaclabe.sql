CREATE PROCEDURE "informix".ctaclabe(pempresa char(3),
                                     pcuenta char(20),
                                     pplaza char(4))
       RETURNING char(5),CHAR(20);

DEFINE vcodret          CHAR(5);
DEFINE sqlerr           INTEGER;
DEFINE vctaclabe        CHAR(20);
DEFINE vdigverif        char(1);
DEFINE vcuenta          char(20);
define vbanco           char(3);
define vplaza           char(3);
define vplazaclabe      char(3);
define i,j,k            smallint;
define l                char(2);
define m                char(1);
define vacum            smallint;
define vlongcta         smallint;


LET vcodret    =  "000";
LET vctaclabe  = " ";

BEGIN
   ON EXCEPTION
      SET sqlerr
      LET vcodret = sqlerr;
      RETURN vcodret,vctaclabe;
   END EXCEPTION;
   
   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

   select{+ INDEX(bdinteg:si_param ix_si_param)} valor INTO vbanco
      FROM bdinteg:si_param
      WHERE empresa = pempresa and descripcion = "Banco";

   SELECT {+ INDEX(sc_plazaclabe idx_plazaclabe_trx1)} plazaclabe INTO vplazaclabe
      FROM sc_plazaclabe
      WHERE empresa = pempresa and sucursal = pplaza;

   IF vplazaclabe IS NULL OR vplazaclabe = " " THEN
      LET vplazaclabe = "XXX";
   END IF;
   LET vctaclabe = vbanco || vplazaclabe || pcuenta;
   call digverclabe(vctaclabe)
        returning vcodret, vdigverif;
   let vctaclabe = trim(vctaclabe) || vdigverif;
END;
RETURN vcodret,vctaclabe;
END PROCEDURE;