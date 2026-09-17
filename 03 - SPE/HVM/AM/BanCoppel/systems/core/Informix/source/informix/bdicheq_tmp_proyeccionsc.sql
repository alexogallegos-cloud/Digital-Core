create procedure "informix".tmp_proyeccionsc(pempresa char(3),
                               psucursal char(4),
                               pusuario char(8),
                               pproducto char(4),
                               pmonto money(14,2),
                               vfecha_hoy date)
RETURNING char(5),      date,        date,
          decimal(4,2), money(14,2), decimal(4,2),
          money(14,2), money(14,2), decimal(9,6);

-- ***********************************************************************************************
-- sp_proyeccionsc
-- Version              1.0.0
-- Objetivo:            Obtener la proyeccion de una cuenta de cheques
-- Supuestos:           Ninguno
-- Creado por:
-- ModIFicado por:      Alejandro Rueda Sanchez
-- Ultima Modificacion: Abril - 2008
--                      Creación de SPL
-- *************************************************************************************************

--//Definicion de variables
DEFINE vcodret     char(5);
DEFINE vsqlerr     integer;
DEFINE vfecha_ini  date;
DEFINE vfecha_fin  date;
DEFINE vfecha_tmp  date;
DEFINE vmes        char(2);
DEFINE vtasa       decimal(4,2);
DEFINE vmonto_int  money(14,2);
DEFINE vtasa_tot   decimal(4,2);
DEFINE vmonto_tot  money(14,2);
DEFINE i           smallint;
DEFINE vdias       smallint;
DEFINE vtipo_calc  char(1);
DEFINE vtasa_nom   char(8);
DEFINE vdia_aper   smallint;
DEFINE vdia_sig    smallint;
DEFINE vtipo_tasa  char(1);
DEFINE visr        MONEY(14,2);
DEFINE vtisr       DECIMAL(9,6);
DEFINE vferiado    date;
DEFINE vnumdias    smallint;
DEFINE vacumulado  MONEY(14,2);

   on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
           RETURN vcodret,null,null,0,
                  0,0,0, 0, 0;
	end if
   end exception;

   --set debug file to "/tmp/sp_proyeccionsc.out";
   --trace on;

   --//Inicializacion de variables
   LET vcodret    = "000";
   LET vfecha_ini = "";
   LET vfecha_fin = "";
   LET vmes       = "";
   LET vtasa      = 0;
   LET vmonto_int = 0;
   LET vtasa_tot  = 0;
   LET vmonto_tot = pmonto;
   LET vfecha_tmp = "";
   LET vdias      = 0;
   LET vtipo_calc = "";
   LET vtasa      = "";
   LET vtasa_nom  = "";
   LET vdia_aper  = 0;
   LET vdia_sig   = 0;
   LET vtipo_tasa = "";
   LET visr       = 0;
   LET vtisr      = 0;
   LET vferiado   = "";
   LET vnumdias   = 0;
   LET vacumulado = 0;

   IF Trim(pproducto) = "" or pmonto = 0 THEN
      LET vcodret = "110";
      RETURN vcodret,vfecha_ini,vfecha_fin,vtasa,vmonto_int,vtasa_tot,vmonto_tot,
             visr, vtisr;
   END IF

   --//Extrae las Caracteristicas del Producto
   SELECT tipo_anio_calc,tasa
     INTO vtipo_calc,vtasa_nom
     FROM sc_producto
    WHERE producto = pproducto
      AND empresa = pempresa;

   --//Obtiene la fecha del Sistema de Captacion
   --SELECT pri_dia_mes, fecha_hoy , ult_dia_mes
   --  INTO vfecha_tmp1,vfecha_hoy , vfecha_tmp2
   --  FROM sc_fechas;

   LET vdia_aper = day(vfecha_hoy);

   SELECT max(fecha)
     INTO vfecha_tmp
     FROM bdinteg:si_tasa_mes;

   LET i = 1;
   LET vfecha_ini = vfecha_hoy;

   FOREACH
       SELECT mes,valor_tasa,tipo_tasa
         INTO vmes,vtasa,vtipo_tasa
         FROM bdinteg:si_tasa_mes
        WHERE fecha = vfecha_tmp
          AND tasa = vtasa_nom
        order by mes::smallint

       LET i = vmes::smallint;

       IF i = 13  THEN
          CALL sp_mes_siguiente(vfecha_hoy, i - 1  ,vdia_aper) RETURNING vcodret, vfecha_fin, vnumdias;
       ELSE
          CALL sp_mes_siguiente(vfecha_ini, 1 ,vdia_aper) RETURNING vcodret, vfecha_fin, vnumdias;
          IF vnumdias > 40 THEN
             CALL sp_mes_siguiente(vfecha_ini, 0 ,vdia_aper) RETURNING vcodret, vfecha_fin, vnumdias;
          END IF
       END IF

       LET vdias = vnumdias;
       LET pmonto = pmonto + vmonto_int;

       CALL calc_isr_proy(pempresa,
                          "0000000",
                           vfecha_hoy,
                           vdias,
                           vmonto_int,
                           pmonto,
                           vdias,
                           "S")
       RETURNING vcodret, visr, vtisr;



       -- Calcula los Intereses
       IF vtipo_calc = "1" THEN
          let vmonto_int = pmonto * (vtasa/100) / 360 * vdias;
       ELSE
          let vmonto_int = pmonto * (vtasa/100) / 365 * vdias;
       END IF


       -- Calcula los Intereses META
       IF vtipo_tasa = "P" THEN
          LET vfecha_ini = vfecha_hoy;
          --LET vdias = vdias -1;
          IF vtipo_calc = "1" THEN
             let vmonto_int = vmonto_tot * (vtasa/100) / 360 * vdias;
             let vtasa_tot = vtasa;
          ELSE
             let vmonto_int = vmonto_tot * (vtasa/100) / 365 * vdias;
             let vtasa_tot = vtasa;
          END  IF

          --LET vmonto_int = vmonto_int - vacumulado;
          CALL calc_isr_proy(pempresa,
                            "0000000",
                             vfecha_ini,
                             vdias,
                             vmonto_int,
                             vmonto_tot,
                             vdias,
                             "S")
          RETURNING vcodret, visr, vtisr;
       ELSE
          -- Calcula Intereses Acumulados
          LET vacumulado = vacumulado + vmonto_int;
       END IF

       RETURN vcodret,vfecha_ini,vfecha_fin,vtasa,
              vmonto_int,vtasa_tot,vmonto_tot, visr, vtisr with resume;
       LET vfecha_ini = vfecha_fin;
   END FOREACH
END PROCEDURE DOCUMENT "Version 1.00.000";

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