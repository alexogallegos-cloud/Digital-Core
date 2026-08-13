CREATE PROCEDURE "informix".sp_cobrocomisionreposicioncredito ( pEmpresa CHAR(3), pCredito CHAR(20),pMotivo CHAR(2), pTipoProd CHAR(4))	
--DATOS A REGRESAR
	RETURNING 
	CHAR(5) AS cCodRet; -- Codigo de Retorno	
	
--============= DEFINIR VARIABLES =============	
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCodRetAux   CHAR(6);
DEFINE ccod_ret CHAR(5);
DEFINE cNumtarjeta CHAR(20);
DEFINE cNumeroFolio CHAR(16);
DEFINE cTransacc CHAR(4);
DEFINE cSucursal CHAR(4);
DEFINE cOperador CHAR(10);
DEFINE mMontoCom MONEY(16,2);
DEFINE cResultado CHAR(1);
DEFINE cEstatusCred CHAR(2);
DEFINE iIdUnidadProd INTEGER;

--============= INICIALIZAR VARIABLES ===========	
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCodRetAux         = "000000";
LET ccod_ret     = "00000";
LET cNumtarjeta = "";
LET cNumeroFolio = "";
LET cTransacc = "";
LET cSucursal = "9290";
LET cOperador = "informix";
LET mMontoCom = 0.00;
LET cResultado = '';
LET cEstatusCred = '';
LET iIdUnidadProd = 0;
-----------------------------------------------------
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/respaldosbd/Bryan/sp_cobrocomisionreposicioncredito.out";
	--TRACE ON;
						  
	-- Verificar que el cobro de la comision no se haya realizado
	SELECT 	resultado
	INTO 	cResultado
	FROM 	bdicred:"informix".sd_cobro_comision
	WHERE 	empresa = pEmpresa AND num_credito = pCredito AND motivo = pMotivo AND resultado = '0';
	
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN
		-- Cobro no realizado
		--SE GENERA EL FOLIO
		CALL bdicheq:"informix".sp_generafolionomina('informix') 
		RETURNING cCodRetAux, cNumeroFolio;
		
		IF pMotivo = '01' THEN
			LET cTransacc = '6218';
			
			SELECT 	a.monto
			INTO 	mMontoCom
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_rob AND a.empresa = b.empresa AND  num_producto = pTipoProd 
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '02' THEN
			LET cTransacc = '6219';
			
			SELECT 	a.monto
			INTO 	mMontoCom
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_ext AND a.empresa = b.empresa AND num_producto = pTipoProd
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '03' THEN
			LET cTransacc = '6220';
			
			SELECT 	a.monto
			INTO 	mMontoCom
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_danmal AND a.empresa = b.empresa AND num_producto = pTipoProd
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '04' THEN
			LET cTransacc = '6221';
			
			SELECT 	a.monto
			INTO 	mMontoCom  
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_acl AND a.empresa = b.empresa AND num_producto = pTipoProd
			AND 	a.empresa = pEmpresa;			
		ELIF pMotivo = '05' THEN
			LET cTransacc = '6212';
			
			SELECT 	a.monto
			INTO 	mMontoCom
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_ven AND a.empresa = b.empresa AND num_producto = pTipoProd
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '06' THEN
			LET cTransacc = '6220';
			
			SELECT 	a.monto
			INTO 	mMontoCom  
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_pet AND a.empresa = b.empresa AND num_producto = pTipoProd
			AND 	a.empresa = pEmpresa;
		END IF;
		
		-- Validar el crÃ©dito
		SELECT	status_cred, id_unidad_prod
        INTO 	cEstatusCred, iIdUnidadProd
        FROM 	bdicred:"informix".sd_maecred
        WHERE 	empresa = pEmpresa AND num_credito = pCredito;
		
		IF mMontoCom > 0 AND cEstatusCred IN(select status_cred from bdicred:sd_tipocartera where descripcion not like '%REVOCADA%' and descripcion not like '%VENCIDA%' and descripcion not like '%CANCELADA%') AND NVL(iIdUnidadProd,0) NOT IN (3,4) THEN
			--Si es credito se ejecuta el siguiente procedimiento 
			EXECUTE Procedure bdicred:"informix".cargo_cred (pEmpresa,pCredito,cSucursal,cOperador,cTransacc,mMontoCom ,cNumeroFolio,cNumtarjeta,0,0,TODAY,'Comision por reposicion de tarjeta','Cargo por Cobro No aplicado','')	
			INTO ccod_ret;

			IF ccod_ret <> 0 THEN
				-- Ocurrio un Error al intentar aplicar la comision
				LET cCodRet = '00001';
			END IF;		
			
		ELIF cEstatusCred NOT IN(select status_cred from bdicred:sd_tipocartera where descripcion not like '%REVOCADA%' and descripcion not like '%VENCIDA%' and descripcion not like '%CANCELADA%') THEN										
			-- "La Cuenta del Cliente tiene un Estatus de CrÃ©dito Vencido"				
			LET cCodRet = '00002';				
		ELIF iIdUnidadProd IN (3,4) THEN
			--"La Cuenta del Cliente Ãsta Bloqueada Para la DisposiciÃ³n de Saldo"									
			LET cCodRet = '00003';				
		ELSE 
			--AAME 20190724 Se agrega condicion para que no muestre error cuando el monto comision sea 0.
			IF mMontoCom > 0 THEN			
				--"Ocurrio un Error al intentar aplicar la comision"								
				LET cCodRet = '00004';	
			END IF;
		END IF;	
	ELSE
		-- El cobrÃ³ ya se ha realizadÃ³
		LET cCodRet = '00005';	
	END IF;

	RETURN cCodRet;
END
END PROCEDURE

DOCUMENT
'Folio: 226 - RQM 10 810 Solicitud de Tarjetas Adicionales Tarjeta de Credito.',
'Autor: 93034687 - Bryan Limon',
'BD: bdicred',
'Solicita:	Abraham Narvaez',
'Fecha: 15/11/2017',
'Descripcion: Se sobrecargara el procedimiento sp_cobrocomisionreposicioncredito para que ahora tome en cuenta el motivo, el credito y producto';

CREATE PROCEDURE "informix".sp_principal_rr(pempresa  char(3), pNumCredito  char(20),p_TpPago smallint,
                                            p_Monto DECIMAL(18,2), p_Usuario char(8), p_Sucursal char(4),
                                            p_Folio LIKE sd_movdia.Folio_Suc, p_Transacc CHAR(4))
RETURNING  CHAR(5)        AS cod_ret,
           CHAR(125)      AS mens_ret,
           DECIMAL(18,2)  AS sdo_ant,
           DECIMAL(18,2)  AS comision,
           DECIMAL(18,2)  AS iva_com,
           DECIMAL(18,2)  AS int_mora,
           DECIMAL(18,2)  AS iva_int_mora,
           DECIMAL(18,2)  AS int_vdo,
           DECIMAL(18,2)  AS iva_int_vdo,
           DECIMAL(18,2)  AS int_ordi,
           DECIMAL(18,2)  AS iva_int_ordi,
           DECIMAL(18,2)  AS capital,
           DECIMAL(18,2)  AS monto_pago,
           CHAR(20)       AS cuenta_eje,
           DECIMAL(18,2)  AS sdo_act,
           DECIMAL(18,2)  AS pago_min,
           CHAR(17)       AS fecha_limite_pago;

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(80);
DEFINE cCodRet                       CHAR(5);
DEFINE cCodRetAux                    CHAR(6);
DEFINE cMensajeRet                   CHAR(125);

DEFINE wBegin                        CHAR(1);

DEFINE iIntAux                       INTEGER;
DEFINE cCharAux                      CHAR(80);
DEFINE dDecAux                       DECIMAL(18,2);
DEFINE dtDateAux                     DATE;

---
DEFINE dSdoAdeudTotal                DECIMAL(18,2);
DEFINE dSdoAdeudTotalAct             DECIMAL(18,2);
DEFINE dPagoMinimo                   DECIMAL(18,2);
DEFINE dPagoCom                      DECIMAL(18,2);
DEFINE dPagoIvaCom                   DECIMAL(18,2);
DEFINE dIntMora                      DECIMAL(18,2);
DEFINE dIvaIntMora                   DECIMAL(18,2);
DEFINE dIntVdo                       DECIMAL(18,2);
DEFINE dIvaIntVdo                    DECIMAL(18,2);
--DEFINE dIntVig                       DECIMAL(18,2);
--DEFINE dIvaIntVig                    DECIMAL(18,2);
--DEFINE dIntDev                       DECIMAL(18,2);
--DEFINE dIvaIntDev                    DECIMAL(18,2);
DEFINE dPagoInt                      DECIMAL(18,2);
DEFINE dPagoIvaInt                   DECIMAL(18,2);
DEFINE dPagoCapital                  DECIMAL(18,2);
DEFINE dPagoCapitalM                 DECIMAL(18,2);
DEFINE dMontoPago                    DECIMAL(18,2);
DEFINE dMontoVencido                 DECIMAL(18,2);
DEFINE dCuentaCap                    CHAR(20);
DEFINE dPagoMinAct                   DECIMAL(18,2);
DEFINE cFechaLimite                  CHAR(17);
DEFINE dtFechaApertura               DATE;
--DEFINE dtFechaCompa                  DATE;
--DEFINE dTasaInt                      DECIMAL(9,6);
--DEFINE dtIvaFechaPag                 DATE;
DEFINE dCuentamens                   INTEGER;
DEFINE dFechaCuota                   DATE;
DEFINE dCapitalStatus                CHAR(1);
DEFINE dIntMoraOrdi                  DECIMAL(18,2);
DEFINE dIntMoraCope                  DECIMAL(18,2);
DEFINE dIvaMoraDebe                  DECIMAL(18,2);
DEFINE dIntDebe                      DECIMAL(18,2);
DEFINE dIvaIntDebe                   DECIMAL(18,2);
DEFINE dCapitalDebe                  DECIMAL(18,2);
DEFINE dPagoMoraCope                 DECIMAL(18,2);
DEFINE dPagoMoraOrdi                 DECIMAL(18,2);
DEFINE dPagoIvaMora                  DECIMAL(18,2);
DEFINE dSdoCapInsolutoPP             DECIMAL(18,2);
--DEFINE dSdoVdo                       DECIMAL(18,2);
DEFINE dSdoTrasp                     DECIMAL(18,2);
DEFINE dIntTrasp                     DECIMAL(18,2);
DEFINE dIvaTrasp                     DECIMAL(18,2);
DEFINE dProvIntFinMes                DECIMAL(18,2);
DEFINE dProvIvaFinMes                DECIMAL(18,2);
DEFINE dtFechaProxPago               DATE;
DEFINE dIvaSuc                       DECIMAL(5,3);
DEFINE iPagoSosten                   INTEGER;   --> FMV: Pago Sostenido
DEFINE dFechaVenci                   DATE;
DEFINE ATR_Cred    INTEGER;
DEFINE ATR_Cred_aux    INTEGER;
DEFINE Mto_fin_venc_trasp    INTEGER;

----------------------- Datos General ------------------------------------------------------

DEFINE GLOBAL g_Remanente_pago       DECIMAL(18,2)  DEFAULT 0;

DEFINE GLOBAL g_Empresa              CHAR(3)        DEFAULT "001";
DEFINE GLOBAL g_NumCred              CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_NumProd              CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_CodFun               CHAR(3)        DEFAULT "";
DEFINE GLOBAL g_dtFechaHoy           DATE           DEFAULT "";
DEFINE GLOBAL g_Folio                CHAR(16)       DEFAULT "";
DEFINE GLOBAL g_Sucursal             CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_Divisa               CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_TransaccSuc          CHAR(4)        DEFAULT "0000";
DEFINE GLOBAL g_NumPago              CHAR(40)       DEFAULT "";
DEFINE GLOBAL dStatusCred            CHAR(2)        DEFAULT "";

----------------------- Cobro automatico -------------------------------------------

DEFINE GLOBAL g_StatusCred           CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_montofinanciado      MONEY(14,2)    DEFAULT 0;
DEFINE GLOBAL g_FechaApertura        DATE           DEFAULT "";
DEFINE GLOBAL g_FechaProxPago        DATE           DEFAULT "";
DEFINE GLOBAL g_MontoVencido         MONEY(14,2)    DEFAULT 0;
DEFINE GLOBAL g_SdoTrasp             DECIMAL(18,2)  DEFAULT 0;
DEFINE GLOBAL g_IvaSuc               DECIMAL(5,3)   DEFAULT 0;
DEFINE GLOBAL g_Cuentamens           INTEGER        DEFAULT 0;
DEFINE GLOBAL g_ProvIntFinMes        DECIMAL(18,2)  DEFAULT 0;
DEFINE GLOBAL g_ProvIvaFinMes        DECIMAL(18,2)  DEFAULT 0;

----------------------- Cargo a cuenta ---------------------------------------------

DEFINE GLOBAL g_StatusCtaCap         CHAR(1)        DEFAULT "";
DEFINE GLOBAL g_TranCargo            CHAR(4)        DEFAULT "0227";
DEFINE GLOBAL g_TranSuc              CHAR(4)        DEFAULT "0000";
DEFINE GLOBAL g_cheque               INTEGER        DEFAULT 0;
DEFINE GLOBAL g_Leyenda              CHAR(40)       DEFAULT "CRG. CTA. ";
DEFINE GLOBAL g_Autoriza             CHAR(8)        DEFAULT "";
--DEFINE GLOBAL g_RetLog               CHAR(6)        DEFAULT ""; --??? cas
--DEFINE GLOBAL g_MensLog              VARCHAR(125,1) DEFAULT ""; --??? cas

DEFINE GLOBAL g_Cuenta               CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_NumTarjDeb           CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_SdoCta               DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_TranRet              CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_FechaCargo           DATE           DEFAULT "";
DEFINE GLOBAL g_SdoDisp              DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_MtoRet               DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL gRespaldoActivo        CHAR(1) DEFAULT "0";
DEFINE cNomProd    		             CHAR(40);
DEFINE cConceptoPag                  CHAR(50);
DEFINE aux_vencidos                  INT;
DEFINE dFechaMaxAmort                DATE;
DEFINE dDiasMaxAmort                 INT;
DEFINE dMonto_Vdo                    DECIMAL(14,2);
--- SDFM Se agrega variable para creditos bloqueados
DEFINE vcodigo_bloq CHAR (2);
DEFINE cCodRetMarc	      CHAR(6);
DEFINE cMensajeRetMarc	  CHAR(80);
DEFINE cNumCte	  CHAR(20);

DEFINE dSaldo_vencido      DECIMAL(18,2); ---EVAL OBJETIVA
DEFINE dIntVdo_2           DECIMAL(18,2);
DEFINE dIvaIntVdo_2        DECIMAL(18,2);

DEFINE bandera_int_orden	INT;
DEFINE GLOBAL gprocesa 		INT        DEFAULT 0; --- llamado de principal suc rr para quitas
DEFINE dBanderaIFRS        CHAR(1);
DEFINE GLOBAL g_TranCapt			 CHAR(4)		DEFAULT "";		

--------------------------------------------------------------------------------------------

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      SET DEBUG FILE TO "sp_principal_rr.err";
       IF iSqlErr != 0 THEN
          LET cCodRet     = iSqlErr;
          LET cMensajeRet = cErrorInfo;
       END IF;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
        NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
        NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

   LET wBegin = "N";
   BEGIN WORK;

LET  g_Cuenta              = "";
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "00000";
LET cMensajeRet           = "Se realizÃ³ el pago correctamente";
LET cCodRetAux            = "000000";
LET dFechaCuota          = DATE(1);
LET dtFechaProxPago       = DATE(1);
LET g_Remanente_pago      = 0;
LET iIntAux               = 0;
LET cCharAux              = "";
LET dDecAux               = 0;
LET dtDateAux             = DATE(1);
---
LET dMontoPago            = p_Monto;
LET dSdoAdeudTotal        = 0;
LET dSdoAdeudTotalAct     = 0;
LET dPagoMinimo           = 0;
LET dPagoCom              = 0;
LET dPagoIvaCom           = 0;
LET dIntMora              = 0;
LET dIvaIntMora           = 0;
LET dIntVdo               = 0;
LET dIvaIntVdo            = 0;
LET dPagoInt              = 0;
LET dPagoIvaInt           = 0;
LET dPagoCapital          = 0;
LET dPagoCapitalM         = 0;
LET dCuentaCap            = "";
LET dPagoMinAct           = 0;
LET cFechaLimite          = "";
LET dtFechaApertura       = DATE(1);
LET dProvIntFinMes        = 0;
LET dProvIvaFinMes        = 0;
--LET dtFechaCompa          = DATE(1);
--LET dIntVig               = 0;
--LET dIvaIntVig            = 0;
--LET dTasaInt              = 0;
--LET dtIvaFechaPag         = DATE(1);
LET dCuentamens           = 0;
LET dSdoTrasp             = 0;
LET dIntTrasp             = 0;
LET dIvaTrasp             = 0;
LET dMontoVencido         = 0;
LET iPagoSosten           = 0;
LET aux_vencidos     	  = 0;
LET dFechaMaxAmort        = DATE(1);
LET dDiasMaxAmort         = 0;
LET dMonto_Vdo            = 0;

LET dFechaCuota                   = DATE(1);
LET dCapitalStatus                = "";
LET dIntMoraOrdi                  = 0;
LET dIntMoraCope                  = 0;
LET dIvaMoraDebe                  = 0;
LET dIntDebe                      = 0;
LET dIvaIntDebe                   = 0;
LET dCapitalDebe                  = 0;
LET dPagoMoraCope                 = 0;
LET dPagoMoraOrdi                 = 0;
LET dPagoIvaMora                  = 0;
LET dStatusCred                   = "";
LET dSdoCapInsolutoPP             = 0;
LET dtFechaProxPago               = DATE(1);
LET dIvaSuc                       = 0;
LET dFechaVenci                  = DATE(1);

LET g_TranCapt			  = "";						
LET g_TranCargo         = "0227";  --FMV 3nov11 Se ajusta la transaccion de cargo para cheques
LET g_TranSuc           = "0000";
LET g_cheque            = 0;
LET g_Leyenda           = "CRG. CTA. ";
LET g_Autoriza          = "";
LET cNomProd    		= "";
LET cConceptoPag        = "";

--- SDFM Se agrega variable para creditos bloqueados
LET vcodigo_bloq = '';
LET cCodRetMarc	        = "";
LET cMensajeRetMarc	   = "";
LET cNumCte	   = "";

LET ATR_Cred  =0;
LET ATR_Cred_aux  =0;
LET Mto_fin_venc_trasp = 0;

let dSaldo_vencido = 0;

LET bandera_int_orden		= 0;

LET dBanderaIFRS           = '';

-- Modifico: Paul Ivan Quintero Varela
-- Fecha: 2010/01/20
-- Comentario: Se agrega validacion al realizar el cobro
--             de capital vigente y vencido
-- Modifica: Paul Ivan Quintero Varela
-- Fecha: 26/02/2010
-- Comentario:  Se modifica con la finalidad de reorganizar los codigos de retorno
-- Modifica: Cristina Acosta Sotelo
-- Fecha: 18/05/2010
-- Comentario:
-- Si el p_TpPago ------> 1 entonces es un pago en ventanilla
-- Si el p_TpPago ------> 2 entonces es un cobro automatico
-- Se modifica para que aplique rollback al pago (maneje correctamente las transacciones)

-- Modifico:Jesus Manuel Aguilar Heredia
-- Fecha: 12-05-2011
-- Comentario: se realiza modificacion para contemplar nuevas transacciones de pago desde sucursal, y se actualizan los codigos de retonos, y se agrega variable globar para identificar si es necesario realizar un respaldo

-- Modifica: Paul Ivan Quintero Varela
-- Fecha: 22/07/2011
-- Comentarios: se modifica la decalaracion de la variable g_montofinanciado y g_MontoVencido de DECIMAL(18,2) A MONEY(14,2) 
-- para eviar asi el problema con el uso de las globales.

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


    IF pempresa = "" OR pempresa IS NULL THEN LET g_Empresa='001'; ELSE LET g_Empresa=pempresa; END IF;
    IF p_Sucursal = "" OR p_Sucursal IS NULL THEN
       LET cCodRet      = "00205";
       LET cMensajeRet  = "CODIGO DE SUCURSAL NULO O BLANCO";
       RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
       NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
       NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
    ELSE
        LET g_Sucursal=p_Sucursal;
    END IF;
    IF p_Usuario = "" OR p_Usuario IS NULL THEN
       LET cCodRet      = "00192";
       LET cMensajeRet  = "CODIGO DE SUCURSAL NULO O BLANCO";
       RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
       NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
       NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
    END IF;
    IF p_Folio = ""  OR p_Folio IS NULL THEN
     SELECT
         TRIM(p_Usuario)||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
         SUBSTR(CURRENT,12,2)||substr(current,15,2)
         ||SUBSTR(current,18,2)
      INTO p_Folio
      FROM "informix".dual;
    ELSE
       LET g_Folio = p_Folio;
    END IF;
   
    IF g_dtFechaHoy = "" OR g_dtFechaHoy IS NULL THEN
       SELECT fecha_proceso INTO g_dtFechaHoy
         FROM "informix".sd_maecredanexocrd
        WHERE empresa=g_Empresa
          AND num_credito = pNumCredito;
    END IF;

       SELECT num_cta
         INTO g_Cuenta
         FROM "informix".sd_ctascarg
        WHERE naturaleza='A'
          AND num_credito=pNumCredito;

    IF NVL(g_Cuenta,"") = "" THEN
       LET cCodRet      = "00193";
       LET cMensajeRet  = "El cliente no tiene asociada una cuenta de captacion";
       RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
              NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
              NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
    END IF;

    LET dCuentaCap=g_Cuenta;

-- Obtiene numero de producto
	SELECT num_producto, id_origen, status_cred
	  INTO g_NumProd, vcodigo_bloq, dStatusCred
	  FROM "informix".sd_maecredcrd
	 WHERE num_credito = pNumCredito
       AND empresa     = g_Empresa;
		   
	IF  vcodigo_bloq = '1' THEN
		LET cCodRet      = "00199";
		LET cMensajeRet  = "Cuenta bloqueada";
		RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
		NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
		NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
	END IF;
		   

---SE REALIZA  CONSULTA A LA TABLA DE  sd_conceptospagomanualcrd para obtener el codifo fun de la transacciones
    let p_Transacc = p_Transacc;
	IF  p_Transacc IN  ("7432","7970", "7998","7795","7796",'8205',"8286","8335","8701","4320","9888") THEN
		SELECT LIMIT 1 cod_fun, concepto INTO g_CodFun, cConceptoPag
		FROM "informix".sd_conceptospagomanualcrd
		WHERE transacc = p_Transacc
		AND num_producto = g_NumProd;
		
	ELSE	
		LET cCodRet      = "00189";
		LET cMensajeRet  = "TransacciÃ³n incorrecta";
		RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
		NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
		NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
	END IF;	
  
  
    IF p_TpPago=1 THEN
        SELECT a.num_credito, a.status_cred, a.sucursal,a.num_producto, a.divisa,
               (b.monto_vencido + b.mto_venc_trasp),cap_tras_no_venci,provision_normal,sdo_global_int,a.numcte,nvl(b.atr,0),b.mto_fin_ven_trasp
          INTO g_NumCred, dStatusCred,g_Sucursal, g_NumProd, g_Divisa,
               dMontoVencido,dSdoTrasp,dProvIntFinMes,dProvIvaFinMes,cNumCte,ATR_Cred,Mto_fin_venc_trasp
          FROM "informix".sd_maecredcrd a,
               "informix".sd_maesdoscrd b,
               "informix".sd_maecredanexocrd c
         WHERE a.num_credito   = pNumCredito
           AND b.num_credito   = a.num_credito
           AND a.empresa       = b.empresa
           AND b.num_credito   = c.num_credito
           AND b.empresa       = c.empresa
           AND a.empresa       = g_Empresa;

-- FMV 11-MAY-2010: Cobranzan exclusiva para Reestructura
           IF g_NumProd  NOT IN ('6011','8600') THEN
              LET cCodRet      = "00085";
              LET cMensajeRet  = "Producto no valido verifique";
               ROLLBACK WORK;
            
		   
               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
              RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                     NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                     NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
           END IF;

           LET g_Sucursal      = p_Sucursal;

            SELECT count(num_credito)
              INTO dCuentamens
              FROM "informix".sd_amortiza_creditocrd
             WHERE empresa     = g_Empresa
               AND num_credito = g_NumCred
               AND capital_status IN ('2','7','1','6');
			
			
    ELSE
	  
			SELECT nvl(atr,0),mto_fin_ven_trasp
          INTO ATR_Cred,Mto_fin_venc_trasp
          FROM "informix".sd_maesdoscrd b
         WHERE num_credito   = pNumCredito
           AND empresa       = g_Empresa;
	  
            LET dStatusCred     = g_StatusCred;
            LET dPagoMinimo     = g_montofinanciado;
            LET dtFechaApertura = g_FechaApertura;
            LET dtFechaProxPago = g_FechaProxPago;
            LET dMontoVencido   = g_MontoVencido;
            LET dSdoTrasp       = g_SdoTrasp;
            LET dIvaSuc         = g_IvaSuc;
            LET g_Sucursal      = p_Sucursal;
            LET dCuentamens     = g_Cuentamens;
            LET dProvIntFinMes  = g_ProvIntFinMes;
            LET dProvIvaFinMes  = g_ProvIvaFinMes;
    END IF;
	  
	SELECT nombre_prod INTO cNomProd 
		FROM "informix".sd_definicion
		WHERE num_producto = g_NumProd; 

	LET g_Leyenda = TRIM(g_Leyenda)||' '||TRIM(NVL(cNomProd,""));

	  
           IF dCuentamens > 0  AND dStatusCred NOT IN ('FF','FC','CV')  THEN 
            IF p_TpPago=1  THEN
              SELECT iva INTO dIvaSuc
                FROM bdinteg:"informix".si_sucursales
               WHERE empresa=g_Empresa
                 AND sucursal=g_Sucursal;

                 /*EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_Empresa,g_NumCred)
                              INTO cCodRetAux,cMensajeRet,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinimo,dtDateAux,
                                  iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                                  dDecAux,dDecAux,dDecAux,dIntMora,dDecAux,dDecAux,dDecAux,dDecAux,dIvaIntMora,dDecAux,
                                  dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotal,dDecAux,dDecAux,
                                  dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
                                  cCharAux,cCharAux,iIntAux,cCharAux;*/
				---- RQM 09 486 - 2 MACF
				EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_Empresa,g_NumCred)
                              INTO cCodRetAux,cMensajeRet,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinimo,dtDateAux,
                                  iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                                  dDecAux,dDecAux, dIntVdo_2, dIntMora,dDecAux,dDecAux,dDecAux, dIvaIntVdo_2,dIvaIntMora,dDecAux,
                                  dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotal,dDecAux,dDecAux,
                                  dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
                                  cCharAux,cCharAux,iIntAux,cCharAux;
				---- RQM 09 486 - 2 MACF
				
                 IF cCodRetAux <> "000000" THEN
                     LET cCodRet      = "00042";
                     LET cMensajeRet  = "Ocurrio un error al obtener el adeudo actual del cliente";
                       ROLLBACK WORK;

                       IF (wBegin = "S") THEN
                           BEGIN WORK;
                       END IF;
                     RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                            NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                            NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                 END IF;
				 IF  p_Monto > dSdoAdeudTotal THEN
					 LET cCodRet      = "00043";
                     LET cMensajeRet  = "ESTA PAGANDO MAS DE LO QUE DEBE, REALIZAR CONSULTA DE SALDO Y PAGAR IMPORTE";
                       ROLLBACK WORK;

                       IF (wBegin = "S") THEN
                           BEGIN WORK;
                       END IF;
                     RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                            NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                            NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
				 END IF;
				 
				 ---- RQM 09 486 - 2 MACF
				 LET dSaldo_vencido = dMontoVencido + dIntMora + dIvaIntMora + dIntVdo_2 + dIvaIntVdo_2; 
				 
             END IF;
                 -- Pago Normal Ventanilla (Manual)
                 -- Pago Normal Salvo Buen Cobro (Cheque)
                 IF NVL(dPagoMinimo,0) <= 0 THEN
                    LET cCodRet      = "00063";
                    LET cMensajeRet  = "No es posible aceptar el pago";
                       ROLLBACK WORK;

                       IF (wBegin = "S") THEN
                           BEGIN WORK;
                       END IF;
                    LET dIntMora = 0; LET dIvaIntMora = 0; LET dIntVdo = 0; LET dIvaIntVdo = 0;
                    RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                           NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                           NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                 END IF;
---CAS

                 IF  p_Transacc IN ("7432","7998","9888")  THEN
                              -- Se obtiene el numero de tarjeta.
                      SELECT a.num_tarjeta
                        INTO g_NumTarjDeb
                        FROM bdicheq:"informix".sc_tarjeta a
                       WHERE a.empresa   = g_Empresa
                         AND a.cuenta    = dCuentaCap
                         AND a.secuencia = (SELECT MAX(b.secuencia)
                                              FROM bdicheq:"informix".sc_tarjeta b
                                             WHERE b.empresa      = a.empresa
                                               AND b.cuenta       = a.cuenta
                                               AND b.secuencia    = b.secuencia
                                               AND b.tipo_tarjeta = "T");

                         IF g_NumTarjDeb IS NULL THEN
                            LET g_NumTarjDeb = "";
                         END IF;

                         -- Se obtiene el saldo de la cuenta identificada.
                         CALL bdicheq:"informix".cons_saldo(dCuentaCap) RETURNING cCodRetAux,g_SdoCta,g_StatusCtaCap;

                         IF (cCodRetAux <> "000") THEN
                             LET cCodRet      = "00066";
                             LET cMensajeRet  = "No es posible obtener el saldo actual de la cuenta cliente";
                               ROLLBACK WORK;

                               IF (wBegin = "S") THEN
                                   BEGIN WORK;
                               END IF;
                             LET dIntMora = 0; LET dIvaIntMora = 0; LET dIntVdo = 0; LET dIvaIntVdo = 0;
                             RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                    NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                    NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                         END IF;

                         -- Valida si el saldo esta activo para poder usarlo.
                         IF g_StatusCtaCap <> "1" THEN
                            LET cCodRet      = "00195";
                            LET cMensajeRet  = "Cuenta de debito bloqueada";
                            ROLLBACK WORK;

                            IF (wBegin = "S") THEN
                               BEGIN WORK;
                            END IF;
                            RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                   NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                   NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                         END IF;

                         -- Valida el saldo obtenido de la cuenta.
                         IF NVL(g_SdoCta,0) <= 0 THEN
                            LET cCodRet      = "00194";
                            LET cMensajeRet  = "Cuenta de debito sin saldo";
                            ROLLBACK WORK;

                            IF (wBegin = "S") THEN
                               BEGIN WORK;
                            END IF;
                            RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                   NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                   NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                         END IF;

                         IF g_SdoCta >= dMontoPago THEN
                            LET dMontoPago = dMontoPago;
                         ELSE
                            -- Se modifica para validar que la cuenta tiene el saldo suficiente para la operacion
							-- CGP 15/05/2014
							IF p_Sucursal <> '9290' THEN
								ROLLBACK WORK;
								IF (wBegin = "S") THEN
									BEGIN WORK;
								END IF;							
								LET cCodRet      = "00777";
								LET cMensajeRet  = "La cuenta del cargo NO tiene saldo suficiente";
								RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
									   NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
									   NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
							ELSE
									
								LET dMontoPago = g_SdoCta;
								
							END IF;
							-- Se modifica para validar que la cuenta tiene el saldo suficiente para la operacion
							-- CGP 15/05/2014
                         END IF;


                         IF dMontoPago <= 0 THEN
                            LET cCodRet      = "00064";
                            LET cMensajeRet  = "Se requiere cubrir un monto mayor a 0";
                            LET dIntMora = 0; LET dIvaIntMora = 0; LET dIntVdo = 0; LET dIvaIntVdo = 0;
                            ROLLBACK WORK;

                            IF (wBegin = "S") THEN
                               BEGIN WORK;
                            END IF;
                            RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                   NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                   NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                         END IF;
                                -- Por solicitud de Juan Olivares no se puede realizar un pago normal que llame al pago anticipado,
                                -- por lo tanto no se puede hacer un pago mayor al pago minimo


                         IF dMontoPago > dPagoMinimo THEN
                            LET cCodRet      = "00065";
                            LET cMensajeRet  = "EESTA PAGANDO MAS DE SU PAGO MINIMO, REALIZAR CONSULTA DE SALDO Y PAGAR IMPORTE";
                            LET dIntMora = 0; LET dIvaIntMora = 0; LET dIntVdo = 0; LET dIvaIntVdo = 0;
                            ROLLBACK WORK;

                            IF (wBegin = "S") THEN
                               BEGIN WORK;
                            END IF;
                            RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                   NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                   NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                         END IF;

                         LET g_Remanente_pago = dMontoPago;
                                  
						IF g_NumProd = '8600' THEN
							LET g_TranCargo = '0541';
						END IF;
                                  -- Realiza el cargo del adeudo a la cuenta
						IF p_Transacc = "9888" THEN
						
							LET g_TranCapt = "0551";
							
							 EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(g_Empresa,
																 g_Sucursal,
																 p_Usuario,
																 g_TranCapt,
																 g_TranCapt,
																 g_Folio,
																 dCuentaCap,
																 g_cheque,
																 g_Remanente_pago,
																 g_Divisa,
																 TRIM(pNumCredito)||" "||g_Leyenda,
																 g_NumTarjDeb,
																 g_Autoriza)
							INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;
						ELSE
							EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(g_Empresa,
																 g_Sucursal,
																 p_Usuario,
																 g_TranCargo,
																 g_TranSuc,
																 g_Folio,
																 dCuentaCap,
																 g_cheque,
																 g_Remanente_pago,
																 g_Divisa,
																 TRIM(pNumCredito)||" "||g_Leyenda,
																 g_NumTarjDeb,
																 g_Autoriza)
							INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;
						END IF;

                        IF cCodRetAux <> "000" THEN
                           LET cCodRet      = "00051";
                           LET cMensajeRet  = "Ocurrio un error al aplicar el cargo a la cuenta de captacion";
                           LET dIntMora = 0; LET dIvaIntMora = 0; LET dIntVdo = 0; LET dIvaIntVdo = 0;
                            ROLLBACK WORK;

                            IF (wBegin = "S") THEN
                               BEGIN WORK;
                            END IF;
                           RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                  NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                  NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                       END IF;
                 END IF;
---CAS
                 LET g_Remanente_pago = dMontoPago;

           ELSE
                   LET cCodRet      = "00189";
                   LET cMensajeRet  = "El cliente no cuenta con adeudo en mensualidades";
                   ROLLBACK WORK;

                   IF (wBegin = "S") THEN
                      BEGIN WORK;
                   END IF;
                   RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                          NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                          NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
           END IF;

           LET dIntMora    = 0; LET dIvaIntMora = 0; LET dIntVdo     = 0;  LET dIvaIntVdo  = 0;
                IF gRespaldoActivo = '0' THEN --se agrega validacion para ver si se realzia respaldo -JMAH
					-- Se respalda el credito.
	                CALL "informix".sp_respalda_credito_rr(g_Empresa,g_NumCred,p_Usuario) RETURNING cCodRetAux;
	                IF (cCodRetAux <> "000000") THEN
	                    LET cCodRet     = "00054";
	                    LET cMensajeRet = "Ocurrio un error al respaldar el credito";
	                    ROLLBACK WORK;

	                    IF (wBegin = "S") THEN
	                       BEGIN WORK;
	                    END IF;
	                    RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
	                           NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
	                           NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
	                END IF;
				END IF;
				
				LET g_TransaccSuc = p_Transacc;
				IF g_TransaccSuc IN ("7795", "7796","8701") THEN
				
				
				    -- Se genera el primer movimiento por el total del abono.
					CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,1,g_CodFun,g_dtFechaHoy,g_Remanente_pago,
											  g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,cConceptoPag,"")
					RETURNING cCodRetAux, cMensajeRet;

					IF (cCodRetAux <> "000000") THEN
						LET cCodRet = "00067";
						LET cMensajeRet  = "Ocurrio un error al registrar el movimiento por el total del abono";
						ROLLBACK WORK;

						IF (wBegin = "S") THEN
						   BEGIN WORK;
						END IF;
						RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
							   NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
							   NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
					ELSE
						LET cCodRet = "00000";
					END IF;
				ELIF g_TransaccSuc = "4320" THEN --MODIFICACION ATM PAGO NORMAL EFECTIVO
				    
					-- Se genera el primer movimiento por el total del abono para pagos en ATM.
					CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,89,'059',g_dtFechaHoy,g_Remanente_pago,
											  g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"PAGO NORMAL","")
					RETURNING cCodRetAux, cMensajeRet;

					IF (cCodRetAux <> "000000") THEN
						LET cCodRet = "00067";
						LET cMensajeRet  = "Ocurrio un error al registrar el movimiento por el total del abono";
						ROLLBACK WORK;

						IF (wBegin = "S") THEN
						   BEGIN WORK;
						END IF;
						RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
							   NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
							   NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
					ELSE
						LET cCodRet = "00000";
					END IF;
				ELIF g_TransaccSuc = "9888" THEN --MODIFICACION ATM PAGO NORMAL CGO CTA
				    
					-- Se genera el primer movimiento por el total del abono para pagos en ATM.
					CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,88,'059',g_dtFechaHoy,g_Remanente_pago,
											  g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"PAGO NORMAL","")
					RETURNING cCodRetAux, cMensajeRet;

					IF (cCodRetAux <> "000000") THEN
						LET cCodRet = "00067";
						LET cMensajeRet  = "Ocurrio un error al registrar el movimiento por el total del abono";
						ROLLBACK WORK;

						IF (wBegin = "S") THEN
						   BEGIN WORK;
						END IF;
						RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
							   NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
							   NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
					ELSE
						LET cCodRet = "00000";
					END IF;
				ELSE
					-- Se genera el primer movimiento por el total del abono.
					CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,1,g_CodFun,g_dtFechaHoy,g_Remanente_pago,
											  g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"PAGO NORMAL","")
					RETURNING cCodRetAux, cMensajeRet;

					IF (cCodRetAux <> "000000") THEN
						LET cCodRet = "00067";
						LET cMensajeRet  = "Ocurrio un error al registrar el movimiento por el total del abono";
						ROLLBACK WORK;

						IF (wBegin = "S") THEN
						   BEGIN WORK;
						END IF;
						RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
							   NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
							   NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
					ELSE
						LET cCodRet = "00000";
					END IF;
                END IF;
			IF g_TransaccSuc IN ("7795", "7796") THEN
              FOREACH 
                    SELECT a.fecha_cuota, a.capital_status,a.interes_debe - a.interes_pagado, a.iva_debe - a.iva_pagado,a.num_pago
                      INTO dFechaCuota, dCapitalStatus, dIntDebe, dIvaIntDebe,g_NumPago
                      FROM "informix".sd_amortiza_creditocrd a
                     WHERE a.empresa     = g_Empresa
                       AND a.num_credito = g_NumCred
                       AND a.capital_status IN ("1", "7", "2","6")
                     ORDER BY a.num_credito,a.fecha_cuota
                                  --- Se calcula el porcentaje a pagar por cada concepto para la cuota.
                                  CALL "informix".sp_calporcentaje_rr(dIntDebe,0,0,dIvaIntDebe,2)
                                  RETURNING cCodRetAux,cMensajeRet,dPagoMoraOrdi,dPagoMoraCope,dPagoInt,dPagoIvaInt;

                                     -- Se cobra interes vdo e iva de interes vdo.
                                     IF ((dIntDebe > 0 OR  dIvaIntDebe > 0)  AND (g_Remanente_pago > 0)) THEN
                                          CALL "informix".sp_cobra_int_rr(dFechaCuota,dPagoInt,dPagoIvaInt,dCapitalStatus, dStatusCred)
                                          RETURNING cCodRetAux,cMensajeRet;
                                          IF (cCodRetAux <> "000000") THEN
                                              LET cCodRet = "00070";
                                              LET cMensajeRet = "OcurriÃ³ un error al cobrar el interes e iva vencido";
                                              ROLLBACK WORK;
                                              IF wBegin = "S" THEN
                                                 BEGIN WORK;
                                              END IF;
                                              RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                     NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                     NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                          END IF;

                                          LET g_Remanente_pago = g_Remanente_pago - (dPagoInt + dPagoIvaInt);

                                          IF dCapitalStatus IN ('2','7','6') THEN
                                              LET dIntVdo    = dIntVdo + dPagoInt;
                                              LET dIvaIntVdo = dIvaIntVdo + dPagoIvaInt;
                                              LET dPagoInt   = 0;
                                              LET dPagoIvaInt= 0;
                                          END IF;
                                      END IF;
			  END FOREACH;
		  END IF;
			 
             FOREACH WITH HOLD
                    SELECT a.fecha_cuota, a.capital_status, a.mora_sdo_ordi - a.mora_sdo_ordi_pag, a.mora_sdo_cope - a.mora_sdo_cope_pag,
                           a.interes_debe - a.interes_pagado, a.iva_debe - a.iva_pagado,a.capital_debe - a.capital_pagado,a.num_pago
                      INTO dFechaCuota, dCapitalStatus, dIntMoraOrdi, dIntMoraCope,
                           dIntDebe, dIvaIntDebe, dCapitalDebe,g_NumPago
                      FROM "informix".sd_amortiza_creditocrd a
                     WHERE a.empresa     = g_Empresa
                       AND a.num_credito = g_NumCred
                       AND a.capital_status IN ("1","7","2","6")
                     ORDER BY a.num_credito,a.fecha_cuota

                                  --- Se calcula el porcentaje a pagar por cada concepto para la cuota.
                                  CALL "informix".sp_calporcentaje_rr(dIntDebe,0,0,dIvaIntDebe,2)
                                  RETURNING cCodRetAux,cMensajeRet,dPagoMoraOrdi,dPagoMoraCope,dPagoInt,dPagoIvaInt;
								  ---- se agrega if para validar proceso de quitas 
									 IF  p_Transacc = '8701' OR  gprocesa <> 1 THEN
                                     -- Se cobra interes vdo e iva de interes vdo.
                                     IF ((dPagoInt > 0 OR  dPagoIvaInt > 0)  AND (g_Remanente_pago > 0)) THEN
                                          CALL "informix".sp_cobra_int_rr(dFechaCuota,dPagoInt,dPagoIvaInt,dCapitalStatus, dStatusCred)
                                          RETURNING cCodRetAux,cMensajeRet;
                                          IF (cCodRetAux <> "000000") THEN
                                              LET cCodRet = "00070";
                                              LET cMensajeRet = "Ocurrio un error al cobrar el interes e iva vencido";
                                              ROLLBACK WORK;
                                              IF wBegin = "S" THEN
                                                 BEGIN WORK;
                                              END IF;
                                              RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                     NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                     NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                          END IF;

                                          LET g_Remanente_pago = g_Remanente_pago - (dPagoInt + dPagoIvaInt);

                                          IF dCapitalStatus IN ('2','7','6') THEN
                                              LET dIntVdo    = dIntVdo + dPagoInt;
                                              LET dIvaIntVdo = dIvaIntVdo + dPagoIvaInt;
                                              LET dPagoInt   = 0;
                                              LET dPagoIvaInt= 0;
                                          END IF;
                                      END IF;
									 END IF; 
                                      -- Se cobra capital vdo
                                      IF (dCapitalDebe > 0 AND g_Remanente_pago > 0) AND gprocesa <> 1 THEN
                                            IF dCapitalDebe > g_Remanente_pago THEN
                                                 LET dPagoCapitalM = g_Remanente_pago;
                                            ELSE
                                                 LET dPagoCapitalM = dCapitalDebe;
                                            END IF;

                                            CALL "informix".sp_cobra_cap_rr(dFechaCuota,dPagoCapitalM,dCapitalStatus,dStatusCred)
                                            RETURNING cCodRetAux,cMensajeRet;

                                            IF (cCodRetAux <> "000000") THEN
                                                LET cCodRet = "00071";
                                                LET cMensajeRet = "Ocurrio un error al cobrar el capital";
                                                ROLLBACK WORK;
                                                IF wBegin = "S" THEN
                                                   BEGIN WORK;
                                                END IF;
                                                RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                       NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                       NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                             END IF;
                                             LET g_Remanente_pago = g_Remanente_pago - dPagoCapitalM;
                                             LET dPagoCapital     = dPagoCapital + dPagoCapitalM;
                                             LET dMontoVencido    = dMontoVencido - dPagoCapitalM;
                                             LET dPagoCapitalM    = 0;
                                      END IF;


                                 --SE OBTIENE ATR PARA CALCULOS DE IFRS --AEH

                                 SELECT count (*)
                                    INTO aux_vencidos
                                    FROM "informix".sd_amortiza_creditocrd a
                                    WHERE a.empresa     = g_Empresa
                                       AND a.num_credito = g_NumCred
                                       AND a.capital_status IN ("7","2","6");

                                    IF aux_vencidos IS NULL THEN
                                       LET aux_vencidos = 0;
                                    END IF;

								  
                                 IF g_Remanente_pago >= 0 AND dMontoVencido <=0 AND dStatusCred IN ('BT','BA') THEN  --> Pago en BT o BA

                                   UPDATE "informix".sd_maecredcrd
                                      SET status_cred = 'AA'
                                    WHERE empresa     = g_Empresa
                                      AND num_credito = g_NumCred;

                                    IF dStatusCred='BT' THEN
										SELECT cap_tras_no_venci
                                          INTO dSdoTrasp 
                                          FROM "informix".sd_maesdoscrd
                                         WHERE num_credito  = g_NumCred
                                           AND empresa      = g_Empresa;
										   
                                           UPDATE "informix".sd_maesdoscrd
                                              SET mto_fin_ven_trasp = aux_vencidos,
                                                   sdo_capital       = cap_tras_no_venci,   --> FMV: VIGENTE = NO EXIGIBLE
                                                  cap_tras_no_venci = 0,
                                                  dias_acum_mora    = 0
                                            WHERE empresa     = g_Empresa
                                              AND num_credito = g_NumCred;

                                           SELECT sum(interes_debe-interes_pagado),
                                                  sum(iva_debe-iva_pagado)
                                             INTO dIntTrasp,dIvaTrasp
                                             FROM "informix".sd_amortiza_creditocrd
                                            WHERE empresa=g_Empresa
                                              AND num_credito = g_NumCred
                                              AND capital_status = "1";

                                              IF dIntTrasp IS NULL THEN LET dIntTrasp = 0; END IF;
                                              IF dIvaTrasp IS NULL THEN LET dIvaTrasp = 0; END IF;
                                              LET dIntTrasp = dIntTrasp + dProvIntFinMes;
                                              LET dIvaTrasp = dIvaTrasp + dProvIvaFinMes;

                                        -- Se registra el movimiento de traspaso de capital vdo no exig a vigente
                                        --> FMV: TRASPASO DE CAPITAL VENCIDO A VIGENTE
                                        IF dSdoTrasp > 0 THEN
											IF g_TransaccSuc ='9888' THEN --TRASPASO DE CAPITAL VENCIDO A VIGENTE ATM
												    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,51,'059',g_dtFechaHoy,dSdoTrasp,
                                                           g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                        RETURNING cCodRetAux, cMensajeRet;												    
												ELSE
												    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,5,'601',g_dtFechaHoy,dSdoTrasp,
                                                           g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                        RETURNING cCodRetAux, cMensajeRet;
												    
												END IF;
                                            IF (cCodRetAux <> "000000") THEN
                                                LET cCodRet = "00074";
                                                LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de capital";
                                                ROLLBACK WORK;

                                                IF (wBegin = "S") THEN
                                                   BEGIN WORK;
                                                END IF;
                                                RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                       NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                       NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                            END IF;
                                         END IF;
                                        -- Se registra el movimiento de traspaso de interes vencido a vigente
                                        -- FMV 13-May-10: Falta Definir el codigo ref de la transaccion de Interes

                                        IF dIntTrasp > 0 THEN
											IF g_TransaccSuc ='9888' THEN --TRASPASO INT SDOS VDOS  E3 A E1 ATM CGO A CTA
												    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,87,'059',g_dtFechaHoy,dSdoTrasp,
                                                           g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                        RETURNING cCodRetAux, cMensajeRet;												    
												ELSE
												    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,903,g_CodFun,g_dtFechaHoy,dIntTrasp,
                                                           g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                 RETURNING cCodRetAux, cMensajeRet;
												    
											END IF;
                                            IF (cCodRetAux <> "000000") THEN
                                                LET cCodRet = "00075";
                                                LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de interes";
                                                ROLLBACK WORK;

                                                IF (wBegin = "S") THEN
                                                   BEGIN WORK;
                                                END IF;
                                                RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                       NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                       NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                            END IF;
                                         END IF;
                                        -- Se registra el movimiento de traspaso de iva de interes vencido a vigente
                                        -- FMV 13-May-10: Falta Definir el codigo ref de la transaccion IVA

                                        IF dIvaTrasp > 0 THEN
											IF g_TransaccSuc ='9888' THEN --TRASPASO INT SDOS VDOS  E3 A E1 ATM CGO A CTA
												    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,87,'059',g_dtFechaHoy,dSdoTrasp,
                                                           g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                        RETURNING cCodRetAux, cMensajeRet;												    
												ELSE
												    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,904,g_CodFun,g_dtFechaHoy,dIvaTrasp,
                                                           g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                 RETURNING cCodRetAux, cMensajeRet;
												    
												END IF;
                                            IF (cCodRetAux <> "000000") THEN
                                                LET cCodRet = "00075";
                                                LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de interes";
                                                ROLLBACK WORK;

                                                IF (wBegin = "S") THEN
                                                   BEGIN WORK;
                                                END IF;
                                                RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                       NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                       NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                             END IF;
                                          END IF;

                                       END IF;
                                       LET dStatusCred='AA';
                                 END IF;

                              IF g_Remanente_pago >= 0 AND dMontoVencido <=0 AND dStatusCred in ('E1','VP') THEN

                                 UPDATE "informix".sd_maesdoscrd
                                             SET mto_fin_ven_trasp = 0,
                                                atr = 0
                                          WHERE empresa     = g_Empresa
                                             AND num_credito = g_NumCred;

                              ELIF g_Remanente_pago >= 0 AND dMontoVencido <=0 AND dStatusCred IN ('E2','E3') THEN  --> Pago en BT o BA

                                   UPDATE "informix".sd_maecredcrd
                                      SET status_cred = 'E1'
                                    WHERE empresa     = g_Empresa
                                      AND num_credito = g_NumCred;

										SELECT sdo_capital
                                          INTO dSdoTrasp 
                                          FROM "informix".sd_maesdoscrd
                                         WHERE num_credito  = g_NumCred
                                           AND empresa      = g_Empresa;
										   
                                          UPDATE "informix".sd_maesdoscrd
                                             SET mto_fin_ven_trasp = aux_vencidos,
                                                atr = aux_vencidos,
                                                monto_vencido = 0,
                                                dias_acum_mora    = 0
                                          WHERE empresa     = g_Empresa
                                             AND num_credito = g_NumCred;

                                          SELECT sum(interes_debe-interes_pagado),
                                                sum(iva_debe-iva_pagado)
                                          INTO dIntTrasp,dIvaTrasp
                                          FROM "informix".sd_amortiza_creditocrd
                                          WHERE empresa=g_Empresa
                                             AND num_credito = g_NumCred
                                             AND capital_status = "1";

                                             IF dIntTrasp IS NULL THEN LET dIntTrasp = 0; END IF;
                                             IF dIvaTrasp IS NULL THEN LET dIvaTrasp = 0; END IF;
                                             LET dIntTrasp = dIntTrasp + dProvIntFinMes;
                                             LET dIvaTrasp = dIvaTrasp + dProvIvaFinMes;

                                       --> FMV: TRASPASO DE E3 Y E2 A E1
                                       IF dSdoTrasp > 0 THEN
                                          IF dStatusCred='E3' THEN
											IF g_TransaccSuc = '9888' THEN 
											    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,52,'059',g_dtFechaHoy,dSdoTrasp,
                                                            g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                   RETURNING cCodRetAux, cMensajeRet;
											 ELSE
                                                CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,1100,'601',g_dtFechaHoy,dSdoTrasp,
                                                            g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                   RETURNING cCodRetAux, cMensajeRet;
											 END IF;
                                            ELIF dStatusCred='E2' THEN
										      IF g_TransaccSuc = '9888' THEN
											    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,48,'059',g_dtFechaHoy,dSdoTrasp,
                                                            g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                   RETURNING cCodRetAux, cMensajeRet;
										      ELSE
											    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,1101,'601',g_dtFechaHoy,dSdoTrasp,
                                                            g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                   RETURNING cCodRetAux, cMensajeRet;									   
										      END IF;
										   
                                            END IF;
                                          IF (cCodRetAux <> "000000") THEN
                                             LET cCodRet = "00074";
                                             LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de capital";
                                             ROLLBACK WORK;

                                             IF (wBegin = "S") THEN
                                                BEGIN WORK;
                                             END IF;
                                             RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                      NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                      NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                          END IF;
                                       END IF;


                                    LET dStatusCred='E1';
                              END IF;


                        -- TRASPASO DE E3 A E2

                        SELECT max(fecha_cuota)
                           INTO dFechaMaxAmort
                           FROM "informix".sd_amortiza_creditocrd a
                           WHERE a.empresa     = g_Empresa
                              AND a.num_credito = g_NumCred
                              AND a.capital_status IN ("7","2","6");

                        SELECT fecha_hoy - dFechaMaxAmort
                           INTO dDiasMaxAmort
                           FROM "informix".sd_fechas
                          WHERE empresa     = g_Empresa;

                        IF dMontoVencido > 0 AND dStatusCred in ('E2','E3') THEN

                           LET ATR_Cred_aux = nvl(ATR_Cred - (Mto_fin_venc_trasp - aux_vencidos),0);

                           UPDATE "informix".sd_maesdoscrd
                              SET mto_fin_ven_trasp = aux_vencidos,
                                 atr = ATR_Cred_aux
                              WHERE empresa     = g_Empresa
                              AND num_credito = g_NumCred;
                              
                        END IF;

						      IF (dStatusCred ='E3' AND ATR_Cred_aux <= 3 ) THEN

                                   UPDATE "informix".sd_maecredcrd
                                      SET status_cred = 'E2 '
                                    WHERE empresa     = g_Empresa
                                      AND num_credito = g_NumCred;

										          SELECT sdo_capital, monto_vencido
                                          INTO dSdoTrasp, dMonto_Vdo
                                          FROM "informix".sd_maesdoscrd
                                         WHERE num_credito  = g_NumCred
                                           AND empresa      = g_Empresa;
										   
                                          UPDATE "informix".sd_maesdoscrd
                                             SET mto_fin_ven_trasp = aux_vencidos,
                                                atr = aux_vencidos
                                          WHERE empresa     = g_Empresa
                                             AND num_credito = g_NumCred;

                                          SELECT NVL(SUM(NVL(interes_debe - interes_pagado,0)),0), NVL(SUM(NVL(iva_debe - iva_pagado,0)),0)
                                             INTO dIntTrasp,dIvaTrasp
                                             FROM "informix".sd_amortiza_creditocrd
                                             WHERE empresa        = g_Empresa
                                                AND num_credito    = g_NumCred
                                                AND capital_status IN ('7','2','6');

                                             IF dIntTrasp IS NULL THEN LET dIntTrasp = 0; END IF;
                                             IF dIvaTrasp IS NULL THEN LET dIvaTrasp = 0; END IF;
                                             
                                       --> FMV: TRASPASO DE CAPITAL NO EXIGIBLE E3 A E2
                                       IF dSdoTrasp > 0 THEN
												   
										    IF g_TransaccSuc = '9888' THEN
											    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,50,'059',g_dtFechaHoy,dSdoTrasp,
                                                            g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                   RETURNING cCodRetAux, cMensajeRet;
											ELSE
											    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,1102,'601',g_dtFechaHoy,dSdoTrasp,
                                                            g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                   RETURNING cCodRetAux, cMensajeRet;
											END IF;

                                          IF (cCodRetAux <> "000000") THEN
                                             LET cCodRet = "00074";
                                             LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de capital no exigible";
                                             ROLLBACK WORK;

                                             IF (wBegin = "S") THEN
                                                BEGIN WORK;
                                             END IF;
                                             RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                      NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                      NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                          END IF;
                                       END IF;

                                       --> FMV: TRASPASO DE CAPITAL EXIGIBLE E3 A E2
                                       IF dMonto_Vdo > 0 THEN
											 
										    IF g_TransaccSuc = '9888' THEN
											    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,49,'059',g_dtFechaHoy,dMonto_Vdo,
                                                            g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                   RETURNING cCodRetAux, cMensajeRet;
											ELSE
											    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,1103,'601',g_dtFechaHoy,dMonto_Vdo,
                                                            g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                   RETURNING cCodRetAux, cMensajeRet;
											END IF;

                                          IF (cCodRetAux <> "000000") THEN
                                             LET cCodRet = "00074";
                                             LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de capital exigible";
                                             ROLLBACK WORK;

                                             IF (wBegin = "S") THEN
                                                BEGIN WORK;
                                             END IF;
                                             RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                      NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                      NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                          END IF;
                                       END IF;

                                       -- Traspaso de intereses de E3 a E2
                                       IF dIntTrasp > 0 THEN
											IF g_TransaccSuc = '9888' THEN
											    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,83,'059',g_dtFechaHoy,dMonto_Vdo,
                                                            g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                   RETURNING cCodRetAux, cMensajeRet;
											ELSE
											    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,1104,'601',g_dtFechaHoy,dIntTrasp,
                                                            g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                   RETURNING cCodRetAux, cMensajeRet;
											END IF;
                                          IF (cCodRetAux <> "000000") THEN
                                             LET cCodRet = "00075";
                                             LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de interes";
                                             ROLLBACK WORK;

                                             IF (wBegin = "S") THEN
                                                BEGIN WORK;
                                             END IF;
                                             RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                      NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                      NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                          END IF;
                                       END IF;
                                      
                                    LET dStatusCred='E2';
                        END IF;



            END FOREACH;
-- FMV 14-MAY-10 VP  INICIA

/*
            SELECT count(num_credito)
              INTO dCuentamens
              FROM "informix".sd_amortiza_creditocrd
             WHERE empresa     = g_Empresa
               AND num_credito = g_NumCred
               AND capital_status IN ('2','7','1');
*/			   
		    SELECT count(num_credito)
              INTO dCuentamens
              FROM "informix".sd_amortiza_creditocrd
             WHERE empresa     = g_Empresa
               AND num_credito = g_NumCred
               AND capital_status_ant='1'
			   AND capital_status='5'
			   AND capital_fecha_pago=fecha_cuota
			   AND fecha_cuota=g_dtFechaHoy;

                        IF dStatusCred IN ('VP') AND dCuentamens=1 THEN  --> Pago en VP

                           UPDATE "informix".sd_maecredcrd
                              SET pagos_sostenidos = pagos_sostenidos + 1   -->
                              WHERE empresa     = g_Empresa
                              AND num_credito = g_NumCred;

                              SELECT pagos_sostenidos
                              INTO iPagoSosten
                              FROM "informix".sd_maecredcrd
                              WHERE empresa     = g_Empresa
                                 AND num_credito = g_NumCred;

                           SELECT valor 
                              INTO dBanderaIFRS
                              FROM bdicred:sd_param 
                              WHERE empresa = g_Empresa
                                 AND cod_param='700';
 

                           IF dBanderaIFRS ='I' THEN  

                                 IF iPagoSosten = 3 THEN
                                    UPDATE "informix".sd_maecredcrd
                                       SET     status_cred = 'AA',
                                          pagos_sostenidos = 0
                                    WHERE empresa     = g_Empresa
                                       AND num_credito = g_NumCred;

                                       LET dStatusCred='AA';
                                 END IF;

                              IF dStatusCred='AA' THEN
                                 SELECT cap_tras_no_venci
                                    INTO dSdoTrasp 
                                    FROM "informix".sd_maesdoscrd
                                 WHERE num_credito  = g_NumCred
                                    AND empresa      = g_Empresa;	
                        
                                    UPDATE "informix".sd_maesdoscrd
                                       SET sdo_capital       = cap_tras_no_venci,   --> FMV: VIGENTE = NO EXIGIBLE
                                          sdo_no_exig       = int_tra_no_exig,
                                          cap_tras_no_venci = 0,
                                          int_tra_no_exig   = 0,
                                          dias_acum_mora    = 0
                                    WHERE empresa     = g_Empresa
                                       AND num_credito = g_NumCred;

                                    SELECT sum(interes_debe-interes_pagado),
                                          sum(iva_debe-iva_pagado)
                                    INTO dIntTrasp,dIvaTrasp
                                    FROM "informix".sd_amortiza_creditocrd
                                    WHERE empresa=g_Empresa
                                       AND num_credito = g_NumCred
                                       AND capital_status = "1";

                                       IF dIntTrasp IS NULL THEN LET dIntTrasp = 0; END IF;
                                       IF dIvaTrasp IS NULL THEN LET dIvaTrasp = 0; END IF;
                                       LET dIntTrasp = dIntTrasp + dProvIntFinMes;
                                       LET dIvaTrasp = dIvaTrasp + dProvIvaFinMes;

                                 -- Se registra el movimiento de traspaso de capital vdo no exig a vigente
                                 --> FMV: TRASPASO DE CAPITAL VENCIDO A VIGENTE
                                 IF dSdoTrasp > 0 THEN
									IF g_TransaccSuc = '9888' THEN
											CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,51,'059',g_dtFechaHoy,dSdoTrasp,
                                                    g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                RETURNING cCodRetAux, cMensajeRet;
										ELSE
											CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,5,'601',g_dtFechaHoy,dSdoTrasp,
                                                    g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                RETURNING cCodRetAux, cMensajeRet;
										END IF;
                                    IF (cCodRetAux <> "000000") THEN
                                       LET cCodRet = "00075";
                                       LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de capital";
                                       ROLLBACK WORK;

                                       IF (wBegin = "S") THEN
                                          BEGIN WORK;
                                       END IF;
                                       RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                    END IF;
                                 END IF;
                                 -- Se registra el movimiento de traspaso de interes vencido a vigente
                                 -- FMV 13-May-10: Falta Definir el codigo ref de la transaccion de Interes

                                 IF dIntTrasp > 0 THEN
									IF g_TransaccSuc ='9888' THEN --TRASPASO INT SDOS VDOS  E3 A E1 ATM CGO A CTA
												    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,87,'059',g_dtFechaHoy,dSdoTrasp,
                                                           g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                        RETURNING cCodRetAux, cMensajeRet;												    
												ELSE
												    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,903,g_CodFun,g_dtFechaHoy,dIntTrasp,
                                                           g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                                 RETURNING cCodRetAux, cMensajeRet;
												    
										END IF;
                                    IF (cCodRetAux <> "000000") THEN
                                       LET cCodRet = "00075";
                                       LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de interes";
                                       ROLLBACK WORK;

                                       IF (wBegin = "S") THEN
                                          BEGIN WORK;
                                       END IF;
                                       RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                    END IF;
                                 END IF;
                                 -- Se registra el movimiento de traspaso de iva de interes vencido a vigente
                                 -- FMV 13-May-10: Falta Definir el codigo ref de la transaccion IVA

                                 IF dIvaTrasp > 0 THEN
                                    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,904,g_CodFun,g_dtFechaHoy,dIvaTrasp,
                                                   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                          RETURNING cCodRetAux, cMensajeRet;

                                    IF (cCodRetAux <> "000000") THEN
                                       LET cCodRet = "00075";
                                       LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de interes";
                                       ROLLBACK WORK;

                                       IF (wBegin = "S") THEN
                                          BEGIN WORK;
                                       END IF;
                                       RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                    END IF;
                                 END IF;
                              END IF;

                           ELIF dBanderaIFRS ='A' THEN  

                                 IF iPagoSosten = 3 THEN
                                    UPDATE "informix".sd_maecredcrd
                                       SET     status_cred = 'E1',
                                          pagos_sostenidos = 0
                                    WHERE empresa     = g_Empresa
                                       AND num_credito = g_NumCred;

                                       LET dStatusCred='E1';
                                 END IF;

                              IF dStatusCred='E1' THEN
                                 SELECT sdo_capital
                                    INTO dSdoTrasp 
                                    FROM "informix".sd_maesdoscrd
                                 WHERE num_credito  = g_NumCred
                                    AND empresa      = g_Empresa;	
                        
                                    UPDATE "informix".sd_maesdoscrd
                                       SET mto_fin_ven_trasp = aux_vencidos,
                                          sdo_no_exig       = int_tra_no_exig,
                                          cap_tras_no_venci = 0,
                                          int_tra_no_exig   = 0,
                                          dias_acum_mora    = 0
                                    WHERE empresa     = g_Empresa
                                       AND num_credito = g_NumCred;

                                 --> FMV: TRASPASO DE CAPITAL VP A E1
                                 IF dSdoTrasp > 0 THEN
                                    CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,1105,'601',g_dtFechaHoy,dSdoTrasp,
                                                   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,"","")
                                          RETURNING cCodRetAux, cMensajeRet;

                                    IF (cCodRetAux <> "000000") THEN
                                       LET cCodRet = "00075";
                                       LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de traspaso de capital";
                                       ROLLBACK WORK;

                                       IF (wBegin = "S") THEN
                                          BEGIN WORK;
                                       END IF;
                                       RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                                NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                                NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                                    END IF;
                                 END IF;
                              END IF;   
                           END IF;


                        END IF;

                        SELECT MIN(fecha_cuota)
                          INTO dFechaVenci
                          FROM "informix".sd_amortiza_creditocrd
                         WHERE empresa=g_Empresa
                           AND num_credito    = g_NumCred
                           AND capital_status in ('2','7','6');

                        UPDATE "informix".sd_maecredanexocrd
                           SET fecha_vencto   = dFechaVenci,
                               fecha_ult_pago = g_dtFechaHoy
                         WHERE num_credito    = g_NumCred
                           AND empresa        = g_Empresa;

------------------------------------------------------------------------------------
--   TRASPASOS (Se realiza traspaso de saldos de Transitorio y Vencido a Vigente.)
------------------------------------------------------------------------------------

                  IF (SELECT sdo_cap_insoluto FROM "informix".sd_maesdoscrd
                       WHERE empresa=g_Empresa AND num_credito=g_NumCred) <= 0 THEN
                                          -- Se actualiza el estatus a saldada normal
                                           UPDATE "informix".sd_maecredcrd
                                              SET status_cred = "FF"
                                            WHERE empresa     = g_Empresa
                                              AND num_credito = g_NumCred;
											--SE realiza el marcaje del cliente RQI 27 100 JMAH
											EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',3,cNumCte, p_Usuario)
											INTO cCodRetMarc, cMensajeRetMarc;
                  END IF;

                   IF p_TpPago=1  THEN

                         EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_Empresa,g_NumCred)
                                      INTO cCodRetAux,cMensajeRet,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
                                          iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                                          dsdocapinsolutopp,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                                          dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dDecAux,dDecAux,
                                          dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
                                          cCharAux,cCharAux,iIntAux,cCharAux;

                         IF cCodRetAux <> "000000" THEN
                             LET cCodRet      = "00042";
                             LET cMensajeRet  = "Ocurrio un error al obtener el adeudo actual del cliente";
                             ROLLBACK WORK;
                             IF (wBegin = "S") THEN
                                BEGIN WORK;
                             END IF;
                             RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
                                    NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
                                    NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");
                         END IF;

                         IF dtFechaProxPago > DATE(1) AND dSdoCapInsolutoPP > 0 THEN

                             LET cFechaLimite = DAY(dtFechaProxPago) || ' de ' || DECODE(MONTH(dtFechaProxPago),"1","ene","2","feb","3","mar"
                                                                                                                ,"4","abr" ,"5","may","6","jun"
                                                                                                                ,"7","jul","8","ago","9","sep"
                                                                                                                ,"10","oct","11","nov","12","dic")
                                                                      || ' de ' || YEAR(dtFechaProxPago);
                         END IF;

                         IF g_dtFechaHoy = dtFechaProxPago or dSdoCapInsolutoPP <= 0 or (dPagoMinimo - dMontoPago) <= 0 THEN
                             LET cFechaLimite = ' ';
                         END IF;

                   END IF;

    IF(cCodRet <> "00000") THEN
        ROLLBACK WORK;
    ELSE
        COMMIT WORK;
    END IF;
        LET cMensajeRet = "Se ejecuto el pago correctamente";
    IF (wBegin = "S") THEN
        BEGIN WORK;
    END IF;

	IF p_TpPago=1  THEN	
		---Evaluacion objetiva RQM 09 486 - 2 -------------------------------------------------------------------------------------
		INSERT INTO bdicobranza:cb_evaluacion_objetiva(empresa, sucursal, fecha_insert, usuario, num_credito, pago_min, saldo_vencido, pago_realizado,
															  pct_cump_pm, pct_cump_sv, folio_suc, reversado, transacc_suc, codigo_fun)
		VALUES (pempresa, p_Sucursal, g_dtFechaHoy, p_Usuario, pNumCredito, dPagoMinimo, dSaldo_vencido, p_Monto,
				case when dPagoMinimo > 0 THEN  case when (round((p_Monto/dPagoMinimo),2)*100) > 100 then 100 else (round((p_Monto/dPagoMinimo),2)*100) end ELSE 0 END,
				case when dSaldo_vencido > 0 THEN  case when (round((p_Monto/dSaldo_vencido),2)*100) > 100 then 100 else (round((p_Monto/dSaldo_vencido),2)*100) end ELSE 0 END,
				p_Folio,'N', p_Transacc, g_CodFun);
		---Evaluacion objetiva RQM 09 486 - 2 -------------------------------------------------------------------------------------
	END IF;
	
  RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0), NVL(dIvaIntMora,0),
        NVL(dIntVdo,0), NVL(dIvaIntVdo,0), NVL(dPagoInt,0), NVL(dPagoIvaInt,0), NVL(dPagoCapital,0), NVL(dMontoPago,0),
        NVL(dCuentaCap,""), NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0), NVL(cFechaLimite,"");

END PROCEDURE
DOCUMENT
'Modificacion: Se agregan las nuevas transacciones de los conceptos de pago Condonacion (7795) y Condonacion por Fallecimiento (7796)',
'              para cobrar los intereses vencidos de la reestructura de tarjeta de credito.',
'Modifico: Mireya Gpe Reyes Vargas',
'Fecha: 07-ENERO-2014',
'FOLIO: 1395 Condonacion de intereses moratorios y vencidos.',
'Version: 20140107.1106',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_pago_anticipado_rr(pEmpresa    CHAR(3),
                                                  pNumCredito CHAR(20),
                                                  pUsuario    CHAR(8),
                                                  pSucursal   CHAR(4),
                                                  pFolio      CHAR(16),
                                                  pTransacc   CHAR(4),
                                                  pMonto      DECIMAL(18,2),
                                                  pbanderarespaldo char(1))
RETURNING  CHAR(5)        AS cod_ret,
           CHAR(125)      AS mens_ret,
           DECIMAL(18,2)  AS sdo_ant,
           DECIMAL(18,2)  AS comision,
           DECIMAL(18,2)  AS iva_com,
           DECIMAL(18,2)  AS int_mora,
           DECIMAL(18,2)  AS iva_int_mora,
           DECIMAL(18,2)  AS int_vdo,
           DECIMAL(18,2)  AS iva_int_vdo,
           DECIMAL(18,2)  AS int_ordi,
           DECIMAL(18,2)  AS iva_int_ordi,
           DECIMAL(18,2)  AS capital,
           DECIMAL(18,2)  AS monto_pago,
           CHAR(20)       AS cuenta_eje,
           DECIMAL(18,2)  AS sdo_act,
           DECIMAL(18,2)  AS pago_min,
           CHAR(17)       AS fecha_limite_pago;

-- Modifico: Roque Solis
-- Fechas: 30/12/2009
-- Modificacion: se valido que el pago anticipado con cargo a cuenta
--              realice el cargo y la validaciones correspondientes
--              a la cuenta efectiva.

-- Modifico: Paul Ivan Quintero Varela
-- Fecha: 2010/01/20
-- Comentario: Se agrega la actualizaciÃÂÃÂ³n del campo capital_status_ant

-- Modifico: Roque Solis
-- Fecha: 25/02/2010
-- Comentario: Se modifico para que en el saldo anterior se coloque el saldo total para liquidar
--                  antes de realizar el pago.

-- ModificÃÂÃÂ³: Paul Ivan Quintero Varela
-- Fecha: 25/02/2010
-- Comentario:  Se modifica para que el procedimiento regrese los siguientes campos:
--                      "usted debe al dia de hoy"
--                      "Su pago mÃÂÃÂ­nimo hoy"
--                      "total que pago el cliente"
--                      "Cargo en cuenta eje"
--                      "Fecha lÃÂÃÂ­mite de pago"

-- ModificÃÂÃÂ³: Paul Ivan Quintero Varela
-- Fecha: 26/02/2010
-- Comentario:  Se modifica con la finalidad de reorganizar los codigos de retorno

-- Modifico:JesÃÂÃÂºs Manuel Aguilar Heredia
-- Fecha: 12-05-2011
-- Comentario: se realiza modificacion para contemplar nuevas transacciones de pago desde sucursal.

DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE cCodRet            CHAR(5);
DEFINE cCodRetAux         CHAR(6);
DEFINE cMensajeRet        VARCHAR(125,1);

DEFINE GLOBAL g_NumCredito      CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_CodFun          CHAR(3)        DEFAULT "221";
DEFINE GLOBAL g_CodFunProv      CHAR(3)        DEFAULT "606";
DEFINE GLOBAL g_Folio           CHAR(16)       DEFAULT "";
DEFINE GLOBAL g_dtFechaHoy      DATE           DEFAULT today;
DEFINE GLOBAL g_cEmpresa        CHAR(3)        DEFAULT "";
DEFINE GLOBAL g_dTasaInt        DECIMAL(9,6)   DEFAULT 0;
DEFINE GLOBAL g_dIvaSuc         DECIMAL(5,3)   DEFAULT 0;
DEFINE GLOBAL g_TransaccSuc     CHAR(4)        DEFAULT "";

DEFINE GLOBAL g_Cuenta               CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_NumTarjDeb           CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_SdoCta               DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_StatusCtaCap         CHAR(1)        DEFAULT "";
DEFINE GLOBAL g_TranRet              CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_FechaCargo           DATE           DEFAULT today;
DEFINE GLOBAL g_SdoDisp              DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_MtoRet               DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_Sucursal             CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_Usuario              CHAR(8)        DEFAULT "";
DEFINE GLOBAL g_TranCargo            CHAR(4)        DEFAULT "0227";
DEFINE GLOBAL g_cheque               INTEGER        DEFAULT 0;
DEFINE GLOBAL g_Divisa               CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_Leyenda              CHAR(40)       DEFAULT "CRG. CTA. ";
DEFINE GLOBAL g_Autoriza             CHAR(8)        DEFAULT "";
DEFINE GLOBAL g_TranCapt			 CHAR(4)		DEFAULT "";

DEFINE dtFechaApert       DATE;
DEFINE iIntAux            INTEGER;
DEFINE cCharAux           CHAR(80);
DEFINE dDecAux            DECIMAL(18,2);
DEFINE dtDateAux          DATE;
DEFINE cCodigoFun         CHAR(3);
DEFINE iCodRef            INTEGER;
DEFINE cNumCred           CHAR(20);
DEFINE cNumCte            CHAR(20);
DEFINE cSucursal          CHAR(4);
DEFINE dTasaInt           DECIMAL(9,6);
DEFINE dtFechApert        DATE;
DEFINE cNumProd           CHAR(4);
DEFINE cDivisa            CHAR(2);
DEFINE dSdoCapital        DECIMAL(18,2);
DEFINE dCapitalIns        DECIMAL(18,2);
DEFINE dSdoAnt            DECIMAL(18,2);
DEFINE dSdoAdeudTotal     DECIMAL(18,2);
DEFINE dSdoAdeudTotalAct  DECIMAL(18,2);
DEFINE dPagoMinAct        DECIMAL(18,2);
DEFINE dIntDebe           DECIMAL(14,2);
DEFINE dIntPag            DECIMAL(14,2);
DEFINE dIvaDebe           DECIMAL(14,2);
DEFINE dIvaPag            DECIMAL(14,2);
DEFINE cCapStatus         CHAR(1);
DEFINE dtIvaFechPag       DATE;
DEFINE dCapMtoCuota       DECIMAL(14,2);
DEFINE dIvaIntReal        DECIMAL(18,2);
DEFINE dTotalAdeudInt     DECIMAL(18,2);
DEFINE dFactorInt         DECIMAL(18,2);
DEFINE dPagoInt           DECIMAL(18,2);
DEFINE dPagoIvaInt        DECIMAL(18,2);
DEFINE dtIntFechPag       DATE;
DEFINE dTasaCom           DECIMAL(9,6);
DEFINE dPagoCapital       DECIMAL(18,2);
DEFINE dPagoCom           DECIMAL(18,2);
DEFINE dPagoIvaCom        DECIMAL(18,2);
DEFINE cFolio             CHAR(16);
DEFINE dIntMora           DECIMAL(18,2);
DEFINE dIvaIntMora        DECIMAL(18,2);
DEFINE dIntVdo            DECIMAL(18,2);
DEFINE dIvaIntVdo         DECIMAL(18,2);
DEFINE iNumPago           INTEGER;
DEFINE cIndicador         CHAR(1);
DEFINE dIntDevengado      DECIMAL(18,2);
DEFINE dIvaIntDevengado   DECIMAL(18,2);
DEFINE dtFechaFinMes      DATE;
DEFINE dtFechaHoy         DATE;
DEFINE dInteFinMes        DECIMAL(18,2);
DEFINE dIvaIntFinMes      DECIMAL(18,2);
DEFINE dProvInte          DECIMAL(18,2);
DEFINE dProvIvaInt        DECIMAL(18,2);
DEFINE dtFechaFinMesAnt   DATE;
DEFINE dIntGrav      	  DECIMAL(18,2);
DEFINE dIntExen       	  DECIMAL(18,2);
DEFINE dFechaT            DATE;
DEFINE dMontoPago         DECIMAL(18,2);
DEFINE dtFechaProxPago    DATE;
DEFINE cFechaLimite       CHAR(17);
DEFINE dtFechaApertura    DATE;
DEFINE dtFechaCompa       DATE;
DEFINE wBegin             CHAR(1);
DEFINE cStatusCred        CHAR(2);
DEFINE cNomProd    		  CHAR(40);
DEFINE cCodRetMarc	      CHAR(6);
DEFINE cMensajeRetMarc	  CHAR(80);
DEFINE GLOBAL gRespaldoActivo        CHAR(1) DEFAULT "0";
DEFINE ATR_Cred           INTEGER;
DEFINE VarAux1            INTEGER;
DEFINE BanderaIFRS           CHAR(1);

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
   END IF;
END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

   LET wBegin = "N";
   BEGIN WORK;

LET  g_Cuenta              = "";
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "00000";
LET cCodRetAux            = "000000";
LET cMensajeRet           = "Se ejecuto el pago anticipado correctamente";

LET g_NumCredito          = pNumCredito;
LET dtFechaApert          = DATE(1);
LET g_Folio               = pFolio;
LET g_cEmpresa            = pEmpresa;
LET iIntAux               = 0;
LET cCharAux              = "";
LET dDecAux               = 0;
LET dtDateAux             = DATE(1);
LET cCodigoFun            = "";
LET iCodRef               = 0;
LET cNumCred              = "";
LET cNumCte               = "";
LET dTasaInt              = 0;
LET dtFechApert           = DATE(1);
LET cNumProd              = "";
LET cDivisa               = "";
LET dSdoCapital           = 0;
LET dCapitalIns           = 0;
LET dSdoAnt               = 0;
LET dSdoAdeudTotal        = 0;
LET dSdoAdeudTotalAct     = 0;
LET dPagoMinAct           = 0;
LET dIntDebe              = 0;
LET dIntPag               = 0;
LET dIvaDebe              = 0;
LET dIvaPag               = 0;
LET cCapStatus            = "";
LET dtIvaFechPag          = DATE(1);
LET dCapMtoCuota          = 0;
LET dIvaIntReal           = 0;
LET dTotalAdeudInt        = 0;
LET dFactorInt            = 0;
LET dPagoInt              = 0;
LET dPagoIvaInt           = 0;
LET dtIntFechPag          = DATE(1);
LET dTasaCom              = 0;
LET dPagoCapital          = 0;
LET dPagoCom              = 0;
LET dPagoIvaCom           = 0;
LET cFolio                = "";
LET dIntMora              = 0;
LET dIvaIntMora           = 0;
LET dIntVdo               = 0;
LET dIvaIntVdo            = 0;
LET iNumPago              = 0;
LET cIndicador            = "N";
LET dIntDevengado         = 0;
LET dIvaIntDevengado      = 0;
LET dtFechaFinMes         = DATE(1);
LET dtFechaHoy            = DATE(1);
LET dInteFinMes           = 0;
LET dIvaIntFinMes         = 0;
LET dProvInte             = 0;
LET dProvIvaInt           = 0;
LET dtFechaFinMesAnt      = DATE(1);
LET dIntGrav              = 0;
LET dIntExen              = 0;
LET dFechaT               = DATE(1);
LET dMontoPago            = 0;
LET dtFechaProxPago       = DATE(1);
LET cFechaLimite          = "";
LET dtFechaApertura       = DATE(1);
LET dtFechaCompa          = DATE(1);
LET g_Sucursal            = pSucursal;
LET g_Usuario             = pUsuario;
LET cStatusCred           = "";
LET cSucursal             = pSucursal;
LET g_CodFun         	  =  "221";
LET g_CodFunProv          = "606";
LET g_TranCargo    	      = "0227";
LET g_TranCapt			  = "";
LET g_cheque              = 0;
LET g_Leyenda             = "CRG. CTA. ";
LET g_Autoriza            = "";
LET cNomProd    		  = "";
LET cCodRetMarc	        = "";
LET cMensajeRetMarc	   = "";
LET ATR_Cred           = 0;
LET VarAux1            = 0;
LET BanderaIFRS           = '';

--SET DEBUG FILE TO "/tmp/sp_pago_anticipado_rr.out";
--TRACE ON;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-------------------------------------------------------------
-- Transacciones de Pago (Central):                        --
   -- 7462 -- Pago Anticipado Ventanilla.                  --
   -- 7469 -- Pago Anticipado Cargo a Cuenta.              --
   -- 7476 -- Pago Anticipado Salvo Buen Cobro (Cheque).   --
   -- 8335 -- Pago SPEI									   --
-------------------------------------------------------------

IF NVL(g_cEmpresa,"")= "" OR  NVL(g_NumCredito,"") = "" OR NVL(pUsuario,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pTransacc,"") NOT IN ("7462","7469","7476","7431","7970","7998","8205","8286","8335","8701", "4320", "9888") OR NVL(pMonto,0) <= 0 OR NVL(g_Folio,"") = "" THEN
     LET cCodRet      = "00411";
     LET cMensajeRet  = "NO HAY ARGUMENTOS (PARAMETROS)";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
     RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

IF EXISTS (SELECT a.num_credito
             FROM "informix".sd_amortiza_creditocrd a
			WHERE a.empresa     = g_cEmpresa
              AND a.num_credito = g_NumCredito
              AND a.capital_status IN ("1","2","7","6")) THEN
     LET cCodRet      = "00041";
     LET cMensajeRet  = "No es posible recibir el pago anticipado";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
     RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

SELECT a.num_credito,a.numcte,a.tasa_interes,a.fecha_apertura,a.num_producto,a.divisa
  INTO cNumCred,cNumCte,g_dTasaInt,dtFechaApert,cNumProd,cDivisa
  FROM "informix".sd_maecredcrd a
 WHERE a.num_credito = g_NumCredito
   AND a.empresa     = g_cEmpresa;

  
select NVL(valor,'I')
   INTO BanderaIFRS 
   from "informix".sd_param 
   WHERE empresa = '001' 
      AND cod_param='700'; 


SELECT nombre_prod INTO cNomProd
FROM "informix".sd_definicion
WHERE num_producto = cNumProd;

LET g_Leyenda = TRIM(g_Leyenda)||' '||TRIM(NVL(cNomProd,""));

IF cNumCred IS NULL THEN
    LET cCodRet      = "00224";
    LET cMensajeRet  = "NO EXISTE NUMERO DE CREDITO";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
    RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

LET pTransacc = pTransacc;
LET cNumProd = cNumProd;

IF pTransacc IN ("7462","7469","7476","7431","7970","7998","8205","8286","8335","8701", "4320", "9888") THEN
       SELECT transacc_rel  INTO g_CodFun
		FROM "informix".sd_conceptospagomanualcrd
		WHERE transacc = pTransacc
		AND num_producto = cNumProd;
ELSE
		LET cCodRet      = "00189";
		LET cMensajeRet  = "Transaccion incorrecta";
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;

		RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_cEmpresa,g_NumCredito)
             INTO cCodRetAux,cMensajeRet,cCharAux,cCharAux,dtDateAux,dtDateAux,dDecAux,dtDateAux,
                   iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                   dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                   dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotal,dIntDevengado,dIvaIntDevengado,
                   dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
                   cCharAux,cCharAux,iIntAux,cCharAux;

IF cCodRetAux <> "000000" THEN
      LET cCodRet      = "00042";
      LET cMensajeRet  = "Ocurrio un error al obtener el adeudo total del cliente";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

IF pMonto > NVL(dSdoAdeudTotal,0) THEN
      LET cCodRet      = "00043";
      LET cMensajeRet  = "ESTA PAGANDO MAS DE LO QUE DEBE, REALIZAR CONSULTA DE SALDO Y PAGAR IMPORTE";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

SELECT fecha_hoy, ult_dia_mes
  INTO dtFechaHoy, dtFechaFinMes
  FROM "informix".sd_fechas
 WHERE empresa=pEmpresa;

LET g_dtFechaHoy=dtFechaHoy;
--	CALL bdicred:monthadd(dtFechaApert,1) RETURNING dFechaT;
 --   CALL bdicred:sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;

IF pMonto < NVL(dSdoAdeudTotal,0) and pMonto >= NVL(dSdoAdeudTotal-dPagoCom-dPagoIvaCom,0)  THEN --and dtFechaHoy < dFechaT
      LET cCodRet      = "00082";
      LET cMensajeRet  = "El cliente no alcanza a liquidar su comision, por favor realizar consulta de saldo y pagar el importe correspondiente";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

LET dtFechaFinMesAnt=DATE(MDY(MONTH(dtFechaFinMes),'01',YEAR(dtFechaFinMes))-1);

SELECT status_cred
  INTO cStatusCred
  FROM "informix".sd_maecredcrd
 WHERE empresa=pEmpresa
   AND num_credito=g_NumCredito;

--validacion para pago anticipado con cargo a cuenta
IF pTransacc IN ("7431","7998", "9888")  THEN    --> FMV   PAGO ANTICIPADO DE CAPITAL CON CARGO EN CUENTA
	-- Se obtiene la cuenta a la cual se le realizÃÂÃÂ³ el deposito del prÃÂÃÂ©stamo.
	SELECT a.num_cta
	  INTO g_Cuenta
	  FROM "informix".sd_ctascarg a
	 WHERE a.num_credito  = g_NumCredito
	   AND a.empresa      = g_cEmpresa
	   AND a.naturaleza   = "A";

	  IF NVL(g_Cuenta,"") = "" THEN
		  LET cCodRet      = "00044";
	      LET cMensajeRet  = "No se pudo consultar la cuenta efectiva";
           ROLLBACK WORK;

           IF (wBegin = "S") THEN
               BEGIN WORK;
           END IF;
          RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
	  END IF;

	  -- Se obtiene el nÃÂÃÂºmero de tarjeta.
	  SELECT a.num_tarjeta
		INTO g_NumTarjDeb
		FROM bdicheq:"informix".sc_tarjeta a
	   WHERE a.empresa   = g_cEmpresa
		 AND a.cuenta    = g_Cuenta
		 AND a.secuencia = (SELECT MAX(b.secuencia)
							  FROM bdicheq:"informix".sc_tarjeta b
							 WHERE b.empresa      = a.empresa
							   AND b.cuenta       = a.cuenta
							   AND b.secuencia    = b.secuencia
							   AND b.tipo_tarjeta = "T");

		IF g_NumTarjDeb IS NULL THEN
		   LET g_NumTarjDeb = "";
		END IF;

		-- Se obtiene el saldo de la cuenta identificada.
		CALL bdicheq:"informix".cons_saldo(g_Cuenta) RETURNING cCodRetAux,g_SdoCta,g_StatusCtaCap;

		IF (cCodRetAux <> "000") THEN
			 LET cCodRet      = "00187";
			 LET cMensajeRet  = "No es posible obtener el saldo actual de la cuenta cliente";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
             RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;

		-- Valida si el saldo esta activo para poder usarlo .
		IF g_StatusCtaCap <> "1" THEN
		     LET cCodRet      = "00188";
			 LET cMensajeRet  = "El saldo no esta activo para poder usarlo";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
             RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;

		-- Valida el saldo obtenido de la cuenta.
		IF NVL(g_SdoCta,0) <= 0 or NVL(g_SdoCta,0) < pMonto THEN
			 LET cCodRet      = "00050";
			 LET cMensajeRet  = "El saldo no es valido";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
             RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;

		IF pTransacc = "9888" THEN
			LET g_TranCapt = "0551";
			
			EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
											  g_Sucursal,
											  g_Usuario,
											  g_TranCapt,
											  g_TranCapt,
											  g_Folio,
											  g_Cuenta,
											  g_cheque,
											  pMonto,
											  cDivisa,
											  pNumCredito||" "||g_Leyenda,
											  g_NumTarjDeb,
											  g_Autoriza)
						INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;
		ELSE
		  -- Realiza el cargo del adeudo a la cuenta
		  EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
											  g_Sucursal,
											  g_Usuario,
											  g_TranCargo,
											  pTransacc,
											  g_Folio,
											  g_Cuenta,
											  g_cheque,
											  pMonto,
											  cDivisa,
											  pNumCredito||" "||g_Leyenda,
											  g_NumTarjDeb,
											  g_Autoriza)
						INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;
			END IF;
		   IF cCodRetAux <> "000" THEN
			   LET cCodRet      = "00051";
			   LET cMensajeRet  = "Ocurrio un error al aplicar el cargo a la cuenta de captacion";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
               RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
           END IF;
END IF;

SELECT a.iva
  INTO g_dIvaSuc
  FROM bdinteg:"informix".si_sucursales a
 WHERE a.sucursal = cSucursal
   AND a.empresa  = g_cEmpresa;

IF NVL(g_dIvaSuc,0) = 0 THEN
    LET cCodRet      = "00052";
    LET cMensajeRet  = "Ocurrio un error al obtener el iva de la sucursal";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
    RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

SELECT a.sdo_capital + a.cap_tras_no_venci,        -- Saldo Capital
       a.sdo_cap_insoluto,    -- Saldo Capital Insoluto
	   a.provision_normal,     --porciÃÂÃÂ³n que restas de la provisiÃÂÃÂ³n fin de mes de los intereses
	   a.sdo_global_int,      --porciÃÂÃÂ³n que resta de la provisiÃÂÃÂ³n de fin de mes del iva de intereses
       NVL(a.ATR,-1)
  INTO dSdoCapital,
       dCapitalIns,
	   dInteFinMes,
	   dIvaIntFinMes,
       ATR_Cred
  FROM "informix".sd_maesdoscrd a
 WHERE a.num_credito = g_NumCredito
   AND a.empresa     = g_cEmpresa;

    IF dSdoCapital IS NULL THEN LET dSdoCapital = 0; END IF;
    IF dCapitalIns IS NULL THEN LET dCapitalIns = 0; END IF;
    IF dInteFinMes IS NULL THEN LET dInteFinMes=0;   END IF;
    IF dIvaIntFinMes IS NULL THEN LET dIvaIntFinMes = 0; END IF;

    LET dSdoAnt = dSdoCapital;

/*SELECT a.sdo_intereses,        -- intereses a fin de mes
       a.sdo_global_int    -- iva de intereses a fin de mes
  INTO dInteFinMes,
       dIvaIntFinMes
  FROM "informix".sd_maesdoscontcrd a
 WHERE a.fecha = dtFechaFinMesAnt
   AND a.num_credito = g_NumCredito
   AND a.empresa     = g_cEmpresa;

   IF dInteFinMes IS NULL THEN
      LET dInteFinMes=0;
   END IF;

   IF dIvaIntFinMes IS NULL THEN
      LET dIvaIntFinMes = 0;
   END IF;
*/


SELECT a.interes_debe,      -- InterÃÂÃÂ©s Ordinario Vigente
       a.interes_pagado,    -- InterÃÂÃÂ©s Ordinario Vigente Pagado
       a.iva_debe,          -- Iva de InterÃÂÃÂ©s Ordinario Vigente
       a.iva_pagado,        -- Iva de InterÃÂÃÂ©s Ordinario Vigente Pagado
       a.capital_status,    -- Estatus de la Mensualidad
       a.capital_mto_cuota, -- Capital Monto Cuota
       a.num_pago
  INTO dIntDebe,
       dIntPag,
       dIvaDebe,
       dIvaPag,
       cCapStatus,
       dCapMtoCuota,
       iNumPago
  FROM "informix".sd_amortiza_creditocrd a
 WHERE a.empresa         = g_cEmpresa
   AND a.num_credito     = g_NumCredito
   AND a.capital_status  = "3";

         -- Se generaÂ¡ el movimiento uno del anticipo realizado
	    IF g_TransaccSuc ="4320" THEN --MODIFICACION ATM PAGO NORMAL EFECTIVO				    
			-- Se genera el primer movimiento por el total del abono para pagos en ATM.
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,89,g_CodFun,g_dtFechaHoy,pMonto,g_Folio,cSucursal,cDivisa,g_TransaccSuc,"ANTICIPO","")
						RETURNING cCodRetAux, cMensajeRet;
		ELIF g_TransaccSuc = "9888" THEN --MODIFICACION ATM PAGO NORMAL CGO CTA	
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,88,g_CodFun,g_dtFechaHoy,pMonto,g_Folio,cSucursal,cDivisa,g_TransaccSuc,"ANTICIPO","")
						RETURNING cCodRetAux, cMensajeRet;
		ELSE
			-- Se genera el movimiento uno del anticipo realizado
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,1,g_CodFun,g_dtFechaHoy,pMonto,g_Folio,cSucursal,cDivisa,g_TransaccSuc,"ANTICIPO","")
						RETURNING cCodRetAux, cMensajeRet;
		END IF;

    IF (cCodRetAux <> "000000") THEN
         LET cCodRet      = "00053";
         LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de Pago";
           ROLLBACK WORK;

           IF (wBegin = "S") THEN
               BEGIN WORK;
           END IF;
         RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
    END IF;

    LET dMontoPago = pMonto;

   -- Se respalda el crÃÂÃÂ©dito
   IF pbanderarespaldo ='1' AND gRespaldoActivo = '0' THEN
      CALL "informix".sp_respalda_credito_rr(g_cEmpresa, g_NumCredito, USER) RETURNING cCodRetAux;

      IF cCodRetAux <> "000000" THEN
          LET cCodRet      = "00054";
          LET cMensajeRet  = "Ocurrio un error respaldar la informaciÃÂÃÂ³n del crÃÂÃÂ©dito";
           ROLLBACK WORK;

           IF (wBegin = "S") THEN
               BEGIN WORK;
           END IF;
          RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
      END IF;
   END IF;

IF g_dtFechaHoy = dtFechaApert THEN ---????cas
   -- Si se realiza el anticipo en dia de la apertura no realiza cobro de interes ni iva.
   LET dTotalAdeudInt  = 0;
ELSE
    -- Se toma el iva de interes devengado obtenido de la consulta generalizada
     LET dIvaIntReal = dIvaIntDevengado;
     LET dTotalAdeudInt = dIntDevengado + dIvaIntReal;
END IF;

IF dTotalAdeudInt > 0 AND dIntDevengado > 0 THEN
    IF (pMonto <= dTotalAdeudInt) THEN
         LET dFactorInt    = (dIntDebe - dIntPag) / dTotalAdeudInt;
         LET dPagoInt      = ROUND(dFactorInt * pMonto,2);
         LET dPagoIvaInt   = pMonto - dPagoInt;
         LET pMonto        = pMonto - dPagoIvaInt - dPagoInt;
    ELSE
         LET dPagoIvaInt   = dIvaIntReal;
         LET dPagoInt      = dIntDebe - dIntPag;
         LET pMonto        = pMonto - dPagoIvaInt - dPagoInt;
    END IF;

         LET cIndicador = "S";

     -- Se actualizan los intereses e ivas de la amortizaciÃÂÃÂ³n
      UPDATE "informix".sd_amortiza_creditocrd
         SET interes_pagado      = interes_pagado + dPagoInt,
             iva_debe            = iva_debe + dPagoIvaInt,
             iva_pagado          = iva_pagado + dPagoIvaInt,
             interes_fecha_pago  = (CASE WHEN (dPagoInt <= (dIntDebe - dIntPag)) THEN TO_CHAR(g_dtFechaHoy) ELSE interes_fecha_pago END),
             iva_fecha_pago      = (CASE WHEN (dPagoIvaInt = dIvaIntReal) THEN g_dtFechaHoy ELSE iva_fecha_pago END)
       WHERE empresa             = g_cEmpresa
         AND num_credito         = g_NumCredito
         AND capital_status      = "3";

		  IF dInteFinMes > 0 THEN
		     IF dInteFinMes > dPagoInt THEN
		        LET dProvInte = dInteFinMes - dPagoInt;
			 ELSE
			    LET dProvInte = 0;
			 END IF;
		 ELSE
		   LET dProvInte =dInteFinMes;
		END IF;

		 IF dIvaIntFinMes > 0 THEN
		     IF dIvaIntFinMes > dPagoIvaInt THEN
		        LET dProvIvaInt = dIvaIntFinMes - dPagoIvaInt;
			 ELSE
			    LET dProvIvaInt = 0;
			 END IF;
		 ELSE
		   LET dProvIvaInt =dIvaIntFinMes;
		END IF;

     if dProvInte < 0   then let dProvInte = 0; end if;
     if dProvIvaInt < 0 then let dProvIvaInt = 0; end if;

      UPDATE "informix".sd_maesdoscrd
         SET sdo_intereses    = sdo_intereses - dPagoInt,
             sdo_acum_mes_int = sdo_acum_mes_int - dPagoInt,
			 provision_normal = dProvInte,
             sdo_global_int   = dProvIvaInt
       WHERE num_credito      = g_NumCredito
         AND empresa          = g_cEmpresa;

	IF dInteFinMes < dPagoInt THEN
                                                     --> FMV: PAGO ANTICIPADO DE INTERES CON CARGO EN CUENTA
	    LET dProvInte             = dPagoInt - dInteFinMes;
		
		IF g_TransaccSuc = '8701'  THEN
			-- Movimiento contable para reconocimiento de interÃÂÃÂ©s vigente DE QUITAS
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,13,'128',g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;		
		ELSE
			-- Movimiento contable para reconocimiento de interÃÂÃÂ©s vigente
            IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
                IF(cStatusCred='AA') THEN
                    LET VarAux1 = 3;
                ELSE
                    LET VarAux1 = 2;
                END IF;
            ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
                IF(cStatusCred='E1') THEN
                    LET VarAux1 = 3;
                ELIF (cStatusCred='E2') THEN
                    LET VarAux1 = 7078;
                ELSE
                    LET VarAux1 = 2;
                END IF;
            END IF;

			     IF g_TransaccSuc = '9888' AND (VarAux1 = 3 OR VarAux1 = 7078) THEN 
				    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'41','059',g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			             RETURNING cCodRetAux, cMensajeRet;	
				 ELIF g_TransaccSuc = '9888' AND VarAux1 = 2 THEN
				    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'45','059',g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			             RETURNING cCodRetAux, cMensajeRet;	
				 ELSE
				    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,'606',g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			             RETURNING cCodRetAux, cMensajeRet;	
				 END IF;
		END IF;

		IF (cCodRetAux <> "000000") THEN
           LET cCodRet      = "00055";
		   LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable provision de interes vigente";
           ROLLBACK WORK;

           IF (wBegin = "S") THEN
               BEGIN WORK;
           END IF;
           RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;
	END IF;
                                        --> FMV : PAGO ANTICIP DE IVA INTERES VIGENTE CON CARGO EN CTA
	IF dIvaIntFinMes < dPagoIvaInt THEN
		LET dProvIvaInt           = dPagoIvaInt - dIvaIntFinMes;
		IF g_TransaccSuc = '8701'  THEN
			 -- Movimiento contable para reconocimiento de iva de interÃÂÃÂ©s vigente
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,14,'128',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;
		ELSE
			 -- Movimiento contable para reconocimiento de iva de interÃÂÃÂ©s vigente
        IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
            IF(cStatusCred='AA') THEN
                LET VarAux1 = 24;
            ELSE
                LET VarAux1 = 25;
            END IF;
        ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
            IF(cStatusCred='E1') THEN
                LET VarAux1 = 24;
            ELIF (cStatusCred='E2') THEN
                LET VarAux1 = 7084;
            ELSE
                LET VarAux1 = 25;
            END IF;
        END IF;
			
		        IF g_TransaccSuc = '4320' AND (VarAux1 = 24 OR VarAux1 = 7084) THEN
			        CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'40','059',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
                       RETURNING cCodRetAux, cMensajeRet;
				ELIF g_TransaccSuc = '9888' AND VarAux1 = 25 THEN	   
				    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'45','059',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
                       RETURNING cCodRetAux, cMensajeRet;
			    ELSE
			        CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,'222',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
                      RETURNING cCodRetAux, cMensajeRet; 
			    END IF;

		END IF;

		IF (cCodRetAux <> "000000") THEN
			 LET cCodRet      = "00057";
			 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva interes vigente";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
             RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;
	ELIF dPagoIvaInt > 0 AND g_TransaccSuc = '8701'  THEN
	
		 -- Movimiento contable para reconocimiento de iva de interÃÂÃÂ©s vigente
     IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
          LET VarAux1 = 14;
      ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
          LET VarAux1 = 14;
      END IF;

		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,'128',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
		RETURNING cCodRetAux, cMensajeRet;
			
		IF (cCodRetAux <> "000000") THEN
			 LET cCodRet      = "00057";
			 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva interÃÂÃÂ©s vigente";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
             RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;
	END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
                IF dProvInte>0 and dProvIvaInt<=0 then
                    LET dIntGrav = dProvInte;
                    LET dIntExen = 0;
                ELSE
                    LET dIntGrav = dProvIvaInt/g_dIvaSuc;
                    LET dIntExen = dProvInte-dIntGrav;
                END IF;

                IF dIntGrav>0 THEN
                    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,12,g_CodFunProv,g_dtFechaHoy,dIntGrav,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
                    RETURNING cCodRetAux, cMensajeRet;

                    IF (cCodRetAux <> "000000") THEN
                         LET cCodRet      = "00086";
                         LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de InterÃÂÃÂ©s Gravado";
                           ROLLBACK WORK;

                           IF (wBegin = "S") THEN
                               BEGIN WORK;
                           END IF;
          				 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
                    END IF;
                END IF;
                IF dIntExen>0 THEN
                    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,13,g_CodFunProv,g_dtFechaHoy,dIntExen,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
                    RETURNING cCodRetAux, cMensajeRet;

                    IF (cCodRetAux <> "000000") THEN
                         LET cCodRet      = "00087";
                         LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de InterÃÂÃÂ©s Exento";
                           ROLLBACK WORK;

                           IF (wBegin = "S") THEN
                               BEGIN WORK;
                           END IF;
          				 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
                    END IF;
                END IF;
---fin cas, Se agrega el movimiento aplicativo de interes gravable y exento

    -- Movimiento contable pago de interÃÂÃÂ©s vigente
    --> FMV: PAGO DE INTERES VIGENTE EN CARGO A CUENTA

      IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
        IF(cStatusCred='AA') THEN
          LET VarAux1 = 28;
        ELSE
          LET VarAux1 = 30;
        END IF;
      ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
        IF(cStatusCred='E1') THEN
          LET VarAux1 = 1112;
        ELIF (cStatusCred='E2') THEN
          LET VarAux1 = 1114;
        ELSE
          LET VarAux1 = 1121;
        END IF;
      END IF;

		IF g_TransaccSuc = '8701'  THEN
		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,g_CodFun,g_dtFechaHoy,dInteFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
			RETURNING cCodRetAux, cMensajeRet;
		ELIF g_TransaccSuc = '9888' AND (VarAux1 = 28 OR VarAux1 = 1112 OR VarAux1 = 1114 OR VarAux1 = 1121) THEN
			  CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'39','059',g_dtFechaHoy,dInteFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
			   RETURNING cCodRetAux, cMensajeRet;
		ELIF g_TransaccSuc = '9888' AND VarAux1 = 30 THEN
		  CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'43','059',g_dtFechaHoy,dInteFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
		   RETURNING cCodRetAux, cMensajeRet;			   
		ELSE
		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,g_CodFun,g_dtFechaHoy,dPagoInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")  --AEH
			RETURNING cCodRetAux, cMensajeRet;	
		END IF;
	
    IF (cCodRetAux <> "000000") THEN
            LET cCodRet      = "00058";
        LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago interÃÂÃÂ©s vigente";
        ROLLBACK WORK;

        IF (wBegin = "S") THEN
             BEGIN WORK;
        END IF;
        RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
    END IF;

    -- Movimiento Contable Pago de Iva de InterÃÂÃÂ©s Vigente
    --> FMV: PAGO DE IVA DE INTERES VIGENTE EN CARGO A CUENTA

      IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
        IF(cStatusCred='AA') THEN
          LET VarAux1 = 47;
        ELSE
          LET VarAux1 = 45;
        END IF;
      ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
        IF(cStatusCred='E1') THEN
          LET VarAux1 = 1113;
        ELIF (cStatusCred='E2') THEN
          LET VarAux1 = 1115;
        ELSE
          LET VarAux1 = 1122;
        END IF;
      END IF;

		IF g_TransaccSuc = '8701'  THEN
			
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,g_CodFun,g_dtFechaHoy,dIvaIntFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
		RETURNING cCodRetAux, cMensajeRet;
		ELIF g_TransaccSuc = '9888' AND (VarAux1= 47 OR VarAux1 = 1113 OR VarAux1 = 1115 OR VarAux1 = 1122) THEN	
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'40','059',g_dtFechaHoy,dIvaIntFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
			  RETURNING cCodRetAux, cMensajeRet;
		ELIF g_TransaccSuc = '9888' AND VarAux1= 45 THEN	
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'44','059',g_dtFechaHoy,dIvaIntFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
			  RETURNING cCodRetAux, cMensajeRet;						 
		ELSE
		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,g_CodFun,g_dtFechaHoy,dPagoIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
			RETURNING cCodRetAux, cMensajeRet;
		END IF;

    IF (cCodRetAux <> "000000") THEN
         LET cCodRet      = "00059";
         LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva interÃÂÃÂ©s vigente";
          ROLLBACK WORK;

          IF (wBegin = "S") THEN
              BEGIN WORK;
          END IF;
         RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
    END IF;
END IF;
IF pMonto > 0  THEN
  IF pMonto > dSdoCapital THEN
    LET dPagoCapital = dSdoCapital;
    LET pMonto = pMonto - dSdoCapital;
  ELSE
    LET dPagoCapital = pMonto;
    LET pMonto  = 0;
  END IF;
END IF;

IF dPagoCapital > 0 THEN
  -- Actualiza el Saldo a Capital

  IF cStatusCred IN ('AA','E1','E2','E3') or (cStatusCred = 'VP' and BanderaIFRS = 'A') THEN
      UPDATE "informix".sd_maesdoscrd
         SET sdo_capital       = sdo_capital  - dPagoCapital,
             sdo_cap_insoluto  = sdo_cap_insoluto - dPagoCapital
       WHERE num_credito       = g_NumCredito
         AND empresa           = g_cEmpresa;
  END IF;

  IF (cStatusCred='VP' and BanderaIFRS = 'I') THEN
      UPDATE "informix".sd_maesdoscrd
         SET cap_tras_no_venci = cap_tras_no_venci - dPagoCapital,
             sdo_cap_insoluto  = sdo_cap_insoluto - dPagoCapital
       WHERE num_credito       = g_NumCredito
         AND empresa = g_cEmpresa;
  END IF;


     -- Movimiento contable pago capital anticipado
     -- FMV : PAGO ANTICIPADO DE CAPITAL CON CARGO EN CUENTA
     -- FMV 3may13: Validacion CASE de pago de capital Vigente o Vencido en sucursal

      IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
        IF(cStatusCred='AA') THEN
          LET VarAux1 = 10;
        ELSE
          LET VarAux1 = 12;
        END IF;
      ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
        IF(cStatusCred='E1' and ATR_Cred <1 ) THEN
          LET VarAux1 = 1106;
        ELIF(cStatusCred='E1' and ATR_Cred >0 ) THEN
          LET VarAux1 = 1107;
        ELIF (cStatusCred='E2') THEN
          LET VarAux1 = 1108;
        ELSE
          LET VarAux1 = 1118;
        END IF;
      END IF;

	      IF g_TransaccSuc = '9888' AND (VarAux1 = 1106 OR VarAux1 = 10 OR VarAux1 = 12) THEN
		   CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'33','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '4320' AND (VarAux1 = 1106 OR VarAux1 = 10 OR VarAux1 = 12) THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'90','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '9888' AND VarAux1 = 1107 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'34','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '4320' AND VarAux1 = 1107 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'91','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '9888' AND VarAux1 = 1108 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'36','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '4320' AND VarAux1 = 1108 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'93','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '9888' AND VarAux1 = 1118 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'37','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '4320' AND VarAux1 = 1118 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'95','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  
		  ELSE
				CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,g_CodFun,g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
				RETURNING cCodRetAux, cMensajeRet;

		  END IF;	

    IF (cCodRetAux <> '000000') THEN
        LET cCodRet      = "00062";
        LET cMensajeRet  = "OcurriÃÂÃÂ³ un error al registrar el movimiento contable de pago capital anticipado";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
        RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
    END IF;
END IF;

-- FMV 13-MAY-10: Se omite el cargo de comision por pago anticipado de Reestructura

   LET cIndicador = "S";

  SELECT sdo_cap_insoluto
    INTO dSdoCapital
    FROM "informix".sd_maesdoscrd
   WHERE empresa=g_cEmpresa
     AND num_credito=g_NumCredito;

     IF dSdoCapital IS NULL THEN
     	LET dSdoCapital =0;
     END IF;

   IF dSdoCapital <= 0 THEN
			UPDATE "informix".sd_amortiza_creditocrd
               SET capital_status_ant = capital_status,
                   capital_status = "5",
                   capital_pagado = capital_debe
			 WHERE empresa = g_cEmpresa
               AND num_credito = g_NumCredito
               AND fecha_cuota > g_dtFechaHoy;

			UPDATE "informix".sd_maecredcrd
               SET status_cred = "FF",
                   fecha_vencim = g_dtFechaHoy
			 WHERE num_credito = g_NumCredito
               AND empresa = g_cEmpresa;

			UPDATE "informix".sd_maecredanexocrd
               SET prox_fecha_pago=date(1)--,
                  -- fecha_vencim = g_dtFechaHoy
			 WHERE num_credito = g_NumCredito
               AND empresa = g_cEmpresa;
				--SE realiza el marcaje del cliente RQI 27 100 JMAH
				EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',3,cNumCte, pUsuario)
				INTO cCodRetMarc, cMensajeRetMarc;
    END IF;


IF cIndicador = "S" THEN
  UPDATE "informix".sd_maecredanexocrd
     SET fecha_ult_pago  = g_dtFechaHoy
   WHERE num_credito     = g_NumCredito
     AND empresa         = g_cEmpresa;
END IF;

EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_cEmpresa,g_NumCredito)
             INTO cCodRetAux,cMensajeRet,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
                  iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                  dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                  dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dIntDevengado,dIvaIntDevengado,
                  dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
                  cCharAux,cCharAux,iIntAux,cCharAux;

IF cCodRetAux <> "000000" THEN
      LET cCodRet      = "00042";
      LET cMensajeRet  = "Ocurrio un error al obtener el adeudo actual del cliente";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

 EXECUTE PROCEDURE "informix".monthadd(dtFechaApertura,1) INTO dtFechaCompa;
 EXECUTE PROCEDURE "informix".sp_valfechabil(dtFechaCompa,'+') INTO cCodRet, dtFechaCompa;

 IF dtFechaProxPago > DATE(1) THEN
     LET cFechaLimite = DAY(dtFechaProxPago) || ' de ' || DECODE(MONTH(dtFechaProxPago),"1","ene","2","feb","3","mar"
                                                                                        ,"4","abr" ,"5","may","6","jun"
                                                                                        ,"7","jul","8","ago","9","sep"
                                                                                        ,"10","oct","11","nov","12","dic")
                                              || ' de ' || YEAR(dtFechaProxPago);
 ELSE
     LET cFechaLimite = ' ';
 END IF;

 IF g_dtFechaHoy = dtFechaProxPago THEN
    LET cFechaLimite = ' ';
 END IF;

 IF cCodRet = "000"  THEN
    LET cCodRet     = "00000";
    LET cMensajeRet = "Se ejecuto el pago anticipado correctamente";
 END IF;

    IF(cCodRet <> "00000") THEN
        ROLLBACK WORK;
    ELSE
        COMMIT WORK;
    END IF;

    IF (wBegin = "S") THEN
        BEGIN WORK;
    END IF;

 RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");


END PROCEDURE;