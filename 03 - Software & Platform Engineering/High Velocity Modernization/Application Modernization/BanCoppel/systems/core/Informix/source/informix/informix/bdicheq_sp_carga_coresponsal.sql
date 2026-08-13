create procedure "informix".sp_carga_coresponsal(pempresa char(3) )
       returning char(5);

define vsqlerr integer;
define vcodret char(5);
define vfecha_hoy date;
define vconreg smallint;
define vsql char(800);
define vaniomes  CHAR(6);
define parchivo  CHAR(60);

LET vaniomes           = '';


begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = "00970";
         return vcodret;
      end if;
   end exception;

--SET DEBUG FILE TO "/resplogifx/conciliachq/respaldos/sp_carga_corresponsal.out";
--TRACE ON;

   let vcodret = "00000";
   select fecha_hoy into vfecha_hoy from sc_fechas where empresa = pempresa;

	/* FORMA NOMECLARUTA DEL NOMBRE DEL ARCHIVO */
    LET vaniomes = TO_CHAR(vfecha_hoy, '%Y%m');
    --perfil_AAAAMM.unl
	LET parchivo ='perfil_'||vaniomes||'.unl';
   
  
   
   select count(*) into vconreg from bdicheq:sc_param 
    where codparam ='ult_corresp'
	and valor = parchivo;
      
   if vconreg > 0 then
      let vcodret = "00969"; -- EL ARCHIVO QUE INTENTA CARGAR YA FUE CARGADO.
      return vcodret;
   
   else
   
	/* RESPALDA LA INFORMACION LA TABLA SC_CORRESPONSAL DE LA BDICHEQ */
	   let vsql = 'echo "unload to /resplogifx/conciliachq/respaldos/' || 'respaldo_corresponsales_'||vaniomes||'.unl' ||
					 ' select * from  bdicheq:sc_corresponsal; "' || ' > /resplogifx/conciliachq/respaldos/query_resp.sql';
	   system vsql;
	   let vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/respaldos/query_resp.sql";
	   system vsql;
	   
	/* Vacia tabla de informacino de corresponsales */
	
	--	begin;
			TRUNCATE TABLE "informix".sc_corresponsal;
	--	commit;
	   
	   
	/* CARGA LA LA INFORMACION DE CORRESPONSALES A LA TABLA SC_CORRESPONSAL DE LA BDICHEQ */
	   --let vsql = 'echo "load from /resplogifx/conciliachq/respaldos/' || trim'perfil_'(vaniomes)'.unl ||
	   let vsql = 'echo "load from /resplogifx/conciliachq/respaldos/' || 'perfil_'||vaniomes||'.unl' ||
				  ' insert into bdicheq:sc_corresponsal "' || ' > /resplogifx/conciliachq/respaldos/query_load.sql';
	   system vsql;
	   let vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/respaldos/query_load.sql";
	   system vsql;
	   
	   
	   
		begin;
		update "informix".sc_corresponsal
		set estatus ='Reprobado'
		where estatus ='No Aprobado';
		commit;

		begin;
		update "informix".sc_corresponsal
		set estatus ='No ha presentado'
		where estatus ='Pendiente';
		commit;
   
   
		UPDATE bdicheq:sc_param  set valor = parchivo
		where codparam ='ult_corresp';
	
   
   end if

   return vcodret;
end
end procedure;