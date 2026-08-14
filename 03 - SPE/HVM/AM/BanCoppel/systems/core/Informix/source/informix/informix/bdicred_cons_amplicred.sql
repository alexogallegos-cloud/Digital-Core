CREATE PROCEDURE "informix".cons_amplicred(pnum_credito  CHAR(20))

   RETURNING CHAR(5),CHAR(80),MONEY(14,2),DATE,CHAR(25),CHAR(25),MONEY(14,2);

   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE text                CHAR(100);
   DEFINE sqlerr,isamerr      SMALLINT;

   DEFINE cod_ret             CHAR(5);
   DEFINE v_num_credito       CHAR(20);
   DEFINE v_numcte            CHAR(20);
   DEFINE v_apell_paterno     CHAR(15);
   DEFINE v_apell_materno     CHAR(15);
   DEFINE v_nombre1           CHAR(15);
   DEFINE v_nombre2           CHAR(15);
   DEFINE v_razon_social      CHAR(40);
   DEFINE v_cliente           CHAR(60);
   DEFINE v_cod_linea         CHAR(04);
   DEFINE v_cod_agricola      CHAR(05);
   DEFINE v_linea             CHAR(25);
   DEFINE v_ciclo             CHAR(25);
   DEFINE v_tipcred           LIKE sd_definicion.cod_tipcred;
   DEFINE v_cod_tipcred       LIKE sd_definicion.cod_tipcred;
   DEFINE v_num_producto      LIKE sd_maecred.num_producto;
   DEFINE v_monto_otorgado    LIKE sd_maesdos.monto_otorgado;
   DEFINE v_fecha_vencim      LIKE sd_maecred.fecha_vencim;
   DEFINE vg_cliente          CHAR(80);
   DEFINE vnum_amplicred      SMALLINT;
   DEFINE v_fechas_int_cred   LIKE sd_paramcred.fechas_int_cred;
   DEFINE v_fecha_hoy         LIKE sd_fechas.fecha_hoy;
   DEFINE v_status_amp        CHAR(2);
   DEFINE dFecha              DATE;
   DEFINE cStatus             CHAR(2);
   DEFINE cSucursal           CHAR(4);
   DEFINE cCodLinea           CHAR(4);
   DEFINE cCodCaract          CHAR(3);
   DEFINE cCodAgricola        CHAR(5);
   DEFINE cCodCaract2         CHAR(2);
   DEFINE cCodTipoLinea       CHAR(2);
   DEFINE nCuotaHectarea      MONEY(14,2);


-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr, text
      LET cod_ret = sqlerr;
      SET DEBUG FILE TO "cons_amplicred.err"; -- se guarda en /users/cs2
      TRACE sqlerr || " * " || isamerr || " * " || text;
      RETURN cod_ret,vg_cliente,v_monto_otorgado,v_fecha_vencim,v_linea,
             v_ciclo,nCuotaHectarea;
   END EXCEPTION;

   SET ISOLATION TO DIRTY READ;



   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret            = "000";
   LET v_numcte           = " ";
   LET v_apell_paterno    = " ";
   LET v_apell_materno    = " ";
   LET v_nombre1          = " ";
   LET v_nombre2          = " ";
   LET v_cliente          = " ";
   LET v_razon_social     = " ";
   LET v_monto_otorgado   = 0;
   LET vg_cliente         = " ";
   LET v_fecha_vencim     = " ";
   LET v_linea            = " ";
   LET vnum_amplicred     = 0;
   LET v_ciclo            = " ";
   LET v_fechas_int_cred  = "";
   LET v_fecha_hoy        = "";
   LET v_status_amp       = "";
   LET dFecha             = "";
   LET cStatus            = "";
   LET cSucursal          = "";
   LET cCodLinea          = "";
   LET cCodCaract         = "";
   LET cCodAgricola       = "";
   LET cCodCaract2        = "";
   LET cCodTipoLinea      = "";
   LET nCuotaHectarea     = 0;

   SELECT fechas_int_cred
      INTO v_fechas_int_cred
      FROM sd_paramcred;

   IF v_fechas_int_cred = "C" THEN
      SELECT fecha_hoy INTO v_fecha_hoy
      FROM sd_fechas;
   ELSE
      SELECT fecha_hoy INTO v_fecha_hoy
      FROM bdinteg:si_fechas;
   END IF;

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = " " THEN
      LET cod_ret = "223"; -- NUMERO DE CREDITO NULO O BLANCO
      RETURN cod_ret,vg_cliente,v_monto_otorgado,v_fecha_vencim,v_linea,
             v_ciclo,nCuotaHectarea;
   ELSE
      LET v_num_credito = pnum_credito;

      SELECT MAX(bdicred:sd_amplicred.fecha)
      INTO dFecha
      FROM bdicred:sd_amplicred
      WHERE bdicred:sd_amplicred.num_credito = v_num_credito;

      IF dFecha IS NOT NULL THEN
         IF dFecha != v_fecha_hoy THEN
            SELECT status_amp
            INTO v_status_amp
            FROM bdicred:sd_amplicred
            WHERE bdicred:sd_amplicred.num_credito = v_num_credito AND
                  bdicred:sd_amplicred.fecha       = dFecha;

            IF v_status_amp = "CO" OR v_status_amp = "AT" OR
               v_status_amp = "EE" THEN
               LET cod_ret = "412"; -- SOLICITUD ESTA EN TRAMITE
            END IF
         ELSE
            SELECT status_amp
            INTO v_status_amp
            FROM bdicred:sd_amplicred
            WHERE bdicred:sd_amplicred.num_credito = v_num_credito AND
                  bdicred:sd_amplicred.fecha       = v_fecha_hoy;

            IF v_status_amp = "CO" OR v_status_amp = "OP" OR
               v_status_amp = "AT" OR v_status_amp = "EE" THEN
               IF v_status_amp = "OP" THEN
                  LET cod_ret = "419"; -- SOLICITUD YA FUE APLICADA HOY
               ELSE
                  LET cod_ret = "412"; -- SOLICITUD ESTA EN TRAMITE
               END IF
            END IF
         END IF
      END IF

      IF cod_ret != "000" THEN
         RETURN cod_ret,vg_cliente,v_monto_otorgado,v_fecha_vencim,v_linea,
                v_ciclo,nCuotaHectarea;
      END IF
   END IF;

   SELECT num_producto,status_cred,sucursal,cod_linea,cod_caract,
          cod_agricola,cod_caract_2
   INTO v_num_producto,cStatus,cSucursal,cCodLinea,cCodCaract,
        cCodAgricola, cCodCaract2
   FROM sd_maecred
   WHERE num_credito = v_num_credito;

   IF v_num_producto IS NULL OR
      v_num_producto = " " THEN
      LET cod_ret = "225"; -- NO TIENE NUMERO DE PRODUCTO EN sd_maecred
      RETURN cod_ret,vg_cliente,v_monto_otorgado,v_fecha_vencim,v_linea,
             v_ciclo,nCuotaHectarea;
   ELSE
      IF cStatus = "FF" THEN
         LET cod_ret = "275"; -- CREDITO YA ESTA SALDADO
         RETURN cod_ret,vg_cliente,v_monto_otorgado,v_fecha_vencim,v_linea,
                v_ciclo,nCuotaHectarea;
      END IF
   END IF;

   SELECT cod_tipo_linea
   INTO cCodTipoLinea
   FROM bdicred:sd_lineasbr
   WHERE bdicred:sd_lineasbr.cod_linea = cCodLinea;

   SELECT cuota_hectarea
   INTO nCuotaHectarea
   FROM bdicred:sd_prehectbr
   WHERE bdicred:sd_prehectbr.sucursal       = cSucursal     AND
         bdicred:sd_prehectbr.cod_tipo_linea = cCodTipoLinea AND
         bdicred:sd_prehectbr.cod_linea      = cCodLinea     AND
         bdicred:sd_prehectbr.cod_caract     = cCodCaract    AND
         bdicred:sd_prehectbr.cod_agricola   = cCodAgricola  AND
         bdicred:sd_prehectbr.cod_caract_2   = cCodCaract2;

   SELECT cod_tipcred INTO v_cod_tipcred
   FROM sd_definicion
   WHERE num_producto = v_num_producto;
   IF v_cod_tipcred != "07" THEN
      LET cod_ret = "233"; -- EL TIPO DE CREDITO NO ES AVIO
      RETURN cod_ret,vg_cliente,v_monto_otorgado,v_fecha_vencim,v_linea,
             v_ciclo,nCuotaHectarea;
   END IF;

   SELECT monto_otorgado INTO v_monto_otorgado
   FROM sd_maesdos
   WHERE num_credito = v_num_credito;

   SELECT numcte,fecha_vencim,cod_linea,cod_agricola
   INTO v_numcte,v_fecha_vencim,v_cod_linea,v_cod_agricola
   FROM sd_maecred
   WHERE num_credito = v_num_credito;
   IF v_num_credito IS NULL OR
      v_num_credito = " " THEN
      LET cod_ret = "224"; -- NO EXISTE EL CREDITO EN sd_maecred
      RETURN cod_ret,vg_cliente,v_monto_otorgado,v_fecha_vencim,v_linea,
             v_ciclo,nCuotaHectarea;
   END IF;

   SELECT descrip_linea INTO v_linea
   FROM sd_lineasbr
   WHERE cod_linea = v_cod_linea;

   SELECT descrip_agricola INTO v_ciclo
   FROM sd_ciclosagbr
   WHERE cod_agricola = v_cod_agricola;

   IF v_numcte IS NULL OR
      v_numcte = " " THEN
      LET cod_ret = "202"; -- CLIENTE NULO O EN BLANCO EN sd_maecred
      RETURN cod_ret,vg_cliente,v_monto_otorgado,v_fecha_vencim,v_linea,
             v_ciclo,nCuotaHectarea;
   ELSE
      SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social
      INTO v_numcte,v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,
           v_razon_social
      FROM bdinteg:si_cliente
      WHERE numcte = v_numcte;

      IF v_numcte IS NULL OR
         v_numcte = " " THEN
         LET cod_ret = "238"; -- NO EXISTE NUMERO DE CLIENTE EN CENTRAL
         RETURN cod_ret,vg_cliente,v_monto_otorgado,
                v_fecha_vencim,v_linea,v_ciclo,nCuotaHectarea;
      END IF;

      IF v_nombre1 IS NULL THEN
         LET v_nombre1  = "";
      END IF;
      IF v_nombre2 IS NULL THEN
         LET v_nombre2  = "";
      END IF;
      IF v_apell_paterno IS NULL THEN
         LET v_apell_paterno  = "";
      END IF;
      IF v_apell_materno IS NULL THEN
         LET v_apell_materno  = "";
      END IF;

      IF v_razon_social IS NULL OR
         v_razon_social = " " THEN
         LET v_cliente = TRIM (v_nombre1) || " " || TRIM (v_nombre2);
         LET v_cliente = TRIM (v_cliente) || " " ||
            TRIM (v_apell_paterno) || " " || TRIM (v_apell_materno);
      ELSE
         LET v_cliente = v_razon_social;
      END IF;
      LET vg_cliente = TRIM(v_numcte) || " " || TRIM(v_cliente);
   END IF;
   RETURN cod_ret,vg_cliente,v_monto_otorgado,v_fecha_vencim,v_linea,v_ciclo,
          nCuotaHectarea;
END PROCEDURE;