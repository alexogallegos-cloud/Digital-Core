CREATE PROCEDURE "informix".gen_min(v_credito  char(20),
                                    p_band smallint)

returning
char(5),        -- Codigo de retorno
char(20),       -- Num. Credito
char(20),       -- Num. Cliente
char(4),        -- cod_linea
char(3),        -- codigo_ins
char(4),        -- cod_inversion
char(5),        -- cod_agricola
char(2),        -- divisa
char(2),        -- cod_tipcred
smallint,       -- Numero de ministracion
decimal(14,2),  -- Monto de la ministracion
date,           -- Fecha de la ministracion
char(1),        -- status_ministra
date,           -- fecha_vencim
smallint;       -- contador

-- Definicion de variables

define sqlerr,isamerr   SMALLINT;
define text             char(100);
define cod_ret          char(05);
define v_numcte         char(20);    -- Num. Cliente
define v_cod_linea      char(4);     -- cod_linea
define v_codigo_ins     char(3);     -- codigo_ins
define v_cod_inversion  char(4);     -- cod_inversion
define v_cod_agricola   char(5);     -- cod_agricola
define v_divisa         char(4);     -- divisa
define v_cod_tipcred    char(2);     -- cod_tipcred
define j                smallint;    -- Numero de la ministracion
define v_monto          money(14,2); -- Monto  de la ministracion
define v_fecha          date;        -- fecha  de la ministracion
define v_status         char(1);     -- status_ministra
define v_fecha_vencim   date;        -- fecha_vencim
define i                smallint;    -- Contador


-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr, text
      LET cod_ret = sqlerr;
      SET DEBUG FILE TO "gen_min.err";
      TRACE sqlerr || " * " || isamerr || " * " || text;

      RETURN cod_ret,v_credito,v_numcte,v_cod_linea,v_codigo_ins,
             v_cod_inversion,v_cod_agricola,v_divisa, v_cod_tipcred,
             j,v_monto,v_fecha,v_status, v_fecha_vencim,i;

   END EXCEPTION;




  --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret          = "000";
   let v_numcte         = " ";
   let v_cod_linea      = " ";
   let v_codigo_ins     = " ";
   let v_cod_inversion  = " ";
   let v_cod_agricola   = " ";
   let v_divisa         = " ";
   let v_cod_tipcred    = " ";
   let j                = 0;
   LET v_fecha          = " ";
   let v_monto          = 0;
   let v_status         = " ";
   let v_fecha_vencim   = " ";
   let i                = 0;


   -- Inicio de Transaccion

   IF v_credito IS NULL OR v_credito = " " THEN
      LET cod_ret = "201"; -- solicitud nula o en blanco.
      RETURN cod_ret,v_credito,v_numcte,v_cod_linea,v_codigo_ins,
             v_cod_inversion,v_cod_agricola,v_divisa, v_cod_tipcred,
             j,v_monto,v_fecha,v_status, v_fecha_vencim,i;
   END IF;

   let i = 0;
   SELECT count(*) INTO i FROM sd_maecred WHERE num_credito = v_credito;
   IF i IS NULL OR i = 0 THEN
      LET cod_ret = "242"; -- credito no existe
      RETURN cod_ret,v_credito,v_numcte,v_cod_linea,v_codigo_ins,
             v_cod_inversion,v_cod_agricola,v_divisa, v_cod_tipcred,
             j,v_monto,v_fecha,v_status, v_fecha_vencim,i;
   END IF;


   select numcte,cod_linea,codigo_ins,cod_inversion,
          cod_agricola,divisa,fecha_vencim
     into v_numcte,v_cod_linea,v_codigo_ins,v_cod_inversion,
          v_cod_agricola,v_divisa,v_fecha_vencim
     FROM sd_maecred WHERE num_credito = v_credito;

   select cod_tipcred into v_cod_tipcred from sd_maecred a, sd_definicion b
    where a.num_credito = v_credito
      and a.num_producto = b.num_producto;

   SELECT count(*) INTO i FROM sd_detminis WHERE num_credito = v_credito;

   -- Ciclo para recuperar registros de sd_detminis

   FOREACH
      SELECT num_minis, monto_otorgado, fecha_programada, status_ministra
        into j,v_monto,v_fecha,v_status
        FROM sd_detminis
       WHERE num_credito = v_credito
       ORDER BY 1

      RETURN cod_ret,v_credito,v_numcte,v_cod_linea,v_codigo_ins,
             v_cod_inversion,v_cod_agricola,v_divisa, v_cod_tipcred,
             j,v_monto,v_fecha,v_status, v_fecha_vencim,i with resume;

   END FOREACH

END PROCEDURE;