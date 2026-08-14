CREATE PROCEDURE "informix".sp_consulta_pre_aprobado_listanegra(pNumCte CHAR(9),gen1 CHAR(20), gen2 CHAR(20))
RETURNING   CHAR (5) AS codRet,
            CHAR(40) AS mensaje;

	
	--VALORES DE RETORNO
	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR (5);
    DEFINE vMensaje CHAR (40);

	--VARIABLES PARA DATOS
	DEFINE vCod_error CHAR (10);
	DEFINE vNombre_comp CHAR (100);
	DEFINE vNum_cte CHAR(9);
	DEFINE vRfc CHAR(13);
	DEFINE vfechaNac DATE;
    DEFINE vNombre1 CHAR (30);
	DEFINE vNombre2 CHAR (30);
	DEFINE vApellidoP CHAR (30);
	DEFINE vApellidoM CHAR (30);
    DEFINE vNum_cta CHAR (15);
    DEFINE vNum_tarj CHAR (20);
    DEFINE vTipo CHAR(5);
	
	
	--EXPRECIONES EXTRAS
	DEFINE vE1 CHAR(20);
	DEFINE vE2 CHAR(20);
	DEFINE vSit1 CHAR(5);
	DEFINE vSit2 CHAR(5);
	DEFINE vMen1 CHAR(25);
	DEFINE vResp CHAR(40);

	DEFINE vSucursal CHAR(20);
	DEFINE vUser CHAR(20);
	
	
	
	
	--DEFINICIONES
    LET vCodRet ='00000';
    LET vMensaje ='CONSULTA EXITOSA';
	LET iSqlErr ='0';
	
	--DEFINICIONES
	LET vCod_error = '';
	LET vNombre_comp = '';
	LET vNum_cte = '';
	LET vRfc = '';
	LET vNombre1 = '';
    LET vNombre2 = '';
    LET vApellidoP = '';
    LET vApellidoM = '';
	LET vNum_cta = '';
    LET vNum_tarj = '';
    LET vTipo = '';
	
	--EXPRECIONES EXTRAS
	LET vE1 = '';
	LET vE2 = '';
	LET vSit1 = '';
	LET vSit2 = '';
	LET vMen1 = '';
	LET vResp = '';
	
	LET vSucursal = gen1;
	LET vUser = 'sys_cred';
	--Ejemplo de ejecucion.
	--EXECUTE PROCEDURE bdicred:"informix".sp_consulta_pre_aprobado_listanegra ('005048221','0318','');

   BEGIN
	  ON EXCEPTION SET iSqlErr
	  	IF iSqlErr <> 0 THEN
              LET vCodRet=iSqlErr;
              LET vMensaje='ERROR AL CONSULTAR CLIENTE';
	  		RETURN vCodRet, vMensaje;
	  	END IF;
	  END EXCEPTION;
	  
	  
	  
	  ---VALIDA LA EXISTENCIA DEL CLIENTE EN LA BDINTEG si_cliente y si_ctepf.
	  FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consclientenumcte('001',pNumCte,'','','','','','','','','','',1,0)
	          INTO vCod_error,vNombre_comp,vNum_cte,vRfc,vfechaNac,vNombre1,vNombre2,vApellidoP,vApellidoM,vNum_cta,vNum_tarj,vTipo  
			  LET vNombre_comp = TRIM(vNombre_comp);
	          IF vNombre_comp = '' THEN
	              LET vCodRet='00001';
                  LET vMensaje='CLIENTE NO ENCONTRADO';
	          	RETURN vCodRet, vMensaje;
	          END IF;
	  END FOREACH;
	  
	  
	  --VALIDA LA EXISTENCIA DEL CLIENTE EN LISTA NEGRA, SI REGRESA UN ERROR 00002 EL CLIENTE ESTA EN LA LISTA NEGRA.
	  FOREACH EXECUTE PROCEDURE bdiauditor:"informix".sp_busqueda_cte_listanegra (vNombre1,vNombre2,vApellidoP,vApellidoM,vfechaNac,vSucursal,vUser)
	          INTO vCod_error
			  LET vCod_error = TRIM(vCod_error);
	          IF vCod_error <> '000000' THEN
	              LET vCodRet='00002';
                  LET vMensaje='CLIENTE EN LISTA NEGRA';
	          	RETURN vCodRet, vMensaje;
	          END IF;
	  END FOREACH;
	  
	  /* --VALIDA EL ESTATUS DEL CLIENTE EN LA TABLA DE SITUACIONES ESPECIALES, SU SITUACION Y SU CAUSA.
	  FOREACH EXECUTE PROCEDURE bdisitesp:"informix".sp_consultaclienteseindividual('001',pNumCte,1)
			  INTO vCod_error,vE1,vE2,vSit1,vSit2,vMen1,vfechaNac
			  
			  LET vSit1 = TRIM(vSit1);
			  LET vSit2 = TRIM(vSit2);
			  LET vMen1 = TRIM(vMen1);
			  
			  --VALIDA LA SITUACION DIFERENTE A U65 Y P23.
			  LET vResp = TRIM(vSit1)|| TRIM(vSit2);
			  IF vResp NOT IN ('U65', 'P23', '0')  THEN
	              LET vCodRet = '00003';
				  LET vMensaje = TRIM(vMen1)||' '||TRIM(vSit1)||TRIM(vSit2);
				  RETURN vCodRet, vMensaje;
	          END IF;
	  
	  END FOREACH; */
	  
	  RETURN vCodRet, vMensaje;                                                                            
	
   END;                                                                                         
END PROCEDURE
DOCUMENT
'AUTOR : JORGE MIGUEL REYES REYES',
'DESCRIPCION: SP CONSULTA EL ESTATUS DEL CLIENTE EN LISTA NEGRA Y CASOS ESPECIALES',
'FOLIO: ONECLICK PREAPROBADOS DESARROLLO WEB',
'FECHA : 04/OCT/2022',
'VERSION: 1.2.3',
'BD: bdicred',
'------------------------------------------------------------------------------------',
'AUTOR : Angel De Jesus Anguiano Camacho',
'DESCRIPCION: Se modifica validacion para ofertar situacion especial P23',
'FOLIO: ONECLICK PREAPROBADOS DESARROLLO WEB',
'FECHA : 17/ABR/2024',
'VERSION: 1.2.4',
'BD: bdicred',
'------------------------------------------------------------------------------------',
'AUTOR : Fernando Rodelo Barron',
'DESCRIPCION: Se modifica para quitar la validacion de situacion especial',
'FOLIO : ONECLICK PREAPROBADOS DESARROLLO WEB',
'FECHA : 12/NOV/2024',
'VERSION : 1.2.5',
'BD : bdicred',
'------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_clona_tdc_upgrade_web(pEmpresa CHAR(3),P_EJECUTIVO CHAR(10) , pProducto CHAR(4), pCredito CHAR(20) ,pTarjeta CHAR(20),pTarjetaOro CHAR(20))
RETURNING CHAR(5)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(5);
DEFINE cCodRetTDif	 CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE vCodRet 		 CHAR(5);
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
DEFINE sExistePromo			SMALLINT;

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '00000';
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
--Nueva Solicitud de Crodito Oro
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
LET sExistePromo		= 0;

--SET DEBUG FILE TO '/informix/keevyn/sp_clona_tdcoro.out';
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
		--AAME Se eliminan los datos del nuevo crÃ©dito y se actualizan las tablas al estado anterior
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
  LET cCodRet = '00001';
  LET cMensajeRet = 'El parÃ¡metro no es valido';

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

		IF cCodRetCSG = '000003' THEN -- Numero de crÃ©dito no existe
			LET cCodRet  = '00002';
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
			LET cCodRet  = '00003';
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

			LET cCodRet  = '00004';
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
		 INTO  CstatusSol,cNumcte
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
					--AAME Se eliminan los datos del nuevo crodito y se actualizan las tablas al estado anterior
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

				/* AAME 20160829 RQI 27 122 SE REALIZARoN EN PROCESO NOCTURNO EL CLONADO DE TABLAS
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

			--EJECUCION PARA LIBERAR EL CARGO RETENIDO	MACM RQM 101584 TDC INFINITE
			IF NVL(dcSdoRetenidoCSG,0) >0 THEN

				UPDATE bdicred:sd_maeretenido SET estatus = 'S' WHERE num_credito = pCredito and estatus = 'P';

			END IF

			
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

						IF (LENGTH(TRIM(vCodRet)) == 3) THEN
					      LET cCodRet = '00' || vCodRet;
					    ELSE
							LET cCodRet = vCodRet;
					    END IF;

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

			-- Genera el movimiento por la apertura de la lonea de credito Oro
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
				WHERE num_credito = pCredito and estatus = 'S';
				
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
					LET cCodRet = '00000';
					LET cMensajeRet= "PROCESO EXITOSO";
				end if;
			end foreach;
			
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
			
			IF NVL(sExistePromo, 0) > 0 THEN
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
			LET cCodRet='00007';
			LET cMensajeRet ='La cuenta se encuentra liquidada, por favor verifique';
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
		/*ELIF NVL(sExistePromo, 0) > 0 THEN
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
			LET cCodRet='00006';
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
	-- Actualizacion de credito en bitacora de upgrade cuando se trata de una reposicion de tarjeta personalizada
		UPDATE bdicred:sd_credito_upgrade SET numerotarjeta_upgrade= pTarjetaOro, Resultado='1'
		WHERE numerotarjeta = pTarjeta;
END IF;

IF (LENGTH(TRIM(cCodRet)) == 3) THEN
	LET cCodRet = '00' || cCodRet;
END IF;

RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para liquidar el credito de TDC clasica y crear el credito para TDC ORO que se ejecutaro',
'desde el de Reposicion de Tarjeta',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/02/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultacuenta(pEmpresa CHAR(3), pNumCuenta CHAR(20))

RETURNING CHAR(6)  AS codigo_error,
          CHAR(80) AS mensaje_error, 
          CHAR(3)  AS empresa, 
          CHAR(20) AS num_cuenta, 
          CHAR(20) AS num_cliente,
          CHAR(50) AS nombre_cliente,          
          CHAR(4)  AS sucursal, 
          CHAR(30) AS bloqueo,
          CHAR(50) AS causa,          
          CHAR(2)  AS status, 
          DATE     AS fecha_apertura;

--31/10/2008
--Abraham Ayala Aguilar
--Busca una cuenta para revisar si la cuenta esta bloqueada o no esta bloqueada.

--05/11/2008
--Rodolfo Tortolero Varela
--Se modifico la consulta para obtener la descripciÃ²n del tipo de bloqueo.

--06/11/2008
--Rodolfo Tortolero Varela
--Se agrego una consulta para checar si el campo id_unidad_prod es nulo
--de ser asi su actualiza con un '0'.

--18/11/2008
--Rodolfo Javier Tortolero Varela
--Se modifico el codigo de la consulta.

--08/01/2009
--Roque Enrique Solis CampaÃ±a
--Se quitÃ³ el update al campo d_unidad_prod y los retornos se hicieron de 6 digitos

-- Fecha: 14/01/2009
-- ModificÃ³: Roque Enrique Solis CampaÃ±a
-- Observaciones/Comentario: Se modifica para realizar la consulta
--en base a la fecha de bloqueo y no a la
--fecha de apertura del credito.

--04/05/2009
-- ModificÃ³: Roque Enrique Solis CampaÃ±a
--Se agrego la causa del bloqueo

--DEFINICION DE VARIABLES--
    DEFINE iSqlErr        INTEGER;
    DEFINE iIsamErr       INTEGER;
    DEFINE cErrorInfo     CHAR(80);
    DEFINE cCodRet        CHAR(6);
    DEFINE vCodRet        CHAR(6);
    DEFINE cMensajeRet    CHAR(80);
    DEFINE vNumCte        CHAR(20);
    DEFINE vSucursal      CHAR(4);
    DEFINE vDescripcion   CHAR(30);
    DEFINE vStatusCredito CHAR(2);
    DEFINE vFechaApertura DATE;
    DEFINE vCodSP         CHAR(6);
    DEFINE cCausa         CHAR(50);
    DEFINE vID            INTEGER;
    DEFINE cCodCausa      CHAR(2);
    DEFINE cNombre        CHAR(50);
    DEFINE cCredBitacora  CHAR(20);
    --Set debug file to '/home/e10000315/bloqueo/sp_consultacuentas.out';
    --trace on;
    
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
               IF iSqlErr != 0 THEN
                  LET cCodRet= iSqlErr;
                  LET cMensajeRet= cErrorInfo;
                 RETURN vCodRet, cMensajeRet, pEmpresa, pNumCuenta, vNumCte,cNombre, vSucursal, 
                        vDescripcion, cCausa , vStatusCredito, vFechaApertura; 
               END IF;
       END EXCEPTION;
        
    
--INICIALIZACION DE VARIABLES--
        LET vCodRet        = '999999';    --No existe el cliente
        LET vNumCte        = '';
        LET vSucursal      = '';
        LET vDescripcion   = '';
        LET vStatusCredito = '';
        LET vFechaApertura = DATE(1);
        LET vID            = 0;
        LET cCausa         = '';
        LET cCodCausa      = '';
        LET iIsamErr       = 0;
        LET cErrorInfo     = '';
        LET cCodRet        = '';
        LET cmensajeret    = '';
        LET cNombre        = '';
        LET cCredBitacora  = '';

        
        IF pEmpresa IS NULL AND (pNumCuenta IS NULL OR pNumCuenta ='') THEN
        
            LET vCodRet = '000001';    --Faltan valores
            LET cMensajeRet="Faltan valores para ejecutar el proceso";
        ELSE    
        
            EXECUTE PROCEDURE bdicred:sp_validacredito (pEmpresa, pNumCuenta) INTO vCodSP;
            
            IF vCodSP <> '000000' THEN
               LET vCodRet = '000002';    --Faltan valores
               LET cMensajeRet="La cuenta no es valida";
            ELSE
                 LET vCodRet = '000000';    --Cliente encontrado
                SELECT id_unidad_prod, cod_caract_2 
                  INTO vID, cCodCausa
                  FROM "informix".sd_maecred
                 WHERE empresa = pEmpresa 
                   AND num_credito = pNumCuenta;
                   
                IF (vID IS NULL AND cCodCausa IS NOT NULL)  THEN --OR (vID IS NOT NULL AND cCodCausa IS NULL) THEN
                     LET vCodRet= '000003';
                     LET cMensajeRet= 'CrÃ©dito bloqueado manualmente, favor de verificar'; 
                     
                END IF;
                IF vID IS NOT NULL AND (cCodCausa IS NOT NULL OR cCodCausa IS  NULL) THEN
                   LET vCodRet= '000004';
                   LET cMensajeRet= 'El crÃ©dito ya ha sido bloqueado, no sera posible bloquear nuevamente';
                END IF;
                
                SELECT cuenta
                  INTO cCredBitacora
                  FROM "informix".sd_bitacorabloqueocta
                 WHERE cuenta=pNumCuenta
                   AND cve_bloqueo=vID
                   AND nvl(cve_causa,'')=nvl(cCodCausa,'')
                   AND id=(SELECT max(id)
                             FROM "informix".sd_bitacorabloqueocta
                            WHERE cuenta=pNumCuenta
                              AND cve_bloqueo=vID
                              AND nvl(cve_causa,'')=nvl(cCodCausa,''));
                              
                IF cCredBitacora IS NULL AND vID IS NOT NULL THEN  
                    LET vCodRet = '000006';    --La cuenta ya esta desbloqueada.
                    LET cMensajeRet= 'Credito desbloqueado manualmente, favor de verificar';
                END IF;
                
                SELECT cte.numcte, 
                       CASE WHEN NVL(cte.razon_social,'') ='' THEN TRIM(cte.nombre1) || " " || TRIM(cte.nombre2) || " " || TRIM(cte.apell_paterno) || " " || TRIM(cte.apell_materno) ELSE cte.razon_social END,  
                       cte.sucursal, 
                       blo.descripcion,  
                       mae.status_cred, 
                       btc.fecha, 
                       ca.causa_bloq 
                  INTO vNumCte,cNombre, vSucursal, vDescripcion, vStatusCredito, vFechaApertura, cCausa
                  FROM bdicred:sd_maecred mae 
                  LEFT OUTER JOIN bdinteg:si_cliente cte ON (mae.numcte = cte.numcte)
                  LEFT OUTER JOIN bdicred:sd_bloqueoscuenta  blo ON  (mae.id_unidad_prod = blo.clave)
                  LEFT OUTER JOIN bdicred:sd_bitacorabloqueocta btc ON (mae.num_credito= btc.cuenta AND btc.id=(SELECT MAX(b.id) 
                                                                                                                   FROM sd_bitacorabloqueocta b 
                                                                                                                   WHERE b.cuenta=mae.num_credito))
                  LEFT OUTER JOIN bdicred:sd_causa_bloqueo ca ON (ca.cod_causa =mae.cod_caract_2 AND mae.empresa=ca.empresa)
                 WHERE mae.empresa = pEmpresa 
                   AND mae.num_credito = pNumCuenta;                 
                                
            
                IF vNumCte IS NULL THEN
                    let vNumCte = '';
                END IF;

                IF vSucursal IS NULL THEN
                    let vSucursal = '';
                END IF;

                IF vDescripcion IS NULL AND vID IS NOT NULL THEN
                    let vDescripcion = 'Tipo de bloqueo desconocido';
                ELIF vDescripcion IS NULL AND vID IS NULL THEN
                    let vDescripcion = 'No tiene bloqueo';
                END IF
                
                IF cCausa IS NULL AND cCodCausa IS NOT NULL THEN
                   LET cCausa='Motivo de restricciÃ³n desconocido'; --
                ELIF cCausa IS NULL AND cCodCausa IS NULL THEN
                    LET cCausa='No tiene motivo de restricciÃ³n'; 
                END IF;
                
                IF vStatusCredito IS NULL THEN
                    let vStatusCredito = '';
                END IF;

                IF vFechaApertura IS NULL THEN
                    let vFechaApertura = DATE(1);
                END IF;
                
                IF vStatusCredito='CV'    THEN
                    LET vCodRet='000002';
                    LET cMensajeRet = 'CrÃ©dito en cartera vendida';
                    RETURN vCodRet, cMensajeRet, pEmpresa, pNumCuenta, vNumCte,cNombre, vSucursal, 
                           vDescripcion, cCausa , vStatusCredito, vFechaApertura; 
                END IF;
                
                
            END IF;        END IF;        
        RETURN vCodRet, cMensajeRet, pEmpresa, pNumCuenta, vNumCte,cNombre, vSucursal, 
               vDescripcion, cCausa , vStatusCredito, vFechaApertura; 
    END;
END PROCEDURE;