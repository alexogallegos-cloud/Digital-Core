CREATE PROCEDURE "informix".sp_rptretdif(pempresa CHAR(3))

 RETURNING CHAR(5), INTEGER;

    -- ******************************
    -- *  DECLARACION DE VARIABLES  *
    -- ******************************
    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vcontador		INTEGER;
    DEFINE vcuantos  		INTEGER;
    DEFINE vcuenta          CHAR(20);
    DEFINE vretmaechq       MONEY(14,2); 
    DEFINE vretdocret       MONEY(14,2);
    DEFINE vdiferencia      MONEY(14,2);
    DEFINE vcomienza        INTEGER;
    DEFINE vsql             CHAR(200);

    -- *********************************
    -- *  INICIALIZACION DE VARIABLES  *
    -- *********************************
    LET vcodret	    = "000";
    LET sql_err	    = 0;
    LET vcontador   = -1;
    LET vcuantos    = 0;
    LET vcomienza   = -1;

    BEGIN

    -- ************************
    -- *  MANEJA EXCEPCIONES  *
    -- ************************
    ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
            RETURN vcodret, vcuantos;
	END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "./sp_rptretdif.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS (SELECT dbsname, tabname
                 FROM sysmaster:systabnames
                WHERE partnum BETWEEN (SELECT MIN(partnum) FROM sysmaster:systabnames) AND
                                      (SELECT MAX(partnum) FROM sysmaster:systabnames)
                  AND tabname = 'sc_rptretenidos') THEN

        DROP TABLE bdicheq:'informix'.sc_rptretenidos;

        CREATE RAW TABLE bdicheq:'informix'.sc_rptretenidos(
            cuenta          CHAR(20),
            sdo_retmaechq   MONEY(14,2),
            sdo_retdocret   MONEY(14,2),
            diferencia      MONEY(14,2))LOCK MODE ROW;
        REVOKE ALL ON bdicheq:'informix'.sc_rptretenidos FROM "public";
    ELSE

        CREATE RAW TABLE bdicheq:'informix'.sc_rptretenidos(
            cuenta          CHAR(20),
            sdo_retmaechq   MONEY(14,2),
            sdo_retdocret   MONEY(14,2),
            diferencia      MONEY(14,2))LOCK MODE ROW;
        REVOKE ALL ON bdicheq:'informix'.sc_rptretenidos FROM "public";
    END IF;

    -- ************************************************************
    -- *  TABLA TEMPORAL PARA LAS CUENTAS DEL MAESTRO DE CHEQUES  *
    -- ************************************************************
    SELECT {+INDEX(sc_maechq bdicheq)}
           cuenta, sdo_retenido
      FROM sc_maechq
     WHERE status_cta <> "2"
       AND sdo_retenido <> 0
      INTO TEMP tmp_maechq WITH NO LOG;
    CREATE INDEX idx_ctas ON tmp_maechq(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_maechq;

    -- ***************************************************************
    -- *  TABLA TEMPORAL PARA DETECTAR LAS TRANSACCIONES PENDIENTES  *
    -- ***************************************************************
    SELECT cuenta, COUNT(*) AS no_reg, SUM(monto) AS sum_monto
      FROM sc_docret
     WHERE siglas = "SC"
       AND fecha_alta > "05012007"
       AND cancelado in("P","T")
     GROUP BY cuenta
      INTO TEMP tmp_docret WITH NO LOG;
    CREATE INDEX idx_ret ON tmp_docret(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_docret;

    -- ************************ FOREACH PRINCIPAL ************************
    FOREACH WITH HOLD
        SELECT a.cuenta, a.sdo_retenido, b.sum_monto,
               a.sdo_retenido - sum_monto as diferencia
          INTO vcuenta, vretmaechq, vretdocret, vdiferencia
          FROM tmp_maechq a,   
               tmp_docret b
         WHERE a.cuenta = b.cuenta
           AND b.cuenta = a.cuenta
           AND a.sdo_retenido <> b.sum_monto
           
        IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcontador = 0;
            LET vcomienza = 0;
        END IF
           
        INSERT INTO sc_rptretenidos VALUES(vcuenta,vretmaechq,vretdocret,vdiferencia);
           
        LET vcontador = vcontador + 1;

        IF (vcontador >= 10000) THEN
            LET vcuantos = vcuantos + vcontador;
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vretmaechq  = 0.00;
        LET vretdocret  = 0.00;
        LET vdiferencia = 0.00;

    END FOREACH;
    -- *********************** FOREACH PRINCIPAL *************************

    LET vcuantos = vcuantos + vcontador;

    IF (vcontador >= 0) THEN
        COMMIT WORK;
    END IF;
    
    CREATE INDEX idx_rptretdif ON sc_rptretenidos(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_rptretenidos;
    
    -- // DESCARGA TABLA DEL REPORTE
    LET vsql = '';
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/rpt_retenidos.txt'||
                ' SELECT * FROM sc_rptretenidos WHERE cuenta IS NOT NULL;"'||
                ' > /resplogifx/conciliachq/rptretenidos.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/rptretenidos.sql';
    SYSTEM vsql;
    let vsql = '';
    
    END;

    RETURN vcodret, vcuantos;

END PROCEDURE;