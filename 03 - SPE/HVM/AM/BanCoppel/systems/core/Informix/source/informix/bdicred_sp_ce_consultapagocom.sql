CREATE PROCEDURE "informix".sp_ce_consultapagocom(
   v_num_credito    	CHAR(20),       -- Numero de credito
   v_num_cuenta    		CHAR(20),       -- Numero de cuenta eje
   v_tipo_moneda    	INTEGER,        -- Tipo de Moneda  
   v_importetot        	MONEY(14,2), 	-- Monto del importe total (ComisiÃ³n e IVA de comisiÃ³n)
   v_importecom        	MONEY(14,2), 	-- Monto del importe de la comisiÃ³n
   v_importeiva        	MONEY(14,2), 	-- Monto del importe del IVA comisiÃ³n
   v_IdConceptoPago 	CHAR(1),        -- ID Concepto pago a realizar (Debe ser 2)
   v_tipo_prod      	CHAR(2),        -- Tipo de Producto
   v_usuario        	CHAR(8),        -- Usuario
   v_folio_suc      	CHAR(20)        -- Folio identificador del pago enviado ++++++ CONSIDERAR EL USUARIO 
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
-- Objetivo:   SP Consulta Pago comisiones e iva Empresarial Transact
-- Autor:     90314722 - Brayam Jair AndrÃ©s ZÃºÃ±iga
-- Fecha:     24/06/2025 - SP para consultar un pago de comision e iva existente en la tabla de bdicheq:sc_movdia
--
--*******************************************************************************************************
--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************

   DEFINE vSqlErr INTEGER;
   DEFINE cCodRet CHAR(5);
   DEFINE v_FolioSUC_1   CHAR(16);
   DEFINE v_FolioSUC_2   CHAR(16);
   DEFINE v_fecha_folio DATETIME HOUR TO SECOND;
   DEFINE v_tranaplicacom CHAR(04);
   DEFINE v_referenciacom CHAR(25);
   DEFINE v_tranaplicaiva CHAR(04);
   DEFINE v_referenciaiva CHAR(25);   
   DEFINE v_id_moneda CHAR(1);
   DEFINE v_id_cuenta INTEGER;
   DEFINE v_id_usuario INTEGER;
   DEFINE v_MontoTotalMovDiacom MONEY(14,2);
   DEFINE v_MontoTotalMovDiaiva MONEY(14,2);
   DEFINE v_canceladcom CHAR(1);
   DEFINE v_canceladiva CHAR(1);

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************

   LET vSqlErr = 0;
   LET cCodRet = ''; --11111
   LET v_MontoTotalMovDiacom = '';
   LET v_MontoTotalMovDiaiva = '';
   LET v_FolioSUC_1 = '';
   LET v_FolioSUC_2 = '';
   LET v_tranaplicacom = '';
   LET v_referenciacom = '';
   LET v_tranaplicaiva = '';
   LET v_referenciaiva = '';
   LET v_canceladcom = '';
   LET v_canceladiva = '';
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
				let cCodRet = vSqlErr;
				--ROLLBACKWORK;
			RETURN cCodRet,v_MontoTotalMovDiacom,v_FolioSUC_1,v_MontoTotalMovDiaiva,v_FolioSUC_2;
		END IF;
	END EXCEPTION;
	
		
	--****************************************************
	-- Mov. Transact Para el Folio Unico
	--****************************************************	
	LET v_FolioSUC_1 = substr(trim(v_folio_suc),1,8)||trim(v_tipo_prod)||substr(trim(v_num_credito),6);
	LET v_fecha_folio = ((substr(trim(v_folio_suc),1,8))::DATETIME HOUR TO SECOND) + INTERVAL(1) SECOND TO SECOND;
	LET v_FolioSUC_2 = substr((v_fecha_folio::DATETIME HOUR TO HOUR),1,2)||substr((v_fecha_folio::DATETIME HOUR TO MINUTE),3,3)||substr((v_fecha_folio::DATETIME HOUR TO SECOND),6,4)||trim(v_tipo_prod)||substr(trim(v_num_credito),6);
		
	--****************************************************
	-- Valida tipo de moneda
	--****************************************************
	
	SELECT id_pago
	INTO v_id_moneda
	FROM 'informix'.sd_ce_tipo_moneda
	WHERE num_tipo_moneda = v_tipo_moneda;
	
	--****************************************************
	-- Valida Cuenta Eje
	--****************************************************
	
	SELECT COUNT(status_cta)
	INTO v_id_cuenta
	FROM bdicheq:'informix'.sc_maechq
	WHERE cuenta = v_num_cuenta;
	
	--****************************************************
	-- Valida Usuario
	--****************************************************
	
	SELECT COUNT(ejecutivo)
	INTO v_id_usuario
	FROM bdinteg:'informix'.si_ejecut
	WHERE ejecutivo = v_usuario;
	
	--*****************************
	-- Valida asignacion de Transacciones (TRANSACT)
	--*****************************
	
	IF (v_IdConceptoPago = '2' AND v_tipo_prod = '99')THEN -->Pago de Comision
		LET v_tranaplicacom = '9008';
		LET v_referenciacom = 'COBRO DE COMISION EMP ';
		LET v_tranaplicaiva = '9009';                      -->Pago IVA de Comision
		LET v_referenciaiva = 'COBRO IVA COMISION EMP';
	END IF;
	
	--******************************************************
	-- Valida el tipo de moneda, se excluyen los indicados
	--******************************************************
	
	IF v_id_moneda = '0' OR v_id_moneda IS NULL THEN -->(1=MXN, 2=USD)
		LET cCodRet = '00951';
		
	--******************************************************
	-- Valida que exista la cuenta
	--******************************************************
	
	ELIF v_id_cuenta = 0 THEN
		LET cCodRet = '00100';
		
	--******************************************************
	-- Valida que exista el usuario
	--******************************************************
	
	ELIF v_id_usuario = 0 THEN
		LET cCodRet = '00106';
		
	--*****************************
	-- Valida que exista la transacciÃ³n
	--*****************************		
	
	ELIF v_tranaplicacom = '' OR v_tranaplicaiva = '' THEN
		LET cCodRet = '00550';	
	
	ELSE
		--************************************
		-- Consulta Pago ComisiÃ³n
		--************************************
		
		SELECT DATA_1.monto_tot, DATA_1.cancelad 
		INTO v_MontoTotalMovDiacom, v_canceladcom
		FROM (
		SELECT FIRST 1 monto_tot,folio_suc,cancelad
		FROM bdicheq:'informix'.sc_movdia
		WHERE empresa = '001' AND
		cuenta = v_num_cuenta AND
		monto_tot = v_importecom AND
		folio_suc = v_FolioSUC_1 AND
		transacc = v_tranaplicacom AND
		usuautoriza = v_usuario AND
		referencia LIKE v_referenciacom||'%'||v_num_credito||'%'
		ORDER BY cancelad ASC, fech_hor DESC)DATA_1;
		
		--************************************
		-- Consulta Pago IVA ComisiÃ³n
		--************************************
			
		SELECT DATA_1.monto_tot, DATA_1.cancelad
		INTO v_MontoTotalMovDiaiva, v_canceladiva
		FROM (
		SELECT FIRST 1 monto_tot,folio_suc,cancelad
		FROM bdicheq:'informix'.sc_movdia
		WHERE empresa = '001' AND
		cuenta = v_num_cuenta AND
		monto_tot = v_importeiva AND
		folio_suc = v_FolioSUC_2 AND
		transacc = v_tranaplicaiva AND
		usuautoriza = v_usuario AND
		referencia LIKE v_referenciaiva||'%'||v_num_credito||'%'
		ORDER BY cancelad ASC, fech_hor DESC)DATA_1;
		
		--***********************************************************************************************
		-- Valida si ya existe el registro 
		--***********************************************************************************************
		
		IF v_MontoTotalMovDiacom > 0 AND v_MontoTotalMovDiaiva > 0 AND v_canceladcom = '' AND v_canceladiva = '' THEN
			LET cCodRet = '00000';
		ELSE
			LET cCodRet = '00988';
		END IF;	
	END IF;  
	RETURN cCodRet,v_MontoTotalMovDiacom,v_FolioSUC_1,v_MontoTotalMovDiaiva,v_FolioSUC_2;
END;
END PROCEDURE;