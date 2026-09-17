CREATE PROCEDURE "informix".tmparrpromene()

RETURNING CHAR(5), char(20),integer, MONEY(14,2);
-- ***********************************************************************************************
-- tmparrpromene
-- Version              1.0.0
-- Objetivo:            SPL de prueba
-- Supuestos:           Ninguno
-- Creado por:
-- ModIFicado por:      Alejandro Rueda Sanchez
-- Ultima Modificacion: ENERO - 2009
--                      Creación de SPL
-- *************************************************************************************************

--//Definicion de variables
   DEFINE vcodret     CHAR(5);
   DEFINE vt_cuenta   CHAR(20);
   DEFINE vt_fecha_hoy  DATE;
   DEFINE vt_acum_sdo_pos MONEY(14,2);
   DEFINE vt_dia_sdo_pos SMALLINT;
   DEFINE vt_acum_sdo_pos_dic MONEY(14,2);
   DEFINE vt_dia_sdo_pos_dic SMALLINT;
   DEFINE vt_acum_sdo_pos_31 MONEY(14,2);
   DEFINE vt_dia_sdo_pos_31 SMALLINT;
   DEFINE vt_acum_sdo_pos_tot MONEY(14,2);
   DEFINE vt_dia_sdo_pos_tot SMALLINT;

   DEFINE vt_dias      SMALLINT;
   DEFINE vt_dialta      SMALLINT;
   DEFINE vt_diapro      SMALLINT;
   DEFINE sql_err     INTEGER;
   DEFINE vt_fecha_proceso  DATE;
   DEFINE vt_saldodia MONEY(14,2);
   DEFINE vt_saldomes MONEY(14,2);
   DEFINE vt_fechalta  DATE;
   DEFINE vt_fechapago  DATE;
   DEFINE vt_cuantos   INTEGER;
   DEFINE vt_cuantos1   INTEGER;
   DEFINE vt_dummy   CHAR(20);


   LET vcodret    = "000";

   let vt_acum_sdo_pos = 0;
   let vt_dia_sdo_pos = 0;
   let vt_acum_sdo_pos_dic = 0;
   let vt_dia_sdo_pos_dic = 0;
   let vt_acum_sdo_pos_31 = 0;
   let vt_dia_sdo_pos_31 = 0;
   let vt_acum_sdo_pos_tot = 0;
   let vt_dia_sdo_pos_tot = 0;

   LET vt_dias = 0;
   LET vt_dia_sdo_pos = 0;
   LET vt_saldodia = 0;
   LET vt_saldomes = 0;
   LET sql_err    = 0;
   LET vt_cuantos = -1;
   LET vt_cuantos1 = 0;
   LET vt_cuenta = 0;

   BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vcodret = sql_err;
         RETURN vcodret, vt_cuenta, vt_dia_sdo_pos_tot , vt_acum_sdo_pos_tot;
      END IF;
   END EXCEPTION;


-- set debug file to "tmparrpromene.out";
-- trace on;


   SET ISOLATION TO DIRTY READ;

   if (vt_cuantos = -1) then
       begin work;
      let vt_cuantos = 0;
   end if;

   --// **********************
   --// FOREACH PRINCIPAL
   --// **********************
   FOREACH with hold
       SELECT mae.cuenta, nvl(noc.dia_sdo_pos,0),nvl(noc.acum_sdo_pos,0), noc.fecha_alta, mae.fecha_proceso
         INTO vt_cuenta, vt_dia_sdo_pos, vt_acum_sdo_pos, vt_fechalta, vt_fecha_proceso
         FROM sc_maechq mae, sc_maenoc noc
        WHERE mae.empresa = noc.empresa
          AND mae.cuenta = noc.cuenta
          AND mae.status_cta <> 2
          AND mae.fecha_proceso IS NOT NULL
          AND DAY(noc.fecha_alta) = 31
         -- AND mae.cuenta in('10000045115', '10000313551', '11000012361', '11000140629', '18000052414', '18000062479')


       IF (vt_fechalta IS NULL) THEN
          LET vcodret = '999';
          CONTINUE FOREACH;
       END IF;

       --SELECT nvl(dia_sdo_pos,0),nvl(acum_sdo_pos,0)
       --  INTO vt_dia_sdo_pos_dic, vt_acum_sdo_pos_dic
       --  FROM sc_maenoc311208
       -- WHERE cuenta = vt_cuenta;

       SELECT 1,nvl(capvig31,0)
         INTO vt_dia_sdo_pos_31, vt_acum_sdo_pos_31
         FROM sc_sdodiarioc
        WHERE aniomes = '200812'
          AND cuenta = vt_cuenta;

       --//Acumula el Total al dia de Hoy
       --let vt_acum_sdo_pos_tot = vt_acum_sdo_pos + vt_acum_sdo_pos_dic + vt_acum_sdo_pos_31;
       --let vt_dia_sdo_pos_tot  = vt_dia_sdo_pos  + vt_dia_sdo_pos_dic  + vt_dia_sdo_pos_31;
       let vt_acum_sdo_pos_tot = vt_acum_sdo_pos + vt_acum_sdo_pos_31;
       let vt_dia_sdo_pos_tot  = vt_dia_sdo_pos  + vt_dia_sdo_pos_31;


       UPDATE sc_maenoc
          SET dia_sdo_pos = vt_dia_sdo_pos_tot, acum_sdo_pos = vt_acum_sdo_pos_tot
        WHERE empresa = '001'
          AND cuenta = vt_cuenta;

   --RETURN vcodret, vt_cuenta, vt_dia_sdo_pos_tot , vt_acum_sdo_pos_tot with resume;
      let vt_acum_sdo_pos = 0;
      let vt_dia_sdo_pos = 0;
      let vt_acum_sdo_pos_dic = 0;
      let vt_dia_sdo_pos_dic = 0;
      let vt_acum_sdo_pos_31 = 0;
      let vt_dia_sdo_pos_31 = 0;
      let vt_acum_sdo_pos_tot = 0;
      let vt_dia_sdo_pos_tot = 0;
      let vt_cuantos = vt_cuantos +1;
      let vt_cuantos1 = vt_cuantos1 +1;

     if (vt_cuantos  >= 25000) then
        let vt_cuantos = 0;
        commit work;
        update statistics medium for table sc_maenoc;
        begin work;
     end if;

END FOREACH

if (vt_cuantos  >= 0) then
    commit work;
    update statistics medium for table sc_maenoc;
end if;

RETURN vcodret, null, vt_cuantos , vt_cuantos1;
END
END PROCEDURE;