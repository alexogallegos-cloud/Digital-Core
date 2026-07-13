CREATE PROCEDURE "informix".sp_ce_aplicapagocom(
   v_num_credito    	CHAR(20),       -- Numero de credito
   v_num_cuenta    		CHAR(20),       -- Numero de cuenta eje
   v_tipo_moneda    	INTEGER,        -- Tipo de Moneda  
   v_importetot        	MONEY(14,2), 	-- Monto del importe total (ComisiÃ³n e IVA de comisiÃ³n)
   v_importecom        	MONEY(14,2), 	-- Monto del importe de la comisiÃ³n
   v_importeiva        	MONEY(14,2), 	-- Monto del importe del IVA comisiÃ³n
   v_IdConceptoPago 	CHAR(1),        -- ID Concepto pago a realizar (Debe ser 2 PARA COMISIONES POR DESEMBOLSO)
   v_tipo_prod      	CHAR(2),        -- Tipo de Producto
   v_usuario        	CHAR(8),        -- Usuario
   v_tipo_pago     		CHAR(1),     	-- Tipo de pago: intento = 0, reintento = 1
   v_folio_suc      	CHAR(20)        -- Folio identificador del pago enviado
										-- considerarse con la nomenclatura siguiente: HH:MM:SS1234567
										--
										-- Donde:
										--
										-- HH =          Hora de envio (24 horas)
										-- MM =          Minuto de envio
										-- SS =          Segundo de envio
										-- 12345678 =    Numero de credito (relleno con ceros a la izquierda)
										-- Por ejemplo: 09:19:3200475815
)
RETURNING CHAR(5), money(14,2), CHAR (16), money(14,2), CHAR (16);
--*******************************************************************************************************
--
-- Objetivo:   SP Aplica Pago comisiones e iva Empresarial Transact
-- Autor:     90314722 - Brayam Jair AndrÃ©s ZÃºÃ±iga
-- Fecha:     24/06/2025 - SP para aplicar un pago de comision e iva 
--
--*******************************************************************************************************
--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************

   DEFINE vSqlErr INTEGER;
   DEFINE cCodRet CHAR(5);
   DEFINE cCodRetRev CHAR(5);
   DEFINE v_MontoTotalMovDiacom MONEY(14,2);
   DEFINE v_MontoTotalMovDiaiva MONEY(14,2);
   DEFINE v_FolioSUC_1   CHAR(16);
   DEFINE v_FolioSUC_2   CHAR(16);
   DEFINE v_FolioSUC_Com   CHAR(16);
   DEFINE v_FolioSUC_Iva   CHAR(16);
   DEFINE v_fecha_folio DATETIME HOUR TO SECOND;
   DEFINE v_tranaplicacom CHAR(04);
   DEFINE v_referenciacom CHAR(25);
   DEFINE v_tranaplicaiva CHAR(04);
   DEFINE v_referenciaiva CHAR(25);
   DEFINE v_sdo_actual MONEY(14,2);
   DEFINE v_cons_sdos_01 char(5);
   DEFINE v_cons_sdos_02 char(20);
   DEFINE v_cons_sdos_03 char(20);
   DEFINE v_cons_sdos_04 char(26);
   DEFINE v_cons_sdos_05 char(26);
   DEFINE v_cons_sdos_06 char(26);
   DEFINE v_cons_sdos_07 char(26);
   DEFINE v_cons_sdos_08 char(60);
   DEFINE v_cons_sdos_09 char(1);
   DEFINE v_cons_sdos_10 money(14,2);
   DEFINE v_cons_sdos_11 money(14,2);
   DEFINE v_cons_sdos_12 money(14,2);
   DEFINE v_cons_sdos_13 money(14,2);
   DEFINE v_cons_sdos_14 money(14,2);
   DEFINE v_cons_sdos_15 char(1);
   DEFINE v_cons_sdos_16 char(40);
   DEFINE v_cons_sdos_17 char(40);
   DEFINE v_cons_sdos_18 money(14,2);
   DEFINE v_cons_sdos_19 money(14,2);
   DEFINE v_cons_sdos_20 money(14,2);
   DEFINE v_cons_sdos_21 char(8);
   DEFINE v_cons_sdos_22 date;
   DEFINE v_cons_sdos_23 char(16);
   DEFINE v_cons_sdos_24 char(18);

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************

   LET vSqlErr = 0;
   LET cCodRet = '00550'; --11111
   LET cCodRetRev = '';
   LET v_MontoTotalMovDiacom = 0;
   LET v_MontoTotalMovDiaiva = 0;
   LET v_FolioSUC_1 = '';
   LET v_FolioSUC_2 = '';
   LET v_FolioSUC_Com = '';
   LET v_FolioSUC_Iva = '';
   LET v_tranaplicacom = '';
   LET v_referenciacom = '';
   LET v_tranaplicaiva = '';
   LET v_referenciaiva = '';
   LET v_sdo_actual = '';
   LET v_cons_sdos_01 = '';
   LET v_cons_sdos_02 = '';
   LET v_cons_sdos_03 = '';
   LET v_cons_sdos_04 = '';
   LET v_cons_sdos_05 = '';
   LET v_cons_sdos_06 = '';
   LET v_cons_sdos_07 = '';
   LET v_cons_sdos_08 = '';
   LET v_cons_sdos_09 = '';
   LET v_cons_sdos_10 = 0;
   LET v_cons_sdos_11 = 0;
   LET v_cons_sdos_12 = 0;
   LET v_cons_sdos_13 = 0;
   LET v_cons_sdos_14 = 0;
   LET v_cons_sdos_15 = '';
   LET v_cons_sdos_16 = '';
   LET v_cons_sdos_17 = '';
   LET v_cons_sdos_18 = 0;
   LET v_cons_sdos_19 = 0;
   LET v_cons_sdos_20 = 0;
   LET v_cons_sdos_21 = '';
   LET v_cons_sdos_22 = '';
   LET v_cons_sdos_23 = '';
   LET v_cons_sdos_24 = '';

--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************

--*****************************************************
-- ACTIVAR / INACTIVAR TRACE
--*****************************************************

   --SET DEBUG FILE TO "/informix/SD/Orion/sp_ce_aplicapago_"||TRIM(v_num_credito)||"_"||TRIM(v_num_cuenta)||"_"||cast(v_tipo_moneda as char(2))||".out";
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

--*****************************************************
-- INICIA PROCESO
--*****************************************************
BEGIN
	ON EXCEPTION SET vSqlErr
		IF vSqlErr <> 0 THEN
				LET cCodRet = vSqlErr;
				CALL sp_ce_aplicareversion(v_FolioSUC_1,v_usuario)
				RETURNING v_FolioSUC_Com;
				CALL sp_ce_aplicareversion(v_FolioSUC_2,v_usuario)
				RETURNING v_FolioSUC_Iva;		
				--ROLLBACKWORK;
			RETURN cCodRet,v_MontoTotalMovDiacom,v_FolioSUC_Com,v_MontoTotalMovDiaiva,v_FolioSUC_Iva;
		END IF;
	END EXCEPTION;
	
		
	--****************************************************
	-- Mov. Transact Para el Folio Unico
	--****************************************************	
	LET v_FolioSUC_1 = substr(trim(v_folio_suc),1,8)||trim(v_tipo_prod)||substr(trim(v_num_credito),6);
	LET v_fecha_folio = ((substr(trim(v_folio_suc),1,8))::DATETIME HOUR TO SECOND) + INTERVAL(1) SECOND TO SECOND;
	LET v_FolioSUC_2 = substr((v_fecha_folio::DATETIME HOUR TO HOUR),1,2)||substr((v_fecha_folio::DATETIME HOUR TO MINUTE),3,3)||substr((v_fecha_folio::DATETIME HOUR TO SECOND),6,4)||trim(v_tipo_prod)||substr(trim(v_num_credito),6);
	
	--****************************************************
	-- Valida el concepto de pago
	--****************************************************
	CALL bdicheq:cons_sdos1('001',v_num_cuenta,'')
        RETURNING
        v_cons_sdos_01,v_cons_sdos_02,v_cons_sdos_03,v_cons_sdos_04,v_cons_sdos_05,v_cons_sdos_06,v_cons_sdos_07,v_cons_sdos_08,v_cons_sdos_09,v_cons_sdos_10,
        v_cons_sdos_11,v_cons_sdos_12,v_cons_sdos_13,v_cons_sdos_14,v_cons_sdos_15,v_cons_sdos_16,v_cons_sdos_17,v_cons_sdos_18,v_cons_sdos_19,v_cons_sdos_20,
        v_cons_sdos_21,v_cons_sdos_22,v_cons_sdos_23,v_cons_sdos_24;

    LET v_sdo_actual = v_cons_sdos_10;
	
	--***********************
    -- Montos no coinciden
    --***********************
    IF v_importetot <> (v_importecom + v_importeiva) THEN
		LET cCodRet = '00420';
	
	--***********************
    -- Fondos insuficientes
    --***********************	
	ELIF v_sdo_actual < v_importetot THEN
        LET cCodRet = '00400';
    
	ELSE
		--****************************************************
		-- Valida el concepto de pago
		--****************************************************	
		IF v_IdConceptoPago = '2' THEN
			--****************************************************
			-- Aplica pago comisiÃ³n
			--****************************************************	
			CALL sp_ce_aplicapago(v_num_credito,v_num_cuenta,v_tipo_moneda,v_importecom,v_IdConceptoPago,v_tipo_prod,v_usuario,v_tipo_pago,v_FolioSUC_1)
			RETURNING cCodRet,v_MontoTotalMovDiacom,v_FolioSUC_Com;
			--****************************************************
			-- Valida si el pago fue exitoso
			--****************************************************	
			IF cCodRet = '00000' THEN
				LET cCodRet =  '';
				--****************************************************
				-- Aplica pago IVA comisiÃ³n
				--****************************************************	
				CALL sp_ce_aplicapago(v_num_credito,v_num_cuenta,v_tipo_moneda,v_importeiva,'3',v_tipo_prod,v_usuario,v_tipo_pago,v_FolioSUC_2)
				RETURNING cCodRet,v_MontoTotalMovDiaiva,v_FolioSUC_Iva;
				--**********************************************************************************************************************************
				-- Valida si el pago fue exitoso, en caso de fallar el pago IVA, se realiza reverso del pago comision
				--**********************************************************************************************************************************	
				IF cCodRet <> '00000' THEN
					CALL sp_ce_aplicareversion(v_FolioSUC_Com,v_usuario)
					RETURNING cCodRetRev;
					--****************************************************
					-- Valida si el reverso fue aplicado, si existe un error envia el error en cCodRet
					--****************************************************	
					IF cCodRetRev <> '00000' THEN
						LET cCodRet = cCodRetRev;
					END IF;
				END IF;	
			END IF;
		END IF;
	END IF;
	RETURN cCodRet,v_MontoTotalMovDiacom,v_FolioSUC_Com,v_MontoTotalMovDiaiva,v_FolioSUC_Iva;
END;
END PROCEDURE;