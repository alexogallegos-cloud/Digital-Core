CREATE PROCEDURE "informix".sp_consultaactualizasolicmc(pEmpresa CHAR(3), pNumSolicitud CHAR(20), pEjecutivoAtiende CHAR(8), pStatus CHAR(2), pCausa CHAR(3), pObservaciones CHAR(300), pTipo SMALLINT)
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
	
-------------------------------------------------------------------------------------------------------------
-- CONTROL DE CAMBIOS	
-------------------------------------------------------------------------------------------------------------
-- ModificÃ³: Gabriela Esmeralda GonzÃ¡lez BÃ¡Ã±ez
-- Fecha de ModificaciÃ³n: 11-02-2019
-- DescripciÃ³n: Se modifica el flujo de las solicitudes 
--              para clientes con solicitudes previas canceladas por mesa de control.
-- RQ: RQM 09 501 - ImplementaciÃ³n - Flujo para Clientes con Solicitudes Canceladas en Mesa de Control.
-- CC Rational: 29749 
-------------------------------------------------------------------------------------------------------------

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
DEFINE cNombre1			CHAR(100);
DEFINE cNombre2			CHAR(100);
DEFINE cApellPat		CHAR(100);
DEFINE cApellMat		CHAR(100);
DEFINE cRfc				CHAR(13);
DEFINE cSucursal		CHAR(4);
DEFINE dFechaInsert		DATE;
DEFINE dFechaModif		DATE;
DEFINE dcMontoSolic		DECIMAL(18,2);
DEFINE cStatusIni		CHAR(2);
DEFINE v_hereda_status  CHAR(2);
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
DEFINE vHoraActual 		DATETIME HOUR TO SECOND;
DEFINE vHoraAnterior 	DATETIME HOUR TO SECOND;
DEFINE dfecha 			DATE;
DEFINE cHora 			CHAR(10);
DEFINE cMensaje 		CHAR(80);
DEFINE cStatusNuevo 	CHAR(2);
DEFINE cStatusMovil 	CHAR(1);
DEFINE iMotivoOs 		INTEGER;
DEFINE iContOS 			INTEGER;
DEFINE cRegion 			CHAR(1); 
DEFINE cIdBox 			CHAR(1);
DEFINE cScore 			DECIMAL(18,2);
DEFINE cPrioridad 		INTEGER; -- GEGB 20190211 RQM 09 501
DEFINE vLatitud 		CHAR(20); -- GEGB 20190211
DEFINE vLongitud 		CHAR(20); -- GEGB 20190211
DEFINE vGeoDif 			INTEGER; -- GEGB 20190213
DEFINE iCont			INTEGER;
--APR
DEFINE cValor_alfabetico    CHAR(100);
DEFINE cFLagGeoMov          CHAR(1);
DEFINE cFolioMovil          CHAR(20);
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
DEFINE vdiastrans 			INTEGER;
DEFINE cNumSolOs 			CHAR(20);
DEFINE cGeoCte 				CHAR (20);
DEFINE dFechaVencimiento 	DATE;
DEFINE cTipoSol 			CHAR(1);

--- RQM 09492
DEFINE iValido                  INTEGER;
DEFINE v_valor                  DECIMAL(14,2);
DEFINE cMensajeRet              CHAR(100);   
DEFINE cCodRetComp		        CHAR(6);

-- INICIALIZACIONES
LET cCodRet				= '00000';
LET cCodRet2			= '00000';
LET iSqlErr				= 0;
LET iSamErr				= 0;
LET cErrorInfo			= '';

-- INICIALIZACION DE VARIABLES DEL PROCESO.
LET cNumSolicitud		= '';
LET cNumCte				= '';
LET cNombreCte			= '';
LET cNombre1			= ''; -- GEGB 20190211
LET cNombre2			= ''; -- GEGB 20190211
LET cApellPat			= ''; -- GEGB 20190211
LET cApellMat			= ''; -- GEGB 20190211
LET cRfc				= '';
LET cSucursal			= '';
LET dFechaInsert		= DATE(1);
LET dFechaModif			= DATE(1);
LET dcMontoSolic		= 0.00;
LET cStatusIni			= '';
LET v_hereda_status		= '';
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
LET iDiaCambio			= 0;
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
	
LET vHoraActual 		= CURRENT;
LET dfecha 				= today;
LET cMensaje 			= "";
LET cStatusNuevo 		= "";
LET cStatusMovil 		= "";
LET iMotivoOs    		= 0;
LET iContOS 			= 0;
LET vLatitud 			= ''; -- GEGB 20190211
LET vLongitud			= ''; -- GEGB 20190211
LET vGeoDif 			= 0; -- GEGB 20190211
LET iCont				= 0; -- GEGB 20190213
LET cFLagGeoMov 		= '';
LET cFolioMovil 		= '';
LET cRegion 			= ''; 
LET cIdBox 				= '';
LET cScore 				= 0.00;
LET cPrioridad 			= 0; -- GEGB 20190211 RQM 09 501

--APR
LET cValor_alfabetico 	= "";
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

LET vdiastrans 			= 0;
LET cNumSolOs 			= '';	
LET cGeoCte 			= '';
LET dFechaVencimiento 	= DATE(1);
LET cTipoSol 			= '';
--RQM 09 492
LET v_valor             = 0;
LET cMensajeRet         = '';
LET iValido             = 0;
LET cCodRetComp		    = '000000';
	
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
	
	ON EXCEPTION IN (-668, -535, -255)
		COMMIT;
		BEGIN;
	END EXCEPTION WITH RESUME;
		
 	--SET DEBUG FILE TO "/tmp/sp_consultaactualizasolicmc.out";
	--SET DEBUG FILE TO "/informix/GabrielaEsmeralda/RQM09501/Test20190201/sp_consultaactualizasolicmc.out";
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
/*	SELECT valor_numerico  INTO iTmpMaxMostrar FROM bdicobranza:"informix".cb_param_campania 
	WHERE tipo_campania = '56' AND grupo_parametro = 'MCTRLINEA' AND num_parametro = '1';
	
	-- LIMITE DE TIEMPO MAXIMO PARA SER ATENDIDA UNA SOLICITUD EN PANTALLA CCONCAC.
	SELECT valor_alfabetico,valor_numerico INTO cMinutosMax,iDiaCambio FROM bdicobranza:"informix".cb_param_campania 
	WHERE tipo_campania = '56' AND grupo_parametro = 'MCTRLINEA' AND num_parametro = '2';	
    --LET cHora = vHoraActual - '00:10:00';
	
	LET cHora = vHoraActual - TRIM(cMinutosMax)::DATETIME HOUR TO SECOND; 
	LET vHoraAnterior = cHora;
	
	--SE OBTIENE LA FECHA DE EL DIA
	SELECT fecha_hoy
	INTO dFecha_Hoy
	FROM bdinteg: "informix".si_fechas
	WHERE empresa = pEmpresa;

	-- VALIDAMOS TODAS LAS SOLICITUDES QUE TENGAN MAS DE 15 MIN SIN SER ATENDIDAS POR UN EJECUTIVO SE PASAN A ORDEN DE SUPERVISION. 
	IF pTipo IN(1,2) THEN
		LET iPaso = 0; -- INICIALIZAMOS LA VARIABLE PARA CONTROL DE LA INFORMACION.

        SELECT valor_alfabetico 
			INTO cValor_alfabetico 
		FROM  "informix".ss_param_solicitudes 
        WHERE empresa = pEmpresa 
		AND secuencia = 14 
		AND grupo_parametro = 'MOTIVOS_OS' 
		AND num_parametro = 14;	
		
		FOREACH WITH HOLD
			SELECT num_solicitud, numcte, sucursal, status_ini, status_fin, ejecutivo_atiende, fecha_insert,num_producto,motivo_os,status_hereda
			INTO cNumSolicitud, cNumCte, cSucursal, cStatusIni, cStatusFin, cEjecAtiende, dFechaInsert,cNumProducto,iMotivoOs,v_hereda_status
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
		
				--LET cStatusSolic = "EE";
				LET cStatusSolic = v_hereda_status;

            --SE ACTUALIZA EL ESTATUS FINAL HEREDADO DEL CLIENTE PROSPECTO.
            UPDATE "informix".ss_solicitudes_mc 
            SET status_fin = cStatusSolic,
                observaciones = cDescripcion 
            WHERE empresa ='001' 
            AND num_solicitud = cNumSolicitud;

			------------------------------------------------------------------------------------------
			--OBTENER EL CLIENTE BANCO PARA IR A BUSCARLO EN LA PR_CLIENTE PARA DETERMINAR SI TUVO COMO ORIGEN CLIENTE PROSPECTO.
			SELECT numcte,monto_solicitado INTO cNumCteBco,v_valor FROM "informix".ss_solicitudes WHERE num_solicitud = cNumSolicitud;		
			--SE CONSULTA SI EXISTE EL CLIENTE PROSPECTO.
			SELECT numcte_pros,status_numcte_pros INTO cCteProsp,cStatusSolic FROM bdiprospectos:"informix".pr_cliente WHERE empresa = pEmpresa AND numcte = cNumCteBco AND tipo_cliente = 3;
			--Obtiene la descripcion del estatus de cliente prospecto
			SELECT descripcion INTO cDesStatusCtePros FROM bdiprospectos:"informix".pr_status_sol WHERE status_solicitud = cStatusSolic;	
			--SE VALIDA QUE EL CLIENTE PROSPECTO ESTE AUTORIZADO PARA ASI PODER AUTORIZAR EL PRODUCTO 6500.
			IF NVL(cCteProsp,'') <> ''  THEN SELECT cliente_pros INTO cClientePros FROM bdinteg:"informix".si_cliente WHERE numcte = cNumCteBco; IF NVL(cClientePros,'') = '1' THEN LET sBanAuto = 1; END IF; END IF;
			------------------------------------------------------------------------------------------
		*/
			/*IF NVL(cNumProducto,"") = "6001" THEN																												
				--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR.
				IF NVL(cCteProsp,'') <> '' THEN
					SELECT secuencia,clave,fecharespuesta INTO iSecuenciaOs,cClaveSup,dFecha_Ent 
					FROM bdisolic:"informix".ss_osclientesupervisar
					WHERE empresa  = pEmpresa AND num_solicitud  = cCteProsp
					AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp);
				END IF;
			END IF;*/
			
			
/*
			SELECT status, folio_movil
			INTO   cStatusMovil,cFolioMovil
			FROM "informix".ss_solicitudes_movil							
			WHERE 	empresa  = pEmpresa 
			AND  num_solicitud = cNumSolicitud
			AND status <> '3';
			---JMAH Geolocalizacion
			IF NVL(cFolioMovil,'') <> '' THEN      
				--SELECT domicilio_alta INTO cFLagGeoMov  FROM bdinteg:"informix".si_solicitud_movil where folio = cFolioMovil;   
				SELECT domicilio_alta,geolocalizacion INTO cFLagGeoMov,cGeoCte  FROM bdinteg:"informix".si_solicitud_movil where folio = cFolioMovil;   
			ELSE
				LET cFLagGeoMov ='N';
			END IF;
			--Inicia Geolocalizacion
			IF NVL(cFolioMovil,'') <> '' AND NVL(cNumProducto,'') = '6001' THEN      --hsrr 387
			
				--SELECT domicilio_alta,geolocalizacion INTO cFLagGeoMov,cGeoCte  FROM bdinteg:"informix".si_solicitud_movil where folio = cFolioMovil;   
				
				IF cFLagGeoMov = 'S' THEN
					LET cFLagGeoMov = 'N';	-- Se considera domicilio no geolocalizado hasta que se demuestre lo contrario.
					IF LEN(NVL(TRIM(cGeoCte),'')) > 10 THEN	-- Si la variable cGeoCte el len es menos de 10 quiere decir que son coordenadas basura					
						
						LET cGeoCte = TRIM(cGeoCte);
						LET vLatitud = SUBSTR(cGeoCte,1,(CHARINDEX(',',cGeoCte) - 1));
						LET vLongitud = SUBSTR(cGeoCte, CHARINDEX(',',cGeoCte) - LEN(cGeoCte));
												
						SELECT COUNT(*) INTO vGeoDif FROM bdinteg:"informix".si_ptf WHERE latitud = vLatitud AND longitud = vLongitud;
										
						IF vGeoDif = 0 THEN -- Domicilio Geolocalizado diferente al de sucursal
							LET cFLagGeoMov = 'S';
						END IF;
					END IF;
				END IF;			
			END IF;
			--Fin Geolocalizacion
			
			IF NVL(cNumProducto,"") = "6500" THEN
				
				SELECT COUNT(num_solicitud) INTO iCont FROM "informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = cNumSolicitud;
					
				IF NVL(iCont,0) > 0 THEN
					LET iCont = 0;
					IF NVL(cStatusMovil,'') = '1'  THEN
						LET cStatusSolic = 'PA';
						LET cMensaje= 'Solicitud Pre-Autorizada';					 
					ELSE
						LET cStatusSolic = "AT";
						LET cMensaje = "Solicitud Autorizada";								 
					END IF
				ELSE							
				
				
					IF cFLagGeoMov ='N' THEN
						LET cMensaje = "Solicitud Enviada a Orden de Supervision";
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
			ELSE -- hsrr si no es coppel
			
                --Inicio Herencia de los estatus de una OS existente y vigente del mismo Cliente
				IF cFLagGeoMov ='N' THEN
					LET cMensaje = "Solicitud Enviada a Orden de Supervision";
					LET cStatusSolic = "EE";
				ELSE
					IF NVL(cStatusMovil,'') = '1'  THEN
						LET cStatusSolic = 'PA';
						LET cMensaje= 'Solicitud Pre-Autorizada';					 
					ELSE
						LET cStatusSolic = "AT";
						LET cMensaje = "Solicitud Autorizada";								 
					END IF;
					LET cBand_clave = '1';
				END IF;
								
				--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR.
				IF NVL(cCteProsp,'') <> '' THEN
					SELECT secuencia,clave,fecharespuesta INTO iSecuenciaOs,cClaveSup,dFecha_Ent 
					FROM bdisolic:"informix".ss_osclientesupervisar
					WHERE empresa  = pEmpresa AND num_solicitud  = cCteProsp
					AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp);
				END IF;
			END IF;
			
			--Inicio Herencia de los estatus de una OS existente y vigente del mismo Cliente
			IF cStatusSolic = 'EE' THEN
			
				SELECT  b.clave_producto
				INTO cNumProducto-- cProducto
				FROM bdicred:"informix".sd_definicion a
				JOIN bdisolic:ss_oscalle_plazovigencia b ON b.clave_producto=a.num_producto 
				AND a.bandera_os = 1 AND resp_oscalle in ('A','R')
				AND b.clave_producto = cNumProducto  --Se agrega validacion porque ya se sabe que el producto es Banco
				group by b.clave_producto;
	
				IF NVL(cNumProducto,'') <> '' THEN 
	
					FOREACH
						--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR PARA TITULAR 'T' Y PROSPECTOS 'P'.		
						SELECT LIMIT 1 b.secuencia,b.clave,b.fecharespuesta,a.num_solicitud,'T' tipo_sol
						INTO  iSecuenciaOs,cStatusRespOs,dFecha_Respuesta,cNumSolOs,cTipoSol
						FROM  bdisolic:"informix".ss_solicitudes a
						JOIN bdisolic:"informix".ss_osclientesupervisar b ON (a.num_solicitud = b.num_solicitud)
						WHERE a.empresa = b.empresa AND b.secuencia=(SELECT MAX(d.secuencia) from bdisolic:"informix".ss_osclientesupervisar AS d WHERE d.num_solicitud = b.num_solicitud)
						AND clave IN ('A','R') AND fecharespuesta IS NOT NULL AND a.numcte = cNumCte
						UNION 
						SELECT secuencia,clave,fecharespuesta,num_solicitud,'P' tipo_sol
						FROM bdisolic:"informix".ss_osclientesupervisar
						WHERE empresa  = pEmpresa AND num_solicitud  = cCteProsp
						AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp)
						ORDER BY fecharespuesta DESC
					END FOREACH;			
					
					IF nvl(iSecuenciaOs,0)<>0 THEN	
		
						IF cTipoSol='T' THEN		

							SELECT dias_vigencia
							INTO sDias_Vig                                           
							FROM bdisolic:"informix".ss_oscalle_plazovigencia
							WHERE clave_producto = cNumProducto
							AND resp_oscalle = cStatusRespOs;
				
							LET vdiastrans = dFecha_Hoy - dFecha_Respuesta;
											
							IF vdiastrans <= sDias_Vig THEN
								IF cStatusRespOs = 'A' THEN 
									LET cStatusSolic = "AT"; 
								Else
									LET cStatusSolic = "RT"; 
								END IF;
					
								-- NO Genera OS
								IF(SELECT COUNT(*)  FROM BDISOLIC:ss_solicitud_os WHERE num_solicitud=cNumSolicitud AND secuenciaos=iSecuenciaOs)= 0 THEN 
									BEGIN;
									INSERT INTO bdisolic:"informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os)
									VALUES('001', cNumSolicitud, dFecha_Hoy, dFecha_Respuesta,cStatusRespOs, 'sistema', 'sistema', NULL, NULL, NULL, ' ', 0, NULL, NULL, iSecuenciaOs, 0);														
									COMMIT;
								END IF;
								LET cBand_clave = '1'; 
							END IF;

						ELIF cTipoSol='P'	THEN

							LET dFecha_Respuesta = NVL(dFecha_Respuesta,DATE(1));
							
							-- SE OBTIENE EL TOTAL DE DIAS DE VIGENCIA MAXIMO PARA UN CLIENTE EN ESE ESTATUS
							IF cStatusRespOs = 'D' THEN
								--SELECT dias_vigencia INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = cNumProducto  AND resp_oscalle = '';		
								SELECT MAX(dias_vigencia::SMALLINT) INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE resp_oscalle = '';		
							ELSE
								-- dias_vigencia INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = cNumProducto  AND resp_oscalle = cStatusRespOs;												
								SELECT MAX(dias_vigencia::SMALLINT) INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE resp_oscalle = cStatusRespOs;												
							END IF;							
				
							LET dFechaVencimiento = dFecha_Respuesta + sDias_Vig::INTEGER UNITS DAY; 
																	
							-- Se valida que la respuesta esta activa 	
							IF(dFecha_Hoy <= dFechaVencimiento) THEN
								IF(SELECT COUNT(*)  FROM BDISOLIC:ss_solicitud_os WHERE num_solicitud=cNumSolicitud AND secuenciaos=iSecuenciaOs)=0 THEN 
									BEGIN;
									INSERT INTO bdisolic:"informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os)
									VALUES('001', cNumSolicitud, dFecha_Hoy, dFecha_Respuesta,cStatusRespOs, 'sistema', 'sistema', NULL, NULL, NULL, ' ', 0, NULL, NULL, iSecuenciaOs, 0);							
									COMMIT;
								END IF;
								LET cBand_clave = '1'; 
								
								IF cStatusRespOs = 'A' THEN LET cStatusSolic = "AT"; END IF;
								IF cStatusRespOs = 'R' THEN LET cStatusSolic = "RT"; END IF;
								IF cStatusRespOs = 'D' THEN LET cStatusSolic = "OA"; END IF;
								IF cStatusRespOs = ' ' THEN LET cStatusSolic = "OS"; END IF;
								
								--LET iEnviarMC = 0; --hsrr
							END IF;	 
						END IF;
					END IF; 	
				END IF;
			END IF;	--Fin Herencia de los estatus de una OS existente y vigente del mismo Cliente
			
			IF cStatusSolic = 'AT' AND NVL(cStatusMovil,'') = '1' THEN	
				--para que cuando tenga completo el proceso lo deje en AT						
				LET cStatusSolic = 'PA';
				--OBTENER LA DESCRIPCION DEL STATUS DEL CATALOGO						
				SELECT descripcion INTO cMensaje FROM "informix".ss_status_sol WHERE status_solicitud = cStatusSolic;
				LET cBand_clave = '1';
			END IF;
			
			IF NVL(cClaveSup,'') <> '' AND cStatusSolic = 'EE' THEN							
				IF cClaveSup = 'A' THEN  LET cStatus_vig = "AT"; END IF;
				IF cClaveSup = 'R' THEN  LET cStatus_vig = "RT"; END IF;
				IF cClaveSup = 'D' THEN  LET cStatus_vig = "OA"; END IF;						
				
				-- SE OBTIENE EL TOTAL DE DIAS DE VIGENCIA MAXIMO PARA UN CLIENTE EN ESE ESTATUS
				IF cClaveSup = 'D' THEN
					--SELECT dias_vigencia INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = sNum_producto AND resp_oscalle = '';
					SELECT MAX(dias_vigencia::SMALLINT) INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE resp_oscalle = '';
				ELSE 
					--SELECT dias_vigencia INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = sNum_producto AND resp_oscalle = cClaveSup;	
					SELECT MAX(dias_vigencia::SMALLINT) INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE resp_oscalle = cClaveSup;	
				END IF;
				
				-- SI EL ESTATUS CUENTA CON DIAS DE VIGENCIA SE OBTENDRAN LOS DATOS PARA CANCELAR EL CLIENTE
				IF NVL(sDias_Vig,0) > 0 THEN
				
					-- SI LA FECHA ACTUAL ES MAYOR O IGUAL A LA FECHA DE ENTRADA A ESE ESTATUS MAS LOS DIAS DE VIGENCIA
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
					
					SELECT COUNT(num_solicitud) INTO iCont FROM "informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = cNumSolicitud;
					
					IF NVL(iCont,0) > 0 THEN
						LET iCont = 0;
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
		
			----------- Eliminacion de la OS para grupo 5 ITD
			IF v_hereda_status = 'AT' THEN
				IF cNumProducto = '6001' THEN --RQM 09 492
					--AAME INC 27 123 14052019 Debido a que la variable pNumSolicitud siempre se encuentra vacï¿½a se cambia por cNumSolicitud solo para el flujo del Demonio				  
					EXECUTE PROCEDURE "informix".sp_valida_comprobante(pEmpresa ,cNumcte, cNumSolicitud)
					INTO cCodRetComp,cMensajeRet,iValido;
					 
					IF cCodRetComp::INTEGER = 0 AND iValido = 1 THEN -- RQM 09 492
						LET cStatusPr = 'LC';
						LET cMensaje= 'RevisiÃ³n LÃ­nea de CrÃ©dito';
						--AAME INC 27 123 14052019 
						--INSERTA REGISTRO PARA LA BITACORA DE ESTATUS LC
						BEGIN;
						INSERT INTO "informix".ss_solicitudes_cac 
						(empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
						VALUES (pEmpresa, cNumSolicitud, cNumcte,csucursal, cNumProducto, cStatusPr, pEjecutivoAtiende, "", "", cMensaje, "S", v_valor, CURRENT,CURRENT, DATE(1), 'N');			 								
						COMMIT;
						LET cBand_clave = '1';
						LET cStatusSolic = cStatusPr;
                    ELSE
						LET cBand_clave = '1';
						LET cStatusSolic = v_hereda_status;	
                    END IF;	
				ELSE
					LET cBand_clave = '1';
					LET cStatusSolic = v_hereda_status;
				END IF;
			END IF;	

			IF cStatusSolic = 'AT' AND NVL(cStatusMovil,'') = '1' THEN	--387
				--para que cuando tenga completo el proceso lo deje en AT						
				LET cStatusSolic = 'PA';
			END IF;
			
			--OBTENER LA DESCRIPCION DEL STATUS DEL CATALOGO
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
				BEGIN;
				INSERT INTO "informix".ss_solicitud_os (empresa, num_solicitud, fecha_solicitud, fecha_respuesta,status,usuario_solicita, motivo_os,secuenciaos)
				VALUES (pEmpresa,cNumSolicitud, TODAY,dFecha_Ent ,cStatusPr, 'sistema',iMotivoOs, iSecuenciaOs);	
				COMMIT;
			END IF;
			
			--SE ACTUALIZA EL ESTATUS FINAL HEREDADO
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
		
		LET iPaso = 0; -- INICIALIZAMOS VARIABLE PARA CONTROL DE LA INFORMACION.
		
		FOREACH
			--RQM 09 459 Iniciativas de mesa de control (INICIO)
			SELECT a.num_solicitud, a.numcte, a.sucursal, fecha_insert,				   
            monto_solicitado, status_ini, observaciones, num_producto, status_fin, ejecutivo_atiende, 
            ejecutivo_autoriza, fecha_determinacion, revisado,hora_insert, 1 region, DECODE (NVL(b.numcte,0), 0, 0, 1) idbox,
			-- GEGB 20190211 RQM 09 501 {
			-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1 AND c.evalua_cc = '0' AND evaluacion >=0),0) + 
			NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc = '0' AND num_solicitud in (SELECT num_solicitud FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1  AND c.evalua_cc = '0' AND evaluacion < 0)),0) +
			NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc <> '0'),0) score,					
			a.prioridad
			-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			-- } GEGB 20190211 RQM 09 501
			INTO cNumSolicitud, cNumCte, cSucursal, dFechaInsert,  dcMontoSolic, cStatusIni, cObservaciones, 
			cNumProducto, cStatusFin, cEjecAtiende, cEjecAutoriza, dFechaDetermin, cRevisado,dtHoraInsert,
			cRegion,cIdBox, cScore, cPrioridad
			FROM bdisolic:"informix".ss_solicitudes_mc a 			 
			LEFT OUTER JOIN bdinteg:si_bitacora_ife b ON ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			LEFT OUTER JOIN bdisolic:ss_resum_scor_fin c ON (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud)
			WHERE a.empresa = pEmpresa
			AND status_ini = pStatus AND status_fin = ""
			AND a.sucursal IN 
			(SELECT sucursal
			 FROM bdinteg:si_sucursales a, bdinteg:si_catciudades b
			 WHERE a.ciudad = b.numerociudad 
			 AND tpo_sucursal = 'S'
			 AND numero_region IN('5','10','14','666','13'))
			UNION ALL
			SELECT a.num_solicitud, a.numcte, a.sucursal, fecha_insert,				   
			monto_solicitado, status_ini, observaciones, num_producto, status_fin, ejecutivo_atiende, 
			ejecutivo_autoriza, fecha_determinacion, revisado,hora_insert, 2, DECODE (NVL(b.numcte,0), 0, 0, 1) idbox,
			-- GEGB 20190211 RQM 09 501 {
			-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1 AND c.evalua_cc = '0' AND evaluacion >=0),0) + 
			NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc = '0' AND num_solicitud IN(SELECT num_solicitud FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1 AND c.evalua_cc = '0' AND evaluacion < 0)),0) + 
			NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc <> '0'),0) score,
			a.prioridad	
			-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            -- } GEGB 20190211 RQM 09 501
			-- INTO cNumSolicitud, cNumCte, cSucursal, dFechaInsert,  dcMontoSolic, cStatusIni, cObservaciones, 
			--	cNumProducto, cStatusFin, cEjecAtiende, cEjecAutoriza, dFechaDetermin, cRevisado,dtHoraInsert 
			FROM bdisolic:"informix".ss_solicitudes_mc a 			 
			LEFT OUTER JOIN bdinteg:si_bitacora_ife b ON ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			LEFT OUTER JOIN bdisolic:ss_resum_scor_fin c ON (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud)
			WHERE a.empresa = pEmpresa
			AND status_ini = pStatus AND status_fin = ""
			AND a.sucursal IN 
			(SELECT sucursal
			 FROM bdinteg:si_sucursales a, bdinteg:si_catciudades b
			 WHERE a.ciudad = b.numerociudad 
			 AND tpo_sucursal = 'S'
			 AND numero_region NOT IN('5','10','14','666','13'))
			ORDER BY 18 DESC, 17 ASC ,15 ASC ,16 ASC -- GEGB 20190211 RQM 09 501
		  	--RQM 09 459 Iniciativas de mesa de control (FIN)
		  
			/*SELECT distinct a.num_solicitud, a.numcte, a.sucursal, fecha_insert,				   
				   monto_solicitado, status_ini, observaciones, num_producto,  status_fin, ejecutivo_atiende, 
				   ejecutivo_autoriza,  fecha_determinacion, revisado,hora_insert , 1 region, (case when b.numcte is null then 0 else 1 end) idbox,
                   case when c.evalua_cc = '0'
                        then (select case when evaluacion < 0 then (select evaluacion from bdisolic:ss_resumen_scoring where a.empresa = empresa and a.num_solicitud = num_solicitud and seccion = 2) else evaluacion end from bdisolic:ss_resumen_scoring where a.empresa = empresa and a.num_solicitud = num_solicitud and seccion = 1)
                        else (select evaluacion from bdisolic:ss_resumen_scoring where a.empresa = empresa and a.num_solicitud = num_solicitud and seccion = 2) 
                        end score
			INTO cNumSolicitud, cNumCte, cSucursal, dFechaInsert,  dcMontoSolic, cStatusIni, cObservaciones, 
				 cNumProducto, cStatusFin, cEjecAtiende, cEjecAutoriza, dFechaDetermin, cRevisado,dtHoraInsert,
				 cRegion,cIdBox, cScore
			FROM "informix".ss_solicitudes_mc a 			 
                 left outer join bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte)   
                 left outer join bdisolic:ss_resum_scor_fin c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud)
          
			WHERE a.empresa = pEmpresa
			AND  status_ini = pStatus AND  status_fin = ""
            AND a.sucursal in 
            (select sucursal
            from bdinteg:si_sucursales a,
                 bdinteg:si_catciudades b
            where a.ciudad = b.numerociudad 
              and tpo_sucursal = 'S'
              and numero_region in ('5','10','14','666','13'))
   union all
			SELECT distinct a.num_solicitud, a.numcte, a.sucursal, fecha_insert,				   
				   monto_solicitado, status_ini, observaciones, num_producto,  status_fin, ejecutivo_atiende, 
				   ejecutivo_autoriza,  fecha_determinacion, revisado,hora_insert , 2, (case when b.numcte is null then 0 else 1 end) idbox,
                   case when c.evalua_cc = '0' 
                        then (select case when evaluacion < 0 then (select evaluacion from bdisolic:ss_resumen_scoring where a.empresa = empresa and a.num_solicitud = num_solicitud and seccion = 2) else evaluacion end from bdisolic:ss_resumen_scoring where a.empresa = empresa and a.num_solicitud = num_solicitud and seccion = 1)
                        else (select evaluacion from bdisolic:ss_resumen_scoring where a.empresa = empresa and a.num_solicitud = num_solicitud and seccion = 2) 
                   end score
			--INTO cNumSolicitud, cNumCte, cSucursal, dFechaInsert,  dcMontoSolic, cStatusIni, cObservaciones, 
			--	 cNumProducto, cStatusFin, cEjecAtiende, cEjecAutoriza, dFechaDetermin, cRevisado,dtHoraInsert 
			FROM "informix".ss_solicitudes_mc a 			 
                 left outer join bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte)   
                 left outer join bdisolic:ss_resum_scor_fin c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud)
          
			WHERE a.empresa = pEmpresa
			AND  status_ini = pStatus AND  status_fin = ""
            AND a.sucursal in 
            (select sucursal
            from bdinteg:si_sucursales a,
                 bdinteg:si_catciudades b
            where a.ciudad = b.numerociudad 
              and tpo_sucursal = 'S'
              and numero_region not in ('5','10','14','666','13'))                
              order by 15 asc ,16 asc ,17 asc/*
*/		
			/*
			SELECT  num_solicitud, numcte, sucursal, fecha_insert,				   
				   monto_solicitado, status_ini, observaciones, num_producto,  status_fin, ejecutivo_atiende, 
				   ejecutivo_autoriza,  fecha_determinacion, revisado,hora_insert
			INTO cNumSolicitud, cNumCte, cSucursal, dFechaInsert,  dcMontoSolic, cStatusIni, cObservaciones, 
				 cNumProducto, cStatusFin, cEjecAtiende, cEjecAutoriza, dFechaDetermin, cRevisado,dtHoraInsert 
			FROM "informix".ss_solicitudes_mc 			 
			WHERE empresa = pEmpresa
			AND  status_ini = pStatus AND  status_fin = ""
			ORDER BY tipo_alta ASC, num_producto ASC, hora_insert  ASC
			*/
/*			LET dFechaModif = dFechaDetermin;
			
			SELECT rfc,nombre1,nombre2,apell_paterno,apell_materno 
			INTO cRfc,cNombre1,cNombre2,cApellPat,cApellMat
			FROM bdinteg:"informix".si_cliente 
			WHERE empresa = '001' 
			AND numcte = cNumCte;
			
			LET cNombreCte = TRIM(cNombre1)||' '||TRIM(cNombre2)||' '||TRIM(cApellPat)||' '||TRIM(cApellMat); 
			
			-- SE OBTIENEN LOS DATOS DE LA INFORMACION CREDITICIA EN COPPEL/BANCOPPEL.
			SELECT situacion_pago, meses_historia 
			INTO dcEficiencia, sHistorial 
			FROM "informix".ss_resum_scor_fin 
			WHERE empresa = pEmpresa 
			AND num_solicitud = cNumSolicitud;
			
			-- SE OBTIENE LAS PUNTUACIONES DEL SCORING QUE SE LE REALIZO AL CLIENTE.
			SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1, 
				   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2
			INTO dcSeccion1, dcSeccion2 
			FROM "informix".ss_resumen_scoring 
			WHERE empresa = pEmpresa 
				AND num_solicitud = cNumSolicitud 
				AND seccion IN ('1','2');
			
			LET iPaso = 1; -- VARIABLE PARA CONTROL DE LA INFORMACION.
							
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
		SELECT numcte,monto_solicitado INTO cNumCteBco,v_valor FROM "informix".ss_solicitudes WHERE num_solicitud = pNumSolicitud;		
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
				
				IF NVL(pStatus, "") = "EE" THEN   */
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
					
/*					IF NVL(cNumProducto,"") = "6500" THEN
						
						SELECT COUNT(num_solicitud) INTO iCont FROM "informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = cNumSolicitud;
					
						IF NVL(iCont,0) > 0 THEN
							LET iCont = 0;
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
						
						IF cClaveSup = 'A' THEN  LET cStatus_vig = "AT"; END IF;
						IF cClaveSup = 'R' THEN  LET cStatus_vig = "RT"; END IF;
						IF cClaveSup = 'D' THEN  LET cStatus_vig = "OA"; END IF;											
							
						-- SE OBTIENE EL TOTAL DE DIAS DE VIGENCIA MAXIMO PARA UN CLIENTE EN ESE ESTATUS
						IF cClaveSup = 'D' THEN
							SELECT MAX(dias_vigencia::SMALLINT) INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE resp_oscalle = '';
						ELSE 
							SELECT MAX(dias_vigencia::SMALLINT) INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE resp_oscalle = cClaveSup;	
						END IF;
						
						-- SI EL ESTATUS CUANTA CON DIAS DE VIGENCIA SE OBTENDRAN LOS DATOS PARA CANCELAR EL CLIENTE
						IF NVL(sDias_Vig,0) > 0 THEN
							--SE OBTIENE LA FECHA EN QUE ENTRO EN ESE ESTATUS EL CLIENTE Y EL EJECUTIVO QUE REALIZO EL REGISTRO
							SELECT fecha_entrada INTO dFecha_Ent FROM "informix".ss_autorizacion
							WHERE num_solicitud = cNumSolicitud AND status_solicitud = cStatus_vig
							AND fecha_entrada =	(SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion WHERE num_solicitud = cNumSolicitud AND status_solicitud = cStatus_vig);

							-- SI LA FECHA ACTUAL ES MAYOR O IGUAL A LA FECHA DE ENTRADA A ESE ESTATUS MAS LOS DIAS DE VIGENCIA
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
						
							SELECT COUNT(num_solicitud) INTO iCont FROM "informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = cNumSolicitud;
							
							IF NVL(iCont,0) > 0 THEN
								LET iCont = 0;
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
					
					----------- Eliminacion de la OS para grupo 5 ITD
					IF v_hereda_status = "AT" THEN
						IF cNumProducto = '6001' THEN --RQM 09 492
							  
							EXECUTE PROCEDURE "informix".sp_valida_comprobante(pEmpresa ,cNumcte, pNumSolicitud)
							INTO cCodRetComp,cMensajeRet,iValido;
							 
							IF cCodRetComp::INTEGER = 0 AND iValido = 1 THEN -- RQM 09 492
								LET cStatusPr = 'LC';
								LET cMensaje= 'RevisiÃ³n LÃ­nea de CrÃ©dito';

								--INSERTA REGISTRO PARA LA BITACORA DE ESTATUS LC
								BEGIN;
								INSERT INTO "informix".ss_solicitudes_cac 
								(empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
								VALUES (pEmpresa, pNumSolicitud, cNumcte,csucursal, cNumProducto, cStatusPr, pEjecutivoAtiende, "", "S", cMensaje, "S", v_valor, CURRENT,CURRENT, DATE(1), "S");			 								
								COMMIT;
								LET cBand_clave = '1';
								LET cStatusSolic = cStatusPr;
					        ELSE	
						        LET cBand_clave = '1';
								LET cStatusSolic = v_hereda_status;	
                            END IF;	
						ELSE	
								LET cBand_clave = '1';
								LET cStatusSolic = v_hereda_status;
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
						BEGIN;
						INSERT INTO "informix".ss_solicitud_os (empresa, num_solicitud, fecha_solicitud, fecha_respuesta,status,usuario_solicita, motivo_os,secuenciaos)
						VALUES (pEmpresa,cNumSolicitud, TODAY,dFecha_Ent ,cStatusPr, 'sistema',iMotivoOs, iSecuenciaOs);	
						COMMIT;
					END IF;
					
				END IF;
			END IF;
		END IF;*/
		RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cRfc,''), NVL(cSucursal,''), NVL(dFechaInsert,DATE(1)), 
			   NVL(dFechaModif,DATE(1)), NVL(dcMontoSolic,0.00), NVL(dcEficiencia,0.00), NVL(sHistorial,0), NVL(cStatusIni,''), NVL(dcSeccion1, 0.00), 
			   NVL(dcSeccion2, 0.00), NVL(cCausaSolic,''), NVL(cObservaciones,''), NVL(cNumProducto,''), NVL(cStatusFin,''), NVL(cEjecAtiende,''), 
			   NVL(cEjecAutoriza,''), NVL(dtHoraInsert, ""), NVL(dFechaDetermin, DATE(1)), NVL(cRevisado,'');
		
	--END IF;	
END
END PROCEDURE
