CREATE PROCEDURE "informix".sp_arreg_maehis_sbc( pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;

    DEFINE CodRet1	                CHAR(5);
    DEFINE CodRet2                  CHAR(5);
    DEFINE CodRet3                  CHAR(50);
    DEFINE sql_err                  INTEGER;
    DEFINE isam_err                 INTEGER;
    DEFINE desc_err                 CHAR(50);
    DEFINE vcomienza                SMALLINT;
    DEFINE ven_transacc             SMALLINT;
    DEFINE vcontador1               INTEGER;
    
    DEFINE vtotdepositos            DECIMAL(14,2);
    DEFINE vtotretiros              DECIMAL(14,2);
    DEFINE vfechafin                DATE;
    DEFINE vfechaini                DATE;
    DEFINE vaniomes                 CHAR(6);
    DEFINE vmonto_tot               DECIMAL(16,2);
    DEFINE vtransacc                CHAR(4);
    DEFINE vnaturaleza              CHAR(1);
    DEFINE vtipo_tran               CHAR(2);
    DEFINE vfechainimovhis          CHAR(10);
    DEFINE vfechainimovhisold       CHAR(10);
    DEFINE vtran_efec               CHAR(4);
    DEFINE vtotretirosefec          DECIMAL(18,2);
    DEFINE vtototroscargos          DECIMAL(18,2);
    DEFINE vtrandepotrobco          CHAR(4);
    DEFINE vtrandevotrobco          CHAR(4);
    DEFINE vgtrans_pag_int          CHAR(4);
    DEFINE vgtransisr               CHAR(4);
    DEFINE vmincta, vmaxcta         CHAR(20);
    DEFINE vcuenta                  CHAR(20);
    
    LET CodRet1      = '000';
    LET CodRet2      = '000';
    LET CodRet3      = 'PROCESO REALIZADO CORRECTAMENTE';
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcontador1   = 0;
    
    LET vtotdepositos      = 0.00;
    LET vtotretiros        = 0.00;
    LET vfechafin          = '';
    LET vfechaini          = '';
    LET vaniomes           = '';
    LET vmonto_tot         = 0.00;
    LET vtransacc          = '';
    LET vnaturaleza        = '';
    LET vtipo_tran         = '';
    LET vfechainimovhis    = '';
    LET vfechainimovhisold = '';
    LET vtran_efec         = '';
    LET vtotretirosefec    = 0.00;
    LET vtototroscargos    = 0.00;
    LET vtrandepotrobco    = '';
    LET vtrandevotrobco    = '';
    LET vgtrans_pag_int    = '';
    LET vgtransisr         = '';
    LET vmincta            = '';
    LET vmaxcta            = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_arreg_maehis_sbc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET CodRet1 = sql_err;
            LET CodRet2 = isam_err;
            LET CodRet3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN CodRet1, CodRet2, CodRet3, vcontador1;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/sp_arreg_maehis_sbc.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE PARAMETROS
    SELECT valor
      INTO vgtrans_pag_int
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = "tranpagint";

    SELECT valor
      INTO vgtransisr
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = "tranisr";
       
    SELECT valor
      INTO vfechainimovhis
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO vfechainimovhisold
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    SELECT valor
      INTO vtrandepotrobco
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'trandepobco';
       
    SELECT valor
      INTO vtrandevotrobco
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'trandevobco';
       
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_maehis;
       
    SELECT cuenta
      FROM sc_movhis_old 
     WHERE fech_alt BETWEEN '09/05/2011' AND '10/31/2011'
       AND fech_alt >= vfechainimovhisold
       AND fech_alt < vfechainimovhis
       AND transacc IN(vtrandepotrobco, vtrandevotrobco)
       AND cancelad <> 'S'
    UNION ALL 
    SELECT cuenta
      FROM sc_movhis
     WHERE fech_alt BETWEEN '09/05/2011' AND '10/31/2011'
       AND fech_alt >= vfechainimovhis
       AND transacc IN(vtrandepotrobco, vtrandevotrobco)
       AND cancelad <> 'S'
    INTO TEMP tmp_movs WITH NO LOG;
    CREATE INDEX idx_ctatmpmovs ON tmp_movs(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movs;
     
    -- // OBTIENE CUENTAS A PROCESAR
    FOREACH WITH HOLD
        SELECT UNIQUE his.cuenta, his.aniomes, his.fechaini, his.fechafin
          INTO vcuenta, vaniomes, vfechaini, vfechafin
          FROM sc_maehis his,
               tmp_movs movs
         WHERE his.empresa = pEmpresa
           AND his.cuenta = movs.cuenta
           AND his.fechafin BETWEEN pFechaIni AND pFechaFin     

        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        -- // INICIALIZA VARIABLES DE SALDOS
        LET vtotdepositos   = 0;
        LET vtotretiros     = 0;
        LET vtotretirosefec = 0;
        LET vtototroscargos = 0;
        
        -- // OBTIENE CARGOS Y ABONOS DEL HISTORICO
        FOREACH           
            SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
              INTO vmonto_tot, vtransacc, vnaturaleza, vtipo_tran, vtran_efec
              FROM sc_movhis mv
             INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S')
              LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
             WHERE mv.empresa = pEmpresa
               AND mv.cuenta = vcuenta
               AND mv.fech_alt BETWEEN vfechaini AND vfechafin
               AND mv.fech_alt >= vfechainimovhis
               AND mv.cancelad <> 'S'
               AND mv.transacc = tr.numero
            UNION ALL
            SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
              FROM sc_movhis_old mv
             INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S')
              LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
             WHERE mv.empresa = pEmpresa
               AND mv.cuenta = vcuenta
               AND mv.fech_alt BETWEEN vfechaini AND vfechafin
               AND mv.fech_alt >= vfechainimovhisold
               AND mv.fech_alt < vfechainimovhis
               AND mv.cancelad <> 'S'
               AND mv.transacc = tr.numero
            
            -- // ABONOS
            IF vnaturaleza = 'A' THEN 
                IF (vtransacc <> vgtrans_pag_int AND vtransacc <> vtrandepotrobco) THEN -- TOTAL DEPOSITOS
                    LET vtotdepositos = vtotdepositos + vmonto_tot;
                END IF;
            -- // CARGOS
            ELIF vnaturaleza = 'C' THEN 
                IF (vtipo_tran IN('00','30') AND vtransacc <> vgtransisr AND vtransacc <> vtrandevotrobco) THEN -- TOTAL RETIROS
                    LET vtotretiros = vtotretiros + vmonto_tot;
                    LET vtototroscargos = vtototroscargos + vmonto_tot;
                END IF;
                
                IF vtran_efec = vtransacc THEN
                    LET vtotretirosefec = vtotretirosefec + vmonto_tot;
                END IF;
            END IF;
        END FOREACH;

        IF vtotdepositos IS NULL THEN -- DEPOSITOS
            LET vtotdepositos = 0;
        END IF;

        IF vtotretiros is null OR vtotretiros < 0 THEN -- RETIROS
            LET vtotretiros = 0;
        END IF;
        
        IF vtotretirosefec IS NULL THEN
            LET vtotretirosefec = 0;
        END IF;
        
        LET vtototroscargos = vtototroscargos - vtotretirosefec;
        
        IF vtototroscargos is null OR vtototroscargos < 0 THEN
            LET vtototroscargos = 0;
        END IF;

        UPDATE sc_maehis
           SET totdepositos = vtotdepositos,
               totretiros = vtotretiros,
               tototroscargos = vtototroscargos
         WHERE empresa = pEmpresa
           AND cuenta = vcuenta
           AND aniomes = vaniomes;
           
        LET vcontador1 = vcontador1 + 1; 
           
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta = ''; 
        LET vaniomes = ''; 
        LET vfechaini = ''; 
        LET vfechafin = '';
        LET vmonto_tot = 0.00; 
        LET vtransacc = ''; 
        LET vnaturaleza = ''; 
        LET vtipo_tran = ''; 
        LET vtran_efec = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;
            
    RETURN CodRet1, CodRet2, CodRet3, vcontador1;

END PROCEDURE;