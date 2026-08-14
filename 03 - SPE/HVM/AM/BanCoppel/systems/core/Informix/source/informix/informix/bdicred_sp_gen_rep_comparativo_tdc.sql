CREATE PROCEDURE "informix".sp_gen_rep_comparativo_tdc(pnum_solicitud varchar(20))

RETURNING   CHAR(5)         AS Codigo, 		  -- CODIGO DE RETORNO
            CHAR(19)   AS TasaInteresProd1,  -- TASA INTERES FIJA ANUAL PRODUCTO 1
            CHAR(19)   AS TasaInteresProd2,  -- TASA INTERES FIJA ANUAL PRODUCTO 2
			CHAR(2)         AS CargoDispProd1,    -- CARGO DISPOSICION EFECTIVO PRODUCTO 1
			CHAR(2)         AS CargoDispProd2,    -- CARGO DISPOSICION EFECTIVO PRODUCTO 2
			CHAR(4)         AS AnualidadProd1,    -- ANUALIDAD PRODUCTO 1
			CHAR(4)         AS AnualidadProd2,     -- ANUALIDAD PRODUCTO 2
			CHAR(40)		AS NombreProducto1,
			CHAR(40)		AS NombreProducto2
			--  CONTROL DE CAMBIOS
---------------------------------------------------------------------------------------------------------------
--ELABORO: Marco Antonio Cardenas Medina
--Descripcion: se crea para llenar el reporte comparativotdcoro.rpt
--Fecha: 2022/03/18
---------------------------------------------------------------------------------------------------------------

-- VARIABLES DE CONTROL DE ERRORES
DEFINE isqlerr      	INTEGER;			-- CODIGO DE ERROR
DEFINE cCodret			CHAR(5);            -- CODIGO RETORNO
-- VARIABLES PARA RETORNO DE DATOS
DEFINE dTasaInteresProd1		DECIMAL(18,1);		-- TASA INTERES FIJA ANUAL PRODUCTO 1
DEFINE dTasaInteresProd2		DECIMAL(18,1);		-- TASA INTERES FIJA ANUAL PRODUCTO 2
DEFINE iCargoDispProd1			INTEGER;			-- CARGO DISPOSICION EFECTIVO PRODUCTO 1
DEFINE iCargoDispProd2			INTEGER;			-- CARGO DISPOSICION EFECTIVO PRODUCTO 2

-- VARIABLES AUXILIARES
DEFINE cCod_comision_efectivo1 		CHAR(6);
DEFINE cCod_comision_efectivo2		CHAR(6);
DEFINE cCodRetSp 					CHAR(5);
DEFINE cTasaMorSp					INTEGER;
DEFINE cProd1						CHAR(4);
DEFINE cProd2						CHAR(4);
DEFINE cNombreProd1					CHAR(40);
DEFINE cNombreProd2					CHAR(40);

DEFINE cCodRet1           			CHAR(5);
DEFINE cPeriodoPlazo1				CHAR(1);
DEFINE cComi_comision_anual1		CHAR(1);
DEFINE dComi_disposicion1       	DECIMAL(16);
DEFINE dComi_gasto_cobranza1		DECIMAL(16);
DEFINE dComi_aclaracion_no1    		DECIMAL(16);
DEFINE dComi_liquidacion_antic1 	DECIMAL(16);
DEFINE cComi_apertura1				CHAR(1);
DEFINE dMonto_comision_anual1		DECIMAL(20,2);	-- ANUALIDAD PRODUCTO 1
DEFINE dMonto_comi_disposicion1		DECIMAL(20,2);
DEFINE dMonto_gasto_cobranza1		DECIMAL(20,2);
DEFINE dMonto_aclaracion_no1		DECIMAL(20,2);
DEFINE dMonto_liquidacion_antic1	DECIMAL(20,2);
DEFINE dMonto_comis_apertura1		DECIMAL(20,2);
DEFINE cCodRet2           			CHAR(5);
DEFINE cPeriodoPlazo2				CHAR(1);
DEFINE cComi_comision_anual2		CHAR(1);
DEFINE dComi_disposicion2       	DECIMAL(16);
DEFINE dComi_gasto_cobranza2		DECIMAL(16);
DEFINE dComi_aclaracion_no2    		DECIMAL(16);
DEFINE dComi_liquidacion_antic2 	DECIMAL(16);
DEFINE cComi_apertura2				CHAR(1);
DEFINE dMonto_comision_anual2		DECIMAL(20,2); -- ANUALIDAD PRODUCTO 2
DEFINE dMonto_comi_disposicion2		DECIMAL(20,2);
DEFINE dMonto_gasto_cobranza2		DECIMAL(20,2);
DEFINE dMonto_aclaracion_no2		DECIMAL(20,2);
DEFINE dMonto_liquidacion_antic2	DECIMAL(20,2);
DEFINE dMonto_comis_apertura2		DECIMAL(20,2);


LET iSqlErr 				= 0;
LET cCodRet 				= '00000';
LET dTasaInteresProd1		= 0;
LET dTasaInteresProd2		= 0;
LET iCargoDispProd1			= 0;
LET iCargoDispProd2			= 0;
LET cCod_comision_efectivo1 = '';
LET cCod_comision_efectivo2 = '';
LET cCodRetSp				= '';
LET cTasaMorSp				= 0;
LET cProd1 					= '6001';
LET cProd2 					= '8100';
LET cNombreProd1			= '';
LET cNombreProd2			= '';

BEGIN
	-- ****************************************************************************
	-- *                        CONTROL DE ERRORES                                *
	-- ****************************************************************************

	ON EXCEPTION SET iSqlErr
		LET cCodRet= iSqlErr;
		RETURN cCodRet,0,0,0,0,0,0,'','';
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/MarcoCardenas/RQM679/sp_gen_rep_comparativo_tdc.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************
	
	SELECT cod_comision_efectivo
			INTO cCod_comision_efectivo1
			FROM bdicred:sd_definicion
			WHERE num_producto = cProd1;
			
	SELECT cod_comision_efectivo
			INTO cCod_comision_efectivo2
			FROM bdicred:sd_definicion
			WHERE num_producto = cProd2;
	
	SELECT apli_factor 
	INTO iCargoDispProd1 
    FROM bdicred:sd_tpcomis WHERE cod_comis = 	NVL(cCod_comision_efectivo1,'');
	
	SELECT apli_factor 
	INTO iCargoDispProd2 
    FROM bdicred:sd_tpcomis WHERE cod_comis = NVL(cCod_comision_efectivo2,'');
	
	EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas('001', pnum_solicitud, cProd1) INTO cCodRetSp,dTasaInteresProd1,cTasaMorSp;

	EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas('001', pnum_solicitud, cProd2) INTO cCodRetSp,dTasaInteresProd2,cTasaMorSp;
	
	EXECUTE PROCEDURE "informix".sp_obtiene_comisiones_productos(cProd1, '') INTO cCodRet1,cPeriodoPlazo1,cComi_comision_anual1,dMonto_comision_anual1,dComi_disposicion1,dMonto_comi_disposicion1,dComi_gasto_cobranza1,dMonto_gasto_cobranza1,
			   dComi_aclaracion_no1,dMonto_aclaracion_no1,dcomi_liquidacion_antic1,dMonto_liquidacion_antic1,cComi_apertura1,dMonto_comis_apertura1;
	
	EXECUTE PROCEDURE "informix".sp_obtiene_comisiones_productos(cProd2, '') INTO cCodRet2,cPeriodoPlazo2,cComi_comision_anual2,dMonto_comision_anual2,dComi_disposicion2,dMonto_comi_disposicion2,dComi_gasto_cobranza2,dMonto_gasto_cobranza2,
			   dComi_aclaracion_no2,dMonto_aclaracion_no2,dcomi_liquidacion_antic2,dMonto_liquidacion_antic2,cComi_apertura2,dMonto_comis_apertura2;
	
	LET cNombreProd1 = 'Tarjeta de Crédito BanCoppel Visa';
	LET cNombreProd2 = 'Tarjeta de Crédito BanCoppel Oro';
	
	RETURN cCodRet, dTasaInteresProd1, dTasaInteresProd2, iCargoDispProd1, iCargoDispProd2, dMonto_comision_anual1, dMonto_comision_anual2, cNombreProd1, cNombreProd2;
	
END
END PROCEDURE;