create procedure "informix".cargainstacash()
       returning char(5);

   define vcodret char(20);
   define vrowid, vsqlerr integer;
   define vsucursal char(4);    
   define vusuario char(8);  
   define vtransacc char(4);       
   define vtransuc char(4);
   define vfoliosuc char(16);
   define vnum_credito char(20);
   define vmonto money(16,2);
   define vdivisa char(02);      
   define vreferencia char(49);
   define vfecha_hoy date; 
   define vsaldo money(16,2);    


   let vcodret  = "000";

begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

   select fecha_hoy into vfecha_hoy
      from sd_fechas
      where empresa = "001";

	begin work;
   foreach
      select rowid,sucursal,usuario,transacc,transuc,foliosuc,num_credito,
             monto,divisa,referencia
         into vrowid,vsucursal,vusuario,vtransacc,vtransuc,vfoliosuc,
              vnum_credito,vmonto,vdivisa,vreferencia
         from sd_instacash
         where aplicado <> "S"	

      call cargoref_td(vsucursal,vusuario,vtransacc,vtransuc,vfoliosuc,
                       vnum_credito,vmonto,vdivisa,vreferencia)
           returning vcodret,vtransacc,vfecha_hoy,vsaldo,vmonto;

      if vcodret = "00000" then
         update sd_instacash
            set codret = vcodret,
                aplicado = "S"
            where rowid = vrowid;
      else
         update sd_instacash
            set codret = vcodret,
                aplicado = "N"
            where rowid = vrowid;
      end if
   end foreach
	commit work;
   let vcodret = "000";
   return vcodret;
end
end procedure;