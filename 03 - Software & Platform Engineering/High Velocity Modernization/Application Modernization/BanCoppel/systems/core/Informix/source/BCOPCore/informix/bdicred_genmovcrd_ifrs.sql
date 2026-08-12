CREATE PROCEDURE "informix".genmovcrd_ifrs(
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
   p_Referencia             VARCHAR(40),
   p_Referencia23           VARCHAR(23,1))          

RETURNING VARCHAR(6), VARCHAR(80);

DEFINE   p_cod_ret       VARCHAR(6);
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
DEFINE vSucOri     CHAR(4);

--  Autor: Paul Ivan Quintero Varela
--  Fecha: 15/10/2009
--  Observaciones:  Se modifica para contemplar el retorno del procedimiento 
--                           de 6 posiciones.

--  Autor: Roque Enrique Solis
--  Fecha: 27/10/2009
--  Observaciones:  Se agrego el parÃ¡metro para recibir la referencia del movimiento.

--  Autor: Paul Ivan Quintero Varela
--  Fecha: 18/11/2009
--  Observaciones:  Se agrega el parÃ¡metro para recibir la referencia23 en el caso de SBC e INTERACT.

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET      = '000000';
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

   IF NVL(p_transacc_suc,'') = '' THEN
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
   
   IF NVL(v_foliosuc,'') = '' THEN
      LET p_cod_ret = '000110';
      LET P_MENSAJE = 'ERROR';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   LET p_cod_ret    = '000000';
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
      LET P_COD_RET = '000100';
      LET P_MENSAJE = 'LA INFORMACION PLAZA/SUCURSAL DEL CREDITO ES INCORRECTA';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   SELECT sucursal, divisa, num_producto  
     INTO vSucOri, v_divisa, v_num_producto
     FROM "informix".sd_maecredcrd
    WHERE empresa = p_empresa
      AND num_credito = p_num_credito;
	  
	  IF NVL(v_divisa,'') = '' THEN
        LET v_divisa = '00';
      END IF;
   
	  IF NVL(v_num_producto,'') = '' THEN
	     LET v_num_producto = '    ';
	  END IF;

   INSERT INTO "informix".sd_movdiacrd_ifrs (EMPRESA        ,
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
                                        REFERENCIA     ,
                                        SUC_ORIGEN     ,
                                        REFERENCIA23   )
      VALUES ( p_empresa,
               v_fecha_hoy,
               CURRENT,
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
			   p_Referencia,
	           vSucOri,
               p_Referencia23);

   RETURN P_COD_RET, P_MENSAJE;

END;
END PROCEDURE;