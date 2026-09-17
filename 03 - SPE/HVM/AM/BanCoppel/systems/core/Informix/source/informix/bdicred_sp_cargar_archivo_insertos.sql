CREATE PROCEDURE "informix".sp_cargar_archivo_insertos(pempresa CHAR(3), pRuta CHAR(3),pRutaMov CHAR(3), parchivo CHAR(100) )
RETURNING
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje;

DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6);
DEFINE cMensajeRet           CHAR(80);
DEFINE cArchivo              CHAR(20);
DEFINE cRuta                 CHAR(255);
DEFINE cRutaMover            CHAR(255);
DEFINE cSentencia            CHAR(5000);
DEFINE cNuevoArchivo         CHAR(100);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "sp_cargar_archivo_insertos.out";
-- TRACE ON;

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = '';
LET cCodRet            = '000000';
LET cMensajeRet        = 'Se realizo la consulta correctamente';
LET cArchivo           = '';
LET cRuta              = '';
LET cRutaMover         = '';
LET cSentencia         = '';
LET cNuevoArchivo      = '';

   SELECT TRIM(valor) 
     INTO cRuta 
     FROM "informix".sd_param 
    WHERE empresa = pempresa 
      AND cod_param = pRuta;
      
   SELECT TRIM(valor) 
     INTO cRutaMover 
     FROM "informix".sd_param 
    WHERE empresa = pempresa 
      AND cod_param = pRutaMov;

    IF cRuta IS NULL OR cRutaMover IS NULL THEN
        LET cCodRet            = '000001';
        LET cMensajeRet        = 'El parámetro no existe';
        RETURN cCodRet, cMensajeRet;
    END IF;
   
    TRUNCATE  "informix".sd_marcaje_paso;
   
    LET cSentencia = '';
    LET cSentencia = 'cd ' || TRIM(cRuta);
    SYSTEM cSentencia;

    LET cSentencia = ' echo "load from ' ||TRIM(cRuta) || TRIM(parchivo) || ' insert into bdicred:sd_marcaje_paso"'||
            	  ' > queryinserto.sql';
                  
    SYSTEM cSentencia;
	LET cSentencia = "dbaccess bdicred queryinserto.sql";
	SYSTEM cSentencia;

    UPDATE statistics medium FOR TABLE sd_marcaje_paso;
    
    LET cSentencia = '';
    LET cSentencia = "rm  queryinserto.sql";
    SYSTEM cSentencia;
    
    let cNuevoArchivo = SubStr( parchivo, 1, ( length(parchivo) - 3)) || "proc";
        
    LET cSentencia = '';
    LET cSentencia = "mv " || TRIM(cRuta)||trim(parchivo)||" "||TRIM(cRutaMover)|| trim(cNuevoArchivo);
    SYSTEM cSentencia; 

    RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para cargar',
'los datos de un archivo en la tabla bdicred:sd_marcaje_paso para realizar el proceso de insertos',
'AUTOR : Roque Enrique Solis',
'FECHA : 27/MAYO/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_listar_archivos_insertos(pempresa CHAR(3), pRuta CHAR(3))
RETURNING
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje,
          CHAR(20) AS archivo;

DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6);
DEFINE cMensajeRet           CHAR(80);

DEFINE cArchivo              CHAR(20);
DEFINE cRuta                 CHAR(255);
DEFINE cSentencia            CHAR(5000);


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;

      RETURN cCodRet, cMensajeRet, cArchivo;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "sp_listar_archivos_insertos.out";
-- TRACE ON;

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = '';
LET cCodRet            = '000000';
LET cMensajeRet        = 'Se realizo la consulta correctamente';

LET cArchivo           = '';
LET cRuta              = '';
LET cSentencia         = '';

BEGIN WORK ;

   SELECT TRIM(valor)
     INTO cRuta
     FROM sd_param
    WHERE empresa = pempresa
      AND cod_param = pRuta;

      IF cRuta IS NULL THEN
          LET cCodRet= '000009';
          LET cMensajeRet = 'No existe el parametro de la ruta';
          RETURN cCodRet, cMensajeRet, cArchivo;
      END IF;

    TRUNCATE TABLE "informix".sd_archivos_insertos;
    COMMIT WORK;
    
    UPDATE statistics medium FOR TABLE sd_archivos_insertos;

--    BEGIN WORK ;

    LET cSentencia = '';
    LET cSentencia = 'cd ' || trim(cRuta);
    SYSTEM cSentencia;

    LET cSentencia = '';
    LET cSentencia = 'ls ' || trim(cRuta) || '| grep .txt' ||'  > archivosinsertos.txt';
    SYSTEM cSentencia;


     LET cSentencia = '';
     LET cSentencia = "sed 's/$/|/g' 'archivosinsertos.txt' > 'archivosinsertos.unl'";
     SYSTEM cSentencia;

      LET cSentencia = '';
      LET cSentencia = "rm  archivosinsertos.txt";
      SYSTEM cSentencia;


     LET cSentencia = ' echo "load from archivosinsertos.unl insert into bdicred:sd_archivos_insertos"'||
            	  ' > queryinserto.sql';

     SYSTEM cSentencia;
	 LET cSentencia = "dbaccess bdicred queryinserto.sql";
	 SYSTEM cSentencia;

     UPDATE statistics medium FOR TABLE sd_archivos_insertos;

     LET cSentencia = '';
     LET cSentencia = "rm  archivosinsertos.unl";
     SYSTEM cSentencia;

     LET cSentencia = '';
     LET cSentencia = "rm  queryinserto.sql";
     SYSTEM cSentencia;

 FOREACH
    SELECT archivos
      INTO cArchivo
      FROM "informix".sd_archivos_insertos
     

      RETURN cCodRet,cMensajeRet,cArchivo WITH RESUME;
  END FOREACH;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para listar',
'archivos que se encuentren en un directorio del servidor',
'AUTOR : Roque Enrique Solis',
'FECHA : 25/MAYO/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_insert_inserto(pEmpresa CHAR(3), pUsuario CHAR(9), pArchivo CHAR(100))
RETURNING
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje,
          INTEGER AS sin_actualizar,
          INTEGER AS procesados;

DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6);
DEFINE cMensajeRet           CHAR(80);
DEFINE dtFechaEmicion        DATE;
DEFINE dtFechaHoy            DATE;
DEFINE cInsertoAct           CHAR(15);
DEFINE cInserto1             CHAR(15);
DEFINE cInserto2             CHAR(15);
DEFINE cInsertoNuevo         CHAR(15);
DEFINE cNumCred              CHAR(20);
DEFINE cPosAct               CHAR(2);
DEFINE cNumcredP             CHAR(20);
DEFINE cPosicion             CHAR(2);
DEFINE iNoProcesados         INTEGER;
DEFINE iProcesados           INTEGER;
DEFINE iContador             INTEGER;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;

      INSERT INTO "informix".sd_bitacora_insertos( empresa, fecha_insert, num_credito, nombre_archivo, posicion, cod_error, descripcion_error,user_insert)
                                                      VALUES(pEmpresa, current, cNumcredP, pArchivo, cPosicion, cCodRet, cMensajeRet, pUsuario);
      RETURN cCodRet, cMensajeRet, iNoProcesados, iProcesados;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "sp_insert_inserto.out";
-- TRACE ON;

LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = '';
LET cCodRet               = '000000';
LET cMensajeRet           = 'Se realizo la consulta correctamente';
LET dtFechaEmicion        = DATE(1);
LET dtFechaHoy            = DATE(1);
LET cInsertoAct           = '000000000000000';
LET cInserto1             = '';
LET cInserto2             = '';
LET cInsertoNuevo         = '';
LET cPosAct               = '';
LET cNumcredP             = '';
LET cPosicion             = '';
LET iNoProcesados         = 0;
LET iProcesados           = 0;
LET iContador             = -1;

IF pEmpresa = '' OR pUsuario = '' OR pArchivo = '' THEN
     LET cCodRet= '000009';
     LET cMensajeRet= 'Faltan parámetros';

     RETURN cCodRet, cMensajeRet, iNoProcesados, iProcesados;
END IF;


SELECT fecha_hoy
 INTO dtFechaHoy
 FROM "informix".sd_fechas
WHERE empresa=pEmpresa;

FOREACH
    SELECT a.num_credito, a.posicion
      INTO cNumcredP, cPosicion
      FROM "informix".sd_marcaje_paso a

    SELECT num_credito
      INTO  cNumCred
      FROM  "informix".sd_maecred
     WHERE  empresa      = pEmpresa
       AND  num_credito  = cNumcredP;

        IF cNumCred IS NULL THEN
            LET cMensajeRet = "El número de crédito no existe";
            LET cCodRet="000001";
            LET iNoProcesados= iNoProcesados+1;

            INSERT INTO "informix".sd_bitacora_insertos( empresa, fecha_insert, num_credito, nombre_archivo, posicion, cod_error, descripcion_error,user_insert)
                                                      VALUES(pEmpresa,current, cNumcredP, pArchivo, cPosicion, cCodRet, cMensajeRet, pUsuario);
            CONTINUE FOREACH;
        END IF;

         IF (iContador = -1) THEN BEGIN WORK; END IF;

       IF cPosicion > 15 OR cPosicion < 1 THEN
          LET cMensajeRet = "Posicion no valida";
          LET cCodRet="000002";
          LET iNoProcesados= iNoProcesados+1;
          INSERT INTO "informix".sd_bitacora_insertos( empresa, fecha_insert, num_credito, nombre_archivo, posicion, cod_error, descripcion_error,user_insert)
                                                      VALUES(pEmpresa, current, cNumcredP, pArchivo, cPosicion, cCodRet, cMensajeRet, pUsuario);
          CONTINUE FOREACH;
       END IF;

       SELECT num_credito, insertos
         INTO cNumCred, cInsertoAct
         FROM "informix".sd_marcaje
        WHERE empresa       = pEmpresa
          AND num_credito   = cNumcredP
          AND fecha_emision = dtFechaHoy;
    
          IF cInsertoAct IS NULL THEN
             LET cInsertoAct = '000000000000000';
          END IF;

          LET cPosAct =  SubStr(cInsertoAct,cPosicion, 1);

          LET cInserto1 = SubStr(cInsertoAct , 1 , cPosicion-1);
          LET cInserto2 = SubStr(cInsertoAct, cPosicion+1 ,15);

          IF cInserto1 IS NULL THEN
             LET cInserto1 = '';
          END IF;

          IF cInserto2 IS NULL THEN
             LET cInserto2 = '';
          END IF;

          LET cInsertoNuevo = TRIM(cInserto1) || '1' || TRIM(cInserto2);

          IF  cNumCred IS NOT NULL THEN

               IF cPosAct='0' THEN
                 UPDATE "informix".sd_marcaje
                    SET insertos = cInsertoNuevo
                  WHERE empresa       = pEmpresa
                    AND num_credito   = cNumcredP
                    AND fecha_emision = dtFechaHoy;

                  LET cMensajeRet = "Actualizacion";
               ELSE
                  LET cMensajeRet = "Sin cambio";
               END IF
          ELSE

               INSERT INTO "informix".sd_marcaje (empresa,num_credito,fecha_emision,posicion,insertos)
               VALUES(pEmpresa,cNumcredP,dtFechaHoy,cPosicion,cInsertoNuevo);

               LET cMensajeRet = "Nuevo";
          END IF
        LET iProcesados = iProcesados + 1;
        LET iContador   = iContador   + 1;

      IF (iContador >= 40000) THEN
         COMMIT WORK;
         UPDATE statistics medium FOR TABLE sd_marcaje;
         LET iContador = 0;
         BEGIN WORK;
      END IF;
END FOREACH;

IF (iContador > 0) THEN
   COMMIT WORK;
END IF;

UPDATE statistics medium FOR TABLE sd_marcaje;

RETURN cCodRet,cMensajeRet,iNoProcesados, iProcesados ;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para insertar',
'los insertos en estados de cuenta',
'AUTOR : Roque Enrique Solis',
'FECHA : 25/MARZO/2009',
'Modificacion',
'FECHA : 27/MAYO/2009',
'Se modifico para utilizar bitacora para los créditos que ocacionen errores',
'BD    : BDICRED';

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