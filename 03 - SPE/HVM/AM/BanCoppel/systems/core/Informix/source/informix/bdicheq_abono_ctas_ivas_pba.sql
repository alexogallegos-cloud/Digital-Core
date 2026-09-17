CREATE PROCEDURE "informix".abono_ctas_ivas_pba(pempresa CHAR(3))

    RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcodretabono     CHAR(5);
    
    DEFINE vsql             CHAR(200);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    DEFINE vmaxsec          SMALLINT;
    DEFINE vtarjeta         CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2);    
    DEFINE vtransacc        CHAR(4);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vsucursal        CHAR(4);  
    
    LET vcodret1	 = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcodretabono = '000';
    
    LET vsql         = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vmincta      = '';
    LET vmaxcta      = '';
    LET vmaxsec      = 0;
    LET vtarjeta     = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vtransacc    = '';
    LET vdescripcion = '';
    LET vsucursal    = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/abono_ctas_ivas.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/abono_ctas_ivas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum > 0 AND tabname = 'ctasxabonar') THEN
        DROP TABLE "informix".ctasxabonar;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxabonar
      (
        tarjeta     char(20)    not null,
        monto       money(14,2) not null,
        transacc    char(4)     not null,
        descripcion char(40)    not null
      )
    EXTENT SIZE 32 NEXT SIZE 64 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxabon ON "informix".ctasxabonar(tarjeta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ivasxabonar.unl DELIMITER ''","'' INSERT INTO ctasxabonar" > /resplogifx/conciliachq/ctasxabon.sql';
    SYSTEM vsql;
    LET vsql = '';
    -- LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxabon.sql';
    LET vsql = 'dbaccess bdicheq /resplogifx/conciliachq/ctasxabon.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxabonar;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    SELECT {+FULL} MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_maechq;
    
    FOREACH WITH HOLD
        SELECT {+FULL} tarjeta, monto, transacc, descripcion
          INTO vtarjeta, vmonto, vtransacc, vdescripcion
          FROM ctasxabonar
        
        IF (vcomienza = -1) THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET ven_transacc = 1;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        SELECT {+INDEX(sc_tarjeta ix_tarjeta2)} MAX(secuencia) 
          INTO vmaxsec
          FROM sc_tarjeta 
         WHERE empresa = pempresa 
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND num_tarjeta = vtarjeta 
           AND status_tar = 'A';
        
        SELECT {+INDEX(sc_tarjeta ix_tarjeta2)} cuenta
          INTO vcuenta
          FROM sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND num_tarjeta = vtarjeta
           AND status_tar = 'A'
           AND secuencia = vmaxsec;
        
        SELECT {+INDEX(sc_maechq idx_maechq1)} sucursal
          INTO vsucursal
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        CALL abono_ref(pempresa,vsucursal,"informix",vtransacc,"0000",vfolio,vcuenta,0,vmonto,vmonto,0,0,0,"01",vdescripcion," ","informix")
        RETURNING vcodretabono;
        
        IF vcodretabono = '000' THEN
            LET vcontador2 = vcontador2 + 1;
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
            BEGIN WORK;
        END IF;
        
        LET vmaxsec      = 0;
        LET vtarjeta     = '';
        LET vmonto       = 0.00;
        LET vtransacc    = '';
        LET vdescripcion = '';
        LET vcuenta      = '';
        LET vsucursal    = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;