create procedure "informix".rrevaloriza(pempresa char(3),pfecha_hoy date,pusuario char(8))
returning char(5);

define ghusuario              char(8);
define ghcontrol_poliza       smallint;
define ghfecha_captura        date;
define ghsecuencia            integer;
define ghempresa              char(3);
define ghccmayor              char(4);
define ghccsub                char(2);
define ghccsubsub             char(2);
define ghccssubsub            char(2);
define ghccsssubsub           char(2);
define ghsector               char(2);
define ghciudad               char(3);
define ghsucursal             char(4);
define ghnaturaleza           char(1);
define ghnro_auxiliar         char(12);
define ghmonto                money(18,2);
define ghdescripcion          char(50);
define ghfecha_valida         date;
define ghmoneda               char(2);
define ghvalor_cambio         money(12,7);
define ghvalor_div_cambio     money(12,7);
define ghpoliza_usuario       char(8);
define ghtipo_mov             char(1);

define gmusuario              char(8);
define gmcontrol_poliza       smallint;
define gmfecha_captura        date;
define gmsecuencia            integer;
define gmempresa              char(3);
define gmccmayor              char(4);
define gmccsub                char(2);
define gmccsubsub             char(2);
define gmccssubsub            char(2);
define gmccsssubsub           char(2);
define gmsector               char(2);
define gmciudad               char(3);
define gmsucursal             char(4);
define gmnaturaleza           char(1);
define gmnro_auxiliar         char(12);
define gmmonto                money(18,2);
define gmdescripcion          char(50);
define gmfecha_valida         date;
define gmmoneda               char(2);
define gmvalor_cambio         money(12,7);
define gmvalor_div_cambio     money(12,7);
define gmpoliza_usuario       char(5);
define gmtipo_mov             char(1);

define vpri_hab_mes      date;
define vfecha_ant        date;
DEFINE codigo            SMALLINT;
define cod_ret           char(5);

define v_proceso         char(10);
define v_fecha_hoy       date;
define contador          smallint;

DEFINE v_num_poliza      integer;
define w_cifra_control   money(18,2);
define v_numpol          smallint;
define monto_debito      money(18,2);
define monto_credito     money(18,2);

let cod_ret = "000";

select pri_hab_mes, fecha_ant
into   vpri_hab_mes,vfecha_ant
from   co_fechas
where  empresa = pempresa;

select max(control_poliza)
into v_numpol
from co_detpol
where fecha_captura = pfecha_hoy
and   empresa = pempresa;

if v_numpol is null then
   let v_num_poliza = 0;
else
   let v_num_poliza = v_numpol;
end if
if (v_num_poliza = 0) then
   let v_num_poliza = 1;
else
   let v_num_poliza = v_num_poliza + 1;
end if

IF pfecha_hoy = vpri_hab_mes THEN
   FOREACH
      SELECT *
      INTO ghusuario,
           ghcontrol_poliza,
           ghfecha_captura,
           ghsecuencia,
           ghempresa,
           ghccmayor,
           ghccsub,
           ghccsubsub,
           ghccssubsub,
           ghccsssubsub,
           ghsector,
           ghciudad,
           ghsucursal,
           ghnaturaleza,
           ghnro_auxiliar,
           ghmonto,
           ghdescripcion,
           ghfecha_valida,
           ghmoneda,
           ghvalor_cambio,
           ghvalor_div_cambio,
           ghpoliza_usuario,
           ghtipo_mov
      FROM co_historico
      WHERE  fecha_captura = vfecha_ant
      AND fecha_valida = vfecha_ant
      AND descripcion = "DIF ENTRE 7001 y 7009"
      AND empresa = pempresa
      ORDER BY secuencia

      IF ghnaturaleza = "D" THEN
         LET ghnaturaleza = "C";
      ELSE
         LET ghnaturaleza = "D";
      END IF
      LET ghusuario = pusuario;
      LET ghfecha_captura = pfecha_hoy;
      LET ghcontrol_poliza = v_num_poliza;
      LET ghfecha_valida  = pfecha_hoy;
      LET ghdescripcion = "REV. POL DIF 7001 y 7009";
--      IF (ghccmayor = "7009" and ghccsub = "04") OR
--         (ghccmayor = "5205" and ghccsub = "04" and
--          ghccsubsub = "05") THEN
--      ELSE
         INSERT
         INTO co_detpol VALUES
             (ghusuario, ghcontrol_poliza,
              ghfecha_captura, ghsecuencia,
              ghempresa, ghccmayor, ghccsub,
              ghccsubsub, ghccssubsub,
              ghccsssubsub,ghsector,ghciudad,
              ghsucursal, ghnro_auxiliar,
              ghnaturaleza,
              ghmonto, ghdescripcion,
              ghfecha_valida, ghmoneda, 0,0,"A","099"," ");
--      END IF
   END FOREACH
ELSE
   FOREACH
      SELECT *
      INTO gmusuario,
           gmcontrol_poliza,
           gmfecha_captura,
           gmsecuencia,
           gmempresa,
           gmccmayor,
           gmccsub,
           gmccsubsub,
           gmccssubsub,
           gmccsssubsub,
           gmsector,
           gmciudad,
           gmsucursal,
           gmnaturaleza,
           gmnro_auxiliar,
           gmmonto,
           gmdescripcion,
           gmfecha_valida,
           gmmoneda,
           gmvalor_cambio,
           gmvalor_div_cambio,
           gmpoliza_usuario,
           gmtipo_mov
      FROM co_mensual
      WHERE  fecha_captura = vfecha_ant
      AND fecha_valida = vfecha_ant
      AND descripcion = "DIF ENTRE 7001 y 7009"
      AND empresa = pempresa
      ORDER BY secuencia

      IF gmnaturaleza = "D" THEN
         LET gmnaturaleza = "C";
      ELSE
         LET gmnaturaleza = "D";
      END IF
      LET gmusuario = pusuario;
      LET gmfecha_captura = pfecha_hoy;
      LET gmcontrol_poliza = v_num_poliza;
      LET gmfecha_valida  = pfecha_hoy;
      LET gmdescripcion = "REV. POL DIF 7001 y 7009";
      INSERT INTO co_detpol
      VALUES (gmusuario, gmcontrol_poliza,
              gmfecha_captura, gmsecuencia,
              gmempresa, gmccmayor, gmccsub,
              gmccsubsub, gmccssubsub,
              gmccsssubsub, gmsector, gmciudad,
              gmsucursal, gmnro_auxiliar,
              gmnaturaleza,
              gmmonto, gmdescripcion,
              gmfecha_valida, gmmoneda, 0,0,"A","099"," ");
   END FOREACH
END IF

--#*****************************************************************************
--#Genera encabezado
--#*****************************************************************************

select  sum(monto) into monto_debito
from bdicont:co_detpol
where usuario  = pusuario
and fecha_captura  = pfecha_hoy
and control_poliza = v_num_poliza
and moneda = "01"
and naturaleza     = "D"
and empresa    = pempresa;

select sum(monto) into monto_credito
from bdicont:co_detpol
where usuario        = pusuario
and fecha_captura  = pfecha_hoy
and control_poliza = v_num_poliza
and moneda = "01"
and naturaleza     = "C"
and empresa = pempresa;

if monto_debito is null then
   let monto_debito = 0;
end if
if monto_credito is null then
   let monto_credito = 0;
end if
-- calcula cifra de control
let w_cifra_control = monto_debito;
insert into bdicont:co_poliza
values(pempresa,pusuario, v_num_poliza,
       pfecha_hoy, w_cifra_control,
       monto_debito,monto_credito,
       "01", "REV. POL DIF 7001 y 7009");
return cod_ret;
end procedure;