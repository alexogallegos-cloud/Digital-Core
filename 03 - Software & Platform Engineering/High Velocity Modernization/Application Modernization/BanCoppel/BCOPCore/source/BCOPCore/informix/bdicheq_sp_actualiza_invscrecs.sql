CREATE PROCEDURE "informix".sp_actualiza_invscrecs(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2);    
    DEFINE vsucursal        CHAR(4);  
    DEFINE vfecha_hoy       DATE;
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET ven_transacc  = 0;
    LET vhora          = '';
    LET vfolio         = '';
    LET vcuenta        = '';
    LET vmonto         = 0.00;
    LET vsucursal      = '';
    LET vfecha_hoy     = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_invscrecs.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_invscrecs.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    select unique cuenta
      from sc_movhis
     where fech_alt = '12/07/2016'
       and transacc = '0205'
       and referencia like 'TRASPASO%INV. CRECIENTE'
       and usuario = 'agnt70ct'
    into temp tmp_ctaseje with no log;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT a.cuenta, b.sdo_actual, b.sucursal
          INTO vcuenta, vmonto, vsucursal
          FROM sc_maeinstrucc a,
               sc_maechq b
         where a.empresa = '001'
           and a.cuentadep in(select cuenta from tmp_ctaseje)
           and a.cuenta in(select cuenta from sc_valcierre_his where fecha = '12/07/2016')
           and b.cuenta = a.cuenta
           and b.status_cta =  '1'
           
        BEGIN WORK;
        LET ven_transacc = 1;
        
        INSERT INTO sc_movdia VALUES
        ( 0, vfolio, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '0239', vsucursal, '1100', pempresa, vcuenta, "", 
          0, vmonto, 0, 0, 0, 0, "", '1', vmonto, "0000", "CARGO POR TRASPASO INV. CRECIENTE", 0, '', "" ,"", vfecha_hoy);
         
        UPDATE sc_maechq
           SET num_cgos_mes = num_cgos_mes + 1,
               imp_cgos_mes = imp_cgos_mes + vmonto,
               sdo_actual = sdo_actual - vmonto,
               status_cta = '2',
               fec_ult_mov = vfecha_hoy,
               fec_cancelac = vfecha_hoy,
               fecultret = vfecha_hoy
         WHERE cuenta = vcuenta;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
    END FOREACH;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;