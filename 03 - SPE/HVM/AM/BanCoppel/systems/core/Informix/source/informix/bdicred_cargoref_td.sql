CREATE PROCEDURE "informix".cargoref_td
	(pTarjeta       CHAR(16),
	 pSucursal      CHAR(4),
         pUsuario       CHAR(8),
         pNumTran       CHAR(4),
         pNumTranS      CHAR(4),
         pFolio         CHAR(16),
         pNumCredito    CHAR(20),
	 pDocumento     INTEGER,
         pMonto         MONEY(16,2),
	 pMonto2        MONEY(16,2),
         pDivisa        CHAR(2),
         pReferencia    CHAR(40),
         pComSucursal   CHAR(4),
         pComUsuario    CHAR(8),
         pComNumTran    CHAR(4),
         pComNumTranS   CHAR(4),
         pComFolio      CHAR(16),
         pComNumCredito CHAR(20),
         pComDocumento  INTEGER,
         pComMonto      MONEY(16,2),
         pComDivisa     CHAR(2),
         pComReferencia CHAR(40),
	 pComBandera    CHAR(1),
	 pSurNumTran    CHAR(4),
         pSurNumTranS   CHAR(4),
         pSurFolio      CHAR(16),
         pSurDocumento  INTEGER,
         pSurMonto      MONEY(16,2),
         pSurDivisa     CHAR(2),
         pSurReferencia CHAR(40))

   RETURNING CHAR(5),      -- Codigo de Retorno
             CHAR(4),      -- Transaccion
             DATE,         -- Fecha Aplicacion
             MONEY(16,2),  -- Saldo Disponible
             MONEY(16,2),  -- Importe Cargado
             CHAR(5),      -- Codigo de Retorno Comision
             CHAR(4),      -- Transaccion Comision
             DATE,         -- Fecha Aplicacion Comision
             MONEY(16,2),  -- Saldo Disponible Comision
             MONEY(16,2);  -- Importe Cargado ComisioN

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE cod_ret2            CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);

   DEFINE NumProducto         CHAR(4);
   DEFINE StatusCred          CHAR(2);
   DEFINE Saldo               MONEY(16,2);
   DEFINE SaldoCom            MONEY(16,2);
   DEFINE ManejaLinea         CHAR(1);
   DEFINE MontoOtorgado       MONEY(16,2);
   DEFINE CodigoRef           INTEGER;
   DEFINE CodigoFun           CHAR(3);
   DEFINE wEmpresa            CHAR(3);
   DEFINE wSucursal           CHAR(4);
   DEFINE wDivisa             CHAR(2);
   DEFINE FechaHoy            DATE;
   DEFINE pForzado            CHAR(1);
   DEFINE wBegin              CHAR(1);
   DEFINE vusuario            char(8);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END EXCEPTION;



  SET LOCK MODE TO WAIT 10;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET wBegin = "N";
   LET vusuario = USER;

   LET cod_ret = "000";
   LET CodigoFun = "002";
   LET MontoOtorgado = 0;

   IF pNumTranS = "9999" THEN --- Retiro de Tarjeta por ventanilla
      LET Codigoref = 6;
      LET pForzado = "N";
   ELSE
      IF pNumTran[1,1] = "1" THEN
         LET Codigoref = 7;
      ELSE
         LET Codigoref = 8;
      END IF

      IF(pNumTran[4,4] = "1") THEN
         LET pForzado = "S";
      ELSE
         LET pForzado = "N";
      END IF;
   END IF

   LET FechaHoy = NULL;
   SELECT a.empresa, a.sucursal, a.divisa, a.num_producto, a.status_cred,
      	  b.monto_otorgado - b.sdo_cap_insoluto, c.maneja_linea
     INTO wEmpresa, wSucursal, wDivisa, NumProducto, StatusCred,
          Saldo, ManejaLinea
     FROM sd_maecred a, sd_maesdos b, sd_definicion c
    WHERE a.num_credito = pNumCredito 
      AND a.empresa = "001"
      AND b.num_credito = a.num_credito 
      AND a.empresa = b.empresa
      AND c.num_producto = a.num_producto;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET Saldo = 0;
      IF pNumTranS = "9999" then
      	LET cod_ret = "100";
      ELSE
      	LET cod_ret = "008";
      END IF
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

   IF(ManejaLinea <> "S") THEN
      LET cod_ret = "206";
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

   IF (Saldo <= 0 AND pForzado <> "S") THEN
      LET cod_ret = "202";
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

   IF (pMonto > Saldo AND pForzado <> "S") THEN
      IF pNumTranS = "9999" then
      	LET cod_ret = "700";
      ELSE
      	LET cod_ret = "203";
      END IF
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

   IF(pMonto > Saldo) THEN
      LET MontoOtorgado = pMonto - Saldo;
   END IF;

   UPDATE sd_maesdos
      SET sdo_capital = sdo_capital + pMonto,
          sdo_cap_insoluto = sdo_cap_insoluto + pMonto,
          mto_ministra_cap = mto_ministra_cap + pMonto,
          cargos_mes_cap   = cargos_mes_cap + pmonto
    WHERE num_credito = pNumCredito
      AND empresa = wEmpresa;

   SELECT fecha_hoy 
     INTO FechaHoy
     FROM sd_fechas
    WHERE empresa = wEmpresa;

   CALL genmov(wEmpresa, pNumCredito, NumProducto,
               CodigoRef, CodigoFun, FechaHoy,
               pMonto, pFolio, wSucursal, wDivisa, pNumTran)
      RETURNING cod_ret, mensaje;

   LET Saldo = Saldo - pMonto + MontoOtorgado;
   RETURN cod_ret, pNumTran, FechaHoy, Saldo, pMonto,
	     cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;

END PROCEDURE
DOCUMENT
'Esta funcion realiza el cargo a una tarjeta de credito  ',
'AUTOR : Raul Mendoza',
'FECHA : 8/10/2003',
'MODIFICADO : Antonio Ruiz Martinez',
'FECHA : 29/12/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';

CREATE PROCEDURE "informix".genmovi_tc(
   p_empresa                VARCHAR(3),
   p_num_credito            VARCHAR(20),
   p_num_producto           VARCHAR(4),
   p_codigo_ref             INTEGER,
   p_codigo_fun             VARCHAR(3),
   p_fecha_hoy              DATE,
   p_monto                  MONEY(14,2),
   p_foliosuc               VARCHAR(16),
   p_sucursal               VARCHAR(4),
   p_divisa                 VARCHAR(2),
   p_transacc_suc           VARCHAR(4),
   p_tarjeta                VARCHAR(20),
   p_referencia             VARCHAR(40),
   p_tipo_cambio            DECIMAL(14,6),
   p_monto_dls              DECIMAL(14,2))

RETURNING VARCHAR(10), VARCHAR(80);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE   v_plaza         VARCHAR(3);
DEFINE   v_hora          DATETIME HOUR TO FRACTION(3);
DEFINE   vm_secuencia    INTEGER;
DEFINE   v_reversado     VARCHAR(1);
DEFINE   v_usuario       VARCHAR(8);

DEFINE   v_num_producto  VARCHAR(4);
DEFINE   v_codigo_ref    INTEGER;
DEFINE   v_codigo_fun    VARCHAR(3);
DEFINE   v_fecha_hoy     DATE;
DEFINE   v_monto         DECIMAL(18,2);
DEFINE   v_foliosuc      VARCHAR(16);
DEFINE   v_sucursal      VARCHAR(4);
DEFINE   v_divisa        VARCHAR(2);
DEFINE   v_transacc_suc  VARCHAR(4);

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vcadena     INTEGER;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET      = '00000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';
   LET v_num_producto =  p_num_producto ;
   LET v_codigo_ref   =  p_codigo_ref   ;
   LET v_codigo_fun   =  p_codigo_fun   ;
   LET v_fecha_hoy    =  p_fecha_hoy    ;
   LET v_monto        =  p_monto        ;
   LET v_foliosuc     =  p_foliosuc     ;
   LET v_sucursal     =  p_sucursal     ;
   LET v_divisa       =  p_divisa       ;
   LET v_transacc_suc =  p_transacc_suc ;

   IF (p_transacc_suc IS NULL) THEN
      LET v_transacc_suc = '0000';
   END IF;

   IF (v_fecha_hoy IS NULL) THEN
      SELECT fecha_hoy
      INTO   v_fecha_hoy
      FROM   sd_fechas;
   END IF;
   IF (v_monto IS NULL) THEN
      LET v_monto = 0;
   END IF;
   IF (v_divisa IS NULL) THEN
      LET v_divisa = '00';
   END IF;
   IF (v_num_producto IS NULL) THEN
      LET v_num_producto = '    ';
   END IF;

   IF (v_foliosuc IS NULL) THEN
      LET p_cod_ret = '110';
      LET P_MENSAJE = 'ERROR';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   LET p_cod_ret    = '00000';
   LET P_MENSAJE    = 'PROCESO EXITOSO';
   LET v_hora       = EXTEND(CURRENT,HOUR TO fraction(3));

   LET v_reversado  = 'N';
--   v_usuario    := USER;


   LET vcadena = 0;

   let vcadena = length(p_foliosuc) - 8;
   LET v_usuario    = substr(p_foliosuc,1,vcadena);

--   LET v_usuario    = substr(v_foliosuc,1,8);

   --############################################################
   --####  GENERACION DE MOVIMIENTOS Y DETALLE CONTABLE     #####
   --############################################################

   SELECT plaza
   INTO   v_plaza
   FROM   bdinteg:si_sucursales
   WHERE  empresa  = p_empresa
   AND    sucursal = v_sucursal;

   IF V_PLAZA IS NULL OR V_PLAZA = '' THEN
      LET P_COD_RET = '00100';
      LET P_MENSAJE = 'LA INFORMACION PLAZA/SUCURSAL DEL CREDITO ES INCORRECTA';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   INSERT INTO sd_movdia (
               EMPRESA        ,
               FECHA_MOV      ,
               HORA_MOV       ,
               SUCURSAL       ,
               NUM_CREDITO    ,
               PLAZA          ,
               TRANSACC_SUC   ,
               USUARIO        ,
               MONTO          ,
               CODIGO_FUN     ,
               CODIGO_REF     ,
               DIVISA         ,
               REVERSADO      ,
               FOLIO_SUC      ,
               NUM_PRODUCTO   ,
	       NRO_TARJETA    ,
	       REFERENCIA     ,
               TIPO_CAMBIO    ,
	       MONTO_DLS      )
      VALUES ( p_empresa,
               v_fecha_hoy,
               current,
               v_sucursal,
               p_num_credito,
               v_plaza,
               v_transacc_suc,
               v_usuario,
               v_monto,
               v_codigo_fun,
               v_codigo_ref,
               v_divisa,
               v_reversado,
               v_foliosuc,
               v_num_producto,
	       p_tarjeta,
	       p_referencia,
	       p_tipo_cambio,
	       p_monto_dls);

   RETURN P_COD_RET, P_MENSAJE;

END;
END PROCEDURE;