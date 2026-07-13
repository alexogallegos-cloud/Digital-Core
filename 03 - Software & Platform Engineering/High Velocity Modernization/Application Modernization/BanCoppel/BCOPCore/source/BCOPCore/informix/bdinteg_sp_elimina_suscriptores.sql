CREATE PROCEDURE "informix".sp_elimina_suscriptores()
RETURNING CHAR(5) AS CodRetorno, 
		  CHAR(200) AS Mensaje;
		  

/*  DEFINICION DE VARIABLES */
DEFINE viSqlError         INTEGER;
DEFINE vsCodRetorno       CHAR (5);
DEFINE vsMensaje          CHAR(200);
DEFINE vdFechaHoy         DATE;
DEFINE pFecha             DATE;
DEFINE cMaxregistros      CHAR(6);
DEFINE vsDia              CHAR(2);
DEFINE vsMes 		      CHAR(2);
DEFINE vsAnio 		      CHAR(2);
DEFINE vsnumcte 	      CHAR (20);
DEFINE vsStmt1			  CHAR (500);
DEFINE vsStmt2			  CHAR (500);
DEFINE vsStmt3			  CHAR (500);
DEFINE vsStmt4			  CHAR (500);
DEFINE vsStmt5			  CHAR (500);
DEFINE vsStmt6			  CHAR (500);
DEFINE vsStmt7			  CHAR (500);
DEFINE vsStmt8			  CHAR (500);
DEFINE viRegistros 		  INTEGER;
DEFINE vArch  			  INTEGER;
DEFINE vsNombreArchivo    CHAR(50);
DEFINE visam_error		  INTEGER;
DEFINE isam_error      	  INTEGER;
DEFINE vsfechacomp		  CHAR(10);
DEFINE vscorreo			  CHAR(100);
DEFINE cCompany           CHAR (100);
DEFINE vsapaterno 	      CHAR(26);
DEFINE vsamaterno 	      CHAR(26);
DEFINE vsnombre1 	      CHAR(26);
DEFINE vsnombre2 	      CHAR(26);
DEFINE vsSexo 		      CHAR(26);
DEFINE vscarrier	   	  SMALLINT;
DEFINE vstelefono	      CHAR(13);

DEFINE vscarrier_nvo	   	  SMALLINT;
DEFINE vstelefono_nvo	      CHAR(13);

/* FIN DE DEFINICION DE VARIABLES*/
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET vdFechaHoy = today;
LET pFecha = today;
LET cMaxregistros = '100000';
LET vsDia = '';
LET vsMes = '';
LET vsAnio = '';
LET vsnumcte = ' ';
LET vsStmt1 = ' ';
LET vsStmt2 = ' ';
LET vsStmt3 = ' ';
LET vsStmt4 = ' ';
LET vsStmt5 = ' ';
LET vsStmt6 = ' ';
LET vsStmt7 = ' ';
LET vsStmt8 = ' ';
LET viRegistros = 0;
LET vArch = 01;
LET vsNombreArchivo = '';
LET visam_error = 0;
LET isam_error = 0;
LET vsfechacomp = ' ';
LET vscorreo ='';
LET cCompany ='';
LET vsapaterno ='';
LET vsamaterno='';
LET vsnombre1='';
LET vsnombre2='';
LET vsSexo='';
LET vscarrier=0;
LET vstelefono ='';

LET vscarrier_nvo=0;
LET vstelefono_nvo ='';

/*FIN DE INICIALIZACION*/

--SET DEBUG FILE TO "/informix/ragomez/sp_elimina_suscriptores.out";
--TRACE ON;

BEGIN
	
	--Obtiene fecha hoy
	LET vsDia =	substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),9,2);
	LET vsMes =	substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),6,2);
	LET vsAnio = substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),3,2);
	LET vdFechaHoy = pFecha;
	LET vsfechacomp = LPAD(YEAR(TODAY),4,'0')||'-'||LPAD(MONTH(TODAY),2,'0')||'-'||LPAD(DAY(TODAY),2,'0');

	--Obtiene el nombre de la compaÃÂ±ia
	select valor into cCompany from bdimnsj:"informix".mnsj_param
	where cod_param = '1' and empresa = '001';
	
	IF (vsCodRetorno='00000') THEN
				
				--Nombre del archivo
		LET vsNombreArchivo = 'user-data-EliminarSuscriptores'||'_'|| NVL(vsDia,'01') || NVL(vsMes,'01') || NVL(vsAnio,'01')||'_'|| vArch ||'.laedb';
		
		SET LOCK MODE TO WAIT 3;
		
		FOREACH	WITH HOLD
			
			
						
			select {+INDEX(si_telefonos_actual_resp "idx_si_telefonos_actual_resp_02")} LIMIT 100000  r.numcte, r.carrier, r.telefono
			INTO vsnumcte, vscarrier,vstelefono
			from si_telefonos_actual_resp as r
			where r.status_eliminado is null
					
			SELECT {+INDEX(si_telefonos_actual idx_telact_ctetipo)} a.carrier, a.telefono 
			into vscarrier_nvo,vstelefono_nvo
			from si_telefonos_actual as a
			where numcte = vsnumcte AND a.tipo_tel ='2';
			
			IF NVL(vstelefono_nvo,' ') = ' ' THEN
				select {+MULTI_INDEX(si_correos)} correo_elec
				into vscorreo
				from si_correos where valido ='1' and numcte = vsnumcte and status_correo ='A'
				and secuencia = (select {+MULTI_INDEX(si_correos)} max(secuencia) from si_correos where valido ='1'  and status_correo ='A');
				
				IF NVL(vscorreo,'') <> '' THEN
				
					/*SELECT {+AVOID_FULL(bdinteg:"informix".si_cliente)} numcte,apell_paterno,apell_materno,nombre1,nombre2
					INTO vsnumcte,vsapaterno,vsamaterno,vsnombre1,vsnombre2
					from bdinteg:"informix".si_cliente 
					where numcte = vsnumcte and tipo_cliente = '1' AND tpo_persona = tpo_persona;*/
					
					SELECT {+INDEX(bdinteg:"informix".si_cliente 224_479)} a.apell_paterno,a.apell_materno,a.nombre1,a.nombre2, b.sexo
					INTO vsapaterno,vsamaterno,vsnombre1,vsnombre2, vsSexo
					from bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b
					where a.numcte = vsnumcte AND b.numcte = a.numcte;

					
					/*SELECT {+INDEX(bdinteg:"informix".si_cliente 224_479)} a.apell_paterno,a.apell_materno,a.nombre1,a.nombre2
					INTO vsapaterno,vsamaterno,vsnombre1,vsnombre2
					from bdinteg:"informix".si_cliente a
					where a.numcte = vsnumcte;

					SELECT {+INDEX(bdinteg:"informix".si_ctepf 225_483)} a.sexo
					INTO vsSexo
					from bdinteg:"informix".si_ctepf a
					where a.numcte = vsnumcte;*/
					
					--select {+AVOID_FULL(si_ctepf )} sexo into vsSexo from si_ctepf where numcte = vsnumcte;
					
					
					LET vsStmt1 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'apell_pat' ||'='||trim(nvl(vsapaterno,''));
						INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
						VALUES (vsStmt1);
						
						LET vsStmt2 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'apell_mat' ||'='||trim(nvl(vsamaterno,''));
						INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
						VALUES (vsStmt2);
						
						LET vsStmt3 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'nombre1' ||'='||trim(nvl(vsnombre1,''));
						INSERT INTO bdimnsj:'informix'.mnsj_susc_paso (linea)
						VALUES (vsStmt3);
						
						LET vsStmt4 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'nombre2' ||'='||trim(nvl(vsnombre2,''));
						INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
						VALUES (vsStmt4);
						
						LET vsStmt5 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'email' ||'='||trim(nvl(vscorreo,''));
						INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
						VALUES (vsStmt5);
						
						LET vsStmt6 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'sexo' ||'='||trim(nvl(vsSexo,''));
						INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
						VALUES (vsStmt6);
						
						LET vsStmt7 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'carrier' ||'='||trim(nvl(vscarrier,''));
						INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
						VALUES (vsStmt7);
						
						LET viRegistros = viRegistros +1;
						
					UPDATE {+INDEX(bdinteg:"informix".si_telefonos_actual_resp "idx_si_telefonos_actual_resp_03")}si_telefonos_actual_resp 
					SET status_eliminado = '2', fecha_procesado = today
					WHERE numcte = vsnumcte and telefono = vstelefono;
						
					IF viRegistros = cMaxregistros THEN
						EXECUTE PROCEDURE bdimnsj:"informix".sp_generaarch(vsNombreArchivo) INTO vsCodRetorno;
							IF vsCodRetorno = '00000' THEN
								LET vArch = vArch +1;
								LET viRegistros = 0;
								
							ELSE
								INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
								VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_generaarch', vdFechaHoy,CURRENT);
								LET vsMensaje = 'Error en la generacion de archivo';

							END IF;		
					END IF;
				
				
				ELSE
				
					LET vsStmt1 =  'DEL_USER'||'|'||'BANCOPPEL'||'|'||trim(vsnumcte);
					INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
					VALUES (vsStmt1);
					
					
					LET viRegistros = viRegistros +1;
						
					UPDATE {+INDEX(bdinteg:"informix".si_telefonos_actual_resp "idx_si_telefonos_actual_resp_03")}si_telefonos_actual_resp 
					SET status_eliminado = '1', fecha_procesado = today
					WHERE numcte = vsnumcte and telefono = vstelefono;
						
					IF viRegistros = cMaxregistros THEN
						LET vArch = vArch +1;
						LET vsNombreArchivo = 'user-data-EliminarSuscriptores'||'_'|| NVL(vsDia,'01') || NVL(vsMes,'01') || NVL(vsAnio,'01')||'_'|| vArch ||'.laedb';
						EXECUTE PROCEDURE bdimnsj:"informix".sp_generaarch(vsNombreArchivo) INTO vsCodRetorno;
							IF vsCodRetorno = '00000' THEN
								
								LET viRegistros = 0;
							ELSE
								INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
								VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_generaarch', vdFechaHoy,CURRENT);
								LET vsMensaje = 'Error en la generacion de archivo';

							END IF;		
					END IF;
				END IF;
			ELSE 
			--LET viRegistros = viRegistros +1;
					
				UPDATE {+INDEX(bdinteg:"informix".si_telefonos_actual_resp "idx_si_telefonos_actual_resp_03")}si_telefonos_actual_resp 
				SET status_eliminado = '0', fecha_procesado = today
				WHERE numcte = vsnumcte and telefono = vstelefono;
			END IF;
		END FOREACH; 
		
		IF viRegistros > 0 THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_generaarch(vsNombreArchivo) INTO vsCodRetorno;
				IF vsCodRetorno <> '00000' THEN
					INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
					VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_generaarch', vdFechaHoy,CURRENT);
					LET vsMensaje = 'Error en la generacion de archivo';	
				END IF;
		END IF;
			
		IF vsCodRetorno = '00000' THEN
			LET vsMensaje  = 'REPORTE GENERADO CORRECTAMENTE';
		
			UPDATE bdimnsj:"informix".mnsj_procesos set status = '1' WHERE proceso = 'ELI_SUSC'
			and fecha_proceso = vdFechaHoy;				
		END IF;		
	END IF;
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;