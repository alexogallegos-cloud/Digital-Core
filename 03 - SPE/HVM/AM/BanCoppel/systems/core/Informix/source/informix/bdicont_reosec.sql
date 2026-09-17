create procedure "informix".reosec(
             detsector   char(2),
             detsucursal char(4),
             detciudad   char(3),
             detmayor    char(10),
             detsub1     char(10),
             detsub2     char(10),
             detsub3     char(10),
             detsub4     char(10),
             de1sector char(10),
             vg_empresa  char(3)
                       )
returning char(5);
DEFINE catccmayor     char(10);
DEFINE catccsub       char(10);
DEFINE catccsubsub    char(10);
DEFINE catccssubsub   char(10);
DEFINE catccsssubsub  char(10);
DEFINE catsector      char(10);
DEFINE catnaturaleza  char(1);
DEFINE catauxiliar    char(1);
DEFINE catmoneda      char(1);
DEFINE auxmoneda      char(02);
DEFINE auxciudad      char(3);
DEFINE auxsucursal    char(4);
DEFINE auxauxiliar    char(9);
DEFINE auxsaldo       money(17,2);
DEFINE wconpol,wconpolco2 smallint;
DEFINE poliusuario              char(8);
DEFINE policontrol_poliza       smallint;
DEFINE polifecha_captura        date;
DEFINE polisecuencia            integer;
DEFINE poliempresa              char(3);
DEFINE policcmayor              char(10);
DEFINE policcsub                char(10);
DEFINE policcsubsub             char(10);
DEFINE policcssubsub            char(10);
DEFINE policcsssubsub           char(10);
DEFINE polisector               char(10);
DEFINE policiudad               char(3);
DEFINE polisucursal             char(4);
DEFINE polinro_auxiliar         char(12);
DEFINE polinaturaleza           char(1);
DEFINE polimonto                money(18,2);
DEFINE polidescripcion          char(30);
DEFINE polifecha_valida         date;
DEFINE polimoneda               char(2);
DEFINE polivalor_cambio         money(12,7);
DEFINE polivdivcambio          money(12,7);
DEFINE polimca_aplic            char(1);
DEFINE polipolizausuario        char(8);
DEFINE politipo_mov             char(1);
DEFINE pol1usuario              char(8);
DEFINE pol1control_poliza       smallint;
DEFINE pol1fecha_captura        date;
DEFINE pol1secuencia            integer;
DEFINE pol1empresa              char(3);
DEFINE pol1ccmayor              char(10);
DEFINE pol1ccsub                char(10);
DEFINE pol1ccsubsub             char(10);
DEFINE pol1ccssubsub            char(10);
DEFINE pol1ccsssubsub           char(10);
DEFINE pol1sector               char(10);
DEFINE pol1ciudad               char(3);
DEFINE pol1sucursal             char(4);
DEFINE pol1nro_auxiliar         char(12);
DEFINE pol1naturaleza           char(1);
DEFINE pol1monto                money(18,2);
DEFINE pol1descripcion          char(30);
DEFINE pol1fecha_valida         date;
DEFINE pol1moneda               char(2);
DEFINE pol1valor_cambio         money(12,7);
DEFINE pol1vdivcambio           money(12,7);
DEFINE pol1mca_aplic            char(1);
DEFINE pol1polizausuario       char(8);
DEFINE pol1tipo_mov             char(1);
DEFINE fecha_w      date;
DEFINE wmoneda           char(2);
DEFINE wsaldo               money(17,2);
DEFINE wsaldoinic           money(17,2);
DEFINE v_monaux char(2);
DEFINE v_mult smallint;
DEFINE codret char(5);
DEFINE sql_err,isam_err integer;
LET codret = "100";
   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let codret = sql_err;
            rollback work;
            return codret;
         end if;
      end exception;
begin work;
 -- Obtiene el numero de poliza por asignar e inicializa aquellas
 -- variables que permaneceran constantes
       select fecha_hoy into fecha_w
        from co_fechas where empresa = vg_empresa;
       select max(a.control_poliza)
       into wconpol
       from co_detpol a
       where a.usuario = USER
       and a.fecha_captura = fecha_w;
       select max(a.control_poliza)
       into wconpolco2
       from co_poliza a
       where a.usuario = USER
       and a.fecha_captura = fecha_w;
       if (wconpol is null) then
          let wconpol = 0;
       end if;
       if (wconpolco2 is null) then
          let wconpolco2 = 0;
       end if
       if (wconpol < wconpolco2) then
          let wconpol = wconpolco2;
       end if;
       let policontrol_poliza = wconpol;
       let policontrol_poliza = policontrol_poliza + 1;
       let pol1control_poliza = policontrol_poliza ;
   select ejecutivo into poliusuario
     from bdinteg:si_ejecut
      where ejecutivo = USER;
--inicializa variables
   let pol1usuario = poliusuario;
   let polifecha_captura = fecha_w;
   let pol1fecha_captura = fecha_w;
   let polisecuencia = 1;
   let pol1secuencia = 2;
   let poliempresa = vg_empresa;
   let pol1empresa = vg_empresa;
   let polidescripcion = "reubicacion de sectores ";
   let pol1descripcion = "reubicacion de sectores  ";
   let polifecha_valida = fecha_w;
   let pol1fecha_valida = fecha_w;
   let polivalor_cambio = 0;
   let pol1valor_cambio = 0;
   let polivdivcambio = 0;
   let pol1vdivcambio = 0;
   let polimca_aplic = " ";
   let pol1mca_aplic = " ";
   let polipolizausuario = pol1usuario;
   let pol1polizausuario = pol1usuario;
   let pol1tipo_mov = " ";
   let politipo_mov = " ";
   let polisector = detsector;
   let pol1sector = de1sector;
-- busqueda de cuentas contables
foreach
       select ccmayor, ccsub, ccsubsub,
       ccssubsub, ccsssubsub, sector,naturaleza_cta,
       auxiliar,moneda
       into catccmayor, catccsub, catccsubsub,
       catccssubsub, catccsssubsub, catsector,catnaturaleza,
       catauxiliar,catmoneda
       from bdinteg:si_catalog
       where empresa =vg_empresa
       and tipo_cuenta ="D"
       and ccmayor matches detmayor
       and ccsub matches detsub1
       and ccsubsub matches detsub2
       and ccssubsub matches detsub3
       and ccsssubsub matches detsub4
       and sector  matches detsector
      order by 1,2,3,4,5,6

       let policcmayor = catccmayor;
       let policcsub = catccsub;
       let policcsubsub = catccsubsub;
       let policcssubsub = catccssubsub;
       let policcsssubsub = catccsssubsub;
       let pol1ccmayor = catccmayor;
       let pol1ccsub = catccsub;
       let pol1ccsubsub = catccsubsub;
       let pol1ccssubsub = catccssubsub;
       let pol1ccsssubsub = catccsssubsub;
-- comenzamos ciclo de poliza
       if catauxiliar = "N" then
         let wsaldoinic = 0;
         let wmoneda = "0" ||catmoneda;
         let wsaldo = 0;
         let polinro_auxiliar = "";
         let pol1nro_auxiliar = "";
         foreach
           select moneda,ciudad,sucursal,
              sum(saldo_fin_de_dia)
            into auxmoneda,auxciudad,auxsucursal,
              auxsaldo
            from co_sdodias
            where empresa = vg_empresa
                     and ccmayor = catccmayor
                     and ccsub = catccsub
                     and ccsubsub = catccsubsub
                     and ccssubsub = catccssubsub
                     and ccsssubsub = catccsssubsub
                     and sector = catsector
                     and ciudad matches detciudad
                     and sucursal matches detsucursal
                     and mes_dia = fecha_w
                 group by  1,2,3 order by  1,2,3
           let polisucursal = auxsucursal;
           let pol1sucursal = auxsucursal;
           let pol1moneda = auxmoneda;
           let polimoneda = auxmoneda;
           let policiudad = auxciudad;
           let pol1ciudad = auxciudad;

           if (auxsaldo <> 0) then
              if (catnaturaleza = "D") then
                if auxsaldo > 0 then
                   let polinaturaleza = "C";
                   let pol1naturaleza = "D";
                 else
                   let auxsaldo = auxsaldo * (-1);
                   let polinaturaleza = "D";
                   let pol1naturaleza = "C";
                 end if
              else
                if auxsaldo < 0 then
                   let auxsaldo = auxsaldo * (-1);
                   let polinaturaleza = "C";
                   let pol1naturaleza = "D";
                 else
                   let polinaturaleza = "D";
                   let pol1naturaleza = "C";
                 end if
              end if
              let polimonto = auxsaldo;
              let pol1monto = auxsaldo;
              let codret = "000";
              insert into co_detpol values (
                 poliusuario, policontrol_poliza, polifecha_captura,
                 polisecuencia, poliempresa, policcmayor, policcsub,
                 policcsubsub, policcssubsub, policcsssubsub, polisector,
                 policiudad, polisucursal, polinro_auxiliar, polinaturaleza,
                 polimonto, polidescripcion, polifecha_valida, polimoneda,
                 polivalor_cambio, polivdivcambio, polimca_aplic,
                 polipolizausuario, politipo_mov);
              let polisecuencia = polisecuencia + 2;
              insert into co_detpol values (
                 pol1usuario, pol1control_poliza, pol1fecha_captura,
                 pol1secuencia, pol1empresa, pol1ccmayor, pol1ccsub,
                 pol1ccsubsub, pol1ccssubsub, pol1ccsssubsub, pol1sector,
                 pol1ciudad, pol1sucursal, pol1nro_auxiliar, pol1naturaleza,
                 pol1monto, pol1descripcion, pol1fecha_valida, pol1moneda,
                 pol1valor_cambio, pol1vdivcambio, pol1mca_aplic,
                 pol1polizausuario, pol1tipo_mov);
              let pol1secuencia = pol1secuencia + 2;
           end if
        end foreach
       else
         let wsaldoinic = 0;
         let wmoneda = "0" ||catmoneda;
         let wsaldo = 0;
         foreach
           select moneda,ciudad,sucursal,auxiliar,
              sum(saldo_fin_de_dia)
            into auxmoneda,auxciudad,auxsucursal,auxauxiliar,
              auxsaldo
            from co_diasaux
            where empresa = vg_empresa
                     and ccmayor = catccmayor
                     and ccsub = catccsub
                     and ccsubsub = catccsubsub
                     and ccssubsub = catccssubsub
                     and ccsssubsub = catccsssubsub
                     and sector = catsector
                     and ciudad matches detciudad
                     and sucursal matches detsucursal
                     and mes_dia = fecha_w
                 group by  1,2,3,4 order by  1,2,3
           let polinro_auxiliar = auxauxiliar;
           let pol1nro_auxiliar = auxauxiliar;
           let polisucursal = auxsucursal;
           let pol1sucursal = auxsucursal;
           let polimoneda = auxmoneda;
           let pol1moneda = auxmoneda;
           let policiudad = auxciudad;
           let pol1ciudad = auxciudad;

           if (auxsaldo <> 0) then
              if (catnaturaleza = "D") then
                if auxsaldo > 0 then
                   let polinaturaleza = "C";
                   let pol1naturaleza = "D";
                 else
                   let auxsaldo = auxsaldo * (-1);
                   let polinaturaleza = "D";
                   let pol1naturaleza = "C";
                 end if
              else
                if auxsaldo < 0 then
                   let auxsaldo = auxsaldo * (-1);
                   let polinaturaleza = "C";
                   let pol1naturaleza = "D";
                 else
                   let polinaturaleza = "D";
                   let pol1naturaleza = "C";
                 end if
              end if
              let polimonto = auxsaldo;
              let pol1monto = auxsaldo;
              let codret = "000";
              insert into co_detpol values (
                 poliusuario, policontrol_poliza, polifecha_captura,
                 polisecuencia, poliempresa, policcmayor, policcsub,
                 policcsubsub, policcssubsub, policcsssubsub, polisector,
                 policiudad, polisucursal, polinro_auxiliar, polinaturaleza,
                 polimonto, polidescripcion, polifecha_valida, polimoneda,
                 polivalor_cambio, polivdivcambio, polimca_aplic,
                 polipolizausuario, politipo_mov);
              let polisecuencia = polisecuencia + 2;
              insert into co_detpol values (
                 pol1usuario, pol1control_poliza, pol1fecha_captura,
                 pol1secuencia, pol1empresa, pol1ccmayor, pol1ccsub,
                 pol1ccsubsub, pol1ccssubsub, pol1ccsssubsub, pol1sector,
                 pol1ciudad, pol1sucursal, pol1nro_auxiliar, pol1naturaleza,
                 pol1monto, pol1descripcion, pol1fecha_valida, pol1moneda,
                 pol1valor_cambio, pol1vdivcambio, pol1mca_aplic,
                 pol1polizausuario, pol1tipo_mov);
              let pol1secuencia = pol1secuencia + 2;
           end if
        end foreach
       end if
   end foreach
  let v_mult = 1;
  foreach
     select distinct moneda into v_monaux from co_detpol
     where usuario = poliusuario
         and control_poliza = policontrol_poliza
          and fecha_captura = polifecha_captura
     update co_detpol
     set control_poliza = control_poliza * v_mult
          where usuario = poliusuario
          and control_poliza = policontrol_poliza
          and fecha_captura = polifecha_captura
          and moneda = v_monaux;
     insert into  co_poliza
     select empresa,usuario, control_poliza ,fecha_captura,
          sum(monto),sum(monto),sum(monto),moneda,descripcion_det
          from co_detpol
          where usuario = poliusuario
          and control_poliza = (policontrol_poliza * v_mult)
          and fecha_captura = polifecha_captura
          and moneda = v_monaux
          and naturaleza = "D"
          and empresa = vg_empresa
          group by 1,2,3,4,8,9 ;
      let v_mult = v_mult +1;
   end foreach;
commit work;
return codret;
end
end procedure;