CREATE PROCEDURE "informix".sp_rep_canctactetf_web(pEmpresa CHAR(3), pNumCteTf CHAR(20), pNumCtaTf CHAR(20), pSucursal CHAR(4),
							pNombreEjecutivo CHAR(100), pNombreGerente CHAR(100))

	--DATOS A REGRESAR
	RETURNING
	CHAR(5)	  AS  CodRet,
	CHAR(60)  AS  Mensaje,
	DATE 	  AS  Fecha,
	CHAR(44)  AS  Sucursal,
	CHAR(104) AS  NomCte,
	CHAR(20)  AS  NumCteTf,
	CHAR(20)  AS  NumCteBco,
	CHAR(20)  AS  NumCtaCancel,
	CHAR(16)  AS  NumTarjeta,
	CHAR(50)  AS  Identificacion,
	CHAR(20)  AS  NumIdentificacion,
	CHAR(22)  AS  Folio,
	CHAR(20)  AS  MotivoCancel,
	CHAR(100) AS  NombreEjecutivo,
	CHAR(100) AS  NombreGerente;

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cMensaje				CHAR(60);
	DEFINE dFecha				DATE;
	DEFINE cSucursal			CHAR(44);
	DEFINE cNombreCte			CHAR(104);
	DEFINE cNumCteTf			CHAR(20);
	DEFINE cNumCteBco			CHAR(20);
	DEFINE cNumCtaTf			CHAR(20);
	DEFINE cNumTarjeta			CHAR(16);
	DEFINE cIdentificacion		CHAR(50);
	DEFINE cNumIdentificacion	CHAR(20);
	DEFINE cFolio				CHAR(22);
	DEFINE cMotivoCancel		CHAR(20);

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr 			= 0;
	LET cCodRet 			= "00000";
	LET cMensaje			= "PROCESO EJECUTADO EXITOSAMENTE";
	LET dFecha				= DATE(1);
	LET cSucursal			= "";
	LET cNombreCte			= "";
	LET cNumCteTf			= "";
	LET cNumCteBco			= "";
	LET cNumCtaTf			= "";
	LET cNumTarjeta			= "";
	LET cIdentificacion		= "";
	LET cNumIdentificacion	= "";
	LET cFolio				= "";
	LET cMotivoCancel		= "";


	--SET DEBUG FILE TO "/home/sysifx/Pedro/sp_rep_canctactetf_web.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "OCURRIO UN ERROR NO CONTROLADO";
				RETURN cCodRet, cMensaje, dFecha, UPPER(cSucursal), UPPER(cNombreCte), cNumCteTf, cNumCteBco, cNumCtaTf,
					cNumTarjeta, UPPER(cIdentificacion), UPPER(cNumIdentificacion),	cFolio, UPPER(cMotivoCancel), 
					UPPER(pNombreEjecutivo), UPPER(pNombreGerente);
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SE VALIDA SI LO PARAMETROS VIENE VACIOS.
		IF NVL(pEmpresa,"") = "" OR NVL(pNumCteTf,"") = "" OR NVL(pNumCtaTf,"") = "" OR NVL(pSucursal,"") = ""
			OR NVL(pNombreEjecutivo,"") = "" OR NVL(pNombreGerente,"") = "" THEN

			LET cCodRet = "00001";
			LET cMensaje = "ERROR PARAMETROS VACIOS";
			RETURN cCodRet, cMensaje, dFecha, UPPER(cSucursal), UPPER(cNombreCte), cNumCteTf, cNumCteBco, cNumCtaTf,
				cNumTarjeta, UPPER(cIdentificacion), UPPER(cNumIdentificacion),	cFolio, UPPER(cMotivoCancel), 
				UPPER(pNombreEjecutivo), UPPER(pNombreGerente);

		END IF;

		IF(SELECT cuenta_tf FROM "informix".tf_maecte WHERE numcte_tf = pNumCteTf AND cuenta_tf = pNumCtaTf AND status_cta="2") > 0 THEN

			SELECT fecha_hoy
			INTO dFecha
			FROM bdicheq:"informix".sc_fechas;

			SELECT TRIM(sucursal) || " - " ||TRIM(nombre)
			INTO cSucursal
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = pSucursal;

			SELECT TRIM(mae.nombre1) || " " || TRIM(mae.nombre2) || " " || TRIM(mae.apell_paterno) || " " || TRIM(mae.apell_materno),
				mae.numcte_tf, mae.numcte, mae.cuenta_tf,mae.num_tarjeta,mae.identificacion, mae.num_identificacion,can.folio_cancelacion, can.motivo
			INTO cNombreCte,cNumCteTf,cNumCteBco,cNumCtaTf,cNumTarjeta,cIdentificacion,cNumIdentificacion,cFolio,cMotivoCancel
			FROM "informix".tf_maecte mae, "informix".tf_ctacancelada can
			WHERE mae.empresa = can.empresa
				AND mae.empresa = pEmpresa
				AND mae.numcte_tf = pNumCteTf
				AND mae.cuenta_tf = pNumCtaTf
				AND mae.cuenta_tf = can.cuenta_tf
				AND mae.status_cta = "2";
		ELSE

			LET cCodRet = "00002";
			LET cMensaje = "NO SE ENCONTARRON DATOS";

		END IF;

		RETURN cCodRet, cMensaje, dFecha, UPPER(cSucursal), UPPER(cNombreCte), cNumCteTf, cNumCteBco, cNumCtaTf,
			cNumTarjeta, UPPER(cIdentificacion), UPPER(cNumIdentificacion),	cFolio, UPPER(cMotivoCancel), 
			UPPER(pNombreEjecutivo), UPPER(pNombreGerente);

	END
END PROCEDURE
DOCUMENT
"AUTOR: 95689966, Pedro Jimenez Guzman",
"FOLIO: 1440",
"DESCRIPCION: Obtiene los datos para el formato del reporte de cancelacion de cuenta",
"FECHA: 30/06/2014",
"SUSTENTO: Se definio con Manuel Osuna y Grabiela Gudino en el requerimiento",
"RQI 63 050 Procesos Transfer Sucursal v1 4.pdf",
"BD: BDITRANSFER";