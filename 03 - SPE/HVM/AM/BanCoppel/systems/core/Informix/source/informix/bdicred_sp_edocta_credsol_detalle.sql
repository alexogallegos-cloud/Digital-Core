CREATE PROCEDURE "informix".sp_edocta_credsol_detalle(pEmpresa CHAR(03), pFecha	DATE)
RETURNING CHAR(5) AS Codigo_Retorno;
                	
	---DECLARACIONES
    DEFINE iSqlErr						INTEGER;
    DEFINE iIsamErr						INTEGER;
    DEFINE cErrorInfo					VARCHAR(80);
	DEFINE cFecha_emision				CHAR(10);
    DEFINE cCodRet						CHAR(5);
	DEFINE vNCred						CHAR(20);
	DEFINE vNPromo 	                	INTEGER;
    DEFINE vNSolPrest               	CHAR(20);
	DEFINE vFolioSuc                	CHAR(16);
    DEFINE vPlazo                   	INTEGER;
	DEFINE vDiaBuy						SMALLINT;
	DEFINE vFecha                      	DATE;
	DEFINE vTasaInt                    	CHAR(5);
    DEFINE vSdoCapital                 	DECIMAL(18,2);
    DEFINE vProxFecPg                  	DATE;
    DEFINE vconcepto                   	CHAR(38);
    DEFINE vCapMtoCuota                	DECIMAL(16,2);
    DEFINE vNumCouta                   	CHAR(5);
    DEFINE vFechOper                   	DATE;
    DEFINE vMontOri                    	DECIMAL(20,2);
    DEFINE vInrPeri                    	DECIMAL(12,2);
    DEFINE vIvaIntPeri                 	DECIMAL(12,2);
    DEFINE vNTarjeta                   	CHAR(20);
    DEFINE vTipotarjeta                	CHAR(1);
	DEFINE vNumCred                    	CHAR(20);
	DEFINE vNumCredMCI                 	CHAR(20);
	DEFINE VSecuencia					SMALLINT;
	DEFINE vMesBef                     	CHAR(2);
	DEFINE vAnioBef                    	CHAR(4);
	DEFINE v_periodo_anterior          	DATE;
	DEFINE pfecham                     	DATE;

		
	---INICIALIZACIONES
	LET iSqlErr						= 0;
	LET iIsamErr					= 0;
	LET cErrorInfo					= '';
	LET pfecham                     = '';
	LET cCodRet						= '00000';
	LET vNCred 		                = '';
    LET vNPromo 	                = 0;
    LET vNSolPrest                  = '';
    LET vFolioSuc                   = '';
    LET vPlazo                      = 0;       
    LET vDiaBuy                     = '';
    LET vFecha                      = '';
    LET vTasaInt                    = '';
    LET vSdoCapital                 = 0;
    LET vProxFecPg                  = '';
	LET vconcepto                   = '';
    LET vCapMtoCuota                = 0;
    LET vNumCouta                   = '';
    LET vFechOper                   = '';
    LET vMontOri                    = 0;
	LET vInrPeri                    = 0;
	LET vIvaIntPeri                 = 0;
    LET vNTarjeta                   = '';
    LET vTipotarjeta                = '';
	LET vNumCred                    = '';
	LET vNumCredMCI                 = '';
	LET VSecuencia                  = '';
	LET vMesBef                     = '';
	LET vAnioBef                    = '';	
	LET v_periodo_anterior          = '';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			DROP TABLE IF EXISTS tmpCrediPagos;
			DROP TABLE IF EXISTS tmpCrediPagos2;
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet);
			
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET v_periodo_anterior = pFecha - 1 UNITS MONTH;
    
	--SET DEBUG FILE TO '/home/c90260202/sp_edocta_credsol_detalle.out';
	--TRACE ON;


	SELECT  
		cm.num_credito,
		promoCred.num_promo,
		promoCred.num_sol_prestamo,
		promoCred.folio_suc,
		crd.plazo,
		DAY(promoCred.fecha) diasmes, 
		promoCred.fecha,
		crd.tasa_interes,
		DATE(1) prox_fecha_pago, 
		' ' concepto,
		1 as secuencia,
		1 as nlinea,
		crd.fecha_apertura,
		promoCred.num_tarjeta,
		promoCred.num_cte
	from sd_muestra_edocta cm
	inner join bdicred:sd_promocion_credito  promoCred on cm.num_credito = promoCred.num_credito  
	inner join bdicred:sd_maecred cr on cm.num_credito = cr.num_credito and cr.status_cred in ('E1','E2','E3') and cr.empresa = '001'
	inner join bdicred:sd_maecredcrd crd ON promoCred.num_sol_prestamo = crd.num_credito  and crd.num_producto = '6900' and crd.fecha_apertura <= pFecha
	WHERE cm.fecha_corte = pFecha
	and promoCred.num_pro_prestamo = '6900'
	AND crd.status_cred in ('E1')
	INTO TEMP tmpCrediPagos2 WITH NO LOG;
	
	create index idx_tmpCrediPagos2 on tmpCrediPagos2(num_credito, num_sol_prestamo);
	update statistics medium for table tmpCrediPagos2;
	
	
	select 
		cm2.num_credito,
		cm2.num_promo,
		cm2.num_sol_prestamo,
		cm2.folio_suc,
		cm2.plazo,
		cm2.diasmes, 
		cm2.fecha,
		cm2.tasa_interes,
 		msdocrd.sdo_cap_insoluto,
		cm2.prox_fecha_pago, 
		cm2.concepto,
		amorcrd.capital_mto_cuota,
		amorcrd.num_pago, 					
		cm2.secuencia,
		cm2.nlinea,
		cm2.fecha_apertura,
		msdocrd.monto_otorgado,
		amorcrd.interes_pagado,
		amorcrd.iva_pagado,
		sdtar.num_tarjeta,
		sdtar.tipo_tarjeta 
	from   tmpCrediPagos2 cm2
		inner join sd_maesdoscrd msdocrd ON cm2.num_sol_prestamo = msdocrd.num_credito
		inner join sd_amortiza_creditocrd amorcrd ON cm2.num_sol_prestamo = amorcrd.num_credito and  amorcrd.capital_status = '5'
		left outer join sd_tarjeta sdtar ON cm2.num_credito = sdtar.num_credito  AND cm2.num_tarjeta = sdtar.num_tarjeta AND cm2.num_cte = sdtar.numcte AND sdtar.empresa = '001'	
		where  amorcrd.fecha_cuota > v_periodo_anterior AND amorcrd.fecha_cuota <= pFecha
		into temp tmpCrediPagos with no log;


		create index idx_tmpCrediPagos on tmpCrediPagos(num_credito, num_sol_prestamo);
		update statistics medium for table tmpCrediPagos FORCE;	
	


	FOREACH WITH HOLD
		        		
		SELECT  num_credito,	num_promo,			num_sol_prestamo,	folio_suc,			plazo,			diasmes,		fecha,			tasa_interes,	sdo_cap_insoluto,	prox_fecha_pago,
				concepto,		capital_mto_cuota,	num_pago,			fecha_apertura,		monto_otorgado,	interes_pagado,	iva_pagado,		num_tarjeta,	tipo_tarjeta	
		INTO 	vNCred,			vNPromo,			vNSolPrest,			vFolioSuc,			vPlazo,			vDiaBuy,		vFecha,			vTasaInt,		vSdoCapital,		vProxFecPg,
                vconcepto,		vCapMtoCuota,		vNumCouta,			vFechOper,			vMontOri,		vInrPeri,		vIvaIntPeri,	vNTarjeta,		vTipotarjeta
		FROM tmpCrediPagos
		

			-- Inserta los creditos y su informacion a descargar
		
		if NVL(vNCred,'') is null or NVL(vNCred,'') = '' then
			CONTINUE FOREACH; 
		ELSE
			LET vconcepto = 'PAGOS FIJOS FOLIO: ' || vNSolPrest;
			
			BEGIN;
				INSERT INTO "informix".sd_detalle_dif_edocta
				   (fecha_emision,		num_credito,		num_promocion,		num_cred_credsol,		folio_suc,				plazo,				diasmes,		fecha,
					tasa,				saldo_pendiente,	prox_fecha_pago,	concepto,				monto_prox_pago,		numero_cuotas,		secuencia,		nlinea,	     
					fecha_oper,			monto_ori,			int_periodo,		iva_int_periodo,		num_tar_ori,			tipo_tarjeta)
				
				VALUES( pFecha,			vNCred,				vNPromo,			vNSolPrest,				vFolioSuc,				vPlazo,				vDiaBuy,		vFecha,          
						vTasaInt,		vSdoCapital,		vProxFecPg,			vconcepto,				vCapMtoCuota,			vNumCouta,			1,				1,         
						vFechOper,		vMontOri,			vInrPeri,			vIvaIntPeri,			vNTarjeta,				vTipotarjeta);
			COMMIT;
		end if;

	END FOREACH;
	--LET vNCred = vNCred; -- prueba
	
	
	FOREACH 
		select num_credito 
		into vNumCred
		from sd_detalle_dif_edocta
		where fecha_emision = pFecha
		group by num_credito
			
		let VSecuencia = 1;	
			
		FOREACH 
			select num_cred_credsol
			into vNumCredMCI
			from sd_detalle_dif_edocta
			where fecha_emision = pFecha
			and num_credito = vNumCred

			update sd_detalle_dif_edocta 
			set secuencia = VSecuencia
			where fecha_emision = pFecha
			and num_credito = vNumCred
			and num_cred_credsol =	vNumCredMCI;

			let VSecuencia = VSecuencia +1;	
		end FOREACH;	
	end FOREACH;


	
	DROP TABLE IF EXISTS tmpCrediPagos;
	DROP TABLE IF EXISTS tmpCrediPagos2;
		
		
	RETURN cCodRet;		
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para consultar los registros de la tabla sd_detalle_dif_edocta por medio de un numero de credito y fecha de emision', 
'AUTOR: Josue Remberto Zazueta Acosta ',
'FECHA: 13 de Julio del 2012',
'VERSION: 20120713.1012 ',
'Modifica: Carlos Aguirre Vega',
'Fecha de modificacion: 30-05-2013',
'Descripcion: Se modifica la consulta a la tabla sd_detalle_dif_edocta para que consulte al nuevo campo saldo_pendiente y no al campo cargos',
'Peticion: MttoCredisoluciones RQM 10 214-2',
'Modifica: Carlos Aguirre Vega',
'Fecha de modificacion: 06-06-2013',
'Descripcion: Se agrega parametro pNumRegistros para la funcionalidad de paginado',
'Peticion: MttoCredisoluciones RQM 10 214-2';

CREATE PROCEDURE "informix".cargo_ref_cel_pba_sfsa 
      ( pTarjeta             CHAR(16),
        pSucursal            CHAR(4),
        pUsuario             CHAR(8),
        pNumTran             CHAR(4),
        pNumTranS            CHAR(4),
        pFolio               CHAR(16),
        pNumCredito          CHAR(20),
        pDocumento           INTEGER,
        pMonto               MONEY(16,2),
        pMonto2              MONEY(16,2),
        pCashTranCen         CHAR(4),
        pCashFolio           CHAR(15),
        pDivisa              CHAR(2),
        pReferencia          CHAR(40),
        pComSucursal         CHAR(4),
        pComUsuario          CHAR(8),
        pComNumTran          CHAR(4),
        pComNumTranS         CHAR(4),
        pComFolio            CHAR(16),
        pComNumCredito       CHAR(20),
        pComDocumento        INTEGER,
        pComMonto            MONEY(16,2),
        pComDivisa           CHAR(2),
        pComReferencia       CHAR(40),
        pComBandera          CHAR(1),
        pSurcharge           CHAR(1),  
        pComCashNumTran      CHAR(4),
        pComCashNumTranS     CHAR(4),
        pComCashFolio        CHAR(16),
        pComCashDocumento    INTEGER,
        pComCashMonto        MONEY(16,2),
        pComCashDivisa       CHAR(2),
        pComCashReferencia   CHAR(40))

   RETURNING CHAR(5),       -- Codigo de Retorno
             CHAR(4),       -- Transaccion
             DATE,          -- Fecha Aplicacion
             MONEY(16,2),   -- Saldo Disponible
             MONEY(16,2),   -- Importe Cargado
             CHAR(5),       -- Codigo de Retorno Comision
             CHAR(4),       -- Transaccion Comision
             DATE,          -- Fecha Aplicacion Comision
             MONEY(16,2),   -- Saldo Disponible Comision
             MONEY(16,2);   -- Importe Cargado ComisioN

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret               CHAR(5);
   DEFINE cod_ret2              CHAR(5);
   DEFINE cod_ret_inc           CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nrows                 SMALLINT;
   DEFINE Mensaje               CHAR(80);
   DEFINE Mensaje_inc           CHAR(80);

   DEFINE NumProducto           CHAR(4);
   DEFINE StatusCred            CHAR(2);
   DEFINE Saldo                 MONEY(16,2);
   DEFINE SaldoCom              MONEY(16,2);
   DEFINE TipoCredito           CHAR(2);
   DEFINE MontoOtorgado         MONEY(16,2);
   DEFINE v_com1_dlls           MONEY(16,2);
   DEFINE v_com2_dlls           MONEY(16,2);
   DEFINE v_mtofavor_dlls       MONEY(16,2);
   DEFINE v_mto1_dlls           MONEY(16,2);
   DEFINE v_mto2_dlls           MONEY(16,2);
   DEFINE MtoTot                MONEY(16,2);
   DEFINE TotCargo              MONEY(16,2);
   DEFINE TotComision           MONEY(16,2);
   DEFINE CodigoRef             INTEGER;
   DEFINE CodigoFun             CHAR(3);
   DEFINE wEmpresa              CHAR(3);
   DEFINE wSucursal             CHAR(4);
   DEFINE wDivisa               CHAR(2);
   DEFINE FechaHoy              DATE;
   DEFINE pForzado              CHAR(1);
   DEFINE wBegin                CHAR(1);
   DEFINE vusuario              CHAR(8);
   DEFINE v_paso                SMALLINT;
   DEFINE v_mn                  CHAR(2);
   DEFINE v_dv                  CHAR(2);
   DEFINE v_valor               SMALLINT;
   DEFINE v_tipocambio          DECIMAL(14,6);
   DEFINE v_mensaje             VARCHAR(100);
   DEFINE TasaIva               DECIMAL(5,3);
   DEFINE Iva                   DECIMAL(14,2);
   DEFINE vMtoComDisp           DECIMAL(14,2);
   DEFINE vMtoComDisp_iva       DECIMAL(14,2);     -- RRG Se agrega para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   DEFINE v_faplica             CHAR(1);
   DEFINE v_factor              DECIMAL(9,6);
   DEFINE v_rangos              CHAR(1);
   DEFINE v_rmax                MONEY(14,2);
   DEFINE v_codparam            CHAR(4);
   DEFINE vSdoPos               DECIMAL(14,2);
   DEFINE vMtoPaso              DECIMAL(14,2);
-- Jom INI Bloqueo de cuentas
   DEFINE vBloqueo              INTEGER;
-- Jom FIN Bloqueo de cuentas
   DEFINE vMtoFavor             DECIMAL(16,2);
   DEFINE vMtoPaso2             DECIMAL(16,2);
   DEFINE pNumTranFavor         CHAR(4);
   DEFINE pNumTranFavor2         CHAR(4);
-- Jom INI limites
   DEFINE vnum_cliente          char(20);
   DEFINE vcodret               char(05);
   DEFINE vmsje_limites         char(80);
   DEFINE vid_autor             char(01);
   DEFINE vid_transacc          char(02);
   DEFINE vid_canal             char(02);
   DEFINE vuser_limit           char(08);
-- Jom FIN limites
   DEFINE vEscajero             char(01);
   DEFINE v_bloqprod            INTEGER;
   DEFINE vValDocto             char(01);
   DEFINE cAplica_restriccion   char(1);
   DEFINE vMensaje              char(100);
   DEFINE cCodCaracter          char(2);
-- Selecciona comision por tipo de producto JOM INI
   DEFINE vCodigoComisionEfe     CHAR(04);
-- Selecciona comision por tipo de producto JOM FIN
   DEFINE dfh_pre_devol_an      DATE;
   DEFINE dfh_devol_an          DATE;
   DEFINE dfh_trasp_devol       DATE;
   DEFINE dSdoCapInsol          DECIMAL(18,2);
   DEFINE v_tp_proceso          CHAR (1);
   DEFINE total_movimiento      DECIMAL(10,2);
   DEFINE saldo_incremento      DECIMAL(10,2);
   DEFINE vIndDispEfec          INTEGER; --RQM 10 1225
   DEFINE vIndDispEfecProd      CHAR(1); --RQM 10 1225
   DEFINE vLinCredAct           DECIMAL(18,2); --RQM 10 1225
   DEFINE v_sdoacumulado        DECIMAL(18,2); --RQM 10 1225
   DEFINE v_montoact            DECIMAL(18,2); --RQM 10 1225
   DEFINE cMen_ret              CHAR(100); --RQM 10 1225
   DEFINE vDispEfec             CHAR(1); --RQM 10 1225
   DEFINE v_bactsaldo           SMALLINT; --RQM 10 1225
   DEFINE cMtoVen               DECIMAL(18,2);
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      --SET DEBUG FILE TO "CargoLineaCredito.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET Saldo = 0;
      LET FechaHoy = NULL;
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOS/Prueba_SP_cargoref_tdc/cargoref_cel.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET wBegin           = "N";
   LET vusuario         = USER;
   LET cod_ret          = "000";
   LET Saldo            = 0;
   LET SaldoCom         = 0;
   LET cod_ret2         = "000";
   LET cod_ret_inc      = "000";
   LET isam_err         = 0;
   LET error_info       = '';
   LET nrows            = 0;
   LET Mensaje          = '';
   LET Mensaje_inc      = '';
   LET NumProducto      = '';
   LET StatusCred       = '';
   LET cMtoVen          = 0;
   LET TipoCredito      = '';
   LET MontoOtorgado    = 0;
   LET FechaHoy         = NULL;
   LET pForzado         = '';
   LET v_paso           = 0;
   LET MtoTot           = 0;
   LET TotCargo         = 0;
   LET TotComision      = 0;
   LET CodigoRef        = 0;
   LET CodigoFun        = '';
   LET wSucursal        = '';
   LET wDivisa          = '';
   LET v_valor          = 0;
   LET v_tipocambio     = 0;
   LET v_mensaje        = "??";
   LET v_com1_dlls      = 0;
   LET v_com2_dlls      = 0;
   LET v_mtofavor_dlls  = 0;
   LET v_mto1_dlls      = 0;
   LET v_mto2_dlls      = 0;
   LET vMtoComDisp      = 0;
   LET vMtoComDisp_iva  = 0;
   LET vMtoPaso         = 0;
   LET v_mn             ='';
   LET v_dv             ='';
   LET TasaIva          = 0;
   LET Iva              = 0;
   LET v_faplica        = '';
   LET v_factor         = 0;
   LET v_rangos         ='';
   LET v_rmax           = 0;
-- Jom INI Bloqueo de cuentas
   LET vBloqueo         = 0;
-- Jom FIN Bloqueo de cuentas
   LET vMtoFavor        = 0;
   LET pNumTranFavor = pNumTran;
   LET pNumTranFavor2 = pNumTran;
-- Jom INI limites
   LET vnum_cliente     = '';
   LET vcodret          = '';
   LET vmsje_limites    = '';
   LET vid_autor        = '';
   LET vid_transacc     = '';
   LET vid_canal        = '';
   LET vuser_limit      = '';
-- Jom FIN limites
   LET v_bloqprod       = 0;
   LET vMtoPaso2       = 0;
   LET vEscajero = '0';
   LET vValDocto = '';
   LET cAplica_restriccion = '0';
   LET vMensaje = '';
   LET cCodCaracter = '';
   LET v_codparam   = '';
   LET wEmpresa     = '';
   LET vSdoPos      = 0;
-- Selecciona comision por tipo de producto JOM INI
   LET vCodigoComisionEfe = '';
-- Selecciona comision por tipo de producto JOM FIN
   LET dfh_pre_devol_an = date(1);
   LET dfh_devol_an     = date(1);
   LET dfh_trasp_devol  = date(1);
   LET dSdoCapInsol = 0;
   
   LET v_tp_proceso = "";
   LET total_movimiento = 0;
   LET saldo_incremento = 0;
   LET vIndDispEfec     = 0; --RQM 10 1225
   LET vLinCredAct      = 0; --RQM 10 1225
   LET cMen_ret         = ''; --RQM 10 1225
   LET vDispEfec        = 0; --RQM 10 1225
   LET vIndDispEfecProd = ''; --RQM 10 1225
   LET v_montoact       = 0; --RQM 10 1225
   LET v_bactsaldo      = 0; --RQM 10 1225
   LET v_sdoacumulado   = 0; --RQM 10 1225  
   
   
   --se obtiene la transaccion a favor de acuerdo a la transaccion recibida
    SELECT transacc_favor,cajero,aplica_restriccion
    INTO pNumTranFavor,vEscajero,cAplica_restriccion
    FROM "informix".sd_conceptoscargoscredito
    WHERE transacc = pNumTran;

    IF dbinfo("sqlca.sqlerrd2") = 0 THEN--cuando no exista en la tabla se pone el valor por default
      LET pNumTranFavor = pNumTran;
      LET vEscajero = '0';
      LET cAplica_restriccion = '0';
    END IF;

    IF LENGTH(TRIM(pSucursal)) = 3 then
       LET pSucursal = "9" || TRIM(pSucursal);
    END IF

   SELECT valor INTO v_mn FROM bdinteg:"informix".si_param WHERE cod_param = 15; -- codigo mn
   SELECT valor INTO v_dv FROM bdinteg:"informix".si_param WHERE cod_param = 17; -- divisa de cambio
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   SELECT fecha_hoy
     INTO FechaHoy
     FROM "informix".sd_fechas;
    --WHERE empresa = wEmpresa;

   -- ************************
   -- Busca Datos del Credito*
   -- ************************
       SELECT a.empresa, a.sucursal, a.divisa, a.num_producto, a.status_cred,
              b.monto_otorgado - (b.sdo_cap_insoluto + sdo_retenido),
          c.cod_tipcred, d.iva, e.fecha_proceso,
          CASE WHEN sdo_capital < 0 THEN  sdo_capital * -1 ELSE 0 END,
          a.id_unidad_prod, numcte,Cod_caract_2, cod_comision_efectivo, sdo_cap_insoluto,
          b.sdo_acum_vencido, a.diferimiento_int, c.ind_disp_efec, nvl(b.monto_vencido + b.mto_venc_trasp,0) --RQM 10 1225
         INTO wEmpresa, wSucursal, wDivisa, NumProducto, StatusCred,
              Saldo, TipoCredito, TasaIva, FechaHoy, vSdoPos,
              vBloqueo, vnum_cliente,cCodCaracter, vCodigoComisionEfe, dSdoCapInsol,
              v_sdoacumulado, vDispEfec, vIndDispEfecProd, cMtoVen --RQM 10 1225
         FROM "informix".sd_maecred a, "informix".sd_maesdos b, "informix".sd_definicion c, "informix".sd_maecredanexo e,
          bdinteg:"informix".si_sucursales d
        WHERE a.num_credito = pNumCredito
          AND a.empresa = "001"
          AND b.num_credito = a.num_credito
          AND a.empresa = b.empresa
          AND c.num_producto = a.num_producto
          AND e.num_credito = a.num_credito
          AND e.empresa = a.empresa
          AND d.empresa = a.empresa
          AND d.sucursal = pSucursal;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET Saldo = 0;
      IF pNumTranS = "9999" then
        LET cod_ret = "100";
      ELSE
        LET cod_ret = "008";
      END IF
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

   IF(TipoCredito <> "03") THEN -- Credito no es tarjeta
      LET cod_ret = "206";
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;
   
   -- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad
   SELECT nvl(date(fecha_pre_devol_anual),date(1)), nvl(date(fecha_devol_anual),date(1)), nvl(date(fecha_trasp_devol_anual), date(1))
     INTO dfh_pre_devol_an, dfh_devol_an, dfh_trasp_devol
     FROM bdicred:sd_indicador_cred WHERE empresa = "001" AND num_credito = pNumCredito;

-- ini -- Se agrega bloqueo de cuentas
-- Bloqueo de cuentas operaciones
-- id_unidad_prod = 2 = bloqueo pago
-- id_unidad_prod = 3 = bloqueo disposicion
-- id_unidad_prod = 4 = bloqueo pago y disposicion

--Jom ini Bloqueo de creditos
   IF ((vBloqueo = 3 or vBloqueo = 4) AND (cAplica_restriccion = '0') ) OR    ((vBloqueo = 3 or vBloqueo = 4) AND  cAplica_restriccion = '1' AND NVL(cCodCaracter,'') = '01') THEN -- Bloqueado
     -- Identifica si el cliente esta marcado como precancelado por devolucion de comision por anualidad y permita realizar el retiro de lo abonado
    IF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) = date(1) AND dSdoCapInsol < 0 THEN
        LET cod_ret = "000"; 
    ELIF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) > date(1) AND dSdoCapInsol = 0 THEN
        LET cod_ret = "1207";   -- Credito cancelado. (la devolucion ya se retiro)
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
        cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
    ELIF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) = date(1) AND nvl(dfh_trasp_devol,date(1)) > date(1) THEN
        LET cod_ret = "1209";   -- DEVOLUCION DE ANUALIDAD HA SIDO TRASPASADA. FAVOR DE TRAMITAR ACLARACION
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
        cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;   
     ELSE
        LET cod_ret = "207";
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
     END IF;
   END IF
-- Jom Fin Bloqueo de creditos

   -- Si el credito tiene devolucion de anualidad, el retiro sea por el monto total de la devolucion.
   IF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) = date(1) AND dSdoCapInsol < 0 THEN
     IF (dSdoCapInsol * -1) != pMonto THEN -- Si monto a retirar no corresponde con monto de devolucion no procede retiro.
        LET cod_ret = '1206';
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
     END IF;
     IF pNumTran != '6900' OR pNumTranS != '6900' THEN -- Si retiro no es en ventanilla, no procede retiro.
        LET cod_ret = '1210';
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
     END IF;
   END IF;

   IF SUBSTR(StatusCred,1,1) IN ("B", "F", "C") OR (StatusCred in ('E1','E2','E3') and cMtoVen > 0)  THEN -- Cancelado o Bloqueado

     IF NOT (StatusCred IN ('BT','BA','E1','E2','E3') AND cAplica_restriccion = '1' ) THEN
        LET cod_ret = "207";
        RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
     END IF

   END IF;

    select count(*)
      into v_bloqprod
      from bdicred:"informix".sd_bloqueoprod
     where num_producto=NumProducto
       and transac_bloq in (pNumTran,pNumTranFavor,pComNumTran,pComNumTranS,pComCashNumTran,pComCashNumTranS);

   IF v_bloqprod > 0  THEN -- bloqueo por producto
      LET cod_ret = "199";
      RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
         cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF;

   -- ****************************
   -- Valida Datos del Plasticos *
   -- ****************************

   SELECT valida_docto
     INTO vValDocto
     FROM bdinteg:"informix".si_transacc
    WHERE empresa = wEmpresa
      AND sistema = "06"
      AND numero = pNumTran;

   IF ( nvl(vValDocto,'') <> 'T' ) then
       SELECT COUNT(*) INTO v_valor
         FROM "informix".sd_tarjeta
        WHERE empresa = wEmpresa
          AND num_tarjeta = pTarjeta
          AND status_tar = "A";
--          AND expiracion >= FechaHoy;

       IF v_valor IS NULL OR v_valor = 0  AND cAplica_restriccion = '0' THEN -- No hay Plasticos Asignados
          LET cod_ret = "208";
          RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
             cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
       END IF;
   END IF;

   -- ********************************************************
   -- Extrae Tipo de Cambio si se requiere para la operacion *
   -- ********************************************************
    IF pDivisa <> v_mn OR pComDivisa <> v_mn OR pComCashDivisa <> v_mn THEN
        SELECT precio_venta INTO v_tipocambio
              FROM bdinteg:"informix".si_tpcambio
         WHERE empresa = "001"
           AND divisa = v_dv
           AND clase_tpcambio = "O"
           AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                       FROM bdinteg:"informix".si_tpcambio
                      WHERE empresa = "001"
                        AND divisa = v_dv);
    END IF

   -- *******************************************************
   -- Valoriza Movimientos en Moneda Diferente a 01 (Pesos) *
   -- *******************************************************

   IF pDivisa <> v_mn THEN
    LET v_mto1_dlls = pMonto;
    LET pMonto = v_mto1_dlls * v_tipocambio;
    LET v_mto2_dlls = pMonto2;
    LET pMonto2 = v_mto2_dlls * v_tipocambio;
   END IF

   IF pComMonto > 0 THEN
    IF pComDivisa <> v_mn THEN
        LET v_com1_dlls = pComMonto;
        LET pComMonto = v_com1_dlls * v_tipocambio;
    END IF
   END IF

   IF pComCashMonto > 0 THEN
    IF pComCashDivisa <> v_mn THEN
        LET v_com2_dlls = pComCashMonto;
        LET pComCashMonto = v_com1_dlls * v_tipocambio;
    END IF
   END IF
   -- *********************************************
   -- Extrae Comision por disposicion de efectivo *
   -- *********************************************
   
   -- AAME Se contempla la nueva transaccion 6846 para el cargo del impuesto GDF. 2013-08-13
   -- PIQV Se contempla transaccion 6845 para el cargo del impuesto GDF Banca por Internet sin cobrar comision. 2013-08-20

   IF  pNumTrans IN ("6952","0800","6900","0871","0872","0873","6846","6845","8105","6800","6871","6872","6873","8022","8045","4316","4317") THEN    
   --IF  pNumTrans IN ("6952","6800","6900","6871","6872","6873","6846","6845","8105") THEN 
        SELECT valor INTO v_codparam
          FROM "informix".sd_param
         WHERE empresa = wEmpresa
           AND cod_param = "334";

        IF vSdoPos > 0 AND vSdoPos < pMonto THEN
            LET vMtoPaso = pMonto - vSdoPos;
        ELIF vSdoPos > 0 AND vSdoPos >= pMonto THEN
            LET vMtoPaso = 0;
        ELIF vSdoPos = 0 THEN
            LET vMtoPaso = pMonto;
        END IF

        IF vMtoPaso > 0 AND pNumTrans NOT IN ("6846","6845","8022","8045") THEN  -- AAME Para que realice el calculo del monto Paso pero sin cobrar comision. 2013-08-13
-- Selecciona comision por tipo de producto JOM INI

                SELECT form_aplica, monto, apli_factor, consi_rango, monto_max
                  INTO v_faplica, vMtoComDisp, v_factor, v_rangos, v_rmax
                  FROM "informix".sd_tpcomis
                 WHERE empresa = wEmpresa
                   AND cod_comis = vCodigoComisionEfe;

--                SELECT form_aplica, monto, apli_factor, consi_rango, monto_max
--                  INTO v_faplica, vMtoComDisp, v_factor, v_rangos, v_rmax
--                  FROM "informix".sd_tpcomis
--                 WHERE empresa = wEmpresa
--                   AND cod_comis = v_codparam;

-- Selecciona comision por tipo de producto JOM FIN

                IF v_faplica = 2 THEN
                        LET vMtoComDisp = vMtoPaso * (v_factor/100);
                END IF

                IF v_rangos = "1" THEN
                        IF vMtoComDisp < v_rmax THEN
                                LET vMtoComDisp = v_rmax;
                        END IF
                END IF
        END IF
   END IF

   -- *******************************************************
   -- Calcula Iva Global por Comision, solo para validacion *
   -- *******************************************************
             -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   if (pSurcharge = 'V') then
      LET Iva = (pComCashMonto * TasaIva) ;     -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   else
      LET Iva = (pComMonto + pComCashMonto) * TasaIva;     -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   end if;
   LET vMtoComDisp_iva = vMtoComDisp * TasaIva;     -- RRG Se agrega para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   LET Iva = Iva +  vMtoComDisp_iva;                -- RRG Se agrega para el proyecto de circular 22/2010 comisiones ATM 26/10/2010

   
   -- *******************************************************
   -- Valida bitacora para incrementos de linea de credito  *
   -- *******************************************************   
    LET total_movimiento = pMonto + pMonto2 + pComMonto + pComCashMonto + vMtoComDisp + Iva;
    
    SELECT tp_proceso
        INTO v_tp_proceso
    FROM bdicred:sd_status_incremento_reduccion 
        WHERE  empresa = wEmpresa AND num_credito = pNumCredito AND tp_proceso = "R";

    IF NVL (v_tp_proceso,"") <> "" THEN
    
        EXECUTE PROCEDURE bdicred:sp_incremento_reduccion (wEmpresa,pNumCredito,0,total_movimiento,"I",0,pNumTran)
            INTO cod_ret_inc,Mensaje_inc, saldo_incremento;
            
            IF cod_ret_inc ::INTEGER = 0 THEN 
                LET Saldo = saldo_incremento;
            END IF;
            
    END IF;
   
   -- ***************************************
   -- Valida Disponible vs Monto Movimiento *
   -- ***************************************
   IF Saldo < total_movimiento THEN
     LET cod_ret = "005";
     RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
            cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;
   END IF 
   
   -- ******************************************************
   -- Valida Monto solicitado en disposicion en efectivo   * 
   -- vs Monto otorgado en credito - RQM 10 1225           * 
   -- ******************************************************    
    IF nvl(vIndDispEfecProd,'') = '1' AND pNumTrans in ('0800','6800','0871','0872','0873','6900','7380','8105','8112','6952','6871','6872','6873') AND  nvl(vDispEfec,'') in (1,2) THEN --El indicador de porcentaje de efectivo
            EXECUTE PROCEDURE bdicred:"informix".sp_evaldispefec_cred (pNumCredito,pMonto) 
                INTO cod_ret, vIndDispEfec, vLinCredAct, cMen_ret;                                                                                                                                                                                                                                                                                                                                                  
            IF cod_ret != '00000' THEN --Codigos de retorno controlados
               IF (cod_ret in ('00301','00302','00303') and pNumTrans in ('0871','0872','0873','6871','6872','6873')) THEN
                    LET cod_ret = "005";
               ELSE
                    IF cod_ret = '00301' THEN
                        LET cod_ret = LTRIM('00301', '00');
                    ELIF cod_ret = '00302' THEN
                        LET cod_ret = LTRIM('00302', '00');
                    ELIF cod_ret = '00303' THEN 
                          LET cod_ret = LTRIM('00303', '00');
                    END IF;                                            
               END IF;
               RETURN cod_ret, pNumTrans, FechaHoy, Saldo, MtoTot, cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;  
            ELSE --Se permite la disposicion
                IF vSdoPos > 0 AND vSdoPos <= pMonto THEN
                    LET v_montoact = v_sdoacumulado + (pMonto - vSdoPos);
                ELIF vSdoPos > 0 AND vSdoPos > pMonto   THEN
                    LET v_montoact = v_sdoacumulado;                
                ELSE
                    LET v_montoact = pMonto + v_sdoacumulado;
                END IF
                LET v_bactsaldo = 1;            
            END IF; 
    END IF;
    
   -- *********************************************
   -- validacion de limites de operaciones        *
   -- *********************************************
--validacion de limites jom ini
    select usuario
      into vuser_limit
      from bdinteg:"informix".si_usuario_limites
     where usuario = pUsuario
       and empresa = wEmpresa;

      if ( vuser_limit is not null or vuser_limit <> '' ) then
    -- // validacion adicional para reconocimiento de canal 120612
        IF (vuser_limit = "intercar") then
            select id_transacc, id_canal
              into vid_transacc, vid_canal
              from bdinteg:"informix".si_transacc_limites
             where transacc = pNumTrans
               and sistema = '06'
               and empresa = wEmpresa;
         ELSE
          SELECT id_canal
          into vid_canal
             from bdinteg:si_canales
          where cc_canal = psucursal;

            select id_transacc, id_canal
              into vid_transacc, vid_canal
              from bdinteg:"informix".si_transacc_limites
             where transacc = pNumTrans
               and sistema = '06'
               and empresa = wEmpresa
                and id_canal = vid_canal;
         END IF;



            if (vid_transacc is not null or vid_transacc <> '') then
-- RQI 01 050 Ajuste envio de mensajes JOM INI
-- Se agrega el parametro de tarjeta
                execute procedure bdinteg:"informix".sp_limite_max(vnum_cliente, pNumCredito, vid_transacc, vid_canal, FechaHoy, pMonto,pTarjeta,pFolio,preferencia)
-- RQI 01 050 Ajuste envio de mensajes JOM FIN
                into vcodret, vmsje_limites, vid_autor;

                if (vcodret = '00035') then
                     LET cod_ret = "035";
                     RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                            cod_ret2, pComNumTran, FechaHoy, SaldoCom, pComMonto;

                end if;
            end if;
        end if;

--validacion de limites jom ini

   -- ***********************************
   -- Determina Total de la Transaccion *
   -- ***********************************
   LET MtoTot =pMonto + pMonto2 + pComMonto + pComCashMonto + vMtoComDisp + Iva;
   LET TotComision = pComMonto + pComCashMonto + vMtoComDisp + Iva;
   LET SaldoCom = Saldo - TotComision;

   -- *************************************************************************
   -- *         Afecta Movimiento(s) de Cargo y Comision Respectivamente      *
   -- *************************************************************************

   -- ******************************************************
   -- Afecta Movto(s) de Disposicion en Cajeros y/o Compra *
   -- ******************************************************
   LET vMtoFavor= pMonto - vMtoPaso;

   IF pDivisa <> v_mn THEN
        LET v_mtofavor_dlls =  vMtoFavor / v_tipocambio;
    else
        LET v_mtofavor_dlls = 0;
    end if;


   IF vMtoFavor > 0 THEN
        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                         pUsuario, pNumTranFavor, vMtoFavor, pFolio,
                         pTarjeta, v_mtofavor_dlls, v_tipocambio,
                         FechaHoy, pReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
            LET TotComision = 0;
            LET Saldo = 0;
            RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                   cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF;
   END IF;

   IF vMtoPaso > 0 THEN
        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                         pUsuario, pNumTrans, vMtoPaso, pFolio,
                         pTarjeta, v_mto1_dlls, v_tipocambio,
                         FechaHoy, pReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
            LET TotComision = 0;
            LET Saldo = 0;
            RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                   cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;
        END IF;
   END IF;
    
    --En caso de no tener saldo a favor se acumula la disposicion de efectivo
    IF v_bactsaldo = 1 THEN --RQM 10 1225-2
        UPDATE bdicred:"informix".sd_maesdos 
        SET sdo_acum_vencido = v_montoact
        WHERE empresa='001' and num_credito = pNumCredito;
    END IF;

   -- ***********************************************************
   -- Afecta Movimiento(s) por Comision de Disposicion o COmpra *
   -- ***********************************************************
   IF pComMonto > 0 THEN

-- jon ini mod surcharge
        if (pSurcharge = 'V') then
            if (pComNumTrans = '0857') then     -- red
                LET pComNumTrans = '0890';
            elif (pComNumTrans = '0858') then -- convenio
                LET pComNumTrans = '0891';
            elif (pComNumTrans = '0859') then -- internacional
                LET pComNumTrans = '0892';
            end if;
        end if;
-- jon fin mod surcharge

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario,pComNumTrans,pComMonto, pComFolio,
                                     pTarjeta, v_com1_dlls, v_tipocambio,
                                     FechaHoy, pComReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
            LET cod_ret2 = cod_ret;
                    LET TotComision = 0;
                    LET Saldo = 0;
                    RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                           cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF
   END IF

   -- ********************************************
   -- Afecta Movto(s) de Disposicion en Comercio *
   -- ********************************************
   IF pMonto2 > 0 THEN

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario, pCashTranCen, pMonto2,pCashFolio,
                                     pTarjeta, v_mto2_dlls, v_tipocambio,
                                     FechaHoy, pReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
                LET TotComision = 0;
                LET Saldo = 0;
                RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                       cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF

   END IF

   -- **************************************************************
   -- Afecta Movimiento(s) por Comision de Disposicion en Comercio *
   -- **************************************************************
   IF pComCashMonto > 0 THEN

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario,pComCashNumTrans, pComCashMonto,
                     pComCashFolio, pTarjeta, v_com2_dlls,
                     v_tipocambio, FechaHoy,
                     pComCashReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
        LET cod_ret2 = cod_ret;
                LET TotComision = 0;
                LET Saldo = 0;
                RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                       cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF
   END IF

   -- **************************************************************
   -- Afecta Movimiento(s) por Comision de Disposicion de Efectivo *
   -- **************************************************************
   IF vMtoComDisp > 0 THEN

        EXECUTE PROCEDURE "informix".cargo_cred(wEmpresa, pNumCredito, pSucursal,
                                     pUsuario,v_codparam, vMtoComDisp,
                                     pFolio, pTarjeta, v_com2_dlls,
                                     v_tipocambio, FechaHoy,
                                     pComCashReferencia,"","")
        INTO cod_ret;

        IF cod_ret <> "000" THEN
                LET TotComision = 0;
                LET Saldo = 0;
                RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
                       cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;

        END IF
   END IF

   LET Saldo = Saldo - MtoTot;

-- jom ini -- Se elimina el iva del total comision
   if (pSurcharge = 'V' or vEscajero = '1') then
      LET TotComision = vMtoComDisp + vMtoComDisp_iva;      -- RRG Se modifica para el proyecto de circular 22/2010 comisiones ATM 26/10/2010
   else
      LET TotComision = TotComision - Iva;
   end if;
-- jom fin

   RETURN cod_ret, pNumTran, FechaHoy, Saldo, MtoTot,
      cod_ret2, pComNumTran, FechaHoy, SaldoCom, TotComision;


END PROCEDURE;