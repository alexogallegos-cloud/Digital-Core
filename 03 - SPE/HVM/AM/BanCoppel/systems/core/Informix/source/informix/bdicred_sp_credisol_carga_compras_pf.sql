CREATE PROCEDURE "informix".sp_credisol_carga_compras_pf(pEmpresa CHAR(3)) 
RETURNING CHAR(6);


DEFINE iSqlErr 					INTEGER;
DEFINE iIsamErr					INTEGER;
DEFINE cErrorInfo				CHAR(80);
DEFINE cCodRet 					CHAR(6);
DEFINE cCod_retIB				CHAR(6);
DEFINE cMensajeRet				CHAR(80);
DEFINE cProceso     			CHAR(4);
DEFINE dFechaHoy				DATE;
DEFINE cRuta 					CHAR (50);
DEFINE cNomArchivoComp			CHAR (50);
DEFINE cNomArchResultado		CHAR (50);
DEFINE cArchivo_dbload			CHAR(50);
DEFINE cArchivo_log     		CHAR(50);
DEFINE dFechaCampania       	DATETIME YEAR TO SECOND;
DEFINE cNumCredito				CHAR (20);
DEFINE cNumCte					CHAR (20);
DEFINE dContador				DECIMAL(8,2);
DEFINE cSQL  					CHAR (500);
DEFINE cNum_Promo				INTEGER;
DEFINE cUsuario					CHAR(9);
DEFINE cNum_Tarjeta				CHAR(20);
DEFINE sPlazo					SMALLINT;
DEFINE dTasa					DECIMAL(9,2);
DEFINE dMontoCompra				DECIMAL(18,2);
DEFINE cNombre_Promo			CHAR(50);
DEFINE cSucursal				CHAR(4);
DEFINE cFolio_Movto      		CHAR(16);
DEFINE sPlazoMin				SMALLINT;
DEFINE sPlazoMax				SMALLINT;
DEFINE cValidaNumero			CHAR(1);
DEFINE dValorMinDiferir			DECIMAL(18,6);
DEFINE cNumCel					CHAR(20);
DEFINE dCap_vig					DECIMAL(18,2);	
DEFINE dLinea_disp				DECIMAL(18,2);		
DEFINE dSdo_tot_liq				DECIMAL(18,2);	
DEFINE dMonto_linea_cred		DECIMAL(18,2);
DEFINE i_Periodo_pp             INTEGER;			-- Variables para proyecta_prestamo
DEFINE d_FechaCouta_pp          DATE;
DEFINE dd_SaldoInicial_pp       DECIMAL(18,2);
DEFINE dd_Mensualidad_aux_pp	DECIMAL(18,2);
DEFINE dd_Intereses_pp          DECIMAL(18,2);
DEFINE dd_IvaInteres_pp         DECIMAL(18,2);
DEFINE dd_Capital_pp            DECIMAL(18,2);
DEFINE dd_SaldoFinal_aux_pp     DECIMAL(18,2);
DEFINE s_DiasPeriodo_pp         SMALLINT;
DEFINE d_FechaAper_pp           DATE;
DEFINE c_NumMesesPago_pp        CHAR(3);
DEFINE dd_Mensualidad_pp        DECIMAL(18,2);
DEFINE dd_SaldoFinal_pp         DECIMAL(18,2);
DEFINE dMonto_Mensualidad		DECIMAL(18,2);
DEFINE dInterIvaPlazo_Dif		DECIMAL(18,2);
DEFINE dMonto_TotalPagar		DECIMAL(18,2);
DEFINE dtotal_pagar_crds		DECIMAL(18,2);	-- Variable creacion credisolucion
DEFINE dnum_plazo_crds			SMALLINT;
DEFINE dpago_mensual_crds		DECIMAL(18,2);
DEFINE dinteres_iva_crds		DECIMAL(18,2);
DEFINE saldo_tdc_crds			DECIMAL(18,2);
DEFINE dfolio_promo_crds		CHAR(16);
DEFINE cNumProm_proy			SMALLINT;

	

LET iSqlErr 				= 0;
LET iIsamErr				= 0;
LET cErrorInfo				= '';
LET cCodRet 				= '000000';
LET cCod_retIB				= '';
LET cMensajeRet				= '';
LET cProceso     			= '0113';
LET dFechaHoy				= date(1);
LET cRuta 					= '';
LET cNomArchivoComp 		= '';
LET cNomArchResultado		= '';
LET cArchivo_dbload			= '';
LET cArchivo_log     		= '';
LET dFechaCampania 			= CURRENT;
LET cNumCredito				= '';
LET cNumCte					= '';
LET dContador				= 0;
LET cSQL 					= '';
LET cNum_Promo				= '';
LET cUsuario				= '';
LET cNum_Tarjeta			= '';
LET sPlazo					= 0;
LET dTasa					= 0;
LET dMontoCompra			= 0;
LET cNombre_Promo			= '';
LET sPlazoMin				= 0;
LET sPlazoMax				= 0;
LET cValidaNumero			= 0;
LET dValorMinDiferir		= 0;
LET cNumCel					= '';
LET dCap_vig				= 0;
LET dLinea_disp				= 0;
LET dSdo_tot_liq			= 0;	
LET dMonto_linea_cred		= 0;
LET i_Periodo_pp            = 0;			-- Variables para proyecta_prestamo
LET d_FechaCouta_pp         = date(1);
LET dd_SaldoInicial_pp     	= 0;
LET dd_Mensualidad_aux_pp	= 0;
LET dd_Intereses_pp         = 0;
LET dd_IvaInteres_pp        = 0;
LET dd_Capital_pp           = 0;
LET dd_SaldoFinal_aux_pp	= 0;
LET s_DiasPeriodo_pp        = 0;
LET d_FechaAper_pp          = date(1);
LET c_NumMesesPago_pp       = '';
LET dd_Mensualidad_pp       = 0;
LET dd_SaldoFinal_pp        = 0;
LET dMonto_Mensualidad		= 0;
LET dInterIvaPlazo_Dif		= 0;
LET dMonto_TotalPagar		= 0;
LET dtotal_pagar_crds		= 0;
LET dnum_plazo_crds			= 0;
LET dpago_mensual_crds		= 0;
LET dinteres_iva_crds		= 0;
LET saldo_tdc_crds			= 0;
LET dfolio_promo_crds		= '';
LET cNumProm_proy			= 0;




BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cErrorInfo)||'-'||iIsamErr::CHAR||'-'||cNumCredito, '02') Returning cCod_retIB;
			RETURN cCodRet;
       END IF;
    END EXCEPTION;
	   	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  

	--SET DEBUG FILE TO '/informix/mahr/sp_credisol_carga_compras_pf.out';
	--TRACE ON;
	
	SELECT fecha_hoy INTO dFechaHoy FROM "informix".sd_fechas WHERE empresa = pEmpresa;
	
	-- Obtiene parametros para proceso
	SELECT valor INTO cRuta FROM bdicred:sd_param WHERE cod_param = '080';
	--select valor INTO cNomArchivoComp FROM bdicred:sd_param WHERE cod_param = '69';	-- clientescompras
	SELECT valor_alfabetico::SMALLINT INTO sPlazoMin FROM bdicred:sd_param_campania WHERE empresa = pEmpresa AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 15;
	SELECT valor_alfabetico::SMALLINT INTO sPlazoMax FROM bdicred:sd_param_campania WHERE empresa = pEmpresa AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 16;
	SELECT TRIM(valor)::DECIMAL(18,2) INTO dValorMinDiferir FROM bdicred:"informix".sd_param WHERE cod_param  = '029';

	IF cRuta IS NULL THEN LET cRuta = '/resplogifx/archivoscredito/'; END IF;
	--IF cNomArchivoComp IS NULL THEN LET cNomArchivoComp = 'clientescompras'; END IF;
	IF dValorMinDiferir IS NULL THEN LET dValorMinDiferir = 1000; END IF;

	LET cNomArchivoComp = 'clientescamp';	
    LET cNomArchResultado	= "bitacoractescompras";
	LET cArchivo_dbload	  	= "f_ctes_compras.com";
	LET cArchivo_log      	= "f_ctes_compras.log";
	LET dFechaCampania 		= CURRENT;
	
	-- Realiza carga de archivo de compras en tabla temporal.
	LET cNomArchivoComp = TRIM(cNomArchivoComp)||'_'||YEAR(dFechaCampania)||LPAD(MONTH(dFechaCampania),2,0)||LPAD(DAY(dFechaCampania),2,0)||'.unl';                
	LET cNomArchResultado = TRIM(cNomArchResultado)||'_'||YEAR(dFechaCampania)||LPAD(MONTH(dFechaCampania),2,0)||LPAD(DAY(dFechaCampania),2,0)||'.txt'; 
			
	TRUNCATE TABLE bdicred:"informix".sd_credpaso;
					   
	system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cNomArchivoComp) ||' DELIMITER '|| "'" || '|' || "'" || ' 14;' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbload);  
	system ' echo "INSERT INTO sd_credpaso;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbload);
	system 'chmod 777 ' || TRIM(cRuta) || TRIM(cArchivo_dbload);

	system ' echo "date ' || '">' || TRIM(cRuta) || 'dbload_datos_compras.sh';
	system ' echo "dbload -d bdicred -c ' || TRIM(cRuta) || TRIM(cArchivo_dbload)  ||' -l ' || TRIM(cRuta) || TRIM(cArchivo_log) || ' -n 1000 ' || ' " >> ' || TRIM(cRuta)|| 'dbload_datos_compras.sh'; 
	system ' echo "date ' || '">>' || TRIM(cRuta)|| 'dbload_datos_compras.sh';
	system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(cRuta)|| 'dbload_datos_compras.sh';             
	system ' echo "set pdqpriority 0;' || '">>' || TRIM(cRuta)|| 'dbload_datos_compras.sh';          
	system ' echo "update statistics medium for table bdicred:sd_credpaso; ' || '">>' || TRIM(cRuta)|| 'dbload_datos_compras.sh';           
	system ' echo "EOF' || '">>' || TRIM(cRuta)|| 'dbload_datos_compras.sh';           
	system 'chmod 777 ' || TRIM(cRuta)|| 'dbload_datos_compras.sh';

	system '/usr/bin/sh ' || TRIM(cRuta)|| 'dbload_datos_compras.sh';

    SELECT count(*) INTO dContador FROM bdicred:sd_credpaso;
	IF dContador = 0 THEN		--- Si no cargo nada, termina el proceso
		LET cSQL = '';
		LET cSQL = '/usr/bin/echo " EL ARCHIVO SE ENCUENTRA VACIO/INEXISTENTE, O CON ERROR EN SU ESTRUCTURA" > ' || TRIM(cRuta) || TRIM(cNomArchResultado);
		SYSTEM cSQL;			
		LET cCodRet = '000001';
		RETURN cCodRet;
	END IF;
	
	-- Procesa las compras cargadas
	FOREACH WITH HOLD
		SELECT {AVOID_FULL("informix".sd_credpaso)}
			   num_credito, num_cte, num_promo , ejecutivo , num_tarjeta , plazo , tasa , monto_actual, nombre_promo , sucursal , folio_movto 
		  INTO cNumCredito, cNumCte, cNum_Promo, cUsuario, cNum_Tarjeta, sPlazo, dTasa, dMontoCompra, cNombre_Promo, cSucursal, cFolio_Movto
		  FROM bdicred:sd_credpaso
		 --WHERE activo = 1

		 IF cNumCredito IS NULL THEN LET cNumCredito = ''; END IF;
		 IF cNumCte IS NULL THEN LET cNumCte = ''; END IF;
		 IF cNum_Promo IS NULL THEN LET cNum_Promo = ''; END IF;
		 IF cUsuario IS NULL THEN LET cUsuario = 'informix'; END IF;
		 IF cNum_Tarjeta IS NULL THEN LET cNum_Tarjeta = ''; END IF;
		 IF sPlazo IS NULL THEN LET sPlazo = 0; END IF;
		 IF dTasa IS NULL THEN LET dTasa = 0; END IF;
		 IF dMontoCompra IS NULL THEN LET dMontoCompra = 0; END IF;
		 IF cNombre_Promo IS NULL THEN LET cNombre_Promo = ''; END IF;
		 IF cSucursal IS NULL THEN LET cSucursal = ''; END IF;
		 IF cFolio_Movto IS NULL THEN LET cFolio_Movto = ''; END IF;
	
		SELECT count(*) INTO dContador FROM bdicred:sd_maesdos WHERE num_credito = cNumCredito AND (monto_vencido + mto_venc_trasp) = 0;
		
		IF dContador != 1 THEN
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000002', descripcion = 'Num Credito, num cte y/o status erroneos'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			CONTINUE FOREACH; 			 			 
		END IF;
		
		SELECT count(*) INTO dContador FROM bdinteg:si_sucursales WHERE sucursal = cSucursal and tpo_sucursal = 'S';
		IF dContador != 1 THEN
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000003', descripcion = 'Num sucursal erroneo'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			CONTINUE FOREACH; 			 			 
		END IF;		
		  
		SELECT count(*) INTO dContador FROM bdicred:sd_promocion WHERE num_promo = cNum_Promo;
		IF dContador != 1 THEN
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000004', descripcion = 'Numero de promocion erronea'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			CONTINUE FOREACH; 			 			 
		END IF;

		SELECT count(*) INTO dContador FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa AND num_tarjeta = cNum_Tarjeta;
		IF dContador != 1 THEN
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000005', descripcion = 'Numero de tarjeta erroneo'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND num_tarjeta = cNum_Tarjeta;
			CONTINUE FOREACH; 			 			 
		END IF;

		SELECT count(*) INTO dContador FROM bdicred:sd_tarjeta 
		 WHERE empresa = pEmpresa AND num_credito = cNumCredito AND num_tarjeta = cNum_Tarjeta AND numcte = cNumCte;
		IF dContador != 1 THEN
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000006', descripcion = 'Num Tarjeta - Num Credito erroneos'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND num_tarjeta = cNum_Tarjeta;
			CONTINUE FOREACH; 			 
		END IF;

		EXECUTE PROCEDURE bdinteg:sp_esnumerico(sPlazo)INTO cValidaNumero;
		IF cValidaNumero = 'F' OR sPlazo < sPlazoMin OR sPlazo > sPlazoMax THEN 
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000007', descripcion = 'Plazo incorrecto'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			CONTINUE FOREACH;  
		END IF;		
		
		IF dTasa < 0 THEN
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000008', descripcion = 'Tasa incorrecta'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			CONTINUE FOREACH;  		
		END IF;
		
		IF dMontoCompra <= 0 OR dMontoCompra < dValorMinDiferir OR cFolio_Movto = '' THEN
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000009', descripcion = 'Monto compra o folio compra incorrecto'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			CONTINUE FOREACH;  		
		END IF;
		
		SELECT count(*) INTO dContador FROM bdicred:sd_promocion_credito WHERE num_credito = cNumCredito AND folio_movto = cFolio_Movto AND status in (0,2);
		IF dContador != 0 THEN
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000010', descripcion = 'Folio con credisolucion registrada previamente'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			CONTINUE FOREACH;  		
		END IF;
		
		SELECT first 1 telefono INTO cNumCel FROM bdinteg:si_telefonos WHERE numcte = cNumCte AND tipo_tel = 2 AND tipo_tel = 2 AND status_tel = 'A';
		IF cNumCel IS NULL THEN LET cNumCel = ''; END IF;

		-- Obtiene saldos del credito
		SELECT sdo_cap_insoluto, (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)), (sdo_cap_insoluto), monto_otorgado
		  INTO dCap_vig        ,  dLinea_disp                                        ,  dSdo_tot_liq     , dMonto_linea_cred 
		  FROM bdicred:sd_maesdos WHERE num_credito = cNumCredito;			
		
		
		-- Realiza proyecion del monto de la compra	/ No se realiza con sp_proyecta_pfsms ya que lo rechazaria si el saldo es menor al monto de la compra 
		LET dContador = 0;	LET dd_SaldoFinal_pp = 0;	LET dd_Mensualidad_pp = 0;	LET dd_Mensualidad_aux_pp = 0;	LET dMonto_Mensualidad = 0;	LET dInterIvaPlazo_Dif = 0;	LET dMonto_TotalPagar = 0;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(dMontoCompra,sPlazo::INTEGER,0,'6900',cSucursal,1,0,cNumCredito,null,1,cNum_Promo::INTEGER, '1', dTasa) INTO
			cCod_retIB, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, dd_Capital_pp, dd_SaldoFinal_aux_pp, 
			s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

			IF cCod_retIB != '000000' THEN
				UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000011', descripcion = 'Error en la proyeccion'
				 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
				CONTINUE FOREACH;  				
			END IF;
			LET dContador = dContador + 1;
			IF dContador = 1 THEN
				LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
			END IF;
			LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
		END FOREACH;
		LET dMonto_Mensualidad = dd_Mensualidad_pp;
		LET dInterIvaPlazo_Dif = dd_SaldoFinal_pp - dMontoCompra;
		LET dMonto_TotalPagar = dd_SaldoFinal_pp;		
				
		IF dLinea_disp < dInterIvaPlazo_Dif THEN -- Si el saldo disponible es menor al interes e iva diferido = No cubre el diferido
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000012', descripcion = 'Saldo disponible no cubre proyeccion.'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			CONTINUE FOREACH;  						
		END IF;
				
		-- Inserta Registro de sms
		SELECT count(*) INTO dContador FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND folio_compra_sms = cFolio_Movto  AND tipo_sms != '7';
		IF dContador > 0 THEN
			DELETE FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND folio_compra_sms = cFolio_Movto;
		END IF;

		SELECT count(*) INTO dContador FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND folio_compra_sms = cFolio_Movto;
		IF dContador > 0 THEN
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000013', descripcion = 'Folio ya procesado previamente.'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			CONTINUE FOREACH;  		
		END IF;

		
		INSERT INTO bdicred:sd_promocion_credito_sms(empresa, num_credito, num_cte, mnto_compra, folio_compra_sms, fecha_invitacion, tipo_sms, num_promo    , fecha_env_sms_inv, plazos_invita, tasas_invita, fecha_insert,
													 respuesta_cte_sms, fecha_resp_cte_sms, envio_result_sms, status_envio_r_sms, plazo , tasa , num_credisolucion, fecha_cancela, compra_inmd, sms_resp_inmd, tipo_contrato)
											  VALUES('001'  , cNumCredito, cNumCte, dMontoCompra, cFolio_Movto   , dFechaHoy       , '3'     , cNum_Promo   , CURRENT          , sPlazo       , dTasa       , CURRENT, 
													 'S'               , NULL              , NULL            , NULL              , sPlazo, dTasa, NULL             , NULL         , '1'        , '1'          , '');
  
		-- Genera registro de credisolucion en cero 
		EXECUTE PROCEDURE sp_proyecta_pfsms(3, cSucursal, cUsuario, cNum_Promo, cNumCredito, '', dMontoCompra, sPlazo, dTasa, cFolio_Movto)
		   INTO cCod_retIB, cMensajeRet, dtotal_pagar_crds, dnum_plazo_crds, dpago_mensual_crds, dinteres_iva_crds, saldo_tdc_crds, dfolio_promo_crds, cNumProm_proy;
		   
		IF cCod_retIB::SMALLINT != 0 THEN
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000014', descripcion = 'Error al insertar en sd_promocion_credito'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			 
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '8' WHERE num_credito = cNumCredito AND folio_compra_sms = cFolio_Movto AND mnto_compra = dMontoCompra;					 
			CONTINUE FOREACH; 		
		ELSE

			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '7' WHERE num_credito = cNumCredito AND folio_compra_sms = cFolio_Movto AND mnto_compra = dMontoCompra;		
			
			UPDATE bdicred:sd_credpaso SET activo = 0, cod_ret = '000000', descripcion = 'Registro Exitoso. Credisolucion Pendiente.'
			 WHERE num_credito = cNumCredito AND num_cte = cNumCte AND folio_movto = cFolio_Movto;
			 
		END IF;
	END FOREACH;		 
		  
		  
	LET cSQL = '';
	LET cSQL = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchResultado)  ||
	           '  delimiter ''|'' SELECT num_credito,num_cte,num_promo,ejecutivo,num_tarjeta,plazo,tasa,monto_actual,nombre_promo,sucursal,folio_movto,cod_ret,descripcion FROM bdicred:"informix".sd_credpaso" >'||TRIM(cRuta)||'ejec_bit_camp.sql';
	SYSTEM cSQL;				
	LET cSQL='chmod 777 '|| TRIM(cRuta)||'ejec_bit_camp.sql';
	System cSQL;				
	let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'ejec_bit_camp.sql';
	System cSQL;				
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cRuta) || 'ejec_bit_camp.sql';
	SYSTEM cSQL;

	IF cCodRet <> '000000' THEN
		LET cCodRet = '000000';
	END IF;			  
			  

	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Carga compras para realizar contrato de credisoluciones',
'AUTOR: MAHR ',
'FECHA DE CREACION:  Noviembre 2020 ',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_descarga_movhisedocta_credisoluciones(pempresa CHAR(3),pperiodo DATE)
--EXECUTE PROCEDURE "informix".sp_descarga_movhisedocta_credisoluciones('001',MDY('05','20','2023'));
RETURNING CHAR(5);

DEFINE v_ruta      	VARCHAR(255);
DEFINE v_ruta_cfd  	VARCHAR(255);
DEFINE cod_ret     	CHAR(5);
DEFINE sql_err     	INTEGER;
DEFINE v_sql        CHAR(6200);
DEFINE v_sql1       CHAR(1550);
DEFINE v_sql2       CHAR(1550);
DEFINE v_sql3       CHAR(1300);
DEFINE v_sql4       CHAR(800);
DEFINE v_sql5       CHAR(1000);
DEFINE v_sql6       CHAR(10000);
DEFINE cNumCred     CHAR(20);
DEFINE cNumCredAux  CHAR(20);
DEFINE cNumCte      CHAR(20);
DEFINE cNumCteAux   CHAR(20);
DEFINE iMovMax      INTEGER;
DEFINE sPaso        SMALLINT;
DEFINE v_periodo_tc_ini   		  DATE;	  		--periodo_tc_ini
DEFINE v_periodo_tc_fin   		  DATE;	  		--periodo_tc_fin
DEFINE v_periodo_anterior   	  DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		  INTEGER;		--dias_periodo_tc
DEFINE v_cod_ret_otro			  CHAR(5);
DEFINE vNumCredito		CHAR(20);
DEFINE vsecuencia		SMALLINT;
DEFINE Vnum_solpres		CHAR(20);

DEFINE vDiaHoyM	CHAR(02);
DEFINE vDiaHoy  CHAR(02);
DEFINE vMesHoy  CHAR(02);
DEFINE vAnioHoy CHAR(04);

-- MSI
DEFINE vTotalCredSol	INTEGER;
DEFINE vTotalCredMSI	INTEGER;
DEFINE vNumCte			CHAR(20);
DEFINE vNumCred			CHAR(20);
DEFINE vNumTarjeta		CHAR(20);
DEFINE vNumCredMSI		CHAR(20);
DEFINE vCodRet    		CHAR(6);
DEFINE vMsjRet			CHAR(80);
DEFINE vFechaCompra		DATE;
DEFINE vConcepto		CHAR(40);
DEFINE vFolioCompra		CHAR(16);
DEFINE vPagMin			DECIMAL(18,2);
DEFINE vNumPago			CHAR(02);
DEFINE vPlazo			CHAR(02);
DEFINE vSaldoAPagar		DECIMAL(18,2);
DEFINE vSaldoDeudor		DECIMAL(18,2);

DEFINE TotVersMsi	INTEGER;
DEFINE TotBuyMsi 	INTEGER;
DEFINE TotCredMsi	INTEGER;


LET v_ruta      = "";
LET v_sql       = "";
LET v_sql1      = "";
LET v_sql2      = "";
LET v_sql3      = "";
LET v_sql4      = "";
LET v_sql5      = "";
LET v_sql6      = "";
LET sPaso       = 0; 
LET cNumCred    = "";
LET cNumCredAux = "";
LET cNumCte     = "";
LET cNumCteAux  = "";
LET iMovMax     = 0;
LET v_periodo_tc_ini   		  	= " ";	--periodo_tc_ini
LET v_periodo_tc_fin   		  	= " ";	--periodo_tc_fin
LET v_periodo_anterior   		= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		 	 = 0;	--dias_periodo_tc
LET v_cod_ret_otro 	= "000";
LET vNumCredito 	= '';
LET vsecuencia		= 0;
LET Vnum_solpres 	= '';

LET vDiaHoy 	= '';
LET vMesHoy 	= '';
LET vAnioHoy	= '';

-- MSI
LET vTotalCredSol	= 0;
LET vTotalCredMSI	= 0;
LET vNumCte			= '';
LET vNumCred		= '';
LET vNumTarjeta		= '';
LET vNumCredMSI		= '';
LET vCodRet         = '00000';
LET vMsjRet			= 'Consulta pago minimo correcta.';
LET vFechaCompra	= date(1);
LET vConcepto		= '';
LET vFolioCompra	= '';
LET vPagMin			= 0;
LET vNumPago		= '';
LET vPlazo			= '';
LET vSaldoAPagar	= 0;
LET vSaldoDeudor	= 0;
LET vDiaHoyM		= '';

LET TotVersMsi = 0;
LET TotBuyMsi  = 0;
LET TotCredMsi = 0;


set isolation to dirty read;
set lock mode to wait 3;

-- Fecha: 
-- Autor: 
-- Nodificacion: Informacion Base de Credisoluciones para la generacion de los Estados de Cuenta
-- Separando los querys.
 
BEGIN

   ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
				DROP TABLE IF EXISTS tmp_universcredmsi;
				DROP TABLE IF EXISTS tmpCredBuyInfoMSI;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";
   
   --SET DEBUG FILE TO "/informix/Rebeca/sp_descarga_movhisedocta.out";
   --SET DEBUG FILE TO "/informix/ulises/RQI/2023-06-20_RQI_21_308/sps/sp_descarga_movhisedocta_credisol.out";
   --TRACE ON;
   
   SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '039';
   
   --let v_ruta = '/informix/Ulises/RQI/25_200/infoedocta/'; --v_ruta || 'cobranza/';
   EXECUTE PROCEDURE sp_mes_siguiente(pperiodo,-1,DAY(pperiodo))
		INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;
   
   LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
   LET v_periodo_tc_fin = pperiodo;	
   LET vDiaHoyM = 20;
   LET vDiaHoy = DAY(pperiodo)+1;
   LET vMesHoy = LPAD(MONTH(pperiodo::DATE), 2, '0');
   LET vAnioHoy = YEAR(pperiodo);
   
   
   
   -- Elimina informacion de tabla credsol para promocion de credisoluciones
   SELECT COUNT(*) INTO vTotalCredSol FROM cred_sol;

	IF NVL(vTotalCredSol,0) > 0 THEN
		TRUNCATE TABLE "informix".cred_sol;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".cred_sol;
	END IF;
	
	-- Elimina informacion de tabla credmsi para promocion de meses sin intereses
	SELECT COUNT(*) INTO vTotalCredMSI FROM "informix".cred_msi;
	
	IF NVL(vTotalCredMSI,0) > 0 THEN
		TRUNCATE TABLE "informix".cred_msi;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".cred_msi;
	END IF;

		------------------------ Credisoluciones ------------------------------------------------
		LET v_sql1 = ' echo " set isolation to dirty read; '||
		             ' INSERT INTO cred_sol '||
					 ' (fecha_emision, num_credito,num_promo,num_sol_prestamo,folio_suc,plazo,diasmes,fecha, '||
					 ' tasa,sdo_capital,prox_fecha_pago,concepto,capital_mto_cuota,numero_cuotas,secuencia,nlinea,fecha_oper,monto_ori, '||
					 ' int_periodo,iva_int_periodo,num_tar_ori,tipo_tarjeta) ';
		LET v_sql2 = ' SELECT '''||to_char(pperiodo,'%m-%d-%Y')||''', cr.num_credito,promoCred.num_promo, '||
					 ' promoCred.num_sol_prestamo,promoCred.folio_suc,crd.plazo,DAY(promoCred.fecha) diames, '||
					 ' promoCred.fecha, crd.tasa_interes, msdocrd.sdo_cap_insoluto,DATE(1) prox_fecha_pago, '||  
					 ' (CASE WHEN promoCred.num_promo = 1 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 2 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
                     ' WHEN promoCred.num_promo = 3 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
                     ' WHEN promoCred.num_promo = 4 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 5 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 6 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 7 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 8 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 9 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo END) concepto, '||
					 ' amorcrd.capital_mto_cuota, amorcrd.num_pago, 1, 1, crd.fecha_apertura, msdocrd.monto_otorgado, '||
					 ' amorcrd.interes_pagado,amorcrd.iva_pagado, sdtar.num_tarjeta, sdtar.tipo_tarjeta ';
        LET v_sql3 = ' FROM bdicred:sd_maecred cr '||
					' INNER JOIN "informix".sd_promocion_credito promoCred ON cr.num_credito = promoCred.num_credito '||
					' INNER JOIN BDICRED:SD_MAECREDCRD crd ON crd.num_credito = promoCred.num_sol_prestamo '||
					' INNER JOIN sd_amortiza_creditocrd amorcrd ON crd.num_credito = amorcrd.num_credito ' ||
					' INNER JOIN sd_maesdoscrd msdocrd ON msdocrd.num_credito = promoCred.num_sol_prestamo '||
					' LEFT OUTER JOIN sd_tarjeta sdtar ON cr.num_credito = sdtar.num_credito  AND promoCred.num_tarjeta = sdtar.num_tarjeta AND promoCred.num_cte = sdtar.numcte AND sdtar.empresa = ''001'' '||
					' WHERE cr.status_cred in (''E1'',''E2'',''E3'') '||
					' AND crd.num_producto = ''6900'' '||
					' AND crd.status_cred = ''E1'' '||
					' AND amorcrd.fecha_cuota > ''' ||to_char(v_periodo_anterior,'%m-%d-%Y')||''' AND amorcrd.fecha_cuota <= ''' ||to_char(pperiodo,'%m-%d-%Y')||''' '||
					' AND amorcrd.capital_status = ''5'' ';
		LET v_sql4 = '; " >'|| v_ruta||'queryCRESOL.sql';
								
			
        LET v_sql = Trim(v_sql1) || ' ' || Trim(v_sql2) || ' ' ||Trim(v_sql3)|| ' ' ||Trim(v_sql4);
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryCRESOL.sql";
        system v_sql;
		
		Foreach 
		   select num_credito 
		     into vNumCredito
			from cred_sol
			group by num_credito
			
			let VSecuencia = 1;	
			
			Foreach 
			  select num_sol_prestamo
		        into Vnum_solpres
			   from cred_sol
			   where num_credito = vNumCredito
			   
			  update cred_sol 
			    set secuencia = VSecuencia
			  where fecha_emision = pperiodo
			    and num_credito = vNumCredito
                and num_sol_prestamo =	Vnum_solpres;
				
			  let VSecuencia = VSecuencia +1;	
			end foreach;	
		end foreach;  		
		
		LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaCredisolucion.unl '||
		             ' SELECT *  FROM cred_sol " > '||v_ruta ||'queryCredisolucion.sql';
		
		-- SE EJECUTA ARCHIVO DE QUERY PARA OBTENER LA INFORMACION
		LET v_sql = Trim(v_sql1);
		SYSTEM v_sql;
		
		LET v_sql = "dbaccess bdicred "||v_ruta||"queryCredisolucion.sql";
		SYSTEM v_sql;


		-- SE COPIA EL ARCHIVO DE DESCARGA A UNO NUEVO
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaCredisolucion.unl'||" >"||v_ruta||'descargaCredisolucion1.unl';
		SYSTEM v_sql;

		-- SE BORRA EL ARCHIVO DE DESCARGA
        LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'descargaCredisolucion.unl';
		SYSTEM v_sql;

		-- SE COPIA LA INFORMACION DEL ARCHIVO DE DESCARGA AL NUEVO ARCHIVO DE CREDISOLUCION
		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaCredisolucion1.unl'||" > " ||v_ruta||'Edocta_Credisolucion'||'.unl';
		SYSTEM v_sql;

		-- BORRA ARCHIVO DE DESCARGA
        LET v_sql = '';   
		LET v_sql = "rm "||v_ruta||'descargaCredisolucion1.unl';
		SYSTEM v_sql;  

		-- SE BORRA ARCHIVO QUERY
        LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'queryCredisolucion.sql';
		SYSTEM v_sql;  
			
		--'JMAH INI CAT
		LET v_sql6 = ' echo "UNLOAD TO '||v_ruta||'descargacredsolsdoint1.unl'  ||		
		' select a.num_credito ,a.num_sol_prestamo,nvl((c.capvig21 ),0) +  '||
		' nvl((c.capvig22 ),0) +  '||
		' nvl((c.capvig23 ),0) + '||
		' nvl((c.capvig24 ),0) + '||
		' nvl((c.capvig25 ),0) + '||
		' nvl((c.capvig26 ),0) + '||
		' nvl((c.capvig27 ),0) + '||
		' nvl((c.capvig28 ),0) + '||
		' nvl((c.capvig29 ),0) + '||
		' nvl((c.capvig30 ),0) + '||
		' nvl((c.capvig31 ),0) + '||
		' (b.capvig1) + '||
		' (b.capvig2 ) + '||
		' (b.capvig3 ) + '||
		' (b.capvig4 ) + '||
		' (b.capvig5 ) + '||
		' (b.capvig6 ) + '||
		' (b.capvig7 ) + '||
		' (b.capvig8 ) + '||
		' (b.capvig9 ) + '||
		' (b.capvig10 ) +  '||
		' (b.capvig11 ) + '||
		' (b.capvig12 ) + '||
		' (b.capvig13 ) + '||
		' (b.capvig14 ) + '||
		' (b.capvig15 ) + '||
		' (b.capvig16 ) + '||
		' (b.capvig17 ) + '||
		' (b.capvig18 ) + '||
		'  nvl((b.capvig19 ),0)  + '||
		' nvl((b.capvig20 ),0)  , '||
		' round((b.capvig1 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig2 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig3 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig4 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig5 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig6 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig7 ) * tasa_interes / 36000,2) + '||
		'  round((b.capvig8  ) * tasa_interes / 36000,2) + '||
		' round((b.capvig9 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig10 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig11 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig12 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig13 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig14 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig15 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig16 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig17 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig18 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig19 ) * tasa_interes / 36000,2)   + '||
		' round((b.capvig20 ) * tasa_interes / 36000,2)   + '||
		' nvl(round((c.capvig21 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig22 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig23 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig24 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig25 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig26 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig27 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig28 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig29 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig30 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig31 ) * tasa_interes / 36000,2),0)  '||
		' from cred_sol   a '||
		' join bdicred:sd_sdodiariocrd b on (a.num_sol_prestamo = b.num_credito and b.fecha = '''|| to_char(pperiodo,'%m-01-%Y') || ''')'|| 
		' join bdicred:sd_maecredcrd d on (a.num_sol_prestamo = d.num_credito)  '||
		' left outer join bdicred:sd_sdodiariocrd c on (a.num_sol_prestamo = c.num_credito and c.fecha = monthadd(b.fecha,-1)) " > '||v_ruta ||'querycredsolsdoint.sql';

		system v_sql6;
		LET v_sql6 = "dbaccess bdicred "||v_ruta||"querycredsolsdoint.sql";
		system v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "sed 's/|$//g' "||v_ruta||'descargacredsolsdoint1.unl'||" >"||v_ruta||'descargacredsolsdoint.unl';
		SYSTEM v_sql6;

 		LET v_sql6 = '';
		LET v_sql6 = "rm "||v_ruta||'descargacredsolsdoint1.unl';
		SYSTEM v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargacredsolsdoint.unl'||" > " ||v_ruta||'Edocta_credsolsdoint'||'.unl';
		SYSTEM v_sql6;

 		LET v_sql6 = '';
		LET v_sql6 = "rm "||v_ruta||'descargacredsolsdoint.unl ';
		SYSTEM v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "rm "||v_ruta||'querycredsolsdoint.sql';
		SYSTEM v_sql6; 		
		--'JMAH FIN CAT
	  
	  ------------------------ Meses sin interes ------------------------------------------------
				-- Obtiene informacion de creditos (Vigentes) con pagos facturados durante la vigencia de la compra a MSI
	LET v_sql1 =   ' echo " set isolation to dirty read; '||
		           ' INSERT INTO cred_msi '||
					' (fecha_emision, folio_movto, numcte, num_credito, num_tarjeta, num_sol_prestamo, num_promo, fecha_compra, comercio, '||
					' descripcion, numero_cuotas, plazo, saldo_total_compra, msipagomin, saldo_total_deudor, diasmes, status, secuencia, tasa_int_aplicable, tipo_tarjeta) ';
	LET v_sql2 =    ' SELECT distinct mdy("'||vMesHoy||'","'||vDiaHoyM||'","'||vAnioHoy||'"),promoCred.folio_suc,cr.numcte, '||
					' cr.num_credito,promoCred.num_tarjeta,promoCred.num_sol_prestamo,promoCred.num_promo,promoCred.fecha_compra_msi, '||
					' promoCred.detalle_compra_msi,promoCred.comercio_msi,amorcrd.num_pago,crd.plazo,msdocrd.monto_otorgado, '||
					' amorcrd.capital_mto_cuota,msdocrd.sdo_cap_insoluto,DAY(promoCred.fecha) diames,promoCred.status,1,crd.tasa_interes,sdtar.tipo_tarjeta '||
					' FROM bdicred:sd_maecred cr '||
					' INNER JOIN "informix".sd_promocion_credito promoCred ON cr.num_credito = promoCred.num_credito '||
					' INNER JOIN BDICRED:SD_MAECREDCRD crd ON crd.num_credito = promoCred.num_sol_prestamo '||
					' INNER JOIN sd_amortiza_creditocrd amorcrd ON crd.num_credito = amorcrd.num_credito '||
					' INNER JOIN sd_maesdoscrd msdocrd ON msdocrd.num_credito = promoCred.num_sol_prestamo '||
					' LEFT OUTER JOIN sd_tarjeta sdtar ON cr.num_credito = sdtar.num_credito  AND promoCred.num_tarjeta = sdtar.num_tarjeta AND promoCred.num_cte = sdtar.numcte AND sdtar.empresa = ''001'' ';
	LET v_sql3 =	' WHERE cr.status_cred in (''E1'',''E2'',''E3'') '||
					' AND crd.num_producto = ''8900'' '||
					' AND crd.status_cred = ''E1'' '||
					' AND amorcrd.fecha_cuota > ''' ||to_char(v_periodo_anterior,'%m-%d-%Y')||''' AND amorcrd.fecha_cuota <= ''' ||to_char(pperiodo,'%m-%d-%Y')||''' '||
					' AND amorcrd.capital_status = ''5'' '||
					' AND promoCred.banderact_msi = ''1'' ';
	LET v_sql4 = 	'; " >'||trim(v_ruta)||'queryMSI.sql';
				   
			 
	LET v_sql = Trim(v_sql1) || ' ' || Trim(v_sql2) || ' ' || Trim(v_sql3) || ' ' || Trim(v_sql4);
    system v_sql;
	
	LET v_sql = '';
    LET v_sql = 'dbaccess bdicred ' ||trim(v_ruta)|| 'queryMSI.sql';
    system v_sql;

	LET cNumCred		= '';
	LET vsecuencia		= 0;
	LET vNumTarjeta		= '';
	LET vNumCredMSI		= '';
	
	Foreach 
		select num_credito 
		into vNumCred
		from cred_msi
		group by num_credito
			
		let VSecuencia = 1;	
			
		Foreach 
			select num_sol_prestamo
			into vNumCredMSI
			from cred_msi
			where num_credito = vNumCred

			update cred_msi 
			set secuencia = VSecuencia
			where fecha_emision = pperiodo
			and num_credito = vNumCred
			and num_sol_prestamo =	vNumCredMSI;

			let VSecuencia = VSecuencia +1;	
		end foreach;	
	end foreach;
	
	LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaMSI.unl' ||
		         ' SELECT *  FROM cred_msi ORDER BY num_credito,secuencia " > '||v_ruta ||'queryCredMSI.sql';
	
	-- SE EJECUTA ARCHIVO DE QUERY PARA OBTENER LA INFORMACION
		LET v_sql = Trim(v_sql1);
		SYSTEM v_sql;
		
		LET v_sql = "dbaccess bdicred "||v_ruta||"queryCredMSI.sql";
		SYSTEM v_sql;


		-- SE COPIA EL ARCHIVO DE DESCARGA A UNO NUEVO
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaMSI.unl'||" >"||v_ruta||'descargaMSI1.unl';
		SYSTEM v_sql;

		-- SE BORRA EL PRIMER ARCHIVO DE DESCARGA
        LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'descargaMSI.unl';
		SYSTEM v_sql;

		-- SE COPIA LA INFORMACION DEL ARCHIVO DE DESCARGA AL NUEVO ARCHIVO DE CREDISOLUCION
		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaMSI1.unl'||" > " ||v_ruta||'Edocta_MovsMSI'||'.unl';
		SYSTEM v_sql;
		
		-- SE BORRA EL SEGUNDO ARCHIVO DE LIMPIEZA
        LET v_sql = '';   
		LET v_sql = "rm "||v_ruta||'descargaMSI1.unl';
		SYSTEM v_sql;  

		-- SE BORRA ARCHIVO QUERY
        LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'queryCRESOL.sql';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'queryMSI.sql';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'queryCredMSI.sql';
		SYSTEM v_sql;
		
		DROP TABLE IF EXISTS tmp_universcredmsi;
		DROP TABLE IF EXISTS tmpCredBuyInfoMSI;
	  

  END;
  RETURN cod_ret;

END PROCEDURE;