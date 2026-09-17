CREATE PROCEDURE "informix".cons_datgrales(p_empresa          CHAR(2),
                                           p_num_credito      CHAR(20))

  RETURNING CHAR(20),CHAR(60),CHAR(45),CHAR(30),CHAR(40),
            CHAR(20),DATE,DATE,CHAR(25),CHAR(60),
            DECIMAL(9,6),DECIMAL(9,3),CHAR(60),
            CHAR(60),CHAR(60),CHAR(60),CHAR(60),
            CHAR(5),CHAR(60);

-- **************************************************************************
--  variables
-- **************************************************************************
DEFINE cod_ret                       CHAR(5);
DEFINE sql_err                       INTEGER;
DEFINE isam_err                      INTEGER;
DEFINE error_info                    CHAR(40);
DEFINE P_NUM_CTE                     LIKE bdicred:sd_maecred.numcte;
DEFINE P_CLIENTE                     LIKE bdinteg:si_cliente.razon_social;
DEFINE P_NOMBRE                      LIKE bdinteg:si_ejecut.nombre;
DEFINE P_DIVISAS                     LIKE bdinteg:si_divisas.descripcion;
DEFINE P_PRODUCTO                    LIKE bdicred:sd_definicion.nombre_prod;
DEFINE PP_NUM_CREDITO                LIKE bdicred:sd_maecred.num_credito;
DEFINE P_FECHA_APERTURA              LIKE bdicred:sd_maecred.fecha_apertura;
DEFINE P_FECHA_VENCIM                LIKE bdicred:sd_maecred.fecha_vencim;
DEFINE P_LINCONCEP                   LIKE bdicred:sd_lineas.descrip_linea;
DEFINE P_PERPLAZO                    LIKE bdinteg:si_cliente.razon_social;
DEFINE P_PORC_REC_PROP               LIKE bdicred:sd_maecred.porc_rec_prop;
DEFINE P_SUPERFICIE                  LIKE bdicred:sd_maecred.superficie;
DEFINE P_NOMBRE_STAT_CRED            LIKE bdicred:sd_tipocartera.descripcion;
DEFINE P_CICLO                       LIKE bdinteg:si_cliente.razon_social;
DEFINE P_PRODUCTOR                   LIKE bdinteg:si_cliente.razon_social;
DEFINE P_CARACTERIS                  LIKE bdinteg:si_cliente.razon_social;
DEFINE P_TIPOCALCULO                 LIKE bdicred:sd_tipocalculo.desc_tipo_calculo;
DEFINE P_COD_RET                     CHAR(2);
DEFINE P_MENSAJE                     CHAR(60);
DEFINE i                             SMALLINT;    ---NUMBER;
DEFINE text                          CHAR(100);
DEFINE v_apell_paterno               CHAR(15);
DEFINE v_apell_materno               CHAR(15);
DEFINE v_nombre1                     CHAR(15);
DEFINE v_nombre2                     CHAR(15);
DEFINE v_razon_social                CHAR(40);
DEFINE v_cliente                     CHAR(60);
DEFINE v_num_credito                 LIKE bdicred:sd_maecred.num_credito;
DEFINE v_fecha_apertura              LIKE bdicred:sd_maecred.fecha_apertura;
DEFINE v_fecha_vencim                LIKE bdicred:sd_maecred.fecha_vencim;
DEFINE v_numcte                      LIKE bdicred:sd_maecred.numcte;
DEFINE v_num_cte                     LIKE bdicred:sd_maecred.numcte;
DEFINE v_cod_prod                    LIKE bdicred:sd_maecred.cod_prod;
DEFINE v_num_producto                LIKE bdicred:sd_maecred.num_producto;
DEFINE v_producto                    LIKE bdicred:sd_definicion.nombre_prod;
DEFINE v_cod_linea                   LIKE bdicred:sd_maecred.cod_linea;
DEFINE v_divisa                      LIKE bdicred:sd_maecred.divisa;
DEFINE v_porc_rec_prop               LIKE bdicred:sd_maecred.porc_rec_prop;
DEFINE v_superficie                  LIKE bdicred:sd_maecred.superficie;
DEFINE v_status_cred                 LIKE bdicred:sd_maecred.status_cred;
DEFINE v_cod_agricola                LIKE bdicred:sd_maecred.cod_agricola;
DEFINE v_tipo_calculo                LIKE bdicred:sd_tipocalculo.tipo_calculo;
DEFINE v_nombre_stat_cred            LIKE bdicred:sd_tipocartera.descripcion;
DEFINE v_linea                       LIKE bdicred:sd_lineas.descrip_linea;
DEFINE v_linconcep                   LIKE bdicred:sd_lineas.descrip_linea;
DEFINE v_divisas                     LIKE bdinteg:si_divisas.descripcion;
DEFINE v_codigo_ins                  LIKE bdicred:sd_institu.codigo_ins;
DEFINE v_ciclo                       LIKE bdicred:sd_ciclosag.DESCRIP_AGRICOLA;
DEFINE v_productor                   CHAR(40);
DEFINE v_caracteris                  CHAR(40);
DEFINE v_tipocalculo                 LIKE bdicred:sd_tipocalculo.desc_tipo_calculo;
DEFINE v_periodo_plazo               LIKE bdicred:sd_definicion.periodo_plazo;
DEFINE v_plazo                       CHAR(6);
DEFINE v_perplazo1                   CHAR(5);
DEFINE v_perplazo                    CHAR(20);
DEFINE v_ejecutivo                   LIKE bdicred:sd_maecred.ejecutivo;
DEFINE vv_nombre                     LIKE bdinteg:si_ejecut.nombre;
DEFINE vvv_nombre                    LIKE bdinteg:si_ejecut.nombre;
DEFINE v_cod_tipo_linea	             LIKE bdicred:sd_maecred.COD_TIPO_LINEA;
DEFINE v_actividad	             LIKE bdicred:sd_maecred.ACTIVIDAD;
DEFINE v_codigo_pro		     LIKE bdicred:sd_maecred.CODIGO_PRO;
DEFINE v_descrip_agricola	     LIKE bdicred:sd_ciclosag.DESCRIP_AGRICOLA;
DEFINE v_tasa_interes		     LIKE bdicred:sd_maecred.TASA_INTERES;
DEFINE v_tasa_moratorios             LIKE bdicred:sd_maecred.TASA_MORATORIOS;


ON EXCEPTION SET sql_err, isam_err, error_info
   LET cod_ret = sql_err;
   SET DEBUG FILE TO "cons_capitales.err";
   TRACE sql_err||" * "||isam_err|| " * "||error_info;
   ROLLBACK WORK;
   RETURN P_NUM_CTE, P_CLIENTE, P_NOMBRE, P_DIVISAS, P_PRODUCTO,
          PP_NUM_CREDITO, P_FECHA_APERTURA, P_FECHA_VENCIM, P_LINCONCEP,
          P_PERPLAZO, P_PORC_REC_PROP, P_SUPERFICIE, P_NOMBRE_STAT_CRED,
          P_CICLO, P_PRODUCTOR, P_CARACTERIS, P_TIPOCALCULO, cod_ret,
          P_MENSAJE;
END EXCEPTION;


-- **************************************************************************
-- verifica parametros de entrada
-- **************************************************************************

LET cod_ret                        = "000";
LET sql_err                        = 0;
LET isam_err                       = 0;
LET error_info                     = " ";
LET P_NUM_CTE                      = " ";
LET P_CLIENTE                      = " ";
LET P_NOMBRE                       = " ";
LET P_DIVISAS                      = " ";
LET P_PRODUCTO                     = " ";
LET PP_NUM_CREDITO                 = " ";
LET P_FECHA_APERTURA               = " ";
LET P_FECHA_VENCIM                 = " ";
LET P_LINCONCEP                    = " ";
LET P_PERPLAZO                     = " ";
LET P_PORC_REC_PROP                = " ";
LET P_SUPERFICIE                   = 0;
LET P_NOMBRE_STAT_CRED             = " ";
LET P_CICLO                        = " ";
LET P_PRODUCTOR                    = " ";
LET P_CARACTERIS                   = " ";
LET P_TIPOCALCULO                  = " ";
LET P_COD_RET                      =" ";
LET P_MENSAJE                      =" ";
LET i                              = 0;    ---NUMBER;
LET text                           =" ";
LET v_apell_paterno                =" ";
LET v_apell_materno                =" ";
LET v_nombre1                      =" ";
LET v_nombre2                      =" ";
LET v_razon_social                 =" ";
LET v_cliente                      =" ";
LET v_num_credito                  = " ";
LET v_fecha_apertura               = " ";
LET v_fecha_vencim                 = " ";
LET v_numcte                       = " ";
LET v_num_cte                      = " ";
LET v_cod_prod                     = " ";
LET v_num_producto                 = " ";
LET v_producto                     = " ";
LET v_cod_linea                    = " ";
LET v_divisa                       = " ";
LET v_porc_rec_prop                = 0;
LET v_superficie                   = 0;
LET v_status_cred                  = " ";
LET v_cod_agricola                 = " ";
LET v_tipo_calculo                 = " ";
LET v_nombre_stat_cred             = " ";
LET v_linea                        = " ";
LET v_linconcep                    = " ";
LET v_divisas                      = " ";
LET v_codigo_ins                   = " ";
LET v_ciclo                        = " ";
LET v_productor                    = " ";
LET v_caracteris                   = " ";
LET v_tipocalculo                  = " ";
LET v_periodo_plazo                = " ";
LET v_plazo                        = " ";
LET v_perplazo1                    = " ";
LET v_perplazo                     = " ";
LET v_ejecutivo                    = " ";
LET vv_nombre                      = " ";
LET vvv_nombre                     = " ";
LET v_cod_tipo_linea	           = " ";
LET v_actividad	                   = " ";
LET v_codigo_pro		   = " ";
LET v_descrip_agricola	           = " ";
LET v_tasa_interes		   = " ";
LET v_tasa_moratorios              = " ";


 --#####################################################################
 --######            Inicio de Transaccion                         #####
--#####################################################################

IF p_num_credito IS NULL OR
   p_num_credito = ' ' THEN
     LET cod_ret = '223'; -- NUMERO DE CREDITO NULO O BLANCO
     --GOTO FIN;
     RETURN P_NUM_CTE, P_CLIENTE, P_NOMBRE, P_DIVISAS, P_PRODUCTO,
            PP_NUM_CREDITO, P_FECHA_APERTURA, P_FECHA_VENCIM, P_LINCONCEP,
            P_PERPLAZO, P_PORC_REC_PROP, P_SUPERFICIE, P_NOMBRE_STAT_CRED,
            P_CICLO, P_PRODUCTOR, P_CARACTERIS, P_TIPOCALCULO, cod_ret,
            P_MENSAJE;
ELSE
    LET v_num_credito = p_num_credito;
END IF;

  SELECT num_credito, fecha_apertura, fecha_vencim, numcte, num_producto, cod_linea,
         divisa, plazo, porc_rec_prop, superficie, status_cred, cod_agricola, cod_prod,
         tipo_calculo, ejecutivo, cod_tipo_linea, actividad, codigo_pro, cod_tasa_base,
	 cod_tasa_mora, tasa_interes, tasa_moratorios
  INTO v_num_credito, v_fecha_apertura, v_fecha_vencim, v_num_cte, v_num_producto, v_cod_linea,
       v_divisa, v_plazo, v_porc_rec_prop, v_superficie, v_status_cred, v_cod_agricola, v_cod_prod,
       v_tipo_calculo, v_ejecutivo, v_cod_tipo_linea, v_actividad, v_codigo_pro, v_productor,
       v_caracteris, v_tasa_interes, v_tasa_moratorios
  FROM bdicred:sd_maecred
  WHERE bdicred:sd_maecred.num_credito = v_num_credito
  AND bdicred:sd_maecred.empresa = p_empresa;

   IF v_num_credito IS NULL OR v_num_credito = '' THEN
       LET cod_ret = '224'; -- NO EXISTE EL CREDITO
       --GOTO FIN;
       RETURN P_NUM_CTE, P_CLIENTE, P_NOMBRE, P_DIVISAS, P_PRODUCTO,
              PP_NUM_CREDITO, P_FECHA_APERTURA, P_FECHA_VENCIM, P_LINCONCEP,
              P_PERPLAZO, P_PORC_REC_PROP, P_SUPERFICIE, P_NOMBRE_STAT_CRED,
              P_CICLO, P_PRODUCTOR, P_CARACTERIS, P_TIPOCALCULO, cod_ret,
              P_MENSAJE;
   END IF;

   IF v_fecha_apertura IS NULL OR v_fecha_apertura = '' THEN
       LET v_fecha_apertura = '';
   END IF;

   IF v_fecha_vencim IS NULL OR v_fecha_vencim = '' THEN
       LET v_fecha_vencim = '';
   END IF;

   IF v_plazo IS NULL OR v_plazo = '' THEN
       LET v_plazo = '';
   END IF;

   IF v_porc_rec_prop IS NULL OR  v_porc_rec_prop = '' THEN
       LET v_porc_rec_prop = '';
   END IF;

   IF v_superficie IS NULL OR v_superficie = '' THEN
       LET v_superficie = 0;
   END IF;

   IF v_ejecutivo IS NULL then
      LET v_ejecutivo = '';
   END IF;

   IF v_num_cte IS NULL OR v_num_cte = '' THEN
      LET v_num_cte = '';
   ELSE
      SELECT numcte,
       	     apell_paterno,
       	     apell_materno,
       	     nombre1,
       	     nombre2,
       	     razon_social
      INTO   v_numcte,
       	     v_apell_paterno,
       	     v_apell_materno,
       	     v_nombre1,
       	     v_nombre2,
             v_razon_social
      FROM bdinteg:si_cliente
      WHERE bdinteg:si_cliente.numcte = v_num_cte;
      IF v_razon_social IS NULL OR v_razon_social = ' ' THEN
         LET v_cliente = TRIM(v_nombre1) ||' '||TRIM (v_nombre2);
         LET v_cliente = TRIM(v_cliente) ||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
      ELSE
         LET v_cliente = v_razon_social;
      END IF;
   END IF;

   SELECT nombre_prod, periodo_plazo
   INTO v_producto, v_periodo_plazo
   FROM bdicred:sd_definicion
   WHERE bdicred:sd_definicion.num_producto = v_num_producto;

   LET v_producto = TRIM(v_num_producto)||' '||TRIM(v_producto);

   IF v_producto IS NULL OR v_producto = '' THEN
      LET v_producto = '';
   END IF;

   IF v_periodo_plazo IS NULL OR v_periodo_plazo = '' THEN
      LET v_perplazo = '';
   END IF;
   IF v_periodo_plazo = 'D' THEN
       LET v_perplazo1 = 'DIAS';
       LET v_perplazo = TRIM(v_plazo)||' '||TRIM(v_perplazo1);
   END IF;
   IF v_periodo_plazo = 'M' THEN
       LET v_perplazo1 = 'MESES';
       LET v_perplazo = TRIM(v_plazo)||' '||TRIM(v_perplazo1);
   END IF;

   IF v_periodo_plazo = 'A' THEN
       LET v_perplazo1 = 'A1';
       LET v_perplazo = TRIM(v_plazo)||' '||TRIM(v_perplazo1);
   END IF;

   SELECT descrip_linea
   INTO v_linea
   FROM bdicred:sd_lineas
   WHERE bdicred:sd_lineas.cod_linea = v_cod_linea
   and bdicred:sd_lineas.cod_tipo_linea = v_cod_tipo_linea;
   --and actividad = v_actividad;

   IF v_linea IS NULL OR v_linea = '' THEN
      LET v_linea = '';
   END IF;

   LET v_linconcep = v_linea;


   --ciclos agricolas
   SELECT descrip_agricola
   INTO v_descrip_agricola
   FROM bdicred:sd_ciclosag
   WHERE bdicred:sd_ciclosag.empresa = p_empresa
   AND bdicred:sd_ciclosag.cod_agricola = v_cod_agricola;

   IF v_descrip_agricola IS NULL OR v_descrip_agricola = '' THEN
      LET v_descrip_agricola = '';
   END IF;

   SELECT descripcion
   INTO v_divisas
   FROM bdinteg:si_divisas
   WHERE bdinteg:si_divisas.divisa = v_divisa;

   IF v_divisas IS NULL OR v_divisas = '' THEN
      LET v_divisas = '';
   END IF;

   SELECT descripcion
   INTO v_nombre_stat_cred
   FROM bdicred:sd_tipocartera
   WHERE bdicred:sd_tipocartera.status_cred = v_status_cred;

   IF v_nombre_stat_cred IS NULL OR v_nombre_stat_cred = '' THEN
     LET v_nombre_stat_cred = '';
   END IF;

   LET v_ciclo = v_descrip_agricola;

   LET v_productor = v_productor ||' '|| v_tasa_interes;

   LET v_caracteris = v_caracteris ||' '|| v_tasa_moratorios;

   SELECT desc_tipo_calculo
   INTO v_tipocalculo
   FROM bdicred:sd_tipocalculo
   WHERE bdicred:sd_tipocalculo.tipo_calculo = v_tipo_calculo;

   IF v_tipocalculo IS NULL OR v_tipocalculo = '' THEN
      LET v_tipocalculo = '';
   END IF;

   SELECT nombre
   INTO vvv_nombre
   FROM bdinteg:si_ejecut
   WHERE bdinteg:si_ejecut.ejecutivo = v_ejecutivo;

   IF vvv_nombre IS NULL THEN
      LET vvv_nombre = '';
   END IF;

   LET P_COD_RET          =cod_ret;
   LET P_NUM_CTE          =v_num_cte;
   LET P_CLIENTE          =v_cliente;
   LET P_NOMBRE           =vvv_nombre;
   LET P_DIVISAS          =v_divisas;
   LET P_PRODUCTO         =v_producto;
   LET pp_NUM_CREDITO      =v_num_credito;
   LET P_FECHA_APERTURA   =v_fecha_apertura;
   LET P_FECHA_VENCIM     =v_fecha_vencim;
   LET P_LINCONCEP        =v_linconcep;
   LET P_PERPLAZO         =v_perplazo;
   LET P_PORC_REC_PROP    =v_porc_rec_prop;
   LET P_SUPERFICIE       =v_superficie;
   LET P_NOMBRE_STAT_CRED =v_nombre_stat_cred;
   LET P_CICLO            =v_ciclo;
   LET P_PRODUCTOR        =v_productor;
   LET P_CARACTERIS       =v_caracteris;
   LET P_TIPOCALCULO      =v_tipocalculo;

   RETURN P_NUM_CTE, P_CLIENTE, P_NOMBRE, P_DIVISAS, P_PRODUCTO,
          PP_NUM_CREDITO, P_FECHA_APERTURA, P_FECHA_VENCIM, P_LINCONCEP,
          P_PERPLAZO, P_PORC_REC_PROP, P_SUPERFICIE, P_NOMBRE_STAT_CRED,
          P_CICLO, P_PRODUCTOR, P_CARACTERIS, P_TIPOCALCULO, cod_ret,
          P_MENSAJE;

END PROCEDURE
