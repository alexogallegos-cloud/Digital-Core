CREATE PROCEDURE "informix".sp_elimina_huellas_vacias() RETURNING CHAR(5) AS cod_retorno;



--DEFINICION DE VARIABLES
DEFINE vcodRet 		    VARCHAR(6); 	-- CODIGO DE RETORNO
DEFINE iSqlErr      	integer;
DEFINE cMensaje		    VARCHAR(100);
DEFINE nContador        INT;
DEFINE nfecha			DATE;
DEFINE pnumcte			CHAR(20);


--INICIALIZACION DE VARIABLES
LET vcodRet 			= '00000';
LET iSqlErr             = 0;
LET cMensaje		    = 'ERROR EN PASO: ';
LET nContador       	= 0;
LET nfecha				= '';
LET pnumcte				= '';


	
BEGIN 
			ON EXCEPTION SET iSqlErr
						IF iSqlErr <> 0 THEN
							LET vcodRet = iSqlErr;
						END IF;
			END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/tmp/masv/huellas/sp_elimina_huellas_vacias.out";
		--TRACE ON;
	
		Select fecha_hoy into nfecha from si_fechas;
		
		FOREACH WITH HOLD
		
			select cte_hu.numcte into pnumcte from si_cte_huella cte_hu 
			join si_cliente cte ON cte.numcte  =  cte_hu.numcte
			where cte_hu.fecha_alta = nfecha 
			and cte_hu.dmapa LIKE 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%' 
			and cte.tipo_cliente = 2

			select count(*) into nContador from si_cte_huella_resp resp where resp.numcte = pnumcte;
			
			IF nContador <> 0 THEN 
			
				delete from si_cte_huella_resp resp where  resp.numcte = pnumcte;			
				delete from si_cte_huella cte_hu where cte_hu.numcte = pnumcte;
			end if;
			
			IF nContador == 0 THEN 
				delete from si_cte_huella cte_hu where cte_hu.numcte = pnumcte;
			end if;
			
		END FOREACH; 
		
	LET vCodRet ='00000';
	
	

	return vCodRet;
END;
END PROCEDURE ;