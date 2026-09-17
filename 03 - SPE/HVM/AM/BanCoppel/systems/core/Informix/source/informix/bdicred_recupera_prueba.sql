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