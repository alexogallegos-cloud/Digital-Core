create procedure "informix".sp_cargo_val_mib(pcuenta    char(20))
   returning char(5);

   define vcodret 		char(5);
   define vsqlerr 		integer;
   define vfecha_hoy    date;
   define vfecha_ant    date;
   define vretiros 		money(14,2);
   define vabonos		money(14,2);
   define vsdoactual	money(14,2);
   define vsdoinicial   money(14,2);
   define vsdoretenido  money(14,2);
   define vsdodisp      money(14,2);
   define vsdocalculado money(14,2);
   
   set isolation to cursor stability;
   set lock mode to wait 10;

   let vcodret = "000";
   let vabonos = 0;
   let vretiros = 0;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
		 return vcodret;
      end if
   end exception;
   
   --SET DEBUG FILE TO "/informix/ash/sp_cargo_val.out";
   --TRACE ON;

-- Valida la informacion de entrada
if pcuenta = '' then
   let vcodret = 110;
   return vcodret;
end if;

set isolation to dirty read;

-- // OBTIENE LAS FECHAS DEL SISTEMA
select fecha_hoy, fecha_ant
  into vfecha_hoy, vfecha_ant
  from sc_fechas;

select nvl(sum(monto_tot), 0) into vretiros
  from sc_movdia, bdinteg:si_transacc
 where cuenta = pcuenta
   and naturaleza = 'C'
   and se_contabiliza = 'S'
   and se_emite_edocta = 'S'
   and transacc = numero
   and sistema = '01'
   and fech_alt = vfecha_hoy
   and cancelad <> 'S';

select nvl(sum(monto_tot), 0) into vabonos
  from sc_movdia, bdinteg:si_transacc
 where cuenta = pcuenta
   and naturaleza = 'A'
   and se_contabiliza = 'S'
   and se_emite_edocta = 'S'
   and transacc = numero
   and sistema = '01'
   and fech_alt = vfecha_hoy
   and cancelad <> 'S';   
  
select sdo_dia_ant, sdo_actual, sdo_retenido into vsdoinicial, vsdoactual, vsdoretenido
  from sc_maechq
 where cuenta = pcuenta;
 
--let vsdodisp = vsdoactual - vsdoretenido;
let vsdodisp = vsdoactual;
let vsdocalculado = vsdoinicial + vabonos - vretiros;

if vsdocalculado <> vsdodisp then
   let vcodret = 110;
else
   let vcodret = '00000';
end if;

return vcodret;

end;

end procedure;