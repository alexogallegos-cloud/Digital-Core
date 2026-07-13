CREATE PROCEDURE "informix".sp_histmovcheqconsolida(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50);
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    DEFINE vfecha   CHAR(8);
    DEFINE vsql     CHAR(600);
    
    LET vcodret1   = '000';
    LET vcodret2   = '000';
    LET vcodret3   = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET sql_err	   = 0;
    LET isam_err   = 0;
    LET desc_err   = ''; 
    LET vfecha     = ''; 
    LET vsql       = '';
    
    BEGIN
    
    ON EXCEPTION
        SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_histmovcheqconsolida.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_histmovcheqconsolida.out";
    --- TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT TO_CHAR(fecha_ant, '%d%m%Y')
      INTO vfecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    LET vsql = 'cat /resplogifx/conciliachq/histmovcheq_aplicados_pte1_'||vfecha||'.txt '||
               '/resplogifx/conciliachq/histmovcheq_aplicados_pte2_'||vfecha||'.txt '||
               '/resplogifx/conciliachq/histmovcheq_aplicados_pte3_'||vfecha||'.txt '||
               '/resplogifx/conciliachq/histmovcheq_aplicados_pte4_'||vfecha||'.txt '||
               '/resplogifx/conciliachq/histmovcheq_aplicados_pte5_'||vfecha||'.txt '||
               '/resplogifx/conciliachq/histmovcheq_aplicados_pte6_'||vfecha||'.txt > /resplogifx/conciliachq/histmovcheq_aplicados_'||vfecha||'.txt';
    SYSTEM vsql;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3;
    
END PROCEDURE;