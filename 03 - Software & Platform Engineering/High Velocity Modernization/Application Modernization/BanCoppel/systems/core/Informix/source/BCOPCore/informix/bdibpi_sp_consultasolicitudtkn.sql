CREATE PROCEDURE "informix".sp_consultasolicitudtkn ( psNumCte CHAR(9), psSolicitud CHAR(10), psNsToken CHAR(9), psTipoConsulta CHAR(3))
RETURNING CHAR (5) AS Retorno,
	CHAR(150) AS errorActividad,
	CHAR(10)  AS solicitud,
	CHAR(20)  AS f_solicitud,
	CHAR(20)  AS f_atencion,
	CHAR(40)  AS estatus,
	CHAR(9)   AS nsToken,
	CHAR(400) AS comentariosReporte,
	CHAR(3)   AS idStatus,
	CHAR(30)  AS numGuia,
	CHAR(9)   AS numCte,
	CHAR(10)  AS codRastreo,
	CHAR(200) AS descripcionSeguimiento,
	CHAR(3)   AS tipoConsulta;
	
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE viCodigo 				INTEGER;
	DEFINE vssqlerr 				CHAR(5);
	DEFINE isam_err 				INT;
	DEFINE error_info 				CHAR(70);
	DEFINE vsErrorActividad 		CHAR(150);
	DEFINE vsF_solicitud 			CHAR(20);
	DEFINE vsF_atencion 			CHAR(20);
	DEFINE vsEstatus 				CHAR(40);
	DEFINE vsNsToken 				CHAR(9);
	DEFINE vsComentariosReporte 	CHAR(400);
	DEFINE vsIdStatus 				CHAR(3);
	DEFINE vsIdStatusT 				CHAR(3);
	DEFINE vsNumGuia 				CHAR(30);
	DEFINE vsCodRastreo 			CHAR(10);
	DEFINE vsDescripcionSeguimiento CHAR(200);
	DEFINE vsstatusTo 				CHAR(3);
	DEFINE vsTipoSol 				CHAR(2);
	DEFINE vsStatusG 				CHAR(3);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	LET viCodigo 			 	 	= 0;
	LET vssqlerr 			 	 	= '00000';
	LET isam_err 			 	 	= 0 ;
	LET error_info 			 	 	='' ;
	LET vsErrorActividad	 		='';
	LET vsF_solicitud 		 	 	= CAST(CURRENT::DATETIME YEAR TO SECOND AS CHAR(20));
	LET vsF_atencion 		 	 	= CAST(CURRENT::DATETIME YEAR TO SECOND AS CHAR(20));
	LET vsEstatus			 		='';
	LET vsNsToken 			 	 	='';
	LET vsComentariosReporte 	 	='';
	LET vsIdStatus			 	 	='';
	LET vsIdStatusT 		 	 	='';
	LET vsNumGuia 			 	 	='';
	LET vsCodRastreo 		 	 	='';
	LET vsDescripcionSeguimiento 	='';
	LET vsstatusTo 				 	='';
	LET vsTipoSol				 	='';
	LET vsStatusG				 	='';

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
	BEGIN
	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsErrorActividad = 'ERROR ' || TRIM(vssqlerr) ||' ISAM '|| isam_err ||' INFORMIX '||TRIM(error_info) || ' EN sp_consultaSolicitudTkn';

		RETURN NVL(vssqlerr,''),
		NVL(vsErrorActividad,''),
		NVL(psSolicitud,''),
		NVL(vsF_solicitud,CAST(CURRENT::DATETIME YEAR TO SECOND AS CHAR(20))),
		NVL(vsF_atencion,CAST(CURRENT::DATETIME YEAR TO SECOND AS CHAR(20))),
		NVL(vsEstatus,''),
		NVL(vsNsToken,''),
		NVL(vsComentariosReporte,''),
		NVL(vsIdStatus,''),
		NVL(vsNumGuia,''),
		NVL(psNumCte,''),
		NVL(vsCodRastreo,''),
		NVL(vsDescripcionSeguimiento,''),
		NVL(psTipoConsulta,'');
	END EXCEPTION;

	--SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_consultaSolicitudTkn.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

		IF (NVL(psNumCte,'') = '')THEN
			LET vssqlerr = '00011';
			LET vsErrorActividad = 'EL PARAMETRO NUMERO DE CLIENTE ES INVALIDO';
		ELIF (NVL(psSolicitud,'') = '' AND psTipoConsulta == '1')THEN
			LET vssqlerr = '00009';
			LET vsErrorActividad = 'EL PARAMETRO NUMERO DE SOLICITUD ES INVALIDO';
		ELIF (NVL(psNsToken,'') = '' AND psTipoConsulta == '2')THEN
			LET vssqlerr = '00010';
			LET vsErrorActividad = 'EL PARAMETRO TOKEN ES INVALIDO';
		ELSE
			IF(psTipoConsulta == '1') THEN   -- CONSULTA POR NUMERO DE SOLICITUD
				IF EXISTS(SELECT id_status FROM bdibpi:"informix".bpi_tokensolicitud
					WHERE solicitud=psSolicitud AND numcte = psNumCte)THEN

					SELECT LIMIT 1 id_status, f_solicitud, f_atencion,tipo --, ns_token
					INTO vsIdStatus, vsF_solicitud, vsF_atencion,vsTipoSol --, vsNsToken
					FROM bdibpi:"informix".bpi_tokensolicitud
					WHERE solicitud = psSolicitud AND numcte = psNumCte;

					IF (vsIdStatus=='100')THEN
						IF NOT EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_bpitoken
							WHERE num_cliente=psNumCte AND id_status_token = vsIdStatus) THEN
							--LA INFORMACION SOLICITADA NO CORRESPONDE
							LET vssqlerr = '00002';
							LET vsErrorActividad = 'ERROR EN LA CONSULTA CON LA TABLA bdinteg:"informix".si_bpitoken';
						END IF;
					ELIF (vsIdStatus IN('200','220'))THEN
						SELECT 	ns_token,id_status_token 
						INTO vsNsToken,vsstatusTo
						FROM bdinteg:"informix".si_bpitoken
						WHERE num_cliente=psNumCte AND id_status_token IN ('140','150','151','152','160');
						
						IF (NVL(vsNsToken,'') <>'')THEN
							LET vsStatusG = vsstatusTo;
							--SE MUESTRAN LOS DATOS
						ELIF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_bpitokenhis
							WHERE num_cliente=psNumCte)THEN
							
							SELECT LIMIT 1 ns_token
							INTO vsNsToken
							FROM bdinteg:"informix".si_bpitokenhis
							WHERE num_cliente=psNumCte
							AND f_registro = (SELECT MAX(f_registro) AS FECHA
								FROM bdinteg:"informix".si_bpitokenhis
								WHERE num_cliente = psNumCte);
								
								LET vsStatusG = vsIdStatus;					
						ELSE
							--LA INFORMACION SOLICITADA NO CORRESPONDE
							LET vssqlerr = '00002';
							LET vsErrorActividad = 'ERROR EN LA CONSULTA CON LA TABLA bdinteg:"informix".si_bpitokenhis';
						END IF;
					ELIF(vsIdStatus IN ('110','120'))THEN
						--CONDICION SI ES TIPO 6 O 7 QUE NO HAGA NADA
						IF(vsTipoSol <> 6  AND vsTipoSol <> 7) THEN
							SELECT LIMIT 1 ns_token
							INTO vsNsToken
							FROM bdinteg:"informix".si_bpitoken
							WHERE num_cliente=psNumCte
							AND id_status_token = vsIdStatus;

							IF (NVL(vsNsToken,'') = '')THEN
								--LA INFORMACION SOLICITADA NO CORRESPONDE
								LET vssqlerr = '00002';
								LET vsErrorActividad = 'ERROR EN LA CONSULTA CON LA TABLA bdinteg:"informix".si_bpitoken';
							ELSE
								LET vsStatusG = vsIdStatus;
							END IF;									
						END IF;
					ELIF(vsIdStatus IN ('130'))THEN
						SELECT LIMIT 1 ns_token, id_status_token
						INTO vsNsToken, vsstatusTo
						FROM bdinteg:"informix".si_bpitoken
						WHERE num_cliente=psNumCte
						AND id_status_token in ('130','140','150','151','152','160','210');

						IF (NVL(vsNsToken,'') = '')THEN
							--LA INFORMACION SOLICITADA NO CORRESPONDE
							LET vssqlerr = '00002';
							LET vsErrorActividad = 'ERROR EN LA CONSULTA CON LA TABLA bdinteg:"informix".si_bpitoken';
						ELSE
							LET vsStatusG = vsstatusTo;
						END IF;
					ELIF(vsIdStatus =='199')THEN
						IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_bpitokenhis
							WHERE num_cliente = psNumCte)THEN

								LET vsStatusG = vsIdStatus;
								LET vsstatusTo = vsIdStatus;

								SELECT LIMIT 1 ns_token
								INTO vsNsToken
								FROM bdinteg:"informix".si_bpitokenhis
								WHERE num_cliente = psNumCte
								AND f_registro = (SELECT MAX(f_registro) AS FECHA
								FROM bdinteg:"informix".si_bpitokenhis
								WHERE num_cliente = psNumCte);
						ELSE
							--LA INFORMACION SOLICITADA NO CORRESPONDE
							LET vssqlerr = '00002';
							LET vsErrorActividad = 'ERROR EN LA CONSULTA CON LA TABLA bdinteg:"informix".si_bpitokenhis';
						END IF;
					END IF;

						SELECT LIMIT 1 num_guia
						INTO vsNumGuia
						FROM bdibpi:"informix".tkn_guias
						WHERE cte_destino MATCHES psNumCte
						AND f_registro = (SELECT  MAX(f_registro) as f_registro
						FROM bdibpi:"informix".tkn_guias
						WHERE cte_destino MATCHES psNumCte);

						IF (NVL(vsNumGuia,'') = '')THEN
							--SE MUESTRAN CODIGO DE RASTREO Y COMENTARIOS EN BLANCO
						ELSE
							SELECT LIMIT 1 cod_rastreo, comentarios
							INTO vsCodRastreo, vsComentariosReporte
							FROM bdibpi:"informix".tkn_envios
							WHERE num_guia = vsNumGuia;
							--SE MUESTRAN DATOS
						END IF;
				ELSE
					LET vssqlerr = '00001';
					LET vsErrorActividad = 'NO SE ENCONTRO LA SOLICITUD ' || psSolicitud || ' PARA EL CLIENTE ' || psNumCte;
					--EL NUMERO DE SOLICITUD NO CORRESPONDE A LA ASIGNACION DEL CLIENTE
				END IF;
			ELIF (psTipoConsulta == '2') THEN  -- CONSULTA POR NUMERO DE TOKEN

				LET vsNsToken = psNsToken;
				
				IF EXISTS(SELECT num_cliente
					FROM bdinteg:"informix".si_bpitoken
					WHERE ns_token = vsNsToken AND num_cliente = psNumCte)THEN

					SELECT id_status_token, f_status
					INTO vsIdStatusT, vsF_atencion
					FROM bdinteg:"informix".si_bpitoken
					WHERE ns_token = vsNsToken AND num_cliente = psNumCte;

					SELECT LIMIT 1 comentarios
					INTO vsComentariosReporte
					FROM bdibpi:"informix".tkn_reporte
					WHERE numcte MATCHES psNumCte
					AND fecstatus = (SELECT MAX(fecstatus)
					FROM bdibpi:"informix".tkn_reporte
					WHERE numcte MATCHES psNumCte);		
				ELIF EXISTS(SELECT num_cliente
					FROM bdinteg:"informix".si_bpitokenhis
					WHERE ns_token = vsNsToken AND num_cliente = psNumCte)THEN

					SELECT id_status_token, f_status
					INTO vsIdStatusT, vsF_atencion
					FROM bdinteg:"informix".si_bpitokenhis
					WHERE ns_token = vsNsToken AND num_cliente = psNumCte;
				ELIF EXISTS(SELECT numcte
					FROM bdibpi:"informix".bpi_tokensolicitud
					WHERE ns_token = vsNsToken AND numcte = psNumCte AND tipo IN(6,7)) THEN
					
					SELECT id_status, f_atencion
					INTO vsIdStatusT, vsF_atencion
					FROM bdibpi:"informix".bpi_tokensolicitud
					WHERE ns_token = vsNsToken 
					AND numcte = psNumCte 
					AND tipo IN(6,7);
					
					SELECT LIMIT 1 comentarios
					INTO vsComentariosReporte
					FROM bdibpi:"informix".tkn_reporte
					WHERE numcte MATCHES psNumCte
					AND fecstatus = (SELECT MAX(fecstatus)
					FROM bdibpi:"informix".tkn_reporte
					WHERE numcte MATCHES psNumCte);
					
					IF (vsIdStatusT IN ('110','120')) THEN
						LET vssqlerr = '00004';
						LET vsErrorActividad = 'REPOSICIÒN TIPO 6 o 7';
					END IF;
				ELSE
					--EL NUMERO NO CORRESPONDE A LA ASIGNACION DEL CLIENTE
					LET vssqlerr = '00001';
					LET vsErrorActividad = 'NO SE ENCONTRO EL TOKEN ' || psNsToken || ' PARA EL CLIENTE ' || psNumCte;
				END IF;
				
				
					
					IF vssqlerr IN ('00000','00004') THEN
						LET vsIdStatus = vsIdStatusT;
						LET vsStatusG = vsIdStatusT;

						SELECT LIMIT 1 env.cod_rastreo, env.comentarios
						INTO vsCodRastreo, vsComentariosReporte
						FROM bdibpi:"informix".tkn_envios env, bdibpi:"informix".bpi_tokensolicitud sol
						WHERE env.solicitud = sol.solicitud
						AND sol.ns_token = vsNsToken AND sol.numcte = psNumCte;
						--SE MUESTRAN DATOS

						END IF;
			
				
			ELSE
				LET vssqlerr = '00008';
				LET vsErrorActividad = 'ERROR EN EL PARAMETRO psTipoConsulta = ' || psTipoConsulta;
			END IF;
		
			IF (vssqlerr <> '00001') THEN
				SELECT LIMIT 1 desc_status
				INTO vsEstatus
				FROM bdinteg:"informix".si_bpistatus
				WHERE id_status = vsIdStatus;
			END IF;
		
			IF vssqlerr IN ('00000','00004') THEN
			
				IF (vsNsToken = '' AND vsstatusTo = '')THEN
					SELECT LIMIT 1 descripcion
					INTO vsDescripcionSeguimiento
					FROM bdibpi:"informix".tkn_catalogostatussol
					WHERE id_status=vsIdStatus;
				ELSE
					IF EXISTS(SELECT ns_token
						FROM bdibpi:"informix".tkn_nseries
						WHERE ns_token=vsNsToken AND id_status = vsStatusG) THEN
						--SE MUESTRAN LOS DATOS
						SELECT LIMIT 1 descripcion
						INTO vsDescripcionSeguimiento
						FROM bdibpi:"informix".tkn_catalogostatussol
						WHERE id_status=vsIdStatus;
					ELSE
						--LA INFORMACION SOLICITADA NO CORRESPONDE
						LET vssqlerr = '00003';
						LET vsErrorActividad = 'ERROR EN LA CONSULTA CON LA TABLA bdibpi:"informix".tkn_nseries';
					END IF;
				END IF;
			END IF;
		END IF;

		RETURN 	NVL(vssqlerr,''),
		NVL(vsErrorActividad,''),
		NVL(psSolicitud,''),
		NVL(vsF_solicitud,CAST(CURRENT::DATETIME YEAR TO SECOND AS CHAR(20))),
		NVL(vsF_atencion,CAST(CURRENT::DATETIME YEAR TO SECOND AS CHAR(20))),
		NVL(vsEstatus,''),
		NVL(vsNsToken,''),
		NVL(vsComentariosReporte,''),
		NVL(vsIdStatus,''),
		NVL(vsNumGuia,''),
		NVL(psNumCte,''),
		NVL(vsCodRastreo,''),
		NVL(vsDescripcionSeguimiento,''),
		NVL(psTipoConsulta,'');
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION:  CONSULTA DE SOLICITUDES Y ESTATUS TOKEN',
'AUTOR : Ing. Alfonso Cruz',
'FECHA : 01/02/2012',
'BD: bdibpi',
'SISTEMA : ICCAT BPI',
'MODIFICACION:  CAMBIO DE FLUJO EN LA CONSULTA DE SOLICITUDES Y ESTATUS TOKEN',
'AUTOR : Ing. Alfonso Cruz',
'FECHA : 23/03/2012',
'BD: bdibpi',
'SISTEMA : ICCAT, BPI',
'DESCRIPCION: Se agregaron condiciones para que traiga datos con los estatus 200,210,220 (renovado por vencimiento,renovado,cancelado por renovacion)',
'AUTOR : Jose Ruben Lopez',
'FECHA : 26/11/2013',
'BD: bdibpi',
'SISTEMA : ICCAT BPI',
'FOLIO: 1386',
'AUTOR: JOSE ANGEL GAXIOLA GAXIOLA',
'FECHA: 12/02/2014',
'MODIFICACION: Se agrega validacion en psTipoConsulta = "2" para cuando el token sea una reposicion se valide en la tabla: bpi_tokensolicitud', 
'			   Tambien se optimiza el SP generalizando codigo duplicado y borrando variables que no se utilizan.',
'SUSTENTO: Se definio por correo, esta plasmado en el cuerpo del correo enviado el dia Viernes 31 de Enero de 2014 10:53 a.m. enviado: ',
'          por VIRIDIANA ROSAS PESQUEIRA [mailto:vrosas@mailbancoppel.com]',
'SOLICITO: VIRIDIANA ROSAS.',
'BD: bdibpi',
'SISTEMA: ICCAT, BPI';

CREATE PROCEDURE "informix".sp_contareg_preg_bex(pNumCte char(20) ,pNumTel  char(20))
	RETURNING 	INTEGER, INTEGER;
--DEFINICION DE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE vSesion 		INTEGER;
DEFINE vEncuentado 	INTEGER;
DEFINE desPreg 		VARCHAR(200);
DEFINE iCont		INTEGER;
DEFINE iCont1		INTEGER;
DEFINE iSesion		INTEGER;

--INICIALIZACION DE VARIABLES
LET iSqlErr 	 = 0;
LET vSesion 	 = 0;
LET vEncuentado	 = 0;	
LET desPreg 	 = " ";
LET iCont 		 = 0;
LET iCont1 		 = 0;
LET iSesion		 = 0;	


--SET DEBUG FILE TO '/informix/ireb/bdibpi/sp_contareg_preg_bex2.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET vSesion = iSqlErr;			
			RETURN vSesion, vEncuentado;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pNumCte='' OR pNumTel= '' THEN
		LET iSesion	 = '';
		RETURN iSesion, vEncuentado;
	END IF
	
	IF NOT EXISTS(SELECT num_cliente FROM bpi_registro_bex WHERE num_cliente = pNumCte AND no_celular = pNumTel AND servicio='activo') THEN 
		LET iSesion	 = '';
		RETURN iSesion, vEncuentado;
	END IF 
		
	SELECT num_inicia_sesion, encuestado INTO vSesion, vEncuentado FROM bpi_reg_usuarioencuestados_bex where num_cte=pNumCte and num_tel=pNumTel;
	
	IF vSesion IS NULL THEN 
		LET vSesion = 0;
	END IF	
	
	IF vSesion > 0 THEN
		IF vSesion < 14 THEN
			
			LET iSesion = vSesion+1;
			
			IF iSesion = 13 AND vEncuentado = 0 THEN 
				UPDATE  bpi_reg_usuarioencuestados_bex SET encuestado=2,num_inicia_sesion=iSesion WHERE num_cte=pNumCte and num_tel=pNumTel;
			ELSE
				UPDATE  bpi_reg_usuarioencuestados_bex SET num_inicia_sesion=iSesion WHERE num_cte=pNumCte and num_tel=pNumTel;
			END IF
			
			SELECT num_inicia_sesion, encuestado into vSesion, vEncuentado FROM bpi_reg_usuarioencuestados_bex where num_cte=pNumCte and num_tel=pNumTel;
			
			RETURN vSesion, vEncuentado;
		END IF		
	ELSE
			LET iCont = iCont + 1;
			INSERT INTO bpi_reg_usuarioencuestados_bex(num_cte, num_tel, num_inicia_sesion, encuestado) VALUES(pNumCte,pNumTel,iCont,'0');
	END IF
	
	
	SELECT num_inicia_sesion, encuestado into vSesion, vEncuentado FROM bpi_reg_usuarioencuestados_bex where num_cte=pNumCte and num_tel=pNumTel;

RETURN vSesion, vEncuentado;
END;
END PROCEDURE;