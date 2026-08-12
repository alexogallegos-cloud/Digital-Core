CREATE PROCEDURE "informix".sp_sacreportesemanalsolfi (pNumConv CHAR (5),pConsecutivo INTEGER)

	RETURNING	CHAR (6)	AS cCod_Ret,
				INTEGER 	AS rec_lunes,
				INTEGER 	AS rec_martes,
				INTEGER 	AS rec_miercoles,
				INTEGER 	AS rec_jueves,
				INTEGER 	AS rec_viernes,
				INTEGER 	AS rec_sabado,
				INTEGER 	AS rec_domingo,
				MONEY(16,2) AS cob_lunes,
				MONEY(16,2) AS cob_martes,
				MONEY(16,2) AS cob_miercoles,
				MONEY(16,2) AS cob_jueves,
				MONEY(16,2) AS cob_viernes,
				MONEY(16,2) AS cob_sabado,
				MONEY(16,2) AS cob_domingo,
				INTEGER 	AS rec_efectivo,
				INTEGER 	AS rec_chequemb,
				INTEGER 	AS rec_chequeob,
				INTEGER 	AS rec_tarcred,
				MONEY(16,2) AS cob_efectivo,
				MONEY(16,2) AS cob_cheqmb,
				MONEY(16,2) AS cob_cheqob,
				MONEY(16,2) AS cob_tarcred,
				MONEY(16,2) AS liq_miercoles,
				MONEY(16,2) AS liq_jueves,
				MONEY(16,2) AS liq_viernes,
				MONEY(16,2) AS liq_lunes,
				MONEY(16,2) AS liq_martes,
				MONEY(16,2) AS aclaraciones,
				MONEY(16,2) AS comision,
				MONEY(16,2) AS iva_comision,
				DATE 		AS fec_iniperiodo,
				DATE 		AS fec_finperiodo,
				INTEGER 	AS consecutivo;
	
--DECLARACION DE VARIABLES
DEFINE cCodRet  		CHAR(6);
DEFINE isqlerr   		INTEGER;
DEFINE iRecLun 			INTEGER;	
DEFINE iRecMar 			INTEGER;	
DEFINE iRecMie 			INTEGER;
DEFINE iRecJue			INTEGER;		
DEFINE iRecVie 			INTEGER;	
DEFINE iRecSab 			INTEGER;	
DEFINE iRecDom			INTEGER;	
DEFINE mCobLun			MONEY(16,2);
DEFINE mCobMar			MONEY(16,2);
DEFINE mCobMie			MONEY(16,2);
DEFINE mCobJue			MONEY(16,2);
DEFINE mCobVie			MONEY(16,2);
DEFINE mCobSab			MONEY(16,2);
DEFINE mCobDom			MONEY(16,2);
DEFINE iRecEfec 		INTEGER;
DEFINE iRecChequemb 	INTEGER;
DEFINE iRecChqOb 		INTEGER;
DEFINE iRecTarCred		INTEGER;
DEFINE mCobEfe			MONEY(16,2);
DEFINE mCobChqmb		MONEY(16,2);
DEFINE mCobChqOb		MONEY(16,2);
DEFINE mCobTarCred		MONEY(16,2);
DEFINE mLiqLun			MONEY(16,2);
DEFINE mLiqMart			MONEY(16,2);
DEFINE mLiqMie			MONEY(16,2);
DEFINE mLiqJue			MONEY(16,2);
DEFINE mLiqVie			MONEY(16,2);
DEFINE mLiqSab			MONEY(16,2);
DEFINE mLiqDom			MONEY(16,2);
DEFINE mAclaracion		MONEY(16,2);
DEFINE mComision		MONEY(16,2);
DEFINE mIvaCom			MONEY(16,2);
DEFINE dtFechIniPed 	DATE;
DEFINE dtFechFinPed 	DATE;


--INICIALIZACION DE VARIABLES
LET cCodRet  		= '000000';
LET isqlerr   		= 0;
LET iRecLun 		= 0;	
LET iRecMar 		= 0;	
LET iRecMie 		= 0;
LET iRecJue			= 0;		
LET iRecVie 		= 0;	
LET iRecSab 		= 0;	
LET iRecDom			= 0;	
LET mCobLun			= 0;
LET mCobMar			= 0;
LET mCobMie			= 0;
LET mCobJue			= 0;
LET mCobVie			= 0;
LET mCobSab			= 0;
LET mCobDom			= 0;
LET iRecEfec 		= 0;
LET iRecChequemb 	= 0;
LET iRecChqOb 		= 0;
LET iRecTarCred		= 0;
LET mCobEfe			= 0;
LET mCobChqmb		= 0;
LET mCobChqOb		= 0;
LET mCobTarCred		= 0;
LET mLiqLun			= 0;
LET mLiqMart		= 0;
LET mLiqMie			= 0;
LET mLiqJue			= 0;
LET mLiqVie			= 0;
LET mLiqSab			= 0;
LET mLiqDom			= 0;
LET mAclaracion		= 0;
LET mComision		= 0;
LET mIvaCom			= 0;
LET dtFechIniPed 	= DATE(1);
LET dtFechFinPed 	= DATE(1);
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	
	--SET DEBUG FILE TO '/respaldosbd/isarai/sp_sacreportesemanalsolfi.out';
	--TRACE ON;
	
BEGIN
    
    ON EXCEPTION  SET isqlerr
        IF isqlerr <> 0  THEN
		    LET  cCodRet  = isqlerr;
			
			RETURN cCodRet, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, 	mCobSab, mCobDom, iRecEfec, iRecChequemb, iRecChqOb, iRecTarCred, mCobEfe, mCobChqmb, mCobChqOb, mCobTarCred, mLiqMie, 	   mLiqJue, mLiqVie, mLiqLun, mLiqMart, mAclaracion, mComision, mIvaCom, dtFechIniPed, dtFechFinPed, pConsecutivo;
        END IF;
    END  EXCEPTION;	
	
	IF pNumConv = ''  OR pConsecutivo = 0 THEN
		LET  cCodRet  = '000001';

		RETURN cCodRet, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, 	mCobSab, mCobDom, iRecEfec, iRecChequemb, iRecChqOb, iRecTarCred, mCobEfe, mCobChqmb, mCobChqOb, mCobTarCred, mLiqMie, 	   mLiqJue, mLiqVie, mLiqLun, mLiqMart, mAclaracion, mComision, mIvaCom, dtFechIniPed, dtFechFinPed, pConsecutivo;
	ELSE
		SET ISOLATION TO DIRTY READ;
		
		FOREACH		
			SELECT {+INDEX ("informix".sac_liquidacionsemanal idx_sacliqsem)} rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, cob_martes,cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred, liq_miercoles, liq_jueves, liq_viernes, liq_lunes, liq_martes,aclaraciones, comision, iva_comision, fec_iniperiodo, fec_finperiodo
			INTO iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom, iRecEfec, iRecChequemb, iRecChqOb, iRecTarCred, mCobEfe, mCobChqmb, mCobChqOb, mCobTarCred, mLiqMie,mLiqJue, mLiqVie, mLiqLun, mLiqMart, mAclaracion, mComision, mIvaCom, dtFechIniPed, dtFechFinPed
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = pNumConv
			AND  consecutivo_convenio  = pConsecutivo

			RETURN cCodRet, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, 	mCobSab, mCobDom, iRecEfec, iRecChequemb, iRecChqOb, iRecTarCred, mCobEfe, mCobChqmb, mCobChqOb, mCobTarCred, mLiqMie, 	   mLiqJue, mLiqVie, mLiqLun, mLiqMart, mAclaracion, mComision, mIvaCom, dtFechIniPed, dtFechFinPed, 
			pConsecutivo WITH RESUME;
			
		END FOREACH;	
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Isarai Bojorquez',
'DESCRIPCIÓN: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos referenciados (SOLFI) ejecutado por repsac.exe',
'FECHA : 22-04-2014',
'VERSIÓN: 20140422.0935',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_validapagoremesa(pEmpresa CHAR(3), pMontoremesa DECIMAL(10,2))

RETURNING CHAR(5) AS cod_ret;

--- Definicion de variables
DEFINE  cCodRet 		CHAR(5);
DEFINE	iSqlErr			INTEGER;
DEFINE  cDivisa 		CHAR(2);
DEFINE  cMontoMaximo 	CHAR(25);
DEFINE  dTatalDllrs		DECIMAL(10,2);
DEFINE  dTipoCambio 	DECIMAL(10,2);

--Inicializacion  de Variables
LET cCodRet 		= '00001';
LET iSqlErr  		= 0;
LET cDivisa  		= "";
LET cMontoMaximo 	= "";
LET dTatalDllrs		= 0.00;
LET dTipoCambio     = 0.00;

    --SET DEBUG FILE TO '/respaldosbd/christian/sp_validapagoremesa.out';
    --TRACE ON;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

    IF NVL(pEmpresa,"") <> "" AND NVL(pMontoremesa,"") <> "" THEN

	--Consulta para saber el monto maximo para pagar las remesas en dolares y se hace la convercion peso-dolar
		SELECT valor
		INTO cMontoMaximo
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87083';

	--Validar que el monto a pagar de la remesa sea igual o menor que el permitido
		IF pMontoremesa <= cMontoMaximo THEN
			LET cCodRet = '00000'; --Codigo de retorno de exito
		ELSE
			LET cCodRet = '00002'; --Indica que el monto a pagar es mayor al permitido
		END IF
	ELSE
		RETURN cCodRet; -- codigo de retorno "00001" que indica que no coinciden los datos o son vacios.
	END IF

	RETURN cCodRet;
END;
END PROCEDURE
 DOCUMENT
 'AUTOR: Christian Echavarria',
 'DESCRIPCION: valida si a un Cliente se le permite Cobrar un envio WU dependiendo de un monto maximo a pagar por remesa.',
 'FECHA: 13/08/2013',
 'BD:   bdisac';

CREATE PROCEDURE "informix".sp_sacreportecobranzasucursal (cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE, siRegistros SMALLINT)

-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno,            --Codigo de Retorno
CHAR(40) AS nombre,             --Nombre convenio
CHAR(5)  AS IdConvenio,
CHAR(16) AS folio_suc,          --Folio de sucursal
CHAR(20) AS referencia1,        --Num telefono (Telmex), Num cliente(Coppel)
CHAR(20) AS referencia2,        --DV (Telmex), Recibo(Coppel)
CHAR(30) AS IdReferencia1,      --Nombre Referencia 1
CHAR(30) AS IdReferencia2,      --Nombre Referencia 2
MONEY(16,2) AS montoCargo,      --Monto de cargo a cuenta
MONEY(16,2) AS montoEfectivo,   --Monto de pago en efectivo
CHAR(1) AS forma_pago,
CHAR(40) AS region,             --Region de la sucursal
CHAR(4) AS sucursal,            --Numero de la sucursal
SMALLINT AS ciclo;

-- DEFINICION DE VARIABLES
DEFINE cCodRet                  CHAR(5);
DEFINE iSqlErr                  INTEGER;
DEFINE iIsamErr                 INTEGER;

DEFINE iTransCargoTelmex	INTEGER;
DEFINE iTransCargoCoppel	INTEGER;
DEFINE iTransEfecTelmex		INTEGER;
DEFINE iTransEfecCoppel		INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iRegistrosHoy		INTEGER;
DEFINE iRegistrosAnt		INTEGER;
DEFINE cTransCargoTelmex	CHAR(4);
DEFINE cTransCargoCoppel	CHAR(4);
DEFINE cTransEfecTelmex		CHAR(4);
DEFINE cTransEfecCoppel		CHAR(4);
DEFINE cInfoErr				CHAR(100);
DEFINE cCodRetParam			CHAR(5);
DEFINE cIdConvenio			CHAR(5);
DEFINE cFormaPago			CHAR(3);
DEFINE cNumTransaccEfec		CHAR(4);
DEFINE cIdReferencia1		CHAR(100);
DEFINE cIdReferencia2		CHAR(100);
DEFINE cRegion				CHAR(40);
DEFINE cFolioSuc			CHAR(16);
DEFINE cReferencia1			CHAR(20);
DEFINE cReferencia2			CHAR(20);
DEFINE cNomconvenio			CHAR(40);
DEFINE mCargoCuenta			MONEY(16,2);
DEFINE mCargoEfectivo		MONEY(16,2);
DEFINE siCiclo				SMALLINT;
DEFINE cFecha_Hoy			CHAR(10);
DEFINE ctransEfecEnvioOrden			CHAR(4);
DEFINE ctransEfecEnvioComision		CHAR(4);
DEFINE ctransEfecEnvioIVA			CHAR(4);
DEFINE ctransCargoEnvioOrden		CHAR(4);
DEFINE ctransCargoEnvioComision		CHAR(4);
DEFINE ctransCargoEnvioIVA			CHAR(4);
DEFINE ctransEfecPagoOrden			CHAR(4);
DEFINE ctransEfecCancelacionOrden	CHAR(4);
DEFINE cTransCargoSky    			CHAR(4);
DEFINE cTransEfecSky            	CHAR(4);
DEFINE itransEfecEnvioOrden			INTEGER;
DEFINE itransEfecEnvioComision		INTEGER;
DEFINE itransEfecEnvioIVA			INTEGER;
DEFINE itransCargoEnvioOrden		INTEGER;
DEFINE itransCargoEnvioComision		INTEGER;
DEFINE itransCargoEnvioIVA			INTEGER;
DEFINE itransEfecPagoOrden			INTEGER;
DEFINE itransEfecCancelacionOrden	INTEGER;
DEFINE cTransCargo					CHAR(4);
DEFINE cTransEfec					CHAR(4);
DEFINE siProcesoAutomatico			SMALLINT;
DEFINE cConsmovhis      			CHAR(10);
--HOMOLOGACION GDF
DEFINE cTranCredPGDF   				CHAR(100);
DEFINE mCargoCuentaCred			    MONEY(16,2);

--INICIALIZACION DE VARIABLES--
LET cCodRet               = "00000";
LET cCodRetParam          = "";
LET cIdConvenio           = "";
LET cIdReferencia1        = "";
LET cIdReferencia2        = "";
LET cFolioSuc             = "";
LET cReferencia1          = "";
LET cReferencia2          = "";
LET cNomconvenio          = "";
LET cFormaPago            = "0";
LET cRegion               = "";
LET cTransCargoTelmex     = "";
LET cTransCargoCoppel     = "";
LET cTransEfecTelmex	  = "";
LET cTransEfecCoppel	  = "";

LET ctransEfecEnvioOrden		= "";
LET ctransEfecEnvioComision     = "";
LET ctransEfecEnvioIVA			= "";
LET ctransCargoEnvioOrden		= "";
LET ctransCargoEnvioComision    = "";
LET ctransCargoEnvioIVA			= "";
LET ctransEfecPagoOrden			= "";
LET ctransEfecCancelacionOrden  = "";
LET cTransCargoSky    			= "";
LET cTransEfecSky            	= "";

/*
LET iTransCargoTelmex     = 0;
LET iTransCargoCoppel     = 0;
LET iTransEfecTelmex     = 0;
LET iTransEfecCoppel     = 0;

LET itransEfecEnvioOrden		= 0;
LET itransEfecEnvioComision		= 0;
LET itransEfecEnvioIVA			= 0;
LET itransCargoEnvioOrden		= 0;
LET itransCargoEnvioComision	= 0;
LET itransCargoEnvioIVA			= 0;
LET itransEfecPagoOrden			= 0;
LET itransEfecCancelacionOrden  = 0;
*/
LET mCargoCuenta          = 0;
LET mCargoEfectivo        = 0;
LET siCiclo               = 0;
LET iCuantos			  = 0;
LET cFecha_Hoy            = "";
LET iRegistrosHoy		 = 0;
LET iRegistrosAnt		 = 0;
LET cTransCargo			 = "";
LET cTransEfec			 = "";
LET siProcesoAutomatico	 = 0;
--HOMOLOGACION GDF
LET cTranCredPGDF   	 = "";
LET mCargoCuentaCred	 = 0;


BEGIN


	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportecobranzasucursal");
				RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo;
		END IF;

	END EXCEPTION;


--SET DEBUG FILE TO  '/respaldosbd/Martha/sacreporte_suc.out';
--TRACE ON;

	SET LOCK MODE TO WAIT 5;

	IF  cSucursal = "" OR LENGTH(cSucursal) <> 4 THEN
			LET cCodRet = "00001";
			RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo;
	ELSE
		SET ISOLATION TO DIRTY READ ;
		SELECT  fecha_hoy
		INTO cFecha_hoy
		FROM bdisac:"informix".sac_fechas;

		SELECT COUNT(*)
		INTO iRegistrosHoy
		FROM bdisac:"informix".sac_movimientos
		WHERE fecha_pago = cFecha_hoy
		AND id_sucursal = cSucursal;

		SELECT valor
		INTO cConsmovhis
		FROM bdicheq:"informix".sc_param
		WHERE codparam = 'fechcon_movhis' AND empresa = '001';

		SET ISOLATION TO DIRTY READ;

		SELECT LPAD (TRIM(CAST(NVL(SUM(CAST(transCargoTelmex AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoTelmex,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoCoppel AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoCoppel,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecCoppel AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecCoppel,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecTelmex AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecTelmex,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecEnvioOrden AS INTEGER)), 0)AS CHAR(4))), 4, '0') AS transEfecEnvioOrden,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecEnvioComision AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecEnvioComision,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecEnvioIVA AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecEnvioIVA,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoEnvioOrden AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoEnvioOrden,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoEnvioComision AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoEnvioComision,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoEnvioIVA AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoEnvioIVA,
				LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecPagoOrden AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecPagoOrden,
			LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecCancelacionOrden AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecCancelacionOrden,
			LPAD (TRIM(CAST(NVL(SUM(CAST(transCargoSky AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoSky,
			LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecSky AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecSky
		INTO cTransCargoTelmex,
				cTransCargoCoppel,
				cTransEfecCoppel,
				cTransEfecTelmex,
				ctransEfecEnvioOrden,
				ctransEfecEnvioComision,
				ctransEfecEnvioIVA,
				ctransCargoEnvioOrden,
				ctransCargoEnvioComision,
				ctransCargoEnvioIVA,
				ctransEfecPagoOrden,
				ctransEfecCancelacionOrden,
				cTransCargoSky,
				cTransEfecSky
		FROM TABLE(MULTISET(SELECT CASE WHEN cod_param = 80001 THEN TRIM(VALOR) END AS transCargoTelmex,
									CASE WHEN cod_param = 80002 THEN TRIM(VALOR) END AS transCargoCoppel,
									CASE WHEN cod_param = 901001 THEN TRIM(VALOR) END AS transEfecCoppel,
									CASE WHEN cod_param = 902001 THEN TRIM(VALOR) END AS transEfecTelmex,
									CASE WHEN cod_param = 5070011 THEN TRIM(VALOR) END AS transEfecEnvioOrden,
									CASE WHEN cod_param = 511070011 THEN TRIM(VALOR) END AS transEfecEnvioComision,
									CASE WHEN cod_param = 510070011 THEN TRIM(VALOR) END AS transEfecEnvioIVA,
									CASE WHEN cod_param = 5070012 THEN TRIM(VALOR) END AS transCargoEnvioOrden,
									CASE WHEN cod_param = 511070012 THEN TRIM(VALOR) END AS transCargoEnvioComision,
									CASE WHEN cod_param = 510070012 THEN TRIM(VALOR) END AS transCargoEnvioIVA,
									CASE WHEN cod_param = 41407002 THEN TRIM(VALOR) END AS transEfecPagoOrden,
				CASE WHEN cod_param = 41507003 THEN TRIM(VALOR) END AS transEfecCancelacionOrden,
				CASE WHEN cod_param = 80006 THEN TRIM(VALOR) END AS transCargoSky,
				CASE WHEN cod_param = 906001 THEN TRIM(VALOR) END AS transEfecSky
		FROM bdisac:"informix".sac_param));

		/*LET cTransCargoTelmex = LPAD(CAST(iTransCargoTelmex AS CHAR(4)), 4, '0');
		LET cTransCargoCoppel = LPAD(CAST(iTransCargoCoppel AS CHAR(4)), 4, '0');
		LET cTransEfecTelmex = LPAD(CAST(iTransEfecTelmex AS CHAR(4)), 4, '0');
		LET cTransEfecCoppel = LPAD(CAST(iTransEfecCoppel AS CHAR(4)), 4, '0');
		LET ctransEfecEnvioOrden = LPAD(CAST(itransEfecEnvioOrden AS CHAR(4)), 4, '0');
		LET ctransEfecEnvioComision = LPAD(CAST(itransEfecEnvioComision AS CHAR(4)), 4, '0');
		LET ctransEfecEnvioIVA = LPAD(CAST(itransEfecEnvioIVA AS CHAR(4)), 4, '0');
		LET ctransCargoEnvioOrden = LPAD(CAST(itransCargoEnvioOrden AS CHAR(4)), 4, '0');
		LET ctransCargoEnvioComision = LPAD(CAST(itransCargoEnvioComision AS CHAR(4)), 4, '0');
		LET ctransCargoEnvioIVA = LPAD(CAST(itransCargoEnvioIVA AS CHAR(4)), 4, '0');
		LET ctransEfecPagoOrden = LPAD(CAST(itransEfecPagoOrden AS CHAR(4)), 4, '0');
		LET ctransEfecCancelacionOrden = LPAD(CAST(itransEfecCancelacionOrden AS CHAR(4)), 4, '0');
	*/



		IF dFechaIni < cFecha_hoy THEN

			SELECT COUNT(*)
			INTO iRegistrosAnt
			FROM bdisac:"informix".sac_movimientoshistorial
			WHERE fecha_pago BETWEEN dFechaIni AND dFechaFin;

			SET LOCK MODE TO WAIT  ;
			SET ISOLATION TO DIRTY READ ;

			SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc2)} COUNT(*) INTO iCuantos
			FROM bdisac:"informix".sac_movhissuc
			WHERE sucursal = cSucursal
			AND fech_alt = dFechaIni;

			IF iCuantos = 0 THEN

				SET ISOLATION TO DIRTY READ ;
				IF dFechaIni >= cConsmovhis THEN
					SELECT sucursal, transacc, monto_tot, fech_alt, folio_suc
					FROM bdicheq:"informix".sc_movhis
					WHERE empresa = '001'
					AND cuenta IS NOT NULL
					AND fech_alt = dFechaIni
					AND cancelad IS NOT NULL
					AND transacc IN (cTransCargoCoppel,
										cTransCargoTelmex,
										cTransEfecTelmex,
										cTransEfecCoppel,
										ctransEfecEnvioOrden,
										ctransEfecEnvioComision,
										ctransEfecEnvioIVA,
										ctransCargoEnvioOrden,
										ctransCargoEnvioComision,
										ctransCargoEnvioIVA,
										ctransEfecPagoOrden,
										ctransEfecCancelacionOrden,
										cTransCargoSky,
										cTransEfecSky)
					AND sucursal = cSucursal
					INTO TEMP tmp_sac_movhis
					WITH NO LOG;
				 ELSE
					SELECT sucursal, transacc, monto_tot, fech_alt, folio_suc
											FROM bdicheq:"informix".sc_movhis_old
											WHERE empresa = '001'
											AND cuenta IS NOT NULL
											AND fech_alt = dFechaIni
											AND cancelad IS NOT NULL
											AND transacc IN (cTransCargoCoppel,
																cTransCargoTelmex,
																cTransEfecTelmex,
																cTransEfecCoppel,
																ctransEfecEnvioOrden,
																ctransEfecEnvioComision,
																ctransEfecEnvioIVA,
																ctransCargoEnvioOrden,
																ctransCargoEnvioComision,
																ctransCargoEnvioIVA,
																ctransEfecPagoOrden,
																ctransEfecCancelacionOrden,
																cTransCargoSky,
																cTransEfecSky)
											AND sucursal = cSucursal
											INTO TEMP tmp_sac_movhis
											WITH NO LOG;
				 END IF;

				DELETE FROM bdisac:"informix".sac_movhissuc WHERE sucursal = cSucursal;

				SET LOCK MODE TO WAIT  ;
				SET ISOLATION TO DIRTY READ ;

				INSERT INTO bdisac:"informix".sac_movhissuc(sucursal, transacc, monto_tot, fech_alt, folio_suc)
				SELECT sucursal, transacc, monto_tot, fech_alt, folio_suc
				FROM bdisac:"informix".tmp_sac_movhis;

				DROP TABLE bdisac:"informix".tmp_sac_movhis;

			END IF;
			IF iRegistrosHoy > 0 OR  iRegistrosAnt > 0 THEN
				SET ISOLATION TO DIRTY READ ;
				FOREACH
					SELECT  b.folio_suc, f.numcategoria||f.numconvenio AS numconvenio, f.nomconvenio, b.referencia1,
						b.referencia2, b.forma_pago, e.nombre, f.trans_cen_cargo_cliente, f.trans_cen_efectivo_cliente, f.proceso_automatico,
						f.nombre_referencia1, f.nombre_referencia2
					INTO cFolioSuc, cIdConvenio, cNomconvenio,cReferencia1, cReferencia2, cFormaPago, cRegion, cTransCargo, cTransEfec,
						siProcesoAutomatico, cIdReferencia1, cIdReferencia2
					FROM bdisac:"informix".sac_movimientos b, bdinteg:"informix".si_sucursales c, bdinteg:"informix".si_plazas d, bdinteg:"informix".si_regional e, bdisac:"informix".sac_convenios f
					WHERE b.id_sucursal = cSucursal
					AND b.numcategoria = f.numcategoria
					AND b.numconvenio = f.numconvenio
					AND b.status_cancelado <> 'S'
					AND c.sucursal = b.id_sucursal
					AND d.plaza = c.plaza
					AND e.empresa IS NOT NULL
					AND e.regional = d.regional
					UNION ALL
					SELECT  b.folio_suc, f.numcategoria||f.numconvenio AS numconvenio, f.nomconvenio, b.referencia1,
						b.referencia2, b.forma_pago, e.nombre, f.trans_cen_cargo_cliente, f.trans_cen_efectivo_cliente, f.proceso_automatico,
						f.nombre_referencia1, f.nombre_referencia2
					FROM bdisac:"informix".sac_movimientoshistorial b, bdinteg:"informix".si_sucursales c, bdinteg:"informix".si_plazas d, bdinteg:"informix".si_regional e, bdisac:"informix".sac_convenios f
					WHERE b.numcategoria = f.numcategoria
					AND b.id_sucursal = cSucursal
					AND b.numconvenio = f.numconvenio
					AND b.status_cancelado <> 'S'
					AND b.fecha_pago BETWEEN dFechaIni AND  dFechaFin
					AND c.sucursal = b.id_sucursal
					AND d.plaza = c.plaza
					AND e.empresa IS NOT NULL
					AND e.regional = d.regional
					ORDER BY folio_suc
					IF siProcesoAutomatico = 1 THEN

						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = cTransCargo  THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = cTransEfec  THEN monto_tot END AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE folio_suc = cFolioSuc and empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = cTransCargo  THEN monto_tot END AS monto_totCargo,
													CASE WHEN transacc = cTransEfec  THEN monto_tot END AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc
											WHERE  folio_suc = cFolioSuc));						
						 
--	HOMOLOGACION GDF
						 --20130109.1030 inicio
					     IF	cIdConvenio = '08001' THEN
						 
							SELECT NVL(TRIM(valor),'')
							INTO cTranCredPGDF 
							FROM bdisac:"informix".sac_param 
							WHERE cod_param = '87033';
							
							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
							INTO mCargoCuentaCred
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredPGDF  
												THEN monto END AS monto_totCargo
												FROM bdicred:"informix".sd_movdia
												WHERE folio_suc = cFolioSuc AND empresa='001'));
				
						END IF;
					  --20130109.1030 fin
					ELSE

					SET ISOLATION TO DIRTY READ ;
					SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
					INTO cIdReferencia1
					FROM bdisac:"informix".sac_param
					WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = cIdConvenio
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '1';

					SET ISOLATION TO DIRTY READ ;
					SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
					INTO cIdReferencia2
					FROM bdisac:"informix".sac_param
					WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = cIdConvenio
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '2';

					IF cIdConvenio = '01001' THEN

						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = cTransCargoCoppel  THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = cTransEfecCoppel  THEN monto_tot END AS totEfectivo
											FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = cTransCargoCoppel THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = cTransEfecCoppel  THEN monto_tot END AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc WHERE   folio_suc = cFolioSuc ));

					ELIF cIdConvenio = '02001' THEN
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = cTransCargoTelmex  THEN monto_tot END AS monto_totCargo,
												   CASE WHEN transacc = cTransEfecTelmex  THEN monto_tot END AS totEfectivo
											FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = cTransCargoTelmex  THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = cTransEfecTelmex  THEN monto_tot END AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc WHERE  folio_suc = cFolioSuc ));

						ELIF cIdConvenio = '06001' THEN
							SET ISOLATION TO DIRTY READ ;
							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
							INTO mCargoCuenta, mCargoEfectivo
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc = cTransCargoSky  THEN monto_tot END AS monto_totCargo,
													   CASE WHEN transacc = cTransEfecSky  THEN monto_tot END AS totEfectivo
												FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'
												UNION ALL
												SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = cTransCargoSky  THEN monto_tot END AS monto_totCargo,
													CASE WHEN transacc = cTransEfecSky  THEN monto_tot END AS totEfectivo
												FROM bdisac:"informix".sac_movhissuc WHERE  folio_suc = cFolioSuc ));
					ELIF cIdConvenio = '07001' THEN
-- MODIFICACION
						 LET cReferencia1='********'||SUBSTRING (cReferencia1 FROM 9 FOR 4);

						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_CargoEnvioOrden), 0) + NVL(SUM(monto_CargoEnvioComision), 0) + NVL(SUM(monto_CargoEnvioIVA), 0) AS totCargo,
								NVL(SUM(monto_EfecEnvioOrden), 0) + NVL(SUM(monto_EfecEnvioComision), 0) + NVL(SUM(monto_EfecEnvioIVA), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(ctransCargoEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioOrden,
												CASE WHEN transacc = CAST(ctransCargoEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioComision,
												CASE WHEN transacc = CAST(ctransCargoEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioIVA,
												CASE WHEN transacc = CAST(ctransEfecEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioOrden,
												CASE WHEN transacc = CAST(ctransEfecEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioComision,
												CASE WHEN transacc = CAST(ctransEfecEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioIVA
											FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = CAST(ctransCargoEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioOrden,
												CASE WHEN transacc = CAST(ctransCargoEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioComision,
												CASE WHEN transacc = CAST(ctransCargoEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioIVA,
												CASE WHEN transacc = CAST(ctransEfecEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioOrden,
												CASE WHEN transacc = CAST(ctransEfecEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioComision,
												CASE WHEN transacc = CAST(ctransEfecEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioIVA
											FROM bdisac:"informix".sac_movhissuc WHERE folio_suc = cFolioSuc));


					ELIF cIdConvenio = '07002' THEN
						LET mCargoCuenta = 0;
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM TABLE(MULTISET(SELECT monto_tot AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE transacc = ctransEfecPagoOrden
											AND folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} monto_tot AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc
											WHERE transacc = ctransEfecPagoOrden
											AND folio_suc = cFolioSuc));

					ELIF cIdConvenio = '07003' THEN
						LET mCargoCuenta = 0;
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM TABLE(MULTISET(SELECT monto_tot AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE transacc = ctransEfecCancelacionOrden
											AND folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} monto_tot AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc
											WHERE transacc = ctransEfecCancelacionOrden
											AND folio_suc = cFolioSuc));

						END IF;
					END IF;

					LET siCiclo = siCiclo + 1;

		-- PAGINACION
					IF siCiclo <= siRegistros THEN
						CONTINUE FOREACH;
					END IF;
--HOMOLOGACION GDF					
					RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, TRIM(cIdReferencia1), TRIM(cIdReferencia2), mCargoCuenta + mCargoCuentaCred, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo
					WITH RESUME;
				END FOREACH;
			ELSE
				RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, TRIM(cIdReferencia1), TRIM(cIdReferencia2), mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo;
			END IF;
		ELSE

			IF iRegistrosHoy > 0 THEN
				SET ISOLATION TO DIRTY READ ;

				FOREACH

					SELECT  b.folio_suc, f.numcategoria||f.numconvenio AS numconvenio, f.nomconvenio, b.referencia1,
						b.referencia2, b.forma_pago, e.nombre, f.trans_cen_cargo_cliente, f.trans_cen_efectivo_cliente, f.proceso_automatico,
						f.nombre_referencia1, f.nombre_referencia2
					INTO cFolioSuc, cIdConvenio, cNomconvenio,cReferencia1, cReferencia2, cFormaPago, cRegion, cTransCargo, cTransEfec,
						siProcesoAutomatico, cIdReferencia1, cIdReferencia2
					FROM bdisac:"informix".sac_movimientos b, bdinteg:"informix".si_sucursales c, bdinteg:"informix".si_plazas d, bdinteg:"informix".si_regional e, bdisac:"informix".sac_convenios f
					WHERE b.id_sucursal = cSucursal
					AND b.numcategoria = f.numcategoria
					AND b.numconvenio = f.numconvenio
					AND b.status_cancelado <> 'S'
					AND c.sucursal = b.id_sucursal
					AND d.plaza = c.plaza
					AND e.regional = d.regional
					ORDER BY folio_suc
					IF siProcesoAutomatico = 1 THEN

						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = cTransCargo  THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = cTransEfec  THEN monto_tot END AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE folio_suc = cFolioSuc AND empresa='001'
											UNION ALL
											SELECT {+INDEX (bdisac:"informix".sac_movhissuc idx_sacmovhissuc)} CASE WHEN transacc = cTransCargo  THEN monto_tot END AS monto_totCargo,
													CASE WHEN transacc = cTransEfec  THEN monto_tot END AS totEfectivo
											FROM bdisac:"informix".sac_movhissuc
											WHERE  folio_suc = cFolioSuc));
						 --20130109.1030 inicio
						 IF	cIdConvenio = '08001' THEN
						 
							SELECT NVL(TRIM(valor),'')
							INTO cTranCredPGDF 
							FROM bdisac:"informix".sac_param 
							WHERE cod_param = '87033';
							
							SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
							INTO mCargoCuentaCred
							FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredPGDF  
												THEN monto END AS monto_totCargo
												FROM bdicred:"informix".sd_movdia
												WHERE folio_suc = cFolioSuc AND empresa='001'));
				
						END IF;
					 --20130109.1030 fin
					ELSE

						SET ISOLATION TO DIRTY READ ;
					SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
					INTO cIdReferencia1
					FROM bdisac:"informix".sac_param
					WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = cIdConvenio
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '1';

					SET ISOLATION TO DIRTY READ ;
					SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
					INTO cIdReferencia2
					FROM bdisac:"informix".sac_param
					WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = cIdConvenio
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '2';

					IF cIdConvenio = '01001' THEN

						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(cTransCargoCoppel AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = CAST(cTransEfecCoppel AS CHAR(4)) THEN monto_tot END AS totEfectivo
											FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'));

					ELIF cIdConvenio = '02001' THEN
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(cTransCargoTelmex AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
												CASE WHEN transacc = CAST(cTransEfecTelmex AS CHAR(4)) THEN monto_tot END AS totEfectivo
												FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'));
					ELIF cIdConvenio = '06001' THEN
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(cTransCargoSky AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
													CASE WHEN transacc = CAST(cTransEfecSky AS CHAR(4)) THEN monto_tot END AS totEfectivo
												FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'));

					ELIF cIdConvenio = '07001' THEN
-- MODIFICACION
						LET cReferencia1='********'||SUBSTRING (cReferencia1 FROM 9 FOR 4);
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(monto_CargoEnvioOrden), 0) + NVL(SUM(monto_CargoEnvioComision), 0) + NVL(SUM(monto_CargoEnvioIVA), 0) AS totCargo,
								NVL(SUM(monto_EfecEnvioOrden), 0) + NVL(SUM(monto_EfecEnvioComision), 0) + NVL(SUM(monto_EfecEnvioIVA), 0) AS totEfectivo
						INTO mCargoCuenta, mCargoEfectivo
						FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(ctransCargoEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioOrden,
												CASE WHEN transacc = CAST(ctransCargoEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioComision,
												CASE WHEN transacc = CAST(ctransCargoEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_CargoEnvioIVA,
												CASE WHEN transacc = CAST(ctransEfecEnvioOrden AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioOrden,
												CASE WHEN transacc = CAST(ctransEfecEnvioComision AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioComision,
												CASE WHEN transacc = CAST(ctransEfecEnvioIVA AS CHAR(4)) THEN monto_tot END AS monto_EfecEnvioIVA
											FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc AND empresa='001'));

					ELIF cIdConvenio = '07002' THEN
						LET mCargoCuenta = 0;
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM TABLE(MULTISET(SELECT monto_tot AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE transacc = ctransEfecPagoOrden
											AND folio_suc = cFolioSuc AND empresa='001'));

					ELIF cIdConvenio = '07003' THEN
						LET mCargoCuenta = 0;
						SET ISOLATION TO DIRTY READ ;
						SELECT NVL(SUM(totEfectivo), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM TABLE(MULTISET(SELECT monto_tot AS totEfectivo
											FROM bdicheq:"informix".sc_movdia
											WHERE transacc = ctransEfecCancelacionOrden
											AND folio_suc = cFolioSuc AND empresa='001'));
						END IF;
					END IF;

					LET siCiclo = siCiclo + 1;

		-- PAGINACION
					IF siCiclo <= siRegistros THEN
						CONTINUE FOREACH;
					END IF;

					RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, TRIM(cIdReferencia1), TRIM(cIdReferencia2), mCargoCuenta + mCargoCuentaCred, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo
					WITH RESUME;
				END FOREACH;
			ELSE
				RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, TRIM(cIdReferencia1), TRIM(cIdReferencia2), mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, siCiclo;
			END IF;
		END IF;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener la conciliacion por convenio y sucursales en un rango de fechas especIFicas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080906',
'BD    : bdisac',
'FECHA ULTIMA MODIFICACION: 20090123',
'AUTOR ULTIMA MODIFICACION: Jose Angel Lopez Adams',
'FECHA ULTIMA MODIFICACION: 15 Octubre 2009',
'FECHA ULTIMA MODIFICACION: 20091016',
'MODIFICACION: Se agregó en las consultas (Querys) un UNION ALL para que tambien se consulten las tablas de historial',
'              asi como tambien el manejo de la fecha de sucursal.',
'AUTOR ULTIMA MODIFICACION: Héctor Manuel Bojórquez Ruelas',
'MODIFICACION: Se modifica para agregar directivas Dirty read en las consultas',
'              asi como tambien el manejo de la fecha de sucursal.',
'AUTOR ULTIMA MODIFICACION: Héctor Manuel Bojórquez Ruelas',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Se agregan validaciones para que contemple los movimientos para ordenes de pago',
'VERSION DE CAMBIO: 20100420.1700',
'MODIFICA : Dulce Ramirez',
'DESCRIPCION: Se agregan validaciones para que contemple los movimientos para pagos de servicios sky',
'VERSION DE CAMBIO: 20100521.1618',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Junto con la integracion de Pagos MVS se integra la modificacion para los convenios en proceso automatico para su funcionamiento dinamico',
'VERSION DE CAMBIO: 20100923.1843',
'                                    ',
'MODIFICA : Martín Eduardo Miranda',
'DESCRIPCION: Se agrega nuevo retorno "cIdConvenio" para ordenar el reporte diario de Servicios por sucursal',
'VERSION DE CAMBIO: 20120830.1629',

'MODIFICA : Martha Aguirre',
'DESCRIPCION: Se agrega búsqueda de monto para el movimiento de cargo en cuenta de crédito para el cIdConvenio 8001',
'             "Pago de Servicios del Gobierno del Distrito Federal"',
'VERSION DE CAMBIO: 20130109.1030',
'',
'DESCRIPCION: Se modifica Procemiento Almacenado para agregarle nueva variable en la cual se almacena el importe de Cargo a Cuenta de',
'             las Transacciones de Crédito',
'MODIFICO: Martha Aguirre',
'FECHA: 12 de Marzo del 2013';

CREATE PROCEDURE "informix".sp_sacreportedetalletransaccionsucursal (cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE,stipo smallint)
-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno, --Codigo de Retorno
CHAR(8) AS usuario,
CHAR(16) AS folio_suc,
CHAR(40) AS nomconvenio,
CHAR(40) AS referencia1,
CHAR(40) AS referencia2,
MONEY(16,2) AS importe_pago,
MONEY(16,2) AS importe_comision_convenio,
MONEY(16,2) AS iva_comision_convenio,
MONEY(16,2) AS importe_comision_cte,
MONEY(16,2) AS iva_comision_cte,
CHAR(1) AS forma_pago,
CHAR(12) AS cuenta_cargo,
CHAR(40) AS region;


-- DEFINICION DE VARIABLES
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE cUsuario CHAR(8);
DEFINE cFolioSuc CHAR(16);
DEFINE cNumcategoria CHAR(2);
DEFINE cNumconvenio CHAR(3);
DEFINE cNomconvenio CHAR(40);
DEFINE cReferencia1 CHAR(40);
DEFINE cReferencia2 CHAR(40);
DEFINE mImpComisionConvenio MONEY(16,2);
DEFINE mIVAComisionConvenio MONEY(16,2);
DEFINE mImpComisionCte MONEY(16,2);
DEFINE mIVAComisionCte MONEY(16,2);
DEFINE mImportePago MONEY(16,2);
DEFINE cFormaPago CHAR(1);
DEFINE cCuentaCargo CHAR(12);
DEFINE cRegion CHAR(40);

--SET DEBUG FILE TO "/respaldosbb/mario/sp_sacreportedetalletransaccionsucursal.out";
--TRACE ON;


--INICIALIZACION DE VARIABLES--
LET cCodRet = "00000";
LET cUsuario = "";
LET cFolioSuc = "";
LET cNumcategoria = SUBSTRING(cConvenio FROM 1 FOR 2);
LET cNumconvenio = SUBSTRING(cConvenio FROM 3 FOR 3);
LET cNomConvenio = "";
LET cReferencia1 = "";
LET cReferencia2 = "";
LET mImportePago = 0;
LET mImpComisionConvenio = 0;
LET mIVAComisionConvenio = 0;
LET mImpComisionCte = 0;
LET mIVAComisionCte = 0;
LET cFormaPago = "";
LET cCuentaCargo = "";
LET cRegion = "";

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
        END IF;
    END EXCEPTION;

		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
        LET cCodRet = "00001";
        RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
    ELSE
        IF cConvenio = "00000" THEN   -- Todos los convenios y una sucursal
            SELECT b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
            b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre
            --INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, deImportePago, deImpComisionConvenio, deIVAComisionConvenio, deImpComisionCte, deIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
            FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d,  bdinteg:si_regional e
            WHERE b.fecha_pago::DATE  >= dFechaIni
            AND b.fecha_pago::DATE  <= dFechaFin
            AND a.numcategoria = b.numcategoria
            AND a.numconvenio = b.numconvenio
            AND b.id_sucursal = cSucursal
            AND b.status_cancelado <> 'S'
            AND flag_confirmacion_central = 1
            AND flag_confirmacion_sucursal = 1
            AND c.sucursal = b.id_sucursal
            AND d.plaza = c.plaza
            AND e.regional = d.regional
            INTO TEMP tmp_movs WITH NO LOG;
            --ORDER BY 3, 2 ASC
            FOREACH
                SELECT usuario, folio_suc, nomconvenio, referencia1, referencia2, importe_pago, importe_comision_convenio, iva_comision_convenio,
                    importe_comision_cte, iva_comision_cte, forma_pago, cuenta_cargo, nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:tmp_movs ORDER BY folio_suc, nomconvenio

                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;
            DROP TABLE bdisac:tmp_movs;
        ELSE   --Un convenio y una sucursal
            FOREACH
                SELECT b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
                b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
                WHERE b.fecha_pago::DATE >= dFechaIni
                AND b.fecha_pago::DATE  <= dFechaFin
                AND b.numcategoria = cNumcategoria
                AND b.numconvenio = cNumconvenio
                AND a.numcategoria = b.numcategoria
                AND a.numconvenio = b.numconvenio
                AND b.id_sucursal = cSucursal
                AND b.status_cancelado <> 'S'
            AND flag_confirmacion_central = 1
            AND flag_confirmacion_sucursal = 1
                AND c.sucursal = b.id_sucursal
                AND d.plaza = c.plaza
                AND e.regional = d.regional

                ORDER BY 3  ASC
                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;
        END IF;
    END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener la conciliacion por convenio y sucursales en un rango de fechas especificas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080906',
'-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Folio:1570',
'Autor:95142134 Mario Gallardo',
'Fecha:24/01/2014',
'Modificación: Se modifica referencia1 y referencia2 a 40 carcateres.',
'Sustento: RQI 62 064-Reingeniería_PagoServicios -  (Pagina 2 a 36)',
'Solicita: Jaime Gonzalez',
'BD: bdisac',
'-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_select
(
pEmpresa					CHAR(3),
pUsuario					CHAR(8),
pMarca                      CHAR(2),
pForeign_Rs_Fefnum_Rq		CHAR(16),
pMoney_Transfer_Key_Rq		CHAR(10),
pFecha_Hora_Rq	 			DATETIME YEAR TO SECOND,
pRetCode					CHAR(5),
pEmisor_NameType			CHAR(1),
pEmisor_Nombre1				CHAR(40),
pEmisor_Appaterno			CHAR(40),
pEmisor_Dirreccion			CHAR(40),
pEmisor_Ciudad				CHAR(20),
pEmisor_Edo					CHAR(3),
pEmisor_Cp					CHAR(10),
pEmisor_Calle				CHAR(40),
pEmisor_Cod_Pais			CHAR(3),
pEmisor_Cod_Moneda			CHAR(3),
pEmisor_Email				CHAR(40),
pEmisor_Elef_Part			CHAR(15),
pBenef_NameType				CHAR(1),
pBenef_Nombre1				CHAR(40),
pBenef_Nombre2				CHAR(40),
pBenef_Appaterno			CHAR(40),
pBenef_Apmaterno			CHAR(40),
pBenef_Cod_Pais				CHAR(3),
pBenef_Cod_Moneda			CHAR(3),
pBenef_Impuestos_Locales	CHAR(6),
pBenef_Impuestos_Estatales	CHAR(6),
pBenef_Impuestos_Federales	CHAR(6),
pMonto_Origen				CHAR(10),
pMonto_Total_Destino		CHAR(10),
pMonto_Total_Origen			CHAR(10),
pMonto_Cargos_Origen		CHAR(10),
pCiudad_Origen				CHAR(20),
pEstado_Origen				CHAR(3),
pTipo_Transaccion			CHAR(4),
pTasa_Cambio				CHAR(10),
pFecha_Alta_Remesa			CHAR(8),
pHora_Alta_Remesa			CHAR(16),
pMoney_Transfer_Key_Rp		CHAR(10),
pPay_Status_Description		CHAR(4),
pMtcn						CHAR(10),
pNew_Mtcn					CHAR(16),
pEmisor_Mensaje				CHAR(80),
pForeign_Rs_System_Id_Rp	CHAR(11),
pForeign_Rs_Refnum_Rp		CHAR(16),
pForeign_Rs_Cntid_Rp		CHAR(11),
pDesc_Error					CHAR(250),
pPartnerid_Err				CHAR(10),
pFecha_Hora_Rp				DATETIME YEAR TO SECOND,
pUser_Insert				CHAR(8),
pFecha_Insert				DATETIME YEAR TO SECOND
)

RETURNING CHAR(5) AS cod_err, CHAR(30) AS error_desc;

--DEFINICION DE VARIABLES--
    DEFINE	iSql_Err		INTEGER;
	DEFINE 	iIsamErr		INTEGER;
    DEFINE	cCodRet			CHAR(5);
	DEFINE  cRetCode		CHAR(5);
	DEFINE  cDesc_Error     CHAR(250);
	DEFINE	cCodRetAux		CHAR(5);
	DEFINE	cTxnStatus		CHAR(1);
	DEFINE	cNombreSP		CHAR(45);
	DEFINE 	cCadena_ent		CHAR(100);
	DEFINE cError_Desc     	CHAR(30);
	DEFINE cFechaProceso    DATETIME YEAR TO SECOND;
	DEFINE cChannelType 	CHAR(3);
    DEFINE cChannelName 	CHAR(3); 
    DEFINE cChannelVersion	CHAR(4);  
    DEFINE cForeignSystemid	CHAR(11); 
	DEFINE cForeignRsCntRq  CHAR(11);
	DEFINE cSucursal		CHAR(4);

	
--INICIALIZACION DE VARIABLES--
    LET	iSql_Err		= 0;
	LET	iIsamErr 		= 0;
    LET cCodRet			= '00000';
	LET cRetCode		= '00000';
	LET cDesc_Error     = "";
	LET cCodRetAux		= '00000';
	LET cTxnStatus		= 'C';
	LET	cNombreSP		= 'sp_sac_wu_guardarespuesta_select';
	LET cCadena_ent		= ""; 
	LET cError_Desc 	="Error en el proceso";
	LET cFechaProceso	= CURRENT::DATETIME YEAR TO SECOND;
    LET cChannelType 	 ="";	
    LET cChannelName 	 ="";	 
    LET cChannelVersion	 ="";  
    LET cForeignSystemid =""; 
	LET cForeignRsCntRq  ="";
	LET cSucursal 			="";


BEGIN
	ON EXCEPTION SET iSql_Err, iIsamErr
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
				INTO cCodRetAux;
				
				IF cCodRetAux <> '00000' THEN
			       LET cCodRet = cCodRetAux;
		        END IF
				
			INSERT INTO bdisac:"informix".sac_wu_select	 
						(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,money_transfer_key_rq,
						 fecha_hora_rq,retcode,emisor_nametype,emisor_nombre1,emisor_appaterno,emisor_dirreccion,emisor_ciudad,emisor_edo,emisor_cp,emisor_calle,
						 emisor_cod_pais,emisor_cod_moneda,emisor_email,emisor_telef_part,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,
						 benef_cod_pais,benef_cod_moneda,benef_impuestos_locales,benef_impuestos_estatales,benef_impuestos_federales,monto_origen,monto_total_destino,
						 monto_total_origen,monto_cargos_origen,ciudad_origen,estado_origen,tipo_transaccion,tasa_cambio,fecha_alta_remesa,hora_alta_remesa,
						 money_transfer_key_rp,pay_status_description,mtcn,new_mtcn,emisor_mensaje,foreign_rs_system_id_rp,foreign_rs_refnum_rp,foreign_rs_cntid_rp,
						 desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert)
						
				  VALUES(cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignSystemid,pForeign_Rs_Fefnum_Rq,cForeignRsCntRq,pMoney_Transfer_Key_Rq,
				         pFecha_Hora_Rq,pRetCode,pEmisor_NameType,pEmisor_Nombre1,pEmisor_Appaterno,pEmisor_Dirreccion,pEmisor_Ciudad,pEmisor_Edo,pEmisor_Cp,pEmisor_Calle,
						 pEmisor_Cod_Pais,pEmisor_Cod_Moneda,pEmisor_Email,pEmisor_Elef_Part,pBenef_NameType,pBenef_Nombre1,pBenef_Nombre2,pBenef_Appaterno,pBenef_Apmaterno,
						 pBenef_Cod_Pais,pBenef_Cod_Moneda,pBenef_Impuestos_Locales,pBenef_Impuestos_Estatales,pBenef_Impuestos_Federales,pMonto_Origen,pMonto_Total_Destino,
						 pMonto_Total_Origen,pMonto_Cargos_Origen,pCiudad_Origen,pEstado_Origen,pTipo_Transaccion,pTasa_Cambio,pFecha_Alta_Remesa,pHora_Alta_Remesa,pMoney_Transfer_Key_Rp,
						 pPay_Status_Description,pMtcn,pNew_Mtcn,pEmisor_Mensaje,pForeign_Rs_System_Id_Rp,pForeign_Rs_Refnum_Rp,pForeign_Rs_Cntid_Rp,pDesc_Error,pPartnerid_Err,
						 pFecha_Hora_Rp,pUser_Insert,current);
--	2014.07.30-FRG.i
						 --	pFecha_Insert);
--	2014.07.30-FRG.f
			
			RETURN cCodRet,cError_Desc;
        END IF;
		
		
    END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_select.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
		
	EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (2,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso)  
	INTO cCodRetAux;
	
	IF cCodRetAux <> '00000' OR pRetCode <> '00000' THEN
		LET	cTxnStatus	= 'C';
		LET cCodRet = '00001';

	ELSE
		LET	cTxnStatus	= 'A';
	END IF
	
	IF pRetCode = '504' THEN
	    LET cRetCode = '99999';
		LET pDesc_Error = 'Aplicativo WU no activo, validar';
		
	END  IF;
	IF pRetCode <>  '504' AND pRetCode <> '00000' AND pRetCode <> '66666'  THEN		
		LET cRetCode = '99998';
		LET pDesc_Error = 'Sin respuesta del aplicativo, validar';
	END IF
	IF pRetCode = '66666' THEN
		LET cDesc_Error = pDesc_Error;
		LET cRetCode = pRetCode;
	END IF
	
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
		IF (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87054') = pMarca
		OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87055') = pMarca
		OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87056') = pMarca THEN
				IF pUsuario = "sys_wu" THEN
					LET cSucursal = '9250';
				ELSE
					SELECT sucursal
						INTO cSucursal
						FROM bdinteg:"informix".si_ejecut
						WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
				END IF;
				IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN

					SELECT fsid ,counter_id
					INTO cForeignSystemId ,cForeignRsCntRq
					FROM bdisac:"informix".sac_wu_identificadores
					WHERE marca = pMarca AND sucursal = cSucursal AND empresa = pEmpresa;

					IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
						LET cCodRet = '00027';
						LET cError_Desc	= 'Usuario no tiene Id. Asignado';
					END IF;
				ELSE
					LET	cCodRet = '00026'; --- Usuario no se encuentra
					LET cError_Desc	= 'NO EXISTE USUARIO';
			   END IF;
		ELSE
			LET	cCodRet = '00003'; --- Marca Inválida
			LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';
		END IF;
  

			SELECT valor
			INTO cChannelType
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87050';  
			 
			SELECT valor
			INTO cChannelName
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87051'; 
			 
			SELECT valor
			INTO cChannelVersion
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87052'; 
																	
				
	
    LET cCadena_ent = TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(cForeignSystemid,'NULL'))||'|'||TRIM(NVL(pMoney_Transfer_Key_Rq,'NULL'));
	
	INSERT INTO bdisac:"informix".sac_wu_select	
						(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,money_transfer_key_rq,
						 fecha_hora_rq,retcode,emisor_nametype,emisor_nombre1,emisor_appaterno,emisor_dirreccion,emisor_ciudad,emisor_edo,emisor_cp,emisor_calle,
						 emisor_cod_pais,emisor_cod_moneda,emisor_email,emisor_telef_part,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,
						 benef_cod_pais,benef_cod_moneda,benef_impuestos_locales,benef_impuestos_estatales,benef_impuestos_federales,monto_origen,monto_total_destino,
						 monto_total_origen,monto_cargos_origen,ciudad_origen,estado_origen,tipo_transaccion,tasa_cambio,fecha_alta_remesa,hora_alta_remesa,
						 money_transfer_key_rp,pay_status_description,mtcn,new_mtcn,emisor_mensaje,foreign_rs_system_id_rp,foreign_rs_refnum_rp,foreign_rs_cntid_rp,
						 desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert)
						
				  VALUES(cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignSystemid,pForeign_Rs_Fefnum_Rq,cForeignRsCntRq,pMoney_Transfer_Key_Rq,
				         pFecha_Hora_Rq,cRetCode,pEmisor_NameType,pEmisor_Nombre1,pEmisor_Appaterno,pEmisor_Dirreccion,pEmisor_Ciudad,pEmisor_Edo,pEmisor_Cp,pEmisor_Calle,
						 pEmisor_Cod_Pais,pEmisor_Cod_Moneda,pEmisor_Email,pEmisor_Elef_Part,pBenef_NameType,pBenef_Nombre1,pBenef_Nombre2,pBenef_Appaterno,pBenef_Apmaterno,
						 pBenef_Cod_Pais,pBenef_Cod_Moneda,pBenef_Impuestos_Locales,pBenef_Impuestos_Estatales,pBenef_Impuestos_Federales,pMonto_Origen,pMonto_Total_Destino,
						 pMonto_Total_Origen,pMonto_Cargos_Origen,pCiudad_Origen,pEstado_Origen,pTipo_Transaccion,pTasa_Cambio,pFecha_Alta_Remesa,pHora_Alta_Remesa,pMoney_Transfer_Key_Rp,
						 pPay_Status_Description,pMtcn,pNew_Mtcn,pEmisor_Mensaje,pForeign_Rs_System_Id_Rp,pForeign_Rs_Refnum_Rp,pForeign_Rs_Cntid_Rp,pDesc_Error,pPartnerid_Err,
						 pFecha_Hora_Rp,pUser_Insert,current);
--	2014.07.30-FRG.i
						 --	pFecha_Insert);
--	2014.07.30-FRG.f
			
	
		IF  cCodRet <> '00000' THEN
	
		    EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,cDesc_Error,iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
		    INTO cCodRetAux;
			
			IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
				RETURN cCodRet,cError_Desc;	
			END IF;
			
			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;	
			ELSE 
				LET cCodRet = '00001';
			END IF
			  
            RETURN cCodRet,cError_Desc;		
	    ELSE	
		    EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (3,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
	        INTO cCodRetAux;	
			
			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
			
			IF cCodRet = '00000' THEN
				LET cError_Desc = "Ejecucion SP exitosa";
			END IF;	
			
           RETURN cCodRet,cError_Desc;
	    END IF;	
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje  <receive-money-select> (request-reply) en la tabla bdisac:sac_wu_select',  
'AUTOR: Christian Echavarria',			
'FECHA: 16/Jul/2013',
'DESCRIPCION: Se modifica para que consulte los campos counter_id y  fsid de sac_wu_identificadores',  
'AUTOR: Mario Gallardo',			
'FECHA: 03/10/2013',
'DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
'AUTOR: FRG',
'FECHA: 30/Jul/2014',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_paystatus
(
pEmpresa					CHAR(3),
pUsuario					CHAR(8),
pChannel_Type				CHAR(3),
pChannel_Name	            CHAR(3),
pChannel_Version 			CHAR(4),
pMtcn						CHAR(10),
pForeign_Rs_System_Id_Rq 	CHAR(11),
pForeign_Rs_Fefnum_Rq		CHAR(16),
pForeign_Rs_Cntid_Rq		CHAR(11),
pFecha_Hora_Rq	 			DATETIME YEAR TO SECOND,
pRetCode					CHAR(5),
pEmisor_NameType			CHAR(1),
pEmisor_Nombre1				CHAR(40),
pEmisor_Appaterno			CHAR(40),
pEmisor_Apmaterno			CHAR(40),
pBenef_NameType				CHAR(1),
pBenef_Nombre1				CHAR(40),
pBenef_Nombre2				CHAR(40),
pBenef_Appaterno			CHAR(40),
pBenef_Apmaterno			CHAR(40),
pBenefMontoDestino			CHAR(10),
pBenef_Cod_Pais				CHAR(3),
pBenef_Cod_Moneda			CHAR(3),
pFecha_Registro_Wu			CHAR(8),
pHora_Registro_Wu			CHAR(8),
pMoney_Transfer_Key			CHAR(10),
pEstatus_Pago				CHAR(4),
pForeign_Rs_System_Id_Rp	CHAR(11),
pForeign_Rs_Refnum_Rp		CHAR(16),
pForeign_Rs_Cntid_Rp		CHAR(11),
pNum_Coincidencias			CHAR(2),
pPagina_Actual				CHAR(2),
pUltima_Pagina				CHAR(2),
pDesc_Error					CHAR(250),
pPartnerid_Err				CHAR(10),
pFecha_Hora_Rp				DATETIME YEAR TO SECOND,
pUser_Insert				CHAR(8),
pFecha_Insert				DATETIME YEAR TO SECOND
)

RETURNING CHAR(5) AS cod_err, CHAR(30) AS error_desc;

--DEFINICION DE VARIABLES--
    DEFINE	iSql_Err	INTEGER;
	DEFINE 	iIsamErr	INTEGER;
    DEFINE	cCodRet		CHAR(5);
	DEFINE	cCodRetAux	CHAR(5);
	DEFINE	cTxnStatus	CHAR(1);
	DEFINE	cNombreSP	CHAR(45); 
	DEFINE 	cCadena_ent	CHAR(100);
	DEFINE cError_Desc  CHAR(30);
	DEFINE cFechaProceso    DATETIME YEAR TO SECOND;
	
--INICIALIZACION DE VARIABLES--
    LET	iSql_Err	= 0;
	LET	iIsamErr 	= 0;
    LET cCodRet		= '00000';
	LET cCodRetAux	= '00000';
	LET cTxnStatus	= 'C';
	LET	cNombreSP	= 'sp_sac_wu_guardarespuesta_paystatus';
	LET cCadena_ent	=  TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pMtcn,'NULL'))||'|'||TRIM(NVL(pForeign_Rs_System_Id_Rq,'NULL'));
	LET cError_Desc ="Error en el proceso";
	LET cFechaProceso	= CURRENT::DATETIME YEAR TO SECOND;


BEGIN
	ON EXCEPTION SET iSql_Err, iIsamErr
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
			INSERT INTO bdisac:"informix".sac_wu_pay_status	 
						(txn_status,channel_type,channel_name,channel_version,mtcn,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,fecha_hora_rq,retcode,
						 emisor_nametype,emisor_nombre1,emisor_appaterno,emisor_apmaterno,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,monto_destino,
						 benef_cod_pais,benef_cod_moneda,fecha_registro_wu,hora_registro_wu,money_transfer_key,estatus_pago,foreign_rs_system_id_rp,foreign_rs_refnum_rp,
						 foreign_rs_cntid_rp,num_coincidencias,pagina_actual,ultima_pagina,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert)
						
				  VALUES(cTxnStatus,pChannel_Type,pChannel_Name,pChannel_Version,pMtcn,pForeign_Rs_System_Id_Rq,pForeign_Rs_Fefnum_Rq,pForeign_Rs_Cntid_Rq,
				         pFecha_Hora_Rq,pRetCode,pEmisor_NameType,pEmisor_Nombre1,pEmisor_Appaterno,pEmisor_Apmaterno,pBenef_NameType,pBenef_Nombre1,pBenef_Nombre2,
						 pBenef_Appaterno,pBenef_Apmaterno,pBenefMontoDestino,pBenef_Cod_Pais,pBenef_Cod_Moneda,pFecha_Registro_Wu,pHora_Registro_Wu,pMoney_Transfer_Key,
						 pEstatus_Pago,pForeign_Rs_System_Id_Rp,pForeign_Rs_Refnum_Rp,pForeign_Rs_Cntid_Rp,pNum_Coincidencias,pPagina_Actual,pUltima_Pagina,pDesc_Error,
						 pPartnerid_Err,pFecha_Hora_Rp,pUser_Insert,current);
--	2014.07.30-FRG.i
						 --	pFecha_Insert);
--	2014.07.30-FRG.f
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
			INTO cCodRetAux;
			
			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
			
			RETURN cCodRet,cError_Desc;
        END IF;
		
		
    END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_paystatus.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
		
	EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (2,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso)  
	INTO cCodRetAux;
	
	IF cCodRetAux <> '00000' OR pRetCode <> '00000' THEN
		LET	cTxnStatus	= 'C';
		LET cCodRet = '00001';
		
	ELSE
		LET	cTxnStatus	= 'A';
	END IF
	
	
	INSERT INTO bdisac:"informix".sac_wu_pay_status	
						(txn_status,channel_type,channel_name,channel_version,mtcn,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,fecha_hora_rq,retcode,
						 emisor_nametype,emisor_nombre1,emisor_appaterno,emisor_apmaterno,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,monto_destino,
						 benef_cod_pais,benef_cod_moneda,fecha_registro_wu,hora_registro_wu,money_transfer_key,estatus_pago,foreign_rs_system_id_rp,foreign_rs_refnum_rp,
						 foreign_rs_cntid_rp,num_coincidencias,pagina_actual,ultima_pagina,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert)
						
				  VALUES(cTxnStatus,pChannel_Type,pChannel_Name,pChannel_Version,pMtcn,pForeign_Rs_System_Id_Rq,pForeign_Rs_Fefnum_Rq,pForeign_Rs_Cntid_Rq,
				         pFecha_Hora_Rq,pRetCode,pEmisor_NameType,pEmisor_Nombre1,pEmisor_Appaterno,pEmisor_Apmaterno,pBenef_NameType,pBenef_Nombre1,pBenef_Nombre2,
						 pBenef_Appaterno,pBenef_Apmaterno,pBenefMontoDestino,pBenef_Cod_Pais,pBenef_Cod_Moneda,pFecha_Registro_Wu,pHora_Registro_Wu,pMoney_Transfer_Key,
						 pEstatus_Pago,pForeign_Rs_System_Id_Rp,pForeign_Rs_Refnum_Rp,pForeign_Rs_Cntid_Rp,pNum_Coincidencias,pPagina_Actual,pUltima_Pagina,pDesc_Error,
						 pPartnerid_Err,pFecha_Hora_Rp,pUser_Insert,current);
--	2014.07.30-FRG.i
						 --	pFecha_Insert);
--	2014.07.30-FRG.f
					   
		IF  cCodRet <> '00000' THEN
	
		    EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
		    INTO cCodRetAux;
			
			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
			  
            RETURN cCodRet,cError_Desc;		
	    ELSE	
		    EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (3,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
	        INTO cCodRetAux;	
			
			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
			
			IF cCodRet = '00000' THEN
				LET cError_Desc = "Ejecucion SP exitosa";
			END IF;	
			
           RETURN cCodRet,cError_Desc;
	    END IF;	
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje <pay-status> (request-reply) en la tabla bdisac:sac_wu_pay_status',  
'AUTOR: Christian Echavarria',			
'FECHA: 18/Jul/2013',
'DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
'AUTOR: FRG',
'FECHA: 30/Jul/2014',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_catmensajeserror
(
pEmpresa 					CHAR(3),
pUsuario 					CHAR(8),
pChannel_type				CHAR(3),
pChannel_name				CHAR(3),
pChannel_version			CHAR(4),
pForeign_rs_system_id_rq	CHAR(11),
pForeign_rs_refnum_rq		CHAR(16),
pForeign_rs_cntid_rq		CHAR(11),
pName_rq					CHAR(30),
pQueryfilter1				CHAR(2),
pQueryfilter2				CHAR(5),
pFecha_hora_rq				DATETIME YEAR TO FRACTION(5),
pRetcode					CHAR(5),
pAccount_num				CHAR(10),
pData_more					CHAR(1),
pData_num_recs				CHAR(3),
pName_rp					CHAR(30),
pFsid						CHAR(11),
pCounter_id					CHAR(11),
pTerm_id					CHAR(6),
pError_desc					CHAR(80),
pError_code					CHAR(5),
pFun_code					CHAR(5),
pGrupo						CHAR(1),
pDesc_error					CHAR(250),
pPartnerid_err				CHAR(10),
pFecha_hora_rp				DATETIME YEAR TO FRACTION(5),
pUser_insert				CHAR(8),
pFecha_insert				DATETIME YEAR TO FRACTION(5)
)
RETURNING   CHAR (5) AS cod_err,CHAR (30) AS error_desc;

DEFINE iSqlErr 			INTEGER;
DEFINE cRetcode 		CHAR(5);
DEFINE cCodRetAux       CHAR(5);
DEFINE cDescripcion 	CHAR (100);
DEFINE ctxn_status 		CHAR (1);
DEFINE cCadena_ent    	CHAR(100);
DEFINE i_Sam_err		INTEGER;
DEFINE cProceso 		CHAR (45);
DEFINE cStatus 			CHAR(1);
DEFINE cRutaServer 		CHAR (40);
DEFINE cSql 			CHAR(600);
DEFINE cNombreArchivo 	CHAR(35);
DEFINE cMes, cDia  		CHAR(2);
DEFINE cAnio 			CHAR (2);
DEFINE cTabla  			CHAR (25);
DEFINE cMarcaVG  		CHAR (11);
DEFINE cMarcaOV  		CHAR (11);
DEFINE cFechaProceso    DATETIME YEAR TO SECOND;

LET iSqlErr = 0;
LET cRetcode = '00000';
LET cCodRetAux = '00000';
LET cDescripcion = 'Error en el proceso';
LET ctxn_status = 'C';
LET i_Sam_err           = 0;
LET cProceso = 'sp_sac_wu_guardarespuesta_catmensajeserror';
LET cStatus = '2';
LET  cCadena_ent = TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pForeign_rs_system_id_rq,'NULL'))||'|'||TRIM(NVL(pName_rq,'NULL'));
LET cRutaServer = '';
LET cSql = '';
LET cNombreArchivo ='';
LET cMes='' ;
LET cDia = ''  ; 
LET cAnio ='';
LET cTabla  ='';
LET cMarcaVG  ='';
LET cMarcaOV  ='';
LET cFechaProceso = CURRENT::DATETIME YEAR TO SECOND;

BEGIN
	ON EXCEPTION SET iSqlErr,i_Sam_err,cDescripcion
		IF iSqlErr <> 0 THEN			
			LET cStatus ='1';
		   
			INSERT INTO bdisac:"informix".sac_wu_catmensajes(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,name_rq,queryfilter1,queryfilter2,fecha_hora_rq,retcode,account_num,data_more,data_num_recs,name_rp,fsid,counter_id,term_id,error_desc,error_code,fun_code,grupo,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert) 
			VALUES  (ctxn_status,pChannel_type,pChannel_name,pChannel_version,pForeign_rs_system_id_rq,pForeign_rs_refnum_rq,pForeign_rs_cntid_rq,pName_rq,pQueryfilter1,pQueryfilter2,pFecha_hora_rq,pRetcode,pAccount_num,pData_more,pData_num_recs,pName_rp,pFsid,pCounter_id,pTerm_id,pError_desc,pError_code,pFun_code,pGrupo,pDesc_error,pPartnerid_err,pFecha_hora_rp,pUser_insert,current);
--	2014.07.30-FRG.i
			--	pFecha_insert);
--	2014.07.30-FRG.f

		   EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cRetcode,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) INTO cRetcode;
		   RETURN iSqlErr, cDescripcion; 
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_wu_guardarespuesta_catmensajeserror.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
EXECUTE PROCEDURE	 bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cRetcode,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) INTO cRetcode;


SELECT valor INTO cRutaServer FROM bdisac:"informix".sac_param  WHERE cod_param = 3;	
LET cMes  =  LPAD(MONTH(CURRENT::DATE), 2, '0');
LET cDia   =  LPAD(DAY(CURRENT::DATE), 2, '0') ; 
LET cAnio = TRIM(SUBSTR(LPAD(YEAR(CURRENT::DATE), 4, '0'),3));
LET  cNombreArchivo = 'sac_wu_catmensajes'||'_'||cDia||cMes||cAnio||'.'; 

IF pRetcode = '00000' THEN
	LET ctxn_status =	'A';
	LET cStatus= '3';
	
ELSE
     LET cStatus= '1';
	 LET cRetcode = '00001';
END IF;
            INSERT INTO bdisac:"informix".sac_wu_catmensajes(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,name_rq,queryfilter1,queryfilter2,fecha_hora_rq,retcode,account_num,data_more,data_num_recs,name_rp,fsid,counter_id,term_id,error_desc,error_code,fun_code,grupo,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert) 
			VALUES  (ctxn_status,pChannel_type,pChannel_name,pChannel_version,pForeign_rs_system_id_rq,pForeign_rs_refnum_rq,pForeign_rs_cntid_rq,pName_rq,pQueryfilter1,pQueryfilter2,pFecha_hora_rq,pRetcode,pAccount_num,pData_more,pData_num_recs,pName_rp,pFsid,pCounter_id,pTerm_id,pError_desc,pError_code,pFun_code,pGrupo,pDesc_error,pPartnerid_err,pFecha_hora_rp,pUser_insert,current);
--	2014.07.30-FRG.i
			--	pFecha_insert);
--	2014.07.30-FRG.f

    IF  cRetcode <> '00000' THEN
	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cRetcode,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
        INTO cCodRetAux;
		IF cCodRetAux <> '00000' THEN
			LET cRetcode = cCodRetAux;
		END IF
		  
		RETURN  cRetcode, cDescripcion;
	ELSE	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
		INTO cCodRetAux;	
		
		IF cCodRetAux <> '00000' THEN
			LET cRetcode = cCodRetAux;
		END IF
		
		IF cRetcode = '00000' THEN
			LET cDescripcion = "Ejecucion SP exitosa";
		END IF;	
	END IF;
RETURN  cRetcode, cDescripcion;	

END;
END PROCEDURE

DOCUMENT
' DESCRIPCION: se crea SP  para guardar los campos del mensaje <h2h-das> referente al mensaje DAS GetErrorMessagesInfo (request-reply) en la tabla bdisac:sac_wu_catmensajes' ,  
' MODIFICO : Christian Echavarria',			
' FECHA : 2013/07/25',
' DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',
' MODIFICO : FRG',
' FECHA : 2014/07/30',
'BD: bdisac ';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_catisopaises
	(
	pEmpresa 					CHAR(3),
	pUsuario 					CHAR(8),
	pChannel_type 				CHAR(3),
	pChannel_name 				CHAR(3),
	pChannel_version 			CHAR(4),
	pForeign_rs_system_id_rq 	CHAR(11),
	pForeign_rs_refnum_rq 		CHAR(16),
	pForeign_rs_cntid_rq 		CHAR(11),
	pName_rq 					CHAR(30),
	pQueryfilter1 				CHAR(2),
	pQueryfilter3 				CHAR(45),
	pFecha_hora_rq 				DATETIME YEAR TO FRACTION(5),
	pRet_code 				    CHAR(5),
	pAccount_num 				CHAR(10),
	pData_more 					CHAR(1),
	pData_num_recs 				CHAR(3),
	pName_rp 					CHAR(30),
	pFsid 						CHAR(11),
	pCounter_id 				CHAR(11),
	pTerm_id 					CHAR(6),
	pIso_country_cd 			CHAR(3),
	pCountry_long 				CHAR(45),
	pDesc_error 				CHAR(250),
	pPartnerid_err 				CHAR(10),
	pFecha_hora_rp 				DATETIME YEAR TO FRACTION(5),
	pUser_insert 				CHAR(8),
	pFecha_insert 				DATETIME YEAR TO FRACTION(5)
	)
	RETURNING   CHAR (5) AS cod_err,CHAR (30) AS error_desc;

	DEFINE iSqlErr 			INTEGER;
	DEFINE cCod_err 		CHAR(5);
	DEFINE cCodRetAux       CHAR(5);
	DEFINE cDescripcion 	CHAR (100);
	DEFINE ctxn_status 		CHAR (1);
	DEFINE cCadena_ent    	CHAR(100);
	DEFINE i_Sam_err		INTEGER;
	DEFINE cProceso 		CHAR (45); 
	DEFINE cStatus 			CHAR(1);
	DEFINE cRutaServer 		CHAR (40);
	DEFINE cSql 			CHAR(600);
	DEFINE cNombreArchivo 	CHAR(35);
	DEFINE cMes, cDia  		CHAR(2);
	DEFINE cAnio 			CHAR (2);
	DEFINE cTabla  			CHAR (25);
	DEFINE cMarcaVG  		CHAR (11);
	DEFINE cMarcaOV  		CHAR (11);
	DEFINE cPais			CHAR (45);
	DEFINE cFechaProceso    DATETIME YEAR TO SECOND;
    DEFINE cContador        SMALLINT;
    DEFINE cContador2       SMALLINT;

	LET iSqlErr = 0;
	LET cCod_err = '00000';
	LET cCodRetAux = '00000';
	LET cDescripcion = 'Error en el proceso';
	LET ctxn_status = 'C';
	LET i_Sam_err           = 0;
	LET cProceso = 'sp_sac_wu_guardarespuesta_catisopaises';
	LET cStatus = '2';
	LET  cCadena_ent = TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pForeign_rs_system_id_rq,'NULL'))||'|'||TRIM(NVL(pName_rq,'NULL'));	
	LET cRutaServer = '';
	LET cSql = '';
	LET cNombreArchivo ='';
	LET cMes='' ;
	LET cDia = ''  ; 
	LET cAnio ='';
	LET cTabla  ='';
	LET cMarcaVG  ='';
	LET cMarcaOV  ='';
	LET cFechaProceso = CURRENT::DATETIME YEAR TO SECOND;
    LET cContador = 1;
    LET cContador2 = 2;

	BEGIN
		ON EXCEPTION SET iSqlErr,i_Sam_err,cDescripcion
			IF iSqlErr <> 0 THEN			
				LET cStatus ='1';
			   
				INSERT INTO bdisac:"informix".sac_wu_isopaises(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,name_rq,queryfilter1,queryfilter3,fecha_hora_rq,retcode,account_num,data_more,data_num_recs,name_rp,fsid,counter_id,term_id,iso_country_cd,country_long,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert) 
				VALUES  (ctxn_status,pChannel_type,pChannel_name,pChannel_version,pForeign_rs_system_id_rq,pForeign_rs_refnum_rq,pForeign_rs_cntid_rq,pName_rq,pQueryfilter1,pQueryfilter3,pFecha_hora_rq,pRet_code,pAccount_num,pData_more,pData_num_recs,pName_rp,pFsid,pCounter_id,pTerm_id,pIso_country_cd,pCountry_long,pDesc_error,pPartnerid_err,pFecha_hora_rp,pUser_insert,current);
--	2014.07.30-FRG.i
				--	pFecha_insert);
--	2014.07.30-FRG.f

			   EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCod_err,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) INTO cCod_err;
			  RETURN iSqlErr, cDescripcion; 
		   END IF;
		END EXCEPTION;

--		SET DEBUG FILE TO '/tmp/WU/sp_sac_wu_guardarespuesta_catisopaises.out';
--		TRACE ON;	
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
	EXECUTE PROCEDURE	 bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCod_err,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) INTO cCod_err;

	SELECT valor INTO cRutaServer FROM bdisac:"informix".sac_param  WHERE cod_param = 3;	
	LET cMes  =  LPAD(MONTH(CURRENT::DATE), 2, '0');
	LET cDia   =  LPAD(DAY(CURRENT::DATE), 2, '0') ; 
	LET cAnio = TRIM(SUBSTR(LPAD(YEAR(CURRENT::DATE), 4, '0'),3));
	LET  cNombreArchivo = 'sac_wu_isopaises'||'_'||cDia||cMes||cAnio||'.'; 

	LET cPais = pCountry_long;

              FOR cContador = 1 TO  cContador2
                    IF  cPais matches ('*\u00E1*') THEN
                        LET cPais = REPLACE(cPais,'\u00E1','a');
                    ELIF  cPais matches ('*\u00E9*') THEN
                        LET cPais = REPLACE(cPais,'\u00E9','e');
                    ELIF cPais matches ('*\u00ED*') THEN
                        LET cPais = REPLACE(cPais,'\u00ED','i');
                    ELIF  cPais matches ('*\u00F3*') THEN
                        LET cPais = REPLACE(cPais,'\u00F3','o');
                    ELIF cPais matches ('*\u00FA*') THEN
                        LET cPais = REPLACE(cPais,'\u00FA','u');
                    ELIF cPais matches ('*\u00F1*') THEN
                        LET cPais = REPLACE(cPais,'\u00F1','ñ');
                    ELIF cPais matches ('*\u00C1*') THEN
                        LET cPais = REPLACE(cPais,'\u00C1','A');
                    ELIF cPais matches ('*\u00E *') THEN
                        LET cPais = REPLACE(cPais,'\u00E ','a');                       
                    ELSE 
                       EXIT FOR;
                    END IF;                  
              END FOR; 


	IF pRet_code = '00000' THEN
		LET ctxn_status =	'A';
		LET cStatus= '3';
		
	ELSE
		 LET cStatus= '1';	
		 LET cCod_err = '00001'; 	 
	END IF;

		INSERT INTO bdisac:"informix".sac_wu_isopaises(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,name_rq,queryfilter1,queryfilter3,fecha_hora_rq,retcode,account_num,data_more,data_num_recs,name_rp,fsid,counter_id,term_id,iso_country_cd,country_long,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert) 
		VALUES  (ctxn_status,pChannel_type,pChannel_name,pChannel_version,pForeign_rs_system_id_rq,pForeign_rs_refnum_rq,pForeign_rs_cntid_rq,pName_rq,pQueryfilter1,pQueryfilter3,pFecha_hora_rq,pRet_code,pAccount_num,pData_more,pData_num_recs,pName_rp,pFsid,pCounter_id,pTerm_id,pIso_country_cd,cPais,pDesc_error,pPartnerid_err,pFecha_hora_rp,pUser_insert,current);
--	2014.07.30-FRG.i
				--	pFecha_insert);
--	2014.07.30-FRG.f

		IF  cCod_err <> '00000' THEN
		
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCod_err,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
			INTO cCodRetAux;
			IF cCodRetAux <> '00000' THEN
				LET cCod_err = cCodRetAux;
			END IF
			  
			RETURN  cCod_err, cDescripcion;
		ELSE	
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
			INTO cCodRetAux;	
			
			IF cCodRetAux <> '00000' THEN
				LET cCod_err = cCodRetAux;
			END IF
			
			IF cCod_err = '00000' THEN
				LET cDescripcion = "Ejecucion SP exitosa";
			END IF;	
		END IF;
	RETURN  cCod_err, cDescripcion;	

	END;
	END PROCEDURE

	DOCUMENT
	' DESCRIPCION: se crea SP  para guardar los campos del mensaje <h2h-das> referente al mensaje DAS ?GetISOCountries? (request-reply) en la tabla bdisac:sac_wu_isopaises.' ,  
	' MODIFICO : Christian Echavarria',			
	' FECHA : 2013/07/24',
	' DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
	' MODIFICO : FRG',
	' FECHA : 2014/07/30',
	'BD: bdisac ';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_catisomonedas
(
pEmpresa 					CHAR (3),
pUsuario 					CHAR (8),
pChannel_type 				CHAR (3),
pChannel_name 				CHAR (3),
pChannel_version 			CHAR (4),
pForeign_rs_system_id_rq 	CHAR (11),
pForeign_rs_refnum_rq 		CHAR (16),
pForeign_rs_cntid_rq 		CHAR (11),
pName_rq 					CHAR (30),
pQueryfilter1 				CHAR (2),
pQueryfilter3 				CHAR (40),
pFecha_hora_rq 				DATETIME YEAR TO FRACTION(5),
pRet_code 					CHAR (5),
pData_more 					CHAR (1),
pData_num_recs 				CHAR (4),
pName_rp 					CHAR (30),
pCurrency_cd				CHAR (4),
pCurrency_name              CHAR (40),
pEquivalence 				CHAR (25),
pPrefix_format 				CHAR (4),
pDecimal                    CHAR (5),
pCurrency_regime            CHAR (20),
pMajor_unit 				CHAR (15),
pMinor_unit 				CHAR (15),
pMajor_unit_plural			CHAR (15),
pMinor_unit_plural			CHAR (15),
pDesc_error					CHAR (250),
pPartnerid_err 				CHAR (10),
pFecha_hora_rp 				DATETIME YEAR TO FRACTION(5),
pUser_insert 				CHAR (8),
pFecha_insert 				DATETIME YEAR TO FRACTION(5)
)
RETURNING   CHAR (5) AS cod_err,CHAR (30) AS error_desc; 

DEFINE iSqlErr 			INTEGER;
DEFINE cCodret 			CHAR(5);
DEFINE cCodretAux       CHAR(5);
DEFINE cDescripcion 	CHAR (100);
DEFINE ctxn_status 		CHAR (1);
DEFINE cCadena_ent    	CHAR(100);
DEFINE i_Sam_err		INTEGER;
DEFINE cProceso 		CHAR (45);
DEFINE cStatus 			CHAR(1);
DEFINE cRutaServer 		CHAR (40);
DEFINE cSql 			CHAR(600);
DEFINE cNombreArchivo 	CHAR(35);
DEFINE cMes, cDia  		CHAR(2);
DEFINE cAnio 			CHAR (2);
DEFINE cTabla  			CHAR (25);
DEFINE cMarcaVG  		CHAR (11);
DEFINE cMarcaOV  		CHAR (11);
DEFINE cFechaProceso    DATETIME YEAR TO SECOND;

LET iSqlErr = 0;
LET cCodret = '00000';
LET cCodretAux ='00000';
LET cDescripcion = 'Error en el proceso';
LET ctxn_status = 'C';
LET i_Sam_err           = 0;
LET cProceso = 'sp_sac_wu_guardarespuesta_catisomonedas';
LET cStatus = '2';
LET  cCadena_ent = TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pForeign_rs_system_id_rq,'NULL'))||'|'||TRIM(NVL(pName_rq,'NULL'));
LET cRutaServer = '';
LET cSql = '';
LET cNombreArchivo ='';
LET cMes='' ;
LET cDia = ''  ; 
LET cAnio ='';
LET cTabla  ='';
LET cMarcaVG  ='';
LET cMarcaOV  ='';
LET cFechaProceso = CURRENT::DATETIME YEAR TO SECOND;

BEGIN
	ON EXCEPTION SET iSqlErr,i_Sam_err,cDescripcion
		IF iSqlErr <> 0 THEN			
			LET cStatus ='1';  
			
			INSERT INTO bdisac:"informix".sac_wu_isomonedas(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,name_rq,queryfilter1,queryfilter3,fecha_hora_rq,retcode,data_more,data_num_recs,name_rp,currency_cd,currency_name,equivalence,prefix_format,decimal,currency_regime,major_unit,minor_unit,major_unit_plural,minor_unit_plural,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert) 
			VALUES  (ctxn_status,pChannel_type,pChannel_name,pChannel_version,pForeign_rs_system_id_rq,pForeign_rs_refnum_rq,pForeign_rs_cntid_rq,pName_rq,pQueryfilter1,pQueryfilter3,pFecha_hora_rq,pRet_code,pData_more,pData_num_recs,pName_rp,pCurrency_cd,pCurrency_name,pEquivalence,pPrefix_format,pDecimal,pCurrency_regime,pMajor_unit,pMinor_unit,pMajor_unit_plural,pMinor_unit_plural,pDesc_error,pPartnerid_err,pFecha_hora_rp,pUser_insert,current);
--	2014.07.30 -FRG.i
			--	pFecha_insert);
--	2014.07.30 -FRG.f

		   EXECUTE PROCEDURE	 bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCodret,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) INTO cCodret;
		  RETURN iSqlErr, cDescripcion; 
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_wu_guardarespuesta_catisomonedas.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
EXECUTE PROCEDURE	 bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCodret,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
INTO cCodret;

SELECT valor INTO cRutaServer FROM bdisac:"informix".sac_param  WHERE cod_param = 3;	
LET cMes  =  LPAD(MONTH(CURRENT::DATE), 2, '0');
LET cDia   =  LPAD(DAY(CURRENT::DATE), 2, '0') ; 
LET cAnio = TRIM(SUBSTR(LPAD(YEAR(CURRENT::DATE), 4, '0'),3));
LET  cNombreArchivo = 'sac_wu_isomonedas'||'_'||cDia||cMes||cAnio||'.'; 

IF pRet_code = '00000' THEN
	LET ctxn_status =	'A';
	LET cStatus= '3';
	
ELSE
     LET cStatus= '1';
	 LET cCodret = '00001';
END IF;

            INSERT INTO bdisac:"informix".sac_wu_isomonedas(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,name_rq,queryfilter1,queryfilter3,fecha_hora_rq,retcode,data_more,data_num_recs,name_rp,currency_cd,currency_name,equivalence,prefix_format,decimal,currency_regime,major_unit,minor_unit,major_unit_plural,minor_unit_plural,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert) 
			VALUES  (ctxn_status,pChannel_type,pChannel_name,pChannel_version,pForeign_rs_system_id_rq,pForeign_rs_refnum_rq,pForeign_rs_cntid_rq,pName_rq,pQueryfilter1,pQueryfilter3,pFecha_hora_rq,pRet_code,pData_more,pData_num_recs,pName_rp,pCurrency_cd,pCurrency_name,pEquivalence,pPrefix_format,pDecimal,pCurrency_regime,pMajor_unit,pMinor_unit,pMajor_unit_plural,pMinor_unit_plural,pDesc_error,pPartnerid_err,pFecha_hora_rp,pUser_insert, current);
--	2014.07.30 -FRG.i
			--	pFecha_insert);
--	2014.07.30 -FRG.f

 IF  cCodret <> '00000' THEN
	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCodret,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
        INTO cCodRetAux;
		IF cCodRetAux <> '00000' THEN
			LET cCodret = cCodRetAux;
		END IF
		  
		RETURN  cCodret, cDescripcion;
	ELSE	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
		INTO cCodRetAux;	
		
		IF cCodRetAux <> '00000' THEN
			LET cCodret = cCodRetAux;
		END IF
		
		IF cCodRet = '00000' THEN
			LET cDescripcion = "Ejecucion SP exitosa";
		END IF;	
	END IF;
RETURN  cCodret, cDescripcion;	

END;
END PROCEDURE
DOCUMENT
' DESCRIPCION: se crea SP  para guardar los campos del mensaje <h2h-das> referente al mensaje DAS ?GetISOCurrencies? (request-reply) en la tabla bdisac:sac_wu_isomonedas',  
' MODIFICO : Christian Echavarria',			
' FECHA : 2013/07/23',
' DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
' MODIFICO : FRG',
' FECHA : 2014/07/30',
'BD: bdisac ';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_catciudadeswu
(
	pEmpresa 					CHAR (3),
	pUsuario 					CHAR (8),
	pChannel_type 				CHAR (3),
	pChannel_name 				CHAR (3),
	pChannel_version			CHAR (4),
	pForeign_rs_system_id_rq 	CHAR (11),
	pForeign_rs_refnum_rq 		CHAR (16),
	pForeign_rs_cntid_rq 		CHAR (11),
	pName_rq 					CHAR (30),
	pQueryfilter1 				CHAR (2),
	pQueryfilter2 				CHAR (24),
	pQueryfilter3 				CHAR (24),
	pFecha_hora_rq 				DATETIME YEAR TO FRACTION(5),
	pRet_code 					CHAR (5),
	pAccount_num 				CHAR (10),
	pData_more 					CHAR (1),
	pData_num_recs 				CHAR (4),
	pName_rp 					CHAR (30),
	pFsid 						CHAR (11),
	pCounter_id 				CHAR (11),
	pTerm_id 					CHAR (6),
	pState_code 				CHAR (6),
	pState_name 				CHAR (44),
	pCity 						CHAR (44),
	pDesc_error 				CHAR (250),
	pPartnerid_err 				CHAR (10),
	pFecha_hora_rp 				DATETIME YEAR TO FRACTION(5),
	pUser_insert 				CHAR (8),
	pFecha_insert 				DATETIME YEAR TO FRACTION(5)
)
RETURNING   CHAR (5) AS cod_err,CHAR (30) AS error_desc;

DEFINE iSqlErr 			INTEGER;
DEFINE cCodret 			CHAR(5);
DEFINE cCodRetAux       CHAR(5);
DEFINE cDescripcion 	CHAR (100);
DEFINE ctxn_status 		CHAR (1);
DEFINE cCadena_ent     	CHAR(100);
DEFINE i_Sam_err		INTEGER;
DEFINE cProceso 		CHAR (45);
DEFINE cStatus 			CHAR(1);
DEFINE cRutaServer 		CHAR (40);
DEFINE cSql 			CHAR(600);
DEFINE cNombreArchivo 	CHAR(35);
DEFINE cMes, cDia  		CHAR(2);
DEFINE cAnio  			CHAR (2);
DEFINE cFechaProceso    DATETIME YEAR TO SECOND; 
 
LET iSqlErr = 0;
LET cCodret = '00000';
LET cCodRetAux ='00000';
LET cDescripcion = 'Error en el proceso';
LET ctxn_status = 'C';
LET i_Sam_err           = 0;
LET cProceso = 'sp_sac_wu_guardarespuesta_catciudadeswu';
LET cStatus = '2';
LET  cCadena_ent = TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pForeign_rs_system_id_rq,'NULL'))||'|'||TRIM(NVL(pName_rq,'NULL'));
LET cRutaServer = '';
LET cSql = '';
LET cNombreArchivo ='';
LET cMes='' ;
LET cDia = ''  ; 
LET cAnio ='';
LET cFechaProceso	= CURRENT::DATETIME YEAR TO SECOND;


BEGIN
	ON EXCEPTION SET iSqlErr,i_Sam_err,cDescripcion
		IF iSqlErr <> 0 THEN			
			LET cStatus ='1';
			
			INSERT INTO bdisac:"informix".sac_wu_catciudades_wu (txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,name_rq,queryfilter1,queryfilter2,queryfilter3,fecha_hora_rq,retcode,account_num,data_more,data_num_recs,name_rp,fsid,counter_id,term_id,state_code,state_name,city,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert) 
			VALUES  (ctxn_status, pChannel_type, pChannel_name, pChannel_version, pForeign_rs_system_id_rq, pForeign_rs_refnum_rq, pForeign_rs_cntid_rq, pName_rq, pQueryfilter1, pQueryfilter2, pQueryfilter3,	pFecha_hora_rq, pRet_code, pAccount_num, pData_more, pData_num_recs, pName_rp, pFsid, pCounter_id, pTerm_id, pState_code, pState_name, pCity, pDesc_error, pPartnerid_err, pFecha_hora_rp, pUser_insert, current);
--	2014.07.30-FRG.i
			--	pFecha_insert )	;
--	2014.07.30-FRG.f

		   EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCodret,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
		   INTO cCodret;
		  RETURN iSqlErr, cDescripcion; 
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_wu_guardarespuesta_catciudadeswu.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
EXECUTE PROCEDURE	 bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCodret,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
INTO cCodret;

SELECT valor INTO cRutaServer FROM bdisac:"informix".sac_param  WHERE cod_param = 3;	
LET cMes  =  LPAD(MONTH(CURRENT::DATE), 2, '0');
LET cDia   =  LPAD(DAY(CURRENT::DATE), 2, '0') ; 
LET cAnio = TRIM(SUBSTR(LPAD(YEAR(CURRENT::DATE), 4, '0'),3));
LET  cNombreArchivo = 'sac_wu_catciudades_wu_' ||cDia||cMes||cAnio||'.'; 


IF pRet_code = '00000' THEN
	LET ctxn_status ='A';
	LET cStatus= '3';
	
ELSE
     LET cStatus= '1';
	 LET cCodret = '00001';
END IF;

INSERT INTO bdisac:"informix".sac_wu_catciudades_wu (txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,name_rq,queryfilter1,queryfilter2,queryfilter3,fecha_hora_rq,retcode,account_num,data_more,data_num_recs,name_rp,fsid,counter_id,term_id,state_code,state_name,city,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert) 
	   VALUES(ctxn_status, pChannel_type, pChannel_name, pChannel_version, pForeign_rs_system_id_rq, pForeign_rs_refnum_rq, pForeign_rs_cntid_rq, pName_rq, pQueryfilter1, pQueryfilter2, pQueryfilter3, pFecha_hora_rq, pRet_code,	pAccount_num, pData_more, pData_num_recs, pName_rp, pFsid, pCounter_id, pTerm_id, pState_code, pState_name, pCity, pDesc_error, pPartnerid_err, pFecha_hora_rp,	pUser_insert, current);
--	2014.07.30 - FRG.i
	   --	   pFecha_insert);
--	2014.07.30 - FRG.f

    IF  cCodret <> '00000' THEN
	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCodret,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
        INTO cCodRetAux;
		IF cCodRetAux <> '00000' THEN
			LET cCodret = cCodRetAux;
		END IF
		  
		RETURN  cCodret, cDescripcion;
	ELSE	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
		INTO cCodRetAux;	
		
		IF cCodRetAux <> '00000' THEN
			LET cCodret = cCodRetAux;
		END IF
		
		IF cCodRet = '00000' THEN
			LET cDescripcion = "Ejecucion SP exitosa";
		END IF;	
	END IF;		

RETURN  cCodret, cDescripcion;	

END;
END PROCEDURE
DOCUMENT
' DESCRIPCION:se crea sp  para guardar los campos del mensaje <h2h-das> referente al DAS GetMexicoCityState (request-reply) en la tabla bdisac:sac_wu_catciudades_wu',  
' MODIFICO : Christian Echavarria',			
' FECHA : 2013/07/19',
' DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',
' MODIFICO : FRG',
' FECHA : 2014/07/30',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_catciudadesvgov
(
pEmpresa 					CHAR (3),
pUsuario 					CHAR (8),
pChannel_type 				CHAR (3),
pChannel_name 				CHAR (3),
pChannel_version 			CHAR (4),
pForeign_rs_system_id_rq 	CHAR (11),
pForeign_rs_refnum_rq 		CHAR (16), 
pForeign_rs_cntid_rq 		CHAR (13),
pName_rq 					CHAR (30),
pQueryfilter1 				CHAR (2),
pQueryfilter2 				CHAR (6),
pQueryfilter3 				CHAR (24),
pQueryfilter4 				CHAR (24),
pFecha_hora_rq 				DATETIME YEAR TO FRACTION(5),
pStatus_code 				CHAR (5),
pAccount_num 				CHAR (10),
pData_more 					CHAR (1),
pData_num_recs 				CHAR (4),
pName_rp 					CHAR (30),
pFsid						CHAR (11),
pCounter_id 				CHAR (13),
pTerm_id 					CHAR (6),
pState_name 				CHAR (44),
pCity 						CHAR (44),
pDesc_error 				CHAR (250),
pPartnerid_err 				CHAR (10),
pFecha_hora_rp 				DATETIME YEAR TO FRACTION(5),
pUser_insert 				CHAR (8),
pFecha_insert 				DATETIME YEAR TO FRACTION(5)
)
RETURNING   CHAR (5) AS cod_err,CHAR (30) AS error_desc;

DEFINE iSqlErr 			INTEGER;
DEFINE cCodret 			CHAR(5);
DEFINE cCodretAux 		CHAR(5);
DEFINE cDescripcion 	CHAR(100);
DEFINE ctxn_status 		CHAR(1);
DEFINE cCadena_ent     	CHAR(100);
DEFINE i_Sam_err		INTEGER;
DEFINE cProceso 		CHAR(45);
DEFINE cStatus 			CHAR(1);
DEFINE cRutaServer	    CHAR(40);
DEFINE cSql 			CHAR(600);
DEFINE cNombreArchivo 	CHAR(35);
DEFINE cMes, cDia  		CHAR(2);
DEFINE cAnio  			CHAR(2);
DEFINE cTabla  			CHAR(25);
DEFINE cMarcaVG  		CHAR(11);
DEFINE cMarcaOV  		CHAR(11);
DEFINE cFechaProceso    DATETIME YEAR TO SECOND; 

LET iSqlErr  = 0;
LET cCodret   = '00000';
LET cCodretAux = '00000';
LET cDescripcion = 'Error en el proceso';
LET ctxn_status = 'C';
LET i_Sam_err           = 0;
LET cProceso = 'sp_sac_wu_guardarespuesta_catciudadesvgov';
LET cStatus = '2';
LET  cCadena_ent = TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pForeign_rs_system_id_rq,'NULL'))||'|'||TRIM(NVL(pName_rq,'NULL'));
LET cRutaServer = '';
LET cSql = '';
LET cNombreArchivo ='';
LET cMes='' ;
LET cDia = ''  ; 
LET cAnio ='';
LET cTabla  ='';
LET cMarcaVG  ='';
LET cMarcaOV  ='';
LET cFechaProceso	= CURRENT::DATETIME YEAR TO SECOND;

BEGIN
	ON EXCEPTION SET iSqlErr,i_Sam_err,cDescripcion
		IF iSqlErr <> 0 THEN			
			LET cStatus ='1';
		    EXECUTE PROCEDURE	 bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCodret,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
			INTO cCodret;
		  RETURN iSqlErr, cDescripcion; 
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_wu_guardarespuesta_catciudadesvgov.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
EXECUTE PROCEDURE	 bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCodret,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
INTO cCodretAux;

SELECT valor INTO  cMarcaOV  FROM bdisac:"informix".sac_param WHERE cod_param = '87058';
SELECT valor INTO  cMarcaVG  FROM bdisac:"informix".sac_param WHERE cod_param = '87059';

IF  TRIM(pForeign_rs_system_id_rq ) =  cMarcaOV  THEN
		LET cTabla  ='sac_wu_catciudades_ov';
ELIF TRIM(pForeign_rs_system_id_rq ) = cMarcaVG THEN	
		LET cTabla  ='sac_wu_catciudades_vg';
ELSE
		LET cCodret = '00001';
		LET cDescripcion = 'Error en ejecucion SP';
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cProceso,cCodret,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
		INTO cCodretAux;
		
		RETURN  cCodret, cDescripcion;	
END IF;
	

SELECT valor INTO cRutaServer FROM bdisac:"informix".sac_param  WHERE cod_param = 3;
LET cMes  =  LPAD(MONTH(CURRENT::DATE), 2, '0');
LET cDia   =  LPAD(DAY(CURRENT::DATE), 2, '0') ; 
LET cAnio = TRIM(SUBSTR(LPAD(YEAR(CURRENT::DATE), 4, '0'),3));
LET  cNombreArchivo = TRIM(cTabla)||'_'||cDia||cMes||cAnio||'.'; 


IF pStatus_code = '00000' THEN
	LET ctxn_status =	'A';
	LET cStatus= '3';
	
ELSE
     LET cStatus= '1';
	 LET cCodret = '00001';
END IF;

IF  cTabla =  'sac_wu_catciudades_ov'  THEN
		INSERT INTO bdisac:"informix".sac_wu_catciudades_ov(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,name_rq,queryfilter1,queryfilter2,queryfilter3,queryfilter4,fecha_hora_rq,retcode,account_num,data_more,data_num_recs,name_rp,fsid,counter_id,term_id,state_name,city,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert) 
		VALUES (ctxn_status,pChannel_type ,pChannel_name ,pChannel_version ,pForeign_rs_system_id_rq ,pForeign_rs_refnum_rq,pForeign_rs_cntid_rq ,pName_rq ,pQueryfilter1 ,pQueryfilter2,pQueryfilter3 ,pQueryfilter4 ,pFecha_hora_rq ,pStatus_code ,pAccount_num ,pData_more ,pData_num_recs,pName_rp ,pFsid ,pCounter_id ,pTerm_id,pState_name,pCity ,pDesc_error ,pPartnerid_err ,pFecha_hora_rp,pUser_insert, current);
--	2014.07.30-FRG.i
		--	pFecha_insert );
--	2014.07.30-FRG.f

ELIF cTabla = 'sac_wu_catciudades_vg' THEN	
		INSERT INTO bdisac:"informix".sac_wu_catciudades_vg(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,name_rq,queryfilter1,queryfilter2,queryfilter3,queryfilter4,fecha_hora_rq,retcode,account_num,data_more,data_num_recs,name_rp,fsid,counter_id,term_id,state_name,city,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert) 
		VALUES (ctxn_status,pChannel_type ,pChannel_name ,pChannel_version ,pForeign_rs_system_id_rq ,pForeign_rs_refnum_rq,pForeign_rs_cntid_rq ,pName_rq ,pQueryfilter1 ,pQueryfilter2,pQueryfilter3 ,pQueryfilter4 ,pFecha_hora_rq ,pStatus_code ,pAccount_num ,pData_more ,pData_num_recs,pName_rp ,pFsid ,pCounter_id ,pTerm_id,pState_name,pCity ,pDesc_error ,pPartnerid_err ,pFecha_hora_rp,pUser_insert, current);
--	2014.07.30-FRG.i
		--	pFecha_insert );
--	2014.07.30-FRG.f

END IF;

 IF  cCodret <> '00000' THEN
	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,cCodret,cDescripcion,iSqlErr,i_Sam_err,cCadena_ent,pUsuario,cFechaProceso) 
        INTO cCodRetAux;
		IF cCodRetAux <> '00000' THEN
			LET cCodret = cCodRetAux;
		END IF
		  
		RETURN  cCodret, cDescripcion;
	ELSE	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cProceso,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
		INTO cCodRetAux;	
		
		IF cCodRetAux <> '00000' THEN
			LET cCodret = cCodRetAux;
		END IF
		
		IF cCodRet = '00000' THEN
			LET cDescripcion = "Ejecucion SP exitosa";
		END IF;	
		RETURN  cCodret, cDescripcion;
END IF;	

END;
END PROCEDURE
DOCUMENT
' DESCRIPCION: se crea SP  para guardar los campos del mensaje <h2h-das> referente al DAS â??GetCityStateListâ?? (request-reply) en la tabla bdisac:sac_wu_catciudades_vg Ã³ bdisac:sac_wu_catciudades_ov (depende de la marca).',  
' MODIFICO : Christian Echavarria',			
' FECHA : 2013/07/22	',
' DESCRIPCION: se actualiza campo counter_id a 13 posiciones.',  
' MODIFICO : FRG',			
' FECHA : 2014/04/08',
' DESCRIPCION: Se actualiza campo fecha_insert en tablas sac_wu_catciudades_ov y sac_wu_catciudades_vg con fecha-hora-sistema central (current)', 
' MODIFICO : FRG',
' FECHA : 2014/07/30',
'BD: bdisac ';

CREATE PROCEDURE "informix".sp_canc_seg(p_tramae CHAR(110), p_tramar CHAR(110))
RETURNING CHAR(5) AS CodigoRetorno;

--DEFINICION DE LAS VARIABLES
DEFINE iCodRet      		CHAR(5);
DEFINE iSqlErr      		INTEGER;
DEFINE cNumcliente 		CHAR(14);
DEFINE cEmpleado 			CHAR(8);
DEFINE cFecha 			CHAR(10);
DEFINE i				INTEGER;
DEFINE iAux				CHAR(1);
DEFINE iAux2			INTEGER;
DEFINE iIni				INTEGER;
DEFINE iPoliza 			INTEGER;
DEFINE iStatus 			INTEGER;
DEFINE cMensaje 			CHAR(100);
DEFINE iSec				INTEGER;
DEFINE iRecibo			INTEGER;
DEFINE iImporte			MONEY(16,4);
DEFINE iCaja			INTEGER;
DEFINE cArea			CHAR(1);
DEFINE iSucursal			INTEGER;
DEFINE iCiudad			INTEGER;
DEFINE iTipo			INTEGER;
DEFINE iMientras			INTEGER;
DEFINE cClave			CHAR(1);
DEFINE cTipoMov			CHAR(1);
DEFINE iCont			INTEGER;

--INICIALIZACION DE LAS VARIABLES
LET iCodRet				= '00000';
LET iSqlErr				= 0;
LET cNumcliente 			= '';
LET cEmpleado 			= '';
LET cFecha 				= '';
LET i					= 1;
LET iAux				= '';
LET iAux2				= 0;
LET cMensaje			= '';
LET iIni				= 0;
LET iSec				= 0;
LET iPoliza 			= 0;
LET iStatus 			= 0;
LET iRecibo				= 0;
LET iImporte			= 0;
LET iCaja				= 0;
LET cArea				= '';
LET iSucursal			= 0;
LET iCiudad				= 0;
LET iTipo 				= 0;
LET iMientras 			= 9;
LET cClave 				= '';
LET cTipoMov 			= '';
LET iCont 				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			RETURN iCodRet;
		END IF;
	END EXCEPTION;

--	SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_canc_seg.out';
--	TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	-- SE DESARMA LA TRAMA DE ENVÃO PARA REALIZAR EL INSERT A LA SAC_ABONO_SEG
	IF TRIM(NVL(p_tramae,'')) <> '' THEN
		WHILE iAux2 <> iMientras
			LET iAux = SUBSTR(p_tramae,i,1);
			IF iAux = '|' THEN
				LET iAux2 = iAux2 + 1;
				IF iAux2 = 1 THEN
					IF  SUBSTR(p_tramae,1,iCont) = 'G' THEN
						LET iTipo = 1;
						LET iMientras = 11;
						LET cClave = SUBSTR(p_tramae,1,iCont);
						LET iIni = i + 1;
					ELSE
						LET cNumcliente = SUBSTR(p_tramae,1,iCont);
						LET iIni = i + 1;
					END IF
				END IF
				IF  iTipo = 1 THEN
					IF iAux2 = 2 THEN
						LET cTipoMov = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
					ELIF iAux2 = 3 THEN
						LET cNumcliente = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
					ELIF iAux2 = 4 THEN
						LET iPoliza = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
						LET iPoliza = iPoliza::INTEGER;
					ELIF iAux2 = 5 THEN
						LET iRecibo = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
						LET iRecibo = iRecibo::INTEGER;
					ELIF iAux2 = 6 THEN
						LET iImporte = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
						LET iImporte = iImporte::INTEGER;
					ELIF iAux2 = 7 THEN
						LET cFecha = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
					ELIF iAux2 = 8 THEN
						LET iSucursal = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
						LET iSucursal = iSucursal::INTEGER;
					ELIF iAux2 = 9 THEN
						LET iCaja = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
					ELIF iAux2 = 10 THEN
						LET cArea = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
					ELIF iAux2 = 11 THEN
						LET iCiudad = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
						LET iCiudad = iCiudad::INTEGER;
						LET cEmpleado = SUBSTR(p_tramae,i + 1,LENGTH(p_tramae));
					END IF;
				ELSE
					IF iAux2 = 2 THEN
						LET iPoliza = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
						LET iPoliza = iPoliza::INTEGER;
					ELIF iAux2 = 3 THEN
						LET iImporte = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
					ELIF iAux2 = 4 THEN
						LET iRecibo = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
						LET iRecibo = iRecibo::INTEGER;
					ELIF iAux2 = 5 THEN
						LET cFecha = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
					ELIF iAux2 = 6 THEN
						LET iCaja = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
					ELIF iAux2 = 7 THEN
						LET cArea = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
					ELIF iAux2 = 8 THEN
						LET iSucursal = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
					ELIF iAux2 = 9 THEN
						LET iCiudad = SUBSTR(p_tramae,iIni,iCont -1);
						LET iIni = i + 1;
						LET cEmpleado = SUBSTR(p_tramae,i + 1,LENGTH(p_tramae));
					END IF
				END IF
				LET iCont = 0;
			END IF
			LET iCont = iCont+1;
			LET iAux = '';
			LET i = i +1;
		END WHILE;

		IF iTipo = 1 THEN
			INSERT INTO "informix".sac_canc_vtacam_seg (clave, tipomovimiento, numcliente, poliza, recibo, importe, fecha,  sucursal, ciudad, caja, area, empleadoefectuo)
			VALUES (cClave,cTipoMov,cNumcliente,iPoliza,iRecibo,iImporte,cFecha,iSucursal,iCiudad,iCaja,cArea,cEmpleado);
		ELSE
			INSERT INTO "informix".sac_canc_abono_seg (numcliente,poliza,recibo,fecha,importe,caja,area,sucursal,ciudad,empleadoefectuo)
			VALUES (cNumcliente,iPoliza,iRecibo,cFecha,iImporte,iCaja,cArea,iSucursal,iCiudad,cEmpleado);
		END IF;
	ELSE
		LET iCodRet = '00001';
	END IF;

	-- SE INICIALIZAN VARIABLES PARA REUTILIZARLAS
	LET iAux  = '';
	LET iAux2 = 0;
	LET iIni  = 0;
	LET iCont = 0;
	LET i = 0;

	-- SE DESARMA LA TRAMA DE RESPUESTA PARA REALIZAR LA ACTUALIZACIÃN A LA TABLA SAC_ABONO_SEG
	IF TRIM(NVL(p_tramar,'')) <> '' THEN
		WHILE iAux2 <> 1
			 LET iAux = SUBSTR(p_tramar,i,1);
			 IF iAux = '|' THEN
				LET iAux2 = iAux2 + 1;
				IF iAux2 = 1 THEN
					LET iStatus = SUBSTR(p_tramar,1,iCont -1 );
					LET iIni = i + 1;
					LET cMensaje = SUBSTR(p_tramar,i + 1,LENGTH(p_tramar));
				END IF
			END IF;
			LET iCont = iCont+1;
			LET iAux = '';
			LET i = i +1;
		END WHILE;

		IF itipo = 1 THEN
			SELECT secuencia INTO iSec FROM "informix".sac_canc_vtacam_seg WHERE secuencia = (SELECT MAX(secuencia) FROM "informix".sac_canc_vtacam_seg WHERE empleadoefectuo = TRIM(cEmpleado));

			UPDATE "informix".sac_canc_vtacam_seg SET cod_resp = iCodRet, cnxn_status = 'A',estatus = iStatus, mensajes = cMensaje WHERE secuencia = iSec;
		ELSE
			SELECT secuencia INTO iSec FROM "informix".sac_canc_abono_seg WHERE secuencia =(SELECT MAX(secuencia) FROM "informix".sac_canc_abono_seg WHERE empleadoefectuo = TRIM(cEmpleado));
			UPDATE "informix".sac_canc_abono_seg SET cod_resp = iCodRet, cnxn_status = 'A',estatus = iStatus, mensajes = cMensaje WHERE secuencia = iSec;
		END IF
	END IF;
	RETURN iCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio: 1448',
'Autor: 92893422 ',
'Fecha: 10/07/2014',
'DescripciÃ³n: Se crea procedimiento graba envio y respuesta de confirmacion del abono.',
'Sustento:RQI 62 038 VentaClubdeProteccionCppl-BCP_InterfacesCaja_v3',
'Solicita: FermÃ­n Ramos',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_cp_consctesex(pNumCte CHAR(20))
RETURNING   CHAR(5)   AS CodigoRetorno,
			CHAR(2)   AS StatusCte,
			DATE      AS FechaAlta,
			DATE      AS FechaNac,
			CHAR(1)   AS Sexo;
			
--DECLARACION DE VARIABLES
DEFINE vi_SqlErr        INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE vc_CodRet        CHAR(5);
DEFINE vc_StatusCte     CHAR(2);
DEFINE vd_FechaAlta     DATE;
DEFINE vd_FechaNac      DATE;
DEFINE cSexo            CHAR(1);
DEFINE cTpoPers         CHAR(2);

--INICIALIZACION DE VARIABLES
LET vi_SqlErr       = 0;
LET iIsamErr        = 0 ;
LET vc_CodRet       = '00000';
LET vc_StatusCte    = '';
LET vd_FechaAlta    = DATE(1);
LET vd_FechaNac     = DATE(1);
LET cSexo           = '';
LET cTpoPers        = '';


BEGIN
    ON EXCEPTION SET vi_SqlErr, iIsamErr
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            RETURN TRIM(vc_CodRet), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	
	--SET DEBUG FILE TO '/respaldosbd/resbdrigoberto/sp_cp_consctesex.out';
	--TRACE ON;
	
	--VALIDAMOS QUE EL PARAMETRO NO VENGA EN BLANCO
	IF NVL(pNumCte, '') = '' THEN
		--PARAMETRO DE ENTRADA INVALIDO
		LET vc_CodRet = '00001';
		RETURN TRIM(vc_CodRet), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));
	END IF;
	
	--VALIDAMOS QUE EL NO. DE CLIENTE VENGA CON EL FORMATO
	IF LENGTH(pNumCte)<> 9 THEN
		--LONGITUD INVALIDA PARA EL PARAMETRO DE ENTRADA
		LET vc_CodRet = '00001';
		RETURN TRIM(vc_CodRet), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));
	END IF;
	
	SELECT tpo_persona, status_cte, fecha_alta 
	INTO   cTpoPers, vc_StatusCte, vd_FechaAlta 
	FROM bdinteg:'informix'.si_cliente
	WHERE numcte = pNumCte;		

	--SI LA BUSQUEDA NO ARROJA RESULTADOS
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN
		--NUMERO DE CLIENTE NO EXISTE
		LET vc_CodRet = '00002';
		RETURN TRIM(vc_CodRet), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));
	END IF
		
	--EL STATUS DEL CLIENTE INDICA QUE EL CLIENTE SE HA DADO DE BAJA O ESTA CANCELADO
	IF vc_StatusCte = 'BA' THEN
		LET vc_CodRet = '00003';
		RETURN TRIM(vc_CodRet), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));
	END IF;

	--ES UNA PERSONA FISICA
	IF TRIM(cTpoPers) = '01' THEN
	
		SELECT fecha_nac, sexo 
		INTO vd_FechaNac, cSexo
		FROM bdinteg:'informix'.si_ctepf WHERE numcte = pNumCte;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			--INCONGRUENCIA DE DATOS
			LET vc_CodRet = '00005';
			RETURN TRIM(vc_CodRet), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));
		END IF	 
	ELSE
		--PERSONA MORAL
		LET vc_CodRet = '00004';
	END IF;
	
	RETURN TRIM(vc_CodRet), TRIM(NVL(vc_StatusCte,'')), NVL(vd_FechaAlta, DATE(1)), NVL(vd_FechaNac, DATE(1)), TRIM(NVL(cSexo, ''));
END;
END PROCEDURE
DOCUMENT
'REALIZÓ: Rigoberto Gonzalez',
'FECHA:  02  de agosto, 2014',
'BD: bdisac';

CREATE PROCEDURE  "informix".sp_graba_abono_seg(p_tramae CHAR(200), p_tramar CHAR(100))
RETURNING CHAR(5) AS CodigoRetorno;

--DEFINICION DE LAS VARIABLES
DEFINE iCodRet      		CHAR(5);
DEFINE iSqlErr      		INTEGER;
DEFINE cNumcliente 		CHAR(14);
DEFINE cEmpleado 			CHAR(8);
DEFINE cFecha 			CHAR(10);
DEFINE i				INTEGER;
DEFINE iAux				CHAR(1);
DEFINE iAux2			INTEGER;
DEFINE iIni				INTEGER;
DEFINE iPoliza 			INTEGER;
DEFINE iStatus 			INTEGER;
DEFINE cMensaje 			CHAR(100);
DEFINE iSec				INTEGER;
DEFINE iRecibo			INTEGER;
DEFINE iImporte			MONEY(16,4);
DEFINE iMesesPagados		INTEGER;
DEFINE iCantSeguros		INTEGER;
DEFINE cFechaVencido		CHAR(10);
DEFINE cFechaNacimiento		CHAR(10);
DEFINE iCaja			INTEGER;
DEFINE cArea			CHAR(1);
DEFINE iSucursal			INTEGER;
DEFINE iCiudad			INTEGER;
DEFINE iCont			INTEGER;

--INICIALIZACION DE LAS VARIABLES
LET iCodRet				= '00000';
LET iSqlErr				= 0;
LET cNumcliente 			= '';
LET cEmpleado 			= '';
LET cFecha 				= '';
LET i					= 1;
LET iAux				= '';
LET iAux2				= 0;
LET cMensaje			= '';
LET iIni				= 0;
LET iSec				= 0;
LET iPoliza 			= 0;
LET iStatus 			= 0;
LET iRecibo				= 0;
LET iImporte			= 0;
LET iMesesPagados			= 0;
LET iCantSeguros			= 0;
LET cFechaVencido			= '';
LET cFechaNacimiento		= '';
LET iCaja				= 0;
LET cArea				= '';
LET iSucursal			= 0;
LET iCiudad				= 0;
LET iCont 				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			RETURN iCodRet;
		END IF;
	END EXCEPTION;

--	SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_graba_abono_seg.out';
--	TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	-- SE DESARMA LA TRAMA DE ENVÍO PARA REALIZAR EL INSERT A LA SAC_ABONO_SEG
	IF TRIM(NVL(p_tramae,'')) <> '' THEN
		WHILE iAux2 <> 13
			LET iAux = SUBSTR(p_tramae,i,1);
			IF iAux = '|' THEN
			
				LET iAux2 = iAux2 + 1;
				IF iAux2 = 1 THEN
					LET cNumcliente = SUBSTR(p_tramae,1,iCont);
					LET iIni = i + 1;					
				ELIF iAux2 = 2 THEN
					LET iPoliza = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;
					LET iPoliza = iPoliza::INTEGER;					
				ELIF iAux2 = 3 THEN
					LET iRecibo = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;
					LET iRecibo = iRecibo::INTEGER;
				ELIF iAux2 = 4 THEN
					LET cFecha = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;
				ELIF iAux2 = 5 THEN
					LET iImporte = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;				
				ELIF iAux2 = 6 THEN
					LET iMesesPagados = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;					
				ELIF iAux2 = 7 THEN
					LET iCantSeguros = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;					
				ELIF iAux2 = 8 THEN
					LET cFechaVencido = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;					
				ELIF iAux2 = 9 THEN
					LET cFechaNacimiento = SUBSTR(p_tramae,iIni,iCont - 1);
					LET iIni = i + 1;				
				ELIF iAux2 = 10 THEN
					LET iCaja = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;					
				ELIF iAux2 = 11 THEN
					LET cArea = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;					
				ELIF iAux2 = 12 THEN
					LET iSucursal = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;					
				ELIF iAux2 = 13 THEN
					LET iCiudad = SUBSTR(p_tramae,iIni,iCont -1);
					LET iIni = i + 1;
					LET cEmpleado = SUBSTR(p_tramae,i + 1,LENGTH(p_tramae));					
				END IF
				LET iCont = 0;
			END IF;
			LET iCont = iCont+1;
			LET iAux = '';
			LET i = i +1;
		END WHILE;

		INSERT INTO "informix".sac_abono_seg (numcliente, poliza, recibo, fecha, importe, mesespagados, cantidadseguros, fechavencimiento, fechanacimiento, sucursal, ciudad, caja, area, empleadoefectuo)
		VALUES (cNumcliente,iPoliza,iRecibo,cFecha,iImporte,iMesesPagados,iCantSeguros,cFechaVencido,cFechaNacimiento,iSucursal,iCiudad,iCaja,cArea,cEmpleado);
	ELSE
		LET iCodRet = '00001';
	END IF;

	-- SE INICIALIZAN VARIABLES PARA REUTILIZARLAS
	LET iAux  = '';
	LET iAux2 = 0;
	LET iIni  = 0;
	LET iCont = 0;
	LET i = 0;

	-- SE DESARMA LA TRAMA DE RESPUESTA PARA REALIZAR LA ACTUALIZACIÓN A LA TABLA SAC_ABONO_SEG
	IF TRIM(NVL(p_tramar,'')) <> '' THEN
		WHILE iAux2 <> 1
			 LET iAux = SUBSTR(p_tramar,i,1);
			 IF iAux = '|' THEN
				LET iAux2 = iAux2 + 1;
				IF iAux2 = 1 THEN
					LET iStatus = SUBSTR(p_tramar,1,iCont -1 );
					LET iIni = i + 1;
					LET cMensaje = SUBSTR(p_tramar,i + 1,LENGTH(p_tramar));
					
				END IF
			END IF;
			LET iCont = iCont+1;
			LET iAux = '';
			LET i = i +1;
		END WHILE;

		SELECT secuencia INTO iSec FROM "informix".sac_abono_seg WHERE secuencia =(SELECT MAX(secuencia) FROM "informix".sac_abono_seg WHERE empleadoefectuo = TRIM(cEmpleado));

		UPDATE "informix".sac_abono_seg SET cod_resp = iCodRet, cnxn_status = 'A',estatus = iStatus, mensajes = cMensaje, fecha_insert = CURRENT WHERE secuencia = iSec;

	END IF;
	RETURN iCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio: 1448',
'Autor: 92893422 ',
'Fecha: 10/07/2014',
'Descripción: Se crea procedimiento graba envio y respuesta de confirmacion del abono.',
'Sustento:RQI 62 038 VentaClubdeProteccionCppl-BCP_InterfacesCaja_v3',
'Solicita: Fermín Ramos',
'BD: bdisac';

CREATE PROCEDURE  "informix".sp_graba_cons_seg(pTramae CHAR(50), pTramar CHAR(300))
RETURNING CHAR(5)   AS CodigoRetorno; 

--DEFINICION DE LAS VARIABLES
DEFINE iCodRet      CHAR(5); 
DEFINE iSqlErr      INTEGER; 

DEFINE cNumcliente 	CHAR(14);  
DEFINE cSucursal 	CHAR(4);
DEFINE cCiudad 		CHAR(5);
DEFINE cEmpleado 	CHAR(8);
DEFINE cFecha 		CHAR(8);
DEFINE i			INTEGER;
DEFINE iAux			CHAR(1);
DEFINE iAux2		INTEGER;
DEFINE iIni			INTEGER; 

DEFINE cClaveseguro 		CHAR(1);
DEFINE cTipopago 			CHAR(1);
DEFINE cPoliza 				CHAR(15);
DEFINE cNomAseg				CHAR(15); 
DEFINE cAppaterno 			CHAR(15);
DEFINE cApmaterno 			CHAR(15);
DEFINE cNumcteban 			CHAR(20);
DEFINE cFechaafiliacion 	CHAR(10);
DEFINE cFechavencimiento 	CHAR(10);
DEFINE cCosto 				CHAR(15); 
DEFINE cCantidadmaxpagar 	CHAR(15);
DEFINE cStatus 				CHAR(15);
DEFINE cMensaje 			CHAR(200);
DEFINE cCantiseg			CHAR(15);
DEFINE iSec					INTEGER;
DEFINE cCnxn_status 	CHAR(1);
DEFINE cCod_resp        CHAR(5); 

--INICIALIZACION DE LAS VARIABLES
LET iCodRet    = '00000';
LET iSqlErr    = 0;
 
LET cNumcliente = '';  
LET cSucursal 	= '';
LET cCiudad 	= '';
LET cEmpleado 	= '';
LET cFecha 		= '';
LET i			= 1;
LET iAux		= '';
LET iAux2		= 0;
LET cMensaje	= '';
LET iIni		= 0;
LET cCantiseg	= '';
LET iSec		= 0;

LET cClaveseguro 		= '';
LET cTipopago 			= '';
LET cPoliza 			= '';
LET cNomAseg			= ''; 
LET cAppaterno 			= '';
LET cApmaterno 			= '';
LET cNumcteban 			= '';
LET cFechaafiliacion 	= '';
LET cFechavencimiento 	= '';
LET cCosto 				= ''; 
LET cCantidadmaxpagar 	= '';
LET cStatus 			= '';
LET cCnxn_status	 	='C';
LET cCod_resp		 	='00001';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			RETURN iCodRet;
		END IF;
	END EXCEPTION;

	-- SET DEBUG FILE TO '/respaldosbd/josue/sp_graba_cons_seg.out';
	-- TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	-- SE DESARMA LA TRAMA DE ENVÍO PARA REALIZAR EL INSERT A LA SAC_CONS_SEG
	IF TRIM(NVL(pTramae,'')) <> '' THEN
	   WHILE iAux2 <> 4
			 LET iAux = SUBSTR(pTramae,i,1);
			 IF iAux = '|' THEN
				LET iAux2 = iAux2 + 1; 
					IF iAux2 = 1 THEN 
						LET cNumcliente = SUBSTR(pTramae,1,i -1);
						LET iIni = i + 1;
					ELIF iAux2 = 2 THEN				
						LET cSucursal = SUBSTR(pTramae,iIni,i -iIni);
						LET iIni = i + 1;
						LET cSucursal = cSucursal::SMALLINT;
					ELIF iAux2 = 3 THEN				
						LET cCiudad = SUBSTR(pTramae,iIni,i -iIni);
						LET iIni = i + 1;
						LET cCiudad = cCiudad::INTEGER;
					ELIF iAux2 = 4 THEN				
						LET cEmpleado = SUBSTR(pTramae,iIni,i -iIni);
						LET cEmpleado = cEmpleado::INTEGER;
						LET cFecha = SUBSTR(pTramae,i +1,LENGTH(pTramae));				
					END IF;
			 END IF;
			 LET iAux = '';
			 LET i = i +1;
		END WHILE;
	
		-- SE INICIALIZAN VARIABLES PARA REUTILIZARLAS
		LET iAux  = '';
		LET iAux2 = 0;
		LET iIni  = 0;
		LET i	  = 1;
	
		IF TRIM(NVL(pTramar,'')) <> '' THEN
		-- SE DESARMA LA TRAMA DE RESPUESTA PARA REALIZAR LA ACTUALIZACIÓN A LA TABLA SAC_CONS_SEG	
			WHILE iAux2 <> 13
				 LET iAux = SUBSTR(pTramar,i,1);
				 IF iAux = '|' THEN
					LET iAux2 = iAux2 + 1; 
						IF iAux2 = 1 THEN 
							LET cClaveseguro = SUBSTR(pTramar,1,i -1);
							LET iIni = i + 1;
						ELIF iAux2 = 2 THEN				
							LET cTipopago = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
						ELIF iAux2 = 3 THEN				
							LET cNomAseg = SUBSTR(pTramar,iIni,i-iIni);
							LET iIni = i + 1;
						ELIF iAux2 = 4 THEN				
							LET cAppaterno = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
							LET cAppaterno = TRIM(cAppaterno);
						ELIF iAux2 = 5 THEN										
							LET cApmaterno = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
							LET cApmaterno = TRIM(cApmaterno);
						ELIF iAux2 = 6 THEN	
							LET cNumcteban = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
							LET cNumcteban = TRIM(cNumcteban);
						ELIF iAux2 = 7 THEN					
							LET cPoliza = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
							LET cPoliza = TRIM(cPoliza)::INTEGER;						
						ELIF iAux2 = 8 THEN				
							LET cCantiseg = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
							LET cCantiseg = cCantiseg::SMALLINT;
						ELIF iAux2 = 9 THEN										
							LET cFechaafiliacion = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
						ELIF iAux2 = 10 THEN										
							LET cFechavencimiento = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
						ELIF iAux2 = 11 THEN				
							LET cCosto = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
							LET cCosto = TRIM(cCosto)::INTEGER;
						ELIF iAux2 = 12 THEN				
							LET cCantidadmaxpagar = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
							LET cCantidadmaxpagar = cCantidadmaxpagar::SMALLINT;						
						ELIF iAux2 = 13 THEN				
							LET cStatus = SUBSTR(pTramar,iIni,i -iIni);
							LET iIni = i + 1;
							LET cStatus = cStatus::SMALLINT;						
							LET cMensaje = SUBSTR(pTramar,i+1,LENGTH(pTramar));
							LET cMensaje = TRIM(NVL(cMensaje,''));
						END IF;
				 END IF;
				 LET iAux = '';
				 LET i = i +1;
			END WHILE;			
					
			LET cCnxn_status ='A';
			LET cCod_resp='00000';	
		END IF;
			
			-- SE REGISTRA LA CONSULA DE SEGURO EN LA TABLA sac_cons_seg LA INFORMACIÓN DE ENVÍO Y RESPUESTA
			INSERT INTO "informix".sac_cons_seg (cnxn_status,numcliente,sucursal,ciudad,empleadoefectuo,fecha,cod_resp,claveseguro,
			tipopago,poliza,cantidadseguros,nombreasegurado,appaternoaseg,apmaternoaseg,numclientebancoppel,fechaafiliacion,fechavencimiento,
			costo,cantidadmaxpagar,status,mensajes)
			VALUES (cCnxn_status,cNumcliente,cSucursal,cCiudad,cEmpleado,cFecha,cCod_resp,cClaveseguro,cTipopago,cPoliza,cCantiseg,
			cNomAseg,cAppaterno,cApmaterno,cNumcteban,cFechaafiliacion,cFechavencimiento,cCosto,cCantidadmaxpagar,cStatus,cMensaje);
	ELSE
		LET iCodRet = '00001';
	END IF;
	
	RETURN iCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio: 1448',
'Autor: 94912599 ',
'Fecha: 10/07/2014',
'Descripción: Se crea procedimiento para grabar lo que se envía y su respuesta al consultar un seguro CP a coppel',
'Sustento:RQI 62 038 VentaClubdeProteccionCppl-BCP_InterfacesCaja_v3',
'Solicita: Fermín Ramos',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_grabapagocoppelcp	(	cClave CHAR,
														cTipomovimiento CHAR,
														iSucursal SMALLINT,
														iCiudad SMALLINT,
														iCliente INT,
														iCteprospectocppl INT8,
														iRecibo INTEGER,
														iFactura INTEGER,
														iImporte INTEGER,
														cEjercicio CHAR,
														iEfectuo INTEGER,
														cMovtoSeguro CHAR,
														iCantidadMeses INTEGER,
														iCantidadSeguros INTEGER,
														iFolioSeguro INTEGER,
														cSexo CHAR(1),
														dFechaVencimiento DATE
													)

RETURNING CHAR(5);


    DEFINE cCodRet     	CHAR(5);
    DEFINE iSqlErr     	INTEGER;
    DEFINE iIsamErr    	INTEGER;
	DEFINE cInfoErr    	CHAR(100);
    DEFINE iCaja       	INTEGER;
    DEFINE dFecha_Hoy  	DATE;
	DEFINE CdRetVerSis 	CHAR (5);
	DEFINE IndCrreCred 	CHAR (1);
	DEFINE IndDispCred 	CHAR (1);
	DEFINE IndCrreChqs 	CHAR (1);
	DEFINE IndDispChqs 	CHAR (1);
	DEFINE IndCrreInvs 	CHAR (1);
	DEFINE IndDispInvs 	CHAR (1);
	DEFINE IndCrreSrvs 	CHAR (1);
	DEFINE IndRegs		INTEGER;

	LET CdRetVerSis		= '';
	LET IndCrreCred 	= '';
	LET IndDispCred 	= '';
	LET IndCrreChqs 	= '';
	LET IndDispChqs 	= '';
	LET IndCrreInvs 	= '';
	LET IndDispInvs 	= '';
	LET IndCrreSrvs 	= '';
	LET IndRegs			= 0;

	--SET DEBUG FILE TO '/respaldosbd/resbdrigoberto/sp_grabapagocoppelcp.out';
	--TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_cp_grabapagocoppel");
                    RETURN cCodRet;
                END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_Hoy FROM "informix".sac_fechas;

		-- Validación Disponibilidad Servicio: Se validan cierres de los sistemas antes de iniciar proceso de PGPROG:
		EXECUTE FUNCTION bdinteg:"informix".verifica_sistemas()
		INTO CdRetVerSis, IndCrreCred, IndDispCred, IndCrreChqs, IndDispChqs, IndCrreInvs, IndDispInvs, IndCrreSrvs;
		
		IF IndCrreSrvs <> '1' THEN
			LET cCodRet = '00060';
			LET iSqlErr = 0;
			LET iIsamErr = 0;
			LET cInfoErr = 'Sistema Servicios No Disponible.';
			EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_cp_grabapagocoppel");
			RETURN cCodRet;
		END IF;

        SELECT CAST(valor AS INTEGER) INTO iCaja FROM "informix".sac_param WHERE cod_param = 11;
		LET cCodRet = '00000';
		
		SELECT  COUNT(recibo)
		INTO IndRegs
		FROM "c92357113".sac_movimientosdetalle
		WHERE clave = cClave
		AND tipomovimiento = cTipomovimiento
		AND recibo = iRecibo
		AND sucursal = iSucursal
		AND factura = iFactura
		AND folio = iFolioSeguro;

        IF NVL(IndRegs,0) > 0 THEN
			LET cCodRet = '00001';
        ELSE
            INSERT INTO "c92357113".sac_movimientosdetalle (clave, tipomovimiento, sucursal, ciudad, cliente, clienteetp, caja, recibo,
                                        factura, importe, saldoinicial, saldofinal, saldocuenta, vencidoinicial, minimoinicial,
                                        montodolar, base, fechasaldacon, importesaldacon, tipoconvenio, subtipoconvenio, plazoconvenio,
                                        ejercicio, clavetdaocob, grabacartera, anexo, clavelocal, clientelocalizar, tiposeguro,
                                        flagseguroconyugal, movtoseguro, flagmontoseguro, statusseguro, causabaja, cantidadseguros,
                                        cantidadsegurosanterior, cantidadmeses, bonificacion, mesesvencidos, fechanacimiento, edad,
                                        sexo, areaajuste, fechaabonoajuste, claveajuste, ajuste, sucursalorigen, numerocontrol,
                                        comision, clienteremitente, tipogastoviaje, centro, flagincluyerecibo, ruta, folio, cuenta,
                                        iva, telefono, compania, contrato, credito, fechavencimiento, fechavencimientoanterior,
                                        fecha, efectuo, cajaoriginal, foliosucursal, rpu, flagmovtosupervisor, interes,importeventa,
                                        folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto,
                                        registropatronal, formaaportacionafore, ipcarteracliente, fechamovto, candidato, statusafore,
										status_coppel, cte_prospecto)
            VALUES(cClave, cTipomovimiento, iSucursal, iCiudad, iCliente,  0, iCaja, iRecibo,
                iFactura, iImporte, 0, 0, 0, 0, 0,
                0, 0, '01-01-1900', 0, ' ', ' ', 0,
                cEjercicio, ' ', ' ', ' ', ' ', ' ', ' ',
                ' ', cMovtoSeguro, ' ', ' ', 0, iCantidadSeguros,
                0, iCantidadMeses, 0, 0, '01-01-1900', 0,
                cSexo, ' ', '01-01-1900', ' ', ' ', 0, 0,
                0, 0, ' ', 0, ' ', 0, iFolioSeguro, ' ',
                0, 0, ' ', ' ', ' ', dFechaVencimiento, '01-01-1900',
                dFecha_Hoy, iEfectuo, 0, 0, ' ', ' ', 0, 0,
                0, 0, ' ', '01-01-1900', 0, 0, 0,
                ' ', 0, ' ', CURRENT, 0, 0, 0, iCteprospectocppl);
        END IF;
        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR :Rigoberto Gonzalez Llanes',
'DESCRIPCION: Se encarga de guardar en tablas el detalle de los movimientos generados por Coppel al aplicar abonos para el club de proteccion',
'EQUIPO DE TRABAJO: Club de Proteccion Coppel',
'EJECUTADO O LLAMADO POR: Caja.exe()',
'FECHA : 01 agosto de 2014',
'VERSION: 20140801.1300',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_wu_obtparamsgenerales( pEmpresa CHAR (3),  pUsuario CHAR(8), pMarca CHAR(2), pFechahora_invoca DATETIME YEAR TO SECOND )

RETURNING CHAR(5) AS cod_err, CHAR(30) AS error_desc, CHAR(4) AS channel_type, CHAR(4) AS channel_name, CHAR(4) AS channel_version,
          CHAR(11) AS frs_identifier, 
--	2014.04.04 FRG-i
		  --	CHAR(11) AS frs_counter_id, 
		  CHAR(13) AS frs_counter_id, 
--	2014.04.04 FRG-f		  
		  CHAR(10) AS templete_id, CHAR(1) as no_reintentos, CHAR(8) AS user_insert, CHAR(22) AS fechahora_insert;
		  
--DEFINICION DE VARIABLES--
DEFINE iSqlErr	   		INTEGER;
DEFINE cCodRet	  	 	CHAR(5);
DEFINE cCodRetAux   	CHAR(5);
DEFINE cNombreSP    	CHAR(45);
DEFINE iIsamErr    		INTEGER;
DEFINE cSucursal		CHAR(4);
DEFINE cChannel_Type   	CHAR(4);
DEFINE cChannel_Name   	CHAR(4);
DEFINE cChannel_Version CHAR(4);
DEFINE cFrs_Identifier  CHAR(11);
--	2014.04.04 FRG-i
--	DEFINE cFrs_Counter_Id  CHAR(11);
DEFINE cFrs_Counter_Id  CHAR(13);
--	2014.04.04 FRG-f
DEFINE cTemplete_Id     CHAR(10);
DEFINE cNo_reintentos   CHAR(1);
DEFINE cCadena_ent	   	CHAR(100);
DEFINE cError_Desc     	CHAR(30);
DEFINE cFechaProceso    DATETIME YEAR TO SECOND;

--INICIALIZACION DE VARIABLES--
LET	iSqlErr 			= 0;
LET	cCodRet 			= '00000';
LET cCodRetAux 			='00000';
LET cNombreSP 			= 'sp_wu_obtparamsgenerales';
LET	iIsamErr 			= 0;
LET cSucursal			="";
LET cChannel_Type		="";
LET cChannel_Name 		="";
LET cChannel_Version 	="";
LET cFrs_Identifier 	="";
LET cFrs_Counter_Id 	=""; 
LET cTemplete_Id 		="";
LET cNo_reintentos      = "";
LET cCadena_ent			= TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pMarca,'NULL'));
LET cError_Desc 		="Error en el proceso";
LET cFechaProceso		= CURRENT::DATETIME YEAR TO SECOND;
    
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
				IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;

					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSqlErr,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
					INTO cCodRetAux;	
		
					IF cCodRetAux <> '00000' THEN
						LET cCodRet = cCodRetAux;
					END IF
		
					RETURN cCodRet, cError_Desc, cChannel_Type, cChannel_Name, cChannel_Version, cFrs_Identifier, cFrs_Counter_Id, cTemplete_Id, cNo_reintentos, pUsuario, CURRENT:: DATETIME YEAR TO SECOND;
				END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/Martha/sp_wu_obtparamsgenerales.out';
	--TRACE ON;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
		
	IF NVL(pEmpresa,"") <> "" AND NVL(pUsuario,"") <> "" AND NVL(pMarca,"") <> "" AND NVL(pFechahora_invoca,"") <> "" THEN
		
		IF (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87054') = pMarca 
			OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87055') = pMarca 
			OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87056') = pMarca THEN
			
			IF pUsuario = "sys_wu" THEN
				LET cSucursal = '9250';
			ELSE
				
				SELECT sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
			END IF;
								
			IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN			
				SELECT {+INDEX(bdisac:sac_wu_identificadores idx_wuidents)}
				fsid,counter_id
				INTO cFrs_Identifier,cFrs_Counter_Id
				FROM bdisac:"informix".sac_wu_identificadores 
--					WHERE marca = pMarca AND sucursal = cSucursal AND empresa = pEmpresa;			  
				WHERE empresa = pEmpresa and marca = pMarca AND sucursal = cSucursal;
								
				SELECT valor
				INTO cChannel_Type
				FROM bdisac:"informix".sac_param 
				WHERE cod_param = '87050';  
				 
				SELECT valor
				INTO cChannel_Name
				FROM bdisac:"informix".sac_param 
				WHERE cod_param = '87051'; 
				 
				SELECT valor
				INTO cChannel_Version
				FROM bdisac:"informix".sac_param 
				WHERE cod_param = '87052'; 
					
				SELECT valor
				INTO cTemplete_Id
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87063';
					
				SELECT valor
				INTO cNo_reintentos
				FROM bdisac:"informix".sac_param
				WHERE cod_param = '87085';
				
				IF cFrs_Identifier IS NULL OR cFrs_Identifier = '' OR cFrs_Counter_Id IS NULL OR cFrs_Counter_Id = '' THEN
					LET cCodRet = '00002'; 
					LET cError_Desc	= 'Usuario no tiene Id. Asignado';
				END IF;
				
			ELSE
				LET	cCodRet = '00002'; --- Usuario no se encuentra
				LET cError_Desc	= 'NO EXISTE USUARIO';
			END IF;
		ELSE
			LET	cCodRet = '00002'; --- Marca Inválida
			LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';
		END IF;		
					  -- cCodRet = 00000 CONTINUA CON EL FLUJO
	ELSE
	    LET cCodRet = '00001'; -- datos vacios
	END IF;
	
		IF cCodRet = '00000' THEN
			LET cError_Desc = "Ejecucion SP exitosa";
		END IF;	
			
		RETURN cCodRet, cError_Desc, cChannel_Type, cChannel_Name, cChannel_Version, cFrs_Identifier, cFrs_Counter_Id, cTemplete_Id, cNo_reintentos, pUsuario, CURRENT:: DATETIME YEAR TO SECOND;

END;	
END PROCEDURE

DOCUMENT
'DESCRIPCION: SP invocado para recuperar los parámetros generales que se requieren en todos los mensajes a intercambiar con el WS-WU (money-transfer-search', 
              'money-transfer-select, money-transfer-pay, Pay Status, HeartBeat y catálogos DAS) obtenidos a partir de tablas centrales informix (bdisac).' ,  
'AUTOR: Christian Echavarria',			
'FECHA: 10/Jul/2013',
'DESCRIPCION: SP se modifica para que tome campos de la tabla sac_wu_identificadores y se le agrega un nuevo campo de retorno ' ,  
'AUTOR: Christian Echavarria',			
'FECHA: 11/SEPT/2013',
'DESCRIPCION: Se modifica sp para que valide que haya información en la tabla sac_wu_identificadores',  
'             para la sucursal y el usuario recibido', 
'AUTOR: Martha Aguirre',			
'FECHA: 02/OCT/2013',
' DESCRIPCION: Se modifica sp para actualizar tamaño del campo cFrs_Counter_Id a 13 pos.', 
' AUTOR: FRG',
' FECHA: 04/Abr/2014',
'BD: bdisac';

CREATE PROCEDURE  "informix".sp_graba_vtacam_seg(p_tramae CHAR(110), p_tramar CHAR(300))
RETURNING CHAR(5)   AS CodigoRetorno; 

--DEFINICION DE LAS VARIABLES
DEFINE iCodRet      	CHAR(5); 
DEFINE iSqlErr      	INTEGER; 

DEFINE i			INTEGER;
DEFINE iAux			CHAR(1);
DEFINE iAux2		INTEGER;
DEFINE iIni			INTEGER; 
DEFINE iSec			INTEGER;

DEFINE cClave		CHAR(1);
DEFINE cTipomovimiento	CHAR(1);
DEFINE cNumcliente 	CHAR(14);
DEFINE cPoliza		CHAR(15);
DEFINE cRecibo		CHAR(15);
DEFINE cImporte 		CHAR(15);
DEFINE cFecha 		CHAR(10);
DEFINE cSucursal 		CHAR(4);
DEFINE cCaja		CHAR(15);
DEFINE cArea		CHAR(15);
DEFINE cCiudad		CHAR(15);
DEFINE cEmpleadoefectuo CHAR(8);
DEFINE cMensaje		CHAR(100);
DEFINE cStatus 			CHAR(6);
DEFINE cCnxn_status 	CHAR(1);
DEFINE cCod_resp        CHAR(5); 
DEFINE iCont		INTEGER;

--INICIALIZACION DE LAS VARIABLES
LET iCodRet    		= '00000';
LET iSqlErr    		= 0; 

LET i				= 1;
LET iAux			= '';
LET iAux2			= 0;
LET cMensaje		= '';
LET iIni			= 0;
LET iSec			= 0;

LET cClave			= '';
LET cTipomovimiento	= '';
LET cNumcliente 	 	= '';
LET cPoliza			= '';
LET cRecibo			= '';
LET cImporte 		= '';
LET cFecha 			= '';
LET cSucursal 		= '';
LET cCaja			= '';
LET cArea			= '';
LET cCiudad			= '';
LET cEmpleadoefectuo 	= '';
LET cStatus 		= '000000';
LET cCnxn_status	 	='C';
LET cCod_resp		='00001';
LET iCont			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			RETURN iCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/vlv/sp_graba_vtacam_seg.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	-- SE DESARMA LA TRAMA DE ENVÍO PARA REALIZAR EL INSERT A LA SAC_CONS_SEG
	IF TRIM(NVL(p_tramae,'')) <> '' THEN
	   WHILE iAux2 <> 11
			 LET iAux = SUBSTR(p_tramae,i,1);
			 IF iAux = '|' THEN
				LET iAux2 = iAux2 + 1; 
					IF iAux2 = 1 THEN 
						LET cClave = SUBSTR(p_tramae,1,i -1);
						LET iIni = i + 1;
					ELIF iAux2 = 2 THEN				
						LET cTipomovimiento = SUBSTR(p_tramae,iIni,i-iIni);
						LET iIni = i + 1;
					ELIF iAux2 = 3 THEN				
						LET cNumcliente = SUBSTR(p_tramae,iIni,i-iIni);
						LET iIni = i + 1;
						LET cNumcliente = cNumcliente;	
					ELIF iAux2 = 4 THEN				
						LET cPoliza = SUBSTR(p_tramae,iIni,i-iIni);
						LET iIni = i + 1;
						LET cPoliza = cPoliza::INTEGER;					
					ELIF iAux2 = 5 THEN			
						LET cRecibo = SUBSTR(p_tramae,iIni,i-iIni);
						LET iIni = i + 1;
						LET cRecibo = cRecibo::INTEGER;	
					ELIF iAux2 = 6 THEN	
						LET cImporte = SUBSTR(p_tramae,iIni,i -iIni);
						LET iIni = i + 1;
						LET cImporte = TRIM(cImporte);
					ELIF iAux2 = 7 THEN					
						LET cFecha = SUBSTR(p_tramae,iIni,i -iIni);
						LET iIni = i + 1;
						LET cFecha = TRIM(cFecha);						
					ELIF iAux2 = 8 THEN				
						LET cSucursal = SUBSTR(p_tramae,iIni,i -iIni);
						LET iIni = i + 1;
						LET cSucursal = TRIM(cSucursal)::SMALLINT;
					ELIF iAux2 = 9 THEN										
						LET cCaja = SUBSTR(p_tramae,iIni,i -iIni);
						LET iIni = i + 1;
						LET cCaja = TRIM(cCaja)::INTEGER;
					ELIF iAux2 = 10 THEN										
						LET cArea = SUBSTR(p_tramae,iIni,i -iIni);
						LET iIni = i + 1;
						LET cArea = TRIM(cArea);
					ELIF iAux2 = 11 THEN										
						LET cCiudad = SUBSTR(p_tramae,iIni,i -iIni);
						LET iIni = i + 1;
						LET cCiudad = TRIM(cCiudad)::SMALLINT;
						
						LET cEmpleadoefectuo = SUBSTR(p_tramae,i+1,LENGTH(p_tramae));
						LET cEmpleadoefectuo = TRIM(cEmpleadoefectuo)::INTEGER;
					END IF;
			 END IF;
			 LET iAux = '';
			 LET i = i +1;
		END WHILE;

		LET iAux  = '';
		LET iAux2 = 0;
		LET iIni  = 0;
		LET iCont = 0;
		LET i = 0;

		IF TRIM(NVL(p_tramar,'')) <> '' THEN
			WHILE iAux2 <> 1
				LET iAux = SUBSTR(p_tramar,i,1);
				IF iAux = '|' THEN
					LET iAux2 = iAux2 + 1;
					IF iAux2 = 1 THEN
						LET cStatus = SUBSTR(p_tramar,1,iCont -1 );
						LET iIni = i + 1;
						LET cMensaje = SUBSTR(p_tramar,i + 1,LENGTH(p_tramar));
					END IF
				END IF;
				LET iCont = iCont+1;
				LET iAux = '';
				LET i = i +1;
			END WHILE;
		END IF;

		
		INSERT INTO "informix".sac_vta_cambio_seg (cnxn_status,clave,tipomovimiento,numcliente,poliza,recibo,importe,
		fecha,sucursal,ciudad,caja,area,empleadoefectuo,cod_resp,estatus,mensajes)
		VALUES (cCnxn_status,cClave,cTipomovimiento,cNumcliente,cPoliza,cRecibo,cImporte,cFecha,cSucursal,cCiudad,
		cCaja,cArea,cEmpleadoefectuo,cCod_resp,cStatus::SMALLINT,cMensaje);
	
	ELSE
		LET iCodRet = '00001';
	END IF;	
			
	RETURN iCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio: 1448',
'Autor: 94912599 ',
'Fecha: 10/07/2014',
'Descripción: Se crea procedimiento para grabar lo que se envía y su respuesta al vender o cambiar un seguro de CP',
'Sustento:RQI 62 038 VentaClubdeProteccionCppl-BCP_InterfacesCaja_v3',
'Solicita: Fermín Ramos',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_wu_recuperaparams_hb( pEmpresa CHAR(3), pUsuario CHAR(8), pMarca CHAR(2), pNombre CHAR(2),pFechahora_invoca DATETIME YEAR TO SECOND )

RETURNING CHAR(5) AS cod_err, CHAR(30) AS error_desc, CHAR(10) AS partner_id, CHAR(15) AS system_ip, CHAR(9) AS connector_id,
          CHAR(3) AS device_id, CHAR(6) AS device_type, CHAR(8) AS user_insert, CHAR(22) AS fechahora_insert;

--DEFINICION DE VARIABLES--		  
DEFINE iSqlErr	  		INTEGER;
DEFINE cCodRet	   		CHAR(5);
DEFINE cCodRetAux   	CHAR(5);
DEFINE cNombreSP    	CHAR(45);
DEFINE iIsamErr    		INTEGER;
DEFINE cSucursal    	CHAR(4);
DEFINE cPartner_id  	CHAR(10);
DEFINE cSystem_Ip   	CHAR(15);
DEFINE cConnector_id  	CHAR(9);
DEFINE cDevice_id  		CHAR(3);
DEFINE cDevice_type 	CHAR(6);
DEFINE cCadena_ent	   	CHAR(100);
DEFINE cError_Desc     	CHAR(30);
DEFINE cFechaProceso    DATETIME YEAR TO SECOND;

--INICIALIZACION DE VARIABLES--
LET	iSqlErr 		= 0;
LET	cCodRet			= '00000';
LET cCodRetAux		='00000';
LET cNombreSP		= 'sp_wu_recuperaparams_hb';
LET	iIsamErr 		= 0;
LET cSucursal 		= "";
LET cPartner_id 	="";
LET cSystem_Ip 		="";
LET cConnector_id	="";
LET cDevice_id 		="";
LET cDevice_type 	=""; 
LET cCadena_ent		= TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pMarca,'NULL'))||'|'||TRIM(NVL(pNombre,'NULL'));
LET cError_Desc 	="Error en el proceso";
LET cFechaProceso	= CURRENT::DATETIME YEAR TO SECOND;

      
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;			
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSqlErr,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
				INTO cCodRetAux;
                 
				IF cCodRetAux <> '00000' THEN
					LET cCodRet = cCodRetAux;
			    END IF 
		
				RETURN cCodRet, cError_Desc, cPartner_id, cSystem_Ip, cConnector_id, cDevice_id, cDevice_type, pUsuario, CURRENT:: DATETIME YEAR TO SECOND;
			END IF;
			
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/christian/sp_wu_recuperaparams_hb.out';
	--TRACE ON;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (2,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso)
	--INTO cCodRetAux;
	
	IF NVL(pEmpresa,"") <> "" AND NVL(pUsuario,"") <> "" AND NVL(pMarca,"") <> "" AND NVL(pNombre,"") <> "" AND NVL(pFechahora_invoca,"") <> "" THEN
		
		IF (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87054') = pMarca 
			OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87055') = pMarca 
			OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87056') = pMarca THEN
			
			IF pUsuario = "sys_wu" THEN
				LET cSucursal = '9250';
			ELSE
				
				SELECT sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
			END IF;

			IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN	
				SELECT account_number
				INTO cConnector_id
				FROM bdisac:"informix".sac_wu_identificadores 
				WHERE marca = pMarca AND sucursal = cSucursal AND empresa = pEmpresa;
										
				SELECT valor
				INTO cPartner_id
				FROM bdisac:"informix".sac_param 
				WHERE cod_param = '87067';  
				 
				SELECT valor
				INTO cSystem_Ip
				FROM bdisac:"informix".sac_param 
				WHERE cod_param = '87068'; 
				 
				SELECT valor
				INTO cDevice_id
				FROM bdisac:"informix".sac_param 
				WHERE cod_param = '87072'; 
				
				SELECT valor
				INTO cDevice_type
				FROM bdisac:"informix".sac_param 
				WHERE cod_param = '87073'; 
			
				IF cConnector_id IS NULL OR cConnector_id = '' THEN
					LET cCodRet = '00002'; 
					LET cError_Desc	= 'Usuario no tiene Id. Asignado';
				END IF;
				
			ELSE
				LET	cCodRet = '00002'; --- Usuario no se encuentra
				LET cError_Desc	= 'NO EXISTE USUARIO';
			END IF;
		ELSE
			LET	cCodRet = '00002'; --- Marca Inválida
			LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';
		END IF;		
					  -- cCodRet = 00000 CONTINUA CON EL FLUJO
			
	ELSE
	    LET cCodRet = '00001'; -- datos vacios
	END IF;
/*	
	IF  cCodRet <> '00000' THEN

		--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSqlErr,iIsamErr,cCadena_ent,pUsuario,cFechaProceso)
		--INTO cCodRetAux;
		
		IF cCodRetAux <> '00000' THEN
			LET cCodRet = cCodRetAux;
		END IF
		  
		RETURN cCodRet, cError_Desc, cPartner_id, cSystem_Ip, cConnector_id, cDevice_id, cDevice_type, pUsuario, CURRENT:: DATETIME YEAR TO SECOND;		
	ELSE	
		--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (3,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
		--INTO cCodRetAux;	
		
		IF cCodRetAux <> '00000' THEN
			LET cCodRet = cCodRetAux;
		END IF
	
		IF cCodRet = '00000' THEN
			LET cError_Desc = "Ejecucion SP exitosa";
		END IF;	
		
		RETURN cCodRet, cError_Desc, cPartner_id, cSystem_Ip, cConnector_id, cDevice_id, cDevice_type, pUsuario, CURRENT:: DATETIME YEAR TO SECOND;
	END IF;
*/	

		IF cCodRet = '00000' THEN
			LET cError_Desc = "Ejecucion SP exitosa";
		END IF;		
		RETURN cCodRet, cError_Desc, cPartner_id, cSystem_Ip, cConnector_id, cDevice_id, cDevice_type, pUsuario, CURRENT:: DATETIME YEAR TO SECOND;
	
END;	
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para consulta la tabla de parámetros de la base de datos bdisac (bdisac:sac_param) los valores fijos para el armado de una transacción heartbeat',
'             a enviar al WS-WU. Estos valores son los mismos que se usan para cualquiera de las 3 marcas (WU-OV-VG), esto quiere decir, que el mensaje Hearbeat es el mismo.',  
'AUTOR: Christian Echavarria',			
'FECHA: 12/Jul/2013',
'DESCRIPCION: Se modifica sp para que valide que haya información en la tabla sac_wu_identificadores',  
'              para la sucursal y el usuario recibido', 
'AUTOR: Martha Aguirre',			
'FECHA: 02/OCT/2013',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_hb
(
 pEmpresa 		CHAR(3),
 pUsuario		CHAR(8), 
 pPartnerId 	CHAR(10), 
 pSystemIp 		CHAR(15), 
 pConnectorId 	CHAR(9), 
 pDeviceId 		CHAR(3),
 pDeviceType 	CHAR(6),
 pFechaHoraRq 	DATETIME YEAR TO SECOND, 
 pRetCode 		CHAR(5),
 pStatusMsj 	CHAR(20),
 pDescError 	CHAR(250),
 pPartnerldErr 	CHAR(10),
 pFechaHoraRP 	DATETIME YEAR TO SECOND,
 pUserInsert 	CHAR(8),
 pFechaInsert 	DATETIME YEAR TO SECOND
)

RETURNING CHAR(5) AS cod_err, CHAR(30) AS error_desc;

--DEFINICION DE VARIABLES--
    DEFINE	iSql_Err		INTEGER;
	DEFINE 	iIsamErr		INTEGER;
    DEFINE	cCodRet			CHAR(5);
	DEFINE	cCodRetAux		CHAR(5);
	DEFINE	cTxnStatus		CHAR(1);
	DEFINE	cNombreSP		CHAR(45);
	DEFINE 	cCadena_ent		CHAR(100);
	DEFINE cError_Desc  	CHAR(30);
	DEFINE cFechaProceso	DATETIME YEAR TO SECOND;
	DEFINE cStatus 			CHAR(1);
	
--INICIALIZACION DE VARIABLES--
    LET	iSql_Err		= 0;
	LET	iIsamErr 		= 0;
    LET cCodRet			= '00000';
	LET cCodRetAux		= '00000';
	LET cTxnStatus		= 'C';
	LET	cNombreSP		= 'sp_sac_wu_guardarespuesta_hb';
	LET cCadena_ent		=  TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pPartnerId,'NULL'))||'|'||TRIM(NVL(pConnectorId,'NULL'));
	LET cError_Desc 	="Error en el proceso";
	LET cFechaProceso	= CURRENT::DATETIME YEAR TO SECOND;
	LET cStatus 		= '2';


BEGIN
	ON EXCEPTION SET iSql_Err, iIsamErr
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
			LET cStatus = '1';

--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
				LET cTxnStatus		 = 'C';
--	2014.11.11 FRG-f

			INSERT INTO bdisac:"informix".sac_wu_heartbeat	 
						(txn_status, partner_id, system_ipadds, connector_id, device_id, device_type, fecha_hora_rq, retcode, status_message, 
						 desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert)
						
				  VALUES(cTxnStatus, pPartnerId, pSystemIp, pConnectorId, pDeviceId, pDeviceType, pFechaHoraRq, pRetCode, pStatusMsj,
				         pDescError, pPartnerldErr, pFechaHoraRP, pUserInsert, current);
					 
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cNombreSP,cCodRet,'',iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso)
			INTO cCodRetAux;
			
			IF cCodRetAux <> '00000' THEN
			   LET cCodRet = cCodRetAux;
		    END IF
			
			RETURN cCodRet,cError_Desc;
        END IF;
		
		
    END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_hb.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	/*	EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
	INTO cCodRetAux;
	
	
	IF cCodRetAux <> '00000' OR pRetCode <> '00000' THEN
		LET	cTxnStatus	= 'C';
		LET cStatus = '1';
		LET cCodret = '00001';
	ELSE
		LET	cTxnStatus	= 'A';
		LET cStatus ='3';
	END IF */

--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
			LET	cTxnStatus	= 'A';
--	2014.11.11 FRG-f
	
	INSERT INTO bdisac:"informix".sac_wu_heartbeat	
						(txn_status, partner_id, system_ipadds, connector_id, device_id, device_type, fecha_hora_rq, retcode, status_message, 
						 desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert)
						
				  VALUES(cTxnStatus, pPartnerId, pSystemIp, pConnectorId, pDeviceId, pDeviceType, pFechaHoraRq, pRetCode, pStatusMsj,
				         pDescError, pPartnerldErr, pFechaHoraRP, pUserInsert, current);
					   
    /*IF  cCodret <> '00000' THEN
	
		--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cNombreSP,cCodret,cError_Desc,iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
        --INTO cCodRetAux;
		IF cCodRetAux <> '00000' THEN
			LET cCodret = cCodRetAux;
		END IF
		  
		RETURN  cCodret, cError_Desc;
	ELSE	
		--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (cStatus,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
		--INTO cCodRetAux;	
		
		IF cCodRetAux <> '00000' THEN
			LET cCodret = cCodRetAux;
		END IF
		
		IF cCodRet = '00000' THEN
			LET cError_Desc = "Ejecucion SP exitosa";
		END IF;	
		RETURN  cCodret, cError_Desc;
    END IF;	*/

    IF cCodRet = '00000' THEN
		LET cError_Desc = "Ejecucion SP exitosa";
	END IF;	
	RETURN  cCodret, cError_Desc;

END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje <esp-heartbeat> (request-reply) en la tabla bdisac:sac_wu_heartbeat' ,  
'AUTOR: Christian Echavarria',			
'FECHA: 12/Jul/2013',
' DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',
' MODIFICO : FRG',
' FECHA : 2014/07/30',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sacreporteconciliacionconveniosucursal(cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE)

-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno, --Codigo de Retorno
CHAR(4) AS id_sucursal, INTEGER AS numpagos, CHAR(40) AS nomconvenio, MONEY(16,2) AS importe_pago, MONEY(16,2) AS importe_comision_convenio, MONEY(16,2) AS iva_comision_convenio, MONEY(16,2) AS importe_comision_cte,
MONEY(16,2) AS iva_comision_cte, INTEGER AS flag_confirmacion_central, INTEGER AS flag_confirmacion_sucursal;


-- DEFINICION DE VARIABLES
DEFINE cCodRet                  CHAR(5);
DEFINE iSqlErr                  INTEGER;
DEFINE cNumcategoria            CHAR(2);
DEFINE cIdSucursal              CHAR(4);
DEFINE cNumconvenio             CHAR(3);
DEFINE cNomconvenio             CHAR(40);
DEFINE mImpComisionConvenio    MONEY(16,2);
DEFINE mIVAComisionConvenio    MONEY(16,2);
DEFINE mImpComisionCte         MONEY(16,2);
DEFINE mIVAComisionCte         MONEY(16,2);
DEFINE mImportePago            MONEY(16,2);
DEFINE iConfirmacionCentral     INTEGER;
DEFINE iConfirmacionSucursal    INTEGER;
DEFINE iNumPagos                INTEGER;
DEFINE dFechaTabla			DATE;

--SET DEBUG FILE TO '/informix/adrian/sp_sacreporteconciliacionconveniosucursal_aia.out';
--TRACE ON;

--INICIALIZACION DE VARIABLES--
LET cCodRet               = "00000";
LET cNumcategoria         = SUBSTRING(cConvenio FROM 1 FOR 2);
LET cNumconvenio          = SUBSTRING(cConvenio FROM 3 FOR 3);
LET cIdSucursal           = "";
LET cNomConvenio          = "";
LET mImportePago         = 0;
LET mImpComisionConvenio = 0;
LET mIVAComisionConvenio = 0;
LET mImpComisionCte      = 0;
LET mIVAComisionCte      = 0;
LET iConfirmacionCentral  = 0;
LET iConfirmacionSucursal = 0;
LET iNumPagos             = 0;
LET dFechaTabla			= '';

BEGIN

    ON EXCEPTION SET iSqlErr

        IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
        END IF;

    END EXCEPTION;
	
	SELECT MIN (fecha_pago)
	INTO dFechaTabla
	FROM bdisac:"informix".sac_conciliaciontotalporconvenio;

    IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
    ELSE
		IF (dFechaIni>=dFechaTabla) THEN --Nuevo Proceso utilizando la tabla sac_conciliaciontotalporconvenio
			IF cConvenio = "00000" THEN      -- Todos los convenios
				IF cSucursal = "0000"  THEN   -- Todos los convenios y todas las sucursales
					FOREACH
						SELECT numcategoria, numconvenio 
						INTO cNumcategoria, cNumconvenio
						FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio					
						FOREACH
							SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
							SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
							SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_conciliaciontotalporconvenio
							WHERE fecha_pago::DATE  >= dFechaIni
							AND fecha_pago::DATE  <= dFechaFin
							AND numcategoria = cNumcategoria
							AND numconvenio = cNumconvenio
							GROUP BY nomconvenio, id_sucursal
							ORDER BY 2,1

							RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH;
					END FOREACH;
				ELSE   --Todos los convenios y una sucursal
					FOREACH
						SELECT numcategoria, numconvenio 
						INTO cNumcategoria, cNumconvenio
						FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
						FOREACH
							SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
							SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
							SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_conciliaciontotalporconvenio
							WHERE fecha_pago::DATE  >= dFechaIni
							AND fecha_pago::DATE  <= dFechaFin
							AND id_sucursal = cSucursal
							AND numcategoria = cNumcategoria
							AND numconvenio = cNumconvenio
							GROUP BY nomconvenio, id_sucursal
							ORDER BY 2,1

							RETURN cCodRet, cIdSucursal, iNumPagos,  cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH
					END FOREACH;
				END IF;
			ELSE
				IF cSucursal = "0000"  THEN   -- Un convenio y todas las sucursales
					FOREACH
						SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
						SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
						SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_conciliaciontotalporconvenio
						WHERE fecha_pago::DATE  >= dFechaIni
						AND fecha_pago::DATE  <= dFechaFin
						AND numcategoria = cNumcategoria
						AND numconvenio = cNumconvenio
						GROUP BY nomconvenio, id_sucursal
						ORDER BY 2,1

						RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						WITH RESUME;
					END FOREACH;
				ELSE   --Un convenio y una sucursal
					FOREACH
						SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
						SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
						SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_conciliaciontotalporconvenio
						WHERE fecha_pago::DATE  >= dFechaIni
						AND fecha_pago::DATE  <= dFechaFin
						AND numcategoria = cNumcategoria
						AND numconvenio = cNumconvenio
						AND id_sucursal = cSucursal
						GROUP BY nomconvenio,id_sucursal					
					
					END FOREACH;
					
					RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;

				END IF;

			END IF;
		ELSE --Proceso anterior consultando los movimiento
		
			IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
			ELSE
				IF cConvenio = "00000" THEN      -- Todos los convenios
					IF cSucursal = "0000"  THEN   -- Todos los convenios y todas las sucursales
						FOREACH
							SELECT numcategoria, numconvenio 
							INTO cNumcategoria, cNumconvenio
							FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
							FOREACH
								SELECT TRIM(b.id_sucursal),TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
								SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
								SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
								INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
								WHERE b.fecha_pago::DATE  >= dFechaIni
								AND b.fecha_pago::DATE  <= dFechaFin
								AND a.numcategoria = b.numcategoria
								AND a.numconvenio = b.numconvenio
								AND b.numcategoria = cNumcategoria
								AND b.numconvenio = cNumconvenio
								AND b.status_cancelado <> 'S'
								AND flag_confirmacion_central = 1
								AND flag_confirmacion_sucursal = 1
								GROUP BY a.nomconvenio, b.id_sucursal
								ORDER BY 2,1

								RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								WITH RESUME;

							END FOREACH;
						END FOREACH;
					ELSE   --Todos los convenios y una sucursal
						FOREACH
							SELECT numcategoria, numconvenio 
							INTO cNumcategoria, cNumconvenio
							FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
							FOREACH
								SELECT TRIM(b.id_sucursal)AS id_sucursal, TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
								SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
								SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
								INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
								WHERE b.fecha_pago::DATE  >= dFechaIni
								AND b.fecha_pago::DATE  <= dFechaFin
								AND a.numcategoria = b.numcategoria
								AND a.numconvenio = b.numconvenio
								AND b.numcategoria = cNumcategoria
								AND b.numconvenio = cNumconvenio
								AND b.id_sucursal = cSucursal
								AND b.status_cancelado <> 'S'
								AND flag_confirmacion_central = 1
								AND flag_confirmacion_sucursal = 1
								GROUP BY a.nomconvenio, b.id_sucursal
								ORDER BY 2, 1

								RETURN cCodRet, cIdSucursal, iNumPagos,  cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								WITH RESUME;
							END FOREACH
						END FOREACH;
					END IF;
				ELSE
					IF cSucursal = "0000"  THEN   -- Un convenio y todas las sucursales
						FOREACH
							SELECT TRIM(b.id_sucursal), TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
							SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
							SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
							WHERE b.fecha_pago::DATE  >= dFechaIni
							AND b.fecha_pago::DATE  <= dFechaFin
							AND b.numcategoria = cNumcategoria
							AND b.numconvenio = cNumconvenio
							AND b.status_cancelado <> 'S'
							AND a.numcategoria = b.numcategoria
							AND a.numconvenio = b.numconvenio
							AND flag_confirmacion_central = 1
							AND flag_confirmacion_sucursal = 1
							GROUP BY a.nomconvenio, b.id_sucursal
							ORDER BY 2, 1

							RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH;
					ELSE   --Un convenio y una sucursal
						SELECT TRIM(b.id_sucursal), TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
						SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
						SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio , iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
						WHERE b.fecha_pago::DATE  >= dFechaIni
						AND b.fecha_pago::DATE  <= dFechaFin
						AND b.numcategoria = cNumcategoria
						AND b.numconvenio = cNumconvenio
						AND b.status_cancelado <> 'S'
						AND a.numcategoria = b.numcategoria
						AND a.numconvenio = b.numconvenio
						AND b.id_sucursal = cSucursal
						AND flag_confirmacion_central = 1
						AND flag_confirmacion_sucursal = 1
						GROUP BY a.nomconvenio, b.id_sucursal;

						RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;

					END IF;

				END IF;

			END IF;
		
		END IF;

    END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener los totales captados por convenio en un rango de fechas especificas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080905',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_search
(
pEmpresa				CHAR(3), 
pUsuario				CHAR(8),
pMarca					CHAR(2),
pForeignRsRefNumRq    	CHAR(16),
pMtcn              	    CHAR(10),
pFechaHoraRq       	    DATETIME YEAR TO SECOND,
pRetCode         		CHAR(5),
pEmisorNameType     	CHAR(1),
pEmisorNombre1          CHAR(40),
pEmisorNombre2          CHAR(40),
pEmisorApPaterno    	CHAR(40),
pEmisorApMaterno    	CHAR(40),
pEmisorCiudad       	CHAR(20),
pEmisorEdo          	CHAR(40),
pEmisorCodPais      	CHAR(3),
pEmisorCodMoneda    	CHAR(3),
pEmisorCp           	CHAR(8), 
pEmisorCalle        	CHAR(30), 
pEmisorTel          	CHAR(15), 
pBenefNameType 			CHAR(1),
pBenefNombre1           CHAR(40),
pBenefNombre2           CHAR(40),
pBenefApaterno      	CHAR(40), 
pBenefAmaterno      	CHAR(40),
pBenefCiudad        	CHAR(20), 
pBenefEdo           	CHAR(40), 
pBenefCodPais       	CHAR(3),
pBenefCodMoneda     	CHAR(3), 
pBenefCp            	CHAR(8), 
pBenefCalle         	CHAR(30), 
pBenefTelPart       	CHAR(15),
pBenefTelCel       		CHAR(10), 
pMontoTotalOrigen  		CHAR(10),
pMontoToTDestino    	CHAR(10),
pMontoOrigen        	CHAR(10),
pMontoCargos        	CHAR(10), 
pCdOrigenPago       	CHAR(30), 
pTipoCambio         	CHAR(10),
pFechaAltaRemesa    	CHAR(8),
pHoraAltaRemesa     	CHAR(16), 
pMoneyTransKey      	CHAR(10),
pEstatusRemesa      	CHAR(4), 
pNewMtcn            	CHAR(16),
pFusionStatus       	CHAR(4),
pNoPaginas          	CHAR(2),
pPaginaActual       	CHAR(2), 
pNumCoincidencias   	CHAR(2), 
pForeignRsSystemIdRp  	CHAR(11), 
pForeignRsRefNumRp      CHAR(16), 
pForeingRsCantIdRp      CHAR(11),
pDescError              CHAR(250),
pPartnerIdErr           CHAR(10), 
pFechaHoraRp            DATETIME YEAR TO SECOND, 
pUserInsert             CHAR(8), 
pFechaInsert            DATETIME YEAR TO SECOND
)

RETURNING CHAR(5) AS cod_err, CHAR(30) AS error_desc;

--DEFINICION DE VARIABLES--
    DEFINE	iSql_Err		INTEGER;
	DEFINE 	iIsamErr		INTEGER;
    DEFINE	cCodRet			CHAR(5);
	DEFINE  cRetCode		CHAR(5);
	DEFINE  cDesc_Error		CHAR(250);
	DEFINE	cCodRetAux		CHAR(5);
	DEFINE	cTxnStatus		CHAR(1);
	DEFINE	cNombreSP		CHAR(45);
	DEFINE 	cCadena_ent		CHAR(100);
	DEFINE cError_Desc  	CHAR(30);
	DEFINE cChannelType 	CHAR(3);
    DEFINE cChannelName 	CHAR(3); 
    DEFINE cChannelVersion	CHAR(4);  
    DEFINE cForeignSystemId	CHAR(11); 
	DEFINE cForeignRsCntRq  CHAR(11);
	DEFINE cFechaProceso    DATETIME YEAR TO SECOND;
	DEFINE cStatus			CHAR(1);
	DEFINE cNumconvenio		CHAR(3);
	DEFINE cSucursal		CHAR(4);
	
--INICIALIZACION DE VARIABLES--
    LET	iSql_Err		 = 0;
	LET	iIsamErr 		 = 0;
    LET cCodRet			 = '00000';
	LET cRetCode		 = '00000';
	LET cDesc_Error		 = "";
	LET cCodRetAux		 = '00000';
	LET cTxnStatus		 = 'C';
	LET	cNombreSP		 = 'sp_sac_wu_guardarespuesta_search';
	LET cCadena_ent		 =  TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pForeignRsSystemIdRp,'NULL'))||'|'||TRIM(NVL(pMtcn,'NULL'));
	LET cError_Desc	     = "Error en el proceso";
	LET cChannelType 	 ="";	
    LET cChannelName 	 ="";	 
    LET cChannelVersion	 ="";  
    LET cForeignSystemId =""; 
	LET cForeignRsCntRq  ="" ;
	LET cFechaProceso	 = CURRENT::DATETIME YEAR TO SECOND;
	LET cStatus		     ="";
	LET cNumconvenio     ="";
	LET cSucursal 			="";
	
--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_search.out';
--	TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
BEGIN
	ON EXCEPTION SET iSql_Err, iIsamErr
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
			
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
				INTO cCodRetAux;
				
				IF cCodRetAux <> '00000' THEN
			       LET cCodRet = cCodRetAux;
		        END IF
--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
				LET cTxnStatus		 = 'C';
--	2014.11.11 FRG-f

					INSERT INTO bdisac:"informix".sac_wu_search	 
							(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,mtcn,fecha_hora_rq,
							 retcode,emisor_nametype,emisor_nombre1,emisor_nombre2,emisor_appaterno,emisor_apmaterno,emisor_ciudad,emisor_edo,emisor_cod_pais,
							 emisor_cod_moneda,emisor_cp,emisor_calle,emisor_telefono,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,
							 benef_ciudad,benef_edo,benef_cod_pais,benef_cod_moneda,benef_cp,benef_calle,benef_tel_part,benef_tel_celular,monto_total_origen,
							 monto_total_destino,monto_origen,monto_cargos,cd_origen_pago,tipo_cambio,fecha_alta_remesa,hora_alta_remesa,money_transfer_key,
							 estatus_remesa,new_mtcn,fusion_status,no_paginas,pagina_actual,num_coincidencias,foreign_rs_system_id_rp,foreign_rs_refnum_rp,
							 foreign_rs_cntid_rp,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert)
							
					  VALUES(cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignSystemId,pForeignRsRefNumRq,cForeignRsCntRq,pMtcn,pFechaHoraRq,pRetCode,pEmisorNameType,
							 pEmisorNombre1,pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,
							 pEmisorTel,pBenefNameType,pBenefNombre1,pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,
							 pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,
							 pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,pNumCoincidencias,
							 pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,pFechaHoraRp,pUserInsert,current);
				
				RETURN cCodRet,cError_Desc;
        END IF;
		
    END EXCEPTION;

	/*	
	--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (2,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso)  
	--INTO cCodRetAux;
	
	IF cCodRetAux <> '00000' OR pRetCode <> '00000' THEN
		LET	cTxnStatus	= 'C';		
		LET cCodRet = '00001';
	ELSE
		LET	cTxnStatus	= 'A';
	END IF
	*/
	IF pRetCode = '504' THEN
	    LET cRetCode = '99999';
		LET pDescError = 'Aplicativo WU no activo, validar';
	END  IF;
	
	IF pRetCode <>  '504' AND pRetCode <> '00000' AND pRetCode <> '66666'  THEN		
		LET cRetCode = '99998';
		LET pDescError = 'Sin respuesta del aplicativo, validar';
	END IF
	IF pRetCode = '66666' THEN
		LET cDesc_Error = pDescError;
		LET cRetCode = pRetCode;
	END IF
	
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
		IF (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87054') = pMarca
		OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87055') = pMarca
		OR (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param ='87056') = pMarca THEN
				IF pUsuario = "sys_wu" THEN
					LET cSucursal = '9250';
				ELSE
					SELECT sucursal
					INTO cSucursal
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
				END IF;
				IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN
					SELECT fsid ,counter_id
					INTO cForeignSystemId ,cForeignRsCntRq
					FROM bdisac:"informix".sac_wu_identificadores
					WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = cSucursal;

					IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
						LET cCodRet = '00027';
						LET cError_Desc	= 'Usuario no tiene Id. Asignado';						
					END IF;
				ELSE
					LET	cCodRet = '00026'; --- Usuario no se encuentra
					LET cError_Desc	= 'NO EXISTE USUARIO';
			   END IF;
		ELSE
			LET	cCodRet = '00003'; --- Marca Inválida
			LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';			
		END IF;
  
			SELECT valor
			INTO cChannelType
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87050';  
			 
			SELECT valor
			INTO cChannelName
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87051'; 
			 
			SELECT valor
			INTO cChannelVersion
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87052'; 
																		
--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
			LET	cTxnStatus	= 'A';
--	2014.11.11 FRG-f

	INSERT INTO bdisac:"informix".sac_wu_search	
						(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,mtcn,fecha_hora_rq,
						 retcode,emisor_nametype,emisor_nombre1,emisor_nombre2,emisor_appaterno,emisor_apmaterno,emisor_ciudad,emisor_edo,emisor_cod_pais,
						 emisor_cod_moneda,emisor_cp,emisor_calle,emisor_telefono,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,
						 benef_ciudad,benef_edo,benef_cod_pais,benef_cod_moneda,benef_cp,benef_calle,benef_tel_part,benef_tel_celular,monto_total_origen,
						 monto_total_destino,monto_origen,monto_cargos,cd_origen_pago,tipo_cambio,fecha_alta_remesa,hora_alta_remesa,money_transfer_key,
						 estatus_remesa,new_mtcn,fusion_status,no_paginas,pagina_actual,num_coincidencias,foreign_rs_system_id_rp,foreign_rs_refnum_rp,
						 foreign_rs_cntid_rp,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert)
						
				  VALUES(cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignSystemId,pForeignRsRefNumRq,cForeignRsCntRq,pMtcn,pFechaHoraRq,cRetCode,pEmisorNameType,
				         pEmisorNombre1,pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,
                         pEmisorTel,pBenefNameType,pBenefNombre1,pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,
						 pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,
						 pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,pNumCoincidencias,
						 pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,pFechaHoraRp,pUserInsert,current);
						 
		SELECT status_cancelado 
		INTO cStatus 
		FROM bdisac:sac_movimientos 
		WHERE numcategoria = '07' AND numconvenio = cNumconvenio 
		AND referencia1 = pMtcn
		AND flag_confirmacion_sucursal = '0'
		AND status_cancelado = 'N' ;

		IF cStatus ='N' AND pFusionStatus = 'W/C' THEN -- Si encontró un intento de pago previo y no ha sido reversado			   
			   LET cCodRet = '00023'; -- Se tiene que reversar primero antes de intentar el pago nuevamente
		END IF;

		IF  cCodRet <> '00000' THEN	
		    --EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,cDesc_Error,iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
		    --INTO cCodRetAux;
			
			IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
				RETURN cCodRet,cError_Desc;	
			END IF;
            
			
/*			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
*/
			IF cCodRet <>  '00023'  THEN		
				LET cCodRet = '00001';
			END IF;
            RETURN cCodRet,cError_Desc;		
	    ELSE	
/*
		    --EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (3,cNombreSP,'','','','',cCadena_ent,pUsuario,cFechaProceso) 
	        --INTO cCodRetAux;	
			
			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF;
*/		
			IF cCodRet = '00000' THEN
				LET cError_Desc = "Ejecucion SP exitosa";
			END IF;	
			
           RETURN cCodRet,cError_Desc;
	    END IF;	
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje <receive-money-search> (request-reply) en la tabla bdisac:sac_wu_search',  
'AUTOR: Christian Echavarria',			
'FECHA: 15/Jul/2013',
'DESCRIPCION: Se modifica para que consulte los campos counter_id y  fsid de sac_wu_identificadores',  
'AUTOR: Mario Gallardo',			
'FECHA: 03/10/2013',
'DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
'AUTOR: FRG',
'FECHA: 30/Jul/2014',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_bts_recuperacdep_pba(pcUsuario CHAR(8), piRegs_recup INTEGER, pcFecha_peticion CHAR(8), pcHora_peticion CHAR(6))
	RETURNING CHAR(5),CHAR(11),CHAR(4),CHAR(8),CHAR(6);

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(4);
DEFINE cConfirmation_nm CHAR(11);
DEFINE cOpcode_cdep 	CHAR(4);
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE cNombre_preceso	CHAR(19);
DEFINE cCadena_ent		CHAR(100);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE cCod_retorno		CHAR(5);

DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;
DEFINE cValor			CHAR(100);

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err = '0000';
LET cConfirmation_nm = '';
LET cOpcode_cdep = '0000';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cNombre_preceso = 'sp_bts_recuperacdep';
LET cCadena_ent = 	NVL(piRegs_recup,0) || '|' || TRIM(NVL(pcFecha_peticion,'NULL')) || '|' || TRIM(NVL(pcHora_peticion,'NULL'));
LET cOpcode 		= '';
LET cDescr_mensaje 	= '';
LET cCod_retorno 	= '';
LET cValor	 		= '';

LET cFecha_dia = '';
LET dtFecha_dia = CURRENT::DATE;

--SET DEBUG FILE TO '/tmp/RMBTS/sp_bts_recuperacdep.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError
		IF iSqlErr <> 0 THEN
			LET cCod_err = iSqlErr;			
			LET cDescr_mensaje = '';
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
			INTO cCod_retorno;
			
			RETURN cCod_err,cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Se inserta el registro del proceso en curso
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombre_preceso,pcFecha_peticion,pcHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);
	
	IF piRegs_recup > 0 THEN

		SELECT NVL(valor,'0')
			INTO cValor
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87013';	
			
			FOREACH
				SELECT LIMIT piRegs_recup num_confirmacion
					INTO cConfirmation_nm
					FROM bdisac:"informix".sac_bts_sdep 
					WHERE estatus_sdep = '01'					
--					WHERE estatus_sdep = 'XX'										
						AND intentos_envio <= cValor
				
				RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso WITH RESUME;
			END FOREACH;
			
			 IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_err = '9984';

					--Se obtienen los mensajes de error asi como el codigo del mensaje
				SELECT NVL(opcode, ''),NVL(opcode_sd, '')
					INTO cOpcode,cDescr_mensaje 
					FROM bdisac:"informix".sac_bts_catmensajes WHERE agent_trans_type_code = 'CDEP' AND opcode = cCod_err;
					
				--En caso de que no exista el codigo del mensaje se les asigna otros valores
				IF cOpcode IS NULL THEN			
					LET cDescr_mensaje = 'Código no registrado en catálogo.';			
				END IF;

				-- En caso de que existan registros que fueron bloqueados temporalmente estatus_sdep='08', se regresan a '01'
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET estatus_sdep = '01'
				WHERE estatus_sdep = '08';							
					
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
					INTO cCod_retorno;

				RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)		
			INTO cCod_retorno;
			
/*		ELSE
			LET cCod_err = '9986';
		END IF;*/
	ELSE
		LET cCod_err = '9001';
	END IF;
	
	IF cCod_err <> '0000' THEN		
		
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, '')
		INTO cOpcode,cDescr_mensaje 
		FROM bdisac:"informix".sac_bts_catmensajes WHERE agent_trans_type_code = 'CDEP' AND opcode = cCod_err;
	
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN			
			LET cDescr_mensaje = 'Código no registrado en catálogo.';			
		END IF;
		
		--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)		
		INTO cCod_retorno;		
		
		RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
	END IF;		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Regresa un numero determinado de registros guadado0s de forma exitosa',
'AUTOR : José Luís Polanco B.',
'FECHA : 05 de Noviembre de 2012',
'VERSION: 1.0',
'BD: BDISAC',
'SISTEMA : Sistema Administrador de Convenios';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_pay 
(
	pEmpresa			CHAR(3), 
	pMarca              CHAR(2),
	pUsuario			CHAR(8),  
	pBenefNameType 		CHAR(1), 
	pBenefNombreUno		CHAR(40), 
	pBenefNombreDos		CHAR(40), 
	pBenefApaterno		CHAR(40), 
	pBenefAmaterno		CHAR(40), 
	pBenefCiudad 		CHAR(24),-- se adapta a la longitud del campo benef_ciudad  
	pBenefEdo  			CHAR(40), 
	pBeneCP				CHAR(9),-- se adapta a la longitud del campo benef_cp
	pBenefIdType  		CHAR(1), 
	pBenefIdPaisExpedi	CHAR(45), 
	pBenefIdNumber  	CHAR(20), 
	pBenefTieneFechVenc	CHAR(1), 
	pBenefFechaVenc  	CHAR(8),
	pBenefFechNac  		CHAR(8), 
	pBenefOcupacion  	CHAR(30), 
	pBenefCalleNum  	CHAR(40), 
	pBenefColDelMun  	CHAR(40), 
	pBenefPais  		CHAR(45), 
	pBenefTelPart 		CHAR(20), -- se adapta a la longitud del campo benef_tel_particular 
	pBenefTelCel  		CHAR(20), -- se adapta a la longitud del campo benef_tel_celular 
	pBenefEmail  		CHAR(40), 
	pBenefPaisNac  		CHAR(2), 
	pBenefNacionalidad 	CHAR(15), 
	pBenefSexo  		CHAR(1), 
	pBenefCiudadNac		CHAR(20), 
	pBenefEdoNac		CHAR(20), 
	pBenefCodPais		CHAR(3), 
	pBenefCodMoneda		CHAR(3), 
	pMontoOrigen		CHAR(10), 
	pMontoDestino		CHAR(10), 
	pMoneyTransferKey	CHAR(10), 
	pNewMtcn			CHAR(16), 
	pMtcn				CHAR(10), 
	pConfPago			CHAR(1), 
	pForeignRefNumRq	CHAR(16), 
	pFechaHrRq			DATETIME YEAR TO SECOND, 
	pRetCode			CHAR(5), 
	pDatosBufer			CHAR(500), 
	pMtcnRp				CHAR(10), 
	pPuntosGanados		CHAR(4), 
	pWuFechaPago		CHAR(16), 
	pForeignSystemIdRp	CHAR(11), 
	pForeingRefNumRp	CHAR(16), 
	pForeignRsCantIdRp	CHAR(11), 
	pDesError			CHAR(250), 
	pPartnerIdErr		CHAR(10), 
	pFechaHoraRp		DATETIME YEAR TO SECOND, 
	pUserInsert			CHAR(8), 
	pFechaInsert		DATETIME YEAR TO SECOND
)

RETURNING  CHAR(5) AS cod_err, CHAR(30) AS error_desc;

	--DEFINICION DE VARIABLES--
    DEFINE	iSqlErr				INTEGER;
	DEFINE 	iIsamErr			INTEGER;
    DEFINE	cCodRet				CHAR(5);
	DEFINE  cRetCode			CHAR(5);
	DEFINE  cDesc_Error         CHAR(250);
	DEFINE	cCodRetAux			CHAR(5);
	DEFINE	cTxnStatus			CHAR(1);
	DEFINE	cNombreSP			CHAR(45);
	DEFINE 	cCadena_ent			CHAR(100);
	DEFINE cError_Desc  		CHAR(30);
	DEFINE cFechaProceso    	DATETIME YEAR TO SECOND;
	DEFINE cChannelType 		CHAR(3);
    DEFINE cChannelName 		CHAR(3); 
    DEFINE cChannelVersion		CHAR(4);
	DEFINE cForeignSystemId		CHAR(11); 
	DEFINE cForeignRsCntRq  	CHAR(11);
	DEFINE cTemplateId          CHAR(10);
	DEFINE cSucursal		CHAR(4);
	
	--INICIALIZACION DE VARIABLES--
    LET	iSqlErr				= 0;
	LET	iIsamErr 			= 0;
    LET cCodRet				= '00000';
	LET cRetCode			= '00000';
	LET cDesc_Error			= "";
	LET cCodRetAux			= '00000';
	LET cTxnStatus			= 'C';
	LET	cNombreSP			= 'sp_sac_wu_guardarespuesta_pay';
	LET cCadena_ent			= TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pMoneyTransferKey,'NULL'))||'|'||TRIM(NVL(pNewMtcn,'NULL'));
    LET cError_Desc 		= "Error en el proceso";
	LET cFechaProceso		=  CURRENT::DATETIME YEAR TO SECOND;
	LET cChannelType 	 	= "";	
    LET cChannelName 	 	= "";	 
    LET cChannelVersion	 	= "";
	LET cForeignSystemId 	= ""; 
	LET cForeignRsCntRq  	= "" ;
	LET cTemplateId			= "";
	LET cSucursal 			= "";

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;

			EXECUTE PROCEDURE "informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSqlErr,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
			INTO cCodRetAux;

			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
			--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
				LET cTxnStatus		 = 'C';
			--	2014.11.11 FRG-f

			INSERT INTO "informix".sac_wu_pay
					(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1,    benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type, benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago, foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp, puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert)
			
			VALUES
					(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun, pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac,  pBenefNacionalidad, pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey, pNewMtcn, pMtcn, pConfPago, cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, pRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago,pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp, pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current);

			RETURN cCodRet, cError_Desc;
		END IF;

	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_pay.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF pRetCode = '504' THEN
	    LET cRetCode = '99999';
		LET pDesError = 'Aplicativo WU no activo, validar';
		
	END  IF;

	IF pRetCode <>  '504' AND pRetCode <> '00000' AND pRetCode <> '66666' THEN		
        IF pRetCode <> '20001' then
            LET cRetCode = '99998';
            LET pDesError = 'Sin respuesta del aplicativo, validar';
        ELIF pRetCode = '20001' then
            LET cRetCode = '20001';
            LET pDesError = 'Caracter invalido en la cadena';
        END IF;
	END IF;

	IF pRetCode = '66666' THEN
		LET cDesc_Error = pDesError;
		LET cRetCode = pRetCode;
	END IF
	
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
		IF (SELECT valor FROM "informix".sac_param WHERE cod_param ='87054') = pMarca
		OR (SELECT valor FROM "informix".sac_param WHERE cod_param ='87055') = pMarca
		OR (SELECT valor FROM "informix".sac_param WHERE cod_param ='87056') = pMarca THEN
			IF pUsuario = "sys_wu" THEN
				LET cSucursal = '9250';
			ELSE
				SELECT sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
			END IF;
			IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN
			
				SELECT fsid ,counter_id
				INTO cForeignSystemId ,cForeignRsCntRq
				FROM "informix".sac_wu_identificadores
				WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = cSucursal;

				IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
					LET cCodRet = '00027';
					LET cError_Desc	= 'Usuario no tiene Id. Asignado';
				END IF;
			ELSE
				LET	cCodRet = '00026'; --- Usuario no se encuentra
				LET cError_Desc	= 'NO EXISTE USUARIO';
		   END IF;
		ELSE
			LET	cCodRet = '00003'; --- Marca Inválida
			LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';
		END IF;
		
		SELECT valor
		INTO cChannelType
		FROM "informix".sac_param 
		WHERE cod_param = '87050';  
		 
		SELECT valor
		INTO cChannelName
		FROM "informix".sac_param 
		WHERE cod_param = '87051'; 
		 
		SELECT valor
		INTO cChannelVersion
		FROM "informix".sac_param 
		WHERE cod_param = '87052'; 
		
		SELECT valor
		INTO cTemplateId
		FROM "informix".sac_param 
		WHERE cod_param = '87063';

		--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
			LET	cTxnStatus	= 'A';
		--	2014.11.11 FRG-f
	
		INSERT INTO "informix".sac_wu_pay	
				(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1, benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type,benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago,foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp,puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err,fecha_hora_rp, user_insert, fecha_insert)
						
		VALUES
				(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun,pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac, pBenefNacionalidad,pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey,pNewMtcn, pMtcn, pConfPago,cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, cRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago, pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp,pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current);
					   
		IF  cCodRet <> '00000' THEN
			
			IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
				RETURN cCodRet,cError_Desc;	
			END IF;
		  
            RETURN cCodRet,cError_Desc;		
	    ELSE	
			
			IF cCodRet = '00000' THEN
				LET cError_Desc = "Ejecucion SP exitosa";
			END IF;	
			
           RETURN cCodRet,cError_Desc;
	    END IF;	
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje  <receive-money-pay> (request-reply) en la tabla bdisac:sac_wu_pay',  
'AUTOR: Christian Echavarria',			
'FECHA: 17/Jul/2013',
'DESCRIPCION: Se modifica para que consulte los campos counter_id y  fsid de sac_wu_identificadores',  
'AUTOR: Mario Gallardo',			
'FECHA: 03/10/2013',
'DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
'AUTOR: FRG',
'FECHA: 30/Jul/2014',
'BD: bdisac',
'AUTOR: Mario Olivo',
'Empleado: 95358919',
'Folio: 1457',
'Centro: 230202',
'Descripcion: Se aumenta la longitud del parametro pBenefPais por que se aumento la longitud en la tabla sac_wu_pay para',
'			  guardar el nombre completo del pais.',
'Fecha:10/SEP/2014',
'Version: 20140910.1627',
'AUTOR: Pedro Jimenez',
'Empleado: 95689966',
'Folio: 1485',
'Centro: 230202',
'Descripcion: Se aumenta la longitud de los parametro pBenefCiudad,pBeneCP,pBenefTelPart,pBenefTelCel  por que se aumento la longitud en la tabla sac_wu_pay',
'Fecha:26/02/2015',
'Version: 20150226.1651';

CREATE PROCEDURE "informix".sp_dinya_calcularcomisioniva_bei (pCategoria CHAR(2), pConvenio CHAR(3), pMonto MONEY)
	RETURNING  CHAR(5) ,MONEY, MONEY ,MONEY, CHAR(1), MONEY;

	DEFINE cCodRet 				CHAR(5);
	DEFINE mMontoMax			MONEY;
	DEFINE mMontoMin			MONEY;
	DEFINE mIva					MONEY;
	DEFINE mComision			MONEY;
	DEFINE mTotIvaComision		MONEY;
	DEFINE cTipo				CHAR(1);
	DEFINE iSqlErr				INTEGER;
	DEFINE isam_error			INTEGER;
	
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_dinya_calcularcomisioniva_bei.out";
	--TRACE ON;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr,isam_error
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
			END IF;
		END EXCEPTION;

		LET cCodRet 				= '00000';
		LET mMontoMax				= '0.00';
		LET mMontoMin				= '0.00';
		LET mIva					= 0;
		LET mComision				= '0.00';
		LET mTotIvaComision			= '0.00';
		LET cTipo					= '';
		LET iSqlErr					= 0;
		LET isam_error				= 0;


		IF pCategoria IS NULL OR pConvenio IS NULL THEN
			LET cCodRet = '00001';
			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF;
		
		IF  pMonto = 0.0 THEN
		
			FOREACH
				SELECT montomaximo, iva_comcte, comision_cte, tipo 
				INTO mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal 
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio and cve_canal = '15'
				
				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;
				
				
				IF cTipo = 1 THEN
					LET mComision = mComision;
				END IF;
				
				LET mIva = mIva/100;
				
				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;
				
			END FOREACH;
		
		ELSE 
			
			FOREACH
				SELECT montominimo, montomaximo, iva_comcte, comision_cte, tipo 
				INTO mMontoMin, mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal 
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio and cve_canal = '15'
				
				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					--RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;
				
				IF pMonto <= mMontoMax AND pMonto >= mMontoMin THEN
					
					IF cTipo = 1 THEN
						LET mComision = mComision;
					END IF;
					
					LET mIva = mComision * (mIva/100);
					LET mTotIvaComision = mIva + mComision;
				
					EXIT FOREACH;
					--RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;
					
				END IF;
				
			END FOREACH;
			
			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF ;
	END
END PROCEDURE
Document
'DESCRIPCION: Calcula el IVA y Comision de un importe y regresa las comisiones para Ordenes de Pago para EmpresaNEt', 
'AUTOR: Bibiana Gaxiola',
'FECHA: 03/03/2015',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_dinya_calcularcomisioniva_bpi (pCategoria CHAR(2), pConvenio CHAR(3), pMonto MONEY)
	RETURNING  CHAR(5) ,MONEY, MONEY ,MONEY, CHAR(1), MONEY;
	DEFINE cCodRet 				CHAR(5);
	DEFINE mMontoMax			MONEY;
	DEFINE mMontoMin			MONEY;
	DEFINE mIva					MONEY;
	DEFINE mComision			MONEY;
	DEFINE mTotIvaComision		MONEY;
	DEFINE cTipo				CHAR(1);
	DEFINE iSqlErr				INTEGER;
	DEFINE isam_error			INTEGER;


	--SET DEBUG FILE TO "/home/sysifx/ilse/sp_dinya_calcularcomisioniva_bpi.out";
	--TRACE ON;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	BEGIN
		ON EXCEPTION SET iSqlErr,isam_error
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
			END IF;
		END EXCEPTION;
		LET cCodRet 				= '00000';
		LET mMontoMax				= '0.00';
		LET mMontoMin				= '0.00';
		LET mIva					= 0;
		LET mComision				= '0.00';
		LET mTotIvaComision			= '0.00';
		LET cTipo					= '';
		LET iSqlErr					= 0;
		LET isam_error				= 0;
		IF pCategoria IS NULL OR pConvenio IS NULL THEN
			LET cCodRet = '00001';
			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF;

		IF  pMonto = 0.0 THEN

			FOREACH
				SELECT montomaximo, iva_comcte, comision_cte, tipo
				INTO mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio and cve_canal = '3'

				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;


				IF cTipo = 1 THEN
					LET mComision = mComision;
				END IF;

				-- COMISION CON %
				IF cTipo = 2 THEN
					LET mComision = mComision/100;
				END IF;

				LET mIva = mIva/100;

				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;

			END FOREACH;

		ELSE

			FOREACH
				SELECT montominimo, montomaximo, iva_comcte, comision_cte, tipo
				INTO mMontoMin, mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio

				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					--RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;

				IF pMonto <= mMontoMax AND pMonto >= mMontoMin THEN

					IF cTipo = 1 THEN
						LET mComision = mComision;
					END IF;

					-- COMISION EN %
					IF cTipo = 2 THEN
						LET mComision = pMonto * (mComision/100);

					END IF;
					LET mIva = mComision * (mIva/100);
					LET mTotIvaComision = mIva + mComision;

					EXIT FOREACH;
					--RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;

				END IF;

			END FOREACH;

			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF ;
	END
END PROCEDURE
Document
'DESCRIPCION: Calcula el IVA y Comision de un importe y regresa las comisiones para Ordenes de Pago',
'AUTOR: Ilse Gómez',
'FECHA: 15 de enero de 2015',
'VERSION: 20141216.0900',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_dinya_insertaenvios3 
	(mMontoEnvio MONEY(16,2),
	pMontoCargo MONEY(16,2),
	pCuentaCargo CHAR(20),
	pSucursal CHAR(4),
	cEjecutivo CHAR(8),
	pFolioSuc CHAR(16))

	RETURNING  CHAR(5), CHAR(16);

	DEFINE cCodRet 			 		CHAR(5);
	DEFINE iSqlErr			 		INTEGER;
	DEFINE cCuentaPrestadora 		CHAR(20);
	DEFINE cTransaccAbonoEnvio		CHAR(4);
	DEFINE cTransaccAbonoIva		CHAR(4);
	DEFINE cTransaccAbonoComision	CHAR(4);
	DEFINE mTotComision				MONEY (16,2);
	DEFINE mTotIVA					MONEY (16,2);
	DEFINE mTotIvaComision			MONEY (16,2);
	DEFINE pImporte					MONEY (16,2);
	DEFINE mTotalaCobrar			MONEY (16,2);
	DEFINE cTransaccSuc				CHAR(4);
	DEFINE cTransaccCargoEnvio 		CHAR(4);
	DEFINE ctranret					CHAR(4);
	DEFINE dfechoy					DATE;
	DEFINE msdodisp					MONEY (14,2);
	DEFINE mmontoret				MONEY (14,2);
	DEFINE dFecha_hoy				DATE;
	DEFINE isam_error				INTEGER;
	DEFINE cDescripcion				CHAR(200);
	DEFINE cTransaccCargoiva		CHAR(4);
	DEFINE cTransaccCargocomi		CHAR(4);
	DEFINE cTransaccCargocomiCte	CHAR(4);
	DEFINE cTransaccCargoivaCte		CHAR(4);

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (iSqlErr,isam_error,cDescripcion,'sp_dinya_insertaenvios3',dFecha_hoy,CURRENT );
				RETURN cCodRet, pFolioSuc;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/informix/bibiana/sp_dinya_InsertaEnvios3.out";
		--TRACE ON;

		LET cCodRet 			   = '00000';
		LET iSqlErr			 	   = 0;
		LET cCuentaPrestadora 	   = '';
		LET cTransaccAbonoEnvio	   = '';
		LET cTransaccAbonoIva	   = '';
		LET cTransaccAbonoComision = '';
		LET mTotComision		   = '';
		LET mTotIVA				   = '';
		LET mTotIvaComision 	   = '';
		LET pImporte			   = '';
		LET mTotalaCobrar		   = '';	
		LET cTransaccSuc		   = '';
		LET cTransaccCargoEnvio	   = '';
		LET ctranret			   = '';
		LET dfechoy				   = '';
		LET msdodisp			   = '';
		LET mmontoret			   = '';
		LET dFecha_hoy			   = '';
		LET isam_error			   = '';
		LET cDescripcion		   = '';
		LET cTransaccCargoiva	='';
		LET cTransaccCargocomi	='';
		LET cTransaccCargocomiCte	='';
		LET cTransaccCargoivaCte		='';

		--Obtiene parametros
		SELECT valor INTO cCuentaPrestadora
		FROM Bdisac:sac_param
		WHERE cod_param='75';

		SELECT valor INTO cTransaccAbonoEnvio
		FROM Bdisac:sac_param
		WHERE cod_param='5070012';

		SELECT valor INTO cTransaccCargoEnvio
		FROM Bdisac:sac_param
		WHERE cod_param='414070021';

		SELECT valor INTO cTransaccAbonoComision
		FROM Bdisac:sac_param
		WHERE cod_param='511070012';

		SELECT valor INTO cTransaccAbonoIva
		FROM Bdisac:sac_param
		WHERE cod_param='510070012';

		SELECT valor INTO cTransaccSuc
		FROM Bdisac:sac_param
		WHERE cod_param='807001';	

		SELECT valor INTO cTransaccCargocomiCte
		FROM Bdisac:sac_param
		WHERE cod_param='413070011';

		SELECT valor INTO cTransaccCargoivaCte
		FROM Bdisac:sac_param
		WHERE cod_param='4070011';

		SELECT valor INTO cTransaccCargocomi
		FROM Bdisac:sac_param
		WHERE cod_param='413070012';

		SELECT valor INTO cTransaccCargoiva
		FROM Bdisac:sac_param
		WHERE cod_param='4070012';		
		
		SELECT fecha_hoy 
		INTO dFecha_hoy
		FROM Bdisac:sac_fechas;			

		
		IF pSucursal = '5003' THEN

			--Calcula la comision e Iva bpi
			CALL  bdisac:"informix".sp_dinya_calcularcomisioniva_bpi ('07', '001', mMontoEnvio)
			RETURNING cCodRet,pImporte,mTotIVA,mTotComision,mTotalaCobrar,mTotIvaComision;  
			
			LET mTotalaCobrar=pImporte+mTotIvaComision;
			
		ELIF pSucursal = '5008' THEN
		
			CALL  bdisac:"informix".sp_dinya_calcularcomisioniva_bei ('07', '001', mMontoEnvio)
			RETURNING cCodRet,pImporte,mTotIVA,mTotComision,mTotalaCobrar,mTotIvaComision;  
			
			LET mTotalaCobrar=pImporte+mTotIvaComision;	
			
		ELSE
		
			--Calcula la comision e Iva
			CALL  bdisac:sp_DinYa_CalcularComisionIva ('07001',mMontoEnvio,pSucursal)
			RETURNING cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
			
		END IF;
		
		IF cCodRet <> 0 THEN
			LET cCodRet = '00015'; --Error en el calculo de comision e iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta del cte por orden de pago	
		LET pMontoCargo= pMontoCargo- mTotIvaComision;
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoEnvio, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, pMontoCargo,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
			LET cCodRet = '00016'; --Error en el cargo de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;	

		--Abono a la cuenta prestadora de servicios por el monto del Envio
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoEnvio, cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, pMontoCargo, mMontoEnvio, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;  

		IF cCodRet <> 0 THEN
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00017'; --Error en el abono de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;		
		
		--Cargo a la cte del cliente por el monto de la comision
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargocomiCte, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, mTotComision,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00018'; --Error en el cargo de la comision
			RETURN cCodRet,pFolioSuc;
		END IF;
		
		--Abono a la cuenta receptora (Comision)
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoComision ,cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, mTotComision, mTotComision, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00019'; --Error en el abono de la comision
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta del cliente por el Iva			
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoivaCte, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, mTotIVA,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
			LET cCodRet = '00020'; --Error en el cargo por el Iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Abono a la cuenta receptora (Iva)
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoIva , cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, mTotIVA, mTotIVA, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;
		
		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion del abono y cargo
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00021'; --Error en el abono del iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta prestadora por la comision			
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargocomi, cTransaccSuc, pFolioSuc, 
		cCuentaPrestadora, 0, mTotComision,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
			LET cCodRet = '00023'; --Error en el cargo por el Iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta prestadora por el iva		
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoiva, cTransaccSuc, pFolioSuc, 
		cCuentaPrestadora, 0, mTotIVA,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
			LET cCodRet = '00024'; --Error en el cargo por el Iva
			RETURN cCodRet,pFolioSuc;
		END IF;
		
		RETURN cCodRet,pFolioSuc; 

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: GENERA EL ENVIO CON PAGO CON CARGO A CUENTA DE MONTO ENVIO, COMISION E IVA, ACTIVA ENVIO EN SAC_ENVIOSDINEROYA', 
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'FECHA: DICIEMBRE 2009',
'VERSION: 20100125.1024',
'MODIFICACION: Se agrega validacion para ejecutar el sp sp_dinya_calcularcomisioniva_bpi cuando se realize una orden de pago desde la BPI', 
'AUTOR: Ilse Gomez',
'FECHA: 15 de enero de 2015',
'VERSION: 20141216.0900',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_pasemovshistorial()
    RETURNING CHAR(5), char(10);  --Códigos de retorno

DEFINE cCodRet                      CHAR(5);
DEFINE vfecha_insert                DATETIME YEAR to FRACTION(5);
DEFINE vtotregshist                 CHAR (40);
DEFINE iSqlErr                      INTEGER;
DEFINE iContBorra                   INTEGER;
DEFINE vmax_fechaold                DATE;
DEFINE vfecharesp                   DATE;
DEFINE vfechacomp                   DATE;
DEFINE  Cid_sucursal               	CHAR(4);
DEFINE  Cnumcategoria              	CHAR(2);
DEFINE  Cnumconvenio               	CHAR(5);
DEFINE  Creferencia1               	CHAR(40);
DEFINE  Creferencia2               	CHAR(40);
DEFINE  Cforma_pago                	CHAR(1);
DEFINE  Mimporte_pago              	MONEY;
DEFINE  Mimporte_comision_convenio 	MONEY;
DEFINE  Miva_comision_convenio     	MONEY;
DEFINE  Mimporte_comision_cte      	MONEY;
DEFINE  Miva_comision_cte          	MONEY;
DEFINE  Ccuenta_cargo              	CHAR(12);
DEFINE  Cusuario                   	CHAR(8);
DEFINE  Cfolio_suc                 	CHAR(16);
DEFINE  Ctransacc_suc              	CHAR(4);
DEFINE  Sflag_confirmacion_central 	SMALLINT;
DEFINE  Sflag_confirmacion_sucursal	SMALLINT;
DEFINE  Dfecha_pago                	DATE;
DEFINE  Dfecha_insert              	DATETIME YEAR to FRACTION(3);
DEFINE  Cstatus_cancelado          	CHAR(1);

 --SET DEBUG FILE TO "/informix/EPG/sp_sac_pasemovshistorial.out";
 --TRACE ON;

 LET cCodRet                    = '00000';
LET vfecha_insert               = CURRENT;
LET vtotregshist                = '0000000000000000000000000000000000000000';
LET iSqlErr                     = 0;
LET iContBorra                  = 0;
LET vmax_fechaold               = '';
LET vfecharesp                  = '';
LET vfechacomp                  = '';
LET Cid_sucursal                ='';
LET Cnumcategoria               ='';
LET Cnumconvenio                ='';
LET Creferencia1                ='';
LET Creferencia2                ='';
LET Cforma_pago                 ='';
LET Mimporte_pago               = 0;
LET Mimporte_comision_convenio  = 0;
LET Miva_comision_convenio      = 0;
LET Mimporte_comision_cte       = 0;
LET Miva_comision_cte           = 0;
LET Ccuenta_cargo               ='';
LET Cusuario                    ='';
LET Cfolio_suc                  ='';
LET Ctransacc_suc               ='';
LET Sflag_confirmacion_central  ='';
LET Sflag_confirmacion_sucursal ='';
LET Dfecha_pago                 ='';
LET Dfecha_insert               ='';
LET Cstatus_cancelado           ='';

BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vtotregshist;
		END IF;
   END EXCEPTION;
	
	SELECT MAX (fecha_pago) INTO vmax_fechaold
	  FROM "c92357113".sac_movimientoshistorial_old;
	
	let vfecharesp = vmax_fechaold + 1;
	let vfechacomp = TODAY - 91;

  SELECT COUNT({+INDEX ("informix".sac_movimientoshistorial)}referencia1) 
	INTO vtotregshist 
	FROM "informix".sac_movimientoshistorial
   WHERE fecha_pago BETWEEN vfecharesp AND vfechacomp;

  FOREACH cursor_borra WITH HOLD FOR
		
		 SELECT id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio,
				iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
				flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado
		   INTO	Cid_sucursal, Cnumcategoria, Cnumconvenio, Creferencia1, Creferencia2, Cforma_pago, Mimporte_pago, Mimporte_comision_convenio,
				Miva_comision_convenio, Mimporte_comision_cte, Miva_comision_cte, Ccuenta_cargo, Cusuario, Cfolio_suc, Ctransacc_suc,
				Sflag_confirmacion_central, Sflag_confirmacion_sucursal, Dfecha_pago, Dfecha_insert, Cstatus_cancelado
           FROM "informix".sac_movimientoshistorial
          WHERE fecha_pago >= vfecharesp
		    AND fecha_pago <= vfechacomp

		IF iContBorra = 0 THEN
		   BEGIN WORK;
		END IF;
		
		INSERT INTO "c92357113".sac_movimientoshistorial_old VALUES (Cid_sucursal, Cnumcategoria, Cnumconvenio, Creferencia1, Creferencia2, Cforma_pago, 
				Mimporte_pago, Mimporte_comision_convenio,Miva_comision_convenio, Mimporte_comision_cte, Miva_comision_cte, Ccuenta_cargo, Cusuario, 
				Cfolio_suc, Ctransacc_suc,Sflag_confirmacion_central, Sflag_confirmacion_sucursal, Dfecha_pago, Dfecha_insert, Cstatus_cancelado);
         
		DELETE FROM "informix".sac_movimientoshistorial WHERE numcategoria = Cnumcategoria AND numconvenio = Cnumconvenio AND fecha_pago = Dfecha_pago AND folio_suc = Cfolio_suc;

		LET iContBorra = iContBorra + 1;

		IF iContBorra = 1000 THEN
		   COMMIT WORK;
		   LET iContBorra = 0;
		END IF;
  
  END FOREACH;

  IF iContBorra < 1000 AND vtotregshist > 0 THEN
     COMMIT WORK;
  END IF;

END;
RETURN cCodRet, vtotregshist;
END PROCEDURE
DOCUMENT
'AUTOR : EPG',
'DESCRIPCION: Elimina registros de tabla bdisac:"informix".sac_movimientoshistorial por medio de cursor',
'y los respalda en bdisac:"informix".sac_movimientoshistorial_old.',
'EJECUTADO O LLAMADO POR: Proceso especial (se ejecuta por script en casos especiales).',
'FECHA : Abril/2014',
'VERSION: 20140413',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_envpag_valmontmax
(
	pModalidad   SMALLINT,  	--Modalidad
	pImporte     MONEY(14,2),  	--Monto a enviar-recibir
	pNombre1   	 CHAR (26), 	--nombre cliente-usuario
	pNombre2	 CHAR (26),
	pApellidoPat CHAR (26),
	pApellidoMat CHAR (26)
)

RETURNING CHAR (6) AS cCodRet;

	DEFINE cCodRet				CHAR(6);
	DEFINE iSqlErr 		  		INTEGER;
	DEFINE mLimite_envio  		MONEY(14,2);
	DEFINE iDias_limit   		INTEGER;
	DEFINE dtFecha_hoy   		DATE;
	DEFINE dtFecha_limit 		DATE;
	DEFINE mImporte_ya	 		MONEY(14,2);
	DEFINE mImporte_yahis 		MONEY(14,2);
	DEFINE mImporte_ya_movhis 	MONEY(14,2);
		
	LET cCodRet		 			= '000000';
	LET iSqlErr 				= 0;
	LET mLimite_envio   		= 0.00;
	LET iDias_limit     		= 0;
	LET dtFecha_hoy     		= DATE(1);
	LET dtFecha_limit   		= DATE(1);
	LET mImporte_ya				= 0.00;
	LET mImporte_yahis			= 0.00;
	LET mImporte_ya_movhis		= 0.00;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/adrian/sp_envpag_valmontmax_aia.out';
		--TRACE ON;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;  		
				
		IF NVL(pModalidad,0) NOT IN (1,2) OR NVL(pNombre1,'') ='' OR NVL(pApellidoPat,'') ='' THEN 
			LET cCodRet = '000001';
			RETURN cCodRet;
		END IF;
		
		-- BUSCANDO LA CANTIDAD LIMITE PERMITIDA
		SELECT NVL(valor,0) 
		INTO mLimite_envio
		FROM "informix".sac_param 
		WHERE cod_param = '6070033';
		
		/*
		-- BUSCANDO LOS DIAS LIMITES PARA EL CALCULO DE LA FECHA RANGO
		SELECT NVL(valor,0) 
		INTO iDias_limit
		FROM "informix".sac_param 
		WHERE cod_param = '6070034';
		*/
		
		--CONSULTAR FECHAHOY
		SELECT fecha_hoy 
		INTO dtFecha_hoy
		FROM "informix".sac_fechas
		WHERE empresa ='001';		
		
		--OBTENER FECHA LIMITE
		LET dtFecha_limit = MDY(MONTH(dtFecha_hoy),01,YEAR(dtFecha_hoy));
		
		-- ASEGURANDO DATOS EN MAYUSCULA
		LET pNombre1 = UPPER(pNombre1);
		LET pNombre2 = UPPER(pNombre2);
		LET pApellidoPat = UPPER(pApellidoPat);
		LET pApellidoMat = UPPER(pApellidoMat);		
		
		--ENVIO DE LA ORDEN DEL PAGO
		IF NVL(pImporte, 0) = 0 THEN
				LET cCodRet = '000001';
				RETURN cCodRet;
			END IF;
			
		IF pModalidad = 1 THEN							
			-- BUSCANDO LA SUMATORIA DE MOVIMIENTOS DE PAGOS EN EFECTIVO PARA EL ORDENANTE				
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_envio,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientos WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_ya
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_rem = pNombre1
			AND envio.seg_nom_rem = pNombre2
			AND envio.apell_pat_rem = pApellidoPat
			AND envio.apell_mat_rem = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(enviohis.importe_envio,0) <> 0 AND enviohis.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = enviohis.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1'  AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_yahis
			FROM "informix".sac_enviosdineroyahis enviohis
			WHERE enviohis.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (enviohis.estatus ='01' OR enviohis.estatus ='04') -- ACTIVOS Y PAGADOS
			AND enviohis.pri_nom_rem = pNombre1
			AND enviohis.seg_nom_rem = pNombre2
			AND enviohis.apell_pat_rem = pApellidoPat
			AND enviohis.apell_mat_rem = pApellidoMat;

			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_envio,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_ya_movhis
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_rem = pNombre1
			AND envio.seg_nom_rem = pNombre2
			AND envio.apell_pat_rem = pApellidoPat
			AND envio.apell_mat_rem = pApellidoMat;
						
		ELSE
			-- BUSCANDO LA SUMATORIA DE MOVIMIENTOS DE COBROS EN EFECTIVO PARA EL BENEFICIARIO
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_pago,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientos WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_ya
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_ben = pNombre1
			AND envio.seg_nom_ben = pNombre2
			AND envio.apell_pat_ben = pApellidoPat
			AND envio.apell_mat_ben = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(enviohis.importe_pago,0) <> 0 AND enviohis.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = enviohis.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_yahis
			FROM "informix".sac_enviosdineroyahis enviohis
			WHERE enviohis.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (enviohis.estatus ='01' OR enviohis.estatus ='04') -- ACTIVOS Y PAGADOS
			AND enviohis.pri_nom_ben = pNombre1
			AND enviohis.seg_nom_ben = pNombre2
			AND enviohis.apell_pat_ben = pApellidoPat
			AND enviohis.apell_mat_ben = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_pago,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_ya_movhis
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_ben = pNombre1
			AND envio.seg_nom_ben = pNombre2
			AND envio.apell_pat_ben = pApellidoPat
			AND envio.apell_mat_ben = pApellidoMat;
					
		END IF;
		
		IF (NVL(mImporte_ya,0) + NVL(mImporte_yahis,0) + NVL(mImporte_ya_movhis,0) + NVL(pImporte,0)) > mLimite_envio THEN
				LET cCodRet = '000004';
				RETURN cCodRet;
		END IF
		
	RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que validará el monto máximo mensual en efectivo por usuario para envíos y/o cobros previa validación de los parámetros de entrada ',
'AUTOR: Antonio Cebreros Perez',
'FECHA DE CREACION: 13 de Octubre del 2014',
'VERSION: 20141030.1500',
'BD: bdisac',
'Folio: 1464 - LimiteOrdPagEfec',

'DESCRIPCION: Ahora se contemplará Envios/Cobros para la sumatoria del acumulado cuando ocurre el siguiente caso',
'por ejemplo: Hoy se realiza un envío y no es cobrado',
'AUTOR: Francisco Eduardo Benitez Baez',
'FECHA DE CREACION: 01 de Diciembre del 2014',
'VERSION: 20141201.1552',
'BD: BDISAC',
'Folio: 1474 - MttoLimiteOrdPagEfec',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE FUNCTION "informix".fn_instr(pString VARCHAR(255),pToken VARCHAR(255),pStar INTEGER DEFAULT 1 )
RETURNING SMALLINT ;

	DEFINE i,j SMALLINT ;
	DEFINE w_1 VARCHAR(255) ;

	IF ( pString IS NULL) OR (pToken IS NULL ) THEN
		RETURN -1 ;
	END IF ;
	LET j = LENGTH(pString);
	FOR i = pStar TO j 
		IF ( SUBSTR(pString,I,1) = SUBSTR(pToken,1,1) ) THEN
			LET w_1 = SUBSTR(pString,i,LENGTH(pToken)) ;
			IF ( w_1 = pToken) THEN
				RETURN i ;
			END IF ;
		END IF ;
	END FOR ;
RETURN 0 ;
END FUNCTION ;