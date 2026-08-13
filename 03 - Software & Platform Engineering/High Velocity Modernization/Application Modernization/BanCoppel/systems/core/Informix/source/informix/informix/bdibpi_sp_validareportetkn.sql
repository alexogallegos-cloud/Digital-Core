CREATE PROCEDURE "informix".sp_validareportetkn( psNumCte CHAR(9))
	RETURNING CHAR (5) AS Retorno, 
	CHAR(150) AS errorActividad;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:verifica si hay reportes registrados 
	-- AUTOR :Jose Ruben Lopez
	-- FECHA :06/09/2013
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
	LET vdFec_alerta = CURRENT;
	LET viIdStatus = 0;
	LET vdFecstatus = CURRENT;
	
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsErrorActividad = 'ERROR ' || TRIM(vssqlerr) ||' ISAM '|| isam_err ||' INFORMIX '||TRIM(error_info) || ' EN sp_validareportetkn';
		
		RETURN 	NVL(vssqlerr,''),
				NVL(vsErrorActividad,'');
				
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/informix/ivonne/sp_validareportetkn.out';
	--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
		
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
			
			IF(vsNumCte IS NOT NULL OR vsNumCte <>"") THEN
				IF (vsNumCte = psNumCte)THEN 
					IF(viIdStatus = "1") THEN
						LET vssqlerr = '00001';
						LET vsErrorActividad = 'SOLICITUD: '|| TRIM(vsSolicitud) || ' CLIENTE: '|| TRIM(psNumCte)||' ESTATUS: 1 - YA SE HA GENERADO UN REPORTE Y ESTA SIENDO ATENDIDO';
					END IF;
					IF(viIdStatus = "3") THEN
						LET vssqlerr = '00003';
						LET vsErrorActividad = 'SOLICITUD: '|| TRIM(vsSolicitud) || ' CLIENTE: '|| TRIM(psNumCte)||' ESTATUS: 3 - SOLICITUD ESCALADA';
					END IF;
				END IF;
			END IF;
		
		
		
		RETURN 	NVL(vssqlerr,''),NVL(vsErrorActividad,'');
				
	END

END PROCEDURE;