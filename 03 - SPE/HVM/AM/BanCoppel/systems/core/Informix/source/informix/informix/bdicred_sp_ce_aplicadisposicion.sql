CREATE PROCEDURE "informix".sp_ce_aplicadisposicion(v_num_credito CHAR(20),
													v_num_cuenta CHAR(20), 
													v_importe MONEY (14,2),
													v_usuario CHAR(8), 
													v_tipo_prod CHAR(2), 
													v_tipo_disp CHAR(1), 
													v_num_prod CHAR(5), 
													v_desc_prod CHAR(255), 
													v_tipo_moneda CHAR(10),
													v_nombre_cte CHAR(150),
													v_correo_p CHAR(100),
													v_correo_a CHAR(100),
													v_celular CHAR(10),
													v_nombre_benef CHAR(100),
													v_cuenta_benef CHAR(60),
													v_banco CHAR(60),
													v_pais_ciudad CHAR(100),
													v_codigo_swift CHAR(30),
													v_codigo_aba CHAR(30),
													v_cuenta_banco CHAR(60),
													v_banco_inter CHAR(60),
													v_concepto CHAR(60))
RETURNING CHAR(5), money(14,2), CHAR (16);
    
    ------------------------------------------------------------------------------>
    -- Objetivo: Sp para disposiciÃÂ³n de crÃÂ©dito empresarial - OriÃÂ³n
    -- Autor: SADCV
    -- Fecha: 30/09/2013
	-- ModificaciÃÂ³n: 01/08/2016
	-- ValidaciÃÂ³n de disposiciÃÂ³n
    ------------------------------------------------------------------------------>
	-- CONTROL DE CAMBIOS
	------------------------------------------------------------------------------>
    -- PeticiÃÂ³n: RQM 20 087 - CrÃÂ©dito en USD
	-- Modificado por: 98769022 Miguel Alejandro SÃÂ¡nchez Mojica
	-- ModificaciÃÂ³n: Se agregan parÃÂ¡metros y validaciones para permitir la disposiciÃÂ³n de crÃÂ©ditos en MXN y USD y la ejecuciÃÂ³n de la notificaciÃÂ³n de LATINIA
	------------------------------------------------------------------------------>
	-- CONTROL DE CAMBIOS 10/01/2025
	------------------------------------------------------------------------------>
    -- PeticiÃÂ³n: P-SBN-20250110-01
	-- Modificado por: 990314722 Brayam Jair Andres ZuÃÂ±iga
	-- ModificaciÃÂ³n: Se agregan funcionalidades para el nuevo core bancario Transact
    ------------------------------------------------------------------------------>
		-- CONTROL DE CAMBIOS 12/03/2025
	------------------------------------------------------------------------------>
    -- PeticiÃÂ³n: RQI CSE006 - Unity CSE - Procedimientos almacenados Pago y Disposicion Transact
	-- Modificado por: 990314722 Brayam Jair Andres ZuÃ±iga
	-- ModificaciÃÂ³n: Se agregan la modifiacion del folio SUC unico para el sistema de Transact y se registra el "Numero de crÃ©dito" en el campo referencia 
	--                para una mayor trazabilidad hacia negocio.
    ------------------------------------------------------------------------------>
	--// Inicializa de Variables 

    DEFINE vSqlErr 				INTEGER;
    DEFINE cCodRet  			CHAR (5);
		
	DEFINE v_importe_1			MONEY(14,2);
	DEFINE v_sdo_actual			MONEY(14,2);
	DEFINE v_importe_ap			MONEY(14,2);
		
	DEFINE v_FolioSUC       	CHAR(16);
	DEFINE v_FolioSUC_1     	CHAR(16);
	DEFINE v_FolioSUC_2     	CHAR(16);
    DEFINE v_fecha_folio    	CHAR(10);
		
	DEFINE DCodret_a 			CHAR (5);
	DEFINE DTranret_c			CHAR (4);
	DEFINE DFechoy_c			DATE ;
	DEFINE DVsdodisp_c 			MONEY (14,2);
	DEFINE DVmontoret_c			MONEY (14,2);
		
	DEFINE v_count 				INTEGER;
	DEFINE v_transacc       	CHAR(5);
	DEFINE v_referencia     	CHAR (25);
	DEFINE v_status_disposicion	CHAR (1);
	
	DEFINE 	v_count_prod_disp	INTEGER;
	DEFINE	v_empresa			CHAR(3);
	DEFINE	v_num_producto		CHAR(5);
	DEFINE	v_desc_producto		VARCHAR(255);
	DEFINE	v_moneda			VARCHAR(5);
	DEFINE	v_tipomoneda_tabla	VARCHAR(5);
	DEFINE	v_pTipoMsj			CHAR(1);
	DEFINE	v_pIdMsj			VARCHAR(10);
	DEFINE	v_pIdPlantilla		VARCHAR(12);
	DEFINE	v_pNumclt			VARCHAR(20);
	DEFINE	v_pNumcta			VARCHAR(20);
	DEFINE	v_pNumTarjeta		VARCHAR(16);
	DEFINE	v_pTipoproc			CHAR(1);
	DEFINE	v_pStr1				VARCHAR(30);
	DEFINE	v_pStr2				VARCHAR(30);
	DEFINE	v_pStr3				VARCHAR(30);
	DEFINE	v_pStr4				VARCHAR(30);
	DEFINE	v_pStr5				VARCHAR(150);
	DEFINE	v_pStr6				VARCHAR(100);
	DEFINE	v_pStr7				VARCHAR(60);
	DEFINE	v_pStr8				VARCHAR(60);
	DEFINE	v_pStr9				VARCHAR(15);
	DEFINE	v_pStr10			VARCHAR(100);
	DEFINE	v_pcorreo_alterno	VARCHAR(100);
	DEFINE	v_correo_copia		VARCHAR(100);
	DEFINE	v_pcelular_alterno	VARCHAR(10);
	DEFINE	v_pImporte1			MONEY (16,2);
	DEFINE	v_pImporte2			MONEY (16,2);
	DEFINE	v_pImporte3			MONEY (16,2);
	DEFINE	v_pImporte4			MONEY (16,2);
	DEFINE	v_pImporte5			MONEY (16,2);
	DEFINE	v_pfecha1			DATETIME YEAR TO FRACTION(3);
	DEFINE	v_pfecha2			DATETIME YEAR TO FRACTION(3);
	DEFINE	v_status			CHAR(1);
	DEFINE	v_cuenta_correos	INTEGER;
	DEFINE 	v_status_envio		CHAR(5);
	DEFINE 	v_status_envio_hist	CHAR(5);
	DEFINE 	v_count_reint		INTEGER;
	DEFINE  v_folio_transact    CHAR(8);
    ------------------------------------------------------------------------------>
	--// Inicializa variables
	
    LET vSqlErr 			= 0;
    LET cCodRet 			= '00000';
	
	LET v_importe_1			= '';
	LET v_sdo_actual		= '';
	LET v_importe_ap		= '';

	LET v_FolioSUC			= '';
	LET v_FolioSUC_1		= '';
    LET v_fecha_folio       = '';
	
	LET DCodret_a 			= '000';
	
	LET v_count 			= 0;
	
	LET v_transacc 			= '';
	LET v_referencia 		= '';
	
	LET v_cuenta_correos 	= 0;
	
	LET v_moneda			= 'MXN';
	LET v_status_envio 		= '00000';
	LET v_status_envio_hist = '11111';
	LET v_count_reint		= 0;
	
   -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
	--SET DEBUG FILE TO "/informix/SD/Orion/sp_ce_aplicadisposicion"||TRIM(v_num_cuenta)||".out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		
    ------------------------------------------------------------------------------>
	--//
    
    BEGIN

    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            let cCodRet = vSqlErr;
            --ROLLBACK WORK;
            RETURN cCodRet, v_importe, v_FolioSUC;
        END IF;
    END EXCEPTION;

	------------------------------------------------------------------------------>
	--//
	
	--> ValidaciÃÂ³n de cuentas eje.
	
	SELECT status_disposicion
	INTO v_status_disposicion
	FROM sd_ce_cuentas_bf
	WHERE num_cta_eje = v_num_cuenta;
	
	
	--IF v_num_cuenta IN ('12000004071','12000004101','12000004098','12000004144','27000000146','12000004063','10423264514', '10423693881') THEN  ----------------------------------------------------------------------------------->>> CIERRE TIEMPORAL BF - Cuenta Eje
	IF v_status_disposicion = '0' THEN
		
		LET cCodRet = '00000';
	
	ELSE   ----------------------------------------------------------------------------------->>> CIERRE TIEMPORAL BF - Cuenta Eje
	
		--> AsignaciÃÂ³n de transacciones para cargos a cuentas de cheques. 
		IF (v_tipo_prod = '01' AND v_tipo_moneda <> '2') THEN  ----------------------------------------------------------------------------------->>> LÃÂ­nea CrÃÂ©dito
		
			LET v_transacc = '3323';
			LET v_referencia = 'No Credito Revolvente ';
		
			ELSE
		
			LET v_transacc = '0337';
			LET v_referencia = 'No Credito Empresarial ';
		
		END IF;
        -- AsignaciÃÂ³n de transacciones (TRANSACT). 
		IF (v_tipo_prod = '99' AND v_tipo_moneda <> '2') THEN  ----------------------------------------------------------------------------------->>> LÃÂ­nea CrÃÂ©dito
		
			LET v_transacc = '9005';
			LET v_referencia = 'ABONO DE CREDITO EMP ';
			LET v_folio_transact = trim(v_tipo_prod)||substr(trim(v_num_credito),6);
			
		END IF;

		-- Generar Folio SUC
		LET v_fecha_folio  = substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);
		IF (v_tipo_prod = '99') THEN
			
			LET v_FolioSUC = trim(v_fecha_folio)||LPAD(TRIM(v_folio_transact),8,'0');
			
			ELSE
			
			LET v_FolioSUC = trim(v_fecha_folio)||LPAD(TRIM(v_num_credito),8,'0');
		
		END IF;		

		--> (Si es primer envÃÂ­o y la cuenta eje es diferente a vacÃÂ­o) y la moneda es diferente a dÃÂ³lares, realizar afectaciÃÂ³n en cuentas
		IF ((v_tipo_disp = '0' AND v_num_cuenta <> '0') AND v_tipo_moneda <> '2') THEN   --> Primer envÃÂ­o 
		
			SET ISOLATION DIRTY READ;
		
			--LET v_fecha_folio  = substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);
		
			--LET v_FolioSUC = trim(v_fecha_folio)||LPAD(TRIM(v_num_credito),8,'0');
			
			IF (v_tipo_prod = '99') THEN
			
				CALL bdicheq:abono_ref ('001', '9250', v_usuario, v_transacc, '0000', v_FolioSUC, v_num_cuenta, v_folio_transact, v_importe, v_importe, 0, 0, 0, '01', v_referencia||LPAD(TRIM(v_num_credito),12,'0'), '', v_usuario)
				RETURNING DCodret_a;
				
				ELSE
				
				CALL bdicheq:abono_ref ('001', '9250', v_usuario, v_transacc, '0000', v_FolioSUC, v_num_cuenta, v_num_credito, v_importe, v_importe, 0, 0, 0, '01', v_referencia||LPAD(TRIM(v_num_credito),12,'0'), '', v_usuario)
				RETURNING DCodret_a;
				
			END IF;
		
		--> (Si es re-intento y la cuenta eje es diferente a vacÃÂ­o) y la moneda es diferente a dÃÂ³lares, realizar afectaciÃÂ³n en cuentas
		ELIF ((v_tipo_disp = '1' AND v_num_cuenta <> '0') AND v_tipo_moneda <> '2') THEN --> Error por respuesta tardia interact
		
			SELECT COUNT (*), folio_suc, monto_tot
			INTO v_count, v_FolioSUC_1, v_importe_1
			FROM bdicheq:sc_movdia WHERE empresa = '001' AND transacc = v_transacc AND cuenta = v_num_cuenta AND monto_tot = v_importe AND cancelad = '' AND referencia LIKE TRIM(v_referencia)||' '||LPAD(TRIM(v_num_credito),12,'0')
			GROUP BY folio_suc, monto_tot;
			
			LET v_FolioSUC_1 = v_FolioSUC_1;
			LET v_importe_1 = v_importe_1; 
			LET v_count = v_count;
			
			IF (v_count >= 1)  THEN		
						
				LET v_importe 	= v_importe_1;
				LET v_FolioSUC 	= v_FolioSUC_1;
				LET DCodret_a 	= '000'; 
				
			ELSE
			
				SET ISOLATION DIRTY READ;
		
				--LET v_fecha_folio  = substr((current HOUR TO HOUR),1,2)||substr((current HOUR TO MINUTE),3,3)||substr((current HOUR TO SECOND),6,4);
		
				--LET v_FolioSUC = trim(v_fecha_folio)||LPAD(TRIM(v_num_credito),8,'0');
				
				IF (v_tipo_prod = '99') THEN
			
					CALL bdicheq:abono_ref ('001', '9250', v_usuario, v_transacc, '0000', v_FolioSUC, v_num_cuenta, v_folio_transact, v_importe, v_importe, 0, 0, 0, '01', v_referencia||LPAD(TRIM(v_num_credito),12,'0'), '', v_usuario)
					RETURNING DCodret_a;
				
					ELSE
				
					CALL bdicheq:abono_ref ('001', '9250', v_usuario, v_transacc, '0000', v_FolioSUC, v_num_cuenta, v_num_credito, v_importe, v_importe, 0, 0, 0, '01', v_referencia||LPAD(TRIM(v_num_credito),12,'0'), '', v_usuario)
					RETURNING DCodret_a;
				
				END IF;
			
			END IF;
			
		END IF;
		
		---------------------------------------------------------------------------------------------------- NOTIFICACIONES ------------------------------------------------------------------------>>> RQM 20 087
		
		-- Si el tipo de moneda es pesos mexicanos y el resultado del abono es 000, ÃÂ³ el tipo de moneda son dÃÂ³lares, realizar el proceso de notificaciones
		IF ((v_tipo_moneda = '1' AND DCodret_a = '000') OR v_tipo_moneda = '2') THEN 
		
			-- Si el tipo de moneda es igual a 2, se asigna a la variable de moneda como dÃÂ³lares
			IF(v_tipo_moneda = '2') THEN
			
				LET v_moneda = 'USD';
			
			END IF;
				
			-- Validar si se encuentra registrado el producto de OriÃÂ³n en la tabla de notificaciones
			SELECT 	COUNT(*)
			INTO 	v_count_prod_disp
			FROM 	bdimnsj:"informix".mnsj_ce_notifica_disp
			WHERE 	num_producto = v_num_prod;
				
			-- Si no existe en la tabla, insertar los registros
			IF(v_count_prod_disp = 0) THEN
			
				FOREACH WITH HOLD
				
					-- Seleccionar los valores por default para las notificaciones
					SELECT 	empresa, tipo_moneda, pTipoMsj, pIdMsj, pIdPlantilla, pNumclt, 
							pNumcta, pNumTarjeta, pTipoproc, pStr1, pStr2, 
							pStr3, pStr4, pStr5, pStr6, pStr7, 
							pStr8, pStr9, pStr10, pcorreo_alterno, correo_copia, 
							pcelular_alterno, pImporte1, pImporte2, pImporte3, pImporte4, 
							pImporte5, pfecha1, pfecha2, status
					INTO	v_empresa, v_tipomoneda_tabla, v_pTipoMsj, v_pIdMsj, v_pIdPlantilla, v_pNumclt, 
							v_pNumcta, v_pNumTarjeta, v_pTipoproc, v_pStr1, v_pStr2, 
							v_pStr3, v_pStr4, v_pStr5, v_pStr6, v_pStr7, 
							v_pStr8, v_pStr9, v_pStr10, v_pcorreo_alterno, v_correo_copia, 
							v_pcelular_alterno, v_pImporte1, v_pImporte2, v_pImporte3, v_pImporte4, 
							v_pImporte5, v_pfecha1, v_pfecha2, v_status
					FROM 	bdimnsj:"informix".mnsj_ce_notifica_disp
					WHERE 	num_producto IN ('0','00') AND tipo_moneda <= v_tipo_moneda
					
					-- Si la moneda enviada por parÃÂ¡metro es diferente a MXN y el tipo de moneda obtenida del producto por default es igual a 1, colocar estatus a 0
					-- Las notificaciones para clientes solo debe aplicar para crÃÂ©ditos en pesos
					IF(v_tipo_moneda <> '1' AND v_tipomoneda_tabla = '1') THEN
						
						LET v_status = '0';
						
					END IF;
					
					-- Insertar nuevo producto
					INSERT INTO bdimnsj:"informix".mnsj_ce_notifica_disp VALUES(v_empresa, v_num_prod, v_desc_prod, v_tipo_moneda, '0', 
																				v_pTipoMsj, v_pIdMsj, v_pIdPlantilla, v_pNumclt, v_pNumcta, 
																				v_pNumTarjeta, v_pTipoproc, v_pStr1, v_pStr2, v_pStr3, 
																				v_pStr4, v_pStr5, v_pStr6, v_pStr7, v_pStr8, 
																				v_pStr9, v_pStr10, v_pcorreo_alterno, v_correo_copia, v_pcelular_alterno, 
																				v_pImporte1, v_pImporte2, v_pImporte3, v_pImporte4, v_pImporte5, 
																				v_pfecha1, v_pfecha2, v_status, TODAY, NULL);
				END FOREACH;
	
			END IF;
				
			LET v_pStr9 = TRIM(TO_CHAR(TODAY, "%d/%m/%Y" ));	-- Se asigna a la variable 9 la fecha en que se envÃÂ­a el correo
			
			FOREACH WITH HOLD
			
				-- Seleccionar la informaciÃÂ³n para la notificaciÃÂ³n
				SELECT 	empresa, pTipoMsj, pIdMsj, pIdPlantilla, pNumclt, 
						pNumcta, pNumTarjeta, pTipoproc, pStr1, pStr2, 
						pStr3, pStr4, pStr5, pStr6, pStr7, 
						pStr8, pStr10, pcorreo_alterno, correo_copia, pcelular_alterno, 
						pImporte1, pImporte2, pImporte3, pImporte4, pImporte5, 
						pfecha1, pfecha2, status
				INTO	v_empresa, v_pTipoMsj, v_pIdMsj, v_pIdPlantilla, v_pNumclt, 
						v_pNumcta, v_pNumTarjeta, v_pTipoproc, v_pStr1, v_pStr2, 
						v_pStr3, v_pStr4, v_pStr5, v_pStr6, v_pStr7, 
						v_pStr8, v_pStr10, v_pcorreo_alterno, v_correo_copia, v_pcelular_alterno, 
						v_pImporte1, v_pImporte2, v_pImporte3, v_pImporte4, v_pImporte5, 
						v_pfecha1, v_pfecha2, v_status
				FROM 	bdimnsj:"informix".mnsj_ce_notifica_disp
				WHERE 	num_producto = v_num_prod AND status = '1'
				
				-- VÃÂ¡lida si es la plantilla de notificaciones para el cliente o notificaciÃÂ³n por SMS, asginar las variables correspondientes
				IF(TRIM(v_pIdPlantilla) = 'CE_NOT_DISPC' OR TRIM(v_pTipoMsj) = '2') THEN
				
					-- Validar si no tiene correo principal el cliente, asignar como correo principal el correo alterno
					IF(v_correo_p = '' OR v_correo_p = ' ') THEN
					
						LET v_correo_p = v_correo_a;
					
					END IF;
					
					LET v_pStr2 = TRIM(v_num_credito);								-- Se asigna a la variable 2 el nÃÂºmero del crÃÂ©dito
					LET v_pStr3 = TRIM(TO_CHAR(v_importe,'$###,###,###.##'));		-- Se asigna a la variable 3 el importe a disponer
					LET v_pStr4 = TRIM(v_moneda);									-- Se asigna a la variable 4 el tipo de moneda	
					LET v_pcorreo_alterno = v_correo_p;								-- Se asigna a la variable de correo el correo del cliente
					LET v_pcelular_alterno = v_celular;								-- Se asigna a la variable de celular el nÃÂºmero de celular del cliente
				
				-- Asignar variables para notificaciÃÂ³n de dÃÂ³lares
				ELSE
					
					LET v_pStr1 = TRIM(v_num_credito);												-- Se asigna a la variable 1 el nÃÂºmero del crÃÂ©dito
					LET v_pStr2 = TRIM(TO_CHAR(v_importe,'$###,###,###.##'));						-- Se asigna a la variable 2 el importe a disponer
					LET v_pStr3 = TRIM(v_codigo_swift);												-- Se asigna a la variable 3 el cÃÂ³digo swift
					LET v_pStr4 = TRIM(v_codigo_aba);												-- Se asigna a la variable 4 el cÃÂ³digo aba
					LET v_pStr5 = TRIM(v_nombre_cte);												-- Se asigna a la variable 5 el nombre de cliente
					LET v_pStr6 = TRIM(v_nombre_benef);												-- Se asigna a la variable 6 el nombre del beneficiario
					LET v_pStr7 = TRIM(v_cuenta_benef);												-- Se asigna a la variable 7 el nÃÂºmero cuenta
					LET v_pStr8 = TRIM(v_banco);													-- Se asigna a la variable 8 el nombre del banco
					LET v_pStr10 = REPLACE(REPLACE(TRIM(v_pais_ciudad),', null',''),'N/A','');		-- Se asigna a la variable 10 el nombre del paÃÂ­s y la ciudad
				
				END IF;
				
				-- Si es re-intento y es el primer registro obtenido de la tabla de notificaciones, validar en la tabla de control si ya fue registrado el Folio SUC y un status de envÃÂ­o en la primer ejecuciÃÂ³n de la notificaciÃÂ³n
				IF (v_tipo_disp = '1' AND v_count_reint  = 0) THEN
					
					SELECT 	MAX(folio_suc), MAX(status_envio)
					INTO	v_FolioSUC_2, v_status_envio_hist
					FROM	bdimnsj:"informix".mnsj_ce_notifica_disp_hist
					WHERE	empresa = v_empresa AND DATE(fecha_ejecucion) = TODAY AND num_producto = v_num_prod 
					AND 	(pStr1 = v_num_credito OR pStr2 = v_num_credito) AND pcorreo_alterno = v_pcorreo_alterno;
					
					-- Si existe un Folio SUC, asignarlo como el Folio SUC a utilizar
					IF(v_FolioSUC_2 IS NOT NULL) THEN
						
						LET v_FolioSUC = v_FolioSUC_2;
						
					END IF;
					
					-- Si existe un status de envÃÂ­o, asignarlo a la variable v_status_envio_hist
					IF(v_status_envio_hist IS NOT NULL) THEN
						
						LET v_status_envio_hist = v_status_envio_hist;

					ELSE
					
						LET v_status_envio_hist = '11111';
					
					END IF;
					
					LET v_count_reint = 1;
					
				END IF;
				
				-- Si el v_status_envio_hist es diferente a 00000, realizar el envÃÂ­o de notificaciones
				-- Si es re-intento y se detectÃÂ³ que hubo error en la primer ejecuciÃÂ³n, realizar el envÃÂ­o de notificaciones, sÃÂ­ no hubo errores, no ejecuta la notificaciÃÂ³n
				IF (v_status_envio_hist <> '00000') THEN
				
					-- Si el tipo de notificaciÃÂ³n es 1 (email) y el correo no esta vacÃÂ­o, o 2 (sms) y el nÃÂºmero de celular no esta vacÃÂ­o, ejecutar el envÃÂ­o de notificaciÃÂ³n
					IF ((v_pTipoMsj = '1' AND v_pcorreo_alterno <> '') OR (v_pTipoMsj = '2' AND v_pcelular_alterno <> '00')) THEN
					
						-- Ejecuta el envÃÂ­o de notificaciones
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(v_pTipoMsj, TRIM(v_pIdMsj), TRIM(v_pIdPlantilla), TRIM(v_pNumclt), TRIM(v_pNumcta),
																				TRIM(v_pNumTarjeta), v_pTipoproc, v_pStr1, v_pStr2, v_pStr3,
																				v_pStr4, v_pStr5, v_pStr6, v_pStr7, v_pStr8,
																				v_pStr9, v_pStr10, v_pcorreo_alterno, v_pcelular_alterno, v_pImporte1,
																				v_pImporte2, v_pImporte3, v_pImporte4, v_pImporte5, v_pfecha1,
																				v_pfecha2)
						INTO v_status_envio;
						
						-- Inserta resultado en la tabla de control
						INSERT INTO bdimnsj:mnsj_ce_notifica_disp_hist VALUES(	v_empresa, CURRENT, v_num_prod, v_tipo_moneda, v_moneda,
																				v_tipo_disp, v_FolioSUC, v_status_envio, v_pTipoMsj, v_pIdMsj, 
																				v_pIdPlantilla, v_pNumclt, v_pNumcta, v_pNumTarjeta, v_pTipoproc, 
																				v_pStr1, v_pStr2, v_pStr3, v_pStr4, v_pStr5, 
																				v_pStr6, v_pStr7, v_pStr8, v_pStr9, v_pStr10, 
																				v_pcorreo_alterno, v_pcelular_alterno, v_pImporte1, v_pImporte2, v_pImporte3, 
																				v_pImporte4, v_pImporte5, v_pfecha1, v_pfecha2 );
						
					END IF;
	
					-- Si el tipo de notificaciÃÂ³n es 1 (email), envÃÂ­ar notificaciÃÂ³n al correo copia
					IF (v_pTipoMsj = '1') THEN
					
						-- Ejecuta el envÃÂ­o de notificaciones
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(v_pTipoMsj, TRIM(v_pIdMsj), TRIM(v_pIdPlantilla), TRIM(v_pNumclt), TRIM(v_pNumcta),
																				TRIM(v_pNumTarjeta), v_pTipoproc, v_pStr1, v_pStr2, v_pStr3,
																				v_pStr4, v_pStr5, v_pStr6, v_pStr7, v_pStr8,
																				v_pStr9, v_pStr10, v_correo_copia, v_pcelular_alterno, v_pImporte1,
																				v_pImporte2, v_pImporte3, v_pImporte4, v_pImporte5, v_pfecha1,
																				v_pfecha2)
						INTO v_status_envio;
						
						-- Inserta resultado en la tabla de control
						INSERT INTO bdimnsj:mnsj_ce_notifica_disp_hist VALUES(	v_empresa, CURRENT, v_num_prod, v_tipo_moneda, v_moneda,
																				v_tipo_disp, v_FolioSUC, v_status_envio, v_pTipoMsj, v_pIdMsj, 
																				v_pIdPlantilla, v_pNumclt, v_pNumcta, v_pNumTarjeta, v_pTipoproc, 
																				v_pStr1, v_pStr2, v_pStr3, v_pStr4, v_pStr5, 
																				v_pStr6, v_pStr7, v_pStr8, v_pStr9, v_pStr10, 
																				v_correo_copia, v_pcelular_alterno, v_pImporte1, v_pImporte2, v_pImporte3, 
																				v_pImporte4, v_pImporte5, v_pfecha1, v_pfecha2 );
	
					END IF;
					
				END IF;

			END FOREACH;
				
		END IF;	----------------------------------------------------------------------------------->>> RQM 20 087
		
	END IF;   ----------------------------------------------------------------------------------->>> CIERRE TIEMPORAL BF - Cuenta Eje 
	
	-->
	-- LET v_importe 	= v_importe;
	-- LET v_FolioSUC 	= v_FolioSUC;
	-- LET cCodRet 	= '000'; 
	
	LET cCodRet = LPAD (TRIM(DCodret_a), 5, '0');
	
    RETURN cCodRet, v_importe, v_FolioSUC;
    
	END;
	
END PROCEDURE;