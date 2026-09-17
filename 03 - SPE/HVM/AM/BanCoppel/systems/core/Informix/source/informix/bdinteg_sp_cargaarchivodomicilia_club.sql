CREATE PROCEDURE "informix".sp_cargaarchivodomicilia_club()
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
DEFINE vLinea VARCHAR(50);
DEFINE cRuta CHAR(100);
DEFINE cSql CHAR(1024);
DEFINE iCantMovDom INTEGER;
DEFINE iCantMovCifras INTEGER;
DEFINE iTotalImporteDom INT8;
DEFINE iTotalImporteCifras INT8;
DEFINE cNumCte CHAR(20);
DEFINE cTipoCliente CHAR(1);
DEFINE cIdDomiciliacion CHAR(20);
DEFINE cFecha CHAR(10);
DEFINE cImporteDom CHAR(20);
DEFINE cProcesado CHAR(1);
DEFINE dtFechaHora DATETIME YEAR TO SECOND;
DEFINE cNumCuenta CHAR(20);
DEFINE cNumTarjeta CHAR(20);
DEFINE cTranRet CHAR(4);
DEFINE dFecHoy DATE;
DEFINE mSdoDisp MONEY(14,2);
DEFINE mMontoRet MONEY(14,2);
DEFINE dcSaldoCom DECIMAL(14,2);
DEFINE dcMtoCgo DECIMAL(14,2);
DEFINE dcMtoCom DECIMAL(14,2);
DEFINE dcIva DECIMAL(14,2);
DEFINE dtarjetacred CHAR(20);

--INICIALIZACION DE VARIABLES--
LET cCodret = '000';
LET cCodRetorno = '000';
LET vMensajeRet = '';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET vErrorInfo = '';
LET vProceso = 'sp_cargaarchivodomicilia_club';
LET cBanArchivoCifras = 'F';
LET cBanArchivoDetalle = 'F';
LET cFolio = '';
LET dFechaHoy = '';
LET cNombreArchivoCifras = '';
LET cNombreArchivoDetalle = '';
LET cFechaArchivo = '';
LET vLinea = '';
LET cRuta = '';
LET cSql = '';
LET iCantMovDom = 0;
LET iCantMovCifras = 0;
LET iTotalImporteDom = 0;
LET iTotalImporteCifras = 0;
LET cNumCte = '';
LET cTipoCliente = '';
LET cIdDomiciliacion = '';
LET cFecha = '';
LET cImporteDom = '';
LET cProcesado = '';
LET dtFechaHora = '';
LET cNumCuenta = '';
LET cNumTarjeta = '';
LET cTranRet = '';
LET dFecHoy = '';
LET mSdoDisp = 0;
LET mMontoRet = 0;
LET dcSaldoCom = 0;
LET dcMtoCgo = 0;
LET dcMtoCom = 0;
LET dcIva = 0;
LET dtarjetacred = '';

--SET DEBUG FILE TO "/tmp/sp_cargaarchivodomicilia_club.out";
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
			LET cNombreArchivoCifras = 'cifradomiciliacionclub' || TRIM(cFechaArchivo) || '.txt';
			LET cNombreArchivoDetalle = 'domiciliacionclub' || TRIM(cFechaArchivo) || '.txt';

            IF EXISTS(SELECT tabname FROM systables WHERE tabname = 'si_club_domiciliacion') THEN
                TRUNCATE TABLE "informix".si_club_domiciliacion;
            END IF

            IF EXISTS(SELECT tabname FROM systables WHERE tabname = 'si_club_cifradomiciliacion') THEN
                TRUNCATE TABLE "informix".si_club_cifradomiciliacion;
            END IF


			--- BORRAR LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
			IF EXISTS(SELECT tabname FROM systables WHERE tabname = 'tmp_club_buscaarchivodom') THEN
				DROP TABLE tmp_club_buscaarchivodom;
			END IF

			--- CREAR LA TABLA DE TRABAJO
			CREATE TABLE tmp_club_buscaarchivodom(linea VARCHAR(50));

			--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO club_buscaarchivodom.unl
			LET cSql = 'ls ' || TRIM(cRuta) || ' > club_buscaarchivodom.unl';
			SYSTEM cSql;

			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO *.SQL
			LET cSql = 'echo "LOAD FROM club_buscaarchivodom.unl INSERT INTO tmp_club_buscaarchivodom" > tmp_club_buscaarchivodom.sql';
			SYSTEM cSql;

			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO *.SQL
			LET cSql = 'dbaccess bdinteg tmp_club_buscaarchivodom.sql';
			SYSTEM cSql;

			LET cSql = '';
				LET cSql = "rm club_buscaarchivodom.unl";
			SYSTEM cSql;

			LET cSql = '';
				LET cSql = "rm tmp_club_buscaarchivodom.sql";
			SYSTEM cSql;

			--- CICLO PARA BARRER LA TABLA DE TRABAJO Y BUSCAR EL NOMBRE DEL ARCHIVO
			FOREACH
				SELECT linea INTO vLinea FROM tmp_club_buscaarchivodom

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

			DROP TABLE tmp_club_buscaarchivodom;

			IF NVL(cBanArchivoCifras,'') = 'V' AND NVL(cBanArchivoDetalle,'') = 'V' THEN
				LET cSql = '';
				LET cSql =  'echo "LOAD FROM ' || TRIM(cRuta) || 'domiciliacionclub' || TRIM(cFechaArchivo) || '.txt' ||
							' INSERT INTO si_club_domiciliacion(num_cliente, flag_tipocliente, idu_domiciliacion, fec_paquete, imp_importe);' ||
							' " > domiciliacionclub.sql';
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = 'dbaccess bdinteg domiciliacionclub.sql';
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = "rm domiciliacionclub.sql";
				SYSTEM cSql;

				LET cSql = '';
				LET cSql =  'echo "LOAD FROM ' || TRIM(cRuta) || 'cifradomiciliacionclub' || TRIM(cFechaArchivo) || '.txt' || 
							' INSERT INTO si_club_cifradomiciliacion(cant_movimientos, total_importe, fec_paquete);' ||
							' " > cifradomiciliacionclub.sql';
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = 'dbaccess bdinteg cifradomiciliacionclub.sql';
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = "rm cifradomiciliacionclub.sql";
				SYSTEM cSql;

				UPDATE statistics medium FOR TABLE "informix".si_club_domiciliacion;
				UPDATE statistics medium FOR TABLE "informix".si_club_cifradomiciliacion;

				SELECT COUNT(num_cliente), SUM(imp_importe::INT8) 
				INTO iCantMovDom, iTotalImporteDom 
				FROM "informix".si_club_domiciliacion;

				SELECT cant_movimientos, total_importe 
				INTO iCantMovCifras, iTotalImporteCifras 
				FROM "informix".si_club_cifradomiciliacion;

				IF NVL(iCantMovDom,0) =  NVL(iCantMovCifras,0) THEN

					IF NVL(iTotalImporteDom,0) =  NVL(iTotalImporteCifras,0) THEN

						FOREACH WITH HOLD
							SELECT num_cliente, imp_importe 
							INTO cNumCte, cImporteDom 
							FROM "informix".si_club_domiciliacion

							SELECT FIRST 1 num_cta, num_tarjeta 
							INTO cNumCuenta, cNumTarjeta 
							FROM "informix".si_club_proteccion 
							WHERE empresa='001' and aceptada = '1'
                                  AND numcte_coppel = cNumCte AND tipo_pago <> '0';

							LET cCodRetorno = '000';
							LET vMensajeRet = '';

							EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(USER)
								INTO cCodRetorno, cFolio;

							IF TRIM(NVL(cCodRetorno,'')) = '000' THEN

								IF TRIM(NVL(cNumCuenta,'')) <> '' THEN

									LET vMensajeRet = 'bdicheq:"informix".cargo_ref';

									EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001', '9290', USER, '0304', '', TRIM(cFolio), TRIM(cNumCuenta), 0, TRIM(cImporteDom), 
										'01', 'COBRO CLUB DE PROTECCION', '', USER)
										INTO cCodRetorno, cTranRet, dFecHoy, mSdoDisp, mMontoRet;

								ELIF TRIM(NVL(cNumTarjeta,'')) <> '' THEN
									IF LENGTH (cNumTarjeta) = 12 THEN
										SELECT num_tarjeta INTO dtarjetacred 
										FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001'
										AND num_credito = cNumTarjeta 
										AND status_tar = 'A' and tipo_tarjeta='T';

										IF TRIM(NVL(dtarjetacred,'')) <> '' THEN
											LET vMensajeRet = 'bdicred:"informix".cargoref_tc_ofi';

											EXECUTE PROCEDURE bdicred:"informix".cargoref_tc_ofi('001', '9290', USER, TRIM(dtarjetacred), TRIM(cImporteDom), TRIM(cFolio), '8045')
											INTO cCodRetorno, dcSaldoCom, dcMtoCgo, dcMtoCom, dcIva;
										ELSE
											LET cCodRetorno = '001'; 
											LET vMensajeRet = 'No es la misma Cuenta Domiciliada';
										END IF;
									ELSE
										LET vMensajeRet = 'bdicred:"informix".cargoref_tc_ofi';

										EXECUTE PROCEDURE bdicred:"informix".cargoref_tc_ofi('001', '9290', USER, TRIM(cNumTarjeta), TRIM(cImporteDom), TRIM(cFolio), '8045')
											INTO cCodRetorno, dcSaldoCom, dcMtoCgo, dcMtoCom, dcIva;
									END IF;
								ELSE
									LET cCodRetorno = '001'; 
									LET vMensajeRet = 'No es la misma Cuenta Domiciliada';
								END IF;

								IF TRIM(NVL(cCodRetorno,'')) = '000' THEN

									UPDATE "informix".si_club_domiciliacion SET procesado = '1', fecha_hora = CURRENT YEAR TO SECOND WHERE num_cliente = cNumCte;

								ELSE
									INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
										VALUES(vProceso, cCodRetorno, vMensajeRet, dFechaHoy);
								END IF;

							ELSE
								LET vMensajeRet = 'bdicheq:"informix".sp_generafolionomina';
								INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
									VALUES(vProceso, cCodRetorno, vMensajeRet, dFechaHoy);
							END IF;
						END FOREACH;

					ELSE
						LET cCodret = '004';
						LET vMensajeRet = 'El Total de Importe es Diferente';
					END IF;
				ELSE
					LET cCodret = '003';
					LET vMensajeRet = 'Las Cantidades de Movimientos son Diferentes';
				END IF;
			ELSE
				LET cCodret = '005';
				LET vMensajeRet = 'No existe el Archivo en la Ruta';
			END IF;

			IF cCodret = '000' THEN

				--LET cSql = '';
				--LET cSql = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'domiciliarclubbcpl1' || TRIM(cFechaArchivo) || '.txt' || ' DELIMITER ' || '''|''' ||
			--				' SELECT num_cliente, flag_tipocliente, idu_domiciliacion, fec_paquete, imp_importe, procesado ' ||
			--				' FROM si_club_domiciliacion ' || ';' ||
			--				' " > domiciliarclubbcpl.sql';
			--	SYSTEM cSql; 

			--	LET cSql = '';
			--	LET cSql = 'dbaccess bdinteg domiciliarclubbcpl.sql';
			--	SYSTEM cSql; 

			--	LET cSql = '';
			--	LET cSql = "sed 's/|$//g' " || TRIM(cRuta) || 'domiciliarclubbcpl1' || TRIM(cFechaArchivo) || '.txt' || " > " || TRIM(cRuta) || 'domiciliarclubbcpl' || TRIM(cFechaArchivo) || '.txt';
			--	SYSTEM cSql; 

			--	LET cSql = '';
			--	LET cSql = 'rm domiciliarclubbcpl.sql';
			--	SYSTEM cSql; 

			--	LET cSql = '';
			--	LET cSql = 'rm ' || TRIM(cRuta) || 'domiciliarclubbcpl1' || TRIM(cFechaArchivo) || '.txt';
			--	SYSTEM cSql; 

			--	LET cSql = '';
			--	LET cSql = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'cifradomiciliacionclubbcpl1' || TRIM(cFechaArchivo) || '.txt' || ' DELIMITER ' || '''|''' ||
			--				' SELECT cant_movimientos, total_importe, fec_paquete ' ||
			--				' FROM si_club_cifradomiciliacion ' || ';' ||
			--				' " > cifradomiciliacionclubbcpl.sql';
			--	SYSTEM cSql; 

			--	LET cSql = '';
			--	LET cSql = 'dbaccess bdinteg cifradomiciliacionclubbcpl.sql';
			--	SYSTEM cSql; 

			--	LET cSql = '';
			--	LET cSql = "sed 's/|$//g' " || TRIM(cRuta) || 'cifradomiciliacionclubbcpl1' || TRIM(cFechaArchivo) || '.txt' || " > " || TRIM(cRuta) || 'cifradomiciliacionclubbcpl' || TRIM(cFechaArchivo) || '.txt';
			--	SYSTEM cSql; 

			--	LET cSql = '';
			--	LET cSql = 'rm cifradomiciliacionclubbcpl.sql';
			--	SYSTEM cSql; 

			--	LET cSql = '';
			--	LET cSql = 'rm ' || TRIM(cRuta) || 'cifradomiciliacionclubbcpl1' || TRIM(cFechaArchivo) || '.txt';
			--	SYSTEM cSql; 

				FOREACH
					SELECT num_cliente, flag_tipocliente, idu_domiciliacion, fec_paquete, imp_importe, procesado, fecha_hora
					INTO cNumCte, cTipoCliente, cIdDomiciliacion, cFecha, cImporteDom, cProcesado, dtFechaHora
					FROM "informix".si_club_domiciliacion

					INSERT INTO "informix".si_club_domiciliacion_hist(num_cliente, flag_tipocliente, idu_domiciliacion, fec_paquete, imp_importe, procesado, fecha_hora)
						VALUES(cNumCte, cTipoCliente, cIdDomiciliacion, cFecha, cImporteDom, cProcesado, dtFechaHora);
				END FOREACH;

				SELECT cant_movimientos, total_importe, fec_paquete
				INTO iCantMovCifras, iTotalImporteCifras, cFecha
				FROM "informix".si_club_cifradomiciliacion;

				INSERT INTO "informix".si_club_cifradomiciliacion_hist(cant_movimientos, total_importe, fec_paquete)
					VALUES(iCantMovCifras, iTotalImporteCifras, cFecha);
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