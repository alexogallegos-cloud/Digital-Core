CREATE PROCEDURE "informix".sp_genarchiadicionales_pba(pempresa CHAR(3), pFechaAct DATE)
RETURNING
     CHAR(6);
	 
--DEFINICION DE VARIABLES
--CLIENTE
DEFINE vClave CHAR(1); --DEFAULT 'C'
DEFINE vcaja SMALLINT;
DEFINE varea CHAR(1); --DEFAULT ''
DEFINE vcliente_ref CHAR(20); --#TITULAR CHECAR QUE SEA EL NUMERO DEL TITULAR
DEFINE vnombre1 CHAR(26); --DEFAULT BLANCO
DEFINE vnombre2 CHAR(26); --DEFAULT BLANCO
DEFINE vapell_paterno CHAR(26); --DEFAULT BLANCO
DEFINE vapell_materno CHAR(26); --DEFAULT BLANCO
DEFINE vcurp CHAR(18);
DEFINE vclaveelector CHAR(18); --DEFAULT BLANCO
DEFINE vclaveidentificacion CHAR(2); --DEFAULT BLANCO
DEFINE videntificacion CHAR(8); --DEFAULT BLANCO
DEFINE vciudad SMALLINT; --DEFAULT 0
DEFINE vcolonia INTEGER; --DEFAULT 0
DEFINE vcalle INTEGER; --DEFAULT 0
DEFINE snumerocasa INTEGER; --DEFAULT 0
DEFINE vdeptointerior CHAR(4); --DEFAULT BLANCO
DEFINE vrumbo CHAR(1); --DEFAULT BLANCO
DEFINE vcomplemento CHAR(80); --DEFAULT BLANCO
DEFINE ventrecalles CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhc SMALLINT; --DEFAULT 0
DEFINE vuhcmanzana SMALLINT; --DEFAULT 0
DEFINE vuhcotros SMALLINT; --DEFAULT 0
DEFINE vuhcandador SMALLINT; --DEFAULT 0
DEFINE vuhcetapa SMALLINT; --DEFAULT 0
DEFINE vuhclote  SMALLINT; --DEFAULT 0
DEFINE vuhcedificio SMALLINT; --DEFAULT 0
DEFINE vuhcentrada SMALLINT; --DEFAULT 0
DEFINE vtelefono INT8; --DEFAULT 0
DEFINE vtelefonocelular INT8; --DEFAULT 0
DEFINE vcasapropia CHAR(1);
DEFINE vniptitular CHAR(7); --DEFAULT BLANCO
DEFINE vnipadicional CHAR(9); --DEFAULT A
DEFINE vsexo CHAR(1); --DEFAULT BLANCO
DEFINE vestadocivil CHAR(1); --DEFAULT BLANCO
DEFINE cfechanac CHAR(10);
DEFINE cfechadesdecuandovive CHAR(10);
DEFINE vpersonasvivenendomicilio INTEGER; --DEFAULT 0
DEFINE vescolaridad CHAR(1); --DEFAULT BLANCO
DEFINE vtiposueldo CHAR(1); --DEFAULT BLANCO
DEFINE vnumerodependientes SMALLINT; --DEFAULT 0
DEFINE vpersonastrabajan SMALLINT;
DEFINE vlimitecredito SMALLINT; --DEFAULT 0
DEFINE vingresomensual SMALLINT; --DEFAULT 0
DEFINE vsituacionespecial CHAR(1); --DEFAULT BLANCO
DEFINE vcausasituacionespecial SMALLINT; --DEFAULT 0
DEFINE vclaveautrechaza CHAR(1); --DEFAULT BLANCO
DEFINE vaceptadosupervisadorechazado CHAR(1); --DEFAULT BLANCO
DEFINE vclientenuevo CHAR(1); --DEFAULT BLANCO
DEFINE vcreditojoven CHAR(1); --DEFAULT BLANCO
DEFINE vlugartrabajo CHAR(20); --DEFAULT BLANCO
DEFINE vciudadtrabajo SMALLINT; --DEFAULT 0
DEFINE vcoloniatrabajo  SMALLINT; --DEFAULT 0
DEFINE vcalletrabajo INTEGER; --DEFAULT 0
DEFINE snumerocasatrabajo INTEGER; --DEFAULT 0
DEFINE vdeptoointeriortrabajo CHAR(4); --DEFAULT BLANCO
DEFINE vrumbotrabajo CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementotrabajo CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallestrabajo CHAR(40); --DEFAULT BLANCO
DEFINE vflaguht SMALLINT; --DEFAULT 0
DEFINE vuhtmanzana SMALLINT; --DEFAULT 0
DEFINE vuhtotros SMALLINT; --DEFAULT 0
DEFINE vuhtandador SMALLINT; --DEFAULT 0
DEFINE vuhtetapa SMALLINT; --DEFAULT 0
DEFINE vuhtlote SMALLINT; --DEFAULT 0
DEFINE vuhtedificio SMALLINT; --DEFAULT 0
DEFINE vuhtentrada SMALLINT; --DEFAULT 0
DEFINE vtelefonotrabajo INT8; --DEFAULT 0
DEFINE vextensiontrabajo INTEGER; --DEFAULT 0
DEFINE vpuesto CHAR(1); --DEFAULT BLANCO
DEFINE vopcionpuesto SMALLINT; --DEFAULT 0
DEFINE cfechaantiguedtrab CHAR(10);
--CONYUGE
DEFINE vclienteconyuge CHAR(20); --DEFAULT 0
DEFINE vnombreunoconyuge CHAR(26); --DEFAULT BLANCO
DEFINE vnombredosconyuge CHAR(26); --DEFAULT BLANCO
DEFINE vapellidopaternoconyuge CHAR(26); --DEFAULT BLANCO
DEFINE vapellidomaternoconyuge CHAR(26); --DEFAULT BLANCO
DEFINE cSexoConyuge CHAR(1); --DEFAULT BLANCO
DEFINE vlugartrabajoconyuge CHAR(20); --DEFAULT BLANCO
DEFINE vciudadconyuge SMALLINT; --DEFAULT 0
DEFINE vcoloniaconyuge INTEGER; --DEFAULT 0
DEFINE vcalletrabajoconyuge INTEGER; --DEFAULT 0
DEFINE snumerocasaconyugue INTEGER; --DEFAULT 0
DEFINE vdeptoointeriorconyuge CHAR(4); --DEFAULT BLANCO
DEFINE vrumbotrabajoconyuge CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementoconyuge CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallesconyuge CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhy SMALLINT; --DEFAULT 0
DEFINE vuhymanzana SMALLINT; --DEFAULT 0
DEFINE vuhyotros SMALLINT; --DEFAULT 0
DEFINE vuhyandador  SMALLINT; --DEFAULT 0
DEFINE vuhyetapa SMALLINT; --DEFAULT 0 
DEFINE vuhylote SMALLINT; --DEFAULT 0
DEFINE vuhyedificio SMALLINT; --DEFAULT 0
DEFINE vuhyentrada SMALLINT; --DEFAULT 0
DEFINE vtelefonotrabajoconyuge INT8; --DEFAULT 0
DEFINE vtelefonocelularconyuge INT8; --DEFAULT 0
DEFINE vclaveconyugefamilia CHAR (1);
--REFERENCIA 1
DEFINE vclientereferencia CHAR(20); --DEFAULT 0
DEFINE vnombreunoreferencia CHAR(26); --DEFAULT BLANCO
DEFINE vnombredosreferencia CHAR(26); --DEFAULT BLANCO
DEFINE vapellidopaternoreferencia CHAR(26); --DEFAULT BLANCO
DEFINE vapellidomaternoreferencia CHAR(26); --DEFAULT BLANCO
DEFINE cSexoReferencia CHAR(1); --DEFAULT BLANCO
DEFINE vciudadreferencia SMALLINT; --DEFAULT 0
DEFINE vcoloniareferencia INTEGER; --DEFAULT 0
DEFINE vcallereferencia INTEGER; --DEFAULT 0
DEFINE snumerocasaref INTEGER; --DEFAULT 0
DEFINE vdeptoointeriorreferencia CHAR(4); --DEFAULT BLANCO
DEFINE vrumboreferencia CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementoreferencia CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallesreferencia1 CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhr SMALLINT; --DEFAULT 0
DEFINE vuhrmanzana SMALLINT; --DEFAULT 0
DEFINE vuhrotros SMALLINT; --DEFAULT 0
DEFINE vuhrandador SMALLINT; --DEFAULT 0
DEFINE vuhretapa SMALLINT; --DEFAULT 0
DEFINE vuhrlote SMALLINT; --DEFAULT 0
DEFINE vuhredificio SMALLINT; --DEFAULT 0
DEFINE vuhrentrada SMALLINT; --DEFAULT 0
DEFINE vtelefonoreferencia INT8; --DEFAULT 0       
DEFINE vtelefonocelularreferencia INT8; --DEFAULT 0
DEFINE vclavereferencia1 CHAR(1); --DEFAULT BLANCO
--REFERENCIA 2
DEFINE vclientereferencia2 CHAR(20); --DEFAULT 0
DEFINE vnombreunoreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE vnombredosreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE vapellidopaternoreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE vapellidomaternoreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE cSexoReferencia2 CHAR(1); --DEFAULT BLANCO
DEFINE vciudadreferencia2 SMALLINT; --DEFAULT 0
DEFINE vcoloniareferencia2 INTEGER; --DEFAULT 0
DEFINE vcallereferencia2 INTEGER; --DEFAULT 0
DEFINE snumerocasaref2 INTEGER; --DEFAULT 0
DEFINE vdeptoointeriorreferencia2 CHAR(4); --DEFAULT BLANCO
DEFINE vrumboreferencia2 CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementoreferencia2 CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallesreferencia2 CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhr2 SMALLINT; --DEFAULT 0
DEFINE vuhrmanzana2 SMALLINT; --DEFAULT 0
DEFINE vuhrotros2 SMALLINT; --DEFAULT 0
DEFINE vuhrandador2 SMALLINT; --DEFAULT 0
DEFINE vuhretapa2 SMALLINT; --DEFAULT 0
DEFINE vuhrlote2 SMALLINT; --DEFAULT 0
DEFINE vuhredificio2 SMALLINT; --DEFAULT 0
DEFINE vuhrentrada2 SMALLINT; --DEFAULT 0
DEFINE vtelefonoreferencia2 INT8; --DEFAULT 0
DEFINE vtelefonocelularreferencia2 INT8; --DEFAULT 0
DEFINE vclavereferencia2 CHAR(1); --DEFAULT BLANCO
------
DEFINE vreferencia2 INTEGER; --DEFAULT 0
DEFINE vreferencia3 INTEGER; --DEFAULT 0
DEFINE vmarcadatosin CHAR(1); --DEFAULT BLANCO
DEFINE vtiporeposicion SMALLINT; --DEFAULT 2
DEFINE vreposicion INTEGER; --DEFAULT 0
DEFINE vflagentregotarjeta CHAR(1); --DEFAULT BLANCO
DEFINE vefectuo INTEGER;
DEFINE vtiendafolio SMALLINT;
DEFINE vfolio CHAR(20); --DEFAULT 0
DEFINE cfechaaltacte CHAR (10);
DEFINE vflagnoreconocehuella CHAR(1); --DEFAULT BLANCO
DEFINE vfoliotienda INTEGER; --DEFAULT 0
DEFINE vrfc CHAR(13); --DEFAULT BLANCO
DEFINE vcveburo CHAR(2); --DEFAULT BLANCO
DEFINE vfolioaut CHAR(4); --DEFAULT BLANCO
DEFINE vfolioconsulta CHAR(9); --DEFAULT BLANCO
DEFINE vfolioconcir CHAR(10); --DEFAULT BLANCO
DEFINE vnegocio SMALLINT; --DEFAULT 0
DEFINE vsubnegocio SMALLINT; --DEFAULT 0
DEFINE vempleadoautorizo INTEGER; --DEFAULT 0
DEFINE vtipo CHAR(1); --DEFAULT BLANCO
DEFINE cfechamovto CHAR (19); 
DEFINE vnumerosolicituddecredito CHAR(20); --DEFAULT 0
DEFINE vnumcte CHAR(20); --DEFAULT BLANCO
DEFINE vtiendafolioanterior SMALLINT;
DEFINE vfolioanterior INTEGER; --DEFAULT 0
DEFINE vclaveproducto SMALLINT; --DEFAULT 0
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
DEFINE vTipoOrigen CHAR(1); --DEFAULT BLANCO
DEFINE vTipoProducto CHAR(5); --DEFAULT BLANCO
--Modificacion Campos nuevos
DEFINE iEmpleadoSubCob INTEGER; --DEFAULT 0
DEFINE sFlagCapHuella SMALLINT; --DEFAULT 0
DEFINE cMarcarConsultado CHAR(2); --DEFAULT BLANCO
DEFINE sFlagTestParametrico SMALLINT; --DEFAULT 0
DEFINE sFlagCapCobranza SMALLINT; --DEFAULT 0
DEFINE iEmpleadoGteAutori INTEGER; --DEFAULT 0
DEFINE cFlagConsBuro CHAR(2); --DEFAULT BLANCO
DEFINE cBuroPilotoTestig CHAR(1); --DEFAULT BLANCO
DEFINE cNacionalidad CHAR(3); --DEFAULT BLANCO
DEFINE cNoFm3 CHAR(18); --DEFAULT BLANCO
DEFINE cEmail CHAR(60); --DEFAULT BLANCO
DEFINE cApellCasada CHAR(26); --DEFAULT BLANCO
DEFINE cPais CHAR(3); --DEFAULT BLANCO
DEFINE cNoIMSS CHAR(12); --DEFAULT BLANCO
DEFINE cEstado CHAR(3); --DEFAULT BLANCO
DEFINE cDelegMunicip CHAR(3); --DEFAULT BLANCO
DEFINE cNumInterior CHAR(4); --DEFAULT BLANCO
DEFINE sPropNegocio SMALLINT; --DEFAULT 0
DEFINE sParCelulares SMALLINT; --DEFAULT 0 
DEFINE sParAltoRiesgo SMALLINT; --DEFAULT 0
DEFINE sParPrestamo SMALLINT; --DEFAULT 0
DEFINE cModeloCel CHAR(1); --DEFAULT BLANCO
DEFINE cFechaConsBuro CHAR(10); --DEFAULT 1900/01/01
DEFINE iMontoIngMensual INTEGER; --DEFAULT 0
DEFINE iCapSistematicabono INTEGER; --DEFAULT 0
DEFINE iTopeAbonoCoppel INTEGER; --DEFAULT 0
DEFINE iLineaCrediTope INTEGER; --DEFAULT 0
DEFINE iCapMaximaAbono INTEGER; --DEFAULT 0
DEFINE iCapRealAbono INTEGER; --DEFAULT 0
DEFINE iLineaCredReal INTEGER; --DEFAULT 0 
DEFINE iCompromisosSic INTEGER; --DEFAULT 0
DEFINE iFlagLineaCredEsp INTEGER; --DEFAULT 0
DEFINE cClienteConyugebcpl CHAR(20); --DEFAULT BLANCO
DEFINE cClienteReferencia1bcpl CHAR(20); --DEFAULT BLANCO
DEFINE cClienteReferencia2bcpl CHAR(20); --DEFAULT BLANCO
DEFINE vreposicionr CHAR(9);
DEFINE cTipocliente CHAR(1);
DEFINE iBandera INTEGER;
DEFINE iContador INTEGER;
DEFINE cEmpresa CHAR(3);

--OTRAS VARIABLES
DEFINE cFolioSucursal CHAR(4);
DEFINE vHora DATETIME HOUR TO FRACTION(3);
DEFINE vfechaaltacliente DATE;
DEFINE vFecha_Hoy DATE;
DEFINE vsSQL LVARCHAR (32000);
DEFINE vsSQL1 LVARCHAR (32000);
DEFINE vsSQL2 LVARCHAR (32000);
DEFINE vsSQL3 LVARCHAR (32000);
DEFINE vsSQL4 LVARCHAR (32000);
DEFINE vsSQL5 LVARCHAR (32000);
DEFINE vsSQL6 LVARCHAR (32000);
DEFINE vsSQLExtraviadas2 LVARCHAR (32000);
DEFINE vsSQLExtraviadas3 LVARCHAR (32000);
DEFINE vsSQLcv LVARCHAR (32000);
DEFINE iSqlErr INTEGER;
DEFINE vCodRetorno Char(6);
DEFINE iPuntuacion INTEGER;
DEFINE cFecha_hoy CHAR (10);
DEFINE iSecuencia INTEGER;
DEFINE cMarcaHit CHAR(2);
DEFINE iSecAdic INTEGER;
DEFINE iCuentaRegistros INTEGER;


--SET DEBUG FILE TO '/tmp/sp_GeneraArchivoAdicionalesPrueba.out';
--TRACE ON;

-- INICIALIZACION DE VARIABLES
--CLIENTE
LET vClave = 'C'; --DEFAULT C
LET vcaja = 0; --dbs-17/09/2012
LET varea = ''; --DEFAULT BLANCO --dsb-17/09/2012
LET vcliente_ref = '0'; --Cliente Coppel --INT
LET vnombre1 = ''; --DEFAULT BLANCO
LET vnombre2 = ''; --DEFAULT BLANCO
LET vapell_paterno = ''; --DEFAULT BLANCO
LET vapell_materno = ''; --DEFAULT BLANCO
LET vcurp = ''; --DEFAULT BLANCO
LET vclaveelector = ''; --DEFAULT BLANCO
LET vclaveidentificacion = ''; --DEFAULT BLANCO
LET videntificacion = ''; --DEFAULT BLANCO
LET vciudad = 0; --DEFAULT 0
LET vcolonia = 0; --DEFAULT 0
LET vcalle = 0; --DEFAULT 0
LET snumerocasa = 0; --DEFAULT 0
LET vdeptointerior = ''; --DEFAULT BLANCO
LET vrumbo = ''; --DEFAULT BLANCO
LET vcomplemento = ''; --DEFAULT BLANCO
LET ventrecalles = ''; --DEFAULT BLANCO
LET vflaguhc = 0; --DEFAULT 0
LET vuhcmanzana = 0; --DEFAULT 0
LET vuhcotros = 0; --DEFAULT 0
LET vuhcandador = 0; --DEFAULT 0
LET vuhcetapa = 0; --DEFAULT 0
LET vuhclote  = 0; --DEFAULT 0
LET vuhcedificio = 0; --DEFAULT 0
LET vuhcentrada = 0; --DEFAULT 0
LET vtelefono = 0; --DEFAULT 0
LET vtelefonocelular = 0; --DEFAULT 0
LET vcasapropia = ''; --DEFAULT BLANCO
LET vniptitular = ''; --DEFAULT BLANCO
LET vnipadicional = ''; --DEFAULT A --dsb-17/09/2012
LET vsexo = ''; --DEFAULT BLANCO
LET vestadocivil = ''; --DEFAULT BLANCO
LET cfechanac = '1900/01/01';
LET cfechadesdecuandovive = '1900/01/01';
LET vpersonasvivenendomicilio = 0; --DEFAULT 0
LET vescolaridad = ''; --DEFAULT BLANCO
LET vtiposueldo = ''; --DEFAULT BLANCO
LET vnumerodependientes = 0; --DEFAULT 0
LET vpersonastrabajan = 0; --DEFAULT 0
LET vlimitecredito = 0; --DEFAULT 0 
LET vingresomensual = 0; --DEFAULT 0
LET vsituacionespecial = ''; --DEFAULT BLANCO
LET vcausasituacionespecial = 0; --DEFAULT 0
LET vclaveautrechaza = ''; --DEFAULT BLANCO
LET vaceptadosupervisadorechazado = ''; --DEFAULT BLANCO
LET vclientenuevo = ''; --DEFAULT BLANCO
LET vcreditojoven = ''; --DEFAULT BLANCO
LET vlugartrabajo = ''; --DEFAULT BLANCO
LET vciudadtrabajo = 0; --DEFAULT 0
LET vcoloniatrabajo  = 0; --DEFAULT 0
LET vcalletrabajo  = 0; --DEFAULT 0
LET snumerocasatrabajo = 0; --DEFAULT 0
LET vdeptoointeriortrabajo = ''; --DEFAULT BLANCO
LET vrumbotrabajo = ''; --DEFAULT BLANCO
LET vcomplementotrabajo = ''; --DEFAULT BLANCO
LET ventrecallestrabajo = ''; --DEFAULT BLANCO
LET vflaguht = 0; --DEFAULT 0
LET vuhtmanzana = 0; --DEFAULT 0
LET vuhtotros = 0; --DEFAULT 0
LET vuhtandador = 0; --DEFAULT 0
LET vuhtetapa = 0; --DEFAULT 0
LET vuhtlote = 0; --DEFAULT 0
LET vuhtedificio = 0; --DEFAULT 0
LET vuhtentrada = 0; --DEFAULT 0
LET vtelefonotrabajo = 0; --DEFAULT 0
LET vextensiontrabajo = 0; --DEFAULT 0
LET vpuesto = ''; --DEFAULT BLANCO
LET vopcionpuesto = 0; --DEFAULT 0
LET cfechaantiguedtrab = '1900/01/01'; 
--CONYUGE
LET vclienteconyuge = '0'; --DEFAULT 0
LET vnombreunoconyuge = ''; --DEFAULT BLANCO
LET vnombredosconyuge = ''; --DEFAULT BLANCO
LET vapellidopaternoconyuge = ''; --DEFAULT BLANCO
LET vapellidomaternoconyuge = ''; --DEFAULT BLANCO
LET cSexoConyuge = ''; --DEFAULT BLANCO
LET vlugartrabajoconyuge = ''; --DEFAULT BLANCO
LET vciudadconyuge = 0; --DEFAULT 0
LET vcoloniaconyuge = 0; --DEFAULT 0
LET vcalletrabajoconyuge = 0; --DEFAULT 0
LET snumerocasaconyugue = 0; --DEFAULT 0
LET vdeptoointeriorconyuge = ''; --DEFAULT BLANCO
LET vrumbotrabajoconyuge = ''; --DEFAULT BLANCO
LET vcomplementoconyuge = ''; --DEFAULT BLANCO
LET ventrecallesconyuge = ''; --DEFAULT BLANCO
LET vflaguhy = 0; --DEFAULT 0
LET vuhymanzana = 0; --DEFAULT 0
LET vuhyotros = 0; --DEFAULT 0
LET vuhyandador  = 0; --DEFAULT 0
LET vuhyetapa = 0; --DEFAULT 0
LET vuhylote = 0; --DEFAULT 0
LET vuhyedificio = 0; --DEFAULT 0
LET vuhyentrada = 0; --DEFAULT 0
LET vtelefonotrabajoconyuge = 0; --DEFAULT 0
LET vtelefonocelularconyuge = 0; --DEFAULT 0
LET vclaveconyugefamilia = ''; --DEFAULT BLANCO
--REFERENCIA 1
LET vclientereferencia = '0'; --DEFAULT 0
LET vnombreunoreferencia = ''; --DEFAULT BLANCO
LET vnombredosreferencia = ''; --DEFAULT BLANCO
LET vapellidopaternoreferencia = ''; --DEFAULT BLANCO
LET vapellidomaternoreferencia = ''; --DEFAULT BLANCO
LET cSexoReferencia = ''; --DEFAULT BLANCO
LET vciudadreferencia = 0; --DEFAULT 0
LET vcoloniareferencia = 0; --DEFAULT 0
LET vcallereferencia = 0; --DEFAULT 0
LET snumerocasaref = 0; --DEFAULT 0
LET vdeptoointeriorreferencia = ''; --DEFAULT BLANCO
LET vrumboreferencia = ''; --DEFAULT BLANCO
LET vcomplementoreferencia = ''; --DEFAULT BLANCO
LET ventrecallesreferencia1 = ''; --DEFAULT BLANCO
LET vflaguhr = 0; --DEFAULT 0
LET vuhrmanzana = 0 ; --DEFAULT 0
LET vuhrotros = 0 ; --DEFAULT 0
LET vuhrandador = 0; --DEFAULT 0
LET vuhretapa = 0; --DEFAULT 0
LET vuhrlote = 0; --DEFAULT 0
LET vuhredificio = 0; --DEFAULT 0
LET vuhrentrada = 0; --DEFAULT 0
LET vtelefonoreferencia = 0; --DEFAULT 0   
LET vtelefonocelularreferencia = 0; --DEFAULT 0
LET vclavereferencia1 = ''; --DEFAULT BLANCO
--REFERENCIA 2
LET vclientereferencia2 = '0'; --DEFAULT 0
LET vnombreunoreferencia2 = ''; --DEFAULT BLANCO
LET vnombredosreferencia2 = ''; --DEFAULT BLANCO
LET vapellidopaternoreferencia2 = ''; --DEFAULT BLANCO
LET vapellidomaternoreferencia2 = ''; --DEFAULT BLANCO
LET cSexoReferencia2 = ''; --DEFAULT BLANCO
LET vciudadreferencia2 = 0; --DEFAULT 0 
LET vcoloniareferencia2 = 0; --DEFAULT 0
LET vcallereferencia2 = 0; --DEFAULT 0
LET snumerocasaref2 = 0; --DEFAULT 0
LET vdeptoointeriorreferencia2 = ''; --DEFAULT BLANCO
LET vrumboreferencia2 = ''; --DEFAULT BLANCO
LET vcomplementoreferencia2 = ''; --DEFAULT BLANCO
LET ventrecallesreferencia2 = ''; --DEFAULT BLANCO
LET vflaguhr2 = 0; --DEFAULT 0 
LET vuhrmanzana2 = 0; --DEFAULT 0
LET vuhrotros2 = 0; --DEFAULT 0
LET vuhrandador2 = 0; --DEFAULT 0
LET vuhretapa2 = 0; --DEFAULT 0
LET vuhrlote2 = 0; --DEFAULT 0
LET vuhredificio2 = 0; --DEFAULT 0
LET vuhrentrada2 = 0; --DEFAULT 0
LET vtelefonoreferencia2 = 0; --DEFAULT 0
LET vtelefonocelularreferencia2 = 0; --DEFAULT 0
LET vclavereferencia2 = ''; --DEFAULT BLANCO
------
LET vreferencia2 = 0; --DEFAULT 0
LET vreferencia3 = 0; --DEFAULT 0
LET vmarcadatosin = ''; --DEFAULT BLANCO
LET vtiporeposicion = 2; --DEFAULT 2 --dsb-17/09/2012
LET vreposicion = 0; --DEFAULT 0
LET vflagentregotarjeta = 'A'; --DEFAULT BLANCO --dsb-17/09/2012
LET vefectuo = 0;
LET vtiendafolio = 0;
LET vfolio = '0'; --DEFAULT 0
LET cfechaaltacte = '1900/01/01';
LET vflagnoreconocehuella = ''; --DEFAULT BLANCO
LET vfoliotienda = 0; --DEFAULT 0
LET vrfc = ''; 
LET vcveburo = ''; --DEFAULT BLANCO
LET vfolioaut = ''; --DEFAULT BLANCO
LET vfolioconsulta = ''; --DEFAULT BLANCO
LET vfolioconcir = ''; --DEFAULT BLANCO
LET vnegocio = 0; --DEFAULT 0
LET vsubnegocio = 0; --DEFAULT 0
LET vempleadoautorizo = 0; --DEFAULT 0
LET vtipo = ''; --DEFAULT BLANCO
LET cfechamovto = '1900/01/01';
LET vnumerosolicituddecredito = '0'; --DEFAULT 0
LET vnumcte = '';
LET vtiendafolioanterior = 0; --DEFAULT 0
LET vfolioanterior = 0; --DEFAULT 0
LET vclaveproducto = 0; --6500
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
LET vTipoOrigen = ''; --DEFAULT BLANCO
LET vTipoProducto = '01000'; --DEFAULT BLANCO
--Modificacion Campos nuevos
LET iEmpleadoSubCob = 0; --DEFAULT 0
LET sFlagCapHuella = 0; --DEFAULT 0
LET cMarcarConsultado = ''; --DEFAULT BLANCO
LET sFlagTestParametrico = 0; --DEFAULT 0
LET sFlagCapCobranza = 0; --DEFAULT 0
LET iEmpleadoGteAutori = 0; --DEFAULT 0
LET cFlagConsBuro = ''; --DEFAULT BLANCO
LET cBuroPilotoTestig = ''; --DEFAULT BLANCO
LET cNacionalidad = ''; --DEFAULT BLANCO
LET cNoFm3 = ''; --DEFAULT BLANCO
LET cEmail = ''; --DEFAULT BLANCO
LET cApellCasada = ''; --DEFAULT BLANCO
LET cPais = ''; --DEFAULT BLANCO
LET cNoIMSS = ''; --DEFAULT BLANCO
LET cEstado = ''; --DEFAULT BLANCO
LET cDelegMunicip = ''; --DEFAULT BLANCO
LET cNumInterior = ''; --DEFAULT BLANCO
LET sPropNegocio = 0; --DEFAULT 0
LET sParCelulares = 0; --DEFAULT 0 
LET sParAltoRiesgo = 0; --DEFAULT 0
LET sParPrestamo = 0; --DEFAULT 0
LET cModeloCel = ''; --DEFAULT BLANCO
LET cFechaConsBuro = '1900/01/01';
LET iMontoIngMensual = 0; --DEFAULT 0
LET iCapSistematicabono = 0; --DEFAULT 0
LET iTopeAbonoCoppel = 0; --DEFAULT 0
LET iLineaCrediTope = 0; --DEFAULT 0
LET iCapMaximaAbono = 0; --DEFAULT 0
LET iCapRealAbono = 0; --DEFAULT 0
LET iLineaCredReal = 0; --DEFAULT 0
LET iCompromisosSic = 0; --DEFAULT 0
LET iFlagLineaCredEsp = 0; --DEFAULT 0
LET cClienteConyugebcpl = ''; --DEFAULT BLANCO
LET cClienteReferencia1bcpl = ''; --DEFAULT BLANCO
LET cClienteReferencia2bcpl = ''; --DEFAULT BLANCO
LET vreposicionr =''; --DEFAULT BLANCO
LET cTipocliente=''; --DEFAULT BLANCO
LET iBandera=0; -- DEFAULT 0
LET iContador=0;LET cEmpresa=pempresa; --DEFAULT BLANCO
--OTRAS VARIABLES
LET cFolioSucursal = '820'; --DSB-17/09/2012
LET vHora = '';
LET vfechaaltacliente = DATE(1);
LET vFecha_Hoy = DATE(1);
LET vsSQL = ''; --DEFAULT BLANCO
LET vsSQL1 =''; --DEFAULT BLANCO
LET vsSQL2 =''; --DEFAULT BLANCO
LET vsSQL3 =''; --DEFAULT BLANCO
LET vsSQL4 =''; --DEFAULT BLANCO
LET vsSQL5 =''; --DEFAULT BLANCO
LET vsSQL6 =''; --DEFAULT BLANCO
LET vsSQLExtraviadas2 = '';
LET vsSQLExtraviadas3 = '';
LET vsSQLcv ='';
LET iSqlErr =0;
LET vCodRetorno = '000000';
LET iPuntuacion = 0;
LET cFecha_hoy = '1900/01/01';
LET iSecuencia = 0;
LET cMarcaHit = '';
LET iSecAdic = 0;
LET iCuentaRegistros = 0;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		SET DEBUG FILE TO '/RESPALDOSNEW/sp_GeneraArchivoAdicionalesPrueba.out';
		TRACE ON;
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
		
		--SECUENCIA DE ARCHIVO
		IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
			IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscopdiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
				LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscopdiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
			ELSE
				LET iSecuencia = (SELECT NVL(MAX(secuencia), 0) + 1  FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
			END IF;
		ELSE
			IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscopdiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
				LET iSecuencia = (SELECT MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscopdiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
			ELSE
				LET iSecuencia = 1;
			END IF;
		END IF;
		
			---GENERAR ARCHIVO ADICIONAL PARA CLAVE "C"
			FOREACH			   
				SELECT numctebanco, numctecoppel,numtarjeta, secuencia, fecha,tipocliente
				INTO vnumcte, vcliente_ref, vreposicionr,iSecAdic, vfechaaltacliente,cTipocliente
				FROM bditarjcop:"informix".detallerepadic
				WHERE secuencia > 0 AND tipocliente IN('A','T')				
				AND fecha = pFechaAct
				
				IF vnumcte <> '' AND vcliente_ref <> '' THEN
				  
				  	SELECT nombre1, nombre2, apell_paterno, apell_materno
					INTO vnombre1,vnombre2, vapell_paterno,vapell_materno
					FROM bdinteg:"informix".si_cliente
					WHERE numcte = vnumcte;
					
					SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
					--DA FORMATO A LAS FECHAS

					LET cfechaaltacte = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH (vfechaaltacliente),2,0)||"/"||LPAD(DAY(vfechaaltacliente),2,0);
				
					IF pFechaAct <> vFecha_Hoy THEN
						LET cfechamovto = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
					ELSE
						LET cfechamovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
					END IF;					
					
					WHILE iBandera = 0
						
						IF cTipocliente = 'A' AND iContador = 0  THEN	--ADICIONAL C
							LET vclave ='C';
							LET vcaja = 0;
							LET vnipadicional = 'A'; 
							LET varea = '';
							LET vflagentregotarjeta ='A';
							LET vreposicion =0;
							LET vsSQLcv = TRIM(vclave)||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(vcliente_ref)||"|||||";
							
							SELECT sucursal, user_insert
								INTO cFolioSucursal, vefectuo
							FROM bdinteg:"informix".si_adiccoppel
							WHERE numcte = vnumcte AND secuencia > 1 AND numtarcoppel = vcliente_ref;

						ELIF cTipocliente = 'A' AND iContador = 1 THEN	--ADICIONAL R
							LET vclave ='R';
							LET vcaja = 100;
							LET varea = 'N';
							LET vnipadicional = '';
							LET vsSQLcv = TRIM(vclave)||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(vcliente_ref)||"|"||TRIM(vnombre1)||"|"||TRIM(vnombre2)||"|"||TRIM(vapell_paterno)||"|"||TRIM(vapell_materno)||"|";
							LET vflagentregotarjeta = 'A';
							LET vreposicion = vreposicionr;
							LET iBandera =1;
							LET iContador =0;							
													
							SELECT sucursal, user_insert
								INTO cFolioSucursal, vefectuo
							FROM bdinteg:"informix".si_adiccoppel
							WHERE numcte = vnumcte AND secuencia > 1 AND numtarcoppel = vcliente_ref;

						ELIF cTipocliente = 'T' AND isecuencia >= 1  THEN  --REPOSICION DE TARJETA
							LET vclave ='R';
							LET vcaja = 100;
							LET varea = 'N';
							LET vnipadicional = '';
							LET vsSQLcv = TRIM(vclave)||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(vcliente_ref)||"|"||TRIM(vnombre1)||"|"||TRIM(vnombre2)||"|"||TRIM(vapell_paterno)||"|"||TRIM(vapell_materno)||"|";
							LET vreposicion = vreposicionr;
							LET vflagentregotarjeta ='A';							
							LET iBandera =1;
							LET iContador =0;
							LET vtiporeposicion = 0;
							
							SELECT sucursal, user_insert
								INTO cFolioSucursal, vefectuo
							FROM bdinteg:"informix".si_adiccoppel
							WHERE numcte = vnumcte AND secuencia = 1;
							
						END IF;
						LET iContador = iContador +1;
						IF cFolioSucursal IS NULL THEN 
							LET cFolioSucursal=0;
						END IF;
						IF vefectuo IS NULL THEN
							LET vefectuo=0;
						END IF;						
						LET vsSQL = TRIM(vcurp)||"|"||TRIM(vclaveelector)||"|"||TRIM(vclaveidentificacion)||"|"||TRIM(videntificacion)||"|"||vciudad||"|"||vcolonia||"|"||vcalle||"|"||snumerocasa||"|"||TRIM(vdeptointerior)||"|" ||TRIM(vrumbo);
						LET vsSQL = vsSQL || "|" ||TRIM(vcomplemento)||"|"||TRIM(ventrecalles)||"|"||vflaguhc||"|"||vuhcmanzana||"|"||vuhcotros||"|"||vuhcandador||"|"||vuhcetapa||"|"||vuhclote||"|"
								||vuhcedificio||"|"||vuhcentrada||"|"||vtelefono||"|"||vtelefonocelular;
						LET vsSQL1 = TRIM(vsSQL);
						LET vsSQL = TRIM(vsSQL)||"|"|| TRIM(vcasapropia);						
						LET vsSQL2 ="|"|| TRIM(vniptitular)||"|"||TRIM(vnipadicional)||"|"||TRIM(vsexo)||"|" ||TRIM(vestadocivil)||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadesdecuandovive, '1900/01/01'))||"|"||vpersonasvivenendomicilio||"|"||TRIM(vescolaridad)||"|"||TRIM(vtiposueldo);
						LET vsSQL2 = vsSQL2 || "|"  ||vnumerodependientes||"|"||vpersonastrabajan||"|"||vlimitecredito||"|"||vingresomensual||"|"||TRIM(vsituacionespecial)||"|"||vcausasituacionespecial||"|"
								||TRIM(vclaveautrechaza)||"|" ||TRIM(vaceptadosupervisadorechazado);
						LET vsSQL = TRIM(vsSQL)||TRIM(vsSQL2);		
						LET vsSQL = TRIM(vsSQL)||"|"|| TRIM(vclientenuevo);	
						LET vsSQL3 ="|"||TRIM(vcreditojoven)||"|"||TRIM(vlugartrabajo)||"|"||vciudadtrabajo||"|"||vcoloniatrabajo||"|"||vcalletrabajo||"|"||snumerocasatrabajo||"|"||TRIM(vdeptoointeriortrabajo)||"|"||TRIM(vrumbotrabajo)||"|"||TRIM(vcomplementotrabajo)||"|"||TRIM(ventrecallestrabajo);
						LET vsSQL = TRIM(vsSQL)|| TRIM(vsSQL3);																
						LET vsSQL4 = "|" ||vflaguht||"|"||vuhtmanzana||"|"||vuhtotros||"|"||vuhtandador||"|"||vuhtetapa||"|"||vuhtlote||"|"||vuhtedificio||"|"||vuhtentrada||"|"||vtelefonotrabajo||"|" 
								||vextensiontrabajo||"|"||TRIM(vpuesto)||"|"||vopcionpuesto||"|"||TRIM(NVL(cfechaantiguedtrab, '1900/01/01'))||"|"||TRIM(vclienteconyuge)||"|"||TRIM(vnombreunoconyuge)||"|"||TRIM(vnombredosconyuge)||"|"
								||TRIM(vapellidopaternoconyuge)||"|"||TRIM(vapellidomaternoconyuge)||"|"||TRIM(cSexoConyuge)||"|"||TRIM(vlugartrabajoconyuge)||"|"||vciudadconyuge||"|"||vcoloniaconyuge||"|"||vcalletrabajoconyuge||"|" 
								||snumerocasaconyugue||"|"||TRIM(vdeptoointeriorconyuge)||"|"||TRIM(vrumbotrabajoconyuge)||"|"||TRIM(vcomplementoconyuge)||"|"||TRIM(ventrecallesconyuge);
						LET vsSQL4 = vsSQL4|| "|" ||vflaguhy||"|"||vuhymanzana||"|"||vuhyotros||"|"||vuhyandador||"|"||vuhyetapa||"|"||vuhylote||"|"||vuhyedificio||"|"||vuhyentrada||"|"||vtelefonotrabajoconyuge||"|" 
								||vtelefonocelularconyuge||"|"||TRIM(vclaveconyugefamilia)||"|"||TRIM(vclientereferencia)||"|"||TRIM(vnombreunoreferencia)||"|"||TRIM(vnombredosreferencia)||"|"   
								||TRIM(vapellidopaternoreferencia)||"|"||TRIM(vapellidomaternoreferencia)||"|"||TRIM(cSexoReferencia)||"|"||vciudadreferencia||"|"||vcoloniareferencia||"|"||vcallereferencia||"|" 
								||snumerocasaref||"|"||TRIM(vdeptoointeriorreferencia)||"|"||TRIM(vrumboreferencia)||"|"||TRIM(vcomplementoreferencia)||"|"||TRIM(ventrecallesreferencia1)||"|"||vflaguhr||"|" 
								||vuhrmanzana||"|"||vuhrotros||"|"||vuhrandador||"|"||vuhretapa||"|"||vuhrlote||"|"||vuhredificio||"|"||vuhrentrada||"|"||vtelefonoreferencia||"|"||vtelefonocelularreferencia;				  
						LET vsSQL4 = vsSQL4|| "|" ||TRIM(vclavereferencia1)||"|"||TRIM(vclientereferencia2)||"|"||TRIM(vnombreunoreferencia2)||"|"||TRIM(vnombredosreferencia2)||"|"||TRIM(vapellidopaternoreferencia2)||"|"||TRIM(vapellidomaternoreferencia2)||"|" 
								||TRIM(cSexoReferencia2)||"|"||vciudadreferencia2||"|"||vcoloniareferencia2||"|"||vcallereferencia2||"|"||snumerocasaref2||"|"||TRIM(vdeptoointeriorreferencia2)||"|"||TRIM(vrumboreferencia2)||"|" 
								||TRIM(vcomplementoreferencia2)||"|"||TRIM(ventrecallesreferencia2)||"|"||vflaguhr2||"|"||vuhrmanzana2||"|"||vuhrotros2||"|"||vuhrandador2||"|"||vuhretapa2||"|"||vuhrlote2||"|" 
								||vuhredificio2||"|"||vuhrentrada2||"|"||vtelefonoreferencia2||"|"||vtelefonocelularreferencia2||"|"||TRIM(vclavereferencia2)||"|"||vreferencia2||"|"||vreferencia3||"|"||TRIM(vmarcadatosin)||"|" ||vtiporeposicion;
						LET vsSQL5= TRIM (vsSQL4)||"|"||vreposicion;
						LET vsSQL = TRIM(vsSQL)||TRIM(vsSQL5)||"|"||TRIM(vflagentregotarjeta)||"|"||NVL(vefectuo, 0);
						LET vsSQL6 = "|"|| NVL(vtiendafolio, 0) || "|" ||TRIM(vfolio)||"|"||TRIM(NVL(cfechaaltacte, '1900/01/01'))||"|"   
								||TRIM(vflagnoreconocehuella)|| "|"||vfoliotienda||"|"||TRIM(vrfc)||"|"||TRIM(vcveburo)||"|"||TRIM(vfolioaut)||"|"||TRIM(vfolioconsulta)|| "|" ||TRIM(vfolioconcir)|| "|" ||vnegocio||"|"||vsubnegocio|| "|"   
								||vempleadoautorizo|| "|" ||TRIM(vtipo)|| "|";								
						LET vsSQL = TRIM(vsSQL)||TRIM(vsSQL6);								
						LET vsSQL= TRIM(vsSQL)||TRIM(NVL(cfechamovto, '1900/01/01'))||"|"||TRIM(vnumerosolicituddecredito)|| "|"||TRIM(vnumcte)|| "|";						
						LET  vsSQLExtraviadas2=vtiendafolioanterior||"|"||vfolioanterior||"|"||vclaveproducto|| "|" ||vflagactualizacion|| "|" ||vSistsegsocial
						        ||"|"||vTiposueldoext|| "|" ||vNumempleados|| "|" ||vSubopcionpuesto|| "|" ||vPuestoext||"|"||vOpcionpuestoext||"|"
								||vNumempleadosext||"|"||vSubopcionpuestoext||"|";
						LET vsSQL= TRIM(vsSQL)||vsSQLExtraviadas2 ||TRIM(vTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(cFolioSucursal, 0))||"|";
						LET  vsSQLExtraviadas3 =TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||TRIM(cMarcaHit)||"|"
								||iEmpleadoSubCob||"|"||sFlagCapHuella||"|"||TRIM(cMarcarConsultado)||"|"||sFlagTestParametrico||"|"||sFlagCapCobranza||"|"||iEmpleadoGteAutori||"|"||TRIM(NVL(cFlagConsBuro,''))||"|"||TRIM(cBuroPilotoTestig)||"|"||TRIM(NVL(cNacionalidad,''))||"|"||TRIM(NVL(cNoFm3,''))||"|"||TRIM(NVL(cEmail,''))||"|"
								||TRIM(NVL(cApellCasada,''))||"|"||TRIM(NVL(cPais,''))||"|"||TRIM(NVL(cNoIMSS,''))||"|"||TRIM(NVL(cEstado,''))||"|"||TRIM(cDelegMunicip)||"|"||TRIM(NVL(cNumInterior,''))||"|"||sPropNegocio||"|"||sParCelulares||"|"||sParAltoRiesgo||"|"||sParPrestamo||"|"||TRIM(cModeloCel)||"|"
								||NVL(cFechaConsBuro, '1900/01/01')||"|"||NVL(iMontoIngMensual,0)||"|"||NVL(iCapSistematicabono,0)||"|"||NVL(iTopeAbonoCoppel,0)||"|"||NVL(iLineaCrediTope,0)||"|"||NVL(iCapMaximaAbono,0)||"|"||NVL(iCapRealAbono,0)||"|"||NVL(iLineaCredReal,0)||"|"||NVL(iCompromisosSic,0)||"|"||NVL(iFlagLineaCredEsp,0)||"|"
								||TRIM(cClienteConyugebcpl)||"|"||TRIM(cClienteReferencia1bcpl)||"|"||TRIM(cClienteReferencia2bcpl);
						LET vsSQL= TRIM(vsSQL)||vsSQLExtraviadas3;
						LET vsSQL = NVL(vsSQL, '');
						LET vsSQL = TRIM(vsSQLcv)||vsSQL;

						--SE INSERTA LA TRAMA FINAL EN LA TABLA SI_ARCHIVOSCOPPELDIARIO, PERO PARA EFECTO DE PRUEBA SE INSERTARA EN LA TABLA si_archivoscopdiario
						INSERT INTO bdinteg:"informix".si_archivoscopdiario (empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
						VALUES (pempresa,iSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);	
						LET iSecuencia = iSecuencia+1;
						--INSERT INTO bdinteg:"informix".si_archivoscoppeldiario  (empresa,secuencia,sucursal,trama,tipomovto,fecha_insert)
						--VALUES (pempresa,iSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);
					END WHILE;
					LET iCuentaRegistros = 1;
				ELSE
					LET vCodRetorno = '000003';
					LET iCuentaRegistros = 2;
				END IF;
				LET vnombre1 ='';
				LET vnombre2 ='';
				LET vapell_paterno ='';
				LET vapell_materno ='';
				LET vflagentregotarjeta ='';
				LET vreposicionr ='';
				LET iBandera =0;
				LET iContador =0;
				
			END FOREACH;
			--VALORES POR DEFAULT PARA TRAMA DE REPOSICION
			LET vClave = 'A'; --DEFAULT A
			LET vCaja = 100; --DEFAULT 100
			LET varea = 'N'; --DEFAULT N
			LET vnipadicional = '';
	        LET vcasapropia = "E";
			LET vClienteNuevo= "N";
			LET vreposicion=0;
			LET vflagentregotarjeta="A";
			LET vefectuo=0;
			LET vnumerosolicituddecredito='';
			LET vnumcte='';
			
			FOREACH					
					SELECT numtarjeta, cvesucursal,
					YEAR(fechaasignacion)||"/"||LPAD(MONTH(fechaasignacion),2,0)||"/"||LPAD(DAY(fechaasignacion),2,0), estatustarjeta
					INTO vcliente_ref, cFolioSucursal,cFechaMovto,vcasapropia
					FROM bditarjcop:"informix".tarjetasnumtarcop
					WHERE empresa = cEmpresa
					--AND estatustarjeta = 'E' 
					AND estatustarjeta IN ('E', 'C', 'B') --dsb-14/01/2013
					AND DATE(fechaasignacion) = pFechaAct
					--AND YEAR(fechaasignacion) = NVL(YEAR(pFechaAct),YEAR(fechaasignacion))
					--AND MONTH(fechaasignacion) = NVL(MONTH(pFechaAct),MONTH(fechaasignacion))
					--AND DAY(fechaasignacion) = NVL(DAY(pFechaAct),DAY(fechaasignacion))
					UNION ALL
					SELECT numtarjeta, cvesucursal,	
					YEAR(fechaasignacion)||"/"||LPAD(MONTH(fechaasignacion),2,0)||"/"||LPAD(DAY(fechaasignacion),2,0), estatustarjeta
					FROM bditarjcop:"informix".tarjetasrepotarcop
					WHERE empresa = cEmpresa
					AND estatustarjeta IN ('E', 'C', 'B') 
					AND DATE(fechaasignacion) = pFechaAct	
					
					IF cFolioSucursal IS NULL THEN 
						LET cFolioSucursal=0;
					END IF;
					IF vefectuo IS NULL THEN
						LET vefectuo=0;
					END IF;
					IF cFechaMovto IS NULL THEN
						LET cFechaMovto='1900/01/01';
					END IF;

					--DA FORMATO A FECHAS
					LET cFechaAltaCte = cFechaMovto;
					SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
					IF pFechaAct <> vFecha_Hoy OR pFechaAct IS NOT NULL THEN
						LET cFechaMovto = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
					ELSE
						LET cFechaMovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
					END IF;
					
					
					
					LET vsSQL = TRIM(vclave)||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(vcliente_ref)||"|||||";
					LET vsSQL= TRIM(vsSQL)||vsSQL1 ||"|"|| TRIM(vcasapropia)|| TRIM(vsSQL2)||"|"||TRIM(vclientenuevo)||TRIM(vsSQL3) ||TRIM(vsSQL4)||"|"
					          ||vreposicion ||"|"||TRIM(vflagentregotarjeta)||"|"||NVL(vefectuo, 0)||TRIM(vsSQL6)||cFechaMovto||"|"||TRIM(vnumerosolicituddecredito)
							  || "|"||TRIM(vnumcte)|| "|"||vsSQLExtraviadas2||TRIM(vTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(cFolioSucursal, 0))||"|"||vsSQLExtraviadas3;
										
					IF pFechaAct IS NULL THEN
						--SE INSERTA LA TRAMA FINAL EN LA TABLA SI_ARCHIVOSCOPPELDIARIO, PERO PARA EFECTO DE PRUEBA SE INSERTARA EN LA TABLA si_archivoscopdiario
						INSERT INTO bdinteg:"informix".si_archivoscopdiario (empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
						VALUES (cEmpresa,iSecuencia, cFolioSucursal,vsSQL, vclave,vFecha_Hoy); 							
						--	INSERT INTO bdinteg:"informix".si_archivoscoppeldiario(empresa,secuencia, sucursal,trama,tipomovto,fecha_insert)
						--	VALUES (cEmpresa,iSecuencia, cFolioSucursal,cTrama, vclave,vFecha_Hoy);
					ELSE
						--SE INSERTA LA TRAMA FINAL EN LA TABLA SI_ARCHIVOSCOPPELDIARIO, PERO PARA EFECTO DE PRUEBA SE INSERTARA EN LA TABLA si_archivoscopdiario
						INSERT INTO bdinteg:"informix".si_archivoscopdiario (empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
						VALUES (cEmpresa,iSecuencia, cFolioSucursal,vsSQL, vclave,pFechaAct); 				
						--	INSERT INTO bdinteg:"informix".si_archivoscoppeldiario(empresa,secuencia, sucursal,trama,tipomovto,fecha_insert)
						--	VALUES (cEmpresa,iSecuencia, cFolioSucursal,cTrama, vclave,pFechaAct);
					END IF;
					LET iSecuencia = iSecuencia+1;
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
--| Procedimiento   : "informix".sp_genarchiadicionales
--| Version         : 1.0
--| Creado por      : Jesus Manuel Aguilar, Maria Elena Angulo.
--| Fecha creacion  : Febrero de 2013
--| Descripcion 	: Reingeniería sobre la generación de las tramas 
--| correspondientes a los archivos batch generados sobre adicionales y 
--| reposiciones del cliente.
--*************************************************************************
END PROCEDURE;