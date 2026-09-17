CREATE PROCEDURE "informix".sp_cobra_comision_param( pEmpresa CHAR(3))
RETURNING CHAR(5);
    
    DEFINE vcodret     CHAR(5);
    DEFINE vcodret2    CHAR(5);
    DEFINE vcodret3    CHAR(50);
    DEFINE vsqlerr     INTEGER;
    DEFINE isam_err    INTEGER;
    DEFINE error_info  CHAR(50);
    DEFINE vpromedio   INTEGER;
    DEFINE vcont       SMALLINT;
    DEFINE vbrinca     INTEGER;
    DEFINE vctamin     CHAR(20);
    DEFINE vcliente1   CHAR(20);
    DEFINE vcliente2   CHAR(20);
	DEFINE vcliente3   CHAR(20);
	DEFINE vcliente4   CHAR(20);
    DEFINE vno_ctas    INTEGER;
	DEFINE v_val_tbl   INTEGER;
	DEFINE v_cte_cargo CHAR(20);
	DEFINE v_sdprom    INTEGER;
	DEFINE v_sdprom2   INTEGER;
	
	
    LET vcodret    = "000";
    LET vcodret2   = "";
    LET vcodret3   = "";
    LET vsqlerr    = 0;
    LET isam_err   = 0;
    LET error_info = ''; 
    LET vpromedio  = 0;
    LET vcont      = 0;
    LET vbrinca    = 0;
    LET vctamin    = '';
    LET vcliente1  = '';
    LET vcliente2  = '';
	LET vcliente3  = '';
	LET vcliente4  = '';
    LET vno_ctas   = 0;
	LET v_sdprom   = 0;
    LET v_sdprom2   = 0;
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobra_comision_param.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    	--SET DEBUG FILE TO "/RESPALDOSNEW/opti/sp_cobra_comision_param.out";
    	--TRACE ON;
	   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;   

    SELECT COUNT(*) 
	INTO   v_val_tbl
	FROM   sysmaster:systabnames 
    WHERE  partnum > 0 
	AND    tabname = 'sc_cliente_si_cargo';
	   
	--INICIALIZA LA TABLA 	   
	IF v_val_tbl > 0 THEN 
	   TRUNCATE TABLE sc_cliente_si_cargo;
	END IF; 
    
	-- SE OPTIENE EL SALDO PROMEDIO PARA LOS PRODUCTOS EN GENERAL.  
    SELECT valor 
	INTO   v_sdprom
	FROM   bdicheq:sc_param
    WHERE  codparam = "sdoprom";
	
	
	-- SE OPTIENE EL SALDO PROMEDIO PARA EL PRODUCTO 2500.  
    SELECT valor 
	INTO   v_sdprom2
	FROM   bdicheq:sc_param
    WHERE  codparam = "sdoprom_2500";
 	
    
    SELECT DISTINCT(cliente)
	FROM   sc_ctas_total
	WHERE  producto <> "2500"
	AND    saldo_prom >= v_sdprom
	INTO   TEMP tmp_cliente_no_cargo1 WITH NO LOG;
	
	
	SELECT DISTINCT(cliente)
	FROM   sc_ctas_total
	WHERE  producto =  "2500"
	AND    saldo_prom >= v_sdprom2
	INTO   TEMP tmp_cliente_no_cargo2 WITH NO LOG;
	
	SELECT * FROM tmp_cliente_no_cargo1
	UNION ALL
	SELECT * FROM tmp_cliente_no_cargo2	
	INTO   TEMP tmp_cliente_no_cargo WITH NO LOG;
	
	
	CREATE INDEX idx_tmp_cliente_no_cargo 
	ON tmp_cliente_no_cargo (cliente);
	
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_cliente_no_cargo;
	UPDATE STATISTICS MEDIUM FOR TABLE sc_ctas_total;
	
	FOREACH WITH HOLD 
			
	        SELECT DISTINCT(cliente)
			INTO   v_cte_cargo
	        FROM   sc_ctas_total
	        WHERE  cliente NOT IN (SELECT cliente FROM tmp_cliente_no_cargo)
	      
		    INSERT INTO   sc_cliente_si_cargo  VALUES (v_cte_cargo);
	END FOREACH;
   	
    SELECT ROUND(COUNT(*)/5)
      INTO vpromedio
      FROM sc_cliente_si_cargo;
      
    SELECT MIN(cliente)
      INTO vctamin
      FROM sc_cliente_si_cargo;
      
          
    LET vcont = 1;  
    
    WHILE vcont <= 4         
        IF vcont = 1 THEN
            LET vbrinca = vpromedio;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cliente
                  INTO vcliente1
                  FROM sc_cliente_si_cargo
                 ORDER BY cliente
             
                UPDATE sc_param
                   SET valor = vcliente1
                 WHERE empresa = pempresa
                   AND codparam = 'CteIniCobComComp1';
                   
                SELECT COUNT(*)
                  INTO vno_ctas
                  FROM sc_cliente_si_cargo
                 WHERE cliente >= vctamin
                   AND cliente < vcliente1;
                   
                UPDATE sc_param
                   SET valor = vno_ctas
                 WHERE empresa = pempresa
                   AND codparam = 'RegIniCobComComp1';
            END FOREACH;
       ELIF vcont = 2 THEN
            LET vbrinca = vpromedio * 2;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cliente
                  INTO vcliente2
                  FROM sc_cliente_si_cargo
                 ORDER BY cliente
             
                UPDATE sc_param
                   SET valor = vcliente2
                 WHERE empresa = pempresa
                   AND codparam = 'CteIniCobComComp2';
                   
                SELECT COUNT(*)
                  INTO vno_ctas
                  FROM sc_cliente_si_cargo
                 WHERE cliente >= vctamin
                   AND cliente < vcliente2;
                   
                UPDATE sc_param
                   SET valor = vno_ctas
                 WHERE empresa = pempresa
                   AND codparam = 'RegIniCobComComp2';
            END FOREACH;
	   ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 3;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cliente
                  INTO vcliente3
                  FROM sc_cliente_si_cargo
                 ORDER BY cliente
             
                UPDATE sc_param
                   SET valor = vcliente3
                 WHERE empresa = pempresa
                   AND codparam = 'CteIniCobComComp3';
                   
                SELECT COUNT(*)
                  INTO vno_ctas
                  FROM sc_cliente_si_cargo
                 WHERE cliente >= vctamin
                   AND cliente < vcliente3;
                   
                UPDATE sc_param
                   SET valor = vno_ctas
                 WHERE empresa = pempresa
                   AND codparam = 'RegIniCobComComp3';
            END FOREACH;
	   ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 4;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 cliente
                  INTO vcliente4
                  FROM sc_cliente_si_cargo
                 ORDER BY cliente
             
                UPDATE sc_param
                   SET valor = vcliente4
                 WHERE empresa = pempresa
                   AND codparam = 'CteIniCobComComp4';
                   
                SELECT COUNT(*)
                  INTO vno_ctas
                  FROM sc_cliente_si_cargo
                 WHERE cliente >= vctamin
                   AND cliente < vcliente4;
                   
                UPDATE sc_param
                   SET valor = vno_ctas
                 WHERE empresa = pempresa
                   AND codparam = 'RegIniCobComComp4';
            END FOREACH;
       END IF;
        
    LET vcont = vcont + 1;
    END WHILE;   

    DROP TABLE 	tmp_cliente_no_cargo;

    RETURN vcodret;

    END;

END PROCEDURE;