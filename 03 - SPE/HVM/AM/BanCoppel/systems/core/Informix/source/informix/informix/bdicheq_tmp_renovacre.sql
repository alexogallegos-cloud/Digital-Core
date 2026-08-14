CREATE PROCEDURE "informix".tmp_renovacre(pempresa CHAR(3))
       RETURNING CHAR(5);


   DEFINE vt_usuario        CHAR(8);
   DEFINE vgprox_fecha      DATE;
   DEFINE vt_fecha_hoy      DATE;
   DEFINE vt_sucursal       CHAR(4);
   DEFINE vgtrans_pag_int   CHAR(4);
   DEFINE vgtransisr        CHAR(4);
   DEFINE vgtranprov        CHAR(4);
   DEFINE vgtranabotrasp    CHAR(4);
   DEFINE vgtranrevprov     CHAR(4);
   DEFINE vgProdCreciente   CHAR(4);
   DEFINE vt_fecha_mod      DATE;
   DEFINE vgfecha_alta      DATE;
   DEFINE vt_status_cta     CHAR(1);
   DEFINE vgtranrecrece     CHAR(4);
   DEFINE vt_cuenta         CHAR(20);
   DEFINE vt_dias           INTEGER;
   DEFINE vcodret           CHAR(5);
   DEFINE vsqlerr           INTEGER;
   DEFINE vfolio_suc        CHAR(16);
   DEFINE vt_fecha_proceso  DATE;
   DEFINE vSdoActual        DECIMAL(14,2);
   DEFINE isam_err          SMALLINT;
   DEFINE vmaxsec           SMALLINT;
   DEFINE error_info        CHAR(40);
   DEFINE vt_intereses      DECIMAL(14,2);
   DEFINE vt_valor_tasa     DECIMAL(9,6);
   DEFINE vt_int_acum       DECIMAL(14,2);
   DEFINE vaniomescre       CHAR(6);


BEGIN

   ON EXCEPTION SET vsqlerr, isam_err, error_info
      IF vsqlerr <> 0 THEN
          let vcodret = vsqlerr;
          RETURN vcodret;
      END IF;
   END EXCEPTION;

 SET DEBUG FILE TO "/tmp/tmp_renovacre.out";
 TRACE ON;


   LET vt_usuario = USER;
   LET vcodret = "000";

   SELECT fecha_hoy, prox_fecha
     INTO vt_fecha_hoy, vgprox_fecha
     FROM sc_fechas
    WHERE empresa = pempresa;

   SELECT valor INTO vgtrans_pag_int
     FROM sc_param
    WHERE empresa = pempresa
      AND codparam = "tranpagint";

   SELECT valor INTO vgtranprov
     FROM sc_param
    WHERE empresa = pempresa
      AND codparam = "tranprov";

   SELECT valor INTO vgtranrecrece
     FROM sc_param
    WHERE empresa = pempresa
      AND codparam = "trenocre";

   -- Producto Inversion Creciente
   SELECT valor INTO vgProdCreciente
     FROM sc_param
    WHERE empresa = pempresa
      AND codparam = "PRODCREC";


    --// ************************************************************
    --// FOREACH PRINCIPAL 
    --// ************************************************************
    FOREACH principal WITH HOLD FOR
    
      SELECT mae.cuenta, fecha_mod, sdo_actual, status_cta, sucursal
        INTO vt_cuenta, vt_fecha_mod, vSdoActual, vt_status_cta, vt_sucursal
        FROM sc_maechq mae,sc_maenoc noc
       WHERE mae.empresa = noc.empresa
         AND mae.cuenta = noc.cuenta
         AND mae.status_cta = 1
         AND noc.fecha_mod < vt_fecha_hoy 
         AND producto = vgProdCreciente
         AND mae.empresa = pempresa
--AND mae.cuenta = "11000000037"
    
    
      --//inicializa variables
      LET vt_intereses  = 0;
      LET vt_valor_tasa = 0;
      LET vt_int_acum   = 0;
    
      --//calcula los dias posteriores a la fecha de vencimiento
      LET vt_dias = vt_fecha_hoy - vt_fecha_mod;
    
      --//calcula la tasa minima del producto
      SELECT a.valor_tasa, int_acum
        INTO vt_valor_tasa, vt_int_acum
        FROM sc_tasa_variable a
       WHERE empresa = '001'
         AND cuenta = vt_cuenta
         AND fin_periodo=(SELECT MIN(fin_periodo)
                            FROM sc_tasa_variable
                           WHERE empresa = '001'
                             AND cuenta = vt_cuenta);
    
      --//calcula los interese no devengados en el periodo
      LET vt_intereses = (vSdoActual * vt_valor_tasa/100)/360 * vt_dias;
    
      --//Calcula el folio
      LET vfolio_suc = current hour TO fraction(3);
      LET vfolio_suc = vt_usuario||vfolio_suc[1,2]||vfolio_suc[4,5]|| vfolio_suc[7,8]||vfolio_suc[10,11];

      LET vaniomescre = YEAR(vt_fecha_hoy)||LPAD(month(vt_fecha_hoy),2,0);
    
      --//Provisiona Intereses no devengados
      IF vt_intereses > 0 THEN
         INSERT INTO sc_movdia
            VALUES (0,vfolio_suc,vt_sucursal,vt_usuario,vt_fecha_hoy,
               vt_fecha_hoy,current hour TO fraction(3),vgtranprov,
               vt_sucursal, vgProdCreciente,pempresa,
               vt_cuenta, "",0,vt_intereses,vt_intereses,0,0,0,"",
               "", vSdoActual,"0000"," ",vt_valor_tasa, "","");
    
    
         --//Capitaliza Intereses no devengados
         INSERT INTO sc_movdia
              VALUES(0,vfolio_suc,vt_sucursal,vt_usuario,vt_fecha_hoy,
                     vt_fecha_hoy,current hour TO fraction(3),vgtrans_pag_int,
                     vt_sucursal,vgProdCreciente, pempresa,
                     vt_cuenta,"",0,vt_intereses,vt_intereses, 0,0,0,"",
                     "",vSdoActual,"0000"," ",vt_valor_tasa,"","");
    
        --//ACTUALIZAR SALDOS EN EL MAESTRO****
         UPDATE sc_maechq
            SET (fec_ult_mov,num_abonos_mes,imp_abonos_mes,sdo_actual,
                 ultpagoint) =
                (vt_fecha_hoy,num_abonos_mes + 1,
                 imp_abonos_mes + vt_intereses,
                 sdo_actual + vt_intereses,
                 vt_fecha_hoy)
          WHERE empresa = pempresa 
            AND cuenta = vt_cuenta;

        --// ***************************************************
        --// como ya vencio...
        --// ***************************************************
        --//REALIZA EL MOVIMIENTO DE RENOVACION ES REFERENCIAL
        INSERT INTO sc_movdia
              VALUES(0,vfolio_suc,vt_sucursal,USER,vt_fecha_hoy,
                     vt_fecha_hoy,current hour TO fraction(3),vgtranrecrece,
                     vt_sucursal,vgProdCreciente,
                     pempresa,vt_cuenta," ",0,vt_intereses,vt_intereses,
                     0,0,0," "," ",vSdoActual,"0000","RENOVACION",0,"","");
     
        LET vaniomescre = YEAR(vt_fecha_hoy)||LPAD(month(vt_fecha_hoy),2,0);
     
        --//Respalda la proyeccion actual en el historico
         INSERT INTO sc_tasa_var_hist
         SELECT vaniomescre, a.*
           FROM sc_tasa_variable a
          WHERE a.empresa = pempresa
            AND cuenta  = vt_cuenta;
     
        --//ELIMINA LA PROYECCION ACTUAL
        DELETE FROM sc_tasa_variable
         WHERE empresa = pempresa
           AND cuenta = vt_cuenta;
     
     
        --//REALIZA LA ACTUALIZACION DEL MAESTRO NOCTURNO
        --//PARA GENERAR LA NUEVA PROYECCION
        UPDATE sc_maenoc
           SET fecha_mod  = NULL,
               fecha_alta = vt_fecha_hoy,
               dia_sdo_pos = 0,
               acum_sdo_pos = 0,
               sdo_prom_mesant = 0,
               int_acum = 0,
               isr_acum = 0,
               acum_sdo_int = 0
         WHERE empresa = pempresa
           AND cuenta = vt_cuenta;
     

       --//Actualiza con la fecha nulo
       UPDATE sc_maechq
          SET fecha_proceso = NULL,
              sdo_dia_ant = sdo_actual
        WHERE empresa = pempresa
          AND cuenta = vt_cuenta;

        --//***************************************************
        --//Fin la inversion creciente ya vencio...
        --//***************************************************
      END IF
    
    END FOREACH;

   RETURN vcodret;
END
END PROCEDURE;