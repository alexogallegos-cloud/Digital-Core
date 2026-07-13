create procedure "informix".gencomtran(pempresa char(3),
                           pcuenta    char(20),
                           ptransacc  char(4),
                           pfolsuc    char(16),
                           pmonto     money(14,2),
                           psucursal  char(4),
                           pusuario   char(8))
       returning char(5);

define vsqlerr integer;
define vcodret char(5);
define vfecha_hoy date;
define vcomision char(4);
define vforma_aplica char(1);
define vmonto_aplica money(14,2);
define vfactor_aplica decimal(9,6);
define vrangos char(1);
define vrango_min money(14,2);
define vrango_max money(14,2);
define vcodigo_param char(2);
define vejecuta_spl char(1);
define voperador char(1);
define vnombrespl char(20);
define vvalorspl money(14,2);
define vcalcula_com char(1);
define vmonto_com money(14,2);
define vestado char(1);
define vsuccta char(4);
define vproducto char(4);
define vsdo_actual money(14,2);
define vtrancarref,vtranaboref char(4);
define vhorax datetime hour to fraction(3);


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if
 end exception;

   let vcodret = "000";

   select fecha_hoy into vfecha_hoy
      from sc_fechas where empresa = pempresa;

   foreach
      select tc.comision,forma_aplica,monto_aplica,factor_aplica,rangos,
             rango_min,rango_max,campo,operador
         into vcomision,vforma_aplica,vmonto_aplica,vfactor_aplica,vrangos,
              vrango_min,vrango_max,vcodigo_param,voperador
         from sc_transcomis tc, sc_comisiones co
         where tc.empresa = pempresa and
               tc.transacc = ptransacc and
               tc.empresa = co.empresa and
               tc.comision = co.comision and
               forma_cargo = "05"

      select ejecuta_spl,nombrespl
         into vejecuta_spl,vnombrespl
         from sc_paramcomis
         where empresa = pempresa and codigo_param = vcodigo_param and
               tipo_param = "D";
      if vejecuta_spl = "S" then
         call vnombrespl(pempresa,pcuenta) returning vcodret,vvalorspl;
         if vcodret <> "000" then
            return vcodret;
         end if
      else
         let vvalorspl = 1;
      end if
      if vrangos = "S" then
         if vvalorspl >= vrango_min and vvalorspl <= vrango_max then
            let vcalcula_com = "1";
            if voperador = "*" then
               let vvalorspl = vvalorspl - vrango_min + 1;
            end if
         else
            let vcalcula_com = "0";
         end if
      else
         let vcalcula_com = "1";
      end if

      if vcalcula_com = "1" then
         if vforma_aplica = "1" then -- comision por monto
            if voperador = "*" then
               let vmonto_com = vmonto_aplica * vvalorspl;
            else
               let vmonto_com = vmonto_aplica;
            end if
         else -- comision por porcentaje
            let vmonto_com = vvalorspl * vfactor_aplica / 100;
         end if
         if vmonto_com > 0 then
            insert into sc_detcomis
                values(pempresa,pcuenta,vcomision,vmonto_com,0,vfecha_hoy,
                       "","P",pfolsuc);
            update sc_maechq
               set com_pendiente = com_pendiente + vmonto_com
               where empresa = pempresa and cuenta = pcuenta;
         end if
      end if
   end foreach
return vcodret;
end
end procedure
DOCUMENT
"Genera comisiones por transaccion",
"Realizado Por Procesamiento Interactivo",
"Ver 1.0 10/Marzo/2003";

create procedure "informix".conscuentas(pempresa char(3), pNumCte char(20))

        returning char(5), char(20);

        DEFINE v_cod_ret char(5);
        DEFINE v_ciclo smallint;
        DEFINE v_cuenta char (20);
        DEFINE v_fcuenta char (20);


        LET v_cod_ret  = "000";
        LET v_ciclo    = 0;
        LET v_cuenta   = "";
        LET v_fcuenta  = "";


                foreach

                select
                                cuenta
                into
                                v_cuenta
                from

                                bdicheq:sc_firmantes
                where
                                empresa = pempresa and
                                numcte = pNumCte

                                if not v_cuenta is null then
                                        LET v_ciclo = v_ciclo + 1;

                                        return v_cod_ret, v_cuenta with resume;
                                end if

                end foreach;


        if  v_ciclo = 0 then
                return "101", "";
        end if

end procedure
;