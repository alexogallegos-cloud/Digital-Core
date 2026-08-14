CREATE PROCEDURE "informix".determina_lincred_tc_cjunk(o_empresa CHAR(3), o_numsol  CHAR(20), o_cte_nvo CHAR(1))
RETURNING CHAR(5)       AS retorno,
          MONEY(14,2)   AS linea_cred,
          MONEY(14,2)   AS capacidad_de_pago,
          INTEGER       AS plazo;

		  
    -- CONTROL DE CAMBIOS:
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificacion: Se valida el producto de la solicitud del cliente. Al tratarse
--               de un producto coppel, se determina si es credito joven y
--               calcula su linea de credito.
-- Fecha de Modificacion: 13/01/2009
-- Proyecto: Caja unica
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificacion: Se realiza calculo para la determinacion de la linea para Prestamo
--               Personal BanCoppel.
-- Fecha de Modificacion: 29/09/2009.
-- Peticion: Prestamo Personal
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificacion: Se modifica para agregar parametros de entrada al momento
--                     de la ejecucion del sp_proyecta_prestamos y cachar los valores
--                     de retorno agregados a dicho sp.
-- Fecha de Modificacion: 01/11/2009.
-- Peticion: Prestamo Personal
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificacion: Se eliminan validaciones en base a codigo de producto y en su
--               lugar se realizan en base al tipo de solicitud, para que el
--               proceso pueda funcionar para demas productos asociados a un
--               tipo de solicitud existente.
-- Fecha de Modificacion: 04/11/2009.
-- Peticion: Prestamo Personal
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Autor: Paul Ivan Quintero Varela
-- Modificacion: Se actualiza para determinar los compromisos del cliente en el banco
--               a traves del maestro de amortizaciones en vez del campo sdo_trab4 del maestro
--               de saldos
-- Fecha de Modificacion: 12/11/2009.
-- Peticion: Prestamo Personal
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificacion: Se valida que el monto del prestamo y el plazo se encuentren
--               dentro de los rangos permitidos, para esto se realizan las
--               proyecciones con los parametros necesario para obtener dichos
--               datos.
-- Fecha de Modificacion: 22/01/2010.
-- Peticion: Prestamo Personal
--------------------------------------------------------------------------------
-- Autor: Mohamed Carreon
-- Modificacion: Se valida que cuando el ingreso sea menor al salario minimo promedio 
--               el valor del ingreso sea igual al salario minimo promedio y ademas 
--               se guarde este en la tabla ss_resum_scor_fin dentro del campo salario_minimo
-- Fecha de Modificacion: 08/06/2011.
-- Peticion: Alta Unica Paso 05
--Autor: Jesus Manuel Aguilar Heredia
--Modificacion: Se modifica para que cuando un credito restructurado, ya este liquidado, se realice la determinacion de la linea de credito en base al grupo de cliente
-- Peticion: RQM 09 240 "Solicitud de credito posterior a una liquidacion de una reestructura".
--Fecha de Modificacion: 26-07-2011
---------------------------------------------------------------------------------
-- Autor: Luis ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂngel JuÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ¡rez VÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ¡zquez, Gustavo Fuentes LÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ³pez
-- Modificacion: Se ha agregado la validaciÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ³n de producto para realizar nueva evaluaciÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ³n de parametros .
-- Fecha de Modificacion: 20-08-2022.
-- Peticion: Prestamo Personal
---------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Autor: Luis Angel Garcia Gayosso, Kevin Galvez Parra
-- Modificacion: Se agrega validacion para ver si la solicitud es de OneClick para que se actualicen en las tablas 
-- ss_certif_evaluacion_buro_pp y ss_certif_evaluacion_cte_pp

-- Fecha de Creacion: 25-06-2025
-- Proyecto: RQM 09 665- Capacidad de Pago - One Click
----------------------------------------------------------------------------------------------------------------',
--------------------------------------------------------------------------------
-- Autor: Kevin Galvez Parra
-- Modificacion: Se agrega validacion de OneClick Prestamo Digital para enviar a BRM.

-- Fecha de Creacion: 19-09-2025
-- Proyecto: RQM 09 665- Capacidad de Pago - One Click
----------------------------------------------------------------------------------------------------------------',

--------------------------------------------------------------------------------
-- Autor: Luis Angel Garcia Gayosso
-- Modificacion: Se agrega variable consulta para validacion de OneClick Prestamo Digital para enviar a BRM.

-- Fecha de Creacion: 30-01-2026
-- Proyecto: RQM 09 665- Capacidad de Pago - One Click
----------------------------------------------------------------------------------------------------------------',

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret                 CHAR(3);
DEFINE vsqlerr                  INTEGER;
DEFINE v_tasa                   DECIMAL(9,6);
DEFINE v_tasa_mora				DECIMAL(9,6);
DEFINE v_factor                 CHAR(1);
DEFINE v_sobretasa              DECIMAL(9,6);
DEFINE v_porc_linea             DECIMAL(6,3);
DEFINE v_salariomin             DECIMAL(14,2);
DEFINE v_porcsalmin             DECIMAL(6,3);
DEFINE v_paramfactor            SMALLINT;
DEFINE v_ingreso                MONEY(14,2);
DEFINE v_ingreso_ant            MONEY(14,2);
DEFINE v_tope_ingre             DECIMAL(14,6);
DEFINE v_tope_ingreso      		DECIMAL(14,2);
DEFINE v_situacion              DECIMAL(6,3);
DEFINE v_meseshist              SMALLINT;
DEFINE v_comproboingreso        SMALLINT;
DEFINE v_porcpermitido          DECIMAL(6,3);
DEFINE v_mesespermitido         SMALLINT;
DEFINE v_minimomesespermitido   SMALLINT;
DEFINE v_capacidad              MONEY(14,2);
DEFINE v_linea                  MONEY(14,2);
DEFINE v_factor_calc           DECIMAL(21,10);
DEFINE v_factor_vp            DECIMAL(21,10);
DEFINE v_compromisos            MONEY(14,2);
DEFINE v_lintienda              MONEY(14,2);
DEFINE v_plazo                  SMALLINT;
DEFINE v_elevado                DECIMAL(21,6);
DEFINE v_moneypaso              MONEY(14,2);
DEFINE cNumCte                  CHAR(20);
DEFINE cEdad                    CHAR(10);
DEFINE v_limite_inferior        DECIMAL(14,2);
DEFINE v_limite_inferior_hit    DECIMAL(14,2);
DEFINE v_limitsuperior_sc       DECIMAL(14,2);
DEFINE v_limitsuperior_cc       DECIMAL(14,2);
DEFINE v_topemax                DECIMAL(14,2);
DEFINE v_param_edad             DECIMAL(14,2);
DEFINE v_abonomesprestamo       MONEY(14,2);
DEFINE v_abonomesmuebles        MONEY(14,2);
DEFINE v_abonomesropa           MONEY(14,2);

-- Ini Caja Unica. Viridiana
DEFINE cProducto                CHAR (4);
DEFINE cProducto2                CHAR (4);
DEFINE cSexo                    CHAR (1);
DEFINE iMinEdadCredCoppel       SMALLINT;
DEFINE iMaxEdadCredJovenF       SMALLINT;
DEFINE iMaxEdadCredJovenH       SMALLINT;
DEFINE iMaxEdadCredCoppel       SMALLINT;
DEFINE iMontoCreditoJoven       SMALLINT;
DEFINE iEdad                    SMALLINT;
DEFINE cNumcredito              CHAR(20);
DEFINE v_comprobanco            MONEY (14,2);
DEFINE v_comprobancoprestamo    MONEY (14,2);
DEFINE iPlazoMax                INTEGER;
DEFINE cSucursal                CHAR(4);
DEFINE iNum_periodos            INTEGER;
DEFINE dtFecha_cuota            DATE;
DEFINE dSdo_inicial             MONEY(14,2);
DEFINE dPago_mensual            MONEY(14,2);
DEFINE dMto_Interes             MONEY(14,2);
DEFINE dIva_interes             MONEY(14,2);
DEFINE dCapital                 MONEY(14,2);
DEFINE dSdo_final               MONEY(14,2);
DEFINE sDias_periodo            SMALLINT;
DEFINE v_diaspromedio           DECIMAL(14,2);
DEFINE dMto_min                 DECIMAL(18,2);
DEFINE dMto_max                 DECIMAL(18,2);
DEFINE Codret                   CHAR(6);
DEFINE dtFecha_Aper		        DATE;
DEFINE cTpSolicitud             CHAR(1);
DEFINE iPlazoMin                INTEGER;
DEFINE cTpSeccion				INTEGER;
DEFINE cStatus					CHAR(2);
DEFINE cCompIngresos			CHAR(1);
-- Fin Caja Unica. Viridiana
--JOM INI
DEFINE v_flujo_libre1      DECIMAL(14,2);
DEFINE v_flujo_libre2      DECIMAL(14,2);
DEFINE v_factor_flujo1     DECIMAL(5,2);
DEFINE v_factor_flujo2     DECIMAL(5,2);
DEFINE v_min_flujo         DECIMAL(14,2);
DEFINE v_max_flujo         DECIMAL(14,2);
DEFINE v_linea_teorica     DECIMAL(14,2);
--JOM FIN
DEFINE v_salarios_max      DECIMAL(14,2);
DEFINE v_paso              DECIMAL(14,2);
DEFINE mIngresoProm		   MONEY(16,2);
DEFINE iFrecuencia		   INTEGER;
DEFINE cNumMesesPagos      CHAR(3);
DEFINE dValor_max          DECIMAL(14,2);
DEFINE dPorcentaje_max     DECIMAL(14,2);
DEFINE dLineaPorcentaje    DECIMAL(14,2);
DEFINE v_factorree         DECIMAL(14,2);
DEFINE v_linea_ree         DECIMAL(14,2);
DEFINE v_lineasinTopes     DECIMAL(14,2);
-- RQM 09 262 LHM INI
DEFINE v_topemax_NO_HIT    DECIMAL(14,2);
DEFINE v_evalua_cc         char(01);
DEFINE v_compromi_tdc      DECIMAL(14,2);
-- RQM 09 262LHM FIN
DEFINE dIngresoCac         DECIMAL(14,2);
DEFINE dCompromisosCac     DECIMAL(14,2);
DEFINE cMensaje_ret        VARCHAR(100,1);
DEFINE cValido   		   SMALLINT;
DEFINE cTope 			   CHAR(1);
DEFINE v_grupo             char(01); ---multiple junio 2013
DEFINE vlIVA               decimal (5,3); 
DEFINE vlMontoHipoteca     decimal (14,2);
DEFINE vlMontoHipoteca_ant     decimal (14,2);
DEFINE vlMontoHipoteca2     decimal (14,2);
DEFINE pporc_mod_lin	   decimal(18,2);
DEFINE pporc_mod_linTDC	   decimal(18,2);
DEFINE pporc_mod_linPP	   decimal(18,2);
DEFINE ptipo_modifica 	   CHAR(1);
DEFINE v_lineaMod          MONEY(14,2);
DEFINE v_capacidadMod      MONEY(14,2);
DEFINE cCodRet 				CHAR(6); 
DEFINE ptipogrupo 			CHAR(2); 
DEFINE phit 				CHAR(6); 	
DEFINE v_compteorico        MONEY(14,2);
define vcompromiso_coppel   MONEY;
define vcompromiso_rmp    	MONEY;

DEFINE dCompromisosTotal MONEY(14,2);
DEFINE v_compromisos_sic MONEY(14,2);
DEFINE v_tasasiniva	DECIMAL(9,6);
DEFINE v_tasaMens	DECIMAL(9,6);
DEFINE dPorcIncr     DECIMAL(14,2);
DEFINE dMontoIncr     DECIMAL(14,2);
DEFINE dMontoDecr     DECIMAL(14,2);
DEFINE dPorcDecr     DECIMAL(14,2);
DEFINE cBanderaRR CHAR(1);
DEFINE v_lineaRR DECIMAL(14,2);
DEFINE v_comprobancoCRNOM DECIMAL(14,2);
DEFINE v_comprobancoPP DECIMAL(14,2);
DEFINE v_comprobancoTDC DECIMAL(14,2);
DEFINE v_lineaAnt DECIMAL(14,2);
DEFINE dCRA DECIMAL(14,2);
DEFINE dCTA DECIMAL(14,2);
DEFINE cRevisionMC CHAR(1);
DEFINE iISM DECIMAL(14,2);
DEFINE v_valor_1s DECIMAL(14,2);
DEFINE iIdRiesgo INTEGER;
DEFINE dMaxPorcHipo DECIMAL(14,2);
DEFINE dMinPorcHipo DECIMAL(14,2);
DEFINE dPorSic DECIMAL(14,2);
DEFINE dMaxPorcOtros DECIMAL(14,2);
DEFINE dMinPorcOtros DECIMAL(14,2);
DEFINE dPorHipo DECIMAL(14,2);
DEFINE dPorOtros DECIMAL(14,2);
DEFINE dOtrosComp DECIMAL(14,2);
DEFINE vflagoro				SMALLINT; --Valor
DEFINE dlinea_min_prod      DECIMAL(18,2);
DEFINE v_Cont6011        SMALLINT;
DEFINE dMax_fecha_tasa		DATE;
DEFINE cCodRetTDif			CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS

--- RQM 09 530 
DEFINE v_mixta_unica				CHAR(1);
DEFINE v_porcentaje_compromiso		SMALLINT;
DEFINE flag_recalculopp12	SMALLINT;
--
DEFINE v_max_limite_hit_con_inf_pd DECIMAL(14,2);
--RQM 10 1177
DEFINE v_iplazomax  INTEGER;

-- RQM 69 613
DEFINE vCuentasPF	 SMALLINT; 
DEFINE vIdModeloHit   	SMALLINT; 
DEFINE vGrupoInfo 		CHAR(10);
DEFINE vScoreBC		SMALLINT;
DEFINE cTipo_producto CHAR(2);
DEFINE cSegmento CHAR(3);
DEFINE iNewMPP INTEGER;

-- RQM 09632
DEFINE dPlazo 	  INTEGER;
DEFINE v_tope_min DECIMAL(14,6);
DEFINE cElemento SMALLINT;

DEFINE iOneClick SMALLINT;
DEFINE iOneClickPP SMALLINT;

DEFINE cBRM_reing SMALLINT;    --MACM
DEFINE cSituacionEspecial       CHAR(1); --MACM
DEFINE sCausaSituacion          SMALLINT; --MACM
DEFINE mAbonoAire    		    DECIMAL(18,2);    --Abono mensual del cliente en tiempo aire
DEFINE mAbonoAfiliados 	        DECIMAL(18,2);    --Abono mensual del cliente en afiliados
DEFINE mAbonoReestructura 	    DECIMAL(18,2);    --Abono mensual del cliente en reestructuras
DEFINE mVencidoMuebles 	        DECIMAL(18,2);    --vencido mensual del cliente en muebles
DEFINE mVencidoRopa 	        DECIMAL(18,2);    --vencido mensual del cliente en ropa
DEFINE mVencidoAire             DECIMAL(18,2);    --vencido mensual del cliente en tiempo aire
DEFINE mVencidoAfiliados        DECIMAL(18,2);    --vencido mensual del cliente en afiliados
DEFINE mVencidoReestructura     DECIMAL(18,2);    --vencido mensual del cliente en reestructura
DEFINE cOrigenSol        CHAR(1);  
DEFINE sHist_meses              SMALLINT; 
DEFINE dEficienciaCoppel    	DECIMAL(5,2);
DEFINE mVencidoPrestamos        DECIMAL(18,2); 
DEFINE mIngreso_Mensual			DECIMAL(18,2);
DEFINE mLinea_tienda            DECIMAL(18,2);
DEFINE mImporte_hip      DECIMAL(18,2);
DEFINE cHabita_en               CHAR (50);
DEFINE cCod_Ult_Identif         CHAR(2);
DEFINE cCurp 					CHAR(20); 
DEFINE dtUltimaCompra           CHAR(10) ;
DEFINE cOrigenCte        CHAR(1);
DEFINE dCompromisos                 DECIMAL(14,2);
DEFINE mSaldoRopa				DECIMAL(18,2);
DEFINE mSaldoMuebles			DECIMAL(18,2);
DEFINE mSaldoPrestamos			DECIMAL(18,2);
DEFINE pMeses_historia_grupo 	SMALLINT;
DEFINE pSituacion_pago_grupo 	DECIMAL(5,2);
DEFINE iDiaPago      			VARCHAR(50);
DEFINE cFechaUltimoPago         CHAR(13); 
DEFINE iReprestamos             	INTEGER; 
DEFINE cProfesion             	CHAR(3);       --profesiÃÂÃÂ³ÃÂÃÂ®ÃÂÃÂ ÃÂÃÂ¤el cliente MACM

DEFINE isBRM					SMALLINT;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret            = "000";
LET vsqlerr             = 0;
LET v_plazo             = 12;
LET v_linea             = 0;
LET cNumCte             = "";
LET cEdad               = "";
LET v_abonomesprestamo  = 0;
LET v_abonomesmuebles   = 0;
LET v_abonomesropa      = 0;


-- Ini Caja Unica. Viridiana
LET iMinEdadCredCoppel      = 0;
LET iMaxEdadCredJovenF      = 0;
LET iMaxEdadCredJovenH      = 0;
LET iMaxEdadCredCoppel      = 0;
LET iMontoCreditoJoven      = 0;
LET iEdad                   = 0;
LET v_capacidad             = 0;
LET cNumcredito             = "";
LET v_comprobanco           = 0;
LET v_comprobancoprestamo   = 0;
LET v_comprobancoTDC	    = 0;
LET iPlazoMax               = 0;
LET cSucursal               = "";
LET iNum_periodos           = 0;
LET dtFecha_cuota           = DATE(1);
LET dSdo_inicial            = 0;
LET dPago_mensual           = 0;
LET dMto_Interes            = 0;
LET dIva_interes            = 0;
LET dCapital                = 0;
LET dSdo_final              = 0;
LET sDias_periodo           = 0;
LET dMto_min                = 0;
LET dMto_max                = 0;
LET Codret                  = "000000";
LET dtFecha_Aper            = DATE(1);
LET cTpSolicitud            = "";
LET iPlazoMin               = 0;
LET cTpSeccion				= 0;
LET cStatus					= "";
LET cCompIngresos			= "";
LET v_diaspromedio          = 0;
-- JOM INI
LET v_tope_ingreso  = 0;
LET v_factor_flujo1 = 0;
LET v_factor_flujo2 = 0;
-- JOM FIN
LET v_salarios_max   = 0;
LET v_paso = 0;
LET mIngresoProm	= 0;
LET iFrecuencia		= 1;
LET cNumMesesPagos  	= "";
LET dValor_max  = 0;
LET dPorcentaje_max    = 0;
LET dLineaPorcentaje    = 0;
LET v_factorree       = 0;
LET v_linea_ree       = 0;
LET v_compromi_tdc = 0;
LET v_lineasinTopes = 0;

LET dIngresoCac         = 0;
LET dCompromisosCac     = 0;
LET cMensaje_ret        = '';
LET cValido   		    = '';
LET cTope 			    = 'S';
LET v_grupo            = "";
let vlIVA              = 0;
LET vlMontoHipoteca    = 0;
LET vlMontoHipoteca_ant    = 0;
LET vlMontoHipoteca2    = 0;
let v_factor_calc      = 0;
let v_factor_vp      = 0;
let v_compteorico	   = 0;
LET vcompromiso_coppel = 0;
let vcompromiso_rmp	   = 0;

-- RQM 09 262 LHM INI
LET v_topemax_NO_HIT = 0;
LET v_evalua_cc      = '';
-- RQM 09 262LHM FIN
-- RQM 09 324 FMJ

LET dCompromisosTotal  = 0;
LET v_compromisos_sic =0;
LET v_tasasiniva	 = 0;
LET v_tasaMens	 = 0;
LET pporc_mod_lin	=0;
LET pporc_mod_linTDC	=0;
LET pporc_mod_linPP	=0;
LET ptipo_modifica 	='';
LET v_lineaMod        = 0;
LET v_capacidad		  = 0;
LET cCodRet  = '000000'; 
LET dPorcIncr = 0;
LET dMontoIncr = 0;
LET dMontoDecr = 0;
LET dPorcDecr = 0;

LET cBanderaRR ='0';
LET v_lineaRR = 0;
LET v_lineaAnt = 0;
LET v_comprobancoCRNOM = 0;
LET v_comprobancoPP = 0;
LET v_comprobancoTDC = 0;
LET v_lineaAnt = 0;
LET cRevisionMC ='0';
LET dCRA = 0;
LET dCTA = 0;
LET iISM = 0;
LET v_valor_1s = 0;
LET iIdRiesgo= 0;
LET dMaxPorcHipo = 0;
LET dMinPorcHipo = 0;
LET dPorSic = 0;
LET dMaxPorcOtros = 0;
LET dMinPorcOtros = 0;
LET dPorHipo= 0;
LET dPorOtros = 0;
LET dOtrosComp = 0;
LET cProducto = '';
LET v_ingreso_ant = 0;
LET vflagoro = 0;
LET dlinea_min_prod = 0;
LET v_Cont6011 = 0;
---LET v_salariomin    ="";
LET dMax_fecha_tasa = DATE(1);
LET cCodRetTDif		= '';
LET v_tasa			= 0;
LET v_tasa_mora		= 0;

--- RQM 09 530 
LET v_mixta_unica = '';
LET v_porcentaje_compromiso = 0;
LET flag_recalculopp12	= 0;
LET v_limite_inferior_hit = 0;
--
LET v_max_limite_hit_con_inf_pd = 0;
LET v_iplazomax = 0;
--RQM 09 613
LET vCuentasPF  = 0;
LET vIdModeloHit = 0;
LET vGrupoInfo = '';
LET vScoreBC = 0;
LET cTipo_producto      = "";
LET cSegmento ='';
LET iNewMPP = 0;

-- RQM 09632
LET dPlazo	   = 0;
LET v_tope_min = 0;
LET cElemento  = 0;


LET iOneClick = 0;
LET iOneClickPP = 0;
LET cBRM_reing = 0; --MACM
LET cSituacionEspecial   		  	="?"; --MACM
LET sCausaSituacion      		  	= 0; --MACM
LET mAbonoAire           			= 0;
LET mAbonoAfiliados     			= 0;
LET mAbonoReestructura   			= 0;
LET mVencidoMuebles 	 			= 0;
LET mVencidoRopa 	     			= 0; 
LET mVencidoAire         			= 0; 
LET mVencidoAfiliados    			= 0;
LET mVencidoReestructura 			= 0;
LET cOrigenSol        ='1';
LET sHist_meses               	  	= 0;
LET dEficienciaCoppel			  	= 0; 
LET mVencidoPrestamos    			= 0; 
LET mIngreso_Mensual	  = 0; 
LET mLinea_tienda        			= 0; 
LET mImporte_hip      = 0;  
LET cHabita_en            ="??";
LET cCod_Ult_Identif      =""; 
LET cCurp  				  =""; 
LET dtUltimaCompra       		 	= '01/01/1900';
LET cOrigenCte		  ="";
LET dCompromisos              = 0;
LET mSaldoRopa			 			= 0;
LET mSaldoMuebles		 			= 0;
LET mSaldoPrestamos		 			= 0;
LET pMeses_historia_grupo = 0;
LET pSituacion_pago_grupo = 0;
LET iDiaPago        ="";
LET cFechaUltimoPago     		  	="";
LET iReprestamos           	= 0;
LET cProfesion            =""; --MACM
LET isBRM =0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
   END IF;
END EXCEPTION;

	-- SET DEBUG FILE TO '/informix/determina_lincred_tc_cjunk.out';
-- TRACE ON;

	-- SET debug file to '/home/e10001126/logsapp/determina_lincred_tc_cjunk_'||trim(o_numsol)||'.out';
	-- TRACE ON;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
-- ********************************************
   --  Se obtiene la edad del cliente            *
   -- ********************************************
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

   SELECT a.numcte,a.sucursal,a.num_producto,a.tipo_solicitud, a.status_solicitud,NVL(b.ingreso_cac,0),NVL(compromisos_cac,0),NVL(comprobante_valido_cac,"N")
    INTO cNumCte,cSucursal,cProducto,cTpSolicitud,cStatus,dIngresoCac,dCompromisosCac,cCompIngresos
    FROM bdisolic:"informix".ss_solicitudes a
	LEFT OUTER JOIN	bdisolic:"informix".ss_solicitudes_cac b ON ( a.num_solicitud = b.num_solicitud)
	WHERE a.num_solicitud = o_numsol;
	--Validacion para verificar si es oneclick
	SELECT COUNT(*) INTO iOneClick FROM bdisolic:ss_solicitudes WHERE num_solicitud = o_numsol AND canal_sol IN ('6','7');
	
	SELECT	count(*)
	INTO isBRM
	FROM bdisolic:ss_certif_evaluacion_cte_pp
	WHERE cSolBanco_ss = o_numsol;
	
	SELECT COUNT(*) 
	INTO iOneClickPP 
	FROM bdisolic:ss_solicitudes 
	WHERE num_solicitud = o_numsol AND
		 canal_sol IN ('6','7') AND
		 num_producto = '6800' AND 
		 isBRM > 0;


--***************************************************
--Se obtienes los salarios maximos para producto 6600
--***************************************************

	--MACM
   SELECT count(*) INTO cBRM_reing FROM bdisolic:"informix".ss_enviossolicitudesmotor_pp where num_solicitud = o_numsol AND status_consumo= '0';
  	
	IF dIngresoCac > 0 THEN
		LET cRevisionMC = '1';	END IF
   
    IF cProducto = "6600" THEN
        SELECT valor INTO v_salarios_max FROM bdisolic:"informix".ss_param
        WHERE empresa= o_empresa AND secuencia= 358;
    END IF;

    ---- SE OBTIENE EL POCENTAJE DE LOS COMPROMISOS DE TDC

        SELECT valor INTO v_compromi_tdc
         FROM bdisolic:"informix".ss_param
        WHERE empresa= o_empresa AND secuencia= 35;
        

-- Se obtiene la edad del cliente
   SELECT (EXTEND(current, year to month) - extend(fecha_nac, year to month)), TRIM(habita_en), codidentifi, curp, profesion 
    INTO cEdad, cHabita_en, cCod_Ult_Identif, cCurp, cProfesion 
     FROM bdinteg:"informix".si_ctepf
    WHERE numcte = cNumCte;

    LET cEdad = TRIM(cEdad);
    LET iEdad= CAST(cEdad[1,2] AS SMALLINT);

-- Ini Caja Unica: Viridiana Osobampo

-- *****************************************************************************
-- Consulta si se trata de una solicitud coppel y si es credito joven
-- *****************************************************************************

   IF cTpSolicitud = 'C' THEN
       SELECT sexo
         INTO cSexo
         FROM bdinteg:"informix".si_ctepf
        WHERE empresa= o_empresa
          AND numcte= cNumCte;

       SELECT valor
         INTO iMinEdadCredCoppel
         FROM bdisolic:"informix".ss_param
        WHERE empresa= o_empresa
          AND secuencia= 342;

       SELECT valor
         INTO iMaxEdadCredCoppel
         FROM bdisolic:"informix".ss_param
        WHERE empresa= o_empresa
          AND secuencia= 345;

       IF cSexo IS NULL THEN
           RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
       END IF;

       IF iEdad < iMinEdadCredCoppel THEN
           LET scod_ret = "473";
           RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
       END IF;

       IF cSexo= 'F' THEN

           SELECT valor
             INTO iMaxEdadCredJovenF
             FROM bdisolic:"informix".ss_param
            WHERE empresa= o_empresa
              AND secuencia= 343;

           IF (iEdad >= iMinEdadCredCoppel) AND (iEdad <= iMaxEdadCredJovenF)  THEN
               SELECT valor
                 INTO v_linea
                 FROM bdisolic:"informix".ss_param
                WHERE empresa= o_empresa
                  AND secuencia= 349;

                 IF v_linea IS NULL THEN
                       LET v_linea = 0;
                 END IF;

                 RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
           END IF;
       ELIF cSexo= 'M' THEN

           SELECT valor
             INTO iMaxEdadCredJovenH
             FROM bdisolic:"informix".ss_param
            WHERE empresa= o_empresa
              AND secuencia= 344;

           IF (iEdad >= iMinEdadCredCoppel) AND (iEdad <= iMaxEdadCredJovenH) THEN
               SELECT valor
                 INTO v_linea
                 FROM bdisolic:"informix".ss_param
                WHERE empresa= o_empresa
                  AND secuencia= 349;

               IF v_linea IS NULL THEN
                   LET v_linea = 0;
               END IF;

               RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
           END IF;
       END IF;
   END IF;

-- Fin Caja Unica
	-- **************************************************

	-- Extrae Parametros para la definicion de la Linea *
	-- **************************************************

	SELECT valor
      INTO v_porcpermitido -- Porcentaje de Situacion de pago
	  FROM bdisolic:"informix".ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 307;

	IF v_porcpermitido IS NULL THEN
		LET scod_ret = "451";
		RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF

	SELECT valor
      INTO v_mesespermitido -- Meses de Historia base
	  FROM bdisolic:"informix".ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 308;

    IF v_mesespermitido IS NULL THEN
		LET scod_ret = "452";
		RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF

    SELECT valor
      INTO v_minimomesespermitido --  Meses de Historia Minimo
	  FROM bdisolic:"informix".ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 329;

	IF  v_minimomesespermitido IS NULL THEN
		LET scod_ret = "452";
		RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF

	SELECT valor::DECIMAL(14,2)
	INTO v_salariomin -- Salario Minimo Base
	FROM bdisolic:"informix".ss_param
	WHERE empresa = o_empresa
	AND secuencia = 354;

	IF v_salariomin IS NULL THEN
		LET scod_ret = "452";
		RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;

	SELECT valor::DECIMAL(14,2)
      INTO v_diaspromedio -- Salario Minimo Base
	  FROM bdisolic:"informix".ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 355;

	IF v_diaspromedio IS NULL THEN
		LET scod_ret = "452";
		RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;

/*    SELECT valor
      INTO v_tasa -- Tasa para determinacion de linea
      FROM bdisolic:"informix".ss_param
     WHERE empresa = o_empresa
       AND secuencia = 312;
       */
    ---Se cambia la obtencion de la tasa
    SELECT iva into vlIVA FROM bdinteg:si_sucursales where sucursal =cSucursal;

    /*SELECT (c.valor) +  (c.valor * vlIVA), (c.valor), a.monto_min_cred
      INTO v_tasa, v_tasasiniva, dlinea_min_prod
	  FROM bdicred:sd_definicion a, 
           bdisolic:ss_solicitudes b,
	       bdinteg:si_fechavalor c
	 WHERE b.empresa = o_empresa
	   AND num_solicitud = o_numsol
	   AND a.empresa = b.empresa
	   AND a.num_producto = b.num_producto
	   AND c.empresa = a.empresa
	   AND c.tasa = a.cod_tasa_base
	   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
			   WHERE r.empresa = o_empresa
			     AND r.tasa = a.cod_tasa_base);

    IF v_tasa IS NULL THEN
       LET scod_ret = "453";
       RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF
	*/			--	RQM 10 1224	

	IF cProducto = '9300' THEN -- RQM 09632 
		SELECT valor::DECIMAL(14,6)
		INTO v_tope_ingre -- Salario Maximo
		FROM bdisolic:"informix".ss_param
		WHERE empresa = o_empresa
		AND secuencia = 414;

		SELECT valor::DECIMAL(14,6)
		INTO v_tope_min -- Tope Ingreso Min
		FROM bdisolic:"informix".ss_param
		WHERE empresa = o_empresa
		AND secuencia = 413;
	ELSE
		SELECT valor::DECIMAL(14,6)
		INTO v_tope_ingre
		FROM bdisolic:"informix".ss_param
		WHERE empresa = o_empresa
		AND secuencia=353;
	END IF;

	-- *******************************************************************
	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************
	-- Se obtiene el grupo
    call bdisolic:"informix".sp_obtienegrupo (o_numsol)RETURNING cCodRet,ptipogrupo,phit;	
    UPDATE bdisolic:"informix".ss_resum_scor_fin
        SET grupo = ptipogrupo
        WHERE empresa = o_empresa AND num_solicitud = o_numsol;	
	--- fin de grupo
	-- RQM 09632 Se le asigna el plazo si el campo viene vacio
	IF cProducto = '9300' THEN
		SELECT a.plazo
		INTO dPlazo 
		FROM bdicred:sd_tasas_disposiciones_diferenciadas a
		INNER JOIN bdisolic:ss_resum_scor_fin b on (a.empresa = b.empresa AND a.grupo = b.grupo AND a.evalua_cc = NVL(b.evalua_cc,'X'))
		WHERE a.empresa = o_empresa 
		AND b.num_solicitud = o_numsol
		AND a.num_producto = cProducto;

		UPDATE bdisolic:ss_solicitudes set plazo = dPlazo
		where empresa = o_empresa AND num_solicitud = o_numsol;
	END IF;
	
	-- Obtiene TASAS DE INTERES DIFERENCIADAS.		-- INI
	EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(o_empresa, o_numsol, '') INTO cCodRetTDif, v_tasa, v_tasa_mora;
	IF cCodRetTDif <> '000000' OR v_tasa IS NULL THEN
       LET scod_ret = "453";
       RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;		
	

	SELECT (v_tasa) + (v_tasa * vlIVA), (v_tasa), a.monto_min_cred
      INTO v_tasa, v_tasasiniva, dlinea_min_prod
	  FROM bdicred:sd_definicion a INNER JOIN bdisolic:ss_solicitudes b ON (a.empresa = b.empresa AND a.num_producto = b.num_producto AND b.num_solicitud = o_numsol)
	 WHERE a.empresa = o_empresa;
	-- Obtiene TASAS DE INTERES DIFERENCIADAS.		-- FIN
	
	
   SELECT ingreso_mensual, situacion_pago, meses_historia , pago_minimo,
          linea_tienda, abonomensualprestamos,abonomensualmuebles,abonomensualropa, evalua_cc,
          monto_hipoteca, nvl(grupo,''),tipo_movimiento, situacion_especial, causa,
		  situacion_pago, meses_historia, abonomensualaire, abonomensualafiliados, abonomensualreestructura, 
		  vencidomuebles, vencidoropa, vencidototalaire, vencidototalafiliados, vencidototalreestructura, origen,
		  vencidoprestamos, ingreso_mensual, linea_tienda, monto_hipoteca, fecha_ultima_compra, fuente, pago_minimo,
		  saldoropa,saldomuebles, saldoprestamos, meses_historia,situacion_pago, fechaultimopago,represtamo
		  
	 INTO v_ingreso, v_situacion, v_meseshist, v_compromisos, v_lintienda,
          v_abonomesprestamo,v_abonomesmuebles,v_abonomesropa, v_evalua_cc,
          vlMontoHipoteca, v_grupo,v_mixta_unica, cSituacionEspecial, sCausaSituacion,
		  dEficienciaCoppel, sHist_meses, mAbonoAire, mAbonoAfiliados, mAbonoReestructura, 
		  mVencidoMuebles, mVencidoRopa,mVencidoAire, mVencidoAfiliados, mVencidoReestructura, cOrigenSol,
		  mVencidoPrestamos, mIngreso_Mensual, mLinea_tienda, mImporte_hip, dtUltimaCompra, cOrigenCte, dCompromisos,
		  mSaldoRopa, mSaldoMuebles, mSaldoPrestamos, pMeses_historia_grupo, pSituacion_pago_grupo,cFechaUltimoPago,iReprestamos
		  
     FROM bdisolic:"informix".ss_resum_scor_fin
    WHERE empresa = o_empresa
      AND num_solicitud = o_numsol;

	if v_lintienda > 0 then
	  let v_compteorico	= (v_lintienda * .10);
	end if; 
	LET v_ingreso_ant = v_ingreso ;
	

	
	---Se valida que si es el producto CrediNomina va a comparar cual es el monto menor, el ingreso mensual o el promedio mensual, ya que se va a considerar el menor para el calculo de linea de credito
	IF cProducto = '6400' THEN
		SELECT NVL(promedio_mes,0),NVL(frecuencia_pgo,1), dia_pago
		INTO mIngresoProm,iFrecuencia, iDiaPago
		FROM bdisolic:"informix".ss_sol_nomina
		WHERE  empresa = o_empresa
		AND num_solicitud = o_numsol;
		
		IF v_ingreso > mIngresoProm AND iOneClick=0 THEN
			LET v_ingreso = mIngresoProm;
		END IF;
	END IF;


	
--ini cas rqm 09 172
            -- *******************************************
            -- Extrae Porcentaje de ingresos del cliente *
            -- *******************************************
    IF (v_situacion >= v_porcpermitido and v_meseshist >= v_minimomesespermitido) THEN -- OR (v_situacion >= v_porcpermitido and v_meseshist < v_mesespermitido and v_meseshist >= v_minimomesespermitido)
        LET v_paramfactor = 301; -- Cliente No Nuevo factor 0.20
    ELSE
        LET v_paramfactor = 302; -- Cliente Nuevo
        LET v_situacion = 0;
        LET v_meseshist = 0;
    END IF
    ---Se limpia meses de historia y Situacion para cliente Grupo A
    IF ( v_grupo = 'A') then
        LET v_situacion = 0;
        LET v_meseshist = 0;
    END IF;   

    SELECT valor / 100
      INTO v_porcsalmin
      FROM bdisolic:"informix".ss_param
     WHERE empresa = o_empresa
       AND secuencia = v_paramfactor;

    IF v_porcsalmin IS NULL THEN
        LET scod_ret = "453";
        RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF

--fin cas rqm 09 172

    IF v_ingreso IS NULL THEN
    LET scod_ret = "454";
            RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF

    IF v_compromisos IS NULL THEN
    LET v_compromisos = 0;
    END IF

    IF v_abonomesprestamo IS NULL THEN
            LET v_abonomesprestamo=0;
    END IF;

    IF v_abonomesmuebles IS NULL THEN
            LET v_abonomesmuebles=0;
    END IF;

    IF v_abonomesropa IS NULL THEN
            LET v_abonomesropa=0;
    END IF;

    IF v_situacion IS NULL THEN
    LET scod_ret = "455";
            RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF

    IF v_meseshist IS NULL THEN
    LET scod_ret = "456";
            RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF

    IF v_lintienda IS NULL THEN
    LET scod_ret = "457";
            RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF

	-- *******************************************************************

	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************


	SELECT COUNT(*)
      INTO v_comproboingreso
	  FROM bdisolic:"informix".ss_detalle_scoring
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol
	   AND seccion = 2
	   AND grupo = 14
	   AND elemento = 3;

	IF v_comproboingreso IS NULL THEN
		LET v_comproboingreso = 0;
	END IF

    -- ************************************
    -- Inicia Proceso de Calculo de Linea *
    -- ************************************

    IF v_ingreso < round(v_salariomin * v_diaspromedio,-2) THEN -- Moha
        LET v_ingreso = round(v_salariomin * v_diaspromedio,-2);
		
		IF cBRM_reing = 0 AND iOneClickPP = 0 THEN
			UPDATE bdisolic:"informix".ss_resum_scor_fin
			SET salario_minimo = v_ingreso
			WHERE empresa = o_empresa AND num_solicitud = o_numsol;
		END IF;
    END IF;

--******* COMPROMISOS BANCO INI


-- CREDITOS REVOLVENTES

	LET cNumcredito = "";

    FOREACH
	   SELECT num_credito
		 INTO cNumcredito
		 FROM bdicred:"informix".sd_maecred
		WHERE empresa = o_empresa
		  AND numcte = cNumCte
		  AND status_cred NOT IN ("FF","FM","FR","FE","CC","FC","CV")

	   SELECT NVL(a.sdo_cap_insoluto,0)
		 INTO v_comprobancoTDC
		 FROM bdicred:"informix".sd_maesdos a
		WHERE a.empresa     = o_empresa
		  AND a.num_credito = cNumcredito;
		  
	   IF v_comprobancoTDC IS NULL or v_comprobancoTDC <= 0 THEN
		   LET v_comprobancoTDC = 0;
	   ELSE
		   IF Round(v_comprobancoTDC,-1) - v_comprobancoTDC < 0 THEN
				LET v_comprobancoTDC = Round(v_comprobancoTDC,-1) + 10;
		   ELSE
			    LET v_comprobancoTDC = Round(v_comprobancoTDC,-1);
			END IF;
	   END IF;
	   
	   LET v_comprobanco = round((v_comprobanco + v_comprobancoTDC) * v_compromi_tdc ,-1);


    END FOREACH;
	LET v_comprobancoTDC = v_comprobanco;	
-- CREDITOS A PLAZO
    FOREACH
	   SELECT num_credito,num_producto
		 INTO cNumcredito,cProducto2
		 FROM bdicred:"informix".sd_maecredcrd
		WHERE empresa = o_empresa
		  AND numcte = cNumCte
		  AND status_cred NOT IN ("FF","FM","FR","FE","CC","FC","CV")


	   SELECT NVL(a.capital_mto_cuota,0)
		 INTO v_comprobancoprestamo
		 FROM bdicred:"informix".sd_amortiza_creditocrd a
		WHERE a.empresa     = o_empresa
		  AND a.num_credito = cNumcredito
		  AND a.num_pago = 1;

	   IF v_comprobancoprestamo IS NULL THEN
		   LET v_comprobancoprestamo = 0;
	   END IF;

	   LET v_comprobanco = v_comprobanco + v_comprobancoprestamo;
	   IF cProducto2  = '6400' THEN--JMAH RQM 09 366-2
			LET v_comprobancoCRNOM = v_comprobancoCRNOM + v_comprobancoprestamo;
	   ELSE
			LET v_comprobancoPP = v_comprobancoPP + v_comprobancoprestamo;
	   END IF;
    END FOREACH;

-- GRABAR COMPROMISOS BANCO
	
	IF v_comprobanco IS NULL  THEN
        LET v_comprobanco=0;
    END IF;
	IF cBRM_reing = 0 AND iOneClickPP = 0 THEN
		UPDATE bdisolic:"informix".ss_resum_scor_fin set compromisos_bco = v_comprobanco where empresa = o_empresa and num_solicitud = o_numsol;
	END IF;

--******* COMPROMISOS BANCO FIN



--  TOPDE DE INGRESO EXCEPTO CREDINOMINA INI

	IF cProducto = '9300' THEN -- RQM 09632

		SELECT elemento
		INTO cElemento
		FROM bdisolic:"informix".ss_detalle_scoring
		WHERE empresa = '001'
		AND seccion = '2'
		AND grupo = '38'
		AND tpo_persona = '01' 
		AND num_solicitud = o_numsol;

		IF NVL(cElemento,0) <> 1 THEN
			LET cTope = 'N';
		END IF;
		
		IF cCompIngresos = 'N' AND cRevisionMC = '1' THEN
			LET cTope = 'S';
		END IF;

		LET v_tope_ingreso = v_tope_ingre;

	ELSE
	LET v_tope_ingreso = round(v_salariomin * v_diaspromedio * v_tope_ingre,-2);
--	LET v_tope_ingreso = round(v_diaspromedio * v_salariomin,-2);
--    LET v_tope_ingreso = round(v_tope_ingreso * v_tope_ingre,-2);
	END IF;
	
	-- ELIMIAR TOPE INGRESO RQM 09 180 INI

	
    IF cProducto IN ("6001") THEN
		EXECUTE PROCEDURE bdisolic:"informix".sp_valida_comprobante(o_empresa, cNumCte, o_numsol) 
		INTO scod_ret, cMensaje_ret, cValido;
		
		IF cValido = 1 THEN
			let cTope = 'N';
		END IF;
    END IF;
	
	IF cStatus IN ("MC","LC") and cCompIngresos = 'S' THEN
		IF dIngresoCac < v_tope_ingreso THEN			
			--LET cCompIngresos = "N"; Respetar el ingreso que declara Mesa de Control cuando sea menor del tope
			LET  v_ingreso = dIngresoCac;				
		ELSE
			LET  v_ingreso = dIngresoCac;		
		END IF;
	END IF;
	-- ELIMINAR TOPE INGRESO RQM 09 180 FIN
	
	--IF ( v_ingreso > v_tope_ingreso and cProducto <> "6400" and cTope = 'S') or ( cStatus = 'LC' and cCompIngresos = 'N') then
	IF ( v_ingreso > v_tope_ingreso and cProducto NOT IN ("6400","8100") and cTope = 'S') or ( cStatus = 'LC' and cCompIngresos = 'N') then
		let v_ingreso = v_tope_ingreso;
	END IF;

	LET vlMontoHipoteca_ant =  NVL(vlMontoHipoteca,0);
  ----Se quitan el monto de hipoteca al ingreso.
  LET   v_ingreso = v_ingreso - NVL(vlMontoHipoteca,0);
  if v_compromisos > 0 then
	LET   v_compromisos_sic = v_compromisos;    
	LET   v_compromisos = v_compromisos -NVL(vlMontoHipoteca,0);
  end if;

  	-- RQM 09632 Se pone el tope minimo de ingreso
	IF (v_ingreso < v_tope_min AND cProducto = "9300") THEN
		let v_ingreso = v_tope_min;
	END IF;

--  TOPDE DE INGRESO EXCEPTO CREDINOMINA FIN	
	--01032022 RQM 10 679-2 Se cambia para que siempre se contemple para el producto 6001 independientemente del estatus la consulta para ver si es candidato a Oro
	IF NVL(cStatus,'') IN ('LC','MC') AND cCompIngresos = "S"  AND cProducto ='6001' THEN --solo se consultara esta seccion cuandos sea para revision de linea de credito cac con comprobante de ingreso valido.
		LET cTpSeccion = '8';
		LET cRevisionMC = '1';	
	ELSE 
		LET cTpSeccion = '2'; --seccion productiva
	END IF;	
	--01032022 RQM 10 679-2 Se cambia para que siempre se contemple para el producto 6001 independientemente del estatus la consulta para ver si es candidato a Oro
	--RQM 10 679 AAME 20160227 Se consulta el valor del flag_oro para ver si es candidato
	SELECT flag_oro
	 INTO vflagoro
	 FROM bdisolic:"informix".ss_solicitudes_tdcoro
	WHERE empresa = o_empresa
	  AND numero_solicitud = o_numsol;
		
		----RQM 10 679 AAME 20160227 Se obtiene la Seccion de Puntajes para determinacion de linea superiores para TDC Oro
	IF (NVL(vflagoro,0) =1 AND o_cte_nvo='') OR cProducto ='8100' THEN		
		LET cTpSeccion = '10';
		
		/*SELECT (c.valor) +  (c.valor * vlIVA), (c.valor)
		  INTO v_tasa, v_tasasiniva
		  FROM bdicred:sd_definicion a, 
			   bdinteg:si_fechavalor c
		 WHERE a.empresa = o_empresa
		   AND a.num_producto = '8100'
		   AND c.empresa = a.empresa
		   AND c.tasa = a.cod_tasa_base
		   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
				   WHERE r.empresa = o_empresa
					 AND r.tasa = a.cod_tasa_base);
		*/						--	RQM 10 1224					 
		
		EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(o_empresa, o_numsol, '8100') INTO cCodRetTDif, v_tasa, v_tasa_mora;
		IF cCodRetTDif <> '000000' OR v_tasa IS NULL THEN
			LET scod_ret = "453";
			RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
		END IF;

		LEt v_tasasiniva = v_tasa;
		LET v_tasa = (v_tasa) + (v_tasa * vlIVA);				--	RQM 10 1224

	END IF;
	
	LET iISM = v_ingreso / (v_salariomin * v_diaspromedio);

	--- Se obtienen la seccion para obtener los valores para calcular los limites inferiores y superiores para el producto 8500
	IF cProducto = '8500' THEN
		LET cTpSeccion = '12';
	END IF
	---Se obtiene secciÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ³n para el producto 6800 PrÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ©stamo Digital - RQM 09 578
	IF cProducto = '6800' THEN
		LET cTpSeccion = '13';
	END IF;
	---AAME Se agrega nueva secciÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ³n para el producto 9100 PrÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ©stamo Tu Moto - RQM 10 1427
	IF cProducto IN ('9100','9200') THEN
		LET cTpSeccion = '14';
	END IF;	
	---AAME Se agrega nueva secciÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ³n para el producto 9100 PrÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ©stamo Montos Mayores - RQM 10 1432
	IF cProducto  IN ('9300','9400') THEN
		LET cTpSeccion = '15';
	END IF;	
	---MACM se agrega nueva seccion para los productos de prestamos 12, 18 y 24
	IF cProducto = '6300' THEN
		LET cTpSeccion = '16';
	END IF;
	IF cProducto = '7600' THEN
		LET cTpSeccion = '17';
	END IF;
	IF cProducto = '7700' THEN
		LET cTpSeccion = '18';
	END IF;
	
	SELECT (sum(round(cant_smb_inf * v_salariomin * v_diaspromedio,-2))), --v_salariomin * v_diaspromedio
		   (sum(round(cant_smb_inf_hit * v_salariomin * v_diaspromedio,-2))),
		   (sum(round(cant_smb_sup * v_salariomin * v_diaspromedio,-2))),
		   (sum(round(cant_smb_sup_no_hit * v_salariomin * v_diaspromedio,-2))),
			sum(factor_flujo1),
			sum(factor_flujo2),
			min(min_flujo),
			max(max_flujo),
			sum(linea_teorica),
			sum(factorree),
			sum(linea_ree),
			(sum(round(max_limite_hit_con_inf_pd * v_salariomin * v_diaspromedio,-2))) --Tope max PrÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ©stamo Digital RQM 09 578
		 INTO v_limite_inferior, --- Valor NO HIT 
			  v_limite_inferior_hit, -- Valor HIT
			  v_topemax,
			  v_topemax_NO_HIT,
			  v_factor_flujo1,
			  v_factor_flujo2,
			  v_min_flujo,
			  v_max_flujo,
			  v_linea_teorica,
			  v_factorree,
			  v_linea_ree,
			  v_max_limite_hit_con_inf_pd  --Tope max PrÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½??ÃÂÃÂÃÂÃÂ¯ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ½?ÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ©stamo Digital RQM 09 578
		 FROM bdisolic:"informix".ss_scoring_solic
		WHERE empresa = o_empresa
		  AND tp_solicitud = cTpSolicitud
		  AND seccion = cTpSeccion --con seccion = 8 se realiza el calculo para lineas superiores
		  /*AND (min_porc_pago <= case when v_situacion = -1 then 0 else v_situacion end
		  AND max_porc_pago >= case when v_situacion = -1 then 0 else v_situacion end)
		  AND (min_mes_hist <= case when v_situacion = -1 then 0 else v_meseshist end
		  AND max_mes_hist >= case when v_situacion = -1 then 0 else v_meseshist end)*/
		  AND activa = '1'
      AND grupo = v_grupo; --- multiple 2013;
	  
	  --- Se agrega campo nuevo para ajustar lineas minimas para HIT
	  --- si es diferente de NO HIT asignale el nuevo campo HIT
	  IF v_evalua_cc <> 'X' THEN
		LET v_limite_inferior = v_limite_inferior_hit;
	  END IF;
	  
	
	IF (v_topemax IS NULL OR v_topemax = 0) and ( v_topemax_NO_HIT is null or v_topemax_NO_HIT = 0 )  THEN
		 LET scod_ret = "463";
		 RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;

	IF v_limite_inferior IS NULL  OR v_limite_inferior = 0 THEN
		 LET scod_ret = "466";
		 RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;
	
	let vcompromiso_rmp = v_abonomesprestamo + v_abonomesmuebles + v_abonomesropa;
	
	IF cProducto = '9300' THEN --RQM 09632 Se agrego validacion para asignar el valor de las sumas de los abonos al producto 9300.
		LET vcompromiso_coppel = vcompromiso_rmp;
	elif vcompromiso_rmp >= v_compteorico  then 
	  	let vcompromiso_coppel = vcompromiso_rmp; 
	else  let vcompromiso_coppel =v_compteorico;
	end if;
	
	
	
		SELECT evaluacion
			INTO v_valor_1s
		FROM  "informix".ss_resumen_scoring
		WHERE  num_solicitud = o_numsol
		AND seccion = 2;
		
	IF v_evalua_cc ='1' THEN
		LET v_evalua_cc = '0';
	END IF;
		--RQM 09 408 JMAH
	--RQM 09 613 Parametro flujo nuevo modelado de prestamos
	select count(*) into iNewMPP from bdisolic:"informix".ss_param_mpp where empresa = '001' and idSuc = cSucursal and produc = cProducto  ;
	IF iNewMPP > 0 THEN	
		--IF cProducto in('6300','6800','7600','7700') Then
		--bs_score
		SELECT sc01::INTEGER
		  INTO vScoreBC
		  FROM bdiburo:"informix".br_sc a
		 WHERE a.rowid = (SELECT MAX(b.rowid) FROM bdiburo:"informix".br_sc b WHERE institucion = 'BC' AND b.num_cliente= cNumCte AND sc00 <> "004")
		   AND institucion = 'BC'
		    AND num_cliente = cNumCte AND sc00 <> "004";  

		--Validar el tipo de hit a calificar.
		SELECT COUNT(TL06) INTO vCuentasPF FROM BDIBURO: "informix".BR_TL WHERE TL06 = 'I' AND NUM_CLIENTE = cNumCte;
		IF(v_evalua_cc = 'X' ) THEN 
			LET vIdModeloHit = 3;
			LET cSegmento = '3'; --'0' 
			LET vGrupoInfo = '3';	 -- 3 N/A
		ELIF(vCuentasPF > 3 AND v_evalua_cc = '0') THEN
			LET vIdModeloHit = 2;
			LET cSegmento = '2'; --'> 3'
			IF vScoreBC > 0 THEN
				LET vGrupoInfo = '1';	-- CON INFO
			ELSE 
				LET vGrupoInfo = '2';	-- SIN INFO
			END IF;
		ELIF(vCuentasPF >= 0 AND vCuentasPF <= 3 AND v_evalua_cc = '0') THEN
			LET vIdModeloHit = 1;
			LET cSegmento = '1';			IF vScoreBC > 0 THEN
				LET vGrupoInfo = '1'; -- CON INFO
			ELSE 
				LET vGrupoInfo = '2';			END IF;
		end if;
		
		IF cBRM_reing = 0 AND iOneClickPP = 0 THEN
			--Guarda tipo modelo para sacar segmento en reporte certificacion en linea
			update bdisolic:ss_solicitudes set tp_gen_planpago=cSegmento WHERE empresa = o_empresa AND num_solicitud =o_numsol;
		END IF;
		
		If cProducto IN ('6800','9300') Then -- RQM 09632 Para que se considere el producto 9300
			LET cTipo_producto = 'PD';
		ELIF cProducto IN ('6300','7600','7700') Then
			LET cTipo_producto = 'PP';
		END IF;

	ELSE
		LET vIdModeloHit = 0;
		LET cTipo_producto = ' ';
		LET vGrupoInfo= ' ';
	END IF;

	IF iOneClick > 0 THEN
	
	SELECT id_riesgo,porc_max_hipoteca,	porc_min_hipoteca,porc_sic,porc_max_otrosg,porc_min_otrosg
	INTO iIdRiesgo,dMaxPorcHipo,dMinPorcHipo,dPorSic,dMaxPorcOtros,dMinPorcOtros
	FROM "informix".ss_perfil_riesgo WHERE tp_solicitud = cTpSolicitud 
	AND id_riesgo = 3
	AND grupo = v_grupo 
	AND hit_buro = v_evalua_cc
	--AND v_valor_1s	between min_score AND max_score
	AND id_modelo = vIdModeloHit
	AND Tipo_producto = cTipo_producto
	AND grupo_info = vGrupoInfo;
	
	ELSE
    
	SELECT id_riesgo,porc_max_hipoteca,	porc_min_hipoteca,porc_sic,porc_max_otrosg,porc_min_otrosg
	INTO iIdRiesgo,dMaxPorcHipo,dMinPorcHipo,dPorSic,dMaxPorcOtros,dMinPorcOtros
	FROM "informix".ss_perfil_riesgo WHERE tp_solicitud = cTpSolicitud 
	AND grupo = v_grupo 
	AND hit_buro = v_evalua_cc
	AND v_valor_1s	between min_score AND max_score
	AND id_modelo = vIdModeloHit
	AND Tipo_producto = cTipo_producto
	AND grupo_info = vGrupoInfo;
	
	END IF;
	
		IF iISM > 2.5 THEN	--poner parametro en la ss_param
			IF vlMontoHipoteca = 0 AND cProducto <> '9300' THEN	--RQM 09632 Se agrego validacion para que no recalcule el monto hipoteca
				LET vlMontoHipoteca = v_ingreso * (dMinPorcHipo / 100) ;
				LET vlMontoHipoteca2 = v_ingreso * (dMinPorcHipo / 100);
				--LET   v_ingreso = v_ingreso - NVL(vlMontoHipoteca,0);
				LET dPorHipo = dMinPorcHipo;
				LET vlMontoHipoteca_ant = 0;
			END IF;				
			LET dOtrosComp = v_ingreso * (dMinPorcOtros  / 100) ;
		LET dPorOtros = dMinPorcOtros;
		ELSE
			IF vlMontoHipoteca = 0 AND cProducto <> '9300' THEN	--RQM 09632 Se agrego validacion para que no recalcule el monto hipoteca
				LET vlMontoHipoteca = v_ingreso * (dMaxPorcHipo / 100) ;
				LET vlMontoHipoteca2 = v_ingreso * (dMaxPorcHipo / 100) ;
				LET dPorHipo = dMaxPorcHipo;
				LET vlMontoHipoteca_ant = 0;
			END IF;		
		LET dOtrosComp = v_ingreso * (dMaxPorcOtros / 100) ;
		LET dPorOtros = dMaxPorcOtros;				
		END IF;
		
		---- Se crea compromiso coppel a solicitudes mixtas con porcentaje aplicado al ingreso RQM 09 530
		-- RQM 09632 Se agrego validacion para que no se apliquen los compromisos coppel al producto 9300.
		IF vcompromiso_coppel = 0 AND v_mixta_unica = 'M' AND cProducto <> '9300' THEN
			
			SELECT valor::INTEGER
				INTO v_porcentaje_compromiso
			FROM bdisolic:ss_param
			WHERE secuencia = 24;
			
			IF v_porcentaje_compromiso <> 0 OR v_porcentaje_compromiso IS NOT NULL THEN
			
				LET vcompromiso_coppel = v_ingreso * (v_porcentaje_compromiso/100);
				IF cBRM_reing = 0 AND iOneClickPP = 0 THEN
					UPDATE bdisolic:ss_revision_determinacion 
						SET compromiso_coppel_simulado =  'SI',
						porcentaje_compromiso =  v_porcentaje_compromiso||'% '
						WHERE num_solicitud = o_numsol;
				END IF;
			END IF;
			
		END IF;
		---- Se crea compromiso coppel a solicitudes mixtas con porcentaje aplicado al ingreso
		
		
		IF v_compromisos = 0 AND cProducto <> '9300' THEN --RQM 09632 Se agrego validacion para que no recalcule los compromisos si es un producto 9300	
			LET v_compromisos = v_ingreso * (dPorSic / 100) ;
		ELSE
			LET dPorSic =0;
		END IF;
		
	IF cProducto = '9300' THEN --RQM 09632 Se agrego el calculo de compromisos totales del producto 9300 -- Se elimina el vlMontoHipoteca_ant
		LET dCompromisosTotal =  ( NVL(v_compromisos,0) + NVL(vcompromiso_coppel,0) + NVL(v_comprobanco,0) + NVL(dOtrosComp,0));
	ELSE
		Let dCompromisosTotal = (v_compromisos + v_comprobanco + vcompromiso_coppel +dCompromisosCac+dOtrosComp+vlMontoHipoteca2);
	END IF;

	LET dCTA = Round(v_factor_flujo1 * v_ingreso );	
	LET v_flujo_libre1 = Round(v_factor_flujo1 * v_ingreso - (v_compromisos + v_comprobanco + vcompromiso_coppel +dCompromisosCac +dOtrosComp ),2);
	LET v_flujo_libre2 = round(v_factor_flujo2 * v_ingreso,2);
	
	IF cProducto = '9300' THEN --RQM 09632 Se agrego el calculo de capacidad real para el producto 9300
		LET v_capacidad = trunc (v_ingreso - (NVL(v_compromisos,0) + NVL(vcompromiso_coppel,0) + NVL(v_comprobanco,0) + NVL(dOtrosComp,0)),-2);
	ELSE
		LET v_capacidad = trunc (v_ingreso - (v_compromisos + v_comprobanco + vcompromiso_coppel +dCompromisosCac +dOtrosComp +vlMontoHipoteca2),-2);
	END IF;

	/*
	IF ( v_flujo_libre1 < v_min_flujo ) then
	   LET v_linea = 0;
	   LET scod_ret = "010"; -- capacidad de pago saturada
	   RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;
	*/
	
	IF cTpSolicitud = 'P' THEN--JMAH RQM 09 408-2

		SELECT NVL(plazo_min_cred,0),NVL(plazo_max_cred,0),monto_min_cred, monto_max_cred
			INTO iPlazoMin,iPlazoMax,dMto_min,dMto_max
		FROM bdicred:"informix".sd_definicion
		WHERE empresa = o_empresa
			AND num_producto = cProducto;
		-- RQM 09632 Se obtiene el plazo para calculo de determinacion de liÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ­nea
		IF (cProducto = '9300') THEN
			LET v_iplazomax = dPlazo;
		
			LET iPlazoMax = dPlazo * iFrecuencia;
		ELSE
			-- AAME RQM 10 1177 Se obtiene el plazo para calculo de determinacion de liÃÂÃÂÃÂÃÂ¿ÃÂÃÂÃÂÃÂ­nea
			LET v_iplazomax = iPlazoMax;
			
			LET iPlazoMax = iPlazoMax *iFrecuencia;
		END IF;
		
		--- RQM 09 530 Asigna creditos 18 y 24 con calculo de 12, validacion HIT y prende bandera para proyectar a 12
		---	Proceso que evalua con el minimo (v_limite_inferior) para determinar si le alcanza
		IF cBRM_reing = 0 AND iOneClickPP = 0 THEN 
			IF cProducto in ('7600','7700') AND v_evalua_cc = '0' THEN

				EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamo_aux(o_empresa,o_numsol,v_limite_inferior,0,cProducto,cSucursal,iPlazoMax,1)
					INTO Codret,flag_recalculopp12,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
					dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;	

					IF Codret <> "000000" THEN 
						LET scod_ret = Codret;
						RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
					END IF;	
					
			END IF;
			
			IF flag_recalculopp12 = 0 THEN 
				EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (v_limite_inferior,iPlazoMax,0,cProducto,cSucursal,0,0,o_numsol,"",NVL(iFrecuencia,1))
					INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
					dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
			END IF;
			
			IF Codret <> "000000" THEN 
				LET scod_ret = "474";
				RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
			END IF;	
		END IF;
		LET v_min_flujo =dPago_mensual;
	END IF;		
	
	IF (( v_capacidad < v_min_flujo ) OR dCRA < 0) AND cBRM_reing = 0 AND iOneClickPP = 0 THEN --
		LET v_linea = 0;
		LET scod_ret = "010"; -- capacidad de pago saturada
		LET dCRA = v_capacidad ;   
	ELSE
	
		IF cTpSolicitud = 'P' THEN--JMAH RQM 09 366-2
		----Monto Minimo y Maximo para Hit y No Hit

			IF cProducto = "6400"  THEN
			--LET v_limite_inferior = dMto_min;			
			LET v_topemax =dMto_max;		
			LET v_topemax_NO_HIT = dMto_max;				
			END IF;
			-- TOPE CREDINOMINA 4 meses INI
			IF dMto_max > v_ingreso * 7 AND cProducto = "6400" THEN
				LET dMto_max = v_ingreso * 7;
				LET v_topemax =dMto_max;	
				LET v_topemax_NO_HIT = dMto_max;				
			END IF;

			-- TOPE CREDINOMINA	4 meses FIN  
			
			--Tope max Prestamo Digital RQM 09 578
			IF cProducto = "6800"  THEN	
			LET v_topemax = v_max_limite_hit_con_inf_pd;				
			END IF;
			----------

			IF (iPlazoMin IS NULL OR iPlazoMax IS NULL) AND cBRM_reing = 0 AND iOneClick = 0 THEN
				LET scod_ret = "470";
				RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
			END IF;
			--se reemplaza ejecucion con formula del valor presente

			LET dCRA = v_capacidad ;				
			--				LET v_tasaMens = v_tasasiniva /12 ;	--JMAH RQM 09 366-2		
			--				LET v_factor_calc=POW(ROUND(((v_tasa/100)/v_plazo)+1,10),(iPlazoMin*-1));
			--				LET v_factor_calc = 1-(v_factor_calc);
			--				LET v_factor_vp = v_factor_calc / ((v_tasa/100)/v_plazo);
			--				LET v_linea =(v_capacidad * v_factor_calc) / ((v_tasa/100)/v_plazo);

			--END IF;
			--- RQM 09 530 Asigna creditos 18 y 24 con calculo de PP12 con evaluacion HIT
			IF cBRM_reing = 0 AND iOneClickPP = 0 THEN 
				IF flag_recalculopp12 = 1 THEN

					EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamo_aux(o_empresa,o_numsol,v_limite_inferior,v_capacidad,cProducto,cSucursal,iPlazoMax,2)
						INTO Codret,flag_recalculopp12,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
						dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;	

						IF Codret <> "000000" THEN
							LET scod_ret = Codret;
							RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
						END IF;	

				ELSE
				--- Se calcula la linea con base a la capacidad de pago, para corregir lineas que exedian su capacidad.			
					EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (0,iPlazoMax,v_capacidad,cProducto,cSucursal,0,0,o_numsol,"",NVL(iFrecuencia,1))
						INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
						dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;

					IF Codret <> "000000" THEN
						LET scod_ret = "474";
						RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
					END IF;		
				END IF;
			END IF;

			--RQM 09632 Prestamo Mas Bancoppel
			--valor es igual al plazo maximo del producto
			IF cProducto = '9300' THEN 
				LET v_iplazomax = v_iplazomax;

				LET dCRA = v_capacidad;				
				LET v_tasaMens = v_tasasiniva / 12;	
				--LET v_factor_calc = 1*(1-(1+(v_tasa/100/12))*- v_iplazomax)/(v_tasa/100/12);
				--LET v_factor_calc = 1-(v_factor_calc);
				LET v_factor_vp = 1*(1-(POW(ROUND(((v_tasa/100)/12)+1,10),(v_iplazomax*-1))))/(v_tasa/100/12);  --CONSERVAR EL CALCULO A 12 como Calculo Anual de tasa de interes
				--- nueva linea teorica
				LET v_lineasinTopes = (v_capacidad * v_factor_vp);
				LET v_linea = trunc ((v_capacidad * v_factor_vp),-3);
			ELSE
				--- nueva linea teorica
				LET v_lineasinTopes = dsdo_inicial;
				LET v_linea = trunc (dsdo_inicial,-3);
			END IF;
			
			IF cProducto <> "6400" THEN
				IF v_evalua_cc = 'X' THEN --Se agrega validacion para revision de lineas de credito
					IF v_linea >= v_topemax_NO_HIT THEN
						LET v_linea = v_topemax_NO_HIT;
					END IF		
				ELSE
					IF v_linea >= v_topemax THEN
						LET v_linea = v_topemax;
					END IF								
				END IF;
			ELSE
				IF v_linea >= v_topemax THEN
					LET v_linea = v_topemax;
				END IF;
			END IF;
			--fin cas RQM 09 172 Punto 4 Eliminar politica de comparacion de linea de credito Coppel
			IF v_linea < v_limite_inferior THEN
				
				-- RQM 09632 Si la linea es menor al limite inferior se Cane
				IF(cProducto = '9300') THEN
					IF cBRM_reing = 0 THEN
						EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, 'RT', 'CPS', 'Rechazo por capacidad de pago saturada')
						INTO scod_ret;
						RETURN TRIM(scod_ret),0,0,NVL(iPlazoMax,0);
					END IF;
				ELSE
					LET v_linea = trunc(v_limite_inferior,-3);
				END IF;
			END IF;
			IF cBRM_reing = 0 AND iOneClickPP = 0 THEN
				--se actualizan los valores con los que se calcula la Linea de credito RQM 09-279-2 --JMAH
				UPDATE bdisolic:"informix".ss_resum_scor_fin
					SET ingreso_lc = v_ingreso,
					valor_cma = v_flujo_libre1,
					valor_tab = v_flujo_libre2,
					linea_teorica = v_lineasinTopes
					WHERE empresa = o_empresa AND num_solicitud = o_numsol;
				--RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
			END IF;

		ELSE
			---Se cambia el sentido ya que el flujo maximo se cambia para dar lineas minimas
			
			--AAME RQM 10 1177 Condicion para asignar valor a v_plazomax Prestamos normales con valor a 12
			
				
			IF cProducto in ('9100','9200','9400') THEN
				LET v_iplazomax = v_iplazomax;
				--Prestamos nuevos Montos Mayores y Prestamos Motos
				--valor es igual al plazo maximo del producto -- Pendiente confirmar si seria el plazo maximo
			ELSE
				LET v_iplazomax = v_plazo;
			END IF;

			LET dCRA = v_capacidad ;				LET v_tasaMens = v_tasasiniva / 12 ;	--JMAH RQM 09 366-2
			LET v_factor_calc=POW(ROUND(((v_tasa/100)/v_plazo)+1,10),(v_iplazomax*-1));  -- CAMBIAR por el plazo que le corresponde al producto  (v_plazo*-1)
			LET v_factor_calc = 1-(v_factor_calc);
			LET v_factor_vp = v_factor_calc / ((v_tasa/100)/v_plazo);  --CONSERVAR EL CALCULO A 12 como Calculo Anual de tasa de interes	
			LET v_linea =(v_capacidad * v_factor_calc) / ((v_tasa/100)/v_plazo); --CONSERVAR EL CALCULO A 12 como Calculo Anual de tasa de interes	
			LET v_lineasinTopes = v_linea;
			--END IF;

			LET v_tasaMens = v_tasasiniva / v_plazo ;	--CONSERVAR EL CALCULO A 12 como Calculo Anual de tasa de interes	

			IF v_evalua_cc = 'X' THEN --Se agrega validacion para revision de lineas de credito
				IF v_linea >= v_topemax_NO_HIT THEN
					LET v_linea = v_topemax_NO_HIT;
				END IF
			ELSE
				IF v_linea >= v_topemax THEN
					LET v_linea = v_topemax;
			END IF

		END IF;

		--fin cas RQM 09 172 Punto 4 Eliminar politica de comparacion de linea de credito Coppel
		IF v_linea < v_limite_inferior THEN
			LET v_linea = ROUND(v_limite_inferior,-2);
		END IF;

	END IF

	IF cProducto = "6600" THEN
		LET v_paso = NVL(v_linea,0)/NVL(v_salarios_max,0);
		IF NVL(v_paso,0) > nvl(v_salarios_max,0) THEN
			LET v_linea= nvl(v_salarios_max,0) * nvl(v_salariomin,0);
		END IF;
	END IF

		--Se descarta la actualizacion de los valores del calculo de la linea cuando se trate de una TDC Oro			
	IF NVL(vflagoro,0) =0 THEN
		IF cBRM_reing = 0 AND iOneClickPP = 0 THEN
			--se actualizan los valores con los que se calcula la Linea de credito RQM 09-279-2 --JMAH
			UPDATE bdisolic:"informix".ss_resum_scor_fin
			SET ingreso_lc = v_ingreso,
				valor_cma = v_flujo_libre1,
				valor_tab = v_flujo_libre2,
				linea_teorica = v_lineasinTopes
			WHERE empresa = o_empresa AND num_solicitud = o_numsol;
		END IF;
	END IF;
	
				
		--SE VALIDA SI EL CLIENTE CUANTA CON UN CREDITO DE REESTRUCTURA LIQUIDADO.

--		IF EXISTS (SELECT status_cred
--					FROM bdicred:"informix".sd_maecredcrd 
--					WHERE empresa = o_empresa
--					AND numcte = cNumCte
--					AND num_producto = '6011'
--					AND status_cred ="FF" ) THEN

		SELECT COUNT(*)
		INTO v_Cont6011
		FROM bdicred:"informix".sd_maecredcrd 
		WHERE empresa = o_empresa
		AND numcte = cNumCte
		AND num_producto = '6011'
		AND status_cred ="FF";
		
		IF v_Cont6011 > 0 THEN
		
			IF v_factorree IS NULL OR v_factorree = '' THEN
			   LET v_factorree = 0;
			END IF

			IF v_linea_ree IS NULL OR v_linea_ree = '' THEN
			   LET v_linea_ree = 0;
			END IF;    

			LET dLineaPorcentaje = v_linea * (v_factorree / 100);
			
			IF v_linea_ree > dLineaPorcentaje THEN
				LET v_linea = ROUND(v_linea_ree,-2);
			ELSE 
				LET v_linea = ROUND(dLineaPorcentaje,-2);
				
			END IF;		
			LET cBanderaRR = '1';
			LET v_lineaRR= v_linea;
			--LET v_Cont6011 = 0;

		END IF;		

		IF cBRM_reing = 0 AND iOneClickPP = 0 THEN
			update bdisolic:"informix".ss_solicitudes 
				set tasa_base_piso =  v_capacidad
			where num_solicitud = o_numsol 
			and empresa = o_empresa;    
		END IF;	  
	 
		 IF (cStatus <> 'LC' AND cBanderaRR  ='0') or (cStatus = 'LC' and cCompIngresos = 'N' and cBanderaRR  ='0') THEN  --a las Reestructuras no se le aplica incremento o decremento --  Se agrega validacion LC ITD-RQM 09 462
			 SELECT {+INDEX ("informix".ss_catalogo_riesgo)} porc_riesgoTDC, porc_riesgoPP
				INTO pporc_mod_linTDC,	 pporc_mod_linPP
			 FROM ss_catalogo_riesgo 
			 WHERE empresa = o_empresa AND id_riesgo = iIdRiesgo;
			
			 IF cTpSolicitud ='T' THEN
				LET pporc_mod_lin = pporc_mod_linTDC;
			 ELSE
				LET pporc_mod_lin = pporc_mod_linPP;
			 END IF
	 
			LET v_lineaAnt = v_linea;
				let  v_lineaMod =     v_linea * (pporc_mod_lin / 100);
				let  v_linea = Round((v_linea+ v_lineaMod),-2);
				 let  v_capacidadMod = v_capacidad * (pporc_mod_lin / 100);
				let  v_capacidad = Round((v_capacidad+ v_capacidadMod),-1);	
				
				IF pporc_mod_lin > 0 THEN 
					LET dPorcIncr = pporc_mod_lin;				
					LET dMontoIncr = v_lineaMod;
					IF dMontoIncr < 0 THEN LET dMontoIncr = dMontoIncr * -1;
					END IF;
					LET dMontoDecr = 0;
					LET dPorcDecr = 0;
				ELSE
					LET dPorcDecr = pporc_mod_lin * -1;
					LET dMontoDecr = v_lineaMod * -1;
					LET dPorcIncr = 0;		
					LET dMontoIncr = 0;
				END IF;
			
				IF v_linea < v_limite_inferior THEN
					LET v_linea = v_limite_inferior;
				END IF;
			
		 END IF;
		 
	END IF;	 
	
	IF  v_linea > v_topemax AND  cProducto = "6400" THEN
		LET  v_linea = v_topemax ;
	END IF 
	--JMAH RQM 09 366-2
	LET v_linea = ROUND(v_linea,-2);
	
	--MACM 
    IF cBRM_reing = 0 AND iOneClickPP = 0 THEN
		IF NVL(vflagoro,0) =1 AND o_cte_nvo='' THEN
			--RQM 10 679 AAME 20160227 Se almacenan los valores con los que se calcula la linea para TDC Oro
			UPDATE bdisolic:"informix".ss_solicitudes_tdcoro
			SET ingreso_lc = v_ingreso,
			valor_cma = v_flujo_libre1,
			valor_tab = v_flujo_libre2,
			linea_teorica = v_linea
			WHERE empresa = o_empresa AND numero_solicitud = o_numsol;
		ELSE 
			UPDATE  "informix".ss_revision_determinacion 
			SET ingreso_mensual = v_ingreso_ant,
				ingreso_mensual_lc		= v_ingreso,    
				pago_crnom				= v_comprobancoCRNOM, 
				pago_prest				= v_comprobancoPP, 
				pago_tdc				= v_comprobancoTDC, 
				compromiso_sic_lc       = v_compromisos,	        
				monto_coppel			= vcompromiso_coppel,		
				mto_pagos_bco			= v_comprobanco,		
				compromiso_mens        	= dCompromisosTotal,
				factor1         		= 0,
				factor2         		= 0,
				valor_cta            	= 0, 
				valor_cma            	= 0,
				valor_tab            	= 0,
				valor_rab            	= dCRA,
				valor_pres            	= v_factor_vp, 
				tasa     	    		= v_tasasiniva ,
				tasa_iva        		= v_tasa,
				tasa_mens        		= v_tasaMens,
				cap_pag_min           	= v_min_flujo,
				tope_ingreso_tope		= v_tope_ingreso,
				linea_teorica        	= v_lineasinTopes,
				limiteInf				= v_limite_inferior,
				limiteSup				= CASE WHEN v_evalua_cc = 'X' THEN v_topemax_NO_HIT  ELSE v_topemax END ,
				linea_credito			= v_lineaAnt,
				porc_incre           	= dPorcIncr,
				porc_decre           	= dPorcDecr, 
				monto_incre           	= dMontoIncr, 
				monto_decre           	= dMontoDecr,  
				linea_final				= v_linea,
				bandera_rr		        = cBanderaRR,
				linea_rest				= v_lineaRR,
				bandera_mc		      	= cRevisionMC,	
				porc_hipo	         	= dPorHipo,
				porc_buro           	= dPorSic,
				porc_otros          	= dPorOtros,
				perfil_riesgo           = iIdRiesgo,
				ingreso_sm 				= iISM,
				monto_hipoteca          = vlMontoHipoteca_ant,
				monto_hipoteca_lc       = vlMontoHipoteca ,
				otros_gastos        	= dOtrosComp,
				score_prop          	= v_valor_1s,
				comprob_ing_val_mc  	= cCompIngresos,
				monto_reportado_mc  	= dIngresoCac,
				salario_minimo      	= v_salariomin,
				linea_min_prod      	= dlinea_min_prod, 
				suma_gastos         	= (vcompromiso_coppel + v_comprobanco)						
			WHERE  empresa  = o_empresa
				AND num_solicitud = o_numsol;
		END IF;
		
   ELSE 
  
		UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_pp 
		SET mAbonoMuebles_ss = v_abonomesmuebles, mAbonoPrestamos_ss = v_abonomesprestamo, mAbonoRopa_ss = v_abonomesropa, dTasa_ss = v_tasa, cCompIngresos_ss = cCompIngresos , dIngresoCac_ss = dIngresoCac, 
		dCompromisosCac_ss = dCompromisosCac, sFlag_oro_ss = vflagoro, dCompromisos_ss = v_compromisos, mCompro_banco_ss = v_comprobanco, dComprobanco_TDC_ss = v_comprobancoTDC, mCompro_bancoPP_ss = v_comprobancoPP, 
		iCtas_StatusFF_6011_ss = v_Cont6011, dSalariomin_ss = v_salariomin, dTasa_Ordinaria_ss = v_tasa, dTasa_Moratoria_ss = v_tasa_mora, diva_ss = vlIVA, dDiaspromedio_ss = v_diaspromedio, dTope_ingre_ss = v_tope_ingre, 
		dMesespermitido_ss =  v_mesespermitido, dMinimomesespermitido_ss = v_minimomesespermitido , cSituacionEspecial_ss = cSituacionEspecial, sCausaSituacion_ss = sCausaSituacion, dEficienciaCoppel_ss = dEficienciaCoppel, 
		sHist_meses_ss = sHist_meses, mAbonoAire_ss = mAbonoAire, mAbonoAfiliados_ss = mAbonoAfiliados, mAbonoReestructura_ss = mAbonoReestructura, mVencidoMuebles_ss = mVencidoMuebles, mVencidoRopa_ss = mVencidoRopa,
		mVencidoAire_ss = mVencidoAire, mVencidoReestructura_ss = mVencidoReestructura, cOrigenSol_ss = cOrigenSol, cTipoGrupo_ss = ptipogrupo , mVencidoPrestamos_ss = mVencidoPrestamos,
		dSituacionPagoCoppel_ss = v_situacion, mIngreso_Mensual_ss = mIngreso_Mensual, mLinea_tienda_ss = mLinea_tienda, mImporte_hip_ss = mImporte_hip, cHabita_en_ss = cHabita_en, cCod_Ult_Identif_ss = cCod_Ult_Identif, cCurp_ss = cCurp,
		dtUltimaCompra_ss = dtUltimaCompra, cOrigenCte_ss = cOrigenCte, sCompValido_ss = cValido, cTipo_movimiento_ss = v_mixta_unica, mIngreso_Neto_ss = mIngreso_Mensual, mSaldoRopa_ss = mSaldoRopa, mSaldoMuebles_ss = mSaldoMuebles, 
		mSaldoPrestamos_ss = mSaldoPrestamos, pMeses_historia_grupo_ss = pMeses_historia_grupo , pSituacion_pago_grupo_ss = pSituacion_pago_grupo, dPorcpermitido_ss = v_porcpermitido, pFrecuencia_ss = iFrecuencia, iDiaPago_ss = iDiaPago,
		cFechaUltimoPago_ss = cFechaUltimoPago,iReprestamos_ss = iReprestamos, cProfesion_ss = cProfesion
		WHERE cSolBanco_ss = o_numsol 
		AND cNumCteBco_ss = cNumCte ;
		
		UPDATE bdisolic:"informix".ss_certif_evaluacion_buro_pp 
		SET sBc_Score_ss = vScoreBC, BCScorePP_ss = vScoreBC, ScorePropietario_ss = v_valor_1s
		WHERE cSolBanco_ss = o_numsol 
		AND cNumCteBco_ss = cNumCte ;
		
  END IF;
	
	RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);

END
END PROCEDURE

