CREATE PROCEDURE "informix".aumento_disminucion_linea(o_empresa char(3))

RETURNING char(6),char(80);


    DEFINE cCodRet                  char(6);
    DEFINE cMensaje                 char(80);
    DEFINE sql_err                  integer;
    DEFINE isam_err                 integer;
    DEFINE cSql                     char(1024);

    DEFINE v_producto            CHAR(4);
    DEFINE v_divisa              CHAR(2);
    DEFINE v_monto_antes         DECIMAL(14,2);
    DEFINE v_monto_ahora         DECIMAL(14,2);
    DEFINE v_monto_cambio        DECIMAL(14,2);
    DEFINE v_sucursal            CHAR(4);
    DEFINE v_folio	             CHAR(16);
    DEFINE v_num_solicitud       CHAR(20);
    DEFINE v_codigo_fun          CHAR(3);
    DEFINE v_codigo_ref          INTEGER;
    DEFINE v_status              CHAR(1);
    DEFINE v_contador            integer;   
    
    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      DROP TABLE cambio_linea;
      ROLLBACK WORK;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

    LET cCodRet = "000000";
    LET cMensaje = "PROCESO EXITOSO";
    LET cSql= "";

    LET v_producto="";
    LET v_divisa="";
    LET v_monto_antes=0;
    LET v_monto_ahora=0;
    LET v_monto_cambio=0;
    LET v_sucursal="";
    LET v_folio="";
    LET v_num_solicitud="";
    LET v_codigo_ref=0;
    LET v_status="";
    LET v_codigo_fun='008';
    let v_contador=0;

 -- SET DEBUG FILE TO "CAMBIO_LINEA.out";
 -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

--I INICIANDO, S ACTUALIZADO, N NO EXISTE LA SOLICITUD
        CREATE TABLE cambio_linea(
                num_solicitud   CHAR(20),
                monto           DECIMAL(14,2));

            let cSql = '';
            let cSql = 'echo "load from aumento_disminucion_linea.unl' ||
                       ' insert into cambio_linea;' ||
                       ' " > cambio_linea.sql';
            SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred cambio_linea.sql';
              SYSTEM cSql; 
          
    FOREACH WITH HOLD

        SELECT num_solicitud,monto
        INTO v_num_solicitud,v_monto_ahora
        FROM cambio_linea

        SELECT monto_otorgado 
        INTO v_monto_antes
        FROM sd_maesdos 
        WHERE empresa=o_empresa
        AND  num_credito=v_num_solicitud;

      IF v_monto_antes is null THEN
          CONTINUE FOREACH;
       END IF; 

    BEGIN WORK;

	SELECT a.num_producto, a.divisa, b.sucursal
	  INTO v_producto, v_divisa, v_sucursal
	  FROM bdisolic:ss_solicitudes b, sd_definicion a
	 WHERE b.empresa = o_empresa
	   AND b.num_solicitud = v_num_solicitud
	   AND a.empresa = b.empresa
	   AND a.num_producto = b.num_producto;

       LET v_monto_cambio=v_monto_antes-v_monto_ahora;

       IF v_monto_cambio >= 0 THEN
              UPDATE sd_maesdos 
              SET monto_otorgado=v_monto_ahora
              WHERE empresa='001'
              AND num_credito=v_num_solicitud;

          LET v_codigo_ref=2;
          LET v_status='D';

       ELSE

          LET v_codigo_ref=1;
          LET v_status='A';

          LET v_monto_cambio = v_monto_cambio * (-1); 

          UPDATE sd_maesdos 
          SET monto_otorgado=monto_otorgado+v_monto_cambio
          WHERE empresa='001'
          AND num_credito=v_num_solicitud;

       END IF;


        LET v_folio='line'||v_num_solicitud;

      IF   v_monto_cambio <>0 THEN
          EXECUTE PROCEDURE GENMOV( o_empresa         , v_num_solicitud,
                                  v_producto          ,v_codigo_ref,
                                    v_codigo_fun      , today,
                                    v_monto_cambio    , v_folio,
                                    v_sucursal        ,v_divisa,
                                    "0000")
        INTO cCodRet,cMensaje;
       END IF;

    COMMIT WORK;

    END FOREACH;

  DROP TABLE cambio_linea;

            let cSql = '';
            LET cSql = "rm cambio_linea.sql";
            SYSTEM cSql;


 RETURN cCodRet,cMensaje;

END PROCEDURE;