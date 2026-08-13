CREATE PROCEDURE "informix".sp_graba_indicador_cnr(	   pempresa 	CHAR(3), 			
                                                       pNumcredito	CHAR(20),			
													   pMonto		DECIMAL(18,2),		
                                                       pTransacc	VARCHAR(4),			-- Abono / Pagos
													   pCodigoFun	CHAR(3),			-- Cuales?
													   pCodigoRef	INTEGER,			-- Siempre es 1
                                                       pFecha 		DATE, 				-- 
													   pFolio 		CHAR(16),			
													   pVencido		INTEGER,			-- Siempre es 0										   
													   Monto2		DECIMAL (18,2),		-- Siempre es 0
													   pIndicador 	SMALLINT			-- INDICADOR =3 es reverso por lo tanto NA, solo aplicara INDICADOR 2
												)  
       RETURNING char(5);
   


--declaracion de variables
------------------------------------------------------------
DEFINE	cCod_ret		CHAR(6);
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(80);
--DEFINE	vcantReg		SMALLINT;

------------------------------------------------
------------------------------------------------
--DEFINE	vtipotrans			char(1);
--DEFINE	vlSentido		    char(1);


--DEFINE vPagoCliente	CHAR(1);
DEFINE vFecUltPago			DATE; 
DEFINE vMtoUltPago			DECIMAL(16,2);
DEFINE vTransUltPago		CHAR(4);	
DEFINE vFolioUltPago		CHAR(16); 
DEFINE vFecUltPagoRev		DATE; 
DEFINE vMtoUltPagoRev		DECIMAL(16,2);      
DEFINE vTransUltPagoRev		CHAR(4);
DEFINE vFolioUltPagoRev		CHAR(16);
DEFINE vNumTrans			INTEGER;
DEFINE bContinua			CHAR(1);
--DEFINE UltPagoRev			CHAR(16);
DEFINE vMtoReversion		DECIMAL(16,2);
DEFINE vRevPAGO				CHAR(1); 





DEFINE dtFechaActual		DATE;
DEFINE dtFechaProxPago		DATE;

--TRIAD
DEFINE vFecVencido 				DATE;			--LEE
DEFINE iDiasAtraso				INTEGER; 		--LEE
DEFINE vFecUltPagoHist 			DATE;			--LEE
DEFINE vMtoUltPagoHist			DECIMAL(18,2);	--LEE
DEFINE vCumplioConv				INTEGER;		--LEE
DEFINE vSdoTotLiquidar			DECIMAL(18,2);	--LEE
DEFINE vSdoTotLiquidar_ch		DECIMAL(18,2);	--LEE
DEFINE vSdoTotLiquidar_h		DECIMAL(18,2);	--LEE
DEFINE vPagoMinimo				DECIMAL(18,2);	--LEE
DEFINE vPagoMinimo_ch			DECIMAL(18,2);	--LEE
DEFINE vPagoMinimo_h			DECIMAL(18,2);	--LEE
DEFINE vSdoTotVencido			DECIMAL(18,2);	--LEE
DEFINE vSdoTotVencido_ch		DECIMAL(18,2);	--LEE
DEFINE vSdoTotVencido_h			DECIMAL(18,2);	--LEE
DEFINE vMontoPagos				DECIMAL(18,2);	--LEE
DEFINE vMontoPagos_ch			DECIMAL(18,2);	--LEE
DEFINE vIntPeriodo				DECIMAL(18,2);	--LEE
DEFINE iNumVenc					INTEGER;		--LEE
DEFINE vMontoMensual			DECIMAL(18,2);	--LEE
DEFINE vFecPrimerMora			DATE;			--LEE
DEFINE vFecUltimaMora			DATE;			--LEE
DEFINE vFecPromesaRota			DATE;			--LEE
DEFINE iPeorMora12m				INTEGER;		--LEE
DEFINE vSdoMaxHist				DECIMAL(18,2);	--LEE
DEFINE TotCuentas				INTEGER;		--LEE
DEFINE vFecUltPagoRevHist		DATE;			--LEE
DEFINE iNumConvHist				INTEGER;		--LEE
DEFINE iNumPagos				INTEGER;		--LEE
DEFINE vPromesaPago				INTEGER;		--LEE

------------------------------------------------

--SET DEBUG FILE TO '/ifxsif01/aacano/liberacion/juan/sp_graba_indicador_cnr.out';
--TRACE ON;

    LET cCod_ret      = '000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';	
	
	--LET vtipotrans = '';	
	--LET vlSentido = '';
	--LET vPagoCliente  = '';
	
	LET vFecUltPago			= DATE(1);
	LET vMtoUltPago			= 0;
	LET vTransUltPago		= '';
	LET vFolioUltPago		= '';
	LET vFecUltPagoRev		= DATE(1);
	LET vMtoUltPagoRev		= 0;
	LET vTransUltPagoRev	= '';
	LET vFolioUltPagoRev	= '';
	LET vNumTrans			= 0;
	LET bContinua			= 'V';
	--LET UltPagoRev			= '';
	LET vMtoReversion		= 0.0;
	LET vRevPAGO			= '';
	

	
	LET dtFechaActual		= DATE(1);
	LET dtFechaProxPago		= DATE(1);
	
	--TRIAD
	LET vFecVencido 			= DATE(1);
	LET iDiasAtraso				= 0;
	LET vFecUltPagoHist 		= DATE(1);
	LET vMtoUltPagoHist			= 0.00;
	LET vCumplioConv			= 0;
	LET vSdoTotLiquidar			= 0.00;
	LET vSdoTotLiquidar_ch		= 0.00;
	LET vSdoTotLiquidar_h		= 0.00;
	LET vPagoMinimo				= 0.00;
	LET vPagoMinimo_ch			= 0.00;
	LET vPagoMinimo_h			= 0.00;
	LET vSdoTotVencido			= 0.00;
	LET vSdoTotVencido_ch		= 0.00;
	LET vSdoTotVencido_h		= 0.00;
	LET vMontoPagos				= 0.00;
	LET vMontoPagos_ch			= 0.00;
	LET vIntPeriodo				= 0.00;
	LET iNumVenc				= 0;
	LET vMontoMensual			= 0.00;
	LET vFecPrimerMora			= DATE(1);
	LET vFecUltimaMora			= DATE(1);
	LET vFecPromesaRota			= DATE(1);
	LET iPeorMora12m			= 0;
	LET vSdoMaxHist				= 0.00;
	LET TotCuentas				= 0;
	LET vFecUltPagoRevHist		= DATE(1);
	LET iNumConvHist			= 0;
	LET iNumPagos				= 0;
	LET vPromesaPago			= 0;

	
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			insert into bdicobranza:cb_bitacora (mensaje) values  (error_info);		
            RETURN cCod_ret;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		
		END EXCEPTION;		
		SET LOCK MODE TO WAIT 3;		
				   
		SELECT fecha_hoy
		INTO dtFechaActual
		FROM  bdicred:"informix".sd_fechas;		
		
		SELECT prox_fecha_pago 
		INTO dtFechaProxPago
		FROM bdicred:sd_maecredanexo 
		WHERE empresa=pempresa AND num_credito=pnumcredito;
				   
		select fecha_vencido,dias_atraso,
				cumplio_convenio,sdo_tot_liquidar,sdo_tot_liquidar_ch,sdo_tot_liquidar_h,
				pago_minimo,pago_minimo_ch,pago_minimo_h,sdo_tot_vencido,sdo_tot_vencido_ch,sdo_tot_vencido_h,
				monto_pagos,monto_pagos_ch,intereses_periodo_ch,num_vencidos_ch,monto_mensual,
				fecha_primera_mora,fecha_ultima_mora,fecha_promesa_rota,peor_mora_12m,saldo_maximo_hist,
				trans_ultimo_pago,folio_ultimo_pago,fecha_ultimo_pago,fecha_ultimo_pago_h,monto_ultimo_pago,monto_ultimo_pago_h,
				fecha_ultimo_pago_rev,fecha_ultimo_pago_h,monto_ultimo_pago_rev,trans_ultimo_pago_rev,folio_ultimo_pago_rev,
				num_convenios_hist,num_pagos_hist,promesa_pago
		  into vFecVencido,iDiasAtraso,
			   vCumplioConv,vSdoTotLiquidar,vSdoTotLiquidar_ch,vSdoTotLiquidar_h,
			   vPagoMinimo,vPagoMinimo_ch,vPagoMinimo_h,vSdoTotVencido,vSdoTotVencido_ch,vSdoTotVencido_h,
			   vMontoPagos,vMontoPagos_ch,vIntPeriodo,iNumVenc,vMontoMensual,
			   vFecPrimerMora, vFecUltimaMora,vFecPromesaRota,iPeorMora12m,vSdoMaxHist,
			   vTransUltPago,vFolioUltPago,vFecUltPago,vFecUltPagoHist,vMtoUltPago,vMtoUltPagoHist,
			   vFecUltPagoRev,vFecUltPagoRevHist, vMtoUltPagoRev, vTransUltPagoRev,vFolioUltPagoRev,
			   iNumConvHist,iNumPagos,vPromesaPago
		FROM bdicred:sd_indicador_cred_crd
		WHERE empresa = pEmpresa
          and num_credito = pNumcredito;  
		  
		/*
		LET vCantReg = DBINFO("sqlca.sqlerrd2");
        --- Inserta el indicador en Caso de que no exista
        IF vCantReg = 0 THEN
            insert into bdicred:"informix".sd_indicador_cred_crd (empresa,num_credito, fecha_alta)
            values(pempresa,pNumcredito, pFecha );
        END IF;  
       */ 
		
		/*SELECT indicador, canal, sentido				--Que es indicador,canal?
		INTO vPagoCliente, vtipotrans, vlSentido		
		FROM bdicred:sd_transfun		  
		WHERE (codigo_fun = pCodigoFun
			and codigo_ref = pCodigoRef );			  				  */
		
		if (pIndicador =3) and ( pFolio = vFolioultPago ) then --- Verifica Reverso de Ultimo Pago		  
		    --Si es el mismo Folio se regresan los valores anteriores.
			let pFecha     = vFecUltPagoRev ;
			let pMonto     = vMtoUltPagoRev ;
            let pCodigoFun = vTransUltPagoRev;
			let pFolio     = vFolioUltPagoRev;						
			
			if (nvl(vFolioUltPagoRev,'')  ='')  then let vRevPAGO ='V'; end if;			
			
			let vfecultpagoRev = null;
			let vmtoUltpagoRev= null;
            let vtransUltpagoRev= null;
			let vFolioUltPagoRev= null;						
			LET vMtoReversion = vMtoUltPago;  
	  
		elif (pIndicador =3) and ( pFolio = vFolioUltPagoRev ) then	
		    let vfecultpagoRev 	= null;
			let vmtoUltpagoRev	= null;
            let vtransUltpagoRev= null;
			let vFolioUltPagoRev= null;
			
		elif (pIndicador =3) and ( pFolio <> vFolioultPago ) then 
           let bContinua = 'F'; 	
		end if;		  
		
		-- Pagos | Abonos
		---Monto Acumulado es igual al Monto de la transaccion y el Numero de transacciÃ³n es 1
		LET vNumTrans	= 1;
		---Monto Acumulado es igual al Monto de la transaccion y el Numero de transacciÃ³n es 1
		IF (pIndicador =3) and (bContinua ='V') THEN  
		  LET pMonto = (Nvl(vMtoReversion,0)) * -1;		
		  LET vNumTrans = -1; 
		END IF;
		
		  update bdicred:"informix".sd_indicador_cred_crd		           
		   set fecha_ultimo_pago 	= pfecha,
		   monto_ultimo_pago 		= pMonto,
		   trans_ultimo_pago 		= pCodigoFun, --pTransacc
		   folio_ultimo_pago 		= pFolio,						   		
		   num_pagos_hist   		= nvl(num_pagos_hist,0) +vnumtrans,
		   monto_pagos 				= nvl(monto_pagos,0)+pMonto,
		   fecha_ultimo_pago_rev 	= vFecUltPagoRev,
	       monto_ultimo_pago_rev	= vMtoUltPagoRev,
	       trans_ultimo_pago_rev	= vTransUltPagoRev,
		   folio_ultimo_pago_rev	= vFolioUltPagoRev
	--no   reverso_ultimo_pago 		= vRevPago 
		   where empresa 			= pempresa
		   and num_credito 			= pnumcredito;	  	 
		   
		-- AL CORTE
		IF dtFechaActual = dtFechaProxPago THEN		
			UPDATE bdicred:"informix".sd_indicador_cred_crd	
			SET monto_pagos_ch	= CASE WHEN monto_pagos IS NULL OR monto_pagos = '' THEN 0 ELSE monto_pagos END, 
				monto_pagos = 0
			WHERE empresa = pempresa AND num_credito = pNumCredito;	
		END IF;	
		
    RETURN cCod_ret;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se inserta o actualiza indicadores de CrÃ©dito de Plazo, Reestructuras',
'AUTOR : Anayeli Alba Cano',
'FECHA : 01/Septiembre/2018',
'BD: BDICRED',
'VERSION:201108.1805';

CREATE PROCEDURE "informix".sp_depura_sd_detalle_edoctacrd()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 		INTEGER;
DEFINE isam_err 	INTEGER;
DEFINE error_info	CHAR(150);
DEFINE cMensaje 	CHAR(150);
DEFINE cCod_ret     CHAR(6);
DEFINE vrowid       INTEGER;
DEFINE VlNumCredito	CHAR(20);
DEFINE iCont		INTEGER;
DEFINE cValor		CHAR(1);
DEFINE dFecha		DATE;	

	--SET DEBUG FILE TO "/informix/c91691184/sp_depura_sd_detalle_edoctacrd_trace.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select trim(valor) into cValor 
	from "informix".sd_param 
	where empresa = '001' and cod_param = 'DT7';

	select date((pri_dia_mes - 1 units year) - 1 units day) into dFecha 
	from "informix".sd_fechas
	where empresa = '001';

	select count(*) into iCont 
	from "informix".temp_creditos_depurar7;

	if iCont > 0 and cValor = '1' then

		update "informix".sd_param set valor = '2'
		where empresa = '001' and cod_param = 'DT7';

	ELIF iCont > 0 and cValor = '0' then

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

    FOREACH WITH HOLD

		select num_credito
		into VlNumCredito  
		from "informix".temp_creditos_depurar7

		BEGIN WORK;

			DELETE FROM bdicred:"informix".sd_detalle_edoctacrd 
			WHERE num_credito = VlNumCredito and fecha_emision <= dFecha;
			delete from "informix".temp_creditos_depurar7 where num_credito = VlNumCredito;

		COMMIT WORK;

	END FOREACH;

	update "informix".sd_param set valor = '0'
	where empresa = '001' and cod_param = 'DT7';

	RETURN cCod_ret;

	END;

END PROCEDURE;