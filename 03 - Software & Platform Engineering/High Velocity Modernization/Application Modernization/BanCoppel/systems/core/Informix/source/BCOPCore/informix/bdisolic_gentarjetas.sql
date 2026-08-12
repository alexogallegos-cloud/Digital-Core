create procedure "informix".gentarjetas()
       returning char(5),char(20),char(20),char(80);

define vcodret char(5);
define vnumcte char(20);
define vnum_solicitud char(20);
define vnum_credito char(20);
define vfecha_hoy date;
define vmensaje char(80);
define vfecha_vencim date;


select fecha_hoy into vfecha_hoy
   from bdicred:sd_fechas;
let vfecha_vencim = vfecha_hoy + 2 units year;
let vcodret = "000";
let vmensaje = " ";

foreach
   select numcte into vnumcte
      from bdinteg:si_cliente
   call bdisolic:asigna_numsol('001','410',vnumcte,'victorlp')
        returning vcodret,vnum_solicitud;
   if vcodret <> "00000" then
      return vcodret,vnumcte,vnum_solicitud,vmensaje;
   end if
   update bdisolic:ss_solicitudes
      set status_solicitud = "AC",
          cod_funcion = "001",
          regional = "001",
          plaza = "001",
          sucursal = "0001",
          tipo_solicitud = "I",
          monto_solicitado = 15000,
          plazo = 36, 
          periodo_plazo = "M",
          tipo_calculo = "01",
          cod_tasa_base = "INSTACAS",
          sobretasa = 0,
          factor_sobretasa = "+",
          tasa_interes = 12,
          tasa_fija_o_var = "1",
          dia_para_revisar = 0,
          tasa_mora_adic = 3,
          cod_tasa_mora = "MORA4",
          sobretasa_mora = 0,
          tasa_moratorios = 4,
          factor_moratorio = "+",
          periodo_pag_cap = "2",
          periodo_pag_int = "3",
          gracia_cap = 0,
          diferimiento_int = 0,
          tp_gen_planpago = 2,
          individualizable = "N",
          fecha_apert_prop = "05/01/2006",
          fecha_venc_prop = "05/01/2009",
          ajuste_de_cuota = "N",
          cuota_con_dec = "S",
          sobretasa_piso = 0,
          factor_piso = "+",
          sobretasa_techo = 0,
          factor_techo = "+",
          porc_rec_prop = 100
      where empresa = "001" and num_solicitud = vnum_solicitud;
   insert into bdisolic:ss_maecontrato
      values("001",vnum_solicitud,"","",vfecha_vencim,vnumcte,15000,0,
             "","N","01","N","","C","00","","","I","informix",current);

   call bdicred:apercred_uno ('001',vnum_solicitud,vfecha_hoy, 
                              vfecha_vencim)
        returning vcodret,vmensaje;
   if vcodret <> "00000" then
      return vcodret,vnumcte,vnum_solicitud,vmensaje;
   end if
   update bdicred:sd_maecred
      set bandera_ministra = "M"
      where empresa = "001" and num_credito = vnum_solicitud;
   update bdisolic:ss_maecontrato
      set estado_contrato = "C"
      where empresa = "001" and num_contrato = vnum_solicitud;
   update bdisolic:ss_solicitudes
      set status_solicitud = "AP"
      where empresa = "001" and num_solicitud = vnum_solicitud;
end foreach
return vcodret,vnumcte,vnum_solicitud,vmensaje;
end procedure;