CREATE PROCEDURE "informix".sp_valida_upgrade(pEmpresa CHAR(3), pCredito CHAR(20))
RETURNING CHAR(6)    AS codigo_retorno,
          CHAR(150)  AS mensaje_retorno;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(150,1);
DEFINE vCodRet 		 CHAR(6);
DEFINE vMsjRetorno   VARCHAR(150,1);
DEFINE scod_ret		 CHAR(6);
DEFINE cod_ret       CHAR(3);
DEFINE cEmpresa      CHAR(3);
DEFINE CstatusSol    CHAR(2);
-- DEFINICION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
DEFINE cCodRetCSG			CHAR(6);
DEFINE cMsjRetCSG			CHAR(80);
DEFINE cNumCreditoCSG		CHAR(20);
DEFINE cCodTCredCSG			CHAR(2);
DEFINE dFechaOrigCSG		DATE;
DEFINE dFechaProxPagCSG 	DATE;
DEFINE dcPagoMinCSG			DECIMAL(18,2);
DEFINE dFechaUltPagCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagRealizadosCSG	INTEGER;
DEFINE dcLinOtorgadaCSG		DECIMAL(18,2);
DEFINE dcTasaInteresCSG		DECIMAL(9,6);
DEFINE dcTasaMoratoriosCSG 	DECIMAL(9,6);
DEFINE dcMontoSbsCSG		DECIMAL(14,2);
DEFINE dcCapVigCSG			DECIMAL(18,2);
DEFINE dcCapTransCSG		DECIMAL(18,2);
DEFINE dcCapVdoExigCSG		DECIMAL(18,2);
DEFINE dcCapVdoNoExigCSG	DECIMAL(18,2);
DEFINE dcSdoActTotCapCSG	DECIMAL(18,2);
DEFINE dcIntVigCSG			DECIMAL(18,2);
DEFINE dcIntVdoCSG			DECIMAL(18,2);
DEFINE dcIntMoratorioCSG	DECIMAL(18,2);
DEFINE dcIntMesCSG			DECIMAL(18,2);
DEFINE dcSodActTotIntCSG	DECIMAL(18,2);
DEFINE dcIvaIntVigCSG		DECIMAL(18,2);
DEFINE dcIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dcIvaIntMorCSG		DECIMAL(18,2);
DEFINE dcIvaIntMesCSG		DECIMAL(18,2);
DEFINE dcSdoActTotIvaCSG	DECIMAL(18,2);
DEFINE dcComPendCSG			DECIMAL(18,2);
DEFINE dcIvaComCSG			DECIMAL(18,2);
DEFINE dcSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dcTotalLiqCSG		DECIMAL(18,2);
DEFINE dcIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcLinDispCSG			DECIMAL(18,2);
DEFINE dcPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqCtaCSG			CHAR(60);
DEFINE cIdCausaBloqCredCSG	CHAR(3);
DEFINE cCausaBloqCtaCSG		CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG 		CHAR(75);
DEFINE vFolio	            CHAR(16);
DEFINE vHoy                 DATE;
DEFINE P_ERROR 				CHAR(5);
DEFINE P_MENSAJE			VARCHAR(100,1);
DEFINE V_CATIVA				DECIMAL(9,6);
DEFINE V_MERCADEO			CHAR(1);
--AAME 31/10/2019 INC 27 135
DEFINE iTotSBC				INTEGER; 

DEFINE cMtoVen				DECIMAL(18,2); 
DEFINE sExistePromo         SMALLINT;

---CLONACION DE TDC Oro
LET cMtoVen 	  = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizó la consulta correctamente.';
LET vCodRet       = '';
LET vMsjRetorno	  = '';

LET cEmpresa      = '';
LET CstatusSol    = '';
-- INICIALIZACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
LET cCodRetCSG				= '000000';
LET cMsjRetCSG				= '';
LET cNumCreditoCSG			= '';
LET cCodTCredCSG			= '';
LET dFechaOrigCSG			= DATE(1);
LET dFechaProxPagCSG 		= DATE(1);
LET dcPagoMinCSG			= 0.00;
LET dFechaUltPagCSG			= DATE(1);
LET iPlazoCSG				= 0;
LET iPagRealizadosCSG		= 0;
LET dcLinOtorgadaCSG		= 0.00;
LET dcTasaInteresCSG		= 0.00;
LET dcTasaMoratoriosCSG 	= 0.00;
LET dcMontoSbsCSG			= 0.00;
LET dcCapVigCSG				= 0.00;
LET dcCapTransCSG			= 0.00;
LET dcCapVdoExigCSG			= 0.00;
LET dcCapVdoNoExigCSG		= 0.00;
LET dcSdoActTotCapCSG		= 0.00;
LET dcIntVigCSG				= 0.00;
LET dcIntVdoCSG				= 0.00;
LET dcIntMoratorioCSG		= 0.00;
LET dcIntMesCSG				= 0.00;
LET dcSodActTotIntCSG		= 0.00;
LET dcIvaIntVigCSG			= 0.00;
LET dcIvaIntVdoCSG			= 0.00;
LET dcIvaIntMorCSG			= 0.00;
LET dcIvaIntMesCSG			= 0.00;
LET dcSdoActTotIvaCSG		= 0.00;
LET dcComPendCSG			= 0.00;
LET dcIvaComCSG				= 0.00;
LET dcSdoRetenidoCSG		= 0.00;
LET dcTotalLiqCSG			= 0.00;
LET dcIntDevengadoCSG		= 0.00;
LET dcIvaIntDevengadoCSG	= 0.00;
LET dcLinDispCSG			= 0.00;
LET dcPagosVdosCSG			= 0.00;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqCtaCSG				= '';
LET cIdCausaBloqCredCSG		= '';
LET cCausaBloqCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0;
LET cSitEspCredCSG 			= '';
--AAME 31/10/2019 INC 27 135
LET iTotSBC					= 0;
LET sExistePromo			= 0;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_valida_upgrade.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' OR TRIM(NVL(pCredito,''))=''    THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';
  RETURN cCodRet, cMensajeRet;
END IF;


-- CONSULTAMOS EL SALDO GENERAL DEL CREDITO.
EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general(TRIM(pEmpresa), TRIM(pCredito))
INTO cCodRetCSG, cMsjRetCSG, cNumCreditoCSG, cCodTCredCSG, dFechaOrigCSG, dFechaProxPagCSG, dcPagoMinCSG, dFechaUltPagCSG, iPlazoCSG, iPagRealizadosCSG, dcLinOtorgadaCSG, dcTasaInteresCSG, dcTasaMoratoriosCSG, dcMontoSbsCSG,
	 dcCapVigCSG, dcCapTransCSG, dcCapVdoExigCSG, dcCapVdoNoExigCSG, dcSdoActTotCapCSG, dcIntVigCSG, dcIntVdoCSG, dcIntMoratorioCSG, dcIntMesCSG, dcSodActTotIntCSG, dcIvaIntVigCSG, dcIvaIntVdoCSG, dcIvaIntMorCSG, dcIvaIntMesCSG,
	 dcSdoActTotIvaCSG, dcComPendCSG, dcIvaComCSG, dcSdoRetenidoCSG, dcTotalLiqCSG, dcIntDevengadoCSG, dcIvaIntDevengadoCSG, dcLinDispCSG, dcPagosVdosCSG, cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqCtaCSG, cIdCausaBloqCredCSG,
	 cCausaBloqCtaCSG, cIdSitEspCteCSG, iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;

IF cCodRetCSG = '000005' THEN -- OCURRIÓ UN ERROR AL REALIZAR CALCULO
	EXECUTE PROCEDURE bdinteg:sp_desc_ret('06','597')
	INTO vCodRet, vMsjRetorno;
	LET cCodRet  = '000002';
	LET cMensajeRet = vMsjRetorno::CHAR(150);
	RETURN cCodRet, cMensajeRet;
ELIF cCodRetCSG = '000006' THEN -- NO SE ENCONTRÓ EL FACTOR DE LA COMISIÓN
	EXECUTE PROCEDURE bdinteg:sp_desc_ret('06','598')
	INTO vCodRet, vMsjRetorno;
	LET cCodRet  = '000003';
	LET cMensajeRet = vMsjRetorno::CHAR(150);
	RETURN cCodRet, cMensajeRet;
ELIF cCodRetCSG::INTEGER < 0 THEN -- ERROR NO CONTROLADO EN EL BDICRED:SP_CONSULTA_SALDOS_GENERAL
	EXECUTE PROCEDURE bdinteg:sp_desc_ret('06','599')
	INTO vCodRet, vMsjRetorno;

	LET cCodRet  = '000004';
	LET cMensajeRet = vMsjRetorno::CHAR(150);
	RETURN cCodRet, cMensajeRet;
END IF
   -- **************************************************
   -- Extrae informacion del Credito *
   -- **************************************************
   
  SELECT a.status_cred, NVL(maes.monto_vencido + maes.mto_venc_trasp,0) As cMtoVenAux
     INTO  CstatusSol, cMtoVen
     FROM sd_maecred a
	 INNER JOIN sd_maesdos maes ON (maes.num_credito = a.num_credito)
    WHERE a.empresa = pEmpresa
      AND a.num_credito = pCredito;

   -- *************************************
   -- AAME INC 27 135 30/10/2019 Extraer si el crédito tiene cheques pendientes de SBC
   -- *************************************
       SELECT COUNT(a.cuenta)
       INTO iTotSBC
       FROM bdicheq:sc_docret_sbc a,
            bdicred:sd_tarjeta b
      WHERE a.siglas = 'SD'
        AND a.cancelado ='T'
        AND b.num_credito = pCredito
        AND a.cuenta = b.num_tarjeta
        AND b.tipo_tarjeta= 'T';
		
	-- *************************************
    -- JRVT INC 04/11/2024 VERIFICA QUE EL CREDITO NO TENGA MSI O CREDISOLUCIONES PENDIENTES PARA HACER EL UPGRADE
	--Estatus Credisoluciones: 0  Pendiente                               
	--Estatus Credisoluciones: 1  Estatus de paso sp_compra_promo         
	--Estatus Credisoluciones: 2  Aperturado / Vigente        
    -- *************************************		
	SELECT COUNT(num_credito) INTO sExistePromo FROM sd_promocion_credito WHERE empresa = '001' and status = '0' AND num_credito = pCredito;
	
	IF NVL(sExistePromo,0) = 0 THEN 
		SELECT COUNT(a.num_credito) INTO sExistePromo 
		FROM sd_promocion_credito a
		INNER JOIN sd_maecredcrd b ON a.empresa = b.empresa AND a.num_sol_prestamo = b.num_credito
		WHERE (a.status IN ('1','2') AND b.status_cred IN ('E1','E2','E3')) AND a.num_credito = pCredito; 
	END IF;  
	
	--VALIDACIONES ANTES DE REPOSICION DE TARJETA
	IF CstatusSol='FF' THEN
		LET cCodRet='000005';
		LET cMensajeRet ='La cuenta se encuentra liquidada, por favor verifique';
		RETURN cCodRet, cMensajeRet;
	--MACM RQM 10 1584 Tarjeta de Credito Infinite
	-- JRVT INC 04/11/2024
	ELIF NVL(sExistePromo,0) > 0 THEN
		LET cCodRet='000006';
		LET cMensajeRet = 'La cuenta tiene credisolucion o msi activa,no se permite Mejora de Producto.';
		RETURN cCodRet, cMensajeRet;
	ELIF (CstatusSol NOT IN ('AA','E1') AND cMtoVen > 0) THEN
		LET cCodRet='000007';
		LET cMensajeRet ='La cuenta no está vigente, favor de ponerse al corriente con pagos.';
		RETURN cCodRet, cMensajeRet;
    ELIF iTotSBC > 0 THEN
        --AAME INC 27 135 30/10/2019 Validacion SBC
        LET cCodRet='000008';
		LET cMensajeRet ='La cuenta tiene un cheque pendiente de cobro SBC';
		RETURN cCodRet, cMensajeRet;	
	END IF;

	RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para validar que el credito se encuentra activo,que no tenga saldo retenido y que no se encuentre vencido,',
'para poder realizar la reposición de su tarjeta',
'desde el de Reposición de Tarjeta',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/03/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_valida_upgrade_web(pEmpresa CHAR(3), pCredito CHAR(20))
RETURNING CHAR(5)    AS codigo_retorno,
          CHAR(150)  AS mensaje_retorno;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(5);
DEFINE cMensajeRet   VARCHAR(150,1);
DEFINE vCodRet 		 CHAR(6);
DEFINE vMsjRetorno   VARCHAR(150,1);
DEFINE scod_ret		 CHAR(6);
DEFINE cod_ret       CHAR(3);
DEFINE cEmpresa      CHAR(3);
DEFINE CstatusSol    CHAR(2);
-- DEFINICION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
DEFINE cCodRetCSG			CHAR(6);
DEFINE cMsjRetCSG			CHAR(80);
DEFINE cNumCreditoCSG		CHAR(20);
DEFINE cCodTCredCSG			CHAR(2);
DEFINE dFechaOrigCSG		DATE;
DEFINE dFechaProxPagCSG 	DATE;
DEFINE dcPagoMinCSG			DECIMAL(18,2);
DEFINE dFechaUltPagCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagRealizadosCSG	INTEGER;
DEFINE dcLinOtorgadaCSG		DECIMAL(18,2);
DEFINE dcTasaInteresCSG		DECIMAL(9,6);
DEFINE dcTasaMoratoriosCSG 	DECIMAL(9,6);
DEFINE dcMontoSbsCSG		DECIMAL(14,2);
DEFINE dcCapVigCSG			DECIMAL(18,2);
DEFINE dcCapTransCSG		DECIMAL(18,2);
DEFINE dcCapVdoExigCSG		DECIMAL(18,2);
DEFINE dcCapVdoNoExigCSG	DECIMAL(18,2);
DEFINE dcSdoActTotCapCSG	DECIMAL(18,2);
DEFINE dcIntVigCSG			DECIMAL(18,2);
DEFINE dcIntVdoCSG			DECIMAL(18,2);
DEFINE dcIntMoratorioCSG	DECIMAL(18,2);
DEFINE dcIntMesCSG			DECIMAL(18,2);
DEFINE dcSodActTotIntCSG	DECIMAL(18,2);
DEFINE dcIvaIntVigCSG		DECIMAL(18,2);
DEFINE dcIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dcIvaIntMorCSG		DECIMAL(18,2);
DEFINE dcIvaIntMesCSG		DECIMAL(18,2);
DEFINE dcSdoActTotIvaCSG	DECIMAL(18,2);
DEFINE dcComPendCSG			DECIMAL(18,2);
DEFINE dcIvaComCSG			DECIMAL(18,2);
DEFINE dcSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dcTotalLiqCSG		DECIMAL(18,2);
DEFINE dcIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcLinDispCSG			DECIMAL(18,2);
DEFINE dcPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqCtaCSG			CHAR(60);
DEFINE cIdCausaBloqCredCSG	CHAR(3);
DEFINE cCausaBloqCtaCSG		CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG 		CHAR(75);
DEFINE vFolio	            CHAR(16);
DEFINE vHoy                 DATE;
DEFINE P_ERROR 				CHAR(5);
DEFINE P_MENSAJE			VARCHAR(100,1);
DEFINE V_CATIVA				DECIMAL(9,6);
DEFINE V_MERCADEO			CHAR(1);
--AAME 31/10/2019 INC 27 135
DEFINE iTotSBC				INTEGER; 

DEFINE cMtoVen				DECIMAL(18,2);
 
DEFINE iupgrade             smallint; 
DEFINE sExistePromo         SMALLINT; 

--JRVT 14/03/2024
DEFINE cIndCierreCheq 		CHAR(1);
DEFINE dFechaIntegral		DATE;
DEFINE dFechaCierrePP		DATE;
DEFINE dFechaHabilAnt		DATE;
DEFINE cCodRet3 			CHAR(5);
DEFINE cStatusCierrePP 		CHAR(1);
--JRVT 14/03/2024

 
---CLONACION DE TDC Oro
LET cMtoVen       = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '00000';
LET cMensajeRet   = 'Se realizÃ³ la consulta correctamente.';
LET vCodRet       = '';
LET vMsjRetorno	  = '';

LET cEmpresa      = '';
LET CstatusSol    = '';
-- INICIALIZACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
LET cCodRetCSG				= '000000';
LET cMsjRetCSG				= '';
LET cNumCreditoCSG			= '';
LET cCodTCredCSG			= '';
LET dFechaOrigCSG			= DATE(1);
LET dFechaProxPagCSG 		= DATE(1);
LET dcPagoMinCSG			= 0.00;
LET dFechaUltPagCSG			= DATE(1);
LET iPlazoCSG				= 0;
LET iPagRealizadosCSG		= 0;
LET dcLinOtorgadaCSG		= 0.00;
LET dcTasaInteresCSG		= 0.00;
LET dcTasaMoratoriosCSG 	= 0.00;
LET dcMontoSbsCSG			= 0.00;
LET dcCapVigCSG				= 0.00;
LET dcCapTransCSG			= 0.00;
LET dcCapVdoExigCSG			= 0.00;
LET dcCapVdoNoExigCSG		= 0.00;
LET dcSdoActTotCapCSG		= 0.00;
LET dcIntVigCSG				= 0.00;
LET dcIntVdoCSG				= 0.00;
LET dcIntMoratorioCSG		= 0.00;
LET dcIntMesCSG				= 0.00;
LET dcSodActTotIntCSG		= 0.00;
LET dcIvaIntVigCSG			= 0.00;
LET dcIvaIntVdoCSG			= 0.00;
LET dcIvaIntMorCSG			= 0.00;
LET dcIvaIntMesCSG			= 0.00;
LET dcSdoActTotIvaCSG		= 0.00;
LET dcComPendCSG			= 0.00;
LET dcIvaComCSG				= 0.00;
LET dcSdoRetenidoCSG		= 0.00;
LET dcTotalLiqCSG			= 0.00;
LET dcIntDevengadoCSG		= 0.00;
LET dcIvaIntDevengadoCSG	= 0.00;
LET dcLinDispCSG			= 0.00;
LET dcPagosVdosCSG			= 0.00;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqCtaCSG				= '';
LET cIdCausaBloqCredCSG		= '';
LET cCausaBloqCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0;
LET cSitEspCredCSG 			= '';
--AAME 31/10/2019 INC 27 135
LET iTotSBC					= 0;


LET iupgrade = 0;
LET sExistePromo = 0;
--JRVT 14/03/2024
LET cIndCierreCheq 		='';
LET dFechaIntegral      = DATE(1);
LET dFechaCierrePP		= DATE(1);
LET dFechaHabilAnt      = DATE(1);
LET cCodRet3			= '00000';
LET cStatusCierrePP		= '';
--JRVT 14/03/2024


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_valida_upgrade.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--JRVT 14/03/2024 SE AGREGA BLOQUE DE VALIDACIÒN PARA NO PERMITIR UPGRADES DURANTE LOS PROCESOS DE CIERRE
SELECT fecha_hoy INTO dFechaIntegral FROM bdinteg:si_fechas;
SELECT max(fecha) INTO dFechaCierrePP FROM sd_contproc WHERE empresa = '001' AND proceso = "CierrePrest";
SELECT status_proc INTO cStatusCierrePP FROM sd_contproc WHERE proceso = "CierrePrest" AND fecha = dFechaCierrePP;
SELECT ind_cierre INTO cIndCierreCheq FROM sd_fechas;

EXECUTE PROCEDURE sp_valfechabil((dFechaIntegral - 1),'-') INTO cCodRet3, dFechaHabilAnt;

IF cIndCierreCheq = '0' OR dFechaCierrePP <> dFechaHabilAnt OR UPPER(cStatusCierrePP) <> 'F' THEN	
	LET cCodRet = '00009';
	LET cMensajeRet = 'Procesos centrales en ejecucion';
	
	RETURN cCodRet, cMensajeRet;
END IF;
--JRVT 14/03/2024 SE AGREGA BLOQUE DE VALIDACIÒN PARA NO PERMITIR UPGRADES DURANTE LOS PROCESOS DE CIERRE

SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' OR TRIM(NVL(pCredito,''))=''    THEN
  LET cCodRet = '00001';
  LET cMensajeRet = 'El parÃ?Â¡metro no es valido';
  RETURN cCodRet, cMensajeRet;
END IF;


-- CONSULTAMOS EL SALDO GENERAL DEL CREDITO.
EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general(TRIM(pEmpresa), TRIM(pCredito))
INTO cCodRetCSG, cMsjRetCSG, cNumCreditoCSG, cCodTCredCSG, dFechaOrigCSG, dFechaProxPagCSG, dcPagoMinCSG, dFechaUltPagCSG, iPlazoCSG, iPagRealizadosCSG, dcLinOtorgadaCSG, dcTasaInteresCSG, dcTasaMoratoriosCSG, dcMontoSbsCSG,
	 dcCapVigCSG, dcCapTransCSG, dcCapVdoExigCSG, dcCapVdoNoExigCSG, dcSdoActTotCapCSG, dcIntVigCSG, dcIntVdoCSG, dcIntMoratorioCSG, dcIntMesCSG, dcSodActTotIntCSG, dcIvaIntVigCSG, dcIvaIntVdoCSG, dcIvaIntMorCSG, dcIvaIntMesCSG,
	 dcSdoActTotIvaCSG, dcComPendCSG, dcIvaComCSG, dcSdoRetenidoCSG, dcTotalLiqCSG, dcIntDevengadoCSG, dcIvaIntDevengadoCSG, dcLinDispCSG, dcPagosVdosCSG, cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqCtaCSG, cIdCausaBloqCredCSG,
	 cCausaBloqCtaCSG, cIdSitEspCteCSG, iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;

IF cCodRetCSG = '000005' THEN -- OCURRIO UN ERROR AL REALIZAR CALCULO
	EXECUTE PROCEDURE bdinteg:sp_desc_ret('06','597')
	INTO vCodRet, vMsjRetorno;
	LET cCodRet  = '00002';
	LET cMensajeRet = vMsjRetorno::CHAR(150);
	RETURN cCodRet, cMensajeRet;
ELIF cCodRetCSG = '000006' THEN -- NO SE ENCONTRO EL FACTOR DE LA COMISION
	EXECUTE PROCEDURE bdinteg:sp_desc_ret('06','598')
	INTO vCodRet, vMsjRetorno;
	LET cCodRet  = '00003';
	LET cMensajeRet = vMsjRetorno::CHAR(150);
	RETURN cCodRet, cMensajeRet;
ELIF cCodRetCSG::INTEGER < 0 THEN -- ERROR NO CONTROLADO EN EL BDICRED:SP_CONSULTA_SALDOS_GENERAL
	EXECUTE PROCEDURE bdinteg:sp_desc_ret('06','599')
	INTO vCodRet, vMsjRetorno;

	LET cCodRet  = '00004';
	LET cMensajeRet = vMsjRetorno::CHAR(150);
	RETURN cCodRet, cMensajeRet;
END IF
   -- **************************************************
   -- Extrae informacion del Credito *
   -- **************************************************
   SELECT a.status_cred, NVL(maes.monto_vencido + maes.mto_venc_trasp,0)
     INTO  CstatusSol, cMtoVen
     FROM sd_maecred a
	 INNER JOIN bdicred:sd_maesdos maes ON (maes.num_credito = a.num_credito)
    WHERE a.empresa = pEmpresa
      AND a.num_credito = pCredito;

   -- *************************************
   -- AAME INC 27 135 30/10/2019 Extraer si el crÃ?Â©dito tiene cheques pendientes de SBC
   -- *************************************
       SELECT COUNT(a.cuenta)
       INTO iTotSBC
       FROM bdicheq:sc_docret_sbc a,
            bdicred:sd_tarjeta b
      WHERE a.siglas = 'SD'
        AND a.cancelado ='T'
        AND b.num_credito = pCredito
        AND a.cuenta = b.num_tarjeta
        AND b.tipo_tarjeta= 'T';
	  
	  
	/*select count(*)
	  into iupgrade
	  from bdicred:sd_credito_upgrade
	 where empresa = '001' 
	   and num_credito = pCredito
	   and num_producto_upgrade = '5400'; */
	   
	-- *************************************
    -- JRVT INC 04/11/2024 VERIFICA QUE EL CREDITO NO TENGA MSI O CREDISOLUCIONES PENDIENTES PARA HACER EL UPGRADE
	--Estatus Credisoluciones: 0  Pendiente                               
	--Estatus Credisoluciones: 1  Estatus de paso sp_compra_promo         
	--Estatus Credisoluciones: 2  Aperturado / Vigente        
    -- *************************************		
	SELECT COUNT(num_credito) INTO sExistePromo FROM sd_promocion_credito WHERE empresa = '001' and status = '0' AND num_credito = pCredito;
	
	IF NVL(sExistePromo,0) = 0 THEN 
		SELECT COUNT(a.num_credito) INTO sExistePromo 
		FROM sd_promocion_credito a
		INNER JOIN sd_maecredcrd b ON a.empresa = b.empresa AND a.num_sol_prestamo = b.num_credito
		WHERE (a.status IN ('1','2') AND b.status_cred IN ('E1','E2','E3')) AND a.num_credito = pCredito; 
	END IF;  
	      
	  
	--VALIDACIONES ANTES DE REPOSICION DE TARJETA
	IF CstatusSol='FF' THEN
		LET cCodRet='00005';
		LET cMensajeRet ='La cuenta se encuentra liquidada, por favor verifique';
		RETURN cCodRet, cMensajeRet;
	--ELIF (dcSdoRetenidoCSG > 0 and iupgrade = 0) OR NVL(sExistePromo,0) > 0 THEN
	ELIF NVL(sExistePromo,0) > 0 THEN
		LET cCodRet='00006';
		LET cMensajeRet = 'La cuenta tiene credisolucion o msi activa,no se permite Mejora de Producto.';
		RETURN cCodRet, cMensajeRet;
	ELIF CstatusSol NOT IN ('AA','E1') AND cMtoVen > 0 THEN
		LET cCodRet='00007';
		LET cMensajeRet ='La cuenta no estÃ?Â¡ vigente, favor de ponerse al corriente con pagos.';
		RETURN cCodRet, cMensajeRet;
    ELIF iTotSBC > 0 THEN
        --AAME INC 27 135 30/10/2019 Validacion SBC
        LET cCodRet='00008';
		LET cMensajeRet ='La cuenta tiene un cheque pendiente de cobro SBC';
		RETURN cCodRet, cMensajeRet;	
	END IF;

	RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para validar que el credito se encuentra activo,que no tenga saldo retenido y que no se encuentre vencido,',
'para poder realizar la reposiciÃ?Â³n de su tarjeta',
'desde el de ReposiciÃ?Â³n de Tarjeta',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/03/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".encabezado2_edocta_bpi(pEmpresa CHAR(3),pNumCredito CHAR(20),pFechaEmision char(10))

RETURNING CHAR(5),          DATE ,    			CHAR(20),    		DECIMAL(14,2),
		                    DECIMAL(14,2),	    DECIMAL(14,2),	    DATE,
		                    DATE,				DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),	    DECIMAL(14,2),		DECIMAL(14,2),
					        DECIMAL(14,2),	    DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		CHAR(560),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),		DATE,			    DATE,
                            CHAR(255),         	DECIMAL(14,2),     	DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),     	DECIMAL(14,2),
                            DECIMAL(14,2),		DECIMAL(14,2),		DECIMAL(14,2), DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err   				SMALLINT;
DEFINE sCodRet   				CHAR(5);

DEFINE v_fecha_emision 			DATE ;
DEFINE v_num_credito 			CHAR(20);

DEFINE v_sdo_pagar 				DECIMAL(14,2);
DEFINE v_sdo_debe 				DECIMAL(14,2);
DEFINE v_sdo_disponible 		DECIMAL(14,2);
DEFINE v_pago_antes_de 			DATE;
DEFINE v_fecha_corte 			DATE;
DEFINE v_usted_debia 			DECIMAL(14,2);
DEFINE v_menos_abonos 			DECIMAL(14,2);
DEFINE v_menos_o_abonos 		DECIMAL(14,2);
DEFINE v_mas_compras 			DECIMAL(14,2);
DEFINE v_mas_o_cargos 			DECIMAL(14,2);
DEFINE v_mas_disp_efectivo 		DECIMAL(14,2);
DEFINE v_mas_intereses 			DECIMAL(14,2);
DEFINE v_mas_iva 				DECIMAL(14,2);
DEFINE v_usted_debe 			DECIMAL(14,2);
DEFINE v_mas_rendimientos 		DECIMAL(14,2);
DEFINE v_mensajes 				CHAR(560);
DEFINE v_capital_tc 			DECIMAL(14,2);
DEFINE v_interes_tc 			DECIMAL(14,2);
DEFINE v_iva_interes_tc 		DECIMAL(14,2);
DEFINE v_capital_ven_tc 		DECIMAL(14,2);
DEFINE v_interes_ven_tc 		DECIMAL(14,2);
DEFINE v_iva_interes_ven_tc 	DECIMAL(14,2);
DEFINE v_moratorios_tc 			DECIMAL(14,2);
DEFINE v_iva_moratorios_tc 		DECIMAL(14,2);
DEFINE v_interes_pago_total_tc	DECIMAL(14,2);
DEFINE v_limite_tc 				DECIMAL(14,2);
DEFINE v_periodo_tc_ini 		DATE;
DEFINE v_periodo_tc_fin 		DATE;
DEFINE v_dias_periodo_tc 		CHAR(255);
DEFINE v_sus_comisiones			DECIMAL(14,2);
--INICIO-----LHM 
DEFINE v_comisiones_iva      	DECIMAL(14,2);
DEFINE v_intereses_iva       	DECIMAL(14,2);
DEFINE v_intereses_pag       	DECIMAL(14,2);
DEFINE v_saldos_menos_pag    	DECIMAL(14,2);
DEFINE v_compras_disp        	DECIMAL(14,2);
--FIN--------LHM
DEFINE v_saldo_diferido      	DECIMAL(14,2);
DEFINE V_saldo_total         	DECIMAL(14,2);

DEFINE cCodRetSp			    CHAR(5);
DEFINE v_saldo_corte			DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   				= 0;
LET sCodRet  				= '000';

LET v_fecha_emision 		= " ";
LET v_num_credito 			= "";

LET v_sdo_pagar 			= 0;
LET v_sdo_debe 				= 0;
LET v_sdo_disponible 		= 0;
LET v_pago_antes_de 		= " ";
LET v_fecha_corte 			= " ";
LET v_usted_debia 			= 0;
LET v_menos_abonos 			= 0;
LET v_menos_o_abonos 		= 0;
LET v_mas_compras 			= 0;
LET v_mas_o_cargos 			= 0;
LET v_mas_disp_efectivo 	= 0;
LET v_mas_intereses 		= 0;
LET v_mas_iva 				= 0;
LET v_usted_debe 			= 0;
LET v_mas_rendimientos 		= 0;
LET v_mensajes 				= "";
LET v_capital_tc 			= 0;
LET v_interes_tc 			= 0;
LET v_iva_interes_tc 		= 0;
LET v_capital_ven_tc 		= 0;
LET v_interes_ven_tc 		= 0;
LET v_iva_interes_ven_tc 	= 0;
LET v_moratorios_tc 		= 0;
LET v_iva_moratorios_tc 	= 0;
LET v_interes_pago_total_tc = 0;
LET v_limite_tc 			= 0;
LET v_periodo_tc_ini 		= " ";
LET v_periodo_tc_fin 		= " ";
LET v_dias_periodo_tc 		= "";
LET v_sus_comisiones		= 0;
--INICIO-----LHM 
LET v_comisiones_iva     	= 0;
LET v_intereses_iva      	= 0;
LET v_intereses_pag      	= 0;
LET v_saldos_menos_pag   	= 0;
LET v_compras_disp       	= 0;
LET v_saldo_diferido     	= 0;
LET V_saldo_total        	= 0;

LET cCodRetSp 			 	= '00000';
LET v_saldo_corte 	 		= 0;

--SET DEBUG FILE TO "/informix/Raldn/BPI/ConstaMovCrd/SP_mod/encabezado2_edocta.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
BEGIN

		ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, 
				nvl(v_fecha_emision,date(1)),NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				nvl(v_fecha_corte,date(1)),				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0),		NVL(v_saldo_diferido,0),			NVL(v_saldo_total,0), NVL(v_saldo_corte,0);
     END EXCEPTION ;

	EXECUTE PROCEDURE "informix".sp_consultasaldocorte(pEmpresa, pNumCredito , 0)
	INTO cCodRetSp, v_saldo_corte;
	
	IF (cCodRetSp <> '00000' OR v_saldo_corte IS NULL)THEN
	LET sCodRet = '002';
	RETURN sCodRet, 
				nvl(v_fecha_emision,date(1)), NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				nvl(v_fecha_corte,date(1)),	NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),				NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0), 	    NVL(v_saldo_diferido,0),			NVL(v_saldo_total,0), NVL(v_saldo_corte,0);
	END IF;
	
  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
	SELECT		fecha_emision,		   num_credito,				sdo_pagar,
				sdo_debe,			   sdo_disponible,			pago_antes_de,
				fecha_corte,		   usted_debia,				menos_abonos,
				menos_o_abonos,		   mas_compras,				mas_o_cargos,
				mas_disp_efectivo,	   mas_intereses,			mas_iva,
				usted_debe,			   mas_rendimientos,		capital_tc,
				interes_tc,			   iva_interes_tc,			capital_ven_tc,
				interes_ven_tc,		   iva_interes_ven_tc,		moratorios_tc,	
				iva_moratorios_tc,	   interes_pago_total_tc,	limite_tc,			  
				periodo_tc_ini,		   periodo_tc_fin,			dias_periodo_tc,
				sus_comisiones,        comisiones_iva,          intereses_iva,
				intereses_pag,         saldo_menos_pag,         compras_disp,
				saldo_diferido,		   saldo_total
	INTO		v_fecha_emision,	   v_num_credito,			v_sdo_pagar,
				v_sdo_debe,			   v_sdo_disponible,		v_pago_antes_de,
				v_fecha_corte,		   v_usted_debia,			v_menos_abonos,
				v_menos_o_abonos,	   v_mas_compras,			v_mas_o_cargos,
				v_mas_disp_efectivo,   v_mas_intereses,			v_mas_iva,
				v_usted_debe,		   v_mas_rendimientos,		v_capital_tc,
				v_interes_tc,		   v_iva_interes_tc,		v_capital_ven_tc,
				v_interes_ven_tc,	   v_iva_interes_ven_tc,	v_moratorios_tc,
				v_iva_moratorios_tc,   v_interes_pago_total_tc,	v_limite_tc,
				v_periodo_tc_ini,	   v_periodo_tc_fin,		v_dias_periodo_tc,
				v_sus_comisiones,      v_comisiones_iva,        v_intereses_iva, 
				v_intereses_pag,       v_saldos_menos_pag,	    v_compras_disp,
				v_saldo_diferido,	   v_saldo_total

	 --FROM bdicred:sd_encabezado2_edocta
	 FROM bdicred@pld_tcp:sd_encabezado2_edocta
	 WHERE fecha_emision = pFechaEmision 
	 		AND num_credito = pNumCredito;

	IF v_num_credito IS NULL THEN
		LET sCodRet = "185";
      RETURN sCodRet, 
				nvl(v_fecha_emision,date(1)),NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				nvl(v_fecha_corte,date(1)),				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0),		NVL(v_saldo_diferido,0),			NVL(v_saldo_total,0), NVL(v_saldo_corte,0);
	END IF

  RETURN sCodRet, 
				v_fecha_emision,			NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				v_fecha_corte,				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0),		NVL(v_saldo_diferido,0),			NVL(v_saldo_total,0), NVL(v_saldo_corte,0);

END;

END PROCEDURE 
DOCUMENT 
"Version 1.00.003",
"Se modifica para retornar saldo al corte.",
"ModificÃ³ : MoisÃ©s Soriano",
"Fecha : 15-06-2015",
"BD    : bdicred";

CREATE PROCEDURE "informix".sp_consultadetallesolicitudmc( pFechaInicio CHAR(10), pFechaFin CHAR(10), pProducto CHAR(4) )
RETURNING
	CHAR(6) AS CodRet, 
	CHAR(20) AS NumSolicitud, 
	CHAR(4) AS Sucursal, 
	VARCHAR(100) AS NombreCte, 
	DATE AS Fechasol, 
	DATE AS Fechacambio,
	CHAR(2) AS Revaluada,
	CHAR(20) AS Referenciacoppel,
	DECIMAL(18,2) AS Eficienciacoppel,
	SMALLINT AS Mesescoppel,
	DECIMAL(18,2) AS Vencidocoppel,
	INTEGER AS Vencidocoppeludis,
	CHAR(2) AS Puntualidad,
	INTEGER AS Scoring1,
	INTEGER AS Scoring2,
	CHAR(40) AS DescStatus,
	CHAR(3) AS CausaSolic,
	VARCHAR(100) AS Comentario,
	CHAR(45) AS Analista,
	CHAR(10) AS Tipo_movto,
	CHAR(50) AS Producto; 
	
	
---DECLARACIONES
DEFINE cCodRet			CHAR(6);
DEFINE cCodRetUDI		CHAR(6);
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);

-- VARIABLES DEL PROCESO
DEFINE cNumSolicitud		CHAR(20);
DEFINE cNumcte			CHAR(20);
DEFINE cSucursal			CHAR(4);
DEFINE vNomCte				VARCHAR(100);
DEFINE dFechasol			DATE;
DEFINE dFechacambio			DATE;
DEFINE cRevaluada			CHAR(2);
DEFINE cReferenciacoppel	CHAR(20);
DEFINE dcEficienciacoppel	DECIMAL(18,2);
DEFINE sMesescoppel			SMALLINT;
DEFINE dcVencidocoppel		DECIMAL(18,2);
DEFINE dcVencidoCoppelUDIS	DECIMAL(25,2);
DEFINE cPuntualidad			CHAR(2);
DEFINE iScoring1			INTEGER;
DEFINE iScoring2			INTEGER;

DEFINE cStatusFin			CHAR(2);
DEFINE cEjecutivoAtiende	CHAR(8);
DEFINE cDescStatus			CHAR(40);
DEFINE cCausaSolic			CHAR(3);
DEFINE vComentario			VARCHAR(100);
DEFINE cAnalista			CHAR(45);
DEFINE cNombreProducto 		CHAR(50);
DEFINE cTipoMovto 		CHAR(10);
DEFINE dcValorUDI			DECIMAL(14,6);

-- INICIALIZACIONES
LET cCodRet				= '00000';
LET cCodRetUDI			= '00000';
LET iSqlErr				= 0;
LET iSamErr				= 0;
LET cErrorInfo			= '';

-- INICIALIZACIÃN DE VARIABLES DEL PROCESO.
LET cNumSolicitud		= '';
LET cNumcte		= '';
LET cSucursal			= '';
LET vNomCte				= '';
LET dFechasol			= DATE(1);
LET dFechacambio		= DATE(1);
LET cRevaluada			= 'NO';
LET cReferenciacoppel	= '';
LET dcEficienciacoppel	= 0.00;
LET sMesescoppel		= 0;
LET dcVencidocoppel		= 0.00;
LET dcVencidoCoppelUDIS	= 0.00;
LET cPuntualidad		= '';
LET iScoring1			= 0;
LET iScoring2			= 0;
LET cStatusFin			= '';
LET cEjecutivoAtiende	= '';
LET cDescStatus			= '';
LET cCausaSolic			= '';
LET vComentario			= '';
LET cAnalista			= '';
LET cNombreProducto		= '';
LET cTipoMovto		= '';
LET dcValorUDI			= 0.00;
	
BEGIN

	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr::CHAR(8);
		    RETURN cCodRet, NVL(TRIM(cNumSolicitud), ''), NVL(TRIM(cSucursal), ''), NVL(TRIM(vNomCte), ''), NVL(dFechasol, DATE(1)), NVL(dFechacambio, DATE(1)),
				   NVL(TRIM(cRevaluada), ''), NVL(TRIM(cReferenciacoppel), ''), NVL(dcEficienciacoppel, 0.00), NVL(sMesescoppel, 0), 
				   NVL(dcVencidocoppel, 0.00), NVL(dcVencidoCoppelUDIS, 0), NVL(TRIM(cPuntualidad), ''), NVL(iScoring1, 0), NVL(iScoring2, 0), 
				   NVL(TRIM(cDescStatus), ''), NVL(TRIM(cCausaSolic), ''), NVL(TRIM(vComentario), ''), NVL(TRIM(cAnalista), ''), cTipoMovto,NVL(TRIM(cNombreProducto), '');
		END IF;
	END EXCEPTION; 
	
	--SET DEBUG FILE TO "/home/e10000315/sp_consultadetallesolicitudmc.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF NVL(pFechaInicio::DATE, "") = "" OR NVL(pFechaFin::DATE, "") = "" THEN
		LET cCodRet = "00001"; -- PARAMETROS OBLIGATORIOS.
	ELIF CAST(NVL(pFechaInicio, "") AS DATE) > CAST(NVL(pFechaFin, "") AS DATE) THEN
		LET cCodRet = "00002"; -- FECHA INICIAL NO DEBE SER MAYOR A LA FECHA FINAL.
	END IF
	
	IF cCodRet = '00000' THEN
	
		IF NVL(pProducto,"") <> "" THEN
			-- OBTENEMOS EL NOMBRE DEL PRODUCTO QUE ESTAMOS CONSULTANDO.
			SELECT nombre_prod INTO cNombreProducto FROM "informix".sd_definicion WHERE num_producto  = pProducto ;
		END IF
		CALL "informix".determina_udi("001", TODAY) RETURNING cCodRetUDI, dcValorUDI;
		-- CALCULAMOS EL VALOR DE LAS UDI AL DIA ACTUAL.
		-- CONSULTAMOS EL DETALLE DE TODAS LAS SOLICITUDES QUE FUERON ANALIZADAS POR MESA DE CONTROL.
		FOREACH WITH HOLD
				
			SELECT numcte,fecha_insert,num_solicitud,sucursal,fecha_determinacion ,status_fin, ejecutivo_atiende,DECODE(tipo_movimiento,'M','MIXTO','U','UNICO','UNICO'),DECODE(revalua,'S','SI','N','NO','NO')
				INTO  cNumcte,dFechasol,cNumSolicitud, cSucursal,  dFechacambio,  cStatusFin, cEjecutivoAtiende,cTipoMovto,cRevaluada
			FROM bdisolic:"informix".ss_solicitudes_mc mc				
			WHERE mc.num_producto = CASE WHEN NVL(pProducto,'') = '' THEN mc.num_producto ELSE pProducto END 	
			  AND mc.fecha_insert >= pFechaInicio::DATE
			  AND mc.fecha_insert <= pFechaFin::DATE			 
			  AND mc.ejecutivo_autoriza <> ''
			  ORDER BY numcte
				
			
			SELECT  situacion_pago , meses_historia , (vencidoropa + vencidomuebles + vencidoprestamos), puntualidad
				INTO dcEficienciacoppel, sMesescoppel, dcVencidocoppel,	 cPuntualidad
			FROM bdisolic:"informix".ss_resum_scor_fin 
			WHERE empresa =  '001'
			AND num_solicitud = cNumSolicitud;		

			
			SELECT numcte_ref ,TRIM(NVL(cte.nombre1,''))||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno)
				INTO cReferenciacoppel,vNomCte
			FROM bdinteg:"informix".si_cliente cte 
			WHERE empresa = '001'
			AND numcte = cNumcte;
			
			SELECT SUM(CASE WHEN  seccion = 1 THEN  evaluacion ELSE 0 END) ,
				   SUM(CASE WHEN  seccion = 2 THEN  evaluacion ELSE 0 END) 				   
				INTO iScoring1, iScoring2
			FROM bdisolic:"informix".ss_resumen_scoring 
			WHERE num_solicitud = cNumSolicitud;
			
			
			-- OBTENEMOS EL VALOR DEL "MOTIVO DE RECHAZO/CANCELACION" Y "JUSTIFICACIONES".
			
			
			SELECT  LIMIT 1 causa_solicitud,comentario
				INTO cCausaSolic, vComentario
			FROM bdisolic:"informix".ss_autorizacion_especial
			WHERE num_solicitud = cNumSolicitud
			AND status_ant = "MC"
			AND status_nvo = cStatusFin;
					  
				IF 	cCausaSolic is null AND vComentario is null THEN
					SELECT  LIMIT 1 causa_solicitud,comentario
						INTO cCausaSolic, vComentario
					FROM bdisolic:"informix".ss_autorizacion_especial
					WHERE num_solicitud = cNumSolicitud
					AND status_ant = "MC"
					AND secuencia= (SELECT MAX(secuencia)
                                         FROM bdisolic:ss_autorizacion_especial 
                                         WHERE empresa='001' AND num_solicitud = cNumSolicitud AND status_ant = "MC");
				END IF;
			

            --LET dcVencidoCoppelUDIS = CASE WHEN dcValorUDI <= 0 THEN 0 ELSE dcVencidocoppel / dcValorUDI END;								  
			IF cStatusFin = "RT" AND cCausaSolic IN ('RBE','RCE','RCZ','RSE') THEN
				LET cDescStatus = "RECHAZO";
			ELIF cStatusFin = "CM" THEN
				LET cDescStatus = "CANCELADO";
			ELSE
				LET cDescStatus = "SIGUE PROCESO";
			END IF;
			
			
			-- OBTENEMOS EL NOMBRE DEL ANALISTA MC
			SELECT nombre INTO cAnalista
			FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = TRIM(cEjecutivoAtiende);
			
			RETURN cCodRet, NVL(TRIM(cNumSolicitud), ''), NVL(TRIM(cSucursal), ''), NVL(TRIM(vNomCte), ''), NVL(dFechasol, DATE(1)), NVL(dFechacambio, DATE(1)),
				   NVL(TRIM(cRevaluada), ''), NVL(TRIM(cReferenciacoppel), ''), NVL(dcEficienciacoppel, 0.00), NVL(sMesescoppel, 0), 
			       NVL(dcVencidocoppel, 0.00), NVL(dcVencidoCoppelUDIS, 0), NVL(TRIM(cPuntualidad), ''), NVL(iScoring1, 0), NVL(iScoring2, 0), 
			       NVL(TRIM(cDescStatus), ''), NVL(TRIM(cCausaSolic), ''), NVL(TRIM(vComentario), ''), NVL(TRIM(cAnalista), ''), cTipoMovto,NVL(TRIM(cNombreProducto), '') WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00003'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.
		END IF
		
	END IF
	
	IF cCodRet <> '00000' THEN
	   RETURN cCodRet, NVL(TRIM(cNumSolicitud), ''), NVL(TRIM(cSucursal), ''), NVL(TRIM(vNomCte), ''), NVL(dFechasol, DATE(1)), NVL(dFechacambio, DATE(1)),
		      NVL(TRIM(cRevaluada), ''), NVL(TRIM(cReferenciacoppel), ''), NVL(dcEficienciacoppel, 0.00), NVL(sMesescoppel, 0), 
			  NVL(dcVencidocoppel, 0.00), NVL(dcVencidoCoppelUDIS, 0), NVL(TRIM(cPuntualidad), ''), NVL(iScoring1, 0), NVL(iScoring2, 0), 
			  NVL(TRIM(cDescStatus), ''), NVL(TRIM(cCausaSolic), ''), NVL(TRIM(vComentario), ''), NVL(TRIM(cAnalista), ''),cTipoMovto, NVL(TRIM(cNombreProducto), '');
	END IF
	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera un reporte del detalle de todas las solicitudes de credito que fueron analizadas por mesa de control Estatus = MC',
'FECHA: 13/Diciembre/2012',
'BD: bdicred',
'AUTOR: Valentin Lopez';

CREATE PROCEDURE "informix".sp_depura_sd_amortiza_3()
RETURNING 
CHAR(6),     -- codigo de retorno
CHAR(150);   -- mensaje

-- Modificacion -> Se hardcodea la fecha por motivo de que no corre con la variable dFechaDepura

DEFINE cCodRet      CHAR(6); 
DEFINE cMensaje     CHAR(150); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE Error_Info   VARCHAR(80);
DEFINE dFechaDepuraFin DATE;
DEFINE sHoraInicial	SMALLINT;
DEFINE sHoraFinal	SMALLINT;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE sHorasProceso	SMALLINT;
DEFINE iCuentasProcesadas	INTEGER;
DEFINE iCount_sd_amortiza_credito_old	INTEGER;
DEFINE cProceso		CHAR(04);
DEFINE P_COD_RET    	VARCHAR(6);
DEFINE dFechaCuota	DATE;
DEFINE cTerminaProceso	CHAR(1);
DEFINE limite INTEGER; -- CAX MARZO 2024
DEFINE vContadorCommit INTEGER;

LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
LET dFechaDepuraFin = date(1);
LET sHoraInicial = 0;
LET sHoraFinal	 = 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET sHorasProceso	= 0;
LET iCuentasProcesadas	= 0;
LET iCount_sd_amortiza_credito_old	= 0;
LET cProceso		= '0007';
LET P_COD_RET   	= '000000';
LET dFechaCuota	= date(1);
LET cTerminaProceso = '0';
LET limite = 1;
LET vContadorCommit = 0;
										 

-- SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;	
            LET cMensaje = 'Error --> '||Error_Info||'	'||vNumCred;
			CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;			
            RETURN cCodRet,cMensaje;
        END IF;
    END EXCEPTION;

	-- SET DEBUG FILE TO '/ifxsif01/ciaguilar/Depuracion/sp_depura_amortiza_3/sp_depura_sd_amortiza_3.out';
	-- TRACE ON;

    CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET cHoraInicial = CURRENT HOUR TO SECOND;
	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);
	
    SELECT num_credito
    INTO vNumCredAux
    FROM "informix".sd_param_movhis_dep
    where proceso = 12;

    IF vNumCredAux = '' OR vNumCredAux IS NULL THEN 
       --LET vNumCredAux = '0'; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(12,'0');
    END IF;

--   select fecha_insert
--   into dFechaDepura
--   from sd_param
--   where empresa = '001'
--   and cod_param = '800'; 
	
	SELECT valor::DATE 
	INTO dFechaDepuraFin
	FROM "informix".sd_param 
	WHERE empresa 	= '001' 
	AND cod_param	= '115';

    IF dFechaDepuraFin IS NULL THEN
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
		VALUES('001', '115', 'FECHA DEPURACION AMORTIZA_CREDITO CUENTAS ACTIVAS', '12/31/2023', user, TODAY);
			
		--LET dFechaDepura = mdy('12','31','2018');
	END IF;

	SELECT valor
    INTO sHorasProceso
    FROM "informix".sd_param
    WHERE cod_param = '116';

	IF sHorasProceso IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
		VALUES('001', '116', 'PARAMETRO DE HORAS A PROCESAR CUENTAS ACTIVAS', '5', user, TODAY);

		--LET sHorasProceso = 5;
    END IF;
	
	SELECT valor::INTEGER
    INTO limite
    FROM "informix".sd_param
    WHERE cod_param = '147';

    IF limite IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
		VALUES('001', '147', 'LIMITE DE REGISTROS A DEPURAR EN SP sp_depura_sd_amortiza_3', '3000000', user, TODAY);	
	
	END IF; 
	
/*  SELECT num_credito
    FROM "informix".sd_maecred
    WHERE empresa  = '001' 
    AND num_credito > vNumCredAux
	AND status_cred IN ('AA','BA','BT')*/

/*	SELECT a.num_credito,c.fecha_cuota
	FROM bdicred:sd_maecred a
	INNER JOIN bdicred:sd_amortiza_credito c ON c.empresa = a.empresa AND c.num_credito = a.num_credito AND c.fecha_cuota >= mdy('01','01','2021') AND c.fecha_cuota <= mdy('03','31','2021')
	AND c.capital_status IN ('1','5')
	WHERE a.empresa='001'
	AND a.num_credito >= (SELECT num_credito FROM bdicred:sd_param_movhis_dep where proceso = 12)
	INTO TEMP cuentas_activas WITH NO LOG;
		
	UPDATE STATISTICS MEDIUM FOR TABLE cuentas_activas;*/
	
	SELECT limit limite a.num_credito,c.fecha_cuota
	FROM bdicred:sd_maecred a
	INNER JOIN bdicred:sd_amortiza_credito c ON c.num_credito = a.num_credito
	WHERE  c.fecha_cuota <= dFechaDepuraFin
	AND c.capital_status IN ('1','5')
	AND c.empresa='001'
	INTO temp sd_universo_depura with no log;
	
	CREATE INDEX idx_temp_unidep on sd_universo_depura(num_credito, fecha_cuota);
	
	FOREACH WITH HOLD	
		SELECT num_credito,fecha_cuota
		INTO vNumCred,dFechaCuota
		from sd_universo_depura
--		AND a.num_credito >= (SELECT num_credito FROM bdicred:sd_param_movhis_dep where proceso = 12)
--		ORDER BY num_credito,fecha_cuota ASC

/*		SELECT TRIM(num_credito),fecha_cuota
           INTO vNumCred,dFechaCuota 
        FROM cuentas_activas
		ORDER BY num_credito,fecha_cuota ASC*/

		IF vContadorCommit = 0 THEN
			BEGIN WORK;
		END IF;
		
		LET iCuentasProcesadas = iCuentasProcesadas + 1;
	   
        insert into "informix".sd_amortiza_credito_old
        select *
		--select empresa, num_credito, fecha_cuota, tipo_cuota, capital_mto_cuota, capital_debe, capital_pagado, capital_status, capital_status_ant, capital_fecha_pago, interes_debe, interes_pagado, interes_status, interes_status_ant, interes_fecha_pago, iva_debe, iva_pagado, iva_status, iva_status_ant, iva_fecha_pago, mora_provi_ordi, mora_provi_cope, mora_sdo_ordi, mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag, mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado, mora_iva_status, mora_iva_fecha_pago, num_pago, campo_trabajo1, campo_trabajo2, campo_trabajo3, campo_trabajo4
		from "informix".sd_amortiza_credito
        where empresa = '001'
        and num_credito = vNumCred
        and fecha_cuota = dFechaCuota;

        DELETE FROM "informix".sd_amortiza_credito
        where empresa = '001'
        and num_credito = vNumCred
        and fecha_cuota = dFechaCuota;

		LET iCount_sd_amortiza_credito_old	= iCount_sd_amortiza_credito_old + 1;
		LET vContadorCommit = vContadorCommit+1;	
		
		UPDATE "informix".sd_param_movhis_dep
		SET num_credito = vNumCred
		where proceso = 12;

        IF vContadorCommit = 1000 then
			COMMIT WORK; 
			LET vContadorCommit = 0;
		END IF;

		--SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;
		LET cHoraFinal = CURRENT HOUR TO SECOND;
		
		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
			LET cTerminaProceso = '1';
			EXIT FOREACH;
		END IF;
		
    END FOREACH;

	IF vContadorCommit > 0 then
		COMMIT WORK; 
	END IF;
	
	IF cTerminaProceso = '0' THEN
		UPDATE bdicred:sd_param_movhis_dep
		SET num_credito = '0'
		WHERE proceso = 12;
	END IF;

--	DROP TABLE cuentas_activas;

	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_amortiza_credito_old : ' ||iCount_sd_amortiza_credito_old;
	CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = 'Proceso de depuracion exitoso.Cuentas procesadas ' || iCuentasProcesadas;

	CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;
	
    RETURN cCodRet,cMensaje;

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se agrega fecha y numero de registros limite para la depuracion de la tabla sd_amortiza_credito',
'FECHA : ABRIL/2024',
'BD: bdicred',
'AUTOR : Cinthia Aguilar',
'DESCRIPCION: Se optimiza consulta que obtiene el universo y se controla COMMIT',
'FECHA : MAYO/2024',
'BD: bdicred',
'AUTOR : Cinthia Aguilar',
'DESCRIPCION: Se modifica tabla de respaldo por ',
'FECHA : FEBRERO/2025',
'BD: bdicred',
'AUTOR : Cinthia Aguilar'
;

CREATE PROCEDURE "informix".sp_reduccion_linea_ina(p_empresa CHAR(3),p_fecha DATE)
RETURNING CHAR(6),CHAR (100);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************


DEFINE v_cod_ret			CHAR(6);
DEFINE vsqlerr				INTEGER;
DEFINE v_Mensaje			CHAR(100);
DEFINE vcod_retred			CHAR(10);
DEFINE v_Mensajered			CHAR(100);
DEFINE vcod_retinc			CHAR(10);
DEFINE v_Mensajeinc			CHAR(100);
DEFINE iMes_Incremento_linea			SMALLINT;
DEFINE iMes_Movimiento_linea			SMALLINT;
DEFINE iMes_Reduccion_linea	   		 	SMALLINT;
DEFINE iMes_Apertura_linea	            SMALLINT;

--- Reduccion

DEFINE p_fecha_consulta_red DATE;
DEFINE v_num_credito		CHAR(20);
DEFINE v_gpo_testigo		INTEGER;
DEFINE v_monto				DECIMAL(14,2);
DEFINE v_alta				DATE;
DEFINE v_fecha_ult_pago		DATE;
DEFINE v_primer_compra		DATE;
DEFINE v_primer_disp		DATE;
DEFINE v_atm_disp_fecha		DATE;
DEFINE v_fecha_ultima_compra	DATE;
DEFINE v_vnt_disp_fecha		DATE;
DEFINE v_fechaultimocambio	DATE;
DEFINE v_fecha_actualiza	DATE;

DEFINE v_meses				INTEGER;
DEFINE v_bcscore			DECIMAL(14,2);
DEFINE VNuevaLinea			DECIMAL(10,2);
DEFINE v_rango				CHAR(20);
DEFINE v_monto_actual		DECIMAL(14,2);
DEFINE v_ajuste_montored	DECIMAL(14,2);
DEFINE v_num_producto		CHAR(4);
DEFINE v_divisared			CHAR(2);
DEFINE v_sucursalred		CHAR(4);
DEFINE v_numcte				CHAR(20);
DEFINE contador_commit 	    INTEGER; 
DEFINE sCommit         		SMALLINT;
DEFINE v_tp_proceso			CHAR(1);

DEFINE pNumTran				CHAR(4);

--- Incremento 50 %

DEFINE p_fecha_rango_inc 	DATE;
DEFINE p_fecha_rango_fin 	DATE;
DEFINE v_num_credito_inc	CHAR(20);
DEFINE v_linea_original		DECIMAL(10,2);
DEFINE vpago_consecutivo	INTEGER;
DEFINE v_param_incremento	DECIMAL (4,2);
DEFINE v_rango_inc			CHAR(20);
DEFINE VNuevaLineaInc		DECIMAL(10,2);
DEFINE v_monto_actual_inc	DECIMAL(10,2);
DEFINE v_ajuste_monto_inc	DECIMAL(10,2);
DEFINE v_productoinc		CHAR(4);
DEFINE v_divisainc			CHAR(2);
DEFINE v_sucursalinc		CHAR(4);

------- Reporte

DEFINE sFechaArch			CHAR(10);
DEFINE sFechaArch2			CHAR(10);
DEFINE v_sepa               CHAR(2);
DEFINE sMes					CHAR(2);
DEFINE sYear				CHAR(4);
DEFINE v_sql				CHAR(250);
DEFINE v_sql2				CHAR(250);
DEFINE cRuta				CHAR(100);

DEFINE periodo1				DATE;
DEFINE periodo2				DATE;
DEFINE r_numcte				CHAR(20);
DEFINE r_num_credito		CHAR(20);
DEFINE r_describe_mov		CHAR(50);
DEFINE r_fecha_insert		DATE;
DEFINE r_total_mov			DECIMAL(10,2);
DEFINE r_linea_original		DECIMAL(10,2);
DEFINE r_linea_nueva		DECIMAL(10,2);
DEFINE r_fecha_marca		DATE;
DEFINE r_meses_ina 			DATE;
DEFINE r_bc_score			DECIMAL(14,2);
DEFINE r_descripcion		CHAR (50);
DEFINE r_fecha_facturacion	DATE;


DEFINE dFechaHoy			DATE;
DEFINE dFechaMes			DATE;
DEFINE dFechaInc			DATE;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************


LET v_cod_ret				= "000000";
LET vsqlerr					= 0;
LET v_Mensaje				= "";
LET vcod_retred				= "000";
LET v_Mensajered			= "";
LET vcod_retinc				= "000";
LET v_Mensajeinc			= "";
LET iMes_Incremento_linea	=0;
LET iMes_Movimiento_linea	=0;
LET iMes_Reduccion_linea	=0;
LET iMes_Apertura_linea		=0;

LET p_fecha_consulta_red	= DATE(1);
LET v_num_credito			= "";
LET v_gpo_testigo			= 0;
LET v_monto					= 0;
LET v_alta					= DATE(1);
LET v_fecha_ult_pago		= DATE(1);
LET v_primer_compra			= DATE(1);
LET v_primer_disp			= DATE(1);
LET v_atm_disp_fecha		= DATE(1);
LET v_fecha_ultima_compra	= DATE(1);
LET v_vnt_disp_fecha		= DATE(1);
LET v_fechaultimocambio		= DATE(1);
LET v_fecha_actualiza		= DATE(1);
LET v_meses					= 0;
LET v_bcscore				= 0;
LET VNuevaLinea				= 0;
LEt v_rango					= "";
LET v_monto_actual			= 0;
LET v_ajuste_montored		= 0;
LET v_num_producto			= "";
LET v_divisared				= "";
LET v_sucursalred			= "";
LET v_numcte				= "";
LET contador_commit			= 0;
LET sCommit                 = 0;
LET v_tp_proceso			= "";

LET p_fecha_rango_inc		= DATE(1);
LET p_fecha_rango_fin		= DATE(1);
LET v_num_credito_inc		= "";
LET v_linea_original		= 0;
LET vpago_consecutivo		= 0;
LET v_param_incremento		= 0;
LET v_rango_inc				= "";
LET VNuevaLineaInc			= 0;
LET v_monto_actual_inc		= 0;
LET v_ajuste_monto_inc		= 0;
LET v_productoinc			= 0;
LET v_divisainc				= 0;
LET v_sucursalinc			= 0;

LET pNumTran				= '0000';

------- Reporte

LET periodo1				= DATE(1);
LET periodo2				= DATE(1);
LET sFechaArch				= "";
LET v_sepa                 	= '\|';
LET sMes					= "";
LET sYear					= "";
LET v_sql					= "";
LET v_sql2					= "";
LET cRuta		 			= "/RESPALDOSNEW/";
--LET cRuta					= "/informix/Israel/";

LET r_numcte				= "";
LET r_num_credito			= "";
LET r_describe_mov			= "";
LET r_fecha_insert			= DATE(1);
LET r_total_mov				= 0;
LET r_linea_original		= 0;
LET r_linea_nueva			= 0;
LET r_fecha_marca			= DATE(1);
LET r_meses_ina				= DATE(1);
LET r_bc_score				= 0;
LET r_descripcion			= "";
LET r_fecha_facturacion		= DATE(1);


LET dFechaHoy			= date(1);
LET dFechaMes			= date(1);
LET dFechaInc			= date(1);
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************


BEGIN
	ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
		LET v_cod_ret=vsqlerr;
		LET v_Mensaje = "";
		IF (sCommit = -1) THEN
                rollback work;
        END IF;
		RETURN v_cod_ret,v_Mensaje;	
	END IF;
	END EXCEPTION;   
	
--SET DEBUG FILE TO "/informix/Israel/sp_reduccion_linea_ina.out";
--TRACE ON;
	
	--SET DEBUG FILE TO "/home/e_vvalen/sp_reduccion_linea_ina.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
		-- Lectura de parametros 
	SELECT valor::SMALLINT INTO iMes_Incremento_linea FROM bdicred:sd_param	WHERE cod_param = '155';		-- NÃºmero de mÃ©ses con Incrementos en los Ãºltimos 9999 meses
	SELECT valor::SMALLINT INTO iMes_Movimiento_linea FROM bdicred:sd_param WHERE cod_param = '156';		-- Movimientos de disposiciones o compras en los Ãºltimos 9999 meses
	SELECT valor::SMALLINT INTO iMes_Reduccion_linea FROM bdicred:sd_param WHERE cod_param = '157';			-- Reducciones de lÃ­nea en los Ãºltimos 9999 meses
	SELECT valor::SMALLINT INTO iMes_Apertura_linea FROM bdicred:sd_param WHERE cod_param = '158';			-- Fecha de apertura del crÃ©dito sea mayor a 9999 meses

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

	--- Obtiene la fecha de 9999 meses menos
	LET p_fecha_consulta_red =  ADD_MONTHS (p_fecha, -iMes_Apertura_linea);
	
	CREATE temp TABLE fecha_actual ( num_credito char(20), meses integer) with no log;
	CREATE INDEX fecha_inx_actual ON fecha_actual(num_credito,meses);
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".fecha_actual;

	CREATE temp TABLE creditos_reduccion ( num_credito char(20),numcte char(20),num_producto CHAR (4),monto DECIMAL(14,2), fecha_ultimo_pago date,f_primer_compra DATE,f_primer_disp DATE,atm_disp_fecha DATE,fecha_ultima_compra DATE,vnt_disp_fecha DATE,fechaultimocambio DATE,fecha_alta DATE) with no log; 
    CREATE UNIQUE INDEX creditos_reduccion_inx ON creditos_reduccion(num_credito,fecha_ultimo_pago,f_primer_compra,f_primer_disp,atm_disp_fecha,fecha_ultima_compra,vnt_disp_fecha,fechaultimocambio,fecha_alta );
	
	Insert into creditos_reduccion
		SELECT 	sdo.num_credito,
				cred.numcte,
				cred.num_producto,
				sdo.monto_otorgado,
				ind.fecha_ultimo_pago,
				ind.f_primer_compra,
				ind.f_primer_disp,
				ind.atm_disp_fecha,
				ind.fecha_ultima_compra,
				ind.vnt_disp_fecha,
				ind.fechaultimocambio,
				ind.fecha_alta
		FROM  bdicred:sd_maecred cred
		JOIN bdicred:sd_indicador_cred ind ON (ind.empresa = cred.empresa AND ind.num_credito = cred.num_credito)
		JOIN bdicred:sd_maesdos sdo ON 	(sdo.empresa = cred.empresa AND sdo.num_credito = cred.num_credito)
		WHERE cred.status_cred IN ('AA','E1')
		AND (sdo.monto_vencido + sdo.mto_venc_trasp) = 0;	

    --------------------------------------------------------------------------------------------------------------------------
	----------Obtiene creditos que tengan algun aumento de linea en los ultimos 3 meses---------------------------------------
	--------------------------------------------------------------------------------------------------------------------------
		-- Lectura de la fecha actual.
	SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas;		-- Fecha del dia
	SELECT add_months(fecha_hoy,-iMes_Incremento_linea) INTO dFechaMes FROM bdicred:sd_fechas;	-- Mes - 9999
	
	
	SELECT num_credito FROM bdicred:sd_incremento_reduccion
	WHERE tp_parametrico IN ('I','3') AND fecha_insert BETWEEN dFechaMes AND dFechaHoy 
	GROUP BY num_credito
	HAVING COUNT(num_credito) > 0 
		UNION ALL
    SELECT num_credito FROM bdicred:sd_status_incremento_reduccion
	WHERE tp_proceso IN ('I','3') AND fecha_actualiza BETWEEN dFechaMes AND dFechaHoy
	GROUP BY num_credito
	HAVING COUNT(num_credito) > 0 
	INTO temp tmp_indic_aum_inac WITH NO LOG;
	create index ix1_indaum_red_inac on tmp_indic_aum_inac ( num_credito ); 
    --ACTUALIZACION DE ESTASISTICOS A LA TEMPORAL
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_indic_aum_inac;
	-- Elimina creditos que recibieron un aumento en los ultimos 3 meses para que no sean procesados en la reduccion de linea.
	DELETE FROM creditos_reduccion WHERE num_credito IN (select {+avoid_full (tmp_indic_aum_inac)} num_credito from tmp_indic_aum_inac);
	
	--------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------

	--- sinonimo sd_adviser_mensual_85		
	CREATE temp TABLE adviser_mensual ( num_credito char(20),adv852 DECIMAL(14,2)) with no log;
    CREATE UNIQUE INDEX adviser_mensual_inx ON adviser_mensual(num_credito,adv852);
	
	Insert into adviser_mensual	
	SELECT num_credito,adv852 FROM sd_adviser_mensual_85; ----- tabla pruebas sd_adviser_mensual cambiar a sd_adviser_mensual_85 para producciÃÂÃÂ³n
	
	LET sMes= MONTH(p_fecha);
	LET sYear= YEAR(p_fecha);

	IF LENGTH(sMes)<2 THEN
		LET sMes="0"||sMes;
	END IF;

	LET sFechaArch=sMes||sYear;
	
	LET v_sql =
		'echo '||'No. de cliente'||v_sepa||'No. de credito'||v_sepa||'Meses de inactividad'||v_sepa||'BC Score'||v_sepa||'Linea anterior'||v_sepa||'Linea actual'||' >>'||TRIM(cRuta)||'Reduccion_'||TRIM(sFechaArch)||'.txt';
	SYSTEM v_sql;	
	
	
	FOREACH WITH HOLD
		
		SELECT 	 a.num_credito,a.numcte,a.num_producto,a.monto,a.fecha_ultimo_pago,a.f_primer_compra,a.f_primer_disp,a.atm_disp_fecha,a.fecha_ultima_compra,a.vnt_disp_fecha,a.fechaultimocambio
			INTO v_num_credito,
			v_numcte,
			v_num_producto,
			v_monto,
			v_fecha_ult_pago,
			v_primer_compra,
			v_primer_disp,
			v_atm_disp_fecha,
			v_fecha_ultima_compra,
			v_vnt_disp_fecha,
			v_fechaultimocambio
		FROM creditos_reduccion a
			WHERE a.fecha_alta <= p_fecha_consulta_red
			
			IF v_num_producto <> '6001' THEN
				CONTINUE FOREACH;
			END IF;

			SELECT fecha_actualiza
				INTO v_fecha_actualiza
			FROM bdicred:sd_status_incremento_reduccion
				WHERE num_credito = v_num_credito AND tp_proceso <> 'E';
			
			LET v_fecha_ult_pago = nvl (v_fecha_ult_pago,date (1));
			LET v_primer_compra	= nvl (v_primer_compra,date (1));
			LET v_primer_disp = nvl (v_primer_disp,date (1));
			LET v_atm_disp_fecha = nvl (v_atm_disp_fecha,date (1));
			LET v_fecha_ultima_compra =	nvl (v_fecha_ultima_compra,date (1));
			LET v_vnt_disp_fecha = nvl (v_vnt_disp_fecha,date (1));
			LET v_fechaultimocambio = nvl (DATE (v_fechaultimocambio),date (1));
			LET v_fecha_actualiza = nvl (v_fecha_actualiza,date(1));

		
			IF (sCommit = 0) THEN
				BEGIN WORK;
				LET sCommit = -1;
			END IF
			
			--- Descarta creditos con movimientos mayores o igual a 9999 meses, que indica que tienen movimientos recientes
			IF (v_fecha_ult_pago >= p_fecha_consulta_red OR v_primer_compra >= p_fecha_consulta_red 
				OR v_primer_disp >= p_fecha_consulta_red OR v_atm_disp_fecha >= p_fecha_consulta_red OR v_fecha_ultima_compra >= p_fecha_consulta_red 
				OR v_vnt_disp_fecha >= p_fecha_consulta_red OR v_fechaultimocambio >= p_fecha_consulta_red OR v_fecha_actualiza >= p_fecha_consulta_red ) THEN
				CONTINUE FOREACH;
			END IF;
			
			--- Proceso que obtiene numero de meses desde el ultimo movimiento
			
			LET v_fecha_ult_pago = (FLOOR (months_between (p_fecha,v_fecha_ult_pago)));
			LET v_primer_compra = (FLOOR (months_between (p_fecha,v_primer_compra)));
			LET v_primer_disp = (FLOOR (months_between (p_fecha,v_primer_disp)));
			LET v_atm_disp_fecha = (FLOOR (months_between (p_fecha,v_atm_disp_fecha)));
			LET v_fecha_ultima_compra = (FLOOR (months_between (p_fecha,v_fecha_ultima_compra)));
			LET v_fechaultimocambio = (FLOOR (months_between (p_fecha,v_fechaultimocambio)));
			LET v_vnt_disp_fecha = (FLOOR (months_between (p_fecha,v_vnt_disp_fecha)));
			LET v_fecha_actualiza = (FLOOR (months_between (p_fecha,v_fecha_actualiza)));
			
		
			-- Se insertan valores en tabla temporal con fechas en meses
				
			INSERT into fecha_actual VALUES(v_num_credito,v_fecha_ult_pago);
			INSERT into fecha_actual VALUES(v_num_credito,v_primer_compra);
			INSERT into fecha_actual VALUES(v_num_credito,v_primer_disp);
			INSERT into fecha_actual VALUES(v_num_credito,v_atm_disp_fecha);
			INSERT into fecha_actual VALUES(v_num_credito,v_fecha_ultima_compra);
			INSERT into fecha_actual VALUES(v_num_credito,v_fechaultimocambio);	
			INSERT into fecha_actual VALUES(v_num_credito,v_vnt_disp_fecha);	
			INSERT into fecha_actual VALUES(v_num_credito,v_fecha_actualiza);
			
			---- Se realiza consulta para obtener fecha mas reciente en meses
			SELECT min (meses)
				INTO v_meses
			FROM fecha_actual 
			WHERE num_credito = v_num_credito;
													
			
			--- sd_adviser_mensual de la tabla temporal
			--SELECT adv852 
				--INTO v_bcscore
			--FROM adviser_mensual 
			--WHERE num_credito = v_num_credito;
			
			--- sd_adviser_mensual de la tabla temporal
			SELECT adv852 
				INTO v_bcscore
			FROM adviser_mensual JOIN sd_tarjeta ON adviser_mensual.num_credito=sd_tarjeta.num_tarjeta
			WHERE sd_tarjeta.num_credito = v_num_credito
			AND secuencia = ( SELECT MAX(secuencia) FROM sd_tarjeta WHERE num_credito = v_num_credito );
				
			LET v_bcscore = NVL (v_bcscore,0);
			
			EXECUTE PROCEDURE bdicred:sp_incremento_reduccion (p_empresa,v_num_credito,v_meses,0,"R",v_bcscore,pNumTran)
			INTO vcod_retred,v_Mensajered, VNuevaLinea;
			
			IF vcod_retred::INTEGER <> 0 THEN
				LET v_cod_ret= '000001'; 
				LET v_Mensaje="Ocurrio un error al realizar la Reduccion de la linea";
				RETURN v_cod_ret, v_Mensaje;			
			END IF;


			LET v_sql = 'echo '||TRIM(v_numcte)||v_sepa||TRIM(v_num_credito)||v_sepa||v_meses||v_sepa||v_bcscore||v_sepa||v_monto||v_sepa||VNuevaLinea||' >>'||TRIM(cRuta)||'Reduccion_'||TRIM(sFechaArch)||'.txt';
			SYSTEM v_sql;
				
			LET contador_commit = contador_commit  + 1;	
	
			IF (contador_commit >= 100) THEN
				COMMIT WORK;
				UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".fecha_actual;
				LET contador_commit = 0;
				BEGIN WORK;
			END IF;
				
			IF sCommit = -1 THEN
				COMMIT WORK;
			END IF;
			
			LET sCommit = 0;
			
	END FOREACH;

	
-- ****************************************************************************
-- *                    Proceso incrementa 100 % de forma mensual              *
-- ****************************************************************************	

	--se consulta la linea de la bitacora y si el count (moviemintos) = 9999 se calcula el 100 % para incrementar la linea
	--- Obtiene la fecha de 3 meses menos
	---LET p_fecha_rango_inc =  ADD_MONTHS (p_fecha, -3);	
	---LET p_fecha_rango_fin =  ADD_MONTHS (p_fecha, -2);
	
	--- Obtiene la fecha de 9999 meses menos
	SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas;		-- Fecha del dia
	SELECT add_months(fecha_hoy,-iMes_Incremento_linea) INTO dFechaInc FROM bdicred:sd_fechas;	-- Mes - 9999


	CREATE temp TABLE cred_incrementos_cincuenta ( numcte CHAR (20),num_credito CHAR(20),meses_ina INTEGER,bc_score INTEGER,describe_mov CHAR (50),fecha_facturacion DATE,total_mov DECIMAL(10,2),linea_original DECIMAL(10,2),linea_nueva DECIMAL(10,2),descripcion CHAR(50)) with no log; 
    CREATE UNIQUE INDEX idx_incrementos_cincuenta ON cred_incrementos_cincuenta(num_credito,linea_original);

	Insert into cred_incrementos_cincuenta	
	SELECT numcte,num_credito,meses_ina,bc_score,describe_mov,fecha_facturacion,monto_facturacion,linea_original,linea_actual,descripcion
	FROM "informix".sd_status_incremento_reduccion 
			WHERE empresa = p_empresa 
				AND tp_proceso = "I" AND marca_cincuenta = 0
				--AND fecha_actualiza BETWEEN p_fecha_rango_inc AND p_fecha_rango_fin;
				AND fecha_actualiza <= dFechaInc;
			
	LET v_sql2 =
		'echo '||'No. de cliente'||v_sepa||'No. de credito'||v_sepa||'Tipo de Facturacion'||v_sepa||'Fecha de movimiento'||v_sepa||'Monto de facturaciÃÂÃÂ³n'||v_sepa||'Linea anterior'||v_sepa||'Linea Actual'||v_sepa||'Fecha reactivaciÃÂÃÂ³n'||v_sepa||'Observaciones'||' >>'||TRIM(cRuta)||'Incrementos_'||TRIM(sFechaArch)||'.txt';
	SYSTEM v_sql2;				
			
	FOREACH WITH HOLD
	
	SELECT numcte,num_credito,meses_ina,bc_score,describe_mov,fecha_facturacion,total_mov,linea_original,linea_nueva,descripcion
			INTO r_numcte,r_num_credito,r_meses_ina,r_bc_score,r_describe_mov,r_fecha_insert,r_total_mov,r_linea_original,r_linea_nueva,r_descripcion
		FROM cred_incrementos_cincuenta 
		
			SELECT COUNT (*)
			INTO vpago_consecutivo
			FROM bdicred:sd_amortiza_credito
			WHERE num_credito = r_num_credito
				AND fecha_cuota > p_fecha_rango_inc
				AND capital_status = 5;
				
			IF vpago_consecutivo < 3 THEN
				CONTINUE FOREACH;
			END IF;
			
			EXECUTE PROCEDURE bdicred:sp_incremento_reduccion (p_empresa,r_num_credito,r_meses_ina,r_linea_original,"3",r_bc_score,pNumTran)
			INTO vcod_retred,v_Mensajered, VNuevaLinea;
			
			IF vcod_retred::INTEGER <> 0 THEN
				LET v_cod_ret= '000001'; 
				LET v_Mensaje="Ocurrio un error al realizar Incremento de la linea";
				RETURN v_cod_ret, v_Mensaje;			
			END IF;				
			
			LET v_sql2 = 'echo '||TRIM(r_numcte)||v_sepa||TRIM(r_num_credito)||v_sepa||TRIM(v_Mensajered)||v_sepa||r_fecha_insert||v_sepa||r_total_mov||v_sepa||r_linea_original||v_sepa||VNuevaLinea||v_sepa||p_fecha||v_sepa||r_descripcion||' >>'||TRIM(cRuta)||'Incrementos_'||TRIM(sFechaArch)||'.txt';
			SYSTEM v_sql2;				
			
	END FOREACH;
	
-- ****************************************************************************
-- *   Reporte incrementos activados por disposiciÃÂÃÂ³n durante el mes anterior  *
-- ****************************************************************************		

	---- Obtiene el periodo para las fechas del reporte

	SELECT ADD_MONTHS (pri_dia_mes,-1) ,LAST_DAY(ADD_MONTHS (fecha_hoy,-1))
		INTO periodo1,periodo2
	FROM bdicred:sd_fechas WHERE empresa = p_empresa;
	

	FOREACH WITH HOLD

		SELECT numcte,num_credito,describe_mov,fecha_insert,fecha_facturacion,monto_facturacion,linea_anterior,linea_actual,descripcion
			INTO r_numcte,r_num_credito,r_describe_mov,r_fecha_insert,r_fecha_facturacion,r_total_mov,r_linea_original,r_linea_nueva,r_descripcion
		FROM "informix".sd_status_incremento_reduccion 
				WHERE empresa = p_empresa 
					AND tp_proceso = "I" AND marca_cincuenta = 0
					AND fecha_actualiza BETWEEN periodo1 AND periodo2					
	
		LET v_sql2 = 'echo '||TRIM(r_numcte)||v_sepa||TRIM(r_num_credito)||v_sepa||TRIM(r_describe_mov)||v_sepa||r_fecha_insert||v_sepa||r_total_mov||v_sepa||r_linea_original||v_sepa||r_linea_nueva||v_sepa||r_fecha_facturacion||v_sepa||r_descripcion||' >>'||TRIM(cRuta)||'Incrementos_'||TRIM(sFechaArch)||'.txt';
		SYSTEM v_sql2;	
		
	END FOREACH;
	

	LET v_Mensaje = "Proceso y Reporte exitoso";	

  RETURN v_cod_ret,v_Mensaje;
END; 

END PROCEDURE
DOCUMENT
'REALIZA LA REDUCCION DE LINEA E INCREMENTO MENSUAL AL 50%, Y GENERA REPORTE - RQM 09 499',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : SEP/2018',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_pagos_rechazados(p_empresa char(3))
    RETURNING CHAR(6)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje;

-- Fecha CreaciÃ³n: Octubre 2024
-- Reporte con los pagos rechazados por rebasar el monto maximo de Saldo a Favor RQI 25 379
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_retIB			CHAR(6);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(1000);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(700);
DEFINE cSQL3                CHAR(100);
DEFINE cruta                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cProceso             CHAR(4);
DEFINE dFechaHoy            DATE;
DEFINE dFechaIniMes         DATE;
DEFINE dFechaIni            DATE;
DEFINE dFechaFin            DATE;

--InicializaciÃ³n de variables
LET sql_err             = 0;
LET isam_err            = 0;
LET error_info          = "";
LET cCod_Ret            = '00000';
LET cCod_retIB          = '00000';
LET cMensaje            = 'PROCESO EXITOSO';
LET cruta               = "";
LET cnombre				= "Pagos_rechazados_sdo_favor_";
LET cnomarchivo         = "";
LET cnomarchivo1		= "";
LET cnomarchivoEjecSql  = "";
LET cSQL                = "";
LET cSQL1               = "";
LET cSQL2               = "";
LET cSQL3               = "";
LET cProceso            = '0086';
LET dFechaHoy           = DATE(1);
LET dFechaIniMes        = DATE(1);
LET dFechaIni           = DATE(1);
LET dFechaFin           = DATE(1);

--SET DEBUG FILE TO "/informix/sp_reporte_pagos_rechazados.out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

 BEGIN
  ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;       
        CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, trim(cMensaje)||'-'||isam_err::CHAR, '02') Returning cCod_retIB;
        RETURN cCod_ret, cMensaje;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'INICIA CREACION REPORTE', '02') Returning cCod_RetIB;

	--Obtener ruta del archivo
    SELECT TRIM(valor)  INTO cruta FROM bdicred:sd_param WHERE empresa = p_empresa AND cod_param = '033';
    -- Obtiene la fecha del dia de hoy
    SELECT fecha_hoy, pri_dia_mes INTO dFechaHoy, dFechaIniMes FROM bdinteg:"informix".si_fechas WHERE empresa = p_empresa;

    LET cFechaGenArchivo = to_char(dFechaHoy,'%d%m%Y');
    LET dFechaFin = dFechaIniMes - 1 units day;
    LET dFechaIni = mdy(month(dFechaFin),1,year(dFechaFin));

	--Validar que existe el archivo	
	LET cnomarchivo1 = trim(cnombre)||'Aux_'||cFechaGenArchivo||'.txt ';
    LET cnomarchivo =  trim(cnombre)||cFechaGenArchivo||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_Rep_PagosRechaSdoFavor.sql';

    LET cSQL='';
    LET cSQL = 'echo "Num Credito'||'|'||'Sucursal Pago'||'|'||'Fecha Pago Rechazado'||'|'||'Monto Pago Rechazado'||'|'||'Saldo Total'||'|'||'Monto Otorgado'
               || ' " >' || TRIM(cruta) || TRIM(cnomarchivo)||'';
    SYSTEM cSQL;

    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1);

    LET cSQL2 = " SELECT num_credito, sucursal, fecha_pago_rech, monto_pago_rech, sdo_total_liquidacion, monto_otorgado "        
                || " FROM bdicred:sd_pagos_rech_sdo_favor WHERE fecha_pago_rech >= '" ||dFechaIni|| "' AND fecha_pago_rech <= '" ||dFechaFin||"'";
                
    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoEjecSql;
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoEjecSql;
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    --Borra el archivo de control.
    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1;
    SYSTEM cSQL;

    LET cCod_Ret = '00000';
    LET cMensaje = 'PROCESO EXITOSO';

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'TERMINA REPORTE PAGOS RECHAZADOS', '02') Returning cCod_RetIB;

    RETURN cCod_Ret, cMensaje;

 END;   --begin        

END PROCEDURE;