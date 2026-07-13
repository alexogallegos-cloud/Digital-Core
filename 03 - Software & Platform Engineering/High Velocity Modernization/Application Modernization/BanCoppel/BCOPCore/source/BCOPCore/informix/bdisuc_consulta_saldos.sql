create procedure "informix".consulta_saldos(pempresa char(3),
                           pcodproveedor char(4))

                           returning char(5),char (40),char (40),
			    	     money (14,2), money (14,2), money (14,2),
                                     money (14,2), money (14,2), money (14,2),
                                     money (14,2), money (14,2), money (14,2),
				     money (14,2), money (14,2);
define vcodret char(5);
define vsqlerr integer;
define vnum_plaza       char (3);
define vsucursal        char (4);
define vfecha           date;
define vfecha_ant       date;
define vtot_dota        money (14,2);
define vtot_conc        money (14,2);
define vtot_falt        money (14,2);
define vtot_sob         money (14,2);
define vtot_bill        money (14,2);
define vnom_proveedor   char (40);
define vnomplaza        char (40);
define vsaldo_actual    money (14,2);
define vdot_pendientes  money (14,2);
define vcon_pendientes  money (14,2);
define vsubtotal_1      money (14,2);
define vfaltantes       money (14,2);
define vsobrantes       money (14,2);
define vbillete_det     money (14,2);
define vsubtotal_3      money (14,2);
define vsaldo_sucursal  money (14,2);
define vsaldo_estimado  money (14,2);
define vsaldo_retenido  money (14,2);
define vtot_suc         money (14,2);
define vcod_trans       char  (4);
define vcod_trans1      char  (4);

define vDeno_1          float;
define vDeno_2          float;
define vDeno_3          float;
define vDeno_4          float;
define vDeno_5          float;
define vDeno_6          float;
define vDeno_7          float;
define vDeno_8          float;
define vDeno_9          float;
define vDeno_10         float;
define vDeno_11         float;
define vDeno_12         float;
define vDeno_13         float;
define vDeno_14         float;
define vDeno_15         float;

define vCant_1          float;
define vCant_2          float;
define vCant_3          float;
define vCant_4          float;
define vCant_5          float;
define vCant_6          float;
define vCant_7          float;
define vCant_8          float;
define vCant_9          float;
define vCant_10         float;
define vCant_11         float;
define vCant_12         float;
define vCant_13         float;
define vCant_14         float;
define vCant_15         float;



let vcodret = "000";
let vsqlerr = 0;
let vnum_plaza = "";
let vsucursal = "";
let vfecha = "";
let vfecha_ant = "";
let vtot_dota = 0;
let vtot_conc = 0;
let vtot_falt = 0;
let vtot_sob = 0;
let vtot_bill = 0;
let vtot_suc = 0;
let vnom_proveedor = "";
let vnomplaza = "";
let vsaldo_actual = 0;
let vdot_pendientes = 0;
let vcon_pendientes =0;
let vsubtotal_1 = 0;
let vfaltantes  = 0;
let vsobrantes  = 0;
let vbillete_det = 0;
let vsubtotal_3 = 0;
let vsaldo_sucursal= 0;
let vsaldo_estimado = 0;
let vsaldo_retenido = 0;
let vcod_trans = "";
let vcod_trans1 = "";

let vDeno_1 = 0;
let vDeno_2 = 0;
let vDeno_3 = 0;
let vDeno_4 = 0;
let vDeno_5 = 0;
let vDeno_6 = "";
let vDeno_7 = "";
let vDeno_8 = "";
let vDeno_9 = "";
let vDeno_10 = "";
let vDeno_11 = "";
let vDeno_12 = "";
let vDeno_13 = "";
let vDeno_14 = "";
let vDeno_15 = "";
let vCant_1 = 0;
let vCant_2 = 0;
let vCant_3 = 0;
let vCant_4 = 0;
let vCant_5 = 0;
let vCant_6 = 0;
let vCant_7 = 0;
let vCant_8 = 0;
let vCant_9 = 0;
let vCant_10 = 0;
let vCant_11 = 0;
let vCant_12 = 0;
let vCant_13 = 0;
let vCant_14 = 0;
let vCant_15 = 0;

--SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/saldos.out";
--trace on;


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vnom_proveedor, vnomplaza, vsaldo_actual,
                vtot_dota, vtot_conc,vsubtotal_1, vtot_falt, vtot_sob,
                vtot_bill,vsubtotal_3,vtot_suc,vsaldo_estimado,vsaldo_retenido;
      end if;
      end exception;

   if exists (select cod_proveedor from ss_proveedores where cod_proveedor = pcodproveedor) Then

       --  Nombre del Proveedor,plaza y numero de plaza

       SELECT  pla.descripcion,prov.descripcion,prov.plaza INTO vnomplaza,vnom_proveedor,vnum_plaza FROM bdinteg:si_plazas_cajagen pla,bdisuc:ss_proveedores prov
       WHERE   prov.cod_proveedor = pcodproveedor and prov.plaza = pla.codigo_plaza;

       --  Saldo actual de la Caja General, Saldo Retenido y Saldo boveda

       SELECT cg.saldo_total,cg.saldo_asignado INTO vsaldo_actual,vsaldo_retenido FROM bdisuc:ss_cajageneral cg WHERE cod_proveedor =  pcodproveedor;
          --let vsaldo_actual = vsaldo_actual + vsaldo_retenido;
          let vsaldo_actual = vsaldo_actual+vsaldo_retenido;

   FOREACH


       -- Sucursales de la plaza

       SELECT  suc.sucursal INTO vsucursal  FROM  bdinteg:si_sucursales suc WHERE plaza_cajagen = vnum_plaza

       --  Saldo de dotaciones no enviadas

       select valor into vcod_trans from ss_param_cajagen where codigo = '0001';
       select valor into vcod_trans1 from ss_param_cajagen where codigo = '0010';

       SELECT  sum(mae.monto) INTO  vdot_pendientes
       FROM  bdisuc:ss_mae_entradasalida mae,bdisuc:ss_operaciones oper
       WHERE   mae.folio_oper = oper.folio_oper and mae.sucursal = vsucursal and (oper.cod_trans  = vcod_trans or oper.cod_trans = vcod_trans1) and mae.status = '01';

       if not vdot_pendientes is null  then
          let vtot_dota = vtot_dota + vdot_pendientes;
       end if;

       --  Saldo de concentraciones
       select valor into vcod_trans from ss_param_cajagen where codigo = '0002';

       SELECT  sum(mae.monto) INTO  vcon_pendientes
       FROM  bdisuc:ss_mae_entradasalida mae,bdisuc:ss_operaciones oper 
       WHERE   mae.folio_oper = oper.folio_oper and mae.sucursal = vsucursal and               oper.cod_trans = vcod_trans and mae.status = '06';

       if not vcon_pendientes is null  then
          let vtot_conc = vtot_conc + vcon_pendientes;
       end if;

       -- subtotal_1

       let vsubtotal_1 = vsaldo_actual - vtot_dota + vtot_conc;

       -- extrae fecha del sistema

       SELECT  fecha_hoy,fecha_ant  INTO  vfecha,vfecha_ant  FROM  bdinteg:si_fechas;

       IF vfecha IS NULL  then
          let vfecha = vfecha_ant;
       END IF ;

       -- Saldo de Faltantes

      select valor into vcod_trans from ss_param_cajagen where codigo = '0006';

       SELECT  sum(monto)  INTO  vfaltantes  FROM  bdisuc:ss_operaciones  WHERE  fecha_operacion = vfecha and cod_trans = vcod_trans  and sucursal = vsucursal;

       if not vfaltantes is null  then
          let vtot_falt = vtot_falt + vfaltantes;
       end if;

       -- Saldo de Sobrantes
       select valor into vcod_trans from ss_param_cajagen where codigo = '0007';

       SELECT   sum(monto)  INTO  vsobrantes  FROM  bdisuc: ss_operaciones  WHERE  fecha_operacion = vfecha and cod_trans = vcod_trans  and sucursal = vsucursal;

       if not vsobrantes is null  then
          let vtot_sob = vtot_sob + vsobrantes;
       end if;

       -- subtotal_2


       -- Saldo de Billetes deteriorados
       SELECT denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
              denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,
              denominacion_11,denominacion_12,denominacion_13,denominacion_14,denominacion_15,
              cantidad_1d,cantidad_2d,cantidad_3d,cantidad_4d,cantidad_5d,
              cantidad_6d,cantidad_7d,cantidad_8d,cantidad_9d,cantidad_10d,
              cantidad_11d,cantidad_12d,cantidad_13d,cantidad_14d,cantidad_15d
       INTO  vDeno_1, vDeno_2, vDeno_3, vDeno_4, vDeno_5,
             vDeno_6, vDeno_7, vDeno_8, vDeno_9, vDeno_10,
             vDeno_11, vDeno_12, vDeno_13, vDeno_14, vDeno_15,
             vCant_1,vCant_2,vCant_3,vCant_4,vCant_5,
             vCant_6,vCant_7,vCant_8,vCant_9,vCant_10,
             vCant_11,vCant_12,vCant_13,vCant_14,vCant_15
       FROM bdisuc:ss_cajageneral
       WHERE cod_proveedor = pcodproveedor;


       let vtot_bill = ((vDeno_1 * vCant_1) + (vDeno_2 * vCant_2) + (vDeno_3 * vCant_3) + (vDeno_4 * vCant_4) + (vDeno_5 * vCant_5)+
                        (vDeno_6 * vCant_6) + (vDeno_7 * vCant_7) + (vDeno_8 * vCant_8) + (vDeno_9 * vCant_9) + (vDeno_10 * vCant_10) +
                        (vDeno_11 * vCant_11) + (vDeno_12 * vCant_12) + (vDeno_13 * vCant_13) + (vDeno_14 * vCant_14) + (vDeno_15 * vCant_15));




      -- if not vbillete_det is null  then
      --    let vtot_bill = vtot_bill + vbillete_det;
      -- end if;

       --subtotal_3

       let vsubtotal_3 = vsubtotal_1 - vtot_bill;

       -- Saldo en Sucursal
       SELECT   sum(saldo_total)  INTO  vsaldo_sucursal  FROM  bdisuc: ss_saldossuc  WHERE  fecha = vfecha_ant and sucursal = vsucursal;

       if not vsaldo_sucursal is null  then
          let vtot_suc = vtot_suc + vsaldo_sucursal;
       end if;

   END FOREACH;

    -- Saldo Estimado

       let vsaldo_estimado = vsaldo_actual - vtot_dota + vtot_conc - vtot_bill;

       return vcodret,vnom_proveedor, vnomplaza, vsaldo_actual,
              vtot_dota,vtot_conc,vsubtotal_1, vtot_falt, vtot_sob,
              vtot_bill,vsubtotal_3,vtot_suc,vsaldo_estimado,vsaldo_retenido;
   end if;
end
end procedure;