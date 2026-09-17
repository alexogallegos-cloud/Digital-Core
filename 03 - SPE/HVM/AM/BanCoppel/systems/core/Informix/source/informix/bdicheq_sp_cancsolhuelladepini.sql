CREATE PROCEDURE "informix".sp_cancsolhuelladepini( pmarca_ret       CHAR(1),
                                              pempresa      CHAR(3),
                                              pcuenta     CHAR(20))                                            
RETURNING  CHAR (5);
 DEFINE codret CHAR (5);
 DEFINE iSqlErr INTEGER;
 
 LET codret = '00000';
 LET iSqlErr = 0;
BEGIN 
 ON EXCEPTION SET iSqlErr
  IF iSqlErr <> 0 THEN
   LET codret = iSqlErr;
   RETURN codret;  
  END IF;
 END EXCEPTION;

-- UPDATE bdinteg:sc_maechq SET marca_ret=pmarca_ret
 UPDATE bdicheq:sc_maechq SET marca_ret=pmarca_ret
 WHERE empresa = pempresa
 AND cuenta = pcuenta;
 
 RETURN codret;
END;
END PROCEDURE;