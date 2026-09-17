CREATE PROCEDURE "informix".sp_obt_tipotkn(  pNumCliente char(9))
RETURNING CHAR(5), CHAR(15)

	------------------------------------------------------------------------------------------------------------------------------------
	--Elaboró: AVF
    --Actividad: 
    --Solicito: Beatriz Alcala
    --Fecha: 2018
  	------------------------------------------------------------------------------------------------------------------------------------	
	
	-- DECLARA
	DEFINE vCod_Ret char(5);
    DEFINE sql_err integer ;
	DEFINE vNumCliente char(9);
	DEFINE vNumtoken char(15);
    DEFINE pEmpresa char(3);
	
	-- INICIALIZA
	LET vCod_Ret = '00099';
	LET vNumCliente = '';
	LET vNumtoken = '';
    LET pEmpresa = '001';
 
	--SET DEBUG FILE TO "/home/informix/sp_obt_tipotkn.out";
    --TRACE ON;
	
	
	BEGIN
	ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret, vNumtoken;
		  END IF ;
		END EXCEPTION ;
		
		
		IF(pNumCliente<>'' OR pNumCliente IS NOT NULL) THEN
 		
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
			SELECT  SB.numcte, TK.ns_token
				INTO vNumCliente, vNumtoken				
				FROM bdinteg:si_bpiusuarios AS SB 
				LEFT OUTER JOIN bdinteg:"informix".si_bpitoken AS TK ON TK.num_cliente=SB.numcte				
				WHERE SB.numcte = TRIM(pNumCliente)  AND SB.empresa = pEmpresa ;
			
			IF(vNumCliente <>'' OR vNumCliente IS NOT NULL) AND (vNumtoken <>'' OR vNumtoken IS NOT NULL) THEN
				LET vCod_Ret = '00000';
			ELSE
				LET vCod_Ret='00002';			
			END IF;
			
		ELSE
			LET vCod_Ret='00001';		
		END IF;
		
		RETURN vCod_Ret, vNumtoken;
	END;
END PROCEDURE;