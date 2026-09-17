CREATE PROCEDURE "informix".sp_actualiza_status_sol(pempresa CHAR(3), 
                                                    pejecutivo CHAR(8), 
                                                    pnum_solicitud CHAR(20), 
                                                    pNuevo_Status_Sol CHAR(2),
                                                    pcausa_status CHAR(3),
                                                    pcomentario VARCHAR(255,1)) 												
	RETURNING CHAR(6);

	-- Control de Cambios:
	-----------------------------------------------------------------------------------------
		--Autor: Juan A Coronel M
		--24-08-2007
		--Funcionalidad para avanzar los estatus de una solicitud, registrANDo bitacora 
		--de cambios de estatus.
	-----------------------------------------------------------------------------------------
		--Modifico: Jose Almeida
		--07-12-2009
		--Se valida que el status recibido no sea un vacio o nulo, de lo contrario regresa 
		--un codigo de retorno 000001
		--Que haga uso del campo fecha_ult_mod de ss_anexosol con la fecha del calENDario 
		--de credito.
	-----------------------------------------------------------------------------------------
		--Modifico: Viridiana Osobampo
		--21-04-2010
		--Se agrega parametro de entrada para INdicar una causa delel nuevo estatus, misma 
		--que se almacena en la bitacora de estatus al INSERTar el registro de la solicitud.
	-----------------------------------------------------------------------------------------
	-- Folio: 773
	-- Modifico: 99804879 - Edith Mendoza Barraza.
	-- Fecha de Modificacion: 11-11-2021
	-- Descripcion: Se anade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC.
	-- RQM: RQM 09 570 Pop Ups para informar sobre solicitudes no autorizadas.
	-- Solicito: Abraham Narvaez.
	-----------------------------------------------------------------------------------------
		--Modifico: Cecilia Fernnda Hernandez Baez
		--27/07/2022
		--Se agrega validacion para consultar los datos  completos de lasa solicitudes ingresadas
		--para insertar estos datos en la tabla de trabajo status_solic_wsp.
		--RQM Consultas Whatsapp
		--Solicita: Maria Nereyda De La O Beltran
	-----------------------------------------------------------------------------------------
		--Modifico: Luis Enrique Moo Varguez
		--29-06-2023
		--Se agregan los campos correspondientes a la fecha_solicitud en los insert a las tablas
		--ss_status_solic_wsp y ss_status_solic_wsp_hist.
		--Solicitantes: Mayra Quiroz / Miguel Olivas
	-----------------------------------------------------------------------------------------
		--Modifico: Kevin Galvez Parra
		--23-08-2023
		--Se agregan los campos correspondientes a la secuencia, numctecoppel, sucursal en los insert 
		--a las tablas ss_status_solic_wsp y ss_status_solic_wsp_hist. Se realiza los ajustes
		--para validar que las 2 ultimas cifras de la secuencia sea menor que el porcentaje obtenido del 
		--ss_param de su respectivo nuevo estatus, con la finalidad de seleccionar los clientes 
		--testigos y clientes piloto, al igual implementando que cada mes se reinicie la secuencia a 0.
		--Se agrego la logica para obtener el numctecoppel mientras el nuevo estatus sea 'AP', si no, se
		--inserta un valor de '1'.
		--Solicitantes: Mayra Quiroz / Miguel Olivas
	-----------------------------------------------------------------------------------------
		--Modifico: Kevin Galvez Parra
		--10-11-2023
		--Se agrega linea de codigo para ajustar el valor de la variable cNumCteCoppel que almacena el numero 
		--de cliente coppel, quitando el digito verificador(ultimo digito) para el envio a CI360.
		-- RQM: RQM 09 653 - SMS Automatizado Prospectos, Autorizados y Nunca CI360
		--Solicitantes: Mayra Quiroz / Miguel Olivas
	-----------------------------------------------------------------------------------------
		
	DEFINE sStatus_Actual   	CHAR(2);
	DEFINE dFechaEnt        	DATE;
	DEFINE sEjecutivo       	CHAR(8);
	DEFINE sComentario      	VARCHAR(255,1);
	DEFINE sCodRet          	CHAR(6);
	DEFINE iCodRet          	INTEGER;
	DEFINE dFechaHoy        	DATE;
	DEFINE pfecha 				DATE;
	DEFINE sExiste          	INTEGER;
	DEFINE sNumCte				CHAR(20);
	DEFINE sCliente_Pros    	CHAR(1);
	DEFINE iFiltroParam     	INTEGER;
	DEFINE vgrupo_sol       	CHAR(1);
	DEFINE v_respsic        	CHAR(1);
	DEFINE iDiaParaRevisar  	INTEGER;
	--APR 20180605
	DEFINE sStatus_numctepros 	CHAR(2);
	DEFINE ncliente_pros		CHAR(1);

	--598
	DEFINE cNumSolicMixta		CHAR(20);
	DEFINE vfechaServ DATE;
	
	DEFINE cTipoSolic			CHAR(1);
	
	
	DEFINE cCanal_Sol 			INTEGER;
	DEFINE iPreAprobado 		INTEGER;
	DEFINE iCuentaEst 		    INTEGER;
	
	--Se agrega actualizacion de estatus AT, PA OS IN
							 
	DEFINE iTipoCliente CHAR(2);
	DEFINE fecha_proceso DATETIME YEAR TO SECOND;
	DEFINE status_proceso CHAR(2);
					 
	DEFINE nombreCliente1 CHAR(80);
    DEFINE nombreCliente2 CHAR (80);
	DEFINE apellidoPaterno CHAR (80);
	DEFINE numeroCliente CHAR (15);
	
	DEFINE numeroCelular CHAR(15);
	DEFINE statusTelefono  CHAR(2);
	DEFINE cCofetel CHAR(1);
	DEFINE cNumProducto CHAR(4);
	DEFINE isam_err              SMALLINT;								   
	
	--Se anade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC. 
	DEFINE csolicitud_sic CHAR(20);
	
	--Se agrega campo de fecha solicitud
	DEFINE cFechaSolicitud DATE;
	
	--Se anade variable para obtener el porcentaje de clientes testigos
	DEFINE cPorcentaje INTEGER;
	DEFINE cUltimaSecuencia INTEGER;
	DEFINE cSucursal CHAR(4);
	DEFINE cNumCteCoppel CHAR(20);
	--Se anade variable para habilitar/deshabilitar el proceso de actualiza estatus del producto 6500
	DEFINE cProcHabilitado CHAR(1);
	DEFINE vSecuenciaTelAct INTEGER;
	
	LET sExiste 				= 0; 
	LET sCliente_Pros 			= '0';
	LET iFiltroParam 			= 0;
	LET vgrupo_sol 				= '';
	LET v_respsic  				= '';
	LET iDiaParaRevisar 		= 0;
	--APR 20180605
	LET sStatus_numctepros 		= '';
	LET ncliente_pros 			= '';

	--598
	LET cTipoSolic 				= '';
	LET cNumSolicMixta 			= '';
	
	LET cCanal_Sol 				= 0;
	LET iPreAprobado            = 0;
	LET iCuentaEst              = 0;
	
	
	--Se agrega actualizacion de estatus AT, PA OS IN
					
	LET iTipoCliente = '0';
	
	LET fecha_proceso = "";
	LET status_proceso = '0';
				
	LET nombreCliente1 = '';
    LET nombreCliente2 = '';
	LET apellidoPaterno='';
	LET numeroCliente = '';

	LET numeroCelular = '';
	LET statusTelefono = '';
	LET cCofetel ='';
	LET cNumProducto = '';

	LET sStatus_Actual			= '';
	LET sNumCte					= '';
	LET dFechaHoy		        = DATE(1);			
	
	--Se anade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC. 
	LET csolicitud_sic = '';
	LET cPorcentaje = 0;
	LET cUltimaSecuencia = 0;
	LET cSucursal = '';
	--Se inicia la variable con valor 1 cuando no tiene numero de cliente asignado.
	LET cNumCteCoppel = '1';
	
	LET cProcHabilitado = '0';
	LET vSecuenciaTelAct = 0;
	
	BEGIN
		ON EXCEPTION SET iCodRet, isam_err
		
			INSERT INTO bdisolic:"informix".ss_bitacora_errores_status(numcte, num_solicitud, status_actual, status_nuevo, pcausa_status, fecha_insert, fecha_hora, tipo_sp, sql_err, isam_err) 
    			VALUES(sNumCte, pnum_solicitud, sStatus_Actual, pNuevo_Status_Sol, pcausa_status, dFechaHoy, CURRENT, '1', iCodRet, isam_err);																																										   
			
			LET SCodRet = iCodRet;
			RETURN SCodRet;
		END EXCEPTION;
		
		--SET debug file to '/home/sysifx/AngelTASF/sp_actualiza_status_sol.out';
		--trace on;
		

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF pNuevo_Status_Sol = '' OR  pNuevo_Status_Sol IS NULL THEN
			LET SCodRet = '000001'; ---Status vacio 
			RETURN SCodRet;
		END IF;
			
		-- Carga la Fecha del Dia
		SELECT fecha_hoy 
		INTO dFechaHoy
		FROM bdicred:sd_fechas
		WHERE empresa = pempresa;
		
		-- RQI 21 246  Originacion de solicitudes 24 x 7
		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
		INTO vfechaServ
		FROM sysmaster:sysshmvals;
	
		IF dFechaHoy < vfechaServ THEN
			LET dFechaHoy = vfechaServ;
		END IF;

		LET SCodRet = '000000';
		
		SELECT  COUNT(*) INTO iPreAprobado
		FROM ss_solicitudes 
		WHERE empresa = pempresa 
		AND num_solicitud = pnum_solicitud
		AND user_insert='sys_cred';

		SELECT status_solicitud, numcte, nvl(dia_para_revisar,0), canal_sol, num_producto, fecha_insert, sucursal
		INTO sStatus_Actual, sNumCte, iDiaParaRevisar, cCanal_Sol, cNumProducto, cFechaSolicitud, cSucursal
		FROM ss_solicitudes 
		WHERE empresa = pempresa 
		AND num_solicitud = pnum_solicitud;
		
		
	    IF iPreAprobado = 1 THEN
		   SELECT COUNT(*) INTO iCuentaEst FROM ss_autorizacion WHERE num_solicitud = pnum_solicitud AND status_solicitud = 'AT';
		     IF iCuentaEst  = 1 THEN
			    IF  sStatus_Actual = 'BC' THEN
			 	 INSERT INTO ss_autorizacion
				(empresa, ejecutivo_auto, num_solicitud, status_solicitud,causa_solicitud,cliente_pros,
				 comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
			     VALUES
				(pempresa, pejecutivo, pnum_solicitud, pNuevo_Status_Sol,pcausa_status,ncliente_pros,
				 pcomentario, dFechaHoy, dFechaHoy, pejecutivo, dFechaHoy);
			     UPDATE ss_solicitudes SET status_solicitud = UPPER(pNuevo_Status_Sol)
	     	     WHERE empresa = pempresa AND num_solicitud = pnum_solicitud;
				 RETURN sCodRet;
				END IF;
			ELIF iCuentaEst >=2  AND pNuevo_Status_Sol = 'AT' THEN
			     RETURN sCodRet;
			 END IF;
		END IF;

	--Se anade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC. INI

	
		IF pcausa_status = 'RCB' AND pNuevo_Status_Sol = 'RT' THEN	
		
			LET pNuevo_Status_Sol = 'CN';
			LET pcausa_status ='CCB';
			LET pcomentario = 'CANCELADO POR CREDITO BLOQUEADO';
			
			SELECT num_solicitud INTO csolicitud_sic
			FROM bdisolic:"informix".ss_solicitudes_sic 
			WHERE numcte = sNumCte AND  num_solicitud = pnum_solicitud AND fecha_sic IS NULL AND  fecha_insert = dFechaHoy;
			
			IF EXISTS (SELECT fecha_sic  FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = sNumCte AND num_solicitud = csolicitud_sic AND fecha_sic IS NULL) THEN
				UPDATE bdisolic:"informix".ss_solicitudes_sic SET fecha_sic = dFechaHoy, causa_rt = 'CCB'
				WHERE numcte = sNumCte AND num_Solicitud = csolicitud_sic AND fecha_sic IS NULL;
			END IF
			
		END IF;
		
	--Se anade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC. FIN
	
	--Se agrega actualizacion de estatus AT/OS/PA/IN....END
		--If pNuevo_Status_Sol = sStatus_Actual then
		--    RETURN SCodRet;
		--END if;
		IF sStatus_Actual IN ('OS','EE') THEN
			IF pNuevo_Status_Sol IN ('CN','RT') THEN
				IF EXISTS (SELECT num_solicitud FROM BDISOLIC:ss_solicitud_os WHERE num_solicitud = pnum_solicitud AND status IN ('P','S')) THEN
					
				   SELECT MAX(fecha_solicitud)  INTO pfecha FROM BDISOLIC:ss_solicitud_os 
					WHERE empresa = '001' 
					AND num_solicitud = pnum_solicitud 
					AND status IN ('P','S');
					
					UPDATE BDISOLIC:ss_solicitud_os SET status = 'C' 
						WHERE empresa = '001'
						AND num_solicitud = pnum_solicitud 
						AND fecha_solicitud = pfecha;
					
				END IF;
			END IF;
		END  IF;

		-- Para solicitudes que fueron marcadas en campana de filtro parametrico, se quita esa marca al ser rechazadas
		IF pNuevo_Status_Sol IN ('CN','RT','CM') AND iDiaParaRevisar = 1 THEN

			SELECT grupo, respuesta_sic INTO vgrupo_sol, v_respsic FROM bdisolic:ss_filtro_paramtr WHERE num_solicitud = pnum_solicitud; 
			SELECT valor::INTEGER INTO iFiltroParam FROM bdisolic:ss_parametrodias WHERE empresa = pempresa AND grupo = vgrupo_sol 
						 AND respuesta_sic = (CASE WHEN v_respsic = '1' then '0' else v_respsic END) AND cod_tip_filtro = '1';

			LET iFiltroParam = iFiltroParam + 1;
			UPDATE bdisolic:"informix".ss_parametrodias SET valor = to_CHAR(iFiltroParam) WHERE empresa = pempresa AND grupo = vgrupo_sol 
			   AND respuesta_sic = (CASE WHEN v_respsic = '1' then '0' else v_respsic END) AND cod_tip_filtro = '1';

			UPDATE bdisolic:ss_solicitudes SET dia_para_revisar = 0 WHERE empresa = pempresa AND num_solicitud = pnum_solicitud; 
			DELETE FROM bdisolic:ss_filtro_paramtr WHERE num_solicitud = pnum_solicitud; 

		END IF;

		SELECT MAX(fecha_entrada) 
		INTO dFechaEnt 
		FROM ss_autorizacion 
		WHERE empresa = pempresa 
		AND num_solicitud = pnum_solicitud 
		AND status_solicitud = sStatus_Actual;

		UPDATE ss_autorizacion
		SET fecha_salida = dFechaHoy
		WHERE empresa = pempresa 
		AND num_solicitud = pnum_solicitud
		AND status_solicitud = sStatus_Actual
		AND fecha_entrada = dFechaEnt;

		UPDATE ss_solicitudes
		SET status_solicitud = UPPER(pNuevo_Status_Sol)
		WHERE empresa = pempresa 
		AND num_solicitud = pnum_solicitud;
		
		IF pNuevo_Status_Sol = 'CN' AND cCanal_Sol = 2 THEN
			UPDATE bdinteg:si_solicitud_movil
			SET folio_procesado = 1
			WHERE num_tdc_coppel = pnum_solicitud;
			
			UPDATE bdinteg:si_solicitud_movil
			SET folio_procesado = 1
			WHERE num_tdc_bcoppel=pnum_solicitud;
		END IF;
		
		LET pNuevo_Status_Sol = TRIM(NVL(pNuevo_Status_Sol,'')); 
		
		--598
		--VALIDAR QUE EL NUEVO ESTATUS DE SOLICITUD NO ESTE CANCELADO  
		IF pNuevo_Status_Sol <> 'PC' AND pNuevo_Status_Sol <> 'CN' AND pNuevo_Status_Sol <> 'CC' AND pNuevo_Status_Sol <> 'AN' THEN
		
			LET pnum_solicitud = TRIM(NVL(pnum_solicitud,''));
			
			--VALIDAR QUE TIPO DE SOLICITUD SEA PARA PROCESO MIXTO
			SELECT tipo_solicitud
			INTO cTipoSolic
			FROM "informix".ss_solicitudes
			WHERE Empresa = pEmpresa
			AND num_solicitud = pnum_solicitud;
			
			LET cTipoSolic = TRIM(NVL(cTipoSolic,''));
			
			--SI SE TRARA DE UN PROCESO MIXTO, SE ACTUALIZARA A 1 PARA PODER REALIZAR EL ENVIO AL PARAMETRICO COPPEL
			IF cTipoSolic = 'T' OR cTipoSolic = 'P' THEN
						
				--SELECCIONA SI EL PROCESO DE SOLICITUD COPPEL
				-- FUE MIXTO O UNICO		
							
				SELECT num_solicitud_ref
				INTO cNumSolicMixta
				FROM "informix".ss_resum_scor_fin
				WHERE empresa = pEmpresa
				AND num_solicitud = pnum_solicitud; 

				LET cNumSolicMixta = TRIM(NVL(cNumSolicMixta,''));
				
				IF cNumSolicMixta <> '' THEN
					--ACTUALIZA A 1 PARA PODER REALIZAR EL ENVIO AL PARAMETRICO COPPEL
					UPDATE "informix".ss_solicitudes
					SET envio_parametrico = '1'
					WHERE Empresa = pEmpresa
					AND num_solicitud =cNumSolicMixta
					AND envio_parametrico = '5';
				END IF;
			END IF;
		END IF;
		
		UPDATE ss_anexosol
		SET fecha_ult_mod = dFechaHoy
		WHERE empresa = pempresa 
		AND num_solicitud = pnum_solicitud;

		LET sEjecutivo = TRIM(NVL(pejecutivo, ' '));  

		IF LOWER(sEjecutivo) = 'sistema' OR sEjecutivo = '' THEN
			LET sEjecutivo = 'sistema';
		END IF;

		LET sComentario = TRIM(NVL(pcomentario, ' '));
		LET pcausa_status = TRIM(NVL(pcausa_status,""));

		SELECT COUNT(*)
		INTO sExiste
		FROM ss_autorizacion
		WHERE empresa = pempresa
		AND ejecutivo_auto = sEjecutivo 
		AND num_solicitud = pnum_solicitud
		AND status_solicitud = UPPER(pNuevo_Status_Sol)
		AND fecha_entrada = dFechaHoy;

   
		IF (sExiste > 0)  THEN
			UPDATE ss_autorizacion
			SET causa_solicitud = pcausa_status,
				comentario = sComentario,
				fecha_salida = dFechaHoy,
				user_INSERT = sEjecutivo,
				fecha_INSERT = dFechaHoy
			WHERE empresa = pempresa
			AND ejecutivo_auto = sEjecutivo 
			AND num_solicitud = pnum_solicitud
			AND status_solicitud = UPPER(pNuevo_Status_Sol)
			AND fecha_entrada = dFechaHoy;
			
		ELSE
			LET pNuevo_Status_Sol = UPPER(pNuevo_Status_Sol);

			IF EXISTS(SELECT a.numcte
			FROM bdisolic:'informix'.ss_solicitudes a
			JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
			WHERE a.num_solicitud = pnum_solicitud) THEN
                
				{-OPTIMIZACION STK202311
				IF EXISTS(SELECT a.numcte
				FROM bdisolic:'informix'.ss_solicitudes a
				JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
				JOIN bdiprospectos:'informix'.pr_autorizacion c ON b.numcte_pros = c.num_solicitud
				WHERE a.num_solicitud = pnum_solicitud
				AND c.status_solicitud = pNuevo_Status_Sol) THEN
                -OPTIMIZACION STK202311}
                
				{+OPTIMIZACION STK202311}
                IF EXISTS(SELECT a.numcte        
                FROM bdisolic:'informix'.ss_solicitudes a, bdiprospectos:'informix'.pr_cliente b, bdiprospectos:'informix'.pr_autorizacion c
                WHERE a.empresa = b.empresa
				AND   a.num_solicitud = b.numcte_pros
				AND   a.numcte = b.numcte
				AND   a.empresa = c.empresa
				AND   a.num_solicitud = c.num_solicitud
				AND   b.empresa = c.empresa
				AND   b.numcte_pros = c.num_solicitud
				AND   a.empresa = pempresa
				AND   a.num_solicitud = pnum_solicitud
				AND   c.status_solicitud = pNuevo_Status_Sol) THEN
                {+OPTIMIZACION STK202311}    

                    {-OPTIMIZACION STK202311
					SELECT b.status_numcte_pros INTO sStatus_numctepros
					FROM bdisolic:'informix'.ss_solicitudes a
					JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
					AND a.num_solicitud = pnum_solicitud;
					-OPTIMIZACION STK202311}

					{+OPTIMIZACION STK202311}
					SELECT b.status_numcte_pros INTO sStatus_numctepros   
					FROM bdisolic:'informix'.ss_solicitudes a, bdiprospectos:'informix'.pr_cliente b
					WHERE a.empresa = b.empresa
					and   a.num_solicitud = b.numcte_pros
					AND   a.empresa = pempresa
					AND   a.num_solicitud = pnum_solicitud;
                    {+OPTIMIZACION STK202311}
					IF sStatus_numctepros NOT IN ('CM','RT','CN') THEN

						IF (SELECT COUNT(num_solicitud) FROM bdisolic:ss_autorizacion WHERE num_solicitud = pnum_solicitud AND status_solicitud = pNuevo_Status_Sol) > 1 THEN
						--IF EXISTS(SELECT num_solicitud FROM bdisolic: ss_autorizacion WHERE num_solicitud = n.num_solicitud AND status_solicitud = 'OA') THEN
							LET ncliente_pros = '1';
						ELSE
							IF (EXISTS(SELECT num_solicitud FROM bdisolic:ss_autorizacion WHERE num_solicitud = pnum_solicitud AND status_solicitud = 'OA'))
								AND (pNuevo_Status_Sol IN ('EE','OS')) THEN
								LET ncliente_pros = '1';
							ELSE
								LET ncliente_pros = '2';
							END IF;
						END IF;
					END IF;
				{-OPTIMIZACION 202311
				ELIF EXISTS( SELECT a.numcte
						FROM bdisolic:'informix'.ss_solicitudes a
						JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
						WHERE a.num_solicitud = pnum_solicitud
						AND b.status_numcte_pros NOT IN ('CM','RT','CN')) THEN
							LET ncliente_pros = '1';
                -OPTIMIZACION STK202311}

                {+OPTIMIZACION STK202311}
                ELIF EXISTS( SELECT a.numcte           
							FROM bdisolic:'informix'.ss_solicitudes a, bdiprospectos:'informix'.pr_cliente b 
							WHERE a.empresa = b.empresa
							and   a.num_solicitud = b.numcte_pros
							AND   a.numcte = b.numcte
							AND   a.empresa = pempresa
							AND   a.num_solicitud = pnum_solicitud
							AND   b.status_numcte_pros NOT IN ('CM','RT','CN')) THEN
							      LET ncliente_pros = '1';
				{+OPTIMIZACION STK202311}
				END IF

			END IF;
			
			INSERT INTO ss_autorizacion
				(empresa, ejecutivo_auto, num_solicitud, status_solicitud,causa_solicitud,cliente_pros,
				 comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
			VALUES
				(pempresa, sEjecutivo, pnum_solicitud, pNuevo_Status_Sol,pcausa_status,ncliente_pros,
				 sComentario, dFechaHoy, dFechaHoy, sEjecutivo, dFechaHoy);
			
		END IF;
	
		IF (pNuevo_Status_Sol IN ('CN','RT','AP','CM')) AND (SUBSTR(pnum_solicitud,1,4) = '6500') THEN
			IF EXISTS (SELECT numcte FROM bdiprospectos:'informix'.pr_cliente WHERE numcte = sNumCte) THEN
				UPDATE bdINteg:si_cliente SET cliente_pros = sCliente_Pros WHERE numcte = sNumCte AND cliente_pros = '1';
			END IF;
		END IF;

		-- Si la solicitud cambia a estatus AP, es decir que ya se formalizo el credito, se elimINa del grupo 8.
		   -- Si se evalua con AT, existe la probabilidad que no se formalice el credito.
		IF (pNuevo_Status_Sol = 'AP') THEN
			LET vgrupo_sol = '';
			SELECT NVL(grupo,'') INTO vgrupo_sol FROM "informix".ss_resum_scor_fin WHERE empresa = pempresa AND num_solicitud = pnum_solicitud;
			IF vgrupo_sol = '8' THEN
				UPDATE bdisolic:ss_clienteslargos  
				SET status = 'IN', fecha_cambio_status = dFechaHoy
				WHERE numcte = sNumCte;
			END IF;
		END IF;      
		
		-- Almacena INformacion para la bitacora de la solicitud  INI
		
		UPDATE bdisolic:"informix".ss_revision_determinacion SET estatus_sol = UPPER(pNuevo_Status_Sol), causa_rechazo = pcomentario  WHERE empresa = pempresa AND num_solicitud = pnum_solicitud;
		
		--Se agrega consulta para conocer si esta habilitado el proceso para el producto 6500
		SELECT NVL(TRIM(valor), '0')
		INTO cProcHabilitado
		FROM bdisolic:informix.ss_param
		WHERE secuencia=106 AND empresa='001';

		
		--Se agrega actualizacion de estatus AT/OS/PA....START
		--Se anade validacion de proceso habilitado
		--IF cNumProducto = '6500' AND pNuevo_Status_Sol  IN ('AT', 'OS', 'PA')THEN
		--09 653
		IF cProcHabilitado = '1' THEN
			IF cNumProducto = '6500' AND pNuevo_Status_Sol IN ('AT', 'PA', 'AP') THEN
			
				SELECT MAX(secuencia)
				INTO vSecuenciaTelAct
				FROM bdinteg:'informix'.si_telefonos_actual 
				WHERE tipo_tel = '2' AND numcte = sNumCte;
					
				SELECT telefono, status_tel, cofetel
				INTO numeroCelular, statusTelefono, cCofetel
				FROM bdinteg:'informix'.si_telefonos_actual
				WHERE tipo_tel = '2' AND secuencia = vSecuenciaTelAct
				AND numcte = sNumCte;			
						
				IF statusTelefono ='A' AND cCofetel = 'V' THEN		
			   
					SELECT nombre1, nombre2, apell_paterno, tipo_cliente
					INTO nombreCliente1, nombreCliente2, apellidoPaterno, iTipoCliente
					FROM bdinteg:'informix'.si_cliente
					WHERE numcte = sNumCte;
				
					-- Para el nuevo estatus 'AT'
					IF ( sStatus_Actual = 'OS' AND pNuevo_Status_Sol = 'AT' AND cCanal_Sol in ('1', '2', '3')) then
						SELECT CAST(valor AS INTEGER) INTO cPorcentaje from ss_param where secuencia = 104;
						
						SELECT secuencia INTO cUltimaSecuencia 
						FROM bdisolic:informix.ss_status_solic_wsp_secuencia 
						WHERE status_solicitud = 'AT' AND MONTH(fecha) = MONTH(current);
						
						LET cUltimaSecuencia = NVL(cUltimaSecuencia, 0);
						
						-- Si es menor que el porcentaje 'AT'
						IF SUBSTR(LPAD(cUltimaSecuencia, 10, 0), -2) < cPorcentaje THEN
							INSERT INTO "informix".ss_status_solic_wsp_hist(numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, response_code, response_id, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel)
							VALUES (sNumCte, TRIM(nombreCliente1), numeroCelular, pnum_solicitud, pNuevo_Status_Sol, cCanal_Sol, current, 'Cliente testigo', null, cFechaSolicitud, cNumProducto, cUltimaSecuencia, cSucursal, '1');
						-- Si es mayor que el porcentaje 'AT'	
						ELSE
							INSERT INTO bdisolic:"informix".ss_status_solic_wsp (numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, status_proceso, fecha_proceso, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel)
							VALUES (sNumCte, TRIM(nombreCliente1), numeroCelular, pnum_solicitud, pNuevo_Status_Sol, cCanal_Sol, current, '0', CURRENT, cFechaSolicitud, cNumProducto, cUltimaSecuencia, cSucursal, cNumCteCoppel);
						END IF;
						
						UPDATE bdisolic:informix.ss_status_solic_wsp_secuencia SET secuencia = cUltimaSecuencia + 1, fecha = current WHERE status_solicitud = 'AT';
					--Para el nuevo estatus 'PA'
					--Se ajusta la condicion de validacion para los nuevos estatus distintos de PA con canal 4
					ELIF (pNuevo_Status_Sol = 'PA' AND (cCanal_Sol in ('1', '2') OR  (sStatus_Actual = 'OS' AND cCanal_Sol = '4') ) ) THEN
						SELECT CAST(valor AS INTEGER) INTO cPorcentaje from ss_param where secuencia = 105;
						
						SELECT secuencia INTO cUltimaSecuencia 
						FROM bdisolic:informix.ss_status_solic_wsp_secuencia 
						WHERE status_solicitud = 'PA' AND MONTH(fecha) = MONTH(current);
						
						LET cUltimaSecuencia = NVL(cUltimaSecuencia, 0);
						
						--Si es menor al porcentaje para el estatus 'PA'
						IF SUBSTR(LPAD(cUltimaSecuencia, 10, 0), -2) < cPorcentaje THEN
							INSERT INTO "informix".ss_status_solic_wsp_hist(numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, response_code, response_id, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel)
							VALUES (sNumCte, TRIM(nombreCliente1), numeroCelular, pnum_solicitud, pNuevo_Status_Sol, cCanal_Sol, current, 'Cliente testigo', null, cFechaSolicitud, cNumProducto, cUltimaSecuencia, cSucursal, '1');
						--Si NO es menor al porcentaje para el estatus 'PA'
						ELSE
							INSERT INTO bdisolic:"informix".ss_status_solic_wsp (numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, status_proceso, fecha_proceso, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel)
							VALUES (sNumCte, TRIM(nombreCliente1), numeroCelular, pnum_solicitud, pNuevo_Status_Sol, cCanal_Sol, current, '0', CURRENT, cFechaSolicitud, cNumProducto, cUltimaSecuencia, cSucursal, cNumCteCoppel);
						END IF;
						
						UPDATE bdisolic:informix.ss_status_solic_wsp_secuencia SET secuencia = cUltimaSecuencia + 1, fecha = current WHERE status_solicitud = 'PA';
					--Para el nuevo estatus 'AP'
					ELIF (sStatus_Actual = 'AT' AND pNuevo_Status_Sol = 'AP' AND cCanal_Sol in ('1', '2', '3', '4')) THEN
						SELECT FIRST 1 numctecoppel INTO cNumCteCoppel FROM bdinteg:"informix".si_adiccoppel WHERE numcte = sNumCte AND secuencia = 1;
						
						LET cNumCteCoppel = SUBSTR(TRIM(cNumCteCoppel), 1, LENGTH(TRIM(cNumCteCoppel))-1);
						SELECT CAST(valor AS INTEGER) INTO cPorcentaje from ss_param where secuencia = 103;
						
						SELECT secuencia INTO cUltimaSecuencia 
						FROM bdisolic:informix.ss_status_solic_wsp_secuencia 
						WHERE status_solicitud = 'AP' AND MONTH(fecha) = MONTH(current);
						
						LET cUltimaSecuencia = NVL(cUltimaSecuencia, 0);
						
						--Si es menor que el porcentaje 'AP'
						IF SUBSTR(LPAD(cUltimaSecuencia, 10, 0), -2) < cPorcentaje THEN
							INSERT INTO "informix".ss_status_solic_wsp_hist(numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, response_code, response_id, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel)
							VALUES (sNumCte, TRIM(nombreCliente1), numeroCelular, pnum_solicitud, pNuevo_Status_Sol, cCanal_Sol, current, 'Cliente testigo', null, cFechaSolicitud, cNumProducto, cUltimaSecuencia, cSucursal, cNumCteCoppel);
						--Si NO es menor que el porcentaje 'AP'
						ELSE
							INSERT INTO bdisolic:"informix".ss_status_solic_wsp (numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, status_proceso, fecha_proceso, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel)
							VALUES (sNumCte, TRIM(nombreCliente1), numeroCelular, pnum_solicitud, pNuevo_Status_Sol, cCanal_Sol, current, '0', CURRENT, cFechaSolicitud, cNumProducto, cUltimaSecuencia, cSucursal, cNumCteCoppel);						
						END IF;
						
						UPDATE bdisolic:informix.ss_status_solic_wsp_secuencia SET secuencia = cUltimaSecuencia + 1, fecha = current WHERE status_solicitud = 'AP';
						
					END IF
					
				END IF
			END IF;
		END IF;
		
		-- Almacena INformacion para la bitacora de la solicitud  FIN
		
		-- EJECUTA SMS AL CAMBIO DE STATUS AT Y RT INI
		IF cNumProducto = '9300' AND pNuevo_Status_Sol IN ('AT','RT') AND sCodRet = '000000' THEN
			EXECUTE PROCEDURE bdisolic:"informix".sp_envia_sms_actualiza_sol(pempresa, cNumProducto, pnum_solicitud, sNumCte, pNuevo_Status_Sol);
		END IF;
		-- EJECUTA SMS AL CAMBIO DE STATUS AT Y RT FIN

		RETURN sCodRet;
  
	END;
END PROCEDURE
