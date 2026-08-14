CREATE PROCEDURE "informix".sp_consultaactualizasolicmc_pba2(pEmpresa CHAR(3), pNumSolicitud CHAR(20), pEjecutivoAtiende CHAR(8), pStatus CHAR(2), pCausa CHAR(3), pObservaciones CHAR(300), pTipo SMALLINT)
RETURNING
	CHAR(6) 		AS CodRet,
	CHAR(20) 		AS NumSolicitud,
	CHAR(20) 		AS NumCte,
	CHAR(100) 		AS NombreCte,
	CHAR(13) 		AS Rfc,
	CHAR(4) 		AS Sucursal,
	DATE 			AS FechaInsert,
	DATE 			AS FechaModif,
	DECIMAL(18,2) 	AS MontoSolic,
	DECIMAL(18,2) 	AS Eficiencia,
	SMALLINT 		AS Historial,
	CHAR(2) 		AS StatusIni,
	DECIMAL(18,2) 	AS Seccion1,
	DECIMAL(18,2) 	AS Seccion2,
	CHAR(3) 		AS CausaSolic,
	CHAR(300) 		AS Observaciones,
	CHAR(4) 		AS NumProducto,
	CHAR(2) 		AS StatusFin,
	CHAR(8) 		AS EjecAtiende,
	CHAR(8) 		AS EjecAutoriza,
	DATETIME HOUR TO SECOND	AS HoraInsert,
	DATE 			AS FechaDetermin,
	CHAR(1) 		AS Revisado; 
	
---DECLARACIONES
DEFINE cCodRet			CHAR(6);
DEFINE cCodRet2			CHAR(6);
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);

-- VARIABLES DEL PROCESO
DEFINE cNumSolicitud	CHAR(20);
DEFINE cNumCte			CHAR(20);
DEFINE cNombreCte		CHAR(100);
DEFINE cRfc				CHAR(13);
DEFINE cSucursal		CHAR(4);
DEFINE dFechaInsert		DATE;
DEFINE dFechaModif		DATE;
DEFINE dcMontoSolic		DECIMAL(18,2);
DEFINE cStatusIni		CHAR(2);
DEFINE cCausaSolic		CHAR(3);
DEFINE cObservaciones	CHAR(300);
DEFINE cNumProducto		CHAR(4);
DEFINE cStatusFin		CHAR(2);
DEFINE cEjecAtiende		CHAR(8);
DEFINE cEjecAutoriza	CHAR(8);
DEFINE dtHoraInsert		DATETIME HOUR TO SECOND;
DEFINE dFechaDetermin	DATE;
DEFINE cRevisado		CHAR(1);
DEFINE cTimeTranscurrido	CHAR(40);
DEFINE sDiasTransc		SMALLINT;
DEFINE cHorasTransc		CHAR(10);
DEFINE iTmpMaxMostrar	SMALLINT;
DEFINE iDiaCambio		SMALLINT;
DEFINE dcEficiencia		DECIMAL(18,2);
DEFINE sHistorial		SMALLINT;
DEFINE dcSeccion1		DECIMAL(18,2);
DEFINE dcSeccion2		DECIMAL(18,2);
DEFINE cMinTransc		CHAR(10);
DEFINE cMinutosMax		CHAR(10);
DEFINE iPaso			INTEGER;
DEFINE vHoraActual DATETIME HOUR TO SECOND;
DEFINE vHoraAnterior DATETIME HOUR TO SECOND;
DEFINE dfecha DATE;
DEFINE cHora CHAR(10);
DEFINE cMensaje CHAR(80);
DEFINE cStatusNuevo CHAR(2);
DEFINE cStatusMovil CHAR(1);
DEFINE iMotivoOs INTEGER;
DEFINE iContOS INTEGER;
--APR
DEFINE cValor_alfabetico CHAR(100);
DEFINE cFLagGeoMov         CHAR(1);
DEFINE cFolioMovil         CHAR(20);
DEFINE cNumCteBco			CHAR(20);
DEFINE cCteProsp   			CHAR(20);
DEFINE cStatusSolic			CHAR(2);
DEFINE cDesStatusCtePros	CHAR(40);
DEFINE cClientePros			CHAR(1);
DEFINE sBanAuto		    	SMALLINT;
DEFINE dFecha_Respuesta		DATE;
DEFINE cStatusRespOs		CHAR(1);
DEFINE cDiaVigencia  		CHAR(2);
DEFINE cStatusPr			CHAR(2);
DEFINE iSecuenciaOs         INTEGER;
DEFINE cNuevoStatus         CHAR(2);
DEFINE cMensajeStatus       CHAR(80);
DEFINE cDescripcion	        CHAR(50);
DEFINE iPros		        INTEGER;
DEFINE iProsOS		        INTEGER;
DEFINE cNumPros2			CHAR(20);
DEFINE cStatusOS2			CHAR(1);
DEFINE cDescEstatustit      CHAR(50);	
DEFINE cMot					INTEGER;

DEFINE cClaveSup			CHAR(1);
DEFINE cBand_clave			CHAR(1);
DEFINE cStatus_vig			CHAR(2);
DEFINE dFecha_Ent			DATE;
DEFINE dFecha_Hoy			DATE;
DEFINE sDias_Vig			SMALLINT;
DEFINE cNumProd				CHAR(4);
DEFINE cVigenciaVencida		INTEGER;


-- INICIALIZACIONES
LET cCodRet				= '00000';
LET cCodRet2			= '00000';
LET iSqlErr				= 0;
LET iSamErr				= 0;
LET cErrorInfo			= '';

-- INICIALIZACIÓN DE VARIABLES DEL PROCESO.
LET cNumSolicitud		= '';
LET cNumCte				= '';
LET cNombreCte			= '';
LET cRfc				= '';
LET cSucursal			= '';
LET dFechaInsert		= DATE(1);
LET dFechaModif			= DATE(1);
LET dcMontoSolic		= 0.00;
LET cStatusIni			= '';
LET cCausaSolic			= '';
LET cObservaciones		= '';
LET cNumProducto		= '';
LET cStatusFin			= '';
LET cEjecAtiende		= '';
LET cEjecAutoriza		= '';
LET dtHoraInsert		= "";
LET dFechaDetermin		= DATE(1);
LET cRevisado			= 'N';
LET cTimeTranscurrido	= '';
LET sDiasTransc			= 0;
LET cHorasTransc		= '00:00:00';
LET iTmpMaxMostrar		= 0;
LET iDiaCambio		= 0;
LET dcEficiencia		= 0.00;
LET sHistorial			= 0;
LET dcSeccion1			= 0.00; 
LET dcSeccion2			= 0.00;
LET cMinTransc			= '00:00:00';
LET cMinutosMax			= '';
LET iPaso				= 0;
LET cDescEstatustit		= '';

LET cClaveSup			= '';
LET cBand_clave			= '';
LET cStatus_vig			= '';
LET dFecha_Hoy			= DATE(1);
LET dFecha_Ent			= DATE(1);
LET sDias_Vig			= 0;
LET cNumProd	  		= "";
LET cVigenciaVencida	= 0;
	
LET vHoraActual = CURRENT;
LET dfecha = today;
LET cMensaje = "";
LET cStatusNuevo = "";
LET cStatusMovil = "";
LET iMotivoOs    = 0;
LET iContOS = 0;
LET cFLagGeoMov ='';
LET cFolioMovil ='';

--APR
LET cValor_alfabetico = "";
LET cNumCteBco  		= "";
LET cCteProsp  			= "";
LET cStatusSolic  		= "";
LET cDesStatusCtePros 	= "";
LET cClientePros 		= "";
LET sBanAuto  			= 0;
LET dFecha_Respuesta 	= DATE(1);
LET cStatusRespOs 		= "";
LET cDiaVigencia 		= "00";
LET cStatusPr 			= "";
LET iSecuenciaOs   		= 0;
LET cNuevoStatus   		= "";
LET cMensajeStatus 		= "";
LET cDescripcion 		= "Solicitud paso el tiempo maximo para ser atendida";
LET iPros				= 0;
LET iProsOS				= 0;
LET cNumpros2			='';
LET cStatusOS2			='S';
LET cMot				= 0;

	
BEGIN

	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr::CHAR(8);
			RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)), 
				   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00), 
				   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''), 
				   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');
		END IF;
	END EXCEPTION; 
	
	--SET DEBUG FILE TO "/informix/josue_coppel/sp_consultaactualizasolicmc.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF NVL(pEmpresa, "") = "" OR NVL(pStatus, "") = "" OR pTipo NOT IN(1,2,3) THEN
		LET cCodRet = "00001"; -- PARAMETROS OBLIGATORIOS.
		RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)), 
			   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00), 
			   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''), 
			   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');
	END IF
	
	-- OBTENEMOS EL VALOR DE HORAS MAXIMO PARA MOSTRAR LAS SOLICITUDES MC.
	SELECT valor_numerico  INTO iTmpMaxMostrar FROM bdicobranza:"informix".cb_param_campania 
	WHERE tipo_campania = '56' AND grupo_parametro = 'MCTRLINEA' AND num_parametro = '1';
	
	-- LIMITE DE TIEMPO MAXIMO PARA SER ATENDIDA UNA SOLICITUD EN PANTALLA CCONCAC.
	SELECT TRIM(valor_alfabetico),valor_numerico INTO cMinutosMax,iDiaCambio FROM bdicobranza:"informix".cb_param_campania 
	WHERE tipo_campania = '56' AND grupo_parametro = 'MCTRLINEA' AND num_parametro = '2';	

	--LET cHora = vHoraActual - '00:10:00';
	LET cHora = vHoraActual - cMinutosMax::DATETIME HOUR TO SECOND; 
	LET vHoraAnterior = cHora;

	-- VALIDAMOS TODAS LAS SOLICITUDES QUE TENGAN MAS DE 15 MIN SIN SER ATENDIDAS POR UN EJECUTIVO SE PASAN A ORDEN DE SUPERVISION. 
	IF pTipo IN(1,2) THEN
		LET iPaso = 0; -- INICIALIZAMOS LA VARIABLE PARA CONTROL DE LA INFORMACIÓN.

        SELECT valor_alfabetico 
			INTO cValor_alfabetico 
		FROM  "informix".ss_param_solicitudes 
        WHERE empresa = pEmpresa 
		AND secuencia = 14 
		AND grupo_parametro = 'MOTIVOS_OS' 
		AND num_parametro = 14;	
		
		FOREACH
			SELECT num_solicitud, numcte, sucursal, status_ini, status_fin, ejecutivo_atiende, fecha_insert,num_producto,motivo_os
			INTO cNumSolicitud, cNumCte, cSucursal, cStatusIni, cStatusFin, cEjecAtiende, dFechaInsert,cNumProducto,iMotivoOs
			FROM "informix".ss_solicitudes_mc
			WHERE status_ini = pStatus
			AND (
				   (status_ini = pStatus AND  status_fin = "")
				    AND NVL(ejecutivo_autoriza,'') ='' 
					AND NVL(ejecutivo_atiende,'') ='' 
				    AND ((fecha_determinacion + iDiaCambio UNITS DAY < today )
							OR 
						 (fecha_determinacion + iDiaCambio UNITS DAY <= today AND hora_insert <= vHoraAnterior)
						 )
										
				)
		

			 LET cStatusSolic = "EE";

            --SE ACTUALIZA EL ESTATUS FINAL HEREDADO DEL CLIENTE PROSPECTO.
            UPDATE "informix".ss_solicitudes_mc 
            SET status_fin = cStatusSolic,
                observaciones = cDescripcion 
            WHERE empresa ='001' 
            AND num_solicitud = cNumSolicitud;

			------------------------------------------------------------------------------------------
			--OBTENER EL CLIENTE BANCO PARA IR A BUSCARLO EN LA PR_CLIENTE PARA DETERMINAR SI TUVO COMO ORIGEN CLIENTE PROSPECTO.
			SELECT numcte INTO cNumCteBco FROM "informix".ss_solicitudes WHERE num_solicitud = cNumSolicitud;		
			--SE CONSULTA SI EXISTE EL CLIENTE PROSPECTO.
			SELECT numcte_pros,status_numcte_pros INTO cCteProsp,cStatusSolic FROM bdiprospectos:"informix".pr_cliente WHERE empresa = pEmpresa AND numcte = cNumCteBco AND tipo_cliente = 3;
			--Obtiene la descripcion del estatus de cliente prospecto
			SELECT descripcion INTO cDesStatusCtePros FROM bdiprospectos:"informix".pr_status_sol WHERE status_solicitud = cStatusSolic;	
			--SE VALIDA QUE EL CLIENTE PROSPECTO ESTE AUTORIZADO PARA ASI PODER AUTORIZAR EL PRODUCTO 6500.
			IF NVL(cCteProsp,'') <> ''  THEN SELECT cliente_pros INTO cClientePros FROM bdinteg:"informix".si_cliente WHERE numcte = cNumCteBco; IF NVL(cClientePros,'') = '1' THEN LET sBanAuto = 1; END IF; END IF;
			------------------------------------------------------------------------------------------
		
			/*IF NVL(cNumProducto,"") = "6001" THEN																												
				--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR.
				IF NVL(cCteProsp,'') <> '' THEN
					SELECT secuencia,clave,fecharespuesta INTO iSecuenciaOs,cClaveSup,dFecha_Ent 
					FROM bdisolic:"informix".ss_osclientesupervisar
					WHERE empresa  = pEmpresa AND num_solicitud  = cCteProsp
					AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp);
				END IF;
			END IF;*/
			
			

			SELECT status, folio_movil
			INTO   cStatusMovil,cFolioMovil
			FROM "informix".ss_solicitudes_movil							
			WHERE 	empresa  = pEmpresa 
			AND  num_solicitud = cNumSolicitud
			AND status <> '3';
			---JMAH Geolocalizacion
			IF NVL(cFolioMovil,'') <> '' THEN      
				SELECT domicilio_alta INTO cFLagGeoMov  FROM bdinteg:"informix".si_solicitud_movil where folio = cFolioMovil;   
			ELSE
				LET cFLagGeoMov ='N';
			END IF;
				
				
			
			IF NVL(cNumProducto,"") = "6500" THEN
				IF EXISTS(SELECT num_solicitud FROM  "informix".ss_os_solautdirecta 
				WHERE empresa = pEmpresa  AND num_solicitud = cNumSolicitud) THEN			
								 
					IF NVL(cStatusMovil,'') = '1'  THEN
						LET cStatusSolic = 'PA';
						LET cMensaje= 'Solicitud Pre-Autorizada';					 
					ELSE
						LET cStatusSolic = "AT";
						LET cMensaje = "Solicitud Autorizada";								 
					END IF
				ELSE							
				
				
					IF cFLagGeoMov ='N' THEN
						LET cMensaje = "Solicitud Enviada a Orden de Supervisión";
						LET cStatusSolic = "EE";

						--INSERT INTO "informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, motivo_os)
						--VALUES("001", cNumSolicitud, TODAY, "S", "SISTEMA", iMotivoOs);

					ELSE
						LET cStatusSolic = "AT";					    
						LET cMensaje = "Solicitud Autorizada";							
					END IF;
								
								
				--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR.
				IF NVL(cCteProsp,'') <> '' THEN
					SELECT secuencia,clave,fecharespuesta INTO iSecuenciaOs,cClaveSup,dFecha_Ent
					FROM bdisolic:"informix".ss_osclientesupervisar
					WHERE empresa  = pEmpresa AND num_solicitud  = cCteProsp
					AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp);
				END IF;
				
				END IF;	
			ELSE
			
			
				IF cFLagGeoMov ='N' THEN
					LET cMensaje = "Solicitud Enviada a Orden de Supervisión";
					LET cStatusSolic = "EE";
				ELSE
					IF NVL(cStatusMovil,'') = '1'  THEN
						LET cStatusSolic = 'PA';
						LET cMensaje= 'Solicitud Pre-Autorizada';					 
					ELSE
						LET cStatusSolic = "AT";
						LET cMensaje = "Solicitud Autorizada";								 
					END IF					
				END IF;
								
				--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR.
				IF NVL(cCteProsp,'') <> '' THEN
					SELECT secuencia,clave,fecharespuesta INTO iSecuenciaOs,cClaveSup,dFecha_Ent 
					FROM bdisolic:"informix".ss_osclientesupervisar
					WHERE empresa  = pEmpresa AND num_solicitud  = cCteProsp
					AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp);
				END IF;
			END IF;
			
			IF NVL(cClaveSup,'') <> '' THEN							
				--SE OBTIENE LA FECHA DE EL DIA
				SELECT fecha_hoy
				INTO dFecha_Hoy
				FROM bdinteg: "informix".si_fechas;
				
				IF cClaveSup = 'A' THEN  LET cStatus_vig = "AT"; END IF;
				IF cClaveSup = 'R' THEN  LET cStatus_vig = "RT"; END IF;
				IF cClaveSup = 'D' THEN  LET cStatus_vig = "OA"; END IF;						
					
				-- SE OBTIENE EL TOTAL DE DIAS DE VIGENCIA MÁXIMO PARA UN CLIENTE EN ESE ESTATUS
				IF cClaveSup = 'D' THEN
					SELECT dias_vigencia INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = cNumProducto AND resp_oscalle = '';
				ELSE 
					SELECT dias_vigencia INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = cNumProducto AND resp_oscalle = cClaveSup;	
				END IF;
				
				-- SI EL ESTATUS CUENTA CON DIAS DE VIGENCIA SE OBTENDRAN LOS DATOS PARA CANCELAR EL CLIENTE
				IF NVL(sDias_Vig,0) > 0 THEN
				
					-- SI LA FECHA ACTUAL ES MAYOR O IGUAL A LA FECHA DE ENTRADA A ESE ESTATUS MÁS LOS DÍAS DE VIGENCIA
					IF dFecha_Hoy > (dFecha_Ent + sDias_Vig::INTEGER UNITS DAY)  THEN
						LET cVigenciaVencida = 1;
						LET dfecha_ent = DATE(1);
						-- EL NUMCTE SE DEBE DE ENCONTRAR UNA SOLA VEZ EN LA TABLA  SS_SOLICITUDES CON TIPO DE SOLICITUD = "C"
						IF (SELECT COUNT(numcte)FROM "informix".ss_solicitudes WHERE numcte = cNumCteBco AND tipo_solicitud = "C") = 1 THEN	
							LET iMotivoOs = 15;
						END IF;
					ELSE 
						LET cStatusSolic = cStatus_vig;										
					END IF;
				END IF;							
			END IF;
			
			LET cMensajeStatus = cDesStatusCtePros;
			--LET cStatusPr = "P";
            LET cStatusPr = "S"; --APR

			IF NVL(cStatusSolic,'') = '' OR NVL(cStatusSolic,'') = 'CN'  OR cVigenciaVencida = 1 THEN
				LET cStatusSolic = 'EE';
				LET cStatusPr = "S"; 
				LET iSecuenciaOs = 0;
                LET cVigenciaVencida = 0;
			ELSE
				--IF cStatusSolic = "AT" THEN 
                IF cStatusSolic IN("AT","PA") THEN 
					IF EXISTS(SELECT num_solicitud FROM  "informix".ss_os_solautdirecta WHERE empresa = pEmpresa  AND num_solicitud = cNumSolicitud) THEN
						--LET cStatusPr = "S";
						LET cBand_clave = '1';
					ELSE
						LET cStatusPr = "A";
					END IF;
					LET cDesStatusCtePros = "Solicitud Autorizada";
					LET cMensajeStatus = cDesStatusCtePros;
					
				ELIF cStatusSolic = "EE" THEN 
					IF NVL(dFecha_Ent,DATE(1)) <> DATE(1) THEN 
						IF dFecha_Hoy > (dFecha_Ent + sDias_Vig::INTEGER UNITS DAY) THEN
							LET cStatusPr = "S";
							LET iSecuenciaOs = 0;
						ELSE
							LET cStatusPr = "P"; 
						END IF;	
					ELSE
						--LET cStatusPr = "P"; 
                        LET cStatusPr = "S"; --APR
					END IF;		
				ELIF cStatusSolic = "OS" THEN 
					LET cStatusPr = "P"; 
				ELIF cStatusSolic = "RT" THEN LET cStatusPr = "R";  
				ELIF cStatusSolic = "OA" THEN LET cStatusPr = "D"; 
				END IF;
			END IF;
			
			SELECT descripcion INTO cMensaje FROM "informix".ss_status_sol WHERE status_solicitud = cStatusSolic;
			
			-- ACTUALIZAMOS LA SOLICITUD 
			EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(pEmpresa, pEjecutivoAtiende, cNumSolicitud, cStatusSolic, "",cMensaje)
			INTO cCodRet2;
			
			 -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD.
			IF cCodRet2 <> '000000' THEN LET cCodRet = '00002'; END IF;
				
			--IF NVL(dFecha_Ent,DATE(1)) = DATE(1) THEN
				--LET dFecha_Ent = dFecha_Hoy;
			--END IF;
			
			IF cBand_clave = '' THEN
				INSERT INTO "informix".ss_solicitud_os (empresa, num_solicitud, fecha_solicitud, fecha_respuesta,status,usuario_solicita, motivo_os,secuenciaos)
				VALUES (pEmpresa,cNumSolicitud, TODAY,dFecha_Ent ,cStatusPr, 'sistema',iMotivoOs, iSecuenciaOs);	
			END IF;
			
			--SE ACTUALIZA EL ESTATUS FINAL HEREDADO DEL CLIENTE PROSPECTO.
			UPDATE "informix".ss_solicitudes_mc SET status_fin = cStatusSolic, observaciones = cDescripcion 
			WHERE empresa ='001' AND num_solicitud = cNumSolicitud;			
			LET  cBand_clave = '';
			--END IF;
		--END IF;
		END FOREACH
		IF pTipo = 2 THEN 
			IF DBINFO("sqlca.sqlerrd2") = 0 OR iPaso = 0 THEN
				LET cCodRet = '00004'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.
			END IF;
			RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)), 
			   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00), 
			   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''), 
			   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');
		END IF;			
	END IF 
	
	-- CONSULTAMOS TODAS LAS SOLICITUDES CON ESTATUS "MC" PARA SER ATENDIDAS POR EL ANALISTA.
	IF pTipo = 1 THEN
		
		LET iPaso = 0; -- INICIALIZAMOS VARIABLE PARA CONTROL DE LA INFORMACIÓN.
		
		FOREACH
			SELECT  num_solicitud, numcte, sucursal, fecha_insert,				   
				   monto_solicitado, status_ini, observaciones, num_producto,  status_fin, ejecutivo_atiende, 
				   ejecutivo_autoriza,  fecha_determinacion, revisado,hora_insert
			INTO cNumSolicitud, cNumCte, cSucursal, dFechaInsert,  dcMontoSolic, cStatusIni, cObservaciones, 
				 cNumProducto, cStatusFin, cEjecAtiende, cEjecAutoriza, dFechaDetermin, cRevisado,dtHoraInsert 
			FROM "informix".ss_solicitudes_mc 			 
			WHERE empresa = pEmpresa
			AND  status_ini = pStatus AND  status_fin = ""
			ORDER BY tipo_alta ASC, num_producto ASC, hora_insert  ASC
			
			LET dFechaModif = dFechaDetermin;
			
			SELECT rfc,TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) 
			INTO cRfc,cNombreCte
			FROM bdinteg:"informix".si_cliente 
			WHERE empresa = '001' 
			AND numcte = cNumCte;
	
			-- SE OBTIENEN LOS DATOS DE LA INFORMACIÓN CREDITICIA EN COPPEL/BANCOPPEL.
			SELECT situacion_pago, meses_historia 
			INTO dcEficiencia, sHistorial 
			FROM "informix".ss_resum_scor_fin 
			WHERE empresa = pEmpresa 
				AND num_solicitud = cNumSolicitud;
			
			-- SE OBTIENE LAS PUNTUACIONES DEL SCORING QUE SE LE REALIZÓ AL CLIENTE.
			SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1, 
				   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2
			INTO dcSeccion1, dcSeccion2 
			FROM "informix".ss_resumen_scoring 
			WHERE empresa = pEmpresa 
				AND num_solicitud = cNumSolicitud 
				AND seccion IN ('1','2');
			
			LET iPaso = 1; -- VARIABLE PARA CONTROL DE LA INFORMACIÓN.
							
			RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)), 
			NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00), 
			NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''), 
			NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'') WITH RESUME;
					
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 OR iPaso = 0 THEN
			LET cCodRet = '00003'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.
			
			RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)), 
			NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00), 
			NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''), 
			NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');
		END IF
		
	END IF;
	
	-- GUARDAMOS LA RESPUESTA DEL ANALISTA QUE ATENDIO LA SOLICITUD.
	IF pTipo = 3 THEN
		
		IF NVL(pEmpresa, "") = "" OR NVL(pEjecutivoAtiende, "") = "" OR NVL(pStatus, "") = "" OR NVL(pNumSolicitud, "") = ""  THEN
			LET cCodRet = "00001"; -- PARAMETROS OBLIGATORIOS.
		END IF
		
		IF NVL(pStatus, "") IN("CM","RT") AND NVL(pCausa, "") = "" THEN
			LET cCodRet = "00001"; -- PARAMETROS OBLIGATORIOS.
		END IF		
		
		LET cStatusNuevo = "EE";
		------------------------------------------------------------------------------------------
		--OBTENER EL CLIENTE BANCO PARA IR A BUSCARLO EN LA PR_CLIENTE PARA DETERMINAR SI TUVO COMO ORIGEN CLIENTE PROSPECTO.
		SELECT numcte INTO cNumCteBco FROM "informix".ss_solicitudes WHERE num_solicitud = pNumSolicitud;		
		--SE CONSULTA SI EXISTE EL CLIENTE PROSPECTO.
		SELECT numcte_pros,status_numcte_pros INTO cCteProsp,cStatusSolic FROM bdiprospectos:"informix".pr_cliente WHERE empresa = pEmpresa AND numcte = cNumCteBco AND tipo_cliente = 3;
		--Obtiene la descripcion del estatus de cliente prospecto
		SELECT descripcion INTO cDesStatusCtePros FROM bdiprospectos:"informix".pr_status_sol WHERE status_solicitud = cStatusSolic;	
		--SE VALIDA QUE EL CLIENTE PROSPECTO ESTE AUTORIZADO PARA ASI PODER AUTORIZAR EL PRODUCTO 6500.
		IF NVL(cCteProsp,'') <> ''  THEN SELECT cliente_pros INTO cClientePros FROM bdinteg:"informix".si_cliente WHERE numcte = cNumCteBco; IF NVL(cClientePros,'') = '1' THEN LET sBanAuto = 1; END IF; END IF;
		------------------------------------------------------------------------------------------		
		IF cCodRet = "00000" THEN
			-- ACTUALIZAMOS LA RESPUESTA DEL ANALISTA QUE ATENDIO LA SOLICITUD.			
			UPDATE "informix".ss_solicitudes_mc 
			SET status_fin = pStatus, 
			ejecutivo_autoriza = pEjecutivoAtiende,
			observaciones = pObservaciones, 
			fecha_determinacion = TODAY,
			revisado = "S"
			WHERE empresa = pEmpresa
			  AND num_solicitud = pNumSolicitud
			  AND status_ini = "MC"
			  AND status_fin = ""
			  AND ejecutivo_atiende = pEjecutivoAtiende;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00005'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.
				
			ELSE
				
				IF NVL(pStatus, "") = "EE" THEN
					--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR.
					/*IF NVL(cNumProducto,"") = "6001" THEN																												
						--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR.
						IF NVL(cCteProsp,'') <> '' THEN
							SELECT secuencia,clave,fecharespuesta INTO iSecuenciaOs,cClaveSup,dFecha_Ent 
							FROM bdisolic:"informix".ss_osclientesupervisar
							WHERE empresa  = pEmpresa AND num_solicitud  = cCteProsp
							AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp);
						END IF;						
					END IF;*/
					
					IF NVL(cNumProducto,"") = "6500" THEN
						IF EXISTS(SELECT num_solicitud FROM  "informix".ss_os_solautdirecta 
						WHERE empresa = pEmpresa  AND num_solicitud = cNumSolicitud) THEN
							SELECT status 
							INTO cStatusMovil 
							FROM "informix".ss_solicitudes_movil							
							WHERE empresa  = pEmpresa 
							AND num_solicitud = cNumSolicitud
							AND status <> '3';
								 
							IF NVL(cStatusMovil,'') = '1'  THEN
								LET cStatusSolic = 'PA';
								LET cMensaje= 'Solicitud Pre-Autorizada';					 
							ELSE
								LET cStatusSolic = "AT";
								LET cMensaje = "Solicitud Autorizada";								 
							END IF
						ELSE							
						
						--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR.
						IF NVL(cCteProsp,'') <> '' THEN
							SELECT secuencia,clave,fecharespuesta INTO iSecuenciaOs,cClaveSup,dFecha_Ent
							FROM bdisolic:"informix".ss_osclientesupervisar
							WHERE empresa  = pEmpresa AND num_solicitud  = cCteProsp
							AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp);
						END IF;
						
						END IF;	
					ELSE
						--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR.
						IF NVL(cCteProsp,'') <> '' THEN
							SELECT secuencia,clave,fecharespuesta INTO iSecuenciaOs,cClaveSup,dFecha_Ent 
							FROM bdisolic:"informix".ss_osclientesupervisar
							WHERE empresa  = pEmpresa AND num_solicitud  = cCteProsp
							AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp);
						END IF;	
					END IF;					
						
					IF NVL(cClaveSup,'') <> '' THEN							
						--SE OBTIENE LA FECHA DE EL DIA
						SELECT fecha_hoy
						INTO dFecha_Hoy
						FROM bdinteg: "informix".si_fechas;
						
						IF cClaveSup = 'A' THEN  LET cStatus_vig = "AT"; END IF;
						IF cClaveSup = 'R' THEN  LET cStatus_vig = "RT"; END IF;
						IF cClaveSup = 'D' THEN  LET cStatus_vig = "OA"; END IF;											
							
						-- SE OBTIENE EL TOTAL DE DIAS DE VIGENCIA MÁXIMO PARA UN CLIENTE EN ESE ESTATUS
						IF cClaveSup = 'D' THEN
							SELECT dias_vigencia INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = cNumProducto AND resp_oscalle = '';
						ELSE 
							SELECT dias_vigencia INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = cNumProducto AND resp_oscalle = cClaveSup;	
						END IF;
						
						-- SI EL ESTATUS CUANTA CON DIAS DE VIGENCIA SE OBTENDRAN LOS DATOS PARA CANCELAR EL CLIENTE
						IF NVL(sDias_Vig,0) > 0 THEN
							--SE OBTIENE LA FECHA EN QUE ENTRÓ EN ESE ESTATUS EL CLIENTE Y EL EJECUTIVO QUE REALIZÓ EL REGISTRO
							SELECT fecha_entrada INTO dFecha_Ent FROM "informix".ss_autorizacion
							WHERE num_solicitud = cNumSolicitud AND status_solicitud = cStatus_vig
							AND fecha_entrada =	(SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion WHERE num_solicitud = cNumSolicitud AND status_solicitud = cStatus_vig);

							-- SI LA FECHA ACTUAL ES MAYOR O IGUAL A LA FECHA DE ENTRADA A ESE ESTATUS MÁS LOS DÍAS DE VIGENCIA
							IF dFecha_Hoy > (dFecha_Ent + sDias_Vig::INTEGER UNITS DAY)  THEN
								LET cVigenciaVencida = 1;
								LET dfecha_ent = DATE(1);
								-- EL NUMCTE SE DEVE DE ENCONTRAR UNA SOLA VEZ EN LA TABLA  SS_SOLICITUDES CON TIPO DE SOLICITUD = "C"
								IF (SELECT COUNT(numcte)FROM "informix".ss_solicitudes WHERE numcte = cNumCteBco AND tipo_solicitud = "C") = 1 THEN	
									LET iMotivoOs = 15;
								END IF;
							ELSE 
								LET cStatusSolic = cStatus_vig;										
							END IF;
						END IF;
					END IF;	
					
					LET cMensajeStatus = cDesStatusCtePros;
					LET cStatusPr = "P";

					IF NVL(cStatusSolic,'') = '' OR NVL(cStatusSolic,'') = 'CN'  OR cVigenciaVencida = 1 THEN
						LET cStatusSolic = 'EE';
						LET cStatusPr = "S"; 
						LET iSecuenciaOs = 0;
                        LET cVigenciaVencida = 0;
					ELSE
						IF cStatusSolic = "AT" THEN 
							IF EXISTS(SELECT num_solicitud FROM  "informix".ss_os_solautdirecta WHERE empresa = pEmpresa  AND num_solicitud = cNumSolicitud) THEN
								--LET cStatusPr = "S";
								LET cBand_clave = '1';
							ELSE
								LET cStatusPr = "A";
							END IF;
							LET cDesStatusCtePros = "Solicitud Autorizada";
							LET cMensajeStatus = cDesStatusCtePros;							
						ELIF cStatusSolic = "EE" THEN 
							IF NVL(dFecha_Ent,DATE(1)) <> DATE(1) THEN 
								IF dFecha_Hoy > (dFecha_Ent + sDias_Vig::INTEGER UNITS DAY) THEN
									LET cStatusPr = "S"; 
									LET iSecuenciaOs = 0;
								ELSE
									LET cStatusPr = "P"; 
								END IF;	
							ELSE
								LET cStatusPr = "P"; 
							END IF;							
						ELIF cStatusSolic = "OS" THEN 
								LET cStatusPr = "P"; 
						ELIF cStatusSolic = "RT" THEN LET cStatusPr = "R";  
						ELIF cStatusSolic = "OA" THEN LET cStatusPr = "D"; 
						END IF;
					END IF;
					
					SELECT descripcion INTO cMensaje FROM "informix".ss_status_sol WHERE status_solicitud = cStatusSolic;
					
					-- ACTUALIZAMOS LA SOLICITUD 
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(pEmpresa, pEjecutivoAtiende, cNumSolicitud, cStatusSolic, "",cMensaje) INTO cCodRet2;
					
					-- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD.
					IF cCodRet2 <> '000000' THEN LET cCodRet = '00002'; END IF;									
											
					--IF NVL(dFecha_Ent,DATE(1)) = DATE(1) THEN
						--LET dFecha_Ent = dFecha_Hoy;
					--END IF;
					
					IF cBand_clave = '' THEN
						INSERT INTO "informix".ss_solicitud_os (empresa, num_solicitud, fecha_solicitud, fecha_respuesta,status,usuario_solicita, motivo_os,secuenciaos)
						VALUES (pEmpresa,cNumSolicitud, TODAY,dFecha_Ent ,cStatusPr, 'sistema',iMotivoOs, iSecuenciaOs);	
					END IF;
					
				END IF;
			END IF;
		END IF;
		RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)), 
			   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00), 
			   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''), 
			   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');
		
	END IF;	
END
END PROCEDURE
