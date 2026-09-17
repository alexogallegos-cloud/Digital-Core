CREATE PROCEDURE "informix".califica_scoring_cjunk_precal( o_empresa       CHAR(3),
													o_numsol   	 	CHAR(20),
													o_referencia1   CHAR(20),
													o_referencia2   CHAR(20),
													o_ingreso       MONEY(14,2),
													o_tpingreso	  	INTEGER,
													o_periodicidad  INTEGER, 
													o_conyuge       CHAR(20),
													o_nombreref_1   CHAR(104),
													o_nombreref_2   CHAR(104),
													o_parentesco_1  CHAR(2),
													o_parentesco_2  CHAR(2),
													o_telefono_1    CHAR(13),
													o_telefono_2    CHAR(13),
													o_importe_sol   DECIMAL (18,2))

	RETURNING CHAR(5) AS retorno;
	
	--------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo
	-- Modificacion: Se valida la consulta del Cliente en Buro de Credito.
	-- Fecha de Modificacion: 08/01/2009
	-- Proyecto: Caja unica
	--------------------------------------------------------------------------------
	-- Fecha de Modificacion: 18-02-2009
	-- Modifico: Viridiana Osobampo
	-- Descripcion: Se valida el puntaje requerido para la seccion 2 por tipo de
	--              cliente.
	-- RQM 09113
	--------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo
	-- Modificacion: Se modifica para recibir y almacenar el importe solicitado
	--               para Prestamo Personal.
	--               ademas se actualiza el parametro para tomar los dias de vigencia de la consulta a SICs
	-- Fecha de Modificacion: 18/09/2009
	-- Peticion: RQM 10 108 Prestamo Personal
	--------------------------------------------------------------------------------
	--Modifico: Viridiana Osobampo
	--Fecha de modificacion: 25-09-2009
	--Descripcion: Se modifica para reemplazar los parametros al obtener la edad minima y maxima
	--                   por el cambio a los asignados para el proyecto de caja unica.
	--Peticion: RQM 10 108 Prestamo Personal
	------------------------------------------------------------------------------------
	--Modifico: Viridiana Osobampo
	--Fecha de modificacion: 15-10-2009
	--Descripcion: Se realiza correccion de query  que verifica que la puntuacion
	-- 		   del scoring es valida, esto para que el count de registros se
	--		  realice por el campo seccion.
	--Peticion: RQM 10 108 Prestamo Personal
	------------------------------------------------------------------------------------
	--Modifico: Viridiana Osobampo
	--Fecha de modificacion: 05-01-2010
	--Descripcion:  Se modifca la variable de codigo de retorno para asignar un
	--		error controlado de 5 caracteres y no de 6 como se eontraba,
	--		esto al ocurrir un error en la ejecucion del spl
	-- 		 actualiza_status_sol ya que en este caso se asigna el error
	--		"000004" pero al devolverlo se trunca a "00000" ya que la variable
	--                 es char(5) , por lo cual no se detecta que haya ocurrido un error.
	--Peticion: RQM 10 108 Prestamo Personal
	------------------------------------------------------------------------------------
	--Modifico: Viridiana Osobampo
	--Fecha de modificacion: 17-01-2010
	--Descripcion: Se modifica para cuando el num de salarios minimos sobrepase el
	--		  rango maximo, se tope al valor maximo.
	--Peticion: Prestamo Personal
	------------------------------------------------------------------------------------
	--Modifico: Viridiana Osobampo
	--Fecha de modificacion: 01-07-2010
	--Descripcion: Se agregan parametros para recibir el tipo de ingreso y la periodicidad,
	--		  mismos datos que se actualizan como parte de la informacion de solicitud.
	--Peticion: Alta unica paso 4
	------------------------------------------------------------------------------------
	--Modifico: Jesus Manuel Aguilar Heredia
	--Fecha de modificacion: 09-12-2010
	--Descripcion: Se  agrega validacion para identificar si el cliente presenta una ocupacion de riesgo.
	--Peticion: Alta unica paso 4.5
	------------------------------------------------------------------------------------
	--Modifico: Mohamed Carreon
	--Fecha de modificacion: 07-06-2011
	--Descripcion: Se  agrega una causa de rechazo la cual valida que cuando una solicitud sea de coppel y
	--                       que si el estado civil es diferente a casado que verifique que al menos tenga una referencia  de familiar directo
	--		    Causa => "RFP"  Descripcion Causa => "Fuera de Politicas de Credito Coppel".
	--Peticion: Alta unica paso 5
	------------------------------------------------------------------------------------
	--Modifico:Jesus Manuel Aguilar Heredia
	--Fecha de modificacion: 26-10-2011
	--Descripcion: Se registra las referencias para el producto coppel, ya que si tramita banco y coppel al mismo tiempo, la informacion se guarda con el numero de solicitud de banco,
	--Peticion: Ajustes Alta unica paso 5 - piloto
	------------------------------------------------------------------------------------
	--Modifico:Jesus Manuel Aguilar Heredia
	--Fecha de modificacion: 22-12-2011
	--Descripcion: Se modifca para verficar si es necesario el envio a buro de credito.
	--Peticion: RQM 18 011 Vigencia de Consulta al Buro y Circulo de Credito
	------------------------------------------------------------------------------------
	--Modifico:Josue Remberto Zazueta Acosta  
	--Fecha de modificacion: 16-11-2012 
	--Descripcion: Se modifica para rechazar solicitudes de credito BanCoppel y Coppel  que hagan match con la huella de algun  empleado del grupo Coppel 
	--Peticion: RQM+09+299+Rechazo+de+solicitudes+de+Credito+a+empleados+del+grupo_0001_v1.pdf 
	--BD      : bdisolic
	------------------------------------------------------------------------------------ 
	------------------------------------------------------------------------------------ 
	--Modifico: Clemente Angulo Ballardo 
	--Fecha de modificacion: 22-12-2012 
	--Descripcion: Se valida el riesgo correctamente de la actividad del solicitante, segun sea una solicitud Banco o Coppel
	--Peticion: RQM+09+299+Rechazo+de+solicitudes+de+Credito+a+empleados+del+grupo_0001_v1.pdf 
	--BD      : bdisolic 
	------------------------------------------------------------------------------------ 
	------------------------------------------------------------------------------------ 
	--Modifico: Guadalupe Payan
	--Fecha de modificacion: 25-01-2013
	--Descripcion: Se realiza homologacion con fuentes modificados por bancoppel: Se agrega validacion para filtrar clientes "Z"  y actualizar la causa solicitud a "RDO". 
	--             Ademas se actualiza el campo "elemento" de la tabla "bdisolic:ss_detalle_scoring" segun el valor extraido de la tabla "bdinteg:si_ctepf del campo habita_en".
	--				Se quitan referencias a la base de datos local "bdisolic" esto segun las nuevas reglas de informix.
	--Peticion: Contrato-MttoAltaUnica_04.doc
	--BD      : bdisolic 	
	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------ 
	--Modifico: Carlos Aguirre Vega
	--Fecha de modificacion: 07-05-2013
	--Descripcion: Se modifica el nombre del sp de califica_scoring_cjunk_02 a califica_scoring_cjunk
	--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	--Modifico: Carlos Aguirre Vega
	--Fecha de modificacion: 23-05-2013
	--Descripcion: Se actualiza status de solicitud a EC cuando la solicitud termine de consultar buro.
	--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
	------------------------------------------------------------------------------------
	-- Modifico: Maria Elena Angulo Aispuro
	-- Fecha de Modificacion: 28-08-2018
	-- Descripcion: Se inhabilita el bloque de FICO Extended
	-- RQ: RQI27201
	-- CC Rational: 26072
	------------------------------------------------------------------------------------
	-- Folio: 660 
	-- Modifico: 97879606 - Adrian Eduardo Lizarraga
	-- Fecha de Modificacion: 03-07-2020
	-- Descripcion: Se agregan los productos 6600, 6500, 6300, 7600, 7700 y 6800 a la verificacion de si se dieron de alta como productos mixtos con el producto 6500.
	-- RQM: RQM 09 553 Ofertar Credito Coppel a todos los solicitantes en Alta ÃÂºnica
	-- Solicito: Abraham Narvaez.
	------------------------------------------------------------------------------------
	-- Autor:  Francisco Javier Peraza.
	-- Modifica: Se modifica orden de consulta a las instituciones de credito
	-- Fecha: 15-04-2020.
	-- Peticion: RQM 09 554 - Consulta a las SICs.
	------------------------------------------------------------------------------------
	-- Folio: 773
	-- Modifico: 97879606 - Brando D. Garcia Lemus.
	-- Fecha de Modificacion: 07-05-2021
	-- Descripcion: Se aÃÂ±ade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC.
	-- RQM: RQM 09 570 Pop Ups para informar sobre solicitudes no autorizadas.
	-- SolicitÃÂ³: Abraham Narvaez.
	------------------------------------------------------------------------------------
	-- *********************************************************************
	-- *                        DEFINICION DE VARIABLES                    *
	-- *********************************************************************
	DEFINE scod_ret                	CHAR(5);
	DEFINE p_cod_ret               	CHAR(6);
	DEFINE vsqlerr                 	INTEGER;
	DEFINE v_valor                 	DECIMAL(14,2);
	DEFINE v_valor_1s              	DECIMAL(14,2);
	DEFINE v_valor_2s              	DECIMAL(14,2);
	DEFINE v_valor_im              	DECIMAL(14,2);
	DEFINE v_valor_ex              	DECIMAL(14,2);
	DEFINE v_paso                  	CHAR(1);
	DEFINE v_seccion               	SMALLINT;
	DEFINE v_grupo                 	SMALLINT;
	DEFINE v_tpsol                 	CHAR(1);
	DEFINE v_hoy                   	DATE;
	DEFINE v_cliente               	CHAR(20);
	DEFINE vCompromisos            	DECIMAL(14,2);
	DEFINE vMensaje                	VARCHAR(255);
	DEFINE vedocivil               	CHAR(1);
	DEFINE vTpCiudad               	CHAR(2);
	DEFINE vCiudadCte              	CHAR(3);
	DEFINE vEstadoCte              	CHAR(2);
	DEFINE v_Porcentaje            	DECIMAL(10,7);
	DEFINE v_Antiguedad            	INTEGER;
	DEFINE v_Seccion_Cd            	SMALLINT;
	DEFINE v_Grupo_Cd              	SMALLINT;
	DEFINE v_Elemento_Cd           	SMALLINT;
	DEFINE v_Valor_Cd              	DECIMAL(14,2);
	DEFINE v_SalarioMinimoCoppel   	SMALLINT;
	DEFINE v_Elemento_smc          	SMALLINT;
	DEFINE v_Valor_smc             	DECIMAL(14,2);
	DEFINE v_NumSalariosMinimos    	INTEGER;
	DEFINE v_CiudadCoppelCte       	SMALLINT;
	DEFINE v_ValorCdCoppel         	CHAR(1);
	DEFINE V_Diferencial           	DECIMAL(14,2);
	DEFINE v_FechaAntiguedad       	DATE;
	DEFINE v_anios                 	DECIMAL(14,2);
	--ini CAS
	DEFINE v_SituacionPagoCoppel   	DECIMAL(5,2);
	DEFINE v_EficienciaCoppel      	SMALLINT;
	DEFINE v_cuantos               	SMALLINT;
	DEFINE v_meses_hist	           	SMALLINT;
	DEFINE v_meses    	           	SMALLINT;
	DEFINE v_meses_hist_inter      	SMALLINT;
	DEFINE orden_consul            	CHAR(1);
	DEFINE status_consul           	CHAR(2);
	DEFINE v_habita_en             	CHAR(2);
	DEFINE v_profesion             	CHAR(3);
	DEFINE v_habitdomi				CHAR(3);
	DEFINE v_mod_parame       		CHAR(1);
	DEFINE v_sucursal         		CHAR(4);
	--fin CAS
	-- Ini Caja Unica. Viridiana
	DEFINE v_VigenciaCC            	SMALLINT;
	DEFINE sNum_producto           	CHAR(4);
	DEFINE cExiste                 	CHAR(20);
	DEFINE cActualiza              	CHAR(1);
	DEFINE cRegreso                	CHAR(4005);
	DEFINE dFecha_Cons             	DATE;
	DEFINE cStatusSol              	CHAR(2);
	DEFINE cEnvio                  	CHAR(1);
	DEFINE cCausa_sol              	CHAR(3);
	-- Fin Caja Unica. Viridiana
	DEFINE mRango_max				MONEY(14,2);
	--
	DEFINE iAct						SMALLINT;
	DEFINE iSubAct					SMALLINT;
	DEFINE vRiesgo					SMALLINT;
	DEFINE vRiesgoBco              	SMALLINT;
	DEFINE vRiesgoCop              	SMALLINT;
	DEFINE iSecuencia				SMALLINT;
	DEFINE cSinFamiliar				CHAR(1);
	------Referencias
	DEFINE cSucursal 				CHAR(4);
	DEFINE cApellPaterno 			CHAR(26);
	DEFINE cApellMaterno 			CHAR(26);
	DEFINE cNombre1 				CHAR(26);
	DEFINE cNombre2 				CHAR(26);
	DEFINE cRfc 					CHAR(13);
	DEFINE dtFechaNac 				DATE;
	DEFINE cCurp 					CHAR(20);
	DEFINE cSexo 					CHAR(1);
	DEFINE cEstadoCivil 			CHAR(2);
	DEFINE cNacionalidad 			CHAR(3);
	DEFINE cNoFm 					CHAR(18);
	DEFINE cCodigoIden 				CHAR(2);
	DEFINE cNumIdentif 				CHAR(30);
	DEFINE cPersDomicilio 			CHAR(2);
	DEFINE cEmail 					CHAR(60);
	DEFINE cParentesco 				CHAR(2);
	DEFINE cApellCasada 			CHAR(26);
	DEFINE cNumcteRef 				CHAR(20);
	DEFINE cNumCteBanco 			CHAR(20);
	DEFINE cUsuario 				CHAR(8);
	DEFINE dtFecha 					DATE;
	DEFINE cCodret    				CHAR(5);
	DEFINE cCodret2    				CHAR(5);
	DEFINE ptipogrupo 				CHAR(2); 
	DEFINE phit 					CHAR(6);
	DEFINE iSecuencia2   			INTEGER;
	DEFINE iContadorRef   			INTEGER;
	DEFINE iSecuenciaMax  			INTEGER;
	DEFINE iDiasVigencia  			INTEGER;
	DEFINE iEnvio  					INTEGER;
	DEFINE cOrigenSol  				CHAR(1);
	DEFINE cEjecutaScoring2  		CHAR(1);
	DEFINE cNumSolSIC  				CHAR(20);
	DEFINE cConsultaSic  			CHAR(2);
	----envio a CC
	--APR
	DEFINE dtFechaSic 				DATE;
	--APR
	DEFINE cSitEsp 					CHAR (1);
	DEFINE iCausaSitEsp 			SMALLINT;
	DEFINE iBanderaSitEsp 			SMALLINT;
	DEFINE cNomcte  				CHAR(104);
	DEFINE iEdadcte 				SMALLINT;
	DEFINE iBanderaCoppel 			SMALLINT;
	-- Se agrega validacion para filtrar clientes "Z" 
	DEFINE v_puntualidad     		CHAR(02); 
	-- Se agrega validacion para filtrar clientes "Z" FIN 
	--- habita en Correccion Grupo 6 FMJ INI 
	DEFINE vElementohabita_en 		SMALLINT; 
	---habita en Correccion Grupo 6 FMJ FIN 
	DEFINE cTicket				   	CHAR(20); 
	DEFINE cEdo_proceso			   	CHAR(4); 
	DEFINE cNum_men				   	CHAR(3); 
	DEFINE cEmpresa				   	CHAR(4); 
    --APR Rechazo RGC parametrizado
    DEFINE v_rechazo                CHAR(1);
    DEFINE iNumRefs                SMALLINT;
    DEFINE cNumSolicitud           CHAR(20);
    DEFINE cNombreRef           CHAR(104);
	DEFINE cTipoSol				   	CHAR(1);
	DEFINE cTipoMov				   	CHAR(1);
    -- Valida preguntas de parametrico que esten completas en sucursal
    DEFINE sNumGpos, sNumPregSol    SMALLINT;
    DEFINE	vlClienteRef			CHAR(20);
	DEFINE	vlNombre				CHAR(104);	
	DEFINE  vsituacion_especial    CHAR(1);     --, 
	DEFINE	vcausa_situacion		SMALLINT;
	DEFINE 	o_vencidomuebles INTEGER;
	DEFINE 	o_vencidoropa    INTEGER;
	DEFINE 	o_vencidoprestamos INTEGER;
	DEFINE 	o_abonomuebles	 INTEGER;
	DEFINE 	o_abonoprestamos INTEGER;
	DEFINE 	o_abonoropa      INTEGER;
	DEFINE 	o_saldomuebles   INTEGER;
	DEFINE 	o_saldoropa      INTEGER;
	DEFINE 	o_saldoprestamos INTEGER;
    DEFINE 	o_ultimacompra   DATE;
	DEFINE	vValidaSPTienda	 CHAR(1);
	DEFINE  cStatusMov         CHAR(1);
	DEFINE  cFolioMovil         CHAR(20);
	DEFINE  cStatus         CHAR(2);
	DEFINE  cStatusSol2         CHAR(2);
	DEFINE  iProdMC          INTEGER;
    DEFINE  iElemento_g3    SMALLINT;
    DEFINE  iElemento_g4    SMALLINT;
--IPCB jun2015 --RQM 09 384-0FICO SCORE
	DEFINE institucion_sic      CHAR(2);
	DEFINE entra_cc 			integer;	
	DEFINE vevalua_cc 			CHAR(01);
	DEFINE v_bcs_min,v_bcs_max  INTEGER;
	DEFINE iFlag2credito         SMALLINT;
	DEFINE iFlag2creditoAux         SMALLINT;
	DEFINE sICC         SMALLINT;
--IPCB ago2016 --FICO EXTENDED
	DEFINE v_sc_prop			INTEGER;
	DEFINE v_scp_min            INTEGER;
	DEFINE s_regreso  			CHAR(1);	
-- VALIDACION IFE
    DEFINE B_ife            char(01);
    DEFINE B_valida_ife     char(01);
    DEFINE dMontoMin     DECIMAL(14,2);
	DEFINE cTelCel		CHAR(10) ;

-- validacion de status de cliente grupo coppel
	DEFINE cActivo CHAR(1);
	DEFINE cBandera CHAR(1);

	
-- Nuevas variables para bitacora determinacion
    DEFINE dFechaNac     DATE;
	DEFINE cSexoBitDet   CHAR(1);
    DEFINE cEscolaridad  CHAR(2);
    DEFINE cRFC_Cte      CHAR(13);
    DEFINE cDescSitEsp   VARCHAR(50);
    DEFINE sReestructCte SMALLINT;
	DEFINE vfecha_sol	DATE;
	DEFINE vAct_Sub		VARCHAR (50);
	DEFINE dlinea_min_prod      DECIMAL(18,2);
	DEFINE scod_ret_bit  CHAR(5);
	DEFINE vescolaridad_des VARCHAR(50);
	DEFINE Flag_bitacora 	SMALLINT;
	---------
    DEFINE cCuentaPP SMALLINT;
	DEFINE cTelefono1               CHAR(13);
	DEFINE cTelefono2               CHAR(13);
	DEFINE cTelefono3               CHAR(13);
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB 
	DEFINE ccausaRT    CHAR(4);
	DEFINE flag_rt_rcb SMALLINT;
	DEFINE cNumCteProspecto			CHAR(20);
    DEFINE cCanal            integer; 
	define cStatusPrev        CHAR(2); 
    define iMotivoOs         integer;
    define iBanderaFaltaOSTEL integer;
    define cTipoMovto         CHAR(1); 
    define iFlagForzarEnvioMC smallint;
    define v_hereda_status    CHAR(2);    
    define VNuevoStatus CHAR(2); 
    DEFINE vMensajeStatus         CHAR(80);
	DEFINE cfamilia  		CHAR(3); --RQM 10 1177
	DEFINE ctipo_nomina		CHAR(1); --RQM 10 1177


 
	DEFINE es_internet              INTEGER;
	DEFINE wBegin               CHAR (1);
	DEFINE aun_prospecteo       CHAR (1);
	DEFINE fgst_prosp			CHAR(1);
	-- RQM 09 554 - Consulta a las SICs.
	DEFINE cFlujo_cc CHAR(1);
	DEFINE tipo_acceso_bc CHAR (03);
	DEFINE usu_orden2   CHAR(10);
	DEFINE pass_orden2  CHAR(8);
	DEFINE cCanalSol	CHAR (2);
	DEFINE vfechaServ DATE;

	DEFINE 	o_vencidoaire 		  INTEGER;   						---Autor: Jonathan Medina(INICIO) 	07/09/2021
	DEFINE 	o_abonoaire    		  INTEGER;
	DEFINE 	o_saldoaire 		  INTEGER;
	DEFINE 	o_vencidoafiliados	  INTEGER;
	DEFINE 	o_abonoafiliados 	  INTEGER;
	DEFINE 	o_saldoafiliados      INTEGER;
	DEFINE 	o_vencidoreestructura INTEGER;	
	DEFINE 	o_abonoreestructura   INTEGER;
	DEFINE 	o_saldoreestructura   INTEGER;					
	DEFINE  iScorePuntualidad     INTEGER;							
	DEFINE  cPuntualidadZ		  CHAR(3);		---Autor: Jonathan Medina(FINAL)	07/09/2021
	DEFINE  vCanalSol			  CHAR(1);
	DEFINE  sStatCNIncomAux		  SMALLINT;
				
				
	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************
    --SET DEBUG FILE TO "/tmp/califica_scoring_cjunk.out";
	--TRACE ON;

	LET scod_ret                = "000";
	LET p_cod_ret               = "000000";
	LET vsqlerr                 = 0;
	LET v_valor                 = 0;
	LET v_valor_1s              = 0;
	LET v_valor_2s              = 0;
	LET v_valor_im              = 0;
	LET v_valor_ex              = 0;
	LET v_paso                  = "";
	LET v_seccion               = 0;
	LET v_grupo                 = 0;
	LET v_tpsol                 = "";
	LET v_Porcentaje            = 0;
	LET v_Antiguedad            = 0;
	LET v_Seccion_Cd            = 0;
	LET v_Grupo_Cd              = 0;
	LET v_Elemento_Cd           = 0;
	LET v_Valor_Cd              = 0;
	LET v_SalarioMinimoCoppel   = 0;
	LET v_Elemento_smc          = 0;
	LET v_Valor_smc             = 0;
	LET v_NumSalariosMinimos    = 0;
	LET v_CiudadCoppelCte       =0;
	LET v_ValorCdCoppel         = "";
	LET v_Diferencial           =0;
	LET v_anios                 =0;
	--ini CAS
	LET v_SituacionPagoCoppel   = 0;
	LET v_EficienciaCoppel      = 0;
	LET v_cuantos               = 0;
	LET v_meses_hist            =0;
	LET v_meses                 =0;
	LET v_meses_hist_inter      =0;
	LET orden_consul            ='0';
	LET status_consul           ='00';
	--fin CAS
	-- Ini Caja Unica: Viridiana
	LET v_VigenciaCC            =0;
	LET sNum_producto           = '';
	LET cExiste                 = "";
	LET cActualiza              = "";
	LET vMensaje                = "";
	LET cRegreso                = "";
	LET dFecha_Cons             = DATE(1);
	LET cStatusSol              = "";
	LET cEnvio                  = "0";
	LET v_habita_en             ="";
	LET v_profesion             ="";
	LET v_habitdomi             ="";
	--LET vMensaje                ="";
	LET v_mod_parame            ="";
	LET v_sucursal              ="";
	LET cCausa_sol              = "";
	-- Fin Caja Unica. Viridiana
	LET mRango_max				= 0;
	---
	LET iAct					= 0;
	LET iSubAct					= 0;
	LET vRiesgo					= 0;
	Let vRiesgoBco          	= 0;
	Let vRiesgoCop          	= 0;
	LET iSecuencia				= 0;
	LET cSinFamiliar			= "0";
	------Referencias
	LET cSucursal  				= "";
	LET cApellPaterno  			= "";
	LET cApellMaterno  			= "";
	LET cNombre1  				= "";
	LET cNombre2  				= "";
	LET cRfc  					= "";
	LET dtFechaNac 				= DATE(1);
	LET cCurp  					= "";
	LET cSexo  					= "";
	LET cEstadoCivil  			= "";
	LET cNacionalidad  			= "";
	LET cNoFm  					= "";
	LET cCodigoIden  			= "";
	LET cNumIdentif  			= "";
	LET cPersDomicilio  		= "";
	LET cEmail  				= "";
	LET cParentesco  			= "";
	LET cApellCasada  			= "";
	LET cNumcteRef  			= "";
	LET cNumCteBanco 			= "";
	LET cUsuario  				= "";
	LET dtFecha 				= DATE(1);
	LET iSecuencia2 			= 0;
	LET iContadorRef 			= 0;
	LET iSecuenciaMax 			= 0;
	LET iDiasVigencia 			= 7;
	LET iEnvio 					= 0;
	LET cOrigenSol 				= '1';
	LET cEjecutaScoring2 		= '0';
	LET cNumSolSIC 				= '';
	
	LET cTipoMov = '';
	LET cConsultaSic 			= '';
	LET vElementohabita_en 		= 0; 
	--APR
	LET dtFechaSic 				= DATE(1);
	--APR
	LET cCodret 				= "";
	LET cCodret2 				= "";
	LET ptipogrupo 			    = "";
	LET phit					= "";
	LET cSitEsp 				= "" ;
	LET iCausaSitEsp 			= 0;
	LET iBanderaSitEsp 			= 0;
	LET cNomcte    				= "";
	LET cSexo      				= "";
	LET iEdadcte   				= 0;
	LET iBanderaCoppel   		= 0;
	-- Se agrega validacion para filtrar clientes "Z" INI
	LET v_puntualidad  			= ""; 
	-- Se agrega validacion para filtrar clientes "Z" FIN
	LET cEdo_proceso	   		=""; 
	LET cNum_men		   		=""; 
	LET cEmpresa		   		=""; 
	LET cTicket			   		=""; 
	LET v_cliente		   		=""; 
    --APR Rechazo RGC parametrizado
    LET v_rechazo               ="";
    LET cNumSolicitud	="";
    LET cNombreRef	="";
    LET iNumRefs               =0;
    -- Valida parametrico completo en sucursal
    LET sNumGpos = 0;
    LET sNumPregSol = 0;
    LET vlClienteRef  ='';
	LET vlNombre	='';
	LET o_vencidomuebles =0;
	LET o_vencidoropa    =0;
	LET o_vencidoprestamos =0;
	LET o_abonomuebles	 =0;
	LET o_abonoprestamos =0;
	LET o_abonoropa      =0;
	LET o_saldomuebles   =0;
	LET o_saldoropa      =0;
	LET o_saldoprestamos =0;
    LET o_ultimacompra   = date(1);
	LET vsituacion_especial = '';
	LET	vValidaSPTienda = '';
	LET cStatusMov ='';
	LET cFolioMovil ='';
	LET cStatus ='';
	LET cStatusSol2 ='';
	LET iProdMC			 =0;
    LET iElemento_g3 = 0;
    LET iElemento_g4 = 0;
	--IPCB 16jun2015 --FICO SCORE
	LET institucion_sic ='BC';
	LET entra_cc   = 0;
	LET vevalua_cc  = '';
	LET v_bcs_min = 0;
	LET v_bcs_max = 0;
	LET iFlag2credito = 0;
	LET iFlag2creditoAux = 0;
	LET sICC = 0;
--IPCB ago2016 --FICO EXTENDED
	LET v_sc_prop = 0;
	LET v_scp_min = 0;
	LET s_regreso =  '0';	
    LET B_ife = '';
    LET B_valida_ife = '';
    LET dMontoMin = 0;
	LET cTelCel		 = '';
	-- validacion de status de cliente grupo coppel
	LET cActivo = '';
	LET cBandera = '';

    -- Variables para bitacora determinacion
    LET dFechaNac       = date(1);
	LET cSexoBitDet     = "";
    LET cEscolaridad    = '';
    LET cRFC_Cte        = '';
    LET cDescSitEsp     = '';
    LET sReestructCte   = 0;
	LET vcausa_situacion = 0;
	LET vfecha_sol		= date (1);
	LET dlinea_min_prod = 0;
	LET scod_ret_bit    = "0";
	LET vAct_Sub 		= "";
	LET vescolaridad_des = "";
	LET Flag_bitacora   = 0;
    LET cCuentaPP = 0; 
	LET cTelefono1              = "";
	LET cTelefono2				= "";
	LET cTelefono3				= "";
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB 
	LET ccausaRT 	= "";
	LET flag_rt_rcb = 0;
	LET cNumCteProspecto = "";
    LET cCanal                    = 99;
	let cStatusPrev       =''; 
    let iMotivoOs     =0;
    let iBanderaFaltaOSTEL =0;
    let cTipoMovto=''; 
    let iFlagForzarEnvioMC =0;  
    let v_hereda_status='';
    let VNuevoStatus='';
    LET vMensajeStatus="";
    LET wBegin = "N";
	LET cfamilia = ""; --RQM 10 1177
	LET ctipo_nomina = ""; --RQM 10 1177 


	LET es_internet  = 0;
	LET aun_prospecteo = '';
	LET fgst_prosp = '';
	-- RQM 09 554 - Consulta a las SICs.
	LET cFlujo_cc = '1';
	LET usu_orden2 = '';
	LET pass_orden2 ='';
    LET cCanalSol	='';
	
	LET o_vencidoaire             =0;
	LET o_abonoaire               =0;
	LET o_saldoaire               =0;
	LET o_vencidoafiliados        =0;
	LET o_abonoafiliados 	      =0;
	LET o_saldoafiliados          =0;
	LET o_vencidoreestructura     =0;
	LET o_abonoreestructura   	  =0;
	LET o_saldoreestructura  	  =0;
	LET iScorePuntualidad   	  =0;
	LET cPuntualidadZ 			  ="";
	LET vCanalSol				  ="";
	LET sStatCNIncomAux			  = 0;
	
	SELECT {+INDEX(bdicred:"informix".sd_fechas idx_sdfechas)} fecha_hoy INTO v_hoy FROM bdicred:"informix".sd_fechas WHERE empresa = o_empresa;
	
	--RQI 21 246  OriginaciÃÂ³n de solicitudes 24 x 7 INI
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;

	IF v_hoy < vfechaServ THEN
		LET v_hoy = vfechaServ;
	END IF;
	--RQI 21 246  OriginaciÃÂ³n de solicitudes 24 x 7 FIN
	
	-- ****************************************************************************
	-- *                        CONTROL DE ERRORES                                *
	-- ****************************************************************************
	BEGIN
		ON EXCEPTION SET vsqlerr
		   IF vsqlerr != 0 THEN
			  LET scod_ret=vsqlerr;
			  RETURN scod_ret;
		   END IF;
		END EXCEPTION;

   /*ON EXCEPTION IN (-535)
    LET wBegin = "S";
      --ROLLBACK WORK;
      --COMMIT WORK;
      BEGIN WORK;
      COMMIT WORK;
   END EXCEPTION WITH RESUME;*/

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- ****************************************************************************
		-- *                        PROGRAMA PRINCIPAL                                *
		-- ****************************************************************************
 		-- ********************************  
		-- Inserta Referencias Personales *  
		-- ********************************  
       --SET DEBUG file to '/tmp/califica_scoring_cjunk_SIC.out';  
	   --TRACE ON;
	   --SET DEBUG FILE TO '/informix/Fperaza/NuevosCambios/canales/traces/califica_scoring_cjunk'||o_numsol||'.out';
		--TRACE ON;

        -- Inserta registro de solicitud para tabla de revision de la cnbv
        IF NOT EXISTS (select num_solicitud from bdisolic:"informix".ss_revision_determinacion where num_solicitud = o_numsol ) THEN			
            INSERT INTO {AVOID_FULL("informix".ss_revision_determinacion)} bdisolic:"informix".ss_revision_determinacion 
			(empresa, num_solicitud) VALUES(o_empresa, o_numsol); -- mahr-cnbv
        END IF;

			
		-- *****************************************************  
		-- VALIDA SI EL SOLICITANTE ES EMPLEADO DE GRUPO COPPEL * 
		-- *****************************************************  		   		   
		SELECT {+INDEX ("informix".ss_solicitudes_movil)}
		sol.numcte,sol.tipo_solicitud, sol.num_producto,sol.sucursal,mov.status,mov.folio_movil ,sol.status_solicitud,sol.fecha_insert, sol.canal_sol -- Viridiana. Obtiene el producto
		INTO v_cliente,v_tpsol, sNum_producto,v_sucursal,cStatusMov,cFolioMovil,cStatusSol2,vfecha_sol, vCanalSol
		FROM "informix".ss_solicitudes sol 
		LEFT JOIN bdisolic:"informix".ss_solicitudes_movil mov on (mov.empresa = sol.empresa and mov.num_solicitud = sol.num_solicitud AND status <> '3')
		WHERE sol.empresa = o_empresa
			AND sol.num_solicitud = o_numsol;
		
        IF sNum_producto <> '7800' THEN
		--IPCB 12Abr21 INI --Credito solicita inactivar validaciÃÂ³n de segundo producto para meter Requerimiento. Con esto no se prende la bandera																																		  
    		--EXECUTE PROCEDURE  bdicred:"informix".sp_valida2credito ('001', TRIM(v_cliente) ,TRIM(o_numsol), 2) INTO cCodRet,iFlag2credito,sICC;
        END IF;

		
        --APR ini
		SELECT rechazo_RGC, monto_min_cred, familia, tipo_nomina
		INTO v_rechazo,dlinea_min_prod,cfamilia, ctipo_nomina
		FROM bdicred:"informix".sd_definicion
		WHERE empresa = o_empresa
			AND num_producto = sNum_producto;
        --APR fin

	--ini jesus RM 09-279-2
		--IF sNum_producto in ("6001","6500") THEN
		--IF sNum_producto IN ("6001","6600","6500","6300","7600","7700","6800") THEN
		--RQM 10 1177 Se contempla la condicion por familia descartando los productos que no aplican
		IF cfamilia IN ('001','002','003','004') AND sNum_producto NOT IN('6400','8500','7000','8100','7800') THEN
			--se obtiene el numero de solicitud asociada.
		
			--IF sNum_producto = "6001" THEN
			--IF sNum_producto IN ("6001","6600","6300","7600","7700","6800") THEN
			IF cfamilia IN ('001','002','003') AND sNum_producto NOT IN('6400','8500','7000','8100','7800') THEN
				LET cTipoSol = 'C';
			ELSE
				LET cTipoSol = 'T';
			END IF;
		
			SELECT num_solicitud
				INTO cNumSolicitud
			FROM "informix".ss_solicitudes
			WHERE empresa = o_empresa
			AND numcte  =v_cliente
			AND tipo_solicitud = cTipoSol
			AND fecha_insert = v_hoy
			AND fecha_hora = (SELECT MAX(fecha_hora)				
						FROM "informix".ss_solicitudes
						WHERE empresa = o_empresa
						AND numcte  =v_cliente
						AND tipo_solicitud = cTipoSol
						AND fecha_insert = v_hoy);
			IF NVL(cNumSolicitud, '') = '' AND TRIM(sNum_producto) = "6500" THEN
				LET cTipoSol = 'P';
								
				SELECT num_solicitud
					INTO cNumSolicitud
				FROM "informix".ss_solicitudes
				WHERE empresa = o_empresa
				AND numcte  =v_cliente
				AND tipo_solicitud = cTipoSol
				AND fecha_insert = v_hoy
				AND fecha_hora = (SELECT MAX(fecha_hora)				
							FROM "informix".ss_solicitudes
							WHERE empresa = o_empresa
							AND numcte  =v_cliente
							AND tipo_solicitud = cTipoSol
							AND fecha_insert = v_hoy);
			END IF;
			
			IF NVL(cNumSolicitud, '') = '' THEN
				SELECT num_solicitud_ref
					INTO cNumSolicitud
				FROM "informix".ss_resum_scor_fin
				WHERE empresa = o_empresa
				AND num_solicitud = o_numsol;
			END IF;
		END IF;
		
		IF NVL(cNumSolicitud,'') ='' THEN
			LET cNumSolicitud ='';
			LET cTipoMov ='U';
		ELSE
			LET cTipoMov ='M';
		END IF;

		call bdisolic:"informix".sp_obtienegrupo (o_numsol)RETURNING cCodret2,ptipogrupo,phit;

		let cCodRet2 = '000';
		-- ********************************
		-- Actualiza Ingresos del Cliente *
		-- ********************************
		UPDATE "informix".ss_resum_scor_fin
		SET ingreso_mensual = o_ingreso,
		  tp_ingreso = o_tpingreso,
		  periodo_ingreso = o_periodicidad,
		  tipo_movimiento = cTipoMov,--RQM 09 279-2 
		  num_solicitud_ref  = cNumSolicitud --RQM 09 279-2 
		  --grupo = ptipogrupo mahr-cnbv
		WHERE empresa = o_empresa
		AND num_solicitud = o_numsol;
		--fin  jesus RM 09-279-2

			SELECT nvl((select telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 1),0),
              nvl((select telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 2),0),
              nvl((select telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 3),0)
			  into cTelefono1,cTelefono2,cTelefono3
		FROM bdinteg:"informix".si_cliente a
		WHERE numcte = v_cliente;
        --mahr-cnbv  
        UPDATE bdisolic:"informix".ss_revision_determinacion SET ingreso_mensual = o_ingreso, numcte = v_cliente, num_producto = sNum_producto,
		 telefono_domicilio = cTelefono1,telefono_celular = cTelefono2, telefono_trabajo = cTelefono3,
		 telefono_ref1 = o_telefono_1, telefono_ref2 = o_telefono_2
         WHERE empresa = o_empresa AND num_solicitud = o_numsol;

		IF NOT o_nombreref_1 IS NULL AND LENGTH(o_nombreref_1) > 0 THEN
			INSERT INTO  "informix".ss_refpersonales
					(empresa, num_solicitud, numcte, numcte_ref, tipo_relacion,
					 nombre_ref, parentesco, telefono_ref)
			VALUES  (o_empresa, o_numsol, v_cliente, o_referencia1, "01",
					o_nombreref_1 , o_parentesco_1, o_telefono_1);
		END IF
		
		IF NOT o_nombreref_2 IS NULL AND LENGTH(o_nombreref_2) > 0 THEN
			INSERT INTO  "informix".ss_refpersonales
					(empresa, num_solicitud, numcte, numcte_ref, tipo_relacion,
						nombre_ref, parentesco, telefono_ref)
			VALUES  (o_empresa, o_numsol, v_cliente, o_referencia2, "01",
						o_nombreref_2 , o_parentesco_2, o_telefono_2);
		END IF

		-- Registro que identificara el numero de cliente asignado al conyuge
		IF NOT o_conyuge IS NULL AND LENGTH(o_conyuge) > 0 THEN
			INSERT INTO  "informix".ss_refpersonales
					(empresa, num_solicitud, numcte, numcte_ref, parentesco)
			VALUES  (o_empresa, o_numsol, v_cliente, o_conyuge, "E");
		END IF
	
		IF  cStatusMov = '1' AND  (LENGTH(o_nombreref_1) > 0 OR LENGTH(o_conyuge) > 0 ) THEN --significa que esta pendiente y se esta complementando el proceso
		
			UPDATE "informix".ss_solicitudes_movil		
			SET status = '2',--finalizado la captura de informacion
			descripcion_status = vMensaje 
			WHERE 	empresa  = o_empresa 
			AND  num_solicitud = o_numsol;
			
			
			UPDATE  bdinteg:"informix".si_solicitud_movil 
				SET folio_procesado ='1'			
			WHERE folio = cFolioMovil;
			
			IF cStatusSol2 = 'PA' THEN
				EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, "AT","", "Solicitud Autorizada" ) INTO p_cod_ret;
			END IF;
			RETURN scod_ret;
		END IF;
	
		SELECT canal_sol,sts_prev_pa, vvalor_junk, imotivos_junk, iband_altaostel, ctipo_movto_junk, flagforenviomcjunk,  v_hereda_stat_junk  	
		  into cCanal, cStatusPrev, v_valor, iMotivoOs, iBanderaFaltaOSTEL, cTipoMovto, iFlagForzarEnvioMC, v_hereda_status
          FROM ss_prospecteo_solicitudes 
         WHERE empresa = o_empresa
           and num_solicitud = o_numsol;

		IF  (cCanal is null) then
			LET cCanal = 99;
		END IF;
		   
        -------- Inicia bloque valida reevaluacion prospecteo bancoppel ICM 21/08/2020 
        ---- Se agrega consulta de v_EficienciaCoppel, v_meses y v_SituacionPagoCoppel para solicitudes que requieren reevaluar

        SELECT situacion_pago, meses_historia, puntualidad  
		  INTO v_SituacionPagoCoppel,v_meses,v_puntualidad
          FROM "informix".ss_resum_scor_fin WHERE empresa=o_empresa AND num_solicitud=o_numsol;
		  
		IF v_puntualidad IS NULL THEN 
		 let v_puntualidad = ""; 
		END IF; 
		  
	    IF (v_meses > 0 OR v_SituacionPagoCoppel > 0 OR v_puntualidad <> "" ) AND cCanal = 0  THEN

			UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
				SET estatus = 'F' WHERE empresa=o_empresa AND num_solicitud = o_numsol;
			LET fgst_prosp = 'F';	--IPCB 040920
		END IF;	
		
			SELECT estatus INTO aun_prospecteo 
			FROM bdisolic:"informix".ss_prospecteo_solicitudes
			WHERE empresa=o_empresa AND num_solicitud = o_numsol;
		
		SELECT valor INTO v_EficienciaCoppel
          FROM "informix".ss_param WHERE empresa = o_empresa AND secuencia = 320;

        SELECT situacion_pago,       meses_historia,    origen,      puntualidad ,  
		       situacion_credito,   causa,   vencidoropa, vencidomuebles ,    
			   vencidoprestamos,     abonomensualropa,  abonomensualmuebles,   
			   abonomensualprestamos,saldoropa,         saldomuebles, saldoprestamos, 
			   fecha_ultima_compra, vencidototalaire, abonomensualaire, saldototalaire, vencidototalafiliados,
			   abonomensualafiliados, saldototalafiliados, vencidototalreestructura, abonomensualreestructura, saldototalreestructura, scorepuntualidad
		  INTO v_SituacionPagoCoppel,v_meses,           cOrigenSol,  v_puntualidad ,
		       vsituacion_especial,  vcausa_situacion,  o_vencidoropa,o_vencidomuebles,
			   o_vencidoprestamos ,	 o_abonoropa ,		o_abonomuebles,
			   o_abonoprestamos ,   o_saldoropa ,		o_saldomuebles ,o_saldoprestamos ,
			   o_ultimacompra, o_vencidoaire, o_abonoaire, o_saldoaire, o_vencidoafiliados,
			   o_abonoafiliados, o_saldoafiliados, o_vencidoreestructura, o_abonoreestructura, o_saldoreestructura, iScorePuntualidad
          FROM "informix".ss_resum_scor_fin WHERE empresa=o_empresa AND num_solicitud=o_numsol;
		  
		select numcte_ref, trim(nombre1) ||' ' || trim(nombre2) ||' ' || trim(apell_paterno) ||' ' || trim(apell_materno), rfc 
		into vlClienteRef, vlNombre, cRFC_Cte
		from bdinteg:si_cliente 
		where numcte = v_cliente;
		   
		LET v_SituacionPagoCoppel = NVL(v_SituacionPagoCoppel,0);
		
		IF v_SituacionPagoCoppel <> 0 then  
			CALL "informix".situacion_pago_tienda_cjunk_precal(o_empresa, v_cliente,sNum_producto,v_sucursal,
				user, decode(v_SituacionPagoCoppel,0,-1,v_SituacionPagoCoppel) ,vsituacion_especial,vcausa_situacion,vlClienteRef,vlNombre,vlNombre,
				v_meses,o_vencidomuebles ,o_vencidoropa    ,o_vencidoprestamos ,o_abonomuebles	 ,
				o_abonoropa ,o_abonoprestamos ,o_saldomuebles ,o_saldoropa ,o_saldoprestamos ,o_ultimacompra   )
				RETURNING scod_ret, vMensaje;		  
			IF scod_ret <> '000' THEN 
				let vValidaSPTienda ='F'; 
				LET scod_ret = '000'; 
			END IF;
		END IF;	   
		
      IF aun_prospecteo = 'A'	THEN	        -------- Finaliza bloque valida reevaluacion prospecteo bancoppel ICM 21/08/2020 	  
		IF (cStatusSol2 <> 'PC' and cCanal = 0) THEN
			IF (cStatusSol2 = 'PA') THEN
				IF (cStatusPrev = 'EE') THEN
					INSERT INTO "informix".ss_solicitud_os
					(empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, motivo_os)
					VALUES
					(o_empresa, o_numsol, v_hoy, "S", "sistema", iMotivoOs);
					SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = cStatusPrev; 
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusPrev,"", vMensajeStatus) INTO p_cod_ret;
						-- dap 26-12-2019 se cambia variable VNuevoStatus a cStatusPrev en el insert 
				ELIF (cStatusPrev = 'MC') then
					INSERT INTO "informix".ss_solicitudes_mc (empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,motivo_os,ostel,tipo_alta,status_hereda,prioridad)																																										  
					VALUES (o_empresa,o_numsol,v_cliente,v_sucursal,sNum_producto, v_valor, cStatusPrev,'','','','Cliente Nuevo',CURRENT,CURRENT,CURRENT,'N',iMotivoOs,iBanderaFaltaOSTEL,cTipoMovto,v_hereda_status,iFlagForzarEnvioMC);
					SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = cStatusPrev; 
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusPrev,"", vMensajeStatus) INTO p_cod_ret;
				ELSE
					LET VNuevoStatus=cStatusPrev;
					SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = cStatusPrev; 
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusPrev,"", vMensajeStatus) INTO p_cod_ret;
				END IF;
			END IF;
			RETURN scod_ret;
		END IF;
      END IF;
			  	

		--RGH 21052020
		IF ((cStatusSol2 = 'BC' OR cStatusSol2 = 'CC') and cCanal = 0) THEN
			RETURN scod_ret;
		END IF;
		--RGH 21052020

		IF  (cCanal = 4 and cStatusPrev  <> '' and vValidaSPTienda <> 'F' ) THEN		
			IF (cStatusSol2 = 'IN') THEN
		        LET cStatusPrev ='MC';
				LET VNuevoStatus=cStatusPrev;	
				INSERT INTO "informix".ss_solicitudes_mc (empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,motivo_os,ostel,tipo_alta,status_hereda,prioridad)																																										  
				VALUES (o_empresa,o_numsol,v_cliente,v_sucursal,sNum_producto, v_valor, VNuevoStatus,'','','','Cliente Nuevo',CURRENT,CURRENT,CURRENT,'N',iMotivoOs,iBanderaFaltaOSTEL,cTipoMovto,v_hereda_status,iFlagForzarEnvioMC);

				SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = cStatusPrev; 
			        EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusPrev,"", vMensajeStatus) INTO p_cod_ret;
			ELIF (cStatusSol2 = 'PA') THEN
			        LET cStatusPrev ='AT';
				SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = cStatusPrev; 
			        EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusPrev,"", vMensajeStatus) INTO p_cod_ret;
			END IF;
            RETURN scod_ret;	                       	
		END IF;
		
        --- Valida que no exista 2 solicitudes en proceso de PP
        SELECT count(*)
        INTO cCuentaPP
		FROM bdisolic:"informix".ss_solicitudes 
		where empresa = o_empresa 
        AND numcte = v_cliente
   	    AND num_producto in (SELECT num_producto FROM bdicred:sd_definicion WHERE familia IN ('002','003') AND num_producto NOT IN ('6400','7800'))
        --AND num_producto in ('6300','7700','7600','6800','7100')
		AND status_solicitud IN ('AT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','PA')
		and num_solicitud <> o_numsol
		AND fecha_insert = today;			 

        --IF (cCuentaPP >= 1) AND (sNum_producto IN ('6300','7700','7600','6800','7100')) THEN
		--RQM 10 1177 Se contempla condicion por familia descartando los productos que no apliquen
		IF (cCuentaPP >= 1) AND (cfamilia IN ('002','003') AND sNum_producto NOT IN ('6400','7800')) THEN
            LET cCausa_sol = 'PPD';
            LET cStatusSol = 'RT';
            LET vMensaje='Mas de un tramite de prestamo personal por dia';
				
            EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje ) INTO p_cod_ret;

            IF p_cod_ret <> '000000' THEN
                LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                RETURN scod_ret;
            END If;
            RETURN scod_ret;
        END IF;
            
            
        --- Valida que no exista 2 solicitudes en proceso de PP

        ----------------------------------------------------------------------------------------------------------
        --- Inicio validacion parametrico completo en sucursal
            -- Valida que la solicitud tenga todas las preguntas completas del parametrico.
        IF (nvl(cStatusPrev,'') ='' ) then 

        SELECT {+ INDEX (bdisolic:ss_scoring_grupo)} count(*) INTO sNumGpos FROM bdisolic:ss_scoring_grupo WHERE seccion = 2 AND mostrar_pantalla = '1';

        SELECT {+USE_HASH (gp/build)} count(gp.grupo) INTO sNumPregSol
          FROM bdisolic:ss_detalle_scoring det, bdisolic:ss_scoring_grupo gp 
         WHERE det.empresa = gp.empresa AND det.seccion = gp.seccion AND det.grupo = gp.grupo AND det.empresa = o_empresa 
           AND det.seccion = '2' AND det.num_solicitud = o_numsol AND gp.mostrar_pantalla = '1' AND gp.grupo IN (
            Select {+ INDEX (bdisolic:ss_scoring_grupo)} grupo from bdisolic:ss_scoring_grupo where seccion = 2 and mostrar_pantalla = '1');     

		IF vCanalSol in ('1','3','5') THEN
			LET sStatCNIncomAux = 1;
		ELSE
			LET sStatCNIncomAux = 0;
		END IF;	
		
        IF ((sNumPregSol != (sNumGpos - sStatCNIncomAux)) OR	   -- Cuestionario de solicitud en sucursal no tiene todas las preguntas, segun lo esperado en central 
		   (select count(*) from bdisolic:ss_detalle_scoring det where det.empresa = o_empresa
			 and det.seccion = '2' and det.num_solicitud = o_numsol )  != (sNumGpos - sStatCNIncomAux) )  THEN

            IF (NVL((select grupo from bdisolic:ss_detalle_scoring where empresa = o_empresa and seccion = '2' and grupo = 39 and tpo_persona = '01'
                                       and num_solicitud = o_numsol),0) != 0) THEN -- Validacion provisional si es grupo 39, deje pasar la solicitud

				LET cCausa_sol = 'CPI';
				LET cStatusSol = 'CN';
				LET vMensaje='Cancelacion por parametrico incompleto en sucursal';

				EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje ) INTO p_cod_ret;
				IF NVL(cStatusMov,'') <> '2' THEN						
					UPDATE "informix".ss_solicitudes_movil		
					SET status = '3',--finalizado
					descripcion_status = vMensaje 
					WHERE 	empresa  = o_empresa 
					AND  num_solicitud = o_numsol;
				END IF;
					
				IF p_cod_ret <> '000000' THEN
					LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
					RETURN scod_ret;
				END If;
				RETURN scod_ret;
            END IF;
		END IF;  
        --- Fin validacion parametrico completo en sucursal
       END IF;
        --- INI validacion rechazo por IFE        

		-- Extrae bandera de validacaion de IFE
		SELECT nvl(valor,'')
		  INTO B_valida_ife
		  FROM "informix".ss_param
	  	 WHERE empresa = o_empresa
		   AND secuencia = 376;

        IF (B_valida_ife = '1') THEN
            select nvl(case when upper(resultado) = 'VERDADERO' then '1' else '0' end,'1')
              into B_ife
              from bdinteg:"informix".si_bitacora_ife 
             where numcte = v_cliente and fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte = v_cliente);

            IF ( B_ife <> '1') THEN
                LET cCausa_sol = "RDO";
                LET cStatusSol = 'RT';
                LET vMensaje='Rechazado por estar fuera de politicas';

                EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje ) INTO p_cod_ret;

                IF p_cod_ret <> '000000' THEN
                    LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                    RETURN scod_ret;
                END If;

                IF NVL(cStatusMov,'') <> '' THEN		
                    UPDATE "informix".ss_solicitudes_movil		
                    SET status = '3', descripcion_status = vMensaje 
                    WHERE empresa  = o_empresa 
                    AND  num_solicitud = o_numsol;
                END IF;

                RETURN scod_ret;
            END IF;   
        END IF;   

        --- FIN validacion rechazo por IFE

        ----------------------------------------------------------------------------------------------------------
        --- Inicio validacion Tiempo Estado Civil INCORRECTO para Casados, Union Libre y Solteros.

        SELECT NVL(det3.elemento,-1), NVL(det4.elemento,-1) INTO iElemento_g3, iElemento_g4 
          FROM bdisolic:ss_detalle_scoring det3, bdisolic:ss_detalle_scoring det4
         WHERE det3.empresa = o_empresa AND det3.seccion = 2 AND det3.grupo = 3 AND det4.empresa = o_empresa AND det4.seccion = 2 AND det4.grupo = 4 
           AND det3.num_solicitud = det4.num_solicitud AND det3.num_solicitud = o_numsol; 

        -- Valida a SOLTEROS cuyo tiempo edo civil, es diferente a no aplica.
        IF iElemento_g3 = 1 THEN -- AND iElemento_g4 != 76 THEN
            UPDATE bdisolic:ss_detalle_scoring SET elemento = 76 WHERE empresa = o_empresa AND seccion = 2 and num_solicitud = o_numsol and grupo = 4;
            UPDATE bdisolic:ss_detalle_scoring SET elemento = 12 WHERE empresa = o_empresa AND seccion = 2 and num_solicitud = o_numsol and grupo = 41;

                                -- Valida a CASADOS o UNION LIBRE, su valor en tiempo edo civil, sea diferente a NO APLICA ==> SE CANCELA solicitud
        --ELIF iElemento_g3 in (2,3,6,7) AND iElemento_g4 = 76 THEN
        ELIF iElemento_g3 in (6,7) AND iElemento_g4 = 76 THEN
            LET cCausa_sol = 'CTI';
            LET cStatusSol = 'CN';
            LET vMensaje='Cancelacion por Tiempo Edo Civil incorrecto en parametrico';

            EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje ) INTO p_cod_ret;
            IF NVL(cStatusMov,'') <> '2' THEN						
                UPDATE "informix".ss_solicitudes_movil SET status = '3', descripcion_status = vMensaje WHERE empresa = o_empresa AND num_solicitud = o_numsol;
            END IF;

            IF p_cod_ret <> '000000' THEN
                LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                RETURN scod_ret;
            END If;
            RETURN scod_ret;
        END IF;

        ----------------------------------------------------------------------------------------------------------

	--IF sNum_producto IN ('6001', '6600','6500') THEN--SE VALIDA QUE EL PRODUCTO SEA TDC COPPEL, BCPL BASICA O VISA
		IF v_rechazo = "1" THEN--SE VALIDA QUE EL PRODUCTO SEA TDC COPPEL, BCPL BASICA O VISA

		--Se optiene el numero de cliente para validar si esta excepto de validacion RGC 
			
			--IF NOT EXISTS (SELECT {+INDEX("informix".ss_clientes_exentos_rgc)} numcte 
							--FROM bdisolic:"informix".ss_clientes_exentos_rgc WHERE numcte = v_cliente ) THEN
				--LET cBandera = '0';
			--ELSE 
			
				SELECT activo 
				 INTO cActivo 
				 FROM  bdisolic:"informix".ss_clientes_exentos_rgc
				 WHERE numcte = v_cliente AND secuencia IN(SELECT {+INDEX("informix".ss_clientes_exentos_rgc)}  
				 MAX(secuencia) FROM bdisolic:"informix".ss_clientes_exentos_rgc WHERE numcte = v_cliente);
			 
				--LET cBandera = '1' ;
			 
			--END IF;
		
			IF NVL (cActivo,'S') =  'N' THEN 
		
				SELECT ticket 
				INTO cTicket
				FROM bdinteg:"informix".si_huella_linea  -- SE OBTIENE EL TICKET CON EL NUM. DE CLIENTE
				WHERE numcte = v_cliente;	
			
				IF NVL(cTicket,"") = '' THEN -- SI NO SE ENCUENTRA EN LA si_huella_linea SE BUSCA EN si_huella_linea_hist
					SELECT ticket 
					INTO cTicket
					FROM bdinteg:"informix".si_huella_linea_hist a   
					WHERE numcte = v_cliente								 
						AND fecha_consulta = (SELECT MAX(fecha_consulta)
											  FROM bdinteg:"informix".si_huella_linea_hist b 
											  WHERE   numcte = v_cliente)
						AND secuencia = (SELECT MAX(secuencia)
										 FROM bdinteg:"informix".si_huella_linea_hist c 
										 WHERE  numcte = v_cliente);
				END IF;
		
				IF NVL(cTicket,"") <> "" THEN   -- CON EL TICKET SE VALIDA QUE LA HUELLA NO CORRESPONDA A EMPLEADOS 
			
					 SELECT LIMIT 1 estado_proceso, num_mensaje, empresa 
					 INTO cEdo_proceso, cNum_men, cEmpresa
					 FROM bdinteg:"informix".si_huella_linea_resultado 
					 WHERE ticket = cTicket
						 AND estado_proceso = '2'
						 AND empresa IN (0,1,2,3)
						 AND num_mensaje = "602";
					 
					IF 	NVL(cEdo_proceso,"") <> "" AND NVL(cNum_men,"") <> ""  AND 	NVL(cEmpresa,"") <> "" THEN
					
					--IF sNum_producto <> '6400' or (sNum_producto = '6400' and cEmpresa <> 0) THEN
					--RQM 10 1177 Se contemplan productos de prestamos y linea de credito diferentes de nomina
						IF (cfamilia IN ('001','003') and ctipo_nomina <> 'S') or (sNum_producto = '6400' and cEmpresa <> 0) THEN
						--IF sNum_producto NOT IN ( '6400','7800','8500') or (sNum_producto = '6400' and cEmpresa <> 0) THEN
							-- SE ACTUALIZA EL ESTADO DE LA SOLICITUD
							EXECUTE PROCEDURE "informix".sp_actualiza_status_sol
							('001', 'sistema',o_numsol, 'CN','CGC', 'Cancelado por ser empleado de Grupo Coppel')
                            --Se aÃÂ±ade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC.
							/**('001', 'sistema',o_numsol, 'RT','RGC', 'Rechazo por ser Empleado del Grupo Coppel')**/
							INTO p_cod_ret;	

                        -- OCURRIu UN ERROR AL EJECUTAR EL PROCEDIMIENTO SP_ACTUALIZA_STATUS_SOL
							IF p_cod_ret <> '000000' THEN
								LET scod_ret= '00004'; 
								RETURN scod_ret;
							END IF;

							IF NVL(sNum_producto,"") = '6500' THEN -- SI LA SOL. ES DE COPPEL SE ACTUALIZA
								-- LA SITUACION ESPECIAL Y SU CAUSA
								UPDATE "informix".ss_resum_scor_fin
								SET situacion_especial = 'P',
									causa_situacion = 23
								WHERE empresa = o_empresa  
									AND num_solicitud = o_numsol;						
							END IF;								
                            RETURN scod_ret;								
						END IF;
					END IF;    
				END IF;
			END IF;
		END IF;			
		
		IF sNum_producto ='7800' THEN --RQM 10 617
			-- Extrae Valor de Parametro de ingreso valido para adn
			SELECT valor
			INTO dMontoMin
			FROM "informix".ss_param
			WHERE empresa = o_empresa
			AND secuencia = 383;

			IF o_ingreso < dMontoMin THEN--dejar parametriado
					--obtener la cuenta ligada al credito				 
				SELECT movil_cuenta
				INTO cTelCel
				FROM "informix".ss_adn_solicitudcuenta
				WHERE empresa = o_empresa
				AND numcte  =  v_cliente;
				
					LET cCausa_sol = "ADN";
					LET cStatusSol = 'RT';
					LET vMensaje='Anticipo de Nomina - Monto minimo de ingreso';
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje ) INTO p_cod_ret;
					--?Tu solicitud del Anticipo de Nomina no concluyo satisfactoriamente, acude a tu sucursal BanCoppel para que te expliquemos el motivo ?.
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_3' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO p_cod_ret;				
					
					
				UPDATE "informix".ss_adn_solicitudcuenta
					SET num_solicitud = ''				
				WHERE numcte =v_cliente;
	
					RETURN scod_ret;
			END IF ;

		END IF;
		
		
		
		-- ********************************
		-- Inserta Referencias Personales *
		-- ********************************		
		SELECT num_parametrico
		INTO v_mod_parame
		FROM "informix".ss_control_parametricos
		WHERE empresa = o_empresa
			AND num_producto = sNum_producto
			AND sucursal = v_sucursal;

		IF v_mod_parame IS NULL THEN
			LET scod_ret= '00136'; -- no se tiene dato de que modelo aplicar para calificar el dato
			RETURN scod_ret;
		END IF;

		UPDATE "informix".ss_solicitudes
		SET tipo_calculo=v_mod_parame,
		   monto_solicitado = o_importe_sol
		WHERE empresa = o_empresa
			AND num_solicitud = o_numsol;
		-- ********************************
		--   Actualiza Datos del Cliente  *
		-- ********************************

		SELECT MAX(NVL((CASE WHEN a.grupo=7 THEN elementobase END),"")),
			   MAX(NVL((CASE WHEN a.grupo=22 THEN elementobase END),""))
		INTO v_profesion,v_habitdomi
		FROM "informix".ss_detalle_scoring a,
			 "informix".ss_scoring_element b
		WHERE a.empresa=b.empresa
			AND a.empresa=o_empresa
			AND a.num_solicitud=o_numsol
			AND a.grupo=b.grupo
			AND a.elemento=b.elemento
			AND activa=1
			AND a.grupo IN (7,22);

		IF v_habitdomi IS NOT NULL OR v_habitdomi<>"" THEN
			UPDATE bdinteg:"informix".si_cliente
			SET string2=v_habitdomi
			WHERE numcte=v_cliente;
		END IF;

		/*IF v_profesion IS NOT NULL OR v_profesion<>"" THEN
			UPDATE bdinteg:"informix".si_ctepf
			SET profesion=v_profesion
			WHERE numcte=v_cliente;
		END IF;*/
		
		SELECT estado_civil,TRIM(habita_en),TRIM(profesion), DECODE ( TRIM(habita_en), 'P' ,5,'R',8,'F',7,'H',9,'G',6,'D',10), NVL(sexo,"I"), fecha_nac, escolaridad
		INTO vedocivil,v_habita_en,v_profesion, vElementohabita_en,cSexo, dFechaNac, cEscolaridad
		FROM bdinteg:"informix".si_ctepf
		WHERE empresa = o_empresa
			AND numcte = v_cliente;
					
		SELECT descripcion 	INTO vescolaridad_des FROM bdinteg:si_escolaridad_am WHERE elemento = cEscolaridad;	
		LET cSexoBitDet = cSexo;
		UPDATE "informix".ss_detalle_scoring
		SET elemento = vElementohabita_en
		WHERE empresa =  o_empresa
			AND seccion = 2
			AND grupo =5
			AND num_solicitud = o_numsol;					

		IF v_mod_parame='1' THEN
			-- **********************************************************
			-- Incorpora Grupo 12 (ciudad) de acuerdo a dato del cliente*
			-- **********************************************************							
			SELECT estado, ciudad, numerociudad
			INTO vEstadoCte, vCiudadCte, v_CiudadCoppelCte
			FROM bdinteg:"informix".si_direcciones_actual a
			WHERE a.empresa = o_empresa				
				AND a.numcte = v_cliente
				AND a.tipo_dir = "1";

			-- Se reclasifican los siguientes estados o ciudades
			-- Edo. de Mexico ( Edo.15), Guerrero( Edo.12), Torreon( Cd 047 Edo. 05), Edo de Sinaloa (Edo. 25)
			IF vEstadoCte IN ('15','12') OR (vCiudadCte= '047' AND vEstadoCte= '05') THEN
			   LET vTpCiudad = "7";
			ELIF vEstadoCte= '25' THEN
			   LET vTpCiudad = "8";
			ELSE
				SELECT tipo_ciudad
				INTO vTpCiudad
				FROM bdinteg:"informix".si_ciudades
				WHERE estado = vEstadoCte
					AND ciudad = vCiudadCte;

				IF vTpCiudad IS NULL THEN
					LET vTpCiudad = "0";
				END IF;

				IF vTpCiudad = "1" THEN
				   LET vTpCiudad= "8";
				ELIF vTpCiudad = "2" THEN
				   LET vTpCiudad= "9";
				ELIF vTpCiudad = "3" THEN
				   LET vTpCiudad= "10";
				ELIF vTpCiudad = "4" THEN
				   LET vTpCiudad= "7";
				ELIF vTpCiudad IN("5","6") THEN
				   LET vTpCiudad= "11";
				ELSE
				   LET vTpCiudad= "0";
				END IF;
			END IF;

			SELECT valor
			INTO v_valor
			FROM "informix".ss_scoring_pesos
			WHERE empresa = o_empresa
				AND tp_solicitud = v_tpsol -- "T"
				AND grupo = 12
				AND elemento = vTpCiudad
				AND seccion = 2
				AND tpo_persona = "01";

			IF v_valor IS NULL THEN
				LET v_valor = 0;
			END IF

			INSERT INTO  "informix".ss_detalle_scoring
					(empresa, seccion, grupo, elemento, tpo_persona, num_solicitud, valor)
			VALUES  (o_empresa, 2, 12, vTpCiudad, "01", o_numsol, v_valor);

			-- ****************************************************************************
			--  Incorpora Grupo 23 (Antiguedad de la Plaza y Nivel de Vencido        *
				--  de acuerdo a la Ciudad del Cliente.                                                           *
			-- ****************************************************************************
			-- Se obtiene el porcentaje o nivel de vencido y la antiguedad de la plaza
			-- dependiendo de la ciudad del cliente.

			LET  v_ValorCdCoppel= "0";

			IF v_CiudadCoppelCte <> 0 THEN

				SELECT {+INDEX("informix".ss_scoring_porcentajes_ciudad idx_ss_scoring_porcentajes_ciudad)} porcentajevencido, nvl(fechaaperturaplaza, '01-01-1900'::DATE)
				INTO v_Porcentaje, v_FechaAntiguedad
				FROM "informix".ss_scoring_porcentajes_ciudad
				WHERE numerociudad=v_CiudadCoppelCte;

				IF v_Porcentaje IS NULL THEN
					Let v_Porcentaje = 0;
				END IF;

				-- se realiza el calculo de anios cumplidos
				IF v_FechaAntiguedad <> '01-01-1900'::DATE THEN
					LET v_Diferencial = 0;
					IF DAY( v_hoy) = DAY( v_FechaAntiguedad) AND MONTH( v_hoy) = MONTH( v_FechaAntiguedad) THEN
						Let v_Diferencial = mod(YEAR( v_hoy) - YEAR( v_FechaAntiguedad), 4) * 0.25;
					END IF;
					LET v_anios = (( v_hoy -  v_FechaAntiguedad)+ v_Diferencial )/ 365.25;
					IF v_anios  IS NULL THEN
						Let v_anios = 0;
					END IF;
				ELSE
					LET v_anios=0;
				END IF;

				IF v_anios = 0 AND v_Porcentaje= 0 THEN
					LET v_ValorCdCoppel= "1";
				ELSE
					LET v_Porcentaje= ROUND(v_Porcentaje,2);
				END IF;
			ELSE
				LET v_ValorCdCoppel= "1";
			END IF;

			-- Se obtiene el grupo, elemento, seccion
			IF v_ValorCdCoppel= "1" THEN
				LET v_Grupo_Cd= 23;
				LET v_Elemento_Cd= 31;
				LET v_Seccion_Cd= 2;
			ELSE
				SELECT {+INDEX("informix".ss_scoring_ciudad)} grupo, elemento, seccion
				INTO v_Grupo_Cd, v_Elemento_Cd, v_Seccion_Cd
				FROM "informix".ss_scoring_ciudad
				WHERE (min_antiguedad_plaza <= v_anios AND max_antiguedad_plaza >=v_anios)
				  AND (min_nivel_vencido <=v_Porcentaje AND max_nivel_vencido >= v_Porcentaje);
			END IF;

		-- Se obtiene el peso o valor de la seccion a la cual hace referencia la ciudad.
			SELECT nvl(valor,0)
			INTO v_Valor_Cd
			FROM "informix".ss_scoring_pesos
			WHERE empresa = o_empresa
				AND tp_solicitud = v_tpsol -- "T"
				AND grupo = v_Grupo_Cd
				AND elemento = v_Elemento_Cd
				AND seccion = v_Seccion_Cd
				AND tpo_persona = "01";

			IF v_Valor_Cd IS NULL THEN
				LET v_Valor_Cd= 0;
			END IF;

			INSERT INTO  "informix".ss_detalle_scoring
					(empresa, seccion, grupo, elemento, tpo_persona, num_solicitud, valor)
			VALUES  (o_empresa, v_Seccion_Cd, v_Grupo_Cd, v_Elemento_Cd, "01", o_numsol, nvl(v_Valor_Cd,0));
		END IF;
		-- **************************************************************************
		-- Incorpora Grupo 20 (Ingresos de Cliente) de acuerdo a dato del cliente   *
		-- **************************************************************************
		-- Extrae Valor de Parametro
		SELECT valor
		INTO v_SalarioMinimoCoppel
		FROM "informix".ss_param
		WHERE empresa = o_empresa
			AND secuencia = 303;

		IF v_SalarioMinimoCoppel IS NULL THEN
			LET v_SalarioMinimoCoppel= 0;
		END IF;
		-- Se calcula el numero de Salarios Minimos Coppel que el cliente percibe.
		IF v_SalarioMinimoCoppel >= 0 Then
			LET v_NumSalariosMinimos= ROUND((o_ingreso / v_SalarioMinimoCoppel),2);
		ELSE
			LET v_NumSalariosMinimos= 0;
		END IF;
		-- Actualiza el numero de salarios minimos que corresponden al ingreso mensual del cliente
		UPDATE "informix".ss_resum_scor_fin
		SET smbc = v_NumSalariosMinimos
		WHERE empresa = o_empresa
			AND num_solicitud = o_numsol;

		SELECT {+INDEX("informix".ss_scoring_element idx_ss_scoring_element)} MAX(rango_maximo)
		INTO mRango_max
		FROM "informix".ss_scoring_element
		WHERE empresa = o_empresa
			AND grupo = 20
			AND seccion = 2
			AND tpo_persona = '01';

		IF v_NumSalariosMinimos > mRango_max THEN
			LET v_NumSalariosMinimos = mRango_max;
		END IF;
		
		--se agrega validacion para identificar si el cliente presenta una ocupacion de riesgo. que se validara posteriormente
		SELECT claveopcionpuesto,clavesubopcionpuesto,sec_ingreso
		INTO iAct,iSubAct,iSecuencia
		FROM bdinteg:"informix".si_ingresos a
		WHERE a.numcte = v_cliente
			AND a.tipo_ingreso='T'
			AND a.sec_ingreso= (SELECT MAX (sec_ingreso)
								FROM bdinteg:"informix".si_ingresos b
								WHERE b.numcte=a.numcte
									AND b.tipo_ingreso='T');
		--se actualiza la maxima secuencia del cliente en la tabla si_ingresos.
		UPDATE bdinteg:"informix".si_ingresos
		SET ingreso_mensual = o_ingreso
		WHERE empresa = o_empresa
			AND numcte = v_cliente
			AND tipo_ingreso='T'
			AND sec_ingreso= iSecuencia;

        -- Se agrega consulta de v_EficienciaCoppel, v_meses y v_SituacionPagoCoppel para solicitudes grupo 4
        /*SELECT valor INTO v_EficienciaCoppel
          FROM "informix".ss_param WHERE empresa = o_empresa AND secuencia = 320;

        SELECT situacion_pago,       meses_historia,    origen,      puntualidad ,  
		       situacion_credito,   causa,   vencidoropa, vencidomuebles ,    
			   vencidoprestamos,     abonomensualropa,  abonomensualmuebles,   
			   abonomensualprestamos,saldoropa,         saldomuebles,saldoprestamos, 
			   fecha_ultima_compra
		  INTO v_SituacionPagoCoppel,v_meses,           cOrigenSol,  v_puntualidad ,
		       vsituacion_especial,  vcausa_situacion,  o_vencidoropa,o_vencidomuebles,
			   o_vencidoprestamos ,	 o_abonoropa ,		o_abonomuebles,
			   o_abonoprestamos ,   o_saldoropa ,		o_saldomuebles ,o_saldoprestamos ,
			   o_ultimacompra
          FROM "informix".ss_resum_scor_fin WHERE empresa=o_empresa AND num_solicitud=o_numsol;
		  
		select numcte_ref, trim(nombre1) ||' ' || trim(nombre2) ||' ' || trim(apell_paterno) ||' ' || trim(apell_materno), rfc 
		into vlClienteRef, vlNombre, cRFC_Cte
		from bdinteg:si_cliente 
		where numcte = v_cliente;
		   
		LET v_SituacionPagoCoppel = NVL(v_SituacionPagoCoppel,0);
		
		IF v_SituacionPagoCoppel <> 0 then  
			CALL "informix".situacion_pago_tienda_cjunk(o_empresa, v_cliente,sNum_producto,v_sucursal,
				user, decode(v_SituacionPagoCoppel,0,-1,v_SituacionPagoCoppel) ,vsituacion_especial,vcausa_situacion,vlClienteRef,vlNombre,vlNombre,
				v_meses,o_vencidomuebles ,o_vencidoropa    ,o_vencidoprestamos ,o_abonomuebles	 ,
				o_abonoropa ,o_abonoprestamos ,o_saldomuebles ,o_saldoropa ,o_saldoprestamos ,o_ultimacompra   )
				RETURNING scod_ret, vMensaje;		  
			IF scod_ret <> '000' THEN 
				let vValidaSPTienda ='F'; 
				LET scod_ret = '000'; 
			END IF;
		END IF;*/

		SELECT descrip INTO  vAct_Sub FROM bdinteg:"informix".si_actsubact	WHERE id_act= iAct AND   id_subact= iSubAct;

	   --mahr-cnbv  
		UPDATE bdisolic:"informix".ss_revision_determinacion 
		   SET saldoropa = o_saldoropa, saldomuebles = o_saldomuebles, saldoprestamo = o_saldoprestamos, vencidoropa = o_vencidoropa,
			   vencidomuebles = o_vencidomuebles, vencidoprestamos = o_vencidoprestamos, abonomensualropa = o_abonoropa, 
			   abonomensualmuebles = o_abonomuebles, abonomensualprestamos = o_abonoprestamos,  fecha_nacimiento = dFechaNac, profesion = v_profesion,
			   sexo = cSexoBitDet, escolaridad = cEscolaridad, edo_civil = vedocivil, rfc = cRFC_Cte,actividad = iAct, subactividad = iSubAct, actividad_descrip = vAct_Sub,
			   vencidototalaire = o_vencidoaire, abonomensualaire = o_abonoaire, saldototalaire = o_saldoaire, vencidototalafiliados = o_vencidoafiliados, abonomensualafiliados = o_abonoafiliados,
			   saldototalafiliados = o_saldoafiliados, vencidototalreestructura = o_vencidoreestructura, abonomensualreestructura = o_abonoreestructura, saldototalreestructura = o_saldoreestructura, scorepuntualidad = iScorePuntualidad
		WHERE empresa = o_empresa AND num_solicitud = o_numsol;
		-- Fin caja unica. Viridiana
		IF v_mod_parame='1' THEN
			SELECT {+INDEX("informix".ss_scoring_element idx_ss_scoring_element)} elemento
			INTO v_Elemento_smc
			FROM "informix".ss_scoring_element
			WHERE grupo= 20
				AND seccion= 2
				AND tpo_persona = "01"
				AND (rango_minimo <= v_NumSalariosMinimos AND rango_maximo >=v_NumSalariosMinimos);

			-- Se obtiene el peso asigado para el Numero de Salarios Minimos Coppel.
			SELECT valor
			INTO v_Valor_smc
			FROM "informix".ss_scoring_pesos
			WHERE empresa = o_empresa
				AND tp_solicitud = v_tpsol --"T"
				AND grupo = 20
				AND elemento = v_Elemento_smc
				AND seccion = 2
				AND tpo_persona = "01";

			IF v_Valor_smc IS NULL THEN
				LET v_Valor_smc= 0;
			END IF;
			
			INSERT INTO  "informix".ss_detalle_scoring
					(empresa, seccion, grupo, elemento, tpo_persona, num_solicitud, valor)
			VALUES  (o_empresa, 2 , 20, v_Elemento_smc, "01", o_numsol, v_Valor_smc);

			--ini CAS se hace una precalificacion para validar si se hace la consulta a circulo y a buro
			EXECUTE PROCEDURE "informix".calculo_parametrico(o_numsol)
			INTO v_valor_2s;

			IF  v_valor_2s IS NULL THEN
				LET  v_valor_2s= 0; -- No se localizaron puntos a sumar para la seccion 2
			END IF;

			/*-- Se agrega validacion para filtrar clientes "Z" INI 
			SELECT situacion_pago,meses_historia,origen, puntualidad  
			INTO v_SituacionPagoCoppel,v_meses,  cOrigenSol, v_puntualidad 
			FROM "informix".ss_resum_scor_fin
			WHERE empresa=o_empresa
				AND num_solicitud=o_numsol;*/


			IF v_puntualidad IS NULL THEN 
				let v_puntualidad = ""; 
			END IF; 

			-- Se agrega validacion para filtrar clientes "Z" FIN 
			--clientes coppel sin compras se le da tratamiento de cliente nuevo
			IF v_SituacionPagoCoppel < 0 THEN
				LET v_meses = 0;
				LET v_SituacionPagoCoppel = 0;
			END IF;

			SELECT valor
			INTO v_meses_hist
			FROM "informix".ss_param
			WHERE empresa = o_empresa
				AND secuencia = 308;

			/*SELECT valor
			INTO v_EficienciaCoppel
			FROM "informix".ss_param
			WHERE empresa = o_empresa
				AND secuencia = 320;*/

			FOREACH  SELECT  {+INDEX("informix".ss_scoring_seccion)} DISTINCT(a.seccion)
				INTO v_seccion
				FROM "informix".ss_scoring_solic a, "informix".ss_scoring_seccion b
				WHERE a.empresa = o_empresa
					AND a.tp_solicitud = v_tpsol
					AND b.empresa = a.empresa
					AND b.seccion = a.seccion
					AND b.automatico = "0"
					AND a.activa = '1'
			END FOREACH

			SELECT COUNT(seccion)
			INTO v_cuantos
			FROM "informix".ss_scoring_solic
			WHERE empresa = o_empresa
				AND tp_solicitud = v_tpsol
				AND seccion = v_seccion
				AND (v_valor_2s >= evaluacion_min)
				--AND  v_valor <= evaluacion_max)
				AND (min_porc_pago <= v_SituacionPagoCoppel
				AND max_porc_pago >= v_SituacionPagoCoppel)
				AND (min_mes_hist <= v_meses
				AND max_mes_hist >= v_meses)
				AND activa = '1';
		END IF;

		--	se validan las actividad del cliente que se obtuvo previamente
		--JMAH Se realiza homologacion con ajustes paso 5
		SELECT altoriesgocred,altoriesgocredcp,situacion_especial,causa_situacion 
		  INTO vRiesgoBco,vRiesgoCop,cSitEsp,iCausaSitEsp 
		  FROM bdinteg:"informix".si_actsubact
		 WHERE id_act= iAct
		   AND   id_subact= iSubAct;
		
		IF vRiesgo IS NULL THEN
			LET vRiesgo = 0;
		END IF;
		
		IF vRiesgoBco IS NULL THEN
			LET vRiesgoBco = 0;
		END IF;
		
		IF vRiesgoCop IS NULL THEN
			LET vRiesgoCop = 0;
		END IF;

		IF (v_tpsol = 'C' AND vRiesgoCop = 1) OR (v_tpsol <> 'C' AND vRiesgoBco = 1) THEN
			LET vRiesgo = 1;
		END IF;
		
		IF NVL(cSitEsp,"") <> "" AND  v_tpsol = "C" THEN
			IF iBanderaSitEsp = 0 THEN
				UPDATE "informix".ss_resum_scor_fin
				SET situacion_especial = cSitEsp,
					causa_situacion = iCausaSitEsp
				WHERE empresa = o_empresa
					AND num_solicitud = o_numsol;
					LET iBanderaSitEsp =1;
			END IF;
		END IF;	
					  			
		IF sNum_producto <>'6500' THEN	 					
            IF v_habita_en = 'H' THEN
                LET cCausa_sol = "REV";
                LET vMensaje = 'Rechazado por estar fuera de politicas';
            END IF;        
		
            IF (v_habita_en = 'H' OR v_habita_en = 'D') AND v_tpsol = "C" THEN --situacion_especial P causa 28
                    IF iBanderaSitEsp = 0 THEN
                        UPDATE "informix".ss_resum_scor_fin
                        SET situacion_especial = "P",
                            causa_situacion = 28
                        WHERE empresa = o_empresa
                            AND num_solicitud = o_numsol;
                            LET iBanderaSitEsp =1;
                    END IF;
            END IF;
        ELIF (v_habita_en = 'D') AND v_tpsol = "C" THEN --situacion_especial P causa 28
                    IF iBanderaSitEsp = 0 THEN
                        UPDATE "informix".ss_resum_scor_fin
                        SET situacion_especial = "P",
                            causa_situacion = 28
                        WHERE empresa = o_empresa
                            AND num_solicitud = o_numsol;
                            LET iBanderaSitEsp =1;
                    END IF;
        END IF;
		
-- Se toma el parametro PUNTUALIDAD PARA RECHAZAR CON EFP (EFICIENCIA FUERA DE POLÃÂTICAS
   SELECT valor
   INTO cPuntualidadZ
   FROM bdisolic:"informix".ss_param
   WHERE secuencia= 46;
   
-- Se agrega validacion para filtrar clientes "Z" INI 
--	Se sustituye causa RDO por subcausas para reflejarse en el arbol de solicitudes RQM 04 469
		IF (v_puntualidad = cPuntualidadZ) THEN 
		   LET cCausa_sol = "EFP"; 
		   LET vMensaje='Eficiencia Fuera de PolÃÂ­ticas'; 	
		--ELIF (v_meses > 0)  and (v_SituacionPagoCoppel < v_EficienciaCoppel)  and (v_SituacionPagoCoppel >= 0)  THEN
		/* --Se comenta validacion para que no se contemple asi la puntualidad
		ELIF v_puntualidad != cPuntualidadZ AND v_meses > 0  THEN
		   LET cCausa_sol = "EFC";
		   LET vMensaje='Eficiencia Coppel y meses historia';
		*/
-- Se agrega validacion para filtrar clientes "Z" FIN 
		ELIF v_profesion='6' THEN
		   LET cCausa_sol = "PDE";
		   LET vMensaje='Profesion desempleado';
		ELIF vRiesgo = 1 THEN
		   LET cCausa_sol = "ADR";
		   LET vMensaje='Actividad de Riesgo';
		ELIF v_cuantos IS NULL OR v_cuantos = 0 AND v_mod_parame ='1' AND v_tpsol <> "C" THEN --se quita rechazo para producto coppel
		   LET cCausa_sol = "RS2";
		   LET vMensaje='Puntos acumulados en Scoring fueron insuficientes para su Aprobacion';
		ELIF vValidaSPTienda = 'F' THEN --se quita rechazo para producto coppel
		   LET cCausa_sol = "ACC";
		   LET vMensaje='Atraso en Cuenta Coppel';   
		END IF;

		IF v_tpsol = "C" THEN -- VALIDA SI LA SOLICITUD ES TIPO TIENDA COPPEL  -- Moha
			IF vedocivil <> "C" THEN -- VALIDA QUE ESTADO CIVIL SEA DIFERENTE A CASADO
				LET o_parentesco_1 = TRIM(o_parentesco_1);
				LET o_parentesco_2 = TRIM(o_parentesco_2);
				IF NVL(o_parentesco_1,"") = "" AND NVL(o_parentesco_2,"") = "" AND NVL(cStatusMov,'') = '' AND (cCanal <> 4) THEN
					LET cSinFamiliar = "1";
					LET cCausa_sol = "RFP";
					LET vMensaje = 'Fuera de Politicas de Credito Coppel';
				END IF
			END IF
		END IF			
		
        IF sNum_producto ='6500' THEN						
            IF ((v_cuantos IS NULL OR v_cuantos = 0) AND v_mod_parame ='1') OR  v_profesion='6' OR vRiesgo =1 OR cSinFamiliar = "1" 
                  OR v_puntualidad = "Z" OR vValidaSPTienda = 'F' THEN --OR ( v_meses > 0 and v_puntualidad != cPuntualidadZ ) 
                  
                LET cStatusSol = 'RT';

                EXECUTE PROCEDURE "informix".sp_actualiza_status_sol
                    (o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje )
                INTO p_cod_ret;

                -- Obtiene datos para almacenar en la bitacora de la solicitud
                SELECT {+INDEX (bdicred:"informix".sd_causas_cte_coppel)}
				s.situacion_especial, s.causa_situacion, c.descripcion
                INTO vsituacion_especial,  vcausa_situacion, cDescSitEsp
                FROM bdisolic:"informix".ss_resum_scor_fin s, bdicred:sd_causas_cte_coppel c
                WHERE s.empresa = c.empresa and s.situacion_especial = c.situacion and s.causa_situacion = c.causa
                AND s.empresa = o_empresa AND s.num_solicitud = o_numsol;

                -- Obtiene le numero de reestructuras que ha tenido el cliente
                SELECT nvl(count(a.numcte),0) INTO sReestructCte FROM bdicred:sd_maecredcrd a, bdicred:sd_maecredanexocrd b WHERE a.empresa = b.empresa 
                AND a.num_credito = b.num_credito AND a.num_producto = '6011' AND a.numcte = v_cliente AND a.status_cred = 'FF' AND b.fecha_proceso <= v_hoy;

                EXECUTE PROCEDURE bdinteg:"informix".consedadcte(o_empresa, v_cliente)
                INTO cCodRet, cNomcte, iEdadcte;

                UPDATE bdisolic:"informix".ss_revision_determinacion SET edad = iEdadcte, escolaridad_descrip = vescolaridad_des,situacion_especial = vsituacion_especial, causa_sit_esp = vcausa_situacion, 
                descripcion_siesp = cDescSitEsp, num_reest_cte = sReestructCte, fecha_sol = vfecha_sol, linea_min_prod = dlinea_min_prod
                WHERE empresa = o_empresa AND num_solicitud = o_numsol;
                IF p_cod_ret <> '000000' then
                    LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                    RETURN scod_ret;
                END If;

                UPDATE "informix".ss_autorizacion
                SET revision_cac = 3
                WHERE empresa = o_empresa
                    AND num_solicitud = o_numsol
                    AND status_solicitud = 'RT'
                    AND fecha_entrada = DATE(CURRENT);

                IF NVL(cStatusMov,'') <> '' THEN		
                    UPDATE "informix".ss_solicitudes_movil		
                    SET status = '3',--finalizado
                    descripcion_status = vMensaje 
                    WHERE 	empresa  = o_empresa 
                    AND  num_solicitud = o_numsol;
                END IF;

                RETURN scod_ret;
            END IF;
        ELSE
            IF ((v_cuantos IS NULL OR v_cuantos = 0) AND v_mod_parame ='1') OR v_habita_en='H' OR v_profesion='6' OR vRiesgo =1 OR cSinFamiliar = "1" 
                  OR v_puntualidad = "Z" OR vValidaSPTienda = 'F' THEN --OR ( v_meses > 0 and v_puntualidad != cPuntualidadZ) 
                  
                LET cStatusSol = 'RT';

                EXECUTE PROCEDURE "informix".sp_actualiza_status_sol
                    (o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje )
                INTO p_cod_ret;

                -- Obtiene datos para almacenar en la bitacora de la solicitud
                SELECT {+INDEX (bdicred:"informix".sd_causas_cte_coppel)}
				s.situacion_especial, s.causa_situacion, c.descripcion
                INTO vsituacion_especial,  vcausa_situacion, cDescSitEsp
                FROM bdisolic:"informix".ss_resum_scor_fin s, bdicred:sd_causas_cte_coppel c
                WHERE s.empresa = c.empresa and s.situacion_especial = c.situacion and s.causa_situacion = c.causa
                AND s.empresa = o_empresa AND s.num_solicitud = o_numsol;

                -- Obtiene le numero de reestructuras que ha tenido el cliente
                SELECT nvl(count(a.numcte),0) INTO sReestructCte FROM bdicred:sd_maecredcrd a, bdicred:sd_maecredanexocrd b WHERE a.empresa = b.empresa 
                AND a.num_credito = b.num_credito AND a.num_producto = '6011' AND a.numcte = v_cliente AND a.status_cred = 'FF' AND b.fecha_proceso <= v_hoy;

                EXECUTE PROCEDURE bdinteg:"informix".consedadcte(o_empresa, v_cliente)
                INTO cCodRet, cNomcte, iEdadcte;

                UPDATE bdisolic:"informix".ss_revision_determinacion SET edad = iEdadcte, escolaridad_descrip = vescolaridad_des,situacion_especial = vsituacion_especial, causa_sit_esp = vcausa_situacion, 
                descripcion_siesp = cDescSitEsp, num_reest_cte = sReestructCte, fecha_sol = vfecha_sol, linea_min_prod = dlinea_min_prod
                WHERE empresa = o_empresa AND num_solicitud = o_numsol;
                IF p_cod_ret <> '000000' then
                    LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                    RETURN scod_ret;
                END If;

                UPDATE "informix".ss_autorizacion
                SET revision_cac = 3
                WHERE empresa = o_empresa
                    AND num_solicitud = o_numsol
                    AND status_solicitud = 'RT'
                    AND fecha_entrada = DATE(CURRENT);

                IF NVL(cStatusMov,'') <> '' THEN		
                    UPDATE "informix".ss_solicitudes_movil		
                    SET status = '3',--finalizado
                    descripcion_status = vMensaje 
                    WHERE 	empresa  = o_empresa 
                    AND  num_solicitud = o_numsol;
                END IF;

                RETURN scod_ret;
            END IF;
        END IF;
		-- RQM 09 554																	 
		/*SELECT {+INDEX("informix".ss_status_sol idx_ss_status_sol1)} status_solicitud
						INTO status_consul
						FROM "informix".ss_status_sol
						WHERE empresa=o_empresa
						AND tipo_auto='2';		*/
		
		-- RQM 09 554 ini
		SELECT canal_sol INTO cCanalSol FROM "informix".ss_solicitudes 
		WHERE numcte = v_cliente AND num_solicitud = o_numsol;
		
		SELECT insti1 INTO status_consul FROM "informix".ss_canales_solic WHERE canal_solic = cCanalSol;
		
		IF status_consul = 'CC' THEN
			LET cflujo_cc = '1';
		END IF;
		-- RQM 09 554 fin
		
		/*SELECT {+INDEX("informix".ss_status_sol idx_ss_status_sol1)} tipo_auto,status_solicitud
		INTO orden_consul,status_consul
		FROM "informix".ss_status_sol
		WHERE empresa=o_empresa
			AND tipo_auto='1';*/

		LET vMensaje= 'En consulta '|| status_consul ;
		--IF v_tpsol = "C" THEN --JMAH
		
		--AAME 20150303 RQM 10 550 Se agrega consulta para la obtencion de los productos validos para heredar la informacion de referencias de la solicitud contemplando los nuevos productos de prestamo(7600,7700)
		/*SELECT COUNT(valor)
		INTO iProdMC 
		FROM "informix".ss_param 
		WHERE empresa = o_empresa
		AND secuencia in (150,151,152,153,154)
		AND valor = sNum_producto;	*/
		
		IF sNum_producto IN ('6001', '6300','6500','7600','7700','6800','7100') THEN --JMAH
		--IF iProdMC >=1 THEN	
		--se valida que no existan referencias para el numero de solicitud coppel
			SELECT COUNT (num_solicitud)
			INTO iNumRefs
			FROM bdinteg:"informix".si_refclientes a
			WHERE a.empresa = '001'
			AND a.numcte = v_cliente
			AND num_solicitud = o_numsol ;
			
			IF iNumRefs < 2 THEN 
				 IF iNumRefs = 1 THEN
					LET iContadorRef = iContadorRef+1;
				 END IF;
			
				IF sNum_producto = '6500' THEN --JMAH				
					IF NVL(cNumSolicitud,'') ='' THEN
						LET cNumSolicitud = o_numsol;
					END IF;
				ELSE	
						EXECUTE PROCEDURE "informix".sp_obtienesolicitudherencia
						(o_empresa ,o_numsol,v_cliente)
						INTO cCodret, cNumSolicitud;					
				END IF;
			
			

				--Se obtiene la ultima referencia del cliente, en caso de que tramite banco y coppel , la ultima referencia es de banco
				FOREACH	WITH HOLD
					SELECT sucursal,apell_paterno,apell_materno,nombre1,
						nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,
						pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert, fecha_insert
					INTO cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cRfc,
						dtFechaNac,cCurp,cSexo,cEstadoCivil,cNacionalidad,cNoFm,cCodigoIden,cNumIdentif ,cPersDomicilio,
						cEmail ,cParentesco,cApellCasada,cNumcteRef ,cNumCteBanco,cUsuario ,dtFecha
					FROM bdinteg:"informix".si_refclientes a
					WHERE a.empresa = '001'
					AND a.numcte = v_cliente	
					AND num_solicitud = cNumSolicitud
					ORDER BY secuencia ASC
					
					LET iContadorRef = iContadorRef+1;
					
					IF iContadorRef > 2 THEN
						EXIT FOREACH;
					END IF;
					
					EXECUTE PROCEDURE bdinteg:"informix".sp_refclientes_cjunk
						(o_empresa,"A",o_numsol,v_cliente,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cRfc,
						dtFechaNac,cCurp,cSexo,cEstadoCivil,cNacionalidad,cNoFm,cCodigoIden,cNumIdentif ,cPersDomicilio,
						cEmail ,cParentesco,cApellCasada,cNumcteRef ,cNumCteBanco,cUsuario ,dtFecha,0 )
					INTO cCodret,iSecuencia2;

					LET cSucursal  		= "";
					LET cApellPaterno  	= "";
					LET cApellMaterno  	= "";
					LET cNombre1  		= "";
					LET cNombre2  		= "";
					LET cRfc  			= "";	
					LET dtFechaNac 		= DATE(1);
					LET cCurp  			= "";
					LET cSexo  			= "";
					LET cEstadoCivil  	= "";
					LET cNacionalidad  	= "";
					LET cNoFm  			= "";
					LET cCodigoIden  	= "";
					LET cNumIdentif  	= "";
					LET cPersDomicilio  = "";
					LET cEmail  		= "";
					LET cParentesco  	= "";
					LET cApellCasada  	= "";
					LET cNumcteRef  	= "";
					LET cNumCteBanco 	= "";
					LET cUsuario  		= "";
					LET dtFecha 		= DATE(1);

				END FOREACH;
			END IF;
		END IF;

		IF NVL(sNum_producto,'') <> "7800" THEN
			EXECUTE PROCEDURE "informix".sp_actualiza_status_sol
			(o_empresa, 'sistema',o_numsol, status_consul,cCausa_sol, vMensaje )
			INTO scod_ret;
		END IF
	   --JMAH Se realiza homologacion con ajustes paso 5
		
		--obtiene la edad del cliente --para validar si se consulta a las SICs
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte(o_empresa, v_cliente)
		INTO cCodRet, cNomcte, iEdadcte;

		IF  NVL(iEdadcte,0) < 18 THEN
			LET iBanderaCoppel = 1;
		END IF;

		IF sNum_producto = "7800" THEN
			IF ( cOrigenSol = '1')  THEN
				EXECUTE PROCEDURE "informix".califica_scoring2_cjunk(o_empresa, o_numsol) INTO scod_ret;
			ELSE
				CALL "informix".califica_scoring2(o_empresa, o_numsol) RETURNING scod_ret;
			END IF;
		END IF;
		
		IF iBanderaCoppel = 0 AND sNum_producto <> "7800" THEN --JMAH Solicitudes de Anticipo  no pasan a Buro:
--			IF cSexo = "I"  THEN --JMAH Solicitudes de Anticipo  no pasan a Buro:
			------obtencion del parametro de dias de vigencia de consultas SIC --JMAH
			SELECT valor
			INTO iDiasVigencia
			FROM "informix".ss_param
			WHERE empresa = o_empresa
				AND secuencia = 362;

			IF NVL(iDiasVigencia,0) = 0 THEN
				LET iDiasVigencia = 0; ---para minimo cumplir lo que viene en el RQM
			END IF;
			
--IPCB 16jun2015 Se incluye para extraer la instutucion a cargar en la tabla ss_solicitudes_Sic, en vez de dejar en balnco la institucion por default cargara 'BC'
			
			-- RQM 09 554 - Consulta a las SICs.
			IF cflujo_cc = '1' THEN 
				LET institucion_sic = status_consul;
			ELSE
				SELECT status_solicitud
				INTO institucion_sic
				FROM bdisolic:"informix".ss_status_sol 
				WHERE empresa = o_empresa 
				AND tipo_auto = '1';
			END IF;
			
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB --se extrae el nuevo campo causa_rt, para validar los rechazos			
			SELECT num_solicitud_sic, fecha_sic, institucion,causa_rt
			INTO cNumSolSIC, dtFechaSic, cConsultaSic, ccausaRT
			FROM "informix".ss_solicitudes_sic
			WHERE ROWID = (SELECT MAX(rowid)
						   FROM "informix".ss_solicitudes_sic
						   WHERE numcte= v_cliente
							AND fecha_sic >= v_hoy - iDiasVigencia
							AND fecha_sic IS NOT NULL
							AND institucion = status_consul);
							
				IF cNumSolSIC IS NULL THEN 
					SELECT num_solicitud_sic, fecha_sic, institucion,causa_rt
						INTO cNumSolSIC, dtFechaSic, cConsultaSic, ccausaRT
					FROM "informix".ss_solicitudes_sic
					WHERE ROWID = (SELECT MAX(rowid)
					FROM "informix".ss_solicitudes_sic
					WHERE numcte= v_cliente
					AND  fecha_sic IS NULL
					AND institucion = status_consul);
				
				END IF;

							
							
							
							
--JMAH RQM 09 392
			IF iFlag2credito =1 AND NVL(cNumSolSIC,'') <> '' THEN --SE valida que la solicitud vigente , tenga el flag de segundo credito
				SELECT nvl(flag2credito,0) 
					INTO iFlag2creditoAux
				FROM bdisolic:ss_revision_determinacion
				WHERE empresa = o_empresa
				AND num_solicitud = cNumSolSIC;	
				
				IF iFlag2creditoAux = 1 THEN
					LET iFlag2credito = 0; -- con esta validacion hacemos que no se realice nuevamente la consulta a buro 
				END IF;
			ELSE
--IPCB 15jul15-- Para grupo 3 y 5 se determina si fueron a FICO
--IPCB Octubre2015 RQM 09 384-3 FICO SCORE--Incluir grupos 1,A,2, Hit. Para determinar si fueron a FICO --Se incluyen en el cgrupo
				IF ptipogrupo in ('1','2','3','5','A','8') AND v_tpsol IN ( 'T','P') AND cNumSolSIC is not null AND cflujo_cc = '0' THEN -- validar stat = BC o cflujo_cc = 0
					
					SELECT count(*) INTO entra_cc
					  FROM bdisolic:ss_autorizacion
					 WHERE empresa = o_empresa
					   AND num_solicitud = cNumSolSIC
					   AND status_solicitud = 'CC';
					 
					IF ( entra_cc > 0 ) THEN
						LET entra_cc = 2;
					ELSE
						SELECT nvl(evalua_cc,'') INTO vevalua_cc
						FROM bdisolic:ss_resum_scor_fin
						WHERE empresa = o_empresa
						AND num_solicitud = cNumSolSIC;		
					
						IF ( vevalua_cc = '0' ) THEN--IPCB   FICO SCORE
							SELECT NVL(sc01::INTEGER,0)
							INTO v_valor_1s
							FROM bdiburo:"informix".br_sc a
							WHERE a.rowid = (SELECT MAX(b.rowid) FROM bdiburo:"informix".br_sc b WHERE institucion = 'BC' AND b.num_cliente= v_cliente AND sc00 <> "004" )
							AND institucion = 'BC'
							AND num_cliente = v_cliente
							AND sc00 <> "004";   							
						
							SELECT unique NVL(bc_scoremin,0), NVL(bc_scoremax,0)
							  INTO v_bcs_min,v_bcs_max
							  FROM bdisolic:ss_scoring_modelo2
							 WHERE tp_solicitud IN ( 'T','P')
							   AND tp_solicitud = v_tpsol
							   AND grupo = ptipogrupo
							   AND num_producto =sNum_producto
							   AND grupo in ('1','2','3','5','A','8')
							   AND fc_score_max > 0
							   AND status_sol = 'RT';									
						   
							IF ( v_valor_1s >= v_bcs_min and v_valor_1s <= v_bcs_max ) THEN
								LET entra_cc = 1;
							END IF;
					-- AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended INICIO{
					/*	ELIF ( vevalua_cc = 'X' ) THEN--IPCB   FICO EXTENDED
							EXECUTE PROCEDURE "informix".sp_calculo_scpropietario(o_empresa,o_numsol,ptipogrupo,v_tpsol,vevalua_cc,v_meses,sNum_producto) 	
							INTO v_sc_prop;
						
							SELECT unique NVL(pro_scormax,0)
							  INTO v_scp_min
							  FROM bdisolic:"informix".ss_scoring_modelo2
							 WHERE tp_solicitud IN ( 'T','P')
							   AND tp_solicitud  = v_tpsol
							   AND respuesta_sic = DECODE(vevalua_cc,"X","X","0","0","2","1","3","1","4","1","1")
							   AND grupo = ptipogrupo    
							   AND num_producto = sNum_producto	
							   AND grupo in ('1','2','3','5','A','8')	
							   AND status_sol = 'RT'
							   AND tp_parametrico = 2; 
							
							IF v_sc_prop <= v_scp_min THEN				
								LET entra_cc = 3;	--SI ENTRA A FICO EXTENDED							
							END IF;	*/
					-- }FIN AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended
						END IF;
					END IF;
				END IF;		
--IPCB 15jul15
			end if--JMAH RQM 09 392
					
			IF ( cNumSolSIC IS NULL )  OR  (iFlag2credito = 1 ) THEN
--IPCB junio2017 //RECHAZO POR CREDITO BLOQUEADO RCB
				/**IF cNumSolSIC IS NOT NULL AND ccausaRT = 'RCB' THEN
					EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, 'RT', 'RCB', 'RECHAZO POR CREDITO BLOQUEADO') INTO p_cod_ret;**/
                    --Se aÃÂ±ade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC.
				IF cNumSolSIC IS NOT NULL AND ccausaRT = 'CCB' THEN
					EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, 'CN', 'CCB', 'CANCELADO POR CREDITO BLOQUEADO') INTO p_cod_ret;
					
					UPDATE "informix".ss_solicitudes_sic SET causa_rt =ccausaRT 
					WHERE numcte = v_cliente AND num_Solicitud_sic = cNumSolSIC AND num_Solicitud = o_numsol;
					
					IF p_cod_ret <> '000000' THEN
						LET scod_ret= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
						LET Flag_bitacora = 1;
					ELSE 
						LET flag_rt_rcb =1;
					END IF;		
				ELSE
					INSERT INTO "informix".ss_solicitudes_sic
						(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
					VALUES(o_empresa,v_cliente,o_numsol,o_numsol,institucion_sic,v_hoy,NULL);
					EXECUTE PROCEDURE bdiburo:"informix".burocred(o_empresa, "0000", USER, o_numsol, 0) INTO scod_ret;
				END IF;
			ELSE
				IF dtFechaSic IS NULL THEN
				 IF fgst_prosp <> 'F' AND cCanal <> 4 THEN	 --IPCB 04sep20, no inserta para 0 - 6500
					INSERT INTO "informix".ss_solicitudes_sic
						(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
					VALUES(o_empresa,v_cliente,o_numsol,cNumSolSIC,cConsultaSic,v_hoy,NULL);
				 END IF;
				ELSE
				--	IF cNumSolSIC <> o_numsol THEN --RGH
        		 IF  fgst_prosp <> 'F' AND cCanal <> 4 THEN	--IPCB 04sep20, no inserta para 0 - 6500
					INSERT INTO "informix".ss_solicitudes_sic
						(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic,causa_rt)
					VALUES(o_empresa,v_cliente,o_numsol,cNumSolSIC,cConsultaSic,v_hoy,dtFechaSic,ccausaRT);
				--	END IF; 
				END IF;
                					
					IF ( entra_cc = 2 ) THEN -- CONSULTA PREVIA A CC
						EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, 'CC', '', 'SOLICITUD ENVIADA A CIRCULO DE CREDITO') INTO p_cod_ret;
						IF p_cod_ret <> '000000' THEN
							LET scod_ret= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
							LET Flag_bitacora = 1;
							---RETURN scod_ret;
						END IF;
--IPCB junio2017 //RECHAZO POR CREDITO BLOQUEADO RCB		
					/**ELIF ccausaRT = 'RCB' THEN				
						EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, 'RT', 'RCB', 'RECHAZO POR CREDITO BLOQUEADO') INTO p_cod_ret;**/
                        --Se aÃÂ±ade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC.
					ELIF ccausaRT = 'CCB' THEN
						EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, 'CN', 'CCB', 'CANCELADO POR CREDITO BLOQUEADO') INTO p_cod_ret;
						IF p_cod_ret <> '000000' THEN
							LET scod_ret= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
							LET Flag_bitacora = 1;
						ELSE 
							LET flag_rt_rcb =1;	
						END IF;		 
					END IF;

					IF  Flag_bitacora <> 1 THEN	
						IF  ( entra_cc in (1,3) ) THEN  --IPCB 13sep16	ENVIO A CC FICO 
							CALL bdiburo:"informix".ins_buro_credito('BC',o_empresa,o_numsol,v_cliente,v_hoy,v_hoy,'',0,'','0') RETURNING s_regreso;
						ELSE
						--JMAH Se realiza homologacion con ajustes paso 5
							IF v_tpsol = "C" THEN-- envio a de consulta a coppel  ---Consulta Coppel
								LET iBanderaCoppel = 2;
							ELSE
								IF ( cOrigenSol = '1')  THEN
									--RQM 09 554
									IF cCanal = 4 THEN
										IF cflujo_cc = '1' THEN --fjpr
											IF EXISTS (SELECT institucion FROM bdiburo:"informix".br_traslado WHERE numcte = v_cliente AND institucion = 'BC') THEN
												EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, 'BC', '', 'SOLICITUD ENVIADA A BURO DE CREDITO') INTO p_cod_ret;
												IF p_cod_ret <> '000000' THEN
													LET scod_ret= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
													LET Flag_bitacora = 1;
												END IF;
												EXECUTE PROCEDURE "informix".califica_scoring2_cjunk(o_empresa, o_numsol) INTO scod_ret; --fjpr
											ELSE
												CALL bdiburo:"informix".ins_buro_credito('CC',o_empresa,o_numsol,v_cliente,v_hoy,v_hoy,'',0,'','0') RETURNING s_regreso;
													IF s_regreso = '0' THEN
														EXECUTE PROCEDURE "informix".califica_scoring2_cjunk(o_empresa, o_numsol) INTO scod_ret;
													END IF;
											END IF;														   
										ELSE
																																   
								  
											EXECUTE PROCEDURE "informix".califica_scoring2_cjunk(o_empresa, o_numsol) INTO scod_ret;
				  
										END IF;
									ELSE	
										EXECUTE PROCEDURE "informix".califica_scoring2_cjunk(o_empresa, o_numsol) INTO scod_ret;
									END IF;
								ELSE
									--RQM 09 554
									CALL "informix".califica_scoring2(o_empresa, o_numsol) RETURNING scod_ret;
								END IF;
								LET scod_ret = '000';
							END IF;
						END IF;
					END IF;	
				END IF;
			END IF;
		END IF;
--IPCB junio2017 //RECHAZO POR CREDITO BLOQUEADO RCB -- Se incluye la validacion flag_rt_rcb <>1, para que las solicitudes Coppel ya rechazadas por RCB no pasen a EC
		IF iBanderaCoppel > 0 AND v_tpsol = "C"  AND Flag_bitacora <> 1  AND flag_rt_rcb <>1 THEN
--		  SELECT canal_sol into es_internet from bdisolic:"informix".ss_prospecteo_solicitudes
	--	  WHERE num_solicitud = o_numsol; 
	      --AND canal_sol = 4;
		 
		    IF (cCanal = 4) THEN 
                UPDATE "informix".ss_solicitudes
                SET envio_parametrico = "6"
                WHERE num_solicitud = o_numsol
                    AND empresa = o_empresa;
            ELSE
				UPDATE "informix".ss_solicitudes
				SET envio_parametrico = "1"
				WHERE num_solicitud = o_numsol
					AND empresa = o_empresa;
		    END IF;
			-- SE VALIDA QUE ACTUALIZE EL NUEVO ESTATUS "EC" CUANDO TERMINE DE CONSULTAR A BURO. RQM 18 023 - EstatusSolicitudCoppelEC
			IF NVL(cConsultaSic,'') <> '' or iBanderaCoppel = 1 THEN
                EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema', o_numsol, 'EC', '', 'Solicitud enviada a Evaluacion Coppel')
				INTO p_cod_ret;
			END IF;
		END IF;
		
		--Actualiza nuevo estatus de Prospecto "CP"
		IF sNum_producto ='6500' THEN	
		
			SELECT {+INDEX (bdiprospectos:"informix".pr_cliente)}
			a.numcte_pros, a.numcte,c.status_solicitud
			INTO  cNumCteProspecto, cNumCteBanco,cStatusSol
			FROM bdiprospectos:pr_cliente a
			JOIN bdisolic:ss_solicitudes c ON c.empresa=a.empresa AND c.numcte=a.numcte 
			AND c.num_producto='6500' AND c.status_solicitud IN ('BC','EC') AND c.num_solicitud = o_numsol AND a.status_numcte_pros IN ('AT','OA','CE','OS','EC','EE'); 
		
			IF(cNumCteProspecto IS NOT NULL) THEN 

						--El Cliente Prospecto debe quedar en estatus CP una vez que sea formalizada la solicitud de Tarjeta Coppel como Cliente Titular
						UPDATE bdiprospectos:pr_cliente SET status_numcte_pros='CP' WHERE numcte=cNumCteBanco ;
						
						EXECUTE PROCEDURE bdiprospectos:sp_ctepr_actualizastatus('sistema', cNumCteProspecto, 'CP' , '' , '')
						INTO p_cod_ret;
			END IF;		
		END IF;					
				
-- Obtiene datos para almacenar en la bitacora de la solicitud
		SELECT {+INDEX (bdicred:"informix".sd_causas_cte_coppel)}
		s.situacion_especial, s.causa_situacion, c.descripcion
		  INTO vsituacion_especial,  vcausa_situacion, cDescSitEsp
		  FROM bdisolic:"informix".ss_resum_scor_fin s, bdicred:sd_causas_cte_coppel c
		 WHERE s.empresa = c.empresa and s.situacion_especial = c.situacion and s.causa_situacion = c.causa
		   AND s.empresa = o_empresa AND s.num_solicitud = o_numsol;

-- Obtiene le numero de reestructuras que ha tenido el cliente
		SELECT nvl(count(a.numcte),0) INTO sReestructCte FROM bdicred:sd_maecredcrd a, bdicred:sd_maecredanexocrd b WHERE a.empresa = b.empresa 
		   AND a.num_credito = b.num_credito AND a.num_producto = '6011' AND a.numcte = v_cliente AND a.status_cred = 'FF' AND b.fecha_proceso <= v_hoy;
	
		UPDATE bdisolic:"informix".ss_revision_determinacion SET edad = iEdadcte, escolaridad_descrip = vescolaridad_des,situacion_especial = vsituacion_especial, causa_sit_esp = vcausa_situacion, 
			   descripcion_siesp = cDescSitEsp, num_reest_cte = sReestructCte, fecha_sol = vfecha_sol, linea_min_prod = dlinea_min_prod
		 WHERE empresa = o_empresa AND num_solicitud = o_numsol;
	END
	
	/*COMMIT WORK;
	IF wbegin = 'N' THEN
	    BEGIN WORK;
	END IF;*/
	
	RETURN scod_ret;
END PROCEDURE
