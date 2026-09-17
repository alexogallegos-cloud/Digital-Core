CREATE PROCEDURE "informix".sp_edocta_msi_detalle(pEmpresa CHAR(3), pFechaM DATE, vNumCredito CHAR(20))
--EXECUTE PROCEDURE "informix".sp_edocta_msi_detalle('001',MDY('05','20','2023'), '600502109660');
RETURNING CHAR(5) AS Codigo_Retorno;

	---DECLARACIONES
    DEFINE iSqlErr					INTEGER;
    DEFINE iIsamErr					INTEGER;
    DEFINE cErrorInfo				VARCHAR(80);
    DEFINE cCodRet					CHAR(5);
	DEFINE vNumCred					CHAR(20);
	DEFINE VSecuencia				SMALLINT;
	--DEFINE vNumCredito				CHAR(20);
	DEFINE vNumCredMSI				CHAR(20);
	
	DEFINE vFolioMovto 				CHAR(16);
	DEFINE vNClient					CHAR(20);
	DEFINE vNCred					CHAR(20);
	DEFINE vNTarjeta				CHAR(20);
	DEFINE vNSolPrest				CHAR(20);
	DEFINE vNPromo					INTEGER;
	DEFINE vFechBuyMsi				DATE;
	DEFINE vNumPag                  DECIMAL(17,2);
	DEFINE vPlazoBuy				INTEGER;
	DEFINE vDetBuyMSI				VARCHAR(40);
	DEFINE vComerMsi				CHAR(19);
	DEFINE vMtoBuyMsi				DECIMAL(18,2);
	DEFINE vCapMtoCuota				DECIMAL(18,2);
	DEFINE vSdoCapInsoluto			DECIMAL(18,2);
	DEFINE vDiaBuy					SMALLINT;
	DEFINE vStatusBuy				CHAR(01);
	DEFINE vTipotarjeta             CHAR(1);
	DEFINE vTasaIntApli             CHAR(5);
    DEFINE v_periodo_anterior       DATE;	
	
		
	---INICIALIZACIONES
	LET iSqlErr						= 0;
	LET iIsamErr					= 0;
	LET cErrorInfo					= '';
	LET cCodRet						= '00000';
	LET vNumCred					=  "";
	LET VSecuencia					= 0;
	--LET vNumCredito 				= '';
	LET vNumCredMSI					= '';
	
	LET vFolioMovto					= '';
	LET vNClient					= '';
	LET vNCred						= '';
	LET vNTarjeta					= '';
	LET vNSolPrest					= '';
	LET vNPromo						= 0;
	LET vFechBuyMsi					= '';
	LET vNumPag                     = 0;
	LET vPlazoBuy					= 0;
	LET vDetBuyMSI					= '';
	LET vComerMsi					= '';
	LET vMtoBuyMsi					= 0;
	LET vCapMtoCuota				= 0;
	LET vSdoCapInsoluto				= 0;
	LET vDiaBuy						= 0;
	LET vStatusBuy					= '';
	LET vTipotarjeta                = '';
	LET vTasaIntApli                = '';
    LET v_periodo_anterior          = '';	
	
	
-- Fecha: 
-- Autor: David Ulises Cuenca Montesinos
-- Nodificacion: Store Procedure para insertar la informaciÃÂ³n de compras a Meses sin Interes


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			DROP TABLE IF EXISTS tmpCredPagFacMSI;
			RETURN TRIM(cCodRet);
			
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/informix/ulises/RQI/2023-06-20_RQI_21_308/sps/sp_edocta_msi_detalle.out";
	--TRACE ON;
	
	LET v_periodo_anterior = pFechaM - 1 UNITS MONTH;

	SELECT  promoCred.folio_suc,			cr.numcte,						cr.num_credito,				promoCred.num_tarjeta,	promoCred.num_sol_prestamo,		promoCred.num_promo, 
			promoCred.fecha_compra_msi,		promoCred.detalle_compra_msi,	promoCred.comercio_msi,		amorcrd.num_pago,		crd.plazo,						msdocrd.monto_otorgado, 
			amorcrd.capital_mto_cuota,		msdocrd.sdo_cap_insoluto,		DAY(promoCred.fecha) diames,promoCred.status,		1 as secuencia,					crd.tasa_interes,
			sdtar.tipo_tarjeta 
	FROM bdicred:sd_maecred cr 
	INNER JOIN "informix".sd_promocion_credito promoCred ON cr.num_credito = promoCred.num_credito 
	INNER JOIN BDICRED:SD_MAECREDCRD crd ON crd.num_credito = promoCred.num_sol_prestamo 
	INNER JOIN sd_amortiza_creditocrd amorcrd ON crd.num_credito = amorcrd.num_credito 
	INNER JOIN sd_maesdoscrd msdocrd ON msdocrd.num_credito = promoCred.num_sol_prestamo 
	LEFT OUTER JOIN sd_tarjeta sdtar ON cr.num_credito = sdtar.num_credito  AND promoCred.num_tarjeta = sdtar.num_tarjeta AND promoCred.num_cte = sdtar.numcte AND sdtar.empresa = '001' 
	WHERE cr.num_credito = vNumCredito
	AND cr.status_cred in ('E1','E2','E3') 
	AND crd.num_producto = '8900' 
	AND crd.status_cred = 'E1' 
	AND amorcrd.fecha_cuota > v_periodo_anterior AND amorcrd.fecha_cuota <= pFechaM
	AND amorcrd.capital_status = '5' 
	AND promoCred.banderact_msi = '1'
	INTO TEMP tmpCredPagFacMSI WITH NO LOG;
	
	--LET vNumCredito = vNumCredito; -- prueba
	
	FOREACH WITH HOLD
		
		SELECT 	folio_suc,		numcte,		num_credito,	num_tarjeta,		num_sol_prestamo,	num_promo,			fecha_compra_msi,	detalle_compra_msi,		comercio_msi,
				num_pago,		plazo,		monto_otorgado,	capital_mto_cuota,	sdo_cap_insoluto,	diames,				status,				tasa_interes,			tipo_tarjeta		
		INTO 	vFolioMovto,	vNClient,	vNCred,			vNTarjeta,			vNSolPrest,			vNPromo,			vFechBuyMsi,		vDetBuyMSI,				vComerMsi,
				vNumPag,		vPlazoBuy,	vMtoBuyMsi,		vCapMtoCuota,		vSdoCapInsoluto,	vDiaBuy,			vStatusBuy,			vTasaIntApli,			vTipotarjeta       
		FROM tmpCredPagFacMSI 
		

			-- Inserta los creditos y su informacion a descargar
		
		if NVL(vNCred,'') is null or NVL(vNCred,'') = '' then
			CONTINUE FOREACH; 
		ELSE
			BEGIN;
			INSERT INTO sd_detalle_msi_edocta
				(fecha_emision,		folio_movto,	numcte,				num_credito,	num_tarjeta,		num_sol_prestamo,	num_promo,	fecha_compra,	comercio,			descripcion,
				numero_cuotas,		plazo,			saldo_total_compra,	msipagomin,		saldo_total_deudor,	diasmes,			status,		secuencia,		tasa_int_aplicable,	tipo_tarjeta)
			VALUES( pFechaM,		vFolioMovto,	vNClient,			vNCred,			vNTarjeta,			vNSolPrest,			vNPromo,	vFechBuyMsi,	vDetBuyMSI,			vComerMsi,
					vNumPag,		vPlazoBuy,		vMtoBuyMsi,			vCapMtoCuota,	vSdoCapInsoluto,	vDiaBuy,			vStatusBuy,	1,				vTasaIntApli,		vTipotarjeta);
			COMMIT;
		end if;
		
	END FOREACH;
	--LET vNCred = vNCred; -- prueba
	
	
	FOREACH 
		select num_credito 
		into vNumCred
		from sd_detalle_msi_edocta
		where fecha_emision = pFechaM
		group by num_credito
			
		let VSecuencia = 1;	
			
		FOREACH 
			select num_sol_prestamo
			into vNumCredMSI
			from sd_detalle_msi_edocta
			where fecha_emision = pFechaM
			and num_credito = vNumCred

			update sd_detalle_msi_edocta 
			set secuencia = VSecuencia
			where fecha_emision = pFechaM
			and num_credito = vNumCred
			and num_sol_prestamo =	vNumCredMSI;

			let VSecuencia = VSecuencia +1;	
		end FOREACH;	
	end FOREACH;
	
	DROP TABLE IF EXISTS tmpCredPagFacMSI;
   
   
		RETURN cCodRet;
		
	END;
END PROCEDURE;