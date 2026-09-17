CREATE PROCEDURE "informix".sp_consulta_autorizaciones_hcbopt(pCliente CHAR(20))     
RETURNING   CHAR(6) AS Cod_ret,
            CHAR(1) AS ChkBuro,
            CHAR(3) AS ChkAvisoPrivacidad,
            CHAR(3) AS ChkINE,
            CHAR(3) AS ChkCompartirGC,
            CHAR(3) AS status_EdoCta,
			CHAR(3) AS gran_data;
      
    -- ****************************************************************************
    -- *                        DEFINICION DE VARIABLES                           *
    -- ****************************************************************************

    DEFINE cCod_ret    CHAR(6);
    DEFINE iSqlErr    INTEGER;    
    
    DEFINE cChkBuro               CHAR(1);
    DEFINE cChkAvisoPrivacidad    CHAR(3);
    DEFINE cChkINE                CHAR(3);
    DEFINE cChkCompartirGC        CHAR(3);
    DEFINE cChkEstadoCuenta       CHAR(3);
    DEFINE status_EdoCta          CHAR(3);
	DEFINE gran_data              CHAR(3);
    
    -- ****************************************************************************
    -- *                        ASIGNACION DE VARIABLES                           *
    -- ****************************************************************************

    LET iSqlErr                = 0;
    LET cCod_ret               = '000000';    

    LET cChkBuro              = '0';
    LET cChkAvisoPrivacidad   = '000';
    LET cChkINE               = '000';
    LET cChkCompartirGC       = '000';
    LET cChkEstadoCuenta      = '000';
    LET status_EdoCta         = '000';
	LET gran_data             = '001';

    BEGIN
    
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCod_ret = iSqlErr;
                RETURN cCod_ret, NVL(cChkBuro,''),NVL(cChkAvisoPrivacidad,''),NVL(cChkINE,''),NVL(cChkCompartirGC,''),NVL(status_EdoCta,''),NVL(gran_data,'');
            END IF;
        END EXCEPTION;
    
        --SET DEBUG FILE TO "/home/sysifx/sp_consulta_autorizaciones_hcbopt.out";
        --TRACE ON;
    
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        
        -- ****************************************************************************
        -- *                        PROGRAMA PRINCIPAL                                *
        -- ****************************************************************************
        
        --Consulta a las Sociedades de InformaciÃ³n Crediticia
        
        -- Consulta Aviso de privacidad
        CALL bdinteg:"informix".sp_valida_aviso_privacidad('001', TRIM(pCliente)) returning cChkAvisoPrivacidad;
        IF cChkAvisoPrivacidad='001' THEN
			LET cChkAvisoPrivacidad='100';
		END IF
       
        -- Consulta Compartir Datos del Cliente con Grupo Coppel
        CALL bdinteg:"informix".sp_cons_datos_contacto(TRIM(pCliente)) returning cChkCompartirGC;
        IF cChkCompartirGC = '001' THEN
            LET cChkCompartirGC = '100';
		ELSE
			LET cChkCompartirGC = '000';
        END IF;
        
        -- Consulta EnvÃ­o de Estados de Cuenta por Medios ElectrÃ³nicos
        CALL bdinteg:"informix".sp_cons_aut_envio_edocta(TRIM(pCliente)) RETURNING cChkEstadoCuenta, status_EdoCta;
		IF status_EdoCta= '1' THEN 
			LET status_EdoCta='100';
		ELSE 
			LET status_EdoCta='000';
		END IF;
		
        RETURN cCod_ret,NVL(cChkBuro,''),NVL(cChkAvisoPrivacidad,''),NVL(cChkINE,''),NVL(cChkCompartirGC,''),NVL(status_EdoCta,''),NVL(gran_data,'');
    
    END;
    
END PROCEDURE
DOCUMENT
'----------------------------------------------------------------------------',
'--Autor: 97523641 Alberto Sanchez',
'--Folio: 869.1- Cuestionario de PLD en Apertura de Productos Complementaria 5.',
'--Fecha: 26/09/2022.',
'--Solicita:', 
'--Descripcion: Se crea procedimiento almacenado para las consultas a las diferentes tablas',
'-- donde se almacenan las autorizaciones',
'--BD: bdinteg.',
'-- --------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_conciliainv_esp( pempresa CHAR(3), pfecha DATE )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    -- // DECLARACION DE VARIABLES
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vcodret4         CHAR(5);
    DEFINE vcodret5         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcomienza        SMALLINT;
    DEFINE ventransacc      SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE vcuenta          CHAR(20);
    DEFINE vsecuencia       SMALLINT;
    DEFINE vnum_cte         CHAR(20);
    DEFINE vsucursal        CHAR(4);
    DEFINE vejecutivo       CHAR(8);
    DEFINE vcap_anterior    MONEY(18,2);
    DEFINE vcap_calculado   MONEY(18,2);
    DEFINE vcap_actual      MONEY(18,2);
    DEFINE vdif_capital     MONEY(18,2);
    DEFINE vint_anterior    MONEY(18,2);
    DEFINE vint_calculado   MONEY(18,2);
    DEFINE vint_actual      MONEY(18,2);
    DEFINE vdif_interes     MONEY(18,2);
    DEFINE vmontocargocap   MONEY(18,2);
    DEFINE vmontoabonocap   MONEY(18,2);
    DEFINE vmontocargoint   MONEY(18,2);
    DEFINE vmontoabonoint   MONEY(18,2);
    DEFINE vcta_cargo       CHAR(14);
    DEFINE vcta_abono       CHAR(14);
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vproducto        CHAR(4);
    DEFINE vplazo           SMALLINT;
    DEFINE vanio_mes        CHAR(6);
    DEFINE vdia             CHAR(2);

    -- // INICIALIZACION DE VARIABLES
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET vcodret3        = 'PROCESO TERMINADO SATISFACTORIAMENTE';
    LET vcodret4        = '';
    LET vcodret5        = '';
    LET sql_err	        = 0;
    LET isam_err	    = 0;
    LET desc_err        = '';
    LET vcomienza       = -1;
    LET ventransacc     = 0;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcontador3      = 0;
    LET vcap_anterior   = 0.00;
    LET vmontocargocap  = 0.00;
    LET vmontoabonocap  = 0.00;
    LET vcap_calculado  = 0.00;
    LET vcap_actual     = 0.00;
    LET vdif_capital    = 0.00;
    LET vint_anterior   = 0.00;
    LET vmontocargoint  = 0.00;
    LET vmontoabonoint  = 0.00;
    LET vint_calculado  = 0.00;
    LET vint_actual     = 0.00;
    LET vdif_interes    = 0.00;
    LET vplazo          = 0;
    LET vanio_mes       = '';
    LET vdia            = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliainv_esp.err";
        TRACE ON;
        LET vcodret1 = sql_err;
        LET vcodret2 = isam_err;
        LET vcodret3 = desc_err;
        RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliainv_esp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // TABLA PARA TODAS LAS CUENTAS
    CREATE TEMP TABLE tmp_conciliainv(
        fecha           DATE,               
        cuenta          CHAR(20),       
        secuencia       SMALLINT,
        plazo           SMALLINT,
        producto        CHAR(4),            
        num_cte         CHAR(20),
        sucursal        CHAR(4),            
        ejecutivo       CHAR(8),
        cap_anterior    MONEY(18,2),        
        movscargocap    MONEY(18,2),
        movsabonocap    MONEY(18,2),        
        cap_calculado   MONEY(18,2),
        cap_actual      MONEY(18,2),        
        dif_sdos        MONEY(18,2),
        int_anterior    MONEY(18,2),        
        movscargoint    MONEY(18,2),
        movsabonoint    MONEY(18,2),        
        int_calculado   MONEY(18,2),
        int_actual      MONEY(18,2),        
        dif_ints        MONEY(18,2) ) 
    WITH NO LOG LOCK MODE ROW;
    CREATE INDEX tmpidx_conciliainv ON tmp_conciliainv(cuenta) USING BTREE;
        
    -- // TABLA DE DIFERENCIAS
    CREATE TEMP TABLE tmp_conciliainvdif(
        fecha           DATE,               
        cuenta          CHAR(20),       
        secuencia       SMALLINT,
        plazo           SMALLINT,
        producto        CHAR(4),            
        num_cte         CHAR(20),
        sucursal        CHAR(4),            
        ejecutivo       CHAR(8),
        cap_anterior    MONEY(18,2),        
        movscargocap    MONEY(18,2),
        movsabonocap    MONEY(18,2),        
        cap_calculado   MONEY(18,2),
        cap_actual      MONEY(18,2),        
        dif_sdos        MONEY(18,2),
        int_anterior    MONEY(18,2),        
        movscargoint    MONEY(18,2),
        movsabonoint    MONEY(18,2),        
        int_calculado   MONEY(18,2),
        int_actual      MONEY(18,2),        
        dif_ints        MONEY(18,2) ) 
    WITH NO LOG LOCK MODE ROW;
    CREATE INDEX tmpidx_conciliainvdif ON tmp_conciliainvdif(cuenta) USING BTREE;
    
    -- // ASIGNA FECHAS DEL PROCESO
    LET vfecha_hoy = pfecha;
    LET vfecha_ant = pfecha - 1 UNITS DAY;
    LET vanio_mes = YEAR(vfecha_hoy)||LPAD(MONTH(vfecha_hoy),2,0);
    LET vdia = DAY(vfecha_hoy);
    LET vdia = TRIM(vdia);
    
    EXECUTE PROCEDURE bdicheq:sp_valfechabil(vfecha_hoy, '-') 
    INTO vcodret1, vfecha_hoy;
    
    EXECUTE PROCEDURE bdicheq:sp_valfechabil(vfecha_ant, '-') 
    INTO vcodret1, vfecha_ant;
        
    -- // TABLA TEMPORAL DE MOVIMIENTOS
    SELECT mov.cuenta, mov.secuencia, mov.transacc, mov.monto_tot, tran.descripcion, tran.se_contabiliza,
           TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub)||TRIM(prod.c_sector) AS cta_cargo,
           TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub)||TRIM(prod.a_sector) AS cta_abono
      FROM bdinvers:sv_movhis mov,
           bdinvers:sv_maeinv mae,
           bdinvers:sv_plazotasa pla,
           bdinteg:si_prodtran prod,
           bdinteg:si_transacc tran
     WHERE mov.empresa = mae.empresa
       AND mov.cuenta = mae.cuenta
       AND mov.secuencia = mae.secuencia
       AND mov.fech_alt = vfecha_hoy
       AND mov.cancelad <> 'S'
       AND mae.plazo <= pla.plazo_max
       AND mae.plazo >= pla.plazo_min
       AND pla.plaza = mae.plaza
       AND pla.secuencia = prod.secuencia
       AND prod.transaccion = mov.transacc
       AND prod.producto = mov.cod_instrum
       AND prod.sistema = '03'
	   AND tran.sistema = '03'
       AND tran.empresa = mov.empresa
       AND tran.numero = prod.transaccion
       AND tran.se_contabiliza = 'S'
    INTO TEMP tmp_concilia WITH NO LOG;
    CREATE INDEX idx_concilia ON tmp_concilia(cuenta) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_concilia;
    
    IF vdia = '1' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia1 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '2' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia2 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '3' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia3 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '4' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia4 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '5' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia5 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '6' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia6 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '7' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia7 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '8' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia8 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '9' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia9 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '10' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia10 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '11' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia11 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '12' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia12 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '13' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia13 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '14' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia14 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '15' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia15 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '16' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia16 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '17' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia17 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '18' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia18 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '19' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia19 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '20' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia20 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '21' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia21 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '22' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia22 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '23' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia23 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '24' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia24 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '25' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia25 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '26' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia26 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '27' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia27 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '28' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia28 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '29' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia29 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '30' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia30 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    ELIF vdia = '31' THEN
        FOREACH WITH HOLD        
            SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo
              INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo
              FROM sv_maeinv mae, sv_provdia sdo
             WHERE mae.empresa = sdo.empresa 
               AND mae.cuenta = sdo.cuenta
               AND mae.secuencia = sdo.secuencia
               AND sdo.aniomes = vanio_mes
               AND cv_dia31 is not null
            
            IF vcomienza = -1 THEN
                BEGIN WORK;
                LET vcomienza = 0;
                LET ventransacc = 1;
            END IF;
            
            -- // OBTIENE SALDOS ANTERIORES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
            INTO vcodret4, vcodret5, vcap_anterior, vint_anterior;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vcap_calculado = vcap_anterior;
            LET vint_calculado = vint_anterior;
            
            -- // RESTA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado - vmontocargocap;
            
            -- // SUMA CAPITAL
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonocap
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

            LET vcap_calculado = vcap_calculado + vmontoabonocap;
            
            -- // RESTA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontocargoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_cargo IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado - vmontocargoint;
            
            -- // SUMA INTERES
            SELECT NVL(SUM(tmp.monto_tot),0.00)
              INTO vmontoabonoint
              FROM tmp_concilia tmp
             WHERE tmp.cuenta = vcuenta
               AND tmp.secuencia = vsecuencia
               AND tmp.cta_abono IN(SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

            LET vint_calculado = vint_calculado + vmontoabonoint;
            
            -- // OBTIENE SALDOS ACTUALES
            EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
            INTO vcodret4, vcodret5, vcap_actual, vint_actual;
            
            IF ( vcodret4 <> '000' OR vcodret5 <> '000' ) THEN
                CONTINUE FOREACH;
            END IF;
            
            LET vdif_capital = vcap_actual - vcap_calculado;
            LET vdif_interes = vint_actual - vint_calculado;
            
            -- // LLENA TABLA DE TODAS LAS CUENTAS
            INSERT INTO tmp_conciliainv VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);
            
            -- // LLENA TABLA DE DIFERENCIAS
            IF ( vdif_capital <> 0 OR vdif_interes <> 0 ) THEN
                INSERT INTO tmp_conciliainvdif VALUES(vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vsucursal, vejecutivo, vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital, vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);                       
                LET vcontador2 = vcontador2 + 1;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 1000 THEN
                LET vcontador3 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
        END FOREACH;
    END IF;    
    
    IF ventransacc = 1 THEN
        LET ventransacc = 0;
        COMMIT WORK;
    END IF;

    UPDATE STATISTICS MEDIUM FOR TABLE tmp_conciliainv;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_conciliainvdif;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;

END PROCEDURE;