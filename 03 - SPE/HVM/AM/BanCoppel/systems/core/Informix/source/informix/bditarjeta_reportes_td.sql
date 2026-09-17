CREATE PROCEDURE "informix".reportes_td(pempresa char(3),
                             psuc              CHAR(3),
                             pusuario          CHAR(8),
                             pfolio            CHAR(16),
                             pnumero_tarjeta   CHAR(16),
                             pcausa            CHAR(2),
                             pcedula	       CHAR(20),
                             pnombre_reporto   CHAR(40),
                             phora             CHAR(8),
                             pfecha            DATE)

   -- reportes de tarjeta por extravio, robo, etc          == --

      RETURNING
              CHAR(5),  -- v_codigo_respuesta,
              CHAR(8);  -- v_folio_confirm  corresponde a la secuencia del folio

   -- VARIABLES PARA RECUPERAR TABLA tarjeta_debito
   DEFINE vnumerotarjeta        CHAR(16);
   DEFINE vsecuencia            CHAR(6);
   DEFINE vstatus_tarjeta       CHAR(2);
   DEFINE vtipo_tarjeta         CHAR(2);
   DEFINE vcuenta_chq           CHAR(20);
   DEFINE vcuenta_aho           CHAR(20);
   DEFINE vcuenta_crd           CHAR(20);
   DEFINE vnombre_tarjeta       CHAR(25);
   DEFINE vnombre_adicional     CHAR(25);
   DEFINE vnumero__anterior     CHAR(16);
   DEFINE vfecha_alta           DATE;
   DEFINE vfecha_vencimiento    CHAR(4);
   DEFINE vfecha_ini_vigenci    DATE;
   DEFINE vfecha_rep_tarjeta    DATE;
   DEFINE vlimite_diario_atm    DECIMAL(12,2);
   DEFINE vlimite_diario_tot    DECIMAL(12,2);
   DEFINE vlimite_mensual_to    DECIMAL(12,2);
   DEFINE vmonto_disp_atm_di    DECIMAL(12,2);
   DEFINE vmonto_disp_tot_di    DECIMAL(12,2);
   DEFINE vmonto_disp_tot_me    DECIMAL(12,2);
   DEFINE vsuc_alta             CHAR(2);
   DEFINE vejecutivo_alta       CHAR(4);
   DEFINE vfolio_alta           CHAR(16);
   DEFINE vsolic_trj            CHAR(1);
   DEFINE vsolic_nip            CHAR(1);
   DEFINE vtipo_cta_base        CHAR(1);
   DEFINE vclase_tarjeta        CHAR(2);
   DEFINE vcedula_adicional     CHAR(20);

   -- VARIABLES VARIAS
   DEFINE cod_ret               INT;
   DEFINE v_codigo_respuesta    CHAR(5);
   DEFINE v_folio_confirm       CHAR(8);
   DEFINE v_fecha_hora          DATETIME YEAR TO FRACTION(3);
   DEFINE v_cedula		        CHAR(20);
   DEFINE vcod_prod             CHAR(4);

   ON EXCEPTION SET cod_ret
       LET v_codigo_respuesta   = cod_ret;
       LET v_folio_confirm     = '00000000';    -- Cuando hay error de informix
       RETURN v_codigo_respuesta, v_folio_confirm;
   END EXCEPTION;


   -- INICIALIZA VARIABLES
   LET v_codigo_respuesta   = '00000';
   LET v_folio_confirm      = '00000000';

   -- RECUPERA INFORMACION DE LA CUENTA CORRESPONDIENTE A LA TARJETA
   -- DE LA TABLA tarjeta_debito
   SELECT *
   INTO vnumerotarjeta,         vsecuencia,
        vcod_prod,              vstatus_tarjeta,
        vtipo_tarjeta,          vcuenta_chq,          vcuenta_aho,
        vcuenta_crd,            vnombre_tarjeta,      vnombre_adicional,
        vnumero__anterior,      vfecha_alta,          vfecha_vencimiento,
        vfecha_ini_vigenci,     vfecha_rep_tarjeta,   vlimite_diario_atm,
        vlimite_diario_tot,     vlimite_mensual_to,   vmonto_disp_atm_di,
        vmonto_disp_tot_di,     vmonto_disp_tot_me,   vsuc_alta,
	     vejecutivo_alta,        vfolio_alta,          vsolic_trj,
	     vsolic_nip,             vtipo_cta_base,       vcedula_adicional
   FROM bditarjeta:td_tarjeta_acceso
   WHERE numero_tarjeta = pnumero_tarjeta;


   -- VERIFICA SI EXISTE LA TARJETA
   IF vnumerotarjeta is NULL THEN
       LET v_codigo_respuesta  = '513';  -- NO EXISTE LA TARJETA
       LET v_folio_confirm     = '00000000';
       RETURN v_codigo_respuesta, v_folio_confirm;
   END IF

   -- Validacion de la Cedula con la Tarjeta de Debito
   SELECT num_cte INTO v_cedula FROM bdicheq:sc_maechq
   WHERE empresa = pempresa and cuenta = vcuenta_chq ;

   IF v_cedula <> pcedula THEN
       LET v_codigo_respuesta  = '515';  -- NO COINCIDE LA CEDULA DEL CLIENTE
       LET v_folio_confirm     = '00000000';
       RETURN v_codigo_respuesta, v_folio_confirm;
   END IF

   IF vstatus_tarjeta != '01' THEN
      LET v_codigo_respuesta  = '530';  -- TARJETA INACTIVA
	   LET v_folio_confirm      = '00000000';
	   RETURN v_codigo_respuesta, v_folio_confirm;
   END IF

   IF pcausa IN ('02','03','06','07','08') THEN
      UPDATE bditarjeta:td_tarjeta_acceso
         SET status_tarjeta = pcausa
       WHERE numero_tarjeta = pnumero_tarjeta;
   ELSE
      LET v_codigo_respuesta  = '532';  -- STATUS NO VALIDO
      LET v_folio_confirm     = '00000000';
      RETURN v_codigo_respuesta, v_folio_confirm;
   END IF

   LET v_fecha_hora  = CURRENT;
   INSERT INTO bditarjeta:td_reportes
   VALUES (pfolio,
           psuc,
           pusuario,
           pnumero_tarjeta,
           pcausa,
   	   pnombre_reporto,
           phora,
           pfecha,
           v_fecha_hora,
           'R');    -- R = Recibido

   LET v_codigo_respuesta = '00000';     -- 0's = OK
   LET v_folio_confirm    = pfolio;      -- Se devuelve sec del folio recibido

   RETURN v_codigo_respuesta, v_folio_confirm;

END PROCEDURE;