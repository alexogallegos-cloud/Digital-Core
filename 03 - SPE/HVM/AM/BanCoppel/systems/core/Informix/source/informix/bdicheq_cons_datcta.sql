CREATE PROCEDURE "informix".cons_datcta(pempresa CHAR(3),
                                        pcuenta char(20))
RETURNING CHAR(5),CHAR(18),
          CHAR(4),CHAR(4),
          CHAR(20),
          CHAR(1),CHAR(8),
          CHAR(1),SMALLINT,SMALLINT,
          CHAR(100),
          date;

DEFINE vsqlerr INTEGER;
DEFINE vcodret        CHAR(5);
DEFINE vctaclabe      CHAR(18);
DEFINE psucursal      CHAR(4);
DEFINE pproducto      CHAR(4);
DEFINE pnum_cte       CHAR(20);
DEFINE pclase_cta     CHAR(1);
DEFINE preg_firmas    CHAR(1);
DEFINE pejecutivo     CHAR(8);
DEFINE penvio_direcc  CHAR(1);
DEFINE pdirecc_envio  SMALLINT;
DEFINE pnofirmas      SMALLINT;
DEFINE vexiste        SMALLINT;
DEFINE vcombinacion   CHAR(100);
DEFINE vfecha_alta    CHAR(100);

begin
   on exception set vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret,vctaclabe,psucursal,pproducto,pnum_cte,preg_firmas,pejecutivo,
                penvio_direcc,pdirecc_envio,pnofirmas,vcombinacion,vfecha_alta;
      END IF;
   END exception;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3 ;


--     SET DEBUG FILE TO "/tmp/cons_datcta.out";
--     TRACE ON;

-- Inicializa variables
LET vcodret        = "000";
LET vctaclabe      = "";
LET psucursal      = "";
LET pproducto      = "";
LET pnum_cte       = "";
LET pclase_cta     = "";
LET preg_firmas    = "";
LET pejecutivo     = "";
LET penvio_direcc  = "";
LET pdirecc_envio  = 0;
LET vexiste        = 0;
LET pnofirmas      = 0;
LET vcombinacion   = "";
LET vfecha_alta    = "";

-- Valida la informacion de entrada
   IF pempresa       = "" OR
      pcuenta      = ""  THEN
      LET vcodret = "110";
      RETURN vcodret,vctaclabe,psucursal,pproducto,pnum_cte,preg_firmas,pejecutivo,
             penvio_direcc,pdirecc_envio,pnofirmas,vcombinacion,vfecha_alta;
   END IF;

   SELECT 1 INTO vexiste
      FROM sc_maechq WHERE empresa = pempresa AND cuenta = pcuenta;
   IF vexiste IS NULL THEN
      LET vcodret = "405";
      RETURN vcodret,vctaclabe,psucursal,pproducto,pnum_cte,preg_firmas,pejecutivo,
             penvio_direcc,pdirecc_envio,pnofirmas,vcombinacion,vfecha_alta;
   END IF;

   SELECT cuenta_clabe,sucursal,producto,num_cte,reg_firmas,ejecutivo,envio_direcc,
          direcc_envio, fecha_alta
   INTO   vctaclabe,psucursal,pproducto,pnum_cte,preg_firmas,pejecutivo,
             penvio_direcc,pdirecc_envio, vfecha_alta
   FROM   sc_maechq a, sc_maenoc b
   WHERE  a.empresa = pempresa
   AND    a.cuenta = pcuenta
   AND    b.empresa = a.empresa
   AND    b.cuenta = a.cuenta;
   -- Saca las Firmas Registradas
   SELECT count(secuencia)
   INTO   pnofirmas
   FROM   sc_firmantes
   WHERE  empresa = pempresa
   AND    cuenta = pcuenta;

   SELECT combinacion
   INTO   vcombinacion
   FROM   sc_firmantes
   WHERE  empresa = pempresa
   AND    cuenta = pcuenta
   AND    secuencia = 1;

   RETURN vcodret,vctaclabe,psucursal,pproducto,pnum_cte,preg_firmas,pejecutivo,
          penvio_direcc,pdirecc_envio,pnofirmas,vcombinacion,vfecha_alta;

END
END procedure
;