CREATE PROCEDURE "informix".sp_periodos_facturacion_cnr(pEmpresa CHAR(3),pNumeroCredito CHAR(20),pPeriodicidad CHAR(1),pNumProducto CHAR(04),pDiaCorte SMALLINT,pFechaHoy DATE,pIva DECIMAL(5,3))
RETURNING   CHAR(6)        AS resultado,
            VARCHAR(100,1) AS mensaje,
            DECIMAL(18,5) AS MontoExigible0,
            DECIMAL(18,5) AS MontoExigible1,
            DECIMAL(18,5) AS MontoExigible2,
            DECIMAL(18,5) AS MontoExigible3,
            DECIMAL(18,5) AS MontoExigible4,
            DECIMAL(18,5) AS MontoExigible5,
            DECIMAL(18,5) AS MontoExigible6,
            DECIMAL(18,5) AS MontoExigible7,
            DECIMAL(18,5) AS MontoExigible8,
            DECIMAL(18,5) AS MontoExigible9,
            DECIMAL(18,5) AS MontoExigible10,
            DECIMAL(18,5) AS MontoExigible11,
            DECIMAL(18,5) AS MontoExigible12,
            DECIMAL(18,5) AS PagosRealizados0,
            DECIMAL(18,5) AS PagosRealizados1,
            DECIMAL(18,5) AS PagosRealizados2,
            DECIMAL(18,5) AS PagosRealizados3,
            DECIMAL(18,5) AS PagosRealizados4,
            DECIMAL(18,5) AS PagosRealizados5,
            DECIMAL(18,5) AS PagosRealizados6,
            DECIMAL(18,5) AS PagosRealizados7,
            DECIMAL(18,5) AS PagosRealizados8,
            DECIMAL(18,5) AS PagosRealizados9,
            DECIMAL(18,5) AS PagosRealizados10,
            DECIMAL(18,5) AS PagosRealizados11,
            DECIMAL(18,5) AS PagosRealizados12,
            DECIMAL(18,5) AS PorcentajePago0,
            DECIMAL(18,5) AS PorcentajePago1,
            DECIMAL(18,5) AS PorcentajePago2,
            DECIMAL(18,5) AS PorcentajePago3,
            DECIMAL(18,5) AS PorcentajePago4,
            DECIMAL(18,5) AS PorcentajePago5,
            DECIMAL(18,5) AS PorcentajePago6,
            DECIMAL(18,5) AS PorcentajePago7,
            DECIMAL(18,5) AS PorcentajePago8,
            DECIMAL(18,5) AS PorcentajePago9,
            DECIMAL(18,5) AS PorcentajePago10,
            DECIMAL(18,5) AS PorcentajePago11,
            DECIMAL(18,5) AS PorcentajePago12,
            DECIMAL(18,5) AS PromPorcentajePago;
        
DEFINE iSqlErr      	     		INTEGER;
DEFINE iIsamErr              		INTEGER;
DEFINE cErrorInfo            		CHAR(80);
DEFINE cCodRet               		CHAR(6); 
DEFINE cMensajeRet           		VARCHAR(100,1);
DEFINE cMensaje                     CHAR(40);

DEFINE dtFechaCorte,dFechaVencim,dtPriDiaMes,dtFecha_Vencto,dtFechaPeriodo,dtFechaPeriodoFact,dtFechaInicioPeriodo DATE;
DEFINE iNumSesion            		INTEGER;
DEFINE cStatus_proc          		CHAR(1);
DEFINE cStatusCred           		CHAR(2);
DEFINE cSucursal             		CHAR(4);
DEFINE cProducto             		CHAR(4);
DEFINE cDivisa               		CHAR(2);
DEFINE dMontoExigible0,dMontoExigible1,dMontoExigible2,dMontoExigible3,dMontoExigible4,dMontoExigible5,dMontoExigible6,dMontoExigible7,dMontoExigible8,dMontoExigible9,dMontoExigible10,dMontoExigible11,dMontoExigible12  DECIMAL(18,5);
DEFINE dPagosRealizados0,dPagosRealizados1,dPagosRealizados2,dPagosRealizados3,dPagosRealizados4,dPagosRealizados5,dPagosRealizados6,dPagosRealizados7,dPagosRealizados8,dPagosRealizados9,dPagosRealizados10,dPagosRealizados11,dPagosRealizados12  DECIMAL(18,5);
DEFINE dPorcentajePago0,dPorcentajePago1,dPorcentajePago2,dPorcentajePago3,dPorcentajePago4,dPorcentajePago5,dPorcentajePago6,dPorcentajePago7,dPorcentajePago8,dPorcentajePago9,dPorcentajePago10,dPorcentajePago11,dPorcentajePago12 DECIMAL(18,5);
DEFINE dPromPorcentajePago DECIMAL(18,5);
DEFINE sIndATR,sDiasAtraso,sPrestamo,sNomina,sOtro,sAuto,sAbc,sPlazoTotal,sNumCuotasPag,sNvoPeriodo,sNumPeriodosPromPorcPago,sNumPeriodo SMALLINT;
DEFINE cSql                  		CHAR(1024);
DEFINE dFechaInicio0,dFechaInicio1,dFechaInicio2,dFechainicio3,dFechaInicio4,dFechaInicio5,dFechaInicio6,dFechainicio7 DATE;
DEFINE dFechaInicio8,dFechaInicio9,dFechaInicio10,dFechainicio11,dFechaInicio12,dFechaInicio13 DATE;
DEFINE pfechaapertura,dFechaHoyAux date;
DEFINE cLaborable					CHAR(01);
DEFINE sDiaInicial,sDiaFinal	SMALLINT;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet = 'Error en el cÃ¡lculo de los PERIODOS DE FACTURACION';
      RETURN cCodRet, cMensajeRet,
             nvl(dMontoExigible0,0),nvl(dMontoExigible1,0),nvl(dMontoExigible2,0),nvl(dMontoExigible3,0),nvl(dMontoExigible4,0),nvl(dMontoExigible5,0),nvl(dMontoExigible6,0),nvl(dMontoExigible7,0),nvl(dMontoExigible8,0),nvl(dMontoExigible9,0),nvl(dMontoExigible10,0),nvl(dMontoExigible11,0),nvl(dMontoExigible12,0),
             nvl(dPagosRealizados0,0),nvl(dPagosRealizados1,0),nvl(dPagosRealizados2,0),nvl(dPagosRealizados3,0),nvl(dPagosRealizados4,0),nvl(dPagosRealizados5,0),nvl(dPagosRealizados6,0),nvl(dPagosRealizados7,0),nvl(dPagosRealizados8,0),nvl(dPagosRealizados9,0),nvl(dPagosRealizados10,0),nvl(dPagosRealizados11,0),nvl(dPagosRealizados12,0),
             nvl(dPorcentajePago0,0),nvl(dPorcentajePago1,0),nvl(dPorcentajePago2,0),nvl(dPorcentajePago3,0),nvl(dPorcentajePago4,0),nvl(dPorcentajePago5,0),nvl(dPorcentajePago6,0),nvl(dPorcentajePago7,0),nvl(dPorcentajePago8,0),nvl(dPorcentajePago9,0),nvl(dPorcentajePago10,0),nvl(dPorcentajePago11,0),nvl(dPorcentajePago12,0),nvl(dPromPorcentajePago,0);
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_periodos_facturacion_cnr.out";
--TRACE ON;

LET iSqlErr                  	= 0;
LET iIsamErr                 	= 0;
LET cErrorInfo               	= "";
LET cCodRet                  	= '000000';
LET cMensajeRet              	= 'Los cÃ¡lculos se realizaron correctamente';
LET cMensaje                    = '';
LET dMontoExigible0,dMontoExigible1,dMontoExigible2,dMontoExigible3,dMontoExigible4,dMontoExigible5,dMontoExigible6,dMontoExigible7,dMontoExigible8,dMontoExigible9,dMontoExigible10,dMontoExigible11,dMontoExigible12 = 0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dPagosRealizados0,dPagosRealizados1,dPagosRealizados2,dPagosRealizados3,dPagosRealizados4,dPagosRealizados5,dPagosRealizados6,dPagosRealizados7,dPagosRealizados8,dPagosRealizados9,dPagosRealizados10,dPagosRealizados11,dPagosRealizados12 = 0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dPorcentajePago0,dPorcentajePago1,dPorcentajePago2,dPorcentajePago3,dPorcentajePago4,dPorcentajePago5,dPorcentajePago6,dPorcentajePago7,dPorcentajePago8,dPorcentajePago9,dPorcentajePago10,dPorcentajePago11,dPorcentajePago12 = 0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dpromporcentajepago 		= 0;
LET cLaborable					= '';
LET sDiaInicial,sDiaFinal = 0,0;

LET dFechaInicio0,dFechaInicio1,dFechaInicio2,dFechainicio3 = date(1),date(1),date(1),date(1);
LET dFechaInicio4,dFechaInicio5,dFechaInicio6,dFechainicio7 = date(1),date(1),date(1),date(1);
LET dFechaInicio8,dFechaInicio9,dFechaInicio10,dFechainicio11 = date(1),date(1),date(1),date(1);
LET dFechaInicio12,dFechaInicio13 = date(1),date(1);
LET pfechaapertura,dFechaHoyAux = date(1),date(1);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- Se determinan las fechas de consulta
    IF pPeriodicidad = 'M' THEN
-- Se determinan las fechas de consulta
		EXECUTE PROCEDURE "informix".sp_calcula_fechas_porperiodo(pEmpresa,pPeriodicidad,pNumProducto,pDiaCorte,pFechaHoy)
				INTO cCodRet,cMensajeRet,dFechaInicio0,dFechaInicio1,dFechaInicio2,dFechaInicio3,dFechaInicio4,dFechaInicio5,dFechaInicio6,
					dFechaInicio7,dFechaInicio8,dFechaInicio9,dFechaInicio10,dFechaInicio11,dFechaInicio12,dFechaInicio13;
		
        SELECT 
			nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
						FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio1 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
						FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio2 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
						FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio3 - 1 units day AND mah.num_credito = pNumeroCredito)
		  INTO dMontoExigible0,dMontoExigible1,dMontoExigible2,dMontoExigible3
		  FROM bdicred:sd_maesdoshistcrd 
		 WHERE empresa = pEmpresa
		   AND fecha = dFechaInicio0 - 1 units day
		   AND num_credito = pNumeroCredito;

		SELECT nvl(sum(monto),0),
			(SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio2 + 1 units day AND fecha_mov <= dFechaInicio1
					AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
					AND codigo_ref = 1 AND reversado = 'N'),
			(SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio3 + 1 units day AND fecha_mov <= dFechaInicio2
					AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
					AND codigo_ref = 1 AND reversado = 'N'),
			(SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio4 + 1 units day AND fecha_mov <= dFechaInicio3
					AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
					AND codigo_ref = 1 AND reversado = 'N')
		  INTO dPagosRealizados0,dPagosRealizados1,dPagosRealizados2,dPagosRealizados3
		  FROM "informix".sd_movhiscrd
		 WHERE empresa     = pEmpresa
		   AND fecha_mov   >= dFechaInicio1 + 1 units day
		   AND fecha_mov   <= dFechaInicio0
		   AND num_credito = pNumeroCredito
		   AND codigo_fun  IN (SELECT cod_fun FROM "informix".sd_conceptospagomanualcrd WHERE num_producto != '6011')
		   AND codigo_ref  = 1 --IN (1,15,16,5,6,7,8,9,10,11,12,13,14)
		   AND reversado   = 'N';

		IF dMontoExigible0 IS NOT NULL AND dMontoExigible0 != 0 THEN LET dPorcentajePago0 = dPagosRealizados0 / dMontoExigible0; ELSE LET dPorcentajePago0 = 0; END IF;
		IF dMontoExigible1 IS NOT NULL AND dMontoExigible1 != 0 THEN LET dPorcentajePago1 = dPagosRealizados1 / dMontoExigible1; ELSE LET dPorcentajePago1 = 0; END IF;
		IF dMontoExigible2 IS NOT NULL AND dMontoExigible2 != 0 THEN LET dPorcentajePago2 = dPagosRealizados2 / dMontoExigible2; ELSE LET dPorcentajePago2 = 0; END IF;
		IF dMontoExigible3 IS NOT NULL AND dMontoExigible3 != 0 THEN LET dPorcentajePago3 = dPagosRealizados3 / dMontoExigible3; ELSE LET dPorcentajePago3 = 0; END IF;

		IF dMontoExigible0 IS NULL OR dMontoExigible0 = 0 THEN LET dPorcentajePago0 = 1; END IF;
		IF dMontoExigible1 IS NULL OR dMontoExigible1 = 0 THEN LET dPorcentajePago1 = 1; END IF;
		IF dMontoExigible2 IS NULL OR dMontoExigible2 = 0 THEN LET dPorcentajePago2 = 1; END IF;
		IF dMontoExigible3 IS NULL OR dMontoExigible3 = 0 THEN LET dPorcentajePago3 = 1; END IF;

		LET dPromPorcentajePago = (dPorcentajePago0 + dPorcentajePago1 + dPorcentajePago2 + dPorcentajePago3) / 4;
	ELIF pPeriodicidad = 'Q' THEN
--calcula 13 periodos de pago
-- Se determinan las fechas de consulta
		EXECUTE PROCEDURE "informix".sp_calcula_fechas_porperiodo(pEmpresa,pPeriodicidad,pNumProducto,pDiaCorte,pFechaHoy)
				INTO cCodRet,cMensajeRet,dFechaInicio0,dFechaInicio1,dFechaInicio2,dFechaInicio3,dFechaInicio4,dFechaInicio5,dFechaInicio6,
					dFechaInicio7,dFechaInicio8,dFechaInicio9,dFechaInicio10,dFechaInicio11,dFechaInicio12,dFechaInicio13;

		SELECT 
			nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio1 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio2 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio3 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio4 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio5 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio6 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio7 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio8 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio9 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio10 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio11 - 1 units day AND mah.num_credito = pNumeroCredito),
			(SELECT nvl(mah.monto_financiado,0) + nvl(mah.sdo_no_exig,0) + nvl(mah.mto_finan_vdo,0) + nvl(mah.int_tra_no_exig,0) + nvl(mah.mto_venc_int,0) + nvl((mah.sdo_contab_mora + mah.sdo_moratorio),0) + nvl(round((mah.sdo_contab_mora + mah.sdo_moratorio) * pIva,2),0)
					FROM bdicred:sd_maesdoshistcrd mah WHERE mah.empresa = pEmpresa AND mah.fecha = dFechaInicio12 - 1 units day AND mah.num_credito = pNumeroCredito)
		  INTO	dMontoExigible0,dMontoExigible1,dMontoExigible2,dMontoExigible3,dMontoExigible4,dMontoExigible5,dMontoExigible6,
				dMontoExigible7,dMontoExigible8,dMontoExigible9,dMontoExigible10,dMontoExigible11,dMontoExigible12
		  FROM bdicred:sd_maesdoshistcrd 
		 WHERE empresa = pEmpresa
		   AND fecha = dFechaInicio0 - 1 units day
		   AND num_credito = pNumeroCredito;

        SELECT nvl(sum(monto),0),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio2 + 1 units day AND fecha_mov <= dFechaInicio1 
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio3 + 1 units day AND fecha_mov <= dFechaInicio2
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio4 + 1 units day AND fecha_mov <= dFechaInicio3 
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio5 + 1 units day AND fecha_mov <= dFechaInicio4
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio6 + 1 units day AND fecha_mov <= dFechaInicio5 
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio7 + 1 units day AND fecha_mov <= dFechaInicio6
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio8 + 1 units day AND fecha_mov <= dFechaInicio7 
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio9 + 1 units day AND fecha_mov <= dFechaInicio8
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio10 + 1 units day AND fecha_mov <= dFechaInicio9 
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio11 + 1 units day AND fecha_mov <= dFechaInicio10
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio12 + 1 units day AND fecha_mov <= dFechaInicio11 
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N'),
            (SELECT nvl(sum(monto),0) FROM "informix".sd_movhiscrd WHERE empresa = pEmpresa AND fecha_mov >= dFechaInicio13 + 1 units day AND fecha_mov <= dFechaInicio12 
               AND num_credito = pNumeroCredito AND codigo_fun  IN (SELECT cod_fun  FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
               AND codigo_ref = 1 AND reversado = 'N')
          INTO dPagosRealizados0,dPagosRealizados1,dPagosRealizados2,dPagosRealizados3,dPagosRealizados4,dPagosRealizados5,dPagosRealizados6,dPagosRealizados7,
               dPagosRealizados8,dPagosRealizados9,dPagosRealizados10,dPagosRealizados11,dPagosRealizados12
          FROM "informix".sd_movhiscrd
         WHERE empresa     = pEmpresa
           AND fecha_mov   >= dFechaInicio1 + 1 units day
           AND fecha_mov   <= dFechaInicio0
           AND num_credito = pNumeroCredito
           AND codigo_fun  IN (SELECT cod_fun FROM "informix".sd_conceptospagomanualcrd where num_producto != '6011')
           AND codigo_ref  = 1
           AND reversado   = 'N';

       IF dMontoExigible0 IS NOT NULL AND dMontoExigible0 != 0 THEN LET dPorcentajePago0 = dPagosRealizados0 / dMontoExigible0; ELSE LET dPorcentajePago0 = 0; END IF;
       IF dMontoExigible1 IS NOT NULL AND dMontoExigible1 != 0 THEN LET dPorcentajePago1 = dPagosRealizados1 / dMontoExigible1; ELSE LET dPorcentajePago1 = 0; END IF;
       IF dMontoExigible2 IS NOT NULL AND dMontoExigible2 != 0 THEN LET dPorcentajePago2 = dPagosRealizados2 / dMontoExigible2; ELSE LET dPorcentajePago2 = 0; END IF;
       IF dMontoExigible3 IS NOT NULL AND dMontoExigible3 != 0 THEN LET dPorcentajePago3 = dPagosRealizados3 / dMontoExigible3; ELSE LET dPorcentajePago3 = 0; END IF;
       IF dMontoExigible4 IS NOT NULL AND dMontoExigible4 != 0 THEN LET dPorcentajePago4 = dPagosRealizados4 / dMontoExigible4; ELSE LET dPorcentajePago4 = 0; END IF;
       IF dMontoExigible5 IS NOT NULL AND dMontoExigible5 != 0 THEN LET dPorcentajePago5 = dPagosRealizados5 / dMontoExigible5; ELSE LET dPorcentajePago5 = 0; END IF;
       IF dMontoExigible6 IS NOT NULL AND dMontoExigible6 != 0 THEN LET dPorcentajePago6 = dPagosRealizados6 / dMontoExigible6; ELSE LET dPorcentajePago6 = 0; END IF;
       IF dMontoExigible7 IS NOT NULL AND dMontoExigible7 != 0 THEN LET dPorcentajePago7 = dPagosRealizados7 / dMontoExigible7; ELSE LET dPorcentajePago7 = 0; END IF;
       IF dMontoExigible8 IS NOT NULL AND dMontoExigible8 != 0 THEN LET dPorcentajePago8 = dPagosRealizados8 / dMontoExigible8; ELSE LET dPorcentajePago8 = 0; END IF;
       IF dMontoExigible9 IS NOT NULL AND dMontoExigible9 != 0 THEN LET dPorcentajePago9 = dPagosRealizados9 / dMontoExigible9; ELSE LET dPorcentajePago9 = 0; END IF;
       IF dMontoExigible10 IS NOT NULL AND dMontoExigible10 != 0 THEN LET dPorcentajePago10 = dPagosRealizados10 / dMontoExigible10; ELSE LET dPorcentajePago10 = 0; END IF;
       IF dMontoExigible11 IS NOT NULL AND dMontoExigible11 != 0 THEN LET dPorcentajePago11 = dPagosRealizados11 / dMontoExigible11; ELSE LET dPorcentajePago11 = 0; END IF;
       IF dMontoExigible12 IS NOT NULL AND dMontoExigible12 != 0 THEN LET dPorcentajePago12 = dPagosRealizados12 / dMontoExigible11; ELSE LET dPorcentajePago12 = 0; END IF;

       IF dMontoExigible0 IS NULL OR dMontoExigible0 = 0 THEN LET dPorcentajePago0 = 1; END IF;
       IF dMontoExigible1 IS NULL OR dMontoExigible1 = 0 THEN LET dPorcentajePago1 = 1; END IF;
       IF dMontoExigible2 IS NULL OR dMontoExigible2 = 0 THEN LET dPorcentajePago2 = 1; END IF;
       IF dMontoExigible3 IS NULL OR dMontoExigible3 = 0 THEN LET dPorcentajePago3 = 1; END IF;
       IF dMontoExigible4 IS NULL OR dMontoExigible4 = 0 THEN LET dPorcentajePago4 = 1; END IF;
       IF dMontoExigible5 IS NULL OR dMontoExigible5 = 0 THEN LET dPorcentajePago5 = 1; END IF;
       IF dMontoExigible6 IS NULL OR dMontoExigible6 = 0 THEN LET dPorcentajePago6 = 1; END IF;
       IF dMontoExigible7 IS NULL OR dMontoExigible7 = 0 THEN LET dPorcentajePago7 = 1; END IF;
       IF dMontoExigible8 IS NULL OR dMontoExigible8 = 0 THEN LET dPorcentajePago8 = 1; END IF;
       IF dMontoExigible9 IS NULL OR dMontoExigible9 = 0 THEN LET dPorcentajePago9 = 1; END IF;
       IF dMontoExigible10 IS NULL OR dMontoExigible10 = 0 THEN LET dPorcentajePago10 = 1; END IF;
       IF dMontoExigible11 IS NULL OR dMontoExigible11 = 0 THEN LET dPorcentajePago11 = 1; END IF;
       IF dMontoExigible12 IS NULL OR dMontoExigible12 = 0 THEN LET dPorcentajePago12 = 1; END IF;

       LET dPromPorcentajePago = (dPorcentajePago0 + dPorcentajePago1 + dPorcentajePago2 + dPorcentajePago3 + dPorcentajePago4 + dPorcentajePago5 + dPorcentajePago6 + dPorcentajePago7 + dPorcentajePago8 + dPorcentajePago9 + dPorcentajePago10 + dPorcentajePago11 + dPorcentajePago12) / 13;
	ELIF pPeriodicidad = 'S' THEN
		LET cCodRet= '000001';
		LET cMensajeRet = 'CÃ¡lculo semanal no disponible.';
		RETURN cCodRet, cMensajeRet,
				nvl(dMontoExigible0,0),nvl(dMontoExigible1,0),nvl(dMontoExigible2,0),nvl(dMontoExigible3,0),nvl(dMontoExigible4,0),nvl(dMontoExigible5,0),nvl(dMontoExigible6,0),nvl(dMontoExigible7,0),nvl(dMontoExigible8,0),nvl(dMontoExigible9,0),nvl(dMontoExigible10,0),nvl(dMontoExigible11,0),nvl(dMontoExigible12,0),
				nvl(dPagosRealizados0,0),nvl(dPagosRealizados1,0),nvl(dPagosRealizados2,0),nvl(dPagosRealizados3,0),nvl(dPagosRealizados4,0),nvl(dPagosRealizados5,0),nvl(dPagosRealizados6,0),nvl(dPagosRealizados7,0),nvl(dPagosRealizados8,0),nvl(dPagosRealizados9,0),nvl(dPagosRealizados10,0),nvl(dPagosRealizados11,0),nvl(dPagosRealizados12,0),
				nvl(dPorcentajePago0,0),nvl(dPorcentajePago1,0),nvl(dPorcentajePago2,0),nvl(dPorcentajePago3,0),nvl(dPorcentajePago4,0),nvl(dPorcentajePago5,0),nvl(dPorcentajePago6,0),nvl(dPorcentajePago7,0),nvl(dPorcentajePago8,0),nvl(dPorcentajePago9,0),nvl(dPorcentajePago10,0),nvl(dPorcentajePago11,0),nvl(dPorcentajePago12,0),nvl(dPromPorcentajePago,0);
	END IF;	 

RETURN cCodRet,cMensajeRet,
nvl(dMontoExigible0,0),nvl(dMontoExigible1,0),nvl(dMontoExigible2,0),nvl(dMontoExigible3,0),nvl(dMontoExigible4,0),nvl(dMontoExigible5,0),nvl(dMontoExigible6,0),nvl(dMontoExigible7,0),nvl(dMontoExigible8,0),nvl(dMontoExigible9,0),nvl(dMontoExigible10,0),nvl(dMontoExigible11,0),nvl(dMontoExigible12,0),
nvl(dPagosRealizados0,0),nvl(dPagosRealizados1,0),nvl(dPagosRealizados2,0),nvl(dPagosRealizados3,0),nvl(dPagosRealizados4,0),nvl(dPagosRealizados5,0),nvl(dPagosRealizados6,0),nvl(dPagosRealizados7,0),nvl(dPagosRealizados8,0),nvl(dPagosRealizados9,0),nvl(dPagosRealizados10,0),nvl(dPagosRealizados11,0),nvl(dPagosRealizados12,0),
nvl(dPorcentajePago0,0),nvl(dPorcentajePago1,0),nvl(dPorcentajePago2,0),nvl(dPorcentajePago3,0),nvl(dPorcentajePago4,0),nvl(dPorcentajePago5,0),nvl(dPorcentajePago6,0),nvl(dPorcentajePago7,0),nvl(dPorcentajePago8,0),nvl(dPorcentajePago9,0),nvl(dPorcentajePago10,0),nvl(dPorcentajePago11,0),nvl(dPorcentajePago12,0),nvl(dPromPorcentajePago,0);

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener',
'el calculo de la reserva al corte para',
'CrÃ©ditos No Revolventes',
'AUTOR : Hector Manuel Bojorquez Ruelas',
'FECHA : 25/Octubre/2011',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_depura_movhis_vendida()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;
DEFINE VlNumCredito                 CHAR(20);

	--SET DEBUG FILE TO "/informix/c91691184/sp_depura_movhis_vendida_trace.out";
    --TRACE ON; 

	LET cCod_ret      = '000000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';
            
	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            RETURN cCod_ret;
	    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

    FOREACH WITH HOLD

		select num_credito
		into VlNumCredito  
		from "informix".temp_creditos

		BEGIN WORK;

			DELETE FROM bdicred:"informix".sd_movhis_new WHERE empresa = '001' and  num_credito = VlNumCredito;
			delete from "informix".temp_creditos where num_credito = VlNumCredito;

		COMMIT WORK;

	END FOREACH;  
	
	drop table "informix".temp_creditos;
	
	RETURN cCod_ret;

	END;

END PROCEDURE;