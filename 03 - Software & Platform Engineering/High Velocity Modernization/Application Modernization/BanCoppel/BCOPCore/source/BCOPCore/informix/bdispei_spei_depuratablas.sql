CREATE PROCEDURE "informix".spei_depuratablas( pEmpresa CHAR(3) ) 
RETURNING CHAR(5);
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(80);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(80);
    DEFINE wfecha_hoy       DATE;
    DEFINE wcierre          SMALLINT;
    DEFINE wtblpago         CHAR(5);
    DEFINE wtbldetranpago   CHAR(5);
    DEFINE wdesbloqbandera  CHAR(5);

    LET sql_err         = 0;
    LET isam_err        = 0;
    LET desc_err        = '';
    LET vcodret1        = '00000';
    LET vcodret2        = '';
    LET vcodret3        = '';
    LET wfecha_hoy      = '';
    LET wcierre         = 0;
    LET wtblpago        = '';
    LET wtbldetranpago  = '';
    LET wdesbloqbandera = '';

    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_depuratablas.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_depuratablas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO wfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
    
    -- // ESPERA EL CIERRE DEL SPEI
    WHILE wcierre = 0
       SELECT COUNT(*) 
         INTO wcierre
         FROM tblctrlproceso
        WHERE dtfecha = wfecha_hoy
          AND intcveproceso = 9
          AND chrstatus = '3';
    END WHILE;
    
    -- // DEPURA MOVIMIENTOS DE LA TABLA tblpago A LA TABLA tblhistpago
    CALL spei_depuratblpago(wfecha_hoy)
    RETURNING wtblpago;
    
    IF wtblpago <> '000' THEN
        LET vcodret1 = '00111';
        RETURN vcodret1;
    END IF;
    
    -- // DEPURA MOVIMIENTOS DE LA TABLA tbldetranpago A LA TABLA tblhistdetranpago
    CALL spei_depuratbldetranpago(wfecha_hoy)
    RETURNING wtbldetranpago;
    
    IF wtbldetranpago <> '000' THEN
        LET vcodret1 = '00222';
        RETURN vcodret1;
    END IF;
    
    /* ##################################################################
    -- // CAMBIA BANDERAS DE BLOQUEO A USUARIOS
    CALL spei_desbloqbandera(pEmpresa) 
    RETURNING wdesbloqbandera;
    
    IF wdesbloqbandera <> '000' THEN
        LET vcodret1 = '00333';
        RETURN vcodret1;
    END IF;
    
    -- // ACTUALIZA TBLPAGO POR SI HUBIERA REGISTROS PENDIENTES
    UPDATE tblpago
       SET chrestatusenvio = 'N'
     WHERE chrestatusenvio = 'E';
    ################################################################## */
    
    RETURN vcodret1;
    
    END;
    
END PROCEDURE;