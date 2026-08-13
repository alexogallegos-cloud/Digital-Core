CREATE PROCEDURE "informix".sp_genera_reportes_spei(p_empresa char(3))
RETURNING CHAR(5);
    
    DEFINE vsqlerr        INTEGER;
    DEFINE iIsamErr       INTEGER;
    DEFINE cErrorInfo     CHAR(80);
    DEFINE vcodret        CHAR(5);
    DEFINE vcodret2       CHAR(5);
	DEFINE vErrorInfo     CHAR(80);
  	DEFINE v_fecha_ini    DATE; 
	DEFINE v_codretparam  CHAR(5);
	DEFINE v_codretparam1 CHAR(5);
	DEFINE v_codretparam2 CHAR(70);
	DEFINE vprocesocomp1  SMALLINT;

    LET vsqlerr = 0; 
    LET iIsamErr = 0;
    LET cErrorInfo = "";
    LET vcodret = "";    
    LET vcodret2 = "";
	LET vErrorInfo = "";
	LET v_fecha_ini = "";
	LET v_codretparam = '';
	LET v_codretparam1 = '';
	LET v_codretparam2 = '';
	LET vprocesocomp1 = 0;
    
    BEGIN
    
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/spei/sp_genera_reportes_spei.err";
	 	    TRACE ON;
			LET vcodret = vsqlerr;
            LET vcodret2 = iIsamErr;
            LET vErrorInfo = cErrorInfo;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
	
	--- SET DEBUG FILE TO '/resplogifx/conciliachq/spei/sp_genera_reportes_spei.out';
    --- TRACE ON;
	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   
    
	SELECT fecha_hoy 
	  INTO v_fecha_ini
	  FROM bdicheq:sc_fechas
     WHERE empresa = p_empresa;	
	
	-- // MIENTRAS LA BANDERA SEA 0 VA A SEGUIR ESPERANDO.
	WHILE vprocesocomp1 = 0
        SELECT COUNT(*) 
          INTO vprocesocomp1
          FROM bdispei:tblctrlproceso
         WHERE intcveproceso = 9
           AND dtfecha = v_fecha_ini;
    END WHILE;
	
	EXECUTE PROCEDURE bdicheq:sp_rptmovsdiariospei('001')
	INTO v_codretparam, v_codretparam1, v_codretparam2; 
	
	IF v_codretparam = "000"  THEN 
        LET v_codretparam  = '';
        LET v_codretparam1 = '';
        LET v_codretparam2 = '';

        EXECUTE PROCEDURE bdicheq:sp_rptmovsdiariospei_acuenta('001')
        INTO  v_codretparam, v_codretparam1, v_codretparam2; 

        IF v_codretparam = '000' THEN 
            LET vcodret = '00000';
        END IF ;
	END IF; 

    RETURN vcodret;
    
    END; 
    
END PROCEDURE;