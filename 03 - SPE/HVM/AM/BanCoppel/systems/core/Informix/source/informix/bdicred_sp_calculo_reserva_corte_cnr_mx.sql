CREATE PROCEDURE "informix".sp_calculo_reserva_corte_cnr_mx(pEmpresa CHAR(3))
RETURNING CHAR(6)        AS resultado,
          VARCHAR(100,1) AS mensaje;
		  
--  EXECUTE PROCEDURE "informix".sp_calculo_reserva_corte_cnr('001');

         
DEFINE iSqlErr      	     		INTEGER;
DEFINE iIsamErr              		INTEGER;
DEFINE cErrorInfo            		CHAR(80);
DEFINE cCodRet               		CHAR(6); 
DEFINE cMensajeRet           		VARCHAR(100,1);
DEFINE cCodRetorno                  CHAR(06);
DEFINE cMensaje                     CHAR(40);

--DEFINE cBegin                		CHAR(1);
DEFINE dtFechaHoy,dtFechaCorte,dFechaVencim,dtFechaApertura,dtPriDiaMes,dtFecha_Vencto,dtFechaPeriodo,dtFechaPeriodoFact,dtFechaInicioPeriodo DATE;
DEFINE iNumSesion            		INTEGER;
DEFINE cStatus_proc          		CHAR(1);
DEFINE cNumeroCredito        		CHAR(20);
DEFINE cStatusCred           		CHAR(2);
DEFINE cSucursal             		CHAR(4);
DEFINE cNumProducto             	CHAR(4);
DEFINE cPeriodicidad         		CHAR(01);
DEFINE cDivisa               		CHAR(2);
DEFINE dMontoTotalPagar				DECIMAL(18,2);
DEFINE iFrec_Pago,cCapitalStatus,dEvaBuro,cTipoFactura            		CHAR(1);
DEFINE cGradoRiesgo CHAR(2);
DEFINE dEndeudamientoTot,dInteVencIva,dMoratorios,dLimiteCredito,dPagoMinimo,dPI,dIvaVencido,dATR,dConsCompAtrS,dConsCompAtrQ,dConsCompAtrM,dMaxPI,dMontoOtorgado DECIMAL(18,4);
DEFINE dIvaSuc,dIva,dConsNumAtrS,dConsNumAtrQ,dConsNumAtrM  DECIMAL(5,3);
DEFINE iContInsert,iDiasAtraso,iPeriodosPagosFalt,dMontoTotalaPagar,dPR,iPlazoRemanente,iMaxATR,iNumPeriodoS,iNumPeriodoQ,iNumPeriodoM,iNumFact           		INTEGER;
DEFINE dMontoExigible0,dMontoExigible1,dMontoExigible2,dMontoExigible3,dMontoExigible4,dMontoExigible5,dMontoExigible6,dMontoExigible7,dMontoExigible8,dMontoExigible9,dMontoExigible10,dMontoExigible11,dMontoExigible12 DECIMAL(18,4);
DEFINE dTotalPagosRealizados,dTotalMontoExigible,dMontoFinanciado,dIntVig,dIvaVig,dIntVdo,dIvaVdo,dMora,dIvaMora DECIMAL(18,4);
DEFINE dtFechaIniPago,dtFechaFinPago,dtFechaFinPeriodo,dtFechaFinPeriodoAux       		DATE;
DEFINE dPagosRealizados0,dPagosRealizados1,dPagosRealizados2,dPagosRealizados3,dPagosRealizados4,dPagosRealizados5,dPagosRealizados6,dPagosRealizados7,dPagosRealizados8,dPagosRealizados9,dPagosRealizados10,dPagosRealizados11,dPagosRealizados12    DECIMAL(18,4);
DEFINE dRecupCap,dRecupInt,dRecupIvaInt,dPromPorcentajePago,dContPorcentajePago,dporcentajeplazorem,dSdoImp             		DECIMAL(18,4);
DEFINE dPorcentajePago0,dPorcentajePago1,dPorcentajePago2,dPorcentajePago3,dPorcentajePago4,dPorcentajePago5,dPorcentajePago6,dPorcentajePago7,dPorcentajePago8,dPorcentajePago9,dPorcentajePago10,dPorcentajePago11,dPorcentajePago12 DECIMAL(18,4);
DEFINE sIndATR,sDiasAtraso,sPrestamo,sNomina,sAbcd,sOtro,sAuto,sPlazoTotal,sNumCuotasPag,sNvoPeriodo,sDiaCorte,sNumPeriodosPromPorcPago,sNumPeriodo,i SMALLINT;
DEFINE dVeces                		DECIMAL(18,2);
DEFINE cCodigoPrestamo,cDia,cMes,cAnio,cMescAnio       		CHAR(2);
DEFINE dConsPIS,dConsATRS,dConsMAXATRS,dConsPagoS,dConsSDOIMPS,dConsAUTOS,dConsNOMS,dConsPERS,dConsOTRS,dConsPIQ,dConsATRQ,dConsINDATRQ,dConsPAGOQ,dConsPRQ,dConsAUTOQ DECIMAL(18,4);
DEFINE dConsNOMQ,dConsOTRQ,dConsPIM,dConsATRM,dConsVECESM,dConsPAGOM,dConsABCDM,dConsNOMM,dConsPERM,dConsOTRM,dConsMINSPNG,dConsMING,dConsSPS,dConsSPQ,dConsSPM,dConsSPG DECIMAL(18,4);
DEFINE dConsMAXSPNG,dConsMAXSPG,dSP,dEI,dSaldoCapitalInsoluto,dMontoReserva,dPorcentajeReserva,dPorResSic,dGradual,dReservaCalifAnt,dTotalCapitalizado,dSdoCapVig DECIMAL(18,4);
DEFINE cGradoRiesgoEdoResultados    CHAR(2);
DEFINE dtFechaCierreAnt,dFechaFin1,dFechaFin2,dFechaFin3,dFechaMasAntigua DATE;
DEFINE dSdoIntVig,dIntDevengado,dSdoIntVdo,dSdoCierre,dContMontoExig,dContPagos,dImporteReservaBuroCC,dInteresVigente,dInteresDevengado,dInteresVencido,dIntVigSdoDiario,dCuota DECIMAL(18,4);
DEFINE dSdoNoExig,dProvisionNormal,dTotalVencido,dVencidoOrden DECIMAL(18,4);
DEFINE cRutaArchivo                 CHAR(100); 
DEFINE cSql                  		CHAR(1024);
DEFINE dOtrasEstimaciones,dIvaIntVigSdoDiario    		DECIMAL(18,2); 
--DEFINE cCodigoFun                   CHAR(3);
DEFINE dFechaInicio,dFechaInicio1,dFechaInicio2,dFechainicio3,dFechaInicio4,dFechaInicio5,dFechaInicio6,dFechainicio7 DATE;
DEFINE dFechaInicio8,dFechaInicio9,dFechaInicio10,dFechainicio11,dFechaInicio12,dFechaInicio13 DATE;
DEFINE dFechaAlta DATE;
DEFINE cbandera CHAR(01);


--SET DEBUG FILE TO "/tmp/sp_calculo_reserva_corte_cnr.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
--      IF cBegin= 'S' THEN
--		IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'tme_sucursales') THEN
--			DROP TABLE tme_sucursales;
--		END IF;				 
--      END IF;
--IPCB 01/08/13: Se acortan los mensajes para no tener desfaces en la entrega de respuesta a CTRL-M
    --LET cMensajeRet              	= 'Error en la ejecuciÃ³n del proceso CALIFICACION DE CREDITOS NO REVOLVENTES  ' || cNumeroCredito;
      LET cMensajeRet = 'Error en CALIFICACION DE CREDITOS NO REVOLVENTES ' || cNumeroCredito || 'iSqlErr :' || iSqlErr || 'iIsamErr :' || iIsamErr;

      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

LET iSqlErr                  	= 0;
LET iIsamErr                 	= 0;
LET cErrorInfo               	= "";
LET cCodRet                  	= '000000';
--IPCB 01/08/13: Se acortan los mensajes para no tener desfaces en la entrega de respuesta a CTRL-M
--LET cMensajeRet              	= 'El proceso de CALIFICACION DE CREDITOS NO REVOLVENTES se realizÃ³ correctamente';
LET cMensajeRet              	= 'CALIFICACION DE CREDITOS NO REVOLVENTES finaliza Ok';
LET cCodRetorno                 = '';
LET cMensaje                    = '';

--LET cBegin                   	= 'F';
LET dMontoTotalPagar			= 0;
LET dtFechaHoy,dtPriDiaMes,dtFechaApertura,dFechaVencim,dtFechaCorte,dtFecha_Vencto,dtFechaPeriodo,dtFechaPeriodoFact = DATE(1),DATE(1),DATE(1),DATE(1),DATE(1),DATE(1),DATE(1),DATE(1);
LET dtFechaInicioPeriodo,dtFechaIniPago,dtFechaFinPago,dtFechaFinPeriodo,dtFechaFinPeriodoAux = DATE(1),DATE(1),DATE(1),DATE(1),DATE(1);
LET iNumSesion               	= 0;
LET cStatus_proc,cNumeroCredito,cStatusCred,cSucursal,cDivisa,iFrec_Pago,cCapitalStatus           	= '','','','','','','';
LET dEndeudamientoTot,dInteVencIva,dMoratorios,dLimiteCredito,dPagoMinimo,dIvaSuc,dIva,dIvaVencido,iContInsert,iDiasAtraso,dConsNumAtrS,dConsNumAtrQ,dConsNumAtrM = 0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dPI,dATR,dMaxPI,iMaxATR,dConsCompAtrS,dConsCompAtrQ,dConsCompAtrM,iNumFact,iNumPeriodoS,iNumPeriodoQ,iNumPeriodoM,dTotalPagosRealizados,dTotalMontoExigible,dMontoFinanciado = 0,0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dMontoExigible0,dMontoExigible1,dMontoExigible2,dMontoExigible3,dMontoExigible4,dMontoExigible5,dMontoExigible6,dMontoExigible7,dMontoExigible8,dMontoExigible9,dMontoExigible10,dMontoExigible11,dMontoExigible12 = 0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dIntVig,dIvaVig,dIntVdo,dIvaVdo,dMora,dIvaMora,dRecupCap,dRecupInt,dRecupIvaInt,dPromPorcentajePago,dContPorcentajePago,dporcentajeplazorem,iPeriodosPagosFalt,sIndATR = 0,0,0,0,0,0,0,0,0,0,0,0,0,0;
LET cCodigoPrestamo          	= "";
LET dPagosRealizados0,dPagosRealizados1,dPagosRealizados2,dPagosRealizados3,dPagosRealizados4,dPagosRealizados5,dPagosRealizados6,dPagosRealizados7,dPagosRealizados8,dPagosRealizados9,dPagosRealizados10,dPagosRealizados11,dPagosRealizados12 = 0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dPorcentajePago0,dPorcentajePago1,dPorcentajePago2,dPorcentajePago3,dPorcentajePago4,dPorcentajePago5,dPorcentajePago6,dPorcentajePago7,dPorcentajePago8,dPorcentajePago9,dPorcentajePago10,dPorcentajePago11,dPorcentajePago12 = 0,0,0,0,0,0,0,0,0,0,0,0,0;
LET sDiasAtraso,dMontoTotalaPagar,dVeces,sPrestamo,sNomina,sAbcd,sOtro,sAuto,dSdoImp,sPlazoTotal,sNumCuotasPag,dPR,iPlazoRemanente,dConsPIS = 0,0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dConsATRS,dConsMAXATRS,dConsPagoS,dConsSDOIMPS,dConsAUTOS,dConsNOMS,dConsPERS,dConsOTRS,dConsPIQ,dConsATRQ,dConsINDATRQ,dConsPAGOQ,dConsPRQ,dConsAUTOQ = 0,0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dConsNOMQ,dConsOTRQ,dConsPIM,dConsATRM,dConsVECESM,dConsPAGOM,dConsABCDM,dConsNOMM,dConsPERM,dConsOTRM,dConsMINSPNG,dConsMING,dConsSPS,dConsSPQ = 0,0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dConsSPM,dConsSPG,dConsMAXSPNG,dConsMAXSPG,dSP,dEI,dSaldoCapitalInsoluto,dMontoReserva,dPorcentajeReserva,dPorResSic,dGradual,dReservaCalifAnt,dTotalCapitalizado,dSdoCapVig = 0,0,0,0,0,0,0,0,0,0,0,0,0,0;
LET cGradoRiesgo,cGradoRiesgoEdoResultados,dEvaBuro,cRutaArchivo,cDia,cMescAnio,cTipoFactura = '','','','','','','';
--LET cCodigoFun = '';
LET dtFechaCierreAnt         	= DATE(1);
LET dSdoIntVig,dIntDevengado,dSdoIntVdo,dSdoCierre,dContMontoExig,dContPagos,dImporteReservaBuroCC,dOtrasEstimaciones,dIvaIntVigSdoDiario,sNvoPeriodo,dMontoOtorgado,sDiaCorte,dInteresVigente,dInteresDevengado,dInteresVencido,dIntVigSdoDiario = 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
LET dSdoNoExig,dProvisionNormal,dTotalVencido,dVencidoOrden = 0,0,0,0;
LET cSql                    	= "";
LET dCuota = 0;
LET sNumPeriodosPromPorcPago    = 0;
LET dFechaMasAntigua            = DATE(1);
LET sNumPeriodo                 = 0;
LET i                 = 0;
LET dFechaAlta = DATE(1);
LET cbandera = '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- Se obtiene la fecha hoy del sistema.

SELECT today, pri_dia_mes
  INTO dtFechaHoy, dtPriDiaMes
  FROM "informix".sd_fechas
 WHERE empresa = pEmpresa;

let dtFechaHoy = mdy(month(dtFechaHoy),1,year(dtFechaHoy)) - 1 units day; 
let dtPriDiaMes = mdy(month(dtFechaHoy),1,year(dtFechaHoy));

--Temporal
--let dtFechaHoy = mdy('09','30','2017'); 
--let dtPriDiaMes = mdy('09','01','2017');
--Temporal

--Valida si exixte la tabla de sucursales temporal para borrarla
--IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'tme_sucursales') THEN
--	DROP TABLE tme_sucursales;
--END IF;		
 
-- Se obtiene el maestro de sucursales
/*
SELECT empresa, sucursal, iva 
  FROM bdinteg:"informix".si_sucursales d
 WHERE empresa = pEmpresa
   AND sucursal <> ''
  INTO temp tme_sucursales WITH NO LOG;

CREATE INDEX indx_tme_sucursales ON tme_sucursales (sucursal,empresa);
UPDATE STATISTICS MEDIUM FOR TABLE tme_sucursales;
*/

---Obtencion de parametros
SELECT valor INTO dConsNumAtrS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '1' AND empresa = pEmpresa;

IF dConsNumAtrS IS NULL THEN
   LET cCodRet= '000001';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO NÃ?MERO DE ATRASOS SEMANALES';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsNumAtrQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '2' AND empresa = pEmpresa;

IF dConsNumAtrQ IS NULL THEN
   LET cCodRet= '000002';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO NÃ?MERO DE ATRASOS QUINCENAL';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsNumAtrM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '3' AND empresa = pEmpresa;

IF dConsNumAtrM IS NULL THEN
   LET cCodRet= '000003';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO NÃ?MERO DE ATRASOS MENSUAL';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsCompAtrS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '4' AND empresa = pEmpresa;

IF dConsCompAtrS IS NULL THEN
   LET cCodRet= '000004';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE COMPARACIÃ?N NÃ?MERO DE ATRASOS SEMANAL';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsCompAtrQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '5' AND empresa = pEmpresa;

IF dConsCompAtrQ IS NULL THEN
   LET cCodRet= '000005';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE COMPARACIÃ?N NÃ?MERO DE ATRASOS QUINCENAL';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsCompAtrM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '6' AND empresa = pEmpresa;

IF dConsCompAtrM IS NULL THEN
   LET cCodRet= '000006';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE COMPARACIÃ?N NÃ?MERO DE ATRASOS MENSUAL';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dMaxPI FROM "informix".sd_param_reservas_cnr WHERE cod_param= '7' AND empresa = pEmpresa;

IF dMaxPI IS NULL THEN
   LET cCodRet= '000007';
   LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE MÃXIMO DE PROBABILIDAD DE INCUMPLIMIENTO';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO iNumPeriodoS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '8' AND empresa = pEmpresa;

IF iNumPeriodoS IS NULL THEN
   LET cCodRet= '000008';
   LET cMensajeRet= 'FALTA PARAMETRO NÃ?MERO DE PERIODOS FACTURACIÃ?N SEMANALES (%PAGO)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO iNumPeriodoQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '9' AND empresa = pEmpresa;

IF iNumPeriodoQ IS NULL THEN
   LET cCodRet= '000009';
   LET cMensajeRet= 'FALTA PARAMETRO NÃ?MERO DE PERIODOS FACTURACIÃ?N QUINCENAL (%PAGO)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO iNumPeriodoM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '10' AND empresa = pEmpresa;

IF iNumPeriodoM IS NULL THEN
   LET cCodRet= '000010';
   LET cMensajeRet= 'FALTA PARAMETRO NÃ?MERO DE PERIODOS FACTURACIÃ?N MENSUAL (%PAGO)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsPIS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '11' AND empresa = pEmpresa;

IF dConsPIS IS NULL THEN
   LET cCodRet= '000011';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO SEMANAL (PI)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsATRS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '12' AND empresa = pEmpresa;

IF dConsATRS IS NULL THEN
   LET cCodRet= '000012';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO SEMANAL (ATR)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsMAXATRS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '13' AND empresa = pEmpresa;

IF dConsMAXATRS IS NULL THEN
   LET cCodRet= '000013';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO SEMANAL (MAXATR)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsPagoS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '14' AND empresa = pEmpresa;

IF dConsPagoS IS NULL THEN
   LET cCodRet= '000014';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO SEMANAL (%PAGO)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsSDOIMPS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '15' AND empresa = pEmpresa;

IF dConsSDOIMPS IS NULL THEN
   LET cCodRet= '000015';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO SEMANAL (%SDOIMP)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsAUTOS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '16' AND empresa = pEmpresa;

IF dConsAUTOS IS NULL THEN
   LET cCodRet= '000016';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO SEMANAL (AUTO)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsNOMS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '17' AND empresa = pEmpresa;

IF dConsNOMS IS NULL THEN
   LET cCodRet= '000017';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO SEMANAL (NOM)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsPERS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '18' AND empresa = pEmpresa;

IF dConsPERS IS NULL THEN
   LET cCodRet= '000018';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO SEMANAL (PER)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsOTRS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '19' AND empresa = pEmpresa;

IF dConsOTRS IS NULL THEN
   LET cCodRet= '000019';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO SEMANAL (OTR)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsPIQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '20' AND empresa = pEmpresa;

IF dConsPIQ IS NULL THEN
   LET cCodRet= '000020';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO QUINCENAL (PI)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsATRQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '21' AND empresa = pEmpresa;

IF dConsATRQ IS NULL THEN
   LET cCodRet= '000021';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO QUINCENAL (ATR)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsINDATRQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '22' AND empresa = pEmpresa;

IF dConsINDATRQ IS NULL THEN
   LET cCodRet= '000022';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO QUINCENAL (INDATR)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsPAGOQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '23' AND empresa = pEmpresa;

IF dConsPAGOQ IS NULL THEN
   LET cCodRet= '000023';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO QUINCENAL (%PAGO)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsPRQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '24' AND empresa = pEmpresa;

IF dConsPRQ IS NULL THEN
   LET cCodRet= '000024';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO QUINCENAL (%PR)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsAUTOQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '25' AND empresa = pEmpresa;

IF dConsAUTOQ IS NULL THEN
   LET cCodRet= '000025';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO QUINCENAL (AUTO)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsNOMQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '26' AND empresa = pEmpresa;

IF dConsNOMQ IS NULL THEN
   LET cCodRet= '000026';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO QUINCENAL (NOM)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsOTRQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '27' AND empresa = pEmpresa;

IF dConsOTRQ IS NULL THEN
   LET cCodRet= '000027';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO QUINCENAL (OTR)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsPIM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '28' AND empresa = pEmpresa;

IF dConsPIM IS NULL THEN
   LET cCodRet= '000028';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO MENSUAL (PI)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsATRM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '29' AND empresa = pEmpresa;

IF dConsATRM IS NULL THEN
   LET cCodRet= '000029';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO MENSUAL (ATR)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsVECESM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '30' AND empresa = pEmpresa;

IF dConsVECESM IS NULL THEN
   LET cCodRet= '000030';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO MENSUAL (VECES)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsPAGOM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '31' AND empresa = pEmpresa;

IF dConsPAGOM IS NULL THEN
   LET cCodRet= '000031';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO MENSUAL (%PAGO)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsABCDM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '32' AND empresa = pEmpresa;

IF dConsABCDM IS NULL THEN
   LET cCodRet= '000032';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO MENSUAL (ABCD)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsNOMM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '33' AND empresa = pEmpresa;

IF dConsNOMM IS NULL THEN
   LET cCodRet= '000033';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO MENSUAL (NOM)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsPERM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '34' AND empresa = pEmpresa;

IF dConsPERM IS NULL THEN
   LET cCodRet= '000034';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO MENSUAL (PER)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsOTRM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '35' AND empresa = pEmpresa;

IF dConsOTRM IS NULL THEN
   LET cCodRet= '000035';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE CALCULO DE PROBABILIDAD DE INCUMPLIMIENTO MENSUAL (OTR)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsMINSPNG FROM "informix".sd_param_reservas_cnr WHERE cod_param= '36' AND empresa = pEmpresa;

IF dConsMINSPNG IS NULL THEN
   LET cCodRet= '000036';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE MIN SEVERIDAD PÃ?RDIDA PARA CRÃ?DITOS NO GRUPALES';
   RETURN cCodRet, cMensajeRet;
END IF;
/*
SELECT valor INTO dConsMING FROM "informix".sd_param_reservas_cnr WHERE cod_param= '37' AND empresa = pEmpresa;

IF dConsMING IS NULL THEN
   LET cCodRet= '000037';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE MIN SEVERIDAD PÃ?RDIDA PARA CRÃ?DITOS GRUPALES';
   RETURN cCodRet, cMensajeRet;
END IF;
*/
SELECT valor INTO dConsSPS FROM "informix".sd_param_reservas_cnr WHERE cod_param= '38' AND empresa = pEmpresa;

IF dConsSPS IS NULL THEN
   LET cCodRet= '000038';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE COMPARACION SEVERIDAD PÃ?RDIDA SEMANAL';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsSPQ FROM "informix".sd_param_reservas_cnr WHERE cod_param= '39' AND empresa = pEmpresa;

IF dConsSPQ IS NULL THEN
   LET cCodRet= '000039';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE COMPARACION SEVERIDAD PÃ?RDIDA QUINCENAL';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsSPM FROM "informix".sd_param_reservas_cnr WHERE cod_param= '40' AND empresa = pEmpresa;

IF dConsSPM IS NULL THEN
   LET cCodRet= '000040';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE COMPARACION SEVERIDAD PÃ?RDIDA MENSUAL';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsSPG FROM "informix".sd_param_reservas_cnr WHERE cod_param= '41' AND empresa = pEmpresa;

IF dConsSPG IS NULL THEN
   LET cCodRet= '000041';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE COMPARACION SEVERIDAD PÃ?RDIDA CRÃ?DITO GRUPAL';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsMAXSPNG FROM "informix".sd_param_reservas_cnr WHERE cod_param= '42' AND empresa = pEmpresa;

IF dConsMAXSPNG IS NULL THEN
   LET cCodRet= '000042';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE MAX SEVERIDAD PÃ?RDIDA PARA CRÃ?DITOS NO GRUPALES';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dConsMAXSPG FROM "informix".sd_param_reservas_cnr WHERE cod_param= '43' AND empresa = pEmpresa;

IF dConsMAXSPG IS NULL THEN
   LET cCodRet= '000043';
   LET cMensajeRet= 'FALTA PARAMETRO CONSTANTE MAX SEVERIDAD PÃ?RDIDA PARA CRÃ?DITOS GRUPALES';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dPorResSic FROM "informix".sd_param_reservas_cnr WHERE cod_param= '44' AND empresa = pEmpresa;

IF dPorResSic IS NULL THEN
   LET cCodRet= '000044';
   LET cMensajeRet= 'FALTA PORCENTAJE DE RESERVA DE SIC';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO cRutaArchivo FROM "informix".sd_param_reservas_cnr WHERE cod_param= '45' AND empresa = pEmpresa;

IF cRutaArchivo = "" THEN
   LET cCodRet= '000045';
   LET cMensajeRet= 'FALTA PARAMETRO DE RUTA DE ARCHIVOS';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor INTO dIva FROM "informix".sd_param WHERE cod_param= '12' AND empresa = pEmpresa;

IF cRutaArchivo = "" THEN
   LET cCodRet= '000112';
   LET cMensajeRet= 'FALTA PARAMETRO DE IVA';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT DBINFO('sessionid')
  INTO iNumSesion
  FROM "informix".systables
 WHERE tabname = 'systables';

FOREACH WITH HOLD
    SELECT a.num_credito, a.status_cred, a.sucursal, a.num_producto,
           a.periodo_plazo, a.fecha_apertura, a.divisa, b.dia_corte,--MDY(MONTH(dtFechaHoy),LPAD(b.dia_corte,2,0),YEAR(dtFechaHoy)),
           b.tp_dias_fecha_pago, b.fecha_vencto, plazo
      INTO cNumeroCredito, cStatusCred, cSucursal, cNumProducto, 
           cPeriodicidad, dtFechaApertura, cDivisa, sDiaCorte,--dtFechaCorte,
		   iFrec_Pago, dtFecha_Vencto, sPlazoTotal
      FROM bdicred:"informix".sd_maecredcontcrd a, 
           bdicred:"informix".sd_maecredanexocrd b
																									 
																										  
     WHERE a.num_credito    = b.num_credito
       AND a.empresa        = b.empresa 
       AND a.fecha = dtFechaHoy
	   AND a.num_producto IN ('6300','7600','7700','6400')
       AND a.status_cred    IN ("AA","BA","BT","E1","E2","E3")
       AND a.num_credito    NOT IN (SELECT d.num_credito
                                      FROM "informix".sd_hist_reserva_cnr d
                                     WHERE d.num_credito = b.num_credito
                                       AND d.fecha_cierre = dtFechaHoy--MDY(MONTH(dtFechaHoy),LPAD(b.dia_corte,2,0),YEAR(dtFechaHoy))    ----HMBR  meter campo en  tabla  para el corte
        							   AND a.empresa         = d.empresa)
       AND b.empresa        = pEmpresa
--       AND trim(a.campo_trab3)    <> 'BAJA' --No se califican los crÃ©ditos que sufren baja en la cartera 28/02/2014

	   
		SELECT bandera,fecha_alta 
		INTO cBandera,dFechaAlta 
		FROM "informix".sd_programa_apoyo2017crd 
		WHERE num_credito = cNumeroCredito;
	   
	    IF cBandera   IS NULL OR cBandera = ''   THEN LET cBandera = ''; 		END IF;
	    IF dFechaAlta IS NULL OR dFechaAlta = '' THEN LET dFechaAlta = DATE(1); END IF;
	   
		SELECT mto_capitalizado 
		INTO dMontoTotalPagar 
		FROM "informix".sd_maesdoscrd 
		WHERE empresa = pEmpresa and num_credito = cNumeroCredito;
		
		IF dMontoTotalPagar IS NULL THEN
			LET dMontoTotalPagar = 0;
		END IF;

--     IF (iContInsert = 0) THEN
       BEGIN WORK;
--       LET cBegin= 'S';
--     END IF;


    SELECT nvl(iva,0.16) INTO dIva
      FROM bdinteg:"informix".si_sucursales d
     WHERE empresa = pEmpresa
       AND sucursal = cSucursal;

    IF cNumProducto in ('6300','7600','7700') THEN 
        LET cTipoFactura = 'M';
    ELIF cNumProducto = '6400' THEN 
        LET cTipoFactura = 'N';
    ELSE
        LET cMensajeRet = 'El crÃ©dito no tiene nÃºmero de producto  ' || cNumeroCredito;
        LET cCodRet = '900000';
        RETURN cCodRet,cMensajeRet;    
    END IF;

    IF sDiaCorte < day(dtFechaHoy)::smallint THEN
       LET dtFechaCorte = MDY(MONTH(dtFechaHoy),LPAD(sDiaCorte,2,0),YEAR(dtFechaHoy));
    ELSE
       LET dtFechaCorte = dtFechaHoy;
    END IF;
	
    IF cPeriodicidad = 'M' THEN
       EXECUTE PROCEDURE "informix".sp_calculo_fechas_porperiodo(pEmpresa,dtFechaApertura,cPeriodicidad,cTipoFactura,dtFechaHoy)
                    INTO cCodRet,dtFechaInicioPeriodo,dtFechaFinPeriodo,cMensaje;
    ELIF cPeriodicidad = 'Q' THEN
       EXECUTE PROCEDURE "informix".sp_calculo_fechas_porperiodo(pEmpresa,dtFechaApertura,cPeriodicidad,cTipoFactura,dtFechaHoy)
                    INTO cCodRet,dtFechaInicioPeriodo,dtFechaFinPeriodo,cMensaje;
    ELIF cPeriodicidad = 'S' THEN
       EXECUTE PROCEDURE "informix".sp_calculo_fechas_porperiodo(pEmpresa,dtFechaApertura,cPeriodicidad,cTipoFactura,dtFechaHoy)
                    INTO cCodRet,dtFechaInicioPeriodo,dtFechaFinPeriodo,cMensaje;
    END IF;

    select  NVL(a.sdo_cap_insoluto,0),  
                a.mto_venc_int, -- iva_vencido, 
                (sdo_contab_mora + sdo_moratorio) ,  --moratorio
--                nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) *.16,2),0),
                fecha_vencim
          INTO dEndeudamientoTot,
               dInteVencIva,
               dMoratorios,
--               dMontoExigible,
               dFechaVencim
    from bdicred:sd_maesdoshistcrd a,
         bdicred:sd_maecredcontcrd b
    where a.empresa = pEmpresa
    and a.empresa = b.empresa
    and b.fecha = dtFechaHoy
    and a.num_credito = b.num_credito
    and b.num_producto = cNumProducto
    and day(a.fecha) = (select min(day(fecha)) from bdicred:sd_maesdoshistcrd where a.empresa = empresa and a.num_credito = num_credito and month(fecha) = month(a.fecha) and year(fecha) =  year(a.fecha))
    and a.fecha >= dtPriDiaMes
    and a.fecha <= dtFechaHoy
    and a.num_credito = cNumeroCredito;

	SELECT evalua_cc
	  INTO dEvaBuro
	  FROM bdisolic:"informix".ss_resum_scor_fin 
	 WHERE empresa = pempresa 
       AND num_solicitud = cNumeroCredito;

	SELECT codigo
	  INTO cCodigoPrestamo
	  FROM bdicred:"informix".sd_catprestamos
	 WHERE num_producto = cNumProducto;
		 
	IF cCodigoPrestamo = "P" THEN  -- PERSONAL
       LET sPrestamo = 1;	
	ELIF cCodigoPrestamo = "N" THEN -- NOMINA
       LET sNomina = 1;
	ELIF cCodigoPrestamo = "O" THEN -- OTRO
       LET sOtro = 1; 
	ELIF cCodigoPrestamo = "A" THEN -- AUTO
       LET sAuto = 1;
	ELIF cCodigoPrestamo = "B" THEN -- ABCD
       LET sAbcd = 1;
	END IF;

/*
	SELECT NVL(COUNT(num_credito),0)
	  INTO sNumCuotasPag
	  FROM "informix".sd_amortiza_creditocrd 
	 WHERE empresa     = pEmpresa
	   AND num_credito =  cNumeroCredito
	   AND fecha_cuota <= dtFechaHoy
	   AND capital_status <> '3'; --= "5";
*/
-- Periodos de incumplimiento o dÃ­as de atraso (ATR)
	SELECT NVL(sdo_cap_insoluto,0), sdo_capital, monto_otorgado, sdo_no_exig, sdo_intereses, --int_tra_no_exig, 
--           NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0) + NVL(sdo_intereses,0) + NVL(sdo_no_exig,0) + NVL(int_tra_no_exig,0)
           NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0),NVL(sdo_no_exig,0),NVL(provision_normal,0)
      INTO dSaldoCapitalInsoluto, dSdoCapVig, dMontoOtorgado, dInteresVigente, dInteresDevengado, --dInteresVencido, 
           dSdoCierre,dSdoNoExig,dProvisionNormal
      FROM "informix".sd_maesdoscontcrd
     WHERE fecha       = dtFechaHoy
       AND empresa     = pEmpresa
       AND num_credito = cNumeroCredito;         


    if cStatusCred IN ('BT','E2','E3') then
         --balanza
/*                select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) 
                INTO dInteresVencido, dOtrasEstimaciones
                from bdicred:sd_amortiza_creditocrd
                where empresa = pEmpresa
                and num_credito = cNumeroCredito
                and capital_status in ('2','7')
                and fecha_cuota <= (
                                    select max(fecha_mov)
                                    from bdicred:sd_movhiscrd
                                    where empresa = pEmpresa
                                    and num_credito = cNumeroCredito
                                    and codigo_fun = '026'
                                    and codigo_ref = 3
                                    and reversado = 'N');

               let dSdoCierre = dSaldoCapitalInsoluto + dInteresVencido + dInteresDevengado + dInteresVigente;*/

               select nvl(sum(interes_debe - interes_pagado),0) Total_Vencido,
                      nvl(sum(case when campo_trabajo3  = 'V' then interes_debe - interes_pagado else 0 end),0) Vencido_Orden,
                      nvl(sum(case when campo_trabajo3 <> 'V' then interes_debe - interes_pagado else 0 end),0) Vencido_Balanza,
                      nvl(sum(case when campo_trabajo3 <> 'V' then iva_debe - iva_pagado else 0 end),0) Vencido_Balanza_Iva
                 into dTotalVencido,dVencidoOrden,dInteresVencido,dOtrasEstimaciones
                 from bdicred:sd_amortiza_creditocrd 
                where empresa = pEmpresa 
                  and num_credito = cNumeroCredito 
                  and capital_status in ('2','6','7');
-----
/*                if day(dtFechaHoy) = 31 then 
                    select intvig31,ivaintvig31 into dIntVigSdoDiario,dIvaIntVigSdoDiario 
                      from  informix.sd_sdodiariocrd
                     where fecha = dtPriDiaMes and num_credito = cNumeroCredito;
                elif day(dtFechaHoy) = 30 then 
                    select intvig30,ivaintvig30 into dIntVigSdoDiario,dIvaIntVigSdoDiario 
                      from  informix.sd_sdodiariocrd
                     where fecha = dtPriDiaMes and num_credito = cNumeroCredito;
                elif day(dtFechaHoy) = 29 then 
                    select intvig29,ivaintvig29 into dIntVigSdoDiario,dIvaIntVigSdoDiario 
                      from  informix.sd_sdodiariocrd
                     where fecha = dtPriDiaMes and num_credito = cNumeroCredito;
                elif day(dtFechaHoy) = 28 then 
                    select intvig28,ivaintvig28 into dIntVigSdoDiario,dIvaIntVigSdoDiario 
                      from  informix.sd_sdodiariocrd
                     where fecha = dtPriDiaMes and num_credito = cNumeroCredito;
                end if;

               if dVencidoOrden <= 0 then
                  let dInteresVencido = dInteresVencido + dIntVigSdoDiario;
                  let dOtrasEstimaciones = dOtrasEstimaciones + dIvaIntVigSdoDiario;
               end if;*/
-----
               let dSdoCierre = dSdoCierre + dInteresVencido;
    else
               let dSdoCierre = dSdoCierre + dSdoNoExig + dProvisionNormal;
    end if;

-- Programa apoyo
	IF cBandera = 'A' AND dFechaAlta <= dtFechaCorte THEN
	--    SELECT ROUND(nvl(DATE(dtFechaHoy) - MIN(fecha_cuota),0),0)
		SELECT nvl(DATE(dtFechaHoy) - MIN(fecha_cuota),0)
		  INTO dATR
		  FROM "informix".sd_amortiza_creditocrd_apoyo2017 
		 WHERE empresa     = pEmpresa
		   AND num_credito =  cNumeroCredito
		   AND fecha 	   = dtFechaCorte
		   AND capital_status IN("2","7","6")
		   AND fecha_cuota <= dtFechaHoy;
	ELSE
	--    SELECT ROUND(nvl(DATE(dtFechaHoy) - MIN(fecha_cuota),0),0)
		SELECT nvl(DATE(dtFechaHoy) - MIN(fecha_cuota),0)
		  INTO dATR
		  FROM "informix".sd_amortiza_creditocrd 
		 WHERE empresa     = pEmpresa
		   AND num_credito =  cNumeroCredito
		   AND capital_status IN("2","7","6")
		   AND fecha_cuota <= dtFechaHoy;
	END IF;
-- Programa apoyo	   
	   
    LET sDiasAtraso = dATR;
	
-- Programa apoyo	   	
	IF cBandera = 'A' AND dFechaAlta <= dtFechaCorte THEN
		select limit 1 capital_mto_cuota into dPagoMinimo
		from bdicred:sd_amortiza_creditocrd_apoyo2017 
		where empresa=pEmpresa and num_credito=cNumeroCredito AND fecha_cuota = dtFechaCorte;
	ELSE
		select limit 1 capital_mto_cuota into dPagoMinimo
		from bdicred:sd_amortiza_creditocrd 
		where empresa=pEmpresa and num_credito=cNumeroCredito ;
	END IF;
-- Programa apoyo	   

    IF cPeriodicidad = 'M' THEN
        LET iPlazoRemanente = case when date(dFechaVencim) > date(dtFechaHoy) then round((date(dFechaVencim) - date(dtFechaFinPeriodo))/30.4,0) else sPlazoTotal end;
--        LET iPlazoRemanente = case when date(dFechaVencim) > date(dtFechaHoy) then round((date(dFechaVencim) - date(dtFechaHoy))/30.4,0) else sPlazoTotal end;
        LET dPorcentajePlazoRem = iPlazoRemanente / sPlazoTotal;
--rss
--implementar llamado a spl sp_periodos_facturacion_cnr
--para credinomina mensual, los pagos son los dias 15 unicamente por lo que en fecha de apertura se debe de poner siempre 15 y mes y aÃ±o de apertura

		   EXECUTE PROCEDURE "informix".sp_periodos_facturacion_cnr(pEmpresa,cNumeroCredito,cPeriodicidad,cNumProducto,sDiaCorte,dtFechaHoy,dIva)
--          EXECUTE PROCEDURE "informix".sp_periodos_facturacion_cnr(pEmpresa,cNumeroCredito,cPeriodicidad,dtFechaApertura,dtFechaHoy,dtFechaFinPeriodo,dIva) 
                       INTO cCodRet,cMensajeRet,
                            dMontoExigible0,dMontoExigible1,dMontoExigible2,dMontoExigible3,dMontoExigible4,dMontoExigible5,dMontoExigible6,dMontoExigible7,dMontoExigible8,dMontoExigible9,dMontoExigible10,dMontoExigible11,dMontoExigible12,
                            dPagosRealizados0,dPagosRealizados1,dPagosRealizados2,dPagosRealizados3,dPagosRealizados4,dPagosRealizados5,dPagosRealizados6,dPagosRealizados7,dPagosRealizados8,dPagosRealizados9,dPagosRealizados10,dPagosRealizados11,dPagosRealizados12,
                            dPorcentajePago0,dPorcentajePago1,dPorcentajePago2,dPorcentajePago3,dPorcentajePago4,dPorcentajePago5,dPorcentajePago6,dPorcentajePago7,dPorcentajePago8,dPorcentajePago9,dPorcentajePago10,dPorcentajePago11,dPorcentajePago12,dPromPorcentajePago;

       IF dPromPorcentajePago > 10 THEN LET dPromPorcentajePago = 10; END IF;

       IF cCodRet != '000000' THEN 
          LET cMensajeRet = TRIM(cMensajeRet) || '  ' || cNumeroCredito;
          RETURN cCodRet,cMensajeRet;
       END IF;

       IF ((dATR / dConsNumAtrM) - TRUNC(dATR / dConsNumAtrM) >= 0.5) OR ((dATR / dConsNumAtrM) - TRUNC(dATR / dConsNumAtrM) = 0) THEN 
          LET dATR = ROUND(dATR / dConsNumAtrM); 
       ELIF (dATR / dConsNumAtrM) - TRUNC(dATR / dConsNumAtrM) > 0 THEN
          LET dATR = ROUND(dATR / dConsNumAtrM) + 1; 
       END IF;
--       LET dATR = ROUND(dATR / dConsNumAtrM,0);
		LET dVeces = dMontoTotalPagar / dMontoOtorgado;
		--LET dVeces = (dPagoMinimo * sPlazoTotal) / dMontoOtorgado;
	   IF dATR >= dConsCompAtrM THEN 
		  LET dPI = dMaxPI;
       ELSE   
          LET dPI = (1/(1 + EXP(-(dConsPIM + (dConsATRM * dATR) + (dConsVECESM * dVeces) +
                    (dConsPAGOM * dPromPorcentajePago) + (dConsABCDM * sAbcd) + (dConsNOMM * sNomina) + 
                    (dConsPERM * sPrestamo) + (dConsOTRM * sOtro)))));
	   END IF;
       IF dATR >= dConsSPM THEN
		  LET dSP = dConsMAXSPNG;
	   ELSE
		  LET dSP = dConsMINSPNG;
	   END IF;

	ELIF cPeriodicidad = 'Q' THEN
--        LET iPlazoRemanente = case when date(dFechaVencim) > date(dtFechaHoy) then round((date(dFechaVencim) - date(dtFechaFinPeriodo))/30.4,0) else sPlazoTotal end;
        LET iPlazoRemanente = case when date(dFechaVencim) > date(dtFechaHoy) then round((date(dFechaVencim) - date(dtFechaHoy))/15.2,0) else sPlazoTotal end;
        LET dPorcentajePlazoRem = iPlazoRemanente / sPlazoTotal;
		
--calcula 13 periodos de pago
----------------------------rss
--implementar llamado a spl sp_periodos_facturacion_cnr
--para credinomina mensual, los pagos son los dias 15 unicamente por lo que en fecha de apertura se debe de poner siempre 15 y mes y aÃ±o de apertura

			EXECUTE PROCEDURE "informix".sp_periodos_facturacion_cnr(pEmpresa,cNumeroCredito,cPeriodicidad,cNumProducto,sDiaCorte,dtFechaHoy,dIva)
--          EXECUTE PROCEDURE "informix".sp_periodos_facturacion_cnr(pEmpresa,cNumeroCredito,cPeriodicidad,MDY(MONTH(DATE(dtFechaApertura)),15,YEAR(DATE(dtFechaApertura))),dtFechaHoy,dtFechaHoy,dIva) 
                       INTO cCodRet,cMensajeRet,
                            dMontoExigible0,dMontoExigible1,dMontoExigible2,dMontoExigible3,dMontoExigible4,dMontoExigible5,dMontoExigible6,dMontoExigible7,dMontoExigible8,dMontoExigible9,dMontoExigible10,dMontoExigible11,dMontoExigible12,
                            dPagosRealizados0,dPagosRealizados1,dPagosRealizados2,dPagosRealizados3,dPagosRealizados4,dPagosRealizados5,dPagosRealizados6,dPagosRealizados7,dPagosRealizados8,dPagosRealizados9,dPagosRealizados10,dPagosRealizados11,dPagosRealizados12,
                            dPorcentajePago0,dPorcentajePago1,dPorcentajePago2,dPorcentajePago3,dPorcentajePago4,dPorcentajePago5,dPorcentajePago6,dPorcentajePago7,dPorcentajePago8,dPorcentajePago9,dPorcentajePago10,dPorcentajePago11,dPorcentajePago12,dPromPorcentajePago;

       IF dPromPorcentajePago > 10 THEN LET dPromPorcentajePago = 10; END IF;

       IF cCodRet != '000000' THEN 
          LET cMensajeRet = TRIM(cMensajeRet) || '  ' || cNumeroCredito;
          RETURN cCodRet,cMensajeRet;
       END IF;

     -- LET cCodRet                  	= '000000';
     --LET cMensajeRet              	= 'El proceso de CALIFICACION DE CREDITOS NO REVOLVENTES se realizÃ³ correctamente';

       IF ((dATR / dConsNumAtrQ) - TRUNC(dATR / dConsNumAtrQ) >= 0.5) OR ((dATR / dConsNumAtrQ) - TRUNC(dATR / dConsNumAtrQ) = 0) THEN 
          LET dATR = ROUND(dATR / dConsNumAtrQ); 
       ELIF (dATR / dConsNumAtrQ) - TRUNC(dATR / dConsNumAtrQ) > 0 THEN
          LET dATR = ROUND(dATR / dConsNumAtrQ) + 1; 
       END IF;
--       LET dATR = ROUND(dATR / dConsNumAtrQ,0);

/*
       IF iPlazoRemanente <= 0 THEN
          LET dVeces = 1;
       ELSE*/
			LET dVeces = dMontoTotalPagar / dMontoOtorgado;
          --LET dVeces = (dPagoMinimo * sPlazoTotal) / dMontoOtorgado;
--          LET dVeces = iPlazoRemanente / sPlazoTotal;
		--END IF;

-- Programa de apoyo	
	IF cBandera = 'A' AND dFechaAlta <= dtFechaCorte THEN
       SELECT nvl(count(*),0)
         INTO sIndATR
         FROM "informix".sd_amortiza_creditocrd_apoyo2017 
        WHERE empresa     = pEmpresa
          AND num_credito =  cNumeroCredito
		  AND fecha 	   = dtFechaCorte
          AND capital_status IN("2","7","6")
          AND fecha_cuota <= dtFechaHoy;
	ELSE
       SELECT nvl(count(*),0)
         INTO sIndATR
         FROM "informix".sd_amortiza_creditocrd 
        WHERE empresa     = pEmpresa
          AND num_credito =  cNumeroCredito
          AND capital_status IN("2","7","6")
          AND fecha_cuota <= dtFechaHoy;
	END IF;
-- Programa de apoyo	
	
       IF sIndATR > 0 THEN LET sIndATR = 1; END IF;

--	   IF sIndATR >= dConsCompAtrQ THEN 
	   IF dATR >= dConsCompAtrQ THEN 
		  LET dPI = dMaxPI;
       ELSE
          LET dPI = (1/(1 + EXP(-(dConsPIQ + (dConsATRQ * dATR) + (dConsINDATRQ * sIndATR) +
                    (dConsPAGOQ * dPromPorcentajePago) + (dConsPRQ * dPorcentajePlazoRem) + (dConsAUTOQ * sAuto) +
                    (dConsNOMQ * sNomina) + (dConsOTRQ * sOtro)))));			
	   END IF;

	   IF dATR >= dConsSPQ THEN
		  LET dSP = dConsMAXSPNG;
	   ELSE
		  LET dSP = dConsMINSPNG;
	   END IF;		
	ELIF cPeriodicidad = 'S' THEN
/*	
        LET iPlazoRemanente = case when date(dFechaVencim) > date(dtFechaHoy) then round((date(dFechaVencim) - date(dtFechaHoy))/7,0) else sPlazoTotal end;
        LET dPorcentajePlazoRem = iPlazoRemanente / sPlazoTotal;

       IF ((dATR / dConsNumAtrS) - TRUNC(dATR / dConsNumAtrS) >= 0.5) OR ((dATR / dConsNumAtrS) - TRUNC(dATR / dConsNumAtrS) = 0) THEN 
          LET dATR = ROUND(dATR / dConsNumAtrS); 
       ELIF (dATR / dConsNumAtrS) - TRUNC(dATR / dConsNumAtrS) > 0 THEN
          LET dATR = ROUND(dATR / dConsNumAtrS) + 1; 
       END IF;
--       LET dATR = ROUND(dATR / dConsNumAtrS,0);

       LET dVeces = dSdoCierre / dMontoOtorgado;
--Pendiente de calcular Ãºnicamente para periodos semanales iMaxATR
	   IF dATR >= dConsCompAtrS THEN 
		  LET dPI = dMaxPI;
       ELSE
          LET dPI = (1/(1 + EXP(-(dConsPIS + (dConsATRS * dATR) + (dConsMAXATRS * iMaxATR) +
                    (dConsPagoS * dPromPorcentajePago) + (dConsSDOIMPS * dSdoImp) +
                    (dConsAUTOS * sAuto)  + (dConsNOMS * sNomina) + (dConsPERS * sPrestamo) + 
                    (dConsOTRS * sOtro)))));
	   END IF;
	   IF dATR >= dConsSPS THEN
		  LET dSP = dConsMAXSPNG;
	   ELSE
		  LET dSP = dConsMINSPNG;
	   END IF;

       SELECT sum(porcentaje_pago) / COUNT(*), COUNT(*)
         INTO dPromPorcentajePago,sNumPeriodosPromPorcPago
         FROM bdicred:sd_hist_reserva_cnr
        WHERE empresa='001' AND num_credito = cNumeroCredito AND fecha_cierre >= date(dtFechaInicioPeriodo) - 35 UNITS day; 

       IF sNumPeriodosPromPorcPago != 35 THEN
          SELECT count(*),min(mah.fecha),
                 (SELECT sum(nvl(a1.monto_financiado,0) + nvl(a1.sdo_no_exig,0) + nvl(a1.mto_finan_vdo,0) + nvl(a1.int_tra_no_exig,0) + nvl(a1.mto_venc_int,0) + nvl((a1.sdo_contab_mora + a1.sdo_moratorio),0) + nvl(round((a1.sdo_contab_mora + a1.sdo_moratorio) *.16,2),0))
                    FROM bdicred:sd_maesdoshistcrd a1
                   WHERE a1.empresa = pEmpresa
                     AND day(a1.fecha) = (SELECT min(day(fecha)) FROM bdicred:sd_maesdoshistcrd WHERE empresa = a1.empresa AND num_credito = a1.num_credito AND month(fecha) = month(a1.fecha) AND year(fecha) =  year(a1.fecha))
                     AND a1.fecha >= date(dtFechaInicioPeriodo) - 35 UNITS day
                     AND a1.fecha <= dtFechaFinPeriodo
                     AND (SELECT dia_corte FROM bdicred:sd_maecredanexocrd WHERE empresa = a1.empresa AND num_credito = a1.num_credito) <> 1
                     AND a1.num_credito = cNumeroCredito)
            INTO sNumPeriodosPromPorcPago,dFechaMasAntigua,dTotalMontoExigible
            FROM bdicred:sd_maesdoshistcrd mah
           WHERE mah.empresa = pEmpresa
             AND day(mah.fecha) = (SELECT min(day(fecha)) FROM bdicred:sd_maesdoshistcrd WHERE empresa = mah.empresa AND num_credito = mah.num_credito AND month(fecha) = month(mah.fecha) AND year(fecha) =  year(mah.fecha))
             AND mah.fecha >= date(dtFechaInicioPeriodo) - 35 UNITS day
             AND mah.fecha <= dtFechaFinPeriodo
             AND (SELECT dia_corte FROM bdicred:sd_maecredanexocrd WHERE empresa = mah.empresa AND num_credito = mah.num_credito) <> 1
             AND mah.num_credito = cNumeroCredito;

          SELECT nvl(SUM(monto),0)
            INTO dPromPorcentajePago
            FROM bdicred:sd_movhiscrd
           WHERE empresa     = pEmpresa
             AND fecha_mov   >= dFechaMasAntigua
             AND fecha_mov   <= dtFechaFinPeriodo 
             AND num_credito = cNumeroCredito
             AND codigo_fun  IN (SELECT cod_fun 
                                   FROM bdicred:sd_conceptospagomanualcrd where num_producto = cNumProducto)
             AND codigo_ref = 1 -- IN (1,15,16,5,6,7,8,9,10,11,12,13,14)
             AND reversado   = 'N';

          LET dPromPorcentajePago = (dPromPorcentajePago / dTotalMontoExigible) / sNumPeriodosPromPorcPago;

          IF sNumPeriodosPromPorcPago != 35 THEN
             LET dPromPorcentajePago = (dPromPorcentajePago + case when sNumPeriodosPromPorcPago = 1 then 300 else case when sNumPeriodosPromPorcPago = 2 then 200 else 100 end end) / 
                                        case when sNumPeriodosPromPorcPago = 1 then 4 else case when sNumPeriodosPromPorcPago = 2 then 3 else 2 end end;
          END IF;
       END IF;*/
	END IF;	 

-- PORCENTAJE DE RESERVA (%)
    LET dPorcentajeReserva = dPI * dSP;

-- CALIFICACIÃ?N POR GRADO DE RIESGO
	SELECT grado_riesgo
	  INTO cGradoRiesgo
	  FROM "informix".sd_grado_riesgo_cnr
	 WHERE grado_riesgo = grado_riesgo
	   AND tipo = '1'
	   AND empresa = pEmpresa
	   AND (ROUND(dPorcentajeReserva * 100,2) >= porcentaje_min
	   AND ROUND(dPorcentajeReserva * 100,2) <= porcentaje_max);
		   
	LET cGradoRiesgoEdoResultados = cGradoRiesgo;

-- MONTO DE LA RESERVA DE CALIFICACIÃ?N 
	LET dEI = dSdoCierre - dInteresVencido;
--	LET dEI = dSaldoCapitalInsoluto + dInteresVigente + (dInteresVigente * dIva);

	LET dMontoReserva = dPI * dSP * dEI;

--    IF cStatusCred = 'BT' THEN LET dOtrasEstimaciones = dInteresVencido * dIva; END IF;

--Determina GRADO RIESGO Bancoppel
	IF cGradoRiesgoEdoResultados= 'A1' THEN
		LET sNvoPeriodo= 0;
	ELIF cGradoRiesgoEdoResultados= 'A2' THEN
		LET sNvoPeriodo= 1;
	ELIF cGradoRiesgoEdoResultados= 'B1' THEN
		LET sNvoPeriodo= 2;
	ELIF cGradoRiesgoEdoResultados= 'B2' THEN
		LET sNvoPeriodo= 3;
	ELIF cGradoRiesgoEdoResultados= 'B3' THEN
		LET sNvoPeriodo= 4;
	ELIF cGradoRiesgoEdoResultados= 'C1' THEN
		LET sNvoPeriodo= 5;
	ELIF cGradoRiesgoEdoResultados= 'C2' THEN
		LET sNvoPeriodo= 6;
	ELIF cGradoRiesgoEdoResultados= 'D' THEN
		LET sNvoPeriodo= 7;
	ELIF cGradoRiesgoEdoResultados= 'E' THEN
		LET sNvoPeriodo= 8;
	END IF;

-- RESERVA DE CALIFICACIÃ?N ANTERIOR
	SELECT nvl(a.reserva_calificacion,0)
	  INTO dReservaCalifAnt
	  FROM "informix".sd_hist_reserva_cnr a
	 WHERE a.empresa      = pEmpresa
	   AND a.num_credito  = cNumeroCredito
	   AND a.fecha_cierre = dtPriDiaMes - 1; 

    INSERT INTO "informix".sd_hist_reserva_cnr (empresa, num_credito, num_producto, fecha_apertura, status_cred, plazo_total,
					    plazo_remanente, linea_autorizada, pago_minimo, dias_incumplimiento, periodos_incumplimiento,
    					maximo_atraso, indicador_atraso, Antecedente_buro, saldo_insoluto, capital_vigente,
						intereses_vigente, intereses_devengados, intereses_vencidos, saldo_cierre,
						veces, porcentaje_plazo_rem, cred_auto, cred_nomina, cred_per, cred_abcd, cred_otro, 
                        monto_exigible0,monto_exigible1,monto_exigible2,monto_exigible3,monto_exigible4,monto_exigible5,monto_exigible6,
                        monto_exigible7,monto_exigible8,monto_exigible9,monto_exigible10,monto_exigible11,monto_exigible12,
                        pagos_realizados0,pagos_realizados1,pagos_realizados2,pagos_realizados3,pagos_realizados4,pagos_realizados5,pagos_realizados6,
                        pagos_realizados7,pagos_realizados8,pagos_realizados9,pagos_realizados10,pagos_realizados11,pagos_realizados12,
                        porcentaje_pago0,porcentaje_pago1,porcentaje_pago2,porcentaje_pago3,porcentaje_pago4,porcentaje_pago5,porcentaje_pago6,
                        porcentaje_pago7,porcentaje_pago8,porcentaje_pago9,porcentaje_pago10,porcentaje_pago11,porcentaje_pago12,
                        prom_porcen_pago, probabilidad_incumplimiento,
						severidad_perdida, exposicion_incumplimiento, porcentaje_reserva,
						grado_riesgo, reserva_calificacion, reserva_intereses, reserva_buro,
						otras_estimaciones, fecha_fin_mes, periodicidad, reserva_calif_mes_anterior,
						fecha_corte, fecha_cierre)
		VALUES (pEmpresa,cNumeroCredito,cNumProducto,dtFechaApertura,cStatusCred, sPlazoTotal,
				iPlazoRemanente, NVL(dMontoOtorgado,0), NVL(dPagoMinimo,0), sDiasAtraso, dATR,
				iMaxATR, sIndATR, dEvaBuro, NVL(dSaldoCapitalInsoluto,0), dSdoCapVig,
				dInteresVigente, dInteresDevengado, dInteresVencido, dSdoCierre,
				dVeces, dPorcentajePlazoRem * 100, sAuto, sNomina, sPrestamo, sAbcd, sOtro, 
                dMontoExigible0,dMontoExigible1,dMontoExigible2,dMontoExigible3,dMontoExigible4,dMontoExigible5,dMontoExigible6,
                dMontoExigible7,dMontoExigible8,dMontoExigible9,dMontoExigible10,dMontoExigible11,dMontoExigible12,
                dPagosRealizados0,dPagosRealizados1,dPagosRealizados2,dPagosRealizados3,dPagosRealizados4,dPagosRealizados5,dPagosRealizados6,
                dPagosRealizados7,dPagosRealizados8,dPagosRealizados9,dPagosRealizados10,dPagosRealizados11,dPagosRealizados12,
                dPorcentajePago0 * 100,dPorcentajePago1 * 100,dPorcentajePago2 * 100,dPorcentajePago3 * 100,dPorcentajePago4 * 100,dPorcentajePago5 * 100,dPorcentajePago6 * 100,
                dPorcentajePago7 * 100,dPorcentajePago8 * 100,dPorcentajePago9 * 100,dPorcentajePago10 * 100,dPorcentajePago11 * 100,dPorcentajePago12 * 100,
                dPromPorcentajePago * 100, dPI * 100,
				dSP * 100, dEI, dPorcentajeReserva * 100,
				cGradoRiesgo, NVL(dMontoReserva,0), NVL(dInteresVencido,0), NVL(dImporteReservaBuroCC,0),
				dOtrasEstimaciones, dtFechaHoy, cPeriodicidad, NVL(dReservaCalifAnt,0),
				dtFechaCorte, dtFechaHoy);

--Reservas calificaciÃ³n de la cartera 
--    IF cNumProducto = '6300' THEN LET cCodigoFun = '090'; ELIF cNumProducto = '6400' THEN LET cCodigoFun = '110'; END IF;

    IF dSdoCierre > 0 THEN   

       /*select codigo_fun into cCodigoFun 
       from bdicred:sd_producto_codigofun_cnr
       where empresa = pEmpresa and num_producto = cNumProducto and cod_concepto = '01';*/

	   EXECUTE PROCEDURE genmov_calif_cnr(pEmpresa,cNumeroCredito,cNumProducto,sNvoPeriodo,'100',dtFechaHoy,dSdoCierre,"CalifCartCNR",cSucursal,cDivISa,"0000")
	   INTO cCodRet, cMensajeRet;
	   IF TRIM(cCodRet) <> "00000" THEN
		  RETURN cCodRet, cMensajeRet;
	   END IF;
	
    END IF;

--Reservas estimaciÃ³n preventiva 
--    IF cNumProducto = '6300' THEN LET cCodigoFun = '091'; ELIF cNumProducto = '6400' THEN LET cCodigoFun = '111'; END IF;

    IF dMontoReserva > 0 THEN   

       /*select codigo_fun into cCodigoFun 
       from bdicred:sd_producto_codigofun_cnr
       where empresa = pEmpresa and num_producto = cNumProducto and cod_concepto = '02';*/

	   EXECUTE PROCEDURE genmov_calif_cnr(pEmpresa,cNumeroCredito,cNumProducto,sNvoPeriodo,'101',dtFechaHoy,dMontoReserva,"CalifCartCNR",cSucursal,cDivISa,"0000")
	   INTO cCodRet, cMensajeRet;
	   IF TRIM(cCodRet) <> "00000" THEN
		  RETURN cCodRet, cMensajeRet;
	   END IF;
	
    END IF;	
/*
-- Reserva estimacion X irrec o dificil cobro IVA
    IF dOtrasEstimaciones > 0 THEN   

	   EXECUTE PROCEDURE genmov_calif_cnr(pEmpresa,cNumeroCredito,cNumProducto,0,'102',dtFechaHoy,dOtrasEstimaciones,"CalifCartCNR",cSucursal,cDivISa,"0000")
	   INTO cCodRet, cMensajeRet;
	   IF TRIM(cCodRet) <> "00000" THEN
		  RETURN cCodRet, cMensajeRet;
	   END IF;
	
    END IF;
*/
--Reservas BurÃ³ de CrÃ©dito 
--    IF cNumProducto = '6300' THEN LET cCodigoFun = '093'; ELIF cNumProducto = '6400' THEN LET cCodigoFun = '113'; END IF;
    IF dEvaBuro='1' THEN
	   LET dImporteReservaBuroCC = NVL(dMontoReserva,0) * NVL(dPorResSic,0);
       IF dImporteReservaBuroCC > 0 THEN
	   
          UPDATE bdicred:sd_hist_reserva_cnr
             SET reserva_buro = dImporteReservaBuroCC
           WHERE empresa= pEmpresa
             AND num_credito = cNumeroCredito
             AND fecha_cierre=dtFechaHoy;

/*           select codigo_fun into cCodigoFun 
           from bdicred:sd_producto_codigofun_cnr
           where empresa = pEmpresa and num_producto = cNumProducto and cod_concepto = '03';*/

		  EXECUTE PROCEDURE genmov_calif_cnr (pEmpresa,cNumeroCredito,cNumProducto,0,'103',dtFechaHoy,dImporteReservaBuroCC,"CalifCartCNR",cSucursal,cDivISa,"0000")
          INTO cCodRet, cMensajeRet;
		  IF TRIM(cCodRet) <> "00000" THEN
             RETURN cCodRet, cMensajeRet;
		  END IF;
		
	   END IF;
	END IF;

--Reservas intereses vencidos 
--    IF cNumProducto = '6300' THEN LET cCodigoFun = '094'; ELIF cNumProducto = '6400' THEN LET cCodigoFun = '114'; END IF;

    IF cStatusCred IN ('BT','E2','E3') and dInteresVencido > 0 THEN  
       /*select codigo_fun into cCodigoFun 
       from bdicred:sd_producto_codigofun_cnr
       where empresa = pEmpresa and num_producto = cNumProducto and cod_concepto = '04';*/

	   EXECUTE PROCEDURE genmov_calif_cnr(pEmpresa,cNumeroCredito,cNumProducto,0,'104',dtFechaHoy,dInteresVencido,"CalifCartCNR",cSucursal,cDivISa,"0000")
	   INTO cCodRet, cMensajeRet;
	   IF TRIM(cCodRet) <> "00000" THEN
		  RETURN cCodRet, cMensajeRet;
	   END IF;

    END IF;		

--Se inicializan variables del cursor

	--LET cCodigoFun = '';
	LET cNumeroCredito,cStatusCred,cPeriodicidad,cCodigoPrestamo,dEvaBuro,cGradoRiesgo,cGradoRiesgoEdoResultados      = '','','','','','','';
    LET sPlazoTotal,iPlazoRemanente,dMontoOtorgado,dEndeudamientoTot,dLimiteCredito,dPagoMinimo,dImporteReservaBuroCC,dReservaCalifAnt  = 0,0,0,0,0,0,0,0;
	LET dtFechaApertura     = DATE(1);
	LET dContPorcentajePago,iNumFact,sPrestamo,sNomina,sAuto,sAbcd,dTotalPagosRealizados,dTotalMontoExigible,dOtrasEstimaciones,dIvaIntVigSdoDiario = 0,0,0,0,0,0,0,0,0,0; 
    LET dATR,iMaxATR,sIndATR,dPI,dSP,dEI,dSaldoCapitalInsoluto,dSdoCapVig,dInteresVigente,cNumeroCredito = 0,0,0,0,0,0,0,0,0,0;
    LET dInteresDevengado,dInteresVencido,dIntVigSdoDiario,dSdoCierre,dVeces,sOtro,dPromPorcentajePago,dPorcentajeReserva,dMontoReserva = 0,0,0,0,0,0,0,0,0;
    LET dSdoNoExig,dProvisionNormal,dTotalVencido,dVencidoOrden = 0,0,0,0;
    LET dMontoExigible0,dMontoExigible1,dMontoExigible2,dMontoExigible3,dMontoExigible4,dMontoExigible5,dMontoExigible6 = 0,0,0,0,0,0,0;
    LET dMontoExigible7,dMontoExigible8,dMontoExigible9,dMontoExigible10,dMontoExigible11,dMontoExigible12 = 0,0,0,0,0,0;
    LET dPagosRealizados0,dPagosRealizados1,dPagosRealizados2,dPagosRealizados3,dPagosRealizados4,dPagosRealizados5,dPagosRealizados6 = 0,0,0,0,0,0,0;
    LET dPagosRealizados7,dPagosRealizados8,dPagosRealizados9,dPagosRealizados10,dPagosRealizados11,dPagosRealizados12 = 0,0,0,0,0,0;
    LET dPorcentajePago0,dPorcentajePago1,dPorcentajePago2,dPorcentajePago3,dPorcentajePago4,dPorcentajePago5,dPorcentajePago6 = 0,0,0,0,0,0,0;
    LET dPorcentajePago7,dPorcentajePago8,dPorcentajePago9,dPorcentajePago10,dPorcentajePago11,dPorcentajePago12 = 0,0,0,0,0,0;
	LET dMontoTotalPagar = 0;

-----Se metio  para que se incremente el contador ----HMBR	   
--    LET iContInsert = iContInsert + 1;

--    IF (iContInsert >= 7000) THEN
        COMMIT WORK;
--        LET cBegin= 'F';
--        LET iContInsert = 0;
--    END IF;	   
		
END FOREACH;

--IF (iContInsert > 0) THEN
--	COMMIT WORK;
--END IF;

UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_hist_reserva_cnr;

LET cCodRet = '000000';

RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener',
'el calculo de la reserva al corte para',
'CrÃ©ditos No Revolventes',
'AUTOR : Hector Manuel Bojorquez Ruelas',
'FECHA : 25/Octubre/2011',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_calculo_reserva_corte_previo(pEmpresa CHAR(3))

RETURNING
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje;

DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6);
DEFINE cMensajeRet           CHAR(80);

DEFINE cBegin                 CHAR(1);
DEFINE vcontador_insert       INTEGER;
DEFINE sNumeroCredito        CHAR(20);
DEFINE auxNumeroCredito      CHAR(20);
DEFINE dtFechaCalculo        DATE;
DEFINE dtFechaUltMes         DATE;
DEFINE dtFechaCorte          DATE;
DEFINE dtFechaPeriodo        DATE;
DEFINE dfechaini             DATE;
DEFINE dEndeudamientoTot     DECIMAL(18,5);
DEFINE dtFechaApertura       DATE;
DEFINE dPagoRealizado        DECIMAL(18,5);
DEFINE cPeriodicidad         CHAR(1);
DEFINE iACT                  INTEGER;
DEFINE iHIST                 INTEGER;
DEFINE iANT                  DECIMAL(18,5);
DEFINE dQuincenal            DECIMAL(18,5);
DEFINE dSemanal              DECIMAL(18,5);
DEFINE dIncumplimiento       DECIMAL(18,5);
DEFINE cStatusCred           CHAR(2);
DEFINE iBanderaConc          INTEGER;
DEFINE i                     INTEGER;
DEFINE vcuotasvenc           INTEGER;
DEFINE dPorPago              DECIMAL(18,5);
DEFINE dPorUso               DECIMAL(18,5);

DEFINE dPorPagoMin           DECIMAL(18,5);
DEFINE dPorUsoMin            DECIMAL(18,5);
DEFINE dPorSaldoMin          DECIMAL(18,5);
DEFINE dLimiteCredito        DECIMAL(18,5);
DEFINE dImpPerConACT         DECIMAL(18,5);
DEFINE dImpObsHIST           DECIMAL(18,5);
DEFINE dPorResSic            DECIMAL(18,5);

DEFINE dConsComPI            DECIMAL(18,5);
DEFINE dConsPI               DECIMAL(18,5);
DEFINE dConsACT              DECIMAL(18,5);
DEFINE dConsHIST             DECIMAL(18,5);
DEFINE dConsANT              DECIMAL(18,5);
DEFINE dConsPORPAGO          DECIMAL(18,5);
DEFINE dConsPORUSO           DECIMAL(18,5);
DEFINE dPI                   DECIMAL(30,10);
DEFINE dPIdefaul             DECIMAL(18,5);
DEFINE dPorUsoMinCtesNunca   DECIMAL(18,5);

DEFINE dConsSPMenor          DECIMAL(18,5);
DEFINE dConsSPMayor          DECIMAL(18,5);
DEFINE dSP                   DECIMAL(18,5);
DEFINE dEvaBuro              CHAR(01);
DEFINE dLineaAutorizada      DECIMAL(18,5);
DEFINE dConsMinPorPago       DECIMAL(18,5);
DEFINE dConsMaxPorPago       DECIMAL(18,5);
DEFINE dConsMinPorUso        DECIMAL(18,5);
DEFINE dConsMaxPorUso        DECIMAL(18,5);
DEFINE dPagoMinimo           DECIMAL(18,5);
DEFINE dImporteReservaMesAnt DECIMAL(18,5);
DEFINE dFechaMesAnt          DATE;
DEFINE v_iva_suc   			 DECIMAL(18,2);
DEFINE v_sucursal            CHAR(4);
DEFINE dMoratorios           DECIMAL(18,2);
DEFINE dInteVencIva          DECIMAL(18,2);
DEFINE dResCalificacion      DECIMAL(18,5);
DEFINE cGradoRiesgo          CHAR(2);
DEFINE vReservaGradual       DECIMAL(18,5);
DEFINE dGradual              DECIMAL(18,5);
DEFINE vImporteReservaBuroCC DECIMAL(18,5);
DEFINE dIvaVencido           DECIMAL(18,5);
DEFINE vProducto             CHAR(4);
DEFINE vNvoPeriodo           INTEGER;
DEFINE vDivisa               CHAR(2);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
--      LET cMensajeRet = cErrorInfo;
      IF cBegin= 'S' THEN
         ROLLBACK WORK;
      END IF;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/pisa/cas/sp_calculo_reserva_corte.out";
--TRACE ON;

LET iSqlErr=0;
LET iIsamErr=0;
LET cErrorInfo="";
LET cCodRet= '000000';
LET cMensajeRet= 'El proceso de CALIFICACION DEL CORTE se realizó correctamente';
LET cBegin= 'F';
LET vcontador_insert= 0;
LET sNumeroCredito="";
LET auxNumeroCredito="";
LET dtFechaCalculo= DATE(1);
LET dtFechaUltMes= DATE(1);
LET dtFechaCorte=DATE(1);
LET dtFechaPeriodo=DATE(1);
LET dfechaini=DATE(1);
LET dEndeudamientoTot=0;
LET dtFechaApertura= DATE(1);
LET dPagoRealizado=0;
LET cPeriodicidad='';
LET iACT=0;
LET iHIST=0;
LET iANT=0;
LET dQuincenal=0;
LET dSemanal=0;
LET dIncumplimiento=0;
LET cStatusCred='';
LET iBanderaConc=0;
LET i=0;
LET vcuotasvenc=0;
LET dPorPago=0;
LET dPorUso=0;

LET dPorPagoMin=0;
LET dPorUsoMin=0;
LET dPorSaldoMin=0;
LET dLimiteCredito=0;
LET dImpPerConACT=0;
LET dImpObsHIST=0;
LET dPorResSic=0;

LET dConsComPI=0;
LET dConsPI=0;
LET dConsACT=0;
LET dConsHIST=0;
LET dConsANT=0;
LET dConsPORPAGO=0;
LET dConsPORUSO=0;
LET dPI=0;
LET dPIdefaul=0;
LET dPorUsoMinCtesNunca= 0;

LET dConsSPMenor=0;
LET dConsSPMayor=0;
LET dSP=0;
LET dEvaBuro='';
LET dLineaAutorizada=0;
LET dConsMinPorPago=0;
LET dConsMaxPorPago=0;
LET dConsMinPorUso=0;
LET dConsMaxPorUso=0;
LET dPagoMinimo=0;
LET dImporteReservaMesAnt=0;
LET dFechaMesAnt=DATE(1);
LET v_iva_suc=0;
LET dMoratorios=0;
LET dInteVencIva=0;
LET dResCalificacion=0;
LET cGradoRiesgo= '';
LET vReservaGradual = 0;
LET dGradual = 0;
LET vImporteReservaBuroCC = 0;
LET dIvaVencido = 0;
LET vProducto = '';
LET vNvoPeriodo = 0;
LET vDivisa = '';

-- Se obtiene la fecha hoy del sistema.
    SELECT fecha_hoy,ult_dia_mes
      INTO dtFechaCalculo,dtFechaUltMes
      FROM bdicred:sd_fechas
	 WHERE empresa = pEmpresa;

     LET dtFechaCorte = MDY(MONTH(dtFechaCalculo),20,YEAR(dtFechaCalculo));
--Se obtiene el último día del mes anterior para obtener la reserva de la sd_hisvalcon
     LET dFechaMesAnt = MDY(MONTH(dtFechaCorte),1,YEAR(dtFechaCorte)) - 1 units day;

    SELECT valor INTO dQuincenal FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '1';

    IF dQuincenal IS NULL THEN
       LET cCodRet= '000010';
       LET cMensajeRet= 'FALTA PARAMETRO CALCULO DE IMPAGOS QUINCENALES';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dSemanal FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '2';

    IF dSemanal IS NULL THEN
       LET cCodRet= '0000020';
       LET cMensajeRet= 'FALTA PARAMETRO CALCULO DE IMPAGOS SEMANALES';
       RETURN cCodRet,cMensajeRet;
    END IF;

    SELECT valor INTO dConsPI FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '3';

   IF dConsPI IS NULL THEN
      LET cCodRet= '000030';
      LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

   SELECT valor INTO dConsACT FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '4';

   IF dConsACT IS NULL THEN
      LET cCodRet= '000040';
      LET cMensajeRet= 'FALTA CONSTANTE IMPAGO ACTUAL PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

   SELECT valor INTO dConsHIST FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '5';

   IF dConsHIST IS NULL THEN
      LET cCodRet= '000050';
      LET cMensajeRet= 'FALTA CONSTANTE IMPAGO HISTORICO PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

   SELECT valor INTO dConsANT FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '6';

   IF dConsANT IS NULL THEN
      LET cCodRet= '000060';
      LET cMensajeRet= 'FALTA CONSTANTE ANTIGÜEDAD PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

   SELECT valor INTO dConsPORPAGO FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '7';

   IF dConsPORPAGO IS NULL THEN
      LET cCodRet= '000070';
      LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE PAGO PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

   SELECT valor INTO dConsPORUSO FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '8';

   IF dConsPORUSO IS NULL THEN
      LET cCodRet= '000080';
      LET cMensajeRet= 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE USO PI';
      RETURN cCodRet, cMensajeRet;
   END IF;

    SELECT valor INTO dPorPagoMin FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '9';

    IF dPorPagoMin IS NULL THEN
       LET cCodRet= '000090';
       LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE PAGO MINIMO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dPorUsoMin FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '10';

    IF dPorUsoMin IS NULL THEN
       LET cCodRet= '000100';
       LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE USO MINIMO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dPIdefaul FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '13';

    IF dPIdefaul IS NULL THEN
       LET cCodRet= '000130';
       LET cMensajeRet= 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO >=4';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dConsSPMenor FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '14';

    IF dConsSPMenor IS NULL THEN
       LET cCodRet= '000140';
       LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT<12 ';
       RETURN cCodRet, cMensajeRet;
    END IF;

   SELECT valor INTO dConsSPMayor FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '15';

   IF dConsSPMayor IS NULL THEN
      LET cCodRet= '000150';
      LET cMensajeRet= 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT>=12';
      RETURN cCodRet, cMensajeRet;
   END IF;

    SELECT valor INTO dConsComPI FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '16';

     IF dConsComPI IS NULL THEN
        LET cCodRet= '000160';
        LET cMensajeRet= 'FALTA CONSTANTE COMPARACIÓN PARA PI';
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dPorSaldoMin FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '17';

    IF dPorSaldoMin IS NULL THEN
       LET cCodRet= '000170';
       LET cMensajeRet= 'FALTA PARAMETRO PORCENTAJE DE SALDO MINIMO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dImpPerConACT FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '18';

    IF dImpPerConACT IS NULL THEN
       LET cCodRet= '000180';
       LET cMensajeRet= 'FALTA PARAMETRO IMPAGOS EN PERIODOS CONSECUTIVOS ACT';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dImpObsHIST FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '20';

    IF dImpObsHIST IS NULL THEN
       LET cCodRet= '000200';
       LET cMensajeRet= 'FALTA PARAMETRO IMPAGOS OBSERVADOS ULTIMOS MESES HIST';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dConsMinPorPago FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '21';

    IF dConsMinPorPago IS NULL THEN
       LET cCodRet= '000210';
       LET cMensajeRet= 'FALTA VALOR MINIMO COMPARATIVO % DE PAGO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dConsMaxPorPago FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '22';

    IF dConsMaxPorPago IS NULL THEN
       LET cCodRet= '000220';
       LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE PAGO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dConsMinPorUso FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '23';

    IF dConsMinPorUso IS NULL THEN
       LET cCodRet= '000230';
       LET cMensajeRet= 'FALTA MINIMO COMPARATIVO % DE USO';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO dConsMaxPorUso FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '24';

    IF dConsMaxPorUso IS NULL THEN
       LET cCodRet= '000240';
       LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE USO';
       RETURN cCodRet, cMensajeRet;
    END IF;

     SELECT valor INTO dPorUsoMinCtesNunca FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '19';

     IF dPorUsoMinCtesNunca IS NULL THEN
       LET cCodRet= '000019';
       LET cMensajeRet= 'FALTA PORCENTAJE USO MINIMO CLIENTES NUNCA';
       RETURN cCodRet, cMensajeRet;
     END IF;

    SELECT valor INTO dPorResSic FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '25';

    IF dPorResSic IS NULL THEN
       LET cCodRet= '000250';
       LET cMensajeRet= 'FALTA PORCENTAJE DE RESERVA DE SIC';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor INTO cGradoRiesgo FROM bdicred:sd_param_reservas WHERE empresa = pEmpresa AND cod_param= '26';

    IF cGradoRiesgo IS NULL THEN
       LET cCodRet= '000260';
       LET cMensajeRet= 'GRADO RIESGO CLIENTES NUNCA';
       RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT gradual
      INTO dGradual
      FROM bdicred:sd_gradualidad
     WHERE empresa=pEmpresa
       AND mes_ano=lpad(month(dtFechaUltMes),2,0)||year(dtFechaUltMes);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

     EXECUTE PROCEDURE bdicred:monthadd(dtFechaCorte, -1) INTO dtFechaPeriodo;

        SELECT empresa,sucursal,iva
          FROM bdinteg:si_sucursales d
         WHERE empresa = pEmpresa
           AND sucursal<> ''
          INTO temp cr_sucursales3;
        CREATE INDEX crsucursales3 on cr_sucursales3 (empresa, sucursal);
        update statistics medium for table cr_sucursales3;

-- Se obtienen los datos del crédito.
FOREACH WITH HOLD
   SELECT a.num_credito, a.status_cred,a.sucursal,a.num_producto,
          a.periodo_plazo, a.fecha_apertura,a.divisa,
          NVL(b.sdo_cap_insoluto,0),
          NVL(NVL(b.int_tra_no_exig,0) - case when NVL(b.mto_venc_trasp + b.monto_vencido,0) > 0 then NVL(b.sdo_int_anticip,0) else 0 end,0),
		  NVL(b.sdo_moratorio,0) + NVL(b.sdo_contab_mora,0),
          NVL(b.monto_otorgado,0), NVL(b.monto_financiado,0)
     INTO sNumeroCredito, cStatusCred,v_sucursal,vProducto,
          cPeriodicidad, dtFechaApertura, vDivisa,
          dEndeudamientoTot,dInteVencIva,dMoratorios,dLimiteCredito,dPagoMinimo
     FROM bdicred:sd_maecred a
     LEFT OUTER JOIN bdicred:sd_maesdoshist b on (a.empresa = b.empresa AND a.num_credito = b.num_credito AND b.fecha = dtFechaPeriodo)
    WHERE a.empresa          = pEmpresa
      AND a.status_cred      IN ("AA","BA","BT","E1","E2","E3")
      AND a.fecha_apertura   <= dtFechaCalculo
      AND a.num_producto <> '6600'
      AND a.num_credito  not in (SELECT num_credito FROM bdicred:sd_hist_reserva_prueba WHERE a.empresa = empresa AND fecha_corte = dtFechaCorte)


        SELECT iva
          INTO v_iva_suc
          FROM cr_sucursales3
         WHERE empresa = pEmpresa
           AND sucursal= v_sucursal;

         SELECT NVL(campo_trabajo1,0)
           INTO dIvaVencido
           FROM sd_amortiza_credito
          WHERE empresa = pEmpresa
            AND num_credito = sNumeroCredito
            AND fecha_cuota = dtFechaPeriodo;

       IF dIvaVencido IS NULL THEN
          LET dIvaVencido=0;
       END IF;

       LET dMoratorios = Round(dMoratorios * (1 + v_iva_suc),2);
       LET dEndeudamientoTot  = dEndeudamientoTot + dMoratorios + dInteVencIva + dIvaVencido;
       LET dPagoMinimo  = dPagoMinimo + dMoratorios + dInteVencIva + dIvaVencido;

     LET cMensajeRet = sNumeroCredito;

     IF (vcontador_insert = 0) THEN
       LET cBegin= 'S';
       BEGIN WORK;
     END IF;

     LET iACT=0;
     LET iHIST=0;
     LET i=0;
	 LET iBanderaConc=0;

    IF dtFechaApertura > dtFechaCorte THEN
     FOREACH
           SELECT first dImpPerConACT monto_vencido + mto_venc_trasp
             INTO dIncumplimiento
             FROM bdicred:sd_maesdoshist
            WHERE empresa= pEmpresa  
              AND fecha <= dtFechaCorte
              AND num_credito = sNumeroCredito
            ORDER BY fecha DESC
                    
		    IF dIncumplimiento> 0   THEN

               IF iBanderaConc=0 THEN
			      LET iACT= iACT + 1;
               END IF;
--Impagos observados en los últimos meses HIST
               IF i < dImpObsHIST THEN  -- 6
                  LET iHIST = iHIST + 1;
               END IF;
                       
			ELSE
			   LET iBanderaConc= 1;
			END IF;
                    
            LET i= i + 1;
--Impagos en períodos consecutivos ACT
            IF (iBanderaConc = 1 AND i >= dImpObsHIST) THEN  -- 10
               EXIT FOREACH;
            END IF;
                    
     END FOREACH;

         IF cPeriodicidad = "Q" THEN
            LET iACT= iACT * dQuincenal;
            LET iHIST= iHIST * dQuincenal;
         ELIF cPeriodicidad = "S" THEN
            LET iACT= iACT * dSemanal;
            LET iHIST= iHIST * dSemanal;
         END IF;

         IF  dtFechaApertura <= dtFechaCorte THEN
             SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0)
               INTO dPagoRealizado
               FROM bdicred:sd_movhis
              WHERE empresa = pEmpresa
                AND fecha_mov > dtFechaPeriodo
                AND fecha_mov <=dtFechaCorte
                AND num_credito = sNumeroCredito
                AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual)
                AND codigo_ref = 1
                AND reversado = 'N';
         END IF;
    -- Se cambia el calculo de la antigûedad tomando la fecha de fin de mes como base, a solicitud del usuario.
         LET iANT = round((dtFechaUltMes - dtFechaApertura)/30,2);

         SELECT fecha_vencto
           INTO dfechaini
           FROM sd_maecredanexo
          WHERE empresa = pempresa
            AND num_credito = sNumeroCredito;

         IF dfechaini IS NOT NULL THEN
            LET vcuotasvenc = ((Year(dtFechaCorte) - Year(dfechaini)) * 12) + Month(dtFechaCorte) - Month(dfechaini);
            IF vcuotasvenc IS NULL THEN
               LET vcuotasvenc = 0;
            END IF;
            IF vcuotasvenc < 0 THEN
               LET vcuotasvenc = 0;
            END IF;
         ELSE
             LET vcuotasvenc = 0;
         END IF;

    --Se obtiene la reserva del mes anterior
        select nvl(reserva_calificacion,0)
          into dImporteReservaMesAnt
          from sd_hist_reserva
         where empresa = pEmpresa
           and num_credito = sNumeroCredito
           and fecha_cierre = dFechaMesAnt;
    ELSE

        SELECT pagos_realizados,meses_antiguedad,severidad_perdida,impagos_consecutivos,
               impagos_historicos,num_periodos,reserva_calif_mes_anterior
          INTO dPagoRealizado,iANT,dSP,iACT,iHIST,vcuotasvenc,dImporteReservaMesAnt
          FROM bdicred:sd_hist_reserva
         WHERE empresa     = pEmpresa
           AND fecha_corte = dtFechaCorte
           AND num_credito = sNumeroCredito;

           IF dPagoRealizado IS NULL THEN LET dPagoRealizado=0; END IF;
           IF iANT IS NULL THEN LET iANT=0; END IF;
           IF dSP IS NULL THEN LET dSP=0; END IF;
           IF iACT IS NULL THEN LET iACT=0; END IF;
           IF iHIST IS NULL THEN LET iHIST=0; END IF;
           IF vcuotasvenc IS NULL THEN LET vcuotasvenc=0; END IF;
    END IF;

           IF dImporteReservaMesAnt IS NULL THEN LET dImporteReservaMesAnt=0; END IF;

---CALCULA LAS RESERVAS PARA LOS CLIENTES NUNCA Y PARA LOS CLIENTES TOTALEROS(INTRA)
   IF (dEndeudamientoTot<=0 AND dPagoRealizado>=0) THEN
-- Se obtiene el antecedente a Buró
     SELECT evalua_cc
       INTO dEvaBuro
       FROM bdisolic:ss_resum_scor_fin
      WHERE empresa = pempresa
        AND num_solicitud = sNumeroCredito;

-- Se obtiene la línea autorizada
     IF (dtFechaApertura > dtFechaPeriodo) then
         SELECT monto_solicitado
           INTO dLimiteCredito
           FROM bdisolic:ss_solicitudes
          WHERE empresa = pempresa
            AND num_solicitud = sNumeroCredito;

            IF dLimiteCredito is null THEN
               LET dLimiteCredito = 0;
            END IF;
     END IF;

       IF (dEndeudamientoTot<=0 AND dPagoRealizado=0) THEN
          LET dResCalificacion = dPorUsoMinCtesNunca * (CASE WHEN (dLimiteCredito + dEndeudamientoTot) < 0 THEN 0 ELSE (dLimiteCredito + dEndeudamientoTot) END);
          LET vReservaGradual= dResCalificacion * dGradual;
          IF dEvaBuro='1' THEN
             LET vImporteReservaBuroCC = dResCalificacion * dPorResSic * dGradual;
          END IF;
       ELSE
          LET vImporteReservaBuroCC = 0;
          LET dResCalificacion      = 0;
          LET vReservaGradual       = 0;
       END IF;


       INSERT INTO "informix".sd_hist_reserva_prueba
        (empresa, fecha_corte, num_credito, fecha_cierre, grado_riesgo, fecha_apertura, antecedente_buro,
         status_cred, linea_autorizada, limite_credito, interes_cred_ven, saldo_corte, saldo_cierre, pago_minimo,
         pagos_realizados, reserva_int_cred_ven, reserva_buro, reserva_calificacion, porcentaje_reserva,
         meses_antiguedad, probabilidad_incumplimiento, severidad_perdida, exposicion_incumplimiento,
         impagos_consecutivos, impagos_historicos, porcentaje_pago, porcentaje_uso, num_periodos,
         exposicion_inc_gradual, grado_riesgo_gradual, reserva_calificacion_gradual, porcentaje_reserva_gradual,
         reserva_buro_gradual, reserva_int_cred_ven_gradual, reserva_calif_mes_anterior, grado_riesgo_bancoppel,
         grado_riesgo_edo_resultados, reserva_edo_resultados, porcentaje_reserva_edo_resultados)
       VALUES
        (pEmpresa, dtFechaCorte, sNumeroCredito, NULL,cGradoRiesgo, dtFechaApertura, dEvaBuro,cStatusCred,
         dLineaAutorizada,dLimiteCredito,0,dEndeudamientoTot,0, dPagoMinimo, dPagoRealizado,0,vImporteReservaBuroCC,
        dResCalificacion,(CASE WHEN dPagoRealizado>0 THEN 0 ELSE dPorUsoMinCtesNunca END)*100, iANT,0,
        (case when iACT< dImpPerConACT then dConsSPMenor else dConsSPMayor end)*100,0,iACT,iHIST,0,0,vcuotasvenc,0,
        cGradoRiesgo,vReservaGradual,0,vImporteReservaBuroCC,0,dImporteReservaMesAnt, 'IN',cGradoRiesgo,vReservaGradual,0);

         LET vNvoPeriodo= 1;

/*------------------------------------------------------------------------------------
        IF vReservaGradual>0 THEN
        -- Genera Movimiento para Contabilidad
            EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                            sNumeroCredito,
                                            vProducto,
                                            vNvoPeriodo,
                                            "070", --665
                                            dtFechaUltMes,
                                            vReservaGradual,
                                            "CalifCartReserva",
                                             v_sucursal,
                                             vDivisa,
                                             "0000")
            INTO cCodRet, cMensajeRet;
            IF TRIM(cCodRet) <> "00000" THEN
               RETURN cCodRet, cMensajeRet;
            END IF;
        END IF;
        IF vReservaGradual > 0 AND (dLimiteCredito + dEndeudamientoTot) > 0 THEN
            EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                            sNumeroCredito,
                                            vProducto,
                                            vNvoPeriodo,
                                            "071", --666
                                            dtFechaUltMes,
                                            (dLimiteCredito + dEndeudamientoTot),
                                            "CalifCart",
                                             v_sucursal,
                                             vDivisa,
                                             "0000")
            INTO cCodRet, cMensajeRet;
            IF TRIM(cCodRet) <> "00000" THEN
               RETURN cCodRet, cMensajeRet;
            END IF;
        END IF;

        IF vImporteReservaBuroCC > 0 THEN
            --Califica malos antecedentes
              EXECUTE PROCEDURE genmov_calif (pEmpresa,
                                              sNumeroCredito,
                                              vProducto,
                                              51,
                                              "661",
                                              dtFechaUltMes,
                                              vImporteReservaBuroCC,
                                              "CalifCart",
                                              v_sucursal,
                                              vDivisa,
                                              "0000")
             INTO cCodRet, cMensajeRet;
             IF TRIM(cCodRet) <> "00000" THEN
               RETURN cCodRet, cMensajeRet;
             END IF;
        END IF;*/
------------------------------------------------------------------------------------
       LET auxNumeroCredito="";
       LET vcontador_insert = vcontador_insert + 1;
       CONTINUE FOREACH;
   END IF;
-- Se calcula % de Uso
--     IF dLimiteCredito = 0 or dEndeudamientoTot = 0 THEN
     IF dLimiteCredito < 1.01 THEN
        LET dPorUso  = 1;
     ELSE
        LET dPorUso  = dEndeudamientoTot / dLimiteCredito;
     END IF;

-- Se calcula % de Pago
    IF dEndeudamientoTot > 0 THEN
       LET dPorPago = dPagoRealizado / dEndeudamientoTot;
    END IF;
-- Valida valor máximo para %PAGO
     IF dPorPago  > dConsMaxPorPago THEN LET dPorPago  = dConsMaxPorPago; END IF

-- Se calcula SP (Severidad de la Pérdida)
     IF iACT < dImpPerConACT THEN
        LET dSP = dConsSPMenor;
     ELSE
        LET dSP = dConsSPMayor;
     END IF;

--Se calcula PI (Probabilidad de Incumplimiento)
     IF iACT >= dConsComPI THEN -- Valor 4
        LET dPI = dPIdefaul; --Valor 1
     ELSE
         LET dPI = (1/(1 + EXP(-(dConsPI + (dConsACT * iACT) + (dConsHIST * iHIST) + (dConsANT * iANT) + (dConsPORPAGO * dPorPago) + (dConsPORUSO * dPorUso)))));
     END IF;

-- Se obtiene el antecedente a Buró
     SELECT evalua_cc
       INTO dEvaBuro
       FROM bdisolic:ss_resum_scor_fin
      WHERE empresa = pempresa
        AND num_solicitud = sNumeroCredito;

-- Se obtiene la línea autorizada
 /*    SELECT monto_solicitado
       INTO dLineaAutorizada
       FROM bdisolic:ss_solicitudes
      WHERE empresa = pempresa
        AND num_solicitud = sNumeroCredito;
*/
                   -- Se almacena la información correspondiente al calculo de la reservas preventivas.
     INSERT INTO "informix".sd_hist_reserva_prueba
/*
(empresa,fecha_corte,num_credito,fecha_cierre,grado_riesgo,fecha_apertura,antecedente_buro,status_cred,linea_autorizada,
limite_credito,interes_cred_ven,saldo_corte,saldo_cierre,pago_minimo,pagos_realizados,reserva_int_cred_ven,reserva_buro,
reserva_calificacion,porcentaje_reserva,meses_antiguedad,probabilidad_incumplimiento,severidad_perdida,exposicion_incumplimiento,
impagos_consecutivos,impagos_historicos,porcentaje_pago,porcentaje_uso,num_periodos,exposicion_inc_gradual,grado_riesgo_gradual,
reserva_calificacion_gradual,porcentaje_reserva_gradual,reserva_buro_gradual,reserva_int_cred_ven_gradual,reserva_calif_mes_anterior,
grado_riesgo_bancoppel)
*/
          VALUES (pEmpresa,
                  dtFechaCorte,
                  sNumeroCredito,
                  null,
                  null,
                  dtFechaApertura,
                  dEvaBuro,
                  cStatusCred,
                  dLineaAutorizada,
                  dLimiteCredito,
                  null,
                  dEndeudamientoTot,
                  null,
                  dPagoMinimo,
                  dPagoRealizado,
                  null,
                  null,
                  null,
                  null,
                  iANT,
                  dPI * 100,
                  dSP * 100,
                  null,
                  iACT,
                  iHIST,
                  dPorPago * 100,
                  dPorUso * 100,
                  vcuotasvenc,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  dImporteReservaMesAnt,
                  null,
                  null,
                  null,
                  null
);

--Se inicializan variables del cursor
   LET sNumeroCredito =0;
   LET cStatusCred =0;
   LET cPeriodicidad =0;
   LET dtFechaApertura =0;
   LET dEndeudamientoTot =0;
   LET dLimiteCredito =0;
   LET dPagoMinimo =0;

   LET auxNumeroCredito="";

   LET vcontador_insert = vcontador_insert + 1;

   IF (vcontador_insert >= 7000) THEN
      COMMIT WORK;
      LET vcontador_insert = 0;
--      UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_hist_reserva;
   END IF;

END FOREACH;

IF (vcontador_insert > 0) THEN
   COMMIT WORK;
END IF;

UPDATE statistics medium FOR TABLE sd_hist_reserva_prueba;

  DROP TABLE cr_sucursales3;
  LET cMensajeRet= 'El proceso de CALIFICACION DEL CORTE se realizó correctamente';

  RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'el calculo de la reserva',
'AUTOR : Roque Enrique Solis',
'FECHA : 05/MARZO/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_camp_primer_uso_cierra9a10repcanc(pempresa CHAR(3), pServicio CHAR(2), pMessinact SMALLINT, pdFechaHoy DATE)

RETURNING CHAR(6);

--Creado: MAHR. Diciembre 2012 
-- Servicio 10-> Campaña;10 Cierre de cifras de campaña 9, y creacion de reporte de cuentas canceladas "automaticamente".


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vproceso				CHAR(4);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnombreTelef			CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivo_tel1     CHAR(100);
DEFINE cnomarchivo_tel      CHAR(100);
DEFINE cnomarchivoejecsql   CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(3000);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE cCod_Promocion       CHAR(3);
DEFINE dfecha_gen_camp      DATE;
DEFINE dfecha_ejec_camp     DATE;
DEFINE dfecha_ent_desde     DATE;
DEFINE dfecha_ent_hasta     DATE;
DEFINE sParamNombArch       SMALLINT;
DEFINE sParamNombArchTelef  SMALLINT;
DEFINE sParamRutaArch       SMALLINT;
DEFINE sNum_logica          SMALLINT;
DEFINE sNumCampania         SMALLINT;
DEFINE itot_tarj_inact      INTEGER;


--SET DEBUG FILE TO "sp_camp_primer_uso_cierra9a10repcanc.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0601';
LET cruta                   = "";
LET cnombre					= "";
LET cnombreTelef            = "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivo_tel1        = "";
LET cnomarchivo_tel         = "";
LET cnomarchivoejecsql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "";
LET cdelimitador            = "";
LET cCod_RetIB              = '000000';
LET sParamNombArch          = 0;
LET sParamNombArchTelef     = 0;
LET sParamRutaArch          = 0;
LET sNumCampania            = 0;
LET cCod_Promocion          = "";
LET sNum_logica             = 0;
LET itot_tarj_inact         = 0;


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, trim(cMensaje) || 'PROCESO' || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'PROCESO INICIALIZADO ' || pServicio , '02') Returning cCod_RetIB;

	-- Validacion de parámetros de entrada
	IF (NVL(pEmpresa,"") = "" OR NVL(pServicio, "") = "" OR pMessinact = 0 ) THEN
        LET cCod_Ret= '104001'; 
        SELECT descripcion INTO cMensaje
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa INTO cempresa FROM bdinteg:si_empresas WHERE empresa = pempresa;
	IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret = '104002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;
  
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicobranza:"informix".cb_param_campania WHERE empresa = pempresa
        AND tipo_campania = 1 AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 26;
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

    -- Asigna parametros con nombres de archivos y ruta, dependiendo del servicio (subcampaña).
    LET sParamRutaArch = 1;
    LET sParamNombArch = 43;
    LET sParamNombArchTelef = 44;
    LET sNumCampania = pServicio::SMALLINT; -- Asigna el numero de campaña en base al servicio


    -- Obtiene las fechas: Fecha de campaña, fecha entregada desde, fecha entregadas hasta de la campaña correspondiente para la campaña 2
        -- se realiza el calculo de manera distinta.
    LET dfecha_ejec_camp = pdFechaHoy - pMessinact units month; -- Se obtiene la fecha de campaña de la campaña anterior ejecutada en el mes calculado
    SELECT first 1 fecha_gen_campania, fecha_entreg_desde, fecha_entreg_hasta INTO dfecha_gen_camp, dfecha_ent_desde, dfecha_ent_hasta
        FROM bdicred:"informix".sd_camp_primer_uso WHERE month(fecha_ejecucion) = month(dfecha_ejec_camp)
        AND year(fecha_ejecucion) = year(dfecha_ejec_camp) AND num_campania = (sNumCampania - 1);
    IF dfecha_gen_camp IS NULL THEN     --  Termina proceso, ya que no existe campaña generada para esta fecha.
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'SIN CAMPAÑA ' || pServicio, '02') Returning cCod_RetIB;
        LET cCod_Ret = '000001';
        RETURN cCod_Ret;
    END IF;

    -- Obtiene la ruta del archivo
	SELECT TRIM(valor_alfabetico) INTO cruta FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamRutaArch; 
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret = '104005';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	-- Obtiene el nombre del archivo a generar con datos del cliente.
	SELECT TRIM(valor_alfabetico) INTO cnombre FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamNombArch; 
	IF NVL (cnombre,'') = '' THEN
        LET cCod_Ret= '102002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	-- Obtiene el nombre del archivo de telefonos a generar.
	SELECT TRIM(valor_alfabetico) INTO cnombreTelef FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
       AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = sParamNombArchTelef; 
	IF NVL (cnombreTelef,'') = '' THEN
        LET cCod_Ret= '102002';
        SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje || pServicio, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;


    -- Obtiene el codigo de la promocion y numero de logica de la misma.
    SELECT TRIM(valor_alfabetico) INTO cCod_Promocion FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'TIPO_PROM' AND num_parametro = 8;
    SELECT num_parametro INTO sNum_logica FROM sd_param_campania WHERE grupo_parametro = 'TIPOLOGICA' AND num_parametro = 8;


    -- Finaliza cifras de campaña 9 para medir efectividad.
    SELECT COUNT(a.num_credito) INTO itot_tarj_inact    --  Obtiene el total de tarjetas inactivas al momento 
        FROM bdicred:sd_camp_primer_uso a JOIN bdicred:sd_indicador_cred ind on ( a.empresa = ind.empresa and a.num_credito = ind.num_credito) 
																							   
																																															  
        JOIN bdicred:sd_maecred cred ON ( a.empresa = cred.empresa and a.num_credito = cred.num_credito and cred.status_cred IN ('AA','E1')) 
        WHERE a.empresa = pempresa
        AND a.fecha_gen_campania = dfecha_gen_camp AND a.fecha_entreg_desde = dfecha_ent_desde AND a.fecha_entreg_hasta = dfecha_ent_hasta
        AND a.num_campania = (sNumCampania - 1) 
        AND a.status_tarj = 'INACT'
        AND ( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) )
        AND ( ind.f_primer_disp IS NULL OR ind.f_primer_disp = date(1) );


    -- Se actualizan datos de la campaña anterior. Las inactivas restantes de la campaña anterior = Las entregadas de esta campaña
    UPDATE bdicred:cb_1eruso_rep_seguim SET tot_tarj_inactivas = itot_tarj_inact, tot_tarj_activas = (tot_tarj_entregadas - itot_tarj_inact),
                porcentaje_efec = (((tot_tarj_entregadas - itot_tarj_inact) / tot_tarj_entregadas) * 100)::INTEGER
        WHERE fecha_gen_campania = dfecha_gen_camp AND fecha_entreg_desde = dfecha_ent_desde AND fecha_entreg_hasta = dfecha_ent_hasta 
		  AND sub_campania = (sNumCampania - 1); 


    -- Genera el ARCHIVO con los datos de los clientes a partir de los almacenado. Asigna nombre de archivo, segun parametro y la fecha correspondiente
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||substr(year(pdFechaHoy),3)||to_char(pdFechaHoy,'%m%d')||'.txt';
    LET cnomarchivo  =  trim(cnombre)||substr(year(pdFechaHoy),3)||to_char( pdFechaHoy,'%m%d')||'.txt';
    LET cnomarchivoejecsql = 'Ejecuta_gen_arch_Camp_primer_uso.sql';
    LET cSql='';
    LET cSql = 'echo "tipo_promocion'||';'||'tipo_logica'||';'||'fecha_insercion'||';'||'num_credito'||';'||'sucursal'||';'||'num_cliente'||';'
            ||'no_tarjeta'||';'|| 'status_prom'||';'||'prioridad'||';'||'ap_paterno'||';'||'ap_materno' ||';'|| 'primer_nombre' ||';'
            ||'segundo_nombre'||';'|| 'sexo' ||';'|| 'estado_civil' ||';'|| 'email' ||';'|| 'estado' ||';'|| 'municipio/delegacion' ||';'
            || ' " >' ||TRIM(cruta)|| cnomarchivo;
    SYSTEM csql;


    -- Genera el ARCHIVO con los telefonos de los clientes. Asigna nombre de archivo, segun parametro y la fecha correspondiente
    LET cnomarchivo_tel1 =  trim(cnombreTelef)|| 'Aux'|| substr(year(pdFechaHoy),3) || to_char(pdFechaHoy,'%m%d') || '.txt';
    LET cnomarchivo_tel  =  trim(cnombreTelef)|| substr(year(pdFechaHoy),3) || to_char(pdFechaHoy,'%m%d') || '.txt';
    LET cSql='';
    LET cSql = 'echo "Num_Credito'||';'||'num_cliente'||';'||'tipo_telefono'||';'||'tipo_red'||';'||'telefono_original'||';'
            ||'telefono_reconstruido'||';'  ||'carrier'||';'|| 'extension' ||';' || ' " >' ||TRIM(cruta)|| cnomarchivo_tel;
    SYSTEM csql;

	
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; ';
                                                            -- Se obtienen los registros de los clientes y sus telefonos 
    LET cSQL2 = " SELECT '" || pempresa || "' as empresa, '" || cCod_Promocion || "' as Cod_prom, '" || sNum_logica::CHAR || "' as logica, " 
            || " a.fecha_gen_campania, a.num_credito, a.sucursal, a.numcte, a.num_tarjeta, a.statusprom, a.prioridad, a.ap_paterno, a.ap_materno, "
            || " a.primer_nombre, a.segundo_nombre, a.sexo, a.estado_civil, a.email, a.estado, a.ciudad, a.fecha_apertura, '0' as stat "
            || " FROM bdicred:sd_camp_primer_uso a JOIN bdicred:sd_indicador_cred ind on ( a.empresa = ind.empresa and a.num_credito = ind.num_credito) "
																										
            || " JOIN bdicred:sd_maecred cred ON ( a.empresa = cred.empresa and a.num_credito = cred.num_credito and cred.status_cred IN ('AA','E1')) " 
            || " WHERE a.empresa = '" || pempresa || "'"
            || " AND a.fecha_gen_campania = '" || dfecha_gen_camp ||"' AND a.fecha_entreg_desde  = '"||dfecha_ent_desde
            || "' AND a.fecha_entreg_hasta = '" || dfecha_ent_hasta ||"'"
            || " AND a.num_campania = " || (sNumCampania - 1) 
            || " AND a.status_tarj = 'INACT' "
            || " AND ( ind.f_primer_compra IS NULL OR ind.f_primer_compra = date(1) ) "
            || " AND ( ind.f_primer_disp IS NULL OR ind.f_primer_disp = date(1) ) "
            || " INTO temp temp_clientes_1eruso with no log; "
            || " CREATE INDEX ix_ctes_1eruso on temp_clientes_1eruso (empresa, numcte); "
            || " UPDATE STATISTICS medium FOR TABLE temp_clientes_1eruso;       "       -- Marca los clientes que no tienen telefono..
            || " SELECT prim.num_credito as num_credito, prim.numcte as numcte, tel.tipo_tel::CHAR as tipo_tel, "
            || " decode(tel.tipo_tel,1,'F',3,'F','M') as tipo_red, substr(tel.telefono,length(tel.telefono)-9,10) as telefono_original, "
            || " substr(tel.telefono,length(tel.telefono)-9,10) as telefono_Reconstruido, NVL(tel.carrier,'') as carrier, NVL(tel.extension, '') as extension "
            || " FROM temp_clientes_1eruso prim JOIN bdinteg:si_telefonos_actual tel ON (prim.empresa = tel.empresa AND prim.numcte = tel.numcte ) "
            || " WHERE tel.status_tel = 'A' AND tel.cofetel = 'V' AND trim(tel.telefono) <> '' "
            || " INTO temp temp_telefonos with no log;      " 
            || " UPDATE temp_clientes_1eruso SET stat = '1' WHERE numcte NOT IN (Select numcte from temp_telefonos group by numcte );       "
            || " UNLOAD TO " || TRIM(cruta) || TRIM(cnomarchivo1) || " DELIMITER '" || cdelimitador || "' "
            || " SELECT Cod_prom, logica, fecha_gen_campania, num_credito, sucursal, numcte, num_tarjeta, "
            || " statusprom, prioridad, ap_paterno, ap_materno, primer_nombre, segundo_nombre, sexo, estado_civil, email, estado, ciudad "
            || " FROM temp_clientes_1eruso "
            || " WHERE stat = '0' "
            || " ORDER BY prioridad, fecha_apertura ASC; "
            || " UNLOAD TO " || TRIM(cruta) || TRIM(cnomarchivo_tel1) || " DELIMITER '" || cdelimitador || "' "
            || " SELECT * from temp_telefonos ORDER BY num_credito; ";


    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
    SYSTEM cSQL;

    LET cSql = "";
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    LET cSql = "";
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo_tel1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo_tel);
    SYSTEM cSql;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || '  ' || TRIM(cruta) || cnomarchivo1 || '  ' || TRIM(cRuta) || TRIM(cnomarchivo_tel1);
    SYSTEM cSQL;

    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, 'PROCESO INICIALIZADO ' || pServicio, '02') Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;