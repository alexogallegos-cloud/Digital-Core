CREATE PROCEDURE "informix".sp_generaarchivoaltasolicitud2(pempresa CHAR(3), pFechaAct DATE)
RETURNING CHAR(6);										 
DEFINE vClave, varea, vaceptadosupervisadorechazado, cBuroPilotoTestig, vclavereferencia1, vtipo, vclientenuevo, cModeloCel, vrumboreferencia, vcreditojoven, cSexoReferencia, vrumbo, cSexoReferencia2, vcasapropia, vsexo, vestadocivil, cUnidadHabit, vmarcadatosin, vflagentregotarjeta, vescolaridad, vtiposueldo, vsituacionespecial, vclaveautrechaza, vTipoOrigen, vclavereferencia2, cSexoConyuge, vrumbotrabajoconyuge, vrumboreferencia2, vflagnoreconocehuella, vrumbotrabajo, cflaguht, vclaveconyugefamilia, vpuesto CHAR(1);
DEFINE cFechaConsBuro, cfechadesdecuandovive, cCasa, cfechaantiguedtrab, cFecha_hoy, cCasareferencia2, cCasatrabajo, vfolioconcir, cfechaaltacte, cCasareferencia, cfechanac, cCasatrabajoconyuge CHAR(10);
DEFINE vNombre CHAR(104);
DEFINE cNoIMSS CHAR(12);
DEFINE vrfc CHAR(13);
DEFINE vcurp, vclaveelector, cNoFm3 CHAR(18);
DEFINE cfechamovto CHAR(19);
DEFINE vclaveidentificacion, vTipo_Dir, cMarcarConsultado, cMarcaHit, vcveburo, cFlagConsBuro CHAR(2);
DEFINE vclienteconyuge, vlugartrabajoconyuge, vclientereferencia, vclientereferencia2, cClienteReferencia2bcpl, vcliente_ref, cClienteReferencia1bcpl, vlugartrabajo, vnumcte, vnumerosolicituddecredito, vfolio, cClienteConyugebcpl CHAR(20);
DEFINE vapellidopaternoreferencia2, cApellCasada, vnombreunoreferencia, vnombredosreferencia2, vnombreunoreferencia2, vapellidomaternoreferencia2, vapellidomaternoreferencia, vapellidopaternoconyuge, vapellidopaternoreferencia, vnombredosreferencia, vnombreunoconyuge, vnombre1, vapellidomaternoconyuge, vnombre2, vnombredosconyuge, vapell_materno, vapell_paterno CHAR(26);
DEFINE cPais, cDelegMunicip, cEstado, cNacionalidad CHAR(3);
DEFINE vdeptoointeriorreferencia2, cNumInterior, cFolioSucursal, vdeptointerior, vdeptoointeriorreferencia, vdeptoointeriorconyuge, vdeptoointeriortrabajo, vfolioaut CHAR(4);
DEFINE ventrecallesreferencia1, ventrecallesconyuge, ventrecallestrabajo, ventrecalles, ventrecallesreferencia2 CHAR(40);
DEFINE vTipoProducto, vcodret CHAR(5);
DEFINE cDescripElemento CHAR(50);
DEFINE vCodRetorno Char(6);
DEFINE cEmail CHAR(60);
DEFINE vniptitular, vnipadicional CHAR(7);
DEFINE videntificacion CHAR(8);
DEFINE vcomplementoreferencia2, vcomplementoreferencia, vcomplementoconyuge, vcomplemento, vcomplementotrabajo CHAR(80);
DEFINE vfolioconsulta CHAR(9);
DEFINE dFechaAlta, vfechaaltacliente, dFechaConsBuro, vfechanacimiento, vfechamovto, vFecha_Hoy DATE;
DEFINE vHora DATETIME HOUR TO FRACTION(3);
DEFINE dEvaluacion2, dEvaluacion1 DECIMAL(5,2);
DEFINE vtelefono, vtelefonotrabajoconyuge, vtelefonoreferencia2, vtelefonotrabajo, vtelefonoreferencia, vtelefonocelularconyuge, vtelefonocelularreferencia, vtelefonocelular, vtelefonocelularreferencia2 INT8;
DEFINE vreferencia2, vcoloniareferencia2, vfoliotienda, iEmpleadoSubCob, vflagactualizacion, vreposicion, iRowId, vciudadreferencia2, vempleadoautorizo, vreferencia3, iEmpleadoGteAutori, vfolioanterior, iNumerocasaref2, vcallereferencia2, vefectuo, vcolonia, iNumerocasa, vcalle, iContConsBuro, iIngreso, vcoloniabanco, iPuntuacion, iValor, iNumerocasaref, vcallereferencia, vcoloniareferencia, vciudadreferencia, iMontoIngMensual, iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, vpersonasvivenendomicilio, vcoloniatrabajo, vcalletrabajo, iNumerocasatrabajo, vciudadbanco, vciudad, iElemento, iSecuencia, iSqlErr, vextensiontrabajo, iAniosHabita, vEdad, iCompromisosSic, vciudadtrabajo, iNumerocasaconyuge, vcalletrabajoconyuge, vcoloniaconyuge, vciudadconyuge, iRefSecuencias, iCuentaRegistros, iElementoScoring INTEGER;
DEFINE vsSQL LVARCHAR(32000);
DEFINE vflaguhr, iFlagLineaCredEsp, sFlagCapCobranza, sPropNegocio, vopcionpuesto, sParCelulares, vflaguhy, vflaguhr2, vuhymanzana, vuhyotros, vuhyandador, vuhtetapa, vuhyetapa, vuhtotros, vuhtmanzana, vflaguht, vuhrmanzana2, vuhylote, vuhrandador2, vuhretapa2, vuhyedificio, vuhyentrada, vuhrentrada, sParPrestamo, vuhrlote2, vuhredificio2, sParAltoRiesgo, sFlagCapHuella, vuhtentrada, vcausasituacionespecial, vuhrentrada2, vingresomensual, vlimitecredito, vpersonastrabajan, vnumerodependientes, vtiporeposicion, vuhrlote, vuhredificio, vuhretapa, sFlagTestParametrico, vSubopcionpuestoext, vtiendafolio, vNumempleadosext, vOpcionpuestoext, vuhrotros, vPuestoext, vSubopcionpuesto, vuhcentrada, vuhcedificio, vuhclote, vuhcetapa, vuhcandador, vuhcotros, vuhcmanzana, vflaguhc, vNumempleados, vTiposueldoext, vuhrmanzana, vnegocio, vuhtedificio, vuhrandador, vuhtlote, vuhtandador, vsubnegocio, vSistsegsocial, vuhrotros2, vclaveproducto, vtiendafolioanterior, vcaja SMALLINT;
DEFINE vletrasnumtrabconyuge, vletrasnumcasaref2, vletrasnumtrabajo, vletrasnumcasa, vletrasnumcasaref VARCHAR(10);
DEFINE cRespuesta VARCHAR(20);
LET vClave = '';
LET vcaja = 100;
LET varea = 'N';
LET vcliente_ref = '0';
LET vnombre1 = '';
LET vnombre2 = '';
LET vapell_paterno = '';
LET vapell_materno = '';
LET vcurp = '';
LET vclaveelector = '';
LET vclaveidentificacion = '';
LET videntificacion = '';
LET vciudad = 0;
LET vcolonia = 0;
LET vcalle = 0;
LET iNumerocasa = 0;
LET vdeptointerior = '';
LET vrumbo = '';
LET vcomplemento = '';
LET ventrecalles = '';
LET vflaguhc = 0;
LET vuhcmanzana = 0;
LET vuhcotros = 0;
LET vuhcandador = 0;
LET vuhcetapa = 0; 
LET vuhclote  = 0;
LET vuhcedificio = 0;
LET vuhcentrada = 0;
LET vtelefono = 0;
LET vtelefonocelular = 0;
LET vcasapropia = '';
LET vniptitular = '';
LET vnipadicional = '';
LET vsexo = '';
LET vestadocivil = '';
LET cfechanac = '1900/01/01';
LET cfechadesdecuandovive = '1900/01/01';
LET vpersonasvivenendomicilio = 0;
LET vescolaridad = '';
LET vtiposueldo = '';
LET vnumerodependientes = 0;
LET vpersonastrabajan = 0;
LET vlimitecredito = 0;
LET vingresomensual = 0;
LET vsituacionespecial = '';
LET vcausasituacionespecial = 0;
LET vclaveautrechaza = '0';
LET vaceptadosupervisadorechazado = 'P';
LET vclientenuevo = '';
LET vcreditojoven = '';
LET vlugartrabajo = '';
LET vciudadtrabajo = 0;
LET vcoloniatrabajo  = 0;
LET vcalletrabajo  = 0;
LET iNumerocasatrabajo = 0;
LET vdeptoointeriortrabajo = '';
LET vrumbotrabajo = '';
LET vcomplementotrabajo = '';
LET ventrecallestrabajo = '';
LET vflaguht = 0;
LET vuhtmanzana = 0;
LET vuhtotros = 0;
LET vuhtandador = 0;
LET vuhtetapa = 0;
LET vuhtlote = 0;
LET vuhtedificio = 0;
LET vuhtentrada = 0;
LET vtelefonotrabajo = 0;
LET vextensiontrabajo = 0;
LET vpuesto = '0';
LET vopcionpuesto = 0;
LET cfechaantiguedtrab = '1900/01/01'; 
LET vclienteconyuge = '0';
LET vnombreunoconyuge = '';
LET vnombredosconyuge = '';
LET vapellidopaternoconyuge = '';
LET vapellidomaternoconyuge = '';
LET cSexoConyuge = '';
LET vlugartrabajoconyuge = '';
LET vciudadconyuge = 0;
LET vcoloniaconyuge = 0;
LET vcalletrabajoconyuge = 0;
LET iNumerocasaconyuge = 0;
LET vdeptoointeriorconyuge = '';
LET vrumbotrabajoconyuge = '';
LET vcomplementoconyuge = '';
LET ventrecallesconyuge = '';
LET vflaguhy = 0;
LET vuhymanzana = 0;
LET vuhyotros = 0;
LET vuhyandador  = 0;
LET vuhyetapa = 0;
LET vuhylote = 0;
LET vuhyedificio = 0;
LET vuhyentrada = 0;
LET vtelefonotrabajoconyuge = 0;
LET vtelefonocelularconyuge = 0;
LET vclaveconyugefamilia = 'E';
LET vclientereferencia = '0';
LET vnombreunoreferencia = '';
LET vnombredosreferencia = '';
LET vapellidopaternoreferencia = '';
LET vapellidomaternoreferencia = '';
LET cSexoReferencia = '';
LET vciudadreferencia = 0;
LET vcoloniareferencia = 0;
LET vcallereferencia = 0;
LET iNumerocasaref = 0;
LET vdeptoointeriorreferencia = '';
LET vrumboreferencia = '';
LET vcomplementoreferencia = '';
LET ventrecallesreferencia1 = '';
LET vflaguhr = 0;
LET vuhrmanzana = 0 ;
LET vuhrotros = 0 ;
LET vuhrandador = 0;
LET vuhretapa = 0;
LET vuhrlote = 0;
LET vuhredificio = 0;
LET vuhrentrada = 0;
LET vtelefonoreferencia = 0;
LET vtelefonocelularreferencia = 0;
LET vclavereferencia1 = '';
LET vclientereferencia2 = '0';
LET vnombreunoreferencia2 = '';
LET vnombredosreferencia2 = '';
LET vapellidopaternoreferencia2 = '';
LET vapellidomaternoreferencia2 = '';
LET cSexoReferencia2 = '';
LET vciudadreferencia2 = 0;
LET vcoloniareferencia2 = 0;
LET vcallereferencia2 = 0;
LET iNumerocasaref2 = 0;
LET vdeptoointeriorreferencia2 = '';
LET vrumboreferencia2 = '';
LET vcomplementoreferencia2 = '';
LET ventrecallesreferencia2 = '';
LET vflaguhr2 = 0;
LET vuhrmanzana2 = 0;
LET vuhrotros2 = 0;
LET vuhrandador2 = 0;
LET vuhretapa2 = 0;
LET vuhrlote2 = 0;
LET vuhredificio2 = 0;
LET vuhrentrada2 = 0;
LET vtelefonoreferencia2 = 0;
LET vtelefonocelularreferencia2 = 0;
LET vclavereferencia2 = '';
LET vreferencia2 = 0;
LET vreferencia3 = 0;
LET vmarcadatosin = '';
LET vtiporeposicion = 0;
LET vreposicion = 0;
LET vflagentregotarjeta = '';
LET vefectuo = 0;
LET vtiendafolio = 0;
LET vfolio = '0';
LET cfechaaltacte = '1900/01/01';
LET vflagnoreconocehuella = '';
LET vfoliotienda = 0;
LET vrfc = ''; 
LET vcveburo = '';
LET vfolioaut = '';
LET vfolioconsulta = '';
LET vfolioconcir = '';
LET vnegocio = 0;
LET vsubnegocio = 0;
LET vempleadoautorizo = 0;
LET vtipo = '';
LET cfechamovto = '1900/01/01';
LET vnumerosolicituddecredito = '';
LET vnumcte = '';
LET vtiendafolioanterior = 0;
LET vfolioanterior = 0;
LET vclaveproducto = 6500;
LET vflagactualizacion = 0;
LET vSistsegsocial = 0;
LET vTiposueldoext = 0;
LET vNumempleados = 0;
LET vSubopcionpuesto = 99;
LET vPuestoext = 0;
LET vOpcionpuestoext = 0;
LET vNumempleadosext = 0;
LET vSubopcionpuestoext = 0;
LET vTipoOrigen = 'G';
LET vTipoProducto = '01000';
LET iEmpleadoSubCob = 0;
LET sFlagCapHuella = 1;
LET cMarcarConsultado = '';
LET sFlagTestParametrico = 0;
LET sFlagCapCobranza = 0;
LET iEmpleadoGteAutori = 0;
LET cFlagConsBuro = '';
LET cBuroPilotoTestig = '';
LET cNacionalidad = '';
LET cNoFm3 = '';
LET cEmail = '';
LET cApellCasada = '';
LET cPais = '';
LET cNoIMSS = '';
LET cEstado = '';
LET cDelegMunicip = '';
LET cNumInterior = '';
LET sPropNegocio = 0;
LET sParCelulares = 0; 
LET sParAltoRiesgo = 0;
LET sParPrestamo = 0;
LET cModeloCel = '1';
LET dFechaConsBuro = DATE(1);
LET cFechaConsBuro = '';
LET iMontoIngMensual = 0; 
LET iCapSistematicabono = 0;
LET iTopeAbonoCoppel = 0;
LET iLineaCrediTope = 0;
LET iCapMaximaAbono = 0;
LET iCapRealAbono = 0;
LET iLineaCredReal = 0;
LET iCompromisosSic = 0;
LET iFlagLineaCredEsp = 0;
LET cClienteConyugebcpl = '';
LET cClienteReferencia1bcpl = '';
LET cClienteReferencia2bcpl = '';
LET vletrasnumcasa = "";
LET vletrasnumtrabajo = "";
LET vletrasnumtrabconyuge = "";
LET vletrasnumcasaref = "";
LET vletrasnumcasaref2 = "";
LET cFolioSucursal = '0';
LET vHora = '';
LET cflaguht = '';
LET vfechanacimiento = DATE(1); 
LET iAniosHabita = 0;
LET vfechaaltacliente = DATE(1);
LET vfechamovto = DATE(1);
LET cCasatrabajo = ''; 
LET cCasatrabajoconyuge = '';
LET cCasareferencia = '';
LET cCasareferencia2 = '';
LET cUnidadHabit = '';
LET vTipo_Dir = '';
LET vFecha_Hoy = DATE(1);
LET vNombre = '';
LET vEdad = 0;
LET vsSQL = "";
LET vCodRetorno = '000000';
LET dFechaAlta = DATE(1);
LET iValor = 0;
LET iIngreso = 0;
LET iPuntuacion = 0;
LET cFecha_hoy = '1900/01/01';
LET dEvaluacion1 = 0;
LET dEvaluacion2 = 0;
LET iSecuencia = 0;
LET cMarcaHit = '';
LET iElemento = 0;
LET vcodret = '';
LET vciudadbanco = 0;
LET vcoloniabanco = 0;
LET iContConsBuro = 0;
LET iRefSecuencias = 0;
LET iElementoScoring = 0;
LET cDescripElemento = '';
LET iCuentaRegistros = 0;
LET cCasa = '';
LET cRespuesta = '';
LET iRowId = 0;
--Set debug file to '/tmp/sp_generaarchivoaltasolicitud2.out';
--trace on;
BEGIN
	ON EXCEPTION
		SET iSqlErr
		Set debug file to '/RESPALDOSNEW/sp_generaarchivoaltasolicitud2.out';
		trace on;
            	LET vnumerosolicituddecredito = vnumerosolicituddecredito;
		IF iSqlErr <> 0 THEN
			LET vCodRetorno = iSqlErr;
			RETURN vCodRetorno;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		SELECT fecha_hoy INTO vFecha_Hoy FROM bdinteg:"informix".si_fechas;
		IF vFecha_Hoy = mdy(1,1,1900) OR vFecha_Hoy IS NULL THEN
			LET vCodRetorno = '000002';
			LET iCuentaRegistros = 2;
		ELSE
			FOREACH
				SELECT num_solicitud, numcte, fecha_insert, sucursal 
				INTO vnumerosolicituddecredito, vnumcte, vfechaaltacliente, cFolioSucursal
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE num_producto = '6500' AND fecha_insert = pFechaAct AND status_solicitud NOT IN ('PC', 'AN')
				IF vnumerosolicituddecredito <> '' OR vnumcte <> '' THEN 
					EXECUTE PROCEDURE "informix".consedadcte(pempresa, vnumcte) INTO vCodRetorno, vNombre, vEdad;
					SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, cte.numcte, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(cte.ejecut_autoriza) = 'V' THEN cte.ejecut_autoriza::INTEGER ELSE 0 END, cte.rfc, cte.fecha_insert, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(cte.ejecut_autoriza) = 'V' THEN cte.ejecut_autoriza::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(cte.string2)= 'V' THEN cte.string2::INTEGER ELSE 0 END, cte.apell_casada
					INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vnumcte, vefectuo, vrfc, 
					vfechamovto, vefectuo, vpersonasvivenendomicilio, cApellCasada
					FROM bdinteg:"informix".si_cliente cte
					WHERE cte.empresa = pempresa AND cte.numcte = vnumcte;
					SELECT iden.estado_civil, REPLACE(iden.curp,'|',' '), iden.numidentifi, iden.codidentifi, iden.habita_en, iden.sexo, iden.fecha_nac, iden.escolaridad, iden.nacionalidad, iden.no_fm3, iden.no_imss
					INTO vestadocivil, vcurp, vclaveelector, vclaveidentificacion, vcasapropia, vsexo, vfechanacimiento, vescolaridad, cNacionalidad, cNoFm3, cNoIMSS
					FROM bdinteg:"informix".si_ctepf iden WHERE iden.numcte = vnumcte;
                    SELECT correo_elec INTO cEmail FROM bdinteg:"informix".si_correos WHERE numcte = vnumcte AND status_correo = 'A';
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerociudad) = 'V' THEN dir.numerociudad::INTEGER ELSE 0 END,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocolonia) = 'V' THEN dir.numerocolonia::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocalle) = 'V' THEN dir.numerocalle::INTEGER ELSE 0 END,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numeroextcalle) = 'V' THEN dir.numeroextcalle::INTEGER ELSE 1 END,
					NVL(TRIM(REPLACE(dir.numerointcalle,'|',' ')),''),dir.puntocardinal,NVL(TRIM(REPLACE(dir.observaciones,'|',' ')),''),NVL(TRIM(REPLACE(dir.entre_calles,'|',' ')),''),dir.unidadhabitac, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.manzana) = 'V' THEN dir.manzana::SMALLINT ELSE 0 END,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.otros) = 'V' THEN dir.otros::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.andador) = 'V' THEN dir.andador::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.etapa) = 'V' THEN dir.etapa::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.lote ) = 'V' THEN dir.lote::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.edificio) = 'V' THEN dir.edificio::SMALLINT ELSE 0 END,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.entrada) = 'V' THEN dir.entrada::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(tel1.telefono) = 'V' THEN tel1.telefono::INT8 ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(tel2.telefono) = 'V' THEN tel2.telefono::INT8 ELSE 0 END, dir.tipo_dir, 
					NVL(TRIM(REPLACE(dir.numerointcalle,'|',' ')),''),	dir.pais, dir.estado  
					INTO vciudadbanco, vcoloniabanco, vcalle, iNumerocasa, vdeptointerior, vrumbo, vcomplemento, ventrecalles, cUnidadHabit, vuhcmanzana, 
					vuhcotros,vuhcandador, vuhcetapa, vuhclote, vuhcedificio, vuhcentrada, vtelefono, vtelefonocelular, vTipo_Dir, cNumInterior, cPais, cEstado
					FROM bdinteg:"informix".si_direcciones_actual dir
                    LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
                    LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
					WHERE dir.numcte = vnumcte AND dir.tipo_dir = '1'; 
					--- AND dir.secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = vnumcte AND tipo_dir = '1');				
					IF iNumerocasa = 0 THEN 
						LET iNumerocasa = 1;
					END IF;
					SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO vciudad, vcolonia
					FROM bdinteg:"informix".si_catzonas
					WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
					IF NVL(vciudad, 0) = 0 THEN
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END INTO vciudad FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
						AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
					END IF;
					IF NVL(vcolonia, 0) = 0 THEN
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END INTO vcolonia FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
						AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
					END IF;
					SELECT ing.nombre_empresa, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(ing.claveopcionpuesto) = 'V' THEN ing.claveopcionpuesto::SMALLINT ELSE 0 END,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(ing.clavesubopcionpuesto) = 'V' THEN ing.clavesubopcionpuesto::SMALLINT ELSE 0 END --ing.ingreso_mensual
					INTO vlugartrabajo, vopcionpuesto, vSubopcionpuesto --vingresomensual
					FROM bdinteg:"informix".si_ingresos ing
					WHERE ing.numcte = vnumcte
					AND ing.sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = vnumcte AND tipo_ingreso = 'T');
					IF NVL(vopcionpuesto, '') = '' THEN LET vopcionpuesto = '0'; END IF;
					IF NVL(vSubopcionpuesto, '') = '' THEN LET vSubopcionpuesto = '99'; END IF;
					SELECT tp_ingreso INTO vtiposueldo FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud = vnumerosolicituddecredito;
					IF cUnidadHabit = 'S' THEN 
						LET vflaguhc = 1;
					ELSE
						LET vflaguhc= 0;
					END IF;
					SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
					LET cfechanac = YEAR(vfechanacimiento)||"/"||LPAD(MONTH(vfechanacimiento),2,0)||"/"||LPAD(DAY(vfechanacimiento),2,0);
					LET cfechaaltacte = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,0)||"/"||LPAD(DAY(vfechaaltacliente),2,0);
					IF pFechaAct <> vFecha_Hoy THEN
						LET cfechamovto = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
					ELSE
						LET cfechamovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
					END IF;					
					LET vcreditojoven = '';
					IF vsexo = 'M' THEN
						IF vEdad >= 16 AND vEdad <= 20 THEN 
							LET vcreditojoven = 'J';
						END IF;
					ELSE
						IF  vsexo = 'F' THEN
							IF vEdad >= 16 AND vEdad <= 17 THEN 
								LET vcreditojoven = 'J';
							END IF;
						END IF;
					END IF;
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerociudad) = 'V' THEN dir.numerociudad::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocolonia) = 'V' THEN dir.numerocolonia::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocalle) = 'V' THEN dir.numerocalle::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numeroextcalle) = 'V' THEN dir.numeroextcalle::INTEGER ELSE 1 END, 
					NVL(TRIM(REPLACE(dir.numerointcalle,'|',' ')),''), dir.puntocardinal,NVL(TRIM(REPLACE(dir.observaciones,'|',' ')),''),NVL(TRIM(REPLACE(dir.entre_calles,'|',' ')),''),dir.unidadhabitac,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.manzana) = 'V' THEN dir.manzana::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.otros) = 'V' THEN dir.otros::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.andador) = 'V' THEN dir.andador::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.etapa) = 'V' THEN dir.etapa::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.lote ) = 'V' THEN dir.lote::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.edificio) = 'V' THEN dir.edificio::SMALLINT ELSE 0 END,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.entrada) = 'V' THEN dir.entrada::SMALLINT ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(tel3.telefono) = 'V' THEN tel3.telefono::INT8 ELSE 0 END,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(tel3.extension) = 'V' THEN tel3.extension ::INTEGER ELSE 0 END
					INTO vciudadbanco,vcoloniabanco,vcalletrabajo,iNumerocasatrabajo,vdeptoointeriortrabajo, vrumbotrabajo,
					vcomplementotrabajo,ventrecallestrabajo,cflaguht,vuhtmanzana, vuhtotros,vuhtandador,vuhtetapa,vuhtlote,vuhtedificio,
					vuhtentrada,vtelefonotrabajo,vextensiontrabajo					
					FROM bdinteg:"informix".si_cliente cte
                    INNER JOIN bdinteg:"informix".si_direcciones_actual dir ON ( cte.numcte = dir.numcte AND dir.tipo_dir = '2' )
                    LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON ( tel3.numcte = cte.numcte AND tel3.tipo_tel = 3 )
					WHERE cte.numcte = vnumcte;
					--- AND	dir.secuencia = (SELECT NVL (MAX(secuencia),0)FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = vnumcte AND  tipo_dir = '2');
					IF iNumerocasatrabajo = 0 THEN LET iNumerocasatrabajo = 1; END IF;
					IF NVL(vcomplementotrabajo, '') = '' THEN LET vcomplementotrabajo = 'E'; END IF;
					SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO vciudadtrabajo, vcoloniatrabajo
					FROM bdinteg:"informix".si_catzonas
					WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
					IF NVL(vciudadtrabajo, 0) = 0 THEN
						--DSB 2012/07/26
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END INTO vciudadtrabajo FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
						AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
					END IF;
					IF NVL(vcoloniatrabajo, 0) = 0 THEN
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END INTO vcoloniatrabajo FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
						AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
					END IF;									
					IF cflaguht = 'S' THEN
						LET vflaguht = 1;
					ELSE
						LET vflaguht = 0;
					END IF;		
					LET cClienteConyugebcpl = '';
					LET cClienteReferencia1bcpl = '';
					LET cClienteReferencia2bcpl = '';
					IF 	vestadocivil = 'C' THEN
						LET vclaveconyugefamilia = 'E';
						SELECT cte2.numcte_banco, cte2.nombre1, cte2.nombre2, cte2.apell_paterno, cte2.apell_materno, cte2.parentesco, cte2.sexo, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(cte2.secuencia) = 'V' THEN cte2.secuencia::INTEGER ELSE 0 END
						INTO vclienteconyuge,vnombreunoconyuge,vnombredosconyuge,vapellidopaternoconyuge,vapellidomaternoconyuge,
						vclaveconyugefamilia,cSexoConyuge,iRefSecuencias
						FROM bdinteg:"informix".si_refclientes cte2
						WHERE cte2.empresa = pempresa AND cte2.numcte = vnumcte 
						AND cte2.secuencia = (SELECT NVL(MAX(secuencia),0) FROM bdinteg:"informix".si_refclientes WHERE numcte = vnumcte AND parentesco = 'E') 
						AND cte2.parentesco = 'E' AND cte2.num_solicitud = vnumerosolicituddecredito;
						IF NVL(vclienteconyuge, '') = '' THEN LET vclienteconyuge = '0'; END IF;
						LET cClienteConyugebcpl = vnumcte;
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerociudad) = 'V' THEN dir2.numerociudad::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocolonia) = 'V' THEN dir2.numerocolonia::INTEGER ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocalle) = 'V' THEN dir2.numerocalle::INTEGER ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numeroextcalle) = 'V' THEN dir2.numeroextcalle::INTEGER ELSE 1 END, 
						NVL(TRIM(REPLACE(dir2.numerointcalle,'|',' ')),' '),dir2.puntocardinal,NVL(TRIM(REPLACE(dir2.observaciones,'|',' ')),''),NVL(TRIM(REPLACE(dir2.entre_calles,'|',' ')),''),dir2.unidadhabitac,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.manzana) = 'V' THEN dir2.manzana::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.otros) = 'V' THEN dir2.otros::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.andador) = 'V' THEN dir2.andador::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.etapa) = 'V' THEN dir2.etapa::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.lote ) = 'V' THEN dir2.lote::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.edificio) = 'V' THEN dir2.edificio::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.entrada) = 'V' THEN dir2.entrada::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono3) = 'V' THEN dir2.telefono3::INT8 ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono2) = 'V' THEN dir2.telefono2::INT8 ELSE 0 END
						INTO vciudadbanco,vcoloniabanco,vcalletrabajoconyuge,iNumerocasaconyuge,vdeptoointeriorconyuge,vrumbotrabajoconyuge,
						vcomplementoconyuge,ventrecallesconyuge,cflaguht,vuhymanzana,vuhyotros,vuhyandador,vuhyetapa,vuhylote,vuhyedificio,
						vuhyentrada,vtelefonotrabajoconyuge,vtelefonocelularconyuge
						FROM bdinteg:"informix".si_refdirecciones dir2
						WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;
						IF iNumerocasaconyuge = 0 THEN LET iNumerocasaconyuge = 1; END IF;
						IF NVL(vcomplementoconyuge, '') = '' THEN LET vcomplementoconyuge = 'E'; END IF;
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)}
						CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
						INTO vciudadconyuge, vcoloniaconyuge
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						IF NVL(vciudadconyuge, 0) = 0 THEN
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END INTO vciudadconyuge FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
						END IF;
						IF NVL(vcoloniaconyuge, 0) = 0 THEN
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END INTO vcoloniaconyuge FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
						END IF;
						SELECT ing.nombre_empresa
						INTO vlugartrabajoconyuge
						FROM bdinteg:"informix".si_ingresos ing
						WHERE ing.numcte = vnumcte AND ing.sec_ingreso =(SELECT MAX(sec_ingreso)FROM bdinteg:"informix".si_ingresos WHERE numcte = vnumcte);
						IF cflaguht = 'S' THEN
							LET vflaguhy = 1;
						ELSE
							LET vflaguhy = 0;
						END IF;
						SELECT cte2.numcte,cte2.nombre1,cte2.nombre2,cte2.apell_paterno,cte2.apell_materno,cte2.parentesco,cte2.sexo,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(cte2.secuencia) = 'V' THEN cte2.secuencia::INTEGER ELSE 0 END
						INTO vclientereferencia2,vnombreunoreferencia2,vnombredosreferencia2,vapellidopaternoreferencia2,vapellidomaternoreferencia2,
						vclavereferencia2,cSexoReferencia2,iRefSecuencias
						FROM bdinteg:"informix".si_refclientes cte2
						WHERE cte2.empresa = '001' AND cte2.numcte = vnumcte
						AND cte2.secuencia = (SELECT NVL(MAX(secuencia), 0) FROM bdinteg:"informix".si_refclientes WHERE numcte = vnumcte AND parentesco <> 'E')
						AND cte2.parentesco <> 'E' AND cte2.num_solicitud = vnumerosolicituddecredito;
						IF NVL(vclientereferencia2, '') = '' THEN LET vclientereferencia2 = '0'; END IF;
						LET cClienteReferencia2bcpl = vnumcte;
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerociudad) = 'V' THEN dir2.numerociudad::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocolonia) = 'V' THEN dir2.numerocolonia::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocalle) = 'V' THEN dir2.numerocalle::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numeroextcalle) = 'V' THEN dir2.numeroextcalle::INTEGER ELSE 1 END,
						NVL(TRIM(REPLACE(dir2.numerointcalle,'|',' ')),''),dir2.puntocardinal,NVL(TRIM(REPLACE(dir2.observaciones,'|',' ')),''),NVL(TRIM(REPLACE(dir2.entre_calles,'|',' ')),''),dir2.unidadhabitac,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.manzana) = 'V' THEN dir2.manzana::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.otros) = 'V' THEN dir2.otros::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.andador) = 'V' THEN dir2.andador::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.etapa) = 'V' THEN dir2.etapa::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.lote ) = 'V' THEN dir2.lote::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.edificio) = 'V' THEN dir2.edificio::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.entrada) = 'V' THEN dir2.entrada::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono1) = 'V' THEN dir2.telefono1::INT8 ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono2) = 'V' THEN dir2.telefono2::INT8 ELSE 0 END
						INTO vciudadbanco,vcoloniabanco,vcallereferencia2,iNumerocasaref2,vdeptoointeriorreferencia2,vrumboreferencia2,
						vcomplementoreferencia2,ventrecallesreferencia2,cflaguht,vuhrmanzana2,vuhrotros2,vuhrandador2,vuhretapa2,vuhrlote2,vuhredificio2,
						vuhrentrada2,vtelefonoreferencia2,vtelefonocelularreferencia2
						FROM bdinteg:"informix".si_refdirecciones dir2
						WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;
						IF iNumerocasaref2 = 0 THEN LET iNumerocasaref2 = 1; END IF;
						IF NVL(vcomplementoreferencia2, '') = '' THEN LET vcomplementoreferencia2 = 'E'; END IF;
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
						INTO vciudadreferencia2, vcoloniareferencia2
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						IF NVL(vciudadreferencia2, 0) = 0 THEN
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END INTO vciudadreferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
						END IF;
						IF NVL(vcoloniareferencia2, 0) = 0 THEN
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END INTO vcoloniareferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
						END IF;												
						IF cflaguht = 'S' THEN
							LET vflaguhr2 = 1;
						ELSE
							LET vflaguhr2 = 0;
						END IF;
					END IF;
					IF 	vestadocivil <> 'C' THEN
						LET vclaveconyugefamilia = '';
						SELECT cte2.numcte,cte2.nombre1,cte2.nombre2,cte2.apell_paterno,cte2.apell_materno,cte2.parentesco,cte2.sexo,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(cte2.secuencia) = 'V' THEN cte2.secuencia::INTEGER ELSE 0 END
						INTO vclientereferencia,vnombreunoreferencia,vnombredosreferencia,vapellidopaternoreferencia,vapellidomaternoreferencia,
						vclavereferencia1,cSexoReferencia,iRefSecuencias
						FROM bdinteg:"informix".si_refclientes cte2
						WHERE cte2.empresa = pempresa AND cte2.numcte = vnumcte
						AND cte2.secuencia = (SELECT NVL(MAX(secuencia-1),0) FROM bdinteg:"informix".si_refclientes WHERE numcte = vnumcte AND parentesco <> 'E')
						AND cte2.parentesco <> 'E' AND cte2.num_solicitud = vnumerosolicituddecredito;
						IF NVL(vclientereferencia, '') = '' THEN
							LET vclientereferencia = '0';
						END IF;
						LET cClienteReferencia1bcpl = vnumcte;
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerociudad) = 'V' THEN dir2.numerociudad::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocolonia) = 'V' THEN dir2.numerocolonia::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocalle) = 'V' THEN dir2.numerocalle::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numeroextcalle) = 'V' THEN dir2.numeroextcalle::INTEGER ELSE 1 END,
						NVL(TRIM(REPLACE(dir2.numerointcalle,'|',' ')),''),dir2.puntocardinal,NVL(TRIM(REPLACE(dir2.observaciones,'|',' ')),''),NVL(TRIM(REPLACE(dir2.entre_calles,'|',' ')),''),dir2.unidadhabitac,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.manzana) = 'V' THEN dir2.manzana::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.otros) = 'V' THEN dir2.otros::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.andador) = 'V' THEN dir2.andador::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.etapa) = 'V' THEN dir2.etapa::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.lote ) = 'V' THEN dir2.lote::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.edificio) = 'V' THEN dir2.edificio::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.entrada) = 'V' THEN dir2.entrada::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono1) = 'V' THEN dir2.telefono1::INT8 ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono2) = 'V' THEN dir2.telefono2::INT8 ELSE 0 END
						INTO vciudadbanco,vcoloniabanco,vcallereferencia,iNumerocasaref,vdeptoointeriorreferencia,vrumboreferencia,
						vcomplementoreferencia,ventrecallesreferencia1,cflaguht,vuhrmanzana,vuhrotros,vuhrandador,vuhretapa,vuhrlote,vuhredificio,
						vuhrentrada,vtelefonoreferencia,vtelefonocelularreferencia
						FROM bdinteg:"informix".si_refdirecciones dir2
						WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;
						IF iNumerocasaref = 0 THEN LET iNumerocasaref = 1; END IF;
						IF NVL(vcomplementoreferencia, '') = '' THEN LET vcomplementoreferencia = 'E'; END IF;
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)}
						CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
						INTO vciudadreferencia, vcoloniareferencia
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						IF NVL(vciudadreferencia, 0) = 0 THEN
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END INTO vciudadreferencia FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
						END IF;
						IF NVL(vcoloniareferencia, 0) = 0 THEN
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END INTO vcoloniareferencia FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
						END IF;				
						IF cflaguht = 'S' THEN
							LET vflaguhr = 1;
						ELSE
							LET vflaguhr = 0;
						END IF;
						EXECUTE PROCEDURE bdinteg:"informix".sp_EsNumerico (cCasareferencia) INTO cRespuesta; -- Sp para validar el tipo de caracter(numero o letra)
						IF cRespuesta = 'F' THEN 
							LET iNumerocasaref = 1;
						ELSE
							LET iNumerocasaref = cCasareferencia;
						END IF;
						SELECT cte2.numcte,cte2.nombre1,cte2.nombre2,cte2.apell_paterno,cte2.apell_materno,cte2.parentesco,cte2.sexo,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(cte2.secuencia) = 'V' THEN cte2.secuencia::INTEGER ELSE 0 END
						INTO vclientereferencia2,vnombreunoreferencia2,vnombredosreferencia2,vapellidopaternoreferencia2,vapellidomaternoreferencia2,
						vclavereferencia2,cSexoReferencia2,iRefSecuencias
						FROM bdinteg:"informix".si_refclientes cte2
						WHERE cte2.empresa = pempresa AND cte2.numcte = vnumcte
						AND cte2.secuencia = (SELECT NVL(MAX(secuencia),0) FROM bdinteg:"informix".si_refclientes WHERE numcte = vnumcte AND parentesco <> 'E')
						AND cte2.parentesco <> 'E' AND cte2.num_solicitud = vnumerosolicituddecredito;
						IF NVL(vclientereferencia2, '') = '' THEN LET vclientereferencia2 = '0'; END IF;
						LET cClienteReferencia2bcpl = vnumcte;
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerociudad) = 'V' THEN dir2.numerociudad::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocolonia) = 'V' THEN dir2.numerocolonia::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocalle) = 'V' THEN dir2.numerocalle::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numeroextcalle) = 'V' THEN dir2.numeroextcalle::INTEGER ELSE 1 END,
						NVL(TRIM(REPLACE(dir2.numerointcalle,'|',' ')),''),dir2.puntocardinal,NVL(TRIM(REPLACE(dir2.observaciones,'|',' ')),''),NVL(TRIM(REPLACE(dir2.entre_calles,'|',' ')),''),dir2.unidadhabitac,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.manzana) = 'V' THEN dir2.manzana::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.otros) = 'V' THEN dir2.otros::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.andador) = 'V' THEN dir2.andador::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.etapa) = 'V' THEN dir2.etapa::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.lote ) = 'V' THEN dir2.lote::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.edificio) = 'V' THEN dir2.edificio::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.entrada) = 'V' THEN dir2.entrada::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono1) = 'V' THEN dir2.telefono1::INT8 ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono2) = 'V' THEN dir2.telefono2::INT8 ELSE 0 END
						INTO vciudadbanco,vcoloniabanco,vcallereferencia2,iNumerocasaref2,vdeptoointeriorreferencia2,vrumboreferencia2,
						vcomplementoreferencia2,ventrecallesreferencia2,cflaguht,vuhrmanzana2,vuhrotros2,vuhrandador2,vuhretapa2,vuhrlote2,vuhredificio2,
						vuhrentrada2,vtelefonoreferencia2,vtelefonocelularreferencia2
						FROM bdinteg:"informix".si_refdirecciones dir2
						WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;
						IF iNumerocasaref2 = 0 THEN LET iNumerocasaref2 = 1; END IF;
						IF NVL(vcomplementoreferencia2, '') = '' THEN LET vcomplementoreferencia2 = 'E'; END IF;
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)}
						CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
						INTO vciudadreferencia2, vcoloniareferencia2
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						IF NVL(vciudadreferencia2, 0) = 0 THEN
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END INTO vciudadreferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
						END IF;
						IF NVL(vcoloniareferencia2, 0) = 0 THEN
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END INTO vcoloniareferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
						END IF;
						IF cflaguht = 'S' THEN
							LET vflaguhr2 = 1;
						ELSE
							LET vflaguhr2 = 0;
						END IF;
					END IF;
					SELECT MAX(ROWID) INTO iRowId FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = vnumerosolicituddecredito;
					IF (SELECT NVL(COUNT(*), 0) FROM bdisolic:"informix".ss_os_solautdirecta WHERE num_solicitud = vnumerosolicituddecredito) >= 1 THEN
						LET vsituacionespecial = 'S';
						LET vcausasituacionespecial = 50;
					ELSE
						SELECT situacion_especial, case when bdinteg:"informix".sp_EsNumerico(causa_sitesp) = 'V' then causa_sitesp::integer else 0 end
						INTO vsituacionespecial, vcausasituacionespecial FROM bdisolic:"informix".ss_nuevo_parametrico WHERE ROWID = iRowId;
					END IF;
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(elemento) = 'V' THEN elemento::INTEGER ELSE 0 END 
					INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring
					WHERE grupo = 11 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
					SELECT rango_minimo INTO vnumerodependientes FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 11 AND seccion = 2 AND tpo_persona = '01' AND elemento = iElemento AND activa = 1;
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(elemento) = 'V' THEN elemento::INTEGER ELSE 0 END 
					INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring
					WHERE grupo = 39 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
					SELECT rango_minimo INTO vpersonastrabajan FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 39 AND seccion = 2 AND tpo_persona = '01' AND elemento = iElemento AND activa = 1;
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(elemento) = 'V' THEN elemento::INTEGER ELSE 0 END 
					INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring 
					WHERE empresa = pempresa AND grupo = 6 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
					SELECT rango_minimo INTO iElemento FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 6 AND seccion = 2 AND elemento = iElemento AND activa = 1;
					LET cfechadesdecuandovive = YEAR(vfechaaltacliente)-iElemento; 
					LET cfechadesdecuandovive = TRIM(cfechadesdecuandovive)||'/01/01';
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(elemento) = 'V' THEN elemento::INTEGER ELSE 0 END 
					INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring 
					WHERE empresa = pempresa AND grupo = 8 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
					SELECT rango_minimo INTO iElemento FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 8 AND seccion = 2 AND elemento = iElemento AND activa = 1;
					IF iElemento = -1 THEN
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(elemento) = 'V' THEN elemento::INTEGER ELSE 0 END 
						INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring 
						WHERE grupo = 7 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
						IF iElemento = 15 THEN --Estudiante
							LET cfechaantiguedtrab = YEAR(vfechanacimiento);
							LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||'/01/01';
						ELIF iElemento = 12 THEN --Ama de Casa
							LET cfechaantiguedtrab = SUBSTR(cfechadesdecuandovive, 1, 4);
							LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||'/01/01';
						ELIF iElemento = 6 OR iElemento = 17 THEN --Desempelado, Jubilado o Pensionado
							LET cfechaantiguedtrab = YEAR(vfechaaltacliente);
							LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||'/01/01';
						END IF;
					ELSE
						LET cfechaantiguedtrab = YEAR(vfechaaltacliente)-iElemento;
						LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||'/01/01';
					END IF;
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(elemento) = 'V' THEN elemento::INTEGER ELSE 0 END 
					INTO iElementoScoring FROM bdisolic:"informix".ss_detalle_scoring 
					WHERE grupo = '21' AND num_solicitud = vnumerosolicituddecredito;
					SELECT descripcion INTO cDescripElemento FROM bdisolic:"informix".ss_scoring_element 
					WHERE elemento = iElementoScoring AND grupo = '21' AND activa = 1;
					IF TRIM(cDescripElemento) = "No Estudió" THEN
						LET vescolaridad = '1';
					END IF;
					IF TRIM(cDescripElemento) = "Primaria" THEN
						LET  vescolaridad = '2';
					END IF;
					IF TRIM(cDescripElemento) = "Secundaria" THEN
						LET vescolaridad = '3';
					END IF;
					IF TRIM(cDescripElemento) = "Carrera Técnica" THEN
						LET vescolaridad = '4';
					END IF;
					IF TRIM(cDescripElemento) = "Preparatoria" THEN
						LET vescolaridad = '5';
					END IF;
					IF TRIM(cDescripElemento) = "Licenciatura o Superior" THEN
						LET vescolaridad = '6'; 
					END IF;
					SELECT secuencia INTO vfolio FROM bdisolic:"informix".ss_osclientesupervisar WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND fechasolicitud = fechasolicitud
					AND ROWID = (SELECT MAX(ROWID) FROM bdisolic:"informix".ss_osclientesupervisar WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito);
					IF NVL(vfolio, '') = '' THEN LET vfolio = '0'; END IF;
					SELECT NVL(institucion, ''), fecha_sic INTO cFlagConsBuro, dFechaConsBuro FROM bdisolic:"informix".ss_solicitudes_sic 
					WHERE numcte = vnumcte AND num_solicitud = vnumerosolicituddecredito
					AND ROWID = (SELECT MAX(ROWID) FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = vnumcte AND num_solicitud = vnumerosolicituddecredito);
					IF cFlagConsBuro = 'BC' OR cFlagConsBuro = 'CC' THEN
						LET cBuroPilotoTestig = 'P';
					ELSE
						LET cBuroPilotoTestig = 'T';
					END IF;
					IF NVL(dFechaConsBuro, '') <> '' THEN
						LET cFechaConsBuro = YEAR(dFechaConsBuro)||"/"||LPAD(MONTH(dFechaConsBuro),2,0)||"/"||LPAD(DAY(dFechaConsBuro),2,0);
					ELSE
						LET cFechaConsBuro = '1900/01/01';
					END IF;
					SELECT NVL(COUNT(*), 0) INTO iContConsBuro FROM bdisolic:"informix".ss_solicitudes_sic 
					WHERE numcte = vnumcte AND num_solicitud = vnumerosolicituddecredito;
					IF iContConsBuro <> 0 THEN
						LET cMarcarConsultado = 'CO';
					ELSE
						LET cMarcarConsultado = 'NC';
					END IF;
					SELECT MAX(ROWID) INTO iRowId FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = vnumerosolicituddecredito;
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ingreso_mensual) = 'V' THEN ingreso_mensual::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(cap_sistematica_abono) = 'V' THEN cap_sistematica_abono::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(tope_abonocoppel) = 'V' THEN tope_abonocoppel::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(lineacreditotope) = 'V' THEN lineacreditotope::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(capmaxima_abono) = 'V' THEN capmaxima_abono::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(capreal_abono) = 'V' THEN capreal_abono::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(lineacredito_real) = 'V' THEN lineacredito_real::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(compromisossic) = 'V' THEN compromisossic::INTEGER ELSE 0 END, 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(flaglineacreditoesp) = 'V' THEN flaglineacreditoesp::INTEGER ELSE 0 END
					INTO iMontoIngMensual, iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, iFlagLineaCredEsp
					FROM bdisolic:"informix".ss_nuevo_parametrico
					WHERE empresa = pempresa AND ROWID = iRowId;
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(valor) = 'V' THEN valor::INTEGER ELSE 0 END 
					INTO iValor FROM bdisolic:"informix".ss_param WHERE secuencia = 363;
					SELECT ingreso_mensual,evalua_cc INTO iIngreso,cMarcaHit FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito;
					LET vingresomensual = ((((NVL(iIngreso::DECIMAL(14,2),0))+(iValor/2)))/iValor)::SMALLINT;
					IF TRIM(NVL(cMarcaHit, '')) = 'X' THEN
						LET cMarcaHit = 'HT';
					ELSE	
						LET cMarcaHit = 'NH';
					END IF;
					IF vingresomensual < 1 THEN
						LET vingresomensual = 1;
					END IF;
					SELECT limitecredito INTO vlimitecredito FROM bdisolic:"informix".ss_nuevo_parametrico WHERE empresa = pempresa AND ROWID = iRowId;
					SELECT EVALUACION INTO dEvaluacion1 FROM bdisolic:"informix".ss_resumen_scoring WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND seccion = 1;
					SELECT EVALUACION INTO dEvaluacion2 FROM bdisolic:"informix".ss_resumen_scoring WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND seccion = 2;
					LET iPuntuacion = (dEvaluacion1+dEvaluacion2);
					IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
						IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						ELSE
							LET iSecuencia = (SELECT NVL(MAX(secuencia), 0) + 1  FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						END IF;
					ELSE
						IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						ELSE
							LET iSecuencia = 1;
						END IF;
					END IF;
					--dsb-17/09/2012 se llega hasta el maximo permitido por small int
					IF NVL(vextensiontrabajo,0) > 32767 THEN
						LET vextensiontrabajo = 0;
					END IF;
					LET vsSQL = vclave||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(vcliente_ref)||"|"||TRIM(NVL(vnombre1, ''))||"|"||TRIM(NVL(vnombre2, ''))||"|"||TRIM(NVL(vapell_paterno, ''))||"|"||TRIM(NVL(vapell_materno, ''))||"|"
							||TRIM(NVL(vcurp, ''))||"|"||TRIM(NVL(vclaveelector, ''))||"|"||TRIM(NVL(vclaveidentificacion, ''))||"|"||TRIM(videntificacion)||"|"||NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)||"|"||TRIM(NVL(vdeptointerior, ''))||"|"
							||TRIM(NVL(vrumbo, ''));
					LET vsSQL = vsSQL ||"|"||TRIM(NVL(vcomplemento, ' '))||"|"||TRIM(NVL(ventrecalles, ''))||"|"||NVL(vflaguhc, 0)||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)||"|"
							||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0)||"|"||NVL(vtelefono, 0)||"|"||NVL(vtelefonocelular, 0)||"|"||TRIM(NVL(vcasapropia, ''))||"|"||TRIM(vniptitular)||"|"||TRIM(vnipadicional)||"|"||TRIM(NVL(vsexo, ''))||"|" 
							||TRIM(NVL(vestadocivil, ''))||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadesdecuandovive, '1900/01/01'))||"|"||NVL(vpersonasvivenendomicilio, 0)||"|"||TRIM(NVL(vescolaridad, ''))||"|"||TRIM(NVL(vtiposueldo, ''));
					LET vsSQL = vsSQL ||"|"||NVL(vnumerodependientes, 0)||"|"||NVL(vpersonastrabajan, 0)||"|"||NVL(vlimitecredito, 0)||"|"||NVL(vingresomensual, 0)||"|"||TRIM(NVL(vsituacionespecial, ''))||"|"||NVL(vcausasituacionespecial, 0)||"|"
							||TRIM(vclaveautrechaza)||"|"||TRIM(vaceptadosupervisadorechazado)||"|"||TRIM(vclientenuevo)||"|"||TRIM(NVL(vcreditojoven, ''))||"|"||TRIM(NVL(vlugartrabajo, ''))||"|"||NVL(vciudadtrabajo, 0)||"|" 
							||NVL(vcoloniatrabajo, 0)||"|"||NVL(vcalletrabajo, 0)||"|"||NVL(iNumerocasatrabajo, 0)||"|"||TRIM(NVL(vdeptoointeriortrabajo, ''))||"|"||TRIM(NVL(vrumbotrabajo, ''))||"|"||TRIM(NVL(vcomplementotrabajo, ''))||"|"||TRIM(NVL(ventrecallestrabajo, ''));
					LET vsSQL = vsSQL ||"|"||NVL(vflaguht, 0)||"|"||NVL(vuhtmanzana, 0)||"|"||NVL(vuhtotros, 0)||"|"||NVL(vuhtandador, 0)||"|"||NVL(vuhtetapa, 0)||"|"||NVL(vuhtlote, 0)||"|"||NVL(vuhtedificio, 0)||"|"||NVL(vuhtentrada, 0)||"|"||NVL(vtelefonotrabajo, 0)||"|" 
							||NVL(vextensiontrabajo, 0)||"|"||TRIM(vpuesto)||"|"||NVL(vopcionpuesto, 0)||"|"||TRIM(NVL(cfechaantiguedtrab, '1900/01/01'))||"|"||TRIM(vclienteconyuge)||"|"||TRIM(NVL(vnombreunoconyuge, ''))||"|"||TRIM(NVL(vnombredosconyuge, ''))||"|"
							||TRIM(NVL(vapellidopaternoconyuge, ''))||"|"||TRIM(NVL(vapellidomaternoconyuge, ''))||"|"||TRIM(NVL(cSexoConyuge, ''))||"|"||TRIM(NVL(vlugartrabajoconyuge, ''))||"|"||NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|"||NVL(vcalletrabajoconyuge, 0)||"|" 
							||NVL(iNumerocasaconyuge, 0)||"|"||TRIM(NVL(vdeptoointeriorconyuge, ''))||"|"||TRIM(NVL(vrumbotrabajoconyuge, ''))||"|"||TRIM(NVL(vcomplementoconyuge, ''))||"|"
							||TRIM(NVL(ventrecallesconyuge,''));
					LET vsSQL = vsSQL||"|"||NVL(vflaguhy, 0)||"|"||NVL(vuhymanzana, 0)||"|"||NVL(vuhyotros, 0)||"|"||NVL(vuhyandador, 0)||"|"||NVL(vuhyetapa, 0)||"|"||NVL(vuhylote, 0)||"|"||NVL(vuhyedificio, 0)||"|"||NVL(vuhyentrada, 0)||"|"||NVL(vtelefonotrabajoconyuge, 0)||"|" 
							||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclaveconyugefamilia, ''))||"|"||TRIM(vclientereferencia)||"|"||TRIM(NVL(vnombreunoreferencia, ''))||"|"||TRIM(NVL(vnombredosreferencia, ''))||"|"   
							||TRIM(NVL(vapellidopaternoreferencia, ''))||"|"||TRIM(NVL(vapellidomaternoreferencia, ''))||"|"||TRIM(NVL(cSexoReferencia, ''))||"|"||NVL(vciudadreferencia, 0)||"|"||NVL(vcoloniareferencia, 0)||"|"||NVL(vcallereferencia, 0)||"|" 
							||NVL(iNumerocasaref, 0)||"|"||TRIM(NVL(vdeptoointeriorreferencia, ''))||"|"||TRIM(NVL(vrumboreferencia,''))||"|"||TRIM(NVL(vcomplementoreferencia,''))||"|"||TRIM(NVL(ventrecallesreferencia1,''))||"|"||NVL(vflaguhr, 0)||"|" 
							||NVL(vuhrmanzana, 0)||"|"||NVL(vuhrotros, 0)||"|"||NVL(vuhrandador, 0)||"|"||NVL(vuhretapa, 0)||"|"||NVL(vuhrlote, 0)||"|"||NVL(vuhredificio, 0)||"|"||NVL(vuhrentrada, 0)||"|"||NVL(vtelefonoreferencia, 0)||"|"||NVL(vtelefonocelularreferencia, 0);				  
					LET vsSQL = vsSQL||"|"||TRIM(NVL(vclavereferencia1, ''))||"|"||TRIM(vclientereferencia2)||"|"||TRIM(NVL(vnombreunoreferencia2, ''))||"|"||TRIM(NVL(vnombredosreferencia2, ''))||"|"||TRIM(NVL(vapellidopaternoreferencia2, ''))||"|"||TRIM(NVL(vapellidomaternoreferencia2, ''))||"|" 
							||TRIM(NVL(cSexoReferencia2, ''))||"|"||NVL(vciudadreferencia2, 0)||"|"||NVL(vcoloniareferencia2, 0)||"|"||NVL(vcallereferencia2, 0)||"|"||NVL(iNumerocasaref2, 0)||"|"||TRIM(NVL(vdeptoointeriorreferencia2, ''))||"|"||TRIM(NVL(vrumboreferencia2, ''))||"|" 
							||TRIM(NVL(vcomplementoreferencia2, ''))||"|"||TRIM(NVL(ventrecallesreferencia2, ''))||"|"||NVL(vflaguhr2, 0)||"|"||NVL(vuhrmanzana2, 0)||"|"||NVL(vuhrotros2, 0)||"|"||NVL (vuhrandador2, 0)||"|"||NVL(vuhretapa2, 0)||"|"||NVL(vuhrlote2, 0)||"|" 
							||NVL(vuhredificio2, 0)||"|"||NVL(vuhrentrada2, 0)||"|"||NVL(vtelefonoreferencia2, 0)||"|"||NVL(vtelefonocelularreferencia2, 0)||"|"||TRIM(NVL(vclavereferencia2, ''))||"|"||vreferencia2||"|"||vreferencia3||"|"||TRIM(vmarcadatosin)||"|" 
							||vtiporeposicion||"|"||vreposicion||"|"||TRIM(vflagentregotarjeta)||"|"||NVL(vefectuo, 0)||"|"||TRIM(NVL(cFolioSucursal, '0'))||"|"||TRIM(vfolio)||"|"||TRIM(NVL(cfechaaltacte, '1900/01/01'))||"|"   
							||TRIM(vflagnoreconocehuella)||"|"||vfoliotienda||"|"||TRIM(NVL(vrfc, ''))||"|"||TRIM(vcveburo)||"|"||TRIM(vfolioaut)||"|"||TRIM(vfolioconsulta)||"|"||TRIM(vfolioconcir)||"|"||vnegocio||"|"||vsubnegocio||"|"   
							||vempleadoautorizo||"|"||TRIM(vtipo)||"|"||TRIM(NVL(cfechamovto, '1900/01/01'))||"|"||TRIM(NVL(vnumerosolicituddecredito, ''))||"|"||TRIM(NVL(vnumcte, ''))||"|"||vtiendafolioanterior||"|"||vfolioanterior||"|" 
							||vclaveproducto||"|"||vflagactualizacion||"|"||vSistsegsocial||"|"||vTiposueldoext||"|"||vNumempleados||"|"||vSubopcionpuesto||"|"||vPuestoext||"|"||vOpcionpuestoext||"|"
							||vNumempleadosext||"|"||vSubopcionpuestoext||"|"||TRIM(vTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(cFolioSucursal, '0'))||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||NVL(cMarcaHit,'')||"|"
							||iEmpleadoSubCob||"|"||sFlagCapHuella||"|"||cMarcarConsultado||"|"||sFlagTestParametrico||"|"||sFlagCapCobranza||"|"||iEmpleadoGteAutori||"|"||NVL(cFlagConsBuro,'')||"|"||cBuroPilotoTestig||"|"||TRIM(NVL(cNacionalidad,''))||"|"||TRIM(NVL(cNoFm3,''))||"|"||TRIM(NVL(cEmail,''))||"|"
							||TRIM(NVL(cApellCasada,''))||"|"||TRIM(NVL(cPais,''))||"|"||TRIM(NVL(cNoIMSS,''))||"|"||TRIM(NVL(cEstado,''))||"|"||cDelegMunicip||"|"||TRIM(NVL(cNumInterior,''))||"|"||sPropNegocio||"|"||sParCelulares||"|"||sParAltoRiesgo||"|"||sParPrestamo||"|"||cModeloCel||"|"
							||NVL(cFechaConsBuro, '1900/01/01')||"|"||NVL(iMontoIngMensual,0)||"|"||NVL(iCapSistematicabono,0)||"|"||NVL(iTopeAbonoCoppel,0)||"|"||NVL(iLineaCrediTope,0)||"|"||NVL(iCapMaximaAbono,0)||"|"||NVL(iCapRealAbono,0)||"|"||NVL(iLineaCredReal,0)||"|"||NVL(iCompromisosSic,0)||"|"||NVL(iFlagLineaCredEsp,0)||"|"
							||TRIM(cClienteConyugebcpl)||"|"||TRIM(cClienteReferencia1bcpl)||"|"||TRIM(cClienteReferencia2bcpl);
					LET vsSQL = NVL(vsSQL, '');
					INSERT  INTO  bdinteg:"informix".si_archivoscoppeldiario (empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
					VALUES (pempresa, iSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);  
					LET iCuentaRegistros = 1;
				ELSE
					LET vCodRetorno = '000003';
					LET iCuentaRegistros = 2;
				END IF;
			END FOREACH;
		END IF;
	ELSE
		LET vCodRetorno = '000001';
		LET iCuentaRegistros = 2;
	END IF;
	IF iCuentaRegistros = 1 THEN
		LET vCodRetorno = '000000';
	ELIF iCuentaRegistros = 0 THEN
		LET vCodRetorno = '000005';
	END IF;
	RETURN vCodRetorno;
END;
END PROCEDURE;