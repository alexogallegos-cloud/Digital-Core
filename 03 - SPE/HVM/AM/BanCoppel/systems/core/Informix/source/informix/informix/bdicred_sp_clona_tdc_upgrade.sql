CREATE PROCEDURE "informix".sp_clona_tdc_upgrade(pEmpresa CHAR(3),P_EJECUTIVO CHAR(10) , pProducto CHAR(4), pCredito CHAR(20) ,pTarjeta CHAR(20),pTarjetaOro CHAR(20))
RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cCodRetTDif	 CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE vCodRet 		 CHAR(6);
DEFINE vMsjRetorno   VARCHAR(100,1);
DEFINE scod_ret		 CHAR(6);
DEFINE cod_ret       CHAR(3);
DEFINE cSolOro       CHAR(20);
DEFINE cEmpresa      CHAR(3);
DEFINE cNumProducto  CHAR(4);
DEFINE cNomProducto  VARCHAR(100,1);
DEFINE CstatusSol    CHAR(2);
DEFINE CstatusSolANT CHAR(2);
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
--DEFINE vHoy                 DATE;
DEFINE P_ERROR 				CHAR(5);
DEFINE P_MENSAJE			VARCHAR(100,1);
DEFINE V_CATIVA				DECIMAL(9,6);
DEFINE V_MERCADEO			CHAR(1);
---CLONACION DE TDC Oro
DEFINE V_TASA_INTERES        DECIMAL(9,6);
DEFINE V_TASA_MORA           DECIMAL(9,6);
DEFINE V_SOBRETASA           DECIMAL(9,6);
DEFINE V_SOBRETASA_MORA      DECIMAL(9,6);
DEFINE V_TASA_FAVOR          DECIMAL(9,6);
DEFINE V_SOBRETASA_FAV       DECIMAL(9,6);
DEFINE V_FACTOR	             CHAR(1);
DEFINE V_FACTOR_MORA		 CHAR(1);
DEFINE V_FECHA_APERT         DATE;
DEFINE V_FECHA_VENC          DATE;
DEFINE V_FACTOR_FAV          CHAR(1);
DEFINE V_PRODUCTO            CHAR(4);
DEFINE VV_DIVISA             CHAR(2);
DEFINE V_MONTO               DECIMAL(14,2);
DEFINE VV_SUCURSAL           CHAR(4);
DEFINE VV_FOLIO	             CHAR(16);
DEFINE vFechaT               DATE;
DEFINE vDiaCorte             SMALLINT;
DEFINE VDIAPAGO              SMALLINT;
DEFINE i		     		 SMALLINT;
DEFINE cTran				 CHAR(4);
DEFINE vtarjeta				 CHAR(16);
DEFINE cproducto			 CHAR(4);
DEFINE dIntPeriodo        	DECIMAL(14,2);
DEFINE iSecuencia 		  	 INTEGER;
DEFINE cNumtarjadi           CHAR(20);
-- Actualiza producto de la tarjeta nueva en intercard INI
DEFINE Scodproducto          CHAR(03);
-- Actualiza producto de la tarjeta nueva en intercard FIN
-- Se obtiene numcte para identificar si ya cuenta con un producto TDC ORO
DEFINE cNumcte 				CHAR(20);
DEFINE cNumCredUpgrade		CHAR(20);
-- AAME 20180821 INC 25 179 Variables para identificar cte adicional
DEFINE cnumcteadi			CHAR(20);
DEFINE cTarAdicUpgrade		CHAR(20);
DEFINE cidsolicitud			INTEGER;
DEFINE cApell_Paterno		CHAR(26);
DEFINE cApell_Materno		CHAR(26);
DEFINE cNombre1				CHAR(26);
DEFINE cNombre2				CHAR(26);
DEFINE cRfc					CHAR(20);
DEFINE cFechaNacimiento 	DATE;
DEFINE TransaccLibRet		CHAR(20);
DEFINE dMontoRet			DECIMAL(14,2);
DEFINE cFolio				CHAR(20);
DEFINE cUsuario				CHAR(8);
DEFINE cReferencia			CHAR(20);
DEFINE dFecha 				DATE;
DEFINE cSucursal			CHAR(20);
DEFINE cTranlibprot			CHAR(20);
--- Cuenta Clabe
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);
--IFRS
DEFINE cACT					INTEGER;
DEFINE cod_ref		     	INTEGER;
DEFINE sExistePromo         SMALLINT;

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cCodRetTDif	  = '';
LET cMensajeRet   = 'PROCESO EXITOSO';
LET vCodRet       = '';
LET vMsjRetorno	  = '';

LET cEmpresa      = '';
LET cNumProducto  = '';
LET cNomProducto  = '';
LET CstatusSol    = '';
LET CstatusSolANT = '';
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
--Nueva Solicitud de Credito Oro
LET scod_ret				= '0';
LET cSolOro     			= '';
LET vFolio                  = '';
--LET vHoy                    = DATE(1);
--
LET P_ERROR 			= '';
LET P_MENSAJE			= '';
LET V_TASA_INTERES 		= 0.0;
LET V_TASA_MORA			= 0.0;
LET V_CATIVA			= 0.0;
LET V_MERCADEO			= '';
LET V_TASA_MORA 		= 0;
LET V_TASA_INTERES 		= 0;
LET V_SOBRETASA   		= 0;
LET V_SOBRETASA_MORA	= 0;
LET V_TASA_FAVOR  		= 0;
LET V_MERCADEO 			= "";
LET V_SOBRETASA_FAV 	= 0;
LET V_FACTOR			= "";
LET V_FACTOR_MORA		= "";
LET V_FECHA_APERT 		= DATE(1);
LET V_FECHA_VENC 		= DATE(1);
LET V_FACTOR_FAV 		= "";
LET V_PRODUCTO  		= "";
LET VV_DIVISA 			= "";
LET V_MONTO  			= 0;
LET VV_SUCURSAL   		= "";
LET VV_FOLIO			= "";
LET vFechaT   			= DATE(1);
LET vDiaCorte 			= 0;
LET VDIAPAGO 			= 0;
LET i		  			= 0;
LET cTran				= "";
LET vtarjeta			= "";
LET cproducto			= "";
LET dIntPeriodo			= 0;
LET iSecuencia 			= 0;
LET cNumtarjadi 		= "";
-- Actualiza producto de la tarjeta nueva en intercard INI
LET Scodproducto        = "";
-- Actualiza producto de la tarjeta nueva en intercard FIN
-- Se obtiene numcte para identificar si ya cuenta con un producto TDC ORO
LET cNumcte 			= "";
LET cNumCredUpgrade		= "";
-- AAME 20180821 INC 25 179 Variables para identificar cte adicional
LET cnumcteadi			= "";
LET cTarAdicUpgrade		= "";
LET cidsolicitud		= 0;
LET cApell_Paterno		= "";
LET cApell_Materno		= "";
LET cNombre1			= "";
LET cNombre2			= "";
LET cRfc				= "";
LET cFechaNacimiento 	= DATE(1);
LET TransaccLibRet		= "";
LET dMontoRet			= 0.00;
LET cFolio				= "";
LET cUsuario			= "";
LET cReferencia			= "";
LET dFecha 				= DATE(1);
LET cSucursal			= "";
LET cTranlibprot			= "";

--- Cuenta Clabe
LET vcod_ret			= '000';
LET cta_Clabe			= '';
-- IFRS
LET cACT				= 0;
LET cod_ref				= 0;
LET sExistePromo        = 0;

--SET DEBUG FILE TO '/home/c90236570/Anio_2025/sp_clona_tdc_UPGRADE.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

select first 1 codproductotarjeta
into Scodproducto
from intercard:binproducto  
where codprodcta = pProducto
and bin = substr(pTarjetaOro,1,6);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
		-- Actualizacion de credito en bitacora de upgrade cuando pase un error
		UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
		WHERE num_credito = pCredito;
		--En caso de error se elimina el registro de la nueva tarjeta
		--AAME Se eliminan los datos del nuevo credito y se actualizan las tablas al estado anterior
		DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
		DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
		UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
		UPDATE intercard:tarjeta 
		SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
		WHERE numtarjeta = pTarjetaOro;
		FOREACH WITH HOLD 
			SELECT numerotarjeta, numcte 
			INTO cNumtarjadi,cnumcteadi
			FROM bdicred:sd_credito_upgrade
			WHERE num_credito = pCredito
			AND tipotar='ADI'	
			
			SELECT DM.IdSolicitud 
			INTO cidsolicitud
			FROM intercard:SolicitudTarjeta ST 
			INNER JOIN intercard:Detalle_Maquila DM ON ST.IdSolicitud=DM.IdSolicitud 
			WHERE ST.IdSolicitud >= 1 AND ST.NumCuenta= cSolOro AND ST.numcliente = cnumcteadi;		
		
			UPDATE sd_tarjeta  SET status_tar='A' WHERE num_tarjeta = cNumtarjadi;
			UPDATE intercard:tarjeta  SET codstatustarjeta='ACT' WHERE numtarjeta = cNumtarjadi;														
			UPDATE intercard:solicitudtarjeta SET numcuenta=pCredito WHERE idsolicitud =cidsolicitud;
			DELETE FROM sd_adicionalespendientes WHERE empresa='001' AND NumCteTitular = cNumcte AND NumCteAdicional= cnumcteadi AND Credito = cSolOro;					
		END FOREACH;			
		DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
		DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
		DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
		DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
		DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
		DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;
      RETURN cCodRet, cMensajeRet;
    END IF;
END EXCEPTION;


SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' OR TRIM(NVL(pCredito,''))=''  OR TRIM(NVL(pProducto,''))=''    THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parametro no es valido';

	-- Actualizacion de credito en bitacora de upgrade cuando pase un error
	UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
	WHERE num_credito = pCredito;
    --En caso de error se elimina el registro de la nueva tarjeta
    DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
    DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
    UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
    UPDATE intercard:tarjeta 
    SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
    WHERE numtarjeta = pTarjetaOro;

  RETURN cCodRet, cMensajeRet;
END IF;

--SELECT fecha_hoy
--INTO vHoy
--FROM bdicred:sd_fechas;

IF SUBSTR(pTarjeta,1,8) <> SUBSTR(pTarjetaOro,1,8) THEN

	IF EXISTS(SELECT num_tarjeta FROM bdicred:sd_tarjeta WHERE empresa =cEmpresa AND num_tarjeta =pTarjetaOro) THEN

		-- CONSULTAMOS EL SALDO GENERAL DEL CREDITO.
		EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general(TRIM(pEmpresa), TRIM(pCredito))
		INTO cCodRetCSG, cMsjRetCSG, cNumCreditoCSG, cCodTCredCSG, dFechaOrigCSG, dFechaProxPagCSG, dcPagoMinCSG, dFechaUltPagCSG, iPlazoCSG, iPagRealizadosCSG, dcLinOtorgadaCSG, dcTasaInteresCSG, dcTasaMoratoriosCSG, dcMontoSbsCSG,
			 dcCapVigCSG, dcCapTransCSG, dcCapVdoExigCSG, dcCapVdoNoExigCSG, dcSdoActTotCapCSG, dcIntVigCSG, dcIntVdoCSG, dcIntMoratorioCSG, dcIntMesCSG, dcSodActTotIntCSG, dcIvaIntVigCSG, dcIvaIntVdoCSG, dcIvaIntMorCSG, dcIvaIntMesCSG,
			 dcSdoActTotIvaCSG, dcComPendCSG, dcIvaComCSG, dcSdoRetenidoCSG, dcTotalLiqCSG, dcIntDevengadoCSG, dcIvaIntDevengadoCSG, dcLinDispCSG, dcPagosVdosCSG, cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqCtaCSG, cIdCausaBloqCredCSG,
			 cCausaBloqCtaCSG, cIdSitEspCteCSG, iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;

		IF cCodRetCSG = '000003' THEN -- Numero de credito no existe
			LET cCodRet  = '000002';
			LET cMensajeRet = cMsjRetCSG::CHAR(150);
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;

			RETURN cCodRet, cMensajeRet;
		ELIF cCodRetCSG = '000007' THEN -- Error al obtener el valor del pago minimo
			LET cCodRet  = '000003';
			LET cMensajeRet = cMsjRetCSG::CHAR(150);
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;

			RETURN cCodRet, cMensajeRet;
		ELIF cCodRetCSG::INTEGER < 0 THEN -- ERROR NO CONTROLADO EN EL BDICRED:SP_CONSULTA_SALDOS_GENERAL
			EXECUTE PROCEDURE bdinteg:sp_desc_ret('06','599')
			INTO vCodRet, vMsjRetorno;

			LET cCodRet  = '000004';
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;

			LET cMensajeRet = vMsjRetorno::CHAR(150);
			RETURN cCodRet, cMensajeRet;
		END IF
		
	   -- **************************************************
	   -- Extrae informacion del Credito *
	   -- **************************************************
	   SELECT status_cred,numcte
		 INTO CstatusSol,cNumcte
		 FROM sd_maecred
		WHERE empresa = pEmpresa
		  AND num_credito = pCredito;
	  --***** ACTUALIZA SD_MAECRED
	  --AAME Se Pregunta que no exista antes de insertar en la tabla sd_maecred
		SELECT limit 1 num_credito 
		INTO cNumCredUpgrade
		FROM bdicred:sd_maecred
		WHERE empresa = pEmpresa 
		AND numcte = cNumcte 
		AND credito_externo = pCredito
		AND status_cred IN ('AA','E1');	  
		--MACM RQM 10 1584 TARJETA DE CREDITO INFINITE, SE OMITE LA VALIDACION DE SALDO RETENIDO dcSdoRetenidoCSG = 0
		IF CstatusSol IN ('FF','AA','E1') AND (dcCapTransCSG + dcCapVdoExigCSG) = 0 THEN 
		
			IF NVL(cNumCredUpgrade,'') = '' THEN
				CALL bdisolic:asigna_numsol(pEmpresa, pProducto)
				RETURNING scod_ret, cSolOro;
				IF scod_ret::integer <> 0 THEN
				   LET cCodRet = scod_ret;
				   LET cMensajeRet= 'Error el proceso de asigna_numsol al crear credito upgrade';
					-- Actualizacion de credito en bitacora de upgrade cuando pase un error
					UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
					WHERE num_credito = pCredito;
					--En caso de error se elimina el registro de la nueva tarjeta
					--AAME Se eliminan los datos del nuevo credito y se actualizan las tablas al estado anterior
					DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
					UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
					UPDATE intercard:tarjeta 
					SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
					WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
					DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

				   RETURN cCodRet, cMensajeRet;
				END IF;				
			ELSE
				LET cSolOro = cNumCredUpgrade;
			END IF;			

			  --clonado de la solicitud
			SELECT fecha_hoy
			  INTO V_FECHA_APERT
			  FROM sd_fechas
			 WHERE empresa = pEmpresa;

			let  V_FECHA_VENC=date(0);
			
			---KSOV
			  -- ****************************
			  -- No permite Upgrade dia 18  *
			  -- ****************************
			  SELECT dia_cuota 
			  INTO VDIAPAGO
			  FROM sd_definicion 
			  WHERE num_producto = pProducto;
			  
			IF DAY(V_FECHA_APERT) = VDIAPAGO AND pProducto <> '5400' 
			   THEN
			   LET cCodRet = '000008';
			   LET cMensajeRet = 'No se puede generar Upgrade de Tarjeta Oro el mismo dÃ­a de Corte';
			-- ActualizaciÃ³n de credito en bitacora de upgrade cuando pase un error
					UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
					WHERE num_credito = pCredito;
					DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
					UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
					UPDATE intercard:tarjeta 
					SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
					WHERE numtarjeta = pTarjetaOro;
			    
				RETURN cCodRet, cMensajeRet;
			END IF;
			
			---KSOV
			  -- ****************************
			  -- No permite Upgrade dia 18 FIN*
			  -- ****************************			
			

			call monthadd(V_FECHA_APERT,12) returning V_FECHA_VENC;

			  -- ****************************
			  -- Determina Tasas de Interes *
			  -- ****************************
			  
			EXECUTE PROCEDURE bdicred:sp_obtiene_tasa_int_diferenciadas(pEmpresa, pCredito, pProducto) INTO cCodRetTDif, V_TASA_INTERES, V_TASA_MORA;
			IF cCodRetTDif <> '000000' THEN
				LET cCodRet = cCodRetTDif;
				RETURN cCodRet, cMensajeRet;
			END IF;
			  
			--INTERES ORDINARIO
			/*SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota
			  INTO V_TASA_INTERES, V_FACTOR, V_SOBRETASA, vDiaCorte
			  FROM sd_definicion a,  bdinteg:si_fechavalor c
			 WHERE a.empresa = pEmpresa
			   AND a.num_producto = pProducto
			   AND c.empresa = a.empresa
			   AND c.tasa = a.cod_tasa_base
			   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
					   WHERE r.empresa = pEmpresa
						 AND r.tasa = a.cod_tasa_base);
			*/	-- RQM 10 1224
						 
			SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.fact_sobret_mora, a.sobretasa_mora
			  INTO V_FACTOR, 		   V_SOBRETASA, vDiaCorte,   V_FACTOR_MORA,      V_SOBRETASA_MORA
			  FROM sd_definicion a
			 WHERE a.empresa = pEmpresa
			   AND a.num_producto = pProducto;							 


			IF v_factor = "+" THEN
				LET V_TASA_INTERES = V_TASA_INTERES + V_SOBRETASA;
			ELIF v_factor = "-" THEN
				LET V_TASA_INTERES = V_TASA_INTERES - V_SOBRETASA;
			ELIF v_factor = "*" THEN
				LET V_TASA_INTERES = V_TASA_INTERES * V_SOBRETASA;
			ELSE
				LET V_TASA_INTERES = V_TASA_INTERES / V_SOBRETASA;
			END IF

			--INTERES MORATORIO
			/*SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
			  INTO V_TASA_MORA   , V_FACTOR, V_SOBRETASA
			  FROM sd_definicion a, bdinteg:si_fechavalor c
			 WHERE a.empresa = pEmpresa
			   AND a.num_producto = pProducto
			   AND c.empresa = a.empresa
			   AND c.tasa = a.cod_tasa_mora
			   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
							   WHERE r.empresa = pEmpresa
								 AND r.tasa = a.cod_tasa_mora);
			*/					-- RQM 10 1224

			IF V_FACTOR_MORA = "+" THEN
					LET V_TASA_MORA = V_TASA_MORA + V_SOBRETASA_MORA;
			ELIF V_FACTOR_MORA = "-" THEN
					LET V_TASA_MORA = V_TASA_MORA - V_SOBRETASA_MORA;
			ELIF V_FACTOR_MORA = "*" THEN
					LET V_TASA_MORA = V_TASA_MORA * V_SOBRETASA_MORA;
			ELSE
					LET V_TASA_MORA = V_TASA_MORA / V_SOBRETASA_MORA;
			END IF

			--INTERES A FAVOR DEL CLIENTE
			SELECT c.valor, a.factor_sobretasa, a.sobretasa
			  INTO V_TASA_FAVOR   , V_FACTOR_FAV, V_SOBRETASA_FAV
			  FROM sd_anexodefinicion a, bdinteg:si_fechavalor c
			 WHERE a.empresa = pEmpresa
			   AND a.num_producto = pProducto
			   AND c.empresa = a.empresa
			   AND c.tasa = a.cod_tasa_base
			   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
							   WHERE r.empresa = pEmpresa
								 AND r.tasa = a.cod_tasa_base);

			IF V_FACTOR_FAV = "+" THEN
					LET V_TASA_FAVOR = V_TASA_FAVOR + V_SOBRETASA_FAV;
			ELIF V_FACTOR_FAV = "-" THEN
					LET V_TASA_FAVOR = V_TASA_FAVOR - V_SOBRETASA_FAV;
			ELIF V_FACTOR_FAV = "*" THEN
					LET V_TASA_FAVOR = V_TASA_FAVOR * V_SOBRETASA_FAV;
			ELSE
					LET V_TASA_FAVOR = V_TASA_FAVOR / V_SOBRETASA_FAV;
			END IF
		  
			IF NOT EXISTS (SELECT num_credito FROM sd_maecred WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN

				--- Genera cuenta Clabe
				EXECUTE PROCEDURE bdicred:sp_gen_clabe_interbancaria (pEmpresa,cSolOro,pProducto)
					INTO vcod_ret, cta_Clabe;

				SELECT a.num_producto, a.divisa, c.monto_otorgado, b.sucursal, NVL(c.act,-1)
				  INTO V_PRODUCTO, VV_DIVISA, V_MONTO, VV_SUCURSAL, cACT
				  FROM bdicred:sd_maecred b, bdicred:sd_maesdos c, sd_definicion a
				 WHERE b.empresa = pEmpresa
				   AND b.num_credito = pCredito
				   AND c.num_credito= b.num_credito
				   AND a.empresa = b.empresa
				   AND a.num_producto = b.num_producto;	
				   
				LET CstatusSolANT = CstatusSol;

				IF (CstatusSol = 'FF' AND cACT = -1 ) THEN
					LET CstatusSol = 'AA';
				ELIF (CstatusSol = 'FF' AND cACT <> -1) THEN
					LET CstatusSol = 'E1';
				END IF;

				INSERT INTO bdicred:sd_maecred
					   (EMPRESA                ,NUM_CREDITO
					   ,NUM_PRODUCTO           ,EJECUTIVO
					   ,NUMCTE                 ,DIVISA
					   ,SUCURSAL               ,ID_ORIGEN
					   ,ORIGEN                 ,COD_TIPO_LINEA
					   ,COD_LINEA              ,PORC_REC_PROP
					   ,STATUS_CRED            ,BANDERA_RENOVAC
					   ,BANDERA_PRORROGA       ,PERIODO_PLAZO
					   ,PLAZO                  ,FECHA_APERTURA
					   ,FECHA_VENCIM           ,PERIOD_PAGO_CAP
					   ,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
					   ,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
					   ,COD_TASA_BASE          ,FACTOR_SOBRETASA
					   ,SOBRETASA              ,TASA_INTERES
					   ,COD_TASA_MORA          ,SOBRETASA_MORA
					   ,FACT_SOBRET_MORA       ,TASA_MORATORIOS
					   ,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
					   ,ES_FISICA              ,BANDERA_FI_FO
					   ,CODIGO_PRO             ,SUPERFICIE
					   ,ACTIVIDAD              ,CAL_EDOS_FIN
					   ,TIPO_CALCULO           ,ADMITE_TLP
					   ,REL_GARCRED            ,ID_UNIDAD_PROD
					   ,NUM_APER_ANT           ,REV_TASA_VAR_PER
					   ,DIA_PARA_REVISAR       ,COD_PROD
					   ,BANDERA_MINISTRA       ,NUM_FIDEICOMISO
					   ,CREDITO_EXTERNO        ,GRACIA_CAPITAL
					   ,DIFERIMIENTO_INT       ,FECHA_FIN_PRORRATEO
					   ,CAMPO_TRAB1            ,CAMPO_TRAB2
					   ,CAMPO_TRAB3            ,CAMPO_TRAB4
					   ,CALIFICACION_RIESGO    ,COD_AGRICOLA
					   ,TASA_BASE_PISO         ,SOBRETASA_PISO
					   ,FACTOR_PISO            ,TASA_PISO
					   ,TASA_BASE_TECHO        ,SOBRETASA_TECHO
					   ,FACTOR_TECHO           ,TASA_TECHO
					   ,cuenta_clabe
					   )
				 SELECT SOL.EMPRESA                ,cSolOro
					   ,pProducto           	   ,SOL.EJECUTIVO
					   ,SOL.NUMCTE                 ,DEF.DIVISA
					   ,SOL.SUCURSAL               ,''
					   ,''                         ,''
					   ,''                         ,100
					   ,CstatusSol                 ,'N'
					   ,'N'                        ,DEF.PERIODO_PLAZO
					   ,0                          ,V_FECHA_APERT
					   ,V_FECHA_VENC               ,"3"
					   ,"2"                        ,CTR.DIAS_TRAS_CAP
					   ,CTR.DIAS_TRAS_INT          ,DEF.TASA_FIJA_O_VAR
					   ,DEF.COD_TASA_BASE          ,DEF.FACTOR_SOBRETASA
					   ,DEF.SOBRETASA              ,V_TASA_INTERES
					   ,DEF.COD_TASA_MORA          ,DEF.SOBRETASA_MORA
					   ,DEF.FACT_SOBRET_MORA       ,V_TASA_MORA
					   ,''                         ,''
					   ,TIP.ES_FISICA              ,''
					   ,DEF.COD_PROD               ,0
					   ,''                         ,''
					   ,DEF.TIPO_CALCULO           ,''
					   ,0                          ,''
					   ,''                         ,DEF.REV_TASA_VAR_PER
					   ,DEF.DIA_PARA_REVISAR       ,''
					   ,'M'                        ,''
					   ,pCredito                   ,0
					   ,0                          ,V_FECHA_APERT
					   ,0                          ,0
					   ,''                         ,''
					   ,SOL.CALIFICACION_RIESGO        ,''
					   ,''                         ,''
					   ,''                         ,''
					   ,''                         ,''
					   ,''                         ,''
					   ,cta_Clabe
				 FROM   BDICRED:SD_MAECRED SOL
					  , BDICRED:SD_MAECREDANEXO    ANX
					  , BDINTEG:SI_CLIENTE      CLI
					  , BDINTEG:SI_TIPPER       TIP
					  , SD_CODTRASP             CTR
					  , SD_DEFINICION           DEF
				 WHERE  DEF.EMPRESA         = SOL.EMPRESA
				 AND    DEF.NUM_PRODUCTO    = pProducto
				 AND    CTR.PERIOD_PAG_INT  = "2"
				 AND    CTR.PERIOD_PAGO_CAP = "3"
				 AND 	CTR.NUM_PRODUCTO    = pProducto
				 AND    CTR.EMPRESA         = DEF.EMPRESA
				 AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
				 AND    CLI.NUMCTE          = SOL.NUMCTE
				 AND    CLI.EMPRESA         = SOL.EMPRESA
				 AND    ANX.num_credito   = SOL.NUM_CREDITO
				 AND    ANX.EMPRESA         = SOL.EMPRESA
				 AND    SOL.num_credito   = pCredito
				 AND    SOL.EMPRESA         = pEmpresa;
			END IF;

			LET CstatusSol = CstatusSolANT;
			   
			 SELECT (a.dia_cuota - a.gracia_calc_mora)
			  INTO VDIAPAGO
			  FROM sd_definicion a
			 WHERE a.empresa = pEmpresa
			   AND a.num_producto = pProducto;	
			 --AAME Se Pregunta que no exista antes de insertar en la tabla SD_MAESDOS
			 
			IF NOT EXISTS (SELECT num_credito FROM SD_MAESDOS WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN

			  --***** ACTUALIZA SD_MAESDOS

				 INSERT INTO SD_MAESDOS (EMPRESA                ,NUM_CREDITO 
										,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
										,SDO_INT_ANT_DEV        ,SDO_INTERESES
										,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
										,SDO_ACUM_MES_INT       ,SDO_RETENIDO
										,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
										,SDO_NO_EXIG            ,PROVISION_NORMAL
										,DIAS_ACUM_INT          ,SDO_MORATORIO
										,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
										,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
										,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
										,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
										,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
										,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
										,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
										,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
										,MONTO_VENCIDO          ,MTO_VENC_TRASP
										,MONTO_FINANCIADO       ,MONTO_RESERVADO
										,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
										,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
										,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
										,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
										,MTO_VENC_INT           ,MTO_VENC_TRA_INT
										,MTO_FINAN_VDO          ,MTO_RESER_INT
										,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
										,INT_TRA_NO_EXIG        ,SDO_TRAB4
										,ACT)
								  SELECT EMPRESA                ,cSolOro
										,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
										,SDO_INT_ANT_DEV        ,SDO_INTERESES
										,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
										,SDO_ACUM_MES_INT       ,SDO_RETENIDO
										,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
										,SDO_NO_EXIG            ,PROVISION_NORMAL
										,DIAS_ACUM_INT          ,SDO_MORATORIO
										,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
										,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
										,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
										,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
										,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
										,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
										,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
										,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
										,MONTO_VENCIDO          ,MTO_VENC_TRASP
										,MONTO_FINANCIADO       ,MONTO_RESERVADO
										,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
										,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
										,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
										,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
										,MTO_VENC_INT           ,MTO_VENC_TRA_INT
										,MTO_FINAN_VDO          ,MTO_RESER_INT
										,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
										,INT_TRA_NO_EXIG        ,SDO_TRAB4
										,ACT
								  FROM   BDICRED:SD_MAESDOS SOL
								  WHERE  SOL.NUM_CREDITO = pCredito
								  AND    SOL.EMPRESA   = pEmpresa;
			END IF;

			SELECT USER
				 || REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
			INTO VV_FOLIO
			FROM SD_FECHAS
			WHERE empresa = pEmpresa;

			-- *********************************************************
			-- INSERTA PRIMEROS 12 MESES DE LA TABLA DE AMORTIZACIONES *
			-- *********************************************************

			select min(fecha_cuota)
			into vFechaT
			from bdicred:sd_amortiza_credito
			where num_credito = pCredito
				  AND fecha_cuota >= monthadd(V_FECHA_APERT,-1);
				
		    IF (DAY(V_FECHA_APERT) > vDiaCorte AND DAY(V_FECHA_APERT) <= DAY(vFechaT)) OR (DAY(V_FECHA_APERT) = vDiaCorte) THEN
				--AAME Se Pregunta que no exista antes de insertar en la tabla SD_AMORTIZA_CREDITO
				IF NOT EXISTS (SELECT num_credito FROM SD_AMORTIZA_CREDITO WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN
		   
			   --Se considera la fecha_cuota que devuelve mas 1 mes, ya que la consulta es fecha_cuota > = a la fecha_hoy menos 1 mes.
					INSERT INTO bdicred:sd_amortiza_credito(empresa,num_credito,fecha_cuota,tipo_cuota,capital_mto_cuota,
					capital_debe,capital_pagado,capital_status,capital_status_ant,capital_fecha_pago,interes_debe    
					,interes_pagado,interes_status,interes_status_ant,interes_fecha_pago,iva_debe,iva_pagado,iva_status    
					,iva_status_ant,iva_fecha_pago,mora_provi_ordi,mora_provi_cope,mora_sdo_ordi,mora_sdo_ordi_pag    
					,mora_sdo_cope,mora_sdo_cope_pag,mora_bonificado,mora_status,mora_iva_debe,mora_iva_pagado    
					,mora_iva_status,mora_iva_fecha_pago,num_pago,campo_trabajo1,campo_trabajo2,campo_trabajo3,
					campo_trabajo4)
					SELECT
					empresa,cSolOro
					,monthadd(mdy(month(fecha_cuota),vDiaCorte,year(fecha_cuota)),1) 
					,tipo_cuota    
					,capital_mto_cuota    
					,capital_debe    
					,capital_pagado    
					,capital_status    
					,capital_status_ant    
					,capital_fecha_pago    
					,interes_debe    
					,interes_pagado    
					,interes_status    
					,interes_status_ant    
					,interes_fecha_pago    
					,iva_debe    
					,iva_pagado    
					,iva_status    
					,iva_status_ant    
					,iva_fecha_pago    
					,mora_provi_ordi    
					,mora_provi_cope    
					,mora_sdo_ordi    
					,mora_sdo_ordi_pag    
					,mora_sdo_cope    
					,mora_sdo_cope_pag    
					,mora_bonificado    
					,mora_status    
					,mora_iva_debe    
					,mora_iva_pagado    
					,mora_iva_status    
					,mora_iva_fecha_pago    
					,num_pago    
					,campo_trabajo1    
					,campo_trabajo2    
					,campo_trabajo3    
					,campo_trabajo4   
					FROM bdicred:sd_amortiza_credito
					WHERE num_credito = pCredito
					  AND fecha_cuota >= monthadd(V_FECHA_APERT,-1);	
				END IF;
					  
				--AAME Se Pregunta que no exista antes de insertar en la tabla sd_maecredanexo
				IF NOT EXISTS (SELECT num_credito FROM sd_maecredanexo WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN

					  --***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)

					INSERT INTO sd_maecredanexo
						(empresa,               num_credito,
						 dia_corte,             dias_gracia_mora,
						 tp_dias_calc_mora,     dias_fecha_max_pago,
						 tp_dias_fecha_pago,    cod_tasa_base_cte,
						 factor_sobretasa_cte,  sobretasa_cte,
						 tasa_interes_cte,      fecha_proceso,prox_fecha_pago)
					SELECT pEmpresa,               cSolOro,
						   def.dia_cuota,           def.gracia_calc_mora,
						   def.pago_adic_sig_cuo,   def.tipo_cliente,
						   def.maneja_linea,        def.cod_tasa_base,
						   def.factor_sobretasa,    def.sobretasa,
						   V_TASA_FAVOR,            V_FECHA_APERT,
						   monthadd(mdy(month(V_FECHA_APERT),VDIAPAGO,year(V_FECHA_APERT)),1) 
					  FROM sd_definicion def, sd_anexodefinicion b,
						   bdicred:sd_maecred c
					 WHERE c.empresa = pEmpresa
					   AND c.num_credito = pCredito
					   AND def.empresa = c.empresa
					   AND def.num_producto = pProducto
					   AND b.empresa = def.empresa
					   AND b.num_producto = pProducto
					   AND b.cod_prod = def.cod_tipcred;
				END IF;
			  
			ELSE 
								--AAME Se Pregunta que no exista antes de insertar en la tabla SD_AMORTIZA_CREDITO
				IF NOT EXISTS (SELECT num_credito FROM SD_AMORTIZA_CREDITO WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN
				
					INSERT INTO bdicred:sd_amortiza_credito(empresa,num_credito,fecha_cuota,tipo_cuota,capital_mto_cuota,
					capital_debe,capital_pagado,capital_status,capital_status_ant,capital_fecha_pago,interes_debe    
					,interes_pagado,interes_status,interes_status_ant,interes_fecha_pago,iva_debe,iva_pagado,iva_status    
					,iva_status_ant,iva_fecha_pago,mora_provi_ordi,mora_provi_cope,mora_sdo_ordi,mora_sdo_ordi_pag    
					,mora_sdo_cope,mora_sdo_cope_pag,mora_bonificado,mora_status,mora_iva_debe,mora_iva_pagado    
					,mora_iva_status,mora_iva_fecha_pago,num_pago,campo_trabajo1,campo_trabajo2,campo_trabajo3,
					campo_trabajo4)
					SELECT
					empresa    
					,cSolOro
					,mdy(month(fecha_cuota),vDiaCorte,year(fecha_cuota))
					,tipo_cuota    
					,capital_mto_cuota    
					,capital_debe    
					,capital_pagado    
					,capital_status    
					,capital_status_ant    
					,capital_fecha_pago    
					,interes_debe    
					,interes_pagado    
					,interes_status    
					,interes_status_ant    
					,interes_fecha_pago    
					,iva_debe    
					,iva_pagado    
					,iva_status    
					,iva_status_ant    
					,iva_fecha_pago    
					,mora_provi_ordi    
					,mora_provi_cope    
					,mora_sdo_ordi    
					,mora_sdo_ordi_pag    
					,mora_sdo_cope    
					,mora_sdo_cope_pag    
					,mora_bonificado    
					,mora_status    
					,mora_iva_debe    
					,mora_iva_pagado    
					,mora_iva_status    
					,mora_iva_fecha_pago    
					,num_pago    
					,campo_trabajo1    
					,campo_trabajo2    
					,campo_trabajo3    
					,campo_trabajo4   
					FROM bdicred:sd_amortiza_credito
					WHERE num_credito = pCredito
					AND fecha_cuota >= monthadd(V_FECHA_APERT,-1);	
				END IF;
				--AAME Se Pregunta que no exista antes de insertar en la tabla sd_maecredanexo
				IF NOT EXISTS (SELECT num_credito FROM sd_maecredanexo WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN
	            
					--***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)
	            
					INSERT INTO sd_maecredanexo
						(empresa,               num_credito,
						dia_corte,             dias_gracia_mora,
						tp_dias_calc_mora,     dias_fecha_max_pago,
						tp_dias_fecha_pago,    cod_tasa_base_cte,
						factor_sobretasa_cte,  sobretasa_cte,
						tasa_interes_cte,      fecha_proceso,prox_fecha_pago)
					SELECT pEmpresa,               cSolOro,
						def.dia_cuota,           def.gracia_calc_mora,
						def.pago_adic_sig_cuo,   def.tipo_cliente,
						def.maneja_linea,        def.cod_tasa_base,
						def.factor_sobretasa,    def.sobretasa,
						V_TASA_FAVOR,            V_FECHA_APERT,
						mdy(month(V_FECHA_APERT),VDIAPAGO,year(V_FECHA_APERT)) 
					FROM sd_definicion def, sd_anexodefinicion b,
						bdicred:sd_maecred c
					WHERE c.empresa = pEmpresa
					AND c.num_credito = pCredito
					AND def.empresa = c.empresa
					AND def.num_producto = pProducto
					AND b.empresa = def.empresa
					AND b.num_producto = pProducto
					AND b.cod_prod = def.cod_tipcred;
				END IF;
			END IF;
			--AAME Se Pregunta que no exista antes de insertar en la tabla sd_indicador_cred
			IF NOT EXISTS (SELECT num_credito FROM sd_indicador_cred WHERE empresa = pEmpresa AND num_credito = cSolOro) THEN

				--Tabla para guardar fecha de ultima compra, ultima disposicion, etc
				INSERT INTO bdicred:sd_indicador_cred
						  (empresa,num_credito, fecha_alta)
					  VALUES(pEmpresa,cSolOro,V_FECHA_APERT );
			END IF;
			--AAME Se Pregunta que no exista antes de insertar en la tabla sd_sdodiario
			IF NOT EXISTS (SELECT num_credito FROM sd_sdodiario WHERE fecha = mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) AND num_credito = cSolOro) THEN

				-- CLONADO DE TABLA SD_SDODIARIO
				INSERT INTO sd_sdodiario(fecha,num_credito,sucursal,capvig1,captrans1,capvencnoexig1,capvenexig1,intvig1,intvenc1,ivaintvig1,ivaintvenc1,capvig2,captrans2,capvencnoexig2,capvenexig2,intvig2,intvenc2,ivaintvig2,ivaintvenc2,capvig3,captrans3,capvencnoexig3,capvenexig3,intvig3,intvenc3,ivaintvig3,ivaintvenc3,capvig4,captrans4,capvencnoexig4,capvenexig4,intvig4,intvenc4,ivaintvig4,ivaintvenc4,capvig5,captrans5,capvencnoexig5,capvenexig5,intvig5,intvenc5,ivaintvig5,ivaintvenc5,capvig6,captrans6,capvencnoexig6,capvenexig6,intvig6,intvenc6,ivaintvig6,ivaintvenc6,capvig7,captrans7,capvencnoexig7,capvenexig7,intvig7,intvenc7,ivaintvig7,ivaintvenc7,capvig8,captrans8,capvencnoexig8,capvenexig8,intvig8,intvenc8,ivaintvig8,ivaintvenc8,capvig9,captrans9,capvencnoexig9,capvenexig9,intvig9,intvenc9,ivaintvig9,ivaintvenc9,capvig10,captrans10,capvencnoexig10,capvenexig10,intvig10,intvenc10,ivaintvig10,ivaintvenc10,capvig11,captrans11,capvencnoexig11,capvenexig11,intvig11,intvenc11,ivaintvig11,ivaintvenc11,capvig12,captrans12,capvencnoexig12,capvenexig12,intvig12,intvenc12,ivaintvig12,ivaintvenc12,capvig13,captrans13,capvencnoexig13,capvenexig13,intvig13,intvenc13,ivaintvig13,ivaintvenc13,capvig14,captrans14,capvencnoexig14,capvenexig14,intvig14,intvenc14,ivaintvig14,ivaintvenc14,capvig15,captrans15,capvencnoexig15,capvenexig15,intvig15,intvenc15,ivaintvig15,ivaintvenc15,capvig16,captrans16,capvencnoexig16,capvenexig16,intvig16,intvenc16,ivaintvig16,ivaintvenc16,capvig17,captrans17,capvencnoexig17,capvenexig17,intvig17,intvenc17,ivaintvig17,ivaintvenc17,capvig18,captrans18,capvencnoexig18,capvenexig18,intvig18,intvenc18,ivaintvig18,ivaintvenc18,capvig19,captrans19,capvencnoexig19,capvenexig19,intvig19,intvenc19,ivaintvig19,ivaintvenc19,capvig20,captrans20,capvencnoexig20,capvenexig20,intvig20,intvenc20,ivaintvig20,ivaintvenc20,capvig21,captrans21,capvencnoexig21,capvenexig21,intvig21,intvenc21,ivaintvig21,ivaintvenc21,capvig22,captrans22,capvencnoexig22,capvenexig22,intvig22,intvenc22,ivaintvig22,ivaintvenc22,capvig23,captrans23,capvencnoexig23,capvenexig23,intvig23,intvenc23,ivaintvig23,ivaintvenc23,capvig24,captrans24,capvencnoexig24,capvenexig24,intvig24,intvenc24,ivaintvig24,ivaintvenc24,capvig25,captrans25,capvencnoexig25,capvenexig25,intvig25,intvenc25,ivaintvig25,ivaintvenc25,capvig26,captrans26,capvencnoexig26,capvenexig26,intvig26,intvenc26,ivaintvig26,ivaintvenc26,capvig27,captrans27,capvencnoexig27,capvenexig27,intvig27,intvenc27,ivaintvig27,ivaintvenc27,capvig28,captrans28,capvencnoexig28,capvenexig28,intvig28,intvenc28,ivaintvig28,ivaintvenc28,capvig29,captrans29,capvencnoexig29,capvenexig29,intvig29,intvenc29,ivaintvig29,ivaintvenc29,capvig30,captrans30,capvencnoexig30,capvenexig30,intvig30,intvenc30,ivaintvig30,ivaintvenc30,capvig31,captrans31,capvencnoexig31,capvenexig31,intvig31,intvenc31,ivaintvig31,ivaintvenc31,diacapvig,acucapvig,diacaptra,acucaptra,diacapvennoexig,acucapvennoexig,diacapvencexig,acucapvencexig,meses_vencidos1,meses_vencidos2,meses_vencidos3,meses_vencidos4,meses_vencidos5,meses_vencidos6,meses_vencidos7,meses_vencidos8,meses_vencidos9,meses_vencidos10,meses_vencidos11,meses_vencidos12,meses_vencidos13,meses_vencidos14,meses_vencidos15,meses_vencidos16,meses_vencidos17,meses_vencidos18,meses_vencidos19,meses_vencidos20,meses_vencidos21,meses_vencidos22,meses_vencidos23,meses_vencidos24,meses_vencidos25,meses_vencidos26,meses_vencidos27,meses_vencidos28,meses_vencidos29,meses_vencidos30,meses_vencidos31,moratorios1,moratorios2,moratorios3,moratorios4,moratorios5,moratorios6,moratorios7,moratorios8,moratorios9,moratorios10,moratorios11,moratorios12,moratorios13,moratorios14,moratorios15,moratorios16,moratorios17,moratorios18,moratorios19,moratorios20,moratorios21,moratorios22,moratorios23,moratorios24,moratorios25,moratorios26,moratorios27,moratorios28,moratorios29,moratorios30,moratorios31)
				SELECT fecha,cSolOro,sucursal,capvig1,captrans1,capvencnoexig1,capvenexig1,intvig1,intvenc1,ivaintvig1,ivaintvenc1,capvig2,captrans2,capvencnoexig2,capvenexig2,intvig2,intvenc2,ivaintvig2,ivaintvenc2,capvig3,captrans3,capvencnoexig3,capvenexig3,intvig3,intvenc3,ivaintvig3,ivaintvenc3,capvig4,captrans4,capvencnoexig4,capvenexig4,intvig4,intvenc4,ivaintvig4,ivaintvenc4,capvig5,captrans5,capvencnoexig5,capvenexig5,intvig5,intvenc5,ivaintvig5,ivaintvenc5,capvig6,captrans6,capvencnoexig6,capvenexig6,intvig6,intvenc6,ivaintvig6,ivaintvenc6,capvig7,captrans7,capvencnoexig7,capvenexig7,intvig7,intvenc7,ivaintvig7,ivaintvenc7,capvig8,captrans8,capvencnoexig8,capvenexig8,intvig8,intvenc8,ivaintvig8,ivaintvenc8,capvig9,captrans9,capvencnoexig9,capvenexig9,intvig9,intvenc9,ivaintvig9,ivaintvenc9,capvig10,captrans10,capvencnoexig10,capvenexig10,intvig10,intvenc10,ivaintvig10,ivaintvenc10,capvig11,captrans11,capvencnoexig11,capvenexig11,intvig11,intvenc11,ivaintvig11,ivaintvenc11,capvig12,captrans12,capvencnoexig12,capvenexig12,intvig12,intvenc12,ivaintvig12,ivaintvenc12,capvig13,captrans13,capvencnoexig13,capvenexig13,intvig13,intvenc13,ivaintvig13,ivaintvenc13,capvig14,captrans14,capvencnoexig14,capvenexig14,intvig14,intvenc14,ivaintvig14,ivaintvenc14,capvig15,captrans15,capvencnoexig15,capvenexig15,intvig15,intvenc15,ivaintvig15,ivaintvenc15,capvig16,captrans16,capvencnoexig16,capvenexig16,intvig16,intvenc16,ivaintvig16,ivaintvenc16,capvig17,captrans17,capvencnoexig17,capvenexig17,intvig17,intvenc17,ivaintvig17,ivaintvenc17,capvig18,captrans18,capvencnoexig18,capvenexig18,intvig18,intvenc18,ivaintvig18,ivaintvenc18,capvig19,captrans19,capvencnoexig19,capvenexig19,intvig19,intvenc19,ivaintvig19,ivaintvenc19,capvig20,captrans20,capvencnoexig20,capvenexig20,intvig20,intvenc20,ivaintvig20,ivaintvenc20,capvig21,captrans21,capvencnoexig21,capvenexig21,intvig21,intvenc21,ivaintvig21,ivaintvenc21,capvig22,captrans22,capvencnoexig22,capvenexig22,intvig22,intvenc22,ivaintvig22,ivaintvenc22,capvig23,captrans23,capvencnoexig23,capvenexig23,intvig23,intvenc23,ivaintvig23,ivaintvenc23,capvig24,captrans24,capvencnoexig24,capvenexig24,intvig24,intvenc24,ivaintvig24,ivaintvenc24,capvig25,captrans25,capvencnoexig25,capvenexig25,intvig25,intvenc25,ivaintvig25,ivaintvenc25,capvig26,captrans26,capvencnoexig26,capvenexig26,intvig26,intvenc26,ivaintvig26,ivaintvenc26,capvig27,captrans27,capvencnoexig27,capvenexig27,intvig27,intvenc27,ivaintvig27,ivaintvenc27,capvig28,captrans28,capvencnoexig28,capvenexig28,intvig28,intvenc28,ivaintvig28,ivaintvenc28,capvig29,captrans29,capvencnoexig29,capvenexig29,intvig29,intvenc29,ivaintvig29,ivaintvenc29,capvig30,captrans30,capvencnoexig30,capvenexig30,intvig30,intvenc30,ivaintvig30,ivaintvenc30,capvig31,captrans31,capvencnoexig31,capvenexig31,intvig31,intvenc31,ivaintvig31,ivaintvenc31,diacapvig,acucapvig,diacaptra,acucaptra,diacapvennoexig,acucapvennoexig,diacapvencexig,acucapvencexig,meses_vencidos1,meses_vencidos2,meses_vencidos3,meses_vencidos4,meses_vencidos5,meses_vencidos6,meses_vencidos7,meses_vencidos8,meses_vencidos9,meses_vencidos10,meses_vencidos11,meses_vencidos12,meses_vencidos13,meses_vencidos14,meses_vencidos15,meses_vencidos16,meses_vencidos17,meses_vencidos18,meses_vencidos19,meses_vencidos20,meses_vencidos21,meses_vencidos22,meses_vencidos23,meses_vencidos24,meses_vencidos25,meses_vencidos26,meses_vencidos27,meses_vencidos28,meses_vencidos29,meses_vencidos30,meses_vencidos31,moratorios1,moratorios2,moratorios3,moratorios4,moratorios5,moratorios6,moratorios7,moratorios8,moratorios9,moratorios10,moratorios11,moratorios12,moratorios13,moratorios14,moratorios15,moratorios16,moratorios17,moratorios18,moratorios19,moratorios20,moratorios21,moratorios22,moratorios23,moratorios24,moratorios25,moratorios26,moratorios27,moratorios28,moratorios29,moratorios30,moratorios31
				FROM sd_sdodiario 
				WHERE  fecha = mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT))		
				and num_credito =pCredito;					  

				-- CLONADO DE TABLA SD_SDODIARIO
				INSERT INTO sd_sdodiario(fecha,num_credito,sucursal,capvig1,captrans1,capvencnoexig1,capvenexig1,intvig1,intvenc1,ivaintvig1,ivaintvenc1,capvig2,captrans2,capvencnoexig2,capvenexig2,intvig2,intvenc2,ivaintvig2,ivaintvenc2,capvig3,captrans3,capvencnoexig3,capvenexig3,intvig3,intvenc3,ivaintvig3,ivaintvenc3,capvig4,captrans4,capvencnoexig4,capvenexig4,intvig4,intvenc4,ivaintvig4,ivaintvenc4,capvig5,captrans5,capvencnoexig5,capvenexig5,intvig5,intvenc5,ivaintvig5,ivaintvenc5,capvig6,captrans6,capvencnoexig6,capvenexig6,intvig6,intvenc6,ivaintvig6,ivaintvenc6,capvig7,captrans7,capvencnoexig7,capvenexig7,intvig7,intvenc7,ivaintvig7,ivaintvenc7,capvig8,captrans8,capvencnoexig8,capvenexig8,intvig8,intvenc8,ivaintvig8,ivaintvenc8,capvig9,captrans9,capvencnoexig9,capvenexig9,intvig9,intvenc9,ivaintvig9,ivaintvenc9,capvig10,captrans10,capvencnoexig10,capvenexig10,intvig10,intvenc10,ivaintvig10,ivaintvenc10,capvig11,captrans11,capvencnoexig11,capvenexig11,intvig11,intvenc11,ivaintvig11,ivaintvenc11,capvig12,captrans12,capvencnoexig12,capvenexig12,intvig12,intvenc12,ivaintvig12,ivaintvenc12,capvig13,captrans13,capvencnoexig13,capvenexig13,intvig13,intvenc13,ivaintvig13,ivaintvenc13,capvig14,captrans14,capvencnoexig14,capvenexig14,intvig14,intvenc14,ivaintvig14,ivaintvenc14,capvig15,captrans15,capvencnoexig15,capvenexig15,intvig15,intvenc15,ivaintvig15,ivaintvenc15,capvig16,captrans16,capvencnoexig16,capvenexig16,intvig16,intvenc16,ivaintvig16,ivaintvenc16,capvig17,captrans17,capvencnoexig17,capvenexig17,intvig17,intvenc17,ivaintvig17,ivaintvenc17,capvig18,captrans18,capvencnoexig18,capvenexig18,intvig18,intvenc18,ivaintvig18,ivaintvenc18,capvig19,captrans19,capvencnoexig19,capvenexig19,intvig19,intvenc19,ivaintvig19,ivaintvenc19,capvig20,captrans20,capvencnoexig20,capvenexig20,intvig20,intvenc20,ivaintvig20,ivaintvenc20,capvig21,captrans21,capvencnoexig21,capvenexig21,intvig21,intvenc21,ivaintvig21,ivaintvenc21,capvig22,captrans22,capvencnoexig22,capvenexig22,intvig22,intvenc22,ivaintvig22,ivaintvenc22,capvig23,captrans23,capvencnoexig23,capvenexig23,intvig23,intvenc23,ivaintvig23,ivaintvenc23,capvig24,captrans24,capvencnoexig24,capvenexig24,intvig24,intvenc24,ivaintvig24,ivaintvenc24,capvig25,captrans25,capvencnoexig25,capvenexig25,intvig25,intvenc25,ivaintvig25,ivaintvenc25,capvig26,captrans26,capvencnoexig26,capvenexig26,intvig26,intvenc26,ivaintvig26,ivaintvenc26,capvig27,captrans27,capvencnoexig27,capvenexig27,intvig27,intvenc27,ivaintvig27,ivaintvenc27,capvig28,captrans28,capvencnoexig28,capvenexig28,intvig28,intvenc28,ivaintvig28,ivaintvenc28,capvig29,captrans29,capvencnoexig29,capvenexig29,intvig29,intvenc29,ivaintvig29,ivaintvenc29,capvig30,captrans30,capvencnoexig30,capvenexig30,intvig30,intvenc30,ivaintvig30,ivaintvenc30,capvig31,captrans31,capvencnoexig31,capvenexig31,intvig31,intvenc31,ivaintvig31,ivaintvenc31,diacapvig,acucapvig,diacaptra,acucaptra,diacapvennoexig,acucapvennoexig,diacapvencexig,acucapvencexig,meses_vencidos1,meses_vencidos2,meses_vencidos3,meses_vencidos4,meses_vencidos5,meses_vencidos6,meses_vencidos7,meses_vencidos8,meses_vencidos9,meses_vencidos10,meses_vencidos11,meses_vencidos12,meses_vencidos13,meses_vencidos14,meses_vencidos15,meses_vencidos16,meses_vencidos17,meses_vencidos18,meses_vencidos19,meses_vencidos20,meses_vencidos21,meses_vencidos22,meses_vencidos23,meses_vencidos24,meses_vencidos25,meses_vencidos26,meses_vencidos27,meses_vencidos28,meses_vencidos29,meses_vencidos30,meses_vencidos31,moratorios1,moratorios2,moratorios3,moratorios4,moratorios5,moratorios6,moratorios7,moratorios8,moratorios9,moratorios10,moratorios11,moratorios12,moratorios13,moratorios14,moratorios15,moratorios16,moratorios17,moratorios18,moratorios19,moratorios20,moratorios21,moratorios22,moratorios23,moratorios24,moratorios25,moratorios26,moratorios27,moratorios28,moratorios29,moratorios30,moratorios31)
				SELECT fecha,cSolOro,sucursal,capvig1,captrans1,capvencnoexig1,capvenexig1,intvig1,intvenc1,ivaintvig1,ivaintvenc1,capvig2,captrans2,capvencnoexig2,capvenexig2,intvig2,intvenc2,ivaintvig2,ivaintvenc2,capvig3,captrans3,capvencnoexig3,capvenexig3,intvig3,intvenc3,ivaintvig3,ivaintvenc3,capvig4,captrans4,capvencnoexig4,capvenexig4,intvig4,intvenc4,ivaintvig4,ivaintvenc4,capvig5,captrans5,capvencnoexig5,capvenexig5,intvig5,intvenc5,ivaintvig5,ivaintvenc5,capvig6,captrans6,capvencnoexig6,capvenexig6,intvig6,intvenc6,ivaintvig6,ivaintvenc6,capvig7,captrans7,capvencnoexig7,capvenexig7,intvig7,intvenc7,ivaintvig7,ivaintvenc7,capvig8,captrans8,capvencnoexig8,capvenexig8,intvig8,intvenc8,ivaintvig8,ivaintvenc8,capvig9,captrans9,capvencnoexig9,capvenexig9,intvig9,intvenc9,ivaintvig9,ivaintvenc9,capvig10,captrans10,capvencnoexig10,capvenexig10,intvig10,intvenc10,ivaintvig10,ivaintvenc10,capvig11,captrans11,capvencnoexig11,capvenexig11,intvig11,intvenc11,ivaintvig11,ivaintvenc11,capvig12,captrans12,capvencnoexig12,capvenexig12,intvig12,intvenc12,ivaintvig12,ivaintvenc12,capvig13,captrans13,capvencnoexig13,capvenexig13,intvig13,intvenc13,ivaintvig13,ivaintvenc13,capvig14,captrans14,capvencnoexig14,capvenexig14,intvig14,intvenc14,ivaintvig14,ivaintvenc14,capvig15,captrans15,capvencnoexig15,capvenexig15,intvig15,intvenc15,ivaintvig15,ivaintvenc15,capvig16,captrans16,capvencnoexig16,capvenexig16,intvig16,intvenc16,ivaintvig16,ivaintvenc16,capvig17,captrans17,capvencnoexig17,capvenexig17,intvig17,intvenc17,ivaintvig17,ivaintvenc17,capvig18,captrans18,capvencnoexig18,capvenexig18,intvig18,intvenc18,ivaintvig18,ivaintvenc18,capvig19,captrans19,capvencnoexig19,capvenexig19,intvig19,intvenc19,ivaintvig19,ivaintvenc19,capvig20,captrans20,capvencnoexig20,capvenexig20,intvig20,intvenc20,ivaintvig20,ivaintvenc20,capvig21,captrans21,capvencnoexig21,capvenexig21,intvig21,intvenc21,ivaintvig21,ivaintvenc21,capvig22,captrans22,capvencnoexig22,capvenexig22,intvig22,intvenc22,ivaintvig22,ivaintvenc22,capvig23,captrans23,capvencnoexig23,capvenexig23,intvig23,intvenc23,ivaintvig23,ivaintvenc23,capvig24,captrans24,capvencnoexig24,capvenexig24,intvig24,intvenc24,ivaintvig24,ivaintvenc24,capvig25,captrans25,capvencnoexig25,capvenexig25,intvig25,intvenc25,ivaintvig25,ivaintvenc25,capvig26,captrans26,capvencnoexig26,capvenexig26,intvig26,intvenc26,ivaintvig26,ivaintvenc26,capvig27,captrans27,capvencnoexig27,capvenexig27,intvig27,intvenc27,ivaintvig27,ivaintvenc27,capvig28,captrans28,capvencnoexig28,capvenexig28,intvig28,intvenc28,ivaintvig28,ivaintvenc28,capvig29,captrans29,capvencnoexig29,capvenexig29,intvig29,intvenc29,ivaintvig29,ivaintvenc29,capvig30,captrans30,capvencnoexig30,capvenexig30,intvig30,intvenc30,ivaintvig30,ivaintvenc30,capvig31,captrans31,capvencnoexig31,capvenexig31,intvig31,intvenc31,ivaintvig31,ivaintvenc31,diacapvig,acucapvig,diacaptra,acucaptra,diacapvennoexig,acucapvennoexig,diacapvencexig,acucapvencexig,meses_vencidos1,meses_vencidos2,meses_vencidos3,meses_vencidos4,meses_vencidos5,meses_vencidos6,meses_vencidos7,meses_vencidos8,meses_vencidos9,meses_vencidos10,meses_vencidos11,meses_vencidos12,meses_vencidos13,meses_vencidos14,meses_vencidos15,meses_vencidos16,meses_vencidos17,meses_vencidos18,meses_vencidos19,meses_vencidos20,meses_vencidos21,meses_vencidos22,meses_vencidos23,meses_vencidos24,meses_vencidos25,meses_vencidos26,meses_vencidos27,meses_vencidos28,meses_vencidos29,meses_vencidos30,meses_vencidos31,moratorios1,moratorios2,moratorios3,moratorios4,moratorios5,moratorios6,moratorios7,moratorios8,moratorios9,moratorios10,moratorios11,moratorios12,moratorios13,moratorios14,moratorios15,moratorios16,moratorios17,moratorios18,moratorios19,moratorios20,moratorios21,moratorios22,moratorios23,moratorios24,moratorios25,moratorios26,moratorios27,moratorios28,moratorios29,moratorios30,moratorios31
				FROM sd_sdodiario 
				WHERE  fecha = mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month
				and num_credito =pCredito;					  
			END IF;

				/* AAME 20160829 RQI 27 122 SE REALIZARAN EN PROCESO NOCTURNO EL CLONADO DE TABLAS
				--CLONADO DE TABLA DE SD_MAECREDCONT
				INSERT INTO bdicred:sd_maecredcont(fecha, empresa, num_credito, num_producto, ejecutivo, numcte, divisa, sucursal, id_origen, origen, 
				cod_tipo_linea, cod_linea, porc_rec_prop, status_cred, bandera_renovac, bandera_prorroga, periodo_plazo, 
				plazo, fecha_apertura, fecha_vencim, period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int, 
				tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa, tasa_interes, cod_tasa_mora, sobretasa_mora, 
				fact_sobret_mora, tasa_moratorios, fecha_pago_cap, fecha_pago_int, es_fisica, bandera_fi_fo, codigo_pro, 
				superficie, actividad, cal_edos_fin, tipo_calculo, admite_tlp, rel_garcred, id_unidad_prod, num_aper_ant, 
				rev_tasa_var_per, dia_para_revisar, cod_prod, bandera_ministra, num_fideicomiso, credito_externo, 
				gracia_capital, diferimiento_int, fecha_fin_prorrateo, campo_trab1, campo_trab2, campo_trab3, campo_trab4, 
				calificacion_riesgo, cod_agricola, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, 
				sobretasa_techo, factor_techo, tasa_techo, cod_caract, cod_caract_2)
				SELECT fecha, empresa, cSolOro, pProducto, ejecutivo, numcte, divisa, sucursal, id_origen, origen, 
				cod_tipo_linea, cod_linea, porc_rec_prop, status_cred, bandera_renovac, bandera_prorroga, periodo_plazo, 
				plazo, fecha_apertura, fecha_vencim, period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int, 
				tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa, tasa_interes, cod_tasa_mora, sobretasa_mora, 
				fact_sobret_mora, tasa_moratorios, fecha_pago_cap, fecha_pago_int, es_fisica, bandera_fi_fo, codigo_pro, 
				superficie, actividad, cal_edos_fin, tipo_calculo, admite_tlp, rel_garcred, id_unidad_prod, num_aper_ant, 
				rev_tasa_var_per, dia_para_revisar, cod_prod, bandera_ministra, num_fideicomiso, credito_externo, 
				gracia_capital, diferimiento_int, fecha_fin_prorrateo, campo_trab1, campo_trab2, campo_trab3, campo_trab4, 
				calificacion_riesgo, cod_agricola, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, 
				sobretasa_techo, factor_techo, tasa_techo, cod_caract, cod_caract_2
				FROM bdicred:sd_maecredcont
				WHERE empresa=pEmpresa 
				AND num_credito = pCredito;   
				
				--CLONADO DE TABLA de SD_MAESDOSCONT
				INSERT INTO sd_maesdoscont(fecha,empresa,num_credito, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4)
				SELECT fecha,empresa,cSolOro, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4
				FROM sd_maesdoscont WHERE  empresa= pEmpresa and num_credito =pCredito;

				--CLONADO DE TABLA DE SD_MAESDOSHIST
				INSERT INTO sd_maesdoshist(fecha,
				empresa,num_credito, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4)
				SELECT mdy(month(fecha),vDiaCorte,year(fecha)),
				empresa,cSolOro, fecha_ult_mov,sdo_int_anticip,sdo_int_ant_dev,sdo_intereses,
				sdo_dia_ant_int,sdo_mes_ant_int,sdo_acum_mes_int,sdo_retenido,sdo_acum_cap_int,sdo_exig_int,
				sdo_no_exig,provision_normal,dias_acum_int,sdo_moratorio,sdo_dia_ant_mor,sdo_mes_ant_mor,
				sdo_contab_mora,dias_acum_mora,sdo_capital,sdo_cap_insoluto,sdo_dia_ant_cap,sdo_mes_ant_cap,
				sdo_acum_mes_cap,mto_capitalizado,mto_ministra_cap,cargos_dia_cap,abonos_dia_cap,cargos_mes_cap,
				abonos_mes_cap,dias_acum_cap,monto_vencido,mto_venc_trasp,monto_financiado,monto_reservado,
				sdo_acum_vencido,dias_acum_intper,sdo_global_int,sdo_acum_intper,monto_otorgado,provi_venc_normal,
				provi_venc_anticip,cap_tras_no_venci,mto_venc_int,mto_venc_tra_int,mto_finan_vdo,mto_reser_int,
				mto_fin_ven_trasp,mto_fin_vig_trasp,int_tra_no_exig,sdo_trab4
				FROM sd_maesdoshist WHERE  empresa= pEmpresa and num_credito =pCredito;

				--CLONADO DE TABLA DE SD_HIST_RESERVA
				INSERT INTO sd_hist_reserva(empresa, fecha_corte,	num_credito, fecha_cierre,grado_riesgo,
				fecha_apertura,antecedente_buro,status_cred,linea_autorizada,limite_credito,interes_cred_ven,saldo_corte,
				saldo_cierre,pago_minimo,pagos_realizados,
				reserva_int_cred_ven,reserva_buro,reserva_calificacion,porcentaje_reserva,meses_antiguedad,
				probabilidad_incumplimiento,severidad_perdida,exposicion_incumplimiento,impagos_consecutivos,
				impagos_historicos,porcentaje_pago,porcentaje_uso,num_periodos,exposicion_inc_gradual,
				grado_riesgo_gradual,reserva_calificacion_gradual,porcentaje_reserva_gradual,reserva_buro_gradual,
				reserva_int_cred_ven_gradual,reserva_calif_mes_anterior,grado_riesgo_bancoppel,
				grado_riesgo_edo_resultados,reserva_edo_resultados,porcentaje_reserva_edo_resultados,numcte,
				cta_credisolucion,status_fin_mes,saldo_corte2,saldo_corte3,saldo_corte4,pagos_realizados1,
				pagos_realizados2,pagos_realizados3,pagos_realizados4,saldo_corte_credisolucion,
				saldo_cierre_credisolucion,monto_pagar_inst,monto_pagar_rep_sic,ant_acreditado_inst,grado_riesgo_alto,
				grado_riesgo_medio,grado_riesgo_bajo,gveces1,gveces2,gveces3,bkatr)
				SELECT 
				empresa, mdy(month(fecha_corte),vDiaCorte,year(fecha_corte)),
				cSolOro, fecha_cierre,grado_riesgo,fecha_apertura,antecedente_buro,status_cred,
				linea_autorizada,limite_credito,interes_cred_ven,saldo_corte,saldo_cierre,pago_minimo,pagos_realizados,
				reserva_int_cred_ven,reserva_buro,reserva_calificacion,porcentaje_reserva,meses_antiguedad,
				probabilidad_incumplimiento,severidad_perdida,exposicion_incumplimiento,impagos_consecutivos,
				impagos_historicos,porcentaje_pago,porcentaje_uso,num_periodos,exposicion_inc_gradual,
				grado_riesgo_gradual,reserva_calificacion_gradual,porcentaje_reserva_gradual,reserva_buro_gradual,
				reserva_int_cred_ven_gradual,reserva_calif_mes_anterior,grado_riesgo_bancoppel,
				grado_riesgo_edo_resultados,reserva_edo_resultados,porcentaje_reserva_edo_resultados,numcte,
				cta_credisolucion,status_fin_mes,saldo_corte2,saldo_corte3,saldo_corte4,pagos_realizados1,
				pagos_realizados2,pagos_realizados3,pagos_realizados4,saldo_corte_credisolucion,
				saldo_cierre_credisolucion,monto_pagar_inst,monto_pagar_rep_sic,ant_acreditado_inst,grado_riesgo_alto,
				grado_riesgo_medio,grado_riesgo_bajo,gveces1,gveces2,gveces3,bkatr    
				FROM   sd_hist_reserva 
				WHERE  empresa= pEmpresa and num_credito =pCredito;*/

	
			-- SE GENERA EL FOLIO
			CALL bdicheq:sp_generafolionomina(P_EJECUTIVO) RETURNING cCodRet, vFolio;

			IF CstatusSol IN ('AA','E1') THEN
				-----------------------------------------
				--- PROCESO DE LIQUIDACION DE CREDITO CLASICA---
				-----------------------------------------
				CALL bdicred:sp_liquida_cred_upgrade (pEmpresa,pCredito,vFolio, dcTotalLiqCSG) RETURNING vCodRet;

				IF vCodRet::integer <> 0 THEN
				
					--MACM RQM 101584 TDC INFINITE, Se anexa reverso de operacion
					EXECUTE PROCEDURE reversion(pEmpresa,VV_SUCURSAL,P_EJECUTIVO,
					vFolio, "A")
					INTO  P_ERROR;	
					-- Actualizacion de credito en bitacora de upgrade cuando pase un error
					UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
					WHERE num_credito = pCredito;
					--En caso de error se elimina el registro de la nueva tarjeta
					DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
					UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
					UPDATE intercard:tarjeta 
					SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
					WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
					DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

					LET cCodRet = vCodRet;
					LET cMensajeRet='Error en proceso de liquida credito upgrade';
					RETURN cCodRet, cMensajeRet;
				END IF;
			END IF;
				
			-- Actualizacion de credito de oro para relacionarlo con el Credito de clasica
			UPDATE sd_maecred SET credito_externo = pCredito WHERE num_credito = cSolOro;

			/*
			IF pProducto = "5400" THEN
				UPDATE bdicred:sd_tarjeta  SET num_credito = cSolOro, prodtarjeta=pProducto, secuencia=1, status_tar = 'A' WHERE num_tarjeta = pTarjetaOro;
				UPDATE intercard:tarjetacuenta  SET numcuenta = cSolOro WHERE numtarjeta = pTarjetaOro;
				
				if (NVL(Scodproducto,'') <> '') then
					UPDATE intercard:tarjeta SET codproductotarjeta = Scodproducto, CodStatusTarjeta='ACT' WHERE numtarjeta = pTarjetaOro;
				ELSE
					UPDATE intercard:tarjeta SET CodStatusTarjeta='ACT' WHERE numtarjeta = pTarjetaOro;
				end if;
			ELSE*/
			
				-- Actualizacion de tarjeta de clasica por la cuenta de credito Oro
				UPDATE bdicred:sd_tarjeta  SET num_credito = cSolOro, prodtarjeta=pProducto, secuencia=1 WHERE num_tarjeta = pTarjetaOro;
				UPDATE intercard:tarjetacuenta  SET numcuenta = cSolOro WHERE numtarjeta = pTarjetaOro;
				-- Actualiza producto de la tarjeta nueva en intercard INI
						
				if (NVL(Scodproducto,'') <> '') then
					UPDATE intercard:tarjeta SET codproductotarjeta = Scodproducto WHERE numtarjeta = pTarjetaOro;
				end if;				
			--END IF;	
					
			-- Actualiza producto de la tarjeta nueva en intercard FIN
			LET iSecuencia = 2;
			--AAME 20160829 RQI 27 122 Se agrega flujo de Adicionales
			FOREACH WITH HOLD 
			-- AAME 20180821 INC 25 179 Se identifican ctes adicionales y su solicitud de plastico se liga al credito upgrade
				SELECT a.numerotarjeta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1, b.nombre2, b.rfc, c.fecha_nac 
				INTO cNumtarjadi,cnumcteadi, cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento
				FROM bdicred:sd_credito_upgrade a, bdinteg:si_cliente b, bdinteg:si_ctepf c
				WHERE a.empresa = b.empresa 
				AND a.numcte= b.numcte 
				AND b.numcte = c.numcte
				AND num_credito = pCredito
				AND tipotar='ADI'				
				
				SELECT DM.numtarjeta, DM.IdSolicitud 
				INTO cTarAdicUpgrade, cidsolicitud
				FROM intercard:SolicitudTarjeta ST 
				INNER JOIN intercard:Detalle_Maquila DM ON ST.IdSolicitud=DM.IdSolicitud 
				WHERE ST.IdSolicitud >= 1 AND ST.NumCuenta= pCredito AND ST.numcliente = cnumcteadi;				
				
				--MACM RQM 10 1584 TDC INFINITE, Omitir la cancelacion y agregar el adicional con el nuevo credito
				
				UPDATE sd_tarjeta  SET status_tar='C' WHERE num_tarjeta = cNumtarjadi;
				UPDATE intercard:tarjeta  SET codstatustarjeta='CAN' WHERE numtarjeta = cNumtarjadi;														
				UPDATE intercard:solicitudtarjeta SET numcuenta=cSolOro WHERE idsolicitud = cidsolicitud;
				INSERT INTO sd_adicionalespendientes(empresa,NumCteTitular,NumTarjetaTitular,NumCteAdicional,Credito,Apell_Paterno,Apell_Materno,Nombre1,Nombre2,Rfc,FechaNacimiento,ProductoCredito,TarjetaReposicion)
				VALUES (pEmpresa,cNumcte,pTarjetaOro,cnumcteadi,cSolOro,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,pProducto, '');
			
				
				-- Actualizacion de credito de adicional en bitacora de upgrade
				UPDATE bdicred:sd_credito_upgrade  SET numero_credito_upgrade = cSolOro, numerotarjeta_upgrade= cTarAdicUpgrade, Resultado='1'
				WHERE numerotarjeta = cNumtarjadi;		
				
				LET iSecuencia = iSecuencia +1;
				
			END FOREACH;	
			
			-- Actualizacion de credito en bitacora de upgrade
			UPDATE bdicred:sd_credito_upgrade  SET numero_credito_upgrade = cSolOro, numerotarjeta_upgrade= pTarjetaOro, Resultado='1'
			WHERE numerotarjeta = pTarjeta;

			-- Genera el movimiento por la apertura de la linea de credito Oro
			EXECUTE PROCEDURE GENMOV( pEmpresa         , cSolOro,
									  pProducto        , 1,
										"001"             , V_FECHA_APERT,
										V_MONTO           , vFolio,
										VV_SUCURSAL       ,VV_DIVISA,
										"0000")
			INTO P_ERROR, P_MENSAJE;
			
			IF P_ERROR::integer <> 0 THEN
				--AAME Se anexa reverso de operacion
				EXECUTE PROCEDURE reversion(pEmpresa,VV_SUCURSAL,P_EJECUTIVO,vFolio, "A")
				INTO  P_ERROR;			
				-- Actualizacion de credito en bitacora de upgrade cuando pase un error
				UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
				WHERE num_credito = pCredito;
				--En caso de error se elimina el registro de la nueva tarjeta
				DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
				DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
				UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
				UPDATE intercard:tarjeta 
				SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
				WHERE numtarjeta = pTarjetaOro;
				FOREACH WITH HOLD 
					SELECT numerotarjeta, numcte 
					INTO cNumtarjadi,cnumcteadi
					FROM bdicred:sd_credito_upgrade
					WHERE num_credito = pCredito
					AND tipotar='ADI'	
					
					SELECT DM.IdSolicitud 
					INTO cidsolicitud
					FROM intercard:SolicitudTarjeta ST 
					INNER JOIN intercard:Detalle_Maquila DM ON ST.IdSolicitud=DM.IdSolicitud 
					WHERE ST.IdSolicitud >= 1 AND ST.NumCuenta= cSolOro AND ST.numcliente = cnumcteadi;		
				
					UPDATE sd_tarjeta  SET status_tar='A' WHERE num_tarjeta = cNumtarjadi;
					UPDATE intercard:tarjeta  SET codstatustarjeta='ACT' WHERE numtarjeta = cNumtarjadi;														
					UPDATE intercard:solicitudtarjeta SET numcuenta=pCredito WHERE idsolicitud =cidsolicitud;
					DELETE FROM sd_adicionalespendientes WHERE empresa='001' AND NumCteTitular = cNumcte AND NumCteAdicional= cnumcteadi AND Credito = cSolOro;																		
				END FOREACH;						
				DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
				DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

				LET cCodRet = P_ERROR;
				LET cMensajeRet=P_MENSAJE;
				RETURN cCodRet, cMensajeRet;
			END IF;
			
				--Se revisa si se cuenta con saldo a favor
			IF dcSdoActTotCapCSG < 0 THEN -- Se crea codigo fun y codigo _ ref nuevo
			
				--MOVIMIENTO POR APERTURA CON SALDO A FAVOR 
				EXECUTE PROCEDURE GENMOV( pEmpresa         , cSolOro,
						  pProducto        , 1,
							"075"             , V_FECHA_APERT,
							(dcSdoActTotCapCSG *-1)          , vFolio,
							VV_SUCURSAL       ,VV_DIVISA,
							"0000")
				INTO P_ERROR, P_MENSAJE;
			
				IF P_ERROR::integer <> 0 THEN
					--AAME Se anexa reverso de operacion
					EXECUTE PROCEDURE reversion(pEmpresa,VV_SUCURSAL,P_EJECUTIVO,
					vFolio, "A")
					INTO  P_ERROR;					
					-- Actualizacion de credito en bitacora de upgrade cuando pase un error
					UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
					WHERE num_credito = pCredito;
					--En caso de error se elimina el registro de la nueva tarjeta
					DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
					UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
					UPDATE intercard:tarjeta 
					SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
					WHERE numtarjeta = pTarjetaOro;
					FOREACH WITH HOLD 
						SELECT numerotarjeta, numcte 
						INTO cNumtarjadi,cnumcteadi
						FROM bdicred:sd_credito_upgrade
						WHERE num_credito = pCredito
						AND tipotar='ADI'	
						
						SELECT DM.IdSolicitud 
						INTO cidsolicitud
						FROM intercard:SolicitudTarjeta ST 
						INNER JOIN intercard:Detalle_Maquila DM ON ST.IdSolicitud=DM.IdSolicitud 
						WHERE ST.IdSolicitud >= 1 AND ST.NumCuenta= cSolOro AND ST.numcliente = cnumcteadi;		
					
						UPDATE sd_tarjeta  SET status_tar='A' WHERE num_tarjeta = cNumtarjadi;
						UPDATE intercard:tarjeta  SET codstatustarjeta='ACT' WHERE numtarjeta = cNumtarjadi;														
						UPDATE intercard:solicitudtarjeta SET numcuenta=pCredito WHERE idsolicitud =cidsolicitud;
						DELETE FROM sd_adicionalespendientes WHERE empresa='001' AND NumCteTitular = cNumcte AND NumCteAdicional= cnumcteadi AND Credito = cSolOro;																		
					END FOREACH;								
					DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
					DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;
					

					LET cCodRet = P_ERROR;
					LET cMensajeRet=P_MENSAJE;
					RETURN cCodRet, cMensajeRet;
				END IF;
					/*--movimiento por CANCELACION del saldo a favor del credito anterior
				   EXECUTE PROCEDURE genmov(pEmpresa, pCredito, V_PRODUCTO, 113,
											'002', V_FECHA_APERT, (dcSdoActTotCapCSG *-1), vFolio, VV_SUCURSAL,
											VV_DIVISA, "0000"
											) INTO P_ERROR, P_MENSAJE;


					IF P_ERROR::integer <> 0 THEN
						-- Actualizacion de credito en bitacora de upgrade cuando pase un error
						UPDATE bdicred:sd_credito_upgrade  SET Resultado='2'
						WHERE num_credito = pCredito;
						LET cCodRet = "000" || P_ERROR;
						RETURN cCodRet, cMensajeRet;
					END IF;		*/
			END IF;

			
			IF dcTotalLiqCSG > 0 THEN -- Se crea codigo fun y codigo _ ref nuevo
				--MACM RQM 10 1584 TDC INFINITE, se agregan los codigo ref de los productos 8100 y 7000
				IF V_PRODUCTO = "8100" THEN
					LET cod_ref = 134;
				ELIF V_PRODUCTO = "7000" THEN
					LET cod_ref = 135;
				ELIF V_PRODUCTO = "6001" THEN
					LET cod_ref = 112;
				ELIF V_PRODUCTO = "8500" THEN
					LET cod_ref = 124;
				END IF;
				--RQI Cambio de producto de grupo Coppel a oro/platino 
				--	IF V_PRODUCTO = 8500 THEN   --se evalua el producto en V_PRODUCTO, si corresponde al 8500 se genera el mivimiento  
				--								--con el codigo_ref = 124 si no se genera el movimiento con el codigo_ref =  112.
				--								
				--		-- Se realiza el cargo del movimiento del total del adeudo
						EXECUTE PROCEDURE GENMOV( 
							pEmpresa , cSolOro, pProducto, cod_ref,
								"002", V_FECHA_APERT,(dcTotalLiqCSG *1),
								vFolio,	VV_SUCURSAL, VV_DIVISA,
								"0000")
					INTO P_ERROR, P_MENSAJE;				
				--ELSE
				--
				--	-- Se realiza el cargo del movimiento del total del adeudo
				--		EXECUTE PROCEDURE GENMOV( 
				--			pEmpresa , cSolOro, pProducto, 112,
				--				"002", V_FECHA_APERT,(dcTotalLiqCSG *1),
				--				vFolio,	VV_SUCURSAL, VV_DIVISA,
				--				"0000")
				--	INTO P_ERROR, P_MENSAJE;
				--
				--END IF;

				IF P_ERROR::integer <> 0 THEN
					--AAME Se anexa reverso de operacion
					EXECUTE PROCEDURE reversion(pEmpresa,VV_SUCURSAL,P_EJECUTIVO,
					vFolio, "A")
					INTO  P_ERROR;					
					-- Actualizacion de credito en bitacora de upgrade cuando pase un error
					UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
					WHERE num_credito = pCredito;
					--En caso de error se elimina el registro de la nueva tarjeta
					DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
					DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
					UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
					UPDATE intercard:tarjeta 
					SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
					WHERE numtarjeta = pTarjetaOro;
					FOREACH WITH HOLD 
						SELECT numerotarjeta, numcte 
						INTO cNumtarjadi,cnumcteadi
						FROM bdicred:sd_credito_upgrade
						WHERE num_credito = pCredito
						AND tipotar='ADI'	
						
						SELECT DM.IdSolicitud 
						INTO cidsolicitud
						FROM intercard:SolicitudTarjeta ST 
						INNER JOIN intercard:Detalle_Maquila DM ON ST.IdSolicitud=DM.IdSolicitud 
						WHERE ST.IdSolicitud >= 1 AND ST.NumCuenta= cSolOro AND ST.numcliente = cnumcteadi;		
					
						UPDATE sd_tarjeta  SET status_tar='A' WHERE num_tarjeta = cNumtarjadi;
						UPDATE intercard:tarjeta  SET codstatustarjeta='ACT' WHERE numtarjeta = cNumtarjadi;														
						UPDATE intercard:solicitudtarjeta SET numcuenta=pCredito WHERE idsolicitud =cidsolicitud;
						DELETE FROM sd_adicionalespendientes WHERE empresa='001' AND NumCteTitular = cNumcte AND NumCteAdicional= cnumcteadi AND Credito = cSolOro;																		
					END FOREACH;							
					DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
					DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
					DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;
					LET cCodRet = P_ERROR;
					LET cMensajeRet=P_MENSAJE;
					RETURN cCodRet, cMensajeRet;
				END IF;
			END IF;
			
			--EJECUCION PARA APLICAR EL CARGO RETENIDO AL NUEVO CREDITO MACM RQM 101584 TDC INFINITE
			
			IF NVL(dcSdoRetenidoCSG,0) >0 THEN
			
				INSERT INTO bdicred:sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)			
				SELECT empresa,cSolOro,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,'P',referencia,sucursal,dias_ori
				FROM bdicred:sd_maeretenido
				WHERE num_credito = pCredito and estatus = 'P';
				
			END IF
			
			--EJECUCION PARA LIBERAR EL CARGO RETENIDO	MACM RQM 101584 TDC INFINITE
			IF NVL(dcSdoRetenidoCSG,0) >0 THEN

				UPDATE bdicred:sd_maeretenido SET estatus = 'S' WHERE num_credito = pCredito and estatus = 'P';

			END IF
			
			
			foreach
				select num_tarjeta
				into vtarjeta
				from bdicred:sd_tarjeta
				where empresa=pEmpresa
				and num_credito=pCredito
				and tipo_tarjeta<>'0'
				and status_tar <> 'C'

				select codproductotarjeta
				into cproducto
				from intercard:tarjeta
				where numtarjeta=vtarjeta;

				execute procedure intercard:sp_cancelacion_tarjeta
				(vtarjeta,cproducto,'informix') INTO cCodRet, cMensajeRet;

				if cCodRet='001' or cCodRet='002' then
					LET cCodRet = '000000';
					LET cMensajeRet= "PROCESO EXITOSO";
				end if;
			end foreach;
			
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
			
			IF NVL(sExistePromo,0) > 0 THEN
				LET cCodRet='000005';
				LET cMensajeRet = 'La cuenta tiene credisolucion o msi activa,no se permite Mejora de Producto.';
				-- Actualizacion de credito en bitacora de upgrade cuando pase un error
				UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
				WHERE num_credito = pCredito;
				--En caso de error se elimina el registro de la nueva tarjeta
				DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
				DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
				UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
				UPDATE intercard:tarjeta 
				SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
				WHERE numtarjeta = pTarjetaOro;
				DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
				DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
				DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;
	
				RETURN cCodRet, cMensajeRet;
			END IF;

		ELIF CstatusSol='FF' THEN
			LET cCodRet='000007';
			LET cMensajeRet = 'La cuenta se encuentra liquidada, por favor verifique';
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;				
			DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

			RETURN cCodRet, cMensajeRet;
			--MACM RQM 10 1584 TDC INFINITE, SE QUITA VALIDACION DE SALDO RETENIDO
		--/*ELIF NVL(dcSdoRetenidoCSG,0) >0 AND cNumCreditoCSG <> '' THEN
		/*ELIF NVL(sExistePromo,0) > 0 THEN
			LET cCodRet='000005';
			LET cMensajeRet = 'La cuenta tiene credisolucion o msi activa,no se permite Mejora de Producto.';
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_maecred WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_maesdos WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_maecredanexo WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_amortiza_credito WHERE num_credito = cSolOro;
			DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

			RETURN cCodRet, cMensajeRet;*/
		--ELIF CstatusSol <> 'AA' THEN
--		ELIF (CstatusSol <> 'AA' OR (NVL(cAct,-1)>0 and CstatusSol<> 'E1')) THEN
		ELSE
			LET cCodRet='000006';
			LET cMensajeRet ='La cuenta se encuentra con atraso, o no esta vigente';
			-- Actualizacion de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:sd_credito_upgrade  SET Resultado='2', numero_credito_upgrade='', numerotarjeta_upgrade=''
			WHERE num_credito = pCredito;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:tarjetacuenta WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_tarjeta WHERE num_tarjeta = pTarjetaOro;
			UPDATE bdicred:sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjeta;
			UPDATE intercard:tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaOro;
			DELETE FROM bdicred:sd_maecred WHERE empresa = '001' AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_maesdos WHERE empresa = '001' AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_maecredanexo WHERE empresa = '001' AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_amortiza_credito WHERE empresa = '001' AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(month(V_FECHA_APERT),'01',year(V_FECHA_APERT)) - 1 units month AND num_credito = cSolOro;
			DELETE FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND num_credito = cSolOro;

			RETURN cCodRet, cMensajeRet;
		END IF;
	END IF;
ELSE 
	-- ActualizaciÃ³n de credito en bitacora de upgrade cuando se trata de una reposicion de tarjeta personalizada
		UPDATE bdicred:sd_credito_upgrade SET numerotarjeta_upgrade= pTarjetaOro, Resultado='1'
		WHERE numerotarjeta = pTarjeta;
END IF;
	RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para liquidar el credito de TDC clasica y crear el credito para TDC ORO que se ejecutara',
'desde el de Reposicion de Tarjeta',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/02/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consulta_msi(pNumCte CHAR(20),pNumTarjeta CHAR(20),pNumCredito CHAR(20), pServicio char(2))
                        --        pServicio./ Plataforma desde donde se ejecuta: 1.- OFI
						-- 		  Servicio 2.- Consulta pago mÃÂ­nimo a fecha de corte
RETURNING
          CHAR(05)      AS codigo_retorno,
          CHAR(20)      AS numero_credito,
          DATE		    AS fecha_compra,
          CHAR(40)      AS concepto,
          CHAR(16) 		AS folio_compra,
          DECIMAL(19,4) AS saldo_total_compra,
          CHAR(02) 		AS numero_pago,
          CHAR(02) 		AS plazo,
          DECIMAL(19,4) AS saldo_apagar,
          DECIMAL(19,4) AS saldo_dedudor;
		  

DEFINE iSqlErr      	    INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE cCodRet              CHAR(6);
DEFINE cMensajeRet          CHAR(80);
DEFINE iRegistros           INTEGER;
DEFINE cNumCredito          CHAR(20);
DEFINE dFechaCompra			DATE;
DEFINE cConcepto			CHAR(40);
DEFINE cFolioCompra			CHAR(16);
DEFINE dSaldoTotalCompra	DECIMAL(19,4);
DEFINE cNumPago				CHAR(2);
DEFINE cPlazo				CHAR(2);
DEFINE dSaldoAPagar			DECIMAL(19,4);
DEFINE dSaldoDeudor			DECIMAL(19,4);
DEFINE cNumCte				CHAR(20);
DEFINE sCuentasMSI			SMALLINT;
DEFINE cNumSolPrestamo		CHAR(20);
DEFINE cStatusCred 			CHAR(4);
DEFINE sSecuencia			SMALLINT;

/*********************************************/
DEFINE cCodRet_pm 			CHAR(6);
DEFINE cMensaje_retorno_pm	CHAR(80);
DEFINE dPagoMinimo_pm		DECIMAL(18,2);
DEFINE dPagoMinimo_tot_pm	DECIMAL(18,2);
DEFINE dPagoMinimo_msi	DECIMAL(18,2);
DEFINE dIntVdo_pm 			DECIMAL(18,2);
DEFINE dIntMoratorio_pm 	DECIMAL(18,2);
DEFINE dIvaIntVdo_pm 		DECIMAL(18,2);
DEFINE dPagosVdos_pm 		DECIMAL(18,2);
DEFINE dIvaIntMoratorio_pm 	DECIMAL(18,2);
DEFINE dIntMes_pm 			DECIMAL(18,2);
DEFINE dIvaIntMes_pm 		DECIMAL(18,2);
DEFINE dIntVig_pm 			DECIMAL(18,2);
DEFINE dIvaIntVig_pm 		DECIMAL(18,2);




BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet = "-"||trim(cNumCredito)||"-"|| cErrorInfo;
		RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
			NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO "/home/c90271846/sp_consulta_msi.out"; 
-- TRACE ON;

LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = '';
LET cCodRet             = '00000';
LET cMensajeRet         = 'Se realizo la consulta correctamente';
LET iRegistros          = 0;
LET cNumCredito         = '';
LET dFechaCompra		= DATE(1);
LET cConcepto			= '';
LET cFolioCompra		= '';
LET dSaldoTotalCompra	= 0;
LET cNumPago			= '';
LET cPlazo				= '';
LET dSaldoAPagar		= 0;
LET dSaldoDeudor		= 0;
LET cNumCte				= '';
LET sCuentasMSI			= 0;
LET cNumSolPrestamo		= '';
LET cStatusCred			= '';
LET sSecuencia			= 0;

/*********************************************/
LET cCodRet_pm 			= '';
LET cMensaje_retorno_pm	= '00000';
LET dPagoMinimo_pm		= 0;
LET dPagoMinimo_tot_pm  = 0;
LET dPagoMinimo_msi		= 0;
LET dIntVdo_pm 			= 0;
LET dIntMoratorio_pm 	= 0;
LET dIvaIntVdo_pm 		= 0;
LET dPagosVdos_pm 		= 0;
LET dIvaIntMoratorio_pm = 0;
LET dIntMes_pm 			= 0;
LET dIvaIntMes_pm 		= 0;
LET dIntVig_pm 			= 0;
LET dIvaIntVig_pm 		= 0;


	-- Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	IF NVL(pNumCte,'') = '' AND NVL(pNumTarjeta,'') = '' AND NVL(pNumCredito,'') = '' THEN
		LET cCodRet     = '99999';
		RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
		NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);
	END IF;

	-- Condiciones nuevas msi 
	LET pNumCte = pNumCte;
	LET pNumTarjeta = pNumTarjeta;
	LET pNumCredito = pNumCredito;

	IF NVL(TRIM(pNumTarjeta), '') != '' THEN

		SELECT max(secuencia) INTO sSecuencia FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_tarjeta = pNumTarjeta AND status_tar = 'A';
		 
		SELECT num_credito INTO cNumCredito FROM bdicred:sd_tarjeta 
		 WHERE empresa = '001' AND num_tarjeta = pNumTarjeta AND secuencia = sSecuencia;
		
		IF NVL(TRIM(cNumcredito), '') = '' THEN
		    LET cCodRet='00001'; --EL numero de tarjeta no es valido
			RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
	            NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);
		END IF; 
	END IF;
				
	IF  NVL(TRIM(pNumCredito),'') != '' THEN
	
		SELECT status_cred, num_credito INTO cStatusCred, cNumCredito FROM bdicred:sd_maecred 
		 WHERE num_credito = pNumCredito AND status_cred IN ('AA','BA','BT','E1','E2','E3');
		IF NVL(TRIM(cStatusCred), '') = '' THEN
			LET cCodRet= '00002';			
			RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
				   NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);	
		END IF;
	END IF;

	IF  NVL(TRIM(pNumCte),'') != '' THEN
		SELECT numcte INTO cNumCte FROM bdinteg:si_cliente WHERE numcte = pNumCte; 	
		SELECT num_credito INTO cNumCredito FROM bdicred:sd_maecred WHERE numcte = cNumCte AND status_cred IN ('AA','BA','BT','E1','E2','E3')and num_producto <>('7800');
		IF TRIM(cNumCredito) = '' OR cNumCredito IS NULL THEN
		    LET cCodRet = '00003';			
			RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
			       NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);	
		END IF; 
	END IF;
	
	IF (pServicio = '1')THEN 	-- Retorna MSI contratados con determinada TDC
	    FOREACH WITH HOLD
		    SELECT a.num_credito,a.num_sol_prestamo,a.fecha,a.nombre_promo,a.folio_movto,c.monto_otorgado,a.plazo,a.mensualidad,a.monto_actual 
		    INTO cNumCredito,cNumSolPrestamo,dFechaCompra,cConcepto,cFolioCompra,dSaldoTotalCompra,cPlazo,dSaldoAPagar,dSaldoDeudor
		    FROM bdicred:sd_promocion_credito a
		    INNER JOIN bdicred:sd_maecred b on (a.num_credito = b.num_credito)
		    INNER JOIN bdicred:sd_maecredcrd d on (a.num_sol_prestamo = d.num_credito AND d.status_cred IN ('AA','BA','E1','E2'))
		    INNER JOIN bdicred:sd_maesdoscrd c on (a.num_sol_prestamo = c.num_credito)
		    WHERE a.num_credito = cNumCredito
		    AND a.num_pro_prestamo = '8900'
			
		    SELECT MAX(num_pago) INTO cNumPago --CAX 23092025
		    FROM bdicred:sd_amortiza_creditocrd
		    WHERE empresa = '001' AND num_credito = cNumSolPrestamo;

            RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
			NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0) WITH RESUME;
			
	    END FOREACH;

	    LET iRegistros = DBINFO("sqlca.sqlerrd2");
	    IF iRegistros  = 0 THEN
		    LET cCodRet     = '00004';
		    LET cMensajeRet = 'NO SE OBTUVIERON RESULTADOS';
		    RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
			NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);
	    END IF;
	END IF; 
	
	
	IF (pServicio = '2')THEN 	-- Pago mÃÂ­nimo mÃÂ¡s meses sin intereses  (pago minimo tdc + pagos minimos de msi)  ( 1 bpi y app)
	
		LET dPagoMinimo_tot_pm = 0;
		-- Obtiene pago minimo de TDC
		
		EXECUTE PROCEDURE bdicred:sp_consultasaldocortemin('001',cNumCredito,4)
				INTO cCodRet_pm, dPagoMinimo_pm;
				
		
		LET dPagoMinimo_tot_pm = dPagoMinimo_pm;


		-- Obtiene Pago Minimo de MSI contratados a la tdc
		FOREACH WITH HOLD
			SELECT a.num_sol_prestamo
			  INTO   cNumSolPrestamo
			  FROM bdicred:sd_promocion_credito a
			 INNER JOIN bdicred:sd_maecred b on (a.num_credito = b.num_credito)
			 INNER JOIN bdicred:sd_maecredcrd d on (a.num_sol_prestamo = d.num_credito AND d.status_cred IN ('AA','BA','E1','E2'))
			 WHERE a.num_credito = cNumCredito AND a.num_pro_prestamo = '8900'

				--ModificaciÃÂ³n Inicial
			EXECUTE PROCEDURE bdicred:sp_consultasaldocortemin('001',cNumSolPrestamo,4)
				INTO cCodRet_pm, dPagoMinimo_msi;
				
			LET dPagoMinimo_tot_pm = dPagoMinimo_tot_pm + dPagoMinimo_msi;
			LET dPagoMinimo_msi = 0;

		END FOREACH;
		
		LET dFechaCompra = date(1);
		LET cConcepto = '';
		LET cFolioCompra = '';
		LET dSaldoTotalCompra = dPagoMinimo_tot_pm;
		LET cNumPago = '';
		LET cPlazo = '';
		LET dSaldoAPagar = 0;
		LET dSaldoDeudor = 0;

		RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dPagoMinimo_tot_pm,0), NVL(cNumPago,0), 
		NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);
	
	
	END IF;
	
	
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'La consulta Meses Sin Intereses contratados por el cliente',
'AUTOR : ',
'FECHA : 23/OCTUBRE/2021',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cierre_diario_adn(pEmpresa CHAR(3))
RETURNING
   CHAR(6)        AS Cod_Ret,
   CHAR(80)       AS Mens_Ret;

DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      CHAR(125);
DEFINE cCodRet_704      CHAR(6);
DEFINE cMensajeErr_704  CHAR(200);

DEFINE cBegin         CHAR(1);
DEFINE cFolio         CHAR(16);
DEFINE cEmpresa       CHAR(3);
DEFINE cNumCredito    CHAR(20);
DEFINE cStatusCred    CHAR(2);
DEFINE cStatusCredAnt CHAR(2);
DEFINE cStatusCredIndica CHAR(2);
DEFINE cDivisa        CHAR(2);
DEFINE cNumProducto   CHAR(4);
DEFINE dtFechaApert   DATE;
DEFINE iDiaCorte      INTEGER;
DEFINE cSucursal      CHAR(4);
DEFINE cPlaza         CHAR(3);
DEFINE dIvaSuc        DECIMAL(5,3);
DEFINE cCodTipCred    CHAR(2);
DEFINE iDiasCalc      INTEGER;
DEFINE dtFechaHoy     DATE;
DEFINE dtFechaHoyAux  DATE;
DEFINE dtFechaProx    DATE;
DEFINE dtFechaFinMes  DATE;
--DEFINE dtFechaFinMesAnt DATE;
DEFINE dtFechaProxCuota  DATE;
DEFINE dtFechaVencto  DATE;
DEFINE iDiasInt       INTEGER;
DEFINE iDiasInt_inh   INTEGER;

DEFINE dIntDiario     DECIMAL(18,2);
DEFINE dIntDiario_inh DECIMAL(18,2);

DEFINE dTasaInter       DECIMAL(9,6);
DEFINE dTasaInterMor    DECIMAL(9,6);
DEFINE dTasaInterMorCop DECIMAL(9,6);
DEFINE dSdoCapital      DECIMAL(18,2);
DEFINE dMntVencido      DECIMAL(18,2);
DEFINE dMntVencTras     DECIMAL(18,2);
DEFINE dCapTrasNoVen    DECIMAL(18,2);
DEFINE dSdoCapInso      DECIMAL(18,2);
DEFINE dSdoNoExig       DECIMAL(18,2);
DEFINE dSdoInt          DECIMAL(18,2);
DEFINE dSdoInt_inh      DECIMAL(18,2);
DEFINE dSdodiaantint    DECIMAL(18,2);
DEFINE dSdomesantint    DECIMAL(18,2);
DEFINE dSdomoratorio    DECIMAL(18,2);
DEFINE dSdocontabmora   DECIMAL(18,2);
DEFINE dMontofinanciado DECIMAL(18,2);
DEFINE dIvaIntVencido   DECIMAL(18,2);
DEFINE dIvaIntVigente   DECIMAL(18,2);
DEFINE dSdotrab4        DECIMAL(18,2);
DEFINE dSdo             DECIMAL(18,2);
DEFINE dtFechaCuota     DATE;
DEFINE dtFechaCuotaAnt  DATE;
DEFINE dProvInt       	DECIMAL(14,2);
DEFINE dProvInt_inh    	DECIMAL(14,2);
DEFINE dIvaPag        	DECIMAL(14,2);
--ini cas
DEFINE dIntGrav      	DECIMAL(14,2);
DEFINE dIntExen       	DECIMAL(14,2);
DEFINE dIntGrav_inh   	DECIMAL(14,2); --FMV
DEFINE dIntExen_inh    	DECIMAL(14,2); --FMV

DEFINE dtIvaFechaPag    DATE;
DEFINE dCapMtoCuota     DECIMAL(14,2);
DEFINE iNumPago         INTEGER;
DEFINE dProvIva       	DECIMAL(14,2);
DEFINE dProvIva_inh    	DECIMAL(14,2); --FMV
DEFINE dIntVdo          DECIMAL(18,2);
DEFINE dTraspCap        DECIMAL(14,2);
DEFINE dTraspInt        DECIMAL(18,2);
DEFINE cCapStatusCuota  CHAR(1);
DEFINE dSdoMora         DECIMAL(18,2);
DEFINE dIntMora         DECIMAL(18,2);
DEFINE dIntCope         DECIMAL(18,2);
DEFINE iContCierre      INTEGER;
DEFINE iContCorte       INTEGER;
DEFINE iContCommit      INTEGER;
DEFINE cIdProc1         CHAR(1);
DEFINE cIdProc2         CHAR(1);
DEFINE cIdProc3         CHAR(1);
DEFINE cIdProc4         CHAR(1);
DEFINE dIntProvFinMes   DECIMAL(18,2);
DEFINE dIvaProvFinMes   DECIMAL(18,2);
DEFINE dIvaIntReal      DECIMAL(18,2);
DEFINE dIvaIntReal_inh  DECIMAL(18,2); --FMV
DEFINE dtFechaMesiversario DATE;
DEFINE cBanTemp         CHAR(1);
DEFINE iNumVdos         INTEGER;
DEFINE iPerTrasp        INTEGER;
DEFINE credcontproc 	char(1);
DEFINE intecontproc 	char(1);
DEFINE CodigoRefProvIva INTEGER;
DEFINE CodigoRefProvInt INTEGER;
DEFINE dIntPeriodo      DECIMAL(18,2);
DEFINE dIvaPeriodo      DECIMAL(18,2);
DEFINE cSQL				CHAR(200);
DEFINE vlCapitalDebe    DECIMAL (14,2);
--FMV 03-SEP-11 --CREDINOMINA
DEFINE iTpDiasFechaPago INTEGER;
--FMV 09-MAY-11
DEFINE dCapTrasVen_Amort DECIMAL(14,2);
--SDFM 11-06-12 -- VENTA PP
DEFINE v_marca_ayuda CHAR(1);
--FMV 24abr13: Indicadores de buro
DEFINE vf_fecha_ult_pago DATE;
DEFINE vdias_atraso      INTEGER;
--FMV 9jul13: Traspaso 90, finalizando plazo
DEFINE vf_fecha_vencim   DATE;
DEFINE vi_dias_trasp_cap INTEGER;
DEFINE vlIntVenBal      DECIMAL (14,2);
DEFINE vlIvaIntVenBal   DECIMAL (14,2);
DEFINE Campotrabajo3 CHAR(10);
-- JOM 11/04/2013 Se cambia traspado a periodos INI
DEFINE dFechacuotamin   DATE;
DEFINE dtFechaMesiversarioAux   DATE;
DEFINE iNumVdosaux      INTEGER;
DEFINE iBanderaDiaInhabil      INTEGER;
-- JOM 11/04/2013 Se cambia traspado a periodos FIN
--FMJ APoyo 2014
DEFINE wbandera_apoyo CHAR(1);
DEFINE iFechaVencto			DATE;

--IFSR variables
DEFINE iAct			INTEGER;
DEFINE iActNvo		INTEGER;
DEFINE iDiasAtraso		INTEGER;
DEFINE cBanderaIFSR			CHAR(1);
--RQM 09 704
DEFINE c_act_retenido   CHAR(1); 
DEFINE c_numcte         CHAR(20);
DEFINE s_existe_cntrl   INTEGER;
DEFINE c_cuenta         CHAR(20);

LET cBegin           = "N";
LET cFolio         	 = "";
LET cEmpresa         = "";
LET cNumCredito      = "";
LET cStatusCred    	 = "";
LET cStatusCredAnt 	 = "";
LET cStatusCredIndica = "";
LET cNumProducto   	 = "";
LET cDivisa          = "";
LET dtFechaApert     = DATE(1);
LET iDiaCorte        = 0;
LET cSucursal      	 = "";
LET cPlaza         	 = "";
LET dIvaSuc          = 0;
LET cCodTipCred      = "";
LET iDiasCalc        = 0;
LET dtFechaHoy       = DATE(1);
LET dtFechaHoyAux    = DATE(1);
LET dtFechaProx      = DATE(1);
LET dtFechaFinMes    = DATE(1);
--LET dtFechaFinMesAnt    = DATE(1);
LET dtFechaProxCuota = DATE(1);
LET dtFechaVencto    = DATE(1);
LET iDiasInt         = 0;
LET iDiasInt_inh     = 0;

LET dIntDiario       = 0;
LET dIntDiario_inh   = 0;
LET dTasaInter       = 0;
LET dTasaInterMor    = 0;
LET dTasaInterMorCop = 0;
LET dSdoCapital      = 0;
LET dMntVencido      = 0;
LET dMntVencTras     = 0;
LET dCapTrasNoVen    = 0;
LET dSdoCapInso      = 0;
LET dSdoNoExig       = 0;
LET dSdoInt          = 0;
LET dSdoInt_inh      = 0;

LET dSdodiaantint       = 0;
LET dSdomesantint       = 0;
LET dSdomoratorio       = 0;
LET dSdocontabmora      = 0;
LET dMontofinanciado    = 0;
LET dIvaIntVencido      = 0;
LET dIvaIntVigente      = 0;
LET dSdotrab4           = 0;
LET dSdo                = 0;
LET dtFechaCuota        = DATE(1);
LET dtFechaCuotaAnt     = DATE(1);
LET dProvInt       	    = 0;
LET dProvInt_inh  	    = 0;
LET dIvaPag        	    = 0;
LET dtIvaFechaPag       = DATE(1);
LET dCapMtoCuota        = 0;
LET iNumPago            = 0;
LET dProvIva       	    = 0;
LET dProvIva_inh  	    = 0;
LET dIntVdo             = 0;
LET dTraspCap           = 0;
LET dTraspInt           = 0;
LET cCapStatusCuota     = "";
LET dSdoMora            = 0;
LET dIntMora            = 0;
LET dIntCope            = 0;
LET iContCierre         = 0;
LET iContCorte          = 0;
LET iContCommit         = 0;
LET cIdProc1            = "";
LET cIdProc2            = "";
LET cIdProc3            = "";
LET cIdProc4            = "";

LET dIntProvFinMes      = 0;
LET dIvaProvFinMes      = 0;
LET dtFechaMesiversario = DATE(1);
LET cBanTemp            = 'N';
LET iNumVdos            = 0;
LET iPerTrasp           = 0;
LET dIntGrav            = 0;
LET dIntExen            = 0;
LET dIntGrav_inh        = 0;
LET dIntExen_inh        = 0;

LET ccodret             ='000';
LET CodigoRefProvIva    = 0;
LET CodigoRefProvInt    = 0;
LET dIntPeriodo         = 0;
LET dIvaPeriodo         = 0;
LET cSQL				= "";
LET vlCapitalDebe       = 0;
-- FMV 09-MAY-11 INICIO DE LA VARIABLE PARA EL CALCULO DE INTERES EN VENCIMIENTO, STATUS 1 DE AMORTIZA
LET dCapTrasVen_Amort = 0;
--FMV 03-SEP-11 --6400
LET iTpDiasFechaPago = 0;
--SDFM 11-06-12 -- VENTA PP
LET v_marca_ayuda = "";
LET vf_fecha_ult_pago = DATE(1);
LET vdias_atraso = 0;
LET vf_fecha_vencim   = DATE(1);
LET vi_dias_trasp_cap = 0;
LET vlIntVenBal      = 0;
LET vlIvaIntVenBal   = 0;
LET Campotrabajo3 = '';
-- JOM 11/04/2013 Se cambia traspado a periodos INI
LET dFechacuotamin = DATE(1);
LET dtFechaMesiversarioAux = DATE(1);
LET iNumVdosaux    = 0;
LET iBanderaDiaInhabil    = 0;
-- JOM 11/04/2013 Se cambia traspado a periodos FIN
LET wbandera_apoyo = '';
LET iFechaVencto = DATE(1);

-- IFSR variables
LET iAct = 0;
LET iActNvo = 0;
LET iDiasAtraso		= 0;
LET cBanderaIFSR = 'I';
--RQM 09 704
LET c_act_retenido  = '0';
LET c_numcte        = '';
LET s_existe_cntrl  = 0;
LET c_cuenta        = '';

SET ISOLATION TO DIRTY READ;



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cNumCredito ||cErrorInfo;

      IF cBegin = "S" THEN
          ROLLBACK WORK;
       END IF;

      UPDATE "informix".sd_contproc
         SET status_proc = "C",
             hora_fin    = CURRENT,
             cod_ret     = cCodRet,
             mensaje     = cMensajeRet
       WHERE empresa     = cEmpresa
         AND proceso     = "CierreAdn"
         AND fecha       = dtFechaHoy;

      UPDATE bdinteg:sx_contproc
         SET status_proc = "C",
             hora_fin    = CURRENT,
             codret      = cCodRet
       WHERE empresa     = cEmpresa
         AND proceso     = "CierreAdn"
         AND fecha       = dtFechaHoy;

	  IF cBanTemp ='S' THEN
	     DROP TABLE tmp_sucursales_adn;
	  END IF;

   RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

--  SET DEBUG FILE TO '/resplogifx/archivoscredito/sp_cierre_diario_adn.out';
--  TRACE ON;
-- *******************************************************
--  VALIDACIONES DE EJECUCION DE PROCESO                 *
-- *******************************************************
SELECT a.empresa
  INTO cEmpresa
  FROM bdinteg:si_empresas a
 WHERE a.empresa = pEmpresa;

IF NVL(cEmpresa,"") = "" THEN
     LET cCodRet     = "000001";
     LET cMensajeRet = "La empresa no existe";
     RETURN cCodRet, cMensajeRet;
END IF;

SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes, 
		-- mdy('01','05','2016'), mdy('01','06','2016'), mdy('01','31','2016'),
       USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(CURRENT,3,2)
           ||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)
           ||SUBSTR(CURRENT,18,2)
  INTO dtFechaHoy, dtFechaProx, dtFechaFinMes,
       cFolio
  --FROM "informix".sd_fechas a
  FROM "informix".sd_fechas a--solo para puebas *** IFSR quitar
 WHERE a.empresa = cEmpresa;

 
  
-- *******************************************************
--  INSERTA PARA EJECUCION DE PROCESO                 *
-- *******************************************************
--INI CAS
    SELECT status_proc
    INTO intecontproc
    FROM bdinteg:sx_contproc
    WHERE fecha= dtFechaHoy
      and proceso ='CierreAdn';

    if (intecontproc='F') then
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCodRet,cMensajeRet;
     end if;

    SELECT status_proc
    INTO credcontproc
    FROM bdicred:sd_contproc
    WHERE fecha= dtFechaHoy
      and proceso ='CierreAdn';

    IF (intecontproc IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret)
      VALUES ('001','CierreAdn',dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    end if;

    if (credcontproc IS NULL) THEN
      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001','CierreAdn',dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    end if;

    UPDATE bdinteg:sx_contproc
       SET status_proc='I'
     WHERE fecha= dtFechaHoy
       and proceso ='CierreAdn';

     UPDATE bdicred:sd_contproc
        SET status_proc='I' ,mensaje = 'Iniciamos'
      WHERE fecha= dtFechaHoy
        and proceso ='CierreAdn';

--FIN CAS


SELECT a.valor
  INTO iDiasCalc
  FROM "informix".sd_param a
 WHERE a.cod_param = "24";

IF iDiasCalc IS NULL THEN
    LET cCodRet     = "000003";
    LET cMensajeRet = "Parametro para los dias de calculo de interes no encontrado";
    RETURN cCodRet, cMensajeRet;
END IF;

-- Dias de interes.
LET iDiasInt = dtFechaProx - dtFechaHoy;

IF NVL(iDiasInt,0) <= 0 THEN
    LET cCodRet     = "000004";
    LET cMensajeRet = "Fechas incorrectas";
    RETURN cCodRet, cMensajeRet;
END IF;

SELECT a.empresa, a.sucursal, a.iva, a.plaza
  FROM bdinteg:si_sucursales a
 WHERE a.tpo_sucursal = "S"
  INTO TEMP tmp_sucursales_adn;
CREATE INDEX indx_sucursal_adn ON tmp_sucursales_adn (empresa, sucursal);

update statistics high for table tmp_sucursales_adn;

LET cBanTemp = 'S';

--CALL "informix".monthadd(dtFechaFinMes,-1) RETURNING dtFechaFinMesAnt;
--LET dtFechaFinMesAnt=DATE(MDY(MONTH(dtFechaFinMes),'01',YEAR(dtFechaFinMes))-1);
CALL "informix".sp_valfechabil(dtFechaHoy+1,'+') RETURNING cCodRet, dtFechaHoyAux;

-- *******************************************************
--  SELECCION DE CREDITOS PARA PROCESAR                  *
-- *******************************************************
SELECT 		   a.num_credito         , a.status_cred       , a.num_producto     , a.sucursal         , a.divisa           ,
               a.fecha_apertura      , a.tasa_interes      , a.tasa_moratorios  , b.sdo_capital      , b.monto_vencido    ,
               b.mto_venc_trasp      , b.cap_tras_no_venci , b.sdo_cap_insoluto , b.sdo_no_exig      , b.sdo_intereses    ,
               c.dia_corte           , b.int_tra_no_exig   , c.fecha_vencto     , c.prox_fecha_pago  , b.provision_normal ,
               b.sdo_global_int      , d.period_pago_cap   , b.sdo_dia_ant_int  , b.sdo_mes_ant_int  , b.sdo_moratorio    ,
               b.sdo_contab_mora     , b.monto_financiado  , b.mto_venc_int     , b.mto_finan_vdo    , b.sdo_trab4        ,
	           nvl(c.tp_dias_fecha_pago,0) as tp_dias_fecha_pago , a.id_origen   , c.fecha_ult_pago   , a.fecha_vencim     , a.dias_trasp_cap   ,
               a.campo_trab3        , nvl(b.act,0) as act  , d.activo_retenido  , a.numcte
          FROM sd_maecred a, sd_maesdos b, sd_maecredanexo c, sd_definicion d
         WHERE a.num_credito   = b.num_credito
           AND a.empresa       = b.empresa
           AND c.num_credito   = a.num_credito
           AND c.empresa       = a.empresa
           AND d.num_producto  = "7800"
		   AND d.num_producto  = a.num_producto
           AND d.empresa       = c.empresa
           AND a.empresa       = cEmpresa
		   AND a.status_cred   IN ("AA","BA","BT","E1","E3")
           AND c.fecha_proceso = dtFechaHoy
		   into temp creditos_adn with no log;

		   create unique index inx_creditos_adn on creditos_adn(num_credito);
		   update statistics high for table creditos_adn force;

FOREACH WITH HOLD
		SELECT num_credito         , status_cred       , num_producto     , sucursal         , divisa           ,
               fecha_apertura      , tasa_interes      , tasa_moratorios  , sdo_capital      , monto_vencido    ,
               mto_venc_trasp      , cap_tras_no_venci , sdo_cap_insoluto , sdo_no_exig      , sdo_intereses    ,
               dia_corte           , int_tra_no_exig   , fecha_vencto     , prox_fecha_pago  , provision_normal ,
               sdo_global_int      , period_pago_cap   , sdo_dia_ant_int  , sdo_mes_ant_int  , sdo_moratorio    ,
               sdo_contab_mora     , monto_financiado  , mto_venc_int     , mto_finan_vdo    , sdo_trab4        ,
	           tp_dias_fecha_pago  , id_origen         , fecha_ult_pago   , fecha_vencim     , dias_trasp_cap   ,
               campo_trab3         , act               , activo_retenido  , numcte
          INTO cNumCredito          , cStatusCred         , cNumProducto       , cSucursal           , cDivisa            ,
               dtFechaApert         , dTasaInter          , dTasaInterMor      , dSdoCapital         , dMntVencido        ,
               dMntVencTras         , dCapTrasNoVen       , dSdoCapInso        , dSdoNoExig          , dSdoInt            ,
               iDiaCorte            , dIntVdo             , dtFechaVencto      , dtFechaMesiversario , dIntProvFinMes     ,
               dIvaProvFinMes       , iPerTrasp           , dSdodiaantint      , dSdomesantint       , dSdomoratorio      ,
               dSdocontabmora       , dMontofinanciado    , dIvaIntVencido     , dIvaIntVigente      , dSdotrab4          ,
               iTpDiasFechaPago     , v_marca_ayuda       , vf_fecha_ult_pago  , vf_fecha_vencim     , vi_dias_trasp_cap  ,
               Campotrabajo3        , iAct                , c_act_retenido     , c_numcte
          FROM creditos_adn 
        
      --LET cBanderaIFSR = 'I';
	IF (cStatusCred NOT IN ('E1','E2','E3')) THEN -- IFSR se contempla para el caso cuando no esta activo el IFSR 
		 
--          IF cBegin = "N" AND iContCommit=0 THEN
               BEGIN WORK;
               LET cBegin = "S";
--           END IF;

            LET cStatusCredAnt     = cStatusCred;
            LET cStatusCredIndica  = cStatusCred;
            LET cIdProc1          = "";	 LET cIdProc2          = "";
            LET cIdProc3          = "";	 LET cIdProc4          = "";
            LET dIvaIntReal       = 0;	 LET dIvaIntReal_inh   = 0;
            LET dProvIva          = 0;	 LET dProvInt          = 0;
            LET dProvIva_inh      = 0;	 LET dProvInt_inh      = 0;
            LET dCapMtoCuota      = 0;	 LET dSdoInt_inh       = 0;
            LET dIntGrav_inh      = 0;	 LET dIntExen_inh      = 0;
            LET iDiasInt_inh      = 0;	 LET dIntDiario_inh    = 0;
			LET dtFechaMesiversarioAux = DATE(1);
            
--APOYO 2017 INI
--        SELECT bandera INTO wbandera_apoyo FROM sd_programa_apoyo2017 WHERE num_credito = cNumCredito;
	
        IF ( wbandera_apoyo is null ) THEN 
            LET wbandera_apoyo = ''; 
        END IF;
--APOYO 2017 FIN

-- Venta de Cartera de PP
		IF ( v_marca_ayuda = '1' OR cStatusCred = 'CV' OR ( Campotrabajo3 = 'BAJA' AND cStatusCred <> 'CV' ) OR wbandera_apoyo ='A' ) THEN

			  -- Identificar  (Cierre de Mes).
			 IF dtFechaHoy = dtFechaFinMes THEN
			    LET cIdProc1 = "C";
			 END IF;
			 -- Validaciones para dias inhabiles y cambios de mes. (Facturacion)
			 IF dtFechaHoyAux = dtFechaMesiversario THEN
				LET cIdProc2 = "F";
			 END IF;
			 -- Identificar un (Mesiversario)
			 IF dtFechaHoy = dtFechaMesiversario THEN
				 LET cIdProc3 = "M";
			 END IF;
             --FMV 7mar13: Valida registros de la Provision a fin de mes, para PP Factu dia 1o. de mes
             IF cIdProc1 = "C" AND cIdProc2 = "F" THEN
                 LET cIdProc4 = "P";  --> Registro para validar (P)rovision
                 --LET iDiasInt_inh = iDiasInt - 1;--CJAC
             END IF;

            /*select sum(interes_debe - interes_pagado) vencido_balanza,
                   sum(iva_debe - iva_pagado) iva_vencido_balanza
              into vlIntVenBal, vlIvaIntVenBal
              from bdicred:sd_amortiza_credito 
             where empresa = cEmpresa 
               and num_credito = cNumCredito 
               and campo_trabajo3 <> 'V'
               and capital_status = '2';*/ --CJAC
        
--            if  vlIntVenBal is null then
--               let vlIntVenBal = 0;
--               let vlIvaIntVenBal = 0;
--            end if;

			 CALL sp_actsdodiario(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
										  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
										  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
										  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
										  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
									dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal ,dMontofinanciado,dtFechaHoy,cStatusCred,dtFechaVencto,NULL)-- IFSR se agregan nuevos campos para llamado al nuevo actuaiza saldos
--									dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal ,dtFechaHoy)
			RETURNING cCodRet;

			IF (cCodRet <> "000") THEN
				 LET cCodRet     = "000002";
				 LET cMensajeRet = "Error al grabar en tabla saldos diarios";
				 RETURN cCodRet, cMensajeRet;
			END IF;

            IF ( v_marca_ayuda = '1' OR ( Campotrabajo3 = 'BAJA' AND cStatusCred <> 'CV' ) OR wbandera_apoyo ='A') THEN


               SELECT COUNT(*),  min(fecha_cuota)
                 INTO iNumVdos, vf_fecha_vencim
                 FROM "informix".sd_amortiza_credito a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status IN ("2","7");

                UPDATE sd_maesdos
                SET mto_fin_ven_trasp = iNumVdos
                WHERE  empresa = cEmpresa
                  AND  num_credito = cNumCredito;

               UPDATE "informix".sd_maecredanexo
                  SET fecha_proceso  = dtFechaProx,
                       fecha_vencto  = vf_fecha_vencim
                WHERE num_credito    = cNumCredito
                  AND empresa        = cEmpresa;

               IF cIdProc1 = "C" OR DAY(dtFechaHoy) = 20 THEN
                  INSERT INTO "informix".sd_maesdoscont
                       SELECT dtFechaHoy, *
                         FROM informix.sd_maesdos
                        WHERE num_credito = cNumCredito
                           AND empresa     = cEmpresa;

                  INSERT INTO "informix".sd_maecredcont
                       SELECT dtFechaHoy, empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,
								status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,
								cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,
								codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,
								bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,
								tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
                         FROM informix.sd_maecred
                        WHERE num_credito = cNumCredito
                          AND empresa     = cEmpresa;
               END IF;
               IF ( cIdProc3 = "M" ) THEN
                  call "informix".calculamesiversario(iDiaCorte::INTEGER, dtFechaMesiversario, 1, iTpDiasFechaPago)
                        RETURNING cCodRet, dtFechaProxCuota;

                  UPDATE "informix".sd_maecredanexo
                     SET prox_fecha_pago = dtFechaProxCuota
                   WHERE num_credito     = cNumCredito
                     AND empresa         = cEmpresa;
               END IF;

               IF ( cIdProc3 = "M" OR cIdProc2 = "F" ) THEN
                  INSERT INTO "informix".sd_maesdoshist
                       SELECT dtFechaHoy, *, 0.0
                         FROM informix.sd_maesdos
                        WHERE num_credito = cNumCredito
                          AND empresa     = cEmpresa;
               END IF;

			   IF (  cIdProc2 = "F" or cIdProc3 = "M") AND wbandera_apoyo ='A' THEN
				 INSERT INTO "informix".sd_maesdos_apoyo2017
                 SELECT dtFechaHoy, * FROM informix.sd_maesdos
				 WHERE num_credito = cNumCredito AND empresa = cEmpresa;
			  
				 INSERT INTO bdicred:"informix".sd_amortiza_credito_apoyo2017
				 SELECT dtFechaHoy, * FROM bdicred:"informix".sd_amortiza_credito
				  WHERE num_credito = cNumCredito AND empresa = pEmpresa;					  
				 if  cIdProc3 = "M" then
				   update bdicred:"informix".sd_amortiza_credito
				      set fecha_cuota = monthadd(fecha_cuota,1)
				    where capital_status in (3,7,1)
				      AND num_credito = cNumCredito
                      AND empresa = pEmpresa;
				 end if;
			   END IF;			   
			   
			   IF cIdProc1 ='C' THEN
			     SELECT min(fecha_cuota) INTO  iFechaVencto
				 FROM "informix".sd_amortiza_credito a
				 WHERE a.empresa = cEmpresa
				 AND a.num_credito = cNumCredito
				 AND a.capital_status IN ("2","7");
						  
				 IF iFechaVencto IS NULL THEN LET vdias_atraso= 0;
				 ELIF cStatusCred ='AA' THEN LET vdias_atraso= 0;
				 ELSE
			       LET vdias_atraso = (dtFechaFinMes - nvl(iFechaVencto,dtFechaFinMes) + 1);                   
				 END IF;	 
				 UPDATE "informix".sd_indicador_cred
                      SET dias_atraso   = NVL(vdias_atraso,0)  
                     WHERE empresa = pEmpresa
                     AND num_credito = cNumCredito;
			   END IF;
            END IF;
            COMMIT WORK;
            CONTINUE FOREACH;
		END IF;

-- *******************************************************
--  CALCULO DE INTERESES DIARIOS                         *
-- *******************************************************
           --Se obtiene el saldo para calcular los int diarios.
  --FMV 09-may-11  Calcula el int sobre el sdo capital sin el monto de traspaso ya calculado en la facturacion
--            SELECT sum(capital_debe - capital_pagado)
--               INTO dCapTrasVen_Amort
--              FROM sd_amortiza_credito
--             WHERE empresa = cEmpresa
--               AND num_credito = cNumCredito
--               AND capital_status = '1';
--
--               IF dCapTrasVen_Amort IS NULL
--                 THEN
--                    LET dCapTrasVen_Amort = 0;
--               END IF;
                  --calculo de los int diarios
                  --LET dIntDiario = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt; --CJAC
             IF dtFechaHoy = dtFechaFinMes AND dtFechaHoyAux = dtFechaMesiversario THEN
                 LET cIdProc4 = "P";  --> Registro para validar (P)rovision
                 --LET iDiasInt_inh = iDiasInt - 1; --CJAC
             END IF;

            --IF cIdProc4 = "P"  THEN
               --LET dIntDiario_inh = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt_inh; --CJAC
               --LET dSdoInt_inh  = dSdoInt_inh + dSdoInt + dIntDiario_inh; --CJAC
            --END IF;

                  --Actualizacion de los int diarios en maestro de saldos (sd_maesdos)
                  --LET dSdodiaantint = dSdoInt; --CJAC
                  --LET dSdoInt       = dSdoInt + dIntDiario; --CJAC
                  --Actualizacion de los int diarios en sd_amortiza_credito
                  /*UPDATE "informix".sd_amortiza_credito
                     SET interes_debe = interes_debe + dIntDiario
                   WHERE empresa        = cEmpresa
                     AND num_credito    = cNumCredito
                     AND capital_status = "3";*/ --CJAC

                  --Se actualiza la fecha del proximo proceso
                  UPDATE "informix".sd_maecredanexo
                     SET fecha_proceso  = dtFechaProx
                   WHERE num_credito    = cNumCredito
                     AND empresa        = cEmpresa;

-- *******************************************************
--  IDENTIFICACION DE PROCESOS POR REALIZAR              *
-- *******************************************************
          -- Validacion para identificar un (Cierre de Mes).
          IF dtFechaHoy = dtFechaFinMes THEN
            LET cIdProc1 = "C";
          END IF;
          -- Validaciones para dias inhabiles y cambios de mes. (Facturacion)
		  --validar dia inhabiles para realizar el cobro antes 
		    IF WEEKDAY(dtFechaMesiversario) = 0  THEN
				LET dtFechaMesiversarioAux =dtFechaMesiversario - 2 UNITS DAY;
				LET iBanderaDiaInhabil =1;
			ELIF  WEEKDAY(dtFechaMesiversario) = 6 THEN
				LET dtFechaMesiversarioAux =dtFechaMesiversario - 1 UNITS DAY;
				LET iBanderaDiaInhabil =1;
			ELSE 
				LET iBanderaDiaInhabil =0;
			END IF

          IF dtFechaHoyAux = dtFechaMesiversario AND iBanderaDiaInhabil =0   THEN
                LET cIdProc2 = "F";
				--se obtiene la fecha de la proxima cuota.--se corrige fecha de envio
				EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',dtFechaMesiversario,cNumCredito)
				INTO cCodRet,dtFechaProxCuota,iDiaCorte;
			
           END IF;
		   IF  dtFechaHoyAux =  dtFechaMesiversarioAux THEN
                LET cIdProc2 = "F";
				--se obtiene la fecha de la proxima cuota.--se corrige fecha de envio
				EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',dtFechaMesiversario,cNumCredito)
				INTO cCodRet,dtFechaProxCuota,iDiaCorte;
			
           END IF;
	 
	
          -- Validaciones para identificar un (Mesiversario)
          IF dtFechaHoy = dtFechaMesiversario THEN
             LET cIdProc3 = "M";
              EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',dtFechaHoy,cNumCredito)
				INTO cCodRet,dtFechaProxCuota,iDiaCorte;
          END IF;

-- *******************************************************
--  Calculo de Iva de Interes                            *
-- *******************************************************
 SELECT a.iva, a.plaza
   INTO dIvaSuc, cPlaza
   FROM tmp_sucursales_adn a
  WHERE empresa  = cEmpresa
    AND sucursal = cSucursal;

IF cIdProc1 = "C" AND cIdProc4 = "P" and (dSdoCapital + dCapTrasNoVen) > 0 THEN

           SELECT a.fecha_cuota,
                --  a.iva_pagado,
--                  a.iva_fecha_pago,
                  NVL(a.capital_mto_cuota,0),
                  NVL(num_pago,1)
             INTO dtFechaCuota,
                 -- dIvaPag,
--                  dtIvaFechaPag,
                  dCapMtoCuota,
                  iNumPago
             FROM "informix".sd_amortiza_credito a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status = "3";

               IF dtFechaCuota IS NOT NULL THEN
                   LET dtFechaCuotaAnt = dtFechaCuota;
               END IF;

-- LET dSdoInt = dSdoInt + dIntDiario;
 --LET dProvInt_inh = dSdoInt_inh; --CJAC


               IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
               IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

       --LET dProvIva_inh = dIvaIntReal_inh; -- dIvaProvFinMes; --CJAC

       IF  cStatusCred='BT' THEN
            LET CodigoRefProvIva    = 9;   
            LET CodigoRefProvInt    = 8;   
       ELSE
            LET CodigoRefProvIva    = 7;
            LET CodigoRefProvInt    = 6;
       END IF;

        /*IF dProvInt_inh > 0 THEN              
                LET dProvInt = dProvInt - dIntProvFinMes;

				

            --LET dProvIva_inh = dProvIva_inh - dIvaProvFinMes; FMV 19mar13 NO SE DESCUENTA PROVISION FIN DE MES y PROVISIONA IVA
                IF dProvIva_inh > 0 THEN

					
                END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
---SE AGREGA VALIDACION PARA NO GENERAR INTERES EXENTO NI GRAVABLE PARA CREDISOLUCIONES
			IF cNumProducto <> '6900' THEN
                IF dProvInt_inh>0 and dProvIva_inh<=0 then
                    LET dIntGrav_inh = dProvInt_inh;
                    LET dIntExen_inh = 0;
                ELSE
                    LET dIntGrav_inh = dProvIva_inh/dIvaSuc;
                    IF dIntGrav_inh>dProvInt_inh THEN LET dIntGrav_inh=dProvInt_inh; END IF;
                    LET dIntExen_inh = dProvInt_inh-dIntGrav_inh;
                END IF;

                IF dIntGrav_inh>0 THEN
						
                END IF;
                IF dIntExen_inh>0 THEN
						
                END IF;
			END IF;
---fin cas, Se agrega el movimiento aplicativo de interes gravable y exento
        END IF;*/   --CJAC
END IF;
--*************************************************************************
--   FIN DE PROVISION POR REGISTROS DE MOVTO EN FIN MES
--*************************************************************************
-- *******************************************************
--  PROVISION                                            *
-- *******************************************************
IF cIdProc1 = "C" OR cIdProc2 = "F" and (dSdoCapital + dCapTrasNoVen) > 0 THEN

           SELECT a.fecha_cuota, --  a.iva_pagado,
--                  a.iva_fecha_pago,
                  NVL(a.capital_mto_cuota,0),NVL(num_pago,1)
             INTO dtFechaCuota,-- dIvaPag,
--                  dtIvaFechaPag,
                  dCapMtoCuota,iNumPago
             FROM "informix".sd_amortiza_credito a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status = "3";

               IF dtFechaCuota IS NOT NULL THEN
                   LET dtFechaCuotaAnt = dtFechaCuota;
               END IF;

-- LET dSdoInt = dSdoInt + dIntDiario;
 --LET dProvInt = dSdoInt;--CJAC



               IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
               IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

      -- LET dProvIva = dIvaIntReal; -- dIvaProvFinMes;  --CJAC

       IF  cStatusCred='BT' THEN
            LET CodigoRefProvIva    = 9;   --FMV 6ene11: Se cambian codigos 8 x 9 para Vencido
            LET CodigoRefProvInt    = 8;   --FMV 6ene11: Se cambian codigos 9 x 8 para Vencido
       ELSE
            LET CodigoRefProvIva    = 7;
            LET CodigoRefProvInt    = 6;
       END IF;

        /*IF dProvInt > 0 THEN  
                IF cIdProc4 = '' THEN
                   LET dProvInt = dProvInt - dIntProvFinMes;
                ELSE
                   LET dProvInt = dProvInt - dIntProvFinMes - dProvInt_inh;
                END IF;
           

                              
                IF cIdProc4 = '' THEN
                   LET dProvIva = dProvIva - dIvaProvFinMes;
                ELSE
                   LET dProvIva = dProvIva - dIvaProvFinMes - dProvIva_inh;
                END IF;
  
                IF dProvIva > 0 THEN
						
                END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
---SE AGREGA VALIDACION PARA NO GENERAR INTERES EXENTO NI GRAVABLE PARA CREDISOLUCIONES
			IF cNumProducto <> '6900' THEN
                IF dProvInt>0 and dProvIva<=0 then
                    LET dIntGrav = dProvInt;
                    LET dIntExen = 0;
                ELSE
                    LET dIntGrav = dProvIva/dIvaSuc;
                    IF dIntGrav>dProvInt THEN LET dIntGrav=dProvInt; END IF;
                    LET dIntExen = dProvInt-dIntGrav;
                END IF;

                IF dIntGrav>0 THEN
						
                END IF;
                IF dIntExen>0 THEN
						
                END IF;
			END IF;
---fin cas, Se agrega el movimiento aplicativo de int gravable y exento
        END IF;*/  --CJAC
END IF;

-- *******************************************************
-- FACTURACION                                           *
-- *******************************************************

--FMV 31-ENE-11
IF cIdProc2 = "F" AND (dSdoCapital + dCapTrasNoVen) > 0 THEN
        LET iNumPago = iNumPago + 1 ;
        
--      select nvl((interes_debe - interes_pagado),0),
--				nvl((iva_debe - iva_pagado),0) + nvl(dIvaIntReal,0)
--		  into  vlIntVenBal, vlIvaIntVenBal
--		  from bdicred:sd_amortiza_credito 
--		  where empresa = cEmpresa 
--			and num_credito = cNumCredito 
--			and capital_status = '3';	 
        
		IF (dSdoCapital + dCapTrasNoVen - (dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal)) <= 0  and (dSdoCapital + dCapTrasNoVen) > 0 THEN
		
		LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + vlIntVenBal + vlIvaIntVenBal;
		--	LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + dProvInt + dProvIva + dIntProvFinMes + dIvaProvFinMes;
			UPDATE "informix".sd_amortiza_credito
			   SET capital_mto_cuota   = dCapMtoCuota
			 WHERE empresa             = cEmpresa
			   AND num_credito         = cNumCredito
			   AND capital_status      = "3";
		END IF;
		
		LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen ;

        LET dMontofinanciado = dSdoCapital ;
        --LET dMontofinanciado = dMontofinanciado + dCapMtoCuota - dProvInt - dProvIva - dIntProvFinMes - dIvaProvFinMes - dProvInt_inh - dProvIva_inh;
        LET dSdotrab4 = dSdotrab4  + dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal;
        --LET dSdotrab4 = dSdotrab4  + dCapMtoCuota - dProvInt - dProvIva- dIntProvFinMes - dIvaProvFinMes - dProvInt_inh - dProvIva_inh;
        LET dSdomesantint = vlIntVenBal; --dSdoInt;
        LET dSdoNoExig = dSdoNoExig +  vlIntVenBal; --dSdoInt;
        LET dSdoInt = 0;
        LET dIvaIntVigente = dIvaIntVigente + dIvaIntReal;

        IF cIdProc2 = "F" THEN LET dIntProvFinMes=0; LET dIvaProvFinMes=0; END IF;

		UPDATE "informix".sd_amortiza_credito
		   SET capital_debe        = dMontofinanciado,
			   capital_status      = "1",
			   capital_status_ant  = "3"
		 WHERE empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "3";


		select  capital_debe
		  into vlCapitalDebe
		  from "informix".sd_amortiza_credito
		 WHERE empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "1";

		if vlCapitalDebe is null then let vlCapitalDebe = 0; end if;

		/*select interes_debe,
			   iva_debe
		  into dIntPeriodo,
			   dIvaPeriodo
		  from "informix".sd_amortiza_credito
		 where empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "1";

	    IF dIntPeriodo IS NULL THEN LET dIntPeriodo=0; END IF;
	    IF dIvaPeriodo IS NULL THEN LET dIvaPeriodo=0; END IF;

		IF dIntPeriodo>0 THEN
				
		END IF;

		IF dIvaPeriodo>0 THEN
				
		END IF;*/ --CJAC
      -- LET vlCapitalDebe = dCapMtoCuota - (interes_debe - interes_pagado) - (dIvaIntReal);
	  --FNV: 31-ENE-2011
		 --IF (dSdoCapital + dCapTrasNoVen - dCapMtoCuota) > 0 THEN
		IF (dSdoCapital + dCapTrasNoVen - vlCapitalDebe) > 0 THEN
	  -- IF (dSdoCapital - dCapMtoCuota) >  0 THEN
			   
			   IF NOT EXISTS (SELECT num_credito FROM  "informix".sd_amortiza_credito
							WHERE empresa = cEmpresa and num_credito = cNumCredito and fecha_cuota =dtFechaProxCuota) THEN
			   INSERT INTO "informix".sd_amortiza_credito
						(
							empresa, 		    num_credito, 		fecha_cuota, 		tipo_cuota,
							capital_mto_cuota, 	capital_debe,		capital_pagado, 	capital_status,
							capital_status_ant, capital_fecha_pago,	interes_debe, 		interes_pagado,
							interes_status, 	interes_status_ant,	interes_fecha_pago, iva_debe,
							iva_pagado, 		iva_status,			iva_status_ant, 	iva_fecha_pago,
							mora_provi_ordi, 	mora_provi_cope,	mora_sdo_ordi, 		mora_sdo_ordi_pag,
							mora_sdo_cope, 		mora_sdo_cope_pag,	mora_bonificado, 	mora_status,
							mora_iva_debe, 		mora_iva_pagado,	mora_iva_status, 	mora_iva_fecha_pago,
							num_pago, 		    campo_trabajo1,		campo_trabajo2, 	campo_trabajo3,
							campo_trabajo4
						)
					VALUES
						(   cEmpresa,		    cNumCredito,	dtFechaProxCuota,	"3",
							0,	NVL(dCapMtoCuota,0),			0,			        "1",
							"3",         		"",				0,			         0,
							"1",                "1",			NULL,			     0,
							0,			        "1",			"1",                 "",
							0,			         0,				0,			         0,
							0,			         0,				0,			         "1",
							0,			          0,			"1",			     "",
							NVL(iNumPago,0),		      0,			0,			         "",
							""
						);
				END IF;
	   END IF;
END IF;

-- *******************************************************
-- TRASPASOS                                             *
-- *******************************************************
    -- Traspaso de Vigente a Vencido Transitorio.
 IF  cIdProc3 = "M"  THEN

               SELECT NVL(a.capital_debe - a.capital_pagado,0) --,NVL(a.interes_debe - a.interes_pagado,0)
                 INTO dTraspCap --,dTraspInt
                 FROM "informix".sd_amortiza_credito a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status = "1";

					IF dTraspCap IS NULL THEN LET dTraspCap=0; END IF;
--					IF dTraspInt IS NULL THEN LET dTraspInt=0; END IF;
----Realiza traspasos a transitorio
        IF cStatusCred IN ('AA','BA') THEN
			IF dTraspCap>0 THEN

               LET dMntVencido = dMntVencido + dTraspCap;
               LET dSdoCapital = dSdoCapital - dTraspCap;

                UPDATE "informix".sd_amortiza_credito
                   SET capital_status = "7",
                       capital_status_ant  = "1",
                       campo_trabajo3 = ''
                 WHERE empresa        = cEmpresa
                   AND num_credito    = cNumCredito
                   AND capital_status = "1";

						IF cStatusCred='AA' THEN
							  --Se actualiza la fecha de vencimiento
							  UPDATE "informix".sd_maecredanexo
								 SET fecha_vencto  = dtFechaHoy
							   WHERE num_credito    = cNumCredito
								 AND empresa        = cEmpresa;

							 --FMV 25Abr13: Actualiza indicador del 1er. vencido y dias de atraso
							  UPDATE "informix".sd_indicador_cred
								 SET fecha_vencido =  DECODE (nvl(fecha_vencido,date(1)) ,date(1), dtFechaHoy, fecha_vencido)
							   WHERE num_credito   = cNumCredito
								 AND empresa       = cEmpresa;
						END IF;

                  -- Traspaso capital vigente a transitorio.
						 CALL genmovcierre_movdia(cEmpresa, cNumCredito, cNumCredito,1, "602", dtFechaHoy, dTraspCap, cFolio, cSucursal, cDivisa, "",cPlaza) RETURNING   cCodRet,cMensajeRet;
						IF (cCodRet <> "00000") THEN
							ROLLBACK WORK;	
						END IF;
						 
					    
            END IF; --IF dTraspCap>0 THEN
		END IF; --IF cStatusCred IN ('AA','BA') AND cNumProducto <> '6900' THEN

        --ELSE
			IF cIdProc3 = "M" AND cStatusCred='BT' THEN
                LET dMntVencTras = dMntVencTras + dTraspCap;
                LET dCapTrasNoVen = dCapTrasNoVen - dTraspCap;
                LET dIntVdo = dIntVdo + dSdoNoExig;
                LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;
                LET dIvaIntVigente=0;

                UPDATE "informix".sd_amortiza_credito
                   SET capital_status = "2",
                       capital_status_ant  = "1",
                       campo_trabajo3 ='V'
                 WHERE empresa        = cEmpresa
                   AND num_credito    = cNumCredito
                   AND capital_status = "1";

                   LET dSdoNoExig = 0;

                  -- Traspaso capital vencido no exigible a vencido exigible.
                IF dTraspCap > 0 THEN --FMV 25Mar13: Se omite generar movimiento en 0, cuando ya termino devengamiento
                    -- Capital de Vigente a Traspasado
			                   

					  CALL genmovcierre_movdia(cEmpresa, cNumCredito, cNumCredito,1, "601", dtFechaHoy, dTraspCap,
                                    cFolio, cSucursal, cDivisa, "",cPlaza) RETURNING   cCodRet,cMensajeRet;
                        IF (cCodRet <> "00000") THEN
                            ROLLBACK WORK;                           
                        END IF;
                END IF;  --dTraspCap > 0 THEN  FMV 25Mar13:
			END IF; --IF cIdProc3 = "M" AND cStatusCred='BT' THEN


                UPDATE "informix".sd_maecredanexo
                   SET prox_fecha_pago = dtFechaProxCuota,
                       dia_corte       = iDiaCorte
                  WHERE num_credito     = cNumCredito
                    AND empresa         = cEmpresa;

                    IF (cStatusCredIndica = "AA" and dTraspCap>0) then
                        let cStatusCredIndica = 'BA';
                    END IF;
					
				IF (cStatusCred = "AA" and dTraspCap>0)	THEN
					LET cStatusCred = "BA";
				END IF;

                UPDATE "informix".sd_maecred
                   SET status_cred = cStatusCred, 
                       fecha_pago_cap = dtFechaProxCuota,
                       fecha_pago_int = dtFechaProxCuota
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;
---Ini cas Validacion solicitada por operaciones para que no cobre el int devengado
---de un dia cuando la reestructura llega a su Oltima mensualidad
                    IF dCapTrasNoVen = 0 AND dSdoCapital = 0 AND dSdoInt > 0 THEN
                       LET dSdoInt = 0;
                    END IF;
---Fin cas Validacion solicitada por operaciones
END IF;

------Realiza traspasos a vencido
-- FMV 9jul2013: Traspaso a Vencido aquellos prestamos que llegan a la ultima cuota y pasan los 90 dias vencidos
-- JOM 11/04/2013 Se cambia traspado a periodos INI
-- Se realiza el traspado en la mensualidad 4 para considerar 90 o mas dias en transitorio            
           /*SELECT COUNT(a.num_credito), nvl(min(fecha_cuota), date(1))
             INTO iNumVdos, dFechacuotamin
             FROM "informix".sd_amortiza_credito a
            WHERE a.empresa        = cEmpresa
              AND a.num_solicitud    = cNumCredito
              AND a.capital_status IN ("2","7");*/
			  
			SELECT nvl(fecha_ult_disp, date(1)) INTO dFechacuotamin
			FROM bdisolic:ss_adn_solicitudcuenta 
			WHERE num_solicitud =cNumCredito;
 
            
          
                LET iNumVdosaux = months_between(dtFechaHoy ,dFechacuotamin );
          

            IF  (cStatusCredAnt ='BA' AND iNumVdosaux > 3 and dFechacuotamin <> date(1)) 
--            IF cStatusCred='BA' AND (dtFechaVencto + vi_dias_trasp_cap <= dtFechaHoy) --OR vf_fecha_vencim < dtFechaHoy
-- JOM 11/04/2013 Se cambia traspado a periodos FIN
				  THEN
						LET dCapTrasNoVen = dCapTrasNoVen + dMntVencTras;
						LET dMntVencTras = dMntVencTras + dMntVencido;
						LET dIntVdo = dIntVdo + dSdoNoExig;
						LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;
						
						LET cStatusCred = "BT";

						UPDATE "informix".sd_maecred
						   SET status_cred = cStatusCred
						 WHERE num_credito = cNumCredito
						   AND empresa     = cEmpresa;

						UPDATE "informix".sd_amortiza_credito
						   SET capital_status = "2",
							   capital_status_ant  = "7"
						 WHERE empresa        = cEmpresa
						   AND num_credito    = cNumCredito
						   AND capital_status = "7";

                  -- Traspaso capital vigente a vdo no exigible.
					IF dCapTrasNoVen > 0 THEN
					 CALL genmovcierre_movdia(cEmpresa, cNumCredito, cNumProducto,1, "600", dtFechaHoy, dCapTrasNoVen,
                                 cFolio, cSucursal, cDivisa, "",cPlaza) RETURNING  cCodRet,cMensajeRet;
                        IF (cCodRet <> "00000") THEN
                            ROLLBACK WORK;                           
                        END IF;
					END IF; -- IF dCapTrasNoVen > 0 THEN

					 

					
						LET dSdoCapital = 0;
						LET dMntVencido = 0;
						LET dIvaIntVigente = 0;
						LET dSdoNoExig = 0;
            END IF; --  cStatusCred='BA' AND (dtFechaVencto + vi_dias_trasp_cap <= dtFechaHoy) OR vf_fecha_vencim < dtFechaHoy


-- *******************************************************
-- CALCULO DE INTERES MORATORIO                          *
-- *******************************************************
    --LET dTasaInterMorCop = dTasaInterMor - dTasaInter; CJAC

/*FOREACH
     SELECT a.fecha_cuota,
            SUM(NVL(a.capital_debe,0) - NVL(a.capital_pagado,0))
       INTO dtFechaCuota,
            dSdoMora
       FROM "informix".sd_amortiza_credito a
      WHERE a.empresa        = cEmpresa
        AND a.num_credito    = cNumCredito
        AND a.capital_status IN ("2","7")
   GROUP BY 1

     IF NVL(dSdoMora,0) > 0 THEN
          --Se calcula el interes moratorio
          LET dIntMora = (dSdoMora * dTasaInter / (iDiasCalc * 100)) * iDiasInt;

          --Se calculan el interes moratorio copete
          LET dIntCope = (dSdoMora * dTasaInterMorCop / (iDiasCalc * 100)) * iDiasInt;

          -- se actualizan los intereses moratorios en la amortiza
          UPDATE "informix".sd_amortiza_credito
             SET mora_sdo_ordi = mora_sdo_ordi + dIntMora,
                 mora_sdo_cope = mora_sdo_cope + dIntCope
           WHERE empresa     = cEmpresa
             AND num_credito = cNumCredito
             AND fecha_cuota = dtFechaCuota;

             LET dSdomoratorio = dSdomoratorio + dIntCope;
             LET dSdocontabmora = dSdocontabmora + dIntMora;
     END IF;
END FOREACH;*/ --CJAC

	IF cStatusCred <> 'AA' then
	   SELECT COUNT(*)
		 INTO iNumVdos
		 FROM "informix".sd_amortiza_credito a
		WHERE a.empresa        = cEmpresa
		  AND a.num_credito    = cNumCredito
		  AND a.capital_status IN ("2","7");
	ELSE	
		LET iNumVdos = 0;
	END IF;

   IF iNumVdos IS NULL THEN
      LET iNumVdos = 0;
   END IF;

    UPDATE sd_maesdos
    SET fecha_ult_mov = dtFechaHoy,
--        sdo_int_anticip = 0,
--        sdo_int_ant_dev = 0,
--        sdo_intereses = 0,
--        sdo_dia_ant_int = 0,
--        sdo_mes_ant_int = 0,
--        sdo_acum_mes_int = 0,
--        sdo_retenido = 0,
--        sdo_acum_cap_int = 0,
--        sdo_exig_int = 0,
        sdo_no_exig = NVL(dSdoNoExig,0),
--        provision_normal = 0,
--        dias_acum_int = 0,
--        sdo_dia_ant_mor =0,
--        sdo_mes_ant_mor= 0,
--        sdo_moratorio = 0,
--        sdo_contab_mora = 0,
--        dias_acum_mora = 0,
        sdo_dia_ant_cap = sdo_cap_insoluto,
--        sdo_mes_ant_cap = 0,
--        sdo_acum_mes_cap = 0,
        sdo_capital = dSdoCapital,
        sdo_cap_insoluto = dSdoCapInso,        
--        mto_ministra_cap = 0,
        dias_acum_cap = (dias_acum_cap + iDiasInt),
        monto_vencido = dMntVencido,
        mto_venc_trasp = dMntVencTras,
        monto_financiado = dMontofinanciado,
--        sdo_global_int = 0,
        cap_tras_no_venci = dCapTrasNoVen,
        mto_venc_int = dIvaIntVencido,
        mto_finan_vdo = dIvaIntVigente,
        int_tra_no_exig = dIntVdo,
        sdo_trab4 = dSdotrab4,
        mto_fin_ven_trasp = iNumVdos
    WHERE  num_credito = cNumCredito;

-- *******************************************************
-- RESPALDO DE INFORMACION CONTABILIDAD A FIN DE MES     *
-- *******************************************************

     IF cIdProc1 = "C" THEN

           INSERT INTO "informix".sd_maesdoscont
                SELECT dtFechaHoy, *
                  FROM informix.sd_maesdos
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

           INSERT INTO "informix".sd_maecredcont
                SELECT dtFechaHoy, empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,
							status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,
							cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,
							codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,
							bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,
							tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
                  FROM informix.sd_maecred
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

             LET iContCierre = iContCierre + 1;

             /*IF (iContCierre = 80000) THEN
                LET iContCierre = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maesdoscont;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maecredcont;
             END IF;*/
     END IF;
-- *******************************************************
-- GENERAR HISTORICO DE SALDOS                           *
-- *******************************************************
    IF cIdProc3 = "M" OR cIdProc2 = "F" THEN
        INSERT INTO "informix".sd_maesdoshist
             SELECT dtFechaHoy, *, 0.0
               FROM informix.sd_maesdos
              WHERE num_credito = cNumCredito
                AND empresa     = cEmpresa;

            LET iContCorte = iContCorte + 1;

           /* IF iContCorte = 30000 THEN
                LET iContCorte = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movdia;
            END IF;*/
    END IF;

-- ***********************************
-- GUARDA SALDOS FIN DE DIA          *
-- ***********************************
      /*select sum(interes_debe - interes_pagado) vencido_balanza,
             sum(iva_debe - iva_pagado) iva_vencido_balanza
        into vlIntVenBal, vlIvaIntVenBal
        from bdicred:sd_amortiza_credito 
        where empresa = cEmpresa
          and num_credito = cNumCredito 
		      and campo_trabajo3 <> 'V'
          and capital_status = '2';*/ --CJAC
        
      if  vlIntVenBal is null then
         let vlIntVenBal = 0;
         let vlIvaIntVenBal = 0;
      end if;
-- RQM 07 085 calificacion credisoluciones
      IF DAY(dtFechaHoy) = 20 AND cNumProducto = '6900' AND iDiaCorte NOT IN (20,21) THEN
         INSERT INTO "informix".sd_maesdoshist
              SELECT dtFechaHoy, *, 0.0
                FROM informix.sd_maesdos
               WHERE num_credito = cNumCredito
                 AND empresa     = cEmpresa;
      END IF;
-- RQM 07 085 calificacion credisoluciones
    CALL sp_actsdodiario(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
										  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
										  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
										  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
										  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
									dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal ,dMontofinanciado,dtFechaHoy,cStatusCred,dtFechaVencto,NULL)-- IFSR se agregan nuevos campos para llamado al nuevo actuaiza saldos
--									dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal ,dtFechaHoy)
     RETURNING cCodRet;

        IF (cCodRet <> "000") THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "Error al grabar en tabla saldos diarios";
             RETURN cCodRet, cMensajeRet;
        END IF;

-- *******************************************************
-- FIN DEL PROCESO                                       *
-- *******************************************************
--          LET iContCommit = iContCommit + 1;

--           IF cBegin = "S" AND iContCommit > 2 THEN
--               LET iContCommit = 0;
--           END IF;
            --FMV 25abr13: Calcula indicadores para los prestamos por sus dias de atraso en vencidos
            --FMV 17jun13: Ajuste para prestamos q vencen a fin de mes y cambio de estatus vigente
		IF (dtFechaHoy = dtFechaFinMes)  THEN
			IF (cStatusCred = 'AA') THEN
				LET vdias_atraso = 0;
			ELSE
				LET vdias_atraso = (dtFechaFinMes - nvl(dtFechaVencto,dtFechaFinMes) + 1);
			END IF;

			 UPDATE "informix".sd_indicador_cred
				SET dias_atraso   = vdias_atraso,
					fecha_ultimo_pago = vf_fecha_ult_pago,
					fecha_ultimo_pago_h = vf_fecha_ult_pago
			  WHERE empresa = cEmpresa
				AND num_credito = cNumCredito;
		END IF; --IF cIdProc1 = "C"
		
		/*IF dtFechaHoy=mdy(12,31,2021) THEN

			--LET dtFechaHoy = mdy(08,31,2021);
			EXECUTE PROCEDURE "informix".sp_ambientar_indicador_7800(dtFechaHoy,cNumCredito)
			--EXECUTE PROCEDURE "informix".sp_ambientar_indicador_7800(mdy(11,30,2021),cNumCredito)
				INTO cCodRet, cMensajeRet;

			IF  cCodRet <> "000" THEN
				RETURN cCodRet,cMensajeRet;				 
			END IF;

		END IF;	*/
			
        COMMIT WORK;
        LET cBegin = "N";
		 
	
	ELSE --IFSR comienza el caso cuando esta activo el IFSR
		
		 --          IF cBegin = "N" AND iContCommit=0 THEN
               BEGIN WORK;
               LET cBegin = "S";
--           END IF;

            LET cStatusCredAnt     = cStatusCred;
            LET cStatusCredIndica  = cStatusCred;
            LET cIdProc1          = "";	 LET cIdProc2          = "";
            LET cIdProc3          = "";	 LET cIdProc4          = "";
            LET dIvaIntReal       = 0;	 LET dIvaIntReal_inh   = 0;
            LET dProvIva          = 0;	 LET dProvInt          = 0;
            LET dProvIva_inh      = 0;	 LET dProvInt_inh      = 0;
            LET dCapMtoCuota      = 0;	 LET dSdoInt_inh       = 0;
            LET dIntGrav_inh      = 0;	 LET dIntExen_inh      = 0;
            LET iDiasInt_inh      = 0;	 LET dIntDiario_inh    = 0;
			LET dtFechaMesiversarioAux = DATE(1);
			
			--IFSR sacar los dias
			LET iDiasAtraso =  abs(dtFechaHoy) - abs(date(dtFechaVencto));
			IF (iDiasAtraso IS NULL OR dtFechaVencto is null) THEN
				LET iDiasAtraso = 0;
			END IF;


-- Venta de Cartera de PP
		IF ( v_marca_ayuda = '1' OR cStatusCred = 'CV') THEN

			  -- Identificar  (Cierre de Mes).
			 IF dtFechaHoy = dtFechaFinMes THEN
			    LET cIdProc1 = "C";
			 END IF;
			 -- Validaciones para dis inhabiles y cambios de mes. (Facturacion)
			 IF dtFechaHoyAux = dtFechaMesiversario THEN
				LET cIdProc2 = "F";
			 END IF;
			 -- Identificar un (Mesiversario)
			 IF dtFechaHoy = dtFechaMesiversario THEN
				 LET cIdProc3 = "M";
			 END IF;
             --FMV 7mar13: Valida registros de la Provision a fin de mes, para PP Factu dia 1o. de mes
             IF cIdProc1 = "C" AND cIdProc2 = "F" THEN
                 LET cIdProc4 = "P";  --> Registro para validar (P)rovision
                 --LET iDiasInt_inh = iDiasInt - 1;--CJAC
             END IF;

			 CALL sp_actsdodiario(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
									0, 0,
									0,
									0,0,0 ,dMontofinanciado,dtFechaHoy,cStatusCred,dtFechaVencto,iAct)
			RETURNING cCodRet;

			IF (cCodRet <> "000") THEN
				 LET cCodRet     = "000002";
				 LET cMensajeRet = "Error al grabar en tabla saldos diarios";
				 RETURN cCodRet, cMensajeRet;
			END IF;

            IF ( v_marca_ayuda = '1' ) THEN


               SELECT COUNT(*),  min(fecha_cuota)
                 INTO iNumVdos, vf_fecha_vencim
                 FROM "informix".sd_amortiza_credito a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status IN ("2","7","6");

                UPDATE sd_maesdos
                SET mto_fin_ven_trasp = iNumVdos
                WHERE  empresa = cEmpresa
                  AND  num_credito = cNumCredito;

               UPDATE "informix".sd_maecredanexo
                  SET fecha_proceso  = dtFechaProx,
                       fecha_vencto  = vf_fecha_vencim
                WHERE num_credito    = cNumCredito
                  AND empresa        = cEmpresa;

               IF cIdProc1 = "C" OR DAY(dtFechaHoy) = 20 THEN
                  INSERT INTO "informix".sd_maesdoscont
                       SELECT dtFechaHoy, *
                         FROM informix.sd_maesdos
                        WHERE num_credito = cNumCredito
                           AND empresa     = cEmpresa;

                  INSERT INTO "informix".sd_maecredcont
                       SELECT dtFechaHoy, empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,
								status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,
								cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,
								codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,
								bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,
								tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
                         FROM informix.sd_maecred
                        WHERE num_credito = cNumCredito
                          AND empresa     = cEmpresa;
               END IF;
               
               IF ( cIdProc3 = "M" OR cIdProc2 = "F" ) THEN
                  INSERT INTO "informix".sd_maesdoshist
                       SELECT dtFechaHoy, *, 0.0
                         FROM informix.sd_maesdos
                        WHERE num_credito = cNumCredito
                          AND empresa     = cEmpresa;
               END IF;

			   
			   IF cIdProc1 ='C' THEN
			    						   
				 UPDATE "informix".sd_indicador_cred
                      SET dias_atraso   = NVL(iDiasAtraso,0)  
                     WHERE empresa = pEmpresa
                     AND num_credito = cNumCredito;
			   END IF;
            END IF;
            COMMIT WORK;
            CONTINUE FOREACH;
		END IF;

-- *******************************************************
--  CALCULO DE INTERESES DIARIOS                         *
-- *******************************************************
             IF dtFechaHoy = dtFechaFinMes AND dtFechaHoyAux = dtFechaMesiversario THEN
                 LET cIdProc4 = "P";  
             END IF;
			 
                  --Se actualiza la fecha del proximo proceso
                  UPDATE "informix".sd_maecredanexo
                     SET fecha_proceso  = dtFechaProx
                   WHERE num_credito    = cNumCredito
                     AND empresa        = cEmpresa;

-- *******************************************************
--  IDENTIFICACION DE PROCESOS POR REALIZAR              *
-- *******************************************************
          -- Validacion para identificar un (Cierre de Mes).
          IF dtFechaHoy = dtFechaFinMes THEN
            LET cIdProc1 = "C";
          END IF;
          -- Validaciones para dis inhabiles y cambios de mes. (Facturacion)
		  --validar dia inhabiles para realizar el cobro antes 
		    IF WEEKDAY(dtFechaMesiversario) = 0  THEN
				LET dtFechaMesiversarioAux =dtFechaMesiversario - 2 UNITS DAY;
				LET iBanderaDiaInhabil =1;
			ELIF  WEEKDAY(dtFechaMesiversario) = 6 THEN
				LET dtFechaMesiversarioAux =dtFechaMesiversario - 1 UNITS DAY;
				LET iBanderaDiaInhabil =1;
			ELSE 
				LET iBanderaDiaInhabil =0;
			END IF

          IF dtFechaHoyAux = dtFechaMesiversario AND iBanderaDiaInhabil =0   THEN
                LET cIdProc2 = "F";
				--se obtiene la fecha de la proxima cuota.--se corrige fecha de envio
				EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',dtFechaMesiversario,cNumCredito)
				INTO cCodRet,dtFechaProxCuota,iDiaCorte;
			
           END IF;
		   IF  dtFechaHoyAux =  dtFechaMesiversarioAux THEN
                LET cIdProc2 = "F";
				--se obtiene la fecha de la proxima cuota.--se corrige fecha de envio
				EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',dtFechaMesiversario,cNumCredito)
				INTO cCodRet,dtFechaProxCuota,iDiaCorte;
			
           END IF;
	 
	
          -- Validaciones para identificar un (Mesiversario)
          IF dtFechaHoy = dtFechaMesiversario THEN
             LET cIdProc3 = "M";
              EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',dtFechaHoy,cNumCredito)
				INTO cCodRet,dtFechaProxCuota,iDiaCorte;
          END IF;

-- *******************************************************
--  Calculo de Iva de Interes                            *
-- *******************************************************
 SELECT a.iva, a.plaza
   INTO dIvaSuc, cPlaza
   FROM tmp_sucursales_adn a
  WHERE empresa  = cEmpresa
    AND sucursal = cSucursal;

-- *******************************************************
-- FACTURACION                                           *
-- *******************************************************

--FMV 31-ENE-11
IF cIdProc2 = "F" AND (dSdoCapital + dCapTrasNoVen) > 0 THEN
        LET iNumPago = iNumPago + 1 ; 
        
		--IF (dSdoCapital + dCapTrasNoVen - (dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal)) <= 0  and (dSdoCapital + dCapTrasNoVen) > 0 THEN
		
		LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen;
		--	LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + dProvInt + dProvIva + dIntProvFinMes + dIvaProvFinMes;
			/*UPDATE "informix".sd_amortiza_credito
			   SET capital_mto_cuota   = dCapMtoCuota
			 WHERE empresa             = cEmpresa
			   AND num_credito         = cNumCredito
			   AND capital_status      = "3";*/
		--END IF;
		
        LET dMontofinanciado = dSdoCapital ;

        IF cIdProc2 = "F" THEN LET dIntProvFinMes=0; LET dIvaProvFinMes=0; END IF;

		/*UPDATE "informix".sd_amortiza_credito
		   SET capital_mto_cuota   = dMontofinanciado,
			   capital_debe        = dMontofinanciado,
			   capital_status      = "1",
			   capital_status_ant  = "3"
			   --,fecha_cuota         = dtFechaMesiversario -- IFSR prod
		 WHERE empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "3";*/


		/*select  capital_debe
		  into vlCapitalDebe
		  from "informix".sd_amortiza_credito
		 WHERE empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "1";*/
		   LET vlCapitalDebe = dMontofinanciado;

		if vlCapitalDebe is null then let vlCapitalDebe = 0; end if;

		--IF (dSdoCapital + dCapTrasNoVen - vlCapitalDebe) > 0 THEN
	  -- IF (dSdoCapital - dCapMtoCuota) >  0 THEN
			   
			   --IF NOT EXISTS (SELECT num_credito FROM  "informix".sd_amortiza_credito
							--WHERE empresa = cEmpresa and num_credito = cNumCredito and fecha_cuota =dtFechaProxCuota) THEN --IFSR prod
							--WHERE empresa = cEmpresa and num_credito = cNumCredito and fecha_cuota =dtFechaMesiversario) THEN -- IFSR NUEVA
			   INSERT INTO "informix".sd_amortiza_credito
						(
							empresa, 		    num_credito, 		fecha_cuota, 		tipo_cuota,
							capital_mto_cuota, 	capital_debe,		capital_pagado, 	capital_status,
							capital_status_ant, capital_fecha_pago,	interes_debe, 		interes_pagado,
							interes_status, 	interes_status_ant,	interes_fecha_pago, iva_debe,
							iva_pagado, 		iva_status,			iva_status_ant, 	iva_fecha_pago,
							mora_provi_ordi, 	mora_provi_cope,	mora_sdo_ordi, 		mora_sdo_ordi_pag,
							mora_sdo_cope, 		mora_sdo_cope_pag,	mora_bonificado, 	mora_status,
							mora_iva_debe, 		mora_iva_pagado,	mora_iva_status, 	mora_iva_fecha_pago,
							num_pago, 		    campo_trabajo1,		campo_trabajo2, 	campo_trabajo3,
							campo_trabajo4
						)
					VALUES
						--(   cEmpresa,		    cNumCredito,	dtFechaProxCuota,	"3", --IFSR prod - fecha cuota futura
						(   cEmpresa,		    cNumCredito,	dtFechaMesiversario,	"3",-- IFSR NUEVA - fecha cuota a cubir
							--NVL(dCapMtoCuota,0),  0,				0,			        "3", --IFRS prod - capital status en 3 - fecha cuota futura
							NVL(dCapMtoCuota,0),	NVL(dCapMtoCuota,0),			0,			        "1", --IFRS - capital status en 1 - fecha cuota a cubrir
							"3",         		"",				0,			         0,
							"1",                "1",			NULL,			     0,
							0,			        "1",			"1",                 "",
							0,			         0,				0,			         0,
							0,			         0,				0,			         "1",
							0,			          0,			"1",			     "",
							NVL(iNumPago,0),		      0,			0,			         "",
							""
						);
				--END IF;
	   --END IF;
END IF;

-- *******************************************************
-- TRASPASOS                                             *
-- *******************************************************
    -- Traspaso de Vigente a Vencido Transitorio.
		IF  cIdProc3 = "M" AND dSdoCapital > 0  THEN

               SELECT NVL(a.capital_debe - a.capital_pagado,0) --,NVL(a.interes_debe - a.interes_pagado,0)
                 INTO dTraspCap --,dTraspInt
                 FROM "informix".sd_amortiza_credito a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status = "1";

					IF dTraspCap IS NULL THEN LET dTraspCap=0; END IF;
					
				IF (dTraspCap > 0) THEN
               
					LET dMntVencido = dMntVencido + dSdoCapital;
					LET dSdoCapital = 0;

					UPDATE "informix".sd_amortiza_credito
					   SET capital_status = "7",
						   capital_status_ant  = "1",
						   campo_trabajo3 = ''
					 WHERE empresa        = cEmpresa
					   AND num_credito    = cNumCredito
					   AND capital_status = "1";

					--Se actualiza la fecha de vencimiento
					UPDATE "informix".sd_maecredanexo
					SET fecha_vencto  = dtFechaHoy
					 WHERE num_credito    = cNumCredito
					AND empresa        = cEmpresa;

					--FMV 25Abr13: Actualiza indicador del 1er. vencido y dias de atraso
					UPDATE "informix".sd_indicador_cred
					SET fecha_vencido =  DECODE (nvl(fecha_vencido,date(1)) ,date(1), dtFechaHoy, fecha_vencido)
					 WHERE num_credito   = cNumCredito
					AND empresa       = cEmpresa;

					 -- Traspaso capital vigente a transitorio.	 
					CALL genmovcierre_movdia(cEmpresa, cNumCredito, cNumCredito,7110, "602", dtFechaHoy, dMntVencido, cFolio, cSucursal, cDivisa, "",cPlaza) RETURNING   cCodRet,cMensajeRet;
							
					IF (cCodRet <> "00000") THEN
						ROLLBACK WORK;	
					END IF;
				END IF;

        END IF;

			--IF cIdProc3 = "M" AND cStatusCred='BT' THEN
			IF cStatusCred IN ('E1') and iDiasAtraso >= 30 AND dMntVencido > 0 THEN
				
                UPDATE "informix".sd_amortiza_credito
				   SET capital_status = "6",
						capital_status_ant  = capital_status
                 WHERE empresa        = cEmpresa
                   AND num_credito    = cNumCredito
                   AND capital_status = "7";

				 
					  CALL genmovcierre_movdia(cEmpresa, cNumCredito, cNumProducto,7111, "600", dtFechaHoy, dMntVencido,
                                 cFolio, cSucursal, cDivisa, "",cPlaza) RETURNING  cCodRet,cMensajeRet;
                        IF (cCodRet <> "00000") THEN
                            ROLLBACK WORK;                           
                        END IF;

					LET cStatusCred = "E3";

					UPDATE "informix".sd_maecred
					   SET status_cred = cStatusCred
					 WHERE num_credito = cNumCredito
					   AND empresa     = cEmpresa;

			END IF; --IF cIdProc3 = "M" AND cStatusCred='BT' THEN

	-- Bloque para actualizar el act cuando haya vencido
	IF  cIdProc3 = "M" AND dMntVencido > 0  THEN
		Let iAct = iAct + 1;
	END IF;
	
	IF  cIdProc3 = "M" THEN
		UPDATE "informix".sd_maecredanexo
                   SET prox_fecha_pago = dtFechaProxCuota,
                       dia_corte       = iDiaCorte
                  WHERE num_credito     = cNumCredito
                    AND empresa         = cEmpresa;
	END IF;

-- *******************************************************
-- CALCULO DE INTERES MORATORIO                          *
-- *******************************************************

	SELECT COUNT(*)
		 INTO iNumVdos
		 FROM "informix".sd_amortiza_credito a
		WHERE a.empresa        = cEmpresa
		  AND a.num_credito    = cNumCredito
		  AND a.capital_status IN ("7","6");

    UPDATE sd_maesdos
    SET fecha_ult_mov = dtFechaHoy,
        sdo_no_exig = 0,
        sdo_dia_ant_cap = sdo_cap_insoluto,
        sdo_capital = dSdoCapital,
        sdo_cap_insoluto = dSdoCapInso,  
        dias_acum_cap = (dias_acum_cap + iDiasInt),
		mto_reser_int = monto_reservado, -- RQM 09 704 SALDO DIA ANTERIOR 
		monto_reservado = dMontofinanciado, -- RQM 09 704 SALDO AL DIA		
        monto_vencido = dMntVencido,
        mto_venc_trasp = dMntVencTras,
        monto_financiado = dMontofinanciado,
        cap_tras_no_venci = dCapTrasNoVen,
        mto_fin_ven_trasp = iNumVdos,
		act = iAct
    WHERE  num_credito = cNumCredito;

-- *******************************************************
-- RESPALDO DE INFORMACION CONTABILIDAD A FIN DE MES     *
-- *******************************************************

     IF cIdProc1 = "C" THEN

           INSERT INTO "informix".sd_maesdoscont
                SELECT dtFechaHoy, *
                  FROM informix.sd_maesdos
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

           INSERT INTO "informix".sd_maecredcont
                SELECT dtFechaHoy, empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,
							status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,
							cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,
							codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,
							bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,
							tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
                  FROM informix.sd_maecred
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

             LET iContCierre = iContCierre + 1;

     END IF;
-- *******************************************************
-- GENERAR HISTORICO DE SALDOS                           *
-- *******************************************************
    IF cIdProc3 = "M" OR cIdProc2 = "F" THEN
        INSERT INTO "informix".sd_maesdoshist
             SELECT dtFechaHoy, *, 0.0
               FROM informix.sd_maesdos
              WHERE num_credito = cNumCredito
                AND empresa     = cEmpresa;

            LET iContCorte = iContCorte + 1;

    END IF;

-- ***********************************
-- GUARDA SALDOS FIN DE DIA          *
-- ***********************************
       
-- RQM 07 085 calificacion credisoluciones
    CALL sp_actsdodiario(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
									0, 0,
									0,
									0,0,0 ,dMontofinanciado,dtFechaHoy,cStatusCred,dtFechaVencto,iAct)
     RETURNING cCodRet;

        IF (cCodRet <> "000") THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "Error al grabar en tabla saldos diarios";
             RETURN cCodRet, cMensajeRet;
        END IF;

-- *******************************************************
-- FIN DEL PROCESO                                       *
-- *******************************************************
            --FMV 25abr13: Calcula indicadores para los prestamos por sus dias de atraso en vencidos
            --FMV 17jun13: Ajuste para prestamos q vencen a fin de mes y cambio de estatus vigente
		IF (dtFechaHoy = dtFechaFinMes)  THEN

			 UPDATE "informix".sd_indicador_cred
				SET dias_atraso   = iDiasAtraso,
					fecha_ultimo_pago = vf_fecha_ult_pago,
					fecha_ultimo_pago_h = vf_fecha_ult_pago
			  WHERE empresa = cEmpresa
				AND num_credito = cNumCredito;
		END IF; --IF cIdProc1 = "C"


		/*IF dtFechaHoy=mdy(12,31,2021) THEN

			--LET dtFechaHoy = mdy(08,31,2021);
			EXECUTE PROCEDURE "informix".sp_ambientar_indicador_7800(dtFechaHoy,cNumCredito)
			--EXECUTE PROCEDURE "informix".sp_ambientar_indicador_7800(mdy(11,30,2021),cNumCredito)
				INTO cCodRet, cMensajeRet;

			IF  cCodRet <> "000" THEN
				RETURN cCodRet,cMensajeRet;				 
			END IF;

		END IF;*/

        COMMIT WORK;
        LET cBegin = "N";
		
	END IF;

 		   
END FOREACH;

   LET cCodRet = "000";   LET cMensajeRet = "PROCESO CONCLUIDO";

    UPDATE "informix".sd_contproc
       SET status_proc = "F", hora_fin    = CURRENT,
           cod_ret = cCodRet, 	mensaje  = cMensajeRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierreAdn"
       AND fecha       = dtFechaHoy;

    UPDATE bdinteg:sx_contproc
       SET status_proc = "F", hora_fin = CURRENT,
           codret      = cCodRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierreAdn"
       AND fecha       = dtFechaHoy;

	   IF cBanTemp = 'S' THEN
	       DROP TABLE tmp_sucursales_adn;
	       LET cBanTemp ='N';
	   END IF;
    
 RETURN cCodRet,cMensajeRet;

END;
END PROCEDURE;