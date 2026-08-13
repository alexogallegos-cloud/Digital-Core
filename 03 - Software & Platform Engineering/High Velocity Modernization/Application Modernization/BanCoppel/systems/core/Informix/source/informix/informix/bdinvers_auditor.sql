create procedure "informix".auditor(pempresa char(3))
       returning char(5);

   define vc_tipo_cuenta char(1);
   define vsqlerr     integer;
   define vcodret     char(5);
   define vcodretg    char(5);
   define vempresa    char(3);
   define vccmayor    char(10);
   define vccsub      char(10);
   define vccsubsub   char(10);
   define vccssubsub  char(10);
   define vccsssubsub char(10);
   define vsector     char(10);
   define vauxiliar   char(9);
   define vproducto   char(4);
   define vtransacc   char(4);
   define vmonto_tot  money(14,2);
   define vexiste     char(1);

   let vcodretg = "000";



begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodretg = vsqlerr;
         return vcodretg;
      end if;
   end exception;

   delete from sv_auditerr where empresa = pempresa;
   foreach
      select empresa,mayor,sub,subsub,ssubsub,sssubsub,sector,auxiliar,
            producto,transacc,sum(monto_tot)
         into vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
              vsector,vauxiliar,vproducto,vtransacc,vmonto_tot
         from aux_auditerr
         where empresa = pempresa
         group by 1,2,3,4,5,6,7,8,9,10
         order by 1,2,3,4,5,6,7,8,9,10

      -- Valida la cuenta contable contra el catalogo contable
      select tipo_cuenta into vc_tipo_cuenta
         from bdinteg:si_catalog
         where empresa    = vempresa     and
               ccmayor    = vccmayor     and
	       ccsub      = vccsub       and
	       ccsubsub   = vccsubsub    and
	       ccssubsub  = vccssubsub   and
	       ccsssubsub = vccsssubsub  and
	       sector     = vsector;
      if vc_tipo_cuenta is null then
         let vcodretg = "964";
	 let vcodret  = "601";
         insert into sv_auditerr
            values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
               vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
         continue foreach;
      end if
      -- Valida la cuenta no sea de Encabezado o Totalizador
      if vc_tipo_cuenta = "E" or vc_tipo_cuenta = "T" then
         let vcodretg = "964";
	 let vcodret  = "602";
         insert into sv_auditerr
            values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
               vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
         continue foreach;
      end if
      -- Valida el numero de auxiliar
      if vc_tipo_cuenta = "A" then  -- and vauxiliar > "0" then
         select 1 into vexiste
            from bdicont:co_auxiliar
            where numero   = vauxiliar;
         if vexiste is null then
            let vcodretg = "964";
	    let vcodret  = "603";
            insert into sv_auditerr
               values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
                  vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
            continue foreach;
         end if
      end if
   end foreach
   return vcodretg;
end
end procedure;