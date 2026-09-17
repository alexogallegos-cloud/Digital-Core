CREATE PROCEDURE "informix".consnomb1( ppaterno   LIKE si_cliente.apell_paterno,
                             pmaterno   LIKE si_cliente.apell_materno,
                             prazon     LIKE si_cliente.razon_social,
                             psecuencia INTEGER)
   RETURNING CHAR(60), CHAR(20), CHAR(5), CHAR(80);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_nombre_completo   CHAR(60);
   DEFINE v_numcte            CHAR(20);

   DEFINE v_longitud          SMALLINT;
   DEFINE v_conta             INTEGER;
   DEFINE v_nombre1           CHAR(15);
   DEFINE v_nombre2           CHAR(15);
   DEFINE v_paterno           CHAR(15);
   DEFINE v_materno           CHAR(15);
   DEFINE v_razon_soc         CHAR(60);

  ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "ConsNomb1.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET p_mensaje = error_info;
      RETURN v_nombre_completo, v_numcte, cod_ret, p_mensaje;
   END EXCEPTION;

   
   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";
   LET v_nombre_completo = '';
   LET v_numcte = '';
   LET ppaterno = TRIM(ppaterno)||'%';
   LET pmaterno = TRIM(pmaterno)||'%';
   LET prazon = prazon||'%';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

   IF(prazon IS NULL OR prazon = ' ') THEN
      FOREACH
         SELECT
            numcte,
            TRIM(NVL(apell_paterno,' ')) || ' ' ||
            TRIM(NVL(apell_materno,' ')) || ' ' ||
            TRIM(NVL(nombre1,' ')) || ' ' ||
            TRIM(NVL(nombre2,' '))  nombre
         INTO
            v_numcte,
            v_nombre_completo
         FROM
            si_cliente
         WHERE
            apell_paterno LIKE ppaterno
         AND
            apell_materno LIKE pmaterno
         ORDER BY
            nombre

         RETURN v_nombre_completo, v_numcte, cod_ret, p_mensaje WITH RESUME;

      END FOREACH;
   ELSE
       FOREACH
         SELECT
            numcte,
            razon_social
         INTO
            v_numcte,
            v_nombre_completo
         FROM
            si_cliente
         WHERE
            razon_social LIKE prazon
         ORDER BY
            razon_social
         RETURN v_nombre_completo, v_numcte, cod_ret, p_mensaje WITH RESUME;
      END FOREACH;
   END IF;


   RETURN v_nombre_completo, v_numcte, cod_ret, p_mensaje;
END PROCEDURE
DOCUMENT
'SPL migrado del PL del mismo nombre de fondafa',
'FECHA : 11/06/2003',
'OD   : Raul Mendoza D nes',
'CLIENTE: Financiera Rural',
'BD : bdinteg';

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