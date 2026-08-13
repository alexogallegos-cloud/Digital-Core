CREATE PROCEDURE "informix".sp_coas_recibidos( pNombreArchivo CHAR(30) )
RETURNING CHAR(5), CHAR(5), CHAR(80);
	
    DEFINE vsqlerr   	INTEGER;
    DEFINE visamerr   	INTEGER;
    DEFINE vdescerr   	CHAR(50);
    DEFINE vcodret   	CHAR(5);
    DEFINE vcodret2  	CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE iComienza    SMALLINT;
    DEFINE iTransacc    SMALLINT;
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE iContador3   INTEGER;
    DEFINE cStmt        CHAR(300);
    DEFINE cSql         CHAR(300);
    
    DEFINE iOperaciones     SMALLINT;
    DEFINE iAbonos          SMALLINT;
    DEFINE iDevols          SMALLINT;
    DEFINE cfolio           CHAR(10);
    DEFINE ctipo_pago       CHAR(2);
    DEFINE cclave_particip  CHAR(5);
    DEFINE cmonto_pago      CHAR(19);
    DEFINE cfolio_pago      CHAR(5);
    DEFINE cclave_rastreo   CHAR(30);
    DEFINE cnombre_orden    CHAR(40);
    DEFINE ctpo_cta_orden   CHAR(2);
    DEFINE ccuenta_orden    CHAR(20);
    DEFINE crfc_orden       CHAR(18);
    DEFINE cnombre_benef    CHAR(40);
    DEFINE ctpo_cta_benef   CHAR(2);
    DEFINE ccuenta_benef    CHAR(20);
    DEFINE crfc_benef       CHAR(18);
    DEFINE cconcepto_pago   CHAR(40);
    DEFINE cimporte_iva     CHAR(16);
    DEFINE cref_numerica    CHAR(7);
    DEFINE cref_cobranza    CHAR(40); 
    DEFINE cFolioAbono      CHAR(30);
    DEFINE cClaveDevAbono   CHAR(2);
    DEFINE cRFCAbono        CHAR(18);
    DEFINE cNombreCteAbono  CHAR(40); 
    DEFINE dmonto_pago      DECIMAL(17,2);
    DEFINE dmonto_pago_ints DECIMAL(17,2);
    DEFINE cFolioDev        CHAR(5);
    DEFINE cclave_devol     CHAR(2);
    DEFINE cCadena          CHAR(352);
    DEFINE iCont            SMALLINT;
    DEFINE iOperacion       CHAR(1);
    DEFINE iOperacion2      CHAR(1);
    DEFINE cvchrcuentabenef CHAR(20);
    DEFINE iintrefnumerica  DECIMAL(7,0);
    DEFINE cfolio_ori       CHAR(10);
    DEFINE cfolio_pago_ori  CHAR(5);
    DEFINE cfecha_ori       CHAR(8);
    DEFINE ccve_rastreo_ori CHAR(30);
    DEFINE cref_num_ori     CHAR(7);
    DEFINE ctpo_cta_ord_ori CHAR(2);
    DEFINE ccta_ord_pag_ori CHAR(20);
    DEFINE cconcepto_ori    CHAR(40);
    DEFINE cmonto_pago_ori  CHAR(19);
    DEFINE cmonto_intereses CHAR(19);
    DEFINE ctipo_operacion  CHAR(2);
    
    LET vsqlerr    = 0; 
    LET visamerr   = 0; 
    LET vdescerr   = 0; 
    LET vcodret    = '000'; 
    LET vcodret2   = '000'; 
    LET vcodret3   = 'PROCESO FINALIZADO CORRECTAMENTE'; 
    LET iComienza  = -1; 
    LET iTransacc  = 0; 
    LET iContador1 = 0; 
    LET iContador2 = 0; 
    LET iContador3 = 0; 
    LET cStmt      = '';
    LET cSql       = '';
    
    LET iOperaciones     = 0;
    LET iAbonos          = 0;
    LET iDevols          = 0;
    LET cfolio           = '';
    LET ctipo_pago       = '';
    LET cclave_particip  = '';
    LET cmonto_pago      = '';
    LET cfolio_pago      = '';
    LET cclave_rastreo   = '';
    LET cnombre_orden    = '';
    LET ctpo_cta_orden   = '';
    LET ccuenta_orden    = '';
    LET crfc_orden       = '';
    LET cnombre_benef    = '';
    LET ctpo_cta_benef   = '';
    LET ccuenta_benef    = '';
    LET crfc_benef       = '';
    LET cconcepto_pago   = '';
    LET cimporte_iva     = '';
    LET cref_numerica    = '';
    LET cref_cobranza    = '';
    LET cFolioAbono      = '';
    LET cClaveDevAbono   = '';
    LET cRFCAbono        = '';
    LET cNombreCteAbono  = '';
    LET dmonto_pago      = 0.00; 
    LET dmonto_pago_ints = 0.00;
    LET cFolioDev        = '';    
    LET cclave_devol     = ''; 
    LET cCadena          = '';
    LET iCont            = 0;
    LET iOperacion       = '';
    LET iOperacion2      = '';
    LET cvchrcuentabenef = '';
    LET iintrefnumerica  = 0;
    LET cfolio_ori       = ''; 
    LET cfolio_pago_ori  = ''; 
    LET cfecha_ori       = ''; 
    LET ccve_rastreo_ori = '';
    LET cref_num_ori     = ''; 
    LET ctpo_cta_ord_ori = ''; 
    LET ccta_ord_pag_ori = ''; 
    LET cconcepto_ori    = '';
    LET cmonto_pago_ori  = ''; 
    LET cmonto_intereses = '';
    LET ctipo_operacion  = '';
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/sp_coas_recibidos.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/sp_coas_recibidos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // CREA TABLA DE TRABAJO PARA TODO EL ARCHIVO
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec') THEN
        DROP TABLE "informix".tbl_coas_rec;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec(cadena CHAR(352))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA DE TRABAJO PARA ABONOS TIPO 1
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_abono') THEN
        DROP TABLE "informix".tbl_coas_rec_abono;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_abono(cadena CHAR(352))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA DE TRABAJO PARA ABONOS TIPO 5
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_abono5') THEN
        DROP TABLE "informix".tbl_coas_rec_abono5;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_abono5(cadena CHAR(352))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA DE TRABAJO PARA ABONOS TIPO 7
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_abono7') THEN
        DROP TABLE "informix".tbl_coas_rec_abono7;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_abono7(cadena CHAR(352))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA DE TRABAJO PARA DEVOLUCIONES TIPO 0
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_devol') THEN
        DROP TABLE "informix".tbl_coas_rec_devol;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_devol(cadena CHAR(352))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA DE TRABAJO PARA DEVOLUCIONES TIPO 16
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_devol16') THEN
        DROP TABLE "informix".tbl_coas_rec_devol16;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_devol16(cadena CHAR(352))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA DE TRABAJO PARA LOS REGISTROS PENDIENTES
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_pend') THEN
        DROP TABLE "informix".tbl_coas_rec_pend;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_pend(cadena CHAR(352))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA PARA EL ENCABEZADO
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_encabezado_coas_rec') THEN
        DROP TABLE "informix".tbl_encabezado_coas_rec;
    END IF;
    
    CREATE TABLE "informix".tbl_encabezado_coas_rec(
        tipo_registro  CHAR(1),
        clave_particip CHAR(5),
        secuencia      CHAR(4),
        no_operaciones CHAR(5) )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA PARA LOS ABONOS TIPO 1
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_abonos') THEN
        DROP TABLE "informix".tbl_coas_rec_abonos;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_abonos(
        folio          CHAR(10),
        tipo_pago      CHAR(2),
        clave_particip CHAR(5),
        monto_pago     CHAR(19),
        folio_pago     CHAR(5),
        clave_rastreo  CHAR(30),
        nombre_orden   CHAR(40),
        tpo_cta_orden  CHAR(2),
        cuenta_orden   CHAR(20),
        rfc_orden      CHAR(18),
        nombre_benef   CHAR(40),
        tpo_cta_benef  CHAR(2),
        cuenta_benef   CHAR(20),
        rfc_benef      CHAR(18),
        concepto_pago  CHAR(40),
        importe_iva    CHAR(16),
        ref_numerica   CHAR(7),
        ref_cobranza   CHAR(40) )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA PARA LOS ABONOS TIPO 5
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_abonos5') THEN
        DROP TABLE "informix".tbl_coas_rec_abonos5;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_abonos5(
        folio          CHAR(10),
        tipo_pago      CHAR(2),
        clave_particip CHAR(5),
        monto_pago     CHAR(19),
        folio_pago     CHAR(5),
        clave_rastreo  CHAR(30),
        nombre_benef   CHAR(40),
        tpo_cta_benef  CHAR(2),
        cuenta_benef   CHAR(20),
        rfc_benef      CHAR(18),
        concepto_pago  CHAR(40),
        importe_iva    CHAR(16),
        ref_numerica   CHAR(7) )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA PARA LOS ABONOS TIPO 7
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_abonos7') THEN
        DROP TABLE "informix".tbl_coas_rec_abonos7;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_abonos7(
        folio          CHAR(10),
        tipo_pago      CHAR(2),
        clave_particip CHAR(5),
        monto_pago     CHAR(19),
        folio_pago     CHAR(5),
        clave_rastreo  CHAR(30),
        tipo_operacion CHAR(2),
        concepto_pago  CHAR(210),
        importe_iva    CHAR(16),
        ref_numerica   CHAR(7) )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA PARA LAS DEVOLUCIONES TIPO 0
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_devols') THEN
        DROP TABLE "informix".tbl_coas_rec_devols;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_devols(
        folio          CHAR(10),
        tipo_pago      CHAR(2),
        clave_particip CHAR(5),
        monto_pago     CHAR(19),
        folio_pago     CHAR(5),
        clave_rastreo  CHAR(30),
        clave_devol    CHAR(2) )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CREA TABLA PARA LAS DEVOLUCIONES TIPO 16
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbl_coas_rec_devols16') THEN
        DROP TABLE "informix".tbl_coas_rec_devols16;
    END IF;
    
    CREATE TABLE "informix".tbl_coas_rec_devols16(
        folio           CHAR(10),
        tipo_pago       CHAR(2),
        clave_particip  CHAR(5),
        monto_pago      CHAR(19),
        folio_pago      CHAR(5),
        clave_rastreo   CHAR(30),
        folio_ori       CHAR(10),
        folio_pago_ori  CHAR(5),
        fecha_ori       CHAR(8),
        cve_rastreo_ori CHAR(30),
        ref_num_ori     CHAR(7),
        tpo_cta_ord_ori CHAR(2),
        cta_ord_pag_ori CHAR(20),
        clave_devol     CHAR(2),
        concepto_ori    CHAR(40),
        monto_pago_ori  CHAR(19),
        monto_intereses CHAR(19) )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    
    
    -- // CARGA EL ARCHIVO A PROCESAR
    LET cStmt = 'echo "LOAD FROM /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||' '||
                'INSERT INTO tbl_coas_rec;" > /resplogifx/conciliachq/spei/carga_coas_rec.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/carga_coas_rec.sql';
    SYSTEM cStmt; 
    
    
    FOREACH
        SELECT SKIP 1 cadena
          INTO cCadena
          FROM tbl_coas_rec
         ORDER BY rowid
         
        LET iCont = 1;
         
        WHILE SUBSTR(cCadena,iCont,1) <> '~' 
            LET iCont = iCont + 1;
            
            IF SUBSTR(cCadena,iCont,1) = '~' THEN
                LET iCont = iCont + 1;
                LET iOperacion = SUBSTR(cCadena,iCont,1);
                
                LET iCont = iCont + 1;
                LET iOperacion2 = SUBSTR(cCadena,iCont,1);
                
                IF   iOperacion = '1' AND iOperacion2 = '~' THEN
                    INSERT INTO tbl_coas_rec_abono VALUES(cCadena);
                    EXIT WHILE;
                ELIF iOperacion = '5' AND iOperacion2 = '~' THEN
                    INSERT INTO tbl_coas_rec_abono5 VALUES(cCadena);
                    EXIT WHILE;
                ELIF iOperacion = '7' AND iOperacion2 = '~' THEN
                    INSERT INTO tbl_coas_rec_abono7 VALUES(cCadena);
                    EXIT WHILE;
                ELIF iOperacion = '0' AND iOperacion2 = '~' THEN
                    INSERT INTO tbl_coas_rec_devol VALUES(cCadena);
                    EXIT WHILE;
                ELIF iOperacion = '1' AND iOperacion2 = '6' THEN
                    INSERT INTO tbl_coas_rec_devol16 VALUES(cCadena);
                    EXIT WHILE;
                ELSE
                    INSERT INTO tbl_coas_rec_pend VALUES(cCadena);
                    EXIT WHILE;
                END IF;
            END IF;
        END WHILE;
         
        LET cCadena = '';
        LET iOperacion = '';
        LET iOperacion2 = '';
    END FOREACH;
    
    
    -- // DESCARGA EL PRIMER REGISTRO DE LA TABLA DE TRABAJO PARA EL ENCABEZADO
    LET cStmt = 'echo "UNLOAD TO /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.enc '||
                'SELECT FIRST 1 * FROM tbl_coas_rec ORDER BY rowid;" > /resplogifx/conciliachq/spei/descarga_encabezado_coas_rec.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/descarga_encabezado_coas_rec.sql';
    SYSTEM cStmt;
    
    LET cSql = 'sed "s/\|$//g" /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.enc > /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.encabezado;';
    SYSTEM cSql;
    
    
    -- // DESCARGA EL DETALLE DE LOS MOVIMIENTOS DE ABONO TIPO 1
    LET cStmt = 'echo "UNLOAD TO /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abono '||
                'SELECT * FROM tbl_coas_rec_abono ORDER BY rowid;" > /resplogifx/conciliachq/spei/descarga_abonos_coas_rec.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/descarga_abonos_coas_rec.sql';
    SYSTEM cStmt;
    
    LET cSql = 'sed "s/\|$//g" /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abono > /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abonos;';
    SYSTEM cSql;
    
    
    -- // DESCARGA EL DETALLE DE LOS MOVIMIENTOS DE ABONO TIPO 5
    LET cStmt = 'echo "UNLOAD TO /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abono5 '||
                'SELECT * FROM tbl_coas_rec_abono5 ORDER BY rowid;" > /resplogifx/conciliachq/spei/descarga_abonos_coas_rec5.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/descarga_abonos_coas_rec5.sql';
    SYSTEM cStmt;
    
    LET cSql = 'sed "s/\|$//g" /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abono5 > /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abonos5;';
    SYSTEM cSql;
    
    
    -- // DESCARGA EL DETALLE DE LOS MOVIMIENTOS DE ABONO TIPO 7
    LET cStmt = 'echo "UNLOAD TO /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abono7 '||
                'SELECT * FROM tbl_coas_rec_abono7 ORDER BY rowid;" > /resplogifx/conciliachq/spei/descarga_abonos_coas_rec7.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/descarga_abonos_coas_rec7.sql';
    SYSTEM cStmt;
    
    LET cSql = 'sed "s/\|$//g" /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abono7 > /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abonos7;';
    SYSTEM cSql;
    
    
    -- // DESCARGA EL DETALLE DE LOS MOVIMIENTOS DE DEVOLUCIONES TIPO 0
    LET cStmt = 'echo "UNLOAD TO /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.devol '||
                'SELECT * FROM tbl_coas_rec_devol ORDER BY rowid;" > /resplogifx/conciliachq/spei/descarga_devol_coas_rec.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/descarga_devol_coas_rec.sql';
    SYSTEM cStmt;
    
    LET cSql = 'sed "s/\|$//g" /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.devol > /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.devols;';
    SYSTEM cSql;
    
    
    -- // DESCARGA EL DETALLE DE LOS MOVIMIENTOS DE DEVOLUCIONES TIPO 16
    LET cStmt = 'echo "UNLOAD TO /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.devol16 '||
                'SELECT * FROM tbl_coas_rec_devol16 ORDER BY rowid;" > /resplogifx/conciliachq/spei/descarga_devol_coas_rec16.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/descarga_devol_coas_rec16.sql';
    SYSTEM cStmt;
    
    LET cSql = 'sed "s/\|$//g" /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.devol16 > /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.devols16;';
    SYSTEM cSql;
    
    
    /* ############################################################################################################################################
    LET cSql = 'head -1 /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||' > /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.enc;';
    SYSTEM cSql;
    
    LET cStmt = 'echo "LOAD FROM /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.enc DELIMITER ''"~"'' '||
                'INSERT INTO tbl_encabezado_coas_rec;" > /resplogifx/conciliachq/spei/carga_encabezado_coas_rec.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/carga_encabezado_coas_rec.sql';
    SYSTEM cStmt;
    ############################################################################################################################################ */
    
    
    -- // CARGA EL ENCABEZADO
    LET cStmt = 'echo "LOAD FROM /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.encabezado DELIMITER ''"~"'' '||
                'INSERT INTO tbl_encabezado_coas_rec;" > /resplogifx/conciliachq/spei/carga_encabezado_coas_rec.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/carga_encabezado_coas_rec.sql';
    SYSTEM cStmt;
    
    
    -- // CARGA EL DETALLE DE ABONOS TIPO 1
    LET cStmt = 'echo "LOAD FROM /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abonos DELIMITER ''"~"'' '||
                'INSERT INTO tbl_coas_rec_abonos;" > /resplogifx/conciliachq/spei/carga_coas_rec_abonos.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/carga_coas_rec_abonos.sql';
    SYSTEM cStmt;
    
    
    -- // CARGA EL DETALLE DE ABONOS TIPO 5
    LET cStmt = 'echo "LOAD FROM /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abonos5 DELIMITER ''"~"'' '||
                'INSERT INTO tbl_coas_rec_abonos5;" > /resplogifx/conciliachq/spei/carga_coas_rec_abonos5.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/carga_coas_rec_abonos5.sql';
    SYSTEM cStmt;
    
    
    -- // CARGA EL DETALLE DE ABONOS TIPO 7
    LET cStmt = 'echo "LOAD FROM /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.abonos7 DELIMITER ''"~"'' '||
                'INSERT INTO tbl_coas_rec_abonos7;" > /resplogifx/conciliachq/spei/carga_coas_rec_abonos7.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/carga_coas_rec_abonos7.sql';
    SYSTEM cStmt;
    
    
    -- // CARGA EL DETALLE DE DEVOLUCIONES TIPO 0
    LET cStmt = 'echo "LOAD FROM /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.devols DELIMITER ''"~"'' '||
                'INSERT INTO tbl_coas_rec_devols;" > /resplogifx/conciliachq/spei/carga_coas_rec_devols.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/carga_coas_rec_devols.sql';
    SYSTEM cStmt;
    
    
    -- // CARGA EL DETALLE DE DEVOLUCIONES TIPO 16
    LET cStmt = 'echo "LOAD FROM /resplogifx/conciliachq/spei/'||TRIM(pNombreArchivo)||'.devols16 DELIMITER ''"~"'' '||
                'INSERT INTO tbl_coas_rec_devols16;" > /resplogifx/conciliachq/spei/carga_coas_rec_devols16.sql';
    SYSTEM cStmt;
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/spei/carga_coas_rec_devols16.sql';
    SYSTEM cStmt;
    
    
    /* ########################################################
    SELECT no_operaciones
      INTO iOperaciones
      FROM tbl_encabezado_coas_rec;
      
    SELECT COUNT(*)
      INTO iAbonos
      FROM tbl_coas_rec_abonos;
      
    SELECT COUNT(*)
      INTO iDevols
      FROM tbl_coas_rec_devols;
      
    IF (iOperaciones <> (iAbonos + iDevols)) THEN
        LET vcodret = '999';
        LET vcodret2 = '999';
        LET vcodret3 = 'NUMERO DE REGISTROS NO COINCIDEN';
        RETURN vcodret, vcodret2, vcodret3;
    END IF;
    ######################################################## */
        
    
    -- // PROCESA LOS ABONOS TIPO 1
    FOREACH WITH HOLD
        SELECT folio, tipo_pago, clave_particip, monto_pago, folio_pago, clave_rastreo, nombre_orden, tpo_cta_orden, cuenta_orden, rfc_orden, 
               nombre_benef, tpo_cta_benef, cuenta_benef, rfc_benef, concepto_pago, importe_iva, ref_numerica, ref_cobranza
          INTO cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, cnombre_orden, ctpo_cta_orden, ccuenta_orden, crfc_orden, 
               cnombre_benef, ctpo_cta_benef, ccuenta_benef, crfc_benef, cconcepto_pago, cimporte_iva, cref_numerica, cref_cobranza
          FROM tbl_coas_rec_abonos
          
        BEGIN WORK;
        LET iTransacc = 1;
        
        LET dmonto_pago = cmonto_pago;
        
        EXECUTE PROCEDURE spei_recordenpago( cclave_rastreo, ccuenta_benef, dmonto_pago, cref_numerica, cconcepto_pago, cref_cobranza, 'L', ccuenta_orden, ctpo_cta_orden )
        INTO cFolioAbono, cClaveDevAbono, cRFCAbono, cNombreCteAbono;
        
        INSERT INTO tbl_coas_rec_abonos_proc VALUES
        ( pNombreArchivo, cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, cnombre_orden, ctpo_cta_orden, ccuenta_orden,  
          crfc_orden, cnombre_benef, ctpo_cta_benef, ccuenta_benef, crfc_benef, cconcepto_pago, cimporte_iva, cref_numerica, cref_cobranza, 
          cFolioAbono, cClaveDevAbono, cRFCAbono, cNombreCteAbono, current );
          
        IF cFolioAbono = '0' THEN
            INSERT INTO tbl_coas_rec_devueltos VALUES
            ( pNombreArchivo, cclave_particip, cmonto_pago, cclave_rastreo, cClaveDevAbono, current );
        END IF;
          
        COMMIT WORK;
        LET iTransacc = 0;
          
        LET cfolio = ''; LET ctipo_pago = ''; LET cclave_particip = ''; LET cmonto_pago = ''; LET cfolio_pago = ''; LET cclave_rastreo = '';
        LET cnombre_orden = ''; LET ctpo_cta_orden = ''; LET ccuenta_orden = ''; LET crfc_orden = ''; LET cnombre_benef = ''; LET ctpo_cta_benef = '';
        LET ccuenta_benef = ''; LET crfc_benef = ''; LET cconcepto_pago = ''; LET cimporte_iva = ''; LET cref_numerica = ''; LET cref_cobranza = '';
        LET cFolioAbono = ''; LET cClaveDevAbono = ''; LET cRFCAbono = ''; LET cNombreCteAbono = ''; LET dmonto_pago = 0.00; 
    END FOREACH;
    
    
    -- // PROCESA LOS ABONOS TIPO 5
    FOREACH WITH HOLD
        SELECT folio, tipo_pago, clave_particip, monto_pago, folio_pago, clave_rastreo, 
               nombre_benef, tpo_cta_benef, cuenta_benef, rfc_benef, concepto_pago, importe_iva, ref_numerica
          INTO cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, 
               cnombre_benef, ctpo_cta_benef, ccuenta_benef, crfc_benef, cconcepto_pago, cimporte_iva, cref_numerica
          FROM tbl_coas_rec_abonos5
          
        BEGIN WORK;
        LET iTransacc = 1;
        
        LET dmonto_pago = cmonto_pago;
        
        EXECUTE PROCEDURE spei_recordenpago( cclave_rastreo, ccuenta_benef, dmonto_pago, cref_numerica, cconcepto_pago, '', 'L', '', '' )
        INTO cFolioAbono, cClaveDevAbono, cRFCAbono, cNombreCteAbono;
        
        INSERT INTO tbl_coas_rec_abonos5_proc VALUES
        ( pNombreArchivo, cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, cnombre_benef, ctpo_cta_benef, 
          ccuenta_benef, crfc_benef, cconcepto_pago, cimporte_iva, cref_numerica, cFolioAbono, cClaveDevAbono, cRFCAbono, cNombreCteAbono, current );
          
        IF cFolioAbono = '0' THEN
            INSERT INTO tbl_coas_rec_devueltos VALUES
            ( pNombreArchivo, cclave_particip, cmonto_pago, cclave_rastreo, cClaveDevAbono, current );
        END IF;
          
        COMMIT WORK;
        LET iTransacc = 0;
          
        LET cfolio = ''; LET ctipo_pago = ''; LET cclave_particip = ''; LET cmonto_pago = ''; LET cfolio_pago = ''; LET cclave_rastreo = '';
        LET cnombre_benef = ''; LET ctpo_cta_benef = ''; LET ccuenta_benef = ''; LET crfc_benef = ''; LET cconcepto_pago = ''; LET cimporte_iva = ''; 
        LET cref_numerica = ''; LET cFolioAbono = ''; LET cClaveDevAbono = ''; LET cRFCAbono = ''; LET cNombreCteAbono = ''; LET dmonto_pago = 0.00; 
    END FOREACH;
    
    
    -- // PROCESA LOS ABONOS TIPO 7
    FOREACH WITH HOLD
        SELECT folio, tipo_pago, clave_particip, monto_pago, folio_pago, clave_rastreo, 
               tipo_operacion, concepto_pago, importe_iva, ref_numerica
          INTO cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, 
               ctipo_operacion, cconcepto_pago, cimporte_iva, cref_numerica
          FROM tbl_coas_rec_abonos7
          
        BEGIN WORK;
        LET iTransacc = 1;
        
        SELECT vchrcuentabenef
          INTO cvchrcuentabenef
          FROM tblpago
         WHERE vchrclaverastreo = cclave_rastreo;
        
        IF ( cvchrcuentabenef is not null OR cvchrcuentabenef <> '' OR cvchrcuentabenef <> ' ' ) THEN
            LET dmonto_pago = cmonto_pago;
            
            EXECUTE PROCEDURE spei_recordenpago( cclave_rastreo, cvchrcuentabenef, dmonto_pago, cref_numerica, cconcepto_pago, '', 'L', '', '' )
            INTO cFolioAbono, cClaveDevAbono, cRFCAbono, cNombreCteAbono;
            
            INSERT INTO tbl_coas_rec_abonos7_proc VALUES
            ( pNombreArchivo, cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, ctipo_operacion, 
              cconcepto_pago, cimporte_iva, cref_numerica, cFolioAbono, cClaveDevAbono, cRFCAbono, cNombreCteAbono, current );
              
            IF cFolioAbono = '0' THEN
                INSERT INTO tbl_coas_rec_devueltos VALUES
                ( pNombreArchivo, cclave_particip, cmonto_pago, cclave_rastreo, cClaveDevAbono, current );
            END IF;
              
            COMMIT WORK;
            LET iTransacc = 0;
        ELSE
            LET cFolioAbono = '0'; 
            LET cClaveDevAbono = '01'; 
            LET cRFCAbono = ' '; 
            LET cNombreCteAbono = ' ';
            
            INSERT INTO tbl_coas_rec_abonos7_proc VALUES
            ( pNombreArchivo, cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, ctipo_operacion, 
              cconcepto_pago, cimporte_iva, cref_numerica, cFolioAbono, cClaveDevAbono, cRFCAbono, cNombreCteAbono, current );
              
            INSERT INTO tbl_coas_rec_devueltos VALUES
            ( pNombreArchivo, cclave_particip, cmonto_pago, cclave_rastreo, cClaveDevAbono, current );
              
            COMMIT WORK;
            LET iTransacc = 0;
        END IF;
          
        LET cfolio = ''; LET ctipo_pago = ''; LET cclave_particip = ''; LET cmonto_pago = ''; LET cfolio_pago = ''; LET cclave_rastreo = '';
        LET ctipo_operacion = ''; LET cconcepto_pago = ''; LET cimporte_iva = ''; LET cref_numerica = ''; LET cvchrcuentabenef = '';
        LET cFolioAbono = ''; LET cClaveDevAbono = ''; LET cRFCAbono = ''; LET cNombreCteAbono = ''; LET dmonto_pago = 0.00; 
    END FOREACH;
    
    
    -- // PROCESA LAS DEVOLUCIONES TIPO 0
    FOREACH WITH HOLD
        SELECT folio, tipo_pago, clave_particip, monto_pago, folio_pago, clave_rastreo, clave_devol
          INTO cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, cclave_devol
          FROM tbl_coas_rec_devols
          
        BEGIN WORK;
        LET iTransacc = 1;
        
        SELECT vchrcuentabenef, intrefnumerica
          INTO cvchrcuentabenef, iintrefnumerica
          FROM tblpago
         WHERE vchrclaverastreo = cclave_rastreo;
         
        IF ( cvchrcuentabenef is not null OR cvchrcuentabenef <> '' OR cvchrcuentabenef <> ' ' ) THEN
            LET dmonto_pago = cmonto_pago;
            
            EXECUTE PROCEDURE spei_recdevolucion( cclave_rastreo, cvchrcuentabenef, dmonto_pago, iintrefnumerica, cclave_devol )
            INTO cFolioDev;
        
            INSERT INTO tbl_coas_rec_devols_proc VALUES
            ( pNombreArchivo, cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, cclave_devol, cFolioDev, current );
              
            COMMIT WORK;
            LET iTransacc = 0;
        ELSE
            LET cFolioDev = '0';
            
            INSERT INTO tbl_coas_rec_devols_proc VALUES
            ( pNombreArchivo, cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, cclave_devol, cFolioDev, current );
            
            COMMIT WORK;
            LET iTransacc = 0;
        END IF;
          
        LET cfolio = ''; LET ctipo_pago = ''; LET cclave_particip = ''; LET cmonto_pago = ''; LET cfolio_pago = '';
        LET cclave_rastreo = ''; LET cclave_devol = ''; LET cFolioDev = ''; LET dmonto_pago = 0.00; 
    END FOREACH; 
    
    
    -- // PROCESA LAS DEVOLUCIONES TIPO 16
    FOREACH WITH HOLD
        SELECT folio, tipo_pago, clave_particip, monto_pago, folio_pago, clave_rastreo, folio_ori, folio_pago_ori, fecha_ori, cve_rastreo_ori, 
               ref_num_ori, tpo_cta_ord_ori, cta_ord_pag_ori, clave_devol, concepto_ori, monto_pago_ori, monto_intereses
          INTO cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, cfolio_ori, cfolio_pago_ori, cfecha_ori, ccve_rastreo_ori,
               cref_num_ori, ctpo_cta_ord_ori, ccta_ord_pag_ori, cclave_devol, cconcepto_ori, cmonto_pago_ori, cmonto_intereses
          FROM tbl_coas_rec_devols16 
          
        BEGIN WORK;
        LET iTransacc = 1;
        
        LET dmonto_pago = cmonto_pago_ori;
        LET dmonto_pago_ints = cmonto_intereses;
        
        EXECUTE PROCEDURE spei_recextemporanea( cclave_rastreo, ccta_ord_pag_ori, dmonto_pago, dmonto_pago_ints, cref_num_ori, cconcepto_ori, cfolio_ori )
        INTO cFolioDev;
        
        INSERT INTO tbl_coas_rec_devols16_proc VALUES
        ( pNombreArchivo, cfolio, ctipo_pago, cclave_particip, cmonto_pago, cfolio_pago, cclave_rastreo, cfolio_ori, cfolio_pago_ori, cfecha_ori, 
          ccve_rastreo_ori, cref_num_ori, ctpo_cta_ord_ori, ccta_ord_pag_ori, cclave_devol, cconcepto_ori, cmonto_pago_ori, cmonto_intereses, cFolioDev, current );
          
        COMMIT WORK;
        LET iTransacc = 0;
          
        LET cfolio = ''; LET ctipo_pago = ''; LET cclave_particip = ''; LET cmonto_pago = ''; LET cfolio_pago = '';
        LET cclave_rastreo = ''; LET cfolio_ori = ''; LET cfolio_pago_ori = ''; LET cfecha_ori = ''; LET ccve_rastreo_ori = '';
        LET cref_num_ori = ''; LET ctpo_cta_ord_ori = ''; LET ccta_ord_pag_ori = ''; LET cclave_devol = ''; LET cconcepto_ori = '';
        LET cmonto_pago_ori = ''; LET cmonto_intereses = ''; LET cFolioDev = ''; LET dmonto_pago = 0.00; LET dmonto_pago_ints = 0.00; 
    END FOREACH; 
    
    
    RETURN vcodret, vcodret2, vcodret3; 
	
    END; 
    
END PROCEDURE;