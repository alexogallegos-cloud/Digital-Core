CREATE PROCEDURE "informix".sp_registra_clientehash_bpi(
                                           pEmpresa CHAR(3),
                                           pNumCliente CHAR(9),
                                           pNumClienteHash CHAR(64))
RETURNING CHAR (5);

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
				RETURN vCod_ret;
			END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
        

		IF NVL(pEmpresa,'') =='' OR NVL(pNumCliente,'') =='' OR NVL(pNumClienteHash,'') =='' THEN
            LET vCod_ret = '00001';
            RETURN vCod_ret;
        END IF;

               
        IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_cliente_hash WHERE empresa = pEmpresa AND numcte= pNumCliente) THEN
           LET vCod_ret = '00002';          
 
        ELSE               
            INSERT INTO bdinteg:"informix".si_cliente_hash(empresa,numcte,numctehash,fecharegistrohashbpi,banderabpi,banderaapp)
            VALUES (pEmpresa,pNumCliente,pNumClienteHash,CURRENT, '1','0');
        END IF;
       

		RETURN vCod_ret;
	END;
END PROCEDURE;