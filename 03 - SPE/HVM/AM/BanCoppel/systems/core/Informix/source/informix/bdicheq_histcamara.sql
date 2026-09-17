create procedure "informix".histcamara(pempresa char(3),
                                       pfecha_hoy date,
                                       pfecha_ant date)
   returning char(5);

   define vcodret     char(5);
   define vsqlerr     integer;
   define vdirectorio char(50);
   define varchivo    char(20);
   define vdia        char(2);
   define vmes        char(2);
   define vanio       char(4);
   define vtabla      char(20);
   define vtablaid    integer;
   define vsql        char(200);
   define vnomtabla   char(800);
   define vnumcols    integer;
   define vtotreg     smallint;
   define vnumreg     smallint;
   define vcheque     char(10);
   define vbanco      char(3);
   define vcuenta_obco char(20);
   define vnum_cheq   integer;
   define vcausa_dev  char(2);



begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = "992";
         return vcodret;
      end if;
   end exception;

   let vcodret     = "000";
   let vdirectorio = " ";
   let vdia        = " ";
   let vmes        = " ";
   let vanio       = " ";
   let vtabla      = " ";
   let vtablaid    = 0;
   let vsql        = " ";
   let vnomtabla   = " ";
   let vnumcols    = 0;
   let vcheque     = "9999999999";
   let vbanco      = "999";

   select valor into vdirectorio
      from sc_param
      where empresa = pempresa and codparam = "rutaimport";

   if vdirectorio is null or vdirectorio = " " then
      let vcodret = "990";
      return vcodret;
   else
      let vdirectorio = TRIM(vdirectorio);
   end if

   let vdia = day(pfecha_ant);
   let vmes = month(pfecha_ant);
   let vanio = year(pfecha_ant);
   if vdia <= 9 then
      let vdia = "0"||vdia;
   end if
   if vmes <= 9 then
      let vmes = "0"||vmes;
   end if

   let varchivo = "cn."||vdia||vmes||vanio;
   let vnomtabla = trim(vdirectorio)||trim(varchivo);
   let vtabla = "sc_histcamara";

   select importe into vtotreg
      from sc_histcamara
      where empresa = pempresa and bco_emisor = vbanco and
            nro_cuenta = varchivo and  nro_cheque = vcheque;
   if vtotreg > 0 then
      let vcodret = "989";
      return vcodret;
   end if

   select ncols into vnumcols
      from systables
      where tabname = vtabla;
   if vnumcols is null then
      let vcodret = "991";
      return vcodret;
   end if

   let vsql = "echo "||'"'|| "file '"||TRIM(vnomtabla)||
              "' delimiter '|' "||vnumcols||
              "; insert into "||TRIM(vtabla)||";"||'"'||' > carga';
   system vsql;

   let vsql = "dbload -d bdicheq -c carga -l dbload.err -n 100";
   system vsql;

   select importe into vtotreg
      from sc_histcamara
      where empresa = pempresa and bco_emisor = vbanco and 
            nro_cuenta = varchivo and nro_cheque = vcheque;

   if vtotreg is null or vtotreg = 0 then
      let vcodret = "992";
      return vcodret;
   end if

   select count(*) into vnumreg
      from sc_histcamara
      where empresa = pempresa and fecha_trans = pfecha_ant;

   if vtotreg  <> vnumreg - 1 then
      drop index "informix".idx_histcmra2;
      drop index "informix".idx_histcmra3;
      delete from sc_histcamara
         where empresa = pempresa and fecha_trans = pfecha_ant;
      drop index "informix".idx_histcmra1;
      create index "informix".idx_histcmra1 on 
             "informix".sc_histcamara (empresa,fecha_trans);
      create index "informix".idx_histcmra2 on 
             "informix".sc_histcamara(nro_cuenta,nro_cheque,bco_emisor);
      create index "informix".idx_histcmra3 on 
             "informix".sc_histcamara(nro_cuenta,nro_cheque);
      let vcodret = "993";
      return vcodret;
   end if
   --- Actualiza devoluciones de otros bancos
   foreach
      select banco,cuenta_obco,num_cheq,causa_dev
         into vbanco,vcuenta_obco,vnum_cheq,vcausa_dev
         from sc_devotrobcog
         where empresa = pempresa and fecha_alta = pfecha_hoy
      update sc_histcamara
         set motivo_dev = vcausa_dev
         where empresa = pempresa and nro_cuenta = vcuenta_obco  and
               nro_cheque = vnum_cheq and
               banco = vbanco;
   end foreach

   return vcodret;
end
end procedure;