create procedure "informix".devchqsbc(eEmpresa  char(3),
                                      eNumCta   char(20),
                                      eSucursal char(4),
                                      eUsuario  char(8),
                                      eFolio    char(16),
                                      eCausaDev CHAR(2),
                                      eImporte  money(14,2),
                                      eBanco    char(3),
                                      eMoneda   char(2))

returning char(5);

define vCodRet     char(5);
define sql_err     integer;
define vReferencia char(40);
define vIvaComi    DECIMAL(14,2);
define vFecHoy     DATE;
define vDivisa     char(2);
define Mensaje     char(40);
DEFINE eNumCredito char(20);
DEFINE vRemanente  decimal(14,2);
DEFINE vValComi    char(4);
DEFINE vCodComi    char(4);
--DEFINE vSdoCapital decimal(14,2);
DEFINE vIva        char(100);
DEFINE vIvapaso    decimal(14,2);
DEFINE vTotComi    decimal(14,2);
--DEFINE vSaldoFav   decimal(14,2);
--DEFINE vSec        INTEGER;
DEFINE eNumProd    char(4);
DEFINE vDesBco     char(19);
define vStatusCred char(02);
						

--set debug file to "/pisa/pisabanco/pisa_ftes/devbanco.out";
--trace on;


let vCodRet  = "000";
let vIvaComi = 0;
Let vFecHoy  = '';
Let vDivisa  = '';
let eNumCredito = '';
let vRemanente  = 0;
let vValComi    = '';
let vCodComi    = '';
--let vSdoCapital = 0;
--let vSec        = 0;
let vDesBco     = '';
--let vSaldoFav   = 0;
let vStatusCred = '';
			 

begin
   on exception set sql_err
      if sql_err <> 0 then
	 let vCodRet = sql_err;
	 return vCodRet;
      end if;
   end exception;

IF eSucursal = " " Or eUsuario = " " Or eFolio = " "  Or eImporte  = 0 Or eBanco = " " THEN
   let vCodRet = "110";
   return vCodRet;
END IF ;

Select fecha_hoy Into vFecHoy From sd_fechas Where empresa = eEmpresa;
select num_credito Into eNumCredito From sd_tarjeta Where empresa = eEmpresa and num_tarjeta = eNumCta ;
Select trim(valor) Into vValComi From sd_param where cod_param ='81';
--Select trim(valor) Into vIva From sd_param where cod_param ='47';
let vIvapaso = 0.15;
Select monto Into vCodComi From sd_tpcomis Where empresa = eEmpresa and cod_comis = vValComi;
--Select monto_otorgado - (sdo_cap_insoluto + sdo_retenido) Into vSdoCapital From sd_maesdos Where empresa = eEmpresa and num_credito = eNumCredito;
Select divisa, status_cred, num_producto Into vDivisa, vStatusCred, eNumProd From sd_maecred Where empresa = eEmpresa and num_credito = eNumCredito;
--Select status_cred Into vStatusCred From sd_maecred Where empresa = eEmpresa and num_credito = eNumCredito;
--Select num_producto Into eNumProd From sd_maecred Where empresa = eEmpresa and num_credito = eNumCredito;
--Select max(secuencia) Into vSec From sd_detcomi Where empresa = eEmpresa;
Select descripcion[1,19] Into vDesBco From bdinteg:si_bancos Where banco = eBanco;

Let vReferencia = "DEVOL.SBC CAUSA "||eCausaDev||" "||vDesBco;
--Let vIvaComi    = vCodComi * vIva;
Let vIvaComi    = vCodComi * vIvapaso;
Let vTotComi    = vCodComi  + vIvaComi;

--jom ini -- Valida comision
if (vCodComi is null or vCodComi <= 0) then
   CALL GenMov(Eempresa, eNumCredito, eNumProd,22,
              '336', vFecHoy, eImporte, eFolio,
              eSucursal, vDivisa, '0000') RETURNING
              vCodRet, Mensaje;
   IF (vCodRet <> "00000") THEN
      RETURN vCodRet;
   ELSE
      LET vCodRet = "000";
      RETURN vCodRet;
   END IF;
END IF;
--jom fin


-- Valida Saldo a Favor del Credito
IF vStatusCred IN ('BT','E2','E3')  THEN
   INSERT INTO sd_detcomi (empresa,cod_comis,num_credito,fecha_alta,
                           secuencia,fecha_pago,monto_com,monto_pag,
                           apli_factor,estado_com,num_solicitud,
                           user_insert,fecha_insert)
   VALUES(eEmpresa,vValComi,eNumCredito,vFecHoy,0,null,
          vTotComi,0,0,'A','',USER,vFecHoy);

   CALL GenMov(Eempresa, eNumCredito, eNumProd,22,
              '336', vFecHoy, eImporte, eFolio,
              eSucursal, vDivisa, '0000') RETURNING
              vCodRet, Mensaje;
   IF (vCodRet <> "00000") THEN
      RETURN vCodRet;
   ELSE
      LET vCodRet = "000";
   END IF;

ELSE
      UPDATE sd_maesdos set sdo_dia_ant_cap = sdo_capital,
                            sdo_capital = sdo_capital + vTotComi,
                           sdo_cap_insoluto = sdo_cap_insoluto + vTotComi
      WHERE empresa = eEmpresa and num_credito = eNumCredito;
      CALL GenMov(Eempresa, eNumCredito, eNumProd,22,
                 '336', vFecHoy, eImporte, eFolio,
                 eSucursal, vDivisa, '0000') RETURNING
                 vCodRet, Mensaje;
      IF (vCodRet <> "00000") THEN
         RETURN vCodRet;
      ELSE
         LET vCodRet = "000";
      END IF;
      CALL GenMov(Eempresa, eNumCredito, eNumProd,23,
                   '336', vFecHoy, vCodComi, eFolio,
                   eSucursal, vDivisa, '0000') RETURNING
                   vCodRet, Mensaje;
      IF (vCodRet <> "00000") THEN
          RETURN vCodRet;
      ELSE
          LET vCodRet = "000";
      END IF;
      CALL GenMov(Eempresa, eNumCredito, eNumProd,24,
                  '336', vFecHoy, vIvaComi, eFolio,
                  eSucursal, vDivisa, '0000') RETURNING
                  vCodRet, Mensaje;
      IF (vCodRet <> "00000") THEN
         RETURN vCodRet;
      ELSE
         LET vCodRet = "000";
      END IF;

END IF;

                       --** Actualiza Mov. Diario **--
UPDATE sd_movdia Set referencia23 = vReferencia
Where  empresa     = eEmpresa and
       fecha_mov   = vFecHoy  and
       num_credito = eNumCredito and
       folio_suc   = eFolio;

return vCodret;

end
end procedure;