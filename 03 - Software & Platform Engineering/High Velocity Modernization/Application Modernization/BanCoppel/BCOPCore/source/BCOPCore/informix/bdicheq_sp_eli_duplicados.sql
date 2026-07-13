CREATE PROCEDURE "informix".sp_eli_duplicados(p_empresa char(3))
    RETURNING   CHAR(5);
    
    DEFINE v_c_vcomienza    SMALLINT;
	DEFINE ven_transacc     SMALLINT;
	DEFINE v_c_vcontador    INTEGER;
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vcodret          CHAR(5);
	DEFINE vcuenta          CHAR(20);
	
	
    LET v_c_vcomienza       = -1;	
	LET ven_transacc        = 0;
	LET v_c_vcontador       = 0;
	LET vsqlerr             = 0;
    LET iIsamErr            = 0;
    LET cErrorInfo          = ""; 
	LET vErrorInfo          = "INICIO DEL PROCESO";
    LET vcodret             = "00000"; 
	LET vcuenta             =  " "; 
    
	
    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_eli_duplicados.err";
	 	    TRACE ON;
			LET vcodret    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/rsv/comspei/sp_eli_duplicados.txt';
    --TRACE ON;

	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 
	
	
   	FOREACH WITH HOLD
	
	    SELECT cuenta
		INTO   vcuenta
		FROM   ctasxprocesar_040
		

	    -- Abre la transaccion 
	    IF   (v_c_vcomienza = -1) THEN
              LET v_c_vcomienza = 0;
              LET ven_transacc = 1;
              BEGIN WORK;
        END IF;
		
		DELETE FROM  conciliachq 
		WHERE cuenta  = vcuenta;
			
		LET v_c_vcontador = v_c_vcontador + 1;
		--Realiza commit cada 100 registros 
		IF (v_c_vcontador >= 100) THEN
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