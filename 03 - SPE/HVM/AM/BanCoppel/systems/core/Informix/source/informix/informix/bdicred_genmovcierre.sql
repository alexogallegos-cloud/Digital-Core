CREATE PROCEDURE "informix".genmovcierre(
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


   INSERT INTO sd_movhis (
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

CREATE PROCEDURE "informix".sp_llena_ctescoppel_contdc(pempresa char(3))

RETURNING CHAR(6)
--Autor: Diana Castellanos, 24-08-2007
--Solicita: Juan A Coronel M
--SP para llenar tabla donde se lleva control de ctes coppel que ya tienen Tarj de Cred BanCoppel.
--Esta tabla será replicada a coppel para promoción de tarjeta de credito en cajas de tiendas coppel.
--Modifica: Juan A. Coronel, actualizar nombre de tabla donde se almacenan datos y validar null.

DEFINE sCod_Ret          CHAR(6);
DEFINE iSecuencia        INTEGER;
DEFINE cNumCte           CHAR(20);
DEFINE cNumCteCoppel     CHAR(20);
DEFINE vsqlerr           INTEGER;

LET sCod_Ret   = "000000";
LET iSecuencia = 0;
LET vsqlerr    = 0;
LET cNumCte    = "";
LET cNumCteCoppel = "";


BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RollBack Work;
      RETURN sCod_Ret;
   END IF;
END EXCEPTION;

    Begin Work;

    SELECT NVL(MAX(secuencia),0)+1 INTO iSecuencia FROM sd_clientescoppelcontdc;

    FOREACH
    Select distinct a.numcte, a.numcte_ref 
    Into cNumCte,cNumCteCoppel 
    From bdinteg:si_cliente a 
    Inner Join sd_maecred b On a.empresa = b.empresa and a.numcte = b.numcte
    Left Join sd_clientescoppelcontdc c On a.numcte = c.numcte
    Where a.empresa = pempresa
    and nvl(a.numcte_ref,0) > 0
    and c.numcte is null

        INSERT INTO sd_clientescoppelcontdc(secuencia, numcte, numctecoppel)
        VALUES(iSecuencia,cNumCte,cNumCteCoppel);

        LET iSecuencia = iSecuencia + 1;

    END FOREACH;

    Commit Work;
    RETURN scod_ret;
END;
END PROCEDURE;