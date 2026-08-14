CREATE PROCEDURE "informix".sp_obtrutasportabilidad (oper int)

    RETURNING  	CHAR(5),	-- COD-RET
				CHAR(50);   -- RUTA ARCHIVO

	DEFINE sql_err		INTEGER;
    DEFINE vcodret1     CHAR(5);	
    DEFINE vrutafisica	CHAR(50);
    DEFINE vrutaopcion  CHAR(14);
						
	LET vcodret1 = "000";
    LET sql_err  = 0;
    LET vrutafisica="";
	LET vrutaopcion="";

BEGIN
	
	------  Control de Errores no Controlados
		ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;    
            RETURN vcodret1, vrutafisica;
        END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/informix/VILLELA/sp_obtrutasportabilidad.out";
		--TRACE ON;
  
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
  
		IF NVL(oper, "")=""   THEN
			LET vcodret1 = "002";	
			RETURN vcodret1, vrutafisica;
		END IF;


        IF   oper=1 THEN
		   LET vrutaopcion='rta_ptsol';
        ELIF oper=2 THEN
		   LET vrutaopcion='rta_ptres';
        ELIF oper=3 THEN
		   LET vrutaopcion='rta_ptacu'; 
        ELIF oper=4 THEN
		  LET vrutaopcion='rta_canpor'; 
	    ELIF oper=5 THEN
		  LET vrutaopcion='rta_canpor_s';  

	   ELSE
           LET vcodret1='003';  -- OPCION NO VALIDA
           RETURN vcodret1, vrutafisica;
        END IF;
	
			SELECT valor
			INTO vrutafisica 
			FROM BDICHEQ:sc_param 
			WHERE empresa = "001" 
			AND codparam = vrutaopcion;
			
RETURN vcodret1, vrutafisica;

END;
END PROCEDURE;