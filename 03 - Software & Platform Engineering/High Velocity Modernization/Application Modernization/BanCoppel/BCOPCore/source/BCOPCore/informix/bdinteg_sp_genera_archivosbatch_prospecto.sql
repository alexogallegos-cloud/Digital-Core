CREATE PROCEDURE "informix".sp_genera_archivosbatch_prospecto(pempresa CHAR(3), pFechaAct DATE) 
RETURNING CHAR(6) AS cod_ret;		
--DECLARACION DE VARIABLES
DEFINE cNoFm3 CHAR(18);
DEFINE cEmail CHAR(60);
DEFINE cClave,cClaveOS,carea, crumbo, cHabitaen,csexo,cestadocivil,cescolaridad,ctiposueldo,csituacionespecial,cclaveautrechaza,caceptadosupervisadorechazado,cclientenuevo,ccreditojoven,cpuesto,cmarcadatosin , cflagentregotarjeta , cflagnoreconocehuella , ctipo , cTipoOrigen , cBuroPilotoTestig , cModeloCel , cflaguht , cUnidadHabit , cFlagProspecto CHAR(1);
DEFINE scaja,vuhcmanzana,vuhcotros, vuhcandador,vuhcetapa,vuhclote,vuhcedificio,vuhcentrada, vnumerodependientes,vpersonastrabajan, vcausasituacionespecial, vopcionpuesto, vclaveproducto, vSistsegsocial, vTiposueldoext, vNumempleados, vSubopcionpuesto, vPuestoext, vOpcionpuestoext, vNumempleadosext, vSubopcionpuestoext, sPropNegocio, sParCelulares, sParAltoRiesgo, sParPrestamo, vtiporeposicion, vnegocio, vsubnegocio, vtiendafolioanterior, sFlagTestParametrico, sFlagCapCobranza, iFlagLineaCredEsp, sFlagCapHuella,icontador,vingresomensual,sFlag_altadirecta_asupervisar,sNuevo_puntajefinal SMALLINT;
DEFINE vcliente_ref,vlugartrabajo,vlugartrabajoconyuge,vclientereferencia, vnumcte, cClienteConyugebcpl, cClienteReferencia1bcpl , cClienteReferencia2bcpl , vfolio ,  vNumCteProspecto,cNumSolRef CHAR(20);
DEFINE vnombre1,vnombre2,vapell_paterno,vapell_materno,cApellCasada CHAR(26);
DEFINE vciudad,vlimitecredito,vcolonia,vcalle,vpersonasvivenendomicilio,vextensiontrabajo,vflagactualizacion, vreferencia2, vreferencia3, vefectuoAP,vreposicion,vfolioanterior,iMontoIngMensual,  iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, iSqlErr, iValor, iPuntuacion, iSecuencia,inumSecuencia, iElemento, vciudadbanco, vcoloniabanco, iContConsBuro, iCuentaRegistros,vfoliotienda,iGrupo,icontador2,iIsamErr,iTopeMax, iParAltoRiesgoNvo, iPagoUlt12meses,iRowId,iId_Situaciones,iPuntos_Var_Param,iPuntos_Var_SIC,iScore_domicilio INTEGER;
DEFINE iIngreso DECIMAL(18,2);
DEFINE vdeptointerior,vfolioaut,cNumInterior, cFolioSucursal CHAR(4);
DEFINE vcomplemento CHAR(80);
DEFINE ventrecalles,cErrorInfo,cDescError  CHAR(40);
DEFINE vtelefono, vtelefonocelular,vtelefonotrabajo,inumerocasaaux,iNumerocasa,inumerocasatrabajo,icasarefAux,icasatrabajoconyuge INT8;
DEFINE vfechanacimiento,vfechaaltacliente,vfechamovto, vFecha_Hoy,dFechaAlta DATE;
DEFINE vniptitular,vnipadicional  CHAR(7);
DEFINE vcveburo,cMarcarConsultado,cFlagConsBuro,vTipo_Dir,cMarcaHit, vclaveidentificacion,cStatus ,cStatusbcpl, cStatusPenul, 
cStatusAntp,cPuntualidad_ref1,cPuntualidad_ref2 CHAR(2);
DEFINE cfechanac, cfechadesdecuandovive, cfechaantiguedtrab,cfechaaltacte,vfolioconcir,cFechaConsBuro CHAR(10);
DEFINE vcurp,vclaveelector CHAR(18);
DEFINE videntificacion, cEmpleadoSubCob, cEmpleadoGteAutori, vefectuoMOD,vefectuo CHAR(8);
DEFINE vrfc CHAR(13);
DEFINE vfolioconsulta CHAR(9);
DEFINE cfechamovto,cFecha_hoy CHAR (19);
DEFINE vTipoProducto CHAR(5);
DEFINE cNacionalidad,cPais,cEstado,cDelegMunicip,cMotivobcpl CHAR(3);
DEFINE cNoIMSS CHAR(12);
DEFINE vFechaHora DATETIME  YEAR TO SECOND;
DEFINE vFechaHoraMax DATETIME  YEAR TO SECOND;
DEFINE vFechaHoraP DATETIME  YEAR TO SECOND;
DEFINE cDescripElemento CHAR(50);
DEFINE vNombre CHAR(104);
DEFINE vCodRetorno Char(6);
DEFINE bMovimiento BOOLEAN;
--DIRECCION DEL TRABAJO
DEFINE sestadotrabajo SMALLINT;		
DEFINE sciudadtrabajo SMALLINT;		
DEFINE scoloniatrabajo  SMALLINT;             
DEFINE icalletrabajo INTEGER;                 
DEFINE cdeptoointeriortrabajo CHAR(4);           
DEFINE crumbotrabajo CHAR(1);                   
DEFINE ccomplementotrabajo CHAR(80);             
DEFINE centrecallestrabajo CHAR(40);             
DEFINE sflaguht SMALLINT;                               
DEFINE suhtmanzana SMALLINT;                        
DEFINE suhtotros SMALLINT;                            
DEFINE suhtandador SMALLINT;                          
DEFINE suhtetapa SMALLINT;                             
DEFINE suhtlote SMALLINT;                             
DEFINE suhtedificio SMALLINT;                           
DEFINE suhtentrada SMALLINT;         
--DIRECCION DEL AUXILIAR
DEFINE sestadoaux 			SMALLINT;		
DEFINE sciudadaux 			INTEGER;		
DEFINE scoloniaaux  		INTEGER;             
DEFINE icalleaux 			INTEGER;                 
DEFINE cdeptoointerioraux 	CHAR(4);           
DEFINE crumboaux 			CHAR(1);                   
DEFINE ccomplementoaux 		CHAR(80);             
DEFINE centrecallesaux 		CHAR(40);             
DEFINE sflaguhtaux 			SMALLINT;                               
DEFINE suhtmanzanaaux 		SMALLINT;                        
DEFINE suhtotrosaux 		SMALLINT;                            
DEFINE suhtandadoraux 		SMALLINT;                          
DEFINE suhtetapaaux 		SMALLINT;                             
DEFINE suhtloteaux 			SMALLINT;                             
DEFINE suhtedificioaux 		SMALLINT;                           
DEFINE suhtentradaaux 		SMALLINT;     
--Referencia Conyuge							
DEFINE iclienteconyuge              	INT8;   
DEFINE cnombreunoconyuge            	CHAR(26);  
DEFINE cnombredosconyuge            	CHAR(26);  
DEFINE capellidopaternoconyuge      	CHAR(26);  
DEFINE capellidomaternoconyuge      	CHAR(26);  
DEFINE csexoconyuge                 	CHAR(1);   
DEFINE clugartrabajoconyuge         	CHAR(20);  
DEFINE sciudadconyuge               	SMALLINT;  
DEFINE scoloniaconyuge              	SMALLINT;  
DEFINE icalletrabajoconyuge         	INTEGER;   
DEFINE cdeptoointeriorconyuge       	CHAR(4);   
DEFINE crumbotrabajoconyuge         	CHAR(1);   
DEFINE ccomplementoconyuge          	CHAR(80);  
DEFINE centrecallesconyuge          	CHAR(40);  
DEFINE sflaguhy                     	SMALLINT;  
DEFINE suhymanzana                  	SMALLINT;  
DEFINE suhyotros                    	SMALLINT;  
DEFINE suhyandador                  	SMALLINT;  
DEFINE suhyetapa                    	SMALLINT;  
DEFINE suhylote                     	SMALLINT;  
DEFINE suhyedificio                 	SMALLINT;  
DEFINE suhyentrada                  	SMALLINT;  
DEFINE ctelefonotrabajoconyuge      	CHAR(10);   
DEFINE ctelefonocelularconyuge      	CHAR(10);   
DEFINE cclaveconyugefamilia         	CHAR(1);   
--Referencia Auxiliar
DEFINE ictereferenciaAux			   INT8;  
DEFINE cnombre1refAux         	       CHAR(26); 
DEFINE cnombre2refAux          	       CHAR(26); 
DEFINE capellpatrefAux   		       CHAR(26); 
DEFINE capellmatrefAux    		       CHAR(26); 
DEFINE csexorefAux                     CHAR(1);  
DEFINE sciudadrefAux                   SMALLINT; 
DEFINE scoloniarefAux                  INTEGER; 
DEFINE icallerefAux                    INTEGER;  
DEFINE cdeptoointrefAux     	       CHAR(4);  
DEFINE crumborefAux                    CHAR(1);  
DEFINE ccomplementorefAux              CHAR(80); 
DEFINE centrecallesrefAux              CHAR(40); 
DEFINE sflaguhrAux                     SMALLINT; 
DEFINE suhrmanzanaAux                  SMALLINT; 
DEFINE suhrotrosAux                    SMALLINT; 
DEFINE suhrandadorAux                  SMALLINT; 
DEFINE suhretapaAux                    SMALLINT; 
DEFINE suhrloteAux                     SMALLINT; 
DEFINE suhredificioAux                 SMALLINT; 
DEFINE suhrentradaAux                  SMALLINT; 
DEFINE ctelrefAux           	       CHAR(10);  
DEFINE ctelcelrefAux    		       CHAR(10);  
DEFINE cclaverefAux                    CHAR(1);  
DEFINE cCteRefbcplAux			       CHAR(20);  
--Referencia uno							
DEFINE iclientereferencia           	INT8;   
DEFINE cnombreunoreferencia         	CHAR(26);  
DEFINE cnombredosreferencia         	CHAR(26);  
DEFINE capellidopaternoreferencia   	CHAR(26);  
DEFINE capellidomaternoreferencia   	CHAR(26);  
DEFINE csexoreferencia              	CHAR(1);   
DEFINE sciudadreferencia            	SMALLINT;  
DEFINE scoloniareferencia           	SMALLINT;  
DEFINE 	icallereferencia             	INTEGER;   
DEFINE icasareferencia              	INTEGER;   
DEFINE cdeptoointeriorreferencia    	CHAR(4);   
DEFINE crumboreferencia             	CHAR(1);   
DEFINE ccomplementoreferencia       	CHAR(80);  
DEFINE centrecallesreferencia1      	CHAR(40);  
DEFINE sflaguhr                     	SMALLINT;  
DEFINE suhrmanzana                  	SMALLINT;  
DEFINE suhrotros                    	SMALLINT;  
DEFINE suhrandador                  	SMALLINT;  
DEFINE suhretapa                    	SMALLINT;  
DEFINE suhrlote                     	SMALLINT;  
DEFINE suhredificio                 	SMALLINT;  
DEFINE suhrentrada                  	SMALLINT;  
DEFINE ctelefonoreferencia          	CHAR(10);   
DEFINE ctelefonocelularreferencia   	CHAR(10);   
DEFINE cclavereferencia1            	CHAR(1);   
--Referencia 2
DEFINE iclientereferencia2          	INT8;  
DEFINE cnombreunoreferencia2        	CHAR(26); 
DEFINE cnombredosreferencia2        	CHAR(26); 
DEFINE capellidopaternoreferencia2  	CHAR(26); 
DEFINE capellidomaternoreferencia2  	CHAR(26); 
DEFINE csexoreferencia2             	CHAR(1);  
DEFINE sciudadreferencia2           	SMALLINT; 
DEFINE scoloniareferencia2          	SMALLINT; 
DEFINE icallereferencia2            	INTEGER;  
DEFINE icasareferencia2             	INTEGER;  
DEFINE cdeptoointeriorreferencia2   	CHAR(4);  
DEFINE crumboreferencia2            	CHAR(1);  
DEFINE ccomplementoreferencia2      	CHAR(80); 
DEFINE centrecallesreferencia2      	CHAR(40); 
DEFINE sflaguhr2                    	SMALLINT; 
DEFINE suhrmanzana2                 	SMALLINT; 
DEFINE suhrotros2                   	SMALLINT; 
DEFINE suhrandador2                 	SMALLINT; 
DEFINE suhretapa2                   	SMALLINT; 
DEFINE suhrlote2                    	SMALLINT; 
DEFINE suhredificio2                	SMALLINT; 
DEFINE suhrentrada2                 	SMALLINT; 
DEFINE ctelefonoreferencia2         	CHAR(10);  
DEFINE ctelefonocelularreferencia2  	CHAR(10);  
DEFINE cclavereferencia2            	CHAR(1);   	

DEFINE cObservs				char(80);
DEFINE cTrama LVARCHAR		(32000);
DEFINE vNumCteProspectoAnt	CHAR(20);

DEFINE cClaveOSAnt					CHAR(1);
DEFINE cStatusParam					CHAR(1);
DEFINE cSituacionespecial_aut		CHAR(1);
DEFINE iCausasituacionespecial_aut	SMALLINT;
DEFINE dFechaTemp					DATETIME YEAR TO FRACTION(5);
DEFINE dFechaSupervisar				 DATE;
DEFINE cCanal_origensol    	CHAR(4);   --RQM 09 541-2 CrÃÂ©dito Motos Coppel en Alta ÃÂnica 06/04/2021

--INICIALIZACION DE VARIABLES
LET cClave = '';
LET cClaveOS = '';
LET scaja = 100;
LET carea = 'N';
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
LET crumbo = '';
LET vcomplemento = '';
LET ventrecalles = '';
LET vuhcmanzana = 0;
LET vuhcotros = 0;
LET vuhcandador = 0;
LET vuhcetapa = 0; 
LET vuhclote  = 0;
LET vuhcedificio = 0;
LET vuhcentrada = 0;
LET vtelefono = 0;
LET vtelefonocelular = 0;
LET cHabitaen = '';
LET vniptitular = '';
LET vnipadicional = '';
LET csexo = '';
LET cestadocivil = '';
LET cfechanac = '1900/01/01';
LET cfechadesdecuandovive = '1900/01/01';
LET vpersonasvivenendomicilio = 0;
LET cescolaridad = '';
LET ctiposueldo = '';
LET vnumerodependientes = 0;
LET vpersonastrabajan = 0;
LET vlimitecredito = 0;
LET vingresomensual = 0;
LET csituacionespecial = '';
LET vcausasituacionespecial = 0;
LET cclaveautrechaza = '2';
LET caceptadosupervisadorechazado = 'P';
LET cclientenuevo = 'N';
LET ccreditojoven = '';
LET vlugartrabajo = '';
LET vtelefonotrabajo = 0;
LET vextensiontrabajo = 0;
LET cpuesto = '0';
LET vopcionpuesto = 0;
LET cfechaantiguedtrab = '1900/01/01';
LET cSexoConyuge = '';
LET vlugartrabajoconyuge = '';
LET crumbotrabajoconyuge = '';
LET cclaveconyugefamilia = 'E';
LET cSexoReferencia = '';
LET cclavereferencia1 = '';
LET cSexoReferencia2 = '';
LET cclavereferencia2 = '';
LET vreferencia2 = 0;
LET vreferencia3 = 0;
LET cmarcadatosin = '';
LET vtiporeposicion = 0;
LET vreposicion = 0;
LET cflagentregotarjeta = '';
LET vefectuo = 0;
LET vefectuoAP=0;
LET vefectuoMOD=0;
LET vfolio = '0';
LET cfechaaltacte = '1900/01/01';
LET cflagnoreconocehuella = '';
LET vfoliotienda = 0;
LET vrfc = ''; 
LET vcveburo = '';
LET vfolioaut = '';
LET vfolioconsulta = '';
LET vfolioconcir = '';
LET vnegocio = 0;
LET vsubnegocio = 0;
LET ctipo = 'A';
LET cfechamovto = '1900/01/01';
LET vnumcte = '';
LET vtiendafolioanterior = 0;
LET vfolioanterior = 0;
LET vclaveproducto = 6500;
LET vflagactualizacion = 0;
LET vSistsegsocial = 0;
LET vTiposueldoext = 0;
LET vNumempleados = 0;
LET vSubopcionpuesto = 0;
LET vPuestoext = 0;
LET vOpcionpuestoext = 0;
LET vNumempleadosext = 0;
LET vSubopcionpuestoext = 0;
LET cTipoOrigen = 'G';
LET vTipoProducto = '00100';
LET cEmpleadoSubCob = '';
LET sFlagCapHuella = 0;
LET cMarcarConsultado = '';
LET sFlagTestParametrico = 0;
LET sFlagCapCobranza = 0;
LET cEmpleadoGteAutori = 0;
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
LET cFechaConsBuro = '1900/01/01';
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
LET cFolioSucursal = '0';
LET cflaguht = '';
LET vfechanacimiento = DATE(1); 
LET vfechaaltacliente = DATE(1);
LET vfechamovto = DATE(1);
LET cUnidadHabit = '';
LET vTipo_Dir = '';
LET vFecha_Hoy = DATE(1);
LET vNombre = '';
LET vCodRetorno = '000000';
LET dFechaAlta = DATE(1);
LET iValor = 0;
LET iTopeMax=0;
LET iIngreso = 0;
LET iPuntuacion = 0;
LET cFecha_hoy = '1900/01/01';
LET iSecuencia = 0;
LET inumSecuencia= 0;
LET cMarcaHit = '';
LET iElemento = 0;
LET vciudadbanco = 0;
LET vcoloniabanco = 0;
LET iContConsBuro = 0;
LET cDescripElemento = '';
LET iCuentaRegistros = 0;
LET cStatus = '';
LET icontador = 0;
LET icontador2 = 0;
LET cNumSolRef='';
LET cErrorInfo='';
LET iIsamErr='';
LET cDescError='';
LET cStatusbcpl= "";
LET cMotivobcpl="";
LET cFlagProspecto="";
LET iParAltoRiesgoNvo=-99999;
LET iPagoUlt12meses=99999;
LET vFechaHora = "";
LET vFechaHoraMax = "";
LET cStatusPenul='';
LET cStatusAntp='';
LET vFechaHoraP = "";
LET bMovimiento="F";
LET vNumCteProspecto='';
LET cClave='';
--direccion del trabajo
LET sestadotrabajo			= 0;
LET sciudadtrabajo			= 0;
LET scoloniatrabajo			= 0;
LET icalletrabajo 			= 0;
LET inumerocasatrabajo 		=0;
LET cdeptoointeriortrabajo 	= '';
LET crumbotrabajo			='';
LET ccomplementotrabajo		='';
LET centrecallesTrabajo		='';
LET sflaguht				=0;
LET suhtmanzana				=0;
LET suhtotros				=0;
LET suhtandador				=0;
LET suhtetapa				=0;
LET suhtlote				=0;
LET suhtedificio			=0;
LET suhtentrada				=0;				
-- Direccion Auxiliar
LET sestadoaux 			= 0;
LET sciudadaux 			= 0;
LET scoloniaaux  		= 0;
LET icalleaux 			= 0;
LET inumerocasaaux 		= 0;
LET cdeptoointerioraux 	= '';
LET crumboaux 			='';
LET ccomplementoaux 	='';	
LET centrecallesaux 	='';	
LET sflaguhtaux 		= 0;	
LET suhtmanzanaaux 		= 0;
LET suhtotrosaux 		= 0;
LET suhtandadoraux 		= 0;
LET suhtetapaaux 		= 0;
LET suhtloteaux 		= 0;	
LET suhtedificioaux 	= 0;	
LET suhtentradaaux 		= 0;		
--Referencia Conyuge							
LET iclienteconyuge              	       = 0;
LET cnombreunoconyuge            	       = '';
LET cnombredosconyuge            	       = '';
LET capellidopaternoconyuge      	       = '';
LET capellidomaternoconyuge      	       = '';
LET csexoconyuge                 	       = '';
LET clugartrabajoconyuge         	       = '';
LET sciudadconyuge               	       = 0;
LET scoloniaconyuge              	       = 0;
LET icalletrabajoconyuge         	       = 0;
LET icasatrabajoconyuge          	       = 0;
LET cdeptoointeriorconyuge       	       = '';
LET crumbotrabajoconyuge         	       = '';
LET ccomplementoconyuge          	       = '';
LET centrecallesconyuge          	       = '';
LET sflaguhy                     	       = 0;
LET suhymanzana                  	       = 0;
LET suhyotros                    	       = 0;
LET suhyandador                  	       = 0;
LET suhyetapa                    	       = 0;
LET suhylote                     	       = 0;
LET suhyedificio                 	       = 0;
LET suhyentrada                  	       = 0;
LET ctelefonotrabajoconyuge      	       = 0;
LET ctelefonocelularconyuge      	       = '0';
LET cclaveconyugefamilia         	       = '';
--Referencia uno					       
LET iclientereferencia           	       = 0;
LET cnombreunoreferencia         	       = '';
LET cnombredosreferencia         	       = '';
LET capellidopaternoreferencia   	       = '';
LET capellidomaternoreferencia   	       = '';
LET csexoreferencia              	       = '';
LET sciudadreferencia            	       = 0;
LET scoloniareferencia           	       = 0;
LET icallereferencia             	       = 0;
LET icasareferencia              	       = 0;
LET cdeptoointeriorreferencia    	       = '';
LET crumboreferencia             	       = '';
LET ccomplementoreferencia       	       = 'E';
LET centrecallesreferencia1      	       = '';
LET sflaguhr                     	       = 0;
LET suhrmanzana                  	       = 0;
LET suhrotros                    	       = 0;
LET suhrandador                  	       = 0;
LET suhretapa                    	       = 0;
LET suhrlote                     	       = 0;
LET suhredificio                 	       = 0;
LET suhrentrada                  	       = 0;
LET ctelefonoreferencia          	       = '0';
LET ctelefonocelularreferencia   	       = '0';
LET cclavereferencia1            	       = '';  
--Referencia 2                            
LET iclientereferencia2          	       = 0;
LET cnombreunoreferencia2        	       = '';
LET cnombredosreferencia2        	       = '';
LET capellidopaternoreferencia2  	       = '';
LET capellidomaternoreferencia2  	       = '';
LET csexoreferencia2             	       = '';
LET sciudadreferencia2           	       = 0;
LET scoloniareferencia2          	       = 0;
LET icallereferencia2            	       = 0;
LET icasareferencia2             	       = 0;
LET cdeptoointeriorreferencia2   	       = '';
LET crumboreferencia2            	       = '';
LET ccomplementoreferencia2      	       = 'E';
LET centrecallesreferencia2      	       = '';
LET sflaguhr2                    	       = 0;
LET suhrmanzana2                 	       = 0;
LET suhrotros2                   	       = 0;
LET suhrandador2                 	       = 0;
LET suhretapa2                   	       = 0;
LET suhrlote2                    	       = 0;
LET suhredificio2                	       = 0;
LET suhrentrada2                 	       = 0;
LET ctelefonoreferencia2         	       = '0';
LET ctelefonocelularreferencia2  	       = '0';
LET cclavereferencia2            	       = '';
--Ref Auxiliar
LET ictereferenciaAux		       = 0;
LET cnombre1refAux        	       = '';
LET cnombre2refAux        	       = '';
LET capellpatrefAux   		       = '';
LET capellmatrefAux    		       = '';
LET csexorefAux           	       = '';
LET sciudadrefAux         	       = 0;	
LET scoloniarefAux        	       = 0;	
LET icallerefAux          	       = 0;	
LET icasarefAux           	       = 0;	
LET cdeptoointrefAux     	       = '';
LET crumborefAux          	       = '';
LET ccomplementorefAux    	       = '';
LET centrecallesrefAux    	       = '';
LET sflaguhrAux           	       = 0;	
LET suhrmanzanaAux        	       = 0;	
LET suhrotrosAux          	       = 0;	
LET suhrandadorAux        	       = 0;
LET suhretapaAux          	       = 0;	
LET suhrloteAux           	       = 0;	
LET suhredificioAux       	       = 0;
LET suhrentradaAux        	       = 0;	
LET ctelrefAux           	       = '';	
LET ctelcelrefAux    		       = '';	
LET cclaverefAux          	       = '';
LET cCteRefbcplAux         	       = '';
LET iId_Situaciones				   = 0;
LET cPuntualidad_ref1              = '';
LET cPuntualidad_ref2			   = '';
LET sFlag_altadirecta_asupervisar  = 0;
LET iPuntos_Var_Param			   = 0;
LET iPuntos_Var_SIC				   = 0;
LET iScore_domicilio			   = 0;
LET sNuevo_puntajefinal			   = 0;
LET iRowId 						   = 0;
LET cObservs = '';
LET cTrama = '';

LET vNumCteProspectoAnt = '';
LET cClaveOSAnt = '';
LET cStatusParam = '';

LET cSituacionespecial_aut ='';
LET iCausasituacionespecial_aut =0;
LET dFechaTemp = current;
LET dFechaSupervisar = DATE(1); 
LET cCanal_origensol='';   --RQM 09 541-2 CrÃÂ©dito Motos Coppel en Alta ÃÂnica 06/04/2021

SET ISOLATION TO DIRTY READ;
	BEGIN
		ON EXCEPTION
		SET iSqlErr,iIsamErr,cErrorInfo
		--SET DEBUG FILE TO '/RESPALDOS/sp_generaarchivosbatch.out';
		--TRACE ON;
				LET vNumCteProspecto = vNumCteProspecto;
			IF iSqlErr <> 0 THEN
				LET vCodRetorno = iSqlErr;
				LET cDescError= cErrorInfo;
                IF NOT EXISTS(SELECT numerosolicitud FROM "informix".si_bitacora_errorbatch where numerosolicitud = vNumCteProspecto and numcte = vnumcte) THEN
					INSERT INTO "informix".si_bitacora_errorbatch (numerosolicitud,numcte,error,observaciones,trama,fecha_insert) VALUES (vNumCteProspecto,vnumcte,iSqlErr,cObservs,cTrama,NVL(vFecha_Hoy,DATE(1)));
					RETURN vCodRetorno; --DSB20210705				  
				END IF 
		END IF;
	END EXCEPTION  WITH RESUME;
	
	SET LOCK MODE TO WAIT 3;
	--SET DEBUG FILE TO "/tmp/Victor/sp_genera_archivosbatch_prospecto.out";
	--TRACE ON;
	
	    
	IF pFechaAct <> MDY(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		SELECT fecha_hoy INTO vFecha_Hoy FROM "informix".si_fechas WHERE empresa = '001';
		IF vFecha_Hoy = MDY(1,1,1900) OR vFecha_Hoy IS NULL THEN
				LET vCodRetorno = '000002';
			ELSE	
				UPDATE STATISTICS MEDIUM FOR TABLE bdinteg:"informix".si_archivoscopdiario;
				SELECT secuencia_max INTO inumSecuencia FROM bdinteg:"informix".si_archivosecuenciamax where empresa = '001' and secuencia_max = secuencia_max;
				--SE OBTIENE VALOR DE SALARIOS MINIMOS
				SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(valor) = 'V' THEN valor::INTEGER ELSE 0 END 
				INTO iValor FROM bdisolic:"informix".ss_param WHERE secuencia = 363;
				--SE OBTIENE VALOR DE TOPE MAXIMO DE INGRESO MENSUAL --2013-12-06 RQI 27 096 AAME										
				SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(valor) = 'V' THEN valor::INTEGER ELSE 0 END 
				INTO iTopeMax FROM bdisolic:"informix".ss_param WHERE secuencia = 373;

                LET cObservs = TRIM('Paso 85');
				FOREACH WITH HOLD
					SELECT sss.numcte_pros, sss.numcte, ssa.fecha_entrada, sss.sucursal, sss.fecha_insert,ssa.status_solicitud,
					ssa.ejecutivo_auto,sss.user_insert, ssa.fecha_hora, sss.emp_cob_alta,
					sss.nombre1, sss.nombre2, sss.apell_paterno, sss.apell_materno, sss.rfc,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(string2) = 'V' THEN string2:: INTEGER ELSE 0 END,
					CASE WHEN ssa.status_solicitud = 'PC' THEN '' ELSE 'M' END,
					CASE WHEN ssa.status_solicitud IN('RT','CN') THEN causa_solicitud ELSE '' END,
					CASE WHEN ssa.status_solicitud IN ('PC','EC','AN','CE','CN','EE') THEN '' ELSE
					DECODE (ssa.status_solicitud,'AT','A','OA','D','OS','P','RT','H')
					END,
					CASE WHEN sss.id_empcob = 0 THEN 0 ELSE 1 END,
					CASE WHEN sss.id_empcob = 0 THEN 2 ELSE 3 END,
					ssa.situacion_especial, ssa.causa_situacion --prueba
					INTO vNumCteProspecto, vnumcte, vfechaaltacliente, cFolioSucursal, dFechaAlta,cStatus,cEmpleadoGteAutori,vefectuoMOD, 
					vFechaHora,cEmpleadoSubCob,vnombre1,vnombre2, vapell_paterno, vapell_materno, vrfc, vpersonasvivenendomicilio,cClave,cMotivobcpl
					,cStatusbcpl, sFlagCapCobranza, cFlagProspecto,
					csituacionespecial_aut, icausasituacionespecial_aut 
					FROM bdiprospectos:"informix".pr_autorizacion ssa
					LEFT JOIN bdiprospectos:"informix".pr_cliente sss
					ON sss.numcte_pros = ssa.num_solicitud
					WHERE ssa.fecha_entrada =  pFechaAct
					AND sss.empresa = ssa.empresa
					AND sss.tipo_cliente="3"
					AND sss.empresa = pempresa
					
					IF LEFT(vNumCteProspecto,1) = 'P' THEN
						LET cTipoOrigen = 'N';
					END IF;				
					
					LET inumSecuencia = inumSecuencia + 1;	
					
				--SE OBTIENEN LOS DATOS DEL PROSPECTO
				IF vNumCteProspectoAnt <> vNumCteProspecto  THEN
					
					LET vNumCteProspectoAnt = vNumCteProspecto;
					LET cfechamovto = vFechaHora;
					LET cObservs = TRIM('Paso 86');
					LET vcliente_ref = "0";
					LET cclaveconyugefamilia='';
					LET cSexoConyuge='';
					LET cclavereferencia1='';
					LET cSexoReferencia='';
					LET icontador = 0;
					LET vlugartrabajo = '';
					LET vlugartrabajoconyuge = '';
					LET iSecuencia=0;
					LET cEstado='';
					LET sParCelulares=0;
					LET sParAltoRiesgo=0;
					LET sParPrestamo=0;
					LET cNumSolRef = '';					
					LET cpuesto = '0';
					--CONSULTA LA INFORMACION DE LA DIRECCION DEL CLIENTE
					LET cObservs = TRIM('Paso 87');
					SELECT estado_civil,  habita_en, sexo, fecha_nac, nacionalidad, curp, codidentifi,numidentifi,no_fm3,no_imss
					INTO cestadocivil, cHabitaen, csexo, vfechanacimiento,cNacionalidad,vcurp,vclaveidentificacion,videntificacion,cNoFm3,cnoimss
					FROM bdiprospectos:"informix".pr_ctepf
					WHERE numcte_pros = vNumCteProspecto;
					LET cObservs = TRIM('Paso 88');
					SELECT NVL(correo_elec,"") INTO cEmail 
					FROM bdiprospectos:"informix".pr_correos 
					WHERE numcte_pros = vNumCteProspecto 
					AND status_correo = "A";
					
					IF cEmail IS NULL THEN 
						LET cEmail="";
					END IF;
					
					--DIRECCION Y TELEFONO
					FOREACH WITH HOLD
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerociudad) = "V" THEN dir.numerociudad::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocolonia) = "V" THEN dir.numerocolonia::INTEGER ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocalle) = "V" THEN dir.numerocalle::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numeroextcalle) = "V" THEN dir.numeroextcalle::INT8 ELSE 0 END,
						NVL(TRIM(REPLACE(REPLACE(dir.numerointcalle,"|"," "),"//","/")),""),dir.puntocardinal,
						NVL(TRIM(REPLACE(REPLACE(dir.observaciones,"|"," "),"//","/")),""),NVL(TRIM(REPLACE(REPLACE(dir.entre_calles,"|"," "),"//","/")),""), 
						DECODE (dir.unidadhabitac,"S","1","0"), 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.manzana) = "V" THEN dir.manzana::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.otros) = "V" THEN dir.otros::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.andador) = "V" THEN dir.andador::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.etapa) = "V" THEN dir.etapa::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.lote ) = "V" THEN dir.lote::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.edificio) = "V" THEN dir.edificio::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.entrada) = "V" THEN dir.entrada::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel1.telefono,0)) = "V" THEN tel1.telefono::INT8 ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel2.telefono,0)) = "V" THEN tel2.telefono::INT8 ELSE 0 END, 
						dir.tipo_dir,NVL(TRIM(REPLACE(REPLACE(dir.numerointcalle,"|"," "),"//","/")),""), dir.estado, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel3.telefono,0)) = "V" THEN tel3.telefono::INT8 ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel3.extension,0)) = "V" THEN tel3.extension::INTEGER ELSE 0 END,
						pais
						INTO  vciudadbanco, vcoloniabanco, icalleaux, inumerocasaaux, cdeptoointerioraux, crumboaux, ccomplementoaux, centrecallesaux, sflaguhtaux, 
						suhtmanzanaaux,suhtotrosaux,suhtandadoraux, suhtetapaaux, suhtloteaux, suhtedificioaux, suhtentradaaux, 
						vtelefono, vtelefonocelular, vTipo_Dir, cNumInterior, sestadoaux,vtelefonotrabajo,vextensiontrabajo,cpais
						FROM bdiprospectos:"informix".pr_direcciones_actual dir
						LEFT OUTER JOIN bdiprospectos:"informix".pr_telefonos tel1 
						ON ( tel1.numcte_pros = dir.numcte_pros AND tel1.tipo_tel = 1 AND tel1.status_tel="A")
						LEFT OUTER JOIN bdiprospectos:"informix".pr_telefonos tel2 
						ON ( tel2.numcte_pros = dir.numcte_pros AND tel2.tipo_tel = 2 AND tel2.status_tel="A")
						LEFT OUTER JOIN bdiprospectos:"informix".pr_telefonos tel3 ON ( tel3.numcte_pros = dir.numcte_pros AND tel3.tipo_tel = 3 )
						WHERE dir.numcte_pros = vNumCteProspecto AND dir.tipo_dir IN ("1" ,"2")
						AND dir.secuencia = (SELECT MAX(dir2.secuencia) FROM bdiprospectos:"informix".pr_direcciones_actual dir2 
											WHERE dir2.numcte_pros = vNumCteProspecto AND dir2.tipo_dir = dir.tipo_dir)
						ORDER BY dir.tipo_dir DESC
						
						LET cObservs = TRIM('Paso 89');
						--SE OBTIENE DEL ESTADO
						LET cEstado = sestadoaux;
						
						LET cObservs = TRIM('Paso 90');
						-- SE OBTIENE EL NOMBRE DE LA CIUDAD Y COLONIA
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel,numerocoloniacoppel
						INTO sciudadaux, scoloniaaux
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						LET cObservs = TRIM('Paso 91');
						--SI NO EXISTEN LA CIUDAD Y COLONIA, SE TOMARA DE LA SUCURSAL
						--SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT cve_ciudad INTO vciudadbanco FROM bdinteg:"informix".si_ptf WHERE id_ptf = cFolioSucursal AND tipo='S';
						IF NVL(sciudadaux, 0) = 0 THEN
							SELECT FIRST 1 numerociudadcoppel INTO sciudadaux FROM bdinteg:"informix".si_catzonas 
							WHERE numerociudad = vciudadbanco;
							IF NVL(sciudadaux, 0) = 0 THEN
									SELECT FIRST 1 numerociudadcoppel INTO sciudadaux FROM bdinteg:"informix".si_catzonas 
									WHERE numerociudadcoppel <> 0;
							END IF;
						END IF;
						IF NVL(scoloniaaux, 0) = 0 THEN
							SELECT FIRST 1 numerocoloniacoppel INTO scoloniaaux FROM bdinteg:"informix".si_catzonas 
							WHERE numerociudad = vciudadbanco;
							IF NVL(scoloniaaux, 0) = 0 THEN
								SELECT FIRST 1 numerocoloniacoppel INTO scoloniaaux FROM bdinteg:"informix".si_catzonas 
								WHERE numerocoloniacoppel <> 0;
							END IF;
						END IF;
	  
						IF inumerocasaaux > 32767 THEN
							LET inumerocasaaux = 0;
						END IF;
						
						IF vTipo_Dir ="1" THEN
							LET cObservs = TRIM('Paso 92');
							LET vciudad			= NVL(sciudadaux,0);
							LET vcolonia		= NVL(scoloniaaux,0);
							LET vcalle 			= NVL(icalleaux,0);
							LET iNumerocasa 	= DECODE (NVL(inumerocasaaux,0),0,1,inumerocasaaux);
							LET vdeptointerior 	= NVL(cdeptoointerioraux,'');
							LET crumbo			= NVL(crumboaux,'');
							LET vcomplemento	= DECODE (NVL(ccomplementoaux,''),'','E',ccomplementoaux);
							LET ventrecalles	= NVL(centrecallesaux,'');
							LET cUnidadHabit	= NVL(sflaguhtaux,0);
							LET vuhcmanzana		= NVL(suhtmanzanaaux,0);
							LET vuhcotros		= NVL(suhtotrosaux,0);
							LET vuhcandador		= NVL(suhtandadoraux,0);
							LET vuhcetapa		= NVL(suhtetapaaux,0);
							LET vuhclote		= NVL(suhtloteaux,0);
							LET vuhcedificio	= NVL(suhtedificioaux,0);
							LET vuhcentrada		= NVL(suhtentradaaux,0);
						ELIF vTipo_Dir ="2" THEN
							LET cObservs = TRIM('Paso 93');
							LET sestadotrabajo			= NVL(sestadoaux,0);
							LET sciudadtrabajo			= NVL(sciudadaux,0);
							LET scoloniatrabajo			= NVL(scoloniaaux,0);
							LET icalletrabajo 			= NVL(icalleaux,0);
							LET inumerocasatrabajo 		= DECODE (NVL(inumerocasaaux,0),0,1,inumerocasaaux);
							LET cdeptoointeriortrabajo 	= NVL(cdeptoointerioraux,'');
							LET crumbotrabajo			= NVL(crumboaux,'');
							LET ccomplementotrabajo		= DECODE (NVL(ccomplementoaux,''),'','E',ccomplementoaux);
							LET centrecallesTrabajo		= NVL(centrecallesaux,'');
							LET sflaguht				= NVL(sflaguhtaux,0);
							LET suhtmanzana				= NVL(suhtmanzanaaux,0);
							LET suhtotros				= NVL(suhtotrosaux,0);
							LET suhtandador				= NVL(suhtandadoraux,0);
							LET suhtetapa				= NVL(suhtetapaaux,0);
							LET suhtlote				= NVL(suhtloteaux,0);
							LET suhtedificio			= NVL(suhtedificioaux,0);
							LET suhtentrada				= NVL(suhtentradaaux,0);
						END IF;
					END FOREACH;
					
					--INGRESOS DEL CLIENTE 
					LET cObservs = TRIM('Paso 94');
					SELECT ing.nombre_empresa, 
					CASE WHEN "informix".sp_EsNumerico(ing.claveopcionpuesto) = "V" THEN ing.claveopcionpuesto::SMALLINT ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(ing.clavesubopcionpuesto) = "V" THEN ing.clavesubopcionpuesto::SMALLINT ELSE 0 END, 
					puesto
					INTO vlugartrabajo, vopcionpuesto, vSubopcionpuesto,cPuesto
					FROM bdiprospectos:"informix".pr_ingresos ing
					WHERE ing.numcte_pros = vNumCteProspecto
					AND ing.sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdiprospectos:"informix".pr_ingresos 
					WHERE numcte_pros = vNumCteProspecto AND tipo_ingreso = "T");
					
					LET cObservs = TRIM('Paso 95');
					LET vopcionpuesto = NVL(vopcionpuesto,0);
					LET vSubopcionpuesto=NVL(vSubopcionpuesto,0);
					
					--SE CAMBIA EL FORMATO DE LA FECHA NACIMIENTO, EL ALTA DEL CLIENTE Y OBTENCION DE FECHA DE MOVIMIENTOS
					IF vfechanacimiento >= DATE(1) THEN --DSB20180621
						LET cfechanac = YEAR(vfechanacimiento)||"/"||LPAD(MONTH(vfechanacimiento),2,0)||"/"||LPAD(DAY(vfechanacimiento),2,0);
					ELSE
						LET cfechanac = '1900/01/01';
					END IF;
					LET cfechaaltacte = YEAR(dFechaAlta)||"/"||LPAD(MONTH(dFechaAlta),2,0)||"/"||LPAD(DAY(dFechaAlta),2,0);
					
					LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
					LET cClienteConyugebcpl = '';
					LET cClienteReferencia1bcpl = '';
					LET cClienteReferencia2bcpl = '';
					LET cObservs = TRIM('Paso 96');
					/*
					--SE OBTIENE NUMERO DE SOLICITUD DE BANCO PARA OBTENER SUS REFERENCIAS EN CASO DE QUE A LA SOLICITUD COPPEL NO SE LE HAYAN HEREDADO POR HABER SIDO RECHAZADA ANTES.
					IF NVL(vnumcte,'') <> "" THEN 
						SELECT MAX(num_solicitud)
						INTO cNumSolRef
						FROM bdisolic:"informix".ss_solicitudes
						WHERE empresa = pempresa
						AND numcte = vnumcte
						AND fecha_insert = dFechaAlta
						AND num_producto = '6001'
						AND status_solicitud NOT IN ('AN','PC');
						
						IF NVL(cNumSolRef,'') = '' THEN
							LET cNumSolRef = '';
						END IF;
					END IF;
					*/
					LET icontador2= 0;
					
					--DATOS REFERENCIAS
					LET cObservs = TRIM('Paso 97');
					FOREACH WITH HOLD
						SELECT cts.numcte_banco,CASE WHEN bdinteg:"informix".sp_EsNumerico(cts.numcte_ref) = "V" THEN cts.numcte_ref::INT8 ELSE 0 END,cts.nombre1,cts.nombre2,cts.apell_paterno,cts.apell_materno,cts.parentesco,cts.sexo,cts.secuencia,
						dirf.numerociudad,dirf.numerocolonia,dirf.numerocalle,CASE WHEN bdinteg:"informix".sp_EsNumerico(dirf.numeroextcalle) = "V" THEN dirf.numeroextcalle::INT8 ELSE 0 END,dirf.numerointcalle,dirf.puntocardinal,dirf.observaciones,
						dirf.entre_calles,DECODE (dirf.unidadhabitac,'S',1,0),dirf.manzana,dirf.otros,dirf.andador,dirf.etapa,dirf.lote,dirf.edificio,
						dirf.entrada,CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(dirf.telefono1,0)) = 'V' THEN dirf.telefono1::INT8 ELSE 0 END,CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(dirf.telefono2,0)) = 'V' THEN dirf.telefono2::INT8 ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(dirf.telefono3,0)) = 'V' THEN dirf.telefono3::INT8 ELSE 0 END
						INTO cCteRefbcplAux, ictereferenciaAux, cnombre1refAux, cnombre2refAux, capellpatrefAux, capellmatrefAux, cclaverefAux, csexorefAux,isecuencia,
						sciudadrefAux, scoloniarefAux, icallerefAux, icasarefAux, cdeptoointrefAux, crumborefAux, ccomplementorefAux, centrecallesrefAux, sflaguhrAux,
						suhrmanzanaAux, suhrotrosAux, suhrandadorAux, suhretapaAux, suhrloteAux, suhredificioAux, suhrentradaAux, ctelrefAux, ctelcelrefAux,
						ctelefonotrabajoconyuge
						FROM bdiprospectos:"informix".pr_refclientes cts,
							 bdiprospectos:"informix".pr_refdirecciones dirf
						WHERE cts.empresa = pempresa
						AND cts.numcte_pros = TRIM(vNumCteProspecto) -- numero de cliente prospecto Variable
						AND dirf.numcte_pros = cts.numcte_pros
						and dirf.secuencia = cts.secuencia
						ORDER BY cts.secuencia DESC
						
						LET cObservs = TRIM('Paso 98');
						LET icontador2= icontador2 + 1;
						IF icasarefAux > 32767 THEN
							LET icasarefAux = 0;
						END IF;
						
						IF (cestadocivil = 'C' OR cestadocivil = 'U') AND cclaverefAux = 'E' THEN
							LET cObservs = TRIM('Paso 99');
							--Referencia Conyuge
							LET cClienteConyugebcpl		= TRIM(NVL(cCteRefbcplAux,''));
							LET iclienteconyuge			= NVL(ictereferenciaAux,0);
							LET cnombreunoconyuge		= TRIM(NVL(cnombre1refAux,''));
							LET cnombredosconyuge		= TRIM(NVL(cnombre2refAux,''));
							LET capellidopaternoconyuge	= TRIM(NVL(capellpatrefAux,''));
							LET capellidomaternoconyuge	= TRIM(NVL(capellmatrefAux,''));
							LET csexoconyuge			= TRIM(NVL(csexorefAux,''));     
							LET clugartrabajoconyuge	= ''; -- pendiente 
							LET sciudadconyuge			= NVL(sciudadrefAux,0);
							LET scoloniaconyuge			= NVL(scoloniarefAux,0);
							LET icalletrabajoconyuge	= NVL(icallerefAux,0);
							LET icasatrabajoconyuge		= DECODE(NVL(icasarefAux,0),0,1,icasarefAux);
							LET cdeptoointeriorconyuge	= TRIM(NVL(cdeptoointrefAux,''));
							LET crumbotrabajoconyuge	= TRIM(NVL(crumborefAux,''));
							LET ccomplementoconyuge		= TRIM(NVL(ccomplementorefAux,''));
							LET centrecallesconyuge		= TRIM(NVL(centrecallesrefAux,''));
							LET sflaguhy				= NVL(sflaguhrAux,0);
							LET suhymanzana				= NVL(suhrmanzanaAux,0);
							LET suhyotros				= NVL(suhrotrosAux,0);
							LET suhyandador				= NVL(suhrandadorAux,0);
							LET suhyetapa				= NVL(suhretapaAux,0);
							LET suhylote				= NVL(suhrloteAux,0);
							LET suhyedificio			= NVL(suhredificioAux,0);
							LET suhyentrada				= NVL(suhrentradaAux,0);
							LET ctelefonotrabajoconyuge	= ctelefonotrabajoconyuge;
							LET ctelefonocelularconyuge	= TRIM(NVL(ctelcelrefAux,'0'));
							LET cclaveconyugefamilia	= TRIM(cclaverefAux);
						ELif icontador2 = 2 AND cclaverefAux <> 'E' THEN -- referencia 1
							LET cObservs = TRIM('Paso 100');
							--Referencia uno cuando no es conyuge
							LET cClienteReferencia1bcpl		= TRIM(NVL(cCteRefbcplAux,''));
							LET iclientereferencia			= NVL(ictereferenciaAux,0);
							LET cnombreunoreferencia		= TRIM(NVL(cnombre1refAux,''));
							LET cnombredosreferencia		= TRIM(NVL(cnombre2refAux,''));
							LET capellidopaternoreferencia	= TRIM(NVL(capellpatrefAux,''));
							LET capellidomaternoreferencia	= TRIM(NVL(capellmatrefAux,''));
							LET csexoreferencia				= TRIM(NVL(csexorefAux,''));
							LET sciudadreferencia			= NVL(sciudadrefAux,0);
							LET scoloniareferencia			= NVL(scoloniarefAux,0);
							LET icallereferencia			= NVL(icallerefAux,0);
							LET icasareferencia				= NVL(icasarefAux,0);
							LET cdeptoointeriorreferencia	= TRIM(NVL(cdeptoointrefAux,''));
							LET crumboreferencia			= TRIM(NVL(crumborefAux,''));
							LET ccomplementoreferencia		= TRIM(NVL(ccomplementorefAux,''));
							LET centrecallesreferencia1		= TRIM(NVL(centrecallesrefAux,'')); 
							LET sflaguhr					= NVL(sflaguhrAux,0);
							LET suhrmanzana					= NVL(suhrmanzanaAux,0);
							LET suhrotros					= NVL(suhrotrosAux,0);
							LET suhrandador					= NVL(suhrandadorAux,0);
							LET suhretapa					= NVL(suhretapaAux,0);
							LET suhrlote					= NVL(suhrloteAux,0);
							LET suhredificio				= NVL(suhredificioAux,0);
							LET suhrentrada					= NVL(suhrentradaAux,0);
							LET ctelefonoreferencia			= NVL(ctelrefaux,'0');
							LET ctelefonocelularreferencia	= NVL(ctelcelrefAux,'0');
							LET cclavereferencia1			= TRIM(cclaverefAux);
						ELif icontador2 = 1 AND cclaverefAux <> 'E' THEN -- referencia 2
							LET cObservs = TRIM('Paso 101');
							--Referencia 2
							LET cClienteReferencia2bcpl		= TRIM(NVL(cCteRefbcplAux,''));
							LET iclientereferencia2			= NVL(ictereferenciaAux,0);
							LET cnombreunoreferencia2		= TRIM(NVL(cnombre1refAux,''));
							LET cnombredosreferencia2		= TRIM(NVL(cnombre2refAux,''));
							LET capellidopaternoreferencia2	= TRIM(NVL(capellpatrefAux,''));
							LET capellidomaternoreferencia2	= TRIM(NVL(capellmatrefAux,''));
							LET csexoreferencia2			= TRIM(NVL(csexorefAux,''));     
							LET sciudadreferencia2			= NVL(sciudadrefAux,0);
							LET scoloniareferencia2			= NVL(scoloniarefAux,0);
							LET icallereferencia2			= NVL(icallerefAux,0);
							LET icasareferencia2			= NVL(icasarefAux,0);
							LET cdeptoointeriorreferencia2	= TRIM(NVL(cdeptoointrefAux,''));
							LET crumboreferencia2			= TRIM(NVL(crumborefAux,''));
							LET ccomplementoreferencia2		= TRIM(NVL(ccomplementorefAux,''));
							LET centrecallesreferencia2		= TRIM(NVL(centrecallesrefAux,'')); 
							LET sflaguhr2					= NVL(sflaguhrAux,0);
							LET suhrmanzana2				= NVL(suhrmanzanaAux,0);
							LET suhrotros2					= NVL(suhrotrosAux,0);
							LET suhrandador2				= NVL(suhrandadorAux,0);
							LET suhretapa2					= NVL(suhretapaAux,0);
							LET suhrlote2					= NVL(suhrloteAux,0);
							LET suhredificio2				= NVL(suhredificioAux,0);
							LET suhrentrada2				= NVL(suhrentradaAux,0);  
							LET ctelefonoreferencia2		= NVL(ctelrefaux,'0');
							LET ctelefonocelularreferencia2	= NVL(ctelcelrefAux,'0');
							LET cclavereferencia2			= TRIM(cclaverefAux);
						END IF;
					END FOREACH;
					
					--SCORING PROSPECTO
					LET cObservs = TRIM('Paso 102');
					FOREACH WITH HOLD
						SELECT ele.rango_minimo,det.grupo,ele.descripcion
						INTO  iElemento,iGrupo,cDescripElemento
						FROM bdiprospectos:"informix".pr_detalle_scoring det
						INNER JOIN bdiprospectos:"informix".pr_scoring_element ele 
								ON ( ele.elemento = det.elemento AND det.grupo = ele.grupo 
								AND det.empresa = ele.empresa AND det.tpo_persona = ele.tpo_persona) 
						WHERE num_solicitud = vNumCteProspecto
						AND det.grupo  IN(11,39,6,8,21) 
						AND det.seccion = 2 
						AND det.tpo_persona = "01" 
						AND activa = 1  
						
						LET cObservs = TRIM('Paso 103');
						IF iGrupo = 11 THEN
							LET cObservs = TRIM('Paso 104');
							LET vnumerodependientes = iElemento;
						ELIF iGrupo = 39 THEN
							LET cObservs = TRIM('Paso 105');
							LET vpersonastrabajan = iElemento;
						ELIF iGrupo = 6 THEN
							LET cObservs = TRIM('Paso 106');
							LET cfechadesdecuandovive = YEAR(dFechaAlta)-iElemento; 
							LET cfechadesdecuandovive = TRIM(cfechadesdecuandovive)||"/01/01";
						ELIF iGrupo = 8 THEN
							LET cObservs = TRIM('Paso 107');
							IF iElemento = -1 THEN
								LET cObservs = TRIM('Paso 108');
								SELECT elemento INTO iElemento FROM bdiprospectos:"informix".pr_detalle_scoring 
								WHERE grupo = 7 AND seccion = 2 AND tpo_persona = "01" AND num_solicitud = vNumCteProspecto;
								
								IF iElemento = 15 THEN --Estudiante
									LET cObservs = TRIM('Paso 109');
									LET cfechaantiguedtrab = dFechaAlta;
								ELIF iElemento = 12 THEN --Ama de Casa
									LET cObservs = TRIM('Paso 110');
									LET cfechaantiguedtrab =  dFechaAlta;
									LET vlugartrabajo = ""; 
								ELIF iElemento = 6 OR iElemento = 17 THEN --Desempleado, Jubilado o Pensionado
									LET cObservs = TRIM('Paso 111');
									LET cfechaantiguedtrab = dFechaAlta;
								END IF;
							ELSE
								LET cObservs = TRIM('Paso 112');
								LET cfechaantiguedtrab = YEAR(vfechaaltacliente)-iElemento;	
								LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||"/01/01";
							END IF;
						ELIF iGrupo = 21 THEN
							LET cObservs = TRIM('Paso 113');
							IF TRIM(cDescripElemento) = "No EstudiÃ³" THEN
								LET cescolaridad = "1";
							ELIF TRIM(cDescripElemento) = "Primaria" THEN
								LET  cescolaridad = "2";
							ELIF TRIM(cDescripElemento) = "Secundaria" THEN
								LET cescolaridad = "3";
							ELIF TRIM(cDescripElemento) = "Carrera TÃ©cnica" THEN
								LET cescolaridad = "4";
							ELIF TRIM(cDescripElemento) = "Preparatoria" THEN
								LET cescolaridad = "5";
							ELIF TRIM(cDescripElemento) = "Licenciatura o Superior" THEN
								LET cescolaridad = "6"; 
							END IF;
						END IF;
					END FOREACH;
					
					LET cObservs = TRIM('Paso 114');
					
					LET vfolio = '';
					LET vfolioanterior = '0';
					LET cClaveOSAnt = '';
					LET cClaveOS = '';
					--SE OBTIENEN LOS FOLIOS ACTUAL Y ANTERIOR
					FOREACH
						SELECT FIRST 2 folio, clave, fechasolicitud
						INTO vfolioanterior, cClaveOSAnt, dFechaSupervisar
						FROM TABLE ( MULTISET(
						SELECT folio, clave, fechasolicitud
						FROM bdisolic:"informix".ss_osclientesupervisar  
						WHERE num_solicitud= vNumCteProspecto 
						AND empresa= pempresa
						))ORDER BY folio DESC
						
						--SI ES EL PRIMERO 
						IF vfolio = '' THEN
							IF dFechaSupervisar <= vfechaaltacliente THEN 
								LET vfolio = NVL(vfolioanterior,'0');
								LET cClaveOS = cClaveOSAnt;
							END IF;
						ELSE
							IF NVL(vfolioanterior,'') = '' THEN
								LET vfolioanterior = '0';
								LET cClaveOSAnt = '';
							END IF;
						END IF;
					END FOREACH;
					
					LET cObservs = TRIM('Paso 115');
					--SE OBTIENE LA RESPUESTA DE BURO
					SELECT NVL(COUNT(*), 0) 
					INTO iContConsBuro 
					FROM bdisolic:"informix".ss_solicitudes_sic 
					WHERE numcte = vnumcte 
					AND num_solicitud = vNumCteProspecto;
					
					LET cObservs = TRIM('Paso 116');
					
					SELECT CASE WHEN "informix".sp_EsNumerico(ingreso_mensual) = "V" THEN ingreso_mensual::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(cap_sistematica_abono) = "V" THEN cap_sistematica_abono::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(tope_abonocoppel) = "V" THEN tope_abonocoppel::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(lineacreditotope) = "V" THEN lineacreditotope::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(capmaxima_abono) = "V" THEN capmaxima_abono::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(capreal_abono) = "V" THEN capreal_abono::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(lineacredito_real) = "V" THEN lineacredito_real::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(compromisossic) = "V" THEN compromisossic::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(flaglineacreditoesp) = "V" THEN flaglineacreditoesp::INTEGER ELSE 0 END,
					limitecredito, situacion_especial, 
					CASE WHEN "informix".sp_EsNumerico(causa_sitesp) = "V" THEN causa_sitesp::INTEGER ELSE 0 END,
					puntos_parcn, par_celulares, par_altoriesgo, par_prestamos,
					id_situaciones,TRIM(puntualidad_ref1),TRIM(puntualidad_ref2),flagtestigoparametricocn::SMALLINT, 
					flag_altadirecta_asupervisar::SMALLINT,puntos_var_param,
					puntos_var_sic,score_domicilio,nuevo_puntajefinal,
					status_solicitud,canal_origenpros
					
					INTO iMontoIngMensual, iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal,
					iCompromisosSic, iFlagLineaCredEsp,vlimitecredito,csituacionespecial, vcausasituacionespecial,iPuntuacion,sParCelulares,
					sParAltoRiesgo, sParPrestamo,
					iId_Situaciones,cPuntualidad_ref1,cPuntualidad_ref2,sFlagTestParametrico,sFlag_altadirecta_asupervisar,iPuntos_Var_Param,
					iPuntos_Var_SIC,iScore_domicilio,sNuevo_puntajefinal,
					cStatusParam,cCanal_origensol
					
					FROM bdiprospectos:"informix".pr_nuevo_parametrico
					WHERE ROWID = (SELECT MAX(ROWID) FROM bdiprospectos:"informix".pr_nuevo_parametrico
					WHERE empresa = pempresa AND num_solicitud = vNumCteProspecto); --DSB-06/04/2018
					
					LET cObservs = TRIM('Paso 117');
					SELECT ingreso_mensual, periosidad 
					INTO iIngreso, ctiposueldo 
					FROM bdiprospectos:"informix".pr_ingresos 
					WHERE empresa = pempresa 
					AND numcte_pros = vNumCteProspecto
					AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdiprospectos:"informix".pr_ingresos WHERE numcte_pros = vNumCteProspecto AND tipo_ingreso = "T");
					IF iIngreso > iTopeMax THEN
						LET iIngreso=iTopeMax;
					END IF;
					
					LET cObservs = TRIM('Paso 118');
					LET vingresomensual = ((((NVL(iIngreso::DECIMAL(18,2),0))+(iValor/2)))/iValor)::INTEGER;
					
					IF vingresomensual < 1 THEN
						LET vingresomensual = 1;
					END IF;
				END IF;
				
				LET cObservs = TRIM('Paso 119');
				IF cClave="M" THEN
					IF cClaveOS = 'R' AND cMotivobcpl = '' AND cStatus = 'RT' THEN 
						LET cMotivobcpl = 'ROS';
					END IF;
					
					IF NVL(csituacionespecial,'') = '' AND NVL(vcausasituacionespecial,0)=0 THEN
						LET cObservs = TRIM('Paso 120');
						IF cClaveOS = 'A' AND sFlagCapCobranza <> 0 THEN
							LET cObservs = TRIM('Paso 121');
							LET csituacionespecial="G";
							LET vcausasituacionespecial=57;
						ELIF cStatus = 'OA' OR cStatus = /*'R'*/'RT' THEN --DSB20180621
							FOREACH
								SELECT FIRST 1 situacionespecialrespuesta,causasituacionespecialrespuesta, fecha_respuesta
								INTO csituacionespecial, vcausasituacionespecial, dFechaTemp
								FROM TABLE ( MULTISET(
								SELECT situacionespecialrespuesta,causasituacionespecialrespuesta , fecha_respuesta
								FROM bdiprospectos:"informix".pr_solicitud_os 
								WHERE num_solicitud = vNumCteProspecto AND status = DECODE(cStatus, /*'R'*/'RT','R','OA','D') --DSB20180621
								AND fecha_respuesta <= pFechaAct))ORDER BY fecha_respuesta DESC
							END FOREACH;
						END IF;
						
						IF cStatusbcpl = 'H' AND NVL(csituacionespecial,'') = ''  THEN
							LET cObservs = TRIM('Paso 122');
							LET csituacionespecial = csituacionespecial_aut;
							LET vcausasituacionespecial = icausasituacionespecial_aut;
						END IF;
						
					ELIF sFlagCapCobranza = 0 AND cstatusparam <> 'R' THEN 
						LET cObservs = TRIM('Paso 123');
						LET csituacionespecial="";
						LET vcausasituacionespecial=0;
					END IF;
					
					IF NVL(cClaveOS,'') = '' THEN
						LET cClaveOS = 'R';
					END IF;
					
					LET cObservs = TRIM('Paso 124');
					SELECT user_insert 
					INTO vefectuo 
					FROM bdisolic:"informix".ss_solicitudes 
					WHERE num_solicitud= vNumCteProspecto; 
					
				ELIF NVL(cClave,'') ='' THEN
					LET cObservs = TRIM('Paso 125');
					
					IF  cStatusParam = 'A' THEN
						IF sFlagCapCobranza = 0 THEN
							LET csituacionespecial ='';
							LET vcausasituacionespecial = 0;
						ELSE
							LET csituacionespecial='G';
							LET vcausasituacionespecial=57;
						END IF;
					END IF;
					
					LET vefectuo=vefectuoMOD;
				END IF;
				
				LET cObservs = TRIM('Paso 126');

--                 --RGH
--                IF LENGTH(CAST(iNumerocasa AS CHAR(10)))>= 10 THEN
--                    LET iNumerocasa = 0;
--                END IF;
--                
--                IF LENGTH(CAST(inumerocasatrabajo AS CHAR(10)))>= 10 THEN
--                    LET inumerocasatrabajo = 0;
--                END IF;
--                --RGH				
				
				LET cTrama = '';
				LET cTrama = inumSecuencia||"|"||NVL(cClave,'')||"|"||scaja||"|"||carea
				||"|"||vcliente_ref::INTEGER||"|"||TRIM(NVL(vnombre1, ''))||"|"||TRIM(NVL(vnombre2, ''))||"|"||TRIM(NVL(vapell_paterno, ''))||"|"||TRIM(NVL(vapell_materno, ''))
				||"|"||TRIM(NVL(vcurp, ''))||"|"||TRIM(NVL(vclaveelector, ''))||"|"||TRIM(NVL(vclaveidentificacion, ''))||"|"||TRIM(videntificacion)
				||"|"||NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)||"|"||TRIM(NVL(vdeptointerior, ''))||"|"||NVL(crumbo, '')||"|"||TRIM(NVL(vcomplemento,''))
				||"|"||TRIM(NVL(ventrecalles, ''))||"|"||NVL(cUnidadHabit, 0)||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)
				||"|"||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0)
				||"|"||NVL(vtelefono::INT8, 0)||"|"||NVL(vtelefonocelular::INT8, 0)||"|"||TRIM(NVL(cHabitaen, ''))||"|"||TRIM(vniptitular)||"|"||TRIM(vnipadicional)||"|"||TRIM(NVL(csexo, ''))
				||"|"||TRIM(NVL(cestadocivil, ''))||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadesdecuandovive, '1900/01/01'))||"|"||NVL(vpersonasvivenendomicilio, 0)
				||"|"||TRIM(NVL(cescolaridad, ''))||"|"||TRIM(NVL(ctiposueldo, ''))||"|"||NVL(vnumerodependientes, 0)||"|"||NVL(vpersonastrabajan, 0)||"|"||NVL(vlimitecredito, 0)
				||"|"||NVL(vingresomensual, 0)
				||"|"||TRIM(NVL(csituacionespecial, ''))||"|"||NVL(vcausasituacionespecial, 0)||"|"||TRIM(cclaveautrechaza)||"|"||TRIM(NVL(caceptadosupervisadorechazado, ''))||"|"||TRIM(cclientenuevo)
				||"|"||TRIM(NVL(ccreditojoven, ''))
				||"|"||TRIM(NVL(vlugartrabajo, ''))||"|"||NVL(sciudadtrabajo,0)||"|"||NVL(scoloniatrabajo, 0)||"|"||NVL(icalletrabajo, 0)
				||"|"||NVL(inumerocasatrabajo, 0)||"|"||TRIM(NVL(cdeptoointeriortrabajo, ''))||"|"||TRIM(NVL(crumbotrabajo, ''))||"|"||TRIM(NVL(ccomplementotrabajo, ''))
				||"|"||TRIM(NVL(centrecallesTrabajo, ''))||"|"||NVL(sflaguht, 0)||"|"||NVL(suhtmanzana, 0)||"|"||NVL(suhtotros, 0)||"|"||NVL(suhtandador, 0)
				||"|"||NVL(suhtetapa, 0)||"|"||NVL(suhtlote, 0)||"|"||NVL(suhtedificio, 0)||"|"||NVL(suhtentrada, 0)||"|"||NVL(vtelefonotrabajo::INT8, 0)||"|"||NVL(vextensiontrabajo, 0)
				||"|"||TRIM(NVL(cpuesto,''))||"|"||NVL(vopcionpuesto, 0)||"|"||TRIM(NVL(cfechaantiguedtrab, '1900/01/01'))
				||"|"||NVL(iclienteconyuge,0)||"|"||TRIM(NVL(cnombreunoconyuge, ''))||"|"||TRIM(NVL(cnombredosconyuge, ''))||"|"||TRIM(NVL(capellidopaternoconyuge, ''))
				||"|"||TRIM(NVL(capellidomaternoconyuge, ''))||"|"||TRIM(NVL(cSexoConyuge, ''))||"|"||TRIM(NVL(clugartrabajoconyuge, ''))||"|"||NVL(sciudadconyuge, 0)
				||"|"||NVL(scoloniaconyuge, 0)||"|"||NVL(icalletrabajoconyuge, 0)||"|"||NVL(icasatrabajoconyuge, 0)||"|"||TRIM(NVL(cdeptoointeriorconyuge, ''))
				||"|"||TRIM(NVL(crumbotrabajoconyuge, ''))||"|"||TRIM(NVL(ccomplementoconyuge, ''))||"|"||TRIM(NVL(centrecallesconyuge,''))||"|"||NVL(sflaguhy, 0)||"|"||NVL(suhymanzana, 0)
				||"|"||NVL(suhyotros, 0)||"|"||NVL(suhyandador, 0)||"|"||NVL(suhyetapa, 0)||"|"||NVL(suhylote, 0)||"|"||NVL(suhyedificio, 0)||"|"||NVL(suhyentrada, 0)||"|"||REPLACE(NVL(TRIM(ctelefonotrabajoconyuge),''),'','0')
				||"|"||REPLACE(NVL(TRIM(ctelefonocelularconyuge),''),'','0')||"|"||NVL(cclaveconyugefamilia,'')
				||"|"||NVL(iclientereferencia,0)||"|"||TRIM(NVL(cnombreunoreferencia, ''))||"|"||TRIM(NVL(cnombredosreferencia, ''))||"|"||TRIM(NVL(capellidopaternoreferencia, ''))
				||"|"||TRIM(NVL(capellidomaternoreferencia, ''))||"|"||TRIM(NVL(cSexoReferencia, ''))||"|"||NVL(sciudadreferencia,0)||"|"||NVL(scoloniareferencia,0)||"|"||NVL(icallereferencia,0)
				||"|"||NVL(icasareferencia,0)||"|"||NVL(cdeptoointeriorreferencia,'')||"|"||NVL(crumboreferencia,'')||"|"||NVL(ccomplementoreferencia,'')||"|"||NVL(centrecallesreferencia1,'')
				||"|"||NVL(sflaguhr,0)||"|"||NVL(suhrmanzana,0)||"|"||NVL(suhrotros,0)||"|"||NVL(suhrandador,0)||"|"||NVL(suhretapa,0)||"|"||NVL(suhrlote,0)||"|"||NVL(suhredificio,0)||"|"||NVL(suhrentrada,0)
				||"|"||REPLACE(NVL(TRIM(ctelefonoreferencia),''),'','0')||"|"||REPLACE(NVL(TRIM(ctelefonocelularreferencia),''),'','0')||"|"||NVL(cclavereferencia1,'')
				||"|"||NVL(iclientereferencia2,0)||"|"||TRIM(NVL(cnombreunoreferencia2, ''))||"|"||TRIM(NVL(cnombredosreferencia2, ''))||"|"||TRIM(NVL(capellidopaternoreferencia2, ''))
				||"|"||TRIM(NVL(capellidomaternoreferencia2, ''))||"|"||TRIM(NVL(cSexoReferencia2, ''))||"|"||NVL(sciudadreferencia2,0)||"|"||NVL(scoloniareferencia2,0)||"|"||NVL(icallereferencia2,0)
				||"|"||NVL(icasareferencia2,0)||"|"||NVL(cdeptoointeriorreferencia2,'')||"|"||NVL(crumboreferencia2,'')||"|"||NVL(ccomplementoreferencia2,'')||"|"||NVL(centrecallesreferencia2,'')
				||"|"||NVL(sflaguhr2,0)||"|"||NVL(suhrmanzana2,0)||"|"||NVL(suhrotros2,0)||"|"||NVL(suhrandador2,0)||"|"||NVL(suhretapa2,0)||"|"||NVL(suhrlote2,0)||"|"||NVL(suhredificio2,0)||"|"||NVL(suhrentrada2,0)
				||"|"||REPLACE(NVL(TRIM(ctelefonoreferencia2),''),'','0')||"|"||REPLACE(NVL(TRIM(ctelefonocelularreferencia2),''),'','0')||"|"||NVL(cclavereferencia2,'')
				||"|"||vreferencia2||"|"||vreferencia3||"|"||TRIM(cmarcadatosin)||"|"||vtiporeposicion||"|"||vreposicion||"|"||TRIM(cflagentregotarjeta)
				||"|"||NVL(vefectuoMOD, 0)||"|"||NVL(cFolioSucursal,'0')||"|"||NVL(vfolio::INTEGER,0)||"|"||NVL(dFechaAlta, '1900/01/01')||"|"||TRIM(cflagnoreconocehuella)
				||"|"||vfoliotienda||"|"||TRIM(NVL(vrfc, ''))||"|"||TRIM(vcveburo)||"|"||TRIM(vfolioaut)||"|"||TRIM(vfolioconsulta)||"|"||TRIM(vfolioconcir)||"|"||vnegocio||"|"||vsubnegocio||"|"||NVL(vefectuo,0)
				||"|"||TRIM(ctipo)||"|"||TRIM(NVL(cfechamovto, '1900/01/01'))||"|"||NVL(cNumSolRef, '')||"|"||TRIM(NVL(vnumcte, ''))||"|"||NVL(vtiendafolioanterior,0)
				||"|"||NVL(vfolioanterior,0)||"|"||NVL(vclaveproducto,0)||"|"||vflagactualizacion||"|"||vSistsegsocial||"|"||vTiposueldoext||"|"||vNumempleados||"|"||vSubopcionpuesto||"|"||vPuestoext
				||"|"||vOpcionpuestoext||"|"||vNumempleadosext||"|"||vSubopcionpuestoext||"|"||TRIM(cTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(cFolioSucursal, '0'))
				||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||NVL(cMarcaHit,'')||"|"||NVL(cEmpleadoSubCob::INTEGER,0)||"|"||NVL(sFlagCapHuella,0)
				||"|"||TRIM(cMarcarConsultado)||"|"||NVL(sFlagTestParametrico,0)||"|"||NVL(sFlagCapCobranza,0)||"|"||NVL(REPLACE(cEmpleadoGteAutori,'sistema','0'),0)||"|"||NVL(cFlagConsBuro,'')
				||"|"||NVL(cBuroPilotoTestig,'')||"|"||TRIM(NVL(cNacionalidad,''))||"|"||TRIM(NVL(cNoFm3,''))||"|"||TRIM(NVL(cEmail,''))||"|"||TRIM(NVL(cApellCasada,''))||"|"||TRIM(NVL(cPais,''))
				||"|"||TRIM(NVL(cNoIMSS,''))||"|"||TRIM(NVL(cEstado,''))||"|"||TRIM(NVL(cDelegMunicip,''))||"|"||TRIM(NVL(cNumInterior,''))||"|"||NVL(sPropNegocio,0)
				||"|"||NVL(sParCelulares,0)||"|"||NVL(sParAltoRiesgo,0)||"|"||NVL(sParPrestamo,0)||"|"||NVL(cModeloCel,'')||"|"||NVL(cFechaConsBuro, '1900/01/01')||"|"||NVL(iMontoIngMensual,0)
				||"|"||NVL(iCapSistematicabono,0)||"|"||NVL(iTopeAbonoCoppel,0)||"|"||NVL(iLineaCrediTope,0)||"|"||NVL(iCapMaximaAbono,0)||"|"||NVL(iCapRealAbono,0)||"|"||NVL(iLineaCredReal,0)
				||"|"||NVL(iCompromisosSic,0)||"|"||NVL(iFlagLineaCredEsp,0)||"|"||TRIM(NVL(cClienteConyugebcpl,'0'))||"|"||TRIM(NVL(cClienteReferencia1bcpl,'0'))
				||"|"||TRIM(NVL(cClienteReferencia2bcpl,'0'))||"|"||TRIM(NVL(cFolioSucursal, '0'))||"|"||NVL(pFechaAct,DATE(1))||"|"||TRIM(NVL(cStatus,''))||"|"||TRIM(NVL(cMotivobcpl,''))
				||"|"||TRIM(NVL(cFlagProspecto,''))||"|"||TRIM(NVL(vNumCteProspecto,''))||"|"||NVL(iParAltoRiesgoNvo,0)||"|"||NVL(iPagoUlt12meses,0)
				||"|"||NVL(iId_Situaciones,0)||"|"||TRIM(NVL(cPuntualidad_ref1,''))||"|"||TRIM(NVL(cPuntualidad_ref2,''))||"|"||NVL(sFlag_altadirecta_asupervisar,0)
				||"|"||NVL(iPuntos_Var_Param,0)||"|"||NVL(iPuntos_Var_SIC,0)||"|"||NVL(iScore_domicilio,0)||"|"||NVL(sNuevo_puntajefinal,0);
				
				LET cObservs = TRIM('Paso 127');
				
				INSERT INTO bdinteg:"informix".si_tramasbatch(secuencia,clave, caja, area,
				--DATOS DEL CLIENTE PROSPECTO
				cliente, nombre1, nombre2, apellidopaterno, apellidomaterno, curp, claveelector, claveidentificacion, identificacion, 
				--DIRECCION
				ciudad, colonia, calle, casa,deptoointerior, rumbo, complemento, entrecalles, flaguhc, uhcmanzana, uhcotros, uhcandador, uhcetapa, uhclote, uhcedificio, 
				uhcentrada, telefono,telefonocelular,
				--Datos Generales del cte
				casapropia, niptitular, nipadicional, sexo, estadocivil, fechanacimiento, fechadesdecuandoviveahi, personasvivenendomicilio, escolaridad,
				tiposueldo, numerodependientes, personastrabajan, limitecredito, ingresomensual,
				--SITUACION DEL CLIENTE
				situacionespecial, causasituacionespecial, claveautrechaza,aceptadosupervisadorechazado, clientenuevo, creditojoven, 
				--OCUPACION Y DIRECCION DEL TRABAJO DEL CTE
				lugartrabajo, ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo, deptoointeriortrabajo,
				rumbotrabajo, complementotrabajo, entrecallestrabajo, flaguht, uhtmanzana, uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio, uhtentrada, 
				telefonotrabajo, extensiontrabajo, puesto, opcionpuesto, fechaantiguedadtrabajo, 
				--DATOS DEL CONYUGE
				clienteconyuge, nombreunoconyuge, nombredosconyuge, apellidopaternoconyuge, apellidomaternoconyuge, sexoconyuge, 
				--DIRECCION DEL CONYUGE
				lugartrabajoconyuge, ciudadconyuge, coloniaconyuge, calletrabajoconyuge, casatrabajoconyuge, deptoointeriorconyuge, rumbotrabajoconyuge, 
				complementoconyuge, entrecallesconyuge, flaguhy, uhymanzana, uhyotros, uhyandador, uhyetapa, uhylote, uhyedificio, uhyentrada, telefonotrabajoconyuge,
				telefonocelularconyuge, claveconyugefamilia,
				--Datos Referencia 1 y direccion
				clientereferencia, nombreunoreferencia, nombredosreferencia, apellidopaternoreferencia, apellidomaternoreferencia, sexoreferencia, ciudadreferencia, 
				coloniareferencia, callereferencia, casareferencia, deptoointeriorreferencia, rumboreferencia, complementoreferencia, entrecallesreferencia1, flaguhr,
				uhrmanzana, uhrotros, uhrandador, uhretapa, uhrlote, uhredificio, uhrentrada, telefonoreferencia, telefonocelularreferencia, clavereferencia1,
				--Datos Referencia 2 y direccion
				clientereferencia2, nombreunoreferencia2, nombredosreferencia2, apellidopaternoreferencia2, apellidomaternoreferencia2, sexoreferencia2, ciudadreferencia2,
				coloniareferencia2, callereferencia2, casareferencia2, deptoointeriorreferencia2, rumboreferencia2, complementoreferencia2, entrecallesreferencia2,
				flaguhr2, uhrmanzana2, uhrotros2, uhrandador2, uhretapa2, uhrlote2, uhredificio2, uhrentrada2, telefonoreferencia2, telefonocelularreferencia2,
				clavereferencia2,
				--OTROS
				referencia2,referencia3,marcadatosin, tiporeposicion, reposicion, flagentregotarjeta, efectuo, tiendafolio, folio, fechaaltacliente, 
				flagnoreconocehuella, foliotienda, rfc,cveburo, folioaut, folioconsulta, folioconcir, negocio, subnegocio, empleadoautorizo, tipo, fechamovto,
				numerosolicituddecredito, clientebancoppel,tiendafolioanterior, folioanterior, claveproducto, flagactualizacion, sistsegsocial, tiposueldoext, 
				numempleados, subopcionpuesto, puestoext, opcionpuestoext, numempleadosext, subopcionpuestoext, tipoorigen, tipoproducto, tienda, fecha, puntosparcn,
				marcahit, empleadosupcob, flagcapturohuella, marcarconsultado, flagtestigoparametricocn, flagcapturacobranza, empleadogteautorizo, flagconsultaburo,
				buropilototestigo, nacionalidad, no_fm3, email, apellido_cas, pais, no_imss, estado, municipio, numinterior, propietarionegocio, parcelulares,
				paraltoriesgo, parprestamo, modelocelulares, fechaconsultaburo, montoingresomensual, capsistematicaabono, topeabonocoppel, lineadecreditope, 
				capmaximaabono, caprealabono, lineadecreditoreal, compromisossic, flaglineacreditoesp, clienteconyugebcpl, clientereferenciabcpl, 
				clientereferencia2bcpl,sucursal,fecha_insert,statusbcpl,motivobcpl,flagprospecto,numcteprospecto,paraltoriesgonvo,pagoult12meses,
				id_situaciones,puntualidad_ref1,puntualidad_ref2,flag_altadirecta_asupervisar,puntos_var_param,puntos_var_sic,score_domicilio,nuevo_puntajefinal,canal_origensol)
				
				VALUES(inumSecuencia,NVL(cClave,''), scaja,carea,
				--DATOS DEL CLIENTE PROSPECTO
				vcliente_ref::INTEGER,TRIM(NVL(vnombre1, '')), TRIM(NVL(vnombre2, '')), TRIM(NVL(vapell_paterno, '')),TRIM(NVL(vapell_materno, '')),
				TRIM(NVL(vcurp, '')),TRIM(NVL(vclaveelector, '')),TRIM(NVL(vclaveidentificacion, '')), TRIM(videntificacion), 
				--DIRECCION DEL CTE
				NVL(vciudad, 0),NVL(vcolonia, 0),NVL(vcalle, 0), NVL(iNumerocasa, 0),TRIM(NVL(vdeptointerior, '')),NVL(crumbo, ''), TRIM(NVL(vcomplemento,'')),
				TRIM(NVL(ventrecalles, '')), NVL(cUnidadHabit, 0),NVL(vuhcmanzana, 0),NVL(vuhcotros, 0), NVL(vuhcandador, 0), NVL(vuhcetapa, 0), NVL(vuhclote, 0), 
				NVL(vuhcedificio, 0), NVL(vuhcentrada, 0),
				--OTROS DATOS
				NVL(vtelefono::INT8, 0),NVL(vtelefonocelular::INT8, 0), TRIM(NVL(cHabitaen, '')),TRIM(vniptitular), TRIM(vnipadicional), TRIM(NVL(csexo, '')),
				TRIM(NVL(cestadocivil, '')), TRIM(NVL(cfechanac, '1900/01/01')),TRIM(NVL(cfechadesdecuandovive, '1900/01/01')), NVL(vpersonasvivenendomicilio, 0), 
				TRIM(NVL(cescolaridad, '')), TRIM(NVL(ctiposueldo, '')),NVL(vnumerodependientes, 0), NVL(vpersonastrabajan, 0), NVL(vlimitecredito, 0),
				NVL(vingresomensual, 0), 
				--Situacion del cte
				TRIM(NVL(csituacionespecial, '')),NVL(vcausasituacionespecial, 0), TRIM(cclaveautrechaza),
				TRIM(NVL(cStatusbcpl,'')), --PRUEBA
				TRIM(cclientenuevo),
				TRIM(NVL(ccreditojoven, '')),
			   ---TRABAJO
				TRIM(NVL(vlugartrabajo, '')),NVL(sciudadtrabajo,0), NVL(scoloniatrabajo, 0),NVL(icalletrabajo, 0),
				NVL(inumerocasatrabajo, 0),TRIM(NVL(cdeptoointeriortrabajo, '')), TRIM(NVL(crumbotrabajo, '')), TRIM(NVL(ccomplementotrabajo, '')),
				TRIM(NVL(centrecallesTrabajo, '')), NVL(sflaguht, 0), NVL(suhtmanzana, 0), NVL(suhtotros, 0), NVL(suhtandador, 0), 
				NVL(suhtetapa, 0), NVL(suhtlote, 0), NVL(suhtedificio, 0),NVL(suhtentrada, 0),NVL(vtelefonotrabajo::INT8, 0), NVL(vextensiontrabajo, 0), 
				TRIM(NVL(cpuesto,'')),NVL(vopcionpuesto, 0), TRIM(NVL(cfechaantiguedtrab, '1900/01/01')),
				--CONYUGE
				NVL(iclienteconyuge,0), TRIM(NVL(cnombreunoconyuge, '')),TRIM(NVL(cnombredosconyuge, '')),TRIM(NVL(capellidopaternoconyuge, '')), 
				TRIM(NVL(capellidomaternoconyuge, '')),TRIM(NVL(cSexoConyuge, '')),TRIM(NVL(clugartrabajoconyuge, '')), NVL(sciudadconyuge, 0), 
				NVL(scoloniaconyuge, 0), NVL(icalletrabajoconyuge, 0),NVL(icasatrabajoconyuge, 0),TRIM(NVL(cdeptoointeriorconyuge, '')), 
				TRIM(NVL(crumbotrabajoconyuge, '')), TRIM(NVL(ccomplementoconyuge, '')),TRIM(NVL(centrecallesconyuge,'')),NVL(sflaguhy, 0),NVL(suhymanzana, 0),
				NVL(suhyotros, 0), NVL(suhyandador, 0), NVL(suhyetapa, 0), NVL(suhylote, 0),NVL(suhyedificio, 0),NVL(suhyentrada, 0),REPLACE(NVL(TRIM(ctelefonotrabajoconyuge),''),'','0'),
				REPLACE(NVL(TRIM(ctelefonocelularconyuge),''),'','0'),NVL(cclaveconyugefamilia,''),
				--REFERENCIA1
				NVL(iclientereferencia,0),TRIM(NVL(cnombreunoreferencia, '')),TRIM(NVL(cnombredosreferencia, '')), TRIM(NVL(capellidopaternoreferencia, '')),
				TRIM(NVL(capellidomaternoreferencia, '')),TRIM(NVL(cSexoReferencia, '')),NVL(sciudadreferencia,0),NVL(scoloniareferencia,0) ,NVL(icallereferencia,0),
				NVL(icasareferencia,0),NVL(cdeptoointeriorreferencia,''),NVL(crumboreferencia,''), NVL(ccomplementoreferencia,''),NVL(centrecallesreferencia1,''),
				NVL(sflaguhr,0),NVL(suhrmanzana,0),NVL(suhrotros,0),NVL(suhrandador,0),NVL(suhretapa,0),NVL(suhrlote,0),NVL(suhredificio,0),NVL(suhrentrada,0),
				REPLACE(NVL(TRIM(ctelefonoreferencia),''),'','0'),REPLACE(NVL(TRIM(ctelefonocelularreferencia),''),'','0'),NVL(cclavereferencia1,''),
				--Referencia 2
				NVL(iclientereferencia2,0), TRIM(NVL(cnombreunoreferencia2, '')),TRIM(NVL(cnombredosreferencia2, '')),TRIM(NVL(capellidopaternoreferencia2, '')),
				TRIM(NVL(capellidomaternoreferencia2, '')),TRIM(NVL(cSexoReferencia2, '')),NVL(sciudadreferencia2,0),NVL(scoloniareferencia2,0),NVL(icallereferencia2,0),
				NVL(icasareferencia2,0),NVL(cdeptoointeriorreferencia2,''),NVL(crumboreferencia2,''),NVL(ccomplementoreferencia2,''),NVL(centrecallesreferencia2,''),
				NVL(sflaguhr2,0),NVL(suhrmanzana2,0),NVL(suhrotros2,0),NVL(suhrandador2,0),NVL(suhretapa2,0),NVL(suhrlote2,0),NVL(suhredificio2,0),NVL(suhrentrada2,0),
				REPLACE(NVL(TRIM(ctelefonoreferencia2),''),'','0'),REPLACE(NVL(TRIM(ctelefonocelularreferencia2),''),'','0'),NVL(cclavereferencia2,''),
				--OTROS
				vreferencia2, vreferencia3, TRIM(cmarcadatosin),vtiporeposicion,vreposicion,TRIM(cflagentregotarjeta),
				NVL(vefectuoMOD, 0),NVL(cFolioSucursal,'0'),NVL(vfolio::INTEGER,0),NVL(dFechaAlta, '1900/01/01'),TRIM(cflagnoreconocehuella),
				vfoliotienda,TRIM(NVL(vrfc, '')),TRIM(vcveburo),TRIM(vfolioaut),TRIM(vfolioconsulta),TRIM(vfolioconcir),vnegocio,vsubnegocio,NVL(vefectuo,0),
				TRIM(ctipo),TRIM(NVL(cfechamovto, '1900/01/01')), NVL(cNumSolRef, ''),TRIM(NVL(vnumcte, '')),NVL(vtiendafolioanterior,0),
				NVL(vfolioanterior,0),NVL(vclaveproducto,0), vflagactualizacion, vSistsegsocial,vTiposueldoext,vNumempleados,vSubopcionpuesto, vPuestoext,
				vOpcionpuestoext,vNumempleadosext,vSubopcionpuestoext, TRIM(cTipoOrigen),TRIM(vTipoProducto),TRIM(NVL(cFolioSucursal, '0')),
				TRIM(NVL(cFecha_hoy, '1900/01/01')),NVL(iPuntuacion,0),NVL(cMarcaHit,''),NVL(cEmpleadoSubCob::INTEGER,0),NVL(sFlagCapHuella,0),
				TRIM(cMarcarConsultado),NVL(sFlagTestParametrico,0),NVL(sFlagCapCobranza,0),NVL(REPLACE(cEmpleadoGteAutori,'sistema','0'),0),NVL(cFlagConsBuro,''),
				NVL(cBuroPilotoTestig,''),TRIM(NVL(cNacionalidad,'')),TRIM(NVL(cNoFm3,'')),TRIM(NVL(cEmail,'')),TRIM(NVL(cApellCasada,'')),TRIM(NVL(cPais,'')),
				TRIM(NVL(cNoIMSS,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cDelegMunicip,'')),TRIM(NVL(cNumInterior,'')),NVL(sPropNegocio,0), 
				NVL(sParCelulares,0), NVL(sParAltoRiesgo,0), NVL(sParPrestamo,0),NVL(cModeloCel,''),NVL(cFechaConsBuro, '1900/01/01'),NVL(iMontoIngMensual,0),
				NVL(iCapSistematicabono,0),NVL(iTopeAbonoCoppel,0),NVL(iLineaCrediTope,0),NVL(iCapMaximaAbono,0),NVL(iCapRealAbono,0),NVL(iLineaCredReal,0),
				NVL(iCompromisosSic,0),NVL(iFlagLineaCredEsp,0),TRIM(NVL(cClienteConyugebcpl,'0')),TRIM(NVL(cClienteReferencia1bcpl,'0')),
				TRIM(NVL(cClienteReferencia2bcpl,'0')),TRIM(NVL(cFolioSucursal, '0')), NVL(pFechaAct,DATE(1)),
				TRIM(NVL(cStatus,'')),TRIM(NVL(cMotivobcpl,'')),
				TRIM(NVL(cFlagProspecto,'')),TRIM(NVL(vNumCteProspecto,'')),NVL(iParAltoRiesgoNvo,0),NVL(iPagoUlt12meses,0),
				NVL(iId_Situaciones,0),TRIM(NVL(cPuntualidad_ref1,'')),TRIM(NVL(cPuntualidad_ref2,'')),NVL(sFlag_altadirecta_asupervisar,0),
				NVL(iPuntos_Var_Param,0),NVL(iPuntos_Var_SIC,0),NVL(iScore_domicilio,0),NVL(sNuevo_puntajefinal,0),TRIM(NVL(cCanal_origensol,'')));
				
				LET iCuentaRegistros = iCuentaRegistros +1 ;
				
			END FOREACH;
			
		END IF
		IF inumSecuencia > 0 THEN
			UPDATE bdinteg:"informix".si_archivosecuenciamax SET secuencia_max=inumSecuencia;
		END IF;
	ELSE
		LET vCodRetorno = '000001';
	END IF;
	IF iCuentaRegistros >= 1 THEN
		LET vCodRetorno = '000000';
	ELIF iCuentaRegistros = 0 THEN
		LET vCodRetorno = '000005';
	END IF;
RETURN vCodRetorno;
END
END PROCEDURE
DOCUMENT
'Descripcion: Batch clientes prospecto reingenieria',
'Autor: Victor Hugo NuÃ±ez',
'BD: bdinteg',
'Fecha: 01/03/2018',
'Folio: 1875',
'Nombre: INC_BATCH',
'Sustento: Correo Re: Envio archivo de pruebas batch con informacion del 11-01-2018 del dia 22/03/2018',
'Solicita: Juan Olivares',
'fecha: 06/04/2018',
'Descripcion: Se realiza modificacion para tener en consideracion doble registros en la tabla pr_nuevo_parametrico, ademas',
'se realiza limpieza de variable cNumSolRef para evitar una valor incorrecto en solicitudes subsecuentes',
'se realiza modificacion para no incluir numero de solicitud de credito esto a peticion de Martha Gabriela Angulo',
'....... DSB20180621.- Se modifica para cambiar los R por RT y que valide la fecha de nacimiento menor a 1900 y enviar 1900/01/01 ',
'Solicita:Juan Olivares',
'Autor: 94379114 Victor Hugo NuÃ±ez',
'...... 95526749 Jesus Horacio Lopez Gonzalez DSB20180621',
'ModificÃ³: Irma Ureta',
'DescripciÃ³n: Se anexa la validaciÃ³n sobre el tipo de origen, si la solicitud se realizÃ³ desde el dispositivo movil se mandarÃ¡ tipoorigen = M',
'			  si la solicitud se realizÃ³ desde sucursal se mandarÃ¡ tipoorigen = G o si la solicitud fue levantada en cobranza y cliente prospecto',
'			  se mandarÃ¡ tipoorigen = N todas aquellas que comiensen con P y darlas de alta en la tabla bdinteg:si_tramasbatch con es tipoorigen.',
'Fecha: 07/05/2018',
'BD: bdinteg',
'----------------------------------------------------------------------------------------------------------------',
'Modificacion: 99802102 - Yonaiker Morillo',
'Folio: 747',
'RQM: RQM 09 541-2 CrÃÂ©dito Motos Coppel en Alta ÃÂnica ',
'Descripcion: Se contempla el campo "cCanal_origensol", para insertar en la tabla si_tramasbatch, tomando el dato del campo canal_origenpros de la tabla "pr_nuevo_parametrico"',
'Fecha: 28/05/2021',
'Solicito: Abraham Narvaez',
'BD: BDINTEG',
'-------------------------------------------------------------------------------------------------------------------------------------------------',
'Folio: 1977',
'Autor: Jesus Ivan Garcia Guicho',
'Fecha: 05/07/2021',
'Descripcion: Se agrega retorno para en caso de existir algun error al generar el reproceso, lo retorne y no lo marque como exitoso',
'Etiqueta:--DSB20210705',
'BD: bdinteg',
'----------------------------------------------------------------------------------------------------------------',
'Descripcion: Se modifica campo numeroextcalle, que cuando este traiga un valor que sobre pase los â32767 y 32767, remplazar por el valor default que en este caso serÃ¡ 0',
'Autor: 95992243 - Trinidad Hernandez',
'BD: bdinteg',																																								 
'Fecha: 10/08/2021',
'Solicita: Abraham Narvaez',
'---------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_ctehuella(pempresa CHAR(3),
                                         psucursal CHAR(4),
                                         pejecutivo CHAR(8),
                                         pautoriza CHAR(8),
                                         pfecha_alta date,
                                         pfuncion CHAR(1),
                                         pnumcte CHAR(20),
                                         pmapad char(942),
                                         pmapai char(942)) 
										 
  RETURNING CHAR(5),smallint;

define vcodret CHAR(5);
define vsigsec smallint;
define vexiste CHAR(1);
define vtp_persona CHAR(2);
define vsqlerr INTEGER;
define visamerr INTEGER;
define vesfisica CHAR(1);



LET vcodret = "000";
LET vsigsec = 0;
LET vexiste = 0;
LET vtp_persona = "";

--SET DEBUG FILE TO '/informix/logspssql/sp_ctehuellaconcambio.sql';
--TRACE ON;


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vsigsec;
   END IF;
END EXCEPTION;

--- Verifica recepcion correcta de datos
IF pnumcte IS NULL OR Trim(pnumcte) = ""
   OR pmapad IS NULL OR pmapad = ""
   OR pmapai IS NULL OR pmapai = "" then
   LET vcodret = "110";
   RETURN vcodret,vsigsec;
END IF;

SELECT tpo_persona INTO vtp_persona
FROM   si_cliente
WHERE  numcte = pnumcte;

SELECT es_fisica INTO vesfisica
   FROM si_tipper
   WHERE tpo_persona = vtp_persona;
IF UPPER(vesfisica) != "S" THEN
   LET vcodret = "120";
   RETURN vcodret,vsigsec;
END IF;

SELECT 1 INTO vexiste
   FROM si_sucursales
   WHERE sucursal=psucursal;
IF vexiste IS NULL THEN
   LET vcodret="111";
   RETURN vcodret,vsigsec;
END IF;

SELECT 1 INTO vexiste
   FROM si_ejecut
   WHERE ejecutivo=pejecutivo;
IF vexiste IS NULL THEN
   LET vcodret="112";
   RETURN vcodret,vsigsec;
END IF;
if Trim(pautoriza) <> "" then
   SELECT 1 INTO vexiste
     FROM si_ejecut
    WHERE ejecutivo=pautoriza;
   IF vexiste IS NULL THEN
      LET vcodret="112";
      RETURN vcodret,vsigsec;
   END IF;
END IF;

IF pfuncion != "A" and pfuncion != "C" THEN
   let vcodret = "130";
   RETURN vcodret,vsigsec;
END IF
-- ****************** Actualizacion de Parametros *****************
IF pfuncion="A" THEN
   SELECT 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte
      AND estado ="A";
   IF vexiste = "1" THEN
      let vcodret = "131";
      RETURN vcodret,vsigsec;
   END IF

   /*SELECT 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte; CIB20220428: se comentÃ³ el select debido a que retornaba dos datos*/
	
	SELECT LIMIT 1 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte; -- CIB20220428: se agregÃ³ LIMIT 1 esto para limitar el retorno de datos a solo 1  */

   IF vexiste = "1" THEN
      select max(secuencia) + 1 INTO vsigsec
      from   si_cte_huella
      where  numcte = pnumcte;
      /*RETURN vcodret,vsigsec; CIB20220428: se comentÃ³ el return debido a que terminaba el proceso sin agregar los datos en la tabla*/
   ELSE
      LET vsigsec = 1;
   END IF;
   BEGIN
      INSERT INTO si_cte_huella
        (numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,fech_ult_camb)
      VALUES
         (pnumcte,vsigsec,"A",pmapad,pmapai,pejecutivo,psucursal,pfecha_alta,CURRENT);
   END;
   RETURN vcodret,vsigsec;
ELIF pfuncion = "C" then
     BEGIN
        UPDATE si_cte_huella SET estado = "I",usuario_camb = pautoriza,
               fecha_camb = pfecha_alta,
	       fech_ult_camb = CURRENT
        WHERE  numcte = pnumcte and estado = "A";
        -- Agrega la Nueva Huella
        select max(secuencia) + 1 INTO vsigsec
          from   si_cte_huella
         where  numcte = pnumcte;
         IF vsigsec is null  THEN
            let vsigsec = 1;
         END IF
         INSERT INTO si_cte_huella
           (numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,fech_ult_camb)
         VALUES
           (pnumcte,vsigsec,"A",pmapad,pmapai,pejecutivo,psucursal,pfecha_alta,CURRENT);
     END;
     RETURN vcodret,vsigsec;
END IF;

RETURN vcodret,vsigsec;
END;
END PROCEDURE
DOCUMENT
"Alta, de Huella de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Mario Escobar",
"FECHA : 04/Enero/2007",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"-----------------------------------------------------",
"Autor: 90231110 - Rolando JosuÃ© UrÃ­as GarcÃ­a",
"Fecha: 28/04/2022 - CIB20220428",
"ModificaciÃ³n: Se modificÃ³ el SELECT 1 INTO vexiste FROM si_cte_huella WHERE numcte = pnumcte ya que cuando se ejecutaba retornaba el error 284",
"..............debido a que se retornaban 2 datos y en la validaciÃ³n de IF vexiste = '1' THEN select max(secuencia) + 1 INTO vsigsec from   si_cte_huella",
"..............where numcte = pnumcte RETURN vcodret,vsigsec ELSE LET vsigsec = 1; END IF; a pesar que ya estaba retornando bien, el return terminaba la ejecuciÃ³n",
"..............sin haber agregado los datos a la tabla por lo que se comentÃ³ el RETURN vcodret,vsigsec",
"Sustento: Se definio por correo electronico el dÃ­a miercoles 27 de abril por Jaime Gonzales Prado",
"Solicita: Jaime Gonzales Prado",
"Folio: 1997",
"Proyecto: INC-SPCTEHUELLA284YNOINSERTA",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_obtener_cel_rep_act(pNumCte CHAR(20),
												   pNumCel CHAR(10)
												  )
RETURNING
	CHAR(5) 	AS codRet,
	CHAR(50) 	AS totRegRep;
	

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_obtener_cel_rep_act"
Folio.........: 854 - Validacion de numeros de celular en 90 dias.
Autor.........: 90127902 - Epigmenio Martinez Pedraza
Fecha.........: 27/04/2022
Solicita......: Bancoppel
BD............: bdinteg
*/


DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iValidaDiasTu    INTEGER;

LEt sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iValidaDiasTu    = 0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/LIP/sp_obtener_cel_rep_act.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
	
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel='A' AND verificado='F' AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));
																																									   
		
	    

RETURN sCodRet, iCantRep;

END
END PROCEDURE;