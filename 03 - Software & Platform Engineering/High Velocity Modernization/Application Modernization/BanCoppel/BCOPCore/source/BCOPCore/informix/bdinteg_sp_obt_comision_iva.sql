CREATE PROCEDURE "informix".sp_obt_comision_iva( pCveComision char(274), pCodParametro smallint, pCuenta CHAR(20) )
RETURNING char(5), money(14,2), money(14,2); 
    
    DEFINE vcodret   char(5);
    DEFINE vcodret2  char(5);
    DEFINE vcodret3  char(80);
    DEFINE sql_err   integer;
    DEFINE isam_err  integer;
    DEFINE desc_err  char(80);
    DEFINE comision  money(14,2);
    DEFINE valorIVA  money(14,2);
    DEFINE vproducto char(4);
    
    LET vcodret   = '000';
    LET vcodret2  = '';
    LET vcodret3  = '';
    LET sql_err   = 0;
    LET isam_err  = 0;
    LET desc_err  = '';
    LET comision  = 0;
    LET valorIVA  = 0;    
    LET vproducto = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obt_comision_iva.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret  = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret, comision, valorIVA;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obt_comision_iva.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT producto
      INTO vproducto
      FROM bdicheq:sc_maechq
     WHERE cuenta = pCuenta;
     
    IF vproducto NOT IN('1300','1700','1400','9900','9901', '1800') THEN
        SELECT mnycomision
          INTO comision
          FROM bdispei:tblcomision
         WHERE vchrcvecomision = pCveComision;
        
        SELECT valor
          INTO valorIVA
          FROM bdinteg:si_param
         WHERE cod_param = pCodParametro;
    ELSE
        LET comision = 0.00;
        LET valorIVA = 0.00;
    END IF;
	
	LET comision = 0.00;
    LET valorIVA = 0.00;
    
    RETURN vcodret, comision, valorIVA;
    
    END;
    
END PROCEDURE;