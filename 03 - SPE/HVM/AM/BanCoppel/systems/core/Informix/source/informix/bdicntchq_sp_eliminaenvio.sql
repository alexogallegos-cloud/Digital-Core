CREATE PROCEDURE "informix".sp_eliminaenvio(
pcuenta  char(20),
pconsec  char(10))
RETURNING CHAR(5);
--DECLARACION DE VARIABLES

DEFINE vc_CodRet    CHAR(5);
DEFINE vi_sqlerr        INTEGER;

LET vc_CodRet="00000";


  --SET DEBUG FILE TO "/tmp/sp_eliminaenvio.out";
  --TRACE ON;

BEGIN

  ON EXCEPTION SET vi_SqlErr
    IF vi_SqlErr <> 0 THEN
        LET vc_CodRet = vi_SqlErr;
        RETURN vc_CodRet;
    END IF;
  END EXCEPTION;

   
    update sq_maechqra set status='G' where cuenta=pcuenta and consec=pconsec;
    delete sq_envios  where num_cuenta=pcuenta and folio_chequera=pconsec;
    RETURN vc_CodRet WITH RESUME;
   

END;
END PROCEDURE;