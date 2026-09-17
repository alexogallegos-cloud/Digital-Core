CREATE PROCEDURE "informix".sp_consimgnullcheque_web(pEmpresa CHAR(3), 
pNumCheq CHAR(7), 
pClaveBanco CHAR(3), 
pNumCuenta CHAR(20), 
pFechaAlta DATE)
RETURNING CHAR(5) AS codRet, CHAR(1) AS lado_A, CHAR(1) AS lado_B, CHAR(1) AS lado_F, CHAR(1) AS lado_t;
          
   DEFINE v_codret         CHAR(5);
   DEFINE lado             CHAR(1);
   DEFINE vNumLados        INT;
   DEFINE v_lado_A         CHAR(1);
   DEFINE v_lado_B         CHAR(1);
   DEFINE v_lado_F         CHAR(1);
   DEFINE v_lado_T         CHAR(1);
   DEFINE iimagen          CHAR(250);
   DEFINE sql_err,isam_err  INT;
-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "00001";
   LET iimagen      = "0";
   LET v_lado_A     = "1";
   LET v_lado_B     = "1";
   LET v_lado_F     = "1";
   LET v_lado_T     = "1";

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
BEGIN
   
ON EXCEPTION SET sql_err,isam_err
      IF sql_err <> 0 or isam_err <> 0 THEN
         LET v_codret = sql_err;
         RETURN v_codret, v_lado_A, v_lado_B, v_lado_F, v_lado_T;
      END IF;
   END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


IF pEmpresa IS NULL OR pNumCheq IS NULL OR pClaveBanco IS NULL OR pNumCuenta IS NULL OR  pFechaAlta IS NULL THEN
   	   LET v_codret = "00001";
	   RETURN v_codret, v_lado_A, v_lado_B, v_lado_F, v_lado_T;
	END IF;

SELECT COUNT(1) 
                INTO  vNumLados
                FROM "informix".cce_cheques_img
        WHERE empresa = pEmpresa
                AND cvebanco = pClaveBanco
                AND numcuenta = pNumCuenta
                AND numcheque = pNumCheq
                AND fecha_alta = pFechaAlta;


FOREACH
        SELECT lado_ft 
                INTO  lado
                FROM "informix".cce_cheques_img
        WHERE empresa = pEmpresa
                AND cvebanco = pClaveBanco
                AND numcuenta = pNumCuenta
                AND numcheque = pNumCheq
                AND fecha_alta = pFechaAlta
                AND (imagen IS NOT NULL)
                      
       	IF lado = 'A' THEN 
            LET v_lado_A  = "0";
        ELSE 
            IF lado = 'B' THEN 
            LET v_lado_B  = "0"; 
        ELSE 
            IF lado = 'F' THEN 
            LET v_lado_F  = "0";   
        ELSE 
            IF lado = 'T' THEN 
           LET v_lado_T  = "0"; 
        ELSE
                LET v_lado_A  = "1";
                LET v_lado_B  = "1";
                LET v_lado_F  = "1";
                LET v_lado_T  = "1";
           END IF;
          END IF;
        END IF;
     END IF
END FOREACH;
END; 

    IF vNumLados = 2  THEN
      IF v_lado_A = "0" AND v_lado_B  = "0" THEN
            LET v_codret     = "00000";
            LET v_lado_F  = "-";
            LET v_lado_T  = "-";
       END IF;
     ELSE
           IF v_lado_A = "0" AND v_lado_B  = "0" AND v_lado_F  = "0" AND v_lado_T  = "0" THEN
            LET v_codret     = "00000";
        END IF;
    END IF;

     RETURN v_codret, v_lado_A, v_lado_B, v_lado_F, v_lado_T;

END PROCEDURE;