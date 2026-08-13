CREATE PROCEDURE "informix".sp_alertas_corresp(pempresa CHAR(3))
RETURNING CHAR(5), DECIMAL(6,2);

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);

    DEFINE vmtototcapt      DECIMAL(18,2);
    DEFINE vporccorr        SMALLINT;
    DEFINE vmtoacumcorr     DECIMAL(18,2);
    DEFINE vmtolimcorr      DECIMAL(18,2);
    DEFINE vporcacumcorr    DECIMAL(6,2);    
    DEFINE vnivel_alerta    SMALLINT;
    DEFINE vporc_alerta     DECIMAL(6,2);
    DEFINE vmaxnivel_alerta SMALLINT;


    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';

    LET vmtototcapt   = 0.00; 
    LET vporccorr     = 0; 
    LET vmtoacumcorr  = 0.00;
    LET vmtolimcorr   = 0.00;
    LET vporcacumcorr = 0.00;
    LET vnivel_alerta = 0;
    LET vporc_alerta  = 0.00;
    LET vmaxnivel_alerta = 0;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_alertas_corresp.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vporcacumcorr;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_alertas_corresp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT {+INDEX(sc_param_corresp idx_paramcorresp)} valor
      INTO vmtototcapt
      FROM sc_param_corresp
     WHERE codparam = '001'
       AND empresa = pempresa;
       
    SELECT {+INDEX(sc_param_corresp idx_paramcorresp)} valor
      INTO vporccorr
      FROM sc_param_corresp
     WHERE codparam = '002'
       AND empresa = pempresa;
       
    LET vmtolimcorr = (vmtototcapt * (vporccorr / 100));
    LET vmtolimcorr = vmtolimcorr;

    SELECT {+INDEX(sc_param_corresp idx_paramcorresp)} valor
      INTO vmtoacumcorr
      FROM sc_param_corresp
     WHERE codparam = '003'
       AND empresa = pempresa;
       
    LET vporcacumcorr = ((vmtoacumcorr * 100) / vmtolimcorr);
    LET vporcacumcorr = vporcacumcorr;

    SELECT {+INDEX(sc_alertas_corresp idx_alertcorr)} MIN(nivel_alerta), MAX(nivel_alerta) 
      INTO vnivel_alerta, vmaxnivel_alerta
      FROM sc_alertas_corresp
     WHERE nivel_alerta > 0
       AND alertado = 'F';
       
    SELECT {+INDEX(sc_alertas_corresp idx_alertcorr)} porc_alerta
      INTO vporc_alerta
      FROM sc_alertas_corresp
     WHERE nivel_alerta = vnivel_alerta;
           
    IF vporcacumcorr >= vporc_alerta THEN
        LET vcodret1 = '999';
        
        IF vnivel_alerta < vmaxnivel_alerta THEN
            UPDATE {+INDEX(sc_alertas_corresp idx_alertcorr)} sc_alertas_corresp
               SET alertado = 'V'
             WHERE nivel_alerta = vnivel_alerta;
        END IF;
    END IF;

    END;

    RETURN vcodret1, vporcacumcorr;
    
END PROCEDURE;