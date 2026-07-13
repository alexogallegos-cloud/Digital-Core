CREATE PROCEDURE "informix".sp_grabarcardcarriers_web(p_sempresa CHAR(3), p_sNumeroCaja CHAR(10), p_sTipoImagen CHAR(1), 
											p_iNumeroPaquete INTEGER, p_sFolioInicio CHAR(16), p_sFolioFinal CHAR(16), 
											p_sSucursal CHAR(4),p_sEstatus CHAR(1),	p_iTipoGrabacion SMALLINT,
											p_sUsuarioRegistro CHAR(8),p_sUsuarioAutoriza CHAR(8),
											p_sUsuarioSolicita CHAR(8), p_sComentario CHAR(100), p_sTarjetaNuevaIni CHAR(16),
											p_sTarjetaNuevaFin CHAR(16),piCantHojas INTEGER,
											p_Secuencia CHAR(5))

	RETURNING CHAR(5) AS retorno,
			  CHAR(10) AS cNumCaja,
			  INTEGER As Secuencia;

	DEFINE iSqlErr				INTEGER;
	DEFINE v_sValRetorno		CHAR(5);
	DEFINE v_dFechaInsercion	DATE;
	DEFINE v_iFolioInicio 		INT8;
	DEFINE v_iFolioFinal		INT8;
	--folio_1668
	DEFINE iCapacidad			INTEGER;
	DEFINE iCantidad 			INTEGER;
	DEFINE iNumReg				INTEGER;
	DEFINE iTotSuma				INTEGER;
	DEFINE iCantidadPaq			INTEGER;
	DEFINE iResta				INTEGER;
	DEFINE iSuma				INTEGER;
	DEFINE iBandera				INTEGER;
	DEFINE cNumCaja				CHAR(10);
	DEFINE iBandUpdate			INTEGER;
	DEFINE iSecuencia			INTEGER;
	DEFINE iPaquete				INTEGER;
	-----------------------------------------------------------------------
	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_GrabarCardCarriers.out";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno = '00001';
	LET v_dFechaInsercion = CURRENT::DATE;
	--folio_1668
	LET iCapacidad 			= 0;
	LET iCantidad 			= 0;
	LET iNumReg 			= 0;
	LET iTotSuma 			= 0;
	LET iCantidadPaq 		= 0;
	LET iResta 				= 0;
	LET iSuma 				= 0;
	LET iBandera 			= 0;
	LET cNumCaja 			= '';
	LET iBandUpdate			= 0;
	LET iSecuencia			= 0;
	LET iPaquete 			= 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,TRIM(NVL(cNumCaja,'')),iSecuencia;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sNumeroCaja,'')='' OR NVL(p_sTipoImagen,'') = ''
			OR NVL(p_iNumeroPaquete,'') = '' OR NVL(p_sFolioInicio,'') = '' OR NVL(p_sFolioFinal,'') = ''
			OR NVL(p_sSucursal,'') = '' OR NVL(p_sEstatus,'') = '' OR NVL(p_iTipoGrabacion,'') = '' OR NVL(piCantHojas,0) = 0  THEN

			RETURN v_sValRetorno,TRIM(NVL(cNumCaja,'')),iSecuencia;
		END IF;

		IF NVL(p_sUsuarioRegistro,'')='' THEN
			LET p_sUsuarioRegistro = NULL;
		END IF

		--SE COMENTA CODIGO YA QUE NO SERA NECESARIA LA AUTORIZACION DEL GERENTE 14/10/2014

		IF NVL(p_sUsuarioSolicita,'')='' THEN
			LET p_sUsuarioSolicita = NULL;
		END IF

		IF NVL(p_sComentario,'')='' THEN
			LET p_sComentario = NULL;
		END IF

		LET v_iFolioInicio = p_sFolioInicio::INT8;
		LET v_iFolioFinal = p_sFolioFinal::INT8;

		--SELECCIONA LA CAPACIDAD  DE NUMERO DE HOJAS PERMITIDO QUE TIENE EL TIPO DE PAQUETE --CARDCARRIERS
		SELECT NVL(capacidad,0) INTO iCapacidad FROM "informix".ss_cattipopaquetes
		WHERE empresa = p_sEmpresa AND tipopaquete = '4';

		--SELECCIONA EL NUMERO DE HOJAS REGISTRADAS QUE TIENE EL NUMERO  DE CAJA RECIBIDO COMO --PARAMETRO
		SELECT NVL(num_hojas_registradas,0) INTO iNumReg FROM "informix".ss_numcajas
		WHERE empresa = p_sEmpresa AND numerocaja = p_sNumeroCaja AND numsucursal = p_sSucursal;

		--SI NO EXISTE GUARDA, SI EXISTE ACTUALIZA
		IF (SELECT count(1) FROM bdisuc:"informix".ss_cardcarriers WHERE empresa = p_sEmpresa 
		AND ((folioinicio::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal)
		OR (foliofinal::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal))
		AND sucursal = p_sSucursal AND estatus <> 'E') = 0 THEN


			SELECT NVL(MAX(secuencia::INTEGER),'0') INTO iSecuencia
			FROM "informix".ss_cardcarriers
			WHERE empresa = p_sEmpresa AND folioinicio = p_sFolioInicio
			AND foliofinal = p_sFolioFinal
			AND sucursal = p_sSucursal ;

			LET iSecuencia = iSecuencia + 1;

				SELECT NVL(MAX(numeropaquete),0) INTO iPaquete
				FROM "informix".ss_cardcarriers
				WHERE empresa = p_sEmpresa
				AND sucursal = p_sSucursal
				AND numerocaja = p_sNumeroCaja
				AND estatus <> 'E';

				LET iPaquete = iPaquete + 1;


				INSERT INTO "informix".ss_cardcarriers(empresa, numerocaja, tipoimagen, numeropaquete, folioinicio,
				foliofinal, sucursal, estatus, usuarioregistra, usuarioautoriza, usuariosolicita,
				comentario, fecha_insert,cantidad_hojas,secuencia)--SE AGREGA CANTIDAD DE HOJAS
				VALUES (p_sEmpresa, p_sNumeroCaja, p_sTipoImagen, iPaquete, p_sFolioInicio,
				p_sFolioFinal, p_sSucursal, p_sEstatus, NVL(p_sUsuarioRegistro,''),
				NVL(p_sUsuarioAutoriza,''), NVL(p_sUsuarioSolicita,''),
				NVL(p_sComentario,''), v_dFechaInsercion,NVL(piCantHojas,0),TRIM(nvl(iSecuencia::CHAR(5),'')));

				LET iBandUpdate = 1;
				LET v_sValRetorno = '00000';

				IF iBandUpdate = 1 THEN

					--SE ACTUALIZA EL NUMERO DE HOJAS REGISTRADAS POR LA CANTIDAD TOTAL DE HOJAS

					SELECT SUM(NVL(cantidad_hojas,0))
					INTO iCantidad
					FROM "informix".ss_cardcarriers
					WHERE empresa = p_sEmpresa
					AND numerocaja = p_sNumeroCaja
					AND sucursal = p_sSucursal
					AND estatus <> 'E';

					UPDATE "informix".ss_numcajas
					SET num_hojas_registradas = iCantidad
					WHERE empresa = p_sEmpresa
					AND numerocaja = p_sNumeroCaja
					AND numsucursal = p_sSucursal
					AND estatus = 'Activa'
					AND tipopaquete = 4;


					IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
						LET v_sValRetorno = "00001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
					ELSE
						LET v_sValRetorno = '00000';
					END IF;

				END IF;

		ELSE
			--SI EXISTE CON EL MISMO RANGO DE FOLIOS, SE ACTUALIZA, DE LO CONTRARIO SE MANDA UN --ERROR
			IF (SELECT count(1) FROM "informix".ss_cardcarriers	WHERE empresa = p_sEmpresa --AND tipoimagen = p_sTipoImagen
			AND folioinicio = p_sFolioInicio AND foliofinal = p_sFolioFinal AND sucursal = p_sSucursal AND estatus <> 'E' AND secuencia = p_Secuencia) > 0 THEN

				--SI ES UNA ACTUALIZACION
				IF p_iTipoGrabacion = 2 THEN
					SELECT NVL(cantidad_hojas,0) INTO iCantidadPaq FROM "informix".ss_cardcarriers
					WHERE empresa = p_sEmpresa AND folioinicio = p_sFolioInicio AND foliofinal = p_sFolioFinal
					AND sucursal = p_sSucursal and numerocaja = p_sNumeroCaja AND estatus <> 'E'
					AND secuencia = p_Secuencia;

							IF (SELECT count(1) FROM "informix".ss_cardcarriers
							WHERE empresa = p_sEmpresa
							AND folioinicio = p_sTarjetaNuevaIni
							AND foliofinal = p_sTarjetaNuevaFin
							AND sucursal = p_sSucursal
							AND secuencia = p_Secuencia) > 0 THEN


							SELECT NVL(MAX(secuencia::INTEGER),0)
							INTO iSecuencia
							FROM "informix".ss_cardcarriers
							WHERE empresa = p_sEmpresa
							AND sucursal = p_sSucursal
							AND folioinicio = p_sTarjetaNuevaIni
							AND foliofinal = p_sTarjetaNuevaFin;

							LET iSecuencia = iSecuencia + 1;
							ELSE
								LET iSecuencia = NVL(p_Secuencia::INTEGER,0);
							END IF;

							--ACTUALIZA SOLAMENTE EL ESTATUS
							UPDATE "informix".ss_cardcarriers
							SET estatus = p_sEstatus, usuarioregistra = p_sUsuarioRegistro,
							usuarioautoriza = p_sUsuarioAutoriza,
							usuariosolicita = p_sUsuarioSolicita, comentario = p_sComentario,
							folioinicio = p_sTarjetaNuevaIni,
							foliofinal = p_sTarjetaNuevaFin,
							cantidad_hojas = piCantHojas,
							secuencia = TRIM(NVL(iSecuencia::CHAR(5),''))
							WHERE empresa = p_sEmpresa
							AND numerocaja = p_sNumeroCaja
							AND sucursal = p_sSucursal
							AND estatus <> 'E'
							AND folioinicio = p_sFolioInicio
							AND foliofinal = p_sFolioFinal
							AND secuencia = p_Secuencia;

							LET p_Secuencia = TRIM(NVL(iSecuencia::CHAR(5),''));

								--SE ACTUALIZA EL NUMERO DE HOJAS REGISTRADAS POR LA CANTIDAD TOTAL --DE HOJAS

								SELECT SUM(NVL(cantidad_hojas,0))
								INTO iCantidad
								FROM "informix".ss_cardcarriers
								WHERE empresa = p_sEmpresa
								AND numerocaja = p_sNumeroCaja
								AND sucursal = p_sSucursal
								AND estatus <> 'E';

								UPDATE "informix".ss_numcajas
								SET num_hojas_registradas = iCantidad
								WHERE empresa = p_sEmpresa
								AND numerocaja = p_sNumeroCaja
								AND numsucursal = p_sSucursal
								AND estatus = 'Activa'
								AND tipopaquete = 4;

								LET iBandUpdate = 1;
								LET iSecuencia = TRIM(p_Secuencia)::INTEGER;
								
								IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
									LET v_sValRetorno = "00001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
								ELSE
									LET v_sValRetorno = '00000';
								END IF;
				ELSE
					SELECT MAX(numerocaja) --,TRIM(MAX(secuencia))::INTEGER
					INTO cNumCaja --,iSecuencia
					FROM "informix".ss_cardcarriers
					WHERE empresa = p_sEmpresa
					AND ((folioinicio::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal)
					OR (foliofinal::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal))
					AND sucursal = p_sSucursal AND estatus <> 'E';

					LET v_sValRetorno = '00003';
				END IF;
			ELSE

				SELECT MAX(numerocaja) 
				INTO cNumCaja 
				FROM "informix".ss_cardcarriers
				WHERE empresa = p_sEmpresa
				AND ((folioinicio::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal)
				OR (foliofinal::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal))
				AND sucursal = p_sSucursal AND estatus <> 'E';

				LET cNumCaja=cNumCaja;
				LET v_sValRetorno = '00002';
			END IF;
		END IF;

		RETURN v_sValRetorno,TRIM(NVL(cNumCaja,'')),iSecuencia;
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Vladimir Felix Galvez',
'FECHA:       03-Agosto-2009',
'CASO DE USO: Caso de uso asociado PCU-bdisuc\CU-0010-GrabarCardCarriers-SPL',
'DESCRIPCION: Guarda o actualiza la informacion de los documentos card carriers.',
'MODIFICADO:  Fabiola Corrales 16/Oct/2009. Se modifica para agrega los campos usuarioregistra, usuarioautoriza, usuariosolicita y comentario.',
'MODIFICO: Josue Zepeda',
'FECHA: 04/marzo/2013',
'DESCRIPCION: Se modifico BETWEEN de select de IF NOT EXISTS tambien se agrega parametro p_sTarjetaNuevaIni y p_sTarjetaNuevaFin para la actualizacion',
'BD: bdisuc',
'ELABORO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR LA CANTIDAD DE HOJAS QUE TIENE LA CAJA',
'ADEMAS DE SUMAR EL NUMERO TOTAL Y ACTUALIZAR EL NUMERO DE HOJAS REGISTRADAS.',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_grabarexpedientesclientes_web(p_sEmpresa CHAR(3), p_sNumCliente CHAR(20), p_sNumCaja CHAR(10), 
p_iCveDocumento SMALLINT, p_sSucursal CHAR(4), p_sEstatus CHAR(1), p_dFechaRegistro DATE, p_sUsuarioRegistro CHAR(8), 
p_sUsuarioAutoriza CHAR(8), p_sUsuarioSolicita CHAR(8), p_sComentario CHAR(100),p_sCantidad CHAR(3))
									
	RETURNING 	CHAR(5) AS retorno;
	
	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(5);
	DEFINE v_dFechaInsercion				DATE;
	DEFINE iCapacidad						INTEGER;
	DEFINE iHojas							INTEGER;
	DEFINE iCantidad						INTEGER;
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_grabarExpedientesClientes.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	
	LET v_sValRetorno = '00001';
	LET v_dFechaInsercion = CURRENT::DATE;
	LET iCapacidad = 0;
	LET iHojas = 0;
	LET iCantidad = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
		 SET ISOLATION TO DIRTY READ;
         SET LOCK MODE TO WAIT 3;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sNumCliente,'')='' OR NVL(p_sNumCaja,'')='' OR p_iCveDocumento IS NULL
		OR NVL(p_sSucursal,'')='' OR NVL(p_sEstatus,'')='' OR NVL(p_dFechaRegistro,'')='' OR NVL(p_sUsuarioRegistro,'')='' THEN
		--OR NVL(p_sUsuarioAutoriza,'')='' THEN
			RETURN v_sValRetorno;
		END IF;
		
		IF NVL(p_sUsuarioSolicita,'')='' THEN
			LET p_sUsuarioSolicita = NULL;
		END IF
		
		IF NVL(p_sUsuarioAutoriza,'')='' THEN
			LET p_sUsuarioAutoriza = NULL;
		END IF
		
		IF NVL(p_sComentario,'')='' THEN
			LET p_sComentario = NULL;
		END IF
		
		--SE OBTIENE CAPACIDAD Y CANTIDAD DE HOJAS DE LA CAJA
		SELECT NVL(paq.capacidad,0), NVL(caj.num_hojas_registradas,0) 
		INTO iCapacidad, iHojas
		FROM "informix".ss_cattipopaquetes paq, "informix".ss_numcajas caj
		WHERE paq.empresa = p_sEmpresa
		AND caj.empresa = paq.empresa
		AND paq.tipopaquete = 1
		AND caj.numerocaja = p_sNumCaja;
		
		IF p_sCantidad::INTEGER <= iCapacidad THEN
			LET p_sNumCliente = LPAD(TRIM(p_sNumCliente),9,'0');
			
			--SI NO EXISTE GUARDA, SI EXISTE ACTUALIZA
			IF (SELECT 1 FROM "informix".ss_expedientesclientes WHERE empresa = p_sEmpresa AND numerocliente = p_sNumCliente 
			AND numerocaja = p_sNumCaja AND cvedocumento = p_iCveDocumento AND sucursal = p_sSucursal AND estatus = 'R') = 0 THEN
				
				INSERT INTO "informix".ss_expedientesclientes (empresa, numerocliente, numerocaja, cvedocumento, sucursal, 
				estatus, fecharegistro, usuarioregistra, usuarioautoriza, usuariosolicita, comentario,cantidad, fecha_insert)
				VALUES (p_sEmpresa, p_sNumCliente, p_sNumCaja, p_iCveDocumento, p_sSucursal, p_sEstatus, p_dFechaRegistro,
				p_sUsuarioRegistro, p_sUsuarioAutoriza, NVL(p_sUsuarioSolicita,''), NVL(p_sComentario,''),NVL(p_sCantidad,''),v_dFechaInsercion);
			
			ELSE
				UPDATE "informix".ss_expedientesclientes 
				SET sucursal = p_sSucursal, estatus = p_sEstatus, usuarioregistra = p_sUsuarioRegistro, 
				usuarioautoriza = p_sUsuarioAutoriza, usuariosolicita = p_sUsuarioSolicita, 
				comentario = p_sComentario,cantidad = p_sCantidad
				WHERE empresa = p_sEmpresa AND numerocliente = p_sNumCliente AND numerocaja = p_sNumCaja AND cvedocumento = p_iCveDocumento AND sucursal = p_sSucursal AND estatus = 'R';

			END IF;
			
			SELECT NVL(SUM(CAST(cantidad AS INTEGER)),0)
			INTO iCantidad
			FROM "informix".ss_expedientesclientes
			WHERE empresa = p_sEmpresa
			AND sucursal = p_sSucursal
			AND numerocaja = p_sNumCaja
			AND estatus <> 'E';
			
			UPDATE "informix".ss_numcajas
			SET num_hojas_registradas = iCantidad
			WHERE empresa = p_sEmpresa
			AND numsucursal = p_sSucursal
			AND numerocaja = p_sNumCaja
			AND tipopaquete = 1
			AND estatus = 'Activa';
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET v_sValRetorno = "00003"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
			ELSE
				LET v_sValRetorno = '00000';
			END IF;
			
		ELSE
			LET v_sValRetorno = '00002';
		END IF;
		RETURN v_sValRetorno;
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Erick Zamora',
'FECHA:       03/Agosto/2009',
'DESCRIPCION: Guarda o actualiza la informacion de un expediente del cliente',
'CASO DE USO: Caso de uso asociado: PCU-bdisuc\CU-0003-GrabarExpedientesClientes-SPL',
'MODIFICADO:  Fabiola Corrales 15/Oct/2009. Se modifica para agregar los campos usuariosolicita y comentario ',
'MODIFICO:    Josue Zepeda', 
'FECHA:       22/Febrero/2013',
'MODIFICADO:  Se agrega parametro p_sCantidad para que tambien se guarde',
'MODIFICO:	  Ernesto Aguilera',
'FECHA:		  17/10/2014',
'DESCRIPCION: Se obtiene capacidad y cantidad de hojas de la caja.',
'VERSION: 20141017.1630',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_grabarnumcaja_web(p_sEmpresa CHAR(3), 
											p_sNumeroCaja CHAR(10), 
											p_sSucursal CHAR(4),
											p_dFechaRegistro DATE, 
											p_iTipoPaquete SMALLINT, 
											pcEstatus CHAR(10),
											pcUsuarioalta CHAR(10),
											pcFechaalta DATE,
											cSucursalCrea  CHAR(4))
	RETURNING CHAR(5) AS retorno;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(5);
	DEFINE v_dFechaInsercion				DATE;

	-----------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_GrabarNumCaja_out.sql";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno = '00001';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		--LOS PARAMETROS NO DEBEN SER NULOS
		--dsb-29/08/2012
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumeroCaja,'') = '' OR NVL(p_sSucursal,'') = ''
		OR NVL(p_dFechaRegistro ,'') = '' OR NVL(p_iTipoPaquete ,'') = '' OR NVL(cSucursalCrea, '') = '' THEN

			RETURN v_sValRetorno;

		END IF;

		--SI NO EXISTE GUARDA, SI EXISTE MANDA UN ERROR
		IF (SELECT count(1) FROM bdisuc:"informix".ss_numcajas WHERE empresa = p_sEmpresa
						AND numerocaja = p_sNumeroCaja AND numsucursal = p_sSucursal) = 0 THEN
			--dsb-29/08/2012
			INSERT INTO bdisuc:"informix".ss_numcajas(empresa, numerocaja, numsucursal, tipopaquete, fecha_insert, estatus,usuarioalta,fechaalta,numsuc_crea)
			VALUES (p_sEmpresa, p_sNumeroCaja, p_sSucursal, p_iTipoPaquete, p_dFechaRegistro, pcEstatus,pcUsuarioalta,pcFechaalta, cSucursalCrea);
			LET v_sValRetorno = '00000';
		ELSE
			LET v_sValRetorno = '00003';
		END IF;
		RETURN v_sValRetorno;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Vladimir FÃ©lix GÃ¡lvez',
'FECHA: 05-Agosto-2009',
'CASO DE USO: PCU-bdisuc\CU-0018-GrabarNumCaja-SPL',
'DESCRIPCION: Guarda la informaciÃ³n de las cajas en el catalogo de las cajas registradas.',
'MODIFICO: Josue Zepeda',
'FECHA: 18-Abril-2012',
'DESCRIPCION: Se agregaron parametros pcEstatus, pcUsuarioalta, pcFechaalta para que sea insertado en tabla ss_numcajas',
'BD: bdisuc',
'MODIFICADO: Victor Hugo NuÃ±ez',
'FECHA: 29-Agosto-2012',
'DESCRIPCION: Se guarda la sucursal que crea la caja.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_grabarpaquetecheques_web(p_sEmpresa CHAR(3), p_sNumeroCaja CHAR(10),
													p_dFechaRegistro DATE, p_sSucursal CHAR(4), p_sEstatus CHAR(1),
													p_iTipoGrabacion SMALLINT, p_sUsuarioRegistro CHAR(8), 
													p_sUsuarioAutoriza CHAR(8), p_sUsuarioSolicita CHAR(8), p_sComentario CHAR(100),p_dFechaNueva DATE, p_iCantHojas INTEGER, p_sSecuencia CHAR(5))

	RETURNING CHAR(5) AS retorno,
			  CHAR(10) AS NumeroCaja,
			  CHAR(5) AS Secuencia;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(5);
	DEFINE v_dFechaInsercion				DATE;
	DEFINE v_dFechaRegistro					DATE;
	DEFINE v_iCiclo							INTEGER;
	DEFINE i								INTEGER;
	DEFINE cNumeroCaja						CHAR(10);
	DEFINE iCapacidad						INTEGER;
	DEFINE iNumReg							INTEGER;
	DEFINE iCantidadPaq						INTEGER;
	DEFINE iResta							INTEGER;
	DEFINE iSuma							INTEGER;
	DEFINE iBandera							INTEGER;
	DEFINE iTotSuma							INTEGER;
	DEFINE iCantidad 						INTEGER;
	DEFINE iSecuencia           			INTEGER;
	-----------------------------------------------------------------------	
	--SET DEBUG FILE TO "/respaldosbd/obed/sp_grabarpaquetecheques.out";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno = '00001';
	LET v_dFechaInsercion = CURRENT::DATE;
	LET v_dFechaRegistro = CURRENT::DATE;
	LET v_iCiclo = 0;
	LET cNumeroCaja = '';
	LET iCapacidad = 0;
	LET iNumReg = 0;
	LET iCantidadPaq = 0;
	LET iResta = 0;
	LET iSuma = 0;
	LET iBandera = 0;
	LET iTotSuma = 0;
	LET iCantidad = 0;
	LET iSecuencia = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;
				RETURN v_sValRetorno,'',TRIM(NVL(iSecuencia::CHAR(5),''));
			END IF;
		END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		 
		 
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sNumeroCaja,'')='' 
		OR NVL(p_dFechaRegistro,'') = '' OR NVL(p_sSucursal,'') = '' OR NVL(p_sEstatus,'') = ''
		OR NVL(p_iTipoGrabacion,'') = '' OR NVL(p_iCantHojas,0) = 0THEN
			RETURN v_sValRetorno,'',TRIM(NVL(iSecuencia::CHAR(5),''));
		END IF;
		
		IF NVL(p_sUsuarioRegistro,'')='' THEN
			LET p_sUsuarioRegistro = NULL;
		END IF;
		IF NVL(p_sUsuarioSolicita,'')='' THEN
			LET p_sUsuarioSolicita = NULL;
		END IF;
		IF NVL(p_sComentario,'')='' THEN
			LET p_sComentario = NULL;
		END IF;
		
		-- Se busca la fecha en otras cajas, si se encuentra, se retorna error y la caja donde se encontro
		SELECT FIRST 1 numerocaja
		INTO cNumeroCaja
		FROM "informix".ss_paquetescheques 
		WHERE empresa = p_sEmpresa
		AND sucursal = p_sSucursal
		AND fecharegistro = p_dFechaNueva
		AND numerocaja <> p_sNumeroCaja
		AND estatus <> 'E';
		
		IF NVL(cNumeroCaja,'') <> '' THEN
			LET v_sValRetorno = '00003';
			RETURN v_sValRetorno, cNumeroCaja,TRIM(NVL(iSecuencia::CHAR(5),''));
		END IF;
		
		-- Se obtiene la capacidad actual de la caja
		SELECT NVL(cja.num_hojas_registradas,0), NVL(pte.capacidad,0)
		INTO iNumReg, iCapacidad
		FROM "informix".ss_numcajas cja, "informix".ss_cattipopaquetes pte 
		WHERE cja.tipopaquete = pte.tipopaquete 
		AND cja.numerocaja = p_sNumeroCaja 
		AND cja.estatus = 'Activa'
		AND pte.tipopaquete = '5';
		
		--SI NO EXISTE INSERTA, SI EXISTE ACTUALIZA
		IF (SELECT count(1) FROM bdisuc:"informix".ss_paquetescheques WHERE empresa = p_sEmpresa 
		AND numerocaja = p_sNumeroCaja AND sucursal = p_sSucursal AND fecharegistro = p_dFechaRegistro AND estatus <> 'E' AND secuencia = p_sSecuencia) = 0 THEN
						
				
				SELECT NVL(MAX(secuencia::INTEGER),0)
				INTO iSecuencia
				FROM "informix".ss_paquetescheques
				WHERE empresa = p_sEmpresa
				AND sucursal = p_sSucursal
				AND fecharegistro = p_dFechaRegistro;
				
				LET iSecuencia = iSecuencia + 1;		
			
				--SE GUARDA EL PAQUETE DE CHEQUES DE LA FECHA PROPORCIONADA
				INSERT INTO bdisuc:"informix".ss_paquetescheques(empresa, numerocaja, tipocheques, fecharegistro, sucursal, estatus, 
				usuarioregistra, usuarioautoriza, usuariosolicita, comentario,
				fecha_insert, cantidad_hojas, secuencia)
				VALUES (p_sEmpresa, p_sNumeroCaja,'', p_dFechaRegistro, p_sSucursal, p_sEstatus, 
				NVL(p_sUsuarioRegistro,''), NVL(p_sUsuarioAutoriza,''), NVL(p_sUsuarioSolicita,''), NVL(p_sComentario,''), 
				v_dFechaInsercion, p_iCantHojas, TRIM(NVL(iSecuencia::CHAR(5),'')));
				
				SELECT SUM(cantidad_hojas) 
				INTO iCantidad
				FROM "informix".ss_paquetescheques
				WHERE empresa = p_sEmpresa
				AND numerocaja = p_sNumeroCaja
				AND sucursal = p_sSucursal
				AND estatus <> 'E';

				UPDATE "informix".ss_numcajas
				SET num_hojas_registradas = NVL(iCantidad,0)
				WHERE empresa = p_sEmpresa
				AND numerocaja = p_sNumeroCaja
				AND numsucursal = p_sSucursal
				AND estatus = 'Activa'
				AND tipopaquete = 5;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
					LET v_sValRetorno = "00001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
				ELSE
					LET v_sValRetorno = '00000';
				END IF;

		ELSE
			--SI ES ACTUALIZACION
				SELECT NVL(cantidad_hojas,0) INTO iCantidadPaq FROM "informix".ss_paquetescheques
				WHERE empresa = p_sEmpresa AND numerocaja = p_sNumeroCaja AND sucursal = p_sSucursal
				AND fecharegistro = p_dFechaRegistro AND secuencia = p_sSecuencia;
				
					IF (SELECT count(1) FROM bdisuc:"informix".ss_paquetescheques WHERE empresa = p_sEmpresa 
									AND numerocaja = p_sNumeroCaja AND sucursal = p_sSucursal AND fecharegistro = p_dFechaNueva  AND secuencia = p_sSecuencia) > 0 THEN
						SELECT NVL(MAX(secuencia::INTEGER),0)
						INTO iSecuencia
						FROM "informix".ss_paquetescheques
						WHERE empresa = p_sEmpresa
						AND sucursal = p_sSucursal
						AND fecharegistro = p_dFechaNueva;
						LET iSecuencia = iSecuencia + 1;
					ELSE
						LET iSecuencia = NVL(p_sSecuencia::INTEGER,0);
					END IF;
				
				
					UPDATE bdisuc:"informix".ss_paquetescheques
					SET sucursal = p_sSucursal, estatus = p_sEstatus, usuarioregistra = p_sUsuarioRegistro,
					usuarioautoriza = p_sUsuarioAutoriza, usuariosolicita = p_sUsuarioSolicita,
					comentario = p_sComentario,
					fecharegistro = p_dFechaNueva,
					cantidad_hojas = p_iCantHojas,
					secuencia = TRIM(NVL(iSecuencia::CHAR(5),''))
					WHERE empresa = p_sEmpresa 
					AND sucursal = p_sSucursal
					AND numerocaja = p_sNumeroCaja
					AND fecharegistro = p_dFechaRegistro
					AND estatus <> 'E'
					AND secuencia = p_sSecuencia;
					
					
					
					SELECT SUM(cantidad_hojas) 
					INTO iCantidad
					FROM "informix".ss_paquetescheques
					WHERE empresa = p_sEmpresa
					AND numerocaja = p_sNumeroCaja
					AND sucursal = p_sSucursal
					AND estatus <> 'E';

					UPDATE "informix".ss_numcajas
					SET num_hojas_registradas = NVL(iCantidad,0)
					WHERE empresa = p_sEmpresa
					AND numerocaja = p_sNumeroCaja
					AND numsucursal = p_sSucursal
					AND estatus = 'Activa'
					AND tipopaquete = 5;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
						LET v_sValRetorno = "00001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
					ELSE
						LET v_sValRetorno = '00000';
					END IF;
		END IF;
		RETURN v_sValRetorno,'',TRIM(NVL(iSecuencia::CHAR(5),''));
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Vladimir Felix Galvez',
'FECHA:       04-Agosto-2009',
'CASO DE USO: Caso de Uso asociado: PCU-bdisuc\CU-0012-GrabarPaqueteCheques-SPL',
'DESCRIPCION: Guarda o actualiza la informacion de los documentos de paquete de cheques.',
'MODIFICADO:  Fabiola Corrales 15/Oct/2009. Se modifica para agregar los campos usuarioregistra, usuarioautoriza, usuariosolicita, comentario',
'MODIFICA:      Victor Hugo NuÃ±ez',
'FECHA:       30-Agosto-2012',
'DESCRIPCION: Se elimina el ciclo para agregar paquetes como no registrados si hay fechas separadas.',
'MODIFICO: Josue Zepeda',  
'FECHA:       26/Febrero/2013',
'BD: bdisuc',
'DESCRIPCION: Se inhibe parametro de p_sTipoCheque y se agrega parametro p_dFechaNueva',
'ELABORO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR LA CANTIDAD DE HOJAS QUE TIENE LA CAJA',
'ADEMAS DE SUMAR EL NUMERO TOTAL Y ACTUALIZAR EL NUMERO DE HOJAS REGISTRADAS.',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_grabarpaquetesoperativos_web(p_sEmpresa CHAR(3), p_sNumCaja CHAR(10),p_dFechaRegistro DATE, p_sSucursal CHAR(4), 
											p_sEstatus CHAR(1), p_iTipoGrabacion SMALLINT, p_sUsuarioRegistro CHAR(8),p_sUsuarioAutoriza CHAR(8),
											p_sUsuarioSolicita CHAR(8), p_sComentario CHAR(100),p_dFechaNueva DATE,piCantHojas INTEGER,p_sSecuencia CHAR(5))
				 
	RETURNING 	CHAR(5) AS retorno,
	CHAR(10) AS NumeroCaja,
	CHAR(5)  AS Secuencia;
	
	DEFINE iSqlErr				INTEGER;
	DEFINE v_sValRetorno		CHAR(5);	
	DEFINE v_dFechaInsercion	DATE;
	DEFINE v_dFechaRegistro		DATE;
	DEFINE v_iCiclo				INTEGER;
	DEFINE i					INTEGER;
	--folio_1668
	DEFINE iCapacidad			INTEGER;
	DEFINE iCantidad 			INTEGER;
	DEFINE iNumReg				INTEGER; 	
	DEFINE iTotSuma				INTEGER;
	DEFINE iCantidadPaq			INTEGER;
	DEFINE iResta				INTEGER;
	DEFINE iSuma				INTEGER;
	DEFINE iBandera				INTEGER;
	DEFINE cNumeroCaja			CHAR(10);
	DEFINE iSecuencia           INTEGER;
	
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/respaldosbd/sp_grabarpaquetesoperativos.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	
	LET v_sValRetorno 		= '00001';
	LET v_dFechaInsercion 	= CURRENT::DATE;
	LET v_dFechaRegistro 	= CURRENT::DATE;
	LET v_iCiclo 			= 0;
	--folio_1668
	LET iCapacidad 			= 0;
	LET iCantidad 			= 0;
	LET iNumReg 			= 0;
	LET iTotSuma 			= 0;
	LET iCantidadPaq 		= 0;
	LET iResta 				= 0;
	LET iSuma 				= 0;
	LET iBandera 			= 0;
	LET cNumeroCaja			= "";
	LET iSecuencia          = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr, NVL(cNumeroCaja,''), TRIM(nvl(iSecuencia::CHAR(5),''));
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sNumCaja,'')='' OR NVL(p_dFechaRegistro,'')=''
		OR NVL(p_sSucursal,'')='' OR NVL(p_sEstatus,'')='' OR NVL(p_iTipoGrabacion,'') = ''
		OR NVL(piCantHojas,0) = 0 THEN
		
			RETURN v_sValRetorno,NVL(cNumeroCaja,''), TRIM(nvl(iSecuencia::CHAR(5),''));
		END IF;
		
		
		SELECT FIRST 1 NVL(numerocaja,'')
		INTO cNumeroCaja
		FROM "informix".ss_paquetesoperativos 
		WHERE empresa = p_sEmpresa
		AND sucursal = p_sSucursal
		AND fecharegistro = p_dFechaNueva
		AND numerocaja <> p_sNumCaja
		AND estatus <> 'E';
		
		IF NVL(cNumeroCaja,'') <> '' THEN
			LET v_sValRetorno = '00003';
			RETURN v_sValRetorno, cNumeroCaja, TRIM(nvl(iSecuencia::CHAR(5),''));
		END IF;
		
		-- Se obtiene la capacidad actual de la caja
		SELECT cja.num_hojas_registradas, pte.capacidad 
		INTO iNumReg, iCapacidad
		FROM "informix".ss_numcajas cja, "informix".ss_cattipopaquetes pte 
		WHERE cja.tipopaquete = pte.tipopaquete 
		AND cja.numerocaja = p_sNumCaja 
		AND cja.estatus = 'Activa'
		AND pte.tipopaquete = '2';
		
		IF iNumReg IS NULL THEN
		  
		  LET iNumReg = 0;
		
		END IF;
		
		--SI NO EXISTE GUARDA, SI EXISTE ACTUALIZA
		IF (SELECT COUNT(1) fecharegistro FROM "informix".ss_paquetesoperativos 
		WHERE empresa = p_sEmpresa AND fecharegistro = p_dFechaRegistro 
		AND sucursal = p_sSucursal AND estatus <> 'E' and secuencia = p_sSecuencia) = 0 THEN


			    SELECT NVL(MAX(secuencia::INTEGER),0)
				INTO iSecuencia
				FROM "informix".ss_paquetesoperativos
				WHERE empresa = p_sEmpresa
				AND sucursal = p_sSucursal
				AND fecharegistro = p_dFechaRegistro;
				
				LET iSecuencia = iSecuencia + 1;
				
				
				--PERMITE REALIZAR LA INSERCCION O ACTUALIZACION
				--SE GUARDA EL PAQUETE OPERATIVO DE LA FECHA PROPORCIONADA
				INSERT INTO "informix".ss_paquetesoperativos (empresa, numerocaja, fecharegistro, sucursal, estatus, 
				usuarioregistra, usuarioautoriza, usuariosolicita, comentario, fecha_insert,cantidad_hojas,secuencia)
				VALUES (p_sEmpresa, p_sNumCaja, p_dFechaRegistro, p_sSucursal, p_sEstatus, NVL(p_sUsuarioRegistro,''),NVL(p_sUsuarioAutoriza,''), NVL(p_sUsuarioSolicita,''), NVL(p_sComentario,''), v_dFechaInsercion,piCantHojas,TRIM(nvl(iSecuencia::CHAR(5),'')));
				
				SELECT SUM(cantidad_hojas) 
				INTO iCantidad
				FROM "informix".ss_paquetesoperativos
				WHERE empresa = p_sEmpresa
				AND numerocaja = p_sNumCaja
				AND sucursal = p_sSucursal
				AND estatus <> 'E';

				UPDATE "informix".ss_numcajas
				SET num_hojas_registradas = iCantidad
				WHERE empresa = p_sEmpresa
				AND numerocaja = p_sNumCaja
				AND numsucursal = p_sSucursal
				AND estatus = 'Activa'
				AND tipopaquete = 2;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
					LET v_sValRetorno = "00001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
				ELSE
					LET v_sValRetorno = '00000';
				END IF;
							
		ELSE
			--SI ES ACTUALIZACION
			
			
				SELECT NVL(cantidad_hojas,0) INTO iCantidadPaq FROM "informix".ss_paquetesoperativos
				WHERE empresa = p_sEmpresa AND numerocaja = p_sNumCaja AND sucursal = p_sSucursal
				AND fecharegistro = p_dFechaRegistro AND secuencia = p_sSecuencia AND estatus <> 'E';
				
					IF (SELECT COUNT(1) fecharegistro FROM "informix".ss_paquetesoperativos 
					WHERE empresa = p_sEmpresa AND fecharegistro = p_dFechaNueva 
					AND sucursal = p_sSucursal AND estatus <> 'E' and secuencia = p_sSecuencia) = 0 THEN   
					
						UPDATE "informix".ss_paquetesoperativos 
						SET estatus = p_sEstatus, usuarioregistra = p_sUsuarioRegistro,
						usuarioautoriza = p_sUsuarioAutoriza,
						usuariosolicita = p_sUsuarioSolicita,
						comentario = p_sComentario,
						cantidad_hojas = piCantHojas,
						fecharegistro = p_dFechaNueva
						WHERE empresa = p_sEmpresa 
						AND fecharegistro = p_dFechaRegistro
						AND numerocaja = p_sNumCaja
						AND sucursal = p_sSucursal
						AND secuencia = p_sSecuencia;
					ELSE
						SELECT NVL(MAX(secuencia::INTEGER),0)
						INTO iSecuencia
						FROM "informix".ss_paquetesoperativos
						WHERE empresa = p_sEmpresa
						AND sucursal = p_sSucursal
						AND fecharegistro = p_dFechaNueva;
						
						LET iSecuencia = iSecuencia + 1;
						
						
						UPDATE "informix".ss_paquetesoperativos 
						SET estatus = p_sEstatus, usuarioregistra = p_sUsuarioRegistro,
						usuarioautoriza = p_sUsuarioAutoriza,
						usuariosolicita = p_sUsuarioSolicita,
						comentario = p_sComentario,
						cantidad_hojas = piCantHojas,
						fecharegistro = p_dFechaNueva,
						secuencia = TRIM(nvl(iSecuencia::CHAR(5),''))
						WHERE empresa = p_sEmpresa 
						AND fecharegistro = p_dFechaRegistro
						AND numerocaja = p_sNumCaja
						AND sucursal = p_sSucursal
						AND secuencia = p_sSecuencia;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
							LET v_sValRetorno = "00001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
						ELSE
							LET v_sValRetorno = '00000';
						END IF;

					END IF;				
						
						--SE ACTUALIZA EL NUMERO DE HOJAS REGISTRADAS POR LA CANTIDAD TOTAL DE HOJAS
						SELECT SUM(cantidad_hojas) 
						INTO iCantidad
						FROM "informix".ss_paquetesoperativos
						WHERE empresa = p_sEmpresa
						AND numerocaja = p_sNumCaja
						AND sucursal = p_sSucursal
						AND estatus <> 'E';

						UPDATE "informix".ss_numcajas
						SET num_hojas_registradas = iCantidad
						WHERE empresa = p_sEmpresa
						AND numerocaja = p_sNumCaja
						AND numsucursal = p_sSucursal
						AND estatus = 'Activa'
						AND tipopaquete = 2;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
							LET v_sValRetorno = "00001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
						ELSE
							LET v_sValRetorno = '00000';
						END IF;
		END IF;
			
		RETURN v_sValRetorno, cNumeroCaja, TRIM(nvl(iSecuencia::CHAR(5),''));
	END;
END PROCEDURE
DOCUMENT
'CREADO: Erick Zamora',
'FECHA: 03/Agosto/2009',
'DESCRIPCION: Guarda o actualiza la informacion de un paquete operativo',
'CASO DE USO: Caso de Uso asociado PCU-bdisuc\CU-0005-GrabarPaquetesOperativos-SPL',
'MODIFICADO:  fabiola Corrales 16/Oct/2009. Se modifica para agregar el usuarioregistra, usuarioautoriza, usuariosolicita y comentario',
'MODIFICO: Victor Hugo NuÃ±ez',
'FECHA: 030/Agosto/2012',
'DESCRIPCION: Se elimina la validacion para grabar paquetes sin registrar en caso de fechas separadas',
'MODIFICO: Josue Zepeda',  
'FECHA:       28/Febrero/2013',
'BD: bdisuc',
'DESCRIPCION: se agrega parametro p_dFechaNueva para la actualizacion',
'MODIFICO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA REALIZAR LAS CONSULTAS SOBRE LA CAPACIDAD,NUMERO DE HOJAS',
'REGISTRADAS Y LA CANTIDAD DE HOJAS QUE TIENE UN PAQUETE PARA SABER SI PODRA ACTUALIZARSE O INSERTARSE',
'VERSION: 20141014.0952',
'BD: BDISUC',
'ELABORO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR LA CANTIDAD DE HOJAS QUE TIENE LA CAJA',
'ADEMAS DE SUMAR EL NUMERO TOTAL Y ACTUALIZAR EL NUMERO DE HOJAS REGISTRADAS.',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_guarda_bitacora_ws_web(pempresa CHAR(3),
								pSucursal Char(4),
								pCodigo_Motor CHAR(5),
								pDescripcion_Codigo_Motor CHAR(30),
								pCodigo_ws CHAR(3),
								pDescripcion_Codigo_ws  CHAR(200),
								pCadena_ent CHAR(600),
								pNotas CHAR(500),
								pUsuario CHAR(8),
								pFecha_Hora_Insert DATETIME YEAR TO SECOND)
								
RETURNING CHAR(5) as cCodRet;

--Declarar variables
DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vFecha CHAR(20);

-- inicializar variables
LET vcodret = '00000';
LET vsqlerr = 0;
--SET DEBUG FILE TO "/home/sysifx/OmarLerma/sp_guarda_bitacora_ws_web.out";
--TRACE ON;


BEGIN

	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
		  LET vcodret=vsqlerr;
		  RETURN vcodret;
	   END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	IF( NVL(pempresa,'') = '' OR NVL(pSucursal,'') = ''  OR NVL(pCodigo_Motor,'') = '' OR NVL(pFecha_Hora_Insert,'') = '' 
	   OR  NVL(pUsuario,'') = '') THEN	
		
		LET vcodret = "00002";
	ELSE
		IF (SELECT COUNT(*) FROM  "informix".ss_bitacora_panamericano_errores WHERE user_insert  = pUsuario AND fecha_hora_insert = pFecha_Hora_Insert) = 0 THEN
				
			INSERT INTO  "informix".ss_bitacora_panamericano_errores (empresa,codigo_motor,descripcion_codigo_motor,codigo_ws,descripcion_codigo_ws,Sucursal,cadena_ent,Notas,user_insert,fecha_hora_insert) 
			VALUES (pempresa,pCodigo_Motor,pDescripcion_Codigo_Motor,pCodigo_ws,pDescripcion_Codigo_ws,pSucursal,pCadena_ent,pNotas,pUsuario,pFecha_Hora_Insert);
		ELSE	
			LET vcodret = "00001";
		END IF;
	END IF;

END; 

RETURN vcodret;
END PROCEDURE
DOCUMENT
'FOLIO: 342',
'AUTOR: OMAR LERMA, OMAR GOMEZ',
'FECHA: 03/01/2018',
'MODIFICACIÃN: SE CREA SP PARA GUARDAR BITACORA DE LA EJECUCION DE WS PANAMERICANO',
'SOLICITA: ABRAHAM NERVAEZ',
'DB:BDISUC';

CREATE PROCEDURE "informix".sp_arqueossuc_atm_web(pempresa CHAR(3), psucursal CHAR(4),
											pcajeroprincipal CHAR(8), 
											pfolio_suc CHAR(16),
                                            ptransacc CHAR(4), pdivisa CHAR(2),
                                            psaldototal money(14,2), 
											pfecha DATE,
											pdeno1 CHAR(18), pdeno2 CHAR(18),
											pdeno3 CHAR(18), pdeno4 CHAR(18),
											pdeno5 CHAR(18), pdeno6 CHAR(18),
											pdeno7 CHAR(18), pdeno8 CHAR(18),
											pdeno9 CHAR(18), pdeno10 CHAR(18),
											pdeno11 CHAR(18), pdeno12 CHAR(18),
											pdeno13 CHAR(18), pdeno14 CHAR(18),
											pdeno15 CHAR(18), pcant1 FLOAT(8),
											pcant2 FLOAT(8), pcant3 FLOAT(8),
											pcant4 FLOAT(8),pcant5 FLOAT(8),
											pcant6 FLOAT(8), pcant7 FLOAT(8),
											pcant8 FLOAT(8), pcant9 FLOAT(8),
											pcant10 FLOAT(8),pcant11 FLOAT(8),
											pcant12 FLOAT(8), pcant13 FLOAT(8),
											pcant14 FLOAT(8), pcant15 FLOAT(8))

RETURNING CHAR(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;

LET vcodret = "000";
	BEGIN
	ON EXCEPTION SET vsqlerr,visamerr
	IF vsqlerr != 0 THEN
		LET vcodret=vsqlerr;
		RETURN vcodret;
	END IF;
	END EXCEPTION;
	
	--- Verifica recepcion correcta de datos
	IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or pdivisa = '0' or pdivisa = ''  
		or pcajeroprincipal = '0' or pcajeroprincipal = '' then
		LET vcodret = "110";
	ELSE
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF (SELECT COUNT(sucursal) FROM "informix".ss_saldossuc WHERE sucursal = psucursal and fecha = pfecha) > 0 THEN
		
			DELETE FROM "informix".ss_saldossuc WHERE sucursal = psucursal and fecha = pfecha;
			
			INSERT INTO ss_saldossuc (empresa, sucursal, divisa,saldo_total, fecha, cajero_principal, denominacion_1, denominacion_2, denominacion_3, 
			denominacion_4,denominacion_5,denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, 
			denominacion_13, denominacion_14, denominacion_15, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5,cantidad_6,cantidad_7,cantidad_8, 
			cantidad_9,cantidad_10,cantidad_11,cantidad_12, cantidad_13,cantidad_14,cantidad_15)
			VALUES (pempresa, psucursal, pdivisa, psaldototal, pfecha, pcajeroprincipal, pdeno1, pdeno2, pdeno3, pdeno4, pdeno5, pdeno6, pdeno7, pdeno8,
			pdeno9, pdeno10, pdeno11, pdeno12, pdeno13, pdeno14, pdeno15, pcant1, pcant2, pcant3, pcant4, pcant5, pcant6, pcant7, pcant8, pcant9, pcant10,
			pcant11, pcant12, pcant13, pcant14, pcant15);
		
		ELSE
		
			INSERT INTO ss_saldossuc (empresa, sucursal, divisa,saldo_total, fecha, cajero_principal, denominacion_1, denominacion_2, denominacion_3, 
			denominacion_4,denominacion_5,denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, 
			denominacion_13, denominacion_14, denominacion_15, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5,cantidad_6,cantidad_7,cantidad_8, 
			cantidad_9,cantidad_10,cantidad_11,cantidad_12, cantidad_13,cantidad_14,cantidad_15)
			VALUES (pempresa, psucursal, pdivisa, psaldototal, pfecha, pcajeroprincipal, pdeno1, pdeno2, pdeno3, pdeno4, pdeno5, pdeno6, pdeno7, pdeno8,
			pdeno9, pdeno10, pdeno11, pdeno12, pdeno13, pdeno14, pdeno15, pcant1, pcant2, pcant3, pcant4, pcant5, pcant6, pcant7, pcant8, pcant9, pcant10,
			pcant11, pcant12, pcant13, pcant14, pcant15);
		
		END IF;
	END IF;       
		
	RETURN vcodret;
	END;
END PROCEDURE;