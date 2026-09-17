CREATE PROCEDURE "informix".tmpsaldos(pEmpresa char(3))

RETURNING CHAR(5), char(20),integer, MONEY(14,2);
-- ***********************************************************************************************
-- tmpsaldos
-- Version              1.0.0
-- Objetivo:            SPL de prueba
-- Supuestos:           Ninguno
-- Creado por:
-- ModIFicado por:      Alejandro Rueda Sanchez
-- Ultima Modificacion: ENERO - 2009
--                      Creación de SPL
-- *************************************************************************************************

DEFINE GLOBAL vgTasaVar        CHAR(1)      DEFAULT "";
DEFINE GLOBAL vgcuenta         CHAR(20)     DEFAULT " ";
DEFINE GLOBAL vgfecha_hoy      DATE         DEFAULT " ";

--//Definicion de variables
   DEFINE vcodret     CHAR(5);
   DEFINE vcodret1    CHAR(5);
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

   DEFINE vt_producto CHAR(4);
   DEFINE vt_numcte   CHAR(20);
   DEFINE vt_tasa     CHAR(8);
   DEFINE vt_esfisica CHAR(1);
   DEFINE vtipper     CHAR(1);
   DEFINE vt_valtasa  DECIMAL(9,6);
   DEFINE IntCrece    DECIMAL(14,2);
   DEFINE vt_intcalculado DECIMAL(14,2);
   DEFINE vhora       DATETIME HOUR TO FRACTION;
   DEFINE vhoraw      CHAR(15);
   DEFINE vfolio_suc   CHAR(16);
   DEFINE vt_sdoactual DECIMAL(14,2);
   DEFINE vt_sdoactual_his DECIMAL(14,2);
   DEFINE vt_intpagene DECIMAL(14,2);
   DEFINE vt_interesfalta DECIMAL(14,2);
   DEFINE vt_sucursal  CHAR(4);
   DEFINE new_isr DECIMAL(14,6);
   DEFINE old_isr DECIMAL(14,6);
   DEFINE nvo_saldo_acum DECIMAL(14,2);
   DEFINE dias_actual INTEGER;
   DEFINE provision_dic DECIMAL(14,2);
   DEFINE provision_ene DECIMAL(14,2);
   DEFINE provision_tot DECIMAL(14,2);
   DEFINE vt_sdoacum_actual decimal(14,2);

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
      IF sql_err > 0 THEN
         LET vcodret = sql_err;
         IF vt_cuantos <> 0 THEN
            ROLLBACK WORK;
         END IF
         RETURN vcodret, vt_cuenta, vt_cuantos , vt_cuantos1;
      END IF;
   END EXCEPTION;


   --set debug file to "./tmpsaldos.out";
   --trace on;


   SET ISOLATION TO DIRTY READ;

   if (vt_cuantos = -1) then
       begin work;
      let vt_cuantos = 0;
   end if;


   SELECT fecha_hoy
     INTO vt_fecha_hoy
     FROM sc_fechas;

   --//Folio Operaciones
   LET vhora = current hour to fraction;
   LET vhoraw = vhora;
   LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
   LET vfolio_suc = 'informix'||vhoraw[1,8];

   --// **********************
   --// FOREACH PRINCIPAL
   --// **********************
   FOREACH with hold
       SELECT mae.cuenta, nvl(noc.dia_sdo_pos,0),noc.fecha_alta, mae.fecha_proceso,
              mae.producto, mae.num_cte, mae.sdo_actual, mae.sucursal, nvl(noc.acum_sdo_pos,0)
         INTO vt_cuenta, dias_actual, vt_fechalta, vt_fecha_proceso,
              vt_producto, vt_numcte, vt_sdoactual, vt_sucursal, vt_sdoacum_actual
         FROM sc_maechq mae, sc_maenoc noc
        WHERE mae.empresa = noc.empresa
          AND mae.cuenta = noc.cuenta
          AND mae.status_cta <> 2
          AND mae.fecha_proceso IS NOT NULL
          AND noc.fecha_alta <= '12/31/2008'
          AND DAY(noc.fecha_alta) in('05','04')
          AND mae.cuenta not in (select cuenta from sc_movdia
              where empresa = '001' and cuenta > '0' and transacc in('3276', '3277','3381'))


       SELECT nvl(his.dia_sdo_pos,0),nvl(his.acum_sdo_pos,0), nvl(his.sdo_actual,0)
         INTO vt_dia_sdo_pos, vt_acum_sdo_pos, vt_sdoactual_his
         FROM sc_maehis his
        WHERE his.aniomes = '200812' --****
          AND his.empresa = pEmpresa
          AND his.cuenta = vt_cuenta;

       IF (vt_fechalta IS NULL) THEN
          LET vcodret = '999';
          CONTINUE FOREACH;
       END IF;

       LET vgcuenta = vt_cuenta;

       SELECT nvl(dia_sdo_pos,0),nvl(acum_sdo_pos,0)
         INTO vt_dia_sdo_pos_dic, vt_acum_sdo_pos_dic
         FROM sc_maenoc311208
        WHERE cuenta = vt_cuenta;

       SELECT 1,nvl(capvig31,0)
         INTO vt_dia_sdo_pos_31, vt_acum_sdo_pos_31
         FROM sc_sdodiarioc
        WHERE aniomes = '200812' --****
          AND cuenta = vt_cuenta;

       LET vt_dialta = day(vt_fechalta);
       LET vt_diapro = day(vt_fecha_proceso);
       LET vt_dia_sdo_pos = vt_dialta -1;

       --//Acumula el Saldo total al mes
       let vt_acum_sdo_pos_tot = vt_acum_sdo_pos + vt_acum_sdo_pos_dic + vt_acum_sdo_pos_31;
       let vt_dia_sdo_pos_tot  = vt_dia_sdo_pos  + vt_dia_sdo_pos_dic  + vt_dia_sdo_pos_31;


       --//Determina la fecha de pago
       IF vt_dialta > vt_diapro THEN
          execute procedure sp_mes_siguiente(vt_fecha_proceso,-1,vt_dialta)
                  into vt_dummy, vt_fechapago, vt_dias;
       ELIF vt_dialta < vt_diapro THEN
          execute procedure sp_mes_siguiente(vt_fecha_proceso,0,vt_dialta)
                  into vt_dummy, vt_fechapago, vt_dias;
       ELSE
          CONTINUE FOREACH;
       END IF

       IF vt_dias < 0 THEN
          LET vt_dias = vt_dias * -1;
       END IF

       LET vgfecha_hoy = vt_fechapago; --**** con que fecha se inserta
       --//Fin Determina la fecha de pago

       --//Determina la Tasa
       SELECT tasa, paga_dividendo
         INTO vt_tasa, vgTasaVar
         FROM sc_producto
        WHERE empresa  = pempresa
          AND producto = vt_producto;

       --//Determina el tipo de persona
       SELECT es_fisica
         INTO vt_esfisica
         FROM bdinteg:si_cliente cli, bdinteg:si_tipper tipp
        WHERE cli.empresa  = pEmpresa
          AND cli.numcte = vt_numcte
          AND cli.tpo_persona = tipp.tpo_persona;

       IF vt_esfisica = "S" THEN
          LET vtipper = "F";
       ELSE
          LET vtipper = "M";
       END IF

       CALL calc_tasa(pEmpresa,vt_tasa,vtipper,vt_acum_sdo_pos_tot)
            RETURNING vcodret1,vt_valtasa, IntCrece;

       IF vt_valtasa IS NULL THEN
          LET vt_valtasa = 0;
       END IF

       LET vt_valtasa = vt_valtasa / 100;

       --//Determinar el interes que debio pagarse
       LET vt_intcalculado = (vt_acum_sdo_pos_tot/vt_dia_sdo_pos_tot * vt_valtasa) * vt_dia_sdo_pos_tot/360;


       --//Determinar el interes Faltante
       SELECT min(monto_tot)
         INTO vt_intpagene
         FROM pago_int_enero2009
        WHERE cuenta  = vt_cuenta;
       IF vt_intpagene is null or vt_intpagene < 0 THEN
          LET vt_intpagene = 0;
       END IF

       LET vt_interesfalta = vt_intcalculado - vt_intpagene;


       --//capitaliza intereses, pero al historico
       IF vt_interesfalta > 0 THEN
          INSERT INTO sc_movdia
               VALUES (0,vfolio_suc,vt_sucursal,'informix',vt_fecha_hoy,
                       vt_fecha_hoy,vhora,'3276',vt_sucursal,vt_producto,
                       pEmpresa,vt_cuenta, "",0,vt_interesfalta,vt_interesfalta,0,0,0,"","1",
                       vt_sdoactual,"0000","AJUSTE DE INTERESES",vt_valtasa,"","");

            UPDATE sc_maechq
               SET (fec_ult_mov,num_abonos_mes,imp_abonos_mes,sdo_actual,
                    ultpagoint) =
                   (vt_fecha_hoy,num_abonos_mes + 1,
		    imp_abonos_mes + (vt_interesfalta),
                    sdo_actual + (vt_interesfalta),
		    vt_fecha_hoy)
             WHERE empresa = pempresa
               AND cuenta = vt_cuenta;

       END IF

       LET provision_dic = 0;
       LET provision_ene = 0;
       LET provision_tot = 0;
       --//Calcula las provisiones
       SELECT monto_tot
         INTO provision_dic
         FROM provision_diciembre
        WHERE cuenta = vt_cuenta;

       IF provision_dic is null or provision_dic < 0 THEN
          LET provision_dic = 0;
       END IF

       SELECT min(monto_tot)
         INTO provision_ene
         FROM provision_enero2009
        WHERE cuenta = vt_cuenta;

       IF provision_ene is null or provision_ene < 0 THEN
          LET provision_ene = 0;
       END IF

       LET provision_tot = vt_intcalculado - provision_ene - provision_dic;

       IF provision_tot > 0 THEN
          INSERT INTO sc_movdia
               VALUES (0,vfolio_suc,vt_sucursal,'informix',vt_fecha_hoy,
                       vt_fecha_hoy,vhora,'3381',vt_sucursal,vt_producto,
                       pEmpresa,vt_cuenta, "",0,provision_tot,provision_tot,0,0,0,"","1",
                       vt_sdoactual,"0000"," ",vt_valtasa,"","");

       END IF

       LET new_isr = 0;
       LET old_isr = 0;
       --//Calcula el VIejo ISR
       SELECT min(monto_tot)
         INTO old_isr
         FROM isr_enero2009
        WHERE cuenta  = vt_cuenta;

       IF old_isr is null THEN
          LET old_isr = 0;
       END IF

       --//Calcula el VIejo ISR
       IF (vt_acum_sdo_pos_tot/vt_dia_sdo_pos_tot)  > 100010 THEN
          LET new_isr = ((vt_acum_sdo_pos_tot/vt_dia_sdo_pos_tot)  - 100010) * 0.0085/365 * vt_dia_sdo_pos_tot;
       END IF

       LET new_isr = new_isr - old_isr;

       IF new_isr > 0 THEN
          INSERT INTO sc_movdia
               VALUES (0,vfolio_suc,vt_sucursal,'informix',vt_fecha_hoy,
                       vt_fecha_hoy,vhora,'3277',vt_sucursal,vt_producto,
                       pEmpresa,vt_cuenta, "",0,new_isr,new_isr,0,0,0,"","1",
                       vt_sdoactual + vt_interesfalta,"0000"," ",vt_valtasa,"","");

           UPDATE sc_maechq
             SET (fec_ult_mov,num_abonos_mes,imp_abonos_mes,sdo_actual,
                  ultpagoint) =
                 (vt_fecha_hoy,num_cgos_mes + 1, imp_cgos_mes + (new_isr),
                  sdo_actual - (new_isr), vt_fecha_hoy)
         WHERE empresa = pempresa
             AND cuenta = vt_cuenta;
       END IF
       LET dias_actual = dias_actual;

       LET nvo_saldo_acum = ((vt_sdoacum_actual/dias_actual) + vt_interesfalta - new_isr) * dias_actual;

       UPDATE sc_maenoc
          SET acum_sdo_pos = nvo_saldo_acum
        WHERE empresa = '001'
          AND cuenta = vt_cuenta;

--      RETURN vcodret, vt_cuenta, vt_dia_sdo_pos_tot , vt_acum_sdo_pos_tot with resume;

      --//Inicializa Variables
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
      LET vt_intcalculado = 0;
      LET IntCrece = 0;
      LET vgTasaVar = "N";
      LET nvo_saldo_acum = 0;
      LET vt_interesfalta = 0;
      LET new_isr = 0;
      LET old_isr = 0;
      LET vt_sdoactual = 0;
      LET vt_sdoactual_his = 0;
      LET nvo_saldo_acum = 0;
      LET dias_actual = 0;
      LET provision_dic = 0;
      LET provision_ene = 0;
      LET provision_tot = 0;
      LET vt_sdoacum_actual = 0;

     if (vt_cuantos  >= 1) then
        let vt_cuantos = 0;
        commit work;
        if vt_cuantos1 > 30000 then
           update statistics medium for table sc_movdia;
           let vt_cuantos1 = 0;
        end if
        begin work;
     end if;


END FOREACH

if (vt_cuantos  >= 0) then
    commit work;
    update statistics medium for table sc_movdia;
end if;

RETURN vcodret, null, vt_cuantos , vt_cuantos1;
END
END PROCEDURE;