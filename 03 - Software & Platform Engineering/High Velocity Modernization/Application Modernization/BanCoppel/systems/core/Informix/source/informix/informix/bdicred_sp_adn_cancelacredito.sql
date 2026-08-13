CREATE PROCEDURE "informix".sp_adn_cancelacredito(pEmpresa CHAR(3), pNumCredito CHAR(20))
returning char (6);

DEFINE cNumProducto             Char(4);
DEFINE dFecha                   Date;
DEFINE dpri_dia_mes				Date;
DEFINE ddia_corte				char(2);
DEFINE cFolio                   Char(16);
DEFINE cSucursal                Char(4);
DEFINE cDivisa                  Char(2);
DEFINE vMontoLineaNoDispuesta   Decimal(16,2);
DEFINE vMontoVencidoExigible    Decimal(16,2);
DEFINE vMontoVencidoNoExigible  Decimal(16,2);

DEFINE g_IntMoraCob   MONEY(14,2);
DEFINE g_IntVencCob   MONEY(14,2);
DEFINE g_CapVencCob   MONEY(14,2);
DEFINE g_IntVigCob    MONEY(14,2);
DEFINE g_CapVigCob    MONEY(14,2);
DEFINE g_Impuesto     MONEY(14,2);
DEFINE g_Comision     MONEY(14,2);
DEFINE g_Seguro       MONEY(14,2);
DEFINE g_Remanente    MONEY(14,2);
DEFINE g_StatusCtaCap CHAR(1) ;
DEFINE g_SdoCta	 	  DECIMAL(14,2)  ;

DEFINE CodRet         CHAR(5);
DEFINE cCodRetAux	  CHAR(6);
DEFINE Mensaje        CHAR(80);
DEFINE sql_err        SMALLINT;
DEFINE isam_err       SMALLINT;
DEFINE error_info     CHAR(40);
DEFINE nRows          SMALLINT;
DEFINE g_SdoDisp	  DECIMAL(14,2)  ;

-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
DEFINE cCodRetGF	  CHAR(6);
DEFINE cFolioSuc	  CHAR(16);
DEFINE cNumCte		  CHAR(20);
DEFINE cCtaNom		  CHAR(20);
DEFINE cNumSol		  CHAR(20);
DEFINE dMonto_disp    MONEY(14,2);
DEFINE  g_TranRet	  CHAR(4) ;
DEFINE  g_FechaCargo  DATE  ;
DEFINE  dtFechaHoy	  DATE  ;
DEFINE  g_MtoRet	  DECIMAL(14,2)  ;

--Set debug file to 'sp_Proceso_Venta_Cartera.out';
--trace on;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
     Rollback Work;
	  LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

--SET DEBUG FILE TO "/informix/jesus/sp_adn_cancelacredito.out";
--TRACE ON;

	LET cCodRetGF	  = '';
	LET cFolioSuc	  = '';
	LET g_Remanente   = 0;
	LET g_IntMoraCob  = 0;
	LET g_IntVencCob  = 0;
	LET g_CapVencCob  = 0;
	LET g_IntVigCob   = 0;
	LET g_CapVigCob   = 0;
	LET g_Impuesto    = 0;
	LET g_Comision    = 0;
	LET g_Seguro      = 0;   
	LET dMonto_disp   = 0;   
	LET cNumCte		  = "";
	LET cCtaNom		  = "";
	LET cNumSol 	  = "";
	LET cCodRetAux	  = "000000";
	LET g_StatusCtaCap = '';
	LET g_SdoCta      = 0;
	LET g_SdoDisp     = 0;
	LET  g_TranRet	  = '';
	LET  g_FechaCargo = DATE(1)  ;
	LET  dtFechaHoy	  = DATE(1)  ;
	LET  g_MtoRet	  = 0;

	SELECT pri_dia_mes, fecha_hoy  --Obtiene la Fecha del Dia
	INTO dpri_dia_mes, dFecha--, vult_hab_mes, vpri_hab_mes
	FROM bdicred:sd_fechas
	WHERE empresa = pEmpresa;

   BEGIN WORK;
   
   --- PROCESO GENERICO PARA GENERAR UN FOLIO
			--se valida previamente que el cliente presente adeudos, y si cuenta con saldo en la cuenta se procede a cobrar el adeudo.
			
			 SELECT d.numcte , a.num_credito,d.cuenta_nomina ,a.divisa, b.monto_financiado				   
			  INTO cNumCte,cNumSol,cCtaNom , cDivisa, dMonto_disp
			 FROM "informix".sd_maecred a,
				   "informix".sd_maesdos b,
				   "informix".sd_maecredanexo c,
				   bdisolic:"informix".ss_adn_solicitudcuenta d,
					bdicheq:"informix".sc_maechq e
			 WHERE a.empresa       = '001'
			   AND a.status_cred   NOT IN ('FF','FC','CV')
			   AND b.empresa       = a.empresa
			   AND b.num_credito   = a.num_credito
			   AND c.num_credito   = b.num_credito
			   and d.num_solicitud  =a.num_credito
			   AND c.empresa       = b.empresa
			   AND a.num_producto  = '7800'
			   AND a.num_credito = pNumCredito      
			   AND e.cuenta = d.cuenta_nomina;
			
			
			EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina('ANTICIPO') INTO  cCodRetGF , cFolioSuc ;
	
			IF dMonto_disp > 0 THEN 
						  -- Se obtiene el saldo de la cuenta identificada.
				CALL bdicheq:"informix".cons_saldo(cCtaNom) RETURNING cCodRetAux,g_SdoCta,g_StatusCtaCap;

				-- Valida el saldo obtenido de la cuenta.
				IF NVL(g_SdoCta,0) > 0 THEN						 
				
					IF g_SdoCta < dMonto_disp THEN 
						LET dMonto_disp = g_SdoCta;								
					END IF;
					--se realiza el cargo a la cuenta			
					EXECUTE PROCEDURE  bdicheq:"informix".cargo_ref('001', '9290', 'informix', '0398', "0000", cFolioSuc,cCtaNom, 0, dMonto_disp,cDivisa,"", "0", '')
					INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;	
					
							--se realiza el pago al crÃ©dito de nomina
					CALL "informix".Principal('001',cNumSol,1,dMonto_disp,'ANTICIPO','9290',cFolioSuc,'8175')
					returning cCodRetAux, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
					   g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
			   
				END IF;			
			END IF ;
			
			--se procede a liquidar el credito por inactividad en 6 meses 
      
			-- Se Actualiza el Status del Maestro de Credito al Status CV (Cartera Vendida).
		    Update bdicred:sd_maecred Set status_cred= 'FF' Where empresa = pEmpresa and num_credito= pNumCredito;

			-- Se Actualiza la fecha de proceso por estar bloqueados los crÃ©ditos
		    Update bdicred:sd_maecredanexo Set fecha_proceso = current Where empresa=pEmpresa And num_credito= pNumCredito;
		
		    SELECT
                a.num_producto, a.sucursal, a.divisa, 
                b.monto_otorgado - (b.sdo_capital + b.monto_vencido + b.mto_venc_trasp + b.cap_tras_no_venci),-- Se obtiene el monto de la LINEA DE CREDITO NO DISPUESTA
                b.Mto_venc_trasp + b.monto_vencido, b.cap_tras_no_venci + b.sdo_capital
            INTO
                cNumProducto, cSucursal, cDivisa,  
                vMontoLineaNoDispuesta,
                vMontoVencidoExigible, vMontoVencidoNoExigible
            FROM
                sd_maecred a, sd_maesdos b, sd_definicion d,
                bdinteg:si_sucursales e
            WHERE a.empresa        = pEmpresa
              AND a.num_credito      = pNumCredito
              AND a.bandera_ministra = 'M'
              AND b.empresa          = a.empresa
              AND b.num_credito      = a.num_credito
              AND d.empresa          = a.empresa
              AND d.num_producto     = a.num_producto
              AND e.empresa			= a.empresa
              AND e.sucursal         = a.sucursal;

			  			  
            If vMontoLineaNoDispuesta > 0 Then
                -- Cancelacion del registro de la LINEA DE CREDITO NO DISPUESTA
                    CALL GenMov(pEmpresa, pNumCredito, cNumProducto, 20,
                                "066", dFecha, vMontoLineaNoDispuesta, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
            Else
                let vMontoLineaNoDispuesta = abs(vMontoLineaNoDispuesta);
                -- Saldo Negativo Inversa de la Cancelacion del registro de la LINEA DE CREDITO NO DISPUESTA
                    CALL GenMov(pEmpresa, pNumCredito, cNumProducto, 21,
                                "066", dFecha, vMontoLineaNoDispuesta, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
            End If;
				
			IF vMontoVencidoExigible > 0 THEN
                -- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMov(pEmpresa, pNumCredito, cNumProducto, 1,
                                "066", dFecha, vMontoVencidoExigible, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
			END IF;
			IF vMontoVencidoNoExigible > 0 THEN
                -- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMov(pEmpresa, pNumCredito, cNumProducto, 2,
                                "066", dFecha, vMontoVencidoNoExigible, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
			END IF;
			
            -- Se Actualizan los saldos
               Update sd_maesdos
                  Set mto_venc_trasp=0, monto_vencido=0,
                      cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0,
                      sdo_capital=0, sdo_cap_insoluto=0, monto_otorgado = 0,
                      monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0
                 Where empresa = pEmpresa
                   And num_credito= pNumCredito;

            -- Se Actualizan las amortizaciones

               Update sd_amortiza_credito
                  Set capital_status = 5,
                      iva_pagado = iva_debe,
                      mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
                      mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
                      mora_provi_ordi = 0,
                      mora_provi_cope = 0,
                      capital_pagado  = 0
                 Where empresa = pEmpresa
                   And num_credito= pNumCredito
                   and (capital_status in ('2','7','6') or interes_debe <> 0);

    Commit Work;

LET CodRet = '00000';
RETURN CodRet;

end;
end procedure;