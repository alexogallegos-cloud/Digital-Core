CREATE PROCEDURE "informix".sp_generaarchivoextraviadas(cEmpresa CHAR(3), dFechaAct DATE)
RETURNING
     CHAR(6) AS CODRET; ---cod_ret
--************************************************************************
--Actualización: Se modifica para que obtenga las tarjetas dadas de baja 'B'.
--Fecha: 09-01-2013
--Autor: Claudio Almodovar
--************************************************************************

--DEFINICION DE VARIABLES
--CLIENTE
DEFINE cClave CHAR(2); --DEFAULT 'R'
DEFINE iCaja SMALLINT;
DEFINE cArea CHAR(1); --DEFAULT 'N'
DEFINE cClienteRef CHAR(20); --NUM CTE COPPEL
DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26);
DEFINE cApellPaterno CHAR(26);
DEFINE cApellMaterno CHAR(26);
DEFINE cCurp CHAR(18);
DEFINE cClaveElector CHAR(18); --DEFAULT BLANCO
DEFINE cClaveIdentificacion CHAR(2); --DEFAULT BLANCO
DEFINE cIdentificacion CHAR(8); --DEFAULT BLANCO
DEFINE iCiudad SMALLINT; --DEFAULT 0
DEFINE iColonia INTEGER; --DEFAULT 0
DEFINE iCalle INTEGER; --DEFAULT 0
DEFINE iNumeroCasa INTEGER; --DEFAULT 0
DEFINE cDeptoInterior CHAR(4); --DEFAULT BLANCO
DEFINE cRumbo CHAR(1); --DEFAULT BLANCO
DEFINE cComplemento CHAR(80); --DEFAULT BLANCO
DEFINE cEntrecalles CHAR(40); --DEFAULT BLANCO
DEFINE iFlaguhc SMALLINT; --DEFAULT 0
DEFINE iUhcmanzana SMALLINT; --DEFAULT 0
DEFINE iUhcotros SMALLINT; --DEFAULT 0
DEFINE iUhcandador SMALLINT; --DEFAULT 0
DEFINE iUhcetapa SMALLINT; --DEFAULT 0
DEFINE iUhclote  SMALLINT; --DEFAULT 0
DEFINE iUhcedificio SMALLINT; --DEFAULT 0
DEFINE iUhcEntrada SMALLINT; --DEFAULT 0
DEFINE iTelefono INT8; --DEFAULT 0
DEFINE iTtelefonoCelular INT8; --DEFAULT 0
DEFINE cCasapropia CHAR(1);
DEFINE cNipTitular CHAR(7); --DEFAULT BLANCO
DEFINE cNipAdicional CHAR(7); --DEFAULT BLANCO
DEFINE cSexo CHAR(1); --DEFAULT BLANCO
DEFINE cEstadoCivil CHAR(1); --DEFAULT BLANCO
DEFINE cFechaNac CHAR(10);
DEFINE cFechaDesdeCuandoVive CHAR(10);
DEFINE iPersonasVivenEnDomicilio INTEGER; --DEFAULT 0
DEFINE cEscolaridad CHAR(1); --DEFAULT BLANCO
DEFINE cTipoSueldo CHAR(1); --DEFAULT BLANCO
DEFINE iNumeroDependientes SMALLINT; --DEFAULT 0
DEFINE iPpersonasTrabajan SMALLINT;
DEFINE iLimiteCredito SMALLINT; --DEFAULT 0
DEFINE iIngresoMensual SMALLINT; --DEFAULT 0
DEFINE cSituacionEspecial CHAR(1); --DEFAULT BLANCO
DEFINE iCausaSituacionEspecial SMALLINT; --DEFAULT 0
DEFINE cClaveAutRechaza CHAR(1); --DEFAULT BLANCO
DEFINE cAceptadoSupervisadoRechazado CHAR(1); --DEFAULT BLANCO
DEFINE cClienteNuevo CHAR(1); --DEFAULT N
DEFINE cCreditoJoven CHAR(1); --DEFAULT BLANCO
DEFINE cLugarTrabajo CHAR(20); --DEFAULT BLANCO
DEFINE iCiudadTrabajo SMALLINT; --DEFAULT 0
DEFINE iColoniaTrabajo  SMALLINT; --DEFAULT 0
DEFINE iCalleTrabajo INTEGER; --DEFAULT 0
DEFINE iNumeroCasaTrabajo INTEGER; --DEFAULT 0
DEFINE cDeptooInteriorTrabajo CHAR(4); --DEFAULT BLANCO
DEFINE cRumboTrabajo CHAR(1); --DEFAULT BLANCO
DEFINE cComplementoTrabajo CHAR(80); --DEFAULT BLANCO
DEFINE cEntreCallesTrabajo CHAR(40); --DEFAULT BLANCO
DEFINE iFlaguht SMALLINT; --DEFAULT 0
DEFINE iUhtManzana SMALLINT; --DEFAULT 0
DEFINE iUhtOtros SMALLINT; --DEFAULT 0
DEFINE iUhtAndador SMALLINT; --DEFAULT 0
DEFINE iUhtEtapa SMALLINT; --DEFAULT 0
DEFINE iUhtLote SMALLINT; --DEFAULT 0
DEFINE iUhtEdificio SMALLINT; --DEFAULT 0
DEFINE iUhtEntrada SMALLINT; --DEFAULT 0
DEFINE iTelefonoTrabajo INT8; --DEFAULT 0
DEFINE iExtensionTrabajo INTEGER; --DEFAULT 0
DEFINE cPuesto CHAR(1); --DEFAULT BLANCO
DEFINE iOpcionPuesto SMALLINT; --DEFAULT 0
DEFINE cFechaAntiguedTrab CHAR(10);
--CONYUGE
DEFINE cClienteConyuge CHAR(20); --DEFAULT 0
DEFINE cNombreUnoConyuge CHAR(26); --DEFAULT BLANCO
DEFINE cNombreDosConyuge CHAR(26); --DEFAULT BLANCO
DEFINE cApellidoPaternoConyuge CHAR(26); --DEFAULT BLANCO
DEFINE cApellidoMaternoConyuge CHAR(26); --DEFAULT BLANCO
DEFINE cSexoConyuge CHAR(1); --DEFAULT BLANCO
DEFINE cLugarTrabajoConyuge CHAR(20); --DEFAULT BLANCO
DEFINE iCiudadConyuge SMALLINT; --DEFAULT 0
DEFINE iColoniaConyuge INTEGER; --DEFAULT 0
DEFINE iCalleTrabajoConyuge INTEGER; --DEFAULT 0
DEFINE iNumeroCasaConyugue INTEGER; --DEFAULT 0
DEFINE cDeptooInteriorConyuge CHAR(4); --DEFAULT BLANCO
DEFINE cRumboTrabajoConyuge CHAR(1); --DEFAULT BLANCO
DEFINE cComplementoConyuge CHAR(80); --DEFAULT BLANCO
DEFINE cEntreCallesConyuge CHAR(40); --DEFAULT BLANCO
DEFINE iFlaguhy SMALLINT; --DEFAULT 0
DEFINE iUhyManzana SMALLINT; --DEFAULT 0
DEFINE iUhyOtros SMALLINT; --DEFAULT 0
DEFINE iUhyAndador  SMALLINT; --DEFAULT 0
DEFINE iUhyEtapa SMALLINT; --DEFAULT 0 
DEFINE iUhyLote SMALLINT; --DEFAULT 0
DEFINE iUhyEdificio SMALLINT; --DEFAULT 0
DEFINE iUhyEntrada SMALLINT; --DEFAULT 0
DEFINE iTelefonoTrabajoConyuge INT8; --DEFAULT 0
DEFINE iTelefonoCelularConyuge INT8; --DEFAULT 0
DEFINE cClaveConyugeFamilia CHAR (1);
--REFERENCIA 1
DEFINE cClienteReferencia CHAR(20); --DEFAULT 0
DEFINE cNombreUnoReferencia CHAR(26); --DEFAULT BLANCO
DEFINE cNombreDosReferencia CHAR(26); --DEFAULT BLANCO
DEFINE cApellidoPaternoReferencia CHAR(26); --DEFAULT BLANCO
DEFINE cApellidoMaternoReferencia CHAR(26); --DEFAULT BLANCO
DEFINE cSexoReferencia CHAR(1); --DEFAULT BLANCO
DEFINE iCiudadReferencia SMALLINT; --DEFAULT 0
DEFINE iColoniaReferencia INTEGER; --DEFAULT 0
DEFINE iCalleReferencia INTEGER; --DEFAULT 0
DEFINE iNumeroCasaRef INTEGER; --DEFAULT 0
DEFINE cDeptooInteriorReferencia CHAR(4); --DEFAULT BLANCO
DEFINE cRumboReferencia CHAR(1); --DEFAULT BLANCO
DEFINE cComplementoReferencia CHAR(80); --DEFAULT BLANCO
DEFINE cEntreCallesReferencia1 CHAR(40); --DEFAULT BLANCO
DEFINE iFlaguhr SMALLINT; --DEFAULT 0
DEFINE iUhrManzana SMALLINT; --DEFAULT 0
DEFINE iUhrOtros SMALLINT; --DEFAULT 0
DEFINE iUhrAndador SMALLINT; --DEFAULT 0
DEFINE iUhrEtapa SMALLINT; --DEFAULT 0
DEFINE iUhrLote SMALLINT; --DEFAULT 0
DEFINE iUhrEdificio SMALLINT; --DEFAULT 0
DEFINE iUhrEntrada SMALLINT; --DEFAULT 0
DEFINE iTelefonoReferencia INT8; --DEFAULT 0       
DEFINE iTelefonoCelularReferencia INT8; --DEFAULT 0
DEFINE cClaveReferencia1 CHAR(1); --DEFAULT BLANCO
--REFERENCIA 2
DEFINE cClienteReferencia2 CHAR(20); --DEFAULT 0
DEFINE cNombreUnoReferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE cNombredosReferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE cApellidoPaternoReferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE cApellidoMaternoReferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE cSexoReferencia2 CHAR(1); --DEFAULT BLANCO
DEFINE iCiudadReferencia2 SMALLINT; --DEFAULT 0
DEFINE iColoniaReferencia2 INTEGER; --DEFAULT 0
DEFINE iCalleReferencia2 INTEGER; --DEFAULT 0
DEFINE iNumeroCasaRef2 INTEGER; --DEFAULT 0
DEFINE cDeptooInteriorReferencia2 CHAR(4); --DEFAULT BLANCO
DEFINE cRumboReferencia2 CHAR(1); --DEFAULT BLANCO
DEFINE cComplementoReferencia2 CHAR(80); --DEFAULT BLANCO
DEFINE cEntreCallesReferencia2 CHAR(40); --DEFAULT BLANCO
DEFINE iFlaguhr2 SMALLINT; --DEFAULT 0
DEFINE iUhrManzana2 SMALLINT; --DEFAULT 0
DEFINE iUhrOtros2 SMALLINT; --DEFAULT 0
DEFINE iUhrAndador2 SMALLINT; --DEFAULT 0
DEFINE iUhrEtapa2 SMALLINT; --DEFAULT 0
DEFINE iUhrLote2 SMALLINT; --DEFAULT 0
DEFINE iUhrEdificio2 SMALLINT; --DEFAULT 0
DEFINE iUhrEntrada2 SMALLINT; --DEFAULT 0
DEFINE iTelefonoReferencia2 INT8; --DEFAULT 0
DEFINE iTelefonoCelularReferencia2 INT8; --DEFAULT 0
DEFINE cClaveReferencia2 CHAR(1); --DEFAULT BLANCO
------
DEFINE iReferencia2 INTEGER; --DEFAULT 0
DEFINE iReferencia3 INTEGER; --DEFAULT 0
DEFINE cMarcadatosin CHAR(1); --DEFAULT BLANCO
DEFINE iTipoReposicion SMALLINT; --DEFAULT 2
DEFINE iReposicion INTEGER; 
DEFINE cFlagEntregoTarjeta CHAR(1); --DEFAULT A
DEFINE iEfectuo INTEGER;
DEFINE iTiendaFolio SMALLINT;
DEFINE cFolio CHAR(20); --DEFAULT 0
DEFINE cFechaAltaCte CHAR (10);
DEFINE cFlagNoReconoceHuella CHAR(1); --DEFAULT BLANCO
DEFINE iFolioTienda INTEGER; --DEFAULT 0
DEFINE cRfc CHAR(13); --DEFAULT BLANCO
DEFINE cCveBuro CHAR(2); --DEFAULT BLANCO
DEFINE cFolioAut CHAR(4); --DEFAULT BLANCO
DEFINE cFolioConsulta CHAR(9); --DEFAULT BLANCO
DEFINE cFolioConcir CHAR(10); --DEFAULT BLANCO
DEFINE iNegocio SMALLINT; --DEFAULT 0
DEFINE iSubnegocio SMALLINT; --DEFAULT 0
DEFINE iEmpleadoAutorizo INTEGER; --DEFAULT 0
DEFINE cTipo CHAR(1); --DEFAULT BLANCO
DEFINE cFechaMovto CHAR (19); 
DEFINE cNumeroSolicitudDeCredito CHAR(20); --DEFAULT 0
DEFINE cNumcte CHAR(20); --DEFAULT 0
DEFINE iTiendaFolioAnterior SMALLINT;
DEFINE iFolioAnterior INTEGER; --DEFAULT 0
DEFINE iClaveProducto SMALLINT; --DEFAULT 0
DEFINE iFlagActualizacion INTEGER; --DEFAULT 0
--------
DEFINE iSistSegSocial SMALLINT; --DEFAULT 0
DEFINE iTipoSueldoExt SMALLINT; --DEFAULT 0
DEFINE iNumEmpleados SMALLINT; --DEFAULT 0
DEFINE iSubOpcionPuesto SMALLINT; --DEFAULT 0
DEFINE iPuestoExt SMALLINT; --DEFAULT 0
DEFINE iOpcionPuestoExt SMALLINT; --DEFAULT 0
DEFINE iNumEmpleadosExt SMALLINT; --DEFAULT 0
DEFINE iSubOpcionPuestoExt SMALLINT; --DEFAULT 0
DEFINE cTipoOrigen CHAR(1); --DEFAULT BLANCO
DEFINE iTipoProducto CHAR(5); --DEFAULT BLANCO
--Modificacion Campos nuevos
DEFINE iEmpleadoSubCob INTEGER; --DEFAULT 0
DEFINE iFlagCapHuella SMALLINT; --DEFAULT 0
DEFINE cMarcarConsultado CHAR(2); --DEFAULT BLANCO
DEFINE iFlagTestParametrico SMALLINT; --DEFAULT 0
DEFINE iFlagCapCobranza SMALLINT; --DEFAULT 0
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
DEFINE iPropNegocio SMALLINT; --DEFAULT 0
DEFINE iParCelulares SMALLINT; --DEFAULT 0 
DEFINE iParAltoRiesgo SMALLINT; --DEFAULT 0
DEFINE iParPrestamo SMALLINT; --DEFAULT 0
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

--OTRAS VARIABLES
DEFINE cFolioSucursal CHAR(4);
DEFINE dHora DATETIME HOUR TO FRACTION(3);
--DEFINE dFechaAltaCliente DATE;
DEFINE vFecha_Hoy DATE;
DEFINE cTrama LVARCHAR (32000);
DEFINE iSqlErr INTEGER;
DEFINE cCodRetorno CHAR(6);
DEFINE dFechaAlta DATE;
DEFINE iPuntuacion INTEGER;
DEFINE cFecha_hoy CHAR (10);
DEFINE iSecuencia INTEGER;
DEFINE cMarcaHit CHAR(2);
DEFINE iSecAdic INTEGER;

-- INICIALIZACION DE VARIABLES
--CLIENTE
LET cClave = 'A'; --DEFAULT A
LET iCaja = 100; --DEFAULT 100
LET cArea = 'N'; --DEFAULT N
LET cClienteRef = '0'; --DEFAULT 0
LET cNombre1 = '';
LET cNombre2 = '';
LET cApellPaterno = '';
LET cApellMaterno = '';
LET cCurp = ''; --DEFAULT BLANCO
LET cClaveElector = ''; --DEFAULT BLANCO
LET cClaveIdentificacion = ''; --DEFAULT BLANCO
LET cIdentificacion = ''; --DEFAULT BLANCO
LET iCiudad = 0; --DEFAULT 0
LET iColonia = 0; --DEFAULT 0
LET iCalle = 0; --DEFAULT 0
LET iNumeroCasa = 0; --DEFAULT 0
LET cDeptoInterior = ''; --DEFAULT BLANCO
LET cRumbo = ''; --DEFAULT BLANCO
LET cComplemento = ''; --DEFAULT BLANCO
LET cEntrecalles = ''; --DEFAULT BLANCO
LET iFlaguhc = 0; --DEFAULT 0
LET iUhcmanzana = 0; --DEFAULT 0
LET iUhcotros = 0; --DEFAULT 0
LET iUhcandador = 0; --DEFAULT 0
LET iUhcetapa = 0; --DEFAULT 0
LET iUhclote  = 0; --DEFAULT 0
LET iUhcedificio = 0; --DEFAULT 0
LET iUhcEntrada = 0; --DEFAULT 0
LET iTelefono = 0; --DEFAULT 0
LET iTtelefonoCelular = 0; --DEFAULT 0
LET cCasapropia = 'E'; --DEFAULT E
LET cNipTitular = ''; --DEFAULT BLANCO
LET cNipAdicional = ''; --DEFAULT BLANCO
LET cSexo = ''; --DEFAULT BLANCO
LET cEstadoCivil = ''; --DEFAULT BLANCO
LET cFechaNac = '1900/01/01';
LET cFechaDesdeCuandoVive = '1900/01/01';
LET iPersonasVivenEnDomicilio = 0; --DEFAULT 0
LET cEscolaridad = ''; --DEFAULT BLANCO
LET cTipoSueldo = ''; --DEFAULT BLANCO
LET iNumeroDependientes = 0; --DEFAULT 0
LET iPpersonasTrabajan = 0; --DEFAULT 0
LET iLimiteCredito = 0; --DEFAULT 0 
LET iIngresoMensual = 0; --DEFAULT 0
LET cSituacionEspecial = ''; --DEFAULT BLANCO
LET iCausaSituacionEspecial = 0; --DEFAULT 0
LET cClaveAutRechaza = ''; --DEFAULT BLANCO
LET cAceptadoSupervisadoRechazado = ''; --DEFAULT BLANCO
LET cClienteNuevo = 'N'; --DEFAULT N
LET cCreditoJoven = ''; --DEFAULT BLANCO
LET cLugarTrabajo = ''; --DEFAULT BLANCO
LET iCiudadTrabajo = 0; --DEFAULT 0
LET iColoniaTrabajo  = 0; --DEFAULT 0
LET iCalleTrabajo  = 0; --DEFAULT 0
LET iNumeroCasaTrabajo = 0; --DEFAULT 0
LET cDeptooInteriorTrabajo = ''; --DEFAULT BLANCO
LET cRumboTrabajo = ''; --DEFAULT BLANCO
LET cComplementoTrabajo = ''; --DEFAULT BLANCO
LET cEntreCallesTrabajo = ''; --DEFAULT BLANCO
LET iFlaguht = 0; --DEFAULT 0
LET iUhtManzana = 0; --DEFAULT 0
LET iUhtOtros = 0; --DEFAULT 0
LET iUhtAndador = 0; --DEFAULT 0
LET iUhtEtapa = 0; --DEFAULT 0
LET iUhtLote = 0; --DEFAULT 0
LET iUhtEdificio = 0; --DEFAULT 0
LET iUhtEntrada = 0; --DEFAULT 0
LET iTelefonoTrabajo = 0; --DEFAULT 0
LET iExtensionTrabajo = 0; --DEFAULT 0
LET cPuesto = ''; --DEFAULT BLANCO
LET iOpcionPuesto = 0; --DEFAULT 0
LET cFechaAntiguedTrab = '1900/01/01'; 
--CONYUGE
LET cClienteConyuge = '0'; --DEFAULT 0
LET cNombreUnoConyuge = ''; --DEFAULT BLANCO
LET cNombreDosConyuge = ''; --DEFAULT BLANCO
LET cApellidoPaternoConyuge = ''; --DEFAULT BLANCO
LET cApellidoMaternoConyuge = ''; --DEFAULT BLANCO
LET cSexoConyuge = ''; --DEFAULT BLANCO
LET cLugarTrabajoConyuge = ''; --DEFAULT BLANCO
LET iCiudadConyuge = 0; --DEFAULT 0
LET iColoniaConyuge = 0; --DEFAULT 0
LET iCalleTrabajoConyuge = 0; --DEFAULT 0
LET iNumeroCasaConyugue = 0; --DEFAULT 0
LET cDeptooInteriorConyuge = ''; --DEFAULT BLANCO
LET cRumboTrabajoConyuge = ''; --DEFAULT BLANCO
LET cComplementoConyuge = ''; --DEFAULT BLANCO
LET cEntreCallesConyuge = ''; --DEFAULT BLANCO
LET iFlaguhy = 0; --DEFAULT 0
LET iUhyManzana = 0; --DEFAULT 0
LET iUhyOtros = 0; --DEFAULT 0
LET iUhyAndador  = 0; --DEFAULT 0
LET iUhyEtapa = 0; --DEFAULT 0
LET iUhyLote = 0; --DEFAULT 0
LET iUhyEdificio = 0; --DEFAULT 0
LET iUhyEntrada = 0; --DEFAULT 0
LET iTelefonoTrabajoConyuge = 0; --DEFAULT 0
LET iTelefonoCelularConyuge = 0; --DEFAULT 0
LET cClaveConyugeFamilia = ''; --DEFAULT BLANCO
--REFERENCIA 1
LET cClienteReferencia = '0'; --DEFAULT 0
LET cNombreUnoReferencia = ''; --DEFAULT BLANCO
LET cNombreDosReferencia = ''; --DEFAULT BLANCO
LET cApellidoPaternoReferencia = ''; --DEFAULT BLANCO
LET cApellidoMaternoReferencia = ''; --DEFAULT BLANCO
LET cSexoReferencia = ''; --DEFAULT BLANCO
LET iCiudadReferencia = 0; --DEFAULT 0
LET iColoniaReferencia = 0; --DEFAULT 0
LET iCalleReferencia = 0; --DEFAULT 0
LET iNumeroCasaRef = 0; --DEFAULT 0
LET cDeptooInteriorReferencia = ''; --DEFAULT BLANCO
LET cRumboReferencia = ''; --DEFAULT BLANCO
LET cComplementoReferencia = ''; --DEFAULT BLANCO
LET cEntreCallesReferencia1 = ''; --DEFAULT BLANCO
LET iFlaguhr = 0; --DEFAULT 0
LET iUhrManzana = 0 ; --DEFAULT 0
LET iUhrOtros = 0 ; --DEFAULT 0
LET iUhrAndador = 0; --DEFAULT 0
LET iUhrEtapa = 0; --DEFAULT 0
LET iUhrLote = 0; --DEFAULT 0
LET iUhrEdificio = 0; --DEFAULT 0
LET iUhrEntrada = 0; --DEFAULT 0
LET iTelefonoReferencia = 0; --DEFAULT 0   
LET iTelefonoCelularReferencia = 0; --DEFAULT 0
LET cClaveReferencia1 = ''; --DEFAULT BLANCO
--REFERENCIA 2
LET cClienteReferencia2 = '0'; --DEFAULT 0
LET cNombreUnoReferencia2 = ''; --DEFAULT BLANCO
LET cNombredosReferencia2 = ''; --DEFAULT BLANCO
LET cApellidoPaternoReferencia2 = ''; --DEFAULT BLANCO
LET cApellidoMaternoReferencia2 = ''; --DEFAULT BLANCO
LET cSexoReferencia2 = ''; --DEFAULT BLANCO
LET iCiudadReferencia2 = 0; --DEFAULT 0 
LET iColoniaReferencia2 = 0; --DEFAULT 0
LET iCalleReferencia2 = 0; --DEFAULT 0
LET iNumeroCasaRef2 = 0; --DEFAULT 0
LET cDeptooInteriorReferencia2 = ''; --DEFAULT BLANCO
LET cRumboReferencia2 = ''; --DEFAULT BLANCO
LET cComplementoReferencia2 = ''; --DEFAULT BLANCO
LET cEntreCallesReferencia2 = ''; --DEFAULT BLANCO
LET iFlaguhr2 = 0; --DEFAULT 0 
LET iUhrManzana2 = 0; --DEFAULT 0
LET iUhrOtros2 = 0; --DEFAULT 0
LET iUhrAndador2 = 0; --DEFAULT 0
LET iUhrEtapa2 = 0; --DEFAULT 0
LET iUhrLote2 = 0; --DEFAULT 0
LET iUhrEdificio2 = 0; --DEFAULT 0
LET iUhrEntrada2 = 0; --DEFAULT 0
LET iTelefonoReferencia2 = 0; --DEFAULT 0
LET iTelefonoCelularReferencia2 = 0; --DEFAULT 0
LET cClaveReferencia2 = ''; --DEFAULT BLANCO
------
LET iReferencia2 = 0; --DEFAULT 0
LET iReferencia3 = 0; --DEFAULT 0
LET cMarcadatosin = ''; --DEFAULT BLANCO
LET iTipoReposicion = 0; --DEFAULT 2
LET iReposicion = 0; --DEFAULT 0
LET cFlagEntregoTarjeta = 'A'; --DEFAULT A
LET iEfectuo = 0;
LET iTiendaFolio = 0;
LET cFolio = '0'; --DEFAULT 0
LET cFechaAltaCte = '1900/01/01';
LET cFlagNoReconoceHuella = ''; --DEFAULT BLANCO
LET iFolioTienda = 0; --DEFAULT 0
LET cRfc = ''; 
LET cCveBuro = ''; --DEFAULT BLANCO
LET cFolioAut = ''; --DEFAULT BLANCO
LET cFolioConsulta = ''; --DEFAULT BLANCO
LET cFolioConcir = ''; --DEFAULT BLANCO
LET iNegocio = 0; --DEFAULT 0
LET iSubnegocio = 0; --DEFAULT 0
LET iEmpleadoAutorizo = 0; --DEFAULT 0
LET cTipo = ''; --DEFAULT BLANCO
LET cFechaMovto = '1900/01/01';
LET cNumeroSolicitudDeCredito = ' '; --DEFAULT BLANCO
LET cNumcte = '';
LET iTiendaFolioAnterior = 0; --DEFAULT 0
LET iFolioAnterior = 0; --DEFAULT 0
LET iClaveProducto = 0; --6500
LET iFlagActualizacion = 0; --DEFAULT 0
--------
LET iSistSegSocial = 0; --DEFAULT 0
LET iTipoSueldoExt = 0; --DEFAULT 0
LET iNumEmpleados = 0; --DEFAULT 0
LET iSubOpcionPuesto = 0; --DEFAULT 0
LET iPuestoExt = 0; --DEFAULT 0
LET iOpcionPuestoExt = 0; --DEFAULT 0
LET iNumEmpleadosExt = 0; --DEFAULT 0
LET iSubOpcionPuestoExt = 0; --DEFAULT 0
LET cTipoOrigen = ''; --DEFAULT BLANCO
LET iTipoProducto = '01000'; --DEFAULT 01000
--Modificacion Campos nuevos
LET cFolioSucursal = '0'; --DEFAULT 0
LET cFecha_hoy = '1900/01/01';
LET iPuntuacion = 0;
LET cMarcaHit = '';
LET iEmpleadoSubCob = 0; --DEFAULT 0
LET iFlagCapHuella = 0; --DEFAULT 0
LET cMarcarConsultado = ''; --DEFAULT BLANCO
LET iFlagTestParametrico = 0; --DEFAULT 0
LET iFlagCapCobranza = 0; --DEFAULT 0
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
LET iPropNegocio = 0; --DEFAULT 0
LET iParCelulares = 0; --DEFAULT 0 
LET iParAltoRiesgo = 0; --DEFAULT 0
LET iParPrestamo = 0; --DEFAULT 0
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

--OTRAS VARIABLES
LET dHora = '';
--LET dFechaAltaCliente = DATE(1);
LET cTrama = "";
LET cCodRetorno = '000000';
LET dFechaAlta = DATE(1);
LET iSecuencia = 0;
LET iSecAdic = 0;

--SET DEBUG FILE TO '/tmp/sp_GeneraArchivoReposicion.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		SET DEBUG FILE TO '/RESPALDOSNEW/sp_generaarchivoextraviadas.out';
		TRACE ON;
        LET iSecuencia = iSecuencia;
		IF iSqlErr <> 0 THEN
			LET cCodRetorno = iSqlErr;
			RETURN cCodRetorno;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF NVL(dFechaAct,'') = '' THEN
		LET dFechaAct = mdy(1,1,1800);
	END IF;
	
	IF NVL(cEmpresa,'') <> '' THEN
		IF dFechaAct <> mdy(1,1,1900) THEN 
			SELECT fecha_hoy INTO vFecha_Hoy FROM bdinteg:"informix".si_fechas;
			
			IF vFecha_Hoy = mdy(1,1,1900) OR vFecha_Hoy IS NULL THEN
				LET cCodRetorno = '000002';
			ELSE
				IF dFechaAct = mdy(1,1,1800) THEN
					LET dFechaAct = NULL;
				END IF;
				
				FOREACH
					--selecciona las tarjetas extraviadas 'E', canceladas 'C' y dadas de baja 'B'
					SELECT numtarjeta, cvesucursal,
					YEAR(fechaasignacion)||"/"||LPAD(MONTH(fechaasignacion),2,0)||"/"||LPAD(DAY(fechaasignacion),2,0),estatustarjeta
					INTO cClienteRef, cFolioSucursal, cFechaMovto, cCasapropia
					FROM bditarjcop:"informix".tarjetasnumtarcop
					WHERE empresa = cEmpresa
					--AND estatustarjeta = 'E' 
					AND estatustarjeta IN ('E', 'C', 'B') --dsb-14/01/2013
					AND DATE(fechaasignacion) = dFechaAct
					--AND YEAR(fechaasignacion) = NVL(YEAR(dFechaAct),YEAR(fechaasignacion))
					--AND MONTH(fechaasignacion) = NVL(MONTH(dFechaAct),MONTH(fechaasignacion))
					--AND DAY(fechaasignacion) = NVL(DAY(dFechaAct),DAY(fechaasignacion))
					UNION ALL
					SELECT numtarjeta, cvesucursal,	
					YEAR(fechaasignacion)||"/"||LPAD(MONTH(fechaasignacion),2,0)||"/"||LPAD(DAY(fechaasignacion),2,0), estatustarjeta
					FROM bditarjcop:"informix".tarjetasrepotarcop
					WHERE empresa = cEmpresa
					AND estatustarjeta IN ('E', 'C', 'B') 
					AND DATE(fechaasignacion) = dFechaAct
					--AND YEAR(fechaasignacion) = NVL(YEAR(dFechaAct),YEAR(fechaasignacion))
					--AND MONTH(fechaasignacion) = NVL(MONTH(dFechaAct),MONTH(fechaasignacion))
					--AND DAY(fechaasignacion) = NVL(DAY(dFechaAct),DAY(fechaasignacion))

					--DA FORMATO A FECHAS
					LET cFechaAltaCte = cFechaMovto;
					SELECT DBINFO('utc_to_datetime', sh_curtime) INTO dHora FROM sysmaster:sysshmvals;
					IF dFechaAct <> vFecha_Hoy OR dFechaAct IS NOT NULL THEN
						LET cFechaMovto = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0)||" "||dHora;
						LET cFecha_hoy = YEAR(dFechaAct)||"/"||LPAD(MONTH(dFechaAct),2,0)||"/"||LPAD(DAY(dFechaAct),2,0);
					ELSE
						LET cFechaMovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||dHora;
						LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
					END IF;
					
					--SECUENCIA DE ARCHIVO
					IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
						IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							LET iSecuencia = (SELECT  {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						ELSE
							LET iSecuencia = (SELECT NVL(MAX(secuencia), 0) + 1  FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						END IF;
					ELSE
						IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							LET iSecuencia = (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = cEmpresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						ELSE
							LET iSecuencia = 1;
						END IF;
					END IF;
					
					LET cTrama = TRIM(cClave)||"|"||iCaja||"|"||TRIM(cArea)||"|"||TRIM(cClienteRef)||"|"||TRIM(NVL(cNombre1, ''))||"|"||TRIM(NVL(cNombre2, ''))||"|"||TRIM(NVL(cApellPaterno, ''))||"|"||TRIM(NVL(cApellMaterno, ''))||"|"||TRIM(cCurp)||"|"||TRIM(cClaveElector)||"|"||TRIM(cClaveIdentificacion)||"|"||TRIM(cIdentificacion)||"|"||iCiudad||"|"||iColonia||"|"||iCalle||"|"||iNumeroCasa||"|"||TRIM(cDeptoInterior)||"|"||TRIM(cRumbo);
					LET cTrama = cTrama || "|" ||TRIM(cComplemento)||"|"||TRIM(cEntrecalles)||"|"||iFlaguhc||"|"||iUhcmanzana||"|"||iUhcotros||"|"||iUhcandador||"|"||iUhcetapa||"|"||iUhclote||"|"||iUhcedificio||"|"||iUhcEntrada||"|"||iTelefono||"|"||iTtelefonoCelular||"|"||TRIM(cCasapropia)||"|"||TRIM(cNipTitular)||"|"||TRIM(cNipAdicional)||"|"||TRIM(cSexo)||"|"||TRIM(cEstadoCivil)||"|"||TRIM(NVL(cFechaNac, '1900/01/01'))||"|"||TRIM(NVL(cFechaDesdeCuandoVive, '1900/01/01'))||"|"||iPersonasVivenEnDomicilio||"|"||TRIM(cEscolaridad)||"|"||TRIM(cTipoSueldo);
					LET cTrama = cTrama || "|"  ||iNumeroDependientes||"|"||iPpersonasTrabajan||"|"||iLimiteCredito||"|"||iIngresoMensual||"|"||TRIM(cSituacionEspecial)||"|"||iCausaSituacionEspecial||"|"||TRIM(cClaveAutRechaza)||"|" ||TRIM(cAceptadoSupervisadoRechazado)||"|"||TRIM(cClienteNuevo)||"|"||TRIM(cCreditoJoven)||"|"||TRIM(cLugarTrabajo)||"|"||iCiudadTrabajo||"|"||iColoniaTrabajo||"|"||iCalleTrabajo||"|"||iNumeroCasaTrabajo||"|"||TRIM(cDeptooInteriorTrabajo)||"|"||TRIM(cRumboTrabajo)||"|"||TRIM(cComplementoTrabajo)||"|"||TRIM(cEntreCallesTrabajo);
					LET cTrama = cTrama || "|" ||iFlaguht||"|"||iUhtManzana||"|"||iUhtOtros||"|"||iUhtAndador||"|"||iUhtEtapa||"|"||iUhtLote||"|"||iUhtEdificio||"|"||iUhtEntrada||"|"||iTelefonoTrabajo||"|"||iExtensionTrabajo||"|"||TRIM(cPuesto)||"|"||iOpcionPuesto||"|"||TRIM(NVL(cFechaAntiguedTrab, '1900/01/01'))||"|"||TRIM(cClienteConyuge)||"|"||TRIM(cNombreUnoConyuge)||"|"||TRIM(cNombreDosConyuge)||"|"||TRIM(cApellidoPaternoConyuge)||"|"||TRIM(cApellidoMaternoConyuge)||"|"||TRIM(cSexoConyuge)||"|"||TRIM(cLugarTrabajoConyuge)||"|"||iCiudadConyuge||"|"||iColoniaConyuge||"|"||iCalleTrabajoConyuge||"|"||iNumeroCasaConyugue||"|"||TRIM(cDeptooInteriorConyuge)||"|"||TRIM(cRumboTrabajoConyuge)||"|"||TRIM(cComplementoConyuge)||"|"||TRIM(cEntreCallesConyuge);
					LET cTrama = cTrama|| "|" ||iFlaguhy||"|"||iUhyManzana||"|"||iUhyOtros||"|"||iUhyAndador||"|"||iUhyEtapa||"|"||iUhyLote||"|"||iUhyEdificio||"|"||iUhyEntrada||"|"||iTelefonoTrabajoConyuge||"|"||iTelefonoCelularConyuge||"|"||TRIM(cClaveConyugeFamilia)||"|"||TRIM(cClienteReferencia)||"|"||TRIM(cNombreUnoReferencia)||"|"||TRIM(cNombreDosReferencia)||"|"||TRIM(cApellidoPaternoReferencia)||"|"||TRIM(cApellidoMaternoReferencia)||"|"||TRIM(cSexoReferencia)||"|"||iCiudadReferencia||"|"||iColoniaReferencia||"|"||iCalleReferencia||"|"||iNumeroCasaRef||"|"||TRIM(cDeptooInteriorReferencia)||"|"||TRIM(cRumboReferencia)||"|"||TRIM(cComplementoReferencia)||"|"||TRIM(cEntreCallesReferencia1)||"|"||iFlaguhr||"|"||iUhrManzana||"|"||iUhrOtros||"|"||iUhrAndador||"|"||iUhrEtapa||"|"||iUhrLote||"|"||iUhrEdificio||"|"||iUhrEntrada||"|"||iTelefonoReferencia||"|"||iTelefonoCelularReferencia;
					LET cTrama = cTrama|| "|" ||TRIM(cClaveReferencia1)||"|"||TRIM(cClienteReferencia2)||"|"||TRIM(cNombreUnoReferencia2)||"|"||TRIM(cNombredosReferencia2)||"|"||TRIM(cApellidoPaternoReferencia2)||"|"||TRIM(cApellidoMaternoReferencia2)||"|"||TRIM(cSexoReferencia2)||"|"||iCiudadReferencia2||"|"||iColoniaReferencia2||"|"||iCalleReferencia2||"|"||iNumeroCasaRef2||"|"||TRIM(cDeptooInteriorReferencia2)||"|"||TRIM(cRumboReferencia2)|| "|"||TRIM(cComplementoReferencia2)||"|"||TRIM(cEntreCallesReferencia2)||"|"||iFlaguhr2||"|"||iUhrManzana2||"|"||iUhrOtros2||"|"||iUhrAndador2||"|"||iUhrEtapa2||"|"||iUhrLote2||"|"||iUhrEdificio2||"|"||iUhrEntrada2||"|"||iTelefonoReferencia2||"|"||iTelefonoCelularReferencia2||"|"||TRIM(cClaveReferencia2)||"|"||iReferencia2||"|"||iReferencia3||"|"||TRIM(cMarcadatosin)||"|"||iTipoReposicion||"|"||NVL(iReposicion, 0)|| "|" ||TRIM(cFlagEntregoTarjeta)|| "|" || NVL(iEfectuo, 0)|| "|" || NVL(iTiendaFolio, 0) || "|" ||TRIM(cFolio)||"|"||TRIM(NVL(cFechaAltaCte, '1900/01/01'))||"|"||TRIM(cFlagNoReconoceHuella)|| "|"||iFolioTienda|| "|" ||TRIM(cRfc)||"|"||TRIM(cCveBuro)|| "|" ||TRIM(cFolioAut)|| "|" ||TRIM(cFolioConsulta)|| "|" ||TRIM(cFolioConcir)|| "|" ||iNegocio|| "|" ||iSubnegocio|| "|"||iEmpleadoAutorizo|| "|" ||TRIM(cTipo)|| "|"||TRIM(NVL(cFechaMovto, '1900/01/01'))||"|"||TRIM(cNumeroSolicitudDeCredito)|| "|" || TRIM(NVL(cNumcte, ''))|| "|" ||iTiendaFolioAnterior|| "|" ||iFolioAnterior||"|"||iClaveProducto|| "|" ||iFlagActualizacion|| "|" ||iSistSegSocial||"|"||iTipoSueldoExt|| "|" ||iNumEmpleados|| "|" ||iSubOpcionPuesto|| "|" ||iPuestoExt||"|"||iOpcionPuestoExt||"|"||iNumEmpleadosExt||"|"||iSubOpcionPuestoExt||"|"||TRIM(cTipoOrigen)||"|"||iTipoProducto||"|"||TRIM(NVL(cFolioSucursal, 0))||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||TRIM(cMarcaHit)||"|"||iEmpleadoSubCob||"|"||iFlagCapHuella||"|"||TRIM(cMarcarConsultado)||"|"||iFlagTestParametrico||"|"||iFlagCapCobranza||"|"||iEmpleadoGteAutori;
					LET cTrama = cTrama||"|"||TRIM(NVL(cFlagConsBuro,''))||"|"||TRIM(cBuroPilotoTestig)||"|"||TRIM(NVL(cNacionalidad,''))||"|"||TRIM(NVL(cNoFm3,''))||"|"||TRIM(NVL(cEmail,''))||"|"||TRIM(NVL(cApellCasada,''))||"|"||TRIM(NVL(cPais,''))||"|"||TRIM(NVL(cNoIMSS,''))||"|"||TRIM(NVL(cEstado,''))||"|"||TRIM(cDelegMunicip)||"|"||TRIM(NVL(cNumInterior,''))||"|"||iPropNegocio||"|"||iParCelulares||"|"||iParAltoRiesgo||"|"||iParPrestamo||"|"||TRIM(cModeloCel)||"|"||NVL(cFechaConsBuro, '1900/01/01')||"|"||NVL(iMontoIngMensual,0)||"|"||NVL(iCapSistematicabono,0)||"|"||NVL(iTopeAbonoCoppel,0)||"|"||NVL(iLineaCrediTope,0)||"|"||NVL(iCapMaximaAbono,0)||"|"||NVL(iCapRealAbono,0)||"|"||NVL(iLineaCredReal,0)||"|"||NVL(iCompromisosSic,0)||"|"||NVL(iFlagLineaCredEsp,0)||"|"||TRIM(cClienteConyugebcpl)||"|"||TRIM(cClienteReferencia1bcpl)||"|"||TRIM(cClienteReferencia2bcpl);
					LET cTrama = NVL(cTrama, '');
					
					IF dFechaAct IS NULL THEN
						INSERT INTO bdinteg:"informix".si_archivoscoppeldiario(empresa,secuencia, sucursal,trama,tipomovto,fecha_insert)
						VALUES (cEmpresa,iSecuencia, cFolioSucursal,cTrama, cClave,vFecha_Hoy);
					ELSE
						INSERT INTO bdinteg:"informix".si_archivoscoppeldiario(empresa,secuencia, sucursal,trama,tipomovto,fecha_insert)
						VALUES (cEmpresa,iSecuencia, cFolioSucursal,cTrama, cClave,dFechaAct);
					END IF;
				END FOREACH;
			END IF;
		ELSE
			RETURN '000001';
		END IF;
	ELSE
		RETURN '000002';
	END IF;
	
	RETURN cCodRetorno;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Victor Hugo Nuñez',
'Procedimiento   : "informix".sp_generaarchivoextraviadas',
'Descripcion: Realiza la extraccion de datos para archivos de extravios..',
'BD:bdinteg',
'Fecha: 28/08/2012',
'Version: 20120828.1620',
'BD: bdinteg',
'AUTOR: Victor Hugo Nuñez',
'Procedimiento   : "informix".sp_generaarchivoextraviadas',
'Descripcion: Se agrega el manejo de tarjetas marcadas como canceladas C',
'BD:bdinteg',
'Fecha: 14/01/2013',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_generararchivoordensupervision2(pempresa CHAR(3), pFechaAct DATE)
RETURNING CHAR(6);
DEFINE vcalletrabajo, vcoloniatrabajo INTEGER;
DEFINE vuhclote, vuhyandador SMALLINT;
DEFINE vclaveconyugefamilia CHAR (1);
DEFINE cfechaaltacte, cFecha_hoy CHAR (10);
DEFINE cfechamovto CHAR (19);
DEFINE vcreditojoven, varea, vClave, vtipo, vTipoOrigen, vrumbotrabajo, vflagnoreconocehuella, cUnidadHabit, vrumbotrabajoconyuge, vrumbo, cSexoReferencia2, vsexo, vaceptadosupervisadorechazado, vestadocivil, cflaguht, cSexoReferencia, vrumboreferencia, vflagentregotarjeta, vclavereferencia1, cBuroPilotoTestig, cModeloCel, vmarcadatosin, vcasapropia, vpuesto, cSexoConyuge, vescolaridad, vclaveautrechaza, vsituacionespecial, vclientenuevo, vclavereferencia2, vtiposueldo, vrumboreferencia2 CHAR(1);
DEFINE cfechanac, cCasareferencia2, cFechaConsBuro, cCasa, cfechaantiguedtrab, cCasatrabajoconyuge, cCasatrabajo, cCasareferencia, vfolioconcir, cfechadesdecuandovive CHAR(10);
DEFINE vNombre CHAR(104);
DEFINE cNoIMSS CHAR(12);
DEFINE vrfc CHAR(13);
DEFINE vcurp, cNoFm3, vclaveelector CHAR(18);
DEFINE vTipo_Dir, vclaveidentificacion, cEstado2, vcveburo, cFlagConsBuro, cMarcaHit, cMarcarConsultado CHAR(2);
DEFINE vnumerosolicituddecredito, vnumcte, cClienteReferencia2bcpl, vlugartrabajo, vclientereferencia, vfolio, vclientereferencia2, cClienteConyugebcpl, cClienteReferencia1bcpl, vclienteconyuge, vlugartrabajoconyuge, vcliente_ref CHAR(20);
DEFINE vnombre1, vapellidomaternoconyuge, vnombreunoconyuge, vapell_paterno, cApellCasada, vapellidopaternoconyuge, vapell_materno, vnombredosconyuge, vapellidomaternoreferencia2, vnombreunoreferencia2, vapellidopaternoreferencia2, vnombredosreferencia2, vnombre2, vapellidopaternoreferencia, vnombreunoreferencia, vnombredosreferencia, vapellidomaternoreferencia CHAR(26);
DEFINE cEstado, cNacionalidad, cDelegMunicip, cPais CHAR(3);
DEFINE vdeptoointeriorreferencia2, vdeptointerior, vdeptoointeriortrabajo, vfolioaut, cFolioSucursal, vdeptoointeriorreferencia, vdeptoointeriorconyuge, cNumInterior CHAR(4);
DEFINE ventrecalles, ventrecallesconyuge, ventrecallesreferencia2, ventrecallestrabajo, ventrecallesreferencia1 CHAR(40);
DEFINE vTipoProducto, vcodret CHAR(5);
DEFINE cDescripElemento CHAR(50);
DEFINE vCodRetorno CHAR(6);
DEFINE cEmail CHAR(60);
DEFINE vniptitular, vnipadicional CHAR(7);
DEFINE videntificacion CHAR(8);
DEFINE vcomplemento, vcomplementoreferencia2, vcomplementoreferencia, vcomplementoconyuge, vcomplementotrabajo CHAR(80);
DEFINE vfolioconsulta CHAR(9);
DEFINE vfechaaltacliente, vFecha_Hoy, vfechanacimiento, dFechaAlta, vfechamovto, dFechaConsBuro DATE;
DEFINE vHora DATETIME HOUR TO FRACTION(3);
DEFINE dEvaluacion1, dEvaluacion2 DECIMAL(5,2);
DEFINE vtelefonoreferencia, vtelefonocelularreferencia, vtelefonocelular, vtelefonotrabajoconyuge, vtelefono, vtelefonocelularconyuge, vtelefonotrabajo, vtelefonoreferencia2, vtelefonocelularreferencia2 INT8;
DEFINE vcallereferencia2, vcoloniareferencia2, vcalletrabajoconyuge, iNumerocasaconyuge, iNumerocasaref2, iRowId, iNumerocasaref, vcallereferencia, vcoloniareferencia, vcoloniaconyuge, iElemento, vreposicion, vextensiontrabajo, vefectuo, iPuntuacion, iSecuencia, vciudad, iIngreso, vfoliotienda, iValor, vcolonia, vreferencia3, vreferencia2, vciudadbanco, vcalle, iNumerocasa, vempleadoautorizo, iAniosHabita, vcoloniabanco, iContConsBuro, vciudadconyuge, iRefSecuencias, vfolioanterior, iElementoScoring, vflagactualizacion, iCompromisosSic, iLineaCredReal, iCapRealAbono, iCapMaximaAbono, iLineaCrediTope, iTopeAbonoCoppel, iCapSistematicabono, iMontoIngMensual, iCuentaRegistros, iSqlErr, iEmpleadoSubCob, vEdad, iNumerocasatrabajo, vpersonasvivenendomicilio, vciudadtrabajo, iEmpleadoGteAutori INTEGER;
DEFINE vsSQL LVARCHAR (32000);
DEFINE vcausasituacionespecial, vingresomensual, vlimitecredito, vuhretapa2, vpersonastrabajan, vnumerodependientes, sFlagCapCobranza, vtiendafolio, sFlagTestParametrico, sFlagCapHuella, vuhtlote, vuhrlote2, sParCelulares, sParAltoRiesgo, sParPrestamo, vciudadreferencia2, vuhredificio2, vuhcentrada, vuhrentrada2, vNumempleadosext, vOpcionpuestoext, vPuestoext, vSubopcionpuesto, vNumempleados, vTiposueldoext, vSistsegsocial, iFlagLineaCredEsp, vuhcedificio, vuhcetapa, vuhcandador, vuhyentrada, vclaveproducto, vtiendafolioanterior, vflaguht, vuhtmanzana, vuhymanzana, vuhyotros, vuhcotros, vuhrentrada, vuhtotros, vuhredificio, vuhrlote, vuhcmanzana, vflaguhc, vuhretapa, vuhrandador, vsubnegocio, vnegocio, vuhtandador, vuhrotros2, vuhtentrada, vuhtetapa, sPropNegocio, vuhyedificio, vflaguhr, vuhtedificio, vopcionpuesto, vuhrandador2, vuhrmanzana2, vuhyetapa, vciudadreferencia, vflaguhr2, vuhylote, vtiporeposicion, vSubopcionpuestoext, vcaja, vflaguhy, vuhrotros, vuhrmanzana SMALLINT;
DEFINE vletrasnumcasa VARCHAR (10);
DEFINE vletrasnumtrabconyuge, vletrasnumcasaref, vletrasnumcasaref2, vletrasnumtrabajo VARCHAR(10);
DEFINE cRespuesta VARCHAR(20);
--CLIENTE
LET vClave = 'M';
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
LET vclaveautrechaza = '';
LET vaceptadosupervisadorechazado = '';
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
--CONYUGE
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
LET vclaveconyugefamilia = '';
--REFERENCIA 1
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
LET vfolioanterior = 0; --DEFAULT 0
LET vclaveproducto = 6500; --6500
LET vflagactualizacion = 0; --DEFAULT 0
--------
LET vSistsegsocial = 0; --DEFAULT 0
LET vTiposueldoext = 0; --DEFAULT 0
LET vNumempleados = 0; --DEFAULT 0
LET vSubopcionpuesto = 99; --DEFAULT 0
LET vPuestoext = 0; --DEFAULT 0
LET vOpcionpuestoext = 0; --DEFAULT 0
LET vNumempleadosext = 0; --DEFAULT 0
LET vSubopcionpuestoext = 0; --DEFAULT 0
LET vTipoOrigen = 'G';
LET vTipoProducto = '01000';
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
LET cEstado2 = '';
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
LET cFolioSucursal = '';
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
--Set debug file to '/tmp/sp_generararchivoordensupervision.out';
--trace on;
BEGIN
	ON EXCEPTION
		SET iSqlErr
		Set debug file to '/RESPALDOSNEW/sp_generararchivoordensupervision2.out';
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
				SELECT ssos.num_solicitud, ssos.fecha_respuesta, ssos.status, ssos.secuenciaos
				INTO vnumerosolicituddecredito, vfechaaltacliente, vaceptadosupervisadorechazado, vfolio
				FROM bdisolic:"informix".ss_solicitud_os ssos, bdisolic:"informix".ss_solicitudes sss
				WHERE ssos.empresa = pempresa AND ssos.status <> 'P' AND ssos.fecha_respuesta = pFechaAct
				AND ssos.num_solicitud = sss.num_solicitud AND sss.num_producto = '6500'				
				IF vnumerosolicituddecredito <> '' THEN --OR vnumcte <> '' THEN 				
					SELECT num_solicitud, numcte, sucursal, sucursal, fecha_insert
					INTO vnumerosolicituddecredito, vnumcte, vtiendafolio, cFolioSucursal, dFechaAlta
					FROM bdisolic:"informix".ss_solicitudes
					WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito;					
					IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumerosolicituddecredito) > 1 THEN
						FOREACH
							SELECT FIRST 1 secuenciaos
							INTO vfolioanterior 
							FROM bdisolic:"informix".ss_solicitud_os
							WHERE num_solicitud = vnumerosolicituddecredito AND secuenciaos < vfolio ORDER BY secuenciaos DESC
						END FOREACH						
						LET vtiendafolioanterior = vtiendafolio;						
					END IF;														
					IF vaceptadosupervisadorechazado = 'R' THEN
						LET vaceptadosupervisadorechazado = 'H';
					END IF;					
					IF vnumcte <> '' THEN 				
						--Calcula Edad del Cliente
						EXECUTE PROCEDURE "informix".consedadcte(pempresa, vnumcte) INTO vCodRetorno, vNombre, vEdad;
						--OBTIENE LOS DATOS GENERALES DEL CLIENTE
						SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, cte.numcte, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(cte.ejecut_autoriza) = 'V' THEN cte.ejecut_autoriza::INTEGER ELSE 0 END, 
						cte.rfc, cte.fecha_insert, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(cte.ejecut_autoriza) = 'V' THEN cte.ejecut_autoriza::INTEGER ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(cte.string2) = 'V' THEN cte.string2::INTEGER ELSE 0 END,
						cte.apell_casada
						INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vnumcte, vefectuo, vrfc, 
						vfechamovto, vefectuo, vpersonasvivenendomicilio, cApellCasada
						FROM bdinteg:"informix".si_cliente cte
						WHERE cte.empresa = pempresa AND cte.numcte = vnumcte;
						--Datos Generales Clientes
						SELECT iden.estado_civil, REPLACE(iden.curp,'|',' '), iden.numidentifi, iden.codidentifi, iden.habita_en, iden.sexo, iden.fecha_nac, iden.escolaridad, iden.nacionalidad, iden.no_fm3, iden.no_imss
						INTO vestadocivil, vcurp, vclaveelector, vclaveidentificacion, vcasapropia, vsexo, vfechanacimiento, vescolaridad, cNacionalidad, cNoFm3, cNoIMSS
						FROM bdinteg:"informix".si_ctepf iden WHERE iden.numcte = vnumcte;
                        SELECT correo_elec INTO cEmail FROM bdinteg:"informix".si_correos WHERE numcte = vnumcte AND status_correo = 'A';
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerociudad) = 'V' THEN dir.numerociudad::INTEGER ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocolonia) = 'V' THEN dir.numerocolonia::INTEGER ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocalle) = 'V' THEN dir.numerocalle::INTEGER ELSE 1 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numeroextcalle) = 'V' THEN dir.numeroextcalle::INTEGER ELSE 1 END, 
						NVL(TRIM(REPLACE(dir.numerointcalle,'|',' ')), ''), dir.puntocardinal, NVL(TRIM(REPLACE(dir.observaciones,'|',' ')), ''), NVL(TRIM(REPLACE(dir.entre_calles,'|',' ')), ''), dir.unidadhabitac, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.manzana) = 'V' THEN dir.manzana::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.otros) = 'V' THEN dir.otros::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.andador) = 'V' THEN dir.andador::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.etapa) = 'V' THEN dir.etapa::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.lote) = 'V' THEN dir.lote::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.edificio) = 'V' THEN dir.edificio::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.entrada) = 'V' THEN dir.entrada::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(tel1.telefono) = 'V' THEN tel1.telefono::INT8 ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(tel2.telefono) = 'V' THEN tel2.telefono::INT8 ELSE 0 END, 
						dir.tipo_dir, NVL(TRIM(REPLACE(dir.numerointcalle,'|',' ')), ''), dir.pais, dir.estado 
						INTO vciudadbanco, vcoloniabanco, vcalle, iNumerocasa, vdeptointerior, vrumbo, vcomplemento, ventrecalles, cUnidadHabit, vuhcmanzana, vuhcotros,
						vuhcandador, vuhcetapa, vuhclote, vuhcedificio, vuhcentrada, vtelefono, vtelefonocelular, vTipo_Dir, cNumInterior, cPais, cEstado
						FROM bdinteg:"informix".si_direcciones_actual dir
                        LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
                        LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
						WHERE dir.numcte = vnumcte AND dir.tipo_dir = '1'; 
						--- AND dir.secuencia = (SELECT NVL(MAX(secuencia), 0) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = vnumcte AND tipo_dir = '1');
						IF iNumerocasa = 0 THEN
							LET iNumerocasa = 1;
						END IF;
						IF NVL(vcomplemento, '') = '' THEN
							LET vcomplemento = 'E';
						END IF;						
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
						INTO vciudad, vcolonia
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;						
						IF NVL(vciudad, 0) = 0 THEN
						
							--SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
													
							SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							INTO vciudadbanco
							FROM bdinteg:"informix".si_ptf 
							WHERE id_ptf = cFolioSucursal AND tipo='S';	
						
					    	SELECT FIRST 1 numerociudadcoppel INTO vciudad FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
						END IF;
						IF NVL(vcolonia, 0) = 0 THEN
						
					       --SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						
							SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							INTO vciudadbanco
							FROM bdinteg:"informix".si_ptf 
							WHERE id_ptf = cFolioSucursal AND tipo='S';	
						
					
  					    SELECT FIRST 1 numerocoloniacoppel INTO vcolonia FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
						END IF;
						--Trabajo Clientes
						SELECT ing.nombre_empresa, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(ing.claveopcionpuesto) = 'V' THEN ing.claveopcionpuesto::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(ing.clavesubopcionpuesto) = 'V' THEN ing.clavesubopcionpuesto::SMALLINT ELSE 0 END --ing.ingreso_mensual
						INTO vlugartrabajo, vopcionpuesto, vSubopcionpuesto --vingresomensual
						FROM bdinteg:"informix".si_ingresos ing
						WHERE ing.numcte = vnumcte
						AND ing.sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = vnumcte AND tipo_ingreso = 'T');							
						IF NVL(vopcionpuesto, '') = '' THEN
							LET vopcionpuesto = '0';
						END IF;
						IF NVL(vSubopcionpuesto, '') = '' THEN
							LET vSubopcionpuesto = '99';
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
						--OBTIENE LOS DATOS DE DIRECCION DE TRABAJO
						--- SELECT NVL (MAX(secuencia),0) INTO iSecuencia FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = vnumcte AND tipo_dir = '2';						
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerociudad) = 'V' THEN dir.numerociudad::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocolonia) = 'V' THEN dir.numerocolonia::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocalle) = 'V' THEN dir.numerocalle::INTEGER ELSE 1 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numeroextcalle) = 'V' THEN dir.numeroextcalle::INTEGER ELSE 1 END,
						NVL(TRIM(REPLACE(dir.numerointcalle,'|',' ')), ''), puntocardinal, NVL(TRIM(REPLACE(dir.observaciones,'|',' ')), ''), NVL(TRIM(REPLACE(dir.entre_calles,'|',' ')), ''), dir.unidadhabitac,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.manzana) = 'V' THEN dir.manzana::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.otros) = 'V' THEN dir.otros::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.andador) = 'V' THEN dir.andador::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.etapa) = 'V' THEN dir.etapa::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.lote) = 'V' THEN dir.lote::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.edificio) = 'V' THEN dir.edificio::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.entrada) = 'V' THEN dir.entrada::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(tel3.telefono) = 'V' THEN tel3.telefono::INT8 ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(tel3.extension) = 'V' THEN tel3.extension::INTEGER ELSE 0 END
						INTO vciudadbanco,vcoloniabanco,vcalletrabajo,iNumerocasatrabajo,vdeptoointeriortrabajo,vrumbotrabajo,
						vcomplementotrabajo,ventrecallestrabajo,cflaguht,vuhtmanzana,vuhtotros,vuhtandador,vuhtetapa,vuhtlote,vuhtedificio,
						vuhtentrada,vtelefonotrabajo,vextensiontrabajo					
						FROM bdinteg:"informix".si_direcciones_actual dir	
                        LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
						WHERE dir.numcte = vnumcte AND dir.tipo_dir = '2'; --- AND secuencia = iSecuencia;
						IF iNumerocasatrabajo = 0 THEN
							LET iNumerocasatrabajo = 1;
						END IF;
						IF NVL(vcomplementotrabajo, '') = '' THEN
							LET vcomplementotrabajo = 'E';
						END IF;						
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
						INTO vciudadtrabajo, vcoloniatrabajo
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;						
						IF NVL(vciudadtrabajo, 0) = 0 THEN
						
					    	--SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						
						    SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							INTO vciudadbanco
							FROM bdinteg:"informix".si_ptf 
							WHERE id_ptf = cFolioSucursal AND tipo='S';
				
						SELECT FIRST 1 numerociudadcoppel INTO vciudadtrabajo FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
							AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
						END IF;
						IF NVL(vcoloniatrabajo, 0) = 0 THEN
						
						   --SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							
							SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							INTO vciudadbanco
							FROM bdinteg:"informix".si_ptf 
							WHERE id_ptf = cFolioSucursal AND tipo='S';
										
   					    	SELECT FIRST 1 numerocoloniacoppel INTO vcoloniatrabajo FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
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
						--OBTIENE LOS DATOS DE LA REFERENCIA CUANDO EL CLIENTE ES CASADO
						IF 	vestadocivil = 'C' THEN
							LET vclaveconyugefamilia = 'E';
							--OBTIENE LOS DATOS DEL CONYUGE 
							SELECT cte2.numcte, cte2.nombre1, cte2.nombre2, cte2.apell_paterno, cte2.apell_materno, cte2.parentesco, cte2.sexo, cte2.secuencia
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
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerociudad) = 'V' THEN dir2.numerociudad::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocolonia) = 'V' THEN dir2.numerocolonia::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocalle) = 'V' THEN dir2.numerocalle::INTEGER ELSE 1 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numeroextcalle) = 'V' THEN dir2.numeroextcalle::INTEGER ELSE 1 END,
							NVL(TRIM(REPLACE(dir2.numerointcalle,'|',' ')), ''),dir2.puntocardinal, NVL(TRIM(REPLACE(dir2.observaciones,'|',' ')), ''), NVL(TRIM(REPLACE(dir2.entre_calles,'|',' ')), ''), dir2.unidadhabitac, 
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.manzana) = 'V' THEN dir2.manzana::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.otros) = 'V' THEN dir2.otros::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.andador) = 'V' THEN dir2.andador::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.etapa) = 'V' THEN dir2.etapa::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.lote) = 'V' THEN dir2.lote::SMALLINT ELSE 0 END, 
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.edificio) = 'V' THEN dir2.edificio::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.entrada) = 'V' THEN dir2.entrada::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono3) = 'V' THEN dir2.telefono3::INT8 ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono2) = 'V' THEN dir2.telefono2::INT8 ELSE 0 END
							INTO vciudadbanco,vcoloniabanco,vcalletrabajoconyuge,iNumerocasaconyuge,vdeptoointeriorconyuge,vrumbotrabajoconyuge,
							vcomplementoconyuge,ventrecallesconyuge,cflaguht,vuhymanzana,vuhyotros,vuhyandador,vuhyetapa,vuhylote,vuhyedificio,
							vuhyentrada,vtelefonotrabajoconyuge,vtelefonocelularconyuge
							FROM bdinteg:"informix".si_refdirecciones dir2
							WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;	
							IF iNumerocasaconyuge = 0 THEN
								LET iNumerocasaconyuge = 1;
							END IF;
							IF NVL(vcomplementoconyuge, '') = '' THEN
								LET vcomplementoconyuge = 'E';
							END IF;							
							SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
							INTO vciudadconyuge, vcoloniaconyuge
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;							
							IF NVL(vciudadconyuge, 0) = 0 THEN
							
							--	SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
								
								SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							    INTO vciudadbanco
						     	FROM bdinteg:"informix".si_ptf 
							    WHERE id_ptf = cFolioSucursal AND tipo='S';
									
        						SELECT FIRST 1 numerociudadcoppel INTO vciudadconyuge FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
								AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
							END IF;
							IF NVL(vcoloniaconyuge, 0) = 0 THEN
							
							--	SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
								
								SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							    INTO vciudadbanco
						     	FROM bdinteg:"informix".si_ptf 
							    WHERE id_ptf = cFolioSucursal AND tipo='S';
										
								SELECT FIRST 1 numerocoloniacoppel INTO vcoloniaconyuge FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
								AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
							END IF;					
							SELECT nombre_empresa 
							INTO vlugartrabajoconyuge 
							FROM bdinteg:"informix".si_ingresos 
							WHERE numcte = vnumcte AND empresa = pempresa AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = vnumcte AND empresa = pempresa); 						 
							 IF cflaguht = 'S' THEN
								LET vflaguhy = 1;
							ELSE
								LET vflaguhy = 0;
							END IF;							
							--OBTIENE LOS DATOS DE LA REFERENCIA 2
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
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerociudad) = 'V' THEN dir2.numerociudad::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocolonia) = 'V' THEN dir2.numerocolonia::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocalle) = 'V' THEN dir2.numerocalle::INTEGER ELSE 1 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numeroextcalle) = 'V' THEN dir2.numeroextcalle::INTEGER ELSE 1 END,
							NVL(TRIM(REPLACE(dir2.numerointcalle,'|',' ')), ''), dir2.puntocardinal, NVL(TRIM(REPLACE(dir2.observaciones,'|',' ')), ''), NVL(TRIM(REPLACE(dir2.entre_calles,'|',' ')), ''), dir2.unidadhabitac,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.manzana) = 'V' THEN dir2.manzana::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.otros) = 'V' THEN dir2.otros::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.andador) = 'V' THEN dir2.andador::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.etapa) = 'V' THEN dir2.etapa::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.lote) = 'V' THEN dir2.lote::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.edificio) = 'V' THEN dir2.edificio::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.entrada) = 'V' THEN dir2.entrada::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono1) = 'V' THEN dir2.telefono1::INT8 ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono2) = 'V' THEN dir2.telefono2::INT8 ELSE 0 END
							INTO vciudadbanco,vcoloniabanco,vcallereferencia2,iNumerocasaref2,vdeptoointeriorreferencia2,vrumboreferencia2,
							vcomplementoreferencia2,ventrecallesreferencia2,cflaguht,vuhrmanzana2,vuhrotros2,vuhrandador2,vuhretapa2,vuhrlote2,vuhredificio2,
							vuhrentrada2,vtelefonoreferencia2,vtelefonocelularreferencia2
							FROM bdinteg:"informix".si_refdirecciones dir2
							WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;	
							IF iNumerocasaref2 = 0 THEN
								LET iNumerocasaref2 = 1;
							END IF;
							IF NVL(vcomplementoreferencia2, '') = '' THEN
								LET vcomplementoreferencia2 = 'E';
							END IF;							
							SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
							INTO vciudadreferencia2, vcoloniareferencia2
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;							
							IF NVL(vciudadreferencia2, 0) = 0 THEN
							
							
						--		SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
								
								SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							    INTO vciudadbanco
						     	FROM bdinteg:"informix".si_ptf 
							    WHERE id_ptf = cFolioSucursal AND tipo='S';														
							
							SELECT FIRST 1 numerociudadcoppel INTO vciudadreferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
								AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
							END IF;
							IF NVL(vcoloniareferencia2, 0) = 0 THEN
								
						--   SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
								
								SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							    INTO vciudadbanco
						     	FROM bdinteg:"informix".si_ptf 
							    WHERE id_ptf = cFolioSucursal AND tipo='S';		
																						
             				SELECT FIRST 1 numerocoloniacoppel INTO vcoloniareferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
								AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
							END IF;							
							IF cflaguht = 'S' THEN
								LET vflaguhr2 = 1;
							ELSE
								LET vflaguhr2 = 0;
							END IF;							
						END IF;										
						--BUSCA DATOS DE REFERENCIAS SI NO ES CASADO
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
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerociudad) = 'V' THEN dir2.numerociudad::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocolonia) = 'V' THEN dir2.numerocolonia::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocalle) = 'V' THEN dir2.numerocalle::INTEGER ELSE 1 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numeroextcalle) = 'V' THEN dir2.numeroextcalle::INTEGER ELSE 1 END,
							NVL(TRIM(REPLACE(dir2.numerointcalle,'|',' ')), ''), dir2.puntocardinal, NVL(TRIM(REPLACE(dir2.observaciones,'|',' ')), ''), NVL(TRIM(REPLACE(dir2.entre_calles,'|',' ')), ''), dir2.unidadhabitac,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.manzana) = 'V' THEN dir2.manzana::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.otros) = 'V' THEN dir2.otros::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.andador) = 'V' THEN dir2.andador::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.etapa) = 'V' THEN dir2.etapa::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.lote) = 'V' THEN dir2.lote::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.edificio) = 'V' THEN dir2.edificio::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.entrada) = 'V' THEN dir2.entrada::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono1) = 'V' THEN dir2.telefono1::INT8 ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono2) = 'V' THEN dir2.telefono2::INT8 ELSE 0 END
							INTO vciudadbanco,vcoloniabanco,vcallereferencia,iNumerocasaref,vdeptoointeriorreferencia,vrumboreferencia,
							vcomplementoreferencia,ventrecallesreferencia1,cflaguht,vuhrmanzana,vuhrotros,vuhrandador,vuhretapa,vuhrlote,vuhredificio,
							vuhrentrada,vtelefonoreferencia,vtelefonocelularreferencia
							FROM bdinteg:"informix".si_refdirecciones dir2
							WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;
							IF iNumerocasaref = 0 THEN
								LET iNumerocasaref = 1;
							END IF;
							IF NVL(vcomplementoreferencia, '') == '' THEN
								LET vcomplementoreferencia = 'E';
							END IF;							
							SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
							INTO vciudadreferencia, vcoloniareferencia
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;							
							IF NVL(vciudadreferencia, 0) = 0 THEN
							
							--	SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
								
								SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							    INTO vciudadbanco
						     	FROM bdinteg:"informix".si_ptf 
							    WHERE id_ptf = cFolioSucursal AND tipo='S';	
								
							
							SELECT FIRST 1 numerociudadcoppel INTO vciudadreferencia FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
								AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
							END IF;
							IF NVL(vcoloniareferencia, 0) = 0 THEN
							
								SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
								
								SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							    INTO vciudadbanco
						     	FROM bdinteg:"informix".si_ptf 
							    WHERE id_ptf = cFolioSucursal AND tipo='S';
																					
							SELECT FIRST 1 numerocoloniacoppel INTO vcoloniareferencia FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
								AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
							END IF;							
							--UNIDAD HABITACIONAL
							IF cflaguht = 'S' THEN
								LET vflaguhr = 1;
							ELSE
								LET vflaguhr = 0;
							END IF;							
							--BUSCA DATOS DE REFERENCIA2
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
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerociudad) = 'V' THEN dir2.numerociudad::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocolonia) = 'V' THEN dir2.numerocolonia::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numerocalle) = 'V' THEN dir2.numerocalle::INTEGER ELSE 1 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.numeroextcalle) = 'V' THEN dir2.numeroextcalle::INTEGER ELSE 1 END,
							NVL(TRIM(REPLACE(dir2.numerointcalle,'|',' ')), ''), dir2.puntocardinal, NVL(TRIM(REPLACE(dir2.observaciones,'|',' ')), ''), NVL(TRIM(REPLACE(dir2.entre_calles,'|',' ')), ''), dir2.unidadhabitac,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.manzana) = 'V' THEN dir2.manzana::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.otros) = 'V' THEN dir2.otros::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.andador) = 'V' THEN dir2.andador::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.etapa) = 'V' THEN dir2.etapa::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.lote) = 'V' THEN dir2.lote::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.edificio) = 'V' THEN dir2.edificio::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.entrada) = 'V' THEN dir2.entrada::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono1) = 'V' THEN dir2.telefono1::INT8 ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir2.telefono2) = 'V' THEN dir2.telefono2::INT8 ELSE 0 END
							INTO vciudadbanco,vcoloniabanco,vcallereferencia2,iNumerocasaref2,vdeptoointeriorreferencia2,vrumboreferencia2,
							vcomplementoreferencia2,ventrecallesreferencia2,cflaguht,vuhrmanzana2,vuhrotros2,vuhrandador2,vuhretapa2,vuhrlote2,vuhredificio2,
							vuhrentrada2,vtelefonoreferencia2,vtelefonocelularreferencia2
							FROM bdinteg:"informix".si_refdirecciones dir2	
							WHERE dir2.numcte = vnumcte AND dir2.secuencia = iRefSecuencias;
							IF iNumerocasaref2 = 0 THEN
								LET iNumerocasaref2 = 1;
							END IF;
							IF NVL(vcomplementoreferencia2, '') = '' THEN
								LET vcomplementoreferencia2 = 'E';
							END IF;							
							--Convierte ciudad, colonia Bancoppel - Coppel
							SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
							INTO vciudadreferencia2, vcoloniareferencia2
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;							
							IF NVL(vciudadreferencia2, 0) = 0 THEN
							
								--SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
								
								SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							    INTO vciudadbanco
						     	FROM bdinteg:"informix".si_ptf 
							    WHERE id_ptf = cFolioSucursal AND tipo='S';
								
							
							SELECT FIRST 1 numerociudadcoppel INTO vciudadreferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
								AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
							END IF;
							IF NVL(vcoloniareferencia2, 0) = 0 THEN
							
							--SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
								
								SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad
							    INTO vciudadbanco
						     	FROM bdinteg:"informix".si_ptf 
							    WHERE id_ptf = cFolioSucursal AND tipo='S';
								
							
							SELECT FIRST 1 numerocoloniacoppel INTO vcoloniareferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco
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
						-----Numero de Dependientes
						SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring
						WHERE grupo = 11 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(rango_minimo) = 'V' THEN rango_minimo::SMALLINT ELSE 0 END 
						INTO vnumerodependientes FROM bdisolic:"informix".ss_scoring_element
						WHERE grupo = 11 AND seccion = 2 AND tpo_persona = '01' AND elemento = iElemento AND activa = 1;
						-----Personas que trabajan
						SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring
						WHERE grupo = 39 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(rango_minimo) = 'V' THEN rango_minimo::SMALLINT ELSE 0 END 
						INTO vpersonastrabajan FROM bdisolic:"informix".ss_scoring_element
						WHERE grupo = 39 AND seccion = 2 AND tpo_persona = '01' AND elemento = iElemento AND activa = 1;
						--TIEMPO DE RESIDENCIA EN DOMICILIO
						SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring 
						WHERE empresa = pempresa AND grupo = 6 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
						SELECT rango_minimo INTO iElemento FROM bdisolic:"informix".ss_scoring_element
						WHERE grupo = 6 AND seccion = 2 AND elemento = iElemento AND activa = 1;
						LET cfechadesdecuandovive = YEAR(dFechaAlta)-iElemento; 
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
								LET cfechaantiguedtrab =  SUBSTR(cfechadesdecuandovive, 1, 4);
								LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||'/01/01';
							ELIF iElemento = 6 OR iElemento = 17 THEN --Desempelado, Jubilado o Pensionado
								LET cfechaantiguedtrab = YEAR(vfechaaltacliente);
								LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||'/01/01';
							END IF;
						ELSE
							LET cfechaantiguedtrab = YEAR(dFechaAlta)-iElemento;
							LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||'/01/01';
						END IF;
						--OBTENER ESCOLARIDAD
						SELECT elemento INTO iElementoScoring FROM bdisolic:"informix".ss_detalle_scoring 
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
						SELECT MAX(ROWID) INTO iRowId FROM bdisolic:"informix".ss_nuevo_parametrico WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito;
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
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(limitecredito) = 'V' THEN limitecredito::SMALLINT ELSE 0 END 
						INTO vlimitecredito FROM bdisolic:"informix".ss_nuevo_parametrico WHERE empresa = pempresa AND ROWID = iRowId;						
						SELECT EVALUACION INTO dEvaluacion1 FROM bdisolic:"informix".ss_resumen_scoring WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND seccion = 1;
						SELECT EVALUACION INTO dEvaluacion2 FROM bdisolic:"informix".ss_resumen_scoring WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND seccion = 2;						
						LET iPuntuacion = (dEvaluacion1+dEvaluacion2);												
						--SECUENCIA DE ARCHIVO
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
						LET vsSQL = TRIM(vclave)||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(vcliente_ref)||"|"||TRIM(NVL(vnombre1, ''))||"|"||TRIM(NVL(vnombre2, ''))||"|"||TRIM(NVL(vapell_paterno, ''))||"|"||TRIM(NVL(vapell_materno, ''))||"|"
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
								||TRIM(NVL(vcomplementoreferencia2, ''))||"|"||TRIM(NVL(ventrecallesreferencia2, ''))||"|"||NVL(vflaguhr2, 0)||"|"||NVL(vuhrmanzana2, 0)||"|"||NVL(vuhrotros2, 0)||"|"||NVL(vuhrandador2, 0)||"|"||NVL(vuhretapa2, 0)||"|"||NVL(vuhrlote2, 0)||"|" 
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
						INSERT  INTO  bdinteg:"informix".si_archivoscoppeldiario (empresa,secuencia,sucursal, trama, tipomovto, fecha_insert)
						VALUES (pempresa, iSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);						
						LET iCuentaRegistros = 1;
					ELSE
						LET vCodRetorno = '000004';
						LET iCuentaRegistros = 2;
					END IF;
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