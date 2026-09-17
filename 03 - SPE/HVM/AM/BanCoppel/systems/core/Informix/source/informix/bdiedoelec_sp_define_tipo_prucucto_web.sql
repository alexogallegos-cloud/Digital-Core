CREATE PROCEDURE "informix".sp_define_tipo_prucucto_web
(
	pEmpresa CHAR(3),
	pProducto CHAR(4)
)
RETURNING 
CHAR(5) AS codRetorno,
CHAR(3) AS tipo;


DEFINE cCodRet CHAR(5);
DEFINE cTipoCuenta CHAR(2);
DEFINE iSql_err INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE iExiste INTEGER;

LET cCodRet = '00000';
LET cTipoCuenta = '';
LET iSql_err	 = 0;
LET iIsamErr	 = 0;
LET iExiste	 = 0;

BEGIN
    
    ON EXCEPTION SET iSql_err,iIsamErr
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet,cTipoCuenta;
        END IF;
    END EXCEPTION;  
    
      --SET DEBUG FILE TO "/respaldosbd/mario/sp_define_tipo_prucucto.out";
      --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	

	IF NVL(pEmpresa,'') <> '' AND NVL(pProducto,'') <> '' THEN	
	
		SELECT 1 INTO iExiste  FROM bdicred:"informix".sd_definicion WHERE empresa =pEmpresa AND num_producto = pProducto ;
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			SELECT 1 INTO iExiste FROM bdicheq:"informix".sc_producto WHERE empresa =pEmpresa AND producto = pProducto ;
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '00002';
			ELSE
				LET cTipoCuenta = 'SC';
			END IF;
		ELSE
			LET cTipoCuenta = 'SD';
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;

	RETURN cCodRet,cTipoCuenta;
	

END;
END PROCEDURE
DOCUMENT
"Folio:1602",
"Autor:951421354 Mario Gallardo",
"Fecha:16/05/2014",
"ModificaciÃ³n: Se crea SP para obtener el tipo de producto de las cuentas .",
"Sustento: RQI 12 231 Edo Cta EmisiÃ³n Consulta DisponibilizaciÃ³n y Respaldo OFI.pdf",
"Solicita: Rodolfo GÃ³mez ",
"BD: bdiedoelec";

CREATE PROCEDURE "informix".sp_ver_user_pass_web (pempresa char(3),pnumcte char(20)) 
    RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_numcte				CHAR(20);
	

    --SET DEBUG FILE TO  "sp_ver_user_pass"; 
    --TRACE ON;
	
	LET v_sCodRet = '00000';
	LET v_numcte = '000000000';
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		

		SELECT numcte
          INTO v_numcte	
		  FROM bdiedoelec:edelec_usr_pass WHERE numcte = pnumcte; 
		  
		 IF (v_numcte IS NULL OR v_numcte = '' ) THEN
		 
			LET v_sCodRet = '00001'; --Cliente No Existe
			RETURN v_sCodRet;
		
		ELSE
		
			RETURN v_sCodRet;    
		
		END IF

    END
END PROCEDURE;