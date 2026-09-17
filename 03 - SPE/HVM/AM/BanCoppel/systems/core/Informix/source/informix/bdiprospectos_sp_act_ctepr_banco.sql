CREATE PROCEDURE "informix".sp_act_ctepr_banco(pCteBanco CHAR(9),pRFC CHAR(13), pCteProsp CHAR(20))
RETURNING CHAR(6) AS CodRet;

	-- DECLARACION DE VARIABLES
	DEFINE cCodRet 			CHAR(6);
	DEFINE iSqlerr			INTEGER;
	

	-- INICIALIZA VARIABLES
	LET cCodRet = '000000';
	
	
	BEGIN
		ON EXCEPTION SET iSqlerr
			IF iSqlerr != 0 THEN
				LET cCodret = iSqlerr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/dbexportb/marioolivo/sp_ctepr_actualizasolcap.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- VALIDACION DE PARAMETROS --
		IF NVL(pCteBanco,'') = '' OR NVL(pRFC,'') = ''  THEN 
		-- SE VERIFICA QUE LOS PARAMETROS NO LLEGUEN VACIO
			LET cCodRet = '00001';
			RETURN cCodRet;
		END IF;	
		
				
			-- REALIZAR EL UPDATE A LA TABLA pr_cliente 
        IF ((SELECT numcte FROM "informix".pr_cliente WHERE rfc = pRFC AND numcte_pros = pCteProsp)='') THEN
            UPDATE "informix".pr_cliente
            SET numcte =  pCteBanco,
            estado=1
            WHERE rfc = pRFC
            AND numcte_pros = pCteProsp;

            IF DBINFO("sqlca.sqlerrd2") = 0 THEN
                LET cCodret = '000004';
            END IF;
        END IF;

		
		RETURN cCodret;

	END;
END PROCEDURE
