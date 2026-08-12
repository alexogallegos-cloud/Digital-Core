CREATE PROCEDURE "informix".sp_suscriptores ( )

RETURNING CHAR(5) AS CodRetorno, 
		  CHAR(200) AS Mensaje;
		  
		  	  
--****************************************************************************************************
-- DESCRIPCION: Generación de archivo de suscriptores.
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
DEFINE vdFechaHoy         DATETIME YEAR TO FRACTION(5);
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


/* FIN DE DEFINICION DE VARIABLES*/
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsCodRet1 = '00000';
LET vsCodRet2 = '00000';
LET vsMensaje = '';
LET vdFechaHoy = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
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
LET vsStmt8 = ' ';
LET viRegistros = 0;
LET vArch = 01;
LET vsNombreArchivo = '';
LET vsStatuscorreo = ' ';
LET vstipocorreo = 0;
LET vscorreo = ' ';
LET visam_error = 0;
LET isam_error = 0;
/*FIN DE INICIALIZACION*/

--SET DEBUG FILE TO "/tmp/MNSJR/sp_suscriptores.OUT";
--TRACE ON;
BEGIN

	ON EXCEPTION SET viSqlError,isam_error,vsMensaje
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET visam_error = isam_error;
				INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_suscriptores', vdFechaHoy,CURRENT);
			RETURN vsCodRetorno, vsMensaje;


		END IF;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--Obtiene maximo de registros
	select valor into cMaxregistros from bdimnsj:'informix'.mnsj_param
	where cod_param = '2' and empresa = '001';
	--Obtiene fecha hoy
	SELECT LIMIT 1 CAST(fecha_hoy AS DATETIME YEAR TO FRACTION(5)),
		substr(CAST(fecha_hoy AS DATETIME YEAR TO FRACTION(5)),9,2),
		substr(CAST(fecha_hoy AS DATETIME YEAR TO FRACTION(5)),6,2),
		substr(CAST(fecha_hoy AS DATETIME YEAR TO FRACTION(5)),3,2)
	INTO vdFechaHoy, vsDia, vsMes, vsAnio FROM bdinteg:"informix".si_fechas;
	
	--Obtiene el nombre de la compañia
	select valor into cCompany from bdimnsj:"informix".mnsj_param
	where cod_param = '1' and empresa = '001';
	
	--Valida que exista la ruta 
	select count (valor) into valruta from bdimnsj:"informix".mnsj_param WHERE cod_param = '3';
	IF valruta = 0 then
		LET vsCodRetorno = '99998';
		LET vsMensaje  = 'ERROR: LA RUTA DEPOSITO DEL ARCHIVO NO EXISTE, FAVOR DE VALIDAR.';
		INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
		VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_suscriptores', vdFechaHoy,CURRENT);
		RETURN vsCodRetorno,vsMensaje;
	END IF;
	
	IF (vsCodRetorno='00000') THEN
		
		FOREACH
		
			select cte.numcte,cte.apell_paterno,cte.apell_materno,cte.nombre1,cte.nombre2,pf.sexo
			--select  limit 100 cte.numcte,cte.apell_paterno,cte.apell_materno,cte.nombre1,cte.nombre2,pf.sexo			
			INTO vsnumcte,vsapaterno,vsamaterno,vsnombre1,vsnombre2,vsSexo
			from bdinteg:"informix".si_cliente cte  inner join
			bdinteg:"informix".si_ctepf as pf on cte.numcte = pf.numcte
			-- where cte.status_cte = 'AL' 
			--AND cte.tipo_cliente ='1'
			--and cte.numcte in (select numcte from bdinteg:"informix".si_telefonos_actual)
			
			--Nombre del archivo
			LET vsNombreArchivo = 'user-data-SUSCP' ||'_'|| NVL(vsDia,'01') || NVL(vsMes,'01') || NVL(vsAnio,'01') ||'_'|| vArch ||'.laedb';

			
			IF vsnumcte <> '' THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0") 
				INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
				
				
				IF vsCodRet1 <> '000' THEN
					LET vsCodRetorno = '00'||vsCodRet1;
					LET vsMensaje = 'Error al obtener telefono';
					INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
					VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_suscriptores', vdFechaHoy,CURRENT);
				END IF;
			
			
			
				EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
				INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;
				
			
				IF vsCodRet2 <> '000' THEN
					LET vsCodRetorno = '00'||vsCodRet2;
					LET vsMensaje = 'Error al obtener correo';
					INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
					VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_suscriptores', vdFechaHoy,CURRENT);
				END IF;
			END IF;
				
			IF (vscorreo IS NOT NULL OR vscorreo <> ' ') OR (vstelefono IS NOT NULL OR vstelefono <> ' ')  THEN
				
				INSERT INTO bdimnsj:"informix".mnsj_bitacora_susc (num_cte,telefono,correo,fecha,Codret1,Codret2)
				VALUES (vsnumcte,vstelefono,vscorreo,vdFechaHoy,vsCodRet1,vsCodRet2);
				
				LET vsStmt1 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'APELL_PAT' ||'='||trim(nvl(vsapaterno,''));
				INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
				VALUES (vsStmt1);
				
				LET vsStmt2 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'APELL_MAT' ||'='||trim(nvl(vsamaterno,''));
				INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
				VALUES (vsStmt2);
				
				LET vsStmt3 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'NOMBRE1' ||'='||trim(nvl(vsnombre1,''));
				INSERT INTO bdimnsj:'informix'.mnsj_susc_paso (linea)
				VALUES (vsStmt3);
				
				LET vsStmt4 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'NOMBRE2' ||'='||trim(nvl(vsnombre2,''));
				INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
				VALUES (vsStmt4);
				
				LET vsStmt5 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'EMAIL' ||'='||trim(nvl(vscorreo,''));
				INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
				VALUES (vsStmt5);
				
				LET vsStmt6 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'CELULAR' ||'='||trim(nvl(vstelefono,''));
				INSERT INTO bdimnsj:'informix'.mnsj_susc_paso (linea)
				VALUES (vsStmt6);
				
				LET vsStmt7 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'SEXO' ||'='||trim(nvl(vsSexo,''));
				INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
				VALUES (vsStmt7);
				
				LET vsStmt8 =  'SETALL_USER_PROPS'||'|'||trim(cCompany)||'|'||trim(vsnumcte)||'|'|| 'CARRIER' ||'='||trim(nvl(vscarrier,''));
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
		END IF;		
	END IF;
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;