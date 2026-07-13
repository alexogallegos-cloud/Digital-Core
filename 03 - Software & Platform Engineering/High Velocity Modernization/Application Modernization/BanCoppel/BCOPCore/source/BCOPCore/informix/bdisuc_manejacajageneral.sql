create procedure "informix".manejacajageneral(ptipo char(1),pempresa char(3),
                    pcod_proveedor char(4), pdes_proveedor char(30),
                    pdivisa char(2), pplaza char(3))

returning char(5);

define vcodret char(5);
define vsqlerr integer;

define vden01 char(5);
define vden02 char(5);
define vden03 char(5);
define vden04 char(5);
define vden05 char(5);
define vden06 char(5);
define vden07 char(5);
define vSaldo_ant money (14,2);
define vSaldo_asi money (14,2);
define vSaldo_tot money (14,2);
define vStatus_1  char (2);
define vStatus_2  char (2);
define vStatus_6  char (2);

let vcodret = "000";
let vsqlerr = 0;

let vden01 = "";
let vden02 = "";
let vden03 = "";
let vden04 = "";
let vden05 = "";
let vden06 = "";
let vden07 = "";
let vSaldo_ant = "";
let vSaldo_asi = "";
let vSaldo_tot = "";
let vStatus_1 = "";
let vStatus_2 = "";
let vStatus_6 = "";

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
     end if;
   end exception;
--SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/sucursal/manejacajageneral.out";
--trace on;

--ptipo = 1 -> insert
--ptipo = 2 -> update
--ptipo = 3 -> delete

 if ptipo = "1" then

    select valor into vden01 from ss_param_cajagen where codigo = "0011";
    select valor into vden02 from ss_param_cajagen where codigo = "0012";
    select valor into vden03 from ss_param_cajagen where codigo = "0013";
    select valor into vden04 from ss_param_cajagen where codigo = "0014";
    select valor into vden05 from ss_param_cajagen where codigo = "0015";
    select valor into vden06 from ss_param_cajagen where codigo = "0016";
    select valor into vden07 from ss_param_cajagen where codigo = "0017";

    if exists (select cod_proveedor from ss_cajageneral where cod_proveedor = pcod_proveedor) Then
       let vcodret = "103";
    else
       insert into ss_cajageneral (empresa,cod_proveedor,divisa,
                    saldo_anterior,saldo_asignado,saldo_total,denominacion_1,
                    denominacion_2,denominacion_3,denominacion_4,
                    denominacion_5,denominacion_6,denominacion_7,
                    denominacion_8,denominacion_9,denominacion_10,
                    denominacion_11,denominacion_12,denominacion_13,
                    denominacion_14,denominacion_15,cantidad_1,cantidad_2,
                    cantidad_3,cantidad_4,cantidad_5,cantidad_6,
                    cantidad_7,cantidad_8,cantidad_9,cantidad_10,
		    cantidad_11,cantidad_12,cantidad_13,cantidad_14,cantidad_15,
                    cantidad_1d,cantidad_2d,cantidad_3d,cantidad_4d,
                    cantidad_5d,cantidad_6d,cantidad_7d,cantidad_8d,
                    cantidad_9d,cantidad_10d,cantidad_11d,cantidad_12d,
                    cantidad_13d,cantidad_14d,cantidad_15d)
            values (pempresa, pcod_proveedor, pdivisa, 0, 0, 0,
		    vden01, vden02, vden03, vden04, vden05, vden06,
                    vden07,'0','0','0','0','0','0','0','0','0','0','0','0',
                    '0','0','0','0','0','0','0','0','0','0','0',
                    '0','0','0','0','0','0','0','0','0','0','0',
                    '0','0','0','0');
       insert into ss_proveedores (cod_proveedor, descripcion, plaza)
                values (pcod_proveedor, pdes_proveedor, pplaza);
    end if;
 end if;


 if ptipo = "2" then
     if exists (select cod_proveedor from ss_cajageneral where cod_proveedor = pcod_proveedor) Then
         UPDATE ss_cajageneral
         SET    empresa = pempresa,
                divisa = pdivisa
         WHERE  cod_proveedor = pcod_proveedor;

         UPDATE ss_proveedores
         SET    descripcion = pdes_proveedor,
                plaza = pplaza
         WHERE cod_proveedor = pcod_proveedor;
     else
         let vcodret = "102";
     end if;
 end if;


 if ptipo = "3" then
     SELECT saldo_anterior,saldo_asignado,saldo_total
     INTO vSaldo_ant,vSaldo_asi,vSaldo_tot
     FROM ss_cajageneral
     WHERE cod_proveedor = pcod_proveedor;

    
     SELECT status into vStatus_1 from ss_mae_entradasalida where cod_proveedor = pcod_proveedor and status = '01';
     SELECT status into vStatus_2 from ss_mae_entradasalida where cod_proveedor = pcod_proveedor and status = '02';
     SELECT status into vStatus_6 from ss_mae_entradasalida where cod_proveedor = pcod_proveedor and status = '06'; 
    
     if (vSaldo_ant > 0 or  vSaldo_asi > 0 or  vSaldo_tot > 0 or vStatus_1 = '01' or vStatus_2 = '02' or vStatus_6 = '06')   then
         let vcodret = "104";    
     else

         DELETE FROM ss_cajageneral
         WHERE  cod_proveedor = pcod_proveedor;

         DELETE from ss_proveedores
         WHERE  plaza = pplaza and cod_proveedor = pcod_proveedor;
    
     end if;

 end if;

    return vcodret;
end
end procedure
DOCUMENT
"Manejo de Caja General",
"Autor : Frank Gaxiola"
;

create procedure "informix".auditapase(pfecha_trab date,pempresa char(3),pusuario char(8))
returning char(5);

define vproceso                char(20);
define w_cod_ret               char(5);
define tmousuario              char(8);
define tmocontrol_poliza       smallint;
define tmofecha_captura        date;
define tmosecuencia            integer;
define tmoempresa              char(3);
define tmoccmayor              char(4);
define tmoccsub                char(2);
define tmoccsubsub             char(2);
define tmoccssubsub            char(2);
define tmoccsssubsub           char(2);
define tmosector               char(2);
define tmociudad               char(3);
define tmosucursal             char(3);
define tmonro_auxiliar         char(12);
define tmonaturaleza           char(1);
define tmomonto                money(18,2);
define tmodescripcion_det      char(50);
define tmofecha_valida         date ;
define tmomoneda               char(2);
define tmovalor_cambio         money(12,7);
define tmovalor_div_cambio     money(12,7);
define tmomca_aplic            char(1);
define tmopoliza_usuario       char(8);
define tmotipo_mov             char(1);
define v_cuantos               integer;
define v_debitos               money(18,2);
define v_creditos              money(18,2);
define v_tipo_cuenta           char(1);
define v_auxiliar              char(1);
define v_aux                   char(12);
define v_sucursal              char(3);
define v_region                smallint;
define v_monant                char(2);

--set debug file to "/pisa/pisabanco/pisa_ftes/SPL/bdicont/auditapase.out";
--trace on;

LET tmosecuencia = 0;
LET tmoccmayor = " ";
LET tmoccsub   = " ";
LET tmoccsubsub = " ";
LET tmoccssubsub = " ";
LET tmoccsssubsub = " ";
LET tmosector = " ";
LET tmonro_auxiliar = " ";
LET w_cod_ret = "00000";

DELETE FROM co_auditpase
WHERE usuario = pusuario
AND   empresa = pempresa
AND   fecha_captura = pfecha_trab;

DELETE FROM co_detpol
WHERE  empresa = pempresa
AND    fecha_captura = pfecha_trab
AND    usuario = pusuario;

DELETE FROM co_poliza
WHERE  empresa = pempresa
AND    fecha_captura = pfecha_trab
AND    usuario = pusuario;

LET tmocontrol_poliza = 0;

-- CHECA SI LAS POLIZAS ESTAN CUADRADAS POR MONEDA.
FOREACH
   SELECT
      moneda,
      sum(monto)
   INTO
      tmomoneda,
      v_debitos
   FROM
      co_poldet
   WHERE
      usuario = pusuario
   AND
      fecha_captura = pfecha_trab
   AND
      naturaleza = "D"
   AND
      empresa = pempresa
   GROUP BY
      usuario,
      moneda
   ORDER BY
      moneda

   SELECT
      sum(monto)
   INTO
      v_creditos
   FROM
      co_poldet
   WHERE
      usuario = pusuario
   AND
      fecha_captura = pfecha_trab
   AND
      moneda = tmomoneda
   AND
      naturaleza = "C"
   AND
      empresa = pempresa;

   IF (v_creditos IS NULL) THEN
      LET v_creditos = 0;
   END IF

   IF (v_debitos is null) then
      LET v_debitos = 0;
   END IF

   IF (v_debitos <> v_creditos) then
      LET w_cod_ret = "106";
      INSERT INTO
      co_auditpase
      VALUES
      (pusuario,tmomoneda,pfecha_trab,tmosecuencia,pempresa,
       tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
       tmosector,tmonro_auxiliar,w_cod_ret);
   END IF
END FOREACH

LET v_monant = " ";

FOREACH
   SELECT *
   INTO
      tmousuario,
      tmofecha_captura,
      tmosecuencia,
      tmoempresa,
      tmoccmayor,
      tmoccsub,
      tmoccsubsub,
      tmoccssubsub,
      tmoccsssubsub,
      tmosector,
      tmociudad,
      tmosucursal,
      tmonro_auxiliar,
      tmonaturaleza,
      tmomonto,
      tmodescripcion_det,
      tmofecha_valida,
      tmomoneda
   FROM  co_poldet
   WHERE empresa = pempresa
   AND   fecha_captura = pfecha_trab
   AND   usuario = pusuario
   ORDER BY moneda, secuencia

   IF tmomoneda != v_monant THEN
      LET tmocontrol_poliza = tmocontrol_poliza + 1;
   -- CAMBIO 26/08/2002 JLG
      INSERT INTO co_poliza
      VALUES (pempresa,
              pusuario,
              tmocontrol_poliza,
              pfecha_trab,
              0, 0, 0, tmomoneda,"X");
   END IF

   SELECT
      tipo_cuenta,
      auxiliar
   INTO
      v_tipo_cuenta,
      v_auxiliar
   FROM
      bdinteg:si_catalog
   WHERE
       empresa    = pempresa
   AND ccmayor    = tmoccmayor
   AND ccsub      = tmoccsub
   AND ccsubsub   = tmoccsubsub
   AND ccssubsub  = tmoccssubsub
   AND ccsssubsub = tmoccsssubsub
   AND sector     = tmosector;

   IF (v_tipo_cuenta IS NULL) THEN
      LET w_cod_ret = "100";       {Cuenta contable no existe}
      INSERT INTO
      co_auditpase
      VALUES
      (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
       tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
       tmosector,tmonro_auxiliar,w_cod_ret);
   END IF

   if w_cod_ret != "100" then
      IF v_tipo_cuenta = "T" THEN
         LET w_cod_ret = "101";
         INSERT INTO
         co_auditpase
         VALUES
         (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
          tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
          tmosector,tmonro_auxiliar,w_cod_ret);
      END IF

      IF (v_auxiliar = "N") THEN
         IF (tmonro_auxiliar <> " ") THEN
            LET w_cod_ret = "118";
            INSERT INTO
            co_auditpase
            VALUES
            (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
             tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
             tmosector,tmonro_auxiliar,w_cod_ret);
         END IF
      ELSE
         SELECT
            numero
         INTO
            v_aux
         FROM
            co_auxiliar
         WHERE
            empresa = pempresa
         AND
            numero = tmonro_auxiliar;

         IF (v_aux is null) THEN
            LET w_cod_ret = "102";
            INSERT INTO
            co_auditpase
            VALUES
            (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
             tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
             tmosector,tmonro_auxiliar,w_cod_ret);
         END IF
      END IF

      SELECT
         sucursal
      INTO
         v_sucursal
      FROM
         bdinteg:si_sucursales
      WHERE
         empresa  = pempresa
      AND sucursal = tmosucursal;

      IF (v_sucursal is null) THEN
         LET w_cod_ret = "103";
         INSERT INTO
         co_auditpase
         VALUES
         (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
          tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
          tmosector,tmonro_auxiliar,w_cod_ret);
      END IF

      LET v_region = 0;
      SELECT count(*)
      INTO v_region
      FROM bdinteg:si_regional
      WHERE empresa = tmoempresa
      AND   regional = tmociudad;

      IF v_region <= 0 THEN
         LET w_cod_ret = "105";
         INSERT INTO
         co_auditpase
         VALUES
         (tmousuario,tmomoneda,tmofecha_captura,tmosecuencia,tmoempresa,
          tmoccmayor,tmoccsub,tmoccsubsub,tmoccssubsub,tmoccsssubsub,
          tmosector,tmonro_auxiliar,w_cod_ret);
      end if

      LET tmovalor_cambio = 0;
      LET tmovalor_div_cambio = 0;
      LET tmomca_aplic = " ";
      LET tmopoliza_usuario = "099";
      LET tmotipo_mov = " ";

      IF w_cod_ret = "00000" THEN
         INSERT INTO co_detpol VALUES
         (tmousuario,
          tmocontrol_poliza,
          tmofecha_captura,
          tmosecuencia,
          tmoempresa,
          tmoccmayor,
          tmoccsub,
          tmoccsubsub,
          tmoccssubsub,
          tmoccsssubsub,
          tmosector,
          tmociudad,
          tmosucursal,
          tmonro_auxiliar,
          tmonaturaleza,
          tmomonto,
          tmodescripcion_det,
          tmofecha_valida,
          tmomoneda,
          tmovalor_cambio,
          tmovalor_div_cambio,
          tmomca_aplic,
          tmopoliza_usuario,
          tmotipo_mov);
      END IF
      LET  v_monant = tmomoneda;
   end if
END FOREACH

SELECT COUNT(*)
INTO   v_cuantos
FROM   co_auditpase
WHERE  usuario = pusuario
AND    empresa = pempresa
AND    fecha_captura = pfecha_trab;

IF v_cuantos = 0 THEN
   FOREACH
      SELECT UNIQUE control_poliza
      INTO          tmocontrol_poliza
      FROM co_detpol
      WHERE empresa = pempresa
      AND   fecha_captura = pfecha_trab
      AND   usuario = pusuario

     EXECUTE PROCEDURE act_encab(pempresa,pusuario,
                                 pfecha_trab,tmocontrol_poliza) INTO w_cod_ret;
   END FOREACH
END IF
return w_cod_ret;
end procedure;