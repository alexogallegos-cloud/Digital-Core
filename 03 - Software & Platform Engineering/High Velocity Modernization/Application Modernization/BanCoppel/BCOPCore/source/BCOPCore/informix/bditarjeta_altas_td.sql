CREATE PROCEDURE "informix".altas_td(pempresa          char(3),
                                     psuc              CHAR(3),
                                     pusuario          CHAR(8),
                                     pfolio            CHAR(16),
                                     --  operador CHAR(8)  ||  secuencia CHAR(8)
                                     pnum_cliente      CHAR(20),
                                     ptit_adic            CHAR(1),
                                     --  T = titular    A = adicional
                                     ptipo_tarjeta     CHAR(2),
                                     pcuenta_chq       CHAR(20),
                                     pcuenta_aho       CHAR(20),
                                     pcuenta_crd       CHAR(20),
                                     pnombre_plastico  CHAR(25),
                                     pnombre_banmag    CHAR(25),
                                     plimite_atm_dia    DECIMAL(12,2),
                                     plimite_tot_dia    DECIMAL(12,2),
                                     plimite_tot_mes    DECIMAL(12,2),
                                     pnumero_ced_adi    CHAR(20),
                                     pnumero_tarjeta   CHAR(16))

       RETURNING CHAR(5),   CHAR(16);


   -- VARIABLES VARIAS
   DEFINE cod_ret            INT;
   DEFINE v_codigo_respuesta CHAR(5);
   DEFINE v_fecha            DATETIME YEAR TO FRACTION(3);
   DEFINE vnum_cte           CHAR(20);
   DEFINE key4               CHAR(5);
   DEFINE key5               CHAR(1);
   DEFINE vfecha_alta        DATE;
   DEFINE vfecha_vencimiento CHAR(4);
   DEFINE vfecha_ini_vigenci DATE;
   DEFINE vfecha_rep_tarjeta DATE;
   DEFINE vfecha_calculada   DATEtime year to month;
   DEFINE x                  INT;
   DEFINE anio               CHAR(4);
   DEFINE mes                CHAR(2);
   DEFINE v_nivel            INT;
   DEFINE vtipo_cta_base     CHAR(1);
   DEFINE vproducto          CHAR(4);
   DEFINE prod               CHAR(4);
   DEFINE vsucalta           CHAR(3);
   DEFINE vctachq            CHAR(20);
   DEFINE vctaaho            CHAR(20);
   DEFINE vtipota            CHAR(2);
   DEFINE vstatus_tarjeta    CHAR(2);
   DEFINE v_existe_cliente   SMALLINT;
   DEFINE v_limite_ATM       DECIMAL(12,2);
   DEFINE v_limite_Dia       DECIMAL(12,2);


   -- MANEJO DE ERRORES
   ON EXCEPTION SET cod_ret
      LET v_codigo_respuesta = cod_ret;

      INSERT INTO bditarjeta:td_errores
      VALUES (cod_ret, "altas_td.sql", CURRENT);

      RETURN v_codigo_respuesta, pnumero_tarjeta;
   END EXCEPTION;



   -- INICIALIZA VARIABLES
   LET v_codigo_respuesta = '00000';

	-- Valida Montos de ATM y Total del Dia MEL
   SELECT valor3
   INTO v_limite_ATM 
   FROM bditarjeta:td_parametro
   WHERE clave = "limiteatm";

   IF v_limite_ATM IS NULL THEN
      LET v_codigo_respuesta = '552'; -- Parametro ATM No Existe
      RETURN v_codigo_respuesta, pnumero_tarjeta;
   ELSE
      IF plimite_atm_dia > v_limite_ATM THEN
         LET v_codigo_respuesta = '553'; -- Sobre Pasa Parametro ATM 
         RETURN v_codigo_respuesta, pnumero_tarjeta;
      END IF
   END IF
	
   SELECT valor3
   INTO v_limite_Dia 
   FROM bditarjeta:td_parametro
   WHERE clave = "limitepos";

   IF v_limite_Dia IS NULL THEN
      LET v_codigo_respuesta = '554'; -- Parametro Diario (POS) No Existe
      RETURN v_codigo_respuesta, pnumero_tarjeta;
   ELSE
      IF plimite_tot_dia > v_limite_Dia THEN
         LET v_codigo_respuesta = '555'; -- Sobre Pasa Parametro ATM 
         RETURN v_codigo_respuesta, pnumero_tarjeta;
      END IF
   END IF
	
   SELECT cuenta_chq,  cuenta_aho
     INTO vctachq,  vctaaho
     FROM bditarjeta:td_tarjeta_acceso
    WHERE numero_tarjeta = pnumero_tarjeta;

   SELECT cuenta_chq,  cuenta_aho
     INTO vctachq,  vctaaho
     FROM bditarjeta:td_tarjeta_acceso
    WHERE numero_tarjeta = pnumero_tarjeta;

   IF vctachq != "" THEN
      LET v_codigo_respuesta = '512'; -- tarjeta ya asignada
      RETURN v_codigo_respuesta, pnumero_tarjeta;
   ELSE
      IF vctaaho != "" THEN
         LET v_codigo_respuesta = '512'; -- tarjeta ya asignada
         RETURN v_codigo_respuesta, pnumero_tarjeta;
      END IF
   END IF


   -- CONFIRMA QUE EL NIVEL SEA 'T'itular O 'A'dicional
   IF ptit_adic NOT IN ('T','A') THEN
       LET v_codigo_respuesta = '500';    -- INDICADOR INVALIDO
       RETURN v_codigo_respuesta, pnumero_tarjeta;
   END IF

   -- VALIDACION DE tipo de TARJETA EXISTENTE
   SELECT tipo_tarjeta INTO vtipota
    FROM bditarjeta:td_tipo_tarjeta
   WHERE tipo_tarjeta = ptipo_tarjeta;

   IF vtipota IS NULL THEN
      LET v_codigo_respuesta = '520';    -- TIPO de tarjeta no existe
      RETURN v_codigo_respuesta, pnumero_tarjeta;
   END IF

   -- validacion cliente titular
   IF ptit_adic = 'T' THEN
      LET v_existe_cliente    = 0;
      SELECT COUNT(*) INTO v_existe_cliente
      FROM bdinteg:si_cliente
      WHERE empresa = pempresa and numcte = pnum_cliente;

      -- VERIFICA SI EXISTE EL CLIENTE EN CENTRAL
      IF v_existe_cliente = 0 THEN
         LET v_codigo_respuesta = '100'; -- no existe el cliente totutlar
         RETURN v_codigo_respuesta, pnumero_tarjeta;
      END IF;
   END IF;


   -- validacion cliente Adicional
   IF ptit_adic = 'A' THEN
      LET v_existe_cliente    = 0;
      SELECT COUNT(*) INTO v_existe_cliente
      FROM bdinteg:si_cliente
      WHERE empresa = pempresa and numcte = pnumero_ced_adi;

      -- VERIFICA SI EXISTE EL CLIENTE EN CENTRAL
      IF v_existe_cliente = 0 THEN
         LET v_codigo_respuesta = '100'; -- no existe el cliente totutlar
         RETURN v_codigo_respuesta, pnumero_tarjeta;
      END IF;
   END IF;


   -- VERIFICA SI LA CUENTA PERTENECE AL CLIENTE
   IF LENGTH(pcuenta_chq) > 0 THEN
      SELECT num_cte,  producto
      INTO  vnum_cte, vproducto
      FROM  bdicheq:sc_maechq
      WHERE empresa = pempresa and cuenta = pcuenta_chq;
      IF vnum_cte IS NULL OR
         vnum_cte = ' ' OR
         vnum_cte = '' THEN
         LET v_codigo_respuesta = '501';    -- CUENTA CHQ'S NO EXISTE
         RETURN v_codigo_respuesta, pnumero_tarjeta;
      END IF
      -- VALIDACION DE PRODUCTO CON DERECHO A TARJETA
      SELECT * INTO prod
      FROM bditarjeta:td_prod_tar
      WHERE codigo = vproducto;
      IF prod IS NULL THEN
         LET v_codigo_respuesta = '514'; -- producto no tiene tarjeta
         RETURN v_codigo_respuesta, pnumero_tarjeta;
      END IF

      LET vtipo_cta_base = 'C';

		-- Validacion para Verificar Cotitulares MEL

      IF  vnum_cte != pnum_cliente THEN
          SELECT nombre
          INTO  vnum_cte
          FROM  bdicheq:sc_cotitular
          WHERE empresa = pempresa and cuenta = pcuenta_chq AND
                nombre = pnum_cliente;
          IF vnum_cte IS NULL THEN
             LET v_codigo_respuesta = '510';    -- CUENTA NO PERTENECE A CLIENTE
             RETURN v_codigo_respuesta, pnumero_tarjeta;
          END IF
      END IF


      IF LENGTH(pcuenta_aho) > 0 THEN
         SELECT num_cte,  producto
         INTO  vnum_cte, vproducto
         FROM  bdicheq:sc_maechq
         WHERE empresa = pempresa and cuenta = pcuenta_aho;
         IF vnum_cte IS NULL OR
            vnum_cte = ' ' OR
            vnum_cte = '' THEN
            LET v_codigo_respuesta = '502';    -- CUENTA FAL NO EXISTE
            RETURN v_codigo_respuesta, pnumero_tarjeta;
         END IF

         -- VALIDACION DE PRODUCTO CON DERECHO A TARJETA
         SELECT * INTO prod
         FROM bditarjeta:td_prod_tar
         WHERE codigo = vproducto;
         IF prod IS NULL THEN
            LET v_codigo_respuesta = '514'; -- producto no tiene tarjeta
            RETURN v_codigo_respuesta, pnumero_tarjeta;
         END IF

         IF vtipo_cta_base != "C" THEN
	         LET vtipo_cta_base = 'A';
         END IF;

			-- Validacion para Verificar Cotitulares MEL

         IF  vnum_cte != pnum_cliente THEN
             SELECT nombre
             INTO  vnum_cte
             FROM  bdicheq:sc_cotitular
             WHERE empresa = pempresa and cuenta = pcuenta_aho AND 
                   nombre = pnum_cliente;
             IF vnum_cte IS NULL THEN
                LET v_codigo_respuesta = '510';    -- NO PERTENECE A CLIENTE
                RETURN v_codigo_respuesta, pnumero_tarjeta;
             END IF
         END IF

      END IF

   ELSE
      IF LENGTH(pcuenta_aho) > 0 THEN
         SELECT num_cte,  producto
         INTO  vnum_cte, vproducto
         FROM  bdicheq:sc_maechq
         WHERE empresa = pempresa and cuenta = pcuenta_aho;
         IF vnum_cte IS NULL OR
            vnum_cte = ' ' OR
            vnum_cte = '' THEN
            LET v_codigo_respuesta = '502';    -- CUENTA FAL NO EXISTE
            RETURN v_codigo_respuesta, pnumero_tarjeta;
         END IF

         -- VALIDACION DE PRODUCTO CON DERECHO A TARJETA
         SELECT * INTO prod
         FROM bditarjeta:td_prod_tar
         WHERE codigo = vproducto;
         IF prod IS NULL THEN
            LET v_codigo_respuesta = '514'; -- producto no tiene tarjeta
            RETURN v_codigo_respuesta, pnumero_tarjeta;
         END IF

         LET vtipo_cta_base = 'A';

         IF  vnum_cte != pnum_cliente THEN
             SELECT nombre
             INTO  vnum_cte
             FROM  bdicheq:sc_cotitular
             WHERE empresa = pempresa and cuenta = pcuenta_aho AND 
                   nombre = pnum_cliente;
             IF vnum_cte IS NULL THEN
                LET v_codigo_respuesta = '510';    -- CUENTA NO PERTENECE A CLIENTE
                RETURN v_codigo_respuesta, pnumero_tarjeta;
             END IF
         END IF

      ELSE
         LET v_codigo_respuesta = '503';    -- CUENTA INVALIDA
         RETURN v_codigo_respuesta, pnumero_tarjeta;
      END IF
   END IF


   -- VALIDACION DE TARJETA ASIGNADA A SUCURSAL QUE SOLICITA EL ALTA
   SELECT sucursal_alta  INTO vsucalta
     FROM bditarjeta:td_tarjeta_acceso
    WHERE numero_tarjeta= pnumero_tarjeta;

   IF vsucalta IS NULL THEN
      LET v_codigo_respuesta = '513'; -- tarjeta no existe
      RETURN v_codigo_respuesta, pnumero_tarjeta;
   END IF

   IF psuc <> vsucalta  THEN
      LET v_codigo_respuesta = '511'; -- tarjeta no corresponde a esa sucursal
      RETURN v_codigo_respuesta, pnumero_tarjeta;
   END IF


   SELECT fecha_hoy
   INTO vfecha_alta
   FROM bdicheq:sc_fechas where empresa = pempresa;


   -- INICIALIZA FECHAS
   -- LET vfecha_alta        = DATE(current);
   LET vfecha_calculada   = YEAR(vfecha_alta)||'-'||MONTH(vfecha_alta);
   LET vfecha_calculada   = vfecha_calculada + 2 UNITS YEAR;
   LET anio               = YEAR(vfecha_calculada);
   LET mes                = MONTH(vfecha_calculada);
   IF  mes < 10 THEN
       LET mes = '0'||mes;
   END IF
   LET vfecha_vencimiento = anio[3,4] || mes;
   LET vfecha_ini_vigenci = vfecha_alta;
   LET vfecha_rep_tarjeta = vfecha_calculada - 2 UNITS MONTH;


   LET vstatus_tarjeta = "01";               -- TARJETA ACTIVA
   -- VALIDACION DE STATUS DE LA tARJETA
   SELECT status_tarjeta INTO vstatus_tarjeta
    FROM bditarjeta:td_status
   WHERE status_tarjeta = vstatus_tarjeta;

   IF vstatus_tarjeta IS NULL THEN
      LET v_codigo_respuesta = '521';    -- status_tarjeta no existe
      RETURN v_codigo_respuesta, pnumero_tarjeta;
   END IF

   -- ######################################################################
   -- ####                CREA REGISTRO NUEVA TARJETA                  #####
   -- ######################################################################
   UPDATE bditarjeta:td_tarjeta_acceso
      SET secuencia          =  ptit_adic,
          codigo             =  vproducto,
          status_tarjeta     =  vstatus_tarjeta,
          tipo_tarjeta       =  ptipo_tarjeta,
          cuenta_chq         =  pcuenta_chq,
          cuenta_aho         =  pcuenta_aho,
          cuenta_crd         =  pcuenta_crd,
          nombre_tarjeta     =  pnombre_plastico,
          nombre_banda_mag   =  pnombre_banmag,
          fecha_alta         =  vfecha_alta,
          --fecha_vencimiento  =  vfecha_vencimiento,
          fecha_ini_vigencia =  vfecha_ini_vigenci,
          --fecha_rep_tarjeta  =  vfecha_rep_tarjeta,
          limite_diario_atm  =  plimite_atm_dia,
          limite_diario_tota =  plimite_tot_dia,
          limite_mensual_tot =  plimite_tot_mes,
          sucursal_alta      =  psuc,
          ejecutivo          =  pusuario,
          folio_alta         =  pfolio,
          tipo_cta_base      =  vtipo_cta_base,
          cedula_adicional   =  pnumero_ced_adi
    WHERE numero_tarjeta     =  pnumero_tarjeta;


   LET v_codigo_respuesta = '00000';     -- 0's = OK
   RETURN v_codigo_respuesta, pnumero_tarjeta;

END PROCEDURE;