CREATE PROCEDURE "informix".sp_rptctassincarat(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50);
     
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcontador    INTEGER;
    DEFINE ven_transacc SMALLINT;
    DEFINE vcomienza    SMALLINT;
    
    DEFINE vfecha_hoy   DATE;
    DEFINE vpri_dia_mes DATE;
    DEFINE vfecha_ini   DATE;
    DEFINE vfecha_fin   DATE;
    
    DEFINE vcuenta      CHAR(20);
    DEFINE vprod        CHAR(4);
    DEFINE vnumcte      CHAR(20);
    DEFINE vnombre      CHAR(104);
    DEFINE vfecha_alta  DATE;
    DEFINE vexiste_caratula SMALLINT;
    
    DEFINE vsql         CHAR(500);
    DEFINE vaniomes     CHAR(6);

    LET vcodret1     = "000";               
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err      = 0;                   
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador    = 0;                   
    LET ven_transacc = 0;                   
    LET vcomienza    = -1;  
       
    LET vfecha_hoy   = ''; 
    LET vpri_dia_mes = '';
    LET vfecha_ini   = '';
    LET vfecha_fin   = '';
    
    LET vcuenta     = '';
    LET vprod       = '';
    LET vnumcte     = '';
    LET vnombre     = '';
    LET vfecha_alta = '';
    LET vexiste_caratula = 0;
    
    LET vsql = '';
    LET vaniomes = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptctassincarat.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptctassincarat.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy, pri_dia_mes
      INTO vfecha_hoy, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vfecha_ini = vpri_dia_mes - 1 UNITS MONTH;
    LET vfecha_fin = vpri_dia_mes - 1 UNITS DAY;
    
    -- // TABLA PARA REPORTE
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_ctassincaratula') THEN
        DROP TABLE "informix".sc_ctassincaratula;        
    END IF;
    
    CREATE TABLE "informix".sc_ctassincaratula
    ( 
      cuenta     CHAR(20),
      producto   CHAR(4), 
      cliente    CHAR(20),
      nombre     CHAR(104),
      fecha_alta DATE
    ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctassincarat ON "informix".sc_ctassincaratula(cuenta);
    UPDATE STATISTICS MEDIUM FOR TABLE sc_ctassincaratula;

    FOREACH WITH HOLD
        SELECT noc.cuenta, chq.producto, chq.num_cte, noc.fecha_alta
          INTO vcuenta, vprod, vnumcte, vfecha_alta
          FROM sc_maenoc noc,
               sc_maechq chq
         WHERE noc.empresa = pempresa
           AND noc.cuenta = chq.cuenta
           AND noc.fecha_alta BETWEEN vfecha_ini AND vfecha_fin
           AND chq.empresa = noc.empresa
           AND chq.cuenta = noc.cuenta
           AND chq.status_cta <> '2'
           AND chq.imp_chq_rem = 0.00
          
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
        END IF;
        
        SELECT TRIM(nombre1)||' '||TRIM(nombre2)||''||TRIM(apell_paterno)||''||TRIM(apell_materno)
          INTO vnombre
          FROM bdinteg:si_cliente
         WHERE numcte = vnumcte; 
        
        -- // ACCESO A LA INSTANCIA DE IMAGENES (PRODUCCION)
        SELECT COUNT(*)
          INTO vexiste_caratula
          FROM bdidigital@coppelimg_tcp:dg_expediente
         -- WHERE empresa = pempresa
         WHERE cliente = vnumcte
           AND cuenta = vcuenta
           AND producto = vprod
           AND cod_docto = '0039';
        
        -- // ACCESO A LA INSTANCIA DE IMAGENES (DESARROLLO - 62)
        /*
        SELECT COUNT(*)
          INTO vexiste_caratula
          FROM bdidigital@coppelimgsm_tcp:dg_expediente
         --WHERE empresa = pempresa
         WHERE cliente = vnumcte
           AND cuenta = vcuenta
           AND producto = vprod
           AND cod_docto = '0039';
        */
           
        IF vexiste_caratula = 0 THEN
            INSERT INTO sc_ctassincaratula(cuenta, producto, cliente, nombre, fecha_alta)
            VALUES(vcuenta, vprod, vnumcte, vnombre, vfecha_alta);
        END IF;
        
        LET vcontador = vcontador + 1;
        
        IF vcontador >= 2500 THEN
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
           
        LET vcuenta = '';
        LET vprod = '';
        LET vnumcte = '';
        LET vnombre = '';
        LET vexiste_caratula = 0;
        LET vfecha_alta = '';
    END FOREACH;
    
    IF vcontador > 0 THEN
        LET vcontador = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_ctassincaratula;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vaniomes = TO_CHAR(vfecha_fin, '%Y%m');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/rptctassincaratulas_'||vaniomes||'.csv '||
               ' SELECT * FROM sc_ctassincaratula ORDER BY cuenta" > /resplogifx/conciliachq/ctassincarat.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctassincarat.sql"; 
    SYSTEM vsql;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3;
    
END PROCEDURE;