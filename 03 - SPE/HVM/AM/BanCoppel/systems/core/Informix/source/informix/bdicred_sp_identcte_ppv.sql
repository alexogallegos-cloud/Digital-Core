CREATE PROCEDURE "informix".sp_identcte_ppv(p_empresa char(3))
    RETURNING   CHAR(5);
       
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vcodret          CHAR(5);
	DEFINE v_numcte         CHAR(20);
	DEFINE v_num_producto   CHAR(4);
	DEFINE v_c_vcomienza    SMALLINT;
	DEFINE ven_transacc     SMALLINT;
	DEFINE v_c_vcontador    INTEGER;
	DEFINE v_val_tbl_cte    INTEGER;
   		
    LET vsqlerr             = 0; 
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";   
    LET vErrorInfo          = "INICIO DEL PROCESO";
    LET vcodret             = "00000";
	LET v_numcte            = "";
	LET v_num_producto      = "";
	LET v_c_vcomienza       = -1;
	LET ven_transacc        = 0;
	LET v_c_vcontador       = 0;
	

    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_identcte_ppv.err";
	 	    TRACE ON;
			LET vcodret    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
	        IF ven_transacc = 1 THEN
               ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
	
	--SET   DEBUG FILE TO '/resplogifx/conciliachq/sp_identcte_ppv.txt';
	--SET   DEBUG FILE TO '/informix/rsv/oxxo/sp_identcte_ppv.txt';
    --TRACE ON;
	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  

    SELECT COUNT(*) 
	INTO   v_val_tbl_cte
	FROM   sysmaster:systabnames 
    WHERE  partnum > 0 
	AND    tabname = 'sd_ppvigente';
	   
	--INICIALIZA LA TABLA 	   
	IF v_val_tbl_cte > 0 THEN 
	   TRUNCATE TABLE sd_ppvigente;
	END IF; 		
	
    FOREACH WITH HOLD
	        SELECT {+INDEX(sd_maecredcrd idx_sd_maecredcrd2)}
	               c.numcte,   c.num_producto  
			INTO   v_numcte, v_num_producto 
			FROM   bdicred:sd_maecredcrd c 
			JOIN   bdicred:sd_maesdoscrd d ON ( c.num_credito = d.num_credito)
			WHERE  c.num_producto IN('6300','7600','7700','7800','6400','6800')
			  AND  c.status_cred IN ('AA','E1')
			  AND  (d.monto_vencido + d.mto_venc_trasp) = 0
			
			-- Abre la transaccion 
		    IF  (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;
			
			INSERT INTO "informix".sd_ppvigente VALUES (v_numcte,v_num_producto);
						
			LET v_c_vcontador = v_c_vcontador + 1;
			--Realiza commit cada 5000 registros 
			IF (v_c_vcontador >= 5000) THEN
               LET v_c_vcontador = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF; 
			
    END FOREACH;
	
	--Si la transaccion esta abierta realiza el commit
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;		
	
RETURN  vcodret;
END; 
END PROCEDURE;