CREATE PROCEDURE "informix".sp_cons_info_cobro_isr(p_empresa VARCHAR(3))
RETURNING VARCHAR(5);

DEFINE vcomienza           SMALLINT;
DEFINE vcomienza_1         SMALLINT;
DEFINE vcomienza_2         SMALLINT;
DEFINE vcomienza_3         SMALLINT;
DEFINE ven_transacc        SMALLINT;
DEFINE ven_transacc_1      SMALLINT;
DEFINE ven_transacc_2      SMALLINT;
DEFINE ven_transacc_3      SMALLINT;
DEFINE vBuscaTablas        SMALLINT;
DEFINE num_mes_hoy         SMALLINT;
DEFINE num_mes_sol         SMALLINT;
DEFINE num_mes_busca       SMALLINT;
DEFINE vcontador           INTEGER;
DEFINE vcontador_1         INTEGER;
DEFINE vcontador_2         INTEGER;
DEFINE vcontador_3         INTEGER;
DEFINE vsqlerr             INTEGER;
DEFINE v_monto_tot         DECIMAL(18,2);
DEFINE v_cuenta       	   VARCHAR(20);
DEFINE vcodret             VARCHAR(5);
DEFINE vfecha_hoy          DATE;
DEFINE vult_mes_ant        DATE;
DEFINE vpri_mes_ant        DATE;
DEFINE vfecha_actual       DATE;
DEFINE dFechaIniMovHis     DATE;
DEFINE dFechaIniMovHisOld  DATE;

LET vcomienza           = -1;
LET vcomienza_1         = -1;
LET vcomienza_2         = -1;
LET vcomienza_3         = -1;
LET ven_transacc        = 0;
LET ven_transacc_1      = 0;
LET ven_transacc_2      = 0;
LET ven_transacc_3      = 0;
LET vcontador           = 0;
LET vcontador_1         = 0;
LET vcontador_2         = 0;
LET vcontador_3         = 0;
LET vBuscaTablas        = 0;
LET num_mes_hoy         = 0;
LET num_mes_sol         = 0;
LET num_mes_busca       = 0;
LET vsqlerr             = 0;
LET v_monto_tot         = 0;
LET v_cuenta            = '';
LET vcodret             = "000";
LET vfecha_hoy          = '';
LET vult_mes_ant        = '';
LET vpri_mes_ant        = '';
LET vfecha_actual       = '';
LET dFechaIniMovHis     = '';
LET dFechaIniMovHisOld  = '';


BEGIN

   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
	     SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cons_info_cobro_isr.err";
         TRACE ON;

         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   

   /*
   sc_movdia        (Solo contiene 1 dia)
   sc_movhis        (Solo tiene 3 meses de InformaciÃ³n)
   sc_movhis_old    (Solo contiene hasta  01/01/2025   al  23/05/2025
   sc_movhis_old2   Todo 2024
   sc_movhis_old3   Todo 2023
   sc_movhis_old4   Todo 2022
   (ActualizaciÃ³n los primeros dias de Marzo)
   */
   
   --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cons_info_cobro_isr.out";
	--TRACE ON;

   SELECT fecha_hoy, pri_dia_mes - 1 UNITS DAY, pri_dia_mes - 1 UNITS MONTH
     INTO vfecha_hoy, vult_mes_ant, vpri_mes_ant
     FROM bdicheq:sc_fechas
    WHERE empresa = p_empresa;

   -- // OBTIENE PARAMETROS PARA BUSQUEDAS EN HISTORICOS DE MOVIMIENTOS
   SELECT valor INTO dFechaIniMovHis
     FROM bdicheq:sc_param
    WHERE empresa = p_empresa
      AND codparam = 'fechcon_movhis';

   SELECT valor INTO dFechaIniMovHisOld
     FROM bdicheq:sc_param
    WHERE empresa = p_empresa
      AND codparam = 'FechIniCon_movhis_ol';


   IF vpri_mes_ant >= dFechaIniMovHisOld AND vult_mes_ant <= (dFechaIniMovHis -1) THEN
      LET vBuscaTablas = 1;        ---  MovHisOld
   ELSE
      IF vpri_mes_ant >= dFechaIniMovHis AND vult_mes_ant >= (dfechaIniMovHis -1) THEN
         LET vBuscaTablas = 2;     ---  MovHis
      ELSE
         LET vBuscaTablas = 3;     ---  MovHis & MovHisOld
      END IF;
   END IF;

   LET vfecha_actual = vpri_mes_ant;

   -- // MOVIMIENTOS DE PAGO DE INTERESES DEL SISTEMA DE CHEQUES
   IF EXISTS (SELECT dbsname, tabname
                FROM sysmaster:systabnames
               WHERE partnum > 0
                 AND tabname = 'movs_3276') THEN
      TRUNCATE TABLE bdicheq:movs_3276;
   ELSE
      CREATE TABLE bdicheq:movs_3276
         (
          cuenta        VARCHAR(20),
          monto_tot     DECIMAL(18,2)
         )IN dbs_datos09 
      EXTENT SIZE 1000 NEXT SIZE 100 LOCK MODE ROW;
      CREATE INDEX idxtmp_mov3276 ON bdicheq:movs_3276(cuenta) IN idx_info04 ONLINE;
   END IF;


   IF (vBuscaTablas = 1) THEN
      WHILE vfecha_actual <= vult_mes_ant
         FOREACH cur_01h WITH HOLD FOR
            SELECT cuenta, monto_tot INTO v_cuenta, v_monto_tot
              FROM bdicheq:sc_movhis_old
             WHERE fech_alt = vfecha_actual
               AND transacc = '3276'
               AND cancelad <> 'S'

            -- Abre la transaccion
            IF (vcomienza = -1) THEN
               LET vcomienza = 0;
               LET ven_transacc = 1;
               BEGIN WORK;
            END IF;

            INSERT INTO bdicheq:movs_3276 VALUES(v_cuenta, v_monto_tot);

            LET vcontador = vcontador + 1;

            --Realiza commit cada 1000 registros
            IF (vcontador >= 1000) THEN
               LET vcontador = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF;
        END FOREACH;

        LET vfecha_actual = vfecha_actual + 1;

      END WHILE;

      --Si la transaccion esta abierta realiza el commit
      IF (ven_transacc = 1) THEN
         LET ven_transacc = 0;
         COMMIT WORK;
      END IF;
   END IF;


   IF (vBuscaTablas = 2) THEN
      WHILE vfecha_actual <= vult_mes_ant
         FOREACH cur_02h WITH HOLD FOR
            SELECT cuenta, monto_tot INTO v_cuenta, v_monto_tot
              FROM bdicheq:sc_movhis
             WHERE fech_alt = vfecha_actual
               AND transacc = '3276'
               AND cancelad <> 'S'

            -- Abre la transaccion
            IF (vcomienza_1 = -1) THEN
               LET vcomienza_1 = 0;
               LET ven_transacc_1 = 1;
               BEGIN WORK;
            END IF;

            INSERT INTO bdicheq:movs_3276 VALUES (v_cuenta, v_monto_tot);

            LET vcontador_1 = vcontador_1 + 1;

            --Realiza commit cada 1000 registros
            IF (vcontador_1 >= 1000) THEN
               LET vcontador_1 = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF;

         END FOREACH;

	     LET vfecha_actual = vfecha_actual + 1;
      END WHILE;

      --Si la transaccion esta abierta realiza el commit
      IF (ven_transacc_1 = 1) THEN
         LET ven_transacc_1 = 0;
         COMMIT WORK;
      END IF;
   END IF;


   IF (vBuscaTablas = 3) THEN
      WHILE vfecha_actual <= vult_mes_ant
         FOREACH cur_03h WITH HOLD FOR
            SELECT cuenta, monto_tot INTO v_cuenta, v_monto_tot
              FROM (SELECT cuenta, monto_tot
                      FROM bdicheq:sc_movhis_old
                     WHERE fech_alt = vfecha_actual
                       AND transacc = '3276'
                       AND cancelad <> 'S'
                    UNION
                    SELECT cuenta, monto_tot
                      FROM bdicheq:sc_movhis
                     WHERE fech_alt = vfecha_actual
                       AND transacc = '3276'
                       AND cancelad <> 'S') AS cunsulta_union

            -- Abre la transaccion
            IF (vcomienza_2 = -1) THEN
               LET vcomienza_2 = 0;
               LET ven_transacc_2 = 1;
               BEGIN WORK;
            END IF;

            INSERT INTO bdicheq:movs_3276 VALUES (v_cuenta, v_monto_tot);

            LET vcontador_1 = vcontador_1 + 1;

            --Realiza commit cada 1000 registros
            IF (vcontador_2 >= 1000) THEN
               LET vcontador_2 = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF;

		 END FOREACH;

         LET vfecha_actual = vfecha_actual + 1;
      END WHILE;

      --Si la transaccion esta abierta realiza el commit
      IF (ven_transacc_2 = 1) THEN
         LET ven_transacc_2 = 0;
         COMMIT WORK;
      END IF;
   END IF;

   UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:movs_3276;

   IF EXISTS (SELECT dbsname, tabname
                FROM sysmaster:systabnames
               WHERE partnum > 0
                 AND tabname = 'movs_int') THEN

      TRUNCATE TABLE bdicheq:movs_int;
   ELSE
      CREATE TABLE bdicheq:movs_int
         (
          cuenta        VARCHAR(20),
          monto_int     DECIMAL(18,2)
         )IN dbs_datos09 
      EXTENT SIZE 1000 NEXT SIZE 100 LOCK MODE ROW; 
      CREATE INDEX idxtmp_movint ON bdicheq:movs_int(cuenta) IN idx_info04 online;
   END IF;

   FOREACH cur_m3276 WITH HOLD FOR
      SELECT cuenta, SUM(monto_tot) AS monto_int INTO v_cuenta, v_monto_tot
        FROM bdicheq:movs_3276
       GROUP BY cuenta

      -- Abre la transaccion
      IF (vcomienza_3 = -1) THEN
         LET vcomienza_3 = 0;
         LET ven_transacc_3 = 1;
         BEGIN WORK;
      END IF;

      INSERT INTO bdicheq:movs_int VALUES (v_cuenta, v_monto_tot);

      LET vcontador_3 = vcontador_3 + 1;

      --Realiza commit cada 1000 registros
      IF (vcontador_3 >= 1000) THEN
         LET vcontador_3 = 0;
         COMMIT WORK;
         BEGIN WORK;
      END IF;

   END FOREACH;

   --Si la transaccion esta abierta realiza el commit
   IF (ven_transacc_3 = 1) THEN
      LET ven_transacc_3 = 0;
      COMMIT WORK;
   END IF;

   UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:movs_int;

   RETURN vcodret;

END;

END PROCEDURE;