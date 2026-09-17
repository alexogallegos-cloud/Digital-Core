CREATE PROCEDURE "informix".califica_scoring2_cjunk(o_empresa CHAR(3), o_numsol CHAR(20))
RETURNING CHAR(5);

        -- CONTROL DE CAMBIOS
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificacion: Se valida resultado de os telefonica y se aplican criterios
--               para autorizar, generar OS Calle o rechazar una solicitud de


--               credito Coppel.
-- Fecha de Modificacion: 14-01-2009
-- Proyecto: Caja Unica
--------------------------------------------------------------------------------
-- Autor:  Viridiana Osobampo.
-- Modificacion: Se modifica para no contemplar os telefonica.
-- Fecha de Modificacion: 28-09-2009.
-- Peticion: Caja Unica.
--------------------------------------------------------------------------------
-- Autor:  Viridiana Osobampo.
-- Modificacion: Se modifica para incluir el Prestamo Personal en el
--		 proceso. Se actualiza informacion sobre la linea de credito
--               calculada, capacidad de pago y plazo para P.P y Capacidad de pago
--               para TDC.
-- Fecha de Modificacion: 30-09-2009
-- Peticion: RQM 10 108 Prestamo Personal
--------------------------------------------------------------------------------
-- Autor:  Viridiana Osobampo.
-- Modificacion: Los clientes coppel con buena eficiencia y meses de historia
--               sin tener compras realizadas desde mas de 180 dias en tiendas coppel,
--               al calcular su linea de credito no se tome como cliente nuevo, sino
--               como un cliente con antiguedad.
-- Fecha de Modificacion: 04-02-2010
-- Peticion: RQM 10 108 Prestamo Personal
--------------------------------------------------------------------------------
-- Autor:  Jesus Manuel Aguilar Heredia
-- Modificacion:  se agrega validaciones para incluir nuevos escenarios para enviar la solicitud a OS Calle,
	--se contempla el proceso de la Os telefonica.
-- Fecha de Modificacion: 09-12-2010
-- Peticion: RQM ajustes alta unica paso 4
--------------------------------------------------------------------------------
-- Autor:  Jesus Manuel Aguilar Heredia
-- Modificacion:  Se corrige validacion par enviar a orden de supervision a las solicitud.
-- Fecha de Modificacion: 20-04-2011
-- Peticion: RQM ajustes alta unica paso 4.5
--------------------------------------------------------------------------------
-- Autor:  Jesus Manuel Aguilar Heredia
-- Modificacion:  Se agrega validacion para envio a os calle a solicitudes coppel cuando el catalogo de BanCoppel con Coppel, no este homologado.
-- Fecha de Modificacion: 17-06-2011
-- Peticion: RQM ajustes alta unica paso 5
-- Autor:  Jesus Manuel Aguilar Heredia
-- Modificacion:  Se Corrige flujo de envio a os Calle para clientes coppel.
-- Fecha de Modificacion: 02-08-2011
-- Peticion: Observaciones ustes alta unica paso 5
--------------------------------------------------------------------------------
-- Modificacion:  Se Corrige flujo de envio a os Calle para clientes  que no se encuentren en als tablas si_clientecomparacionbanco y si_clientecomparacionbanconomatch
-- Fecha de Modificacion: 22-09-2011
-- Peticion: Observaciones ustes alta unica paso 5
--------------------------------------------------------------------------------
--Modifico:Jesus Manuel Aguilar Heredia
--Fecha de modificacion: 22-12-2011
--Descripcion: Se modifca para registrar la respuesta de la ultima consulta a buro para el cliente  en una tabla de control  verficar si es necesario el envio a buro de credito, en futuros tramites
--Peticion: RQM 18 011 Vigencia de Consulta al Buro y Circulo de Credito
--------------------------------------------------------------------------------------Modifico:Jesus Manuel Aguilar Heredia
--Fecha de modificacion: 19-03-2012
--Descripcion: se modifica para no rechazar las solicitudes coppel cuando el resultado de la consulta a coppel nos regresa autorizado y guardar
-- en el campo monto_solicitado el valor que nos regresa dicha consulta
--Peticion: Observaciones RQM 18 011 Vigencia de Consulta al Buro y Circulo de Credito
-- validacion de Grupo A no enviar a OS a menos que la huella no coincida FMJ Marzo,2013
------------------------------------------------------------------------------------
--Modifico: Carlos Aguirre
--Fecha de modificacion: 31-05-2012
--Descripcion: SE MODIFICA PARA NO SE RECHAZAR SOLICITUDES COPPEL POR NINGUNA CAUSA DEL PROCESO (RS3)
--Peticion: Revision en paralelo
--------------------------------------------------------------------------------------
-- Modifico: Maria Elena Angulo Aispuro
-- Fecha de Modificacion: 28-08-2018
-- Descripcion: Se inhabilita el bloque de FICO Extended
-- RQ: RQI27201
-- CC Rational: 26072
-------------------------------------------------------------------------------------------------------------

-- Modifico: Gabriela Esmeralda Gonzalez Baez
-- Fecha de Modificacion: 11-02-2019
-- Descripcion: Se modifica el flujo de las solicitudes 
--              para clientes con solicitudes previas canceladas por mesa de control.
-- RQ: RQM 09 501 - Implementacion - Flujo para Clientes con Solicitudes Canceladas en Mesa de Control.
-- CC Rational: 29749 
-------------------------------------------------------------------------------------------------------------
-- Autor:  Gutberto Gomez.
-- Modifica: Se modifica para no contemplar os para producto 8500.
-- Fecha: 10-07-2019.
-- RQM 10 960.
-- Etiqueta: GGG-100719
-- CC Rational: 34554 
-------------------------------------------------------------------------------------------------------------
-- Autor:  Francisco Javier Peraza.
-- Modifica: Se modifica orden de consulta a las instituciones de credito
-- Fecha: 15-04-2020.
-- Peticion: RQM 09 554 - Consulta a las SICs.																											 
--------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Autor:  Felix Ignacio Leyva Gamez.
-- Modifica: Se agrega consulta aleatoria a las SICs, ,con las banderas de fallosic y vigencia
-- Fecha: 06-01-2023.
-- Peticion: RQM 09 606 - Consulta aleatoria a las SIC's cadena 2x1 - Originacion
------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE cNumsolOs			  CHAR(20);
DEFINE vdiastrans			  INTEGER;
DEFINE cTipoSol				  CHAR(1);
DEFINE iBanderaProsNoTit	  INTEGER;

DEFINE vstatusCoppel          CHAR (1);
DEFINE scod_ret               CHAR(5);
DEFINE vsqlerr                INTEGER;
DEFINE v_valor                DECIMAL(14,2);
DEFINE v_lineaban             DECIMAL(18,2);	---Modificacion de longitud de decimal
DEFINE v_valor_1s             DECIMAL(14,2);
DEFINE v_valor_2s             DECIMAL(14,2);
DEFINE v_valor_3s             DECIMAL(14,2);  --IPCB  FICO SCORE
DEFINE v_valor_4s             DECIMAL(14,2);  --IPCB  FICO EXTENDED
DEFINE v_valor_im             DECIMAL(14,2);
DEFINE v_valor_ex             DECIMAL(14,2);
DEFINE v_paso                 CHAR(1);
DEFINE v_respsic              CHAR(1);
DEFINE v_cuantos              SMALLINT;
DEFINE v_seccion              SMALLINT;
--DEFINE v_grupo                SMALLINT;
DEFINE v_tpsol                CHAR(1);
DEFINE v_hoy                  DATE;
DEFINE v_cliente              CHAR(20);
DEFINE vCompromisos           DECIMAL(14,2);
DEFINE vMensaje               VARCHAR(255);
DEFINE vMsg_Reasig            VARCHAR(100);
DEFINE vedocivil              CHAR(1);
DEFINE vTpCiudad              CHAR(1);
DEFINE vCiudadCte             CHAR(3);
DEFINE vEstadoCte             CHAR(2);
DEFINE vCte                   CHAR(20);
DEFINE vAntiguedad            CHAR(1);
DEFINE vHuella                SMALLINT;
DEFINE v_EficienciaCoppel     SMALLINT;
DEFINE v_SituacionPagoCoppel  DECIMAL(5,2);
DEFINE v_PuntualidadCoppel    CHAR(2);
DEFINE v_ElementoDesempleo    SMALLINT;
DEFINE p_cod_ret              CHAR(6);
DEFINE v_Desempleo            CHAR(1);
DEFINE vMensajeStatus         CHAR(80);
DEFINE VNuevoStatus           CHAR(2);
DEFINE v_hereda_status        CHAR(2);
DEFINE v_meses_hist           SMALLINT;
DEFINE v_meses                SMALLINT;
DEFINE v_meses_hist_inter     SMALLINT;
-- Ini  Caja Unica. Viridiana
DEFINE sConsulta               SMALLINT;
DEFINE sSituacionOs            SMALLINT;
DEFINE sCausa                  SMALLINT;
DEFINE dUltimaCompra           DATE;
DEFINE iDiasCoppel             INTEGER;
DEFINE cSituacionCredito       CHAR(1);
DEFINE cGeneraOs               CHAR(1);
DEFINE cOrigen                 CHAR(1);
DEFINE iTotalParametrico       INTEGER;
-- Fin Caja Unica Viridiana
DEFINE v_capacidad_pago        MONEY(18,2);
DEFINE iPlazo                  INTEGER;
DEFINE dMonto_min              DECIMAL(18,2);
DEFINE cProducto               CHAR(20);
DEFINE v_meses_min            SMALLINT;
DEFINE v_eficiencia           DECIMAL(5,2);
DEFINE cCausa_sol             CHAR(3);
DEFINE v_ingreso_neto         MONEY;
DEFINE v_importe_hip          MONEY;
DEFINE v_num_pagos            INTEGER;
DEFINE v_mensual_hip          MONEY;
DEFINE v_sol_rechazada        SMALLINT;
DEFINE v_compromisos_33       MONEY;
DEFINE v_monto_cap_pago       CHAR(20);
DEFINE vCodUdi      CHAR(2);
DEFINE vCodUs       CHAR(2);
DEFINE vTpCambioUdi DECIMAL(14,6);
DEFINE vTpCambioUs  DECIMAL(14,6);
define vcompromiso_coppel    MONEY;
---DEFINE v_Sichip     DECIMAL(9,6);  
DEFINE cStatusSolicitud       CHAR(2);
DEFINE v_mod_parame           CHAR(1);
DEFINE vClase        CHAR(1);
--variables para os telefonica
DEFINE cResultadoOsTel         CHAR(1);
DEFINE dValorOs                decimal(10,4);
DEFINE cEnvioCat               CHAR(1);
DEFINE cRechazoOsTel           CHAR(1);
DEFINE cNuevoStatusOstel       CHAR(2);
DEFINE cTieneOstel             CHAR(1);
DEFINE cElementOs              SMALLINT;
DEFINE vCodret					CHAR(5);
DEFINE iReferencia1				INTEGER;	
DEFINE iReferencia2				INTEGER;
DEFINE iReferencia				INTEGER;
DEFINE v_habita_en             CHAR(2);
DEFINE codidentif              CHAR(2);
DEFINE iAct						SMALLINT;
DEFINE iSubAct					SMALLINT;
DEFINE vRiesgo					SMALLINT;
DEFINE cTelefono1               CHAR(13);
DEFINE cTelefono2               CHAR(13);
DEFINE cCodidentif              CHAR(2);
DEFINE iBanderatel				INTEGER;	
DEFINE iBanderaidentificacion	INTEGER;
DEFINE iBanderareferencia		INTEGER;
DEFINE banderaS					INTEGER;
DEFINE iMotivoOs, iFiltroParam  INTEGER;
DEFINE vdiagpo3      CHAR(20);
DEFINE iBanderaErrorCatalogo   INTEGER;
DEFINE vcompromiso_rmp      MONEY;
DEFINE v_compteorico        MONEY(14,2);
DEFINE v_linea_tienda       MONEY(14,2);

DEFINE V_ciudad LIKE bdisolic:ss_osclientesupervisar.ciudad;
DEFINE V_colonia LIKE bdisolic:ss_osclientesupervisar.colonia;
DEFINE V_calle LIKE bdisolic:ss_osclientesupervisar.calle;
DEFINE V_ciudadCoppel LIKE bdisolic:ss_osclientesupervisar.ciudadcoppel;
DEFINE V_coloniaCoppel LIKE bdisolic:ss_osclientesupervisar.coloniacoppel;
DEFINE V_NombreZonaCoppel LIKE bdisolic:ss_osclientesupervisar.nombrezonacoppel;	
----LHM INI
DEFINE v_factor_flujo1     DECIMAL(5,2); 
DEFINE v_comprobanco        MONEY (14,2);
---LHM FIN
DEFINE iSitEsp  		INTEGER;
DEFINE cNomcte          CHAR(104);
DEFINE cCodRet          CHAR(3);
DEFINE cSexo            CHAR(1);
DEFINE iEdadcte         SMALLINT;
--DEFINE vAsignaGrupo, 
DEFINE vgrupo_sol CHAR(01);
--DEFINE vgrupo6          smallint;
DEFINE iValido   		INTEGER;
DEFINE cMensajeRet   	CHAR(100);
DEFINE cSucursal   		CHAR(4);
DEFINE dMontoAut   		DECIMAL(18,2);
DEFINE iProdMC   		INTEGER;
DEFINE iEnviarMC   		INTEGER;
--- RQM 09 324
DEFINE	vScoreBC			SMALLINT;
DEFINE	vScorePR			SMALLINT;
DEFINE  vValidaOS			CHAR(1);
--- RQM 18 056
DEFINE  iSolMc			INTEGER;
DEFINE  iSolMcAux			INTEGER;
DEFINE  iBanderaFaltaOSTEL	INTEGER;
--- RQM Cte tipo 3
DEFINE  vRTipo3             CHAR(1);
DEFINE  vVigente            CHAR(1);
DEFINE  vlSecuencia         INTEGER;
DEFINE  vlClaveOSCoppel     CHAR(1);
DEFINE  vSolDirecta				  SMALLINT;
--- RQM 09 337
DEFINE cRespuestaOs          CHAR(1); 
DEFINE cMsjStatus            CHAR(80);
DEFINE cTipoMovto            CHAR(1);
DEFINE cNumSolRef            CHAR(20);
 
--DEFINE	cGrupo	CHAR(1);


DEFINE	iValidaCel	SMALLINT;
DEFINE	dFechaCte	DATE;
DEFINE	dFechaIniVal	DATE;
DEFINE cNumSol         CHAR(20);
DEFINE cStatusMovil         CHAR(1);

--IPCB Marzo2015 RQM 09 384-0 FICO SCORE Se requiere el grupo
DEFINE entra_cc integer;
DEFINE v_scp_min integer;
DEFINE cCodRet2Cred CHAR(6);
DEFINE iFlag2credito         SMALLINT;
DEFINE iValorICC	         SMALLINT;

DEFINE  cNumCteBco		    CHAR(20);
DEFINE  cCteProsp		    CHAR(20);
DEFINE  cStatusSolic	    CHAR(2);
DEFINE  sBanAuto		    SMALLINT;
DEFINE dFecha_Respuesta		DATE;
DEFINE dFechaVencimiento	DATE;
DEFINE cDiaVigencia  		CHAR(3);
DEFINE cDesStatusCtePros	CHAR(40);
DEFINE cStatusPr			CHAR(2);
DEFINE cStatusRespOs		CHAR(1);
DEFINE cClientePros			CHAR(1);
DEFINE iSecuenciaOs, iNumSolDia, iNumSolTotDia, iFiltroPrend INTEGER;
DEFINE cPiloto, v_Reasig_rubro	CHAR (1);

DEFINE cFLagGeoMov, vreasig_evalua_cc CHAR(1);
DEFINE cFolioMovil         CHAR(20);
DEFINE cFlagAltadirectaSupervisar CHAR(1);DEFINE cCuenta         CHAR(20); -- RQM 10 617 JMAH
DEFINE cCodRetAdn           CHAR(6); -- RQM 10 617 JMAH
DEFINE iValidoAdn           SMALLINT; -- RQM 10 617 JMAH
DEFINE cTelCel              CHAR(10) ;
---DEFINE StatusSolDta         INTEGER;
DEFINE vSituacionSolD  		CHAR (1);
DEFINE vCausaSolD			INTEGER;
DEFINE cCodReRub            CHAR(6);
DEFINE iSuma                DECIMAL(10,4);
DEFINE iPuntos              DECIMAL(10,4);

DEFINE cGeoCte		  		CHAR (20);
DEFINE cProductoMovil		CHAR (3);
DEFINE cProductoVig			CHAR(20);
DEFINE cFechaHora			DATETIME YEAR TO SECOND;
DEFINE cCteProspVig			CHAR(20);

DEFINE iFlagForzarEnvioMC	SMALLINT; --- GEGB 20190211 RQM 09 501
DEFINE v_factor     DECIMAL(14,6); --RQM 09 408
DEFINE v_moneda     CHAR(2); --RQM 09 408
DEFINE v_total      MONEY; --RQM 09 408
DEFINE v_imp_hip    MONEY; --RQM 09 408
DEFINE v_tot_tp     MONEY;
DEFINE v_id_excluye_os CHAR(1); --- GGG-100719
DEFINE cStatusprospecteo    CHAR (1); ---ICM _prospecteo_solicitdudes_09_19

DEFINE bandera_geo			INTEGER;
DEFINE bandera_grupo5 		INTEGER;
DEFINE existe_gpo5			INTEGER;

DEFINE cCanalv1            integer;
--DEFINE ostatus           CHAR(2);

--- RQM 09 530

DEFINE scod_ret_rev				CHAR(5);
DEFINE  v_monto_origen				DECIMAL (18,2);
-- RQM 10 1177
DEFINE v_envio_os 			SMALLINT; 
DEFINE cbanobligadosol		SMALLINT;
DEFINE ccapturaobligsol		SMALLINT;
DEFINE vfechaServ DATE;
						 
DEFINE cParamOS_AltaAutom   CHAR(1);						 

DEFINE cScorecoppel   SMALLINT;
DEFINE cParametrico   CHAR(1);
DEFINE pSeccion       CHAR(1);
DEFINE isolcomp			INTEGER; -- RQM 10 1432
DEFINE cProducto2    CHAR(4); -- RQM 10 1432
DEFINE cRevalua CHAR(1); --RQM 10 1432
DEFINE vnvalinea DECIMAL(18,2);
DEFINE vnumsol  CHAR(20);
DEFINE vlatitud VARCHAR(10);
DEFINE vlongitud VARCHAR(11);

DEFINE isam_err	SMALLINT;
DEFINE error_info CHAR(100);


DEFINE vCuentasPF SMALLINT;
DEFINE vTipoHit SMALLINT;
DEFINE vScore INTEGER;
DEFINE iNewMPP INTEGER;
DEFINE bc_Score_orig DECIMAL(14,2);
DEFINE vFalloSIC	INTEGER;
DEFINE vInstitucion	CHAR(2);

DEFINE sFlagCanalWeb		SMALLINT;

LET cNumsolOs	= '';
LET vdiastrans	= 0;
LET cTipoSol	= '';
LET iBanderaProsNoTit	= 0;

LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_valor      = 0;
LET v_lineaban   = 0;
LET v_valor_1s   = 0;
LET v_valor_2s   = 0;
LET v_valor_3s   = 0;	--IPCB FICO SCORE
LET v_valor_4s   = 0;	--IPCB FICO EXTENDED
LET v_valor_im   = 0;
LET v_valor_ex   = 0;
LET v_paso       = "";
LET v_respsic    = "";
LET v_cuantos    = 0;
LET v_seccion    = 0;
--LET v_grupo      = 0;
LET v_tpsol      = "";
LET vCte         = "";
LET vAntiguedad  = "?";
LET vHuella = 0;
LET v_EficienciaCoppel= 0;
LET v_SituacionPagoCoppel= 0;
LET v_PuntualidadCoppel= "";
LET v_ElementoDesempleo= 0;
LET p_cod_ret= "000000";
LET v_Desempleo= "";
LET vMensajeStatus="";
LET VNuevoStatus="";
LET v_hereda_status = "";
LET v_meses_hist=0;
LET v_meses=0;
LET v_meses_hist_inter=0;
-- Ini Caja Unica. Viridiana
LET sConsulta               = 0;
LET sSituacionOs            = 0;
LET sCausa                  = 0;
LET dUltimaCompra           = DATE(1);
LET iDiasCoppel             = 0;
LET cSituacionCredito       = "";
LET cGeneraOs               = "0";
LET cOrigen                 = "";
LET iTotalParametrico       = 0;
-- Fin Caja Unica Viridiana
LET v_capacidad_pago        = 0;
LET iPlazo                  = 0;
LET dMonto_min              = 0;
LET cProducto               = "";
LET v_meses_min  = 0;
LET v_eficiencia = 0;
LET cCausa_sol = "";
LET v_ingreso_neto = 0 ;
LET v_importe_hip = 0;
LET v_num_pagos = 0;
LET v_mensual_hip = 0;
LET v_sol_rechazada = 0;
LET v_compromisos_33 = 0;
LET v_monto_cap_pago = 0;
LET vCodUdi      = "";
LET vCodUs       = "";
LET vTpCambioUdi = 0;
LET vTpCambioUs  = 0;
LET vcompromiso_coppel = 0;
----LET v_Sichip = 0;
LET cStatusSolicitud = "";
LET v_mod_parame = "";
LET vClase       = "";

LET cResultadoOsTel         = "";
LET dValorOs                = 0;
LET cEnvioCat               = "";
LET cRechazoOsTel           = "";
LET cNuevoStatusOstel       = "";
LET cTieneOstel             = "";
LET cElementOs              = "";
LET vCodret					= "";
LET iReferencia1			= 0;	
LET iReferencia2			= 0;
LET iReferencia				= 0;
LET iAct					= 0;
LET iSubAct					= 0;
LET vRiesgo					= 0;
LET cTelefono1              = "";
LET cTelefono2				= "";
LET cCodidentif				= "";
LET iBanderatel				= 0;
LET iBanderaidentificacion	= 0;
LET iBanderareferencia		= 0;
LET banderaS				= 0;
LET vdiagpo3     = "";
LET iBanderaErrorCatalogo = 0;
LET iMotivoOs				= 0;
----LHM INI----FACTOR DE COMPROMISOS PARA HIPOTECARIO
LET v_factor_flujo1       = 0;
LET v_comprobanco         = 0;
---LHM FIN
LET iSitEsp = 0;
LET cNomcte    	= "";
LET cCodRet    	= "";
LET cSexo     	= "";
LET iEdadcte  	= 0;
--LET vAsignaGrupo = "";
--LEt vgrupo6      = 0;
LET iValido    	= 0;
LET cMensajeRet = "";
LET cSucursal   = "";
LET dMontoAut   = 0;
LET iProdMC   = 0;
LET iEnviarMC   = 0;
---RQM 09 324
LET	vScoreBC	=0;
LET	vScorePR	=0;
LET vValidaOS   = '';
---RQM 18 056
LET iSolMc =0;
LET iSolMcAux =0;
LET iBanderaFaltaOSTEL =0;
--- Cliente Tipo 3
LET vRTipo3 = '';
LET vVigente = '';
LET vlSecuencia = 0;
LET vlClaveOSCoppel = 'S';
LET vSolDirecta = 0;
LET v_habita_en = '';
LET vgrupo_sol = '';
LET vcompromiso_rmp =0;
LET v_compteorico  =0;
LET v_linea_tienda = 0;
--- RQM 09 337
LET cRespuestaOs            = '';
LET cMsjStatus              = '';
LET cTipoMovto           = '';
LET cNumSolRef            = '';
---RQM 09 369
--LET cGrupo = '';
LET iValidaCel = 0;
LET dFechaCte = DATE(1);
LET dFechaIniVal = DATE(1);
LET cNumSol ='';
LET cStatusMovil ='';


--IPCB Marzo2015 RQM 09 384-0 FICO SCORE
LET entra_cc   = 0;
LET v_scp_min  = 0;
LET cCodRet2Cred  = "";
LET iFlag2credito =0;
LET iValorICC =0;

LET cNumCteBco  = "";
LET cCteProsp  = "";
LET cStatusSolic  = "";
LET sBanAuto  = 0;
LET dFecha_Respuesta = DATE(1);
LET dFechaVencimiento = DATE(1);
LET cDiaVigencia = "000";
LET cDesStatusCtePros ="";
LET cStatusPr = "";
LET cStatusRespOs = "";
LET cClientePros = "";
LET iSecuenciaOs = 0;
LET v_hoy = DATE(1);
LET cPiloto	= "";
LET cFLagGeoMov ='';
LET cFolioMovil ='';
LET vstatusCoppel = '';
LET iFiltroParam = 0;
LET iNumSolDia = 0;
LET iNumSolTotDia = 0;
LET cFlagAltadirectaSupervisar  = ''; -- DSB 20160208
LET cCuenta        = ''; -- RQM 10 617 JMAH
LET cCodRetAdn	   = ''; -- RQM 10 617 JMAH
LET iValidoAdn     = 0; -- RQM 10 617 JMAH
LET v_lineaban        = 0; -- RQM 10 617 JMAH
LET cTelCel        = ''; -- RQM 10 617 JMAH
---LET StatusSolDta = 0;
LET vSituacionSolD = "";
LET vCausaSolD= 0;
LET vreasig_evalua_cc   = '';
LET vMsg_Reasig         = '';
LET cCodReRub           = '000000';
LET v_Reasig_rubro      = '0';
LET iSuma               = 0;
LET iPuntos             = 0;

LET cGeoCte             = '';
LET cProductoMovil    = '';
LET cProductoVig      = "";
LET cFechaHora		= DATE(1);
LET cCteProspVig	= "";

LET v_factor     = 0;LET v_moneda     = ''; --RQM 09 408
LET v_total      =0; --RQM 09 408
LET v_imp_hip    =0; --RQM 09 408
LET v_tot_tp     =0;

LET iFlagForzarEnvioMC = 0;  -- GEGB 20190211 RQM 09 501
LET cStatusprospecteo = ''; ---ICM _prospecteo_solicitdudes_09_19

LET v_id_excluye_os = '0'; --- GGG-100719

LET bandera_geo			= 0;
LET bandera_grupo5 		= 0;
LET existe_gpo5			= 0;

LET cCanalv1                    = 99;
--LET ostatus                     ='';

--- RQM 09 530

LET scod_ret_rev 			= '';
LET v_monto_origen			= 0;
				
-- RQM 10 1177
LET v_envio_os 				= 0; 
LET cbanobligadosol			= 0;
LET ccapturaobligsol		= 0;

LET cParamOS_AltaAutom      = '';

LET cScorecoppel = 0;
LET cParametrico = '2';
LET pSeccion = 0;
LET isolcomp	 = 0; -- RQM 10 1432
LET cProducto2   =''; -- RQM 10 1432
LET cRevalua    = ""; -- RQM 10 1432
LET vnvalinea =0;
LET vnumsol  ="";
LET vlatitud  ="";
LET vlongitud ="";
LET vCuentasPF = 0;
LET vTipoHit	=0;
LET vScore = 0;
LET iNewMPP = 0;
LET bc_Score_orig = 0;
LET vInstitucion	= ''; --RQM 09 606
LET vFalloSIC		= 0; 

LET sFlagCanalWeb = 0;

--SET DEBUG FILE TO '/home/c90039427/componentes_3/PROD_2/califica_scoring2_cjunk'||trim(o_numsol)||'.out';  
--TRACE ON;

	--SET DEBUG FILE TO '/home/c90077639/campo_vacio/pruebas/PRUEBAS_3/califica_scoring2_cjunk'||trim(o_numsol)||'.out';  
	--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy
  INTO v_hoy
  FROM bdicred:"informix".sd_fechas
 WHERE empresa = o_empresa;
 
--RQI 21 246  Originacion de solicitudes 24 x 7 INI
SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
INTO vfechaServ
FROM sysmaster:sysshmvals;

IF v_hoy < vfechaServ THEN
	LET v_hoy = vfechaServ;
END IF;
--RQI 21 246  Originacion de solicitudes 24 x 7 FIN


 
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr, isam_err, error_info
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
	  INSERT INTO bdisolic:ax_paso values ("bdisolic:califica_scoring2_cjunk", vsqlerr, CURRENT ||error_info||' sol '||TRIM(o_numsol));
      RETURN scod_ret;
   END IF;
END EXCEPTION;

   -- se movio este query para tomar el tipo de solicitud en caso de que se haya generado la os telefonica y se tenga el resultado
	SELECT sol.tipo_solicitud, sol.numcte, sol.num_producto,TRIM(sol.tipo_calculo),sol.status_solicitud,sol.sucursal,sol.monto_solicitado,mov.num_solicitud,status,mov.folio_movil
      INTO v_tpsol, vCte,cProducto,v_mod_parame,cStatusSolicitud,cSucursal,dMontoAut,cNumSol,cStatusMovil,cFolioMovil
      FROM "informix".ss_solicitudes sol
	  LEFT JOIN bdisolic:"informix".ss_solicitudes_movil mov on (mov.empresa = sol.empresa and mov.num_solicitud = sol.num_solicitud AND status <> '3')
     WHERE sol.empresa = o_empresa
       AND sol.num_solicitud = o_numsol;  

	   --- RQM 09 530 ITD se guarda el monto para reevaluacion de 6800
	   LET v_monto_origen = dMontoAut;
																					   
	------------------------------------------------------------------------------------------------------------------------------------------------
	--Inicio: RQM 09 606 consulta sic aleatorio y Fallo de SIC
	--Tomar la ultima solicitud de la SIC
	SELECT institucion, fallosIC
		INTO vInstitucion, vFalloSIC
		FROM bdisolic:"informix".ss_solicitudes_sic
		WHERE ROWID = (SELECT MAX(rowid)
					   FROM bdisolic:"informix".ss_solicitudes_sic
					   WHERE numcte= vCte
						AND num_solicitud = o_numsol);
	--Fin: RQM 09 606 consulta sic aleatorio y Fallo de SIC
	------------------------------------------------------------------------------------------------------------------------------------------------
	--Se agrega las solicitudes con status CN y causa CCB, CGC para no avanzar de status.
	IF cStatusSolicitud = "CN" THEN
		SELECT causa_solicitud INTO cCausa_sol 
		FROM "informix".ss_autorizacion 
		WHERE empresa = o_empresa AND 
		      num_solicitud = o_numsol AND 
			  status_solicitud = cStatusSolicitud;
		

		IF cCausa_sol IN ("CCB","CGC") THEN
			LET scod_ret= '00007'; -- Solicitudes en CCB, CGC no deben de avanzar de status
        	RETURN scod_ret;
		ELSE
			LET cCausa_sol = "";
		END IF;		
	END IF;	
	
   IF cStatusSolicitud IN ("AN","RT","CM") THEN
		LET scod_ret= '00007'; -- Solicitudes en AN no deben de avanzar de status
        RETURN scod_ret;
   END IF;
      ---JMAH Geolocalizacion
   --Se obliga a que las solicitudes moviles que tienen Geolocalizacion generen OS 
	
   IF NVL(cFolioMovil,'') <> '' AND v_tpsol != 'C' THEN      
	--SELECT domicilio_alta INTO cFLagGeoMov  FROM bdinteg:"informix".si_solicitud_movil where folio = cFolioMovil;   
	SELECT domicilio_alta, TRIM(geolocalizacion), substr(geolocalizacion,1,10), substr(geolocalizacion,12,21) INTO cFlagGeoMov,cGeoCte, vlatitud, vlongitud FROM bdinteg:"informix".si_solicitud_movil WHERE folio = cFolioMovil; --Se tiene el domicilio_alta solo si es movil
	
   ELSE
	IF cFolioMovil is not null THEN 
		LET cFLagGeoMov ='N';
	END IF;
   END IF;
		
SELECT TRIM(valor) INTO vCodUdi
  FROM bdinteg:"informix".si_param
 WHERE empresa = o_empresa
   AND cod_param = 16;

SELECT TRIM(valor) INTO vCodUs
  FROM bdinteg:"informix".si_param
 WHERE empresa = o_empresa
   AND cod_param = 17;

SELECT TRIM(valor) INTO vClase
  FROM bdicred:"informix".sd_param
 WHERE empresa = o_empresa
   AND cod_param = "336";
  /* Inicia Validacion Envia OS*/
  SELECT TRIM(valor) INTO vScoreBC
  FROM "informix".ss_param
  WHERE empresa = o_empresa
   AND secuencia = "366";

  SELECT TRIM(valor) INTO vScorePR
  FROM "informix".ss_param
 WHERE empresa = o_empresa
   AND secuencia = "367";
 --OBTENER EL CLIENTE BANCO PARA IR A BUSCARLO EN LA PR_CLIENTE PARA DETERMINAR SI TUVO COMO ORIGEN CLIENTE PROSPECTO.
	SELECT numcte INTO cNumCteBco 
	FROM "informix".ss_solicitudes 
	WHERE num_solicitud = o_numsol;		
	--SE CONSULTA SI EXISTE EL CLIENTE PROSPECTO.
	SELECT numcte_pros,status_numcte_pros INTO cCteProsp,cStatusSolic 
	FROM bdiprospectos:"informix".pr_cliente 
	WHERE empresa = o_empresa AND numcte = cNumCteBco AND tipo_cliente = 3 and status_numcte_pros NOT IN ('AN','PC','CN','CP');
	
	IF cStatusSolic IS NULL THEN
		LET cPiloto	= '1';
	ELIF (SELECT COUNT(numcte) FROM "informix".ss_solicitudes WHERE numcte = cNumCteBco AND num_solicitud <> o_numsol  AND  tipo_solicitud = "C" AND status_solicitud NOT IN ('PC','AN','MC')) > 0 THEN
		LET cCteProsp = null;
		LET cStatusSolic = null;
		LET cPiloto	= '1';
		
	END IF;
	
--SELECT flag_envia_os INTO cRespuestaOs 		 --SELECCIONA SI EL CLIENTE FUE 
--FROM bdinteg:"informix".si_ctes_manttodomIFE --MARCADO CON DOMICILIO DIFERENTE A SU 
--WHERE numcte = vCte							 --IFE 	
--AND empresa = o_empresa
--AND flag_envia_os = '1';						--CAMPO fecha_respuesta_os DE LA TABLA si_ctes_manttodomife.

--	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cRespuestaOs = '0'; -- NO SE ACTIVARA LA BANDERA SI NO EXISTE EL REGISTRO DEL CLIENTE
--	END IF;
	--SI EL CLIENTE FUE MARCADO CON DOMICILIO DIFERENTE A SU IFE SE ENVIARA A ORDEN DE SUPERVISION
	IF cRespuestaOs = '1' AND v_tpsol <> "C" THEN
		SELECT valor_alfabetico 
		INTO cMsjStatus
		FROM "informix".ss_param_solicitudes 
		WHERE secuencia = 14
		AND num_parametro = 14;
	
		LET iMotivoOs = 14;  --Domicilio dIFerente a IFE
		LET cGeneraOs = '1';
		--LET vNuevoStatus = 'EE'; --SE ENVIARA A ORDEN DE SUPERVISION
		--LET vMensajeStatus = vMensajeStatus;
	ELSE 
		LET cRespuestaOs = '0';	
	END IF;

    if v_tpsol  = 'P' then
      EXECUTE PROCEDURE bdisolic:"informix".sp_validageneraos(o_empresa, vCte,o_numsol,v_hoy  ) into  scod_ret, vValidaOS;
	end if;
  
   	-- SE IMPLEMENTA BANDERA PARA PRUEBA PILOTO
		IF  cPiloto = '1' THEN
			EXECUTE PROCEDURE bdisolic:"informix".sp_os_consultatipo3(o_empresa, vCte,cProducto,2 ) into  scod_ret, vRTipo3, vVigente;  
		END IF;
  /* Inicia Validacion Envia OS*/

    EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(o_empresa, v_hoy,vCodUdi,vClase,'0')
    INTO scod_ret,vTpCambioUdi;

    IF scod_ret<>'00000' THEN
       RETURN scod_ret;
    END IF;

    EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(o_empresa, v_hoy,vCodUs,vClase,'1')
    INTO scod_ret,vTpCambioUs;

    IF scod_ret<>'00000' THEN
       RETURN scod_ret;
    END IF;
-- FIN CAS obtiene la fecha del dia
LET scod_ret      = "000";

-- Lee tabla propecteo para buscar solicitudes por otros canales ini
	
	SELECT estatus, canal_sol 
  	  INTO cStatusprospecteo, cCanalv1
	  from bdisolic:"informix".ss_prospecteo_solicitudes
	 where num_solicitud = o_numsol 
	 AND estatus <> 'F';
--	 and status_solicitud is null;-- and canal_sol='0';

	if (cCanalv1 is null) then	
		let cCanalv1 = 99;
		LET cStatusprospecteo = nvl(cStatusprospecteo,'');
	end if;
	--JIBC Cambio verificar si el canal es un canal web
	IF exists (select * from bdisolic: ss_canales_solic where canal_solic = cCanalv1 and flag_canal_dud = 'A') then 
		LET sFlagCanalWeb = 1;
		--validar que la solicitud venga por el canal digital(autosolicitudes) capturada con cobranza y no por el canal movil
		if cCanalv1 = 2 and cSucursal <> '8503' then 
			LET sFlagCanalWeb = 0;
		end IF 
	END IF;
-- Lee tabla propecteo para buscar solicitudes por otros canales fin



	select count(*) into iNewMPP from bdisolic:"informix".ss_param_mpp where empresa = '001' and idSuc = cSucursal and produc = cProducto  ;
	--RQM 69 613 FIN
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
--*********************************
    --Ini  Caja Unica . Viridiana
    --*********************************

	  SELECT valor
        INTO v_meses_hist_inter
        FROM "informix".ss_param
       WHERE empresa = o_empresa
         AND secuencia = 328;
        -- **************************************
        -- Inicia Proceso de Circulo de Credito *
        -- **************************************
   -- ini Caja Unica. Viridiana
   -- Obtiene la secuencia de la ultima consulta del cliente que se consulto en Buro y/o Circulo de Credito
    -- SELECT NVL(MAX(nvl(secuenciaconsulta,1)),1)
      --INTO sConsulta
      --FROM bdiburo:sb_regreso
     --WHERE numcte = vCte;
    -- Fin Caja Unica. Viridiana

    EXECUTE PROCEDURE "informix".cal_circulocredito_cjunk(o_empresa, vCte, o_numsol)
                 INTO scod_ret, v_respsic, vCompromisos, vMensaje;

   IF scod_ret <> "000" THEN
       RETURN scod_ret;
   END IF

	IF cProducto = '7800' THEN--RQM 10 617 Anticipo de Nomina
		LET v_respsic ="X";
		LET vCompromisos =0;
		LET v_importe_hip =0;
		LET vMensaje ="";
	END IF
   
/*-- DETERMINA GRUPO A INI -- Se mueve a sp_obtienegrupo
    SELECT COUNT(*)
      INTO vgrupo6
      FROM bdicred:"informix".sd_grupo_cliente 
     WHERE empresa = o_empresa
       AND numcte  = vCte;

    IF ( vgrupo6 > 0 ) THEN
        LET vAsignaGrupo = 'A';
    END IF;*/
	--RQM 69 613 INI
	SELECT COUNT(TL06) INTO vCuentasPF FROM BDIBURO: "informix".BR_TL WHERE TL06 = 'I' AND NUM_CLIENTE = vCte;
	IF v_respsic = 'X' THEN
		LET vTipoHit= 3;
		
	ELIF(vCuentasPF > 3) THEN 
		LET vTipoHit = 2;
		
	ELSE 
		LET vTipoHit = 1;
		
	END IF;	

	UPDATE "informix".ss_solicitudes SET tp_gen_planpago=vTipoHit  WHERE empresa = o_empresa AND num_solicitud = o_numsol;  
	
	IF cProducto <> '7800' THEN 
	--- REALIZA LA CONSULTA PARA OBTENER EL MONTO DEL HIPOTECARIO Y BIENES RAICES RQM 09 408
		FOREACH		  
			SELECT a.tl08,a.tl12,b.factor
			INTO v_moneda,v_imp_hip,v_factor
				FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b 
				WHERE a.tl11 = b.tipo
					AND num_cliente = vCte
					AND tl07 IN ('RE','MI') AND tl12 <> 0 
					AND ((tl06 IN ('M','I') and tl02 <> 'SIC')
					AND (tl02 = 'BIENES RAICES' OR tl02 MATCHES "HIPOTECA*"))
			UNION ALL
			SELECT  a.tl08,a.tl12,b.factor
				FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b 
				WHERE a.tl11 = b.tipo
					AND num_cliente =  vCte AND tl12 <> 0 
					AND tl06  = 'M' AND tl07 = 'MI' AND tl02 MATCHES "HIPOTECA*"
							
				IF (v_moneda = 'N$' OR v_moneda = 'MX') THEN 
				   LET v_tot_tp = v_imp_hip * v_factor; 
				   IF v_imp_hip > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
				   ELSE LET v_imp_hip = 0; END IF;
				END IF;
				IF v_moneda = 'UD' THEN  
				   LET v_tot_tp = vTpCambioUdi * (v_imp_hip * v_factor);
				   IF v_imp_hip > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
				   ELSE LET v_imp_hip = 0; END IF;
				END IF;
				IF v_moneda = 'US' THEN
				   LET v_tot_tp = vTpCambioUs * (v_imp_hip * v_factor);			
				   IF v_imp_hip > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
				   ELSE LET v_imp_hip = 0; END IF;
				END IF;
				LET v_importe_hip = v_total;
		END FOREACH;
    END IF;
-- DETERMINA GRUPO A FIN


------------------------------------REEVALUACION--------------------------------------------------------------------------------------	

   -- Evalua si la solicitud es candidata a realizar reasignacion de rubro (No Hit a Hit) INI
   IF nvl(v_respsic,'X') = 'X' AND cProducto <> '7800' AND v_tpsol = 'T' THEN

        -- Realiza la reevaluacion del modelo si es No Hit y cumple con las condiciones de variables BC_# se cambia Hit
        EXECUTE PROCEDURE "informix".sp_reevalua_rubro_sols(o_empresa, o_numsol, vMensaje) INTO cCodReRub, vMsg_Reasig, v_Reasig_rubro;

        LET cCodReRub = '000000';
        IF v_Reasig_rubro = '1' THEN    -- Si se realiza cambio de rubro se cambian datos
            LET v_respsic = '0';
            LET vMensaje = vMsg_Reasig;
        END IF

   END IF;
    -- Revisa reasignacion rubro FIN.

   UPDATE "informix".ss_resum_scor_fin
      SET evalua_cc = v_respsic,
          motivo_cc = vMensaje,
          pago_minimo = vCompromisos,
          secuenciaconsulta = sConsulta, -- Caja Unica. Viridiana          
		  --grupo = vAsignaGrupo,  -- Asigna Grupo/ mahr-cnbv se elimina actualizacion, se asigna gpo desde sp_obtienegrupo
		  monto_hipoteca = v_importe_hip
    WHERE empresa = o_empresa
      AND num_solicitud = o_numsol;
	  
----------------------------------------------------------------------------------------------------------------------------------------------	 

	 
    -- mahr-cnbv Se actualiza el grupo para que los calculos se realicen en base a ese grupo.
    UPDATE bdisolic:"informix".ss_revision_determinacion SET monto_hipoteca = v_importe_hip, evalua_cc = v_respsic, compromiso_sic = vCompromisos,
		   tipo_cambio_udi = vTpCambioUdi, tipo_cambio_dls = vTpCambioUs
     WHERE empresa = o_empresa AND num_solicitud = o_numsol;
		
	IF v_respsic in ('1','2','3','4') AND v_tpsol NOT IN ('C')  THEN --JMAH  Solicitudes coppel no se rechazan
        LET vNuevoStatus = 'RT';
        IF cStatusSolicitud = "BC" THEN
		   LET cCausa_sol = "RBC";
		ELIF cStatusSolicitud = "CC" THEN
		   LET cCausa_sol = "RCC";
		END IF;
        LET vMensajeStatus = 'Evaluacion Crediticia Negativa. Solicitud No Aprobada';
      
	  
	   EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, vNuevoStatus, cCausa_sol, vMensajeStatus)
                        INTO p_cod_ret;

           IF p_cod_ret <> '000000' THEN
               LET scod_ret= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
               RETURN scod_ret;
           END IF;
          IF NVL(cNumSol,'') <> '' THEN	
			  UPDATE "informix".ss_solicitudes_movil		
					SET status = '3',--finalizado
					descripcion_status = vMensajeStatus 
				WHERE 	empresa  = o_empresa 
				AND  num_solicitud = o_numsol;
		  END IF;
		   RETURN scod_ret;
	 END IF; 

    -- ********************************
    -- Inicia Proceso de Calificacion *
    -- ********************************
    FOREACH
        SELECT {+INDEX (ss_scoring_seccion)}
		DISTINCT(b.seccion)
          INTO v_seccion
          FROM "informix".ss_scoring_seccion a, "informix".ss_scoring_solic b
         WHERE a.empresa = o_empresa
           AND a.seccion = b.seccion
           AND b.empresa = a.empresa
           AND b.secuencia > 0
           AND b.tp_solicitud = v_tpsol
           AND b.seccion > 0
           AND b.tpo_persona > 0
           AND b.activa = '1'
           AND a.automatico = "0"
    END FOREACH;
    
           -- *******************************
       -- Evalua Antiguedad del Cliente *
       -- *******************************
       -- Extrae Valor de Parametro
    SELECT valor
      INTO v_cuantos
      FROM "informix".ss_param
     WHERE empresa = o_empresa
       AND secuencia = 300;

    SELECT valor
      INTO v_EficienciaCoppel
      FROM "informix".ss_param
     WHERE empresa = o_empresa
       AND secuencia = 320;

       -- Extrae Valores del Cliente
   SELECT situacion_pago,meses_historia,puntualidad,situacion_credito,
          fuente,causa,fecha_ultima_compra,ingreso_mensual, NVL((abonomensualropa+abonomensualmuebles+abonomensualprestamos),0),
		  (linea_tienda  * .10),tipo_movimiento,num_solicitud_ref, linea_tienda --se agrega linea_tienda 
     INTO v_SituacionPagoCoppel,v_meses,v_PuntualidadCoppel,cSituacionCredito,cOrigen,
          sCausa,dUltimaCompra,v_ingreso_neto, vcompromiso_rmp,v_compteorico,
		  cTipoMovto,cNumSolRef	, v_linea_tienda --se agrega v_linea_tienda 	  
     FROM "informix".ss_resum_scor_fin
    WHERE empresa =  o_empresa
      AND num_solicitud = o_numsol;	  
	  
   IF v_SituacionPagoCoppel IS NULL THEN
       LET v_SituacionPagoCoppel= 0;
   END IF;

   IF  ( v_SituacionPagoCoppel = 0 AND NVL(v_meses,0) = 0 ) OR cProducto ='6500' THEN --JMAH 09 279 
		LET iEnviarMC = 1;
   END IF;
   
   LET v_eficiencia=v_SituacionPagoCoppel;
   LET v_meses_hist = v_meses;
   --se valida la eficiencia y meses de Historia RQM 09 324-2
	   IF (( v_eficiencia < 0 and v_meses_hist >= v_meses_hist_inter ) AND v_tpsol <> 'C') THEN		   
		   IF iMotivoOs = 0  THEN
			   LET iMotivoOs = 12;    -- Tipo Cliente 3
               Let cGeneraOs = '1';		
		   END IF
	   END IF;	
   -- clientes coppel sin compras, se le da tratamiento de cliente nuevo
   IF ( v_SituacionPagoCoppel < 0  ) and v_tpsol NOT IN ('C') THEN
       LET v_meses = 0;
       LET v_SituacionPagoCoppel = 0;
	   IF iMotivoOs = 0  THEN LET iMotivoOs = 2;   END IF;   --Eficiencia
   END IF;
   
   IF v_PuntualidadCoppel IS NULL THEN
       LET v_PuntualidadCoppel= "";
   END IF;

    LET vAntiguedad = "0";

    IF (v_meses <= v_cuantos) and v_tpsol NOT IN ('C') THEN
        LET vAntiguedad = "1";
		IF iMotivoOs = 0  THEN
			LET iMotivoOs = 1;		--Cte Nuevo	
		END IF--JMAH
    END IF;

    -- se les asigno vAntiguedad = "0";
    -- a los clientes con 1 mes de antiguedad
    -- lalo 28jun07
    IF (v_meses = 1) and v_tpsol NOT IN ('C') THEN
        LET vAntiguedad = "0";
		IF iMotivoOs = 0  THEN   --Cte Nuevo
			LET iMotivoOs = 1;		
		END IF--JMAH
    END IF;

        IF v_mod_parame=2 AND v_tpsol NOT IN ('C') THEN--JMAH

			IF cProducto = '7800' THEN--RQM 10 617 Anticipo de Nomina
				--obtener la cuenta ligada al credito				 
				SELECT LIMIT 1 cuenta_nomina,movil_cuenta
				INTO cCuenta ,cTelCel
				FROM "informix".ss_adn_solicitudcuenta
				WHERE empresa = o_empresa
				AND numcte  =  vCte;
				
		
					EXECUTE PROCEDURE "informix".sp_adn_calculalinea(o_empresa,vCte, cCuenta)
					INTO cCodRetAdn,iValidoAdn,v_lineaban;					
			
			
				IF v_lineaban = 0 THEN
					LET vMensajeStatus= 'Depositos de Nomina Insuficientes';
					LET VNuevoStatus = 'RT';
					LET cCausa_sol = 'DNI';

					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, VNuevoStatus, cCausa_sol, vMensajeStatus )
					INTO p_cod_ret;
					
					--?Tu solicitud del Anticipo de Nomina no concluyo satisfactoriamente, acude a tu sucursal BanCoppel para que te expliquemos el motivo ?.
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_3' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;	
					
					UPDATE "informix".ss_adn_solicitudcuenta
						SET num_solicitud = '', linea	= v_lineaban		
					WHERE numcte =vCte;
					RETURN scod_ret;		
				

				END IF;
				
				UPDATE "informix".ss_adn_solicitudcuenta
					SET linea = v_lineaban
				WHERE empresa = o_empresa
				AND numcte  =  vCte;
				
			ELSE
				IF v_tpsol <> 'P' THEN
				
					EXECUTE PROCEDURE "informix".determina_lincred_tc_cjunk(o_empresa,o_numsol,vAntiguedad)
					INTO p_cod_ret, v_lineaban,v_capacidad_pago,iPlazo;
				ELSE
					EXECUTE PROCEDURE "informix".determina_lincred_tc_cjunk_ver_2016(o_empresa,o_numsol,vAntiguedad)
					INTO p_cod_ret, v_lineaban,v_capacidad_pago,iPlazo;		
				END IF;
				
			END IF;
			
		---Casteo para continuidad del sp	
			LET v_lineaban = v_lineaban::DECIMAL(18,2);
			LET v_capacidad_pago = v_capacidad_pago::DECIMAL(18,2);
			
			--RQM 69 613 INI
			IF iNewMPP > 0 THEN
				EXECUTE PROCEDURE "informix".calulavariables_modelo2_pp(o_empresa,o_numsol) INTO p_cod_ret, vMensaje,vScore;
			ELSE 
				EXECUTE PROCEDURE "informix".calulavariables_modelo2(o_empresa,o_numsol,v_lineaban,v_capacidad_pago) INTO p_cod_ret, vMensaje;
		    END IF;
			--RQM 69 613 FIN

            IF p_cod_ret <> '000' then
                LET scod_ret= '00007'; -- ocurrio un error al calcular las variables del modelo2
                RETURN scod_ret;
            ELSE
                LET p_cod_ret= "000000";
            END IF;

	       IF v_tpsol IN ('T','C') THEN
	           UPDATE "informix".ss_solicitudes
	              SET monto_solicitado = v_lineaban,
	                  capacidad_pres = v_capacidad_pago
	            WHERE empresa = o_empresa
	              AND num_solicitud = o_numsol;
           END IF;
           --- Consulta el grupo asignado a la solicitud, para la consulta de puntos de quiebre
           SELECT NVL(grupo,'') INTO vgrupo_sol FROM "informix".ss_resum_scor_fin -- mahr
            WHERE empresa = o_empresa AND num_solicitud = o_numsol;
        END IF;

        -- *******************************************************
       -- Realiza la suma de los valores de la seccon 2
       -- ********************************************************
    EXECUTE PROCEDURE "informix".calculo_parametrico(o_numsol)
                 INTO v_valor_2s;

    IF  v_valor_2s IS NULL THEN
        LET  v_valor_2s= 0; -- No se localizaron puntos a sumar para la seccion 2
    END IF;
    -- ********************************
    -- Califica Comportamiento Interno*
    -- ********************************
  IF v_mod_parame=1 THEN
    -- Clientes coppel sin compras (con situacion de pago < 0) se le califica como un cliente nuevo
    SELECT a.puntuacion
      INTO v_valor_1s
      FROM "informix".ss_scoring_financ a, "informix".ss_resum_scor_fin b
     WHERE a.empresa = o_empresa
       AND a.tp_solicitud = v_tpsol
       AND a.secuencia > 0
       AND b.empresa= a.empresa
       AND b.num_solicitud= o_numsol
       AND a.circulo_credito = DECODE (b.evalua_cc,"X","X","0","0","2","1","3","1","4","1","1")
       AND DECODE(b.situacion_pago,-1,0,b.meses_historia) >= a.min_mes_hist
       AND DECODE(b.situacion_pago,-1,0,b.meses_historia) <= a.max_mes_hist
       AND DECODE(b.situacion_pago,-1,0,b.situacion_pago) >= a.min_porc_pago
       AND DECODE(b.situacion_pago,-1,0,b.situacion_pago) <= a.max_porc_pago
       AND a.tp_cliente = vAntiguedad;

       IF v_valor_1s IS NULL THEN
            LET v_valor_1s = 0;
       END IF;
  ELSE
-- AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended INICIO{  
	IF v_respsic = 'X' THEN
		LET v_valor_1s = -1;
--IPCB Marzo2016 RQM 09 398-0 FICO Extended --Inicio //Almacena el valor del Fico Extended
	/*	SELECT min(pro_scormax)
		  INTO v_scp_min
		  FROM "informix".ss_scoring_modelo2
		 WHERE tp_solicitud  = v_tpsol
		   AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
		   AND grupo = vgrupo_sol   
           AND num_producto = cProducto		   
		   AND tp_parametrico = 2; 
		
		IF v_valor_2s <= v_scp_min THEN --VALIDA SI ENTRA O NO A FICO EXTENDED
		SELECT sc01::INTEGER    
		  INTO v_valor_4s
		  FROM bdiburo:"informix".br_sc a
		 WHERE a.rowid = (SELECT MAX(b.rowid) FROM bdiburo:"informix".br_sc b WHERE institucion   = 'CC' AND b.num_cliente= vCte )
		   AND institucion = 'CC'
           AND num_cliente=vCte;
		ELSE
		LET v_valor_4s = 0;
---		   IF EXISTS (SELECT * FROM "informix".ss_autorizacion WHERE empresa = o_empresa AND num_solicitud= o_numsol AND status_solicitud = 'CC') THEN
				DELETE  "informix".ss_autorizacion 
			     where empresa = o_empresa
			      and  num_solicitud= o_numsol
				  and  status_solicitud ='CC';
		   END IF;	
		END IF;
		
	    IF v_valor_4s is null THEN 
			LET v_valor_4s = 0; 
	    END IF; */
--IPCB Marzo2016 RQM 09 398-0 FICO Extended --Fin	
	ELSE	
-- }FIN AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended						 
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE  	-- Se integrar el filtro de la institucion BC
		SELECT sc01::INTEGER
		  INTO v_valor_1s
		  FROM bdiburo:"informix".br_sc a
		 WHERE a.rowid = (SELECT MAX(b.rowid) FROM bdiburo:"informix".br_sc b WHERE institucion = 'BC' AND b.num_cliente= vCte AND sc00 <> "004")
		   AND institucion = 'BC'
		    AND num_cliente = vCte AND sc00 <> "004";   

		IF v_valor_1s < 0 THEN
			LET v_valor_1s = -1;
		ELIF v_valor_1s IS NULL THEN
			LET v_valor_1s=0;             
		END IF;	
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE --Se extrae el valor de FICO (CC)                    
		SELECT sc01::INTEGER
		  INTO v_valor_3s
		  FROM bdiburo:"informix".br_sc a
	     WHERE a.rowid = (SELECT MAX(b.rowid) FROM bdiburo:"informix".br_sc b WHERE institucion = 'CC' AND b.num_cliente= vCte AND sc00 <> "004")
		   AND institucion = 'CC'
		   AND num_cliente=vCte AND sc00 <> "004";

		IF v_valor_3s < 0 THEN
			LET v_valor_3s = -1;
		ELIF v_valor_3s IS NULL THEN
			LET v_valor_3s= 0;				
		END IF;
-- AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended INICIO{  
	END IF;
-- }FIN AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended						 
  END IF;

    -- mahr-cnbv
    UPDATE bdisolic:"informix".ss_revision_determinacion SET situacion_pago = v_SituacionPagoCoppel, meses_historia = v_meses, 
                     situacion_credito = cSituacionCredito, bs_score = v_valor_1s, score_prop = v_valor_2s, fico_score = v_valor_3s, linea_tienda = v_linea_tienda
     WHERE empresa = o_empresa AND num_solicitud = o_numsol;

	 
	 
    -- *************************************
    -- Almacena Resultado de la Evaluacion *
    -- *************************************
   LET v_valor = v_valor_2s + (CASE WHEN v_valor_1s < 0 THEN 0 ELSE v_valor_1s END);

   DELETE FROM "informix".ss_resumen_scoring
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol;

   DELETE FROM "informix".ss_autorizacion
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol
           AND status_solicitud IN ("RT","EE");

        -- Se inserta valor de la seccion 1
   INSERT INTO "informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
        VALUES (o_empresa, o_numsol, 1, v_valor_1s);

        --Se inserta valor de la seccion 2
    INSERT INTO "informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
         VALUES (o_empresa, o_numsol, v_seccion, v_valor_2s);
 
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE/Se inserta valor de la seccion 3
    INSERT INTO "informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
         VALUES (o_empresa, o_numsol, 3, v_valor_3s);
--IPCB Marzo2016 RQM 09 398-0 FICO Extended
-- AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended INICIO{ 
/*	INSERT INTO "informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
		 VALUES (o_empresa, o_numsol, 4, v_valor_4s);	*/
-- }FIN AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended
------------------------------------------------------------------------------------------
--                                   SCORE COPPEL                                       --
------------------------------------------------------------------------------------------
LET o_numsol = o_numsol;
LET cNumSolRef = cNumSolRef;
       IF cTipoMovto = 'M' THEN
	    	 IF v_tpsol = 'C' THEN
			 --REGISTRA EL SCORE COPPEL DE LA SOLICITUD COPPEL 
				SELECT puntos_parcn 
				INTO cScorecoppel
				FROM bdisolic:"informix".ss_nuevo_parametrico 
				WHERE num_solicitud = o_numsol
				AND empresa = o_empresa;
				
			 ELIF v_tpsol = 'T' THEN		 
			 --REGISTRA EL SCORE COPPEL DE LA SOLICITUD COPPEL 
				SELECT puntos_parcn 
				INTO cScorecoppel
				FROM bdisolic:"informix".ss_nuevo_parametrico 
				WHERE num_solicitud = cNumSolRef
				AND empresa = o_empresa;	
			 END IF;
	   
	   ELIF cTipoMovto = 'U' THEN
	   
			--REGISTRA EL SCORE COPPEL DE LA SOLICITUD COPPEL/BANCO
			SELECT puntos_parcn 
			INTO cScorecoppel
			FROM bdisolic:"informix".ss_nuevo_parametrico 
			WHERE num_solicitud = o_numsol
			AND empresa = o_empresa;		
		
		END IF;	
		
		 IF cScorecoppel IS NULL OR cScorecoppel = '' THEN
		  LET cScorecoppel = 0;
		 END IF;
		
	--INSERTA EL SCORE COPPEL CON SECCION 6 EN LA TABLA ss_resumen_scoring		
		  -- IF v_tpsol IN ('T','C') AND cTipoMovto IN ('M','U') THEN	
		   IF cProducto IN ('6001','6500') AND cTipoMovto IN ('M','U')  THEN
		   
		       IF (cProducto = '6001' AND v_respsic = '0') OR cProducto = '6500' THEN                            
                        IF cScorecoppel = 0 THEN
                          LET cScorecoppel = 0;
                        ELSE			
							LET bc_Score_orig = 	v_valor_1s;		
							LET v_valor_1s = cScorecoppel;
							LET cParametrico = '4';	
							
							-- INI RQM 09 606 Se agrega condicion cuando la SIC sea CC y con fallo, para sustituir el valor del score CC por ScoreCoppel
							IF vInstitucion = 'CC' AND vFalloSIC = 1 THEN
								LET v_valor_3s = cScorecoppel;
								LET cParametrico = '4';
							END IF;
							-- FIN RQM 09 606
						END IF;
			               
			  
				  LET o_numsol = TRIM(o_numsol);
				  LET cScorecoppel = cScorecoppel;
				  LET pSeccion = '6';
				  LET o_empresa = '001';
								  
				  INSERT INTO bdisolic:"informix".ss_resumen_scoring(empresa,num_solicitud,seccion,evaluacion) VALUES (o_empresa,o_numsol,pSeccion,cScorecoppel);
				 
			   END IF;	    		
			 
		   END IF;	    
			LET v_valor_1s = v_valor_1s;	
			LET v_valor_2s = v_valor_2s;
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
    -- ************************************
    -- Valida Resultado de la  Evaluacion *
    -- ************************************
    IF v_mod_parame=1 THEN
        SELECT SUM(evaluacion_min)
          INTO iTotalParametrico
          FROM "informix".ss_scoring_solic
         WHERE empresa = o_empresa
           AND tp_solicitud = v_tpsol
		   AND num_producto = cProducto --JMAH RQM 10 617
           AND seccion IN (1,2)
           AND (min_porc_pago <= v_SituacionPagoCoppel
           AND max_porc_pago >= v_SituacionPagoCoppel)
           AND (min_mes_hist <= v_meses
           AND max_mes_hist >= v_meses)
           AND activa = '1';

       IF iTotalParametrico IS NULL THEN
           LET iTotalParametrico = 0;
       END IF;
	ELIF v_mod_parame=2 AND v_tpsol NOT IN ('C') THEN
	
		SELECT  NVL(flag2credito,0) INTO iFlag2credito
		FROM "informix".ss_revision_determinacion					 
		WHERE empresa = o_empresa
		AND num_solicitud = o_numsol;
		
		IF iFlag2credito = 1 THEN --RQM 09 392
			EXECUTE PROCEDURE bdicred:"informix".sp_valida2Credito (o_empresa, vCte, o_numsol, 1)
				INTO  cCodRet2Cred,iFlag2credito,iValorICC;
			
			INSERT INTO "informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
			 VALUES (o_empresa, o_numsol, 5, iValorICC);
				--RQM 69 613 INI
				IF iNewMPP > 0 THEN
				--IF cProducto in('6300','6800','7600','7700') Then
					SELECT status_sol 
					INTO VNuevoStatus
					FROM "informix".ss_scoring_modelo2_pp
					WHERE tp_solicitud  = v_tpsol
					AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")			 
					AND v_valor_1s BETWEEN bc_scoremin AND bc_scoremax			 
					AND iValorICC BETWEEN icc_min AND icc_max --RQM 09 392
					AND tp_parametrico = cParametrico -- se parametriza el tipo de parametrico actual
					AND tipo_modelo_hit = vTipoHit;
				ELSE
					SELECT status_sol 
					INTO VNuevoStatus
					FROM "informix".ss_scoring_modelo2
					WHERE tp_solicitud  = v_tpsol
					AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")			 
					AND v_valor_1s BETWEEN bc_scoremin AND bc_scoremax			 
					AND iValorICC BETWEEN icc_min AND icc_max --RQM 09 392
					AND tp_parametrico = cParametrico; -- se parametriza el tipo de parametrico actual
				 END IF;
				--RQM 69 613 FIN
				 
				 IF VNuevoStatus ="RT" THEN
					LET VNuevoStatus ="";
					LET iFlag2credito = 0;
					UPDATE "informix".ss_revision_determinacion
					  SET flag2creditoicc = 1
					WHERE empresa = o_empresa
					  AND num_solicitud = o_numsol;
				 END IF;
			 
		END IF;
		
		IF iFlag2credito = 0 THEN --RQM 09 392		
		
			--RQM 69 613 INI
			IF iNewMPP > 0 THEN
			--IF cProducto in('6300','6800','7600','7700') Then	
				SELECT UNIQUE status_sol 
				INTO VNuevoStatus
				FROM "informix".ss_scoring_modelo2_pp
				WHERE tp_solicitud  = v_tpsol
				AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
				AND num_producto = cProducto--JMAH RQM 10 617
				AND grupo = vgrupo_sol             -- mahr
				AND v_valor_1s BETWEEN bc_scoremin AND bc_scoremax
				AND v_valor_2s BETWEEN pro_scormin AND pro_scormax
				AND tp_parametrico = cParametrico -- se parametriza el tipo de parametrico actual
				AND tipo_modelo_hit = vTipoHit;		   
		   	ELSE
		   	
				IF cParametrico = 4 and bc_Score_orig = -1 THEN
				LET v_respsic = 'X';
				--INI.- Se asigna como NO HIT, unicamente para la consulta ss_scoring_modelo2 para obtener el estatus, ya que no existen registros de Hit Sin informacion.
				-- los puntajes de hit sin informacion se encuentran dentro de los registros marcados como No Hit. (Asignacion temporal)
				END IF;
				-- INI RQM 09 606 Se agrega bloque donde se obtiene el valor de FICOScore para solicitudes CC con fallo en SIC
				IF vInstitucion = 'CC' AND vFalloSIC = 1 THEN
					
					SELECT UNIQUE status_sol 
					INTO VNuevoStatus
					FROM "informix".ss_scoring_modelo2
					WHERE tp_solicitud  = v_tpsol
					AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
					AND num_producto = cProducto--JMAH RQM 10 617
					AND grupo = vgrupo_sol             -- mahr
					AND v_valor_3s BETWEEN fc_score_min AND fc_score_max
					AND v_valor_2s BETWEEN pro_scormin AND pro_scormax
					AND tp_parametrico = cParametrico; -- se parametriza el tipo de parametrico actual
				-- FIN RQM 09 606
				ELSE
					SELECT UNIQUE status_sol 
					INTO VNuevoStatus
					FROM "informix".ss_scoring_modelo2
					WHERE tp_solicitud  = v_tpsol
					AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
					AND num_producto = cProducto--JMAH RQM 10 617
					AND grupo = vgrupo_sol             -- mahr
					AND v_valor_1s BETWEEN bc_scoremin AND bc_scoremax
					AND v_valor_2s BETWEEN pro_scormin AND pro_scormax
					AND tp_parametrico = cParametrico; -- se parametriza el tipo de parametrico actual
					IF cParametrico = 4 and bc_Score_orig = -1 THEN
					LET v_respsic = '0';
					-- FIN.- Asignacion temporal, se regresa su dato evaluac_cc original: No hit
					END IF;
				END IF;
			END IF;
			--RQM 69 613 FIN
		     IF VNuevoStatus IS NULL OR VNuevoStatus = '' THEN
		        LET VNuevoStatus = 'RT';
		     END IF;  
		   
		   
		END IF;	
		
	
		IF VNuevoStatus = 'RT' THEN 		  
				  --Estatus de rechazo por bcscore
                IF cParametrico = '4' THEN
				   LET cCausa_sol = "RS3"; 
				   LET vMensajeStatus = 'Rechazo por score coppel y score propietario';
				END IF;
		-- AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended INICIO{
			IF  v_respsic = 'X'  THEN    --IPCB Marzo2016 RQM 09 398-0 FICO Extended
			/*
				SELECT UNIQUE status_sol_fcex
				  INTO VNuevoStatus
				  FROM "informix".ss_scoring_modelo2
				 WHERE tp_solicitud  = v_tpsol
				   AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
				   AND grupo = vgrupo_sol             
				   AND v_valor_4s BETWEEN fc_extended_min AND fc_extended_max
				   AND v_valor_2s BETWEEN pro_scormin AND pro_scormax
				   AND num_producto = cProducto
				   AND tp_parametrico = 2; 	
				
				IF VNuevoStatus is null or VNuevoStatus = '' THEN
					LET VNuevoStatus = 'RT';
				END IF;	*/
				IF VNuevoStatus = 'RT' THEN
					LET entra_cc = 1;
				END IF;   
			/*ELSE	 --IPCB Se comenta para RQM 09 554 INI
			-- }FIN AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended			
				SELECT UNIQUE status_sol_fc
				  INTO VNuevoStatus
				  FROM "informix".ss_scoring_modelo2
				 WHERE tp_solicitud  = v_tpsol
				   AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
				   AND grupo = vgrupo_sol             
					AND num_producto = cProducto--JMAH RQM 10 617
				   AND v_valor_3s BETWEEN fc_score_min AND fc_score_max
				   AND v_valor_2s BETWEEN pro_scormin AND pro_scormax
				   AND tp_parametrico = 2; 
					  
				IF VNuevoStatus is null or VNuevoStatus = '' THEN
					LET VNuevoStatus = 'RT';
				ELSE
					SELECT unique pro_scormin  INTO v_scp_min
					  FROM bdisolic:ss_scoring_modelo2
					 WHERE tp_solicitud IN ( 'T','P')
					   AND tp_solicitud = v_tpsol
					   AND grupo = vgrupo_sol
						AND num_producto = cProducto--JMAH RQM 10 617
					   AND grupo in ('1','2','3','5','A','8')
					   AND status_sol_fc = 'AT';	

					IF v_valor_2s < v_scp_min THEN
					  LET entra_cc = 0;
					ELSE  
					  LET entra_cc = 1;
					END IF;  
				END IF;*/--IPCB Se comenta para RQM 09 554 FIN
		-- AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended INICIO{ 
			END IF;
		-- }FIN AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended
 			IF VNuevoStatus = 'RT' THEN
                LET v_valor=0;
                LET iTotalParametrico=1;
			ELSE  --Si es diferente a RT la respuesta FICO
                LET v_valor=1;
                LET iTotalParametrico=1;
            END IF;  			 
		ELSE
			LET v_valor=1;
            LET iTotalParametrico=1;
        END IF;
          
	END IF;

    let vdiagpo3 = '';
    IF v_valor < iTotalParametrico THEN
        --    SELECT TRIM(valor) INTO vdiagpo3 FROM bdisolic:"informix".ss_parametrodias
        --     WHERE empresa = o_empresa AND fecha_aplica = today AND referencia = 'clientes testigo gpo 3';
        --       IF vdiagpo3 = '' OR vdiagpo3 IS NULL THEN
        --          LET vdiagpo3 = '';  
        --       END IF;
        --      IF v_meses < 6 AND (TRIM(vdiagpo3) = lpad(day(v_hoy),2,0)) and cOrigen <> 'T' THEN
                --NO REALIZA NINGUNA VALIDACION DEBIDO A RQM 09 188
        --         UPDATE bdisolic:"informix".ss_solicitudes SET dia_para_revisar = vdiagpo3::integer 
        ---          WHERE empresa = o_empresa AND num_solicitud = o_numsol;

        
        -- RQM 09 418 Filtro Parametrico  // Si vdiagpo3 tiene -1 => parametro apagado de filtro parametrico. Si vdiagpo3 = 0, es el contador de sols
        -- Verifica que el dia actual este dentro de los dias permitidos para la campania (codigo = '0')
        SELECT count(*) INTO iFiltroPrend FROM bdisolic:"informix".ss_parametrodias WHERE empresa = o_empresa AND fecha_aplica = v_hoy AND cod_tip_filtro = '0';

        SELECT {+INDEX (ss_parametrodias )}
		NVL(TRIM(valor),0), nvl(num_sol_por_dia,0) INTO vdiagpo3, iNumSolTotDia FROM bdisolic:"informix".ss_parametrodias WHERE empresa = o_empresa 
           AND grupo = vgrupo_sol AND respuesta_sic = (case when v_respsic = '1' then '0' else v_respsic end) AND cod_tip_filtro = '1';

        LET iFiltroParam = vdiagpo3::INTEGER;
        IF iFiltroParam > 0 AND iFiltroPrend > 0 THEN  -- Si aun quedan solicitudes por agregar al total Y la fecha actual este registrada como fecha valida.
           
            SELECT count(num_solicitud) INTO iNumSolDia FROM bdisolic:ss_filtro_paramtr WHERE empresa = o_empresa 
               AND grupo = vgrupo_sol AND respuesta_sic = (case when v_respsic = '1' then '0' else v_respsic end) AND fecha_insert = v_hoy; 

            IF iNumSolDia >= iNumSolTotDia THEN -- Si el ingresado en el dia es mayor o igual al TOTAL permitido por grupo al dia.
                LET iFiltroParam = 0; -- iguala a cero, para que ya no permita ingresar mas solicitudes en el dia.
            END IF;
        ELSE
            LET iFiltroParam = 0; -- No permite ingresar nvas sols, ya que el dia actual no esta permitido.
        END IF;

        IF iFiltroParam > 0 AND ( SELECT COUNT(*) FROM "informix".ss_scoring_modelo2
                                         WHERE tp_solicitud  = v_tpsol AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
                                           AND grupo = vgrupo_sol 
                                           AND v_valor_1s BETWEEN bc_scoremin AND bc_scoremax
                                           AND pro_scormin BETWEEN pro_scormin AND pro_scormax
                                           AND num_producto = cProducto--JMAH RQM 10 617
                                           AND tp_parametrico = cParametrico
                                           AND status_sol = 'AT'  ) > 0  
           AND v_tpsol = 'T' 
           AND ((Select count(num_solicitud) From bdisolic:"informix".ss_filtro_paramtr Where empresa = o_empresa AND num_solicitud = o_numsol) = 0) THEN

            LET VNuevoStatus = VNuevoStatus;                                           
            LET VNuevoStatus = 'AT';
            -- Inserta para relacion de solicitudes en filtro parametrico
            INSERT INTO bdisolic:"informix".ss_filtro_paramtr VALUES (o_empresa, o_numsol, vgrupo_sol, v_respsic, user, v_hoy); 

            -- Indica q la sol es parte del programa para el filtro parametrico 
            LET iFiltroParam = iFiltroParam - 1;
            LET vdiagpo3 = to_char(iFiltroParam);

            UPDATE bdisolic:"informix".ss_solicitudes SET dia_para_revisar = 1 WHERE empresa = o_empresa AND num_solicitud = o_numsol; 
            UPDATE bdisolic:"informix".ss_parametrodias SET valor = vdiagpo3 WHERE empresa = o_empresa AND grupo = vgrupo_sol 
               AND respuesta_sic = (case when v_respsic = '1' then '0' else v_respsic end) AND cod_tip_filtro = '1';

        ELSE  -- Valida Grupo 6
          
			/* RQM 09 515 Eliminacion aprobacion Grupo 6 TDC - INI
              -- RQM 07 057 ini
            IF  (v_tpsol = 'T' and cOrigen <> 'T' and v_respsic = 'X' and v_eficiencia = 0 and  v_meses_hist =  0 and vgrupo_sol <> '8' and cProducto <> '7800') THEN -- Valida grupo "6" TDC (NO COPPEL -  NO HIT)
                let vgrupo_sol ='6';
                EXECUTE PROCEDURE "informix".calculavariables_grupo6(o_empresa,o_numsol) INTO p_cod_ret, vMensaje;

                -- Se comenta llamado a sps, por el cambio de tipo de dato. Cambiar el tipo de retorno al sps afecta otros procesos actuales
                -- EXECUTE PROCEDURE "informix".calculo_parametrico(o_numsol) INTO v_valor_2s;
                -- Se calcula el puntaje asignado a la solicitud
                Let iSuma   = 0;    Let iPuntos = 0;

                Foreach
                    Select decode(nvl(sg.agrupar, ''), '', sum(nvl(dc.valor,0)), max(nvl(dc.valor,0))) as suma  Into iPuntos
                      From bdisolic:ss_detalle_scoring dc, bdisolic:ss_scoring_grupo sg, bdisolic:ss_solicitudes sol 
                     Where sg.empresa = dc.empresa 
                       and sg.grupo = dc.grupo                  and sg.seccion = dc.seccion 
                       and dc.num_solicitud = o_numsol		    and dc.seccion = '2' 
                       and dc.empresa = '001'                   and sol.num_solicitud = dc.num_solicitud 
                       and sol.empresa = dc.empresa 
                       Group By sol.num_solicitud, sg.empresa, sg.seccion, sg.agrupar 

                    Let iSuma = iSuma + iPuntos;

                End foreach;

                IF iSuma IS NULL THEN
                    LET  v_valor_2s = 0; -- No se localizaron puntos a sumar para la seccion 2
                ELSE
                    LET  v_valor_2s = round(((EXP(iSuma) / ( 1 + EXP(iSuma) ) ) * 1000),0);
                END IF;

                SELECT status_sol, causa_sol 
                  INTO VNuevoStatus, cCausa_sol
                  FROM "informix".ss_scoring_modelo2
                 WHERE tp_solicitud  = v_tpsol
                   AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
 					
					AND num_producto = cProducto --JMAH RQM 10 617
                   AND grupo = vgrupo_sol
				   AND num_producto = cProducto--JMAH RQM 10 617
                   AND v_valor_1s BETWEEN bc_scoremin AND bc_scoremax
                   AND v_valor_2s BETWEEN pro_scormin AND pro_scormax
                   AND tp_parametrico = 3; -- se parametriza el tipo de parametrico nuevo

                -- Borra puntaje del primer parametrico
                DELETE FROM "informix".ss_resumen_scoring  WHERE empresa = o_empresa AND num_solicitud = o_numsol and seccion = v_seccion;

                --Se inserta valor de la seccion 2
                INSERT INTO "informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
                   VALUES (o_empresa, o_numsol, v_seccion, v_valor_2s);

                -- Actualiza si es grupo 6 -- mahr-cnbv
                UPDATE "informix".ss_resum_scor_fin SET grupo = vgrupo_sol WHERE empresa = o_empresa AND num_solicitud = o_numsol;
                UPDATE bdisolic:"informix".ss_revision_determinacion SET grupo = vgrupo_sol, score_prop = v_valor_2s WHERE empresa = o_empresa AND num_solicitud = o_numsol;
                IF ( VNuevoStatus = 'RT' ) THEN
                    -- UPDATE "informix".ss_resum_scor_fin
                    --    SET grupo = vAsignaGrupo
                    --  WHERE empresa = o_empresa
                    --   AND num_solicitud = o_numsol; -- mahr-cnbv
                    LET vMensajeStatus = 'Puntos acumulados en Scoring fueron insuficientes para su Aprobacion';
                    EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, vNuevoStatus,cCausa_sol, vMensajeStatus)
                                    INTO p_cod_ret;
                    IF p_cod_ret <> '000000' THEN
                        LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                        IF NVL(cNumSol,'') <> '' THEN	
                            UPDATE "informix".ss_solicitudes_movil		
                               SET status = '3',--finalizado
                                   descripcion_status = vMensajeStatus 
                             WHERE empresa = o_empresa 
                               AND  num_solicitud = o_numsol;
                        END IF;
                        RETURN scod_ret;
                    END IF;
                    RETURN scod_ret;
                END IF;
            -- RQM 07 057 fin   

            ELSE -- SI NO es GRUPO 6  */	-- ==> RQM 09 515 Eliminacion aprobacion Grupo 6 TDC -- FIN
			
			IF v_tpsol <> 'C' THEN -- 20130531 --> NO SE RECHAZAN SOLICITUDES COPPEL POR NINGUNA CAUSA DEL PROCESO
				IF (entra_cc = 1 and vNuevoStatus = 'RT') AND  cProducto <> '7800' THEN --IPCB FICO
					--LET cCausa_sol = "RCC"; LET vMensajeStatus = 'Rechazo por mal antecedente en Circulo de Credito';       
					LET cCausa_sol = "RS3"; 
					LET vMensajeStatus = 'Puntos acumulados en Scoring fueron insuficientes para su Aprobacion';
			    ELIF (entra_cc = 0 and vNuevoStatus = 'RT') AND  cProducto <> '7800' AND cParametrico='4' THEN
					LET cCausa_sol = "RS3"; 
					LET vMensajeStatus = 'Rechazo por score coppel y score propietario';
				ELSE		   
					LET vNuevoStatus = 'RT';  
					LET cCausa_sol = "RS3"; 
					LET vMensajeStatus = 'Puntos acumulados en Scoring fueron insuficientes para su Aprobacion';
				END IF;		   
				EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, vNuevoStatus,cCausa_sol, vMensajeStatus)
						INTO p_cod_ret;
				IF p_cod_ret <> '000000' THEN
					LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
					--	           RETURN scod_ret;
				END IF;
				IF NVL(cNumSol,'') <> '' THEN	
					UPDATE "informix".ss_solicitudes_movil		
					   SET status = '3',--finalizado
						   descripcion_status = vMensajeStatus 
					 WHERE empresa = o_empresa 
					   AND num_solicitud = o_numsol;
				END IF;
				RETURN scod_ret;
			END IF
            --END IF; -- SI NO es GRUPO 6	==> RQM 09 515
        END IF; -- Filtro parametrico            
    END IF; /* IF v_valor < iTotalParametrico THEN */

   -- Valida si la situacion especial del cliente es motivo para generar os
    SELECT COUNT(generaos)
      INTO sSituacionOs
      FROM bdicred:"informix".sd_causas_cte_coppel
     WHERE empresa= o_empresa
       AND situacion= cSituacionCredito
       AND causa= sCausa
       AND generaos= '1';

   IF sSituacionOs > 0 THEN
       LET cGeneraOs = '1';
	   IF iMotivoOs = 0  THEN
			LET iMotivoOs = 3;		--Situaciones especiales
	   END IF--JMAH
   END IF;
    -- Valida para generacion de Orden de Supervision
    SELECT valor
      INTO v_cuantos
      FROM "informix".ss_param
     WHERE empresa = o_empresa
       AND secuencia = 319;

	IF v_tpsol NOT IN ('C') THEN
	   IF v_cuantos = 1 THEN
		   SELECT COUNT(numcte)
			 INTO vHuella
			 FROM bdinteg:"informix".si_clientecomparacionbanconomatch
			WHERE tipo = 6
			  AND numcte = vCte;
			
				IF vHuella = 0 THEN
				   SELECT COUNT(numcte)
					 INTO vHuella
					 FROM bdinteg:"informix".si_clientecomparacionbanco
					WHERE tipo = 7
					  AND numcte = vCte;
					IF vHuella > 0 THEN
						IF iMotivoOs = 0  THEN
							LET iMotivoOs =6;		-- No coincide la Huella bancoppel vs Coppel	
						END IF --JMAH
					END IF
				ELSE
					IF iMotivoOs = 0  THEN
						LET iMotivoOs = 6;		-- No coincide la Huella bancoppel vs Coppel	
					END IF--JMAH			  
				END IF;
		END IF;
   END IF;

   LET v_paso = "0";
   LET v_Desempleo= "0";

  /* SELECT elemento
	 INTO v_ElementoDesempleo
	 FROM bdisolic:ss_detalle_scoring
	WHERE empresa = o_empresa
	  AND num_solicitud= o_numsol
	  AND grupo= 7
	  AND seccion= 2;

       IF v_ElementoDesempleo = 6 THEN
           IF vAntiguedad = "1" THEN
               LET vMensajeStatus= 'CLIENTE NUEVO DESEMPLEADO';
           ELSE
               LET vMensajeStatus= 'CLIENTE COPPEL DESEMPLEADO';
           END IF;
               LET v_Desempleo= '1';
               LET v_paso = "0";
               LET VNuevoStatus = 'RT';

           EXECUTE PROCEDURE sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, vNuevoStatus, vMensajeStatus)
                        INTO p_cod_ret;

       IF p_cod_ret <> '000000' THEN
           LET scod_ret= '00005'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
           RETURN scod_ret;
       END IF;
       RETURN scod_ret;

       END IF;*/
--- GGG-100719 - Se agrega campo para validar si el producto excluye envio de OS 
		-- AAME RQM 10 1177 Se contempla el parametro envio_mesa_control para identificar el envio a mesa de control por producto
       SELECT NVL(monto_min_cred,0), id_excluye_os, envia_os, envio_mesa_control, obligado_solidario, captura_obligatoria
         INTO dMonto_min, v_id_excluye_os,v_envio_os, iProdMC, cbanobligadosol, ccapturaobligsol
         FROM bdicred:"informix".sd_definicion
        WHERE num_producto = cProducto
          AND empresa      = o_empresa;

 -- se agrega validacion de la respuesta de la os telefonica, en caso de que  se haya generado.
		--AAME 20180223 RQM 10 915 Se contempla nuevo codigo 149 de producto 6800 para enviar a MC
		--AAME 20150303 RQM 10 550 Se agregan nuevos codigos a la tabla de parametros para indicar los nuevos productos que se van a MC 
		--RQM 101177 Se reemplaza variable por parametro envio_mesa_control en la sd_definicion
		/*SELECT COUNT(valor)
			INTO iProdMC 
		FROM "informix".ss_param 
		WHERE empresa = o_empresa
		--AND secuencia in (149,150,151,152,153,154) 
		AND valor = cProducto;	*/
		  
		 SELECT COUNT(num_solicitud)
			INTO iSolMc
		FROM ss_solicitudes_mc
		WHERE empresa = o_empresa
		AND  num_solicitud = o_numsol; 
		
		
		SELECT COUNT(num_solicitud)
			INTO iSolMcAux 
		FROM ss_solicitudes_mc
		WHERE empresa = o_empresa
		AND  num_solicitud = cNumSolRef; 
		
		  
 EXECUTE PROCEDURE "informix".sp_OStelConsultaResultado (o_empresa,o_numsol)
		INTO scod_ret, cResultadoOsTel,cTieneOstel,cEnvioCat;

   IF scod_ret <> '000' THEN
       LET scod_ret = '00001';
       RETURN scod_ret;
   END IF

   IF NVL(cTieneOstel,'') = 'V' THEN
			IF nvl(cResultadoOsTel,'') = '' THEN--JMAH RQM 18 056
			   IF (iProdMC = 1) AND (iEnviarMC = 1 OR v_tpsol = 'C' ) AND iSolMc = 0 THEN--para que la solicitud aunque le falte la respuesta de OSTEL pase a MC a su revision
					LET iBanderaFaltaOSTEL = 1;
			   ELSE						  	
				   LET vNuevoStatus= 'ST';
				   LET cCausa_sol= "";
				   LET vMensajeStatus= 'En Supervision Telefonica';
				   EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, vNuevoStatus, cCausa_sol, vMensajeStatus)
								INTO p_cod_ret;
				   IF p_cod_ret <> '000000' THEN
					   LET scod_ret = '00002';
				   END IF;
				   IF NVL(cNumSol,'') <> '' THEN	
					   UPDATE "informix".ss_solicitudes_movil		
							SET status = '3',--finalizado
							descripcion_status = vMensajeStatus 
						WHERE 	empresa  = o_empresa 
						AND  num_solicitud = o_numsol;
					END IF;
				   RETURN scod_ret;
			   
			   END IF;
			ELSE

				IF cResultadoOsTel = 'V' THEN
				   LET cElementOs = 1;
				ELIF cResultadoOsTel = 'I' THEN
				   LET cElementOs = 2;
				ELIF cResultadoOsTel = 'S' THEN
				   LET cElementOs = 3;
				   LET banderaS =1;
				   IF iMotivoOs = 0  THEN
					LET iMotivoOs = 4; --JMAH   Respuesta S en supervision telefonica
				   END IF
				END IF;

				SELECT valor 
				 INTO dValorOs
				 FROM "informix".ss_scoring_pesos
				WHERE empresa= o_empresa
				  AND tp_solicitud= v_tpsol
				  AND grupo = 25
				  AND elemento = cElementOs;

				IF dValorOs IS NULL THEN
				   LET dValorOs = 0;
				END IF; 
				
					INSERT INTO "informix".ss_detalle_scoring (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor)
					VALUES (o_empresa, 2, 25,cElementOs, "01",o_numsol, dValorOs);
			END IF;	
--   ELSE 
--       LET vNuevoStatus = "EE";
   END IF;
	--se contempla validaciones para determinar el status de la solicitud de acuerdo a la OS telefonica y sus meses de historia del cliente		 
	IF cTieneOstel = 'V' AND iBanderaFaltaOSTEL =0 THEN--JMAH RQM 18 056
		SELECT resultado 
		  INTO cNuevoStatusOstel
		  FROM "informix".ss_ostel
		 WHERE empresa= o_empresa
		   AND tp_solicitud = v_tpsol
		   AND min_mes_hist <= v_meses
		   AND max_mes_hist >= v_meses
		   AND origen= cOrigen
		   AND os_tel = cResultadoOsTel;

		   IF NVL(cNuevoStatusOstel,"") = "" THEN
				IF EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN
					LET VNuevoStatus = "AT";
			   ELSE 
					LET VNuevoStatus = "EE";
			   END IF;
		   ELSE
               IF cNuevoStatusOstel = 'RT' then
				  LET cCausa_sol = 'RST';
				  LET vMensajeStatus = 'Rechazo por Supervision Telefonica';

				   EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, vNuevoStatus, cCausa_sol, vMensajeStatus)
									INTO p_cod_ret;
						IF NVL(cNumSol,'') <> '' THEN	
							UPDATE "informix".ss_solicitudes_movil		
								SET status = '3',--finalizado
								descripcion_status = vMensajeStatus 
							WHERE 	empresa  = o_empresa 
							AND  num_solicitud = o_numsol;
						END IF;
			
				  IF p_cod_ret <> '000000' THEN
					  LET scod_ret= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
					  RETURN scod_ret;
				  END IF;
				  RETURN scod_ret;
               END IF               
			   LET VNuevoStatus = cNuevoStatusOstel;
               
		   END IF; 
		   
		   
	END IF; 	  

	  --obtener el tipo de vivienda y  la clave de la ultima identificacion que presento el cliente 
	SELECT TRIM(habita_en), codidentifi 
	INTO v_habita_en, cCodidentif
	FROM bdinteg:"informix".si_ctepf
	WHERE empresa = o_empresa
	AND numcte = vCte;	
		
	--se determina si el cliente presento una credencial del seguro, issste o pasaporte como identificacion oficial.
	IF cCodidentif IN ("B","G","J") AND v_meses < 13 THEN -- RQM 09-262 Ajustes al proceso de credito LHM 13/12/2011
		LET iBanderaidentificacion=1;
		IF iMotivoOs = 0  THEN
			LET iMotivoOs = 11;		-- Tipo identIFicacion ISSTE O IMSS
		END IF
	END IF;
	
	
	--obtener los telefonos de casa y de trabajo del cliente
    /*
	SELECT CASE WHEN LENGTH(TRIM(telefono1)) > 10 THEN SUBSTR(TRIM(telefono1),LENGTH(TRIM(telefono1))-9,10) ELSE telefono1 END
		INTO cTelefono1
	FROM bdinteg:"informix".si_direcciones_actual
	WHERE numcte = vCte
	  and tipo_dir = 1;
    */
      
    SELECT CASE WHEN LENGTH(TRIM(telefono)) > 10 THEN SUBSTR(TRIM(telefono),LENGTH(TRIM(telefono))-9,10) ELSE telefono END
		INTO cTelefono1
	FROM bdinteg:"informix".si_telefonos_actual
	WHERE numcte = vCte
	  and tipo_tel = 1;
 
    -- se agrega consulta a la si_direcciones con el tipo de direccion 2 para obtener el numero de oficina del cliente.
    /*
    SELECT CASE WHEN LENGTH(TRIM(telefono3)) > 10 THEN SUBSTR(TRIM(telefono3),LENGTH(TRIM(telefono3))-9,10) else telefono3 END
	INTO  cTelefono2
	FROM bdinteg:"informix".si_direcciones_actual
	WHERE numcte = vCte
	  and tipo_dir = 2;
    */
      
    SELECT CASE WHEN LENGTH(TRIM(telefono)) > 10 THEN SUBSTR(TRIM(telefono),LENGTH(TRIM(telefono))-9,10) else telefono END
	INTO cTelefono2
	FROM bdinteg:"informix".si_telefonos_actual
	WHERE numcte = vCte
	  and tipo_tel = 3;
      
	--se valida si los telefono de casa y del trabajo del cliente son iguales.
	IF cTelefono1 = cTelefono2 THEN
		LET iBanderatel=1;
		IF iMotivoOs = 0  THEN
			LET iMotivoOs = 7;		-- Mismo Tel de casa y trabajo
		END IF
	END IF;
	--se obtiene la info de la validacion telefonica del Celular
	
	SELECT  count(*) INTO iValidaCel
	FROM bdinteg:"informix".si_telefonos_actual
	WHERE numcte = vCte AND tipo_tel = 2 AND status_tel = 'A' and cofetel = 'V';
	
	SELECT  fecha_insert INTO dFechaCte
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = vCte;
	
	SELECT  valor_alfabetico INTO dFechaIniVal
	FROM bdisolic:ss_param_solicitudes
	WHERE grupo_parametro = 'FECHA_CLI' and num_parametro = 1;
     


--se agrega validacion para identificar si el cliente presenta una ocupacion de riesgo. "Abogado litigante o Notario" actividad 4 subactividad 1
  SELECT claveopcionpuesto,clavesubopcionpuesto
	INTO iAct,iSubAct
  FROM bdinteg:"informix".si_ingresos a
  WHERE a.numcte = vCte
  AND a.tipo_ingreso='T'
  AND a.sec_ingreso= (SELECT MAX (sec_ingreso) 
						FROM bdinteg:"informix".si_ingresos b
						WHERE b.numcte=a.numcte
						AND b.tipo_ingreso='T');
  
  IF  (iAct = 4  AND  iSubAct = 1 ) THEN   --se puso fijo para que envie a os calle a esta actividad
	LET vRiesgo=1; 
	IF iMotivoOs = 0  THEN
		LET iMotivoOs = 10;		-- Ctes profesion abogado 
	END IF	
  END IF;
--SE IMPLEMENTA BANDERA PARA PRUEBA PILOTO
   IF (vRTipo3 = 'A') AND (vVigente =  '1' ) AND (cPiloto = '1')
         then LET cGeneraOs = '0'; 
              LET vValidaOS = 'F';
         --IF v_tpsol <> 'C'  THEN
         --    execute procedure sp_os_GrabaOSTipo3 (o_empresa,o_numsol , vCte, v_tpsol ) into scod_ret, vlSecuencia ;
         --END IF;
       --ELIF ( vRTipo3 = 'A' and vVigente= '1')
    --ELSE
      --   LET cGeneraOs = '1' ;
    END IF;
	--APR SE CONSULTA EL CLIENTE PROSPECTO SI ES QUE EXISTE.
	IF NVL(cCteProsp,'') = '' AND cPiloto = '1' THEN
		SELECT numcte_pros INTO cCteProspVig
		FROM bdiprospectos:"informix".pr_cliente 
		WHERE empresa = o_empresa AND numcte = cNumCteBco AND tipo_cliente = 3;
	ELSE
		LET cCteProspVig = cCteProsp;
	END IF;
	
   IF v_tpsol IN ('T','P') THEN --TDC y P.P BanCoppel

      IF v_meses >0 AND cGeneraOs = '0' THEN
               SELECT valor 		-- Obtiene parametro de dias maximo establecido desde la ultima compra para no enviar a OS al Cliente.
                 INTO iDiasCoppel
                 FROM "informix".ss_param
                WHERE empresa= o_empresa
                  AND secuencia= 348;

               IF ((v_hoy - dUltimaCompra) > iDiasCoppel) THEN
                   LET cGeneraOs = '1'; --Cte nuevo
				   IF iMotivoOs = 0  THEN
						LET iMotivoOs = 5;	 -- Fecha de compra mayOR a 6 meses	
				   END IF --JMAH marcaje de motivo de os calle
 
               END IF;
       END IF;

	  SELECT valor::smallint
        INTO v_meses_min
          FROM "informix".ss_param
         WHERE empresa = o_empresa
           AND secuencia = 327;
	
		
		 IF NVL(cTieneOstel,'') = 'V' AND iBanderaFaltaOSTEL =0 THEN--JMAH RQM 18 056
			--se obtiene las referencias mas actuales del cliente y se valida con las referencias que se enviaron a os telefonica.
			EXECUTE PROCEDURE bdinteg:"informix".sp_ConsultaReferencias (o_empresa, vCte) INTO vCodret,iReferencia1,iReferencia2;
			FOREACH
				SELECT num_referencia
					INTO iReferencia
				FROM "informix".ss_ostelrefsolicitud
				WHERE num_solicitud = o_numsol
				
				IF iReferencia NOT IN (iReferencia1,iReferencia2) THEN
					LET iBanderareferencia=1;
					IF iMotivoOs = 0  THEN
						LET iMotivoOs = 9;		--Ref. de cte distinta a enviada a supervision tel.		
					END IF					
					EXIT FOREACH;
				END IF;
			END FOREACH;
	
		 END IF;	
	 	
		IF (vgrupo_sol IN ('1','2','8') AND iValidaCel = 1 AND dFechaCte >= dFechaIniVal) THEN
			LET cCausa_sol = 'EVT'; -- Excepcion por Validacion Telefonica
		END IF;

		IF (((v_valor_1s >= vScoreBC) or (v_valor_2s >= vScorePR)) AND  iMotivoOs not in ( 2,12) ) AND vgrupo_sol <> '5' THEN
			LET cCausa_sol = 'EBC'; --Excepcion por BC Score
		END IF;				

		IF (vValidaOS ='F') THEN
		  LET cCausa_sol = 'EDP'; ---Otro producto con Pago 
		END IF;
		
		IF (vgrupo_sol ='A' and vHuella = 0) THEN
			LET cCausa_sol = 'EGA'; --Excepcion por Grupo A
		END IF;
	   --Inicio HSRR geolocalizacion.
		IF NVL(cFolioMovil,'') <> '' AND NVL(cProducto,'') = '6001' AND iMotivoOs = 0 THEN --Validar la solicitud movil de producto Banco
			
			IF (NVL(cFlagGeoMov,'') = 'S' ) THEN --Validar Geolocalizacion solo para productos Banco
				IF LEN(NVL(TRIM(cGeoCte),'')) > 10 THEN		--Si la variable cGeoCte el len es menos de 10 quiere decir que son coordenadas basura	
					SELECT count (id_ptf) INTO bandera_geo
					  FROM bdinteg:"informix".si_ptf 
						WHERE latitud = vlatitud AND longitud  = vlongitud;
						--WHERE TRIM(latitud)||","||TRIM(longitud) = TRIM(cGeoCte);
					IF bandera_geo > 0 THEN --Domocilio Geolocalizado diferente al de sucursal
						LET iMotivoOs = 17; --Domicilio no geolocalizado hasta que se demuestre lo contrario
						LET cGeneraOs = '1';
						LET cFLagGeoMov ='N';
					END IF;		
				END IF;
			END IF;
		END IF;
		--Fin HSRR geolocalizacion.
			IF (sFlagCanalWeb = 1 and cproducto='6001') then
--			LET vMensajeStatus='Enviado a Orden de Supervision Solicitud Web';
			LET cGeneraos='1'; 
			LET iMotivoOs='19';
		END IF;
		--RQM 10 1177 Valida OS producto se contempla solo para prestamo tu moto
     IF nvl(v_envio_os,0) = 1 AND cproducto IN ('9100') THEN
			LET cGeneraos='1'; 
			LET iMotivoOs='20';
     END IF;		
	 --RQM 101177 se agrega en condicion para que tome en cuenta el parametro si es forsozo envio a os
     IF ((((vAntiguedad = "0" AND vHuella = 0 AND v_SituacionPagoCoppel >= v_EficienciaCoppel AND cGeneraOs= '0')
           OR (v_eficiencia > 0 AND cOrigen='T' AND vHuella = 0 AND cGeneraOs= '0')) --RQM 09 172 No generan os clientes con menos de 6 meses	    	    
	       AND banderaS = 0  AND v_habita_en <> 'D' AND iBanderatel = 0 --RQM ajustes Paso 4
	       AND iBanderaidentificacion=0 AND iBanderareferencia=0 AND vRiesgo =0 
	       AND VNuevoStatus <> 'EE' AND  iBanderaFaltaOSTEL =0) OR --RQM ajustes Paso 4--JMAH RQM 18 056
	          (vgrupo_sol ='A' and vHuella = 0)  OR ---Clientes Grupo A 
	          (((v_valor_1s >= vScoreBC) or (v_valor_2s >= vScorePR)) AND  iMotivoOs not in ( 2,12)  AND vgrupo_sol <> '5') OR 
                            (vValidaOS ='F')  OR ((vgrupo_sol IN ('1','2','8') AND iValidaCel = 1 AND dFechaCte >= dFechaIniVal)) 
			    OR (cFLagGeoMov ='S' AND iEnviarMC = 0) OR (VNuevoStatus = 'AT' AND cProducto = '7800' )) and sFlagCanalWeb <> 1 THEN  -----JMAH Geolocalizacion, se agrega OR 
			  
                 LET vMensajeStatus = 'Solicitud Autorizada';
                 LET VNuevoStatus = 'AT';
				 IF vgrupo_sol = '8' THEN 
				     LET cCausa_sol = 'CG8'; ---Otro producto con Pago 
				 END IF;
       ELSE
	      -- VALIDACIONES DE CADA MOTIVO EN CASO DE NO TRAER MOTIVO OS
			IF iMotivoOs = 0 AND v_habita_en = 'D' THEN
				LET iMotivoOs = 8;	-- Tipo de viviENDa (Prestada)
			END IF
            /*INSERT INTO ss_solicitud_os (empresa, num_solicitud, fecha_solicitud, status,usuario_solicita)
                 VALUES (o_empresa, o_numsol, v_hoy, "S", "sistema");

           LET vMensajeStatus = 'Solicitud Enviada a Orden de Supervision';*/
		
			---- GGG-100719 Segmento para validar que ninguna solicitud de producto 8500 pase por status OS			
			IF (v_id_excluye_os = '1' ) THEN
					LET cGeneraOs = '0';
					LET iMotivoOs = 0;
					LET VNuevoStatus = 'AT';
				ELSE
					IF EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN
							LET VNuevoStatus = "AT";
						ELSE 
							LET VNuevoStatus = "EE";
				   END IF;
			END IF;
            
           IF vAntiguedad = "1" OR vHuella > 0 OR v_SituacionPagoCoppel < v_EficienciaCoppel THEN
                LET v_paso = "1"; -- Asigna Bandera para nuevos
           END IF;
       END IF;
   ELIF v_tpsol = 'C' THEN -- TDC Coppel
   
	   FOREACH 
			SELECT {+INDEX(bdinteg:"informix".si_direcciones inx_puntocardinales)} NVL(numerociudad,0) as numerociudad, 
			NVL(numerocolonia,0) as numerocolonia, NVL(numerocalle,0) as numerocalle
			INTO V_ciudad, V_colonia,v_calle
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = vCte
			AND tipo_dir in (1,2) 
			
			
				IF  v_ciudad IS NULL OR NVL(v_colonia, 0) = 0 OR NVL(v_calle, 0)= 0 OR V_ciudad = 0 OR V_colonia = 8000 OR V_calle = 800000  THEN
					LET	 iBanderaErrorCatalogo = 1; 
					EXIT FOREACH;
				END IF; 
			
			SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerocoloniacoppel, nombrezonacoppel, numerociudadcoppel 
			INTO V_coloniaCoppel, V_NombreZonaCoppel, V_ciudadCoppel
			FROM bdinteg:"informix".si_catzonas
			WHERE numerociudad = V_ciudad AND numerocolonia = V_colonia;

		     					 
			IF NVL(V_ciudadCoppel,0) = 0  OR NVL(V_coloniaCoppel,0) = 0 OR NVL(V_NombreZonaCoppel, '') = '' THEN 
				LET iBanderaErrorCatalogo = 1; 
				EXIT FOREACH;
			END IF;
	   
	   END FOREACH;
   	--checar si el cliente presenta alguna situacion especial L o M, en caso de presentar se envia a OS Calle
		SELECT  COUNT(situacion)
			INTO  iSitEsp
		FROM bdicred:"informix".sd_situacion_pago a, bdicred:"informix".sd_maecred b
		WHERE b.numcte = vCte
		AND b.empresa = o_empresa
		AND a.empresa = b.empresa
		AND a.num_credito = b.num_credito
		AND a.fecha = (SELECT MAX(fecha) 
				   FROM bdicred:"informix".sd_situacion_pago s
				  WHERE s.empresa = b.empresa
					AND s.num_credito = b.num_credito
					AND s.porcentaje=(SELECT MIN(porcentaje)
										FROM bdicred:"informix".sd_situacion_pago j
									   WHERE j.empresa = b.empresa
										 AND j.num_credito=b.num_credito))
		AND situacion IN ("L","M");
		
		-- Inicio DSB 20160206        
-- Determina si el Envio Parametrico manda a OS INI
        SELECT nvl(status_solicitud,''),NVL(flag_altadirecta_asupervisar,'0'),NVL(situacion_especial,'0'),NVL(causa_sitesp,'0')
          INTO vstatusCoppel,cFlagAltadirectaSupervisar, -- DSB 20160208
				vSituacionSolD,vCausaSolD
          FROM bdisolic:"informix".ss_nuevo_parametrico 
  		 WHERE num_solicitud = o_numsol
	  	   AND empresa = o_empresa;	
		
		IF ( vstatusCoppel = 'S' ) THEN
			   LET iMotivoOs = 16;    -- Motivo 
               Let cGeneraOs = '1';	
			  ---LET vstatusCoppel = 'A';
			  ---LET StatusSolDta = 1;
        END IF;
		
		------------------------------------------------------------- INI	
		SELECT  b.clave_producto
		INTO cProducto
		FROM bdicred:"informix".sd_definicion a
		JOIN bdisolic:ss_oscalle_plazovigencia b ON b.clave_producto=a.num_producto 
		and a.bandera_os = 1 AND resp_oscalle in ('A','R')
		AND b.clave_producto = cProducto  --Se agrega validacion porque ya se sabe que el producto es Coppel
		group by b.clave_producto;
		
		IF (nvl(cProducto,'') <> '') THEN 	
			FOREACH
					--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS 
					--SS_OSCLIENTESUPERVISAR PARA TITULAR 'T' Y PROSPECTOS 'P'.		
					SELECT LIMIT 1 b.secuencia,b.clave,b.fecharespuesta,a.num_solicitud,'T' tipo_sol
					INTO  iSecuenciaOs,cStatusRespOs,dFecha_Respuesta,cNumsolOs,cTipoSol
					FROM  bdisolic:"informix".ss_solicitudes a
					JOIN bdisolic:"informix".ss_osclientesupervisar b ON (a.num_solicitud = b.num_solicitud)
					WHERE a.empresa = b.empresa AND b.secuencia=(SELECT MAX(d.secuencia) 
																	from bdisolic:"informix".ss_osclientesupervisar AS d 
																	WHERE d.num_solicitud = b.num_solicitud)
					AND clave IN ('A','R') AND fecharespuesta IS NOT NULL AND a.numcte =vCte 
					UNION 
					SELECT secuencia,clave,fecharespuesta,num_solicitud,'P' tipo_sol
					FROM bdisolic:"informix".ss_osclientesupervisar
					WHERE empresa  = '001' AND num_solicitud  = cCteProspVig --cCteProsp
					AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar 
										WHERE num_solicitud  = cCteProspVig) --cCteProsp
					ORDER BY fecharespuesta DESC
			END FOREACH;			
						
			 			
			/* SE COMENTA HASTA QUE SE DEFINA SI HEREDARA TODOS LOS ESTATUS O NO
			SELECT fecha_hora INTO cFechaHora  
			FROM "informix".ss_autorizacion
			WHERE num_solicitud = cNumsolOs
			AND status_solicitud = 'EE';
			*/
			IF nvl(iSecuenciaOs,0)<>0 THEN		
				IF NOT EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN																			 
					IF cTipoSol='T'	THEN		
					
						LET iBanderaProsNoTit = 1;	
						
						SELECT dias_vigencia
						INTO cDiaVigencia                                           
						FROM bdisolic:ss_oscalle_plazovigencia
						WHERE clave_producto = cProducto   
						AND resp_oscalle = cStatusRespOs;
						
						LET vdiastrans = v_hoy - dFecha_Respuesta;
													
						IF vdiastrans <= cDiaVigencia THEN
							IF cStatusRespOs = 'A' THEN 
								LET VNuevoStatus = "AT"; 
							Else
								LET VNuevoStatus = "RT"; 
								LET cCausa_sol = "ROS";
							END IF;
							
							-- NO Genera OS
								LET cGeneraOs = '0'; 
								IF(SELECT COUNT(*)  FROM BDISOLIC:ss_solicitud_os WHERE num_solicitud=o_numsol AND secuenciaos=iSecuenciaOs)= 0 THEN 
									INSERT INTO bdisolic:"informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os)
									VALUES('001', o_numsol, v_hoy, dFecha_Respuesta,cStatusRespOs, 'sistema', 'sistema', NULL, NULL, NULL, ' ', 0, NULL, NULL, iSecuenciaOs, 0);														
								END IF;
								LET sBanAuto = 1; 					
						END IF;
					
					ELIF cTipoSol='P'	THEN
					
						LET iBanderaProsNoTit = 1;
						LET dFecha_Respuesta = NVL(dFecha_Respuesta,DATE(1));
					
						IF cStatusRespOs = 'D' THEN
							SELECT dias_vigencia INTO cDiaVigencia FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = '6500'  AND resp_oscalle = '';		
						ELSE
							SELECT dias_vigencia INTO cDiaVigencia FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = '6500'  AND resp_oscalle = cStatusRespOs;												
						END IF;	
						
						LET dFechaVencimiento = dFecha_Respuesta + cDiaVigencia::INTEGER UNITS DAY; 
						
						--SELECT descripcion INTO cDesStatusCtePros FROM bdiprospectos:"informix".pr_status_sol WHERE status_solicitud = cStatusSolic;	
														
						-- Se valida que la respuesta esta activa 	
						IF(v_hoy  <= dFechaVencimiento) THEN
							LET cGeneraOs = '0'; 
							IF(SELECT COUNT(*)  FROM BDISOLIC:ss_solicitud_os WHERE num_solicitud=o_numsol AND secuenciaos=iSecuenciaOs)=0 THEN 
								INSERT INTO bdisolic:"informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os)
								VALUES('001', o_numsol, v_hoy, dFecha_Respuesta,cStatusRespOs, 'sistema', 'sistema', NULL, NULL, NULL, ' ', 0, NULL, NULL, iSecuenciaOs, 0);							
							END IF;
							LET sBanAuto = 1; 
							
							IF cStatusRespOs = 'A' THEN LET VNuevoStatus = "AT"; END IF;
							IF cStatusRespOs = 'R' THEN LET VNuevoStatus = "RT"; LET cCausa_sol = "ROS"; END IF;
							IF cStatusRespOs = 'D' THEN LET VNuevoStatus = "OA"; END IF;
							IF cStatusRespOs = ' ' THEN LET VNuevoStatus = "OS"; END IF;
							
						END IF;	 
						
						/*IF  v_hoy  > dFechaVencimiento THEN
							LET iMotivoOs = 15;
							LET vMensajeStatus = 'Orden de Supervision Calle Cliente Prospecto';
							LET VNuevoStatus = 'EE';
							LET dFecha_Respuesta = DATE(1);
						END IF;*/
					END IF;
				END IF;
			END IF; 					
			/* SE COMENTA HASTA QUE SE DEFINA SI HEREDARA TODOS LOS ESTATUS O NO
			--Ciclo para obtener los estatus de la solicitud existente que estan despues de 'EE'
			FOREACH 
				SELECT status_solicitud INTO VNuevoStatus FROM "informix".ss_autorizacion 
				WHERE num_solicitud = cNumsolOs
				AND fecha_hora >= cFechaHora
				ORDER BY fecha_hora ASC			

				EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, VNuevoStatus, cCausa_sol, vMensajeStatus )
				INTO p_cod_ret;

				IF p_cod_ret <> '000000' THEN
					LET scod_ret= '00006'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
					RETURN scod_ret;
				END IF;				
			END FOREACH;
			*/
			
			    --CUANDO NO EXISTE NINGUNA SOLICITUD COMO TITULAR HEREDA EL ESTATUS EN EL QUE SE ENCUETRA EL CLIENTE PROSPECTO.			
			IF ( NVL(cCteProsp,'') <>'' AND iBanderaProsNoTit = 0 AND  NVL(iSecuenciaOs,0) <> 0 ) THEN   --IPCB 260521
			
				SELECT descripcion INTO cDesStatusCtePros FROM bdiprospectos:"informix".pr_status_sol WHERE status_solicitud = VNuevoStatus;
				LET vMensajeStatus = cDesStatusCtePros;
				LET cStatusPr = "P";

				IF 	VNuevoStatus = "AT" THEN 
					LET cStatusPr = "A";
					LET cDesStatusCtePros = "Solicitud Autorizada";
					LET vMensajeStatus = cDesStatusCtePros;
				ELIF VNuevoStatus = "EE" THEN 
					IF NVL(dFechaVencimiento,DATE(1)) <> DATE(1) THEN 

						IF  v_hoy  > dFechaVencimiento THEN
							LET cStatusPr = "S";
						ELSE
							LET cStatusPr = "P";
						END IF;
					ELSE
						IF cStatusSolic = "EE" THEN
							LET cStatusPr = "S";
						END IF;
					END IF;
				ELIF VNuevoStatus = "OS" THEN LET cStatusPr = "P";
				ELIF VNuevoStatus = "RT" THEN LET cStatusPr = "R"; LET cCausa_sol = "ROS";
				ELIF VNuevoStatus = "OA" THEN LET cStatusPr = "D";

				END IF;
				
				IF (SELECT COUNT(*)  FROM BDISOLIC:ss_solicitud_os WHERE num_solicitud=o_numsol AND secuenciaos=iSecuenciaOs) = 0 THEN 
					IF NOT EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN
						INSERT INTO bdisolic:"informix".ss_solicitud_os (empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status,usuario_solicita,secuenciaos,motivo_os)
						VALUES (o_empresa, o_numsol, TODAY,NVL(dFecha_Respuesta,DATE(1)),cStatusPr, "sistema",iSecuenciaOs,iMotivoOs);
					END IF;
				END IF;
				LET sBanAuto = 1; 
			END IF;
		END IF; 					
		------------------------------------------------------------- FIN
		
-- Determina si el Envio Parametrico manda a OS FIN
       IF (((cGeneraOs= '0' AND VNuevoStatus <> 'EE')  --JMAH RQM 18 056
           OR (vValidaOS ='F') OR cStatusMovil <> '3' ) AND 
		   (sBanAuto = 0))  --Bandera que determina que el cliente tiene origen de un prospecto. 18/03/2015. 
		   --AND  cFLagGeoMov != 'N' -- Geolocalizacion para Coppel genera OS
		   AND NVL(vstatusCoppel,'') = 'A' --Se agrega para respetar el parametrico
		   --Se elimina la bandera cFLagGeoMov ya que a las solicitudes Coppel el Parametrico evaluara el domicili_alta
       THEN--RQM ajustes Paso 5
		   LET VNuevoStatus = 'AT';
           LET vMensajeStatus= 'Solicitud Autorizada';
		
		
			IF cOrigen = ""  THEN --Credito Coppel Autorizado automatico, sin ctas credito en banco, CLIENTE NUEVO
                --Mandar a OS, indicando en el campo observacion1 de ss_solicitud_os que es S50, alta directa
				IF vlSecuencia > 0 THEN 
					LET vlClaveOSCoppel = "A";
				END IF;                         
					
                SELECT valor INTO cParamOS_AltaAutom
                  FROM bdisolic:ss_param WHERE empresa = o_empresa and secuencia = 450;
				  -- Se coloca estatus transitorio, hasta que se valide entrega para marcar S-50 de alta directa. RQM 18 105  
			-----  Se apaga envio S-50, se comenta insert con estatus T - RQI 25 066
			--- Se activa(nuevamente) para enviar o no a OS cuando es S-50 o S-51 RQM 09 588 MACF
			--	IF cFlagAltadirectaSupervisar = '1' THEN -- DSB 20160208	 
				IF cFlagAltadirectaSupervisar = '1'  AND cParamOS_AltaAutom = '1' THEN
					IF NOT EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN	
						INSERT INTO "informix".ss_solicitud_os (empresa,   num_solicitud, fecha_solicitud, status, usuario_solicita, observacion1, motivo_os, secuenciaos)
						VALUES (o_empresa, o_numsol, v_hoy, "T", "sistema", "S50 Supervisar, Autorizacion Automatica.", 1, vlSecuencia);
					END IF;
				END IF;
					
				SELECT count(num_solicitud)	 
					INTO  vSolDirecta
				FROM "informix".ss_os_solautdirecta
				WHERE empresa = o_empresa
					AND num_solicitud = o_numsol;
					
				IF  nvl(vSolDirecta,0) = 0  THEN
					INSERT INTO "informix".ss_os_solautdirecta (empresa, num_solicitud, situacionespecial, causa, status, respreplicadacoppel)
					VALUES (o_empresa, o_numsol,  vSituacionSolD,vCausaSolD, 'S', "");
				END IF;    
				
			END IF;
       ELSE
			-- Bandera Heredo
			IF sBanAuto = 0 THEN
			-- APAGAR PROSPECTO
				
				IF NOT EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN
					LET sBanAuto = 0;
					LET VNuevoStatus = 'EE';
					LET vMensajeStatus = 'Solicitud Enviada a Orden de Supervision';	
				ELSE
					LET VNuevoStatus = 'AT';
					LET vMensajeStatus = 'Solicitud Autorizada por Reevaluacion';
				END IF;
			END IF;
-- Determina si el Envio Parametrico manda a OS INI
                IF ( vstatusCoppel = 'S' ) THEN
                    LET cCausa_sol = 'OSC'; 
                END IF;
-- Determina si el Envio Parametrico manda a OS FIN
				LET v_paso = "1";			      	              
       END IF;
   END IF;

    -- ******************************
    -- Genera Linea de Credito  *
    -- ******************************
	IF cProducto <> '7800' THEN 
		IF  iMotivoOs = 14 AND cRespuestaOs = '1' AND v_tpsol IN ('T', 'P')  THEN
			IF EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN
				LET VNuevoStatus = "AT";
			ELSE
                    LET VNuevoStatus = 'EE';
                    LET vMensajeStatus = cMsjStatus;                         
			END IF;
		END IF;
	
	   IF VNuevoStatus IN ('EE', 'AT') AND v_tpsol NOT IN ('C')   THEN

			SELECT valor INTO v_monto_cap_pago FROM "informix".ss_param WHERE empresa = o_empresa AND secuencia = 356;


			SELECT  sum(factor_flujo1)
			  INTO  v_factor_flujo1
			 FROM "informix".ss_scoring_solic
			WHERE empresa = o_empresa
			  AND tp_solicitud = v_tpsol
			  AND seccion = '2'
			  AND (min_porc_pago <= case when v_SituacionPagoCoppel = -1 then 0 else v_SituacionPagoCoppel end
			  AND max_porc_pago >= case when v_SituacionPagoCoppel = -1 then 0 else v_SituacionPagoCoppel end)
			  AND (min_mes_hist <= case when v_SituacionPagoCoppel = -1 then 0 else v_meses end
			  AND max_mes_hist >= case when v_SituacionPagoCoppel = -1 then 0 else v_meses end)
			  AND activa = '1';

	/*
			SELECT valor::decimal(9,6)
			 INTO v_Sichip
			 FROM "informix".ss_param
			WHERE empresa = o_empresa
			  AND secuencia = 357;
	*/

		   SELECT compromisos_bco
			 INTO v_comprobanco
			 FROM "informix".ss_resum_scor_fin
			WHERE empresa =  o_empresa
			  AND num_solicitud = o_numsol;
			  

			IF v_ingreso_neto <> 0 THEN
			  if vcompromiso_rmp >= v_compteorico  then 
				let vcompromiso_coppel = vcompromiso_rmp; 
			  else  
				let vcompromiso_coppel =v_compteorico;
			  end if;
			   LET vCompromisos = vCompromisos - v_importe_hip + vcompromiso_coppel + v_comprobanco;
			   LET v_ingreso_neto = v_ingreso_neto - v_importe_hip;
	--           LET v_compromisos_33 = v_ingreso_neto * v_Sichip;
			   LET v_compromisos_33 = v_ingreso_neto * v_factor_flujo1;
			END IF

			IF (v_compromisos_33 - vCompromisos) >= v_monto_cap_pago::DECIMAL(10,2) THEN

			
			EXECUTE PROCEDURE "informix".determina_lincred_tc_cjunk(o_empresa, o_numsol,v_paso)
						 INTO scod_ret, v_valor,v_capacidad_pago,iPlazo;

					

				IF scod_ret = '010' THEN
					LET vMensajeStatus= 'Capacidad de pago saturada';
					LET VNuevoStatus = 'RT';
					LET cCausa_sol = 'CPS';
				END IF;

			   IF v_tpsol IN ('T','C') THEN
				   UPDATE "informix".ss_solicitudes
					  SET monto_solicitado = v_valor,
						  capacidad_pres = v_capacidad_pago
					WHERE empresa = o_empresa
					  AND num_solicitud = o_numsol;
			   ELIF v_tpsol = 'P' THEN
				   UPDATE "informix".ss_solicitudes
					  SET monto_autorizado = v_valor,
						  capacidad_pres = v_capacidad_pago,
						  plazo = iPlazo
					WHERE empresa = o_empresa
					  AND num_solicitud = o_numsol;

				   IF v_valor < dMonto_min THEN
						IF cProducto = '9300' THEN
							LET VNuevoStatus = 'RT';
							LET cCausa_sol = 'CPS';
							LET vMensajeStatus = 'Rechazo por capacidad de pago saturada';
						ELSE
							LET VNuevoStatus = 'RT';
							LET cCausa_sol = 'CPS';
							LET vMensajeStatus = 'Rechazada por linea de credito insuficiente para el prestamo.';
						END IF;
				   END IF;
				END IF;
			 ELSE

				LET VNuevoStatus = 'RT';
				LET cCausa_sol = 'CPS';
				LET vMensajeStatus= 'Capacidad de pago saturada';			
			END IF;
	   ELIF  v_tpsol IN ('C') THEN
			SELECT limitecreditopesos
				INTO v_valor
			FROM "informix".ss_nuevo_parametrico
			WHERE num_solicitud = o_numsol
			AND empresa = o_empresa;		
				
			  UPDATE "informix".ss_solicitudes
			  SET monto_solicitado = v_valor
			  WHERE empresa = o_empresa
			  AND num_solicitud = o_numsol;
	   END IF;
	END IF
	--SI EL NUEVO ESTATUS  ES "EE", PRODUCTO "6001","6300" Y ES UN CLIENTE NUEVO,SE CAMBIA A "MC" Y SE AGREGA UN REGISTRO A SS_SOLICITUDES_MC PARA SER ATENDIDA LA SOLICITUD POR MESA DE CONTROL.
	
	LET cProducto2 = cProducto;	--JMAH RQM 18 056		
	IF (VNuevoStatus = 'EE' OR  VNuevoStatus = 'AT') OR (v_tpsol = 'C' AND iSolMc = 0 ) THEN 

		----------- Eliminacion de la OS para grupo 5 		INICIO

		--RQM 69 613 INI
		IF iNewMPP > 0 THEN
		--IF cProducto in('6300','6800','7600','7700') Then	   
			SELECT count (pro_scor_osmin) INTO bandera_grupo5
			FROM bdisolic:"informix".ss_scoring_modelo2_pp
			WHERE tp_solicitud  = v_tpsol AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
			AND grupo = vgrupo_sol 
			AND v_valor_1s BETWEEN bc_scoremin AND bc_scoremax
			AND v_valor_2s BETWEEN pro_scor_osmin AND pro_scor_osmx
			AND num_producto = cProducto
			AND tp_parametrico = cParametrico
			AND tipo_modelo_hit = vTipoHit;		
		ELSE
			SELECT count (pro_scor_osmin) INTO bandera_grupo5
			FROM bdisolic:"informix".ss_scoring_modelo2
			WHERE tp_solicitud  = v_tpsol AND respuesta_sic = DECODE(v_respsic,"X","X","0","0","2","1","3","1","4","1","1")
			AND grupo = vgrupo_sol 
			AND v_valor_1s BETWEEN bc_scoremin AND bc_scoremax
			AND v_valor_2s BETWEEN pro_scor_osmin AND pro_scor_osmx
			AND num_producto = cProducto
			AND tp_parametrico = cParametrico;	
		END IF;		
		--RQM 69 613 FIN
		IF bandera_grupo5 > 0 and sFlagCanalWeb <> 1 THEN
		
			LET VNuevoStatus = 'AT';
			
			SELECT COUNT (*) INTO existe_gpo5
			FROM bdisolic:"informix".bitacora_os_gpo5 
			WHERE empresa = o_empresa AND num_solicitud = o_numsol;
		
			IF existe_gpo5 = 0 THEN
				INSERT INTO bdisolic:"informix".bitacora_os_gpo5 VALUES (o_empresa,cProducto,o_numsol,
				(Case When (nvl(v_respsic,'X') = 'X')  Then 'No-Hit' Else 'Hit' end),
				v_hoy,'',VNuevoStatus,cSucursal,vgrupo_sol,v_valor_1s,v_valor_2s,v_valor_3s,v_valor_4s,v_valor,'Excepcion de OS grupo 5',"");
			ELSE 
				UPDATE "informix".bitacora_os_gpo5 SET bc_score = v_valor_1s, sc_propietario = v_valor_2s, fico_score = v_valor_3s, 
				fc_extended = v_valor_4s, linea_credito = v_valor WHERE num_solicitud = o_numsol;
			END IF;
		
		END IF;
		
		--INC status obligatorio de OS para prestamo tu Moto
		IF VNuevoStatus ='AT' AND cProducto ='9100' THEN
			LET VNuevoStatus = 'EE';
		END IF;
		
		LET v_hereda_status = VNuevoStatus;

		----------- Eliminacion de la OS para grupo 5
		--se valida que no se envien solicitudes coppel si no son mixtas y la solicitud de banco se envio a MC.	
	
		IF  (v_tpsol = 'C' AND (NVL(cTipoMovto,"") <> "M" OR iSolMcAux = 0)) OR sFlagCanalWeb = 1   THEN		
			LET iEnviarMC = 0;
		END IF;
				
		-- GEGB 20190211 RQM 09 501 {
		------------------------------------------------------------------------------------------------------------------------------------------------------	
		-- Se valida si el producto de la actual solicitud es producto que viaja a MC [iProdMC]
		-- Se valida si la solicitud no existe ya en la tabla ss_solicitudes_mc [iSolMc]
		-- Se valida si el tipo de solicitud es diferente de 'C' (Coppel) y si es mixta o si tiene ya una solicitud auxiliar en MC [iEnviarMC]
		IF iProdMC = 1 AND iSolMc = 0 AND iEnviarMC = 1 THEN
			
			-- Consulta si la ultima solicitud previa del cliente para los productos Bancoppel 6800,6001,6300,7600,7700 
			-- omitiendo las solicitudes con estatus de AN y PC 
			-- tiene historial de registro en CM [Cancelada por Mesa de Control] y su estatus actual es CM o CN 
			SELECT COUNT(a.status_solicitud) 
			INTO iFlagForzarEnvioMC -- Bandera para el envio forzado de solicitud a MC
			FROM bdisolic:"informix".ss_solicitudes s
			LEFT JOIN bdisolic:"informix".ss_autorizacion a ON s.empresa = a.empresa AND a.num_solicitud = s.num_solicitud
			WHERE s.empresa = o_empresa AND s.numcte = vCte AND s.num_solicitud <> o_numsol
			AND s.fecha_hora = (SELECT MAX(fecha_hora) FROM bdisolic:"informix".ss_solicitudes 
								WHERE empresa = o_empresa AND numcte = vCte AND num_solicitud <> o_numsol 
								--AND status_solicitud NOT IN('AN','PC') AND num_producto IN('6800','6001','6300','7600','7700'))
								AND status_solicitud NOT IN('AN','PC') AND num_producto IN (SELECT num_producto FROM bdicred:"informix".sd_definicion WHERE envio_mesa_control = '1'))
			AND a.status_solicitud = 'CM' AND s.status_solicitud IN('CM','CN');
		END IF;

			--RQM 10 1432  Se contempla que solo mande a MC cuando sea diferente de este estatus
			--RQM 10 1177 valida si no encontro informacion y es producto con obligado solidario o corresponde a obligado(9200) forzar el envio a MC
		IF (NVL(iFlagForzarEnvioMC,0) > 0 OR (iProdMC = 1 AND iSolMc = 0 AND iEnviarMC = 1 AND iFlag2credito = 0) OR cProducto IN ('9100','9300','9200','9400')) AND  cStatusSolicitud <> 'MC'  THEN

			LET VNuevoStatus = "MC";
			

			IF (cCanalv1 = 99) OR cProducto IN ('9100','9300','9200','9400') OR (cbanobligadosol = 1 AND ccapturaobligsol = 1) THEN
				
				IF iSolMc = 0  THEN
					INSERT INTO "informix".ss_solicitudes_mc (empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,motivo_os,ostel,tipo_alta,status_hereda,prioridad)																																										  
					VALUES (o_empresa,o_numsol,vCte,cSucursal,cProducto, v_valor, VNuevoStatus,'','','','Cliente Nuevo',CURRENT,CURRENT,CURRENT,'N',iMotivoOs,iBanderaFaltaOSTEL,cTipoMovto,v_hereda_status,iFlagForzarEnvioMC);
				END IF;
			END IF;
		
			LET vMensajeStatus = 'Solicitud se envia a Mesa de Control.'; 
		------------------------------------------------------------------------------------------------------------------------------------------------------
		-- } GEGB 20190211 RQM 09 501
		--ELIF ( (VNuevoStatus = 'EE') OR (v_tpsol = 'C' AND iSolMc = 0 ) ) THEN
		END IF;
		
		--Inicio Herencia de los estatus de una OS existente y vigente del mismo Cliente 
		--para producto nuevo diferente de Cooppel
 
		LET cProducto2 = cProducto;
		IF VNuevoStatus = 'EE' AND v_tpsol <> 'C' THEN
		
			SELECT  b.clave_producto
			INTO cProducto
			FROM bdicred:"informix".sd_definicion a
			JOIN bdisolic:ss_oscalle_plazovigencia b ON b.clave_producto=a.num_producto 
			AND a.bandera_os = 1 AND resp_oscalle in ('A','R')
			AND b.clave_producto = cProducto  --Se agrega validacion porque ya se sabe que el producto es Banco
			group by b.clave_producto;
			
			IF NVL(cProducto,'') <> '' THEN 
			
				FOREACH
					--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR PARA TITULAR 'T' Y PROSPECTOS 'P'.		
					SELECT LIMIT 1 b.secuencia,b.clave,b.fecharespuesta,a.num_solicitud,'T' tipo_sol
					INTO  iSecuenciaOs,cStatusRespOs,dFecha_Respuesta,cNumsolOs,cTipoSol
					FROM  bdisolic:"informix".ss_solicitudes a
					JOIN bdisolic:"informix".ss_osclientesupervisar b ON (a.num_solicitud = b.num_solicitud)
					WHERE a.empresa = b.empresa AND b.secuencia=(SELECT MAX(d.secuencia) 
																	from bdisolic:"informix".ss_osclientesupervisar AS d 
																	WHERE d.num_solicitud = b.num_solicitud)
					AND clave IN ('A','R') AND fecharespuesta IS NOT NULL AND a.numcte = vCte 
					UNION 
					SELECT secuencia,clave,fecharespuesta,num_solicitud,'P' tipo_sol
					FROM bdisolic:"informix".ss_osclientesupervisar
					WHERE empresa  = '001' AND num_solicitud  = cCteProspVig --cCteProsp
					AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar 
										WHERE num_solicitud  = cCteProspVig) --cCteProsp
					ORDER BY fecharespuesta DESC
				END FOREACH;			
				
				/*
				IF cTipoSol = 'T' THEN
					SELECT fecha_hora INTO cFechaHora  
					FROM "informix".ss_autorizacion
					WHERE num_solicitud = cNumsolOs
					AND status_solicitud = 'EE';
				END IF;
				*/
					
				IF nvl(iSecuenciaOs,0)<>0 THEN	
				
					IF cTipoSol='T' THEN		
						LET iBanderaProsNoTit = 1;
						SELECT dias_vigencia
						INTO cDiaVigencia                                           
						FROM bdisolic:"informix".ss_oscalle_plazovigencia
						WHERE clave_producto = cProducto   
						AND resp_oscalle = cStatusRespOs;
						
						LET vdiastrans = v_hoy - dFecha_Respuesta;
													
						IF vdiastrans <= cDiaVigencia THEN
							IF cStatusRespOs = 'A' THEN 
								LET VNuevoStatus = "AT"; 
							Else
								LET VNuevoStatus = "RT"; 
								LET cCausa_sol = "ROS";
							END IF;
							
							-- NO Genera OS
							LET cGeneraOs = '0'; 
							IF(SELECT COUNT(*)  FROM BDISOLIC:ss_solicitud_os WHERE num_solicitud=o_numsol AND secuenciaos=iSecuenciaOs)= 0 THEN 
								IF NOT EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN
									INSERT INTO bdisolic:"informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os)
									VALUES('001', o_numsol, v_hoy, dFecha_Respuesta,cStatusRespOs, 'sistema', 'sistema', NULL, NULL, NULL, ' ', 0, NULL, NULL, iSecuenciaOs, 0);														
								END IF;
							END IF;
							LET sBanAuto = 1; 
						END IF;

					ELIF cTipoSol='P'	THEN
						LET iBanderaProsNoTit = 1;
						LET dFecha_Respuesta = NVL(dFecha_Respuesta,DATE(1));

						IF cStatusRespOs = 'D' THEN
							SELECT dias_vigencia INTO cDiaVigencia FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = cProducto  AND resp_oscalle = '';		
						ELSE
							SELECT dias_vigencia INTO cDiaVigencia FROM "informix".ss_oscalle_plazovigencia WHERE clave_producto = cProducto  AND resp_oscalle = cStatusRespOs;												
						END IF;	
						
						LET dFechaVencimiento = dFecha_Respuesta + cDiaVigencia::INTEGER UNITS DAY; 
																			
						-- Se valida que la respuesta esta activa 	
						IF(v_hoy  <= dFechaVencimiento) THEN
							LET cGeneraOs = '0'; 
							IF(SELECT COUNT(*)  FROM BDISOLIC:ss_solicitud_os WHERE num_solicitud=o_numsol AND secuenciaos=iSecuenciaOs)=0 THEN 
								IF NOT EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN
									INSERT INTO bdisolic:"informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os)
									VALUES('001', o_numsol, v_hoy, dFecha_Respuesta,cStatusRespOs, 'sistema', 'sistema', NULL, NULL, NULL, ' ', 0, NULL, NULL, iSecuenciaOs, 0);							
								END IF;
							END IF; 
							
							LET sBanAuto = 1; 
							
							IF cStatusRespOs = 'A' THEN LET VNuevoStatus = "AT"; END IF;
							IF cStatusRespOs = 'R' THEN LET VNuevoStatus = "RT"; LET cCausa_sol = "ROS"; END IF;
							IF cStatusRespOs = 'D' THEN LET VNuevoStatus = "OA"; END IF;
							IF cStatusRespOs = ' ' THEN LET VNuevoStatus = "OS"; END IF;
							
						END IF;	 
					END IF;
					
					--CUANDO NO EXISTE NINGUNA SOLICITUD COMO TITULAR HEREDA EL ESTATUS EN EL QUE SE ENCUETRA EL CLIENTE PROSPECTO.			
					IF ( NVL(cCteProsp,'') <>'' AND iBanderaProsNoTit = 0 ) THEN
					
						SELECT descripcion INTO cDesStatusCtePros FROM bdiprospectos:"informix".pr_status_sol WHERE status_solicitud = VNuevoStatus;
						LET vMensajeStatus = cDesStatusCtePros;
						LET cStatusPr = "P";

						IF 	VNuevoStatus = "AT" THEN 
							LET cStatusPr = "A";
							LET cDesStatusCtePros = "Solicitud Autorizada";
							LET vMensajeStatus = cDesStatusCtePros;
						ELIF VNuevoStatus = "EE" THEN 
							IF NVL(dFechaVencimiento,DATE(1)) <> DATE(1) THEN 

								IF  v_hoy  > dFechaVencimiento THEN
									LET cStatusPr = "S";
								ELSE
									LET cStatusPr = "P";
								END IF;
							ELSE
								IF cStatusSolic = "EE" THEN
									LET cStatusPr = "S";
								END IF;
							END IF;
						ELIF VNuevoStatus = "OS" THEN LET cStatusPr = "P";
						ELIF VNuevoStatus = "RT" THEN LET cStatusPr = "R"; LET cCausa_sol = "ROS";
						ELIF VNuevoStatus = "OA" THEN LET cStatusPr = "D";

						END IF;
						
						IF (SELECT COUNT(*)  FROM BDISOLIC:ss_solicitud_os WHERE num_solicitud=o_numsol AND secuenciaos=iSecuenciaOs) = 0 THEN 
							IF NOT EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN
								INSERT INTO bdisolic:"informix".ss_solicitud_os (empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status,usuario_solicita,secuenciaos,motivo_os)
								VALUES (o_empresa, o_numsol, TODAY,NVL(dFecha_Respuesta,DATE(1)),cStatusPr, "sistema",iSecuenciaOs,iMotivoOs);
							END IF;
						END IF;
						LET sBanAuto = 1; 
					END IF;
						
					/*
					--Ciclo para obtener los estatus de la solicitud existente que estan despues de 'EE'
					FOREACH 
						SELECT status_solicitud INTO VNuevoStatus FROM "informix".ss_autorizacion 
						WHERE num_solicitud = cNumsolOs
						AND fecha_hora >= cFechaHora
						ORDER BY fecha_hora ASC			

						EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, VNuevoStatus, cCausa_sol, vMensajeStatus )
						INTO p_cod_ret;

						IF p_cod_ret <> '000000' THEN
							LET scod_ret= '00006'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
							RETURN scod_ret;
						END IF;				
					END FOREACH;
					*/
					
					IF sBanAuto = 0 THEN
					-- APAGAR PROSPECTO
						IF EXISTS (SELECT num_solicitud FROM ss_solic_rt WHERE num_solicitud = o_numsol) THEN 
							LET vNuevoStatus = 'AT';
							LET vMensajeStatus = 'Solicitud Autorizada por Reevaluacion';
						ELSE
                                LET VNuevoStatus = 'EE';
                                LET vMensajeStatus = 'Solicitud Enviada a Orden de Supervision';
						END IF;
					END IF; 	
				END IF;
			END IF;
		END IF;
		--Fin Herencia de los estatus de una OS existente y vigente del mismo Cliente
		
		IF VNuevoStatus = 'EE' AND NVL(sBanAuto,0) = 0 and cCanalv1 <> 0 THEN
			INSERT INTO "informix".ss_solicitud_os
			(empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, motivo_os)
			VALUES
			(o_empresa, o_numsol, v_hoy, "S", "sistema", iMotivoOs);

			IF iMotivoOs <> 14 THEN
				LET vMensajeStatus = 'Solicitud Enviada a Orden de Supervision';        	
			END IF;        
		END IF;
		
	END IF;
	--RQM 10 1432 Se contemplan las solicitudes de prestamo con comprobante de ingresos 
	IF VNuevoStatus IN ('AT','MC') AND sFlagCanalWeb <> 1  THEN --revision para incrementos de lineasd e credito
		EXECUTE PROCEDURE "informix".sp_valida_comprobante(o_empresa ,vCte , o_numsol)
		 INTO cCodRet,cMensajeRet,iValido;
		 
		IF (cCodRet::INTEGER = 0 AND iValido = 1 AND VNuevoStatus = 'AT') THEN
			IF cProducto2 ='6001' THEN
				LET VNuevoStatus = 'LC';
			END IF;
			LET vMensajeStatus= 'Revision Linea de Credito';
			SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = o_numsol;
			IF isolcomp = 0 THEN
				INSERT INTO "informix".ss_solicitudes_cac 
				(empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
				VALUES (o_empresa, o_numsol, vCte,cSucursal, cProducto2, VNuevoStatus, "", "", "", "", "N", v_valor, CURRENT,CURRENT, DATE(1), 'N');	
			END IF;
		ELSE
			IF  cProducto2 IN ('9100','9300') THEN
				SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = o_numsol;
				IF isolcomp = 0 THEN
					INSERT INTO "informix".ss_solicitudes_cac 
					(empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
					VALUES (o_empresa, o_numsol, vCte,cSucursal, cProducto2, VNuevoStatus, "", "", "", "", "N", v_valor, CURRENT,CURRENT, DATE(1), 'N');	
				END IF;			
			END IF;
		END IF;
	END IF;
	

	IF (sFlagCanalWeb = 1) then
	
		UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
		set sts_prev_pa 	    = VNuevoStatus, 
			vvalor_junk         =  v_valor,         
			imotivos_junk       = iMotivoOs,      
			iband_altaostel     = iBanderaFaltaOSTEL,
			ctipo_movto_junk    = cTipoMovto,         
			flagforenviomcjunk  = iFlagForzarEnvioMC,
			v_hereda_stat_junk  = v_hereda_status    
		where num_solicitud = o_numsol;
	
        IF (VNuevoStatus = 'AT') THEN
            if (cProducto ='6001') THEN
                LET VNuevoStatus = 'IN';
            ELSE
                LET VNuevoStatus = 'PA';
            END IF;
        END IF;

		
		--LET cCausa_sol = '';
		SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = VNuevoStatus;

	end IF;
	
	
	IF VNuevoStatus = 'AT' AND  NVL(cNumSol,'') <> '' AND NVL(cStatusMovil,'') ='1' THEN			--para que cuando tenga completo el proceso lo deje en AT						
		LET VNuevoStatus = 'PA';
		--LET cCausa_sol = '';
		--LET vMensajeStatus= 'Solicitud Pre-Autorizada';
		
		--OBTENER LA DESCRIPCION DEL STATUS DEL CATALOGO						
		SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = VNuevoStatus;

		UPDATE "informix".ss_solicitudes_movil		
			SET status_solicitud = VNuevoStatus		
		WHERE 	empresa  = o_empresa 
		AND  num_solicitud = o_numsol;
					
	END IF;
	
	-----
	IF (VNuevoStatus <> 'RT' and cCanalv1 = 0) then
	
		UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
		set sts_prev_pa 	    = VNuevoStatus, 
			vvalor_junk         =  v_valor,         
			imotivos_junk       = iMotivoOs,      
			iband_altaostel     = iBanderaFaltaOSTEL,
			ctipo_movto_junk    = cTipoMovto,         
			flagforenviomcjunk  = iFlagForzarEnvioMC,
			v_hereda_stat_junk  = v_hereda_status    
		where num_solicitud = o_numsol; 

		LET VNuevoStatus = 'PA';
		--LET cCausa_sol = '';
		--OBTENER LA DESCRIPCION DEL STATUS DEL CATALOGO
		SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = VNuevoStatus; --- prospecteo_solicitdudes_05_19--FIN
		
		
	END IF;
	
	EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, VNuevoStatus, cCausa_sol, vMensajeStatus )
			INTO p_cod_ret;
    IF p_cod_ret <> '000000' THEN
        LET scod_ret= '00006'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
        RETURN scod_ret;
    ELSE 
    /*    IF vAsignaGrupo = 'A' OR vAsignaGrupo ='6' THEN  -- mahr-cnbv. Se elimina, ya que la actualizacion se hace previamente.
		UPDATE "informix".ss_resum_scor_fin
		   SET grupo = vAsignaGrupo  
		 WHERE empresa = o_empresa
		   AND num_solicitud = o_numsol; 
	ELIF  vgrupo_sol = '8' THEN	   
	  update bdisolic:ss_clienteslargos 
		set status ='IN'
	   where numcte = vCte;
	END IF;*/
	/*IF  vgrupo_sol = '8' THEN	   	 -- Se cambia sentencia en sp: sp_actualiza_status_sol, en cambio estatus a AP    
		UPDATE bdisolic:ss_clienteslargos 
		   SET status ='IN'
		 WHERE numcte = vCte;
	END IF;*/
	END IF;
	--RQM 10679-2 Se valida si el nuevo status es AT y 6001 se ejecuta el proceso que valida para ser candidato a TDC Oro
	IF VNuevoStatus IN ('AT','EE','MC') AND cProducto2 ='6001' THEN
		EXECUTE PROCEDURE bdisolic:"informix".sp_marcagraba_tdc_oro(o_empresa,'1', v_lineaban,o_numsol)
		INTO scod_ret_rev,vnvalinea, vnumsol;	
		IF scod_ret_rev::INTEGER <> 0 THEN
			LET scod_ret = '00008';
			RETURN scod_ret;
		END IF;		
	END IF;
	
	--### Se comenta bloque por INC 25 297 Corregir proceso de evaluacion de solicitudes omincanal producto 6800
	---- INICIO Reevaluar solicitud rechazada por CPS y genera producto 6800 RQM 09 530 ITD
	--IF cProducto2 in ('6001','6300','9100','9300') AND ((VNuevoStatus = 'RT' AND cCausa_sol = 'CPS') OR (VNuevoStatus = 'CN' AND cCausa_sol = 'LIM')) THEN
	--IF cProducto in ('6001') AND VNuevoStatus = 'RT' AND cCausa_sol = 'CPS' THEN
	--	EXECUTE PROCEDURE bdisolic:sp_genera_sol_cps(o_empresa,o_numsol,vCte,'6800','P',cSucursal,v_monto_origen)
	--			INTO scod_ret_rev;
	--		IF scod_ret_rev::INTEGER <> 0 THEN
	--			LET scod_ret = '0099';
	--			RETURN scod_ret;
	--		END IF;
	--END IF;
	---- FIN Reevaluar solicitud rechazada por CPS y genera producto 6800 RQM 09 530 ITD
	---- FIN INC 25 297 Corregir proceso de evaluacion de solicitudes omincanal producto 6800
END
RETURN scod_ret;
--Codigos de retorno:
-- '00001'  Error al consultar si la solicitud fue enviada a ST
-- '00002' Error al actualizar el estatus de solicitud al ser ST
-- '00003' Error al actualizar el estatus a rechazada por antecedentes en BC/CC.
-- '00004' Error al actualizar el estatus a rechazada por puntos insuficientes en scoring.
-- '00005' Error al actualizar el estatus a rechazada por cte desempleado.
-- '00006' Error al actualizar el estatus de solicitud al ser Autorizada o En Estudio.
-- '00007' Error al actualizar el status a AT para grupo de solicitudes de filtro parametrico
--  '0099' Error al generar solicitud 6800 de una 6001 en RT con causa CPS.
-- '00008' Error al marcar al cliente prospecto para tdc oro
END PROCEDURE

