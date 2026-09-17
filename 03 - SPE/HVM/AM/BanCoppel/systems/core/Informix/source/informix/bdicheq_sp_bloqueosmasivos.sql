CREATE PROCEDURE "informix".sp_bloqueosmasivos(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(40);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(40);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vusuario         CHAR(8);
    DEFINE vfecha           CHAR(13);
    
    DEFINE vcuenta          CHAR(20);
    DEFINE vstatus          CHAR(1);
    DEFINE vclave_bloq      CHAR(2);
    DEFINE vopcion_bloq     INTEGER;
    DEFINE vcve_area        CHAR(2);
    DEFINE vcod_area        CHAR(1);
    DEFINE vcve_tipobloq    CHAR(2);
    DEFINE vcod_tipobloq    CHAR(1);
    DEFINE vmonto           MONEY(18,2);    
    DEFINE vusuariobloq     CHAR(8);
    DEFINE vcodret_bloqueo  CHAR(5);
    DEFINE vclave_bloqueo   CHAR(5);
    DEFINE vdescripcion     CHAR(40);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET vcodret3      = 'PROCESO TERMINADO SATISFACTORIAMENTE';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET desc_err      = '';
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcomienza     = -1;
    LET ven_transacc  = 0;
    
    LET vfecha_hoy   = '';
    LET vsql         = '';
    LET vstmt        = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vusuario     = 'informix';
    LET vfecha       = '';
    
    LET vcuenta         = '';
    LET vstatus         = '';
    LET vclave_bloq     = '';
    LET vopcion_bloq    = 0;
    LET vcve_area       = '';
    LET vcod_area       = '';
    LET vcve_tipobloq   = '';
    LET vcod_tipobloq   = '';
    LET vmonto          = 0.00;
    LET vusuariobloq    = '';
    LET vcodret_bloqueo = '';
    LET vclave_bloqueo  = '';
    LET vdescripcion    = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_bloqueosmasivos.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_bloqueosmasivos.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // TABLA DE CUENTAS POR BLOQUEAR
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxbloquear') THEN
        DROP TABLE "informix".ctasxbloquear;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxbloquear
      (
        cuenta          char(20)    not null,
        clave           char(2)     not null,
        opcion          integer     not null,
        cve_area        char(2)     not null,
        cod_area        char(1)     not null,
        cve_tipobloq    char(2)     not null,
        cod_tipobloq    char(1)     not null,
        monto           money(18,2),
        usuario         char(8)     not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxbloq ON "informix".ctasxbloquear(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ctasxbloquear.unl DELIMITER ''","'' INSERT INTO ctasxbloquear" > /resplogifx/conciliachq/ctasbloq.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasbloq.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxbloquear;
    
    -- // TABLA DE REPORTE DE CUENTAS POR BLOQUEAR
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'repctasxbloquear') THEN
        DROP TABLE "informix".repctasxbloquear;
    END IF;
    
    CREATE RAW TABLE "informix".repctasxbloquear
      (
        cuenta          char(20)    not null,
        codret          char(5)     not null,
        descripcion     char(40)    
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_repctaxbloq ON "informix".repctasxbloquear(cuenta) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE repctasxbloquear;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = vusuario||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta, clave, opcion, cve_area, cod_area, cve_tipobloq, cod_tipobloq, monto, usuario
          INTO vcuenta, vclave_bloq, vopcion_bloq, vcve_area, vcod_area, vcve_tipobloq, vcod_tipobloq, vmonto, vusuariobloq
          FROM ctasxbloquear
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        SELECT status_cta
          INTO vstatus
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        IF vstatus in ('1','4') THEN
            
            CALL bloqueo_cta(pempresa, vcuenta, vmonto, vclave_bloq, vopcion_bloq, vfecha_hoy, vusuariobloq, '11111', vcve_area, vcod_area, vcve_tipobloq, vcod_tipobloq)
            RETURNING vcodret_bloqueo, vclave_bloqueo;
            
            IF vcodret_bloqueo = '000' THEN
                LET vdescripcion = 'CUENTA BLOQUEADA SATISFACTORIAMENTE';
                LET vcontador2 = vcontador2 + 1;
            ELSE
                SELECT descripcion
                  INTO vdescripcion
                  FROM bdinteg:si_codret
                 WHERE codigo_retorno = vcodret_bloqueo
                   AND sistema = '01';
            END IF;
        
        ELIF vstatus = '2' THEN
        
            LET vcodret_bloqueo = '200';
            LET vdescripcion = 'CUENTA CANCELADA';
        
        ELIF vstatus = '3' THEN
        
            LET vcodret_bloqueo = '303';
            LET vdescripcion = 'CUENTA BLOQUEADA';
        
        ELIF vstatus is null OR vstatus = '' THEN
        
            LET vcodret_bloqueo = '100';
            LET vdescripcion = 'CUENTA NO EXISTE';
        
        END IF;
        
        INSERT INTO repctasxbloquear VALUES(vcuenta, vcodret_bloqueo, vdescripcion);
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta         = '';
        LET vstatus         = '';
        LET vclave_bloq     = '';
        LET vopcion_bloq    = 0;
        LET vcve_area       = '';
        LET vcod_area       = '';
        LET vcve_tipobloq   = '';
        LET vcod_tipobloq   = '';
        LET vmonto          = 0.00;
        LET vusuariobloq    = '';
        LET vcodret_bloqueo = '';
        LET vclave_bloqueo  = '';
        LET vdescripcion    = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    LET vfecha = TO_CHAR(vfecha_hoy, '%d%m%Y') ||'_'|| vhora[1,2] || vhora[4,5];
    
    -- // GENERA EL ARCHIVO DE TODAS LAS CUENTAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/repctasbloq_'||vfecha||'.txt '||
               ' SELECT * FROM repctasxbloquear ORDER BY cuenta" > /resplogifx/conciliachq/repctasbloq.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    --- LET vstmt = "dbaccess bdicheq /resplogifx/conciliachq/repctasbloq.sql"; 
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/repctasbloq.sql"; 
    SYSTEM vstmt;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;