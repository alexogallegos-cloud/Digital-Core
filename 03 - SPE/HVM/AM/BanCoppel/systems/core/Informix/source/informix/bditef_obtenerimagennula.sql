CREATE PROCEDURE "informix".obtenerimagennula(pempresa       char(3),
									  pcvebanco   	 char(3),
									  pnumcuenta   	 char(20),
									  pnumcheque   	 char(7),
									  pfechapresenta char(10))
RETURNING char(5);  

    DEFINE v_codret char(5);
    DEFINE sql_err,isam_err int;   
    DEFINE v_existe int;

    -- // Inicializa variables
    LET v_codret    = "000";
    LET v_existe    = 0;
    
    -- // Valida la informacion de entrada
    IF pempresa    	  is null or
		pcvebanco      is null or
		pnumcuenta     is null or
		pnumcheque     is null or
		pfechapresenta is null THEN
		LET v_codret = "110"; -- // datos de entrada incompletos
		RETURN v_codret; 
    END IF;
    
    BEGIN

    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            return v_codret;
        end if;
    end exception;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

    -- // validacion imagen nula
		select count(numcheque)
		into v_existe
		from "informix".cce_cheques_img
		where empresa = pempresa
		and cvebanco = pcvebanco
		and numcuenta = pnumcuenta
		and numcheque = pnumcheque
		and fechapresenta = pfechapresenta
		and imagen is null;

    IF v_existe > 0 THEN 
        LET v_codret = "130"; 
        RETURN v_codret;                 
    END IF;  
    
    END;    

    RETURN v_codret;

END PROCEDURE;