CREATE PROCEDURE "informix".sp_ce_aplicapago(
   v_num_credito   CHAR(20),    -- Numero de credito
   v_num_cuenta    CHAR(20),    -- Numero de cuenta eje
   v_tipo_moneda   INTEGER,     -- Tipo de Moneda  <------- NUEVO
   v_importe      MONEY(14,2),  -- Monto del importe
   v_IdConceptoPago CHAR(1),     -- ID Concepto pago a realizar (Comision, Capital, IVA, etc)
   v_tipo_prod     CHAR(2),     -- Tipo de Producto
   v_usuario      CHAR(8),     -- Usuario
   v_tipo_pago     CHAR(1),     -- Tipo de pago: intento = 0, reintento = 1
   v_folio_suc        CHAR(20)     -- Folio identificador del pago enviado
                           -- considerarse con la nomenclatura siguiente: HH:MM:SS1234567
                           --
                           -- Donde:
                           --
                           -- HH =          Hora de envio (24 horas)
                           -- MM =          Minuto de envio
                           -- SS =          Segundo de envio
                           -- 12345678 =  Numero de credito (relleno con ceros a la izquierda)
                           -- Por ejemplo: 09:19:3200475815
)
RETURNING CHAR(5), money(14,2), CHAR (16);
--*******************************************************************************************************
--
-- Objetivo:   Sp Credito Empresarial-Orion
-- Autor:     Patrica Lopez Linares

-- Fecha:     09/02/2017 - Modificacion para crodito de linea y revolvente.
--
-- Autor:     Gutberto Gomez Guadarrama
-- Fecha:     10/10/2019 - Modificacion para validar que una solicitud haya sido aplicada en central y
--                           no en sistema orion.
--
-- Autor:     Gutberto Gomez Guadarrama
-- Fecha:     07/12/2021 - Modificacion para validar tipo de moneda, se excluye impacto de movimientos
--                           en cuentas eje de central
--
--
-- Autor:     90314722 Brayam Jair AndrÃ©s ZÃºÃ±iga
-- Fecha:     12/03/2025 - Modificacion para validar el folio SUC de transact, se modifica el folio para que sea
--                         unico para el sistema Transact y solo es modificado a este.
--
--
--*******************************************************************************************************
--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************

   DEFINE vSqlErr INTEGER;
   DEFINE cCodRet CHAR(5);

   DEFINE v_sdo_actual MONEY(14,2);
   DEFINE v_importe_ap MONEY(14,2);

   DEFINE v_FolioSUC CHAR(16);
   DEFINE v_fecha_folio CHAR(10);

   DEFINE DCodret_a CHAR(5);
   DEFINE DTranret_c CHAR(4);
   DEFINE DFechoy_c DATE;
   DEFINE DVsdodisp_c MONEY(14,2);
   DEFINE DVmontoret_c MONEY(14,2);

   DEFINE v_tranaplica CHAR(04);
   DEFINE v_referencia CHAR(25);
   DEFINE v_id_pago CHAR(1);
   -->SP:cons_sdos1

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

   DEFINE v_MontoTotalMovDia MONEY(14,2);
   DEFINE v_FlagTipoPago INTEGER;
   -->SP:sp_consulta_limite_sbg
   DEFINE v_cons_lim_sbg_01 CHAR(5);
   DEFINE v_cons_lim_sbg_02 CHAR(20);
   DEFINE v_cons_lim_sbg_03 MONEY(18,2);
   DEFINE v_cons_lim_sbg_04 MONEY(18,2);
   DEFINE v_cons_lim_sbg_05 MONEY(18,2);
   DEFINE v_status_pago CHAR(1);

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************

   LET vSqlErr = 0;
   LET cCodRet = '00000';

   LET v_sdo_actual = '';
   LET v_importe_ap = '';

   LET v_FolioSUC = '';
   LET v_fecha_folio = '';

   LET DCodret_a = '';
   LET DTranret_c = '';
   LET DFechoy_c = '';
   LET DVsdodisp_c = '';
   LET DVmontoret_c = '';

   LET v_tranaplica = '';
   LET v_referencia = '';

   -->SP:cons_sdos1
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

   -->sp_consulta_limite_sbg
   LET v_cons_lim_sbg_01 ='';
   LET v_cons_lim_sbg_02 ='';
   LET v_cons_lim_sbg_03 =0;
   LET v_cons_lim_sbg_04 =0;
   LET v_cons_lim_sbg_05 =0;

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
            RETURN cCodRet,v_importe,v_FolioSUC;
         END IF;
    END EXCEPTION;

    LET v_id_pago = '0';
	
		--****************************************************
		-- Valida si es Mov. Transact Para el Folio Unico
		--****************************************************	
		
	IF (v_tipo_prod = '99') THEN
		LET v_folio_suc = substr(trim(v_folio_suc),1,8)||trim(v_tipo_prod)||substr(trim(v_num_credito),6);
	END IF;	

      --****************************************************
      -- Valida tipo de moneda
      --****************************************************

    SELECT id_pago
    INTO v_id_pago
    FROM 'informix'.sd_ce_tipo_moneda
    WHERE num_tipo_moneda = v_tipo_moneda;

      --******************************************************
      --     Valida el tipo de moneda, se excluyen los indicados
      --******************************************************
    IF v_id_pago = '0' THEN -->(1=MXN, 2=USD)
         LET cCodRet = '00000';
         LET v_importe_ap = v_importe;
    ELSE

            --****************************************************
            -- Valida cuentas eje para identificar si aplica pago
			 --****************************************************
        SELECT status_pago
        INTO v_status_pago
        FROM 'informix'.sd_ce_cuentas_bf
        WHERE num_cta_eje = v_num_cuenta;

            --*****************
            -- No aplica pago
            --*****************
        IF v_status_pago = '0' THEN
               LET cCodRet = '00000';
               LET v_importe_ap = v_importe;

        ELSE
                  --************************************
                  --     Valida si el pago es un reintento
                  --************************************
                  LET v_MontoTotalMovDia = 0;
                  LET v_FlagTipoPago = 0;
            IF v_tipo_pago = 1 THEN
                     SELECT monto_tot
                     INTO v_MontoTotalMovDia
                     FROM bdicheq:'informix'.sc_movdia
                     WHERE empresa='001' AND
                        folio_suc = v_folio_suc AND
						cancelad <> 'S';

                     --***********************************************************************************************
                     --     Valida si ya existe el registro / Se indica bandera para concluir en sistema de empresarial
                     --***********************************************************************************************
                IF v_MontoTotalMovDia IS NOT NULL THEN
                        LET v_FlagTipoPago = 1;
                END IF;
            END IF;
                  --************************************************************************
                  -- Se valida bandera de reintento para identificar si debe aplicarse pago
                  --************************************************************************
            IF v_FlagTipoPago = 0 THEN
                --********************
                -- Consulta de Saldos
                --********************
                CALL bdicheq:cons_sdos1('001',v_num_cuenta,'')
                RETURNING
                v_cons_sdos_01,v_cons_sdos_02,v_cons_sdos_03,v_cons_sdos_04,v_cons_sdos_05,v_cons_sdos_06,v_cons_sdos_07,v_cons_sdos_08,v_cons_sdos_09,v_cons_sdos_10,
                v_cons_sdos_11,v_cons_sdos_12,v_cons_sdos_13,v_cons_sdos_14,v_cons_sdos_15,v_cons_sdos_16,v_cons_sdos_17,v_cons_sdos_18,v_cons_sdos_19,v_cons_sdos_20,
                v_cons_sdos_21,v_cons_sdos_22,v_cons_sdos_23,v_cons_sdos_24;

                LET v_sdo_actual = v_cons_sdos_10;
                IF(v_tipo_prod = '01') THEN
                    --****************************
                    -- Consulta limite sobregiro
                    --****************************
                    CALL bdicheq:sp_consulta_limite_sbg(v_num_cuenta)
                    RETURNING v_cons_lim_sbg_01,v_cons_lim_sbg_02,v_cons_lim_sbg_03,v_cons_lim_sbg_04,v_cons_lim_sbg_05;
                    LET v_sdo_actual = v_sdo_actual+v_cons_lim_sbg_05;
                END IF;
                        --***********************
                        -- Fondos insuficientes
                        --***********************
                IF v_sdo_actual <= 0 THEN
                           LET cCodRet = '00400';
                           LET v_folio_suc='';
                ELSE
                    LET v_importe = v_importe;
                    IF v_importe > v_sdo_actual THEN
                                LET v_importe_ap = v_sdo_actual;
                    ELSE
                                LET v_importe_ap = v_importe;
                    END IF;
                --*************************
                -- Validacion de Productos
                --*************************
					IF (v_tipo_prod = '00' AND v_IdConceptoPago = '1') THEN-->Producto de linea
                                LET v_tranaplica = '0336';
                                LET v_referencia = 'Pago Linea/Credito Emp:';
                        ELIF (v_tipo_prod = '01' AND v_IdConceptoPago = '1')THEN-->Producto Revolvente
                                LET v_tranaplica = '3324';
                                LET v_referencia = 'Pago Capital Revolvente:';
                    END IF;
                              --*****************************
                              -- Asignacion de Transacciones
                              --*****************************
                    IF (v_IdConceptoPago='2' AND v_tipo_prod <> '99' ) THEN-->Pago de Comision
                                    LET v_tranaplica = '3268';
                                    LET v_referencia = 'Com. Linea/Credito Emp:';
                        ELIF (v_IdConceptoPago = '3')THEN-->Pago IVA de Comision
                                    LET v_tranaplica = '0260';
                                    LET v_referencia = 'IVA Linea/Credito Emp:';
                        ELIF (v_IdConceptoPago = '4')THEN-->Pago de Comision por Incumplimiento
                                    LET v_tranaplica = '3268';
                                    LET v_referencia = 'Com. Linea/Credito Emp:';
                        ELIF (v_IdConceptoPago = '5')THEN-->Pago IVA de Comision por incumplimiento
                                    LET v_tranaplica = '0260';
                                    LET v_referencia = 'IVA Linea/Credito Emp:';
                    END IF;
                              --*****************************
                              -- Asignacion de Transacciones (TRANSACT)
                              --*****************************
                    IF (v_tipo_prod = '99') THEN
                        IF (v_IdConceptoPago = '1')THEN 
                                    LET v_tranaplica = '9010';
                                    LET v_referencia = 'PAGO DE CREDITO EMP ';
                        ELIF (v_IdConceptoPago = '2')THEN-->Pago IVA de Comision
                                    LET v_tranaplica = '9008';
                                    LET v_referencia = 'COBRO DE COMISION EMP ';
                        ELIF (v_IdConceptoPago = '3')THEN-->Pago de Comision por Incumplimiento
                                    LET v_tranaplica = '9009';
                                    LET v_referencia = 'COBRO IVA COMISION EMP';
                        ELIF (v_IdConceptoPago = '4')THEN-->Pago IVA de Comision por incumplimiento
                                    LET v_tranaplica = '9008';
                                    LET v_referencia = 'COBRO DE COMISION EMP ';
                        ELIF (v_IdConceptoPago = '5')THEN-->Pago IVA de Comision por incumplimiento
                                    LET v_tranaplica = '9009';
                                    LET v_referencia = 'COBRO IVA COMISION EMP ';
                        END IF;
                    END IF;

                              --*****************************************
							  -- Llamado de sp para aplicar el pago
                              --*****************************************
                            CALL bdicheq:cargo_ref('001','9550',v_usuario,v_tranaplica,'0000',v_folio_suc,v_num_cuenta,0,v_importe_ap,'01',v_referencia||LPAD(TRIM(v_num_credito),12,'0'),'',v_usuario)
                            RETURNING DCodret_a, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;

                            LET cCodRet = LPAD(TRIM(DCodret_a),5,'0');

                              --**********************************************************
                              -- Valida valor de retorno de sp usada para aplicar el pago
                              --**********************************************************
                    IF cCodRet <> '00000' THEN
                        LET v_importe = '0';
                        LET v_importe_ap = v_importe;
                        LET v_folio_suc = '';
                    END IF;
                END IF;
            ELSE
            LET v_importe_ap = v_MontoTotalMovDia;
        END IF;
    END IF ;
END IF ;
      --**********************************************************
      -- Valores de retorno resultado de la ejecucion
      --**********************************************************
	  
    RETURN cCodRet,v_importe_ap,v_folio_suc;
    END;
END PROCEDURE;