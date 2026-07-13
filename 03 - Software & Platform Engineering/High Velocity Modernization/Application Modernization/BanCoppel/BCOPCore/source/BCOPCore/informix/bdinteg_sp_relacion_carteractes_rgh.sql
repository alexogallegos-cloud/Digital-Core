CREATE PROCEDURE "informix".sp_relacion_carteractes_rgh(pTpoProceso CHAR(1))
	
	RETURNING 	
			CHAR(6)    AS COD_RET,
			CHAR(80)   AS DESCRIPCION;

	---DECLARACION DE VARIABLES.
	DEFINE iSqlErr              INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE iCont	            INTEGER;	
	DEFINE cErrorInfo           CHAR(80);
	DEFINE cCodRet              CHAR(6);
	DEFINE cMensajeRet          CHAR(80);		
	DEFINE iCantEjecucion       INTEGER;
	DEFINE cNumCte		        CHAR(20);		
	DEFINE cNumCteAdi	        CHAR(20);		
	DEFINE cNumCteRef           CHAR(20);		
	DEFINE cNumCteRefAdi        CHAR(20);		
	DEFINE cTipoRel		        CHAR(1);		
	DEFINE sCommit              SMALLINT;	
	DEFINE cValor     			CHAR(100);
	DEFINE cValorRel     			CHAR(100);
	DEFINE cValorSep     			CHAR(100);
	DEFINE cBand				CHAR(1);
	---INICIALIZACION DE VARIABLES.
	LET iSqlErr                 = 0;
	LET iIsamErr                = 0;
	LET iCont	                = 0;	
	LET cErrorInfo              = '';
	LET cCodRet                 = '000000';
	LET cMensajeRet             = 'PROCESO EXISTOSO';		
	LET iCantEjecucion          = 0;
	LET cNumCte		            = '';
	LET cNumCteAdi	            = '';
	LET cNumCteRef	            = '';
	LET cNumCteRefAdi	        = '';
	LET cTipoRel	            = '0';		
	LET sCommit          		= 0;			
	LET cValor        			= '';  
	LET cValorRel        			= '';  
	LET cValorSep       			= '';  
	LET cBand					= '0';
    
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = cErrorInfo;					
				IF (sCommit = -1) THEN
					ROLLBACK WORK;
				END IF;
				RETURN TRIM(cCodRet), TRIM(cMensajeRet);
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/respaldosbd/Guadalupe/sp_relacion_carteractes.out';
		--TRACE ON;

		--VALORES QUE PUEDE RECIBIR pTpoProceso.
			-- 0-Sin informacion.
			-- 1-Alta unica.
			-- 2-Alta de cliente.
			-- 3-Todos.		
		
		--SE VALIDA PARAMETRO.
		/*IF NVL(pTpoProceso,'') = '' OR pTpoCte NOT IN ('1','2') OR NVL(pNumRegistro,0) <= 0 THEN 
			LET cCodRet ='000001';
			LET cMensajeRet = 'PARAMETROS DE ENTRADA INVALIDOS, VERIFIQUE';				
			RETURN TRIM(cCodRet), TRIM(cMensajeRet);		
		END IF;

		SELECT  valor 
		INTO cValorRel
		FROM bdicobranza:"informix".cb_param 
		WHERE empresa = '001' AND descripcion = 'REP_TIPO_RELACION'
			AND cod_param = 43;
			
			
		SELECT  valor 
		INTO cValorSep
		FROM bdicobranza:"informix".cb_param 
		WHERE empresa = '001' AND descripcion = 'REP_TIPO_RELACION'
			AND cod_param = 44;
		*/
		IF pTpoProceso ='1' THEN  ---Solo procesa registros de Alta unica
		 --SE CONSULTA SI ES CTE DE ALTA UNICA.
				FOREACH WITH HOLD
				
					SELECT cte.numcte,cte.numcte_ref
					INTO cNumCteAdi, cNumCteRefAdi
					FROM "informix".si_adiccoppel adic,
					"informix".si_ctes_coppel cte 
					WHERE  cte.numcte_ref = adic.numctecoppel
					AND cte.numcte =adic.numcte
					AND cte.bctecoppel = '1'
					AND cte.altaunica = 0
					AND adic.tipotar= '1'
					
					IF (sCommit = 0) THEN
						BEGIN WORK;
						LET iCont = 0;
						LET sCommit = -1;
					END IF; 
					
					--SE INSERTA EL REGISTRO DE LA RELACION.
					INSERT INTO "informix".si_relacion_ctebcplcpl 
					(empresa,numcte_banco,cliente,numempleado,tipo_relacion,definicion,status,tipo_re_ini,fecha_insert)
					VALUES ('001',cNumCteAdi,cNumCteRefAdi,'informix','1',cValor,'1',0,TODAY);
					
					UPDATE "informix".si_ctes_coppel SET altaunica = 1 
					WHERE numcte = cNumCteAdi AND numcte_ref = cNumCteRefAdi;
					/*
					LET cTipoRel = '';					
					
					LET iCont = iCont  + 1;			
				
					IF (iCont >= 25000) THEN
						COMMIT WORK;	
						LET iCont = 0;
						BEGIN WORK;
					END IF;
					
					LET iCantEjecucion = iCantEjecucion + 1;
					
					IF iCantEjecucion = pNumRegistro THEN
						EXIT FOREACH;
					END IF
					*/
				END FOREACH;	
		
		--ELIF pTpoProceso = '2' THEN  ---SOLO PROCESA REGISTROS DE ALTA CLIENTE
			
			FOREACH	WITH HOLD	

					SELECT {+INDEX("informix".si_ctes_coppel ix_ctes_coppel5)} numcte,numcte_ref 
					INTO cNumCte,cNumCteRef
					FROM "informix".si_ctes_coppel 
					WHERE empresa = '001'
					AND bctecoppel = '1'
					AND altaunica = 0
						
					IF (sCommit = 0) THEN
						BEGIN WORK;
						LET iCont = 0;
						LET sCommit = -1;
					END IF; 
					
					--SE INSERTA EL REGISTRO DE LA RELACION.
					INSERT INTO "informix".si_relacion_ctebcplcpl 
					(empresa,numcte_banco,cliente,numempleado,tipo_relacion,definicion,status,tipo_re_ini,fecha_insert)
					VALUES ('001',cNumCte,cNumCteRef,'informix','2',cValor,'1',0,TODAY);					
					
					UPDATE "informix".si_ctes_coppel SET altaunica = 2 
					WHERE numcte = cNumCte AND numcte_ref = cNumCteRef;
					
					/*
					LET cTipoRel = '';
					
					LET iCont = iCont  + 1;			
				
					IF (iCont >= 25000) THEN
						COMMIT WORK;	
						LET iCont = 0;
						BEGIN WORK;
					END IF;
					
					LET iCantEjecucion = iCantEjecucion + 1;
					
					IF iCantEjecucion = pNumRegistro THEN
						EXIT FOREACH;
					END IF
					*/
			END FOREACH;
		END IF;
			
		--ELSE--0, y 3 --PROCESA CLIENTES SIN INFORMACION Y TODOS.
		--CICLO PARA OBTENER LOS DETALLES DE MOVIMIENTOS DEL DIA.
		/*	FOREACH	WITH HOLD	

		SELECT cte.numcte,cte.numcte_ref 
				INTO cNumCte,cNumCteRef
				FROM bdinteg:"informix".si_cliente cte 
				WHERE cte.empresa = '001' 				
					AND cte.numcte NOT IN(SELECT numcte_banco FROM bdinteg:"informix".si_relacion_ctebcplcpl
										  WHERE numcte_banco = cte.numcte)
					AND cte.tipo_cliente = pTpoCte
					AND NVL(cte.numcte_ref,'')  = CASE WHEN pTpoProceso = '0' THEN '' ELSE NVL(cte.numcte_ref,'') END 
							
				IF pTpoProceso ='3' THEN --PROCESA TODOS.
					--SE CONSULTA SI ES CTE DE ALTA UNICA.
					SELECT numcte,numctecoppel
					INTO cNumCteAdi, cNumCteRefAdi
					FROM bdinteg:"informix".si_adiccoppel
					WHERE numcte = cNumCte
						AND numctecoppel = numctecoppel
						AND secuencia = 1;
						
						LET cBand = '1';
						LET cValor = cValorRel;
						--ALTA UNICA
						IF NVL(cNumCteRefAdi,'') <> '' AND NVL(cNumCteRef,'') = NVL(cNumCteRefAdi,'') THEN
							LET cTipoRel = '1';																
							LET cNumCte = cNumCteAdi;
							LET cNumCteRef = cNumCteRefAdi;
						ELIF NVL(cNumCteRefAdi,'') = '' AND NVL(cNumCteRef,'') <>'' THEN--Alta de Cliente 
							LET cTipoRel = '2';														
						ELSE 
							LET cTipoRel = '0';
							LET cBand = '0';
							LET cValor = cValorSep;									
						END IF;
						
				ELSE
					LET cTipoRel = '0';							
					LET cBand = '0';
					LET cValor = cValorSep;
				END IF;			
							
				
				IF (sCommit = 0) THEN
					BEGIN WORK;
					LET iCont = 0;
					LET sCommit = -1;
				END IF; 
						
							
				--SE INSERTA EL REGISTRO DE LA RELACION.
				INSERT INTO bdinteg:"informix".si_relacion_ctebcplcpl 
				(empresa,numcte_banco,cliente,numempleado,tipo_relacion,definicion,status,tipo_re_ini,fecha_insert)
				VALUES ('001',cNumCte,cNumCteRef,'informix',cTipoRel,cValor,cBand,0,TODAY);					
													
				LET cTipoRel = '';
				
											
				LET iCont = iCont  + 1;			
			
				IF (iCont >= 25000) THEN
					COMMIT WORK;	
					LET iCont = 0;
					BEGIN WORK;
				END IF;
				
				LET iCantEjecucion = iCantEjecucion + 1;
				
				IF iCantEjecucion = pNumRegistro THEN
					EXIT FOREACH;
				END IF			
							
			END FOREACH
		END IF;
		*/
		IF iCantEjecucion = 0 THEN		
			LET cCodRet ='000002';
			LET cMensajeRet = 'NO SE ENCONTRARON DATOS PARA PROCESAR';		
			IF sCommit = -1 THEN
				COMMIT WORK;
		    END IF;
			LET sCommit = 0;
			RETURN TRIM(cCodRet), TRIM(cMensajeRet);
		ELSE
			IF sCommit = -1 THEN
				COMMIT WORK;
		    END IF;
			LET sCommit = 0;
			--SE OPTIMIZA PARA SU MEJOR PROCESAMIENTO LA TABLA DE INSERCION.	
			UPDATE STATISTICS MEDIUM FOR TABLE bdinteg:"informix".si_relacion_ctebcplcpl;
			RETURN TRIM(cCodRet), TRIM(cMensajeRet);
		END IF;											  				   				
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que recorre la cartera de la "bdinteg:si_cliente" con los existentes en la',
'             tabla "bdinteg:si_adiccoppel" para que estos sean insertados en la tabla .bdinteg:si_relacion_ctebcplcpl.',
'             con un tipo de relación por .Alta Única.. De igual forma este proceso debe de insertar los clientes ya',
'             existentes en la tabla .bdinteg:si_cliente. y que ya cuenten con un numero de referencia (Ya es Cliente Coppel)',
' 			  se deben de insertar con un tipo de relación .Alta de Cliente. en la tabla .bdinteg:si_relacion_ctebcplcpl..',
'			  Al igual que los clientes existentes en la tabla .bdinteg:si_cliente pero que no cuentan con un numero de referencia',
'             (No Cuentan con Numero de Cliente Coppel), deberán ser insertados en la tabla .bdinteg:si_relacion_ctebcplcpl. pero',
'			  con una relación .Sin Información..', 
'AUTOR: Guadalupe Payan',
'FECHA DE CREACION: 14 de Agosto de 2012',
'VERSION: 20120814.1232',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actstatenviocpel(pNum_sol CHAR(20), pNuevo_estatus CHAR(1))
	RETURNING 
			CHAR(5)		AS Cod_ret,
			CHAR(80)	AS Mensaje_ret;
		
	---DECLARACIONES
    DEFINE iSqlErr						INTEGER;
    DEFINE iIsamErr						INTEGER;
    DEFINE vErrorInfo					VARCHAR(80);
    DEFINE cCodRet						CHAR(5);
	DEFINE cMensajeRet     				CHAR(80);
	DEFINE cEstatus						CHAR(2);	
	---INICIALIZACIONES
	LET iSqlErr						= 0;
	LET iIsamErr					= 0;
	LET vErrorInfo					= '';
	LET cCodRet						= '00000';
	LET cMensajeRet					= 'PROCESO EXITOSO';
	LET cEstatus					= '';
		
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		   IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = TRIM(NVL(vErrorInfo,''));
				RETURN TRIM(cCodRet),NVL(cMensajeRet,'');				
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
    
		--SET DEBUG FILE TO '/home/sysifx/respaldosbd/josue/sp_actstatenviocpel';
		--TRACE ON;
	
		-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS	
		IF TRIM(NVL(pNum_sol,'')) = '' OR TRIM(NVL(pNuevo_estatus,'')) = '' THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'PARÁMETROS VACÍOS';			
			-- SI LOS PARAMETROS TRAEN INFORMACIÓN SE BUSCA EL ESTATUS DE LA SOLICITUD Y VALIDA SI PUEDE CAMBIAR O NO SU ESTATUS.
		ELSE
			SELECT  status_solicitud
			INTO  	cEstatus
			FROM bdisolic:"informix".ss_solicitudes
			WHERE	 num_solicitud = pNum_sol;			
			IF cEstatus NOT IN("PC", "AN") THEN			
				IF pNuevo_estatus = '1' OR pNuevo_estatus ='2' THEN
			
					UPDATE bdisolic:"informix".ss_solicitudes
					SET envio_coppel = pNuevo_estatus
					WHERE num_solicitud = pNum_sol;					
				ELSE
					LET cCodRet		= '00002';
					LET cMensajeRet	= 'LA SOLICITUD NO PUEDE SER PROCESADA';
				END IF;
			ELSE
				LET cCodRet		= '00003';
				LET cMensajeRet	= 'ESTATUS INCORRECTO';
			END IF;				
		END IF;	
		RETURN TRIM(cCodRet),NVL(cMensajeRet,'');		
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION:Procedimiento que realiza la actualización del campo bdisolic: ss_solicitudes envio_coppel al status requerido.', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 23 de Julio del 2012',
'BD   : bdisolic',
'VERSION: 20120723.1015';

CREATE PROCEDURE "informix".sp_consenvioscoppel(pNumero CHAR(20))
	RETURNING 
			 CHAR(5)			AS cod_ret,			
			 VARCHAR(80)		AS mensaje_ret,
			 CHAR (350)  		AS cad1;
			
	---DECLARACIONES
    DEFINE iSqlErr						INTEGER;
    DEFINE iIsamErr						INTEGER;
    DEFINE vErrorInfo					VARCHAR(80);
    DEFINE cCodRet						CHAR(5);
	DEFINE vMensajeRet     				VARCHAR(80);
	DEFINE cNumero_sol					CHAR(20);
	DEFINE cNombre1						CHAR(26);		
	DEFINE cNombre2						CHAR(26);
	DEFINE cApell_paterno				CHAR(26);	
	DEFINE cApell_materno				CHAR(26);
    DEFINE cFecha_nac 					CHAR(10);
	DEFINE cFecha_alta_sol				CHAR(10);
	DEFINE cNumcte						CHAR(20);
	DEFINE cEnvio						CHAR(1);
	DEFINE cCad1                       	CHAR (350);	
	---INICIALIZACIONES
	LET iSqlErr						= 0;
	LET iIsamErr					= 0;
	LET vErrorInfo					= '';
	LET cCodRet						= '00000';
	LET vMensajeRet					= 'PROCESO EXITOSO';
	LET cNumero_sol					= '';
	LET cNombre1					= '';
	LET cNombre2					= '';
	LET cApell_paterno				= '';
	LET cApell_materno				= '';
	LET cFecha_nac					= '1900/01/01';
	LET cFecha_alta_sol				= '1900/01/01';
	LET	cNumcte						= '';
	LET cEnvio						= '';
	LET cCad1 						= '';		
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		   IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET vMensajeRet = TRIM(NVL(vErrorInfo,''));
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(vMensajeRet,'')),TRIM(NVL(cCad1,''));			
		   END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;    
		
		--SET DEBUG FILE TO '/home/sysifx/respaldosbd/josue/sp_consenvioscoppel';
		--TRACE ON;	
	    
		LET cNumero_sol =  TRIM(NVL(pNumero,''));				
		-- SI LOS PARAMETROS TRAEN INFORMACIÓN SE BUSCA LA INFORMACIÓN PERSONAL DEL CLIENTE SOLICITANTE Y SE REGRESA
		-- SI NO TRAE TODAS LAS SOLICITUDES QUE SU CAMPO envio_coppel= 1   		
		IF cNumero_sol <> '' THEN		
			
			SELECT envio_coppel, fecha_insert,numcte
			INTO cEnvio, cFecha_alta_sol,cNumcte
			FROM bdisolic:"informix".ss_solicitudes
			WHERE	 num_solicitud = pNumero
				AND tipo_solicitud='C';	
				
			IF NVL(cEnvio,'0') = '1' THEN
				
				SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, b.fecha_nac 
				INTO cNombre1, cNombre2, cApell_paterno, cApell_materno, cFecha_nac 
				FROM  bdinteg:"informix".si_cliente a,  
					  bdinteg:"informix".si_ctepf b
				WHERE a.numcte = cNumcte
					AND a.numcte = b.numcte;	
					
					LET cNombre1 = REPLACE (REPLACE (cNombre1,'Ñ','#'),'ñ','#');
					LET cNombre2 = REPLACE (REPLACE (cNombre2,'Ñ','#'),'ñ','#');
					LET cApell_paterno = REPLACE(REPLACE (cApell_paterno,'Ñ','#'),'ñ','#');
					LET cApell_materno = REPLACE(REPLACE (cApell_materno,'Ñ','#'),'ñ','#');
					
				LET cCad1 = 
					"90"||"|"||"0026"||"|"||"0"||"|"|| TRIM(NVL(cNumero_sol,'')) ||"|"||
					TRIM(NVL(cNombre1,'')) ||"|"||TRIM(NVL(cNombre2,'')) ||"|"|| 
					TRIM(NVL(cApell_paterno,'')) ||"|"||TRIM(NVL(cApell_materno,'')) ||"|"|| 
					TRIM(NVL(cFecha_nac,'1900/01/01')) ||"|"||TRIM(NVL(cFecha_alta_sol,'1900/01/01'))||"|";					
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(vMensajeRet,'')),TRIM(NVL(cCad1,''));				
				
			ELSE
			
				LET cCodRet = '00001';
				LET vMensajeRet = 'SOLICITUD CONSULTADA NO ES APTA PARA ENVÍO A COPPEL';
				LET cNumero_sol='';							  
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(vMensajeRet,'')),TRIM(NVL(cCad1,''));						
				
			END IF;
		ELSE 		
			FOREACH
			
					SELECT  fecha_insert,numcte,num_solicitud
					INTO cFecha_alta_sol,cNumcte,cNumero_sol
					FROM bdisolic:"informix".ss_solicitudes
					WHERE  status_solicitud NOT IN("PC", "AN")
						AND  envio_coppel = '1'
						
					SELECT a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, b.fecha_nac 
					INTO cNombre1, cNombre2, cApell_paterno, cApell_materno, cFecha_nac 
					FROM  bdinteg:"informix".si_cliente a,  bdinteg: "informix".si_ctepf b
					WHERE a.numcte = cNumcte
						AND a.numcte = b.numcte;
					
					LET cNombre1 = REPLACE (REPLACE (cNombre1,'Ñ','#'),'ñ','#');
					LET cNombre2 = REPLACE (REPLACE (cNombre2,'Ñ','#'),'ñ','#');
					LET cApell_paterno = REPLACE(REPLACE (cApell_paterno,'Ñ','#'),'ñ','#');
					LET cApell_materno = REPLACE(REPLACE (cApell_materno,'Ñ','#'),'ñ','#');
					
					LET cCad1 =  
							"|"||"#90"||"|"||"0026"||"|"||"0"||"|"|| TRIM(NVL(cNumero_sol,'')) ||"|"||
							TRIM(NVL(cNombre1,'')) ||"|"||TRIM(NVL(cNombre2,'')) ||"|"|| 
							TRIM(NVL(cApell_paterno,'')) ||"|"||TRIM(NVL(cApell_materno,'')) ||"|"|| 
							TRIM(NVL(cFecha_nac,'1900/01/01')) ||"|"||TRIM(NVL(cFecha_alta_sol,'1900/01/01'))||"|";					
					
					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(vMensajeRet,'')),TRIM(NVL(cCad1,'')) WITH RESUME;					
					
			END FOREACH;
		END IF;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Creación de un procedimiento nuevo el cual consulta y regresa la información necesaria para el envió a Coppel de todas las solicitudes Coppel listas para el envió', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 20 de Julio del 2012',
'BD   : bdisolic',
'VERSION: 20120720.1115';

CREATE PROCEDURE "informix".sp_consultactesrelacionados(pEmpresa CHAR(3), pNumCteBanco CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)  AS CodigoRetorno,
	CHAR(20) AS NumCteCoppel;

	DEFINE iSql_err	  INTEGER;
	DEFINE cCodRet	  CHAR(5);
	DEFINE cNumCteCPL CHAR(20);
	
	LET iSql_err	= 0;
	LET cCodRet		= '00000';
	LET cNumCteCPL	= '';

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consultactesrelacionados.out";
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
		
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cNumCteCPL;
			END IF;
			
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pNumCteBanco IS NULL OR pNumCteBanco = '' OR pEmpresa IS NULL OR pEmpresa = '' THEN
			LET cCodRet = '00001';
		ELSE
			IF EXISTS (SELECT numcte_banco FROM bdinteg:"informix".si_relacion_ctebcplcpl WHERE numcte_banco = TRIM(pNumCteBanco)) THEN
				SELECT TRIM(cliente)
				INTO cNumCteCPL
				FROM bdinteg:"informix".si_relacion_ctebcplcpl 
				WHERE empresa = pEmpresa
				AND numcte_banco = TRIM(pNumCteBanco);
				
				IF cNumCteCPL = "" OR cNumCteCPL IS NULL THEN
					LET cCodRet = '00001';
				END IF;
				
			ELSE
				LET cCodRet = '00001';
			END IF;
		END IF;
		
		RETURN  cCodRet, cNumCteCPL;
	END
	
END PROCEDURE

DOCUMENT
'Consulta si existe relacion de un cliente Bancoppel con un numero de cliente Coppel',
'Autor :Daniela Ramírez',
'FECHA : 19/Septiembre/2012',
'BD: bdinteg',
'Valida que el campo cliente de la tabla si_relacion_ctebcplcpl, no este vacio o sea nulo',
'Autor :Rodolfo Tortolero',
'FECHA : 03/Enero/2013',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actdepctesbcplcpl(pEmpresa CHAR(3))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5)  AS CodigoRetorno;

	DEFINE iSql_err	  	INTEGER;
	DEFINE cCodRet		CHAR(5);
	DEFINE cNumCte		CHAR(20);
	DEFINE cValorCte	CHAR(1);
	DEFINE cValorLimpio	CHAR(1);
	
	LET iSql_err	= 0;
	LET cCodRet		= '00000';
	LET cNumCte		= '';
	LET cValorCte	= '';
	LET cValorLimpio = '';

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_actdepctesbcplcpl.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet WITH RESUME;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEmpresa IS NULL OR pEmpresa = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet WITH RESUME;
		ELSE
			FOREACH
				--NOTA:
				--bctecoppel = 0: El cliente coppel no se encuentra en la base de datos de Coppel
				--bctecoppel = 1: El cliente coppel se encuentra en la base de datos de Coppel
				--bctecoppel = 2: Se actualizó registros a cValorLimpio para borrar relacion entre clientes BCPL-CPL
			
				SELECT TRIM(numcte), TRIM(bctecoppel)
				INTO cNumCte, cValorCte 
				FROM "informix".si_ctes_coppel 
				WHERE empresa = pEmpresa 
				AND bctecoppel = "0"
				
				IF cValorCte = "0" THEN
					
					IF EXISTS (SELECT numcte FROM "informix".si_cliente WHERE empresa = pEmpresa AND numcte = cNumCte) THEN
						UPDATE "informix".si_cliente 
						SET numcte_ref = cValorLimpio 
						WHERE empresa = pEmpresa
						AND numcte = cNumCte;
						/*
						IF EXISTS (SELECT numcte_banco FROM "informix".si_relacion_ctebcplcpl WHERE empresa = pEmpresa AND numcte_banco = cNumCte) THEN
							UPDATE "informix".si_relacion_ctebcplcpl
							SET cliente = cValorLimpio
							WHERE empresa = pEmpresa
							AND numcte_banco = cNumCte;
						END IF
						
						IF EXISTS (SELECT numcte FROM "informix".si_ctes_coppel WHERE empresa = pEmpresa AND numcte = cNumCte AND bctecoppel = "0") THEN
							UPDATE "informix".si_ctes_coppel
							SET bctecoppel = "2"
							WHERE empresa = pEmpresa
							AND numcte = cNumCte
							AND bctecoppel = "0";
						END IF
						*/
					END IF
				END IF;
				
				CONTINUE FOREACH;
				
			END FOREACH;

			RETURN cCodRet WITH RESUME;
			
		END IF;
		
	END
END PROCEDURE
DOCUMENT
'Conocer si el cliente coppel registrado como referencia de un cliente Bancoppel',
'se encuentra o no en la base de datos de Coppel',
'Autor :Daniela Ramírez',
'FECHA : 25/Septiembre/2012',
'BD: bdinteg';

CREATE PROCEDURE "informix".cteppes(pempresa 	      CHAR(3),
                                    pfuncion 	      CHAR(1),
					                pnumcte           CHAR(20),
					                ptipo_ppes        CHAR(1),
					                ppuesto_ppes      CHAR(2),
					                papell_paterno    CHAR(26),
					                papell_materno    CHAR(26),
					                pnombre1          CHAR(26),
					                pnombre2          CHAR(26),
					                pparticipacion    DECIMAL(14,2),
					                pdomicilio        CHAR(80),
					                ptelefono         CHAR(20),
					                puser_insert      CHAR(8),
					                pfecha_insert     DATE,
                                    pasociacion       CHAR(40),
					                pnumeroregistro   INTEGER)
RETURNING CHAR(5);

DEFINE vcodret            CHAR(5);
DEFINE vfecha             DATE;
--DEFINE vsignumcte         INT;
DEFINE vexiste            CHAR(1);
--DEFINE vempresa           CHAR(3);
--DEFINE vsucursal          CHAR(4);
--DEFINE vejecutivo         CHAR(8);
--DEFINE vejecut_autoriza   CHAR(8);
--DEFINE vtp_persona        CHAR(2);
--DEFINE vtp_cliente        CHAR(1);
DEFINE vnumcte 		      CHAR(20);
--DEFINE vtipo_ppes         CHAR(1);
--DEFINE vpuesto_ppes       CHAR(2);
--DEFINE vpaterno 	        CHAR(26);
--DEFINE vmaterno 	        CHAR(26);
--DEFINE vnombre1 	        CHAR(26);
--DEFINE vnombre2 	        CHAR(26);
--DEFINE vparticipacion     DECIMAL(14,2);
--DEFINE vdomicilio         CHAR(80);
--DEFINE vtelefono          CHAR(20);
--DEFINE vuser_insert       CHAR(8);
--DEFINE vfecha_insert      DATE;
DEFINE vnumeroregistro    INTEGER;
DEFINE vsqlerr,visamerr   INTEGER;

LET vfecha           = "";
--LET vsignumcte       = 0;
LET vexiste          = "";
--LET vempresa         = "";
--LET vsucursal        = "";
--LET vejecutivo       = "";
--LET vejecut_autoriza = "";
--LET vtp_persona      = "";
--LET vtp_cliente      = "";
LET vnumcte          = "";
--LET vtipo_ppes       = "";
--LET vpuesto_ppes     = "";
--LET vpaterno         = "";
--LET vmaterno         = "";
--LET vnombre1         = "";
--LET vnombre2         = "";
--LET vparticipacion   = "";
--LET vdomicilio       = "";
--LET vtelefono        = "";
--LET vuser_insert     = "";
--LET vfecha_insert    = "";
LET vnumeroregistro  = 0;


LET vcodret          = "000";
--LET vempresa = pempresa;
--LET vexiste = "";


	-- SET DEBUG FILE TO "/tmp/cteppes.out";
	-- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

SELECT fecha_hoy INTO vfecha
   FROM bdinteg:"informix".si_fechas
   WHERE empresa = pempresa;

   --alida datos Nulos
   IF pnumcte IS NULL OR pnumcte = " " THEN
      LET vcodret = "104";
      RETURN vcodret;
   END IF


   SELECT 1 INTO vexiste FROM bdinteg:"informix".si_cliente
      WHERE numcte = pnumcte AND empresa = pempresa;
   IF vexiste IS NULL THEN
      LET vcodret="104";
      RETURN vcodret;
   END IF;

   IF ptipo_ppes IS NULL OR ptipo_ppes = " " THEN
      LET vcodret = "302";
      RETURN vcodret;
   END IF

   IF ppuesto_ppes IS NULL OR ppuesto_ppes = " " THEN
      LET vcodret = "300";
      RETURN vcodret;
   END IF

   SELECT 1 INTO vexiste
     FROM bdinteg:"informix".si_puestosppes
    WHERE empresa=pempresa AND puesto_ppes = ppuesto_ppes;
   IF vexiste IS NULL THEN
      LET vcodret="300";
      RETURN vcodret;
   END IF;

   SELECT 1 INTO vexiste
     FROM bdinteg:"informix".si_empresas
    WHERE empresa=pempresa;
   IF vexiste IS NULL THEN
      LET vcodret="301";
      RETURN vcodret;
   END IF;

   SELECT 1 INTO vexiste
     FROM bdinteg:"informix".si_ejecut
    WHERE empresa= pempresa AND ejecutivo = puser_insert;
   IF vexiste IS NULL THEN
      LET vcodret="112";
      RETURN vcodret;
   END IF;

-- ****************** Actualizacion de Parametros *****************
IF pfuncion="A" THEN

   SELECT MAX(numeroregistro) + 1
     INTO vnumeroregistro
     FROM bdinteg:"informix".si_cteppes
    WHERE empresa = pempresa AND numcte = pnumcte;

   IF vnumeroregistro IS NULL THEN
      LET vnumeroregistro = 1;
   END IF


   BEGIN
      INSERT INTO bdinteg:"informix".si_cteppes
         (empresa,		numcte,		tipo_ppes, 	puesto_ppes,
	  apell_paterno, 	apell_materno,	nombre1,	nombre2,
	  participacion,	domicilio,	telefono,	user_insert,
	  fecha_insert,		numeroregistro,  asociacion_civil)
      VALUES
         (pempresa,		pnumcte,	ptipo_ppes, 	ppuesto_ppes,
	  papell_paterno, 	papell_materno,	pnombre1,	pnombre2,
	  pparticipacion,	pdomicilio,	ptelefono,	puser_insert,
	  pfecha_insert, vnumeroregistro,  pasociacion);
   END;
   RETURN vcodret;

ELSE

   SELECT 1 INTO vexiste FROM bdinteg:"informix".si_cteppes
      WHERE numcte = vnumcte AND empresa = pempresa AND numeroregistro = pnumeroregistro;
   IF vexiste IS NULL THEN
      --LET vcodret="303";
      --RETURN vcodret;
	  SELECT MAX(numeroregistro) + 1
      INTO vnumeroregistro
      FROM bdinteg:"informix".si_cteppes
      WHERE empresa = pempresa AND numcte = pnumcte;

	   IF vnumeroregistro IS NULL THEN
		  LET vnumeroregistro = 1;
	   END IF

	   BEGIN
		  INSERT INTO bdinteg:"informix".si_cteppes
			(empresa,		numcte,		tipo_ppes, 	puesto_ppes,
		  apell_paterno, 	apell_materno,	nombre1,	nombre2,
		  participacion,	domicilio,	telefono,	user_insert,
		  fecha_insert,		numeroregistro,  asociacion_civil)
		  VALUES
			 (pempresa,		pnumcte,	ptipo_ppes, 	ppuesto_ppes,
		  papell_paterno, 	papell_materno,	pnombre1,	pnombre2,
		  pparticipacion,	pdomicilio,	ptelefono,	puser_insert,
		  pfecha_insert, vnumeroregistro,  pasociacion);
	   END;
	   RETURN vcodret;
	  
   END IF;

   BEGIN
      UPDATE bdinteg:"informix".si_cteppes
 	 SET(tipo_ppes,		puesto_ppes,	apell_paterno,	apell_materno,
 	     nombre1,		nombre2,   	participacion,	domicilio,
 	     telefono,	 	user_insert,	fecha_insert,  asociacion_civil)
	   =
 	    (ptipo_ppes,	ppuesto_ppes,	papell_paterno,	papell_materno,
 	     pnombre1,		pnombre2,   	pparticipacion,	pdomicilio,
 	     ptelefono,	 	puser_insert,		pfecha_insert,   pasociacion)
       WHERE empresa = pempresa AND numcte = pnumcte AND numeroregistro = pnumeroregistro;
   END;

END IF;
RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Alta y Cambio de Personas Politicamente",
"AutOR : Procesamiento Interactivo S.A. de C..",
"MODIFICO : Victor Luna",
"FECHA : 17/Octubre/2006",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Felipe Urias",
"FECHA : 30/Agosto/2012",
"Se Agregan Reglas de Informix, se agrega insert en caso",
"De Realizar un mantenimiento que no tubiese registro de",
"ppes";

CREATE PROCEDURE "informix".sp_buscar_movimientos_inversion_his2(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(14,2), p_skip INT, ids_transacciones lvarchar, p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento;
	-- Definicion de variables	    
	DEFINE resultado_fechaMovimiento    DATE;
	DEFINE resultado_monto				money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR TO FRACTION(3);
	DEFINE resultado_folioSuc			CHAR(30);
    DEFINE resultado_sucursal			CHAR(4);
    DEFINE resultado_nombre             CHAR(30);
    DEFINE resultado_claveTipo          CHAR(5);
    DEFINE resultado_tipo   			CHAR(40);
    DEFINE resultado_reversado   		CHAR(1);
    DEFINE transacciones 				LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                      INTEGER;
	 
     -- InicializaciÃ³n de las variables.
	LET resultado_fechaMovimiento 		= '';
	LET resultado_monto 				= '';
	LET resultado_horaMovimiento 		= TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc 				= '';
    LET resultado_sucursal 				= '';
    LET resultado_nombre 				= '';
    LET resultado_claveTipo 			= '';
	LET resultado_tipo 					= '';
	LET resultado_reversado 			= '';
	LET transacciones 					= 'LIST{' || ids_transacciones || '}';

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones OptimizaciÃ³n de SPÂ´s II 05/03/2013
-- Cambio para que en un sÃ³lo SP se realicen todas las consultas que correspan.
-- Se cambia el nombre para la identificaciÃ³n correcta de los SPÂ´s del sistema.
-- SADVC 
	
-- SET DEBUG FILE TO "/informix/SD/Optimizacion_sps_root_II/sp_buscar_movimientos_inversion_his2.out";
-- TRACE ON;

    RETURN resultado_fechaMovimiento;
END PROCEDURE;