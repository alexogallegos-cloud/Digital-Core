CREATE PROCEDURE "informix".cancela_resultados(p_empresa	CHAR(3))
   RETURNING CHAR(5);

   DEFINE codret                        CHAR(5);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);
   DEFINE GLOBAL v_fecha_hoy		DATE DEFAULT "";
   DEFINE GLOBAL v_fecha_ant            DATE DEFAULT "";
   DEFINE GLOBAL v_fecha_canc           CHAR(10) DEFAULT "";
   DEFINE GLOBAL v_prox_fecha  	 	DATE DEFAULT "";
   DEFINE v_pri_hab_mes                 DATE;
   DEFINE v_pri_dia_mes                 DATE;
   DEFINE v_begin                       CHAR(1);

{*************************************************************************
 **                  Variables de co_param                              **
 *************************************************************************}

   DEFINE v_mescierre1                  CHAR(2);
   DEFINE v_mescierre2                  CHAR(2);
   DEFINE v_moneda_nacional             CHAR(2);
   DEFINE v_anio_fiscal                 CHAR(2);
   DEFINE v_cta_ing_inic                CHAR(10);
   DEFINE v_cta_ing_final               CHAR(10);
   DEFINE v_cta_gto_inic                CHAR(10);
   DEFINE v_cta_gto_final               CHAR(10);
   DEFINE v_per_gan_mayor		CHAR(10);
   DEFINE v_per_gan_sub			CHAR(10);
   DEFINE v_per_gan_ss			CHAR(10);
   DEFINE v_per_gan_sss			CHAR(10);
   DEFINE v_per_gan_ssss		CHAR(10);
   DEFINE v_per_gan_sect                CHAR(10);

{*************************************************************************
 **              VARIABLES DE si_catalog                                **
 *************************************************************************}

   DEFINE GLOBAL v_ccmayor		CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccsub		CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccsubsub		CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccssubsub		CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_ccsssubsub		CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_sector		CHAR(10) DEFAULT "          ";
   DEFINE GLOBAL v_naturaleza_cta	CHAR(1) DEFAULT " ";
   DEFINE GLOBAL v_auxiliar		CHAR(1) DEFAULT " ";

{*************************************************************************
 **               VARIABLES PARA co_cance                               **
 *************************************************************************}

   DEFINE v_ciudad 			CHAR(3);
   DEFINE v_sucursal   			CHAR(4);
   DEFINE v_moneda			CHAR(2);
   DEFINE v_cargos                      MONEY(14,2);
   DEFINE v_abonos                      MONEY(14,2);
   DEFINE v_suma_cargos                 MONEY(14,2);
   DEFINE v_suma_abonos                 MONEY(14,2);

   DEFINE v_diferencia                  MONEY(14,2);
   DEFINE v_nat_movto			CHAR(1);
   DEFINE v_min_mesdia 			DATE;
   DEFINE v_sdo_inic                    MONEY(14,2);
   DEFINE v_sdo_fin                     MONEY(14,2);
   DEFINE v_fecha                       DATE;
   DEFINE v_dia_acum                    SMALLINT;
   DEFINE v_sdo_acum                    MONEY(14,2);
   DEFINE v_nrows                       SMALLINT;
   DEFINE lv_ano                        CHAR(4);
   DEFINE lv_mes                        CHAR(2);
   DEFINE lv_dia                        CHAR(2);
   DEFINE lv_cuantos                    SMALLINT;
   DEFINE ccosto_institucional          CHAR(4);


   {ON EXCEPTION SET sql_err, isam_err, error_info
      LET codret = sql_err;
      SET DEBUG FILE TO "Cancela_Resultados.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      IF (v_begin = "S") THEN
         ROLLBACK WORK;
      END IF;
      UPDATE
         co_contproc
      SET
         cod_ret = codret
      WHERE
         empresa = p_empresa
      AND
         fecha = v_fecha_hoy;

      RETURN codret;
   END EXCEPTION;}

--SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/contabilidad/cancela_resultados.out";
--TRACE ON;
{***********************************************************************
 ** Inicia la carga de parametros para la ejecucion del programa y se **
 ** activa el control de procesos                                     **
 ***********************************************************************}

   LET v_begin = "N";
   LET codret = "99999";

   FOREACH
     SELECT sucursal INTO ccosto_institucional FROM bdinteg:si_sucursales
     WHERE  nombre  LIKE '%OPERATIVO DE CONTABILIDAD%'
   END FOREACH;

   SELECT
      fecha_hoy,
      fecha_ant,
      prox_fecha,
      pri_dia_mes,
      pri_hab_mes
   INTO
      v_fecha_hoy,
      v_fecha_ant,
      v_prox_fecha,
      v_pri_dia_mes,
      v_pri_hab_mes
   FROM
      co_fechas
   WHERE
      empresa = p_empresa;

   LET lv_ano = YEAR(v_fecha_ant);
   LET lv_mes = MONTH(v_fecha_ant);
   IF lv_mes < 10 THEN
      LET lv_mes = "0"||lv_mes;
   END IF
   LET lv_dia = diasmes(lv_ano,lv_mes);
   IF lv_dia < 10 THEN
      LET lv_dia = "0"||lv_dia;
   END IF
   LET v_fecha_canc = TRIM(lv_mes)||TRIM(lv_dia)||TRIM(lv_ano);
   LET v_fecha_ant = v_fecha_canc;

   SELECT
      mescierre1,
      mescierre2,
      moneda_nacional,
      anio_fiscal,
      cta_ing_inic,
      cta_ing_final,
      cta_gto_inic,
      cta_gto_final,
      per_gan_mayor,
      per_gan_sub,
      per_gan_ss,
      per_gan_sss,
      per_gan_ssss,
      per_gan_sect
   INTO
      v_mescierre1,
      v_mescierre2,
      v_moneda_nacional,
      v_anio_fiscal,
      v_cta_ing_inic,
      v_cta_ing_final,
      v_cta_gto_inic,
      v_cta_gto_final,
      v_per_gan_mayor,
      v_per_gan_sub,
      v_per_gan_ss,
      v_per_gan_sss,
      v_per_gan_ssss,
      v_per_gan_sect
   FROM
      co_param
   WHERE
      empresa = p_empresa;

    ----cancelacion de resultados solo en 31-diciembre
    IF v_pri_hab_mes = v_fecha_hoy THEN
      ----IF (MONTH(v_fecha_ant) <> v_mescierre1 AND  10/11/2006 se inactiva el
      ----mescierre1
     IF MONTH(v_fecha_ant) <> v_mescierre2 THEN
          LET codret = "999";
          RETURN codret;
      END IF
   ELSE
      LET codret = "999";
      RETURN codret;
   END IF


   INSERT INTO
      co_contproc
   VALUES
      (p_empresa,
       "canresulta",
       v_fecha_hoy,
       codret);

   DELETE FROM co_cance
   WHERE empresa = p_empresa
   AND year(fecha) = year(v_fecha_ant)
   AND month(fecha) = month(v_fecha_ant);

{***********************************************************************
 ** Termina la carga de parametros para la ejecucion del programa e   **
 ** Inicia la transaccion de cancelacion de resultos NO RETROACTIVA   **
 ***********************************************************************}

   --BEGIN WORK;
   LET v_begin = "S";

--		DEFINE CURSOR CON CUENTAS A AFECTAR

   FOREACH
      SELECT
         ccmayor,
         ccsub,
         ccsubsub,
         ccssubsub,
         ccsssubsub,
         sector,
         naturaleza_cta,
         auxiliar
      INTO
         v_ccmayor,
         v_ccsub,
         v_ccsubsub,
         v_ccssubsub,
         v_ccsssubsub,
         v_sector,
         v_naturaleza_cta,
         v_auxiliar
      FROM
         bdinteg:si_catalog
      WHERE
         empresa = p_empresa
      AND
         (ccmayor BETWEEN v_cta_ing_inic AND v_cta_ing_final
      OR
         ccmayor BETWEEN v_cta_gto_inic AND v_cta_gto_final)
      AND
         tipo_cuenta = "D"
      ORDER BY
         1,2,3,4,5,6,7,8

      CALL Sdos_Sin_Auxiliar(p_empresa) RETURNING codret;
      IF (codret <> "000") THEN
         ROLLBACK WORK;
         UPDATE
            co_contproc
         SET
            cod_ret = codret
         WHERE
             empresa = p_empresa
         AND
            fecha = v_fecha_hoy;
      END IF;

      IF (v_auxiliar = "S") THEN
         CALL Sdos_Auxiliar(p_empresa) RETURNING codret;
         IF (codret <> "000") THEN
            ROLLBACK WORK;
            UPDATE
               co_contproc
            SET
               cod_ret = codret
            WHERE
               empresa = p_empresa
            AND
               fecha = v_fecha_hoy;
         END IF;
      END IF;

   END FOREACH;

{*************************************************************************
 **        GENERACION DE MOVIMIENTOS DE PERDIDAS Y GANACIAS             **
 ************************************************************************}


   FOREACH
      SELECT
         ciudad,
         sucursal,
         moneda,
         SUM(cargos),
         SUM(abonos)
      INTO
         v_ciudad,
         v_sucursal,
         v_moneda,
         v_cargos,
         v_abonos
      FROM
         co_cance
      WHERE
         empresa = p_empresa
      AND
         fecha = v_fecha_ant
      AND
         auxiliar = " "
      GROUP BY
         1,2,3
      ORDER BY
         1,2,3

    -----se verifica que exista la cuenta de perdidas y ganancias para el
    ------- c. costo INSTITUCIONAL
      select count(*)
      into lv_cuantos
      from co_cance
      where empresa  = p_empresa
      and fecha      = v_fecha_ant
      and ccmayor    = v_per_gan_mayor
      and ccsub      = v_per_gan_sub
      and ccsubsub   = v_per_gan_ss
      and ccssubsub  = v_per_gan_sss
      and ccsssubsub = v_per_gan_ssss
      and sector     = v_per_gan_sect
      --and ciudad     = v_ciudad
      --and sucursal   = v_sucursal
      and ciudad     = '900'
      and sucursal    = ccosto_institucional
      and moneda     = v_moneda;

-- v_cargos es la suma de saldos de cuentas de INGRESO
-- y v_abonos es la suma de saldos de cuentas de GASTO

      IF (v_cargos > v_abonos) THEN
         LET v_diferencia = v_cargos - v_abonos;
         LET v_nat_movto = "C";
         if lv_cuantos = 0 THEN
            INSERT INTO
               co_cance
            VALUES
               (p_empresa,
                v_fecha_ant,
                v_per_gan_mayor,
                v_per_gan_sub,
                v_per_gan_ss,
                v_per_gan_sss,
                v_per_gan_ssss,
                v_per_gan_sect,
                --v_ciudad,
                '900',
                --v_sucursal, --va al c. costo institucional 22/11/2006
                ccosto_institucional,
                v_moneda,
                " ",
                0,
                0,
                v_diferencia,
                0);
         else
            update co_cance
            set abonos = abonos + v_diferencia
            where empresa  = p_empresa
            and fecha      = v_fecha_ant
            and ccmayor    = v_per_gan_mayor
            and ccsub      = v_per_gan_sub
            and ccsubsub   = v_per_gan_ss
            and ccssubsub  = v_per_gan_sss
            and ccsssubsub = v_per_gan_ssss
            and sector     = v_per_gan_sect
            --and ciudad     = v_ciudad
            and ciudad     = '900'
            --and sucursal   = v_sucursal
            and sucursal   = ccosto_institucional
            and moneda     = v_moneda;
         end if
      ELSE
         IF (v_abonos > v_cargos) THEN
            LET v_diferencia = v_abonos - v_cargos;
            LET v_nat_movto = "D";
            if lv_cuantos = 0 THEN
               INSERT INTO
               co_cance
               VALUES
               (p_empresa,
                v_fecha_ant,
                v_per_gan_mayor,
                v_per_gan_sub,
                v_per_gan_ss,
                v_per_gan_sss,
                v_per_gan_ssss,
                v_per_gan_sect,
                --v_ciudad,
                '900',
                --v_sucursal,
                ccosto_institucional,
                v_moneda,
                " ",
                0,
                v_diferencia,
                0,
                0);
            else
               update co_cance
               set cargos = cargos + v_diferencia
               where empresa  = p_empresa
               and fecha      = v_fecha_ant
               and ccmayor    = v_per_gan_mayor
               and ccsub      = v_per_gan_sub
               and ccsubsub   = v_per_gan_ss
               and ccssubsub  = v_per_gan_sss
               and ccsssubsub = v_per_gan_ssss
               and sector     = v_per_gan_sect
               --and ciudad     = v_ciudad
               and ciudad     = '900'
               --and sucursal   = v_sucursal
               and sucursal       = ccosto_institucional
               and moneda     = v_moneda;
            end if
         ELSE
            LET v_diferencia = 0;
         END IF;
      END IF;
   END FOREACH;


{*************************************************************************
 **     ACTUALIZA CUENTAS O GANANCIAS EN SALDOS INICIAL Y FINAL         **
 *************************************************************************}


   FOREACH
      SELECT
         a.ccmayor,
         a.ccsub,
         a.ccsubsub,
         a.ccssubsub,
         a.ccsssubsub,
         a.sector,
         a.ciudad,
         a.sucursal,
         a.moneda,
         a.auxiliar,
         a.cargos,
         a.abonos,
         b.naturaleza_cta
      INTO
         v_ccmayor,
         v_ccsub,
         v_ccsubsub,
         v_ccssubsub,
         v_ccsssubsub,
         v_sector,
         v_ciudad,
         v_sucursal,
         v_moneda,
         v_auxiliar,
         v_cargos,
         v_abonos,
         v_naturaleza_cta
      FROM
         co_cance a,
         bdinteg:si_catalog b
      WHERE
         a.empresa    = p_empresa
      AND
         month(a.fecha) = month(v_fecha_ant)
      AND
         year(a.fecha) = year(v_fecha_ant)
      AND
         a.ccmayor    = v_per_gan_mayor
      AND
         a.ccsub      = v_per_gan_sub
      AND
         a.ccsubsub   = v_per_gan_ss
      AND
         a.ccssubsub  = v_per_gan_sss
      AND
         a.ccsssubsub = v_per_gan_ssss
      AND
         a.sector     = v_per_gan_sect
      AND
         b.empresa    = a.empresa
      AND
         b.ccmayor    = a.ccmayor
      AND
         b.ccsub      = a.ccsub
      AND
         b.ccsubsub   = a.ccsubsub
      AND
         b.ccssubsub  = a.ccssubsub
      AND
         b.ccsssubsub = a.ccsssubsub
      AND
         b.sector     = a.sector

      ORDER BY
         7,8,9,1,2,3,4,5,6

         SELECT
            MIN(mes_dia)
         INTO
            v_min_mesdia
         FROM
            co_sdodias
         WHERE
            empresa    = p_empresa
         AND
            ccmayor    = v_ccmayor
         AND
            ccsub      = v_ccsub
         AND
            ccsubsub   = v_ccsubsub
         AND
            ccssubsub  = v_ccssubsub
         AND
            ccsssubsub = v_ccsssubsub
         AND
            sector     = v_sector
         AND
            ciudad     = v_ciudad
         AND
            sucursal   = v_sucursal
         AND
            moneda     = v_moneda
         AND
           MONTH(mes_dia) = MONTH(v_fecha_hoy)
         AND
           YEAR(mes_dia)  = YEAR(v_fecha_hoy);


         SELECT
            saldo_inicio_dia
         INTO
            v_sdo_inic
         FROM
            co_sdodias
         WHERE
            empresa    = p_empresa
         AND
            ccmayor    = v_ccmayor
         AND
            ccsub      = v_ccsub
         AND
            ccsubsub   = v_ccsubsub
         AND
            ccssubsub  = v_ccssubsub
         AND
            ccsssubsub = v_ccsssubsub
         AND
            sector     = v_sector
         AND
            ciudad     = v_ciudad
         AND
            sucursal   = v_sucursal
         AND
            moneda     = v_moneda
         AND
            mes_dia    = v_min_mesdia;

         LET v_nrows = dbinfo("sqlca.sqlerrd2");
         IF (v_nrows <> 0) THEN
            IF (v_naturaleza_cta = "D") THEN
               LET v_sdo_fin = v_sdo_inic + v_cargos - v_abonos;
            ELSE
               LET v_sdo_fin = v_sdo_inic + v_abonos - v_cargos;
            END IF;

         ELSE
            LET v_sdo_inic = 0;
            IF (v_naturaleza_cta = "D") THEN
               LET v_sdo_fin = v_sdo_inic + v_cargos - v_abonos;
            ELSE
               LET v_sdo_fin = v_sdo_inic + v_abonos - v_cargos;
            END IF;
         END IF;



         UPDATE
            co_cance
         SET
            saldo_inicio = v_sdo_inic,
            saldo_fin    = v_sdo_fin
         WHERE
            empresa    = p_empresa
         AND
            fecha      = v_fecha_ant
         AND
            ccmayor    = v_ccmayor
         AND
            ccsub      = v_ccsub
         AND
            ccsubsub   = v_ccsubsub
         AND
            ccssubsub  = v_ccssubsub
         AND
            ccsssubsub = v_ccsssubsub
         AND
            sector     = v_sector
         AND
            ciudad     = v_ciudad
         AND
            sucursal   = v_sucursal
         AND
            moneda     = v_moneda;


   END FOREACH;


{************************************************************************
 **    ACTUALIZACION DE DE co_sdodias Y co_diasaux PARA CUENTAS DE     **
 **    DE INGRESOS Y EGRESOS A SIGUIENTE EJERCICIO                     **
 ************************************************************************}

   UPDATE
      co_sdodias
   SET
      cargos_dia       = 0,
      abonos_dia       = 0,
      nro_cargos_dia   = 0,
      nro_abonos_dia   = 0,
      dias_acumulado   = 0,
      dias_proyectado  = 0,
      saldo_acumulado  = 0,
      saldo_inicio_dia = 0,
      saldo_fin_de_dia = 0
   WHERE
      empresa    = p_empresa
   AND
      (ccmayor BETWEEN v_cta_ing_inic AND v_cta_ing_final
   OR
      ccmayor BETWEEN v_cta_gto_inic AND v_cta_gto_final);


   UPDATE
      co_diasaux
   SET
      cargos_dia       = 0,
      abonos_dia       = 0,
      nro_cargos_dia   = 0,
      nro_abonos_dia   = 0,
      dias_acumulados  = 0,
      dias_proyectado  = 0,
      saldo_acumulado  = 0,
      saldo_inicio_dia = 0,
      saldo_fin_de_dia = 0
   WHERE
      empresa    = p_empresa
   AND
      (ccmayor BETWEEN v_cta_ing_inic AND v_cta_ing_final
   OR
      ccmayor BETWEEN v_cta_gto_inic AND v_cta_gto_final);


   FOREACH
      SELECT
         ccmayor,
         ccsub,
         ccsubsub,
         ccssubsub,
         ccsssubsub,
         sector,
         ciudad,
         sucursal,
         moneda,
         auxiliar,
         saldo_inicio,
         cargos,
         abonos,
         saldo_fin
      INTO
         v_ccmayor,
         v_ccsub,
         v_ccsubsub,
         v_ccssubsub,
         v_ccsssubsub,
         v_sector,
         v_ciudad,
         v_sucursal,
         v_moneda,
         v_auxiliar,
         v_sdo_inic,
         v_cargos,
         v_abonos,
         v_sdo_fin
      FROM
         co_cance
      WHERE
         empresa    = p_empresa
      AND
         fecha      = v_fecha_ant
      AND
         ccmayor    = v_per_gan_mayor
      AND
         ccsub      = v_per_gan_sub
      AND
         ccsubsub   = v_per_gan_ss
      AND
         ccssubsub  = v_per_gan_sss
      AND
         ccsssubsub = v_per_gan_ssss
      AND
         sector     = v_per_gan_sect
      ORDER BY
         7,8,9,1,2,3,4,5,6

      LET v_fecha = v_pri_dia_mes;
      LET v_dia_acum = 0;
      LET v_sdo_acum = 0;
      WHILE v_fecha <= v_fecha_hoy
         LET v_dia_acum = v_dia_acum + 1;
         LET v_sdo_acum = v_sdo_acum + v_sdo_fin;
         UPDATE
            co_sdodias
         SET
            saldo_inicio_dia  = v_sdo_fin,
            saldo_acumulado   = v_sdo_fin,
            dias_acumulado    = v_dia_acum,
            saldo_fin_de_dia  = v_sdo_fin,
            cargos_dia        = cargos_dia + v_cargos,
            abonos_dia        = abonos_dia + v_abonos
         WHERE
            empresa    = p_empresa
         AND
            ccmayor    = v_ccmayor
         AND
            ccsub      = v_ccsub
         AND
            ccsubsub   = v_ccsubsub
         AND
            ccssubsub  = v_ccssubsub
         AND
            ccsssubsub = v_ccsssubsub
         AND
            sector     = v_sector
         AND
            moneda     = v_moneda
         AND
            --ciudad     = v_ciudad
            ciudad     = '900'
         AND
            --sucursal   = v_sucursal
            sucursal   = ccosto_institucional
         AND
            mes_dia    = v_fecha;

         LET v_nrows = dbinfo("sqlca.sqlerrd2");
         IF (v_nrows = 0) THEN
            INSERT INTO
               co_sdodias
            VALUES
               (p_empresa,
                v_ccmayor,
                v_ccsub,
                v_ccsubsub,
                v_ccssubsub,
                v_ccsssubsub,
                v_sector,
                --v_ciudad,
                '900',
                --v_sucursal,
                ccosto_institucional,
                v_moneda,
                v_fecha,
                0,
                0,
                0,
                0,
                0,
                v_dia_acum,
                v_sdo_acum,
                v_sdo_fin,
                v_sdo_fin);
         END IF;
         LET v_fecha = v_fecha + 1 UNITS DAY;
         
      END WHILE;
   END FOREACH

   --COMMIT WORK;

   UPDATE
      co_contproc
   SET
      cod_ret = codret
   WHERE
      empresa = p_empresa
   AND
      fecha = v_fecha_hoy;

   DELETE FROM bdicont:co_ctrlpoliza;
   INSERT INTO bdicont:co_ctrlpoliza(num_sec,numero) values('1',0);

   RETURN codret;
END PROCEDURE
DOCUMENT
"Proceso de cancelacion de resultados, se graban las tablas de ",
"co_cance para la cancelacion normal y co_canret cuando es cancelacion",
"retroactiva",
"Ver.  : 1.0",
"Mod.  : ",
"BD.   : bdicont";

create procedure "informix".carga_diaria(pempresa char(3),pfecha_hoy date)
returning char(5);
--#***************************************************************************#
--#                                                                           #
--#   ESTA FUNCION CARGA LA TABLA DE MOVIMIENTOS DIARIOS DE DETERMINADA       #
--#   FECHA Y COMPANIA, POSTERIORMENTE DEBE REALIZAR EL PROCESO VALIDACION    #
--#   DE MOVIMIENTOS DEL DIA                                                  #
--#   co_movdia        --> Tabla primaria de lectura                          #
--#                                                                           #
--#***************************************************************************#

define cod_ret     char(5);
define w_dd        char(2);
define w_dd2       char(2);
define w_mm2       char(2);
define w_mm        char(2);
define w_year      char(4);
define w_a         char(1);
define fecha_movto date;
define w_proceso   char(20);
define v_dia_mes   char(4);
define v_nomtabla  char(70);
define v_sql       char(200);
define vmovtos     char(200);
define v_moneda      char(3);
define v_moneda2     char(3);
define v_tipmov      char(1);
define v_cargo_abono char(1);
define v_ccsub       char(2);
define v_ccsubsub    char(2);
define v_ccssubsub   char(2);
define v_ccsssubsub  char(2);
define v_sector      char(2);
define v2_sector     char(2);
define v_division    char(2);
define v_dd          char(2);
define v_mm          char(2);
define vw_moneda     char(2);
define v_ccmayor     char(4);
define v_ccaa        char(4);
define v_num_poliza3 char(5);
define w_sig_numpoliza char(5);
define w_sig_numpoliza2 char(5);
define v_usuario2    char(8);
define v_descripcion char(50);
define v_fecha       date;
define w_fecha       char(8);
define v_cis         char(9);
define v_secuencia   integer;
define num_reg       integer;
define i             integer;
define v_cuantos     integer;
define v_tipcamxp    money(15,5);
define v_tipcamb     money(15,5);
define v_importe     money(18,2);
define v_impmonloc   money(18,2);
define v_cliente     char(7);
define v_sectoriza_cta char(1);
define resp          char(1);
define v_auxiliar    char(1);
define v_nro_auxiliar char(9);
define v_usuario char (8);
define vruta_respaldo char(40);

begin work;
lock table co_detpol in exclusive mode;
delete from co_detpol
where empresa = pempresa
and   fecha_captura = pfecha_hoy;
commit work;

begin work;
lock table co_poliza in exclusive mode;
delete from bdicont:co_poliza
where empresa = pempresa
and   fecha_captura = pfecha_hoy;
commit work;

let cod_ret = "000";
begin work;
lock table co_tabmovdia in exclusive mode;
delete from co_tabmovdia;
commit work;

select fecha
into fecha_movto
from co_contproc
where proceso = "movtosdia"
and empresa = pempresa;

delete
from co_contproc
where fecha_movto = pfecha_hoy
and empresa = pempresa;

let w_dd = day(pfecha_hoy);
let w_mm = month(pfecha_hoy);
let w_year = year(pfecha_hoy);
let w_a    = w_year[4,4];

if w_dd <= 9 then
   let w_dd2 = w_dd;
   let w_dd = "0"||w_dd2;
end if

if w_mm <= 9 then
   let w_mm2 = w_mm;
   let w_mm = "0"||w_mm2;
end if

let v_dia_mes = trim(w_dd)||w_mm;

select ruta_respaldo
into vruta_respaldo
from co_param
where empresa = pempresa;

let v_nomtabla = trim(vruta_respaldo)||
                 "/importadatos/mup"||v_dia_mes||w_a||".txt";
begin work;
lock table co_movdia in exclusive mode;
delete from co_movdia;
commit work;
let v_sql = "echo "||'"'|| "file '"||TRIM(v_nomtabla)||"' delimiter '|' 1"
            || "; insert into co_movdia;"||'"'||' > carga';
SYSTEM v_sql;

let v_sql = "dbload -d bdicont -c carga -l er -n 100";
SYSTEM v_sql;

select count(*)
into v_cuantos
from co_movdia
where registro[26,27] = w_dd
and   registro[24,25] = w_mm
and   registro[20,23] = w_year;

if v_cuantos = 0 then
   let cod_ret = "999";
   return cod_ret;
end if

select count(*)
into num_reg
from co_movdia
where registro[62,64] not in (select num_lote from co_mapeo_lotes
                              where empresa = pempresa)
and   registro[5,7] = pempresa;

let i = 0;
select max(control_poliza) into w_sig_numpoliza
from co_detpol
where usuario = "informix"
and fecha_captura = pfecha_hoy
and empresa = pempresa;

if w_sig_numpoliza is null or w_sig_numpoliza = " " then
   let w_sig_numpoliza = "0";
end if
select max(control_poliza) into w_sig_numpoliza2
from co_poliza
where usuario = "informix"
and fecha_captura = pfecha_hoy;
if w_sig_numpoliza2 is null or w_sig_numpoliza2 = " " then
   let w_sig_numpoliza2 = "0";
end if

if w_sig_numpoliza >= w_sig_numpoliza2 then
   let w_sig_numpoliza = w_sig_numpoliza ;
   let v_num_poliza3 = w_sig_numpoliza;
else
   let w_sig_numpoliza2 = w_sig_numpoliza2 ;
   let v_num_poliza3 = w_sig_numpoliza2;
end if
let v_moneda2 = " ";


   select * from co_movdia into temp tx with no log;

foreach
   select registro
   into  vmovtos
   from tx
   where registro[62,64] not in (select num_lote from co_mapeo_lotes
                                 where empresa = pempresa)
   and   registro[5,7] = pempresa
   order by
   registro[38,40]

   let i             = i + 1;
   let v_moneda      = "  ";
   let v_usuario     = vmovtos[100,106];
   let v_secuencia   =  i;
   let v_dd          = vmovtos[26,27];
   let v_mm          = vmovtos[24,25];
   let v_ccaa        = vmovtos[20,23];
   let v_descripcion = vmovtos[62,91];
   let v_cis         = vmovtos[9,17];
   let v_importe     = vmovtos[42,56];
   let v_moneda      = vmovtos[38,40];
   let v_tipcamxp    = 0;
   let v_impmonloc   = 0;
   let v_tipmov      = vmovtos[59,60];
   let v_tipcamb     = 0;
   let v_cliente     = vmovtos[100,106];
   let v_importe     = v_importe / 100;

   if v_num_poliza3 is null or v_num_poliza3 = " " then
	let v_usuario2 = "informix";
	let v_num_poliza3 = "1";
      let v_moneda2 = v_moneda;
   else
      if v_moneda != v_moneda2 then
         let v_num_poliza3 = v_num_poliza3 + 1;
         let v_moneda2 = v_moneda;
      end if
   end if

   -- Valida la moneda
   select moneda into vw_moneda
   from co_mapeo_divisas
   where divisa_ext = v_moneda;

   let v_moneda = null;
   let v_ccmayor = " ";
   let v_nro_auxiliar = " ";

   -- Extrae equivalencia de la cuenta nacional
   select ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector
   into   v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub, v_ccsssubsub, v_sector
   from co_mapeo_nuevo
   where cuenta_ext = v_cis
   and empresa = pempresa
   and moneda = vw_moneda;

   --Valida si la Cuenta sectoriza o NO
   let v_sectoriza_cta = " ";
   let v_auxiliar = " ";
   select sectoriza_cta,auxiliar into v_sectoriza_cta,v_auxiliar
   from bdinteg:si_catalog
   where  bdinteg:si_catalog.empresa = pempresa and
          bdinteg:si_catalog.ccmayor = v_ccmayor and
          bdinteg:si_catalog.ccsub   = v_ccsub and
          bdinteg:si_catalog.ccsubsub = v_ccsubsub and
          bdinteg:si_catalog.ccssubsub = v_ccssubsub and
          bdinteg:si_catalog.ccsssubsub = v_ccsssubsub and
          bdinteg:si_catalog.sector = v_sector;

   if v_sectoriza_cta = "S" then
       -- Extrae el sector de Acuerdo al Nuevo Catalogo
       let v2_sector = " ";
       select sector
       into v2_sector
       from co_mapeo_cte
       where numero = v_cliente
       and empresa = pempresa;

       if v2_sector is null then
 	    let v_sector = null;
       end if
       if v2_sector != v_sector then
          let v_sector = v2_sector;
       end if
   end if

   if v_auxiliar = "S" then
      let v_nro_auxiliar = v_cliente;
   else
      let v_nro_auxiliar = "    ";
   end if

    if v_tipmov = "D" then
	 let v_cargo_abono = "D";
    else
       if v_tipmov = "C" then
	    let v_cargo_abono = "C";
       end if
    end if

   let w_fecha = v_mm||v_dd||v_ccaa;
   let v_fecha = w_fecha;

   insert into co_tabmovdia
   values(pempresa, v_ccmayor, v_ccsub, v_ccsubsub, v_ccssubsub,
          v_ccsssubsub , v_sector, "001", "001", v_cargo_abono, v_importe,
          v_descripcion, v_fecha,"informix", v_fecha, v_num_poliza3,
          vw_moneda, v_cis, v_secuencia, v_cliente, v_tipmov,v_moneda);
end foreach
return cod_ret;
end procedure;