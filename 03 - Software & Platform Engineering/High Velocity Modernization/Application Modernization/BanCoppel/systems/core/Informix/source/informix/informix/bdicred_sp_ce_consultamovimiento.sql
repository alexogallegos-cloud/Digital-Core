CREATE PROCEDURE "informix".sp_ce_consultamovimiento(
   v_num_credito    CHAR(20),    -- Numero de credito
   v_num_cuenta     CHAR(20),    -- Numero de cuenta eje
   v_tipo_moneda    INTEGER,     -- Tipo de Moneda  
   v_importe        MONEY(14,2), -- Monto del importe
   v_IdConceptoPago CHAR(1),     -- ID Concepto pago a realizar (Comision, Capital, IVA, etc)
   v_tipo_prod      CHAR(2),     -- Tipo de Producto
   v_usuario        CHAR(8),     -- Usuario
   v_folio_suc      CHAR(20)     -- Folio identificador del pago enviado ++++++ CONSIDERAR EL USUARIO 
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
RETURNING CHAR(5), money(14,2), CHAR (16);
--*******************************************************************************************************
--
-- Objetivo:   SP Consulta Credito Empresarial Transact
-- Autor:     90314722 - Brayam Jair AndrÃ©s ZÃºÃ±iga
-- Fecha:     20/06/2025 - SP para consultar un pago existente en la tabla de bdicheq:sc_movdia
--
--
--*******************************************************************************************************
--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************

   DEFINE vSqlErr INTEGER;
   DEFINE cCodRet CHAR(5);
   DEFINE v_cancelad CHAR(1);
   DEFINE v_importe_ap MONEY(14,2);
   DEFINE v_FolioSUC CHAR(16);
   DEFINE v_tranaplica CHAR(04);
   DEFINE v_referencia CHAR(25);
   DEFINE v_id_moneda CHAR(1);
   DEFINE v_id_cuenta INTEGER;
   DEFINE v_id_usuario INTEGER;
   DEFINE v_MontoTotalMovDia MONEY(14,2);

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************
   LET v_cancelad = '';
   LET vSqlErr = 0;
   LET cCodRet = ''; --11111
   LET v_importe_ap = '';
   LET v_FolioSUC = '';
   LET v_tranaplica = '';
   LET v_referencia = '';

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
			IF vSqlErr = -284 THEN 
				LET cCodRet = '00998';
			ELSE
				let cCodRet = vSqlErr;
				--ROLLBACKWORK;
			END IF;
			RETURN cCodRet,v_importe_ap,v_FolioSUC;
		END IF;
	END EXCEPTION;
	
		
	--****************************************************
	-- Mov. Transact Para el Folio Unico
	--****************************************************	
	IF v_IdConceptoPago = '' OR v_IdConceptoPago IS NULL THEN 
		LET v_folio_suc = '';
	ELSE
		LET v_folio_suc = substr(trim(v_folio_suc),1,8)||trim(v_tipo_prod)||substr(trim(v_num_credito),6);
	END IF;
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
	IF ((v_IdConceptoPago = '' OR v_IdConceptoPago IS NULL) AND v_tipo_prod = '99')THEN 
		LET v_tranaplica = '9005';
		LET v_referencia = 'ABONO DE CREDITO EMP ';
	ELIF (v_IdConceptoPago = '1' AND v_tipo_prod = '99')THEN 
		LET v_tranaplica = '9010';
		LET v_referencia = 'PAGO DE CREDITO EMP ';
	ELIF (v_IdConceptoPago = '2' AND v_tipo_prod = '99')THEN-->Pago IVA de Comision
		LET v_tranaplica = '9008';
		LET v_referencia = 'COBRO DE COMISION EMP ';
	ELIF (v_IdConceptoPago = '3' AND v_tipo_prod = '99')THEN-->Pago de Comision por Incumplimiento
		LET v_tranaplica = '9009';
		LET v_referencia = 'COBRO IVA COMISION EMP';
	ELIF (v_IdConceptoPago = '4' AND v_tipo_prod = '99')THEN-->Pago IVA de Comision por incumplimiento
		LET v_tranaplica = '9008';
		LET v_referencia = 'COBRO DE COMISION EMP ';
	ELIF (v_IdConceptoPago = '5' AND v_tipo_prod = '99')THEN-->Pago IVA de Comision por incumplimiento
		LET v_tranaplica = '9009';
		LET v_referencia = 'COBRO IVA COMISION EMP ';
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
	
	ELIF v_tranaplica = '' OR v_referencia = '' THEN
		LET cCodRet = '00550';	
	
	ELSE
		--************************************
		-- Consulta Pago
		--************************************
		
		LET v_MontoTotalMovDia = 0;
		SELECT DATA_1.monto_tot, DATA_1.folio_suc, DATA_1.cancelad 
		INTO v_MontoTotalMovDia,v_FolioSUC,v_cancelad
		FROM (
		SELECT FIRST 1 monto_tot,folio_suc,cancelad
		FROM bdicheq:'informix'.sc_movdia
		WHERE empresa = '001' 
		AND cuenta = v_num_cuenta 
		AND 
			((v_folio_suc IS NULL OR v_folio_suc = '') AND folio_suc LIKE '%'||TRIM(v_tipo_prod)||SUBSTR(TRIM(v_num_credito), 6)
			OR 
			(v_folio_suc IS NOT NULL AND v_folio_suc <> '' AND folio_suc = v_folio_suc))
		AND 
			((v_folio_suc IS NULL OR v_folio_suc = '') AND monto_tot = v_importe
			OR 
			(v_folio_suc IS NOT NULL AND v_folio_suc <> '' AND monto_tot <= v_importe))
		AND	transacc = v_tranaplica 
		AND	usuautoriza = v_usuario 
		AND	referencia LIKE v_referencia||'%'||v_num_credito||'%'
		ORDER BY cancelad ASC, fech_hor DESC)DATA_1;
		
		--***********************************************************************************************
		-- Valida si ya existe el registro, SI ESTA REVERSADO O SI NO EXISTE
		--***********************************************************************************************
		
		IF v_MontoTotalMovDia = 0 OR v_MontoTotalMovDia IS NULL THEN
			LET cCodRet = '00988';
		ELIF v_MontoTotalMovDia > 0 AND v_cancelad = 'S' THEN
			LET cCodRet = '00988';
			LET v_importe_ap = v_MontoTotalMovDia;
		ELIF v_MontoTotalMovDia > 0 AND v_cancelad <> 'S' THEN
			LET cCodRet = '00000';
			LET v_importe_ap = v_MontoTotalMovDia;	
		END IF;	
	END IF;  
	RETURN cCodRet,v_importe_ap,v_FolioSUC;
END;
END PROCEDURE;