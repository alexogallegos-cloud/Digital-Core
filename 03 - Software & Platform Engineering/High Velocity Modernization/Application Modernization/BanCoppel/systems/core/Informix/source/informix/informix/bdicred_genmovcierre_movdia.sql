CREATE PROCEDURE "informix".genmovcierre_movdia(
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
   p_plaza		    VARCHAR(3))
RETURNING VARCHAR(10), VARCHAR(80);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE   v_hora          DATETIME HOUR TO FRACTION(3);
DEFINE   vm_secuencia    INTEGER;
DEFINE   v_usuario       VARCHAR(8);


DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vcadena     INTEGER;
DEFINE vSucOri     CHAR(4);

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET      = '00000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';

   IF (p_monto IS NULL) THEN
      LET p_monto = 0;
   END IF;

   LET p_cod_ret    = '00000';
   LET P_MENSAJE    = 'PROCESO EXITOSO';
   LET v_hora       = EXTEND(CURRENT,HOUR TO fraction(3));

   LET v_usuario    = USER;

   --############################################################
   --####  GENERACION DE MOVIMIENTOS Y DETALLE CONTABLE     #####
   --############################################################


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
	       SUC_ORIGEN     )
      VALUES ( p_empresa,
               p_fecha_hoy,
               current,
               p_sucursal,
               p_num_credito,
               p_plaza,
               p_transacc_suc,
               v_usuario,
               p_monto,
               p_codigo_fun,
               p_codigo_ref,
               p_divisa,
               "N",
               p_foliosuc,
               p_num_producto,
	       p_sucursal);

   RETURN P_COD_RET, P_MENSAJE;

END;
END PROCEDURE
DOCUMENT           
'Procedimiento para la insercion de los movmientos que',
'son generdos por el cierre        ',
'AUTOR : Antonio Ruiz',
'FECHA : 19/Octubre/2007',   
'VERSION: 1.00.000',
'BD    : BDICRED' ;

CREATE PROCEDURE "informix".sp_actualiza_fecha(pfecha date)
RETURNING char(6);


DEFINE scod_ret               CHAR(5);
DEFINE vsqlerr                INTEGER;
DEFINE ccredito             CHAR(20);
DEFINE ccontador              INTEGER;

LET scod_ret     = "000";
LET vsqlerr      = 0;
LET ccontador    = 1;


BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

  FOREACH WITH HOLD 
         select num_credito 
         into ccredito
         from bdicred:sd_sdodiario 

        IF ccontador=1 then
          BEGIN WORK;
        END IF;
         
         update bdicred:sd_sdodiario set fecha = mdy(month(today),'01',year(today)) where fecha=today and num_credito=ccredito;

         IF ccontador>=70000 THEN
            COMMIT WORK;
            ---update statistics medium for table bdiburo:br_traslado;
            LET ccontador=1;
         ELSE
            LET ccontador=ccontador+1;
         END IF;

    END FOREACH; 

  IF ccontador > 1 THEN
        COMMIT WORK; 
  END IF;

    LET ccontador = 1;

RETURN scod_ret;
END
END PROCEDURE;