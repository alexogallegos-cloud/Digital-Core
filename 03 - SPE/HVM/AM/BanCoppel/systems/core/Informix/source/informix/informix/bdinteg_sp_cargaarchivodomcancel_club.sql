CREATE PROCEDURE "informix".sp_cargaarchivodomcancel_club()
--DATOS A REGRESAR--
RETURNING CHAR(6) AS CodigoRetorno;

--DEFINICION DE VARIABLES--
DEFINE cCodret CHAR(6);
DEFINE cCodRetorno CHAR(6);
DEFINE vMensajeRet VARCHAR(80);
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE vErrorInfo VARCHAR(80);
DEFINE vProceso VARCHAR(30);
DEFINE cBanArchivoCifras CHAR(1);
DEFINE cBanArchivoDetalle CHAR(1);
DEFINE cFolio CHAR(16);
DEFINE dFechaHoy DATE;
DEFINE cNombreArchivoCifras CHAR(50);
DEFINE cNombreArchivoDetalle CHAR(50);
DEFINE cFechaArchivo CHAR(8);
DEFINE cRuta CHAR(100);
DEFINE cSql CHAR(1024);
DEFINE vLinea VARCHAR(50);
DEFINE iCantMovDom INTEGER;
DEFINE iCantMovCifras INTEGER;
DEFINE iTotalDomiciliacion INT8;
DEFINE iTotalDomiciliacionCifras INT8;
DEFINE cNumCte CHAR(20);
DEFINE cTipoCliente CHAR(1);
DEFINE cIdDomiciliacion CHAR(20);
DEFINE cFechaPaquete CHAR(10);
DEFINE cProcesado CHAR(1);
DEFINE dtFechaHora DATETIME YEAR TO SECOND;

--INICIALIZACION DE VARIABLES--
LET cCodret = '000';
LET cCodRetorno = '000';
LET vMensajeRet = '';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET vErrorInfo = '';
LET vProceso = 'sp_cargaarchivodomcancel_club';
LET cBanArchivoCifras = 'F';
LET cBanArchivoDetalle = 'F';
LET cFolio = '';
LET dFechaHoy = '';
LET cNombreArchivoCifras = '';
LET cNombreArchivoDetalle = '';
LET cFechaArchivo = '';
LET cRuta = '';
LET cSql = '';
LET vLinea = '';
LET iCantMovDom = 0;
LET iCantMovCifras = 0;
LET iTotalDomiciliacion = 0;
LET iTotalDomiciliacionCifras = 0;
LET cNumCte = '';
LET cTipoCliente = '';
LET cIdDomiciliacion = '';
LET cFechaPaquete = '';
LET cProcesado = '';
LET dtFechaHora = '';

--SET DEBUG FILE TO "/informix/IrisA/sp_cargaarchivodomcancel_club.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET vMensajeRet = vErrorInfo;
			INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
				VALUES(vProceso, cCodret, vMensajeRet, dFechaHoy);
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	SELECT fecha_hoy INTO dFechaHoy 
	FROM "informix".si_fechas WHERE empresa = '001';

	IF TRIM(NVL(dFechaHoy,'')) <> '' THEN

		SELECT valor INTO cRuta 
		FROM "informix".si_param 
		WHERE empresa = '001' AND cod_param = 319;

		IF TRIM(NVL(cRuta,'')) <> '' THEN

			LET cFechaArchivo = YEAR(dFechaHoy) || LPAD(MONTH(dFechaHoy),2,'0') || LPAD(DAY(dFechaHoy),2,'0');
			LET cNombreArchivoCifras = 'cifradomiciliacionescanceladas' || TRIM(cFechaArchivo) || '.txt';
			LET cNombreArchivoDetalle = 'domiciliacionescanceladas' || TRIM(cFechaArchivo) || '.txt';

			TRUNCATE TABLE "informix".si_club_domiciliacioncancelada;
			TRUNCATE TABLE "informix".si_club_cifradomiciliacioncancelada;
			
			--- BORRAR LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
			IF EXISTS(SELECT tabname FROM systables WHERE tabname = 'tmp_club_buscaarchivodomcancel') THEN
				DROP TABLE tmp_club_buscaarchivodomcancel;
			END IF

			--- CREAR LA TABLA DE TRABAJO
			CREATE TABLE tmp_club_buscaarchivodomcancel(linea VARCHAR(50));

			--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO club_buscaarchivodomcancel.unl
			LET cSql = 'ls ' || TRIM(cRuta) || ' > club_buscaarchivodomcancel.unl';
			SYSTEM cSql;

			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO *.SQL
			LET cSql = 'echo "LOAD FROM club_buscaarchivodomcancel.unl INSERT INTO tmp_club_buscaarchivodomcancel" > tmp_club_buscaarchivodomcancel.sql';
			SYSTEM cSql;

			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO *.SQL
			LET cSql = 'dbaccess bdinteg tmp_club_buscaarchivodomcancel.sql';
			SYSTEM cSql;

			LET cSql = '';
				LET cSql = "rm club_buscaarchivodomcancel.unl";
			SYSTEM cSql;

			LET cSql = '';
				LET cSql = "rm tmp_club_buscaarchivodomcancel.sql";
			SYSTEM cSql;

			--- CICLO PARA BARRER LA TABLA DE TRABAJO Y BUSCAR EL NOMBRE DEL ARCHIVO
			FOREACH
				SELECT linea INTO vLinea FROM tmp_club_buscaarchivodomcancel

				IF vLinea = cNombreArchivoCifras THEN
					LET cBanArchivoCifras = 'V';
				END IF;

				IF vLinea = cNombreArchivoDetalle THEN
					LET cBanArchivoDetalle = 'V';
				END IF;

				IF NVL(cBanArchivoCifras,'') = 'V' AND NVL(cBanArchivoDetalle,'') = 'V' THEN
					EXIT FOREACH;
				END IF;
			END FOREACH;

			DROP TABLE tmp_club_buscaarchivodomcancel;

			IF NVL(cBanArchivoCifras,'') = 'V' AND NVL(cBanArchivoDetalle,'') = 'V' THEN
				LET cSql = '';
				LET cSql =  'echo "LOAD FROM ' || TRIM(cRuta) || 'domiciliacionescanceladas' || TRIM(cFechaArchivo) || '.txt' ||
							' INSERT INTO si_club_domiciliacioncancelada(num_cliente, flag_tipocliente, idu_domiciliacion, fec_paquete);' ||
							' " > domiciliacionescanceladas.sql';
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = 'dbaccess bdinteg domiciliacionescanceladas.sql';
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = "rm domiciliacionescanceladas.sql";
				SYSTEM cSql;

				LET cSql = '';
				LET cSql =  'echo "LOAD FROM ' || TRIM(cRuta) || 'cifradomiciliacionescanceladas' || TRIM(cFechaArchivo) || '.txt' || 
							' INSERT INTO si_club_cifradomiciliacioncancelada(cant_movimientos, total_domiciliacion, fec_paquete);' ||
							' " > cifradomiciliacionescanceladas.sql';
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = 'dbaccess bdinteg cifradomiciliacionescanceladas.sql';
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = "rm cifradomiciliacionescanceladas.sql";
				SYSTEM cSql;

				UPDATE statistics medium FOR TABLE "informix".si_club_domiciliacioncancelada;
				UPDATE statistics medium FOR TABLE "informix".si_club_cifradomiciliacioncancelada;

				SELECT COUNT(num_cliente) INTO iCantMovDom
				FROM "informix".si_club_domiciliacioncancelada;

				SELECT cant_movimientos INTO iCantMovCifras
				FROM "informix".si_club_cifradomiciliacioncancelada;

				IF NVL(iCantMovDom,0) =  NVL(iCantMovCifras,0) THEN

					FOREACH
						SELECT num_cliente INTO cNumCte 
						FROM "informix".si_club_domiciliacioncancelada

						IF EXISTS(SELECT 1 FROM "informix".si_club_proteccion WHERE numcte_coppel = TRIM(cNumCte)) THEN

							UPDATE "informix".si_club_proteccion SET tipo_pago = '0', num_tarjeta = '', num_cta = '' WHERE numcte_coppel = cNumCte;

							UPDATE "informix".si_club_domiciliacioncancelada SET procesado = '1', fecha_hora = CURRENT YEAR TO SECOND WHERE num_cliente = cNumCte;

						ELSE
							LET cCodRetorno = '001';
							LET vMensajeRet = 'No Existe el Cliente';
							INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
								VALUES(vProceso, cCodRetorno, vMensajeRet, dFechaHoy);
						END IF;
					END FOREACH;

				ELSE
					LET cCodret = '003';
					LET vMensajeRet = 'Las Cantidades de Movimientos son Diferentes';
				END IF;

				IF cCodret = '000' THEN

					FOREACH
						SELECT num_cliente, flag_tipocliente, idu_domiciliacion, fec_paquete, procesado, fecha_hora
						INTO cNumCte, cTipoCliente, cIdDomiciliacion, cFechaPaquete, cProcesado, dtFechaHora
						FROM "informix".si_club_domiciliacioncancelada

						INSERT INTO "informix".si_club_domiciliacioncancelada_hist(num_cliente, flag_tipocliente, idu_domiciliacion, fec_paquete, procesado, fecha_hora)
							VALUES(cNumCte, cTipoCliente, cIdDomiciliacion, cFechaPaquete, cProcesado, dtFechaHora);
					END FOREACH;

					SELECT cant_movimientos, total_domiciliacion, fec_paquete
					INTO iCantMovCifras, iTotalDomiciliacionCifras, cFechaPaquete
					FROM "informix".si_club_cifradomiciliacioncancelada;

					INSERT INTO "informix".si_club_cifradomiciliacioncancelada_hist(cant_movimientos, total_domiciliacion, fec_paquete)
						VALUES(iCantMovCifras, iTotalDomiciliacionCifras, cFechaPaquete);
				END IF;
			ELSE
				LET cCodret = '005';
				LET vMensajeRet = 'No existe el Archivo en la Ruta';
			END IF;
		ELSE
			LET cCodret = '002';
			LET vMensajeRet = 'No Existe Ruta';
		END IF;
	ELSE
		LET cCodret = '001';
		LET vMensajeRet = 'No Existe Fecha';
	END IF;

	IF cCodret <> '000' THEN
		INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
			VALUES(vProceso, cCodret, vMensajeRet, dFechaHoy);
	END IF;

	IF cCodret = '005' THEN
		LET cCodret = '000';
	END IF;

	RETURN cCodret;
END;
END PROCEDURE;