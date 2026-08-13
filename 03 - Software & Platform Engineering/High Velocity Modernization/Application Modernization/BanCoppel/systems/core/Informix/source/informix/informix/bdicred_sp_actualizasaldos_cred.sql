CREATE PROCEDURE "informix".sp_actualizasaldos_cred(pempresa CHAR(3),pNumcredito CHAR(20),pNumProd CHAR(4), pMontoEfec MONEY(14,2), pMontoCargo MONEY(14,2),pFolioMovto CHAR(20) DEFAULT "",pSucursal CHAR(4), pUsuario CHAR(20))
 RETURNING CHAR(6), CHAR(80);

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(100);
DEFINE CodRet                        CHAR(6);
DEFINE codretRev					 CHAR(5);
DEFINE Mensaje                       CHAR(80);

DEFINE cCredito_promo                CHAR(20);
DEFINE cfolio_suc_promo              CHAR(16);
DEFINE cfolio_mov_promo              CHAR(16);
DEFINE dFecha	                     DATE;
DEFINE v_fecha_hoy                   DATE;
DEFINE dtFechaMesiversario           DATE;

DEFINE cNumTarjeta  		CHAR(20);
DEFINE cFolio               CHAR(16);
DEFINE cBegin               CHAR(1);
DEFINE  vlStatusCred        CHAR(2);
DEFINE g_Remanente						MONEY(14,2);
DEFINE g_IntMoraCob 					MONEY(14,2);
DEFINE g_IntVencCob 					MONEY(14,2);
DEFINE g_CapVencCob 					MONEY(14,2);
DEFINE g_IntVigCob 						MONEY(14,2);
DEFINE g_CapVigCob 						MONEY(14,2);
DEFINE g_Impuesto 						MONEY(14,2);
DEFINE g_Comision 						MONEY(14,2);
DEFINE g_Seguro							MONEY(14,2);
DEFINE g_SdoCapInsol					MONEY(14,2);

DEFINE v_tipocambio     DECIMAL(14,6);
DEFINE mMonto                         MONEY(14,2);
DEFINE cTrans           CHAR(4);

DEFINE mTasa		MONEY(14,2);

DEFINE iDiasMes		INTEGER;

DEFINE vmto_final_cs    MONEY(14,2);
DEFINE v_capital_cs     MONEY(14,2);
DEFINE v_interes_cs     MONEY(14,2);
DEFINE v_iva_cs         MONEY(14,2);
DEFINE GLOBAL g_Empresa        CHAR(3)     DEFAULT ' ';
DEFINE GLOBAL g_NumCredito     CHAR(20)    DEFAULT ' ';
DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';
DEFINE g_Cuenta			CHAR(20);
DEFINE g_Trans 		CHAR(4);
DEFINE mSdoDisp money(14,2);
DEFINE mMontoRet money(14,2);
DEFINE cPasoCargo char(1);
DEFINE cTranPFSI_aux	CHAR(4);
DEFINE cTranCargoTdc	CHAR(4);

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
			  LET CodRet     = iSqlErr;
			  LET Mensaje = cErrorInfo;

		  IF cBegin = "S" THEN
			  ROLLBACK WORK;
		   END IF;

		   RETURN CodRet,Mensaje;
	   END IF;
	END EXCEPTION;

LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET CodRet              = "000000";
LET codretRev           = "00000";
LET Mensaje   = "Se realizÃÂÃÂ³ el proceso exitosamente";

LET cCredito_promo      = '';
LET cfolio_suc_promo    = '';
LET cfolio_mov_promo    = '';
LET dFecha             = DATE(1);
LET v_fecha_hoy = DATE(1);
LET dtFechaMesiversario = DATE(1);

LET cBegin           = "N";

LET v_tipocambio     = 0;
LET mMonto           =0;
LET cTrans           ="";

LET mTasa            = 0;

LET iDiasMes		 = 0;

LET vmto_final_cs    = 0;
LET v_capital_cs     = 0;
LET v_interes_cs     = 0;
LET v_iva_cs         = 0;
LET g_SdoCapInsol	 = 0;
LET g_Cuenta         = '';
LET g_Trans      	 = '';
LET mSdoDisp 	 	 = '';
LET mMontoRet 	 	 = 0;
LET cPasoCargo 		 = '';
LET vlStatusCred    = '';
LET cTranPFSI_aux	= '';
LET cTranCargoTdc	= '';



 --SET DEBUG FILE TO "/respaldosbd/Efrain/188-lib29/Saldos/sp_actualizasaldos_cred.out";
 --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    --SET PDQPRIORITY 10;
	SET LOCK MODE TO WAIT 3;
	
	 IF pNumProd = 'PFSI' THEN
		LET pNumProd = '6900';
		LET cTranPFSI_aux = '8654';
	 END IF;

	SELECT fecha_hoy INTO v_fecha_hoy
    FROM bdicred: "informix".sd_fechas a
    WHERE a.empresa = pEmpresa;


	--SE OBTIENE LA TRANSACCION PARA EL PAGO
	--ME 17/04/2018
	IF pMontoEfec > 0 THEN 			--PAGO ANTICIPADO EFECTIVO
		LET cTrans    = "8151";		--SU PAGO CREDISOLUCIONES EFECTIVO
		LET mMonto=pMontoEfec;
	ELIF pMontoCargo > 0 THEN		--PAGO ANTICIPADO CON CARGO A CUENTA
		LET cTrans    = "8150";		--SU PAGO CREDISOLUCIONES CARGO X CTA
		LET mMonto=pMontoCargo;
	END IF;
		
	--LET folio_suc=folio_suc;

	SELECT monto,mv_interes_cs,mv_iva_cs,mv_capital_cs
	INTO vmto_final_cs, v_interes_cs, v_iva_cs, v_capital_cs
	FROM bdicred: "informix".sd_montopagcrd where folio =  pFolioMovto;

	--FMV 21Jul14: Reasignacion de la variable global para generar los movimientos en la fecha correcta.

	--FOREACH WITH HOLD  --FMV 15JUL14: Se adiciona with hold, ya que solo cobraba 1 credisolucion en vencimiento.
		SELECT a.fecha, a.num_credito,a.folio_suc,a.folio_movto, c.prox_fecha_pago,a.num_tarjeta
		INTO dFecha,cCredito_promo,cfolio_suc_promo,cfolio_mov_promo,dtFechaMesiversario,cNumTarjeta
		FROM bdicred: "informix".sd_promocion_credito a, bdicred: "informix".sd_maecredcrd b, bdicred: "informix".sd_maecredanexocrd c
		WHERE a.empresa = pempresa
		AND a.empresa = b.empresa
		AND a.empresa = c.empresa
		and a.num_sol_prestamo = pNumcredito
		AND a.num_sol_prestamo = b.num_credito
		AND a.num_sol_prestamo = c.num_credito
		AND num_pro_prestamo = '6900';
		--AND a.status = 2
		--AND b.status_cred = 'AA';

		LET cCredito_promo = cCredito_promo;
		--- PROCESO GENERICO PARA GENERAR UN FOLIO PARA LA PROMOCION
		/*	EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pUsuario)
		INTO CodRet,g_Folio;
		IF CodRet::INTEGER <> 0 THEN
			SELECT descripcion
			INTO Mensaje
			FROM bdinteg:"informix".si_codret
			WHERE empresa        = pEmpresa
			AND codigo_retorno = CodRet;

			ROLLBACK WORK;
            IF cBegin = "S" THEN
				BEGIN WORK;
			END IF;

			RETURN CodRet,Mensaje;
		END IF;*/
		-- AAME 25102018 INC 27 108 Se actualiza la variable del folio con el que se generÃÂÃÂ³ de la credisolucion para guardar respaldo
        LET g_Folio =  pFolioMovto;
		--Inicia Respaldo de Tablas de Reversion
		LET g_NumCredito = cCredito_promo;
		CALL RespaldaCredito() RETURNING CodRet;
		IF (CodRet <> "000") THEN
			SELECT descripcion
			INTO Mensaje
			FROM bdinteg:"informix".si_codret
			WHERE empresa        = pEmpresa
			AND codigo_retorno = CodRet;

			ROLLBACK WORK;
			IF cBegin = "S" THEN
				BEGIN WORK;
			END IF;

			RETURN CodRet,Mensaje;
		END IF;
		IF ( cCredito_promo is not null ) THEN

			--8150 y 8151         RECUPERACION CREDISOLUCIONES ANTICIPADO
			--BEGIN WORK;
			LET cBegin = "S";

			IF pMontoEfec > 0 or pMontoCargo >0  THEN
			--4202         IVA CREDISOLUCIONES ANTICIPADO
				IF v_iva_cs <> 0 THEN
					
					IF cTranPFSI_aux = '8654' THEN LET cTranCargoTdc = '4202'; ELSE LET cTranCargoTdc = '8233'; END IF;
						
					CALL "informix".cargo_cred(pempresa,cCredito_promo,pSucursal,pUsuario,cTranCargoTdc, v_iva_cs,pFolioMovto, cNumTarjeta,0, v_tipocambio,v_fecha_hoy,pNumcredito, 'IVA CRED ANTICIPADO', dFecha)
					RETURNING CodRet;

					IF (CodRet <> "000") THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar el cargo de iva credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
                           END IF;
                           RETURN CodRet,Mensaje;
					END IF;

					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = monto - v_iva_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
					AND nvl(substr(referencia,18,3),'')= 'RET'
					AND estatus = 'R';
					
					--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						UPDATE bdicred: "informix".sd_maeretenido
						SET monto = monto - v_iva_cs
						WHERE empresa = '001'
						AND num_credito = cCredito_promo
						AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
						AND nvl(substr(referencia,18,3),'')= 'RET'
						AND estatus = 'R';				
					END IF;	

					UPDATE bdicred: "informix".sd_maesdos
					SET sdo_retenido = sdo_retenido - v_iva_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo;

					UPDATE bdicred: "informix".sd_promocion_credito
					SET monto_int_iva = monto_int_iva - v_iva_cs
					WHERE empresa = '001'
					AND num_sol_prestamo = pNumcredito;
				END IF;

				--4201         INTERES CREDISOLUCIONES ANTICIPADO
				IF v_interes_cs <> 0 THEN
				   
					IF cTranPFSI_aux = '8654' THEN LET cTranCargoTdc = '4201'; ELSE LET cTranCargoTdc = '8232'; END IF;
					   
					CALL "informix".cargo_cred(pempresa,cCredito_promo,pSucursal,pUsuario,cTranCargoTdc, v_interes_cs,pFolioMovto, cNumTarjeta,0, v_tipocambio,v_fecha_hoy,pNumcredito, 'INTERES CREDI ANTICI', dFecha)
					RETURNING CodRet;
					IF (CodRet <> "000") THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar el cargo de interes credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
						RETURN CodRet,Mensaje;
					END IF;

					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = monto - v_interes_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
					AND nvl(substr(referencia,18,3),'')= 'RET'
					AND estatus = 'R';					
						
					--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						UPDATE bdicred: "informix".sd_maeretenido
						SET monto = monto - v_interes_cs
						WHERE empresa = '001'
						AND num_credito = cCredito_promo
						AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
						AND nvl(substr(referencia,18,3),'')= 'RET'
						AND estatus = 'R';				
					END IF;	

					UPDATE bdicred: "informix".sd_maesdos
					SET sdo_retenido = sdo_retenido - v_interes_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo;

					UPDATE bdicred: "informix".sd_promocion_credito
					SET monto_int_iva = monto_int_iva - v_interes_cs
					WHERE empresa = '001'
					AND num_sol_prestamo = pNumcredito;
				END IF;

				--4200         CAPITAL CREDISOLUCIONES ANTICIPADO

				IF v_capital_cs <> 0 THEN
				   
					IF cTranPFSI_aux = '8654' THEN LET cTranCargoTdc = '4200'; ELSE LET cTranCargoTdc = '8231'; END IF;
				   
					CALL "informix".cargo_cred(pempresa,cCredito_promo,pSucursal,pUsuario,cTranCargoTdc, v_capital_cs,pFolioMovto, cNumTarjeta,0, v_tipocambio,v_fecha_hoy,pNumcredito, 'CAPITAL CRED ANTICI', dFecha)
					RETURNING CodRet;
					IF (CodRet <> "000") THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar el cargo de iva credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
						RETURN CodRet,Mensaje;
					END IF;

					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = monto - v_capital_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
					AND nvl(substr(referencia,18,3),'')= 'PAG'
					AND estatus = 'R';

					UPDATE bdicred: "informix".sd_maesdos
					SET sdo_retenido = sdo_retenido - v_capital_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo;

					UPDATE bdicred: "informix".sd_promocion_credito
					SET monto_actual = monto_actual - v_capital_cs
					WHERE empresa = '001'
					AND num_sol_prestamo = pNumcredito;
				END IF;
				
				LET g_Folio = pFolioMovto;

				IF cTrans = '8151' AND cTranPFSI_aux != '8654' Then  -- No ejecute el pago a la TDC cuando venga desde cargo automatico de Sdo a Favor para PF Sdo Inmediato.
					COMMIT WORK;
					CALL "informix".principalrefer(pempresa,cCredito_promo,'01',cNumTarjeta,USER,pSucursal,pFolioMovto,cTrans,0,mMonto,pNumcredito)
					RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
					
					IF (CodRet::integer <> 0  AND  CodRet::integer <> 1144) THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar la recuperacion del pago anticipado de credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
					END IF;
				Elif cTrans    = "8150" THEN
					-- DSB TH 20161108
					SELECT a.numcta
					INTO g_Cuenta
					FROM  "informix".sd_verif_cuentas_crd a
					WHERE a.empresa      = pempresa 
					AND a.numcredisol  = pNumcredito;
						  
					--LET =  TRIM(cCredito_promo::char(12)) || ' CRG. CTA. MONTOS DIFERIDOS';
					
					CALL "informix".sp_cgoctefva_abontdc(pempresa,pSucursal,pUsuario,'0438',cTrans,'0618',pFolioMovto,g_Cuenta,cCredito_promo,01,mMonto,'01',TRIM(pNumcredito::char(12)) || ' CRG. CTA. MONTOS DIFERIDOS','',pUsuario,0)
					RETURNING CodRet, codretRev , iSqlErr, g_Trans, dFecha, mSdoDisp, mMontoRet, cPasoCargo, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
					--COMMIT WORK;	
					IF (CodRet::integer <> 0  AND  CodRet::integer <> 1144) THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar la recuperacion del pago anticipado de credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
					END IF;							
				END IF
				LET CodRet = CodRet;
			END IF;
              --COMMIT WORK;
		END IF;

		--Seccion para Quitar Retenido Excedente
		SELECT status_cred INTO vlStatusCred
		FROM bdicred: "informix".sd_maecredcrd
		WHERE num_credito = pNumcredito;

		IF vlStatusCred = 'FF' THEN
			select  monto into  v_iva_cs
			FROM bdicred: "informix".sd_maeretenido
			WHERE empresa = '001'
			AND num_credito = cCredito_promo
			AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
			AND nvl(substr(referencia,18,3),'')= 'RET'
			AND estatus = 'R';

			--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN		
				select  monto into  v_iva_cs
				FROM bdicred: "informix".sd_maeretenido
				WHERE empresa = '001'
				AND num_credito = cCredito_promo
				AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
				AND nvl(substr(referencia,18,3),'')= 'RET'
				AND estatus = 'R';				
			END IF;	
			
			select  monto into  v_capital_cs
			FROM bdicred: "informix".sd_maeretenido
			WHERE empresa = '001'
			AND num_credito = cCredito_promo
			AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
			AND nvl(substr(referencia,18,3),'')= 'PAG'
			AND estatus = 'R';
				 
			IF NVL(v_iva_cs,0) = 0 THEN
				LET v_iva_cs = 0;
			END IF;
			IF NVL(v_capital_cs,0) = 0 THEN
				LET v_capital_cs = 0;
			END IF;
				
			IF v_iva_cs > 0 or v_capital_cs >=0 THEN

				UPDATE bdicred: "informix".sd_maesdos
				SET sdo_retenido = sdo_retenido - (v_iva_cs+v_capital_cs)
				WHERE empresa = '001'
				AND num_credito = cCredito_promo;

				UPDATE bdicred: "informix".sd_promocion_credito
				SET monto_int_iva = 0, monto_actual = 0, status = 6
				WHERE empresa = '001'
				AND num_sol_prestamo = pNumcredito;

				UPDATE bdicred: "informix".sd_maeretenido
				SET monto = 0
				WHERE empresa = '001'
				AND num_credito = cCredito_promo
				AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
				AND nvl(substr(referencia,18,3),'')= 'RET'
				AND estatus = 'R';
				
				--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN		
					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = 0
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
					AND nvl(substr(referencia,18,3),'')= 'RET'
					AND estatus = 'R';				
				END IF;	
			
				UPDATE bdicred: "informix".sd_maeretenido
				SET monto = 0
				WHERE empresa = '001'
				AND num_credito = cCredito_promo
				AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
				AND nvl(substr(referencia,18,3),'')= 'PAG'
				AND estatus = 'R';

			END IF;
		END IF;
		--END FOREACH;
		LET CodRet = "000000";
		LET Mensaje   = "Se realizo el proceso exitosamente";

    	RETURN CodRet,Mensaje;

	END;
END PROCEDURE
DOCUMENT
'Autor: 97468789 - Jesus Manuel Bustamante Lujano',
'Folio: 126',
'Descripcion: Se crea procedimiento para generar cargos a las credisoluciones',
'Fecha: 11/11/2016',
'BD: bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para que actualice el campo "monto" de la tabla "sd_maesdos" y se filtra por "referencia" ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 30/03/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc en el saldo retenido ',
'Modifico    : Cinthia Aguilar Xingu',
'Fecha       : Enero-2026',
'BD          : bdicred'
;

CREATE PROCEDURE "informix".sp_principal_suc_rr(pEmpresa                  CHAR(3),
												pNumCredito               CHAR(20),
												pProducto 				  CHAR(4),
												pMontoOperacionEfec       DECIMAL(18,2),
												pMontoOperacionCargCuenta DECIMAL(18,2),
												pUsuario 				  CHAR(8),
												pSucursal 				  CHAR(4),
												pFolio 					  CHAR(16),
												pTransaccion 			  CHAR(4))
RETURNING CHAR(5) AS Cod_Ret,
	CHAR(80)      AS mensaje_Retorno,
	CHAR(20) 	  AS Num_Credito,
	CHAR(20) 	  AS Cuenta_eje,
	CHAR(40) 	  AS Producto,
	CHAR(20) 	  AS Num_Cliente,
	CHAR(150) 	  AS Nom_Cliente,
	DECIMAL(18,2) AS Pago_Efectivo,
	DECIMAL(18,2) AS Pago_Cuenta,
	DECIMAL(18,2) AS Monto_Operacion,
	DECIMAL(18,2) AS Saldo_Actual,
	CHAR(60)      AS Status_Actual;

---DECLARACIONES
DEFINE iSqlErr                      INTEGER;
DEFINE iIsamErr                     INTEGER;
DEFINE cErrorInfo                   CHAR(80);
DEFINE cMensajeRet                  CHAR(80);
DEFINE cCodRet                      CHAR(6);
DEFINE cSucursal             	    CHAR(4);
DEFINE dMontoOperacion        		DECIMAL(18,2);
DEFINE cBanderarespaldo      	    CHAR(1);
DEFINE GLOBAL gRespaldoActivo 		CHAR(1) DEFAULT '1';
DEFINE cTransacc_rel          		CHAR(4);
DEFINE dMontoFinanciado      	    DECIMAL(18,2);
DEFINE dIvaSuc                		DECIMAL(5,3);
DEFINE dMontoInt              		DECIMAL(18,2);
DEFINE dPagoMensualidades     		DECIMAL(18,2);
DEFINE dMontoOperacionEfecAux   	DECIMAL(18,2);
DEFINE dMontoOperacionCargCuentaAux DECIMAL(18,2);
DEFINE GLOBAL g_Transacc    		CHAR(4)        DEFAULT '';
DEFINE GLOBAL g_TransaccSuc 		CHAR(4)        DEFAULT '';
DEFINE g_CodigoFun    				INTEGER;

---VARIABLES DEL PROCESO DE sp_principal_rr
DEFINE cCod_Ret		      CHAR(5);
DEFINE cMensaje_Ret       CHAR(125);
DEFINE dSdo_Ant		      DECIMAL(18,2);
DEFINE dComision	      DECIMAL(18,2);
DEFINE dIva_Com		      DECIMAL(18,2);
DEFINE dInt_Mora	      DECIMAL(18,2);
DEFINE dIva_Int_Mora      DECIMAL(18,2);
DEFINE dInt_Vdo		      DECIMAL(18,2);
DEFINE dIva_Int_Vdo       DECIMAL(18,2);
DEFINE dInt_Ordi          DECIMAL(18,2);
DEFINE dIva_Int_Ordi      DECIMAL(18,2);
DEFINE dCapital		      DECIMAL(18,2);
DEFINE dMonto_Pago        DECIMAL(18,2);
DEFINE cCuenta_Eje        CHAR(20);
DEFINE dSdo_Actual        DECIMAL(18,2);
DEFINE dPago_Min     	  DECIMAL(18,2);
DEFINE cFecha_Limite_Pago CHAR(17);

-- VARIABLES sp_principal_pp
DEFINE cCodigoRetorno_P    CHAR(5);
DEFINE cMensajeRetorno_P   CHAR(125);
DEFINE dSdo_Anterior_P     DECIMAL(18,2);
DEFINE dComision_P         DECIMAL(18,2);
DEFINE dIva_Com_P          DECIMAL(18,2);
DEFINE dInt_Mora_P         DECIMAL(18,2);
DEFINE dIva_Int_Mora_P     DECIMAL(18,2);
DEFINE dInt_Vdo_P          DECIMAL(18,2);
DEFINE dIva_Int_Vdo_P      DECIMAL(18,2);
DEFINE dInt_Ordi_P         DECIMAL(18,2);
DEFINE dIva_Int_Ordi_P     DECIMAL(18,2);
DEFINE dCapital_P          DECIMAL(18,2);
DEFINE dMonto_Pago_P       DECIMAL(18,2);
DEFINE cCuenta_Eje_P       CHAR(20);
DEFINE dSdoActual_P        DECIMAL(18,2);
DEFINE dPago_Min_P         DECIMAL(18,2);
DEFINE cFecha_LimitePago_P CHAR(17);

-- VARIABLES  sp_pago_anticipado_pp
DEFINE cCod_Retorno_Ap       CHAR(5);
DEFINE cMens_Ret          	 CHAR(125);
DEFINE dSdo_Anterior         DECIMAL(18,2);
DEFINE dComision_Ap          DECIMAL(18,2);
DEFINE dIva_Com_Ap           DECIMAL(18,2);
DEFINE dInt_Mora_Ap          DECIMAL(18,2);
DEFINE dIva_Int_Mora_Ap      DECIMAL(18,2);
DEFINE dInt_Vdo_Ap           DECIMAL(18,2);
DEFINE dIva_Int_Vdo_Ap       DECIMAL(18,2);
DEFINE dInt_Ordi_Ap          DECIMAL(18,2);
DEFINE dIva_Int_Ordi_Ap      DECIMAL(18,2);
DEFINE dCapital_Ap           DECIMAL(18,2);
DEFINE dMonto_Pago_Ap        DECIMAL(18,2);
DEFINE cCuenta_Eje_Ap        CHAR(20);
DEFINE dSdo_Act_Ap           DECIMAL(18,2);
DEFINE dPago_Min_Ap          DECIMAL(18,2);
DEFINE cFecha_Limite_Pago_Ap CHAR(17);

DEFINE cCodRetCD	  CHAR(6);
DEFINE cMensajeCD 	  CHAR(80);
DEFINE cNumCredCD 	  CHAR(20);
DEFINE cNumCteCD 	  CHAR(20);
DEFINE cNomProductoCD CHAR(40);
DEFINE cNumTarjetaCD  CHAR(20);
DEFINE cNomCteCD      CHAR(150);

--VARIABLES para sp_consulta_saldos_general
DEFINE cCodRetSP			 CHAR(6);
DEFINE cMensajeSP			 CHAR(80);
DEFINE cNumCredito      	 CHAR(20);
DEFINE cCodTipCred      	 CHAR(2);
DEFINE cDescStatusCred  	 CHAR(60);
DEFINE iIdUnidadProd     	 INTEGER;
DEFINE cCodCaract2       	 CHAR(3);
DEFINE dtFechaOrigen    	 DATE;
DEFINE dtFechaProxPago  	 DATE;
DEFINE dPagoMinimo      	 DECIMAL(18,2);
DEFINE dtFechaUltPago    	 DATE;
DEFINE iPlazo           	 INTEGER;
DEFINE iPagosRealizados 	 INTEGER;
DEFINE dLineaOtorgada    	 DECIMAL(18,2);
DEFINE dTasaInteres      	 DECIMAL(9,6);
DEFINE dTasaMoratorios  	 DECIMAL(9,6);
DEFINE dMontoSBC        	 DECIMAL(14,2);
DEFINE dCapVig           	 DECIMAL(18,2);
DEFINE dCapTrans         	 DECIMAL(18,2);
DEFINE dCapVdoExig       	 DECIMAL(18,2);
DEFINE dCapVdoNoExig    	 DECIMAL(18,2);
DEFINE dSdoActCap        	 DECIMAL(18,2);
DEFINE dIntVig           	 DECIMAL(18,2);
DEFINE dIntVdo           	 DECIMAL(18,2);
DEFINE dIntMoratorio     	 DECIMAL(18,2);
DEFINE dIntMes          	 DECIMAL(18,2);
DEFINE dSdoActInt        	 DECIMAL(18,2);
DEFINE dIvaIntVig        	 DECIMAL(18,2);
DEFINE dIvaIntVdo        	 DECIMAL(18,2);
DEFINE dIvaIntMoratorio  	 DECIMAL(18,2);
DEFINE dIvaIntMes        	 DECIMAL(18,2);
DEFINE dSdoActIvaInt     	 DECIMAL(18,2);
DEFINE dComPend          	 DECIMAL(18,2);
DEFINE dIvaCom            	 DECIMAL(18,2);
DEFINE dSdoRetenido     	 DECIMAL(18,2);
DEFINE dSdoTotalLiq     	 DECIMAL(18,2);
DEFINE dIntDevengado         DECIMAL(18,2);
DEFINE dIvaIntDevengado      DECIMAL(18,2);
DEFINE dLineaDisponible      DECIMAL(18,2);
DEFINE dPagosVdos            DECIMAL(18,2);
DEFINE cDescBloqueoCta       CHAR(60);
DEFINE cDescCausaBloqueoCta  CHAR(50);
DEFINE cSitCte               CHAR(1);
DEFINE iCausaCte             INTEGER;
DEFINE cDescSitEspCte        CHAR(75);
DEFINE cSitCred              CHAR(1);
DEFINE iCausaCred            INTEGER;
DEFINE cDescSitEspCred       CHAR(75);
DEFINE iAplicoPago           INTEGER;

-- DSB  - TH - EM -2017-03-16
DEFINE dMontoAux 			 DECIMAL(18,2);
DEFINE dtFechaActual	  	 DATE;
DEFINE dFechaAmortiza    	 DATE;
DEFINE mMensualidad          DECIMAL(18,2);
DEFINE iFlaPagoAnticipado    INTEGER;
DEFINE cCodigoFunth      	 CHAR(3);
DEFINE g_TransaccAnt		 CHAR(4);
DEFINE cCodRetAux		CHAR(6);
DEFINE dNumCredito      CHAR(20);
DEFINE mMontoEfec     MONEY(14,2);
DEFINE mMontoCargo    MONEY(14,2);
DEFINE mMonto		  MONEY(14,2);
DEFINE v_iva_cs       DECIMAL(14,2);
DEFINE cfolio_mov     CHAR(16);
DEFINE c_Folio_Suc		  CHAR(16);
--AAME Quita Validacion If exits select por variables 21052018
DEFINE cnumcredisol   CHAR(20);
DEFINE ccapital_status CHAR(1);
DEFINE vNumCte         CHAR(20); --RQM 10 915-4
DEFINE vNumCel         CHAR(13); --RQM 10 915-4
DEFINE vFecha          CHAR(10); --RQM 10 915-4
DEFINE vstcred         CHAR(2); --RQM 10 915-4
DEFINE vMontoPago      DECIMAL(18,2); --RQM 10 915-4
DEFINE banderaApoyo		SMALLINT;
---- CONDONACIONES Y QUITAS 
DEFINE indicaQuitaCondona	CHAR (1);
DEFINE montoQuita			DECIMAL(18,2);
DEFINE montoCondona			DECIMAL(18,2);
DEFINE bandera_quita_restante	SMALLINT;
DEFINE monto_condona			DECIMAL(18,2);
DEFINE monto_qc				DECIMAL(18,2);
DEFINE totalquitacapvenc    DECIMAL(18,2);
DEFINE status_cred_quita	CHAR(2);
DEFINE p_Divisa             CHAR(2);
DEFINE dFechaCuota			DATE;
DEFINE monto_balanza		DECIMAL(18,2);
DEFINE monto_orden			DECIMAL(18,2);
DEFINE condona_accesorios 	DECIMAL(18,2);
DEFINE GLOBAL gprocesa 		INT        DEFAULT 0;
DEFINE vFechaVencCred		DATE;
DEFINE cTranPFSI_aux		CHAR(4);
DEFINE cEnvioSMSRespMultic	CHAR(1);
DEFINE cbanfamilia			 CHAR(3); -- RQM 10 1177
DEFINE ATR_Cred    INTEGER;
DEFINE iPagosVencidos    INTEGER;

DEFINE vMesesVencidos		SMALLINT;
DEFINE vMesesHistoria		INTEGER;
DEFINE dMontoOtorgado   	DECIMAL(18,2);
DEFINE vIntVencido          MONEY(18,2);
DEFINE vIvaIntVigente		DECIMAL(14,2);
DEFINE vIvaIntVencido		DECIMAL(14,2); --RQM 09 459
DEFINE vCapitalMtoCuota		DECIMAL(14,2);
DEFINE vSdoCredito			DECIMAL(18,2);
DEFINE vIntMoratorio        MONEY(18,2); --RQM 09 459
DEFINE dSdoCapInsoluto      DECIMAL(14,2); 

DEFINE dFechapago   		DATE;  
DEFINE dFechaUltMov 		DATE; 
DEFINE dFechanegociacion    DATE;
DEFINE dPagorealizado       DECIMAL(14,2);
DEFINE dPagoParcial         DECIMAL(14,2);

DEFINE wBegin           CHAR(1);

--INICIALIZACIONES
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = '';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET cCodRet         = '00000';
LET cSucursal       = '';
LET dMontoOperacion = 0;
LET g_Transacc      = pTransaccion;
LET cTransacc_rel   = '';

LET dMontoFinanciado     		 = 0;
LET dIvaSuc              		 = 0;
LET dMontoInt            		 = 0;
LET dPagoMensualidades           = 0;
LET dMontoOperacionEfecAux       = pMontoOperacionEfec;
LET dMontoOperacionCargCuentaAux = pMontoOperacionCargCuenta;
LET g_CodigoFun					 = 0;

--VARIABLES DEL PROCESO DE sp_principal_rr
LET cCod_Ret		   = '';
LET cMensaje_Ret       = '';
LET dSdo_Ant		   = 0.0;
LET dComision		   = 0.0;
LET dIva_Com		   = 0.0;
LET dInt_Mora		   = 0.0;
LET dIva_Int_Mora      = 0.0;
LET dInt_Vdo		   = 0.0;
LET dIva_Int_Vdo       = 0.0;
LET dInt_Ordi          = 0.0;
LET dIva_Int_Ordi      = 0.0;
LET dCapital		   = 0.0;
LET dMonto_Pago        = 0.0;
LET cCuenta_Eje        = '';
LET dSdo_Actual        = 0.0;
LET dPago_Min          = 0.0;
LET cFecha_Limite_Pago = '';

--VARIABLES sp_principal_pp
LET cCodigoRetorno_P    = '00000';
LET cMensajeRetorno_P   = '';
LET dSdo_Anterior_P     = 0;
LET dComision_P         = 0;
LET dIva_Com_P          = 0;
LET dInt_Mora_P         = 0;
LET dIva_Int_Mora_P     = 0;
LET dInt_Vdo_P          = 0;
LET dIva_Int_Vdo_P      = 0;
LET dInt_Ordi_P         = 0;
LET dIva_Int_Ordi_P     = 0;
LET dCapital_P          = 0;
LET dMonto_Pago_P       = 0;
LET cCuenta_Eje_P       = 0;
LET dSdoActual_P        = 0;
LET dPago_Min_P         = 0;
LET cFecha_LimitePago_P = '';

-- VARIABLES sp_pago_anticipado_ppsr y sp_pago_anticipado_pp
LET cCod_Retorno_Ap          = '00000';
LET cMens_Ret             = '';
LET dSdo_Anterior         = 0;
LET dComision_Ap          = 0;
LET dIva_Com_Ap           = 0;
LET dInt_Mora_Ap          = 0;
LET dIva_Int_Mora_Ap      = 0;
LET dInt_Vdo_Ap           = 0;
LET dIva_Int_Vdo_Ap       = 0;
LET dInt_Ordi_Ap          = 0;
LET dIva_Int_Ordi_Ap      = 0;
LET dCapital_Ap           = 0;
LET dMonto_Pago_Ap        = 0;
LET cCuenta_Eje_Ap        = '';
LET dSdo_Act_Ap           = 0;
LET dPago_Min_Ap          = 0;
LET cFecha_Limite_Pago_Ap = '';

LET cCodRetCD			= '';
LET cMensajeCD 			= '';
LET cNumCredCD 			= '';
LET cNumCteCD 			= '';
LET cNomProductoCD		= '';
LET cNumTarjetaCD    	= '';
LET cNomCteCD     		= '';
LET gRespaldoActivo    	= '0';
LET cBanderarespaldo	= '1';

--INICIALIZACIONES PARA sp_consulta_saldos_general
LET cCodRetSP             = '';
LET cMensajeSP			  = '';
LET cNumCredito      	  = '';
LET cCodTipCred      	  = '';
LET cDescStatusCred  	  = '';
LET iIdUnidadProd     	  = 0;
LET cCodCaract2       	  = '';
LET dtFechaOrigen    	  = DATE(1);
LET dtFechaProxPago  	  = DATE(1);
LET dPagoMinimo      	  = 0;
LET dtFechaUltPago    	  = DATE(1);
LET iPlazo           	  = 0;
LET iPagosRealizados 	  = 0;
LET dLineaOtorgada    	  = 0;
LET dTasaInteres      	  = 0;
LET dTasaMoratorios  	  = 0;
LET dMontoSBC        	  = 0;
LET dCapVig           	  = 0;
LET dCapTrans         	  = 0;
LET dCapVdoExig       	  = 0;
LET dCapVdoNoExig    	  = 0;
LET dSdoActCap        	  = 0;
LET dIntVig           	  = 0;
LET dIntVdo           	  = 0;
LET dIntMoratorio     	  = 0;
LET dIntMes          	  = 0;
LET dSdoActInt        	  = 0;
LET dIvaIntVig        	  = 0;
LET dIvaIntVdo        	  = 0;
LET dIvaIntMoratorio  	  = 0;
LET dIvaIntMes        	  = 0;
LET dSdoActIvaInt     	  = 0;
LET dComPend          	  = 0;
LET dIvaCom            	  = 0;
LET dSdoRetenido     	  = 0;
LET dSdoTotalLiq     	  = 0;
LET dIntDevengado         = 0;
LET dIvaIntDevengado      = 0;
LET dLineaDisponible      = 0;
LET dPagosVdos            = 0;
LET cDescBloqueoCta       = '';
LET cDescCausaBloqueoCta  = '';
LET cSitCte               = '';
LET iCausaCte             = 0;
LET cDescSitEspCte        = '';
LET cSitCred              = '';
LET iCausaCred            = 0;
LET cDescSitEspCred       = '';
LET iAplicoPago           = 0;

-- DSB - TH - EM - 2017-03-16
LET dMontoAux 			= pMontoOperacionEfec + pMontoOperacionCargCuenta;
LET dtFechaActual  	 	= DATE(1);
LET dFechaAmortiza    	= DATE(1);
LET mMensualidad        = 0;
LET iFlaPagoAnticipado  = 0;
LET g_TransaccAnt       = '';
LET cCodRetAux			= '';
LET mMontoEfec          = 0;
LET mMontoCargo         = 0;
LET mMonto		        = 0;
LET v_iva_cs            = 0;
LET cfolio_mov          = "";
LET c_Folio_Suc     ='';
--AAME Quita Validacion If exits select por variables 21052018
LET cnumcredisol        = '';
LET ccapital_status 	= '';
LET vNumCte             = ''; --RQM 10 915-4
LET vNumCel             = ''; --RQM 10 915-4
LET vFecha              = ''; --RQM 10 915-4
LET vstcred             = ''; --RQM 10 915-4
LET vMontoPago          = 0; --RQM 10 915-4

LET banderaApoyo		= 0;
---- CONDONACIONES Y QUITAS 
LET indicaQuitaCondona	= '';
LET montoQuita			= 0;
LET montoCondona		= 0;
LET bandera_quita_restante = 0;
LET monto_condona			= 0;
LET monto_qc			= 0;
LET totalquitacapvenc   = 0;
LET status_cred_quita	= 0;
LET p_Divisa			= '';
LET dFechaCuota			= DATE(1);
LET monto_balanza		= 0;
LET monto_orden			= 0;
LET condona_accesorios	= 0;
LET vFechaVencCred		= DATE (1);
-- LET gprocesa				= 0;	--- variable global que valida si procesa capital para quitas
LET cTranPFSI_aux		= '';
LET cEnvioSMSRespMultic	= '';
LET cbanfamilia				= ''; -- RQM 10 1177
LET ATR_Cred  =0;
LET iPagosVencidos = 0;
--RQM 09 459
LET vMesesVencidos		= 0;
LET vMesesHistoria		= 0;
LET dMontoOtorgado  	= 0;
LET vIntVencido 		= 0;
LET vIvaIntVigente		= 0;
LET vIvaIntVencido		= 0;
LET vCapitalMtoCuota	= 0;
LET vSdoCredito			= 0;
LET vIntMoratorio 		= 0; --RQM 09 459
LET dSdoCapInsoluto     = 0;

LET dFechapago          = DATE (1);
LET dFechaUltMov        = DATE (1);
LET dFechanegociacion   = DATE (1);
LET dPagorealizado      = 0;
LET dPagoParcial        = 0;
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
		  LET cMensajeRet  = cErrorInfo;
          RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
       END IF;
    END EXCEPTION;
  
    SELECT fecha_hoy
	INTO dtFechaActual
	FROM  bdicred:"informix".sd_fechas
	where empresa= '001';
		
	SELECT status_cred,divisa,fecha_vencim
	INTO status_cred_quita,p_Divisa,vFechaVencCred
	FROM bdicred:sd_maecredcrd
	WHERE num_credito = pNumCredito;	
	---- realiza consulta para validar si es quita, condonacion o quita por operaciones
	SELECT indicador_proceso,mto_quita,monto_condonado,fecha_negociacion --,NVL(saldo_tot_liquidar,0)
		INTO indicaQuitaCondona,montoQuita,montoCondona,dFechanegociacion --, totalquitacapvenc
	FROM bdicred:sd_bitacora_quitacondonacion
	WHERE num_credito = pNumCredito
	AND estatus_proceso = 'PR';	
	--AND fecha_negociacion >= dtFechaActual;

	IF indicaQuitaCondona IS NULL OR indicaQuitaCondona = '' THEN
		LET indicaQuitaCondona = '';
	END IF;
	
	IF montoQuita IS NULL OR montoQuita = '' THEN
		LET montoQuita = 0;
	END IF;
	
	IF montoCondona IS NULL OR montoCondona = '' THEN
		LET montoCondona = 0;
	END IF;
	IF dFechanegociacion IS NULL OR dFechanegociacion ='' THEN
		LET dFechanegociacion   = DATE (1);
	END IF;
	
    LET monto_qc = montoQuita + montoCondona;
	-- VALIDA LOS PARAMETROS DE ENTRADA
	--- se agrega validacion para que no mande error cuando es quita operativa, pueda mandar pago cero	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCredito,'') = '' OR NVL(pUsuario,'') = ''
	OR NVL(pSucursal,'') = ''   OR NVL(pFolio,'') = ''  OR NVL(g_Transacc,'') = ''
	OR (NVL(pMontoOperacionEfec,0) = 0 AND NVL(pMontoOperacionCargCuenta,0) = 0 AND indicaQuitaCondona NOT IN ('O','U')) THEN
		LET cCodRet = '00361';
		LET cMensajeRet  = 'PARAMETROS INVALIDOS';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pTransaccion = '8654' THEN	-- Banderas para cargo sdo a favor en tdc para PG Sdo Inmediato
		LET cTranPFSI_aux = 'PFSI';
	END IF;

	LET g_TransaccSuc = LPAD(pTransaccion,4,'0');
    
	SELECT NVL(transacc,''),cod_fun --,NVL(transacc_rel,"")
	INTO g_Transacc,g_CodigoFun --, cTransacc_rel
	FROM bdicred:"informix".sd_conceptospagomanualcrd
	WHERE transacc_suc = g_TransaccSuc
	AND num_producto = pProducto;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	   LET cCodRet     = '00189';
	   LET cMensajeRet = 'Transaccion incorrecta';
	   RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;
	
	-- --AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1 SE OBTIENE LA FAMILIA DEL PRODUCTO
	SELECT familia
	INTO cbanfamilia
	FROM  "informix".sd_definicion 
	WHERE empresa = pEmpresa AND num_producto = pProducto;
	
	LET vMontoPago = pMontoOperacionEfec+pMontoOperacionCargCuenta; --RQM 10 915-4

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	   LET cCodRet     = '00189';
	   LET cMensajeRet = 'Transaccion incorrecta';
	   RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;


	SELECT mensualidad INTO mMensualidad
	FROM bdicred:"informix".sd_promocion_credito
	WHERE num_sol_prestamo = pNumCredito
	AND empresa = pEmpresa;


	LET g_Transacc = g_Transacc;
	LET vMontoPago = vMontoPago;
	LET indicaQuitaCondona = indicaQuitaCondona;
	LET status_cred_quita = status_cred_quita;
	
	IF pProducto = '6800' THEN		-- Identifica el envio de sms o no
		IF g_Transacc = '7590' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 2; -- atm
			LET cEnvioSMSRespMultic = '0';
			 
		ELIF g_Transacc = '8738' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 3; -- whats
			LET cEnvioSMSRespMultic = '0';

		ELIF g_Transacc = '8317'	THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 1; -- sms
			LET cEnvioSMSRespMultic = '0';
		ELIF g_Transacc	= '5025' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 4; -- app
			LET cEnvioSMSRespMultic = '0';
		ELIF g_Transacc	= '7506' THEN
			LET cEnvioSMSRespMultic = '0';		
		ELSE	   
			LET cEnvioSMSRespMultic = '1';
		END IF;
	END IF;

	SELECT NVL(atr,0),mto_fin_ven_trasp
	INTO ATR_Cred ,iPagosVencidos
	FROM bdicred:"informix".sd_maesdoscrd 
	WHERE num_credito = pNumCredito
	AND empresa       = pEmpresa;
			

	--- Validacion para Quita, Condonacion, O = Quita de Operaciones sin cancelcion de linea de PD, U = Quita Operacion con cancelacion si es PD
	IF g_Transacc NOT IN ('8671','8701') AND vMontoPago >= monto_qc  AND dFechanegociacion >= dtFechaActual
	--AND  ((indicaQuitaCondona = 'Q' AND status_cred_quita in ('BT')) OR (indicaQuitaCondona = 'C' AND status_cred_quita in ('BT','BA')))
	AND  ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
	OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3') and ATR_Cred>0))  )
	OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
	OR ( pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5) )) -- se agrega validacion por IFRS AEH
	OR (g_Transacc NOT IN ('8671','8701') AND (indicaQuitaCondona IN ('O','U') )) THEN 
	--	IF pProducto IN ('6300','7600','7700','6800','6011') THEN --PRESTAMO 12 18 y 24, PRESTAMO DIGITAL
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
		INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
			dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,
			dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,
			iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
		IF cCodRetSP <> '000000' THEN
			LET cCodRet = cCodRetSP;
			LET cMensajeRet= cMensajeSP;
		END IF;

		UPDATE "informix".sd_bitacora_quitacondonacion 
		SET pago_realizado = vMontoPago,int_vencido = dIntVdo,iva_int_vencido = dIvaIntVdo, cap_vigente = dCapVig, iva_int_vigente = dIvaIntVig,
		cap_vigente_cq = NVL(dCapVig,0), iva_int_vigente_cq =  dIvaIntVig,
		int_moratorio = dIntMoratorio, iva_int_mora = dIvaIntMoratorio,int_vigente_cq =  dIntVig,
		int_vencido_cq = dIntVdo,iva_int_vencido_cq = dIvaIntVdo,
		int_moratorio_cq = dIntMoratorio, iva_int_mora_cq = dIvaIntMoratorio,
		cap_vencido = dCapVdoExig, int_vigente = dIntVig, cap_vencido_cq = dCapVdoExig,
         -----------------------------------------------------------------------	 		
		meses_vencidos = dPagosVdos, copete_moratorio = NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0), 
		saldo_tot_liquidar = dSdoTotalLiq WHERE num_credito = pNumCredito and estatus_proceso='PR';
		-----------------------------------------------------------------------	
		COMMIT;
		BEGIN;	
		IF pProducto NOT IN ('6011','8600') THEN

			---- total balanza
			SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado) 
			into monto_orden
			---into monto_balanza
			FROM  bdicred:sd_amortiza_creditocrd
			WHERE campo_trabajo3 = 'V'		---- V es Orden
			and capital_status = '2'
			AND num_credito = pNumCredito;
				
			---- total orden
			SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado) 
			into monto_balanza
			--- into monto_orden
			FROM  bdicred:sd_amortiza_creditocrd
			WHERE campo_trabajo3 <> 'V'		--- diferente de V es balanza
			and capital_status = '2'
			AND num_credito = pNumCredito;

			IF monto_balanza IS NULL THEN LET monto_balanza = 0; END IF;
			IF monto_orden IS NULL THEN LET monto_orden = 0; END IF;
							
			--			LET condona_accesorios = dIntMoratorio + dIvaIntMoratorio + monto_balanza;
			LET condona_accesorios = dIntMoratorio + dIvaIntMoratorio + monto_orden;
		
			IF vMontoPago < dSdoTotalLiq THEN
					--- si el monto efectivo es mayor a capital e interes de orden, solo se condonana moratorios y lo que alcance de vencidos.
				IF vMontoPago > dSdoActCap + monto_balanza THEN

					LET condona_accesorios = dSdoTotalLiq - vMontoPago;	 -- 	- (vMontoPago - (dSdoActCap + monto_balanza));
					IF condona_accesorios > 0 THEN	---- aplica pago de accesorios que logre pagar
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8671')
						INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

					END IF;
				ELSE	
					--- Cuando no cubre capitales e int balanza, entonces no alcanza.. se condona al 100%				
					IF condona_accesorios > 0 THEN
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8671')
						INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

					END IF;	
				END IF;
			END IF;
		ELSE

			LET condona_accesorios = dSdoTotalLiq - dSdoActCap;
			----- QUITA DE REESTRUCTURAS  
			IF vMontoPago < dSdoTotalLiq THEN
					--- si el monto efectivo es mayor a capital e interes de orden, solo se condonana moratorios y lo que alcance de vencidos.
				IF vMontoPago > dSdoActCap THEN
				
					LET condona_accesorios = dSdoTotalLiq - vMontoPago;
					
					IF condona_accesorios > 0 THEN	---- aplica pago de accesorios y capital que logre pagar
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
						(pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8701')
						INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					END IF;
				ELSE	
					--- Cuando no cubre capitales e int balanza, entonces no alcanza.. se condona al 100%	
					IF condona_accesorios > 0 THEN
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
						(pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8701')
						INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					END IF;	
				END IF;
			END IF;

		END IF;
			LET g_TransaccSuc = LPAD(pTransaccion,4,'0');
			SELECT NVL(transacc,''),cod_fun --,NVL(transacc_rel,"")
			INTO g_Transacc,g_CodigoFun --, cTransacc_rel
			FROM bdicred:"informix".sd_conceptospagomanualcrd
			WHERE transacc_suc = g_TransaccSuc
			AND num_producto = pProducto;
			--- Apaga respaldo
			IF condona_accesorios > 0  THEN
				LET gRespaldoActivo = '1';
				LET gprocesa = 2;
			END IF;
	     --Si el pago es menor al monto quita/condonado y la fecha de pago sea menor o igual a la fecha negociacion se actualiza el pago en la bitacora
	ELIF g_Transacc NOT IN ('8671','8701') AND vMontoPago < monto_qc  AND dFechanegociacion >= dtFechaActual
	AND  ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
	OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3')))  ) 
	OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
	OR (pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5) ))    THEN
		 
        UPDATE "informix".sd_bitacora_quitacondonacion 
		SET pago_realizado = vMontoPago
        WHERE num_credito = pNumCredito and estatus_proceso='PR';
COMMIT;	
	BEGIN; 
	LET indicaQuitaCondona = '';
		
	ELIF dFechanegociacion < dtFechaActual AND g_Transacc NOT IN ('8671','8701') AND ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
	OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3')))  ) 		
	OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
	OR (pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5))) THEN
		
			UPDATE "informix".sd_bitacora_quitacondonacion 
			SET estatus_proceso = 'CN',fecha_status = dtFechaActual
            WHERE num_credito = pNumCredito and estatus_proceso='PR';
	COMMIT;	
	
	BEGIN; 
		LET indicaQuitaCondona = '';
		   
	ELSE
		-- Si no pasa por el flujo y variable global esta activa no realiza respaldo, prepara el anticipo de quita
		LET indicaQuitaCondona = '';
		IF gprocesa = 2 THEN
			LET gRespaldoActivo = '1';
		END IF;
	END IF;

	--AAME Quita Validacion If exits select por variables 21052018
	SELECT limit 1 NVL(a.capital_status,'')
	INTO ccapital_status
	FROM bdicred:"informix".sd_amortiza_creditocrd a
	WHERE a.empresa = pEmpresa
	AND a.num_credito = pNumCredito
	AND a.capital_status IN ('1','2','7','6');
		
	IF NVL(ccapital_status,'') = '' THEN
		SELECT limit 1 NVL(a.capital_status,'')
		INTO ccapital_status
		FROM bdicred:"informix".sd_amortiza_creditocrd a
		WHERE a.empresa     = pEmpresa
		AND a.num_credito = pNumCredito
		AND a.capital_status IN ('3');
	END IF;

	 --se valida si se va realizar un pago normal.
	IF ccapital_status IN ('1','2','7','6') THEN --AAME Quita Validacion If exits select por variables 21052018

		--se obtiene la informacion del  cliente
		SELECT  a.sucursal, b.monto_financiado, round((today - a.fecha_apertura)/30.4)
		INTO  cSucursal, dMontoFinanciado, vMesesHistoria
		FROM bdicred:"informix".sd_maecredcrd a,
		bdicred:"informix".sd_maesdoscrd b,
		bdicred:"informix".sd_maecredanexocrd c
		WHERE a.num_credito = pNumCredito
		AND a.empresa       = pEmpresa
		AND b.empresa       = a.empresa
		AND b.num_credito   = a.num_credito
		AND c.num_credito   = b.num_credito
		AND c.empresa       = b.empresa;

		SELECT iva
		INTO dIvaSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa
		AND sucursal  = cSucursal;

		-- 2011-11-30 Se cambia metodo de calculo de moratorio
		SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag) +	(SUM(round((mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)*dIvaSuc,2)))
		INTO dMontoInt
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa = pEmpresa
		AND num_credito = pNumCredito
		AND capital_status IN ('2','7','1','6');

		LET dMontoFinanciado = dMontoFinanciado + dMontoInt;
		---- se agrega transacciones de quitas solo para pago en efectivo
		IF g_Transacc IN ('7970','8205','8160','8286', '7990','8335','8671','8701','8654','4320')  THEN--pago en efectivo --DSB 20/11/2015 se Agrega la Transaccion 8160 --- 8335 SPEI

			IF pMontoOperacionEfec <= dMontoFinanciado THEN
				LET dPagoMensualidades = pMontoOperacionEfec;
				LET dMontoFinanciado = dMontoFinanciado - pMontoOperacionEfec;
				LET pMontoOperacionEfec = 0;
			ELSE
				LET dPagoMensualidades = dMontoFinanciado;
				LET pMontoOperacionEfec = pMontoOperacionEfec - dPagoMensualidades;
				LET dMontoFinanciado =0;
			END IF;

			IF pProducto IN ('6011','8600') THEN --REESTRUCTURAS
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')
					INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual = dSdo_Actual;
				LET cCuenta_Eje = cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--- Se agrega variable para indicar si el pago es mayor a cero de lo contrario mandara error el sp principal pp
			--ELIF pProducto IN ('6300','6400','7600','7700','6800','6900') AND dPagoMensualidades > 0 THEN --PRESTAMO,NOMINA,FLEXIBLE,MONTOS_DIFERIDOS
																								  
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') AND dPagoMensualidades > 0 THEN --PRESTAMO,NOMINA,FLEXIBLE,MONTOS_DIFERIDOS			
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

				IF cCodigoRetorno_P::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')
					INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCodigoRetorno_P;
					LET cMensajeRet  = cMensajeRetorno_P;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;

				LET dSdo_Actual = dSdoActual_P;
				LET cCuenta_Eje = cCuenta_Eje_P;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			END IF;			
			--IF pProducto IN ('6900') THEN
			--	LET pMontoOperacionEfec = dPagoMensualidades;
			--END IF;
			
			IF pMontoOperacionEfec > 0 THEN
				IF pProducto IN ('6011','8600') THEN
					-- REALIZA EL PAGO ANTICIPADO
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
					INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
					dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					IF cCod_Ret::INTEGER <> 0 THEN
					   EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')   INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Ret;
						LET cMensajeRet  = cMensaje_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET dSdo_Actual = dSdo_Actual;
					LET cCuenta_Eje = cCuenta_Eje;
				--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN	
				--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
																		
																								   
				ELIF (cbanfamilia IN ('002','003') OR pProducto='6900')  THEN
				-- REALIZA EL PAGO ANTICIPADO

					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
					INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

					IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					   EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Retorno_Ap;
						LET cMensajeRet  = cMens_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;

					LET dSdo_Actual=dSdo_Act_Ap;
					LET cCuenta_Eje= cCuenta_Eje_Ap;

				END IF;
			END IF;
		END IF;
					
		--IF g_Transacc in ('7998') OR cTransacc_rel = '7998' OR g_Transacc = '8150' THEN -- pago  con cargo a cuenta --DSB 20/11/2015 se agrega transaccion 8150
		IF g_Transacc in ('7998','8317','7590','8738','5025','9888') OR cTransacc_rel IN ('7998','8317','7590','8738','5025') OR g_Transacc = '8150' THEN -- pago  con cargo a cuenta --DSB 20/11/2015 se agrega transaccion 8150
			IF cTransacc_rel <> '' THEN
				LET g_Transacc = cTransacc_rel;
			END IF;

			IF dMontoFinanciado > 0 THEN
				IF pMontoOperacionCargCuenta <= dMontoFinanciado THEN
				  LET dPagoMensualidades = pMontoOperacionCargCuenta;
				  LET dMontoFinanciado = dMontoFinanciado - pMontoOperacionCargCuenta;
				  LET pMontoOperacionCargCuenta = 0;
				ELSE
				  LET dPagoMensualidades = dMontoFinanciado;
				  LET pMontoOperacionCargCuenta = pMontoOperacionCargCuenta - dPagoMensualidades;
				  LET dMontoFinanciado =0;
				END IF;
			END IF;

			--pago con cargo a cuenta     
			IF pProducto IN ('6011','8600') AND dPagoMensualidades > 0 THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual=dSdo_Actual;
				LET cCuenta_Eje= cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6800','6900') AND dPagoMensualidades > 0 THEN
			--AAME RQM 10 1177 Se valida la familia de productos Prestamos y Linea Credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') AND dPagoMensualidades > 0 THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

				IF cCodigoRetorno_P::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCodigoRetorno_P;
					LET cMensajeRet  = cMensajeRetorno_P;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;

				LET dSdo_Actual=dSdoActual_P;
				LET cCuenta_Eje= cCuenta_Eje_P;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			
			END IF;
			--IF pProducto IN ('6900') THEN
			--	LET pMontoOperacionCargCuenta = dPagoMensualidades;
			--END IF;
			
			IF pMontoOperacionCargCuenta > 0  THEN
				IF pProducto IN  ('6011','8600') THEN
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
					INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
					dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;
						 
					IF cCod_Ret::INTEGER <> 0 THEN
						EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Ret;
						LET cMensajeRet  = cMensaje_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET dSdo_Actual=dSdo_Actual;
					LET cCuenta_Eje= cCuenta_Eje;
				--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
				--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
				--AAME RQM 10 1177 Se valida la familia de productos Prestamo y linea de credito a Plazo
				ELIF (cbanfamilia IN ('002','003') OR pProducto='6900')  THEN

					-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
					INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;
		 
					IF cCod_Retorno_Ap::INTEGER <> 0 THEN
						EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Retorno_Ap;
						LET cMensajeRet  = cMens_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
 					
					LET dSdo_Actual = dSdo_Act_Ap;
					LET cCuenta_Eje = cCuenta_Eje_Ap;
				END IF;
			END IF;
		END IF;

		--cuando entra por este flujo se realiza un pago anticipado
	ELIF ccapital_status IN ('3') THEN --AAME Quita Validacion If exits select por variables 21052018
	---- se agregan transacciones de quitas para pago anticipado solo en pago efectivo	
		IF g_Transacc IN ('7970','8205','8160','8286','7990','8335','8671','8701','8654','4320')  THEN --pago en efectivo --- 8335 SPEI

			IF pProducto IN  ('6011','8600') THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
				dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual = dSdo_Actual;
				LET cCuenta_Eje = cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
			--AAME RQM 10 1177 Se valida la familia de productos prestamos y linea credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') THEN
				-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
				INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

				IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Retorno_Ap;
					LET cMensajeRet  = cMens_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				
				LET dSdo_Actual=dSdo_Act_Ap;
				LET cCuenta_Eje= cCuenta_Eje_Ap;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
								
			END IF;
		END IF;

		--IF g_Transacc ='7998' OR cTransacc_rel = '7998' OR g_Transacc = '8150' THEN  -- pago  con cargo a cuenta  --EM-17/03/2017'
		IF g_Transacc IN ('7998','8317','7590','8738','5025','9888') OR cTransacc_rel IN ('7998','8317','7590','8738','5025') OR g_Transacc = '8150' THEN  -- pago  con cargo a cuenta  --EM-17/03/2017'

			IF cTransacc_rel <> '' THEN
				LET g_Transacc = cTransacc_rel;
			END IF;

			IF pProducto IN  ('6011','8600') THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
				dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual=dSdo_Actual;
				LET cCuenta_Eje= cCuenta_Eje;
				LET gRespaldoActivo = '1';
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
			--AAME RQM 10 1177 Se valida la familia de productos prestamo y linea credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') THEN

				-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp (pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
				INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

				IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Retorno_Ap;
					LET cMensajeRet  = cMens_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual=dSdo_Act_Ap;
				LET cCuenta_Eje= cCuenta_Eje_Ap;
				LET gRespaldoActivo = '1';
			END IF;
		END IF;
	ELSE
		-- Cuando el credito ya esta saldado... y no es posible aplicar el pago
		LET cCodRet = '00374';
		LET cMensajeRet= 'El credito ya esta saldado';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;
	
	IF pProducto = '6900' AND g_Transacc IN ("8150","8160","8654") THEN	
		IF g_Transacc ="8150" THEN
			LET mMontoCargo = dMontoAux;
		END IF;

		IF g_Transacc in ("8160","8654") THEN
			LET mMontoEfec = dMontoAux;
			--AAME Quita Validacion If exits select por variables 21052018
			Select limit 1 numcredisol 
			INTO cnumcredisol
			from  bdicred: "informix".sd_verif_cuentas_crd  
			where empresa = pempresa AND numcredisol = pNumCredito;
			
			IF cnumcredisol <> '' Then
				DELETE FROM bdicred: "informix".sd_verif_cuentas_crd WHERE empresa = pempresa AND numcredisol=pNumCredito;
			END IF
		END IF;

		IF cTranPFSI_aux = 'PFSI' THEN
			CALL "informix".sp_actualizasaldos_cred(pempresa,pNumCredito,'PFSI',mMontoEfec,mMontoCargo,pFolio,pSucursal, pUsuario) RETURNING cCodRetAux, cMensajeRet;
		ELSE
			CALL "informix".sp_actualizasaldos_cred(pempresa,pNumCredito,pProducto,mMontoEfec,mMontoCargo,pFolio,pSucursal, pUsuario) RETURNING cCodRetAux, cMensajeRet;
		END IF;

	   IF (cCodRetAux <> "000000") THEN
		   LET cCodRet      = "00053";
		   LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de Pago del credisolucion";

			/*IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;*/
			RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
		END IF;	
	END IF;
	-- OBTIENE LOS DATOS DEL PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(pEmpresa, '',pNumCredito,'','','','')
	INTO cCodRetCD,cMensajeCD,cNumCredCD,cNumCteCD,cNomProductoCD,cNumTarjetaCD,cNomCteCD;
	IF cCodRetCD::INTEGER <> 0 THEN
		LET cCodRet = cCodRetCD;
		LET cMensajeRet= cMensajeCD;
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;

	LET dMontoOperacion = dMontoOperacionEfecAux + dMontoOperacionCargCuentaAux;
	
	--Se ejecuta sp para poder obtener el status del credito
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
	INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
	IF cCodRetSP <> '000000' THEN
		LET cCodRet = cCodRetSP;
		LET cMensajeRet= cMensajeSP;
	END IF;
	
	IF dSdoActCap <= 0 THEN
		IF pProducto = '6900' AND g_Transacc IN("8150","8160","8654") THEN
			--Seccion para Quitar Retenido Excedente
			SELECT monto_actual,monto_int_iva,folio_movto,num_credito INTO mMonto,v_iva_cs,cfolio_mov,dNumCredito
			FROM "informix".sd_promocion_credito
			WHERE empresa = '001'
			AND num_sol_prestamo = pNumCredito;

			UPDATE bdicred: "informix".sd_maesdos
			SET sdo_retenido = sdo_retenido - (mMonto + v_iva_cs)
			WHERE empresa = '001'
			AND num_credito = dNumCredito;

			UPDATE bdicred: "informix".sd_promocion_credito
			SET monto_actual=0,monto_int_iva = 0, status = 6
			WHERE empresa = '001'
			AND num_sol_prestamo = pNumCredito;

			UPDATE bdicred: "informix".sd_maeretenido
			SET monto = 0
			WHERE empresa = '001'
			AND num_credito = dNumCredito
			AND nvl(substr(referencia,1,16),'') = cfolio_mov
			AND nvl(substr(referencia,18,3),'')= 'RET'
			AND estatus = 'R';
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN		
				UPDATE bdicred: "informix".sd_maeretenido
				SET monto = 0
				WHERE empresa = '001'
				AND num_credito = dNumCredito
				AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
				AND nvl(substr(referencia,18,3),'')= 'RET'
				AND estatus = 'R';
			END IF;	

			UPDATE bdicred: "informix".sd_maeretenido
			SET monto = 0
			WHERE empresa = '001'
			AND num_credito = dNumCredito
			AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
			AND nvl(substr(referencia,18,3),'')= 'PAG'
			AND estatus = 'R';	
		END IF;
	END IF;
	
	-- RQM 09 473: TRIAD INI
	EXECUTE PROCEDURE "informix".sp_graba_indicador_cnr(pEmpresa,pNumCredito,dMontoAux,g_Transacc,g_CodigoFun,1,dtFechaActual,pFolio,0,0,2)
	INTO cCodRet;
	
	--IF pProducto = '6800' and pTransaccion not in ('611','620') THEN  -- RQM 10 915-4 
	--AAME RQM 10 1177 Se valida la familia de Linea Credito a Plazo
	IF (cbanfamilia IN ('003') AND pProducto NOT IN('6400')) and pTransaccion not in ('611','620')  THEN	 -- RQM 10 915-4
		SELECT NVL(a.telefono,''), b.status_cred INTO vNumCel,vstcred								
		FROM bdinteg:si_telefonos a
		JOIN bdicred:sd_maecredcrd b on a.numcte = b.numcte
		WHERE a.tipo_tel = 2 AND a.verificado = 'V' AND a.status_tel = 'A' AND b.num_credito = pNumCredito; 
		
		SELECT COUNT (*)
			INTO banderaApoyo
		FROM bdicred:sd_diferir
		WHERE numcte = cNumCteCD
		AND canal_baja = 21;
		
		IF banderaApoyo = 0 THEN
			IF vNumCel <> '' OR vNumCel IS NOT NULL THEN
				LET vFecha = DAY(dtFechaActual) || '/' || MONTH(dtFechaActual) || '/' || YEAR(dtFechaActual);						
					IF vstcred = 'FF'  THEN
						----Envio de mensaje de Liquidacion del prestamo						 								 
						IF cEnvioSMSRespMultic = '1' THEN
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2','CRED_SMS','PPF_SMS_FF','000000000','', '','1', vFecha, '', '', '', '', '', '', '', '', '', '',TRIM(vNumCel), vMontoPago, 0, 0, 0, 0, current, current) INTO cCodRetSP;						
						END IF;
					ELSE
						IF cEnvioSMSRespMultic = '1' THEN  
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2','CRED_SMS','PPF_SMS_CAUT','000000000','', '','1', vFecha, '', '', '', '', '', '', '', '', '', '',TRIM(vNumCel), vMontoPago, 0, 0, 0, 0, current, current) INTO cCodRetSP;						
						END IF;
					END IF;
			END IF;
		END IF;
	END IF; 
	
	IF  (indicaQuitaCondona IN ('Q','C','O','U') AND  g_Transacc NOT IN ('8671','8701'))   THEN	
		
		SELECT 
		SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
        SUM((mora_provi_ordi + mora_provi_cope + mora_sdo_ordi) - (mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)),
        NVL(SUM(interes_debe - interes_pagado),0),
		SUM(NVL(iva_debe,0) - NVL(iva_pagado,0))
		INTO vIntVencido,
			vIntMoratorio,
			vIvaIntVigente, 
			vIvaIntVencido
		FROM "informix".sd_amortiza_creditocrd WHERE empresa = '001' AND num_credito = pNumCredito;
		
		SELECT capital_mto_cuota INTO vCapitalMtoCuota
		FROM sd_amortiza_creditocrd WHERE num_credito = pNumCredito
		AND fecha_cuota = dtFechaActual;
		
		IF  indicaQuitaCondona IN ('Q','O','U') AND dSdoTotalLiq > 0 THEN
			
			LET gprocesa = 2;
			
			IF pProducto NOT IN ('6011','8600') THEN
				---- se manda a llamar el principal_suc_rr por el total a liquidar, con la nueva transaccion de PP
				execute procedure bdicred:sp_principal_suc_rr (pEmpresa,pNumCredito,pProducto,dSdoTotalLiq,0,pUsuario,pSucursal,pFolio,'8671')
					INTO cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
					dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;
			ELSE 
				---- se manda a llamar el principal_suc_rr por el total a liquidar, con la nueva transaccion de Rees
				execute procedure bdicred:sp_principal_suc_rr (pEmpresa,pNumCredito,pProducto,dSdoTotalLiq,0,pUsuario,pSucursal,pFolio,'8701')
					INTO cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
					dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;			
			END IF;
		END IF;
		----- Se omite la O Quita de operaciones ya que no requieren se cancele
		IF  pProducto = '6800' AND indicaQuitaCondona IN ('Q','U') THEN
			--Se genera movimiento de cancelacion de linea solo para Prestamo Digital, cuando el capital se salda con el pago y se debe cancelar el credito
			CALL "informix".genmovcrd(pEmpresa,pNumCredito, '6800', 2, '002', dtFechaActual,dLineaOtorgada,pFolio,pSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) 
			RETURNING cCodigoRetorno_P, cMensajeRetorno_P;

			UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = dtFechaActual, cancel_pf = '1', fecha_ult_pf = vFechaVencCred WHERE num_credito = pNumCredito;
			
		END IF;
		
		--Se consulta el saldo capital insoluto y la fecha pago
		SELECT A.sdo_cap_insoluto,B.fecha_proceso,A.monto_otorgado,A.fecha_ult_mov
		INTO dSdoCapInsoluto, dFechapago, dMontoOtorgado,dFechaUltMov
		FROM bdicred:"informix".sd_maesdoscrd A
		INNER JOIN bdicred:"informix".sd_maecredanexocrd B ON B.num_credito = A.num_credito
		WHERE A.num_credito = pNumCredito
		AND A.empresa = pEmpresa;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
		INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
			dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,
			dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,
			iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
		IF cCodRetSP <> '000000' THEN
			LET cCodRet = cCodRetSP;
			LET cMensajeRet= cMensajeSP;
		END IF;
		
		LET vSdoCredito = dMontoOtorgado-dSdoCapInsoluto-dSdoRetenido;


		----------------------------------------------------------------------------
		UPDATE "informix".sd_bitacora_quitacondonacion 
			SET meses_historia = vMesesHistoria, sdo_credito = vSdoCredito, 
			fecha_pago = today, abono_mensual_al_quita = NVL(vCapitalMtoCuota,0),
			fecha_ult_mov = dFechaUltMov, fecha_liquidacion = today,
			fecha_status = today, estatus_proceso = 'FI',saldo_tot_liquidar = dSdoTotalLiq,
			copete_moratorio = NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0),
			int_moratorio = dIntMoratorio,
        ----------------------------------------------------------------------------
			cap_vigente_dq = NVL(dCapVig,0), 
			cap_vencido_dq = dCapVdoExig, 
			int_vigente_dq = dIntVig, 
			int_vencido_dq = dIntVdo,
			int_moratorio_dq = dIntMoratorio,		
			iva_int_vigente_dq = dIvaIntVig, 
			iva_int_vencido_dq = dIvaIntVdo,
			iva_int_mora_dq = dIvaIntMoratorio
			WHERE num_credito = pNumCredito and estatus_proceso='PR';
		----------------------------------------------------------------------------
		--COMMIT;
		LET gprocesa = 0;
	END IF;
	
	RETURN cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
	dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para realizar pagos normales y anticipados de prestamos a plazo, en efectivo, con cargo a cuenta o mixto',
'AUTOR: Mohamed Carreon, Jesus Aguilar ',
'FECHA: 22 de Junio 2011',
'BD: BDICRED',
'VERSION: 20110624.1808',
'DESCRIPCION: Se Modifica codigo de mensaje para cuando el credito ya este saldado.',
'AUTOR: Mohamed Carreon, Jesus Aguilar ',
'FECHA: 18 de Agosto 2011',
'BD: BDICRED',
'VERSION: 20110818.1808',
'DESCRIPCION: Se modifica metodo de calculo del IVA moratorio.',
'AUTOR: Diego Guerra Atienzo ',
'FECHA: 30 de Noviembre 2011',
'Folio: 1580',
'AUTOR : 95594213',
'FECHA : 29/01/2014',
'MODIFICACION: Se modifica sp_principal_suc_rr agregandole la ejecucion del sp_consulta_saldos_general para Retornar el status actual del credito ',
'SUSTENTO: RQM_09-338_Deposito_personal_cobranzav3.1.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdicred',
'DESCRIPCION: Se Agregan las Transacciones 8150 y 8160 Para los Producto 6900 ',
'FECHA: 28/11/2015',
'Modifico: 92597688 - Yadira Morales Zazueta',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para filtrar dtFechaProxPago >= dtFechaActual ademasagregan las transacciones 8160 y 81150. ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 17/03/2017',
'BD          : bdicred',
'-------------------------------------------------------------------------',
'Modifico: 95992243 - Trinidad Hernadez',
'Folio: 188',
'Modificacion: Se quitan movimientos a la sd_movdia',
'BD: bdicred',
'Fecha: 25/04/2017',
'-------------------------------------------------------------------------',
'Modifico: Cinthia Aguilar',
'Modificacion: se agrega la validacion para liberar saldo retenido para las credisoluciones',
'BD: bdicred',
'Fecha: Enero.2026';

CREATE PROCEDURE "informix".sp_genera_archivo_carteralinea_solo(pEmpresa char(3))

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

--Creado por: Abrham Lopez L. 05/08/2011. Proceso para la generacion del archivo de Cartera en Linea
-- Modificado por: MAHR Octubre 2011. Se agregan al proceso productos de colocacion ademas de la Tarjeta de Credito Prestamo Personal y Reestructura.
--      Servicios: 1.- Tarjeta de Credito, 2.- Prestamo Personal y Reestructura 3.- AMBOS.
-- Modificado por MAHR. Mayo 2012. Se crea sp sp_genera_carteraenlinea_tab, que genera los saldos de la cartera vencida y la almacena en la tabla:
--		sd_sdos_cartera_linea y desde dicha tabla se genera el archivo de Cartera en linea.


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cEmpresa             CHAR(3);
DEFINE cCod_ret				CHAR(6);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivoAuxRPp    CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoNvo		CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(6204);
DEFINE cSQL2                CHAR(6204);
DEFINE cSQL3                CHAR(100);
DEFINE pFecha               DATE;
DEFINE vnomProceso			CHAR(20);
DEFINE cMensajeRet          CHAR(125);
--DEFINE credcontproc 	    char(1);
--DEFINE intecontproc 	    char(1);
DEFINE cProceso             CHAR(4);
DEFINE cCod_retBit          CHAR(6);

--SET DEBUG FILE TO "/ifxsif01/PEDRO/carteralinea/sp_cartera_total_ppyr_finmes.out";
--TRACE ON;	


--Inicializacion de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cEmpresa                = "";
LET cCod_Ret                = "000000";
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivoAuxRPp       = "";
LET cnomarchivo1			= "";
LET cnomarchivoNvo			= "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cMensajeRet				= 'PROCESO EXITOSO';
LET vnomProceso             = "";
--LET credcontproc            = "";
--LET intecontproc            = "";
LET cProceso                = '0203';
LET cCod_retBit             = '00000';


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;            
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;       

        /*UPDATE bdicred:"informix".sd_contproc SET status_proc = "C",  hora_fin = CURRENT, cod_ret = cCod_ret, mensaje = "Cobranza en Linea Sin Generar"
            WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha   = pFecha; 
        UPDATE bdinteg:"informix".sx_contproc SET status_proc = "C", hora_fin = CURRENT, codret  = cCod_ret
            WHERE empresa = pEmpresa AND proceso   = vnomProceso  AND fecha   = pFecha; */
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '01') RETURNING cCod_retBit;       
	
    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


    LET pfecha = date(1);

    -- Obtener la fecha del dia de ayer
    SELECT fecha_ant INTO pFecha
        FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
		
	--LET pFecha= mdy('02','28','2022'); -- fecha de prueba 
		

    IF pFecha IS NULL THEN
        LET cCod_Ret=  '20013';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 2 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF

    -- *******************************************************
    --  INSERTA BITACORA PARA EJECUCION DE PROCESO           *
    -- *******************************************************
    /* Se elimina la bitacora ya que cuando por error se ejecuta la cartera en linea despues del cambio de fecha, al dia posterior no permite
       la ejecucion del proceso por que indica que ya fue ejecuta, cuando no se ha ejecutado ese dia. Se agrega la bitacora en cobranza para su registro.

    SELECT status_proc INTO intecontproc FROM bdinteg:"informix".sx_contproc WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pfecha;
    IF (intecontproc = 'F') THEN
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCod_Ret,cMensajeRet;
    END IF;
    SELECT status_proc INTO credcontproc FROM bdicred:"informix".sd_contproc WHERE empresa = pEmpresa  AND proceso = vnomProceso AND fecha = pFecha;
    IF (credcontproc = 'F') THEN
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCod_Ret,cMensajeRet;
    END IF;

    IF (intecontproc IS NULL) THEN
        INSERT INTO bdinteg:"informix".sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
            VALUES ('001',vnomProceso,pFecha,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;
    IF (credcontproc IS NULL) THEN
        INSERT INTO bdicred:"informix".sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
            VALUES ('001',vnomProceso,pFecha,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    END IF;
    UPDATE bdinteg:"informix".sx_contproc SET status_proc = 'I' WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    UPDATE bdicred:"informix".sd_contproc SET status_proc = 'I', mensaje = 'Iniciamos' WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    */

    -- *******************************************************
    --  FIN BITACORA                                         *
    -- *******************************************************

	-- Validacion de parametros de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3  AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
	END IF;

	--Validacion de la empresa
    SELECT empresa INTO cEmpresa
        FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
    IF NVL (cEmpresa, '') = '' OR cEmpresa IS NULL THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

	--Obtener ruta del archivo
    SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = 34;  
            
                --Valida que exista la carpeta
    IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3
                AND codigo_error = cCod_Ret;

        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

	--let cruta = '/ifxsif01/PEDRO/carteralinea/'; -- Ruta de pruebas

    --Obtener el nombre del archivo
	SELECT TRIM(valor_alfabetico) INTO cnombre
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = 35;
    IF NVL (cnombre,'') = '' THEN
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = '104006';
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;


                        --Validar que existe el archivo
    LET cnomarchivo		=  trim(cnombre)||'Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
    LET cnomarchivo1	=  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'.txt';
	LET cnomarchivoNvo	=  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'_nuevo'||'.txt';

        --              Obtiene la consulta de la Cartera de Tarjeta de Credito                                     -
        --------------------------------------------------------------------------------------------------------------
        -- Cliente |Credito | Tarjeta | Int Moratorio | Sdo Tot Liquidacion | Sdo Vencido Tot | Mens Actual |       - 
        -- No Vencidos | Status Cred | Fech Ult Pago | Pago 1 Mora | Tipo Prod | Cuenta Eje( N/A TDC) |             -

   -- IF pServicio = '1' OR pServicio = '3' THEN

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo); 

        LET cSQL2 = " SELECT numcte, num_credito, num_tarjeta, moratorio, " 
            || " (sdo_capital +  monto_vencido + mto_venc_trasp + cap_tras_no_venci + moratorio + interes_iva ) sdo_tot_liquid, "
            || " (monto_vencido + mto_venc_trasp + moratorio + interes_iva) sdo_venc_tot, mensualidad_actual, "
            || " mto_fin_ven_trasp::INTEGER no_vencidos, dias_vencido,atr, act, to_char( fecha_vencido,'%d/%m/%Y') fecha_vencido, fecha_ult_dispo, status_cred, fecha_ult_pago, pago_una_mora, num_producto, num_cta cuenta_eje, "
			|| " to_char(fecha_apertura,'%d/%m/%Y') fecha_apertura, antiguedad, monto_otorgado, mto_fin_ven_trasp::INTEGER vencidos_ant, novencidos1, novencidos2, novencidos3, novencidos4, "
			|| " novencidos5, novencidos6, bcscore::INTEGER bc_score, scoreprop::INTEGER score_prop, ficoscore::INTEGER fico_score, bhscore::INTEGER bhscore, "
			|| " grupo, sucursal, SUBSTR(lpad(nvl(trim(celular),''),13,'0'),-10),ejecutivo "
            || " FROM bdicred:sd_sdos_cartera_linea "
            || " WHERE num_producto IN ('6001','8100','8500') "; 

        LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchCARTERAlinea.sql';

        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cnomarchivo || " >> " || TRIM(cRuta) || cnomarchivoNvo; --cnomarchivo1;
        SYSTEM cSql;

        --Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo;
        SYSTEM cSQL;

   -- END IF;

	  -- ADLM: SE AGREGA ARCHIVO CON CAMPOS NUEVOS SOLICITADOS EN EL RQM 09 463
		LET cSQL = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18 -d '|' " || TRIM(cruta) || trim(cnomarchivoNvo) || ' >' || TRIM(cruta) || trim(cnomarchivo1);
		System cSQL;                                          --Nota se quito el parametro de la fecha de apertura 
	
		LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivoNvo;
		LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivo1;
		System cSQL;
		
	
    --IF pServicio = '2' OR pServicio = '3' THEN
            
        LET cnomarchivoAuxRPp =  trim(cnombre)||'R_PP_Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
        -- cnomarchivo1 Contiene la consulta de Tarjeta de Credito...

        LET cSQL  = ""; 
        LET cSQL1 = "";
        LET cSQL2 = "";
        LET cSQL3 = "";

        --              Obtiene la consulta de la Cartera de Reestructura y Prestamo Personal                       -
        -- -------------------------------------------------------------------------------------------------------- -
        -- Cliente |Credito | Tarjeta | Int Moratorio | Sdo Tot Liquidacion | Sdo Vencido Tot | Mens Actual |       -
        -- No Vencidos | Status Cred | Fech Ult Pago | Pago 1 Mora | Tipo Prod | Cuenta Eje( N/A TDC) |             -

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivoAuxRPp); 
        --AAME RQM 10 393 20150624 Se solicita contemplar los dos nuevos productos de prestamo personal (7600,7700)
        LET cSQL2 = " SELECT numcte, num_credito, num_tarjeta, moratorio, "
            || " (sdo_cap_insoluto + sdo_intereses + interes_iva + moratorio + sdo_retenido ) sdo_tot_liquid, "
            || " (monto_vencido + mto_venc_trasp + interes_iva + moratorio - iva_int_trasp) sdo_venc_tot, mensualidad_actual, " 
            || " mto_fin_ven_trasp::INTEGER no_vencidos, dias_vencido,atr, act, to_char( fecha_vencido,'%d/%m/%Y') fecha_vencido, fecha_ult_dispo, status_cred, fecha_ult_pago, pago_una_mora, num_producto, num_cta cuenta_eje, "
			|| " to_char(fecha_apertura,'%d/%m/%Y') fecha_apertura, antiguedad, monto_otorgado, mto_fin_ven_trasp::INTEGER vencidos_ant, novencidos1, novencidos2, novencidos3, novencidos4, "
			|| " novencidos5, novencidos6, bcscore::INTEGER bc_score, scoreprop::INTEGER score_prop, ficoscore::INTEGER fico_score, bhscore::INTEGER bhscore, "
			|| " grupo, sucursal, SUBSTR(lpad(nvl(trim(celular),''),13,'0'),-10), ejecutivo "
            || " from bdicred:sd_sdos_cartera_linea "
            || " WHERE num_producto IN ('6011','6300','6400','6800','7600','7700') ";
            
        LET cSQL3 = '">'||TRIM(cRuta)||'Ejec_GenCARTLinea_Reest_PP.sql';

        LET cSQL = trim(cSQL1) ||cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cnomarchivoAuxRPp || " >> " || TRIM(cRuta) || cnomarchivoNvo;		SYSTEM cSql;

        --Borra el archivo de control.
    	LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoAuxRPp;
        SYSTEM cSQL;

   -- END IF;          
   
   -- ADLM: SE AGREGA ARCHIVO CON CAMPOS NUEVOS SOLICITADOS EN EL RQM 09 463
	LET cSQL = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18 -d '|' " || TRIM(cruta) || trim(cnomarchivoNvo) || ' >' || TRIM(cruta) || trim(cnomarchivo1);
    System cSQL;												--Nota se quito el parametro de la fecha de apertura 
	
	LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivoNvo;
	LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivo1;
    System cSQL;
	
	
    --                  Fin consultas | & | Concluye datos en bitacora                                          -
  
    LET cCod_Ret = "00000";
    LET cMensajeRet = "PROCESO CONCLUIDO";

    /*UPDATE bdicred:"informix".sd_contproc SET status_proc = 'F', hora_fin = CURRENT, cod_ret = cCod_ret, mensaje = cMensajeRet
     WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    UPDATE bdinteg:"informix".sx_contproc SET status_proc = 'F', hora_fin = CURRENT, codret = cCod_ret
     WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha  = pFecha; */

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '03') RETURNING cCod_retBit;
    RETURN cCod_ret,cMensajeRet;

END;

END PROCEDURE;