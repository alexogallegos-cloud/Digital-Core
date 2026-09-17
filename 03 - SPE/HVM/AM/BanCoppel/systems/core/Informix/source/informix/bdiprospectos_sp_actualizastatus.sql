CREATE PROCEDURE "informix".sp_actualizastatus() 
												 
   returning CHAR(5);

--******************************************************************************************
-- Define variables
--******************************************************************************************
	DEFINE cod_ret       CHAR(5);
	DEFINE sql_err       INTEGER;
	DEFINE cNumCte       CHAR(20); 
	DEFINE cNumSolic     CHAR(20);
	DEFINE cStatusSolic	 CHAR(1);
	DEFINE cCodRet2       CHAR(5);
	
	
--******************************************************************************************
-- Inicializa variables
--******************************************************************************************
   LET cod_ret		 = '00000';
   LET cCodRet2		 = '';
   LET sql_err		 = 0;
   LET cNumCte		 = '';
   LET cNumSolic     = '';
   LET cStatusSolic  = '';
  

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
   
	--SET DEBUG FILE TO 'sp_AutomaSolCobranza.out';
	--TRACE ON ;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    FOREACH 
		
		SELECT pr.numcte_pros, pnp.num_solicitud, pnp.status_solicitud
		  INTO cNumCte, cNumSolic,cStatusSolic
		FROM pr_cliente pr
		INNER JOIN pr_nuevo_parametrico pnp ON pnp.num_solicitud = pr.numcte_pros
		WHERE pr.status_numcte_pros = 'EC' AND pr.envio_parametrico = 2			
		
			EXECUTE PROCEDURE "informix".sp_ctepr_continuaenviocoppel('001', cNumSolic, cStatusSolic);
			
		
    END FOREACH;

    END
    
    RETURN cod_ret;
    
END PROCEDURE;