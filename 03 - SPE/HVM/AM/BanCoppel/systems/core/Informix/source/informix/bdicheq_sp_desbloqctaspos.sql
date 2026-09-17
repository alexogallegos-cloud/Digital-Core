CREATE PROCEDURE "informix".sp_desbloqctaspos(pempresa char(3))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    DEFINE cod_ret1     CHAR(5);
    DEFINE cod_ret2     CHAR(5);
    DEFINE cod_ret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE nComit       INTEGER;
    DEFINE vcuantos1    INTEGER;
    DEFINE vcuantos2    INTEGER;
    DEFINE vcomienza    SMALLINT;
    
    DEFINE vsql         CHAR(300);
    DEFINE vstmt        CHAR(100);
    DEFINE vfecha       DATE;
    DEFINE vhora        CHAR(15);
    DEFINE vfolio       CHAR(20);
    DEFINE vcuenta      CHAR(20);

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        IF sql_err <> 0 THEN
            LET cod_ret1 = sql_err;
            LET cod_ret2 = isam_err;
            LET cod_ret3 = desc_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cod_ret1, cod_ret2, cod_ret3, vcuantos1, vcuantos2;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desbloqctaspos.out";
    --- TRACE ON;

    LET cod_ret1    = "000";
    LET cod_ret2    = "000";
    LET cod_ret3    = "PROCESO CONCLUIDO";
    LET nComit      = 0;
    LET vcuantos1    = 0;
    LET vcuantos2    = 0;
    LET vcomienza   = -1;
    
    LET vsql        = '';
    LET vstmt       = '';
    LET vfecha      = '';
    LET vhora       = '';
    LET vfolio      = '';
    LET vcuenta     = ''; 

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
      INTO vfecha
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxdesbloq') THEN
        DROP TABLE "informix".ctasxdesbloq;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxdesbloq
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxdesb ON "informix".ctasxdesbloq(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentas_desbloquear.unl DELIMITER ''","'' INSERT INTO ctasxdesbloq" > /resplogifx/conciliachq/ctasxdesb.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxdesb.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxdesbloq;

    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM ctasxdesbloq
          
        BEGIN WORK;
        LET nComit = 1;
        LET vcuantos1 = vcuantos1 + 1;
        
        DELETE FROM "informix".cuentas
         WHERE cuenta = vcuenta;
        
        DELETE FROM "informix".sc_ctabloqueo
         WHERE cuenta = vcuenta;
        
        INSERT INTO "informix".sc_histbloq
        (empresa, cuenta, tipo_mov, motivo, opcion, importe, usuario, fecha, hora, clave, status_blo, folio_suc, referencia, cve_area, cod_area, cve_tipobloq, cod_tipobloq)
        VALUES
        (pempresa, vcuenta, "D", "00", " ", 0.00, "informix", vfecha, current hour to fraction, "1111", "D", vfolio, " ", " "," "," "," ");
        
        UPDATE "informix".sc_maechq
           SET status_cta = '1',
               motivo = '00'
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
            ROLLBACK WORK;
            LET nComit = 0;
            CONTINUE FOREACH;
        END IF;
        
        COMMIT WORK;
        LET nComit = 0;
        LET vcuantos2 = vcuantos2 + 1;
    END FOREACH

    IF nComit = 1 THEN
        COMMIT WORK;
        LET nComit = 0;
    END IF;

    END;

    RETURN cod_ret1, cod_ret2, cod_ret3, vcuantos1, vcuantos2;

END PROCEDURE;