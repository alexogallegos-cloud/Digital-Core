create procedure "informix".respalda(pempresa char(3), pfecha_hoy date)
returning char(5);

   define cod_ret      char(5);
   define v_directorio char(50);
   define v_dia        char(2);
   define v_mes        char(2);
   define v_ano        char(4);
   define v_tabla      char(20);
   define v_tablaid    integer;
   define v_colnomb    char(20);
   define v_sql        char(200);
   define nomb_tabla   char(800);
   define v_proceso    char(10);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret         = "000";
   let v_directorio    = " ";
   let v_dia           = " ";
   let v_mes           = " ";
   let v_ano           = " ";
   let v_tabla         = " ";
   let v_tablaid       = 0;
   let v_colnomb       = " ";
   let v_sql           = " ";
   let nomb_tabla      = " ";
   let v_proceso       = "respaldo";
-- ***************************************************************************
-- Procesa Informacion
-- ***************************************************************************

   select ruta_respaldo into v_directorio
   from bdicont:co_param
   where empresa = pempresa;

   if v_directorio is null or v_directorio = " " then
      let cod_ret = "120";
      -- Actualiza control de procesos
      EXECUTE PROCEDURE contproc(pempresa,pfecha_hoy,v_proceso,cod_ret);
      return cod_ret;
   else
      let v_directorio = TRIM(v_directorio);
   end if

   let v_dia = day(pfecha_hoy);
   let v_mes = month(pfecha_hoy);
   let v_ano = year(pfecha_hoy);

   if v_dia <= 9 then
      let v_dia = "0"||v_dia;
   end if

   if v_mes <= 9 then
      let v_mes = "0"||v_mes;
   end if

   foreach
      select nombre_tabla into v_tabla
      from co_tablas

      let v_tabla = TRIM(v_tabla);

      select tabid into v_tablaid
      from systables
      where
          tabname = v_tabla;

      -- Tabla no existe en la base de datos
      if v_tablaid is null then
         let cod_ret = "121";
          -- Actualiza control de procesos
         EXECUTE PROCEDURE contproc(pempresa,pfecha_hoy,v_proceso,cod_ret);
         return cod_ret;
      end if

      let nomb_tabla = TRIM(v_directorio)||
                       "/pisa_resp/contable/"||
                       TRIM(v_tabla)||"."||
                       v_dia||v_mes||v_ano||
                       "a"||pempresa;

      let nomb_tabla = TRIM(nomb_tabla);

      select colname into v_colnomb
      from syscolumns
      where tabid = v_tablaid
      and colname = "empresa";

      if v_colnomb is null then
         let v_sql = 'echo "UNLOAD TO ' || TRIM(nomb_tabla) ||
                     ' SELECT * FROM '||TRIM(v_tabla) || '"' || ' > query.sql';
      else
         let v_sql = 'echo "UNLOAD TO ' || TRIM(nomb_tabla) ||
                     ' SELECT * FROM ' || TRIM(v_tabla) ||
                     ' WHERE empresa = ' || pempresa || '"' || ' > query.sql';
      end if

      SYSTEM v_sql;
      LET v_sql = "dbaccess bdicont query.sql ";
      SYSTEM v_sql;

   end foreach
    -- Actualiza control de procesos
   let cod_ret = TRIM(cod_ret);
      EXECUTE PROCEDURE contproc(pempresa,pfecha_hoy,v_proceso,cod_ret);
   return cod_ret;
end procedure;