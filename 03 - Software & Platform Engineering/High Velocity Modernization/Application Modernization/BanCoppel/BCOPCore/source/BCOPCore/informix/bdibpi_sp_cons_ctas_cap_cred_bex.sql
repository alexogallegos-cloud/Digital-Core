CREATE PROCEDURE "informix".sp_cons_ctas_cap_cred_bex(pEmpresa CHAR(3), pNumCte CHAR(20))
RETURNING CHAR(5), CHAR(20), CHAR(10), CHAR(100), CHAR(1);
    
    DEFINE vCodRet 		CHAR(5);
    DEFINE vCodRet2		CHAR(5);
    DEFINE vCodRet3		CHAR(80);
    DEFINE sql_err 		INTEGER;
    DEFINE isam_err		INTEGER;
    DEFINE desc_err		CHAR(80);
    DEFINE vCuenta	 	CHAR(20);
    DEFINE vProducto	CHAR(10);
    DEFINE vNombre		CHAR(100);
    DEFINE vTipo		CHAR(1);
    DEFINE iCont		INTEGER;
    DEFINE nCtaCap		INTEGER;
    DEFINE nCtaCred		INTEGER;
    DEFINE vNumcred	 	CHAR(20);
    DEFINE nMaxsec		INTEGER;

    LET vCodRet   = '00000';
    LET vCodRet2  = '';
    LET vCodRet3  = '';
    LET sql_err   = 0;
    LET isam_err  = 0;
    LET desc_err  = '';
    LET vCuenta	  = '';
    LET vProducto = '';
    LET vNombre	  = '';
    LET vTipo	  = '';
    LET iCont 	  = 0;
    LET nCtaCap   = 0;
    LET nCtaCred  = 0;
    LET vNumcred  = '';
    LET nMaxsec   = 0;

    BEGIN
    
	ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/informix/mpm/sp_cons_ctas_cap_cred_bex.err";
        TRACE ON;
		IF sql_err <> 0 THEN
			let vCodRet = sql_err;
            let vCodRet2 = isam_err;
            let vCodRet3 = desc_err;
			RETURN vCodRet, vCuenta, vProducto, vNombre, vTipo;
		END IF
	END EXCEPTION;

 	SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;
    
	IF NVL(pNumCte,'') = '' THEN
        LET vCodRet = '00002';
        RETURN vCodRet, vCuenta, vProducto, vNombre, vTipo;
	END IF;
	
    FOREACH
        SELECT mc.cuenta, mc.producto, pr.nombre, 1 as tipo
          INTO vCuenta, vProducto, vNombre, vTipo
          FROM bdicheq:"informix".sc_maechq as mc, 
               bdicheq:"informix".sc_producto AS pr
         WHERE mc.num_cte = pNumCte
           AND mc.status_cta IN ('1','3','4', '5')
           AND pr.producto = mc.producto
           AND mc.producto IN ('2000','1300','1400','1500','1800','1700','1900','2400','2500')
        
        LET iCont = iCont + 1;
        
        IF (iCont < 100 ) THEN
            RETURN vCodRet, vCuenta, vProducto, vNombre, vTipo WITH RESUME;
        END IF;
    END FOREACH;
        
    /* ##########################################################################################
    FOREACH
        SELECT mc.num_credito,
        mc.num_producto,
        df.nombre_prod, 
        2 as tipo
        INTO vNumcred, vProducto, vNombre,  vTipo
        FROM bdicred:"informix".sd_maecred as mc, bdicred:"informix".sd_definicion as df
        WHERE mc.numcte = pNumCte 
          AND mc.status_cred in ('AA','BA','BT')
          AND mc.num_producto IN ('6600','7000','8100','6001')
          AND df.num_producto = mc.num_producto

        LET nMaxsec = 0;
          
        SELECT MAX(secuencia) 
        INTO nMaxsec
        FROM bdicred:"informix".sd_tarjeta
        WHERE empresa = pEmpresa
        AND   num_credito = vNumcred
        AND  tipo_tarjeta = 'T';

        SELECT num_tarjeta 
        INTO vCuenta
        FROM bdicred:"informix".sd_tarjeta			
        WHERE empresa = pEmpresa
        AND   num_credito = vNumcred
        AND  secuencia = nMaxsec;		
        
        LET iCont = iCont + 1;
        IF(iCont < 100 ) THEN
            RETURN vCodRet, vCuenta, vProducto, vNombre,  vTipo	WITH RESUME;
        END IF;
    END FOREACH;
    ########################################################################################## */
	
	IF ( iCont = 0 ) THEN
        LET vCodRet = '00001'; --- Cliente No tiene cuentas
        RETURN vCodRet, vCuenta, vProducto, vNombre, vTipo;
    END IF;
    
    END;

END PROCEDURE;