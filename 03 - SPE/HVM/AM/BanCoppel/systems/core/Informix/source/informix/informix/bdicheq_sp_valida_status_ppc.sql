CREATE PROCEDURE "informix".sp_valida_status_ppc(numcte CHAR(20), folioPres CHAR(20))
       RETURNING CHAR(5) AS cCodRet;

DEFINE cCodRet			CHAR(5); 
DEFINE iSqlErr          INTEGER; 
DEFINE iMonto           MONEY;
DEFINE cCuenta			CHAR(20);
DEFINE cSuc				CHAR(4);
DEFINE cFoliosuc        CHAR(16);


LET cCodRet = "00000";
LET iSqlErr =0;
LET iMonto =0;
LET cCuenta=" ";
LET cSuc= " ";
LET cFoliosuc=" ";


BEGIN

   ON EXCEPTION SET iSqlErr
        LET cCodRet=iSqlErr;
        RETURN cCodRet;
    
    END EXCEPTION;
	
		
	IF numcte ='' THEN
	  LET cCodRet='00001'; -- Parametro de entrada vacio
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	select monto_autorizado, sucursal into iMonto , cSuc
	from bdisolic:ss_prestamoscoppel WHERE numcte = numcte and folio_prestamo = folioPres and status_solicitud='P';
	 
	if iMonto > 0 or iMonto is not null then
	  
	  SELECT FIRST 1 cuenta into cCuenta
	  FROM BDICHEQ:sc_maechq WHERE num_cte = num_cte and sucursal= cSuc;
	  
	  if cCuenta is not null or cCuenta <> '' then
	  
		select folio_suc into cFoliosuc
		from bdicheq:sc_movdia where sucursal= cSuc and cuenta= cCuenta and monto_tot= iMonto and producto='2000';
	  
	    if NVL(cFoliosuc,'') = '' then
		
           select folio_suc into cFoliosuc
		   from bdicheq:sc_movhis where sucursal= cSuc and cuenta= cCuenta and monto_tot= iMonto and producto='2000';
        	   
		    if NVL(cFoliosuc,'') = '' then

               select folio_suc into cFoliosuc
		       from bdicheq:sc_movhis_old where sucursal= cSuc and cuenta= cCuenta and monto_tot= iMonto and producto='2000' ;
			   
			   if NVL(cFoliosuc,'') = '' then
			   
			      LET cCodRet='00003'; -- NO se encontro el prestamo			  
                  RETURN cCodRet;
			   else
			    
				   UPDATE bdisolic:informix.ss_prestamoscoppel SET status_solicitud = 'A'
                   WHERE numcte = numcte and folio_prestamo = folioPres and sucursal= cSuc and monto_autorizado= iMonto;
				   
				   LET cCodRet='00000'; 
			   end if;
			
            end if;			
		end if;
	  end if;
	  
	ELSE
	 LET cCodRet ='00002'; -- No existe el registro
	end if;
	RETURN cCodRet;
END;
END PROCEDURE
;