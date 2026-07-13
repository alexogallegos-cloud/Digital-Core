CREATE PROCEDURE "informix".sp_altactecoppelnuevoparametrico(pEmpresa CHAR(3), pNumCte VARCHAR(20), pNumSolicitud CHAR(20))
RETURNING
CHAR(5),
CHAR(1050); --- Trama conformada

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


SET LOCK MODE TO WAIT 10;
SET ISOLATION TO DIRTY READ;
	
	
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
			
			SELECT numcte_ref, nombre1, NVL(TRIM(nombre2), ''), apell_paterno, NVL(TRIM(apell_materno), '')
			INTO cNumCteRef, cNombreUno, cNombreDos, cApellPat, cApellMat
			FROM bdinteg:"informix".si_cliente
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
				 iOtros, iAndador, iEtapa, iLote, iEdificio, iEntrada, cTelefonoCliente, cTelefono2
			FROM bdinteg:"informix".si_direcciones_actual dir
            LEFT OUTER JOIN si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
            LEFT OUTER JOIN si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
			WHERE dir.numcte = pNumCte
			AND dir.tipo_dir = '1';

			--- EXECUTE PROCEDURE bdinteg:"informix".sp_ConvierteNumerodeCasa(cCasa) INTO cCodRetCasa, cCasa, cLetrasNumCasa;

			IF cCasa = '' THEN
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
			INTO cCasaTrabajo, iNumeroCiudadDeTrabajo, iNumeroColoniaDeTrabajo, iNumeroCalleDeTrabajo, cTelefonoTrabajoCliente, iExtension
			FROM bdinteg:"informix".si_direcciones_actual dir
            LEFT OUTER JOIN si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
			WHERE dir.numcte = pNumCte 
            AND dir.tipo_dir = '2';

			--- EXECUTE PROCEDURE bdinteg:"informix".sp_ConvierteNumerodeCasa(cCasa) INTO cCodRetTrabajo, cCasaTrabajo, cLetrasNumeroTrabajo;

			IF cCasaTrabajo = '' THEN
				LET cCasaTrabajo = '1';
			END IF;

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
			INTO cTelefonoReferencia
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
				situacion_especial, causa_sitesp
			INTO iLineaDeCreditoReal, cDiaFechaLineaDeCreditoReal, cMesFechaLineaDeCreditoReal, cAnioFechaLineaDeCreditoReal,
				cDiaFechaLineaDeCreditoTope, cMesFechaLineaDeCreditoTope, cAnioFechaLineaDeCreditoTope,
				iParCelulares, iParAltoRiesgo, iParPrestamo, iFlagLineaCreditoEsp, iLineaDeCreditoTope, iLimiteDeCredito,
				cSituacionEspecial, iCausaSituacionEspecial
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
			--DSB-11/08/2012
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
			------

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

        END IF;
    END IF;

	RETURN  cCodRet, TRIM(v_Cad1) || "|" || TRIM(v_Cad2) || "|";

END;
--########################################################################################################################
--## Procedimiento       	: sp_altactecoppelnuevoparametrico
--## Base de Datos       	: bdinteg
--## Version				: 1.0
--## Creado por          	: Frank Gaxiola
--## Fecha creacion      	: Febrero de 2012
--## Descripcion          	: Obtiene la informacion del cliente coppel para el envio en línea a Coppel
--## Version				: 1.1
--## Modificado por         : Frank Gaxiola
--## Fecha Modificación		: Agosto de 2012
--## Descripcion          	: Se modifica para que se envie la ciudad y colonia de coppel del catalogo relacionado
--########################################################################################################################
--## Modificado por  : Victor Hugo Nuñez
--## Ultima Modif.   : 21-Agosto-2012 dsb-21/08/2012
--## Descripción     : Se agrega validacion de ROWID para traer solamente un registro; se añade la consulta a 
--## 					tarjetasnumtarcop para obtener la fecha de asignacion de la tarjeta como fecha alta.
--########################################################################################################################
--## Modificado por  : Josue Zepeda
--## Ultima Modif.   : 30-Agosto-2012 DSB-30/08/2012
--## Descripción     : Se agrega REPLACE al campo entre_calles de la tabla si_direcciones_actual, se limita 
--##					iExtension al maximo permitido por small int 32767
--########################################################################################################################
--## Modificado por  : Victor Hugo Nuñez
--## Ultima Modif.   : 07-Noviembre-2012 DSB-07/11/2012
--## Descripción     : Se agrega validacion para enviar la ciudad y colonia de la sucursal en caso de que la ciudad y colonia
--##					del cliente no se encuentren en el catalogo de zonas relacionado
--########################################################################################################################
--## Modificado por  : Ernesto Aguilera
--## Ultima Modif.   : DSB-11/08/2012
--## Descripción     : Se retorna vacios situacion y causa para no enviarse al mensaje 21.
--########################################################################################################################
END PROCEDURE;