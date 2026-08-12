create procedure "informix".extcartconsumo(pempresa char(3))
       returning char(5),char(20),money(14,2),money(14,2),money(14,2),
                 money(14,2),char(1),smallint,smallint,char(2);

define vcodret char(5);
define vnum_credito char(20);
define vcapitalvig money(14,2);
define vinteresvig money(14,2);
define vcapitalven money(14,2);
define vinteresven money(14,2);
define vperiodicidad char(1);
define vplazo smallint;
define vcuotasvenc smallint;
define vcalif_riesgo char(2);
define vtipcred char(2);
define vfechaini Date;
define vfechafin Date;
define vtotal_dias smallint;


	
let vcodret = "000";
let vtotal_dias = 0;
let vcuotasvenc = 0;


   select fecha_hoy 
     into vfechafin  
     from bdicred:sd_fechas
    where empresa = pempresa;



foreach
   select a.num_credito,sdo_capital,sdo_no_exig, sdo_cap_insoluto,sdo_intereses,
          a.periodo_plazo,plazo,
          calificacion_riesgo
      into vnum_credito,vcapitalvig,vinteresvig,vcapitalven,vinteresven,
           vperiodicidad,vplazo,vcalif_riesgo
      from sd_maecred a, sd_maesdos b, sd_definicion c, sd_tipcred d, sd_tipocredito e
      where a.empresa = pempresa and 
            a.num_credito = b.num_credito and
            c.num_producto = a.num_producto and
            c.cod_tipcred = d.cod_tipcred and
            d.tipocredito = e.tipocredito and
            e.tipocredito = "01" and
            a.status_cred <> "CC" and
            b.sdo_cap_insoluto > 0
  


	let vnum_credito = vnum_credito;
	let vinteresven = 0;


   select fecha_vencto
     into vfechaini
      from sd_maecredanexo
      where empresa = pempresa and num_credito = vnum_credito;

    if not vfechaini is null then	

       let vcuotasvenc = ((Year(vfechafin) - Year(vfechaini)) * 12) + Month(vfechafin) - Month(vfechaini);


       if vcuotasvenc is null then
         let vcuotasvenc = 0;
       end if


       if vcuotasvenc < 0 then
         let vcuotasvenc = 0;
       end if


       select vfechafin - fecha_vencto
         into vtotal_dias
         from sd_maecredanexo
        where empresa = pempresa and num_credito = vnum_credito;

  --    if vtotal_dias >= 180 then
  --    end if
    else
       let vcuotasvenc = 0;
    end if


   return vcodret,vnum_credito,vcapitalvig,vinteresvig,vcapitalven,
          vinteresven,vperiodicidad,vplazo,vcuotasvenc,vcalif_riesgo
          with resume;
end foreach
end procedure;