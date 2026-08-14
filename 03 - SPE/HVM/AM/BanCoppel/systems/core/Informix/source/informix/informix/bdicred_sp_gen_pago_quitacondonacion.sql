CREATE PROCEDURE "informix".sp_gen_pago_quitacondonacion ()
--EXECUTE PROCEDURE "informix".sp_gen_pago_quitacondonacion();
RETURNING CHAR(5), VARCHAR(90);    

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE cErrorInfo   		VARCHAR(255,1);
DEFINE COD_RET      		CHAR(5);
DEFINE cCodRet2				CHAR(6);
DEFINE cCodRet      	    CHAR(6);
DEFINE cMen_ret 			VARCHAR(100,1);
DEFINE cNumeroFolio 	    CHAR(16);
DEFINE P_MENSAJE		    VARCHAR(90);
DEFINE v_empresa 		    CHAR(3);

DEFINE vNumCredito  	    CHAR(20);
DEFINE vNumCte 			    CHAR(20);
DEFINE vNumProducto         CHAR(4);
DEFINE vIndProc			    CHAR(1);
DEFINE vSucursal            CHAR(4);
DEFINE vFechaHoy            DATE;
DEFINE vCodRetFolio         CHAR(3);

DEFINE vFechaAplicacion     DATE;
DEFINE CodRet               CHAR(5); 
DEFINE g_Remanente			MONEY(14,2);
DEFINE g_IntMoraCob			MONEY(14,2);
DEFINE g_IntVencCob			MONEY(14,2);
DEFINE g_CapVencCob			MONEY(14,2);
DEFINE g_IntVigCob			MONEY(14,2);
DEFINE g_CapVigCob			MONEY(14,2); 
DEFINE g_Impuesto			MONEY(14,2);
DEFINE g_Comision			MONEY(14,2);
DEFINE g_Seguro				MONEY(14,2);
DEFINE cSQL                 CHAR(1000);
DEFINE cParamInsumo			CHAR(100);
DEFINE cParamRepCanMarcaje	CHAR(100);
DEFINE cRutaArch            CHAR(100);
DEFINE cRutaInsumo          CHAR(100);
DEFINE vSdoActual           DECIMAL(18,2);
DEFINE vCodRet              CHAR(5);
DEFINE vMontoPagoDia		DECIMAL(18,2);
DEFINE vTransacc     		CHAR(4);
DEFINE vExiste              SMALLINT;
DEFINE vExisteC             SMALLINT;
DEFINE vFechaCAut           DATE;

DEFINE vSaldoCred			DECIMAL(18,2);
DEFINE vSdoCapVigente		DECIMAL(18,2);
DEFINE vCapVencido			DECIMAL(18,2);
DEFINE vIntVigente			DECIMAL(18,2);
DEFINE vIntVencido			DECIMAL(18,2);
DEFINE vIntMora				DECIMAL(18,2);
DEFINE vIvaIntVig			DECIMAL(18,2); 
DEFINE vIvaIntVencido		DECIMAL(18,2); 
DEFINE vIvaIntMora			DECIMAL(18,2);
DEFINE vPagoTotal           DECIMAL(18,2);
DEFINE vFechaAplica         DATE;
DEFINE vFechaPagoTot        DATE;

DEFINE vCtaCheques			CHAR(20);
DEFINE vPagoRealizar		DECIMAL(18,2); 
DEFINE vPagoQuitaPorc		DECIMAL(18,2); 
DEFINE vFechaLimite  		DATE;
DEFINE vFechaUltPago		DATE;
DEFINE vBandera             CHAR(1);
DEFINE vFechTransac         DATE;
DEFINE vCrdbitacora         CHAR(20);
DEFINE v_indicador          CHAR(1);

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general   
DEFINE csg_codigo_ret			CHAR(6);
DEFINE csg_mensaje_ret			CHAR(80);
DEFINE csg_num_credito			CHAR(20);
DEFINE csg_cod_tipcred			CHAR(2);
DEFINE cStatus					CHAR(2);
DEFINE csg_fec_origen			DATE;
DEFINE csg_fec_prox_pago		DATE;
DEFINE csg_pago_min				MONEY(18,2);
DEFINE csg_fec_ult_pago			DATE;
DEFINE csg_plazo				INTEGER;
DEFINE csg_pagos_realizados		INTEGER;
DEFINE csg_linea_otorgada		MONEY(18,2);
DEFINE csg_tasa_interes			DECIMAL(9,6);
DEFINE csg_tasa_moratorios		DECIMAL(9,6);
DEFINE csg_monto_sbc			DECIMAL(14,2);
DEFINE csg_cap_vig				MONEY(18,2);
DEFINE csg_cap_trans			MONEY(18,2);
DEFINE csg_cap_vdo_exig			MONEY(18,2);
DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
DEFINE csg_sdo_act_total_cap	MONEY(18,2);
DEFINE csg_int_vig				MONEY(18,2);
DEFINE csg_int_vdo				MONEY(18,2);
DEFINE csg_int_moratorios		MONEY(18,2);
DEFINE csg_int_mes				MONEY(18,2);
DEFINE csg_sdo_act_total_int	MONEY(18,2);
DEFINE csg_iva_int_vig			MONEY(18,2);
DEFINE csg_iva_int_vdo			MONEY(18,2);
DEFINE csg_iva_int_moratorios	MONEY(18,2);
DEFINE csg_iva_int_mes			MONEY(18,2);
DEFINE csg_sdo_act_total_iva	MONEY(18,2);
DEFINE csg_com_pend				MONEY(18,2);
DEFINE csg_iva_com				MONEY(18,2);
DEFINE csg_sdo_retenido			MONEY(18,2);
DEFINE csg_tot_liquidacion		MONEY(18,2);
DEFINE csg_int_devengado		MONEY(18,2);
DEFINE csg_iva_int_devengado	MONEY(18,2);
DEFINE csg_linea_disp			MONEY(18,2);
DEFINE csg_pagos_vdos			MONEY(18,2);
DEFINE csg_desc_status_cred		CHAR(60);
DEFINE csg_id_bloqueo_cred		INTEGER;
DEFINE csg_bloqueo_cta			CHAR(60);
DEFINE csg_id_causa_bloq_cred	CHAR(3);
DEFINE csg_causa_bloqueo_cta	CHAR(50);
DEFINE csg_id_sit_esp_cte		CHAR(1);
DEFINE csg_id_causa_esp_cte		INTEGER;
DEFINE csg_sit_esp_cte			CHAR(75);
DEFINE csg_id_sit_esp_cred		CHAR(1);
DEFINE csg_id_causa_esp_cred	INTEGER;
DEFINE csg_sit_esp_cred			CHAR(75);
DEFINE csg_dMoraBase        	DECIMAL(18,2);
DEFINE csg_dMoraCopete     		DECIMAL(18,2);
DEFINE csg_dIvamoraBase     	DECIMAL(18,2);
DEFINE csg_dIvaMoraCopete   	DECIMAL(18,2);
DEFINE g_Folio              	CHAR(16);

--Variables para realizar el cobro automatico del cliente
DEFINE cCodRetAux               CHAR(5);
DEFINE GLOBAL g_TranRet         CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_FechaCargo      DATE           DEFAULT "";
DEFINE GLOBAL g_SdoDisp         DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_MtoRet          DECIMAL(14,2)  DEFAULT 0;
DEFINE cDivisa	                CHAR(2);
DEFINE g_SdoCta                 DECIMAL(14,2);
DEFINE g_StatusCtaCap           CHAR(1);
--DEFINE g_SdoDisp	            DECIMAL(14,2);
--DEFINE g_MtoRet	                DECIMAL(14,2);

DEFINE g_NumCredito             CHAR(20); 
DEFINE g_NumProducto            CHAR(4); 
DEFINE g_NumCte                 CHAR(20); 
DEFINE g_NombreCte              CHAR(150); 
DEFINE g_PagoEfectivo           DECIMAL(18,2);
DEFINE g_PagoCta                DECIMAL(18,2); 
DEFINE g_MontoOperacion         DECIMAL(18,2) ; 
DEFINE g_StatusActual           CHAR(60);

DEFINE g_SdoAnt                 DECIMAL(18,2);    
DEFINE g_IvaCom                 DECIMAL(18,2); 
DEFINE g_IntMora                DECIMAL(18,2); 
DEFINE g_IvaIntMora             DECIMAL(18,2); 
DEFINE g_IntVdo                 DECIMAL(18,2); 
DEFINE g_IvaIntVdo              DECIMAL(18,2); 
DEFINE g_IntOrdi                DECIMAL(18,2); 
DEFINE g_IvaIntOrdi             DECIMAL(18,2); 
DEFINE g_Capital                DECIMAL(18,2); 
DEFINE g_MtoPago                DECIMAL(18,2); 
DEFINE g_CtaEje                 CHAR(20); 
DEFINE g_SdoActual              DECIMAL(18,2); 
DEFINE g_PagoMin                DECIMAL(18,2); 
DEFINE g_FechaLimite            CHAR(17);
DEFINE vDescripcion             CHAR(95);
DEFINE vEstatus                 CHAR(2);
DEFINE wBegin                   CHAR(1);
DEFINE cRuta CHAR (50);


ON EXCEPTION SET iSqlErr	
		LET COD_RET = iSqlErr;
			LET P_MENSAJE = 'Error al ejecutar el proceso.';
			ROLLBACK WORK;
			  IF (wBegin = "S") THEN
				 BEGIN WORK;
			  END IF;
			RETURN COD_RET,P_MENSAJE;
    END EXCEPTION;
    
    ON EXCEPTION IN (-255)
        LET wBegin = "S";
        ROLLBACK WORK;
        BEGIN WORK;
    END EXCEPTION WITH RESUME;
    
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    LET wBegin = "N";
	
	
LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET cErrorInfo      		= "";
LET COD_RET         		= "00000";
LET cMen_ret     			= "";
LET cNumeroFolio            = "";
LET cCodRet2                = '';
LET P_MENSAJE               = 'PROCESO EXITOSO';

LET vNumCredito             = '';
LET vNumCte                 = '';
LET vNumProducto            = '';
LET vIndProc                = '';
LET vSucursal               = '';
--LET vTransaccQuita		    = '';
LET vTransacc        		= '';
LET v_empresa 		        = '001';
LET vFechaHoy               = DATE(1);
LET cCodRet      	        = '';
LET vCodRetFolio            = '';

LET vCodRet					= '';
LET vMontoPagoDia			= 0;
--LET vSucursalDia			= '';
--LET vFolioDia				= '';

--LET vMontoPagoHis			= 0;
--LET vSucursalHis			= '';
--LET vFolioHis				= '';			

LET vSaldoCred			    = 0;
LET vSdoCapVigente			= 0;
LET vCapVencido				= 0;
LET vIntVigente				= 0;
LET vIntVencido			    = 0;
LET vIntMora				= 0;
LET vIvaIntVig				= 0; 
LET vIvaIntVencido			= 0; 
LET vIvaIntMora				= 0;
LET vExiste                 = 0;
LET vExisteC                = 0;
LET vFechaCAut              = '';
LET vPagoTotal              = 0;
LET vFechaAplica            = DATE(1);
LET vFechaPagoTot           = '';

LET vCtaCheques				= '';
LET vPagoRealizar			= 0; 
LET vPagoQuitaPorc			= 0; 
LET vFechaLimite  			= DATE(1);
LET vFechaUltPago			= '';
LET vSdoActual              = 0;
LET vBandera				= '0';
LET vFechTransac            = '';
LET vCrdBitacora            = '';
LET v_indicador             = '0';
LET g_Folio                 = '';
LET g_Remanente             = 0;
LET g_IntMoraCob 			= 0; 
LET g_IntVencCob 			= 0; 
LET g_CapVencCob 			= 0; 
LET g_IntVigCob 			= 0; 
LET g_CapVigCob 			= 0; 
LET g_Impuesto 				= 0; 
LET g_Comision 				= 0; 
LET g_Seguro 				= 0;

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
LET csg_codigo_ret				= "000000";
LET csg_mensaje_ret				= "";
LET csg_num_credito				= "";
LET csg_cod_tipcred				= "";
LET cStatus						= "";
LET csg_fec_origen				= DATE(1);
LET csg_fec_prox_pago			= DATE(1);
LET csg_pago_min				= 0.0;
LET csg_fec_ult_pago			= DATE(1);
LET csg_plazo					= 0;
LET csg_pagos_realizados		= 0;
LET csg_linea_otorgada			= 0.0;
LET csg_tasa_interes			= 0.0;
LET csg_tasa_moratorios			= 0.0;
LET csg_monto_sbc				= 0.0;
LET csg_cap_vig					= 0.0;
LET csg_cap_trans				= 0.0;
LET csg_cap_vdo_exig			= 0.0;
LET csg_cap_vdo_no_exig			= 0.0;
LET csg_sdo_act_total_cap		= 0.0;
LET csg_int_vig					= 0.0;
LET csg_int_vdo					= 0.0;
LET csg_int_moratorios			= 0.0;
LET csg_int_mes					= 0.0;
LET csg_sdo_act_total_int		= 0.0;
LET csg_iva_int_vig				= 0.0;
LET csg_iva_int_vdo				= 0.0;
LET csg_iva_int_moratorios		= 0.0;
LET csg_iva_int_mes				= 0.0;
LET csg_sdo_act_total_iva		= 0.0;
LET csg_com_pend				= 0.0;
LET csg_iva_com					= 0.0;
LET csg_sdo_retenido			= 0.0;
LET csg_tot_liquidacion			= 0.0;
LET csg_int_devengado			= 0.0;
LET csg_iva_int_devengado		= 0.0;
LET csg_linea_disp				= 0.0;
LET csg_pagos_vdos				= 0.0;
LET csg_desc_status_cred		= "";
LET csg_id_bloqueo_cred			= 0;
LET csg_bloqueo_cta				= "";
LET csg_id_causa_bloq_cred		= "";
LET csg_causa_bloqueo_cta		= "";
LET csg_id_sit_esp_cte			= "";
LET csg_id_causa_esp_cte		= 0;
LET csg_sit_esp_cte				= "";
LET csg_id_sit_esp_cred			= "";
LET csg_id_causa_esp_cred		= 0;
LET csg_sit_esp_cred			= "";
LET csg_dMoraBase               = "";
LET csg_dMoraCopete             = "";
LET csg_dIvamoraBase            = "";
LET csg_dIvaMoraCopete          = "";

--Variables para el cargo del pago del cliente a su cuenta de captacion

LET cCodRetAux                  = "00000";
LET cDivisa	                    = '';
LET g_SdoCta	                = 0;
LET g_StatusCtaCap              = '';
--LET g_SdoDisp	                = 0;
--LET g_MtoRet	                = 0;

LET g_NumCredito                = ''; 
LET g_CtaEje                    = ''; 
LET g_NumProducto               = ''; 
LET g_NumCte                    = ''; 
LET g_NombreCte                 = ''; 
LET g_PagoEfectivo              = 0;
LET g_PagoCta                   = 0; 
LET g_MontoOperacion            = 0; 
LET g_SdoActual                 = 0; 
LET g_StatusActual              = '';

LET g_SdoAnt                    = 0;   
LET g_IvaCom                    = 0; 
LET g_IntMora                   = 0; 
LET g_IvaIntMora                = 0; 
LET g_IntVdo                    = 0; 
LET g_IvaIntVdo                 = 0; 
LET g_IntOrdi                   = 0;  
LET g_IvaIntOrdi                = 0;  
LET g_Capital                   = 0;  
LET g_MtoPago                   = 0;    
LET g_PagoMin                   = 0;  
LET g_FechaLimite               = ''; 

LET g_TranRet                   = '';
LET g_FechaCargo                = date(1);
LET g_SdoDisp                   = 0;
LET g_MtoRet                    = 0;
LET vDescripcion                = '';

LET vEstatus                    = 0;
				
BEGIN

    --SET debug FILE TO "/informix/sp_gen_pago_quitacondonacion2.out";
	--TRACE ON;
				
	SELECT fecha_hoy, fecha_hoy + 2 UNITS day, fecha_hoy - 2 UNITS day  INTO vFechaHoy, vFechaCAut, vFechaPagoTot FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;
 	--LET vFechaPagoTot = mdy('08','10','2021'); --dos dias antes
	--LET vFechaHoy = mdy('08','12','2021'); --fecha actual
	--LET vFechaCAut = mdy('08','14','2021'); --dos dias despues																		 
 
	
--Pago de Condonacion y Quita/Castigos	
FOREACH WITH HOLD
--Buscar el credito en la tabla de insumos 
SELECT  fecha_insert,num_producto, a.numcte, a.num_credito, num_cuenta_chq, CASE WHEN indicador_proceso = 'Q' THEN mto_quita ELSE monto_condonado END pago_realizar, porc_quita, fecha_negociacion, a.indicador_proceso, a.estatus_proceso
INTO vFechaAplica, vNumProducto, vNumCte, vNumCredito, vCtaCheques, vPagoRealizar, vPagoQuitaPorc, vFechaLimite, vIndProc, vEstatus
FROM bdicred:"informix".sd_bitacora_quitacondonacion a 
WHERE a.estatus_proceso = 'PR'

BEGIN WORK;
	IF vCtaCheques IS NULL OR vCtaCheques = '' OR vCtaCheques = '0' THEN LET vCtaCheques = ''; END IF;
	    LET vFechaHoy=mdy(MONTH(vFechaHoy),DAY(vFechaHoy),YEAR(vFechaHoy)); --fecha actual
	    LET vFechaLimite=mdy(MONTH(vFechaLimite),DAY(vFechaLimite),YEAR(vFechaLimite)); --fecha negociacion		
	IF vFechaHoy > vFechaLimite THEN
		UPDATE bdicred:"informix".sd_bitacora_quitacondonacion SET estatus_proceso = 'CN', fecha_status = TODAY WHERE 
				num_credito = vNumCredito and estatus_proceso = vEstatus and fecha_insert = vFechaAplica;
		COMMIT WORK;
		CONTINUE FOREACH;
	END IF;

	IF vNumProducto NOT IN ('6300','7600','7700','6011','6800') THEN COMMIT WORK; CONTINUE FOREACH; END IF;
		
	IF vPagoRealizar > 0 AND vFechaHoy <= vFechaLimite THEN --Se aplica el pago de Condonacion o Quita/Castigo
	    --Para conocer si se realiza cobro automatico
		IF vCtaCheques != '' THEN --Si cuenta de cheques tiene saldo para realizar el pago
		  --Busqueda de saldo de cuenta de cliente
            SELECT divisa, sucursal
			INTO cDivisa, vSucursal
			FROM bdicred:"informix".sd_maecredcrd
			WHERE empresa  = '001' 
			AND num_credito = vNumCredito 
			AND num_producto IN ('6300','6800','7600','7700','6011')  
			AND status_cred NOT IN ('FF','FC','CV');
			
			-- Se obtiene el saldo de la cuenta identificada.
			CALL bdicheq:"informix".cons_saldo(vCtaCheques) RETURNING cCodRetAux,g_SdoCta,g_StatusCtaCap;

			IF (TRIM(cCodRetAux) <> "000") THEN
			    COMMIT WORK;
				CONTINUE FOREACH;
			END IF;

			-- Valida el saldo obtenido de la cuenta.
			IF NVL(g_SdoCta,0) <= 0 THEN
			    COMMIT WORK;
				CONTINUE FOREACH;
			END IF;

		   --Se realiza el cobro solo cuando la cuenta de captacion tenga todo el monto completo para realizar el cobro automatico 
            IF g_SdoCta >= vPagoRealizar AND vFechaCAut <=  vFechaLimite THEN 
				--*** Cobro automatico INICIO								
				-- SE GENERA EL FOLIO
				CALL bdicheq:"informix".sp_generafolionomina('CONDONACIONQUITA') RETURNING cCodRetAux, cNumeroFolio;		
				
				--Aplica el pago de Condonacion y Quita
				IF vNumProducto IN ('6300','7600','7700','6800','8100') THEN --Para PP y Prestamo Digital
					LET vTransacc = '620'; --PAGO CON CGO. A CTA. EN VENT. PREST. PERS.					
					EXECUTE PROCEDURE bdicred:sp_principal_suc_rr(v_empresa,vNumCredito,vNumProducto,0,vPagoRealizar,'informix',vSucursal,NVL(cNumeroFolio,''),vTransacc)
					INTO CodRet, P_MENSAJE, g_NumCredito, g_CtaEje, g_NumProducto, g_NumCte, g_NombreCte, g_PagoEfectivo, g_PagoCta, g_MontoOperacion, g_SdoActual, g_StatusActual;
				ELIF vNumProducto IN ('6011') THEN --Para Reestructura	
					LET vTransacc = '620';
					LET vSucursal = '9290';
					EXECUTE PROCEDURE bdicred:sp_principal_suc_rr(v_empresa,vNumCredito,vNumProducto,0,vPagoRealizar,'informix',vSucursal,NVL(cNumeroFolio,''),vTransacc)
					INTO CodRet, P_MENSAJE, g_NumCredito, g_CtaEje, g_NumProducto, g_NumCte, g_NombreCte, g_PagoEfectivo, g_PagoCta, g_MontoOperacion, g_SdoActual, g_StatusActual;
				END IF;

			    --LET CodRet = '00000';
				IF CodRet::INTEGER <> 0	 THEN
				--insertar en bitacora de rechazos
				        LET vDescripcion = CodRet || ' ' ||P_MENSAJE;
				        INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
				        VALUES (vNumCredito, vNumCte, vIndProc, vDescripcion ,TODAY);
						COMMIT WORK;      ---KSOV SE AGREGA COMMIT INC 25 435 
						CONTINUE FOREACH; ---KSOV SE AGREGA CONTINUE FOREARCH INC 25 435 
				    --RETURN COD_RET,P_MENSAJE;--SE COMENTA PARA NO INTERRUMPIR EL FOREACH
				END IF;
			ELSE
--			   LET COD_RET = '00002';
			   LET P_MENSAJE = 'Hubieron cuentas SIN saldo suficiente para realizar el pago';
				INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
					VALUES (vNumCredito, vNumCte, vIndProc, 'La cuenta del cargo NO tiene saldo suficiente para realizar el pago' ,TODAY);
			   COMMIT WORK;
			   CONTINUE FOREACH;
			END IF;
		ELSE
--		   LET COD_RET = '00003';
		   LET P_MENSAJE = 'Hubieron cuentas sin cuenta de captacion asociada';
			INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
				VALUES (vNumCredito, vNumCte, vIndProc, 'El credito no cuenta con una cuenta de captacion asociada' ,TODAY);
			COMMIT WORK;
		   CONTINUE FOREACH;
		END IF;   
  END IF; 
COMMIT WORK;

END FOREACH


RETURN COD_RET,P_MENSAJE;

END
END PROCEDURE;