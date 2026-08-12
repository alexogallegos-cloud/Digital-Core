create procedure "informix".auditbancoppel(pempresa char(3))
returning char(5);


define vcodret         char(5);
define vnum_credito    char(20);
define vsqlerr         Integer;
define vmonto_vencido  money(14,2);
define vsdo_cap        money(14,2);

define vSdoCapIns         money(14,2);
define vSdoCap            money(14,2);
define vMtoVevTrap        money(14,2);
define vCapTraspNoVenc    money(14,2);
define vMtoFinan          money(14,2);
define vSdoCapInsH        money(14,2);
define vSdoCapH           money(14,2);
define vMtoVencH          money(14,2);
define vMtoVevTrapH       money(14,2);
define vCapTraspNoVencH   money(14,2);
define vMtoFinanH         money(14,2);
define vDifMtoFinan       money(14,2);
define vDifMtoVenc        money(14,2);
define vFecVenci          date;

-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

  --set debug file to "audita.out";
  --trace on;



  let vnum_credito    = "";
  let vcodret         = "000";
  let vmonto_vencido  = 0;
  let vsdo_cap        = 0;
  let vFecVenci       ='';
  let vSdoCapIns       =0;
  let vSdoCap          =0;
  let vMtoVevTrap      =0;
  let vCapTraspNoVenc  =0;
  let vMtoFinan        =0;
  let vSdoCapInsH      =0;
  let vSdoCapH         =0;
  let vMtoVencH        =0;
  let vMtoVevTrapH     =0;
  let vCapTraspNoVencH =0;
  let vMtoFinanH       =0;
  let vDifMtoFinan     =0;
  let vDifMtoVenc      =0;

--Creditos Vigentes Cuadra saldos capitales y inicializa vencidos

foreach
  select  a.num_credito into vnum_credito
    from  sd_maecred a,sd_maesdos b
   where  a.empresa = b.empresa and a.num_credito = b.num_credito
     and  sdo_capital != sdo_cap_insoluto
     and  a.status_cred = "AA"

   update sd_maesdos set sdo_capital = sdo_cap_insoluto,
       monto_vencido = 0,mto_venc_trasp = 0,cap_tras_no_venci = 0,
       sdo_moratorio = 0 where empresa = "001" and num_credito = vnum_credito;

end foreach

  FOREACH
       SELECT num_credito,sdo_cap_insoluto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,monto_financiado
       INTO vnum_credito,vSdoCapIns,vSdoCap,vmonto_vencido,vMtoVevTrap,vCapTraspNoVenc,vMtoFinan
       FROM sd_maesdos
       WHERE num_credito in (SELECT num_credito FROM sd_maecred WHERE status_cred='BA') and empresa = pempresa

       SELECT num_credito,sdo_cap_insoluto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,monto_financiado
       INTO vnum_credito,vSdoCapInsH,vSdoCapH,vMtoVencH,vMtoVevTrapH,vCapTraspNoVencH,vMtoFinanH
       FROM sd_maesdoshist
       WHERE fecha = '04/20/2008' and empresa = pempresa and num_credito = vnum_credito;

       IF vMtoFinan <= 0 THEN
             UPDATE sd_maesdos set sdo_capital      =  sdo_capital + vmonto_vencido,
                                   monto_vencido    = 0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
             CONTINUE FOREACH;
      END IF;

       let vDifMtoFinan  = vMtoFinanH -vMtoFinan ;
       IF vmonto_vencido > 0 THEN
          let vDifMtoVenc = vMtoVencH - vDifMtoFinan;
          IF vDifMtoVenc > 0 THEN
             let vSdoCap        = vSdoCap + (vmonto_vencido - vDifMtoVenc);
             let vmonto_vencido = vDifMtoVenc;
             UPDATE sd_maesdos set sdo_capital = vSdoCap,
                                   monto_vencido = vmonto_vencido
            WHERE num_credito = vnum_credito and empresa = pempresa;
          ELIF vDifMtoVenc <= 0 THEN
             let vSdoCap        = vSdoCap + vmonto_vencido;
             UPDATE sd_maesdos set sdo_capital = vSdoCap,
                                   monto_vencido = 0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
          END IF;
        ELSE
             let vSdoCap        = vSdoCap + vmonto_vencido;
             UPDATE sd_maesdos set sdo_capital = vSdoCap,
                                   monto_vencido = 0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
        END IF;
   END FOREACH

  FOREACH
       SELECT num_credito,sdo_cap_insoluto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,monto_financiado
       INTO vnum_credito,vSdoCapIns,vSdoCap,vmonto_vencido,vMtoVevTrap,vCapTraspNoVenc,vMtoFinan
       FROM sd_maesdos
       WHERE num_credito in (SELECT num_credito FROM sd_maecred WHERE status_cred='BT') and empresa = pempresa

       SELECT num_credito,sdo_cap_insoluto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,monto_financiado
       INTO vnum_credito,vSdoCapInsH,vSdoCapH,vMtoVencH,vMtoVevTrapH,vCapTraspNoVencH,vMtoFinanH
       FROM sd_maesdoshist
       WHERE fecha = '04/20/2008' and empresa = pempresa and num_credito = vnum_credito;

       IF vMtoFinan <= 0 THEN
             UPDATE sd_maesdos set sdo_capital      =  vCapTraspNoVenc + vMtoVevTrap,
                                   monto_vencido    = 0,
                                   mto_venc_trasp   = 0,
                                   cap_tras_no_venci=0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
             CONTINUE FOREACH;
      END IF;

       let vDifMtoFinan  = vMtoFinanH -vMtoFinan ;
       IF vMtoVevTrap > 0 THEN
          let vDifMtoVenc = vMtoVevTrapH - vDifMtoFinan;
          IF vDifMtoVenc > 0 THEN
             let vCapTraspNoVenc  = vCapTraspNoVenc + (vMtoVevTrap - vDifMtoVenc);
             let vMtoVevTrap = vDifMtoVenc;
             UPDATE sd_maesdos set mto_venc_trasp     = vMtoVevTrap,
                                   cap_tras_no_venci = vCapTraspNoVenc
            WHERE num_credito = vnum_credito and empresa = pempresa;
          ELIF vDifMtoVenc <= 0 THEN
             let vCapTraspNoVenc  = vCapTraspNoVenc +  vMtoVevTrap;
             UPDATE sd_maesdos set sdo_capital      = vCapTraspNoVenc,
                                   monto_vencido    = 0,
                                   mto_venc_trasp   = 0,
                                   cap_tras_no_venci=0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
          END IF;
        ELSE
             let vCapTraspNoVenc  = vCapTraspNoVenc +  vMtoVevTrap;
             UPDATE sd_maesdos set sdo_capital      = vCapTraspNoVenc,
                                   monto_vencido    = 0,
                                   mto_venc_trasp   = 0,
                                   cap_tras_no_venci=0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
        END IF;
   END FOREACH


-- Nivela Saldos Transitorio con Cuotas cero
foreach
  select  a.num_credito ,monto_vencido into vnum_credito,vmonto_vencido
    from  sd_maecred a,sd_maesdos b
   where  a.empresa = b.empresa and a.num_credito = b.num_credito
     and  (monto_vencido < 0 Or sdo_capital < 0)
     and  a.status_cred = "BA"

   update sd_maesdos set sdo_capital = sdo_capital + vmonto_vencido,
          monto_vencido = 0
   where  empresa = "001" and num_credito = vnum_credito;
   update sd_maecred set status_cred = "AA"
   where  empresa = "001" and num_credito = vnum_credito;
   UPDATE sd_maecredanexo set fecha_vencto = ''
   WHERE num_credito = vnum_credito and empresa = pempresa;

end foreach
foreach
   select  a.num_credito ,monto_vencido into vnum_credito,vmonto_vencido
    from  sd_maecred a,sd_maesdos b
   where  a.empresa = b.empresa and a.num_credito = b.num_credito
     and  monto_vencido = 0 and sdo_capital = 0
     and  a.status_cred = "BA"

   update sd_maecred set status_cred = "AA"
   where  empresa = "001" and num_credito = vnum_credito;
   UPDATE sd_maecredanexo set fecha_vencto = ''
   WHERE num_credito = vnum_credito and empresa = pempresa;
end foreach

--Nivela Saldos Con 1 Cuota Vencida

--foreach
-- select  a.num_credito ,sdo_cap_insoluto,sum(monto_vencido +  mto_venc_trasp + cap_tras_no_venci )
--         into vnum_credito ,vsdo_cap, vmonto_vencido
--    from  sd_maecred a,sd_maesdos b
--   where  a.empresa = b.empresa and a.num_credito = b.num_credito
   --  and  sdo_capital != sdo_cap_insoluto and b.sdo_capital = 0
--    and  sdo_capital  = 0
--     and  a.status_cred = "BT"
--    group by 1,2
--   If vsdo_cap = vmonto_vencido Then
--          update sd_maesdos set sdo_capital   = sdo_cap_insoluto,
--                                monto_vencido = 0,
--                                mto_venc_trasp = 0,
--                                cap_tras_no_venci = 0,
--                                sdo_moratorio = 0
--          where empresa = "001" and num_credito = vnum_credito;
--   End if;
--end foreach

foreach
 select  a.num_credito into vnum_credito
    from  sd_maecred a,sd_maesdos b
   where  a.empresa = b.empresa and a.num_credito = b.num_credito
    and  sdo_capital  < 0 and (mto_venc_trasp < 0 or mto_venc_trasp > 0)
     and  a.status_cred = "BT"
          update sd_maesdos set sdo_capital   = sdo_cap_insoluto,
                                monto_vencido = 0,
                                mto_venc_trasp = 0,
                                cap_tras_no_venci = 0,
                                sdo_moratorio = 0
          where empresa = "001" and num_credito = vnum_credito;
          update sd_maecred set status_cred = "AA"
          where  empresa = "001" and num_credito = vnum_credito;
          UPDATE sd_maecredanexo set fecha_vencto = ''
          WHERE num_credito = vnum_credito and empresa = pempresa;
end foreach

foreach
 select  a.num_credito into vnum_credito
    from  sd_maecred a,sd_maesdos b
   where  a.empresa = b.empresa and a.num_credito = b.num_credito
    and  sdo_capital  < 0 and  mto_venc_trasp <= 0
     and  a.status_cred = "BT"
          update sd_maesdos set sdo_capital   = sdo_cap_insoluto,
                                monto_vencido = 0,
                                mto_venc_trasp = 0,
                                cap_tras_no_venci = 0,
                                sdo_moratorio = 0
          where empresa = "001" and num_credito = vnum_credito;

          update sd_maecred set status_cred = "AA"
          where  empresa = "001" and num_credito = vnum_credito;
          UPDATE sd_maecredanexo set fecha_vencto = ''
          WHERE num_credito = vnum_credito and empresa = pempresa;
end foreach

return vcodret;
end
end procedure
;