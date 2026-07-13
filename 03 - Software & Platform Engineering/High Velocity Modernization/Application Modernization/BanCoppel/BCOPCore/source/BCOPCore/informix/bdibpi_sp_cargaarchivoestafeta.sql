CREATE PROCEDURE "informix".sp_cargaarchivoestafeta(pArchivo CHAR(50))
	RETURNING 	CHAR(5); --cod retorno

--*********************************************
--Definición:	Se crea para cargar el archivo de estafeta en las tablas con comentarios.
--Autor: 		Walber Castro
--Fecha:		07 Febrero 2012
--*********************************************

DEFINE cCodret			CHAR(5);
DEFINE cSQL        		CHAR(350);
DEFINE cDirectorio 		CHAR(50);
DEFINE iSql_Err    		INTEGER;

DEFINE sCampo 			CHAR(500);
DEFINE iTamanio 		INT8;
DEFINE pos 				INT8;
DEFINE siguiente 		INT;
DEFINE caracter 		CHAR(50);
DEFINE v_guia 			CHAR(50);
DEFINE v_rastreo 		CHAR(15);
DEFINE v_status 		CHAR(15);
DEFINE v_fecha 			CHAR(10);
DEFINE v_comentarios 	CHAR(400);
DEFINE palabra 			CHAR(400);
DEFINE espacio 			CHAR(1);
DEFINE v_solicitud 		CHAR(10);
DEFINE v_numcte 		CHAR(9);
DEFINE v_transaccion 		CHAR(1);

LET cCodret 	=	'00000';
LET cSQL 		=	'';
LET cDirectorio	=	'';
LET sCampo		=	'';
LET iTamanio	=	0;
LET pos			=	1;
LET caracter	=	'';
LET v_guia		=	'';
LET v_rastreo	=	'';
LET siguiente	=	0;
LET v_status	=	'';
LET v_fecha		=	'';
LET v_comentarios = '';
LET palabra		=	'';
LET espacio		=	'0';
LET v_transaccion	=	'0';

--SET debug FILE TO "/tmp/manuel/sp_cargaarchivoestafeta.out";
--Trace ON;

BEGIN

	ON EXCEPTION SET iSql_Err
		LET cCodRet = iSql_Err;
		IF v_transaccion == '1' THEN
			ROLLBACK WORK;
			INSERT INTO bdibpi:"informix".bpi_tempcargarchivoestafeta_paso(campo) VALUES(cCodRet);
		END IF;
		RETURN cCodRet;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		COMMIT WORK;
		BEGIN WORK;
		LET v_transaccion = 1;
	END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
		
	 
	IF TRIM(NVL(pArchivo,'')) == '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet;
	ELSE
	
		DELETE FROM bdibpi:"informix".bpi_cargarchivoestafeta
		WHERE f_registro <= (SELECT fecha_hoy - 7 UNITS DAY FROM bdinteg:"informix".si_fechas);
	
		IF NOT EXISTS(SELECT dbsname FROM sysmaster:systabnames WHERE tabname = 'bpi_tempcargarchivoestafeta') THEN	
			CREATE TABLE bdibpi:"informix".bpi_tempcargarchivoestafeta
			(			
				campo CHAR(500)
			);		
		END IF;
		DELETE FROM bdibpi:"informix".bpi_tempcargarchivoestafeta;
		
		IF NOT EXISTS(SELECT dbsname FROM sysmaster:systabnames WHERE tabname = 'bpi_tempcargarchivoestafeta_paso') THEN	
			CREATE TABLE bdibpi:"informix".bpi_tempcargarchivoestafeta_paso
			(			
				campo CHAR(10)
			);		
		END IF;
		DELETE FROM bdibpi:"informix".bpi_tempcargarchivoestafeta_paso;
		
		SELECT LIMIT 1 valor
		INTO cDirectorio
		FROM bdibpi:"informix".tkn_parametros
		WHERE id_param='53';
		
		
		
		LET cSQL = '';
		LET cSQL = 'echo "LOAD FROM '||TRIM(cDirectorio)||TRIM(pArchivo)||' INSERT INTO bdibpi:"informix".bpi_tempcargarchivoestafeta;" > '||TRIM(cDirectorio)||'query.sql';
		LET cSQL = cSQL;
		SYSTEM cSQL;		
		
		LET cSQL = '';
		LET cSQL = '/informix/bin/dbaccess bdibpi < '||TRIM(cDirectorio)||'query.sql;';
		LET cSQL = cSQL;
		SYSTEM cSQL;		
		
		--BEGIN WORK;
		--LET v_transaccion = 1;
		IF v_transaccion == 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
			LET v_transaccion = 1;
		END IF;
		
		FOREACH        
			SELECT TRIM(campo), LENGTH(TRIM(campo))
			INTO sCampo, iTamanio
			FROM bdibpi:"informix".bpi_tempcargarchivoestafeta		
			
			IF iTamanio > 50 THEN
				
				WHILE siguiente < 5 AND pos <= iTamanio + 1 
					LET caracter = substr(sCampo,pos,1);
					IF caracter = '	' THEN
						IF siguiente == 0 THEN
							LET v_guia = palabra;
						ELIF siguiente == 1 THEN
							LET v_rastreo = palabra;
						ELIF siguiente == 2 THEN
							LET v_status = palabra;
						ELIF siguiente == 3 THEN
							LET v_fecha = palabra;
						ELIF siguiente == 4 THEN
							LET v_comentarios = palabra;
						END IF;
						
						LET siguiente = siguiente + 1;
						LET palabra = '';
					ELSE
						IF espacio == '1' THEN
							LET palabra = TRIM(palabra) || ' ' || TRIM(caracter);
						ELSE
							LET palabra = TRIM(palabra) || TRIM(caracter);
						END IF;
					END IF;
					IF caracter == ' ' THEN
						LET espacio = '1';
					ELSE 
						LET espacio = '0';
					END IF;
					LET pos = pos + 1;
				END WHILE;
				
				IF LENGTH(TRIM(v_guia)) >= 22 THEN					
					
					IF SUBSTR(v_fecha,7,4) == '1900' THEN
						LET v_fecha = '01-01-1900';
					ELSE						
						LET v_fecha = SUBSTR(v_fecha,4,2) ||'-' || SUBSTR(v_fecha,1,2)||'-'|| SUBSTR(v_fecha,7,4);
					END IF;
					
					INSERT INTO bdibpi:"informix".bpi_cargarchivoestafeta (numguia,codrastreo,id_status,f_entrega,comentarios)
					VALUES (v_guia, v_rastreo, v_status, v_fecha, v_comentarios);
					
					UPDATE bdibpi:"informix".tkn_envios SET comentarios = v_comentarios WHERE num_guia = v_guia;
					
					SELECT solicitud, numcte 
					INTO v_solicitud, v_numcte 
					FROM bdibpi:"informix".tkn_envios
					WHERE num_guia = v_guia;
					
					UPDATE bdibpi:"informix".bpi_tokensolicitud SET comentarios = v_comentarios WHERE solicitud = v_solicitud AND numcte = v_numcte;
				END IF;
			END IF;
			LET v_guia = '';
			LET v_rastreo = '';
			LET v_status = '';
			LET v_fecha = '';
			LET v_comentarios = '';
			LET caracter ='';
			LET pos = 1;
			LET siguiente = 0;
			LET sCampo = '';
			LET iTamanio = 0;
			LET palabra = '';
			LET espacio = '0';
		END FOREACH;
		
		DELETE FROM bdibpi:"informix".bpi_tempcargarchivoestafeta;
		
		INSERT INTO bdibpi:"informix".bpi_tempcargarchivoestafeta_paso(campo) VALUES(cCodRet);
		COMMIT WORK;
		RETURN cCodRet;
	END IF;
END;
END PROCEDURE;