CREATE PROCEDURE  "informix".limites_td(pempresa char(3),
                             psuc                   CHAR(3),
                             pusuario               CHAR(8),
                             pfolio                 CHAR(16),
                             pnumero_tarjeta        CHAR(16),
                             pcuentaaho             CHAR(20),
                             plimite_atm_dia        DECIMAL(12,2),
                             plimite_tot_dia        DECIMAL(12,2),
                             plimite_tot_mes        DECIMAL(12,2))

       RETURNING
             CHAR(5),          -- v_codigo_respuesta;
             DECIMAL(12,2);    -- limite institucional de retiro

   --  cambio de limites de disposicion      == --


   -- VARIABLES PARA RECUPERAR datos de TARJETA ACCESO

   DEFINE vnumerotarjeta         CHAR(16);
   DEFINE vsecuencia             CHAR(6);
   DEFINE vstatus_tarjeta        CHAR(2);
   DEFINE vtipo_tarjeta          CHAR(2);
   DEFINE vcuenta_chq            CHAR(20);
   DEFINE vcuenta_aho            CHAR(20);
   DEFINE vcuenta_crd            CHAR(20);
   DEFINE vnombre_tarjeta        CHAR(25);
   DEFINE vnombre_adicional      CHAR(25);
   DEFINE vnumero_anterior       CHAR(16);
   DEFINE vfecha_alta            DATE;
   DEFINE vfecha_vencimiento     CHAR(4);
   DEFINE vfecha_ini_vigenci     DATE;
   DEFINE vfecha_rep_tarjeta     DATE;
   DEFINE vlimite_diario_atm     DECIMAL(12,2);
   DEFINE vlimite_diario_tot     DECIMAL(12,2);
   DEFINE vlimite_mensual_to     DECIMAL(12,2);
   DEFINE vmonto_disp_atm_di     DECIMAL(12,2);
   DEFINE vmonto_disp_tot_di     DECIMAL(12,2);
   DEFINE vmonto_disp_tot_me     DECIMAL(12,2);
   DEFINE vsuc_alta              CHAR(3);
   DEFINE vejecutivo_alta        CHAR(4);
   DEFINE vfolio_alta            CHAR(16);
   DEFINE vsolic_trj             CHAR(1);
   DEFINE vsolic_nip             CHAR(1);
   DEFINE vtipo_cta_base         CHAR(1);
   DEFINE vclase_tarjeta         CHAR(1);
   DEFINE vcedula_adicional      CHAR(20);

   -- VARIABLES VARIAS

   DEFINE cod_ret                INT;
   DEFINE v_codigo_respuesta     CHAR(5);
   DEFINE v_fecha                DATETIME YEAR TO FRACTION(3);
   DEFINE v_fecha_hoy            DATE;
   DEFINE vlimite_inst           DECIMAL(12,2);
   DEFINE vcodigo_prod           CHAR(4);
   DEFINE vc_num_cte             CHAR(20);
   DEFINE va_num_cte             CHAR(20);


   -- MANEJO DE ERRORES DE INFORMIX

   ON  EXCEPTION SET cod_ret
       LET v_codigo_respuesta = cod_ret;
       RETURN v_codigo_respuesta,0;
   END EXCEPTION;



   -- INICIALIZA VARIABLES
   LET v_codigo_respuesta = '00000';
   LET vlimite_inst =        0;

   -- #####################################################################
   --                 VERIFICA EL LIMITE INSTITUCIONAL
   -- #####################################################################
   SELECT valor2
     INTO vlimite_inst
     FROM bditarjeta:td_parametro
    WHERE clave = "limiteatm";

   -- ####################################################################
   -- RECUPERA INFORMACION DE LA CUENTA CORRESPONDIENTE A LA TARJETA
   -- DE LA TABLA td_tarjeta_acceso
   -- ####################################################################
   SELECT *
   INTO vnumerotarjeta,       vsecuencia,
        vcodigo_prod,         vstatus_tarjeta,
        vtipo_tarjeta,        vcuenta_chq,        vcuenta_aho,
        vcuenta_crd,          vnombre_tarjeta,    vnombre_adicional,
        vnumero_anterior,     vfecha_alta,        vfecha_vencimiento,
        vfecha_ini_vigenci,   vfecha_rep_tarjeta, vlimite_diario_atm,
        vlimite_diario_tot,   vlimite_mensual_to, vmonto_disp_atm_di,
        vmonto_disp_tot_di,   vmonto_disp_tot_me, vsuc_alta,
        vejecutivo_alta,      vfolio_alta,        vsolic_trj,
        vsolic_nip,           vtipo_cta_base,     vcedula_adicional
   FROM bditarjeta:td_tarjeta_acceso
   WHERE numero_tarjeta = pnumero_tarjeta;

   -- VERIFICA SI EXISTE LA TARJETA

   IF  vnumerotarjeta IS NULL THEN
      LET    v_codigo_respuesta = '513';  -- NO EXISTE LA TARJETA
      RETURN v_codigo_respuesta, vlimite_inst;
   END IF


   LET  vc_num_cte = "";
   SELECT num_cte
   INTO  vc_num_cte
   FROM  bdicheq:sc_maechq
   WHERE empresa = pempresa and cuenta = vcuenta_chq;


   IF vc_num_cte != va_num_cte THEN
      LET v_codigo_respuesta = '510';    -- CUENTA NO PERTENECE A CLIENTE
      RETURN v_codigo_respuesta, vlimite_inst;
   END IF


   -- VERIFICA EL ESTATUS DE LA TARJETA
   IF  vstatus_tarjeta != '01' THEN
      LET v_codigo_respuesta = '530';  -- TARJETA INACTIVA 400
      RETURN v_codigo_respuesta, vlimite_inst;
   END IF

   -- VERIFICA EL LIMITE INSTITUCIONAL
   IF  plimite_atm_dia > vlimite_inst THEN
      LET v_codigo_respuesta = '531';  -- LIMITE INSTITUCIONAL EXCEDIDO 800
      RETURN v_codigo_respuesta, vlimite_inst;
   END IF

   -- DATOS PARA CAMBIOS DE LIMITE POR TARJETA

   UPDATE bditarjeta:td_tarjeta_acceso
      SET limite_diario_atm  =  plimite_atm_dia,
          limite_diario_tota =  plimite_tot_dia,
          limite_mensual_tot =  plimite_tot_mes,
          cuenta_aho         =  pcuentaaho
    WHERE numero_tarjeta     =  pnumero_tarjeta;

   SELECT fecha_hoy INTO v_fecha_hoy
   FROM bdicheq:sc_fechas where empresa = pempresa;

   LET v_fecha = v_fecha_hoy;

   -- #####################################################################
   --        DATOS PARA REPORTE DE CAMBIOS DE LIMITE POR TARJETA
   -- #####################################################################

   INSERT INTO bditarjeta:td_limites
       VALUES( psuc,
               pusuario,
               pfolio,
               pnumero_tarjeta,
               plimite_atm_dia,
               plimite_tot_dia,
               plimite_tot_mes,
               v_fecha);

   LET  v_codigo_respuesta = '00000';     -- 0's = OK

   RETURN v_codigo_respuesta,vlimite_inst;

END PROCEDURE;