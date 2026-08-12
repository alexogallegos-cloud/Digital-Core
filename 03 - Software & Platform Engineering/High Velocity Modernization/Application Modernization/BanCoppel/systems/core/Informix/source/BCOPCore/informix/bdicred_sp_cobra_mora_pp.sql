CREATE PROCEDURE "informix".sp_cobra_mora_pp(pFechaCuota DATE,pPagoIvaMora DECIMAL(18,2), pPagoMoraCope DECIMAL(18,2), pPagoMoraOrdi DECIMAL(18,2))
   RETURNING CHAR(6)  AS codigo_ret,
             CHAR(80) AS mensaje;

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(100);
DEFINE cCodRet                       CHAR(6);
DEFINE cMensajeRet                   CHAR(80);
DEFINE iReferenciaBas                INTEGER;
DEFINE iReferenciaCop                INTEGER;

DEFINE GLOBAL g_Empresa              CHAR(3)        DEFAULT "001";
DEFINE GLOBAL g_NumCred              CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_NumProd              CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_CodFun               CHAR(3)        DEFAULT "";
DEFINE GLOBAL g_dtFechaHoy           DATE           DEFAULT "";
DEFINE GLOBAL g_Folio                CHAR(16)       DEFAULT "";
DEFINE GLOBAL g_Sucursal             CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_Divisa               CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_TransaccSuc          CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_NumPago              CHAR(40)       DEFAULT "";

DEFINE GLOBAL g_Remanente_pago       DECIMAL(18,2)  DEFAULT 0;

LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = "";
LET cCodRet       = "000000";
LET cMensajeRet   = "Se realizó el proceso exitosamente";


-- SET DEBUG FILE TO "/home/tmp/MireyaR/sp_cobra_moratorios_pp.out";
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    IF NVL(pPagoIvaMora,0)= 0 THEN 
		LET pPagoIvaMora=0; 
	END IF;
    IF NVL(pPagoMoraCope,0)= 0 THEN 
		LET pPagoMoraCope=0; 
	END IF;
    IF NVL(pPagoMoraOrdi,0) = 0 THEN 
		LET pPagoMoraOrdi=0; 
	END IF;

	-- Se Actualiza la tabla de amortizaciones
	UPDATE "informix".sd_amortiza_creditocrd
	   SET mora_iva_debe       = mora_iva_debe + pPagoIvaMora,
	       mora_iva_pagado     = mora_iva_pagado + pPagoIvaMora,
		   mora_sdo_cope_pag   = mora_sdo_cope_pag + pPagoMoraCope,
		   mora_sdo_ordi_pag   = mora_sdo_ordi_pag + pPagoMoraOrdi,
		   mora_iva_fecha_pago = g_dtFechaHoy
	 WHERE empresa     = g_Empresa
       AND num_credito = g_NumCred
       AND fecha_cuota = pFechaCuota;

	-- Se Actualiza la tabla de saldos
	UPDATE "informix".sd_maesdoscrd
	   SET sdo_contab_mora = sdo_contab_mora - pPagoMoraOrdi,
	       sdo_moratorio   = sdo_moratorio - pPagoMoraCope,
           dias_acum_mora  = (case when (sdo_contab_mora + sdo_moratorio)=0 then 0 else dias_acum_mora end)
	 WHERE empresa         = g_Empresa
       AND num_credito     = g_NumCred;

	-- Se Genera Movimiento de Pago de Interes Moratorio
	IF g_TransaccSuc IN ("7795","7796") AND (pPagoMoraCope + pPagoMoraOrdi) > 0 THEN
			 IF g_NumProd = "6400" THEN
			 
				  LET iReferenciaBas = 7;
				  LET iReferenciaCop = 8;
			 
			 ELIF g_NumProd = "6300" THEN
			 
				  LET iReferenciaBas = 12;
				  LET iReferenciaCop = 13;
			 
			 END IF;
			 CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,iReferenciaBas,g_CodFun,g_dtFechaHoy,pPagoMoraOrdi,
						   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
				 RETURNING cCodRet, cMensajeRet;

			 IF (cCodRet <> "000000") THEN
				RETURN cCodRet,cMensajeRet;
			 END IF;
			 
			 CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,iReferenciaCop,g_CodFun,g_dtFechaHoy,pPagoMoraCope,
						   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
				 RETURNING cCodRet, cMensajeRet;

			 IF (cCodRet <> "000000") THEN
				RETURN cCodRet,cMensajeRet;
			 END IF;
	ELSE
		IF (pPagoMoraCope + pPagoMoraOrdi) > 0 THEN
		IF g_TransaccSuc = '9888' THEN
			CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,72,'059',g_dtFechaHoy,(pPagoMoraCope + pPagoMoraOrdi),
						   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
				 RETURNING cCodRet, cMensajeRet;
		/*ELIF g_TransaccSuc = '9854' THEN
			CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,72,'059',g_dtFechaHoy,(pPagoMoraCope + pPagoMoraOrdi),
						   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
				 RETURNING cCodRet, cMensajeRet;*/
		ELIF g_TransaccSuc = '4320' THEN
			CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,121,'059',g_dtFechaHoy,(pPagoMoraCope + pPagoMoraOrdi),
						   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
				 RETURNING cCodRet, cMensajeRet;
		ELSE
			CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,2,g_CodFun,g_dtFechaHoy,(pPagoMoraCope + pPagoMoraOrdi),
						   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
				 RETURNING cCodRet, cMensajeRet;
		END IF;

			IF (cCodRet <> "000000") THEN
				RETURN cCodRet,cMensajeRet;
			END IF;
		END IF;
	END IF;

	-- Se Genera Movimiento de Pago de Iva de Interes Moratorio
    -- Se contemplan dos escenarios Iva del 10% y 15% -- se pide eliminar el contemplar ambos escenarios
	IF g_TransaccSuc IN ("7795","7796") AND pPagoIvaMora > 0 THEN
	
	        IF g_NumProd = "6400" THEN
			 
				  LET iReferenciaBas = 9;
			 
			 ELIF g_NumProd = "6300" THEN
			 
				  LET iReferenciaBas = 14;
			 
			 END IF;
			 
	        CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,iReferenciaBas,g_CodFun,g_dtFechaHoy,pPagoIvaMora,
						   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
				 RETURNING cCodRet, cMensajeRet;

			IF (cCodRet <> "000000") THEN
				RETURN cCodRet,cMensajeRet;
			END IF;
	ELSE
		IF pPagoIvaMora > 0 THEN
			IF g_TransaccSuc = '9888' THEN
				CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,73,'059',g_dtFechaHoy,pPagoIvaMora,
							   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
					 RETURNING cCodRet, cMensajeRet;
			/*ELIF g_TransaccSuc = '9854' THEN
				CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,73,'059',g_dtFechaHoy,pPagoIvaMora,
							   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
					 RETURNING cCodRet, cMensajeRet;*/
			ELIF g_TransaccSuc = '4320' THEN
				CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,122,'059',g_dtFechaHoy,pPagoIvaMora,
							   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
					 RETURNING cCodRet, cMensajeRet;
			ELSE
				CALL "informix".genmovcrd(g_Empresa,g_NumCred,g_NumProd,3,g_CodFun,g_dtFechaHoy,pPagoIvaMora,
						   g_Folio,g_Sucursal, g_Divisa, g_TransaccSuc,g_NumPago,"")
					 RETURNING cCodRet, cMensajeRet;
			END IF;

			IF (cCodRet <> "000000") THEN
				RETURN cCodRet,cMensajeRet;
			END IF;
		 END IF;
    END IF;
	
	RETURN cCodRet,cMensajeRet;

END PROCEDURE
DOCUMENT
'Modificacion: Se implementan los nuevos conceptos de pago "Condonacion"(7795) y "condonacion por fallecimiento" (7796) para la condonacion',
'			   de intereses moratorios y vencidos para los productos de PRESTAMO PERSONAL y CREDINOMINA',
'Modifico: Mireya Gpe Reyes Vargas',
'Folio: 1395 Condonacion Intereses',
'BD: bdicred',
'Version: 20140107.1452';

CREATE PROCEDURE "informix".cobraintvencido(e_fcuota DATE,
                                            e_IvaInt DECIMAL(14,2),
                                            e_Int    DECIMAL(14,2))
   RETURNING CHAR(5);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto   CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_TpPago        SMALLINT    DEFAULT 0;

   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_IntVencCob    MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoVencInt    MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoVencTraInt MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_StCred	 CHAR(2) DEFAULT ' ';
   --DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;

   DEFINE vCobro7                LIKE sd_pagocapit.monto_cuota;
   DEFINE vCobro2                LIKE sd_pagocapit.monto_cuota;
   DEFINE vCapCobrado            LIKE sd_pagocapit.monto_cuota;
   DEFINE vFechaCuota            LIKE sd_paginter.fecha_cuota;
   DEFINE vIntVenc               LIKE sd_paginter.monto_cuota;
   DEFINE vIvaVenc               LIKE sd_paginter.monto_cuota;
   DEFINE vCuotaRec              LIKE sd_paginter.cuota_rec;
   DEFINE vMontoCuota            LIKE sd_paginter.monto_cuota;
   DEFINE vMontoRealPag          LIKE sd_paginter.monto_real_pag;
   DEFINE vMontoFinanc           LIKE sd_paginter.monto_financiado;
   DEFINE vStatusCuota           LIKE sd_paginter.status_cuota;
   DEFINE vIntCob                LIKE sd_paginter.monto_cuota;
   DEFINE vIntFinan              LIKE sd_paginter.monto_cuota;
   DEFINE vIntCob7               LIKE sd_paginter.monto_cuota;
   DEFINE vIvaCob7               LIKE sd_paginter.monto_cuota;
   DEFINE vIvaCob2               LIKE sd_paginter.monto_cuota;
   DEFINE vIntCob2               LIKE sd_paginter.monto_cuota;
   DEFINE vIntdebe               LIKE sd_paginter.monto_cuota;
   DEFINE vIntIva                LIKE sd_paginter.monto_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vStatus                LIKE sd_paginter.status_cuota;
   DEFINE vStatusAnt             LIKE sd_paginter.status_cuota;
   DEFINE v_IvaIntaux            DECIMAL(14,2);
   DEFINE vStatusIva             LIKE sd_paginter.status_cuota;
   DEFINE dIvaIntVencCob         MONEY(14,2);

	ON EXCEPTION SET sql_err, isam_err, error_info
		--SET DEBUG FILE TO "CobraIntVencido.err";
		--TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET CodRet = sql_err;
		RETURN CodRet;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	LET vIntCob   = 0;
	LET vIntFinan = 0;
	LET vIntCob7  = 0;
	LET vIntCob2  = 0;
	LET vIvaCob7  = 0;
	LET vIvaCob2  = 0;
	LET dIvaIntVencCob = 0;
	LET CodRet    = '000';
	LET vIntVenc  = 0;
	LET vCobro7   = 0;
	LET vCobro2   = 0;
	LET vIntdebe  = 0;
	LET vIntIva   = 0;
	LET vCapCobrado= 0;
	LET vStatus   = '';
	LET vStatusAnt= '';
	LET vCuotaRec = '';
	LET e_IvaInt  = e_IvaInt;
	LET e_Int     = e_Int;
	LET v_IvaIntaux=e_IvaInt;


	IF (g_StCred='AA' OR g_StCred='BA' OR g_StCred='BT') THEN

		IF e_IvaInt > 0  THEN
			FOREACH
			/*{
			SELECT min(fecha_cuota),capital_status INTO vFechaCuota,vStatus
			FROM sd_amortiza_credito
			WHERE empresa = g_Empresa             AND
			num_credito = g_NumCredito      AND
			capital_status not in ("1",'5') AND
			interes_status in ('3')   AND
			nvl(interes_debe,0) - nvl(interes_pagado,0) > 0
			GROUP BY 2
			ORDER BY 1
			}*/
				SELECT fecha_cuota,sum(iva_debe  - iva_pagado) ,iva_status,capital_status,iva_status_ant
				INTO vFechaCuota,vIntIva,vStatusIva,vStatus,vStatusAnt
				FROM "informix".sd_amortiza_credito
				WHERE empresa = g_Empresa             
				AND	num_credito = g_NumCredito      
				AND capital_status not in ('1','5') 
				AND interes_status in ('3')         
				AND nvl(iva_debe,0) - nvl(iva_pagado,0) > 0
				GROUP BY 1,3,4,5
				ORDER BY 1

				IF v_IvaIntaux > 0 THEN

				--      IF (g_Remanente >= e_IvaInt) THEN
				--          LET g_Remanente = g_Remanente - e_IvaInt;
				--          LET vStatusAnt = vStatus;
				--          LET vStatus = '5';
				--      ELSE
				--         LET g_Remanente = 0;
				--      END IF;

					IF (v_IvaIntaux >= vIntIva) THEN
						LET g_Remanente = g_Remanente - vIntIva;
						LET v_IvaIntaux=v_IvaIntaux - vIntIva;
						LET vStatusAnt = vStatusIva;
						LET vStatusIva = '5';
					ELSE
						LET vIntIva=v_IvaIntaux;
						LET v_IvaIntaux=0;
						LET g_Remanente = g_Remanente-vIntIva;
					END IF;

					UPDATE "informix".sd_amortiza_credito
					SET iva_pagado = iva_pagado + vIntIva,
					iva_status     = vStatusIva,
					iva_status_ant = vStatusAnt,
					iva_fecha_pago = g_fecha
					WHERE empresa  = g_empresa    
					AND num_credito = g_NumCredito 
					AND fecha_cuota = vFechaCuota;
				END IF;
				
			END FOREACH;
				 --**Movimientos Contables Por La Proporcion **--
		--- ESTE VA AL FINAL
			IF g_Transacc NOT IN ('7795','7796') THEN
				IF vStatus = '2' THEN
					IF g_Transacc = '9854' THEN
						LET vReferencia = 40;   -- PAGO ATM CGO CUENTA
					ELIF g_Transacc = '4356' THEN
						LET vReferencia = 97;   -- PAGO ATM EFECTIVO
					ELSE
						LET vReferencia = 6640;   -- Iva Vencido Traspasado
					END IF;
					
					CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
					g_CodigoFun, g_Fecha, e_IvaInt, g_Folio,
					g_Sucursal, g_Divisa, g_Transacc) RETURNING
					CodRet, Mensaje;
					
					IF (CodRet <> "00000") THEN
						RETURN CodRet;
					ELSE
						LET CodRet = "000";
						LET e_IvaInt = e_IvaInt - e_IvaInt;
					END IF;
					
				ELIF vStatus = '7' THEN
					IF g_Transacc = '9854' THEN
						LET vReferencia = 40;   -- PAGO ATM CGO CUENTA
					ELIF g_Transacc = '4356' THEN
						LET vReferencia = 97;   -- PAGO ATM EFECTIVO
					ELSE
						LET vReferencia = 6641;   --Iva vencido no traspasado
					END IF;
					
					CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
					g_CodigoFun, g_Fecha, e_IvaInt, g_Folio,
					g_Sucursal, g_Divisa, g_Transacc) RETURNING
					CodRet, Mensaje;
					
					IF (CodRet <> "00000") THEN
						RETURN CodRet;
					ELSE
						LET CodRet = "000";
						LET e_IvaInt = e_IvaInt - e_IvaInt;
					END IF;
				END IF;
			END IF;
		END IF
		IF e_Int > 0 THEN

			IF (g_ManejaLinea <> 'S') THEN
				UPDATE "informix".sd_maesdos
				SET sdo_exig_int     = sdo_exig_int - e_Int,
				mto_venc_int     = mto_venc_int - e_Int,
				mto_venc_tra_int = mto_venc_tra_int - e_Int
				WHERE empresa = g_Empresa 
				AND num_credito = g_NumCredito;
			ELSE
				UPDATE "informix".sd_maesdos
				SET int_tra_no_exig = int_tra_no_exig - e_Int
				WHERE empresa     = g_Empresa 
				AND num_credito = g_NumCredito;
			END IF
			
			FOREACH
				SELECT fecha_cuota,sum(interes_debe  - interes_pagado) ,interes_status
				INTO vFechaCuota,vIntdebe,vStatus
				FROM "informix".sd_amortiza_credito
				WHERE empresa = g_Empresa             
				AND num_credito = g_NumCredito      
				AND capital_status not in ('1','5') 
				AND interes_status in ('3')         
				AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0
				GROUP BY 1,3
				ORDER BY 1
				--LET g_Remanente = g_Remanente - e_Int;
				IF e_Int > 0 THEN
					--**Movimientos Contables Por La Proporcion **--
					IF g_Remanente > 0 THEN
						IF vStatus = '3' THEN
							IF (g_Remanente >= vIntdebe) THEN
								LET g_Remanente = g_Remanente - vIntdebe;
								LET vCobro2 = vCobro2 + vIntdebe;
								LET vCuotaRec = vStatus;
								LET vStatus = '5';
							ELSE
								let vCapCobrado  = vCapCobrado;
								Let g_Remanente = g_Remanente;
								LET vCobro2 = vCobro2;
								LET vCobro2 = vCobro2 + g_Remanente;
								LET g_Remanente = 0;
							END IF;
							
							LET vCapCobrado = vCapCobrado + vCobro2;

							UPDATE "informix".sd_amortiza_credito
							SET interes_pagado     = interes_pagado + vCapCobrado,
							interes_status     = vStatus,
							interes_status_ant = vCuotaRec,
							interes_fecha_pago = g_fecha
							WHERE empresa     = g_empresa    
							AND num_credito = g_NumCredito 
							AND fecha_cuota = vFechaCuota;

							--CAS INI
							LET g_IntVencCob = g_IntVencCob + vCobro2;
							--CAS FIN
							LET vCapCobrado = 0;
							LET vCobro2 = 0;

						END IF;
					END IF;
				END IF;
			END FOREACH;
			

			IF g_Transacc = '9854' THEN
				LET vReferencia = 41;   -- PAGO ATM CGO CUENTA
			ELIF g_Transacc = '4356' THEN
				LET vReferencia = 98;   -- PAGO ATM EFECTIVO
			ELSE
				LET vReferencia = 5;   -- Interes Vencido Traspasado
			END IF;
			
			CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
			g_CodigoFun, g_Fecha, e_Int, g_Folio,
			g_Sucursal, g_Divisa, g_Transacc) RETURNING
			CodRet, Mensaje;
			
			IF (CodRet <> "00000") THEN
				RETURN CodRet;
			ELSE
				LET CodRet = "000";
			END IF;

		ELSE --** Pago Normal Sin Porcentaje **--
			FOREACH
				SELECT fecha_cuota,(interes_debe - interes_pagado),interes_status,(iva_debe - iva_pagado)
				INTO vFechaCuota, vIntVenc, vStatusCuota, vIvaVenc
				FROM "informix".sd_amortiza_credito
				WHERE empresa = g_Empresa
				AND num_credito = g_NumCredito
				AND fecha_cuota < (SELECT MIN(fecha_cuota)
									FROM "informix".sd_amortiza_credito
									WHERE empresa = g_Empresa
									AND num_credito = g_NumCredito
									AND capital_status = "1")
				AND interes_status in ('3')
				AND capital_status not in ("1",'5')  ---MOD  CAS
				AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0
				ORDER BY fecha_cuota

				IF g_TpPago = "2" AND vFechaCuota <> e_fcuota THEN
					CONTINUE FOREACH;
				END IF

				LET vStatus = vStatusCuota;

				IF (g_Remanente > 0) THEN

					-- Cobra Iva
					IF (g_Remanente >= vIvaVenc) THEN
						LET g_Remanente = g_Remanente - vIvaVenc;
						
						IF (vStatusCuota = '7') THEN
							LET vIvaCob7 = vIvaCob7 + vIvaVenc;
						ELSE
							LET vIvaCob2 = vIvaCob2 + vIvaVenc;
						END IF;
						
						LET vCuotaRec = vStatusCuota;
						LET vStatusCuota = '5';
					ELSE
						LET vIvaVenc = g_Remanente;
						LET g_Remanente = 0;
						
						IF (vStatusCuota = '7') THEN
							LET vIvaCob7 = vIvaCob7 + vIvaVenc;
						ELSE
							LET vIvaCob2 = vIvaCob2 + vIvaVenc;
						END IF;

						LET vStatusCuota = vStatus;
					END IF;

					UPDATE "informix".sd_amortiza_credito
					SET iva_status_ant = vCuotaRec,
					iva_pagado     = iva_pagado + vIvaVenc,
					iva_status     = vStatusCuota,
					iva_fecha_pago = g_fecha
					WHERE empresa = g_empresa
					AND num_credito = g_NumCredito
					AND fecha_cuota = vFechaCuota;


					-- Cobra Intereses
					IF (g_Remanente >= vIntVenc) THEN
						LET g_Remanente = g_Remanente - vIntVenc;
						
						IF (vStatusCuota = '7') THEN
							LET vIntCob7 = vIntCob7 + vIntVenc;
						ELSE
							LET vIntCob2 = vIntCob2 + vIntVenc;
						END IF;
						
						LET vCuotaRec = vStatusCuota;
						LET vStatusCuota = '5';
					ELSE
						LET vIntVenc = g_Remanente;
						LET g_Remanente = 0;
						
						IF (vStatusCuota = '7') THEN
							LET vIntCob7 = vIntCob7 + vIntVenc;
						ELSE
							LET vIntCob2 = vIntCob2 + vIntVenc;
						END IF;

						LET vStatusCuota = vStatus;

					END IF;

					UPDATE "informix".sd_amortiza_credito
					SET interes_status_ant = vCuotaRec,
					interes_pagado     = interes_pagado + vIntVenc,
					interes_status     = vStatusCuota,
					interes_fecha_pago = g_fecha
					WHERE empresa = g_empresa
					AND num_credito = g_NumCredito
					AND fecha_cuota = vFechaCuota;

				END IF;
				IF (g_Remanente = 0) THEN
					EXIT FOREACH;
				END IF;
			END FOREACH;

			-- *****************************
			-- *         TARJETA           *
			-- *****************************
			IF (g_ManejaLinea <> 'S') THEN

				UPDATE "informix".sd_maesdos
				SET sdo_exig_int = sdo_exig_int - vIntCob7 - vIntCob2,
				mto_venc_int = mto_venc_int - vIntCob7,
				mto_venc_tra_int = mto_venc_tra_int - vIntCob2
				WHERE empresa = g_Empresa
				AND num_credito = g_NumCredito;

			ELSE
				UPDATE "informix".sd_maesdos
				SET int_tra_no_exig = int_tra_no_exig - vIntCob2
				WHERE empresa = g_Empresa
				AND num_credito = g_NumCredito;

			END IF

			IF (vIntCob7 > 0) AND g_Transacc NOT IN ('7795','7796') THEN
				LET vReferencia = 3;   --Interes vencido no traspasado
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIntCob7, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;

			IF (vIntCob2 > 0) AND g_Transacc NOT IN ('7795','7796') THEN

				IF g_Transacc = '9854' THEN
					LET vReferencia = 41;   -- PAGO ATM CGO CUENTA
				ELIF g_Transacc = '4356' THEN
					LET vReferencia = 98;   -- PAGO ATM EFECTIVO
				ELSE
					LET vReferencia = 5;   -- Interes Vencido Traspasado
				END IF;
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIntCob2, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;
		   
			LET g_IntVencCob = g_IntVencCob + (vIntCob7 + vIntCob2);

			IF (g_IntVencCob > 0) AND g_Transacc IN ('7795','7796') THEN
				-- 21062018 AAME RQM 06590 y RQM 06 591 Se contemplan los productos oro y Platino, se agrega TDC GC
				IF g_NumProducto IN ("6001","7000","8100","8500") THEN
				 
					LET vReferencia = 5;
									 
				END IF;
				 
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, g_IntVencCob, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;
		   
			IF (vIvaCob7 > 0) AND g_Transacc NOT IN ('7795','7796') THEN
				IF g_Transacc = '9854' THEN
					LET vReferencia = 40;   -- PAGO ATM CGO CUENTA
				ELIF g_Transacc = '4356' THEN
					LET vReferencia = 97;   -- PAGO ATM EFECTIVO
				ELSE
					LET vReferencia = 6641;   --Iva vencido no traspasado
				END IF;
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIvaCob7, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;
		   
			IF (vIvaCob2 > 0) AND g_Transacc NOT IN ('7795','7796') THEN

				IF g_Transacc = '9854' THEN
					LET vReferencia = 40;   -- PAGO ATM CGO CUENTA
				ELIF g_Transacc = '4356' THEN
					LET vReferencia = 97;   -- PAGO ATM EFECTIVO
				ELSE
					LET vReferencia = 6640;   -- Iva Vencido Traspasado
				END IF;
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIvaCob2, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;

		    LET dIvaIntVencCob =  dIvaIntVencCob + (vIvaCob7 + vIvaCob2);
		   
			IF (dIvaIntVencCob > 0) AND g_Transacc IN ('7795','7796') THEN
			-- 21062018 AAME RQM 06590 y RQM 06 591 Se contemplan los productos oro y Platino, se agrega TDC GC
				IF g_NumProducto IN ("6001","7000","8100","8500") THEN
				 
					LET vReferencia = 6;

				END IF;
				 
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, dIvaIntVencCob, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;
		END IF;

	ELIF (g_StCred='E1' OR g_StCred='E2' OR g_StCred='E3') THEN

		IF e_IvaInt > 0  THEN
			FOREACH
			/*{
			SELECT min(fecha_cuota),capital_status INTO vFechaCuota,vStatus
			FROM sd_amortiza_credito
			WHERE empresa = g_Empresa             AND
			num_credito = g_NumCredito      AND
			capital_status not in ("1",'5') AND
			interes_status in ('3')   AND
			nvl(interes_debe,0) - nvl(interes_pagado,0) > 0
			GROUP BY 2
			ORDER BY 1
			}*/
				SELECT fecha_cuota,sum(iva_debe  - iva_pagado) ,iva_status,capital_status,iva_status_ant
				INTO vFechaCuota,vIntIva,vStatusIva,vStatus,vStatusAnt
				FROM "informix".sd_amortiza_credito
				WHERE empresa = g_Empresa             
				AND	num_credito = g_NumCredito      
				AND capital_status not in ('1','5') 
				AND interes_status in ('3')         
				AND nvl(iva_debe,0) - nvl(iva_pagado,0) > 0
				GROUP BY 1,3,4,5
				ORDER BY 1

				IF v_IvaIntaux > 0 THEN

				--      IF (g_Remanente >= e_IvaInt) THEN
				--          LET g_Remanente = g_Remanente - e_IvaInt;
				--          LET vStatusAnt = vStatus;
				--          LET vStatus = '5';
				--      ELSE
				--         LET g_Remanente = 0;
				--      END IF;

					IF (v_IvaIntaux >= vIntIva) THEN
						LET g_Remanente = g_Remanente - vIntIva;
						LET v_IvaIntaux=v_IvaIntaux - vIntIva;
						LET vStatusAnt = vStatusIva;
						LET vStatusIva = '5';
					ELSE
						LET vIntIva=v_IvaIntaux;
						LET v_IvaIntaux=0;
						LET g_Remanente = g_Remanente-vIntIva;
					END IF;

					UPDATE "informix".sd_amortiza_credito
					SET iva_pagado = iva_pagado + vIntIva,
					iva_status     = vStatusIva,
					iva_status_ant = vStatusAnt,
					iva_fecha_pago = g_fecha
					WHERE empresa  = g_empresa    
					AND num_credito = g_NumCredito 
					AND fecha_cuota = vFechaCuota;
				END IF;
				
			END FOREACH;
				 --**Movimientos Contables Por La Proporcion **--
		  --- ESTE VA AL FINAL
			IF g_TRansacc NOT IN ('7795','7796') THEN
				IF vStatus = '2' THEN
					--LET vReferencia = 6640;   -- Iva Vencido Traspasado
					--LET vReferencia = 6650;   -- Iva E2 --AEH
					IF g_Transacc = '9854' AND g_StCred = 'E1'  THEN --IVA INT. E1 CGO CUENTA ATM
			            LET vReferencia = 135;
				    ELIF g_Transacc = '9854' AND g_StCred = 'E2' THEN  --IVA INT. E2 CGO CUENTA ATM
						LET vReferencia = 136;
				    ELIF g_Transacc = '9854' AND g_StCred = 'E3' THEN  --IVA INT. E3 CGO CUENTA ATM
						LET vReferencia = 137;
				    ELIF g_Transacc = '4356' AND g_StCred = 'E1' THEN  --IVA INT. E1 EFECTIVO ATM
						LET vReferencia = 129;
				    ELIF  g_Transacc = '4356' AND g_StCred = 'E2' THEN  --IVA INT. E2 EFECTIVO ATM
						LET vReferencia = 130;
				    ELIF  g_Transacc = '4356' AND g_StCred = 'E3' THEN  --IVA INT. E3 EFECTIVO ATM
						LET vReferencia = 131;
				    ELSE
					  IF g_StCred = 'E1' THEN
						 LET vReferencia = 6651;   --IVA E1 --AEH
					  ELIF g_StCred = 'E2' THEN
						 LET vReferencia = 6650;   -- Iva E2 --AEH 
					  ELIF g_StCred = 'E3' THEN
						 LET vReferencia = 6652;   -- IVA VENCIDO E3 --AEH
					  END IF;
					END IF;
					
					CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
					g_CodigoFun, g_Fecha, e_IvaInt, g_Folio,
					g_Sucursal, g_Divisa, g_Transacc) RETURNING
					CodRet, Mensaje;
					
					IF (CodRet <> "00000") THEN
						RETURN CodRet;
					ELSE
						LET CodRet = "000";
						LET e_IvaInt = e_IvaInt - e_IvaInt;
					END IF;
					
				ELIF vStatus = '7' THEN
					--LET vReferencia = 6641;   --Iva vencido no traspasado
					--LET vReferencia = 6651;   -- Iva E1 --AEH
					
					IF g_Transacc = '9854' AND g_StCred = 'E1'  THEN --IVA INT. E1 CGO CUENTA ATM
			            LET vReferencia = 135;
				    ELIF g_Transacc = '9854' AND g_StCred = 'E2' THEN  --IVA INT. E2 CGO CUENTA ATM
						LET vReferencia = 136;
				    ELIF g_Transacc = '9854' AND g_StCred = 'E3' THEN  --IVA INT. E3 CGO CUENTA ATM
						LET vReferencia = 137;
				    ELIF g_Transacc = '4356' AND g_StCred = 'E1' THEN  --IVA INT. E1 EFECTIVO ATM
						LET vReferencia = 129;
				    ELIF  g_Transacc = '4356' AND g_StCred = 'E2' THEN  --IVA INT. E2 EFECTIVO ATM
						LET vReferencia = 130;
				    ELIF  g_Transacc = '4356' AND g_StCred = 'E3' THEN  --IVA INT. E3 EFECTIVO ATM
						LET vReferencia = 131;
				    ELSE
					  IF g_StCred = 'E1' THEN
						 LET vReferencia = 6651;   --IVA E1 --AEH
					  ELIF g_StCred = 'E2' THEN
						 LET vReferencia = 6650;   -- Iva E2 --AEH 
					  ELIF g_StCred = 'E3' THEN
						 LET vReferencia = 6652;   -- IVA VENCIDO E3 --AEH
					  END IF;
					END IF;

					CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
					g_CodigoFun, g_Fecha, e_IvaInt, g_Folio,
					g_Sucursal, g_Divisa, g_Transacc) RETURNING
					CodRet, Mensaje;
					
					IF (CodRet <> "00000") THEN
						RETURN CodRet;
					ELSE
						LET CodRet = "000";
						LET e_IvaInt = e_IvaInt - e_IvaInt;
					END IF;
				ELIF vStatus = '6' THEN
				   IF g_Transacc = '9854' AND g_StCred = 'E1'  THEN --IVA INT. E1 CGO CUENTA ATM
			             LET vReferencia = 135;
				   ELIF g_Transacc = '9854' AND g_StCred = 'E2' THEN  --IVA INT. E2 CGO CUENTA ATM
						LET vReferencia = 136;
				   ELIF g_Transacc = '9854' AND g_StCred = 'E3' THEN  --IVA INT. E3 CGO CUENTA ATM
						LET vReferencia = 137;
				   ELIF g_Transacc = '4356' AND g_StCred = 'E1' THEN  --IVA INT. E1 EFECTIVO ATM
						LET vReferencia = 129;
				   ELIF  g_Transacc = '4356' AND g_StCred = 'E2' THEN  --IVA INT. E2 EFECTIVO ATM
						LET vReferencia = 130;
				   ELIF  g_Transacc = '4356' AND g_StCred = 'E3' THEN  --IVA INT. E3 EFECTIVO ATM
						LET vReferencia = 131;
				   ELSE
					 IF g_StCred = 'E1' THEN
						LET vReferencia = 6651;   --IVA E1 --AEH
					 ELIF g_StCred = 'E2' THEN
						--LET vReferencia = 6640;   -- Iva Vencido Traspasado
						LET vReferencia = 6650;   -- Iva E2 --AEH 
					 ELIF g_StCred = 'E3' THEN
						LET vReferencia = 6652;   -- IVA VENCIDO E3 --AEH
					 END IF;
			       END IF;
				  				  
					CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
					g_CodigoFun, g_Fecha, e_IvaInt, g_Folio,
					g_Sucursal, g_Divisa, g_Transacc) RETURNING
					CodRet, Mensaje;
					
					IF (CodRet <> "00000") THEN
						RETURN CodRet;
					ELSE
						LET CodRet = "000";
						LET e_IvaInt = e_IvaInt - e_IvaInt;
					END IF;
				END IF;
			END IF;
		END IF
		IF e_Int > 0 THEN

			IF (g_ManejaLinea <> 'S') THEN
				UPDATE "informix".sd_maesdos
				SET sdo_exig_int     = sdo_exig_int - e_Int,
				mto_venc_int     = mto_venc_int - e_Int,
				mto_venc_tra_int = mto_venc_tra_int - e_Int
				WHERE empresa = g_Empresa 
				AND num_credito = g_NumCredito;
			ELSE
				UPDATE "informix".sd_maesdos
				SET int_tra_no_exig = int_tra_no_exig - e_Int
				WHERE empresa     = g_Empresa 
				AND num_credito = g_NumCredito;
			END IF
			
			FOREACH
				SELECT fecha_cuota,sum(interes_debe  - interes_pagado) ,interes_status
				INTO vFechaCuota,vIntdebe,vStatus
				FROM "informix".sd_amortiza_credito
				WHERE empresa = g_Empresa             
				AND num_credito = g_NumCredito      
				AND capital_status not in ('1','5') 
				AND interes_status in ('3')         
				AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0
				GROUP BY 1,3
				ORDER BY 1
				--LET g_Remanente = g_Remanente - e_Int;
				IF e_Int > 0 THEN
					--**Movimientos Contables Por La Proporcion **--
					IF g_Remanente > 0 THEN
						IF vStatus = '3' THEN
							IF (g_Remanente >= vIntdebe) THEN
								LET g_Remanente = g_Remanente - vIntdebe;
								LET vCobro2 = vCobro2 + vIntdebe;
								LET vCuotaRec = vStatus;
								LET vStatus = '5';
							ELSE
								let vCapCobrado  = vCapCobrado;
								Let g_Remanente = g_Remanente;
								LET vCobro2 = vCobro2;
								LET vCobro2 = vCobro2 + g_Remanente;
								LET g_Remanente = 0;
							END IF;
							
							LET vCapCobrado = vCapCobrado + vCobro2;

							UPDATE "informix".sd_amortiza_credito
							SET interes_pagado     = interes_pagado + vCapCobrado,
							interes_status     = vStatus,
							interes_status_ant = vCuotaRec,
							interes_fecha_pago = g_fecha
							WHERE empresa     = g_empresa    
							AND num_credito = g_NumCredito 
							AND fecha_cuota = vFechaCuota;

							--CAS INI
							LET g_IntVencCob = g_IntVencCob + vCobro2;
							--CAS FIN
							LET vCapCobrado = 0;
							LET vCobro2 = 0;

						END IF;
					END IF;
				END IF;
			END FOREACH;
			
			IF g_StCred = 'E1' THEN
                LET vReferencia = 923;   --Interes vencido E1 --AEH
        	ELIF g_StCred = 'E2' THEN
				LET vReferencia = 925;   --Interes vencido E2 --AEH
            ELIF g_StCred = 'E3' THEN
                LET vReferencia = 926;   --Interes vencido E3 --AEH
            END IF; 
			
				IF g_Transacc = '9854' THEN
					IF vReferencia = 923 THEN
						LET vReferencia = 132;
					ELIF vReferencia = 925 THEN
						LET vReferencia = 133;
					ELIF vReferencia = 926 THEN
						LET vReferencia = 134;
					END IF;
				END IF;
				
				IF g_Transacc = '4356' THEN
					IF vReferencia = 923 THEN
						LET vReferencia = 126;
					ELIF vReferencia = 925 THEN
						LET vReferencia = 127;
					ELIF vReferencia = 926 THEN
						LET vReferencia = 128;
					END IF;
				END IF;
				
			CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
			g_CodigoFun, g_Fecha, e_Int, g_Folio,
			g_Sucursal, g_Divisa, g_Transacc) RETURNING
			CodRet, Mensaje;
			
			IF (CodRet <> "00000") THEN
				RETURN CodRet;
			ELSE
				LET CodRet = "000";
			END IF;

		ELSE --** Pago Normal Sin Porcentaje **--
			FOREACH
				SELECT fecha_cuota,(interes_debe - interes_pagado),interes_status,(iva_debe - iva_pagado)
				INTO vFechaCuota, vIntVenc, vStatusCuota, vIvaVenc
				FROM "informix".sd_amortiza_credito
				WHERE empresa = g_Empresa
				AND num_credito = g_NumCredito
				AND fecha_cuota < (SELECT MIN(fecha_cuota)
									FROM "informix".sd_amortiza_credito
									WHERE empresa = g_Empresa
									AND num_credito = g_NumCredito
									AND capital_status = "1")
				AND interes_status in ('3')
				AND capital_status not in ("1",'5')  ---MOD  CAS
				AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0
				ORDER BY fecha_cuota

				IF g_TpPago = "2" AND vFechaCuota <> e_fcuota THEN
					CONTINUE FOREACH;
				END IF

				LET vStatus = vStatusCuota;

				IF (g_Remanente > 0) THEN

					-- Cobra Iva
					IF (g_Remanente >= vIvaVenc) THEN
						LET g_Remanente = g_Remanente - vIvaVenc;
						
						IF (vStatusCuota = '7') THEN
							LET vIvaCob7 = vIvaCob7 + vIvaVenc;
						ELSE
							LET vIvaCob2 = vIvaCob2 + vIvaVenc;
						END IF;
						
						LET vCuotaRec = vStatusCuota;
						LET vStatusCuota = '5';
					ELSE
						LET vIvaVenc = g_Remanente;
						LET g_Remanente = 0;
						
						IF (vStatusCuota = '7') THEN
							LET vIvaCob7 = vIvaCob7 + vIvaVenc;
						ELSE
							LET vIvaCob2 = vIvaCob2 + vIvaVenc;
						END IF;

						LET vStatusCuota = vStatus;
					END IF;

					UPDATE "informix".sd_amortiza_credito
					SET iva_status_ant = vCuotaRec,
					iva_pagado     = iva_pagado + vIvaVenc,
					iva_status     = vStatusCuota,
					iva_fecha_pago = g_fecha
					WHERE empresa = g_empresa
					AND num_credito = g_NumCredito
					AND fecha_cuota = vFechaCuota;


					-- Cobra Intereses
					IF (g_Remanente >= vIntVenc) THEN
						LET g_Remanente = g_Remanente - vIntVenc;
						
						IF (vStatusCuota = '7') THEN
							LET vIntCob7 = vIntCob7 + vIntVenc;
						ELSE
							LET vIntCob2 = vIntCob2 + vIntVenc;
						END IF;
						
						LET vCuotaRec = vStatusCuota;
						LET vStatusCuota = '5';
					ELSE
						LET vIntVenc = g_Remanente;
						LET g_Remanente = 0;
						
						IF (vStatusCuota = '7') THEN
							LET vIntCob7 = vIntCob7 + vIntVenc;
						ELSE
							LET vIntCob2 = vIntCob2 + vIntVenc;
						END IF;

						LET vStatusCuota = vStatus;

					END IF;

					UPDATE "informix".sd_amortiza_credito
					SET interes_status_ant = vCuotaRec,
					interes_pagado     = interes_pagado + vIntVenc,
					interes_status     = vStatusCuota,
					interes_fecha_pago = g_fecha
					WHERE empresa = g_empresa
					AND num_credito = g_NumCredito
					AND fecha_cuota = vFechaCuota;

				END IF;
				IF (g_Remanente = 0) THEN
					EXIT FOREACH;
				END IF;
			END FOREACH;

			-- *****************************
			-- *         TARJETA           *
			-- *****************************
			IF (g_ManejaLinea <> 'S') THEN

				UPDATE "informix".sd_maesdos
				SET sdo_exig_int = sdo_exig_int - vIntCob7 - vIntCob2,
				mto_venc_int = mto_venc_int - vIntCob7,
				mto_venc_tra_int = mto_venc_tra_int - vIntCob2
				WHERE empresa = g_Empresa
				AND num_credito = g_NumCredito;

			ELSE
				UPDATE "informix".sd_maesdos
				SET int_tra_no_exig = int_tra_no_exig - vIntCob2
				WHERE empresa = g_Empresa
				AND num_credito = g_NumCredito;

			END IF

			IF (vIntCob7 > 0) AND g_Transacc NOT IN ('7795','7796') THEN
				--LET vReferencia = 3;   --Interes vencido no traspasado
				LET vReferencia = 923;   --Interes vencido E1 --AEH
				
				IF g_Transacc = '9854' THEN
					IF vReferencia = 923 THEN
						LET vReferencia = 132;
					ELIF vReferencia = 925 THEN
						LET vReferencia = 133;
					ELIF vReferencia = 926 THEN
						LET vReferencia = 134;
					END IF;
				END IF;
				
				IF g_Transacc = '4356' THEN
					IF vReferencia = 923 THEN
						LET vReferencia = 126;
					ELIF vReferencia = 925 THEN
						LET vReferencia = 127;
					ELIF vReferencia = 926 THEN
						LET vReferencia = 128;
					END IF;
				END IF;
				
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIntCob7, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;

			IF (vIntCob2 > 0) AND g_Transacc NOT IN ('7795','7796') THEN
				IF g_StCred = 'E1' THEN
                    LET vReferencia = 923;   --Interes vencido E1 --AEH
                ELIF g_StCred = 'E2' THEN
                    --LET vReferencia = 5;   -- Interes Vencido Traspasado
					LET vReferencia = 925;   --Interes vencido E2 --AEH
                ELIF g_StCred = 'E3' THEN
                    LET vReferencia = 926; --Interes vencido E3 --AEH
                END IF;

				IF g_Transacc = '9854' THEN
					IF vReferencia = 923 THEN
						LET vReferencia = 132;
					ELIF vReferencia = 925 THEN
						LET vReferencia = 133;
					ELIF vReferencia = 926 THEN
						LET vReferencia = 134;
					END IF;
				END IF;
				
				IF g_Transacc = '4356' THEN
					IF vReferencia = 923 THEN
						LET vReferencia = 126;
					ELIF vReferencia = 925 THEN
						LET vReferencia = 127;
					ELIF vReferencia = 926 THEN
						LET vReferencia = 128;
					END IF;
				END IF;
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIntCob2, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;
		   
			LET g_IntVencCob = g_IntVencCob + (vIntCob7 + vIntCob2);

			IF (g_IntVencCob > 0) AND g_Transacc IN ('7795','7796') THEN
				-- 21062018 AAME RQM 06590 y RQM 06 591 Se contemplan los productos oro y Platino, se agrega TDC GC
				IF g_NumProducto IN ("6001","7000","8100","8500") THEN
                    IF g_StCred = 'E1' THEN
                    	LET vReferencia = 923;   --Interes vencido E1 --AEH
                	ELIF g_StCred = 'E2' THEN
                        --LET vReferencia = 5;   -- Interes Vencido Traspasado
						LET vReferencia = 925;   --Interes vencido E2 --AEH
                    ELIF g_StCred = 'E3' THEN
                        LET vReferencia = 926;  --Interes vencido E3 --AEH
                    END IF;		 
				END IF;
				 
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, g_IntVencCob, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;
		   
			IF (vIvaCob7 > 0) AND g_Transacc NOT IN ('7795','7796') THEN
				LET vReferencia = 6641;   --Iva vencido no traspasado
				--LET vReferencia = 6651;   -- Iva E1 --AEH
				
				IF g_Transacc = '9854' AND g_StCred = 'E1'  THEN --IVA INT. E1 CGO CUENTA ATM
			        LET vReferencia = 135;
			    ELIF g_Transacc = '9854' AND g_StCred = 'E2' THEN  --IVA INT. E2 CGO CUENTA ATM
			        LET vReferencia = 136;
			    ELIF g_Transacc = '9854' AND g_StCred = 'E3' THEN  --IVA INT. E3 CGO CUENTA ATM
			        LET vReferencia = 137;
			    ELIF g_Transacc = '4356' AND g_StCred = 'E1' THEN  --IVA INT. E1 EFECTIVO ATM
			        LET vReferencia = 129;
			    ELIF  g_Transacc = '4356' AND g_StCred = 'E2' THEN  --IVA INT. E2 EFECTIVO ATM
			        LET vReferencia = 130;
			    ELIF  g_Transacc = '4356' AND g_StCred = 'E3' THEN  --IVA INT. E3 EFECTIVO ATM
			        LET vReferencia = 131;
			    ELSE
				   IF g_StCred = 'E1' THEN
                     LET vReferencia = 6651;   --IVA E1 --AEH
                   ELIF g_StCred = 'E2' THEN
                     --LET vReferencia = 6640;   -- Iva Vencido Traspasado
					 LET vReferencia = 6650;   -- Iva E2 --AEH 
                   ELIF g_StCred = 'E3' THEN
                     LET vReferencia = 6652;   -- IVA VENCIDO E3 --AEH
                   END IF;
			    END IF;
				
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIvaCob7, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;
		   
			IF (vIvaCob2 > 0) AND g_Transacc NOT IN ('7795','7796') THEN
			
               IF g_Transacc = '9854' AND g_StCred = 'E1'  THEN --IVA INT. E1 CGO CUENTA ATM
			        LET vReferencia = 135;
			   ELIF g_Transacc = '9854' AND g_StCred = 'E2' THEN  --IVA INT. E2 CGO CUENTA ATM
			        LET vReferencia = 136;
			   ELIF g_Transacc = '9854' AND g_StCred = 'E3' THEN  --IVA INT. E3 CGO CUENTA ATM
			        LET vReferencia = 137;
			   ELIF g_Transacc = '4356' AND g_StCred = 'E1' THEN  --IVA INT. E1 EFECTIVO ATM
			        LET vReferencia = 129;
			   ELIF  g_Transacc = '4356' AND g_StCred = 'E2' THEN  --IVA INT. E2 EFECTIVO ATM
			        LET vReferencia = 130;
			   ELIF  g_Transacc = '4356' AND g_StCred = 'E3' THEN  --IVA INT. E3 EFECTIVO ATM
			        LET vReferencia = 131;
			   ELSE
				 IF g_StCred = 'E1' THEN
                    LET vReferencia = 6651;   --IVA E1 --AEH
                 ELIF g_StCred = 'E2' THEN
                    --LET vReferencia = 6640;   -- Iva Vencido Traspasado
					LET vReferencia = 6650;   -- Iva E2 --AEH 
                 ELIF g_StCred = 'E3' THEN
                    LET vReferencia = 6652;   -- IVA VENCIDO E3 --AEH
                 END IF;
			   END IF;
			   
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIvaCob2, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;

		    LET dIvaIntVencCob =  dIvaIntVencCob + (vIvaCob7 + vIvaCob2);
		   
			IF (dIvaIntVencCob > 0) AND g_Transacc IN ('7795','7796') THEN
			-- 21062018 AAME RQM 06590 y RQM 06 591 Se contemplan los productos oro y Platino, se agrega TDC GC
				IF g_NumProducto IN ("6001","7000","8100","8500") THEN
				 
					LET vReferencia = 6;

				END IF;
				 
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, dIvaIntVencCob, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;
		END IF;

	END IF;

	RETURN CodRet;
END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de intereses vencidos, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'VERSION:1.00.00.003',
'BD    : BDICRED',
'MODIFICACION: Se agragan transacciones 7795 y 7796 (condonacion y condonacion por fallecimiento),',
' 			   se implementan reglas de informix ',
'AUTOR : Mireya Gpe. Reyes Vargs',
'FECHA : 03-01-2014',
'VERSION :20140103.1557',
'FOLIO: 1395 - Condonacion de intereses vencidos y moratorios.',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_enmascarado_tarjeta(pCadena CHAR(16))
RETURNING CHAR(05)       AS Codigo_Retorno,
          CHAR(16)       AS Cadena_Final;
	
--*******************************************************************************************************
-- Realizo   : 
-- Proyecto  : 
-- Actividad : 
-- Fecha     : 

--Autor: 
--Fecha: 05/05/2022
--ModificaciÃÂ³n: 
--*******************************************************************************************************

DEFINE cCodRet         	CHAR(6);
DEFINE cErrorInfo      	CHAR(80);
DEFINE cErrorInfoR     	CHAR(80);
DEFINE iSqlerr         	INTEGER;
DEFINE sIsamErr        	SMALLINT;
DEFINE iRegistros      	INTEGER;
DEFINE cCadena 			CHAR(16);
DEFINE sLongitud 		SMALLINT;
DEFINE dContador 		SMALLINT;
DEFINE cCadenaFinal		CHAR(16);

LET cCodRet         = '000000';
LET cErrorInfo      = "";
--LET cErrorInfoR     = "OPERACION EXITOSA";
LET iSqlerr         = 0;
LET iRegistros      = 0;
LET cCadenaFinal	= '';


BEGIN

ON EXCEPTION  SET iSqlerr, sIsamErr, cErrorInfo
	IF iSqlerr <> 0  THEN
		LET  cCodRet  = iSqlerr;
--		LET cErrorInfoR = cErrorInfo;
     RETURN cCodRet,cCadenaFinal;
	END IF;
END  EXCEPTION

--set debug file to "sp_enmascarado.out";
--trace on;

IF NVL(TRIM(pCadena),'') = '' THEN
	LET cCodRet     = '00001';	-- 'NO SE ESPECIFICA LA CADENA'
	RETURN cCodRet,cCadenaFinal;
END IF;

LET cCadena = TRIM(pCadena);
LET sLongitud = length(cCadena);
LET dContador = 1;

IF sLongitud <= 3 THEN
	LET cCadena = '';
	WHILE dContador <= sLongitud
		LET cCadena = TRIM(cCadena) || '*';
		LET dContador = dContador + 1;
	END WHILE;
	LET cCadenaFinal = TRIM(cCadena);
ELSE
	WHILE dContador < sLongitud
		IF dContador = 1 THEN
			LET cCadena = substr(TRIM(cCadena),dContador,4);
		ELSE
			LET cCadena = TRIM(cCadena) || '*';
		END IF;
		LET dContador = dContador + 1;
	END WHILE;
	--LET cCadenaFinal = TRIM(cCadena);-- || substr(TRIM(pCadena),-4);
	LET cCadenaFinal = substr(TRIM(cCadena),1,12) || substr(TRIM(pCadena),-4);
END IF;

RETURN cCodRet,TRIM(cCadenaFinal);

END;
END PROCEDURE;