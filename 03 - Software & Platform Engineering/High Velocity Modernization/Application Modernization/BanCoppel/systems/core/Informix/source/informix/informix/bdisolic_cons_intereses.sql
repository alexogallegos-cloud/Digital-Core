CREATE PROCEDURE "informix".cons_intereses(p_empresa            CHAR(3),
                                           pnum_credito         CHAR(20))

 RETURNING CHAR(20),CHAR(60),CHAR(45),CHAR(30),CHAR(40),
           CHAR(20),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),
           DECIMAL(18,2),DECIMAL(18,2),CHAR(3),CHAR(60);


-- **************************************************************************
--  variables
-- **************************************************************************
DEFINE cod_ret                       CHAR(5);
DEFINE sql_err                       INTEGER;
DEFINE isam_err                      INTEGER;
DEFINE error_info                    CHAR(40);
DEFINE v_numcte                      LIKE BDINTEG:SI_CLIENTE.NUMCTE;
DEFINE v_cliente                     LIKE BDINTEG:SI_CLIENTE.RAZON_SOCIAL;
DEFINE v_ejecut                      LIKE BDINTEG:SI_EJECUT.NOMBRE;
DEFINE v_divnom                      LIKE BDINTEG:SI_DIVISAS.DESCRIPCION;
DEFINE v_prodnom                     LIKE BDINTEG:SD_DEFINICION.NOMBRE_PROD;
DEFINE v_num_credito                 LIKE BDICRED:SD_MAECRED.NUM_CREDITO;
DEFINE v_credito                     LIKE BDICRED:SD_MAECRED.NUM_CREDITO;
DEFINE v_mto_finan_vdo               LIKE BDICRED:SD_MAESDOS.MTO_FINAN_VDO;
DEFINE v_sdo_no_exig                 LIKE BDICRED:SD_MAESDOS.SDO_NO_EXIG;
DEFINE v_sdo_exig_int                LIKE BDICRED:SD_MAESDOS.SDO_EXIG_INT;
DEFINE v_sdo_mora_ordi               LIKE BDICRED:SD_DETMORA.SDO_MORA_ORDI;
DEFINE v_sdo_mora_cope               LIKE BDICRED:SD_DETMORA.SDO_MORA_COPE; 
DEFINE v_mto_capitalizad             LIKE BDICRED:SD_MAESDOS.MTO_CAPITALIZADO;
DEFINE p_cod_ret                     CHAR(3);
DEFINE p_mensaje                     CHAR(60);

DEFINE i                             SMALLINT;  --NUMBER(6);
DEFINE text                          CHAR(100);
DEFINE v_apell_paterno               CHAR(15);
DEFINE v_apell_materno               CHAR(15);
DEFINE v_nombre1                     CHAR(15);
DEFINE v_nombre2                     CHAR(15);
DEFINE v_razon_social                CHAR(40);
DEFINE v_num_prod                    CHAR(4);
DEFINE v_monto_ven_tras              LIKE BDICRED:SD_MAESDOS.MTO_VENC_TRASP;


ON EXCEPTION SET sql_err, isam_err, error_info
   LET cod_ret = sql_err;
   SET DEBUG FILE TO "cons_intereses.err";
   TRACE sql_err||" * "||isam_err|| " * "||error_info;
   ROLLBACK WORK;
   RETURN v_numcte, v_cliente, v_ejecut, v_divnom, v_prodnom, v_num_credito,
          v_mto_finan_vdo, v_sdo_no_exig, v_sdo_exig_int, v_sdo_mora_ordi,
          v_sdo_mora_cope, cod_ret, p_mensaje;
END EXCEPTION;


-- **************************************************************************
-- verifica parametros de entrada
-- **************************************************************************

LET cod_ret                        = "000";
LET sql_err                        = 0;
LET isam_err                       = 0;
LET error_info                     = " ";
LET v_numcte                       = " ";
LET v_cliente                      = " ";
LET v_ejecut                       = " ";
LET v_divnom                       = " ";
LET v_prodnom                      = " ";
LET v_num_credito                  = " ";
LET v_credito                      = " ";
LET v_mto_finan_vdo                = 0;
LET v_sdo_no_exig                  = 0;
LET v_sdo_exig_int                 = 0;
LET v_sdo_mora_ordi                = 0;
LET v_sdo_mora_cope                = 0; 
LET p_cod_ret                      = "000";
LET p_mensaje                      = " ";
LET i                              = 0;  --NUMBER(6);
LET text                           = " ";
LET v_apell_paterno                = " ";
LET v_apell_materno                = " ";
LET v_nombre1                      = " ";
LET v_nombre2                      = " ";
LET v_razon_social                 = " ";
LET v_num_prod                     = " ";
LET v_monto_ven_tras               = 0;
LET v_mto_capitalizad              = 0;

--#####################################################################
--######            Inicio de Transaccion                         #####
--#####################################################################

IF pnum_credito IS NULL OR
   pnum_credito = ' ' THEN
      LET cod_ret = "223"; -- NUMERO DE CREDITO NULO O BLANCO
      RETURN v_numcte, v_cliente, v_ejecut, v_divnom, v_prodnom, v_num_credito,
             v_mto_finan_vdo, v_sdo_no_exig, v_sdo_exig_int, v_sdo_mora_ordi,
             v_sdo_mora_cope, cod_ret, p_mensaje;
      --GOTO FIN;
ELSE
      LET v_num_credito = pnum_credito;
END IF;

   SELECT num_credito,mto_capitalizado,monto_otorgado,provision_normal,
          sdo_exig_int

   INTO v_credito,v_mto_capitalizad,v_mto_finan_vdo,v_sdo_no_exig,
          v_sdo_exig_int

   FROM bdicred:sd_maesdos
   WHERE bdicred:sd_maesdos.empresa = p_empresa
   AND   bdicred:sd_maesdos.num_credito = v_num_credito;

   IF v_num_credito IS NULL OR v_num_credito = ' ' THEN
      LET cod_ret = "224"; -- NO EXISTE EL CREDITO
        RETURN v_numcte, v_cliente, v_ejecut, v_divnom, v_prodnom, v_num_credito,
               v_mto_finan_vdo, v_sdo_no_exig, v_sdo_exig_int, v_sdo_mora_ordi,
               v_sdo_mora_cope, cod_ret, p_mensaje;
      --GOTO FIN;
   END IF;


    SELECT si_cliente.numcte,apell_paterno,apell_materno,nombre1,
             nombre2,razon_social
    INTO v_numcte,v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,
           v_razon_social
    FROM bdicred:sd_maecred, bdinteg:si_cliente
    WHERE bdicred:sd_maecred.empresa     = p_empresa
    AND   bdicred:sd_maecred.num_credito = v_num_credito
    AND   bdicred:sd_maecred.empresa     = bdinteg:si_cliente.empresa
    AND   bdicred:sd_maecred.numcte      = bdinteg:si_cliente.numcte;

     IF v_razon_social IS NULL OR v_razon_social = ' ' THEN
         LET v_cliente = TRIM (v_nombre1) || ' ' || TRIM (v_nombre2);
         LET v_cliente = TRIM (v_cliente) || ' ' ||
                      TRIM (v_apell_paterno) || ' ' ||
                      TRIM (v_apell_materno);
     ELSE
         LET v_cliente = v_razon_social;
     END IF;


     SELECT nombre INTO v_ejecut
     FROM bdicred:sd_maecred, bdinteg:si_ejecut
     WHERE bdicred:sd_maecred.empresa     = p_empresa
     AND   bdicred:sd_maecred.num_credito = v_num_credito
     AND  bdicred:sd_maecred.empresa      = bdinteg:si_ejecut.empresa
     AND  bdicred:sd_maecred.ejecutivo    = bdinteg:si_ejecut.ejecutivo;

     IF v_ejecut IS NULL OR v_ejecut = ' ' THEN
        LET v_ejecut    = ' ';
     END IF;


        SELECT num_producto INTO v_num_prod
        FROM bdicred:sd_maecred
        WHERE bdicred:sd_maecred.empresa     = p_empresa
        AND  bdicred:sd_maecred.num_credito = v_num_credito;

        SELECT nombre_prod INTO v_prodnom
        FROM bdicred:sd_definicion
        WHERE bdicred:sd_definicion.empresa = p_empresa
        AND bdicred:sd_definicion.num_producto = v_num_prod;

        LET v_prodnom = TRIM (v_num_prod) || ' ' || TRIM (v_prodnom);
        IF v_prodnom IS NULL THEN
           LET v_prodnom = ' ';
        END IF;

        SELECT descripcion INTO v_divnom
        FROM bdicred:sd_maecred, bdinteg:si_divisas
        WHERE bdicred:sd_maecred.empresa     = p_empresa
        AND  bdicred:sd_maecred.num_credito = v_num_credito
        AND bdicred:sd_maecred.empresa     = bdinteg:si_divisas.empresa
        AND bdicred:sd_maecred.divisa      = bdinteg:si_divisas.divisa;


        IF v_mto_capitalizad IS NULL THEN
           LET v_mto_capitalizad = 0;
        END IF;

        IF v_mto_finan_vdo IS NULL THEN
           LET v_mto_finan_vdo = 0;
        END IF;

        IF v_sdo_no_exig IS NULL THEN
           LET v_sdo_no_exig = 0;
        END IF;

        IF v_sdo_exig_int IS NULL THEN
           LET v_sdo_exig_int = 0;
        END IF;


        SELECT SUM(sdo_mora_ordi) INTO v_sdo_mora_ordi
        FROM bdicred:sd_detmora
        WHERE bdicred:sd_detmora.empresa = p_empresa
        AND bdicred:sd_detmora.num_credito = v_num_credito;

        IF v_sdo_mora_ordi IS NULL THEN
           LET v_sdo_mora_ordi = 0;
        END IF;

        SELECT SUM(sdo_mora_cope) INTO v_sdo_mora_cope
        FROM bdicred:sd_detmora
        WHERE bdicred:sd_detmora.empresa = p_empresa
        AND bdicred:si_detmora.num_credito = v_num_credito;

        IF v_sdo_mora_cope IS NULL THEN
           LET v_sdo_mora_cope = 0;
        END IF;


        RETURN v_numcte, v_cliente, v_ejecut, v_divnom, v_prodnom, v_num_credito,
               v_mto_finan_vdo, v_sdo_no_exig, v_sdo_exig_int, v_sdo_mora_ordi,
               v_sdo_mora_cope, cod_ret, p_mensaje;


END PROCEDURE
