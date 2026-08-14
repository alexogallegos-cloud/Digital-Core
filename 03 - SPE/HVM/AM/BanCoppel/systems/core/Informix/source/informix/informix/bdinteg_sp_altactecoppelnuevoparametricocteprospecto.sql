CREATE PROCEDURE "informix".sp_altactecoppelnuevoparametricocteprospecto(pEmpresa CHAR(3), pNumCte VARCHAR(20), pNumSolicitud CHAR(20))
	RETURNING
	CHAR(5),
	CHAR(1071); --- Trama conformada

	--- DECLARACIONES
	DEFINE cCodRet 							CHAR(5);
	DEFINE iSqlErr                          INTEGER;
	DEFINE iSamErr                          INTEGER;
	DEFINE cDesErr                          CHAR(60);

	DEFINE iTipoMensaje                     SMALLINT;
	DEFINE iValorSeguridad                  INTEGER;

	DEFINE cNumCteRef                      	CHAR(20);
	DEFINE cNombreUno                      	CHAR(26);
	DEFINE cNombreDos                      	VARCHAR(26);
	DEFINE cApellPat                       	CHAR(26);
	DEFINE cApellMat                       	VARCHAR(26);
	DEFINE cSexo                           	CHAR(1);
	DEFINE cDiaNac                         	CHAR(2);
	DEFINE cMesNac                         	CHAR(2);
	DEFINE cAnioNac                        	CHAR(4);
	DEFINE cEdoCivil                       	CHAR(1);

	DEFINE iNumeroCiudad                    INTEGER;
	DEFINE iNumeroColonia                   INTEGER;
	DEFINE iNumeroCalle                     INTEGER;
	DEFINE cCasa                            VARCHAR(10);
	DEFINE cRumbo                          	VARCHAR(1);
	DEFINE cObservaciones                  	VARCHAR(80);
	DEFINE cEntreCalles						VARCHAR(40);
	DEFINE iFlagUH                        	INTEGER;
	DEFINE iManzana                        	INTEGER;
	DEFINE iOtros                          	INTEGER;
	DEFINE iAndador                        	INTEGER;
	DEFINE iEtapa                          	INTEGER;
	DEFINE iLote                           	INTEGER;
	DEFINE iEdificio                       	INTEGER;
	DEFINE iEntrada                        	INTEGER;
	DEFINE cLetrasNumCasa                   VARCHAR(6);
	DEFINE cTelefono                       	VARCHAR(10);
	DEFINE cTelefono2                       VARCHAR(10);
	DEFINE cHabitaEn                      	VARCHAR(1);

	DEFINE cSituacionEspecial               VARCHAR(1);
	DEFINE iCausaSituacionEspecial          SMALLINT;
	DEFINE cPuntualidad                    	CHAR(1);
	DEFINE iIngresoMensual                	INTEGER;
	DEFINE iLimiteDeCredito 				INTEGER;

	DEFINE iReposicionTarjeta              	SMALLINT;
	DEFINE iFlagclienteAnexo                INTEGER;
	DEFINE iFlagCobxTel                     INTEGER;
	DEFINE iFlagDescuentoEspecial           INTEGER;
	DEFINE iFlagActualizarDatos             INTEGER;
	DEFINE iFlagHuella                      INTEGER;
	DEFINE iMesesTranscurridos              INTEGER;

	DEFINE cLugarDeTrabajo                  VARCHAR(20);
	DEFINE iNumeroCiudadDeTrabajo           INTEGER;
	DEFINE iNumeroColoniaDeTrabajo          INTEGER;
	DEFINE iNumeroCalleDeTrabajo            INTEGER;
	DEFINE cCasaTrabajo                     VARCHAR(10);
	DEFINE cLetrasNumeroTrabajo            	VARCHAR(6) ;
	DEFINE cTelefonoUnoTrabajo              VARCHAR(10);
	DEFINE iExtension                       INTEGER;

	DEFINE iNipTitular                      INTEGER;
	DEFINE iNipAdicional1                   INTEGER;
	DEFINE iNipAdicional2                   INTEGER;

	DEFINE cNombreUnoRef                    CHAR(26);
	DEFINE cNombreDosRef                    VARCHAR(26);
	DEFINE cApellUnoReferencia              CHAR(26);
	DEFINE cApellDosReferencia              VARCHAR(26);
	DEFINE cTelefonoRef                     VARCHAR(10);

	DEFINE cDiaAltaCliente                  CHAR(2);
	DEFINE cMesAltaCliente                  CHAR(2);
	DEFINE cYearAltaCliente                 CHAR(4);

	DEFINE iGrupoSemaforoCN                 INTEGER;
	DEFINE iStatusAfore                     INTEGER;
	DEFINE iParametricosCelulares           INTEGER;
	DEFINE cClave                           CHAR(1);
	DEFINE cTipoMovto                       CHAR(1);
	DEFINE cSucursal 						VARCHAR(4);
	DEFINE iCaja                            INTEGER;
	DEFINE cEmpleadoEfectuo                 VARCHAR(8);
	DEFINE iCiudadTiendaMov                 INTEGER;
	DEFINE cArea                            CHAR(1);

	--Variables a partir de nuevo parametrico
	DEFINE cSubPuntualidad					CHAR(1);
	DEFINE iLineaDeCreditoTope				INTEGER;
	DEFINE iLineaDeCreditoReal				INTEGER;
	DEFINE cDiaFechaLineaDeCreditoReal	    CHAR(2);
	DEFINE cMesFechaLineaDeCreditoReal		CHAR(2);
	DEFINE cAnioFechaLineaDeCreditoReal		CHAR(4);
	DEFINE cDiaFechaLineaDeCreditoTope		CHAR(2);
	DEFINE cMesFechaLineaDeCreditoTope		CHAR(2);
	DEFINE cAnioFechaLineaDeCreditoTope		CHAR(4);
	DEFINE iNivelLineaCreditoReal			SMALLINT;
	DEFINE iNivelLineaCreditoTope			SMALLINT;

	DEFINE cTelefonoCliente					VARCHAR(10);
	DEFINE cTelefonoTrabajoCliente			VARCHAR(10);
	DEFINE cTelefonoReferencia				VARCHAR(10);
	DEFINE iParCelulares					SMALLINT;
	DEFINE cModeloCelulares					CHAR(1);
	DEFINE iParAltoRiesgo					SMALLINT;
	DEFINE iParPrestamo						SMALLINT;
	DEFINE iPedirTelefono					SMALLINT;
	DEFINE iFlagLineaCreditoEsp				SMALLINT;

	--VariablesComplementos
	DEFINE cCodRetCasa 						CHAR(5);
	DEFINE cCodRetTrabajo					CHAR(5);
	DEFINE cCiudadSucursal 					CHAR(4);
	DEFINE dFechaMaxima  					DATE;
	DEFINE cEstadoSucursal 					CHAR(2);
	DEFINE iCiudadCoppel 					INTEGER;
	DEFINE iColoniaCoppel 					INTEGER;
	DEFINE iCiudadCoppelTrabajo 			INTEGER;
	DEFINE iColoniaCoppelTrabajo 			INTEGER;
	DEFINE iIngreso 						INTEGER;
	DEFINE cValor 							CHAR(20);
	DEFINE iSecuenciaMax1 					SMALLINT;
	DEFINE iSecuenciaMax2 					SMALLINT;
	DEFINE iSecuenciaRef1 					INTEGER;
	DEFINE iSecuenciaIng					INTEGER;
	DEFINE iValor							MONEY(14,2);

	--Vaiables para la cadena
	DEFINE v_Cad1                           LVARCHAR(525);
	DEFINE v_Cad2                           LVARCHAR(525);
	DEFINE cSPcodRet						CHAR(06);
	DEFINE cSPcteCplTitular					CHAR(20);
	DEFINE cSPcteCplProspecto				CHAR(20);

	--DSB-09/03/2015
	DEFINE cTelefono2T						VARCHAR(13);
	DEFINE cTelefonoClienteT				VARCHAR(13);
	DEFINE cTelefonoTrabajoClienteT			VARCHAR(13);
	DEFINE cTelefonoReferenciaT				VARCHAR(13);
	DEFINE cCodRetInt						CHAR(1);

	--DSB-14082017
	DEFINE iPrepuntajeAltoRiesgo            INTEGER; /* nuevos campos 11/08/2017 */
	DEFINE iPuntosParcn						SMALLINT;
	DEFINE iPuntajeFinalParamcn				SMALLINT; /*fin  */
	
	--598 INICIO
	DEFINE cCanal_OrigenSol					CHAR(1);
	DEFINE cGrupo_Eval						CHAR(1);
	DEFINE cGrupo_Hit						CHAR(1);
	--598 FIN

	--- INICIALIZACIONES
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iSamErr = 0;
	LET cDesErr = '';
	LET cNumCteRef = '';
	LET cNombreUno = '';
	LET cNombreDos = '';
	LET cApellPat = '';
	LET cApellMat = '';
	LET cSexo = '';
	LET cDiaNac = '';
	LET cMesNac = '';
	LET cAnioNac = '';
	LET cEdoCivil = '';
	LET iNumeroCiudad = 0;
	LET iNumeroColonia = 0;
	LET iNumeroCalle = 0;
	LET cCasa = '';
	LET cRumbo = '';
	LET cObservaciones = '';
	LET cEntreCalles = '';
	LET iFlagUH = '';
	LET iManzana = 0;
	LET iOtros = 0;
	LET iAndador = 0;
	LET iEtapa = 0;
	LET iLote = 0;
	LET iEdificio = 0;
	LET iEntrada = 0;
	LET cLetrasNumCasa = '';
	LET cTelefono2 = '0';
	LET cHabitaEn = '';
	LET cSituacionEspecial = '';
	LET iCausaSituacionEspecial = 0;
	LET iIngresoMensual = 0;
	LET iLimiteDeCredito = 0;
	LET cLugarDeTrabajo = '';
	LET iNumeroCiudadDeTrabajo = 0;
	LET iNumeroColoniaDeTrabajo = 0;
	LET iNumeroCalleDeTrabajo = 0;
	LET cCasaTrabajo = '';
	LET cLetrasNumeroTrabajo = '';
	LET iExtension = 0;
	LET cNombreUnoRef = '';
	LET cNombreDosRef = '';
	LET cApellUnoReferencia = '';
	LET cApellDosReferencia = '';
	LET cDiaAltaCliente = '';
	LET cMesAltaCliente = '';
	LET cYearAltaCliente = '';
	LET cSucursal = '';
	LET cEmpleadoEfectuo = '';
	LET iCiudadTiendaMov = '';
	LET iLineaDeCreditoReal	= 0;
	LET cDiaFechaLineaDeCreditoReal = '';
	LET cMesFechaLineaDeCreditoReal = '';
	LET cAnioFechaLineaDeCreditoReal = '';
	LET cDiaFechaLineaDeCreditoTope = '';
	LET cMesFechaLineaDeCreditoTope	= '';
	LET cAnioFechaLineaDeCreditoTope = '';
	LET cTelefonoCliente = '0';
	LET cTelefonoTrabajoCliente = '0';
	LET cTelefonoReferencia = '0';
	LET iParCelulares = 0;
	LET iParAltoRiesgo = 0;
	LET iParPrestamo = 0;
	LET iFlagLineaCreditoEsp = 0;
	LET cCodRetCasa = '00000';
	LET cCasa = '';
	LET cCiudadSucursal = '';
	LET dFechaMaxima  = mdy(01,01,1900);
	LEt cEstadoSucursal = '';
	LET iCiudadCoppel = 0;
	LET iColoniaCoppel = 0;
	LET iCiudadCoppelTrabajo = 0;
	LET iColoniaCoppelTrabajo = 0;
	LET iIngreso = 0;
	LET cValor = '';
	LET iSecuenciaMax1 = 0;
	LET iSecuenciaMax2 = 0;
	LET iSecuenciaRef1 = 0;
	LET iSecuenciaIng = 0;
	LET v_Cad1 = '';
	LET v_Cad2 = '';
	LET iLineaDeCreditoTope = 0;
	LET ivalor		 	= 0;

	--DSB-09/03/2015
	LET cTelefono2T				='0';
	LET cTelefonoClienteT		='0';
	LET cTelefonoTrabajoClienteT ='0';
	LET cTelefonoReferenciaT	='0';
	LET cCodRetInt				='';

	--DSB-14082017
	LET iPrepuntajeAltoRiesgo=0;   /* nuevos campos 09/08/2017 */
	lET iPuntosParcn=0;
	LET iPuntajeFinalParamcn=0;    /* fin */
	
	--598 INICIO
	LET pNumSolicitud				= TRIM(NVL(pNumSolicitud,''));		
	LET cCanal_OrigenSol			= ''; 	
	LET cGrupo_Eval					= ''; 	
	LET cGrupo_Hit					= ''; 	
	--598 FIN

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;

	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr, cDesErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet, NULL;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/Josue/sp_altactecoppelnuevoparametrico_out.sql';
		--TRACE ON;

		IF (pEmpresa IS NULL OR pEmpresa = '')  THEN
			RETURN '00001', NULL;
		ELSE
			IF (pNumCte IS NULL OR pNumCte = '')  THEN
				RETURN '00002', NULL;
			ELSE

				SELECT ingreso_mensual INTO iIngreso FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud;
				SELECT valor INTO iValor FROM bdisolic:"informix".ss_param WHERE secuencia = 363;
				LET iIngresoMensual = ((((NVL(iIngreso::DECIMAL(14,2),0))+(iValor/2)))/iValor)::SMALLINT;

				IF iIngresoMensual < 1 THEN
						LET iIngresoMensual = 1;
				END IF;

				/*LET iIngresoMensual = ROUND(NVL(iIngreso,0)/cValor)::INTEGER;
				IF  iIngresoMensual < 2  OR iIngresoMensual = 2 THEN
					SELECT creditoautorizado INTO iLimiteDeCredito FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 0 AND limitesuperior = 2;
				ELIF iIngresoMensual = 3 OR iIngresoMensual > 3 AND iIngresoMensual < 4 OR iIngresoMensual = 4 THEN
					SELECT creditoautorizado INTO iLimiteDeCredito FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 3 AND limitesuperior = 4;
				ELIF iIngresoMensual = 5  OR iIngresoMensual > 5 AND iIngresoMensual < 6 OR iIngresoMensual = 6  THEN
					SELECT creditoautorizado INTO iLimiteDeCredito FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 5 AND limitesuperior = 6;
				ELIF iIngresoMensual = 7  OR iIngresoMensual > 7 AND iIngresoMensual < 8 OR iIngresoMensual = 8 THEN
					SELECT creditoautorizado INTO iLimiteDeCredito FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 7 AND limitesuperior = 8;
				ELIF iIngresoMensual = 9 OR iIngresoMensual > 9 THEN
					SELECT creditoautorizado INTO iLimiteDeCredito FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 9 AND limitesuperior = 0;
				END IF;*/

				--dsb-21/08/2012
				/*SELECT numcte_ref, nombre1, NVL(TRIM(nombre2), ''), apell_paterno, NVL(TRIM(apell_materno), ''),
				DAY(fecha_insert), MONTH(fecha_insert), YEAR(fecha_insert)
				INTO cNumCteRef, cNombreUno, cNombreDos, cApellPat, cApellMat, cDiaAltaCliente, cMesAltaCliente, cYearAltaCliente
				FROM bdinteg:"informix".si_cliente
				WHERE numcte = pNumCte;*/			
				/*
				SELECT numcte_ref, nombre1, NVL(TRIM(nombre2), ''), apell_paterno, NVL(TRIM(apell_materno), '')
				INTO cNumCteRef, cNombreUno, cNombreDos, cApellPat, cApellMat
				FROM bdinteg:"informix".si_cliente
				WHERE numcte = pNumCte;
				*/
				--DSB-03072017
				SELECT rela.cliente, si.nombre1, NVL(TRIM(si.nombre2), ''), si.apell_paterno, NVL(TRIM(si.apell_materno), '')
				INTO cNumCteRef, cNombreUno, cNombreDos, cApellPat, cApellMat
				FROM bdinteg:"informix".si_cliente si
				JOIN bdinteg:"informix".si_relacion_ctebcplcpl rela
				ON rela.numcte_banco = si.numcte
				WHERE numcte = pNumCte;
				
				SELECT DAY(fechaasignacion), MONTH(fechaasignacion), YEAR(fechaasignacion) 
				INTO cDiaAltaCliente, cMesAltaCliente, cYearAltaCliente
				FROM bditarjcop:"informix".tarjetasnumtarcop WHERE numtarjeta = cNumCteRef;

				SELECT sexo, YEAR(fecha_nac), MONTH(fecha_nac), DAY(fecha_nac), estado_civil, NVL(TRIM(habita_en), '')
				INTO cSexo, cAnioNac, cMesNac, cDiaNac, cEdoCivil, cHabitaEn
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte = pNumCte;

				/*
				SELECT MAX(secuencia) INTO iSecuenciaMax1 FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pNumCte AND tipo_dir = '1';
				--- DSB-30/08/2012
				SELECT NVL(TRIM(numeroextcalle), ''), numerociudad, numerocolonia, NVL(TRIM(REPLACE(entre_calles,'|',' ')), ''), numerocalle, NVL(TRIM(puntocardinal), ''), NVL(TRIM(REPLACE(observaciones,'|',' ')), ''), 
				DECODE(unidadhabitac,'S',1,'1',1,'N',0,'0',0,0),
					   manzana, otros, andador, etapa, lote, edificio, entrada, NVL(TRIM(telefono1), ''), NVL(TRIM(telefono2), '')
				INTO cCasa, iNumeroCiudad, iNumeroColonia, cEntreCalles, iNumeroCalle, cRumbo, cObservaciones, iFlagUH, iManzana,
					 iOtros, iAndador, iEtapa, iLote, iEdificio, iEntrada, cTelefonoCliente, cTelefono2
				FROM bdinteg:"informix".si_direcciones_actual
				WHERE numcte = pNumCte
				AND tipo_dir = '1'
				AND secuencia = iSecuenciaMax1;
				*/
				SELECT NVL(TRIM(dir.numeroextcalle), ''), dir.numerociudad, dir.numerocolonia, NVL(TRIM(REPLACE(dir.entre_calles,'|',' ')), ''), dir.numerocalle, 
					   NVL(TRIM(dir.puntocardinal), ''), NVL(TRIM(REPLACE(dir.observaciones,'|',' ')), ''), DECODE(dir.unidadhabitac,'S',1,'1',1,'N',0,'0',0,0),
					   dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote, dir.edificio, dir.entrada, --- NVL(TRIM(telefono1), ''), NVL(TRIM(telefono2), '')
					   NVL(TRIM(tel1.telefono), ''), NVL(TRIM(tel2.telefono), '')
				INTO cCasa, iNumeroCiudad, iNumeroColonia, cEntreCalles, iNumeroCalle, cRumbo, cObservaciones, iFlagUH, iManzana,
					--iOtros, iAndador, iEtapa, iLote, iEdificio, iEntrada, cTelefonoCliente, cTelefono2--DSB-09/03/2015
					iOtros, iAndador, iEtapa, iLote, iEdificio, iEntrada, cTelefonoClienteT, cTelefono2T
				FROM bdinteg:"informix".si_direcciones_actual dir
				LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
				LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
				WHERE dir.numcte = pNumCte
				AND dir.tipo_dir = '1';

				--- EXECUTE PROCEDURE bdinteg:"informix".sp_ConvierteNumerodeCasa(cCasa) INTO cCodRetCasa, cCasa, cLetrasNumCasa;

				--DSB-09/03/2015
				/*IF cCasa = '' THEN
					LET cCasa = '1';
				END IF;*/
				EXECUTE PROCEDURE "informix".sp_esnumerico (cCasa) INTO cCodRetInt;
				IF cCodRetInt = 'F' OR (cCasa::int) = 0 THEN
						LET cCasa = '1';
				END IF;

				/*
				SELECT MAX(secuencia) INTO iSecuenciaMax2 FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pNumCte AND tipo_dir = '2';
				SELECT NVL(TRIM(numeroextcalle), ''), numerociudad, numerocolonia, numerocalle, NVL(TRIM(telefono3), ''), extension
				INTO cCasaTrabajo, iNumeroCiudadDeTrabajo, iNumeroColoniaDeTrabajo, iNumeroCalleDeTrabajo, cTelefonoTrabajoCliente, iExtension
				FROM bdinteg:"informix".si_direcciones_actual
				WHERE numcte = pNumCte AND tipo_dir = '2' AND secuencia = iSecuenciaMax2;
				*/
				SELECT NVL(TRIM(dir.numeroextcalle), ''), dir.numerociudad, dir.numerocolonia, dir.numerocalle, --- NVL(TRIM(telefono3), ''), extension
					   NVL(TRIM(tel3.telefono), ''), tel3.extension
				--INTO cCasaTrabajo, iNumeroCiudadDeTrabajo, iNumeroColoniaDeTrabajo, iNumeroCalleDeTrabajo, cTelefonoTrabajoCliente, iExtension --DSB-09/03/2015
				INTO cCasaTrabajo, iNumeroCiudadDeTrabajo, iNumeroColoniaDeTrabajo, iNumeroCalleDeTrabajo, cTelefonoTrabajoClienteT, iExtension
				FROM bdinteg:"informix".si_direcciones_actual dir
				LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
				WHERE dir.numcte = pNumCte 
				AND dir.tipo_dir = '2';

				--- EXECUTE PROCEDURE bdinteg:"informix".sp_ConvierteNumerodeCasa(cCasa) INTO cCodRetTrabajo, cCasaTrabajo, cLetrasNumeroTrabajo;

				--DSB-09/03/2015
				/*IF cCasaTrabajo = '' THEN
					LET cCasaTrabajo = '1';
				END IF;*/

				SELECT MAX(sec_ingreso)
				INTO iSecuenciaIng
				FROM bdinteg:"informix".si_ingresos
				WHERE empresa = pEmpresa AND numcte = pNumCte;

				SELECT NVL(TRIM(nombre_empresa), '')
				INTO cLugarDeTrabajo
				FROM bdinteg:"informix".si_ingresos
				WHERE empresa = pEmpresa
				AND numcte = pNumCte
				AND sec_ingreso = iSecuenciaIng;

				IF cEdoCivil = 'E' THEN
					SELECT MAX(secuencia)
					INTO iSecuenciaRef1
					FROM bdinteg:"informix".si_refclientes
					WHERE empresa = pEmpresa
					AND numcte = pNumCte
					AND parentesco <> 'E'
					AND secuencia > 0;
				ELSE
					SELECT MAX(secuencia) -1
					INTO iSecuenciaRef1
					FROM bdinteg:"informix".si_refclientes
					WHERE empresa = pEmpresa
					AND numcte = pNumCte
					AND parentesco <> 'E'
					AND secuencia > 0;
				END IF;

				SELECT nombre1, NVL(TRIM(nombre2), ''), apell_paterno, NVL(TRIM(apell_materno), '')
				INTO cNombreUnoRef, cNombreDosRef, cApellUnoReferencia, cApellDosReferencia
				FROM bdinteg:"informix".si_refclientes
				WHERE empresa = pEmpresa
				AND numcte = pNumCte
				AND secuencia = iSecuenciaRef1;

				SELECT NVL(TRIM(telefono1), '')
				--INTO cTelefonoReferencia--DSB-09/03/2015
				INTO cTelefonoReferenciaT
				FROM bdinteg:"informix".si_refdirecciones
				WHERE numcte = pNumCte
				AND secuencia = iSecuenciaRef1;

				SELECT NVL(TRIM(user_insert), '')
				INTO cEmpleadoEfectuo
				FROM bdisolic:"informix".ss_solicitudes
				WHERE num_solicitud = pNumSolicitud;

				SELECT NVL(TRIM(sucursal), '')
				INTO cSucursal
				FROM bdinteg:"informix".si_adiccoppel
				WHERE empresa = pEmpresa AND numctecoppel = cNumCteRef AND secuencia = 1;

				/*SELECT TRIM(ciudad), TRIM(estado)
				INTO cCiudadSucursal, cEstadoSucursal
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = cSucursal;*/
				
				SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)}TRIM(cve_ciudad),TRIM(cve_estado) 
				INTO cCiudadSucursal, cEstadoSucursal
				FROM bdinteg:"informix".si_ptf 
				WHERE id_ptf = cSucursal AND tipo='S';				
				
				SELECT FIRST 1 ciudad_coppel
				INTO iCiudadTiendaMov
				FROM bdinteg:"informix".si_ciudades
				WHERE ciudad = cCiudadSucursal AND estado = cEstadoSucursal;
				
				--DSB-03072017			
				IF NVL(iCiudadTiendaMov,0) = 0 THEN
				SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad_coppel) = 'V' THEN ciudad_coppel::INTEGER ELSE 0 END
				INTO iCiudadTiendaMov FROM bdinteg:"informix".si_ciudades WHERE ciudad = cCiudadSucursal and ciudad_coppel <> 0;
				END IF;

				IF NVL(iCiudadTiendaMov,0) = 0 THEN
				SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad_coppel) = 'V' THEN ciudad_coppel::INTEGER ELSE 0 END
				INTO iCiudadTiendaMov FROM bdinteg:"informix".si_ciudades WHERE ciudad_coppel <> 0;
				END IF;

				SELECT FIRST 1 numerocoloniacoppel, numerociudadcoppel
				INTO iColoniaCoppel, iCiudadCoppel
				FROM bdinteg:"informix".si_catzonas
				WHERE numerociudad = iNumeroCiudad AND numerocolonia = iNumeroColonia;

				SELECT FIRST 1 numerocoloniacoppel, numerociudadcoppel
				INTO iColoniaCoppelTrabajo, iCiudadCoppelTrabajo
				FROM bdinteg:"informix".si_catzonas
				WHERE numerociudad = iNumeroCiudadDeTrabajo AND numerocolonia = iNumeroColoniaDeTrabajo;
				
				--dsb-07/11/2012
				IF NVL(iColoniaCoppel,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO iColoniaCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal;
				END IF;
				
				IF NVL(iCiudadCoppel,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
					INTO iCiudadCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal;
				END IF;
				
				IF NVL(iColoniaCoppelTrabajo,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO iColoniaCoppelTrabajo FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal;
				END IF;
				
				IF NVL(iCiudadCoppelTrabajo,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
					INTO iCiudadCoppelTrabajo FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal;
				END IF;
				
				--dsb-21/08/2012
				SELECT lineacredito_real, DAY(fechalineacreditoreal), MONTH(fechalineacreditoreal), YEAR(fechalineacreditoreal),
					DAY(fechalineacreditotope), MONTH(fechalineacreditotope), YEAR(fechalineacreditotope),
					par_celulares, par_altoriesgo, par_prestamos, flaglineacreditoesp, lineacreditotope, limitecredito,
					situacion_especial, causa_sitesp,prepuntajealtoriesgo,puntos_parcn,nuevo_puntajefinal,    --DSB-14082017
					canal_origensol,grupo_eval,grupo_hit --598
				INTO iLineaDeCreditoReal, cDiaFechaLineaDeCreditoReal, cMesFechaLineaDeCreditoReal, cAnioFechaLineaDeCreditoReal,
					cDiaFechaLineaDeCreditoTope, cMesFechaLineaDeCreditoTope, cAnioFechaLineaDeCreditoTope,
					iParCelulares, iParAltoRiesgo, iParPrestamo, iFlagLineaCreditoEsp, iLineaDeCreditoTope, iLimiteDeCredito,
					cSituacionEspecial, iCausaSituacionEspecial,iPrepuntajeAltoRiesgo,iPuntosParcn,iPuntajeFinalParamcn,  --DSB-14082017
					cCanal_OrigenSol,cGrupo_Eval,cGrupo_Hit --598
				FROM bdisolic:"informix".ss_nuevo_parametrico
				WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud
				AND ROWID = (SELECT MAX(ROWID) FROM bdisolic:"informix".ss_nuevo_parametrico
				WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud);

				IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud) >= 1 THEN
					LET cSituacionEspecial = 'S';
					LET iCausaSituacionEspecial = 50;
				/*ELSE
					SELECT MAX(fecha_solicitud) INTO dFechaMaxima FROM bdisolic:"informix".ss_solicitud_os WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud;
					SELECT NVL(TRIM(situacionespecial), ''), causasituacionespecial
					INTO cSituacionEspecial, iCausaSituacionEspecial
					FROM bdisolic:"informix".ss_solicitud_os
					WHERE empresa = pEmpresa AND fecha_solicitud = dFechaMaxima AND num_solicitud = pNumSolicitud;*/
				END IF;
				
				--DSB-16/02/2015
				--Validaciones extras a los campos para eliminar caracteres extrañso
				EXECUTE PROCEDURE sp_alfanumerico (cEntreCalles) INTO cEntreCalles;
				EXECUTE PROCEDURE sp_alfanumerico (cObservaciones) INTO cObservaciones;
				EXECUTE PROCEDURE sp_alfanumerico (cTelefonoClienteT) INTO cTelefonoCliente;
				EXECUTE PROCEDURE sp_alfanumerico (cTelefono2T) INTO cTelefono2;
				EXECUTE PROCEDURE sp_alfanumerico (cCasaTrabajo) INTO cCasaTrabajo;
				EXECUTE PROCEDURE sp_alfanumerico (cTelefonoTrabajoClienteT) INTO cTelefonoTrabajoCliente;
				EXECUTE PROCEDURE sp_alfanumerico (cTelefonoReferenciaT) INTO cTelefonoReferencia;
				
				EXECUTE PROCEDURE "informix".sp_esnumerico (cCasaTrabajo) INTO cCodRetInt;
				IF cCodRetInt = 'F' OR (cCasaTrabajo::INT) = 0 THEN
						LET cCasaTrabajo = '1';
				END IF;
				
				LET cEntreCalles = TRIM(cEntreCalles);
				LET cObservaciones = TRIM(cObservaciones);
				LET cTelefonoCliente = TRIM(cTelefonoCliente);
				LET cTelefono2 = TRIM(cTelefono2);
				LET cCasaTrabajo = TRIM(cCasaTrabajo);
				LET cTelefonoTrabajoClienteT = TRIM(cTelefonoTrabajoClienteT);
				LET cTelefonoReferencia = TRIM(cTelefonoReferencia);

				LET cNumCteRef = NVL(cNumCteRef,'');
				LET cNombreUno = NVL(cNombreUno,'');
				IF cNombreDos IS NULL OR cNombreDos = '' THEN
					LET cNombreDos = ' ';
				END IF;
				LET cApellPat = NVL(cApellPat,'');
				IF cApellMat IS NULL OR cApellMat = '' THEN
					LET cApellMat = ' ';
				END IF;
				LET cSexo = NVL(cSexo,'');
				LET cDiaNac = NVL(cDiaNac,'01');
				LET cMesNac = NVL(cMesNac,'01');
				LET cAnioNac = NVL(cAnioNac,'1900');
				LET cEdoCivil = NVL(cEdoCivil,'');
				LET iColoniaCoppel = NVL(iColoniaCoppel,0);
				LET iCiudadCoppel = NVL(iCiudadCoppel,0);
				LET iNumeroCalle = NVL(iNumeroCalle,0);
				IF cCasa IS NULL OR cCasa = '' THEN
					LET cCasa = '1';
				END IF;
				IF cRumbo IS NULL OR cRumbo = '' THEN
					LET cRumbo = ' ';
				END IF;
				IF cObservaciones IS NULL OR cObservaciones = '' THEN
					LET cObservaciones = 'E';
				END IF;
				IF cEntreCalles IS NULL OR cEntreCalles = '' THEN
					LET cEntreCalles = ' ';
				END IF;
				IF iFlagUH IS NULL THEN
					LET iFlagUH = 0;
				END IF;
				IF iManzana IS NULL THEN
					LET iManzana = 0;
				END IF;
				IF iOtros IS NULL THEN
					LET iOtros = 0;
				END IF;
				IF iAndador IS NULL THEN
					LET iAndador = 0;
				END IF;
				IF iEtapa IS NULL THEN
					LET iEtapa = 0;
				END IF;
				IF iLote IS NULL THEN
					LET iLote = 0;
				END IF;
				IF iEdificio IS NULL THEN
					LET iEdificio = 0;
				END IF;
				IF iEntrada IS NULL THEN
					LET iEntrada = 0;
				END IF;
				IF cLetrasNumCasa IS NULL OR cLetrasNumCasa = '' THEN
					LET cLetrasNumCasa = ' ';
				END IF;
				IF cTelefono2 IS NULL THEN
					LET cTelefono2 = '0';
				END IF;
				IF cHabitaEn IS NULL OR cHabitaEn = '' THEN
					LET cHabitaEn = ' ';
				END IF;
				IF cSituacionEspecial IS NULL OR cSituacionEspecial = '' THEN
					LET cSituacionEspecial = ' ';
				END IF;
				IF iCausaSituacionEspecial IS NULL THEN
					LET iCausaSituacionEspecial = 0;
				END IF;
				IF iIngresoMensual IS NULL THEN
					LET iIngresoMensual = 0;
				END IF;
				IF iLimiteDeCredito IS NULL THEN
					LET iLimiteDeCredito = 0;
				END IF;
				IF cLugarDeTrabajo IS NULL OR cLugarDeTrabajo = '' THEN
					LET cLugarDeTrabajo = ' ';
				END IF;
				IF iCiudadCoppelTrabajo IS NULL THEN
					LET iCiudadCoppelTrabajo = 0;
				END IF;
				IF iColoniaCoppelTrabajo IS NULL THEN
					LET iColoniaCoppelTrabajo = 0;
				END IF;
				IF iNumeroCalleDeTrabajo IS NULL THEN
					LET iNumeroCalleDeTrabajo = 0;
				END IF;
				IF cCasaTrabajo IS NULL OR cCasaTrabajo = '' THEN
					LET cCasaTrabajo = '1';
				END IF;
				IF cLetrasNumeroTrabajo IS NULL OR cLetrasNumeroTrabajo = '' THEN
					LET cLetrasNumeroTrabajo = ' ';
				END IF;
				IF iExtension IS NULL THEN
					LET iExtension = 0;
				ELSE
					--dsb-30/08/2012 se llega hasta el maximo permitido por small int
					IF iExtension > 32767 THEN
					LET	iExtension = 0;
					END IF;
				END IF;
				LET cNombreUnoRef = NVL(cNombreUnoRef,'');
				IF cNombreDosRef IS NULL OR cNombreDosRef = '' THEN
					LET cNombreDosRef = ' ';
				END IF;
				LET cApellUnoReferencia = NVL(cApellUnoReferencia,'');
				IF cApellDosReferencia IS NULL OR cApellDosReferencia = '' THEN
					LET cApellDosReferencia = ' ';
				END IF;
				LET cDiaAltaCliente = NVL(cDiaAltaCliente,'01');
				LET cMesAltaCliente = NVL(cMesAltaCliente,'01');
				LET cYearAltaCliente = NVL(cYearAltaCliente,'1900');
				IF cSucursal IS NULL OR cSucursal = '' THEN
					LET cSucursal = ' ';
				END IF;
				IF cEmpleadoEfectuo IS NULL OR cEmpleadoEfectuo = '' THEN
					LET cEmpleadoEfectuo = ' ';
				END IF;
				IF iCiudadTiendaMov IS NULL THEN
					LET iCiudadTiendaMov = 0;
				END IF;
				IF iLineaDeCreditoTope IS NULL THEN
					LET iLineaDeCreditoTope = 0;
				END IF;
				IF iLineaDeCreditoReal IS NULL THEN
					LET iLineaDeCreditoReal = 0;
				END IF;
				LET cDiaFechaLineaDeCreditoReal = NVL(cDiaFechaLineaDeCreditoReal,'01');
				LET cMesFechaLineaDeCreditoReal = NVL(cMesFechaLineaDeCreditoReal,'01');
				LET cAnioFechaLineaDeCreditoReal = NVL(cAnioFechaLineaDeCreditoReal,'1900');
				LET cDiaFechaLineaDeCreditoTope = NVL(cDiaFechaLineaDeCreditoTope,'01');
				LET cMesFechaLineaDeCreditoTope	= NVL(cMesFechaLineaDeCreditoTope,'01');
				LET cAnioFechaLineaDeCreditoTope = NVL(cAnioFechaLineaDeCreditoTope,'1900');
				IF cTelefonoCliente IS NULL OR cTelefonoCliente = '' THEN
					LET cTelefonoCliente = '0';
				END IF;
				IF cTelefonoTrabajoCliente IS NULL OR cTelefonoTrabajoCliente = '' THEN
					LET cTelefonoTrabajoCliente = '0';
				END IF;
				IF cTelefonoReferencia IS NULL OR cTelefonoReferencia = '' THEN
					LET cTelefonoReferencia = '0';
				END IF;
				IF iParCelulares IS NULL THEN
					LET iParCelulares = 0;
				END IF;
				IF iParAltoRiesgo IS NULL THEN
					LET iParAltoRiesgo = 0;
				END IF;
				IF iParPrestamo IS NULL THEN
					LET iParPrestamo = 0;
				END IF;
				IF iFlagLineaCreditoEsp IS NULL THEN
					LET iFlagLineaCreditoEsp = 0;
				END IF;

				--Valores default
				LET iTipoMensaje = 0;
				LET iValorSeguridad = 1;
				LET cPuntualidad = 'N';
				LET iReposicionTarjeta = 0;
				LET iFlagclienteAnexo = 0;
				LET iFlagCobxTel = 0;
				LET iFlagDescuentoEspecial = 0;
				LET iFlagActualizarDatos = 0;
				LET iFlagHuella = 0;
				LET iMesesTranscurridos = 0;
				LET iNipTitular = 0;
				LET iNipAdicional1 = 0;
				LET iNipAdicional2 = 0;
				LET iGrupoSemaforoCN = 0;
				LET iStatusAfore = 0;
				LET iParametricosCelulares = 0;
				LET cClave = 'A';
				LET cTipoMovto = 'C';
				LET iCaja = 100;
				LET cArea = 'C';
				LET cSubPuntualidad	= ' ';
				LET iNivelLineaCreditoReal = 0;
				LET iNivelLineaCreditoTope = 0;
				LET cModeloCelulares = '1';
				LET iPedirTelefono = 0;
				LET cTelefono = '0';
				LET cTelefonoUnoTrabajo = '0';
				LET cTelefonoRef = '0';
				
				--598 INFORMACION NECESARIA PARA EL ENVIO AL PARAMETRICO
				LET cCanal_OrigenSol = TRIM(NVL(cCanal_OrigenSol,'0'));
				LET cGrupo_Eval	= TRIM(NVL(cGrupo_Eval,'0'));
				LET cGrupo_Hit = TRIM(NVL(cGrupo_Hit,'0'));
				
				--598.1 VALIDAR QUE SI LOS PARAMETROS VIENEN CON ESPACIO GUARDARLOS EN 0
				IF cCanal_OrigenSol = ' '  OR cCanal_OrigenSol = '' THEN
					LET cCanal_OrigenSol = '0';
				END IF;
				IF cGrupo_Eval = ' ' OR cGrupo_Eval = '' THEN
					LET cGrupo_Eval = '0';
				END IF;
				IF cGrupo_Hit = ' ' OR cGrupo_Hit = '' THEN
					LET cGrupo_Hit = '0';
				END IF;

				LET v_Cad1 = iTipoMensaje ||"|"||iValorSeguridad ||"|"|| TRIM(cNumCteRef) ||"|"|| TRIM(cNombreUno) ||"|"|| cNombreDos ||"|"|| TRIM(cApellPat)
					||"|"|| cApellMat ||"|"|| TRIM(cSexo) ||"|"|| TRIM(cDiaNac) ||"|"|| TRIM(cMesNac) ||"|"|| TRIM(cAnioNac)
					||"|"|| TRIM(cEdoCivil) ||"|"|| iCiudadCoppel ||"|"|| iColoniaCoppel ||"|"|| iNumeroCalle ||"|"|| cCasa
					||"|"|| cRumbo ||"|"|| cObservaciones ||"|"|| cEntreCalles ||"|"|| iFlagUH ||"|"|| iManzana ||"|"|| iOtros
					||"|"|| iAndador ||"|"|| iEtapa ||"|"|| iLote ||"|"|| iEdificio ||"|"|| iEntrada ||"|"|| DECODE(cLetrasNumCasa,'',' ',cLetrasNumCasa)
					||"|"|| TRIM(cTelefono) ||"|"|| TRIM(cTelefono2) ||"|"|| cHabitaEn ||"|"|| cSituacionEspecial
					||"|"|| iCausaSituacionEspecial ||"|"|| cPuntualidad ||"|"|| iIngresoMensual ||"|"|| iLimiteDeCredito
					||"|"|| iReposicionTarjeta ||"|"|| iFlagclienteAnexo ||"|"|| iFlagCobxTel ||"|"|| iFlagDescuentoEspecial
					||"|"|| iFlagActualizarDatos ||"|"|| iFlagHuella ||"|"|| iMesesTranscurridos ||"|"|| cLugarDeTrabajo ||"|"|| iCiudadCoppelTrabajo;

				LET v_Cad2 = iColoniaCoppelTrabajo ||"|"|| iNumeroCalleDeTrabajo ||"|"|| cCasaTrabajo ||"|"|| DECODE(cLetrasNumeroTrabajo,'',' ',cLetrasNumeroTrabajo)
					||"|"|| TRIM(cTelefonoUnoTrabajo) ||"|"|| iExtension ||"|"|| iNipTitular ||"|"|| iNipAdicional1 ||"|"|| iNipAdicional2  ||"|"|| TRIM(cNombreUnoRef)
					||"|"|| cNombreDosRef ||"|"|| TRIM(cApellUnoReferencia) ||"|"|| cApellDosReferencia ||"|"|| TRIM(cTelefonoRef)
					||"|"|| TRIM(cDiaAltaCliente) ||"|"|| TRIM(cMesAltaCliente) ||"|"|| TRIM(cYearAltaCliente) ||"|"|| iGrupoSemaforoCN
					||"|"|| iStatusAfore ||"|"|| iParametricosCelulares ||"|"|| cClave ||"|"|| cTipoMovto ||"|"|| cSucursal ||"|"|| iCaja
					||"|"|| cEmpleadoEfectuo ||"|"|| iCiudadTiendaMov ||"|"|| cArea ||"|"|| cSubPuntualidad ||"|"|| iLineaDeCreditoTope
					||"|"|| iLineaDeCreditoReal ||"|"|| TRIM(cDiaFechaLineaDeCreditoReal) ||"|"|| TRIM(cMesFechaLineaDeCreditoReal) ||"|"|| TRIM(cAnioFechaLineaDeCreditoReal)
					||"|"|| TRIM(cDiaFechaLineaDeCreditoTope) ||"|"|| TRIM(cMesFechaLineaDeCreditoTope) ||"|"|| TRIM(cAnioFechaLineaDeCreditoTope) ||"|"|| iNivelLineaCreditoReal
					||"|"|| iNivelLineaCreditoTope ||"|"|| TRIM(cTelefonoCliente) ||"|"|| TRIM(cTelefonoTrabajoCliente) ||"|"|| TRIM(cTelefonoReferencia)
					||"|"|| iParCelulares ||"|"|| cModeloCelulares ||"|"|| iParAltoRiesgo ||"|"|| iParPrestamo ||"|"|| iPedirTelefono ||"|"|| iFlagLineaCreditoEsp;
					
					EXECUTE PROCEDURE bdinteg:"informix".sp_obtienecteprospecto_club(pEmpresa, pNumCte)
							INTO cSPcodRet, cSPcteCplTitular, cSPcteCplProspecto;
							IF NVL(TRIM(cSPcodRet), '') = '' OR cSPcodRet <> '000000' THEN
								LET cSPcteCplProspecto = '0';
							END IF;
							
				

			END IF;
		END IF;

		--RETURN  cCodRet, TRIM(v_Cad1) || "|" || TRIM(v_Cad2) || "|";
		RETURN  cCodRet, TRIM(v_Cad1) || "|" || TRIM(v_Cad2) || "|" || TRIM(cSPcteCplProspecto) || "|" || iPrepuntajeAltoRiesgo || "|" || iPuntosParcn || "|" || iPuntajeFinalParamcn --DSB-14082017
				|| "|" || TRIM(cCanal_OrigenSol) || "|" || TRIM(cGrupo_Eval) || "|" || TRIM(cGrupo_Hit) || "|" ; --598

	END;
--##############################################################################################################################
--## Procedimiento       	: sp_altactecoppelnuevoparametricocteprospecto
--## Base de Datos       	: bdinteg
--## Creado por          	: Selene Campos
--## Fecha creacion      	: 24/10/2014
--## Solicita:				: Rodolfo Gomez
--## Descripcion          	: Se crea clon de sp_altactecoppelnuevoparametrico.sql y se le modificó para que regresará  número de --                            cliente prospecto coppel',
--###############################################################################################################################
END PROCEDURE
DOCUMENT
'Folio:			1560',
'Autor: 		94379114 - Victor Hugo Nuñez',
'Fecha: 		16/02/2015',
'Sustento:		(Re_ minuta reunión Alta de Clientes y Seguro Club).pdf',
'Solicita		Rodolfo Gomez',
'Descripción:	Se añaden validaciones por caracteres que son prohibidos para un servicio web',
'				se homologan espacios',
'*****************************************************************************************************************************************',
'Autor:			94480389 - Edwin S Castro',
'Etiqueta: 		--DSB-03072017',
'Sustento:		Correo',
'Solicita		Abraham Narvaez',
'Descripcion:	Se agregan condiciones para validar el campo ciudad_coppel, para que no se valla en cero',
'Se modifica una consulta para que el dato cNumCteref lo obtenga de la tabla si_relacion_ctebcplcpl',
'BD: 			    bdinteg',
'*****************************************************************************************************************************************',
'Autor:			97982571 - Jesus A. Alvarado',
'Etiqueta: 		--DSB-14082017',
'Solicita		Abraham Narvaez',
'Descripcion:	retorna nuevos campo iPrepuntajeAltoRiesgo,iPuntosParcn,iPuntajeFinalParamcn',
'BD: 			bdinteg',
'Folio:			292',
'*****************************************************************************************************************************************',
'PROYECTO: Petición 598.1 - RQM 09 488-3 IMPLEMENTACIÓN - ADENDUM - Homologación de Clientes BanCoppel - Coppel en alta única (Mensaje PP y % inicial de pago)',
'DESCRIPCION: SE AGREGA VALIDACIONES PARA CONTEMPLAR LOS NUEVOS CAMPOS A ENVIAR EN EL PROCESO DE ALTA DE CLIENTE COPPEL.',
'AUTOR: ISARAI BOJORQUEZ',
'BD: BDINTEG',
'FECHA: 09/08/2019',
'SOLICITA:ABRAHAM NARVAEZ',
'*****************************************************************************************************************************************';

CREATE PROCEDURE "informix".sp_cnsif_monitorsucursales2(cID_USUARIOC CHAR(8), cID_FUNCIONC CHAR(10), Tp_Busqueda CHAR(1), Id_Plaza CHAR(3), 
pNumRegistro INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS Cod_Retorno,
		CHAR(3) AS IdPlaza,
		CHAR(4) AS No_Sucursal,
		CHAR(40) AS Nom_Sucursal,
		CHAR(40) AS Gte_Sucursal,
		CHAR(14) AS Tel_Sucursal,
		CHAR(8) AS Estat_Suc,
		CHAR(2) AS Poliza_Suc;

	DEFINE cCodRet       CHAR(5);
	DEFINE iSql_err      INT;    
	DEFINE IdPlaza       CHAR(3);
	DEFINE No_Sucursal   CHAR(4);
	DEFINE Nom_Sucursal  CHAR(40);
	DEFINE Gte_Sucursal  CHAR(40);
	DEFINE Tel_Sucursal  CHAR(14);
	DEFINE Estat_Suc     CHAR(8);
	DEFINE fechadia      DATE;
	DEFINE Flag_abrio    CHAR(1);
	DEFINE Flag_cerro    CHAR(1);
	DEFINE iCont         INT;
	DEFINE cUsuario      CHAR(8);
	DEFINE Poliza_Suc    CHAR(2);
	
	LET cCodRet          = "00000";
	LET iSql_err         = 0;
	LET IdPlaza          = '';
	LET No_Sucursal      = '';
	LET Nom_Sucursal     = '';
	LET Gte_Sucursal     = '';
	LET Tel_Sucursal     = '';
	LET Estat_Suc        = '';
	LET fechadia         = '01-01-1900';
	LET Flag_abrio       = '';
	LET Flag_cerro       = '';
	LET iCont            = 0;
	LET cUsuario         = '';
	LET Poliza_Suc       = '';

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet, IdPlaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc;
			END IF;
		END EXCEPTION;

		 -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,cID_FUNCIONC) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, IdPlaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc;
		END IF;

		--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_monitorsucursales2.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion
			ps_idplaza, ps_no_sucursal,ps_nom_sucursal,ps_gte_sucursal,ps_tel_sucursal, ps_estat_suc, ps_poliza_suc
			INTO IdPlaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc
			FROM bdinteg:"informix".sw_detallemonitorps
			WHERE ps_usuario_insert = cID_USUARIOC
			ORDER BY ps_no_sucursal
			
			LET iCont = iCont + 1;
			RETURN cCodRet, IdPlaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc WITH RESUME;
		END FOREACH;
		
		IF pNumRegistro = 0 AND iCont = 0 THEN
			LET cCodRet = '00091';
			RETURN cCodRet, IdPlaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc;
		END IF;

		IF iCont = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, IdPlaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 24/10/2016',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MONITOR DE PASES CONTABLES DE SUCURSALES', 
'DESCRIPCION: Consulta detalle de Sucursales de acuerdo a criterios (Consulta por Plaza).',
'Se realiza la clonacion del spl original a la base bdicont para agregar la columna al grid con la consulta de las polizas contables.',
'AUTOR: Victor Hugo Sanchez Mendoza',
'FECHA: 10/11/2016',
'DESCRIPCION: Debido a que la respuesta que nos dieron fue muy ambigua y en el campo usuario de la tabla de poliza se refiere al numero de sucursal, cambie las variables.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 05/03/2018',
'DESCRIPCION: Se implementa el tratado de la información en segundo plano.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 06/01/2020',
'DESCRIPCION: Se aplica optimización de querys.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_pasesucursal2(cID_USUARIOC CHAR(8), cID_FUNCIONC CHAR(10), Num_Sucursal CHAR(4))
	RETURNING CHAR(5) AS Cod_Retorno,
		CHAR(3) AS Id_Plaza,
		CHAR(4) AS No_Sucursal,
		CHAR(40) AS Nom_Sucursal,
		CHAR(40) AS Gte_Sucursal,
		CHAR(14) AS Tel_Sucursal,
		CHAR(8) AS Estat_Suc,
		CHAR(2) AS Poliza_Suc;

	DEFINE cCodRet       CHAR(5);
	DEFINE iSql_err      INT;
	DEFINE Id_Plaza      CHAR(3);
	DEFINE No_Sucursal   CHAR(4);
	DEFINE Nom_Sucursal  CHAR(40);
	DEFINE Gte_Sucursal  CHAR(40);
	DEFINE Tel_Sucursal  CHAR(14);
	DEFINE Estat_Suc     CHAR(8);
	DEFINE fechadia      DATE;
	DEFINE Flag_abrio    INTEGER;
	DEFINE Flag_cerro    INTEGER;
	DEFINE cUsuario      CHAR(8);
	DEFINE Poliza_Suc    CHAR(2);
    DEFINE iCont         INT;
	
	LET cCodRet          = "00000";
	LET iSql_err         = 0;
	LET Id_Plaza         = '';
	LET No_Sucursal      = '0000';
	LET Nom_Sucursal     = '';
	LET Gte_Sucursal     = '';
	LET Tel_Sucursal     = '';
	LET Estat_Suc        = '';
	LET fechadia         = '01-01-1900';
	LET Flag_abrio       = 0;
	LET Flag_cerro       = 0;
	LET cUsuario         = '';
	LET Poliza_Suc       = '';
	LET iCont            = 0;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc;
			END IF;
		END EXCEPTION;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,cID_FUNCIONC) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc;
		END IF;

		--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_pasesucursal2.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT ps_idplaza,ps_no_sucursal,ps_nom_sucursal,ps_gte_sucursal,ps_tel_sucursal,ps_estat_suc,ps_poliza_suc
			INTO Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc
			FROM bdinteg:"informix".sw_detallemonitorps
			WHERE ps_usuario_insert = cID_USUARIOC
			ORDER BY ps_no_sucursal
			
			LET iCont = iCont + 1;
			RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc WITH RESUME;
		END FOREACH;
		
		IF NVL(iCont,0) = 0 THEN
			LET cCodRet = "00105";
			RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT  'AUTOR: L. Montserrat León Amador',
'FECHA: 24/10/2016',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MONITOR DE PASES CONTABLES DE SUCURSALES', 
'DESCRIPCION: Consulta detalle de Sucursales de acuerdo a criterios (Numero de Sucursal).',
'Se realiza la clonación del spl original a la base bdicont para agregar la columna al grid con la consulta de las pólizas contables.',
'AUTOR: TASF',
'FECHA: 10/11/2016',
'DESCRIPCION: De acuerdo a indicaciones se realiza el cambio de variables al momento de realizar el cruce con la tabla co_poliza (cUsuario por No_Sucursal).',
'AUTOR: L. Montserrat León Amador',
'FECHA: 05/03/2018',
'DESCRIPCION: Se implementa el tratado de la información en segundo plano.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 06/01/2020',
'DESCRIPCION: Se aplica optimización de querys.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_valida_folio_sms_coppel(pEmpresa CHAR(3), pSucursal CHAR(4), pProducto CHAR(8),pNumCte CHAR(20), pEjecutivo CHAR(8))
RETURNING CHAR(6)        AS codigo_retorno,
		  INTEGER        AS flag_bton_sms,
          INTEGER        AS flag_dll,
          INTEGER        AS cont_rpte;

	DEFINE cCodRet		CHAR(6);
	DEFINE iSqlErr		INTEGER;
	DEFINE iSamErr		INTEGER;
	DEFINE cErrorInfo	VARCHAR(80,1);
	DEFINE iReqVal      INTEGER; 
	DEFINE iFlag        INTEGER;   
	DEFINE cTelefono    CHAR(13);
	DEFINE iFlagSMS    	INTEGER;
	DEFINE iContador	INTEGER;
	DEFINE iParamCont	INTEGER;
	DEFINE iTotTel		INTEGER;
	DEFINE iFlagDll		INTEGER;
	DEFINE iContRepte	INTEGER;
	DEFINE cVerificado    CHAR(1);
    DEFINE ccampocuatro INTEGER;
	DEFINE cGrupo  CHAR(1);
	DEFINE cNumSolic VARCHAR(20);
	DEFINE dEvaluacion DECIMAL(5,2);
	DEFINE iScorePropietario INTEGER;
	DEFINE sParamSMS    CHAR(1);
	DEFINE cProducto         CHAR(4);
	DEFINE cValSms           CHAR(1);

	LET cCodRet			= "000000";
	LET iSqlErr			= 0;
	LET iSamErr			= 0;
	LET cErrorInfo		= "";
	LET iReqVal         = 0;
	LET iFlag           = 0;
	LET cTelefono       = '';
	LET iFlagSMS       	= 0;
	LET iContador       = 0;
	LET iParamCont      = 0;
	LET iTotTel      	= 0;
	LET iFlagDll      	= 0;
	LET iContRepte      = 0;
	LET cVerificado       = '';
    LET ccampocuatro    = "";
	LET cGrupo          = "";
	LET cNumSolic  		= "";
	LET dEvaluacion 	= 0;
	LET iScorePropietario = 0;
	LET sParamSMS 		= "0";
	LET cProducto     ='0000';
	LET cValSms     = "";

	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);
			END IF;
		END EXCEPTION; 	

		--SET DEBUG FILE TO "/tmp/sp_valida_folio_sms.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
		--VALIDANDO EL PARAMETRO POR CONTINGENCIA -- ANJ
		  --SELECT valor INTO sParamSMS FROM bdinteg:si_param WHERE cod_param='469';
		  --IF sParamSMS = "1" THEN
			-- RETURN NVL(cCodRet,''),0,0,0;
		  --END IF;	
		--VALIDANDO EL PARAMETRO POR CONTINGENCIA -- ANJ		
		
		--RQI 23 496 
		SELECT num_producto, valida_sms
		INTO cProducto, cValSms
		FROM bdicred:sd_definicion 
		WHERE num_producto = pProducto;
			
		IF cProducto = '' or cProducto is null THEN			
			SELECT producto, valida_sms
			INTO cProducto, cValSms
			FROM bdicheq:sc_producto
			WHERE producto = pProducto;
		END IF;
			
		IF cValSms = 0 THEN
			RETURN NVL(cCodRet,''),0,0,0;
		END IF;		
		
		--Fin RQI 23 496		

		IF TRIM(NVL(pEmpresa,"")) = "" OR TRIM(NVL(pSucursal,"")) = "" OR TRIM(NVL(pProducto,"")) = ""  OR  TRIM(NVL(pNumCte,"")) = "" OR TRIM(NVL(pEjecutivo,"")) = "" THEN
			LET cCodRet  = "000001";
			RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);
		END IF;
				
		IF pProducto='6500' THEN
            SELECT nvl(b.campo_4,'0')
                INTO  ccampocuatro
        		FROM  bdisolic: ss_solicitudes a inner join 
            		  bdisolic: ss_nuevo_parametrico b 
                	  on a.num_solicitud=b.num_solicitud
                WHERE a.empresa=pEmpresa
            		and a.numcte=pNumCte
            		and a.sucursal=pSucursal
                    and a.num_producto = '6500'
                    and a.status_solicitud='AP';
            IF (ccampocuatro = "1") THEN
        			LET iFlagDll=0;
            	RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);	 
             END IF;
		End if;		

		SELECT LIMIT 1 1 
		INTO iReqVal
		FROM "informix".si_prod_sucursal_sms
		WHERE empresa = pEmpresa
		AND num_producto = pProducto
		AND sucursal = pSucursal;
		 
		IF NVL(iReqVal,0) = 0 THEN	

			SELECT count(telefono)
			INTO iTotTel
			FROM "informix".si_telefonos
			WHERE numcte = pNumCte
			AND status_tel = 'A'
			AND tipo_tel IN (1,2);
				
			IF NVL(iTotTel,0) = 1 THEN
				SELECT NVL(telefono ,'')
				INTO cTelefono
				FROM "informix".si_telefonos
				WHERE numcte = pNumCte AND tipo_tel = 1 
				AND status_tel = 'A' AND NVL(verificado,'F') = 'F';

				IF NVL(cTelefono,'') <> '' THEN
					LET iFlagDll = 1;

					SELECT NVL(cont_rpte,0) INTO iContRepte
					FROM "informix".si_bit_intentos_ivr
					WHERE numcte = pNumCte
					AND numtel = TRIM(cTelefono)
					AND empresa = pEmpresa;
				END IF;
			END IF;
			
			IF NVL(iFlagDll,0) = 0 THEN
			
			
			-- RQI 27 008 20/01/2016 Se agrega validación para relacionar la tabla si_telefonos donde el telefono haya sido verificado JMA
				SELECT LIMIT 1 a.telefono
				  INTO cTelefono
				  FROM "informix".si_telefonos_actual a
				  INNER JOIN  "informix".si_telefonos b on (b.numcte     = a.numcte 
														   AND b.tipo_tel   = a.tipo_tel
														   AND b.status_tel = a.status_tel
														   AND b.telefono = a.telefono 
														   AND b.verificado = 'V')
				 WHERE a.numcte     = pNumCte
				   AND a.tipo_tel   = 1
				   AND a.status_tel = 'A';
				   
				   IF NVL(cTelefono,'') = '' THEN
						LET iFlag = 0;
				   ELSE		
						LET iFlag = 1;	   
				   END IF;
			
				IF iFlag = 0 THEN
					SELECT LIMIT 1 a.telefono, b.verificado 
					  INTO cTelefono,cVerificado 
					  FROM "informix".si_telefonos_actual a
					  LEFT JOIN  "informix".si_telefonos b on (b.numcte     = a.numcte 
														   AND b.tipo_tel   = a.tipo_tel
														   AND b.status_tel = a.status_tel
														   AND b.telefono = a.telefono 
														   )
					 WHERE a.numcte     = pNumCte
					   AND a.tipo_tel   = 2
					   AND a.status_tel = 'A';
					   
					   IF NVL(cTelefono,'') = '' or  cVerificado = 'V' THEN
							LET iFlag = 1;
					   END IF;
				END IF;	   
				IF iFlag = 0 THEN
						FOREACH 
							SELECT LIMIT 1 1
							   INTO iFlag
							   FROM "informix".si_bitsmstels b
							  WHERE b.numcte     = pNumCte
							   AND b.telefono   = cTelefono
							   AND b.bandera    = 't'
						  ORDER BY b.fecha DESC
						END FOREACH
				END IF;
				
				IF NVL(iReqVal,0) = 0 AND NVL(iFlag,0) = 0 THEN
					LET iFlagDll = 2;
				END IF;
			END IF;

			IF NVL(iFlagDll,0) = 2 THEN
				IF NVL(cTelefono,'') <> '' THEN
					
					SELECT NVL(valor,0)::integer INTO iParamCont
					FROM "informix".si_param
					WHERE cod_param = 404;
						
					SELECT NVL(cont_sms,0) INTO iContador
					FROM "informix".si_bit_intentos_ivr
					WHERE empresa = pEmpresa
					AND numcte = pNumCte
					AND numtel = TRIM(cTelefono);
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET iContador = 0; --No se encontraron registros
					END IF;
					
					IF NVL(iContador,0) < NVL(iParamCont,0) THEN
						LET iFlagSMS = 1;
					END IF;
					
				ELSE
					LET iFlagSMS = 1;
				END IF;
			END IF;
		END IF;
		
		IF iFlagDll <> 0 THEN 
				IF pProducto = '6001' THEN
					SELECT b.grupo, a.num_solicitud
					  INTO cGrupo, cNumSolic
					  FROM bdisolic:"informix".ss_solicitudes a, bdisolic:"informix".ss_resum_scor_fin b
						WHERE a.empresa = b.empresa
						  AND a.num_solicitud = b.num_solicitud
						  and a.numcte = pNumCte
						  --and a.sucursal = pSucursal
						  and a.num_producto = '6001'
						  and a.status_solicitud = 'AT';
						  
						  IF NVL(cGrupo,'') IN ('1','2','A') THEN
						  
								SELECT valor 
								  INTO iScorePropietario 
								  FROM bdisolic:"informix".ss_param 
								 WHERE empresa = pEmpresa 
								   AND secuencia = 385;
							
							  SELECT evaluacion
								 INTO dEvaluacion
								 FROM bdisolic:"informix".ss_resumen_scoring 
								WHERE empresa = pEmpresa
								  and num_solicitud = cNumSolic
								  and seccion = 2;						  
								  
								  IF NVL(dEvaluacion,0) >= iScorePropietario THEN
									  UPDATE bdisolic:"informix".ss_revision_determinacion
										 SET excluye_validacion = 1
									   WHERE empresa = pEmpresa
										 AND num_solicitud = cNumSolic;
										 
										 LET iFlagDll=0;
										 RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);	 													  
								  END IF;
						  END IF;		
				END IF;
		END IF;	
		
		RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para revisar si el folio sms ya fue validado',
'FECHA: 12/NOV/2015',
'BD: bdinteg',
'AUTOR: PAUL IVAN QUINTERO VARELA',
'MODIFICACION: Se agrega bandera para saber si el reenvio del sms ya alcanzo el limite permitido',
'FECHA: 29/DIC/2015',
'AUTOR: ERNESTO AGUILERA';

CREATE PROCEDURE  "informix".cons_tarjetas_cte_web(pempresa     CHAR(3),
                                              pnumcte      CHAR(20),
                                              pregistros   SMALLINT)

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Cliente
          CHAR(26),      -- Nombre1
	      CHAR(26),      -- Nombre2
	      CHAR(26),      -- Apellido Paterno
          CHAR(26),      -- Apellido Materno
          DATE,  	     -- Fecha Nacimiento
	      CHAR(13),      -- RFC
	      CHAR(20),      -- CUENTA
	      CHAR(20),      -- TARJETA
	      CHAR(1),       -- STATUS APLICATIVO
	      SMALLINT,      -- SISTEMA
          CHAR(50),      -- PRODUCTO
          CHAR(50),      -- DIVISA
          CHAR (3);      -- STATUS DE INTERCARD

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_numcte        CHAR(20);
DEFINE s_nombre1       CHAR(26);
DEFINE s_nombre2       CHAR(26);
DEFINE s_paterno       CHAR(26);
DEFINE s_materno       CHAR(26);
DEFINE s_fechanac      DATE;
DEFINE s_rfc           CHAR(13);
DEFINE s_cuenta        CHAR(20);
DEFINE s_tarjeta       CHAR(20);
DEFINE v_cuantos       SMALLINT;
DEFINE s_status        CHAR(1);
DEFINE s_sistema       SMALLINT;
DEFINE s_status_cta    CHAR(1);
DEFINE s_producto      CHAR(50);
DEFINE s_divisa        CHAR(50);
DEFINE s_codstatustarjeta CHAR(3);
DEFINE s_rfc_alterno   CHAR(13);
DEFINE cProdTransfer   CHAR(4);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
SET OPTIMIZATION HIGH;
SET OPTIMIZATION ALL_ROWS;
LET scod_ret      = "00000";
LET vsqlerr       = 0;
LET v_cuantos     = 0;
LET s_numcte      = "";
LET s_nombre1	= "";
LET s_nombre2	= "";
LET s_paterno	= "";
LET s_materno	= "";
LET s_fechanac	= "";
LET s_rfc	      = "";
LET s_cuenta	= "";
LET s_tarjeta	= "";
LET s_status      = "";
LET s_sistema     = 0;
LET s_status_cta  = "";
LET s_producto    = "";
LET s_divisa      = "";
LET s_codstatustarjeta = "";
LET s_rfc_alterno = "";
LET cProdTransfer	= "";
--scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO dirty READ;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/integral/cons_tarjetas_cte.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   LET pempresa = pempresa;
   LET pnumcte = pnumcte;


  -- Valida Parametros de Entrada

  IF pempresa = "" or
     pnumcte = ""  then
     LET scod_ret = "00110";
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
  END IF


	SELECT valor 
	INTO cProdTransfer
	FROM bditransfer:"informix".tf_param 
	WHERE empresa = pempresa 
	AND	cod_param = 4;

  -- Extrae las Tarjeta de Cheques
	-- Se agrega la validaciÃ³n a la sc_firmantes para solo buscar tarjetas autorizadas
	-- CGP 10032015
  FOREACH
     SELECT a.cuenta, a.num_tarjeta, a.numcte, a.status_tar, e.producto || " " || e.nombre,f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta, b.rfc_alterno  
       INTO s_cuenta, s_tarjeta, s_numcte,s_status, s_producto, s_divisa,
            s_nombre1,s_nombre2,s_paterno,s_materno,s_rfc,
            s_fechanac, s_codstatustarjeta, s_rfc_alterno
       FROM bdicheq:"informix".sc_tarjeta a,
            bdinteg:"informix".si_cliente b,
            bdinteg:"informix".si_ctepf c,
            bdicheq:"informix".sc_maechq d,
            bdicheq:"informix".sc_producto e,
            bdinteg:"informix".si_divisas f,
            intercard:"informix".tarjeta tar,
			bdicheq:"informix".sc_firmantes as firm
      WHERE a.empresa = b.empresa
            AND a.numcte = b.numcte
            AND a.empresa = c.empresa
            AND a.numcte = c.numcte
            AND a.empresa = d.empresa
            AND a.cuenta = d.cuenta
            AND e.empresa = a.empresa
            AND e.producto = a.prodtarjeta
            AND f.empresa = a.empresa
            AND f.divisa = e.divisa
			and (firm.cuenta = a.cuenta)
			and (firm.numcte = a.numcte)
            AND (a.num_tarjeta = tar.numtarjeta)

            AND ((a.empresa=pempresa)
--            AND (a.tipo_tarjeta='T')
            AND (d.status_cta = "1")
            AND (a.numcte=pnumcte))
			AND a.prodtarjeta <> cProdTransfer  order by a.num_tarjeta

     LET s_sistema = 1;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF;

	 IF s_rfc_alterno is not null and s_rfc_alterno <> "" THEN
        LET s_rfc = s_rfc_alterno;
     END IF;	
	 
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

  -- Extrae las Tarjeta de Credito
  FOREACH
SELECT a.num_credito, a.num_tarjeta, a.numcte, a.status_tar,  e.num_producto || " " || e.nombre_prod, f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta, b.rfc_alterno 
       INTO s_cuenta,  s_tarjeta, s_numcte,  s_status, s_producto, s_divisa,
            s_nombre1, s_nombre2, s_paterno, s_materno, s_rfc,
            s_fechanac, s_codstatustarjeta, s_rfc_alterno
       FROM bdicred:"informix".sd_maecred d,
            bdicred:"informix".sd_tarjeta a,
            bdinteg:"informix".si_cliente b,
            bdinteg:"informix".si_ctepf c,
            bdicred:"informix".sd_definicion e,
            bdinteg:"informix".si_divisas f,
            intercard:"informix".tarjeta tar
      WHERE d.numcte=pnumcte
            and d.numcte = b.numcte
            AND d.numcte = c.numcte
            and a.empresa = d.empresa
            and a.num_credito = d.num_credito  
            AND e.empresa = d.empresa
            AND e.num_producto = d.num_producto
            and f.empresa=pempresa
            AND f.divisa = d.divisa
            AND a.num_tarjeta = tar.numtarjeta
            AND d.status_cred <> "FF"
	ORDER BY a.num_tarjeta    

     LET s_sistema = 6;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF

	 IF s_rfc_alterno is not null or s_rfc_alterno <> "" THEN
        LET s_rfc = s_rfc_alterno;
     END IF;	
	 
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

END

END PROCEDURE

DOCUMENT
"Especificacion: Se modifico para que consulte el status de la",
"                tarjeta en la tabla intercard:tarjeta y se regrese como retorno",
"Base de Datos : bdinteg",
"AUTOR : Jesus Manuel Perea Heredia",
"FECHA : 19/Nov/2010",
"Descripcion: Se actualiza a la nueva version de reglas.", 
"Base de Datos : bdinteg",
"Autor : Marcos Cuevas",
"Fecha : 16/Febrero/2011",
'',
'FOLIO: 1611',
'FECHA : 26/06/2014',
'MODIFICO : 94972834',
'MODIFICACION: se modifica para excluir las tarjetas que pertenecen a un producto transfer',
'SUSTENTO: modificaciones_promotoria.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdinteg',
--------------REINGENIERIA-----------
'Descripcion: Se genera un clon del sp "sp_clona_tdc_upgrade" para que este tenga un cod ret de 5 caracteres',
'AUTOR : Efrain MIranda Miranda',
'FECHA : 15/08/2019',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_valida_sms_cte_web( pNumCte CHAR(9))
 RETURNING CHAR(5) as CodRet ,
		   SMALLINT  as valido,
		   CHAR(13) as telefono;

DEFINE cCodret   CHAR(5);
DEFINE iSql_err  INTEGER;
DEFINE iValido   INTEGER;
DEFINE cTel      CHAR(13);

LET cCodret     = '00000';
LET iSql_err    = 0;
LET iValido     = 0;
LET cTel        = '';

BEGIN
	ON EXCEPTION SET iSql_err
		--LET cCodret = CAST(iSql_err AS CHAR);
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret,iValido,cTel;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO '/informix/jesus/sp_valida_sms_cte.sql';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    
	IF (SELECT COUNT(b.numcte)
		FROM bdinteg:"informix".si_telefonos_actual a
		LEFT JOIN bdinteg:"informix".si_bitsmstels b ON a.numcte=b.numcte AND a.telefono=b.telefono AND  b.bandera='t' AND  b.fecha::DATE = TODAY		
		WHERE a.numcte=pNumCte
		AND a.tipo_tel=2 AND a.status_tel='A'
		and fecha = (SELECT max(fecha) from bdinteg:"informix".si_bitsmstels c 
                        where c.numcte=a.numcte AND a.telefono=a.telefono 
                        AND  c.fecha::DATE = TODAY)
		) 
 > 0 THEN		
			LET iValido =1;
		
	END IF 
    
    SELECT  LIMIT 1 telefono
    INTO cTel
    FROM bdinteg:"informix".si_telefonos_actual a
    WHERE a.numcte=pNumCte
    AND a.tipo_tel=2 AND a.status_tel='A';
		
	RETURN cCodret,iValido, cTel;

END;
END PROCEDURE
DOCUMENT
'Autor:	JESUS MANUEL AGUILAR HEREDIA',
'FECHA:	30/SEP/2016',
'DESCRIPCION: se crea procedimiento para ser usado en el flujo de 2 credito.',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_valida_confirmacion_movil_web(pNumCte CHAR(9), pUsuario CHAR(8),pTelefono CHAR(10))
RETURNING CHAR(5) As cCodRet;

--Definicion de Variables 
DEFINE cCodRet			CHAR (5);
DEFINE cBandera         BOOLEAN;
DEFINE iSqlErr          INTEGER;
--Inicializacion de Variables

LET cCodRet      = '00000';
LET cBandera     = 'F';
LET iSqlErr      = 0;

BEGIN	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			let cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/Braulio/sp_valida_confirmacion_movil.out";
	--TRACE ON; 
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pNumCte,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pTelefono,'') <> '' THEN

			SELECT bandera 
			INTO cBandera
			FROM bdinteg:"informix".si_bitsmstels
			WHERE numcte = pNumCte 
			AND telefono = pTelefono 
			AND ejecutivo = pUsuario
			AND fecha IN (SELECT MAX(FECHA) FROM bdinteg:"informix".si_bitsmstels 
						  WHERE numcte = pNumCte
						  AND telefono = pTelefono
						  AND ejecutivo = pUsuario);

			IF dbinfo ("sqlca.sqlerrd2") = 0 then-- No hay informacion
				LET cCodRet = '01289';
				RETURN cCodRet;
			END IF;

			IF cBandera = 'F' THEN
				LET cCodRet = '01386';
			ELIF cBandera = 'T' THEN
				LET cCodRet = '00000';
			END IF;
	ELSE
		LET cCodRet = '00001';
	END IF; 

RETURN cCodRet;
END;
END PROCEDURE;