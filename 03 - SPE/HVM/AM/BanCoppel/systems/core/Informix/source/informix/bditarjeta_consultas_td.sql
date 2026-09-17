CREATE PROCEDURE "informix".consultas_td(pempresa char(3),
                              psuc              CHAR(3),   -- sin uso
                              pusuario          CHAR(8),   -- sin uso
                              pfolio            CHAR(16),  -- sin uso
                              --  operador CHAR(8)  ||  secuencia CHAR(8)
                              pnumero_tarjeta   CHAR(16),
                              pcuentachq        CHAR(20),
                              pcliente          CHAR(20),
                              pnumero_rows      SMALLINT)

       RETURNING CHAR(5),         -- v_codigo_respuesta,
                 CHAR(1),         -- vsecuencia T = titular    A = adicional
                 CHAR(16),        -- pnumero_tarjeta
                 CHAR(60),        -- vnombre
                 CHAR(2),         -- vstatus tarjeta
                 DECIMAL(12,2),   -- vlimite_diario_atm
                 DECIMAL(12,2),   -- vlimite_diario_tot
                 DECIMAL(12,2),   -- vlimite_mensual_tot
                 CHAR(20),        -- cedula del cliente
                 CHAR(20),        -- Cuenta de cheques
                 CHAR(20);        -- Cuenta de ahorros


   -- VARIABLES PARA RECUPERAR TABLA tarjeta_debito
   DEFINE vnumerotarjeta        CHAR(16);
   DEFINE vsecuencia            CHAR(1);
   DEFINE vcodigo_prod          CHAR(4);
   DEFINE vstatus_tarjeta       CHAR(2);
   DEFINE vtipo_tarjeta         CHAR(2);
   DEFINE vcuenta_chq           CHAR(20);
   DEFINE vcuenta_aho           CHAR(20);
   DEFINE vcuenta_crd           CHAR(20);
   DEFINE vnombre_tarjeta       CHAR(25);
   DEFINE vnombre_adicional     CHAR(25);
   DEFINE vnumero_anterior      CHAR(16);
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
   DEFINE cod_ret               INTEGER;
   DEFINE v_codigo_respuesta    CHAR(5);
   DEFINE v_fecha               DATETIME YEAR TO FRACTION(3);
   DEFINE vnum_cte              CHAR(20);
   DEFINE v_ciclo               INTEGER;
   DEFINE v_ciclo1              INTEGER;
   DEFINE vcuenta               CHAR(20);
   DEFINE v_cuenta_chq          CHAR(20);
   DEFINE vnumero_rows1         SMALLINT;
   DEFINE v_existe_cliente      SMALLINT;
   DEFINE vnombre_cliente       CHAR(60);
   DEFINE vnombre1              CHAR(15);
   DEFINE vnombre2              CHAR(15);
   DEFINE vapell_pat            CHAR(15);
   DEFINE vapell_mat            CHAR(15);


   ON EXCEPTION SET cod_ret
       LET v_codigo_respuesta = cod_ret;
       RETURN v_codigo_respuesta, vsecuencia, pnumero_tarjeta,vnombre_cliente,
              "00", 0.00, 0.00, 0.00, " ", " ", " ";
   END EXCEPTION;

   --SET DEBUG FILE TO "consulta_td.out";


   -- INICIALIZA VARIABLES
   LET v_codigo_respuesta  = '00000';
   LET vsecuencia          = ' ';
   LET vstatus_tarjeta     = ' ';
   LET vlimite_diario_atm  = 0;
   LET vlimite_diario_tot  = 0;
   LET vlimite_mensual_to  = 0;
   LET v_ciclo             = 0;
   LET v_ciclo1            = 0;
   LET vnombre_tarjeta     = ' ';
   LET vnombre_cliente     = ' '; --Se Adiciono para Regresar el Nombre Cliente
   LET vnum_cte            = " ";
   LET vtipo_tarjeta       = " ";
   LET vcuenta_chq         = " ";
   LET vcuenta_aho         = " ";
   LET v_existe_cliente    = 0;
   LET vnombre1            = ' ';
   LET vnombre2            = ' ';
   LET vapell_pat          = ' ';
   LET vapell_mat          = ' ';

   -- ####################################################################
   -- RECUPERA INFORMACION DE LA CUENTA CORRESPONDIENTE A LA TARJETA
   -- DE LA TABLA tarjeta_debito SI SE RECIBIO UN NUMERO DE TARJETA
   -- ####################################################################
   IF length(pnumero_tarjeta) > 0 THEN
      SELECT *
      INTO vnumerotarjeta,      vsecuencia,
           vcodigo_prod,        vstatus_tarjeta,
           vtipo_tarjeta,       vcuenta_chq,        vcuenta_aho,
           vcuenta_crd,         vnombre_tarjeta,    vnombre_adicional,
           vnumero_anterior,    vfecha_alta,        vfecha_vencimiento,
           vfecha_ini_vigenci,  vfecha_rep_tarjeta, vlimite_diario_atm,
           vlimite_diario_tot,  vlimite_mensual_to, vmonto_disp_atm_di,
           vmonto_disp_tot_di,  vmonto_disp_tot_me, vsuc_alta,
           vejecutivo_alta,     vfolio_alta,        vsolic_trj,
           vsolic_nip,          vtipo_cta_base,     vcedula_adicional
      FROM  bditarjeta:td_tarjeta_acceso
      WHERE numero_tarjeta = pnumero_tarjeta;

      -- VERIFICA SI EXISTE LA TARJETA
      IF vnumerotarjeta IS NULL THEN
         LET v_codigo_respuesta = '513';  -- NO EXISTE LA TARJETA
         RETURN v_codigo_respuesta,
                vsecuencia,
                pnumero_tarjeta,
                vnombre_cliente,
                vstatus_tarjeta,
                0.00, 0.00, 0.00,
                vnum_cte,
                vcuenta_chq,
                vcuenta_aho;
      END IF;

      SELECT num_cte
      INTO vnum_cte
      FROM bdicheq:sc_maechq
      WHERE empresa = pempresa and cuenta = vcuenta_chq;

      LET v_existe_cliente    = 0;
      SELECT COUNT(*) INTO v_existe_cliente
      FROM bdinteg:si_cliente
      WHERE bdinteg:si_cliente.numcte = vnum_cte;

      -- VERIFICA SI EXISTE EL CLIENTE EN CENTRAL
      IF v_existe_cliente = 0 THEN
         LET v_codigo_respuesta = '100';  -- NO EXISTE EL CLIENTE 
         RETURN v_codigo_respuesta,
                vsecuencia,
                pnumero_tarjeta,
                vnombre_cliente,
                vstatus_tarjeta,
                0.00, 0.00, 0.00,
                vnum_cte,
                vcuenta_chq,
                vcuenta_aho;
         --- Se le Adiciona para Extraer el Nombre del Cliente MEL
      ELSE
         SELECT nombre1,nombre2,apell_paterno,apell_materno INTO vnombre1,
                vnombre2,vapell_pat,vapell_mat
         FROM bdinteg:si_cliente
         WHERE bdinteg:si_cliente.numcte = vnum_cte;
         IF vnombre1 IS NULL THEN
            LET vnombre1 = ' ';
         END IF;
         IF vnombre2 IS NULL THEN
            LET vnombre2 = ' ';
         END IF;
         IF vapell_pat IS NULL THEN
            LET vapell_pat = ' ';
         END IF;
         IF vapell_mat IS NULL THEN
            LET vapell_mat = ' ';
         END IF;
         LET vnombre_cliente = TRIM(vnombre1) ||' '|| TRIM(vnombre2) ||' '|| TRIM(vapell_pat) ||' '|| TRIM(vapell_mat);
      END IF;

      IF vsecuencia = "A" THEN
         -----   LET  vnum_cte = vcedula_adicional;
      END IF

      RETURN v_codigo_respuesta,
             vsecuencia,
             pnumero_tarjeta,
             vnombre_cliente,
             vstatus_tarjeta,
             vlimite_diario_atm,
             vlimite_diario_tot,
             vlimite_mensual_to,
     	       vnum_cte,
    	       vcuenta_chq,
    	       vcuenta_aho;
   END IF

   -- ######################################################################
   -- RECUPERA INFORMACION DE LA CUENTA CORRESPONDIENTE A LA CUENTA
   -- DE LA TABLA bdicheq:sc_maechq SI SE RECIBIO UN NUMERO DE CUENTA
   -- VERIFICA SI LA CUENTA PERTENECE AL CLIENTE
   -- ######################################################################
   IF LENGTH(pcuentachq) > 0 THEN

      SELECT num_cte INTO vnum_cte
      FROM bdicheq:sc_maechq
      WHERE empresa = pempresa and cuenta = pcuentachq;

      IF vnum_cte IS NULL OR
         vnum_cte = ' ' OR
         vnum_cte = '' THEN
         LET v_codigo_respuesta = '501';    -- CUENTA CHQ'S NO EXISTE

         RETURN v_codigo_respuesta,
                vsecuencia,
                pnumero_tarjeta,
                vnombre_cliente,
                vstatus_tarjeta,
                0.00, 0.00, 0.00,
                vnum_cte,
    	          vcuenta_chq,
    	          vcuenta_aho;
      END IF

      LET v_existe_cliente    = 0;
      SELECT COUNT(*) INTO v_existe_cliente
      FROM bdinteg:si_cliente
      WHERE bdinteg:si_cliente.numcte = vnum_cte;

      -- VERIFICA SI EXISTE EL CLIENTE EN CENTRAL
      IF v_existe_cliente = 0 THEN
         LET v_codigo_respuesta = '100';  -- NO EXISTE EL CLIENTE 
         RETURN v_codigo_respuesta,
                vsecuencia,
                pnumero_tarjeta,
                vnombre_cliente,
                vstatus_tarjeta,
                0.00, 0.00, 0.00,
                vnum_cte,
                vcuenta_chq,
                vcuenta_aho;
      ELSE
         SELECT nombre1,nombre2,apell_paterno,apell_materno INTO vnombre1,
                vnombre2,vapell_pat,vapell_mat
         FROM bdinteg:si_cliente
         WHERE bdinteg:si_cliente.numcte = vnum_cte;
         IF vnombre1 IS NULL THEN
            LET vnombre1 = ' ';
         END IF;
         IF vnombre2 IS NULL THEN
            LET vnombre2 = ' ';
         END IF;
         IF vapell_pat IS NULL THEN
            LET vapell_pat = ' ';
         END IF;
         IF vapell_mat IS NULL THEN
            LET vapell_mat = ' ';
         END IF;
         LET vnombre_cliente = TRIM(vnombre1) ||' '|| TRIM(vnombre2) ||' '|| TRIM(vapell_pat) ||' '|| TRIM(vapell_mat);
      END IF;

      FOREACH
         SELECT *
         INTO vnumerotarjeta,      vsecuencia,
              vcodigo_prod,        vstatus_tarjeta,
              vtipo_tarjeta,       vcuenta_chq,        vcuenta_aho,
              vcuenta_crd,         vnombre_tarjeta,    vnombre_adicional,
              vnumero_anterior,    vfecha_alta,        vfecha_vencimiento,
              vfecha_ini_vigenci,  vfecha_rep_tarjeta, vlimite_diario_atm,
              vlimite_diario_tot,  vlimite_mensual_to, vmonto_disp_atm_di,
              vmonto_disp_tot_di,  vmonto_disp_tot_me, vsuc_alta,
              vejecutivo_alta,     vfolio_alta,        vsolic_trj,
              vsolic_nip,          vtipo_cta_base,     vcedula_adicional
         FROM bditarjeta:td_tarjeta_acceso
         WHERE cuenta_chq = pcuentachq
         LET v_ciclo = v_ciclo + 1;
         IF v_ciclo <= pnumero_rows THEN
            CONTINUE FOREACH;
         END IF
         IF vsecuencia="A" THEN
           --  LET vnum_cte = vcedula_adicional;
         END IF

         RETURN v_codigo_respuesta,
                vsecuencia,
                vnumerotarjeta,
                vnombre_cliente,
                vstatus_tarjeta,
                vlimite_diario_atm,
                vlimite_diario_tot,
                vlimite_mensual_to,
                vnum_cte,
                vcuenta_chq,
    	          vcuenta_aho WITH RESUME;
      END FOREACH;
   END IF;


   -- ######################################################################
   -- RECUPERA INFORMACION CON EL NUMERO DE CLIENTE
   -- TABLA sc_maechq SI RECIBE EL NUMERO DE CLIENTE
   -- ######################################################################
   IF LENGTH(pcliente) > 0 THEN

      LET vnumerotarjeta = null;
      LET v_existe_cliente    = 0;
      SELECT COUNT(*) INTO v_existe_cliente
      FROM bdinteg:si_cliente
      WHERE empresa = pempresa and numcte = pcliente;

      -- VERIFICA SI EXISTE EL CLIENTE EN CENTRAL
      IF v_existe_cliente = 0 THEN
         LET v_codigo_respuesta = '100';  -- NO EXISTE EL CLIENTE 
         RETURN v_codigo_respuesta,
                vsecuencia,
                pnumero_tarjeta,
                vnombre_cliente,
                vstatus_tarjeta,
                0.00, 0.00, 0.00,
                vnum_cte,
                vcuenta_chq,
                vcuenta_aho;
      ELSE
         SELECT nombre1,nombre2,apell_paterno,apell_materno INTO vnombre1,
                vnombre2,vapell_pat,vapell_mat
         FROM bdinteg:si_cliente
         WHERE empresa = pempresa and numcte = pcliente;
         IF vnombre1 IS NULL THEN
            LET vnombre1 = ' ';
         END IF;
         IF vnombre2 IS NULL THEN
            LET vnombre2 = ' ';
         END IF;
         IF vapell_pat IS NULL THEN
            LET vapell_pat = ' ';
         END IF;
         IF vapell_mat IS NULL THEN
            LET vapell_mat = ' ';
         END IF;
         LET vnombre_cliente = TRIM(vnombre1) ||' '|| TRIM(vnombre2) ||' '||
                               TRIM(vapell_pat) ||' '|| TRIM(vapell_mat);
      END IF;

      FOREACH
         SELECT cuenta
         INTO vcuenta
         FROM bdicheq:sc_maechq
         WHERE empresa = pempresa and num_cte = pcliente
         IF vcuenta IS NULL OR
            vcuenta = ' ' OR
            vcuenta = '' THEN
            LET v_codigo_respuesta = '501';    -- CUENTA CHQ'S NO EXISTE
            RETURN v_codigo_respuesta,
                   vsecuencia,
                   pnumero_tarjeta,
                   vnombre_cliente,
                   vstatus_tarjeta,
                   0.00, 0.00, 0.00,
                   pcliente,
    	             vcuenta_chq,
    	             vcuenta_aho;
         END IF;

         FOREACH
            SELECT *
            INTO vnumerotarjeta,     vsecuencia,
                 vcodigo_prod,        vstatus_tarjeta,
                 vtipo_tarjeta,      vcuenta_chq,        vcuenta_aho,
                 vcuenta_crd,        vnombre_tarjeta,    vnombre_adicional,
                 vnumero_anterior,  vfecha_alta,        vfecha_vencimiento,
                 vfecha_ini_vigenci, vfecha_rep_tarjeta, vlimite_diario_atm,
                 vlimite_diario_tot, vlimite_mensual_to, vmonto_disp_atm_di,
                 vmonto_disp_tot_di, vmonto_disp_tot_me, vsuc_alta,
                 vejecutivo_alta,    vfolio_alta,        vsolic_trj,
                 vsolic_nip,         vtipo_cta_base,     vcedula_adicional
            FROM bditarjeta:td_tarjeta_acceso
            WHERE cuenta_chq = vcuenta

                        
            LET v_ciclo = v_ciclo + 1;
            IF v_ciclo <= pnumero_rows THEN
               LET v_cuenta_chq = vcuenta;
               FOREACH
                  SELECT *
                  INTO
                     vnumerotarjeta,     vsecuencia,
                     vcodigo_prod,       vstatus_tarjeta,
                     vtipo_tarjeta,      vcuenta_chq,        vcuenta_aho,
                     vcuenta_crd,        vnombre_tarjeta,    vnombre_adicional,
                     vnumero_anterior,   vfecha_alta,        vfecha_vencimiento,
                     vfecha_ini_vigenci, vfecha_rep_tarjeta, vlimite_diario_atm,
                     vlimite_diario_tot, vlimite_mensual_to, vmonto_disp_atm_di,
                     vmonto_disp_tot_di, vmonto_disp_tot_me, vsuc_alta,
                     vejecutivo_alta,    vfolio_alta,        vsolic_trj,
                     vsolic_nip,         vtipo_cta_base,     vcedula_adicional
                  FROM bditarjeta:td_tarjeta_acceso
                  WHERE cuenta_chq = v_cuenta_chq

                  IF vnumerotarjeta IS NULL OR
                     vnumerotarjeta = ' ' OR
                     vnumerotarjeta = '' THEN
                     LET v_ciclo1 = v_ciclo1 + 1;
                     IF v_ciclo1 <= vnumero_rows1 THEN
                        CONTINUE FOREACH;
                     END IF
                  END IF
               END FOREACH
            END IF -- v_ciclo <= pnumero_rows THEN
         END FOREACH


         IF v_ciclo = 0 THEN
            IF vnumerotarjeta IS NULL THEN
               LET v_codigo_respuesta = '513';  -- NO EXISTE LA TARJETA
               RETURN v_codigo_respuesta,
                vsecuencia,
                pnumero_tarjeta,
                vnombre_cliente,
                vstatus_tarjeta,
                0.00, 0.00, 0.00,
                vnum_cte,
                vcuenta_chq,
                vcuenta_aho;
            END IF;
         END IF;


         IF vsecuencia="A" THEN
            ----   LET dula_adicional=vcedula_adicional;
         END IF

         RETURN v_codigo_respuesta,
                vsecuencia,
                vnumerotarjeta,
                vnombre_cliente,
                vstatus_tarjeta,
                vlimite_diario_atm,
                vlimite_diario_tot,
                vlimite_mensual_to,
                pcliente,
    	          vcuenta_chq,
    	          vcuenta_aho;

      END FOREACH;
   END IF;  -- LENGTH(pcliente) > 0 THEN

END PROCEDURE;