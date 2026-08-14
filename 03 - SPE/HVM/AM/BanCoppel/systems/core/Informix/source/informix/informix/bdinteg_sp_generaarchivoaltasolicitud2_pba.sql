CREATE PROCEDURE "informix".sp_generaarchivoaltasolicitud2_pba(pempresa CHAR(3), pFechaAct DATE)
                                         RETURNING CHAR(6);
										 
--DEFINICION DE VARIABLES
--CLIENTE
DEFINE vClave CHAR(1); --DEFAULT ''
DEFINE vcaja SMALLINT;
DEFINE varea CHAR(1); --DEFAULT N
DEFINE vcliente_ref CHAR(20); --DEFAULT 0
DEFINE vnombre1 CHAR(26);
DEFINE vnombre2 CHAR(26);
DEFINE vapell_paterno CHAR(26);
DEFINE vapell_materno CHAR(26);
DEFINE vcurp CHAR(18);
DEFINE vclaveelector CHAR(18);
DEFINE vclaveidentificacion CHAR(2);
DEFINE videntificacion CHAR(8); --DEFAULT BLANCO
DEFINE vciudad INTEGER;
DEFINE vcolonia INTEGER;
DEFINE vcalle INTEGER;
DEFINE iNumerocasa INTEGER;
DEFINE vdeptointerior CHAR(4);
DEFINE vrumbo CHAR(1);
DEFINE vcomplemento CHAR(80);
DEFINE ventrecalles CHAR(40);
DEFINE vflaguhc SMALLINT;
DEFINE vuhcmanzana SMALLINT;
DEFINE vuhcotros SMALLINT;
DEFINE vuhcandador SMALLINT;
DEFINE vuhcetapa SMALLINT; 
DEFINE vuhclote  SMALLINT;
DEFINE vuhcedificio SMALLINT;
DEFINE vuhcentrada SMALLINT;
DEFINE vtelefono INT8;
DEFINE vtelefonocelular INT8;
DEFINE vcasapropia CHAR(1);
DEFINE vniptitular CHAR(7); --DEFAULT BLANCO
DEFINE vnipadicional CHAR(7); --DEFAULT BLACO
DEFINE vsexo CHAR(1);
DEFINE vestadocivil CHAR(1);
DEFINE cfechanac CHAR(10);
DEFINE cfechadesdecuandovive CHAR(10);
DEFINE vpersonasvivenendomicilio INTEGER;
DEFINE vescolaridad CHAR(1);
DEFINE vtiposueldo CHAR(1);
DEFINE vnumerodependientes SMALLINT;
DEFINE vpersonastrabajan SMALLINT;
DEFINE vlimitecredito SMALLINT; --DEFAULT 0
DEFINE vingresomensual SMALLINT;
DEFINE vsituacionespecial CHAR(1); --DEFAULT BLANCO
DEFINE vcausasituacionespecial SMALLINT; --DEFAULT 0
DEFINE vclaveautrechaza CHAR(1); --DEFAULT 0
DEFINE vaceptadosupervisadorechazado CHAR(1); --DEFAULT P
DEFINE vclientenuevo CHAR(1); --DEFAULT BLACO
DEFINE vcreditojoven CHAR(1);
DEFINE vlugartrabajo CHAR(20);
DEFINE vciudadtrabajo INTEGER;
DEFINE vcoloniatrabajo  INTEGER;
DEFINE vcalletrabajo  INTEGER;
DEFINE iNumerocasatrabajo INTEGER;
DEFINE vdeptoointeriortrabajo CHAR(4);
DEFINE vrumbotrabajo CHAR(1);
DEFINE vcomplementotrabajo CHAR(80);
DEFINE ventrecallestrabajo CHAR(40);
DEFINE vflaguht SMALLINT;
DEFINE vuhtmanzana SMALLINT;
DEFINE vuhtotros SMALLINT;
DEFINE vuhtandador SMALLINT;
DEFINE vuhtetapa SMALLINT;
DEFINE vuhtlote SMALLINT;
DEFINE vuhtedificio SMALLINT;
DEFINE vuhtentrada SMALLINT;
DEFINE vtelefonotrabajo INT8;
DEFINE vextensiontrabajo INTEGER;
DEFINE vpuesto CHAR(1);
DEFINE vopcionpuesto SMALLINT;
DEFINE cfechaantiguedtrab CHAR(10);
--CONYUGE
DEFINE vclienteconyuge CHAR(20); --INT
DEFINE vnombreunoconyuge CHAR(26);
DEFINE vnombredosconyuge CHAR(26);
DEFINE vapellidopaternoconyuge CHAR(26);
DEFINE vapellidomaternoconyuge CHAR(26);
DEFINE cSexoConyuge CHAR(1);
DEFINE vlugartrabajoconyuge CHAR(20);
DEFINE vciudadconyuge INTEGER;
DEFINE vcoloniaconyuge INTEGER;
DEFINE vcalletrabajoconyuge INTEGER;
DEFINE iNumerocasaconyuge INTEGER;
DEFINE vdeptoointeriorconyuge CHAR(4);
DEFINE vrumbotrabajoconyuge CHAR(1);
DEFINE vcomplementoconyuge CHAR(80);
DEFINE ventrecallesconyuge CHAR(40);
DEFINE vflaguhy SMALLINT;
DEFINE vuhymanzana SMALLINT;
DEFINE vuhyotros SMALLINT;
DEFINE vuhyandador  SMALLINT;
DEFINE vuhyetapa SMALLINT;
DEFINE vuhylote SMALLINT;
DEFINE vuhyedificio SMALLINT;
DEFINE vuhyentrada SMALLINT;
DEFINE vtelefonotrabajoconyuge INT8;
DEFINE vtelefonocelularconyuge INT8;
DEFINE vclaveconyugefamilia CHAR (1);
--REFERENCIA 1
DEFINE vclientereferencia CHAR(20); --INT
DEFINE vnombreunoreferencia CHAR(26);
DEFINE vnombredosreferencia CHAR(26);
DEFINE vapellidopaternoreferencia CHAR(26);
DEFINE vapellidomaternoreferencia CHAR(26);
DEFINE cSexoReferencia CHAR(1);
DEFINE vciudadreferencia INTEGER;
DEFINE vcoloniareferencia INTEGER;
DEFINE vcallereferencia INTEGER;
DEFINE iNumerocasaref INTEGER;
DEFINE vdeptoointeriorreferencia CHAR(4);
DEFINE vrumboreferencia CHAR(1);
DEFINE vcomplementoreferencia CHAR(80);
DEFINE ventrecallesreferencia1 CHAR(40);
DEFINE vflaguhr SMALLINT;
DEFINE vuhrmanzana SMALLINT ;
DEFINE vuhrotros SMALLINT ;
DEFINE vuhrandador SMALLINT;
DEFINE vuhretapa SMALLINT;
DEFINE vuhrlote SMALLINT;
DEFINE vuhredificio SMALLINT;
DEFINE vuhrentrada SMALLINT;
DEFINE vtelefonoreferencia INT8;       
DEFINE vtelefonocelularreferencia INT8;
DEFINE vclavereferencia1 CHAR(1);
--REFERENCIA 2
DEFINE vclientereferencia2 CHAR(20);
DEFINE vnombreunoreferencia2 CHAR(26);
DEFINE vnombredosreferencia2 CHAR(26);
DEFINE vapellidopaternoreferencia2 CHAR(26);
DEFINE vapellidomaternoreferencia2 CHAR(26);
DEFINE cSexoReferencia2 CHAR(1);
DEFINE vciudadreferencia2 INTEGER;
DEFINE vcoloniareferencia2 INTEGER;
DEFINE vcallereferencia2 INTEGER;
DEFINE iNumerocasaref2 INTEGER;
DEFINE vdeptoointeriorreferencia2 CHAR(4);
DEFINE vrumboreferencia2 CHAR(1);
DEFINE vcomplementoreferencia2 CHAR(80);
DEFINE ventrecallesreferencia2 CHAR(40);
DEFINE vflaguhr2 SMALLINT;
DEFINE vuhrmanzana2 SMALLINT;
DEFINE vuhrotros2 SMALLINT;
DEFINE vuhrandador2 SMALLINT;
DEFINE vuhretapa2 SMALLINT;
DEFINE vuhrlote2 SMALLINT;
DEFINE vuhredificio2 SMALLINT;
DEFINE vuhrentrada2 SMALLINT;
DEFINE vtelefonoreferencia2 INT8;
DEFINE vtelefonocelularreferencia2 INT8;
DEFINE vclavereferencia2 CHAR(1);
------
DEFINE vreferencia2 INTEGER; --DEFAULT 0
DEFINE vreferencia3 INTEGER; --DEFAULT 0
DEFINE vmarcadatosin CHAR(1); --DEFAULT BLACO
DEFINE vtiporeposicion SMALLINT; --DEFAULT 0
DEFINE vreposicion INTEGER; --DEFAULT 0
DEFINE vflagentregotarjeta CHAR(1); --DEFAULT BLACO
DEFINE vefectuo INTEGER;
DEFINE vtiendafolio SMALLINT;
DEFINE vfolio CHAR(20);
DEFINE cfechaaltacte CHAR (10);
DEFINE vflagnoreconocehuella CHAR(1); --DEFAULT BLACO
DEFINE vfoliotienda INTEGER; --DEFAULT 0
DEFINE vrfc CHAR(13); 
DEFINE vcveburo CHAR(2); --DEFAULT BLACO
DEFINE vfolioaut CHAR(4); --DEFAULT BLACO
DEFINE vfolioconsulta CHAR(9); --DEFAULT BLACO
DEFINE vfolioconcir CHAR(10); --DEFAULT BLACO
DEFINE vnegocio SMALLINT; --DEFAULT 0
DEFINE vsubnegocio SMALLINT; --DEFAULT 0
DEFINE vempleadoautorizo INTEGER; --DEFAULT 0
DEFINE vtipo CHAR(1); --DEFAULT BLACO
DEFINE cfechamovto CHAR (19);
DEFINE vnumerosolicituddecredito CHAR(20);
DEFINE vnumcte CHAR(20);
DEFINE vtiendafolioanterior SMALLINT;
DEFINE vfolioanterior INTEGER; --DEFAULT 0
DEFINE vclaveproducto SMALLINT; --6500
DEFINE vflagactualizacion INTEGER; --DEFAULT 0
--------
DEFINE vSistsegsocial SMALLINT; --DEFAULT 0
DEFINE vTiposueldoext SMALLINT; --DEFAULT 0
DEFINE vNumempleados SMALLINT; --DEFAULT 0
DEFINE vSubopcionpuesto SMALLINT; --DEFAULT 0
DEFINE vPuestoext SMALLINT; --DEFAULT 0
DEFINE vOpcionpuestoext SMALLINT; --DEFAULT 0
DEFINE vNumempleadosext SMALLINT; --DEFAULT 0
DEFINE vSubopcionpuestoext SMALLINT; --DEFAULT 0
DEFINE vTipoOrigen CHAR(1); --DEFAULT G
DEFINE vTipoProducto CHAR(5); --DEFAULT 11000
--Modificacion Campos nuevos
DEFINE iEmpleadoSubCob INTEGER; --DEFAULT 0
DEFINE sFlagCapHuella SMALLINT; --DEFAULT 1
DEFINE cMarcarConsultado CHAR(2);
DEFINE sFlagTestParametrico SMALLINT; --DEFAULT 0
DEFINE sFlagCapCobranza SMALLINT; --DEFAULT 0
DEFINE iEmpleadoGteAutori INTEGER; --DEFAULT 0
DEFINE cFlagConsBuro CHAR(2);
DEFINE cBuroPilotoTestig CHAR(1);
DEFINE cNacionalidad CHAR(3);
DEFINE cNoFm3 CHAR(18);
DEFINE cEmail CHAR(60);
DEFINE cApellCasada CHAR(26);
DEFINE cPais CHAR(3);
DEFINE cNoIMSS CHAR(12);
DEFINE cEstado CHAR(3);
DEFINE cDelegMunicip CHAR(3);
DEFINE cNumInterior CHAR(4);
DEFINE sPropNegocio SMALLINT; --DEFAULT 0
DEFINE sParCelulares SMALLINT; --DEFAULT 0 
DEFINE sParAltoRiesgo SMALLINT; --DEFAULT 0
DEFINE sParPrestamo SMALLINT; --DEFAULT 0
DEFINE cModeloCel CHAR(1); --DEFAULT 1
DEFINE dFechaConsBuro DATE;
DEFINE cFechaConsBuro CHAR(10);
DEFINE iMontoIngMensual INTEGER; 
DEFINE iCapSistematicabono INTEGER;
DEFINE iTopeAbonoCoppel INTEGER;
DEFINE iLineaCrediTope INTEGER;
DEFINE iCapMaximaAbono INTEGER;
DEFINE iCapRealAbono INTEGER;
DEFINE iLineaCredReal INTEGER;
DEFINE iCompromisosSic INTEGER;
DEFINE iFlagLineaCredEsp SMALLINT;
DEFINE cClienteConyugebcpl CHAR(20);
DEFINE cClienteReferencia1bcpl CHAR(20);
DEFINE cClienteReferencia2bcpl CHAR(20);

--OTRAS VARIABLES
DEFINE vletrasnumcasa VARCHAR (10);
DEFINE vletrasnumtrabajo VARCHAR(10);
DEFINE vletrasnumtrabconyuge VARCHAR(10);
DEFINE vletrasnumcasaref VARCHAR(10);
DEFINE vletrasnumcasaref2 VARCHAR(10);
DEFINE cFolioSucursal CHAR(4);
DEFINE vHora DATETIME HOUR TO FRACTION(3);
DEFINE cflaguht CHAR(1);
DEFINE vfechanacimiento DATE; 
--DEFINE vfechadesdecuandoviveahi DATE; 
DEFINE iAniosHabita INTEGER;
--DEFINE vfechaantiguedadtrabajo DATE;
DEFINE vfechaaltacliente DATE;
DEFINE vfechamovto DATE;
--DEFINE vcasa INTEGER;
DEFINE cCasatrabajo CHAR(10); --INT
DEFINE cCasatrabajoconyuge CHAR(10);
DEFINE cCasareferencia CHAR(10);
DEFINE cCasareferencia2 CHAR(10);
DEFINE cUnidadHabit CHAR(1);
DEFINE vTipo_Dir CHAR(2);
DEFINE vFecha_Hoy DATE;
DEFINE vNombre CHAR(104);
DEFINE vEdad INTEGER;
DEFINE vsSQL LVARCHAR (32000);
DEFINE iSqlErr INTEGER;
DEFINE vCodRetorno Char(6);
DEFINE dFechaAlta DATE;
DEFINE iValor INTEGER;
DEFINE iIngreso INTEGER;
DEFINE iPuntuacion INTEGER;
DEFINE cFecha_hoy CHAR (10);
DEFINE dEvaluacion1 DECIMAL(5,2);
DEFINE dEvaluacion2 DECIMAL(5,2);
DEFINE iSecuencia INTEGER;
DEFINE cMarcaHit CHAR(2);
DEFINE iElemento INTEGER;
DEFINE vcodret CHAR(5);
--DEFINE vfolio2 CHAR(20);
--DEFINE dfechasolicitud DATE;
--DEFINE vtiendafolio2 CHAR(5);
--DEFINE dFechaResidencia date;
--DEFINE dFechaLaborando date;
DEFINE vciudadbanco INTEGER;
DEFINE vcoloniabanco INTEGER;
DEFINE iContConsBuro INTEGER;
DEFINE iRefSecuencias INTEGER;
DEFINE iElementoScoring INTEGER;
DEFINE cDescripElemento CHAR(50);
DEFINE iCuentaRegistros INTEGER;
--dsb-19/07/2012
DEFINE cCasa CHAR(10);
DEFINE cRespuesta VARCHAR(20);

-- INICIALIZACION DE VARIABLES
--CLIENTE
LET vClave = ''; --DEFAULT BLACO
LET vcaja = 100;
LET varea = 'N'; --DEFAULT N
LET vcliente_ref = '0'; --Cliente Coppel --INT
LET vnombre1 = '';
LET vnombre2 = '';
LET vapell_paterno = '';
LET vapell_materno = '';
LET vcurp = '';
LET vclaveelector = '';
LET vclaveidentificacion = '';
LET videntificacion = ''; --DEFAULT BLANCO
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
LET vniptitular = ''; --DEFAULT BLANCO
LET vnipadicional = ''; --DEFAULT BLACO
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
LET vclaveautrechaza = '0'; --DEFAULT 2
LET vaceptadosupervisadorechazado = 'P'; --DEFAULT P
LET vclientenuevo = ''; --DEFAULT BLANCO
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
--CONYUGE
LET vclienteconyuge = '0'; --INT
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
LET vclaveconyugefamilia = '';
--REFERENCIA 1
LET vclientereferencia = '0'; --INT
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
--REFERENCIA 2
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
------
LET vreferencia2 = 0; --DEFAULT 0
LET vreferencia3 = 0; --DEFAULT 0
LET vmarcadatosin = ''; --DEFAULT BLACO
LET vtiporeposicion = 0; --DEFAULT 0
LET vreposicion = 0; --DEFAULT 0
LET vflagentregotarjeta = ''; --DEFAULT BLACO
LET vefectuo = 0;
LET vtiendafolio = 0;
LET vfolio = '0';
LET cfechaaltacte = '1900/01/01';
LET vflagnoreconocehuella = ''; --DEFAULT BLACO
LET vfoliotienda = 0; --DEFAULT 0
LET vrfc = ''; 
LET vcveburo = ''; --DEFAULT BLACO
LET vfolioaut = ''; --DEFAULT BLACO
LET vfolioconsulta = ''; --DEFAULT BLACO
LET vfolioconcir = ''; --DEFAULT BLACO
LET vnegocio = 0; --DEFAULT 0
LET vsubnegocio = 0; --DEFAULT 0
LET vempleadoautorizo = 0; --DEFAULT 0
LET vtipo = ''; --DEFAULT BLACO
LET cfechamovto = '1900/01/01';
LET vnumerosolicituddecredito = '';
LET vnumcte = '';
LET vtiendafolioanterior = 0;
LET vfolioanterior = 0; --DEFAULT 0
LET vclaveproducto = 6500; --6500
LET vflagactualizacion = 0; --DEFAULT 0
--------
LET vSistsegsocial = 0; --DEFAULT 0
LET vTiposueldoext = 0; --DEFAULT 0
LET vNumempleados = 0; --DEFAULT 0
LET vSubopcionpuesto = 0; --DEFAULT 0
LET vPuestoext = 0; --DEFAULT 0
LET vOpcionpuestoext = 0; --DEFAULT 0
LET vNumempleadosext = 0; --DEFAULT 0
LET vSubopcionpuestoext = 0; --DEFAULT 0
LET vTipoOrigen = 'G'; --DEFAULT G
LET vTipoProducto = '01000'; --DEFAULT 11000
--Modificacion Campos nuevos
LET iEmpleadoSubCob = 0; --DEFAULT 0
LET sFlagCapHuella = 1; --DEFAULT 1
LET cMarcarConsultado = '';
LET sFlagTestParametrico = 0; --DEFAULT 0
LET sFlagCapCobranza = 0; --DEFAULT 0
LET iEmpleadoGteAutori = 0; --DEFAULT 0
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
LET sPropNegocio = 0; --DEFAULT 0
LET sParCelulares = 0; --DEFAULT 0 
LET sParAltoRiesgo = 0; --DEFAULT 0
LET sParPrestamo = 0; --DEFAULT 0
LET cModeloCel = '1'; --DEFAULT 1
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

--OTRAS VARIABLES
LET vletrasnumcasa = "";
LET vletrasnumtrabajo = "";
LET vletrasnumtrabconyuge = "";
LET vletrasnumcasaref = "";
LET vletrasnumcasaref2 = "";
LET cFolioSucursal = '0';
LET vHora = '';
LET cflaguht = '';
LET vfechanacimiento = DATE(1); 
--LET vfechadesdecuandoviveahi = DATE(1); 
LET iAniosHabita = 0;
--LET vfechaantiguedadtrabajo = DATE(1);
LET vfechaaltacliente = DATE(1);
LET vfechamovto = DATE(1);
--LET vcasa = 0;
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
--LET vfolio2 = '';
--LET dfechasolicitud = date(1);
--LET vtiendafolio2 = '';
LET vciudadbanco = 0;
LET vcoloniabanco = 0;
LET iContConsBuro = 0;
LET iRefSecuencias = 0;
LET iElementoScoring = 0;
LET cDescripElemento = '';
LET iCuentaRegistros = 0;
--dsb-19/07/2012
LET cCasa = '';
LET cRespuesta = '';

Set debug file to '/RESPALDOSNEW/sp_GeneraArchivoAltaSolicitud.out';
trace on;

BEGIN
	ON EXCEPTION
		SET iSqlErr
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
				WHERE num_solicitud = '650000144750' AND num_producto = '6500' AND fecha_insert = pFechaAct AND status_solicitud NOT IN ('PC', 'AN')
				
				IF vnumerosolicituddecredito <> '' OR vnumcte <> '' THEN 
					
					--Calcula Edad del Cliente
					EXECUTE PROCEDURE "informix".consedadcte(pempresa, vnumcte) INTO vCodRetorno, vNombre, vEdad;
					--OBTIENE DATOS GENERALES DEL CLIENTE
					SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, cte.numcte, cte.ejecut_autoriza, cte.rfc, 
					cte.fecha_insert, cte.ejecut_autoriza, TRIM(NVL(cte.string2,0))::INTEGER, cte.apell_casada
					INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vnumcte, vefectuo, vrfc, 
					vfechamovto, vefectuo, vpersonasvivenendomicilio, cApellCasada
					FROM bdinteg:"informix".si_cliente cte
					WHERE cte.empresa = pempresa AND cte.numcte = vnumcte;

					--Datos Generales Clientes
					SELECT iden.estado_civil, iden.curp, iden.numidentifi, iden.codidentifi, iden.habita_en, iden.sexo, iden.fecha_nac, iden.escolaridad,
					iden.nacionalidad, iden.no_fm3, iden.email, iden.no_imss
					INTO vestadocivil, vcurp, vclaveelector, vclaveidentificacion, vcasapropia, vsexo, vfechanacimiento, vescolaridad,
					cNacionalidad, cNoFm3, cEmail, cNoIMSS
					FROM bdinteg:"informix".si_ctepf iden
					WHERE iden.numcte = vnumcte;

					--Direccion Clientes
					/*SELECT dir.numerociudad, dir.numerocolonia, dir.numerocalle, TRIM(NVL(dir.numeroextcalle,'1')), dir.departamento, dir.puntocardinal, 
					dir.observaciones, dir.entre_calles, dir.unidadhabitac, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote, 
					dir.edificio, dir.entrada, TRIM(NVL(dir.telefono1,0)), TRIM(NVL(dir.telefono2,0)), dir.tipo_dir, dir.numerointcalle, dir.pais, dir.estado  
					INTO vciudadbanco, vcoloniabanco, vcalle, vcasa, vdeptointerior, vrumbo, vcomplemento, ventrecalles, cUnidadHabit, vuhcmanzana, vuhcotros,
					vuhcandador, vuhcetapa, vuhclote, vuhcedificio, vuhcentrada, vtelefono, vtelefonocelular, vTipo_Dir, cNumInterior, cPais, cEstado
					FROM bdinteg:"informix".si_direcciones_actual dir
					WHERE dir.numcte = vnumcte AND dir.tipo_dir = '1' 
					AND dir.secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = vnumcte AND tipo_dir = '1');
					*/
					--dsb-19/07/2012
					SELECT dir.numerociudad, dir.numerocolonia, dir.numerocalle, TRIM(NVL(dir.numeroextcalle,'1')), dir.departamento, dir.puntocardinal, 
					dir.observaciones, dir.entre_calles, dir.unidadhabitac, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote, 
					dir.edificio, dir.entrada, TRIM(NVL(dir.telefono1,0)), TRIM(NVL(dir.telefono2,0)), dir.tipo_dir, dir.numerointcalle, dir.pais, dir.estado  
					INTO vciudadbanco, vcoloniabanco, vcalle, cCasa, vdeptointerior, vrumbo, vcomplemento, ventrecalles, cUnidadHabit, vuhcmanzana, vuhcotros,
					vuhcandador, vuhcetapa, vuhclote, vuhcedificio, vuhcentrada, vtelefono, vtelefonocelular, vTipo_Dir, cNumInterior, cPais, cEstado
					FROM bdinteg:"informix".si_direcciones_actual dir
					WHERE dir.numcte = vnumcte AND dir.tipo_dir = '1' 
					AND dir.secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = vnumcte AND tipo_dir = '1');
					
					EXECUTE PROCEDURE bdinteg:"informix".sp_EsNumerico (cCasa) INTO cRespuesta; -- Sp para validar el tipo de caracter(numero o letra)
						
					IF cRespuesta = 'F' THEN
						LET iNumerocasa = 1;
					ELSE
						LET iNumerocasa = cCasa;
					END IF;
					
					IF NVL(vcomplemento, '') = '' THEN
						LET vcomplemento = 'E';
					END IF;
					
					--Convierte ciudad, colonia Bancoppel - Coppel
					SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
					INTO vciudad, vcolonia
					FROM bdinteg:"informix".si_catzonas
					WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
					
					IF NVL(vciudad, 0) = 0 THEN
						SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT FIRST 1 numerociudadcoppel INTO vciudad FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
					END IF;
					IF NVL(vcolonia, 0) = 0 THEN
						SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT FIRST 1 numerocoloniacoppel INTO vcolonia FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
					END IF;

					--Trabajo Clientes
					SELECT ing.nombre_empresa, ing.claveopcionpuesto, ing.clavesubopcionpuesto --ing.ingreso_mensual
					INTO vlugartrabajo, vopcionpuesto, vSubopcionpuesto --vingresomensual
					FROM bdinteg:"informix".si_ingresos ing
					WHERE ing.numcte = vnumcte
					AND ing.sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = vnumcte AND tipo_ingreso = 'T');				
					
					IF NVL(vopcionpuesto, '') = '' THEN
						LET vopcionpuesto = '0';
					END IF;
					IF NVL(vSubopcionpuesto, '') = '' THEN
						LET vSubopcionpuesto = 0;
					END IF;
					
					SELECT tp_ingreso INTO vtiposueldo FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud = vnumerosolicituddecredito;
					
					IF cUnidadHabit = 'S' THEN
						LET vflaguhc = 1;
					ELSE
						LET vflaguhc= 0;
					END IF;
					SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
					-- DARLE FORMATO A LAS FECHAS 
					LET cfechanac = YEAR(vfechanacimiento)||"/"||LPAD(MONTH(vfechanacimiento),2,0)||"/"||LPAD(DAY(vfechanacimiento),2,0);
					LET cfechaaltacte = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,0)||"/"||LPAD(DAY(vfechaaltacliente),2,0);
					IF pFechaAct <> vFecha_Hoy THEN
						LET cfechamovto = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
					ELSE
						LET cfechamovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
					END IF;					
					
					--dsb-19/07/2012
					--DA FORMATO A NUMERO DE CASA
					/*EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(vcasa) INTO vCodRetorno, iNumerocasa, vletrasnumcasa;
					
					IF iNumerocasa = 0 THEN
						LET iNumerocasa = 1;
					END IF;*/
					
					--EVALUA SI ES CREDITO JOVEN
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
					
					--TOMA LOS DATOS DE LA DIRECCION DEL TRABAJO
					SELECT dir.numerociudad, dir.numerocolonia, dir.numerocalle, TRIM(NVL(dir.numeroextcalle,'1')),dir.departamento, dir.puntocardinal,
					dir.observaciones, dir.entre_calles,dir.unidadhabitac,dir.manzana, dir.otros,dir.andador, dir.etapa,dir.lote,
					dir.edificio, dir.entrada,TRIM(NVL(dir.telefono3,0)),dir.extension 
					INTO vciudadbanco,vcoloniabanco,vcalletrabajo,cCasatrabajo,vdeptoointeriortrabajo, vrumbotrabajo,
					vcomplementotrabajo,ventrecallestrabajo,cflaguht,vuhtmanzana, vuhtotros,vuhtandador,vuhtetapa,vuhtlote,vuhtedificio,
					vuhtentrada,vtelefonotrabajo,vextensiontrabajo					
					FROM bdinteg:"informix".si_cliente cte, bdinteg:"informix".si_direcciones_actual dir
					WHERE cte.numcte = vnumcte AND cte.numcte = dir.numcte AND dir.tipo_dir = '2' 
					AND	dir.secuencia = (SELECT NVL (MAX(secuencia),0)FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = vnumcte AND  tipo_dir = '2');
					
					IF NVL(vcomplementotrabajo, '') = '' THEN
						LET vcomplementotrabajo = 'E';
					END IF;
					
					--Convierte ciudad, colonia Bancoppel - Coppel
					SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
					INTO vciudadtrabajo, vcoloniatrabajo
					FROM bdinteg:"informix".si_catzonas
					WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
					
					IF NVL(vciudadtrabajo, 0) = 0 THEN
						SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT FIRST 1 numerociudadcoppel INTO vciudadtrabajo FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
					END IF;
					IF NVL(vcoloniatrabajo, 0) = 0 THEN
						SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT FIRST 1 numerocoloniacoppel INTO vcoloniatrabajo FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
					END IF;
					
					--OBTIENE LA UNIDAD HABITACIONAL
					IF cflaguht = 'S' THEN
						LET vflaguht = 1;
					ELSE
						LET vflaguht = 0;
					END IF;
					
					--DA FORMATO A NUMERO DE TRABAJO
					--EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(cCasatrabajo) INTO vCodRetorno, iNumerocasatrabajo, vletrasnumtrabajo; --NO
					--19/07/2012
					EXECUTE PROCEDURE bdinteg:"informix".sp_EsNumerico (cCasatrabajo) INTO cRespuesta; -- Sp para validar el tipo de caracter(numero o letra)

					IF cRespuesta = 'F' THEN
						LET iNumerocasatrabajo = 1;
					ELSE
						LET iNumerocasatrabajo = cCasatrabajo;
					END IF;
					
					LET cClienteConyugebcpl = '';
					LET cClienteReferencia1bcpl = '';
					LET cClienteReferencia2bcpl = '';
					--********************************************************************************************************************
					--OBTIENE LOS DATOS DE LA REFERENCIAS SI ES CASADO
					IF 	vestadocivil = 'C' THEN
						LET vclientereferencia = '0'; --INT
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
						
						LET vclaveconyugefamilia = 'E';
						--OBTIENE LOS DATOS DEL CONYUGE CUANDO EL CLIENTE ES CASADO					
						SELECT cte2.numcte_banco, cte2.nombre1, cte2.nombre2, cte2.apell_paterno, cte2.apell_materno, cte2.parentesco, cte2.sexo, cte2.secuencia
						INTO vclienteconyuge,vnombreunoconyuge,vnombredosconyuge,vapellidopaternoconyuge,vapellidomaternoconyuge,
						vclaveconyugefamilia,cSexoConyuge,iRefSecuencias
						FROM bdinteg:"informix".si_refclientes cte2
						WHERE cte2.empresa = pempresa AND cte2.numcte = vnumcte 
						AND cte2.secuencia = (SELECT NVL(MAX(secuencia),0) FROM bdinteg:"informix".si_refclientes WHERE numcte = vnumcte AND parentesco = 'E') 
						AND cte2.parentesco = 'E' AND cte2.num_solicitud = vnumerosolicituddecredito;
						
						IF NVL(vclienteconyuge, '') = '' THEN
							LET vclienteconyuge = '0';
						END IF;
						
						LET cClienteConyugebcpl = vnumcte;
							
						SELECT dir2.numerociudad,dir2.numerocolonia,dir2.numerocalle,TRIM(NVL(dir2.numeroextcalle,'1')),dir2.departamento,dir2.puntocardinal,
						dir2.observaciones,dir2.entre_calles,dir2.unidadhabitac,dir2.manzana,dir2.otros,dir2.andador,dir2.etapa,dir2.lote, 
						dir2.edificio,dir2.entrada,TRIM(NVL(dir2.telefono3,0)),TRIM(NVL(dir2.telefono2,0))
						INTO vciudadbanco,vcoloniabanco,vcalletrabajoconyuge,cCasatrabajoconyuge,vdeptoointeriorconyuge,vrumbotrabajoconyuge,
						vcomplementoconyuge,ventrecallesconyuge,cflaguht,vuhymanzana,vuhyotros,vuhyandador,vuhyetapa,vuhylote,vuhyedificio,
						vuhyentrada,vtelefonotrabajoconyuge,vtelefonocelularconyuge
						FROM bdinteg:"informix".si_refdirecciones dir2
						WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;
						
						IF NVL(vcomplementoconyuge, '') = '' THEN
							LET vcomplementoconyuge = 'E';
						END IF;
							
						--Convierte ciudad, colonia Bancoppel - Coppel
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
						INTO vciudadconyuge, vcoloniaconyuge
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						
						IF NVL(vciudadconyuge, 0) = 0 THEN
							SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 numerociudadcoppel INTO vciudadconyuge FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
						END IF;
						IF NVL(vcoloniaconyuge, 0) = 0 THEN
							SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 numerocoloniacoppel INTO vcoloniaconyuge FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
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
						--dsb-19/07/2012
						--DA FORMATO A NUMERO DE CASA DE CONYUGE
						--EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(cCasatrabajoconyuge) INTO vCodRetorno, iNumerocasaconyuge, vletrasnumtrabconyuge;
						
						EXECUTE PROCEDURE bdinteg:"informix".sp_EsNumerico (cCasatrabajoconyuge) INTO cRespuesta; -- Sp para validar el tipo de caracter(numero o letra)

						IF cRespuesta = 'F' THEN
							LET iNumerocasaconyuge = 1;
						ELSE
							LET iNumerocasaconyuge = cCasatrabajoconyuge;
						END IF;
						
						--TOMA DATOS DE REFERENCIA 2 
						SELECT cte2.numcte,cte2.nombre1,cte2.nombre2,cte2.apell_paterno,cte2.apell_materno,cte2.parentesco,cte2.sexo,cte2.secuencia
						INTO vclientereferencia2,vnombreunoreferencia2,vnombredosreferencia2,vapellidopaternoreferencia2,vapellidomaternoreferencia2,
						vclavereferencia2,cSexoReferencia2,iRefSecuencias
						FROM bdinteg:"informix".si_refclientes cte2
						WHERE cte2.empresa = '001' AND cte2.numcte = vnumcte
						AND cte2.secuencia = (SELECT NVL(MAX(secuencia), 0) FROM bdinteg:"informix".si_refclientes WHERE numcte = vnumcte AND parentesco <> 'E')
						AND cte2.parentesco <> 'E' AND cte2.num_solicitud = vnumerosolicituddecredito;
						
						IF NVL(vclientereferencia2, '') = '' THEN
							LET vclientereferencia2 = '0';
						END IF;
						
						LET cClienteReferencia2bcpl = vnumcte;
						
						SELECT dir2.numerociudad,dir2.numerocolonia,dir2.numerocalle,TRIM(NVL(dir2.numeroextcalle,'1')),dir2.departamento,dir2.puntocardinal,dir2.observaciones,
						dir2.entre_calles,dir2.unidadhabitac,dir2.manzana,dir2.otros,dir2.andador,dir2.etapa,dir2.lote,dir2.edificio,dir2.entrada,
						TRIM(NVL(dir2.telefono1, ''))::INT8,TRIM(NVL(dir2.telefono2,''))::INT8
						INTO vciudadbanco,vcoloniabanco,vcallereferencia2,cCasareferencia2,vdeptoointeriorreferencia2,vrumboreferencia2,
						vcomplementoreferencia2,ventrecallesreferencia2,cflaguht,vuhrmanzana2,vuhrotros2,vuhrandador2,vuhretapa2,vuhrlote2,vuhredificio2,
						vuhrentrada2,vtelefonoreferencia2,vtelefonocelularreferencia2
						FROM bdinteg:"informix".si_refdirecciones dir2
						WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;
						
						IF NVL(vcomplementoreferencia2, '') = '' THEN
							LET vcomplementoreferencia2 = 'E';
						END IF;
						
						--Convierte ciudad, colonia Bancoppel - Coppel
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
						INTO vciudadreferencia2, vcoloniareferencia2
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						
						IF NVL(vciudadreferencia2, 0) = 0 THEN
							SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 numerociudadcoppel INTO vciudadreferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
						END IF;
						IF NVL(vcoloniareferencia2, 0) = 0 THEN
							SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 numerocoloniacoppel INTO vcoloniareferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
						END IF;
						
						IF cflaguht = 'S' THEN
							LET vflaguhr2 = 1;
						ELSE
							LET vflaguhr2 = 0;
						END IF;
						
						--DA FORMATO A NUMERO DE CASA DE REFERENCIA 2 
						--EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(cCasareferencia2) INTO vCodRetorno, iNumerocasaref2, vletrasnumcasaref2; 
						--19/07/2012
						EXECUTE PROCEDURE bdinteg:"informix".sp_EsNumerico (cCasareferencia2) INTO cRespuesta; -- Sp para validar el tipo de caracter(numero o letra)

						IF cRespuesta = 'F' THEN
							LET iNumerocasaref2 = 1;
						ELSE
							LET iNumerocasaref2 = cCasareferencia2;
						END IF;
						
					END IF;
					
					--********************************************************************************************************************
					--TOMA LOS DATOS DE LAS REFERENCIAS SI NO ES CASADO
					IF 	vestadocivil <> 'C' THEN
						LET vclienteconyuge = '0'; --INT
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
						LET vclaveconyugefamilia = '';
							
						--OBTIENE LOS DATOS DE LA REFERENCIA 1
						SELECT cte2.numcte,cte2.nombre1,cte2.nombre2,cte2.apell_paterno,cte2.apell_materno,cte2.parentesco,cte2.sexo,cte2.secuencia
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
						
						SELECT dir2.numerociudad,dir2.numerocolonia,dir2.numerocalle,TRIM(NVL(dir2.numeroextcalle,'1')),dir2.departamento,dir2.puntocardinal,dir2.observaciones,
						dir2.entre_calles,dir2.unidadhabitac,dir2.manzana,dir2.otros,dir2.andador,dir2.etapa,dir2.lote,dir2.edificio,dir2.entrada,
						TRIM(NVL(dir2.telefono1, ''))::INT8,TRIM(NVL(dir2.telefono2,''))::INT8
						INTO vciudadbanco,vcoloniabanco,vcallereferencia,cCasareferencia,vdeptoointeriorreferencia,vrumboreferencia,
						vcomplementoreferencia,ventrecallesreferencia1,cflaguht,vuhrmanzana,vuhrotros,vuhrandador,vuhretapa,vuhrlote,vuhredificio,
						vuhrentrada,vtelefonoreferencia,vtelefonocelularreferencia
						FROM bdinteg:"informix".si_refdirecciones dir2
						WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;
						
						IF NVL(vcomplementoreferencia, '') = '' THEN
							LET vcomplementoreferencia = 'E';
						END IF;
						
						--Convierte ciudad, colonia Bancoppel - Coppel
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
						INTO vciudadreferencia, vcoloniareferencia
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						
						IF NVL(vciudadreferencia, 0) = 0 THEN
							SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 numerociudadcoppel INTO vciudadreferencia FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
						END IF;
						IF NVL(vcoloniareferencia, 0) = 0 THEN
							SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 numerocoloniacoppel INTO vcoloniareferencia FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
						END IF;
						
						--OBTIENE LA UNIDAD HABITACIONAL
						IF cflaguht = 'S' THEN
							LET vflaguhr = 1;
						ELSE
							LET vflaguhr = 0;
						END IF;
						
						--DA FORMATO A NUMERO DE CASA DE REFERENCIA 1
						--EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(cCasareferencia) INTO vCodRetorno, iNumerocasaref, vletrasnumcasaref;
						--19/07/2012
						EXECUTE PROCEDURE bdinteg:"informix".sp_EsNumerico (cCasareferencia) INTO cRespuesta; -- Sp para validar el tipo de caracter(numero o letra)

						IF cRespuesta = 'F' THEN
							LET iNumerocasaref = 1;
						ELSE
							LET iNumerocasaref = cCasareferencia;
						END IF;
						
						--OBTIENE LOS DATOS DE REFERENCIA 2
						SELECT cte2.numcte,cte2.nombre1,cte2.nombre2,cte2.apell_paterno,cte2.apell_materno,cte2.parentesco,cte2.sexo,cte2.secuencia
						INTO vclientereferencia2,vnombreunoreferencia2,vnombredosreferencia2,vapellidopaternoreferencia2,vapellidomaternoreferencia2,
						vclavereferencia2,cSexoReferencia2,iRefSecuencias
						FROM bdinteg:"informix".si_refclientes cte2
						WHERE cte2.empresa = pempresa AND cte2.numcte = vnumcte
						AND cte2.secuencia = (SELECT NVL(MAX(secuencia),0) FROM bdinteg:"informix".si_refclientes WHERE numcte = vnumcte AND parentesco <> 'E')
						AND cte2.parentesco <> 'E' AND cte2.num_solicitud = vnumerosolicituddecredito;
						
						IF NVL(vclientereferencia2, '') = '' THEN
							LET vclientereferencia2 = '0';
						END IF;
						
						LET cClienteReferencia2bcpl = vnumcte;
						
						SELECT dir2.numerociudad,dir2.numerocolonia, dir2.numerocalle,TRIM(NVL(dir2.numeroextcalle,'1')),dir2.departamento,dir2.puntocardinal,dir2.observaciones,
						dir2.entre_calles,dir2.unidadhabitac,dir2.manzana,dir2.otros,dir2.andador,dir2.etapa,dir2.lote,dir2.edificio,dir2.entrada,
						TRIM(NVL(dir2.telefono1, ''))::INT8,TRIM(NVL(dir2.telefono2,''))::INT8
						INTO vciudadbanco,vcoloniabanco,vcallereferencia2,cCasareferencia2,vdeptoointeriorreferencia2,vrumboreferencia2,
						vcomplementoreferencia2,ventrecallesreferencia2,cflaguht,vuhrmanzana2,vuhrotros2,vuhrandador2,vuhretapa2,vuhrlote2,vuhredificio2,
						vuhrentrada2,vtelefonoreferencia2,vtelefonocelularreferencia2
						FROM bdinteg:"informix".si_refdirecciones dir2	
						WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;
						
						IF NVL(vcomplementoreferencia2, '') = '' THEN
							LET vcomplementoreferencia2 = 'E';
						END IF;
						
						--Convierte ciudad, colonia Bancoppel - Coppel
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
						INTO vciudadreferencia2, vcoloniareferencia2
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						
						IF NVL(vciudadreferencia2, 0) = 0 THEN
							SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 numerociudadcoppel INTO vciudadreferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
						END IF;
						IF NVL(vcoloniareferencia2, 0) = 0 THEN
							SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							SELECT FIRST 1 numerocoloniacoppel INTO vcoloniareferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
						END IF;
						
						IF cflaguht = 'S' THEN
							LET vflaguhr2 = 1;
						ELSE
							LET vflaguhr2 = 0;
						END IF;
						
						--DA FORMATO A NUMERO DE CASA DE REFERENCIA 2	
						--EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(cCasareferencia2) INTO vCodRetorno, iNumerocasaref2, vletrasnumcasaref2;
						--19/07/2012
						EXECUTE PROCEDURE bdinteg:"informix".sp_EsNumerico (cCasareferencia2) INTO cRespuesta; -- Sp para validar el tipo de caracter(numero o letra)

						IF cRespuesta = 'F' THEN
							LET iNumerocasaref2 = 1;
						ELSE
							LET iNumerocasaref2 = cCasareferencia2;
						END IF;
						
					END IF;
					--********************************************************************************************************************
					IF (SELECT NVL(COUNT(*), 0) FROM bdisolic:"informix".ss_os_solautdirecta WHERE num_solicitud = vnumerosolicituddecredito) >= 1 THEN
						LET vsituacionespecial = 'S';
						LET vcausasituacionespecial = 50;
					ELSE
						SELECT situacion_especial, causa_sitesp INTO vsituacionespecial, vcausasituacionespecial
						FROM bdisolic:"informix".ss_nuevo_parametrico
						WHERE num_solicitud = vnumerosolicituddecredito;
					END IF; 
					
					-----Numero de Dependientes
					SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring
					WHERE grupo = 11 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
					
					SELECT rango_minimo INTO vnumerodependientes FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 11 AND seccion = 2 AND tpo_persona = '01' AND elemento = iElemento AND activa = 1;
					
					-----Personas que trabajan
					SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring
					WHERE grupo = 39 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
					
					SELECT rango_minimo INTO vpersonastrabajan FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 39 AND seccion = 2 AND tpo_persona = '01' AND elemento = iElemento AND activa = 1;
					
					--TIEMPO DE RESIDENCIA 
					SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring 
					WHERE empresa = pempresa AND grupo = 6 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
					
					SELECT rango_minimo INTO iElemento FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 6 AND seccion = 2 AND elemento = iElemento AND activa = 1;

					LET cfechadesdecuandovive = YEAR(vfechaaltacliente)-iElemento; 
					LET cfechadesdecuandovive = TRIM(cfechadesdecuandovive)||'/01/01';
					
					--TIEMPO LABORANDO
					SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring 
					WHERE empresa = pempresa AND grupo = 8 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
					
					SELECT rango_minimo INTO iElemento FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 8 AND seccion = 2 AND elemento = iElemento AND activa = 1;
					
					IF iElemento = -1 THEN
						SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring 
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

					--OBTENER ESCOLARIDAD
					SELECT elemento INTO iElementoScoring FROM bdisolic:"informix".ss_detalle_scoring 
					WHERE grupo = '21' AND num_solicitud = vnumerosolicituddecredito;
					
					--Para buscar descripcion de elemento 
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
					
					--OBTIENE EL FOLIO
					SELECT secuencia INTO vfolio FROM bdisolic:"informix".ss_osclientesupervisar WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND fechasolicitud = fechasolicitud
					AND ROWID = (SELECT MAX(ROWID) FROM bdisolic:"informix".ss_osclientesupervisar WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito);
					IF NVL(vfolio, '') = '' THEN
						LET vfolio = '0';
					END IF;
					
					--CONSULTA DE BURO
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
					
					--CONSULTA NUEVO PARAMETRICO
					SELECT ingreso_mensual, cap_sistematica_abono, tope_abonocoppel, lineacreditotope, capmaxima_abono, capreal_abono, lineacredito_real, compromisossic, flaglineacreditoesp
					INTO iMontoIngMensual, iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, iFlagLineaCredEsp
					FROM bdisolic:"informix".ss_nuevo_parametrico
					WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito;
					
					--INGRESO MENSUAL
					SELECT valor INTO iValor FROM bdisolic:"informix".ss_param WHERE secuencia = 363;
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
					
					SELECT limitecredito INTO vlimitecredito FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = vnumerosolicituddecredito;
					
					SELECT EVALUACION INTO dEvaluacion1 FROM bdisolic:"informix".ss_resumen_scoring WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND seccion = 1;
					SELECT EVALUACION INTO dEvaluacion2 FROM bdisolic:"informix".ss_resumen_scoring WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND seccion = 2;
					
					LET iPuntuacion = (dEvaluacion1+dEvaluacion2);
					
					--SECUENCIA DE ARCHIVO
					IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
						IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							LET iSecuencia = (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						ELSE
							LET iSecuencia = (SELECT NVL(MAX(secuencia), 0) + 1  FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						END IF;
					ELSE
						IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							LET iSecuencia = (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						ELSE
							LET iSecuencia = 1;
						END IF;
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
					
--					INSERT  INTO  bdinteg:"informix".si_archivoscoppeldiario (empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
--					VALUES (pempresa, iSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);  
					
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

--*************************************************************************
--| Procedimiento   : "informix".sp_GeneraArchivoAltaSolicitud
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Noviembre de 2008
--| Descripción     : Realiza la extracción de datos del alta de solicitud.
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Fecha Modifica  : Junio de 2011
--| Descripción     : Se generan archivos, se agreagan nuevas consultas y correcciones en la trama de datos.
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Ultima Modif.   : Sptiembre de 2011
--| Descripción     : Se modifica para que el campo complemento se agregue el valor E.
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Ultima Modif.   : Octubre de 2011
--| Descripción     : Se modifica para la consulta de solicitudes para la fecha actual siendo cualquier tipo de estatus.
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Ultima Modif.   : Febrero 2012
--| Descripción     : Se agregan 32 nuevos campos a la trama de salida que incluyen los datos del nuevo parametrico.
--*************************************************************************
--| Modificado por  : Victor Hugo Nuñez
--| Ultima Modif.   : 18-Julio-2012
--| Descripción     : Se valida ingreso de variable de numero de casa y se elimina llamada sp_conviertenumerodecasa.
--*************************************************************************
END PROCEDURE;