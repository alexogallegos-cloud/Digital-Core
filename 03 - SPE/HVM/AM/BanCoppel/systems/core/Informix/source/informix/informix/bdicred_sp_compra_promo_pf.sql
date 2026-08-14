CREATE PROCEDURE "informix".sp_compra_promo_pf(pEmpresa CHAR(3), pSucursal CHAR(4), pEjecutivo CHAR(8), pCanal SMALLINT, pNumCredito CHAR(20), pFolioMovto CHAR(16), pPlazo SMALLINT)
RETURNING
	CHAR(5) 	  AS cod_ret,
	CHAR(20) 	  AS contrato_credito,
	CHAR(16) 	  AS folio_operacion,
	DECIMAL(18,2) AS monto_mensual,
	DECIMAL(18,2) AS monto_a_diferir,
	SMALLINT      AS plazo_contratado,
	DECIMAL(18,2) AS tasa_contratada,	
	DECIMAL(18,2) AS monto_total_a_pagar,
	DATE AS fecha_primera_cuota,
	DATETIME YEAR TO SECOND  AS fecha_hora_operacion;
	
    DEFINE sql_err             	 INTEGER;
    DEFINE exec_sp             	 INTEGER;
	DEFINE cFolio_operacion      CHAR(16);
	DEFINE cContratoNumCredito   CHAR(20);
	DEFINE cMonto_mensual        DECIMAL(18,2);	
	DEFINE cMonto_a_diferir      DECIMAL(18,2);	
	DEFINE cPlazo_contratado     SMALLINT;
	DEFINE cTasa_contratada      DECIMAL(18,2);
	DEFINE cMonto_total_a_pagar  DECIMAL(18,2);
	DEFINE cFecha_primera_cuota  DATE;
	DEFINE cFecha_hora_operacion  DATETIME  YEAR TO SECOND; 
	
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(6);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE dMonto				DECIMAL(18,2);
	DEFINE sPlazo				SMALLINT;
	DEFINE vcNumCredito			VARCHAR(20);
	DEFINE cNumTarjeta          CHAR(20);
    DEFINE cNumcte              CHAR(9);
	DEFINE vcNumCte				CHAR(20);
	DEFINE cSucursal			CHAR(4);
	DEFINE dPromoMovSelect		SMALLINT;


	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
	DEFINE cCodRetGF			CHAR(6);
	DEFINE cFolioSucGF			CHAR(16);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE LA PROYECCION
	DEFINE dPagoMensualPP		DECIMAL(18,2);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE principal
	DEFINE cCodRetPrin			CHAR(5);
	DEFINE dRemanentePrin		DECIMAL(18,2);
	DEFINE dIntMoratorioPrin	DECIMAL(18,2);
	DEFINE dIntVencidoPrin		DECIMAL(18,2);
	DEFINE dCapVencidoPrin		DECIMAL(18,2);
	DEFINE dIntVigentePrin		DECIMAL(18,2);
	DEFINE dCapVigentePrin		DECIMAL(18,2);
	DEFINE dImpuestoPrin		DECIMAL(18,2);
	DEFINE dComisionesPrin		DECIMAL(18,2);
	DEFINE dSeguroPrin			DECIMAL(18,2);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE ASIGNACION DE NUMERO DE SOLICITUD
	DEFINE cCodRetANS			CHAR(5);
	DEFINE cNumSolANS			CHAR(20);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE APERTURA DE PRESTAMO
	DEFINE cCodRetAP			CHAR(6);
	DEFINE dTasaInteres			DECIMAL(18,2);
	DEFINE dTasaMora			DECIMAL(18,2);
	DEFINE dCatIva		    	DECIMAL(18,2);
	DEFINE cMercadeo			CHAR(1);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE REVERSION
	DEFINE cCodRetRev			CHAR(5);

	--VARIABLES PARA CACHAR EL VALOR DEL PROCEDIMIENTO DE LA APERTURA DE LA COMPRA A MESES.
	DEFINE cCodRetGenMov		CHAR(10);
	DEFINE cMsjeGenMov		    CHAR(80);
    DEFINE vDivisa              CHAR(2);
    DEFINE v_dv                 CHAR(2);
    DEFINE v_tipocambio         DECIMAL(14,6);
    DEFINE vsucorig             CHAR(4);
    DEFINE dtFechaHoy        DATE;    --> FMV 4-AGO-14: Fecha  Apertura
	DEFINE sCountExists			SMALLINT;
	DEFINE sYield				INTEGER;

	-- JHQS INC 27 127 {
	DEFINE vReferencia			VARCHAR(40);
	DEFINE vReferencia2			VARCHAR(40);
	DEFINE cTipoContrato		CHAR(3);
	
	DEFINE cNumProducto        CHAR(4);
	DEFINE cTransacc           CHAR(4);
	DEFINE dInterIvaPlazoMax   DECIMAL(18,2);
	
    DEFINE dLstTransac          LIST(VARCHAR(4) NOT NULL);
    DEFINE dLstTransacDispo     LIST(VARCHAR(4) NOT NULL);
    DEFINE dLstTransacCompras   LIST(VARCHAR(4) NOT NULL);
	DEFINE dmontoMin			DECIMAL(18, 2);	
	
	DEFINE dtFechaCorte			DATE;
	
	-- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_proyecta_prest_credisol
	DEFINE c_CodigoRet_pp               CHAR(6);
    DEFINE i_Periodo_pp                 INTEGER;
    DEFINE d_FechaCouta_pp              DATE;
    DEFINE dd_SaldoInicial_pp           DECIMAL(18,2);
    DEFINE dd_Mensualidad_pp            DECIMAL(18,2);
    DEFINE dd_Mensualidad_aux_pp        DECIMAL(18,2);
    DEFINE dd_Intereses_pp              DECIMAL(18,2);
    DEFINE dd_IvaInteres_pp             DECIMAL(18,2);
    DEFINE dd_Capital_pp                DECIMAL(18,2);
    DEFINE dd_SaldoFinal_pp             DECIMAL(18,2);
    DEFINE dd_SaldoFinal_aux_pp         DECIMAL(18,2);
    DEFINE s_DiasPeriodo_pp             SMALLINT;
    DEFINE d_FechaAper_pp               DATE;
    DEFINE c_NumMesesPago_pp            CHAR(3);
	DEFINE iContador                    INTEGER;
    DEFINE iTasa1				        DECIMAL(18,2);
	DEFINE vcNomPromocion               CHAR(50);
	DEFINE iDisposicionEfectivoApp      SMALLINT;
	DEFINE iComprasApp                  SMALLINT;

	--
   	DEFINE isam_err              SMALLINT;
   	DEFINE error_info            CHAR(40);
	
	--VARIABLE PARA TASA
    DEFINE vListDispo               	LVARCHAR;
    DEFINE vListCompra              	LVARCHAR;
    DEFINE vListTransacte           	LVARCHAR;
    DEFINE vListPromos              	LVARCHAR;
	 
	LET dtFechaCorte 		= DATE(1);
	LET vcNomPromocion      ='';

	LET sql_err             = 0;
	LET vReferencia 		= '';
	LET	vReferencia2 		= '';
	-- } JHQS INC 27 127
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '000000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET dMonto				= 0.0;
	LET sPlazo				= 0;
	LET vcNumCredito		= '';
	LET cContratoNumCredito = '';
	LET cNumTarjeta         = '';
	LET cNumcte             = '';
	LET vcNumCte			= '';
	LET cSucursal			= '';
	LET dPromoMovSelect		= 0;
	
	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
	LET cCodRetGF			= '000000';
	LET cFolioSucGF			= '';

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE LA PROYECCION
	LET dPagoMensualPP		= 0.0;

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE principal
	LET cCodRetPrin			= '';
	LET dRemanentePrin		= 0.0;
	LET dIntMoratorioPrin	= 0.0;
	LET dIntVencidoPrin		= 0.0;
	LET dCapVencidoPrin		= 0.0;
	LET dIntVigentePrin		= 0.0;
	LET dCapVigentePrin		= 0.0;
	LET dImpuestoPrin		= 0.0;
	LET dComisionesPrin		= 0.0;
	LET dSeguroPrin			= 0.0;

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE ASIGNACION DE NUMERO DE SOLICITUD
	LET cCodRetANS			= '';
	LET cNumSolANS			= '';

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE APERTURA DE PRESTAMO
	LET cCodRetAP			= '000000';
	LET dTasaInteres		= 0.0;
	LET dTasaMora			= 0.0;
	LET dCatIva		    	= 0.0;
	LET cMercadeo			= '';

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE REVERSION
	LET cCodRetRev			= '00000';

	--VARIABLES PARA CACHAR EL VALOR DEL PROCEDIMIENTO DE LA APERTURA DE LA COMPRA A MESES.
	LET cCodRetGenMov		= "";
	LET cMsjeGenMov		    = "";
    LET vDivisa             = "00";
    LET v_dv                = "00";
    LET v_tipocambio        = 0;
    LET vsucorig            = "";
    LET dtFechaHoy       = '';
	LET sCountExists		= 0;
	LET sYield 				= 0;
	LET cTipoContrato		= '';
	
	LET cFolio_operacion       = '';
	LET cMonto_mensual         = 0.00;
	LET cMonto_a_diferir       = 0.00;
	LET cPlazo_contratado      = 0;
	LET cTasa_contratada       = 0.00;
	LET cMonto_total_a_pagar   = 0.00;
	LET cFecha_primera_cuota   = DATE(1);
	LET cFecha_hora_operacion  = CURRENT YEAR TO SECOND;
	LET cNumProducto           = '';
	LET cTransacc              = '';
	LET dInterIvaPlazoMax      = 0.0;
	
	
    LET dLstTransac         = 'LIST{}';
	LET dLstTransacDispo     		= 'LIST{}';
	LET dLstTransacCompras     		= 'LIST{}';
	LET dmontoMin			= 0.00;	
	LET exec_sp             = 0;
	
	
	-- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_proyecta_prest_credisol
	LET c_CodigoRet_pp              = '';
    LET i_Periodo_pp                = 0;
    LET d_FechaCouta_pp             = MDY(1,1,1900);
    LET dd_SaldoInicial_pp          = 0.0;
    LET dd_Mensualidad_pp           = 0.0;
    LET dd_Mensualidad_aux_pp       = 0.0;
    LET dd_Intereses_pp             = 0.0;
    LET dd_IvaInteres_pp            = 0.0;
    LET dd_Capital_pp               = 0.0;
    LET dd_SaldoFinal_pp            = 0.0;
    LET dd_SaldoFinal_aux_pp        = 0.0;
    LET s_DiasPeriodo_pp            = 0;
    LET d_FechaAper_pp              = MDY(1,1,1900);
    LET c_NumMesesPago_pp           = '';
	LET iContador					= 0; 
	
	LET iTasa1                      = 0.00;
	LET iDisposicionEfectivoApp     = 7;
	LET iComprasApp                 = 8;
	


BEGIN	
    ON EXCEPTION SET sql_err, isam_err, error_info	
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			LET cMensajeRet = cErrorInfo;
		END IF
		
		IF exec_sp = 5 THEN 
			LET cCodRetAP = sql_err;
		ELIF exec_sp = 4 THEN 
			LET cCodRetANS = sql_err;
		ELIF exec_sp = 3 THEN  
			LET cCodRetPrin = sql_err;
		ELIF exec_sp = 2 THEN  
			LET cCodRetGenMov = sql_err; 
		ELIF exec_sp = 1 THEN 
			LET c_CodigoRet_pp = sql_err;
		END IF 	
     END EXCEPTION WITH RESUME;

	 ON EXCEPTION IN (-535)
      	ROLLBACK WORK;
	 END EXCEPTION WITH RESUME;
   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    
      
 	  --SET DEBUG FILE TO '/aplicacion/pisabanco/sp_compra_promo_pf_' || TRIM(pFolioMovto) || '_' || TRIM(pNumCredito) || '.out';
	  --TRACE ON;	


	--VALIDACIONES CORE
	EXECUTE PROCEDURE "informix".sp_pf_validaciones_core(pEmpresa, pSucursal, pEjecutivo, pCanal, pNumCredito, 1)
	INTO cCodRet, cMensajeRet, cNumcte, vcNumCredito, cNumProducto, dmontoMin, dtFechaCorte, vListPromos, vListDispo, vListCompra, vListTransacte, dtFechaHoy;
	
	IF cCodRet::INTEGER > 0 THEN
		RETURN cCodRet,cContratoNumCredito,TRIM(cFolio_operacion),NVL(cMonto_mensual,0.00),NVL(cMonto_a_diferir,0.00),NVL(cPlazo_contratado,0),NVL(cTasa_contratada,0.00),NVL(cMonto_total_a_pagar,0.00),cFecha_primera_cuota,cFecha_hora_operacion;	
	ELSE

		--Inicializamos las listas
		LET dLstTransac        = vListTransacte;
		LET dLstTransacDispo   = vListDispo;
		LET dLstTransacCompras = vListCompra;
		
		SELECT LIMIT 1 a.num_tarjeta, b.num_credito, b.num_producto, b.numcte, b.sucursal
		INTO cNumTarjeta, vcNumCredito, cNumProducto, vcNumCte,cSucursal
		FROM "informix".sd_tarjeta a, "informix".sd_maecred b
		WHERE a.empresa = b.empresa
		AND a.num_credito = b.num_credito
		AND a.num_credito = pNumCredito
		AND a.tipo_tarjeta = 'T'
		AND a.status_tar IN ('A', 'I')
		AND b.status_cred in ('AA', 'E1');


		IF NVL(vcNumCredito,'') = '' THEN
			LET cCodRet = '00439';
			LET cMensajeRet = 'NUMERO DE CREDITO NO ESTA VIGENTE O NO ES VALIDO';
			RETURN cCodRet,cContratoNumCredito,TRIM(cFolio_operacion),NVL(cMonto_mensual,0.00),NVL(cMonto_a_diferir,0.00),NVL(cPlazo_contratado,0),NVL(cTasa_contratada,0.00),NVL(cMonto_total_a_pagar,0.00),cFecha_primera_cuota,cFecha_hora_operacion;
		END IF
		
	END IF;
	
	SELECT pEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
		 ||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
		 ||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
		 ||lpad(bdicheq:sp_random(),2,'0')
	INTO cFolioSucGF 
	FROM sysmaster:sysshmvals;
	
	LET cFolio_operacion = cFolioSucGF;
		-------
		-- Valida folio no exista y lo recalcula si existe
		LET sCountExists = 0;  
		SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito 
		 WHERE empresa = '001' AND folio_suc = cFolioSucGF;
		IF sCountExists > 0 THEN
			SELECT pEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
				||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
				||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
				||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
			  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
		END IF;
		
		SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;

		SELECT precio_venta
		  INTO v_tipocambio
		  FROM bdinteg:"informix".si_tpcambio
		 WHERE empresa = "001"
		   AND divisa = v_dv
		   AND clase_tpcambio = "O"
		   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
					   FROM bdinteg:"informix".si_tpcambio
					  WHERE empresa = "001"
						AND divisa = v_dv);
		
	    LET exec_sp = 0;
		
		LET cPlazo_contratado = pPlazo;
	 
	--OBTENEMOS LOS MOVIMIENTOS DE COMPRAS A COMERCIO EN UN RANGO DE FECHAS ENTRE LA FECHA CORTE Y LA FECHA DE HOY DE LAS PROMOCIONES
	SELECT LIMIT 1  monto, transacc_suc
		INTO dmonto,cTransacc
		FROM (
				SELECT  a.monto,a.transacc_suc
				FROM bdicred:"informix".sd_movdia a
				WHERE a.transacc_suc IN dLstTransac 
					AND a.num_credito= pNumCredito
					AND a.folio_suc = pFolioMovto
					AND a.folio_suc NOT IN (SELECT folio_movto FROM bdicred:sd_promocion_credito WHERE num_credito = pNumCredito AND status IN (2,0,6,7))
					AND a.monto >= dmontoMin
					AND a.reversado = 'N'
				UNION ALL
				SELECT b.monto,b.transacc_suc 
				FROM bdicred:"informix".sd_movhis b
				WHERE b.transacc_suc IN dLstTransac 
					AND b.monto >= dmontoMin
					AND b.num_credito= pNumCredito
					AND b.folio_suc = pFolioMovto
					AND b.folio_suc	 NOT IN (SELECT folio_movto FROM bdicred:sd_promocion_credito WHERE num_credito = pNumCredito AND status IN (2,0,6,7))
					AND b.reversado = 'N'
					AND b.fecha_mov BETWEEN dtFechaCorte AND dtFechaHoy  
			) AS tb_mov;
				
	LET cMonto_a_diferir =  dmonto;		
	
	IF(cTransacc IS NULL OR cTransacc ='')THEN
		LET cCodRet = '00009';
		LET cMensajeRet = 'NO SE ENCONTRARON MOVIMIENTOS DISPONIBLES';
		RETURN cCodRet,cContratoNumCredito,TRIM(cFolio_operacion),NVL(cMonto_mensual,0.00),NVL(cMonto_a_diferir,0.00),NVL(cPlazo_contratado,0),NVL(cTasa_contratada,0.00),NVL(cMonto_total_a_pagar,0.00),cFecha_primera_cuota,cFecha_hora_operacion;
	END IF;
		
			
		IF cTransacc IN dLstTransacDispo THEN
			LET dPromoMovSelect = NVL(iDisposicionEfectivoApp,0);
		END IF;
		
		IF cTransacc IN dLstTransacCompras THEN
			LET dPromoMovSelect = NVL(iComprasApp,0);
		END IF;

	
		   
		-- INICIALIZA VARIABLES QUE REGRESAN LOS PROCESOS DE LA PROYECCION Y EL PRINCIPAL
		LET dPagoMensualPP		= 0.0;
		LET cCodRetPrin			= '';
		LET dRemanentePrin		= 0.0;
		LET dIntMoratorioPrin	= 0.0;
		LET dIntVencidoPrin		= 0.0;
		LET dCapVencidoPrin		= 0.0;
		LET dIntVigentePrin		= 0.0;
		LET dCapVigentePrin		= 0.0;
		LET dImpuestoPrin		= 0.0;
		LET dComisionesPrin		= 0.0;
		LET dSeguroPrin			= 0.0;

		---PROTECTAR dInterIvaPlazoMax
		FOREACH
			EXECUTE PROCEDURE "informix".sp_pf_consulta_tasa_plazo_preferenciales(1, pEmpresa, pCanal, pNumCredito, cNumProducto, dPromoMovSelect, dmonto, pPlazo, dtFechaHoy)
			INTO cCodRet, iTasa1, pPlazo
		END FOREACH;

		IF cCodRet::INTEGER <> 0 OR cCodRet IS NULL  THEN		
			LET cMensajeRet = 'VALIDE EL PLAZO/TASA SELECCIONADO';
			RETURN cCodRet,cContratoNumCredito,TRIM(cFolio_operacion),NVL(cMonto_mensual,0.00),NVL(cMonto_a_diferir,0.00),NVL(cPlazo_contratado,0),NVL(cTasa_contratada,0.00),NVL(cMonto_total_a_pagar,0.00),cFecha_primera_cuota,cFecha_hora_operacion;
		END IF;
		
		LET exec_sp = 1;
		FOREACH 

			EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(dmonto,pPlazo::INTEGER,0,'6900',cSucursal,1,0,vcNumCredito,null,1,dPromoMovSelect::INTEGER, '2', iTasa1)
			INTO c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp    

			IF  c_CodigoRet_pp IS NULL OR c_CodigoRet_pp::INTEGER <> 0  OR  c_CodigoRet_pp = '' THEN
				LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
				CONTINUE FOREACH;
			END IF;

			LET iContador = iContador + 1;
			IF iContador = 1 THEN
				LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
				LET cFecha_primera_cuota = d_FechaCouta_pp;
			END IF;
			LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;                               
		END FOREACH;

		IF c_CodigoRet_pp IS NULL OR c_CodigoRet_pp::INTEGER <> 0  OR c_CodigoRet_pp = '' THEN
			LET cCodRet = '00005';
			RETURN cCodRet,cContratoNumCredito,TRIM(cFolio_operacion),NVL(cMonto_mensual,0.00),NVL(cMonto_a_diferir,0.00),NVL(cPlazo_contratado,0),NVL(cTasa_contratada,0.00),NVL(cMonto_total_a_pagar,0.00),cFecha_primera_cuota,cFecha_hora_operacion;
		END IF;

		LET dInterIvaPlazoMax =  dd_SaldoFinal_pp - cMonto_a_diferir;
		LET cMonto_mensual = dd_Mensualidad_pp;
		LET cNumcte =  TRIM(NVL(vcNumCte,''));
		
		
		SELECT TRIM(nombre_promo) INTO vcNomPromocion FROM bdicred:"informix".sd_promocion 
		WHERE num_promo = dPromoMovSelect;
		--IF vcNomPromocion TODO:: VAL EXISTA 
		IF EXISTS (SELECT * FROM "informix".sd_promocion_credito WHERE num_credito=pNumCredito AND folio_movto=pFolioMovto AND status='4') THEN
			DELETE FROM "informix".sd_promocion_credito WHERE num_credito=pNumCredito AND folio_movto=pFolioMovto AND status='4';
		END IF;
		
		BEGIN WORK;
			LET vReferencia = cFolioSucGF;
			INSERT INTO "informix".sd_promocion_credito(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
			VALUES ('001','06',dPromoMovSelect,dtFechaHoy,pEjecutivo,cNumcte, pNumCredito,cNumTarjeta,pPlazo,cFolioSucGF,cMonto_a_diferir,dInterIvaPlazoMax,cMonto_mensual,0,vcNomPromocion,cSucursal,'','6900',pFolioMovto);
			-- REALIZA EL RETENIDO POR EL MONTO DE LOS INTERESES E IVA PARA EVITAR EL SOBREGIRO
			INSERT INTO "informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
			VALUES('001',pNumCredito,cFolioSucGF,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'6837',0,dInterIvaPlazoMax,pEjecutivo,'R',cFolioSucGF||' RET. CREDISOLUCIONES',cSucursal,0);
			-- ACTUALIZA EL SALDO RETENIDO EN EL MAESTRO DE SALDOS
			UPDATE "informix".sd_maesdos
				SET sdo_retenido = sdo_retenido + dInterIvaPlazoMax
			WHERE num_credito = pNumCredito
			AND empresa = '001';
		COMMIT WORK;
		-- GENERAMOS EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES
		LET exec_sp = 2;
		EXECUTE PROCEDURE "informix".genmov_tc('001',pNumCredito,cNumProducto,dtFechaHoy,dInterIvaPlazoMax,cFolioSucGF,cSucursal,vdivisa,'6837','','RET. de INT. e Iva CS',v_tipocambio,0,pEjecutivo,vsucorig,'','')
		INTO cCodRetGenMov, cMsjeGenMov;

		IF  cCodRetGenMov IS NULL OR cCodRetGenMov::INTEGER <> 0 THEN
			LET cCodRet = '00006';
			LET cMensajeRet = 'OCURRIO UN ERROR EN GENMOV_TC RETINT';
		ELSE

			LET cTasa_contratada = iTasa1;
			LET  cMonto_total_a_pagar= dd_SaldoFinal_pp;
			LET dPagoMensualPP = cMonto_mensual;
			
			-- Se consulta referencias de retenidos en la tabla sd_maeretenido (en caso de que requiera actualizarse estatus por error [sd_promocion_credito.status = 4])	
			LET vReferencia = cFolioSucGF;				
				SELECT pEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
					||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
					||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
					||lpad(bdicheq:sp_random(),2,'0')
				INTO cFolioSucGF 
				FROM sysmaster:sysshmvals;
				LET vReferencia2 = cFolioSucGF;
				LET cFolio_operacion = cFolioSucGF;
					-------
					-- Valida folio no exista y lo recalcula si existe
					LET sCountExists = 0;  
					SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito 
					WHERE empresa = '001' AND folio_suc = cFolioSucGF;
					IF sCountExists > 0 THEN
						SELECT pEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
							||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
							||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
							||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
						INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
					END IF;
			

				LET exec_sp = 3;
				-- MANDA A LLAMAR AL PROCESO LLAMADO PRINCIPAL PARA REALIZAR EL ABONO POR EL MONTO A DIFERIR
				EXECUTE PROCEDURE bdicred:"informix".principal('001',vcNumCredito,1,dMonto,pEjecutivo,cSucursal,cFolioSucGF,'6030')
				INTO cCodRetPrin,dRemanentePrin,dIntMoratorioPrin,dIntVencidoPrin,dCapVencidoPrin,dIntVigentePrin,dCapVigentePrin,dImpuestoPrin,dComisionesPrin,dSeguroPrin;

				IF cCodRetPrin IS NULL OR cCodRetPrin::INTEGER <> 0 THEN
					LET cCodRet = "00008";
					LET cMensajeRet = 'OCURRIO UN ERROR PRINCIPAL ::' ||cCodRetPrin ;
				
				ELSE
					LET cCodRetGF = '000000';

					IF cCodRetGF::INTEGER <> 0 THEN
						LET cCodRet = '00004';
						LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
						-- EXIT FOREACH;
						
					ELSE
						BEGIN WORK;
							INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
							VALUES('001',vcNumCredito,cFolioSucGF,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'6837',0,dMonto,pEjecutivo,'R',vReferencia ||' PAGOS DIFERIDOS',cSucursal,0);
						COMMIT WORK;

						-- GENERAMOS EL MOVIMIENTO DE LA APERTURA DE LA COMPRA A MESES.
						LET exec_sp = 2;
						EXECUTE PROCEDURE bdicred:"informix".genmov_tc('001',vcNumCredito,cNumProducto,dtFechaHoy,dMonto,cFolioSucGF,cSucursal,vDivisa,'6837','','PAGOS DIFERIDOS',v_tipocambio,0,pEjecutivo,vsucorig,'','')
						INTO cCodRetGenMov, cMsjeGenMov;

						IF cCodRetGenMov IS NULL OR cCodRetGenMov::INTEGER <> 0 THEN
							LET cCodRet = '00006';
							LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE APERTURA PF';
							-- EXIT FOREACH;
							
						END IF

							BEGIN WORK;
								-- ACTUALIZA EL SALDO RETENIDO EN EL MAESTRO DE SALDOS
								UPDATE bdicred:"informix".sd_maesdos
								SET sdo_retenido = sdo_retenido + dMonto
								WHERE empresa = '001'
								AND num_credito = vcNumCredito;

							COMMIT WORK;
							LET exec_sp = 4;
							-- MANDA A LLAMAR A EL PROCESO DE ASIGNACION DE SOLICITUD
							EXECUTE PROCEDURE bdisolic:"informix".asigna_numsol('001','6900')
							INTO cCodRetANS, cNumSolANS;
							

							IF cCodRetANS IS NULL OR cCodRetANS::INTEGER <> 0 THEN
								LET cCodRet = '00007';
								LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE LA ASIGNACION DE LA SOLICITUD';
							ELSE
								BEGIN WORK;
									
									-- ACTUALIZA EL NUMERO DE SOLICITUD DEL PRESTAMO EN LA TABLA DE LAS PROMOCIONES
									UPDATE bdicred:"informix".sd_promocion_credito
									SET num_sol_prestamo = cNumSolANS,
										tipo_contrato = cTipoContrato
									WHERE empresa = '001'
									AND num_credito = vcNumCredito
									AND num_promo = dPromoMovSelect
									AND folio_movto = pFolioMovto;

								COMMIT WORK;
								LET exec_sp = 5;
								-- MANDA A LLAMAR AL PROCESO DE APERTURA DE CREDITO DE PRESTAMOS
								EXECUTE PROCEDURE bdicred:"informix".sp_apercred1_credisol('001', cNumSolANS, pEjecutivo, pPlazo, vcNomPromocion, dMonto, '', dPagoMensualPP, pCanal)
								INTO cCodRetAP, dTasaInteres, dTasaMora, dCatIva, cMercadeo;

								IF cCodRetAP IS NULL OR cCodRetAP::INTEGER <> 0 THEN
									LET cCodRet = '00010';
								ELSE
									BEGIN WORK;
										-- ACTUALIZA EL ESTATUS A 2
										UPDATE bdicred:"informix".sd_promocion_credito
										SET status = 2,     --> FMV 4ago14: Aperturado
											fecha = dtFechaHoy
										WHERE empresa = '001'
										AND num_credito = vcNumCredito
										AND num_promo = dPromoMovSelect
										AND folio_movto = pFolioMovto;

										-- ACTUALIZA REGISTRO DE MOV_DIA CON LA APERTURA DEL CREDITO (CREDISOLUCION) APERTURADO
										UPDATE bdicred:sd_movdia SET referencia = cFolioSucGF || ' ' || cNumSolANS
										WHERE num_credito = vcNumCredito AND folio_suc = cFolioSucGF
										AND codigo_fun = '060' AND codigo_ref = 10;
										
										LET cContratoNumCredito = cNumSolANS;   							   
										LET cCodRet = '00000';
									COMMIT WORK;
								END IF
							END IF
					END IF
				END IF
		END IF;

	
	
		
	IF cCodRet <> '00000' THEN

		BEGIN WORK;
			LET exec_sp = 6;
			EXECUTE PROCEDURE bdicred:"informix".reversion('001', cSucursal, pEjecutivo, cFolioSucGF, "M") INTO cCodRetRev;
		COMMIT WORK;
		
		IF cCodRetRev::INTEGER <> 0 OR cCodRetRev IS NULL OR cCodRetRev = '' THEN
		    INSERT INTO bdicred:sd_bitacora_promocion 
		    VALUES('001',vcNumCredito,'reversion',dtFechaHoy,CURRENT,'',dPromoMovSelect,cCodRetRev);
		END IF;
		
		BEGIN WORK;
		
			UPDATE bdicred:"informix".sd_maesdos
			SET sdo_retenido = sdo_retenido - dInterIvaPlazoMax
			WHERE num_credito = vcNumCredito
			AND empresa = '001';
			-- ACTUALIZA EL ESTATUS A 4 COMO  CREDITO QUE SE TRABAJO Y OBTUVO UN ERROR
			UPDATE bdicred:"informix".sd_promocion_credito
			SET status = 4 , num_sol_prestamo = ''      
			WHERE empresa = '001'
			AND num_credito = vcNumCredito
			AND num_promo = dPromoMovSelect
			AND folio_movto = pFolioMovto;

			-- Se agrega cambio de estatus de la tabla sd_maeretenido
			UPDATE "informix".sd_maeretenido SET estatus = 'S'
			WHERE empresa = '001' 
			AND num_credito = vcNumCredito
			AND folio_suc IN(vReferencia, vReferencia2)
			AND estatus = 'R'
			AND fecha = dtFechaHoy;

			-- ACTUALIZA EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES COMO REVERSADO	  
			UPDATE bdicred:"informix".sd_movdia
			SET reversado = "S"
			WHERE num_credito = vcNumCredito
			AND folio_suc IN(vReferencia, vReferencia2);	
			
			INSERT INTO bdicred:sd_bitacora_promocion 
			VALUES('001',vcNumCredito,'sp_compra_promo_pf',dtFechaHoy,CURRENT,'',dPromoMovSelect,cCodRet);
		COMMIT WORK;
    END IF;

	RETURN cCodRet,cContratoNumCredito,TRIM(cFolio_operacion),NVL(cMonto_mensual,0.00),NVL(cMonto_a_diferir,0.00),NVL(cPlazo_contratado,0),NVL(cTasa_contratada,0.00),NVL(cMonto_total_a_pagar,0.00),cFecha_primera_cuota,cFecha_hora_operacion;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: PAGOS FIJOS APP',
'AUTOR: Alexi Sitlali Hernandez Sauceda ',
'FECHA DE CREACION: 09/06/2025',
'AUTOR: Alexi Sitlali Hernandez Sauceda ',
'MODIFICACION: Actualizacion de validaciones para procedimientos internos',
'FECHA DE CREACION: 16/02/2025',
'VERSION: 20120207.1137';

CREATE PROCEDURE "informix".sp_pf_validaciones_core(pEmpresa    CHAR(3),
                                                pSucursal       CHAR(4), 
                                                pEjecutivo      CHAR(8),
                                                pCanal          SMALLINT,
                                                pNumCredito     CHAR(20),
                                                pValidaCompleta SMALLINT
                                                )
RETURNING   CHAR(5)         AS cod_ret,
            CHAR(80)        AS desc_ret,
            CHAR(9)         AS num_cte,
            CHAR(12)        AS num_credito,
            CHAR(4)         AS num_producto,
            DECIMAL(18,2)   AS monto_minimo,
            DATE            AS fecha_corte,
            LVARCHAR        AS promo_disponibles,
            LVARCHAR        AS transacc_disposicion,
            LVARCHAR        AS transacc_compras,
            LVARCHAR        AS transacc_cte,
            DATE            AS fecha_hoy;



    /********** DECLARACION DE VARIABLES ************/
    DEFINE iSqlErr       	            INTEGER;			-- CODIGO DE ERROR
    DEFINE cCodRet     		            CHAR(5); 			-- CODIGO DE RETORNO DE ERROR
    DEFINE cMensajeRet                  CHAR(80);           -- DESCRIPCION DEL CODIGO DE ERROR
    DEFINE c_CodigoRet_pp               CHAR(5);
    DEFINE cNumCredito                  CHAR(20);
    DEFINE cNumcte                      CHAR(9);
    DEFINE cNumProducto                 CHAR(4);
    DEFINE cDisponCred			        CHAR(1);
    DEFINE dtFechaHoy                   DATE;
    DEFINE dtFechaCorte                 DATE;
    DEFINE iNumPromo                    SMALLINT;
    DEFINE iDisposicionEfectivoApp      SMALLINT;
    DEFINE iComprasApp                  SMALLINT;
    DEFINE iPlazo                       SMALLINT;
    DEFINE cTempLst                     LVARCHAR;
    DEFINE cTempLstTrans        	    LVARCHAR;
    DEFINE dLstNumPromo                 LIST(SMALLINT NOT NULL);
    DEFINE dLstTransac                  LIST(VARCHAR(4) NOT NULL);
    DEFINE dLstPromociones              LIST(SMALLINT NOT NULL);
    DEFINE dLstTransacPromo     	    LIST(VARCHAR(4) NOT NULL);
    DEFINE dLstTransacDispo      	    LIST(VARCHAR(4) NOT NULL);
    DEFINE dLstTransacCompras      	    LIST(VARCHAR(4) NOT NULL);
    DEFINE dValorMinDiferir             DECIMAL(18,2);
    DEFINE dTasa                        DECIMAL(18,2);

    /********** VARIABLES CANAL APP  ************/
    DEFINE cEmpresa                     CHAR(3);
    DEFINE iCanalApp                    SMALLINT;
    DEFINE cSucursalApp                 CHAR(4);
    DEFINE cEjecutivoApp                CHAR(8);

    /***** VARIABLES DE CIERRE DE CREDITO *****/
    DEFINE cCierreCred      CHAR(1);
    DEFINE cStatusCred      CHAR(1);
    DEFINE cStatusPres      CHAR(1);
    DEFINE cCodRet3         CHAR(3);
    DEFINE dFechaCierreCred DATE;
    DEFINE dFechaCierrePres DATE;
    DEFINE dFechaHabilAnt   DATE;

    

    /********** INICIALIZACION DE VARIABLES ************/
    LET iSqlErr                     = 0;
    LET cCodRet                     = '00000';
    LET c_CodigoRet_pp              = '';
    LET cMensajeRet                 = 'PROCESO EXITOSO';
    LET dtFechaHoy                  = '';
    LET dtFechaCorte                = '';
    LET cNumCredito                 = '';
    LET cNumcte                     = '';
    LET cNumProducto                = '';
    LET cTempLst                    = '';
    LET cDisponCred                 = '';
    LET dValorMinDiferir            = 0.0;
    LET iDisposicionEfectivoApp     = 7;  --VARIABLE PARA DISPOSICION EN EFECTIVO
    LET iComprasApp                 = 8;  --VARIABLE PARA COMPRAS APP
    LET iNumPromo                   = 0;
    LET dLstNumPromo                = 'LIST{' || cTempLst ||'}';
    LET dLstTransac                 = 'LIST{}';
    LET dLstPromociones             = 'LIST{' || iDisposicionEfectivoApp ||','|| iComprasApp || '}';  
	LET dLstTransacDispo     		= 'LIST{}';
	LET dLstTransacCompras     		= 'LIST{}';
	LET dLstTransacPromo    		= 'LIST{}';
    LET iPlazo                      = 0;
    LET dTasa                       = 0.0;

    /********** VARIABLES CANAL APP  ************/
    LET cEmpresa                    = '001';
    LET iCanalApp                   = 17;
    LET cSucursalApp                = '5011';
    LET cEjecutivoApp               = 'transBPI';

    /***** VARIABLES DE CIERRE DE CREDITO *****/
    LET cCierreCred                 = '';
    LET cStatusCred                 = '';
    LET cStatusPres                 = '';
    LET cCodRet3                    = '000';
    LET dFechaCierreCred            = '';
    LET dFechaCierrePres            = '';
    LET dFechaHabilAnt              = '';




    BEGIN
        ON EXCEPTION  SET iSqlErr
            IF iSqlErr <> 0  THEN
                LET  cCodRet  = '00003';
                LET  cMensajeRet = 'ERROR EN LA EJECUCION DE VALIDACIONES PF';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
            END IF;
        END  EXCEPTION

        --SET DEBUG FILE TO "/home/e99807882/Pagos_fijos/sp_pf_validaciones_core.out";
        --TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        IF LENGTH(pEjecutivo) != 8 THEN
            LET cCodRet = '00001';
            LET cMensajeRet = 'LA LONGITUD DEL EJECUTIVO ES INCORRECTA';
            LET cNumcte = '';
            LET cNumCredito = '';
            LET cNumProducto = '';
            LET dValorMinDiferir = null;
            LET dtFechaCorte = null;
            LET dLstNumPromo = null;
            LET dLstTransacDispo = null;
            LET dLstTransacCompras =null;
            LET dLstTransac = null;
            LET dtFechaHoy = null;
            RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
        END IF;

        IF LENGTH(pSucursal) != 4  THEN
            LET cCodRet = '00001';
            LET cMensajeRet = 'LA LONGITUD DE LA SUCURSAL ES INCORRECTA';
            LET cNumcte = '';
            LET cNumCredito = '';
            LET cNumProducto = '';
            LET dValorMinDiferir = null;
            LET dtFechaCorte = null;
            LET dLstNumPromo = null;
            LET dLstTransacDispo = null;
            LET dLstTransacCompras =null;
            LET dLstTransac = null;
            LET dtFechaHoy = null;
            RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
        END IF;

        IF pCanal = iCanalApp  THEN
            IF  (nvl(pEmpresa, '')  <> cEmpresa      )  OR 
                (nvl(pSucursal,'')  <> cSucursalApp  )  OR 
                (nvl(pEjecutivo,'') <> cEjecutivoApp ) THEN

                LET  cCodRet  = '00022';
                LET  cMensajeRet = 'DATOS INVALIDOS PARA CANAL APP';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;   

            END IF;
        ELSE 
            LET  cCodRet  = '00023';
            LET  cMensajeRet = 'EL CANAL POR EL MOMENTO NO ESTA ACTIVO';
            LET cNumcte = '';
            LET cNumCredito = '';
            LET cNumProducto = '';
            LET dValorMinDiferir = null;
            LET dtFechaCorte = null;
            LET dLstNumPromo = null;
            LET dLstTransacDispo = null;
            LET dLstTransacCompras =null;
            LET dLstTransac = null;
            LET dtFechaHoy = null;
            RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy ;  
        END IF;

        SELECT NVL(ind_disponible,'0'),NVL(ind_cierre,'0'), fecha_hoy
		INTO cDisponCred, cCierreCred, dtFechaHoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pEmpresa;

        -- Obtenemos las fechas Maximas de credito y prestamo
        SELECT 
            MAX(CASE WHEN proceso = 'CierreCred'  THEN fecha END) AS fecha_cierre_cred,
            MAX(CASE WHEN proceso = 'CierrePrest' THEN fecha END) AS fecha_cierre_prest
        INTO dFechaCierreCred, dFechaCierrePres
        FROM bdicred:"informix".sd_contproc 
        WHERE empresa = '001' 
        AND proceso IN ('CierreCred', 'CierrePrest');

        -- Consultamos sus estatus
        -- Credito
        SELECT status_proc INTO cStatusCred FROM bdicred:"informix".sd_contproc 
        WHERE empresa = '001' AND proceso = 'CierreCred' and fecha = dFechaCierreCred; -- fecha_cierre_cred

        --Prestamos
        SELECT status_proc INTO cStatusPres FROM bdicred:"informix".sd_contproc 
        WHERE empresa = '001' AND proceso ='CierrePrest' and fecha = dFechaCierrePres; -- fecha_cierre_prest

        -- Fecha habil
        EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil((dtFechaHoy - 1),'-') INTO cCodRet3, dFechaHabilAnt;

        IF (dFechaCierrePres IS NULL OR dFechaCierrePres = '') OR (dFechaCierreCred IS NULL OR dFechaCierrePres  = '') THEN
            	LET cDisponCred = '0';
				LET cCodRet = '00040';
				LET cMensajeRet = 'SE ESTA EJECUTANDO EL CIERRE DE CREDITOS, INTENTE MAS TARDE';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
				RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
        END IF

        IF NOT (cCierreCred = '1' AND (dFechaCierrePres = dFechaHabilAnt AND UPPER(cStatusPres) = 'F') 
                                  AND (dFechaCierreCred = dFechaHabilAnt AND UPPER(cStatusCred) = 'F')) THEN

            	LET cDisponCred = '0';
				LET cCodRet = '00040';
				LET cMensajeRet = 'SE ESTA EJECUTANDO EL CIERRE DE CREDITOS, INTENTE MAS TARDE';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
				RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
        END IF;

        IF NVL(pNumCredito,'') <> '' THEN

            IF LENGTH(pNumCredito) != 12  THEN
                LET cCodRet = '00001';
                LET cMensajeRet = 'LA LONGITUD DEL NUMERO DE CREDITO ES INCORRECTA';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
            END IF;
            
            --
            SELECT cr.num_credito, num_producto, numcte
            INTO cNumCredito, cNumProducto, cNumcte
            FROM bdicred:"informix".sd_maecred cr inner join  sd_maesdos sd ON (cr.num_credito = sd.num_credito)
            WHERE cr.empresa = pEmpresa AND cr.num_credito = pNumCredito
            AND status_cred ='E1'
            AND sd.monto_vencido = 0;

        ELSE
            LET cNumCredito = pNumCredito;
        END IF;

        IF NVL(cNumCredito,'') = '' THEN
            LET cCodRet = '00439';
            LET cMensajeRet = 'NUMERO DE CREDITO NO ESTA VIGENTE O NO ES VALIDO';
            LET cNumcte = '';
            LET cNumCredito = '';
            LET cNumProducto = '';
            LET dValorMinDiferir = null;
            LET dtFechaCorte = null;
            LET dLstNumPromo = null;
            LET dLstTransacDispo = null;
            LET dLstTransacCompras =null;
            LET dLstTransac = null;
            LET dtFechaHoy = null;
            RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
        END IF

        IF pValidaCompleta = 1 THEN

            --OBTENEMOS EL VALOR MINIMO A DIFERIR
            SELECT valor
            INTO dValorMinDiferir
            FROM bdicred:"informix".sd_param	
            WHERE cod_param  = '029';
                
                --SE VALIDA EL MONTO MINIMO DE COMPRA.
            IF NVL(dValorMinDiferir,0.01) = 0.01 THEN
                LET cCodRet = '00002';          
                LET cMensajeRet = "ERROR AL OBTENER EL PARAMETRO DEL VALOR MINIMO A DIFERIR";
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
            END IF;

            FOREACH 
                SELECT num_promo
                INTO  iNumPromo
                FROM "informix".sd_prospectos
                WHERE num_promo IN dLstPromociones
                AND num_credito = pNumCredito
                AND dtFechaHoy >= fecha_ini
                AND dtFechaHoy <= fecha_fin
                ORDER BY num_promo ASC

                -- OBTENEMOS EL NUMERO DE PROMOCIONES
                IF EXISTS (SELECT nvl(1,0) as existe 
                            FROM "informix".sd_promocion 
                            WHERE num_promo = iNumPromo 
                            AND activo = 1 
                            AND dtFechaHoy >= fechaini_promo 
                            AND dtFechaHoy <= fechafin_promo) THEN
                    
                    --LA PROMOCION EXISTE PERO SE VALIDA QUE TENGA UNA TASA
                    FOREACH
                        EXECUTE PROCEDURE "informix".sp_pf_consulta_tasa_plazo_preferenciales(3, pEmpresa, pCanal, cNumCredito, cNumProducto, iNumPromo, dValorMinDiferir, 1, dtFechaHoy)
                        INTO c_CodigoRet_pp, dTasa, iPlazo

                        IF c_CodigoRet_pp :: INTEGER = 0 THEN 
                            LET cTempLst = TRIM(cTempLst) || iNumPromo || ',';
                        END IF;
                    END FOREACH
                END IF;
            END FOREACH;

            --AGREGAMOS LAS PROMOCIONES A LA LISTA.
            LET cTempLst  = SUBSTRING(cTempLst FROM 1 FOR LENGTH(cTempLst) - 1);
            LET dLstNumPromo = 'LIST{' || TRIM(cTempLst) || '}';

            --VALIDAMOS EN LA LISTA DE PROMOCIONES ESTEN VIGENTES.
            IF (CARDINALITY(dLstNumPromo) == 0 OR dLstNumPromo IS NULL)THEN
                LET cCodRet = '00020';
                LET cMensajeRet = 'EL CANDIDATO NO CUENTA CON PROMOCIONES VIGENTES';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;

                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
            END IF;

            IF EXISTS (SELECT 1 FROM "informix".sd_promocion_credito WHERE num_promo IN (3,6,9) AND status IN (0,2) AND num_credito = pNumCredito) THEN
                LET cCodRet = '00006';
                LET cMensajeRet = 'EL CLIENTE YA CUENTA CON PAGOS FIJOS DE TIPO SALDO ACTIVOS.';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
            END IF;

            -- OBTENEMOS LAS TRANSACCIONES DE LAS PROMOCIONES DISPOCION EN EFECTIVO APP y COMPRAS EN APP. 
            SELECT transacc
            INTO dLstTransacDispo
            FROM "informix".sd_movimientos_promo_camp  
            WHERE num_promo = iDisposicionEfectivoApp;

            SELECT transacc
            INTO dLstTransacCompras
            FROM "informix".sd_movimientos_promo_camp  
            WHERE num_promo = iComprasApp;

            LET cTempLst = '';

            IF 	(CARDINALITY(dLstTransacDispo) == 0 OR dLstTransacDispo IS NULL) OR 
                (CARDINALITY(dLstTransacCompras) == 0 OR dLstTransacCompras IS NULL) THEN
                LET cCodRet = '00021';
                LET cMensajeRet = 'NO SE ENCONTRARON TRANSACCIONES DISPONIBLES';
                LET cNumcte = '';
                LET cNumCredito = '';
                LET cNumProducto = '';
                LET dValorMinDiferir = null;
                LET dtFechaCorte = null;
                LET dLstNumPromo = null;
                LET dLstTransacDispo = null;
                LET dLstTransacCompras =null;
                LET dLstTransac = null;
                LET dtFechaHoy = null;
                RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  

            END IF;

            -- OBTENEMOS UNICAMENTE LAS TRANSACCIONES PERTENECIENTES AL CLIENTE
            FOREACH
                SELECT {+AVOID_FULL ("informix".sd_movimientos_promo_camp) } transacc
                INTO dLstTransacPromo
                FROM "informix".sd_movimientos_promo_camp  
                WHERE num_promo IN dLstNumPromo

                LET cTempLst = cTempLst || REPLACE(REPLACE(dLstTransacPromo::LVARCHAR, 'LIST{',''), '}','') || ',' ;

            END FOREACH
            LET cTempLstTrans = SUBSTRING(cTempLst FROM 1 FOR LENGTH(cTempLst) - 1);
            LET dLstTransac = 'LIST{' || TRIM(cTempLstTrans) || '}';
            LET cTempLst = '';

            --SE VALIDA QUE LA FECHA HOY SEA IGUAL O MENOR QUE LA FECHA CORTE PARA CALCULAR EL RENGO DE FECHAS.
            IF DAY(dtFechaHoy)< 21 THEN         
                --SE CALCULA FECHA CORTE.
                EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaHoy, -2) INTO dtFechaCorte;
                IF TRIM(NVL(dtFechaCorte,'')) = '' THEN         
                    LET cCodRet = '00003';
                    LET cMensajeRet = "ERROR EN LA EJECUCION DE BDICRED:MONTHADD";
                    LET cNumcte = '';
                    LET cNumCredito = '';
                    LET cNumProducto = '';
                    LET dValorMinDiferir = null;
                    LET dtFechaCorte = null;
                    LET dLstNumPromo = null;
                    LET dLstTransacDispo = null;
                    LET dLstTransacCompras =null;
                    LET dLstTransac = null;
                    LET dtFechaHoy = null;
                    RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
                END IF;
                LET dtFechaCorte = MDY(MONTH(dtFechaCorte),20,YEAR(dtFechaCorte));
            ELSE
                EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaHoy, -1)
                INTO dtFechaCorte;
            END IF;
        END IF;
        RETURN cCodRet,cMensajeRet, cNumcte, cNumCredito, cNumProducto, dValorMinDiferir,dtFechaCorte, dLstNumPromo::LVARCHAR, dLstTransacDispo::LVARCHAR, dLstTransacCompras::LVARCHAR, dLstTransac::LVARCHAR, dtFechaHoy;  
    END
END PROCEDURE 
DOCUMENT 'AUTOR: Jose Antonio RamiÂ­rez Franco',
'FECHA: 03/09/2025',
'DESCRIPCION:Este proceso se encarga de validar los pagos fijos para Credisoluciones con promociones de compra y disposicion de efectivo a traves del canal de la aplicacion movil (APP).',
'   1.Validacion de parametros: Se valida la longitud de los parametros de entrada.',
'   2.Validacion del canal: Se valida que el canal sea el 17 (canal de la APP).',
'   3.Verificacion de cierre: Se asegura que no haya un proceso de cierre de creditos en curso.',
'   4.Validacion de credito: Se verifica la existencia y vigencia del numero de credito.',
'   5.Validacion de promociones: Se comprueba si el credito tiene promociones vigentes.',
'   6.Validacion de valor minimo: Se valida el valor minimo de sd_param.',
'   7.Validacion de transacciones: Se verifica si existen transacciones registradas en sd_movimientos_promo_camp para las promociones de disposicion en efectivo y compras.',
'   8.Obtencion de fecha de corte: Se obtiene la fecha de corte y, en caso de error, se muestra un mensaje correspondiente.',
'FECHA: 28/01/2026',
'AUTOR: Jose Antonio Ramirez Franco',
'MODIFICACION: Actualizacion a la validacion de credito se anexa a la consulta que se valide los atrasos del cliente para dictaminar si es candidato a pagos fijos.',
'FECHA: 17/02/2026',
'AUTOR: Jose Antonio Ramirez Franco',
'MODIFICACION: Se anexa validacion en el proceso de cierre tanto de credito como prestamos.',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_sv_aprovisionamiento_oltp()
--EXECUTE PROCEDURE "informix".sp_sv_aprovisionamiento_oltp();
RETURNING VARCHAR (5) as rCODIGO_RETORNO, 
          VARCHAR (255) as rMENSAJE_RESPUESTA;

DEFINE vCODIGO_RETORNO VARCHAR(5);
DEFINE vMENSAJE_RETORNO VARCHAR(120);
DEFINE vsql             LVARCHAR(5000);
DEFINE vIndicadorProceso CHAR(10);	
DEFINE RUTA_ARCHIVOS     VARCHAR(100);
DEFINE RUTA_CARPETA      VARCHAR(100); 
DEFINE RUTA_LOGS         VARCHAR(100); 

DEFINE v_periodo_tc_ini   	DATE;	  		--periodo_tc_ini
DEFINE v_periodo_tc_fin   	DATE;	  		--periodo_tc_fin
DEFINE v_periodo_anterior   DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 	INTEGER;		--dias_periodo_tc
DEFINE  v_periodo             DATE;

DEFINE SQLERR		INTEGER;
DEFINE ISAM_ERR		INTEGER;
DEFINE ERROR_INFO	VARCHAR(80); 
DEFINE v_cod_ret_otro	 CHAR(5);
 
LET vCODIGO_RETORNO = '00000';
LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
LET RUTA_ARCHIVOS = '/Interfaces_SmartVista/INTFZ_TDC_008';
--LET RUTA_ARCHIVOS = '/RESPALDOSNEW/Interfaces_SmartVista/INTFZ_TDC_008';
LET RUTA_CARPETA = '/Envio';
LET RUTA_LOGS = '/Logs';

  LET SQLERR = '';
  LET ISAM_ERR = '';
  LET ERROR_INFO = '';

LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc
LET v_periodo_tc_ini   		  = " ";	--periodo_tc_ini
LET v_periodo_tc_fin   		  = " ";	--periodo_tc_fin
LET v_periodo=mdy(month(current),20, year(current));
LET v_cod_ret_otro = "000";

    --SET DEBUG FILE TO TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_LOGS)||"/debug_sp_sv_aprovisionamiento_oltp.out";
    --TRACE ON;

    BEGIN

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO   TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_LOGS)|| "/excep_sp_sv_aprovisionamiento_oltp.err.out" WITH APPEND;
            TRACE ON;
            
            IF  SQLERR <> 0  THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||current ||' '||' Proceso =>'||vIndicadorProceso;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;

    
----------------------------------------------------------------------------------

    -- Obtener el nombre completo del cliente
    LET vIndicadorProceso =  '1.0.0.0.#';
    LET vsql= '';
    --LET vsql= 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||   
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/si_cliente_sv.unl' ||
                 ' SELECT a.numcte,' ||
                 ' TRIM(NVL(a.nombre1, '' '')) || '' '' || TRIM(NVL(a.nombre2, '' '')) || '' '' || TRIM(NVL(a.apell_paterno, '' '')) || '' '' || TRIM(NVL(a.apell_materno, '' '')) nombre,'||
                 ' NVL(a.rfc, a.rfc_alterno) rfc,'||
                 ' NVL(SUBSTR(YEAR(a.fecha_alta), 3, 2), '' '') fecha_alta,' ||
                 ' a.fecha_alta,'||
                 ' a.sucursal '||       
                 ' FROM bdinteg:si_cliente a '||
                 ' INNER JOIN '||
                 ' bdinteg:si_credito_sv s ' ||
                 ' ON ( s.num_producto = ''4900'' '||
                 ' and a.numcte=s.numcte); "> '|| TRIM(RUTA_ARCHIVOS) ||'/si_cliente_sv.sql';
    system vsql;   

   LET vIndicadorProceso =  '1.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/si_cliente_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '1.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/si_cliente_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '1.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/si_cliente_sv.unl';
        system vsql;
      
	end if	

    -- Obtener la direcciÃ³n (Ãºltima direcciÃ³n activa tipo 1)
	LET vIndicadorProceso =  '1.0.3.#';
    LET vsql= '';
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/si_direcciones_sv.unl' ||  
              ' WITH maxsec AS ( '|| 
              ' SELECT a.numcte, MAX(a.secuencia) AS secuencia '||   
              ' FROM bdinteg:si_direcciones_actual a '||  
              ' INNER JOIN '|| 
              ' bdinteg:si_credito_sv s '|| 
              ' ON ( s.num_producto =  ''4900'' '||  
              ' and a.numcte=s.numcte) '||  
              ' WHERE  a.tipo_dir =  ''1'' '||
              ' GROUP BY a.numcte ) '||  	  
              ' SELECT b.numcte, '||  
              ' NVL(b.numeroextcalle,  ''0'') numeroextcalle, '|| 
              ' NVL(b.numerointcalle,  ''0'') numerointcalle, '|| 
              ' NVL(b.departamento,  ''0'') departamento, '|| 
              ' NVL(b.cod_postal,  ''0'') cod_postal, '|| 
              ' NVL(b.entre_calles,  '' '') entre_calles, '|| 
              ' NVL(b.observaciones,  '' '') observaciones, '|| 
              ' NVL(b.numerociudad, '' '') numerociudad, '|| 
              ' NVL(b.numerocolonia,  '' '') numerocolonia, '|| 
              ' NVL(b.numerocalle,  '' '') numerocalle, '|| 
              ' NVL(b.estado, '' '') estado, '||
              ' TRIM(NVL(c.nombrecalle,'' '')) nombrecalle, '||
              ' TRIM(NVL(e.nombre,'' '')) nombreciudad, '||
              ' TRIM(NVL(f.nombre,'' '')) estado, '||
              ' d.nombrezona, '||			
              ' d.centro, '|| 
              ' d.jefegrupozona, '||			
              ' d.supervisorzona, '||
			  ' d.numerociudadcoppel, '||     
              ' d.numerocolonia, '||
              ' LPAD(p.num_region,2,0) num_region ,'||
              ' LPAD(p.num_ciudad_banco,4,0) num_ciudad_banco,'||
              ' LPAD(p.num_ciudad_coppel,3,0) num_ciudad_coppel'||
              ' FROM bdinteg:si_direcciones_actual b '||  
              ' INNER JOIN maxsec s '||   
              ' ON (b.numcte = s.numcte '||   
              ' AND b.secuencia = s.secuencia) '||
			  ' left join '||
              ' bdinteg:si_estados f '||
              ' on (f.estado=b.estado )'||
			  ' LEFT join '||               
			  ' bdinteg:si_ciudades e '||
              ' on( e.pais=b.pais '||
              ' and e.estado=b.estado '||
              ' and e.ciudad_coppel=b.numerociudad ) '|| 			  
              ' LEFT join '|| 
              ' bdinteg:si_catcalles c '||
              ' on (c.numerocalle=b.numerocalle) '||       
              ' left join'||
              ' bdinteg:si_catzonas d'||
              ' on( d.numerociudad=b.numerociudad '||
              ' and d.numerocolonia=b.numerocolonia )'||
              ' inner join'||
              ' bdicred:sd_centrosimpresion_coppel p'||
              ' on(p.num_ciudad_banco =b.numerociudad);"> '|| TRIM(RUTA_ARCHIVOS) ||'/si_direcciones_sv.sql';
    system vsql;   

    LET vIndicadorProceso =  '2.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/si_direcciones_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '2.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/si_direcciones_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '2.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/si_direcciones_sv.unl';
        system vsql;

	end if	  

    -- Obtener el correo electrÃ³nico mÃ¡s reciente
    LET vIndicadorProceso =  '3.0.0.0.#';    
    LET vsql= '';
    --LET vsql= 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||  
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/si_correos_sv.unl' ||  
              ' with correo(numcte,secuencia) as( ' || 
              ' select a.numcte, NVL(MAX(a.secuencia), 0) ' || 
              ' FROM bdinteg:si_correos a ' || 
              ' inner join ' || 
              ' bdinteg:si_credito_sv s ' || 
              ' ON ( s.num_producto = ''4900'' ' ||  
              ' and a.numcte=s.numcte' || 
              ' and a.status_correo = ''A'') ' ||  
              ' group by  a.numcte) ' ||            
              ' SELECT c.numcte,NVL(c.correo_elec, '' '') ' ||  
              ' FROM bdinteg:si_correos c ' || 
              ' inner join ' || 
              ' correo o' || 
              ' on (c.numcte=o.numcte ' || 
              ' and c.secuencia=o.secuencia ' || 
              ' and c.status_correo = ''A'' ); "> '|| TRIM(RUTA_ARCHIVOS) ||'/si_correos_sv.sql';  
    system vsql;   

    LET vIndicadorProceso =  '3.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/si_correos_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '3.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/si_correos_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '3.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/si_correos_sv.unl';
        system vsql;

	end if	      

    LET vIndicadorProceso =  '4.0.0.0.#';
    LET vsql= '';
    --LET vsql= 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||  
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/sucursales_sv.unl' ||  
              ' with cliente(numcte, sucursal ) as( ' || 
              ' select  a.numcte, a.sucursal ' ||         
              ' FROM bdinteg:si_cliente a ' ||   
              ' INNER JOIN ' ||   
              ' bdinteg:si_credito_sv s ' ||   
              ' ON ( s.num_producto = ''4900'' ' || 
              ' and a.numcte=s.numcte) ' ||              
              ' ) SELECT c.numcte,'||
              ' d.sucursal,'||
              ' d.nombre,'||
              ' d.gerente,'||
              ' d.iva,'||
              ' nvl(t.tel1,'' '') tel1 ' ||       
              ' FROM bdinteg:si_sucursales d ' || 
              ' inner join ' || 
              ' cliente c ' || 
              ' on (d.sucursal=c.sucursal) ' || 
              ' left join ' || 
              ' bdinteg:si_ptf t ' || 
              ' on ( t.id_ptf=c.sucursal ' || 
              ' and t.tipo=''S''); "> '|| TRIM(RUTA_ARCHIVOS) ||'/sucursales_sv.sql';
    system vsql;   

    LET vIndicadorProceso =  '4.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/sucursales_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '4.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/sucursales_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '4.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/sucursales_sv.unl';
        system vsql;

	end if	  


    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   
	
	--......................................
  
    LET vIndicadorProceso =  '6.0.0.0.#';
    let vsql='';
    let vsql ='rm -f '|| TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_CARPETA) || '/aprovisionamiento_oltp_sv.tar';    
    system vsql;  

    --......................................

    LET vIndicadorProceso =  '6.0.0.1.#';
    LET vsql = '';
	LET vsql = ' tar -cf ' ||  TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_CARPETA) || '/aprovisionamiento_oltp_sv.tar ' ||  TRIM(RUTA_ARCHIVOS)|| '/*_sv.unl ';
    SYSTEM vsql;

    --......................................

    LET vIndicadorProceso =  '6.0.0.2.#';  
	let vsql='';
    let vsql ='rm  -f '|| TRIM(RUTA_ARCHIVOS) || '/*_sv.sql';
    system vsql;

    --......................................

    --LET vIndicadorProceso =  '6.0.0.3.#';
    let vsql='';
    let vsql ='rm -f '|| TRIM(RUTA_ARCHIVOS) || '/*_sv.unl';    
    system vsql;

    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>		
    		
    
    End;
      RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
END PROCEDURE;