CREATE PROCEDURE "informix".sp_identcte_pros_referencias(pEmpresa CHAR(3), 
											 pPrimerNombre CHAR(26), 
											 pSegundoNombre CHAR(26), 
											 pApellidoPat CHAR(26),
											 pApellidoMat CHAR(26), 
											 pFechaNacimiento DATE)

--DATOS A REGRESAR---
RETURNING CHAR(5)   AS Retorno, 
          CHAR(20)  AS RFC,
		  CHAR(20)  AS NumeroCliente, 
		  CHAR(20)  AS NumeroClienteProspecto, 
		  CHAR(4)   AS TipoCliente,   
		  CHAR(20)  AS Estatus,
		  CHAR(20)  AS NumeroClienteCoppel,
		  CHAR(20)  AS IndCuestParametrico,
		  CHAR(20)  AS Edad;	
		  
-- DEFINICION DE VARIABLES
	DEFINE cCod_ret      		  	 CHAR(6);
	DEFINE rfc       	 		 	 CHAR(13);
    DEFINE cNumCte      		 	 CHAR(20);
    DEFINE cNumCtePros     			 CHAR(26);
	DEFINE cTipoCliente			 	 CHAR(1);
    DEFINE cEstatus     	 		 CHAR(20);
	DEFINE cNumCteCoppel			 CHAR(26);
	DEFINE cIndicadorCuestPara    	 CHAR(20);
	DEFINE cEdad			    	 CHAR(20);
	DEFINE cMensaje 				 CHAR(100);
	DEFINE cCod_retEdad      		 CHAR(5);
	DEFINE vCodRet          		 CHAR(5);
	DEFINE vNumCte          		 CHAR(20);
	DEFINE vApell_Paterno     		 CHAR(26);
	DEFINE vApell_Materno  			 CHAR(26);
	DEFINE vNombre1 		         CHAR(26);
	DEFINE vNombre2			         CHAR(26);
	DEFINE vRfc			             CHAR(13);
	DEFINE vFechaNacimiento			 CHAR(10);
	DEFINE cCod_retCteRel	         CHAR(5);
	DEFINE cCod_retCtePros		     CHAR(5);
	DEFINE cTp_cte					 CHAR(1);
	DEFINE iSqlErr			      	 INTEGER;

    DEFINE vcCodRet			         CHAR(5);
    DEFINE vcNumPros		         CHAR(20);
    DEFINE vcNombre1		         CHAR(26);
    DEFINE vcNombre2		         CHAR(26);
    DEFINE vcApellPaterno		     CHAR(26);
    DEFINE vcApellMaterno		     CHAR(26);
    DEFINE vdFechaNac		         DATE;
    DEFINE vcRfc            		 CHAR(13);
    DEFINE vcCurp           		 CHAR(20);
    DEFINE vcSexo           		 CHAR(1);
    DEFINE vcEdoCivil       		 CHAR(2);
    DEFINE vcApellCasada    		 CHAR(26);
    DEFINE vcNacionalidad   		 CHAR(3);
    DEFINE vcFM3            		 CHAR(18);
    DEFINE vcOcupacion      		 CHAR(3);
    DEFINE vcTipoCasa       		 CHAR(2);
    DEFINE vcDependientes   		 CHAR(60);
    DEFINE vcTipoId         		 CHAR(2);
    DEFINE vcNumId          		 CHAR(30);
    DEFINE vcCorreo         		 CHAR(100);
	DEFINE vCantReg         		 smallint;
	
--INICIALIZACION DE VARIABLES
	LET cCod_ret     	 	 = "000000";
	LET rfc    	 	  		 = "";
	LET cNumCte    	 	 	 = "";
	LET cNumCtePros    	 	 = "";
	LET cEstatus     	     = "";
	LET cTipoCliente	     = "";
	LET cNumCteCoppel     	 = "";
	LET cIndicadorCuestPara  = "";
	LET cEdad   			 = "";
	LET cMensaje   			 = "";
	LET cCod_retEdad    	 = "000";
	LET vCodRet 			 = "00000";
	LET vNumCte 			 = "";
	LET vApell_Paterno		 = "";
	LET vApell_Materno		 = "";
	LET vNombre1			 = "";
	LET vNombre2			 = "";
	LET vRfc				 = "";
	LET vFechaNacimiento	 = "";
	LET cCod_retCteRel		 = "00000";
	LET cCod_retCtePros		 = "00000";
	LET iSqlErr	        	 = 0;
	LET cTp_cte				 = '';
	
    LET vcCodRet       		 = '00000';   
    LET vcNumPros     	 	 = '';
    LET vcNombre1      		 = '';
    LET vcNombre2      		 = '';
    LET vcApellPaterno 		 = '';
    LET vcApellMaterno 		 = '';
    LET vdFechaNac     		 = '';
    LET vcRfc          		 = '';
    LET vcCurp         		 = '';
    LET vcSexo         		 = '';
    LET vcEdoCivil     		 = '';
    LET vcApellCasada  		 = '';
    LET vcNacionalidad 		 = '';
    LET vcFM3          		 = '';
    LET vcOcupacion    		 = '';
    LET vcTipoCasa     		 = '';
    LET vcDependientes 		 = '';
    LET vcTipoId       		 = '';
    LET vcNumId        		 = '';
    LET vcCorreo       		 = '';
	LET vCantReg = 0;
	
	--SET DEBUG FILE TO 'sp_indetcte_pros.out';
	--TRACE ON;

	-- INICIO DEL PROCEDIMIENTO
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','';
			END IF;
		END EXCEPTION; 
		
	SET LOCK MODE TO WAIT 3;
	
IF (pApellidoPat = '') OR (pApellidoPat IS NULL) THEN
	RETURN '000020',rfc,cNumCte,cNumCtePros,cTipoCliente,cEstatus,cNumCteCoppel,cIndicadorCuestPara,cEdad;
		ELIF (pPrimerNombre = '') OR (pPrimerNombre IS NULL) THEN
				RETURN '000020',rfc,cNumCte,cNumCtePros,cTipoCliente,cEstatus,cNumCteCoppel,cIndicadorCuestPara,cEdad;
					ELIF (pFechaNacimiento = '') OR (pFechaNacimiento IS NULL) THEN
						RETURN '000020',rfc,cNumCte,cNumCtePros,cTipoCliente,cEstatus,cNumCteCoppel,cIndicadorCuestPara,cEdad;
		ELSE
		Call bdinteg:"informix".sp_calcularfc(pEmpresa, pApellidoPat, pApellidoMat, pPrimerNombre ,pSegundoNombre ,pFechaNacimiento) 
			 RETURNING cCod_ret, cMensaje, rfc;
				IF cCod_ret = "000000" THEN
						LET cCod_ret = cCod_ret; 
						LET cMensaje = cMensaje;
						LET rfc = rfc;
						ELSE
						RETURN cCod_ret,rfc,cNumCte,cNumCtePros,cTipoCliente,cEstatus,cNumCteCoppel,cIndicadorCuestPara,cEdad;		
		END IF		
END IF;	
	
IF cCod_ret = "000000" AND rfc IS NOT NULL THEN
	Call bdinteg:"informix".sp_obteneredadpersona(today , pFechaNacimiento)
		RETURNING  cCod_retEdad, cEdad;
		LET cEdad = TRIM(cEdad);		
		IF (cEdad IS NULL) OR (cEdad = "") THEN
			LET cCod_ret = "002";
				RETURN cCod_ret,rfc,cNumCte,cNumCtePros,cTipoCliente,cEstatus,cNumCteCoppel,cIndicadorCuestPara,cEdad;
		END IF;
END IF;


		Call bdicheq:"informix".consdatadic(pEmpresa, rfc)
		RETURNING vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vFechaNacimiento;
		IF vCodRet = "00000" AND 
		   vNumCte IS NOT NULL AND vNumCte <> "" AND vApell_Paterno = pApellidoPat AND vApell_Materno = pApellidoMat AND  vNombre1 = pPrimerNombre AND
		   vNombre2 = pSegundoNombre AND vFechaNacimiento = pFechaNacimiento THEN	
		   LET cNumCte = vNumCte;
		ELIF vCodRet = "253" THEN
			LET cCod_ret = "00000";
		ELSE
			--LET cCod_ret = "00020"; JLM - Se comenta para no validar RFC en REFERENCIAS CC 32395
			RETURN cCod_ret,rfc,cNumCte,cNumCtePros,cTipoCliente,cEstatus,cNumCteCoppel,cIndicadorCuestPara,cEdad;
		END IF;
 
 
IF  vCodRet = "00000" AND cNumCte IS NOT NULL THEN
		Call bdinteg:"informix".sp_consultactesrelacionados_cop(pEmpresa, cNumCte)
			RETURNING cCod_retCteRel, cNumCteCoppel;
			if cCod_retCteRel = "00001" THEN
				LET cCod_retCteRel = "00000"; 
			END IF;		
END IF;

LET rfc = TRIM(rfc);

IF (rfc IS NOT NULL) OR (rfc <> "") THEN
	Call bdiprospectos:"informix".sp_consctepros(pEmpresa, rfc)
		RETURNING cCod_retCtePros, cNumCtePros;
		
			IF cCod_retCtePros = "00000" AND trim(cNumCtePros) <> "" THEN
				Call bdiprospectos:"informix".sp_conspros_ctepf(pEmpresa, cNumCtePros)
				RETURNING vcCodRet,vcNumPros,vcNombre1,vcNombre2,vcApellPaterno,vcApellMaterno,vdFechaNac,vcRfc,vcCurp,vcSexo,vcEdoCivil,vcApellCasada,vcNacionalidad,vcFM3,vcOcupacion,vcTipoCasa,vcDependientes,vcTipoId,vcNumId,vcCorreo;
								IF vcCodRet = "00000" AND 
								   cNumCtePros IS NOT NULL AND cNumCtePros <> "" AND
								   vcApellPaterno = pApellidoPat AND
								   vcApellMaterno = pApellidoMat AND
								   vcNombre1 = pPrimerNombre  AND
								   vcNombre2 = pSegundoNombre AND
								   vdFechaNac = pFechaNacimiento THEN	
								   LET cNumCtePros = trim(cNumCtePros);
								ELSE
									LET cCod_ret = "000027";
									RETURN cCod_ret,rfc,cNumCte,cNumCtePros,cTipoCliente,cEstatus,cNumCteCoppel,cIndicadorCuestPara,cEdad;
								END IF;
			END IF;
ELSE
		RETURN cCod_ret,rfc,cNumCte,cNumCtePros,cTipoCliente,cEstatus,cNumCteCoppel,cIndicadorCuestPara,cEdad;
END IF;

LET cNumCtePros = trim(cNumCtePros);

IF  cCod_retCtePros = "00000" AND cNumCtePros <> "" THEN
	Call bdiprospectos:"informix".sp_ctepr_consctemasivo(cNumCtePros)
		RETURNING cCod_retCtePros, cEstatus, cTp_cte, cIndicadorCuestPara;
END IF;

LET cNumCte = TRIM(cNumCte);
LET cNumCtePros = TRIM(cNumCtePros);

IF (cNumCte <> "") THEN
	select tipo_cliente 
	into cTipoCliente 
	from bdinteg:"informix".si_cliente
	where numcte = cNumCte;
	
		IF (cTipoCliente = 0) AND (cNumCtePros <> "") THEN
			LET cTipoCliente = cTp_cte;
		ELSE
			LET cTipoCliente = cTipoCliente;
		END IF;
ELSE
	IF (cNumCtePros <> "") THEN
		LET cTipoCliente = cTp_cte;
	END IF;
END IF;

RETURN cCod_ret,rfc,cNumCte,cNumCtePros,cTipoCliente,cEstatus,cNumCteCoppel,cIndicadorCuestPara,cEdad;

END;
END PROCEDURE             
