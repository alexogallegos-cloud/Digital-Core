CREATE PROCEDURE "informix".sp_guardarreportetkn ( psNumCte CHAR(9) , psRegenerar CHAR(2),psValorTipo CHAR(1))
	RETURNING CHAR (5) AS Retorno, 
	CHAR(150) AS errorActividad;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  REPORTE DE SOLICITUDES Y ESTATUS TOKEN  
	-- AUTOR : Ing. Alfonso Cruz  
	-- FECHA : 03/02/2012  
	-- BD: bdibpi  
	-- SISTEMA : ICCAT  

	-- MODIFICACION: SE AGREGA PARAMETRO psRegenerar PARA VOLVER A LEVANTAR UN REPORTE UNA VEZ QUE HA ---
	-- SIDO CANCELADO  
	-- AUTOR : Ing. Alfonso Cruz  
	-- FECHA : 23/03/2012  
	-- BD: bdibpi  
	-- SISTEMA : ICCAT  
	
	-- MODIFICACION: SE AGREGA PARAMETRO PARA GUARDAR EL TIPO DE INCIDENCIA QUE SE GENERA  ---
	-- AUTOR :Jose Ruben Lopez
	-- FECHA : 23/03/2012  
	-- BD: bdibpi  
	-- SISTEMA : ICCAT  
	*****************************************************************************************************
	*/

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	
	DEFINE vsCodigoRetorno CHAR(5);
	
	DEFINE vsErrorActividad CHAR(150);
	DEFINE vsSolicitud CHAR(10);
	DEFINE vsSolicitudMax CHAR(10);
	DEFINE vsNumCte CHAR(9);
	DEFINE vsNombreCompleto CHAR(200);
	DEFINE vdFec_alerta DATE;
	DEFINE viIdStatus SMALLINT;
	DEFINE vdFecstatus DATE;
	
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	
	LET vsCodigoRetorno = '00000';
	
	LET vsErrorActividad ='';
	LET vsSolicitud = '';
	LET vsSolicitudMax = '';
	LET vsNumCte = '';
	LET vsNombreCompleto = '';
	LET vdFec_alerta = CURRENT;
	LET viIdStatus = 0;
	LET vdFecstatus = CURRENT;
	
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsErrorActividad = 'ERROR ' || TRIM(vssqlerr) ||' ISAM '|| isam_err ||' INFORMIX '||TRIM(error_info) || ' EN sp_guardarReporteTkn';
		
		RETURN 	NVL(vssqlerr,''),
				NVL(vsErrorActividad,'');
				
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/informix/ivonne/sp_guardarreportetkn.out';
	--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
		
		SELECT LIMIT 1 (TRIM(nombre1) ||' '
			|| TRIM(nombre2) ||' '
			|| TRIM(apell_paterno) ||' '
			|| TRIM(apell_materno)) AS NOMBRE
		INTO vsNombreCompleto
		FROM bdinteg:"informix".si_cliente
		WHERE numcte=psNumCte;
		
		IF(vsNombreCompleto IS NULL OR TRIM(vsNombreCompleto) = "") THEN
			LET vssqlerr = '00001';
			LET vsErrorActividad = ' CLIENTE: '|| TRIM(psNumCte) || ' - ERROR AL OBTENER EL NOMBRE DEL CLIENTE';
		ELSE
			SELECT MAX(solicitud)
			INTO vsSolicitudMax
			FROM bdibpi:"informix".tkn_reporte
			WHERE numcte=psNumCte;
			
			IF(vsSolicitudMax IS NULL OR vsSolicitudMax = "") THEN
				
				SELECT LIMIT 1 solicitud, numcte, fec_alerta, id_status, fecstatus
				INTO vsSolicitud, vsNumCte, vdFec_alerta, viIdStatus, vdFecstatus
				FROM bdibpi:"informix".tkn_reporte
				WHERE numcte=psNumCte;
			ELSE 
				
				SELECT LIMIT 1 solicitud, numcte, fec_alerta, id_status, fecstatus
				INTO vsSolicitud, vsNumCte, vdFec_alerta, viIdStatus, vdFecstatus
				FROM bdibpi:"informix".tkn_reporte
				WHERE numcte=psNumCte and solicitud = vsSolicitudMax;
				
			END IF;
			
			IF(vsNumCte IS NULL OR vsNumCte = "") THEN
				SELECT LPAD(TRIM(CAST((NVL(max(solicitud),0)::INTEGER+1) AS CHAR(10))),10,0) AS SOLICITUD
				INTO vsSolicitudMax
				FROM bdibpi:"informix".tkn_reporte;
			
				INSERT INTO bdibpi:"informix".tkn_reporte
					(solicitud, numcte, nombre, comentarios, fec_alerta, id_status, fecstatus, f_registro,tipo)
				VALUES (vsSolicitudMax,psNumCte,TRIM(vsNombreCompleto),'',current,1,current,current,psValorTipo);
				
			ELSE
				IF (vsNumCte = psNumCte)THEN 
					IF(viIdStatus = "1") THEN
						LET vssqlerr = '00002';
						LET vsErrorActividad = 'SOLICITUD: '|| TRIM(vsSolicitud) || ' CLIENTE: '|| TRIM(psNumCte)||' ESTATUS: 1 - YA SE HA GENERADO UN REPORTE Y ESTA SIENDO ATENDIDO';
					ELIF (viIdStatus = "2") THEN
						LET vssqlerr = '00003';
						LET vsErrorActividad = 'SOLICITUD: '|| TRIM(vsSolicitud) || ' CLIENTE: '|| TRIM(psNumCte)||' ESTATUS: 2 - SOLICITUD ATENDIDA';
					ELIF (viIdStatus = "3") THEN
						LET vssqlerr = '00004';
						LET vsErrorActividad = 'SOLICITUD: '|| TRIM(vsSolicitud) || ' CLIENTE: '|| TRIM(psNumCte)||' ESTATUS: 3 - SOLICITUD VENCIDA';
					ELIF (viIdStatus = "4") THEN
						IF(psRegenerar =="SI") THEN
							SELECT LPAD(TRIM(CAST((NVL(max(solicitud),0)::INTEGER+1) AS CHAR(10))),10,0) AS SOLICITUD
							INTO vsSolicitudMax
							FROM bdibpi:"informix".tkn_reporte;
						
							INSERT INTO bdibpi:"informix".tkn_reporte
								(solicitud, numcte, nombre, comentarios, fec_alerta, id_status, fecstatus, f_registro,tipo)
							VALUES (vsSolicitudMax,psNumCte,TRIM(vsNombreCompleto),'',current,1,current,current,psValorTipo);
						ELSE
							LET vssqlerr = '00005';
							LET vsErrorActividad = 'SOLICITUD: '|| TRIM(vsSolicitud) || ' CLIENTE: '|| TRIM(psNumCte)||' ESTATUS: 4 - EL REPORTE FUE CANCELADO POR EL AREA DE OPERACIONES';							
						END IF;

					ELSE
						
						LET vssqlerr = '00006';
						LET vsErrorActividad = 'SOLICITUD: '|| TRIM(vsSolicitud) || ' CLIENTE: '|| TRIM(psNumCte)||' ESTATUS: '|| viIdStatus ||' - ESTATUS INCORRECTO';
						
					END IF;
				ELSE 
					LET vssqlerr = '00007';
					LET vsErrorActividad = 'SOLICITUD: '|| TRIM(vsSolicitud) || ' CLIENTE: '|| TRIM(psNumCte)||' ESTATUS: '|| viIdStatus ||' - HAY UNA REPORTE PERO ASIGNADO AL CLIENTE '|| TRIM(vsNumCte);
				END IF;
			END IF;
		END IF;
		
		
		
		RETURN 	NVL(vssqlerr,''),
				NVL(vsErrorActividad,'');
				
	END

END PROCEDURE;