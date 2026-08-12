CREATE PROCEDURE "informix".sp_obtener_referencias(pEmpresa CHAR(20), pNumcte CHAR(20),pNum_solicitud  CHAR(20))
					
					
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
DEFINE cEstadoCivil 		CHAR(20);
DEFINE iSqlErr				INTEGER;

--INICIALIZACIONES
LET cCodRet			 	= '000000';
LET cNumCteRef 			= '';
LET cNombreRef 			= '';
LET cTelefono			= '';
LET cDescParentesco		= '';
LET cEstadoCivil		= '';
LET iSqlErr				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,"","","","";
	   END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/e99804975/DUD-Cobranza/Liberar/sp_obtener_referencias.out';
	--TRACE ON;
	
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

--VALIDA QUE LOS PARAMETROS NO ESTEN VACIOS
	IF pEmpresa = ''  OR pNumcte = '' OR pNum_solicitud = ''   THEN
		LET cCodRet = '000001';
	ELSE 
			 
			 
		select numcte_ref as cNumCteRef, trim(nombre1) || ' '|| trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno) as cNombreRef, 
		d.telefono2,p.descripcion
		INTO cNumCteRef,cNombreRef,cTelefono,cDescParentesco
		from bdinteg: si_refclientes r 
		inner join bdinteg:"informix".si_refdirecciones d on r.numcte = d.numcte and r.secuencia = d.secuencia
		inner join  bdinteg: "informix".si_parentesco p on r.parentesco = p.parentesco
		where r.empresa= pEmpresa 
		and r.numcte =pNumcte
		and r.num_solicitud =pNum_solicitud;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002';
		END IF;
		 
    END IF; 
	
	RETURN NVL(cCodRet,''),NVL(cNumCteRef,''),NVL(cNombreRef,''),NVL(cTelefono,''),NVL(cDescParentesco,'');
		
END;
END PROCEDURE	
