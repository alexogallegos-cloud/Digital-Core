create procedure "informix".sp_valida_operaciones_spei()
   returning char(5), integer, integer;

   define vcodret 		char(5);
   define vsqlerr 		integer;
   
   define vcantidad_op  integer;
   define vultopreal    integer;
   define vtotopreal	integer;
   define vdifopreal    integer;
   
 
   set lock mode to wait 10;

   let vcodret    = "00000";
   let vdifopreal = 0;
   let vcantidad_op = 0;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
		 return vcodret, vcantidad_op, vdifopreal;
      end if
   end exception;
   
   --SET DEBUG FILE TO "/ifxsif01/ash/sp_valida_operaciones_spei.out";
   --TRACE ON;
   
set isolation to dirty read;

select vchrvalor 
  into vcantidad_op
  from tblparametros
 where vchrcveparametro = 'PROMEDIO_OPERACIONES';
 
select vchrvalor 
  into vultopreal
  from tblparametros
 where vchrcveparametro = 'ULTIMA_VERIFICACION';

select count(*) into vtotopreal
from tblpago
where dtfechavalor in(select (substr(vchrvalor, 4,2))||(substr(vchrvalor, 1,2))||(substr(vchrvalor, 7,4)) 
                        from tblparametros 
						where vchrcveparametro = "FECHA_OPERACION");

let vdifopreal = vtotopreal - vultopreal;

if vdifopreal > vcantidad_op then
   let vcodret = '00001';
end if;

update tblparametros set vchrvalor = vtotopreal
 where vchrcveparametro = 'ULTIMA_VERIFICACION';
 
return vcodret, vcantidad_op, vdifopreal;

end;

end procedure;