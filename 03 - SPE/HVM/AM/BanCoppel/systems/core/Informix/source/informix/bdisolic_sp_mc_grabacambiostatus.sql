CREATE PROCEDURE "informix".sp_mc_grabacambiostatus( pEmpresa CHAR (3),
													  pNumSol CHAR (20),
													  pNumSol2 CHAR (20),
													  pNumcte CHAR (20),
													  pEjecutivo_ana CHAR (10),	
													  pEjecutivo_aut CHAR (10),																
													  pStatusIni CHAR (2),
													  pStatusFin CHAR (2),
													  pMontoAnt DECIMAL(18,2),
													  pMontoNvo DECIMAL(18,2),
													  pCausa CHAR (3),
													  pComentario CHAR(500),
													  pTipoMovto  CHAR(1),
													  pTipoBusqueda CHAR(1),
													  pBanderaMotor CHAR(1)
													)
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION,
	CHAR(1) AS BANDERAMOTORMC; 

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(6);
DEFINE cCodRet2			CHAR(5);
DEFINE cMensajeRet		CHAR(80);
DEFINE cNombreejecutivo CHAR(100);
DEFINE iContinua INTEGER;
DEFINE iContador INTEGER;
DEFINE iMotivoOs INTEGER;
DEFINE cCoppel CHAR(1);
DEFINE cSitEsp CHAR(1);
DEFINE iCausaSitEsp INTEGER;
DEFINE iOstel INTEGER;
DEFINE cComentario CHAR(500);
DEFINE cRevalua CHAR(1);
DEFINE cStatusMovil CHAR(1);
DEFINE cValor_alfabetico CHAR(100);
---DEFINE cNumCteBco			CHAR(20);
DEFINE cCteProsp   			CHAR(20);
DEFINE cStatusSolic			CHAR(2);
DEFINE cDesStatusCtePros	CHAR(40);
DEFINE cClientePros			CHAR(1);
DEFINE dFecha_Respuesta		DATE;
DEFINE cStatusRespOs		CHAR(1);
DEFINE cDiaVigencia  		CHAR(2);
DEFINE cStatusPr			CHAR(2);
DEFINE iSecuenciaOs         INTEGER;
DEFINE cNuevoStatus         CHAR(2);
DEFINE cMensajeStatus       CHAR(80);
DEFINE cDescripcion	        CHAR(40);
DEFINE cClave				CHAR(1);	
DEFINE cStatusOS2			CHAR(1);	
DEFINE cMot					INTEGER;
DEFINE iPaso				INTEGER;

DEFINE cClaveSup			CHAR(1);
DEFINE cBand_clave			CHAR(1);
DEFINE cStatus_vig			CHAR(2);
DEFINE dFecha_Ent			DATE;
DEFINE dFecha_Hoy			DATE;
DEFINE sDias_Vig			SMALLINT;
DEFINE cVigenciaVencida		INTEGER;
DEFINE cFLagGeoMov         CHAR(1);
DEFINE cFolioMovil         CHAR(20);

----- Reevaluacion
DEFINE sNum_producto           	CHAR(4);
DEFINE pStatusActual			CHAR(2);
DEFINE v_hereda_status			CHAR(2);
DEFINE 	v_sucursal         		CHAR(4);
DEFINE v_SituacionPagoCoppel  DECIMAL(5,2);
DEFINE v_meses                SMALLINT;
DEFINE  vsituacion_especial    	CHAR(1); 
DEFINE	vcausa_situacion		SMALLINT;
DEFINE 	o_vencidoropa    INTEGER;
DEFINE 	o_vencidomuebles INTEGER;
DEFINE 	o_vencidoprestamos INTEGER;
DEFINE 	o_abonoropa      INTEGER;
DEFINE 	o_saldomuebles   INTEGER;
DEFINE 	o_saldoropa      INTEGER;
DEFINE 	o_saldoprestamos INTEGER;
DEFINE 	o_ultimacompra   DATE;
DEFINE 	o_abonomuebles	 INTEGER;
DEFINE 	o_abonoprestamos INTEGER;
DEFINE	vlNombre				CHAR(104);	
DEFINE	vlClienteRef			CHAR(20);
DEFINE cCodRetRe			CHAR(6);
DEFINE p_cod_ret		CHAR(6);
DEFINE Flag_RT			INTEGER;

DEFINE cGeoCte CHAR (20);
DEFINE cTipoSol CHAR(1);
DEFINE cFechaHora DATE;
DEFINE vdiastrans INTEGER;
DEFINE dFechaVencimiento DATE;
DEFINE cNumSolOs CHAR(20);
--DEFINE iEnviarMC --hsrr
--DEFINE VNuevoStatus           CHAR(2);
DEFINE cCteProspVig			CHAR(20);
--- RQM 09492
DEFINE iValido                  INTEGER;
DEFINE v_valor                  DECIMAL(14,2);
DEFINE cCodRetComp		CHAR(5);
DEFINE valida_os		INTEGER;
DEFINE val_solautdirecta	INTEGER;
DEFINE isolcomp			INTEGER; -- RQM 10 1432
DEFINE cejecutivoAut    CHAR(10); -- INC 27 195
DEFINE sNumprod  CHAR(4); -- INC 27 195
DEFINE cBanderaMotorMC CHAR(1);
--RQM 09 632
DEFINE v_tope_ingre             DECIMAL(14,6);
DEFINE cCodRetDeter CHAR(5);
DEFINE cLineaDeter MONEY(14,2);
DEFINE cCapPagoDeter MONEY(14,2);
DEFINE cPlazoDeter INTEGER;
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cCodRet2			= '00000';
LET cMensajeRet			= 'Proceso Exitoso';
LET cNombreejecutivo    = '';
LET iContinua    = 0;
LET iContador    = 0;
LET iMotivoOs    = 0;
LET cCoppel    = "";
LET cSitEsp    = "";
LET iCausaSitEsp    = 0;
LET iOstel    = 0;
LET cComentario    = "";
LET cRevalua    = "";
LET cStatusMovil    = "";
LET cValor_alfabetico = "";
---LET cNumCteBco  		= "";
LET cCteProsp  			= "";
LET cStatusSolic  		= "";
LET cDesStatusCtePros 	= "";
LET cClientePros 		= "";
LET dFecha_Respuesta 	= DATE(1);
LET cStatusRespOs 		= "";
LET cDiaVigencia 		= "00";
LET cStatusPr 			= "";
LET iSecuenciaOs   		= 0;
LET cNuevoStatus   		= "";
LET cMensajeStatus 		= "";
LET cDescripcion 		= "";
LET cClave				="";
LET cStatusOS2			="S";
LET cMot				=0;
LET iPaso				= 0;

LET cClaveSup			='';
LET cBand_clave			='';
LET cStatus_vig			= '';
LET dFecha_Hoy			= DATE(1);
LET dFecha_Ent			= DATE(1);
LET sDias_Vig			= 0;
LET cVigenciaVencida	= 0;
LET cFLagGeoMov ='';
LET cFolioMovil ='';
----- Reevaluacion

LET sNum_producto = '';
LET pStatusActual = '';
LET v_hereda_status = '';
LET v_sucursal= "";
LET v_SituacionPagoCoppel = 0;
LET v_meses               = 0;
LET vsituacion_especial = '';
LET o_vencidomuebles =0;
LET o_vencidoropa    =0;
LET o_vencidoprestamos =0;
LET o_abonomuebles	 =0;
LET o_abonoprestamos =0;
LET o_abonoropa      =0;
LET o_saldomuebles   =0;
LET o_saldoropa      =0;
LET o_saldoprestamos =0;
LET o_ultimacompra   = date(1);
LET vcausa_situacion = 0;
LET vlNombre= '';
LET vlClienteRef ='';
LET cCodRetRe = '000000';
LET p_cod_ret = '000000'; 
LET Flag_RT = 0;
--RQM 09 492
LET v_valor             = 0;
LET iValido             = 0;
LET cCodRetComp     = '00000';
LET cGeoCte	= '';
LET cTipoSol = '';
LET cFechaHora = DATE(1);
LET vdiastrans = 0;
LET dFechaVencimiento = DATE(1);
LET cNumSolOs = '';
--LET iEnviarMC --hsrr
--LET VNuevoStatus = '';
LET cCteProspVig	= "";
LET valida_os = 0;
LET val_solautdirecta = 0;
LET isolcomp = 0;		-- RQM 10 1432
LET cejecutivoAut = '';
LET sNumprod ='';
LET cBanderaMotorMC = '0';
-- RQM 09 632
LET cCodRetDeter = "0";
LET cLineaDeter = 0;
LET cCapPagoDeter = 0;
LET cPlazoDeter = 0;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet, cBanderaMotorMC;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
 	--SET DEBUG FILE TO "/home/sysifx/LeonardoFigueroa/Motor/Mesacontrol/sp_mc_grabacambiostatus"||pNumSol||".out";
	--TRACE ON;
	
	IF  NVL(pEmpresa,"") = "" AND NVL(pNumSol,"") = "" OR  NVL(pStatusIni,"") = "AP" THEN
	  LET cCodRet = "000001";
	  LET cMensajeRet = "PARAMETROS DE ENTRADA INVALIDOS.";
	  
	ELSE
	
		SELECT fecha_hoy INTO dFecha_Hoy FROM bdinteg: "informix".si_fechas;	
	
		SELECT num_producto,sucursal,status_solicitud,monto_solicitado
		INTO sNum_producto,v_sucursal,pStatusActual,v_valor
		FROM "informix".ss_solicitudes 	
			WHERE empresa = pEmpresa AND num_solicitud  = pNumSol;
			
		LET sNumprod = sNum_producto;

		IF pBanderaMotor = '1' THEN
			LET pStatusActual = pStatusIni;
		END IF;

		IF pStatusActual = pStatusIni  THEN	-- hsrr si los dos estatus coinciden
			
			SELECT nombre INTO cNombreejecutivo 
			FROM bdinteg:si_ejecut 
			WHERE ejecutivo= pEjecutivo_aut 
			AND empresa = pEmpresa;   
				
			IF pStatusFin = "AT" Then       
				LET pComentario = "Autorizada por MC " || TRIM(NVL(cNombreejecutivo,'')) || " " || pComentario;
			ELIF pStatusFin = "RT" Then                       
				LET pComentario = "Rechazada por MC " || TRIM(NVL(cNombreejecutivo,'')) || " " || pComentario;
			ELIF  pStatusFin = "OS" Then                  
				LET pComentario = "Enviada a orden de supervision por MC " ||TRIM(NVL(cNombreejecutivo,''))|| " " || pComentario;
			ELIF  pStatusFin = "EE" AND  pStatusIni ="MC" THEN
				LET pComentario = "Revisada en MC por " ||TRIM(NVL(cNombreejecutivo,''))|| " " || pComentario;
			ELSE
				LET pComentario = "Cambio por MC " ||TRIM(NVL(cNombreejecutivo,''))|| " " || pComentario;
			END IF	
			
			SELECT ostel,revalua,status_hereda 
			INTO iOstel,cRevalua,v_hereda_status
			FROM  "informix".ss_solicitudes_mc 
			WHERE empresa = pEmpresa 
			AND num_solicitud = pNumSol;

			IF pBanderaMotor = '1' THEN
			
				--SE CONSULTA EL ESTATUS AL QUE CAMBIO LA SOLICITUD			
				SELECT status_solicitud 
				INTO pStatusFin 
				FROM "informix".ss_solicitudes 
				WHERE empresa = pEmpresa AND num_solicitud  = pNumSol;			
			
				-- ACTUALIZAMOS LA RESPUESTA DEL ANALISTA QUE ATENDIO LA SOLICITUD.			
				UPDATE "informix".ss_solicitudes_mc 
				SET status_fin = pStatusFin, 
				ejecutivo_autoriza = pEjecutivo_ana,
				ejecutivo_atiende = pEjecutivo_ana,
				observaciones = pComentario, 
				fecha_determinacion = TODAY,
				revisado = "S",
				tipo_movimiento = pTipoMovto
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol
				AND status_ini = "MC"
				AND status_fin = "";				
				
				-- ACTUALIZAMOS LA SOLICITUD 
				SELECT MAX(secuencia+1) INTO iSecuencia FROM "informix".ss_autorizacion_especial 
				WHERE empresa=pEmpresa 
				AND num_solicitud=pNumSol;	
					
				INSERT INTO "informix".ss_autorizacion_especial
				(empresa,num_solicitud,numcte,secuencia,comentario,causa_solicitud,montolinea_ant,montolinea_nvo,status_ant,status_nvo,usuario_modif,fecha_modif,tipo_movimiento ) 
				VALUES(pEmpresa,pNumSol,pNumcte,NVL(iSecuencia,1),pComentario,pCausa,pMontoAnt,pMontoNvo,pStatusIni,pStatusFin,pEjecutivo_aut,today,pTipoMovto);
				
				LET cBanderaMotorMC = '0';
				RETURN cCodRet, cMensajeRet, cBanderaMotorMC;
			END IF;
						  
			IF  (iOstel = "1" OR cRevalua = "S" ) AND pStatusIni = "MC" AND pStatusFin = "EE" THEN 	--si falta la OS Telefonica manda llamar el proceso de califica_scoring2_cjunk
			
				
					-- Extrae Valores del Cliente, para armar nueva consulta de reevaluacion Tienda

				SELECT situacion_pago,     meses_historia,
					situacion_credito,   causa,   vencidoropa, 	 vencidomuebles,    
					vencidoprestamos,      abonomensualropa,  abonomensualmuebles,   
					abonomensualprestamos, saldoropa,         saldomuebles,saldoprestamos, 
					fecha_ultima_compra
				INTO v_SituacionPagoCoppel,v_meses,  
					vsituacion_especial, vcausa_situacion, o_vencidoropa,o_vencidomuebles,
					o_vencidoprestamos , o_abonoropa ,	o_abonomuebles,
					o_abonoprestamos ,   o_saldoropa ,		o_saldomuebles ,o_saldoprestamos ,
					o_ultimacompra
				FROM "informix".ss_resum_scor_fin WHERE empresa=pEmpresa AND num_solicitud=pNumSol;	  
			
				select numcte_ref, trim(nombre1) ||' ' || trim(nombre2) ||' ' || trim(apell_paterno) ||' ' || trim(apell_materno) 
					into vlClienteRef, vlNombre
				from bdinteg:si_cliente 
				where numcte = pNumCte;
			
    			-----  Reevaluacion Tienda
	
				CALL "informix".situacion_pago_tienda_cjunk(pEmpresa, pNumCte,sNum_producto,v_sucursal,
					user, decode(v_SituacionPagoCoppel,0,-1,v_SituacionPagoCoppel) ,vsituacion_especial,vcausa_situacion,vlClienteRef,vlNombre,vlNombre,
					v_meses,o_vencidomuebles ,o_vencidoropa    ,o_vencidoprestamos ,o_abonomuebles	 ,
					o_abonoropa ,o_abonoprestamos ,o_saldomuebles ,o_saldoropa ,o_saldoprestamos ,o_ultimacompra   )
					RETURNING cCodRetRe, cMensajeRet;		  
					IF cCodRetRe <> '000' THEN 
				
						LET cMensajeRet='Rechazado por estar fuera de politicas';	
						LET cCodRetRe= '00008'; -- Rechazado por estar fuera de politicas
						EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'SISTEMA',pNumSol, 'RT','RDO', cMensajeRet) INTO p_cod_ret;
						LET Flag_RT = 1;
					END IF;
				--------------------------------------------
				--JMAH 
				IF Flag_RT = 0 then
					
					DELETE FROM "informix".ss_detalle_scoring WHERE empresa = pEmpresa AND num_solicitud = pNumSol and grupo =25;
					
					IF EXISTS(SELECT numproducto from bdicred:sd_productos_motor WHERE numproducto=sNum_producto) THEN
					LET cBanderaMotorMC = '1';
					LET cMensajeRet = 'Solicitud enviada a motor';
						RETURN cCodRet, cMensajeRet, cBanderaMotorMC;
					ELSE
						EXECUTE PROCEDURE "informix".califica_scoring2_cjunk 
						(pEmpresa , pNumSol ) INTO cCodRet2;	
					END IF;
				END IF;
			
				--SE CONSULTA EL ESTATUS AL QUE CAMBIO LA SOLICITUD			
				SELECT status_solicitud 
				INTO pStatusFin 
				FROM "informix".ss_solicitudes 
				WHERE empresa = pEmpresa AND num_solicitud  = pNumSol;			
			
			 -- ACTUALIZAMOS LA RESPUESTA DEL ANALISTA QUE ATENDIO LA SOLICITUD.			
				UPDATE "informix".ss_solicitudes_mc 
				SET status_fin = pStatusFin, 
				ejecutivo_autoriza = pEjecutivo_ana,
				ejecutivo_atiende = pEjecutivo_ana,
				observaciones = pComentario, 
				fecha_determinacion = TODAY,
				revisado = "S",
				tipo_movimiento = pTipoMovto
				WHERE empresa = pEmpresa
				AND num_solicitud = pNumSol
				AND status_ini = "MC"
				AND status_fin = "";				
				
				-- ACTUALIZAMOS LA SOLICITUD 
				SELECT MAX(secuencia+1) INTO iSecuencia FROM "informix".ss_autorizacion_especial 
				WHERE empresa=pEmpresa 
				AND num_solicitud=pNumSol;	
					
				INSERT INTO "informix".ss_autorizacion_especial
				(empresa,num_solicitud,numcte,secuencia,comentario,causa_solicitud,montolinea_ant,montolinea_nvo,status_ant,status_nvo,usuario_modif,fecha_modif,tipo_movimiento ) 
				VALUES(pEmpresa,pNumSol,pNumcte,NVL(iSecuencia,1),pComentario,pCausa,pMontoAnt,pMontoNvo,pStatusIni,pStatusFin,pEjecutivo_aut,today,pTipoMovto);
		ELSE		
				SELECT status, folio_movil
				INTO   cStatusMovil,cFolioMovil
				FROM "informix".ss_solicitudes_movil							
				WHERE 	empresa  = pEmpresa 
				AND  num_solicitud = pNumSol
				AND status <> '3';
		
	---JMAH Geolocalizacion
				/*IF NVL(cFolioMovil,'') <> '' THEN      
					SELECT domicilio_alta INTO cFLagGeoMov  FROM bdinteg:"informix".si_solicitud_movil where folio = cFolioMovil;   
				ELSE
					LET cFLagGeoMov ='N';
				END IF;
				*/
				--Inicia Geolocalizacion
				IF NVL(cFolioMovil,'') <> '' AND NVL(sNum_producto,'') = '6001' THEN      --hsrr 387
					
					SELECT domicilio_alta,geolocalizacion INTO cFLagGeoMov,cGeoCte  FROM bdinteg:"informix".si_solicitud_movil where folio = cFolioMovil;   

					IF cFLagGeoMov = 'S' THEN
						LET cFLagGeoMov = 'N';	--Se concidera domicilio no geolocalizado hasta que se demuestre lo contrario.
						LET iMotivoOs = 17;
						IF LEN(NVL(TRIM(cGeoCte),'')) > 10 THEN		--Si la variable cGeoCte el len es menos de 10 quiere decir que son coordenadas basura					
							IF (NOT EXISTS (SELECT * FROM bdinteg:"informix".si_ptf 
											WHERE TRIM(latitud)||","||TRIM(longitud) = TRIM(cGeoCte))) THEN --Domocilio Geolocalizado diferente al de sucursal
								LET cFLagGeoMov = 'S';
								LET iMotivoOs = 0;
							END IF;
						END IF;
					END IF;			
				END IF;
				--Fin Geolocalizacion
				IF  pTipoBusqueda = "1" THEN					  
					IF pStatusIni = "MC" THEN
						SELECT count (*) INTO val_solautdirecta FROM  "informix".ss_os_solautdirecta WHERE empresa = pEmpresa  AND num_solicitud = pNumSol;

						
						IF val_solautdirecta > 0 THEN
							LET iMotivoOs = 0;
						ELSE
							SELECT motivo_os 
							INTO iMotivoOs 
							FROM  "informix".ss_solicitudes_mc 
							WHERE empresa = pEmpresa 
							AND num_solicitud = pNumSol;				 
						END IF;
					ELSE 
						LET iMotivoOs = 1;
					END IF; 
--					IF pStatusFin = "EE" AND iMotivoOs = 0 THEN			  
					IF pStatusFin = "EE" AND (iMotivoOs = 0 OR cFLagGeoMov ='S') THEN			  	  
						LET pStatusFin = "AT";					    
						LET pComentario = "Solicitud Autorizada";
					END IF;				 
					IF NVL(cStatusMovil,'') = '1' AND pStatusFin = "AT" THEN
						LET pStatusFin = 'PA';
						LET pComentario= 'Solicitud Pre-Autorizada';					 
					END IF
					 
					-- ACTUALIZAMOS LA RESPUESTA DEL ANALISTA QUE ATENDIO LA SOLICITUD.			
					UPDATE "informix".ss_solicitudes_mc 
					SET status_fin = pStatusFin, 
					ejecutivo_autoriza = pEjecutivo_ana, 
					ejecutivo_atiende = pEjecutivo_ana,
					observaciones = pComentario, 
					fecha_determinacion = TODAY, 
					revisado = "S", 
					tipo_movimiento = pTipoMovto
					WHERE empresa = pEmpresa 
					AND num_solicitud = pNumSol 
					AND status_ini = "MC" 
					AND status_fin = "";					  
				END IF;				
					  
				IF SUBSTR(pNumSol,1,2) ='65' THEN 
					LET cCoppel = "C";					
					SELECT  situacion_especial, causa_situacion 
					INTO cSitEsp,iCausaSitEsp 
					FROM "informix".ss_causas_sol
					WHERE status_solicitud = pStatusFin 
					AND causa_solicitud = pCausa;
					
					UPDATE "informix".ss_resum_scor_fin 
					SET  situacion_especial = cSitEsp, 
					causa_situacion = iCausaSitEsp
					WHERE empresa = pEmpresa 
					AND num_solicitud  = pNumSol ; 
				END IF;	
				
				-- ACTUALIZAMOS LA SOLICITUD 
				SELECT MAX(secuencia+1) INTO iSecuencia FROM "informix".ss_autorizacion_especial 
				WHERE empresa=pEmpresa 
				AND num_solicitud=pNumSol;	
					
				INSERT INTO "informix".ss_autorizacion_especial
				(empresa,num_solicitud,numcte,secuencia,comentario,causa_solicitud,montolinea_ant,montolinea_nvo,status_ant,status_nvo,usuario_modif,fecha_modif,tipo_movimiento ) 
				VALUES(pEmpresa,pNumSol,pNumcte,NVL(iSecuencia,1),pComentario,pCausa,pMontoAnt,pMontoNvo,pStatusIni,pStatusFin,pEjecutivo_aut,today,pTipoMovto);

				SELECT motivo_os 
				INTO  iMotivoOs 
				FROM  "informix".ss_solicitudes_mc 
				WHERE empresa = pEmpresa 
				AND num_solicitud = pNumSol;	
				
					IF ( pStatusFin = "EE" AND iMotivoOs = 14 ) THEN
						SELECT valor_alfabetico 
						INTO cValor_alfabetico 
						FROM  "informix".ss_param_solicitudes 
						WHERE empresa = pEmpresa 
						AND secuencia = 14 
						AND grupo_parametro = 'MOTIVOS_OS' 
						AND num_parametro = 14;			
						
						LET pComentario = cValor_alfabetico;
					END IF;
				--Se agrga motivo 17 para cuando la solicitud es movil, bancoppel y no esta geolocalizada.
				/*IF NVL(cFolioMovil,'') <> '' AND NVL(sNum_producto,'') = '6001' THEN
					IF cFLagGeoMov = 'N' THEN
						LET iMotivoOs = 17;
					END IF;
				END IF;*/
			
				UPDATE "informix".ss_autorizacion 
				SET revision_cac = 2
				WHERE empresa = pEmpresa AND ejecutivo_auto =pEjecutivo_ana
				AND num_solicitud  = pNumSol  AND status_solicitud = pStatusFin
				AND fecha_entrada = (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion as aut2 
															 WHERE aut2.num_solicitud  = pNumSol
															 AND status_solicitud = pStatusFin);
				
				UPDATE "informix".ss_solicitudes 
				SET monto_solicitado = CASE WHEN pMontoNvo > 0 THEN pMontoNvo ELSE monto_solicitado END
				WHERE empresa = pEmpresa
				AND num_solicitud  = pNumSol ;					
				
				------------------------------------------------------------------------------------------
				--OBTENER EL CLIENTE BANCO PARA IR A BUSCARLO EN LA PR_CLIENTE PARA DETERMINAR SI TUVO COMO ORIGEN CLIENTE PROSPECTO.
				---SELECT numcte INTO cNumCteBco FROM "informix".ss_solicitudes WHERE num_solicitud = pNumSol;		
				--SE CONSULTA SI EXISTE EL CLIENTE PROSPECTO.
				SELECT numcte_pros,status_numcte_pros INTO cCteProsp,cStatusSolic FROM bdiprospectos:"informix".pr_cliente WHERE empresa = pEmpresa AND numcte = pNumcte AND tipo_cliente = 3 AND status_numcte_pros NOT IN ('AN','CN','PC','CP');
				--Obtiene la descripcion del estatus de cliente prospecto
				--SELECT descripcion INTO cDesStatusCtePros FROM bdiprospectos:"informix".pr_status_sol WHERE status_solicitud = cStatusSolic;	
				--SE VALIDA QUE EL CLIENTE PROSPECTO ESTE AUTORIZADO PARA ASI PODER AUTORIZAR EL PRODUCTO 6500.
				--IF NVL(cCteProsp,'') <> ''  THEN SELECT cliente_pros INTO cClientePros FROM bdinteg:"informix".si_cliente WHERE numcte = cNumCteBco; IF NVL(cClientePros,'') = '1' THEN LET sBanAuto = 1; END IF; END IF;
					------------------------------------------------------------------------------------------
				IF (SELECT COUNT(numcte) FROM "informix".ss_solicitudes WHERE numcte = pNumcte AND num_solicitud <> pNumSol  AND  tipo_solicitud = "C") > 0 THEN 
					LET cCteProsp = NULL;
					LET cStatusSolic = NULL;
					LET iMotivoOs = 15;
				END IF;
				
				--APR SE CONSULTA EL CLIENTE PROSPECTO SI ES QUE EXISTE.
				IF NVL(cCteProsp,'') = '' AND iMotivoOs = 15 THEN
					SELECT numcte_pros INTO cCteProspVig
					FROM bdiprospectos:"informix".pr_cliente 
					WHERE empresa = pEmpresa AND numcte = pNumcte AND tipo_cliente = 3;
				ELSE
					LET cCteProspVig = cCteProsp;
				END IF;
				IF pStatusFin = "EE" AND NVL(cCteProsp,'') <> '' AND NVL(cStatusSolic,'') <> '' THEN	-- hsrr Es prospecto
		
					--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR.
					
						SELECT secuencia,clave,fecharespuesta INTO iSecuenciaOs,cClaveSup,dFecha_Ent
						FROM bdisolic:"informix".ss_osclientesupervisar
						WHERE empresa  = pEmpresa AND num_solicitud  = cCteProsp
						AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp);

					IF (SELECT COUNT (num_solicitud) FROM ss_osclientesupervisar  WHERE num_solicitud = cCteProsp)  > 0	THEN								
					
						--SE OBTIENE LA FECHA DE EL DIA
						--SELECT fecha_hoy INTO dFecha_Hoy FROM bdinteg: "informix".si_fechas;
						
						IF cClaveSup = 'A' THEN LET cStatus_vig = "AT"; END IF;
						IF cClaveSup = 'R' THEN LET cStatus_vig = "RT"; END IF;
						IF cClaveSup = 'D' THEN LET cStatus_vig = "OA"; END IF;
						IF cClaveSup = ' ' THEN LET cStatus_vig = "OS"; END IF;
						
							-- SE OBTIENE EL TOTAL DE DIAS DE VIGENCIA MAXIMO PARA UN CLIENTE EN ESE ESTATUS
							IF cClaveSup = 'D' THEN
								--SELECT dias_vigencia INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = sNum_producto AND resp_oscalle = '';
								SELECT MAX(dias_vigencia::SMALLINT) INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE resp_oscalle = '';
							ELSE 
								--SELECT dias_vigencia INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = sNum_producto AND resp_oscalle = cClaveSup;	
								SELECT MAX(dias_vigencia::SMALLINT) INTO sDias_Vig FROM "informix".ss_oscalle_plazovigencia WHERE resp_oscalle = cClaveSup;	
							END IF;
							-- SI EL ESTATUS CUANTA CON DIAS DE VIGENCIA SE OBTENDRAN LOS DATOS PARA CANCELAR EL CLIENTE
							--IF NVL(sDias_Vig,0) > 0 THEN
								-- SI LA FECHA ACTUAL ES MAYOR O IGUAL A LA FECHA DE ENTRADA A ESE ESTATUS MAS LOS DIAS DE VIGENCIA
								IF dFecha_Hoy > (dFecha_Ent + sDias_Vig::INTEGER UNITS DAY)  THEN
									--- LET dfecha_ent = DATE(1);
									LET cVigenciaVencida = 1;
									IF cVigenciaVencida = 1 THEN ---NVL(cStatusSolic,'') = '' OR   NVL(cStatusSolic,'') = 'CN'  
										LET cStatusSolic = 'EE';
										LET cStatusPr = "S"; 
										LET iSecuenciaOs = 0;
									END IF;
									-- EL NUMCTE SE DEVE DE ENCONTRAR UNA SOLA VEZ EN LA TABLA  SS_SOLICITUDES CON TIPO DE SOLICITUD = "C"
									--IF (SELECT COUNT(numcte)FROM "informix".ss_solicitudes WHERE numcte = cNumCteBco AND tipo_solicitud = "C") = 1 THEN	
									--	LET iMotivoOs = 15;
									--END IF;
								ELSE 
									LET cStatusSolic = cStatus_vig;										
								END IF;
							--END IF;							 
					END IF;		
					
					SELECT descripcion INTO cDesStatusCtePros FROM bdiprospectos:"informix".pr_status_sol WHERE status_solicitud = cStatusSolic;
					LET cMensajeStatus = cDesStatusCtePros;
					LET cStatusPr = "P";
							
					IF cStatusSolic = "AT" THEN 
						LET cStatusPr = "A";
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
							--LET iSecuenciaOs = 0;
					ELIF cStatusSolic = "RT" THEN LET cStatusPr = "R";  
					ELIF cStatusSolic = "OA" THEN LET cStatusPr = "D"; 
					END IF;
			
					--OBTENER LA DESCRIPCION DEL STATUS DEL CATALOGO DEL TITULAR.						
					SELECT descripcion INTO pComentario FROM "informix".ss_status_sol WHERE status_solicitud = cStatusSolic;
					
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (pEmpresa, pEjecutivo_ana, pNumSol, cStatusSolic, pCausa, pComentario) INTO cCodRet;
					
					-- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD.
					IF cCodRet <> '000000' THEN 
						LET cCodRet = '00002'; 
					END IF;
					
					--IF NVL(dFecha_Ent,DATE(1)) = DATE(1) THEN
						--LET dFecha_Ent = dFecha_Hoy;
					--END IF;

					SELECT count (*) INTO valida_os
					 FROM "informix".ss_solicitud_os 	
					 WHERE empresa = pEmpresa AND num_solicitud  = pNumSol AND fecha_solicitud = today;
					
					IF valida_os = 0 THEN				
						INSERT INTO "informix".ss_solicitud_os (empresa, num_solicitud, fecha_solicitud,fecha_respuesta, status,usuario_solicita,usuario_gestor,secuenciaos, motivo_os)
						VALUES (pEmpresa,pNumSol, today , dFecha_Ent,cStatusPr, 'sistema', 'sistema',iSecuenciaOs,NVL(iMotivoOs,2));
					END IF;
					
					--SE ACTUALIZA EL ESTATUS FINAL HEREDADO DEL CLIENTE PROSPECTO.
					UPDATE "informix".ss_solicitudes_mc SET status_fin = cStatusSolic, observaciones = pComentario 
					WHERE empresa = pEmpresa AND num_solicitud = pNumSol AND status_ini = "MC";
					
				ELSE -- hsrr No es prospecto
					
					--Inicio Herencia de los estatus de una OS existente y vigente del mismo Cliente
					IF pStatusFin = 'EE' THEN
					
						SELECT  b.clave_producto
						INTO sNum_producto-- cProducto
						FROM bdicred:"informix".sd_definicion a
						JOIN bdisolic:ss_oscalle_plazovigencia b ON b.clave_producto=a.num_producto 
						AND a.bandera_os = 1 AND resp_oscalle in ('A','R')
						AND b.clave_producto = sNum_producto--cProducto  --Se agrega validacion porque ya se sabe que el producto es Banco
						group by b.clave_producto;
			
						IF NVL(sNum_producto,'') <> '' THEN 
			
							FOREACH
								--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR PARA TITULAR 'T' Y PROSPECTOS 'P'.		
								SELECT LIMIT 1 b.secuencia,b.clave,b.fecharespuesta,a.num_solicitud,'T' tipo_sol
								INTO  iSecuenciaOs,cStatusRespOs,dFecha_Respuesta,cNumSolOs,cTipoSol
								FROM  bdisolic:"informix".ss_solicitudes a
								JOIN bdisolic:"informix".ss_osclientesupervisar b ON (a.num_solicitud = b.num_solicitud)
								WHERE a.empresa = b.empresa AND b.secuencia=(SELECT MAX(d.secuencia) from bdisolic:"informix".ss_osclientesupervisar AS d WHERE d.num_solicitud = b.num_solicitud)
								AND clave IN ('A','R') AND fecharespuesta IS NOT NULL AND a.numcte = pNumcte 
								UNION 
								SELECT secuencia,clave,fecharespuesta,num_solicitud,'P' tipo_sol
								FROM bdisolic:"informix".ss_osclientesupervisar
								WHERE empresa  = '001' AND num_solicitud  = cCteProspVig --cCteProsp
								AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProspVig) --cCteProsp
								ORDER BY fecharespuesta DESC
							END FOREACH;			
				
							IF nvl(iSecuenciaOs,0)<>0 THEN	
				
								IF cTipoSol='T' THEN		

									SELECT dias_vigencia
									INTO cDiaVigencia                                           
									FROM bdisolic:"informix".ss_oscalle_plazovigencia
									WHERE clave_producto = sNum_producto --cProducto   
									AND resp_oscalle = cStatusRespOs;
						
									LET vdiastrans = dFecha_Hoy - dFecha_Respuesta;
													
									IF vdiastrans <= cDiaVigencia THEN
										IF cStatusRespOs = 'A' THEN 
											LET pStatusFin = "AT"; 
										Else
											LET pStatusFin = "RT"; 
										END IF;
							
										-- NO Genera OS

										SELECT count (*) INTO valida_os
										 FROM "informix".ss_solicitud_os 	
										 WHERE empresa = pEmpresa AND num_solicitud  = pNumSol AND fecha_solicitud = today;
										
										IF valida_os = 0 THEN
											INSERT INTO bdisolic:"informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os)
											VALUES('001', pNumSol, dFecha_Hoy, dFecha_Respuesta,cStatusRespOs, 'sistema', 'sistema', NULL, NULL, NULL, ' ', 0, NULL, NULL, iSecuenciaOs, 0);														
										END IF;

									END IF;

								ELIF cTipoSol='P'	THEN

									LET dFecha_Respuesta = NVL(dFecha_Respuesta,DATE(1));

									IF cStatusRespOs = 'D' THEN
										SELECT dias_vigencia INTO cDiaVigencia FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = sNum_producto  AND resp_oscalle = '';		
									ELSE
										SELECT dias_vigencia INTO cDiaVigencia FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = sNum_producto  AND resp_oscalle = cStatusRespOs;												
									END IF;	
						
									LET dFechaVencimiento = dFecha_Respuesta + cDiaVigencia::INTEGER UNITS DAY; 
																			
									-- Se valida que la respuesta esta activa 	
									IF(dFecha_Hoy <= dFechaVencimiento) THEN

										SELECT count (*) INTO valida_os
										 FROM "informix".ss_solicitud_os 	
										 WHERE empresa = pEmpresa AND num_solicitud  = pNumSol AND fecha_solicitud = today;
										
										IF valida_os = 0 THEN
											INSERT INTO bdisolic:"informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os)
											VALUES('001', pNumSol, dFecha_Hoy, dFecha_Respuesta,cStatusRespOs, 'sistema', 'sistema', NULL, NULL, NULL, ' ', 0, NULL, NULL, iSecuenciaOs, 0);							
										END IF;
										
										IF cStatusRespOs = 'A' THEN LET pStatusFin = "AT"; END IF;
										IF cStatusRespOs = 'R' THEN LET pStatusFin = "RT"; END IF;
										IF cStatusRespOs = 'D' THEN LET pStatusFin = "OA"; END IF;
										IF cStatusRespOs = ' ' THEN LET pStatusFin = "OS"; END IF;
										
									END IF;	 
								END IF;
								
								IF pStatusFin = 'AT' AND NVL(cStatusMovil,'') = '1' THEN	
									--para que cuando tenga completo el proceso lo deje en AT						
									LET pStatusFin = 'PA';
									--OBTENER LA DESCRIPCION DEL STATUS DEL CATALOGO						
									SELECT descripcion INTO pComentario FROM "informix".ss_status_sol WHERE status_solicitud = pStatusFin;
								END IF;
								UPDATE "informix".ss_solicitudes_mc SET status_fin = pStatusFin, observaciones = pComentario 
								WHERE empresa = pEmpresa AND num_solicitud = pNumSol AND status_ini = "MC";
								
							END IF; 	
						END IF;
					END IF;

					--Fin Herencia de los estatus de una OS existente y vigente del mismo Cliente
					
					IF pStatusFin = 'AT' AND NVL(cStatusMovil,'') = '1' THEN	
						--para que cuando tenga completo el proceso lo deje en AT						
						LET pStatusFin = 'PA';
						--OBTENER LA DESCRIPCION DEL STATUS DEL CATALOGO						
						SELECT descripcion INTO pComentario FROM "informix".ss_status_sol WHERE status_solicitud = pStatusFin;
					END IF;
					
					----------- Eliminacion de la OS para grupo 5 ITD
					IF  pStatusFin = "EE"  AND  pStatusFin <> v_hereda_status THEN
						LET pStatusFin = v_hereda_status;
						
						IF pStatusFin = 'AT' AND NVL(cStatusMovil,'') = '1' THEN	
							--para que cuando tenga completo el proceso lo deje en AT						
							LET pStatusFin = 'PA';
							--OBTENER LA DESCRIPCION DEL STATUS DEL CATALOGO						
							SELECT descripcion INTO pComentario FROM "informix".ss_status_sol WHERE status_solicitud = pStatusFin;
						ELSE	
							IF  pStatusFin = "AT"  THEN					  
									EXECUTE PROCEDURE "informix".sp_valida_comprobante(pEmpresa ,pNumCte, pNumSol)
									INTO cCodRetComp,cMensajeRet,iValido;
									
									 SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = pNumSol;
									 -- RQM 09 632 - Si es producto 9300 y no tiene comentario, el comprobante no estÃÂ¡ correcto
									 SELECT observaciones,  ejecutivo_autoriza INTO pComentario, cejecutivoAut FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = pNumSol;
									 IF NVL(pComentario,'') = '' AND NVL(sNumprod,'') = '9300' THEN
										LET iValido = 0;
									 END IF;
									IF cCodRetComp::INTEGER = 0 AND iValido = 1 THEN -- RQM 09 492
										--INC 27 205 Se contempla la revisiÃÂ³ÃÂ®ÃÂ ÃÂ°ara 6001 tambiÃÂ©ÃÂ®ÃÂ y ya no va para LC, solo si se va por tiempo se considerara el LC
										/*IF sNumprod = '6001' THEN --RQM 10 1432
											LET pStatusFin = 'LC';
											LET pComentario= 'Revision Linea de Credito';
										END IF;*/
										IF NVL(pComentario,'') = '' THEN LET pComentario= 'Comprobante no valido'; END IF;
										IF isolcomp = 0 THEN
											INSERT INTO "informix".ss_solicitudes_cac (empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado, comprobante_valido_cac) 
											VALUES (pEmpresa, pNumSol, pNumCte,v_sucursal, sNumprod, pStatusFin, pEjecutivo_ana, pEjecutivo_aut, "N", pComentario, "S", v_valor, CURRENT,CURRENT, DATE(1), 'S', 'N');	
										ELSE
											IF cejecutivoAut = '' THEN
												UPDATE  "informix".ss_solicitudes_cac SET  status = pStatusFin, ejecutivo_atiende = pEjecutivo_ana, ejecutivo_autoriza= pEjecutivo_aut, comprobante_valido= 'N', comprobante_valido_cac='N', observaciones = pComentario WHERE num_solicitud = pNumSol;
											END IF;
										END IF;
									ELIF cCodRetComp::INTEGER = 0 AND iValido = 0 THEN --RQM101432-4vr2 Se contempla para cuando sea prestamo y se vaya autorizar actualizar la informaciÃÂÃÂ³n de linea superior		 
										IF sNumprod <> '6001' THEN  
											IF NVL(pComentario,'') = '' THEN LET pComentario= 'Comprobante no valido'; END IF;
											IF isolcomp = 0 THEN
												INSERT INTO "informix".ss_solicitudes_cac (empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado, comprobante_valido_cac) 
												VALUES (pEmpresa, pNumSol, pNumCte,v_sucursal, sNumprod, pStatusFin, pEjecutivo_ana, pEjecutivo_aut, "N", pComentario, "S", v_valor, CURRENT,CURRENT, DATE(1), 'S','N');	
											ELSE
											-- RQM 09 632 - Verifica no sea producto 9300
												IF cejecutivoAut = '' AND sNumprod <> '9300' THEN	
													UPDATE  "informix".ss_solicitudes_cac SET  status = pStatusFin, ejecutivo_atiende = pEjecutivo_ana, ejecutivo_autoriza= pEjecutivo_aut, comprobante_valido= 'N', comprobante_valido_cac= 'N', observaciones = pComentario  WHERE num_solicitud = pNumSol;
												END IF;
												-- RQM 09 632 - Si es producto 9300, actualiza ss_solicitudes_cac, ss_revision_determinacion y ejecuta determina_lincred_tc_cjunk
												IF (sNumprod = '9300') THEN
													SELECT valor::DECIMAL(14,6)
													INTO v_tope_ingre -- Salario Maximo
													FROM "informix".ss_param
													WHERE empresa = pEmpresa
													AND secuencia = 414;
													UPDATE "informix".ss_solicitudes_cac SET  status = pStatusFin, ejecutivo_atiende = pEjecutivo_ana, ejecutivo_autoriza= pEjecutivo_aut, comprobante_valido= 'N', comprobante_valido_cac= 'N', observaciones = pComentario, ingreso_cac = v_tope_ingre, revisado = 'S' WHERE num_solicitud = pNumSol;
													UPDATE "informix".ss_revision_determinacion SET ingreso_mensual_lc = v_tope_ingre WHERE empresa = pEmpresa AND num_solicitud = pNumSol;
													EXECUTE PROCEDURE "informix".determina_lincred_tc_cjunk(pEmpresa,pNumSol,'') INTO cCodRetDeter, cLineaDeter, cCapPagoDeter, cPlazoDeter;
													-- SI ESTE ES 0
														IF cCodRetDeter = '010' THEN
															LET pComentario= 'Capacidad de pago saturada';
															LET pStatusFin = 'RT';
															LET pCausa = 'CPS';
															UPDATE "informix".ss_solicitudes_cac SET  status = pStatusFin WHERE num_solicitud = pNumSol;
														END IF;
																
												END IF;
												
											END IF;			
										END IF;
									END IF;	
						    END IF;							 							 
					    END IF; --FIN RQM 09 492	
						--SE ACTUALIZA EL ESTATUS FINAL
						UPDATE "informix".ss_solicitudes_mc SET status_fin = pStatusFin, observaciones = pComentario 
						WHERE empresa = pEmpresa AND num_solicitud = pNumSol AND status_ini = "MC";
                    END IF;	--FIN  Eliminacion de la OS para grupo 5 ITD  			
					IF pStatusFin = "AT"  THEN  	--RQM101432-4vr2 Se contempla para cuando sea prestamo y se vaya autorizar actualizar la informaciÃÂÃÂ³n de linea superior		  
						SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = pNumSol;
						SELECT observaciones, ejecutivo_autoriza INTO pComentario , cejecutivoAut FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = pNumSol;	
						IF NVL(pComentario,'') = '' THEN LET pComentario= 'Comprobante no valido'; END IF;
						IF isolcomp = 0 THEN
							INSERT INTO "informix".ss_solicitudes_cac (empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado, comprobante_valido_cac) 
							VALUES (pEmpresa, pNumSol, pNumCte,v_sucursal, sNumprod, pStatusFin, pEjecutivo_ana, pEjecutivo_aut, "N", pComentario, "N", v_valor, CURRENT,CURRENT, DATE(1), 'S' ,'N');	
						ELSE
							IF NVL(cejecutivoAut,'') = '' THEN
								UPDATE  "informix".ss_solicitudes_cac SET  status = pStatusFin, ejecutivo_atiende = pEjecutivo_ana, ejecutivo_autoriza= pEjecutivo_aut, comprobante_valido= 'N' , comprobante_valido_cac= 'N' , observaciones = pComentario WHERE num_solicitud = pNumSol;
							END IF;
						END IF;
					END IF;
					IF pStatusFin = "RT"  THEN
						UPDATE "informix".ss_solicitudes_mc 
							SET status_fin = pStatusFin, 
							ejecutivo_autoriza = pEjecutivo_ana,
							ejecutivo_atiende = pEjecutivo_ana,
							observaciones = pComentario, 
							fecha_determinacion = TODAY,
							revisado = "S",
							tipo_movimiento = pTipoMovto
							WHERE empresa = pEmpresa
							AND num_solicitud = pNumSol
							AND status_ini = "MC"
							AND status_fin = "";
					END IF;
					--Se actualiza la solicitud del cliente titular
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol
					(pEmpresa, pEjecutivo_ana, pNumSol, pStatusFin, pCausa, pComentario)
					INTO cCodRet;
					
					IF cCodRet <> '000000' THEN 
						LET cCodRet = '00002'; -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD.
					END IF
					
					IF pStatusFin = "EE" THEN	
						SELECT count (*) INTO valida_os
						 FROM "informix".ss_solicitud_os 	
						 WHERE empresa = pEmpresa AND num_solicitud  = pNumSol AND fecha_solicitud = today;
						
						IF valida_os = 0 THEN
							INSERT INTO "informix".ss_solicitud_os (empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, motivo_os)
							VALUES (pEmpresa,pNumSol, today , 'S', 'sistema',NVL(iMotivoOs,2));					
						END IF;
					ELIF pStatusFin = "BC" THEN	
						EXECUTE PROCEDURE "informix".sp_mc_envioburo(pEmpresa ,pNumCte,pNumSol , cCoppel ) INTO  cCodRet, cMensajeRet, cBanderaMotorMC; 
							IF cBanderaMotorMC ='1' THEN
							LET cBanderaMotorMC = '2';
						END IF;
					END IF;
				END IF;	
			
				UPDATE "informix".ss_autorizacion 
				SET revision_cac = 2
				WHERE empresa = pEmpresa AND ejecutivo_auto =pEjecutivo_ana
				AND num_solicitud  = pNumSol  AND status_solicitud = pStatusFin
				AND fecha_entrada = (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion as aut2 
															 WHERE aut2.num_solicitud  = pNumSol
															 AND status_solicitud = pStatusFin);
			
			END IF;
		ELSE
			LET cCodRet = "000003";
			LET cMensajeRet = "Error al procesar la solicitud";
		END IF;			
	END IF;
	
	RETURN cCodRet, cMensajeRet, cBanderaMotorMC;
END
END PROCEDURE
