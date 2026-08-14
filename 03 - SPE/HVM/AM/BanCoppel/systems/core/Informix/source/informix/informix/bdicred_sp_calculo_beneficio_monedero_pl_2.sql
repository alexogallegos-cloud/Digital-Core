CREATE PROCEDURE "informix".sp_calculo_beneficio_monedero_pl_2() 
RETURNING	 CHAR(5); --Codigo Retorno

DEFINE cCodret				    CHAR(5);			 
DEFINE iSqlerr				    INTEGER;
DEFINE iExiste				    INTEGER;

DEFINE vFechaHoy        	DATE;
DEFINE vFechaConta        	DATE;
DEFINE vPeriodo				CHAR(10);
DEFINE vPeriodo_acum		CHAR(10);
DEFINE vTipo			 	CHAR(40);
DEFINE vTipo_acum		 	CHAR(40);
DEFINE vClienteBanco		CHAR(20);
DEFINE vNumCredito			CHAR(20);
DEFINE vNumProducto			CHAR(4);
DEFINE vNumProducto_acum	CHAR(4);
DEFINE vMontoDiario		 	DECIMAL(18,2);
DEFINE vPorcentajeDineroElectronico	DECIMAL(18,2);
DEFINE vPorcentaje		 	DECIMAL(18,2);
DEFINE vDineroEOriginal		DECIMAL(18,2);
DEFINE vDineroEOriginal_acum	DECIMAL(18,2);
DEFINE vImporteTransaccion 	DECIMAL(18,2);
DEFINE vFolioBeneficio		CHAR(50);
DEFINE vFolioBeneficio_acum	CHAR(50);
DEFINE vEstatus				CHAR(2);
DEFINE vEstatus_acum		CHAR(2);
DEFINE vDiaCorte			SMALLINT;
DEFINE vDiaCorteMenos1		CHAR(2);
DEFINE vFechaCorteMenosTresMeses	DATE;
DEFINE vFechaCorte			DATE;
DEFINE vFechaCompra			DATETIME YEAR TO FRACTION(5);
DEFINE vMontoMinimo		 	DECIMAL(18,2);
DEFINE vPorcentajeCumple	DECIMAL(18,2);
DEFINE vFechaCumple         DATE;
DEFINE vMesCumple			SMALLINT;
DEFINE vMesCompra			DATE;
DEFINE vMontoAcumulado 		DECIMAL(18,2);
DEFINE vAcumula				CHAR(1);
DEFINE vNuevoMontoDiario	DECIMAL(18,2);
DEFINE vMontoCompleto		DECIMAL(18,2);
DEFINE vOrigen 				CHAR(50);
DEFINE vMontoCompletoOrigen DECIMAL(18,2);
DEFINE vMoneda				CHAR(4);
DEFINE vMoneda_acum			CHAR(4);
DEFINE vReferencia23		CHAR(23);
DEFINE vReferencia23_acum	CHAR(23);
DEFINE aOrigen 				CHAR(50);
DEFINE vMontoDiarioOriginal	DECIMAL(18,2);
DEFINE vMontoDiarioOriginal_acum 	DECIMAL(18,2);
DEFINE pNombreComercio		CHAR(80);
DEFINE pNombreComercio_acum	CHAR(80);
DEFINE vFecha_generacion	DATETIME YEAR TO FRACTION(5);
DEFINE vFecha_generacion_acum	DATETIME YEAR TO FRACTION(5);
DEFINE vTipoVigencia		CHAR(40);
DEFINE asucursal			CHAR(4);
DEFINE atipomov				CHAR(40);
DEFINE vFechaCompra_acum    DATETIME YEAR TO FRACTION(5);


DEFINE pEmpresa				    CHAR(3);
DEFINE pUsuario					CHAR(40);
DEFINE pTransacc				CHAR(40);
DEFINE pTpPago					SMALLINT;
DEFINE pDivisa					CHAR(3);

DEFINE gCodigoRef				integer;
DEFINE gCodigoFun				VARCHAR(3);
DEFINE pMensaje					CHAR(80);
DEFINE vStatus_rw               CHAR(40);
DEFINE vCashback_amount         DECIMAL(16,2);



--INICIALIZANDO VARIABLES -------------
LET vFechaHoy        	=date(1);
LET vFechaConta        	=date(1);
LET vPeriodo			="";
LET vTipo			 	="";
LET vClienteBanco		="";
LET vNumCredito			="";
LET vNumProducto		="";
LET vMontoDiario		=0;
LET vPorcentajeDineroElectronico	=0;
LET vPorcentaje		 	=0;
LET vDineroEOriginal	=0;
LET vImporteTransaccion =0;
LET vFolioBeneficio		="";
LET vEstatus			="";
LET vDiaCorte			=0;
LET vDiaCorteMenos1		="";
LET vFechaCorte			="";
LET vFechaCompra		="";
LET vFechaCumple        =date(1);
LET vMesCumple     		=0;
LET vMesCompra			="";
LET vPorcentajeCumple	=0;
LET vMontoMinimo		=0;
LET vMontoAcumulado		=0;
LET vNuevoMontoDiario	=0;
LET vMontoCompleto		=0;
LET vOrigen				="";
LET vMontoCompletoOrigen =0;
LET vMoneda				="";
LET vReferencia23		="";
LET aOrigen				="";
LET vMontoDiarioOriginal =0;
LET pNombreComercio		= "";
LET vAcumula            ="0";


LET  vPeriodo_acum		= "";
LET  vTipo_acum		 	= "";
LET  vNumProducto_acum	= "";
LET  vDineroEOriginal_acum	=0;
LET  vFolioBeneficio_acum	= "";
LET  vEstatus_acum		= "";
LET  vMoneda_acum			= "";
LET  vReferencia23_acum	= "";
LET  vMontoDiarioOriginal_acum 	=0;
LET  pNombreComercio_acum	= "";
LET  vFecha_generacion_acum  = "";
LET vFechaCompra_acum  		 = "";		

---------------------------------------
LET cCodret    			= "00000";
LET iSqlerr    			= 0;
LET iExiste	   			= 0;
---------------------------------------

LET pEmpresa			= '001';
LET pUsuario			= 'informix';
LET pTransacc			= 0; 
LET pTpPago				= 1;
LET pDivisa				= '01';
LET gCodigoRef		= "";
LET gCodigoFun		= "";
LET pMensaje		= "";

LET vTipo = 'COMPRAS';
LET vEstatus = 'P';

LET vTipoVigencia	= "vigente";
LET aSucursal 		= "";

LET vStatus_rw      = '';
LET vCashback_amount = 0;




	--SET DEBUG FILE TO "/ifxsif01/DBA/IPCB/tdc/sp_calculo_beneficio_monedero_pl.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--consultar fecha actual
	SELECT fecha_ant as fechaHoy, fecha_hoy
	INTO vFechaHoy, vFechaConta
	FROM bdicred:sd_fechas
	WHERE empresa = '001';


FOREACH WITH HOLD

	SELECT a.num_credito,a.numcte, a.origen, a.moneda, a.referencia23, a.nombre_comercio,a.monto_diario, a.producto, a.periodo,a.fecha_compra, a.status_rw, a.cashback_amount
	INTO vNumCredito,vClienteBanco,vOrigen,vMoneda,vReferencia23,pNombreComercio,vMontoDiarioOriginal,vNumProducto,vPeriodo,vFechaCompra, vStatus_rw, vCashback_amount
	FROM bdicred: "informix".sd_compras_plan_lealtad a
	where (estatus_calculo::boolean = "f" or status_rw = 'confirmed')
		
		IF nvl(vStatus_rw,'') =  'confirmed' then
			LET vOrigen = "Reworth";
		END IF;
		
		LET vFolioBeneficio = TO_CHAR(vFechaHoy, 'PL' || '%e%m%Y%H%M%S '); 
		LET vFolioBeneficio = REPLACE(vFolioBeneficio, " ", "");
		
		--Lee sucursal del credito
		SELECT sucursal INTO aSucursal
		FROM bdicred:"informix".sd_Maecred
		WHERE num_credito = vNumCredito;
		
		-----------------------------
		IF vOrigen = "Plan_Lealtad" THEN
			LET aOrigen 		= 'Plan_Lealtad';
			LET aTipoMov 		= 'ABONO_PUNTOS';
			LET pTransacc 		= '9815';
			LET gCodigoFun		= '151';
			LET gCodigoRef		= 141;
		ELIF vOrigen = "Reworth" THEN
			LET aOrigen 		= 'Reworth';
			LET aTipoMov 		= 'ABONO_PUNTOS';
			LET pTransacc 		= '9830';
			LET gCodigoFun		= '152';
			LET gCodigoRef		= 141;
		ELIF vOrigen = "Devolucion_Pl" THEN
			LET aOrigen 		= 'Plan_Lealtad';
			LET aTipoMov 		= 'CARGO_DEVOLUCION';
			LET pTransacc 		= '9822';
			LET gCodigoFun		= '151';
			LET gCodigoRef		= 140;
		ELIF vOrigen = "Devolucion_Ex" THEN
			LET aOrigen 		= 'Reworth';
			LET aTipoMov 		= 'CARGO_DEVOLUCION';
			LET pTransacc 		= '9999';
			LET gCodigoFun		= '152';
			LET gCodigoRef		= 140;
		ELIF vOrigen = "Aclaraciones_Pl" THEN
			LET aOrigen			= 'Plan_Lealtad';
			LET pTransacc 		= '9821';
			LET gCodigoFun		= '151';
			LET gCodigoRef		= 139;
		-----------------------------
		END IF;		
		
		
		--consultar la tabla productos permitidos 
		IF (vOrigen = "Plan_Lealtad") then
			SELECT porcentaje_beneficio, porcentaje_especial,monto_minimo
			INTO  vPorcentajeDineroElectronico, vPorcentajeCumple, vMontoMinimo
			FROM  bdicred:"informix".sd_productos_permitidos_plan_lealtad
			WHERE num_producto = vNumProducto;

			--Obtener mes de cumpleanios--------------
			SELECT fecha_nac
			INTO vFechaCumple
			FROM bdinteg:"informix".si_ctepf
			WHERE numcte = vClienteBanco;
			
			LET vMesCumple = MONTH(vFechaCumple) ;
			
			--Acumula monedero 
			
			SELECT NVL(monto_acumulado,0), NVL(acumula,"0")
			INTO vMontoAcumulado, vAcumula
			FROM bdicred: "informix".sd_compra_acumulada_plan_lealtad
			WHERE numcte = vClienteBanco
			AND num_credito = vNumCredito
			AND origen = vOrigen;
			
			IF vMontoAcumulado is null THEN 
				LET vMontoAcumulado = 0;
				LET vAcumula = "0";
			END IF;
			
			BEGIN WORK;
			
			IF (vMontoAcumulado + vMontoDiarioOriginal) >= vMontoMinimo THEN 
				LET vAcumula = "1";
				--FOREACH DE MOVIMIENTOS POR ACUMULAR
				
				FOREACH WITH HOLD
				
					SELECT producto, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, moneda, referencia23, nombre_comercio,fecha_compra
					INTO vNumProducto_acum, vMontoDiarioOriginal_acum, vDineroEOriginal_acum, vFolioBeneficio_acum, vFecha_generacion_acum, vTipo_acum, vPeriodo_acum, vEstatus_acum, vMoneda_acum, vReferencia23_acum, pNombreComercio_acum,vFechaCompra_acum
					FROM sd_beneficios_calculados_por_acumular
					WHERE numcte = vClienteBanco
					AND num_credito = vNumCredito
					AND origen = vOrigen
					
					INSERT INTO bdicred:"informix".sd_beneficios_calculados_plan_lealtad(numcte, producto, num_credito, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, origen, moneda, referencia23, nombre_comercio)
					VALUES(vClienteBanco, vNumProducto_acum, vNumCredito, vMontoDiarioOriginal_acum, vDineroEOriginal_acum, vFolioBeneficio_acum, vFecha_generacion_acum, vTipo_acum, vPeriodo_acum, vEstatus_acum, vOrigen, vMoneda_acum, vReferencia23_acum, pNombreComercio_acum);
					
					DELETE bdicred:"informix".sd_beneficios_calculados_por_acumular
					WHERE numcte = vClienteBanco
					AND origen = vOrigen
					AND referencia23 = vReferencia23_acum
					AND num_credito = vNumCredito
					AND monto = vMontoDiarioOriginal_acum;
					
					UPDATE "informix".sd_monedero_plan_lealtad 
					SET saldo_total=saldo_total + vDineroEOriginal_acum, fecha_actualizacion=vFechaHoy 
					WHERE numcte = vClienteBanco
					and origen = aOrigen;
					
					IF dbinfo('sqlca.sqlerrd2') = 0 THEN
					
						INSERT INTO bdicred:"informix".sd_monedero_plan_lealtad(numcte, saldo_total, fecha_actualizacion, estatus, origen)
						VALUES(vClienteBanco, vDineroEOriginal_acum, vFechaHoy, 'A', aOrigen);
							
					END IF;
					
					EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa,vNumCredito,vNumProducto_acum,gCodigoRef,gCodigoFun,vFechaConta,vDineroEOriginal_acum,vFolioBeneficio,aSucursal,pDivisa,pTransacc)
					INTO cCodRet,pMensaje;
					----------------
					INSERT INTO bdicred:"informix".sd_vigencia_monedero_plan_lealtad(numcte,tipo, monto_abono, monto_abono_recuperado, fecha_registro, folio, estatus, origen, referencia23)
					VALUES(vClienteBanco, vTipoVigencia, vDineroEOriginal_acum, 0, vFechaCompra_acum, vFolioBeneficio, "f", aOrigen, vReferencia23_acum);	
				
					INSERT INTO bdicred:"informix".sd_movs_monedero_plan_lealtad(numcte, num_credito, tipo_producto, beneficio_calculado, monto, tipo_mov, fecha_mov, folio, origen, moneda, referencia23, nombre_comercio)
					VALUES(vClienteBanco, vNumCredito, vNumProducto_acum, vDineroEOriginal_acum, vMontoDiarioOriginal_acum, aTipoMov, vFechaCompra_acum, vFolioBeneficio, aOrigen, vMoneda_acum, vReferencia23_acum, pNombreComercio_acum);
				
				END FOREACH;
				
			END IF; 
				
			--Obtiene mes de compra --
			LET vMesCompra = MONTH(vFechaCompra);
			
			--Validar mes de cumpleanios
			IF vMesCompra = vMesCumple then
				LET vPorcentajeDineroElectronico = vPorcentajeCumple;
			END IF;
			
			--calculo de dinero
			LET vPorcentaje = vPorcentajeDineroElectronico / 100;
			LET vDineroEOriginal = vMontoDiarioOriginal * vPorcentaje;

			
			
			IF vAcumula = "1"
			THEN
			
				INSERT INTO bdicred:"informix".sd_beneficios_calculados_plan_lealtad(numcte, producto, num_credito, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, origen, moneda, referencia23, nombre_comercio)
				VALUES(vClienteBanco, vNumProducto, vNumCredito, vMontoDiarioOriginal, vDineroEOriginal, vFolioBeneficio, vFechaHoy, vTipo, vPeriodo, vEstatus, vOrigen, vMoneda, vReferencia23, pNombreComercio);
			
			ELSE 
				INSERT INTO bdicred:"informix".sd_beneficios_calculados_por_acumular(numcte, producto, num_credito, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, origen, moneda, referencia23, nombre_comercio,fecha_compra)
				VALUES(vClienteBanco, vNumProducto, vNumCredito, vMontoDiarioOriginal, vDineroEOriginal, vFolioBeneficio, vFechaHoy, vTipo, vPeriodo, vEstatus, vOrigen, vMoneda, vReferencia23, pNombreComercio,vFechaCompra);
			
			END IF;
			
			UPDATE bdicred: "informix".sd_compra_acumulada_plan_lealtad
			SET monto_acumulado= monto_acumulado + vMontoDiarioOriginal,
				acumula = vAcumula
			WHERE numcte = vClienteBanco
			AND num_credito = vNumCredito
			AND origen = vOrigen;
			
			
			IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			
				INSERT INTO bdicred:"informix".sd_compra_acumulada_plan_lealtad(numcte, producto, num_credito, monto_acumulado, origen, moneda,acumula)
				VALUES(vClienteBanco, vNumProducto, vNumCredito, vMontoDiarioOriginal,vOrigen,vMoneda,vAcumula);

			END IF;
				
			--Cambia el estatus de cliente
			UPDATE bdicred:"informix".sd_compras_plan_lealtad
			SET estatus_calculo="t" 
			WHERE numcte = vClienteBanco
			AND origen = vOrigen
			AND referencia23 = vReferencia23
			AND num_credito = vNumCredito;

			
			
			--CONDICION DE MONTO MINIMO

			IF vAcumula = "1"
				
			THEN
				UPDATE "informix".sd_monedero_plan_lealtad 
				SET saldo_total=saldo_total + vDineroEOriginal, fecha_actualizacion=vFechaHoy 
				WHERE numcte = vClienteBanco
				and origen = aOrigen;
				
				IF dbinfo('sqlca.sqlerrd2') = 0 THEN
				
					INSERT INTO bdicred:"informix".sd_monedero_plan_lealtad(numcte, saldo_total, fecha_actualizacion, estatus, origen)
					VALUES(vClienteBanco, vDineroEOriginal, vFechaHoy, 'A', aOrigen);
						
				END IF;
				
				EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa,vNumCredito,vNumProducto,gCodigoRef,gCodigoFun,vFechaConta,vDineroEOriginal,vFolioBeneficio,aSucursal,pDivisa,pTransacc)
				INTO cCodRet,pMensaje;
				----------------
			
				INSERT INTO bdicred:"informix".sd_vigencia_monedero_plan_lealtad(numcte,tipo, monto_abono, monto_abono_recuperado, fecha_registro, folio, estatus, origen, referencia23)
				VALUES(vClienteBanco, vTipoVigencia, vDineroEOriginal, 0, vFechaCompra, vFolioBeneficio, "f", aOrigen, vReferencia23);	
				
				
				INSERT INTO bdicred:"informix".sd_movs_monedero_plan_lealtad(numcte, num_credito, tipo_producto, beneficio_calculado, monto, tipo_mov, fecha_mov, folio, origen, moneda, referencia23, nombre_comercio)
				VALUES(vClienteBanco, vNumCredito, vNumProducto, vDineroEOriginal, vMontoDiarioOriginal, aTipoMov, vFechaCompra, vFolioBeneficio, aOrigen, vMoneda, vReferencia23, pNombreComercio);
			
			END IF;
			
			COMMIT WORK;
		ELSE
		
			LET vCashback_amount = nvl(vCashback_amount,0);
			
			IF nvl(vCashback_amount,0) <= 0 THEN
				LET vCashback_amount = 0;
			END IF;
		
			UPDATE "informix".sd_monedero_plan_lealtad 
			SET saldo_total=saldo_total + vCashback_amount, fecha_actualizacion=vFechaHoy 
			WHERE numcte = vClienteBanco
			and origen = aOrigen;
			
			IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			
				INSERT INTO bdicred:"informix".sd_monedero_plan_lealtad(numcte, saldo_total, fecha_actualizacion, estatus, origen)
				VALUES(vClienteBanco, vCashback_amount, vFechaHoy, 'A', aOrigen);
					
			END IF;
			
			EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa,vNumCredito,vNumProducto,gCodigoRef,gCodigoFun,vFechaConta,vCashback_amount,vFolioBeneficio,aSucursal,pDivisa,pTransacc)
			INTO cCodRet,pMensaje;
			----------------
		
			INSERT INTO bdicred:"informix".sd_vigencia_monedero_plan_lealtad(numcte,tipo, monto_abono, monto_abono_recuperado, fecha_registro, folio, estatus, origen, referencia23)
			VALUES(vClienteBanco, vTipoVigencia, vCashback_amount, 0, vFechaCompra, vFolioBeneficio, "f", aOrigen, vReferencia23);	
			
			
			INSERT INTO bdicred:"informix".sd_movs_monedero_plan_lealtad(numcte, num_credito, tipo_producto, beneficio_calculado, monto, tipo_mov, fecha_mov, folio, origen, moneda, referencia23, nombre_comercio)
			VALUES(vClienteBanco, vNumCredito, vNumProducto, vCashback_amount, vMontoDiarioOriginal, aTipoMov, vFechaCompra, vFolioBeneficio, aOrigen, vMoneda, vReferencia23, pNombreComercio);
			
			UPDATE bdicred:"informix".sd_compras_plan_lealtad
			SET status_rw="process" 
			WHERE numcte = vClienteBanco
			AND origen = 'Plan_Lealtad'
			AND referencia23 = vReferencia23
			AND num_credito = vNumCredito;
			
			
		END IF;
--Limpia variables

END FOREACH;

RETURN cCodret;
	
END
END procedure;