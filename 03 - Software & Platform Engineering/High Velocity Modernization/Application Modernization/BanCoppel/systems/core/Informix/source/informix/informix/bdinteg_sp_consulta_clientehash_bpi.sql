CREATE PROCEDURE "informix".sp_consulta_clientehash_bpi(pEmpresa CHAR(3), pNumCliente CHAR(9))
RETURNING CHAR (5), CHAR (64);

	DEFINE sql_err int;
	DEFINE vNumCteHash CHAR (64);
    DEFINE vBanderaBpi CHAR (1);
    DEFINE vCod_ret CHAR (5);
  	
    LET vNumCteHash = '';
    LET vBanderaBpi = '';
    LET vCod_ret = '00000';
        

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCod_ret = sql_err;
				RETURN vCod_ret,vNumCteHash;
			END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
        

		IF NVL(pEmpresa,'') =='' OR NVL(pNumCliente,'') =='' THEN
            LET vCod_ret = '00001';
            RETURN vCod_ret,vNumCteHash;
        END IF;

        SELECT numctehash, banderabpi INTO vNumCteHash, vBanderaBpi
        FROM bdinteg:"informix".si_cliente_hash WHERE empresa = pEmpresa AND numcte= pNumCliente;
        
        IF NVL(vNumCteHash,'') =='' THEN
            LET vCod_ret='00002';
            RETURN vCod_ret,vNumCteHash;          
        END IF;  

        IF vBanderaBpi == '0' THEN
            UPDATE bdinteg:"informix".si_cliente_hash SET fecharegistrohashbpi = CURRENT , banderabpi = '1' 
            WHERE empresa = pEmpresa AND numcte= pNumCliente;    
          
         END IF;
       

		RETURN vCod_ret,vNumCteHash;
	END;
END PROCEDURE;