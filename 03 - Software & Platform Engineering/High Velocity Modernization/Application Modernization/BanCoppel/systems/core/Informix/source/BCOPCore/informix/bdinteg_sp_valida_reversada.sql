CREATE PROCEDURE "informix".sp_valida_reversada (pIdSucursal CHAR(4),
                                                 pFolioOperacion CHAR(16),
                                                 pTipoOperacion CHAR(2))
                                                 
RETURNING CHAR(5) AS cod_ret;

--- DECLARACION DE VARIABLES

	DEFINE vCodRet     CHAR(5);
	DEFINE iSqlErr     INTEGER;
      
  DEFINE vCiclo      CHAR(1);
    
			
--- INICIALIZACION DE VARIABLES


	LET vCodret       = '00000';
	LET iSqlErr       = '0';
      
  LET vCiclo        = '';
    
     --****************************************************************
     -- Creado por Raúl Ramírez    07/Septiembre/2010
     -- Proceso para validar transacciones reversadas para la traducción
     -- de boletos a un detalle de boletos
     --****************************************************************

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				 LET vCodRet = iSqlErr;
				RETURN vCodret;		
			END IF;
		END EXCEPTION;

       -- SET DEBUG FILE TO "/ids10_uc9/raul/sorteo/sp_valida_reversada.out";
       -- TRACE ON;


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    

        IF pTipoOperacion = '10' THEN 
						--Para debito
						--IF EXISTS (SELECT {+INDEX (bdicheq:sc_movdia idx_movdia2a)} -- BGM 09-Nov-2010: se coloca directiva
						                 --empresa, cuenta, fech_alt, cancelad, transacc, folio_suc 
									     --FROM bdicheq:sc_movdia
									     --WHERE empresa is not null
										 --WHERE folio_suc  = pFolioOperacion     -- BGM 09-Nov-2010: se cambia condición
									     -- AND cuenta is not null    			-- BGM 09-Nov-2010: se comenta condición
									     --AND empresa = '001'
									     --AND fech_alt is not null   			-- BGM 09-Nov-2010: se comenta condición
									     --AND transacc is not null   			-- BGM 09-Nov-2010: se comenta condición
									     --AND cancelad = 'S') THEN
			IF EXISTS (SELECT {+INDEX (bdinteg:si_movreversados idx_si_movrever)} empresa, folio_suc 
				FROM bdinteg:si_movreversados
				WHERE empresa = '001'
				AND folio_suc  = pFolioOperacion     -- BGM 16-Nov-2010: se cambia tabla a si_movreversados
				AND tipo_mov = pTipoOperacion) THEN
				LET vCiclo = 'S';
						--ELSE
						--	    IF EXISTS (SELECT {+INDEX (bdicheq:sc_movdia idx_movdia2a)}  -- BGM 09-Nov-2010: se coloca directiva
						--		  empresa,folio_suc    
                        --    FROM bdicheq:sc_movdia
						--				         WHERE folio_suc  = pFolioOperacion
						--				         AND  empresa = '001'
						--				         AND cancelad = 'S') THEN
						--                
                        --     LET vCiclo = 'S';
						--	    END IF;	
			END IF;
        END IF;
        IF pTipoOperacion = '11' THEN
          	
						--IF vCiclo <> 'S' THEN
              --Para credito
							--IF EXISTS (SELECT {+INDEX (bdicred:sd_movdia mov2)}  -- BGM 09-Nov-2010: se coloca directiva
							 --folio_suc 
                        --FROM bdicred:sd_movdia
								        --WHERE sucursal = pIdSucursal
								        --AND  folio_suc = pFolioOperacion
								        --AND reversado = 'S') THEN
						            --LET vCiclo = 'S';								
						  --ELSE
						    	--IF EXISTS(SELECT {+INDEX (bdicred:sd_movdia mov2)}  -- BGM 09-Nov-2010: se coloca directiva
								   --folio_suc --, codigo_fun, codigo_ref             -- BGM 09-Nov-2010: se omiten datos que no se usan
                              --FROM bdicred:sd_movdia 
									   		--	    WHERE folio_suc = pFolioOperacion 
										    --		AND codigo_fun is not null
										    --		AND codigo_ref is not null
										  	--	    AND reversado = 'S') THEN
			IF EXISTS (SELECT {+INDEX (bdinteg:si_movreversados idx_si_movrever)} empresa, folio_suc 
				FROM bdinteg:si_movreversados
				WHERE empresa = '001'
				AND folio_suc  = pFolioOperacion     -- BGM 16-Nov-2010: se cambia tabla a si_movreversados
				AND tipo_mov = pTipoOperacion) THEN
				LET vCiclo = 'S'; 
				   
			END IF;
		END IF;	
		
          	
		IF vCiclo = 'S' THEN
             LET vCodRet = '00101';
             --LET vMensaje = 'Folio Reversado';
        END IF;
END
    RETURN vCodret; --, vMensaje;

END PROCEDURE;