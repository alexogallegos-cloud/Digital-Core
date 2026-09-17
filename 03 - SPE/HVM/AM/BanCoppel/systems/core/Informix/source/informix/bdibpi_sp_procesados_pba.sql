CREATE PROCEDURE "informix".sp_procesados_pba()
	returning char (5);


--Creado por: Javier Chávez
--Solicitado por: Mauricio León
--Actividad : obtiene números de guía de envíos de token
--Fecha: 	18/02/2010
--Modificación: Inserta a la tabla envios los datos necesarios
--Modificó: Javier Chávez
--Fecha: 10-03-2010
--Modificación: Se depura la tabla de tkn_guias_temporal
--Modificó: Arturo Cruz
--Fecha: 21-09-2010



--DECLARA VARIABLES
DEFINE sql_err integer;
DEFINE cod_ret char(5);
DEFINE vNombreArchivoError char (20);
DEFINE vDirectorio char(50);
DEFINE vsSQL char (900);
DEFINE vFechaHoy date;
DEFINE vDia char(2);
DEFINE vMes char(2);
DEFINE vAnio char(4);
DEFINE vFechaArchivo char(10);
DEFINE vFechaArchivo2 char(10);
DEFINE vNombreGuia char(26);
DEFINE vNumGuia char(30);
DEFINE vNumCte char (11);
DEFINE vLongGuia integer;
DEFINE vNombreBuscar char(14);
DEFINE vCodRet char (5);
DEFINE vCon char (1);
DEFINE vCont integer;
DEFINE vN integer;
DEFINE ciclo integer;
DEFINE vMaxima datetime year to second;
DEFINE vCod_rastreo char (15);
DEFINE vCte_destino char(15);
DEFINE vRazon_social char (20);
DEFINE vDestino char(50);
DEFINE vReferencia char (15);
DEFINE vPeso char (9);
DEFINE vContenido char(20);
DEFINE vCantidad char(6);
DEFINE vPeso_declarado char(1);
DEFINE vNombreError char(20);
DEFINE vCodRetError char(5);
DEFINE vTotal integer;
DEFINE vContador integer;
DEFINE vSolicitud char(10);
DEFINE vBatch datetime year to second;

--INICIA VARIABLES
LET vDirectorio = '';
LET cod_ret = '00010';
LET vSolicitud = '';
LET vNombreArchivoError = '';
LET vNumCte = '';
LET vCont = 0;
LET vN = 0;
LET vTotal = 0;
LET vContador = 0;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			IF sql_err = -668 THEN
				SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
				INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (sql_err,vBatch,'Error informix con el archivo',vBatch);
			ELSE
				SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
				INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (sql_err,vBatch,'Error Informix general',vBatch);
			END IF;
			RETURN cod_ret;
		END IF;
	END EXCEPTION;


	SET DEBUG FILE TO 'sp_procesados.trc';
	TRACE ON ;

	--Inserta en bitacora el inicio.
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
	INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (30,vBatch,'Inicio de proceso',vBatch);
	--Trae los datos necesarios
	LET vFechaHoy = current;
	LET vDia = LPAD(day(vFechaHoy),2,'0');
	LET vMes = LPAD(MONTH(vFechaHoy),2,'0');
	LET vAnio = YEAR(vFechaHoy);
	LET vFechaArchivo2 = vAnio||LPAD(vMes,2,'0')||LPAD(vDia,2,'0');
	LET vFechaArchivo = vAnio||'-'||LPAD(vMes,2,'0')||'-'||LPAD(vDia,2,'0');

	SELECT valor INTO vDirectorio FROM tkn_parametros WHERE id_param = '14';
	SELECT valor INTO vNombreArchivoError FROM tkn_parametros WHERE id_param = '22';

	LET vNombreBuscar = TRIM(vFechaArchivo2)||'.txt';
        DELETE FROM  tkn_errores_temporal;
        DELETE FROM  tkn_guias_temporal;
	EXECUTE PROCEDURE sp_token_buscararchivo(TRIM(vDirectorio), TRIM(vNombreBuscar)) INTO vCodRet, vCon,vCont;

	  IF (vCodRet = '00000') THEN
		IF (vCon = 'V') THEN

					FOR ciclo = 1 TO vCont
							LET vN = vN + 1;
							LET vContador = 0;
							SELECT valor INTO vNombreGuia FROM tkn_parametros WHERE id_param = '23';
							IF (vNombreGuia <> '' OR vNombreGuia IS NOT NULL ) THEN
								LET vNombreGuia = 'MANIFIESTO'||vN||'_'||TRIM(vFechaArchivo2)||'.txt';
								UPDATE tkn_parametros SET
									valor = vNombreGuia
								WHERE id_param = '23';

							END IF;

							--CREA ARCHIOVO DE INSTRUCCION DE CARGA
							LET vsSQL = 'echo "LOAD FROM '''|| TRIM(vDirectorio) ||  TRIM(vNombreGuia) || "'" || ' DELIMITER '','' INSERT INTO tkn_guias_temporal" > ' || TRIM(vDirectorio) ||  'load_archivo.sql';
							SYSTEM vsSQL;

							--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
							LET vsSQL = 'dbaccess bdibpi ' || TRIM(vDirectorio) ||  'load_archivo.sql';
							SYSTEM vsSQL;

							LET vsSQL = 'rm ' || TRIM(vDirectorio) || 'load_archivo.sql';
							SYSTEM vsSQL;

							SELECT COUNT(*) INTO vTotal FROM tkn_guias_temporal;
							FOREACH

								SELECT num_guia,cod_rastreo,cte_destino,razon_social,destino,referencia,peso,contenido,cantidad,peso_declarado INTO vNumGuia,vCod_rastreo,vNumCte,vRazon_social,vDestino,vReferencia,vPeso,vContenido,vCantidad,vPeso_declarado FROM tkn_guias_temporal
								LET vLongGuia = LENGTH(vNumGuia)-2;
								LET vNumGuia = substring(TRIM(vNumGuia) FROM 2 FOR (vLongGuia));
								LET vNumCte = substring(TRIM(vNumCte) FROM 2 FOR (LENGTH(vNumCte)-2));
								LET vContador = vContador + 1;

							IF (vContador <> vTotal) THEN
								IF(vLongGuia < 30) THEN
								  IF(vNumCte <> '' OR vNumCte IS NOT NULL)THEN
									IF EXISTS(SELECT cte_destino FROM tkn_guias WHERE cte_destino = vNumCte) THEN

											SELECT MAX(f_registro) INTO vMaxima FROM tkn_guias WHERE cte_destino = vNumCte;
											UPDATE tkn_guias SET
												num_guia = vNumGuia
											WHERE cte_destino = vNumCte AND f_registro = vMaxima;

										IF EXISTS (SELECT numcte FROM tkn_envios WHERE numcte = vNumCte) THEN
											SELECT MAX(f_registro) INTO vMaxima FROM tkn_envios WHERE numcte = vNumCte;
											UPDATE tkn_envios SET
												num_guia = vNumGuia,
												num_envio = num_envio + 1,
												id_status = 110
											WHERE numcte = vNumCte AND f_registro = vMaxima;

											LET cod_ret = '00000';

										ELSE
											SELECT solicitud INTO vSolicitud FROM bpi_tokensolicitud WHERE numcte = vNumCte AND f_solicitud = (SELECT MAX(f_solicitud) FROM bpi_tokensolicitud WHERE numcte = vNumCte);
											IF (vSolicitud <> '' OR vSolicitud IS NOT NULL) THEN
													INSERT INTO tkn_envios(solicitud,num_envio,id_status,comentarios,f_envio,f_registro,num_guia,numcte) VALUES(vSolicitud,1,110,'','1900-01-01 00:00:00',current,vNumGuia,vNumCte);
													LET cod_ret = '00000';
											ELSE
													SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
													INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (31,vBatch,'No existe el cliente '||vNumCte||' con solicitudes',vBatch);
													INSERT INTO tkn_errores_temporal(num_guia, cod_rastreo, cte_destino,razon_social,destino,referencia,peso,contenido,cantidad,peso_declarado) VALUES(vNumGuia,vCod_rastreo,vNumCte,vRazon_social,vDestino,vReferencia,vPeso,vContenido,vCantidad,vPeso_declarado);
											END IF;
										END IF;
									ELSE
										SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
										INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (31,vBatch,'No existe el cliente '||vNumCte||' en la tabla guias',vBatch);
										INSERT INTO tkn_errores_temporal(num_guia, cod_rastreo, cte_destino,razon_social,destino,referencia,peso,contenido,cantidad,peso_declarado) VALUES(vNumGuia,vCod_rastreo,vNumCte,vRazon_social,vDestino,vReferencia,vPeso,vContenido,vCantidad,vPeso_declarado);
									END IF;
								 END IF;
								ELSE
									SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
									INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (31,vBatch,'La Guia '||NVL(vNumGuia," ")||' no cumplio con la longitud',vBatch);
									LET vBatch=vBatch;
									LET vNumGuia= vNumGuia;
									INSERT INTO tkn_errores_temporal(num_guia, cod_rastreo, cte_destino,razon_social,destino,referencia,peso,contenido,cantidad,peso_declarado) VALUES(vNumGuia,vCod_rastreo,vNumCte,vRazon_social,vDestino,vReferencia,vPeso,vContenido,vCantidad,vPeso_declarado);
								END IF;
							ELSE
								EXIT FOREACH;
							END IF;
							END FOREACH;
						DELETE FROM tkn_guias_temporal;
				END FOR;
			ELSE
				SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
				INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (31,vBatch,'sin archivos por validar',vBatch);
				LET cod_ret = '00002';
			END IF;
		ELSE
			SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
			INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (31,vBatch,'sin archivos por validar',vBatch);
			LET cod_ret = '00001';
		END IF;

                LET vCont = 0;
		SELECT LIMIT 1 num_guia INTO vNumGuia FROM tkn_errores_temporal;

		IF (vNumGuia <> '' OR vNumGuia IS NOT NULL) THEN
			SELECT COUNT(*), valor INTO vCont, vNombreError FROM  tkn_parametros WHERE id_param = '22' GROUP BY valor;
                        LET vNombreError = 'ERROR' || TRIM(vFechaArchivo) || '.txt';

                         IF(vCont <> 0) THEN
                                UPDATE tkn_parametros SET valor = vNombreError WHERE id_param = '22';				
                         ELSE
				INSERT INTO tkn_parametros VALUES('22',vNombreError,'Nombre Archivo de Error','2010-01-01 00:00:00','9999-01-01 00:00:00');
                         END IF;
			
			IF (cod_ret <> '00001' AND cod_ret <> '00002') THEN
				EXECUTE PROCEDURE sp_Errores() INTO vCodRetError;
			END IF;
		END IF;

		
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO SECOND INTO vBatch FROM sysmaster:sysshmvals;
	INSERT INTO tkn_batch (id_proceso,f_proceso,descripcion,f_registro) VALUES (32,vBatch,'Fin de proceso',vBatch);
	return cod_ret;

END
END PROCEDURE;