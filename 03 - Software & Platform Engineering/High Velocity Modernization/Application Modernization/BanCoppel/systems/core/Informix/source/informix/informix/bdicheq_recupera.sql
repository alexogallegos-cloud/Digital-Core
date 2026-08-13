create procedure "informix".recupera(pempresa char(3),
                                     pfecha  date,
                                     ptipo_resp char(1))
       returning char(5);
--       returning char(250);

   define vcodret     char(5);
   define vsqlerr     integer;
   define vdirectorio char(50);
   define vdia        char(2);
   define vmes        char(2);
   define vano        char(4);
   define vtabla      char(20);
   define vnumcols    smallint;
   define vsql        char(200);
   define vnomtabla   char(800);
   define vproceso    char(10);
   define vruta       char(400);
   define vexiste     char(1);
   define vtabid      integer;


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

-- Inicializa variables
   let vcodret = "000";

-- Procesa Informacion
   if ptipo_resp = "A" or ptipo_resp = "a" then
      let vruta = "/cheques/a_cierre/";
      let vproceso = "respacie";
   else
      let vruta = "/cheques/d_cierre/";
      let vproceso = "respdcie";
   end if
   let vruta = trim(vruta)||"empresa"||pempresa||"/";
   select valor into vdirectorio
      from sc_param
      where empresa = pempresa and codparam = "rutaresp";

   if vdirectorio is null or vdirectorio = " " then
      let vcodret = "960";
      return vcodret;
   else
      let vdirectorio = TRIM(vdirectorio);
   end if

   let vdia = day(pfecha);
   let vmes = month(pfecha);
   let vano = year(pfecha);

   if vdia <= 9 then
      let vdia = "0"||vdia;
   end if

   if vmes <= 9 then
      let vmes = "0"||vmes;
   end if
   let vruta = TRIM(vdirectorio)||TRIM(vruta)||vdia||vmes||vano;
   foreach
      select nombre_tabla into vtabla
         from sc_tablas
         let vtabla = TRIM(vtabla);
      select ncols,tabid into vnumcols,vtabid
         from systables
         where tabname = vtabla;

      -- Tabla no existe en la base de datos
      if vnumcols is null then
         let vcodret = "961";
         return vcodret;
      end if

      -- Verifica si existe empresa en la tabla
      select 1 into vexiste
         from syscolumns
         where tabid = vtabid and colname = "empresa";
      if vexiste = "1" then
         let vsql = 'echo "unload to paso'||
                    ' select * from '||trim(vtabla)||
                    ' where empresa != '||pempresa||'"'||
                    ' > query.sql';
         system vsql;
         let vsql = "dbaccess bdicheq query.sql";
         system vsql;
      end if

      -- Obtiene el esquema de la tabla antes del drop
      let vsql = "dbschema -q -d bdicheq -t "||trim(vtabla)||
                 " -p all tabla;"||
                 " sed /revoke/d tabla >"||
                 " tabla.sql";
      system vsql;

      -- Elimina la tabla por drop y crea el esquema de la misma.
      let vsql = 'echo "drop table bdicheq:'||TRIM(vtabla)||
                 '" > query.sql';
      system vsql;

      let vsql = "dbaccess bdicheq query.sql ";
      system vsql;

      let vsql = "dbaccess bdicheq tabla"||
                 " 2>/dev/null > /dev/null";
      system vsql;

      let vnomtabla = TRIM(vruta)||"/"||TRIM(vtabla)||"."||
                      vdia||vmes||vano;
      let vnomtabla = TRIM(vnomtabla);

      --- Carga el respaldo de las otras empresas
      let vsql = "echo " || '"' || "file 'paso'"||
                 " delimiter '|' "||
                 vnumcols || "; insert into " ||
                 TRIM(vtabla) || ";" || '"' || ' > carga';
      system vsql;

      let vsql = "dbload -d bdicheq -c carga -l er -n 100";
      system vsql;

      --- Carga el respaldo de la empresa solicitada
      let vsql = "echo " || '"' || "file '" || TRIM(vnomtabla) ||
                  "' delimiter '|' " || vnumcols || "; insert into " ||
                  TRIM(vtabla) || ";" || '"' || ' > carga';
      system vsql;

      let vsql = "dbload -d bdicheq -c carga -l er -n 100";
      system vsql;

      -- update statistics a cada tabla cargada
      let vsql ='echo "update statistics medium for table bdicheq:'||
                 TRIM(vtabla)||'" > query.sql';
      system vsql;
      let vsql = "dbaccess bdicheq query.sql ";
      system vsql;
   end foreach
   if ptipo_resp = "A" then
      delete from sx_contproc
         where fecha = pfecha and proceso <> "fecha" and sistema = "01";
   end if

   return vcodret;
end
end procedure;