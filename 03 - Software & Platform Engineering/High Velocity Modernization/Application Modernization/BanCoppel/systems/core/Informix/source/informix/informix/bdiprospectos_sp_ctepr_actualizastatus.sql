CREATE PROCEDURE "informix".sp_ctepr_actualizastatus( 
													  pEjecutivo CHAR(8), 
													  pNum_ctepros CHAR(20), 
													  pNuevo_Status_Sol CHAR(2),
													  pCausa CHAR(3),
													  pComentario VARCHAR(255,1)
													)
RETURNING CHAR(6) AS CodRet;

	-- DECLARACION DE VARIABLES
	DEFINE cCodRet 				CHAR(6);
	DEFINE iSqlerr				INTEGER;
	DEFINE dFecha				DATE;
	DEFINE cDescripcion_status	CHAR(40);
	DEFINE cStatus_actual		CHAR(2);
	DEFINE cSitEsp				CHAR(1);
	DEFINE sCausaSit			SMALLINT;
	DEFINE cNumctebcpl			CHAR(9);


	
	-- INICIALIZA VARIABLES
	LET cCodRet					= '000000';
	LET cDescripcion_status 	= '';
	LET cStatus_actual 			= '';
	LET cSitEsp					= '';
	LET sCausaSit				= 0;
	LET cNumctebcpl				= '';
	
	BEGIN
			
		ON EXCEPTION SET iSqlerr
			IF iSqlerr != 0 THEN
				LET cCodret = iSqlerr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/MARTIN/sp_ctepr_actualizastatus-PRUEBA.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- VALIDACION DE PARAMETROS --
		IF NVL(pEjecutivo,"") = "" OR NVL(pNum_ctepros,"") = "" OR NVL(pNuevo_Status_Sol,"") = "" THEN 
		-- SE VERIFICA QUE LOS PARAMETROS NO LLEGUEN VACIO
			LET cCodRet = '000001';
			RETURN cCodRet;
		END IF;
		
		-- SI PCOMENTARIO = '' CONSULTAR DESCRIPCION EN LA TABLA BDISOLIC:"INFORMIX".SS_STATUS_SOL --
		IF NVL(pComentario,"") = "" THEN
			SELECT descripcion
			INTO cDescripcion_status
			FROM "informix".pr_status_sol
			WHERE empresa = '001' 
			AND status_solicitud = pNuevo_Status_Sol;
			
			LET pComentario = cDescripcion_status;
		END IF;
		
		--CONSULTAR LA FECHA_HOY DE LA TABLA BDINTEG:SI_FECHAS --		
		SELECT fecha_hoy
		INTO dFecha
		FROM bdinteg:"informix".si_fechas;
		
		-- CONSULTAR EL STATUS_ACTUAL DEL CLIENTE DE LA TABLA BDIPROSPECTOS:PR_CLIENTE QUE ES EL CAMPO STATUS_NUMCTE_PROS --
		--Se modifica consulta haciendo match entre pr_cliente y pr_autorizacion con parametros de estatus y causa sin alterar el codigo de retorno (resultado exitoso) para evitar modificar mas componentes.	

		--INICIA INC-21-12-2020
		/*SELECT A.status_numcte_pros, A.numcte
		INTO cStatus_actual, cNumctebcpl
		FROM "informix".pr_cliente A INNER JOIN "informix".pr_autorizacion B
		ON A.numcte_pros = pNum_ctepros
		AND B.num_solicitud = A.numcte_pros
		AND B.status_solicitud = A.status_numcte_pros
		AND B.fecha_salida IS NULL;*/
		
		SELECT LIMIT 1 A.status_numcte_pros, A.numcte
		INTO cStatus_actual, cNumctebcpl
		FROM "informix".pr_cliente A INNER JOIN "informix".pr_autorizacion B
		ON A.numcte_pros = pNum_ctepros
		AND B.num_solicitud = A.numcte_pros
		AND B.status_solicitud = A.status_numcte_pros
		AND B.fecha_salida IS NULL;
		
		--TERMINA INC-21-12-2020
		IF NVL(pNuevo_Status_Sol, '') = NVL(cStatus_actual, '') OR (NVL(cStatus_actual, '') IN ('RT', 'AT', 'CN') AND NVL(pNuevo_Status_Sol, '') <> 'CN') THEN
			RETURN cCodRet;
		END IF;		

		--SE INSERTA REGISTRO PARA RELANZAMIENTO
		IF (cStatus_actual = 'OA' AND pNuevo_Status_Sol = 'EE') OR (cStatus_actual = 'EC' AND pNuevo_Status_Sol = 'EE')
		THEN
			IF NOT EXISTS (SELECT num_solicitud FROM "informix".pr_solicitud_os WHERE num_solicitud=pNum_ctepros and status = 'S') THEN
				INSERT INTO "informix".pr_solicitud_os(empresa, num_solicitud, fecha_solicitud, status,usuario_solicita)
				VALUES ('001', pNum_ctepros, dFecha , "S", "sistema");
			END IF;
		END IF;	
		-- ACTUALIZAR LA FECHA_SALIDA DE LA TABLA BDIPROSPECTOS:PR_AUTORIZACION DONDE NUMERO DE SOLICITUD ES IGUAL A PNUM_CTEPROS Y STATUS_SOLICITUD IGUAL A STATUS_ACTUAL, LA FECHA SALIDA DEBE SER IGUAL A LA FECHA_HOY --
		UPDATE "informix".pr_autorizacion 
		SET fecha_salida = dFecha 
		WHERE num_solicitud = pNum_ctepros 
		AND status_solicitud = cStatus_actual
		AND fecha_entrada = (SELECT MAX(fecha_entrada) FROM pr_autorizacion 
		WHERE num_solicitud = pNum_ctepros AND status_solicitud = cStatus_actual);
		
		-- VALIDAR CON UN DBINFO SI SE REALIZO LA ACTUALIZACION --
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodret = '000002';
			RETURN cCodret;
		END IF;
		
		
		
		-- ACTUALIZAR EL STATUS_NUMCTE_PROS DEL CLIENTE DE LA TABLA PR_CLIENTE CON EL VALOR DEL PARAMETRO PNUEVO_STATUS_SOL CON EL FILTRO DE BUSQUEDA NUMCTE_PRO IGUAL A PNUM_CTEPROS --
		UPDATE "informix".pr_cliente 
		SET status_numcte_pros = pNuevo_Status_Sol,
		fecha_hora = CURRENT YEAR TO SECOND
		WHERE numcte_pros = pNum_ctepros
		AND status_numcte_pros = cStatus_actual;

		-- VALIDAR CON UN DBINFO SI SE REALIZO LA ACTUALIZACION --
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodret = '000003';
			RETURN cCodret;
		END IF;
		
		IF pNuevo_Status_Sol = 'RT' AND pCausa = 'RSC' THEN
			LET cSitEsp	  = 'P';
		    LET sCausaSit = 27;
		END IF;
		
		-- INSERTAR EN LA TABLA PR_AUTORIZACION EL REGISTRO DEL NUEVO STATUS --
		IF pNuevo_Status_Sol = 'AN' THEN
			IF EXISTS (SELECT num_solicitud FROM"informix".pr_autorizacion WHERE num_solicitud = pNum_ctepros AND status_solicitud = pNuevo_Status_Sol AND fecha_entrada = dFecha AND user_insert = pEjecutivo) THEN 
				DELETE FROM "informix".pr_autorizacion WHERE num_solicitud = pNum_ctepros AND status_solicitud = pNuevo_Status_Sol AND fecha_entrada = dFecha AND user_insert = pEjecutivo;
			END IF;
		END IF;
		
		INSERT INTO "informix".pr_autorizacion
		(empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, causa_solicitud, situacion_especial,  
		causa_situacion, fecha_entrada, fecha_salida, user_insert, fecha_insert, revision_cac, fecha_hora)
		VALUES ('001',pEjecutivo,pNum_ctepros,pNuevo_Status_Sol,NVL(pComentario,''),NVL(pCausa,''),NVL(cSitEsp,''), 
				NVL(sCausaSit,0),dFecha,'',pEjecutivo,CURRENT,0,CURRENT HOUR TO SECOND);
			
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodret = '000004';
			RETURN cCodret;
		END IF;
		
			IF  cNumctebcpl <> ''  AND pNuevo_Status_Sol IN ('RT', 'AT', 'CN','CP') THEN 		
				UPDATE bdinteg:"informix".si_cliente 
				SET cliente_pros = '0'
				WHERE numcte = cNumctebcpl;				
			END IF
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodret = '000005';
				RETURN cCodret;
			END IF;
		
		RETURN cCodret;		
	--END IF;
	END;
END PROCEDURE
