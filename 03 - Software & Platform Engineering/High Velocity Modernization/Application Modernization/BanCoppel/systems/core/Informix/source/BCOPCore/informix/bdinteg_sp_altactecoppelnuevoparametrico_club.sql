CREATE PROCEDURE "informix".sp_altactecoppelnuevoparametrico_club(pEmpresa CHAR(3), pNumCte VARCHAR(20), pNumSolicitud CHAR(20))

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
	--DEFINE cNombreUno                      	CHAR(26);
	--DEFINE cNombreDos                      	VARCHAR(26);
	--DEFINE cApellPat                       	CHAR(26);
	--DEFINE cApellMat                       	VARCHAR(26);
	DEFINE cNombreUno                      	CHAR(25);
	DEFINE cNombreDos                      	VARCHAR(25);
	DEFINE cApellPat                       	CHAR(25);
	DEFINE cApellMat                       	VARCHAR(25);
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
	--DEFINE cEntreCalles						VARCHAR(40);
	DEFINE cEntreCalles						VARCHAR(39);
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
	DEFINE v_CadXml1                        LVARCHAR(10000);
	DEFINE v_CadXml2                        LVARCHAR(10000);
	DEFINE v_CadXmlFinal					LVARCHAR(10000);
	DEFINE cSPcodRet						CHAR(06);
	DEFINE cSPcteCplTitular					CHAR(20);
	DEFINE cSPcteCplProspecto				CHAR(20);
	DEFINE p_cod_ret						CHAR(1);

	--DSB-05/03/2015
	DEFINE cTelefono2Temp                   VARCHAR(13);
	DEFINE cTelefonoUnoTrabajoTemp          VARCHAR(13);
	DEFINE cTelefonoClienteTemp				VARCHAR(13);
	DEFINE cTelefonoTrabajoClienteTemp		VARCHAR(13);
	DEFINE cTelefonoReferenciaTemp			VARCHAR(13);
	--DSB-14082017
	DEFINE iPrepuntajeAltoRiesgo             INTEGER; /* nuevos campos 11/08/2017 */
	DEFINE iPuntosParcn						SMALLINT;
	DEFINE iPuntajeFinalParamcn				SMALLINT; /*fin  */
	
	--598 INICIO
	DEFINE cCanal_OrigenSol					CHAR(1);
	DEFINE cGrupo_Eval						CHAR(1);
	DEFINE cGrupo_Hit						CHAR(1);
	--598 FIN
	
		-- CAMBIAR Ã POR #
	DEFINE tmp_v_Cad1						LVARCHAR(525);
	DEFINE tmp_v_Cad2                       LVARCHAR(525);
	DEFINE tmp_cSPcteCplProspecto			CHAR(20);
	DEFINE tmp_cCanal_OrigenSol				CHAR(1);
	DEFINE tmp_cGrupo_Eval					CHAR(1);
	DEFINE tmp_cGrupo_Hit					CHAR(1);
	
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
	LET cTelefono = '0';
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
	LET iCiudadTiendaMov = 0;
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
	LET v_CadXml1 = '';
	LET v_CadXml2 = '';
	LET v_CadXmlFinal = '';
	LET iLineaDeCreditoTope = 0;
	LET ivalor		 	= 0;
	LET p_cod_ret = '';

	--DSB-05/03/2015
	LET cTelefono2Temp = '0';
	LET cTelefonoClienteTemp = '0';
	LET cTelefonoTrabajoClienteTemp = '0';
	LET cTelefonoReferenciaTemp = '0';

	--DSB-14082017
	LET iPrepuntajeAltoRiesgo=0;   /* nuevos campos 11/08/2017 */
	lET iPuntosParcn=0;
	LET iPuntajeFinalParamcn=0;    /* fin */
	
	--598 INICIO
	LET pNumSolicitud				= TRIM(NVL(pNumSolicitud,''));	
	LET cCanal_OrigenSol			= ''; 	
	LET cGrupo_Eval					= ''; 	
	LET cGrupo_Hit					= ''; 	
	--598 FIN
	
	LET tmp_v_Cad1					= '';
	LET tmp_v_Cad2                  = '';
	LET tmp_cSPcteCplProspecto		= '';
	LET tmp_cCanal_OrigenSol		= '';
	LET tmp_cGrupo_Eval	 		    = '';
	LET tmp_cGrupo_Hit				= '';						 


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;   --SE CAMBIA DE WAIT 10 A WAIT 3 INC25112021

	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr, cDesErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet, NULL;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/sp_altactecoppelnuevoparametrico_club.out';
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

				SELECT NVL(TRIM(dir.numeroextcalle), ''), dir.numerociudad, dir.numerocolonia, 
					NVL(TRIM(REPLACE(dir.entre_calles,'|',' ')), ''), dir.numerocalle, 
					NVL(TRIM(dir.puntocardinal), ''), NVL(TRIM(REPLACE(dir.observaciones,'|',' ')), ''),
					DECODE(dir.unidadhabitac,'S',1,'1',1,'N',0,'0',0,0),
					dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote, dir.edificio, dir.entrada,
					NVL(TRIM(tel1.telefono), ''), NVL(TRIM(tel2.telefono), '')
				INTO cCasa, iNumeroCiudad, iNumeroColonia, cEntreCalles, iNumeroCalle, cRumbo, cObservaciones, iFlagUH, iManzana,
					 --iOtros, iAndador, iEtapa, iLote, iEdificio, iEntrada, cTelefonoCliente, cTelefono2
					 iOtros, iAndador, iEtapa, iLote, iEdificio, iEntrada, cTelefonoClienteTemp, cTelefono2Temp
				FROM bdinteg:"informix".si_direcciones_actual dir
				LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
				LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
				WHERE dir.numcte = pNumCte
				AND dir.tipo_dir = '1';


				--DSB EA  09/10/2020
				LET cObservaciones = TRIM(pNumSolicitud);
				
				--IF NVL(cCasa,'') = '' OR cCasa = '0' THEN
					--LET cCasa = '1';
				--END IF;

				SELECT NVL(TRIM(dir.numeroextcalle), ''), dir.numerociudad, dir.numerocolonia, dir.numerocalle, 
					   NVL(TRIM(tel3.telefono), ''), tel3.extension
				--INTO cCasaTrabajo, iNumeroCiudadDeTrabajo, iNumeroColoniaDeTrabajo, iNumeroCalleDeTrabajo, cTelefonoTrabajoCliente, iExtension
				INTO cCasaTrabajo, iNumeroCiudadDeTrabajo, iNumeroColoniaDeTrabajo, iNumeroCalleDeTrabajo, cTelefonoTrabajoClienteTemp, iExtension
				FROM bdinteg:"informix".si_direcciones_actual dir
				LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
				WHERE dir.numcte = pNumCte 
				AND dir.tipo_dir = '2';

				--DSB-09/03/2015
				/*IF NVL(cCasaTrabajo,'') = '' OR cCasaTrabajo = '0' THEN
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
				INTO cTelefonoReferenciaTemp
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

			    --CAMBIO
				/*SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)}TRIM(cve_ciudad),TRIM(cve_estado) 
				INTO cCiudadSucursal, cEstadoSucursal
				FROM bdinteg:"informix".si_ptf 
				WHERE id_ptf = cSucursal AND tipo='S';*/
				
				SELECT FIRST 1 {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)}TRIM(cve_ciudad),TRIM(cve_estado) 
				INTO cCiudadSucursal, cEstadoSucursal
				FROM bdinteg:"informix".si_ptf 
				WHERE id_ptf = cSucursal AND (tipo='X' OR tipo='S'); --INC27092021 Se agrega tipo X a la consulta ya que hay veces donde no existe la sucursal
																					--con el filtro tipo S
				
				--FIN CAMBIO			
				SELECT FIRST 1 ciudad_coppel
				INTO iCiudadTiendaMov
				FROM bdinteg:"informix".si_ciudades
                WHERE ciudad = cCiudadSucursal AND estado = cEstadoSucursal and ciudad_coppel <> 0;

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
				
				/*       SE COMENTA BLOQUE PARA TOMAR DE MEJOR MANERA LA OBTENCION DE CIUDAD Y COLONIA COPPEL
				--dsb-07/11/2012
				IF NVL(iColoniaCoppel,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN "informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO iColoniaCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal;
				END IF;
				--Cambio INC27092021
				--Se homologa las dos validaciones de el sp sp_consultageneralescte_club debido a que la colonia se tomaba en 0 en algunas situaciones
				IF NVL(iColoniaCoppel,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO iColoniaCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal and numerocoloniacoppel <> 0;
				END IF;

				IF NVL(iColoniaCoppel,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO iColoniaCoppel FROM bdinteg:"informix".si_catzonas WHERE numerocoloniacoppel <> 0;
				END IF;   
				--Fin Cambio INC27092021
				IF NVL(iCiudadCoppel,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN "informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
					INTO iCiudadCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal;
				END IF;
				--INC27092021
				--Cambio Se homologa las dos validaciones de el sp sp_consultageneralescte_club debido a que la Ciudad se tomaba en 0 en algunas situaciones
				IF NVL(iCiudadCoppel,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
					INTO iCiudadCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal and numerociudadcoppel <> 0;
				END IF;

				IF NVL(iCiudadCoppel,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
					INTO iCiudadCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudadcoppel <> 0;
				END IF;
				--Fin Cambio INC27092021*/
				
				--INC18102021						
				------------------------------------------------------------------------------------------------------------
				-- SI NO EXISTE CIUDAD O COLONIA COPPEL RELACIONADAS SE OBTIENEN DE LA SUCURSAL DONDE SE DIO DE ALTA EL CLIENTE
				------------------------------------------------------------------------------------------------------------
					IF NVL(iCiudadCoppel,0) = 0 OR NVL(iColoniaCoppel,0) = 0 THEN
						
						IF NVL(cCiudadSucursal,0) <> 0 THEN
							SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
										   CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
							INTO iCiudadCoppel, iColoniaCoppel
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudad = cCiudadSucursal;
						END IF;

						-----------------------------------------------------------------------------------------------
						-- SI NO EXISTE CIUDAD O COLONIA COPPEL RELACIONADAS SE TOMARA EL PRIMER REGISTRO DEL CATALOGO
						-----------------------------------------------------------------------------------------------
						IF NVL(iCiudadCoppel,0) = 0 OR NVL(iColoniaCoppel,0) = 0 THEN
							SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
										   CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
							INTO iCiudadCoppel, iColoniaCoppel
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL
							AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
						END IF;

					END IF;
				-- CIB-18/10/2021 	"SE AGREGA MODIFICACION"  TERMINA --INC18102021
				
				IF NVL(iColoniaCoppelTrabajo,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN "informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO iColoniaCoppelTrabajo FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal;
				END IF;
				
				IF NVL(iCiudadCoppelTrabajo,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN "informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
					INTO iCiudadCoppelTrabajo FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal;
				END IF;
				
				--dsb-21/08/2012
				SELECT lineacredito_real, DAY(fechalineacreditoreal), MONTH(fechalineacreditoreal), YEAR(fechalineacreditoreal),
					DAY(fechalineacreditotope), MONTH(fechalineacreditotope), YEAR(fechalineacreditotope),
					par_celulares, par_altoriesgo, par_prestamos, flaglineacreditoesp, lineacreditotope, limitecredito,
					situacion_especial, causa_sitesp, prepuntajealtoriesgo, puntos_parcn, nuevo_puntajefinal,     --DSB-14082017
					canal_origensol,grupo_eval,grupo_hit --598
				INTO iLineaDeCreditoReal, cDiaFechaLineaDeCreditoReal, cMesFechaLineaDeCreditoReal, cAnioFechaLineaDeCreditoReal,
					cDiaFechaLineaDeCreditoTope, cMesFechaLineaDeCreditoTope, cAnioFechaLineaDeCreditoTope,
					iParCelulares, iParAltoRiesgo, iParPrestamo, iFlagLineaCreditoEsp, iLineaDeCreditoTope, iLimiteDeCredito,
					cSituacionEspecial, iCausaSituacionEspecial, iPrepuntajeAltoRiesgo, iPuntosParcn, iPuntajeFinalParamcn,   --DSB-14082017
					cCanal_OrigenSol,cGrupo_Eval,cGrupo_Hit --598
				FROM bdisolic:"informix".ss_nuevo_parametrico
				WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud
				AND ROWID = (SELECT MAX(ROWID) FROM bdisolic:"informix".ss_nuevo_parametrico
				WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud);

				IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud) >= 1 THEN
					SELECT situacionespecial,causa INTO cSituacionEspecial,iCausaSituacionEspecial FROM bdisolic:"informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud;
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
				
				
				--DSB-16/02/2015 05/03/2015
				--Validaciones extras a los campos para eliminar caracteres extraÃÂ±so
				EXECUTE PROCEDURE sp_alfanumerico (cCasa) INTO cCasa;
				EXECUTE PROCEDURE sp_alfanumerico (cEntreCalles) INTO cEntreCalles;
				EXECUTE PROCEDURE sp_alfanumerico (cObservaciones) INTO cObservaciones;
				EXECUTE PROCEDURE sp_alfanumerico (cTelefonoClienteTemp) INTO cTelefonoCliente;
				EXECUTE PROCEDURE sp_alfanumerico (cTelefono2Temp) INTO cTelefono2;
				EXECUTE PROCEDURE sp_alfanumerico (cCasaTrabajo) INTO cCasaTrabajo;
				EXECUTE PROCEDURE sp_alfanumerico (cTelefonoTrabajoClienteTemp) INTO cTelefonoTrabajoCliente;
				EXECUTE PROCEDURE sp_alfanumerico (cTelefonoReferenciaTemp) INTO cTelefonoReferencia;
				
				EXECUTE PROCEDURE "informix".sp_esnumerico (cCasa)
				INTO p_cod_ret;
				
				IF p_cod_ret = 'F' OR (cCasa::INT) = 0 THEN
					LET cCasa = '1';
				END IF;
				
				EXECUTE PROCEDURE "informix".sp_esnumerico (cCasaTrabajo)
				INTO p_cod_ret;
				
				IF p_cod_ret = 'F' OR (cCasaTrabajo::INT) = 0 THEN
					LET cCasaTrabajo = '1';
				END IF;
						
				LET cCasa = TRIM(cCasa);
				LET cEntreCalles = TRIM(cEntreCalles);
				LET cObservaciones = TRIM(cObservaciones);
				LET cTelefonoCliente = TRIM(cTelefonoCliente);
				LET cTelefono2 = TRIM(cTelefono2);
				LET cCasaTrabajo = TRIM(cCasaTrabajo);
				LET cTelefonoTrabajoCliente = TRIM(cTelefonoTrabajoCliente);
				LET cTelefonoReferencia = TRIM(cTelefonoReferencia);
				
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
				
				--598 INFORMACION NECESARI PARA EL ENVIO AL PARAMETRICO
				LET cCanal_OrigenSol = TRIM(NVL(cCanal_OrigenSol,'0'));
				LET cGrupo_Eval	= TRIM(NVL(cGrupo_Eval,'0'));
				LET cGrupo_Hit = TRIM(NVL(cGrupo_Hit,'0'));

				--598.1 VALIDAR QUE SI LOS PARAMETROS VIENEN VACIOS GUARDARLOS EN 0
				IF cCanal_OrigenSol = ' ' THEN
					LET cCanal_OrigenSol = '0';
				END IF;
				IF cGrupo_Eval = ' ' THEN
					LET cGrupo_Eval = '0';
				END IF;
				IF cGrupo_Hit = ' ' THEN
					LET cGrupo_Hit = '0';
				END IF;
				
				IF LENGTH(TRIM(cDiaNac))  = 1 THEN
						LET cDiaNac = '0' || cDiaNac;
					END IF;
					IF LENGTH(TRIM(cMesNac))  = 1 THEN
						LET cMesNac = '0' || cMesNac;
					END IF;
					IF LENGTH(TRIM(cAnioNac))  = 1 THEN
						LET cAnioNac = '0' || cAnioNac;
					END IF;
					
					IF LENGTH(TRIM(cDiaAltaCliente)) = 1 THEN
						LET cDiaAltaCliente = '0' || cDiaAltaCliente;
					END IF
					IF LENGTH(TRIM(cMesAltaCliente)) = 1 THEN
						LET cMesAltaCliente = '0' || cMesAltaCliente;
					END IF
					IF LENGTH(TRIM(cYearAltaCliente)) = 1 THEN
						LET cYearAltaCliente = '0' || cYearAltaCliente;
					END IF
					
					IF LENGTH(TRIM(cAnioFechaLineaDeCreditoReal)) = 1 THEN
						LET cAnioFechaLineaDeCreditoReal = '0' || cAnioFechaLineaDeCreditoReal;
					END IF
					IF LENGTH(TRIM(cMesFechaLineaDeCreditoReal)) = 1 THEN
						LET cMesFechaLineaDeCreditoReal = '0' || cMesFechaLineaDeCreditoReal;
					END IF
					IF LENGTH(TRIM(cDiaFechaLineaDeCreditoReal)) = 1 THEN
						LET cDiaFechaLineaDeCreditoReal = '0' || cDiaFechaLineaDeCreditoReal;
					END IF
					
					IF LENGTH(TRIM(cAnioFechaLineaDeCreditoTope)) = 1 THEN
						LET cAnioFechaLineaDeCreditoTope = '0' || cAnioFechaLineaDeCreditoTope;
					END IF
					IF LENGTH(TRIM(cMesFechaLineaDeCreditoTope)) = 1 THEN
						LET cMesFechaLineaDeCreditoTope = '0' || cMesFechaLineaDeCreditoTope;
					END IF
					IF LENGTH(TRIM(cDiaFechaLineaDeCreditoTope)) = 1 THEN
						LET cDiaFechaLineaDeCreditoTope = '0' || cDiaFechaLineaDeCreditoTope;
					END IF
					
					
					LET v_Cad1 = TRIM(cNumCteRef) ||"|"|| TRIM(cNombreUno) ||"|"|| cNombreDos ||"|"|| TRIM(cApellPat)
						||"|"|| cApellMat ||"|"|| TRIM(cSexo) ||"|"|| TRIM(cAnioNac) || TRIM(cMesNac) || TRIM(cDiaNac)
						||"|"|| TRIM(cEdoCivil) ||"|"|| iCiudadCoppel ||"|"|| iColoniaCoppel ||"|"|| iNumeroCalle ||"|"|| cCasa
						||"|"|| cRumbo ||"|"|| cObservaciones ||"|"|| cEntreCalles ||"|"|| iFlagUH ||"|"|| iManzana ||"|"|| iOtros
						||"|"|| iAndador ||"|"|| iEtapa ||"|"|| iLote ||"|"|| iEdificio ||"|"|| iEntrada 
						||"|"|| DECODE(cLetrasNumCasa,'',' ',cLetrasNumCasa) ||"|"|| TRIM(cTelefono) ||"|"|| TRIM(cTelefono2)
						||"|"|| cHabitaEn ||"|"|| cSituacionEspecial ||"|"|| iCausaSituacionEspecial ||"|"|| cPuntualidad 
						||"|"|| iIngresoMensual ||"|"|| iLimiteDeCredito ||"|"|| iReposicionTarjeta ||"|"|| iFlagclienteAnexo
						||"|"|| iFlagCobxTel ||"|"|| iFlagDescuentoEspecial ||"|"|| iFlagActualizarDatos ||"|"|| iFlagHuella
						||"|"|| iMesesTranscurridos ||"|"|| cLugarDeTrabajo ||"|"|| iCiudadCoppelTrabajo;
						
					LET v_CadXml1 = "<cNumCliente>" || TRIM(cNumCteRef) ||
					"</cNumCliente><cNombre1>" ||
					TRIM(cNombreUno) || "</cNombre1><cNombre2>" || 
						cNombreDos || "</cNombre2><cApellidoPaterno>" || 
						TRIM(cApellPat)||"</cApellidoPaterno><cApellidoMaterno>" || 
						cApellMat ||"</cApellidoMaterno><cSexo>" || 
						TRIM(cSexo) ||"</cSexo><cFechaNacimiento>" || 
						TRIM(cAnioNac) || TRIM(cMesNac) ||TRIM(cDiaNac) ||"</cFechaNacimiento><cEstadoCivil>" || 
						TRIM(cEdoCivil) ||"</cEstadoCivil><iCiudad>" || 
						iCiudadCoppel || "</iCiudad><iColonia>" || 
						iColoniaCoppel || "</iColonia><iCalle>" || 
						iNumeroCalle ||"</iCalle><iCasa>" || 
						cCasa || "</iCasa><cRumbo>" || 
						cRumbo || "</cRumbo><cObservaciones>" || 
						cObservaciones || "</cObservaciones><cEntrecalle>"|| 
						cEntreCalles || "</cEntrecalle><shFlagUhc>"|| 
						iFlagUH ||"</shFlagUhc><shUhcManzana>"|| 
						iManzana ||"</shUhcManzana><shUhcOtros>"|| 
						iOtros||"</shUhcOtros><shUhcAndador>"|| 
						iAndador ||"</shUhcAndador><shUhcEtapa>"|| 
						iEtapa ||"</shUhcEtapa><shUhcLote>"|| 
						iLote ||"</shUhcLote><shUhcEdificio>"|| 
						iEdificio ||"</shUhcEdificio><shUhcEntrada>"|| 
						iEntrada ||"</shUhcEntrada><cNumDeptoInterior>"|| 
						DECODE(cLetrasNumCasa,'',' ',cLetrasNumCasa) ||"</cNumDeptoInterior><lTelefono>"|| 
						TRIM(cTelefono) ||"</lTelefono><lTelefonoCelular>"|| 
						TRIM(cTelefono2)||"</lTelefonoCelular><cCasaPref>"|| 
						cHabitaEn ||"</cCasaPref><cSituacionEspecial>"|| 
						cSituacionEspecial ||"</cSituacionEspecial><cCausasItesp>"|| 
						iCausaSituacionEspecial ||"</cCausasItesp><cPuntualidad>"|| 
						cPuntualidad ||"</cPuntualidad><iIngresoMensual>"|| 
						iIngresoMensual ||"</iIngresoMensual><iLimiteCredito>"|| 
						iLimiteDeCredito ||"</iLimiteCredito><iReposicionTarjeta>"|| 
						iReposicionTarjeta ||"</iReposicionTarjeta><shFlagClienteCNexo>"|| 
						iFlagclienteAnexo||"</shFlagClienteCNexo><shFlagCobXtel>"|| 
						iFlagCobxTel ||"</shFlagCobXtel><shFlagDescuentoEspecial>"|| 
						iFlagDescuentoEspecial ||"</shFlagDescuentoEspecial><shFlagActualizarDatos>"|| 
						iFlagActualizarDatos ||"</shFlagActualizarDatos><shFlagHuella>"|| 
						iFlagHuella	||"</shFlagHuella><shMesesTranscurridos>"|| 
						iMesesTranscurridos ||"</shMesesTranscurridos><cLugarTrabajo>"|| 
						cLugarDeTrabajo ||"</cLugarTrabajo><iCiudadTrabajo>"|| 
						iCiudadCoppelTrabajo || "</iCiudadTrabajo>";

					LET v_Cad2 = iColoniaCoppelTrabajo ||"|"|| iNumeroCalleDeTrabajo ||"|"|| cCasaTrabajo 
						||"|"|| DECODE(cLetrasNumeroTrabajo,'',' ',cLetrasNumeroTrabajo)
						||"|"|| TRIM(cTelefonoUnoTrabajo) ||"|"|| iExtension ||"|"|| iNipTitular ||"|"|| iNipAdicional1 
						||"|"|| iNipAdicional2  ||"|"|| TRIM(cNombreUnoRef) ||"|"|| cNombreDosRef ||"|"|| TRIM(cApellUnoReferencia) 
						||"|"|| cApellDosReferencia ||"|"|| TRIM(cTelefonoRef)
						||"|"|| TRIM(cYearAltaCliente) || TRIM(cMesAltaCliente) || TRIM(cDiaAltaCliente) 
						||"|"|| iGrupoSemaforoCN ||"|"|| iStatusAfore ||"|"|| iParametricosCelulares ||"|"|| cSubPuntualidad 
						||"|"|| iLineaDeCreditoTope ||"|"|| iLineaDeCreditoReal
						||"|"|| TRIM(cAnioFechaLineaDeCreditoReal) || TRIM(cMesFechaLineaDeCreditoReal) || TRIM(cDiaFechaLineaDeCreditoReal)
						||"|"|| TRIM(cAnioFechaLineaDeCreditoTope) || TRIM(cMesFechaLineaDeCreditoTope) || TRIM(cDiaFechaLineaDeCreditoTope)
						||"|"|| iNivelLineaCreditoReal ||"|"|| iNivelLineaCreditoTope
						||"|"|| TRIM(cTelefonoCliente) ||"|"|| TRIM(cTelefonoTrabajoCliente) ||"|"|| TRIM(cTelefonoReferencia)
						||"|"|| iParCelulares ||"|"|| cModeloCelulares ||"|"|| iParAltoRiesgo ||"|"|| iParPrestamo 
						||"|"|| iPedirTelefono ||"|"|| iFlagLineaCreditoEsp ||"|"|| cClave ||"|"|| cTipoMovto ||"|"|| cSucursal 
						||"|"|| iCaja ||"|"|| cEmpleadoEfectuo ||"|"|| iCiudadTiendaMov ||"|"|| cArea;
						
					LET v_CadXml2 = "<iColoniaTrabajo>" ||
						iColoniaCoppelTrabajo ||"</iColoniaTrabajo><iCalleTrabajo>"|| 
						iNumeroCalleDeTrabajo ||"</iCalleTrabajo><iCasaTrabajo>"|| 
						cCasaTrabajo ||"</iCasaTrabajo><cNumDeptoInteriorTrab>"|| 
						DECODE(cLetrasNumeroTrabajo,'',' ',cLetrasNumeroTrabajo)||"</cNumDeptoInteriorTrab><lTelefonoTrabajo>"|| 
						TRIM(cTelefonoUnoTrabajo) ||"</lTelefonoTrabajo><iExtension>"|| 
						iExtension ||"</iExtension><iNipTitular>"|| 
						iNipTitular ||"</iNipTitular><iNipAdicional1>"|| 
						iNipAdicional1 	||"</iNipAdicional1><iNipAdicional2>"|| 
						iNipAdicional2  ||"</iNipAdicional2><cNombre1Referencia>"|| 
						TRIM(cNombreUnoRef) ||"</cNombre1Referencia><cNombre2Referencia>"|| 
						cNombreDosRef ||"</cNombre2Referencia><cApellidoPaternoReferencia>"|| 
						TRIM(cApellUnoReferencia) ||"</cApellidoPaternoReferencia><cApellidoMaternoReferencia>"|| 
						cApellDosReferencia ||"</cApellidoMaternoReferencia><lTelefonoReferencia>"|| 
						TRIM(cTelefonoRef)	||"</lTelefonoReferencia><cFechaAltaCliente>"|| 
						TRIM(cYearAltaCliente) || TRIM(cMesAltaCliente) || TRIM(cDiaAltaCliente) ||"</cFechaAltaCliente><iGruposEmaforocn>"|| 
						iGrupoSemaforoCN ||"</iGruposEmaforocn><shStatusAfore>"|| 
						iStatusAfore ||"</shStatusAfore><iParametricoCelulares>"|| 
						iParametricosCelulares ||"</iParametricoCelulares><cSubPuntualidad>"|| 
						cSubPuntualidad ||"</cSubPuntualidad><iLineaDeCreditoTope>"|| 
						iLineaDeCreditoTope ||"</iLineaDeCreditoTope><iLineaDeCreditoReal>"|| 
						iLineaDeCreditoReal	||"</iLineaDeCreditoReal><cFechaLineaDeCreditoReal>"|| 	
						TRIM(cAnioFechaLineaDeCreditoReal) || TRIM(cMesFechaLineaDeCreditoReal) || TRIM(cDiaFechaLineaDeCreditoReal)||"</cFechaLineaDeCreditoReal><cFechaLineaDeCreditoTope>"|| 
						TRIM(cAnioFechaLineaDeCreditoTope) || TRIM(cMesFechaLineaDeCreditoTope) || TRIM(cDiaFechaLineaDeCreditoTope)||"</cFechaLineaDeCreditoTope><shNivelLineaCreditoReal>"|| 
						iNivelLineaCreditoReal ||"</shNivelLineaCreditoReal><shNivelLineaCreditoTope>"|| 
						iNivelLineaCreditoTope ||"</shNivelLineaCreditoTope><lTelefonoCliente>"|| 
						TRIM(cTelefonoCliente) ||"</lTelefonoCliente><lTelefonoTrabajoCliente>"|| 
						TRIM(cTelefonoTrabajoCliente) ||"</lTelefonoTrabajoCliente><lTelReferencia>"|| 
						TRIM(cTelefonoReferencia)     ||"</lTelReferencia><shParCelulares>"|| 
						iParCelulares ||"</shParCelulares><cModeloCelulares>"|| 
						cModeloCelulares ||"</cModeloCelulares><shParAltoRiesgo>"|| 
						iParAltoRiesgo ||"</shParAltoRiesgo><shParPrestamo>"|| 
						iParPrestamo   ||"</shParPrestamo><shPedirTelefono>"|| 
						iPedirTelefono ||"</shPedirTelefono><shFlagLineaCreditoEsp>"|| 
						iFlagLineaCreditoEsp ||"</shFlagLineaCreditoEsp><cClave>"|| 
						cClave ||"</cClave><cTipoMovto>"|| 
						cTipoMovto ||"</cTipoMovto><shTienda>"|| 
						cSucursal  ||"</shTienda><shCaja>"|| 
						iCaja ||"</shCaja><iEmpleadoEfectuo>"|| 					
						cEmpleadoEfectuo ||"</iEmpleadoEfectuo><shCiudadTienda>"|| 
						iCiudadTiendaMov ||"</shCiudadTienda><cArea>"|| cArea ||"</cArea>";
						
						EXECUTE PROCEDURE "informix".sp_obtienecteprospecto_club(pEmpresa, pNumCte)
						INTO cSPcodRet, cSPcteCplTitular, cSPcteCplProspecto;
						IF NVL(TRIM(cSPcodRet), '') = '' OR cSPcodRet <> '000000' THEN
							LET cSPcteCplProspecto = '0';
						END IF;
						
					
					
				END IF;
		END IF;
		---  metodo para reemplazar la Ã en #
		EXECUTE PROCEDURE sp_remplaza_n(v_Cad1) INTO tmp_v_Cad1;
		EXECUTE PROCEDURE sp_remplaza_n(v_Cad2) INTO tmp_v_Cad2;
		EXECUTE PROCEDURE sp_remplaza_n(cSPcteCplProspecto) INTO tmp_cSPcteCplProspecto;
		EXECUTE PROCEDURE sp_remplaza_n(cCanal_OrigenSol) INTO tmp_cCanal_OrigenSol;
		EXECUTE PROCEDURE sp_remplaza_n(cGrupo_Eval) INTO tmp_cGrupo_Eval;
		EXECUTE PROCEDURE sp_remplaza_n(cGrupo_Hit) INTO tmp_cGrupo_Hit;
		

/* 		RETURN  cCodRet, TRIM(v_Cad1) || "|" || TRIM(v_Cad2) || "|" || TRIM(cSPcteCplProspecto) || "|" || iPrepuntajeAltoRiesgo|| "|" || iPuntosParcn || "|" || iPuntajeFinalParamcn  --DSB-14082017
				|| "|" || TRIM(cCanal_OrigenSol) || "|" || TRIM(cGrupo_Eval) || "|" || TRIM(cGrupo_Hit) || "|" ; --598 */
		
		LET v_CadXmlFinal = v_CadXml1 || v_CadXml2 || "<lClienteProspecto>" || TRIM(tmp_cSPcteCplProspecto) || "</lClienteProspecto><prepuntajeAltoRiesgo>" || iPrepuntajeAltoRiesgo|| "</prepuntajeAltoRiesgo><puntosParCn>" || iPuntosParcn || "</puntosParCn><puntajeFinalParamCn>" || iPuntajeFinalParamcn  --DSB-14082017
				|| "</puntajeFinalParamCn><canalOrigenSol>" || TRIM(tmp_cCanal_OrigenSol) || "</canalOrigenSol><grupoEval>" || TRIM(tmp_cGrupo_Eval) || "</grupoEval><grupoHit>" || TRIM(tmp_cGrupo_Hit) || "</grupoHit>";
		
		INSERT INTO "informix".clientes_coppel_envia_xml(numcte_coppel,xml,fecha_hora) VALUES(cNumCteRef,v_CadXmlFinal,CURRENT);
		
		
		RETURN  cCodRet, TRIM(tmp_v_Cad1) || "|" || TRIM(tmp_v_Cad2) || "|" || TRIM(tmp_cSPcteCplProspecto) || "|" || iPrepuntajeAltoRiesgo|| "|" || iPuntosParcn || "|" || iPuntajeFinalParamcn  --DSB-14082017
				|| "|" || TRIM(tmp_cCanal_OrigenSol) || "|" || TRIM(tmp_cGrupo_Eval) || "|" || TRIM(tmp_cGrupo_Hit) || "|" ; --598
		

	END;
END PROCEDURE

DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - JosÃÂ© Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'DescripciÃÂ³n:	Se crea clon de sp_altactecoppelnuevoparametrico.sql y se le modificÃÂ³ para que regresarÃÂ¡ el nÃÂºmero de cliente prospecto coppel',
'Folio:			1560',
'Autor: 		94379114 - Victor Hugo NuÃÂ±ez',
'Fecha: 		16/02/2015',
'Sustento:		(Re_ minuta reuniÃÂ³n Alta de Clientes y Seguro Club).pdf',
'Solicita		Rodolfo Gomez',
'DescripciÃÂ³n:	Se aÃÂ±aden validaciones por caracteres que son prohibidos para un servicio web',
'se modifican campos que son identicos a su estructura del mensaje para no provocar desbordes',
'BD: 			bdinteg',
'*****************************************************************************************************************************************',
'Autor:			97982571 - Jesus A. Alvarado',
'Etiqueta: 		--DSB-14082017',
'Solicita		Abraham Narvaez',
'Descripcion:	retorna nuevos campo iPrepuntajeAltoRiesgo,iPuntosParcn,iPuntajeFinalParamcn',
'BD: 			bdinteg',
'Folio:			292',
'*****************************************************************************************************************************************',
'PROYECTO: PeticiÃÂ³n 598.1 - RQM 09 488-3 IMPLEMENTACIÃ?N - ADENDUM - HomologaciÃÂ³n de Clientes BanCoppel - Coppel en alta ÃÂºnica (Mensaje PP y % inicial de pago)',
'DESCRIPCION: SE AGREGA VALIDACIONES PARA SELECCIONAR LA INFORMACION QUE RECIBIO PREVIAMENTE EN EL PROCESO DE EVALUACION DE LA SOLICITUD TDC COPPEL',
'AUTOR: ISARAI BOJORQUEZ',
'BD: BDINTEG',
'FECHA: 09/08/2019',
'SOLICITA:ABRAHAM NARVAEZ',
'*****************************************************************************************************************************************',
'PROYECTO: Envio de numero de solicitud en el alta de cliente coppel en linea',
'DESCRIPCION: Se reutiliza la variable observaciones para que se mande ahora el numero de solicitud del cliente',
'AUTOR: 95281495 - Ernesto Aguilera',
'BD: BDINTEG',
'FECHA: 09/10/2020',
'SOLICITA: Abraham Narvaez',
'*****************************************************************************************************************************************',
'PROYECTO: INC_CIUDAD_COLONIA_CERO_16',
'FOLIO: 1982',
'DESCRIPCION: Se homologan dos sps sp_consultageneralescte_club y sp_altactecoppelnuevoparametrico_club para la obtencion de la Ciudad y colonia',
' Y una modificacion en el where (tipo="X" OR tipo="S") ya que no se esta llenando ese valor por que no existen en algunos casos sucursales con tipo S',
'AUTOR: 98467379 - Hector aguilar',
'ETIQUETA: INC27092021',
'BD: BDINTEG',
'FECHA: 27/09/2021',
'SOLICITA: Fabiola Martinez Mozo Y Federico Magdaleno',
'*****************************************************************************************************************************************',
'PROYECTO: INC_HOMOLOGACION_CIUDAD/COLONIA_16',
'FOLIO: 1985',
'DESCRIPCION: Se homologan tres sps sp_envioparametricocoppel_cteprosp, sp_consultageneralescte_club y sp_altactecoppelnuevoparametrico_club para la obtencion de la Ciudad y colonia',
'AUTOR: 98467379 - Hector aguilar',
'ETIQUETA: INC18102021',
'BD: BDINTEG',
'FECHA: 18/10/2021',
'SOLICITA: Fabiola Martinez Mozo Y Federico Magdaleno',
'*****************************************************************************************************************************************',
'PROYECTO: INC_HOM_INDEX_CIUDAD_COLONIA_14_16',
'FOLIO: 1988',
'DESCRIPCION: Se agregan indices para bajar los costos y se modifica SET LOCK MODE TO WAIT 10 a SET LOCK MODE TO WAIT 3 por peticion de el cliente',
'AUTOR: 98467379 - Hector aguilar',
'ETIQUETA: INC25112021',
'BD: BDINTEG',
'FECHA: 25/11/2021',
'SOLICITA: Fabiola Martinez Mozo Y Federico Magdaleno',
'*****************************************************************************************************************************************';

CREATE PROCEDURE "informix".sp_actstatusctecopnvoparam_club()

	RETURNING
		CHAR(5);

	--- DECLARACIONES
	DEFINE cCodRet 							CHAR(5);
	DEFINE iSqlErr                          INTEGER;
	DEFINE cnumcte_coppel                   CHAR(20);
	DEFINE ctrama 							LVARCHAR(10000);	
	DEFINE vsRepositorio  					CHAR(200);
    DEFINE vsNomArchivo 					CHAR (50);
    DEFINE vsNomArchivoF 					CHAR (50);
	DEFINE cNombre							CHAR (50);
    DEFINE vsSQL 							CHAR (1050) ;
    DEFINE vsSQL1 							CHAR (150);
    DEFINE vsSQL2 							CHAR (750) ;
    DEFINE vsSQL3 							CHAR (150) ;
    DEFINE vsFlagSystem 					CHAR (1);
	DEFINE cHora							CHAR (2);
	DEFINE cMin								CHAR (2);
	DEFINE csec								CHAR (2);
	DEFINE dhoraActual 						CHAR (8);	
	
	--- INICIALIZACIONES
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cnumcte_coppel = '';
	LET ctrama = '';
	LET vsRepositorio = '';
	LET vsNomArchivo = '';
	LET vsNomArchivoF = '';	
	LET cNombre ='';
    LET vsSQL = '' ;
    LET vsSQL1 = '' ;
    LET vsSQL2 = '' ;
    LET vsSQL3 = '' ;
    LET vsFlagSystem = '';	
	LET cHora = '';	
	LET cMin = '';	
	LET csec = '';	
	LET dhoraActual = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  

    BEGIN

    ON EXCEPTION SET iSqlErr    --cacha el error en caso de que exista y regresa un valor predeterminado
        -- ELIMINA LA TABLA TEMPORAL DE REPORTE
        SET ISOLATION TO DIRTY READ;
        IF EXISTS ( SELECT dbsname, tabname 
                      FROM sysmaster:SysTabNames  
                     WHERE partnum > 0 
                       and tabname = 'tmpxmlarchclientecoppel' 
                       AND dbsname= 'bdinteg') THEN
            DROP TABLE BdInteg:tmpxmlarchclientecoppel;
        END IF;

        LET cCodRet = iSqlErr;

        IF (vsFlagSystem = '1') THEN -- ERROR DE GENERACION DEL ARCHIVO
            LET cCodRet = '00001';
        END IF;

        RETURN cCodRet ;
    END EXCEPTION;		
	
	--SET DEBUG FILE TO '/informix/ifxsif01/Control-M/sp_actstatusctecopnvoparam_club.out';
	--TRACE ON;
	
	--LET vsRepositorio = "/RESPALDOSNEW/CTECOPPEL";
	
	-- // VALIDA SI EXISTE LA TABLA DEL REPORTE
	SET ISOLATION TO DIRTY READ;
	IF EXISTS ( SELECT dbsname, tabname 
				  FROM sysmaster:SysTabNames  
				 WHERE partnum > 0
				   and tabname = 'tmpxmlarchclientecoppel' 
				   AND dbsname= 'bdinteg') THEN
		DROP TABLE Bdinteg:tmpxmlarchclientecoppel;
	END IF;

	-- // CREA LA TABLA DEL REPORTE
	CREATE TABLE tmpxmlarchclientecoppel
	(
		numcte_coppel  CHAR(20) NOT NULL,
		XML            LVARCHAR(10000)
	);
	
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD 		
		SELECT numcte_coppel, XML 
		INTO cnumcte_coppel, ctrama
		FROM clientes_coppel_envia_xml
		WHERE enviado ='0'
					
		
		UPDATE clientes_coppel_envia_xml SET enviado= '1' WHERE numcte_coppel= cnumcte_coppel;
		
		INSERT INTO tmpxmlarchclientecoppel(numcte_coppel, XML)
		VALUES (cnumcte_coppel, ctrama);
		
	END FOREACH;
	
	SELECT TRIM(valor)
	INTO vsRepositorio
	FROM bdinteg:"informix".si_param
	WHERE cod_param='529';
	
	SELECT TRIM(valor)
	INTO cNombre
	FROM bdinteg:"informix".si_param
	WHERE cod_param='530';
	
	SELECT DBINFO("utc_to_datetime", sh_curtime)::DATETIME HOUR TO SECOND 
	INTO dhoraActual
	FROM sysmaster:sysshmvals;
	
	LET cHora = substr(dhoraActual,1,2);
	LET cMin  = substr(dhoraActual,4,2);
	LET csec  = substr(dhoraActual,7,2);
	   
   -- // GENERA EL NOMBRE DEL ARCHIVO DE INTERCAMBIO nomenclatura:  ArchivoCombinado__AAAA-MM-DD_HH-MM-SS.log
	LET vsNomArchivo = TRIM(cNombre) || REPLACE (SUBSTRING (CURRENT FROM 1 FOR 10), '-', '' ) || '.log';
	LET vsNomArchivoF = TRIM(cNombre) || REPLACE (SUBSTRING (CURRENT FROM 1 FOR 10), '-', '' ) || '_' ||cHora || '-' || cMin || '-' ||csec ||'.log';
	
	LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) ||'/'|| TRIM (vsNomArchivo) || ' DELIMITER ' || '''|''';
	LET vsSQL2 = "SELECT numcte_coppel, sp_remplaza_n(XML) FROM BdInteg:tmpxmlarchclientecoppel;" ;
	LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || '/clientes_coppelxml.sql';

	LET vsSQL1 = TRIM(vsSQL1);
	LET vsSQL3 = TRIM(vsSQL3);
	LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

	-- // CHECA QUE NO ESTE VACIA LA CONSULTA
	IF ( vsSQL <> '' ) THEN
		LET vsFlagSystem = '1';

		-- // CREA ARCHIVO DE CONTROL
		SYSTEM vsSQL ;

		let vsSQL = '' ;
		LET vsSQL = 'dbaccess Bdinteg ' || TRIM(vsRepositorio) || '/clientes_coppelxml.sql' ;
		SYSTEM vsSQL ;

		LET vsSQL = "sed 's/|$//g' "|| TRIM(vsRepositorio) ||'/'|| TRIM (vsNomArchivo) || " > " || TRIM(vsRepositorio) ||'/'|| TRIM (vsNomArchivoF);
		SYSTEM vsSQL;

		LET vsSQL = 'rm ' || TRIM(vsRepositorio) ||'/'|| TRIM (vsNomArchivo)  ;
		SYSTEM vsSQL ;
		
		-- // BORRA EL ARCHIVO DE CONTROL
		let vsSQL = '' ;
		LET vsSQL = 'rm ' || TRIM(vsRepositorio) || '/clientes_coppelxml.sql' ;
		SYSTEM vsSQL ;

		LET vsFlagSystem = '';
	ELSE 
        -- // CONSULTA VACIA
        LET cCodRet = '00002';		
	END IF;		
	
	-- // ELIMINA LA TABLA TEMPORAL DE REPORTE
	DROP TABLE BdInteg:tmpxmlarchclientecoppel;

	RETURN  cCodRet; 

	END;
END PROCEDURE
DOCUMENT
'Autor: 		Maria Elena Angulo',
'Fecha: 		30/04/2024',
'Descripcion:	Proceso para actualizar el estatus para validar si ya se envió a coppel',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_consultainforoi(
pNumeroCliente               CHAR(9),   --Es el nÃºmero del cliente que realiza la operaciÃ³n inusual
pNumeroCuenta                CHAR(11),  --Es el nÃºmero de cuenta del cliente que realiza la operaciÃ³n inusual
pNumeroTarjeta               CHAR(16),  --NÃºmero de tarjeta del cliente que realiza la operaciÃ³n inusual
pNumeroUsuario               CHAR(9),  --El nÃºmero de usuario a reportar (El cual es el nÃºmero de cliente)
pNumeroColaborador           CHAR(8),   --Es el nÃºmero del colaborador involucrado en la operaciÃ³n inusual
pOrdenPago                   CHAR(12),  --Es el nÃºmero de orden de pago con el cual se va a solicitar la informaciÃ³n del usuario
pNumeroRemesa                CHAR(12),  --Es el nÃºmero de remesa con el cual se va a solicitar la informaciÃ³n del usuario
pGenerico1                   CHAR(100), --Parametro generico que recibe 100 caracteres
pGenerico2                   CHAR(200), --Parametro generico que recibe 200 caracteres
pGenerico3                   CHAR(300)) --Parametro generico que recibe 300 caracteres

RETURNING
--Datos a retornar
CHAR(5)          AS   cCodRet,                  --Codigo de retorno del SP
CHAR(80)         AS   cDescripcionCodRetorno,   --Descripcion del codigo retorno
CHAR(40)         AS   cNombre1,                 --El primer nombre del cliente o del usuario a reportar
CHAR(40)         AS   cNombre2,                 --El Segundo nombre del cliente o del usuario a reportar
CHAR(40)         AS   cApellidoPaterno,         --El apellido paterno del cliente o usuario a reportar
CHAR(40)         AS   cApellidoMaterno,         --El apellido materno del cliente o usuario a reportar
CHAR(9)          AS   cNumeroCliente,           --El nÃºmero de cliente de la persona que se va a reportar
CHAR(20)         AS   cCuentaCliente,           --Es la cuena del cliente a reportar
CHAR(16)         AS   cNumeroTarjeta,           --Es el nÃºmero de Tarjeta del cliente a reportar
CHAR(20)         AS   cPuestoColaborador,       --Es el nombramiento del colaborador
CHAR(20)         AS   cNombreGerente,           --Es el nombre del gerente que realizo la operaciÃ³n inusual
CHAR(100)        AS   cGenerico1,               --Texto generico 1 para el mensaje (opcional)
CHAR(100)        AS   cGenerico2,               --Texto generico 2 para el mensaje (opcional)
CHAR(100)        AS   cGenerico3;               --Texto generico 3 para el mensaje (opcional)

--Definicion de las variables sp_consultaClienteRoi

DEFINE iSqlErr                  INTEGER;    --Error SQL
DEFINE cCodRet                  CHAR(5);
DEFINE cDescripcionCodRetorno   CHAR(80);   
DEFINE cNombre1                 CHAR(40);                
DEFINE cNombre2                 CHAR(40);
DEFINE cApellidoPaterno         CHAR(40);
DEFINE cApellidoMaterno         CHAR(40);
DEFINE cNumeroCliente           CHAR(20);   
DEFINE cCuentaCliente           CHAR(20);
DEFINE cNumeroTarjeta           CHAR(16);
DEFINE cPuestoColaborador       CHAR(20);
DEFINE cNombreGerente           CHAR(20);
DEFINE cGenerico1               CHAR(100);
DEFINE cGenerico2               CHAR(100);
DEFINE cGenerico3               CHAR(100);

DEFINE iContadorAuxiliar        INTEGER;

--Inicializacion de variables
LET iSqlErr                     = 0;					--- Error SQL
LET cDescripcionCodRetorno      = 'Se encontro con exito la informacion solicitada'; --- Descripcion del estado de la transaccion
LET cCodRet                     = '00000';              --- Codigo de retorno de la transaccion
LET cNombre1                    = '';
LET cNombre2                    = '';
LET cApellidoPaterno            = '';
LET cApellidoMaterno            = '';
LET cNumeroCliente              = '';
LET cCuentaCliente              = '';
LET cNumeroTarjeta              = '';
LET cPuestoColaborador          = '';
LET cNombreGerente              = '';
LET cGenerico1                  = '';
LET cGenerico2                  = '';
LET cGenerico3                  = '';
LET iContadorAuxiliar           = 0;

BEGIN
    -- Control de errores 'informix', excepciones no controladas
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN  cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/home/c90314234/bdinteg/sp_consultainforoi.out";	
--   SET DEBUG FILE TO "/home/systelmex/pruebasroi/sp_consultainforoi.out";
--	TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --Valida que se haya ingresado los paramaetros correpondientes
    IF pNumeroRemesa = '' AND pOrdenPago = '' AND pNumeroUsuario = '' AND pNumeroColaborador = '' AND
    pNumeroTarjeta = '' AND pNumeroCuenta = '' AND pNumeroCliente = '' THEN
        LET cCodRet = '00500';
        LET cDescripcionCodRetorno = 'No se ha ingresado informacion. Por favor, valide los datos.';
        RETURN cCodRet, cDescripcionCodRetorno, cNombre1, cNombre2, cApellidoPaterno,
        cApellidoMaterno, cNumeroCliente, cCuentaCliente, cNumeroTarjeta, cPuestoColaborador, cNombreGerente,
      cGenerico1, cGenerico2, cGenerico3;
    END IF;
    --Consulta campos ingresados
    --Se consulta si tiene numero de remesa
    IF pNumeroRemesa != '' THEN
        --Se valida si la longitud es correcta
        IF LENGTH(pNumeroRemesa) != 10 AND LENGTH(pNumeroRemesa) != 11 AND LENGTH(pNumeroRemesa) != 12  THEN
            LET cDescripcionCodRetorno = 'La longitud de la remesa no es de 10,11 u 12 caracteres, favor de validar';
            LET cCodRet = '00200';
        
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;
        --Consulta informaciÃ³n por nÃºmero de remesa
        --Se valida que exita la referencia
        SELECT COUNT(*)
        INTO iContadorAuxiliar
        FROM bdisac:"informix".sac_remesas_estadistica 
        WHERE referencia = pNumeroRemesa;
        -- si existe la referencia se llenan los datos correspondientes
        IF iContadorAuxiliar > 0 THEN    
            SELECT nombre1,nombre2,appaterno,apmaterno
            INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
            FROM bdisac:"informix".sac_remesas_estadistica
            WHERE referencia = pNumeroRemesa;
        ELSE
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM bdisac:"informix".sac_remesas_estadistica_old
            WHERE referencia = pNumeroRemesa;
            IF iContadorAuxiliar > 0 THEN
                SELECT nombre1,nombre2,appaterno,apmaterno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM bdisac:"informix".sac_remesas_estadistica_old
                WHERE referencia = pNumeroRemesa;
            ELSE
                LET cDescripcionCodRetorno = 'No se encontro la remesa, por favor revise la informacion solicitada.';
                LET cCodRet = '00110'; 
            END IF;
        END IF;

        RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
        cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
        cGenerico1,cGenerico2,cGenerico3;
    END IF;
        --Consulta informaciÃ³n por Orden de pago
    IF pOrdenPago != '' THEN
        IF LENGTH(pOrdenPago) != 12 THEN
            LET cDescripcionCodRetorno = 'La longitud de la orden de pago no es de 12 caracteres, favor de validar';
            LET cCodRet = '00210';
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;

        SELECT COUNT(*)
        INTO iContadorAuxiliar
        FROM bdisac:"informix".sac_enviosdineroya
        WHERE no_control = pOrdenPago;

        IF iContadorAuxiliar>0 THEN
            SELECT pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem
            INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
            FROM bdisac:"informix".sac_enviosdineroya
            WHERE no_control = pOrdenPago;
        ELSE
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM bdisac:"informix".sac_enviosdineroyahis
            WHERE no_control = pOrdenPago;

            IF iContadorAuxiliar>0 THEN
                SELECT pri_nom_rem,seg_nom_rem,apell_pat_rem,apell_mat_rem
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM bdisac:"informix".sac_enviosdineroyahis
                WHERE no_control = pOrdenPago;
            ELSE
                LET cDescripcionCodRetorno = 'No se encontro la Orden de pago, verifique la Orden de pago.';
                LET cCodRet = '00120';
            END IF;
        END IF; 
        RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
        cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
        cGenerico1,cGenerico2,cGenerico3;
    END IF;
    -- Consulta usuario por el numero de usuario (El numero de usuario es el nÃºmero de cliente)
    IF pNumeroUsuario != '' THEN
        IF LENGTH(pNumeroUsuario) != 9 THEN
                LET cDescripcionCodRetorno = 'La longitud del numero de usuario no es de 9 caracteres, favor de validar';
                LET cCodRet = '00260';
                RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                cGenerico1,cGenerico2,cGenerico3;
        END IF;

        SELECT COUNT(*)
        INTO iContadorAuxiliar
        FROM bdinteg:"informix".si_cliente 
        WHERE numcte = pNumeroUsuario;
        
        IF iContadorAuxiliar > 0 THEN         
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM bdinteg:"informix".si_cliente 
                WHERE numcte = pNumeroUsuario;
        ELSE
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM BDINTEG:"informix".SI_FUSCLIENTE 
            WHERE numcte = pNumeroUsuario;

            IF iContadorAuxiliar > 0 THEN
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM BDINTEG:"informix".SI_FUSCLIENTE 
                WHERE numcte = pNumeroUsuario;
            ELSE
                LET cDescripcionCodRetorno = 'No se encontro el usuario, verifique el numero de usuario.';
                LET cCodRet = '00130';
            END IF;
        END IF;      
        RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
        cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
        cGenerico1,cGenerico2,cGenerico3;
    END IF;
    --Consultar por el nÃºmero de colaborador
    IF pNumeroColaborador != '' THEN

    END IF;
    --Consulta informaciÃ³n por nÃºmero de tarjeta
    IF pNumeroTarjeta != '' THEN
        IF LENGTH(pNumeroTarjeta) != 16 THEN
            LET cDescripcionCodRetorno = 'La longitud del numero de tarjeta no es de 16 caracteres, favor de validar.';
            LET cCodRet = '00230';
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;        
        SELECT COUNT(*)
        INTO iContadorAuxiliar 
        FROM bdicheq:"informix".sc_tarjeta 
        WHERE num_tarjeta = pNumeroTarjeta;

        IF iContadorAuxiliar > 0 THEN
            SELECT numcte,cuenta
            INTO  cNumeroCliente,cCuentaCliente
            FROM bdicheq:"informix".sc_tarjeta 
            WHERE num_tarjeta = pNumeroTarjeta;
            
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM bdinteg:"informix".si_cliente 
            WHERE numcte = cNumeroCliente;

            IF iContadorAuxiliar > 0 THEN 
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM bdinteg:"informix".si_cliente 
                WHERE numcte = cNumeroCliente;
            ELSE
                SELECT COUNT(*)
                INTO iContadorAuxiliar
                FROM BDINTEG:"informix".SI_FUSCLIENTE 
                WHERE numcte = cNumeroCliente;
                
                IF iContadorAuxiliar > 0 THEN 
                    SELECT nombre1,nombre2,apell_paterno,apell_materno
                    INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                    FROM BDINTEG:"informix".SI_FUSCLIENTE  
                    WHERE numcte = cNumeroCliente;
                ELSE
                    LET cDescripcionCodRetorno = 'No se encontro al cliente solicitado, verifique el numero de cliente.';
                    LET cCodRet = '00100';
                END IF;
            END IF;      
        ELSE
            LET cDescripcionCodRetorno = 'No se encontro la tarjeta, verifique el numero de tarjeta.';
            LET cCodRet = '00140';
        END IF;  
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,pNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
    END IF;
    IF pNumeroCuenta != '' THEN
        IF LENGTH(pNumeroCuenta) != 11 THEN
            LET cDescripcionCodRetorno = 'La longitud del numero de cuenta no es de 11 caracteres, favor de validar';
            LET cCodRet = '00240';
        
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;
        LET cCuentaCliente= pNumeroCuenta;

        SELECT COUNT(*)
        INTO iContadorAuxiliar
        FROM BDICHEQ:"informix".SC_MAECHQ
        WHERE CUENTA = pNumeroCuenta;

        IF iContadorAuxiliar > 0 THEN
            SELECT num_cte
            INTO cNumeroCliente
            FROM BDICHEQ:"informix".SC_MAECHQ
            WHERE CUENTA = pNumeroCuenta;

             --REGRESA NOMBRES Y APELLIDOS DEL CLIENTE
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM BDINTEG:SI_CLIENTE 
            WHERE NUMCTE = cNumeroCliente;

            IF iContadorAuxiliar > 0 THEN
                --REGRESA NOMBRES Y APELLIDOS DEL CLIENTE
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno 
                FROM BDINTEG:SI_CLIENTE 
                WHERE NUMCTE = cNumeroCliente;
            ELSE
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno 
                FROM BDINTEG:"informix".SI_FUSCLIENTE 
                WHERE NUMCTE = cNumeroCliente;       
            END IF;
			
			SELECT COUNT(*)
			INTO iContadorAuxiliar
			FROM bdicheq:"informix".sc_tarjeta 
			WHERE cuenta = pNumeroCuenta;
			
			IF iContadorAuxiliar != 0 THEN
			
				--Foreach que recorre las filas de las consultas
				FOREACH iteracionTarjeta FOR
					SELECT num_tarjeta
					INTO cNumeroTarjeta
					FROM bdicheq:"informix".sc_tarjeta 
					WHERE cuenta = pNumeroCuenta

					RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
					cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
					cGenerico1,cGenerico2,cGenerico3 WITH RESUME;   
                                                               
				END FOREACH;
			
			ELSE
				RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
					cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
					cGenerico1,cGenerico2,cGenerico3 WITH RESUME;
			END IF
			
        ELSE
            LET cDescripcionCodRetorno = 'No se encontro el numero de cuenta, verifique el numero de cuenta.';
            LET cCodRet = '00150';
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;
    END IF;
        
    IF pNumeroCliente != '' THEN
        --VERIFICA SI EXISTE EL CLIENTE
        IF LENGTH(pNumeroCliente) != 9 THEN
            LET cDescripcionCodRetorno = 'La longitud del nÃºmero de cliente no es de 9 caracteres, favor de validar';
            LET cCodRet = '00250';
            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
            cGenerico1,cGenerico2,cGenerico3;
        END IF;
       
        SELECT COUNT(*)
        INTO iContadorAuxiliar
        FROM bdinteg:"informix".si_cliente 
        WHERE numcte = pNumeroCliente;

        IF iContadorAuxiliar > 0 THEN
            --Nombres y apellidos
            SELECT nombre1,nombre2,apell_paterno,apell_materno
            INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
            FROM bdinteg:"informix".si_cliente 
            WHERE numcte = pNumeroCliente;
            -- numero de cliente
            LET cNumeroCliente = pNumeroCliente;

            SELECT COUNT(Cuenta)
            INTO cCuentaCliente
            FROM BDICHEQ:"informix".SC_MAECHQ 
            WHERE num_cte = pNumeroCliente;
            --VALIDA SI TIENE CUENTAS
            IF iContadorAuxiliar > 0 THEN
            -- numero de cuenta
                FOREACH iteracionCuenta FOR
                    SELECT cuenta
                    INTO cCuentaCliente
                    FROM BDICHEQ:"informix".SC_MAECHQ 
                    WHERE num_cte = pNumeroCliente
                    --numero de tarjeta
                    LET cNumeroTarjeta = '';
                    IF EXISTS (SELECT 1 FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = cCuentaCliente) THEN
                        FOREACH iteracionTarjeta FOR
                            SELECT num_tarjeta
                            INTO cNumeroTarjeta
                            FROM bdicheq:"informix".sc_tarjeta 
                            WHERE cuenta = cCuentaCliente

                            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                            cGenerico1,cGenerico2,cGenerico3 WITH RESUME;   
                                                                
                        END FOREACH;
                    ELSE 
                        RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                        cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                        cGenerico1,cGenerico2,cGenerico3 WITH RESUME;
                    END IF;
                END FOREACH;
            ELSE
                RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                cGenerico1,cGenerico2,cGenerico3;
            END IF;
        ELSE
            SELECT COUNT(*)
            INTO iContadorAuxiliar
            FROM BDINTEG:SI_FUSCLIENTE
            WHERE numcte = pNumeroCliente;
                    
            IF iContadorAuxiliar > 0 THEN
                --Nombres y apellidos
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombre1,cNombre2,cApellidoPaterno,cApellidoMaterno
                FROM bdinteg:"informix".si_fuscliente 
                WHERE numcte = pNumeroCliente;
                -- numero de cliente
                LET cNumeroCliente = pNumeroCliente;
                -- numero de cuenta
                FOREACH iteracionCuenta FOR
                    SELECT cuenta
                    INTO cCuentaCliente
                    FROM BDICHEQ:"informix".SC_MAECHQ 
                    WHERE num_cte = pNumeroCliente
                    --numero de tarjeta
                    LET cNumeroTarjeta = '';
                    IF EXISTS (SELECT 1 FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = cCuentaCliente) THEN
                        FOREACH iteracionTarjeta FOR
                            SELECT num_tarjeta
                            INTO cNumeroTarjeta
                            FROM bdicheq:"informix".sc_tarjeta 
                            WHERE cuenta = cCuentaCliente

                            RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                            cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                            cGenerico1,cGenerico2,cGenerico3 WITH RESUME;                                           
                        END FOREACH;
                    ELSE 
                        RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                        cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                        cGenerico1,cGenerico2,cGenerico3 WITH RESUME;
                    END IF;
                END FOREACH;
            ELSE
                LET cDescripcionCodRetorno = 'No se encontro al cliente solicitado,favor de verificar los datos';
                LET cCodRet = '00100';
                  
                RETURN cCodRet,cDescripcionCodRetorno,cNombre1,cNombre2,cApellidoPaterno,
                cApellidoMaterno,cNumeroCliente,cCuentaCliente,cNumeroTarjeta,cPuestoColaborador,cNombreGerente,
                cGenerico1,cGenerico2,cGenerico3;
            END IF;
        END IF;
    END IF;

END;
END PROCEDURE

DOCUMENT 'AUTOR: Osiel  Alfredo Camacho Mendoza',
'FECHA 29/12/2023',
'MODULO: Mejoras 11 183 Mejoras ROI ',
'FUNCIONALIDAD: Consulta usuario ROI',
'DESCRIPCION: SPL encargado de devolver la informaciÃ³n del cliente/usuario/colaborador que realizo una operaciÃ³n inusual'
;

CREATE PROCEDURE "informix".sp_consultatickethuelladec_or()

--DATOS A REGRESAR---
RETURNING          
	CHAR(5)   			AS codigoretorno,
	CHAR(50)			AS ticket;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_consultatickethuelladec_or"
Folio.........: 841 - ComparaciÃÂ³n en linea de 10 huellas.
Autor.........: 90127902 - Carlos Vazquez Mitre
Fecha.........: 31/01/2022
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE cTicket		CHAR(50);
DEFINE iContador	INTEGER;
DEFINE jContador	INTEGER;

 --SET DEBUG FILE TO '/informix/jfponce/gabriel/TRACE/sp_consultatickethuelladec_or.out';
 --TRACE ON;

-- INICIALIZACION DE VARIABLE.
LET cCodRet			= '00000';
LET iSqlErr			= 0;
LET cTicket			= '';	
LET iContador		= 0;
LET jcontador       = 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTicket;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT COUNT(numcte)
		INTO icontador
	FROM "informix".si_huella_linea_dec 
	WHERE fecha_consulta>=today-5 and fecha_env <= current -30 units minute AND ((status_consulta='3' AND codret_result = '204') OR (status_consulta='1' AND fecha_result IS NULL));
	
	
	IF(iContador > 0) THEN
	
		FOREACH
			SELECT ticket 
				INTO cTicket 
			FROM "informix".si_huella_linea_dec 
			WHERE fecha_consulta>=today-5 and fecha_env <= current -30 units minute AND ((status_consulta='3' AND codret_result = '204') 
			OR (status_consulta='1' AND fecha_result IS NULL))
			RETURN cCodRet, cTicket WITH RESUME;
		END FOREACH;
			
			SELECT COUNT(numcte)
			INTO jcontador
			FROM "informix".si_huella_linea_dec_hist 
			WHERE fecha_consulta>=today-5 and fecha_env <= current -30 units minute AND ((status_consulta='3' AND codret_result = '204') OR (status_consulta='1' AND fecha_result IS NULL));
				
			
			IF(jContador > 0) THEN
				FOREACH
					SELECT ticket 
						INTO cTicket 
					FROM "informix".si_huella_linea_dec_hist 
					WHERE fecha_consulta>=today-5 and fecha_env <= current -30 units minute AND ((status_consulta='3' AND codret_result = '204') 
					OR (status_consulta='1' AND fecha_result IS NULL))
					RETURN cCodRet, cTicket WITH RESUME;
				END FOREACH;
			END IF;
			
	ELSE			
		LET cCodRet = '00001';
		RETURN cCodRet, cTicket WITH RESUME;
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'RQI 6310007 Se agrega validacion para consultar en la tabla historica el si_huella_linea_dec_hist ticket',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 15/03/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_generahuellalinea(
													pNumCte CHAR(20),
													pIP CHAR(15),
													pTipoMov CHAR(2),
													pEmpleado CHAR(8),
													pVerificacion CHAR(2),
													pSensor CHAR(2)
												)

--DATOS A REGRESAR---
RETURNING
CHAR(5) 					AS CodigoRetorno,
CHAR(2000) 					AS TramaSalida;


--DEFINICION DE VARIABLES--
DEFINE iSql_err 			INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cCadena				CHAR(2000);
DEFINE dFechaCons			DATETIME YEAR TO DAY;
DEFINE fechaComparacion		DATETIME YEAR TO DAY;
DEFINE cSecuencia			CHAR(2);
DEFINE cSexo				CHAR(1);
DEFINE cSucursal			CHAR(4);
DEFINE cFechAlta			CHAR(10);
DEFINE cHuellaD				CHAR(942);
DEFINE cHuellaI				CHAR(942);
DEFINE cStatuHuella 		CHAR(1);
DEFINE cRefCte				CHAR(20);
DEFINE dFechaUltCon			DATETIME YEAR TO SECOND;
DEFINE cTipoCte				CHAR(2);
DEFINE cTicket				CHAR(20);
DEFINE cStatusCons			CHAR(1);
DEFINE cRspMsj601			CHAR(1);
DEFINE cFechaAlt			CHAR(10);
DEFINE cFecUlCam			CHAR(18);
DEFINE cContador 			INTEGER;
DEFINE cContador_2 			INTEGER;
DEFINE cContador_3			INTEGER;
DEFINE cContador_4			INTEGER;
DEFINE cContador_5			CHAR(1);
DEFINE cContador_6			INTEGER;
DEFINE cSecuenciaMax 		INTEGER;
DEFINE cSecuenciaDec 		INTEGER;
DEFINE iHuellas_cap 		SMALLINT;
DEFINE dFecha_alta_prueba 	DATE;
DEFINE cprint				CHAR(50);
DEFINE iExiste				SMALLINT;
DEFINE iVacio				SMALLINT;

  --SET DEBUG FILE TO "/informix/jfponce/gabriel/TRACE/sp_generahuellalinea_PropuestaFinal.out";
  --TRACE ON;

--INICIALIZACION DE VARIABLES--
LET iSql_err 	 		= 0;
LET cCodRet 	 		= '00000';
LET cCadena		 		= "";
LET dFechaCons	 		= TODAY;
LET fechaComparacion	= TODAY;
LET cSecuencia	 		= "";
LET cSexo		 		= "";
LET cSucursal	 		= "";
LET cFechAlta	 		= "";
LET cHuellaD	 		= "";
LET cHuellaI	 		= "";
LET cStatuHuella 		= "";
LET cRefCte		 		= "";
LET dFechaUltCon 		= CURRENT YEAR TO SECOND;
LET cTipoCte	 		= "";
LET cTicket		 		= "";
LET cStatusCons  		= "0";
LET cRspMsj601   		= "";
LET cFechaAlt	 		= "";
LET cFecUlCam	 		= "";
LET cContador    		= 0;
LET cContador_2  		= 0;
LET cContador_3  		= 0;
LET cContador_4  		= 0;
LET cContador_5			= "0";
LET cContador_6			= 0;
LET cSecuenciaMax 		= 0;
LET cSecuenciaDec 		= 1;
LET iHuellas_cap 		= 0;
LET dFecha_alta_prueba 	= TODAY;
LET cprint				= '';
LET iExiste				= 0;
LET iVacio				= 0;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN  cCodRet, cCadena;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

	--Controlar tipo pTipoMov = 'A' y pTipoMov vacio
	IF (pTipoMov = 'A') THEN
		LET pTipoMov = '1';
	ELIF (TRIM(pTipoMov) = '' OR pTipoMov IS NULL )	THEN
		LET pTipoMov = '1';
		LET iVacio = 1;
	END IF;
	
	SELECT COUNT(*) 
	INTO cContador
	FROM bdinteg:"informix".si_cliente 
	WHERE numcte = pNumCte;

	IF (cContador > 0) THEN		
		
		--Fecha Consulta
		SELECT fecha_hoy 
		INTO dFechaCons 
		FROM bdinteg:"informix".si_fechas 
		WHERE empresa = '001';
		
		--Nuevas lineas para comparar si fueron tomadas nuevas huellas. En caso de que si se pone cContador_5 = '1'
		SELECT MAX(fecha)
		INTO fechaComparacion
		FROM bdinteg:"informix".si_cte_huella_dec_actual
		WHERE numcte = pNumCte;

		SELECT COUNT(*) 
        INTO cContador_6
        FROM bdinteg:"informix".si_huella_linea_dec 
        WHERE fecha_consulta = dFechaCons 
		AND numcte = pNumCte 
		AND status_consulta <> '';
	
		IF (fechaComparacion == dFechaCons )THEN
			LET cContador_5 = '1';
		END IF;
		
		
		
		--Se consulta la huella del cliente si no existen o es de otro dia la consulta se agregan
		SELECT COUNT(*) 
		INTO cContador_2
		FROM bdinteg:"informix".si_huella_linea 
		WHERE fecha_consulta <> dFechaCons 
		AND numcte = pNumCte 
		AND status_consulta <> "";
		IF (cContador_5 =='1') THEN
			IF (cContador_2 > 0) THEN
				
				IF (iVacio = 1) THEN
					--Se cambia tipo mov a mantenimiento, porque ya se envio a comparar previamente
					LET pTipoMov = '4';
				END IF;
				
				INSERT INTO bdinteg:"informix".si_huella_linea_hist(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
															empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, 
															tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601)
				SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, 
						imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
				FROM bdinteg:"informix".si_huella_linea 
				WHERE numcte = pNumCte;
				
				DELETE FROM bdinteg:"informix".si_huella_linea 
				WHERE numcte = pNumCte;			
			END IF;
		END IF;
		--ref_coppel, Tipo Persona
        SELECT TRIM(cte.numcte_ref), TRIM(cte.tpo_persona)
		INTO cRefCte, cTipoCte
		FROM bdinteg:"informix".si_cliente cte
		WHERE cte.numcte = pNumCte;
           
        --sexo
        SELECT TRIM(ctepf.sexo)
		INTO cSexo
		FROM bdinteg:"informix".si_ctepf ctepf
		WHERE ctepf.numcte = pNumCte;

		--tiene huella el cliente	
        SELECT COUNT(*) 
        INTO cContador_3
        FROM bdinteg:"informix".si_cte_huella 
        WHERE numcte = pNumCte;
		
		IF (cContador_3 > 0)THEN			
			SELECT MAX(secuencia) 
			INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella 
			WHERE numcte = pNumCte AND estado = 'A';

			--Secuencia, Sucursal, Fecha Alta, dmapa, imapa, Estatus Huella, Fecha Ultima Cambio
			SELECT secuencia, TRIM(sucursal), TO_CHAR(fecha_alta, "%Y%m%d"), TRIM(dmapa), TRIM(imapa), TRIM(estado), 
					NVL(fech_ult_camb,CURRENT YEAR TO SECOND)
			INTO cSecuencia, cSucursal, cFechAlta, cHuellaD, cHuellaI, cStatuHuella, dFechaUltCon
			FROM bdinteg:"informix".si_cte_huella 
			WHERE numcte = pNumCte
			AND secuencia = cSecuenciaMax;
		END IF;
			
		-- Se insertan registros en la si_huella_linea
		LET cFechaAlt = SUBSTR(cFechAlta,1,4) ||"-"|| SUBSTR(cFechAlta,5,2) ||"-"|| SUBSTR(cFechAlta,7,2);
		
		
		
		--Se consulta la huella del cliente, si es el mismo dia se regresan los mismo datos ya consultados
        SELECT COUNT(*) 
        INTO cContador_4
        FROM bdinteg:"informix".si_huella_linea 
        WHERE fecha_consulta = dFechaCons 
		AND numcte = pNumCte 
		AND status_consulta <> '';
		
		
		IF (cContador_5 =='1') THEN
			IF (cContador_4 = 0) THEN
			
				INSERT INTO bdinteg:"informix".si_huella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
													empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente,
													tipo_verificacion, ticket, status_consulta, respuesta_msj601)
				VALUES  (pNumCte, dFechaCons, cSecuencia, cSexo, cSucursal, TO_DATE(cFechaAlt, "%Y-%m-%d"), pIP, pTipoMov,
						pEmpleado, pSensor,	cHuellaD, cHuellaI, cStatuHuella, cRefCte, dFechaUltCon, cTipoCte,
						pVerificacion, cTicket, cStatusCons, cRspMsj601);
			END IF;
		END IF;
		LET cFecUlCam = TO_CHAR(dFechaUltCon);
		LET cFecUlCam = SUBSTR(cFecUlCam,1,4) || SUBSTR(cFecUlCam,6,2) || SUBSTR(cFecUlCam,9,2) || " 00:00:00";
		
		--Se construye trama
		LET cCadena = TRIM(pNumCte) ||"|"|| TRIM(cSecuencia) ||"|"|| cSexo ||"|"|| cSucursal ||"|"|| TRIM(cFechAlta)
			||"|"|| TRIM(pIP) ||"|"|| TRIM(pTipoMov) ||"|"|| TRIM(pEmpleado) ||"|"|| TRIM(pSensor) ||"|"|| TRIM(cHuellaD)
			||"|"|| TRIM(cHuellaI) ||"|"|| cStatuHuella ||"|"|| TRIM(cRefCte) ||"|"|| TRIM(cFecUlCam) ||"|"|| TRIM(cTipoCte) 
			||"|"|| TRIM(pVerificacion) ||"|";
		
		--INICIA 10 HUELLAS
		IF cContador_5 == '1' THEN
			IF (cContador_6 = 0) THEN

				IF (cContador_3 > 1) THEN
					SELECT MAX(secuencia)
					INTO cSecuenciaDec
					FROM bdinteg:"informix".si_cte_huella_dec_actual 
					WHERE numcte = pNumCte;
				END IF;

				-- SE INSERTA TABLA si_huella_linea_dec codigo nuevo proyecto 10 huellas
				SELECT count(numcte) 
				INTO iHuellas_cap 
				FROM bdinteg:"informix".si_cte_huella_dec_actual 
				WHERE numcte = pNumCte AND secuencia = cSecuenciaDec AND id_excepcion = 0;
				
				IF (iHuellas_cap > 0)THEN
					INSERT INTO si_huella_linea_dec(numcte,secuencia,fecha_consulta,status_consulta,sexo,sucursal,fecha_alta_huella,
													ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,
													fecha_ult_cambio,huellas_cap,fecha_insert)
					VALUES(pNumCte, cSecuenciaDec, dFechaCons, cStatusCons, cSexo, cSucursal, dFecha_alta_prueba, pIP, pTipoMov,
								pEmpleado, pSensor, cStatuHuella, cRefCte, cTipoCte, pVerificacion, dFechaUltCon, iHuellas_cap,CURRENT);
								
				END IF; 
				
				SELECT COUNT(numcte) 
				INTO iExiste 
				FROM bdinteg:"informix".si_huella_linea_dec 
				WHERE secuencia = cSecuenciaDec 
				AND numcte = pNumCte;
				
				IF (iExiste > 0) THEN
				
					INSERT INTO si_huella_linea_dec_hist(numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal, 
														fecha_alta_huella,fecha_ult_cambio,ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,
														tipo_cliente,tipo_verificacion,huellas_cap,code_service,origen_ticket,origen_result,fecha_insert,
														fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,codret_result)
					SELECT numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal,fecha_alta_huella,fecha_ult_cambio,ip,
							tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,huellas_cap,code_service,
							origen_ticket,origen_result,fecha_insert,fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,
							codret_result
					FROM bdinteg:"informix".si_huella_linea_dec 
					WHERE numcte = pNumCte
					AND secuencia <> cSecuenciaDec;
					
					-- SELECT ticket 
					-- INTO cTicket 
					-- FROM bdinteg:"informix".si_huella_linea_dec 
					-- WHERE numcte = pNumCte
					-- AND secuencia = cSecuenciaDec;
					
					-- IF (NVL(cTicket, '') <> '') THEN
						INSERT INTO si_huella_linea_dec_result_hist(id_hist,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,
																	fecha_nac,situacion,causa,activo)
						SELECT id,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,fecha_nac,situacion,causa,activo
						FROM bdinteg:"informix".si_huella_linea_dec_result 
						WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
						
						DELETE FROM bdinteg:"informix".si_huella_linea_dec_result 
						WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
					-- END IF;	
				
					DELETE FROM bdinteg:"informix".si_huella_linea_dec 
					WHERE numcte = pNumCte
					AND secuencia <> cSecuenciaDec;
				END IF;
				
				
			 
			END IF;		 
		END IF;
	ELSE
		LET cCodRet = '00001';
		LET cCadena = 'El cliente no existe en la si_cliente';
	END IF;

	RETURN cCodRet, TRIM(cCadena);
END;
END PROCEDURE

DOCUMENT
'Inserta registro en si_huella_linea y regresa la trama del registro insertado',
'Autor :Daniela Ramirez',
'FECHA : 23/Febrero/2012',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Se agrega un insert a la si_huella_linea_dec y a la si_huella_linea_dec_hist',
'Modifico: Carlos Vazquez Mitre',
'Fecha: 31/01/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Para RQI 63 730 Comparacion en linea 10 huellas, se agrega validacion para guardar en la tabla si_huella_linea_dec, si_huella_linea_dec_hist, si_huella_linea_dec_result_hist, dependiedo si la sucursal es piloto y esta registrada en la tabla si_piloto_suc',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 08/04/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 63 730 Comparacion en linea 10 huellas, Se agrega campo cSecuenciaDec para usar secuencia de alta y mantenimiento de 10 huellas',
'Modifico: Juan Francisco Ponce',
'Fecha: 28/09/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 63 890 Se agrega una consulta a la si_cte_huella_dec_actual para saber si hay algun cambio en las huellas. Se anadieron las variables cContador_5 y cContador_6 para evitar que se anadan campos a la tablas si no hay nuevas huellas',
'Modifico: Jahaziel Eduardo Heredia Hinojosa',
'Fecha: 29/12/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Se agregan validaciones para no permitir tipo de movimiento en blanco',
'Modifico: Juan Francisco Ponce',
'Fecha: 13/09/2023',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 6310007 Se modifica y corrige la logica para que se ejecute el pase de los registros de las tablas de trabajo de 10 huellas a sus respectivas tablas historicas',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 01/03/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_generahuellalinea_chl(pNumCte CHAR(20),pIP CHAR(15),pTipoMov CHAR(2),pEmpleado CHAR(8),pVerificacion CHAR(2), pSensor CHAR(2))
	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) 	AS CodigoRetorno,
	CHAR(2000) 	AS TramaSalida;

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err 	INTEGER;
	DEFINE cCodRet 		CHAR(5);
	DEFINE cCadena		CHAR(2000);
	DEFINE dFechaCons	DATETIME YEAR TO DAY;
	DEFINE smSecuencia	SMALLINT;
	DEFINE cGeneraTrama	CHAR(1);
	DEFINE smSec_linea	SMALLINT;
	DEFINE cSexo		CHAR(1);
	DEFINE cSucursal	CHAR(4);
	DEFINE cFechAlta	CHAR(10);
	DEFINE cHuellaD		CHAR(942);
	DEFINE cHuellaI		CHAR(942);
	DEFINE cStatuHuella CHAR(1);
	DEFINE cRefCte		CHAR(20);
	DEFINE dFechaUltCon	DATETIME YEAR TO SECOND;
	DEFINE cTipoCte		CHAR(2);
	DEFINE cTicket		CHAR(20);
	DEFINE cStatusCons	CHAR(1);
	DEFINE cRspMsj601	CHAR(1);
	DEFINE cFechaAlt	CHAR(10);
	DEFINE cFecUlCam	CHAR(18);
	DEFINE dFecha_alta_prueba 	DATE;
	DEFINE iExiste		SMALLINT;
	DEFINE iHuellas_cap 		SMALLINT;
	DEFINE cSecuenciaDec 		INTEGER;
	--DEFINE cContador_3			INTEGER;
	DEFINE iVacio				SMALLINT;

	--INICIALIZACION DE VARIABLES--
	LET iSql_err 	 = 0;
	LET cCodRet 	 = '00000';
	LET cCadena		 = "";
	LET dFechaCons	 = TODAY;
	LET smSecuencia	 = 0;
	LET cGeneraTrama = '0';
	LET smSec_linea	 = 0;
	LET cSexo		 = "";
	LET cSucursal	 = "";
	LET cFechAlta	 = "";
	LET cHuellaD	 = "";
	LET cHuellaI	 = "";
	LET cStatuHuella = "";
	LET cRefCte		 = "";
	LET dFechaUltCon = CURRENT YEAR TO SECOND;
	LET cTipoCte	 = "";
	LET cTicket		 = "";
	LET cStatusCons  = "0";
	LET cRspMsj601   = "";
	LET cFechaAlt	 = "";
	LET cFecUlCam	 = "";
	LET dFecha_alta_prueba 	= TODAY;
	LET iExiste				= 0;
	LET iHuellas_cap 		= 0;
	LET cSecuenciaDec 		= 1;
	--LET cContador_3  		= 0;
	LET iVacio				= 0;
	


	--SET DEBUG FILE TO "/informix/jfponce/gabriel/TRACE/sp_generahuellalinea_chl_PropuestaFinal.out";
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cCadena;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte) THEN
			
			--Controlar pTipoMov vacio
			IF (TRIM(pTipoMov) = '' OR pTipoMov IS NULL ) THEN
				LET pTipoMov = '1';
				LET iVacio = 1;
			END IF;
			
			SELECT TRIM(cte.numcte_ref), TRIM(cte.tpo_persona), TRIM(ctepf.sexo)
			INTO cRefCte, cTipoCte, cSexo
			FROM bdinteg:"informix".si_cliente cte,
				 bdinteg:"informix".si_ctepf ctepf
			WHERE cte.numcte = pNumCte
			AND ctepf.numcte = pNumCte;
				
			IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_cte_huella WHERE numcte = pNumCte)THEN
				--Secuencia, Sucursal, Fecha Alta, dmapa, imapa, Estatus Huella, Fecha Ultima Cambio
				SELECT secuencia, TRIM(sucursal), TO_CHAR(fecha_alta, "%Y%m%d"), TRIM(dmapa), TRIM(imapa), TRIM(estado), NVL(fech_ult_camb,CURRENT YEAR TO SECOND)
				INTO smSecuencia, cSucursal, cFechAlta, cHuellaD, cHuellaI, cStatuHuella, dFechaUltCon
				FROM bdinteg:"informix".si_cte_huella 
				WHERE numcte = pNumCte
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_cte_huella WHERE numcte = pNumCte AND estado = 'A');
			END IF;
			
			--Fecha Consulta
			SELECT fecha_hoy INTO dFechaCons FROM bdinteg:"informix".si_fechas;
			LET cFechaAlt = SUBSTR(cFechAlta,1,4) ||"-"|| SUBSTR(cFechAlta,5,2) ||"-"|| SUBSTR(cFechAlta,7,2);
			
			IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_huella_linea WHERE numcte = pNumCte AND status_consulta <> "") THEN
				-- Se actualiza registro en la si_huella_linea
				SELECT NVL(secuencia ,'0'), NVL(ticket,'')
				INTO smSec_linea, cTicket
				FROM bdinteg:"informix".si_huella_linea 
				WHERE numcte = pNumCte;
				
				IF smSecuencia > smSec_linea THEN	
				
					IF (iVacio = 1) THEN
						--Se cambia tipo mov a mantenimiento, porque ya se envio a comparar previamente
						LET pTipoMov = '4';
					END IF;
				
					INSERT INTO bdinteg:"informix".si_huella_linea_hist_chl(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, 
								status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert)
					SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, 
								status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
					FROM bdinteg:"informix".si_huella_linea
					WHERE numcte = pNumCte;
					
					INSERT INTO bdinteg:"informix".si_huella_linea_resultado_hist_chl (estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, 
								nombre, fecha_nac, situacion, causa)
					SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa
					FROM bdinteg:"informix".si_huella_linea_resultado
					WHERE ticket = cTicket;
					
					DELETE FROM bdinteg:"informix".si_huella_linea
					WHERE numcte = pNumCte;
										
					DELETE FROM bdinteg:"informix".si_huella_linea_resultado
					WHERE ticket = cTicket;
					
					LET cTicket = '';
					
					INSERT INTO bdinteg:"informix".si_huella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
								empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, 
								respuesta_msj601)
					VALUES	(pNumCte, dFechaCons, smSecuencia, cSexo, cSucursal, TO_DATE(cFechaAlt, "%Y-%m-%d"), pIP, pTipoMov,
							pEmpleado, pSensor,	cHuellaD, cHuellaI, cStatuHuella, cRefCte, dFechaUltCon, cTipoCte, pVerificacion, cTicket, cStatusCons, 
							cRspMsj601);
					/*UPDATE bdinteg:"informix".si_huella_linea SET fecha_consulta = dFechaCons, secuencia = smSecuencia, sexo = cSexo, sucursal = cSucursal, 
						   fecha_alta_huella = TO_DATE(cFechaAlt, "%Y-%m-%d"), ip = pIP, tipo_mov_huella = pTipoMov, empleado = pEmpleado, tipo_sensor = pSensor, 
						   dmapa = cHuellaD, imapa = cHuellaI, status_huella = cStatuHuella, ref_coppel = cRefCte, fecha_ult_cambio = dFechaUltCon, tipo_cliente = cTipoCte,
							tipo_verificacion = pVerificacion , ticket = cTicket, status_consulta = cStatusCons, respuesta_msj601 = cRspMsj601, fecha_insert = CURRENT
					WHERE numcte = pNumCte;*/

					LET cGeneraTrama = '1';
				ELSE
					LET cCodRet = '00002';
					LET cCadena = 'El registro no afecto si_huella_linea porque ya existe';
				END IF;
			ELSE
				INSERT INTO bdinteg:"informix".si_huella_linea(	numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
																empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente,
																tipo_verificacion, ticket, status_consulta, respuesta_msj601)
				VALUES(pNumCte, dFechaCons, smSecuencia, cSexo, cSucursal, TO_DATE(cFechaAlt, "%Y-%m-%d"), pIP, pTipoMov,
						pEmpleado, pSensor,	cHuellaD, cHuellaI, cStatuHuella, cRefCte, dFechaUltCon, cTipoCte,
						pVerificacion, cTicket, cStatusCons, cRspMsj601);

				LET cGeneraTrama = '1';
			END IF;
			
	
			
			IF cGeneraTrama = '1' THEN
				LET cFecUlCam = TO_CHAR(dFechaUltCon);
				LET cFecUlCam = SUBSTR(cFecUlCam,1,4) || SUBSTR(cFecUlCam,6,2) || SUBSTR(cFecUlCam,9,2) || " 00:00:00";

				--Se construye trama
				LET cCadena = TRIM(pNumCte) ||"|"|| smSecuencia ||"|"|| cSexo ||"|"|| cSucursal ||"|"|| TRIM(cFechAlta)
					||"|"|| TRIM(pIP) ||"|"|| TRIM(pTipoMov) ||"|"|| TRIM(pEmpleado) ||"|"|| TRIM(pSensor) ||"|"|| TRIM(cHuellaD)
					||"|"|| TRIM(cHuellaI) ||"|"|| cStatuHuella ||"|"|| TRIM(cRefCte) ||"|"|| TRIM(cFecUlCam) ||"|"|| TRIM(cTipoCte) 
					||"|"|| TRIM(pVerificacion) ||"|";
			END IF;
					
					--tiene huella el cliente	
        --SELECT COUNT(*) 
        --INTO cContador_3
        --FROM bdinteg:"informix".si_cte_huella 
        --WHERE numcte = pNumCte;
		
	
			
		-- INICIA 10 HUELLAS
		
				
			 --IF (cContador_3 > 1) THEN
				SELECT MAX(secuencia) 
					INTO cSecuenciaDec
					FROM bdinteg:"informix".si_cte_huella_dec_actual 
					WHERE numcte = pNumCte;
				--END IF;
				
				-- SE INSERTA TABLA si_huella_linea_dec
				SELECT count(numcte) 
					INTO iHuellas_cap 
				FROM "informix".si_cte_huella_dec_actual 
				WHERE numcte = pNumCte
					AND secuencia = cSecuenciaDec AND id_excepcion = 0;
				
				IF (iHuellas_cap > 0)THEN
					INSERT INTO "informix".si_huella_linea_dec(numcte,secuencia,fecha_consulta,status_consulta,sexo,sucursal,fecha_alta_huella,
																		ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,
																		fecha_ult_cambio,huellas_cap,fecha_insert)
						VALUES(pNumCte, cSecuenciaDec, dFechaCons, cStatusCons, cSexo, cSucursal, dFecha_alta_prueba, pIP, pTipoMov,
								pEmpleado, pSensor, cStatuHuella, cRefCte, cTipoCte, pVerificacion, dFechaUltCon, iHuellas_cap,CURRENT);
				END IF;
				
				SELECT COUNT(numcte) 
					INTO iExiste 
				FROM "informix".si_huella_linea_dec 
				WHERE secuencia = cSecuenciaDec 
					AND numcte = pNumCte;
				
				IF (iExiste > 0) THEN
				
					INSERT INTO "informix".si_huella_linea_dec_hist(numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal,
						fecha_alta_huella,fecha_ult_cambio,ip,tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,
						tipo_cliente,tipo_verificacion,huellas_cap,code_service,origen_ticket,origen_result,fecha_insert,
						fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,codret_result)
					SELECT numcte,secuencia,fecha_consulta,status_consulta,ticket,sexo,sucursal,fecha_alta_huella,fecha_ult_cambio,ip,
						tipo_mov,empleado,tipo_sensor,status_huella,ref_coppel,tipo_cliente,tipo_verificacion,huellas_cap,code_service,
						origen_ticket,origen_result,fecha_insert,fecha_env,fecha_resp,fecha_result,desc_result,match_result,num_match_result,
						codret_result
					FROM "informix".si_huella_linea_dec 
					WHERE secuencia <> cSecuenciaDec 
						AND numcte = pNumCte;
					
					-- SELECT ticket 
						-- INTO cTicket 
					-- FROM "informix".si_huella_linea_dec 
					-- WHERE secuencia = cSecuenciaDec 
						-- AND numcte = pNumCte;
					
					-- IF (NVL(cTicket, '') <> '') THEN
						INSERT INTO si_huella_linea_dec_result_hist(id_hist,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,
																		fecha_nac,situacion,causa,activo)
							SELECT id,ticket,cliente,empresa,Fecha_insert,secuenciacpl,nombre,fecha_nac,situacion,causa,activo
							FROM "informix".si_huella_linea_dec_result 
							WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
						
						DELETE FROM "informix".si_huella_linea_dec_result 
						WHERE ticket in (SELECT ticket FROM "informix".si_huella_linea_dec WHERE numcte = pNumCte and secuencia <> cSecuenciaDec);
					-- END IF;	
				
					DELETE FROM "informix".si_huella_linea_dec 
					WHERE secuencia <> cSecuenciaDec 
						AND numcte = pNumCte;
				END IF;
				
		
		ELSE
			LET cCodRet = '00001';
			LET cCadena = 'El cliente no existe en la si_cliente';
		END IF;

		RETURN cCodRet, TRIM(cCadena);
	END

END PROCEDURE

DOCUMENT
'Inserta registro en bdinteg:si_huella_linea y regresa la trama del registro insertado',
'Autor :Daniela Ramirez',
'FECHA : 23/Febrero/2012',
'BD: bdinteg',
'**************************************************************************************',
'MODIFICACION:Se modifica para eliminar el UPDATE de la tabla si_huella_linea cuando ya exista registro de las huellas del cliente,',
'en su lugar realizara un movimiento de la informacion al historico y despues insertara el(los) nuevo(s) registro(s)',
'SUSTENTA: RQI 64 060',
'FECHA : 03/DICIEMBRE/2014',
'MODIFICACION:Se modifica el tipo de dato de las variables smSecuencia y smSec_linea para evitar problemas funcionales en el proceso',
'SUSTENTA: RQI 64 166',
'FECHA : 15/JUNIO/2016',
'**************************************************************************************',
'MODIFICACION:Se modifica para generar el registro en si_huella_linea_dec y si aplica generar los historicos',
'Autor : Narciso Cisneros',
'SUSTENTA: RQI 63 730 Comparacion en linea 10 huellas',
'FECHA : 25/MARZO/2022',
'----------------------------------------------------------------------------',
'MOFICACION:se agrega validacion para guardar en la tabla si_huella_linea_dec, si_huella_linea_dec_hist, si_huella_linea_dec_result_hist, dependiedo si la sucursal es piloto y esta registrada en la tabla si_piloto_suc',
'Autor: Gabriel Romero Cuauhitzo',
'SUSTENTA: RQI 63 730 Comparacion en linea 10 huellas',
'FECHA: 08/04/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 63 730 Comparacion en linea 10 huellas, Se agrega campo cSecuenciaDec para usar secuencia de alta y mantenimiento de 10 huellas',
'Modifico: Juan Francisco Ponce',
'Fecha: 28/09/2022',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'Se agregan validaciones para no permitir tipo de movimiento en blanco',
'Modifico: Juan Francisco Ponce',
'Fecha: 13/09/2023',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'MOFICACION:se elimina la validacion cuando la sucursal es piloto y esta registrada en la tabla si_piloto_suc',
'Autor: Gabriel Romero Cuauhitzo',
'SUSTENTA: RQI 63 730 Comparacion en linea 10 huellas',
'FECHA: 05/01/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------',
'RQI 6310007 Se modifica y corrige la logica para que se ejecute el pase de los registros de las tablas de trabajo de 10 huellas a sus respectivas tablas historicas',
'Modifico: Gabriel Romero Cuauhitzo',
'Fecha: 01/03/2024',
'BD: bdinteg',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_inserta_actividad_economica_cliente(p_NumCte CHAR(20), p_Sucursal CHAR(4), p_Ejecutivo CHAR(8),  p_Actividad CHAR(100))
        RETURNING CHAR(6);
		
		DEFINE v_CodRet 				VARCHAR(5);
		DEFINE sql_err                  INTEGER;
        DEFINE isam_err                 INTEGER;
        DEFINE error_info               VARCHAR(60);
		DEFINE v_Existe					INTEGER;
		
		DEFINE v_Fecha					DATETIME year to second;
		
		LET v_CodRet					='00000';
		LET sql_err                     = 0;
        LET isam_err                    = 0;
        LET error_info                  = "";
		LET v_Existe					= 0;
		LET v_Fecha						= CURRENT;
		BEGIN
                ON EXCEPTION SET sql_err, isam_err, error_info
                        LET v_CodRet = sql_err;
                        RETURN v_CodRet;
                END EXCEPTION;
				
				SELECT  count(*) INTO v_Existe FROM si_cliente WHERE numcte = p_NumCte;
				
				IF v_Existe <=0 THEN
					LET v_CodRet = '00001';
				ELSE
					INSERT INTO si_cliente_actividad_economica (empresa, numcte, sucursal, ejecutivo, fecha_insert, actividad_economica) 
					VALUES('001',p_NumCte,p_Sucursal,p_Ejecutivo,v_Fecha,p_Actividad);
				END IF;
				
				RETURN v_CodRet;
		END
END PROCEDURE
DOCUMENT
'SP para Insertar actividad economica del cliente cuando se corra la calificaciÃ³n inicial de riesgo de cliente',
'AUTOR : Eduardo Ãvila PÃ©re Tagle',
'Area: Sitemas',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Miguel Angel Mendoza Maldonado',
'Fecha: 01/Mayo/2024',
'Version: 2.0.0',
'BD: bdinteg',
'Requerimiento: RQM 11 178 CalificaciÃ³n inicial de riesgo de cliente';

CREATE PROCEDURE "informix".sp_wsenviohuellas(fechaActual DATE,registros INT)

RETURNING
        CHAR(5)   as ccCodRetorno,
        char(100) as mensaje,
        CHAR(10)  as cCliente_coppel,
        CHAR(10)  as cCliente_banco,
        CHAR(10)  as cUsuario,
        CHAR      as cSexo,
        CHAR      as cCompany,
        CHAR      as cstore_number,
        CHAR      as cStatus_huella,
        date      as dFecha_insert,
        CHAR      as cDpositiond,
        CHAR      as cDsecuencia,
        CHAR(942) as cDMapa,
        CHAR      as cIpositiond,
        CHAR      as cIsecuencia,
        CHAR(942) as cIMapa;


DEFINE  ccCodRetorno    CHAR(5);
DEFINE  mensaje         char(100);                                                                        
DEFINE  cCliente_coppel CHAR(10);
DEFINE  cCliente_banco  CHAR(10);
DEFINE  cUsuario        CHAR(10);
DEFINE  cSexo           CHAR;
DEFINE  cCompany        CHAR;
DEFINE  cstore_number   CHAR;
DEFINE  cStatus_huella  CHAR;
DEFINE  dFecha_insert   date;
DEFINE  cDpositiond     CHAR;
DEFINE  cDsecuencia     CHAR;
DEFINE  cDMapa          CHAR(942);
DEFINE  cIpositiond     CHAR;
DEFINE  cIsecuencia     CHAR;
DEFINE  cIMapa          CHAR(942);
DEFINE  iNumreg         INTEGER;
DEFINE  sql_err         INTEGER;
DEFINE  isam_err        INTEGER;
DEFINE  vcodret1        INTEGER;
DEFINE  vcodret2        INTEGER;

LET  ccCodRetorno       = '00000';
LET  mensaje            = 'EXITO' ;
LET  cCliente_coppel    = '';
LET  cCliente_banco     = '';
LET  cUsuario           = '';
LET  cSexo              = '';
LET  cCompany           = '';
LET  cstore_number      = '';
LET  cStatus_huella     = '';
LET  dFecha_insert      = mdy(01,01,1900);
LET  cDpositiond        = '';
LET  cDsecuencia        = '';
LET  cDMapa             = '';
LET  cIpositiond        = '';
LET  cIsecuencia        = '';
LET  cIMapa             = '';
LET  iNumreg            = 0;

BEGIN

        ON EXCEPTION SET sql_err, isam_err
            IF sql_err <> 0 THEN
                                LET ccCodRetorno = sql_err;
                                LET mensaje = 'NUM ISAM ERR: '|| isam_err || ' ' || "SQL";
            RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,TODAY,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/EPG/sp_wsenviohuellas.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
        IF   ( registros IS NULL OR registros = '' OR registros < 0  ) THEN
                LET ccCodRetorno = '00002';
                LET mensaje = "Valor de variable registros no validos";
                RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF

        DELETE FROM sp_temphuella;
		
        INSERT INTO  bdinteg:cte_coppel_huella 
        SELECT a.numcte_coppel,0,c.numcte_banco, CURRENT TIMESTAMP,a.fecha_insert,'' 
        FROM clientes_coppel_envia_xml a 
        LEFT JOIN cte_coppel_huella b ON a.numcte_coppel = b.numcte_coppel 
        LEFT JOIN si_relacion_ctebcplcpl c ON c.cliente = a.numcte_coppel
        WHERE b.numcte_coppel IS NULL AND a.fecha_insert >= MDY(month (fechaActual),day (fechaActual),year(fechaActual));
 

        INSERT INTO  bdinteg:sp_temphuella 
        SELECT LIMIT registros numcte_coppel, numcte_banco 
		FROM cte_coppel_huella
		--INNER JOIN si_huella_linea AS a on numcte_banco = a.numcte 
		WHERE estatus = 0  
			and date (fec_xml_creacion)= MDY(month (fechaActual),day (fechaActual),year(fechaActual));

					
        FOREACH
              
            SELECT LIMIT registros d.numcte_coppel, d.numcte_banco
            INTO  cCliente_coppel,cCliente_banco
            FROM sp_temphuella AS d
                    
			SELECT empleado, sexo, 5 AS company, 2 AS store_number, status_huella, date (fecha_alta_huella),  2 AS positiond, secuencia, dmapa, 7 AS positiond, secuencia, imapa 
            INTO  cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa
            FROM si_huella_linea AS a 
			WHERE a.numcte = cCliente_banco;	
				
			IF cUsuario is null THEN
				UPDATE bdinteg:cte_coppel_huella  SET estatus = 3, fec_act_estatus = CURRENT  where numcte_coppel = cCliente_coppel;
			ELSE
				UPDATE bdinteg:cte_coppel_huella  SET estatus = 1, fec_act_estatus = CURRENT  where numcte_coppel = cCliente_coppel;
				LET iNumreg = iNumreg + 1;     	 

				RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa WITH RESUME;

			END IF;
			
        END FOREACH;


        IF  iNumreg = 0 THEN
                LET ccCodRetorno = '00001';
                LET mensaje = "No se encontro informacion por actualizar";
                RETURN ccCodRetorno, mensaje, cCliente_coppel,cCliente_banco,cUsuario,cSexo,cCompany,cstore_number,cStatus_huella,dFecha_insert,cDpositiond,cDsecuencia,cDMapa,cIpositiond,cIsecuencia,cIMapa;
        END IF;

END


END PROCEDURE;