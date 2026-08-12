CREATE PROCEDURE "informix".sp_depura_ctetel_invalido ( )

RETURNING CHAR(5) AS CodRetorno, 
		  CHAR(200) AS Mensaje;
		  
		  	  
--****************************************************************************************************
-- DESCRIPCION: Se depuran cliente de plataforma, con telefono invalido.
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
DEFINE pFecha             DATE;
DEFINE cMaxregistros      CHAR(6);
DEFINE cCompany           CHAR (100);
DEFINE valruta            INTEGER;
DEFINE vsDia              CHAR(2);
DEFINE vsMes 		      CHAR(2);
DEFINE vsAnio 		      CHAR(2);
DEFINE vsnumcte 	      CHAR (20);
DEFINE vsStmt1			  CHAR (500);
DEFINE viRegistros 		  INTEGER;
DEFINE vArch  			  INTEGER;
DEFINE vsNombreArchivo    CHAR(50);
DEFINE visam_error		  INTEGER;
DEFINE isam_error      	  INTEGER;
DEFINE vstelcom			  CHAR(13);
DEFINE vscorreocomp		  CHAR(100);
DEFINE vsfechacomp		  CHAR(10);
DEFINE vistatus			  INTEGER;


/* FIN DE DEFINICION DE VARIABLES*/
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET vdFechaHoy = today;
LET pFecha = today;
LET cMaxregistros = ' ';
LET cCompany = ' ';
LET valruta = 0;
LET vsDia = '';
LET vsMes = '';
LET vsAnio = '';
LET vsnumcte = ' ';
LET vsStmt1 = ' ';
LET viRegistros = 0;
LET vArch = 01;
LET vsNombreArchivo = '';
LET visam_error = 0;
LET isam_error = 0;
LET vsfechacomp = ' ';
LET vistatus = 0;

/*FIN DE INICIALIZACION*/

--SET DEBUG FILE TO "/tmp/MNSJR/sp_depura_ctetel_invalido.out";
--TRACE ON;
BEGIN

	ON EXCEPTION SET viSqlError,isam_error,vsMensaje
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET visam_error = isam_error;
				INSERT INTO bdimnsj:"informix".mnsj_errores (sql_error,isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_depura_ctetel_invalido', vdFechaHoy,CURRENT);
				
			RETURN vsCodRetorno, vsMensaje;


		END IF;
	END EXCEPTION;
	
	--Inicio de Proceso
	INSERT INTO bdimnsj:"informix".mnsj_procesos(proceso,fecha_proceso,status,user_insert,fecha_insert)
	VALUES('DEP_CTE',vdFechaHoy,vistatus,'informix',CURRENT);
	
	
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
		VALUES (vsCodRetorno,visam_error, vsMensaje, 'sp_depura_ctetel_invalido', vdFechaHoy,CURRENT);
		RETURN vsCodRetorno,vsMensaje;

	END IF;
	
	IF (vsCodRetorno='00000') THEN
				
		FOREACH
		
			select numcte INTO vsnumcte from bdinteg:si_telefonos_actual where cofetel = 'F'
			and status_tel = 'A' and empresa = '001' and tipo_tel = '2'

			--Nombre del archivo
			LET vsNombreArchivo = 'user-data-del-SUSCP' ||'_'|| NVL(vsDia,'01') || NVL(vsMes,'01') || NVL(vsAnio,'01') ||'_'|| vArch ||'.laedb';

			IF vsnumcte <> '' THEN

					LET vsStmt1 =  'DEL_USER'||'|'||trim(cCompany)||'|'||trim(vsnumcte);
					
					INSERT INTO bdimnsj:"informix".mnsj_susc_paso (linea)
					VALUES (vsStmt1);
					
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
		
			UPDATE "informix".mnsj_procesos set status = '1' WHERE proceso = 'DEP_CTE'
			and fecha_proceso = vdFechaHoy;
				
		END IF;		
	END IF;
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;