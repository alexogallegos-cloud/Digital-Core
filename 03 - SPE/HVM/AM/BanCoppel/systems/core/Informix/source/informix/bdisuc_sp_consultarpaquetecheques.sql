CREATE PROCEDURE "informix".sp_consultarpaquetecheques(p_sEmpresa CHAR(3), p_sSucursal CHAR(4),--p_sTipoCheque CHAR(1),
				p_sNumeroCaja CHAR(10), p_dFecha DATE, p_iCantRegistros INTEGER, p_cOpcion CHAR(1), p_sScuencia CHAR(5))

	RETURNING 	CHAR(6)  AS retorno,	
				CHAR(3)  AS empresa,	
				CHAR(10) AS numerocaja, 
				CHAR(1)  AS tipocheque,
				DATE     AS fecharegistro, 
				CHAR(4)  AS sucursal, 
				CHAR(1)  AS estatus, 
				DATE     AS fechainsercion,
				CHAR(8)  AS numUsuarioRegistro,
				CHAR(45) AS desUsuarioRegistro,
				CHAR(8)  AS numUsuarioAutorizo,
				CHAR(45) AS desUsuarioAutorizo,
				CHAR(8)  AS numUsuarioSolicita,
				CHAR(45) AS desUsuarioSolicita,
				CHAR(100) AS desComentario,
				INTEGER		AS iHojasDoc,
				INTEGER 	AS iNumHojasReg,
				INTEGER 	AS iCapacidad,
				CHAR(5)     AS sSecuencia;
					

	--VARIABLES DE ERROR DEL SP
    DEFINE cVarDataErr			VARCHAR(255);
    DEFINE iSqlErr				INTEGER;
    DEFINE iSamErr				INTEGER;

	--DECLARACIÓN DE VARIABLES DE USO DEL SP
	DEFINE v_sValRetorno			CHAR(6);
	DEFINE v_sNumeroCaja 			CHAR(10);
	DEFINE v_sTipoCheques			CHAR(1);
	DEFINE v_dFechaRegistro			DATE;
	DEFINE v_sSucursal				CHAR(4);
	DEFINE v_sEstatus				CHAR(1);
	DEFINE v_dFechaInsercion		DATE;
	DEFINE v_iNumRegistro			INTEGER;
	DEFINE v_sNumUsuarioRegistro	CHAR(8);
	DEFINE v_sDesUsuarioRegistro	CHAR(45);
	DEFINE v_sNumUsuarioAutorizo	CHAR(8);
	DEFINE v_sDesUsuarioAutorizo	CHAR(45);
	DEFINE v_sNumUsuarioSolicita	CHAR(8);
	DEFINE v_sDesUsuarioSolicita	CHAR(45);
	DEFINE v_sDesComentario			CHAR(100);
	DEFINE iHojasDocumento			INTEGER;
	DEFINE iCantidad 				INTEGER;
	DEFINE iCapacidad				INTEGER;
	DEFINE cSecuencia               CHAR(5);
	
	-----------------------------------------------------------------------	
	--Debug del Procedure
	--SET DEBUG FILE TO "/tmp/vladi/sp_consultarpaquetecheques.out";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno 		= '000001';
	LET v_sNumeroCaja 		= '';
	LET v_sTipoCheques 		= '';
	LET v_dFechaRegistro 	= '';
	LET v_sSucursal 		= '';
	LET v_sEstatus 			= '';
	LET v_dFechaInsercion 	= '';
	LET v_iNumRegistro = 0;
	LET iHojasDocumento = 0;
	LET iCantidad = 0;
	LET iCapacidad = 0;
	LET cSecuencia = '';
	BEGIN

		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;
				RETURN iSqlErr,'','','','','','','','','','','','','','',0,0,0,'';
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF NVL(p_cOpcion,'') = '' OR p_cOpcion NOT IN ('1','2') THEN 
			RETURN v_sValRetorno,'','','','','','','','','','','','','','',0,0,0,'';
		END IF;
		
		IF p_cOpcion = '2' THEN
			IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumeroCaja,'') = '' OR NVL(p_sSucursal,'') = '' OR NVL(p_dFecha,'') = '' THEN
				RETURN v_sValRetorno,'','','','','','','','','','','','','','',0,0,0,'';
			END IF;
			
			UPDATE "informix".ss_paquetescheques 
			SET estatus='E' 
			WHERE empresa = p_sEmpresa 
			AND numerocaja = p_sNumeroCaja 
			AND sucursal = p_sSucursal 	
			AND fecharegistro = p_dFecha
			AND secuencia = p_sScuencia;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET v_sValRetorno = '000002'; 
				RETURN v_sValRetorno,'','','','','','','','','','','','','','',0,0,0,'';
			END IF;
			
			LET p_dFecha = '';
			--SE ACTUALIZA EL NUMERO DE HOJAS REGISTRADAS POR LA CANTIDAD TOTAL DE HOJAS
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
		
		END IF;
		
		IF p_cOpcion = '1' OR p_cOpcion = '2' THEN
			--LOS PARAMETROS NO DEBEN SER NULOS
			IF NVL(p_sEmpresa, '') = '' OR NVL(p_sSucursal, '') = '' THEN --OR NVL(p_sTipoCheque, '') = '' THEN
				RETURN v_sValRetorno,'','','','','','','','','','','','','','',0,0,0,'';
			END IF;

			--SI NO SE ESPECIFICAN ESTOS CAMPOS SE REALIZA LA BUSQUEDA CON LOS PARAMETROS REQUERIDOS.
			IF p_sNumeroCaja = '' THEN
				LET p_sNumeroCaja = NULL;
			END IF;

			IF p_dFecha = '' THEN
				LET p_dFecha = NULL;
			END IF;
			
			SELECT NVL(cja.num_hojas_registradas,0), NVL(pte.capacidad,0)
			INTO iCantidad, iCapacidad
			FROM "informix".ss_numcajas cja, "informix".ss_cattipopaquetes pte
			WHERE pte.tipopaquete = cja.tipopaquete 
			AND cja.numerocaja = p_sNumeroCaja 
			ANd cja.numsucursal = p_sSucursal
			AND pte.tipopaquete = '5';
			
			--Consultar la información de los paquetes de cheques.
			FOREACH
				SELECT SKIP p_iCantRegistros empresa, numerocaja, tipocheques, fecharegistro, sucursal, estatus, usuarioregistra, 
				usuarioautoriza, usuariosolicita, comentario, fecha_insert, cantidad_hojas, secuencia
				INTO p_sEmpresa, v_sNumeroCaja, v_sTipoCheques, v_dFechaRegistro, v_sSucursal, v_sEstatus, v_sNumUsuarioRegistro,
				v_sNumUsuarioAutorizo, v_sNumUsuarioSolicita, v_sDesComentario, v_dFechaInsercion, iHojasDocumento, cSecuencia
				FROM bdisuc:"informix".ss_paquetescheques
				WHERE empresa = p_sEmpresa
				AND sucursal = p_ssucursal
				--AND tipocheques = p_sTipoCheque
				AND numerocaja = NVL(p_sNumeroCaja, numerocaja)
				AND fecharegistro = NVL(p_dFecha, fecharegistro)
				AND estatus <> 'E'
				ORDER BY fecharegistro

				--OBTIENE EL NOMBRE DEL USUARIO QUE REGISTRA
				IF NVL(v_sNumUsuarioRegistro,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioRegistro 
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioRegistro;
				ELSE
					LET v_sDesUsuarioRegistro = '';
				END IF
				
				--OBTIENE EL NOMBRE DEL USUARIO QUE AUTORIZA
				IF NVL(v_sNumUsuarioAutorizo,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioAutorizo 
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioAutorizo;
				ELSE
					LET v_sDesUsuarioAutorizo = '';
				END IF
				
				--OBTIENE EL NOMBRE DEL USUARIO QUE SOLICITA
				IF NVL(v_sNumUsuarioSolicita,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioSolicita
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioSolicita;
				ELSE 
					LET v_sDesUsuarioSolicita = '';
				END IF			
				
				LET v_sValRetorno = '000000';
				
				RETURN v_sValRetorno, p_sEmpresa, v_sNumeroCaja, v_sTipoCheques, v_dFechaRegistro, v_sSucursal,
				v_sEstatus, v_dFechaInsercion, v_sNumUsuarioRegistro, v_sDesUsuarioRegistro, v_sNumUsuarioAutorizo,
				v_sDesUsuarioAutorizo, v_sNumUsuarioSolicita, v_sDesUsuarioSolicita, v_sDesComentario, iHojasDocumento, iCantidad, iCapacidad, cSecuencia WITH RESUME;

			END FOREACH;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Vladimir Félix Gálvez',
'FECHA:       04-Agosto-2009',
'CASO DE USO: Caso de uso asociado: PCU-bdisuc\CU-0011-ConsultarPaqueteCheques-SPL',
'DESCRIPCION: Consultar la información de la documentación de los paquetes de cheques. Datos de Entrada Requeridos: Empresa, Sucursal y el tipo de Cheque. Datos de Entrada Opcionales: numero de la caja y la fecha.',
'MODIFICADO:  Fabiola Corrales 16/Oct/2009. Se modifica para agregar los campos usuario que registra, autoriza, solicita y comentario',
'MODIFICO: Victor Hugo Nuñez',  
'FECHA:       30/Agosto/2012',
'BD: bdisuc',
'DESCRIPCION: Se organiza por fecha de registro, se elimina filtro por tipo de cheque',
'MODIFICO: Josue Zepeda',  
'FECHA:       26/Febrero/2013',
'BD: bdisuc',
'DESCRIPCION: Se inhibe parametro de p_sTipoCheque',
'MODIFICO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA CONSULTAR LA CANTIDAD DE HOJAS QUE TIENE LA CAJA',
'Y EL NUMERO DE HOJAS REGISTRADAS.',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_consultarcardcarriers(p_sEmpresa CHAR(3), p_sSucursal CHAR(10), p_sTipoImagen CHAR(1), p_sFolio CHAR(16), 
											p_sNumCaja CHAR(10), p_iNumPaquete INTEGER,
											p_iCantRegistros INTEGER,p_cOpcion CHAR(1),
											p_sSecuencia CHAR(5))
	RETURNING	CHAR(6)  	AS retorno, 
				CHAR(3)  	AS empresa, 
				CHAR(10) 	AS numerocaja,
				CHAR(1)  	AS tipoimagen,
				INTEGER  	AS numeropaquete,
				CHAR(16) 	AS folioinicio,
				CHAR(16) 	AS foliofinal,
				CHAR(4)  	AS sucursal,
				CHAR(1)  	AS estatus,
				DATE     	AS fecha_insert,
				CHAR(80) 	AS desimagen,
				CHAR(8)  	AS numUsuarioRegistro,
				CHAR(45) 	AS desUsuarioRegistro,
				CHAR(8)  	AS numUsuarioAutorizo,
				CHAR(45) 	AS desUsuarioAutorizo,					
				CHAR(8)  	AS numUsuarioSolicita,
				CHAR(45) 	AS desUsuarioSolicita,
				CHAR(100) 	AS desComentario,
				--folio_1668
				INTEGER 	AS iCantHojas,
				INTEGER 	AS iCapacidad,
				INTEGER 	AS iCantDocs,
				CHAR(5)		AS sSecuencia;	
				
	
	DEFINE iSqlErr					INTEGER;
	DEFINE v_sValRetorno			CHAR(6);
	DEFINE v_sEmpresa				CHAR(3);
	DEFINE v_sNumCaja 				CHAR(10);
	DEFINE v_sTipoImagen			CHAR(1);
	DEFINE v_sFolioInicio			CHAR(16);
	DEFINE v_sFolioFinal			CHAR(16);
	DEFINE v_sSucursal				CHAR(4);
	DEFINE v_sEstatus				CHAR(1);
	DEFINE v_iNumPaquete			INTEGER;	
	DEFINE v_dFechaInsercion		DATE;	
	DEFINE v_iFolio					INT8;
	DEFINE v_iFolioInicio			INT8;
	DEFINE v_iFolioFinal			INT8;
	DEFINE v_sDesimagen				CHAR(80);
	DEFINE v_sNumUsuarioRegistro	CHAR(8);
	DEFINE v_sDesUsuarioRegistro	CHAR(45);
	DEFINE v_sNumUsuarioAutorizo	CHAR(8);
	DEFINE v_sDesUsuarioAutorizo	CHAR(45);
	DEFINE v_sNumUsuarioSolicita	CHAR(8);
	DEFINE v_sDesUsuarioSolicita	CHAR(45);
	DEFINE v_sDesComentario			CHAR(100);
	--folio_1668
	DEFINE iNumReg					INTEGER;
	DEFINE iCapacidad				INTEGER;	
	DEFINE iCantidad 				INTEGER;
	DEFINE iCantDocs				INTEGER;
	DEFINE iBandUpdate				INTEGER;
	DEFINE sSecuencia				CHAR(5);
	
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_consultarcardcarriers.out";
	--TRACE ON;
	-----------------------------------------------------------------------------	
	
	LET v_sValRetorno 		= '000001';
	--folio_1668
	LET iNumReg 			= 0;
	LET iCapacidad 			= 0;
	LET iCantDocs 			= 0;	
	LET v_sDesComentario 	= '';
	LET iBandUpdate 		= 1;
	LET sSecuencia 			= '';
	BEGIN	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','',0,0,0,'';
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--LOS PARAMETROS NO DEBEN SER NULOS					--folio_1668
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sSucursal,'')='' OR NVL(p_cOpcion,'')='' 
		OR (p_cOpcion NOT IN ('1','2')) THEN
			RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','',0,0,0,'';
		END IF;
		
		-- ACTUALIZA LOS PAQUETES CARDCARRIERS DE UNA SUCURSAL
		IF p_cOpcion = '2' THEN
		
			IF p_sEmpresa = '' OR p_sNumCaja = '' OR p_sSucursal = '' OR p_iNumPaquete = 0 THEN
				RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','',0,0,0,'';
			END IF;
		
			UPDATE "informix".ss_cardcarriers SET estatus='E'  WHERE empresa = p_sEmpresa 
			AND numerocaja = p_sNumCaja AND sucursal = p_sSucursal AND numeropaquete=p_iNumPaquete;
			
			LET iBandUpdate = 1;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET v_sValRetorno = '000002'; 
					RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','',0,0,0,'';
				END IF;
				
				IF iBandUpdate = 1 THEN

					UPDATE "informix".ss_cardcarriers 
					SET numeropaquete = numeropaquete - 1
					WHERE empresa = p_sEmpresa
					AND numerocaja = p_sNumCaja
					AND sucursal = p_sSucursal
					AND numeropaquete > p_iNumPaquete
					AND estatus <> 'E';
					---AND secuencia = p_sSecuencia;
					
					/*IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
						LET v_sValRetorno = '000007'; 
						RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','',0,0,0,'';
					END IF;*/
					
					--SE ACTUALIZA EL NUMERO DE HOJAS REGISTRADAS POR LA CANTIDAD TOTAL DE HOJAS
					SELECT NVL(SUM(cantidad_hojas),0) 
					INTO iCantidad
					FROM "informix".ss_cardcarriers
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
					AND tipopaquete = 4;
						
						
					LET v_sValRetorno = '000000';
					
				END IF;		
					
						
					LET v_sEmpresa = NULL;
					LET v_sNumCaja = NULL;
					LET v_sTipoImagen = NULL;
					LET v_iNumPaquete = NULL;
					LET v_sFolioInicio = NULL;
					LET v_sFolioFinal = NULL;
					LET v_sSucursal = NULL;
					LET v_sEstatus = NULL;
					LET v_sDesimagen = NULL;
					LET v_sNumUsuarioRegistro = NULL;
					LET v_sDesUsuarioRegistro = NULL;
					LET v_sNumUsuarioAutorizo = NULL;
					LET v_sDesUsuarioAutorizo = NULL;
					LET v_sDesUsuarioSolicita = NULL;
					LET v_sNumUsuarioSolicita = NULL;
					LET v_sDesComentario = NULL;
					LET v_dFechaInsercion = NULL;
					

				
				RETURN NVL(v_sValRetorno,''), NVL(v_sEmpresa,''), NVL(v_sNumCaja,''), 
				NVL(v_sTipoImagen,''), NVL(v_iNumPaquete,''), NVL(v_sFolioInicio,''), 
				NVL(v_sFolioFinal,''),NVL(v_sSucursal,''),NVL(v_sEstatus,''),
				NVL(v_dFechaInsercion,''), NVL(v_sDesimagen,''), NVL(v_sNumUsuarioRegistro,''),
				NVL(v_sDesUsuarioRegistro,''), NVL(v_sNumUsuarioAutorizo,''), 
				NVL(v_sDesUsuarioAutorizo,''), NVL(v_sNumUsuarioSolicita,''),
				NVL(v_sDesUsuarioSolicita,''),NVL(v_sDesComentario,''),iNumReg,iCapacidad,iCantDocs,NVL(sSecuencia,'');		

		END IF;	
		
		-- CONSULTA LOS PAQUETES CARDCARRIERS DE UNA SUCURSAL
		IF p_cOpcion = '1'  THEN
		
			IF p_sFolio = '' THEN
				LET p_sFolio = NULL;
			END IF;

			IF p_sNumCaja = '' THEN
				LET p_sNumCaja = NULL;
			END IF;

			IF p_iNumPaquete = '' THEN
				LET p_iNumPaquete = NULL;
			END IF

			IF p_sTipoImagen = '' THEN
				LET p_sTipoImagen = NULL;
			END IF;
			
			SELECT NVL(a.capacidad,0), NVL(b.num_hojas_registradas,0) 
			INTO iCapacidad,iNumReg 
			FROM "informix".ss_cattipopaquetes a, "informix".ss_numcajas b
			WHERE a.empresa = p_sEmpresa 
			AND b.numerocaja = p_sNumCaja
			AND a.tipopaquete = b.tipopaquete
			AND b.tipopaquete = '4';
		
			--OBTIENE LOS DOCUMENTOS CARDCARRIERS PARA UNA SUCURSAL Y TIPO DE IMAGEN ESPECIFICADO
			FOREACH
				SELECT SKIP p_iCantRegistros b.tipoimagen, NVL(b.descripcion,''), a.empresa, a.folioinicio, a.sucursal, a.foliofinal, a.numerocaja, 
				a.numeropaquete, a.estatus, a.usuarioregistra, a.usuarioautoriza, a.usuariosolicita, a.comentario, 
				a.fecha_insert,a.cantidad_hojas,secuencia
				INTO v_sTipoImagen, v_sDesimagen,v_sEmpresa, v_sFolioInicio,v_sSucursal,v_sFolioFinal, v_sNumCaja, 
				v_iNumPaquete, v_sEstatus, v_sNumUsuarioRegistro, v_sNumUsuarioAutorizo, v_sNumUsuarioSolicita, v_sDesComentario, 
				v_dFechaInsercion,iCantDocs,sSecuencia
				FROM "informix".ss_cardcarriers a, "informix".ss_catcardcarriers b
				--WHERE a.tipoimagen = NVL(p_sTipoImagen, a.tipoimagen ) --dsb-07/08/2012
				WHERE a.empresa = p_sEmpresa 
				AND (NVL(p_sFolio,a.foliofinal)::INT8) BETWEEN (a.folioinicio::INT8) AND (a.foliofinal::INT8)
				AND a.sucursal = p_sSucursal
				AND a.numerocaja = NVL(p_sNumCaja, a.numerocaja)
				AND a.numeropaquete = NVL(p_iNumPaquete, a.numeropaquete) 
				AND b.empresa = a.empresa			
				AND b.tipoimagen = a.tipoimagen
				AND a.estatus <> 'E'
				ORDER BY a.numeropaquete	

				--OBTIENE EL NOMBRE DEL USUARIO QUE REGISTRA
				IF NVL(v_sNumUsuarioRegistro,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioRegistro 
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioRegistro;
				ELSE
					LET v_sDesUsuarioRegistro = '';
				END IF

				--OBTIENE EL NOMBRE DEL USUARIO QUE AUTORIZA
				IF NVL(v_sNumUsuarioAutorizo,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioAutorizo 
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioAutorizo;
				ELSE
					LET v_sDesUsuarioAutorizo = '';
				END IF
				
				--OBTIENE EL NOMBRE DEL USUARIO QUE SOLICITA
				IF NVL(v_sNumUsuarioSolicita,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioSolicita
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioSolicita;
				ELSE 
					LET v_sDesUsuarioSolicita = '';
				END IF
				
				LET v_sValRetorno = '000000';
				
				
				RETURN NVL(v_sValRetorno,''), NVL(v_sEmpresa,''), NVL(v_sNumCaja,''), 
				NVL(v_sTipoImagen,''), NVL(v_iNumPaquete,''), NVL(v_sFolioInicio,''), 
				NVL(v_sFolioFinal,''),NVL(v_sSucursal,''),NVL(v_sEstatus,''),
				NVL(v_dFechaInsercion,''), NVL(v_sDesimagen,''), NVL(v_sNumUsuarioRegistro,''),
				NVL(v_sDesUsuarioRegistro,''), NVL(v_sNumUsuarioAutorizo,''), 
				NVL(v_sDesUsuarioAutorizo,''), NVL(v_sNumUsuarioSolicita,''),
				NVL(v_sDesUsuarioSolicita,''),NVL(v_sDesComentario,''),iNumReg,iCapacidad,iCantDocs,NVL(sSecuencia,'') WITH RESUME;
			END FOREACH;
		END IF;	
			
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Erick Zamora', 
'FECHA:       04/Agosto/2009',
'DESCRIPCION: Consulta los documentos cardcarriers para una sucursal y tipo de imagen epecificado de forma paginada',
'CASO DE USO: Caso de uso asociado: PCU-bdisuc\CU-0009-ConsultarCardCarriers-SPL',
'MODIFICADO:  Fabiola Corrales 16/Oct/2009. Se modifica para agregar los campos usuarioregistra, usuarioautoriza, usuariosolicita, comentario',
'MODIFICO:     Victor Hugo Nuñez', 
'FECHA:       07/Agosto/2012',
'DESCRIPCION: Se remueve el filtro por tipo de imagen',
'MODIFICO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA CONSULTAR LA CANTIDAD DE HOJAS QUE TIENE LA CAJA',
'Y EL NUMERO DE HOJAS REGISTRADAS.',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_consultarexpedientesclientes(p_sEmpresa CHAR(3), p_sNumCliente CHAR(20), p_sNumCaja CHAR(10), 
				p_sTipoDocumento CHAR(1), p_iCantRegistros INTEGER)
				
	RETURNING	CHAR(6) AS retorno, 
				SMALLINT AS cvedocumento,
				CHAR(80) AS documento, 
				CHAR(4) AS numSucursal, 
				CHAR(40) AS desSucursal,
				CHAR(10) AS cajaRegistrada,
				CHAR(10) AS fechaRegistro,
				CHAR(1) AS estatus,
				CHAR(8) AS numUsuarioRegistro,
				CHAR(45) AS desUsuarioRegistro,
				CHAR(8) AS numUsuarioAutorizo,
				CHAR(45) AS desUsuarioAutorizo,
				CHAR(1) AS bloqueado,			
				CHAR(8)  AS numUsuarioSolicita,
				CHAR(45) AS desUsuarioSolicita,
				CHAR(100) AS desComentario,
				CHAR(1) AS cantidad,  --DSB 22/02/2013
				CHAR(3) AS cantidadExp,  --DSB 22/02/2013
				INTEGER AS NumHojasReg,
				INTEGER AS Capacidad;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_iClaveDocto					SMALLINT;
	DEFINE v_sDocumento						CHAR(80);
	DEFINE v_sNumSucursal					CHAR(4);
	DEFINE v_sDesSucursal					CHAR(40);
	DEFINE v_sCajaRegistrada				CHAR(10);
	DEFINE v_sFechaRegistro					CHAR(10);
	DEFINE v_sEstatus						CHAR(1);
	DEFINE v_sNumUsuarioRegistro			CHAR(8);
	DEFINE v_sDesUsuarioRegistro			CHAR(45);
	DEFINE v_sNumUsuarioAutorizo			CHAR(8);
	DEFINE v_sDesUsuarioAutorizo			CHAR(45);
	DEFINE v_iNumRegistro					INTEGER;
	DEFINE v_sbloqueado						CHAR(1);
	DEFINE v_sNumUsuarioSolicita			CHAR(8);
	DEFINE v_sDesUsuarioSolicita			CHAR(45);
	DEFINE v_sDesComentario					CHAR(100);
	DEFINE cCantidad						CHAR(1);   --DSB 22/02/2013
	DEFINE cCantidadExp						CHAR(3);   --DSB 22/02/2013
	DEFINE iCapacidad						INTEGER;	--DSB 14/10/2014
	DEFINE iHojas							INTEGER;	--DSB 14/10/2014
	
	LET cCantidad = '';  --DSB 22/02/2013
	LET cCantidadExp = '';  --DSB 22/02/2013
	LET iHojas = 0; --DSB 14/10/2014
	LET iCapacidad = 0; --DSB 14/10/2014
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarExpedientesClientes.out";
	--TRACE ON;
	-----------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','',iHojas,iCapacidad;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		LET v_sValRetorno = '000001';
		LET v_iNumRegistro = 0;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sNumCliente,'')='' THEN
			RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','',iHojas,iCapacidad;
		END IF;

		IF p_sNumCaja = '' THEN
			LET p_sNumCaja = NULL;
		END IF;

		IF p_sTipoDocumento = '' THEN
			LET p_sTipoDocumento = NULL;
		END IF;
		
		--OBTENER LA CAPACIDAD Y EL NUMERO DE HOJAS DE LA CAJA
		SELECT NVL(paq.capacidad,0), NVL(caj.num_hojas_registradas,0) 
		INTO iCapacidad, iHojas
		FROM "informix".ss_cattipopaquetes paq, "informix".ss_numcajas caj
		WHERE paq.empresa = p_sEmpresa
		AND caj.empresa = paq.empresa
		AND caj.tipopaquete = paq.tipopaquete
		AND caj.numerocaja = p_sNumCaja
		AND paq.tipopaquete = 1;
		
		LET p_sNumCliente = LPAD(TRIM(p_sNumCliente),9,'0');

		FOREACH
			--OBTIENE TODOS LOS DOCUMENTOS QUE TIENE EL CLIENTE REGISTRADOS MAS LOS DOCUMENTOS DEL CLIENTE QUE FALTAN POR CAPTURAR
			SELECT SKIP p_iCantRegistros NVL(cat.cvedocumento,''), NVL(cat.descripcion,''), NVL(ex.sucursal,''), NVL(ex.numerocaja,''), 
			NVL(ex.fecharegistro,''), NVL(ex.estatus,''), NVL(ex.usuarioregistra,''), NVL(ex.usuarioautoriza,''), 
			NVL(cat.bloqueado,''), NVL(ex.usuariosolicita,''), NVL(ex.comentario,''),cat.cantidad,ex.cantidad
			INTO v_iClaveDocto, v_sDocumento, v_sNumSucursal, v_sCajaRegistrada, 
			v_sFechaRegistro, v_sEstatus, v_sNumUsuarioRegistro, v_sNumUsuarioAutorizo, 
			v_sbloqueado, v_sNumUsuarioSolicita, v_sDesComentario,cCantidad,cCantidadExp   --DSB 22/02/2013
			FROM "informix".ss_catdocumentos cat LEFT JOIN "informix".ss_expedientesclientes ex 
			ON(cat.empresa = ex.empresa AND cat.cvedocumento = ex.cvedocumento
			AND ex.empresa = p_sEmpresa
			AND ex.numerocliente = p_sNumCliente
			AND ex.cvedocumento = ex.cvedocumento --para que tome en cuenta los indices
			AND ex.numerocaja = NVL(p_sNumCaja, ex.numerocaja))
			WHERE cat.tipodocumento = NVL(p_sTipoDocumento, cat.tipodocumento)
			AND cat.bloqueado <> 1   --DSB 22/02/2013
			ORDER BY cat.cvedocumento, ex.numerocaja, ex.sucursal

			--SI EL DOCUMENTO ESTA REGISTRADO
			IF v_sCajaRegistrada <> '' THEN
				--OBTIENE EL NOMBRE DE LA SUCURSAL
				SELECT NVL(nombre,'') INTO v_sDesSucursal 
				FROM bdinteg:"informix".si_sucursales
				WHERE empresa = p_sEmpresa
				AND sucursal = v_sNumSucursal;

				--OBTIENE EL NOMBRE DEL USUARIO QUE REGISTRA
				IF NVL(v_sNumUsuarioRegistro,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioRegistro 
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioRegistro;
				ELSE
					LET v_sDesUsuarioRegistro = '';
				END IF

				--OBTIENE EL NOMBRE DEL USUARIO QUE AUTORIZA
				IF NVL(v_sNumUsuarioAutorizo,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioAutorizo 
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioAutorizo;
				ELSE
					LET v_sDesUsuarioAutorizo = '';
				END IF
				
				--OBTIENE EL NOMBRE DEL USUARIO QUE SOLICITA
				IF NVL(v_sNumUsuarioSolicita,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioSolicita
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioSolicita;
				ELSE 
					LET v_sDesUsuarioSolicita = '';
				END IF
			ELSE
				LET v_sDesSucursal = '';
				LET v_sDesUsuarioRegistro = '';
				LET v_sDesUsuarioAutorizo = '';
				LET v_sDesUsuarioSolicita = '';
			END IF;

			LET v_sValRetorno = '000000';

			RETURN v_sValRetorno, v_iClaveDocto, v_sDocumento, v_sNumSucursal, v_sDesSucursal, v_sCajaRegistrada, v_sFechaRegistro, 
			v_sEstatus,v_sNumUsuarioRegistro,v_sDesUsuarioRegistro,v_sNumUsuarioAutorizo,v_sDesUsuarioAutorizo, v_sbloqueado,
			v_sNumUsuarioSolicita, v_sDesUsuarioSolicita, v_sDesComentario,cCantidad,cCantidadExp,iHojas,iCapacidad WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Erick Zamora', 
'FECHA:       01/Agosto/2009',
'DESCRIPCION: Obtiene todos los documentos que tiene el cliente registrados mas los documentos del cliente que faltan por capturar',
'CASO DE USO: Caso de uso asociado PCU-bdisuc\CU-0002-ConsultarExpedientesClientes-SPL',
'MODIFICADO:  Fabiola Corrales 16/Oct/2009. Se modifica para agregar los campos usuariosolicita y comentario',
'MODIFICO:    Josue Zepeda', 
'FECHA:       22/Febrero/2013',
'MODIFICADO:  Se agrega variable into cCantidad,cCantidadExp y tambien variable de retorno cantidad',
'MODIFICO:	  Ernesto Aguilera',
'FECHA:		  17/10/2014',
'DESCRIPCION: Se obtiene y retorna la capacidad y el número de hojas que tiene la caja.';

CREATE PROCEDURE "informix".sp_grabarcardcarriers(p_sempresa CHAR(3), p_sNumeroCaja CHAR(10), p_sTipoImagen CHAR(1), 
											p_iNumeroPaquete INTEGER, p_sFolioInicio CHAR(16), p_sFolioFinal CHAR(16), 
											p_sSucursal CHAR(4),p_sEstatus CHAR(1), p_iTipoGrabacion SMALLINT,
											p_sUsuarioRegistro CHAR(8),p_sUsuarioAutoriza CHAR(8),
											p_sUsuarioSolicita CHAR(8), p_sComentario CHAR(100), p_sTarjetaNuevaIni CHAR(16),
											p_sTarjetaNuevaFin CHAR(16),piCantHojas INTEGER,
											p_Secuencia CHAR(5))

	RETURNING CHAR(6) AS retorno,
			  CHAR(10) AS cNumCaja,
			  INTEGER As Secuencia;

	DEFINE iSqlErr				INTEGER;
	DEFINE v_sValRetorno		CHAR(6);
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

	LET v_sValRetorno = '000001';
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
		/*IF NVL(p_sUsuarioAutoriza,'')='' THEN
			LET p_sUsuarioAutoriza = NULL;
		END IF*/

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
		IF NOT EXISTS (SELECT 1 FROM bdisuc:"informix".ss_cardcarriers WHERE empresa = p_sEmpresa --AND tipoimagen = p_sTipoImagen
		--AND ((v_iFolioInicio BETWEEN folioinicio::INT8 AND foliofinal::INT8)  'DSB 04/03/2013
		--OR (v_iFolioFinal BETWEEN folioinicio::INT8 AND foliofinal::INT8))    'DSB 04/03/2013
		AND ((folioinicio::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal)
		OR (foliofinal::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal))
		AND sucursal = p_sSucursal /*AND secuencia = p_Secuencia */ AND estatus <> 'E') THEN



			SELECT NVL(MAX(secuencia::INTEGER),'0') INTO iSecuencia
			FROM "informix".ss_cardcarriers
			WHERE empresa = p_sEmpresa AND folioinicio = p_sFolioInicio
			AND foliofinal = p_sFolioFinal
			AND sucursal = p_sSucursal ;
			--AND estatus <> 'E';

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
				LET v_sValRetorno = '000000';

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
						LET v_sValRetorno = "000001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
					ELSE
						LET v_sValRetorno = '000000';
					END IF;

				END IF;

		ELSE
			--SI EXISTE CON EL MISMO RANGO DE FOLIOS, SE ACTUALIZA, DE LO CONTRARIO SE MANDA UN --ERROR
			IF EXISTS (SELECT 1 FROM "informix".ss_cardcarriers	WHERE empresa = p_sEmpresa --AND tipoimagen = p_sTipoImagen
			AND folioinicio = p_sFolioInicio AND foliofinal = p_sFolioFinal AND sucursal = p_sSucursal AND estatus <> 'E' AND secuencia = p_Secuencia) THEN

				--SI ES UNA ACTUALIZACION
				IF p_iTipoGrabacion = 2 THEN
					SELECT NVL(cantidad_hojas,0) INTO iCantidadPaq FROM "informix".ss_cardcarriers
					WHERE empresa = p_sEmpresa AND folioinicio = p_sFolioInicio AND foliofinal = p_sFolioFinal
					AND sucursal = p_sSucursal and numerocaja = p_sNumeroCaja AND estatus <> 'E'
					AND secuencia = p_Secuencia;

							IF EXISTS (	SELECT 1 FROM "informix".ss_cardcarriers
							WHERE empresa = p_sEmpresa
							AND folioinicio = p_sTarjetaNuevaIni
							AND foliofinal = p_sTarjetaNuevaFin
							AND sucursal = p_sSucursal
							AND secuencia = p_Secuencia) THEN


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
									LET v_sValRetorno = "000001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
								ELSE
									LET v_sValRetorno = '000000';
								END IF;


				ELSE

					SELECT MAX(numerocaja) --,TRIM(MAX(secuencia))::INTEGER
					INTO cNumCaja --,iSecuencia
					FROM "informix".ss_cardcarriers
					WHERE empresa = p_sEmpresa
					AND ((folioinicio::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal)
					OR (foliofinal::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal))
					AND sucursal = p_sSucursal AND estatus <> 'E';


					LET v_sValRetorno = '000003';
				END IF;
			ELSE

				SELECT MAX(numerocaja) --,TRIM(MAX(secuencia))::INTEGER
				INTO cNumCaja --,iSecuencia
				FROM "informix".ss_cardcarriers
				WHERE empresa = p_sEmpresa
				AND ((folioinicio::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal)
				OR (foliofinal::INT8 BETWEEN v_iFolioInicio AND v_iFolioFinal))
				AND sucursal = p_sSucursal AND estatus <> 'E';

				LET cNumCaja=cNumCaja;
				LET v_sValRetorno = '000002';
			END IF;
		END IF;

		RETURN v_sValRetorno,TRIM(NVL(cNumCaja,'')),iSecuencia;
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Vladimir Félix Gálvez',
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

CREATE PROCEDURE "informix".sp_grabarexpedientesclientes(p_sEmpresa CHAR(3), p_sNumCliente CHAR(20), p_sNumCaja CHAR(10), 
p_iCveDocumento SMALLINT, p_sSucursal CHAR(4), p_sEstatus CHAR(1), p_dFechaRegistro DATE, p_sUsuarioRegistro CHAR(8), 
p_sUsuarioAutoriza CHAR(8), p_sUsuarioSolicita CHAR(8), p_sComentario CHAR(100),p_sCantidad CHAR(3))
									
	RETURNING 	CHAR(6) AS retorno;
	
	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_dFechaInsercion				DATE;
	DEFINE iCapacidad						INTEGER;
	DEFINE iHojas							INTEGER;
	DEFINE iCantidad						INTEGER;
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_grabarExpedientesClientes.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	
	LET v_sValRetorno = '000001';
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
			IF NOT EXISTS (SELECT 1 FROM "informix".ss_expedientesclientes WHERE empresa = p_sEmpresa AND numerocliente = p_sNumCliente 
			AND numerocaja = p_sNumCaja AND cvedocumento = p_iCveDocumento AND sucursal = p_sSucursal AND estatus = 'R') THEN
				
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
				LET v_sValRetorno = "000003"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
			ELSE
				LET v_sValRetorno = '000000';
			END IF;
			
		ELSE
			LET v_sValRetorno = '000002';
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

CREATE PROCEDURE "informix".sp_grabarpaquetecheques(p_sEmpresa CHAR(3), p_sNumeroCaja CHAR(10), --p_sTipoCheque CHAR(1),
													p_dFechaRegistro DATE, p_sSucursal CHAR(4), p_sEstatus CHAR(1),
													p_iTipoGrabacion SMALLINT, p_sUsuarioRegistro CHAR(8), 
													p_sUsuarioAutoriza CHAR(8), p_sUsuarioSolicita CHAR(8), p_sComentario CHAR(100),p_dFechaNueva DATE, p_iCantHojas INTEGER, p_sSecuencia CHAR(5))

	RETURNING CHAR(6) AS retorno,
			  CHAR(10) AS NumeroCaja,
			  CHAR(5) AS Secuencia;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
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

	LET v_sValRetorno = '000001';
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
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sNumeroCaja,'')='' --OR NVL(p_sTipoCheque,'') = ''
		OR NVL(p_dFechaRegistro,'') = '' OR NVL(p_sSucursal,'') = '' OR NVL(p_sEstatus,'') = ''
		OR NVL(p_iTipoGrabacion,'') = '' OR NVL(p_iCantHojas,0) = 0THEN
			RETURN v_sValRetorno,'',TRIM(NVL(iSecuencia::CHAR(5),''));
		END IF;
		
		IF NVL(p_sUsuarioRegistro,'')='' THEN
			LET p_sUsuarioRegistro = NULL;
		END IF;
		/*IF NVL(p_sUsuarioAutoriza,'')='' THEN
			LET p_sUsuarioAutoriza = NULL;
		END IF;*/
		IF NVL(p_sUsuarioSolicita,'')='' THEN
			LET p_sUsuarioSolicita = NULL;
		END IF;
		IF NVL(p_sComentario,'')='' THEN
			LET p_sComentario = NULL;
		END IF;
		
		-- Se busca la fecha en otras cajas, si se encuentra, se retorna error y la caja donde se encontró
		SELECT FIRST 1 numerocaja
		INTO cNumeroCaja
		FROM "informix".ss_paquetescheques 
		WHERE empresa = p_sEmpresa
		AND sucursal = p_sSucursal
		AND fecharegistro = p_dFechaNueva
		AND numerocaja <> p_sNumeroCaja
		AND estatus <> 'E';
		
		IF NVL(cNumeroCaja,'') <> '' THEN
			LET v_sValRetorno = '000003';
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
		IF NOT EXISTS (SELECT 1 FROM bdisuc:"informix".ss_paquetescheques WHERE empresa = p_sEmpresa 
		--AND tipocheques = p_sTipoCheque 
		AND numerocaja = p_sNumeroCaja AND sucursal = p_sSucursal AND fecharegistro = p_dFechaRegistro AND estatus <> 'E' AND secuencia = p_sSecuencia) THEN
						
			--LET iTotSuma = iNumReg + p_iCantHojas;
			--IF iTotSuma <= iCapacidad THEN
				
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
					LET v_sValRetorno = "000001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
				ELSE
					LET v_sValRetorno = '000000';
				END IF;

		ELSE
			--SI ES ACTUALIZACION
				SELECT NVL(cantidad_hojas,0) INTO iCantidadPaq FROM "informix".ss_paquetescheques
				WHERE empresa = p_sEmpresa AND numerocaja = p_sNumeroCaja AND sucursal = p_sSucursal
				AND fecharegistro = p_dFechaRegistro AND secuencia = p_sSecuencia;
				
					IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_paquetescheques WHERE empresa = p_sEmpresa 
									AND numerocaja = p_sNumeroCaja AND sucursal = p_sSucursal AND fecharegistro = p_dFechaNueva  AND secuencia = p_sSecuencia) THEN
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
						LET v_sValRetorno = "000001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
					ELSE
						LET v_sValRetorno = '000000';
					END IF;
		END IF;
		RETURN v_sValRetorno,'',TRIM(NVL(iSecuencia::CHAR(5),''));
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Vladimir Félix Gálvez',
'FECHA:       04-Agosto-2009',
'CASO DE USO: Caso de Uso asociado: PCU-bdisuc\CU-0012-GrabarPaqueteCheques-SPL',
'DESCRIPCION: Guarda o actualiza la informacion de los documentos de paquete de cheques.',
'MODIFICADO:  Fabiola Corrales 15/Oct/2009. Se modifica para agregar los campos usuarioregistra, usuarioautoriza, usuariosolicita, comentario',
'MODIFICA:      Victor Hugo Nuñez',
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

CREATE PROCEDURE "informix".sp_grabarpaquetesoperativos(p_sEmpresa CHAR(3), p_sNumCaja CHAR(10),p_dFechaRegistro DATE, p_sSucursal CHAR(4), 
											p_sEstatus CHAR(1), p_iTipoGrabacion SMALLINT, p_sUsuarioRegistro CHAR(8),p_sUsuarioAutoriza CHAR(8),
											p_sUsuarioSolicita CHAR(8), p_sComentario CHAR(100),p_dFechaNueva DATE,piCantHojas INTEGER,p_sSecuencia CHAR(5))
				 
	RETURNING 	CHAR(6) AS retorno,
	CHAR(10) AS NumeroCaja,
	CHAR(5)  AS Secuencia;
	
	DEFINE iSqlErr				INTEGER;
	DEFINE v_sValRetorno		CHAR(6);	
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
	
	LET v_sValRetorno 		= '000001';
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
			LET v_sValRetorno = '000003';
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
		IF NOT EXISTS (SELECT 1 fecharegistro FROM "informix".ss_paquetesoperativos 
		WHERE empresa = p_sEmpresa AND fecharegistro = p_dFechaRegistro 
		AND sucursal = p_sSucursal AND estatus <> 'E' and secuencia = p_sSecuencia) THEN
			
			--SELECT MAX(fecharegistro) INTO v_dFechaRegistro FROM "informix".ss_paquetesoperativos 
			--WHERE empresa = p_sEmpresa AND sucursal = p_sSucursal;
			
			--dsb-30/08/2012
			/*--SI LA FECHA MAXIMA DE REGISTRO ES MENOR A LA PROPORCIONADA
			IF v_dFechaRegistro IS NOT NULL AND (v_dFechaRegistro + 1 UNITS DAY) < p_dFechaRegistro THEN
				LET v_dFechaRegistro = v_dFechaRegistro + 1 UNITS DAY;
				LET v_iCiclo = p_dFechaRegistro - v_dFechaRegistro;
				--SE AGREGAN PAQUETES OPERATIVOS COMO NO REGISTRADOS POR CADA DIA HASTA LLEGAR A LA FECHA PROPORCIONADA
				IF v_iCiclo > 0 THEN
					FOR i = 1 TO v_iCiclo						
						INSERT INTO bdisuc:"informix".ss_paquetesoperativos (empresa, numerocaja, fecharegistro, sucursal, estatus, 
						usuarioregistra, usuarioautoriza, usuariosolicita, comentario, fecha_insert)
						VALUES (p_sEmpresa, p_sNumCaja, v_dFechaRegistro, p_sSucursal, 'N', 
						'','','','', v_dFechaInsercion);
						
						LET v_dFechaRegistro = v_dFechaRegistro + 1 UNITS DAY;
					END FOR;
				END IF;
			END IF;*/

			    SELECT NVL(MAX(secuencia::INTEGER),0)
				INTO iSecuencia
				FROM "informix".ss_paquetesoperativos
				WHERE empresa = p_sEmpresa
				AND sucursal = p_sSucursal
				AND fecharegistro = p_dFechaRegistro;
				
				LET iSecuencia = iSecuencia + 1;
				
				
				--PERMITE REALIZAR LA INSERCCCION O ACTUALIZACION
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
					LET v_sValRetorno = "000001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
				ELSE
					LET v_sValRetorno = '000000';
				END IF;
							
		ELSE
			--SI ES ACTUALIZACION
			
			
				SELECT NVL(cantidad_hojas,0) INTO iCantidadPaq FROM "informix".ss_paquetesoperativos
				WHERE empresa = p_sEmpresa AND numerocaja = p_sNumCaja AND sucursal = p_sSucursal
				AND fecharegistro = p_dFechaRegistro AND secuencia = p_sSecuencia AND estatus <> 'E';
				
					IF NOT EXISTS (SELECT 1 fecharegistro FROM "informix".ss_paquetesoperativos 
					WHERE empresa = p_sEmpresa AND fecharegistro = p_dFechaNueva 
					AND sucursal = p_sSucursal AND estatus <> 'E' and secuencia = p_sSecuencia) THEN   
					
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
							LET v_sValRetorno = "000001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
						ELSE
							LET v_sValRetorno = '000000';
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
							LET v_sValRetorno = "000001"; --ERROR DURANTE LA EJECUCION DE UNA CONSULTA
						ELSE
							LET v_sValRetorno = '000000';
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
'MODIFICO: Victor Hugo Nuñez',
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

CREATE PROCEDURE "informix".sp_conscapacidadcaja(pEmpresa CHAR(3), pNumCja CHAR(10))

RETURNING	CHAR(6) AS CodRet, INTEGER AS HojasRegistradas, INTEGER AS CapacidadCja, 
			INTEGER AS PorcentajeLimiteParaCerrado, DECIMAL(5,2) AS PorcentajeCapacidadActual, CHAR(100) AS Descripcion;
		
DEFINE 	cCodRet		 CHAR(6);
DEFINE	iSqlErr	 	 INTEGER;
DEFINE	iHojas	 	 INTEGER;
DEFINE	iCapacidad	 INTEGER;
DEFINE	iPorLimite	 INTEGER;
DEFINE 	dPorCapAct	 DECIMAL(14,2);
DEFINE  cDescripcion CHAR(100);

LET	cCodRet		 = '000000';
LET iSqlErr		 = 0;
LET iHojas		 = 0;
LET iCapacidad	 = 0;	
LET iPorLimite	 = 0;
LET dPorCapAct	 = 0;
LET cDescripcion = '';

-- SET DEBUG FILE TO '/tmp/sp_conscapacidadcaja.out';
-- TRACE ON; 

BEGIN
	
	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet,iHojas,iCapacidad,iPorLimite,dPorCapAct,TRIM(cDescripcion);
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
	
	--VALIDA ERRORES DE LOS PARAMETROS
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCja,'') = '' THEN
		LET cCodRet='000001';
		RETURN cCodRet,iHojas,iCapacidad,iPorLimite,dPorCapAct,TRIM(cDescripcion);
	END IF;
	
	SELECT NVL(paq.capacidad,0), NVL(paq.porcentaje_limite,0), NVL(caj.num_hojas_registradas,0) 
	INTO iCapacidad, iPorLimite, iHojas	
	FROM "informix".ss_cattipopaquetes paq, "informix".ss_numcajas caj
	WHERE paq.empresa = pEmpresa
	AND caj.empresa = paq.empresa
	AND caj.tipopaquete = paq.tipopaquete
	AND caj.numerocaja = pNumCja;
		
	--VALIDA CUALQUIER ERROR DURANTE LA EJECUCION
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002';
	END IF;
	
	LET dPorCapAct = ((iHojas / iCapacidad)*100);
	LET cDescripcion = iHojas||' de '||iCapacidad||" hojas";
	
	RETURN cCodRet,iHojas,iCapacidad,iPorLimite,dPorCapAct,TRIM(cDescripcion);
END;
END PROCEDURE
DOCUMENT
'AUTOR:	  	  Ernesto Aguilera',
'FECHA:		  17/10/2014',
'DESCRIPCION: Se consulta la capacidad y porcentaje de la caja. Se retorna los datos de la consulta',
'VERSION:     20141017.1630',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_consultarautoguardadopaquete(pEmpresa CHAR(3),pTipoPaquete CHAR(1))

	RETURNING CHAR(6) AS Cod_Retorno,
			  INTEGER AS TotalRegAutoguardado;
			  
--DEFINICION DE VARIABLES
	DEFINE cCod_Ret CHAR(6);
	DEFINE iNumReg	INTEGER;
	DEFINE iSqlErr	INTEGER;
	
--INICIALIZACION DE VARIABLES
	LET cCod_Ret = '';
	LET iNumReg	 = 0;
	
	
BEGIN
    
    ON EXCEPTION  SET isqlerr
        IF isqlerr <> 0  THEN
            LET  cCod_Ret  = isqlerr;
            RETURN NVL(cCod_Ret,''),iNumReg;
        END IF;
    END  EXCEPTION;

	-----------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarautoguardadopaquete.out";
	--TRACE ON;
	-----------------------------------------------------------------------


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
		IF NVL(pEmpresa,'') = '' OR NVL(pTipoPaquete,'') = '' THEN
		
			LET  cCod_Ret  = '000001';
			
		ELSE
	
			SELECT NVL(num_registros_autoguardado,0) INTO iNumReg 
			FROM "informix".ss_cattipopaquetes
			WHERE empresa = pEmpresa AND tipopaquete = pTipoPaquete;
		
		
			LET  cCod_Ret  = '000000';
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCod_Ret = '000002';
				
			END IF;
			
		END IF;	
		
		RETURN NVL(cCod_Ret,''),NVL(iNumReg,0);
		
END
END PROCEDURE
DOCUMENT 
'ELABORO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE CREA PROCEDIMIENTO PARA CONSULTAR EL NUMERO DE REGISTROS QUE PERMITE DEL AUTOGUARDADO DEPENDIENDO DEL TIPO DE PAQUETE',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_sesioncaja(pEmpresa CHAR(3),pCaja CHAR(14),pUsuario CHAR(8),pTipo CHAR(1),pTiempo INTEGER)

	RETURNING CHAR(6) AS Cod_Retorno, CHAR(53) AS Empleado;
			  
--DEFINICION DE VARIABLES
	DEFINE cCodRet CHAR(6);
	DEFINE iSqlErr	INTEGER;
	DEFINE iActualizar	INTEGER;
	DEFINE cNumEmpleado CHAR(8);
	DEFINE cDescripcion CHAR(45);
	DEFINE dHoraOcupada DATETIME YEAR TO MINUTE;
	DEFINE dHoraActual  DATETIME YEAR TO MINUTE;
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet = '000000';
	LET iActualizar = 0;
	LET cNumEmpleado	= '';
	LET cDescripcion = '';
	LET dHoraOcupada	= '';
	LET dHoraActual = '';
	
	------------------------------------------------------------
			--	CODIGOS DE RETORNO
			--	000000	=	EJECUCION CORRECTA
			--	000001	=	PARAMETROS DE ENTRADA VACIOS O NULOS
			--	000002	=	CAJA ABIERTA
			--	000003	=	SESION EXPIRADA
			--	000004	=	SESION ACTIVA
			--	000005	=	CAJA DISPONIBLE
			--	000006	=	NO SE ENCONTRO REGISTRO
	------------------------------------------------------------
	
	BEGIN
		
		ON EXCEPTION  SET iSqlErr
			IF iSqlErr <> 0  THEN
				LET  cCodRet  = iSqlErr;
				RETURN cCodRet,cNumEmpleado||' '||cDescripcion;
			END IF;
		END  EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_sesioncaja.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pEmpresa,'') = '' OR NVL(pCaja,'') = '' OR NVL(pUsuario,'') = '' OR NVL(pTipo,'') = '' OR NVL(pTiempo,0) = 0 THEN	
			LET  cCodRet  = '000001';			
		ELSE			
			--SELECCIONA LA FECHA DEL SERVIDOR
			SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO MINUTE
			INTO dHoraActual
			FROM sysmaster:"informix".sysshmvals;		
			
			SELECT numempleado_cajaocupada,fecha_cajaocupada
			INTO cNumEmpleado, dHoraOcupada
			FROM "informix".ss_numcajas
			WHERE empresa = pEmpresa
			AND numerocaja = pCaja;		

			IF NVL(cNumEmpleado,'') <> '' THEN
				LET dHoraOcupada  = dHoraOcupada::DATETIME YEAR TO MINUTE +  (pTiempo) UNITS MINUTE;
			END IF;		
			
			IF pTipo = '0' THEN						--EL USUARIO QUEIRE ABRIR LA CAJA	(BLOQUEAR)
				IF NVL(cNumEmpleado,'') = '' THEN	--EL NUMERO DE EMPLEADO ESTA VACIO
					LET iActualizar = 1;			--SE PUEDE ABRIR LA CAJA CORRECTAMENTE
				ELSE
					IF pUsuario = cNumEmpleado AND dHoraOcupada > dHoraActual THEN
						LET cCodRet = '000004';
						LET cNumEmpleado = '';
					ELIF dHoraOcupada > dHoraActual THEN	--EL NUMERO DE EMPLEADO TIENE DATOS Y LA FECHA-HORA OCUPADA ES MAYOR A LA HORA ACTUAL
						LET cCodRet = '000002';			--REGRESA EL NOMBRE Y NUMERO DEL EMPLEADO QUE LA ESTA USANDO
						SELECT nombre				
						INTO cDescripcion
						FROM bdinteg:"informix".si_ejecut
						WHERE empresa = pEmpresa
						AND ejecutivo = cNumEmpleado;
					ELIF dHoraOcupada <= dHoraActual THEN	--LA FECHA-HORA ES MENOR O IGUAL A LA HORA ACTUAL
						LET iActualizar = 1;				--SE ACTUALIZA PARA PODER ABRIR LA CAJA
					END IF;
				END IF;
			ELIF pTipo = '1' THEN					--EL USUARIO QUIERE CERRAR LA CAJA	(DESBLOQUEAR)		
				IF cNumEmpleado = pUsuario THEN		--EL NUMERO DE EMPLEADO REGISTRADO ES IGUAL AL DEL PARAMETRO
					LET pUsuario = NULL;			--VARIABLES EN NULL PARA PODER CERRAR LA CAJA
					LET dHoraActual = NULL;			--VARIABLES EN NULL PARA PODER CERRAR LA CAJA
					LET iActualizar = 1;				--SE ACTUALIZARA SEGUN SEA LA SIGUIENTE VALIDACION
				END IF;
			ELIF pTipo = '2' THEN					--SE CONSULTA LA SESION
				IF cNumEmpleado = pUsuario THEN			--EL NUMERO DE EMPLEADO ES IGUAL AL PARAMETRO
					IF dHoraOcupada > dHoraActual THEN	--LA FECHA-HORA OCUPADA ES MAYOR A LA HORA
						LET cCodRet = '000004';
						LET cNumEmpleado = '';
					ELIF dHoraOcupada <= dHoraActual THEN	--LA FECHA-HORA ES MENOR O IGUAL A LA HORA ACTUAL (CAJA DISPONIBLE)
						LET cCodRet = '000003';				
						LET pUsuario = NULL;                --VARIABLES EN NULL PARA PODER CERRAR LA CAJA
						LET dHoraActual = NULL;				--VARIABLES EN NULL PARA PODER CERRAR LA CAJA
						LET iActualizar = 1;	            
					END IF;
				ELSE
					IF cNumEmpleado <> pUsuario THEN	--EL NUMERO DE EMPLEADO ES DIFERENTE AL PARAMETRO
						IF NVL(cNumEmpleado,'') = '' THEN	-- --EL NUMERO DE EMPLEADO ESTA EN NULL
							LET cCodRet = '000005';
							LET cNumEmpleado = '';
						ELSE
							LET cCodRet = '000002';		--EL NUMERO DE EMPLEADO ES DIFERENTE AL PARAMETRO Y DIFERENTE DE NULL
							SELECT nombre
							INTO cDescripcion
							FROM bdinteg:"informix".si_ejecut
							WHERE empresa = pEmpresa
							AND ejecutivo = cNumEmpleado;
						END IF;	
					END IF;
				END IF;
			END IF;
			
			IF iActualizar = 1 THEN				
				UPDATE "informix".ss_numcajas
				SET numempleado_cajaocupada = pUsuario,
				fecha_cajaocupada= dHoraActual
				WHERE empresa = pEmpresa
				AND numerocaja = pCaja;
			END IF;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCodRet = '000006';				
			END IF;
		END IF;
		
		RETURN cCodRet,cNumEmpleado||' '||cDescripcion;
			
	END
END PROCEDURE
DOCUMENT 
'ELABORO: 95281495-ERNESTO AGUILERA',
'FECHA CREACION: 27/02/2015',
'DESCRIPCION: SE CREA PROCEDIMIENTO PARA VALIDAR CUANDO UNA CAJA ESTA ABIERTA Y CUANDO ESTA CERRADA.',
'			ADEMAS DE VALIDAR LA SESION DEL USUARIO',
'VERSION: 27022015.1610',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_consul_dotacion2_total(eEmpresa    CHAR(3), 
                                               eTipo       CHAR(1), 
                                               eProveedor  CHAR(4),
                                               eSucursal   CHAR(4),
                                               eFecInicio  DATE,
                                               eFecFin     DATE,
                                               eStatus     CHAR(2))
RETURNING CHAR(5),
          INTEGER;

DEFINE vCodRet   CHAR(5);
DEFINE vWHERE    CHAR(300);
DEFINE vSucursal CHAR(4);
DEFINE vNomSuc   CHAR(50);
DEFINE vFecOpera DATE;
DEFINE vStatus   CHAR(50);
DEFINE vFolio    CHAR(16);
DEFINE vMonto    DECIMAL(14,2);
DEFINE vUsuario  CHAR(50);
DEFINE vUser     CHAR(16);
DEFINE vPlaza    CHAR(50);
DEFINE vPSuc     char(4);
DEFINE vTotRegs  INTEGER;

LET vCodRet  = "000";
LET vWHERE   = '';
LET vPSuc    = "";
LET eTipo = eTipo;
LET eFecInicio = eFecInicio;
LET eFecFin = eFecFin;
LET vPlaza = "";
LET vTotRegs = 0;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_consul_dotacion2_total.out';
        --TRACE ON;

    IF eProveedor <> '' and eSucursal = '' THEN   --** Por proveedor

                IF eFecInicio = '' OR eFecInicio IS NULL  THEN
                        LET eFecInicio = MDY(1,1,2007);
                END IF

                  SELECT COUNT(*)
                    INTO vTotRegs
                    FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
                   WHERE a.cod_trans in (  '0001' ,'0036', '0010' ) 
                                     AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
                     AND a.sucursal IN (SELECT sucursal 
                                                                              FROM bdinteg:"informix".si_sucursales  
                                                                             WHERE sucursal != '0' 
                                                                               AND empresa = eEmpresa 
                                                                                   AND tpo_sucursal = eTipo)
                                        AND a.reversado IN ('0')
                                    AND a.folio_oper = b.folio_oper                 
                                    AND b.cod_proveedor = eProveedor               
                                    AND b.status = eStatus;                   

                  RETURN vcodret, vTotRegs;

    ELIF eProveedor <> '' and eSucursal <> ''  THEN   --** Por Sucursal

                IF eFecInicio = '' OR eFecInicio IS NULL  THEN
                        LET eFecInicio = MDY(1,1,2007);
                END IF

                  SELECT COUNT(*)
                    INTO vTotRegs
                    FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
                   WHERE a.cod_trans in (  '0001' ,'0036', '0010' ) 
                     AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
                                     AND a.sucursal = eSucursal 
                                         AND a.reversado IN ('0')
                     AND a.folio_oper = b.folio_oper                 
                     AND b.status = eStatus;                 
                  RETURN vcodret, vTotRegs;

    ELSE  --** Todos

                IF eFecInicio = '' OR eFecInicio IS NULL  THEN
                        LET eFecInicio = MDY(1,1,2007);
                END IF

                  SELECT COUNT(*)
                    INTO vTotRegs
                    FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b
                   WHERE a.cod_trans in (  '0001' ,'0036', '0010' ) 
                                     AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
                                         AND a.sucursal IN (SELECT sucursal 
                                                                  FROM bdinteg:"informix".si_sucursales  
                                                                  WHERE sucursal != '0' 
                                                                    AND empresa = eEmpresa 
                                                                        AND tpo_sucursal = eTipo)
                                         AND a.reversado IN ('0')
                     AND a.folio_oper = b.folio_oper                 
                     AND b.status = eStatus;                 

                  RETURN vcodret, vTotRegs;
    END IF;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 04/02/2015',
'DESCRIPCION: Clon del spl bdisuc:sp_consul_dotacion para el conteo de registros que devolvera la consulta';

CREATE PROCEDURE "informix".sp_consul_operaciones2(eEmpresa    CHAR(3),
                                                  eFecha      DATE,
                                                  eFecFin     DATE,
                                                  eFolioOper  CHAR(8),
                                                  eSucursal   CHAR(4),
                                                  eCodTras    CHAR(4),
                                                  eTpConsul   CHAR(1),
                                                  eRegional   CHAR(5),
                                                  eTipo       CHAR(1),
												  eRegistros  INTEGER,
												  eRecupera   INTEGER) --S = Sucursal C = Cajero
RETURNING CHAR(5),             --CodRet
          CHAR(50),            --Sucursal
          DATE,                --Fec.Operacion
          CHAR(4),             --CodTran
          CHAR(1),             --Reversado
          CHAR(40),            --Usuario
          CHAR(40),            --Divisa
          MONEY(14,2),         --Monto
          FLOAT,               --Cantidad1
          FLOAT,               --Cantidad2
          FLOAT,               --Cantidad3
          FLOAT,               --Cantidad4
          FLOAT,               --Cantidad5
          FLOAT,               --Cantidad6
          FLOAT,               --Cantidad7
          fLOAT,               --Cantidad8
          FLOAT,               --Cantidad9
          FLOAT,               --Cantidad10
          FLOAT,               --Cantidad11
          FLOAT,               --Cantidad12
          FLOAT,               --Cantidad13
          FLOAT,               --Cantidad14
          FLOAT,               --Cantidad15
          CHAR(16),            --Folio Sucursal
          CHAR(8),             --Folio Oper
          CHAR(4),             --Procedencia
          CHAR(40),            --Proveedor
          CHAR(40);            --CodTrans

 DEFINE vCodRet       CHAR(5);
 DEFINE vSucursal     CHAR(4);
 DEFINE vFecOperacion DATE;
 DEFINE vCodTrans     CHAR(4);
 DEFINE vReversado    CHAR(1);
 DEFINE vUsuario      CHAR(8);
 DEFINE vDivisa       CHAR(2);
 DEFINE vMonto        MONEY(14,2);
 DEFINE vCant1        FLOAT;
 DEFINE vCant2        FLOAT;
 DEFINE vCant3        FLOAT;
 DEFINE vCant4        FLOAT;
 DEFINE vCant5        FLOAT;
 DEFINE vCant6        FLOAT;
 DEFINE vCant7        FLOAT;
 DEFINE vCant8        FLOAT;
 DEFINE vCant9        FLOAT;
 DEFINE vCant10       FLOAT;
 DEFINE vCant11       FLOAT;
 DEFINE vCant12       FLOAT;
 DEFINE vCant13       FLOAT;
 DEFINE vCant14       FLOAT;
 DEFINE vCant15       FLOAT;
 DEFINE vFolSuc       CHAR(16);
 DEFINE vFolOper      CHAR(8);
 DEFINE vProcedencia  CHAR(4);
 DEFINE vNomSuc       CHAR(40);
 DEFINE vNomProv      CHAR(40);
 DEFINE vNomUsuario   CHAR(40);
 DEFINE vDesDivisa    CHAR(40);
 DEFINE vPlazaGen     CHAR(3);
 DEFINE vDesTran      CHAR(40);
 DEFINE vPlaza        CHAR(3);
 DEFINE vFolioSrv     CHAR(16);
 DEFINE vCajGen       CHAR(1);


 LET vCodRet       = "000";
 LET vSucursal     = '';
 LET vFecOperacion = '';
 LET vCodTrans     = '';
 LET vReversado    = '';
 LET vUsuario      = '';
 LET vDivisa       = '';
 LET vMonto        = 0;
 LET vCant1        = 0;
 LET vCant2        = 0;
 LET vCant3        = 0;
 LET vCant4        = 0;
 LET vCant5        = 0;
 LET vCant6        = 0;
 LET vCant7        = 0;
 LET vCant8        = 0;
 LET vCant9        = 0;
 LET vCant10       = 0;
 LET vCant11       = 0;
 LET vCant12       = 0;
 LET vCant13       = 0;
 LET vCant14       = 0;
 LET vCant15       = 0;
 LET vFolSuc       = '';
 LET vFolOper      = '';
 LET vProcedencia  = '';
 LET vNomSuc       = '';
 LET vNomProv      = '';
 LET vNomUsuario   = '';
 LET vDesDivisa    = '';
 LET vPlazaGen     = '';
 LET vDesTran      = '';
 LET vPlaza        = '';
 LET vFolioSrv     = '';
 LET vCajGen       = 'N';


 SET LOCK MODE TO WAIT 4;
 SET ISOLATION TO DIRTY READ;

 IF eRegional != '0000' THEN
    SELECT plaza INTO vPlaza FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = eRegional;    
 END IF;

 IF eTipo = 'C' THEN
    LET vCajGen =  'C';
 END IF;

 IF eTpConsul = '1' THEN    --Todos
    IF eRegional != '0000' THEN    
        FOREACH
            SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                   divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                   cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                   cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                   cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
            INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                  vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                  vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                  vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                  vFolOper      , vProcedencia
            FROM  bdisuc:"informix".ss_operaciones
            WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                 AND fecha_operacion between eFecha  and eFecFin
                 AND (sucursal in( SELECT sucursal 
                                    FROM bdinteg:"informix".si_sucursales 
                                   WHERE sucursal != '0'
                                     AND empresa = eEmpresa
                                     AND plaza_cajagen = vPlaza 
                                     AND tpo_sucursal = eTipo)
                  OR sucursal IN (SELECT cod_proveedor 
                                             FROM bdisuc:ss_proveedores 
                                             WHERE cod_proveedor = eRegional))
                 AND reversado IN ('0','1')
             ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

             SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

             SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

             SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

             SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

             SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE empresa = eEmpresa AND codigo = vCodTrans;

             SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
             INTO vFolioSrv 
             FROM bdisuc:"informix".ss_mae_entradasalida 
             WHERE folio_oper = vFolOper;

             IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                LET vFolSuc = vFolioSrv;
             END IF;

             Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;
         END FOREACH;
    ELSE
        FOREACH
               SELECT SKIP eRegistros FIRST eRecupera  {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                      divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                      cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                      cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                      cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
               INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                     vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                     vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                     vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                     vFolOper      , vProcedencia
               FROM  bdisuc:"informix".ss_operaciones
               WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                 AND fecha_operacion between eFecha  and eFecFin
                 AND sucursal in( SELECT sucursal 
                                    FROM bdinteg:"informix".si_sucursales 
                                   WHERE sucursal != '0'
                                     AND empresa = eEmpresa
                                     AND (tpo_sucursal = eTipo OR tpo_sucursal = vCajGen))
                 AND reversado IN ('0','1')
            ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE empresa = eEmpresa AND codigo = vCodTrans;

               SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
               INTO vFolioSrv 
               FROM bdisuc:"informix".ss_mae_entradasalida 
               WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;
         END FOREACH;
    END IF;         

 ELIF eTpConsul = '2' THEN    --Reversado
    IF eRegional != '0000' THEN
        FOREACH
               SELECT SKIP eRegistros FIRST eRecupera  {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                      divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                      cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                      cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                      cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
               INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                     vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                     vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                     vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                     vFolOper      , vProcedencia
               FROM  bdisuc:"informix".ss_operaciones
               WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                 AND fecha_operacion between eFecha  and eFecFin
                 AND sucursal in( SELECT sucursal 
                                    FROM bdinteg:"informix".si_sucursales 
                                   WHERE sucursal != '0'
                                     AND empresa = eEmpresa
                                     AND plaza_cajagen = vPlaza 
                                     AND tpo_sucursal = eTipo)
                 AND reversado IN ('1')
            ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

               SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
               INTO vFolioSrv 
               FROM bdisuc:"informix".ss_mae_entradasalida 
               WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans,  vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

         END FOREACH;
    ELSE
         FOREACH
               SELECT SKIP eRegistros FIRST eRecupera  {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                      divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                      cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                      cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                      cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
               INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                     vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                     vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                     vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                     vFolOper      , vProcedencia
               FROM  bdisuc:"informix".ss_operaciones
               WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                 AND fecha_operacion between eFecha  and eFecFin
                 AND sucursal in( SELECT sucursal 
                                    FROM bdinteg:"informix".si_sucursales 
                                    WHERE empresa = eEmpresa
                                     AND sucursal != '0' 
                                     AND (tpo_sucursal = eTipo OR tpo_sucursal = vCajGen))
                 AND reversado IN ('1')
            ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

             SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
             INTO vFolioSrv 
             FROM bdisuc:"informix".ss_mae_entradasalida 
             WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans,  vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

         END FOREACH;
    END IF;        

 ELIF eTpConsul = '3' THEN    --Folio Operacion
    FOREACH
           SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx02ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                  divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                  cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                  cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                  cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
           INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                 vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                 vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                 vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                 vFolOper      , vProcedencia
           FROM  bdisuc:"informix".ss_operaciones
           WHERE folio_oper = eFolioOper
           ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

             --** Descripcion Sucursal
           SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

             --** Nombre proveeedor
           SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

             --** Usuario
           SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

             --** Divisa
           SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

             --** Transaccion
           SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

	     SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
		 INTO vFolioSrv 
		 FROM bdisuc:"informix".ss_mae_entradasalida 
		 WHERE folio_oper = vFolOper;

           IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
              LET vFolSuc = vFolioSrv;
           END IF;

           Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion ,  vCodTrans, vReversado    , vNomUsuario   ,
                  vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                  vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                  vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                  vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

     END FOREACH;
 
 ELIF eTpConsul = '4' THEN    --Fecha
    IF eFecha Is Null Or eFecha = '' THEN
       LET vCodRet  = "001";
           Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                  vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                  vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                  vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                  vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;
    ELSE
       IF eRegional != '0000' THEN
           FOREACH
                  SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                         divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                         cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                         cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                         cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
                  INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                        vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                        vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                        vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                        vFolOper      , vProcedencia
                  FROM  bdisuc:"informix".ss_operaciones
                  WHERE cod_trans IN ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                    AND fecha_operacion between eFecha  and eFecFin
                    AND (sucursal IN( SELECT sucursal 
                                       FROM bdinteg:"informix".si_sucursales 
                                      WHERE sucursal != '0'
                                        AND empresa = eEmpresa
                                        AND plaza_cajagen = vPlaza 
                                        AND tpo_sucursal = eTipo)
                          OR sucursal IN (SELECT cod_proveedor 
                                              FROM bdisuc:"informix".ss_proveedores 
                                             WHERE cod_proveedor = eRegional))
                    AND reversado IN ('0','1')
              ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

           SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
             INTO vFolioSrv 
             FROM bdisuc:"informix".ss_mae_entradasalida 
            WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

         END FOREACH;
       ELSE
         FOREACH
                  SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                         divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                         cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                         cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                         cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
                  INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                        vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                        vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                        vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                        vFolOper      , vProcedencia
                  FROM  bdisuc:"informix".ss_operaciones
                  WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
                    AND fecha_operacion between eFecha  and eFecFin
                    AND sucursal in( SELECT sucursal 
                                       FROM bdinteg:"informix".si_sucursales 
                                      WHERE sucursal != '0' 
                                        AND empresa = eEmpresa
                                        AND (tpo_sucursal = eTipo OR tpo_sucursal = vCajGen))
                    AND reversado IN ('0','1')
              ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

               SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
               INTO vFolioSrv 
               FROM bdisuc:"informix".ss_mae_entradasalida 
               WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

         END FOREACH;   
       END IF;
    END IF;

 ELIF eTpConsul = '5' THEN    --Sucursal
       FOREACH
              SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                     divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                     cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                     cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                     cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
              INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                    vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                    vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                    vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                    vFolOper      , vProcedencia
              FROM  bdisuc:"informix".ss_operaciones
              WHERE cod_trans in ("0001","0002","0003","0004","0006","0007","0008","0009","0010","0031","0036","0041")
			    AND fecha_operacion between eFecha  and eFecFin
                AND sucursal = eSucursal
                AND reversado IN ('0','1')
           ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

             --** Descripcion Sucursal
           SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

             --** Nombre proveeedor
           SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

             --** Usuario
           SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

             --** Divisa
           SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

             --** Transaccion
           SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;
	
            SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
            INTO vFolioSrv 
            FROM bdisuc:"informix".ss_mae_entradasalida 
            WHERE folio_oper = vFolOper;

           IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
              LET vFolSuc = vFolioSrv;
           END IF;

           Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                  vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                  vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                  vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                  vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

     END FOREACH;

 ELIF eTpConsul = '6' THEN    --Transaccion
    IF eRegional != '0000' THEN
       FOREACH
              SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                     divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                     cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                     cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                     cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
              INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                    vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                    vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                    vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                    vFolOper      , vProcedencia
              FROM  bdisuc:"informix".ss_operaciones
              WHERE cod_trans = eCodTras
			    AND fecha_operacion between eFecha  and eFecFin
                AND (sucursal in( SELECT sucursal 
						           FROM bdinteg:"informix".si_sucursales 
						          WHERE sucursal != '0' 
                                    AND empresa = eEmpresa
						            AND plaza_cajagen = vPlaza 
						            AND tpo_sucursal = eTipo)
			  OR sucursal IN (SELECT cod_proveedor 
										  FROM bdisuc:ss_proveedores 
								         WHERE cod_proveedor = eRegional))
                AND reversado IN ('0','1')
                ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

                SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
                INTO vFolioSrv 
                FROM bdisuc:"informix".ss_mae_entradasalida 
                WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

        END FOREACH;
    ELSE
       FOREACH
              SELECT SKIP eRegistros FIRST eRecupera {+ INDEX(ss_operaciones idx01ss_operaciones)} sucursal     , fecha_operacion , cod_trans     , reversado  , usuario     ,
                     divisa       , monto           , cantidad_1    , cantidad_2 , cantidad_3  ,
                     cantidad_4   , cantidad_5      , cantidad_6    , cantidad_7 , cantidad_8  ,
                     cantidad_9   , cantidad_10     , cantidad_11   , cantidad_12, cantidad_13 ,
                     cantidad_14  , cantidad_15     , folio_sucursal, folio_oper , procedencia
              INTO  vSucursal     , vFecOperacion , vCodTrans     , vReversado    , vUsuario      ,
                    vDivisa       , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                    vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                    vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                    vFolOper      , vProcedencia
              FROM  bdisuc:"informix".ss_operaciones
              WHERE cod_trans = eCodTras
			    AND fecha_operacion between eFecha  and eFecFin
                AND sucursal in( SELECT sucursal 
						           FROM bdinteg:"informix".si_sucursales 
						          WHERE sucursal != '0'
                                    AND empresa = eEmpresa
						            AND (tpo_sucursal = eTipo OR tpo_sucursal = vCajGen))
                AND reversado IN ('0','1')
                ORDER BY fecha_operacion ASC,sucursal,cod_trans desc

                 --** Descripcion Sucursal
               SELECT nombre,plaza_cajagen INTO vNomSuc,vPlazaGen FROM bdinteg:"informix".si_sucursales WHERE sucursal = vSucursal AND empresa = eEmpresa;

                 --** Nombre proveeedor
               SELECT descripcion INTO vNomProv FROM bdisuc:"informix".ss_proveedores WHERE plaza = vPlazaGen;

                 --** Usuario
               SELECT nombre INTO  vNomUsuario FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = vUsuario;

                 --** Divisa
               SELECT descripcion INTO vDesDivisa FROM bdinteg:"informix".si_divisas WHERE empresa = eEmpresa AND divisa = vDivisa;

                 --** Transaccion
               SELECT descripcion INTO vDesTran FROM bdisuc:"informix".ss_param_cajagen WHERE codigo = vCodTrans;

                SELECT {+ INDEX(ss_mae_entradasalida idx01ss_mae_entradasalida)} folio_servicio 
                INTO vFolioSrv 
                FROM bdisuc:"informix".ss_mae_entradasalida 
                WHERE folio_oper = vFolOper;

               IF NOT vFolioSrv IS NULL AND vFolioSrv != '' THEN
                  LET vFolSuc = vFolioSrv;
               END IF;

               Return vCodRet       , vSucursal || ' ' || vNomSuc       , vFecOperacion , vCodTrans, vReversado    , vNomUsuario   ,
                      vDesDivisa    , vMonto        , vCant1        , vCant2        , vCant3        , vCant4        ,
                      vCant5        , vCant6        , vCant7        , vCant8        , vCant9        , vCant10       ,
                      vCant11       , vCant12       , vCant13       , vCant14       , vCant15       , vFolSuc       ,
                      vFolOper      , vProcedencia  , vNomProv ,vDesTran WITH RESUME;

        END FOREACH;
    END IF;

 END IF;

END PROCEDURE;