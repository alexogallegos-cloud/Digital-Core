CREATE PROCEDURE "informix".sp_sc_ctas_mesiversario()
	RETURNING CHAR(5) AS codigo_retorno,
		CHAR(80) AS mensaje_retorno;

	---DECLARACIONES   
	DEFINE cCodRet				CHAR(5); 
	DEFINE cMensajeRet			CHAR(80);	
	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo			CHAR(80);
	DEFINE iNoRegsProcesados 	INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	DEFINE dFechaFin			DATE;
	DEFINE cProducto			CHAR(4);
	DEFINE cCuenta				CHAR(20);
	DEFINE mAcumSdoPos			MONEY;
	DEFINE sDiasSdoPos			SMALLINT;
	DEFINE mSdoProm				MONEY;
	DEFINE dTasaBruta			DECIMAL(9,6);
	DEFINE mTotIntPag			MONEY;
	DEFINE mTotIsrCobrado		MONEY;
	
	DEFINE iIdRegistro INTEGER;
	DEFINE bEnTransaccion BOOLEAN;
	DEFINE iContador INTEGER;
	DEFINE iMaxCommit INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE dFechaAnt DATE;
	DEFINE mSaldoActual MONEY(14,2);
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'PROCESO EJECUTADO CORRECTAMENTE';
	LET iNoRegsProcesados   = 0;
	LET cEmpresa 			= '001';
	
	LET dFechaFin		= '';
	LET cProducto		= '';
	LET cCuenta			= '';
	LET mAcumSdoPos		= 0;
	LET sDiasSdoPos		= 0;
	LET mSdoProm		= 0;	
	LET dTasaBruta		= 0;
	LET mTotIntPag		= 0;
	LET mTotIsrCobrado	= 0;
	
	LET iIdRegistro = 0;
	LET bEnTransaccion = 'f';
	LET iContador = 0;
	LET iMaxCommit = 1000;
	LET iNoRegistros = 0;
	LET dFechaAnt = '';
	LET mSaldoActual = 0.00;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			
			IF bEnTransaccion = 't' THEN
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet, cMensajeRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bEnTransaccion = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sc_ctas_mesiversario.out';
		--TRACE ON;
		
		SELECT fecha_ant INTO dFechaAnt
		FROM bdicheq:"informix".sc_fechas WHERE empresa = cEmpresa;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
		LET bEnTransaccion = 't';	
		
		-- INVERSIÃN CRECIENTE 1100
		FOREACH WITH HOLD
			
			SELECT {+INDEX (bdicheq:"informix".sc_maehis maehis_ffin)} FIRST 5
			fechafin, producto, cuenta, acum_sdo_pos, dia_sdo_pos,CAST((acum_sdo_pos/dia_sdo_pos) AS MONEY) AS sdo_prom, tasabruta, totintpag, totisrcobrado, sdo_actual
			INTO dFechaFin, cProducto, cCuenta, mAcumSdoPos, sDiasSdoPos, mSdoProm, dTasaBruta, mTotIntPag, mTotIsrCobrado, mSaldoActual
			FROM bdicheq:"informix".sc_maehis mhis	
			WHERE fechafin = dFechaAnt AND producto = '1100'
			  AND dia_sdo_pos > 0
			ORDER BY sdo_actual DESC
			
			INSERT INTO bdicheq:"informix".sc_ctas_mesiversario(fecha_mov, producto, cuenta, sdo_acum, dias_periodo, sdo_prom, tasa_interes, monto_interes, isr_cobrado, sdo_actual) 
			VALUES(dFechaFin, cProducto, cCuenta, NVL(mAcumSdoPos,0), NVL(sDiasSdoPos,0), NVL(mSdoProm,0), NVL(dTasaBruta,0), NVL(mTotIntPag,0), NVL(mTotIsrCobrado,0), NVL(mSaldoActual,0));
			
			LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
		
		-- NÃMINA 1300
		FOREACH WITH HOLD
			
			SELECT {+INDEX (bdicheq:"informix".sc_maehis maehis_ffin)} FIRST 5
			fechafin, producto, cuenta, acum_sdo_pos, dia_sdo_pos,CAST((acum_sdo_pos/dia_sdo_pos) AS MONEY) AS sdo_prom, tasabruta, totintpag, totisrcobrado, sdo_actual
			INTO dFechaFin, cProducto, cCuenta, mAcumSdoPos, sDiasSdoPos, mSdoProm, dTasaBruta, mTotIntPag, mTotIsrCobrado, mSaldoActual
			FROM bdicheq:"informix".sc_maehis mhis	
			WHERE fechafin = dFechaAnt AND producto = '1300'
			  AND dia_sdo_pos > 0
			ORDER BY sdo_actual DESC
			
			INSERT INTO bdicheq:"informix".sc_ctas_mesiversario(fecha_mov, producto, cuenta, sdo_acum, dias_periodo, sdo_prom, tasa_interes, monto_interes, isr_cobrado, sdo_actual) 
			VALUES(dFechaFin, cProducto, cCuenta, NVL(mAcumSdoPos,0), NVL(sDiasSdoPos,0), NVL(mSdoProm,0), NVL(dTasaBruta,0), NVL(mTotIntPag,0), NVL(mTotIsrCobrado,0), NVL(mSaldoActual,0));
			
			LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
		
		-- NÃMINA GENERAL 1400
		FOREACH WITH HOLD
			
			SELECT {+INDEX (bdicheq:"informix".sc_maehis maehis_ffin)} FIRST 5
			fechafin, producto, cuenta, acum_sdo_pos, dia_sdo_pos,CAST((acum_sdo_pos/dia_sdo_pos) AS MONEY) AS sdo_prom, tasabruta, totintpag, totisrcobrado, sdo_actual
			INTO dFechaFin, cProducto, cCuenta, mAcumSdoPos, sDiasSdoPos, mSdoProm, dTasaBruta, mTotIntPag, mTotIsrCobrado, mSaldoActual
			FROM bdicheq:"informix".sc_maehis mhis	
			WHERE fechafin = dFechaAnt AND producto = '1400'
			  AND dia_sdo_pos > 0
			ORDER BY sdo_actual DESC
			
			INSERT INTO bdicheq:"informix".sc_ctas_mesiversario(fecha_mov, producto, cuenta, sdo_acum, dias_periodo, sdo_prom, tasa_interes, monto_interes, isr_cobrado, sdo_actual) 
			VALUES(dFechaFin, cProducto, cCuenta, NVL(mAcumSdoPos,0), NVL(sDiasSdoPos,0), NVL(mSdoProm,0), NVL(dTasaBruta,0), NVL(mTotIntPag,0), NVL(mTotIsrCobrado,0), NVL(mSaldoActual,0));
			
			LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
		
		-- CUENTA EFECTIVA NIÃO 1500
		FOREACH WITH HOLD
			
			SELECT {+INDEX (bdicheq:"informix".sc_maehis maehis_ffin)} FIRST 5
			fechafin, producto, cuenta, acum_sdo_pos, dia_sdo_pos,CAST((acum_sdo_pos/dia_sdo_pos) AS MONEY) AS sdo_prom, tasabruta, totintpag, totisrcobrado, sdo_actual
			INTO dFechaFin, cProducto, cCuenta, mAcumSdoPos, sDiasSdoPos, mSdoProm, dTasaBruta, mTotIntPag, mTotIsrCobrado, mSaldoActual
			FROM bdicheq:"informix".sc_maehis mhis	
			WHERE fechafin = dFechaAnt AND producto = '1500'
			  AND dia_sdo_pos > 0
			ORDER BY sdo_actual DESC
			
			INSERT INTO bdicheq:"informix".sc_ctas_mesiversario(fecha_mov, producto, cuenta, sdo_acum, dias_periodo, sdo_prom, tasa_interes, monto_interes, isr_cobrado, sdo_actual) 
			VALUES(dFechaFin, cProducto, cCuenta, NVL(mAcumSdoPos,0), NVL(sDiasSdoPos,0), NVL(mSdoProm,0), NVL(dTasaBruta,0), NVL(mTotIntPag,0), NVL(mTotIsrCobrado,0), NVL(mSaldoActual,0));
			
			LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
		
		-- BÃSICO NÃMINA 1700
		FOREACH WITH HOLD
			
			SELECT {+INDEX (bdicheq:"informix".sc_maehis maehis_ffin)} FIRST 5
			fechafin, producto, cuenta, acum_sdo_pos, dia_sdo_pos,CAST((acum_sdo_pos/dia_sdo_pos) AS MONEY) AS sdo_prom, tasabruta, totintpag, totisrcobrado, sdo_actual
			INTO dFechaFin, cProducto, cCuenta, mAcumSdoPos, sDiasSdoPos, mSdoProm, dTasaBruta, mTotIntPag, mTotIsrCobrado, mSaldoActual
			FROM bdicheq:"informix".sc_maehis mhis	
			WHERE fechafin = dFechaAnt AND producto = '1700'
			  AND dia_sdo_pos > 0
			ORDER BY sdo_actual DESC
			
			INSERT INTO bdicheq:"informix".sc_ctas_mesiversario(fecha_mov, producto, cuenta, sdo_acum, dias_periodo, sdo_prom, tasa_interes, monto_interes, isr_cobrado, sdo_actual) 
			VALUES(dFechaFin, cProducto, cCuenta, NVL(mAcumSdoPos,0), NVL(sDiasSdoPos,0), NVL(mSdoProm,0), NVL(dTasaBruta,0), NVL(mTotIntPag,0), NVL(mTotIsrCobrado,0), NVL(mSaldoActual,0));
			
			LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
		
		-- PLUS 1800
		FOREACH WITH HOLD
			
			SELECT {+INDEX (bdicheq:"informix".sc_maehis maehis_ffin)} FIRST 5
			fechafin, producto, cuenta, acum_sdo_pos, dia_sdo_pos,CAST((acum_sdo_pos/dia_sdo_pos) AS MONEY) AS sdo_prom, tasabruta, totintpag, totisrcobrado, sdo_actual
			INTO dFechaFin, cProducto, cCuenta, mAcumSdoPos, sDiasSdoPos, mSdoProm, dTasaBruta, mTotIntPag, mTotIsrCobrado, mSaldoActual
			FROM bdicheq:"informix".sc_maehis mhis	
			WHERE fechafin = dFechaAnt AND producto = '1800'
			  AND dia_sdo_pos > 0
			ORDER BY sdo_actual DESC
			
			INSERT INTO bdicheq:"informix".sc_ctas_mesiversario(fecha_mov, producto, cuenta, sdo_acum, dias_periodo, sdo_prom, tasa_interes, monto_interes, isr_cobrado, sdo_actual) 
			VALUES(dFechaFin, cProducto, cCuenta, NVL(mAcumSdoPos,0), NVL(sDiasSdoPos,0), NVL(mSdoProm,0), NVL(dTasaBruta,0), NVL(mTotIntPag,0), NVL(mTotIsrCobrado,0), NVL(mSaldoActual,0));
			
			LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
		
		-- EFECTIVA CHEQUES 1900
		FOREACH WITH HOLD
			
			SELECT {+INDEX (bdicheq:"informix".sc_maehis maehis_ffin)} FIRST 5
			fechafin, producto, cuenta, acum_sdo_pos, dia_sdo_pos,CAST((acum_sdo_pos/dia_sdo_pos) AS MONEY) AS sdo_prom, tasabruta, totintpag, totisrcobrado, sdo_actual
			INTO dFechaFin, cProducto, cCuenta, mAcumSdoPos, sDiasSdoPos, mSdoProm, dTasaBruta, mTotIntPag, mTotIsrCobrado, mSaldoActual
			FROM bdicheq:"informix".sc_maehis mhis	
			WHERE fechafin = dFechaAnt AND producto = '1900'
			  AND dia_sdo_pos > 0
			ORDER BY sdo_actual DESC
			
			INSERT INTO bdicheq:"informix".sc_ctas_mesiversario(fecha_mov, producto, cuenta, sdo_acum, dias_periodo, sdo_prom, tasa_interes, monto_interes, isr_cobrado, sdo_actual) 
			VALUES(dFechaFin, cProducto, cCuenta, NVL(mAcumSdoPos,0), NVL(sDiasSdoPos,0), NVL(mSdoProm,0), NVL(dTasaBruta,0), NVL(mTotIntPag,0), NVL(mTotIsrCobrado,0), NVL(mSaldoActual,0));
			
			LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
		
		-- CUENTAS POR EL PRODUCTO EFECTIVA DIGITAL 2000
		FOREACH WITH HOLD
			
			SELECT {+INDEX (bdicheq:"informix".sc_maehis maehis_ffin)} FIRST 20
			fechafin, producto, cuenta, acum_sdo_pos, dia_sdo_pos,CAST((acum_sdo_pos/dia_sdo_pos) AS MONEY) AS sdo_prom, tasabruta, totintpag, totisrcobrado, sdo_actual
			INTO dFechaFin, cProducto, cCuenta, mAcumSdoPos, sDiasSdoPos, mSdoProm, dTasaBruta, mTotIntPag, mTotIsrCobrado, mSaldoActual
			FROM bdicheq:"informix".sc_maehis mhis	
			WHERE fechafin = dFechaAnt AND producto = '2000'
			  AND dia_sdo_pos > 0
			ORDER BY sdo_actual DESC
			
			INSERT INTO bdicheq:"informix".sc_ctas_mesiversario(fecha_mov, producto, cuenta, sdo_acum, dias_periodo, sdo_prom, tasa_interes, monto_interes, isr_cobrado, sdo_actual) 
			VALUES(dFechaFin, cProducto, cCuenta, NVL(mAcumSdoPos,0), NVL(sDiasSdoPos,0), NVL(mSdoProm,0), NVL(dTasaBruta,0), NVL(mTotIntPag,0), NVL(mTotIsrCobrado,0), NVL(mSaldoActual,0));
			
			LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
		
		-- CUENTA EFECTIVA JÃVENES 2500
		FOREACH WITH HOLD
			
			SELECT {+INDEX (bdicheq:"informix".sc_maehis maehis_ffin)} FIRST 5
			fechafin, producto, cuenta, acum_sdo_pos, dia_sdo_pos,CAST((acum_sdo_pos/dia_sdo_pos) AS MONEY) AS sdo_prom, tasabruta, totintpag, totisrcobrado, sdo_actual
			INTO dFechaFin, cProducto, cCuenta, mAcumSdoPos, sDiasSdoPos, mSdoProm, dTasaBruta, mTotIntPag, mTotIsrCobrado, mSaldoActual
			FROM bdicheq:"informix".sc_maehis mhis	
			WHERE fechafin = dFechaAnt AND producto = '2500'
			  AND dia_sdo_pos > 0
			ORDER BY sdo_actual DESC
			
			INSERT INTO bdicheq:"informix".sc_ctas_mesiversario(fecha_mov, producto, cuenta, sdo_acum, dias_periodo, sdo_prom, tasa_interes, monto_interes, isr_cobrado, sdo_actual) 
			VALUES(dFechaFin, cProducto, cCuenta, NVL(mAcumSdoPos,0), NVL(sDiasSdoPos,0), NVL(mSdoProm,0), NVL(dTasaBruta,0), NVL(mTotIntPag,0), NVL(mTotIsrCobrado,0), NVL(mSaldoActual,0));
			
			LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
			
			LET iContador = iContador + 1;
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				BEGIN WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
		
		COMMIT WORK;
		IF bEnTransaccion = 't' THEN
			--BEGIN WORK;
			LET bEnTransaccion = 'f';
			LET iContador = 0;
		END IF;
		
		RETURN cCodRet, cMensajeRet;
		
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 05/09/2019',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Muestreo de Estados de Cuenta por Mesiversario', 
'DESCRIPCION: SPL para Control-M encargado de realizar inserciÃ³n de datos de tabla sc_maehis a tabla sc_ctas_mesiversario por fecha_ant de sc_fechas',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 31/03/2020',
'DESCRIPCION: Se modifica SPL para implementar COMMIT cada 1000 registros.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 30/04/2020',
'DESCRIPCION: Se modifica SPL para implementar directivas para solventar la recuperaciÃ³n de datos desde la tabla sc_maehis.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 08/06/2020',
'DESCRIPCION: Se modifica SPL para recuperar campo sdo_actual.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 07/08/2020',
'DESCRIPCION: Se modifica SPL para realizar separaciÃ³n de querys por producto.',
'BD: bdicheq';

CREATE PROCEDURE "informix".spsctransctaspropias_bex(pEmpresa char(3),
                                                pSucursal char(4),
                                                pUsuario char(8),
                                                pTransCargo char(4),
                                                pTransAbono char(4),
                                                pTransSuc char(4),
                                                pFolioSuc char(16),
                                                pNumCtaOrigen char(12),
                                                pNumCtaDestino char(18),
                                                pCheque integer,
                                                pMonto money(14,2),
                                                pMoneda char(2),
                                                pReferencia char(40),
												pReferenciaBe char(40),
                                                pNumTarjetaOrigen char(16),
                                                pNumTarjetaDestino char(16),
                                                pUsuAutoriza char(8),
                                                pMontoTotal money(14,2),
                                                pMontoFirme money(14,2),
                                                pMontoSBC money(14,2),
                                                pMontoRem money(14,2),
                                                pDiasRet smallint,
                                                pDocto integer)
        RETURNING char(5), char(5);

    -- SP de 23 registros
	--******************************************************

	DEFINE vcodret   char(5);
    DEFINE vcodretRev   char(5);
    DEFINE sql_err   integer;
    DEFINE vTrans    char(4);
	DEFINE vFechaHoy date;
	DEFINE vSdoDisp  money(14,2);
	DEFINE vMontoRet money(14,2);
	DEFINE vPasoCargo char(1);
	DEFINE vMensajeRet char(100);
	DEFINE vReferencia	char(40);
	DEFINE vTransCargo char(4);
	DEFINE vCliente1 CHAR(20);
	DEFINE vCuenta1 char(12);
	DEFINE vTransAbono CHAR(4);
    DEFINE cReferencia varchar(40);
    DEFINE aReferencia varchar(40);
	DEFINE vFechaProcesoOr date;
	DEFINE vFechaProcesoDe date;
	DEFINE vLogCta 			INTEGER;
	DEFINE vBin		varchar(8);
	DEFINE vStatusCtaOr  varchar(2);
	DEFINE vStatusCtaDe  varchar(2);
	  
	LET vReferencia ='' ;
   	LET vTransCargo ='';
	LET vCliente1 ='';
	LET vCuenta1 ='';
	LET vTransAbono='';
	LET vPasoCargo = '0';
	LET vcodret = '00000	';
	LET vcodretRev = '000';
	LET vMensajeRet = '';
	LET cReferencia = '';
	LET aReferencia = '';
	LET vBin = '';
	LET vLogCta=LENGTH(pNumCtaDestino);
	LET vStatusCtaOr = '';
	LET vStatusCtaDe = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
	
BEGIN
	ON EXCEPTION SET sql_err
		   IF sql_err <> 0 THEN
			IF vPasoCargo = '1' THEN
				EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
											pSucursal,
											pUsuario,
											pFolioSuc,
											'A') INTO vcodretRev;
			END IF;
			IF vcodretRev = '000' THEN
				LET vcodretRev = '001';
			END IF;

			LET vcodret = sql_err;
			RETURN vcodret, vcodretRev;
		   END IF;
	END EXCEPTION;


	IF vLogCta <> 11 THEN
		
		IF vLogCta = 18 THEN
			SELECT cuenta INTO pNumCtaDestino FROM bdicheq:sc_maechq WHERE cuenta_clabe = pNumCtaDestino;
		ELSE IF vLogCta = 16 THEN
			    --Se quita la validacion del bin debido a que ya se encuentran cancelada 
				--LET vBin= LEFT(pNumCtaDestino, 8);
				--IF vBin = '40081904' THEN 
					--LET vcodret = '00001';
				--ELSE

				  SELECT cuenta INTO pNumCtaDestino FROM  bdicheq:sc_tarjeta WHERE empresa='001' AND num_tarjeta = pNumCtaDestino AND status_tar = 'A';
			    -- END IF
		ELSE IF vLogCta = 10 THEN	
					SELECT cuenta INTO pNumCtaDestino FROM  bdicheq:sc_cuenta_telefono WHERE telefono = pNumCtaDestino;
		ELSE
					LET vcodret = '00001'; --Cuenta no valida
			  END IF;
			END IF;			
		END IF;
		
		IF pNumCtaDestino IS NULL THEN
			LET vcodret = '00002';   --Cuenta destino en nulo
		END IF;
	END IF;	
		

	---Asignacion y concatenacion de Cuenta del Cargo/Abono y la Referencia para el Estado de Cuenta
	LET cReferencia = TRIM(pNumCtaDestino) || ' ' || pReferencia; --cargo y la Referencia 
	LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferenciaBe; --abono y la Referencia del Beneficiario
	
	LET vTransCargo=pTransCargo;
	LET vTransAbono=pTransAbono;

		IF pTransCargo='0239' THEN
			select count(distinct num_cte), count(cuenta)
			into vCliente1, vCuenta1
			from bdicheq:"informix".sc_maechq
			where ( cuenta=pNumCtaOrigen  or cuenta=pNumCtaDestino)
			and empresa ='001';
			
			IF vCliente1 = 1 AND vCuenta1 = 2 THEN
				LET vTransCargo='0309';
				LET vTransAbono='0313';
				LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferencia;			
					
			END IF
		END IF
		
		--********************Valida los estatus y fechas*********************************************--
		IF vcodret = '00000' THEN
		
			SELECT fecha_proceso,status_cta INTO vFechaProcesoOr, vStatusCtaOr FROM bdicheq:sc_maechq WHERE cuenta = pNumCtaOrigen;
			SELECT fecha_proceso,status_cta INTO vFechaProcesoDe, vStatusCtaDe FROM bdicheq:sc_maechq WHERE cuenta = pNumCtaDestino;

				IF (vStatusCtaOr IN('2','6','7','8') OR vStatusCtaDe  IN('2','6','7','8')) THEN
					
					LET vcodret = '00003'; --Cuenta  con status invalido

				ELIF (vStatusCtaOr IN('1','3','5') AND vStatusCtaDe  IN('1','3','5')) THEN
					IF (vFechaProcesoOr <> vFechaProcesoDe)  THEN
					
						LET vcodret = '00004';  --Fecha proceso de cuenta destino diferente al dia
					
					END IF;	
				END IF;
				
		END IF
		
		
		IF  vcodret = '00000'  THEN
				EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
											pSucursal,
											pUsuario,
											vTransCargo, --Envia 0309 si es entre cuentas del mismo cliente sino envia el de entrada 0239.
											pTransSuc,
											pFolioSuc,
											pNumCtaOrigen,
											pCheque,
											pMonto,
											pMoneda,
											cReferencia,
											pNumTarjetaOrigen,
											pUsuAutoriza) INTO vcodret,
															   vTrans,
															   vFechaHoy,
															   vSdoDisp,
															   vMontoRet;

				IF vcodret <> '000' THEN
					RETURN vcodret, vcodretRev;
				ELSE
					LET vPasoCargo = '1';
				END IF;

				EXECUTE PROCEDURE bdicheq:"informix".abono_ref(pEmpresa,
											pSucursal,
											pUsuario,
											vTransAbono, --Envia 0313 si es entre cuentas del mismo cliente sino envia el de entrada 0205.
											pTransSuc,
											pFolioSuc,
											pNumCtaDestino,
											pDocto,
											pMontoTotal,
											pMontoFirme,
											pMontoSBC,
											pMontoRem,
											pDiasRet,
											pMoneda,
											aReferencia,
											pNumTarjetaDestino,
											pUsuAutoriza) INTO vcodret;

				IF vcodret <> '000' THEN
					EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
												pSucursal,
												pUsuario,
												pFolioSuc,
												'A') INTO vcodretRev;
					IF vcodretRev = '000' THEN
						LET vcodretRev = '001';
					END IF;
					RETURN vcodret, vcodretRev;
				END IF;
		ELSE
			RETURN vcodret, vcodretRev;
		END IF;

END;
RETURN vcodret, vcodretRev;
END PROCEDURE;