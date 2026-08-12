CREATE PROCEDURE "informix".sp_cnsif_consulta_telefonos(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
RETURNING CHAR(5),CHAR(20),SMALLINT,CHAR(13),CHAR(5);
          
    DEFINE iexiste 			INT;
    DEFINE cCodRet 			CHAR(5);
    DEFINE iSql_err 		INT;	
 
    DEFINE cTipoTel         CHAR(20);   
    DEFINE sSecuencia       SMALLINT;
    DEFINE vTelefono        CHAR(13);
    DEFINE vExtension       CHAR(5);
    DEFINE iCont INTEGER;

    LET  iexiste = 0;
    LET cCodRet = "00000";
    LET iSql_err = 0 ;	
    LET cTipoTel       = '';
    LET sSecuencia        =0;
    LET vTelefono         = '';
    LET vExtension      = '';
    LET iCont=0;
    
    BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
		END IF;
	END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/VH/sp_consulta_telefonos.out";
    --- TRACE ON;

    -- // VALIDA PARAMETROS DE ENTRADA
	IF 	cID_USUARIOC = '' OR
		cID_FUNCIONC = '' OR
		cNUMCTE  = ''     THEN 
        LET cCodRet = "00054";
        RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
        END IF;
    END IF;  
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCTE,'11','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
	END IF;
	-- TERMINA VALIDACION
    SELECT NVL(COUNT(numcte),0)  INTO iexiste FROM si_telefonos WHERE numcte = cNUMCTE;
    IF iexiste = 0 THEN 
        LET cCodRet = "00096";
        RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
    END IF;	    
    SET ISOLATION TO DIRTY READ;
    
        FOREACH
            SELECT SKIP pNumRegistro FIRST pRecuperacion 
			   CASE
			   WHEN tipo_tel = 1 THEN 
				'TEL. PARTICULAR'
			   WHEN tipo_tel = 2 THEN 
				'TEL. MOVIL'
			   WHEN tipo_tel = 3 THEN 
				'TEL. TRABAJO'
			   WHEN tipo_tel = 4 THEN 
				'OTRO'
			   ELSE 
				' '
			   END AS tipo_TEL,secuencia,telefono, extension
              INTO cTipoTel, sSecuencia, vTelefono, vExtension
              FROM si_telefonos
             WHERE numcte = cNUMCTE
             ORDER BY secuencia DESC
             
            LET iCont=iCont+1;  
            RETURN cCodRet,cTipoTel, sSecuencia, vTelefono, vExtension WITH RESUME;
        END FOREACH;
        IF iCont = 0 THEN
            LET cCodRet = '1001'; 
            RETURN cCodRet,cTipoTel, sSecuencia, vTelefono, vExtension;
        END IF 	
END
END PROCEDURE;