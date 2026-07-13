CREATE PROCEDURE "informix".sp_actestenvspei()
RETURNING CHAR(5);
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    
    LET vcodret1 = '00000';
    LET vcodret2 = '';
    LET vcodret3 = '';
    LET sql_err  = 0 ;
    LET isam_err = 0 ;
    LET desc_err = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actestenvspei.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actestenvspei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    /* ####################################################################################################################################################################################
    IF CURRENT HOUR TO fraction < '17:58:00' OR CURRENT HOUR TO fraction > '18:05:00' THEN
        UPDATE tblpago 
           SET chrestatusenvio = 'N'
         WHERE chrestatusenvio = 'E'
           AND vchrclaverastreo IN( SELECT {+INDEX(bdicheq:sc_movdia idx_movdia10)} referencia FROM bdicheq:sc_movdia WHERE CURRENT HOUR TO fraction - fech_hor > '00:30:00.000' )
           AND dtfechavalor IN( SELECT SUBSTR(vchrvalor,4,2)||"/"||SUBSTR(vchrvalor,1,2)||"/"||SUBSTR(vchrvalor,7,4) FROM tblparametros WHERE vchrcveparametro = "FECHA_OPERACION" );
    END IF;
    #################################################################################################################################################################################### */
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;