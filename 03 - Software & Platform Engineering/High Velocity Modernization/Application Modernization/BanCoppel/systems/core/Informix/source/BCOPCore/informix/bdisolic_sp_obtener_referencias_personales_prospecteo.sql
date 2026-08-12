CREATE PROCEDURE "informix".sp_obtener_referencias_personales_prospecteo(pNumcte 		 CHAR(20),
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
DEFINE ptipo_movimiento     CHAR(1);
DEFINE pnum_solicitud_ref    CHAR(20);

--INICIALIZACIONES
LET cCodRet			 	= '000000';
LET cNumCteRef 			= '';
LET cNombreRef 			= '';
LET cTelefono			= '';
LET cDescParentesco		= '';
LET iSqlErr				= 0;
LET ptipo_movimiento    = '';
LET pnum_solicitud_ref   = '';

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,"","","","";
	   END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/sp_obtener_referencias_personales_prospecteo.out';
	--TRACE ON;
	
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

--VALIDA QUE LOS PARAMETROS NO ESTEN VACIOS
	IF pNumcte = '' OR pNum_solicitud = '' OR pOpcion = '' THEN
		LET cCodRet = '000001';
	ELSE
	        --RGH
	        IF substr(pNum_solicitud, 0, 2) = '65' THEN
	            SELECT tipo_movimiento, num_solicitud_ref INTO ptipo_movimiento, pnum_solicitud_ref from bdisolic:ss_resum_scor_fin where empresa = '001' and num_solicitud = pNum_solicitud;
	            IF ptipo_movimiento = 'M' THEN
	                LET pNum_solicitud = pnum_solicitud_ref;
	            END IF;
	        END IF;
	        --RGH
	            	            
			IF TRIM(pParentesco) = 'E' THEN 

			
				IF TRIM(pOpcion) = '1' THEN --Cliente hereda informaciÃÂ³n de esposo(a) de prospecteo en el soltar 
				
					SELECT  LIMIT 1 a.numcte_ref,a.nombre_ref,a.telefono_ref,b.descripcion
					INTO 	cNumCteRef,cNombreRef,cTelefono,cDescParentesco
					FROM  	bdisolic: "informix".ss_refpersonales_prospecteo a, bdinteg: "informix".si_parentesco b
					WHERE 	a.parentesco 	= b.parentesco
					AND   	a.numcte		= pNumcte
					AND 	a.num_solicitud = pNum_solicitud
					AND   	a.parentesco 	= pParentesco;
					
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '000002';
				END IF;
				
				ELIF TRIM(pOpcion) = '2' THEN --Cliente hereda informaciÃÂ³n de esposo(a) de otra solicitud de crÃÂ©dito en prospecteo
				
					SELECT  LIMIT 1 a.numcte_ref,a.nombre_ref,a.telefono_ref,b.descripcion
					INTO 	cNumCteRef,cNombreRef,cTelefono,cDescParentesco
					FROM  	bdisolic: "informix".ss_refpersonales_prospecteo a, bdinteg: "informix".si_parentesco b
					WHERE 	a.parentesco 	= b.parentesco
					AND   	a.numcte		= pNumcte
					AND   	a.parentesco 	= pParentesco
					AND   	a.status 		= 'A';
				END IF;

				
			 ELSE --Cliente hereda informaciÃÂ³n de la primera referencia del sistema de prospecteo al soltar
			
				SELECT 	LIMIT 1 a.numcte_ref,a.nombre_ref,a.telefono_ref,b.descripcion
				INTO   	cNumCteRef,cNombreRef,cTelefono,cDescParentesco
				FROM 	bdisolic: "informix".ss_refpersonales_prospecteo a, bdinteg: "informix".si_parentesco b
				WHERE 	a.parentesco 	= b.parentesco
				AND 	a.numcte 	  	= pNumcte
				AND 	a.num_solicitud = pNum_solicitud
				AND 	a.numcte_ref	= pNumcte_Ref;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '000002';
				END IF;
			
			 END IF;
    END IF; 
	
	RETURN NVL(cCodRet,''),NVL(cNumCteRef,''),NVL(cNombreRef,''),NVL(cTelefono,''),NVL(cDescParentesco,'');
		
END;
END PROCEDURE	
