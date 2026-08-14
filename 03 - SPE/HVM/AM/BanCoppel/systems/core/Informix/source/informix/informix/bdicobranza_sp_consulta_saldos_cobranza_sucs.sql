CREATE PROCEDURE "informix".sp_consulta_saldos_cobranza_sucs(pEmpresa CHAR(3), pNumCuenta CHAR(20))
RETURNING   CHAR(6)     AS cod_ret,
			CHAR(21)	AS pago_minimo,
			CHAR(21)	AS saldo_total,
			CHAR(21)	AS pago_vencido1,
			CHAR(21)	AS pago_vencido2,
			CHAR(21)	AS pago_vencido3,
			CHAR(21)	AS pago_vencido4;
			
DEFINE cCodRet              CHAR(6);
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cNumProducto         CHAR (4);
DEFINE dpago_vencido1   	DECIMAL(18,2);
DEFINE dpago_vencido2   	DECIMAL(18,2);
DEFINE dpago_vencido3   	DECIMAL(18,2);
DEFINE dpago_vencido4   	DECIMAL(18,2);
DEFINE cMensajeRetornoCSG	CHAR(80);
DEFINE cNumeroCreditoCSG	CHAR(20);
DEFINE cCodigoTipcredCSG	CHAR(2);
DEFINE dFechaOrigenCSG		DATE;
DEFINE dFechaProxPagoCSG	DATE;
DEFINE dPagoMinimoCSG		DECIMAL(18,2);
DEFINE dFechaUltPagoCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagosRealizadosCSG	INTEGER;
DEFINE dLineaOtorgadaCSG	DECIMAL(18,2);
DEFINE dTasaInteresCSG		DECIMAL(9,6);
DEFINE dTasaMoratoriosCSG	DECIMAL(9,6);
DEFINE dMontoSbcCSG			DECIMAL(14,2);
DEFINE dCapVigCSG			DECIMAL(18,2);
DEFINE dCapTransCSG			DECIMAL(18,2);
DEFINE dCapVdoExigCSG		DECIMAL(18,2);
DEFINE dCapVdoNoExigCSG		DECIMAL(18,2);
DEFINE dSdoActTotalCapCSG	DECIMAL(18,2);
DEFINE dIntVigCSG			DECIMAL(18,2);
DEFINE dIntVdoCSG			DECIMAL(18,2);
DEFINE dIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIntMesCSG			DECIMAL(18,2);
DEFINE dSdoActTotalIntCSG	DECIMAL(18,2);
DEFINE dIvaIntVigCSG		DECIMAL(18,2);
DEFINE dIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dIvaIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIvaIntMesCSG		DECIMAL(18,2);
DEFINE dSdoActTotalIvaCSG	DECIMAL(18,2);
DEFINE dComPendCSG			DECIMAL(18,2);
DEFINE dIvaComCSG			DECIMAL(18,2);
DEFINE dSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dTotalLiquidacionCSG	DECIMAL(18,2);
DEFINE dIntDevengadoCSG		DECIMAL(18,2);
DEFINE dIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dLineaDisponibleCSG	DECIMAL(18,2);
DEFINE dPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqueoCtaCSG		CHAR(60); 
DEFINE cIdCausaBloqueoCSG	CHAR(3);
DEFINE cCausaBloqueoCtaCSG	CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG		CHAR(75);


-----------------------------------------------------------

-- InicializaciÃÂ³n de variables
LET cCodRet                 = "000000";
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET error_info              = "";
LET cNumProducto 			= '';
LET dpago_vencido1 			= 0;
LET dpago_vencido2 			= 0;
LET dpago_vencido3 			= 0;
LET dpago_vencido4 			= 0;
LET cMensajeRetornoCSG      = 'PROCESO EXITOSO';
LET cNumeroCreditoCSG		= '';
LET cCodigoTipcredCSG		= '';
LET dFechaOrigenCSG			= '';
LET dFechaProxPagoCSG		= '';
LET dPagoMinimoCSG			= 0	;
LET dFechaUltPagoCSG		= '';
LET iPlazoCSG				= 0;
LET iPagosRealizadosCSG		= 0;
LET dLineaOtorgadaCSG		= 0;
LET dTasaInteresCSG			= 0;
LET dTasaMoratoriosCSG		= 0;
LET dMontoSbcCSG			= 0;
LET dCapVigCSG				= 0;
LET dCapTransCSG			= 0;
LET dCapVdoExigCSG			= 0;
LET dCapVdoNoExigCSG		= 0;
LET dSdoActTotalCapCSG		= 0;
LET dIntVigCSG				= 0;
LET dIntVdoCSG				= 0;
LET dIntMoratoriosCSG		= 0;
LET dIntMesCSG				= 0;
LET dSdoActTotalIntCSG		= 0;
LET dIvaIntVigCSG			= 0;
LET dIvaIntVdoCSG			= 0;
LET dIvaIntMoratoriosCSG	= 0;
LET dIvaIntMesCSG			= 0;
LET dSdoActTotalIvaCSG		= 0;
LET dComPendCSG				= 0;
LET dIvaComCSG				= 0;
LET dSdoRetenidoCSG			= 0;
LET dTotalLiquidacionCSG	= 0;
LET dIntDevengadoCSG		= 0;
LET dIvaIntDevengadoCSG		= 0;
LET dLineaDisponibleCSG		= 0;
LET dPagosVdosCSG			= 0;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqueoCtaCSG			= '';
LET cIdCausaBloqueoCSG		= '';
LET cCausaBloqueoCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0	;
LET cSitEspCredCSG			= '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	BEGIN
	
		

		ON EXCEPTION SET iSqlErr, iIsamErr, error_info		
			  LET cCodRet = iSqlErr;			   
			  RETURN TRIM(NVL(cCodRet," ")), NVL(dPagoMinimoCSG, 0), NVL(dTotalLiquidacionCSG, 0), NVL(dpago_vencido1, 0),
				    NVL(dpago_vencido2, 0), NVL(dpago_vencido3, 0), NVL(dpago_vencido4, 0);
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/home/sysifx/respaldosbd/Adrian/587/sp_consulta_saldos_cobranza_sucs.out'; 
		--TRACE ON;

		IF pEmpresa <> "" AND pNumCuenta <> "" THEN
		
			EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa, pNumCuenta)
			INTO cCodRet, cMensajeRetornoCSG, cNumeroCreditoCSG, cCodigoTipcredCSG, dFechaOrigenCSG, dFechaProxPagoCSG,
			dPagoMinimoCSG, dFechaUltPagoCSG, iPlazoCSG, iPagosRealizadosCSG, dLineaOtorgadaCSG, dTasaInteresCSG, dTasaMoratoriosCSG,
			dMontoSbcCSG, dCapVigCSG, dCapTransCSG, dCapVdoExigCSG, dCapVdoNoExigCSG, dSdoActTotalCapCSG, dIntVigCSG, dIntVdoCSG, dIntMoratoriosCSG,
			dIntMesCSG, dSdoActTotalIntCSG, dIvaIntVigCSG, dIvaIntVdoCSG, dIvaIntMoratoriosCSG, dIvaIntMesCSG, dSdoActTotalIvaCSG, dComPendCSG,
			dIvaComCSG, dSdoRetenidoCSG, dTotalLiquidacionCSG, dIntDevengadoCSG, dIvaIntDevengadoCSG, dLineaDisponibleCSG, dPagosVdosCSG,
			cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqueoCtaCSG, cIdCausaBloqueoCSG, cCausaBloqueoCtaCSG, cIdSitEspCteCSG,
			iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;
					 
			IF cCodRet = "000000" THEN
				FOREACH		
					SELECT num_producto INTO cNumProducto
					FROM "informix".sd_maecred 
					WHERE empresa = pEmpresa AND num_credito = pNumCuenta
					UNION ALL
					SELECT num_producto				
					FROM "informix".sd_maecredcrd
					WHERE empresa = pEmpresa AND num_credito = pNumCuenta
				END FOREACH;
				
				IF cNumProducto IS NOT NULL THEN					
					IF(TRIM(NVL(cNumProducto,"")) IN ('6001','8100','8500')) THEN 
						 SELECT
						  (CASE WHEN saldovencido1 <> 0 
						  THEN saldovencido1  + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 + interesmoratorio4 + interesmoratorio5 + interesmoratorio6 + sdo_intereses
						  ELSE 0 END) AS CUADRO1,
						  (CASE WHEN saldovencido2 <> 0 THEN saldovencido2 + saldovencido1 + interesmoratorio1 + interesmoratorio2 +
						interesmoratorio3 + interesmoratorio4 + interesmoratorio5 + interesmoratorio6 +
						sdo_intereses ELSE 0 END) AS CUADRO2,
						(CASE WHEN saldovencido3 <> 0 THEN saldovencido3 + saldovencido2 + saldovencido1 + interesmoratorio1 +
						interesmoratorio2 + interesmoratorio3 + interesmoratorio4 + interesmoratorio5 +
						interesmoratorio6 + sdo_intereses ELSE 0 END) AS CUADRO3,
						(CASE WHEN saldovencido4 <> 0 THEN saldovencido6 + saldovencido5 + saldovencido4 + saldovencido3 + saldovencido2 +
						saldovencido1 + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 +
						interesmoratorio4 + interesmoratorio5 + interesmoratorio6 + sdo_intereses ELSE 0 END) AS CUADRO4
						INTO dpago_vencido1,dpago_vencido2,dpago_vencido3,dpago_vencido4
						FROM "informix".sd_sdos_cartera_linea 
						WHERE num_credito = pNumCuenta;
					 
					ELIF (TRIM(NVL(cNumProducto,"")) IN ('6300','6800','7600','7700')) THEN 

						SELECT 
						  (CASE WHEN saldovencido1 <> 0 THEN saldovencido1 + interesmoratorio1	ELSE 0 END) AS CUADRO1,
						  (CASE WHEN saldovencido2 <> 0 THEN saldovencido2 + saldovencido1 + interesmoratorio1 + interesmoratorio2 ELSE 0 END) AS CUADRO2,
						  (CASE WHEN saldovencido3 <> 0 THEN saldovencido3 + saldovencido2 + saldovencido1 + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 ELSE 0 END) AS CUADRO3,
						  (CASE WHEN saldovencido4 <> 0 THEN saldovencido6 + saldovencido5 + saldovencido4 + saldovencido3 + saldovencido2 + 
						  saldovencido1 + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 + interesmoratorio4 + interesmoratorio5 + interesmoratorio6 ELSE 0 END) AS CUADRO4
						  INTO dpago_vencido1,dpago_vencido2,dpago_vencido3,dpago_vencido4
						  FROM "informix".sd_sdos_cartera_linea 
						  WHERE num_credito = pNumCuenta;
								
					ELIF (TRIM(NVL(cNumProducto,"")) = '6011') THEN

						SELECT 
						(CASE WHEN saldovencido1 <> 0 THEN saldovencido1 ELSE 0 END) AS CUADRO1,
						(CASE WHEN saldovencido2 <> 0 THEN saldovencido2 + saldovencido1 ELSE 0 END) AS CUADRO2,
						(CASE WHEN saldovencido3 <> 0 THEN saldovencido3 + saldovencido2 + saldovencido1 ELSE 0 END) AS CUADRO3,
						(CASE WHEN saldovencido4 <> 0 THEN saldovencido6 + saldovencido5 + saldovencido4 + saldovencido3 + saldovencido2 + saldovencido1 ELSE 0 END) AS CUADRO4
						INTO dpago_vencido1,dpago_vencido2,dpago_vencido3,dpago_vencido4
						FROM "informix".sd_sdos_cartera_linea 
						WHERE num_credito = pNumCuenta;
							
					END IF;
				ELSE
					LET cCodRet = "000001";
				END IF;
			END IF;
		ELSE
			LET cCodRet = "000002";			
		END IF;
		
        IF dPagoMinimoCSG = 0 AND dTotalLiquidacionCSG = 0 THEN
		   LET dpago_vencido1 = 0;
		   LET dpago_vencido2 = 0;
		   LET dpago_vencido3 = 0;
		   LET dpago_vencido4 = 0;
		END IF;
		RETURN TRIM(NVL(cCodRet," ")), NVL(dPagoMinimoCSG, 0), NVL(dTotalLiquidacionCSG, 0), NVL(dpago_vencido1, 0),
				    NVL(dpago_vencido2, 0), NVL(dpago_vencido3, 0), NVL(dpago_vencido4, 0);
	END; 

END PROCEDURE
DOCUMENT
'Folio: 587',
'Autor:95572217 Omar Lerma',
'Fecha:19/07/2019',
'DESCRIPCION: Procedimineto que consulta el saldo vencido que presenta el cliente',
'Solicita: PEDRO RICARDO SANCHEZ SANCHEZ',
'BD: bdicred',
'Modifico: 97879606 Adrian Lizarraga',
'Fecha: 19/08/2019',
'DESCRIPCION: Se modifica la busqueda del producto con base al numero de credito',
'Solicita: PEDRO RICARDO SANCHEZ SANCHEZ',
'Folio: 587',
'BD: bdicred',
'Modifico: 90034397 Brando Garcia',
'Fecha: 14/04/2020',
'DESCRIPCION: Se agregan productos [6800,8100,8500] a la validaciÃ³n de saldo vencido.',
'Solicita: Marco Campos',
'Folio: 658',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_layout_in_triad_revolventes(pEjecucion integer)

RETURNING CHAR(6), char(80);
  -- vers: 1.0.4 20200618, 1.0.3 20190822, 1.0.2 20190409, 1.0.1 20180704, 1.0.0 20180302,  
  define vDataErr			varchar(64);
  define iSqlErr			integer;
  define iSamErr			integer;
  define cCodRet			char(6);
  define dtFecha			date;
  define vNomarchivo  char(70); 
  define cRuta        char(20);
  define cMensaje     char(80);
  define cCodRet2     char(5);
    
define vEmpresa               char(3);
define v_numcte_ref           char(20); 
define vSitesp                integer;
define vCuentaTels            integer;
define vCuentaEmails          integer;
define vMoraMaxHist           integer;
define vFechahoy              date;
define vFechahoy_temp         date;
define vPriDiaMes             date;
define vfecha_fin_mes_ant     date;
define vFechacorte            date;
define vFechacorteant         date;
define vFechacorte_23MesesAntes  date;
define v_evalua_cc            char(1);
define iIdUnidadProd          integer;
define vNumvencidos           integer;
define iContadorTarjetas      smallint;

--Variables para pago minimo
 define vPago_minimo      decimal(18,2);
 define vPago_minimo_2    decimal(18,2);
 define vIntVdo           decimal(18,2);
 define dIntMoratorio     decimal(18,2);
 define dIvaIntVdo        decimal(18,2);
 define dPagosVdos        decimal(18,2);
 define dIvaIntMoratorio  decimal(18,2);
 define dIntMes           decimal(18,2);
 define dIvaIntMes        decimal(18,2);
 define dIntVig           decimal(18,2);
 define dIvaIntVig        decimal(18,2);
 define dSdoRetenido      decimal(18,2);
 define dSdoActCap        decimal(18,2);
 define dMontoFinanciado  decimal(18,2);
 define cLineaDisponible  char(9);
 --define iLineaDisponible  integer;
 define iLineaDisponible  decimal(18,2);
 define cLineaDisponible_2 char(10);
 define vRetCs_acum       decimal(18,2); 
 --define cSucursal         char(4);
 --define dIvaSuc           decimal(5,3);
 define dIntVdo           decimal(18,2);
 
 --define dIntMoraIva	      decimal(18,2);
 --define dIntMoraProvi	    decimal(18,2);
 define cPagoMinimo       char(9);

 define dSdoTotalLiq      decimal(18,2);
 define dSdoTotalLiq_2    decimal(18,2);
 define cSdoTotalLiq      char(9);
 define cSaldo_total      char(9);
 define dIntsCobrados     decimal(18,2);
 define cIntsCobrados     char(9);
 define vCod_retorno      char(6);
 define vMsj_retorno      char(80);
 define vDiacorte         smallint;
 define cSuma             char(10);
 define dSuma             decimal(18,2);
 define dMontoPagos_CicloAct  decimal(18,2);
 define cSuma_2           char(10);
 define vMonto_pos        decimal(18,2);
 define vNum_pos          char(3);  
 define vNum_atm          char(3);
 define vMonto_atm        decimal(18,2);
 define cMonto_pos        char(9);  
 define cMonto_atm        char(9); 
 define cLimite_credito_ini char(9);
 define cSumaDevoluciones char(9);
 define dSumaDevoluciones decimal(18,2);
 define cDevolAclaracion  char(9);
 define dDevolAclaracion  decimal(18,2);
 define cNumpagos_dev     char(4);
 define iScoreProp        integer;
 define iScoreBc          integer;
 define iScoreBc_2        integer;
 define cScoreBc          char(3);   
 define cTipoProd         char(4);
 define dFechaIniMora     date; 
 define cCadena1          char(40);
 define iContGral         integer;
 define cScoreBehavior    char(4);
 define iScoreBehavior    integer;
 define cNumRegion        char(4);
   
 define vNumcuentas       integer;
 define vTipo_prod        CHAR(3);
 define vCuenta           char(20);
 define cSegmento         char(20);
 define iRandomNumber1    integer;
 define iRandomNumber2    integer;
 define iRandomNumber3    integer;
 define iRandomNumber4    integer;
 define cRandomNumber1    char(4);
 define cRandomNumber2    char(4);
 define cRandomNumber3   char(4);
 define cRandomNumber4    char(4);
 define fValor            float;
 define cValor            char(30);
 define cProceso          char(4);
 define cCod_ret_2        CHAR(6);
 define cContGral         char(10);
 define dSalto_total      decimal(14,2);
 define dSalto_total_2      decimal(14,2);
 define iMaxMorosidad     integer;
 define cMaxMorosidad     char(2);
 define iVecesMora1       integer;
 define cVecesMora1       char(3);
 define iVecesMora2       integer;
 define cVecesMora2       char(3);
 define iVecesMora3       integer;
 define cVecesMora3       char(3);
 define iVecesMora4       integer;
 define cVecesMora4       char(3);
 define dPago_minimo_AlCorte   decimal(14,2);
 define dPago_minimo_AlCorte_2 decimal(14,2); 
 define cPago_minimo_AlCorte   char(10);
 define dSumaMontos_1          decimal(14,2);
 define dSaldoVencido_AlCorte  decimal(14,2);
 define dSaldoVencido_AlCorte_2 decimal(14,2);
 define cSaldoVencido_AlCorte  char(10);
 define dLimiteCred_AlCorte    decimal(14,2);
 define dLimiteCred_AlCorte_2  decimal(14,2);
 define cLimiteCred_AlCorte    char(10);
 define dIntsCargados_AlCorte   decimal(14,2);
 define dIntsCargados_AlCorte_2 decimal(14,2);
 define cIntsCargados_AlCorte   char(10);
 define dFechacorte_12MsAntes   date; 
 define iContadorCiclos         integer;
 define iContadorCiclos_max     integer;
 define dFechaUltCorte_12       date;
 define dSdo_cap_insoluto       decimal(14,2);
 define iMorosidad_ciclo        integer;       -- es decimal en sd_maesdoshist.mto_fin_ven_trasp pero no deberÃ?Â?Ã?Â­a haber problema
 define dFechaant_enCiclo       date;
 define cCodBloqueoCta          char(4);
 define d_sdo_tot_liq_ciclos      decimal(18,2); 
 define d_sdo_tot_liq_ciclos_2    decimal(18,2);
 define c_sdo_tot_liq_ciclos      char(10);
 define c_sdo_tot_liq_ciclos_2    char(10);
 define d_pago_minimo_ciclos      decimal(18,2);
 define d_pago_minimo_ciclos_2    decimal(18,2);
 define c_pago_minimo_ciclos      char(10);
 define c_pago_minimo_ciclos_2    char(10);
 define i_num_pos_ciclos          integer;
 define c_num_pos_ciclos          char(3);
 define c_num_pos_ciclos_2        char(3);  
 define d_monto_pos_ciclos        decimal(18,2);
 define d_monto_pos_ciclos_2      decimal(18,2);
 define c_monto_pos_ciclos        char(10);
 define c_monto_pos_ciclos_2      char(10);
 define i_num_atm_ciclos          integer;
 define c_num_atm_ciclos          char(3);
 define c_num_atm_ciclos_2        char(3);
 define d_monto_atm_ciclos        decimal(18,2);
 define d_monto_atm_ciclos_2      decimal(18,2);
 define c_monto_atm_ciclos        char(10);
 define c_monto_atm_ciclos_2      char(10);
 define d_sdo_total_venc_ciclos   decimal(18,2);
 define d_sdo_total_venc_ciclos_2 decimal(18,2);
 define c_sdo_total_venc_ciclos   char(10);
 define c_sdo_total_venc_ciclos_2 char(10);
 define d_intereses_cobrados_ciclos   decimal(18,2);
 define d_intereses_cobrados_ciclos_2 decimal(18,2);
 define c_intereses_cobrados_ciclos   char(10);
 define c_intereses_cobrados_ciclos_2 char(10);
 define d_monto_comisiones_ciclos     decimal(18,2); 
 define d_monto_comisiones_ciclos_2   decimal(18,2);
 define c_monto_comisiones_ciclos     char(10);
 define c_monto_comisiones_ciclos_2   char(10);
 define d_monto_pagos_ciclos          decimal(18,2);
 define d_monto_pagos_ciclos_2        decimal(18,2);
 define c_monto_pagos_ciclos          char(10);
 define c_monto_pagos_ciclos_2        char(10);
 define d_monto_devoluciones_ciclos   decimal(18,2);
 define d_monto_devoluciones_ciclos_2  decimal(18,2);
 define c_monto_devoluciones_ciclos    char(10);
 define c_monto_devoluciones_ciclos_2  char(10);
 define dLimiteCred_ciclos          decimal(18,2);
 define dLimiteCred_ciclos_2        decimal(18,2);
 define cLimiteCred_ciclos          char(10);
 define cLimiteCred_ciclos_2        char(10);
 define cFechaUltCorte_12           char(8);
 define i_num_devoluciones_ciclos    integer;
 define c_num_devoluciones_ciclos    char(4);
 define c_num_devoluciones_ciclos_2  char(4);
 define dSdoMax_hist                 decimal(18,2);
 define cSdoMax_hist                 char(9);
 define cSdoMax_hist_2               char(9);
 define i_Contador_moro_24_max       integer;     
 define i_Contador_moro_24           integer;
 define i_Numvencidos_hist           integer;
 define cNumvencidos_hist            char(2); 
 define dDevolComprasNoReconoc       decimal(18,2);
 define cDevolComprasNoReconoc       char(9);  
 define cCampo_trab4                 char(10);
 define d_InteresesCargados          decimal(18,2);
 define d_Iva_IntsCargados           decimal(18,2);
 define d_Total_IntsCargados         decimal(18,2);
 define d_Total_IntsCargados_2       decimal(18,2);
 define c_Total_IntsCargados         char(9);
 define d_Monto_vnt                  decimal(18,2);
 define c_Monto_vnt                  char(9);
 define d_Montototal_dispoc          decimal(18,2);
 define c_Montototal_dispoc          char(9);
 define d_Otras_transacciones        decimal(18,2);
 define c_Otras_transacciones        char(9);
 define d_Otras_transacciones_2      decimal(18,2);
 define dMonto_otras_tnxs_tot  decimal(18,2);
 define d_Otras_transacciones_ciclos decimal(18,2);
 define d_Otras_transacciones_ciclos_2 decimal(18,2);
 define c_Otras_transacciones_ciclos   char(10);
 define c_Otras_transacciones_ciclos_2 char(10);
 define dMonto_vnt                   decimal(18,2);
 define d_Intereses_periodo          decimal(18,2);
 define d_Intereses_periodo_2        decimal(18,2);
 define c_Intereses_periodo          char(9);
 define dMontoDisp_efect             decimal(18,2); 
 define dMontoDisp_efect_2           decimal(18,2); 
 define cMontoDisp_efect             char(9); 
 define cNumDisp_efect               char(3);
 define vNum_vtn                     smallint;
 define v_cod_bloqueo_cta            integer;
 --define vTI_RV_DATE_CYCLE_CorteActual date; 
 
 define v_cod_bloqueo_cta_0          char(4);   
 define dSdoTotalLiq_0    decimal(18,2);
 define dSdoTotalLiq_2_0  decimal(18,2);
 define cSdoTotalLiq_0    char(9);
 define d_Montototal_dispoc_0         decimal(18,2);
 define d_Montototal_dispoc_2_0      decimal(18,2);
 define c_Montototal_dispoc_0          char(9);
 
 define cNumDisp_efect_0             char(3); 
 
 define dPago_minimo_AlCorte_0   decimal(14,2);
 define dPago_minimo_AlCorte_2_0 decimal(14,2); 
 define cPago_minimo_AlCorte_0   char(10);
 
 define dMontoPagos_CicloAct_0  decimal(18,2);
 define dMontoPagos_CicloAct_2_0  decimal(18,2);
 define cMontoPagos_CicloAct_0  char(10);
 
 define vMonto_atm_0        decimal(18,2);
 define vMonto_atm_2_0        decimal(18,2);
 define cMonto_atm_0        char(10);
 
 define vNum_atm_0          char(3);
 
 define vMonto_pos_0        decimal(18,2);
 define cMonto_pos_0        char(9); 
 define vNum_pos_0          char(3);   
 
 define dSaldoVencido_AlCorte_0  decimal(14,2);
 define dSaldoVencido_AlCorte_2_0 decimal(14,2);
 define cSaldoVencido_AlCorte_0  char(10);
 
 define dLimiteCred_AlCorte_0    decimal(14,2);
 define dLimiteCred_AlCorte_2_0  decimal(14,2);
 define cLimiteCred_AlCorte_0    char(10);
 
 define cSumaDevoluciones_0     char(9);
 define dSumaDevoluciones_0     decimal(18,2);
 
 define d_Otras_transacciones_0        decimal(18,2);
 define c_Otras_transacciones_0        char(9);
 define d_Otras_transacciones_2_0      decimal(18,2);
 
 define d_Intereses_periodo_0          decimal(18,2);
 define d_Intereses_periodo_2_0        decimal(18,2);
 define c_Intereses_periodo_0          char(9);
 
 define dMonto_comisiones_0            decimal(18,2);
 define cMonto_comisiones_0            char(9);
 
  
 define vExiste_promo_credito             smallint;
 define vNum_vencidos_ch                  smallint;   
 define vCount_maesdoshist                smallint;
 define vFecha_consulta                   date;
  
 define iExisteCuenta         integer;
 define cCredIni                  char(20);
 define cCredFin                  char(20); 
 define cCredIni_fin              char(20);
 define vFecha_proceso        date;
 define dtotalfees2           decimal(18,2); 
 define dsaldo_total          decimal(18,2); 
 
 define dSadototliq1, dSadototliq2, dSadototliq3, dSadototliq4, dSadototliq5, dSadototliq6, dSadototliq7, dSadototliq8, dSadototliq9 decimal(18,2);
 define dSadototliq10, dSadototliq11 decimal(18,2); 
 define cStatus_cred          char(2);
 define vFechaDiaAnt          date;
 define vFechaDiaAnt_temp          date;
 define iNum_pagos_periodo     integer;
 define d_monto_otorgado     decimal(18,2);
 define d_sdo_cap_insoluto   decimal(18,2);
 define d_sdo_retenido       decimal(18,2);
 define iDia_corte           INTEGER;  
 define vEmpresa_2         	 CHAR(3);
 define iIdUnidadProd_2      integer;
 define cCampo_trab4_2       CHAR(10);
 define d_monto_otorgado_2   decimal(18,2);
 define d_sdo_cap_insoluto_2 decimal(18,2);
 define d_sdo_retenido_2     decimal(18,2);
 
 --vCod_retorno  vMsj_retorno vPago_minimo vIntVdo dIntMoratorio dIvaIntVdo dPagosVdos dIvaIntMoratorio dIntMes dIvaIntMes dIntVig dIvaIntVig
--       dSdoRetenido dIntVig  dSdoActCap dMontoFinanciado cLineaDisponible
--dSdoTotalLiq cSdoTotalLiq


DEFINE vTI_CU_CUSTOMER_ID         char(20);
DEFINE vTI_RV_ACCOUNT_ID          char(20);

 define vTI_RV_DATE_OPEN            date;       
 define vTI_RV_DATE_CLOSED          date;       
 define vTI_RV_ACCOUNT_TYPE         char(1);    
 define vTI_RV_DATE_FIRST_ACTIVE    date;       
 define vTI_RV_DATE_LAST_MERCH      date;       
 define vTI_RV_DATE_LAST_PAY        date;       
 define vTI_RV_DATE_LAST_CASH_ADV   date;       
 define vTI_RV_DATE_START_DELQ      date;          
 define vTI_RV_CURR_BALANCE         decimal(18,2); 
 define vTI_RV_CURR_LIMIT           decimal(18,2); 
 define vTI_RV_CURR_CYCLES_DELQ     smallint;      
 define vOut_rv_cat                 char(2);       
 define vTI_RV_VAL_FEES_1           decimal(18,2); 
 define vTI_RV_VAL_FEES_2           decimal(18,2); 
 define vTI_RV_VAL_FEES_3           decimal(18,2); 
 define vTI_RV_VAL_FEES_4           decimal(18,2); 
 define vTI_RV_VAL_FEES_5           decimal(18,2); 
 define vTI_RV_CREDIT_INTEREST      decimal(18,2); 
 define vTI_RV_HI_BAL_LF            decimal(18,2); 
 define vTI_RV_HI_DELQ_LF           smallint;      
 define vTI_RV_NUM_1_CYC_LF         smallint;      
 define vTI_RV_NUM_2_CYC_LF         smallint;      
 define vTI_RV_NUM_3_CYC_LF         smallint;      
 define vTI_RV_NUM_4P_CYC_LF        smallint;      
 define vTI_RV_NO_CARDS             smallint;
 define vTI_RV_DATE_CYCLE_1          date; 
 define vTI_RV_DATE_CYCLE_CorteActual   date;          
 define vTI_RV_BLOCK_CODE_1         integer;       
 define vTI_RV_CYCLE_BALANCE_1      decimal(18,2);
 define vTI_RV_CASH_BALANCE_1       decimal(18,2);
 define vTI_RV_AMOUNT_DUE_1         decimal(18,2); 
 define vTI_RV_VAL_PAYMENTS_1       decimal(18,2); 
 define vTI_RV_VAL_MERCH_SALES_1    decimal(18,2); 
 define vTI_RV_NUM_MERCH_SALES_1    smallint;      
 define vTI_RV_VAL_CASH_ADV_1       decimal(18,2); 
 define vTI_RV_NUM_CASH_ADV_1       smallint;      
 define vTI_RV_VAL_ARREARS_1        decimal(18,2); 
 define vTI_RV_LIMIT_1              decimal(18,2); 
 define vTI_RV_VAL_RETURNS_1        decimal(18,2); 
 define vTI_RV_VAL_OTHER_TXNS_1     decimal(18,2); 
 define vTI_RV_VAL_INTEREST_1       decimal(18,2); 
 define vTI_RV_VAL_TOTAL_FEES_1     decimal(18,2); 
 define vTI_RV_VAL_OTHER_DEBITS_1   decimal(18,2);
 define vTI_RV_NO_NSF_1             smallint;

 define vTI_RV_CYCLES_DELQ_1        smallint;
 define vNumCredito_salida          char(20);
 
 define vTI_RV_DATE_FIRST_ACTIVE_2  date;
 define vTI_RV_DATE_LAST_PAY_2      date;
 define vTI_RV_DATE_LAST_CASH_ADV_2 date;       
 define vTI_RV_DATE_LAST_MERCH_2    date;
 define vOut_rv_cat_2               char(2);       
--INICIALIZACION DE VARIABLES--
	    
let vEmpresa      = '001';
let v_numcte_ref  = '';
let vSitesp       = 0;
let vCuentaTels   = 0;
let vCuentaEmails = 0;
let vMoraMaxHist  = 0;
let vFechahoy     = date(1);
let vFechahoy_temp     = date(1);
let vPriDiaMes    = date(1);
let vfecha_fin_mes_ant    = date(1);
let vFechacorte           = date(1);
let vFechacorteant        = date(1);
let vFechacorte_23MesesAntes = date(1); 
let v_evalua_cc           = '';
let iIdUnidadProd         = 0;	    
let vNumvencidos          = 0;
let iContadorTarjetas     = 0;
let dSdoTotalLiq          = 0;
let dSdoTotalLiq_2        = 0;
  
  let cCodRet				= "000000";
  let dtFecha				= '01-01-1900';
  --LET vNomarchivo   = 'Layout_in_triad.txt';
  let vNomarchivo   = 'Bcpl_Layout_in_Triad_Rev.txt';
  let cRuta         = '/informix/macf/';
  let cCodRet2      = '';

--Variables para pago minimo
 let vPago_minimo      = 0;
 let vPago_minimo_2    = 0;
 let vIntVdo           = 0;
 let dIntMoratorio     = 0;
 let dIvaIntVdo        = 0;
 let dPagosVdos        = 0;
 let dIvaIntMoratorio  = 0;
 let dIntMes           = 0;
 let dIvaIntMes        = 0;
 let dIntVig           = 0;
 let dIvaIntVig        = 0;
 let dSdoRetenido      = 0;
 let dSdoActCap        = 0;
 let dMontoFinanciado  = 0;
 let cLineaDisponible  = '';
 let iLineaDisponible  = 0;
 let cLineaDisponible_2  = '';
 let vRetCs_acum       = 0; 
 let dIntVdo           = 0; 
 let cPagoMinimo         = '';
 let cSdoTotalLiq        = '';
 let dIntsCobrados       = 0;
 let cIntsCobrados       = ''; 
 let vCod_retorno        = '';
 let vMsj_retorno        = '';
 let vDiacorte           = 0;
 let cSuma               = ''; 
 let cSuma_2             = '';
 let vMonto_pos          = 0;
 let vNum_pos            = '';
 let vNum_atm            = '';
 let vMonto_atm          = 0;
 let cLimite_credito_ini = '';
 let cSumaDevoluciones   = '';
 let dSumaDevoluciones   = 0;
 let cNumpagos_dev       = '';
 let iScoreProp          = 0;
 let iScoreBc            = 0;
 let iScoreBc_2          = 0;
 let cScoreBc            = '';
 let cTipoProd           = '';
 let dFechaIniMora       = date(1);
 let cCadena1            = '';
 let iContGral           = 0;
 let cScoreBehavior      = '';
 let iScoreBehavior      = 0;
 let cNumRegion          = '';
 let cMensaje            = 'PROCESO CONCLUYE CORRECTAMENTE';
 let vNumcuentas         = 0;
 let vTipo_prod          = '';
 let vCuenta             = '';
 let cSegmento           = '';
 let iRandomNumber1      = 0;
 let iRandomNumber2      = 0;
 let iRandomNumber3      = 0;
 let iRandomNumber4      = 0;
 let cRandomNumber1      = '';
 let cRandomNumber2      = '';
 let cRandomNumber3     = '';
 let cRandomNumber4      = '';
 let fValor              = 0;
 let cValor              = '';
 let cProceso            = '0107';
 let cCod_ret_2          = ''; 
 let cContGral           = '';
 let dSalto_total        = 0;
 let iMaxMorosidad       = 0;
 let cMaxMorosidad       = ''; 
 let iVecesMora1         = 0; 
 let cVecesMora1         = '';
 let iVecesMora2         = 0;
 let cVecesMora2         = '';
 let iVecesMora3         = 0;
 let cVecesMora3          = '';
 let iVecesMora4         = 0;
 let cVecesMora4         = '';
 let dPago_minimo_AlCorte   = 0;
 let dPago_minimo_AlCorte_2 = 0;
 let cPago_minimo_AlCorte   = '';
 let dSumaMontos_1          = 0;
 let dSaldoVencido_AlCorte  = 0;
 let dSaldoVencido_AlCorte_2  = 0;
 let cSaldoVencido_AlCorte  = '';
 let dLimiteCred_AlCorte    = 0;
 let dLimiteCred_AlCorte_2  = 0;
 let cLimiteCred_AlCorte    = '';
 let dIntsCargados_AlCorte   = 0;
 let dIntsCargados_AlCorte_2 = 0; 
 let cIntsCargados_AlCorte   = ''; 
 let dFechacorte_12MsAntes   = date(1); 
 let iContadorCiclos         = 0; 
 let iContadorCiclos_max     = 0;
 let dFechaUltCorte_12       = date(1);
 let dSdo_cap_insoluto       = 0;
 let iMorosidad_ciclo        = 0;   -- es decimal en sd_maesdoshist.mto_fin_ven_trasp pero no deberÃ?Â?Ã?Â­a haber problema
 let dFechaant_enCiclo       = date(1);
 let cCodBloqueoCta          = '';
 let d_sdo_tot_liq_ciclos    = 0;
 let d_sdo_tot_liq_ciclos_2  = 0;
 let c_sdo_tot_liq_ciclos    = ''; 
 let c_sdo_tot_liq_ciclos_2  = '';
 let d_pago_minimo_ciclos    = 0;
 let d_pago_minimo_ciclos_2  = 0;
 let c_pago_minimo_ciclos    = '';
 let c_pago_minimo_ciclos_2  = '';
 let i_num_pos_ciclos        = 0;
 let c_num_pos_ciclos        = '';
 let c_num_pos_ciclos_2      = '';
 let d_monto_pos_ciclos      = 0;
 let d_monto_pos_ciclos_2    = 0;
 let c_monto_pos_ciclos      = '';
 let c_monto_pos_ciclos_2    = '';
 let i_num_atm_ciclos        = 0;
 let c_num_atm_ciclos        = '';
 let c_num_atm_ciclos_2      = '';
 let d_monto_atm_ciclos      = 0;
 let d_monto_atm_ciclos_2    = 0;
 let c_monto_atm_ciclos      = '';
 let c_monto_atm_ciclos_2    = '';
 let d_sdo_total_venc_ciclos = 0;
 let d_sdo_total_venc_ciclos_2 = 0; 
 let c_sdo_total_venc_ciclos   = '';
 let c_sdo_total_venc_ciclos_2 = '';
 let d_intereses_cobrados_ciclos = 0;
 let d_intereses_cobrados_ciclos_2 = 0; 
 let c_intereses_cobrados_ciclos = '';
 let c_intereses_cobrados_ciclos_2 = '';
 let d_monto_comisiones_ciclos   = 0; 
 let d_monto_comisiones_ciclos_2 = 0;
 let c_monto_comisiones_ciclos   = '';
 let c_monto_comisiones_ciclos_2 = '';
 let d_monto_pagos_ciclos         = 0;
 let d_monto_pagos_ciclos_2       = 0;
 let c_monto_pagos_ciclos         = '';
 let c_monto_pagos_ciclos_2       = '';
 let d_monto_devoluciones_ciclos  = 0;
 let d_monto_devoluciones_ciclos_2 = 0;
 let c_monto_devoluciones_ciclos   = '';
 let c_monto_devoluciones_ciclos_2 = '';
 let dLimiteCred_ciclos          = 0;
 let dLimiteCred_ciclos_2        = 0;
 let cLimiteCred_ciclos          = '';
 let cLimiteCred_ciclos_2        = '';
 let i_num_devoluciones_ciclos   = 0;
 let c_num_devoluciones_ciclos   = '';
 let c_num_devoluciones_ciclos_2 = '';
 let cFechaUltCorte_12           = '';
 let dSdoMax_hist                = 0;
 let cSdoMax_hist                = '';
 let cSdoMax_hist_2              = '';
 let i_Contador_moro_24_max      = 0;
 let i_Contador_moro_24          = 0;
 let i_Numvencidos_hist          = 0;
 let cNumvencidos_hist           = '';
 let dDevolComprasNoReconoc      = 0;
 let cDevolComprasNoReconoc      = '';
 let cDevolAclaracion            = '';
 let dDevolAclaracion            = 0;
 let cCampo_trab4                = '';
 let d_InteresesCargados         = 0;
 let d_Iva_IntsCargados          = 0;
 let d_Total_IntsCargados        = 0;
 let d_Total_IntsCargados_2      = 0;
 let c_Total_IntsCargados        = '';
 let dMonto_vnt                  = 0;
 let d_Monto_vnt                 = 0;
 let d_Montototal_dispoc         = 0;
 let c_Montototal_dispoc         = '';
 let d_Otras_transacciones       = 0;
 let c_Otras_transacciones       = '';
 let d_Otras_transacciones_2     = 0;
 let d_Otras_transacciones_ciclos =0;
 let d_Otras_transacciones_ciclos_2 =0;
 let c_Otras_transacciones_ciclos ='';
 let c_Otras_transacciones_ciclos_2 ='';
 --let vTI_RV_DATE_CYCLE_CorteActual = '00000000';
 let cSaldo_total                 = '';
 let d_Intereses_periodo          = 0;
 let d_Intereses_periodo_2        = 0;
 let dMontoPagos_CicloAct         = 0;
 let c_Intereses_periodo   = '';
 let vExiste_promo_credito          = 0;
 let vNum_vencidos_ch               = 0;
 let vCount_maesdoshist             = 0; 
 let vFecha_consulta                = date(1);
 
 let v_cod_bloqueo_cta = 0;
 let v_cod_bloqueo_cta_0 = '';
 let dSdoTotalLiq_0 = 0; let dSdoTotalLiq_2_0 = 0;  let d_Montototal_dispoc_0 = 0; let d_Montototal_dispoc_2_0 = 0; 
 let dPago_minimo_AlCorte_0 = 0; let dPago_minimo_AlCorte_2_0 = 0;  let dMontoPagos_CicloAct_0 = 0;  let dMontoPagos_CicloAct_2_0 = 0; 
 let vMonto_atm_0 = 0;  let vMonto_atm_2_0 = 0;  let vMonto_pos_0 = 0;  let dSaldoVencido_AlCorte_0 = 0;  let dSaldoVencido_AlCorte_2_0 = 0;
 let dLimiteCred_AlCorte_0 = 0; let dLimiteCred_AlCorte_2_0 = 0;  let dSumaDevoluciones_0 = 0;  let d_Otras_transacciones_0 = 0; 
 let d_Otras_transacciones_2_0 = 0;  let d_Intereses_periodo_0 = 0;  let d_Intereses_periodo_2_0 = 0;  let dMonto_comisiones_0 = 0; 
 
 let cSdoTotalLiq_0 = '';
 let c_Montototal_dispoc_0 = ''; 
 let cPago_minimo_AlCorte_0 = ''; 
 let cMontoPagos_CicloAct_0 = ''; 
 let vMonto_atm_0        = ''; 
 let vNum_atm_0          = ''; 
 let cMonto_pos_0        = ''; 
 let vNum_pos_0          = ''; 
 let cSaldoVencido_AlCorte_0 = ''; 
 let cLimiteCred_AlCorte_0   = ''; 
 let cSumaDevoluciones_0     = ''; 
 let c_Otras_transacciones_0 = ''; 
 let c_Intereses_periodo_0   = ''; 
 let cMonto_comisiones_0     = ''; 
 let iExisteCuenta           = 0;
 let cCredIni                  = '';
 let cCredFin                  = '';
 let cCredIni_fin              = '';
 let vFecha_proceso          = date(1);
 
 let dSadototliq1 = 0; let dSadototliq2 = 0; let dSadototliq3 = 0; let dSadototliq4 = 0; let dSadototliq5 = 0; let dSadototliq6 = 0; let dSadototliq7 = 0;
 let dSadototliq8 = 0; let dSadototliq9 = 0; let dSadototliq10 = 0; let dSadototliq11 = 0;  
 
 let dSuma                 = 0;
 let dMonto_otras_tnxs_tot = 0;
 let dtotalfees2          = 0;
 let dsaldo_total         = 0;
 let cStatus_cred         = '';
 let vFechaDiaAnt         = date(1);
 let vFechaDiaAnt_temp    = date(1);
 let iNum_pagos_periodo   = 0;
 let d_monto_otorgado     = 0;
 let d_sdo_cap_insoluto   = 0;
 let d_sdo_retenido       = 0;
 let vNumCredito_salida   = '';
 let iDia_corte           = 0;
 let vEmpresa_2           = '';
 let iIdUnidadProd_2      = 0;
 let cCampo_trab4_2       = '';
 let d_sdo_cap_insoluto_2 = 0;
 let d_sdo_retenido_2     = 0;
 let vOut_rv_cat_2        = '';
 
 LET vTI_CU_CUSTOMER_ID = ''; --20 ya en la descarga se darÃ?Â?Ã?Â¡ el formato
 LET vTI_RV_ACCOUNT_ID  = ''; --20 

 let vTI_RV_DATE_OPEN            = date(1);       
 let vTI_RV_DATE_CLOSED          = date(1);       
 let vTI_RV_ACCOUNT_TYPE         = '';    
 let vTI_RV_DATE_FIRST_ACTIVE    = date(1);       
 let vTI_RV_DATE_LAST_MERCH      = date(1);       
 let vTI_RV_DATE_LAST_PAY        = date(1);       
 let vTI_RV_DATE_LAST_CASH_ADV   = date(1);       
 let vTI_RV_DATE_START_DELQ      = date(1);          
 let vTI_RV_CURR_BALANCE         = 0; 
 let vTI_RV_CURR_LIMIT           = 0;  
 let vTI_RV_CURR_CYCLES_DELQ     = 0;      
 let vOut_rv_cat                 = '';       
 let vTI_RV_VAL_FEES_1           = 0; 
 let vTI_RV_VAL_FEES_2           = 0; 
 let vTI_RV_VAL_FEES_3           = 0; 
 let vTI_RV_VAL_FEES_4           = 0; 
 let vTI_RV_VAL_FEES_5           = 0; 
 let vTI_RV_CREDIT_INTEREST      = 0; 
 let vTI_RV_HI_BAL_LF            = 0; 
 let vTI_RV_HI_DELQ_LF           = 0;      
 let vTI_RV_NUM_1_CYC_LF         = 0;      
 let vTI_RV_NUM_2_CYC_LF         = 0;      
 let vTI_RV_NUM_3_CYC_LF         = 0;      
 let vTI_RV_NUM_4P_CYC_LF        = 0;      
 let vTI_RV_NO_CARDS             = 0;
 let vTI_RV_DATE_CYCLE_1         = date(1);      
 let vTI_RV_DATE_CYCLE_CorteActual = date(1);          
 let vTI_RV_BLOCK_CODE_1         = 0;       
 let vTI_RV_CYCLE_BALANCE_1      = 0; 
 let vTI_RV_AMOUNT_DUE_1         = 0; 
 let vTI_RV_VAL_PAYMENTS_1       = 0; 
 let vTI_RV_VAL_MERCH_SALES_1    = 0; 
 let vTI_RV_NUM_MERCH_SALES_1    = 0;      
 let vTI_RV_VAL_CASH_ADV_1       = 0; 
 let vTI_RV_NUM_CASH_ADV_1       = 0;      
 let vTI_RV_VAL_ARREARS_1        = 0; 
 let vTI_RV_LIMIT_1              = 0; 
 let vTI_RV_VAL_RETURNS_1        = 0; 
 let vTI_RV_VAL_OTHER_TXNS_1     = 0; 
 let vTI_RV_VAL_INTEREST_1       = 0; 
 let vTI_RV_VAL_TOTAL_FEES_1     = 0; 
 let vTI_RV_VAL_OTHER_DEBITS_1   = 0;
 let vTI_RV_NO_NSF_1             = 0;

 let vTI_RV_CYCLES_DELQ_1        = 0;
 let vTI_RV_DATE_FIRST_ACTIVE_2  = date(1);
 let vTI_RV_DATE_LAST_PAY_2      = date(1);
 let vTI_RV_DATE_LAST_CASH_ADV_2 = date(1);
 let vTI_RV_DATE_LAST_MERCH_2    = date(1);
 
BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensaje = pEjecucion || '-' || trim(cCodRet) || ' ' || trim(vCuenta);

			CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensaje);
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_layout_in_triad_revolventes.trc";
	--TRACE ON;
  
  LET cMensaje = pEjecucion; 
  CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
  
  --- Caso 1: corre diariamente actualizando info que no sea de saldos, excepto el 21
  --- Caso 2: cuando corre el 21 (cierre del 20) obteniendo toda la informaciÃ?Â?Ã?Â³n.
   
  --select fecha_hoy, fecha_ant, pri_dia_mes into vFechahoy, vFechaDiaAnt, vPriDiaMes
  select fecha_hoy, fecha_ant, pri_dia_mes into vFechahoy_temp, vFechaDiaAnt_temp, vPriDiaMes
    from bdicred:sd_fechas
   where empresa = vEmpresa; 
   
   -- let vFechahoy  = mdy(5,20,2020);                  --- SOLO TEST MACF
   -- let vPriDiaMes = mdy(3,1,2019);                  --- SOLO TEST MACF
   -- let vFechaDiaAnt = date(vFechahoy -1 units day); --- SOLO TEST MACF
	
	let vFechahoy = today -1;  
	let vFechaDiaAnt = date(vFechahoy -1 units day); 
	
	let iDia_corte = DAY(vFechahoy);

	
   --SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO cCredIni, cCredFin
     SELECT valor INTO cCredIni_fin
          FROM bdicred:sd_param  WHERE cod_param = (980 + pEjecucion)::CHAR(3);	
 

   let cCredIni = SUBSTR(cCredIni_fin,1,12);
   let cCredFin = SUBSTR(cCredIni_fin,14,25);


		if iDia_corte = 18 or iDia_corte = 20 then

			-- 3 CORTE:  SALDO MAYOR A CERO
			SELECT a.numcte vTI_CU_CUSTOMER_ID_2, a.num_credito vNumCredito_2
			  FROM bdicred:sd_maecred a 
				   JOIN bdicred:sd_maesdos c ON c.empresa = a.empresa AND c.num_credito = a.num_credito AND c.sdo_cap_insoluto > 0  --SALDO MAYOR A CERO
			 WHERE a.num_producto <> '7800'   
			   AND a.num_credito >= cCredIni AND a.num_credito < cCredFin
			   AND a.status_cred in('AA','BA','BT')
			 INTO TEMP paso_revolventes WITH NO LOG;
			
			create unique index inx_paso_revolventes on paso_revolventes(vNumCredito_2);
			update statistics medium for table paso_revolventes;
		

			-- 4: DIARIO/CORTE	 VIGENTES	VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID		
			insert into paso_revolventes 
			SELECT a.numcte, a.num_credito
			  FROM bdicred:sd_maecred a 
				   JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito 
				   --JOIN bdicobranza:cb_triad_salida f ON f.out_co_account_id='00000000'||a.num_credito 
				   JOIN bdicobranza:cb_triad_salida f ON f.num_credito = a.num_credito 
			 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES 
			   AND a.num_credito not in (select vNumCredito_2 from paso_revolventes)
			   AND a.num_credito >= cCredIni AND a.num_credito < cCredFin 
			   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy;

		ELSE
		
	
			-- 1 DIARIO: VENCIDOS 
			SELECT a.numcte vTI_CU_CUSTOMER_ID_2, a.num_credito vNumCredito_2
			  FROM bdicred:sd_maecred a 
			 WHERE a.num_producto <> '7800' AND a.status_cred in('BA','BT') --VENCIDOS
			   AND a.num_credito >= cCredIni AND a.num_credito < cCredFin  
				INTO TEMP paso_revolventes WITH NO LOG;
			
			create unique index inx_paso_revolventes on paso_revolventes(vNumCredito_2);
			update statistics medium for table paso_revolventes;

		
			-- 2 DIARIO:  VIGENTES PAGO UN DIA ANTERIOR   
			insert into paso_revolventes 
			SELECT a.numcte, a.num_credito
			  FROM bdicred:sd_maecred a
			  JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito AND d.fecha_ult_pago = vFechaDiaAnt --PAGO UN DIA ANTERIOR
			 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES
			   AND a.num_credito not in (select vNumCredito_2 from paso_revolventes)
			   AND a.num_credito >= cCredIni AND a.num_credito  < cCredFin;


			-- 4: DIARIO/CORTE	 VIGENTES	VALIDA CAMPO DE ARCHIVO SALIDA: OUT_CO_ACCOUNT_ID		
			insert into paso_revolventes 
			SELECT a.numcte, a.num_credito
			  FROM bdicred:sd_maecred a 
				   JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito 
				   --JOIN bdicobranza:cb_triad_salida f ON f.out_co_account_id='00000000'||a.num_credito 
				   JOIN bdicobranza:cb_triad_salida f ON f.num_credito = a.num_credito 
			 WHERE a.num_producto <> '7800' AND a.status_cred = 'AA' --VIGENTES 
			   AND a.num_credito not in (select vNumCredito_2 from paso_revolventes)
			   AND a.num_credito >= cCredIni AND a.num_credito < cCredFin 
			   AND d.prox_fecha_pago+f.out_coll_next_call_days = vFechahoy;  --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*
		
		end if;

		  update statistics medium for table paso_revolventes;
		
       SELECT limit 1 empresa into vEmpresa_2
		 FROM bdicobranza:cb_triad_revolventes_2 
		WHERE ti_rv_account_id >= '600000000001' AND fecha_proceso = vFechahoy;
		
		IF nvl(vEmpresa_2,'') <> '' and vEmpresa_2 <> ''then
		   begin;
			  delete from paso_revolventes
			  where vNumCredito_2 in (SELECT ti_rv_account_id from bdicobranza:cb_triad_revolventes_2 WHERE fecha_proceso = vFechahoy);
			commit;
		END IF;
		
		begin; 
          delete from paso_revolventes
          where vNumCredito_2 in (SELECT num_credito FROM bdicred:sd_inactivos_12meses WHERE num_credito > '600000000001');
		commit;

        update statistics medium for table paso_revolventes;

	  	  
	  FOREACH WITH HOLD 

         SELECT vTI_CU_CUSTOMER_ID_2, vNumCredito_2	INTO vTI_CU_CUSTOMER_ID, vCuenta
	       FROM paso_revolventes


         --SELECT b.fecha_apertura, b.num_producto, d.fecha_vencto, c.mto_fin_ven_trasp, nvl(b.id_unidad_prod,0), d.dia_corte,
		 --    trim(b.campo_trab4), NVL(c.monto_otorgado,0), NVL(c.sdo_cap_insoluto,0), NVL(c.sdo_retenido,0), b.status_cred
		 SELECT b.fecha_apertura, b.num_producto, d.fecha_vencto, c.mto_fin_ven_trasp, b.id_unidad_prod, d.dia_corte,
		        b.campo_trab4, c.monto_otorgado, c.sdo_cap_insoluto, c.sdo_retenido, b.status_cred
		   INTO vTI_RV_DATE_OPEN, cTipoProd, dFechaIniMora, vNumvencidos, iIdUnidadProd_2, vDiacorte, cCampo_trab4_2, d_monto_otorgado_2, 
		       d_sdo_cap_insoluto_2, d_sdo_retenido_2, cStatus_cred  
  		  FROM bdicred:sd_maecred b 
		       JOIN bdicred:sd_maesdos c ON c.empresa = b.empresa AND c.num_credito = b.num_credito
		       JOIN bdicred:sd_maecredanexo d ON d.empresa = c.empresa AND d.num_credito = c.num_credito
		 WHERE b.num_credito = vCuenta;
		
      let iIdUnidadProd = nvl(iIdUnidadProd_2,0);
      let cCampo_trab4 = trim(cCampo_trab4_2); 
	  let d_monto_otorgado = nvl(d_monto_otorgado_2,0);
	  let d_sdo_cap_insoluto = nvl(d_sdo_cap_insoluto_2,0);
	  let d_sdo_retenido = nvl(d_sdo_retenido_2,0);

	  
	  let iLineaDisponible = ROUND(d_monto_otorgado - d_sdo_cap_insoluto - d_sdo_retenido,0);
	 
      let iContGral = iContGral + 1;
      
	  if vDiacorte <= 0 then continue foreach; end if;

        let vTI_RV_ACCOUNT_ID = trim(vCuenta); 

              --let vFechahoy  = mdy(11,17,2017);  --- Test
              --let vPriDiaMes = mdy(11,1,2017);   --- Test

            --if nvl(TI_RV_ACCOUNT_ID,'') <> '' and TI_RV_ACCOUNT_ID is not null then
            
               let vNumcuentas = vNumcuentas +1;
               let vfecha_fin_mes_ant = date(vPriDiaMes - 1 units day);   -- 2017-10-31
   
              
              if day(vFechahoy) < vDiacorte then
                  let vFechacorte = mdy(month(vfecha_fin_mes_ant),vDiacorte,year(vfecha_fin_mes_ant)); 
              elif day(vFechahoy) >= vDiacorte then
                  let vFechacorte = mdy(month(vFechahoy),vDiacorte,year(vFechahoy)); 
              end if;

              let vFechacorteant = vFechacorte -1 units month;  
              let vFechacorte_23MesesAntes = date(vFechacorte - 23 units month);
              let vTI_RV_DATE_CYCLE_CorteActual = vFechacorte;
							 
              /*select count(*)  into vCount_maesdoshist
			    from bdicred:sd_maesdoshist  
			   where fecha between vFechacorte_23MesesAntes and vFechacorte
			     and empresa = '001' and num_credito = vCuenta;	
			  */
			  
             -- cambiar aqui, debe ser +1 = Visa clasica, +2 = MC Oro, +3 = MC Platinum, +4 = Básica
			 if cTipoProd = '6001' then
			    let vTI_RV_ACCOUNT_TYPE = '1';
			 elif cTipoProd = '8100' then
			    let vTI_RV_ACCOUNT_TYPE = '2';
			 elif cTipoProd = '7000' then
			    let vTI_RV_ACCOUNT_TYPE = '3';
             elif cTipoProd = '6600' then
			    let vTI_RV_ACCOUNT_TYPE = '4';				
			 else
			    let vTI_RV_ACCOUNT_TYPE = '0';
			 end if;
			 
			 let vTI_RV_DATE_START_DELQ = dFechaIniMora;
			 
			  --Topar num vencidos
             if vNumvencidos > 9 then let vNumvencidos = 9; end if;
             let vTI_RV_CURR_CYCLES_DELQ = round(vNumvencidos,0);
             let vTI_RV_CYCLES_DELQ_1 = round(vNumvencidos,0);
			 
             --limite de la cuenta
             -- TI_RV_CURR_LIMIT  Limite actual de la cuenta
             --if iLineaDisponible is not null then
			 if nvl(iLineaDisponible,'') <> '' then
			    let vTI_RV_CURR_LIMIT = iLineaDisponible;
			 else 
			    let vTI_RV_CURR_LIMIT = 0;
			 end if;
			 
              
              -- Obtener diversos datos de tabla de indicadores
              --select nvl(to_char(f_primer_compra, "%Y%m%d"),'00000000'), nvl(to_char(fecha_ultimo_pago, "%Y%m%d"),'00000000'), 
              --       nvl(to_char(atm_disp_fecha, "%Y%m%d"),'00000000'), nvl(num_atm_ch,0), round(nvl(monto_atm_ch,0),0), nvl(num_pos_ch,0), round(nvl(monto_pos_ch,0),0), 
              --       nvl(to_char(fecha_ultima_compra, "%Y%m%d"),'00000000'), round(nvl(monto_vtn_ch,0),0), nvl(num_vtn_ch,0)  
			  select f_primer_compra, fecha_ultimo_pago, 
                     atm_disp_fecha, nvl(num_atm_ch,0), round(nvl(monto_atm_ch,0),0), nvl(num_pos_ch,0), round(nvl(monto_pos_ch,0),0), 
                     fecha_ultima_compra, round(nvl(monto_vtn_ch,0),0), nvl(num_vtn_ch,0), round(nvl(sdo_tot_liquidar,0),0)  
                into vTI_RV_DATE_FIRST_ACTIVE_2, vTI_RV_DATE_LAST_PAY_2, vTI_RV_DATE_LAST_CASH_ADV_2, vNum_atm, vMonto_atm, vNum_pos, vMonto_pos, 
                     vTI_RV_DATE_LAST_MERCH_2, d_Monto_vnt, vNum_vtn, dSalto_total 
                from bdicred:sd_indicador_cred
               where num_credito = vTI_RV_ACCOUNT_ID;
          
		       -- El valor de las disposiciones en efectivo (Cash Advance) realizados con la cuenta durante el periodo correspondiente.
			   -- También obtener aquí­ el saldo de caja del saldo total (suma disposiciones atm y ventanilla), estaba abajo, se repetía, copiar las variables. TI_RV_CASH_BALANCE_1 = vTI_RV_VAL_CASH_ADV_1
				let vTI_RV_DATE_FIRST_ACTIVE = nvl(vTI_RV_DATE_FIRST_ACTIVE_2,'01/01/1900');
				let vTI_RV_DATE_LAST_PAY = nvl(vTI_RV_DATE_LAST_PAY_2,'01/01/1900');
				let vTI_RV_DATE_LAST_CASH_ADV = nvl(vTI_RV_DATE_LAST_CASH_ADV_2,'01/01/1900');
				let vTI_RV_DATE_LAST_MERCH = nvl(vTI_RV_DATE_LAST_MERCH_2,'01/01/1900');
				let dMontoDisp_efect = round(vMonto_atm + d_Monto_vnt,0);
                let cMontoDisp_efect = round(dMontoDisp_efect,0); 
				let vTI_RV_VAL_CASH_ADV_1 = round(dMontoDisp_efect,0);
				
				-----------------SALDO TOTAL LIQUIDAR al día anterior
				IF dSalto_total > 0 THEN 
					let cSaldo_total = round(dSalto_total,0);
					let vTI_RV_CURR_BALANCE = round(dSalto_total,0); 
				ELSE
					let vTI_RV_CURR_BALANCE = 0; 
				END IF;
                ---- Calcular TI_RV_CURR_BALANCE (saldo actual de la cuenta)
			
				let cNumDisp_efect = round(vNum_atm + vNum_vtn,0);
 
               -- El numero de disposiciones en efectivo (Cash Advance) realizados con la cuenta durante el periodo.               
               let vTI_RV_NUM_CASH_ADV_1 = round(vNum_atm + vNum_vtn,0);
               
               -- El valor de compras realizadas con la cuenta durante el ciclo.
               let cMonto_pos = round(vMonto_pos,0); 
			   let vTI_RV_VAL_MERCH_SALES_1 = round(vMonto_pos,0);
			   
			   -- El numero de compras realizadas con la cuenta durante el periodo correspondiente.
			   let vTI_RV_NUM_MERCH_SALES_1 = vNum_pos;
 		   
             
             -- Maximo saldo en la vida de la cuenta (se informara el del ciclo actual)
             --let TI_RV_HI_BAL_LF = TI_RV_CURR_BALANCE;
             --sd_triad_sdos_inds_hist_tdc.sdomax_hist
			 

             --- Validar la FECHA PROCESO de la cuenta  en cb_triad_revolventes_2, si es nula o 1900 es la primer vez que se ejecuta el proceso y calcular los saldos diversos
			 -- al corte de tablas operativas,Si no es asÃ?Â?Ã?Â­ tomarÃ?Â?Ã?Â¡ la sd_indicador_cred pues quiere decir que ya se ejecutÃ?Â?Ã?Â³ cundo menos una vez.

			 select fecha_proceso into vFecha_proceso
			   from bdicobranza:cb_triad_revolventes_2 
			  where ti_rv_account_id = vTI_RV_ACCOUNT_ID;


			 if vFechahoy = vFechacorte then
			       -- tomar info de bdicred:sd_indicador_cred, siempre y cuando fecha hoy sea igual a fecha corte
			 
                --- Saldo máximo histórico
				--select nvl(sdo_tot_liquidar1,0), nvl(sdo_tot_liquidar2,0), nvl(sdo_tot_liquidar3,0), nvl(sdo_tot_liquidar4,0), nvl(sdo_tot_liquidar5,0), 
				--       nvl(sdo_tot_liquidar6,0), nvl(sdo_tot_liquidar7,0), nvl(sdo_tot_liquidar8,0), nvl(sdo_tot_liquidar9,0), nvl(sdo_tot_liquidar10,0), nvl(sdo_tot_liquidar11,0)
				select sdo_tot_liquidar1, sdo_tot_liquidar2, sdo_tot_liquidar3, sdo_tot_liquidar4, sdo_tot_liquidar5, 
				       sdo_tot_liquidar6, sdo_tot_liquidar7, sdo_tot_liquidar8, sdo_tot_liquidar9, sdo_tot_liquidar10, sdo_tot_liquidar11
				  into dSadototliq1, dSadototliq2, dSadototliq3, dSadototliq4, dSadototliq5, dSadototliq6, dSadototliq7, dSadototliq8, dSadototliq9, dSadototliq10, dSadototliq11
                  from bdicobranza:cb_triad_sdos_inds_tdc
                 where num_credito = vTI_RV_ACCOUNT_ID;    
                  
				  if nvl(dSadototliq1,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq1,0); end if;
				  if nvl(dSadototliq2,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq2,0); end if;
				  if nvl(dSadototliq3,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq3,0); end if;
				  if nvl(dSadototliq4,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq4,0); end if;
				  if nvl(dSadototliq5,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq5,0); end if;
				  if nvl(dSadototliq6,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq6,0); end if;
				  if nvl(dSadototliq7,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq7,0); end if;
				  if nvl(dSadototliq8,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq8,0); end if;
				  if nvl(dSadototliq9,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq9,0); end if;
				  if nvl(dSadototliq10,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq10,0); end if;
				  if nvl(dSadototliq11,0) > dSdoMax_hist then let dSdoMax_hist = round(dSadototliq11,0); end if;
				  
				  
                  --if dSdoMax_hist is not null then
				  if nvl(dSdoMax_hist,'') <> '' then
                     let cSdoMax_hist = round(dSdoMax_hist,0);
                     let vTI_RV_HI_BAL_LF = round(dSdoMax_hist,0);
				  else
				     let vTI_RV_HI_BAL_LF = 0;
                  end if;
				
				--Maxima morosidad historica de la cuenta (numero de meses vencidos historicos de la cuenta), topada a 9.
                --let TI_RV_HI_DELQ_LF = lpad(TI_RV_CURR_CYCLES_DELQ,2,'0');  -- ESTE FUE PARA PRUEBA
             
				select nvl(max_mora_hist,0), round(nvl(saldo_maximo_hist,0),0), round(nvl(sdo_tot_liquidar,0),0), round(nvl(sdo_tot_liquidar_ch,0),0), round(nvl(pago_minimo_ch,0),0), 
				       round(nvl(sdo_tot_vencido_ch,0),0), round(NVL(comision_disp_efectivo_ch,0),0), round(nvl(monto_devoluciones_ch,0),0), round(nvl(monto_otras_trnx_ch,0),0),
        			   nvl(num_veces_mora1,0), nvl(num_veces_mora2,0), nvl(num_veces_mora3,0), nvl(num_veces_mora4,0), nvl(num_vencidos_ch,0), round(NVL(monto_pagos_ch,0),0), 
					   nvl(intereses_periodo_ch,0), nvl(limite_credito_ch,0)
				  into iMaxMorosidad, dSdoMax_hist, dSalto_total, dSdoTotalLiq, dPago_minimo_AlCorte, dSaldoVencido_AlCorte, 
				       vTI_RV_VAL_FEES_2, dSumaDevoluciones, d_Otras_transacciones, iVecesMora1, iVecesMora2, 
					   iVecesMora3, iVecesMora4, vNum_vencidos_ch, dMontoPagos_CicloAct, d_Intereses_periodo, dLimiteCred_AlCorte
				  from bdicred:sd_indicador_cred
				 where empresa = vEmpresa
                   and num_credito = vTI_RV_ACCOUNT_ID;       
             
			    --if iMaxMorosidad is not null then
				if nvl(iMaxMorosidad,'') <> '' then
                   if iMaxMorosidad > 9 then let iMaxMorosidad = 9; end if;
				   let vTI_RV_HI_DELQ_LF = iMaxMorosidad;
				else
				   let vTI_RV_HI_DELQ_LF = 0;  
			    end if;
			
			    -----------------SALDO TOTAL LIQUIDAR al día anterior (se modifica para que tome la del corte 20200616)
			    --let cSaldo_total = round(dSalto_total,0);
                --let vTI_RV_CURR_BALANCE = round(dSalto_total,0); 
				IF dSdoTotalLiq > 0 THEN
					let cSaldo_total = round(dSdoTotalLiq,0);
					let vTI_RV_CURR_BALANCE = round(dSdoTotalLiq,0); 				
				ELSE
					let vTI_RV_CURR_BALANCE = 0; 				
				END IF;
                ---- Calcular TI_RV_CURR_BALANCE (saldo actual de la cuenta)
			  
			    let c_Intereses_periodo = round(d_Intereses_periodo,0);
			    let vTI_RV_VAL_INTEREST_1 = round(d_Intereses_periodo,0);
		        let vTI_RV_CREDIT_INTEREST = round(d_Intereses_periodo,0);
           
			 
               -- TI_RV_HI_BAL_LF   ---- Maximo saldo en la vida de la cuenta (se informara el del ciclo actual)
               -- Obtener de sd_triad_sdos_inds_hist_tdc.sdomax_hist
               
				let dFechacorte_12MsAntes = date(vFechacorte - 12 units month);			   
				
				--if dSdoMax_hist is not null then
				if nvl(dSdoMax_hist,'') <> '' then
				   let vTI_RV_HI_BAL_LF = round(dSdoMax_hist,0);
				else
				   let vTI_RV_HI_BAL_LF = 0;
				end if;
				
                   
				 if iVecesMora1 is not null then let vTI_RV_NUM_1_CYC_LF = iVecesMora1; end if;
				 if iVecesMora2 is not null then let vTI_RV_NUM_2_CYC_LF = iVecesMora2; end if;
				 if iVecesMora3 is not null then let vTI_RV_NUM_3_CYC_LF = iVecesMora3; end if;
				 if iVecesMora4 is not null then let vTI_RV_NUM_4P_CYC_LF = iVecesMora4; end if;

			 
				 -- determina el boqueo de cuenta o no (ciclo actual)
			     --select limit 1 lpad(cve_causa,4,'0') into v_cod_bloqueo_cta
			     select limit 1 nvl(cve_causa,'0') into v_cod_bloqueo_cta
			       from bdicred:sd_bitacorabloqueocta
                  where cuenta = vTI_RV_ACCOUNT_ID and fecha between vFechacorteant and vFechacorte
                    and tipo_movimiento = 'B'; 
				
                 let vTI_RV_BLOCK_CODE_1 = nvl(v_cod_bloqueo_cta,'0');
				
                 let cSdoTotalLiq = round(dSdoTotalLiq,0);
                 let vTI_RV_CYCLE_BALANCE_1 = round(dSdoTotalLiq,0);
			   
                 let cPago_minimo_AlCorte = round(dPago_minimo_AlCorte,0);
                 let vTI_RV_AMOUNT_DUE_1 = round(dPago_minimo_AlCorte,0);

                 -- TI_RV_AMOUNT_DUE_1 Pago Minimo al corte
           
                 -- El valor de pagos durante el ciclo (Montos de pagos durante el ciclo. )
			     -- Al parecer este dato ya viene en la sd_indicador_cred, tomarlo de ahÃ?Â?Ã?Â­
			 
			     --if dMontoPagos_CicloAct <> '' or dMontoPagos_CicloAct is not null then
				 if nvl(dMontoPagos_CicloAct,'') <> '' then
			        let vTI_RV_VAL_PAYMENTS_1 = round(dMontoPagos_CicloAct,0);
				 else 
				    let vTI_RV_VAL_PAYMENTS_1 = 0;   
			     end if;
             
             -- El valor de pagos durante el ciclo (Montos de pagos durante el ciclo. )
             
			 -- TI_RV_VAL_ARREARS_1 -- El valor de atrasos en la cuenta en el ciclo - Saldo vencido de la cuenta al corte correspondiente
             --Estos dos valores tomarlos de la sd_indicador_cred, se obtienen arriba
			 -- Ya no se obtiene asÃ?Â?Ã?Â­, ya se trae la consulta arriba de la sd_indicador_cred
			  
			  let cSaldoVencido_AlCorte = round(dSaldoVencido_AlCorte,0);
			  let vTI_RV_VAL_ARREARS_1 = round(dSaldoVencido_AlCorte,0);
	  
              -- TI_RV_VAL_ARREARS_1 -- El valor de atrasos en la cuenta en el ciclo - Saldo vencido de la cuenta al corte correspondiente
			  -- TI_RV_LIMIT_1   El lÃ?Â?Ã?Â­mite de crÃ?Â?Ã?Â©dito de la cuenta. (corte actual)
              
              let cLimiteCred_AlCorte = round(dLimiteCred_AlCorte,0);
			  let vTI_RV_LIMIT_1 = round(dLimiteCred_AlCorte,0);
	  
              -- TI_RV_LIMIT_1   El lÃ?Â?Ã?Â­mite de crÃ?Â?Ã?Â©dito de la cuenta. (corte actual)  

              -- La cantidad de devoluciones (non-payment credits) hechas en la cuenta en el ciclo.
			  -- Ya no se obtiene asÃ?Â?Ã?Â­, se obtiene de sd_indicador_cred, ya consultado arriba 

			   let cSumaDevoluciones = round(dSumaDevoluciones,0);
			   let vTI_RV_VAL_RETURNS_1 = round(dSumaDevoluciones,0);
	   
               -- El valor de otras transacciones (excluyendo pagos, compras y disposiciones en efectivo) durante el ciclo. Si es un valor neto de credito, 
               -- el signo es negativo.  Si no existe algun otro concepto poner en +000000000
               -- TI_RV_VAL_OTHER_TXNS_1   Ya inicializada
               -- 2018-02-24 sacar el valor para informar lo de otras transacciones TI_RV_VAL_OTHER_TXNS_1 con la tabla sd_conceptospagomanual concepto Abono por correcciÃ?Â?Ã?Â³n (codigo_fun 052)

			   --if d_Otras_transacciones is not null then
			   if nvl(d_Otras_transacciones,'') <> '' then
			      LET vTI_RV_VAL_OTHER_TXNS_1 = d_Otras_transacciones;
			   else 
			      LET vTI_RV_VAL_OTHER_TXNS_1 = 0;
			   end if;
				  
               -- Total de comisiones cargadas durante el periodo.
               let vTI_RV_VAL_TOTAL_FEES_1 = vTI_RV_VAL_FEES_2;   -- se copia de esta pq es la unica comisiÃ?Â?Ã?Â³n que hay
  
               -- Sacar el num_pagos_hist, acumularlo del que se obtiene en el período
			   /*select count(*) into iNum_pagos_periodo
				FROM bdicred:sd_movhis
				WHERE empresa = vEmpresa 
				and fecha_mov between vFechacorteant and vFechacorte
				and num_credito = vTI_RV_ACCOUNT_ID
				and codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual) --in ('033', '334', '335', '336', '337')
				and codigo_ref = 1
				and reversado = 'N';
				
				begin;
				 UPDATE bdicred:sd_indicador_cred SET num_pagos_hist = num_pagos_hist + iNum_pagos_periodo
				 where empresa = vEmpresa and num_credito = vTI_RV_ACCOUNT_ID;
				commit;	
			   */	

      end if;       

	  select count(*) into iContadorTarjetas
        from bdicred:sd_tarjeta 
       where empresa = vEmpresa
         and num_credito = vTI_RV_ACCOUNT_ID;
         --and tipo_tarjeta in('A','T')
         --and status_tar in('A','I');
             
        --let vTI_RV_NO_CARDS = lpad(trim(cContadorTarjetas),3,'0');
		let vTI_RV_NO_CARDS = iContadorTarjetas;
			  
	  --let vNumCredito_salida = '00000000' || trim(vTI_RV_ACCOUNT_ID);
	  
	  -- Después de la primera ejecución, se debe traer este valor
      --select nvl(out_rv_cat,'00') into vOut_rv_cat
	  select limit 1 out_rv_cat into vOut_rv_cat_2
  	    from bdicobranza:cb_triad_salida
	   --where out_rv_account_id = vNumCredito_salida;
       where num_credito = vTI_RV_ACCOUNT_ID;
	   
	   let vOut_rv_cat = nvl(vOut_rv_cat_2,'00');
	   
	   --if vOut_rv_cat = '' or vOut_rv_cat is null then let vOut_rv_cat = '00'; end if;
	   --if nvl(vOut_rv_cat,'') = '' then
	   --   let vOut_rv_cat = '00'; 
	   --end if;
              
	
	if nvl(vFecha_proceso,'01/01/1900') <> '01/01/1900' then
	   let iExisteCuenta = 1;
	end if;
		 
    if iExisteCuenta > 0  and (vFechahoy = vFechacorte) then
	  BEGIN; 
		 UPDATE cb_triad_revolventes_2 
		 SET ti_cu_customer_id = vTI_CU_CUSTOMER_ID,
		 ti_rv_date_open =  vTI_RV_DATE_OPEN,
		 ti_rv_date_closed = vTI_RV_DATE_CLOSED,
		 ti_rv_account_type = vTI_RV_ACCOUNT_TYPE,
		 ti_rv_date_first_active = vTI_RV_DATE_FIRST_ACTIVE,
		 ti_rv_date_last_merch = vTI_RV_DATE_LAST_MERCH, 
		 ti_rv_date_last_pay = vTI_RV_DATE_LAST_PAY, 
		 ti_rv_date_last_cash_adv = vTI_RV_DATE_LAST_CASH_ADV,
		 ti_rv_date_start_delq = vTI_RV_DATE_START_DELQ,
		 ti_rv_curr_balance = vTI_RV_CURR_BALANCE,
		 ti_rv_curr_limit = vTI_RV_CURR_LIMIT,
		 ti_rv_curr_cycles_delq = vTI_RV_CURR_CYCLES_DELQ,
		 ti_rv_triad_cat = vOut_rv_cat,
		 ti_rv_val_fees_1 = vTI_RV_VAL_FEES_1,
		 ti_rv_val_fees_2 = vTI_RV_VAL_FEES_2,
		 ti_rv_val_fees_3 = vTI_RV_VAL_FEES_3,
		 ti_rv_val_fees_4 = vTI_RV_VAL_FEES_4,
		 ti_rv_val_fees_5 = vTI_RV_VAL_FEES_5,
		 ti_rv_credit_interest = vTI_RV_CREDIT_INTEREST,
		 ti_rv_hi_bal_lf = vTI_RV_HI_BAL_LF,
		 ti_rv_hi_delq_lf = vTI_RV_HI_DELQ_LF,
		 ti_rv_num_1_cyc_lf = vTI_RV_NUM_1_CYC_LF,
		 ti_rv_num_2_cyc_lf = vTI_RV_NUM_2_CYC_LF,
		 ti_rv_num_3_cyc_lf = vTI_RV_NUM_3_CYC_LF,
		 ti_rv_num_4p_cyc_lf = vTI_RV_NUM_4P_CYC_LF,
		 ti_rv_no_cards = vTI_RV_NO_CARDS,
		 ti_rv_date_cycle_1 =  vTI_RV_DATE_CYCLE_CorteActual,
		 ti_rv_block_code_1 =  vTI_RV_BLOCK_CODE_1,
		 ti_rv_cycle_balance_1 = vTI_RV_CYCLE_BALANCE_1,
		 ti_rv_cash_balance_1 = vTI_RV_VAL_CASH_ADV_1,
		 ti_rv_amount_due_1 = vTI_RV_AMOUNT_DUE_1,
		 ti_rv_val_payments_1 = vTI_RV_VAL_PAYMENTS_1,
		 ti_rv_val_merch_sales_1 = vTI_RV_VAL_MERCH_SALES_1,
		 ti_rv_num_merch_sales_1 = vTI_RV_NUM_MERCH_SALES_1,
		 ti_rv_val_cash_adv_1 = vTI_RV_VAL_CASH_ADV_1,
		 ti_rv_num_cash_adv_1 = vTI_RV_NUM_CASH_ADV_1,
		 ti_rv_val_arrears_1 = vTI_RV_VAL_ARREARS_1,
		 ti_rv_limit_1 = vTI_RV_LIMIT_1,
		 ti_rv_val_returns_1 = vTI_RV_VAL_RETURNS_1,
		 ti_rv_val_other_txns_1 = vTI_RV_VAL_OTHER_TXNS_1,
		 ti_rv_val_interest_1 = vTI_RV_VAL_INTEREST_1,
		 ti_rv_val_total_fees_1 = vTI_RV_VAL_TOTAL_FEES_1,
		 ti_rv_val_other_debits_1 = vTI_RV_VAL_OTHER_DEBITS_1,
		 ti_rv_no_nsf_1 = vTI_RV_NO_NSF_1,
		 ti_rv_cycles_delq_1 = vTI_RV_CYCLES_DELQ_1,
         ti_rv_status_anterior = cStatus_cred,
		 fecha_corte = vFechacorte,
		 empresa = vEmpresa,
		 fecha_proceso = vFechahoy
		WHERE ti_rv_account_id = vCuenta; 

	  COMMIT;
  
  elif iExisteCuenta > 0 and (vFechahoy <> vFechacorte) then   
	 
	  BEGIN; 
		 UPDATE "informix".cb_triad_revolventes_2 
		 SET ti_cu_customer_id = vTI_CU_CUSTOMER_ID,
		 ti_rv_date_open =  vTI_RV_DATE_OPEN,
		 ti_rv_date_closed = vTI_RV_DATE_CLOSED,
		 ti_rv_account_type = vTI_RV_ACCOUNT_TYPE,
		 ti_rv_date_first_active = vTI_RV_DATE_FIRST_ACTIVE,
		 ti_rv_date_last_merch = vTI_RV_DATE_LAST_MERCH, 
		 ti_rv_date_last_pay = vTI_RV_DATE_LAST_PAY, 
		 ti_rv_date_last_cash_adv = vTI_RV_DATE_LAST_CASH_ADV,
		 ti_rv_date_start_delq = vTI_RV_DATE_START_DELQ,
		 ti_rv_curr_balance = vTI_RV_CURR_BALANCE,
		 ti_rv_curr_limit = vTI_RV_CURR_LIMIT,
		 ti_rv_curr_cycles_delq = vTI_RV_CURR_CYCLES_DELQ,
		 ti_rv_triad_cat = vOut_rv_cat,
		 ti_rv_val_fees_1 = vTI_RV_VAL_FEES_1,
		 ti_rv_val_fees_2 = vTI_RV_VAL_FEES_2,
		 ti_rv_val_fees_3 = vTI_RV_VAL_FEES_3,
		 ti_rv_val_fees_4 = vTI_RV_VAL_FEES_4,
		 ti_rv_val_fees_5 = vTI_RV_VAL_FEES_5,
		 ti_rv_credit_interest = vTI_RV_CREDIT_INTEREST,
		 ti_rv_hi_bal_lf = vTI_RV_HI_BAL_LF,
		 ti_rv_hi_delq_lf = vTI_RV_HI_DELQ_LF,
		 ti_rv_num_1_cyc_lf = vTI_RV_NUM_1_CYC_LF,
		 ti_rv_num_2_cyc_lf = vTI_RV_NUM_2_CYC_LF,
		 ti_rv_num_3_cyc_lf = vTI_RV_NUM_3_CYC_LF,
		 ti_rv_num_4p_cyc_lf = vTI_RV_NUM_4P_CYC_LF,
		 ti_rv_no_cards = vTI_RV_NO_CARDS,
		 --ti_rv_date_cycle_1 =  vTI_RV_DATE_CYCLE_CorteActual,
		 --ti_rv_block_code_1 =  vTI_RV_BLOCK_CODE_1,
		 --ti_rv_cycle_balance_1 = vTI_RV_CYCLE_BALANCE_1,
		 --ti_rv_cash_balance_1 = vTI_RV_VAL_CASH_ADV_1,
		 --ti_rv_amount_due_1 = vTI_RV_AMOUNT_DUE_1,
		 --ti_rv_val_payments_1 = vTI_RV_VAL_PAYMENTS_1,
		 --ti_rv_val_merch_sales_1 = vTI_RV_VAL_MERCH_SALES_1,
		 --ti_rv_num_merch_sales_1 = vTI_RV_NUM_MERCH_SALES_1,
		 --ti_rv_val_cash_adv_1 = vTI_RV_VAL_CASH_ADV_1,
		 --ti_rv_num_cash_adv_1 = vTI_RV_NUM_CASH_ADV_1,
		 --ti_rv_val_arrears_1 = vTI_RV_VAL_ARREARS_1,
		 --ti_rv_limit_1 = vTI_RV_LIMIT_1,
		 --ti_rv_val_returns_1 = vTI_RV_VAL_RETURNS_1,
		 --ti_rv_val_other_txns_1 = vTI_RV_VAL_OTHER_TXNS_1,
		 --ti_rv_val_interest_1 = vTI_RV_VAL_INTEREST_1,
		 --ti_rv_val_total_fees_1 = vTI_RV_VAL_TOTAL_FEES_1,
		 --ti_rv_val_other_debits_1 = vTI_RV_VAL_OTHER_DEBITS_1,
		 --ti_rv_no_nsf_1 = vTI_RV_NO_NSF_1,
		 --ti_rv_cycles_delq_1 = vTI_RV_CYCLES_DELQ_1,
         ti_rv_status_anterior = cStatus_cred,
		 fecha_corte = vFechacorte,
		 empresa = vEmpresa,
		 fecha_proceso = vFechahoy
		WHERE ti_rv_account_id = vCuenta; 

	 COMMIT;   
 	 
  else  --iExisteCuenta = 0 then
	   begin;
		INSERT INTO cb_triad_revolventes_2(ti_rv_account_id, ti_cu_customer_id, ti_rv_date_open, ti_rv_date_closed, ti_rv_account_type, ti_rv_date_first_active, 
			   ti_rv_date_last_merch, ti_rv_date_last_pay, ti_rv_date_last_cash_adv, ti_rv_date_start_delq, ti_rv_curr_balance, ti_rv_curr_limit, ti_rv_curr_cycles_delq, 
			   ti_rv_triad_cat, ti_rv_val_fees_1, ti_rv_val_fees_2, ti_rv_val_fees_3, ti_rv_val_fees_4, ti_rv_val_fees_5, ti_rv_credit_interest, ti_rv_hi_bal_lf, ti_rv_hi_delq_lf, 
			   ti_rv_num_1_cyc_lf, ti_rv_num_2_cyc_lf, ti_rv_num_3_cyc_lf, ti_rv_num_4p_cyc_lf,
			   ti_rv_no_cards, ti_rv_date_cycle_1, ti_rv_block_code_1, ti_rv_cycle_balance_1, ti_rv_cash_balance_1, ti_rv_amount_due_1, ti_rv_val_payments_1, ti_rv_val_merch_sales_1, 
			   ti_rv_num_merch_sales_1, ti_rv_val_cash_adv_1, ti_rv_num_cash_adv_1, ti_rv_val_arrears_1, ti_rv_limit_1, ti_rv_val_returns_1, ti_rv_val_other_txns_1, 
			   ti_rv_val_interest_1, ti_rv_val_total_fees_1, ti_rv_val_other_debits_1, ti_rv_no_nsf_1, ti_rv_cycles_delq_1, ti_rv_status_anterior, fecha_corte, empresa, fecha_proceso) 

		VALUES(vTI_RV_ACCOUNT_ID, vTI_CU_CUSTOMER_ID, vTI_RV_DATE_OPEN, vTI_RV_DATE_CLOSED, vTI_RV_ACCOUNT_TYPE, vTI_RV_DATE_FIRST_ACTIVE, vTI_RV_DATE_LAST_MERCH, vTI_RV_DATE_LAST_PAY,
			   vTI_RV_DATE_LAST_CASH_ADV, vTI_RV_DATE_START_DELQ, vTI_RV_CURR_BALANCE, vTI_RV_CURR_LIMIT, vTI_RV_CURR_CYCLES_DELQ, vOut_rv_cat, vTI_RV_VAL_FEES_1, vTI_RV_VAL_FEES_2,
			   vTI_RV_VAL_FEES_3, vTI_RV_VAL_FEES_4, vTI_RV_VAL_FEES_5, vTI_RV_CREDIT_INTEREST, vTI_RV_HI_BAL_LF, vTI_RV_HI_DELQ_LF, vTI_RV_NUM_1_CYC_LF, vTI_RV_NUM_2_CYC_LF,
			   vTI_RV_NUM_3_CYC_LF, vTI_RV_NUM_4P_CYC_LF, vTI_RV_NO_CARDS, vTI_RV_DATE_CYCLE_CorteActual,
			   vTI_RV_BLOCK_CODE_1, vTI_RV_CYCLE_BALANCE_1, vTI_RV_VAL_CASH_ADV_1, vTI_RV_AMOUNT_DUE_1, vTI_RV_VAL_PAYMENTS_1, vTI_RV_VAL_MERCH_SALES_1, vTI_RV_NUM_MERCH_SALES_1,
			   vTI_RV_VAL_CASH_ADV_1, vTI_RV_NUM_CASH_ADV_1, vTI_RV_VAL_ARREARS_1, vTI_RV_LIMIT_1, vTI_RV_VAL_RETURNS_1, vTI_RV_VAL_OTHER_TXNS_1, vTI_RV_VAL_INTEREST_1, 
			   vTI_RV_VAL_TOTAL_FEES_1, vTI_RV_VAL_OTHER_DEBITS_1, vTI_RV_NO_NSF_1, vTI_RV_CYCLES_DELQ_1, cStatus_cred, vFechacorte, vEmpresa, vFechahoy);

	  commit; 
  end if;
   -- LIMPIAR VARIABLES   
  LET vTI_CU_CUSTOMER_ID = ''; --20 ya en la descarga se darÃ?Â?Ã?Â¡ el formato
  LET vTI_RV_ACCOUNT_ID  = ''; --20 ya en la descarga se darÃ?Â?Ã?Â¡ el formato
		
  let vTI_RV_DATE_OPEN            = date(1);       
  let vTI_RV_DATE_CLOSED          = date(1);       
  let vTI_RV_ACCOUNT_TYPE         = '';    
  let vTI_RV_DATE_FIRST_ACTIVE    = date(1);       
  let vTI_RV_DATE_LAST_MERCH      = date(1);       
  let vTI_RV_DATE_LAST_PAY        = date(1);       
  let vTI_RV_DATE_LAST_CASH_ADV   = date(1);       
  let vTI_RV_DATE_START_DELQ      = date(1);          
  let vTI_RV_CURR_BALANCE         = 0; 
  let vTI_RV_CURR_LIMIT           = 0;  
  let vTI_RV_CURR_CYCLES_DELQ     = 0;      
  let vOut_rv_cat                 = '';       
  let vTI_RV_VAL_FEES_1           = 0; 
  let vTI_RV_VAL_FEES_2           = 0; 
  let vTI_RV_VAL_FEES_3           = 0; 
  let vTI_RV_VAL_FEES_4           = 0; 
  let vTI_RV_VAL_FEES_5           = 0; 
  let vTI_RV_CREDIT_INTEREST      = 0; 
  let vTI_RV_HI_BAL_LF            = 0; 
  let vTI_RV_HI_DELQ_LF           = 0;      
  let vTI_RV_NUM_1_CYC_LF         = 0;      
  let vTI_RV_NUM_2_CYC_LF         = 0;      
  let vTI_RV_NUM_3_CYC_LF         = 0;      
  let vTI_RV_NUM_4P_CYC_LF        = 0;      
  let vTI_RV_NO_CARDS             = 0;
  let vTI_RV_DATE_CYCLE_1         = date(1);      
  let vTI_RV_DATE_CYCLE_CorteActual = date(1);          
  let vTI_RV_BLOCK_CODE_1         = 0;       
  let vTI_RV_CYCLE_BALANCE_1      = 0; 
  let vTI_RV_AMOUNT_DUE_1         = 0; 
  let vTI_RV_VAL_PAYMENTS_1       = 0; 
  let vTI_RV_VAL_MERCH_SALES_1    = 0; 
  let vTI_RV_NUM_MERCH_SALES_1    = 0;      
  let vTI_RV_VAL_CASH_ADV_1       = 0; 
  let vTI_RV_NUM_CASH_ADV_1       = 0;      
  let vTI_RV_VAL_ARREARS_1        = 0; 
  let vTI_RV_LIMIT_1              = 0; 
  let vTI_RV_VAL_RETURNS_1        = 0; 
  let vTI_RV_VAL_OTHER_TXNS_1     = 0; 
  let vTI_RV_VAL_INTEREST_1       = 0; 
  let vTI_RV_VAL_TOTAL_FEES_1     = 0; 
  let vTI_RV_VAL_OTHER_DEBITS_1   = 0;
  let vTI_RV_NO_NSF_1             = 0;
  let vCuenta       = '';  
  let iExisteCuenta = 0;
  let vFecha_proceso = date(1); 
  
  let vTI_RV_DATE_FIRST_ACTIVE_2  = date(1);
  let vTI_RV_DATE_LAST_PAY_2      = date(1);
  let vTI_RV_DATE_LAST_CASH_ADV_2 = date(1);
  let vTI_RV_DATE_LAST_MERCH_2    = date(1);
  let vOut_rv_cat_2               = '';
  
  let iMaxMorosidad   = 0;
  let dSdoMax_hist    = 0;
  let dSalto_total    = 0;
  let dSdoTotalLiq    = 0;
  let dPago_minimo_AlCorte = 0;
  let dSaldoVencido_AlCorte = 0;
  let dSumaDevoluciones = 0; 
  let d_Otras_transacciones = 0;
  let iVecesMora1 = 0; 
  let iVecesMora2 = 0; 
  let iVecesMora3 = 0; 
  let iVecesMora4 = 0;
  let vNum_vencidos_ch = 0;
  let dMontoPagos_CicloAct = 0;
  let d_Intereses_periodo = 0;
  let dLimiteCred_AlCorte = 0;
  
  end foreach

 
 let cContGral = iContGral;
 CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 
 LET cMensaje = trim(cMensaje) || '. [' || trim(cContGral) || '] - Registros procesados.';
 
 	
    ---RETURN cCodRet;
	RETURN cCodRet, trim(cMensaje);
END
END PROCEDURE
;