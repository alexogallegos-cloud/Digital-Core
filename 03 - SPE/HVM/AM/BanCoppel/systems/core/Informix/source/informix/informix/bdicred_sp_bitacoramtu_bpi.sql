CREATE PROCEDURE "informix".sp_bitacoramtu_bpi(pFechaMov DATETIME YEAR TO SECOND,
                                    pMtuActual   DECIMAL(14,2),
                                    pNumCteOrigen CHAR(20),
                                    pDescripcion  CHAR(60),
                                    pMonto        DECIMAL(14,2),
                                    pCodOperacion CHAR(2),
                                    pCanal     CHAR(4), 
                                    pFolioSuc  CHAR(16),
                                    pFolioBPI  CHAR(24))
RETURNING CHAR(5), CHAR(60);
    
    DEFINE vCodRet          CHAR(5);
    DEFINE vDescripcion     CHAR(60);
    DEFINE sql_err         SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
   
    LET vCodRet = '00000';

    BEGIN 
    
        ON EXCEPTION SET sql_err
            --SET DEBUG FILE TO "/tmp/sp_bitacoramtu_bpi.err";
            --TRACE ON;
            IF sql_err <> 0 THEN
                LET vcodret = '00002';
                LET vdescripcion = 'Ocurrio un error al registrar el movimiento';
                RETURN vcodret,vDescripcion;
            END IF;
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        --SET debug file to "/home/c90324512/sp_bitacoramtu_bpi.out";
        --TRACE on;
        
        IF pCanal <> '' OR pCanal IS NOT NULL THEN
        
            IF pCanal = '5003' THEN
       
                IF pFechaMov = '' or pFechaMov IS NULL OR 
                    pMtuActual = '' or pMtuActual IS NULL OR
                    pNumCteOrigen = '' or pNumCteOrigen IS NULL OR 
                    pDescripcion = '' or pDescripcion IS NULL OR
                    pMonto = '' or pMonto IS NULL OR 
                    pCodOperacion = '' or pCodOperacion IS NULL OR
                    pFolioBPI = '' or pFolioBPI IS NULL
                    THEN
        
                    LET vcodret = "00001";
                    LET vDescripcion = "Uno o mas parametros estan vacios";
                    RETURN vcodret, vDescripcion;
                END IF;
                
            ELSE 
            
                IF pFechaMov = '' or pFechaMov IS NULL OR 
                    pMtuActual = '' or pMtuActual IS NULL OR
                    pNumCteOrigen = '' or pNumCteOrigen IS NULL OR 
                    pDescripcion = '' or pDescripcion IS NULL OR
                    pMonto = '' or pMonto IS NULL OR 
                    pCodOperacion = '' or pCodOperacion IS NULL OR
                    pCanal = '' or pCanal IS NULL OR 
                    ( (pFolioSuc = '' or pFolioSuc IS NULL) AND (pFolioBPI = '' or pFolioBPI IS NULL) )
                    THEN
        
                    LET vcodret = "00001";
                    LET vDescripcion = "Uno o mas parametros estan vacios";
                    RETURN vcodret, vDescripcion;
                END IF;
            END IF;  
             
        ELSE
            LET vcodret = "00002";
            LET vDescripcion = "El canal esta vacio";
            RETURN vcodret, vDescripcion;
        END IF;
    
        INSERT INTO bdicheq:sc_bitacoramtu(fecha_oper,
			     mtuactual,
			     numcte,
			     descripcion,
			     monto,
			     codigooperacion,
			     canal,
			     folio_suc,
			     folio_bpi) VALUES (pFechaMov,
						  pMtuActual,
						  pNumCteOrigen,
						  pDescripcion,
						  pMonto,
						  pCodOperacion,
						  pCanal,
						  pFolioSuc,
						  pFolioBPI);
						  
        LET  vDescripcion = 'Se registro correctamente';                
        RETURN vCodRet, vDescripcion;
    
    END;

END PROCEDURE
DOCUMENT
'Modifico: BCPL',
'Fecha: 23/06/2025',
'BDD: bdicheq',
'Descripcion: Bitacora de movimientos sobre el MTU del cliente';

CREATE PROCEDURE "informix".sp_calculo_beneficio_monedero_pl() 
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
DEFINE vPorcentaje		 	DECIMAL(18,4);
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

DEFINE isam_err               	SMALLINT;
DEFINE sql_err               	SMALLINT;
DEFINE error_info             	CHAR(40);
DEFINE cmensaje                 CHAR(80);
DEFINE cNombreSp                CHAR(60);
DEFINE cMensajeError   			CHAR(100);
DEFINE cCountError			    INTEGER;
DEFINE cTabla					CHAR(60);

----VIGENCIA------------------------------------------------------
DEFINE v2NumCte					CHAR(20);
DEFINE v2SaldoTotal				DECIMAL(18,2);
DEFINE v2MontoAbono				DECIMAL(18,2);
DEFINE v2MontoAbonoRecuperado	DECIMAL(18,2);
DEFINE v2NumCredito				CHAR(20);
DEFINE v2Producto				CHAR(40);
DEFINE v2Folio					CHAR(40);
DEFINE v2TipoMov				CHAR(40);
DEFINE v2Origen					CHAR(40);
DEFINE v2BeneficioCalculado		DECIMAL(18,2);DEFINE v2NombreComercio			CHAR(80);
DEFINE v2Referencia23			CHAR(40);
DEFINE v2MontoPuntos			DECIMAL(16,2);
DEFINE v2FechaCaduco       		DATE;
DEFINE v2Moneda					CHAR(40);
DEFINE v2ClienteAux 			CHAR(20);
DEFINE v2Lote					INTEGER;
DEFINE v2FechaRegistro			DATETIME YEAR TO FRACTION(5);
DEFINE v2Sucursal				CHAR(4);
DEFINE v2Empresa				CHAR(3);
DEFINE v2Transacc				CHAR(40);
DEFINE v2CodigoRef				integer;
DEFINE v2CodigoFun				VARCHAR(3);
-----------------------------------------------------------------




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

LET cNombreSp        	= "sp_calculo_beneficio_monedero_pl";
LET cTabla        		= "";
LET cMensajeError  		= "";
LET isam_err            = 0;
LET cCountError         = 0;
LET error_info          = "";
LET sql_err    			= 0;

----VIGENCIA---------------------------------------------------------
LET v2TipoMov 			= 'CARGO_CADUCADOS';
LET v2NombreComercio 	= 'App BanCoppel';
LET v2NumCte					= "";
LET v2SaldoTotal				= "";
LET v2MontoAbono				= "";
LET v2MontoAbonoRecuperado	= "";
LET v2NumCredito 			= "";
LET v2Producto				= "";
LET v2Folio					= "";
LET v2Origen					= "";
LET v2BeneficioCalculado		= "";LET v2Referencia23			= "";
LET v2MontoPuntos			= 0;
LET v2FechaCaduco    		= "";
LET v2Moneda				='484';
LET v2ClienteAux			="";
LET v2Lote					= 0;
LET v2FechaRegistro			= "";
LET v2Sucursal				= "";
LET v2Empresa				= '001';
LET v2Transacc				= "";
LET v2CodigoFun				= "";
LET v2CodigoRef				= "";
--------------------------------------------------------------------


	--SET DEBUG FILE TO "/ifxsif01/DBA/IPCB/tdc/sp_calculo_beneficio_monedero_pl.out";
	--TRACE ON;

BEGIN
	
	ON EXCEPTION SET iSqlerr, isam_err, error_info
		IF iSqlerr = 243 THEN
			LET cCodret = iSqlerr;
			LET cMensajeError = sql_err||" * "||isam_err||" * "||error_info||" * "||cTabla;
            INSERT INTO "informix".sd_bitacora_errores_pl(nombreSp,cCodRet,mensaje_error,num_credito,numcte,fecha_mov)
            VALUES(cNombreSp,cCodret,cMensajeError,vNumCredito,vClienteBanco,vFechaCompra);
            LET cCountError = cCountError +1;
            IF cCountError = 2 THEN
            	RETURN cCodret;
            END IF;
	    ELIF iSqlerr <> 0 THEN
            LET cCodret = iSqlerr;
			LET cMensajeError = sql_err||" * "||isam_err||" * "||error_info||" * "||cTabla;
            INSERT INTO "informix".sd_bitacora_errores_pl(nombreSp,cCodRet,mensaje_error,num_credito,numcte,fecha_mov)
            VALUES(cNombreSp,cCodret,cMensajeError,vNumCredito,vClienteBanco,vFechaCompra);
            RETURN cCodret;
        END IF;
     END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--consultar fecha actual
	LET cTabla = 'sd_fechas';
	SELECT fecha_ant as fechaHoy, fecha_hoy
	INTO vFechaHoy, vFechaConta
	FROM bdicred:sd_fechas
	WHERE empresa = '001';

	LET cTabla = 'sd_compras_plan_lealtad';
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
		LET cTabla = 'sd_Maecred';
		SELECT sucursal INTO aSucursal
		FROM bdicred:"informix".sd_Maecred
		WHERE num_credito = vNumCredito;
		
		-----------------------------
		IF vStatus_rw is not null THEN
			LET aOrigen 		= 'Reworth';
			LET aTipoMov 		= 'ABONO_PUNTOS';
			LET pTransacc 		= '9830';
			LET gCodigoFun		= '152';
			LET gCodigoRef		= 141;
		ELIF vOrigen = "Plan_Lealtad" THEN
			LET aOrigen 		= 'Plan_Lealtad';
			LET aTipoMov 		= 'ABONO_PUNTOS';
			LET pTransacc 		= '9815';
			LET gCodigoFun		= '151';
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
			LET cTabla = 'sd_productos_permitidos_plan_lealtad';
			SELECT porcentaje_beneficio, porcentaje_especial,monto_minimo
			INTO  vPorcentajeDineroElectronico, vPorcentajeCumple, vMontoMinimo
			FROM  bdicred:"informix".sd_productos_permitidos_plan_lealtad
			WHERE num_producto = vNumProducto;

			--Obtener mes de cumpleanios--------------
			LET cTabla = 'si_ctepf';
			SELECT fecha_nac
			INTO vFechaCumple
			FROM bdinteg:"informix".si_ctepf
			WHERE numcte = vClienteBanco;
			
			LET vMesCumple = MONTH(vFechaCumple) ;
			
			--Acumula monedero 
			LET cTabla = 'sd_compra_acumulada_plan_lealtad';
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
				LET cTabla = 'sd_beneficios_calculados_por_acumular';
				FOREACH WITH HOLD
				
					SELECT producto, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, moneda, referencia23, nombre_comercio,fecha_compra
					INTO vNumProducto_acum, vMontoDiarioOriginal_acum, vDineroEOriginal_acum, vFolioBeneficio_acum, vFecha_generacion_acum, vTipo_acum, vPeriodo_acum, vEstatus_acum, vMoneda_acum, vReferencia23_acum, pNombreComercio_acum,vFechaCompra_acum
					FROM sd_beneficios_calculados_por_acumular
					WHERE numcte = vClienteBanco
					AND num_credito = vNumCredito
					AND origen = vOrigen
					
					LET cTabla = 'insert_sd_beneficios_calculados_plan_lealtad';
					INSERT INTO bdicred:"informix".sd_beneficios_calculados_plan_lealtad(numcte, producto, num_credito, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, origen, moneda, referencia23, nombre_comercio)
					VALUES(vClienteBanco, vNumProducto_acum, vNumCredito, vMontoDiarioOriginal_acum, vDineroEOriginal_acum, vFolioBeneficio_acum, vFecha_generacion_acum, vTipo_acum, vPeriodo_acum, vEstatus_acum, vOrigen, vMoneda_acum, vReferencia23_acum, pNombreComercio_acum);
					
					LET cTabla = 'delete_sd_beneficios_calculados_por_acumular';
					DELETE bdicred:"informix".sd_beneficios_calculados_por_acumular
					WHERE numcte = vClienteBanco
					AND origen = vOrigen
					AND referencia23 = vReferencia23_acum
					AND num_credito = vNumCredito
					AND monto = vMontoDiarioOriginal_acum;
					
					LET cTabla = 'update_sd_monedero_plan_lealtad';
					UPDATE "informix".sd_monedero_plan_lealtad 
					SET saldo_total=saldo_total + vDineroEOriginal_acum, fecha_actualizacion=vFechaHoy,
						de_obtenido = de_obtenido + vDineroEOriginal_acum
					WHERE numcte = vClienteBanco
					and origen = aOrigen;
					
					IF dbinfo('sqlca.sqlerrd2') = 0 then
					
						LET cTabla = 'insert_sd_monedero_plan_lealtad';
						INSERT INTO bdicred:"informix".sd_monedero_plan_lealtad(numcte, saldo_total, fecha_actualizacion, estatus, origen,de_obtenido)
						VALUES(vClienteBanco, vDineroEOriginal_acum, vFechaHoy, 'A', aOrigen, vDineroEOriginal_acum);
							
					END IF;
					
					LET cTabla = 'execute_genmov';
					EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa,vNumCredito,vNumProducto_acum,gCodigoRef,gCodigoFun,vFechaConta,vDineroEOriginal_acum,vFolioBeneficio,aSucursal,pDivisa,pTransacc)
					INTO cCodRet,pMensaje;
					----------------
					LET cTabla = 'insert_sd_vigencia_monedero_plan_lealtad';
					INSERT INTO bdicred:"informix".sd_vigencia_monedero_plan_lealtad(numcte,tipo, monto_abono, monto_abono_recuperado, fecha_registro, folio, estatus, origen, referencia23)
					VALUES(vClienteBanco, vTipoVigencia, vDineroEOriginal_acum, 0, vFechaCompra_acum, vFolioBeneficio, "f", aOrigen, vReferencia23_acum);	
					
					LET cTabla = 'insert_sd_movs_monedero_plan_lealtad';
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
				LET cTabla = 'insert_sd_beneficios_calculados_plan_lealtad';
				INSERT INTO bdicred:"informix".sd_beneficios_calculados_plan_lealtad(numcte, producto, num_credito, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, origen, moneda, referencia23, nombre_comercio)
				VALUES(vClienteBanco, vNumProducto, vNumCredito, vMontoDiarioOriginal, vDineroEOriginal, vFolioBeneficio, vFechaHoy, vTipo, vPeriodo, vEstatus, vOrigen, vMoneda, vReferencia23, pNombreComercio);
			
			ELSE 
				LET cTabla = 'insert_sd_beneficios_calculados_plan_lealtad';
				INSERT INTO bdicred:"informix".sd_beneficios_calculados_por_acumular(numcte, producto, num_credito, monto, beneficio_calculado, folio_beneficio, fecha_generacion, tipo, periodo, estatus, origen, moneda, referencia23, nombre_comercio,fecha_compra)
				VALUES(vClienteBanco, vNumProducto, vNumCredito, vMontoDiarioOriginal, vDineroEOriginal, vFolioBeneficio, vFechaHoy, vTipo, vPeriodo, vEstatus, vOrigen, vMoneda, vReferencia23, pNombreComercio,vFechaCompra);
			
			END IF;
			
			LET cTabla = 'update_sd_compra_acumulada_plan_lealtad';
			UPDATE bdicred: "informix".sd_compra_acumulada_plan_lealtad
			SET monto_acumulado= monto_acumulado + vMontoDiarioOriginal,
				acumula = vAcumula
			WHERE numcte = vClienteBanco
			AND num_credito = vNumCredito
			AND origen = vOrigen;
			
			
			IF dbinfo('sqlca.sqlerrd2') = 0 THEN
				
				LET cTabla = 'insert_sd_compra_acumulada_plan_lealtad';
				INSERT INTO bdicred:"informix".sd_compra_acumulada_plan_lealtad(numcte, producto, num_credito, monto_acumulado, origen, moneda,acumula)
				VALUES(vClienteBanco, vNumProducto, vNumCredito, vMontoDiarioOriginal,vOrigen,vMoneda,vAcumula);

			END IF;
				
			--Cambia el estatus de cliente
			LET cTabla = 'update_sd_compras_plan_lealtad';
			UPDATE bdicred:"informix".sd_compras_plan_lealtad
			SET estatus_calculo="t" 
			WHERE numcte = vClienteBanco
			AND origen = vOrigen
			AND referencia23 = vReferencia23
			AND num_credito = vNumCredito;

			
			
			--CONDICION DE MONTO MINIMO

			IF vAcumula = "1"
				
			THEN
				LET cTabla = 'update_sd_monedero_plan_lealtad';
				UPDATE "informix".sd_monedero_plan_lealtad 
				SET saldo_total=saldo_total + vDineroEOriginal, fecha_actualizacion=vFechaHoy,
					de_obtenido = de_obtenido + vDineroEOriginal
				WHERE numcte = vClienteBanco
				and origen = aOrigen;
				
				IF dbinfo('sqlca.sqlerrd2') = 0 THEN
					
					LET cTabla = 'insert_sd_monedero_plan_lealtad';
					INSERT INTO bdicred:"informix".sd_monedero_plan_lealtad(numcte, saldo_total, fecha_actualizacion, estatus, origen, de_obtenido)
					VALUES(vClienteBanco, vDineroEOriginal, vFechaHoy, 'A', aOrigen, vDineroEOriginal);
						
				END IF;
				
				LET cTabla = 'execute_genmov';
				EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa,vNumCredito,vNumProducto,gCodigoRef,gCodigoFun,vFechaConta,vDineroEOriginal,vFolioBeneficio,aSucursal,pDivisa,pTransacc)
				INTO cCodRet,pMensaje;
				----------------
				LET cTabla = 'insert_sd_vigencia_monedero_plan_lealtad';
				INSERT INTO bdicred:"informix".sd_vigencia_monedero_plan_lealtad(numcte,tipo, monto_abono, monto_abono_recuperado, fecha_registro, folio, estatus, origen, referencia23)
				VALUES(vClienteBanco, vTipoVigencia, vDineroEOriginal, 0, vFechaCompra, vFolioBeneficio, "f", aOrigen, vReferencia23);	
				
				LET cTabla = 'insert_sd_movs_monedero_plan_lealtad';
				INSERT INTO bdicred:"informix".sd_movs_monedero_plan_lealtad(numcte, num_credito, tipo_producto, beneficio_calculado, monto, tipo_mov, fecha_mov, folio, origen, moneda, referencia23, nombre_comercio)
				VALUES(vClienteBanco, vNumCredito, vNumProducto, vDineroEOriginal, vMontoDiarioOriginal, aTipoMov, vFechaCompra, vFolioBeneficio, aOrigen, vMoneda, vReferencia23, pNombreComercio);
			
			END IF;
			
			COMMIT WORK;
		ELSE
		
			LET vCashback_amount = nvl(vCashback_amount,0);
			
			IF nvl(vCashback_amount,0) <= 0 THEN
				LET vCashback_amount = 0;
			END IF;
		
			LET cTabla = 'update_sd_monedero_plan_lealtad';
			UPDATE "informix".sd_monedero_plan_lealtad 
			SET saldo_total=saldo_total + vCashback_amount, fecha_actualizacion=vFechaHoy,
				de_obtenido = de_obtenido + vDineroEOriginal_acum
			WHERE numcte = vClienteBanco
			and origen = aOrigen;
			
			IF dbinfo('sqlca.sqlerrd2') = 0 THEN
				
				LET cTabla = 'insert_sd_monedero_plan_lealtad';
				INSERT INTO bdicred:"informix".sd_monedero_plan_lealtad(numcte, saldo_total, fecha_actualizacion, estatus, origen, de_obtenido)
				VALUES(vClienteBanco, vCashback_amount, vFechaHoy, 'A', aOrigen, vCashback_amount);
					
			END IF;
			
			LET cTabla = 'execute_genmov';
			EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa,vNumCredito,vNumProducto,gCodigoRef,gCodigoFun,vFechaConta,vCashback_amount,vFolioBeneficio,aSucursal,pDivisa,pTransacc)
			INTO cCodRet,pMensaje;
			----------------
			
			LET cTabla = 'insert_sd_vigencia_monedero_plan_lealtad';
			INSERT INTO bdicred:"informix".sd_vigencia_monedero_plan_lealtad(numcte,tipo, monto_abono, monto_abono_recuperado, fecha_registro, folio, estatus, origen, referencia23)
			VALUES(vClienteBanco, vTipoVigencia, vCashback_amount, 0, vFechaCompra, vFolioBeneficio, "f", aOrigen, vReferencia23);	
			
			LET cTabla = 'insert_sd_movs_monedero_plan_lealtad';
			INSERT INTO bdicred:"informix".sd_movs_monedero_plan_lealtad(numcte, num_credito, tipo_producto, beneficio_calculado, monto, tipo_mov, fecha_mov, folio, origen, moneda, referencia23, nombre_comercio)
			VALUES(vClienteBanco, vNumCredito, vNumProducto, vCashback_amount, vMontoDiarioOriginal, aTipoMov, vFechaCompra, vFolioBeneficio, aOrigen, vMoneda, vReferencia23, pNombreComercio);
			
			LET cTabla = 'update_sd_compras_plan_lealtad';
			UPDATE bdicred:"informix".sd_compras_plan_lealtad
			SET status_rw="process" 
			WHERE numcte = vClienteBanco
			AND origen = 'Plan_Lealtad'
			AND referencia23 = vReferencia23
			AND num_credito = vNumCredito;
			
			
		END IF;
--Limpia variables

END FOREACH;

----------VIGENCIA-----------------------------------------------------------------------------------------
	let v2FechaCaduco = vFechaHoy- 1 units year;
	
	let v2ClienteAux = "";
	
	SELECT valor
	INTO v2Lote
	FROM bdicred:sd_param
	where cod_param = '159';

FOREACH WITH HOLD

	SELECT FIRST v2Lote a.numcte,SUM(a.monto_abono),SUM(a.monto_abono_recuperado),a.origen,b.producto,b.num_credito
	INTO v2NumCte,v2MontoAbono,v2MontoAbonoRecuperado,v2Origen,v2Producto,v2NumCredito
	FROM bdicred:"informix".sd_vigencia_monedero_plan_lealtad a
	LEFT JOIN bdicred:"informix".sd_compras_plan_lealtad b 
		ON a.numcte = b.numcte
		AND a.referencia23 = b.referencia23
	WHERE a.estatus = 'f'
		AND a.fecha_insert < v2FechaCaduco
	GROUP BY a.numcte,b.num_credito,b.producto,a.origen
	ORDER BY a.numcte,b.num_credito,b.producto,a.origen
	
	IF v2NumCredito is null or v2Producto is null THEN
		LET v2NumCredito 			= "";
		LET v2Producto				= "";
	END IF;
	-------------------------------------------------------	
	LET v2MontoPuntos = v2MontoAbono - v2MontoAbonoRecuperado;
	------------------------------------------------------------	
	BEGIN WORK;

	UPDATE bdicred:"informix".sd_monedero_plan_lealtad 
	SET saldo_total = saldo_total - v2MontoPuntos, --SALDO NEGATIVO
	    de_cancelado = de_cancelado + v2MontoPuntos,
	--SET saldo_total = saldo_total - (case WHEN saldo_total < v2MontoPuntos then saldo_total ELSE v2MontoPuntos END), -- SALDO EN 0
	fecha_actualizacion = SYSDATE
	WHERE numcte = v2NumCte
	AND origen = v2Origen;

	let v2Referencia23 =  TO_CHAR(vFechaHoy, 'VENCIDO' || '%e%m%Y%H%M%S '); 
	LET v2Referencia23 = REPLACE(v2Referencia23, " ", "");

	LET v2Folio = TO_CHAR(vFechaHoy, 'VG' || '%e%m%Y%H%M%S ');
	LET v2Folio = REPLACE(v2Folio, " ", "");
--------------------
	IF v2Origen = "Plan_Lealtad" THEN
		LET v2Transacc 		= '9820';
		LET v2CodigoFun		= '151';
		LET v2CodigoRef		= 138;
	ELIF v2Origen = "Reworth" THEN
		LET v2Transacc 		= '9997';
		LET v2CodigoFun		= '152';
		LET v2CodigoRef		= 138;
	END IF
	
	LET v2FechaRegistro = SYSDATE;
	
	--Lee sucursal del credito
	SELECT sucursal INTO v2Sucursal
	FROM bdicred:"informix".sd_Maecred
	WHERE num_credito = v2NumCredito;
		
	EXECUTE PROCEDURE bdicred:"informix".genmov(v2Empresa,v2NumCredito,v2Producto,v2CodigoRef,v2CodigoFun,v2FechaRegistro,v2MontoPuntos,v2Folio,v2Sucursal,v2Moneda,v2Transacc)
	INTO cCodRet,pMensaje;
---------------------------	
	INSERT INTO bdicred:"informix".sd_movs_monedero_plan_lealtad
	(numcte, num_credito, tipo_producto, beneficio_calculado, tipo_mov, fecha_mov, folio, monto, origen, moneda, referencia23, nombre_comercio)
	VALUES(v2NumCte, v2NumCredito, v2Producto, v2MontoPuntos, v2TipoMov, v2FechaRegistro, v2Folio, 0, v2Origen, v2Moneda, v2Referencia23, v2NombreComercio);
	
	IF v2ClienteAux = "" THEN
	
		 LET v2ClienteAux = v2NumCte;
		
	END IF;
	
	IF v2ClienteAux <> v2NumCte THEN
		--Cambia el estatus al procesar
		UPDATE bdicred:"informix".sd_vigencia_monedero_plan_lealtad
		SET estatus = "t", tipo = "caducado"
		WHERE estatus = "f"
		AND numcte = v2ClienteAux	
		AND fecha_insert < v2FechaCaduco;
		
		LET v2ClienteAux = v2NumCte;
	END IF;
	COMMIT WORK;
END FOREACH;

IF v2NumCte IS NOT NULL THEN
	BEGIN WORK;
	--Cambia el estatus al procesar
	UPDATE bdicred:"informix".sd_vigencia_monedero_plan_lealtad
	SET estatus = "t", tipo = "caducado"
	WHERE estatus = "f"
	AND numcte = v2NumCte	
	AND fecha_insert < v2FechaCaduco;
	COMMIT WORK;
END IF;
	
-------VIGENCIA END-----------------------------------------------------------------
EXECUTE PROCEDURE bdicred:"informix".sp_plan_lealtad_edc()
INTO cCodRet;

RETURN cCodret;
	
END
END procedure;