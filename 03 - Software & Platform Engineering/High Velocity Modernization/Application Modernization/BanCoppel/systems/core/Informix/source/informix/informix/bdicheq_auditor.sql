CREATE PROCEDURE "informix".auditor(pempresa char(3))
       returning char(5);

   DEFINE vc_tipo_cuenta char(1);
   DEFINE vsqlerr     integer;
   DEFINE vcodret     VARCHAR(5);
   DEFINE vcodretg    VARCHAR(5);
   DEFINE vempresa    char(3);
   DEFINE vccmayor    VARCHAR(10);
   DEFINE vccsub      VARCHAR(10);
   DEFINE vccsubsub   VARCHAR(10);
   DEFINE vccssubsub  VARCHAR(10);
   DEFINE vccsssubsub VARCHAR(10);
   DEFINE vsector     VARCHAR(10);
   DEFINE vauxiliar   VARCHAR(9);
   DEFINE vproducto   VARCHAR(4);
   DEFINE vtransacc   VARCHAR(4);
   DEFINE vmonto_tot  money(14,2);
   DEFINE vexiste     char(1);
   DEFINE vcomienza1  SMALLINT;
   DEFINE ven_transacc1 SMALLINT;
   DEFINE vconta        INTEGER;
   
   LET vcomienza1 	  = -1;
   LET ven_transacc1  = 0;
   LET vconta         = 0;
   LET vcodretg = "000";


begin
   
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodretg = vsqlerr;
         return vcodretg;
      end if;
   end exception;

	--Se cambia por un Truncate, ya que el filtro hace borrado de todos los registros.
   /*delete {+INDEX(sc_auditerr idx_auditerr1)} from sc_auditerr
      where empresa = pempresa;*/
	  	
	Truncate table bdicheq:sc_auditerr;
	
   /*foreach --Exiten 13994770
	  --Se quita Directiva
      --select {+INDEX(aux_auditerr idx_aux_auditerr)} 
	  select empresa,mayor,sub,subsub,ssubsub,
	     sssubsub,sector,auxiliar,producto,transacc,
		 sum(monto_tot)
        into vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vauxiliar,vproducto,vtransacc,vmonto_tot
         from bdicheq:aux_auditerr
         where empresa = pempresa
         group by 1,2,3,4,5,6,7,8,9,10
         order by 1,2,3,4,5,6,7,8,9,10

      -- Valida la cuenta contable contra el catalogo contable
      select tipo_cuenta 
	     into vc_tipo_cuenta
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
         insert into sc_auditerr
            values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
               vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
         continue foreach;
      end if
      -- Valida la cuenta no sea de Encabezado o Totalizador
      if vc_tipo_cuenta = "E" or vc_tipo_cuenta = "T" then
         let vcodretg = "964";
	 let vcodret  = "602";
         insert into sc_auditerr
            values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
               vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
         continue foreach;
      end if
      -- Valida el numero de auxiliar
      if vc_tipo_cuenta = "A" then  -- and vauxiliar > "0" then
         select 1 into vexiste
            from bdicont:co_auxiliar
            where empresa = pempresa and numero   = vauxiliar;
         if vexiste is null then
            let vcodretg = "964";
	    let vcodret  = "603";
            insert into sc_auditerr
               values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
                  vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
            continue foreach;
         end if
      end if
   end foreach;*/
   
	--Exiten 13,994,770 de registros
	--Se genera FOREACH con 'Commits'
    FOREACH cursor_auditor WITH HOLD FOR
	  --Se quita Directiva
	  --select {+INDEX(aux_auditerr idx_aux_auditerr)} 
	  select empresa,mayor,sub,subsub,ssubsub,
		 sssubsub,sector,auxiliar,producto,transacc,
		 sum(monto_tot)
		 into vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,
		 vccsssubsub,vsector,vauxiliar,vproducto,vtransacc,
		 vmonto_tot
		 from bdicheq:aux_auditerr
		 where empresa = pempresa
		 group by 1,2,3,4,5,6,7,8,9,10
		 order by 1,2,3,4,5,6,7,8,9,10

	  -- Valida la cuenta contable contra el catalogo contable
	  select tipo_cuenta 
		 into vc_tipo_cuenta
		 from bdinteg:si_catalog
		 where empresa    = vempresa     and
			   ccmayor    = vccmayor     and
			   ccsub      = vccsub       and
			   ccsubsub   = vccsubsub    and
			   ccssubsub  = vccssubsub   and
			   ccsssubsub = vccsssubsub  and
			   sector     = vsector;
			   
			   
	  -- Abre la transaccion
	   IF (vcomienza1 = -1) THEN
		  LET vcomienza1 = 0;
		  LET ven_transacc1 = 1;
		  BEGIN WORK;
	   END IF;
			   
	  if vc_tipo_cuenta is null then
		 let vcodretg = "964";
		 let vcodret  = "601";
		 insert into sc_auditerr
			values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
			   vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
		 continue foreach;
	  end if
	  -- Valida la cuenta no sea de Encabezado o Totalizador
	  if vc_tipo_cuenta = "E" or vc_tipo_cuenta = "T" then
		 let vcodretg = "964";
	 let vcodret  = "602";
		 insert into bdicheq:sc_auditerr
			values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
			   vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
		 continue foreach;
	  end if
	  -- Valida el numero de auxiliar
	  if vc_tipo_cuenta = "A" then  -- and vauxiliar > "0" then
		 select 1 into vexiste
			from bdicont:co_auxiliar
			where empresa = pempresa and numero   = vauxiliar;
		 if vexiste is null then
			let vcodretg = "964";
		let vcodret  = "603";
			insert into bdicheq:sc_auditerr
			   values(vempresa,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
				  vsector,vauxiliar,vproducto,vtransacc,vcodret,vmonto_tot);
			continue foreach;
		 end if
	  end if
	  
	  LET vconta = vconta + 1;

	   --Commit cada 10000 registros
	   IF (vconta >= 10000) THEN
		  LET vconta = 0;
		  COMMIT WORK;
		  BEGIN WORK;
	   END IF;
	  
    END FOREACH;
   
	   IF (ven_transacc1 = 1) THEN
		  LET ven_transacc1 = 0;
		  COMMIT WORK;
	   END IF;
   
   
   return vcodretg;
end
end procedure;