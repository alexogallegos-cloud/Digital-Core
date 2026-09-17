CREATE PROCEDURE "informix".sp_cargarsurtidotarcop( psEmpleado VARCHAR(8), psEmpresa VARCHAR(3), psNomArchivo VARCHAR(15) )

RETURNING VARCHAR(5) AS CodRetorno, VARCHAR(200) AS Mensaje, VARCHAR(20) AS Arch_Intercambio;

--****************************************************************************************************
-- DESCRIPCION: Carga a una tabla el contenido de un archivo de surtido de tarjetas coppel, procesa el surtido y genera un archivo de salida con el estatus de cada envio de tarjetas del surtido.
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 30/01/2009
-- BD: bdiTarCop
-- SISTEMA : Inventario de Tarjetas Caja Unica.
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsNomArchivo CHAR (15);
DEFINE vsNomArchivo2 CHAR (15);
DEFINE vsFlagSoloNumeros CHAR (1);

DEFINE vsTipoSurtido CHAR(2) ;
DEFINE vsEmpresa CHAR(3) ;
DEFINE vsCveSucursal CHAR(4) ;
DEFINE vsTipoTarjeta CHAR(1) ;
DEFINE viNumEnvio INTEGER;
DEFINE dtFechaSurt DATETIME YEAR TO FRACTION(5);
DEFINE viCantidadRec INTEGER;
DEFINE viRangoIni INTEGER;
DEFINE viRangoFin INTEGER;
DEFINE vsNumGuia CHAR(25);
DEFINE dtFechaGuia DATETIME YEAR TO FRACTION(5);
DEFINE vsCodRespuesta CHAR (5);

DEFINE viTotalRegistros INTEGER;

DEFINE vsRepositorio CHAR (90);
DEFINE vsSQL CHAR (1300) ;
DEFINE vsSQL1 CHAR (150);
DEFINE vsSQL2 CHAR (1000) ;
DEFINE vsSQL3 CHAR (150) ;

DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER ;

DEFINE vsFlagSystem CHAR (1);

DEFINE viSqlError INTEGER;
DEFINE vsCodRetorno CHAR (5);
DEFINE vsMensaje CHAR(200);

DEFINE Arch_Intercambio VARCHAR(20);


/* INICIALIZACION DE VARIABLES */
LET vsNomArchivo = '';
LET vsNomArchivo2 = '';
LET vsFlagSoloNumeros = '';

LET vsTipoSurtido = '';
LET vsEmpresa = '';
LET vsCveSucursal = '';
LET vsTipoTarjeta = '';
LET viNumEnvio = 0;
LET dtFechaSurt = CURRENT;
LET viCantidadRec = 0;
LET viRangoIni = 0;
LET viRangoFin = 0;
LET vsNumGuia = '';
LET dtFechaGuia = CURRENT;
LET vsCodRespuesta = '';

LET viTotalRegistros = 0;

LET vsRepositorio = '';
LET vsSQL = '' ;
LET vsSQL1 = '' ;
LET vsSQL2 = '' ;
LET vsSQL3 = '' ;

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

LET vsFlagSystem = '';

LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';

LET Arch_Intercambio = '';

BEGIN

  ON EXCEPTION SET viSqlError    --cacha el error en caso de que exista y regresa un valor predeterminado

		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			ROLLBACK WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;

		LET vsCodRetorno = viSqlError;

		IF (vsFlagSystem = '1') THEN -- ERROR DE CARGA DEl ARCHIVO DE SURTIDO
			LET vsCodRetorno = '00927';
			IF (vsCodRetorno = '00927') THEN
				LET vsNomArchivo2 = 'C' || SUBSTR(psNomArchivo, 2, 14); --RESPUESTA DIRECTA DEL ARCHIVO QUE SE ESTA TRABAJANDO.
				--GENERA EL ARCHIVO DE INTERCAMBIO
				LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) || '/' || TRIM (vsNomArchivo2) || ' DELIMITER ' || '''?''';

				LET vsSQL2 = "SELECT FIRST 1 'ERROR DE CARGA DEL ARCHIVO DE SURTIDO VERIFIQUE'"
					|| "FROM BdiTarjCop:paraminvtarcop";

				LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || '/' || TRIM(vsNomArchivo2);
				LET vsSQL1 = TRIM(vsSQL1);
				LET vsSQL3 = TRIM(vsSQL3);

				LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
				IF ( vsSQL <> '' ) THEN
					SYSTEM vsSQL ;
				ELSE -- CONSULTA VACIA
					LET vsCodRetorno = '00900';
				END IF;
			END IF;

		ELIF (vsFlagSystem = '2') THEN -- ERROR DE GENERACION DE ARCHIVO DE RESPUESTA DE SURTIDO
			LET vsCodRetorno = '00928';
		END IF;

		--GUARDA  REGISTRO DE LA OPERACION EN LA BITACORA
		INSERT INTO bdiTarjCop:"informix".BitacoraTarCop (Empleado, Fecha, Actividad, NomArchivo, CodRetorno) VALUES (psEmpleado, CURRENT, 'CARGAR SURTIDO', psNomArchivo, vsCodRetorno);

		SELECT FIRST 1 mensaje INTO vsMensaje FROM bditarjcop:"informix".mensajestarcop WHERE codmensaje = vsCodRetorno;

		IF((vsMensaje = '') OR (vsMensaje IS NULL))THEN
			LET vsMensaje = 'ERROR DE INFORMIX';
		END IF;

		RETURN vsCodRetorno, vsMensaje, vsNomArchivo2;

    END EXCEPTION;

	--SET DEBUG FILE TO "/dbexport/ALTAUNICA/INVENTARIO/cargarsurt.SQL";
	--TRACE ON;
    --set explain on;

	--SET LOCK MODE TO WAIT 3;
	--SET ISOLATION TO DIRTY READ;
	--EXECUTE PROCEDURE BdiTarjCop:"informix".sp_EsNumerico (psEmpleado) INTO vsFlagSoloNumeros;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF (LENGTH ( TRIM(psNomArchivo)) < 15 ) OR ((LENGTH ( TRIM(psNomArchivo)) > 15 )) THEN --EL NOMBRE DEL ARCHIVO NO POSEE LA EXTENCION CORRESPONDIENTE
		LET vsCodRetorno = '00908';
	ELIF ((SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 1 FOR 1) <> 'S') AND (SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 1 FOR 1) <> 'G')) THEN -- NO ES ARCHIVO DE SURTIDO
		LET vsCodRetorno = '00907';
	ELIF (SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 12 FOR 4) <> '.DAT') THEN -- NO ES ARCHIVO DE EXTENCION DAT
		LET vsCodRetorno = '00906';

	ELIF (TRIM(psEmpleado) = '') THEN  -- DEBE DE CONTENER UN USUARIO
		LET vsCodRetorno = '00930';


	/*ELIF ( vsFlagSoloNumeros <> 'V' ) THEN --VALIDA QUE EL NUMERO DE EMPLEADO CONTENGA UNICAMENTE NUMEROS
		LET vsCodRetorno = '00905';
	ELIF (LENGTH (TRIM(psEmpleado)) < 8) THEN  -- ERROR DE LONGITUD DEL NUMERO DE EMPLEADO.
		LET vsCodRetorno = '00904';
	ELIF (psEmpleado < 90000000) THEN  -- EL NUMERO PROPORCIONADO NO CORRESPONDE CON EL FORMATO DE EMPLEADO COPPEL
		LET vsCodRetorno = '00929';
	*/

	ELIF NOT EXISTS (SELECT Empresa FROM BdiTarjCop:"informix".InventarioTarCop WHERE Empresa = psEmpresa ) THEN  --NO EXISTE LA EMPRESA PROPORCIONADA
		LET vsCodRetorno = '00903';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTarjCop:"informix".ParamInvTarCop WHERE Descripcion = "REPOSITORIO AIX" AND Empresa = psEmpresa ) THEN --NO EXISTE EL REPOSITORIO DEL ARCHIVO DE INTERCAMBIO
		LET vsCodRetorno = '00902';
	ELIF EXISTS ( SELECT NomArchivo FROM BdiTarjCop:"informix".BitacoraTarCop WHERE NomArchivo = psNomArchivo AND CodRetorno = '00000') THEN --CHECA QUE EL ARCHIVO NO FUE PROCESADO ANTERIORMENTE.
		LET vsCodRetorno = '00901';
	ELSE
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT FIRST 1  Valor INTO vsRepositorio FROM BdiTarjCop:"informix".ParamInvTarCop WHERE Descripcion = "REPOSITORIO AIX" AND Empresa = psEmpresa ;

		--VALIDA SI EXISTE LA TABLA DE SURTIDO
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		IF EXISTS ( SELECT dbsname, tabname FROM sysmaster :"informix".SysTabNames  WHERE tabname = 'surtido' AND dbsname= 'bditarjcop') THEN
			DROP TABLE bditarjcop:"informix".Surtido;
		END IF;

		--CREA LA TABLA DE SURTIDO
		CREATE TABLE BdiTarjCop:"informix".Surtido(
			TipoSurtido CHAR (2),
			Empresa CHAR(3),
			CveSucursal CHAR(4),
			TipoTarjeta CHAR(1),
			NumEnvio INTEGER,
			FechaSurt DATETIME YEAR TO FRACTION(5),
			CantidadRec INTEGER,
			RangoIni INTEGER,
			RangoFin INTEGER,
			NumGuia CHAR(25),
			FechaGuia DATETIME YEAR TO FRACTION(5)
		);

		--CARGA EL CONTENIDO DEL ARCHIVO EN LA TABLA TEMPORAL.
		--CREA ARCHIVO DE INSTRUCCION DE CARGA.
		LET vsFlagSystem = '1';

		LET vsSQL = 'echo "LOAD FROM '''|| TRIM(vsRepositorio) || '/' || TRIM(psNomArchivo) || "'" || ' INSERT INTO bdiTarjCop:Surtido" > ' || TRIM(vsRepositorio) ||  '/load_archivo.sql';
		SYSTEM vsSQL;

		--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
		LET vsSQL = '' ;
		LET vsSQL = 'chmod 666 ' || TRIM(vsRepositorio) ||  '/load_archivo.sql';
		SYSTEM vsSQL;
		LET vsSQL = '' ;
		LET vsSQL = 'dbaccess BdiTarjCop ' || TRIM(vsRepositorio) ||  '/load_archivo.sql';
		SYSTEM vsSQL;
		--BORRA EL ARCHIVO
		LET vsSQL = '' ;
		LET vsSQL = 'rm ' || TRIM(vsRepositorio) || '/load_archivo.sql' ;
		SYSTEM vsSQL ;

		LET vsFlagSystem = '';

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		IF NOT EXISTS (SELECT TipoTarjeta FROM BdiTarjCop:"informix".Surtido WHERE CveSucursal < 1 ) THEN --NO EXISTE EL REGISTRO DE CONTROL DEL ARCHIVO DE SURTIDO
			LET vsCodRetorno = '00909';
		ELSE

			--AGREGA LA COLUMNA QUE CORRESPONDE AL CODIGO DE RESPUESTA DEL REGISTRO DEL ENVIO EN PARTICULAR
			ALTER TABLE BdiTarjCop:"informix".Surtido ADD CodRespuesta CHAR (5) DEFAULT '' ;

			--OBTIENE EL REGISTRO DE CONTROL DEL ARCHIVO DE SURTIDO ( SUCURSAL 0 )
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT LIMIT 1 TipoSurtido, Empresa, LPAD (TRIM(CveSucursal), 4, '0'), TipoTarjeta, NumEnvio, FechaSurt, CantidadRec, RangoIni, RangoFin, TRIM(NumGuia), FechaGuia
					INTO vsTipoSurtido, vsEmpresa, vsCveSucursal, vsTipoTarjeta, viNumEnvio, dtFechaSurt, viCantidadRec, viRangoIni, viRangoFin, vsNumGuia, dtFechaGuia
					FROM BdiTarjCop:"informix".Surtido WHERE CveSucursal < 1 ;


			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT COUNT (CveSucursal) INTO viTotalRegistros FROM BdiTarjCop:"informix".Surtido WHERE CveSucursal > 1 ;

			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			-- VERIFICA LOS TOTALE DEL REGISTRO DE CONTROL CON LOS CONTENIDOS EN EL ARCHIVO DE SURTIDO
			IF EXISTS (SELECT CveSucursal FROM BdiTarjCop:"informix".Surtido WHERE CveSucursal < 1 AND NumEnvio <> (SELECT (COUNT (Surt.CveSucursal) - 1) FROM BdiTarjCop:"informix".Surtido AS Surt) ) THEN --EL TOTAL DE REGISTROS DEL ARCHIVO DE SURTIDO NO CORRESPONDE CON LOS INDICADOS EN EL REGISTRO DE CONTROL
				LET vsCodRetorno = '00910';
			ELIF EXISTS (SELECT CveSucursal FROM BdiTarjCop:"informix".Surtido WHERE CveSucursal < 1 AND CantidadRec <> (SELECT (COUNT (Surt.CveSucursal) ) FROM BdiTarjCop:"informix".Surtido AS Surt WHERE TRIM (Surt.NumGuia) <> '' AND CveSucursal > 0 )) THEN --EL TOTAL DE REGISTROS CON NUMERO DE GUIA DEL ARCHIVO DE SURTIDO NO CORRESPONDE CON LOS INDICADOS EN EL REGISTRO DE CONTROL
				LET vsCodRetorno = '00911';
			ELIF EXISTS (SELECT CveSucursal FROM BdiTarjCop:"informix".Surtido WHERE CveSucursal < 1 AND RangoIni <> (SELECT COUNT (Surt.CveSucursal)  FROM BdiTarjCop:"informix".Surtido AS Surt WHERE Surt.TipoTarjeta = 'N') ) THEN --EL TOTAL DE REGISTROS DE TARJETAS NUMERADAS DEL ARCHIVO DE SURTIDO NO CORRESPONDE CON LOS INDICADOS EN EL REGISTRO DE CONTROL
				LET vsCodRetorno = '00912';
			ELIF EXISTS (SELECT CveSucursal FROM BdiTarjCop:"informix".Surtido WHERE CveSucursal < 1 AND RangoFin <> (SELECT COUNT (Surt.CveSucursal)  FROM BdiTarjCop:"informix".Surtido AS Surt WHERE Surt.TipoTarjeta = 'R') ) THEN --EL TOTAL DE REGISTROS DE TARJETAS DE REPOSICION DEL ARCHIVO DE SURTIDO NO CORRESPONDE CON LOS INDICADOS EN EL REGISTRO DE CONTROL
				LET vsCodRetorno = '00913';
			ELSE
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;

				--VALIDA LOS DATOS DE LOS REGISTROS DEL SURTIDO.
				-- INDICA SI ALGUN SURTIDO ESTA DIRIGIDO A UNA EMPRESA NO REGISTRADA
				UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00914' WHERE CveSucursal > 0 AND Empresa NOT IN (SELECT Empresa FROM BdiTarjCop:"informix".InventarioTarCop);

				--INDICA SI ALGUN SURTIDO ESTA DIRIGIDO A UNA SUCURSAL QUE NO EXISTE
				UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00915' WHERE CveSucursal > 0 AND LPAD (TRIM(CveSucursal), 4, '0') NOT IN (SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica) AND CodRespuesta = '';

				--INDICA SI ALGUN SURTIDO ESTA DIRIGIDO A UNA SUCURSAL QUE NO TENGA LA OPCION DE CAJA UNICA ACTIVA
				--APR UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00916' WHERE CveSucursal > 0 AND LPAD (TRIM(CveSucursal), 4, '0') NOT IN (SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE CajaUnica = 'V') AND CodRespuesta = '';

				--INDICA SI ALGUN SURTIDO NO CORRESPONDE CON EL TIPO DE TARJETA NUMERADA O DE REPOSICION
				UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00917' WHERE CveSucursal > 0 AND TipoTarjeta NOT IN ( 'N', 'R') AND CodRespuesta = '';

				--INDICA SI ALGUN SURTIDO NO CONTIENE NUMERO DE ENVIO
				UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00918' WHERE CveSucursal > 0 AND NumEnvio < 1 AND CodRespuesta = '';

				--INDICA SI ALGUN SURTIDO NO CONTIENE LA CANTIDAD DE TARJETAS DEL ENVIO
				UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00919' WHERE CveSucursal > 0 AND CantidadRec < 1 AND CodRespuesta = '';

				--INDICA SI ALGUN SURTIDO NO CONTIENE EL RANGO INICIAL DE LAS TARJETAS
				UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00920' WHERE CveSucursal > 0 AND RangoIni < 1 AND CodRespuesta = '';

				--INDICA SI ALGUN SURTIDO NO CONTIENE EL RANGO FINAL DE LAS TARJETAS
				UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00921' WHERE CveSucursal > 0 AND RangoFin < 1 AND CodRespuesta = '';

				--INDICA SI ALGUN SURTIDO POSEE ANORMALIDADES EN LOS RANGOS DE LAS TARJETAS
				UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00922' WHERE CveSucursal > 0 AND RangoIni > RangoFin  AND CodRespuesta = '';

				--INDICA SI EN UN SURTIDO NO CORRESPONDEN LA CANTIDAD DE TARJETAS INDICADAS POR LOS RANGOS INICIAL Y FINAL CON LA CANTIDAD INDICADA POR EL CAMPO CANTIDADREC
				UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00923' WHERE CveSucursal > 0 AND CantidadRec <> (RangoFin - (RangoIni - 1)) AND CodRespuesta = '';

				--INDICA SI ALGUN SURTIDO NO CORRESPONDE CON EL TIPO DE  SURTIDO ESTABLECIDO
				UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00924' WHERE CveSucursal > 0 AND TipoSurtido NOT IN ( 'SA', 'SE') AND CodRespuesta = '';

				--OBTIENE TODOS LOS REGISTROS DE LA TABLA DESURTIDO
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				FOREACH WITH HOLD SELECT TipoSurtido, Empresa, LPAD (TRIM(CveSucursal), 4, '0'), TipoTarjeta, NumEnvio, FechaSurt, CantidadRec, RangoIni, RangoFin, TRIM(NumGuia), FechaGuia
						INTO vsTipoSurtido, vsEmpresa, vsCveSucursal, vsTipoTarjeta, viNumEnvio, dtFechaSurt, viCantidadRec, viRangoIni, viRangoFin, vsNumGuia, dtFechaGuia
						FROM BdiTarjCop:"informix".Surtido WHERE CveSucursal > 0 AND CodRespuesta = ''

					--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
					IF (vsFlagEnTransaccion = 'F') THEN
						 BEGIN WORK;
						 LET vsFlagEnTransaccion = 'V';
					END IF;

					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					--VALIDA QUE EL ENVIO NO ESTE REGISTRADO  EXACTAMENTE IGUAL PREVIAMENTE
					IF EXISTS(SELECT CveSucursal FROM bditarjcop:"informix".enviostarcop WHERE TipoSurtido = vsTipoSurtido AND Empresa = vsEmpresa AND CveSucursal = vsCveSucursal AND NumEnvio = viNumEnvio
						AND TipoTarjeta = vsTipoTarjeta AND CantidadRec = viCantidadRec AND RangoIni = viRangoIni AND RangoFin = viRangoFin AND TRIM(NumGuia) = vsNumGuia AND FechaGuia = dtFechaGuia ) THEN

						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						-- AGREGA EL CODIGO DE ERROR DE ENVIO DUPLICADO
						UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00925' WHERE TipoSurtido = vsTipoSurtido AND Empresa = vsEmpresa AND LPAD (TRIM(CveSucursal), 4, '0') = vsCveSucursal AND NumEnvio = viNumEnvio
							AND TipoTarjeta = vsTipoTarjeta AND CantidadRec = viCantidadRec AND RangoIni = viRangoIni AND RangoFin = viRangoFin AND TRIM(NumGuia) = vsNumGuia AND FechaGuia = dtFechaGuia ;

					END IF;

					LET viContadorRegistros = viContadorRegistros + 1;

					--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
					IF (viContadorRegistros = 10000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
						COMMIT WORK;
						LET vsFlagEnTransaccion = 'F';
						LET viContadorRegistros = 0;
						CONTINUE FOREACH;
					END IF;

				END FOREACH ;

				-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
				IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
					COMMIT WORK;
					LET vsFlagEnTransaccion = 'F';
				END IF;

				LET viContadorRegistros = 0;

				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				-- VALIDA SI EXISTE ALGUN REGISTRO DE SURTIDO CON ERROR
				/*IF EXISTS (SELECT CodRespuesta FROM BdiTarjCop:"informix".Surtido WHERE CodRespuesta <> '') THEN --RESGITROS DE SURTIDO CON ERROR, ARCHIVO RECHAZADO
					UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00000' WHERE CodRespuesta = '' AND CveSucursal > 0 ;
					LET vsCodRetorno = '00926';
				ELSE*/
					UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = '00000' WHERE CodRespuesta = '' AND CveSucursal > 0;					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					--OBTIENE TODOS LOS REGISTROS DE LA TABLA DE SURTIDO
					SET ISOLATION TO DIRTY READ;
					FOREACH WITH HOLD SELECT TipoSurtido, Empresa, LPAD (TRIM(CveSucursal), 4, '0'), TipoTarjeta, NumEnvio, FechaSurt, CantidadRec, RangoIni, RangoFin, TRIM(NVL (NumGuia, '')), NVL (FechaGuia, '1900-01-01 00:00:00')
							INTO vsTipoSurtido, vsEmpresa, vsCveSucursal, vsTipoTarjeta, viNumEnvio, dtFechaSurt, viCantidadRec, viRangoIni, viRangoFin, vsNumGuia, dtFechaGuia
							--FROM BdiTarjCop:"informix".Surtido WHERE CveSucursal > 0
							FROM BdiTarjCop:"informix".Surtido WHERE CveSucursal > 0 AND CodRespuesta = '00000'

							--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
							IF (vsFlagEnTransaccion = 'F') THEN
								 BEGIN WORK;
								 LET vsFlagEnTransaccion = 'V';
							END IF;

							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							EXECUTE PROCEDURE BdiTarjCop:"informix".sp_RegistrarNuevoLoteTarjCop(vsTipoSurtido, vsEmpresa, vsCveSucursal, vsTipoTarjeta, viNumEnvio, dtFechaSurt, viCantidadRec, viRangoIni, viRangoFin, vsNumGuia, dtFechaGuia ) INTO vsCodRespuesta ;

							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							UPDATE BdiTarjCop:"informix".Surtido SET CodRespuesta = vsCodRespuesta WHERE TipoSurtido = vsTipoSurtido AND Empresa = vsEmpresa AND LPAD (TRIM(CveSucursal), 4, '0') = vsCveSucursal
								AND TipoTarjeta = vsTipoTarjeta AND NumEnvio = viNumEnvio AND FechaSurt = dtFechaSurt AND CantidadRec = viCantidadRec
								AND RangoIni = viRangoIni AND RangoFin = viRangoFin AND TRIM(NVL (NumGuia, '')) = vsNumGuia AND NVL (FechaGuia, '1900-01-01 00:00:00') = dtFechaGuia;

							LET viContadorRegistros = viContadorRegistros + 1;

							--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
							IF (viContadorRegistros = 10000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
								COMMIT WORK;
								LET vsFlagEnTransaccion = 'F';
								LET viContadorRegistros = 0;
								CONTINUE FOREACH;
							END IF;

					END FOREACH ;

					-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
					IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
						COMMIT WORK;
						LET vsFlagEnTransaccion = 'F';
					END IF;

					LET viContadorRegistros = 0;

				--END IF;

				--GENERA EL NOMBRE DEL ARCHIVO DE INTERCAMBIO  cAAAAMMDD##.DAT
				LET vsNomArchivo = 'temporal.txt';
				LET vsNomArchivo2 = 'C' || SUBSTR(psNomArchivo, 2, 14); --RESPUESTA DIRECTA DEL ARCHIVO QUE SE ESTA TRABAJANDO.
				--LET vsNomArchivo2 = 'C' || REPLACE (SUBSTRING (CURRENT FROM 1 FOR 10), '-', '' ) ||  SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 10 FOR 2) || '.dat';

				--GENERA EL ARCHIVO DE INTERCAMBIO
				LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) || '/' || TRIM (vsNomArchivo) || ' DELIMITER ' || '''?''';

				LET vsSQL2 = "SELECT ('00'||'|'||'001'||'|'||'0000'||'|'||'E'||'|'||0||'|'|| SUBSTRING (CURRENT FROM 1 FOR 19)||'|'||0||'|'|| "
				|| "(SELECT COUNT (CveSucursal) FROM BdiTarjCop:Surtido WHERE TipoTarjeta = 'N' )::INTEGER ||'|'|| "
				|| "(SELECT COUNT (CveSucursal) FROM BdiTarjCop:Surtido WHERE TipoTarjeta = 'R' )::INTEGER ||'|'|| "
				|| "'0'||'|'|| SUBSTRING (CURRENT FROM 1 FOR 19) ||'|'|| '"|| vsCodRetorno ||"' ||'|'|| 'TOTALES')  FROM BdiTarjCop:Surtido WHERE LPAD (TRIM(CveSucursal), 4, '0') = '0000' "
				|| "UNION SELECT TipoSurtido||'|'|| Empresa||'|'|| LPAD (CveSucursal, 4, '0')||'|'|| TipoTarjeta||'|'|| NumEnvio||'|'|| "
				|| "SUBSTRING (FechaSurt FROM 1 FOR 19)||'|'|| CantidadRec||'|'|| RangoIni::INTEGER||'|'|| RangoFin::INTEGER||'|'|| TRIM(NVL(NumGuia,'')) ||'|'||SUBSTRING (FechaGuia FROM 1 FOR 19)||'|'|| "
				|| "CodRespuesta ||'|'|| (SELECT TRIM(MENSAJE) FROM BditarjCop:MensajesTarCop AS Men1 WHERE Surt.CodRespuesta = Men1.CodMensaje) "
				|| "FROM BdiTarjCop:Surtido AS Surt  WHERE CodRespuesta <> '' AND CveSucursal > 0";

				LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || '/control_reporte.sql';

				LET vsSQL1 = TRIM(vsSQL1);
				LET vsSQL3 = TRIM(vsSQL3);

				LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

				--CHECA QUE NO ESTE VACIA LA CONSULTA
				IF ( vsSQL <> '' ) THEN
					LET vsFlagSystem = '2';
					SYSTEM vsSQL ;
					LET vsSQL = '' ;
					LET vsSQL = 'chmod 666 ' || TRIM(vsRepositorio) || '/control_reporte.sql' ;
					SYSTEM vsSQL ;
					LET vsSQL = '' ;
					LET vsSQL = 'dbaccess BdiTarjCop ' || TRIM(vsRepositorio) || '/control_reporte.sql' ;
					SYSTEM vsSQL ;
					--BORRA EL ARCHIVO DE CONTROL
					LET vsSQL = '' ;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || '/control_reporte.sql' ;
					SYSTEM vsSQL ;

					--Elimina el caracter delimitardor '?'.
					LET vsSQL = '' ;
					LET vsSQL =  "sed 's/?$//g' " || TRIM(vsRepositorio) || '/' || TRIM (vsNomArchivo) || " > " || TRIM(vsRepositorio) || '/' ||
					TRIM (vsNomArchivo2);
					SYSTEM vsSQL;

					--Borra el archivo temporal.
					LET vsSQL = '' ;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || '/' || TRIM (vsNomArchivo);
					SYSTEM vsSQL ;

					LET vsFlagSystem = '';

				ELSE -- CONSULTA VACIA
					LET vsCodRetorno = '00900';
				END IF;

				--ELIMINA LA TABLA TEMPORAL DE SURTIDOS
				DROP TABLE  BdiTarjCop:"informix".Surtido;

			END IF;
			IF (vsCodRetorno IN ('00910','00911','00912','00913')) THEN
				--GENERA EL NOMBRE DEL ARCHIVO DE INTERCAMBIO  cAAAAMMDD##.DAT
				LET vsNomArchivo = 'temporal.txt';
				LET vsNomArchivo2 = 'C' || SUBSTR(psNomArchivo, 2, 14); --RESPUESTA DIRECTA DEL ARCHIVO QUE SE ESTA TRABAJANDO.
				--LET vsNomArchivo2 = 'C' || REPLACE (SUBSTRING (CURRENT FROM 1 FOR 10), '-', '' ) ||  SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 10 FOR 2) || '.dat';

				--GENERA EL ARCHIVO DE INTERCAMBIO
				LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) || '/' || TRIM (vsNomArchivo) || ' DELIMITER ' || '''?''';

				LET vsSQL2 = "SELECT TRIM(MENSAJE)"
					|| "FROM BditarjCop:MensajesTarCop WHERE codmensaje = '"||vsCodRetorno||"'";

				LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || '/control_reporte.sql';

				LET vsSQL1 = TRIM(vsSQL1);
				LET vsSQL3 = TRIM(vsSQL3);

				LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

				--CHECA QUE NO ESTE VACIA LA CONSULTA
				IF ( vsSQL <> '' ) THEN
					LET vsFlagSystem = '2';
					SYSTEM vsSQL ;
					LET vsSQL = '' ;
					LET vsSQL = 'chmod 666 ' || TRIM(vsRepositorio) || '/control_reporte.sql' ;
					SYSTEM vsSQL ;
					LET vsSQL = '' ;
					LET vsSQL = 'dbaccess BdiTarjCop ' || TRIM(vsRepositorio) || '/control_reporte.sql' ;
					SYSTEM vsSQL ;
					--BORRA EL ARCHIVO DE CONTROL
					LET vsSQL = '' ;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || '/control_reporte.sql' ;
					SYSTEM vsSQL ;

					--Elimina el caracter delimitardor '?'.
					LET vsSQL = '' ;
					LET vsSQL =  "sed 's/?$//g' " || TRIM(vsRepositorio) || '/' || TRIM (vsNomArchivo) || " > " || TRIM(vsRepositorio) || '/' ||
					TRIM (vsNomArchivo2);
					SYSTEM vsSQL;

					--Borra el archivo temporal.
					LET vsSQL = '' ;
					LET vsSQL = 'rm ' || TRIM(vsRepositorio) || '/' || TRIM (vsNomArchivo);
					SYSTEM vsSQL ;

					LET vsFlagSystem = '';

				ELSE -- CONSULTA VACIA
					LET vsCodRetorno = '00900';
				END IF;

				--ELIMINA LA TABLA TEMPORAL DE SURTIDOS
				DROP TABLE  BdiTarjCop:"informix".Surtido;

			END IF;
		END IF;
	END IF ;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--GUARDA  REGISTRO DE LA OPERACION EN LA BITACORA
	INSERT INTO bdiTarjCop:"informix".BitacoraTarCop (Empleado, Fecha, Actividad, NomArchivo, CodRetorno) VALUES (psEmpleado, CURRENT, 'CARGAR SURTIDO', psNomArchivo, vsCodRetorno);

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 mensaje INTO vsMensaje FROM bditarjcop:"informix".mensajestarcop WHERE codmensaje = vsCodRetorno;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--VALIDA SI SE GENERO EL ARCHIVO DE INTERCAMBIO CON REGISTROS DE ERROR


	--IF (vsCodRetorno = '00926') THEN --REGISTROS CON ERROR
	--IF (vsCodRetorno <> '00000') THEN --REGISTROS CON ERROR
		LET Arch_Intercambio = vsNomArchivo2;  --ARCHIVO DE INTERCANBIO CON ESTATUS DE LOS REGISTROS
	--ELSE
		--LET Arch_Intercambio = '';
	--END IF;


	RETURN vsCodRetorno, vsMensaje, Arch_Intercambio;

END

END PROCEDURE
DOCUMENT
'AUTOR: Casanova Edeza Hector Juan',
'Proyecto: Alta Única',
'Descripcion: Carga a una tabla el contenido de un archivo de surtido de tarjetas coppel, procesa el surtido y genera un archivo de salida con el estatus de cada envio de tarjetas del surtido.',
'Fecha: 2009/01/29',
'Version: 201090129.1800',
'BD: bditarjcop',
'',
'MODIFICADO: Casanova Edeza Hector Juan',
'Proyecto: Alta Única',
'Descripcion: SE MODIFICA LA CONSULTA PARA OBTENER LA RUTA AIX PARA LA CARGA DE LOS ARCHIVOS.',
'Fecha: 2011/12/26',
'Version: 20111226.0934',
'BD: bditarjcop',
'',
'MODIFICADO: Casanova Edeza Hector Juan',
'Proyecto: Alta Única',
'Descripcion: SE MOFIFICA EÑ RETORNO DEL SP PARA INDICAR EL NOMBRE DEL ARCHIVO DE INTERCAMBIO EN CASO DE ESTE SER GENERADO.',
'Fecha: 2011/12/26',
'Version: 20111226.1644',
'BD: bditarjcop';