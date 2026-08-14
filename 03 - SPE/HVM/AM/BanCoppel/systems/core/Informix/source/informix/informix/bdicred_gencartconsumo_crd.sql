CREATE PROCEDURE "informix".gencartconsumo_crd(pEmpresa CHAR(3))
RETURNING
          CHAR(6)   AS resultado,
          CHAR(100) AS mensaje;

--EXECUTE PROCEDURE "informix".gencartconsumo_crd ("001"); 
		  		  
DEFINE ISqlErr                       INTEGER;
DEFINE iISamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(80);
DEFINE cCodRet                       CHAR(6);
DEFINE cMensajeRet                   CHAR(80);

DEFINE cBegin                        CHAR(1);
DEFINE iContador_insert              INTEGER;
DEFINE dtFechaHoy                    DATE;
DEFINE cStatus_proc                  CHAR(1);
DEFINE dImporteReservaBuroCC         DECIMAL(18,5);
DEFINE dTotal_capitalizado           DECIMAL(18,5);
DEFINE dMonto_capitalizado           DECIMAL(18,5);
DEFINE iCuotasVdas                   INTEGER;
DEFINE iNvoPeriodo                   INTEGER;
DEFINE cPeriodicidad                 CHAR(1);
DEFINE cProducto                     CHAR(4);
DEFINE cSucursal                     CHAR(4);
DEFINE cDivISa                       CHAR(2);
DEFINE cStatusCred                   CHAR(02);
DEFINE dConsPI                       DECIMAL(18,5);
DEFINE dConsPORPAGO                  DECIMAL(18,5);
DEFINE dConsPORUSO                   DECIMAL(18,5);
DEFINE dPorPagoMin                   DECIMAL(18,5);
DEFINE dPorcUsoMin                   DECIMAL(18,5);
DEFINE dpiEI                         DECIMAL(18,5);
DEFINE iMeses                        INTEGER;
DEFINE dPIdefaul                     DECIMAL(18,5);
DEFINE dConsSPMenor                  DECIMAL(18,5);
DEFINE dConsComPI                    DECIMAL(18,5);
DEFINE cNumCredito                   CHAR(20);
DEFINE dPagos                        DECIMAL(18,5);
DEFINE dImpagosCons                  DECIMAL(18,5);
DEFINE dImpagoshist                  DECIMAL(18,5);
DEFINE dMesesAntiguedad              DECIMAL(18,5);
DEFINE dEndeudamientoTotCierre       DECIMAL(18,5);
DEFINE dEndeudamientoTotCorte        DECIMAL(18,5);
DEFINE dLimiteCredito                DECIMAL(18,5);
DEFINE dPorUso                       DECIMAL(18,5);
DEFINE dPorPago                      DECIMAL(18,5);
DEFINE dPagosnunca                   DECIMAL(18,5);
DEFINE dEI                           DECIMAL(18,5);
DEFINE dPI                           DECIMAL(18,5);
DEFINE dSP                           DECIMAL(18,5);
DEFINE dPorcentajeReserva            DECIMAL(18,5);
DEFINE cGradoRiesgo                  CHAR(2);
DEFINE cGradoRiesgoAux               CHAR(2);
DEFINE cGradoRiesgoGradual           CHAR(2);
DEFINE cGradoRiesgoEdoResultados     CHAR(2);
DEFINE cGradoRiesgoBancoppel         CHAR(2);
DEFINE dPorUsoMinCtesNunca           DECIMAL(18,5);
DEFINE dResCalIFicacion              DECIMAL(18,5);
DEFINE dLineaAutorizada              DECIMAL(18,5);
DEFINE cEvaBuro                      CHAR(01);
DEFINE iContInteres                  INTEGER;
DEFINE dtFechaApertura               DATE;
DEFINE dANT                          DECIMAL(18,5);
DEFINE dPagoRealizado                DECIMAL(18,5); 
DEFINE dConsMinPorUso                DECIMAL(18,5);
DEFINE dConsMaxPorUso                DECIMAL(18,5);
DEFINE dPorSaldoMin                  DECIMAL(18,5);
DEFINE dConsMaxPorPago               DECIMAL(18,5);
DEFINE dConsMinPorPago               DECIMAL(18,5);
DEFINE dConsACT                      DECIMAL(18,5);
DEFINE dConshist                     DECIMAL(18,5);
DEFINE dConsANT                      DECIMAL(18,5);
DEFINE iACT                          INTEGER;   
DEFINE iHist                         INTEGER;   
DEFINE i                     INTEGER;
DEFINE cDiaCorte                     CHAR(02);
DEFINE sExISten                      SMALLINT;
DEFINE dReservaGradual               DECIMAL(18,5);
DEFINE dPorcentajeGradual            DECIMAL(18,5);
DEFINE dPorcentajeEdoResultados      DECIMAL(18,5);
DEFINE dReservaCalifMesAnterior      DECIMAL(18,5);
DEFINE dReservaEdoResultados         DECIMAL(18,5);
DEFINE dGradual                      DECIMAL(18,5);
DEFINE dReservaBuroGradual           DECIMAL(18,5);
DEFINE dReservaIntCredVenGradual     DECIMAL(18,5);
DEFINE dImpPerConACT                 DECIMAL(18,5);
DEFINE dImpPerConACTaux              DECIMAL(18,5);
DEFINE dConsSPMayor                  DECIMAL(18,5);
DEFINE dENDeudTotCierreSinIntereses  DECIMAL(18,5);
DEFINE dPorResSic                    DECIMAL(18,5);
DEFINE cRuta                     	 CHAR(100); 
DEFINE cDia                          CHAR(02);  
DEFINE cMes                          CHAR(02);
DEFINE cAnio                         CHAR(4);
DEFINE cSql                          CHAR(1024);
DEFINE cNumeroCreditoTC              CHAR(20);
DEFINE dtFechaAperturaTC             DATE;
DEFINE dtFechaCorte                  DATE; 
DEFINE dIntVenCargRees               DECIMAL(18,5);
DEFINE dIntDeclaCtaBalan             DECIMAL(18,5);
DEFINE dIntDeclaCtaOrden             DECIMAL(18,5);
DEFINE dInt_Vencido                  DECIMAL(18,5);
DEFINE dInt_Mora                     DECIMAL(18,5);
DEFINE dInt_Devengado                DECIMAL(18,5);

--FMV 12mar12 : Periodo de pagos vencidos
DEFINE icuotas_vencidas     INTEGER;  
DEFINE vtotal_capitalizado           DECIMAL(18,5);
DEFINE dIncumplimiento               DECIMAL(18,5);
DEFINE iBanderaConc          INTEGER;  
DEFINE dImpObsHIST           DECIMAL(18,5);
DEFINE vInteresesOrden       DECIMAL(18,5);
DEFINE vIvaInteresOrden      DECIMAL(18,5);

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET ISqlErr, iISamErr, cErrorInfo
	IF ISqlErr != 0 THEN
		LET cCodRet= ISqlErr;
		LET cMensajeRet= cNumCredito;

		IF cBegin= 'S' THEN
			ROLLBACK WORK;
		END IF;
/*
		SELECT status_proc
		INTO cStatus_proc
		FROM bdinteg:"informix".sx_contproc
		WHERE empresa = pEmpresa    AND
			proceso = "CalifCart" AND
			sIStema = "06"        AND
			fecha   = dtFechaHoy;

		IF cStatus_proc IS NULL THEN

			INSERT INTO bdicred:"informix".sd_contproc (empresa, proceso, fecha, status_proc,
						ejecutivo, hora_inicio, hora_fin, cod_ret, mensaje)
					VALUES (pempresa, "CalifCart", dtFechaHoy, "C",
							USER, CURRENT, CURRENT, "", "PROCESO CANCELADO");

			INSERT INTO bdinteg:"informix".sx_contproc (empresa, proceso, fecha, sIStema, status_proc,
						ejecutivo, hora_ini, hora_fin, codret)
					VALUES (pempresa, "CalifCart", dtFechaHoy, "06", "C",
							USER, CURRENT, CURRENT, "");

		ELSE

			UPDATE bdicred:"informix".sd_contproc SET status_proc = "C", mensaje = "PROCESO CANCELADO"
			WHERE empresa = pempresa    AND
				proceso = "CalifCart" AND
				fecha   = dtFechaHoy;

			UPDATE bdinteg:"informix".sx_contproc SET status_proc = "C"
			WHERE empresa = pempresa    AND
				proceso = "CalifCart" AND
				sIStema = "06"        AND
				fecha   = dtFechaHoy;

		END IF
*/
		RETURN cCodRet, cMensajeRet;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "gencartconsumo_crd.out";
--TRACE ON;
LET cCodRet= '000000';
LET cMensajeRet= 'El proceso de CALIFICACION DEL CIERRE se realizï¿½ correctamente';

LET cBegin= 'F';
LET iContador_insert= 0;
LET dtFechaHoy= DATE(1);
LET cStatus_proc= '';
LET dImporteReservaBuroCC= 0;
LET dTotal_capitalizado = 0;
LET dMonto_capitalizado = 0;
LET iCuotasVdas= 0;
LET iNvoPeriodo= 0;
LET cPeriodicidad= '';
LET cProducto= '';
LET cSucursal= '';
LET cDivISa= '';
LET cStatusCred= '';
LET dConsPI= 0;
LET dConsPORPAGO= 0;
LET dConsPORUSO= 0;
LET dPorPagoMin= 0;
LET dPorcUsoMin= 0;
LET dpiEI= 0;
LET iMeses= 0;
LET dPIdefaul= 0;
LET dConsSPMenor= 0;
LET dConsComPI= 0;
LET cNumCredito= '';
LET dPagos= 0;
LET dImpagosCons= 0;
LET dImpagoshist= 0;
LET dMesesAntiguedad= 0;
LET dEndeudamientoTotCierre= 0;
LET dEndeudamientoTotCorte= 0;
LET dLimiteCredito= 0;
LET dPorUso= 0;
LET dPorPago= 0;
LET dEI= 0;
LET dPI= 0;
LET dSP= 0;
LET dPorcentajeReserva= 0;
LET cGradoRiesgo= '';
LET dPorUsoMinCtesNunca= 0;
LET dResCalIFicacion= 0;
LET dLineaAutorizada= 0;
LET cEvaBuro= '';
LET iContInteres= 0;
LET dtFechaApertura=DATE(1);
LET dANT= 0;
LET dPagoRealizado= 0;
LET dConsMinPorUso= 0;
LET dConsMaxPorUso= 0;
LET dPorSaldoMin= 0;
LET dConsMaxPorPago= 0;
LET dConsMinPorPago= 0;
LET dConsACT= 0;
LET dConshist= 0;
LET dConsANT= 0;
LET iACT= 0;
LET iHist= 0;
LET i = 0;
LET cDiaCorte = '';
LET sExISten = 0;
LET dReservaGradual = 0;
LET dPorcentajeGradual = 0;
LET dReservaCalifMesAnterior = 0;
LET dReservaEdoResultados = 0;
LET dGradual = 0;
LET dReservaBuroGradual = 0;
LET dReservaIntCredVenGradual  = 0;
LET cGradoRiesgo               = '';
LET cGradoRiesgoAux            = '';
LET cGradoRiesgoGradual        = '';
LET cGradoRiesgoEdoResultados  = '';
LET cGradoRiesgoBancoppel      = '';
LET dImpPerConACT = 0;
LET dImpPerConACTaux = 0;
LET dConsSPMayor = 0;
LET dENDeudTotCierreSinIntereses = 0;

LET dPagosnunca = 0;
LET dPorResSic = 0;

LET cRuta = '';
LET cDia = '';
LET cMes = '';
LET cAnio = '';
LET cSql = '';
LET cNumeroCreditoTC = "";
LET dtFechaAperturaTC =  DATE(1);
LET dtFechaCorte = DATE(1);
LET dIntVenCargRees   = 0;
LET dIntDeclaCtaBalan = 0;
LET dIntDeclaCtaOrden  = 0;
	
LET	dInt_Vencido = 0;
LET	dInt_Mora = 0;
LET	dInt_Devengado = 0;

--FMV 12-MAR-12
LET icuotas_vencidas = 0;
LET vtotal_capitalizado = 0;

LET dIncumplimiento = 0;
LET iBanderaConc    = 0; 
LET dImpObsHIST   = 0;
LET vInteresesOrden       = 0;
LET vIvaInteresOrden      = 0;


	
-- Se obtiene la fecha hoy del sIStema.
SELECT a.fecha_hoy
   INTO dtFechaHoy
   FROM bdicred:"informix".sd_fechas a
  WHERE a.empresa = pempresa;

   let dtFechaHoy = mdy(month(date(today)),1,year(date(today))) - 1 units day;

--Temporal solo para pruebas
--let dtFechaHoy = mdy('06','30','2012');
--Temporal solo para pruebas

--Se calcula el factor de comparaciï¿½n para los crï¿½ditos que se dieron de alta entre el 21 y ï¿½ltimo dï¿½a del mes
--FMV 26-ENE-12 SE OMITE PARA PRUEBAS
--	SELECT {+INDEX(bdinteg:"informix".sx_contproc idx_xcontproc1)} status_proc
--	INTO cStatus_proc
--	FROM bdinteg:"informix".sx_contproc
--	WHERE empresa     = pempresa     AND
--		proceso     = "CierreCred" AND
--		status_proc = "F"          AND
--		sIStema     = "06"         AND
--		fecha       = dtFechaHoy;

--	IF cStatus_proc IS NULL  THEN
--		let ccodret = "582";
--		LET cMensajeRet= 'No se ha ejecutado el previo de cierre';
--		RETURN cCodRet, cMensajeRet;
--	END IF;


/*
	SELECT {+INDEX(bdinteg:"informix".sx_contproc idx_xcontproc1)} status_proc
	INTO cStatus_proc
	FROM bdinteg:"informix".sx_contproc
	WHERE empresa = pempresa    AND
		proceso = "CalifCart" AND
	    sIStema = "06"        AND
        fecha   = dtFechaHoy;

   IF ( cStatus_proc IS NULL ) THEN

		INSERT INTO bdicred:"informix".sd_contproc  (empresa, proceso, fecha, status_proc,
				ejecutivo, hora_inicio, hora_fin, cod_ret, mensaje)
		VALUES  (pempresa, "CalifCart", dtFechaHoy, "I",
				USER, CURRENT, CURRENT, "", "EN PROCESO");

		INSERT INTO bdinteg:"informix".sx_contproc  (empresa, proceso, fecha, sIStema, status_proc,
				ejecutivo, hora_ini, hora_fin, codret)
		VALUES  (pempresa, "CalifCart", dtFechaHoy, "06", "I",
				USER, CURRENT, CURRENT, "");

   END IF;

	IF cStatus_proc = "F" THEN
		UPDATE {+INDEX(bdicred:"informix".sd_contproc idx_sd_contproc)} bdicred:"informix".sd_contproc 
		SET mensaje = "PROCESO YA EJECUTADO"
		WHERE empresa = pempresa    AND
			proceso = "CalifCart" AND
			fecha   = dtFechaHoy;

        LET cMensajeRet= 'El proceso ya fue ejecutado';
		LET cCodRet =  '582';
        RETURN cCodRet, cMensajeRet;
	ELSE
		IF cStatus_proc = "C" THEN
			UPDATE {+INDEX(bdicred:"informix".sd_contproc idx_sd_contproc)} bdicred:"informix".sd_contproc 
			SET status_proc = "I", mensaje = "EN PROCESO"
			WHERE empresa = pempresa    AND
				proceso = "CalifCart" AND
				fecha   = dtFechaHoy;

			UPDATE {+INDEX(bdinteg:"informix".sx_contproc idx_xcontproc1)} bdinteg:"informix".sx_contproc 
			SET status_proc = "I"
			WHERE empresa = pempresa    AND
				proceso = "CalifCart" AND
				sIStema = "06"        AND
				fecha   = dtFechaHoy;
		END IF;
	END IF;
--FMV 26ENE12 
*/
--
-- Carga de parametros
--

	SELECT valor INTO dConsPI FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '3';

	IF dConsPI IS NULL THEN
	LET cCodRet= '000001';
	LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO PI';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsACT FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '4';

	IF dConsACT IS NULL THEN
	LET cCodRet= '000002';
	LET cMensajeRet= 'FALTA CONSTANTE IMPAGO ACTUAL PI';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsHIST FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '5';

	IF dConsHIST IS NULL THEN
	LET cCodRet= '000003';
	LET cMensajeRet= 'FALTA CONSTANTE IMPAGO HISTORICO PI';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsANT FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '6';

	IF dConsANT IS NULL THEN
	LET cCodRet= '000004';
	LET cMensajeRet= 'FALTA CONSTANTE ANTIGï¿½EDAD PI';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsPORPAGO FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '7';

	IF dConsPORPAGO IS NULL THEN
	LET cCodRet= '000005';
	LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE PAGO PI';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsPORUSO FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '8';

	IF dConsPORUSO IS NULL THEN
	LET cCodRet= '000006';
	LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE USO PI';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dPorPagoMin FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '9';

	IF dPorPagoMin IS NULL THEN
	LET cCodRet= '000007';
	LET cMensajeRet= 'FALTA PORCENTAJE PAGO Mï¿½NIMO';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dPorcUsoMin FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '10';

	IF dPorcUsoMin IS NULL THEN
	LET cCodRet= '000008';
	LET cMensajeRet= 'FALTA PORCENTAJE USO Mï¿½NIMO';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dpiEI FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '11';

	IF dpiEI IS NULL THEN
	LET cCodRet= '000009';
	LET cMensajeRet= 'FALTA EXPOSICIï¿½N AL MOMENTO DE INCUMPLIMIENTO';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO iMeses FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '12';

	IF iMeses IS NULL THEN
	LET cCodRet= '000010';
	LET cMensajeRet= 'FALTA Nï¿½MERO DE MESES';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dPIdefaul FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '13';

	IF dPIdefaul IS NULL THEN
	LET cCodRet= '000011';
	LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO >=4';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsSPMenor FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '14';

	IF dConsSPMenor IS NULL THEN
	LET cCodRet= '000012';
	LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT<12 ';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsSPMayor FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '15';

	IF dConsSPMayor IS NULL THEN
	LET cCodRet= '000013';
	LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT>=12';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsComPI FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '16';

	IF dConsComPI IS NULL THEN
	LET cCodRet= '000014';
	LET cMensajeRet= 'FALTA CONSTANTE COMPARACIï¿½N PARA PI';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dPorSaldoMin FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '17';

	IF dPorSaldoMin IS NULL THEN
	 LET cCodRet= '000015';
	 LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE SALDO MINIMO';
	 RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dImpPerConACT FROM bdicred:sd_param_reservas_crd 
	WHERE empresa = pEmpresa and cod_param= '18';

	IF dImpPerConACT IS NULL THEN
	 LET cCodRet= '00016';
	 LET cMensajeRet= 'FALTA PARAMETRO IMPAGOS EN PERIODOS CONSECUTIVOS ACT';
	 RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dPorUsoMinCtesNunca FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '19';

	IF dPorUsoMinCtesNunca IS NULL THEN
	LET cCodRet= '000017';
	LET cMensajeRet= 'FALTA PORCENTAJE USO MINIMO CLIENTES NUNCA';
	RETURN cCodRet, cMensajeRet;
	END IF;


	SELECT valor INTO dConsMinPorPago FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '21';

	IF dConsMinPorPago IS NULL THEN
	LET cCodRet= '000018';
	LET cMensajeRet= 'FALTA VALOR MINIMO COMPARATIVO % DE PAGO';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsMaxPorPago FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '22';

	IF dConsMaxPorPago IS NULL THEN
	 LET cCodRet= '000019';
	 LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE PAGO';
	 RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsMinPorUso FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '23';

	IF dConsMinPorUso IS NULL THEN
	LET cCodRet= '000020';
	LET cMensajeRet= 'FALTA MINIMO COMPARATIVO % DE USO';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dConsMaxPorUso FROM bdicred:sd_param_reservas_crd 
	where empresa = pEmpresa and cod_param= '24';

	IF dConsMaxPorUso IS NULL THEN
	LET cCodRet= '000021';
	LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE USO';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO dPorResSic FROM bdicred:sd_param_reservas_crd 
	WHERE empresa = pEmpresa AND cod_param= '25';

	IF dPorResSic IS NULL THEN
	LET cCodRet= '000022';
	LET cMensajeRet= 'FALTA PORCENTAJE DE RESERVA DE SIC';
	RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT valor INTO cGradoRiesgoAux FROM bdicred:sd_param_reservas_crd 
	WHERE empresa = pEmpresa AND cod_param= '26';
	
    IF cGradoRiesgoAux IS NULL THEN
       LET cCodRet= '000023';
       LET cMensajeRet= 'GRADO RIESGO CLIENTES NUNCA';
       RETURN cCodRet, cMensajeRet;
    END IF;	

    SELECT valor 
      INTO dImpObsHIST 
      FROM "informix".sd_param_reservas_crd  
     WHERE empresa   = pEmpresa 
       AND cod_param = '20';


-------------------------
FOREACH WITH HOLD	
	
    -- Se obtienen los crï¿½ditos calificados con corte al 20.
    SELECT a.num_credito, c.mto_fin_ven_trasp, 
		CASE WHEN b.pagos_realizados IS NULL THEN 0 ELSE b.pagos_realizados END,
		CASE WHEN b.impagos_consecutivos IS NULL THEN 0 ELSE b.impagos_consecutivos END,
		CASE WHEN b.impagos_historicos IS NULL THEN 0 ELSE b.impagos_historicos END,
			b.meses_antiguedad,a.fecha_apertura,
			a.periodo_plazo, a.num_producto, a.sucursal, a.divISa, a.status_cred,
			(b.probabilidad_incumplimiento/100),(b.severidad_perdida/100), b.limite_credito, b.antecedente_buro,
    c.sdo_capital+c.monto_vencido+c.mto_venc_trasp+c.cap_tras_no_venci+c.int_tra_no_exig,
            b.saldo_corte,
			d.dia_corte,nvl(reserva_calif_mes_anterior,0),
			(porcentaje_uso/100), (porcentaje_pago/100),
            c.sdo_intereses, 
            b.interes_dec_cta_balance,
            b.interes_dec_cta_orden,
            c.mto_fin_ven_trasp, 
            a.credito_externo
	INTO cNumCredito, iCuotasVdas, 
            dPagos, 
            dImpagosCons,
            dImpagoshist, 
            dMesesAntiguedad,dtFechaApertura,
            cPeriodicidad, cProducto, cSucursal, cDivISa, cStatusCred,
			dPI, dSP,dLimiteCredito,cEvaBuro,
        	dEndeudamientoTotCierre,
            dEndeudamientoTotCorte,
			cDiaCorte,dReservaCalifMesAnterior,
			dPorUso, dPorPago,
			dInt_Devengado, --Obtener Interes Devengados
			dIntDeclaCtaBalan, ---Obtener Intereses declarados en cuanta de balance
			dIntDeclaCtaOrden,  ---Obtener Intereses declarados en cuanta de orden
            icuotas_vencidas,    --Periodo de pagos vencidos
            cNumeroCreditoTC
	FROM bdicred:"informix".sd_maecredcontcrd a
			LEFT OUTER JOIN bdicred:"informix".sd_hist_reserva_crd b on b.empresa = a.empresa AND b.num_credito = a.num_credito 
                AND MONTH(b.fecha_corte_fin) = MONTH(a.fecha) AND YEAR(b.fecha_corte_fin) = YEAR(a.fecha)	   
			JOIN bdicred:"informix".sd_maesdoscontcrd c on c.fecha = a.fecha AND c.empresa = a.empresa  AND c.num_credito = a.num_credito 
			JOIN bdicred:"informix".sd_maecredanexocrd d on d.empresa = a.empresa AND d.num_credito = a.num_credito
	WHERE a.empresa = pEmpresa
   	AND a.fecha = dtFechaHoy
    AND a.num_credito > ''   
    AND a.num_producto = '6011'
    AND a.status_cred IN ("AA","BA","BT","VP","E1","E2","E3")
	AND b.fecha_cierre IS NULL

	IF dLimiteCredito IS NULL OR dLimiteCredito <= 0 THEN  
		LET dLimiteCredito = 0.01;
	END IF;

	IF iContador_insert = 0 THEN
		LET cBegin= 'S';
		BEGIN WORK;
	END IF;

	LET dtFechaCorte = mdy(MONTH(dtFechaHoy),cDiaCorte,YEAR(dtFechaHoy));

--	IF (cStatusCred not in ('AA','VP') OR ( NVL(Atr_Aux,-1) <> 0 and cStatusCred <> 'E1')) THEN
       select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresesOrden, vIvaInteresOrden
         from bdicred:sd_amortiza_creditocrd
        where empresa = pEmpresa
          and num_credito = cNumCredito
          and capital_status in ('2','7','6')
		  and campo_trabajo3 = 'V';
/*          and fecha_cuota > (
              select max(fecha_mov)
                from bdicred:sd_movhiscrd
               where empresa = pEmpresa
                 and num_credito = cNumCredito
                 and codigo_fun = '602'
                 and codigo_ref = 2
                 and reversado = 'N');*/
--    END IF;

    LET dEndeudamientoTotCierre = vInteresesOrden + vIvaInteresOrden;

	IF cStatusCred = 'VP' THEN
		SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} sum(monto)
          INTO dTotal_capitalizado
          FROM bdicred:"informix".sd_movhis mov
         WHERE mov.empresa = pEmpresa
           AND mov.fecha_mov >= (SELECT {+INDEX(bdicred:sd_amortiza_credito_vendida amorst_vend)} MAX(fecha_cuota) 
                                   FROM bdicred:"informix".sd_amortiza_credito_vendida
                                  WHERE empresa = mov.empresa
                                    AND num_credito = cNumeroCreditoTC
                                    AND capital_status IN ('5','2','6','7')
                                    AND interes_debe = 0 AND capital_debe > 0)
		   AND mov.fecha_mov <= dtFechaHoy
           AND mov.num_credito = cNumeroCreditoTC
           AND mov.codigo_fun = '605'
           AND mov.codigo_ref in (2,125,127)
		   AND mov.reversado = 'N';

		IF dTotal_capitalizado IS NULL THEN LET dTotal_capitalizado = 0; END IF;	
	END IF;

    IF cStatusCred = 'VP' THEN
        LET dEndeudTotCierreSinIntereses = dEndeudamientoTotCierre - vtotal_capitalizado;
    ELIF (cStatusCred IN ('BT','E2','E3')) THEN
        LET dEndeudTotCierreSinIntereses = dEndeudamientoTotCierre - vtotal_capitalizado;
    ELIF (cStatusCred IN ('AA','BA','E1')) THEN
        LET dEndeudTotCierreSinIntereses = dEndeudamientoTotCierre + dIntDeclaCtaBalan - vtotal_capitalizado;
    END IF;


    -- Se obtiene el antecedente de Burï¿½
		SELECT fecha_apertura
          INTO dtFechaAperturaTC
		  FROM bdicred:"informix".sd_maecred 
		 WHERE empresa        = empresa
		   AND  num_credito    = cNumeroCreditoTC;
--	  	   AND credito_externo = cNumCredito;	
	
	--Para obtenerel interes vencido cargado a las reestructura que es la suma del Interes Vencido, Intereses Moratorios y el Interes Devengado
	--Obtener Interes Vencido
-- OBTIENE INTERESES CAPITALIZADOS AL MOMENTO DE LA REESTRUCTURA

	--Obtener Interes Vencido y Moratorio
    SELECT sum(case when codigo_ref = 21 then monto else 0 end),sum(case when codigo_ref = 22 then monto else 0 end)
	  INTO dInt_Vencido,dInt_Mora
	  FROM bdicred:"informix".sd_movhis 
     WHERE empresa = pEmpresa
       AND fecha_mov >= dtFechaAperturaTC AND fecha_mov <= dtFechaApertura
       AND num_credito = cNumeroCreditoTC
	   AND codigo_fun = '338'
	   AND codigo_ref = 21
	   AND reversado  =  'N';

	--Obtener Interes Devengados
	--Interes vencido cargado a las reestructura
	LET dIntVenCargRees =  NVL(dInt_Vencido, 0) + NVL(dInt_Mora, 0) + NVL(dInt_Devengado, 0);
	---Obtener Intereses declarados en cuanta de balance
	IF (cStatusCred IN( "AA", "BA","E1")) THEN
		LET dEndeudamientoTotCierre = dEndeudamientoTotCierre + dIntDeclaCtaBalan;
	END IF;

	---Obtener Intereses declarados en cuanta de orden
	IF dMesesAntiguedad IS NULL THEN
		LET dPagosnunca = 0;
        LET dANT = round((dtFechaHoy - dtFechaApertura)/30,2);	
        SELECT evalua_cc
		  INTO cEvaBuro
          FROM bdISolic:"informix".ss_resum_scor_fin
         WHERE empresa = pempresa
           AND num_solicitud = cNumeroCreditoTC;
    -- Se obtiene la lï¿½nea autorizada
        SELECT nvl(monto_solicitado,0)
          INTO dLineaAutorizada
          FROM bdISolic:"informix".ss_solicitudes
         WHERE empresa = pempresa
           AND num_solicitud = cNumeroCreditoTC;
    -- Se obtiene el lï¿½mite de crï¿½dito y Cuotas vencidas a fin de mes  -->FMV 12mar12
        SELECT nvl(monto_otorgado,0),(mto_fin_ven_trasp)
          INTO dLimiteCredito, icuotas_vencidas
          FROM bdicred:"informix".sd_maesdoscontcrd
         WHERE empresa = pempresa
           AND fecha = (SELECT MAX (fecha)                                              
                          FROM bdicred:"informix".sd_maesdoscontcrd
                         WHERE empresa = pempresa                                     
                           AND num_credito = cNumCredito)
           AND num_credito = cNumCredito;

        LET dPorUso  = 0; 
        LET dPorPago = 0; 
        LET dSP = dConsSPMenor;
        LET dPI = 0; 

-- OBTIENE ACT E HIST EN LA HISTORIA DEL CREDITO
-- OBTIENE ACT E HIST EN LA HISTORIA DE LA REESTRUCTURA
      LET iACT         = 0;
      LET iHIST        = 0;
      LET i            = 0;
      LET iBanderaConc = 0;	  

-- FMV 30ENE12: dImpPerConACT = 10 IMPAGOS EN PERIODOS CONSECUTIVOS ACT
--                dImpObsHIST = 6  IMPAGOS OBSERVADOS ULTIMOS MESES HIST

      FOREACH
           SELECT FIRST dImpPerConACT (monto_vencido + mto_venc_trasp)  
             INTO dIncumplimiento
             FROM bdicred:"informix".sd_maesdoshistcrd
            WHERE fecha       <= dtFechaCorte
              AND empresa     = pEmpresa  
              AND num_credito = cNumCredito
              AND day(fecha)  = day(dtFechaCorte)	--FMV 17abr12: Dia de la fecha del corte              
            ORDER BY fecha DESC

            IF dIncumplimiento > 0   THEN
                IF iBanderaConc = 0 THEN
                  LET iACT = iACT + 1;
                END IF;

-- Impagos observados en los ï¿½ltimos meses HIST
                IF i < dImpObsHIST THEN  -- 6
                  LET iHIST = iHIST + 1;
                END IF;
            ELSE
                LET iBanderaConc= 1;
            END IF;

            LET i = i + 1;

            --Impagos en perï¿½odos consecutivos ACT
            IF (iBanderaConc = 1 AND i >= dImpPerConACT) THEN  -- 10
               EXIT FOREACH;
            END IF;
      END FOREACH;

	  IF (i < dImpPerConACT ) THEN
          LET dImpPerConACTaux = dImpPerConACT - i;
          LET i = 0;
  	      FOREACH
		   SELECT FIRST dImpPerConACTaux (monto_vencido + mto_venc_trasp)  
			 INTO dIncumplimiento
			 FROM bdicred:"informix".sd_maesdoshist
			WHERE  fecha       <= date(mdy(month(dtFechaCorte),20,year(dtFechaCorte)))
			  AND empresa     = pEmpresa 
			  AND num_credito = cNumeroCreditoTC
			ORDER BY fecha DESC

			IF dIncumplimiento > 0 THEN
				IF iBanderaConc = 0 THEN
				  LET iACT = iACT + 1;
				END IF;
					  
			-- Impagos observados en los ï¿½ltimos meses HIST
				IF i < dImpPerConACT AND i < dImpObsHIST THEN  
				  LET iHIST = iHIST + 1;
				END IF;
			ELSE
				LET iBanderaConc= 1;
			END IF;

			LET i = i + 1;

			--Impagos en perï¿½odos consecutivos ACT
			IF (iBanderaConc = 1 AND i >= dImpPerConACT) THEN  
			   EXIT FOREACH;
			END IF;
		END FOREACH;
	  END IF;

	END IF;

	IF dtFechaApertura > mdy(MONTH(dtFechaHoy),cDiaCorte,YEAR(dtFechaHoy)) AND dMesesAntiguedad IS NULL THEN 
		LET dPagosnunca = dPagos; 
	ELSE 
		LET dPagosnunca = -1;
	END IF;



--Se calcula EI
-- Si la resta del saldo y los intereses vencidos es menor o igual a cero, el saldo es igual al ENDeudamiento del cliente 
    IF dENDeudTotCierreSinIntereses <= 0 THEN
        LET dEI = 0;
    ELSE
        LET dEI = dENDeudTotCierreSinIntereses;
    END IF;

--Se calcula la reserva de riesgos crediticios
    IF dENDeudTotCierreSinIntereses <= 0 AND dPagos = 0 AND dEndeudamientoTotCorte <= 0 THEN 
       LET dPorcentajeReserva = dPorUsoMinCtesNunca; -- 2.68%
       LET dResCalIFicacion = dPorcentajeReserva * (dLimiteCredito + dEndeudamientoTotCorte); ----Se omite el monto ya que el monto al inicio del periodo es cero???
       LET cGradoRiesgo = cGradoRiesgoAux;
    ELSE
        LET dPorcentajeReserva = dPI * dSP;
        LET dResCalIFicacion = dPorcentajeReserva * dEI;
            SELECT a.grado_riesgo
              INTO cGradoRiesgo
              FROM bdicred:"informix".sd_grado_riesgo a
             WHERE empresa = pEmpresa
               AND tipo = '3'
               AND (round(dPorcentajeReserva * 100,2) >= a.porcentaje_min
               AND round(dPorcentajeReserva * 100,2) <= a.porcentaje_max);
    END IF;

--Determina RESERVA CALIFICACION GRADUAL
--    LET dReservaGradual=dResCalIFicacion*dGradual;
    LET dReservaGradual=dResCalIFicacion;
    LET cGradoRiesgoGradual = cGradoRiesgo;
    LET dReservaEdoResultados = dReservaGradual;

--Determina PORCENTAJE RESERVA estado de resultados
	IF (dEI > 0) THEN
		LET dPorcentajeEdoResultados=dReservaEdoResultados/dEI;
	ELSE
		LET dPorcentajeEdoResultados=0.0;
	END IF;

    LET cGradoRiesgoEdoResultados = cGradoRiesgo;

--Determina GRADO RIESGO Bancoppel
	IF cGradoRiesgoEdoResultados= 'A' THEN
		LET iNvoPeriodo= 0;
	ELIF cGradoRiesgoEdoResultados= 'B1' THEN
		LET iNvoPeriodo= 1;
	ELIF cGradoRiesgoEdoResultados= 'B2' THEN
		LET iNvoPeriodo= 2;
	ELIF cGradoRiesgoEdoResultados= 'C' THEN
		LET iNvoPeriodo= 3;
	ELIF cGradoRiesgoEdoResultados= 'D' THEN
		LET iNvoPeriodo= 4;
	ELIF cGradoRiesgoEdoResultados= 'E' THEN
		LET iNvoPeriodo= 5;
	END IF;

-- Actualiza Maestro de Credito Central
	UPDATE bdicred:"informix".sd_maecredcrd
	   SET califica_riesgo = cGradoRiesgo
	 WHERE empresa = pempresa
	   AND num_credito = cNumCredito;

	IF dMesesAntiguedad IS NOT NULL THEN
-- Se almacena la informaciï¿½n correspondiente al calculo de la reservas preventivas.
		UPDATE "informix".sd_hist_reserva_crd
			 SET
				fecha_cierre              = dtFechaHoy,
				grado_riesgo              = cGradoRiesgo,
				saldo_cierre              = dEndeudamientoTotCierre,
				reserva_int_cred_ven      = dTotal_capitalizado,
				interes_cred_ven          = dTotal_capitalizado,
			    interes_ven_cargados      = dIntVenCargRees,
				reserva_buro              = dImporteReservaBuroCC,
                otras_estimaciones        = (dResCalIFicacion * 0.16) * dPorcentajeReserva,
				reserva_calificacion      = dResCalIFicacion,
				porcentaje_reserva        = dPorcentajeReserva * 100,
				exposicion_incumplimiento    = dEI,
				num_periodos		         = icuotas_vencidas
			WHERE empresa = pEmpresa
	          AND num_credito = cNumCredito
			  AND fecha_corte_fin = mdy(MONTH(dtFechaHoy),cDiaCorte,YEAR(dtFechaHoy));
		ELSE
         -- Se almacena la informaciï¿½n correspondiente al calculo de la reservas preventivas para crï¿½ditos aperturados despuï¿½s del 20.

			INSERT INTO bdicred:"informix".sd_hist_reserva_crd 
                                         (empresa,
							   fecha_corte_inicio,
								  fecha_corte_fin,
								  	  num_credito,
									 fecha_cierre,
									 grado_riesgo,
								   fecha_apertura,
								 antecedente_buro,
									  status_cred,
								   limite_credito,
								 interes_cred_ven,
							 interes_ven_cargados,
						  interes_dec_cta_balance,
							interes_dec_cta_orden,
									  saldo_corte,
									 saldo_cierre,
									  pago_minimo,
								 pagos_realizados,
							 reserva_int_cred_ven,
									 reserva_buro,
							   otras_estimaciones,
							 reserva_calificacion,
							   porcentaje_reserva,
								 meses_antiguedad,
					  probabilidad_incumplimiento,
								severidad_perdida,
                        exposicion_incumplimiento,
							 impagos_consecutivos,
							   impagos_historicos,
								  porcentaje_pago,
								   porcentaje_uso,
									 num_periodos,
						reserva_calif_mes_anterior,				   							
								   num_credito_tdc,
				                fecha_apertura_tdc
			)
				VALUES (pEmpresa,
						dtFechaCorte - 1 units MONTH,
						dtFechaCorte,
						cNumCredito,
						dtFechaHoy,
						cGradoRiesgo,
						dtFechaApertura,
						cEvaBuro,
						cStatusCred,
						dLimiteCredito,
						dTotal_capitalizado,
						dIntVenCargRees,
                        0,
                        0,
						0,
						dEndeudamientoTotCierre,
						0,
						dPagoRealizado,
						dTotal_capitalizado,
						dImporteReservaBuroCC,
						(dResCalIFicacion * 0.16) * dPorcentajeReserva,   
						dResCalIFicacion,
						dPorcentajeReserva * 100,
						dANT,
						dPI * 100,
						dSP * 100,
						dEI,
						iACT,
						iHist,
						dPorPago * 100,
						dPorUso * 100,
						icuotas_vencidas,
						0,																	
						cNumeroCreditoTC,
						dtFechaAperturaTC);
	END IF;
    IF dReservaEdoResultados>0 THEN
        -- Genera Movimiento para Contabilidad
/*
            EXECUTE PROCEDURE genmov_calif_crd (pEmpresa,
                                           cNumCredito,
                                           cProducto,
                                           iNvoPeriodo,
                                           "091", 
                                           dtFechaHoy,
                                           dReservaEdoResultados,
                                           "CalifCartReseFMV",
                                           cSucursal,
                                           cDivISa,
                                           "0000")
            INTO cCodRet, cMensajeRet;
            IF TRIM(cCodRet) <> "000000" THEN
               RETURN cCodRet, cMensajeRet;
            END IF;
*/
    END IF;
    IF dEndeudamientoTotCierre>0 THEN
/*
        EXECUTE PROCEDURE genmov_calif_crd (pEmpresa,
		
									cNumCredito,
									cProducto,
									iNvoPeriodo,
									"090",
									dtFechaHoy,
									dEndeudamientoTotCierre,
									"CalifCartFMV",
									cSucursal,
									cDivISa,
									"0000")
        INTO cCodRet, cMensajeRet;
        IF TRIM(cCodRet) <> "000000" THEN
			RETURN cCodRet, cMensajeRet;
		END IF;
*/
    END IF;
-- Reservas por Riesgos Operativos (Clientes con mal Antecedentes en Burï¿½ o Cï¿½rculo)
	IF cEvaBuro NOT IN ('0','X') THEN
		LET dImporteReservaBuroCC = dResCalIFicacion * dPorResSic;
        LET dImporteReservaBuroCC = dImporteReservaBuroCC;
        LET dReservaBuroGradual   = dImporteReservaBuroCC;

		IF dMesesAntiguedad IS NOT NULL THEN
		   -- Se almacena la informaciï¿½n correspondiente a la reserva de Burï¿½
			UPDATE bdicred:"informix".sd_hist_reserva_crd
			   SET reserva_buro              = dImporteReservaBuroCC
			 WHERE empresa = pEmpresa
			   AND num_credito = cNumCredito
			   AND fecha_cierre = dtFechaHoy;

			--CalIFica malos antecedentes
/*
			EXECUTE PROCEDURE genmov_calif_crd (pEmpresa,
											cNumCredito,
											cProducto,
											0,
											"092",   --> Buro
											dtFechaHoy,
											dReservaBuroGradual,
											"CalifCartFMV",
											cSucursal,
											cDivISa,
											"0000")
			INTO cCodRet, cMensajeRet;
			IF TRIM(cCodRet) <> "000000" THEN
        		RETURN cCodRet, cMensajeRet;
            END IF;
*/
	END IF;

    END IF;

-- Reservas por Intereses devengados sobre crï¿½ditos vencidos.
	LET dMonto_capitalizado = 0;
	LET iContInteres = 0;
	LET dImporteReservaBuroCC = 0;
	LET dReservaBuroGradual = 0;

	IF cStatusCred = 'VP' THEN
	   IF (dTotal_capitalizado > 0 AND dEndeudamientoTotCierre > 0)  THEN
/*
			EXECUTE PROCEDURE genmov_calif_crd(pEmpresa,
										cNumCredito,
										cProducto,
										1,
										"093",    --> FMV:9mar11
										dtFechaHoy,
										dTotal_capitalizado,
										"CalifCartFMV",
										cSucursal,
										cDivISa,
										"0000")
			INTO cCodRet, cMensajeRet;
			IF TRIM(cCodRet) <> "000000" THEN
				RETURN cCodRet, cMensajeRet;
			END IF;
*/
			UPDATE bdicred:"informix".sd_hist_reserva_crd
			SET 
                interes_cred_ven          = dTotal_capitalizado,
				reserva_int_cred_ven      = dTotal_capitalizado 				
			WHERE empresa = pEmpresa
			AND num_credito = cNumCredito
            AND fecha_cierre = dtFechaHoy;
		END IF;
	END IF;

	LET sExISten = 0;
    LET iContInteres = 0;
    LET dTotal_capitalizado = 0;
    LET dImporteReservaBuroCC = 0;
    let dMonto_capitalizado = 0;
    LET cNumCredito ='';
    LET iCuotasVdas =0;
    LET dPagos =0;
    LET dImpagosCons =0;
    LET dImpagoshist =0;
    LET dMesesAntiguedad =0;
    LET dtFechaApertura =DATE(0);
    LET cPeriodicidad ='';
    LET cProducto ='';
    LET cSucursal ='';
    LET cDivISa ='';
    LET cStatusCred ='';
    LET dPI =0;
    LET dSP =0;
    LET dLimiteCredito =0;
    LET cEvaBuro ='';
    LET dEndeudamientoTotCierre =0;
    LET dEndeudamientoTotCorte =0;
    LET cDiaCorte =0;
    LET dReservaCalifMesAnterior =0;
    LET dPorUso =0;
    LET dENDeudTotCierreSinIntereses =0;
    LET dIncumplimiento = 0;
    LET vInteresesOrden       = 0;
    LET vIvaInteresOrden      = 0;
    LET dIntDeclaCtaBalan = 0;
    LET dIntDeclaCtaOrden  = 0;


    LET iContador_insert = iContador_insert + 1;

    IF (iContador_insert >= 2000) THEN
        COMMIT WORK;
        LET iContador_insert = 0;
    END IF;

END FOREACH;

IF (iContador_insert > 0) THEN
	COMMIT WORK;
END IF;

	UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_hist_reserva_crd;
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movhis_calif_crd;

--	LET cCodRet = "000000";
/*
	-- Actualiza el Control de Procesos
	UPDATE bdicred:"informix".sd_contproc
		SET status_proc = "F", mensaje = "PROCESO CONCLUIDO", hora_fin = CURRENT, cod_ret = ccodret
	WHERE empresa = pempresa    
      AND proceso = "CalifCart" 
      AND fecha   = dtFechaHoy;

	UPDATE bdinteg:"informix".sx_contproc
		SET status_proc = "F", hora_fin = CURRENT, codret = ccodret
	WHERE empresa = pempresa   
      AND proceso = "CalifCart" 
      AND sIStema = "06"       
      AND fecha   = dtFechaHoy;
*/
-- Se genera reporte de la calIFicaciï¿½n para mostrar por SIF  FMV SE OMITE PARA PRUEBAS 25ene2012
/*
	EXECUTE PROCEDURE bdicred:"informix".sp_genera_reporte_calIFicacion_crd(pEmpresa, dtFechaHoy) INTO cCodRet,cMensajeRet;

	IF cCodRet <> '000000' THEN
		LET cMensajeRet = 'Se generï¿½ un error en el proceso de generaciï¿½n del reporte de calIFicaciï¿½n';
		RETURN cCodRet, cMensajeRet;
	END IF;

  --Obtiene la Ruta en donde se guardara el archivo plano con lainformacion de la calIFicacion de cartera de los creditos reestructurados
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param
	WHERE cod_param = "47";

  
-- Se genera un archivo plano con la informaciï¿½n de reservas que inserta en la tabla sd_hist_reserva.
	LET cDia = LPAD(DAY(dtFechaHoy),2,'00');
	LET cMes = LPAD(MONTH(dtFechaHoy),2,'00');
	LET cAnio = YEAR(dtFechaHoy);

	let cSql = 'echo " unload to ' ||TRIM(cRuta)||'sd_reservas_reestructuras'|| cMes || cAnio ||'.txt '||" delimiter '|' "||
			'" > '||TRIM(cRuta)||'calificacionrr.sql';
	system cSql;

	let cSql = 'echo "'||
	"SELECT num_credito, num_credito_tdc,  fecha_corte_inicio, fecha_corte_fin, fecha_cierre, grado_riesgo, fecha_apertura_tdc, fecha_apertura,"||
		"antecedente_buro, status_cred, limite_credito, interes_cred_ven, interes_ven_cargados,"||
		"interes_dec_cta_balance,	interes_dec_cta_orden, 	saldo_corte,"||
		"saldo_cierre, pago_minimo, pagos_realizados, impagos_consecutivos,impagos_historicos, num_periodos, reserva_int_cred_ven,"||
		"reserva_buro, otras_estimaciones, reserva_calificacion, porcentaje_reserva, meses_antiguedad, probabilidad_incumplimiento,"||
		"severidad_perdida,  porcentaje_pago, porcentaje_uso, grado_riesgo_gradual, reserva_calificacion_gradual,"||
		"reserva_buro_gradual,  reserva_calif_mes_anterior"||
	' FROM bdicred:sd_hist_reserva_crd WHERE empresa = '''||pEmpresa|| ''' AND fecha_cierre = '''|| dtFechaHoy || ''' ' ||
		" AND grado_riesgo IS NOT NULL; " ||
		' " >> '||TRIM(cRuta)||'calificacionrr.sql';
	system cSql;

	let cSql = 'dbaccess bdicred ' ||TRIM(cRuta)||'calificacionrr.sql';
	system cSql;
	let cSql = "rm "||TRIM(cRuta)||"calificacionrr.sql ";
	system cSql;

	LET cMensajeRet= 'El proceso de CALIFICACION DEL CIERRE se realizï¿½ correctamente';
*/

	IF cCodRet <> '000000' THEN
		LET cMensajeRet = 'Se generï¿½ un ERROR en el proceso de generaciï¿½n del reporte de Calificaciï¿½n Resstructuras';
		RETURN cCodRet, cMensajeRet;
    ELSE
       LET cMensajeRet= 'El proceso de CALIFICACION DEL CIERRE REESTURCTURAS se realizï¿½ correctamente';
    END IF;

RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para el calculo',
'de la reserva a fin de mes',
'AUTOR : Hï¿½ctor Manuel Bojï¿½rquez Ruelas',
'FECHA : 16/Agosto/2011',
'BD    : BDICRED',
'Se realiza correccion de consultas a la tabla sd_maesdoscontcrd para el calculo de interes',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 28/Septiembre/2011',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cierre_diario_pp(pEmpresa CHAR(3), pCodTipCred CHAR(2))
RETURNING
   CHAR(6)        AS Cod_Ret,
   CHAR(80)       AS Mens_Ret;

-- Modifico: Francisco Martinez Viveros
-- Fecha: 21/mar/2013
-- Comentario: Se adicionan los movimientos de provision a fin de mes, para los prestamos que facturan el dia 1o. de mes
-- se genera el movimiento provision del periodo al dia 31 y el movimiento del dia 1 mas su facturacion.
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(125);

DEFINE cBegin         CHAR(1);
DEFINE cFolio         CHAR(16);
DEFINE cEmpresa       CHAR(3);
DEFINE cNumCredito    CHAR(20);
DEFINE cStatusCred    CHAR(2);
DEFINE cStatusCredAnt CHAR(2);
DEFINE cStatusCredIndica CHAR(2);
DEFINE cDivisa        CHAR(2);
DEFINE cNumProducto   CHAR(4);
DEFINE dtFechaApert   DATE;
DEFINE iDiaCorte      INTEGER;
DEFINE cSucursal      CHAR(4);
DEFINE cPlaza         CHAR(3);
DEFINE dIvaSuc        DECIMAL(5,3);
DEFINE cCodTipCred    CHAR(2);
DEFINE iDiasCalc      INTEGER;
DEFINE dtFechaHoy     DATE;
DEFINE dtFechaHoyAux  DATE;
DEFINE dtFechaProx    DATE;
DEFINE dtFechaFinMes  DATE;
--DEFINE dtFechaFinMesAnt DATE;
DEFINE dtFechaProxCuota  DATE;
DEFINE dtFechaVencto  DATE;
DEFINE iDiasInt       INTEGER;
DEFINE iDiasInt_inh   INTEGER;

DEFINE dIntDiario     DECIMAL(18,2);
DEFINE dIntDiario_inh DECIMAL(18,2);

DEFINE dTasaInter       DECIMAL(9,6);
DEFINE dTasaInterMor    DECIMAL(9,6);
DEFINE dTasaInterMorCop DECIMAL(9,6);
DEFINE dSdoCapital      DECIMAL(18,2);
DEFINE dMntVencido      DECIMAL(18,2);
DEFINE dMntVencTras     DECIMAL(18,2);
DEFINE dCapTrasNoVen    DECIMAL(18,2);
DEFINE dSdoCapInso      DECIMAL(18,2);
DEFINE dSdoNoExig       DECIMAL(18,2);
DEFINE dSdoInt          DECIMAL(18,2);
DEFINE dSdoInt_inh      DECIMAL(18,2);
DEFINE dSdodiaantint    DECIMAL(18,2);
DEFINE dSdomesantint    DECIMAL(18,2);
DEFINE dSdomoratorio    DECIMAL(18,2);
DEFINE dSdocontabmora   DECIMAL(18,2);
DEFINE dMontofinanciado DECIMAL(18,2);
DEFINE dIvaIntVencido   DECIMAL(18,2);
DEFINE dIvaIntVigente   DECIMAL(18,2);
DEFINE dSdotrab4        DECIMAL(18,2);
DEFINE dSdo             DECIMAL(18,2);
DEFINE dtFechaCuota     DATE;
DEFINE dtFechaCuotaAnt  DATE;
DEFINE dProvInt       	DECIMAL(14,2);
DEFINE dProvInt_inh    	DECIMAL(14,2);
DEFINE dIvaPag        	DECIMAL(14,2);
--ini cas
DEFINE dIntGrav      	DECIMAL(14,2);
DEFINE dIntExen       	DECIMAL(14,2);
DEFINE dIntGrav_inh   	DECIMAL(14,2); --FMV
DEFINE dIntExen_inh    	DECIMAL(14,2); --FMV

DEFINE dtIvaFechaPag    DATE;
DEFINE dCapMtoCuota     DECIMAL(14,2);
DEFINE dCapMtoCuota_ori DECIMAL(14,2);
DEFINE iNumPago         INTEGER;
DEFINE dProvIva       	DECIMAL(14,2);
DEFINE dProvIva_inh    	DECIMAL(14,2); --FMV
DEFINE dIntVdo          DECIMAL(18,2);
DEFINE dTraspCap        DECIMAL(14,2);
DEFINE dTraspInt        DECIMAL(18,2);
DEFINE cCapStatusCuota  CHAR(1);
DEFINE dSdoMora         DECIMAL(18,2);
DEFINE dIntMora         DECIMAL(18,2);
DEFINE dIntCope         DECIMAL(18,2);
DEFINE iContCierre      INTEGER;
DEFINE iContCorte       INTEGER;
DEFINE iContCommit      INTEGER;
DEFINE cIdProc1         CHAR(1);
DEFINE cIdProc2         CHAR(1);
DEFINE cIdProc3         CHAR(1);
DEFINE cIdProc4         CHAR(1);
DEFINE dIntProvFinMes   DECIMAL(18,2);
DEFINE dIvaProvFinMes   DECIMAL(18,2);
DEFINE dIvaIntReal      DECIMAL(18,2);
DEFINE dIvaIntReal_inh  DECIMAL(18,2); --FMV
DEFINE dtFechaMesiversario DATE;
DEFINE cBanTemp         CHAR(1);
DEFINE iNumVdos         INTEGER;
DEFINE iPerTrasp        INTEGER;
DEFINE credcontproc 	char(1);
DEFINE intecontproc 	char(1);
DEFINE CodigoRefProvIva INTEGER;
DEFINE CodigoRefProvInt INTEGER;
DEFINE dIntPeriodo      DECIMAL(18,2);
DEFINE dIvaPeriodo      DECIMAL(18,2);
DEFINE cSQL				CHAR(200);
DEFINE vlCapitalDebe    DECIMAL (14,2);
--FMV 03-SEP-11 --CREDINOMINA
DEFINE iTpDiasFechaPago INTEGER;
--FMV 09-MAY-11
DEFINE dCapTrasVen_Amort DECIMAL(14,2);
--SDFM 11-06-12 -- VENTA PP
DEFINE v_marca_ayuda CHAR(1);
--FMV 24abr13: Indicadores de buro
DEFINE vf_fecha_ult_pago DATE;
DEFINE vdias_atraso      INTEGER;
--FMV 9jul13: Traspaso 90, finalizando plazo
DEFINE vf_fecha_vencim   DATE;
DEFINE vi_dias_trasp_cap INTEGER;
DEFINE vlIntVenBal      DECIMAL (14,2);
DEFINE vlIvaIntVenBal   DECIMAL (14,2);
DEFINE Campotrabajo3 CHAR(10);
-- JOM 11/04/2013 Se cambia traspado a periodos INI
DEFINE dFechacuotamin   DATE;
DEFINE iNumVdosaux      INTEGER;

-- RQM 09 473 TRIAD
DEFINE vSdoTotLiquidar 			decimal(18,2);
DEFINE vPagoMinimo 				decimal(18,2);
DEFINE vSdoTotVencido 			decimal(18,2);

-- JOM 11/04/2013 Se cambia traspado a periodos FIN
--FMJ APoyo 2014
DEFINE wbandera_apoyo 	CHAR(1);
DEFINE iFechaVencto	  	DATE;
DEFINE cNumCteApoyo	  	CHAR(20);
DEFINE cDifApoy			SMALLINT;	
DEFINE cDifApoyoBaja	SMALLINT;	
DEFINE dInteresApoyo	DECIMAL(18,2);
DEFINE dIvaApoyo        DECIMAL(18,2);
DEFINE dIvaApoyoPag1    DECIMAL(18,2);
DEFINE dCapitalApoyo	DECIMAL(18,2);
DEFINE dCountAmort		SMALLINT;
DEFINE sNumPagApoyo		SMALLINT;
DEFINE dCapMntoCutApoy	DECIMAL(18,2);
DEFINE StatusCred_apoyo CHAR (2);
DEFINE dprovint_inh_aux DECIMAL(14,2);
DEFINE vMensaje			CHAR(50);
DEFINE dIvaIntReal_inh_aux DECIMAL(14,2);

DEFINE psaldoInteresApoyo DECIMAL(14,2);
DEFINE psaldoIvaApoyo 	DECIMAL(14,2);
DEFINE dFactor 			DECIMAL(14,2);
DEFINE dPagoInt 		DECIMAL(14,2);
DEFINE dPagoIvaInt 		DECIMAL(14,2);
DEFINE dCapMtoCuotaApoyo DECIMAL(14,2);
DEFINE pInteresactualPagado DECIMAL(14,2);
DEFINE pIvaActualPagado	DECIMAL(14,2);
DEFINE ivaPagadoAnterior DECIMAL(14,2);
DEFINE psaldoInteresTrasApoyo DECIMAL(14,2);

--nuevas variables para IFSR, calculo de etapas
DEFINE iAtr 			INTEGER;
DEFINE iAtrNvo			INTEGER;
DEFINE iDiasAtraso		INTEGER;
DEFINE dFechaVencimiento DATE;
DEFINE cCapitalStatus 	CHAR(2);
DEFINE cCapitalStatusAnt CHAR(2);
DEFINE vFechaVenc		DATE;
DEFINE dFechaVencPlazo DATE;
DEFINE dIntPeriodoTras      DECIMAL(18,2);
DEFINE dIntPeriodoTrasOrd      DECIMAL(18,2);
DEFINE dIvaIntPeriodoTrasOrd      DECIMAL(18,2);

DEFINE apoyo_iva_debe DECIMAL(14,2);
LET apoyo_iva_debe = 0;

LET cBegin           = "N";
LET cFolio         	 = "";
LET cEmpresa         = "";
LET cNumCredito      = "";
LET cStatusCred    	 = "";
LET cStatusCredAnt 	 = "";
LET cStatusCredIndica = "";
LET cNumProducto   	 = "";
LET cDivisa          = "";
LET dtFechaApert     = DATE(1);
LET iDiaCorte        = 0;
LET cSucursal      	 = "";
LET cPlaza         	 = "";
LET dIvaSuc          = 0;
LET cCodTipCred      = "";
LET iDiasCalc        = 0;
LET dtFechaHoy       = DATE(1);
LET dtFechaHoyAux    = DATE(1);
LET dtFechaProx      = DATE(1);
LET dtFechaFinMes    = DATE(1);
--LET dtFechaFinMesAnt    = DATE(1);
LET dtFechaProxCuota = DATE(1);
LET dtFechaVencto    = DATE(1);
LET iDiasInt         = 0;
LET iDiasInt_inh     = 0;

LET dIntDiario       = 0;
LET dIntDiario_inh   = 0;
LET dTasaInter       = 0;
LET dTasaInterMor    = 0;
LET dTasaInterMorCop = 0;
LET dSdoCapital      = 0;
LET dMntVencido      = 0;
LET dMntVencTras     = 0;
LET dCapTrasNoVen    = 0;
LET dSdoCapInso      = 0;
LET dSdoNoExig       = 0;
LET dSdoInt          = 0;
LET dSdoInt_inh      = 0;

LET dSdodiaantint       = 0;
LET dSdomesantint       = 0;
LET dSdomoratorio       = 0;
LET dSdocontabmora      = 0;
LET dMontofinanciado    = 0;
LET dIvaIntVencido      = 0;
LET dIvaIntVigente      = 0;
LET dSdotrab4           = 0;
LET dSdo                = 0;
LET dtFechaCuota        = DATE(1);
LET dtFechaCuotaAnt     = DATE(1);
LET dProvInt       	    = 0;
LET dProvInt_inh  	    = 0;
LET dIvaPag        	    = 0;
LET dtIvaFechaPag       = DATE(1);
LET dCapMtoCuota        = 0;
LET dCapMtoCuota_ori	= 0;
LET iNumPago            = 0;
LET dProvIva       	    = 0;
LET dProvIva_inh  	    = 0;
LET dIntVdo             = 0;
LET dTraspCap           = 0;
LET dTraspInt           = 0;
LET cCapStatusCuota     = "";
LET dSdoMora            = 0;
LET dIntMora            = 0;
LET dIntCope            = 0;
LET iContCierre         = 0;
LET iContCorte          = 0;
LET iContCommit         = 0;
LET cIdProc1            = "";
LET cIdProc2            = "";
LET cIdProc3            = "";
LET cIdProc4            = "";

LET dIntProvFinMes      = 0;
LET dIvaProvFinMes      = 0;
LET dtFechaMesiversario = DATE(1);
LET cBanTemp            = 'N';
LET iNumVdos            = 0;
LET iPerTrasp           = 0;
LET dIntGrav            = 0;
LET dIntExen            = 0;
LET dIntGrav_inh        = 0;
LET dIntExen_inh        = 0;

LET ccodret             ='000';
LET CodigoRefProvIva    = 0;
LET CodigoRefProvInt    = 0;
LET dIntPeriodo         = 0;
LET dIvaPeriodo         = 0;
LET cSQL				= "";
LET vlCapitalDebe       = 0;
-- FMV 09-MAY-11 INICIO DE LA VARIABLE PARA EL CALCULO DE INTERES EN VENCIMIENTO, STATUS 1 DE AMORTIZA
LET dCapTrasVen_Amort = 0;
--FMV 03-SEP-11 --6400
LET iTpDiasFechaPago = 0;
--SDFM 11-06-12 -- VENTA PP
LET v_marca_ayuda = "";
LET vf_fecha_ult_pago = DATE(1);
LET vdias_atraso = 0;
LET vf_fecha_vencim   = DATE(1);
LET vi_dias_trasp_cap = 0;
LET vlIntVenBal      = 0;
LET vlIvaIntVenBal   = 0;
LET Campotrabajo3 = '';
-- JOM 11/04/2013 Se cambia traspado a periodos INI
LET dFechacuotamin = DATE(1);
LET iNumVdosaux    = 0;
-- JOM 11/04/2013 Se cambia traspado a periodos FIN
LET wbandera_apoyo = '';
LET cNumCteApoyo = '';
LET cDifApoy = 0;
LET cDifApoyoBaja = 0;	
LET dInteresApoyo = 0;
LET dIvaApoyo     = 0;
LET dIvaApoyoPag1 = 0;
LET dCapitalApoyo = 0;
LET dCountAmort	  = 0;
LET sNumPagApoyo  = 0;
LET dCapMntoCutApoy	= 0;
LET StatusCred_apoyo = '';
--LET totalApoyo		= 0;
LET psaldoInteresApoyo = 0;
LET psaldoIvaApoyo	= 0;
LET dFactor 		= 0;
LET dPagoInt 		= 0;
LET dPagoIvaInt 	= 0;
LET dCapMtoCuotaApoyo = 0;
LET pInteresactualPagado = 0;
LET pIvaActualPagado	= 0;
LET ivaPagadoAnterior 	= 0;
LET psaldoInteresTrasApoyo	= 0;

LET iFechaVencto = DATE(1);

-- RQM 09 473 TRIAD
LET vSdoTotLiquidar 		= 0.0;
LET vPagoMinimo				= 0.0;
LET vSdoTotVencido 			= 0.0;
LET dprovint_inh_aux 		= 0;
LET vMensaje				= '';
LET dIvaIntReal_inh_aux		= 0;

--nuevas variables para IFSR, calculo de etapas
LET iAtr 			= 0;
LET iAtrNvo			= 0;
LET iDiasAtraso		= 0;
LET dFechaVencimiento = DATE(1);
LET cCapitalStatus 	= '';
LET cCapitalStatusAnt = '';
LET vFechaVenc = NULL;
LET dFechaVencPlazo = DATE(1);
LET dIntPeriodoTras         = 0;
LET dIntPeriodoTrasOrd   = 0;
LET dIvaIntPeriodoTrasOrd = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 10;



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cNumCredito ||cErrorInfo;

      IF cBegin = "S" THEN
          ROLLBACK WORK;
       END IF;

      UPDATE "informix".sd_contproc
         SET status_proc = "C",
             hora_fin    = CURRENT,
             cod_ret     = cCodRet,
             mensaje     = cMensajeRet
       WHERE empresa     = cEmpresa
         AND proceso     = "CierrePrest"
         AND fecha       = dtFechaHoy;

      UPDATE bdinteg:sx_contproc
         SET status_proc = "C",
             hora_fin    = CURRENT,
             codret      = cCodRet
       WHERE empresa     = cEmpresa
         AND proceso     = "CierrePrest"
         AND fecha       = dtFechaHoy;

	  IF cBanTemp ='S' THEN
	     DROP TABLE tmp_sucursales_pp;
	  END IF;

   RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/ifxsif01/aacano/liberacion/juan/sp_cierre_diario_pp.out';
--TRACE ON;
-- *******************************************************
--  VALIDACIONES DE EJECUCION DE PROCESO                 *
-- *******************************************************
SELECT a.empresa
  INTO cEmpresa
  FROM bdinteg:si_empresas a
 WHERE a.empresa = pEmpresa;

IF NVL(cEmpresa,"") = "" THEN
     LET cCodRet     = "000001";
     LET cMensajeRet = "La empresa no existe";
     RETURN cCodRet, cMensajeRet;
END IF;

SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes,
       USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(CURRENT,3,2)
           ||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)
           ||SUBSTR(CURRENT,18,2)
  INTO dtFechaHoy, dtFechaProx, dtFechaFinMes,
       cFolio
  FROM "informix".sd_fechas a
 WHERE a.empresa = cEmpresa;

-- *******************************************************
--  INSERTA PARA EJECUCION DE PROCESO                 *
-- *******************************************************
--INI CAS
    SELECT status_proc
    INTO intecontproc
    FROM bdinteg:sx_contproc
    WHERE fecha= dtFechaHoy
      and proceso ='CierrePrest';

    if (intecontproc='F') then
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCodRet,cMensajeRet;
     end if;

    SELECT status_proc
    INTO credcontproc
    FROM bdicred:sd_contproc
    WHERE fecha= dtFechaHoy
      and proceso ='CierrePrest';

    IF (intecontproc IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret)
      VALUES ('001','CierrePrest',dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    end if;

    if (credcontproc IS NULL) THEN
      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001','CierrePrest',dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    end if;

    UPDATE bdinteg:sx_contproc
       SET status_proc='I'
     WHERE fecha= dtFechaHoy
       and proceso ='CierrePrest';

     UPDATE bdicred:sd_contproc
        SET status_proc='I' ,mensaje = 'Iniciamos'
      WHERE fecha= dtFechaHoy
        and proceso ='CierrePrest';

--FIN CAS

SELECT a.cod_tipcred
  INTO cCodTipCred
  FROM "informix".sd_tipcred a
 WHERE a.cod_tipcred  = pCodTipCred
   AND a.empresa      = cEmpresa;

IF NVL(cCodTipCred,"") = "" THEN
     LET cCodRet     = "000002";
     LET cMensajeRet = "El tipo de credito indicado no existe";
     RETURN cCodRet, cMensajeRet;
END IF;

SELECT a.valor
  INTO iDiasCalc
  FROM "informix".sd_param a
 WHERE a.cod_param = "24";

IF iDiasCalc IS NULL THEN
    LET cCodRet     = "000003";
    LET cMensajeRet = "Parametro para los dias de calculo de interes no encontrado";
    RETURN cCodRet, cMensajeRet;
END IF;

-- Dias de interes.
LET iDiasInt = dtFechaProx - dtFechaHoy;

IF NVL(iDiasInt,0) <= 0 THEN
    LET cCodRet     = "000004";
    LET cMensajeRet = "Fechas incorrectas";
    RETURN cCodRet, cMensajeRet;
END IF;

SELECT a.empresa, a.sucursal, a.iva, a.plaza
  FROM bdinteg:si_sucursales a
 WHERE a.tpo_sucursal = "S"
  INTO TEMP tmp_sucursales_pp;
CREATE INDEX indx_sucursal_pp ON tmp_sucursales_pp (empresa, sucursal);

LET cBanTemp = 'S';

--CALL "informix".monthadd(dtFechaFinMes,-1) RETURNING dtFechaFinMesAnt;
--LET dtFechaFinMesAnt=DATE(MDY(MONTH(dtFechaFinMes),'01',YEAR(dtFechaFinMes))-1);
CALL "informix".sp_valfechabil(dtFechaHoy+1,'+') RETURNING cCodRet, dtFechaHoyAux;

-- *******************************************************
--  SELECCION DE CREDITOS PARA PROCESAR                  *
-- *******************************************************
FOREACH WITH HOLD
        SELECT a.num_credito         , a.status_cred       , a.num_producto     , a.sucursal         , a.divisa           ,
               a.fecha_apertura      , a.tasa_interes      , a.tasa_moratorios  , b.sdo_capital      , b.monto_vencido    ,
               b.mto_venc_trasp      , b.cap_tras_no_venci , b.sdo_cap_insoluto , b.sdo_no_exig      , b.sdo_intereses    ,
               c.dia_corte           , b.int_tra_no_exig   , c.fecha_vencto     , c.prox_fecha_pago  , b.provision_normal ,
               b.sdo_global_int      , d.period_pago_cap   , b.sdo_dia_ant_int  , b.sdo_mes_ant_int  , b.sdo_moratorio    ,
               b.sdo_contab_mora     , b.monto_financiado  , b.mto_venc_int     , b.mto_finan_vdo    , b.sdo_trab4        ,
	           nvl(c.tp_dias_fecha_pago,0) , a.id_origen   , c.fecha_ult_pago   , a.fecha_vencim     , a.dias_trasp_cap   ,
               a.campo_trab3		 , a.numcte			   , NVL(b.atr,-1)				 , a.fecha_vencim --, f.capital_status	-- IFSR se agregan retornos para iAtr y iDiasAtraso

          INTO cNumCredito          , cStatusCred         , cNumProducto       , cSucursal           , cDivisa            ,
               dtFechaApert         , dTasaInter          , dTasaInterMor      , dSdoCapital         , dMntVencido        ,
               dMntVencTras         , dCapTrasNoVen       , dSdoCapInso        , dSdoNoExig          , dSdoInt            ,
               iDiaCorte            , dIntVdo             , dtFechaVencto      , dtFechaMesiversario , dIntProvFinMes     ,
               dIvaProvFinMes       , iPerTrasp           , dSdodiaantint      , dSdomesantint       , dSdomoratorio      ,
               dSdocontabmora       , dMontofinanciado    , dIvaIntVencido     , dIvaIntVigente      , dSdotrab4          ,
               iTpDiasFechaPago     , v_marca_ayuda       , vf_fecha_ult_pago  , vf_fecha_vencim     , vi_dias_trasp_cap  ,
               Campotrabajo3		, cNumCteApoyo		  , iAtr			   ,  dFechaVencPlazo	 --, cCapitalStatusAnt -- IFSR se agregan las asignaciones a iAtr y dFechaVencimiento
          FROM sd_maecredcrd a, sd_maesdoscrd b, sd_maecredanexocrd c, sd_definicion d--, sd_indicador_cred_crd e--, sd_maecredcontcrd f--, sd_amortiza_creditocrd f --IFSR se agrega sd_indicador_cred_crd para tomar los dias de atraso
         WHERE a.num_credito   = b.num_credito
           AND a.empresa       = b.empresa
           AND c.num_credito   = a.num_credito
           AND c.empresa       = a.empresa
           AND d.num_producto  = a.num_producto
           AND d.empresa       = c.empresa
           AND a.empresa       = cEmpresa
           AND a.status_cred   NOT IN ("FF","FM","CC","FC","CV","FI")
           AND c.fecha_proceso = dtFechaHoy
           AND d.cod_tipcred   = cCodTipCred


 --          IF cBegin = "N" AND iContCommit=0 THEN
               BEGIN WORK;
               LET cBegin = "S";
--           END IF;

            LET cStatusCredAnt     = cStatusCred;
            LET cStatusCredIndica  = cStatusCred;
            LET cIdProc1          = "";	 LET cIdProc2          = "";
            LET cIdProc3          = "";	 LET cIdProc4          = "";
            LET dIvaIntReal       = 0;	 LET dIvaIntReal_inh   = 0;
            LET dProvIva          = 0;	 LET dProvInt          = 0;
            LET dProvIva_inh      = 0;	 LET dProvInt_inh      = 0;
            LET dCapMtoCuota      = 0;	 LET dSdoInt_inh       = 0;
            LET dIntGrav_inh      = 0;	 LET dIntExen_inh      = 0;
            LET iDiasInt_inh      = 0;	 LET dIntDiario_inh    = 0;
			LET iContCommit		  = 0;
			LET StatusCred_apoyo  = '';
			LET vMensaje		  		= '';
			LET dprovint_inh_aux 		= 0;
			LET dIvaIntReal_inh_aux		= 0;
			LET psaldoInteresApoyo		= 0;
			LET psaldoIvaApoyo			= 0;
			LET dPagoInt				= 0;
			LET	dPagoIvaInt				= 0;
			LET pInteresactualPagado 	= 0;
			LET pIvaActualPagado		= 0;
			LET ivaPagadoAnterior 	= 0;
			LET dFactor				= 0;
			LET dCapMtoCuotaApoyo	= 0;
			LET apoyo_iva_debe		= 0;
			
			--IFSR sacar los dias
			LET iDiasAtraso =  abs(dtFechaHoy) - abs(date(dtFechaVencto));
			
			IF ( NVL(iDiasAtraso,0) <= 0) THEN 
			   LET iDiasAtraso = 0; 
			END IF;
			
			LET vFechaVenc = dtFechaVencto;
			LET iAtrNvo = iAtr;
			/*IF (iDiaCorte = 1) then
				LET dIvaProvFinMes = 0; -- IFSR validar si se deja
			end if;*/
			
			--select * from sd_indicador_cred_crd
			
			-- IFSR identifica de donde va a tomar el atr cuando el vencimiento ya se haya cumplido
			IF (dFechaVencPlazo < dtFechaHoy) THEN
				SELECT nvl(atr,0) 
				INTO iAtr
				FROM sd_maesdoscrd 
				where num_credito   = cNumCredito;
				/*SELECT nvl(atr,0) 
				INTO iAtr
				FROM sd_atrPP 
				where num_credito   = cNumCredito;*/
				
				LET iAtrNvo = iAtr;
				
			END IF;

	--		IF  cNumProducto in ('6300','7600','7700','6800') THEN
				------Programa Apoyo
				SELECT bandera INTO wbandera_apoyo
				  FROM sd_programa_apoyo2021crd
				 WHERE num_credito = cNumCredito;

				IF ( wbandera_apoyo is null ) THEN LET wbandera_apoyo = ''; END IF;
				/*		--- se apaga inscripcion al programa de apoyo 01/08/2020 ITD
				IF wbandera_apoyo = '' THEN
					-- Consulta si el credito tenia status vigente a fin de febrero
					SELECT status_cred INTO StatusCred_apoyo FROM bdicred:sd_maecredcontcrd 
					 WHERE num_credito = cNumCredito AND fecha = mdy('03','31','2020');
					 
					 IF StatusCred_apoyo IS NULL THEN
						LET StatusCred_apoyo = '';	
					 END IF;
				
					IF cNumProducto = '6800' AND StatusCred_apoyo = '' THEN
						SELECT count(*) INTO iContCommit
					      FROM bdicred:sd_maecredcrd a, bdicred:sd_linea_prestamo b
						 WHERE a.num_credito = b.num_credito
						   AND a.num_credito = cNumCredito
					  	   AND b.fecha_otorga <= mdy('03','31','2020')
						   AND fecha_cancela IS NULL;
			   
					END IF;

					IF iContCommit > 0 OR StatusCred_apoyo = 'AA' THEN		-- Si termino feb con AA
						-- Consulta tabla origen de programa apoyo: Registro de diferimiento por parte del cliente
						SELECT canal,canal_baja INTO cDifApoy ,cDifApoyoBaja FROM bdicred:sd_diferir
						 WHERE numcte = cNumCteApoyo;
						 
						 IF cDifApoy IS NULL THEN
							LET cDifApoy = 0;
						 END IF;

						-- Solo inserte cuando sea mesiversario. Para casos q estan registrado en sd_diferir y no en sd_programa_apoyo2020crd. Solo entra si se encuentra en vigente: AA
						IF (cDifApoy > 0 AND cDifApoyoBaja IS NULL) OR 
							(cDifApoyoBaja IS NULL AND dMontofinanciado > 0 ) AND (dtFechaHoy = dtFechaMesiversario) AND cStatusCred = 'AA' THEN   
						
							INSERT INTO bdicred:"informix".sd_programa_apoyo2020crd VALUES (cNumCredito,dtFechaHoy,"A",date(1));
							UPDATE bdicred:"informix".sd_maecredcrd SET campo_trab3 = "BAJA" WHERE num_credito = cNumCredito;
							LET wbandera_apoyo = 'A';
							LET Campotrabajo3 = 'BAJA';
							
						END IF;
					END IF;
				END IF; */
	--		END IF;
			  		
-- Venta de Cartera de PP
		IF (v_marca_ayuda = '1' OR cStatusCred = 'CV' OR ( Campotrabajo3 = 'BAJA' AND cStatusCred <> 'CV' ) OR wbandera_apoyo ='A') THEN
		
			  -- Identificar  (Cierre de Mes).
			 IF dtFechaHoy = dtFechaFinMes THEN
			    LET cIdProc1 = "C";
			 END IF;
			 -- Validaciones para dias inhabiles y cambios de mes. (Facturacion)
			 IF dtFechaHoyAux = dtFechaMesiversario THEN
				LET cIdProc2 = "F";
			 END IF;
			 -- Identificar un (Mesiversario)
			 IF dtFechaHoy = dtFechaMesiversario THEN
				 LET cIdProc3 = "M";
			 END IF;
             --FMV 7mar13: Valida registros de la Provision a fin de mes, para PP Factu dia 1o. de mes
             IF cIdProc1 = "C" AND cIdProc2 = "F" THEN
                 LET cIdProc4 = "P";  --> Registro para validar (P)rovision
                 LET iDiasInt_inh = iDiasInt - 1;
             END IF;


            IF ( v_marca_ayuda = '1' OR ( Campotrabajo3 = 'BAJA' AND cStatusCred <> 'CV' ) OR wbandera_apoyo ='A') THEN
			
				IF (  cIdProc2 = "F" or cIdProc3 = "M") AND (wbandera_apoyo ='A' or Campotrabajo3 = 'BAJA') THEN			
					---- respaldo antes de alguna modificacion
					 INSERT INTO "informix".sd_maecredcrd_apoyo2021
					 SELECT dtFechaHoy, * FROM informix.sd_maecredcrd
					  WHERE num_credito = cNumCredito AND empresa = cEmpresa;
				   
					 INSERT INTO "informix".sd_maesdoscrd_apoyo2021
					 SELECT dtFechaHoy, * FROM informix.sd_maesdoscrd
					 WHERE num_credito = cNumCredito AND empresa = cEmpresa;
				  
					 INSERT INTO bdicred:"informix".sd_amortiza_creditocrd_apoyo2021
					 SELECT dtFechaHoy, * FROM bdicred:"informix".sd_amortiza_creditocrd
					  WHERE num_credito = cNumCredito AND empresa = pEmpresa;					  
					  
					 INSERT INTO "informix".sd_maecredanexocrd_apoyo2021
					 SELECT dtFechaHoy, * FROM informix.sd_maecredanexocrd
					  WHERE num_credito = cNumCredito AND empresa = cEmpresa;
					  
					  -- respaldo para la sd_linea_prestamo
					 INSERT INTO "informix".sd_linea_prestamo_apoyo2021
					 SELECT dtFechaHoy, * FROM informix.sd_linea_prestamo
					  WHERE num_credito = cNumCredito AND empresa = cEmpresa;
				END IF;
			
               SELECT COUNT(*)
                 INTO iNumVdos
                 FROM "informix".sd_amortiza_creditocrd a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status IN ("2","7","6");

                  IF (iNumVdos = 0) THEN
                      UPDATE "informix".sd_maecredanexocrd
                         SET fecha_vencto  = NULL
                       WHERE num_credito    = cNumCredito
                         AND empresa        = cEmpresa;
				  END IF;

               UPDATE sd_maesdoscrd
                  SET mto_fin_ven_trasp = iNumVdos
                WHERE empresa = cEmpresa
                  AND num_credito = cNumCredito;


               UPDATE "informix".sd_maecredanexocrd
                  SET fecha_proceso  = dtFechaProx
                WHERE num_credito    = cNumCredito
                  AND empresa        = cEmpresa;


               IF cIdProc1 = "C" or day(dtFechaHoy)=20 THEN
                  INSERT INTO "informix".sd_maesdoscontcrd
                       SELECT dtFechaHoy, *
                         FROM informix.sd_maesdoscrd
                        WHERE num_credito = cNumCredito
                          AND empresa     = cEmpresa;

                  INSERT INTO "informix".sd_maecredcontcrd
                       SELECT dtFechaHoy, empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,
								cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,
								tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,
								valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,
								credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4--,etapa,status_cred_ant
                         FROM informix.sd_maecredcrd
                        WHERE num_credito = cNumCredito
                          AND empresa     = cEmpresa;
               END IF;
               IF ( cIdProc3 = "M" ) THEN
                      call "informix".calculamesiversario(iDiaCorte::INTEGER, dtFechaMesiversario, 1, iTpDiasFechaPago)
                          RETURNING cCodRet, dtFechaProxCuota;

                      UPDATE "informix".sd_maecredanexocrd
                         SET prox_fecha_pago = dtFechaProxCuota
                       WHERE num_credito     = cNumCredito
                         AND empresa         = cEmpresa;
                  END IF;

                  IF ( cIdProc3 = "M" OR cIdProc2 = "F" ) THEN
                     INSERT INTO "informix".sd_maesdoshistcrd
                           SELECT dtFechaHoy, *
                             FROM informix.sd_maesdoscrd
                            WHERE num_credito = cNumCredito
                              AND empresa     = cEmpresa;
                  END IF;
			   IF (  cIdProc2 = "F" or cIdProc3 = "M") AND (wbandera_apoyo ='A' or Campotrabajo3 = 'BAJA') THEN
		
					if  cIdProc3 = "M" then
						update bdicred:"informix".sd_amortiza_creditocrd
							set fecha_cuota = monthadd(fecha_cuota,1)
						where capital_status in (3,7,1)
							AND num_credito = cNumCredito
							AND empresa = pEmpresa;
					end if;
			   END IF;
			END IF;
			   --calculo de los int diarios para programa apoyo sea sobre deuda total. No existe amortiza con status 1 (se pasa a 3)
               --LET dIntDiario = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt;
		--	   LET dIntDiario = (((dSdoCapital + dCapTrasNoVen) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt;
		--	   
		--	   LET dSdodiaantint = dSdoInt;
		--	   LET dSdoInt  = dSdoInt + dIntDiario;
						  
			   --------------------------
			   -- Calcula PROVISION
/*
				----- provision de 1 dia cuando es fin de mes
				IF cIdProc1 = "C"  and (dSdoCapital + dCapTrasNoVen) > 0 THEN
				
					SELECT a.iva, a.plaza
						INTO dIvaSuc, cPlaza
					FROM tmp_sucursales_pp a
						WHERE empresa  = cEmpresa
						AND sucursal = cSucursal;
				
					SELECT a.fecha_cuota, --  a.iva_pagado,
							a.iva_fecha_pago,
							NVL(a.capital_mto_cuota,0),NVL(num_pago,1)
						INTO dtFechaCuota,-- dIvaPag,
							dtIvaFechaPag,
							dCapMtoCuota,iNumPago
					FROM "informix".sd_amortiza_creditocrd a
					WHERE a.empresa        = cEmpresa
						AND a.num_credito    = cNumCredito
						AND a.capital_status = "3";

					LET dProvInt = dSdoInt;

					CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
													dtIvaFechaPag,dtFechaApert,dtFechaCuota,dSdoInt)
						RETURNING cCodRet,dIvaIntReal,cMensajeRet;

					IF cCodRet <> "000000" THEN
						LET cCodRet      = "000005";
						LET cMensajeRet  = "Ocurrio un error al realizar calculo de iva de interes";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
						RETURN cCodRet,cMensajeRet;
					END IF;

					IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
					IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

					LET dProvIva = dIvaIntReal; -- dIvaProvFinMes;
					LET CodigoRefProvIva    = 7;
					LET CodigoRefProvInt    = 6;


					IF dProvInt > 0 THEN  
						IF cIdProc4 = '' THEN
							LET dProvInt = dProvInt - dIntProvFinMes;
						ELSE
							LET dProvInt = dProvInt  - dProvInt_inh;	
						END IF;
					END IF;
					
					IF dProvInt > 0 THEN    

						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt,
						"606", dtFechaHoy ,dProvInt, cFolio,
						cSucursal, cDivisa, "0000",'PROV','')
						RETURNING cCodRet,cMensajeRet;

						IF (cCodRet <> "000000") THEN
							LET cCodRet      = cCodRet;
							LET cMensajeRet = "Ocurrio un error al registrar la provision de interes";
							IF cBegin = "S" THEN
								ROLLBACK WORK;
							END IF;
							RETURN cCodRet,cMensajeRet;
						END IF;

						IF cIdProc4 = '' THEN
							LET dProvIva = dProvIva - dIvaProvFinMes;
						ELSE
							LET dProvIva = dProvIva - dProvIva_inh;
						END IF;

						IF dProvIva > 0 THEN
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva,
										"606", dtFechaHoy , dProvIva, cFolio,cSucursal, cDivisa, "0000",'PROV','')
								RETURNING cCodRet,cMensajeRet;
							IF (cCodRet <> "000000") THEN
								LET cCodRet      = "000007";
								LET cMensajeRet = "Ocurrio un error al registrar la provision de iva de interes";
								IF cBegin = "S" THEN
									ROLLBACK WORK;
								END IF;
								RETURN cCodRet,cMensajeRet;
							END IF;
						END IF;

					END IF;
					
					IF cNumProducto <> '6900' THEN
						IF dProvInt>0 and dProvIva<=0 then
							LET dIntGrav = dProvInt;
							LET dIntExen = 0;
						ELSE
							LET dIntGrav = dProvIva/dIvaSuc;
							IF dIntGrav>dProvInt THEN LET dIntGrav=dProvInt; END IF;
							LET dIntExen = dProvInt-dIntGrav;
						END IF;

						IF dIntGrav>0 THEN
								CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 12,
												  "606",  dtFechaHoy  , dIntGrav, cFolio,
												  cSucursal, cDivisa, "0000",'GRAV','')
								RETURNING cCodRet,cMensajeRet;
								IF (cCodRet <> "000000") THEN
									   LET cCodRet      = "000007";
									   LET cMensajeRet = "Ocurrio un error al registrar el Interes Gravado";
									   IF cBegin = "S" THEN
										  ROLLBACK WORK;
									   END IF;
									   RETURN cCodRet,cMensajeRet;
								END IF;
						END IF;
						IF dIntExen>0 THEN
								CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 13,
												  "606", dtFechaHoy, dIntExen, cFolio,
												  cSucursal, cDivisa, "0000",'EXEN','')
								RETURNING cCodRet,cMensajeRet;
								IF (cCodRet <> "000000") THEN
									   LET cCodRet      = "000007";
									   LET cMensajeRet = "Ocurrio un error al registrar el Interes Exento";
									   IF cBegin = "S" THEN
										  ROLLBACK WORK;
									   END IF;
									   RETURN cCodRet,cMensajeRet;
								END IF;
						END IF;
					END IF;
	
				END IF;
				
			   -- Fin Calcula provision					   
			   --------------------------
		
		
				 if  cIdProc3 = "M" then
					select nvl((interes_debe - interes_pagado),0), nvl((iva_debe - iva_pagado),0), nvl(iva_pagado,0), NVL((capital_debe - capital_pagado),0), nvl(num_pago,0)
					  into dInteresApoyo					     , dIvaApoyo					 , dIvaApoyoPag1    , dCapitalApoyo							, sNumPagApoyo
		              from bdicred:sd_amortiza_creditocrd 
		             where empresa = cEmpresa 
			           and num_credito = cNumCredito 
			           and capital_status = '1';	

						IF dInteresApoyo IS NULL THEN
							LET dInteresApoyo = 0;
							LET dIvaApoyo = 0;
							LET dIvaApoyoPag1 = 0;
							LET dCapitalApoyo = 0;
							LET sNumPagApoyo = 0;
							LET dCapMntoCutApoy = 0;
						END IF;
				 
				    update bdicred:"informix".sd_amortiza_creditocrd
				       set capital_status = '5'
				     where capital_status = '1'
				       and num_credito = cNumCredito
                       and empresa = pEmpresa;
				 
				    update bdicred:"informix".sd_amortiza_creditocrd
					   set interes_debe = interes_debe + dInteresApoyo, 
						   iva_debe = iva_debe + dIvaApoyoPag1, iva_pagado = iva_pagado + dIvaApoyoPag1, iva_fecha_pago = dtFechaHoy 	
						   -- fecha de ultimo pago de iva para provision
					 where capital_status in ('3')
				       and num_credito = cNumCredito
                       and empresa = pEmpresa;
					LET dCountAmort = dbinfo("sqlca.sqlerrd2");
					IF dCountAmort = 0 AND dCapitalApoyo > 0 THEN 			-- Es decir, no existe un registro 3 por ser ultima, generale nueva por apoyo

						select nvl(capital_mto_cuota,0)
						  into dCapMntoCutApoy
						  from bdicred:sd_amortiza_creditocrd 
						 where empresa = cEmpresa 
						   and num_credito = cNumCredito 
						   and num_pago = 1;
					
						INSERT INTO "informix".sd_amortiza_creditocrd
								(
									empresa, 		    num_credito, 		fecha_cuota, 		tipo_cuota,
									capital_mto_cuota, 	capital_debe,		capital_pagado, 	capital_status,
									capital_status_ant, capital_fecha_pago,	interes_debe, 		interes_pagado,
									interes_status, 	interes_status_ant,	interes_fecha_pago, iva_debe,
									iva_pagado, 		iva_status,			iva_status_ant, 	iva_fecha_pago,
									mora_provi_ordi, 	mora_provi_cope,	mora_sdo_ordi, 		mora_sdo_ordi_pag,
									mora_sdo_cope, 		mora_sdo_cope_pag,	mora_bonificado, 	mora_status,
									mora_iva_debe, 		mora_iva_pagado,	mora_iva_status, 	mora_iva_fecha_pago,
									num_pago, 		    campo_trabajo1,		campo_trabajo2, 	campo_trabajo3,
									campo_trabajo4
								)
							VALUES
								(   cEmpresa,		    cNumCredito,	dtFechaProxCuota,	"3",
									dCapMntoCutApoy,       0,				0,			        "3",
									"3",         		"",				dInteresApoyo,       0,
									"1",                "1",			NULL,			     dIvaApoyoPag1,
									0,			        "1",			"1",                 "",
									0,			         0,				0,			         0,
									0,			         0,				0,			         "1",
									0,			          0,			"1",			     "",
							(sNumPagApoyo +1),		      0,			0,			         "",
									""
								);
					END IF;
				  
					   
					UPDATE bdicred:"informix".sd_maesdoscrd
				       SET sdo_intereses = sdo_intereses  + dInteresApoyo, provision_normal = provision_normal + dInteresApoyo, 
					       sdo_global_int = sdo_global_int + dIvaApoyo
			         WHERE empresa = cEmpresa
				       AND num_credito = cNumCredito;
  
				 end if;
				 END IF;
*/				 
			   IF cIdProc1 ='C' THEN
/*			   
			    SELECT min(fecha_cuota) INTO  iFechaVencto
				   FROM "informix".sd_amortiza_creditocrd a
				  WHERE a.empresa        = cEmpresa
					AND a.num_credito    = cNumCredito
					AND a.capital_status IN ("2","7","6"); --IFSR se agrega ajuste para que se contemple la informacion del nuevo capital status 6 
				 IF iFechaVencto IS NULL THEN  LET vdias_atraso= 0; 
				 ELIF cStatusCred ='AA' THEN LET vdias_atraso= 0; 
				 ELSE
			       LET vdias_atraso = (dtFechaFinMes - nvl(iFechaVencto,dtFechaFinMes) + 1);                   
			     END IF;
*/				 
				 UPDATE "informix".sd_indicador_cred_crd
                      SET dias_atraso   = NVL(iDiasAtraso,0)  
                   WHERE empresa = pEmpresa
                     AND num_credito = cNumCredito;
			   END IF;
			   /*
			   --------------------------
			   -- Calcula Intereses para PROGRAMA APOYO 2020
			   SELECT sum(capital_debe - capital_pagado) INTO dCapTrasVen_Amort
				 FROM sd_amortiza_creditocrd
				WHERE empresa = cEmpresa
				  AND num_credito = cNumCredito
				  AND capital_status = '1';
			   IF dCapTrasVen_Amort IS NULL THEN	LET dCapTrasVen_Amort = 0; 	END IF;
			   
			   --Actualizacion de los int diarios en sd_amortiza_creditocrd
               UPDATE "informix".sd_amortiza_creditocrd
                  SET interes_debe = interes_debe + dIntDiario
                WHERE empresa        = cEmpresa		
                  AND num_credito    = cNumCredito
                  AND capital_status = "3";
					 
			   --LET dMontofinanciado = dMontofinanciado + dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal;					 
               UPDATE sd_maesdoscrd
				  SET fecha_ult_mov = dtFechaHoy,
					sdo_intereses = sdo_intereses + dSdoInt,
					sdo_dia_ant_int = dSdodiaantint,
					sdo_mes_ant_int = dSdomesantint,
					sdo_acum_mes_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE dSdoInt END),
--					sdo_no_exig = dSdoNoExig,
					sdo_no_exig = 0,
					mto_finan_vdo = 0,
					provision_normal = (CASE WHEN cIdProc1 = "C" THEN (provision_normal + dSdoInt) ELSE provision_normal END),
					dias_acum_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE (dias_acum_int + iDiasInt) END),
					sdo_dia_ant_cap = sdo_cap_insoluto,
					sdo_capital = dSdoCapital,
					sdo_cap_insoluto = dSdoCapInso,
					dias_acum_cap = (dias_acum_cap + iDiasInt),
					monto_vencido = dMntVencido,
					mto_venc_trasp = dMntVencTras,
					-- monto_financiado = dMontofinanciado,
					monto_financiado = 0,					
					sdo_global_int = (CASE WHEN cIdProc1 = "C" THEN (sdo_global_int + dProvIva) ELSE sdo_global_int END),
					cap_tras_no_venci = dCapTrasNoVen,
					mto_venc_int = dIvaIntVencido,
					int_tra_no_exig = dIntVdo,
					sdo_trab4 = dSdotrab4,
					mto_fin_ven_trasp = iNumVdos
				WHERE empresa = cEmpresa
				  AND num_credito = cNumCredito;

			END IF;
			
			
			  select sum(interes_debe - interes_pagado) vencido_balanza,
					   sum(iva_debe - iva_pagado) iva_vencido_balanza
				  into vlIntVenBal, vlIvaIntVenBal
				  from bdicred:sd_amortiza_creditocrd 
				 where empresa = cEmpresa 
				   and num_credito = cNumCredito 
				   and capital_status = '2'
				   and campo_trabajo3 <> 'V';
			
				if  vlIntVenBal is null then
				   let vlIntVenBal = 0;
				   let vlIvaIntVenBal = 0;
				end if;

				LET dSdoNoExig = 0;
				LET dMontofinanciado = 0;
				
				SELECT provision_normal,sdo_global_int
					INTO dSdoInt,dProvIva
				FROM bdicred:sd_maesdoscrd 
				WHERE num_credito = cNumCredito;

				 CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
									--	(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
									--		  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
									--		  ELSE (dSdoNoExig + dIntProvFinMes)  END)
											  dSdoInt, dIntVdo,
									--	(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
									--		  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
									--		  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
											  dProvIva,
										dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy)
				RETURNING cCodRet;
				*/
						   
			   If  cStatusCred in ('E1','E2') THEN 
					  select sum(interes_debe - interes_pagado) vencido_balanza,
							 sum(iva_debe - iva_pagado) iva_vencido_balanza
						into vlIntVenBal, vlIvaIntVenBal
						from bdicred:sd_amortiza_creditocrd 
						where empresa = cEmpresa
						  and num_credito = cNumCredito 
							  and campo_trabajo3 <> 'V'
						  --and capital_status = '2';
						  and capital_status in ('1','7','2','6'); -- IFSR se valida para que los intereces de balanza vencido sean en capital status 6 (etapa 3)
				 ELIF  cStatusCred = 'E3' THEN
						select sum(interes_debe - interes_pagado) vencido_balanza,
							 sum(iva_debe - iva_pagado) iva_vencido_balanza
						into vlIntVenBal, vlIvaIntVenBal
						from bdicred:sd_amortiza_creditocrd 
						where empresa = cEmpresa
						  and num_credito = cNumCredito 
							  and campo_trabajo3 <> 'V'
						  --and capital_status = '2';
						  and capital_status in ('7','2','6'); -- IFSR se valida para que los intereces de balanza vencido sean en capital status 6 (etapa 3) 
				 ELSE
						 select sum(interes_debe - interes_pagado) vencido_balanza,
							 sum(iva_debe - iva_pagado) iva_vencido_balanza
						into vlIntVenBal, vlIvaIntVenBal
						from bdicred:sd_amortiza_creditocrd 
						where empresa = cEmpresa
						  and num_credito = cNumCredito 
							  and campo_trabajo3 <> 'V'
						  and capital_status = '2';
				 END IF;
			   
        
            if  vlIntVenBal is null then
               let vlIntVenBal = 0;
               let vlIvaIntVenBal = 0;
            end if;

			 /*CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
										  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
										  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
										  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
										  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
									dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy)
		  	RETURNING cCodRet;*/
			
			IF cStatusCred in ('E1','E2','E3') THEN 
			 
				 CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
											  (dSdoNoExig + dIntProvFinMes), -- interes vigente
											  dIntVdo, -- interes vencido 
											  (dIvaIntVigente + dIvaProvFinMes), -- iva interes vigente
										dIvaIntVencido, -- iva interes vencido
										(vlIntVenBal+dIntProvFinMes), -- interes vencido de balanza
										(vlIvaIntVenBal+dIvaProvFinMes), -- iva interes vencido de balanza
										dMontofinanciado,dtFechaHoy,cStatusCredIndica,iAtrNvo)
				RETURNING cCodRet;
			
			ELSE
			
					CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
											(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
												  WHEN cIdProc2 = "F" THEN (dSdoNoExig + dIntProvFinMes)
												  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
											(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
												  WHEN cIdProc2 = "F" THEN (dIvaIntVigente + dIvaProvFinMes)
												  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
											dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy,cStatusCredIndica,iAtrNvo)
				RETURNING cCodRet;
			
			END IF
			
				IF (cCodRet <> "000") THEN
					 LET cCodRet     = "000002";
					 LET cMensajeRet = "Error al grabar en tabla saldos diarios";
					 RETURN cCodRet, cMensajeRet;
				END IF;
			
				IF dtFechaHoy=mdy(12,31,2021) THEN

					EXECUTE PROCEDURE "informix".sp_ambientar_indicador_cred_crd(dtFechaHoy,cNumCredito)
						INTO cCodRet, vMensaje;

					IF  cCodRet <> "000" THEN
						RETURN cCodRet,cMensajeRet;				 
					END IF;

				END IF;
			
            COMMIT WORK;
            CONTINUE FOREACH;
		END IF;
-- Venta de cartera de PP
-- *******************************************************
--  CALCULO DE INTERESES DIARIOS                         *
-- *******************************************************
           --Se obtiene el saldo para calcular los int diarios.
  --FMV 09-may-11  Calcula el int sobre el sdo capital sin el monto de traspaso ya calculado en la facturacion
  
            SELECT sum(capital_debe - capital_pagado)
               INTO dCapTrasVen_Amort
              FROM sd_amortiza_creditocrd
             WHERE empresa = cEmpresa
               AND num_credito = cNumCredito
               AND capital_status = '1';

               IF dCapTrasVen_Amort IS NULL
                 THEN
                    LET dCapTrasVen_Amort = 0;
               END IF; 
			   /*
			   IF wbandera_apoyo = 'A' THEN		--Programa apoyo 2020
					LET dCapTrasVen_Amort = 0;
			   END IF; 
				*/
			   --calculo de los int diarios
			   LET dIntDiario = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt;

             IF dtFechaHoy = dtFechaFinMes AND dtFechaHoyAux = dtFechaMesiversario THEN
                 LET cIdProc4 = "P";  --> Registro para validar (P)rovision
                 LET iDiasInt_inh = iDiasInt - 1;
             END IF;

            IF cIdProc4 = "P"  THEN
               LET dIntDiario_inh = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt_inh;
               LET dSdoInt_inh  = dSdoInt_inh + dSdoInt + dIntDiario_inh;
            END IF;

                  --Actualizacion de los int diarios en maestro de saldos (sd_maesdoscrd)
                  LET dSdodiaantint = dSdoInt;
                  LET dSdoInt       = dSdoInt + dIntDiario;
                  --Actualizacion de los int diarios en sd_amortiza_creditocrd
                  UPDATE "informix".sd_amortiza_creditocrd
                     SET interes_debe = interes_debe + dIntDiario
                   WHERE empresa        = cEmpresa
                     AND num_credito    = cNumCredito
                     AND capital_status = "3";

                  --Se actualiza la fecha del proximo proceso
                  UPDATE "informix".sd_maecredanexocrd
                     SET fecha_proceso  = dtFechaProx
                   WHERE num_credito    = cNumCredito
                     AND empresa        = cEmpresa;


-- *******************************************************
--  IDENTIFICACION DE PROCESOS POR REALIZAR              *
-- *******************************************************
          -- Validacion para identificar un (Cierre de Mes).
          IF dtFechaHoy = dtFechaFinMes THEN
            LET cIdProc1 = "C";
          END IF;
          -- Validaciones para dias inhabiles y cambios de mes. (Facturacion)
          IF dtFechaHoyAux = dtFechaMesiversario THEN
                LET cIdProc2 = "F";
                if ( iTpDiasFechaPago = 2 ) then
                    if ( iDiaCorte <= 15) then
                        SELECT  sdodiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND perdiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'N';
                    else
                        SELECT  perdiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND sdodiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'S';
                    end if;
                 end if;
                call "informix".calculamesiversario(iDiaCorte::INTEGER, dtFechaMesiversario, 1, iTpDiasFechaPago)
                     RETURNING cCodRet, dtFechaProxCuota;
          END IF;

          -- Validaciones para identificar un (Mesiversario)
          IF dtFechaHoy = dtFechaMesiversario THEN
             LET cIdProc3 = "M";
                if ( iTpDiasFechaPago = 2 ) then
                    if ( iDiaCorte <= 15) then
                        SELECT  sdodiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND perdiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'N';
                    else
                        SELECT  perdiafac
                          INTO iDiaCorte
                          FROM "informix".sd_diafactura
                         WHERE empresa = cEmpresa
                           AND num_producto = cNumProducto
                           AND sdodiafac = iDiaCorte
                           AND tipo_pago = iTpDiasFechaPago
                           AND fac_especial = 'S';
                    end if;
                 end if;
                call "informix".calculamesiversario(iDiaCorte::INTEGER, dtFechaMesiversario, 1, iTpDiasFechaPago)
                     RETURNING cCodRet, dtFechaProxCuota;
          END IF;

-- *******************************************************
--  Calculo de Iva de Interes                            *
-- *******************************************************
 SELECT a.iva, a.plaza
   INTO dIvaSuc, cPlaza
   FROM tmp_sucursales_pp a
  WHERE empresa  = cEmpresa
    AND sucursal = cSucursal;
	
	IF (cStatusCred IN ('E1','E2','E3')) THEN
	--IFSR se obtiene el interes para el traspaso
		select nvl(sum(interes_debe - interes_pagado),0)
			  into dIntPeriodoTras
			  from "informix".sd_amortiza_creditocrd
			 where empresa             = cEmpresa
			   AND num_credito         = cNumCredito
			   and campo_trabajo3 = ''
			   AND capital_status      in ('1','7','2','6');

	--IFSR se obtiene el interes para el traspaso en orden
		select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
			  into dIntPeriodoTrasOrd, dIvaIntPeriodoTrasOrd
			  from "informix".sd_amortiza_creditocrd
			 where empresa             = cEmpresa
			   AND num_credito         = cNumCredito
			   and campo_trabajo3 = 'V'
			   AND capital_status      in ('1','7','2','6');
	END IF;
		   
--********************************************************************
-- PROVISION ESPECIAL PARA PRESTAMOS CON MESIVERSARIO DIA 1o. DE MES
--********************************************************************
IF cIdProc1 = "C" AND cIdProc4 = "P" and (dSdoCapital + dCapTrasNoVen) > 0 THEN

           SELECT a.fecha_cuota,
                --  a.iva_pagado,
                  a.iva_fecha_pago,
                  NVL(a.capital_mto_cuota,0),
                  NVL(num_pago,1)
             INTO dtFechaCuota,
                 -- dIvaPag,
                  dtIvaFechaPag,
                  dCapMtoCuota,
                  iNumPago
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status = "3";

               IF dtFechaCuota IS NOT NULL THEN
                   LET dtFechaCuotaAnt = dtFechaCuota;
               END IF;

-- LET dSdoInt = dSdoInt + dIntDiario;
 LET dProvInt_inh = dSdoInt_inh;
 
 
	IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
	IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;
 
--	LET dIntProvFinMes = dIntProvFinMes;
	LET dsdoint = dsdoint;
 
/* 	IF wbandera_apoyo = 'A' THEN
		LET dprovint_inh_aux = dProvInt_inh- dIntProvFinMes;
			---- se ejecuta con variable nueva dprovint_inh_aux  -- ITD
		  CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
										  dtIvaFechaPag,dtFechaApert,dtFechaCuota,dprovint_inh_aux)
		  RETURNING cCodRet,dIvaIntReal_inh_aux,cMensajeRet;
	--	 LET dProvInt_inh = dSdoInt_inh;
	END IF; */
	
			---- llamado original con dSdoInt_inh calcula el IVA sobre el Interes acomulado-- ITD
		  CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
										  dtIvaFechaPag,dtFechaApert,dtFechaCuota,dSdoInt_inh)
		  RETURNING cCodRet,dIvaIntReal_inh,cMensajeRet;



  IF cCodRet <> "000000" THEN
        LET cCodRet      = "000005";
        LET cMensajeRet  = "Ocurrio un error al realizar calculo de iva de interes";
        IF cBegin = "S" THEN
           ROLLBACK WORK;
        END IF;
     RETURN cCodRet,cMensajeRet;
  END IF;

 --              IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
 --              IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

       LET dProvIva_inh = dIvaIntReal_inh; -- dIvaProvFinMes;

       --IF  cStatusCred='BT' THEN
	   -- IFSR se ajusta para actualizar los codigos ref dependiendo la etapa
	   IF (cStatusCred in ('BT','E3')) THEN
            IF (cStatusCred = 'BT') THEN
				LET CodigoRefProvIva    = 9;   
				LET CodigoRefProvInt    = 8;  
			ELSE 
				LET CodigoRefProvIva    = 7027;   
				LET CodigoRefProvInt    = 7030;
			END IF;
       ELSE
			IF ( cStatusCred IN ("AA","BA")) THEN
				LET CodigoRefProvIva    = 7;
				LET CodigoRefProvInt    = 6;
			ELIF ( cStatusCred = 'E2' ) THEN
				LET CodigoRefProvIva    = 7032;
				LET CodigoRefProvInt    = 7035;
			ELSE  --IFSR Intereses para etapa 1
				LET CodigoRefProvIva    = 7031;
				LET CodigoRefProvInt    = 7034;
			END IF;
       END IF;

        IF dProvInt_inh > 0 THEN              
                LET dProvInt = dProvInt - dIntProvFinMes;
				
	/*			IF wbandera_apoyo = 'A' THEN
				
					CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt,
											  "606",  dtFechaHoy , dprovint_inh_aux, cFolio,
											  cSucursal, cDivisa, "0000",'PROV','')
					RETURNING cCodRet,cMensajeRet;
					
				ELSE */
					CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt,
											  "606",  dtFechaHoy , dProvInt_inh, cFolio,
											  cSucursal, cDivisa, "0000",'PROV','')
					RETURNING cCodRet,cMensajeRet;
	--			END IF;

                IF (cCodRet <> "000000") THEN
                       LET cCodRet      = cCodRet;
                       LET cMensajeRet = "Ocurrio un error al registrar la provision de interes";
                       IF cBegin = "S" THEN
                          ROLLBACK WORK;
                       END IF;
                       RETURN cCodRet,cMensajeRet;
                END IF;

            --LET dProvIva_inh = dProvIva_inh - dIvaProvFinMes; FMV 19mar13 NO SE DESCUENTA PROVISION FIN DE MES y PROVISIONA IVA
                IF dProvIva_inh > 0 THEN
			/*		IF wbandera_apoyo = 'A' THEN
					
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva,
				                          "606", dtFechaHoy , dIvaIntReal_inh_aux, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar la provision de iva de interes";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
					ELSE		*/
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva,
				                          "606", dtFechaHoy , dProvIva_inh, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar la provision de iva de interes";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
			--		END IF;
                END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
---SE AGREGA VALIDACION PARA NO GENERAR INTERES EXENTO NI GRAVABLE PARA CREDISOLUCIONES
			IF cNumProducto <> '6900' THEN
                IF dProvInt_inh>0 and dProvIva_inh<=0 then
                    LET dIntGrav_inh = dProvInt_inh;
                    LET dIntExen_inh = 0;
                ELSE
                    LET dIntGrav_inh = dProvIva_inh/dIvaSuc;
                    IF dIntGrav_inh>dProvInt_inh THEN LET dIntGrav_inh=dProvInt_inh; END IF;
                    LET dIntExen_inh = dProvInt_inh-dIntGrav_inh;
                END IF;

                IF dIntGrav_inh>0 THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 12,
				                          "606", case when cIdProc1 = "C" and cIdProc2 = "F" and cIdProc4 = "P"
                                           then dtFechaHoy end, dIntGrav_inh, cFolio,
										  cSucursal, cDivisa, "0000",'GRAV','')
							RETURNING cCodRet,cMensajeRet;
						
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el Interes Gravado";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
                IF dIntExen_inh>0 THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 13,
											  "606", case when cIdProc1 = "C" and cIdProc2 = "F" and cIdProc4 = "P"
											   then dtFechaHoy end, dIntExen_inh, cFolio,
											  cSucursal, cDivisa, "0000",'EXEN','')
							RETURNING cCodRet,cMensajeRet;
						
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el Interes Exento";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
			END IF;
---fin cas, Se agrega el movimiento aplicativo de interes gravable y exento
        END IF;
END IF;
--*************************************************************************
--   FIN DE PROVISION POR REGISTROS DE MOVTO EN FIN MES
--*************************************************************************
-- *******************************************************
--  PROVISION                                            *
-- *******************************************************
IF cIdProc1 = "C" OR cIdProc2 = "F" and (dSdoCapital + dCapTrasNoVen) > 0 THEN

           SELECT a.fecha_cuota, --  a.iva_pagado,
                  a.iva_fecha_pago,
                  NVL(a.capital_mto_cuota,0),NVL(num_pago,1)
             INTO dtFechaCuota,-- dIvaPag,
                  dtIvaFechaPag,
                  dCapMtoCuota,iNumPago
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status = "3";

               IF dtFechaCuota IS NOT NULL THEN
                   LET dtFechaCuotaAnt = dtFechaCuota;
               END IF;

-- LET dSdoInt = dSdoInt + dIntDiario;
 LET dProvInt = dSdoInt;

  CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
                                  dtIvaFechaPag,dtFechaApert,dtFechaCuota,dSdoInt)
  RETURNING cCodRet,dIvaIntReal,cMensajeRet;

  IF cCodRet <> "000000" THEN
        LET cCodRet      = "000005";
        LET cMensajeRet  = "Ocurrio un error al realizar calculo de iva de interes";
        IF cBegin = "S" THEN
           ROLLBACK WORK;
        END IF;
     RETURN cCodRet,cMensajeRet;
  END IF;

               IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
               IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

       LET dProvIva = dIvaIntReal; -- dIvaProvFinMes;

       --IF  cStatusCred='BT' THEN
	   -- IFSR se ajusta para actualizar los codigos ref dependiendo la etapa
	   IF (cStatusCred in ('BT','E3')) THEN -- IFSR se agrega validacion para nuevas e
            IF (cStatusCred = 'BT') THEN
				LET CodigoRefProvIva    = 9;   
				LET CodigoRefProvInt    = 8;  
			ELSE 
				LET CodigoRefProvIva    = 7027;   
				LET CodigoRefProvInt    = 7030;
			END IF;
       ELSE
			IF (cStatusCred IN ("AA","BA")) THEN
				LET CodigoRefProvIva    = 7;
				LET CodigoRefProvInt    = 6;
			ELIF (cStatusCred = "E2") THEN
				LET CodigoRefProvIva    = 7032;
				LET CodigoRefProvInt    = 7035;
			ELSE  --IFSR Intereses para etapa 1
				LET CodigoRefProvIva    = 7031;
				LET CodigoRefProvInt    = 7034;
			END IF;
       END IF;

        IF dProvInt > 0 THEN  
                IF cIdProc4 = '' THEN
                   LET dProvInt = dProvInt - dIntProvFinMes;
                ELSE
                   --LET dProvInt = dProvInt - dIntProvFinMes - dProvInt_inh;
				   LET dProvInt = dProvInt  - dProvInt_inh;	
                END IF;
		END IF;
        IF dProvInt > 0 THEN    

				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt,
				                          "606", dtFechaHoy ,dProvInt, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				RETURNING cCodRet,cMensajeRet;

                IF (cCodRet <> "000000") THEN
                       LET cCodRet      = cCodRet;
                       LET cMensajeRet = "Ocurrio un error al registrar la provision de interes";
                       IF cBegin = "S" THEN
                          ROLLBACK WORK;
                       END IF;
                       RETURN cCodRet,cMensajeRet;
                END IF;
                              
                IF cIdProc4 = '' THEN
                   LET dProvIva = dProvIva - dIvaProvFinMes;
                ELSE
                   --LET dProvIva = dProvIva - dIvaProvFinMes - dProvIva_inh;
                   LET dProvIva = dProvIva - dProvIva_inh;
                END IF;
  
                IF dProvIva > 0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva,
				                          "606", dtFechaHoy , dProvIva, cFolio,
										  cSucursal, cDivisa, "0000",'PROV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar la provision de iva de interes";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
---SE AGREGA VALIDACION PARA NO GENERAR INTERES EXENTO NI GRAVABLE PARA CREDISOLUCIONES
			IF cNumProducto <> '6900' THEN
                IF dProvInt>0 and dProvIva<=0 then
                    LET dIntGrav = dProvInt;
                    LET dIntExen = 0;
                ELSE
                    LET dIntGrav = dProvIva/dIvaSuc;
                    IF dIntGrav>dProvInt THEN LET dIntGrav=dProvInt; END IF;
                    LET dIntExen = dProvInt-dIntGrav;
                END IF;

                IF dIntGrav>0 THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 12,
				                          "606", dtFechaHoy , dIntGrav, cFolio,
										  cSucursal, cDivisa, "0000",'GRAV','')
							RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el Interes Gravado";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
				
                IF dIntExen>0 THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 13,
											  "606", dtFechaHoy , dIntExen, cFolio,
											  cSucursal, cDivisa, "0000",'EXEN','')
							RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "Ocurrio un error al registrar el Interes Exento";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;
                        END IF;
                END IF;
			END IF;
---fin cas, Se agrega el movimiento aplicativo de int gravable y exento
        END IF;
END IF;

-- *******************************************************
-- FACTURACION                                           *
-- *******************************************************

--FMV 31-ENE-11
IF cIdProc2 = "F" THEN

		--- se obtienen los  montos de INT e IVA de la maeretenido del programa de apoyo
		SELECT monto
			INTO psaldoInteresApoyo
		FROM bdicred:sd_maeretenido 
		WHERE num_credito = cNumCredito
			AND transacc = '8374'
			AND estatus = 'R';

			IF psaldoInteresApoyo IS NULL THEN
				LET psaldoInteresApoyo = 0;
			END IF;

		SELECT monto
			INTO psaldoIvaApoyo
		FROM bdicred:sd_maeretenido 
		WHERE num_credito = cNumCredito
			AND transacc ='8375'
			AND estatus = 'R';

		IF psaldoIvaApoyo IS NULL THEN
			LET psaldoIvaApoyo = 0;
		END IF;
		
		
		IF  (dSdoCapital + dCapTrasNoVen) <= 0 AND (psaldoInteresApoyo + psaldoIvaApoyo) > 0 THEN
			SELECT a.fecha_cuota, --  a.iva_pagado,
				a.iva_fecha_pago,
				NVL(a.capital_mto_cuota,0),NVL(num_pago,1)
			INTO dtFechaCuota,-- dIvaPag,
				dtIvaFechaPag,
				dCapMtoCuota,iNumPago
			FROM "informix".sd_amortiza_creditocrd a
			WHERE a.empresa        = cEmpresa
				AND a.num_credito    = cNumCredito
				AND a.capital_status = "3";

			IF dtFechaCuota IS NOT NULL THEN
				LET dtFechaCuotaAnt = dtFechaCuota;
			END IF;
		END IF;
			
			
END IF;
/*
IF cIdProc2 = "F" AND wbandera_apoyo = 'A' AND dtFechaHoy >= MDY (09,30,2020) AND dtFechaHoy < MDY (11,01,2020)  THEN 

	CALL sp_diferir_cancela_credito(cNumCteApoyo,cNumCredito,2,20) 
					RETURNING cCodRet,vMensaje;
					
				UPDATE bdicred:sd_programa_apoyo2020crd 
				SET bandera = 'B',fecha_inactivacion = CURRENT 
				WHERE num_credito = cNumCredito;
				
				UPDATE bdicred:sd_maecredcrd 
					SET campo_trab3 = ''
				WHERE num_credito = cNumCredito;		

				---- Tiene el saldo total de intereses identificando si realizo algun pago
				select nvl((interes_debe - interes_pagado),0),
					nvl((iva_debe - iva_pagado),0), iva_pagado
					into  psaldoInteresApoyo,
						  psaldoIvaApoyo, ivaPagadoAnterior
				from bdicred:sd_amortiza_creditocrd 
				where empresa = cEmpresa 
					and num_credito = cNumCredito 
					and fecha_cuota = ADD_MONTHS (dtFechaCuota, -1);

				IF psaldoInteresApoyo IS NULL THEN
					LET psaldoInteresApoyo = 0;
					LET psaldoIvaApoyo = 0;
					LET ivaPagadoAnterior = 0;
				END IF;
				
				select interes_pagado, iva_pagado, iva_debe
					into  pInteresactualPagado,pIvaActualPagado, apoyo_iva_debe
				from bdicred:sd_amortiza_creditocrd 
				where empresa = cEmpresa 
					and num_credito = cNumCredito 
					and capital_status = '3';
					
				IF pInteresactualPagado IS NULL THEN
					LET pInteresactualPagado = 0;
					LET pIvaActualPagado = 0;
					LET apoyo_iva_debe = 0;
				END IF;
				
				LET psaldoInteresApoyo = psaldoInteresApoyo - pInteresactualPagado;
				---	SI EL IVA DE APOYO ES MAYOR A CERO, SE DESCUENTA SI REALIZO PAGOS
				IF psaldoIvaApoyo > 0 THEN
						LET psaldoIvaApoyo = psaldoIvaApoyo - (pIvaActualPagado - ivaPagadoAnterior);
				END IF;

				IF psaldoIvaApoyo < 0 THEN
					LET psaldoIvaApoyo = 0;
				END IF;
				
				IF psaldoInteresApoyo < 0 THEN
					LET psaldoInteresApoyo = 0;
				END IF;
			
				IF psaldoInteresApoyo > 0 THEN
						
					INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
						VALUES('001',cNumCredito,cFolio,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'8374',0,psaldoInteresApoyo,user,'R','INTERES DIFERIDO PROGRAMA APOYO PP',cSucursal,0);

					INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
						VALUES('001',cNumCredito,cFolio,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'8375',0,psaldoIvaApoyo,user,'R','IVA INTERES DIFERIDO PROGRAMA APOYO PP',cSucursal,0);						
							
					UPDATE bdicred:sd_amortiza_creditocrd 
					SET interes_debe = interes_debe - psaldoInteresApoyo,
						iva_debe = iva_debe - psaldoIvaApoyo
					WHERE empresa = cEmpresa 
						and num_credito = cNumCredito 
						and capital_status = '3';	
						
					UPDATE bdicred:sd_maesdoscrd 
					SET provision_normal = provision_normal - psaldoInteresApoyo,
						sdo_global_int = sdo_global_int - psaldoIvaApoyo,
						sdo_retenido = sdo_retenido + psaldoInteresApoyo + psaldoIvaApoyo
					WHERE empresa = cEmpresa 
						and num_credito = cNumCredito ;
				END IF;
				
				
			LET dIvaIntVigente = dIvaIntVigente;
			LET dIvaIntVigente = dIvaIntVigente - psaldoIvaApoyo;

	
END IF;
*/
IF cIdProc2 = "F" AND (dSdoCapital + dCapTrasNoVen + psaldoInteresApoyo + psaldoIvaApoyo ) > 0 THEN

		LET iNumPago = iNumPago + 1 ;
        
      select nvl((interes_debe - interes_pagado),0),
				nvl((iva_debe - iva_pagado),0) + nvl(dIvaIntReal,0)
		  into  vlIntVenBal, vlIvaIntVenBal
		  from bdicred:sd_amortiza_creditocrd 
		  where empresa = cEmpresa 
			and num_credito = cNumCredito 
			and capital_status = '3';	 
			
			
			LET dSdoCapital = dSdoCapital;
			LET dCapTrasNoVen = dCapTrasNoVen;
			LET dCapMtoCuota = dCapMtoCuota;
			
        --- si la suma de capitales menos la cuota original menos insteres es < 0, es para obtener un monto cuota con todo lo que se debe
		--- capital e intereses (si el capital de la cuota es mayor al capital, se sustituye por el capital mas intereses)
		IF ((dSdoCapital + dCapTrasNoVen - (dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal )) <= 0)  
			and ((dSdoCapital + dCapTrasNoVen) > 0 OR (psaldoInteresApoyo + psaldoIvaApoyo) > 0) THEN
		
			LET dCapMtoCuotaApoyo = dCapMtoCuota - (dSdoCapital + dCapTrasNoVen + vlIntVenBal + vlIvaIntVenBal);
			IF (psaldoInteresApoyo + psaldoIvaApoyo) > 0 THEN
				--- 
				IF dCapMtoCuotaApoyo >= (psaldoInteresApoyo + psaldoIvaApoyo)  THEN
				
					LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + vlIntVenBal + vlIvaIntVenBal + psaldoInteresApoyo + psaldoIvaApoyo;
				
					UPDATE "informix".sd_amortiza_creditocrd
					   SET capital_mto_cuota   = dCapMtoCuota,
						interes_debe 			= interes_debe + psaldoInteresApoyo,
						iva_debe				= iva_debe + psaldoIvaApoyo
					 WHERE empresa             = cEmpresa
					   AND num_credito         = cNumCredito
					   AND capital_status      = "3";
					   
					LET vlIntVenBal = vlIntVenBal + psaldoInteresApoyo;
					LET vlIvaIntVenBal = vlIvaIntVenBal + psaldoIvaApoyo;

					   ------ cancelar  retenido
					UPDATE bdicred:sd_maeretenido 
						SET monto = 0, estatus = 'S'
					WHERE num_credito = cNumCredito
						AND transacc = '8374'
						AND estatus = 'R';
						
					UPDATE bdicred:sd_maeretenido 
						SET monto = 0, estatus = 'S'
					WHERE num_credito = cNumCredito
						AND transacc = '8375'
						AND estatus = 'R';
						
					UPDATE bdicred:sd_maesdoscrd 
					SET sdo_retenido = sdo_retenido - (psaldoInteresApoyo + psaldoIvaApoyo)
					WHERE empresa = cEmpresa 
						and num_credito = cNumCredito ;
						
					LET dPagoInt = psaldoInteresApoyo;
					LET dPagoIvaInt = psaldoIvaApoyo;
						
					LET psaldoInteresApoyo = 0;
					LET psaldoIvaApoyo = 0;
					   
				ELSE
						---- proporcional, acompletar cuota
					LET dFactor = psaldoInteresApoyo / (psaldoInteresApoyo + psaldoIvaApoyo);
					LET dPagoInt = round(dCapMtoCuotaApoyo * dFactor,2);		
					LET dPagoIvaInt = dCapMtoCuotaApoyo - dPagoInt;					
				
				
					UPDATE "informix".sd_amortiza_creditocrd
					   SET interes_debe 			= interes_debe + dPagoInt,
						iva_debe				= iva_debe + dPagoIvaInt
					 WHERE empresa             = cEmpresa
					   AND num_credito         = cNumCredito
					   AND capital_status      = "3";
					   
					LET vlIntVenBal = vlIntVenBal + dPagoInt;
					LET vlIvaIntVenBal = vlIvaIntVenBal + dPagoIvaInt;
					----- agregar movimientos
					------- disminuir de la retenido
					
					UPDATE bdicred:sd_maeretenido 
						SET monto = monto - dPagoInt
					WHERE num_credito = cNumCredito
						AND transacc = '8374'
						AND estatus = 'R';
						
					UPDATE bdicred:sd_maeretenido 
						SET monto = monto - dPagoIvaInt
					WHERE num_credito = cNumCredito
						AND transacc = '8375'
						AND estatus = 'R';
						
					UPDATE bdicred:sd_maesdoscrd 
					SET sdo_retenido = sdo_retenido - (dPagoInt + dPagoIvaInt)
					WHERE empresa = cEmpresa 
						and num_credito = cNumCredito ;
				
					LET psaldoInteresApoyo = psaldoInteresApoyo - dPagoInt;
					LET psaldoIvaApoyo = psaldoIvaApoyo - dPagoIvaInt;
					
				
				END IF;
				
				IF dPagoInt>0 THEN
					--IFSR se va a contemplar este movimiento, ya que se refiere a programa de apoyo 
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 50,
										  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dPagoInt, cFolio,
										  cSucursal, cDivisa, "0000",'INT','')
						RETURNING cCodRet,cMensajeRet;
						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000007";
							   LET cMensajeRet = "Ocurrio un error al registrar el Interes del Periodo";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
				END IF;				
				
				IF dPagoIvaInt>0 THEN
					--IFSR se va a contemplar este movimiento, ya que se refiere a programa de apoyo 
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 51,
										  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dPagoIvaInt, cFolio,
										  cSucursal, cDivisa, "0000",'INT','')
						RETURNING cCodRet,cMensajeRet;
						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000007";
							   LET cMensajeRet = "Ocurrio un error al registrar el Interes Periodo";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
				END IF;				
				
			ELSE  	

				LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + vlIntVenBal + vlIvaIntVenBal ;
			--	LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + dProvInt + dProvIva + dIntProvFinMes + dIvaProvFinMes;
				UPDATE "informix".sd_amortiza_creditocrd
				   SET capital_mto_cuota   = dCapMtoCuota
				 WHERE empresa             = cEmpresa
				   AND num_credito         = cNumCredito
				   AND capital_status      = "3";
			
			END IF;
		

		END IF;
		
		LET dCapMtoCuota_ori = dCapMtoCuota;
		---- cuando los intereses son mayor al monto cuota le deja todo el monto en un monto cuota sin limite
		IF  (dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal) < 0 THEN	
			LET dCapMtoCuota = vlIntVenBal + vlIvaIntVenBal;
					
				UPDATE "informix".sd_amortiza_creditocrd
				SET capital_mto_cuota   = dCapMtoCuota
				WHERE empresa             = cEmpresa
				AND num_credito         = cNumCredito
				AND capital_status      = "3";			
		END IF;
		
		LET dPagoIvaInt = dPagoIvaInt;
		let dIvaIntReal = dIvaIntReal;
		LET dIvaIntVigente	=dIvaIntVigente;
		
		----- la resta del monto cuota menos los intereses es para obtener solo el capital
        LET dMontofinanciado = dMontofinanciado + dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal;
        --LET dMontofinanciado = dMontofinanciado + dCapMtoCuota - dProvInt - dProvIva - dIntProvFinMes - dIvaProvFinMes - dProvInt_inh - dProvIva_inh;
        LET dSdotrab4 = dSdotrab4  + dCapMtoCuota - vlIntVenBal - vlIvaIntVenBal ;
        --LET dSdotrab4 = dSdotrab4  + dCapMtoCuota - dProvInt - dProvIva- dIntProvFinMes - dIvaProvFinMes - dProvInt_inh - dProvIva_inh;
        LET dSdomesantint = vlIntVenBal; --dSdoInt;
        LET dSdoNoExig = dSdoNoExig +  vlIntVenBal; --dSdoInt;
        LET dSdoInt = 0;
        LET dIvaIntVigente = dIvaIntVigente + dIvaIntReal + dPagoIvaInt;

        IF cIdProc2 = "F" THEN LET dIntProvFinMes=0; LET dIvaProvFinMes=0; END IF;

		UPDATE "informix".sd_amortiza_creditocrd
		   SET capital_debe        = capital_mto_cuota - vlIntVenBal - vlIvaIntVenBal,
			   iva_debe            = iva_debe + (dIvaIntReal),
			   capital_status      = "1",
			   capital_status_ant  = "3"
		 WHERE empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "3";


		select  capital_debe
		  into vlCapitalDebe
		  from "informix".sd_amortiza_creditocrd
		 WHERE empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "1";

		if vlCapitalDebe is null then let vlCapitalDebe = 0; end if;

		select interes_debe,
			   iva_debe
		  into dIntPeriodo,
			   dIvaPeriodo
		  from "informix".sd_amortiza_creditocrd
		 where empresa             = cEmpresa
		   AND num_credito         = cNumCredito
		   AND capital_status      = "1";

	    IF dIntPeriodo IS NULL THEN LET dIntPeriodo=0; END IF;
	    IF dIvaPeriodo IS NULL THEN LET dIvaPeriodo=0; END IF;

		IF dIntPeriodo>0 THEN
				
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 43,
											  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dIntPeriodo, cFolio,
											  cSucursal, cDivisa, "0000",'INT','')
							RETURNING cCodRet,cMensajeRet;
				IF (cCodRet <> "000000") THEN
					   LET cCodRet      = "000007";
					   LET cMensajeRet = "Ocurrio un error al registrar el Interes del Periodo";
					   IF cBegin = "S" THEN
						  ROLLBACK WORK;
					   END IF;
					   RETURN cCodRet,cMensajeRet;
				END IF;
		END IF;
		IF psaldoInteresApoyo>0 THEN
			--IFSR se va a contemplar este movimiento, ya que se refiere a programa de apoyo 
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 48,
								  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, psaldoInteresApoyo, cFolio,
								  cSucursal, cDivisa, "0000",'INT','')
				RETURNING cCodRet,cMensajeRet;
				IF (cCodRet <> "000000") THEN
					   LET cCodRet      = "000007";
					   LET cMensajeRet = "Ocurrio un error al registrar el Interes del Periodo";
					   IF cBegin = "S" THEN
						  ROLLBACK WORK;
					   END IF;
					   RETURN cCodRet,cMensajeRet;
				END IF;
		END IF;		
		IF dIvaPeriodo>0 THEN
					
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 44,
											  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dIvaPeriodo, cFolio,
											  cSucursal, cDivisa, "0000",'INT','')
							RETURNING cCodRet,cMensajeRet;
						--END IF;
				IF (cCodRet <> "000000") THEN
					   LET cCodRet      = "000007";
					   LET cMensajeRet = "Ocurrio un error al registrar el Interes Periodo";
					   IF cBegin = "S" THEN
						  ROLLBACK WORK;
					   END IF;
					   RETURN cCodRet,cMensajeRet;
				END IF;
		END IF;
		IF psaldoIvaApoyo>0 THEN
			--IFSR se va a contemplar este movimiento, ya que se refiere a programa de apoyo 
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 49,
								  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, psaldoIvaApoyo, cFolio,
								  cSucursal, cDivisa, "0000",'INT','')
				RETURNING cCodRet,cMensajeRet;
				IF (cCodRet <> "000000") THEN
					   LET cCodRet      = "000007";
					   LET cMensajeRet = "Ocurrio un error al registrar el Interes Periodo";
					   IF cBegin = "S" THEN
						  ROLLBACK WORK;
					   END IF;
					   RETURN cCodRet,cMensajeRet;
				END IF;
		END IF;		
      -- LET vlCapitalDebe = dCapMtoCuota - (interes_debe - interes_pagado) - (dIvaIntReal);
	  --FNV: 31-ENE-2011
		 --IF (dSdoCapital + dCapTrasNoVen - dCapMtoCuota) > 0 THEN
		 ----- agregar variables disminuidas, si sobra de retenido
		IF (dSdoCapital + dCapTrasNoVen - vlCapitalDebe) > 0 OR  (psaldoInteresApoyo + psaldoIvaApoyo) > 0 THEN
		
			LET dCapMtoCuota = dCapMtoCuota_ori;
	  -- IF (dSdoCapital - dCapMtoCuota) >  0 THEN
			   INSERT INTO "informix".sd_amortiza_creditocrd
						(
							empresa, 		    num_credito, 		fecha_cuota, 		tipo_cuota,
							capital_mto_cuota, 	capital_debe,		capital_pagado, 	capital_status,
							capital_status_ant, capital_fecha_pago,	interes_debe, 		interes_pagado,
							interes_status, 	interes_status_ant,	interes_fecha_pago, iva_debe,
							iva_pagado, 		iva_status,			iva_status_ant, 	iva_fecha_pago,
							mora_provi_ordi, 	mora_provi_cope,	mora_sdo_ordi, 		mora_sdo_ordi_pag,
							mora_sdo_cope, 		mora_sdo_cope_pag,	mora_bonificado, 	mora_status,
							mora_iva_debe, 		mora_iva_pagado,	mora_iva_status, 	mora_iva_fecha_pago,
							num_pago, 		    campo_trabajo1,		campo_trabajo2, 	campo_trabajo3,
							campo_trabajo4
						)
					VALUES
						(   cEmpresa,		    cNumCredito,	dtFechaProxCuota,	"3",
							dCapMtoCuota,        0,				0,			        "3",
							"3",         		"",				0,			         0,
							"1",                "1",			NULL,			     0,
							0,			        "1",			"1",                 "",
							0,			         0,				0,			         0,
							0,			         0,				0,			         "1",
							0,			          0,			"1",			     "",
							iNumPago,		      0,			0,			         "",
							""
						);
						
		END IF;
END IF;

-- *******************************************************
-- TRASPASOS                                             *
-- *******************************************************
    -- Traspaso de Vigente a Vencido Transitorio.
 IF  cIdProc3 = "M"  THEN 		--IFSR se quita validacion para hacer los traspasos diarios, dependiendo los dias

               SELECT NVL(a.capital_debe - a.capital_pagado,0),NVL(a.interes_debe - a.interes_pagado,0)
                 INTO dTraspCap,dTraspInt
                 FROM "informix".sd_amortiza_creditocrd a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status = "1";

					IF dTraspCap IS NULL THEN LET dTraspCap=0; END IF;
					IF dTraspInt IS NULL THEN LET dTraspInt=0; END IF;
----Realiza traspasos a transitorio
        --IF cStatusCred IN ('AA','BA') AND cNumProducto <> '6900' THEN
		IF (cStatusCred IN ('AA','BA') AND cNumProducto <> '6900') OR (cStatusCred = 'E1' AND iAtr <= 1 AND dSdoCapInso > 0 AND cNumProducto <> '6900') OR (cStatusCred = 'E1' AND iAtr >= 0 AND dSdoCapInso = 0 AND iDiasAtraso >= 0 AND iDiasAtraso < 30 AND cNumProducto <> '6900') THEN -- IFSR Se agrega validacion para tomar en cuanta las etapas E1
			IF dTraspCap>0 OR dTraspInt > 0 THEN

               LET dMntVencido = dMntVencido + dTraspCap;
               LET dSdoCapital = dSdoCapital - dTraspCap;

                UPDATE "informix".sd_amortiza_creditocrd 
                   SET capital_status = "7",
                       capital_status_ant  = "1",
                       campo_trabajo3 = ''
                 WHERE empresa        = cEmpresa
                   AND num_credito    = cNumCredito
                   AND capital_status = "1";

						--IF cStatusCred='AA' THEN
						IF cStatusCred='AA' OR (cStatusCred = 'E1' AND iAtr = 0) THEN -- IFSR Se agrega validacion para tomar en cuanta las etapas E1
							  --Se actualiza la fecha de vencimiento
							  UPDATE "informix".sd_maecredanexocrd
								 SET fecha_vencto  = dtFechaHoy
							   WHERE num_credito    = cNumCredito
								 AND empresa        = cEmpresa;

							 --FMV 25Abr13: Actualiza indicador del 1er. vencido y dias de atraso
							  UPDATE "informix".sd_indicador_cred_crd
								 SET fecha_vencido =  DECODE (nvl(fecha_vencido,date(1)) ,date(1), dtFechaHoy, fecha_vencido)
							   WHERE num_credito   = cNumCredito
								 AND empresa       = cEmpresa;
						END IF;

                  -- Traspaso capital vigente a transitorio.
				  -- IFSR Traspaso capital vigente a transitorio. por etapa
						IF ((iAtr >=0 AND iAtr <=1 AND cStatusCred = 'E1' AND iDiasAtraso >= 0 AND iDiasAtraso < 30 AND dSdoCapInso = 0) OR (iAtr <=1 and cStatusCred = 'E1' AND dSdoCapInso > 0)) THEN 
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7049,
								  "026", dtFechaHoy, dTraspCap, cFolio,
								  cSucursal, cDivisa, "0000",'TCVAT','')
							RETURNING cCodRet,cMensajeRet;
							
							IF (cCodRet <> "000000") THEN
							   LET cCodRet      = cCodRet;
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vigente a transitorio";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						 END IF;
						
						ELIF (cStatusCred NOT IN ('E1','E2','E3')) THEN 
						  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 3,
								  "026", dtFechaHoy, dTraspCap, cFolio,
								  cSucursal, cDivisa, "0000",'TCVAT','')
						  RETURNING cCodRet,cMensajeRet;
						  
						  IF (cCodRet <> "000000") THEN
							   LET cCodRet      = cCodRet;
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vigente a transitorio";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						 END IF;
						END IF;
						
					    IF dTraspInt > 0 AND (cStatusCred NOT IN ('E1','E2','E3')) THEN
						  -- Traspaso interes vigente a transitorio.
						 
						  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 6,
								  "026", dtFechaHoy, dTraspInt, cFolio,
								  cSucursal, cDivisa, "0000",'TCVAT','')
						  RETURNING cCodRet,cMensajeRet;
						
							IF (cCodRet <> "000000") THEN
								   LET cCodRet      = cCodRet;
								   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vigente a transitorio";
								   IF cBegin = "S" THEN
									  ROLLBACK WORK;
								   END IF;
								   RETURN cCodRet,cMensajeRet;
							 END IF;
					    END IF; -- IF dTraspInt > 0 THEN
            END IF; --IF dTraspCap>0 THEN
			
-- IFSR Traspaso capital vencido no exigible a vencido exigible. por etapa
			IF ((iAtr =1 AND cStatusCred = 'E1' AND iDiasAtraso >= 0 AND iDiasAtraso < 30 AND dSdoCapInso = 0) OR (iAtr =1 and cStatusCred = 'E1' AND dSdoCapInso > 0)) THEN 
			
					CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7070,
					   "026", dtFechaHoy, dMntVencido, cFolio,
					   cSucursal, cDivisa, "0000",'TCVNEAVE','')
					RETURNING cCodRet,cMensajeRet;
					
					CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7071,
					   "026", dtFechaHoy, dSdoCapital, cFolio,
					   cSucursal, cDivisa, "0000",'TCVNEAVE','')
					RETURNING cCodRet,cMensajeRet;

			
			ELIF ((iAtr = 3 AND cStatusCred = 'E2' AND iDiasAtraso >= 30 AND iDiasAtraso < 90 AND dSdoCapInso = 0) OR (iAtr = 3 and cStatusCred = 'E2' AND dSdoCapInso > 0)) THEN
			
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7072,
					   "026", dtFechaHoy, dMntVencido, cFolio,
					   cSucursal, cDivisa, "0000",'TCVNEAVE','')
					RETURNING cCodRet,cMensajeRet;
				
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7073,
					   "026", dtFechaHoy, dSdoCapital, cFolio,
					   cSucursal, cDivisa, "0000",'TCVNEAVE','')
					RETURNING cCodRet,cMensajeRet;
			
			END IF;
			
			-- IFSR Traspaso intereses por etapa
			IF ((iAtr =1 AND cStatusCred = 'E1' AND iDiasAtraso >= 0 AND iDiasAtraso < 30 AND dSdoCapInso = 0) OR (iAtr =1 and cStatusCred = 'E1' AND dSdoCapInso > 0)) THEN 
			
					CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7105,
					   "026", dtFechaHoy, dIntPeriodoTras, cFolio,
					   cSucursal, cDivisa, "0000",'TCVNEAVE','')
					RETURNING cCodRet,cMensajeRet;
					
			
			ELIF ((iAtr = 3 AND cStatusCred = 'E2' AND iDiasAtraso >= 30 AND iDiasAtraso < 90 AND dSdoCapInso = 0) OR (iAtr = 3 and cStatusCred = 'E2' AND dSdoCapInso > 0)) THEN
			
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7107,
					   "026", dtFechaHoy, dIntPeriodoTras, cFolio,
					   cSucursal, cDivisa, "0000",'TCVNEAVE','')
					RETURNING cCodRet,cMensajeRet;
				
				IF (dIntPeriodoTrasOrd > 0) THEN
					CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7108,
						   "026", dtFechaHoy, dIntPeriodoTrasOrd, cFolio,
						   cSucursal, cDivisa, "0000",'TCVNEAVE','')
						RETURNING cCodRet,cMensajeRet;
				END IF;
				
				IF (dIvaIntPeriodoTrasOrd > 0) THEN
					CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7109,
						   "026", dtFechaHoy, dIvaIntPeriodoTrasOrd, cFolio,
						   cSucursal, cDivisa, "0000",'TCVNEAVE','')
						RETURNING cCodRet,cMensajeRet;
				END IF;
			
			END IF;
			
		END IF; --IF cStatusCred IN ('AA','BA') AND cNumProducto <> '6900' THEN

        --ELSE
			--IF cIdProc3 = "M" AND cStatusCred='BT' THEN
			-- IFSR Se agrega validacion para contemplar la etapa 2 y 3
			IF cIdProc3 = "M" AND (cStatusCred='BT' OR (((iAtr >=1 AND cStatusCred IN('E2','E3') AND iDiasAtraso >= 1 AND dSdoCapInso = 0) OR (iAtr >=1 and cStatusCred IN('E2','E3') AND dSdoCapInso > 0))) ) THEN 
                IF (cStatusCred IN ('BT')) then
					LET dMntVencTras = dMntVencTras + dTraspCap;
					LET dCapTrasNoVen = dCapTrasNoVen - dTraspCap;
					LET dIntVdo = dIntVdo + dSdoNoExig;
					LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;
					LET dIvaIntVigente=0;
				END IF;
				--IFSR pasar a vencido hasta que sea E3 y el sdoNoExig
				IF ((cStatusCred IN ('E2') and iAtr >= 3) or cStatusCred in ('E3')) then
					LET dIntVdo = dIntVdo + dSdoNoExig;
					LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;
					LET dIvaIntVigente=0;
					LET dSdoNoExig = 0;
				END IF;
				
				--IFSR se actualizan los saldos
				IF (cStatusCred IN ('E2','E3')) then
					LET dMntVencido = dMntVencido + dTraspCap;
					LET dSdoCapital = dSdoCapital - dTraspCap;
				END IF;

				IF (cStatusCred IN ('E1','E2','E3') ) then
					UPDATE "informix".sd_amortiza_creditocrd
					   --SET capital_status = "2",
						   --capital_status_ant  = "1",
						SET capital_status = (CASE WHEN cStatusCred IN ("BT","E2") AND iAtr <= 2 THEN "2" ELSE "6" END), -- IFSR se agrega validacion para que se actualice el status a 2 o 6 dependiendo la etapa
						   capital_status_ant  = (CASE WHEN cStatusCred IN ("BT","E2") AND iAtr <= 2 THEN "1" ELSE "2" END),
						   --campo_trabajo3 ='V'
						   --campo_trabajo3 = (CASE WHEN cStatusCred IN ("BT","E2") AND iAtr >=3 THEN "" ELSE "V" END)
						   campo_trabajo3 = (CASE WHEN (cStatusCred = 'BT' or ((cStatusCred IN ("E3") AND iAtr >= 1))) THEN "V" ELSE "" END)
					 WHERE empresa        = cEmpresa
					   AND num_credito    = cNumCredito
					   AND capital_status = "1";
				ELSE
				
					UPDATE "informix".sd_amortiza_creditocrd
					   SET capital_status = "2",
						   capital_status_ant  = "1",
						   campo_trabajo3 ='V'
					 WHERE empresa        = cEmpresa
					   AND num_credito    = cNumCredito
					   AND capital_status = "1";
				
				END IF;

			   IF (cStatusCred IN ('BT')) then
					LET dSdoNoExig = 0;
			   END IF;

                  -- Traspaso capital vencido no exigible a vencido exigible.
                IF dTraspCap > 0 THEN --FMV 25Mar13: Se omite generar movimiento en 0, cuando ya termino devengamiento
				
					-- IFSR Traspaso capital vencido no exigible a vencido exigible. por etapa
						IF ((iAtr >=0 AND iAtr <=1 AND cStatusCred = 'E1' AND iDiasAtraso >= 0 AND iDiasAtraso < 30 AND dSdoCapInso = 0) OR (iAtr <=1 and cStatusCred = 'E1' AND dSdoCapInso > 0)) THEN 
						
								CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7055,
								   "026", dtFechaHoy, dTraspCap, cFolio,
								   cSucursal, cDivisa, "0000",'TCVNEAVE','')
								RETURNING cCodRet,cMensajeRet;

						
						ELIF ((iAtr >=1 AND iAtr <=3 AND cStatusCred = 'E2' AND iDiasAtraso >= 30 AND iDiasAtraso < 90 AND dSdoCapInso = 0) OR (iAtr >=1 and cStatusCred = 'E2' AND dSdoCapInso > 0)) THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7056,
								   "026", dtFechaHoy, dTraspCap, cFolio,
								   cSucursal, cDivisa, "0000",'TCVNEAVE','')
								RETURNING cCodRet,cMensajeRet;
						
						ELIF ((iAtr >=1 and cStatusCred = 'E3' AND dSdoCapInso > 0) OR (iAtr >=1 AND cStatusCred = 'E3' AND iDiasAtraso >= 90 AND dSdoCapInso = 0)) THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7057,
								   "026", dtFechaHoy, dTraspCap, cFolio,
								   cSucursal, cDivisa, "0000",'TCVNEAVE','')
								RETURNING cCodRet,cMensajeRet;
						
						ELIF (cStatusCred NOT IN ('E1','E2','E3')) THEN
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 2,
								   "026", dtFechaHoy, dTraspCap, cFolio,
								   cSucursal, cDivisa, "0000",'TCVNEAVE','')
								RETURNING cCodRet,cMensajeRet;
						END IF;

                    IF (cCodRet <> "000000") THEN
                           LET cCodRet      = "000014";
                           LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vencido no exigible a vencido exigible";
							IF cBegin = "S" THEN
                              ROLLBACK WORK;
                            END IF;
                           RETURN cCodRet,cMensajeRet;
                    END IF;
                END IF;  --dTraspCap > 0 THEN  FMV 25Mar13:
				
				-- IFSR Traspaso capital vencido no exigible a vencido exigible. por etapa
						IF ((iAtr =1 AND cStatusCred = 'E1' AND iDiasAtraso >= 0 AND iDiasAtraso < 30 AND dSdoCapInso = 0) OR (iAtr =1 and cStatusCred = 'E1' AND dSdoCapInso > 0)) THEN 
						
								CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7070,
								   "026", dtFechaHoy, dMntVencido, cFolio,
								   cSucursal, cDivisa, "0000",'TCVNEAVE','')
								RETURNING cCodRet,cMensajeRet;
								
								CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7071,
								   "026", dtFechaHoy, dSdoCapital, cFolio,
								   cSucursal, cDivisa, "0000",'TCVNEAVE','')
								RETURNING cCodRet,cMensajeRet;

						
						ELIF ((iAtr = 3 AND cStatusCred = 'E2' AND iDiasAtraso >= 30 AND iDiasAtraso < 90 AND dSdoCapInso = 0) OR (iAtr = 3 and cStatusCred = 'E2' AND dSdoCapInso > 0)) THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7072,
								   "026", dtFechaHoy, dMntVencido, cFolio,
								   cSucursal, cDivisa, "0000",'TCVNEAVE','')
								RETURNING cCodRet,cMensajeRet;
							
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7073,
								   "026", dtFechaHoy, dSdoCapital, cFolio,
								   cSucursal, cDivisa, "0000",'TCVNEAVE','')
								RETURNING cCodRet,cMensajeRet;
						
						END IF;
						
						-- IFSR Traspaso intereses por etapa
						IF ((iAtr =1 AND cStatusCred = 'E1' AND iDiasAtraso >= 0 AND iDiasAtraso < 30 AND dSdoCapInso = 0) OR (iAtr =1 and cStatusCred = 'E1' AND dSdoCapInso > 0)) THEN 
						
								CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7105,
								   "026", dtFechaHoy, dIntPeriodoTras, cFolio,
								   cSucursal, cDivisa, "0000",'TCVNEAVE','')
								RETURNING cCodRet,cMensajeRet;
								
						ELIF ((iAtr = 3 AND cStatusCred = 'E2' AND iDiasAtraso >= 30 AND iDiasAtraso < 90 AND dSdoCapInso = 0) OR (iAtr = 3 and cStatusCred = 'E2' AND dSdoCapInso > 0)) THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7107,
								   "026", dtFechaHoy, dIntPeriodoTras, cFolio,
								   cSucursal, cDivisa, "0000",'TCVNEAVE','')
								RETURNING cCodRet,cMensajeRet;
							
							IF (dIntPeriodoTrasOrd > 0) THEN
								CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7108,
									   "026", dtFechaHoy, dIntPeriodoTrasOrd, cFolio,
									   cSucursal, cDivisa, "0000",'TCVNEAVE','')
									RETURNING cCodRet,cMensajeRet;
							END IF;
							
							IF (dIvaIntPeriodoTrasOrd > 0) THEN
								CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7109,
									   "026", dtFechaHoy, dIvaIntPeriodoTrasOrd, cFolio,
									   cSucursal, cDivisa, "0000",'TCVNEAVE','')
									RETURNING cCodRet,cMensajeRet;
							END IF;
						
						END IF;
				
			END IF; --IF cIdProc3 = "M" AND cStatusCred='BT' THEN


                UPDATE "informix".sd_maecredanexocrd
                   SET prox_fecha_pago = dtFechaProxCuota,
                       dia_corte       = iDiaCorte
                  WHERE num_credito     = cNumCredito
                    AND empresa         = cEmpresa;

                    --IF (cStatusCredIndica = "AA" and dTraspCap>0 and cNumProducto <> '6900') then}
					IF ((cStatusCredIndica = "AA" OR (cStatusCred = 'E1' AND iAtr = 0)) and dTraspCap>0 and cNumProducto <> '6900') then -- IFSR se agrega validacion para que tome los creditos con atr = 0
                        --let cStatusCredIndica = 'BA';
						IF cStatusCredIndica = 'AA' THEN
							LET cStatusCredIndica = 'BA';
						ELSE
							LET cStatusCredIndica = 'E1';
						END IF;
						IF (cStatusCred IN ('E1','E2','E3')) then LET iAtrNvo = iAtr + 1; END IF;                    END IF;

				IF (cStatusCred NOT IN ('E1','E2','E3')) then
					UPDATE "informix".sd_maecredcrd
                   SET status_cred = (CASE WHEN cStatusCred = "AA" and dTraspCap>0 and cNumProducto <> '6900' THEN "BA" ELSE status_cred END),				   
                       fecha_pago_cap = dtFechaProxCuota,
                       fecha_pago_int = dtFechaProxCuota
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;
				ELSE 
					UPDATE "informix".sd_maecredcrd
					   SET status_cred = cStatusCredIndica,
						   fecha_pago_cap = dtFechaProxCuota,
						   fecha_pago_int = dtFechaProxCuota
					 WHERE num_credito = cNumCredito
					   AND empresa     = cEmpresa;
				 END IF;
---Ini cas Validacion solicitada por operaciones para que no cobre el int devengado
---de un dia cuando la reestructura llega a su ultima mensualidad
                    IF dCapTrasNoVen = 0 AND dSdoCapital = 0 AND dSdoInt > 0 THEN
                       LET dSdoInt = 0;
                    END IF;
---Fin cas Validacion solicitada por operaciones
END IF;

------Realiza traspasos a vencido
-- FMV 9jul2013: Traspaso a Vencido aquellos prestamos que llegan a la ultima cuota y pasan los 90 dias vencidos
-- JOM 11/04/2013 Se cambia traspado a periodos INI
-- Se realiza el traspado en la mensualidad 4 para considerar 90 o mas dias en transitorio            
           SELECT COUNT(a.num_credito), nvl(min(fecha_cuota), date(1))
             INTO iNumVdos, dFechacuotamin
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status IN ("2","7","6"); --IFRS se agrega para que se contemplen los creditos con el capital_status = 6
            
            IF day(dtFechaHoy) >= iDiaCorte  then 
                LET iNumVdosaux = months_between(dtFechaHoy ,dFechacuotamin ) + 1;  
            ELSE 
                LET iNumVdosaux = months_between(dtFechaHoy ,dFechacuotamin );
            END IF;
			
			--IF(dSdoCapInso > 0 and day(dtFechaHoy) = iDiaCorte AND cStatusCredIndica NOT IN('AA','BA','BT') ) THEN --IFSR se agrega validacion para identificar a que estapa se va a mover
			--IF(dSdoCapInso > 0 and cIdProc3 = "M" AND cStatusCredIndica NOT IN('AA','BA','BT') and dTraspCap>0) THEN --IFSR se agrega validacion para identificar a que estapa se va a mover
			IF(dSdoCapInso > 0 and cIdProc3 = "M" AND cStatusCredIndica NOT IN('AA','BA','BT')) THEN --IFSR se agrega validacion para identificar a que estapa se va a mover
				IF(iAtr = 0) THEN --IFSR se toma en cuenta solamente el atr
					LET cStatusCredIndica = 'E1';
					LET iAtrNvo = iAtr + 1;
					LET cCapitalStatus = '7';
				ELIF (iAtr = 1) then
					LET cStatusCredIndica = 'E2';
					LET iAtrNvo = iAtr + 1;
					LET cCapitalStatus = '2';
				ELIF (iAtr = 2) then
					LET cStatusCredIndica = 'E2';
					LET iAtrNvo = iAtr + 1;
					LET cCapitalStatus = '2';
				ELIF (iAtr = 3) then
					LET cStatusCredIndica = 'E3';
					LET iAtrNvo = iAtr + 1;
					LET cCapitalStatus = '6';
				ELIF (iAtr > 3) then
					LET cStatusCredIndica = 'E3';
					LET iAtrNvo = iAtr + 1;
					LET cCapitalStatus = '6';
				END IF;
			--ELIF(dSdoCapInso <= 0 and cIdProc3 = "M" AND cStatusCredIndica NOT IN('AA','BA','BT') and dTraspCap>0) THEN --IFSR se toma en cuenta el atr y los dias de atraso --IFSR se toma en cuenta el atr y los dias de atraso
			ELIF(dSdoCapInso <= 0 and cIdProc3 = "M" AND cStatusCredIndica NOT IN('AA','BA','BT')) THEN --IFSR se toma en cuenta el atr y los dias de atraso --IFSR se toma en cuenta el atr y los dias de atraso
				IF(iDiasAtraso = 0 OR (iAtr <= 1 AND iDiasAtraso > 0 AND iDiasAtraso < 30)) THEN -- IFSR si el saldo capital vigente es igual a cero y sus dias de atraso son cero, se pasa a etapa 1
					LET cStatusCredIndica = 'E1';
					LET iAtrNvo = iAtr + 1;
					LET cCapitalStatus = '7';
				ELIF (iAtr > 0 AND iDiasAtraso >= 30 AND iDiasAtraso < 90) then -- IFSR si el saldo capital vigente es igual a cero y sus dias de atraso son cero, se pasa a etapa 2
					LET cStatusCredIndica = 'E2';
					LET iAtrNvo = iAtr + 1;
					LET cCapitalStatus = '2';
				ELIF (iAtr > 0 AND iDiasAtraso >= 90) then -- IFSR si el saldo capital vigente es igual a cero y sus dias de atraso son cero, se pasa a etapa 3
					LET cStatusCredIndica = 'E3';
					LET iAtrNvo = iAtr + 1;
					LET cCapitalStatus = '6';
				END IF;
			END IF;

            --IF (cStatusCred='BA' AND iNumVdos >= 4) or (cStatusCred='BA' and iNumVdos < iNumVdosaux and iNumVdosaux >= 4 and dFechacuotamin <> date(1)) 
			IF (cStatusCred='BA' AND iNumVdos >= 4) or (cStatusCred='BA' and iNumVdos < iNumVdosaux and iNumVdosaux >= 4 and dFechacuotamin <> date(1)) or 
				(((cStatusCred = 'E1' AND iAtr = 1 AND dSdoCapInso = 0 AND iDiasAtraso > 0 AND iDiasAtraso < 30) or (cStatusCred = 'E1' AND iAtr = 1 AND dSdoCapInso > 0) or (cStatusCred = 'E2' AND iAtr >= 1 and iAtr <= 3 AND dSdoCapInso = 0 AND iDiasAtraso >= 30 AND iDiasAtraso < 90) or (cStatusCred = 'E2' AND iAtr >= 1 and iAtr <= 3 AND dSdoCapInso > 0) or (cStatusCred = 'E3' AND iAtr >= 1 AND dSdoCapInso = 0 AND iDiasAtraso >= 90 AND iDiasAtraso < 90) or (cStatusCred = 'E3' AND iAtr >= 1 AND dSdoCapInso > 0)) and dFechacuotamin <> date(1) and cIdProc3 = "M")
--            IF cStatusCred='BA' AND (dtFechaVencto + vi_dias_trasp_cap <= dtFechaHoy) --OR vf_fecha_vencim < dtFechaHoy
-- JOM 11/04/2013 Se cambia traspado a periodos FIN
				  THEN
					--- se obtienen los  montos de INT de la maeretenido del programa de apoyo
					   SELECT monto
						 INTO psaldoInteresTrasApoyo
						 FROM bdicred:sd_maeretenido 
						WHERE num_credito = cNumCredito
						  AND transacc = '8374'
						  AND estatus = 'R';

						IF psaldoInteresTrasApoyo IS NULL THEN
							LET psaldoInteresTrasApoyo = 0;
						END IF;
						
						IF (cStatusCred NOT IN ('E1','E2','E3') ) then 
							LET dCapTrasNoVen = dCapTrasNoVen + dSdoCapital;
							LET dMntVencTras = dMntVencTras + dMntVencido;
							LET dIntVdo = dIntVdo + dSdoNoExig;
							LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;
						END IF;
						--IFSR pasar a vencido hasta que sea E3 y el sdoNoExig
						IF ((cStatusCred IN ('E2') and iAtr >= 3) or cStatusCred in ('E3')) then
							LET dIntVdo = dIntVdo + dSdoNoExig;
							LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;
							--LET dIvaIntVigente=0;
							--LET dSdoNoExig = 0;
						END IF;
						
						IF (cStatusCred NOT IN ('E1','E2','E3') ) then 
						
							UPDATE "informix".sd_maecredcrd
							   SET status_cred = "BT"
							 WHERE num_credito = cNumCredito
							   AND empresa     = cEmpresa;
							   
							   UPDATE "informix".sd_amortiza_creditocrd
							   SET capital_status = "2",
								   capital_status_ant  = "7"
							 WHERE empresa        = cEmpresa
							   AND num_credito    = cNumCredito
							   AND capital_status = "7";
						
						ELSE
							UPDATE "informix".sd_maecredcrd
							   SET status_cred = cStatusCredIndica -- IFSR actualizacion de status
							 WHERE num_credito = cNumCredito
							   AND empresa     = cEmpresa;
							   
							UPDATE "informix".sd_amortiza_creditocrd
							   SET capital_status = cCapitalStatus,		
									--capital_status_ant  = "7"
									capital_status_ant = capital_status
							 WHERE empresa        = cEmpresa
							   AND num_credito    = cNumCredito
							   --AND capital_status = "7";
							   AND capital_status in ('2','7');
						END IF;
                  -- Traspaso capital vigente a vdo no exigible.
					IF dCapTrasNoVen > 0 THEN
					
						-- IFSR  Traspaso capital vigente a vdo no exigible por etapa
						IF ((iAtr >=0 AND iAtr <=1 AND cStatusCred = 'E1' AND iDiasAtraso >= 0 AND iDiasAtraso < 30 AND dSdoCapInso = 0) OR (iAtr <=1 and cStatusCred = 'E1' AND dSdoCapInso > 0)) THEN 
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7058,
								  "026", dtFechaHoy, dSdoCapital, cFolio,
								  cSucursal, cDivisa, "0000",'TCVAVNE','')
						  RETURNING cCodRet,cMensajeRet;

						
						ELIF ((iAtr >=1 AND iAtr <=3 AND cStatusCred = 'E2' AND iDiasAtraso >= 30 AND iDiasAtraso < 90 AND dSdoCapInso = 0) OR (iAtr >=1 and cStatusCred = 'E2' AND dSdoCapInso > 0)) THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7059,
								  "026", dtFechaHoy, dSdoCapital, cFolio,
								  cSucursal, cDivisa, "0000",'TCVAVNE','')
						  RETURNING cCodRet,cMensajeRet;
						
						ELIF ((iAtr >=1 and cStatusCred = 'E3' AND dSdoCapInso > 0) OR (iAtr >=1 AND cStatusCred = 'E3' AND iDiasAtraso >= 90 AND dSdoCapInso = 0)) THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7060,
								  "026", dtFechaHoy, dSdoCapital, cFolio,
								  cSucursal, cDivisa, "0000",'TCVAVNE','')
						  RETURNING cCodRet,cMensajeRet;
						
						ELIF (cStatusCred NOT IN ('E1','E2','E3')) THEN
						  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 4,
								  "026", dtFechaHoy, dSdoCapital, cFolio,
								  cSucursal, cDivisa, "0000",'TCVAVNE','')
						  RETURNING cCodRet,cMensajeRet;
						END IF;
						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000010";
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital vigente a vdo no exigible";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
					END IF; -- IF dCapTrasNoVen > 0 THEN

					  -- Traspaso capital transitorio a exigible.
					IF dMntVencTras  > 0 THEN
					
					-- IFSR Traspaso capital transitorio a exigible. por etapa
						IF ((iAtr >=0 AND iAtr <=1 AND cStatusCred = 'E1' AND iDiasAtraso >= 0 AND iDiasAtraso < 30 AND dSdoCapInso = 0) OR (iAtr <=1 and cStatusCred = 'E1' AND dSdoCapInso > 0)) THEN 
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7061,
								  "026", dtFechaHoy, dMntVencido, cFolio,
								  cSucursal, cDivisa, "0000",'TCTAE','')
						  RETURNING cCodRet,cMensajeRet;

						
						ELIF ((iAtr >=1 AND iAtr <=3 AND cStatusCred = 'E2' AND iDiasAtraso >= 30 AND iDiasAtraso < 90 AND dSdoCapInso = 0) OR (iAtr >=1 and cStatusCred = 'E2' AND dSdoCapInso > 0)) THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7062,
								  "026", dtFechaHoy, dMntVencido, cFolio,
								  cSucursal, cDivisa, "0000",'TCTAE','')
						  RETURNING cCodRet,cMensajeRet;
						
						ELIF ((iAtr >=1 and cStatusCred = 'E3' AND dSdoCapInso > 0) OR (iAtr >=1 AND cStatusCred = 'E3' AND iDiasAtraso >= 90 AND dSdoCapInso = 0)) THEN
						
							CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7063,
								  "026", dtFechaHoy, dMntVencido, cFolio,
								  cSucursal, cDivisa, "0000",'TCTAE','')
						  RETURNING cCodRet,cMensajeRet;
						
						ELIF (cStatusCred NOT IN ('E1','E2','E3')) THEN
						
						  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 1,
								  "026", dtFechaHoy, dMntVencido, cFolio,
								  cSucursal, cDivisa, "0000",'TCTAE','')
						  RETURNING cCodRet,cMensajeRet;
						END IF;

						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000011";
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso capital transitorio a exigible";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
					END IF; -- IF dMntVencTras  > 0

					  -- Traspaso interes vigente a vdo.
					IF dIntVdo > 0 THEN
					
					IF (cStatusCred NOT IN ('E1','E2','E3')) THEN
						  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 5,
								  "026", dtFechaHoy, dSdoNoExig, cFolio,
								  cSucursal, cDivisa, "0000",'TIVAV','')
						  RETURNING cCodRet,cMensajeRet;
						  
						  IF (cCodRet <> "000000") THEN
							   LET cCodRet      = "000012";
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso interes vigente a vdo";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						END IF;
						END IF;

						
					END IF; --IF dIntVdo > 0
					
					IF psaldoInteresTrasApoyo > 0 THEN
					  -- Traspaso interes vigente a transitorio.
					  
						  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 7,
								  "026", dtFechaHoy, psaldoInteresTrasApoyo, cFolio,
								  cSucursal, cDivisa, "0000",'TIVAV','')
						  RETURNING cCodRet,cMensajeRet;
						  
						IF (cCodRet <> "000000") THEN
							   LET cCodRet      = cCodRet;
							   LET cMensajeRet = "Ocurrio un error al registrar traspaso Interes Apoyo vigente a transitorio";
							   IF cBegin = "S" THEN
								  ROLLBACK WORK;
							   END IF;
							   RETURN cCodRet,cMensajeRet;
						 END IF;
					END IF;

					IF (cStatusCred NOT IN ('E1','E2','E3') ) then 
						LET dSdoCapital = 0;
						LET dMntVencido = 0;
						LET dIvaIntVigente = 0;
						LET dSdoNoExig = 0;
					END IF;
            END IF; --  cStatusCred='BA' AND (dtFechaVencto + vi_dias_trasp_cap <= dtFechaHoy) OR vf_fecha_vencim < dtFechaHoy


-- *******************************************************
-- CALCULO DE INTERES MORATORIO                          *
-- *******************************************************
    LET dTasaInterMorCop = dTasaInterMor - dTasaInter;
--IPCB	
	IF dTasaInterMorCop < 0 THEN
		LET dTasaInterMorCop = 0;
	END IF;
	
FOREACH
     SELECT a.fecha_cuota,
            SUM(NVL(a.capital_debe,0) - NVL(a.capital_pagado,0))
       INTO dtFechaCuota,
            dSdoMora
       FROM "informix".sd_amortiza_creditocrd a
      WHERE a.empresa        = cEmpresa
        AND a.num_credito    = cNumCredito
        AND a.capital_status IN ("2","7","6") -- IFSR se agrega condicion para que se contemplen los creditos con capital_status = 6
   GROUP BY 1

     IF NVL(dSdoMora,0) > 0 THEN
          --Se calcula el interes moratorio
          LET dIntMora = (dSdoMora * dTasaInter / (iDiasCalc * 100)) * iDiasInt;

          --Se calculan el interes moratorio copete
          LET dIntCope = (dSdoMora * dTasaInterMorCop / (iDiasCalc * 100)) * iDiasInt;

          -- se actualizan los intereses moratorios en la amortizacrd
          UPDATE "informix".sd_amortiza_creditocrd
             SET mora_sdo_ordi = mora_sdo_ordi + dIntMora,
                 mora_sdo_cope = mora_sdo_cope + dIntCope
           WHERE empresa     = cEmpresa
             AND num_credito = cNumCredito
             AND fecha_cuota = dtFechaCuota;

             LET dSdomoratorio = dSdomoratorio + dIntCope;
             LET dSdocontabmora = dSdocontabmora + dIntMora;
     END IF;
END FOREACH;

   SELECT COUNT(*), min(fecha_cuota) 
     INTO iNumVdos,iFechaVencto
     FROM "informix".sd_amortiza_creditocrd a
    WHERE a.empresa        = cEmpresa
      AND a.num_credito    = cNumCredito
      AND a.capital_status IN ("2","7","6"); -- IFSR se agrega condicion para que se contemplen los creditos con capital_status = 6

   IF iNumVdos IS NULL THEN
      LET iNumVdos = 0;
   END IF;

    UPDATE sd_maesdoscrd
    SET fecha_ult_mov = dtFechaHoy,
        sdo_int_anticip = 0,
        sdo_int_ant_dev = 0,
        sdo_intereses = dSdoInt,
        sdo_dia_ant_int = dSdodiaantint,
        sdo_mes_ant_int = dSdomesantint,
        sdo_acum_mes_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE dSdoInt END),
--        sdo_retenido = 0,
        sdo_acum_cap_int = 0,
        sdo_exig_int = 0,
        sdo_no_exig = dSdoNoExig,
--        provision_normal = (CASE WHEN cIdProc1 = "C" THEN (provision_normal + dSdoInt) ELSE dIntProvFinMes END),
		provision_normal = (CASE WHEN cIdProc1 = "C" THEN (dSdoInt) ELSE dIntProvFinMes END),
        dias_acum_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE (dias_acum_int + iDiasInt) END),
        sdo_dia_ant_mor = (sdo_moratorio + sdo_contab_mora),
        sdo_mes_ant_mor= (CASE WHEN cIdProc3 = "F" THEN sdo_dia_ant_mor ELSE sdo_mes_ant_mor END),
        sdo_moratorio = dSdomoratorio,
        sdo_contab_mora = dSdocontabmora,
        dias_acum_mora = (CASE WHEN (dSdomoratorio + dSdocontabmora) > 0 THEN (dias_acum_mora + iDiasInt) ELSE dias_acum_mora END),
        sdo_dia_ant_cap = sdo_cap_insoluto,
        sdo_mes_ant_cap = 0,
        sdo_acum_mes_cap = 0,
        sdo_capital = dSdoCapital,
        sdo_cap_insoluto = dSdoCapInso,
        --mto_capitalizado = 0,
        mto_ministra_cap = 0,
        dias_acum_cap = (dias_acum_cap + iDiasInt),
        monto_vencido = dMntVencido,
        mto_venc_trasp = dMntVencTras,
        monto_financiado = dMontofinanciado,
--        sdo_global_int = (CASE WHEN cIdProc1 = "C" THEN (sdo_global_int + dProvIva) ELSE dIvaProvFinMes END),
        --sdo_global_int = (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (sdo_global_int + dProvIva) WHEN cIdProc2 = "P" THEN 0  ELSE dIvaProvFinMes END),
        sdo_global_int = (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (sdo_global_int + dProvIva) WHEN cIdProc4 = "P" THEN 0  ELSE dIvaProvFinMes END),
		cap_tras_no_venci = dCapTrasNoVen,
        mto_venc_int = dIvaIntVencido,
        mto_finan_vdo = dIvaIntVigente,
        int_tra_no_exig = dIntVdo,
        sdo_trab4 = dSdotrab4,
        mto_fin_ven_trasp = iNumVdos,
		--IFSR se actualiza el campo mto_fin_ven_trasp para actualizarlo con el nuevo atr
		--atr = (CASE WHEN dFechaVencPlazo < dtFechaHoy THEN iAtrNvo ELSE iNumVdos END)
		atr = iAtrNvo
		--
    WHERE  empresa = cEmpresa
      AND  num_credito = cNumCredito;

-- *******************************************************
-- RESPALDO DE INFORMACION CONTABILIDAD A FIN DE MES     *
-- *******************************************************

     IF cIdProc1 = "C" THEN

           INSERT INTO "informix".sd_maesdoscontcrd
                SELECT dtFechaHoy, *
                  FROM informix.sd_maesdoscrd
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

           INSERT INTO "informix".sd_maecredcontcrd
                SELECT dtFechaHoy, empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,
						cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,
						tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,
						valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,
						credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4--,etapa,status_cred_ant
                  FROM informix.sd_maecredcrd
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

             LET iContCierre = iContCierre + 1;

             IF (iContCierre = 80000) THEN
                LET iContCierre = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maesdoscontcrd;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maecredcontcrd;
             END IF;
     END IF;
-- *******************************************************
-- GENERAR HISTORICO DE SALDOS                           *
-- *******************************************************
    IF cIdProc3 = "M" OR cIdProc2 = "F" THEN
        INSERT INTO "informix".sd_maesdoshistcrd
             SELECT dtFechaHoy, *
               FROM informix.sd_maesdoscrd
              WHERE num_credito = cNumCredito
                AND empresa     = cEmpresa;

            LET iContCorte = iContCorte + 1;

            IF iContCorte = 30000 THEN
                LET iContCorte = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movdiacrd;
            END IF;
    END IF;

-- ***********************************
-- GUARDA SALDOS FIN DE DIA          *
-- ***********************************

      If  cStatusCred in ('E1','E2') THEN 
          select sum(interes_debe - interes_pagado) vencido_balanza,
                 sum(iva_debe - iva_pagado) iva_vencido_balanza
            into vlIntVenBal, vlIvaIntVenBal
            from bdicred:sd_amortiza_creditocrd 
            where empresa = cEmpresa
              and num_credito = cNumCredito 
                  and campo_trabajo3 <> 'V'
              --and capital_status = '2';
              and capital_status in ('1','7','2','6'); -- IFSR se valida para que los intereces de balanza vencido sean en capital status 6 (etapa 3)
     ELIF  cStatusCred = 'E3' THEN
            select sum(interes_debe - interes_pagado) vencido_balanza,
                 sum(iva_debe - iva_pagado) iva_vencido_balanza
            into vlIntVenBal, vlIvaIntVenBal
            from bdicred:sd_amortiza_creditocrd 
            where empresa = cEmpresa
              and num_credito = cNumCredito 
                  and campo_trabajo3 <> 'V'
              --and capital_status = '2';
              and capital_status in ('7','2','6'); -- IFSR se valida para que los intereces de balanza vencido sean en capital status 6 (etapa 3) 
     ELSE
             select sum(interes_debe - interes_pagado) vencido_balanza,
                 sum(iva_debe - iva_pagado) iva_vencido_balanza
            into vlIntVenBal, vlIvaIntVenBal
            from bdicred:sd_amortiza_creditocrd 
            where empresa = cEmpresa
              and num_credito = cNumCredito 
                  and campo_trabajo3 <> 'V'
              and capital_status = '2';
     END IF;  
	 
      if  vlIntVenBal is null then
         let vlIntVenBal = 0;
         let vlIvaIntVenBal = 0;
      end if;
	  
	  LET dSdoNoExig = dSdoNoExig;
	  LET dSdoInt = dSdoInt;
	  LET dIntProvFinMes = dIntProvFinMes;
	  
	  LET dIvaIntVigente = dIvaIntVigente;
	  LET dProvIva = dProvIva;
	  LET dIvaProvFinMes = dIvaProvFinMes;
	  
	  LEt cIdProc1 = cIdProc1;
	  LEt cIdProc2 = cIdProc2;

	  LET dIvaIntReal = dIvaIntReal;	----- Trael calculo de IVA del monto total de int arrastrado (dSdoInt) por el programa de apoyo
	  
/*	  IF wbandera_apoyo = 'A' AND cIdProc1 = "C" AND cIdProc2 = "" THEN
			CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
								(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
									  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
									  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
								(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dIvaIntReal)
									  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
									  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
								dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy)
			 RETURNING cCodRet;
	  ELSE		*/
	  
			/*CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
								(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
									  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
									  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
								(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
									  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
									  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
								dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy)
			 RETURNING cCodRet;*/
			 
			 IF cStatusCred in ('E1','E2') THEN 
			 
				 CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
										(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
											  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
											  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
										(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
											  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
											  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
										dIvaIntVencido,
										(CASE WHEN cIdProc1 = "C" THEN (vlIntVenBal+dSdoInt) ELSE (vlIntVenBal+dIntProvFinMes) END), -- IFSR se agrega validacion para casos de interes vencido de balanza
										
										(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (vlIvaIntVenBal+dProvIva) 
											  WHEN cIdProc2 = "P" THEN (vlIvaIntVenBal)  
											  ELSE (vlIvaIntVenBal+dIvaProvFinMes) END),-- IFSR se agrega validacion para casos de iva interes vencido de balanza
										
										dMontofinanciado,dtFechaHoy,cStatusCredIndica,iAtrNvo)
				RETURNING cCodRet;
			
			ELSE
			
					CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
											(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
												  WHEN cIdProc2 = "F" THEN (dSdoNoExig)
												  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
											(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
												  WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
												  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
											dIvaIntVencido,vlIntVenBal,vlIvaIntVenBal,dMontofinanciado,dtFechaHoy,cStatusCredIndica,iAtrNvo)
				RETURNING cCodRet;
			
			END IF
--	 END IF;

        IF (cCodRet <> "000") THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "Error al grabar en tabla saldos diarios";
             RETURN cCodRet, cMensajeRet;
        END IF;

-- ****************************************
-- FIN DEL PROCESO                        *
-- ****************************************
--          LET iContCommit = iContCommit + 1;

--           IF cBegin = "S" AND iContCommit > 2 THEN
               COMMIT WORK;
               LET cBegin = "N";
--               LET iContCommit = 0;
--           END IF;
            --FMV 25abr13: Calcula indicadores para los prestamos por sus dias de atraso en vencidos
            --FMV 17jun13: Ajuste para prestamos q vencen a fin de mes y cambio de estatus vigente
                    IF (dtFechaHoy = dtFechaFinMes)  THEN
						--IF (cStatusCredIndica = 'AA') THEN
                        IF (cStatusCredIndica = 'AA' OR (cStatusCredIndica = 'E1' AND iAtr = 0)) THEN -- IFSR validacion para contemplar etapa 1 con atr 0
                            LET vdias_atraso = 0;
                        ELSE
                            LET vdias_atraso = (dtFechaFinMes - nvl(dtFechaVencto,dtFechaFinMes) + 1);
                        END IF;

                         UPDATE "informix".sd_indicador_cred_crd
                            SET dias_atraso   = vdias_atraso,
                                fecha_ultimo_pago = vf_fecha_ult_pago,
                                fecha_ultimo_pago_h = vf_fecha_ult_pago
                          WHERE empresa = cEmpresa
                            AND num_credito = cNumCredito;
                    END IF; --IF cIdProc1 = "C"
				
-- *******************************************************
-- 	RQM 09 473: TRIAD	                                 *
-- *******************************************************
	LET vSdoTotLiquidar 	= dSdoCapInso + 
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig)
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido +
							  ((dSdomoratorio+dSdocontabmora) *  ( 1 + dIvaSuc));
							  
	LET vPagoMinimo 	    = dMontofinanciado + 
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig)
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido +
							  ((dSdomoratorio+dSdocontabmora) *  ( 1 + dIvaSuc));
							  
							  
	LET vSdoTotVencido 		=  dMntVencido + dMntVencTras +
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig)
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido +
							  ((dSdomoratorio+dSdocontabmora) *  ( 1 + dIvaSuc));
	 
	-- Actualizacion DIARIA.
	UPDATE "informix".sd_indicador_cred_crd
		SET sdo_tot_liquidar 	= vSdoTotLiquidar,
			pago_minimo 		= vPagoMinimo,
			sdo_tot_vencido 	= vSdoTotVencido,
			saldo_maximo_hist   = CASE WHEN(vSdoTotLiquidar > nvl(saldo_maximo_hist,0)) THEN vSdoTotLiquidar ELSE nvl(saldo_maximo_hist,0) END
	WHERE 	empresa				= cEmpresa
	AND 	num_credito 		= cNumCredito;

	--Actualizacion al CORTE.
	IF cIdProc3 = "M" THEN 
		UPDATE "informix".sd_indicador_cred_crd
		SET num_vencidos_ch 	= CASE WHEN num_vencidos_ch IS NULL OR num_vencidos_ch = '' THEN iNumVdos ELSE num_vencidos_ch END,
			sdo_tot_liquidar_ch = vSdoTotLiquidar,
			pago_minimo_ch  	= vPagoMinimo,
			intereses_periodo_ch = (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
									WHEN cIdProc2 = "F" THEN (dSdoNoExig)
									ELSE (dSdoNoExig + dIntProvFinMes) END),
			sdo_tot_vencido_ch 	= vSdoTotVencido,
			fecha_primera_mora  = CASE WHEN fecha_primera_mora IS NULL OR fecha_primera_mora = '' THEN iFechaVencto ELSE fecha_primera_mora END,
			fecha_ultima_mora	= CASE WHEN iFechaVencto IS NOT NULL THEN iFechaVencto ELSE fecha_ultima_mora END,
			max_mora_hist       = CASE WHEN iNumVdos > nvl(max_mora_hist,0) THEN iNumVdos ELSE nvl(max_mora_hist,0) END
		WHERE empresa			= cEmpresa
		AND num_credito 		= cNumCredito;
	END IF;	

	--Actualizacion a FIN DE MES.
	IF cIdProc1 = "C" THEN
		UPDATE "informix".sd_indicador_cred_crd 
		SET sdo_tot_liquidar_h = vSdoTotLiquidar,
			pago_minimo_h 	   = vPagoMinimo,
			sdo_tot_vencido_h  = vSdoTotVencido
		WHERE empresa = cEmpresa
		AND num_credito = cNumCredito;
    END IF;
	-- RQM 09 473: TRIAD - FIN	


    IF dtFechaHoy=mdy(12,31,2021) THEN

        EXECUTE PROCEDURE "informix".sp_ambientar_indicador_cred_crd(dtFechaHoy,cNumCredito)
            INTO cCodRet, vMensaje;

        IF  cCodRet <> "000" THEN
            RETURN cCodRet,cMensajeRet;			 
        END IF;

    END IF;

END FOREACH;
--    IF iContCommit > 0 THEN --  COMMIT WORK;--    END IF;

    IF iContCierre > 0 THEN
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maesdoscontcrd;
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_maecredcontcrd;
    END IF;

    IF iContCorte > 0 THEN
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movdiacrd;
    END IF;

   LET cCodRet = "000";   LET cMensajeRet = "PROCESO CONCLUIDO";

    UPDATE "informix".sd_contproc
       SET status_proc = "F", hora_fin    = CURRENT,
           cod_ret = cCodRet, 	mensaje  = cMensajeRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierrePrest"
       AND fecha       = dtFechaHoy;

    UPDATE bdinteg:sx_contproc
       SET status_proc = "F", hora_fin = CURRENT,
           codret      = cCodRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierrePrest"
       AND fecha       = dtFechaHoy;

	   IF cBanTemp = 'S' THEN
	       DROP TABLE tmp_sucursales_pp;
	       LET cBanTemp ='N';
	   END IF;
    
 RETURN cCodRet,cMensajeRet;

END;
END PROCEDURE;