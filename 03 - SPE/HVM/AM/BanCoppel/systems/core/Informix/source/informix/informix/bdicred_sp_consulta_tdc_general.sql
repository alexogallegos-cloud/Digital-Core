CREATE PROCEDURE "informix".sp_consulta_tdc_general(pEmpresa      CHAR(3),
                                                    pTransacc     CHAR(4),
													pCentroCosto  CHAR(4),
													pUsuario      CHAR(8),
													pFolio        CHAR(16),
													pNumTarjeta   CHAR(16),
													pCuenta       VARCHAR(20,1),
													pReferencia   VARCHAR(40,1))
RETURNING CHAR(5)         AS codigo_retorno,
          CHAR(4)         AS terminacion_tarjeta,
		  CHAR(60)        AS nombre_cte,
		  DECIMAL(14,2)   AS saldo_total,
		  DECIMAL(14,2)   AS pago_minimo,
		  DECIMAL(14,2)   AS pago_no_generar_interes,
          CHAR(10)	      AS fecha_limite_pago;
		  
DEFINE nrows             INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(5);

DEFINE vCodRet           CHAR(5);
DEFINE vMensaje          VARCHAR(100,1);
DEFINE vCuenta           CHAR(20);
DEFINE vTarjeta          CHAR(20);
DEFINE vNumCte           CHAR(20);
DEFINE vSdoDisponible    DECIMAL(14,2);
DEFINE vNombreCte        CHAR(60);
DEFINE vPagoMin          DECIMAL(14,2);
DEFINE vFechaCorte       CHAR(10);
DEFINE vFechaPago        CHAR(10);
DEFINE vDisponible       DECIMAL(14,2);
DEFINE vSdoRetenido      DECIMAL(14,2);
DEFINE vIntMora          DECIMAL(14,2);
DEFINE vIvaIntMora       DECIMAL(14,2);
DEFINE sFecExp           DATE;
DEFINE vSdoTotal         DECIMAL(14,2);
DEFINE vTerminacion      CHAR(4);

LET nrows                = 0;
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = '';
LET cCodRet              = '000';

LET vCodRet              = '000';
LET vMensaje             = '';
LET vCuenta              = '';
LET vTarjeta             = '';
LET vNumCte              = '';
LET vSdoDisponible       = 0;
LET vNombreCte           = '';
LET vPagoMin             = 0;
LET vFechaCorte          = '';
LET vFechaPago           = '';
LET vDisponible          = 0;
LET vSdoRetenido         = 0;
LET vIntMora             = 0;
LET vIvaIntMora          = 0;
LET sFecExp              = DATE(1);
LET vSdoTotal            = 0;
LET vTerminacion         = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
		LET vCodRet = iSqlErr;
		RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/paulq/sp_consulta_tdc_general.out';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

IF NOT EXISTS( SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
	LET vCodRet = "1070";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF NOT EXISTS(SELECT numero FROM bdinteg:"informix".si_transacc WHERE sistema = '06' and numero = pTransacc) THEN
	LET vCodRet = "1071";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF TRIM(NVL(pCentroCosto,'')) = '' THEN 
	LET vCodRet = "1072";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF TRIM(NVL(pUsuario,'')) = '' THEN
	LET vCodRet = "1073";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF TRIM(NVL(pFolio,'')) = '' THEN
	LET vCodRet = "1074";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF TRIM(NVL(pReferencia,'')) = '' THEN
	LET vCodRet = "1075";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

IF TRIM(NVL(pNumTarjeta,'')) = '' AND TRIM(NVL(pCuenta,'')) = '' THEN
	LET vCodRet = "1076";
	RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;
END IF;

CALL "informix".cons_sdos2 (pEmpresa,pCuenta,pNumTarjeta)
RETURNING vCodRet, vCuenta, vTarjeta, vNumCte, vSdoDisponible,
		  vNombreCte, vPagoMin, vFechaCorte, vFechaPago, vDisponible,
		  vSdoRetenido, vIntMora, vIvaIntMora, sFecExp;
	
	IF vCodRet = "000" THEN
	    LET vTerminacion = SUBSTR(vTarjeta,LENGTH(vTarjeta)-3,LENGTH(vTarjeta));
		
		CALL "informix".sp_consultasaldocortemin(pEmpresa,vCuenta,2)
		RETURNING vCodRet, vSdoTotal;
		
		IF vCodRet = "00000" AND TRIM(pReferencia) <> 'CON' THEN 
			CALL "informix".genmov(pEmpresa,vCuenta,'6001',0,'000',TODAY,0,pFolio,pCentroCosto,'01',pTransacc)
			RETURNING vCodRet, vMensaje;
		END IF;
	END IF;		  
	
IF vCodRet = "00000" THEN
  LET vCodRet = "000";
END IF;

IF vSdoDisponible < 0 THEN
  LET vSdoDisponible = 0;
END IF;

IF vPagoMin < 0 THEN
  LET vPagoMin = 0;
END IF;

IF vSdoTotal < 0 THEN
  LET vSdoTotal = 0;
END IF;
	
RETURN vCodRet, vTerminacion, vNombreCte, vSdoDisponible, vPagoMin, vSdoTotal, vFechaPago;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento realizar invocar la',
'consulta de saldos TDC',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 08/09/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obtener_prospectos_aumlincred_ofi
(
	pEmpresa CHAR(3),	
	pSucursal  CHAR(4),
	pNumCredito CHAR(20),
	pNumProd	CHAR(4),
	pNumcte    CHAR(20),
	pNumcte_cop CHAR(20),
	pLincredSolicitada DECIMAL(18,2),
	pComprobanteIngresos  CHAR(2),
	pMensaje CHAR(250),
	pFechaHoyAumlincred DATE,
	pEjecutivo CHAR(8),
	pIngresoMensual DECIMAL(18,2)
)
RETURNING CHAR(6)  AS codigo_retorno, CHAR(80) AS mensaje_retorno;           
          
DEFINE cCodRet     CHAR(6); 
DEFINE cMensajeRet CHAR(150);
DEFINE iSqlErr     INTEGER;
DEFINE iIsamErr    INTEGER;
DEFINE cErrorInfo  CHAR(80);
DEFINE dMontoOtor  DECIMAL(18,2);
DEFINE iBandera INTEGER;
DEFINE cOrigen CHAR(1);

LET cCodRet      = "000000";
LET cMensajeRet  = "Se realizÃ³ la consulta correctamente";
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET cErrorInfo   = "";
LET dMontoOtor   = 0;
LET iBandera = 0;
LET cOrigen = "S";


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
       LET cCodRet= iSqlErr;
       LET cMensajeRet= cErrorInfo;
       RETURN cCodRet, cMensajeRet;     
   END IF;
END EXCEPTION;


--SET DEBUG FILE TO '/informix/jesus/incrementos/sp_obtener_prospectos_aumlincred_ofi.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,"") = ""  OR NVL(pSucursal,"") = "" OR NVL(pNumCredito,"") = "" OR NVL(pNumcte,"") = "" 
	OR NVL(pLincredSolicitada,0) = 0 OR NVL(pComprobanteIngresos,"") = "" THEN
		LET cCodRet                  = '000001';
		LET cMensajeRet              = 'Parametro requerido esta vacio';
		RETURN cCodRet, cMensajeRet;
	END IF;
 	
	IF NOT EXISTS (SELECT num_solicitud FROM  "informix".sd_bitacora_aumlincred WHERE  empresa = pEmpresa AND   num_solicitud = pNumCredito AND  numcte =  pNumcte AND  fecha_insert =  pFechaHoyAumlincred   ) THEN	
	
		SELECT b.monto_otorgado
		INTO dMontoOtor
		FROM "informix".sd_maecred a 
		INNER JOIN "informix".sd_maesdos b ON a.empresa = b.empresa AND a.num_credito = b.num_credito
		WHERE a.empresa     = pEmpresa
		AND a.num_credito = pNumCredito;
		
			

IF EXISTS(SELECT ejecutivo FROM "informix".sd_perfiles_cac_aumlincred where empresa = 	pEmpresa AND ejecutivo = pEjecutivo) 
	THEN
		LET cOrigen = 'C';
	ELSE
		LET cOrigen = 'S';
	END IF

	
		INSERT INTO  "informix".sd_bitacora_aumlincred (empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status, hora_status, sucursal,lincred_actual, lincred_sugerida, smb_lincred,grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert,	fecha_insert,	numcte_cop, lincred_solicitada, comp_ingreso)	
		VALUES (pEmpresa, pNumCredito, pNumcte, pNumProd, "PC", "",pFechaHoyAumlincred, CURRENT, pSucursal, dMontoOtor, 0, 0, "", 0,"","",pMensaje,"","",cOrigen, pEjecutivo, pFechaHoyAumlincred,pNumcte_cop,pLincredSolicitada,pComprobanteIngresos);		
		
		INSERT INTO "informix".sd_autorizacion_aumlincred
		(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
		VALUES(pEmpresa, pNumCredito, "PC", "", pEjecutivo, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
		
		UPDATE bdisolic:"informix".ss_resum_scor_fin
			SET ingreso_mensual = pIngresoMensual
		WHERE num_solicitud = pNumCredito;
		
		EXECUTE PROCEDURE "informix".sp_identificar_clientes_ofi(pEmpresa,pNumCredito)
		INTO cCodRet, cMensajeRet;
	END IF
     
RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para el registro de la solicitud de incremento de clientes desde sucursal',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 08/Noviembre/2011',
'BD    : BDICRED',
'Modificacion: Se agrega el monto otorgado en el campo lincred_actual de la bitacora en lugar de insertarlo en cero.',
'AUTOR : Mohamed CarreÃ³n',
'FECHA : 25/Julio/2012',
'BD    : bdicred',
'VERSION:20120826.0940',
'Modificacion:  se  agrega  validacion  para que verifÃ­que  que exista registro en la tabla  "informix".sd_bitacora_aumlincred antes de insertarlo',
'AUTOR :  Mario Gallardo',
'FECHA : 17/05/2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_obteninfosolincred_mc(pEmpresa CHAR(3), pNumCredito CHAR(20), pNumcte CHAR(20))
														   
RETURNING CHAR(6)           AS cod_ret,
          VARCHAR(107,1)    AS mensaje_ret,
	      VARCHAR(20,1)     AS numero_credito,
		  VARCHAR(20,1)     AS numero_cte,
		  VARCHAR(4,1)      AS sucursal,
		  VARCHAR(4,1)      AS numero_producto;	

DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      VARCHAR(255,1);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(107,1);

DEFINE vNumCredito     VARCHAR(20,1);
DEFINE vNumcte         VARCHAR(20,1);
DEFINE vSucursal       VARCHAR(4,1);
DEFINE vNumProd        VARCHAR(4,1);

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET cMensajeRet        = "CONSULTA EXITOSA";

LET vNumCredito        = "";
LET vNumcte            = "";
LET vSucursal          = "";
LET vNumProd           = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN NVL(cCodRet,''),NVL(cMensajeRet,''), NVL(vNumCredito,''), NVL(vNumcte,''), NVL(vSucursal,''), NVL(vNumProd,'');
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/paulq/sp_obteninfosolincre_mc.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR (NVL(pNumCredito,"") = "" AND NVL(pNumcte,"") = "" ) THEN
	 LET cCodRet = "000001";
	 LET cMensajeRet = "PARAMETROS DE ENTRADA INVALIDOS";
	 RETURN NVL(cCodRet,''),NVL(cMensajeRet,''), NVL(vNumCredito,''), NVL(vNumcte,''), NVL(vSucursal,''), NVL(vNumProd,'');
	END IF;

	IF TRIM(NVL(pNumCredito,'')) = '' THEN LET pNumCredito = ''; END IF;
	IF TRIM(NVL(pNumcte,'')) = '' THEN LET pNumcte = ''; END IF;
	
	FOREACH WITH HOLD
	SELECT LIMIT 1 num_credito,numcte,sucursal,num_producto
	  INTO vNumCredito, vNumcte, vSucursal, vNumProd
      FROM "informix".sd_maecred
     WHERE empresa = pEmpresa
       AND num_credito =  (CASE WHEN pNumCredito > '' THEN pNumCredito ELSE num_credito END)
       AND numcte = (CASE WHEN pNumcte > '' THEN pNumcte ELSE numcte END)	   
	   
	   RETURN NVL(cCodRet,''),NVL(cMensajeRet,''), NVL(vNumCredito,''), NVL(vNumcte,''), NVL(vSucursal,''), NVL(vNumProd,'') WITH RESUME;
	   
    END FOREACH;
	   
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		 LET cCodRet = "000002";
		 LET cMensajeRet = "NO HAY INFORMACIÒN CON EL FILTRO INDICADO";
		 RETURN NVL(cCodRet,''),NVL(cMensajeRet,''), NVL(vNumCredito,''), NVL(vNumcte,''), NVL(vSucursal,''), NVL(vNumProd,'');
	END IF;	
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para la informaciòn de la solicitud.',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 01/OCT/2016',
'BD: BDICRED',
'VERSION:20161001.0001';

CREATE PROCEDURE "informix".cargoref_tc_ofi(o_empresa  CHAR(3),
				 o_sucursal CHAR(4),
				 o_usuario  CHAR(8),
				 o_tarjeta  CHAR(20),
				 o_monto    DECIMAL(14,2),
				 o_folio    CHAR(16),
				 o_transuc  CHAR(4))

RETURNING CHAR(5),       -- Codigo Retorno
	  DECIMAL(14,2), -- Saldo Disponible 
          DECIMAL(14,2), -- Importe Cargado
	  DECIMAL(14,2), -- Importe Comision
          DECIMAL(14,2); -- Iva de Comisiones

-- **************************************************************************
-- *                      DEFINICION DE VARIABLES                           *
-- **************************************************************************
DEFINE cod_ret            CHAR(5);
DEFINE cod_ret2           CHAR(5);
DEFINE sql_err            SMALLINT;
DEFINE isam_err           SMALLINT;
DEFINE error_info         CHAR(40);
DEFINE Saldo              MONEY(14,2);
DEFINE SaldoCom           MONEY(14,2);
DEFINE v_monto		      MONEY(14,2);
DEFINE v_codparam	   	  CHAR(4);
DEFINE v_fecha            DATE;
DEFINE v_num_credito      CHAR(20);
DEFINE v_divisa		  	  CHAR(2);
DEFINE MtoCgo		  	  MONEY(14,2);
DEFINE MtoCom		   	  MONEY(12,2);
DEFINE v_faplica          CHAR(1);
DEFINE v_factor		 	  DECIMAL(9,6);
DEFINE v_rangos		 	  CHAR(1);
DEFINE v_rmax	          MONEY(14,2);
DEFINE vIva		  		  MONEY(14,2);
DEFINE dMonto		 	  DECIMAL(18,2);
DEFINE cFolioPromo		  CHAR(16);
DEFINE cCodRetGenMov	  CHAR(10);
DEFINE cMsjeGenMov		  CHAR(80);
DEFINE v_dv               CHAR(2);
DEFINE v_tipocambio       DECIMAL(14,6);
DEFINE vsucorig           CHAR(4);
DEFINE vBloqueo           INTEGER;
DEFINE dfh_pre_devol_an   DATE;
DEFINE dfh_devol_an       DATE;
DEFINE dSdoCapInsol       DECIMAL(18,2);
DEFINE cCodRetDevol		  CHAR(5);
DEFINE cMen_retDevol      CHAR(80);
DEFINE dMntoDevol         DECIMAL(16,2);

-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "CargoLineaCredito.err";
--   TRACE sql_err||" * "||isam_err||" * "||error_info;
   LET cod_ret = sql_err;
   LET Saldo = 0;
   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
END EXCEPTION;



-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET cod_ret             = "000";
LET Saldo               = 0;
LET cod_ret2            = "000";
LET SaldoCom            = 0;
LET MtoCgo              = 0;
LET MtoCom              = 0;
LET vIva                = 0;
LET dMonto              = 0;
LET cFolioPromo         = "";
LET cCodRetGenMov		= "";
LET cMsjeGenMov		    = "";
LET v_dv                = "00";
LET v_tipocambio        = 0;
LET vsucorig            ="";
LET vBloqueo            = 0;
LET dfh_pre_devol_an    = date(1);
LET dfh_devol_an        = date(1);
LET dSdoCapInsol = 0;
LET cCodRetDevol		= "";
LET cMen_retDevol       = ""; 
LET dMntoDevol          = 0;

--SET DEBUG FILE TO "/tmp/cargofi.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	-- **************************
	-- **************************
	SELECT a.num_credito, b.divisa, b.sucursal, b.id_unidad_prod
	  INTO v_num_credito, v_divisa, vsucorig,   vBloqueo
	  FROM bdicred:"informix".sd_tarjeta a, bdicred:"informix".sd_maecred b
	 WHERE a.empresa = o_empresa
	   AND a.num_tarjeta = o_tarjeta
	   AND b.empresa = a.empresa
	   AND b.num_credito = a.num_credito;

	IF v_num_credito IS NULL THEN
		LET cod_ret = "008";
	        RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
	END IF

	EXECUTE PROCEDURE bdicred:"informix".cargo_ref_cel(o_tarjeta, o_sucursal, o_usuario,
					o_transuc, o_transuc,  o_folio,
					v_num_credito, 1, o_monto, 0,
					" ", " ", v_divisa, "",  
					o_sucursal, o_usuario, "",
					"", "", v_num_credito,
					1, 0, v_divisa, " ", "2",
					"F"," ", " ", " ", 0, 0, " ", " ")
	INTO cod_ret, v_codparam, v_fecha, Saldo, MtoCgo, 
	     cod_ret2, v_codparam, v_fecha, SaldoCom, MtoCom;

	SELECT SUM(monto_com) INTO vIva 
          FROM bdicred:"informix".sd_detcomi
	 WHERE num_credito = v_num_credito
           AND cod_comis IN ("6260","6261")
	   AND num_solicitud = o_folio
           AND empresa = o_empresa
	   AND num_credito=v_num_credito;

	SELECT SUM(monto_com) INTO MtoCom 
          FROM bdicred:"informix".sd_detcomi
	 WHERE num_credito = v_num_credito
           AND cod_comis IN ("6902","6901")
	   AND num_solicitud = o_folio
           AND empresa = o_empresa
	   AND num_credito=v_num_credito;

       SELECT sdo_cap_insoluto + sdo_retenido    
         INTO SaldoCom                        
         FROM bdicred:"informix".sd_maesdos                         
        WHERE empresa = o_empresa
          AND num_credito=v_num_credito;

	IF MtoCom IS NULL THEN
		LET MtoCom = 0;
		LET vIva   = 0;
	END IF
	
	--JMAH 
	-- OBTIENE EL FOLIO DE LA PROMOCION Y EL MONTO DE LOS INTERESES DE CREDISOLUCIONES
	SELECT folio_movto, monto_int_iva
	INTO cFolioPromo, dMonto
	FROM bdicred:"informix".sd_promocion_credito
	WHERE num_credito = v_num_credito 
	AND folio_movto = o_folio 
	AND status = 6;
	-- VALIDA SI EL CARGO TUVO UNA CREDISOLUCION DE EFECTIVO LIGADA
	IF NVL(cFolioPromo,"") <> "" THEN

        SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;

		SELECT precio_venta INTO v_tipocambio
	          FROM bdinteg:si_tpcambio
		 WHERE empresa = "001"
		   AND divisa = v_dv
		   AND clase_tpcambio = "O"
		   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
					   FROM bdinteg:si_tpcambio
					  WHERE empresa = "001"
					    AND divisa = v_dv);

		UPDATE bdicred:"informix".sd_maesdos SET sdo_retenido = sdo_retenido + dMonto
		WHERE empresa = o_empresa
		AND num_credito = v_num_credito;

		INSERT INTO bdicred:"informix".sd_maeretenido
		(empresa, num_credito, folio_suc, fecha, hora, transacc, dias_ret,monto, usuario, estatus, referencia, sucursal, dias_ori)
		VALUES(o_empresa, v_num_credito, o_folio, CURRENT, CURRENT HOUR TO FRACTION(3),"6837", 0, dMonto, o_usuario, "R", trim(cFolioPromo) || ' RET. CREDISOLUCIONES', o_sucursal, 0);	
		
		UPDATE bdicred:"informix".sd_promocion_credito
			SET status = 0
		WHERE num_credito = v_num_credito
		AND folio_movto = o_folio;		

--     GENERAMOS EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES
		EXECUTE PROCEDURE bdicred:"informix".genmov_tc('001',v_num_credito,'6001',TODAY,dMonto,o_folio,o_sucursal,v_divisa,'6837',o_tarjeta,'RET. CREDISOLUCIONES',v_tipocambio,0,o_usuario,vsucorig,'','')
		INTO cCodRetGenMov, cMsjeGenMov;

	END IF;

	-- Devolucion anualidad RQM 10 850 INI
	-- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad
	SELECT nvl(date(ind.fecha_pre_devol_anual),date(1)), nvl(date(ind.fecha_devol_anual),date(1)), dos.sdo_cap_insoluto 
      INTO dfh_pre_devol_an,                       dfh_devol_an,                       dSdoCapInsol
      FROM bdicred:sd_indicador_cred ind JOIN bdicred:sd_maesdos dos ON (ind.empresa = dos.empresa and ind.num_credito = dos.num_credito )
     WHERE ind.empresa = '001' AND ind.num_credito = v_num_credito;
	 
	-- Si el credito tiene devolucion de anualidad, y el retiro termino correctamente, que proceda a marcar el credito como devolucion realizada.
	IF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) = date(1) AND dSdoCapInsol = 0 THEN
		-- Reinicia fecha para validaciones correctas en caso de retiro despues de un reverso del 1er retiro.
        EXECUTE PROCEDURE "informix".sp_comision_anual_devolucion(o_empresa, v_num_credito, o_usuario) INTO cCodRetDevol, cMen_retDevol, dMntoDevol;
		IF (cCodRetDevol = '00000' OR cCodRetDevol = '1208') AND dMntoDevol = 0 THEN
            LET cod_ret = '1208'; -- Retiro de devolucion correcto. Credito se cancelara.
			--LET cod_ret = '0000'; -- Retiro de devolucion correcto. Credito se cancelara.
		END IF

	END IF;
	-- Devolucion anualidad RQM 10 850 FIN

   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica para contemplar movimientos diferidos, en el proceso de realizar el cargo al crédito', 
'AUTOR: Jesús Aguilar ',
'FECHA: 08 FEBRERO 2012',
'BD: BDICRED',
'DESCRIPCION MODIFICACION: Se cambia el proceso para que guarde la transaccion 6837 en los retenidos de los intereses en lugar de la transaccion de disposición',
'MODIFICO: Mohamed Carreón',
'VERSION: 20120607.0919';

CREATE PROCEDURE "informix".sp_ticket_credisoluciones (pEmpresa CHAR(3), pfolioSuc CHAR(20))
RETURNING CHAR (5)      AS CodRet,
		  CHAR (104)    AS Nombre,
		  CHAR (20)     AS CrediSoluccion,
		  CHAR (20)     AS Cliente,
		  DECIMAL(18,2) AS Monto,
		  CHAR (20)     AS Cuenta,
		  DECIMAL(18,2) AS SaldoActual,
		  DATE          AS FechaProximo,
		  INT           AS Tipo;
		  

	DEFINE iSqlErr       INT;
	DEFINE cCodRet       CHAR(5);	  
	DEFINE cNombre       CHAR(104);
    DEFINE cCrediSol     CHAR(20);
	DEFINE cCrediSol2    CHAR(20);
	DEFINE cCliente      CHAR(20);
	DEFINE cCliente2     CHAR(20);
	DEFINE dMonto        DECIMAL(18,2);
	DEFINE dMonto2       DECIMAL(18,2);
	DEFINE cCuenta       CHAR(20);
	DEFINE cCuenta2      CHAR(20);
	
	DEFINE cNombre1      CHAR(26);
	DEFINE cNombre2      CHAR(26);
	DEFINE cApPat        CHAR(26);
	DEFINE cApMat        CHAR(26);
	
	DEFINE dSaldoActual  DECIMAL(18,2);
	DEFINE dSaldoActual2 DECIMAL(18,2);
	DEFINE dfechaproxi   DATE;
	DEFINE dfechaproxi2  DATE;
	DEFINE ctransac      CHAR(4);
	DEFINE iTipo         INT;
	
	LET iSqlErr       = 0;
	LET cCodRet       = '00000';	  
	LET cNombre       = '';
    LET cCrediSol     = '';
	LET cCrediSol2    = '';
	LET cCliente      = '';
	LET cCliente2     = '';
	LET dMonto        = 0.00;
	LET dMonto2       = 0.00;
	LET cCuenta       = '';
	LET cCuenta2      = '';
	
	LET cNombre1      = '';
	LET cNombre2      = '';
    LET cApPat        = '';	
	LET cApMat        = '';	  
		  
	LET dSaldoActual  = 0.00;
	LET dSaldoActual2 = 0.00;
	LET dfechaproxi   = DATE(1);
	LET dfechaproxi2  = DATE(1);
	LET ctransac 	  = '';
	LET iTipo         = 0;
	  
--SET DEBUG FILE TO '/respaldosbd/felipe/sp_ticket_credisoluciones_test.out';
--TRACE ON;  
BEGIN
    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet, cNombre, cCrediSol, cCliente, dMonto, cCuenta, dSaldoActual, dfechaproxi, iTipo;
       END IF;
    END EXCEPTION;
		  
		  
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;		  
		  
	IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pfolioSuc,'')) <> '' THEN
	
		SELECT num_credito, monto
		INTO cCrediSol2, dMonto2
		FROM bdicred:"informix".sd_movdiacrd 
		WHERE folio_suc = pfolioSuc 
		AND codigo_ref= 1;
		
		IF TRIM(NVL(cCrediSol2,'')) <> '' THEN
			
			SELECT b.numcte, b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno 
			INTO cCliente2, cNombre1, cNombre2, cApPat, cApMat
			FROM bdicred:"informix".sd_promocion_credito a, bdinteg:"informix".si_cliente b
			WHERE a.num_cte = b.numcte
			AND a.empresa = b.empresa
			AND a.empresa = pEmpresa
			AND a.num_sol_prestamo = cCrediSol2; 
			
			IF TRIM(NVL(cNombre1,'')) <> '' AND TRIM(NVL(cApPat,'')) <> '' THEN
				
				SELECT saldo_actual, fechaproximopago, transaccion
				INTO dSaldoActual2, dfechaproxi2, ctransac
				FROM bdicred:"informix".sd_pago_anticipado_cs
				WHERE empresa = pEmpresa
				AND folio_suc = pfolioSuc;
				
				IF TRIM(NVL(ctransac,'')) <> '' THEN
					
					IF TRIM(NVL(ctransac,'')) = '618' THEN --efectivo
						LET iTipo = 1;
					ELIF TRIM(NVL(ctransac,'')) = '623' THEN-- cargo
						LET iTipo = 2;
					END IF;
					
					IF iTipo = 2 THEN
						SELECT cuenta
						INTO cCuenta2
						FROM bdicheq:"informix".sc_movdia
						WHERE empresa = pEmpresa
						AND folio_suc = pfolioSuc;
					END IF;
				
					LET cNombre = TRIM(NVL(cNombre1,'')) || ' ' || TRIM(NVL(cNombre2,''));
					LET cNombre = TRIM(cNombre) || ' ' || TRIM(NVL(cApPat,'')) || ' ' || TRIM(NVL(cApMat,''));
					LET cNombre = TRIM(cNombre);
					LET cCrediSol = cCrediSol2;
					LET cCliente = cCliente2;
					LET dMonto = dMonto2;
					LET cCuenta = cCuenta2;
					LET dSaldoActual = dSaldoActual2;
					LET dfechaproxi = dfechaproxi2;
					
					RETURN cCodRet, NVL(cNombre,''), NVL(cCrediSol, ''), NVL(cCliente, ''), NVL(dMonto, 0.00), NVL(cCuenta, ''), NVL(dSaldoActual, 0.00), NVL(dfechaproxi, DATE(1)), NVL(iTipo,0);
				ELSE
					LET cCodRet = '00004';
				END IF;
			ELSE
				LET cCodRet = '00003';
			END IF;
		ELSE
			LET cCodRet = '00002';
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	
	IF cCodRet <> '00000' THEN
		RETURN cCodRet, NVL(cNombre,''), NVL(cCrediSol, ''), NVL(cCliente, ''), NVL(dMonto, 0.00), NVL(cCuenta, ''), NVL(dSaldoActual, 0.00), NVL(dfechaproxi, DATE(1)), NVL(iTipo,0);
	END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: se crea para datos para la reimpresion de ticket de pago de credisoluciones',
'AUTOR : Felipe Urias',
'FECHA : 28/11/2015',
'BD    : bdicred';

CREATE PROCEDURE "informix".totcomp(o_empresa CHAR(3), o_usuario CHAR(8), o_sucursal CHAR(4), o_num_total SMALLINT)

	RETURNING	CHAR(5),
				CHAR(2),
				MONEY(16, 2),
				MONEY(16, 2),
				MONEY(16, 2),
				MONEY(16, 2),
				CHAR(40),
				INTEGER,
				INTEGER,
				INTEGER,
				INTEGER;

	-- ============================================================================
	-- =                        DEFINICION DE VARIABLES                           =
	-- ============================================================================
	DEFINE v_monto_cargo		MONEY(16, 2);
	DEFINE v_monto_firme		MONEY(16, 2);
	DEFINE v_monto_firme_crd 	MONEY(16, 2);
	DEFINE v_monto_sbc			MONEY(16, 2);
	DEFINE v_monto_rem			MONEY(16, 2);
	DEFINE v_movto_cargo		INTEGER;
	DEFINE v_movto_firme		INTEGER;
	DEFINE v_movto_firme_crd	INTEGER;
	DEFINE v_movto_sbc			INTEGER;
	DEFINE v_movto_rem			INTEGER;
	DEFINE v_descripcion		CHAR(40);
	DEFINE v_contador			SMALLINT;
	DEFINE v_fecha				DATE;
	DEFINE v_row				INTEGER;
	DEFINE v_codret				CHAR(5);
	DEFINE v_empresa			CHAR(3);
	DEFINE w_plaza				CHAR(3);
	DEFINE w_sucursal			CHAR(4);
	DEFINE v_producto			CHAR(4);
	DEFINE v_ciclo				SMALLINT;
	DEFINE v_divisa				CHAR(2);
	DEFINE v_cal_int_chq		CHAR(1);
	DEFINE sql_err				INTEGER;
	DEFINE v_usuario			CHAR(8);
	DEFINE v_existe				CHAR(1);
	DEFINE iContador			INTEGER;

	-- ============================================================================
	-- =                        ASIGNACION DE VALORES                             =
	-- ============================================================================
	LET v_monto_cargo		= 0;
	LET v_monto_firme		= 0;
	LET v_monto_firme_crd 	= 0;
	LET v_monto_sbc			= 0;
	LET v_monto_rem			= 0;
	LET v_movto_cargo		= 0;
	LET v_movto_firme		= 0;
	LET v_movto_firme_crd	= 0;
	LET v_movto_sbc			= 0;
	LET v_movto_rem			= 0;
	LET v_descripcion		= "";
	LET v_contador			= 0;
	LET v_fecha				= DATE(1);
	LET v_row				= 0;
	LET v_codret			= "00000";
	LET v_empresa			= "";
	LET w_plaza				= "";
	LET w_sucursal			= "";
	LET v_producto			= "";
	LET v_ciclo				= 0;
	LET v_divisa			= "";
	LET v_cal_int_chq		= "";
	LET sql_err				= 0;
	LET v_usuario			= "";
	LET v_existe			= "";
	LET iContador			= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/totcomp.out";
	--TRACE ON;

	--"223" Efectivo, pago normal.
	--"020" Efectivo, pago anticipado prestamo personal.
	--"221" Efectivo, pago anticipado reestructura.

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_coDret = sql_err;
					RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, v_descripcion,
					v_movto_cargo, v_movto_firme, v_movto_sbc, v_movto_rem;
			END IF
		END EXCEPTION;

		SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy INTO v_fecha
		FROM bdicred:sd_fechas WHERE empresa = o_empresa;

		FOREACH WITH HOLD

			SELECT divisa, descripcion INTO v_divisa, v_descripcion
			FROM bdinteg:"informix".si_divisas WHERE divisa = divisa AND empresa = o_empresa

			SELECT {+INDEX(sd_movdia idx_movdia2)}
			NVL(SUM(CASE WHEN codigo_fun = '002' THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun = '002' THEN 1 END), 0),
			NVL(SUM(CASE WHEN codigo_fun IN ('033', '333', '067') THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun IN ('033', '333','067') THEN 1 END), 0),
			NVL(SUM(CASE WHEN codigo_fun = "336" AND codigo_ref = 20 THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun = "336" AND codigo_ref = 20 THEN 1 END), 0)
			INTO v_monto_cargo,
			v_movto_cargo,
			v_monto_firme,
			v_movto_firme,
			v_monto_sbc,
			v_movto_sbc
			FROM bdicred:"informix".sd_movdia a
			WHERE usuario = o_usuario
			AND sucursal = o_sucursal
			AND ((codigo_fun IN ("033", "333", "067") AND codigo_ref = 1)
			OR (codigo_fun = "336" AND codigo_ref = 20)
			OR (codigo_fun = "002" AND codigo_ref IN (50, 60)))
			AND reversado <> "S"
			AND fecha_mov = v_fecha
			AND empresa = o_empresa
			AND divisa = v_divisa;
			--AAME 07/03/2017 RQM 10 282 Se contemplan codigo fun de pagos anticipados de credisolucion 076 y 077 desde la caja
			SELECT {+INDEX(sd_movdiacrd idx_movdiacrd2)}
			NVL(SUM(CASE WHEN codigo_fun IN ('027','028','225','077') THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun IN ('027','028','225','077') THEN 1 END), 0)
			INTO v_monto_firme_crd,
			v_movto_firme_crd
			FROM bdicred:"informix".sd_movdiacrd a
			WHERE usuario = o_usuario
			AND sucursal = o_sucursal
			AND (codigo_fun IN ("027","028","225","077") AND codigo_ref = 1)
			AND reversado <> "S"
			AND fecha_mov = v_fecha
			AND empresa = o_empresa
			AND divisa = v_divisa;

			LET v_monto_firme = NVL(v_monto_firme,0) + NVL(v_monto_firme_crd,0);
			LET v_movto_firme = NVL(v_movto_firme,0) + NVL(v_movto_firme_crd,0);

			IF NOT (v_monto_cargo = 0 AND v_movto_cargo = 0 AND v_monto_firme = 0 AND v_movto_firme= 0
			AND v_monto_sbc = 0 AND v_movto_sbc = 0 ) THEN
				LET iContador = iContador + 1;
				RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, TRIM(v_descripcion),
				v_movto_cargo, v_movto_firme, v_movto_sbc, v_movto_rem WITH RESUME;
			END IF;
		END FOREACH;    

		--IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		--	LET v_codret = "00001"; --"No existen divisas cargadas en el catalogo para iniciar las consultas.";
		--ELIF iContador = 0 THEN
		--	LET v_codret = "00002"; --"No existe información con las divisas consultadas.";
		--END IF;

		--IF v_codret <> "00000" THEN
		--	RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, TRIM(v_descripcion),
		--	v_movto_cargo, v_movto_firme, v_movto_sbc, v_movto_rem;
		--END IF;
	END
END PROCEDURE
DOCUMENT
'Fecha: 17/06/2011',
'Modifico: Paul Ivan Quintero Varela',
'Observaciones: Se modifica para contemplar los pagos de préstamo personal',
'pago de anticipo y los pagos de reesturctura para obtener el total de',
'pagos de este proceso del totales de computador.';

CREATE PROCEDURE "informix".sp_gen_arch_auto_sinrecogertc_vencidas(pEmpresa CHAR(3))
RETURNING CHAR(5) AS CodigoRetorno, 
		  CHAR(80) AS Mensaje;	

DEFINE cod_ret     CHAR(5);
DEFINE sql_err     SMALLINT;
DEFINE vMen        CHAR(80);
DEFINE cErrorInfo  CHAR(80);
DEFINE iIsamErr    SMALLINT;
DEFINE  dtFechaHoy     	DATE;
DEFINE  cNomArchivo 	CHAR(50);
DEFINE  cSQL            CHAR(4000);
DEFINE  cSQLEncabezado		CHAR(300);
DEFINE  cSQLEncabezadofin	CHAR(300);
DEFINE  cRuta			CHAR(100);

LET cod_ret        = "00000";
LET sql_err        = 0;
LET vMen           = "El archivo Autorizas_sinrecogerTC_vencidas se generÃ³ correctamente";
LET cErrorInfo     = "";
LET iIsamErr       = 0;
LET dtFechaHoy  = DATE(1);
LET cNomArchivo = '';
LET cSQL        = '';
LET cSQLEncabezado	= '';
LET cSQLEncabezadofin = '';
LET cRuta       = '';

BEGIN
	
	ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
		IF sql_err != 0 THEN
			LET cod_ret = sql_err;
			LET vMen= 'Error al generar archivo de Autorizas_sinrecogerTC_vencidas ';
        RETURN cod_ret, vMen;	
		END IF;
END EXCEPTION;


--	SET DEBUG FILE TO "sp_genera_archivo_tdcexpiradas.out";
 --   TRACE ON; 
	
	SELECT fecha_hoy - 1 units month
	INTO dtFechaHoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';
	
	--let dtFechaHoy = mdy('02','05','2013'); --para pruebas
	LET cRuta = '/resplogifx/archivoscartera/';
	
	---Encabezado de archivo
	
	LET cSql = ' echo "Numero de solicitud;Fecha de solicitud;Fecha de vencimiento;Nombre; Linea de credito autorizada;Estado;Sucursal;Numero cliente;"'||' >'|| TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas_'||to_char(dtFechaHoy,'%m%Y')||'.txt';		
	SYSTEM cSql;
	--Generacion de archivo Autorizas_sinrecogerTC_vencidas	
			LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || SUBSTR(cRuta,1,LENGTH(cRuta)) ||'Autorizas_sinrecogerTC_vencidas.unl' || ' DELIMITER ' || ''';'''  ||
			' select a.num_solicitud,date(a.fecha_insert - 120 units day),a.fecha_insert,'||
			' TRIM(c.nombre1)||'||''' '''||'||TRIM(c.nombre2)||'||''' '''||'||TRIM(c.apell_paterno)||'||''' '''||'||TRIM(c.apell_materno),'||
			' b.monto_solicitado as Linea_de_credito_solicitada,e.nombre,b.sucursal,c.numcte'|| 
			' from bdisolic:ss_autorizacion a,'||
			' bdisolic:ss_solicitudes b,'||
			' bdinteg:si_cliente c,'||
			' bdinteg:si_direcciones_actual d,'||
			' bdinteg:si_estados e'||
			' where a.empresa = b.empresa'||
			' and c.empresa = b.empresa'||
			' and a.num_solicitud = b.num_solicitud'||
			' and b.numcte = c.numcte'||
			' and d.numcte = b.numcte'||
			' and b.num_producto =''6001'''||
			' and a.status_solicitud =''CN'''||
			' and a.causa_solicitud =''CV'''||
			' and d.tipo_dir = ''1'''||
			' and e.estado = d.estado'||
			' and e.pais = ''001'''||
			' and year (a.fecha_insert) = year('''||dtFechaHoy||''')'||
			' and month (a.fecha_insert) = month('''||dtFechaHoy||''');'||
			'" > '||TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas.sql';	
 
 
 		
			
            SYSTEM cSql;

            LET cSql = '';
            LET cSql = 'dbaccess bdicred '||TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas.sql';
            SYSTEM cSql;

            --Se une el encabezado con la informaciÃ³n.
			LET cSql = '';
			LET cSql= "sed 's/;$//g' " ||TRIM(cRuta)||"Autorizas_sinrecogerTC_vencidas.unl"||" >> "||TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas_'||to_char(dtFechaHoy,'%m%Y')||'.txt';
			SYSTEM cSql;
			
	
			LET cSql ='rm '|| TRIM(cruta)||'Autorizas_sinrecogerTC_vencidas.sql ' ||TRIM(cruta)||'Autorizas_sinrecogerTC_vencidas.unl';
			SYSTEM cSql; 


			LET vMen = 'El archivo Autorizas_sinrecogerTC_vencidas se generÃ³ correctamente';
			LET cod_ret = '00000';	
	
			RETURN cod_ret, vMen;

END;
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento generar archivo con informaciÃ³n de Tarjetas de crÃ©dito autorizadas, pero no han sido recogidas',
'AUTOR : Guadalupe de Jesus Espinoza Valenzuela ',
'FECHA : 01/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_rep_estadisticas_tdc_latinia()

RETURNING 
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);

DEFINE vnumcte			CHAR(20);
DEFINE vnum_credito		CHAR(20);
DEFINE vtelefono		CHAR(20);
DEFINE vtarjeta 		CHAR(20);
DEFINE vapellido_pat	CHAR(30);
DEFINE vfecha			DATE;
DEFINE dtFecha          DATE;
DEFINE vdia2 			SMALLINT;
DEFINE vdia7			SMALLINT;
DEFINE vdia14			SMALLINT;
DEFINE vdia15			SMALLINT;
DEFINE vdia21			SMALLINT;
DEFINE vdia28			SMALLINT;
define vtotal			integer;
define vtotal2			integer;
define vtotal1			integer;
DEFINE iTotalRegistros  integer;
define vregistros		integer;
define vproceso			char(4);
define vvalor			smallint;
define vcontador		integer;
define vfechas			char(6);
define vpri_dia_mes 	date;
define VlDescripcion    char(50); 
define vlValorAlfa      char(50); 
define vlValorAlfabetico char(50);
define  vlCDummy        integer;

LET vproceso	='2083';
LET iSqlErr    	= 0;
LET iIsamErr   	= 0;
LET cErrorInfo 	= "";
LET cCodRet   	= '000000';
LET cMensajeRet	= 'El proceso se realizÃ³ correctamente';

LET vnumcte			= "";
LET vnum_credito	= "";
LET vtelefono		= "";
LET vtarjeta 		= "";
LET vapellido_pat	= "";
LET vfecha			= DATE(0);  
LET dtFecha    		= DATE(0);  
let vtotal			= 0;
let vtotal1			= 0;
let vdia2 			= 0;
let vdia7			= 0;
let vdia14			= 0;
let vdia15			= 0;
let vdia21			= 0;
let vdia28			= 0;
LET iTotalRegistros = 0;
let vregistros		=0;
let vvalor 			= 0;
let vcontador 		= 0;
let vfechas			 = '';
let vpri_dia_mes	= DATE(0); 
let VlDescripcion   = '';
let vlValorAlfabetico = '';
let vlCDummy = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= 'ERROR en la ejecuciÃ³n';
	 CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensajeRet, '02')RETURNING cCodRet;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensajeRet, '01')RETURNING cCodRet;
    
--SET DEBUG FILE TO "/informix/gpe/Pruebas_de_carta_por_prioridad/sp_rep_estadisticas_tdc_latinia.out";
--TRACE ON;

	SELECT a.fecha_hoy, a.pri_dia_mes
		INTO dtFecha ,vpri_dia_mes
	FROM bdicred:sd_fechas a
	WHERE a.empresa = '001';
--let dtFecha = '04-05-2014';----------------------------------------pruebas
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

  	select valor_numerico into vregistros
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 57;
	--Dia nuevos
	select valor_numerico into vdia2
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 70;
	
	select valor_numerico into vdia7
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 64;
	select valor_numerico into vdia14
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 65;
	select valor_numerico into vdia15
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 66;
	--RQM 10 637 20150917 AAME Se agregan 2 parametros nuevos de fecha de envÃ­o
	select valor_numerico into vdia21
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 68;
	select valor_numerico into vdia28
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 69;
	
		
	select count(*) into vtotal
	from bdimnsj:mnsjr_trx_batch 
	where id_mensaje = 'AUT_SINREC' 
	 and to_char(fecha_hora_registro,'%m%Y') = to_char(vpri_dia_mes,'%m%Y') ;
	
	select count(*) into vtotal2
	from bdimnsj:mnsjr_trx_batch_his 
	where id_mensaje = 'AUT_SINREC' 
	  and to_char(fecha_hora_registro,'%m%Y') = to_char(vpri_dia_mes,'%m%Y');
	
	let vtotal = nvl(vtotal,0) + nvl(vtotal2,0);
	if (vtotal < vregistros) then
		LET vtotal1 = vregistros - vtotal;
	end if;
	if (day(dtFecha) = 1 ) then 
		let vtotal1 = vregistros; --delete from bdicobranza:cb_administativa_latinia where num_campania = 1;
	end if;
	select valor into vvalor from bdisolic:ss_param where secuencia = '21';

if (vtotal1  >= 1) then
FOREACH
  
	SELECT /* limit vtotal1 */sol.numcte,/*SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10),*/ --SUBSTR(cte.nombre1,1,10) --cte.nombre1
		CASE WHEN LENGTH(cte.nombre1) <=  3 THEN TRIM(cte.nombre1)||' '||TRIM(SUBSTR(cte.nombre2,1,9 - LENGTH(cte.nombre1))) ELSE
																					SUBSTR(cte.nombre1,1,10) END nombre
			,sol.num_solicitud
		INTO vnumcte, /*vtelefono, */ vapellido_pat,vnum_credito
	FROM bdisolic:ss_solicitudes sol
	JOIN bdinteg:si_cliente cte ON cte.empresa = sol.empresa AND cte.numcte = sol.numcte
	JOIN bdisolic:ss_autorizacion aut ON aut.empresa= sol.empresa and aut.num_solicitud = sol.num_solicitud AND aut.status_solicitud = sol.status_solicitud
		AND (aut.fecha_entrada = date(dtFecha) - vdia2 units day or aut.fecha_entrada = date(dtFecha) - vdia7 units day or aut.fecha_entrada = date(dtFecha) - vdia14 units day or aut.fecha_entrada = date(dtFecha) - vdia21 units day or aut.fecha_entrada = date(dtFecha) - vdia28 units day) 
		AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
                                    FROM bdisolic:"informix".ss_autorizacion aut_aux
                                    WHERE aut_aux.empresa= sol.empresa
                                    AND aut_aux.num_solicitud= sol.num_solicitud
                                    AND aut_aux.status_solicitud= sol.status_solicitud)
	/*join bdinteg:si_telefonos_actual tel2 on (tel2.empresa = sol.empresa and tel2.numcte= sol.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
							and tel2.telefono is not null and tel2.telefono <> ''
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = sol.numcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A'))
	*/WHERE sol.empresa = '001' 
		AND sol.num_solicitud = sol.num_solicitud 
		AND sol.status_solicitud = 'AT'
		and sol.tipo_solicitud = 'T'
	order by sol.monto_autorizado desc
	
	select limit 1 SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10) into vtelefono
	from bdinteg:si_telefonos_actual tel2 
	where tel2.empresa = '001' 
	and tel2.numcte = vnumcte
	and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
	and tel2.telefono is not null and tel2.telefono <> ''
    and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                        where numcte = vnumcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A');
	
	if 	(vtelefono is not null and vtelefono <> '') then
	
		let vfecha = date(dtFecha) + vdia15 units day;
		let vfechas = lpad(day(vfecha),2,'0')||'-'|| decode (month(vfecha),01,'Ene',02,'Feb',03,'Mar',04,'Abr',05,'May',06,'Jun',
																   07,'Jul',08,'Ago',09,'Sep',10,'Oct',11,'Nov',12,'Dic');
   
		/*insert into bdicobranza:cb_administativa_latinia(num_campania,numcte,num_credito,telefono,tarjeta ,apellido_pat,fecha,fecha_insert)
		values (1,vnumcte,vnum_credito, vtelefono, '', vapellido_pat, vfecha,today);*/
		call bdimnsj:"informix".sp_registra_evento (2, 'AUT_SINREC' , vnumcte, vnum_credito,'', 2,
							vapellido_pat,vfechas,'','','',0,0,0,0,0, '', '')RETURNING cCodRet;
		let vcontador = vcontador + 1 ;
	end if;
	if (vcontador = vtotal1) then	exit FOREACH; end if;
 End ForEach;
end if;	
  if (day(dtFecha) <= 8 ) then
  
  FOREACH  
    select descripcion,  trim(valor_alfabetico)
      into VlDescripcion, vlValorAlfabetico
      from bdicred:sd_param_campania 
     where tipo_campania = 60  AND GRUPO_PARAMETRO = 'TELSMSFIJO'
	 and num_parametro in (1,2,3)
	 
	 select  count(*) into vlCDummy   
      from bdimnsj:"informix".mnsjr_trx_batch 
     where tipo_mensaje = 2  
      and to_char(fecha_hora_registro,'%m%Y') = to_char( dtFecha,'%m%Y' )
      and id_mensaje  ='AUT_SINREC'
	  and cuenta = vlValorAlfabetico;
      
      if vlCDummy > 0 then continue foreach; end if; 
	 
	 select numcte,num_credito
	  into vnumcte,vnum_credito
	  from bdicred:sd_maecred
	 where num_credito =vlValorAlfabetico;  --in ('600109267697','600030001041','600109267432')
	 

	 
	 select CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1))) ELSE
																					SUBSTR(a.nombre1,1,10) END nombre into vapellido_pat
    from bdinteg:si_cliente a where numcte = vnumcte;
	 
	   call bdimnsj:"informix".sp_registra_evento (2, 'AUT_SINREC' , vnumcte, vnum_credito,'', 2,
							vapellido_pat,vfechas,'','','',0,0,0,0,0,'','')RETURNING cCodRet;

  END FOREACH;
	end if;

	/*if (vcontador  >= 1) then 
	CALL bdicobranza:"informix".sp_sms_reporte(1,0,0,0) RETURNING 	cCodRet;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, 'Reporte sms', '02')RETURNING cCodRet;
	end if;*/
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensajeRet, '03')RETURNING cCodRet;
	RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;