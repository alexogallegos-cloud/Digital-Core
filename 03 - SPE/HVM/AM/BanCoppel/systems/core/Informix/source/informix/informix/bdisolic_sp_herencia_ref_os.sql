CREATE PROCEDURE "informix".sp_herencia_ref_os ( pEmpresa CHAR(3))	
RETURNING CHAR(5);       -- Codigo de Retorno
		  

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMen_ret CHAR(80);
DEFINE p_cod_ret CHAR(6);
DEFINE iMotivoOs  INTEGER;

DEFINE iSecuencia INTEGER;
DEFINE iContadorRef INTEGER;
DEFINE cNumSol CHAR(20);
DEFINE cNumcte CHAR(20);
DEFINE cNumSolicitud CHAR(20);
DEFINE dtFechaSol DATE;
DEFINE VARsituacionespecial char(1);
DEFINE VARcausasituacionespecial smallint;
DEFINE VARsituacionespecialrespuesta char(1);
DEFINE VARcausasituacionespecialrespuesta smallint;


------Referencias
DEFINE cSucursal 				CHAR(4);
DEFINE cApellPaterno 			CHAR(26);
DEFINE cApellMaterno 			CHAR(26);
DEFINE cNombre1 				CHAR(26);
DEFINE cNombre2 				CHAR(26);
DEFINE cRfc 					CHAR(13);
DEFINE dtFechaNac 				DATE;
DEFINE cCurp 					CHAR(20);
DEFINE cSexo 					CHAR(1);
DEFINE cEstadoCivil 			CHAR(2);
DEFINE cNacionalidad 			CHAR(3);
DEFINE cNoFm 					CHAR(18);
DEFINE cCodigoIden 				CHAR(2);
DEFINE cNumIdentif 				CHAR(30);
DEFINE cPersDomicilio 			CHAR(2);
DEFINE cEmail 					CHAR(60);
DEFINE cParentesco 				CHAR(2);
DEFINE cApellCasada 			CHAR(26);
DEFINE cNumcteRef 				CHAR(20);
DEFINE cNumCteBanco 			CHAR(20);
DEFINE cUsuario 				CHAR(8);
DEFINE dtFecha 					DATE;
DEFINE iSecuencia2   			INTEGER;
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMen_ret     = "Proceso Exitoso";

LET iSecuencia = 0;
LET iSecuencia2 = 0;
LET iContadorRef = 0;
LET cNumSol = "";
LET cNumcte = "";
LET cNumSolicitud = "";
LET dtFechaSol = DATE(1);
LET p_cod_ret     = "000000";
LET iMotivoOs     = 0;
LET VARsituacionespecial = '';
LET VARcausasituacionespecial = 0;
LET VARsituacionespecialrespuesta = '';
LET VARcausasituacionespecialrespuesta = 0;


LET cSucursal  		= "";
LET cApellPaterno  	= "";
LET cApellMaterno  	= "";
LET cNombre1  		= "";
LET cNombre2  		= "";
LET cRfc  			= "";	
LET dtFechaNac 		= DATE(1);
LET cCurp  			= "";
LET cSexo  			= "";
LET cEstadoCivil  	= "";
LET cNacionalidad  	= "";
LET cNoFm  			= "";
LET cCodigoIden  	= "";
LET cNumIdentif  	= "";
LET cPersDomicilio  = "";
LET cEmail  		= "";
LET cParentesco  	= "";
LET cApellCasada  	= "";
LET cNumcteRef  	= "";
LET cNumCteBanco 	= "";
LET cUsuario  		= "";
LET dtFecha 		= DATE(1);
					

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/sp_reinicia_solicitudes.out';
	--TRACE ON;

			SELECT num_solicitud, numcte 
				FROM bdisolic:ss_solicitudes a
			WHERE empresa='001'
             and status_solicitud  IN('BC','EC','RT','AT','AP','MC','EE','CN','CM')
            and  fecha_insert>=mdy(02,14,2017)
			and num_producto ='6500'			
			and num_solicitud not in (SELECT c.num_solicitud
			FROM bdinteg:"informix".si_refclientes c
			WHERE c.empresa = '001'
			AND c.numcte = a.numcte
			AND c.num_solicitud = a.num_solicitud )
			into temp paso_sol1 with no log;
			
			create index inx_paso_sol1 on paso_sol1(num_solicitud,numcte);
			
			update statistics high for table paso_sol1;
			


	FOREACH WITH HOLD
		
			SELECT num_solicitud,numcte
				INTO  cNumSol,cNumcte
				from paso_sol1
    
			
			
						EXECUTE PROCEDURE "informix".sp_obtienesolicitudherencia
						('001' ,cNumSol,cNumcte)
						INTO cCodret, cNumSolicitud;					
				
			IF NVL(cNumSolicitud,'') = '' THEN 
				SELECT num_solicitud_ref 
				INTO cNumSolicitud
				FROM bdisolic:ss_resum_scor_fin 
				WHERE  num_solicitud =cNumSol;
			END IF;
			

				--Se obtiene la ultima referencia del cliente, en caso de que tramite banco y coppel , la ultima referencia es de banco
				FOREACH	WITH HOLD
					SELECT sucursal,apell_paterno,apell_materno,nombre1,
						nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,
						pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert, fecha_insert
					INTO cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cRfc,
						dtFechaNac,cCurp,cSexo,cEstadoCivil,cNacionalidad,cNoFm,cCodigoIden,cNumIdentif ,cPersDomicilio,
						cEmail ,cParentesco,cApellCasada,cNumcteRef ,cNumCteBanco,cUsuario ,dtFecha
					FROM bdinteg:"informix".si_refclientes a
					WHERE a.empresa = '001'
					AND a.numcte = cNumcte	
					AND num_solicitud = cNumSolicitud
					ORDER BY secuencia ASC
					
					LET iContadorRef = iContadorRef+1;
					
					IF iContadorRef > 2 THEN
						EXIT FOREACH;
					END IF;
					BEGIN WORK;
					
					EXECUTE PROCEDURE bdinteg:"informix".sp_refclientes_cjunk
						('001',"A",cNumSol,cNumcte,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cRfc,
						dtFechaNac,cCurp,cSexo,cEstadoCivil,cNacionalidad,cNoFm,cCodigoIden,cNumIdentif ,cPersDomicilio,
						cEmail ,cParentesco,cApellCasada,cNumcteRef ,cNumCteBanco,cUsuario ,dtFecha,0 )
					INTO cCodret,iSecuencia2;
					
					LET cSucursal  		= "";
					LET cApellPaterno  	= "";
					LET cApellMaterno  	= "";
					LET cNombre1  		= "";
					LET cNombre2  		= "";
					LET cRfc  			= "";	
					LET dtFechaNac 		= DATE(1);
					LET cCurp  			= "";
					LET cSexo  			= "";
					LET cEstadoCivil  	= "";
					LET cNacionalidad  	= "";
					LET cNoFm  			= "";
					LET cCodigoIden  	= "";
					LET cNumIdentif  	= "";
					LET cPersDomicilio  = "";
					LET cEmail  		= "";
					LET cParentesco  	= "";
					LET cApellCasada  	= "";
					LET cNumcteRef  	= "";
					LET cNumCteBanco 	= "";
					LET cUsuario  		= "";
					LET dtFecha 		= DATE(1);
					COMMIT WORK;
				END FOREACH;
			
								
				LET iContadorRef    = 0;
				
	END FOREACH;	
	
		
					
		RETURN cCodRet ;
END
END PROCEDURE
