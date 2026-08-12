CREATE PROCEDURE "informix".sp_consulta_disponibilidad_pred(pEmpresa      CHAR(3),
														    pNumCte       CHAR(20),
														    pNumCuenta    CHAR(20),
														    pEjecutivo    CHAR(8),
														    pPrimerApell  CHAR(26),
														    pSdoApell     CHAR(26),
														    pPrimerNombre CHAR(26),
														    pSdoNombre    CHAR(26),
														    pIpEjecutivo  CHAR(20))
RETURNING   CHAR(6)     AS cod_ret,
			CHAR(2)     AS status_cuenta,
			CHAR(1)     AS causa_ex,
			CHAR(21)    AS pagos_recibidos,
			CHAR(10)	AS fecha_ultimo_cargo,
			CHAR(21)	AS saldo_total,
			CHAR(21)	AS interes_moratorio,
			CHAR(21)	AS pago_minimo,
			CHAR(21)	AS capital_vencido,
			CHAR(21)    AS capital_exigible,
			CHAR(2)		AS pagos_vencidos,
			CHAR(10)	AS fecha_ult_pago,
			CHAR(21)	AS monto_ult_pago,
			CHAR(21)    AS monto_aconveniar,
			CHAR(10)	AS fecha_prox_pago,
			CHAR(10)    AS fecha_ultimo_conv,
			CHAR(21)    AS monto_convenio,
			CHAR(1)     AS indicador_cumplido,
			CHAR(21)    AS monto_pagado_conv,
			CHAR(21)	 AS pago_vencido1,--DSB 19/07/2018 FOLIO 441-Pantallas Cobranza CAT BanCoppel
			CHAR(21)	 AS pago_vencido2,
			CHAR(21)	 AS pago_vencido3,
			CHAR(21)	 AS pago_vencido4;
-- Declaraciï¿½n de variables
DEFINE cCodRet              CHAR(6);
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE iDisponible          SMALLINT;
DEFINE cMensajeRet          CHAR(80);
DEFINE cNumCredito          CHAR(20);
DEFINE cNumcliente          CHAR(20);
DEFINE cNomProd             CHAR(40);
DEFINE cNum_tarjeta         CHAR(20);
DEFINE cNomCliente          CHAR(150);
DEFINE dtFechaConvenio      DATE;
DEFINE dtFecha_venc         DATE;
DEFINE cOrigen              CHAR(3);
DEFINE cSituacion           CHAR(1);
DEFINE iCausa               SMALLINT;
DEFINE cInstruccion         CHAR(1);
DEFINE cStatus              CHAR(2);
DEFINE iExiste              SMALLINT;
DEFINE iMotivoRT            SMALLINT;
DEFINE vcodigo_resultado    SMALLINT;
DEFINE vlMontoFinanciado    DECIMAL(14,2);
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE vproceso				CHAR(30);
DEFINE vlFecha              DATE;
DEFINE dFechaInsert         DATE;
DEFINE vPagosVencidos       SMALLINT;
DEFINE vnumproducto         CHAR (4);
DEFINE vmonto_financiado    DEC(18,2);
DEFINE cTipoCobranza        CHAR(1);
DEFINE cVAR_S1 				VARCHAR(255);
DEFINE cVAR_S2 				VARCHAR(255);
DEFINE cVAR_S3 				VARCHAR(255);
DEFINE cVAR_S4 				DATE;
DEFINE cVAR_S5 				VARCHAR(255);
DEFINE cVAR_S6 				VARCHAR(255);
DEFINE cVAR_S7 				VARCHAR(255);
DEFINE cVAR_S8 				VARCHAR(255);
DEFINE cVAR_S9 				VARCHAR(255);
DEFINE cVAR_S10 			VARCHAR(255);
DEFINE cVAR_S11 			VARCHAR(255);
DEFINE cVAR_S12 			VARCHAR(255);
DEFINE cVAR_S13 			VARCHAR(255);
DEFINE cVAR_S14 			VARCHAR(255);
DEFINE cVAR_S15 			VARCHAR(255);
DEFINE cVAR_S16 			VARCHAR(255);
DEFINE cVAR_S17 			VARCHAR(255);
DEFINE cVAR_S18 			VARCHAR(255);
DEFINE cImpSdoTotal     	CHAR(21);
DEFINE cImpIntMora      	CHAR(21);
DEFINE cImpMensual      	CHAR(21);
DEFINE cImpVdoT         	CHAR(21);
DEFINE cNumPagosVdos    	CHAR(2);
DEFINE ctFechaUltPago   	CHAR(10);
DEFINE cImpUltPago      	CHAR(21);
DEFINE cImporteConv    		CHAR(21);
DEFINE ctFechaProxPago  	CHAR(10);
DEFINE dtFechaProxPago  	DATE;
DEFINE dFechaMaxUltCompra 	DATE;
DEFINE dFechaMaxDispAtm 	DATE;
DEFINE dFechaMaxDispPos 	DATE;
DEFINE dFechaMaxDispVnt 	DATE;
DEFINE dFechaUltCargo   	DATE;
DEFINE dFechaUltCargo1   	DATE;
DEFINE dFechaUltCargo2   	DATE;
DEFINE iFechaMax   			SMALLINT;
DEFINE dMontoUltimoPago 	DECIMAL(18,2);
DEFINE cMontoUltimoPago 	CHAR(21);
DEFINE dCapExigible     	DECIMAL(18,2);
DEFINE cCapExigible     	CHAR(21);
DEFINE cMotivoRT 			CHAR(1);
DEFINE cFechaUltCargo   	CHAR(10);
DEFINE cFechaUltConv        CHAR(10);
DEFINE cMontoConvenio       CHAR(21);
DEFINE cIndCumplidoc        CHAR(1);
DEFINE cMontoPagConv        CHAR(21); 
DEFINE dFech_hora DATETIME hour to fraction;
DEFINE dFfechaUltimoPago    DATE;
DEFINE cFfechaUltimoPago    CHAR(10);
DEFINE dFechaUltimaCompra   DATE;
DEFINE dAtmDispFecha        DATE;
DEFINE dPosDispFecha        DATE;
DEFINE dVntDispFecha        DATE;
DEFINE dDecAux          DECIMAL(18,2);
DEFINE cCharAux         CHAR(80);
DEFINE dtDateAux        DATE;
DEFINE dImpMensual      DECIMAL(18,2);
DEFINE iIntAux          DECIMAL(18,2);
DEFINE dImpVdo          DECIMAL(18,2);
DEFINE dCapVdoExig      DECIMAL(18,2);
DEFINE dCapVdoNoExig    DECIMAL(18,2);
DEFINE dSdoActTotalCap  DECIMAL(18,2);
DEFINE cint_vdo         DECIMAL(18,2);
DEFINE civa_int_vdo     DECIMAL(18,2);
DEFINE civa_int_mor     DECIMAL(18,2);
DEFINE dImporte      	DECIMAL(18,2);
DEFINE dImpIntMora      DECIMAL(18,2);
DEFINE dIntMes          DECIMAL(18,2);
DEFINE dSdoActTotalInt  DECIMAL(18,2);
DEFINE dIvaIntMes       DECIMAL(18,2);
DEFINE dSdoActTotalIva  DECIMAL(18,2);
DEFINE dImpSdoTotal     DECIMAL(18,2);
DEFINE sNumPagosVdos    SMALLINT;
DEFINE vPorcentaje      DECIMAL(18,2);
DEFINE dPagosRealizados DECIMAL(18,2);
DEFINE cPagosRealizados CHAR(21);
--DSB 19/07/2018 FOLIO 441-Pantallas Cobranza CAT BanCoppel
DEFINE dpago_vencido1  DECIMAL(18,2);
DEFINE dpago_vencido2  DECIMAL(18,2);
DEFINE dpago_vencido3  DECIMAL(18,2);
DEFINE dpago_vencido4  DECIMAL(18,2);

DEFINE cpago_vencido1  CHAR(21);
DEFINE cpago_vencido2  CHAR(21);
DEFINE cpago_vencido3  CHAR(21);
DEFINE cpago_vencido4  CHAR(21);
DEFINE pIpEjecutivo_2  CHAR(20);

DEFINE cstatusdesc CHAR(60);
-----------------------------------------------------------

-- Inicializaciï¿½n de variables
LET cCodRet                 = "000000";
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET iDisponible             = 1;
LET cMensajeRet             = "";
LET cNumCredito             = "";
LET cNumcliente             = "";
LET cNomProd                = "";
LET cNum_tarjeta            = "";
LET cNomCliente             = "";
LET dtFechaConvenio         = DATE(1);
LET dtFecha_venc            = DATE(1);
LET cOrigen                 = "";
LET cSituacion              = "";
LET iCausa                  = 0;
LET cInstruccion            = "";
LET cStatus                 = "";
LET iExiste                 = 0;
LET iMotivoRT               = 0;
LET vlMontoFinanciado       = 0;
LET error_info              = "";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0077';
LET vmonto_financiado       = 0;
LET vnumproducto 			= '';
LET cTipoCobranza           = '';
LET cImpSdoTotal     		= 0;
LET cImpMensual      		= 0;
LET cImpVdoT         		= 0;
LET cImpIntMora      		= 0;
LET cNumPagosVdos    		= 0;
LET ctFechaUltPago   		= DATE(1);
LET dtFechaProxPago 		= DATE(1);
LET ctFechaProxPago 		= '';
LET cImpUltPago     		= 0;
LET cImporteConv     		= 0;
LET cVAR_S1 				= "";
LET cVAR_S2 				= "";
LET cVAR_S3 				= "";
LET cVAR_S4 				= DATE(1);
LET cVAR_S5 				= "";
LET cVAR_S6 				= DATE(1);
LET cVAR_S7 				= 0;
LET cVAR_S8 				= 0;
LET cVAR_S9 				= 0;
LET cVAR_S10 				= "";
LET cVAR_S11 				= 0;
LET cVAR_S12 				= 0;
LET cVAR_S13 				= "";
LET cVAR_S14 				= "";
LET cVAR_S15 				= "";
LET cVAR_S16 				= "";
LET cVAR_S17 				= "";
LET cVAR_S18 				= "";
LET dFechaMaxUltCompra 		= DATE(1);
LET dFechaMaxDispAtm 		= DATE(1);
LET dFechaMaxDispPos 		= DATE(1);
LET dFechaMaxDispVnt 		= DATE(1);
LET dFechaUltCargo 			= DATE(1);
LET dFechaUltCargo1 		= DATE(1);
LET dFechaUltCargo2 		= DATE(1);
LET iFechaMax   			= 0;
LET dMontoUltimoPago 		= 0;
LET dCapExigible  			= 0;
LET cCapExigible  			= '';
LET cMotivoRT     			= 0;
LET cFechaUltCargo 			= "";
LET cMontoUltimoPago 		= "";
LET cFechaUltConv           = "";
LET cMontoConvenio       	= "";
LET cIndCumplidoc        	= "0";
LET cMontoPagConv        	= ""; 
LET dFech_hora = CURRENT hour to fraction;
LET dFechaInsert            = DATE(1);    
LET dFfechaUltimoPago       = "";
LET cFfechaUltimoPago       = "";
LET dFechaUltimaCompra      = "";
LET dAtmDispFecha           = "";
LET dPosDispFecha           = "";
LET dVntDispFecha           = "";
LET dDecAux                 = 0 ;
LET cCharAux                = 0 ;
LET dtDateAux               = DATE(1);
LET dImpMensual             = 0;
LET iIntAux                 = 0;
LET dImpVdo                 = 0;
LET dCapVdoExig             = 0;
LET dCapVdoNoExig           = 0;
LET dSdoActTotalCap         = 0;
LET cint_vdo                = 0;
LET civa_int_vdo            = 0;
LET civa_int_mor            = 0;
LET dImporte                = 0;
LET dImpIntMora             = 0;
LET dIntMes                 = 0;
LET dSdoActTotalInt         = 0;
LET dIvaIntMes              = 0;
LET dSdoActTotalIva         = 0;
LET dImpSdoTotal            = 0;
LET sNumPagosVdos           = 0;
LET vPorcentaje             = 0;
LET dPagosRealizados        = 0;
LET cPagosRealizados        = '';
--DSB 19/07/2018 FOLIO 441-Pantallas Cobranza CAT BanCoppel
LET dpago_vencido1 = 0;
LET dpago_vencido2 = 0;
LET dpago_vencido3 = 0;
LET dpago_vencido4 = 0;

LET cpago_vencido1 = "";
LET cpago_vencido2 = "";
LET cpago_vencido3 = "";
LET cpago_vencido4 = "";
LET pIpEjecutivo_2 = trim(pIpEjecutivo);

LET cstatusdesc = "";

--SET DEBUG FILE TO "/RESPALDOS/INFOSAT/ALDO/SPL/sp_consulta_disponibilidad_pred.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, error_info
          LET cCodRet = iSqlErr;
		  LET cMensaje = error_info;
		   --GRABAR EN BITï¿½CORA
		  INSERT INTO bdicobranza:"informix".cb_bitacora_predictivo (transaccion,ip,fecha,hora,num_credito,numcte,ejecutivo,apellido_pat,apellido_mat,pri_nombre,seg_nombre,codigo_retorno) 
		  VALUES ('CONDISP',TRIM(NVL(pIpEjecutivo,'')), NVL(dFechaInsert,DATE(1)),dFech_hora, TRIM(NVL(pNumCuenta,'')), TRIM(NVL(pNumCte,'')),TRIM(nvl(pEjecutivo,'')),TRIM(NVL(pPrimerApell,'')),TRIM(NVL(pSdoApell,'')),TRIM(NVL(pPrimerNombre,'')), TRIM(NVL(pSdoNombre,'')),cCodRet);
		   
          RETURN TRIM(NVL(cCodRet," ")), " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ";
    END EXCEPTION;


	IF TRIM(NVL(pEmpresa,"")) = '' THEN  
		LET cCodRet = "000005";
	ELIF TRIM(NVL(pNumCte,"")) = '' THEN
		LET cCodRet = "000006";
	ELIF TRIM(NVL(pNumCuenta,"")) = '' THEN
		LET cCodRet = "000007";
	ELIF TRIM(NVL(pEjecutivo,"")) = '' THEN
		LET cCodRet = "000001";
	ELIF TRIM(NVL(pPrimerApell,"")) = '' THEN
		LET cCodRet = "000002";
	ELIF TRIM(NVL(pPrimerNombre,"")) = '' THEN
		LET cCodRet = "000003";
	ELIF TRIM(NVL(pIpEjecutivo_2,"")) = '' THEN
		LET cCodRet = "000004";
	ELIF NOT EXISTS (SELECT ip FROM bdicobranza:"informix".cb_ips_predictivo WHERE ip = pIpEjecutivo_2) THEN
		LET cCodRet = "000008";
	END IF;
	
	  SELECT fecha_hoy
      INTO dFechaInsert
      FROM bdinteg:"informix".si_fechas
      WHERE empresa = pEmpresa;
	
  IF cCodRet = "000000" THEN     
	
        EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCuenta)
                    INTO cCodRet,cMensaje,cCharAux,cCharAux,dtDateAux,dtFechaProxPago,dImpMensual,dtDateAux,
                         iIntAux,dPagosRealizados,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dImpVdo,dCapVdoExig,dCapVdoNoExig,
                         dSdoActTotalCap,dDecAux,cint_vdo,dImpIntMora,dIntMes,dSdoActTotalInt,dDecAux,civa_int_vdo,civa_int_mor,dIvaIntMes,
                         dSdoActTotalIva,dDecAux,dDecAux,dDecAux,dImpSdoTotal,dDecAux,dDecAux,dDecAux,sNumPagosVdos,cstatusdesc,
                         iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,cCharAux,cCharAux,iIntAux,
                         cCharAux;
    
		IF cCodRet <> '000000' THEN   
              LET cCodRet = '101005';
			  --GRABAR EN BITï¿½CORA
			  INSERT INTO bdicobranza:"informix".cb_bitacora_predictivo (transaccion,ip,fecha,hora,num_credito,numcte,ejecutivo,apellido_pat,apellido_mat,pri_nombre,seg_nombre,codigo_retorno) 
			  VALUES ('CONDISP',pIpEjecutivo,dFechaInsert,dFech_hora,pNumCuenta,pNumCte,pEjecutivo,pPrimerApell,pSdoApell,pPrimerNombre,pSdoNombre,cCodRet);
			   
			RETURN TRIM(NVL(cCodRet," ")), " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ";
		ELSE

			LET cImpSdoTotal    = dImpSdoTotal; --
			LET cImpIntMora     = dImpIntMora + civa_int_mor + cint_vdo + civa_int_vdo; --
			LET cImpMensual 	= case when dImpMensual < 0 then 0 else dImpMensual end; --
			LET cImpVdoT        = dImpMensual - dCapVdoExig - cint_vdo - dImpIntMora - civa_int_vdo - civa_int_mor;
            LET vmonto_financiado = case when dImpMensual = 0 then 0 else dImpMensual - cint_vdo - dImpIntMora - civa_int_vdo - civa_int_mor end; 
            LET cCapExigible    = dCapVdoExig;
			LET cNumPagosVdos 	= sNumPagosVdos;
            LET cPagosRealizados = dPagosRealizados;

           SELECT Porcentaje
             INTO vPorcentaje
             FROM bdicobranza:cb_compac_montomin
            WHERE Meses_vencido = sNumPagosVdos
              AND Monto_vencido_min <= dImpMensual
              AND Monto_vencido_max >= dImpMensual;

            IF vPorcentaje IS NULL OR vPorcentaje = '' THEN
                LET cImporteConv = '0';
            ELSE
    			LET cImporteConv = (vPorcentaje * dImpMensual / 100)::decimal(18,2);
            END IF;

			LET ctFechaProxPago = TO_CHAR(dtFechaProxPago,'%m/%d/%Y');
        END IF

-- Se valida en el spl sp_cat_consulta_saldostc_pred

		SELECT  max(fecha_insert) into vlFecha
		FROM bdicobranza:"informix".cb_cat_directorio_cte 
		 WHERE num_credito = pNumCuenta;

--      if (nvl(fecha_insert,date(1)) <> date(1)) then

            -- Obtiene el nï¿½mero de crï¿½dito del cliente
            SELECT limit 1  num_producto, tipo_cobranza  INTO vnumproducto, cTipoCobranza
            FROM bdicobranza:"informix".cb_cat_directorio_cte 
             WHERE empresa      = pempresa
               AND tipo_cobranza in ('A','R')
               AND fecha_insert  =  vlFecha
               AND num_credito = pNumCuenta;

			/*SELECT limit 1  num_producto, 'A'  INTO vnumproducto, cTipoCobranza
            FROM bdicred:sd_sdos_cartera_linea 
             WHERE num_credito = pNumCuenta;*/   

-- Se valida en el spl sp_cat_consulta_saldostc_pred

	   -- Validar si el cliente tiene compromisos activos
		IF (cTipoCobranza IN ('A', 'R')) THEN
			EXECUTE PROCEDURE bdicobranza:"informix".sp_compac_consultacompromisosvigente(pEmpresa,pNumCuenta)
			INTO cCodRet,cMensajeRet,dtFechaConvenio,dtFecha_venc,dImporte,cOrigen;  -- Unicamente con A y P llame al sp
		ELSE
			LET cCodRet = '00003';  -- Se forza a que entre a la sig condicion.
		END IF;

		IF TRIM(cCodRet) IN ("00003", "00005", "00004") THEN
		
    		LET cCodRet = "000000";
		  SELECT FIRST 1 situacion,  causa
					   INTO cSituacion, iCausa
					   FROM bdisitesp:"informix".se_ctessitespcte
					  WHERE numcte = pNumCte;

		  SELECT FIRST 1 instruccion
					   INTO cInstruccion
					   FROM bdisitesp:"informix".se_situacionaccion
					  WHERE situacion= cSituacion
						AND causa= iCausa
						AND idaccion = 9;
		  
		  IF NVL(cInstruccion,"") <> "0" THEN
			  -- Validar  si el crï¿½dito presenta saldo vencido 
						--valida si el credito se encuentra en maecred o maecredcrd para
						--tarjeta de credito o credito no revolventes.					
			LET cStatus = '';
			LET vPagosVencidos =-1;

--			SELECT status_cred
--			  INTO cStatus
--			  FROM bdicred:"informix".sd_maecred
--			 WHERE empresa = pEmpresa AND num_credito = pNumCuenta;

--			SELECT COUNT(num_credito)
--			  INTO vPagosVencidos
--			  FROM bdicred:"informix".sd_amortiza_credito
--			 WHERE empresa     = pEmpresa
--			   AND num_credito = pNumCuenta
--			   AND capital_status IN ('2','7');

            LET vPagosVencidos = cNumPagosVdos;

--			SELECT monto_financiado
--			  INTO vmonto_financiado
--			  FROM bdicred:"informix".sd_maesdos
--			 WHERE empresa     = pEmpresa
--			   AND num_credito = pNumCuenta;
			  
			IF  ( cTipoCobranza IN ('R','E') )  then
--				SELECT status_cred
--				INTO cStatus
--				FROM bdicred:"informix".sd_maecredcrd
--			   WHERE empresa = pEmpresa
--				 AND num_credito = pNumCuenta;

--			  SELECT COUNT(num_credito)
--				INTO vPagosVencidos
--				FROM bdicred:"informix".sd_amortiza_creditocrd
--			   WHERE empresa     = pEmpresa
--				 AND num_credito = pNumCuenta
--				 AND capital_status IN ('2','7');	

                 LET vPagosVencidos = cNumPagosVdos;

--			  SELECT monto_financiado
--				INTO vmonto_financiado
--				FROM bdicred:"informix".sd_maesdoscrd
--			   WHERE empresa     = pEmpresa
--				 AND num_credito = pNumCuenta;
			END IF;
			IF (vPagosVencidos >0 AND vmonto_financiado > 100) THEN 
			  SELECT status_cliente, codigo_resultado
				INTO cStatus ,vcodigo_resultado
				FROM bdicobranza:"informix".cb_cat_directorio_cte a
			   WHERE a.empresa       = pEmpresa
				 AND a.tipo_cobranza = cTipoCobranza
				 AND a.fecha_insert  = vlFecha
                 AND a.num_credito   = pNumCuenta;
	
			  IF ((NVL(cStatus,"") IN ("AC", "LD")) OR ((NVL(cStatus,"") ='PR') AND (nvl(vcodigo_resultado,0) != 1)))  THEN
				 SELECT COUNT(numcte)
				   INTO iExiste
				   FROM bdicobranza:"informix".cb_excepcion_cte
				  WHERE empresa = pEmpresa
					AND numcte = pNumcte
					AND status_excepcion = "AC";
				IF iExiste = 0 THEN
				  LET iDisponible = 0;
				ELSE
				  LET iMotivoRT = 6;
				END IF;
			  ELSE
				LET iMotivoRT = 5;
			  END IF;				
			ELIF (vPagosVencidos >0 AND vmonto_financiado <= 100) THEN
				 LET iMotivoRT = 7;
			ELIF NVL(trim(cstatusdesc),"") = "CARTERA VENDIDA" THEN -- Si es por venta de cartera
			   LET iMotivoRT = 4;					
			ELIF ((( cTipoCobranza ="P" ) or (cTipoCobranza ="E" )) AND (NVL(trim(cstatusdesc),"") = "VIGENTE NORMAL" )) THEN -- Si es Preventiva Reestructura o TC
			   IF  ( cTipoCobranza ="P" ) THEN --TC       
--					SELECT monto_financiado  INTO vlMontoFinanciado
--					FROM bdicred:"informix".sd_maesdos 
--				   WHERE empresa = pEmpresa 
--					 AND num_credito = pNumCuenta;

					IF vmonto_financiado >0 THEN 
					 LET iMotivoRT = 0;
					 LET iDisponible = 0;
				    ELSE
					 LET iMotivoRT = 2;  
				    END IF;
			   ELSE --Reestructura                  
--					SELECT   monto_financiado  INTO vlMontoFinanciado
--					 FROM bdicred:"informix".sd_maesdoscrd
--					WHERE empresa = pEmpresa 
--					  AND num_credito = pNumCuenta;					
				   IF vmonto_financiado >0 THEN 
					  LET iMotivoRT = 0;
					  LET iDisponible = 0;
				   ELSE
					 LET iMotivoRT = 2;  
				   END IF;
			   END IF;
			ELIF ((( cTipoCobranza ="R" ) or (cTipoCobranza ="A" )) AND (NVL(trim(cstatusdesc),"") = "VIGENTE NORMAL" )) THEN
			  LET iMotivoRT = 2;
			END IF;        
		  ELSE
			 LET iMotivoRT = 3;
		  END IF;		   	   
		ELSE
				LET iMotivoRT = 1;
		END IF;  
	 --VALIDA SI EL CLIENTE SERï¿½ EXCEPTUADO, ASIGNANDO ESTATUS FINAL
	  IF iDisponible = "0" THEN
		  LET cCodRet = "000000";
		  LET cStatus = "AC";
		  -- Marca registro de cliente actualizANDose en cb_cat_directorio_cte
		  UPDATE bdicobranza:"informix".cb_cat_directorio_cte
			SET cobranza_aux_direct = '1'
			WHERE empresa       = pEmpresa
			AND tipo_cobranza   = cTipoCobranza
--			AND numcte          = pNumCte
			AND fecha_insert    = vlFecha
			AND num_credito     = pNumCuenta;  
	  ELSE
		  LET cStatus = "EX";
	  END IF
	  LET cMotivoRT = CAST(iMotivoRT AS CHAR);

		--CONSULTA FECHA ULTIMO CARGO Y MONTO ULTIMO PAGO CUENTAS REVOLVENTES
		IF (cTipoCobranza IN ('A','P')) THEN
            SELECT fecha_ultimo_pago,monto_ultimo_pago,fecha_ultima_compra,atm_disp_fecha,pos_disp_fecha,vnt_disp_fecha
            INTO dFfechaUltimoPago,dMontoUltimoPago,dFechaUltimaCompra,dAtmDispFecha,dPosDispFecha,dVntDispFecha
			FROM bdicred:"informix".sd_indicador_cred
			WHERE empresa = pEmpresa
			AND num_credito = pNumCuenta;

			IF NVL(dFechaUltimaCompra, DATE(1)) > NVL(dAtmDispFecha, DATE(1)) THEN
				LET dFechaUltCargo = dFechaUltimaCompra;
			ELSE
				LET dFechaUltCargo = dAtmDispFecha;
			END IF
			IF NVL(dPosDispFecha, DATE(1)) > NVL(dFechaUltCargo, DATE(1)) THEN
				LET dFechaUltCargo = dPosDispFecha;
			END IF
			IF NVL(dVntDispFecha, DATE(1)) > NVL(dFechaUltCargo, DATE(1)) THEN
				LET dFechaUltCargo = dVntDispFecha;
			END IF

        --CONSULTA FECHA ULTIMO CARGO Y MONTO ULTIMO PAGO CUENTAS A PLAZO
		ELIF (cTipoCobranza IN ('R','E')) THEN
			SELECT NVL(fecha_ultimo_pago, DATE(1)), NVL(monto_ultimo_pago,0)
			INTO dFfechaUltimoPago, dMontoUltimoPago
			FROM bdicred:"informix".sd_indicador_cred_crd
			WHERE empresa = pEmpresa
			AND num_credito = pNumCuenta;
		END IF;
		
        LET cFfechaUltimoPago = TO_CHAR(dFfechaUltimoPago, '%m/%d/%Y');
		LET cMontoUltimoPago  = dMontoUltimoPago;
        IF dFfechaUltimoPago IS NULL OR dFfechaUltimoPago = '' THEN 
            LET dFfechaUltimoPago = DATE(1);
            LET cFfechaUltimoPago = TO_CHAR(dFfechaUltimoPago, '%m/%d/%Y'); 
            LET cMontoUltimoPago='0.00'; 
        END IF;

        IF dMontoUltimoPago IS NULL OR dMontoUltimoPago = '' THEN LET dMontoUltimoPago = 0; END IF;

        IF dFfechaUltimoPago != DATE(1) AND dMontoUltimoPago = 0 THEN 
            IF (cTipoCobranza IN ('A','P')) THEN
                SELECT SUM(monto) INTO dMontoUltimoPago
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa
                AND fecha_mov = dFfechaUltimoPago
                AND num_credito = pNumCuenta
                AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual)
                AND codigo_ref = 1;
            ELIF (cTipoCobranza IN ('R','E')) THEN
                SELECT SUM(monto) INTO dMontoUltimoPago
                FROM bdicred:sd_movhiscrd
                WHERE empresa = pEmpresa
                AND fecha_mov = dFfechaUltimoPago
                AND num_credito = pNumCuenta
                AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd)
                AND codigo_ref = 1;
            END IF;
            LET cMontoUltimoPago=dMontoUltimoPago;
        END IF;

        IF dFechaUltCargo IS NULL OR dFechaUltCargo = '' THEN LET dFechaUltCargo = DATE(1); END IF;
		LET cFechaUltCargo = TO_CHAR(dFechaUltCargo, '%m/%d/%Y');
		
		--CONSULTA LA INFORMACION DEL ULTIMO CONVENIO DEL CLIENTE
		EXECUTE PROCEDURE bdicobranza: "informix".sp_cat_consulta_ultimo_convenio(pEmpresa,pNumCte)
        INTO cVAR_S1,cVAR_S2,cVAR_S3,cVAR_S4,cVAR_S5,cVAR_S6,cVAR_S7,cVAR_S8;
        IF cVAR_S1::INTEGER <> 0 THEN                           
              LET cCodRet = TRIM(cVAR_S1);
			  --GRABAR EN BITï¿½CORA
			  INSERT INTO bdicobranza:"informix".cb_bitacora_predictivo (transaccion,ip,fecha,hora,num_credito,numcte,ejecutivo,apellido_pat,apellido_mat,pri_nombre,seg_nombre,codigo_retorno) 
			  VALUES ('CONDISP',pIpEjecutivo,dFechaInsert,dFech_hora,pNumCuenta,pNumCte,pEjecutivo,pPrimerApell,pSdoApell,pPrimerNombre,pSdoNombre,cCodRet);
			   
			RETURN TRIM(NVL(cCodRet," ")), " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ";
		ELSE
			LET cFechaUltConv  = TRIM(TO_CHAR(cVAR_S4, '%m/%d/%Y'));
			LET cMontoConvenio = TRIM(cVAR_S5);
			LET cIndCumplidoc  = TRIM(CASE WHEN cVAR_S6 = '' THEN '-' ELSE cVAR_S6 END);
			LET cMontoPagConv  = TRIM(cVAR_S7);
		
        END IF
	ELSE
		INSERT INTO bdicobranza:"informix".cb_bitacora_predictivo (transaccion,ip,fecha,hora,num_credito,numcte,ejecutivo,apellido_pat,apellido_mat,pri_nombre,seg_nombre,codigo_retorno) 
		VALUES ('CONDISP',pIpEjecutivo,dFechaInsert,dFech_hora,pNumCuenta,pNumCte,pEjecutivo,pPrimerApell,pSdoApell,pPrimerNombre,pSdoNombre,cCodRet);
		   
		RETURN TRIM(NVL(cCodRet," ")), " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ";
	END IF;
   --DSB 19/07/2018 FOLIO 441-Pantallas Cobranza CAT BanCoppel
	IF(TRIM(NVL(vnumproducto,'')) IN ('6001','8100','8500')) THEN-->>tarjeta de credito clasica (6001), tarjeta de credito ORO (8100), tarjeta grupo Coppel (8500)
		 SELECT
          (CASE WHEN saldovencido1 <> 0 
          THEN saldovencido1  + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 + interesmoratorio4 + interesmoratorio5 + interesmoratorio6 + sdo_intereses
          ELSE 0 END) CUADRO1,
          (CASE WHEN saldovencido2 <> 0 THEN saldovencido2 + saldovencido1 + interesmoratorio1 + interesmoratorio2 +
		interesmoratorio3 + interesmoratorio4 + interesmoratorio5 + interesmoratorio6 +
		sdo_intereses ELSE 0 END) CUADRO2,
		(CASE WHEN saldovencido3 <> 0 THEN saldovencido3 + saldovencido2 + saldovencido1 + interesmoratorio1 +
		interesmoratorio2 + interesmoratorio3 + interesmoratorio4 + interesmoratorio5 +
		interesmoratorio6 + sdo_intereses ELSE 0 END) CUADRO3,
		(CASE WHEN saldovencido4 <> 0 THEN saldovencido6 + saldovencido5 + saldovencido4 + saldovencido3 + saldovencido2 +
		saldovencido1 + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 +
		interesmoratorio4 + interesmoratorio5 + interesmoratorio6 + sdo_intereses ELSE 0 END) CUADRO4 --ELSE 0 END 
		INTO dpago_vencido1,dpago_vencido2,dpago_vencido3,dpago_vencido4
		FROM bdicred:"informix".sd_sdos_cartera_linea 
		WHERE num_credito = pNumCuenta;
	 
	--ELIF (TRIM(NVL(vnumproducto,"")) = '6300') THEN --prestamo personal(6300) 
	ELIF (TRIM(NVL(vnumproducto,"")) IN ('6300','6400','6800','7600','7700')) THEN --prestamo personal(6300), PP 18(7600), PP 24(7700), ANT (6400), PF (6800)

		SELECT 
		  (CASE WHEN saldovencido1 <> 0 THEN saldovencido1 + interesmoratorio1	ELSE 0 END) CUADRO1,
          (CASE WHEN saldovencido2 <> 0 THEN saldovencido2 + saldovencido1 + interesmoratorio1 + interesmoratorio2 ELSE 0 END) CUADRO2,
          (CASE WHEN saldovencido3 <> 0 THEN saldovencido3 + saldovencido2 + saldovencido1 + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 ELSE 0 END) CUADRO3,
          (CASE WHEN saldovencido4 <> 0 THEN saldovencido6 + saldovencido5 + saldovencido4 + saldovencido3 + saldovencido2 + 
		  saldovencido1 + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 + interesmoratorio4 + interesmoratorio5 + interesmoratorio6 ELSE 0 END) CUADRO4
		  INTO dpago_vencido1,dpago_vencido2,dpago_vencido3,dpago_vencido4
		  FROM bdicred:"informix".sd_sdos_cartera_linea 
		  WHERE num_credito = pNumCuenta;
				
	ELIF (TRIM(NVL(vnumproducto,"")) = '6011') THEN --reetructura (6011)
			--CAST(iMotivoRT AS CHAR)
		SELECT 
		(CASE WHEN saldovencido1 <> 0 THEN saldovencido1 ELSE 0 END) CUADRO1,
		(CASE WHEN saldovencido2 <> 0 THEN saldovencido2 + saldovencido1 ELSE 0 END) CUADRO2,
		(CASE WHEN saldovencido3 <> 0 THEN saldovencido3 + saldovencido2 + saldovencido1 ELSE 0 END) CUADRO3,
		(CASE WHEN saldovencido4 <> 0 THEN saldovencido6 + saldovencido5 + saldovencido4 + saldovencido3 + saldovencido2 + saldovencido1 ELSE 0 END) CUADRO4
		INTO dpago_vencido1,dpago_vencido2,dpago_vencido3,dpago_vencido4
		FROM bdicred:"informix".sd_sdos_cartera_linea 
		WHERE num_credito = pNumCuenta;
			
	END IF;
	
	LET cpago_vencido1 = dpago_vencido1;
	LET cpago_vencido2 = dpago_vencido2;
	LET cpago_vencido3 = dpago_vencido3;
	LET cpago_vencido4 = dpago_vencido4;


  --GRABAR EN BITï¿½CORA
	  INSERT INTO bdicobranza:"informix".cb_bitacora_predictivo (transaccion,ip,fecha,hora,num_credito,numcte,ejecutivo,apellido_pat,apellido_mat,pri_nombre,seg_nombre,codigo_retorno) 
	  VALUES ('CONDISP',pIpEjecutivo,dFechaInsert,dFech_hora,pNumCuenta,pNumCte,pEjecutivo,pPrimerApell,pSdoApell,pPrimerNombre,pSdoNombre,cCodRet);

   
	RETURN TRIM(cCodRet),TRIM(cStatus),TRIM(cMotivoRT),TRIM(cPagosRealizados),TRIM(cFechaUltCargo),TRIM(cImpSdoTotal),TRIM(cImpIntMora),TRIM(cImpMensual),TRIM(cImpVdoT),TRIM(cCapExigible),TRIM(cNumPagosVdos),
		TRIM(cFfechaUltimoPago),TRIM(cMontoUltimoPago),TRIM(cImporteConv),TRIM(ctFechaProxPago),TRIM(cFechaUltConv),TRIM(cMontoConvenio),TRIM(cIndCumplidoc),TRIM(cMontoPagConv),
		TRIM(NVL(cpago_vencido1,'0')), 	TRIM(NVL(cpago_vencido2,'0')),TRIM(NVL(cpago_vencido3,'0')),TRIM(NVL(cpago_vencido4,'0'));

END; 

END PROCEDURE
DOCUMENT
'FECHA: 19/07/2018',
'Folio:441-Pantallas Cobranza CAT BanCoppel',
'Autor:97877352 - Rubio Lugo Jesï¿½s Alberto',
'Fecha:19/07/2018',
'DESCRIPCION: Procedimineto que consulta el saldo vencido que presenta el cliente',
'Solicita: Ricardo Sanchez',
'BD: bditrapres',
'-------------------------------------',
'FECHA: 22/Jun/2015',
'FOLIO :1728',
'PROYECTO: ReingenieriaPredictivoBancoppel',
'DESCRIPCION: Procedimineto que consulta la disponibilidad del cliente y consulta sus datos generales. Asï¿½ como la informaciï¿½n de su crï¿½dito',
'AUTOR: Mireya Reyes',
'BD: bdicobranza';

CREATE PROCEDURE "informix".trans_abono( ptipo_transfer CHAR(2),
                                         pc_costos      CHAR(4),
                                         pusuario       CHAR(8),
                                         pfolio         CHAR(16),
                                         pcuenta        CHAR(20),
                                         pnum_tarjeta   CHAR(16),
                                         pfecha         DATE,
                                         pmto_tot       DECIMAL(14,2),
                                         pmoneda        CHAR(3),
                                         preferencia    CHAR(40) )
RETURNING CHAR(5), CHAR(11);
    
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_tpcambio  DATE;
    DEFINE vprecio_udi      DECIMAL(14,6);
    DEFINE vmonto_udi       DECIMAL(18,6);
    DEFINE vmtoacumcta      DECIMAL(18,6);
    DEFINE vmtopagosudi     DECIMAL(18,6);
    DEFINE vlim_cuenta      DECIMAL(18,6);
    DEFINE vporcapcorres    DECIMAL(9,6);
    DEFINE vmtoglobcap      DECIMAL(20,6);
    DEFINE vmtomensacum     DECIMAL(20,6);
    DEFINE vexiste          CHAR(20);
    DEFINE vtransaccion     SMALLINT;
    DEFINE vtranprestcoppel CHAR(4);
    DEFINE vnomaxudis       SMALLINT;
    DEFINE vhoramax         datetime hour to minute;
    DEFINE wcuenta          CHAR(20);
    DEFINE vstatus_tar      CHAR(1);
    DEFINE vproceso         CHAR(1);
    DEFINE vind_cierre      CHAR(1);
    DEFINE vind_dispon      CHAR(1);
    DEFINE vexiste_hoy      SMALLINT;
    DEFINE vexiste_mes      SMALLINT;
    DEFINE vtrx_dia         SMALLINT;
    DEFINE vtrx_mes         SMALLINT;
    DEFINE vnumcte          CHAR(20);
	DEFINE vtranabono  		CHAR(4);
	DEFINE vterminacion  	CHAR(4);
	DEFINE vacumulado		CHAR(1);
	DEFINE vfolios          SMALLINT;
    DEFINE vmto_perm        DECIMAL(14,2);
    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vproceso = '0';
    
    LET vfecha_hoy       = '';
    LET vfecha_tpcambio  = '';
    LET vprecio_udi      = 0.00;
    LET vmonto_udi       = 0.00;
    LET vmtoacumcta      = 0.00;
    LET vmtopagosudi     = 0.00;
    LET vlim_cuenta      = 0.00;
    LET vporcapcorres    = 0.00;
    LET vmtoglobcap      = 0.00;
    LET vmtomensacum     = 0.00;
    LET vexiste          = '';
    LET vtransaccion     = 0;
    LET vnomaxudis       = 0;
    LET vhoramax         = '';
    LET vtranprestcoppel = '';
    LET wcuenta          = '';
    LET vstatus_tar      = '';
    LET vind_cierre      = '0';
    LET vind_dispon      = '0';
    LET vexiste_hoy      = 0;
    LET vexiste_mes      = 0;
    LET vtrx_dia         = 0;
    LET vtrx_mes         = 0;
    LET vnumcte          = '';
	LET vtranabono    	 = '';
	LET vterminacion  	 = '';
	LET vacumulado		 = '';
    LET vmto_perm        = 0.00;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/trans_abono.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
         SET DEBUG FILE TO "/resplogifx/conciliachq/trans_abono.err";
         TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF vproceso = '1' THEN
                LET vcodret1 = '000';
            END IF;
            RETURN vcodret1, TRIM(pcuenta);
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // Obtiene fechas del sistema de cheques
    SELECT fecha_hoy, ind_cierre, ind_disponible
      INTO vfecha_hoy, vind_cierre, vind_dispon
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';

    IF ( vind_cierre = '0' OR vind_dispon = '0' ) THEN
        LET vcodret1 = '004';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    -- // VALIDACION DE PARAMETROS
    LET pmto_tot = pmto_tot / 100;

    IF ( pc_costos is null OR pc_costos = '' OR LENGTH(pc_costos) <> 4 ) OR
       ( pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8 ) OR
       ( pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16 ) OR
       ( ( pcuenta is null OR pcuenta = '' OR LENGTH(pcuenta) <> 11 ) AND ( pnum_tarjeta is null OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16 ) ) OR
       ( pfecha is null OR pfecha = '' ) OR
       ( pmto_tot is null OR pmto_tot <= 0.00 ) OR
       ( pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03 ) THEN
        LET vcodret1 = '110';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3];
    END IF;

    -- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
    IF pcuenta is null OR pcuenta = '' THEN
        SELECT cuenta, status_tar, numcte
          INTO pcuenta, vstatus_tar, vnumcte
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = pnum_tarjeta;

        IF vstatus_tar <> 'A' THEN
            LET vcodret1 = '200';
            RETURN vcodret1, TRIM(pcuenta);
        END IF;

		LET vterminacion = SUBSTR(pnum_tarjeta,13,4);
    END IF;

    IF pnum_tarjeta is null OR pnum_tarjeta = '' THEN
        SELECT num_tarjeta, numcte
          INTO pnum_tarjeta, vnumcte
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND cuenta = pcuenta
           AND secuencia = (SELECT max(secuencia)
                              FROM bdicheq:sc_tarjeta
                             WHERE empresa = '001'
                               AND cuenta = pcuenta)
           AND status_tar = 'A';

        IF pnum_tarjeta is null THEN
            LET pnum_tarjeta = '';
        END IF;

		LET vterminacion = SUBSTR(pcuenta,8,4);
    END IF;

	-- // VALIDA QUE NO EXISTA EL FOLIO
	SELECT COUNT(*)
	  INTO vfolios
	  FROM bdicheq:sc_movdia
	 WHERE folio_suc = pfolio;

	IF vfolios > 0 THEN
        LET vcodret1 = '302';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    -- // VALIDA EL NUMERO DE CLIENTE
    IF vnumcte is null OR vnumcte = '' THEN
        SELECT num_cte
          INTO vnumcte
          FROM bdicheq:sc_maechq
         WHERE empresa = '001'
           AND cuenta = pcuenta;
    END IF;
    
    -- // OBTIENE NUMERO DE TRANSACCION
	SELECT trans, acumulado
	INTO vtranabono, vacumulado
	FROM "informix".sc_tipo_trans
	WHERE clave = ptipo_transfer;

	IF vtranabono IS NULL OR vtranabono = '' THEN
		LET vcodret1 = '110';
        RETURN vcodret1, TRIM(pcuenta);
    END IF;
    
    IF vacumulado = 'S' THEN
		-- // VALIDA TRANSACCIONES PERMITIDAS POR DIA
		SELECT valor::int
		INTO vtrx_dia
		FROM bdicheq:sc_param
		WHERE empresa = '001'
		AND codparam = 'NoTrxsDiaTranPres';

		SELECT COUNT(*)
		INTO vexiste_hoy
		FROM bdicheq:sc_acumtrapres
		WHERE numcte = vnumcte
		AND fecha = vfecha_hoy;

		IF vexiste_hoy >= vtrx_dia THEN
		LET vcodret1 = '302';
		RETURN vcodret1, TRIM(pcuenta);
		END IF;

		-- // VALIDA TRANSACCIONESPOR PERMITIDAS POR MES
		SELECT valor::int
		INTO vtrx_mes
		FROM bdicheq:sc_param
		WHERE empresa = '001'
		AND codparam = 'NoTrxsMesTranPres';

		SELECT COUNT(*)
		INTO vexiste_mes
		FROM bdicheq:sc_acumtrapres
		WHERE numcte = vnumcte;

		IF vexiste_mes >= vtrx_mes THEN
			LET vcodret1 = '302';
			RETURN vcodret1, TRIM(pcuenta);
		END IF;
    END IF;
    
    -- // VALIDA MONTO PERMITIDO PARA PRESTAMOS
    SELECT valor
      INTO vtranprestcoppel
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = "tranprestcoppel";
    
    IF vtranabono = vtranprestcoppel THEN
        -- // VALIDA MONTO PERMITIDO
        SELECT valor::decimal(14,2)
          INTO vmto_perm
          FROM bdicheq:sc_param
         WHERE empresa = '001'
           AND codparam = 'MtoPermitidoTranPres';

        IF pmto_tot > vmto_perm THEN
            LET vcodret1 = '302';
            RETURN vcodret1, TRIM(pcuenta);
        END IF;
    END IF;

    -- // APLICA TRANSACCION DE ABONO EN LA CUENTA DE CHEQUES
    EXECUTE PROCEDURE bdicheq:abono_ref( "001",             --- empresa
                                         pc_costos,         --- sucursal
                                         pusuario,          --- usuario
                                         vtranabono,  		--- transaccion
                                         "0000",            --- transaccion suc
                                         pfolio,            --- folio suc
                                         pcuenta,           --- cuenta
                                         0,                 --- cheque
                                         pmto_tot,          --- monto total
                                         pmto_tot,          --- monto firme
                                         0,                 --- monto SBC
                                         0,                 --- monto REM
                                         0,                 --- dias ret
                                         pmoneda,           --- divisa
                                         preferencia,       --- referencia
                                         pnum_tarjeta,      --- no. tarjeta
                                         " " )              --- usuario autoriza
    INTO vcodret1;

    IF vcodret1 = '000' THEN
        LET vproceso = '1';

		IF vacumulado = 'S' THEN
			INSERT INTO bdicheq:sc_acumtrapres
			VALUES ( pcuenta, pfolio, pmto_tot, vfecha_hoy, vnumcte );
		END IF
    ELSE
        IF vcodret1 = '110' OR
           vcodret1 = '106' OR
           vcodret1 = '420' OR
           vcodret1 = '552' OR
           vcodret1 = '959' OR
           vcodret1 = '956' OR
           vcodret1 = '401' OR
           vcodret1 = '549' THEN
            LET vcodret1 = '110';
        END IF;

        IF vcodret1 = '100' THEN
            LET vcodret1 = '100';
        END IF;

        IF vcodret1 = '200' THEN
            LET vcodret1 = '200';
        END IF;

        IF vcodret1 = '951' THEN
            LET vcodret1 = '951';
        END IF;

        IF vcodret1 = '301' THEN
            LET vcodret1 = '302';
        END IF;

        RETURN vcodret1, TRIM(pcuenta);
    END IF;

    RETURN vcodret1, TRIM(vterminacion);

    END;

END PROCEDURE;