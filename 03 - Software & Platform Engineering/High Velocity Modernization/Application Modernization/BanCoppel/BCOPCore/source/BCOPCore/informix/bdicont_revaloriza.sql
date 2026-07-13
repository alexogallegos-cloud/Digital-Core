CREATE PROCEDURE "informix".revaloriza(p_empresa     CHAR(3),
                                       p_usuario     CHAR(8),
                                       p_password    CHAR(8))
        RETURNING CHAR(5);

   DEFINE cod_ret                       CHAR(5);
   DEFINE sql_err                       INTEGER;
   DEFINE isam_err                      INTEGER;
   DEFINE error_info                    CHAR(40);
   DEFINE nrows                         INTEGER;
   DEFINE whorafol                      DATETIME HOUR TO FRACTION(3);
   DEFINE whoratemp                     CHAR(12);
   DEFINE wusegen                       CHAR(8);
   DEFINE wtot_inter                    MONEY(14,2);
   DEFINE wtot_cap                      MONEY(14,2);
   DEFINE wcodinter                     CHAR(5);
   DEFINE wcodcap                       CHAR(5);

   DEFINE c                             INTEGER;
   DEFINE contador                      INTEGER;
   DEFINE wcontador                     CHAR(3);
   DEFINE v_contador                    INTEGER;

   DEFINE cuenta                        CHAR(4);
   DEFINE subcta                        CHAR(2);
   DEFINE subsubcta                     CHAR(6);
   DEFINE ssubsubcta                    CHAR(6);
   DEFINE sssubsubcta                   CHAR(6);
   --DEFINE sector                        CHAR(2);
   DEFINE regional                      CHAR(2);
   --DEFINE sucursal                      CHAR(5);
   DEFINE fecha                         DATE;
   DEFINE mes_aplica                    CHAR(2);
   DEFINE wmoneda                       CHAR(2);
   DEFINE debito                        money(16,2);
   DEFINE credito                       money(16,2);
   DEFINE v_fechax                      CHAR(10);
   DEFINE credito1                      MONEY(16,2);
   DEFINE debito1                       MONEY(16,2);
   DEFINE v_descripcion                 CHAR(50);
   DEFINE v_control                     INTEGER;
   DEFINE v_control2                    INTEGER;
   DEFINE v_tipo_cta                    CHAR(1);
   DEFINE v_contaerror                  INTEGER;
   DEFINE i                             INTEGER;
   DEFINE j                             INTEGER;
   DEFINE wcuantos                      INTEGER;
   DEFINE wcuantos1                     INTEGER;
   DEFINE w_cap_cargo_mn                MONEY(16,2);
   DEFINE v_cap_cargo_dls               MONEY(16,2);
   DEFINE v_cap_abono_mn                MONEY(16,2);
   DEFINE v_cap_abono_dls               MONEY(16,2);
   DEFINE v_control_poliza              INTEGER;
   DEFINE v_ciudad                      CHAR(3);
   DEFINE v_cifra_mn                    MONEY(16,2);
   DEFINE v_cifra_dls                   MONEY(16,2);
   DEFINE v_sql                         CHAR(700);
   DEFINE v_ruta                        CHAR(50);
   DEFINE v_reporte                     CHAR(100);
   DEFINE v_valida                      INTEGER;
   DEFINE wpassword                     CHAR(8);
   DEFINE wempresa                      CHAR(3);
   DEFINE wferesp                       DATE;
   DEFINE wfecha_pase                   DATE;
   DEFINE wfecha_ant                    DATE;
   DEFINE wproceses                     CHAR(10);

   DEFINE pempresa                      CHAR(3);
   DEFINE pmeses_historia               CHAR(2);
   DEFINE pmeses_saldos                 CHAR(2);
   DEFINE pmeses_retroact               CHAR(2);
   DEFINE pdias_saldos                  CHAR(3);
   DEFINE pmoneda_nacional              CHAR(2);
   DEFINE pcodigo_udis                  CHAR(2);
   DEFINE pdivisa_contra_camb           CHAR(1);
   DEFINE pvalor_cambio                 CHAR(2);
   DEFINE pmescierre1                   CHAR(2);
   DEFINE pmescierre2                   CHAR(2);
   DEFINE pcifra_control                CHAR(1);
   DEFINE panio_fiscal                  CHAR(2);
   DEFINE pruta_respaldo                CHAR(60);
   DEFINE psec_escape                   CHAR(10);
   DEFINE pcta_ing_inic                 CHAR(10);
   DEFINE pcta_ing_final                CHAR(10);
   DEFINE pcta_gto_inic                 CHAR(10);
   DEFINE pcta_gto_final                CHAR(10);
   DEFINE pcta_cap_inic                 CHAR(10);
   DEFINE pcta_cap_final                CHAR(10);
   DEFINE pcta_ord_inic                 CHAR(10);
   DEFINE pcta_ord_final                CHAR(10);
   DEFINE pper_gan_mayor                CHAR(10);
   DEFINE pper_gan_sub                  CHAR(10);
   DEFINE pper_gan_ss                   CHAR(10);
   DEFINE pper_gan_sss                  CHAR(10);
   DEFINE pper_gan_ssss                 CHAR(10);
   DEFINE pper_gan_sect                 CHAR(10);
   DEFINE prevalor_mayor                CHAR(10);
   DEFINE prevalor_sub                  CHAR(10);
   DEFINE prevalor_ss                   CHAR(10);
   DEFINE prevalor_sss                  CHAR(10);
   DEFINE prevalor_ssss                 CHAR(10);
   DEFINE prevalor_sect                 CHAR(10);
   DEFINE pcv_mn_mayor                  CHAR(4);
   DEFINE pcv_mn_sub                    CHAR(2);
   DEFINE pcv_mn_ss                     CHAR(2);
   DEFINE pcv_mn_sss                    CHAR(2);
   DEFINE pcv_mn_ssss                   CHAR(2);
   DEFINE pcv_mn_sector                 CHAR(2);
   DEFINE pcv_dls_mayor                 CHAR(4);
   DEFINE pcv_dls_sub                   CHAR(2);
   DEFINE pcv_dls_ss                    CHAR(2);
   DEFINE pcv_dls_sss                   CHAR(2);
   DEFINE pcv_dls_ssss                  CHAR(2);
   DEFINE pcv_dls_sector                CHAR(2);
   DEFINE plen_may                      SMALLINT;
   DEFINE plen_s                        SMALLINT;
   DEFINE plen_ss                       SMALLINT;
   DEFINE plen_sss                      SMALLINT;
   DEFINE plen_ssss                     SMALLINT;
   DEFINE plen_sect                     SMALLINT;
   DEFINE wfecha_cotiza                 DATE;
   DEFINE wfecha_cot                    DATE;
   DEFINE mes_ant                       SMALLINT;
   DEFINE anio_actual                   INTEGER;
   DEFINE lv_fecha_max                  DATE;
   DEFINE lv_fecha_hist                 DATE;
   DEFINE lv_ciudad                     CHAR(3);

   DEFINE lv_sucursal                   LIKE co_histsdodias.sucursal;
   DEFINE lv_ext_dls                    MONEY(18,2);
   DEFINE lv_dls                        MONEY(18,2);
   DEFINE lv_sdo_actual                 MONEY(18,2);
   DEFINE lv_sdo_inicial                MONEY(18,2);
   DEFINE lv_saldo                      MONEY(18,2);
   DEFINE lv_sub                        LIKE co_histsdodias.ccsub;
   DEFINE lv_subsub                     LIKE co_histsdodias.ccsubsub;
   DEFINE lv_ccssubsub                  LIKE co_histsdodias.ccssubsub;
   DEFINE lv_ccsssubsub                 LIKE co_histsdodias.ccsssubsub;
   DEFINE lv_sector                     LIKE co_histsdodias.sector;
   DEFINE b_indicador                   CHAR(1);
   DEFINE vw_control_poliza             SMALLINT;
   DEFINE lv_revalorizada               MONEY(18,2);
   DEFINE lv_monto                      MONEY(18,2);
   DEFINE lv_naturaleza                 CHAR(1);
   DEFINE lv_control_poliza             SMALLINT;
   DEFINE lv_primerreg                  CHAR(1);
   DEFINE maxdetpol                     INTEGER;
   DEFINE maxpol                        INTEGER;
   DEFINE lv_secuencia                  INTEGER;
   DEFINE lv_cargos                     LIKE co_poliza.capturado_cargo;
   DEFINE lv_abonos                     LIKE co_poliza.capturado_abono;
   DEFINE lv_cifra_control              LIKE co_poliza.cifra_control;
   DEFINE wcontrol                      INTEGER;
   DEFINE lv_moneda                     CHAR(2); -- co_sdodias.moneda;
   define vexiste           		integer;

   DEFINE wccmayor                      CHAR(4);
   DEFINE wsub                          CHAR(2);
   DEFINE wss                           CHAR(2);
   DEFINE wsss                          CHAR(2);
   DEFINE wssss                         CHAR(2);
   DEFINE wsector                       CHAR(2);
   DEFINE GLOBAL g_fecha_hoy            DATE            DEFAULT " ";
   DEFINE GLOBAL g_ult_hab_mes          DATE            DEFAULT " ";
   DEFINE GLOBAL g_pri_dia_mes          DATE            DEFAULT " ";
   DEFINE GLOBAL g_pri_dia_hab_mes      DATE            DEFAULT " ";
   DEFINE GLOBAL g_num_credito          CHAR(20)        DEFAULT " ";
   DEFINE GLOBAL g_num_producto         CHAR(4)         DEFAULT " ";
   DEFINE GLOBAL g_numcte               CHAR(20)        DEFAULT " ";
   DEFINE GLOBAL g_divisa               CHAR(2)         DEFAULT " ";
   DEFINE GLOBAL g_cod_linea            CHAR(4)         DEFAULT " ";
   DEFINE GLOBAL g_es_fisica            CHAR(1)         DEFAULT " ";
   DEFINE GLOBAL g_num_linea            CHAR(20)        DEFAULT " ";
   DEFINE GLOBAL g_tipo_calculo         CHAR(2)         DEFAULT " ";
   DEFINE GLOBAL g_int_venc             MONEY(14,2)     DEFAULT 0;
   DEFINE GLOBAL g_sdo_moratorio        MONEY(14,2)     DEFAULT 0;
   DEFINE GLOBAL g_cap_venc             MONEY(14,2)     DEFAULT 0;
   DEFINE GLOBAL g_ctachq_cap           CHAR(20)        DEFAULT " ";
   DEFINE GLOBAL g_ctachq_int           CHAR(20)        DEFAULT " ";
   DEFINE GLOBAL g_folio                CHAR(16)        DEFAULT " ";
   DEFINE GLOBAL g_codudi               CHAR(2)         DEFAULT " ";
   DEFINE GLOBAL g_tasa_ordi            DECIMAL(9,6)    DEFAULT 0;
   DEFINE GLOBAL g_tasa_mora            DECIMAL(9,6)    DEFAULT 0;
   DEFINE GLOBAL g_iva                  DECIMAL(5,3)    DEFAULT 0;
   DEFINE GLOBAL g_usuario              CHAR(8)         DEFAULT " ";
   DEFINE GLOBAL g_sucursal             CHAR(4)         DEFAULT " ";
   DEFINE GLOBAL g_fecha_apertura       DATE            DEFAULT " ";
   DEFINE GLOBAL g_fecha_vencim         DATE            DEFAULT " ";

   DEFINE GLOBAL g_mora_cobra           MONEY(16,2)     DEFAULT 0;
   DEFINE GLOBAL g_mora_codret          CHAR(5)         DEFAULT " ";
   DEFINE GLOBAL g_cartera_asociada     CHAR(1)         DEFAULT " ";
   DEFINE GLOBAL g_intvenc_cobra        MONEY(16,2)     DEFAULT 0;
   DEFINE GLOBAL g_intvenc_codret       CHAR(5)         DEFAULT " ";
   DEFINE GLOBAL g_capvenc_cobra        MONEY(16,2)     DEFAULT 0;
   DEFINE GLOBAL g_capvenc_codret       CHAR(5)         DEFAULT " ";
   DEFINE GLOBAL g_intvig_cobra         MONEY(16,2)     DEFAULT 0;
   DEFINE GLOBAL g_intvig_codret        CHAR(5)         DEFAULT " ";
   DEFINE GLOBAL g_capvig_cobra         MONEY(16,2)     DEFAULT 0;
   DEFINE GLOBAL g_capvig_codret        CHAR(5)         DEFAULT " ";
   DEFINE GLOBAL g_iva_cobra            MONEY(16,2)     DEFAULT 0;
   DEFINE GLOBAL g_archivo              CHAR(100)       DEFAULT " ";
   DEFINE GLOBAL g_detalle              CHAR(61)        DEFAULT " ";

   DEFINE pgan_mayor            char(10);
   DEFINE pgan_sub              char(10);
   DEFINE pgan_ss               char(10);
   DEFINE pgan_sss              char(10);
   DEFINE pgan_ssss             char(10);
   DEFINE pgan_sect             char(10);
   DEFINE pper_mayor            char(10);
   DEFINE pper_sub              char(10);
   DEFINE pper_ss               char(10);
   DEFINE pper_sss              char(10);
   DEFINE pper_ssss             char(10);
   DEFINE pper_sect             char(10);
   DEFINE pcta_correl_inic      CHAR(10);
   DEFINE pcta_correl_final     CHAR(10);
   DEFINE pcta_val_mn           char(10);
   DEFINE pcta_val_dls          char(10);

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      SET DEBUG FILE TO "Revaloriza.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;

      RETURN cod_ret;
   END EXCEPTION;

   
{***************************************************************************
 **   OBTENCION DE INFORMACION GENERAL PARA EL PROCESO                    **
 ***************************************************************************}
   LET g_usuario = USER;
   LET g_mora_codret = "000";
   LET g_intvenc_codret = "000";
   LET contador         = 1;
   LET v_contador = 0;
   LET g_detalle  = " ";
   LET cuenta      = " ";
   LET subcta      = " ";
   LET subsubcta   = " ";
   LET ssubsubcta  = " ";
   LET sssubsubcta = " ";
   --LET sector      = " ";
   LET regional    = " ";
   --LET sucursal    = " ";
   LET fecha       = " ";
   LET mes_aplica  = " ";
   LET wmoneda      = "01";
   LET debito      = 0;
   LET credito     = 0;
   LET v_fechax    = " ";
   LET credito1    = 0;
   LET debito1     = 0;
   LET w_cap_cargo_mn  = 0;
   LET v_cap_cargo_dls = 0;
   LET v_cap_abono_mn  = 0;
   LET v_cap_abono_dls = 0;
   LET v_control_poliza = 0;
   LET v_ciudad    = " ";
   LET v_cifra_mn  = 0;
   LET v_cifra_dls = 0;
   LET v_valida    = 0;
   LET wpassword   = " ";
   LET wempresa    = " ";
   LET wferesp     = " ";
   LET wfecha_pase = " ";
   LET wfecha_ant  = " ";
   LET pempresa             = " ";
   LET pmeses_historia      = " ";
   LET pmeses_saldos        = " ";
   LET pmeses_retroact      = " ";
   LET pdias_saldos         = " ";
   LET pmoneda_nacional     = " ";
   LET pcodigo_udis         = " ";
   LET pdivisa_contra_camb  = " ";
   LET pvalor_cambio        = " ";
   LET pmescierre1       = " ";
   LET pmescierre2       = " ";
   LET pcifra_control    = " ";
   LET panio_fiscal      = " ";
   LET pruta_respaldo    = " ";
   LET psec_escape       = " ";
   LET pcta_ing_inic     = " ";
   LET pcta_ing_final    = " ";
   LET pcta_gto_inic     = " ";
   LET pcta_gto_final    = " ";
   LET pcta_cap_inic     = " ";
   LET pcta_cap_final    = " ";
   LET pcta_ord_inic     = " ";
   LET pcta_ord_final    = " ";
   LET pper_gan_mayor    = " ";
   LET pper_gan_sub      = " ";
   LET pper_gan_ss       = " ";
   LET pper_gan_sss      = " ";
   LET pper_gan_ssss     = " ";
   LET pper_gan_sect     = " ";
   LET prevalor_mayor    = " ";
   LET prevalor_sub      = " ";
   LET prevalor_ss       = " ";
   LET prevalor_sss      = " ";
   LET prevalor_ssss     = " ";
   LET prevalor_sect     = " ";
   LET pcv_mn_mayor    = " ";
   LET pcv_mn_sub    = " ";
   LET pcv_mn_ss     = " ";
   LET pcv_mn_sss    = " ";
   LET pcv_mn_ssss   = " ";
   LET pcv_mn_sector = " ";
   LET pcv_dls_mayor = " ";
   LET pcv_dls_sub = " ";
   LET pcv_dls_ss = " ";
   LET pcv_dls_sss   = " ";
   LET pcv_dls_ssss  = " ";
   LET pcv_dls_sector = " ";
   LET plen_may = 0;
   LET plen_s   = 0;
   LET plen_ss  = 0;
   LET plen_sss = 0;
   LET plen_ssss = 0;
   LET plen_sect = 0;
   LET wfecha_cot = " ";
   LET lv_fecha_max  = " ";
   LET lv_fecha_hist = " ";
   LET lv_sucursal    = " ";
   LET lv_ext_dls     = 0;
   LET lv_dls         = 0;
   LET lv_sdo_actual  = 0;
   LET lv_sdo_inicial = 0;
   LET lv_saldo       = 0;
   LET lv_sub         = " ";
   LET lv_subsub      = " ";
   LET lv_ccssubsub   = " ";
   LET lv_ccsssubsub  = " ";
   LET lv_sector      = " ";
   LET lv_moneda      = " ";
   LET b_indicador  = " ";
   LET vw_control_poliza = 0;
   LET wccmayor = " ";
   LET wsub = " ";
   LET wss = " ";
   LET wsss = " ";
   LET wssss = " ";
   LET wsector = " ";
   LET lv_revalorizada = 0;
   LET lv_naturaleza = " ";
   LET lv_control_poliza = 0;
   LET lv_primerreg = "S";
   LET maxdetpol = 0;
   LET maxpol = 0;
   LET lv_secuencia = 1;
   LET wproceses = "reval_men";

   LET pgan_mayor = " ";
   LET pgan_sub   = " ";
   LET pgan_ss    = " ";
   LET pgan_sss   = " ";
   LET pgan_ssss  = " ";
   LET pgan_sect  = " ";
   LET pper_mayor = " ";
   LET pper_sub   = " ";
   LET pper_ss    = " ";
   LET pper_sss   = " ";
   LET pper_ssss  = " ";
   LET pper_sect  = " ";
   LET pcta_correl_inic  = " ";
   LET pcta_correl_final = " ";
   LET pcta_val_mn  = " ";
   LET pcta_val_dls = " ";
   let vexiste       = 1;

   SELECT
      fecha_hoy, ult_hab_mes, pri_dia_mes, pri_hab_mes
   INTO
      g_fecha_hoy, g_ult_hab_mes, g_pri_dia_mes, g_pri_dia_hab_mes
   FROM
      bdicont:co_fechas
   WHERE
      bdicont:co_fechas.empresa = p_empresa;

   {IF g_fecha_hoy <> g_pri_dia_hab_mes THEN
      LET cod_ret = "123";
      RETURN cod_ret;
   END IF;}

   LET nrows  = 0;
   LET cod_ret = "000";

   --Valida se el Proceso Ya Se Genero En El Dia.
   LET v_valida    = 0;
   LET wpassword   = " ";

   SELECT password INTO wpassword
   FROM bdinteg:si_ejecut
   WHERE bdinteg:si_ejecut.ejecutivo = p_usuario
   AND   bdinteg:si_ejecut.empresa = p_empresa;

    --IF wpassword IS NULL OR wpassword = " " THEN
    --  LET cod_ret = "120";
    --  RETURN cod_ret;
    --END IF;

    --IF wpassword != p_password THEN
    --  LET cod_ret = "121";
    --  RETURN cod_ret;
    --END IF;

    --Valida la Empresa a Procesar
    SELECT empresa INTO wempresa
    FROM bdinteg:si_empresas
    WHERE empresa = p_empresa;

    IF wempresa != p_empresa THEN
      LET cod_ret = "122";
      RETURN cod_ret;
    END IF;

    -- Verifica se haya realizado el respaldo previo
    SELECT fecha INTO wferesp FROM co_contproc
    WHERE proceso = "respaldo"
    AND empresa = p_empresa;


   IF wferesp != g_fecha_hoy THEN
      LET cod_ret = "123";
      RETURN cod_ret;
   END IF;

   -- Verifica si puede realizar el proceso de revalorizacion mensual

   SELECT fecha INTO wfecha_pase FROM co_contproc
   WHERE empresa = wempresa
   AND proceso = "reval_men";
   LET wcontrol = 0;

   -- Verifica la Actualizacion del Control de Procesos de Contabilidad.
   SELECT COUNT(*) INTO wcontrol FROM co_contproc
   WHERE proceso = "reval_men"
   AND empresa = p_empresa;

  IF wcontrol >= 1 THEN
      LET cod_ret = "124";
      RETURN cod_ret;
  END IF;

  LET wfecha_ant  = " ";

  -- determina el mes inmediato anterior

  LET wfecha_ant = g_pri_dia_mes - 1 units day;
  while vexiste = 1 or weekday(wfecha_ant) = 0 or weekday(wfecha_ant) = 6
             if weekday(wfecha_ant) = 0 then
                let wfecha_ant = wfecha_ant - 1 units day;
             elif weekday(wfecha_ant) = 6 then
                   let wfecha_ant = wfecha_ant - 1;
             else
                select count(*) into vexiste
                from bdinteg:si_feriado
                where empresa = pempresa and
                      pais    = "001" and
                      fecha   = wfecha_ant;
                if vexiste > 0 then
                   let wfecha_ant = wfecha_ant - 1 units day;
                else  
                   let wfecha_ant = wfecha_ant;
                   let vexiste = 0;
                end if
             end if
  end while
  

   -- Obtine los parametros de cuentas a valorizar y la cta de revalorizacion

   BEGIN WORK;
   SET ISOLATION TO DIRTY READ;
      SELECT empresa, meses_historia, meses_saldos, meses_retroact, dias_saldos, moneda_nacional, codigo_udis,
           divisa_contra_camb, valor_cambio, mescierre1, mescierre2, cifra_control, anio_fiscal, ruta_respaldo,
           sec_escape, cta_ing_inic, cta_ing_final, cta_gto_inic, cta_gto_final, cta_cap_inic, cta_cap_final,
           cta_ord_inic, cta_ord_final, per_gan_mayor, per_gan_sub, per_gan_ss, per_gan_sss, per_gan_ssss,
           per_gan_sect, revalor_mayor, revalor_sub, revalor_ss, revalor_sss, revalor_ssss, revalor_sect,
           cv_mn_mayor, cv_mn_sub, cv_mn_ss, cv_mn_sss, cv_mn_ssss, cv_mn_sector, cv_dls_mayor, cv_dls_sub,
           cv_dls_ss, cv_dls_sss, cv_dls_ssss, cv_dls_sector, len_may, len_s, len_ss, len_sss, len_ssss,
           len_sect,gan_mayor,gan_sub,gan_ss,gan_sss,gan_ssss,gan_sect,per_mayor,per_sub,per_ss,per_sss,per_ssss,
           per_sect,cta_val_mn,cta_val_dls,cta_correl_inic,cta_correl_final
      INTO pempresa, pmeses_historia, pmeses_saldos, pmeses_retroact, pdias_saldos, pmoneda_nacional, pcodigo_udis,
           pdivisa_contra_camb, pvalor_cambio, pmescierre1, pmescierre2, pcifra_control, panio_fiscal, pruta_respaldo,
           psec_escape, pcta_ing_inic, pcta_ing_final, pcta_gto_inic, pcta_gto_final, pcta_cap_inic, pcta_cap_final,
           pcta_ord_inic, pcta_ord_final, pper_gan_mayor, pper_gan_sub, pper_gan_ss, pper_gan_sss, pper_gan_ssss,
           pper_gan_sect, prevalor_mayor, prevalor_sub, prevalor_ss, prevalor_sss, prevalor_ssss, prevalor_sect,
           pcv_mn_mayor, pcv_mn_sub, pcv_mn_ss, pcv_mn_sss, pcv_mn_ssss, pcv_mn_sector, pcv_dls_mayor, pcv_dls_sub,
           pcv_dls_ss, pcv_dls_sss, pcv_dls_ssss, pcv_dls_sector, plen_may, plen_s, plen_ss, plen_sss, plen_ssss,
           plen_sect,pgan_mayor,pgan_sub,pgan_ss,pgan_sss,pgan_ssss,pgan_sect,pper_mayor,pper_sub,pper_ss,pper_sss,
           pper_ssss,pper_sect,pcta_val_mn,pcta_val_dls,pcta_correl_inic,pcta_correl_final
      FROM co_param
      WHERE empresa = p_empresa;

      IF pempresa IS NULL OR pempresa = " " THEN
         LET b_indicador = "2";
         LET vw_control_poliza = 0;
         LET cod_ret = "125";
         RETURN cod_ret;
      END IF;
   COMMIT WORK;

   -- Determina el Ultimo Dia de Cotizacion del Mes Anterior
   LET wfecha_cotiza = g_pri_dia_mes - 1 units month;

   SELECT MAX(fecha_tc)
     INTO wfecha_cot
     FROM bdinteg:si_histdiv
     WHERE divisa = pvalor_cambio
     AND clase_tpcambio = "O"
     AND month(fecha_tc) = month(wfecha_cotiza)
     AND year(fecha_tc) = year(wfecha_cotiza);

     --LET mes_ant = MONTH(wfecha_ant);
     --LET anio_actual = YEAR(wfecha_ant);
     LET lv_fecha_hist = g_fecha_hoy - 1 units month;

   SELECT MAX(mes_dia)
   INTO lv_fecha_max
   FROM co_histsdodias
   WHERE YEAR(mes_dia) = YEAR(lv_fecha_hist)
   AND MONTH(mes_dia) = MONTH(lv_fecha_hist);

---

   LET wccmayor = trim(pcv_mn_mayor);
   LET wsub = trim(pcv_mn_sub);
   LET wss = trim(pcv_mn_ss);
   LET wsss = trim(pcv_mn_sss);
   LET wssss = trim(pcv_mn_ssss);
   LET wsector = trim(pcv_mn_sector);

   -- Se Genera Un Cursor Para Traer las Cuentas en Moneda Nacional
   FOREACH --WITH HOLD
      SELECT ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, ciudad, sucursal,SUM(saldo_fin_de_dia)
      INTO lv_sub, lv_subsub, lv_ccssubsub, lv_ccsssubsub, lv_sector, lv_ciudad, lv_sucursal, lv_sdo_actual
      --SELECT ccsub, ccsubsub, ccssubsub, ccsssubsub, ciudad, SUM(saldo_fin_de_dia)
      --INTO lv_sub, lv_subsub, lv_ccssubsub, lv_ccsssubsub,lv_ciudad, lv_sdo_actual
      FROM co_histsdodias
      WHERE empresa = p_empresa
      AND ccmayor = pcv_mn_mayor
      --AND ccsub = wsub
      --AND ccsubsub = wss
      --AND ccssubsub = wsss
      --AND ccsssubsub = wssss
      --AND sector = wsector
      --AND moneda = wmoneda
      AND mes_dia = lv_fecha_max
      --AND mes_dia = wfecha_cotiza
      GROUP BY ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,ciudad,sucursal

            ------
         LET lv_sub=lv_sub;
         LET lv_subsub=lv_subsub;
         LET lv_ccssubsub=lv_ccssubsub;
         LET lv_ccsssubsub=lv_ccsssubsub;
         LET lv_sector=lv_sector;
         LET lv_sucursal=lv_sucursal;

         SELECT sector,sucursal
         INTO lv_sector,lv_sucursal
         FROM co_histsdodias
         WHERE empresa = p_empresa
         AND ccmayor = pcv_mn_mayor
         AND ccsub = lv_sub
         AND ccsubsub = lv_subsub
         AND ccssubsub = lv_ccssubsub
         AND ccsssubsub = lv_ccsssubsub
         AND moneda = wmoneda
         AND mes_dia = lv_fecha_max;

         --LET lv_sector = "00";
         --LET lv_sucursal = "0001";

            -------

            LET lv_saldo = lv_sdo_actual;
            LET lv_sector = lv_sector;
            LET lv_sucursal = lv_sucursal;

            SELECT SUM(saldo_fin_de_dia)
            INTO lv_dls
            FROM co_histsdodias
            WHERE empresa = p_empresa
            --AND ccmayor = wccmayor
            AND ccmayor = pcv_dls_mayor
            AND ccsub = lv_sub
            AND ccsubsub = lv_subsub
            AND ccssubsub = lv_ccssubsub
            AND ccsssubsub =  lv_ccsssubsub
            AND sector = lv_sector
            AND moneda = pvalor_cambio
            AND ciudad = lv_ciudad
            AND sucursal = lv_sucursal
            AND mes_dia  = lv_fecha_max;
	    --AND mes_dia  = wfecha_cotiza;

            SELECT (precio_venta * lv_dls)
            INTO
                   lv_revalorizada
            FROM
                   bdinteg:si_histdiv
            WHERE
                   divisa = pvalor_cambio
            AND
                   fecha_tc = wfecha_cot
            AND
                   clase_tpcambio = "O";


            IF (lv_revalorizada < 0) THEN
               LET lv_revalorizada = lv_revalorizada * -1;
            END IF;
            IF (lv_saldo < 0) THEN
                LET lv_saldo = lv_saldo * -1;
            END IF;

            LET lv_monto = lv_saldo - lv_revalorizada;
            IF (lv_monto > 0) THEN
                LET lv_naturaleza = "D";
            ELSE
                IF (lv_monto < 0) THEN
                    LET lv_naturaleza = "C";
                ELSE
                    LET lv_naturaleza = " ";
                    LET b_indicador = "0";
                    LET lv_control_poliza = 0;
                    LET vw_control_poliza = 0;
                    --LET cod_ret = "127";
                    LET cod_ret = "000";
                    RETURN cod_ret;     -- return b_indicador, vw_control_poliza
                END IF;
            END IF;

            IF (lv_monto < 0) THEN
               LET lv_monto = lv_monto * -1;
            END IF;

            let lv_sector=lv_sector;
            let lv_sucursal=lv_sucursal;
            IF (lv_primerreg = "S" AND lv_naturaleza <> " ") THEN
                SELECT
                  MAX(control_poliza)
                INTO
                  maxdetpol
                FROM
                  co_detpol
                WHERE
                  usuario = p_usuario
                AND
                  fecha_captura = g_fecha_hoy;

                SELECT
                  MAX(numero)
                INTO
                  maxdetpol
                FROM
                  co_ctrlpoliza;

                        IF (maxdetpol IS NULL) THEN
                            LET maxdetpol = 0;
                        END IF;

                            SELECT
                                MAX(control_poliza)
                            INTO
                                maxpol
                            FROM
                                co_poliza
                            WHERE
                                usuario = p_usuario
                            AND
                                fecha_captura = g_fecha_hoy;

		                SELECT
		                  MAX(numero)
		                INTO
		                  maxpol
		                FROM
		                  co_ctrlpoliza;

                                IF (maxpol is null) THEN
                                    LET maxpol = 0;
                                END IF;

                                IF (maxpol > maxdetpol) THEN
                                    LET lv_control_poliza = maxpol;
                                ELSE
                                    LET lv_control_poliza = maxdetpol;
                                END IF;


                                LET lv_control_poliza = lv_control_poliza + 1;
				
				UPDATE co_ctrlpoliza SET numero=lv_control_poliza;	

                                IF (lv_naturaleza != " ") THEN
                                   INSERT INTO
                                          co_poliza
                                   values
                                          (p_empresa,
                                           p_usuario,
                                           lv_control_poliza,
                                           g_fecha_hoy,
                                           0,
                                           0,
                                           0,
                                           "01",
                                           "POLIZA DE REVALORIZACION MENSUAL");

                                 END IF;
                           END IF;

                           LET lv_primerreg = "N";

                           IF (lv_naturaleza = "C") THEN

                               -- Cargo a la Cuenta de Revalorizacion (Pérdida)

                               INSERT INTO
                                      co_detpol
                               VALUES
                                      (p_usuario,
                                       lv_control_poliza,
                                       g_fecha_hoy,
                                       lv_secuencia,
                                       p_empresa,
                                       --prevalor_mayor,
                                       --prevalor_sub,
                                       --prevalor_ss,
                                       --prevalor_sss,
                                       --prevalor_ssss,
                                       --prevalor_sect,
                                       pper_mayor,
                                       pper_sub,
                                       pper_ss,
                                       pper_sss,
                                       pper_ssss,
                                       pper_sect,
                                       lv_ciudad,
                                       lv_sucursal,
                                       "0",
                                       lv_naturaleza,
                                       lv_monto,
                                       "REVALORIZACION MENSUAL",
                                       wfecha_ant,
                                       pmoneda_nacional,
                                       0, 0, 0, " ", " ",lv_sucursal);

                                       -- Abono a cuenta de compra/venta de MN

                                       LET lv_naturaleza = "D";
                                       LET lv_secuencia = lv_secuencia + 1;
                                 INSERT INTO
                                        co_detpol
                                 VALUES
                                        (p_usuario,
                                         lv_control_poliza,
                                         g_fecha_hoy,
                                         lv_secuencia,
                                         p_empresa,
                                         pcv_mn_mayor,
                                         lv_sub,
                                         lv_subsub,
                                         lv_ccssubsub,
                                         lv_ccsssubsub,
                                         lv_sector,
                                         lv_ciudad,
                                         lv_sucursal,
                                         "0",
                                         lv_naturaleza,
                                         lv_monto,
                                         "REVALORIZACION MENSUAL",
                                          wfecha_ant,
                                         pmoneda_nacional,
                                         0, 0, 0, " ", " ",lv_sucursal);


                           ELSE
                                  -- Cargo a la Cuenta de D compra-Venta de MN (Ganancia)

                                  INSERT INTO
                                         co_detpol
                                  VALUES
                                         (p_usuario,
                                          lv_control_poliza,
                                          g_fecha_hoy,
                                          lv_secuencia,
                                          p_empresa,
                                          --prevalor_mayor,
                                          --prevalor_sub,
                                          --prevalor_ss,
                                          --prevalor_sss,
                                          --prevalor_ssss,
                                          --prevalor_sect,
                                          pgan_mayor,
                                          pgan_sub,
                                          pgan_ss,
                                          pgan_sss,
                                          pgan_ssss,
                                          pgan_sect,
                                          lv_ciudad,
                                          lv_sucursal,
                                          "0",
                                          lv_naturaleza,
                                          lv_monto,
                                          "REVALORIZACION MENSUAL",
                                          wfecha_ant,
                                          pmoneda_nacional,
                                          0, 0, 0, " ", " ",lv_sucursal);

                                   -- Abono a la cuenta de revalorizacion

                                   LET lv_secuencia = lv_secuencia + 1;
                                   LET lv_naturaleza = "C";
                                   INSERT INTO
                                          co_detpol
                                   VALUES
                                          (p_usuario,
                                           lv_control_poliza,
                                           g_fecha_hoy,
                                           lv_secuencia,
                                           p_empresa,
                                           pcv_mn_mayor,
                                           lv_sub,
                                           lv_subsub,
                                           lv_ccssubsub,
                                           lv_ccsssubsub,
                                           lv_sector,
                                           lv_ciudad,
                                           lv_sucursal,
                                           "0",
                                           lv_naturaleza,
                                           lv_monto,
                                           "REVALORIZACION MENSUAL",
                                           wfecha_ant,
                                           pmoneda_nacional,
                                           0, 0, 0, " ", " ",lv_sucursal);

                           END IF;

       LET lv_secuencia = lv_secuencia + 1;

   END FOREACH;


   -- Se Actualizan los Valores del Encabezado de la Poliza.
      SELECT
         sum(monto)
      INTO
         lv_cargos
      FROM
         co_detpol
      WHERE
         usuario        = p_usuario and
         control_poliza = lv_control_poliza and
         fecha_captura  = g_fecha_hoy and
         moneda         = pmoneda_nacional and
         naturaleza     = "D";


      SELECT
         SUM(monto)
      INTO
         lv_abonos
      FROM
         co_detpol
      WHERE
         usuario        = p_usuario and
         control_poliza = lv_control_poliza and
         fecha_captura  = g_fecha_hoy and
         moneda         = pmoneda_nacional and
         naturaleza     = "C";

      LET lv_cifra_control = lv_cargos;
      UPDATE co_poliza SET
         capturado_cargo = lv_cargos,
         capturado_abono = lv_abonos,
         cifra_control   = lv_cifra_control
      WHERE
         usuario        = p_usuario and
         control_poliza = lv_control_poliza and
         fecha_captura  = g_fecha_hoy and
         moneda         = pmoneda_nacional;


   LET vw_control_poliza = lv_control_poliza;
   --return b_indicador, vw_control_poliza

   IF cod_ret = "000" THEN
      LET wcontrol = 0;
      -- Verifica la Actualizacion del Control de Procesos de Contabilidad.
      SELECT COUNT(*) INTO wcontrol FROM co_contproc
      WHERE proceso = "reval_men"
      AND empresa = p_empresa;

      IF wcontrol <= 0 THEN
         INSERT INTO co_contproc
         VALUES(p_empresa,wproceses,g_fecha_hoy,cod_ret);

      ELSE
         UPDATE co_contproc
                SET (fecha,cod_ret) = (g_fecha_hoy,cod_ret)
         WHERE proceso = wproceses
         AND empresa = p_empresa;

      END IF;
   END IF;

RETURN cod_ret;

END PROCEDURE
DOCUMENT
"Esta rutina realiza la Revalorizacion de Las Cuentas Contables de Dolares a Pesos.",
"y Despues Genera La Poliza de Los Movimientos del Dia Por Empresa Contable ",
"BD    : bdicont",
"VER   : 1.1";

CREATE PROCEDURE "informix".rptconciliacion(pv_empresa	CHAR(3),pd_fechaRep date ,pv_currentusr VARCHAR(10))
   RETURNING INTEGER, VARCHAR(10);
	DEFINE ln_err INTEGER;
	DEFINE lv_paso VARCHAR(10);
	--Variables de actualizacion de datos
	DEFINE ld_fecha_proceso date;
  DEFINE lv_sistema   char(2);
  DEFINE lv_empresa char(3);
  DEFINE lv_ccmayor char(10);
  DEFINE lv_ccsub char(10);
  DEFINE lv_ccsubsub char(10);
  DEFINE lv_ccssubsub char(10);
  DEFINE lv_ccsssubsub char(10);
  DEFINE lv_sector char(10);
  DEFINE lv_cta_Cliente  char(11);
  DEFINE lv_ciudad char(3);
  DEFINE lv_folio  char(16);
  DEFINE lv_sucursal  char(04);
  DEFINE ln_debitos money(18,2);
  DEFINE ln_creditos money(18,2);
  DEFINE ln_debitos_suc money(18,2);
  DEFINE ln_creditos_suc money(18,2);
  DEFINE lv_descripcion_det char(80);
  DEFINE lv_ccosto_dest char(4);
  DEFINE lv_moneda char(2);
  DEFINE ln_nDebitos INTEGER;
  DEFINE ln_nCreditos INTEGER;
  DEFINE ln_nDebitos_suc INTEGER;
  DEFINE ln_nCreditos_suc INTEGER;
  DEFINE ln_nDiferencia money(18,2);
  DEFINE ln_nDiferencia_suc money(18,2);
  DEFINE lv_nOrigen	CHAR(1);   -- 1. sUCURSALES, 2. CENTRALES
  DEFINE ld_fechaSis 	DATE;
   ON EXCEPTION
    SET ln_err
      RETURN ln_err, lv_paso;
   END EXCEPTION;

	LET ln_err = 0;
	LET lv_paso = 'Paso 0' ;
--SET DEBUG FILE TO "/tmp/con.out";
--TRACE ON;
  
  	truncate co_audconresum;
  	truncate co_auditerr_cint;
  
	--Transferencia de polizas de usuario

	SELECT fecha_hoy
	INTO  ld_fechaSis
	FROM bdicont:co_fechas
	WHERE empresa = pv_empresa;

	IF MONTH(ld_fechaSis) = MONTH(pd_fechaRep) AND YEAR(ld_fechaSis) = YEAR(pd_fechaRep) THEN
	LET lv_paso = 'Paso 1';
  		INSERT INTO co_auditerr_cint
  		(fecha_proceso, sistema, empresa,usuario,control_poliza,secuencia, ccmayor,ccsub,
			  ccsubsub,ccssubsub,ccsssubsub,sector,cta_Cliente,
			  ciudad,folio,sucursal,debitos,creditos,descripcion_det,
			  ccosto_dest,moneda,nDebitos,nCreditos, nDiferencia,
			  nOrigen,currentuser)
  	select
  		fecha_valida,
  		decode( upper(trim(usuario)),
  		upper('chqinfor'),'01',
  		upper('invinfor'),'03',
  		upper('credito'),'06',
  		upper('spei'),'01',
  			'07') sistema,
  		empresa, usuario,control_poliza,secuencia,
  		ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
  		--sector,'' cta_cliente, ciudad,'' folio, sucursal,
  		sector,'' cta_cliente, ciudad,'' folio, ccosto_orig,
  		decode(naturaleza,
  										'D', monto,
  										0),
  		decode(naturaleza,
  										'C', monto,
  										0),
  		descripcion,
  		ccosto_orig,
  		moneda,
  		decode(naturaleza,
  										'D', 1,
  										0),
  		decode(naturaleza,
  										'C', 1,
  										0),
  		 0,
  		'2',pv_currentusr
  		 from co_mensual
  		 WHERE upper(trim(usuario)) in (upper('chqinfor'),upper('credito'))
  		 AND fecha_captura >= pd_fechaRep
         AND substr(ccmayor,1,2) = '95'
         AND empresa = pv_empresa
		 AND fecha_valida = pd_fechaRep;

  		  --Transferencia de datos de tabla de paso
  		LET lv_paso = 'Paso 2';
			LET pd_fechaRep = pd_fechaRep;
			LET pv_empresa = pv_empresa;

			  INSERT INTO co_auditerr_cint
  		(fecha_proceso, sistema, empresa,usuario,control_poliza,secuencia, ccmayor,ccsub,
			  ccsubsub,ccssubsub,ccsssubsub,sector,cta_Cliente,
			  ciudad,folio,sucursal,debitos_suc,creditos_suc,descripcion_det,
			  ccosto_dest,moneda,nDebitos_suc,nCreditos_suc, nDiferencia_suc,
			  nOrigen,currentuser)
  		select
  		fecha_valida,
  			(select sistema
  			from tbEnlaceSis ten
  			where
  			ten.ccmayor       = cod.ccmayor
  			and ten.ccsub         = cod.ccsub
  			and ten.ccsubsub      = cod.ccsubsub
  			and ten.ccssubsub     = cod.ccssubsub
  			and ten.ccsssubsub    = cod.ccsssubsub
  			and ten.sector        = cod.sector) sistema,
  		empresa, usuario,control_poliza,secuencia,
  		ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
  		--sector,'' cta_cliente, ciudad,'' folio, sucursal,
			sector,'' cta_cliente, ciudad,'' folio, ccosto_orig,
  		decode(naturaleza,
  										'D', monto,
  										0),
  		decode(naturaleza,
  										'C', monto,
  										0),
  		descripcion,
  		--sucursal,
  		ccosto_orig,
  		moneda,
  		decode(naturaleza,
  										'D', 1,
  										0),
  		decode(naturaleza,
  										'C', 1,
  										0),
  		 0,
  		'1',pv_currentusr
  		 from co_mensual cod
  		 WHERE length(trim(usuario)) = 4
  		 AND fecha_captura >= pd_fechaRep
         AND substr(ccmayor,1,2) = '95'
         AND empresa = pv_empresa
		 AND fecha_valida = pd_fechaRep;

	ELSE

			LET lv_paso = 'Paso 3';
  		INSERT INTO co_auditerr_cint
  		(fecha_proceso, sistema, empresa,usuario,control_poliza,secuencia, ccmayor,ccsub,
			  ccsubsub,ccssubsub,ccsssubsub,sector,cta_Cliente,
			  ciudad,folio,sucursal,debitos,creditos,descripcion_det,
			  ccosto_dest,moneda,nDebitos,nCreditos, nDiferencia,
			  nOrigen,currentuser)
  		select
  		fecha_valida,
  		decode( upper(trim(usuario)),
  		upper('chqinfor'),'01',
  		upper('invinfor'),'03',
  		upper('credito'),'06',
  		upper('spei'),'01',
  		'07') sistema,
  		empresa, usuario,control_poliza,secuencia,
  		ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
  		--sector,'' cta_cliente, ciudad,'' folio, sucursal,
  		sector,'' cta_cliente, ciudad,'' folio, ccosto_orig,
  		decode(naturaleza,
  										'D', monto,
  										0),
  		decode(naturaleza,
  										'C', monto,
  										0),
  		descripcion,
  		--sucursal,
  		ccosto_orig,
  		moneda,
  		decode(naturaleza,
  										'D', 1,
  										0),
  		decode(naturaleza,
  										'C', 1,
  										0),
  		 0,
  		'2',pv_currentusr
  		from co_historico
  		WHERE upper(trim(usuario)) in (upper('chqinfor'),upper('credito'))
        AND control_poliza IS NOT NULL
  		AND fecha_captura >= pd_fechaRep
        AND secuencia > 0
        AND empresa = pv_empresa
        AND ccmayor  like '95%'
        AND ccsub IS NOT NULL
        AND ccsubsub IS NOT NULL
        AND ccssubsub IS NOT NULL
        AND ccsssubsub IS NOT NULL
        AND sector IS NOT NULL
        AND ciudad IS NOT NULL
        AND sucursal IS NOT NULL
        AND nro_auxiliar IS NOT NULL
		AND fecha_valida = pd_fechaRep
        AND moneda IS NOT NULL ;

  		  --Transferencia de datos de tabla de paso
  		LET lv_paso = 'Paso 4';
			LET pd_fechaRep = pd_fechaRep;
			LET pv_empresa = pv_empresa;

			  INSERT INTO co_auditerr_cint
  		(fecha_proceso, sistema, empresa,usuario,control_poliza,secuencia, ccmayor,ccsub,
			  ccsubsub,ccssubsub,ccsssubsub,sector,cta_Cliente,
			  ciudad,folio,sucursal,debitos_suc,creditos_suc,descripcion_det,
			  ccosto_dest,moneda,nDebitos_suc,nCreditos_suc, nDiferencia_suc,
			  nOrigen,currentuser)
  		select
  		fecha_valida,
  			(select sistema
  			from tbEnlaceSis ten
  			where
  			ten.ccmayor       = cod.ccmayor
  			and ten.ccsub         = cod.ccsub
  			and ten.ccsubsub      = cod.ccsubsub
  			and ten.ccssubsub     = cod.ccssubsub
  			and ten.ccsssubsub    = cod.ccsssubsub
  			and ten.sector        = cod.sector) sistema,
  		empresa, usuario,control_poliza,secuencia,
  		ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
  		--sector,'' cta_cliente, ciudad,'' folio, sucursal,
  		sector,'' cta_cliente, ciudad,'' folio, ccosto_orig,
  		decode(naturaleza,
  										'D', monto,
  										0),
  		decode(naturaleza,
  										'C', monto,
  										0),
  		descripcion,
  		--sucursal,
  		ccosto_orig,
  		moneda,
  		decode(naturaleza,
  										'D', 1,
  										0),
  		decode(naturaleza,
  										'C', 1,
  										0),
  		 0,
  		'1',pv_currentusr
  		from co_historico cod
  		WHERE length(trim(usuario)) = 4
        AND control_poliza IS NOT NULL
  		AND fecha_captura >= pd_fechaRep
        AND secuencia > 0
        AND empresa = pv_empresa
        AND ccmayor  like '95%'
        AND ccsub IS NOT NULL
        AND ccsubsub IS NOT NULL
        AND ccssubsub IS NOT NULL
        AND ccsssubsub IS NOT NULL
        AND sector IS NOT NULL
        AND ciudad IS NOT NULL
        AND sucursal IS NOT NULL
        AND nro_auxiliar IS NOT NULL
		AND fecha_valida = pd_fechaRep
        AND moneda IS NOT NULL ;
	END IF;

	DELETE FROM co_auditerr_cint WHERE ccmayor ='9512' AND ccsub NOT IN ('01','04','07','10');
    DELETE FROM co_auditerr_cint WHERE ccmayor ='9513' AND ccsub NOT IN ('10','11') ;
	DELETE FROM co_auditerr_cint WHERE ccmayor NOT IN ('9512','9513');

    DELETE FROM bdicont:co_auditerr_cint 
		  WHERE sucursal NOT IN (SELECT sucursal FROM bdinteg:si_sucursales 
						  				        WHERE tpo_sucursal='S' 
												  AND pais='001' 
												  AND estado!='0'
												  AND ciudad!='0');

	  LET lv_paso = 'Paso 5' ;
    insert into co_audconresum
    (fecha_proceso,sistema,empresa,ccmayor,cta_Cliente,ciudad,folio,
    sucursal,descripcion_det, moneda,nDiferencia,nDiferencia_suc,currentuser)
    select a.fecha_proceso,a.sistema,a.empresa,TRIM(a.ccmayor)||' '||TRIM(a.ccsub)||' '||TRIM(a.ccsubsub)||' '||
    TRIM(a.ccssubsub)||' '||TRIM(a.ccsssubsub)||' '||TRIM(a.sector) cuenta,a.cta_Cliente,' ',a.folio,
    a.sucursal,b.nombre,a.moneda,sum(nvl(a.creditos,0) - nvl(a.debitos,0)),sum(nvl(a.debitos_suc,0) - nvl(a.creditos_suc,0)),a.currentuser
    from co_auditerr_cint a, bdinteg:si_catalog b
    where currentuser = pv_currentusr
    AND a.empresa       = pv_empresa
    AND a.ccmayor       = b.ccmayor
  	and a.ccsub         = b.ccsub
  	and a.ccsubsub      = b.ccsubsub
  	and a.ccssubsub     = b.ccssubsub
  	and a.ccsssubsub    = b.ccsssubsub
  	and a.sector        = b.sector
    group by 1,2,3,4,5,7,8,9,10,13;

    DELETE
    FROM co_audconresum
    WHERE nDiferencia = nDiferencia_suc
    or sistema is null
    or sistema = '';

    --order by cuenta;
	  LET lv_paso = 'Paso 6' ;
--trace off;
   RETURN ln_err, lv_paso;
END PROCEDURE;