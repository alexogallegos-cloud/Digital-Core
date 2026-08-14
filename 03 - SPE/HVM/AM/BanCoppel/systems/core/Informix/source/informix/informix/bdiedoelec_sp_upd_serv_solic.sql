CREATE PROCEDURE "informix".sp_upd_serv_solic (pempresa char(3),pnumcte char(20),pcuenta char(20), pproducto char(4), pfecha_corte date, pstatus_envio_edocta CHAR(2)) 
    RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_pass_second_part   CHAR (4);
	DEFINE encry_pass           VARCHAR(20);
	
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_producto 			CHAR(4);


   -- SET DEBUG FILE TO  "sp_upd_serv_solic.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_producto = '';	

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		IF pstatus_envio_edocta NOT IN ('NE','AE')THEN
		
			LET v_sCodRet = '001'; -- Estatus No Valido
			RETURN v_sCodRet;
			
		END IF 
		
		IF EXISTS( SELECT numcte FROM bdiedoelec:edelec_serv_solic 
		            WHERE empresa = pempresa AND numcte = pnumcte 
					  AND cuenta = pcuenta  AND producto = pproducto 
					  AND fecha_corte = pfecha_corte AND fecha_vigencia >= TODAY ) THEN
		
		INSERT INTO bdiedoelec:"informix".edelec_log_serv_solic (empresa,numcte,cuenta,producto,fecha_corte,status_envio_edocta,fecha_modificacion)
		     VALUES (pempresa,pnumcte,pcuenta,pproducto,pfecha_corte,pstatus_envio_edocta,TODAY);
		
		END IF
		
		RETURN v_sCodRet;    
    END
END PROCEDURE;