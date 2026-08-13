CREATE PROCEDURE "informix".sp_obtinfretirosctas( pempresa char(3), pfechaini DATE, pfechafin DATE )
RETURNING CHAR(5), CHAR(5), INTEGER;
     
    DEFINE vcodret1             char(5);
    DEFINE vcodret2             char(5);
    DEFINE vsqlerr              integer;
    DEFINE isam_err             integer;
    DEFINE vcontador1           integer;
    DEFINE vcontador2           integer;
    DEFINE ven_transacc         smallint;
    DEFINE vcomienza            smallint;
    
    DEFINE vperiodo             char(6);
    DEFINE vfecha_hoy           date;
    DEFINE vfechconmovhis       char(10);
    DEFINE vfechconmovhisold    char(10);
    DEFINE vcuenta              char(20);
    DEFINE vproducto            char(4);
    DEFINE vexiste              integer;
    DEFINE vregs                integer;
    DEFINE vmonto               decimal(18,2);
    DEFINE vatm                 smallint;
    DEFINE vpos                 smallint;
    DEFINE vspei                smallint;
    DEFINE vventana             smallint;
    DEFINE vno_tarj_tit         smallint;
    DEFINE vno_tarj_adic        smallint;
    
    LET vcodret1     = "000";               
    LET vcodret2     = '000';
    LET vsqlerr      = 0;                   
    LET isam_err     = 0;
    LET vcontador1   = 0;                   
    LET vcontador2   = 0;
    LET ven_transacc = 0;                   
    LET vcomienza    = -1;  
       
    LET vperiodo       = '';
    LET vfecha_hoy     = ''; 
    LET vfechconmovhis = '';
    LET vfechconmovhisold = '';
    LET vcuenta        = '';  
    LET vproducto      = '';
    LET vexiste        = 0;  
    LET vregs          = 0;
    LET vmonto         = 0.00;
    LET vatm           = 0;
    LET vpos           = 0;
    LET vspei          = 0;
    LET vventana       = 0; 
    LET vno_tarj_tit   = 0;
    LET vno_tarj_adic  = 0;
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtinfretirosctas.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtinfretirosctas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET vperiodo = TO_CHAR(pfechafin, '%Y%m');
    
    /* CREA TABLAS DE TRABAJO TEMPORALES */
    -- // RETIROS ATM
    CREATE TEMP TABLE tmp_retiros_atm( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retatm ON tmp_retiros_atm(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atm;
    
    INSERT INTO tmp_retiros_atm VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atm VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atm VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atm VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atm VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atm VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atm VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atm VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS POS
    CREATE TEMP TABLE tmp_retiros_pos( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retpos ON tmp_retiros_pos(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_pos;
    
    INSERT INTO tmp_retiros_pos VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_pos VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_pos VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_pos VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_pos VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_pos VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_pos VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_pos VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS SPEI
    CREATE TEMP TABLE tmp_retiros_spei( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retspei ON tmp_retiros_spei(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_spei;
    
    INSERT INTO tmp_retiros_spei VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_spei VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_spei VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_spei VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_spei VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_spei VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_spei VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_spei VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS VENTANILLA
    CREATE TEMP TABLE tmp_retiros_ventanilla( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retvent ON tmp_retiros_ventanilla(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_ventanilla;
    
    INSERT INTO tmp_retiros_ventanilla VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_ventanilla VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_ventanilla VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_ventanilla VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_ventanilla VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_ventanilla VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_ventanilla VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_ventanilla VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS ATM Y POS
    CREATE TEMP TABLE tmp_retiros_atmpos( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retatmpos ON tmp_retiros_atmpos(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmpos;
    
    INSERT INTO tmp_retiros_atmpos VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmpos VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmpos VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmpos VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmpos VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmpos VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmpos VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmpos VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS ATM Y SPEI
    CREATE TEMP TABLE tmp_retiros_atmspei( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retatmspei ON tmp_retiros_atmspei(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmspei;
    
    INSERT INTO tmp_retiros_atmspei VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmspei VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmspei VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmspei VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmspei VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmspei VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmspei VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmspei VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS ATM Y VENTANILLA
    CREATE TEMP TABLE tmp_retiros_atmvent( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_ctasatmvent ON tmp_retiros_atmvent(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmvent;
    
    INSERT INTO tmp_retiros_atmvent VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmvent VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmvent VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmvent VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmvent VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmvent VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmvent VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmvent VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS POS Y SPEI
    CREATE TEMP TABLE tmp_retiros_posspei( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retposspei ON tmp_retiros_posspei(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_posspei;
    
    INSERT INTO tmp_retiros_posspei VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspei VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspei VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspei VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspei VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspei VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspei VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspei VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS POS Y VENTANILLA
    CREATE TEMP TABLE tmp_retiros_posvent( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retposvent ON tmp_retiros_posvent(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_posvent;
    
    INSERT INTO tmp_retiros_posvent VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posvent VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posvent VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posvent VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posvent VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posvent VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posvent VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posvent VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS SPEI Y VENTANILLA
    CREATE TEMP TABLE tmp_retiros_speivent( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retspeivent ON tmp_retiros_speivent(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_speivent;
    
    INSERT INTO tmp_retiros_speivent VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_speivent VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_speivent VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_speivent VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_speivent VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_speivent VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_speivent VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_speivent VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS ATM, POS Y SPEI
    CREATE TEMP TABLE tmp_retiros_atmposspei( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retatmposspei ON tmp_retiros_atmposspei(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmposspei;
    
    INSERT INTO tmp_retiros_atmposspei VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspei VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspei VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspei VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspei VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspei VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspei VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspei VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS ATM, POS Y VENTANILLA
    CREATE TEMP TABLE tmp_retiros_atmposvent( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retatmposvent ON tmp_retiros_atmposvent(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmposvent;
    
    INSERT INTO tmp_retiros_atmposvent VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposvent VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposvent VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposvent VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposvent VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposvent VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposvent VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposvent VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS POS, SPEI Y VENTANILLA
    CREATE TEMP TABLE tmp_retiros_posspeivent( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retposspeivent ON tmp_retiros_posspeivent(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_posspeivent;
    
    INSERT INTO tmp_retiros_posspeivent VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspeivent VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspeivent VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspeivent VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspeivent VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspeivent VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspeivent VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_posspeivent VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // RETIROS ATM, POS, SPEI Y VENTANILLA
    CREATE TEMP TABLE tmp_retiros_atmposspeivent( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_retatmposspeivent ON tmp_retiros_atmposspeivent(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmposspeivent;
    
    INSERT INTO tmp_retiros_atmposspeivent VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspeivent VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspeivent VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspeivent VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspeivent VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspeivent VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspeivent VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_retiros_atmposspeivent VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // SIN RETIROS
    CREATE TEMP TABLE tmp_sin_retiros( 
        periodo char(6), 
        producto char(4), 
        no_cuentas integer, 
        no_tarj_tit integer,
        no_tarj_adic integer,
        no_operaciones integer, 
        importe money(18,2)
    ) WITH NO LOG;
    CREATE INDEX idx_sinret ON tmp_sin_retiros(periodo, producto) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_sin_retiros;
    
    INSERT INTO tmp_sin_retiros VALUES(vperiodo, '2000', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_sin_retiros VALUES(vperiodo, '1800', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_sin_retiros VALUES(vperiodo, '1900', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_sin_retiros VALUES(vperiodo, '1500', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_sin_retiros VALUES(vperiodo, '1300', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_sin_retiros VALUES(vperiodo, '1700', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_sin_retiros VALUES(vperiodo, '1400', 0, 0, 0, 0, 0.00);
    INSERT INTO tmp_sin_retiros VALUES(vperiodo, '2500', 0, 0, 0, 0, 0.00);
    
    -- // OBTIENE PARAMETROS
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    SELECT valor 
      INTO vfechconmovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor 
      INTO vfechconmovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    -- // CREA TABLA TEMPORAL DE MOVS HISTORICOS
    SELECT {+INDEX(sc_movhis_old idx_movhisnew6_old)}
           num_serial, transacc, producto, cuenta, monto_tot
      FROM sc_movhis_old
     WHERE fech_alt BETWEEN pfechaini AND pfechafin
       AND fech_alt >= vfechconmovhisold
       AND fech_alt < vfechconmovhis
       AND cancelad <> 'S'
       AND producto IN('2000','1800','1900','1500','1300','1700','1400','2500')
    UNION ALL
    SELECT {+INDEX(sc_movhis idx_movhisnew6)}
           num_serial, transacc, producto, cuenta, monto_tot
      FROM sc_movhis
     WHERE fech_alt BETWEEN pfechaini AND pfechafin
       AND fech_alt >= vfechconmovhis
       AND cancelad <> 'S'
       AND producto IN('2000','1800','1900','1500','1300','1700','1400','2500')
    INTO TEMP tmp_movhis WITH NO LOG;
    CREATE INDEX idx_tmpmovhis ON tmp_movhis(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movhis;
    
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta, producto
          INTO vcuenta, vproducto
          FROM tmp_movhis
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        SELECT count(*)
          INTO vexiste
          FROM tmp_movhis
         WHERE cuenta = vcuenta
           AND transacc in('0800','0871','0872','0873','0830','0887','0274','0223'); 
           
        IF vexiste = 0 THEN
        
            SELECT COUNT(*), SUM(monto_tot)
              INTO vregs, vmonto
              FROM tmp_movhis
             WHERE cuenta = vcuenta;
             
            SELECT COUNT(*)
              INTO vno_tarj_tit
              FROM sc_tarjeta
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND tipo_tarjeta = 'T'
               AND status_tar = 'A'
               AND secuencia = ( SELECT MAX(secuencia)
                                   FROM sc_tarjeta 
                                  WHERE empresa = pempresa
                                    AND cuenta = vcuenta
                                    AND tipo_tarjeta = 'T'
                                    AND status_tar = 'A');
               
            SELECT COUNT(*)
              INTO vno_tarj_adic
              FROM sc_tarjeta
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND tipo_tarjeta = 'A'
               AND status_tar = 'A'
               AND secuencia = ( SELECT MAX(secuencia)
                                   FROM sc_tarjeta 
                                  WHERE empresa = pempresa
                                    AND cuenta = vcuenta
                                    AND tipo_tarjeta = 'A'
                                    AND status_tar = 'A');
                                   
            UPDATE tmp_sin_retiros
               SET no_cuentas = no_cuentas + 1,
                   no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                   no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                   no_operaciones = no_operaciones + vregs,
                   importe = importe + vmonto
             WHERE periodo = vperiodo
               AND producto = vproducto;
           
        ELSE
        
            IF EXISTS ( SELECT transacc FROM tmp_movhis WHERE cuenta = vcuenta AND transacc IN('0800','0871','0872','0873') ) THEN
                LET vatm = 1;
            END IF;
            
            IF EXISTS ( SELECT transacc FROM tmp_movhis WHERE cuenta = vcuenta AND transacc IN('0830','0887') ) THEN
                LET vpos = 1;
            END IF;
            
            IF EXISTS ( SELECT transacc FROM tmp_movhis WHERE cuenta = vcuenta AND transacc IN('0274') ) THEN
                LET vspei = 1;
            END IF;

            IF EXISTS ( SELECT transacc FROM tmp_movhis WHERE cuenta = vcuenta AND transacc IN('0223') ) THEN
                LET vventana = 1;
            END IF;
        
            IF vatm = 1 AND vpos = 0 AND vspei = 0 AND vventana = 0 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0800','0871','0872','0873');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_atm
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 0 AND vpos = 1 AND vspei = 0 AND vventana = 0 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0830','0887');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_pos
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 0 AND vpos = 0 AND vspei = 1 AND vventana = 0 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0274');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_spei
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 0 AND vpos = 0 AND vspei = 0 AND vventana = 1 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0223');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_ventanilla
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 1 AND vpos = 1 AND vspei = 0 AND vventana = 0 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0800','0871','0872','0873','0830','0887');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_atmpos
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 1 AND vpos = 0 AND vspei = 1 AND vventana = 0 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0800','0871','0872','0873','0274');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_atmspei
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 1 AND vpos = 0 AND vspei = 0 AND vventana = 1 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0800','0871','0872','0873','0223');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_atmvent
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 0 AND vpos = 1 AND vspei = 1 AND vventana = 0 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0830','0887','0274');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_posspei
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 0 AND vpos = 1 AND vspei = 0 AND vventana = 1 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0830','0887','0223');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_posvent
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 0 AND vpos = 0 AND vspei = 1 AND vventana = 1 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0274','0223');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_speivent
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 1 AND vpos = 1 AND vspei = 1 AND vventana = 0 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0800','0871','0872','0873','0830','0887','0274');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_atmposspei
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 1 AND vpos = 1 AND vspei = 0 AND vventana = 1 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0800','0871','0872','0873','0830','0887','0223');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_atmposvent
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 0 AND vpos = 1 AND vspei = 1 AND vventana = 1 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0830','0887','0274','0223');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_posspeivent
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
            IF vatm = 1 AND vpos = 1 AND vspei = 1 AND vventana = 1 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO vregs, vmonto
                  FROM tmp_movhis 
                 WHERE cuenta = vcuenta
                   AND transacc IN('0800','0871','0872','0873','0830','0887','0274','0223');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_tit
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'T'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'T'
                                        AND status_tar = 'A');
                   
                SELECT COUNT(*)
                  INTO vno_tarj_adic
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tarjeta = 'A'
                   AND status_tar = 'A'
                   AND secuencia = ( SELECT MAX(secuencia)
                                       FROM sc_tarjeta 
                                      WHERE empresa = pempresa
                                        AND cuenta = vcuenta
                                        AND tipo_tarjeta = 'A'
                                        AND status_tar = 'A');

                UPDATE tmp_retiros_atmposspeivent
                   SET no_cuentas = no_cuentas + 1,
                       no_tarj_tit = no_tarj_tit + vno_tarj_tit,
                       no_tarj_adic = no_tarj_adic + vno_tarj_adic,
                       no_operaciones = no_operaciones + vregs,
                       importe = importe + vmonto
                 WHERE periodo = vperiodo
                   AND producto = vproducto; 
            END IF;
            
        END IF;        
                
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;

        IF (vcontador2 >= 7500) THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta   = '';
        LET vproducto = '';
        LET vexiste   = '';
        LET vregs     = 0;
        LET vmonto    = 0.00;
        LET vatm      = 0;
        LET vpos      = 0;
        LET vspei     = 0;
        LET vventana  = 0; 
        LET vno_tarj_tit   = 0;
        LET vno_tarj_adic  = 0;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atm;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_pos;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_spei;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_ventanilla;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmpos;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmspei;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmvent;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_posspei;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_posvent;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_speivent;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmposspei;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmposvent;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_posspeivent;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_retiros_atmposspeivent;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_sin_retiros;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;