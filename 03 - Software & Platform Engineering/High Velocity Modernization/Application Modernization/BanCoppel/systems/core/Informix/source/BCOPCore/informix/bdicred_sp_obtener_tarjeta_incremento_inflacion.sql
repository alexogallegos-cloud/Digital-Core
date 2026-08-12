CREATE PROCEDURE "informix".sp_obtener_tarjeta_incremento_inflacion(
    pEmpresa            CHAR(3),    
    p_numcte            CHAR(20)   
    )
RETURNING 
    CHAR(5) AS cCodRet,
    char(4) AS cTermnTarjeta,
    CHAR(50) AS cDescription;

    DEFINE cCodRet                      CHAR(5);
    DEFINE cCodRetSms                   CHAR(5);
    DEFINE sErrorCont                   SMALLINT;
    DEFINE iSqlErr                      INTEGER;
    DEFINE d_fecha_hoy                  DATE;
    DEFINE c_num_credito                CHAR(20);
    DEFINE c_num_producto               CHAR(4);
    DEFINE s_secuencia_tarjeta          SMALLINT;
    DEFINE c_num_tarjeta                CHAR(20);
    DEFINE c_nombre_prod                CHAR(50);


     LET cCodRet                      = '00000';
    LET cCodRetSms                   = '';
    LET sErrorCont                   = 0;
    LET iSqlErr                      = 0;
    LET d_fecha_hoy                  =DATE(1);
    LET c_num_credito                = '';
    LET c_num_producto               = '';
    LET s_secuencia_tarjeta          = 0;
    LET c_num_tarjeta                = '';
    LET c_nombre_prod                = '';


    BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet,c_num_tarjeta,c_nombre_prod;
        END IF;
	END EXCEPTION;
    
   --   SET DEBUG FILE TO '/home/e10000187/TRACE/sp_obtener.out';
    --  TRACE ON;
    

    
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy 
    INTO d_fecha_hoy
    FROM bdicred:sd_fechas
    WHERE empresa = pEmpresa;
 

    SELECT FIRST 1 num_credito,num_producto 
        INTO c_num_credito,c_num_producto
        FROM bdicred:"informix".sd_bitacora_incremento_inflacion
        WHERE num_cliente  = p_numcte
        AND confirma_incremento <> "1" 
            AND fin_vigencia >= d_fecha_hoy;

        SELECT MAX(secuencia) 
            INTO s_secuencia_tarjeta 
            FROM bdicred:sd_tarjeta 
            WHERE num_credito = c_num_credito AND tipo_tarjeta = 'T' AND status_tar = 'A';

        SELECT num_tarjeta 
            INTO c_num_tarjeta 
            FROM bdicred:"informix".sd_tarjeta 
            WHERE num_credito = c_num_credito AND tipo_tarjeta = 'T' AND status_tar = 'A' AND secuencia = s_secuencia_tarjeta;

        SELECT  descripcion 
            INTO c_nombre_prod 
            FROM bdicred:"informix".sd_param_incremento_inf_tc 
            WHERE producto = c_num_producto; 

      RETURN cCodRet,nvl(SUBSTR(c_num_tarjeta,13),''),nvl(c_nombre_prod,'');
      

END;   
END PROCEDURE
;