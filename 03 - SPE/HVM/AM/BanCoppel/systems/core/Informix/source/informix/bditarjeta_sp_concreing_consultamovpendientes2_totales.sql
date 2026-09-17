CREATE PROCEDURE "informix".sp_concreing_consultamovpendientes2_totales (psCve_usuario CHAR(10), psFecha DATE)
        RETURNING CHAR (5) AS Retorno,
				INTEGER AS total_registros;

		DEFINE vsRetBitacora CHAR(5);
        DEFINE vsActividad VARCHAR(150);
		DEFINE viElemento INTEGER;
        DEFINE viNoRegistros INTEGER;
        DEFINE viCodigo INTEGER;
        DEFINE vssqlerr CHAR(5) ;
        DEFINE isam_err INT ;
        DEFINE error_info CHAR(70) ;

        LET  vsRetBitacora = '';
        LET vsActividad = '';
        LET viElemento = 40;
        LET viCodigo = 0;
        LET vssqlerr = '00000';
        LET isam_err = 0 ;
        LET error_info = '' ;
		LET viNoRegistros = 0;
		

        BEGIN

			ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
					LET vssqlerr = viCodigo;
					LET vsActividad = 'ERROR ' || NVL(vssqlerr,'') ||' ISAM '|| NVL(isam_err,0) ||' INFORMIX '||TRIM(NVL(error_info,'')) || ' EN sp_concreing_consultamovpendientes';
					EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
							

					RETURN NVL(vssqlerr,''), NVL(viNoRegistros,0);
			END EXCEPTION;

    --  SET DEBUG FILE TO "/RESPALDOSNEW/sp_concreing_consultamovpendientes2_totales.out";
    --  TRACE ON;
	
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;



			--CONSULTA QUE SE TRAE LOS REGISTROS PENDIENTES
			IF psCve_usuario NOT IN (SELECT cve_usuario 
									 FROM   bditarjeta:"informix".td_usuarios_conciliacion
								     WHERE  activo = 'V' AND operacion = 'V' AND monitoreo = 'V' )  THEN -- Usuarios con capacidad de modificar registros a su criterio
			

				-- Sftk Abril 2024
                SELECT COUNT(*)
				INTO viNoRegistros
	            FROM bditarjeta:td_movimientos_conciliacion   a,   bditarjeta:td_archivos_conciliacion b
				WHERE (a.integridad='F' OR a.conciliacion = 'F'     OR a.aplicacion =  'F') 
				AND a.nombrearchivo = b.nombrearchivo
				AND a.archivo_origen = b.archivo_origen
				AND b.fecha_archivo =   psFecha; 
				
				RETURN NVL(vssqlerr,''), NVL(viNoRegistros,0);
				
				/*SELECT COUNT(*)
				INTO viNoRegistros 
				FROM bditarjeta:td_movimientos_conciliacion     
				WHERE (integridad='F' OR conciliacion = 'F'     OR aplicacion =  'F') 
						   and nombrearchivo in (SELECT nombrearchivo 
																		 FROM bditarjeta:td_archivos_conciliacion  
																		 WHERE fecha_archivo = psFecha);*/
							
			ELSE
				-- Sftk Abril 2024
				SELECT COUNT(*)
				INTO viNoRegistros
				FROM  bditarjeta:td_movimientos_conciliacion   a,   bditarjeta:td_archivos_conciliacion b
				WHERE  (integridad='F' OR conciliacion = 'F'  OR aplicacion <> 'V')
				AND a.nombrearchivo = b.nombrearchivo
				AND a.archivo_origen = b.archivo_origen
				AND b.fecha_archivo =   psFecha
				AND a.archivo_origen IN ('VNC', 'VND', 'VID', 'VIC','MCC', 'MCD');				
				
									
				RETURN NVL(vssqlerr,''), NVL(viNoRegistros,0);
				
				/*SELECT COUNT(*)
				INTO viNoRegistros
				FROM bditarjeta:td_movimientos_conciliacion     
				WHERE (integridad='F' OR conciliacion = 'F'     OR aplicacion <> 'V') -- Se mostrar los registros hasta que estos sean reprocesados por el cron 3
						   and nombrearchivo in (SELECT nombrearchivo 
																		 FROM bditarjeta:td_archivos_conciliacion  
																		 WHERE fecha_archivo = psFecha)
						   and archivo_origen in ('VNC', 'VND', 'VID', 'VIC','MCC', 'MCD');*/
				
			END IF;
			
	END
END PROCEDURE
;