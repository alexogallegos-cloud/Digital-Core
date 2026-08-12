CREATE PROCEDURE "informix".sp_saldostmp(pempresa CHAR(3),
                                        pusuario char(8),
                                        pfecha date,
                                        pproveedor char(4))

RETURNING CHAR(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vsucursal char(4);
DEFINE vfecha_hoy date;
DEFINE vfecha_tmp date;
DEFINE vmes_act char(1);
DEFINE vsaldo_ant money(14,2);
DEFINE ventradas money(14,2);
DEFINE vsalidas money(14,2);
DEFINE vsaldo_calc money(14,2);
DEFINE vsaldo_rep money(14,2);
DEFINE vsaldo_dif money(14,2);
DEFINE vcuenta char(14);

LET vcodret = "000";
LET vsucursal = "";
LET vmes_act = "";
LET vsaldo_ant  = 0;
LET ventradas = 0;
LET vsalidas = 0;
LET vsaldo_calc = 0;
LET vsaldo_rep = 0;
LET vsaldo_dif = 0;
LET vcuenta = "";

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

--SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/saldostmp.out";
--trace on;

SELECT fecha_hoy INTO vfecha_hoy
FROM   bdicont:co_fechas;

SELECT valor INTO vcuenta
FROM   ss_param_cajagen
WHERE  codigo = "0025";

IF month(vfecha_hoy) = month(pfecha) THEN
   LET vmes_act = "S";
ELSE
   LET vmes_act = "N";
END IF

--- Verifica recepcion correcta de datos
IF pempresa = '' or pfecha = '' or
   pproveedor = '' or pusuario = '' then
   LET vcodret = "110";
   return vcodret;
ELSE
   delete from ss_saldostmp where usuario = pusuario;

   foreach
       select a.sucursal into vsucursal
       from   bdinteg:si_sucursales as a,
              bdisuc:ss_proveedores as b
       where  b.plaza = a.plaza_cajagen
       and    b.cod_proveedor = pproveedor
              order by a.sucursal

       foreach
            SELECT saldo_total,fecha INTO vsaldo_rep,vfecha_hoy
            FROM   ss_saldossuc
            WHERE  month(fecha) = month(pfecha)
            AND    sucursal = vsucursal
            ORDER BY fecha
            IF vsaldo_rep IS NULL THEN
               LET vsaldo_rep = 0;
            END IF
            LET vfecha_tmp = vfecha_hoy -1 units day;
            -- Calcula el saldo anterior restando un dia a la fecha hoy
            SELECT nvl(saldo_total,0) INTO vsaldo_ant
            FROM   ss_saldossuc
            WHERE  fecha = vfecha_tmp
            AND    sucursal = vsucursal;
            LET vfecha_tmp = vfecha_tmp;
            IF vsaldo_ant IS NULL THEN
               LET vsaldo_ant = 0;
            END IF
            -- Lee Saldos segun la variable de vmes_act
               LET  vfecha_hoy = vfecha_hoy;
               LET  vsucursal = vsucursal;
               LET  vcuenta[1,4]= vcuenta[1,4];
               LET  vcuenta[5,6] = vcuenta[5,6];
               LET  vcuenta[7,8] = vcuenta[7,8];
               LET  vcuenta[9,10] = vcuenta[9,10];
               LET  vcuenta[11,12]= vcuenta[11,12];

            IF vmes_act = "S" THEN
               SELECT NVL(sum(cargos_dia),0),NVL(sum(abonos_dia),0)
               INTO   ventradas,vsalidas
               FROM   bdicont:co_sdodias
               WHERE  mes_dia = vfecha_hoy
               AND    sucursal = vsucursal
               AND    ccmayor = vcuenta[1,4]
               AND    ccsub = vcuenta[5,6]
               AND    ccsubsub = vcuenta[7,8]
               AND    ccssubsub = vcuenta[9,10]
               AND    ccsssubsub = vcuenta[11,12];
               IF ventradas IS NULL THEN
                  LET ventradas = 0;
               END IF
               IF vsalidas IS NULL THEN
                  LET vsalidas = 0;
               END IF
            ELSE
               SELECT NVL(sum(cargos_dia),0),NVL(sum(abonos_dia),0)
               INTO   ventradas,vsalidas
               FROM   bdicont:co_histsdodias
               WHERE  mes_dia = vfecha_hoy
               AND    sucursal = vsucursal
               AND    ccmayor = vcuenta[1,4]
               AND    ccsub = vcuenta[5,6]
               AND    ccsubsub = vcuenta[7,8]
               AND    ccssubsub = vcuenta[9,10]
               AND    ccsssubsub = vcuenta[11,12];
               IF ventradas IS NULL THEN
                  LET ventradas = 0;
               END IF
               IF vsalidas IS NULL THEN
                  LET vsalidas = 0;
               END IF
            END IF

            -- Carga la Diferencia de Montos Anterior y Reportado
            LET vsaldo_calc = vsaldo_ant + ventradas - vsalidas;
            LET vsaldo_dif = vsaldo_rep - vsaldo_calc;

            -- Inserta los Datos Cargados para la IMpresuion del Reporte
            INSERT INTO ss_saldostmp (usuario,fecha_saldo,cod_proveedor,
                        sucursal,saldo_anterior,entradas,salidas,
                        saldo_actual,saldo_reportado,saldo_diferencia)
            values(pusuario,vfecha_hoy,pproveedor,vsucursal,vsaldo_ant,
                   ventradas,vsalidas,vsaldo_calc,vsaldo_rep,vsaldo_dif);

       end foreach

   end foreach
END IF;

RETURN vcodret;
END;
END PROCEDURE;