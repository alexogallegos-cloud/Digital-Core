CREATE PROCEDURE "informix".sp_actualiza_status_800(pFechaInicio Date, pFechaFinal Date)
  
  returning CHAR(5);

--******************************************************************************************
-- Define variables
--******************************************************************************************
	DEFINE cod_ret       		CHAR(5);
	DEFINE sql_err       		INTEGER;
	DEFINE vIdEmp		 		INTEGER;
	DEFINE cNumCteProspecto  	CHAR(10); 
	DEFINE cNumCteBanco      	CHAR(9);
	DEFINE cStatusNumctePros 	CHAR(2);
	DEFINE cStatusSolicitud 	CHAR(2);
	
	
	
--******************************************************************************************
-- Inicializa variables
--******************************************************************************************
   LET cod_ret		 	 = '00000';
   LET sql_err		 	 = 0;
   LET vIdEmp		 	 = 0;
   LET cNumCteProspecto  = '';
   LET cNumCteBanco      = '';
   LET cStatusNumctePros = '';
   LET cStatusSolicitud  = '';
  

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
   
	--SET DEBUG FILE TO 'sp_actualiza_status_800.out';
	--TRACE ON ;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
   
	FOREACH 
		    SELECT a.numcte_pros, c.numcte, a.status_numcte_pros, c.status_solicitud 
				INTO cNumCteProspecto, cNumCteBanco, cStatusNumctePros, cStatusSolicitud 
				FROM PR_CLIENTE A, bdisolic:ss_solicitudes C
				WHERE A.SUCURSAL = '0800'
				and a.numcte = c.numcte
				and a.fecha_insert BETWEEN pFechaInicio and pFechaFinal
				and c.fecha_insert BETWEEN pFechaInicio and pFechaFinal
				and tipo_solicitud = 'C'
				and status_numcte_pros not in ('RT','CP')
				and C.status_solicitud not in ('CN', 'AN')
				and c.fecha_hora IN (SELECT MAX(fecha_hora) FROM BDISOLIC:SS_SOLICITUDES where numcte = c.numcte)
				and c.fecha_insert >= a.fecha_insert
				order by 4,3
				
			LET cStatusSolicitud = TRIM(cStatusSolicitud);
			LET cStatusNumctePros = TRIM(cStatusNumctePros);
				
	IF cStatusSolicitud = 'AP' and  cStatusNumctePros = 'CN' THEN
				  UPDATE bdiprospectos:pr_cliente SET status_numcte_pros='CP' WHERE numcte=cNumCteBanco ;
			EXECUTE PROCEDURE bdiprospectos:sp_ctepr_actualizastatus('sistema', cNumCteProspecto, 'CP' , '' , '')
			INTO cod_ret;
			ELIF cStatusSolicitud = 'AT' and  cStatusNumctePros = 'CN' THEN
				  UPDATE bdiprospectos:pr_cliente SET status_numcte_pros='CP' WHERE numcte=cNumCteBanco ;
			EXECUTE PROCEDURE bdiprospectos:sp_ctepr_actualizastatus('sistema', cNumCteProspecto, 'CP' , '' , '')
			INTO cod_ret;				
			ELIF cStatusSolicitud = 'OA' and  cStatusNumctePros = 'CN' THEN
				  UPDATE bdiprospectos:pr_cliente SET status_numcte_pros='CP' WHERE numcte=cNumCteBanco ;
			EXECUTE PROCEDURE bdiprospectos:sp_ctepr_actualizastatus('sistema', cNumCteProspecto, 'CP' , '' , '')
			INTO cod_ret;				
			ELIF cStatusSolicitud = 'RT' and  cStatusNumctePros = 'CN' THEN
					UPDATE bdiprospectos:pr_cliente SET status_numcte_pros='CP' WHERE numcte=cNumCteBanco ;
			EXECUTE PROCEDURE bdiprospectos:sp_ctepr_actualizastatus('sistema', cNumCteProspecto, 'CP' , '' , '')
			INTO cod_ret;
	ENd IF;
		
    END FOREACH;

    END
    
    RETURN cod_ret;
    
END PROCEDURE;