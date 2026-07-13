CREATE PROCEDURE "informix".sp_genera_archivosbatch_prospecto_pba1(pempresa CHAR(3), pFechaAct DATE) 
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
	--DEFINE vHora DATETIME HOUR TO FRACTION(3);
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

    DEFINE cObservs char(80);
    DEFINE cTrama LVARCHAR (32000);

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

	SET ISOLATION TO COMMITTED READ LAST COMMITTED;
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
				END IF 
			--RETURN vCodRetorno WITH RESUME;
		END IF;
	END EXCEPTION  WITH RESUME;
	--SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO "/pisa/pisabanco/sp_genera_archivosbatch_prospecto.out";
	--TRACE ON;
    
	IF pFechaAct <> MDY(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		SELECT fecha_hoy INTO vFecha_Hoy FROM "informix".si_fechas WHERE empresa = '001';
		IF vFecha_Hoy = MDY(1,1,1900) OR vFecha_Hoy IS NULL THEN
				LET vCodRetorno = '000002';
				--LET iCuentaRegistros = 2;
			ELSE	
				UPDATE STATISTICS MEDIUM FOR TABLE bdinteg:"informix".si_archivoscopdiario;
				 --Se revisa que la tabla diario no haya quedado con datos de anteriores ejecuciones por causa de algun error en ejecución.
				/* IF EXISTS (SELECT 1 FROM "informix".si_archivoscopdiario  WHERE  fecha_insert != pFechaAct) THEN 
					DELETE FROM "informix".si_archivoscopdiario  WHERE  fecha_insert != pFechaAct;
				 END IF;	*/	
				SELECT secuencia_max INTO inumSecuencia FROM bdinteg:"informix".si_archivosecuenciamax where empresa = '001' and secuencia_max = secuencia_max;
				--LET inumSecuencia = inumSecuencia + 1;
				--SE OBTIENE VALOR DE SALARIOS MINIMOS
				SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(valor) = 'V' THEN valor::INTEGER ELSE 0 END 
				INTO iValor FROM bdisolic:"informix".ss_param WHERE secuencia = 363;
				--SE OBTIENE VALOR DE TOPE MAXIMO DE INGRESO MENSUAL --2013-12-06 RQI 27 096 AAME										
				SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(valor) = 'V' THEN valor::INTEGER ELSE 0 END 
				INTO iTopeMax FROM bdisolic:"informix".ss_param WHERE secuencia = 373;

                LET cObservs = TRIM('Paso 85');
				FOREACH WITH HOLD
					SELECT DISTINCT sss.numcte_pros, sss.numcte, ssa.fecha_entrada, sss.sucursal, sss.fecha_insert,ssa.status_solicitud,
					ssa.ejecutivo_auto,sss.user_insert, ssa.fecha_hora, sss.emp_cob_alta,
					sss.nombre1, sss.nombre2, sss.apell_paterno, sss.apell_materno, sss.rfc, CASE WHEN bdinteg: "informix".sp_EsNumerico(string2) = 'V' THEN string2:: INTEGER ELSE 0 END
					INTO vNumCteProspecto, vnumcte, vfechaaltacliente, cFolioSucursal, dFechaAlta,cStatus,cEmpleadoGteAutori,vefectuoMOD, vFechaHora,cEmpleadoSubCob,
					vnombre1,vnombre2, vapell_paterno, vapell_materno, vrfc, vpersonasvivenendomicilio
					FROM bdiprospectos:"informix".pr_autorizacion ssa,
					bdiprospectos:"informix".pr_cliente sss
					WHERE sss.empresa = ssa.empresa
					AND sss.numcte_pros = ssa.num_solicitud			
					AND sss.sucursal=sss.sucursal
					And sss.tipo_cliente="3"
					AND sss.fecha_insert=sss.fecha_insert
					AND sss.numcte_pros = sss.numcte_pros
					AND ssa.fecha_entrada =  pFechaAct	
					
					--and sss.numcte_pros = 'P000609895'
					--DSB 31/03/2017 se contempla la fecha del status como fecha del movimiento
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
					LET inumSecuencia = inumSecuencia + 1;
					LET iSecuencia=0;	
					LET bMovimiento = "F";
					--LET cEmpleadoSubCob=0;
					LET cEstado='';
					LET sParCelulares=0;
					LET sParAltoRiesgo=0;
					LET sParPrestamo=0;
					LET cStatusbcpl='';
					LET cMotivobcpl='';
					LET cpuesto = '0';
					
					SELECT MAX(fecha_hora) INTO vFechaHoraMax from bdiprospectos:"informix".pr_autorizacion where num_solicitud=vNumCteProspecto AND fecha_entrada=pFechaAct;
					--ALTA SOLICITUD OS
					IF NOT EXISTS(SELECT * FROM bdiprospectos:"informix".pr_autorizacion where status_solicitud="OA" and fecha_hora < (SELECT MAX(fecha_hora) FROM bdiprospectos:"informix".pr_autorizacion WHERE status_solicitud="OS" AND num_solicitud=vNumCteProspecto)AND num_solicitud=vNumCteProspecto) AND (cStatus= "OS" AND vFechaHoraMax=vFechaHora)   THEN
						LET cClave = "";
						LET bMovimiento = "T";
					ELIF cStatus ="CE" AND vFechaHoraMax=vFechaHora THEN --status CE
							LET cClave = "";
							LET bMovimiento = "T";
					ELIF EXISTS(SELECT * FROM bdiprospectos:"informix".pr_nuevo_parametrico WHERE status_solicitud="R" AND num_solicitud=vNumCteProspecto ) AND(cStatus ="RT" AND vFechaHoraMax=vFechaHora) THEN --status RT
							LET cClave = "";
							LET bMovimiento = "T";
					ELIF cStatus ="EC"  AND vFechaHoraMax=vFechaHora THEN --status EC O EE
							LET cClave = "";
							LET bMovimiento = "T";
					ELIF (cStatus ="AN" OR cStatus ="PC") AND vFechaHoraMax=vFechaHora THEN --status AN O PC
							LET cClave = "";
							LET cpuesto = "";
							LET ctipo = "";
							LET bMovimiento = "T";
					END IF;
                    LET cObservs = TRIM('Paso 87');
					 --MODIFICACION SOLICITUD
					SELECT  FIRST 1 status_solicitud, fecha_hora 
					INTO cStatusPenul, vFechaHoraP 
					FROM bdiprospectos:"informix".pr_autorizacion 
					WHERE num_solicitud =vNumCteProspecto  AND fecha_hora =(SELECT MAX( fecha_hora )FROM bdiprospectos:"informix".pr_autorizacion 
																			WHERE num_solicitud =vNumCteProspecto AND fecha_hora < vFechaHora );

                    LET cObservs = TRIM('Paso 88');
					SELECT  FIRST 1 status_solicitud 
					INTO cStatusAntp 
					FROM bdiprospectos:"informix".pr_autorizacion 
					WHERE num_solicitud =vNumCteProspecto 
					AND   fecha_hora =(SELECT MAX( fecha_hora )FROM bdiprospectos:"informix".pr_autorizacion 
									   WHERE num_solicitud =vNumCteProspecto AND fecha_hora < vFechaHoraP );
					
                    LET cObservs = TRIM('Paso 89');
					--STATUS AT,RT,OA
					IF EXISTS(SELECT * FROM bdiprospectos:pr_solicitud_os WHERE num_solicitud=vNumCteProspecto AND status in('A','R','D')) AND 
					( cStatus IN ("AT","RT","OA") AND vfechaaltacliente=pFechaAct ) AND cStatusPenul="OS" THEN
						LET cClave = "M";
						LET bMovimiento = "T";
						--Validar status= OA para envir  situacion especial y causa
					END IF;
                    LET cObservs = TRIM('Paso 90');
					--STATUS CN
					IF EXISTS(SELECT * FROM bdiprospectos:"informix".pr_autorizacion WHERE causa_solicitud in ('CEC','CEE','COS', 'COA','CCE')AND num_solicitud = 	vNumCteProspecto AND fecha_entrada=pFechaAct) AND ( cStatus ="CN" AND vfechaaltacliente=pFechaAct) THEN
								LET cClave = "M";
								LET bMovimiento = "T";
					END IF;
                    LET cObservs = TRIM('Paso 91');
					--STATUS CN Y CAUSA CV
					IF EXISTS(SELECT * FROM bdiprospectos:"informix".pr_autorizacion WHERE causa_solicitud in ('CV')AND num_solicitud = vNumCteProspecto AND fecha_entrada=pFechaAct) AND ( cStatus ="CN" AND vfechaaltacliente=pFechaAct) THEN
							LET cClave = "M";
							LET bMovimiento = "T";
					END IF;
                    LET cObservs = TRIM('Paso 92');
					--STATUS OS(RELANZADA)
					IF (SELECT COUNT(num_solicitud) FROM bdiprospectos:pr_solicitud_os WHERE status='D' and num_solicitud=vNumCteProspecto)>1 AND cStatusPenul="EE" AND cStatusAntp="OA" AND(cStatus ="OS" AND vfechaaltacliente=pFechaAct) AND
					(SELECT COUNT(num_solicitud)  FROM bdiprospectos:pr_solicitud_os WHERE status='D' and num_solicitud=vNumCteProspecto AND fecha_solicitud=pFechaAct) >=1 	THEN
						LET cClave = "M";
						LET bMovimiento = "T";
					END IF;
                    LET cObservs = TRIM('Paso 93');
					--STATUS RT
					IF EXISTS(select * from bdiprospectos:"informix".pr_autorizacion where status_solicitud='RT' and causa_solicitud='RSC' and situacion_especial='P' and causa_situacion='27' and  num_solicitud=vNumCteProspecto ) and cStatus="RT" AND vfechaaltacliente=pFechaAct  then
--                    IF EXISTS(select * from bdiprospectos:"informix".pr_autorizacion where status_solicitud='RT' and  num_solicitud=vNumCteProspecto ) and cStatus="RT" AND vfechaaltacliente=pFechaAct  then
						LET cClave = "M";
						LET bMovimiento = "T";
					ELIF bMovimiento ="F" THEN
						CONTINUE FOREACH;
					END IF;
					
					IF vNumCteProspecto <> '' OR vnumcte <> '' THEN 					
					--SE OBTIENEN DATOS PERSONALES DEL CLIENTE				
					
                        LET cObservs = TRIM('Paso 94');	
						--DSB Se modifica para obtener los datos en foreach principal
						--SELECT nombre1, nombre2, apell_paterno, apell_materno, numcte_pros, rfc, fecha_insert, 
						--CASE WHEN "informix".sp_EsNumerico(string2)= "V" THEN string2::INTEGER ELSE 0 END,user_insert ,apell_casada
						--INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vNumCteProspecto, vrfc,  vfechamovto, vpersonasvivenendomicilio,vefectuoAP,cApellCasada
						--FROM bdiprospectos:"informix".pr_cliente cte
						--WHERE empresa = pempresa AND numcte_pros = vNumCteProspecto;

                        LET cObservs = TRIM('Paso 95');
						SELECT estado_civil,  habita_en, sexo, fecha_nac, nacionalidad, curp, codidentifi,numidentifi,no_fm3,no_imss
						INTO cestadocivil, cHabitaen, csexo, vfechanacimiento,cNacionalidad,vcurp,vclaveidentificacion,videntificacion,cNoFm3,cnoimss
						FROM bdiprospectos:"informix".pr_ctepf
						WHERE numcte_pros = vNumCteProspecto;

                        LET cObservs = TRIM('Paso 96');
						SELECT NVL(correo_elec,"") INTO cEmail 
						FROM bdiprospectos:"informix".pr_correos 
						WHERE numcte_pros = vNumCteProspecto 
						AND status_correo = "A";	
						
						IF cEmail IS NULL THEN 
							LET cEmail="";
						END IF;
						--CONSULTA LA INFORMACION DE LA DIRECCION DEL CLIENTE					
						FOREACH WITH HOLD
								SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerociudad) = "V" THEN dir.numerociudad::INTEGER ELSE 0 END,
								CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocolonia) = "V" THEN dir.numerocolonia::INTEGER ELSE 0 END, 
								CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocalle) = "V" THEN dir.numerocalle::INTEGER ELSE 0 END,
								CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numeroextcalle) = "V" THEN dir.numeroextcalle::INT8 ELSE 1 END,
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
								LEFT OUTER JOIN bdiprospectos:"informix".pr_telefonos tel1 ON ( tel1.numcte_pros = dir.numcte_pros AND tel1.tipo_tel = 1 AND tel1.status_tel="A")
								LEFT OUTER JOIN bdiprospectos:"informix".pr_telefonos tel2 ON ( tel2.numcte_pros = dir.numcte_pros AND tel2.tipo_tel = 2 AND tel2.status_tel="A")								
								LEFT OUTER JOIN bdiprospectos:"informix".pr_telefonos tel3 ON ( tel3.numcte_pros = dir.numcte_pros AND tel3.tipo_tel = 3 )
								WHERE dir.numcte_pros = vNumCteProspecto AND dir.tipo_dir IN ("1" ,"2")
								AND dir.secuencia = (SELECT MAX(dir2.secuencia) FROM bdiprospectos:"informix".pr_direcciones_actual dir2 
													WHERE dir2.numcte_pros = vNumCteProspecto AND dir2.tipo_dir = dir.tipo_dir)
								ORDER BY dir.tipo_dir DESC			
								

								LET cObservs = TRIM('Paso 97');
								--SE OBTIENE DEL ESTADO
								--DSB Bernardo Báez se modifica para que se guarde el numero de estado en vez de las siglas
								--SELECT siglas INTO cEstado FROM bdinteg:"informix".si_estados WHERE estado=sestadoaux;
								LET cEstado = sestadoaux;
								
								LET cObservs = TRIM('Paso 98');
								-- SE OBTIENE EL NOMBRE DE LA CIUDAD Y COLONIA
								SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel,numerocoloniacoppel
								INTO sciudadaux, scoloniaaux
								FROM bdinteg:"informix".si_catzonas
								WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
                                LET cObservs = TRIM('Paso 99');
								--SI NO EXISTEN LA CIUDAD Y COLONIA, SE TOMARA DE LA SUCURSAL
								SELECT ciudad INTO vciudadbanco FROM "informix".si_sucursales WHERE sucursal = cFolioSucursal;
								IF NVL(sciudadaux, 0) = 0 THEN
									SELECT FIRST 1 numerociudadcoppel INTO sciudadaux FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
									IF NVL(sciudadaux, 0) = 0 THEN						
											SELECT FIRST 1 numerociudadcoppel INTO sciudadaux FROM bdinteg:"informix".si_catzonas where numerociudadcoppel <> 0;
									END IF;
								END IF;
								IF NVL(scoloniaaux, 0) = 0 THEN											
									SELECT FIRST 1 numerocoloniacoppel INTO scoloniaaux FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
									IF NVL(scoloniaaux, 0) = 0 THEN
										SELECT FIRST 1 numerocoloniacoppel INTO scoloniaaux FROM bdinteg:"informix".si_catzonas where numerocoloniacoppel <> 0;
									END IF;
								END IF;		

								IF vTipo_Dir ="1" THEN
                                    LET cObservs = TRIM('Paso 100');
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
                                    LET cObservs = TRIM('Paso 101');
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

						LET cObservs = TRIM('Paso 102');
						SELECT ing.nombre_empresa, 
						CASE WHEN "informix".sp_EsNumerico(ing.claveopcionpuesto) = "V" THEN ing.claveopcionpuesto::SMALLINT ELSE 0 END,
						CASE WHEN "informix".sp_EsNumerico(ing.clavesubopcionpuesto) = "V" THEN ing.clavesubopcionpuesto::SMALLINT ELSE 0 END, --ing.ingreso_mensual
						puesto
						INTO vlugartrabajo, vopcionpuesto, vSubopcionpuesto,cPuesto
						FROM bdiprospectos:"informix".pr_ingresos ing
						WHERE ing.numcte_pros = vNumCteProspecto
						AND ing.sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdiprospectos:"informix".pr_ingresos WHERE numcte_pros = vNumCteProspecto AND tipo_ingreso = "T");
						
                        LET cObservs = TRIM('Paso 103');
						LET vopcionpuesto = NVL(vopcionpuesto,0);
						LET vSubopcionpuesto=NVL(vSubopcionpuesto,0);
						
					--SE CAMBIA EL FORMATO DE LA FECHA NACIMIENTO, EL ALTA DEL CLIENTE Y OBTENCION DE FECHA DE MOVIMIENTOS
						--SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
						LET cfechanac = YEAR(vfechanacimiento)||"/"||LPAD(MONTH(vfechanacimiento),2,0)||"/"||LPAD(DAY(vfechanacimiento),2,0);
						LET cfechaaltacte = YEAR(dFechaAlta)||"/"||LPAD(MONTH(dFechaAlta),2,0)||"/"||LPAD(DAY(dFechaAlta),2,0);
						
						--LET cfechamovto = CAST(CURRENT::DATETIME YEAR TO SECOND AS CHAR(19));
						--LET cfechamovto= SUBSTR (cfechamovto,1,4) || '/' || SUBSTR (cfechamovto,6,2) || '/' || SUBSTR (cfechamovto,9,2) || ' ' || SUBSTR (cfechamovto,12,8);
						
						LET cFecha_hoy = CAST(CURRENT::DATETIME YEAR TO SECOND AS CHAR(19));
						LET cFecha_hoy= SUBSTR (cFecha_hoy,1,4) || '/' || SUBSTR (cFecha_hoy,6,2) || '/' || SUBSTR (cFecha_hoy,9,2) || ' ' || SUBSTR (cFecha_hoy,12,8);
										
													
						LET cClienteConyugebcpl = '';
						LET cClienteReferencia1bcpl = '';
						LET cClienteReferencia2bcpl = '';				
                        LET cObservs = TRIM('Paso 104');
						--SE OBTIENE NUMERO DE SOLICITUD DE BANCO PARA OBTENER SUS REFERENCIAS EN CASO DE QUE A LA SOLICITUD COPPEL NO SE LE HAYAN HEREDADO POR HABER SIDO RECHAZADA ANTES.
						SELECT num_solicitud
						 INTO cNumSolRef
						FROM bdisolic:"informix".ss_solicitudes
						WHERE empresa = pempresa
						AND numcte  =vnumcte
						AND fecha_insert = dFechaAlta
						AND num_producto = '6001'
						AND status_solicitud NOT IN ('AN','PC')
						AND ROWID IN (SELECT MAX(ROWID)
										FROM bdisolic:"informix".ss_solicitudes
										WHERE empresa = pempresa
										AND numcte  = vnumcte
										AND fecha_insert = dFechaAlta
										AND num_producto = '6001'
										AND status_solicitud NOT IN ('AN','PC'));
						  IF NVL(cNumSolRef,'') = '' THEN
								--LET cNumSolRef=vNumCteProspecto;
								LET cNumSolRef = '';
						  END IF;	
						  
						--LET cclaveconyugefamilia = '';
						LET icontador2= 0;
							
                        LET cObservs = TRIM('Paso 105');
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
							WHERE cts.empresa = pempresa --Parametro de entrada
							AND cts.numcte_pros = TRIM(vNumCteProspecto) -- numero de cliente prospecto Variable
							AND dirf.numcte_pros = cts.numcte_pros
							and dirf.secuencia = cts.secuencia
							ORDER BY cts.secuencia DESC
							
                            LET cObservs = TRIM('Paso 106');

							LET icontador2= icontador2 + 1;
							
							IF 	(cestadocivil = 'C' OR cestadocivil = 'U') AND cclaverefAux = 'E' THEN
                                LET cObservs = TRIM('Paso 107');
								-- pon los datos del conyuge
								--Referencia Conyuge							
								LET cClienteConyugebcpl     = TRIM(NVL(cCteRefbcplAux,''));
								LET iclienteconyuge         = NVL(ictereferenciaAux,0);
								LET cnombreunoconyuge       = TRIM(NVL(cnombre1refAux,''));
								LET cnombredosconyuge       = TRIM(NVL(cnombre2refAux,''));
								LET capellidopaternoconyuge = TRIM(NVL(capellpatrefAux,''));
								LET capellidomaternoconyuge = TRIM(NVL(capellmatrefAux,''));
								LET csexoconyuge            = TRIM(NVL(csexorefAux,''));     
								LET clugartrabajoconyuge    = ''; -- pendiente 
								LET sciudadconyuge          = NVL(sciudadrefAux,0);
								LET scoloniaconyuge         = NVL(scoloniarefAux,0);
								LET icalletrabajoconyuge    = NVL(icallerefAux,0);
								LET icasatrabajoconyuge     = DECODE(NVL(icasarefAux,0),0,1,icasarefAux);
								LET cdeptoointeriorconyuge  = TRIM(NVL(cdeptoointrefAux,''));
								LET crumbotrabajoconyuge    = TRIM(NVL(crumborefAux,''));     
								LET ccomplementoconyuge     = TRIM(NVL(ccomplementorefAux,''));
								LET centrecallesconyuge     = TRIM(NVL(centrecallesrefAux,''));     
								LET sflaguhy                = NVL(sflaguhrAux,0);
								LET suhymanzana             = NVL(suhrmanzanaAux,0);
								LET suhyotros               = NVL(suhrotrosAux,0);
								LET suhyandador             = NVL(suhrandadorAux,0);
								LET suhyetapa               = NVL(suhretapaAux,0);
								LET suhylote                = NVL(suhrloteAux,0);
								LET suhyedificio            = NVL(suhredificioAux,0);
								LET suhyentrada             = NVL(suhrentradaAux,0);  
								LET ctelefonotrabajoconyuge = ctelefonotrabajoconyuge;
								LET ctelefonocelularconyuge = TRIM(NVL(ctelcelrefAux,'0'));
								LET cclaveconyugefamilia    = TRIM(cclaverefAux);
																
							ELif icontador2 = 2 AND cclaverefAux <> 'E' THEN -- referencia 1							
                                LET cObservs = TRIM('Paso 108');
								--Referencia uno cuando no es conyuge		       
								LET cClienteReferencia1bcpl      = TRIM(NVL(cCteRefbcplAux,''));
								LET iclientereferencia           = NVL(ictereferenciaAux,0);
								LET cnombreunoreferencia         = TRIM(NVL(cnombre1refAux,''));
								LET cnombredosreferencia         = TRIM(NVL(cnombre2refAux,''));
								LET capellidopaternoreferencia   = TRIM(NVL(capellpatrefAux,''));
								LET capellidomaternoreferencia   = TRIM(NVL(capellmatrefAux,''));
								LET csexoreferencia              = TRIM(NVL(csexorefAux,''));     
								LET sciudadreferencia            = NVL(sciudadrefAux,0);
								LET scoloniareferencia           = NVL(scoloniarefAux,0);
								LET icallereferencia             = NVL(icallerefAux,0);
								LET icasareferencia              = NVL(icasarefAux,0);
								LET cdeptoointeriorreferencia    = TRIM(NVL(cdeptoointrefAux,''));
								LET crumboreferencia             = TRIM(NVL(crumborefAux,''));     
								LET ccomplementoreferencia       = TRIM(NVL(ccomplementorefAux,''));
								LET centrecallesreferencia1      = TRIM(NVL(centrecallesrefAux,'')); 
								LET sflaguhr                     = NVL(sflaguhrAux,0);
								LET suhrmanzana                  = NVL(suhrmanzanaAux,0);
								LET suhrotros                    = NVL(suhrotrosAux,0);
								LET suhrandador                  = NVL(suhrandadorAux,0);
								LET suhretapa                    = NVL(suhretapaAux,0);
								LET suhrlote                     = NVL(suhrloteAux,0);
								LET suhredificio                 = NVL(suhredificioAux,0);
								LET suhrentrada                  = NVL(suhrentradaAux,0);  
								LET ctelefonoreferencia          = NVL(ctelrefaux,'0');
								LET ctelefonocelularreferencia   = NVL(ctelcelrefAux,'0');
								LET cclavereferencia1            = TRIM(cclaverefAux);					
	                                           
							ELif icontador2 = 1 AND cclaverefAux <> 'E' THEN -- referencia 2
                                LET cObservs = TRIM('Paso 109');
								--Referencia 2                            
								LET cClienteReferencia2bcpl        	       = TRIM(NVL(cCteRefbcplAux,''));
								LET iclientereferencia2          	       = NVL(ictereferenciaAux,0);
								LET cnombreunoreferencia2        	       = TRIM(NVL(cnombre1refAux,''));
								LET cnombredosreferencia2        	       = TRIM(NVL(cnombre2refAux,''));
								LET capellidopaternoreferencia2  	       = TRIM(NVL(capellpatrefAux,''));
								LET capellidomaternoreferencia2  	       = TRIM(NVL(capellmatrefAux,''));
								LET csexoreferencia2             	       = TRIM(NVL(csexorefAux,''));     
								LET sciudadreferencia2           	       = NVL(sciudadrefAux,0);
								LET scoloniareferencia2          	       = NVL(scoloniarefAux,0);
								LET icallereferencia2            	       = NVL(icallerefAux,0);
								LET icasareferencia2             	       = NVL(icasarefAux,0);
								LET cdeptoointeriorreferencia2   	       = TRIM(NVL(cdeptoointrefAux,''));
								LET crumboreferencia2            	       = TRIM(NVL(crumborefAux,''));     
								LET ccomplementoreferencia2      	       = TRIM(NVL(ccomplementorefAux,''));
								LET centrecallesreferencia2      	       = TRIM(NVL(centrecallesrefAux,'')); 
								LET sflaguhr2                    	       = NVL(sflaguhrAux,0);
								LET suhrmanzana2                 	       = NVL(suhrmanzanaAux,0);
								LET suhrotros2                   	       = NVL(suhrotrosAux,0);
								LET suhrandador2                 	       = NVL(suhrandadorAux,0);
								LET suhretapa2                   	       = NVL(suhretapaAux,0);
								LET suhrlote2                    	       = NVL(suhrloteAux,0);
								LET suhredificio2                	       = NVL(suhredificioAux,0);
								LET suhrentrada2                 	       = NVL(suhrentradaAux,0);  
								LET ctelefonoreferencia2         	       = NVL(ctelrefaux,'0');
								LET ctelefonocelularreferencia2  	       = NVL(ctelcelrefAux,'0');
								LET cclavereferencia2            	       = TRIM(cclaverefAux);					
							
							END IF;
							
						END FOREACH;	

                        LET cObservs = TRIM('Paso 110');
						FOREACH WITH HOLD
							SELECT ele.rango_minimo,det.grupo,ele.descripcion
							INTO  iElemento,iGrupo,cDescripElemento
							FROM bdiprospectos:"informix".pr_detalle_scoring det
							INNER JOIN bdiprospectos:"informix".pr_scoring_element ele 
									ON ( ele.elemento = det.elemento AND det.grupo = ele.grupo and det.empresa = ele.empresa and det.tpo_persona = ele.tpo_persona) 
							WHERE num_solicitud = vNumCteProspecto
							AND det.grupo  IN(11,39,6,8,21) 
							AND det.seccion = 2 
							AND det.tpo_persona = "01" 
                            AND activa = 1  
						
                            LET cObservs = TRIM('Paso 111');

							IF iGrupo = 11 THEN
                                LET cObservs = TRIM('Paso 112');
								LET vnumerodependientes = iElemento;
							ELIF iGrupo = 39 THEN
                                LET cObservs = TRIM('Paso 113');
								LET vpersonastrabajan = iElemento;
							ELIF iGrupo = 6 THEN
                                LET cObservs = TRIM('Paso 114');
								LET cfechadesdecuandovive = YEAR(dFechaAlta)-iElemento; 
								LET cfechadesdecuandovive = TRIM(cfechadesdecuandovive)||"/01/01";
							ELIF iGrupo = 8 THEN
                                LET cObservs = TRIM('Paso 115');
								IF iElemento = -1 THEN
                                    LET cObservs = TRIM('Paso 116');
									SELECT elemento INTO iElemento FROM bdiprospectos:"informix".pr_detalle_scoring 
									WHERE grupo = 7 AND seccion = 2 AND tpo_persona = "01" AND num_solicitud = vNumCteProspecto;		
									
									IF iElemento = 15 THEN --Estudiante
                                        LET cObservs = TRIM('Paso 117');
										--LET cfechaantiguedtrab = cfechanac;
										LET cfechaantiguedtrab = dFechaAlta;
									ELIF iElemento = 12 THEN --Ama de Casa
                                        LET cObservs = TRIM('Paso 118');
										--LET cfechaantiguedtrab =  cfechadesdecuandovive;
										LET cfechaantiguedtrab =  dFechaAlta;
										LET vlugartrabajo = ""; 
										
									ELIF iElemento = 6 OR iElemento = 17 THEN --Desempleado, Jubilado o Pensionado
                                        LET cObservs = TRIM('Paso 119');
										--LET cfechaantiguedtrab = cfechaaltacte; 	
										LET cfechaantiguedtrab = dFechaAlta; 	
										
									END IF;
								ELSE
                                    LET cObservs = TRIM('Paso 120');
									LET cfechaantiguedtrab = YEAR(vfechaaltacliente)-iElemento;	
									LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||"/01/01";
								END IF;					
							ELIF iGrupo = 21 THEN
                                LET cObservs = TRIM('Paso 121');
								IF TRIM(cDescripElemento) = "No Estudió" THEN
									LET cescolaridad = "1";						
								ELIF TRIM(cDescripElemento) = "Primaria" THEN
									LET  cescolaridad = "2";
								ELIF TRIM(cDescripElemento) = "Secundaria" THEN
									LET cescolaridad = "3";
								ELIF TRIM(cDescripElemento) = "Carrera Técnica" THEN
									LET cescolaridad = "4";
								ELIF TRIM(cDescripElemento) = "Preparatoria" THEN
									LET cescolaridad = "5";
								ELIF TRIM(cDescripElemento) = "Licenciatura o Superior" THEN
									LET cescolaridad = "6"; 
								END IF;
							END IF;
						END FOREACH;

                        LET cObservs = TRIM('Paso 122');
						SELECT folio 
						INTO  vfolio 
						FROM bdisolic:"informix".ss_osclientesupervisar  
						WHERE num_solicitud= vNumCteProspecto 
						AND empresa= pempresa 
						AND secuencia IN(SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar 
											  WHERE num_solicitud= vNumCteProspecto);
						
						IF NVL(vfolio, '') = '' THEN
								LET vfolio = '0';
						END IF;					
                        LET cObservs = TRIM('Paso 123');
						--SE OBTIENE LA RESPUESTA DE BURO
						SELECT NVL(COUNT(*), 0) 
						INTO iContConsBuro 
						FROM bdisolic:"informix".ss_solicitudes_sic 
						WHERE numcte = vnumcte 
						AND num_solicitud = vNumCteProspecto;
						

					    LET cObservs = TRIM('Paso 124');
						SELECT CASE WHEN "informix".sp_EsNumerico(ingreso_mensual) = "V" THEN ingreso_mensual::INTEGER ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(cap_sistematica_abono) = "V" THEN cap_sistematica_abono::INTEGER ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(tope_abonocoppel) = "V" THEN tope_abonocoppel::INTEGER ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(lineacreditotope) = "V" THEN lineacreditotope::INTEGER ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(capmaxima_abono) = "V" THEN capmaxima_abono::INTEGER ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(capreal_abono) = "V" THEN capreal_abono::INTEGER ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(lineacredito_real) = "V" THEN lineacredito_real::INTEGER ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(compromisossic) = "V" THEN compromisossic::INTEGER ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(flaglineacreditoesp) = "V" THEN flaglineacreditoesp::INTEGER ELSE 0 END,
						limitecredito, situacion_especial, CASE WHEN "informix".sp_EsNumerico(causa_sitesp) = "V" THEN causa_sitesp::INTEGER ELSE 0 END,
						puntos_parcn, par_celulares, par_altoriesgo, par_prestamos 
						INTO iMontoIngMensual, iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, 
						iFlagLineaCredEsp,vlimitecredito,csituacionespecial, vcausasituacionespecial,iPuntuacion,
						sParCelulares, sParAltoRiesgo, sParPrestamo ----DSB Bernarod Báez 31/03/2017 Se modifica para obtener mas datos en una sola consulta
						FROM bdiprospectos:"informix".pr_nuevo_parametrico
						WHERE empresa = pempresa AND num_solicitud = vNumCteProspecto;
						
						
						
                        LET cObservs = TRIM('Paso 125');
						SELECT ingreso_mensual, periosidad 
						INTO iIngreso, ctiposueldo 
						FROM bdiprospectos:"informix".pr_ingresos 
						WHERE empresa = pempresa 
						--AND numcte_pros = vNumCteProspecto;
                        AND numcte_pros = vNumCteProspecto
						AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdiprospectos:"informix".pr_ingresos WHERE numcte_pros = vNumCteProspecto AND tipo_ingreso = "T");
						IF iIngreso > iTopeMax THEN
							LET iIngreso=iTopeMax;	
						END IF;
						
                        LET cObservs = TRIM('Paso 126');
						LET vingresomensual = ((((NVL(iIngreso::DECIMAL(18,2),0))+(iValor/2)))/iValor)::INTEGER;
						
						IF vingresomensual < 1 THEN
							LET vingresomensual = 1;
						END IF;		
						
                        LET cObservs = TRIM('Paso 127');
						IF cClave="M" THEN
                            LET cObservs = TRIM('Paso 128');
							SELECT situacion_especial,causa_sitesp 
							INTO csituacionespecial,vcausasituacionespecial 
							FROM bdiprospectos:"informix".pr_nuevo_parametrico 
							where num_solicitud =vNumCteProspecto 
							AND status_solicitud='R';
							
                            LET cObservs = TRIM('Paso 129');
							SELECT situacionespecial, causasituacionespecial 
							INTO csituacionespecial, vcausasituacionespecial 
							FROM bdisolic:"informix".ss_osclientesupervisar 
							WHERE num_solicitud= vNumCteProspecto 
                            AND secuencia = (select max(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar where num_solicitud= vNumCteProspecto)
							AND clave in ('R','D');
							
							IF NVL(csituacionespecial,'') = '' AND NVL(vcausasituacionespecial,0)=0 THEN
								IF EXISTS(SELECT 1 FROM bdisolic:"informix".ss_osclientesupervisar os 
										 INNER JOIN bdiprospectos:"informix".pr_cliente cte ON (cte.empresa = '001' and cte.id_empcob <>0 and cte.numcte_pros = vNumCteProspecto)
								WHERE os.clave='A' AND os.num_solicitud=vNumCteProspecto)THEN
								LET csituacionespecial="G";
								LET vcausasituacionespecial=57;
								END IF;
							ELIf EXISTS (SELECT 1 FROM bdiprospectos:"informix".pr_cliente WHERE empresa = '001' and id_empcob=0 AND numcte_pros = vNumCteProspecto) THEN
								LET csituacionespecial="";
								LET vcausasituacionespecial=0;
							END IF;
							
                               LET cObservs = TRIM('Paso 130');
							--caceptadosupervisadorechazado
							   SELECT clave 
							   INTO cClaveOS 
							   FROM bdisolic:"informix".ss_osclientesupervisar 
							   WHERE num_solicitud=vNumCteProspecto and secuencia = (select max(secuencia) from bdisolic:"informix".ss_osclientesupervisar 
							   WHERE num_solicitud=vNumCteProspecto);
							   
							   IF NVL(cClaveOS,'') = '' THEN
									LET cClaveOS = 'R';
							   END IF;
							
								LET caceptadosupervisadorechazado= DECODE(cClaveOS,"R","H","D","D","A","A");
								
                            LET cObservs = TRIM('Paso 131');
							--vefectuo
							SELECT user_insert 
							INTO vefectuo 
							FROM bdisolic:"informix".ss_solicitudes 
							WHERE num_solicitud= vNumCteProspecto; 
							--LET cfechaaltacte = '1900/01/01'; 
							
						ELIF NVL(cClave,'') ='' THEN
                            LET cObservs = TRIM('Paso 132');
							IF EXISTS(SELECT 1 FROM bdiprospectos:"informix".pr_nuevo_parametrico param 
								INNER JOIN bdiprospectos:"informix".pr_cliente cte ON (cte.empresa = '001' and cte.id_empcob=0 and cte.numcte_pros = vNumCteProspecto)
								WHERE param.empresa = '001' AND param.status_solicitud='A' AND param.num_solicitud=vNumCteProspecto)  THEN
									let csituacionespecial ='';
									let vcausasituacionespecial = 0;
							ELIF EXISTS(SELECT 1 FROM bdiprospectos:"informix".pr_nuevo_parametrico param
								INNER JOIN bdiprospectos:"informix".pr_cliente cte ON (cte.empresa = '001' and cte.id_empcob<>0 and cte.numcte_pros = vNumCteProspecto)
								WHERE param.empresa = '001' AND param.status_solicitud='A' AND param.num_solicitud=vNumCteProspecto) THEN
								let csituacionespecial='G';
								let	vcausasituacionespecial=57;
							END IF;
                            LET cObservs = TRIM('Paso 133');
							--caceptadosupervisadorechazado DSB20151105
							IF EXISTS(SELECT 1 FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud =vNumCteProspecto AND clave ='') THEN
							  	 LET caceptadosupervisadorechazado="P";
							--ELIF EXISTS(SELECT 1 FROM bdiprospectos:"informix".pr_cliente cte WHERE  cte.empresa = '001' AND cte.numcte_pros = vNumCteProspecto AND cte.status_numcte_pros  in('AN','PC','RT')) THEN
							ELIF EXISTS(SELECT 1,* FROM bdiprospectos:"informix".pr_autorizacion WHERE  empresa = '001' AND num_solicitud = vNumCteProspecto 
									AND status_solicitud  in('AN','PC','RT') AND fecha_hora = (select max(fecha_hora) FROM bdiprospectos:"informix".pr_autorizacion  
										where empresa = '001' AND num_solicitud = vNumCteProspecto AND status_solicitud  in('AN','PC','RT') AND fecha_insert <= pFechaAct)) THEN
								 LET caceptadosupervisadorechazado="H";
							ELIF EXISTS(SELECT 1 FROM bdiprospectos:"informix".pr_nuevo_parametrico param WHERE  param.empresa = '001' and param.num_solicitud= vNumCteProspecto AND param.status_solicitud='R') THEN
								 LET caceptadosupervisadorechazado="H";
                            --DSB 30 de Marzo 2017 Bernardo Báez Se modifica para contemplar como pendientes cuando clave ya no esa en =''
                            --ELIF EXISTS(SELECT 1 FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud =vNumCteProspecto AND (fecharespuesta > pFechaAct) or (fecharespuesta is null)) THEN
							--  	 LET caceptadosupervisadorechazado="P";
							ELSE
								LET caceptadosupervisadorechazado="P";
							END IF;
							LET vefectuo=vefectuoMOD;
						END IF;
						
                        LET cObservs = TRIM('Paso 134');
						--LET vnumcte='0';
						--SI EXISTE MAS DE UN REGISTRO EN LA SS_SOLICITUD_OS SE OBTIENE LA SECUENCIA MAYOR						
						IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_osclientesupervisar WHERE clave='D' AND num_solicitud = vNumCteProspecto) > 1 THEN
							FOREACH
								SELECT FIRST 1 folio
								INTO vfolioanterior 
								FROM bdisolic:ss_osclientesupervisar 
								WHERE num_solicitud = vNumCteProspecto AND secuencia < vfolio ORDER BY secuencia DESC

                                LET cObservs = TRIM('Paso 135');
							END FOREACH;						
							LET vtiendafolioanterior = cFolioSucursal;		
						END IF;

                        LET cObservs = TRIM('Paso 136');
						--SE OBTIENE EL flagcapturacobranza
						SELECT CASE WHEN id_empcob=0 THEN 0 ELSE 1 END INTO sFlagCapCobranza FROM bdiprospectos:"informix".pr_cliente WHERE empresa = '001' and numcte_pros=vNumCteProspecto;
                        LET cObservs = TRIM('Paso 137');
						--DSB Bernarod Báez 31/03/2017 Se modifica para obtener los datos en una sola consulta
						--Se agregan a la cunsulta de arriba a la tabla pr_nuevo_parametrico
						--SE OBTIENE EL CAMPO PARCELULARES
						--SELECT par_celulares
						--INTO sParCelulares
						--FROM bdiprospectos:"informix".pr_nuevo_parametrico WHERE num_solicitud= vNumCteProspecto;
                        --LET cObservs = TRIM('Paso 138');
						--SE OBTIENE CAMPO sParAltoRiesgo
						--SELECT par_altoriesgo INTO sParAltoRiesgo FROM bdiprospectos:"informix".pr_nuevo_parametrico WHERE num_solicitud =vNumCteProspecto;
                        --LET cObservs = TRIM('Paso 139');
						--SE OBTIENE CAMPO sParPrestamo
						--SELECT par_prestamos INTO sParPrestamo FROM bdiprospectos:"informix".pr_nuevo_parametrico WHERE num_solicitud =vNumCteProspecto;
                        --LET cObservs = TRIM('Paso 140');
						--SE OBTIENE CAMPO cStatusbcpl
						--SELECT status_numcte_pros INTO cStatusbcpl FROM bdiprospectos:"informix".pr_cliente WHERE empresa = '001' and numcte_pros =vNumCteProspecto;
						 --and fecha_insert <= pFechaAct);
						 
						--DSB 31/03/2017 se contempla el estatus del movimiento como el status a guardar en statusbancoppel
						LET cStatusbcpl = cStatus;
						--DSB 31/03/2017 se contempla el status OS como Pediente para cualquier caso
						IF cStatusbcpl = 'OS' THEN
							LET caceptadosupervisadorechazado = 'P';
						ELIF cStatusbcpl = 'OA' THEN
							LET caceptadosupervisadorechazado = 'D';
						ELIF cStatusbcpl = 'PC' THEN
							LET caceptadosupervisadorechazado = 'P';
						ELIF cStatusbcpl = 'RT' THEN
							LET caceptadosupervisadorechazado = 'H';
						END IF;
						
                        LET cObservs = TRIM('Paso 141');
						--SE OBTIENE CAMPO cMotivobcpl
						SELECT causa_solicitud INTO cMotivobcpl FROM bdiprospectos:"informix".pr_autorizacion WHERE status_solicitud ='RT' AND num_solicitud=vNumCteProspecto;
                        LET cObservs = TRIM('Paso 142');
						--SE OBTIENE CAMPO flagprospecto
						SELECT CASE WHEN id_empcob=0 THEN 2 ELSE 3 END INTO cFlagProspecto FROM bdiprospectos:"informix".pr_cliente WHERE empresa = '001' and numcte_pros=vNumCteProspecto;
						
                        LET cObservs = TRIM('Paso 143');
						SELECT MAX(ROWID) INTO iRowId FROM bdiprospectos:"informix".pr_nuevo_parametrico WHERE num_solicitud = vNumCteProspecto;
                        LET cObservs = TRIM('Paso 144');
						SELECT id_situaciones,TRIM(puntualidad_ref1),TRIM(puntualidad_ref2),flagtestigoparametricocn::SMALLINT, flag_altadirecta_asupervisar::SMALLINT,
							puntos_var_param,puntos_var_sic,score_domicilio,nuevo_puntajefinal
						INTO iId_Situaciones,cPuntualidad_ref1,cPuntualidad_ref2,sFlagTestParametrico,sFlag_altadirecta_asupervisar,iPuntos_Var_Param,iPuntos_Var_SIC,iScore_domicilio,sNuevo_puntajefinal
						FROM bdiprospectos:"informix".pr_nuevo_parametrico WHERE empresa = '001' AND ROWID = iRowId;

                        LET cObservs = TRIM('Paso 145');

						--INSERTA LA TRAMA EN LA TABLA QUE GENERA EL ARCHIVO.
						
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

                        LET cObservs = TRIM('Paso 146');

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
						id_situaciones,puntualidad_ref1,puntualidad_ref2,flag_altadirecta_asupervisar,puntos_var_param,puntos_var_sic,score_domicilio,nuevo_puntajefinal)

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
						TRIM(NVL(csituacionespecial, '')),NVL(vcausasituacionespecial, 0), TRIM(cclaveautrechaza),TRIM(NVL(caceptadosupervisadorechazado, '')),TRIM(cclientenuevo),
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
						TRIM(NVL(cClienteReferencia2bcpl,'0')),TRIM(NVL(cFolioSucursal, '0')), NVL(pFechaAct,DATE(1)),TRIM(NVL(cStatus,'')),TRIM(NVL(cMotivobcpl,'')),
						TRIM(NVL(cFlagProspecto,'')),TRIM(NVL(vNumCteProspecto,'')),NVL(iParAltoRiesgoNvo,0),NVL(iPagoUlt12meses,0),
						NVL(iId_Situaciones,0),TRIM(NVL(cPuntualidad_ref1,'')),TRIM(NVL(cPuntualidad_ref2,'')),NVL(sFlag_altadirecta_asupervisar,0),
						NVL(iPuntos_Var_Param,0),NVL(iPuntos_Var_SIC,0),NVL(iScore_domicilio,0),NVL(sNuevo_puntajefinal,0));
						LET iCuentaRegistros = iCuentaRegistros +1 ;
							
                        LET cObservs = TRIM('Paso 147');
					ELSE
                        LET cObservs = TRIM('Paso 148');
						LET vCodRetorno = '000003';
						--LET iCuentaRegistros = 2;
					END IF
				END FOREACH;
			END IF
			IF inumSecuencia > 0 THEN
				UPDATE bdinteg:"informix".si_archivosecuenciamax SET secuencia_max=inumSecuencia;
			END IF;		
		ELSE
			LET vCodRetorno = '000001';
			--LET iCuentaRegistros = 2;
		END IF;
		IF iCuentaRegistros >= 1 THEN
			LET vCodRetorno = '000000';
		ELIF iCuentaRegistros = 0 THEN
			LET vCodRetorno = '000005';
		END IF;
		RETURN vCodRetorno;
	END
	--*************************************************************************
	--| Procedimiento   : "informix".sp_genera_archivosbatch_prospecto
	--| Version         : 1.0
	--| Creado por      : Omar Gamez/Selene Campos
	--| Fecha creacion  : 2015/01/22
	--| Descripcion 	: Reingeniería sobre la generación de las tramas correspondientes a los archivos batch de clientes prospectos.
	--| Procedimiento   : "informix".sp_genera_archivosbatch_prospecto
	--| Creado por      : Pedro Jimenez
	--| Fecha Modificacion : 2015/04/22
	--| Descripcion 	:  Se modifica la consulta para obtener el numero de empleado cobranza.
	--| Procedimiento   : "informix".sp_genera_archivosbatch_prospecto
	--| Creado por      : Ivàn Michel Valdez Rodrìguez
	--| Fecha Modificacion : 2015/06/25
	--| Descripcion 	:  Se modifica por la presencia de inconsistencia en los datos.
	--*************************************************************************
END PROCEDURE;