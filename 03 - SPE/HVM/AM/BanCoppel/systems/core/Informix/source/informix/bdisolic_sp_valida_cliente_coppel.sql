CREATE PROCEDURE "informix".sp_valida_cliente_coppel(opcion CHAR (1),cliente_coppel CHAR(20),RFC1 CHAR (13),puntualidad CHAR(3),porcentaje_efic FLOAT,limite_credito INT,meses_historia INT,saldo_total_ropa INT,saldo_total_muebles INT,saldo_total_prestamos INT,vencido_total_ropa INT,vencido_total_muebles INT,vencido_total_prestamos INT,abono_mensual_ropa INT,abono_mensual_muebles INT,abono_mensual_prestamos INT,situacion_especial CHAR(2),causa SMALLINT,linea_credito INT,fecha_ultima_compra CHAR(13),fecha_ultimo_pago CHAR(13),prestamo_autorizado CHAR(1),monto_autorizado CHAR(17),re_prestamo CHAR(17))

-- ***************************************************************************
-- *                         RETORNO DE EJECUCION                        *
-- ***************************************************************************		
RETURNING CHAR(6) 	AS CodRet,
          CHAR(13) 	AS fecha_ultimo_pago,
		  CHAR(1) 	AS prestamo_autorizado,
		  CHAR(17) 		AS monto_autorizado,
		  CHAR(17) 		AS re_prestamo;

		  
		  
-- ***************************************************************************
-- *                         DEFINICION DE VARIABLES                         *
-- ***************************************************************************
DEFINE cOpcion					CHAR(1);
DEFINE cEmpresa 				CHAR(3);
DEFINE iClienteCoppel   		CHAR(20);
DEFINE iCteCoppel   			INT;
DEFINE iRfc			   			INT;
DEFINE cRfc						CHAR(13); 
DEFINE cPuntualidad				CHAR(3);
DEFINE fPorcentajeEfic			FLOAT;
DEFINE ilimiteCredito			INT;
DEFINE iMesesHistoria 			INT;
DEFINE iSaldoTotalRopa			INT;
DEFINE iSaldoTotalMuebles 		INT;
DEFINE iSaldoTotalPrestamos 	INT;
DEFINE iVencidoTotalRopa		INT;
DEFINE iVencidoTotalMuebles		INT;
DEFINE iVencidoTotalPrestamos	INT;
DEFINE iAbonoMensualRopa		INT;
DEFINE iAbonoMensualMuebles		INT;
DEFINE iAbonoMensualPrestamos 	INT;
DEFINE cSituacionEspecial		CHAR(2);
DEFINE cCausa					SMALLINT;
DEFINE iLineaCredito			INT;
DEFINE cFechaUltimaCompra		CHAR(13);
DEFINE cFechaUltimoPago			CHAR(13);
DEFINE cPrestamoAutorizado		CHAR(1);
DEFINE iMontoAutorizado			CHAR(17);
DEFINE iRePrestamo				CHAR(17);
DEFINE dFecha					date;
DEFINE iSqlErr           		INT;
DEFINE cCodRet 					CHAR(6);

-- ***************************************************************************
-- *                     ASIGNACION DE VALORES A VARIABLES                   *
-- ***************************************************************************


LET cOpcion					= opcion;
LET cEmpresa 				= "001";
LET iClienteCoppel   		= cliente_coppel;
LET iCteCoppel   			= 0;
LET iRfc		   			= 0;
LET cRfc					= RFC1;
LET cPuntualidad			= puntualidad;
LET fPorcentajeEfic			= porcentaje_efic;
LET ilimiteCredito			= limite_credito;
LET iMesesHistoria 			= meses_historia;
LET iSaldoTotalRopa			= saldo_total_ropa;
LET iSaldoTotalMuebles 		= saldo_total_muebles;
LET iSaldoTotalPrestamos 	= saldo_total_prestamos;
LET iVencidoTotalRopa		= vencido_total_ropa;
LET iVencidoTotalMuebles	= vencido_total_muebles;
LET iVencidoTotalPrestamos	= vencido_total_prestamos;
LET iAbonoMensualRopa		= abono_mensual_ropa;
LET iAbonoMensualMuebles	= abono_mensual_muebles;
LET iAbonoMensualPrestamos 	= abono_mensual_prestamos;
LET cSituacionEspecial		= situacion_especial;
LET cCausa					= causa;
LET iLineaCredito			= linea_credito;
LET cFechaUltimaCompra		= fecha_ultima_compra;
LET cFechaUltimoPago		= fecha_ultimo_pago;
LET cPrestamoAutorizado		= prestamo_autorizado;
LET iMontoAutorizado		= monto_autorizado;
LET iRePrestamo				= re_prestamo;
LET dFecha					= TODAY;
LET iSqlErr         		= 0;
LET cCodRet 				= "000000";
							
BEGIN
	ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				--LET cCodRet = CAST(iSqlErr AS CHAR);
				RETURN  cCodRet, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo;
			END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--- Registrar cliente coppel
	--SET DEBUG FILE TO '/respaldosbd/Efrain/230/sp_valida_cliente_coppel.out';
	--TRACE ON;		

	SELECT 1 INTO iCteCoppel FROM bdisolic: "informix".ss_cliente_coppel_pp a WHERE a.cliente_coppel = iClienteCoppel AND a.empresa = cEmpresa;
	
	IF cOpcion = '1' THEN 
		IF cliente_coppel <> '' AND cliente_coppel <> '000000000' THEN
		
			IF NVL(iCteCoppel, 0) = 1  THEN
			
				DELETE FROM  bdisolic: "informix".ss_cliente_coppel_pp a WHERE a.cliente_coppel = iClienteCoppel AND a.empresa = cEmpresa;
				
			END IF;	
				INSERT INTO bdisolic: "informix".ss_cliente_coppel_pp (empresa,cliente_coppel,rfc,puntualidad,porcentaje_efic,limite_credito,meses_historia,saldo_total_ropa,saldo_total_muebles,saldo_total_prestamos,vencido_total_ropa,vencido_total_muebles,vencido_total_prestamos,abono_mensual_ropa,abono_mensual_muebles,abono_mensual_prestamos,situacion_especial,causa,linea_credito,fecha_ultima_compra,fecha_ultimo_pago,prestamo_autorizado,monto_autorizado,re_prestamo,fecha)
				VALUES (cEmpresa,iClienteCoppel,cRfc,cPuntualidad,fPorcentajeEfic,ilimiteCredito,iMesesHistoria,iSaldoTotalRopa,iSaldoTotalMuebles,iSaldoTotalPrestamos,iVencidoTotalRopa,iVencidoTotalMuebles,iVencidoTotalPrestamos,iAbonoMensualRopa,iAbonoMensualMuebles,iAbonoMensualPrestamos,cSituacionEspecial,cCausa,iLineaCredito,cFechaUltimaCompra,cFechaUltimoPago,cPrestamoAutorizado,iMontoAutorizado,iRePrestamo,dFecha);
												
		ELSE 
			LET cFechaUltimoPago = '1900-01-01';
			LET cPrestamoAutorizado = '0';
			LET iMontoAutorizado = '0';
			LET iRePrestamo = '0';
			LET cCodRet = '000000';
		END IF;
	ELSE
		IF cOpcion = '2' THEN 	
				IF cliente_coppel <> '' AND cliente_coppel <> '000000000' THEN
					IF  NVL(iCteCoppel, 0) = 1  THEN
						
						SELECT a.fecha_ultimo_pago,a.prestamo_autorizado,a.monto_autorizado,a.re_prestamo 
							INTO cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo
						FROM bdisolic: "informix".ss_cliente_coppel_pp a WHERE a.cliente_coppel = iClienteCoppel AND a.empresa = cEmpresa;			
						
					ELSE
						LET cFechaUltimoPago = '1900-01-01';
						LET cPrestamoAutorizado = '0';
						LET iMontoAutorizado = '0';
						LET iRePrestamo = '0';
						LET cCodRet = '000000';
					END IF;			
				ELSE
				
					LET cFechaUltimoPago = '1900-01-01';
					LET cPrestamoAutorizado = '0';
					LET iMontoAutorizado = '0';
					LET iRePrestamo = '0';
					LET cCodRet = '000000';
				END IF;
		ELIF cOpcion = '3' THEN 
				IF cRfc <> '' THEN
					SELECT 1 INTO iRfc FROM bdisolic: "informix".ss_cliente_coppel_pp a WHERE a.rfc = cRfc ;
					
					IF NVL(iRfc, 0) = 1 THEN
						
						SELECT a.fecha_ultimo_pago,a.prestamo_autorizado,a.monto_autorizado,a.re_prestamo 
							INTO cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo
						FROM bdisolic: "informix".ss_cliente_coppel_pp a WHERE a.rfc = cRfc ;			
						
					ELSE
						LET cFechaUltimoPago = '1900-01-01';
						LET cPrestamoAutorizado = '0';
						LET iMontoAutorizado = '0';
						LET iRePrestamo = '0';
						LET cCodRet = '000000';
					END IF;			
				ELSE
				
					LET cFechaUltimoPago = '1900-01-01';
					LET cPrestamoAutorizado = '0';
					LET iMontoAutorizado = '0';
					LET iRePrestamo = '0';
					LET cCodRet = '000000';
				END IF;
		ELSE
			
				LET cFechaUltimoPago = '1900-01-01';
				LET cPrestamoAutorizado = '0';
				LET iMontoAutorizado = '0';
				LET iRePrestamo = '0';
				LET cCodRet = '000000';	
		END IF;				
		
	END IF;
	
	
RETURN  cCodRet, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo;
 
END;
END PROCEDURE
