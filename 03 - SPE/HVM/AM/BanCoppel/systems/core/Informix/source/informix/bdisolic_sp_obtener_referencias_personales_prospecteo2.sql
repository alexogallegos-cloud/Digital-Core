CREATE PROCEDURE "informix".sp_obtener_referencias_personales_prospecteo2(pNumcte 		 CHAR(20),
																		 pNum_solicitud  CHAR(20),
																		 pNumcte_Ref	 CHAR(20),
																		 pParentesco	 CHAR(2),
																		 pOpcion	     CHAR(1))
					
					
--DATOS A REGRESAR--
	RETURNING
	CHAR(6)   AS 	cCodRet,
	CHAR(20)  AS 	cNumCteRef,
	CHAR(104) AS	cNombreRef,
	CHAR(13)  AS 	cTelefono,
	CHAR(20)  AS 	cDescParentesco;
	
--DECLARACIONES
DEFINE cCodRet				CHAR(6);
DEFINE cNumCteRef			CHAR(20);
DEFINE cNombreRef		 	CHAR(104);
DEFINE cTelefono 			CHAR(13);
DEFINE cDescParentesco 		CHAR(20);
DEFINE iSqlErr				INTEGER;


--INICIALIZACIONES
LET cCodRet			 	= '000000';
LET cNumCteRef 			= '';
LET cNombreRef 			= '';
LET cTelefono			= '';
LET cDescParentesco		= '';
LET iSqlErr				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,"","","","";
	   END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/jesuslopez/sp_obtener_referencias_personales_prospecteo.out';
	--TRACE ON;
	
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

--VALIDA QUE LOS PARAMETROS NO ESTEN VACIOS
	IF pNumcte = '' OR pNum_solicitud = '' OR pOpcion = '' THEN
		LET cCodRet = '000001';
	ELSE
	
				SELECT 	LIMIT 1 a.numcte_ref,a.nombre_ref,a.telefono_ref,b.descripcion
				INTO   	cNumCteRef,cNombreRef,cTelefono,cDescParentesco
				FROM 	bdisolic: "informix".ss_refpersonales_prospecteo a, bdinteg: "informix".si_parentesco b
				WHERE 	a.parentesco 	= b.parentesco
				AND 	a.numcte 	  	= pNumcte
				AND a.status = 'A';
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '000002';
				END IF;
			
			 --END IF;
    END IF; 
	
	RETURN NVL(cCodRet,''),NVL(cNumCteRef,''),NVL(cNombreRef,''),NVL(cTelefono,''),NVL(cDescParentesco,'');
		
END;
END PROCEDURE	
