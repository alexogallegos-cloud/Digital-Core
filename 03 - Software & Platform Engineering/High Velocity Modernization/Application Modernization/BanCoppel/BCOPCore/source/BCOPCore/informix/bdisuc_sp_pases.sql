create procedure "informix".sp_pases(pempresa char(3), fecha_hoy date)

RETURNING CHAR(5), CHAR(4),INTEGER,DATE,INTEGER, INTEGER,INTEGER,DATE;

DEFINE vcodret           CHAR(5);
DEFINE vsqlerr           INTEGER;
DEFINE vsucursal_abrio   INTEGER;
DEFINE v_abrio           CHAR(1);
DEFINE v_sucursal        CHAR(4);
DEFINE v_cerro           INTEGER;
DEFINE v_poliza          INTEGER;
DEFINE v_sucabrio        INTEGER;
DEFINE v_procesada       INTEGER;
DEFINE vdias_antes       INTEGER;
DEFINE vfecha_ini        DATE;
DEFINE vfecha_valida     DATE;
DEFINE vfecha_captura    DATE;

-- *****************************************************************
-- Inicializa variables
-- *****************************************************************

LET vcodret         = "000";
LET vsqlerr         = 0;
LET vsucursal_abrio = 0;
LET v_abrio         ="";
LET v_sucursal      ="";
LET v_cerro         =0;
LET v_poliza        =0;
LET v_sucabrio      =0;
LET v_procesada     =0;
LET vdias_antes     =0;
LET vfecha_ini      = "";
LET vfecha_valida   = "";
LET vfecha_captura  ="";

BEGIN
   ON EXCEPTION SET vsqlerr
   IF vsqlerr <> 0 THEN
      LET vcodret = vsqlerr;
      RETURN vcodret, v_sucursal, v_poliza, vfecha_captura, v_abrio, v_cerro, v_procesada,vfecha_valida;
   END IF;
END EXCEPTION;

-- *****************************************************************
-- Valida los parametros de entrada
-- *****************************************************************

-- set debug file to "/pisa/pisabanco/pisa_ftes/sucursales.out";
-- trace on;

-- *****************************************************************
-- Extrae el Numero de Dias a Extraer Sucursales
-- *****************************************************************
   SELECT valor
   INTO   vdias_antes
   FROM ss_param_cajagen
   WHERE  codigo = "0099";
   IF vdias_antes IS NULL THEN
      LET vdias_antes = 0;
      LET vfecha_ini = fecha_hoy;
   ELSE
      LET vfecha_ini = fecha_hoy - vdias_antes UNITS DAY;
   END IF;

-- *****************************************************************
-- Valida la sucursal asignada,como el usuario del Pase Contable
-- *****************************************************************

   SELECT COUNT(suc_abrio)
   INTO v_sucabrio
   FROM ss_pase_sucursal
   WHERE fecha_pase between vfecha_ini AND fecha_hoy
   AND   suc_abrio = 1 ;


   SELECT COUNT(suc_cerro)
   INTO v_cerro
   FROM ss_pase_sucursal
   WHERE fecha_pase between vfecha_ini AND fecha_hoy
   AND   suc_cerro = 1 ;


   FOREACH
      SELECT  UNIQUE
         a.sucursal,
         b.control_poliza,
         b.fecha_valida,
         b.fecha_captura 
      INTO
         v_sucursal,v_poliza,vfecha_valida,vfecha_captura
      FROM
         ss_pase_sucursal a, bdicont:co_detpol b
      WHERE
         a.fecha_pase between vfecha_ini AND fecha_hoy AND
         a.fecha_pase = b.fecha_captura AND
         a.sucursal = b.usuario

      LET v_procesada     =0;


      IF EXISTS(SELECT 1 FROM bdicont:co_mensual
                WHERE control_poliza = v_poliza
                AND fecha_captura between vfecha_ini
                AND fecha_hoy AND secuencia = 1
                AND empresa = 001)THEN
         LET v_procesada = 1;
      ELSE
         IF v_procesada <> 1 THEN
            IF EXISTS (SELECT 1 FROM bdicont:co_historico
                       WHERE usuario = v_sucursal
                       AND control_poliza = v_poliza
                       AND fecha_captura between vfecha_ini
                       AND fecha_hoy AND secuencia = 1
                       AND empresa = 001)THEN
               LET v_procesada = 1;
            END IF
         END IF;
      END IF;


      RETURN vcodret, v_sucursal, v_poliza, vfecha_captura, v_sucabrio, v_cerro, v_procesada, vfecha_valida  WITH RESUME;

    END FOREACH

END
END PROCEDURE
;