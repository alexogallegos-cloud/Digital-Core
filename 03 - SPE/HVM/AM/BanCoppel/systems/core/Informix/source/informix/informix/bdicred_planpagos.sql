CREATE PROCEDURE "informix".planpagos(pempresa char(3),
                            pnum_credito  CHAR(20),
                            pnum_pago     SMALLINT) -- mandan un cero y el
                                                    -- cs2 regresa de 20 en 20.

   RETURNING CHAR(05),         -- codigo de retorno
             CHAR(80),         -- clave y nombre del cliente
             DATE,             -- fecha de apertura
             DATE,             -- fecha de vencimiento
             CHAR(45),         -- nombre del producto
             MONEY(14,2),      -- monto de la cuota propios
             DATE,             -- fecha de la cuota propios
             DATE,             -- fecha de pago de la cuota propios
             CHAR(1),          -- status de la cuota propios
             CHAR(1),          -- segundo status de la cuota propios
                               --(antes recursos de la cuota)
             CHAR(30),         -- nombre de la divisa
             CHAR(54),         -- nombre del ejecutivo
             MONEY(14,2),      -- monto otorgado del credito
             MONEY(14,2),      -- monto ministrado    v_saldo_cuota
             MONEY(14,2),      -- monto capitalizado  v_imp_capitalizado
             MONEY(14,2),      -- valor actual        v_valor_actual
             MONEY(14,2),      -- monto real pagado   v_monto_real_pag
             MONEY(14,2),      -- monto interes
             CHAR(1),          -- status de la cuota de interes
             DATE,             --
             MONEY(14,2),       --
             MONEY(14,2)       -- Seguro

   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE i                   SMALLINT;
   DEFINE text                CHAR(100);
   DEFINE sqlerr,isamerr      SMALLINT;
   DEFINE v_num_credito       CHAR(20);
   DEFINE v_monto_otorgado    MONEY(14,2);
   DEFINE cod_ret             CHAR(5);
   DEFINE v_ejecutivo         LIKE sd_maecred.ejecutivo;
   DEFINE v_ciclo             SMALLINT;
   DEFINE v_conta             SMALLINT;
   DEFINE v_apell_paterno     CHAR(15);
   DEFINE v_apell_materno     CHAR(15);
   DEFINE v_divisa            LIKE sd_maecred.divisa;
   DEFINE v_divisas           LIKE bdinteg:si_divisas.descripcion;
   DEFINE v_nomejecutivo      CHAR(54);
   DEFINE v_producto          CHAR(40);
   DEFINE v_nombre1           CHAR(15);
   DEFINE v_nombre2           CHAR(15);
   DEFINE v_razon_social      CHAR(80);
   DEFINE v_cliente           CHAR(60);
   DEFINE v_descripcion       CHAR(45);
   DEFINE v_num_producto      LIKE sd_maecred.num_producto;
   DEFINE v_numcte            LIKE sd_maecred.numcte;
   DEFINE vg_cliente          CHAR(80);
   DEFINE v_fecha_apertura    LIKE sd_maecred.fecha_apertura;
   DEFINE v_fecha_vencim      LIKE sd_maecred.fecha_vencim;
   DEFINE v_monto_cuota       LIKE sd_pagocapit.monto_cuota;
   DEFINE v_monto_cuotas      LIKE sd_pagocapit.monto_cuota;
   DEFINE v_fecha_cuota       LIKE sd_pagocapit.fecha_cuota;
   DEFINE v_fecha_cuota1      LIKE sd_pagocapit.fecha_cuota;
   DEFINE v_fecha_pago        LIKE sd_pagocapit.fecha_pago;
   DEFINE v_fecha_pago1       LIKE sd_pagocapit.fecha_pago;
   DEFINE v_status_cuota      LIKE sd_pagocapit.status_cuota;
   DEFINE v_status_cuota1     LIKE sd_pagocapit.status_cuota;
   DEFINE v_cuota_rec         LIKE sd_pagocapit.cuota_rec;
   DEFINE v_cuota_recr        LIKE sd_pagocapit.cuota_rec;
   DEFINE v_monto_cuota1      LIKE sd_pagocapit.monto_cuota;
   DEFINE v_saldo_cuota       MONEY(14,2);      -- monto minis
   DEFINE v_imp_capitalizado  MONEY(14,2);      -- monto capitalizado
   DEFINE v_valor_actual      MONEY(14,2);      -- valor actual
   DEFINE v_monto_real_pag    MONEY(14,2);      -- monto real pagado
   DEFINE v_monto_interes     LIKE sd_pagocapit.monto_cuota;    -- monto de interes
   DEFINE V_status_interes    LIKE sd_pagocapit.status_cuota;   -- status interes
   DEFINE v_fecha_Pag_Int     LIKE sd_pagocapit.fecha_cuota;
   DEFINE v_int_monto_real_pag LIKE sd_pagocapit.monto_cuota;
   DEFINE v_sdo_cap_insoluto   LIKE sd_pagocapit.monto_cuota;
   DEFINE v_mto_venc_int       LIKE sd_pagocapit.monto_cuota;
   DEFINE v_total_adeudo_fecha LIKE sd_pagocapit.monto_cuota;
   DEFINE v_seguro             LIKE sd_pagocapit.monto_cuota;
   DEFINE v_monto_com          LIKE sd_pagocapit.monto_cuota;
   DEFINE v_monto_pag          LIKE sd_pagocapit.monto_cuota;


-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr
      IF sqlerr != 0 THEN
         LET cod_ret = sqlerr;
         RETURN cod_ret,          vg_cliente,      v_fecha_apertura,
                v_fecha_vencim,   v_descripcion,
                v_monto_cuota,    v_fecha_cuota,   v_fecha_pago,
                v_status_cuota,   v_cuota_rec,    v_divisas,
                v_nomejecutivo,   v_monto_otorgado,
                v_saldo_cuota,    v_imp_capitalizado, v_valor_actual,
                v_monto_real_pag, v_monto_interes, v_status_interes, v_fecha_Pag_Int,
                v_total_adeudo_fecha, v_seguro;
      END IF;
   END EXCEPTION;



   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret            = "000000";
   LET i                  = 1;
   LET v_ciclo            = 0;
   LET v_conta            = 0;
   LET v_num_credito      = " ";
   LET v_monto_otorgado   = 0;
   LET v_fecha_apertura   = " ";
   LET v_fecha_vencim     = " ";
   LET v_fecha_cuota      = " ";
   LET v_fecha_pago       = " ";
   LET v_monto_cuota      = 0.00;
   LET v_monto_cuotas     = 0.00;
   LET v_status_cuota     = " ";
   LET v_cuota_rec        = " ";
   LET v_nomejecutivo     = " ";
   LET v_ejecutivo        = " ";
   LET v_producto         = " ";
   LET vg_cliente         = " ";
   LET v_monto_cuota1     = 0;
   LET v_descripcion      = " ";
   LET v_num_producto     = " ";
   LET v_descripcion      = " ";
   LET v_divisa           = " ";
   LET v_divisas          = " ";
   LET v_monto_cuota1     = 0;
   LET v_fecha_cuota1     = " ";
   LET v_fecha_pago1      = " ";
   LET v_status_cuota1    = " ";
   LET v_monto_cuotas     = 0;
   let v_saldo_cuota      = 0;
   let v_imp_capitalizado = 0;
   let v_valor_actual     = 0;
   let v_monto_real_pag   = 0;
   let v_monto_interes    = 0;
   let v_status_interes   = 0;
   let v_fecha_Pag_Int    = " ";
   let v_int_monto_real_pag = 0;
   let v_sdo_cap_insoluto = 0;
   let v_mto_venc_int     = 0;
   let v_total_adeudo_fecha = 0;
   let v_seguro             = 0;
   let v_monto_com          = 0;
   let v_monto_pag          = 0;



   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = " " THEN
      LET cod_ret = "223"; -- NUMERO DE CREDITO NULO O BLANCO
      RETURN cod_ret,         vg_cliente,      v_fecha_apertura,
             v_fecha_vencim,  v_descripcion,
             v_monto_cuota,   v_fecha_cuota,   v_fecha_pago,
             v_status_cuota,  v_cuota_rec,     v_divisas,
             v_nomejecutivo,  v_monto_otorgado,
             v_saldo_cuota,   v_imp_capitalizado, v_valor_actual,
             v_monto_real_pag, v_monto_interes, v_status_interes, v_fecha_Pag_Int,
             v_total_adeudo_fecha, v_seguro;
   ELSE
      LET v_num_credito = pnum_credito;

      SELECT num_credito,      numcte,         num_producto,
             fecha_apertura,   fecha_vencim,   divisa,
             ejecutivo
      INTO   v_num_credito,    v_numcte,       v_num_producto,
             v_fecha_apertura, v_fecha_vencim, v_divisa,
             v_ejecutivo
      FROM sd_maecred
      WHERE empresa = pempresa and num_credito = v_num_credito;

      IF v_num_credito IS NULL OR
         v_num_credito = " " THEN
         LET cod_ret = "224"; -- NO EXISTE EL CREDITO EN sd_maecred
         RETURN cod_ret,         vg_cliente,      v_fecha_apertura,
                v_fecha_vencim,  v_descripcion,
                v_monto_cuota,   v_fecha_cuota,   v_fecha_pago,
                v_status_cuota,  v_cuota_rec,     v_divisas,
                v_nomejecutivo,  v_monto_otorgado,
                v_saldo_cuota,    v_imp_capitalizado, v_valor_actual,
                v_monto_real_pag, v_monto_interes, v_status_interes, v_fecha_Pag_Int,
                v_total_adeudo_fecha, v_seguro;

      END IF;

      IF v_numcte IS NULL OR
         v_numcte = " " THEN
         LET cod_ret = "202"; -- CLIENTE NULO O EN BLANCO EN sd_maecred
         RETURN cod_ret,         vg_cliente,      v_fecha_apertura,
                v_fecha_vencim,  v_descripcion,
                v_monto_cuota,   v_fecha_cuota,   v_fecha_pago,
                v_status_cuota,  v_cuota_rec,     v_divisas,
                v_nomejecutivo,  v_monto_otorgado,
                v_saldo_cuota,    v_imp_capitalizado, v_valor_actual,
                v_monto_real_pag, v_monto_interes, v_status_interes, v_fecha_Pag_Int,
                v_total_adeudo_fecha, v_seguro;
      ELSE
         SELECT numcte, TRIM(NVL(razon_social, " ")) ||
                TRIM(NVL(apell_paterno," ")) || " " ||
                TRIM(NVL(apell_materno,' ')) || " " ||
                TRIM(NVL(nombre1," ")) || " " ||
                TRIM(NVL(nombre2," "))
         INTO v_numcte, v_cliente
         FROM bdinteg:si_cliente
         WHERE numcte = v_numcte;
         LET vg_cliente = TRIM (v_numcte) || " " || v_cliente;
      END IF;
   END IF;

   IF v_num_producto IS NULL THEN
      LET v_num_producto = " ";
   ELSE
      SELECT nombre_prod INTO v_descripcion
      FROM sd_definicion
      WHERE empresa = pempresa and num_producto = v_num_producto;
   END IF;

   SELECT descripcion INTO v_divisas
   FROM bdinteg:si_divisas
   WHERE empresa = pempresa and divisa = v_divisa;
   IF v_divisas IS NULL THEN
      LET v_divisas = " ";
   END IF;

   SELECT nombre INTO v_nomejecutivo
   FROM bdinteg:si_ejecut
   WHERE ejecutivo = v_ejecutivo;

   IF v_nomejecutivo IS NULL THEN
      LET v_nomejecutivo = " ";
   ELSE
      LET v_nomejecutivo = TRIM (v_ejecutivo) || " " ||
         TRIM (v_nomejecutivo);
   END IF;

   SELECT monto_otorgado, sdo_cap_insoluto, mto_venc_int INTO v_monto_otorgado, v_sdo_cap_insoluto, v_mto_venc_int
   FROM sd_maesdos
   WHERE empresa = pempresa and num_credito = v_num_credito;

   IF v_monto_otorgado IS NULL THEN
      LET v_monto_otorgado = 0;
   END IF;

   IF v_sdo_cap_insoluto IS NULL THEN
      LET v_sdo_cap_insoluto = 0;
   END IF

   IF v_mto_venc_int IS NULL THEN
      LET v_mto_venc_int = 0;
   END IF

   LET v_total_adeudo_fecha = v_sdo_cap_insoluto + v_mto_venc_int;

   FOREACH
      SELECT cap.monto_cuota,  cap.fecha_cuota,
             cap.fecha_pago,   cap.status_cuota,   cap.cuota_rec,
             cap.saldo_cuota,  nvl(mora.sdo_mora_ordi,0),  cap.monto_real_pag,
             inte.monto_cuota, inte.status_cuota, inte.fecha_pag, inte.monto_real_pag
      INTO   v_monto_cuota,  v_fecha_cuota,
             v_fecha_pago, v_status_cuota, v_cuota_rec,
             v_saldo_cuota,  v_imp_capitalizado, v_monto_real_pag,
             v_monto_interes, v_status_interes, v_fecha_Pag_Int, v_int_monto_real_pag

      FROM sd_pagocapit cap, sd_paginter inte, outer sd_detmora mora
      WHERE cap.empresa = pempresa and cap.num_credito = v_num_credito
            and inte.empresa = cap.empresa and inte.num_credito = cap.num_credito
            and cap.fecha_cuota = inte.fecha_cuota
            and mora.empresa = cap.empresa and mora.num_credito = cap.num_credito
            and mora.fecha_cuota = cap.fecha_cuota
      ORDER BY 2

      IF v_fecha_cuota IS NULL THEN
         LET v_fecha_cuota = " ";
      END IF;

      IF v_fecha_pago IS NULL THEN
         LET v_fecha_pago = " ";
      END IF;

      LET v_ciclo = v_ciclo + 1;

      IF v_ciclo <= pnum_pago THEN
         CONTINUE FOREACH;
      END IF;

      IF v_monto_cuota IS NULL THEN
         LET v_monto_cuota = 0;
      END IF;
      IF v_monto_cuota1 IS NULL THEN
         LET v_monto_cuota1 = 0;
      END IF;

      LET v_monto_cuotas = v_monto_cuota + v_monto_cuota1;
      LET v_valor_actual = v_saldo_cuota - v_monto_real_pag + v_monto_interes  - v_int_monto_real_pag;
      IF vg_cliente IS NULL THEN
         LET vg_cliente = " ";
      END IF;


      SELECT Sum(sd_detcomi.monto_com) monto_com, Sum(sd_detcomi.monto_pag) monto_pag
      INTO  v_monto_com, v_monto_pag
      FROM  sd_detcomi,  sd_tpcomis
      WHERE sd_detcomi.empresa = sd_tpcomis.empresa AND
            sd_detcomi.cod_comis = sd_tpcomis.cod_comis AND
            ((sd_detcomi.num_credito=v_num_credito) AND
            (sd_tpcomis.comi_o_seg='2') AND
            (sd_detcomi.fecha_alta=v_fecha_cuota) AND (sd_detcomi.empresa=pempresa));


      IF v_monto_com IS NULL THEN
         LET v_monto_com = 0;
      END IF;

      IF v_monto_pag IS NULL THEN
         LET v_monto_pag = 0;
      END IF;

      LET v_seguro = v_monto_com - v_monto_pag;


         RETURN cod_ret,         vg_cliente,      v_fecha_apertura,
                v_fecha_vencim,  v_descripcion,
                v_monto_cuota,   v_fecha_cuota,   v_fecha_pago,
                v_status_cuota,  v_cuota_rec,     v_divisas,
                v_nomejecutivo,  v_monto_otorgado,
                v_saldo_cuota,   v_imp_capitalizado, v_valor_actual,
                v_monto_real_pag, v_monto_interes, v_status_interes,
                v_fecha_Pag_Int,  v_total_adeudo_fecha, v_seguro
      WITH RESUME;
      LET v_conta = v_conta + 1;
   END FOREACH;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

Create procedure "informix".recupera_prueba(pempresa varchar(3)
      ,pfecha_hoy date)
returning char(5);

define cod_ret      char(3);
define v_directorio char(50);
define v_dia        char(2);
define v_mes        char(2);
define v_ano        char(4);
define v_tabla      char(20);
define v_tablaid    integer;
define v_colnomb    char(20);
define v_sql        char(250);
define nomb_tabla   char(800);
define v_numcols    integer;
define lv_cuantos   smallint;
define lv_cadena    char(61);
define lv_tabla     char(30);
define i            smallint;
define j            smallint;
define v_nrows      smallint;
define lv_registro  integer;
define lv_busca     char(30);
define v_dir_hoy    varchar(100);

define v_inicializa varchar(2);

BEGIN


  -- Inicializa variables
  let cod_ret         = "00000";
  let v_directorio    = null;
  let v_dia           = null;
  let v_mes           = null;
  let v_ano           = null;
  let v_tabla         = null;
  let v_tablaid       = 0;
  let v_colnomb       = null;
  let v_sql           = null;
  let nomb_tabla      = null;
  let v_numcols       = 0;

  -- Procesa Informacion
  select valor
  into v_directorio
  from sd_param
  where empresa = pempresa
  and cod_param = '44';

  if v_directorio is null or v_directorio = " " then
    let cod_ret = "00110";
    return cod_ret;
  else
    let v_directorio = '/pisa/pisabanco/pisa_ftes/credito_alex/';
  end if

  let v_dia = lpad(day(pfecha_hoy),2,'0');
  let v_mes = lpad(month(pfecha_hoy),2,'0');
  let v_ano = lpad(year(pfecha_hoy),4,'0');

  let v_dir_hoy = 'D' || v_mes || v_dia || v_ano;

  foreach select trim(nombre_tabla), inicializa
          into v_tabla, v_inicializa
          from sd_tablas
          order by inicializa desc

    select ncols,tabid into v_numcols,v_tablaid
    from systables
    where tabname = trim(v_tabla);

    -- Tabla no existe en la base de datos
    if v_tablaid is null or v_tablaid = 0 then
      let cod_ret = "140";
      return cod_ret;
    end if

    -- Obtiene el esquema de la tabla antes de drop
    LET v_sql ="dbschema -q -d bdicred -t "|| trim(v_tabla) ||
               " -p all " || trim(v_tabla) ||
               "; sed /revoke/d " || trim(v_tabla) || " >" ||
               trim(v_tabla) || ".sql";
    SYSTEM v_sql;

    --RESPALDA LOS REGISTROS DE LAS OTRAS EMPRESAS
    --POR CADA TABLA EN UN ARCHIVO DE PASO (solo tablas con campo empresa)
    select colname into v_colnomb
    from syscolumns
    where tabid = v_tablaid
    and colname = "empresa";

    if v_colnomb is null then
    else
      LET v_sql = 'echo "UNLOAD TO ' || TRIM(V_TABLA) || '.otras' ||
                  ' SELECT * FROM ' || TRIM(v_tabla) ||
                  ' WHERE empresa != ' || pempresa || '"' || ' > query.sql';
      SYSTEM v_sql;
      LET v_sql = "dbaccess bdicred query.sql ";
      SYSTEM v_sql;
    end if

    -- Elimina la tabla por drop y crea el esquema de la misma.
--    LET v_sql ='echo "drop table bdicred:'||TRIM(v_tabla)||'" > query.sql';
--    SYSTEM v_sql;
--    LET v_sql = "dbaccess bdicred query.sql ";
--    SYSTEM v_sql;

  end foreach;

  foreach select trim(nombre_tabla), inicializa
          into v_tabla, v_inicializa
          from sd_tablas
          order by inicializa

    --crea las tablas que fueron borradas
    LET v_sql = "dbaccess bdicred " || trim(v_tabla) || ".sql 1>/dev/null 2>/dev/null";
--    system trim(v_sql);

    select ncols,tabid into v_numcols,v_tablaid
    from systables
    where tabname = v_tabla;

    select colname into v_colnomb
    from syscolumns
    where tabid = v_tablaid
    and colname = "empresa";

    --inserta datos de otras empresas
    if v_colnomb is null then
    else
      let v_sql = "echo "||'"'|| "file '" || TRIM(v_tabla) || ".otras" ||
                  "' delimiter '|' " ||
                  v_numcols || "; insert into "||TRIM(v_tabla)||
                  ";"||'"'||' > carga';
      SYSTEM v_sql;
      let v_sql = "dbload -d bdicred -c carga -l er -n 100";
      SYSTEM v_sql;
    end if
      --inserta los datos respaldados
      let v_sql = "echo "||'"'|| "file '"|| trim(v_directorio) || trim(v_dir_hoy) ||
                  "/" || TRIM(v_tabla)|| "." || v_dia || v_mes || v_ano || "a" || pempresa ||
                  "' delimiter '|' "|| v_numcols||
                  "; insert into "||TRIM(v_tabla)||";"||'"'||' > carga';
      SYSTEM v_sql;

      let v_sql = "dbload -d bdicred -c carga -l er -n 100";
--      SYSTEM v_sql;

      -- Corre UPDATE STATISTICS a cada tabla cargada a nivel medio
      LET v_sql ='echo "update statistics medium for table bdicred:'||
                 TRIM(v_tabla)||'" > query.sql';
      SYSTEM v_sql;
      LET v_sql = "dbaccess bdicred query.sql ";
--      SYSTEM v_sql;

  end foreach;
{
  --crea las vistas que estan declaradas en bdicred, no estan en bdinteg
  create view sd_movconta_view
      (empresa, fecha_mov, num_producto, sistema
      ,transacc, monto, cuantos) as
    select x0.empresa ,x0.fecha_mov ,x0.num_producto
          ,'06' ,x1.transacc ,sum(x0.monto ),count(*)
    from sd_movdia x0 ,sd_transfun x1
    where ((((x1.empresa = x0.empresa )
          AND (x1.codigo_fun = x0.codigo_fun ))
          AND (x1.codigo_ref = x0.codigo_ref ))
          AND (x0.reversado = 'N' ) )
    group by x0.empresa,x0.fecha_mov,x0.num_producto,x1.transacc;
}
  return cod_ret;
END;
end procedure;