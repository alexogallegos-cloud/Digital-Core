CREATE PROCEDURE "informix".sp_guardar_referencia_prospecteo_web(pEmpresa 		 CHAR(3),
															  pNum_solicitud CHAR(20),
															  pNumcte	 	 CHAR(20),
															  pNumcte_ref	 CHAR(20),
															  pParentesco 	 CHAR(2),
															  pTipo_relacion CHAR(2),
															  pNombre_ref 	 CHAR(104),
															  pTelefono_ref  CHAR(13))
										
--DATOS A REGRESAR--
	RETURNING
	CHAR(5)   AS 	cCodRet;
	
--DECLARACIONES
DEFINE cCodRet	CHAR(5);
DEFINE iSqlErr	INTEGER;


--INICIALIZACIONES
LET cCodRet		= '00000';
LET iSqlErr		= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/jesuslopez/sp_guardar_referencia_prospecteo.out';
	--TRACE ON;
		
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

--VALIDA QUE LOS PARAMETROS NO ESTEN VACIOS
	IF pEmpresa = '' OR pNum_solicitud = '' OR pNumcte = ''  OR pNumcte_ref = '' OR pParentesco = '' OR pTipo_relacion = '' OR pNombre_ref = '' OR pTelefono_ref = '' THEN
		LET cCodRet = '00001';
	ELSE
		UPDATE bdisolic: "informix".ss_refpersonales_prospecteo SET status='C'
		WHERE empresa = pEmpresa
		AND numcte = pNumcte;

		INSERT INTO bdisolic: "informix".ss_refpersonales_prospecteo 
		(empresa,num_solicitud,numcte,numcte_ref,parentesco,tipo_relacion,nombre_ref,telefono_ref,status) 
		VALUES
		(pEmpresa,pNum_solicitud,pNumcte,pNumcte_ref,pParentesco,pTipo_relacion,pNombre_ref,pTelefono_ref,'A');
		
    END IF; 
	
	RETURN cCodRet;
		
END;
END PROCEDURE	
