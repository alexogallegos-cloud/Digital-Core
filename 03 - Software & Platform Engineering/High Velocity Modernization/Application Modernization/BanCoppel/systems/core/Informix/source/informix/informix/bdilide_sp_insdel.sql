CREATE PROCEDURE "informix".sp_insdel(pTipoOpera CHAR(1),  pNumCte CHAR(20), pFechaCargo CHAR(10), pCuenta CHAR(20), pPeriodo CHAR(7), pImporte MONEY)
RETURNING
 CHAR (5);
--Declaracion de Variables
DEFINE vcCodRet     CHAR(5);
DEFINE vsqlerr  integer;
--Inicializacion de Variables
LET vcCodRet = "00000";
LET vsqlerr = 0;

 BEGIN

        ON EXCEPTION  SET vsqlerr
                IF vsqlerr <> 0  THEN                  
                     LET  vcCodRet  = vsqlerr;
                     RETURN vcCodRet;
                END IF;
         END  EXCEPTION;
         
         IF pTipoOpera = "1" THEN
                    DELETE bdilide:sl_recaudaciones;
         ELIF pTipoOpera = "2" THEN
                    INSERT INTO sl_recaudaciones VALUES(pNumCte, pFechaCargo, pCuenta, pPeriodo, pImporte);
         END IF;
         RETURN vcCodRet;
END;
END PROCEDURE;