CREATE PROCEDURE "informix".sp_suscriptores_act_xfecha (pFecha DATE )

RETURNING CHAR(5) AS CodRetorno, 
		  CHAR(200) AS Mensaje;
		  
		  	  
--****************************************************************************************************
-- DESCRIPCION: Generación de actualización de suscriptores.
-- SOLICITA: Jaime Gonzalez Prado
-- AUTOR : Angel Rene de la Llave
-- FECHA : 17/05/2012
-- BD: bdimnsj
-- SISTEMA : Mensajeria y Alerta de eventos.
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE viSqlError         INTEGER;
DEFINE vsCodRetorno       CHAR (5);
DEFINE vsMensaje          CHAR(200);
DEFINE vdFechaHoy         DATE;
DEFINE cMaxregistros      CHAR(6);
DEFINE cCompany           CHAR (100);
DEFINE valruta            INTEGER;
DEFINE vsDia              CHAR(2);
DEFINE vsMes 		      CHAR(2);
DEFINE vsAnio 		      CHAR(2);
DEFINE cMax 		      CHAR(10);
DEFINE vsnumcte 	      CHAR (20);
DEFINE vsapaterno 	      CHAR(26);
DEFINE vsamaterno 	      CHAR(26);
DEFINE vsnombre1 	      CHAR(26);
DEFINE vsnombre2 	      CHAR(26);
DEFINE vsSexo 		      CHAR(26);
DEFINE vstelefono	      CHAR(13);
DEFINE vstipotel 	      SMALLINT;
DEFINE vsSecuencia        SMALLINT;
DEFINE vsStatustel	      CHAR(1);
DEFINE vsextension 	   	  CHAR(5);
DEFINE vscarrier	   	  SMALLINT;
DEFINE vsnombrecarrier 	  CHAR(20);
DEFINE vsStatusvalidacion SMALLINT;
DEFINE vscorreo			  CHAR(100);
DEFINE vstipocorreo		  SMALLINT;
DEFINE vsStatuscorreo     CHAR(1);
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
DEFINE vsCodRet1		  CHAR(5);
DEFINE vsCodRet2		  CHAR(5);
DEFINE isam_error      	  INTEGER;
DEFINE vstelcom			  CHAR(13);
DEFINE vscorreocomp		  CHAR(100);
DEFINE vsfechacomp		  CHAR(10);
DEFINE vistatus			  INTEGER;
DEFINE vcofetel			  CHAR(1);


/* FIN DE DEFINICION DE VARIABLES*/
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsCodRet1 = '00000';
LET vsCodRet2 = '00000';
LET vsMensaje = '';
LET vdFechaHoy = today;
LET cMaxregistros = ' ';
LET cCompany = ' ';
LET valruta = 0;
LET vsDia = '';
LET vsMes = '';
LET vsAnio = '';
LET cMax = ' ';
LET vsnumcte = ' ';
LET vsapaterno = ' ';
LET vsamaterno = ' ';
LET vsnombre1 = ' ';
LET vsnombre2 = ' ';
LET vsSexo = ' ';
LET vstelefono        = '';
LET vstipotel         = 0;
LET vsStatustel      = '';
LET vsextension       = '';
LET vscarrier         = 0;
LET vsnombrecarrier   = '';
LET vsStatusvalidacion = 0;
LET vsSecuencia       = 0;
LET vsStmt1 = ' ';
LET vsStmt2 = ' ';
LET vsStmt3 = ' ';
LET vsStmt4 = ' ';
LET vsStmt5 = ' ';
LET vsStmt6 = ' ';
LET vsStmt7 = ' ';
LET vsStmt7 = ' ';
LET vsStmt8 = ' ';
LET viRegistros = 0;
LET vArch = 01;
LET vsNombreArchivo = '';
LET vsStatuscorreo = ' ';
LET vstipocorreo = 0;
LET vscorreo = ' ';
LET visam_error = 0;
LET isam_error = 0;
LET vstelcom = ' ';
LET vscorreocomp = ' ';
LET vsfechacomp = ' ';
LET vistatus = 0;
LET vcofetel = ' ';
/*FIN DE INICIALIZACION*/

--SET DEBUG FILE TO "/tmp/MNSJR/sp_suscriptores_act_xfecha.out";
--TRACE ON;
BEGIN

	ON EXCEPTION SET viSqlError,isam_error,vsMensaje
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET visam_error = isam_error;
				INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_suscriptores_act_xfecha', pFecha,CURRENT);
			RETURN vsCodRetorno, vsMensaje;


		END IF;
	END EXCEPTION;
	
	--Inicio de Proceso
	INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
	VALUES('ACTXF_SUSC',pFecha,vistatus,'informix',CURRENT);
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--Obtiene maximo de registros
	select valor into cMaxregistros from bdimnsj:'informix'.mnsj_param
	where cod_param = '2' and empresa = '001';
	--Obtiene fecha hoy
	--SELECT LIMIT 1 CAST(fecha_hoy AS DATETIME YEAR TO FRACTION(5)),
	LET vsDia =	substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),9,2);
	LET vsMes =	substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),6,2);
	LET vsAnio = substr(CAST(pFecha AS DATETIME YEAR TO FRACTION(5)),3,2);
	LET vdFechaHoy = pFecha;
	LET vsfechacomp = '20'||vsAnio||'-'||vsMes||'-'||vsDia;
	
	
	--Obtiene el nombre de la compañia
	select valor into cCompany from bdimnsj:"informix".mnsj_param
	where cod_param = '1' and empresa = '001';
	
	--Valida que exista la ruta 
	select count (valor) into valruta from bdimnsj:"informix".mnsj_param WHERE cod_param = '3';
	IF valruta = 0 then
		LET vsCodRetorno = '99998';
		LET vsMensaje  = 'ERROR: LA RUTA DEPOSITO DEL ARCHIVO NO EXISTE, FAVOR DE VALIDAR.';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_suscriptores_act_xfecha', vdFechaHoy,CURRENT);
		RETURN vsCodRetorno,vsMensaje;
	END IF;
	
	IF (vsCodRetorno='00000') THEN
				
		FOREACH
			select cte.numcte,cte.apell_paterno,cte.apell_materno,cte.nombre1,cte.nombre2,pf.sexo
			    INTO vsnumcte,vsapaterno,vsamaterno,vsnombre1,vsnombre2,vsSexo
				from bdinteg:"informix".si_cliente cte  inner join
				bdinteg:"informix".si_ctepf as pf on cte.numcte = pf.numcte		
				where cte.status_cte = 'AL' and cte.fecha_insert = vdFechaHoy
			union
			select  cte.numcte,cte.apell_paterno,cte.apell_materno,cte.nombre1,cte.nombre2,pf.sexo
				from bdinteg:"informix".si_cliente cte  inner join
				bdinteg:"informix".si_ctepf as pf on cte.numcte = pf.numcte
				inner join bdinteg:"informix".si_correos as co on cte.numcte = co.numcte
				where cte.status_cte = 'AL' and co.status_correo ='A' and substr(co.fecha_hora,1,10)= vsfechacomp
			union
			select  cte.numcte,cte.apell_paterno,cte.apell_materno,cte.nombre1,cte.nombre2,pf.sexo
				from bdinteg:"informix".si_cliente cte  inner join
				bdinteg:"informix".si_ctepf as pf on cte.numcte = pf.numcte
				inner join bdinteg:"informix".si_telefonos_actual as tel on cte.numcte = tel.numcte
				where cte.status_cte = 'AL' and tel.tipo_tel = 2 and substr(tel.fecha_hora,1,10)= vsfechacomp

			
			--Nombre del archivo
			LET vsNombreArchivo = 'user-data-SUSCP' ||'_'|| NVL(vsDia,'01') || NVL(vsMes,'01') || NVL(vsAnio,'01') ||'_'|| vArch ||'.laedb';

			IF vsnumcte <> '' THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0") 
				INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
				
				SELECT cofetel into vcofetel from bdinteg:"informix".si_telefonos_actual WHERE numcte = vsnumcte AND telefono = vstelefono and tipo_tel = '2';
				
				IF vsCodRet1 <> '000' THEN
					LET vsCodRetorno = '00'||vsCodRet1;
					LET vsMensaje = 'Error al obtener telefono';
					INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
					VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_suscriptores_act_xfecha', vdFechaHoy,CURRENT);
                    CONTINUE FOREACH;
				END IF;
			
				--EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
				--INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;
				/*IF vsCodRet2 <> '000' THEN
					LET vsCodRetorno = '00'||vsCodRet2;
					LET vsMensaje = 'Error al obtener correo';
					INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
					VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_suscriptores_act_xfecha', vdFechaHoy,CURRENT);
                    CONTINUE FOREACH;
				END IF;*/
				
				select first 1 correo_elec into vscorreo from bdinteg:"informix".si_correos where numcte=vsnumcte and status_correo='A';
				
				
			END IF;
			
				IF vscorreo IS NOT NULL OR (vstelefono IS NOT NULL AND vcofetel = 'V') THEN
					
					INSERT INTO bdimnsj:"informix".mnsj_bitacora_susc (num_cte,telefono,correo,fecha,Codret1,Codret2)
					VALUES (vsnumcte,vstelefono,vscorreo,vdFechaHoy,vsCodRet1,vsCodRet2);
					
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
					
					LET vsStmt6 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'celular' ||'='||trim(nvl(vstelefono,''));
					INSERT INTO bdimnsj:'informix'.mnsj_susc_paso (linea)
					VALUES (vsStmt6);
					
					LET vsStmt7 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'sexo' ||'='||trim(nvl(vsSexo,''));
					INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
					VALUES (vsStmt7);
					
					LET vsStmt8 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'carrier' ||'='||trim(nvl(vscarrier,''));
					INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
					VALUES (vsStmt8);
					
					LET viRegistros = viRegistros +1;
					
				END IF;
					
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
		UPDATE "informix".mnsj_procesos set status = '1' WHERE proceso = 'ACTXF_SUSC'
		and fecha_proceso = vdFechaHoy;
		END IF;		
	END IF;
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;