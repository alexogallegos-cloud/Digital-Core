CREATE PROCEDURE "informix".sp_cs_pago_anticipado(pEmpresa					CHAR(3),
												pNumCredito					CHAR(20),
												pProducto					CHAR(4),
												pMontoOperacionEfec			DECIMAL(18,2),
												pMontoOperacionCargCuenta	DECIMAL(18,2),
												pUsuario					CHAR(8),
												pSucursal					CHAR(4),
												pFolio						CHAR(16),
												pTransaccion				CHAR(4))
RETURNING CHAR(5)		AS CodRet,
		CHAR(80)		AS Mensaje,
		CHAR(20)		AS Num_Credito,
		CHAR(20)		AS Cuenta_eje,
		CHAR(40)		AS Producto,
		CHAR(20)		AS Num_Cliente,
		CHAR(150)		AS Nom_Cliente,
		DECIMAL(18,2)	AS Pago_Efectivo,
		DECIMAL(18,2)	AS Pago_Cuenta,
		DECIMAL(18,2)	AS Monto_Operacion,
		DECIMAL(18,2)	AS Saldo_Actual,
		CHAR(60)		AS Status_Actual,
		DATE			AS fecha_prox_pago

DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(100);
DEFINE cCodRet				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE cNumCreditocrd		CHAR(20);
DEFINE cNumCreditocrdsol	CHAR(20);
DEFINE cCredito_promo		CHAR(20);
DEFINE dtFechaProxPago		DATE;
DEFINE dtFechaApertura		DATE;
DEFINE Cuenta_eje			CHAR(20);
DEFINE Producto				CHAR(40);
DEFINE Num_Cliente			CHAR(20);
DEFINE Nom_Cliente			CHAR(80);
DEFINE Pago_Efectivo		DECIMAL(18,2);
DEFINE Pago_Cuenta			DECIMAL(18,2);
DEFINE Monto_Operacion		DECIMAL(18,2);
DEFINE Saldo_Actual			DECIMAL(18,2);
DEFINE Status_Actual		CHAR(60);
DEFINE iIntAux				INTEGER;
DEFINE cCharAux				CHAR(80);
DEFINE dDecAux				DECIMAL(18,2);
DEFINE dtDateAux			DATE;
DEFINE dPagoMinAct			DECIMAL(18,2);
DEFINE dSdoCapInsolutoPP	DECIMAL(18,2);
DEFINE dSdoAdeudTotalAct	DECIMAL(18,2);
DEFINE cFolio				INTEGER;

define cMensaje3 char(50);
DEFINE scont INT8;

LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= "";
LET cCodRet				= "00000";
LET cMensaje			= "Se realiza el proceso exitosamente";
LET cNumCreditocrd		= pNumCredito;
LET cCredito_promo		= "";
LET cCredito_promo		= "";
LET dtFechaProxPago		= mdy(1, 1, 1900);
LET dtFechaApertura		= mdy(1, 1, 1900);
LET Cuenta_eje			= "";
LET Producto			= "";
LET Num_Cliente			= "";
LET Nom_Cliente			= "";
LET Pago_Efectivo		= 0;
LET Pago_Cuenta			= 0;
LET Monto_Operacion		= 0;
LET Saldo_Actual		= 0;
LET Status_Actual		= "";
LET iIntAux				= 0;
LET cCharAux			= "";
LET dDecAux				= 0;
LET dtDateAux			= DATE(1);
LET dPagoMinAct			= 0;
LET dSdoCapInsolutoPP	= 0;
LET dSdoAdeudTotalAct	= 0;
LET cNumCreditocrdsol   = pNumCredito;
LET cFolio				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr in (-255) THEN
            SET DEBUG FILE TO "/RESPALDOSNEW/sp_cs_pago_anticipado.out";
            TRACE ON;
        else	
--		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = cErrorInfo;
			RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
		END IF;
	END EXCEPTION;



IF NVL(pEmpresa,"")= "" OR  NVL(pNumCredito,"") = "" OR NVL(pProducto,"") = "" OR NVL(pMontoOperacionEfec,"") = "" OR NVL(pMontoOperacionCargCuenta,"")  = "" OR NVL(pUsuario,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pFolio,"") = "" OR NVL(pTransaccion,"") = "" THEN

	LET cCodRet      = "00411";
     LET cMensaje  = "NO HAY ARGUMENTOS (PARAMETROS)";

		RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
END IF;

--SET DEBUG FILE TO "/tmp/sp_cs_pago_anticipado.out";
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		SELECT a.num_credito
			INTO cCredito_promo
		FROM bdicred: "informix".sd_promocion_credito a, bdicred: "informix".sd_maecredcrd b, bdicred: "informix".sd_maecredanexocrd c
		WHERE a.empresa = pempresa
			AND a.empresa = b.empresa
			AND a.empresa = c.empresa
			and a.num_sol_prestamo = cNumCreditocrd
			AND a.num_sol_prestamo = b.num_credito
			AND a.num_sol_prestamo = c.num_credito
			AND num_pro_prestamo = pproducto
			AND a.status = 2
			AND b.status_cred IN ('AA','E1');

		IF ( cCredito_promo IS NOT NULL ) THEN

				CALL "informix".sp_principal_suc_rr(pempresa,cNumCreditocrd, pproducto,pMontoOperacionEfec,pMontoOperacionCargCuenta,pUsuario,pSucursal,pFolio,pTransaccion)
				RETURNING cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual;

				--AAME INC 27 108 Se castea la variable de retorno para que cuando el codigoret sea "000" exito o "00000" los tome igual
				IF (cCodRet::INTEGER <> 0) THEN
					IF cCodRet = "00044" THEN
						LET cCodRet = "01088";
						LET cMensaje = "Cliente no tiene cuenta efectiva";
					ELIF cCodRet = "00195" THEN
						LET cCodRet = "01094";
						LET cMensaje = "Cuenta del cliente no esta activa";
					ELIF cCodRet = "00199" THEN
						LET cCodRet = "001093";
						LET cMensaje = "Cuenta del cliente bloqueada";
					ELIF cCodRet = "00194" THEN
						LET cCodRet = "001095";
						LET cMensaje = "Cuenta sin saldo";
					END IF;

					RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
				ELSE


					EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pempresa,cNumCreditocrd)
						INTO cCodRet,cMensaje,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
					iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
					dsdocapinsolutopp,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
					dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dDecAux,dDecAux,
					dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
					cCharAux,cCharAux,iIntAux,cCharAux;

					IF  pTransaccion = '623' THEN

					   LET pMontoOperacionEfec = pMontoOperacionCargCuenta;
					END IF;
					--EM 24/03/2017
					--AAME INC 27 108 Se elimina IF NOT EXITS a peticiÃÂ³n de Base de Datos
					SELECT count(folio_suc) INTO cFolio
					FROM bdicred: "informix".sd_pago_anticipado_cs WHERE folio_suc = pFolio;
					
					IF cFolio = 0 THEN
					  INSERT INTO bdicred: "informix".sd_pago_anticipado_cs(empresa,folio_suc,fecha_mov,producto,num_credito,tarjeta,monto_pago,saldo_actual,fechaproximopago,transaccion)
                      VALUES (pempresa,pFolio,TODAY,pproducto,cNumCreditocrd,'',pMontoOperacionEfec,dSdoAdeudTotalAct,dtFechaProxPago,pTransaccion);
					ELSE
						UPDATE bdicred: "informix".sd_pago_anticipado_cs
						SET  fecha_mov= TODAY, producto= pproducto, num_credito= cNumCreditocrd, tarjeta= '', monto_pago= pMontoOperacionEfec, saldo_actual= dSdoAdeudTotalAct, fechaproximopago= dtFechaProxPago, transaccion= pTransaccion
						WHERE folio_suc= pFolio and empresa= pempresa;
					END IF;

					LET cMensaje   = "Se realiza el proceso exitosamente";

				   -- DSB - TH - 16-02-2015
					LET Saldo_Actual = dSdoAdeudTotalAct;

					--UPDATE bdicred: "informix".sd_promocion_credito
					--	SET monto_actual = dSdoAdeudTotalAct, folio_suc_mov_crd = pFolio
					--WHERE empresa = pempresa and num_sol_prestamo = cNumCreditocrdsol;
				END IF;

		ELSE
			LET cCodRet = "00002";
			LET cMensaje   = "La credisolucion no existe";
		END IF;
	RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
END
END PROCEDURE
DOCUMENT

'DESCRIPCIÃÂ?N: PROCEDURE QUE PARA INVOCAR EL PAGO ANTICIPADO DE CREDISOLUCIONES',
'FECHA DE MODIFICACIÃÂ?N: 28-11-2015',
'BASE DE DATOS: BDICRED',
'MODIFICÃÂ?: YADIRA MORALES ZAZUETA',
'----------------------------------------------------------------------------',
'Descripcion : se agrega consulta de credito en sd_promocion_credito de credisoluciones para respaldar',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 07/02/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : se agrega modifica para que imprima en ticket sd_pago_anticipado_cs.saldo_actual ',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 16/02/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para actualizar folio suc en la tabla sd_promocion_credito cuando se hace un pago, se filtra para que inserte en sd_pago_anticipado_cs ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 08/003/2017,--EM 24/03/2017',
'BD          : bdicred';

CREATE PROCEDURE "informix".sp_liquida_credito(P_EMPRESA        VARCHAR(3) ,
                                               P_NUM_SOLICITUD  VARCHAR(20),
                                               P_FOLIO          VARCHAR(20))

RETURNING VARCHAR(5), VARCHAR(80);

DEFINE vCodRet          VARCHAR(5);
DEFINE vMensaje         VARCHAR(80);
DEFINE vFuncion         VARCHAR(3);
DEFINE vCodComis        VARCHAR(4);
DEFINE vNumCte          VARCHAR(20);
DEFINE vTarjeta         VARCHAR(20);
DEFINE eRror_Info       VARCHAR(80);
DEFINE vNumCredOld      VARCHAR(20);
DEFINE vVigente         DECIMAL(14,2);
DEFINE vVencido         DECIMAL(14,2);
DEFINE vVencTrasp       DECIMAL(14,2);
DEFINE vIntNoExig       DECIMAL(14,2);
DEFINE vIntVenc         DECIMAL(14,2);
DEFINE vIntVencTrasp    DECIMAL(14,2);
DEFINE vIvaIntNoExig       DECIMAL(14,2);
DEFINE vIvaIntVenc         DECIMAL(14,2);
DEFINE vIvaIntVencTrasp    DECIMAL(14,2);
DEFINE vSdoSeg          DECIMAL(18,2);
DEFINE vTotSdoSeg       DECIMAL(18,2);
DEFINE vMora            DECIMAL(14,2);
DEFINE vMtoComis        DECIMAL(14,2);
DEFINE vNumProducto     CHAR(4);
DEFINE vSucursal        CHAR(4);
DEFINE vdivisa          CHAR(2);
DEFINE vFolio           CHAR(16);
DEFINE vComision        CHAR(4);
DEFINE vEvento          CHAR(2);
DEFINE vHoy             DATE;
DEFINE vNumConfirma     INTEGER;
DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE vDiasCalc        SMALLINT;
DEFINE vMtoCopete       DECIMAL(14,2);
DEFINE vIvaMtoCopete    DECIMAL(14,2);
DEFINE vIvaMtoOrdi      DECIMAL(14,2);
DEFINE vMtoTotal        DECIMAL(14,2);
DEFINE vLimite_aut      DECIMAL(14,2);
DEFINE vIvaSuc          CHAR(5);
DEFINE vinteresvend  DECIMAL(14,2);
DEFINE vivavend      DECIMAL(14,2);
define vtasa         date;
define vfecaper      date;
define vfecuota      date;
define v_usuario      varchar(8);
define vcadena integer;

define vstatus_tdc char(2);
 -- set debug file to "/tmp/liquida_cred.out";
 -- trace on;

  --BEGIN WORK;

  --ASIGNA VALORES A LAS VARIABLES
  LET vCodRet        = '00000';
  LET vMensaje       = 'PROCESO EXITOSO';
  LET vFuncion       = '338';
  LET vNumConfirma   = 0;
  LET vCodComis      = '';
  LET vNumCte        = '';
  LET eRror_Info     = '';
  LET vNumCredOld    = '';
  LET vVigente       = 0;
  LET vVencido       = 0;
  LET vVencTrasp     = 0;
  LET vIntNoExig     = 0;
  LET vIntVenc       = 0;
  LET vIntVencTrasp  = 0;
  LET vIvaIntNoExig     = 0;
  LET vIvaIntVenc       = 0;
  LET vIvaIntVencTrasp  = 0;
  LET vSdoSeg        = 0;
  LET vTotSdoSeg     = 0;
  LET vMora          = 0;
  LET vMtoComis      = 0;
  LET vNumProducto   = '';
  LET vSucursal      = '';
  LET vdivisa        = '';
  LET vFolio         = '';
  LET vComision      = '';
  LET vEvento        = '';
  LET vHoy           = '';
  LET vMtoCopete     = 0;
  LET vIvaMtoOrdi    = 0;
  LET vIvaMtoCopete  = 0;
  LET vNumCredOld    = P_NUM_SOLICITUD;
  LET vFolio         = P_FOLIO;
  LET vMtoTotal      = 0;
  LET vLimite_aut    = 0;
LET vstatus_tdc = '';
  -- SACA EL I.V.A DEL SD_PARAM
    SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
    WHERE cod_param = "12"
    AND empresa = P_EMPRESA;


  --LEE LA INFORMACION DEL CREDITO
     SELECT num_producto, sucursal, divisa, NUMCTE,status_cred
     INTO   vNumProducto, vSucursal,
            vdivisa, vNumCte,vstatus_tdc
     FROM   sd_maecred
     WHERE  empresa     = P_EMPRESA AND
            num_credito = vNumCredOld;

{ -- Lo cambian al Monto Otorgado Solicitado BAncoppel 05102009
    SELECT limite_aut
      INTO vLimite_aut
      FROM sd_tarjeta
     WHERE empresa  = P_EMPRESA AND
           num_credito = vNumCredOld;   }
    SELECT monto_otorgado
      INTO vLimite_aut
      FROM sd_maesdos
     WHERE empresa  = P_EMPRESA AND
           num_credito = vNumCredOld;


     -- Respada Credito a Liquidar

    CALL RespaldaCrd(P_EMPRESA,vNumCredOld,vFolio) RETURNING vCodRet;
    IF vCodRet <> "000" THEN
       --ROLLBACK WORK;
       LET vMensaje ="Al Respaldar Credito a Renovar";
       RETURN vCodRet, vMensaje;
    ELSE
       LET vCodRet ="00000";
    END IF;

    SELECT  fecha_hoy
    INTO  vHoy
    FROM sd_fechas;

    -- Realpalda a Cartera Vendida
    CALL respventacr(P_EMPRESA,vNumCredOld,vHoy) RETURNING vCodRet;
    IF vCodRet <> "000" THEN
       --ROLLBACK WORK;
       LET vMensaje ="Al Respaldar Credito a Vender";
       RETURN vCodRet, vMensaje;
    ELSE
       LET vCodRet ="00000";
    END IF;

    -- Capital Vigente,Vencido Transitorio, Vencido Traspasado
    SELECT sdo_capital + cap_tras_no_venci,monto_vencido,mto_venc_trasp --Capitales
    INTO   vVigente,vVencido,vVencTrasp
    FROM   sd_maesdos
    WHERE  empresa = P_EMPRESA AND
           NUM_credito = vNumCredOld;

    -- Corrigen el Cliente y siempre si quiere el Monto Autorizado 22 Agos 2009 MEL
    --LET vLimite_aut = vLimite_aut - vVigente - vVencTrasp - vVencido;

    SELECT NVL(sum(interes_debe),0), NVL(sum(iva_debe - iva_pagado),0)
    INTO   vIntNoExig, vIvaIntNoExig
    FROM   bdicred:sd_amortiza_credito
    WHERE  empresa     = P_EMPRESA
      AND  num_credito = vNumCredOld
      AND  capital_status = '1';

    SELECT NVL(sum(interes_debe - interes_pagado),0), NVL(sum(iva_debe - iva_pagado),0)
    INTO   vIntVencTrasp, vIvaIntVencTrasp
    FROM   bdicred:sd_amortiza_credito
    WHERE  empresa     = P_EMPRESA
      AND  num_credito = vNumCredOld
      AND  capital_status in( '2','6');

    --Cancelacion De Mora Copete

   SELECT sum( mora_provi_cope+  mora_sdo_cope - mora_sdo_cope_pag)
   INTO   vMtoCopete
   FROM   sd_amortiza_credito
   WHERE  empresa     = P_EMPRESA
   AND    num_credito = vNumCredOld
   AND  capital_status in('7', '2','6');
   
   IF vMtoCopete > 0 THEN
      LET vIvaMtoCopete = vMtoCopete *  vIvaSuc;
   ELSE
      LET vIvaMtoCopete = 0;
   END IF;

    --Cancelacion De Mora Ordinari

   SELECT sum(mora_provi_ordi +  mora_sdo_ordi - mora_sdo_ordi_pag)
   INTO   vMora
   FROM   sd_amortiza_credito
   WHERE  empresa     = P_EMPRESA
   AND    num_credito = vNumCredOld
   AND  capital_status in('7', '2','6');
   
   IF vMora > 0 THEN
      LET vIvaMtoOrdi = vMora *  vIvaSuc ;
   ELSE
      LET vIvaMtoOrdi = 0;
   END IF;


   IF vMtoCopete > 0 THEN
     CALL genmov(P_EMPRESA, vNumCredOld, vNumProducto,16,
                 vFuncion, vHoy, vMtoCopete,
                 vFolio, vSucursal, vDivisa, '0000')
     RETURNING vCodRet, vMensaje;
     IF vCodRet <> "00000" THEN
       RETURN vCodRet, vMensaje;
     END IF;
 --     LET vMtoTotal = vMtoTotal + vMtoCopete;
    END IF;

    --Cancelacion De Iva Mora Copete

   IF vIvaMtoCopete > 0 THEN
     CALL genmov(P_EMPRESA, vNumCredOld, vNumProducto,17,
                 vFuncion, vHoy, vIvaMtoCopete,
                 vFolio, vSucursal, vDivisa, '0000')
     RETURNING vCodRet, vMensaje;
     IF vCodRet <> "00000" THEN
       RETURN vCodRet, vMensaje;
     END IF;
   --  LET vMtoTotal = vMtoTotal + vIvaMtoCopete;
   END IF;

     -- Liquida o Traspasa el Capital Vigente Segun Corresponda
    IF vVigente > 0 then
    
        IF  vstatus_tdc =  'E2' THEN  --IFRS
            EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, 30,
                                     vFuncion, vHoy, vVigente, vFolio, vSucursal,
                                     vdivisa, "0000"
                                     ) INTO vCodRet, vMensaje;
    
            IF vCodRet <> "00000" THEN
              --ROLLBACK WORK;
              RETURN vCodRet, vMensaje;
            END IF; 
        ELSE
            --se reunitiza para E3
            EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, 20,
                                     vFuncion, vHoy, vVigente, vFolio, vSucursal,
                                     vdivisa, "0000"
                                     ) INTO vCodRet, vMensaje;
    
            IF vCodRet <> "00000" THEN
              --ROLLBACK WORK;
              RETURN vCodRet, vMensaje;
            END IF;
         END IF;   
        LET vMtoTotal = vMtoTotal + vVigente;
    END IF;

    LET vMtoTotal = vMtoTotal;
     -- Liquida o Traspasa el Interes Vigente Segun Corresponda
    IF vVencido > 0 then
    
        IF  vstatus_tdc =  'E2' THEN  --IFRS
            EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto,29,
                                     vFuncion, vHoy, vVencido, vFolio, vSucursal,
                                     vdivisa, "0000"
                                     ) INTO vCodRet, vMensaje;
    
            IF vCodRet <> "00000" THEN
              --ROLLBACK WORK;
              RETURN vCodRet, vMensaje;
            END IF; 
        ELSE
            --se reunitiza para E3
           EXECUTE PROCEDURE genmov(P_EMPRESA, vNumCredOld, vNumProducto, 19,
                                    vFuncion, vHoy, vVencido, vFolio, vSucursal,
                                    vdivisa, "0000") INTO vCodRet, vMensaje;
    
    
            IF vCodRet <> "00000" THEN
               --ROLLBACK WORK;
               RETURN vCodRet, vMensaje;
            END IF;
      END IF;      
      LET vMtoTotal = vMtoTotal + vVencido;
    END IF;

    LET vMtoTotal = vMtoTotal;
    -- Liquida o Traspasa el Capital Vencido Segun Corresponda
    --EN IFRS no entrara por que no serÃ  mayor a 0
    IF vVencTrasp > 0 then
       EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, 19,
                                vFuncion, vHoy, vVencTrasp, vFolio, vSucursal,
                                vdivisa, "0000"
                                ) INTO vCodRet, vMensaje;

        IF vCodRet <> "00000" THEN
          --ROLLBACK WORK;
          RETURN vCodRet, vMensaje;
        END IF;

        LET vMtoTotal = vMtoTotal + vVencTrasp;
    END IF;

    LET vMtoTotal = vMtoTotal;
     -- Liquida o Traspasa el Interes Vigente Segun Corresponda
    IF vIntNoExig > 0 then
       EXECUTE PROCEDURE genmov(P_EMPRESA, vNumCredOld, vNumProducto, 18,
                                vFuncion, vHoy, vIntNoExig, vFolio, vSucursal,
                                vdivisa, "0000") INTO vCodRet, vMensaje;


        IF vCodRet <> "00000" THEN
           --ROLLBACK WORK;
           RETURN vCodRet, vMensaje;
        END IF;
        LET vMtoTotal = vMtoTotal + vIntNoExig;
    END IF;

    LET vMtoTotal = vMtoTotal;
     -- Liquida o Traspasa el Iva de Interes Vigente Segun Corresponda
    IF vIvaIntNoExig > 0 then
       EXECUTE PROCEDURE genmov(P_EMPRESA, vNumCredOld, vNumProducto, 2,
                                vFuncion, vHoy, vIvaIntNoExig, vFolio, vSucursal,
                                vdivisa, "0000") INTO vCodRet, vMensaje;


        IF vCodRet <> "00000" THEN
           --ROLLBACK WORK;
           RETURN vCodRet, vMensaje;
        END IF;
        LET vMtoTotal = vMtoTotal + vIvaIntNoExig;
    END IF;


    LET vMtoTotal = vMtoTotal;

    -- Liquida o Traspasa el Interes Vencido Segun Corresponda

    IF vIntVencTrasp > 0 then
        IF  vstatus_tdc =  'E2' THEN  --IFRS
            EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto,31,
                                     vFuncion, vHoy, vIntVencTrasp, vFolio, vSucursal,
                                     vdivisa, "0000"
                                     ) INTO vCodRet, vMensaje;
    
            IF vCodRet <> "00000" THEN
              --ROLLBACK WORK;
              RETURN vCodRet, vMensaje;
            END IF; 
        ELSE
            --se reunitiza para E3  
           EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, 21,
                                    vFuncion, vHoy, vIntVencTrasp, vFolio, vSucursal,
                                    vdivisa, "0000"
                                    ) INTO vCodRet, vMensaje;
    
           IF vCodRet <> "00000" THEN
              --ROLLBACK WORK;
              RETURN vCodRet, vMensaje;
           END IF;
        END IF;   
       LET vMtoTotal = vMtoTotal + vIntVencTrasp;
    END IF;

    LET vMtoTotal = vMtoTotal;
    -- Liquida o Traspasa el Iva de Interes Vencido Segun Corresponda
    IF vIvaIntVencTrasp > 0 then
    
    --IFRS poner contabilidad IVA
       EXECUTE PROCEDURE genmov(P_EMPRESA, vNumCredOld, vNumProducto, 3,
                                vFuncion, vHoy, vIvaIntVencTrasp, vFolio, vSucursal,
                                vdivisa, "0000") INTO vCodRet, vMensaje;


        IF vCodRet <> "00000" THEN
           --ROLLBACK WORK;
           RETURN vCodRet, vMensaje;
        END IF;
        LET vMtoTotal = vMtoTotal + vIvaIntVencTrasp;
     END IF;

    LET vMtoTotal = vMtoTotal;
     -- Liquida el Interes Transitorio
     --IFRS siempre viene en 0
     IF vIntVenc > 0 then
         EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, 21,
                                  vFuncion, vHoy, vIntVenc, vFolio, vSucursal,
                                  vdivisa, "0000"
                                  ) INTO vCodRet, vMensaje;

         IF vCodRet <> "00000" THEN
            --ROLLBACK WORK;
            RETURN vCodRet, vMensaje;
         END IF;
         LET vMtoTotal = vMtoTotal + vIntVenc;
     END IF;
     
    LET vMtoTotal = vMtoTotal;
    -- Liquida o Traspasa el Iva de Interes Vencido Transitorio Segun Corresponda
     --IFRS siempre viene en 0 
    IF vIvaIntVenc > 0 then
       EXECUTE PROCEDURE genmov(P_EMPRESA, vNumCredOld, vNumProducto, 3,
                                vFuncion, vHoy, vIvaIntVenc, vFolio, vSucursal,
                                vdivisa, "0000") INTO vCodRet, vMensaje;

        IF vCodRet <> "00000" THEN
           --ROLLBACK WORK;
           RETURN vCodRet, vMensaje;
        END IF;
        LET vMtoTotal = vMtoTotal + vIvaIntVenc;
    END IF;
	
    LET vMtoTotal = vMtoTotal;
    -- Liquida o Traspasa el Interes Moratorio Segun Corresponda
    IF vMora > 0 then
        EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, 22,
                                 vFuncion, vHoy, vMora, vFolio, vSucursal,
                                 vdivisa, "0000"
                                 ) INTO vCodRet, vMensaje;


        IF vCodRet <> "00000" THEN
          --ROLLBACK WORK;
          RETURN vCodRet, vMensaje;
        END IF;
        LET vMtoTotal = vMtoTotal + vMora;
    END IF ;

    LET vMtoTotal = vMtoTotal;
    -- Liquida o Traspasa el Iva Interes Moratorio

    IF vIvaMtoOrdi > 0 THEN
       EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, 23,
                             vFuncion, vHoy, vIvaMtoOrdi, vFolio, vSucursal,
                             vdivisa, "0000"
                            ) INTO vCodRet, vMensaje;
     IF vCodRet <> "00000" THEN
       RETURN vCodRet, vMensaje;
     END IF;
     LET vMtoTotal = vMtoTotal + vIvaMtoOrdi;
   END IF;

    LET vMtoTotal = vMtoTotal;

   EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, 1,
                            vFuncion, vHoy, vLimite_aut, vFolio, vSucursal,
                            vdivisa, "0000"
                            ) INTO vCodRet, vMensaje;


   IF vCodRet <> "00000" THEN
      --ROLLBACK WORK;
      RETURN vCodRet, vMensaje;
   END IF;

   -- BGM 25-May-10 Se cambia el orden para obtener los intereses transcurridos, de modo que se incluyan en el total de la baja
   -- para el movimiento no contable codigo fun = '001' y codigo_ref = '4'
   
   select sdo_intereses into vinteresvend
   from sd_maesdos_vendida
    WHERE empresa     = p_empresa
         AND num_credito = vNumCredOld;
   if vinteresvend is null then let vinteresvend = 0; end if;

   if vinteresvend > 0 then
    select tasa_interes,fecha_apertura
      into vtasa,vfecaper
      from sd_maecred
      WHERE empresa     = p_empresa
         AND num_credito = vNumCredOld;
      select fecha_hoy into vhoy
        from sd_fechas;
     SELECT max(fecha_cuota)
	INTO vfecuota
	FROM bdicred:sd_amortiza_credito
     WHERE empresa     = p_empresa
         AND num_credito = vNumCredOld
    	  AND capital_status = '1';
      call calc_iva_grav_pp(p_empresa,vNumCredOld,vtasa,vIvaSuc,vHoy,null,
          vfecaper,vfecuota,vinteresvend)
       returning    vCodRet,vivavend,vMensaje;
      IF vinteresvend > 0 THEN
             EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, 18,
                                   "338", vHoy, vinteresvend, vFolio, vSucursal,
                                   vdivisa, "0000"
                                  ) INTO vCodRet, vMensaje;
           IF vCodRet <> "00000" THEN
             RETURN vCodRet, vMensaje;
      END IF;
      LET vMtoTotal = vMtoTotal + vinteresvend;
     END IF;
     IF vivavend > 0 THEN
            EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, 2,
                                  "338", vHoy, vivavend, vFolio, vSucursal,
                                  vdivisa, "0000"
                                 ) INTO vCodRet, vMensaje;
          IF vCodRet <> "00000" THEN
            RETURN vCodRet, vMensaje;
          END IF;
          LET vMtoTotal = vMtoTotal + vivavend;
     END IF;

   end if
   
    LET vMtoTotal = vMtoTotal;
   IF vLimite_aut > 0 then
      EXECUTE PROCEDURE genmov(p_empresa, vNumCredOld, vNumProducto, '4',
                               '001', vHoy, vMtoTotal, vFolio, vSucursal,
                               vdivisa, "0000"
                               ) INTO vCodRet, vMensaje;

      IF vCodRet <> "00000" THEN
         RETURN vCodRet, vMensaje;
      END IF;

   END IF;

    LET vMtoTotal = vMtoTotal;
      UPDATE sd_amortiza_credito SET capital_pagado = capital_debe,
       	capital_status = "5", capital_status_ant = capital_status
      WHERE num_credito = vNumCredOld
        AND empresa = p_empresa
        AND capital_status <> "5";

     UPDATE sd_amortiza_credito SET interes_pagado = interes_debe,
         interes_status = "5", interes_status_ant = interes_status
     WHERE num_credito = vNumCredOld
       AND empresa = p_empresa
       AND interes_status <> "5";


     UPDATE sd_maesdos
        SET  sdo_no_exig       = 0,
             sdo_exig_int      = 0,
             sdo_moratorio     = 0,
             sdo_capital       = 0,
             sdo_cap_insoluto  = 0,
             monto_vencido     = 0,
             mto_venc_trasp    = 0,
             mto_venc_int      = 0,
             mto_venc_tra_int  = 0,
             sdo_global_int    = 0,
             sdo_intereses     = 0,
             cap_tras_no_venci = 0,
             int_tra_no_exig   = 0,
             monto_financiado  = 0
       WHERE num_credito = vNumCredOld
         AND empresa = p_empresa ;

     UPDATE sd_maecred SET status_cred = "FC"
      WHERE num_credito = vNumCredOld
        AND empresa = p_empresa ;

  --**Cancelacion de Tarjeta de Credito

 LET vcadena = length(vFolio) - 8;
  LET v_usuario    = substr(vFolio,1,vcadena);

  FOREACH 
       select  num_tarjeta 
         into vTarjeta 
         from sd_tarjeta
        WHERE empresa = p_empresa
          AND num_credito = vNumCredOld
          AND tipo_tarjeta IN ('T','A')
          AND status_tar='A'

        SELECT numtarjeta,codproductotarjeta 
          INTO vTarjeta,vNumProducto
          FROM intercard:tarjeta
         WHERE numtarjeta = vTarjeta
           AND codstatustarjeta='ACT';

           IF vNumProducto IS NOT NULL THEN
                call intercard:sp_cancelacion_tarjeta
                (vTarjeta, vNumProducto,v_usuario)
                RETURNING vCodRet, vMensaje;
                IF vCodRet <> "000" THEN
                   let vMensaje = "Intercard genero problema";
                   RETURN vCodRet, vMensaje;
                else
                    let vCodRet = "00000";
                END IF;
            END IF;
  END FOREACH;

  UPDATE sd_tarjeta
     SET status_tar = 'C'
   WHERE empresa = p_empresa
     AND num_credito = vNumCredOld;
  RETURN vCodRet, vMensaje;
END PROCEDURE
;