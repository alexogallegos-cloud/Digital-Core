create procedure "informix".actcuota(pempresa char(3))
returning char(5);


define vcodret         char(5);
define vnum_credito    char(20);
define vStatus         char(1);
define vsqlerr         Integer;
define vCuotas         Integer;
define vMtoVigente     money(14,2);
define vSdoMinimo      money(14,2);
define vMtoTransi      money(14,2);
define vCapVencido     money(14,2);
define vIntVenc        money(14,2);
define vMtoCuota       money(14,2);
define vMtoCuotaVig    money(14,2);
define vInt            money(14,2);
define vMora           money(14,2);
define vTotAdeudoVenc  money(14,2);
define vMto1           money(14,2);
define vMto2           money(14,2);
define vCapPag         money(14,2);
define vCuotaVig       money(14,2);
define vTotCap         money(14,2);
define vRem1           money(14,2);
define vRem2           money(14,2);
define vTotInt         money(14,2);
define v1              money(14,2);
define vFecVenci       date;
define vFecha          date;
DEFINE vBegin     CHAR(1);

-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      IF vBegin = "S" THEN
         ROLLBACK WORK;
      END IF;
      RETURN vcodret;
   END IF;
END EXCEPTION;

--  set debug file to "actcuota.out";
--  trace on;



  LET vBegin     = "?";
  let vnum_credito    = "";
  let vcodret         = "000";
  let vMtoVigente     =0;
  let vSdoMinimo      =0;
  let vMtoTransi      =0;
  let vCuotas         =0;
  let vCapVencido     =0;
  let vIntVenc        =0;
  let vMtoCuota       =0;
  let vMtoCuotaVig    =0;
  let vInt            =0;
  let vTotAdeudoVenc  =0;
  let vMto1           =0;
  let vMto2           =0;
  let vCapPag         =0;
  let vCuotaVig       =0;
  let vMora           =0;
  let  vTotCap        =0;
  let  vTotInt        =0;
  let  vRem1          =0;
  let  vRem2          =0;
  let vFecha          ='';
  Let vStatus         ='';


--Creditos Vigentes

FOREACH WITH HOLD


  select num_credito
  into vnum_credito
  from  sd_maecred 
  where  empresa = '001'
    and  status_cred = "AA"

   
   begin work;

   update sd_maesdos set sdo_contab_mora = 0,
                         sdo_moratorio   = 0
   where empresa = "001" and num_credito = vnum_credito;

   update sd_maesdoshist set sdo_contab_mora = 0,
                         sdo_moratorio   = 0
   where empresa = "001" and num_credito = vnum_credito and fecha = '06/20/2008';


  COMMIT WORK;
  LET vBegin ="N";


end foreach



return vcodret;
end
end procedure
;