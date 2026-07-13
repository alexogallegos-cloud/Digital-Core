CREATE PROCEDURE "informix".tmpactualiza_proy_cierre(pempresa CHAR(3))

RETURNING CHAR(5), INTEGER;
-- ***********************************************************************************************
-- tmpactualiza_proy_cierre
-- Version              1.0.0
-- Objetivo:            SPL de prueba (actualiza montos y periodo meta en sc_tasa_variable)
-- Supuestos:           Ninguno
-- Creado por:
-- ModIFicado por:      Alejandro Rueda Sanchez
-- Ultima Modificacion: Agosto - 2008
--                      Creación de SPL
-- *************************************************************************************************

--//Definicion de variables
   DEFINE vcodret     CHAR(5);
   DEFINE vsucursal   CHAR(4);
   DEFINE vusuario    CHAR(8);
   DEFINE pcuenta     CHAR(20);
   DEFINE vtasatotal  DECIMAL(4,2);
   DEFINE vfecha_ini  DATE;
   DEFINE vfecha_fin  DATE;
   DEFINE vtasa       DECIMAL(4,2);
   DEFINE vmonto_int  MONEY(14,2);
   DEFINE vmonto_tot  MONEY(14,2);
   DEFINE pmonto  MONEY(14,2);
   DEFINE i           SMALLINT;
   DEFINE vtipo_tasa  CHAR(1);
   DEFINE vmontoprom  DECIMAL(14,2);
   DEFINE vtisr	      DECIMAL(9,6);
   DEFINE sql_err     INTEGER;
   DEFINE vint_acum   DECIMAL(14,2);
   DEFINE pproducto   CHAR(4);
   DEFINE vmotivo     CHAR(100);
   DEFINE vinicio_periodo DATE;
   DEFINE vfin_periodo  DATE;
   DEFINE vinteres_acum MONEY(14,2);
   DEFINE vtiptasa     CHAR(1);
   DEFINE vt_fechalta  DATE;
   DEFINE vt_cuantos   INTEGER;


   LET vcodret    = "000";
   LET vsucursal  = "0000";
   LET pproducto  = "1100";
   LET vusuario   = "informix";

   LET vfecha_ini = "";
   LET vfecha_fin = "";
   LET vtasa      = 0;
   LET vmonto_int = 0;
   LET vmontoprom = 0;
   LET vmonto_tot = 0;
   LET pmonto     = 0;
   LET vtasa      = "";
   LET vtipo_tasa = "";
   LET vtisr      = 0;
   LET sql_err    = 0;
   LET vt_cuantos = 0;

   BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vcodret = sql_err;
         RETURN vcodret, vt_cuantos;
      END IF;
   END EXCEPTION;


   --set debug file to "/tmp/tmpactualiza_proy_cierre.out";
   --trace on;

   CREATE TEMP TABLE temporal (vcodret CHAR(5),
                               pcuenta CHAR(20),
                               vinicio_periodo date,
                               vfin_periodo date,
                               vinteres_acum money(14,2),
                               vtiptasa char(1), 
                               vmotivo char(100),
                               pmonto  money(14,2));

   SET ISOLATION TO DIRTY READ;

   FOREACH
       SELECT mae.cuenta,mae.imp_chq_rem, noc.fecha_alta
         INTO pcuenta, pmonto, vt_fechalta
         FROM sc_maechq mae, sc_maenoc noc
        WHERE producto = pproducto
          AND mae.empresa = '001'
          AND mae.status_cta = 1
          AND mae.empresa = noc.empresa
          AND mae.cuenta = noc.cuenta
          AND noc.fecha_alta <= '04/30/2008'
    --      AND mae.cuenta = '11000109390'

       IF vt_fechalta IS NULL THEN
          LET vcodret = '999';
          EXIT FOREACH;
       END IF;

       LET vt_cuantos = vt_cuantos + 1;
         
       LET i = 1;
       LET vint_acum = 0;

      FOREACH
          EXECUTE FUNCTION tmp_proyeccionsc(pempresa, vsucursal, vusuario, pproducto, pmonto, vt_fechalta)
             INTO vcodret,vfecha_ini,vfecha_fin, vtasa, vmonto_int, vtasatotal, vmonto_tot, vmontoprom, vtisr
             IF trim(vcodret) <> "000" THEN
                RETURN vcodret, vt_cuantos;
             END IF;
   
          SELECT tipo_tasa
            INTO vtipo_tasa
            FROM bdinteg:si_tasa_mes
           WHERE valor_tasa = vtasa
             AND mes = i;
          IF vtipo_tasa <> "P" THEN
             LET vint_acum = vint_acum + vmonto_int;
          ELSE
             LET vmonto_int = vmonto_int - vint_acum;
          END IF
       
          LET vtiptasa = "X";
          LET vmotivo = "";
   
          SELECT inicio_periodo, fin_periodo, int_acum, tipo_tasa
            INTO vinicio_periodo, vfin_periodo, vinteres_acum, vtiptasa
            FROM sc_tasa_variable
           WHERE empresa = pempresa
             AND cuenta = pcuenta
             AND inicio_periodo = vfecha_ini
             AND tipo_tasa = vtipo_tasa;
          
          IF vtiptasa = "X" THEN
             EXIT FOREACH;
          END IF
          IF vfecha_fin <> vfin_periodo THEN
             UPDATE sc_tasa_variable
                SET fin_periodo = vfecha_fin
              WHERE empresa = pempresa
                AND cuenta = pcuenta
                AND inicio_periodo = vfecha_ini
                AND tipo_tasa = vtipo_tasa;
          END IF
          IF vmonto_int <> vinteres_acum THEN
             UPDATE sc_tasa_variable
                SET int_acum = vmonto_int
              WHERE empresa = pempresa
                AND cuenta = pcuenta
                AND inicio_periodo = vfecha_ini
                AND tipo_tasa = vtipo_tasa;
          END IF

          LET i = i +1;
   
      END FOREACH;
   END FOREACH;
   END
   RETURN vcodret, vt_cuantos;
END PROCEDURE;