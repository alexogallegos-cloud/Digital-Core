CREATE PROCEDURE "informix".sp_bts_aplicapagos_cred(pUsuario CHAR(8), pNum_confirmacion CHAR(11), pMonto_destino CHAR(20), pFecha_peticion CHAR(8), pHora_peticion CHAR(6))
RETURNING
CHAR(5)   AS cod_err,   	--Codigo_Error,
CHAR(150) AS desc_error,	--Desc_error, 		 
CHAR(8)   AS fecha_proceso,	--Fecha_proceso,
CHAR(6)   AS hora_proceso;	--Hora_proceso;	

--DEFINICION DE VARIABLES--
DEFINE iSql_err        				INTEGER;
DEFINE iSam_err		   				INTEGER;
DEFINE cCod_err        				CHAR(5);
DEFINE cCod_err2       				CHAR(5);
DEFINE cDesc_error     				CHAR(150);
DEFINE cCadena_ent     				CHAR(100);
DEFINE cHora_sistema   				CHAR(6);
DEFINE cCta_benef      				CHAR(20);
DEFINE cSuc_cargo      				CHAR(4);
DEFINE cCta_pres       				CHAR(20);
DEFINE cCen_cargo 	   				CHAR(4);
DEFINE cCen_abono      				CHAR(4);
DEFINE cFolSuc         				CHAR(16);
DEFINE cPreferencia    				CHAR(40); 
DEFINE cTrandet        				CHAR(4);
DEFINE dFechoy         				DATE;
DEFINE mSdodisp        				MONEY(14,2);
DEFINE mMontoret       				MONEY(14,2);
DEFINE cReferencia2    				CHAR(20);
DEFINE mImpcomconvenio 				MONEY(14,2);
DEFINE mIVAimpconvenio 				MONEY(14,2);
DEFINE mImpcomcte	   				MONEY(14,2);
DEFINE mIVAimpcomcte   				MONEY(14,2);
DEFINE cValor          				CHAR(100);
DEFINE cCategoria      				CHAR(2);
DEFINE cConvenio       				CHAR(3);
DEFINE cBank_ref_nm	   				CHAR(16);
DEFINE cImporte2	   				CHAR(16);
DEFINE cDesc_error2    				CHAR(50);
DEFINE cDesc_error3    				CHAR(150);
DEFINE iTransaccion    				INTEGER;
--------------------------------
DEFINE cNumProducto	   				CHAR (4);
DEFINE cCen_abonocr	   				CHAR (4);
DEFINE cCen_abonocf	   				CHAR (4);
DEFINE mSaldoBTS	   				MONEY(18,2);
DEFINE cCod_Ret_prod   				CHAR(5);
DEFINE cNombre_prod    				CHAR (40);	
-------------------------------- 	/*Valores de retorno del sp_consulta_saldos_general*/
DEFINE cCod_ret_saldos           	CHAR(6);
DEFINE cMsj_ret_saldos           	CHAR(80);
DEFINE cNum_cred_saldos          	CHAR(20);
DEFINE cCod_tipcred_saldos       	CHAR (2);
DEFINE dtFechaOrigen_saldos      	DATE;
DEFINE dtFechaProxPago_saldos    	DATE;
DEFINE dPagoMin_saldos           	DECIMAL(18,2);
DEFINE dtFechaUlt_pago           	DATE;
DEFINE iPlazo_saldos             	INTEGER;
DEFINE iPagos_realizados_saldos  	INTEGER;
DEFINE dLinea_otorgada_saldos    	DECIMAL(18,2);
DEFINE dTasa_interes_saldos		 	DECIMAL(9,6);
DEFINE dTasa_mora_saldos		 	DECIMAL(9,6);
DEFINE dMonto_sbc_saldos		 	DECIMAL(14,2);
DEFINE dCap_vigente_saldos		 	DECIMAL(18,2);
DEFINE dCap_trans_saldos		 	DECIMAL(18,2);
DEFINE dCap_vdo_exig_saldos		 	DECIMAL(18,2);
DEFINE dCap_vdo_no_exig_saldos	 	DECIMAL(18,2);
DEFINE dSaldoact_tot_cap_saldos  	DECIMAL(18,2);
DEFINE dInt_vig_saldos			 	DECIMAL(18,2);
DEFINE dInt_vdo_saldos			 	DECIMAL(18,2);
DEFINE dInt_moratorios_saldos    	DECIMAL(18,2);
DEFINE dInt_mes_saldos			 	DECIMAL(18,2);
DEFINE dSaldoTot_act_int_saldos  	DECIMAL(18,2);
DEFINE dIva_int_vig_saldos		 	DECIMAL(18,2);
DEFINE dIva_int_vdo_saldos		 	DECIMAL(18,2);
DEFINE dIva_intMoratorios_saldos 	DECIMAL(18,2);
DEFINE dIva_intMes_saldos		 	DECIMAL(18,2);
DEFINE dSdoAct_total_iva_saldos	 	DECIMAL(18,2);
DEFINE dCom_pend_saldos			 	DECIMAL(18,2);
DEFINE dIva_com_saldos			 	DECIMAL(18,2);
DEFINE dSdo_retenido_saldos		 	DECIMAL(18,2);
DEFINE dTotal_liquida_saldos	 	DECIMAL(18,2);
DEFINE dInt_devengado_saldos	 	DECIMAL(18,2);
DEFINE dIva_int_devengado_saldos 	DECIMAL(18,2);
DEFINE dLinea_disp_saldos        	DECIMAL(18,2);
DEFINE dPagos_vdos_saldos		 	DECIMAL(18,2);
DEFINE cDesc_status_cred_saldos  	CHAR(60);
DEFINE iId_bloqueo_cred_saldos	 	INTEGER;
DEFINE cBloq_cuenta_saldos		 	CHAR(60);
DEFINE cId_causa_bloqcred_saldos 	CHAR(3);
DEFINE cCausa_bloq_cta_saldos	 	CHAR(50);
DEFINE cId_sit_espcte_saldos	 	CHAR(1);
DEFINE iId_causa_espcte_saldos   	INTEGER;
DEFINE cSit_espcte_saldos   	 	CHAR(75);
DEFINE cId_sit_espcred_saldos    	CHAR(1);
DEFINE iId_causa_espcred_saldos  	INTEGER;
DEFINE cSit_espcred_saldos		 	CHAR(75);
-------------------------------- 	/*Valores de retorno del sp bdicred:"informix".principalrefer.*/
DEFINE cCod_ret_prinrefer   	  	CHAR(5);     -- Codigo de Retorno
DEFINE mRemanente_prinrefer 	  	MONEY(14,2); -- Remanente
DEFINE mInteresmora_cob_prinrefer 	MONEY(14,2); -- Interes Moratorio Cobrado
DEFINE mInteresven_cob_prinrefer  	MONEY(14,2); -- Interes Vencido Cobrado
DEFINE mCapven_cob_prinrefer      	MONEY(14,2); -- Capital Vencido Cobrado
DEFINE mInteresvig_cob_prinrefer  	MONEY(14,2); -- Interes Vigente Cobrado
DEFINE mCapvig_cob_prinrefer      	MONEY(14,2); -- Capital Vigente Cobrado
DEFINE mImpcob_prinrefer          	MONEY(14,2); -- Impuesto Cobrado
DEFINE mComcob_prinrefer          	MONEY(14,2); -- Comisiones Cobradas
DEFINE mSegcob_prinrefer          	MONEY(14,2); -- Seguro Cobrado
-------------------------------- 	/*Valores de retorno del sp bdicred:"informix".sp_principal_suc_rr.*/
DEFINE cCod_Ret_prinsucrr    		CHAR(5); 
DEFINE cMsg_Ret_prinsucrr	 		CHAR(80);    
DEFINE cNum_Cred_prinsucrr   		CHAR(20);	
DEFINE cCta_eje_prinsucrr	 		CHAR(20); 	 
DEFINE cProd_prinsucrr		 		CHAR(40);	 
DEFINE cNum_Cte_prinsucrr	 		CHAR(20);	 
DEFINE cNom_Cte_prinsucrr    		CHAR(150); 	 
DEFINE dPago_Efect_prinsucrr 		DECIMAL(18,2);
DEFINE dPago_Cta_prinsucrr   		DECIMAL(18,2);
DEFINE dMonto_Oper_prinsucrr 		DECIMAL(18,2);
DEFINE dSdo_Act_prinsucrr	 		DECIMAL(18,2);
DEFINE cStatus_Act_prinsucrr 		CHAR(60);
-------------------------------- 	/*sp_consulta_datos_general
DEFINE cCodigo_retorno  			CHAR(6);
DEFINE cMensaje_retorno 			CHAR(80);
DEFINE cNumero_credito  			CHAR(20);
DEFINE cNumero_cliente  			CHAR(20);
DEFINE cNombre_producto 			CHAR(40);
DEFINE cNumero_tarjeta  			CHAR(20);
DEFINE cNombre_cliente  			CHAR(150);
--------------------------------
DEFINE cSucBTS         				CHAR(4);
DEFINE cMonedaOrigen 	  			CHAR(3);
DEFINE mMontoOrigen 	  			MONEY(14,2);
-------------------------------- Variables de validacion de paises permitidos
DEFINE cPaisOrigen            CHAR(3);
DEFINE iCodPais                CHAR(3);
DEFINE iValPais                INTEGER;
--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE mSdoActual		MONEY(14,2); --Monto del saldo actual de la cuenta.
	DEFINE mSdoRetenido     MONEY(14,2); --Monto del saldo retenido de la cuenta.
	DEFINE mSdoCong	        MONEY(14,2); --Monto del saldo congelado de la cuenta.
	DEFINE mSaldoSBC        MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE mImpChqSbg		MONEY(14,2); --Monto del importe de cheques de sobregiro.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.


--INICIALIZACION DE VARIABLES--
LET cPaisOrigen                = '';        
LET iCodPais                = '';    
LET iValPais                = 0;

LET iTransaccion       =  0; 
LET iSql_err           =  0;
LET cImporte2		   = '';
LET iSam_err           =  0;
LET cCod_err           = '00000';
LET cCod_err2          = '00000';
LET cDesc_error 	   = '';
LET cCadena_ent 	   = TRIM(NVL(pUsuario,'NULL'))||"|" 
				         ||TRIM(NVL(pNum_confirmacion,'NULL'))||"|" 
				         ||TRIM(NVL(pFecha_peticion,'NULL'));
LET cHora_sistema      = REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '');
LET cCta_benef         = '';
LET cSuc_cargo         = '';
LET cCta_pres 		   = '';
LET cCen_cargo		   = '';
LET cCen_abono  	   = '';
LET cFolSuc  		   = '';
--LET cPreferencia 	   = 'Pago de Remesa: '||pNum_confirmacion; 
LET cPreferencia 	   = pNum_confirmacion || ' Abono por remesa de BTS'; 
LET cTrandet           = '';
LET dFechoy            = '';
LET mSdodisp           = '';
LET mMontoret		   = '';
LET cReferencia2       = '';
LET mImpcomconvenio    =  0;
LET mIVAimpconvenio    =  0;
LET mImpcomcte         =  0;
LET mIVAimpcomcte      =  0;
LET cValor             = '';
LET cCategoria         = '';
LET cConvenio          = '';
LET cBank_ref_nm   	   = '';
LET cDesc_error2       = '';
LET cDesc_error3       = '';
LET cSucBTS            = '';
--------------------------------
LET cNumProducto = '';
LET cCen_abonocr = '';
LET cCen_abonocf = '';
LET mSaldoBTS = 0;
--------------------------------/*Valores de retorno del sp bdicred:"informix".sp_consulta_saldos_general*/
LET   cCod_ret_saldos           =  		 '';
LET   cMsj_ret_saldos           =  		 '';
LET   cNum_cred_saldos          =  		 '';
LET   cCod_tipcred_saldos       =  		 '';
LET   dtFechaOrigen_saldos      =   DATE(1);
LET   dtFechaProxPago_saldos    =   DATE(1);
LET   dPagoMin_saldos           =   	  0;
LET   dtFechaUlt_pago           =   DATE(1);
LET   iPlazo_saldos             =   	  0;
LET   iPagos_realizados_saldos  =   	  0;
LET   dLinea_otorgada_saldos    =   	  0;
LET   dTasa_interes_saldos		=   	  0;
LET   dTasa_mora_saldos		    =    	  0;
LET   dMonto_sbc_saldos		    =   	  0;
LET   dCap_vigente_saldos		=   	  0;
LET   dCap_trans_saldos		    =   	  0;
LET   dCap_vdo_exig_saldos		=   	  0;
LET   dCap_vdo_no_exig_saldos	=   	  0;
LET   dSaldoact_tot_cap_saldos  =   	  0;
LET   dInt_vig_saldos			=   	  0;
LET   dInt_vdo_saldos			=   	  0;
LET   dInt_moratorios_saldos    =   	  0;
LET   dInt_mes_saldos			=   	  0;
LET   dSaldoTot_act_int_saldos  =   	  0;
LET   dIva_int_vig_saldos		=   	  0;
LET   dIva_int_vdo_saldos		=   	  0;
LET   dIva_intMoratorios_saldos =   	  0;
LET   dIva_intMes_saldos		=   	  0;
LET   dSdoAct_total_iva_saldos	=   	  0;
LET   dCom_pend_saldos			=   	  0;
LET   dIva_com_saldos			=   	  0;
LET   dSdo_retenido_saldos		=   	  0;
LET   dTotal_liquida_saldos	    =   	  0;
LET   dInt_devengado_saldos	    =   	  0;
LET   dIva_int_devengado_saldos =   	  0;
LET   dLinea_disp_saldos        =   	  0;
LET   dPagos_vdos_saldos		=   	  0;
LET   cDesc_status_cred_saldos  =   	 '';
LET   iId_bloqueo_cred_saldos	=   	  0;
LET   cBloq_cuenta_saldos		=   	 '';
LET   cId_causa_bloqcred_saldos =   	 '';
LET   cCausa_bloq_cta_saldos	=   	 '';
LET   cId_sit_espcte_saldos	    =   	 '';
LET   iId_causa_espcte_saldos   =   	  0;
LET   cSit_espcte_saldos   	    =   	 '';
LET   cId_sit_espcred_saldos    =   	 '';
LET   iId_causa_espcred_saldos  =   	  0;
LET   cSit_espcred_saldos		=   	 '';
--------------------------------/*Valores de retorno del sp bdicred:"informix".principalrefer */
LET cCod_ret_prinrefer   	   = '';
LET mRemanente_prinrefer 	   =  0;
LET mInteresmora_cob_prinrefer =  0;
LET mInteresven_cob_prinrefer  =  0;
LET mCapven_cob_prinrefer      =  0;
LET mInteresvig_cob_prinrefer  =  0;
LET mCapvig_cob_prinrefer      =  0;
LET mImpcob_prinrefer          =  0;
LET mComcob_prinrefer          =  0;
LET mSegcob_prinrefer          =  0;

-------------------------------- /*Valores de retorno del sp bdicred:"informix".sp_principal_suc_rr */
LET cCod_Ret_prinsucrr    = '';
LET cMsg_Ret_prinsucrr	  = '';
LET cNum_Cred_prinsucrr   = '';
LET cCta_eje_prinsucrr	  = ''; 
LET cProd_prinsucrr		  = '';
LET cNum_Cte_prinsucrr	  = '';
LET cNom_Cte_prinsucrr    = '';
LET dPago_Efect_prinsucrr =  0;
LET dPago_Cta_prinsucrr   =  0;
LET dMonto_Oper_prinsucrr =  0;
LET dSdo_Act_prinsucrr	  =  0;
LET cStatus_Act_prinsucrr = '';
--------------------------------

--sp_consulta_datos_general
LET cCodigo_retorno  = '000000';
LET cMensaje_retorno = '';
LET cNumero_credito  = '';
LET cNumero_cliente  = '';
LET cNombre_producto = '';
LET cNumero_tarjeta  = '';
LET cNombre_cliente  = '';

	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSdoActual			=0.00;	
	LET mSdoRetenido		=0.00;
	LET mSdoCong			=0.00;
	LET mSaldoSBC   		=0.00;
	LET mImpChqSbg			=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';

-- SET DEBUG FILE TO '/home/c90314234/informix/sp_bts_aplicapagos_cred.out';
-- TRACE ON;

BEGIN
 	ON EXCEPTION SET iSql_err,iSam_err
		IF iSql_err <> 0 THEN
			LET cCod_err = iSql_err; 
			LET cDesc_error = '';
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws
				(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,iSql_err,isam_err, cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;	
			
			SET ISOLATION TO DIRTY READ;
			UPDATE bdisac:"informix".sac_bts_sdep 
			   SET estatus_sdep = '01', intentos_envio = intentos_envio + 1
		     WHERE num_confirmacion = pNum_confirmacion AND estatus_sdep = '02';
			
			EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9251', pUsuario, cFolSuc,'M')
			INTO cCod_err2;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN(-535)
		LET iTransaccion = 1;
	END EXCEPTION WITH resume;	

	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO "informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		     VALUES ('sp_bts_aplicapagos_cred',pFecha_peticion,pHora_peticion,'0','',pUsuario,CURRENT::DATE,cHora_sistema);	
		
		IF NVL(pNum_confirmacion,'') = '' THEN		
			LET cCod_err = '9902';
				
			SELECT NVL(opcode_sd, '')
			INTO cDesc_error 
			FROM bdisac:"informix".sac_bts_catmensajes 
			WHERE agent_trans_type_code = 'PAYC' 
			AND opcode = cCod_err;
			
			IF cDesc_error IS NULL THEN
				LET cDesc_error = 'Código no registrado en catálogo.';
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
		   
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;
		
		
		
		--Validacion pais origen------------------------------------------------
        SELECT cod_pais_origen INTO cPaisOrigen FROM sac_bts_sdep WHERE estatus_sdep = '02' AND num_confirmacion = pNum_confirmacion;
        
        SELECT pais INTO iCodPais FROM sac_paises_permitidos WHERE appbts = cPaisOrigen;
        
        SELECT COUNT(*) INTO iValPais FROM bdinteg:si_paises_remesadoras WHERE id_remesadora = '5' AND id_pais = iCodPais;
        
        IF iValPais = 0 THEN
        
            LET cCod_err = '00001';
            LET cDesc_error = 'Pais restringido';
            
            UPDATE bdisac:"informix".sac_bts_sdep
            SET    estatus_sdep     = '04'
            WHERE  num_confirmacion = pNum_confirmacion
            AND    estatus_sdep     = '02';
            
            EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;  
            
            RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
        
        END IF;

		
		
		--OBTIENE TIPO_CTA_BENEF Y  NUMCTA_BENEF
		SELECT cuenta_benef, cod_moneda_origen, monto_origen
		INTO cCta_benef, cMonedaOrigen, mMontoOrigen
		FROM bdisac:"informix".sac_bts_sdep 
		WHERE num_confirmacion = pNum_confirmacion 
		AND estatus_sdep = '02';
		
		
		--Obtenemos el numero de producto.
		IF LENGTH(cCta_benef) = 16 THEN
		
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_producto ('001', '', cCta_benef)
			INTO cCod_Ret_prod, cNumProducto, cNombre_prod;				
		
			EXECUTE PROCEDURE bdicred: "informix".sp_consulta_datos_general('001','','',cCta_benef,'','','')
			INTO  cCodigo_retorno, cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente;
			
			LET cCta_benef = cNumero_credito;
			
		ELSE
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_producto ('001', cCta_benef, '')
			INTO cCod_Ret_prod, cNumProducto, cNombre_prod;
			
			EXECUTE PROCEDURE bdicred: "informix".sp_consulta_datos_general('001','',cCta_benef,'','','','')
			INTO  cCodigo_retorno, cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente;
		END IF;
		

		IF cCod_Ret_prod <> '00000' OR cCodigo_retorno <> '000000' THEN
			LET cDesc_error = 'Error al obtener numero de producto';
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				   SET estatus_sdep = '01'
				 WHERE num_confirmacion = pNum_confirmacion 
				   AND estatus_sdep = '02';
		
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				INTO cCod_err2;

				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;  	
		END IF;
		
		SELECT valor 
		INTO cValor
		FROM bdisac:"informix".sac_param 
		WHERE empresa = '001'
		AND cod_param = 87018;
		
		LET cCategoria = SUBSTR(TRIM(cValor),1,2);
		LET cConvenio = SUBSTR(TRIM(cValor),3,5);
			
		SELECT cuenta_prestadora, trans_cen_cargo_cliente, trans_suc_cargo, trans_cen_abono_cr, trans_cen_abono_cf		
		INTO cCta_pres, cCen_cargo, cSuc_cargo, cCen_abonocr, cCen_abonocf
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		   
		SELECT  b.folio_suc INTO cBank_ref_nm
		FROM bdisac:"informix".sac_movimientos b 
		WHERE b.numcategoria = cCategoria
		AND b.numconvenio  = cConvenio
		AND b.referencia1  = pNum_confirmacion
		AND b.flag_confirmacion_central  = '1' 
		AND b.flag_confirmacion_sucursal = '1' 
		AND b.status_cancelado = 'N';	
			
		IF cBank_ref_nm IS NOT NULL OR cBank_ref_nm <> '' THEN
			   	LET cCod_err = '9998';
				LET cDesc_error = 'REMESA PAGADA ANTERIORMENTE';				 
		
				UPDATE bdisac:"informix".sac_bts_sdep 
				   SET estatus_sdep = '98'
				 WHERE num_confirmacion = pNum_confirmacion 
				   AND estatus_sdep = '02';		
						
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				   INTO cCod_err2;
				
				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;  
		END IF;	   
		
		
		--VALIDACION DE MONTO MAX ACUMULADO POR CUENTA 
		SELECT valor
		INTO cSucBTS
		FROM bdisac:"informix".sac_param 
		WHERE empresa = '001'
		AND cod_param = 87015;
		
		--Reviso limite de remesas
		EXECUTE PROCEDURE bdisac:"informix".sp_validamontoremesabts_aut(pNum_confirmacion ,cCta_benef, cSucBTS, pMonto_destino, cMonedaOrigen, mMontoOrigen, cNumero_cliente)
		INTO cCod_err, cDesc_error;

		IF cCod_err::INT <> 0 THEN
			
			UPDATE bdisac:"informix".sac_bts_sdep
			SET    estatus_sdep     = '04'
			WHERE  num_confirmacion = pNum_confirmacion
			AND    estatus_sdep     = '02';

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		
		END IF;
		------
	
	-- 95347142 1040 3004
		--LET cFolSuc = TRIM(pUsuario)||SUBSTR(TRIM(cHora_sistema),1,6);quito yury
		LET cFolSuc = 'btstd'||pNum_confirmacion;
		--sys_bts

		--Validamos el saldo de la cuenta concentradora de BTS. Debe ser mayor al monto del pago de la remesa.
		--RQM 09 704.Se agrega la variable de saldo inmovilizado para el calculo del saldo disponible.
			SELECT sdo_actual,sdo_retenido,sdo_cong,imp_chq_sbg,saldo_sbc
			INTO mSdoActual,mSdoRetenido,mSdoCong,mImpChqSbg,mSaldoSBC
				FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr, bdinteg:"informix".si_divisas di 
			WHERE mc.empresa = '001' 
			AND mc.cuenta = cCta_pres
			AND pr.empresa = mc.empresa 
			AND pr.producto = mc.producto
			AND di.empresa = pr.empresa 
			AND di.divisa = pr.divisa;
		
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
		EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,mImpChqSbg,0.00,0.00,'F',1) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSaldoBTS;        
		
		
		--En caso de no haber saldo suficiente en la cuenta concentradora de BTS se procede a registrar el error.
			IF mSaldoBTS <=  pMonto_destino::MONEY THEN
				LET cCod_err = '9997';
				LET cDesc_error = 'Saldo insuficiente en cuenta concentradora BTS.';
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				   SET estatus_sdep = '01'
				 WHERE num_confirmacion = pNum_confirmacion 
				   AND estatus_sdep = '02';
		
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				INTO cCod_err2;

				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;  				
				
			END IF;
			
		--En caso de no haber error al validar el saldo de la cuenta concentradora de BTS continuamos con el calculo de comisiones.
		EXECUTE PROCEDURE bdisac:"informix".sp_calcula_comisiones(cCategoria,cConvenio,pMonto_destino)
		INTO cCod_err, mImpcomconvenio, mIVAimpconvenio, mImpcomcte, mIVAimpcomcte;

		IF cCod_err::INT <> 0 THEN			
			LET cDesc_error = 'Error al momento de calcular las comisiones';

				UPDATE bdisac:"informix".sac_bts_sdep 
				   SET estatus_sdep = '01'
				 WHERE num_confirmacion = pNum_confirmacion 
				   AND estatus_sdep = '02';
		
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			   INTO cCod_err2;

			 RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;  
		END IF;

		EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001','9251', pUsuario,cCen_cargo,cSuc_cargo,cFolSuc,cCta_pres,0, pMonto_destino,'01',cPreferencia,'','')
		   INTO cCod_err, cTrandet, dFechoy, mSdodisp, mMontoret;		
			
		IF cCod_err::INT <> 0 THEN			
			LET cDesc_error = 'Error al momento de realizar el cargo en cuenta';			
			
			IF cCod_err::INT < 0 THEN
				--LET cDesc_error2 = 'Error en cargo_ref informix';
				--LET cDesc_error3 = 'El registro no se actualizo '|| pNum_confirmacion;
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				   SET estatus_sdep = '01', intentos_envio = intentos_envio + 1
				 WHERE num_confirmacion = pNum_confirmacion 
				   AND estatus_sdep = '02';	
				   
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9251', pUsuario, cFolSuc,'M')
				   INTO cCod_err2;	
			   
				IF iTransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF   
	   
			ELSE
				--LET cDesc_error2 = 'Error al realizar el cargo_ref';
				--LET cDesc_error3 = 'No se actualizó el status a 04 cargo_ref '||pNum_confirmacion ;
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				   SET estatus_sdep = '04', intentos_envio = 0
				 WHERE num_confirmacion = pNum_confirmacion 
				   AND estatus_sdep = '02';
				   
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9251', pUsuario, cFolSuc,'M')
    			   INTO cCod_err2;	
			   
			END IF;			
						
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			   INTO cCod_err2;
			
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion; 
		END IF;	
					
		--Si el producto pertenece al tipo "prestamo personal" validar que el monto del prÃ©stamo personal (adeudo) sea menor o igual al pago de remesa que se quiere realizar. Si esto no se cumple, rechazar el pago.
		IF	(cNumProducto = '6011' OR cNumProducto = '6300' OR cNumProducto = '6400' OR cNumProducto = '7600' OR cNumProducto = '7700') THEN
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general ('001', cCta_benef)
			INTO -- TOMAR SOLAMENTE EL CAMPO total_liquidacion 'total_liquidacion' (CAMPO #33: dTotal_liquida_saldos )
			cCod_ret_saldos, cMsj_ret_saldos, cNum_cred_saldos, cCod_tipcred_saldos, dtFechaOrigen_saldos, dtFechaProxPago_saldos, dPagoMin_saldos, dtFechaUlt_pago, iPlazo_saldos, iPagos_realizados_saldos, dLinea_otorgada_saldos, dTasa_interes_saldos, dTasa_mora_saldos, dMonto_sbc_saldos, dCap_vigente_saldos, dCap_trans_saldos, dCap_vdo_exig_saldos, dCap_vdo_no_exig_saldos, dSaldoact_tot_cap_saldos, dInt_vig_saldos, dInt_vdo_saldos, dInt_moratorios_saldos, dInt_mes_saldos, dSaldoTot_act_int_saldos, dIva_int_vig_saldos, dIva_int_vdo_saldos, dIva_intMoratorios_saldos, dIva_intMes_saldos, dSdoAct_total_iva_saldos,dCom_pend_saldos, dIva_com_saldos, dSdo_retenido_saldos, dTotal_liquida_saldos, dInt_devengado_saldos, dIva_int_devengado_saldos, dLinea_disp_saldos, dPagos_vdos_saldos, cDesc_status_cred_saldos, iId_bloqueo_cred_saldos, cBloq_cuenta_saldos, cId_causa_bloqcred_saldos, cCausa_bloq_cta_saldos, cId_sit_espcte_saldos, iId_causa_espcte_saldos, cSit_espcte_saldos, cId_sit_espcred_saldos, iId_causa_espcred_saldos, cSit_espcred_saldos;
			
			IF pMonto_destino > dTotal_liquida_saldos  THEN
				LET cCod_err = '9997';
				LET cDesc_error = 'Error: monto de remesa mayor que adeudo de prÃ©stamo.';
							
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET estatus_sdep = '04'
				WHERE num_confirmacion = pNum_confirmacion 
				AND estatus_sdep = '02';
				
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9251', pUsuario, cFolSuc,'M')
				INTO cCod_err2;	
				   
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				INTO cCod_err2;

				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
			
			END IF;		
		END IF;
		
		--Si es un producto de credito revolvente se manda llamar el sp bdicred:"informix".principalrefer.
		IF (cNumProducto = '6001' OR cNumProducto = '6600' OR cNumProducto = '7000') THEN
			EXECUTE PROCEDURE bdicred:"informix".principalrefer('001', cCta_benef, 1, cNumero_tarjeta, pUsuario, '9251', cFolSuc,cCen_abonocr, dMonto_sbc_saldos, pMonto_destino, cPreferencia)
			INTO cCod_ret_prinrefer, mRemanente_prinrefer, mInteresmora_cob_prinrefer, mInteresven_cob_prinrefer, mCapven_cob_prinrefer, mInteresvig_cob_prinrefer,mCapvig_cob_prinrefer, mImpcob_prinrefer, mComcob_prinrefer, mSegcob_prinrefer;
			
				--IF cCod_ret_prinrefer <> '000' THEN
				IF cCod_ret_prinrefer::INT <> 0 THEN				
					LET cDesc_error = 'Error al momento de realizar el abono';
					LET cCod_err = cCod_ret_prinrefer;
					
					IF cCod_ret_prinrefer::INT < 0 THEN
					
						EXECUTE PROCEDURE bdicred:"informix".reversion ('001', '9251', pUsuario, cFolSuc,'M')
						INTO cCod_err2;
					
						EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9251', pUsuario, cFolSuc,'M')
						INTO cCod_err2;
						
						UPDATE bdisac:"informix".sac_bts_sdep 
						SET estatus_sdep = '01', intentos_envio = intentos_envio + 1 
						WHERE num_confirmacion = pNum_confirmacion 
						AND estatus_sdep = '02';
						
					ELSE
						
						EXECUTE PROCEDURE bdicred:"informix".reversion ('001', '9251', pUsuario, cFolSuc,'M')
						INTO cCod_err2;
					
						EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9251', pUsuario, cFolSuc,'M')
						INTO cCod_err2;
						
						UPDATE bdisac:"informix".sac_bts_sdep 
						SET estatus_sdep = '04', intentos_envio = 0
						WHERE num_confirmacion = pNum_confirmacion 
						AND estatus_sdep = '02';
						
					END IF;
						
					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws (1,'sp_bts_aplicapagos_cred', cCod_ret_prinrefer, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
					INTO cCod_err2;											
										
					RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;					
					
				END IF;
				
			LET cCen_abono = cCen_abonocr;
			
		--Si es un producto de crédito fijo se manda llamar el sp bdicred:"informix".sp_principal_suc_rr.
		ELIF (cNumProducto = '6011' OR cNumProducto = '6300' OR cNumProducto = '6400' OR cNumProducto = '7600' OR cNumProducto = '7700') THEN
			EXECUTE PROCEDURE bdicred:"informix".sp_principal_suc_rr ('001', cCta_benef, cNumProducto, pMonto_destino::DECIMAL(18,2), 0, pUsuario,'9251', cFolSuc, cCen_abonocf)
			INTO cCod_Ret_prinsucrr, cMsg_Ret_prinsucrr, cNum_Cred_prinsucrr, cCta_eje_prinsucrr, cProd_prinsucrr, cNum_Cte_prinsucrr, cNom_Cte_prinsucrr,dPago_Efect_prinsucrr, dPago_Cta_prinsucrr, dMonto_Oper_prinsucrr, dSdo_Act_prinsucrr, cStatus_Act_prinsucrr;
			
			IF cCod_Ret_prinsucrr::INTEGER <> 0 THEN
				LET cDesc_error = 'Error al momento de realizar el abono';
				LET cCod_err = cCod_Ret_prinsucrr;
			
				IF cCod_Ret_prinsucrr::INTEGER < 0 THEN
						
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd ('001', '9251', pUsuario, cFolSuc,'M')
					INTO cCod_err2;
					
					EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9251', pUsuario, cFolSuc,'M')
					INTO cCod_err2;
					
					UPDATE bdisac:"informix".sac_bts_sdep 
					SET estatus_sdep = '01', intentos_envio = intentos_envio + 1 
					WHERE num_confirmacion = pNum_confirmacion 
					AND estatus_sdep = '02';
					
				ELSE
					
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd ('001', '9251', pUsuario, cFolSuc,'M')
					INTO cCod_err2;
					
					EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9251', pUsuario, cFolSuc,'M')
					INTO cCod_err2;
					
					UPDATE bdisac:"informix".sac_bts_sdep 
					SET estatus_sdep = '04', intentos_envio = 0
					WHERE num_confirmacion = pNum_confirmacion 
					AND estatus_sdep = '02';
					
				END IF;
					
					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_Ret_prinsucrr, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
					INTO cCod_err2;																
										
					RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
					
			END IF;
			
			LET cCen_abono = cCen_abonocf;
			
		END IF;
		
		
		LET cReferencia2 = SUBSTR(pNum_confirmacion,11,1);

		EXECUTE PROCEDURE bdisac:"informix".sp_grabapagoservicio('9251',cCategoria,cConvenio,pNum_confirmacion, cReferencia2, '5',pMonto_destino,mImpcomconvenio,mIVAimpconvenio,mImpcomcte,mIVAimpcomcte,cCta_pres, pUsuario, cFolSuc,cCen_abono,CURRENT::DATE)
		INTO cCod_err;
		
		IF cCod_err::INT <> 0 THEN
			LET cDesc_error = 'Error al momento de grabar en servicios';					
			
			IF cCod_err::INT < 0 THEN
				--LET cDesc_error2 = 'Error en servicios informix';
				--LET cDesc_error3 = 'No se actualizó el status a 01 '||pNum_confirmacion;
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				   SET estatus_sdep = '01', intentos_envio = intentos_envio + 1
				 WHERE num_confirmacion = pNum_confirmacion 
				   AND estatus_sdep = '02';	
			ELSE
				--LET cDesc_error2 = 'Error al momento de grabar en servicios';
				--LET cDesc_error3 = 'No se actualizó el status a 04 '||pNum_confirmacion;
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				   SET estatus_sdep = '04', intentos_envio = 0
				WHERE num_confirmacion = pNum_confirmacion AND estatus_sdep = '02';	
			END IF;			
			
			IF	(cNumProducto = '6011' OR cNumProducto = '6300' OR cNumProducto = '6400' OR cNumProducto = '7600' OR cNumProducto = '7700') THEN					
				EXECUTE PROCEDURE bdicred:"informix".reversion ('001', '9251', pUsuario, cFolSuc,'M')
				INTO cCod_err2;
			ELSE
				EXECUTE PROCEDURE bdicred:"informix".reversioncrd ('001', '9251', pUsuario, cFolSuc,'M')
				INTO cCod_err2;
			END IF;
			
			EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9251', pUsuario, cFolSuc,'M')
			   INTO cCod_err2;
			   
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			   INTO cCod_err2;
			   
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;
		LET cDesc_error = 'Confirmación PAYC exitosa';
			
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,'sp_bts_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
		   INTO cCod_err;	
		
		--LET cDesc_error2  = 'Error al confirmar PAYC exitosa informix';
		--LET cDesc_error3  = 'No se actualizó el status a 03 '||pNum_confirmacion;		

		UPDATE bdisac:"informix".sac_bts_sdep 
		   SET estatus_sdep = '03', intentos_envio = 0
		 WHERE num_confirmacion = pNum_confirmacion 
		   AND estatus_sdep = '02';		
		   
		LET cImporte2 = TRIM (TO_CHAR(pMonto_destino,"###,###,###,###.##"));
		--ACTIVAR AL LIBERAR
		CALL bdimnsj:"informix".sp_registra_evento ('2' , 'BTS_ACTAS', '', cCta_benef, '' , '1', 
			 cCta_benef, cFolSuc, 'PAGO DE REMESA DE BTS', cImporte2, '', '', '', '', '', '', '', '',  -- strings
			 pMonto_destino, '','', '', '', CURRENT, '') RETURNING cCod_err2;						   -- importes
		RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;

 END
 END PROCEDURE
DOCUMENT
'AUTOR: 96273763 - Antonio Cebreros Perez',
'FOLIO: 230142 - 32  - PagoBTSAbnoAutCtasCred',
'DESCRIPCION: Procedimiento que realiza cargo en cuenta concentradora de BTS y abona a los crÃ©ditos del cliente.',
'FECHA: 07/03/2016',
'BD: bdisac',
'MODIFICADO:  - Daniel Hernandez Garcia, Osiel Camacho',
'FOLIO: RQM 09 704 Cobranza automatica en cuentas de captacion',
'DESCRIPCION: En el saldo disponible de la cuenta concentradora se agerga el saldo sbc por medio del sp de consulta saldos por tipo',
'FECHA: 08/07/2025',
'BD: bdisac'
;

CREATE PROCEDURE "informix".sp_app_aplicapagos_cred(pUsuario CHAR(8), pUniqueReferenceNumber CHAR(12), pMonto_destino CHAR(20), pFecha_peticion CHAR(8), pHora_peticion CHAR(6))
RETURNING
CHAR(5)   AS cod_err,
CHAR(150) AS desc_error,
CHAR(8)   AS fecha_proceso,
CHAR(6)   AS hora_proceso;

--DEFINICION DE VARIABLES--
DEFINE iSql_err        				INTEGER;
DEFINE iSam_err		   				INTEGER;
DEFINE cCod_err        				CHAR(5);
DEFINE cCod_err2       				CHAR(5);
DEFINE cDesc_error     				CHAR(150);
DEFINE cCadena_ent     				CHAR(100);
DEFINE cHora_sistema   				CHAR(6);
DEFINE cCta_benef      				CHAR(20);
DEFINE cSuc_cargo      				CHAR(4);
DEFINE cCta_pres       				CHAR(20);
DEFINE cCen_cargo 	   				CHAR(4);
DEFINE cCen_abono      				CHAR(4);
DEFINE cFolSuc         				CHAR(16);
DEFINE cPreferencia    				CHAR(40);
DEFINE cTrandet        				CHAR(4);
DEFINE dFechoy         				DATE;
DEFINE mSdodisp        				MONEY(14,2);
DEFINE mMontoret       				MONEY(14,2);
DEFINE cReferencia2    				CHAR(20);
DEFINE mImpcomconvenio 				MONEY(14,2);
DEFINE mIVAimpconvenio 				MONEY(14,2);
DEFINE mImpcomcte	   				MONEY(14,2);
DEFINE mIVAimpcomcte   				MONEY(14,2);
DEFINE cCategoria      				CHAR(2);
DEFINE cConvenio       				CHAR(3);
DEFINE cBank_ref_nm	   				CHAR(16);
DEFINE cImporte2	   				CHAR(16);
DEFINE iTransaccion    				INTEGER;
--------------------------------
DEFINE cNumProducto	   				CHAR (4);
DEFINE cCen_abonocr	   				CHAR (4);
DEFINE cCen_abonocf	   				CHAR (4);
DEFINE mSaldoAPP	   				MONEY (18,2);
DEFINE cCod_Ret_prod   				CHAR(5);
DEFINE cNombre_prod    				CHAR (40);
-------------------------------- /*Valores de retorno del sp_consulta_saldos_general*/
DEFINE dMonto_sbc_saldos		 	DECIMAL(14,2);
DEFINE dTotal_liquida_saldos	 	DECIMAL(18,2);
-------------------------------- /*Valores de retorno del sp bdicred:"informix".principalrefer.*/
DEFINE cCod_ret_prinrefer   	  	CHAR(5);     -- Codigo de Retorno
DEFINE mRemanente_prinrefer 	  	MONEY(14,2); -- Remanente
DEFINE mInteresmora_cob_prinrefer 	MONEY(14,2); -- Interes Moratorio Cobrado
DEFINE mInteresven_cob_prinrefer  	MONEY(14,2); -- Interes Vencido Cobrado
DEFINE mCapven_cob_prinrefer      	MONEY(14,2); -- Capital Vencido Cobrado
DEFINE mInteresvig_cob_prinrefer  	MONEY(14,2); -- Interes Vigente Cobrado
DEFINE mCapvig_cob_prinrefer      	MONEY(14,2); -- Capital Vigente Cobrado
DEFINE mImpcob_prinrefer          	MONEY(14,2); -- Impuesto Cobrado
DEFINE mComcob_prinrefer          	MONEY(14,2); -- Comisiones Cobradas
DEFINE mSegcob_prinrefer          	MONEY(14,2); -- Seguro Cobrado

-------------------------------- /*Valores de retorno del sp bdicred:"informix".sp_principal_suc_rr.*/
DEFINE cCod_Ret_prinsucrr    		CHAR(5);
DEFINE cMsg_Ret_prinsucrr	 		CHAR(80);    
DEFINE cNum_Cred_prinsucrr   		CHAR(20);	
DEFINE cCta_eje_prinsucrr	 		CHAR(20); 	 
DEFINE cProd_prinsucrr		 		CHAR(40);	 
DEFINE cNum_Cte_prinsucrr	 		CHAR(20);	 
DEFINE cNom_Cte_prinsucrr    		CHAR(150); 	 
DEFINE dPago_Efect_prinsucrr 		DECIMAL(18,2);
DEFINE dPago_Cta_prinsucrr   		DECIMAL(18,2);
DEFINE dMonto_Oper_prinsucrr 		DECIMAL(18,2);
DEFINE dSdo_Act_prinsucrr	 		DECIMAL(18,2);
DEFINE cStatus_Act_prinsucrr 		CHAR(60);
--sp_consulta_datos_general
DEFINE cCodigo_retorno  			CHAR(6);
DEFINE cMensaje_retorno 			CHAR(80);
DEFINE cNumero_credito  			CHAR(20);
DEFINE cNumero_cliente  			CHAR(20);
DEFINE cNombre_producto 			CHAR(40);
DEFINE cNumero_tarjeta  			CHAR(20);
DEFINE cNombre_cliente  			CHAR(150);
--------------------------------
DEFINE cSucAPP         				CHAR(4);
DEFINE cMonedaOrigen 	  			CHAR(3);
DEFINE mMontoOrigen 	  			MONEY(14,2);
DEFINE cValor          				CHAR(100);

DEFINE iSecuencia					INTEGER;

DEFINE cPaisOrigen			CHAR(3);
DEFINE iCodPais				CHAR(3);
DEFINE iValPais				INTEGER;
--RQM 09 704.Se definen las variables requeridas para la consulta del saldo disponible.DHG
	DEFINE mSdoActual		MONEY(14,2); --Monto del saldo actual de la cuenta.
	DEFINE mSdoRetenido     MONEY(14,2); --Monto del saldo retenido de la cuenta.
	DEFINE mSdoCong	        MONEY(14,2); --Monto del saldo congelado de la cuenta.
	DEFINE mSaldoSBC        MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE mImpChqSbg		MONEY(14,2); --Monto del importe de cheques de sobregiro.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.


--INICIALIZACION DE VARIABLES--
LET iTransaccion       				= 0; 
LET iSql_err           				= 0;
LET cImporte2		   				= '';
LET iSam_err           				= 0;
LET cCod_err           				= '00000';
LET cCod_err2          				= '00000';
LET cDesc_error 	   				= '';
LET cCadena_ent 	   				= TRIM(NVL(pUsuario,'NULL'))||"|" 
										||TRIM(NVL(pUniqueReferenceNumber,'NULL'))||"|" 
										||TRIM(NVL(pFecha_peticion,'NULL'));
LET cHora_sistema      				= REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCta_benef         				= '';
LET cSuc_cargo         				= '';
LET cCta_pres 		   				= '';
LET cCen_cargo		   				= '';
LET cCen_abono  	   				= '';
LET cFolSuc  		   				= '';
LET cPreferencia 	   				= pUniqueReferenceNumber || ' Abono por remesa de APPRIZA'; 
LET cTrandet           				= '';
LET dFechoy            				= '';
LET mSdodisp           				= '';
LET mMontoret		   				= '';
LET cReferencia2       				= '';
LET mImpcomconvenio    				= 0;
LET mIVAimpconvenio    				= 0;
LET mImpcomcte         				= 0;
LET mIVAimpcomcte      				= 0;
LET cCategoria         				= '';
LET cConvenio          				= '';
LET cBank_ref_nm   	   				= '';
LET cSucAPP            				= '';
LET mMontoOrigen 			 		= 0;
--------------------------------
LET cNumProducto 					= '';
LET cCen_abonocr 					= '';
LET cCen_abonocf 					= '';
LET mSaldoAPP 	 					= 0;

--------------------------------/*Valores de retorno del sp bdicred:"informix".sp_consulta_saldos_general*/
LET   dMonto_sbc_saldos		    	= 0;
LET   dTotal_liquida_saldos	    	= 0;
--------------------------------/*Valores de retorno del sp bdicred:"informix".principalrefer */
LET cCod_ret_prinrefer   	   		= '';
LET mRemanente_prinrefer 	   		= 0;
LET mInteresmora_cob_prinrefer 		= 0;
LET mInteresven_cob_prinrefer  		= 0;
LET mCapven_cob_prinrefer      		= 0;
LET mInteresvig_cob_prinrefer  		= 0;
LET mCapvig_cob_prinrefer      		= 0;
LET mImpcob_prinrefer          		= 0;
LET mComcob_prinrefer          		= 0;
LET mSegcob_prinrefer          		= 0;
-------------------------------- /*Valores de retorno del sp bdicred:"informix".sp_principal_suc_rr */
LET cCod_Ret_prinsucrr    			= '';
LET cMsg_Ret_prinsucrr	  			= '';
LET cNum_Cred_prinsucrr   			= '';
LET cCta_eje_prinsucrr	  			= ''; 
LET cProd_prinsucrr		  			= '';
LET cNum_Cte_prinsucrr	  			= '';
LET cNom_Cte_prinsucrr    			= '';
LET dPago_Efect_prinsucrr 			= 0;
LET dPago_Cta_prinsucrr   			= 0;
LET dMonto_Oper_prinsucrr 			= 0;
LET dSdo_Act_prinsucrr	  			= 0;
LET cStatus_Act_prinsucrr 			= '';
--------------------------------
--sp_consulta_datos_general
LET cCodigo_retorno  				= '000000';
LET cMensaje_retorno 				= '';
LET cNumero_credito  				= '';
LET cNumero_cliente  				= '';
LET cNombre_producto 				= '';
LET cNumero_tarjeta  				= '';
LET cNombre_cliente  				= '';
LET cValor             				= '';

LET cPaisOrigen						= '';		
LET iCodPais						= '';	
LET iValPais						= 0;

LET iSecuencia						= 0;

	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSdoActual			=0.00;	
	LET mSdoRetenido		=0.00;
	LET mSdoCong			=0.00;
	LET mSaldoSBC   		=0.00;
	LET mImpChqSbg			=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';

--SET DEBUG FILE TO '/home/c90314234/informix/sp_app_aplicapagos_cred.out';
--	TRACE ON;


BEGIN
 	ON EXCEPTION SET iSql_err,iSam_err
		IF iSql_err <> 0 THEN
			LET cCod_err = iSql_err; 
			LET cDesc_error = '';
			
			IF iSql_err = -284 THEN
				SELECT COUNT(*)
				INTO   iSecuencia
				FROM   bdisac:"informix".sac_app_getorder  
				WHERE  uniquereferencenumber = pUniqueReferenceNumber 
				AND    estatus_getorder      = '02';
			
				IF iSecuencia > 1 THEN

					LET iSecuencia = 0;
					
					SELECT MAX(ROWID) secuencia
					INTO   iSecuencia
					FROM   bdisac:"informix".sac_app_getorder  
					WHERE  uniquereferencenumber = pUniqueReferenceNumber 
					AND    estatus_getorder      = '02';

					UPDATE bdisac:"informix".sac_app_getorder  SET estatus_getorder='09' 
					WHERE  uniquereferencenumber = pUniqueReferenceNumber  
					  AND  estatus_getorder      = '02' 
					  AND rowid <> iSecuencia;

					UPDATE bdisac:"informix".sac_app_getorder  SET estatus_getorder='01', intentos_envio = '1'
					WHERE  uniquereferencenumber = pUniqueReferenceNumber  
					  AND  estatus_getorder      = '02' 
					  AND rowid = iSecuencia;
				END IF;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws
				(1,'sp_app_aplicapagos_cred', cCod_err, cDesc_error, iSql_err, isam_err, cCadena_ent, pUsuario, pFecha_peticion, pHora_peticion)
			INTO cCod_err2;	
			
			SET ISOLATION TO DIRTY READ;
			UPDATE bdisac:"informix".sac_app_getorder 
			   SET estatus_getorder = '01', intentos_envio = intentos_envio + 1
		     WHERE uniquereferencenumber = pUniqueReferenceNumber AND estatus_getorder = '02';
			
			EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
			INTO cCod_err2;
						
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN(-535)
		LET iTransaccion = 1;
	END EXCEPTION WITH resume;	

	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		--REGISTRA INICIO DEL PROCESO		
		--INSERT INTO "informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		--     VALUES ('sp_app_aplicapagos_cred',pFecha_peticion,pHora_peticion,'0','',pUsuario,CURRENT::DATE,cHora_sistema);	


		--VALIDA REFERENCIA (NUMERO DE REMESA)	
		IF NVL(pUniqueReferenceNumber,'') = '' THEN		
			LET cCod_err = '9902';
				
			SELECT NVL(opcode_sd, '')
			INTO cDesc_error 
			FROM bdisac:"informix".sac_app_cat_mensajes
			WHERE agent_trans_type_code = 'PAYC' 
			AND opcode = cCod_err;
			
			IF cDesc_error IS NULL THEN
				LET cDesc_error = 'Codigo No Registrado En Catalogo.';
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
		   
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;

		--Validacion paises permitidos
		select countrycodebranch into cPaisOrigen from sac_app_getorder where estatus_getorder = '02' and uniquereferencenumber = pUniqueReferenceNumber;
		
		select pais into iCodPais from sac_paises_permitidos where appbts = cPaisOrigen;
		
		select count(*) into iValPais from bdinteg:si_paises_remesadoras where id_remesadora = '4' and id_pais = iCodPais;
		
		if iValPais = 0 THEN
		
			LET cCod_err = '00001';
			LET cDesc_error = 'Pais restringido';
			
			UPDATE bdisac:"informix".sac_app_getorder
			SET    estatus_getorder      = '04'
			WHERE  uniquereferencenumber = pUniqueReferenceNumber 
			AND    estatus_getorder      = '02';

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
			
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		
		end if;
		
		--OBTIENE TIPO_CTA_BENEF Y  NUMCTA_BENEF
		SELECT accountnumbersenderpay,currencycodeorigin,originamount
		INTO cCta_benef,cMonedaOrigen,mMontoOrigen
		FROM bdisac:"informix".sac_app_getorder
		WHERE uniquereferencenumber = pUniqueReferenceNumber
		AND estatus_getorder = '02';
		

		--OBTIENE DATOS GRALES (NUM PRODUCTO Y CLIENTE)
		IF LENGTH(trim(cCta_benef)) = 16 THEN
		
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_producto ('001', '', cCta_benef)
			INTO cCod_Ret_prod, cNumProducto, cNombre_prod;				
		
			EXECUTE PROCEDURE bdicred: "informix".sp_consulta_datos_general('001','','',cCta_benef,'','','')
			INTO  cCodigo_retorno, cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente;
			
			LET cCta_benef = cNumero_credito;
			
		ELSE
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_producto ('001', cCta_benef, '')
			INTO cCod_Ret_prod, cNumProducto, cNombre_prod;

			EXECUTE PROCEDURE bdicred: "informix".sp_consulta_datos_general('001','',cCta_benef,'','','','')
			INTO  cCodigo_retorno, cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente;		
		END IF;


		IF cCodigo_retorno <> '000000' THEN
			LET cDesc_error = 'Error Al Obtener Numero De Producto';
				
				UPDATE bdisac:"informix".sac_app_getorder 
				   SET estatus_getorder = '04'
				 WHERE uniquereferencenumber = pUniqueReferenceNumber 
				   AND estatus_getorder = '02';
		
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				INTO cCod_err2;

				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;

	
		--OBTIENE EL NUMERO DE CATEGORIA Y CONVENIO
		SELECT valor 
		INTO cValor
		FROM bdisac:"informix".sac_param 
		WHERE empresa = '001'
		AND cod_param = 87111;
		
		LET cCategoria = SUBSTR(TRIM(cValor),1,2);
		LET cConvenio = SUBSTR(TRIM(cValor),3,5);
		
		--OBTIENE CTA PRESTADORA Y TRANSACCIONES DEL CONVENIO	
		SELECT cuenta_prestadora, trans_cen_cargo_cliente, trans_suc_cargo, trans_cen_abono_cr, trans_cen_abono_cf		
		INTO cCta_pres, cCen_cargo, cSuc_cargo, cCen_abonocr, cCen_abonocf
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;


		--OBTIENE EL FOLIO_SUC SI ESTE EXISTSE, PARA SABER SI YA FUE PAGADA LA REMESA
		SELECT  b.folio_suc INTO cBank_ref_nm
		FROM bdisac:"informix".sac_movimientos b 
		WHERE b.numcategoria = cCategoria
		AND b.numconvenio  = cConvenio
		AND b.referencia1  = pUniqueReferenceNumber
		AND b.flag_confirmacion_central  = '1' 
		AND b.flag_confirmacion_sucursal = '1' 
		AND b.status_cancelado = 'N';	
			
		IF cBank_ref_nm IS NOT NULL OR cBank_ref_nm <> '' THEN
			   	LET cCod_err = '9998';
				LET cDesc_error = 'Remesa Pagada Anteriormente';				 
		
				UPDATE bdisac:"informix".sac_app_getorder 
				   SET estatus_getorder = '98'
				 WHERE uniquereferencenumber = pUniqueReferenceNumber 
				   AND estatus_getorder = '02';		
						
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				   INTO cCod_err2;
				
				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;  
		END IF;	   
		
		
		--OBTIENE EL NUMERO DE SURCURSAL ASIGNADO
		SELECT valor
		INTO cSucAPP
		FROM bdisac:"informix".sac_param
		WHERE empresa = '001'
		AND cod_param = 87130;
		
		--Reviso limite de remesas
		EXECUTE PROCEDURE bdisac:"informix".sp_app_valmonto_aut(pUniqueReferenceNumber ,cNumero_credito, cSucAPP, pMonto_destino, cMonedaOrigen, mMontoOrigen, cNumero_cliente)
		INTO cCod_err, cDesc_error;
		
		IF cCod_err::INT <> 0 THEN
			
			UPDATE bdisac:"informix".sac_app_getorder
			SET    estatus_getorder      = '04'
			WHERE  uniquereferencenumber = pUniqueReferenceNumber 
			AND    estatus_getorder      = '02';

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		
		END IF;
		------


		--SE CREA EL FOLIOSUC CON QUE SE GUARDARÃÂÃÂ?N LOS MOVIMIENTOS
		--LET cFolSuc = 'appc'||pUniqueReferenceNumber;
		LET cFolSuc = 'ad' || SUBSTR(TRIM(cHora_sistema),5,2) || TRIM(pUniqueReferenceNumber);
		

		--SE OBTIENE EL SALDO ACTUAL DE LA CUENTA CONCENTRADORA (APPRIZA)
		--SELECT sdo_actual - sdo_retenido - sdo_cong - imp_chq_sbg AS saldo
		--INTO mSaldoAPP
		SELECT sdo_actual,sdo_retenido,sdo_cong,imp_chq_sbg,saldo_sbc
		INTO mSdoActual,mSdoRetenido,mSdoCong,mImpChqSbg,mSaldoSBC
			FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr, bdinteg:"informix".si_divisas di 
		WHERE mc.empresa = '001' 
		AND mc.cuenta = cCta_pres
		AND pr.empresa = mc.empresa 
		AND pr.producto = mc.producto
		AND di.empresa = pr.empresa 
		AND di.divisa = pr.divisa;

		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
		EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,mImpChqSbg,0.00,0.00,'F',1) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSaldoAPP;        
		

		--VALIDA QUE EL SALDO ACTUAL DE LA CUENTA CONCENTRADORA DE APPRIZA, SEA MAYOR AL MONTO DE LA REMESA.
		IF mSaldoAPP <=  pMonto_destino::MONEY THEN
			LET cCod_err = '9997';
			LET cDesc_error = 'Saldo Insuficiente En Cuenta Concentradora APPRIZA.';
			
			UPDATE bdisac:"informix".sac_app_getorder 
			   SET estatus_getorder = '01'
			 WHERE uniquereferencenumber = pUniqueReferenceNumber 
			   AND estatus_getorder = '02';
	
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
			
		END IF;


		--SE REALIZA EL CALCULO DE COMISIONES
		EXECUTE PROCEDURE bdisac:"informix".sp_calcula_comisiones(cCategoria,cConvenio,pMonto_destino)
		INTO cCod_err, mImpcomconvenio, mIVAimpconvenio, mImpcomcte, mIVAimpcomcte;

		IF cCod_err::INT <> 0 THEN			
			LET cDesc_error = 'Error Al Momento De Calcular Las Comisiones';

				UPDATE bdisac:"informix".sac_app_getorder 
				   SET estatus_getorder = '01'
				 WHERE uniquereferencenumber = pUniqueReferenceNumber 
				   AND estatus_getorder = '02';
		
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			   INTO cCod_err2;

			 RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;  
		END IF;


		--SI ES CREDITO FIJO (A PLAZOS), VALIDA QUE EL MONTO DE LA DEUDA SE MENOR O IGUAL AL MONTO DE LA REMESA A PAGAR.
		IF	(SELECT count(*) FROM "informix".sac_ws_prodsperm WHERE agent_cd='APR' AND tipo_cta='CRD-FIJ' AND activa='S' and producto=cNumProducto) > 0 THEN
			
			SELECT monto_sbc, total_liquidacion INTO dMonto_sbc_saldos, dTotal_liquida_saldos
			FROM TABLE(PROCEDURE bdicred:"informix".sp_consulta_saldos_general ('001', cCta_benef))
			                AS consssdogen(codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, 
			                				fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, tasa_interes, tasa_moratorios, monto_sbc, cap_vig, 
			                				cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			                				sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, 
			                				iva_com, sdo_retenido, total_liquidacion, int_devengado, iva_int_devengado, linea_disponible, pagos_vdos, 
			                				desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred, causa_bloqueo_cta, id_sit_esp_cte, 
			                				id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, id_causa_esp_cred, sit_esp_cred);

			IF pMonto_destino > dTotal_liquida_saldos  THEN
				LET cCod_err = '9997';
				LET cDesc_error = 'Error: Monto De Remesa Mayor Que Adeudo De Prestamo.';
							
				UPDATE bdisac:"informix".sac_app_getorder 
				SET estatus_getorder = '04'
				WHERE uniquereferencenumber = pUniqueReferenceNumber 
				AND estatus_getorder = '02';
				
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
				INTO cCod_err2;	
				   
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				INTO cCod_err2;

				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
			
			END IF;		
		END IF;


		--SE APLICA EL CARGO EN LA CUENTA DE CHEQUES
		EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001',cSucAPP, pUsuario,cCen_cargo,cSuc_cargo,cFolSuc,cCta_pres,0, pMonto_destino,'01',cPreferencia,'','')
		   INTO cCod_err, cTrandet, dFechoy, mSdodisp, mMontoret;		
			
		IF cCod_err::INT <> 0 THEN			
			LET cDesc_error = 'Error Al Momento De Realizar El Cargo En Cuenta';			
			
			IF cCod_err::INT < 0 THEN
				UPDATE bdisac:"informix".sac_app_getorder 
				   SET estatus_getorder = '01', intentos_envio = intentos_envio + 1
				 WHERE uniquereferencenumber = pUniqueReferenceNumber 
				   AND estatus_getorder = '02';	
				   
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
				   INTO cCod_err2;	
			   
				IF iTransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF   
			ELSE
				UPDATE bdisac:"informix".sac_app_getorder 
				   SET estatus_getorder = '04', intentos_envio = 0
				 WHERE uniquereferencenumber = pUniqueReferenceNumber 
				   AND estatus_getorder = '02';
				   
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
    			   INTO cCod_err2;	
			   
			END IF;			
						
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			   INTO cCod_err2;
			
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion; 
		END IF;	

		
		--SI ES CRÃÂÃÂ?DITO REVOLVENTE SE EJECUTA bdicred:"informix".principalrefer.
		IF (SELECT COUNT(*) FROM  "informix".sac_ws_prodsperm where tipo_cta='CRD-REV' and agent_cd='APR' and activa='S' and producto= cNumProducto) > 0 THEN
			EXECUTE PROCEDURE bdicred:"informix".principalrefer('001', cCta_benef, 1, cNumero_tarjeta, pUsuario, cSucAPP, cFolSuc,cCen_abonocr, dMonto_sbc_saldos, pMonto_destino, cPreferencia)
			INTO cCod_ret_prinrefer, mRemanente_prinrefer, mInteresmora_cob_prinrefer, mInteresven_cob_prinrefer, mCapven_cob_prinrefer, mInteresvig_cob_prinrefer,mCapvig_cob_prinrefer, mImpcob_prinrefer, mComcob_prinrefer, mSegcob_prinrefer;
			
				IF cCod_ret_prinrefer::INT <> 0 THEN				
					LET cDesc_error = 'Error Al Momento De Realizar El Abono';
					LET cCod_err = cCod_ret_prinrefer;
					
					IF cCod_ret_prinrefer::INT < 0 THEN
					
						UPDATE bdisac:"informix".sac_app_getorder 
						SET estatus_getorder = '01', intentos_envio = intentos_envio + 1 
						WHERE uniquereferencenumber = pUniqueReferenceNumber 
						AND estatus_getorder = '02';
					
						EXECUTE PROCEDURE bdicred:"informix".reversion ('001', cSucAPP, pUsuario, cFolSuc,'M')
						INTO cCod_err2;
					
						EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
						INTO cCod_err2;
					
					ELSE
						UPDATE bdisac:"informix".sac_app_getorder 
						SET estatus_getorder = '04', intentos_envio = 0
						WHERE uniquereferencenumber = pUniqueReferenceNumber 
						AND estatus_getorder = '02';
						
						EXECUTE PROCEDURE bdicred:"informix".reversion ('001', cSucAPP, pUsuario, cFolSuc,'M')
						INTO cCod_err2;
					
						EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
						INTO cCod_err2;
						
					END IF;
						
					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws (1,'sp_app_aplicapagos_cred', cCod_ret_prinrefer, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
					INTO cCod_err2;											
										
					RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;					
					
				END IF;
				
			LET cCen_abono = cCen_abonocr;


			--SI ES CRÃÂÃÂ?DITO FIJO SE EJECUTA bdicred:"informix".sp_principal_suc_rr.
		ELIF (SELECT COUNT(*) FROM  "informix".sac_ws_prodsperm where tipo_cta='CRD-FIJ' and agent_cd='APR' and activa='S' and producto= cNumProducto) > 0 THEN
			EXECUTE PROCEDURE bdicred:"informix".sp_principal_suc_rr ('001', cCta_benef, cNumProducto, pMonto_destino::DECIMAL(18,2), 0, pUsuario,cSucAPP, cFolSuc, cCen_abonocf)
			INTO cCod_Ret_prinsucrr, cMsg_Ret_prinsucrr, cNum_Cred_prinsucrr, cCta_eje_prinsucrr, cProd_prinsucrr, cNum_Cte_prinsucrr, cNom_Cte_prinsucrr,dPago_Efect_prinsucrr, dPago_Cta_prinsucrr, dMonto_Oper_prinsucrr, dSdo_Act_prinsucrr, cStatus_Act_prinsucrr;
			
			IF cCod_Ret_prinsucrr::INTEGER <> 0 THEN
				LET cDesc_error = 'Error Al Momento De Realizar El Abono';
				LET cCod_err = cCod_Ret_prinsucrr;
			
				IF cCod_Ret_prinsucrr::INTEGER < 0 THEN
					
					UPDATE bdisac:"informix".sac_app_getorder 
					SET estatus_getorder = '01', intentos_envio = intentos_envio + 1 
					WHERE uniquereferencenumber = pUniqueReferenceNumber 
					AND estatus_getorder = '02';
						
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd ('001', cSucAPP, pUsuario, cFolSuc,'M')
					INTO cCod_err2;
					
					EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
					INTO cCod_err2;					
					
				ELSE	
					UPDATE bdisac:"informix".sac_app_getorder 
					SET estatus_getorder = '04', intentos_envio = 0
					WHERE uniquereferencenumber = pUniqueReferenceNumber 
					AND estatus_getorder = '02';
					
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd ('001', cSucAPP, pUsuario, cFolSuc,'M')
					INTO cCod_err2;
					
					EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
					INTO cCod_err2;	
					
				END IF;
					
					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapagos_cred', cCod_Ret_prinsucrr, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
					INTO cCod_err2;																
										
					RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
					
			END IF;
			
			LET cCen_abono = cCen_abonocf;
			
		END IF;
		
		LET cReferencia2 = SUBSTR(pUniqueReferenceNumber,11,1);			



		--GRABA PAGO DE SERVICIO
		EXECUTE PROCEDURE bdisac:"informix".sp_grabapagoservicio(cSucAPP,cCategoria,cConvenio,pUniqueReferenceNumber, cReferencia2, '5',pMonto_destino,mImpcomconvenio,mIVAimpconvenio,mImpcomcte,mIVAimpcomcte,cCta_pres, pUsuario, cFolSuc,cCen_abono,CURRENT::DATE)
		INTO cCod_err;		
		IF cCod_err::INT <> 0 THEN
			LET cDesc_error = 'Error Al Momento De Grabar En Servicios';					
			
			IF cCod_err::INT < 0 THEN

				
				UPDATE bdisac:"informix".sac_app_getorder 
				   SET estatus_getorder = '01', intentos_envio = intentos_envio + 1
				 WHERE uniquereferencenumber = pUniqueReferenceNumber 
				   AND estatus_getorder = '02';	
			ELSE
				UPDATE bdisac:"informix".sac_app_getorder 
				   SET estatus_getorder = '04', intentos_envio = 0
				WHERE uniquereferencenumber = pUniqueReferenceNumber AND estatus_getorder = '02';	
			END IF;			
			
			IF	(SELECT count(*) FROM "informix".sac_ws_prodsperm WHERE agent_cd='APR' AND tipo_cta='CRD-REV' AND activa='S' and producto=cNumProducto) > 0 THEN					
				EXECUTE PROCEDURE bdicred:"informix".reversion ('001', cSucAPP, pUsuario, cFolSuc,'M')
				INTO cCod_err2;
			ELSE
				EXECUTE PROCEDURE bdicred:"informix".reversioncrd ('001', cSucAPP, pUsuario, cFolSuc,'M')
				INTO cCod_err2;
			END IF;
			
			EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
			   INTO cCod_err2;
			   
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			   INTO cCod_err2;
			   
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;
		LET cDesc_error = 'Confirmacion PAYC Exitosa';


		--REGISTRA FIN SATISFACTORIO DEL SP
		--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,'sp_app_aplicapagos_cred', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
		--   INTO cCod_err;	


		--ACTUALIZA EL ESTATUS DE LA REMESA		
		UPDATE bdisac:"informix".sac_app_getorder 
		   SET estatus_getorder = '03', intentos_envio = 0
		 WHERE uniquereferencenumber = pUniqueReferenceNumber 
		   AND estatus_getorder = '02';		


		--SMS AL CLIENTE
		LET cImporte2 = TRIM (TO_CHAR(pMonto_destino,"###,###,###,###.##"));
		CALL bdimnsj:"informix".sp_registra_evento ('2' , 'APP_ACTAS', '', cCta_benef, '' , '1', 
			 cCta_benef, cFolSuc, 'PAGO DE REMESA DE APPRIZA', cImporte2, '', '', '', '', '', '', '', '',
			 pMonto_destino, '','', '', '', CURRENT, '') RETURNING cCod_err2;
	
																											 
											
   
		
		RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;

 END
 END PROCEDURE
DOCUMENT
'AUTOR: 96273763 - Antonio Cebreros Perez',
'FOLIO: 230142 - 32  - PagoBTSAbnoAutCtasCred',
'DESCRIPCION: Procedimiento que realiza cargo en cuenta concentradora de BTS y abona a los crÃÂÃÂÃÂÃÂ©ditos del cliente.',
'FECHA: 07/03/2016',
'BD: bdisac',
'MODIFICACION: 93440138 - Noe Medina Ramirez',
'DESCRIPCION: Se Genera SP para Pagos APP(TDC-PP), apartir de SP de BTS(TDC-PP).',
'FECHA: 30/10/2017',
'BD: bdisac',
'MODIFICACION: 90314234 - Osiel Alfredo Camacho Mendoza - Daniel Hernandez',
'DESCRIPCION: Se modifica el saldo disponible incluyendo el saldo sbc por medio del sp de calcula saldo por tipo',
'FECHA: 08/07/2025',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sac_qry_statusrem(pNumRemesa CHAR(15))

	RETURNING
 CHAR(4)    AS  cCodRet,
 CHAR(1)    AS  cTransacc,      
 CHAR(12)   AS  cNumRemesa,    
 CHAR(16)   AS  cFolioSuc,    
 CHAR(8)    AS  cTipoOp,
 CHAR(20)   AS  cCodB,
 CHAR(100)  AS  cDescCodB,
 CHAR(5)    AS  cCodStatusRem,   
 CHAR(100)  AS  cDescStatus,
 CHAR(4)    AS  cSuc,
 CHAR(5)    AS  cCod,
 CHAR(100)  AS  cDescCod,
 CHAR (5)   AS  cCanal,
 CHAR(30)   AS  cNom1,
 CHAR(30)   AS  cNom2, 
 CHAR(30)   AS  cApelldoPat,
 CHAR(30)   AS  cApellMat,   
 CHAR(4)    AS  cPais,  
 CHAR(4)    AS  cEdo,
 CHAR(30)   AS  cCd,
 CHAR(5)    AS  cCP,
 CHAR(10)   AS  cTel, 
 CHAR(10)   AS  cCel,  
 CHAR(50)   AS  cDom,  
 CHAR(2)    AS  cTipoID,
 CHAR(20)   AS  cNumID,
 CHAR(10)   AS  cFechaVencID,   
 CHAR(30)   AS  cEmail,
 CHAR(6)    AS  cTipoCambio, 
 CHAR(4)    AS  cMonedaOrigen, 
 CHAR(4)    AS  cMonedaDestino,
 CHAR(8)    AS  cMontoOrigen,
 CHAR(8)    AS  cMontoDestino,
 CHAR(30)   AS  cNom1Emisor,
 CHAR(30)   AS  cNom2Emisor,
 CHAR(30)   AS  cApellPatEmisor,
 CHAR(30)   AS  cApellMatEmisor,
 CHAR(4)    AS  cPaisEmisor,
 CHAR(4)    AS  cEdoEmisor,
 CHAR(20)   AS  cCdEmisor,
 CHAR(5)    AS  cCpEmisor,  
 CHAR(50)   AS  cDomEmisor,
 CHAR(9)    AS  cEjecut,
 CHAR(25)   AS  cFechaInsert;       

DEFINE cCodRet CHAR(4);
DEFINE isqlerr INTEGER;
DEFINE cTransacc CHAR(1);
DEFINE cNumRemesa CHAR(12);
DEFINE cFolioSuc CHAR(16);


DEFINE cCodStatusRem CHAR(5);
DEFINE cDescStatus CHAR(100);
DEFINE cTipoOp CHAR(8);    
DEFINE cCodB CHAR(20);
DEFINE cDescCodB CHAR(100);
DEFINE cSuc CHAR(4);
DEFINE cCod CHAR(4);
DEFINE cDescCod CHAR(100);
DEFINE cCanal CHAR(5);
DEFINE cNom1 CHAR(30);
DEFINE cNom2 CHAR(30);
DEFINE cApelldoPat CHAR(30);
DEFINE cApellMat CHAR(30);
DEFINE cPais CHAR(4);
DEFINE cEdo CHAR(4);
DEFINE cCd CHAR(30);
DEFINE cCP CHAR(5);
DEFINE cTel CHAR(10);
DEFINE cCel CHAR(10);
DEFINE cDom CHAR(50);
DEFINE cTipoID CHAR(2);
DEFINE cNumID CHAR(20);
DEFINE cFechaVencID CHAR(10);
DEFINE cEmail CHAR(30);
DEFINE cTipoCambio CHAR(6);
DEFINE cMonedaOrigen CHAR(4);
DEFINE cMonedaDestino CHAR(4);
DEFINE cMontoOrigen CHAR(8);
DEFINE cMontoDestino CHAR(8);
DEFINE cNom1Emisor CHAR(30);
DEFINE cNom2Emisor CHAR(30);
DEFINE cApellPatEmisor CHAR(30);
DEFINE cApellMatEmisor CHAR(30);
DEFINE cPaisEmisor CHAR(4);
DEFINE cEdoEmisor CHAR(4);
DEFINE cCdEmisor CHAR(20);
DEFINE cCpEmisor CHAR(5);
DEFINE cDomEmisor CHAR(50);
DEFINE cEjecut CHAR(9);
DEFINE cFechaInsert CHAR(25);

DEFINE cremesaApp CHAR(12);
DEFINE cremesaBts CHAR(12);
DEFINE cremesaWu  CHAR(12);

LET cCodRet = '0000';
LET isqlerr = 0;
LET cTransacc = '';
LET cNumRemesa = '';
LET cFolioSuc = '';

LET cTipoOp = 'Qryi';
LET cCodB = '';
LET cDescCodB = '';
LET cCodStatusRem = '';
LET cDescStatus = '';
LET cSuc = '';
LET cCod = '';
LET cDescCod = '';
LET cCanal = '';
LET cNom1 = '';
LET cNom2 = '';
LET cApelldoPat = '';
LET cApellMat = '';
LET cPais = '';
LET cEdo = '';
LET cCd = '';
LET cCP = '';
LET cTel = '';
LET cCel = '';
LET cDom = '';
LET cTipoID = '';
LET cNumID = '';
LET cFechaVencID = '';
LET cEmail = '';
LET cTipoCambio = '';
LET cMonedaOrigen = '';
LET cMonedaDestino = '';
LET cMontoOrigen = '';
LET cMontoDestino = '';
LET cNom1Emisor = '';
LET cNom2Emisor = '';
LET cApellPatEmisor = '';
LET cApellMatEmisor = '';
LET cPaisEmisor = '';
LET cEdoEmisor = '';
LET cCdEmisor = '';
LET cCpEmisor = '';
LET cDomEmisor = '';
LET cEjecut = '';
LET cFechaInsert = '';

LET cremesaApp ='';
LET cremesaBts ='';
LET cremesaWu ='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN  cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1, cNom2, cApelldoPat, cApellMat, 
                    cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                    cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert;       

		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/home/c90307738/herramienta/sp_sac_qry_statusrem.log';
       --TRACE ON;

		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;

        DROP SYNONYM IF EXISTS bitacoraAppriza;
        DROP SYNONYM IF EXISTS bitacoraBts;
        DROP SYNONYM IF EXISTS bitacoraWu;

        DROP TABLE IF EXISTS tablaTemporal;
        CREATE TEMP TABLE tablaTemporal (tCodRet  CHAR(4), tTransacc   CHAR(1), tNumRemesa  CHAR(12),tFolioSuc   CHAR(16),tTipoOp   CHAR(8), tCodB     CHAR(20),tDescCodB    CHAR(100),tCodStatusRem  CHAR(5), 
        tDescStatus CHAR(100) ,tSuc     CHAR(4), tCod     CHAR(5), tDescCod CHAR(100),tCanal   CHAR (5),tNom1    CHAR(30),tNom2    CHAR(30),tApelldoPat CHAR(30),tApellMat   CHAR(30),
        tPais    CHAR(4), tEdo     CHAR(4), tCd   CHAR(30),tCP   CHAR(5), tTel     CHAR(10),tCel     CHAR(10),tDom     CHAR(50),tTipoID  CHAR(2), tNumID   CHAR(20),tFechaVencID   CHAR(10),
        tEmail   CHAR(30),tTipoCambio CHAR(6), tMonedaOrigen  CHAR(4), tMonedaDestino CHAR(4), tMontoOrigen   CHAR(8), tMontoDestino  CHAR(8), tNom1Emisor CHAR(30),tNom2Emisor CHAR(30),tApellPatEmisor CHAR(30),
        tApellMatEmisor CHAR(30),tPaisEmisor CHAR(4), tEdoEmisor  CHAR(4), tCdEmisor   CHAR(20),tCpEmisor   CHAR(5), tDomEmisor  CHAR(50),tEjecut  CHAR(9), tFechaInsert   CHAR(25));

        FOREACH
        SELECT referencia, retcode2, descripcion_error, sucursal, fecha_insert 
        INTO   cNumRemesa, cCod ,  cDescCod,  cSuc, cFechaInsert
        FROM   sac_bitacora_errores_remesas
        WHERE referencia = pNumRemesa  
        AND     tipo_proceso= cTipoOp
        INSERT INTO tablaTemporal (tCodRet, tTransacc, tNumRemesa,tFolioSuc,tTipoOp, tCodB,tDescCodB,tCodStatusRem, tDescStatus,tSuc, tCod, tDescCod,tCanal,tNom1,tNom2,tApelldoPat,tApellMat,tPais, tEdo, 
                                    tCd,tCP, tTel,tCel,tDom,tTipoID, tNumID,tFechaVencID, tEmail,tTipoCambio, tMonedaOrigen, tMonedaDestino, tMontoOrigen, tMontoDestino, tNom1Emisor,tNom2Emisor,tApellPatEmisor,
                                    tApellMatEmisor,tPaisEmisor, tEdoEmisor, tCdEmisor,tCpEmisor, tDomEmisor,tEjecut, tFechaInsert) VALUES 
                                    (cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1,cNom2, cApelldoPat, cApellMat, 
                                    cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                                    cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert);
        END FOREACH;
        LET cNumRemesa= '';
        LET cCodB = '';
        LET cDescCodB= '';
        LET cSuc= '';
        LET cEjecut= '';
        LET cFechaInsert = '';
                        -----------------------------APPRIZA - MONEYGRAM---------------------------------------------------------------
        IF LENGTH(TRIM(pNumRemesa))= 12 OR LENGTH(TRIM(pNumRemesa))= 8 THEN 

            SELECT COUNT(unirefnum)
            INTO cremesaApp
            FROM bdisac:sac_app_qryi
            WHERE unirefnum = pNumRemesa ;

            IF cremesaApp > 0 THEN
                CREATE SYNONYM IF NOT EXISTS bitacoraAppriza FOR bdisac:"informix".sac_app_qryi;
            ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraAppriza FOR bdisac:"informix".sac_app_qryi_old;
            END IF;

            FOREACH
            SELECT
                txn_status, unirefnum,code,r_ordstatuscode,nnumber,
                r_code_d, r_message_d,r_firstname_b,r_middlename_b,r_lastname_b,r_mommaidenna_b,r_countrycode_b,r_statecode_b,r_city_b,r_zipcode_b,r_homephonenum,
                r_number_cl,r_address_b, r_email,r_rexchangerate,r_originamount,r_currencycode, r_destinamount, r_currencycod_d,
                r_firstname,r_middlename,r_lastname,r_mommaidenname,r_countrycode_a,r_statecode,r_city,r_zipcode,r_address,user_insert,fecha
            INTO
                cTransacc,cNumRemesa,cCanal, cCodStatusRem,cSuc,
                cCod,cDescCod,cNom1,cNom2,cApelldoPat,cApellMat,cPais,cEdo,cCd,cCP,cTel,
                cCel,cDom,cEmail,cTipoCambio,cMontoOrigen,cMonedaOrigen, cMontoDestino, cMonedaDestino,
                cNom1Emisor,cNom2Emisor,cApellPatEmisor,cApellMatEmisor,cPaisEmisor,cEdoEmisor,cCdEmisor,cCpEmisor,cDomEmisor,cEjecut,cFechaInsert
            FROM
                bitacoraAppriza 
            WHERE
                unirefnum = pNumRemesa 
            
            IF cCodStatusRem <> '' THEN
                SELECT description INTO cDescStatus FROM bdisac:sac_app_estatusrem WHERE status = cCodStatusRem;
            END IF;
            
            
            INSERT INTO tablaTemporal (tCodRet, tTransacc, tNumRemesa,tFolioSuc,tTipoOp, tCodB,tDescCodB,tCodStatusRem, tDescStatus,tSuc, tCod, tDescCod,tCanal,tNom1,tNom2,tApelldoPat,tApellMat,tPais, tEdo, 
                                    tCd,tCP, tTel,tCel,tDom,tTipoID, tNumID,tFechaVencID, tEmail,tTipoCambio, tMonedaOrigen, tMonedaDestino, tMontoOrigen, tMontoDestino, tNom1Emisor,tNom2Emisor,tApellPatEmisor,
                                    tApellMatEmisor,tPaisEmisor, tEdoEmisor, tCdEmisor,tCpEmisor, tDomEmisor,tEjecut, tFechaInsert) VALUES 
                                    (cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1,cNom2, cApelldoPat, cApellMat, 
                                    cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen, cMonedaDestino,cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                                    cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert);
            END FOREACH;
            DROP SYNONYM IF EXISTS bitacoraAppriza;

                     ------ -----------------------BTS --------------------------------------------------------------------------  
        ELIF LENGTH(TRIM(pNumRemesa))= 11 THEN 

            SELECT COUNT(confirmation_nm)
            INTO cremesaBts
            FROM bdisac:sac_bts_qryi
            WHERE confirmation_nm = pNumRemesa ;

            IF cremesaBts > 0 THEN
                CREATE SYNONYM IF NOT EXISTS bitacoraBts FOR bdisac:"informix".sac_bts_qryi;
            ELSE 
                CREATE SYNONYM IF NOT EXISTS bitacoraBts FOR bdisac:"informix".sac_bts_qryi_old;
            END IF;

            FOREACH
            SELECT
            txn_status ,agent_cd ,confirmation_nm , trans_status_cd , branch_sd ,
            opcode , process_msg , r_first_name , r_middle_name , r_last_name , r_mother_m_name , r_country_cd , r_state_cd , r_city , r_zip_code ,
            r_phone , r_address , r_identif_type_cd , r_identif_nm , r_expiration_dt , exch_rate_fx , orig_currency_cd , dest_currency_cd , origin_am , destination_am , 
            s_first_name , s_middle_name , s_last_name , s_mother_m_name , s_country_cd , s_state_cd , s_city , s_zip_code , s_address , user_insert , fecha_insert 
            INTO
            cTransacc,cCanal, cNumRemesa,cCodStatusRem,cSuc,
            cCod,cDescCod,cNom1,cNom2,cApelldoPat,cApellMat,cPais,cEdo,cCd,cCP,
            cCel,cDom,cTipoID,cNumID,cFechaVencID,cTipoCambio,cMonedaOrigen,cMonedaDestino,
            cMontoOrigen,cMontoDestino,cNom1Emisor,cNom2Emisor,cApellPatEmisor,cApellMatEmisor,cPaisEmisor,cEdoEmisor,cCdEmisor,cCpEmisor,cDomEmisor,cEjecut,cFechaInsert
            FROM
            bitacoraBts
            WHERE
            confirmation_nm = pNumRemesa 

            IF cCodStatusRem <> '' THEN
                SELECT dans_status_code_sd INTO cDescStatus FROM bdisac:sac_bts_catstatusremesas WHERE dans_status_code = cCodStatusRem;
            END IF;

            

            INSERT INTO tablaTemporal (tCodRet, tTransacc, tNumRemesa,tFolioSuc,tTipoOp, tCodB,tDescCodB,tCodStatusRem, tDescStatus,tSuc, tCod, tDescCod,tCanal,tNom1,tNom2,tApelldoPat,tApellMat,tPais, tEdo, 
                                    tCd,tCP, tTel,tCel,tDom,tTipoID, tNumID,tFechaVencID, tEmail,tTipoCambio, tMonedaOrigen, tMonedaDestino, tMontoOrigen, tMontoDestino, tNom1Emisor,tNom2Emisor,tApellPatEmisor,
                                    tApellMatEmisor,tPaisEmisor, tEdoEmisor, tCdEmisor,tCpEmisor, tDomEmisor,tEjecut, tFechaInsert) VALUES 
                                    (cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1,cNom2, cApelldoPat, cApellMat, 
                                    cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                                    cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert);
      
            END FOREACH;
            DROP SYNONYM IF EXISTS bitacoraBts;
                        -------- ---------------------------------WESTERN UNION --------------------------------------------------------  
        ELSE 
            SELECT COUNT(mtcn)
            INTO cremesaWu
            FROM bdisac:sac_wu_search
            WHERE mtcn = pNumRemesa ;

            IF cremesaWu > 0 THEN
            CREATE SYNONYM IF NOT EXISTS bitacoraWu FOR bdisac:"informix".sac_wu_search;
            ELSE 
            CREATE SYNONYM IF NOT EXISTS bitacoraWu FOR bdisac:"informix".sac_wu_search_old;
            END IF;

            FOREACH
            SELECT
                txn_status,mtcn,foreign_rs_refnum_rp,estatus_remesa,
                retcode,desc_error,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,benef_cod_pais,benef_edo,benef_ciudad,benef_cp,benef_tel_part,
                benef_tel_celular,benef_calle,tipo_cambio,emisor_cod_moneda,benef_cod_moneda,monto_total_origen,monto_total_destino,
                emisor_nombre1,emisor_nombre2,emisor_appaterno,emisor_apmaterno,emisor_cod_pais,emisor_edo,emisor_ciudad,emisor_cp,emisor_calle,user_insert,fecha_insert
            INTO
                cTransacc,cNumRemesa,cFolioSuc,cCodStatusRem,
                cCod,cDescCod,cNom1,cNom2,cApelldoPat,cApellMat,cPais,cEdo,cCd,cCP,cTel,
                cCel,cDom,cTipoCambio,cMonedaOrigen,cMonedaDestino,cMontoOrigen,cMontoDestino,
                cNom1Emisor,cNom2Emisor,cApellPatEmisor,cApellMatEmisor,cPaisEmisor,cEdoEmisor,cCdEmisor,cCpEmisor,cDomEmisor,cEjecut,cFechaInsert
            FROM 
                bitacoraWu
            WHERE
                mtcn = pNumRemesa 


            SELECT sucursal
            INTO cSuc
            from bdinteg:"informix".si_ejecut
            where ejecutivo = cEjecut;

            IF cCodStatusRem <> ''  AND cCodStatusRem IS NOT NULL THEN
                SELECT descripcion_bcp INTO cDescStatus FROM bdisac:"informix".sac_wu_estatusrems WHERE estatus_remesa = cCodStatusRem;
            END IF;

            INSERT INTO tablaTemporal (tCodRet, tTransacc, tNumRemesa,tFolioSuc,tTipoOp, tCodB,tDescCodB,tCodStatusRem, tDescStatus,tSuc, tCod, tDescCod,tCanal,tNom1,tNom2,tApelldoPat,tApellMat,tPais, tEdo, 
                                    tCd,tCP, tTel,tCel,tDom,tTipoID, tNumID,tFechaVencID, tEmail,tTipoCambio, tMonedaOrigen, tMonedaDestino, tMontoOrigen, tMontoDestino, tNom1Emisor,tNom2Emisor,tApellPatEmisor,
                                    tApellMatEmisor,tPaisEmisor, tEdoEmisor, tCdEmisor,tCpEmisor, tDomEmisor,tEjecut, tFechaInsert) VALUES 
                                    (cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1,cNom2, cApelldoPat, cApellMat, 
                                    cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                                    cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert);

            END FOREACH;
            DROP SYNONYM IF EXISTS bitacoraWu;
        END IF;

        FOREACH
        SELECT  tCodRet, tTransacc, tNumRemesa,tFolioSuc,tTipoOp, tCodB,tDescCodB,tCodStatusRem, tDescStatus,tSuc, tCod, tDescCod,tCanal,tNom1,tNom2,tApelldoPat,tApellMat,tPais, tEdo, 
                tCd,tCP, tTel,tCel,tDom,tTipoID, tNumID,tFechaVencID, tEmail,tTipoCambio, tMonedaOrigen, tMonedaDestino, tMontoOrigen, tMontoDestino, tNom1Emisor,tNom2Emisor,tApellPatEmisor,
                tApellMatEmisor,tPaisEmisor, tEdoEmisor, tCdEmisor,tCpEmisor, tDomEmisor,tEjecut, tFechaInsert
        INTO    cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1,cNom2, cApelldoPat, cApellMat, 
                cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert
        FROM tablaTemporal
        ORDER BY cFechaInsert DESC

        RETURN  cCodRet,  cTransacc, cNumRemesa, cFolioSuc, cTipoOp, cCodB ,cDescCodB, cCodStatusRem, cDescStatus, cSuc, cCod, cDescCod, cCanal ,cNom1, cNom2, cApelldoPat, cApellMat, 
                cPais, cEdo, cCd, cCP, cTel,cCel, cDom, cTipoID, cNumID, cFechaVencID, cEmail, cTipoCambio, cMonedaOrigen,cMonedaDestino, cMontoOrigen, cMontoDestino, cNom1Emisor, cNom2Emisor, cApellPatEmisor, 
                cApellMatEmisor,cPaisEmisor,cEdoEmisor, cCdEmisor, cCpEmisor, cDomEmisor, cEjecut, cFechaInsert WITH RESUME;
        END FOREACH;
        DROP TABLE IF EXISTS tablaTemporal;
    END;
END PROCEDURE
		;