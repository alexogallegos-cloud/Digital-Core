CREATE PROCEDURE "informix".movinver(pempresa CHAR(3))
RETURNING CHAR(5);
    
    DEFINE vcodret      CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vsqlerr      INTEGER;
    DEFINE visamerr     INTEGER;
    DEFINE vdescerr     CHAR(50);
    DEFINE vrow         INTEGER; 
    DEFINE vsucursal    CHAR(4);
    DEFINE vcuenta      CHAR(20);
    DEFINE vmonto       MONEY(14,2);
    DEFINE vdivisa      CHAR(2);
    DEFINE vstatus      CHAR(1);
    DEFINE vusuario     CHAR(8);
    DEFINE vtipo_mov    CHAR(1);
    DEFINE vfolio_suc   CHAR(16);
    DEFINE vtransacc    CHAR(4);
    DEFINE vreferencia  CHAR(40);
    DEFINE vfecha_hoy   DATE;
    DEFINE vtranret     CHAR(4);
    DEFINE vfechapli    DATE;
    DEFINE vsdodisp     MONEY(14,2);
    DEFINE vimpcar      MONEY(14,2);
    DEFINE v_size       SMALLINT;
    DEFINE vtransaccion INTEGER;
    DEFINE vexiste      SMALLINT;
    
    LET vcodret      = '000';
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET vsqlerr      = 0;
    LET visamerr     = 0;
    LET vdescerr     = '';
    LET vrow         = 0;
    LET vsucursal    = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vdivisa      = '';
    LET vstatus      = '';
    LET vtipo_mov    = '';
    LET vfolio_suc   = '';
    LET vtransacc    = '';
    LET vreferencia  = '';
    LET vfecha_hoy   = '';
    LET vtranret     = '';
    LET vfechapli    = '';
    LET vsdodisp     = 0.00;
    LET vimpcar      = 0.00;
    LET vtransaccion = 0;
    LET v_size       = LENGTH(user);
    LET vusuario     = SUBSTR(user,v_size-7, v_size);
    LET vexiste      = 0;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/movinver.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN vcodret;
        END IF
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH resume;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/movinver.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT fecha_hoy 
      INTO vfecha_hoy 
      FROM sc_fechas 
     WHERE empresa = pempresa;
    
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_movinver ix212_2)}
               a.rowid, a.sucursal, a.cuenta, a.tipo_mov, a.monto, a.divisa, a.transacc, a.referencia
          INTO vrow, vsucursal, vcuenta, vtipo_mov, vmonto, vdivisa, vtransacc, vreferencia
          FROM sc_movinver a, 
               sc_maechq b
         WHERE a.cuenta = b.cuenta
           AND a.procesado != 'S'
           AND b.status_cta in('1','3','4','5')
         ORDER BY a.referencia, a.transacc
        
        LET vcodret = '000';
        LET vstatus = '';
        LET vfolio_suc = current hour to fraction(3);
        LET vfolio_suc = vusuario||vfolio_suc[1,2]||vfolio_suc[4,5]||vfolio_suc[7,8]||vfolio_suc[10,11];
        
        SELECT status_cta 
          INTO vstatus 
          FROM sc_maechq
         WHERE cuenta = vcuenta;
        
        IF vstatus = '3' THEN
            UPDATE sc_maechq
               SET status_cta = '1'
             WHERE cuenta = vcuenta;
        END IF
        
        IF vtipo_mov = 'C' THEN
            CALL cargo_ref(pempresa, vsucursal, vusuario, vtransacc, "0000", vfolio_suc, vcuenta, 0, vmonto, vdivisa, vreferencia, "", "")
            RETURNING vcodret, vtranret, vfechapli, vsdodisp, vimpcar;
        ELIF vtipo_mov = 'A' THEN
            CALL abono_ref(pempresa, vsucursal, vusuario, vtransacc, "0000", vfolio_suc, vcuenta,0, vmonto, vmonto, 0, 0, 0, vdivisa, vreferencia, "", "")
            RETURNING vcodret;
        END IF;
        
        IF vstatus = '3' THEN
            UPDATE sc_maechq
               SET status_cta = '3'
             WHERE cuenta = vcuenta;
        END IF
        
        IF vcodret = '000' THEN
            UPDATE sc_movinver
               SET procesado = 'S',
                   codigo_retorno = vcodret,
                   fecha_proceso = vfecha_hoy
             WHERE rowid = vrow;
             
            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                EXIT FOREACH;
            END IF;
        ELSE
            UPDATE sc_movinver
               SET procesado = 'N',
                   codigo_retorno = vcodret,
                   fecha_proceso = vfecha_hoy
             WHERE rowid = vrow;
            
            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                EXIT FOREACH;
            END IF;
        END IF
    END FOREACH
    
    FOREACH 
        SELECT {+INDEX(sc_movinver ix212_2)}
               TRIM(cuenta), monto, transacc, TRIM(referencia)
          INTO vcuenta, vmonto, vtransacc, vreferencia
          FROM sc_movinver
         WHERE cuenta >= '10000005016'
           AND procesado <> 'S'
           AND codigo_retorno = '000'
           AND fecha_apli = vfecha_hoy
           AND (fecha_proceso is null or fecha_proceso = '')
           
        SELECT COUNT(*)
          INTO vexiste
          FROM sc_movdia
         WHERE cuenta = vcuenta
           AND transacc = vtransacc
           AND cancelad <> 'S'
           AND referencia = vreferencia
           AND monto_tot = vmonto;
           
        IF vexiste > 0 THEN
            UPDATE sc_movinver
               SET procesado = 'S',
                   fecha_proceso = vfecha_hoy
             WHERE cuenta = vcuenta
               AND transacc = vtransacc
               AND monto = vmonto
               AND referencia = vreferencia
               AND fecha_apli = vfecha_hoy;
        END IF;
        
        LET vcuenta     = '';
        LET vmonto      = 0.00;
        LET vtransacc   = '';
        LET vreferencia = '';
        LET vexiste     = 0;
    END FOREACH;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    LET vcodret = '000';
    
    RETURN vcodret;
    
    END
    
END PROCEDURE;