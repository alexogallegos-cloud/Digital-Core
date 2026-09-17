CREATE PROCEDURE "informix".sp_calculo_reserva_corte_crd (pEmpresa CHAR(3))
RETURNING CHAR(6)        AS resultado,
          VARCHAR(100,1) AS mensaje;
		  
--EXECUTE PROCEDURE "informix".sp_calculo_reserva_corte_crd ("001"); 

---------------------------------Declaracion de variables
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           VARCHAR(100,1);

DEFINE cBegin                CHAR(1);
DEFINE dtFechaCalculo        DATE;
DEFINE dtFechaUltMes         DATE;
DEFINE dtFechaPriMes         DATE;
DEFINE dtFechaMesAnt          DATE;
DEFINE dtFechaCorte          DATE;
DEFINE cNumCredito           CHAR(20);
DEFINE cNumeroCreditoTC      CHAR(20);

DEFINE dMensual              DECIMAL(18,5);
DEFINE dQuincenal            DECIMAL(18,5);
DEFINE dSemanal              DECIMAL(18,5);
DEFINE dConsPI               DECIMAL(18,5);
DEFINE dConsACT              DECIMAL(18,5);
DEFINE dConsHIST             DECIMAL(18,5);
DEFINE dConsANT              DECIMAL(18,5);
DEFINE dConsPORPAGO          DECIMAL(18,5);
DEFINE dConsPORUSO           DECIMAL(18,5);
DEFINE dPIdefaul             DECIMAL(18,5);
DEFINE dConsSPMenor          DECIMAL(18,5);
DEFINE dConsSPMayor          DECIMAL(18,5);
DEFINE dConsComPI            DECIMAL(18,5);
DEFINE dImpPerConACT         DECIMAL(18,5);
DEFINE dImpPerConACTaux         DECIMAL(18,5);
DEFINE dImpObsHIST           DECIMAL(18,5);
DEFINE dConsMinPorPago       DECIMAL(18,5);
DEFINE dConsMaxPorPago       DECIMAL(18,5);
DEFINE dConsMinPorUso        DECIMAL(18,5);
DEFINE dConsMaxPorUso        DECIMAL(18,5);
DEFINE dPorUsoMinCtesNunca   DECIMAL(18,5);
DEFINE dPorResSic            DECIMAL(18,5);
DEFINE cGradoRiesgo          CHAR(2);

DEFINE cNumeroCredito        CHAR(20);
DEFINE cStatusCred           CHAR(2);
DEFINE cSucursal             CHAR(4);
DEFINE cProducto             CHAR(4);
DEFINE cPeriodicidad         CHAR(1);
DEFINE dtFechaApertura       DATE;
DEFINE dtFechaAperturaTDC    DATE;
DEFINE dtFechaPeriodo        DATE;
DEFINE cDivisa               CHAR(2);
DEFINE dEndeudamientoTot     DECIMAL(18,5);
DEFINE dInteVencIva          DECIMAL(18,2);
DEFINE dMoratorios           DECIMAL(18,2);
DEFINE dLimiteCredito        DECIMAL(18,5);
DEFINE dTotal_capitalizado   DECIMAL(18,5);
DEFINE dPagoMinimo           DECIMAL(18,5);
DEFINE dImporteReservaMesAnt DECIMAL(18,5);
DEFINE iNumReg               INTEGER;
DEFINE dIvaSuc   			 DECIMAL(18,2);
DEFINE dPorPago              DECIMAL(18,5);
DEFINE dPorUso               DECIMAL(18,5);

DEFINE iACT                  INTEGER;
DEFINE iHIST                 INTEGER;
DEFINE i                     INTEGER;
DEFINE iBanderaConc          INTEGER;  
DEFINE iContInsert           INTEGER;
DEFINE dIncumplimiento       DECIMAL(18,5);
DEFINE dPagoRealizado        DECIMAL(18,5);
DEFINE iANT                  DECIMAL(18,5);
DEFINE dEvaBuro              CHAR(01);
DEFINE dPI                   DECIMAL(30,10);
DEFINE dSP                   DECIMAL(18,5);
DEFINE dLineaAutorizada      DECIMAL(18,5);
DEFINE dResCalificacion      DECIMAL(18,5);
DEFINE dImporteReservaBuroCC DECIMAL(18,5);
DEFINE iNvoPeriodo           INTEGER;
DEFINE cTabla          		 CHAR(1);
DEFINE dIntVenCargRees               DECIMAL(18,5);
DEFINE dIntDeclaCtaBalan             DECIMAL(18,5);
DEFINE dIntDeclaCtaOrden             DECIMAL(18,5);
DEFINE dInt_Vencido                  DECIMAL(18,5);
DEFINE dInt_Mora                     DECIMAL(18,5);
DEFINE dInt_Devengado                DECIMAL(18,5);
DEFINE vmonto_capitalizado           DECIMAL(18,5);
DEFINE vcodigo_ref      INTEGER;
DEFINE icuotas_venc                  INTEGER;  
DEFINE dint_venc_card                DECIMAL(18,5);
DEFINE vInteresesBalanza            DECIMAL(18,5);
DEFINE vIvaInteresesBalanza         DECIMAL(18,5);
DEFINE vInteresesOrden              DECIMAL(18,5);
DEFINE vIvaInteresOrden             DECIMAL(18,5);
DEFINE vInteresCapitalizado         DECIMAL(18,5);
DEFINE dFechaVencim     DATE;

--FMV 12mar12
DEFINE dFechaCuota          DATE;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      IF cBegin= 'S' THEN
         ROLLBACK WORK;
      END IF;
	  IF cTabla="S" THEN
	    DROP TABLE tme_sucursales;
      END IF;       
	   RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_calculo_reserva_corte_crd.out";
--TRACE ON;
 
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = '000000';
LET cMensajeRet           = 'El proceso de CALIFICACION DEL CORTE REESTRUCTURA se realizó correctamente';

LET cBegin                = 'F';
LET dtFechaCalculo        = DATE(1);
LET dtFechaUltMes         = DATE(1);
LET dtFechaPriMes         = DATE(1);
LET dtFechaMesAnt         = DATE(1);
LET dtFechaCorte          = DATE(1);
LET cNumCredito           = "";
LET cNumeroCreditoTC      = "";

LET dMensual              = 0;
LET dQuincenal            = 0;
LET dSemanal              = 0;
LET dConsPI               = 0;
LET dConsACT              = 0;
LET dConsHIST             = 0;
LET dConsANT              = 0;
LET dConsPORPAGO          = 0;
LET dConsPORUSO           = 0;
LET dPIdefaul             = 0;
LET dConsSPMenor          = 0;
LET dConsSPMayor          = 0;
LET dConsComPI            = 0;
LET dImpPerConACT         = 0;
LET dImpPerConACTaux         = 0;
LET dImpObsHIST           = 0;
LET dConsMinPorPago       = 0;
LET dConsMaxPorPago       = 0;
LET dConsMinPorUso        = 0;
LET dConsMaxPorUso        = 0;
LET dPorUsoMinCtesNunca   = 0;
LET dPorResSic            = 0;
LET cGradoRiesgo          = null;

LET cNumeroCredito        = "";
LET cStatusCred           = "";
LET cSucursal             = "";
LET cProducto             = "";
LET cPeriodicidad         = "";
LET dtFechaApertura       = DATE(1);
LET dtFechaAperturaTDC    = DATE(1);
LET dtFechaPeriodo        = DATE(1);
LET cDivisa               = "";
LET dEndeudamientoTot     = 0;
LET dInteVencIva          = 0;
LET dMoratorios           = 0;
LET dLimiteCredito        = 0;
LET dTotal_capitalizado   = 0;
LET dPagoMinimo           = 0;
LET dImporteReservaMesAnt = 0;
LET iNumReg               = 0;
LET dIvaSuc               = 0;
LET dPorPago              = 0;
LET dPorUso               = 0;

LET iACT                  = 0;
LET iHIST                 = 0;
LET i                     = 0;
LET iBanderaConc          = 0;
LET iContInsert           = 0;
LET dIncumplimiento       = 0;
LET dPagoRealizado        = 0;
LET iANT                  = 0;
LET dEvaBuro              = "";
LET dPI                   = 0;
LET dSP                   = 0;
LET dLineaAutorizada      = 0;
LET cSucursal             = "";
LET dResCalificacion      = 0;
LET dImporteReservaBuroCC = 0;
LET iNvoPeriodo           = 0;
LET cTabla                = "N";

LET dIntVenCargRees    = 0;
LET dIntDeclaCtaBalan  = 0;
LET dIntDeclaCtaOrden  = 0;
	
LET	dInt_Vencido = 0;
LET	dInt_Mora = 0;
LET	dInt_Devengado = 0;

LET vmonto_capitalizado = 0;
LET vcodigo_ref = 0;

--FMV 12-MAR-12
LET dFechaCuota = DATE(1);
--FMV 12mar12 : Periodo de pagos vencidos
LET icuotas_venc = 0;

--FMV 3abr12: Interes Vencido Tarjeta cargado a la Rees
LET dint_venc_card = 0;

LET vInteresesBalanza            = 0;
LET vIvaInteresesBalanza         = 0;
LET vInteresesOrden              = 0;
LET vIvaInteresOrden             = 0;
LET vInteresCapitalizado         = 0;
LET dFechaVencim  = DATE(1);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- Se obtiene la fecha hoy del sistema.
SELECT fecha_hoy, ult_dia_mes, pri_dia_mes
  INTO dtFechaCalculo, dtFechaUltMes, dtFechaPriMes
  FROM "informix".sd_fechas
 WHERE empresa = pEmpresa;

--Temporal solo para pruebas
--let dtFechaCalculo = mdy('06','03','2012'); 
--let dtFechaUltMes = mdy('06','30','2012'); 
--let dtFechaPriMes = mdy('06','01','2012'); 
--Temporal solo para pruebas

IF DATE(dtFechaCalculo) > mdy(month(dtFechaCalculo),2,year(dtFechaCalculo)) and DATE(dtFechaCalculo) < mdy(month(dtFechaCalculo),18,year(dtFechaCalculo)) THEN
   LET dtFechaCalculo = mdy(month(dtFechaCalculo),2,year(dtFechaCalculo)); 
ELSE
   LET dtFechaCalculo = mdy(month(dtFechaCalculo),17,year(dtFechaCalculo)); 
END IF;

-- Se obtienen los parámetros necesarios para el proceso
SELECT valor 
  INTO dMensual 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '27';

IF dMensual IS NULL THEN
   LET cCodRet     = '000027';
   LET cMensajeRet = 'FALTA PARAMETRO CALCULO DE IMPAGOS MENSUALES';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor
  INTO dQuincenal 
  FROM "informix".sd_param_reservas_crd 
 WHERE empresa   = pEmpresa 
   AND cod_param = '1';

IF dQuincenal IS NULL THEN
   LET cCodRet= '000010';
   LET cMensajeRet= 'FALTA PARAMETRO CALCULO DE IMPAGOS QUINCENALES';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dSemanal 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '2';

IF dSemanal IS NULL THEN
   LET cCodRet= '000020';
   LET cMensajeRet= 'FALTA PARAMETRO CALCULO DE IMPAGOS SEMANALES';
   RETURN cCodRet,cMensajeRet;
END IF;

SELECT valor 
  INTO dConsPI 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '3';

IF dConsPI IS NULL THEN
   LET cCodRet     = '000030';
   LET cMensajeRet = 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO (PI)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dConsACT 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '4';

IF dConsACT IS NULL THEN
   LET cCodRet     = '000040';
   LET cMensajeRet = 'FALTA CONSTANTE IMPAGO ACTUAL (ACT)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dConsHIST 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '5';

IF dConsHIST IS NULL THEN
   LET cCodRet     = '000050';
   LET cMensajeRet = 'FALTA CONSTANTE IMPAGO HISTORICO (HIST)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dConsANT 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '6';

IF dConsANT IS NULL THEN
   LET cCodRet     = '000060';
   LET cMensajeRet = 'FALTA CONSTANTE ANTIGÜEDAD (ANT)';
   RETURN cCodRet, cMensajeRet;
END IF

SELECT valor 
  INTO dConsPORPAGO 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '7';

IF dConsPORPAGO IS NULL THEN
   LET cCodRet     = '000070';
   LET cMensajeRet = 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE PAGO (%PAGO)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dConsPORUSO 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '8';

IF dConsPORUSO IS NULL THEN
   LET cCodRet     = '000080';
   LET cMensajeRet = 'FALTA CONSTANTE PARA EL CALCULO DE PORCENTAJE USO (%USO)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dPIdefaul 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '13';

IF dPIdefaul IS NULL THEN
   LET cCodRet     = '000130';
   LET cMensajeRet = 'FALTA CONSTANTE PARA PROBABILIDAD DE INCUMPLIMIENTO >=4 (PI)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dConsSPMenor 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '14';

IF dConsSPMenor IS NULL THEN
   LET cCodRet     = '000140';
   LET cMensajeRet = 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT < 10 (SP)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dConsSPMayor 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '15';

IF dConsSPMayor IS NULL THEN
   LET cCodRet     = '000150';
   LET cMensajeRet = 'FALTA CONSTANTE SEVERIDAD DE LA PERDIDA CUANDO ACT >= 10 (SP)';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dConsComPI 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '16';

IF dConsComPI IS NULL THEN
   LET cCodRet     = '000160';
   LET cMensajeRet = 'CONSTANTE COMPARACION ACT PARA CALCULO DE PI';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dImpPerConACT 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '18';

IF dImpPerConACT IS NULL THEN
   LET cCodRet     = '000180';
   LET cMensajeRet = 'FALTA PARAMETRO IMPAGOS EN PERIODOS CONSECUTIVOS ACT';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dImpObsHIST 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '20';

IF dImpObsHIST IS NULL THEN
   LET cCodRet     = '000200';
   LET cMensajeRet = 'FALTA PARAMETRO IMPAGOS OBSERVADOS ULTIMOS MESES HIST';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dConsMinPorPago 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '21';

IF dConsMinPorPago IS NULL THEN
   LET cCodRet     = '000210';
   LET cMensajeRet = 'FALTA VALOR MINIMO COMPARATIVO % DE PAGO';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
  INTO dConsMaxPorPago 
  FROM "informix".sd_param_reservas_crd  
 WHERE empresa   = pEmpresa 
   AND cod_param = '22';

IF dConsMaxPorPago IS NULL THEN
   LET cCodRet= '000220';
   LET cMensajeRet= 'FALTA MAXIMO COMPARATIVO % DE PAGO';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
 INTO dConsMinPorUso 
 FROM "informix".sd_param_reservas_crd  
WHERE empresa   = pEmpresa 
  AND cod_param = '23';
   
    IF dConsMinPorUso IS NULL THEN
       LET cCodRet= '000230';
       LET cMensajeRet= 'FALTA MINIMO COMPARATIVO % DE USO';
       RETURN cCodRet, cMensajeRet;
    END IF;

SELECT valor 
 INTO dConsMaxPorUso 
 FROM "informix".sd_param_reservas_crd  
WHERE empresa   = pEmpresa 
  AND cod_param = '24';
    
IF dConsMaxPorUso IS NULL THEN
   LET cCodRet     = '000240';
   LET cMensajeRet = 'FALTA MAXIMO COMPARATIVO % DE USO';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
 INTO dPorUsoMinCtesNunca 
 FROM "informix".sd_param_reservas_crd  
WHERE empresa   = pEmpresa 
  AND cod_param = '19';

IF dPorUsoMinCtesNunca IS NULL THEN
   LET cCodRet     = '0001900';
   LET cMensajeRet = 'FALTA PORCENTAJE USO MINIMO CLIENTES NUNCA';
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT valor 
 INTO dPorResSic 
 FROM "informix".sd_param_reservas_crd  
WHERE empresa   = pEmpresa 
  AND cod_param = '25';

IF dPorResSic IS NULL THEN
   LET cCodRet     = '000250';
   LET cMensajeRet = 'FALTA PORCENTAJE DE RESERVA DE SIC';
   RETURN cCodRet, cMensajeRet;
END IF;

--SELECT valor 
-- INTO cGradoRiesgo 
-- FROM "informix".sd_param_reservas_crd  
--WHERE empresa   = pEmpresa 
--  AND cod_param = '26';

--IF cGradoRiesgo IS NULL THEN
--   LET cCodRet     = '000260';
--   LET cMensajeRet = 'GRADO RIESGO CLIENTES NUNCA';
--   RETURN cCodRet, cMensajeRet;
--END IF;
/*
SELECT gradual
  INTO dGradual
  FROM "informix".sd_gradualidad_crd
 WHERE empresa   = pEmpresa
   AND mes_anio = LPAD(MONTH(dtFechaUltMes),2,0)||YEAR(dtFechaUltMes);
*/
-- Se obtiene el maestro de sucursales
SELECT  
      empresa,sucursal,iva 
  FROM bdinteg:"informix".si_sucursales d
 WHERE empresa = pEmpresa
   AND sucursal <> ''
  INTO temp tme_sucursales WITH NO LOG;

CREATE INDEX indx_tme_sucursales ON tme_sucursales (empresa, sucursal);
UPDATE STATISTICS MEDIUM FOR TABLE tme_sucursales;
LET cTabla="S";
-- Se obtienen los datos del crédito.
FOREACH WITH HOLD
      SELECT a.num_credito, a.credito_externo, a.status_cred, a.sucursal, a.num_producto,
             a.periodo_plazo, a.fecha_apertura, a.divisa, MDY(MONTH(dtFechaCalculo),LPAD(b.dia_corte,2,0),YEAR(dtFechaCalculo)),
             a.fecha_vencim
        INTO cNumeroCredito, cNumeroCreditoTC, cStatusCred, cSucursal, cProducto,
             cPeriodicidad, dtFechaApertura, cDivisa, dtFechaCorte,
             dFechaVencim
        FROM bdicred:"informix".sd_maecredcrd a,
             bdicred:"informix".sd_maecredanexocrd b
       WHERE a.empresa        = pEmpresa   
         AND b.empresa        = a.empresa         
         AND b.num_credito    = a.num_credito
         AND b.dia_corte      = DAY(dtFechaCalculo)      
         AND a.num_producto   = '6011'
         AND a.fecha_apertura <= dtFechaCalculo
         AND a.status_cred    IN ("AA","BA","BT","VP","E1","E2","E3") 
         AND a.num_credito    NOT IN (SELECT d.num_credito
                                        FROM bdicred:"informix".sd_hist_reserva_crd d
                                       WHERE a.empresa     = d.empresa 
                                         AND d.fecha_corte_fin = MDY(MONTH(dtFechaCalculo),LPAD(b.dia_corte,2,0),YEAR(dtFechaCalculo)))

       EXECUTE PROCEDURE "informix".monthadd(dtFechaCorte, -1) INTO dtFechaPeriodo;

    SELECT NVL(monto_otorgado,0) INTO dLimiteCredito
     FROM bdicred:sd_maesdoshistcrd 
     WHERE fecha = dtFechaCorte
       AND empresa = pEmpresa 
       AND num_credito = cNumeroCredito; 

    SELECT monto_pago,pago_total_tc INTO dPagoMinimo,dEndeudamientoTot
      FROM bdicred:sd_encabezado2_edoctacrd
     WHERE fecha_emision = dtFechaCorte 
       AND num_credito = cNumeroCredito; 

    if dPagoMinimo is null then let dPagoMinimo = 0; end if;
    if dEndeudamientoTot is null then let dEndeudamientoTot = 0; end if;

    if dFechaVencim <= dtFechaCalculo and dPagoMinimo = 0 then let dPagoMinimo = dEndeudamientoTot; end if;

-- OBTIENE INTERESES CAPITALIZADOS CUANDO PASO A VENCIDO
        IF cStatusCred = 'VP' THEN

           select max(fecha_cuota) into dFechaCuota
             from bdicred:sd_amortiza_credito_vendida
            where empresa = pEmpresa 
              and num_credito = cNumeroCreditoTC 
              and capital_status in ('5','2','7','6')
               and interes_debe = 0 and capital_debe > 0;

            if dFechaCuota is null or dFechaCuota = '' then let dFechaCuota = date(1); end if;

            if dFechaCuota != date(1) then
                select sum(monto)
                  into vmonto_capitalizado
                  FROM bdicred:sd_movhis mov
                 WHERE mov.empresa = pEmpresa
                   AND mov.fecha_mov >= dFechaCuota
				   AND mov.fecha_mov <= dtFechaCalculo
                   AND mov.num_credito = cNumeroCreditoTC
                   AND mov.codigo_fun = '605'
                   and mov.codigo_ref in (2,125,127)
                   AND mov.reversado = 'N';
            end if;
        END IF;

--se obtiene el credito relacionado con la reestructura.		
         SELECT fecha_apertura
           INTO dtFechaAperturaTDC
           FROM bdicred:"informix".sd_maecred 
          WHERE empresa     = pEmpresa
            AND num_credito = cNumeroCreditoTC;

-- OBTIENE INTERESES CAPITALIZADOS AL MOMENTO DE LA REESTRUCTURA
         SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} nvl(sum(monto),0)
         INTO dIntVenCargRees
         FROM bdicred:"informix".sd_movhis
        WHERE empresa = pEmpresa
          AND fecha_mov = dtFechaApertura
          AND num_credito = cNumeroCreditoTC  
          AND codigo_fun = '338' 
          AND codigo_ref in (2,3,18,21,22,23,28,29,30,31)
          AND reversado = 'N';
       
       -- TOTAL DE PAGOS REALIZADOS EN EL PERIODO
     SELECT {+INDEX(bdicred:sd_movhiscrd inx_movcrd)} NVL(SUM(monto),0) 
       INTO dPagoRealizado
       FROM bdicred:"informix".sd_movhiscrd
      WHERE empresa     = pEmpresa
        AND fecha_mov   >= dtFechaPeriodo + 1
        AND fecha_mov   <=  dtFechaCorte 
        AND num_credito = cNumeroCredito
        AND codigo_fun  IN (SELECT cod_fun FROM "informix".sd_conceptospagomanualcrd where num_producto = '6011')
        AND codigo_ref  = 1
        AND reversado   = 'N';

-- Se calcula % de Pago 
       IF dEndeudamientoTot > 0 THEN
          LET dPorPago = dPagoRealizado / dEndeudamientoTot;
       END IF;
     
       SELECT iva 
          INTO dIvaSuc
          FROM tme_sucursales
         WHERE empresa = pEmpresa
           AND sucursal= cSucursal;

      LET dMoratorios = Round(dMoratorios * (1 + dIvaSuc),2);
  
      LET cMensajeRet = cNumeroCredito;

      IF (iContInsert = 0) THEN
        LET cBegin = 'S';
        BEGIN WORK;
      END IF;

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
              AND num_credito = cNumeroCredito
              AND day(fecha)  = day(dtFechaCorte)	--FMV 17abr12: Dia de la fecha del corte              
            ORDER BY fecha DESC

            IF dIncumplimiento > 0   THEN
                IF iBanderaConc = 0 THEN
                  LET iACT = iACT + 1;
                END IF;

-- Impagos observados en los últimos meses HIST
                IF i < dImpObsHIST THEN  -- 6
                  LET iHIST = iHIST + 1;
                END IF;
            ELSE
                LET iBanderaConc= 1;
            END IF;

            LET i = i + 1;

            --Impagos en períodos consecutivos ACT
            IF (iBanderaConc = 1 AND i >= dImpPerConACT) THEN  -- 10
               EXIT FOREACH;
            END IF;
      END FOREACH;

      IF i = 1 THEN LET iBanderaConc = 0; END IF;

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
					  
			-- Impagos observados en los últimos meses HIST
				IF i < dImpPerConACT AND i < dImpObsHIST THEN  
				  LET iHIST = iHIST + 1;
				END IF;
			ELSE
				LET iBanderaConc= 1;
			END IF;

			LET i = i + 1;

			--Impagos en períodos consecutivos ACT
			IF (iBanderaConc = 1 AND i >= dImpPerConACT) THEN  
			   EXIT FOREACH;
			END IF;
		END FOREACH;
	  END IF;

		IF cPeriodicidad = "M" THEN
			LET iACT  = iACT * dMensual;
			LET iHIST = iHIST * dMensual;
		ELIF cPeriodicidad = "Q" THEN
			LET iACT  = iACT * dQuincenal;
			LET iHIST = iHIST * dQuincenal;
		ELIF cPeriodicidad = "S" THEN
			LET iACT  = iACT * dSemanal;
			LET iHIST = iHIST * dSemanal;
		END IF;

-- Se cambia el calculo de la antigûedad tomando la fecha de fin de mes como base Y COMO FECHA INICIAL LA FECHA DE APERTURA DE LA TDC
		LET iANT = ROUND((dtFechaUltMes - dtFechaAperturaTDC)/30,2);

--Se obtiene la reserva del mes anterior
		SELECT {+INDEX(bdicred:sd_hist_reserva_crd idx_fecha_cierre_crd)} reserva_calificacion
		INTO dImporteReservaMesAnt
		FROM bdicred:"informix".sd_hist_reserva_crd
		WHERE empresa = pEmpresa 
		AND num_credito = cNumeroCredito
		AND fecha_cierre = dtFechaPriMes - 1;

		IF dImporteReservaMesAnt IS NULL THEN LET dImporteReservaMesAnt=0; END IF;

-- Se calcula % de Uso 
     IF dLimiteCredito < 1.01 THEN
        LET dPorUso  = 1; 
     ELSE 
        LET dPorUso  = dEndeudamientoTot / dLimiteCredito; 
     END IF;

-- Se calcula % de Pago 
    IF dEndeudamientoTot > 0 THEN
       LET dPorPago = dPagoRealizado / dEndeudamientoTot;
    ELSE
       LET dPorPago = 0;
    END IF;
-- Valida valor máximo para %PAGO
     IF dPorPago  > dConsMaxPorPago THEN
        LET dPorPago  = dConsMaxPorPago;
     END IF; 

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
       FROM bdisolic:"informix".ss_resum_scor_fin 
      WHERE empresa = pEmpresa 
        AND num_solicitud = cNumeroCreditoTC;

      -- Se obtiene el límite de crédito y Cuotas vencidas a fin de mes  -->FMV 12mar12
      SELECT mto_fin_ven_trasp
        INTO icuotas_venc
        FROM bdicred:"informix".sd_maesdoscontcrd
       WHERE empresa = pEmpresa                                     
         AND num_credito = cNumeroCredito
         AND fecha = ( SELECT MAX (fecha)                                              
             FROM bdicred:"informix".sd_maesdoscontcrd
            WHERE empresa = pEmpresa                                     
              AND num_credito = cNumeroCredito) ;

     IF (cStatusCred = 'BT') THEN
--orden
        select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresesOrden, vIvaInteresOrden
          from bdicred:sd_amortiza_creditocrd
         where empresa = pEmpresa
           and num_credito = cNumeroCredito
           and capital_status in ('2','7')
           and fecha_cuota > (
               select max(fecha_mov)
                 from bdicred:sd_movhiscrd
                where empresa = pEmpresa
                  and num_credito = cNumeroCredito
                  and codigo_fun = '602'
                  and codigo_ref = 2
                  and reversado = 'N');
--balanza
        select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresesBalanza, vIvaInteresesBalanza
          from bdicred:sd_amortiza_creditocrd
         where empresa = pEmpresa
           and num_credito = cNumeroCredito
           and capital_status in ('2','7')
           and fecha_cuota <= (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumeroCredito
                                and codigo_fun = '602'
                                and codigo_ref = 2
                                and reversado = 'N');
     END IF;
	 
	 IF (cStatusCred in ('E1','E2','E3')) THEN
--orden
        select nvl(sum(interes_debe - interes_pagado),0), 
		       nvl(sum(iva_debe - iva_pagado),0) 
		  INTO vInteresesOrden, vIvaInteresOrden
          from bdicred:sd_amortiza_creditocrd
         where empresa = pEmpresa
           and num_credito = cNumeroCredito
           and capital_status in ('2','7','6')
		   and campo_trabajo3 = 'V';
--balanza
        select nvl(sum(interes_debe - interes_pagado),0), 
		       nvl(sum(iva_debe - iva_pagado),0) 
		  INTO vInteresesBalanza, vIvaInteresesBalanza
          from bdicred:sd_amortiza_creditocrd
         -- from bdicred:sd_amortiza_creditocrd
         where empresa = pEmpresa
           and num_credito = cNumeroCredito
           and capital_status in ('2','7','6')
		   and campo_trabajo3 = '';
	 END IF;

      -- Se almacena la información correspondiente al calculo de la reservas preventivas.
         INSERT INTO "informix".sd_hist_reserva_crd
          VALUES (pEmpresa,
				  dtFechaPeriodo,
                  dtFechaCorte,
                  cNumeroCredito,
                  NULL,
                  NULL,
                  dtFechaApertura,
                  dEvaBuro,
                  cStatusCred,
                  dLimiteCredito,
				  vmonto_capitalizado,
				  dIntVenCargRees,
				  vInteresesBalanza,
				  vInteresesOrden,
                  dEndeudamientoTot,
                  NULL,
                  dPagoMinimo,
                  dPagoRealizado,
                  NULL,
                  NULL,
				  NULL,
                  NULL,
                  NULL,
                  iANT,
                  dPI * 100,
                  dSP * 100,
                  NULL,
                  iACT,
                  iHIST,
                  dPorPago * 100,
                  dPorUso * 100,
                  icuotas_venc,
                  dImporteReservaMesAnt,
				  cNumeroCreditoTC,
				  dtFechaAperturaTDC);
/*
		---CALCULA LAS RESERVAS PARA LOS CLIENTES NUNCA Y PARA LOS CLIENTES TOTALEROS(INTRA) 
	IF (dEndeudamientoTot <=0 AND dPagoRealizado >= 0) THEN
		-- Se obtiene el antecedente a Buró	
		   
		 SELECT evalua_cc
		   INTO dEvaBuro
		   FROM bdisolic:"informix".ss_resum_scor_fin 
		  WHERE empresa = pEmpresa 
			AND num_solicitud = cNumeroCreditoTC;

				-- Se obtiene la línea autorizada
			 IF (dtFechaApertura > dtFechaPeriodo) then
				 SELECT monto_solicitado
				   INTO dLimiteCredito
				   FROM bdisolic:"informix".ss_solicitudes 
				  WHERE empresa = pEmpresa 
					AND num_solicitud = cNumeroCreditoTC; --FMV 16abr12 se cambia por tarjeta

					IF dLimiteCredito is NULL THEN
					    --LET dLimiteCredito = 0;
                        --FMV 12-MAR-12 :Si el limite de credito es NULL por ser credito de reciente apertura, 
                       --se busca en la tabla maestro de saldos.
                           SELECT  
                                  NVL(monto_otorgado,0)
                             INTO dLimiteCredito
                             FROM "informix".sd_maesdoscrd
                            WHERE empresa     = pEmpresa
                              AND num_credito = cNumeroCredito;
					END IF;
			 END IF;   
	
			IF (dEndeudamientoTot<=0 AND dPagoRealizado=0) THEN -- clientes inactivos
			  LET dResCalificacion = dPorUsoMinCtesNunca * (CASE WHEN (dLimiteCredito + dEndeudamientoTot) < 0 THEN 0 ELSE (dLimiteCredito + dEndeudamientoTot) END);
--			  LET dReservaGradual= dResCalificacion * dGradual;
			  IF dEvaBuro='1' THEN
				 LET dImporteReservaBuroCC = dResCalificacion * dPorResSic;
			  END IF; 
			ELSE
			  LET dImporteReservaBuroCC = 0;
			  LET dResCalificacion      = 0;
--			  LET dReservaGradual       = 0;
			END IF;


       INSERT INTO "informix".sd_hist_reserva_crd
        (empresa, fecha_corte_inicio,fecha_corte_fin, num_credito, fecha_cierre,
         grado_riesgo, fecha_apertura, antecedente_buro, status_cred, 
         limite_credito, interes_cred_ven,interes_ven_cargados,interes_dec_cta_balance,interes_dec_cta_orden, 
         saldo_corte, saldo_cierre, pago_minimo,  pagos_realizados, reserva_int_cred_ven,
         reserva_buro,otras_estimaciones,reserva_calificacion, porcentaje_reserva,  meses_antiguedad,
          severidad_perdida, impagos_consecutivos, impagos_historicos,
         porcentaje_pago, porcentaje_uso, num_periodos, reserva_calif_mes_anterior, 
         num_credito_tdc,
         fecha_apertura_tdc) 
       VALUES
        (pEmpresa, dtFechaPeriodo,dtFechaCorte, cNumeroCredito, NULL,
         cGradoRiesgo, dtFechaApertura, dEvaBuro, cStatusCred, 
         dLimiteCredito, vmonto_capitalizado, dIntVenCargRees, null, null,
         dEndeudamientoTot, null, dPagoMinimo,dPagoRealizado, dint_venc_card,
         dImporteReservaBuroCC, null, dResCalificacion,(CASE WHEN dPagoRealizado>0 THEN 0 ELSE dPorUsoMinCtesNunca END)*100,iANT,
         (CASE WHEN iACT< dImpPerConACT then dConsSPMenor else dConsSPMayor end)*100, iACT, iHIST,
         dPorPago * 100, dPorUso * 100,icuotas_venc, dImporteReservaMesAnt, 
         cNumeroCreditoTC, 
         dtFechaAperturaTDC);

		
         LET iNvoPeriodo= 1;

        IF dResCalificacion>0 THEN   --FMV 8mar12 : Se cambia codigo fun 091
        -- Genera Movimiento para Contabilidad
            EXECUTE PROCEDURE "informix".genmov_calif_crd (pEmpresa,
                                            cNumeroCredito,
                                            cProducto,
                                            iNvoPeriodo,
                                            "091",    
                                            dtFechaUltMes,
                                            dResCalificacion,
                                            "CalifCartReserva",
                                             cSucursal,
                                             cDivisa,
                                             "0000")
            INTO cCodRet, cMensajeRet;
            IF TRIM(cCodRet) <> "000000" THEN
               RETURN cCodRet, cMensajeRet;
            END IF;
        END IF;
                      --FMV 8mar12: codigo 090
        IF dResCalificacion > 0 AND (dLimiteCredito + dEndeudamientoTot) > 0 THEN  
            EXECUTE PROCEDURE "informix".genmov_calif_crd (pEmpresa,
                                            cNumeroCredito,
                                            cProducto,
                                            iNvoPeriodo,
                                            "090", 
                                            dtFechaUltMes,
                                            (dLimiteCredito + dEndeudamientoTot),
                                            "CalifCart",
                                             cSucursal,
                                             cDivisa,
                                             "0000")
            INTO cCodRet, cMensajeRet;
            IF TRIM(cCodRet) <> "000000" THEN
               RETURN cCodRet, cMensajeRet;
            END IF;
        END IF;
                    --FMV 8-MAR-12: CODIGO_FUN  092 CODIGO_REF 1, PARA BURO
        IF dImporteReservaBuroCC > 0 THEN
            --Califica malos antecedentes
              EXECUTE PROCEDURE "informix".genmov_calif_crd (pEmpresa,
                                              cNumeroCredito,
                                              cProducto,
                                               1,
                                              "092",
                                              dtFechaUltMes,
                                              dImporteReservaBuroCC,
                                              "CalifCart",
                                              cSucursal,
                                              cDivisa,
                                              "0000")
             INTO cCodRet, cMensajeRet;
             IF TRIM(cCodRet) <> "000000" THEN
               RETURN cCodRet, cMensajeRet;
             END IF;
        END IF;
------------------------------------------------------------------------------------
       LET iContInsert = iContInsert + 1;
       CONTINUE FOREACH;
   END IF;
*/
--Se inicializan variables del cursor
   LET dtFechaPeriodo       = DATE(1);
   LET dtFechaCorte         = DATE(1);
   LET cNumeroCredito       = '';
   LET dtFechaApertura      = DATE(1);
   LET dEvaBuro             = '';
   LET cStatusCred          = '';
   LET dLineaAutorizada     = 0;
   LET dLimiteCredito       = 0;
   LET vmonto_capitalizado  = 0;
   LET dIntVenCargRees      = 0;
   LET dEndeudamientoTot    = 0;
   LET dPagoMinimo          = 0;
   LET dPagoRealizado       = 0;
   LET iANT                 = 0;
   LET dPI                  = 0;
   LET dSP                  = 0;
   LET iACT                 = 0;
   LET iHIST                = 0;
   LET dPorPago             = 0;
   LET dPorUso              = 0;
   LET icuotas_venc         = 0;
   LET dImporteReservaMesAnt = 0;
   LET cNumeroCreditoTC = '';
   LET dtFechaAperturaTDC = DATE(1);
   LET vInteresesBalanza    = 0;
   LET vIvaInteresesBalanza = 0;
   LET vInteresesOrden      = 0;
   LET vIvaInteresOrden     = 0;
   LET dFechaCuota = DATE(1);
   LET dFechaVencim  = DATE(1);

   LET iContInsert = iContInsert + 1;

   IF (iContInsert >= 7000) THEN
      COMMIT WORK;
      LET iContInsert = 0;
   END IF;

END FOREACH;

IF (iContInsert > 0) THEN
   COMMIT WORK;
END IF;

UPDATE statistics medium FOR TABLE sd_hist_reserva_crd;
    
  DROP TABLE tme_sucursales;
        LET cMensajeRet= 'El proceso de CALIFICACION DEL CORTE REESTRUCTURAS se realizó correctamente';
  RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener',
'el calculo de la reserva para creéditos reestructurados.',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 01/AGOSTO/2011',
'BD    : BDICRED',
'Se realiza eliminan consultas a la tabla sd_maesdoscontcrd para el calculo de interes',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 28/Septiembre/2011',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cancelacion_ctas_nunca(pEmpresa CHAR(3))
RETURNING CHAR(6)        AS codigo_retorno,
          VARCHAR(150,1) AS mensaje_retorno;


--- DECLARACION DE VARIABLES ---		  
DEFINE dtFechaHoy       DATE;
DEFINE dtFechaCompara   DATE;

DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE iMeses           INTEGER;
DEFINE iTotalRegistros  INTEGER;
DEFINE iTotalCtasNunca	INTEGER;
DEFINE iSaldoAFavorMax	INTEGER;

DEFINE cMonto 			MONEY(14,2);
DEFINE cMonto_2			MONEY(14,2);
DEFINE vSaldo			MONEY(14,2);
DEFINE v_cap_insol		MONEY(14,2);

DEFINE cMensajeRet      VARCHAR(150,1);
DEFINE cSucursal		VARCHAR(4);
DEFINE cNumCred         VARCHAR(20,1);
DEFINE cErrorInfo       VARCHAR(150,1);
DEFINE cCodRetGM		VARCHAR(10);
DEFINE cMensaje			VARCHAR(80);
DEFINE cCod_fun			VARCHAR(3);
DEFINE cCod_fun_2		VARCHAR(3);

DEFINE cCodRet          	CHAR(6); 
DEFINE cCodRet2             CHAR(6);
DEFINE cCodRet3             CHAR(6);
DEFINE cEmpresa         	CHAR(3);
DEFINE cProducto			CHAR(4);
DEFINE cCodRetAux       	CHAR(5);
DEFINE cFolioSucAux     	CHAR(16);
DEFINE cFechaGenArchivo 	CHAR(8);
DEFINE cDivisa				CHAR(2);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnombrefinal			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(2704);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2304);
DEFINE cSQL3                CHAR(200);
DEFINE cruta                CHAR(100);
DEFINE cCodRetIB			CHAR(6);
DEFINE cProceso         	CHAR(4);
DEFINE vNumCred				CHAR(20);
DEFINE cFolioSuc2           CHAR(16);

--Envio de SMS & Correo
DEFINE cNom_Cte               char(150);
DEFINE cNom_Producto          char(100);
DEFINE cNum_Tarjeta           char(20);
DEFINE dFechaRegistro         date;
DEFINE pNumCel                char(13);
DEFINE COD_RET				  char(05);
DEFINE cCorreo				  char(100);


--- INICIALIZACION DE VARIABLES ---
LET dtFechaHoy      = DATE(1);
LET dtFechaCompara  = DATE(1);

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET iMeses          = 0;
LET iTotalRegistros = 0;
LET iTotalCtasNunca = 0;
LET	iSaldoAFavorMax = 0;

LET cMonto			= 0;
LET cMonto_2		= 0;
LET vSaldo			= 0;
LET v_cap_insol		= 0;


LET cMensajeRet     = "PROCESO EXITOSO";
LET cSucursal		= "";
LET cNumCred        = "";
LET cErrorInfo      = "";
LET cCodRetGM		= "";
LET cMensaje		= "";
LET cCod_fun		= "";
LET cCod_fun_2		= "";

LET cCodRet         	= "000000";
LET cCodRet2            ="000000";
LET cCodRet3            ="000000";
LET cEmpresa        	= "";
LET cProducto			= "6001";
LET cCodRetAux      	= "";
LET cFolioSucAux    	= "";
LET cFechaGenArchivo 	= "";
LET cDivisa				= "";
LET cnomarchivo  		= "";
LET cnomarchivo1	 	= "";
LET cnomarchivoEjecSql	= "";
LET cSQL       			= "";
LET cSQL1      			= "";
LET cSQL2      			= "";
LET cSQL3      			= "";
LET cruta      			= "/resplogifx/archivoscartera/"; 
--LET cruta      			= "/informix/Joel/Envio_SMS/";
LET cnombrefinal		= "INACT_NUNC_CANCEL_";
LET cCodRetIB			= "000000";
LET cProceso            = '0089'; 
LET vNumCred			= "";
LET cFolioSuc2          ="";


BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
		CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'ERROR CANCEL INACTIVAS-NUNCAS '||'-'||iIsamErr::CHAR ||'-'||cNumCred, '02') Returning cCodRetIB;
		RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 4;

--SET DEBUG FILE TO '/informix/Joel/Envio_SMS/sp_cancelacion_ctas_nunca_joel.out';
--TRACE ON;
 
CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'INICIA OBTENCION CTAS INACTIVAS A CANCELAR', '02') Returning cCodRetIB;
 
 SELECT empresa
   INTO cEmpresa     
   FROM bdinteg:si_empresas 
  WHERE empresa= pEmpresa;
  
  IF TRIM(NVL(cEmpresa,'')) = '' THEN
	  LET cCodRet = '000001';
	  LET cMensajeRet = 'El parametro de la empresa no es valido';
	  RETURN cCodRet, cMensajeRet;
  END IF;
	
	--LET dtFechaHoy = '01-05-2019';
	SELECT fecha_hoy
      INTO dtFechaHoy
	  FROM 'informix'.sd_fechas
	 WHERE empresa = pEmpresa;

	IF NVL(dtFechaHoy,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000003';
		LET cMensajeRet = 'La fecha del sistema no es valida';
		RETURN cCodRet,cMensajeRet;
	END IF;
 
	SELECT TRIM(valor)::INTEGER
		INTO iMeses
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "177";	
 
 	IF NVL(iMeses,0) = 0 THEN
		LET cCodRet = '000004';
		LET cMensajeRet = 'El parametro de los meses no es valido';
		RETURN cCodRet,cMensajeRet;
	END IF;
	
	
	--- Saldo a Favor Maximo para Cancelacion de Cuentas
		SELECT TRIM(valor)::INTEGER
		INTO iSaldoAFavorMax
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "189";	
 
 	IF NVL(iSaldoAFavorMax,0) = 0 THEN
		LET cCodRet = '000002';
		LET cMensajeRet = 'El parametro del saldo a favor no es valido';
		RETURN cCodRet,cMensajeRet;
	END IF;

-- Variables de inicio para cuentas INACTIVAS. 	
	SELECT TRIM(valor)::INTEGER
		INTO iTotalRegistros
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "178";	
 
 	IF NVL(iTotalRegistros,0) = 0 THEN
		LET cCodRet = '000005';
		LET cMensajeRet = 'El parametro del contador de registros no es valido';
		RETURN cCodRet,cMensajeRet;
	END IF;

LET dtFechaCompara = MONTHADD(dtFechaHoy,-iMeses);

-- Borra la tabla al inicio del proceso.
TRUNCATE TABLE "informix".paso_can_sol_nuncas;

--- Llena la tabla bdicred:paso_can_sol_nuncas con la informacion de cuentas INACTIVAS.
    INSERT INTO "informix".paso_can_sol_nuncas
	SELECT LIMIT iTotalRegistros a.num_credito,
	TRIM(NVL(g.nombre1,'')) ||' '||
					 TRIM(NVL(g.nombre2,'')) ||' '||
					 TRIM(NVL(g.apell_paterno,'')) ||' '||
					 TRIM(NVL(g.apell_materno,'')) AS nombre_cte,
	b.monto_otorgado AS linea_credito,
	b.sdo_cap_insoluto AS saldo_fecha_cancelacion,
	c.fecha_ultimo_pago AS fecha_ultimo_pago,
	c.fecha_ultima_compra AS fecha_ultima_disposicion,
	d.expiracion AS fecha_vencimiento_plastico,
	d.status_tar AS estatus_plastico,
	a.sucursal AS numero_sucursal,
	'I' AS marca
	  FROM bdicred:sd_maecred a
	INNER JOIN bdicred:sd_maesdos b ON (b.num_credito = a.num_credito AND b.empresa = a.empresa AND b.sdo_retenido = 0 AND (b.sdo_capital between iSaldoAFavorMax and 0) AND (b.sdo_cap_insoluto between iSaldoAFavorMax and 0)) 
	INNER JOIN bdicred:sd_indicador_cred c ON (c.num_credito = a.num_credito AND c.empresa = a.empresa AND (fecha_ultimo_pago > DATE(1) OR fecha_ultima_compra > DATE(1))
		AND dtFechaCompara >= (CASE WHEN NVL(fecha_ultimo_pago,DATE(1)) > NVL(fecha_ultima_compra,DATE(1)) THEN NVL(fecha_ultimo_pago,DATE(1)) ELSE NVL(fecha_ultima_compra,DATE(1)) END))
	LEFT OUTER JOIN bdiaclaracion:"informix".acl_aclaracion e ON (e.num_cliente = a.numcte AND e.fky_estatus_aclaracion = '2')
	INNER JOIN bdicred:sd_tarjeta d ON (
	d.empresa = a.empresa AND d.numcte = a.numcte AND d.num_credito = a.num_credito AND d.tipo_tarjeta = 'T' 
	AND d.secuencia = (SELECT MAX(f.secuencia) FROM bdicred:sd_tarjeta f WHERE f.empresa = d.empresa AND f.numcte= a.numcte and d.num_credito = a.num_credito AND f.tipo_tarjeta = 'T'))
	INNER JOIN bdinteg:si_cliente g ON (g.numcte = a.numcte)
	WHERE a.num_credito = b.num_credito
	   AND a.empresa = b.empresa
	   AND a.status_cred IN ('AA','E1')
	   AND (b.monto_vencido + b.mto_venc_trasp) = 0
	   AND a.num_producto = cProducto --'6001'
	   AND e.fky_estatus_aclaracion IS NULL
	   AND d.expiracion < dtFechaHoy;
	
  --UPDATE STATISTICS HIGH FOR TABLE "informix".paso_can_sol_nuncas; 
CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'TERMINA OBTENCION CTAS INACTIVAS A CANCELAR', '02') Returning cCodRetIB;

CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'INICIA OBTENCION CTAS NUNCAS A CANCELAR', '02') Returning cCodRetIB;   
--- Variables de inicio para cuentas NUNCAS.
SELECT TRIM(valor)::INTEGER 
		INTO iTotalCtasNunca --10000
		FROM bdicred:sd_param 
		WHERE empresa = '001' 
		AND cod_param = '188';
		
 	IF NVL(iTotalCtasNunca,0) = 0 THEN
		LET cCodRet = '000007';
		LET cMensajeRet = 'El parametro del contador de cuentas nunca no es valido';
		RETURN cCodRet,cMensajeRet;
	END IF;  
  
--- Llena la tabla bdicred:paso_can_sol_nuncas con la informacion de cuentas NUNCAS.  
INSERT INTO "informix".paso_can_sol_nuncas
	SELECT LIMIT iTotalCtasNunca a.num_credito,
	TRIM(NVL(g.nombre1,'')) ||' '||
			TRIM(NVL(g.nombre2,'')) ||' '||
			TRIM(NVL(g.apell_paterno,'')) ||' '||
			TRIM(NVL(g.apell_materno,'')) AS nombre_cte,
	b.monto_otorgado AS linea_credito,
	b.sdo_cap_insoluto AS saldo_fecha_cancelacion,
	c.fecha_ultimo_pago AS fecha_ultimo_pago,
	c.fecha_ultima_compra AS fecha_ultima_disposicion,
	d.expiracion AS fecha_vencimiento_plastico,
	d.status_tar AS estatus_plastico,
	a.sucursal AS numero_sucursal,
	'N' AS marca
	  FROM bdicred:sd_maecred a
	INNER JOIN bdicred:sd_maesdos b ON (b.num_credito = a.num_credito AND b.empresa = a.empresa AND b.sdo_retenido = 0 AND (b.sdo_capital between iSaldoAFavorMax and 0) AND (b.sdo_cap_insoluto between iSaldoAFavorMax and 0)) 
	INNER JOIN bdicred:sd_indicador_cred c ON (c.num_credito = a.num_credito AND c.empresa = a.empresa AND nvl(c.f_primer_compra, date(1)) = date(1) AND nvl(c.f_primer_disp, date(1)) = date(1) AND nvl(c.fecha_ultimo_pago, date(1)) = date(1)
	AND dtFechaCompara >= NVL(c.fecha_alta,DATE(1)))
	LEFT OUTER JOIN bdiaclaracion:"informix".acl_aclaracion e ON (e.num_cliente = a.numcte AND e.fky_estatus_aclaracion = '2') 
	INNER JOIN bdicred:sd_tarjeta d ON (
	d.empresa = a.empresa AND d.numcte = a.numcte AND d.num_credito = a.num_credito	AND d.tipo_tarjeta = 'T'  
	AND d.secuencia = (SELECT MAX(f.secuencia) FROM bdicred:sd_tarjeta f WHERE f.empresa = d.empresa AND f.numcte= a.numcte and d.num_credito = a.num_credito AND f.tipo_tarjeta = 'T'))
	INNER JOIN bdinteg:si_cliente g ON (g.numcte = a.numcte)
	 WHERE a.num_credito = b.num_credito
	   AND a.empresa = b.empresa
	   AND a.status_cred IN ('AA','E1') 
	   AND (b.monto_vencido + b.mto_venc_trasp) = 0
	   AND a.num_producto = cProducto--'6001'
	   AND e.fky_estatus_aclaracion IS NULL 
	   AND d.expiracion < dtFechaHoy;
 
 UPDATE STATISTICS MEDIUM FOR TABLE "informix".paso_can_sol_nuncas;

CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'TERMINA OBTENCION CTAS INACTIVAS A CANCELAR', '02') Returning cCodRetIB;

CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'INICIA CANCELACION CUENTAS INACTIVAS', '02') Returning cCodRetIB;
------------------------------
--Se insertan valores a la tabla bdimnsj:mnsjr_trx_batch para mandar el aviso de cancelacion del credito al usuario 

										--------------------------------------------------------------
										---------------------------S M S -----------------------------
										--------------------------------------------------------------
	LET cNom_Cte = '';
	LET cNom_Producto = '';
	LET cNum_Tarjeta = '';
	LET dFechaRegistro = dtFechaHoy;
	LET pNumCel = 0;
	LET COD_RET = '';
	
	FOREACH WITH HOLD
	
	SELECT a.nombre_cte,d.nombre_prod,SUBSTR(t.num_tarjeta,13,4) num_tarjeta,tel.telefono
	INTO cNom_Cte,cNom_Producto,cNum_Tarjeta,pNumCel
	FROM "informix".paso_can_sol_nuncas as a
	INNER JOIN bdicred:sd_tarjeta as t ON t.num_credito = a.num_credito
	INNER JOIN bdicred:sd_definicion as d ON d.num_producto = t.prodtarjeta
	INNER JOIN bdinteg:si_telefonos_actual as tel ON tel.numcte = t.numcte
	WHERE tel.movil_fijo = 0 AND tel.tipo_tel = 2  
	AND tel.cofetel = 'V'   AND tel.status_tel = 'A'
	group by a.nombre_cte,d.nombre_prod,num_tarjeta,tel.telefono
	
	BEGIN WORK; 
			
	CALL bdimnsj:"informix".sp_registra_evento(1,'PROD_SMS','CANTJ_SMS','000000000','', '',2, cNom_Cte, cNom_Producto, cNum_Tarjeta, ''
												, '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, dFechaRegistro, '')RETURNING COD_RET;
	
	COMMIT WORK;
	
	END FOREACH;

										--------------------------------------------------------------
										---------------------------CORREO-----------------------------
										--------------------------------------------------------------
							
	LET cNom_Cte = '';
	LET cNom_Producto = '';
	LET cNum_Tarjeta = '';
	LET dFechaRegistro = dtFechaHoy;
	LET cCorreo = 0;
	LET COD_RET = '';

	FOREACH WITH HOLD
	
	SELECT a.nombre_cte,d.nombre_prod,SUBSTR(t.num_tarjeta,13,4) num_tarjeta,sc.correo_elec
	INTO cNom_Cte,cNom_Producto,cNum_Tarjeta,cCorreo
	FROM "informix".paso_can_sol_nuncas as a
	INNER JOIN bdicred:sd_tarjeta as t ON t.num_credito = a.num_credito
	INNER JOIN bdicred:sd_definicion as d ON d.num_producto = t.prodtarjeta
	INNER JOIN bdinteg:si_correos as sc ON sc.numcte = t.numcte
	WHERE sc.status_correo = 'A' 
	group by a.nombre_cte,d.nombre_prod,num_tarjeta,sc.correo_elec
	
	BEGIN WORK; 
	
	CALL bdimnsj:"informix".sp_registra_evento(2,'PROD_EMAIL','CANTJ_EMAIL','000000000','', '',2, cNom_Cte, cNom_Producto, cNum_Tarjeta
										, '', '', '', '', '', '', '', cCorreo,'', 0, 0,0, 0, 0, dFechaRegistro, '')RETURNING COD_RET;
	COMMIT WORK;
			
	END FOREACH;
--/*//*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/

--- Cancela cuentas INACTIVAS. 
  FOREACH WITH HOLD     
	  SELECT num_credito
		INTO cNumCred
		FROM "informix".paso_can_sol_nuncas
		WHERE num_credito IS NOT NULL AND marca='I' 
	
-- Inicio RQM 10 703-3
-- Realiza movimiento para cancelacion de Saldo a favor		
	/* LÃ?Â³gica para cancelaciÃ?Â³n de saldo a favor */
	SELECT num_credito, saldo_fecha_cancelacion
			INTO vNumCred, vSaldo
		FROM "informix".paso_can_sol_nuncas
	WHERE num_credito = cNumCred; 

	IF vSaldo < 0 THEN

		--EXECUTE PROCEDURE "informix".genmov(pEmpresa,vNumCred,cProducto,118,'002',dtFechaHoy,vSaldo,"SaldoAFavorInact",'9290',cDivisa,'cSucursal') --9290 - generica
		--	INTO cCodRetGM, cMensaje;					
		--END IF;	

        EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina('92579841')
				INTO cCodRet2, cFolioSuc2;

        -- VALIDA QUE NO HAYA TENIDO ERROR LA GENERACÃ?N DEL FOLIO NOMINA.
        IF cCodRet2::INTEGER <> 0 THEN
            LET cCodRet = '000010';
            LET cMensajeRet = 'Error en la generacion del folio';
            RETURN cCodRet,cMensajeRet;
        END IF;
                                                                                                                                     
        EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, '9290','92579841','8309',abs(vSaldo),cFolioSuc2,'',	0,'0',TODAY,'CARGO POR CANC SALDO A FAVOR CTAS INACT','','')
        INTO cCodRet3;
        IF cCodRet3::INTEGER <> 0 THEN
            LET cCodRet = '000011';
            LET cMensajeRet = 'Error al realizar el cargo';
            RETURN cCodRet,cMensajeRet;
		END IF;	
-- Fin RQM 10 703-3
		
			EXECUTE PROCEDURE "informix".sp_cancelarcredito(pEmpresa,cNumCred,'4',"92579841","92579841","4","9290")
			INTO cCodRetAux, cFolioSucAux; 
			
			IF cCodRetAux::INTEGER <> 0 THEN
			   DELETE FROM "informix".paso_can_sol_nuncas WHERE num_credito = cNumCred;
			END IF;				
    END IF;
  END FOREACH

  CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'TERMINA CANCELACION CUENTAS INACTIVAS', '02') Returning cCodRetIB;
  
IF dbinfo("sqlca.sqlerrd2") = 0 THEN
	LET cCodRet = '000006';
	LET cMensajeRet = 'No hay creditos por cancelar';

	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'ERROR EN CANCELACION CUENTAS INACTIVAS', '02') Returning cCodRetIB;

ELSE

	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'INICIA CANCELACION CUENTAS NUNCAS', '02') Returning cCodRetIB;
END IF;	

--- Cancela cuentas NUNCAS. 
   FOREACH WITH HOLD     
	SELECT num_credito, numero_sucursal, saldo_fecha_cancelacion
		INTO cNumCred, cSucursal, vSaldo
		FROM "informix".paso_can_sol_nuncas
		WHERE num_credito IS NOT NULL AND marca='N' 	

	SELECT a.divisa
		INTO cDivisa
		FROM bdicred:sd_maecred a
		WHERE a.num_credito = cNumCred;
		
	SELECT monto, codigo_fun
		INTO cMonto, cCod_fun
		FROM bdicred:sd_movhis_calif
		WHERE num_credito = cNumCred
		AND codigo_fun = '091'
		AND fecha_mov = (select max(fecha_mov) from "informix".sd_movhis_calif WHERE num_credito = cNumCred);
		
	SELECT monto, codigo_fun
		INTO cMonto_2, cCod_fun_2
		FROM bdicred:sd_movhis_calif
		WHERE num_credito = cNumCred
		AND codigo_fun = '090'
		AND fecha_mov = (select max(fecha_mov) from "informix".sd_movhis_calif WHERE num_credito = cNumCred);
		
-- Inicio RQM 10 703-3
-- Realiza movimiento para cancelacion de Saldo a favor		
		/* LÃ?Â³gica para cancelaciÃ?Â³n de saldo a favor */
	SELECT num_credito, saldo_fecha_cancelacion
			INTO vNumCred, vSaldo
		FROM "informix".paso_can_sol_nuncas
	WHERE num_credito = cNumCred; 

	IF vSaldo < 0 THEN
		--EXECUTE PROCEDURE "informix".genmov(pEmpresa,vNumCred,cProducto,118,'002',dtFechaHoy,vSaldo,"SaldoAFavorNunca",'9290',cDivisa,'cSucursal') --9290 - generica
		--	INTO cCodRetGM, cMensaje;					
		--END IF;	
-- Fin RQM 10 703-3
        EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina('92579841')
				INTO cCodRet2, cFolioSuc2;

        -- VALIDA QUE NO HAYA TENIDO ERROR LA GENERACÃ?N DEL FOLIO NOMINA.
            IF cCodRet2::INTEGER <> 0 THEN
                LET cCodRet = '000010';
                LET cMensajeRet = 'Error en la generacion del folio';
                RETURN cCodRet,cMensajeRet;
            END IF

            EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, '9290','92579841','8309',abs(vSaldo),cFolioSuc2,'',	0,'0',TODAY,'CARGO POR CANC SALDO A FAVOR CTAS INACT','','')
            INTO cCodRet3;
            IF cCodRet3::INTEGER <> 0 THEN
                LET cCodRet = '000011';
                LET cMensajeRet = 'Error al realizar el cargo';
                RETURN cCodRet,cMensajeRet;
            END IF
       END IF;

-- Se realiza cancelacion de Cuentas Nunca RQM 10 703-2 
   -- ******** Libera los Montos de Reservas *********
			IF cCod_fun IS NOT NULL THEN
			EXECUTE PROCEDURE "informix".genmov(pEmpresa,cNumCred,cProducto,20,cCod_fun,dtFechaHoy,cMonto,"LibCalifCart",'9290',cDivisa,'cSucursal')
				INTO cCodRetGM, cMensaje;
			END IF;
			
			IF cCod_fun_2 IS NOT NULL THEN
			EXECUTE PROCEDURE "informix".genmov(pEmpresa,cNumCred,cProducto,20,cCod_fun_2,dtFechaHoy,cMonto_2,"LibCalCartReserv",'9290',cDivisa,'cSucursal')
			INTO cCodRetGM, cMensaje;
			END IF;
					
			-- ******** Cancela el Credito ********
			EXECUTE PROCEDURE "informix".sp_cancelarcredito(pEmpresa,cNumCred,'6','92579841','92579841','6','9290')
			INTO cCodRetAux, cFolioSucAux; 
			
			
			LET cCodRetAux=0;
			IF cCodRetAux::INTEGER <> 0 THEN
			   DELETE FROM "informix".paso_can_sol_nuncas WHERE num_credito = cNumCred;
			END IF;	
--	END IF;		
  END FOREACH
  
CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'TERMINA CANCELACION CUENTAS NUNCAS', '02') Returning cCodRetIB; 


 
IF dbinfo("sqlca.sqlerrd2") = 0 THEN
	LET cCodRet = '000009';
	LET cMensajeRet = 'No hay creditos por cancelar';
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'ERROR CANCELACION CUENTAS NUNCAS', '02') Returning cCodRetIB; 	

ELSE
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'INCIA GENERACION DE ARCHIVO', '02') Returning cCodRetIB;
	
	
--- ARCHIVO CUENTAS INACTIVAS ---	
	LET cFechaGenArchivo =  to_char(dtFechaHoy,'%m%Y');	
	LET cnomarchivo1 = TRIM(cnombrefinal)||TRIM(cFechaGenArchivo)||'_Aux_'||'.txt ';
    LET cnomarchivo =  TRIM(cnombrefinal)||TRIM(cFechaGenArchivo)||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_Rep_Inactivas' || '.sql';
	    

    LET cSQL='';
    LET cSQL = 'echo "Numero de cuenta'||'|'||'Nombre del cliente'||'|'||'Linea de Credito'||'|'||'Saldo a la fecha de cancelacion'||'|'||'Fecha de ultimo pago'||'|'||'Fecha de ultima transaccion(compra o disposicion)'
               ||'|'||'Fecha vencimiento de ultimo plastico relacionado'||'|'||'Estatus del plastico(Activo/Inactivo)'
               ||'|'||'Numero de Sucursal'||'|'||'Marca'||' " >' || TRIM(cruta) || TRIM(cnomarchivo)||'';
    SYSTEM cSQL;
		
	LET cSQL1 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1);

     LET cSQL2 = " SELECT num_credito, nombre_cte, linea_credito, saldo_fecha_cancelacion,fecha_ultimo_pago, "
	        || " fecha_ultima_disposicion, fecha_vencimiento_plastico, "
            || " estatus_plastico, "
			|| " numero_sucursal, "
			|| " marca "
			|| " FROM bdicred:'informix'.paso_can_sol_nuncas " ;
		
			
    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoEjecSql;
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoEjecSql;
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    --Borra el archivo de control.
    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1;
    SYSTEM cSQL;	

	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCodRet, 'TERMINA GENERACION DE ARCHIVO', '02') Returning cCodRetIB;

END IF;
	RETURN cCodRet,cMensajeRet;
	END
	
END PROCEDURE


DOCUMENT 
'Se realiza procedimiento realizar la cancelaciÃ?Â?Ã?Â³n',
'clientes inactivas',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 22/JUNIO/2016',
'BD    : BDICRED',
'',
'Se agrega procedimiento realizar la cancelaciÃ?Â?Ã?Â³n',
'cuentas nunca',
'AUTOR : Angelica Daniella Lopez MuÃ?Â?Ã?Â±oz',
'FECHA : 30/SEPTIEMBRE/2017',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_carga_datos_upgrade() 
RETURNING CHAR(6);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cCod_Ret CHAR(6);
DEFINE cCadena  CHAR (500);
DEFINE cRuta CHAR (50);
DEFINE cUpg CHAR (50);
DEFINE cBitUpg CHAR (50);
DEFINE vnum_cred CHAR (20);
DEFINE vnum_cte CHAR (20);
DEFINE vnum_tarj CHAR (20);
DEFINE vtipo_tar CHAR (3);
DEFINE vnombre CHAR (106);
DEFINE vnombre_emb CHAR (21);
DEFINE vnum_prod CHAR (4);
DEFINE cmiembro CHAR (2);
DEFINE dtUpgIni DATETIME YEAR TO SECOND;
DEFINE dtUpgFin DATETIME YEAR TO SECOND;

DEFINE wBegin                CHAR(1);

LET iSqlErr = 0;
LET cCodRet = '000001';
LET cCod_Ret = '000000';
LET cCadena = '';
LET cRuta = '';
LET cUpg = '';
LET cBitUpg = '';
LET vnum_cred = '';
LET vnum_cte = '';
LET vnum_tarj = '';
LET vtipo_tar = '';
LET vnombre = '';
LET vnombre_emb = '';
LET vnum_prod = '';
LET cmiembro = '';
LET wBegin = '';
LET dtUpgIni = CURRENT;
LET dtUpgFin = CURRENT;


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
	END EXCEPTION;
   	
   SET LOCK MODE TO WAIT 3;

   --SET DEBUG FILE TO '/resplogifx/archivoscredito/sp_carga_datos_upgrade.out';
   --TRACE ON;

    LET cUpg="datosupgrade";
    LET cBitUpg="bitacoraupgrade";
    LET cRuta="/resplogifx/archivoscredito/";                                                    
 
	
	IF NVL(cRuta,'') <> '' THEN
			IF NVL(cUpg,'') <> '' THEN

				LET dtUpgIni = CURRENT;
				LET cUpg = TRIM(cUpg)||'_'||YEAR(dtUpgIni)||LPAD(MONTH(dtUpgIni),2,0)||LPAD(DAY(dtUpgIni),2,0)||'.txt';                
                LET cBitUpg= TRIM(cBitUpg)||'_'||YEAR(dtUpgIni)||LPAD(MONTH(dtUpgIni),2,0)||LPAD(DAY(dtUpgIni),2,0)||'.txt'; 

				
				TRUNCATE TABLE sd_carga_upgrade;
				LET cCadena = '/usr/bin/echo "LOAD FROM ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cUpg,1,LENGTH(cUpg)) ||'''  delimiter ''|'' INSERT INTO bdicred:"informix".sd_carga_upgrade" >' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_upgrade.sql';
                SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/ifxsif01/bin/dbaccess bdicred ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_upgrade.sql';
				system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_upgrade.sql';
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/usr/bin/rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_upgrade.sql';
                system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_upgrade.sql';
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));                

				LET cCodRet = '000000';
			ELSE
				LET cCodRet = '000002';
			END IF;
            
            IF cCodRet = '000000' THEN 
                FOREACH WITH HOLD
                    SELECT num_credito, num_cte, num_tarjeta, tipo_tar, nombre, nombre_embosado, num_producto
                    INTO vnum_cred, vnum_cte, vnum_tarj, vtipo_tar, vnombre, vnombre_emb, vnum_prod
                    FROM sd_carga_upgrade                  
                    
                    IF NOT EXISTS ( SELECT num_credito  FROM "informix".sd_credito_upgrade
                        WHERE num_credito = vnum_cred and numcte = vnum_cte) THEN
						
						IF (SELECT status_cred FROM sd_maecred WHERE num_credito=vnum_cred ) IN ('AA','E1') THEN 
							IF (SELECT NVL(monto_vencido + mto_venc_trasp,0) FROM sd_maesdos WHERE num_credito=vnum_cred ) = 0 THEN 

								IF (SELECT sdo_retenido FROM sd_maesdos WHERE num_credito=vnum_cred)=0 THEN
									SELECT substr(YEAR(fecha_apertura),3,2)
									INTO cmiembro
									FROM bdicred:"informix".sd_maecred
									WHERE num_credito = vnum_cred;

									INSERT INTO  "informix".sd_credito_upgrade (empresa ,num_credito,numcte ,numerotarjeta ,numero_credito_upgrade, numerotarjeta_upgrade, num_producto_upgrade,tipoTar ,nombre,nombre_embosado ,bandtarjpersonal,tipo_proceso, nombre_archivo,master ,Tipo_dom,miembro,Resultado,bclonadocompleto,user_insert ,fecha_insert)
																		VALUES ('001' ,vnum_cred ,vnum_cte, vnum_tarj, "","",vnum_prod,vtipo_tar ,vNombre ,vnombre_emb, '1','1','','1' , '3' ,cmiembro,"0","0", 'informix' ,CURRENT);

									UPDATE "informix".sd_carga_upgrade SET cod_ret='000000', descripcion='Upgrade Exitoso' WHERE num_credito=vnum_cred AND num_cte= vnum_cte;
									
								ELSE --CREDITO CON SALDO RETENIDO
									UPDATE "informix".sd_carga_upgrade SET cod_ret='000001', descripcion='Credito con saldo Retenido' WHERE num_credito=vnum_cred AND num_cte= vnum_cte;
									 
								END IF;
							ELSE -- CREDITO NO VIGENTE
								UPDATE "informix".sd_carga_upgrade SET cod_ret='000002', descripcion='Credito no Vigente' WHERE num_credito=vnum_cred AND num_cte= vnum_cte;

							END IF;
                        ELSE -- CREDITO NO VIGENTE
                            UPDATE "informix".sd_carga_upgrade SET cod_ret='000002', descripcion='Credito no Vigente' WHERE num_credito=vnum_cred AND num_cte= vnum_cte;
                                
                        END IF;
					ELSE-- YA EXISTE UPGRADE
						UPDATE "informix".sd_carga_upgrade SET cod_ret='000003', descripcion='Ya existe la solicitud de Upgrade para este Credito' WHERE num_credito=vnum_cred AND num_cte= vnum_cte;
                           
                    END IF;
                END FOREACH 
				  
	
                LET cCadena = '';
				LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitUpg)  ||'  delimiter ''|'' SELECT num_credito,num_cte,num_tarjeta,cod_ret,descripcion FROM bdicred:"informix".sd_carga_upgrade" >'||TRIM(cRuta)||'bit_upgrade.sql';
				SYSTEM cCadena;				
				LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_upgrade.sql';
				System cCadena;				
				let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_upgrade.sql';
				System cCadena;				
				LET cCadena = '' ;
				LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_upgrade.sql';
				SYSTEM cCadena;

            END IF; 
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 05/SEP/2017',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_carteral_ppyr()
RETURNING CHAR(6);
--Creado por: maria elizabeth anzures ibarguen
--28-12-2011
--Proceso para la generacion de archivo cartera total prestamo personal y reestructura

--Modificado por: Jorge Tirado Villa
--12-05-2017
--Se aniadio los scoring de originacion al reporte mensual Cartera_totalddmmaaaa.txt 

--Modificado por: PAUL IVAN QUINTERO VARELA
--29-06-2017
--Se agrego el campo para el flag indicativo del segundo producto

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_ret2			CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE  vproceso			CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE pfechacorte date;
DEFINE Vult_dia_mes DATE;
--Structura
DEFINE Vcreditoexterno          char(20);
DEFINE Vproducto     		char(4);
DEFINE Vnum_credito         char(20);
DEFINE  Vnumcte				char(20);
DEFINE Vnum_tarjeta         char(20);
DEFINE Vnum_sucursal		char(4);
DEFINE  Vnom_suucursal		char(40);
DEFINE  Vingreso_mensual    money;
DEFINE  Vmonto_apertura      decimal(18,2); 
DEFINE  Vfecha_apertura      date;

DEFINE  Vplazo smallint;
DEFINE Vestatus char (2);
DEFINE  Vsaldo_insoluto	decimal(18,2);
DEFINE  Vcapital_vigente	decimal(18,2);
DEFINE Vcapital_transitorio	decimal(18,2);
DEFINE Vsaldo_vencido_exigible	decimal(18,2);
DEFINE Vsaldo_vencido_no_exigible	decimal(18,2);
DEFINE Vsaldo_actual decimal(18,2); 
DEFINE  Vsaldo_cierre decimal(18,2); 
DEFINE Vmes_vencido decimal(18,2); 
DEFINE Vtipo_mov cHAR (1);
DEFINE Vfecha_mov DATE;

DEFINE Vsexo char (1);
DEFINE Vfecha_nac date;
DEFINE Vnombre1 char(26);
DEFINE Vnombre2 char(26);
DEFINE Vapellido_p char(26);
DEFINE Vapellido_m char(26);
DEFINE Vmail char (60);
DEFINE Vdir_calle char(30);
DEFINE Vdir_numero char(20);
DEFINE Vdir_colonia char(32);
DEFINE Vcp char(5);

DEFINE Vdir_municipio char(60);
DEFINE Vnum_estado smallint;
DEFINE Vdir_estado char(30);
DEFINE Vnum_cd_coppel smallint;
DEFINE Vcd_coppel char(32);
DEFINE Vnum_cd_banco smallint;
DEFINE  Vcd_banco char(32);
DEFINE Vtel1 char(13);
DEFINE  Vtel2 char(13);
DEFINE Vtel3 char(13);
DEFINE Vext char(5);

DEFINE Vref_coppel char(20);
DEFINE Vficiencia decimal(5,2);
DEFINE Vmeses_historia smallint;
DEFINE Vhit char(6);
DEFINE Vsecc1 char (4);
DEFINE Vsecc2 decimal(10,4);
DEFINE sPaso integer;
DEFINE vlNumInsert SMALLINT;
DEFINE Vpri_dia_mes DATE;

	  --variables
DEFINE Vnumcreditortc       char(20);
DEFINE VcreditoConsulta       char(20);
DEFINE Vnumcuentartc      	char(20);
DEFINE Vnumtarjetatdc       char(20);
--DEFINE Vnumcte        		char(20);
DEFINE Vnumsucursal     	char(4);
DEFINE Vnumciudad			char(4);
DEFINE Vsaldoactual      	decimal(18,2);
DEFINE Vinteres       		decimal(18,2);
DEFINE Vsaldovencido     	decimal(18,2);
DEFINE Vinteresvencido   	decimal(18,2);
DEFINE vinteres_moratorio	decimal(18,2);
DEFINE Vabonobase			decimal(18,2);
DEFINE Vabonosvencidos		smallint;
DEFINE Vestadocredito		char(2);
DEFINE Vplazortc			smallint;
DEFINE Vtasainteres			decimal(18,2);
DEFINE Vfechalimitedepago	date;
DEFINE Vfechaultmov			date;
DEFINE Vtipoultimomov		char(2);
DEFINE Vfechacorte			date;
define cNombreArchivo		char(70);
define cNombreArchivo2		char(70);
define cNombreArchivoNvo	char(70);
--define sPaso				integer;
--define cempresa				char(3);
define Vprod				char(4);
define vmontor1				decimal(18,2);
define vmontor2				decimal(18,2);
DEFINE cMotivo	char(5);
-- RQM 09 440
DEFINE VsaldoCapital		decimal(18,2);
DEFINE VsaldoTrasp			decimal(18,2);
DEFINE VvenciNoExig			decimal(18,2);
DEFINE VvenciExig			decimal(18,2);
DEFINE VintVigente			decimal(18,2);
DEFINE VintVencido			decimal(18,2);
DEFINE VintVenc28			decimal(18,2);
DEFINE VintVenc29			decimal(18,2);
DEFINE VintVenc30			decimal(18,2);
DEFINE VintVenc31			decimal(18,2);

DEFINE dBcScore DECIMAL(5,2);
DEFINE dScoreProp DECIMAL(5,2);
DEFINE dFico DECIMAL(5,2);
DEFINE dFicoExtended DECIMAL(5,2);
DEFINE dIcc DECIMAL(5,2);
DEFINE v_selectcredito char(20);
DEFINE cFlag2Credito   VARCHAR(120,1);
DEFINE cStatus_Ini CHAR(2);
DEFINE cRevisado CHAR(2);
DEFINE cIdbox smallint;
DEFINE cIfe CHAR(2);
DEFINE dFechaVencto	DATE;
DEFINE cGrupo	CHAR(01);
DEFINE sMesesVencidos SMALLINT;
DEFINE sNumPagos	SMALLINT;
DEFINE dMontoPagos	decimal(18,2);
DEFINE dFechaVencido DATE;

--Inicializacion de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_Ret2                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso	            = '2060';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre		    = "";
LET cnomarchivo             = "";
LET cnomarchivo1            = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = ";";
LET cCod_RetIB              = "000000";
LET pfechacorte = date(1);
LET Vult_dia_mes = DATE(1);
LET Vpri_dia_mes = DATE(1);

-----VARIABLES
LET Vcreditoexterno = '';
LET Vproducto     		='';
LET Vnum_credito         = '';
LET VcreditoConsulta         = '';
LET  Vnumcte				='';
LET Vnum_tarjeta         ='';
LET Vnum_sucursal		='';
LET  Vnom_suucursal		='';
LET  Vingreso_mensual    = 0;
LET  Vmonto_apertura      = 0;
LET  Vfecha_apertura     = date(1);

LET  Vplazo = 0;
LET Vestatus ='';
LET  Vsaldo_insoluto	= 0;
LET  Vcapital_vigente	= 0;
LET Vcapital_transitorio	= 0;
LET Vsaldo_vencido_exigible	= 0;
LET Vsaldo_vencido_no_exigible	= 0;
LET Vsaldo_actual = 0;
LET  Vsaldo_cierre = 0;
LET Vmes_vencido = 0;
LET Vtipo_mov ='';
LET Vfecha_mov = DATE(1);

LET Vsexo ='';
LET Vfecha_nac = date(1);
LET Vnombre1 ='';
LET Vnombre2 ='';
LET Vapellido_p ='';
LET Vapellido_m ='';
LET Vmail ='';
LET Vdir_calle ='';
LET Vdir_numero ='';
LET Vdir_colonia ='';
LET Vcp = '';

LET Vdir_municipio ='';
LET Vnum_estado = 0;
LET Vdir_estado ='';
LET Vnum_cd_coppel= 0;
LET Vcd_coppel ='';
LET Vnum_cd_banco = 0;
LET  Vcd_banco ='';
LET Vtel1 ='';
LET  Vtel2 ='';
LET Vtel3 ='';
LET Vext ='';

LET Vref_coppel ='';
LET Vficiencia = 0;
LET Vmeses_historia = 0;
LET Vhit ='';
LET Vsecc1 = '';
LET Vsecc2 = 0;
LET  sPaso = 0;
LET vlNumInsert = 0;

	  --variables
LET	Vnumcreditortc			= '';
LET Vnumcuentartc			= '';
LET	Vnumtarjetatdc			= '';
--LET	Vnumcte           	    = '';
LET	Vnumsucursal			= 0;
LET	Vnumciudad	            = '';
LET Vsaldoactual			= 0;
LET Vinteres                = 0;
LET Vsaldovencido           = 0;
LET Vinteresvencido         = 0;
LET Vabonobase              = 0;
LET Vabonosvencidos         = 0;
LET vinteres_moratorio		= 0;
LET Vestadocredito          = 0;
LET Vplazortc      			= 0;
LET Vtasainteres   		    = 0;
LET Vfechalimitedepago      = DATE(1);
LET	Vfechaultmov            = DATE(1);
LET Vtipoultimomov          = '';
LET Vfechacorte             = DATE(1);
let cempresa 				= '001';
let Vprod					='';
let vmontor1				= 0;
let vmontor2				= 0;
LET cMotivo = '';
-- RQM 09 440
LET VsaldoCapital			= 0;
LET VsaldoTrasp				= 0;
LET VvenciNoExig			= 0;
LET VvenciExig				= 0;
LET VintVigente				= 0;
LET VintVencido				= 0;
LET VintVenc28				= 0;
LET VintVenc29				= 0;
LET VintVenc30				= 0;
LET VintVenc31				= 0;

LET dScoreProp = "";
LET dBcScore = "";
LET dFico = "";
LET dFicoExtended = "";
LET dIcc  = "";
let  v_selectcredito = "";
LET cFlag2Credito = "" ;
LET cStatus_Ini = "";
LET cRevisado = "";
LET cIdbox = 0;
LET cIfe = "";
LET dFechaVencto = DATE(1);
LET cGrupo = '';
LET sMesesVencidos	= 0;
LET sNumPagos = 0;
LET dMontoPagos = 0;
LET dFechaVencido = DATE(1);


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02') returning cCod_ret2;
        RETURN cCod_ret;
	END EXCEPTION;

--	SET DEBUG FILE TO "CATERA_PPyR.out";
--	TRACE ON;


	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
	
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 26;
	
	--Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
        Return cCod_Ret;
	END IF;
	
		
	select trim(valor_alfabetico) into cruta
	from bdicobranza:cb_param_campania 
	where tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 36;
	
	--Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
        Return cCod_Ret;
	END IF;
	
	-------------------------------GENERA TABLA-------------------------------------
		
	--DROP TABLE sd_cartera_total_PPyR;
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'sd_carteral_ppyr';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_carteral_ppyr;
            END IF;

					
    create table "informix".sd_carteral_ppyr
    ( 
	producto     		char(4),
    num_credito         char(20),
	numcte				char(20),
	num_tarjeta         char(20),
	num_sucursal		char(4),
	nom_suucursal		char(40),
	ingreso_mensual     money,
	monto_apertura      decimal(18,2), 
	fecha_apertura      date default '01/01/1900',
	 
	plazo smallint,
	estatus char (2),
	saldo_insoluto	decimal(18,2),
	capital_vigente	decimal(18,2),
	capital_transitorio	decimal(18,2),
	saldo_vencido_exigible	decimal(18,2),
	saldo_vencido_no_exigible	decimal(18,2),
	saldo_actual decimal(18,2), 
	saldo_cierre decimal(18,2), 
	--mes_vencido decimal(18,2), 
	mes_vencido integer,
	tipo_mov cHAR (1),
	fecha_mov DATE,
	 
	sexo char (1),
	fecha_nac date,
	nombre1 char(26),
	Nombre2 char(26),
	apellido_p char(26),
	apellido_m char(26),
	mail char (60),
	dir_calle char(30),
	dir_numero char(20),
	dir_colonia char(32),
	cp char(5),
	 
	dir_municipio char(60),
	num_estado smallint,
	dir_estado char(30),
	num_cd_coppel smallint,
	cd_coppel char(32),
	num_cd_banco smallint,
	cd_banco char(32),
	tel1 char(13),
	tel2 char(13),
	tel3 char(13),
	ext char(5),
	 
	ref_coppel char(20),
	eficiencia decimal(5,2),
	meses_historia smallint,
	hit char(6),
	secc1 decimal(5,2),
	secc2 decimal(10,4),
	motivo CHAR(5),
	bc_score decimal(5,2),
	score_prop decimal(5,2),
	fico decimal(5,2),
	fico_extended decimal(5,2),
	icc decimal(5,2),
	flag2credito VARCHAR(120,1),
	status CHAR(2),
	revisado CHAR(2),
	ife CHAR(2),
	grupo CHAR(1),
	meses_vencidos SMALLINT,
	num_pagos SMALLINT,
	monto_pagos DECIMAL(18,2)
	);
	
		
	SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_pagosydisposicionescrd_cartera';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_pagosydisposicionescrd_cartera;
            END IF;


    create table sd_pagosydisposicionescrd_cartera
    (
	num_producto	char(4),
    numcreditortc	char(20) default '0',
    numcreditotdc	char(20) default '0',
    numcuentartc	char(20) default '0',
	numtarjetatdc   char(20) default '0',
	numcte          char(20),
	numsucursal     char(4),
	numciudad		char(4),
    fechareestructura   date,
    saldoactual     decimal(18,2),
    interes       	decimal(18,2),
    saldovencido    decimal(18,2),
    interesvencido  decimal(18,2),
	interes_moratorio	decimal(18,2),
    abonobase           decimal(18,2),
    abonosvencidos      smallint,
    estadocredito       char(2),
    plazortc    		smallint,
    tasainteres    		decimal(18,2),
    fechalimitedepago 	date,
	fechaultmov 		date,
    tipoultimomov		char(2),
    fechacorte          date,
	sdo_cap_vigente 			DECIMAL(18,2),
	sdo_cap_trasp_vigente 		DECIMAL(18,2),
	sdo_cap_noexig_vencido 		DECIMAL(18,2),
	sdo_cap_exig_vencido 		DECIMAL(18,2),
	sdo_int_vigente 			DECIMAL(18,2),
	sdo_int_vencido 			DECIMAL(18,2)
	);
	
	select max(fecha)
	into pfechacorte
	from bdicred:sd_maecredcontcrd
	where num_producto in ( '6011','6300','7600','7700');
	
	--Prueba de cartera
	--LET pfechacorte = mdy('03','31','2018');
	
	select empresa, num_credito, fecha_apertura, numcte , num_producto, credito_externo, sucursal, plazo, status_cred, tasa_interes, fecha
	from bdicred:sd_maecredcontcrd crd 
	where fecha =pfechacorte and empresa = '001'
	  and num_producto in ('6300','6011','7600','7700') and nvl(campo_trab3,'') <> 'BAJA'
	into temp CreditosCrd with no log;
	create index indx_creditos on CreditosCrd (num_credito );
			 update statistics medium for table CreditosCrd;
			 
	select crd.num_credito ,fecha_mov, codigo_fun, codigo_ref, monto
			from bdicred:sd_movhiscrd mov , CreditosCrd crd
			where 
              crd.num_credito = mov.num_credito
             and crd.fecha_apertura>=mov.fecha_mov 
              and ((codigo_fun = '338' and codigo_ref = 21 )
            or (codigo_fun = '338' and codigo_ref = 22 )
            or (codigo_fun   in ('020','021','022','023','024','025','027','028','222','225') and  codigo_ref = 1 )
            or (codigo_fun  = '001' and codigo_ref  in (3,4) )
            or ( codigo_fun  in ('001','002')  and codigo_ref in (1,2,66) ) )
			and reversado = 'N'             
			 into temp MovtosCred with no log;
			 create index indx_mov on MovtosCred (num_credito );
			 update statistics medium for table MovtosCred;
			 
	
		select num_credito num_solicitud,  nvl(ingreso_mensual,0) ingreso_mensual ,nvl(situacion_pago,0) situacion_pago ,nvl(meses_historia,0) meses_historia,
			DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit')	evalua_cc, grupo			
		--into Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit
		from CreditosCrd crd,bdisolic:ss_resum_scor_fin scor 
		where crd.empresa=scor.empresa
		  and crd.num_credito=scor.num_solicitud
		  --- Se agregan productos para corregir datos nullos en los campos Eficiencia y Meses historia.
		  and crd.num_producto in ('6300','7600','7700')
		  union 
		  select num_credito num_solicitud,  nvl(ingreso_mensual,0) ingreso_mensual ,nvl(situacion_pago,0) situacion_pago ,nvl(meses_historia,0) meses_historia,
			DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit')	evalua_cc, grupo			
		--into Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit
		from CreditosCrd crd,bdisolic:ss_resum_scor_fin scor 
		where crd.empresa=scor.empresa
		  and crd.credito_externo=scor.num_solicitud
		  and crd.num_producto ='6011'
		into temp scorfin with no log;
		create index indx_scor on scorfin (num_solicitud );
			 update statistics medium for table scorfin;
			 

		
	--------------------INSERTAR EN TABLA-----------------------------------
	
	 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Inicia Foreach', '02') returning cCod_ret2;

	FOREACH 
		select a.num_producto,a.num_credito,NVL(a.credito_externo,'0'),a.numcte,a.sucursal,suc.nombre,b.monto_otorgado ,NVL(a.fecha_apertura,DATE(1))
			, a.plazo, a.status_cred,b.sdo_cap_insoluto,b.sdo_capital,b.monto_vencido,b.mto_venc_trasp,b.cap_tras_no_venci, 
			nvl(b.mto_fin_ven_trasp,0),fecha_ult_pago,nvl(a.tasa_interes,0) ,NVL(c.prox_fecha_pago,'01/01/1900'),nvl(suc.ciudad,0),
			(CASE WHEN a.status_cred IN ('AA','BA','E1') THEN (sdo_intereses + sdo_no_exig) ELSE 0 END) ,
			(CASE WHEN a.status_cred NOT IN ('AA','BA','E1') THEN (sdo_intereses + sdo_no_exig + int_tra_no_exig) ELSE 0 END ), c.fecha_vencto
		into Vproducto ,  Vnum_credito,Vcreditoexterno  , Vnumcte,Vnum_sucursal,vnom_suucursal,vmonto_apertura,vfecha_apertura
			,vplazo,vestatus, vsaldo_insoluto,vcapital_vigente,vcapital_transitorio,vsaldo_vencido_exigible,vsaldo_vencido_no_exigible,
			vmes_vencido,Vfechaultmov,Vtasainteres,Vfechalimitedepago,Vnumciudad,
			Vinteres,Vinteresvencido,dFechaVencto
		from CreditosCrd a -- bdicred:sd_maecredcontcrd a
			inner join bdicred:sd_maesdoscontcrd b on (a.fecha = b.fecha and a.empresa = b.empresa and a.num_credito = b.num_credito)		
			left join bdinteg:si_sucursales suc on (suc.empresa = a.empresa and suc.sucursal = a.sucursal)					
			inner join bdicred:sd_maecredanexocrd  c on (c.num_credito = a.num_credito)
		 --where a.empresa ='001' and a.num_producto in ( '6011','6300')
		--and a.fecha = pfechacorte
		
		SELECT cte.numcte_ref,cte.nombre1, cte.nombre2, cte.apell_paterno  , cte.apell_materno,nvl(pf.sexo,''),nvl(pf.fecha_nac,'')
		INTO Vref_coppel,vnombre1 , vnombre2 ,vapellido_p ,vapellido_m,vsexo,vfecha_nac
		FROM  bdinteg:si_cliente cte 
		INNER JOIN bdinteg:si_ctepf pf on (pf.numcte = cte.numcte)
		WHERE cte.numcte = Vnumcte;
		
		SELECT first 1 ca.nombrecalle ,dir.numeroextcalle,zo.nombrezona,dir.cod_postal,cd.nombre as dir_mun,
		es.estado as num_estado,es.nombre as dir_estado,cd.ciudad_coppel as cd_coppel,cd.nombre ,
		zo.numerociudad as num_banco ,zo.poblacionzona as cd_banco
		INTO vdir_calle,vdir_numero,vdir_colonia,vcp
		,Vdir_municipio,  Vnum_estado ,Vdir_estado ,Vnum_cd_coppel ,Vcd_coppel ,Vnum_cd_banco ,Vcd_banco 
		FROM bdinteg:si_direcciones_actual dir  
		inner join bdinteg:si_catcalles ca on ( ca.numerocalle = dir.numerocalle)
		inner join bdinteg:si_catzonas zo on ( zo.numerociudad = dir.numerociudad   and zo.numerocolonia = dir.numerocolonia)
		inner join bdinteg:si_ciudades cd  on (cd.estado  = dir.estado  and  cd.ciudad = dir.ciudad)
		inner join bdinteg:si_estados es on (es.estado = dir.estado)
		WHERE dir.numcte = Vnumcte AND dir.tipo_dir = 1;
		
		SELECT nvl(cta.num_cta,0) 
		INTO Vnum_tarjeta 
		FROM bdicred:sd_ctascarg cta
		WHERE empresa ='001' 
		AND cta.num_credito = Vnum_credito;
		
		LET Vnumcuentartc = Vnum_tarjeta;	
		
		IF (Vproducto = '6011') THEN 				
			SELECT nvl(tar.num_tarjeta,0)
				INTO Vnumtarjetatdc 
			FROM bdicred:sd_tarjeta tar 
			WHERE tar.empresa ='001'
			and tar.num_credito = Vcreditoexterno
			and tar.tipo_tarjeta ='T' 
			and tar.secuencia = (select max(tar2.secuencia)
								from bdicred:sd_tarjeta tar2
								where tar2.empresa = '001' 
								and tar2.num_credito = Vcreditoexterno
								and tar2.tipo_tarjeta ='T' );						
		END IF;
		
		SELECT LIMIT 1 nvl(sc01,'')
			INTO  Vsecc1
		FROM bdiburo:br_sc  br 
		WHERE  br.num_cliente = Vnumcte;			
		
		select limit 1 correo_elec
		INTO Vmail
		from bdinteg:si_correos
		where numcte = Vnumcte
		AND status_correo = 'A';
		
		select LIMIT 1 a.telefono, b.telefono ,d.telefono,d.extension
			into Vtel1 , Vtel2 ,Vtel3 ,Vext
		from bdinteg:si_telefonos_actual a
		left outer join bdinteg:si_telefonos_actual b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 2 AND b.status_tel = 'A' and b.cofetel = 'V') 
		left outer join bdinteg:si_telefonos_actual d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 3 AND d.status_tel = 'A' and d.cofetel = 'V') 
		where a.empresa = '001' and a.numcte = vnumcte 
		and a.tipo_tel = 1
		AND a.status_tel = 'A' 
		and a.cofetel = 'V' ;	
			
		--IF (Vproducto = '6300') then		
			LET VcreditoConsulta =Vnum_credito;
		--ELSE
			--LET VcreditoConsulta =Vcreditoexterno;  
		--END IF;
				
		SELECT limit 1 nvl(sum(valor),0) into Vsecc2
		FROM bdisolic:ss_detalle_scoring 
		where empresa = '001'
		and num_solicitud = VcreditoConsulta;

		select limit 1  nvl(ingreso_mensual,0), nvl(situacion_pago,0), nvl(meses_historia,0), evalua_cc, nvl(grupo,'')
		into Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit, cGrupo
		from scorfin
		where num_solicitud = VcreditoConsulta;
		
		
/*		if (vestatus in ('AA') OR (vestatus = 'E1' and iAtr_Act_ifrs = 0)) then
			let Vsaldo_cierre =  Vcapital_vigente + vsaldo_vencido_exigible;	
		end if;
		if (vestatus in ('BA') OR (vestatus in ('E1','E2') and iAtr_Act_ifrs > 0)) then
			let Vsaldo_cierre =  vcapital_vigente + vcapital_transitorio;	
		end if;
		if (vestatus in ('BT','VP') OR (vestatus = 'E3' and iAtr_Act_ifrs > 0)) then
			let Vsaldo_cierre = vsaldo_vencido_exigible + vsaldo_vencido_no_exigible; 
		end if;
		*/
		
		if (vestatus <> 'FF') THEN 
			LET Vsaldo_cierre = vsaldo_insoluto; 
		END IF;
			
		-------------------------BUSCAR ULTIMO MOVIMIENTO DEL CLIENTE-------------------------
		if exists(select num_credito 
			from MovtosCred 
			where  num_credito = Vnum_credito
			and codigo_ref = 1 and codigo_fun   in ('020','021','022','023','024','025','027','028','222','225')
			and fecha_mov = Vfechaultmov --(select max(fecha_mov)from bdicred:sd_movhiscrd )
			) then 	

			LET Vtipoultimomov = 'P';
			
			 IF  (Vproducto = '6011') THEN --para la segunda parte...
				/*select limit 1 nvl(monto,0) into vmontor1
				FROM MovtosCred
				where  num_credito = Vnum_credito 
				and codigo_fun = '338' and codigo_ref = 21 
				and fecha_mov = (select max(fecha_mov) from MovtosCred  where num_credito = Vnum_credito and codigo_fun = '338' and codigo_ref = 21 );
				*/
			
				/*select limit 1 nvl(monto,0) into vmontor2
				FROM MovtosCred
				where  num_credito = Vnum_credito 
				and codigo_fun = '338' and codigo_ref = 22 
				and fecha_mov = (select max(fecha_mov) from MovtosCred  where num_credito = Vnum_credito and codigo_fun = '338' and codigo_ref = 22 ); 
				*/
				
				--let Vinteres = vmontor1 + vmontor2;
				if   Vinteres is null then let Vinteres = 0; end if;			
			 
			 END IF;
			
		elif exists(select num_credito 
			from MovtosCred
			where 
			 num_credito = Vnum_credito
			and codigo_ref  in (3,4) and codigo_fun  = '001'
			and fecha_mov = (select max(fecha_mov)from MovtosCred where codigo_ref in(3,4) and codigo_fun  = '001' and num_credito = Vnum_credito)
			) then
			
			select max(fecha_mov) INTO Vfechaultmov from MovtosCred where codigo_ref in(3,4) and codigo_fun  = '001' and num_credito = Vnum_credito;
			
			IF  (Vproducto = '6011') THEN 
				LET Vtipoultimomov = 'L';
				LET Vfechaultmov = vfecha_apertura;
			ELSE
				LET Vtipoultimomov = 'A';
			END IF;		
			
		elif exists(select num_credito 
			from MovtosCred 
			where 
			 num_credito = Vnumcreditortc
			and codigo_ref in (1,2,66) and codigo_fun  in ('001','002') 
			and fecha_mov = (select max(fecha_mov)from MovtosCred where  num_credito = Vnumcreditortc and   codigo_ref in (1,2,66) and codigo_fun in ('001','002') )
			) then		
			
			select max(fecha_mov) INTO Vfechaultmov from MovtosCred where   num_credito = Vnumcreditortc and  codigo_ref in (1,2,66) and codigo_fun in ('001','002');
			
			IF  (Vproducto = '6011') THEN 
				LET Vtipoultimomov = 'A';				
			ELSE
				LET Vtipoultimomov = 'D';
			END IF;								
		end if;
			
		LET vlNumInsert = vlNumInsert + 1;
		IF vlNumInsert = 5000 then 
		   LET vlNumInsert = 1;
		  -- update statistics medium for table bdicred:"informix".sd_carteral_ppyr;
		END IF;

		select NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)
		into Vsaldovencido
		from sd_maesdoscrd 
		where empresa = '001'
		and num_credito = Vnum_credito;
		
		select 	nvl(sdo_capital,0)
				,nvl(monto_vencido,0)
				,nvl(cap_tras_no_venci,0)
				,nvl(mto_venc_trasp,0)
				,nvl(sdo_intereses,0) + nvl(sdo_no_exig,0)
		into 	VsaldoCapital
				,VsaldoTrasp
				,VvenciNoExig
				,VvenciExig
				,VintVigente
		from sd_maesdoscontcrd 
		where empresa = '001'
		and fecha = pfechacorte
		and num_credito = Vnum_credito;

		select int_venc_bal28,int_venc_bal29,int_venc_bal30,int_venc_bal31
		into VintVenc28,VintVenc29,VintVenc30,VintVenc31
		from bdicred:sd_sdodiariocrd 
		where fecha = MDY(month(pfechacorte), 1,year(pfechacorte))
		and num_credito = Vnum_credito;
		
		IF to_char(pfechacorte, "%d") = 28 THEN 
			Let VintVencido = VintVenc28;
		ELIF to_char(pfechacorte, "%d") = 29 THEN 
			Let VintVencido = VintVenc29;
		ELIF to_char(pfechacorte, "%d") = 30 THEN
			Let VintVencido = VintVenc30;
		ELIF to_char(pfechacorte, "%d") = 31 THEN 
			Let VintVencido = VintVenc31;
		END IF;
		
		IF Vproducto = '6011' THEN
			IF vestatus IN ('BT','VP','E3')  THEN
				Let VintVencido = Vinteresvencido;
			END IF;
		END IF;
		
		IF vestatus IN ('BT','VP','E3') THEN
			LET VintVigente = 0;
		END IF;
		
		select nvl(capital_mto_cuota,0)
		into Vabonobase
		from bdicred:sd_amortiza_creditocrd 
		where num_credito = Vnum_credito
		and fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd where num_credito = Vnum_credito);

		if (Vabonobase = '') then 
			LET Vabonobase = 0; 
		end if;

		SELECT --nvl(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0),
			   nvl(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
		INTO --Vinteresvencido,
		  vinteres_moratorio
		FROM "informix".sd_amortiza_creditocrd
		WHERE empresa     = '001'
		AND num_credito = Vnum_credito
		AND capital_status IN ('2','7','6')
		AND fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd where num_credito = Vnumcreditortc);

		--obtener causa solicitud
			select limit 1 nvl(a.causa_solicitud,'') into cMotivo
			from bdisolic:ss_autorizacion a
			where a.empresa = cEmpresa
			and a.num_solicitud = vNum_Credito
			and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = vNum_Credito and status_solicitud = 'AT')
			and a.status_solicitud = 'AT';
			IF Vcreditoexterno not in ('0','') THEN
				select limit 1 nvl(a.causa_solicitud,'') into cMotivo
				from bdisolic:ss_autorizacion a
				where a.empresa = cEmpresa
				and a.num_solicitud = Vcreditoexterno
				and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = Vcreditoexterno and status_solicitud = 'AT')
				and a.status_solicitud = 'AT';
			END IF;	
		
------------Obtenemos los valores de scores de originacion
			--valida si es prestamo o reestructura
				--si es reestructura, tmar el valor de vnum_credito
			if Vproducto = '6011' then
				let v_selectcredito = Vcreditoexterno;
			--si no es reestructura, tomar el valor de vcreditoexterno
			else 
				let v_selectcredito = Vnum_credito;
			end if
			
			select evaluacion 
			into dBcScore
			from bdisolic:ss_resumen_scoring 
			where empresa = '001' 
			and num_solicitud = v_selectcredito
			and seccion = 1;
		
			if dBcScore is null or dBcScore = "" then
				let dBcScore = "";
			end if
			select evaluacion 
			into dScoreProp
			from bdisolic:ss_resumen_scoring 
			where empresa = '001' 
			and num_solicitud = v_selectcredito
			and seccion = 2;
			if dScoreProp is null or dScoreProp = "" then
				let dScoreProp = "";
			end if
			select evaluacion 
			into dFico
			from bdisolic:ss_resumen_scoring 
			where empresa = '001' 
			and num_solicitud = v_selectcredito
			and seccion = 3;
			if dFico is null or dFico = "" then
				let dFico = "";
			end if
			select evaluacion 
			into dFicoExtended
			from bdisolic:ss_resumen_scoring 
			where empresa = '001' 
			and num_solicitud = v_selectcredito
			and seccion = 4;
			if dFicoExtended is null or dFicoExtended = "" then
				let dFicoExtended = "";
			end if
			select evaluacion 
			into dIcc
			from bdisolic:ss_resumen_scoring 
			where empresa = '001' 
			and num_solicitud = v_selectcredito
			and seccion = 5;
			if dIcc is null or dIcc = "" then
				let dIcc = "";
			end if
			
			SELECT LIMIT 1 DECODE(flag2creditoicc,'1','Evaluacion de segundo producto de credito en adelante','')
             INTO cFlag2Credito
             FROM bdisolic:"informix".ss_revision_determinacion
            WHERE empresa = '001'
			  AND num_solicitud = v_selectcredito;

			IF cFlag2Credito IS NULL THEN 
			   LET cFlag2Credito = ' ';
			END IF;
			
			-- MODIFICACION REPORTE RQM 09 459-2 (INICIO)
			SELECT status_ini
			 INTO cStatus_Ini
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = v_selectcredito;
			 
			IF cStatus_Ini IS NULL THEN
			   LET cStatus_Ini = ' ';
			END IF;
			
			SELECT CASE WHEN revisado = 'N' THEN 'C'ELSE 'R' END
			 INTO cRevisado
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = v_selectcredito;
			 
			IF cRevisado IS NULL THEN
			   LET cRevisado = ' ';
			END IF;			 
			
			SELECT COUNT(*) 
			 INTO cIdbox
			 FROM bdisolic:"informix".ss_solicitudes_mc a
			 RIGHT OUTER JOIN bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			WHERE empresa = '001'
			 AND num_solicitud = v_selectcredito;
			 			
			IF cIdbox >= 1 THEN 
			   LET cIFE = 'Si';
			ELSE   
			   LET cIFE = 'No'; 
			END IF;	
			-- MODIFICACION REPORTE RQM 09 459-2 (FIN)
			
			IF (vestatus IN ('BA','BT','VP','E1','E2','E3') AND  vmes_vencido > 0) THEN
				SELECT fecha_vencido INTO dFechaVencido
				FROM bdicred:sd_indicador_cred_crd_hist
				WHERE empresa = '001'
				AND fecha_insert = pfechacorte
				AND num_credito = Vnum_credito;
				
				LET sMesesVencidos = TRUNC((pfechacorte - dFechaVencido)/30.4);
			ELSE
				LET sMesesVencidos = 0;
			END IF;
		

         SELECT COUNT(*),SUM(monto) INTO sNumPagos,dMontoPagos
           FROM bdicred:sd_movhiscrd
          WHERE empresa = empresa
            AND fecha_mov >= MDY(MONTH(pfechacorte),1,YEAR(pfechacorte))
            AND fecha_mov <= pfechacorte
            AND num_credito = Vnum_credito
            AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanualcrd)
            AND codigo_ref = 1 
            AND reversado = 'N';

		IF dMontoPagos IS NULL OR dMontoPagos = '' THEN
			LET sNumPagos = 0;
			LET dMontoPagos = 0;
		END IF;

		INSERT INTO sd_carteral_ppyr 
			(producto , num_credito ,numcte	,num_tarjeta ,num_sucursal	,nom_suucursal	,ingreso_mensual ,
			monto_apertura  ,fecha_apertura  ,plazo ,estatus ,
			saldo_insoluto	,capital_vigente,	capital_transitorio	,saldo_vencido_exigible	,saldo_vencido_no_exigible	,saldo_actual , 
			saldo_cierre ,mes_vencido ,tipo_mov ,fecha_mov,sexo ,fecha_nac ,nombre1 ,Nombre2 ,apellido_p ,
			apellido_m ,mail ,dir_calle ,dir_numero ,dir_colonia ,cp ,
			dir_municipio ,num_estado ,dir_estado ,num_cd_coppel ,cd_coppel ,num_cd_banco ,
			cd_banco ,tel1 ,tel2 ,tel3 ,ext ,ref_coppel ,eficiencia ,meses_historia ,hit ,secc1 ,secc2, motivo,
			bc_score , score_prop, fico, fico_extended, icc, flag2credito, status, revisado, ife, grupo, meses_vencidos, num_pagos, monto_pagos)
		VALUES
			(Vproducto , Vnum_credito , Vnumcte,	Vnum_tarjeta ,Vnum_sucursal	, Vnom_suucursal,nvl(Vingreso_mensual,''),
			Vmonto_apertura , Vfecha_apertura , Vplazo ,Vestatus,Vsaldo_insoluto,Vcapital_vigente,
			Vcapital_transitorio	,Vsaldo_vencido_exigible,Vsaldo_vencido_no_exigible,Vsaldo_actual ,
			Vsaldo_cierre ,Vmes_vencido ,Vtipoultimomov ,Vfechaultmov, Vsexo ,Vfecha_nac, Vnombre1 , Vnombre2 ,Vapellido_p ,
			Vapellido_m ,nvl(Vmail,''),Vdir_calle, Vdir_numero , Vdir_colonia , Vcp ,
			Vdir_municipio,  Vnum_estado ,Vdir_estado ,Vnum_cd_coppel ,Vcd_coppel ,Vnum_cd_banco ,
			Vcd_banco , nvl(Vtel1,'') ,nvl(Vtel2,'') , nvl(Vtel3,'') ,nvl(Vext,'') , Vref_coppel ,Vficiencia , Vmeses_historia ,Vhit ,Vsecc1 , Vsecc2, cMotivo,
			nvl(dBcScore,''),nvl(dScoreProp,''), nvl(dFico,''), nvl(dFicoExtended,''), nvl(dIcc,''), cFlag2Credito, cStatus_Ini, cRevisado, cIfe, nvl(cGrupo,''), nvl(sMesesVencidos,0), nvl(sNumPagos,0), nvl(dMontoPagos,0));			
		
		IF Vnumtarjetatdc = '' THEN 
			LET Vnumtarjetatdc ='0';
		END IF
		IF Vnumcuentartc = '' THEN 
			LET Vnumcuentartc ='0';
		END IF
		IF Vnumcuentartc = '' THEN 
			LET Vnumcuentartc ='0';
		END IF
		
		INSERT INTO sd_pagosydisposicionescrd_cartera  VALUES
		(Vproducto,Vnum_credito,Vcreditoexterno,Vnumcuentartc,Vnumtarjetatdc,Vnumcte,Vnum_sucursal,Vnumciudad, 
		vfecha_apertura,Vsaldo_insoluto,Vinteres,Vsaldovencido,Vinteresvencido,vinteres_moratorio,
		Vabonobase,vmes_vencido,Vestatus,vplazo,Vtasainteres,Vfechalimitedepago,Vfechaultmov,Vtipoultimomov,pfechacorte,
		VsaldoCapital,VsaldoTrasp,VvenciNoExig,VvenciExig,VintVigente,VintVencido);	
	
		
		LET	Vnumcreditortc			= '';LET Vcreditoexterno			= '';LET Vnumcuentartc			= '';
		LET	Vnumtarjetatdc			= '';LET	Vnumcte           	    = '';LET	Vnumsucursal			= 0;
		LET	Vnumciudad	            = '';LET Vsaldoactual			= 0;LET Vinteres                = 0;
		LET Vsaldovencido           = 0;LET Vinteresvencido         = 0;LET Vabonobase              = 0;LET Vabonosvencidos         = 0;
		LET vinteres_moratorio		= 0;LET Vestadocredito          = 0;LET Vplazortc      			= 0;LET Vtasainteres   		    = 0;
		LET Vfechalimitedepago      = DATE(1);LET	Vfechaultmov            = DATE(1);LET Vtipoultimomov          = '';
		let Vprod					='';let vmontor1				= 0;let vmontor2				= 0;
					
			
		LET  Vsaldo_insoluto	= 0;	LET  Vcapital_vigente	= 0;	LET Vcapital_transitorio	= 0;	LET Vsaldo_vencido_exigible	= 0;
		LET Vsaldo_vencido_no_exigible	= 0;	LET Vsaldo_actual = 0;	LET  Vsaldo_cierre = 0;	
		LET Vproducto     		='';     LET Vnum_credito         = '';	 LET  Vnumcte				='';
		LET Vnum_tarjeta         ='';	 LET Vnum_sucursal		='';	 LET  Vnom_suucursal		='';	 LET  Vingreso_mensual    = 0;
		LET  Vmonto_apertura      = 0;	 LET  Vfecha_apertura     = date(1);	  LET  Vplazo = 0;
		LET Vestatus ='';	  
		LET Vmes_vencido = 0;	  LET Vtipo_mov ='';	  LET Vfecha_mov = DATE(1);
		LET Vsexo ='';	  LET Vfecha_nac = date(1);	  LET Vnombre1 ='';	  LET Vnombre2 ='';	  LET Vapellido_p ='';
		LET Vapellido_m ='';	  LET Vmail ='';	  LET Vdir_calle ='';	  LET Vdir_numero ='';	  LET Vdir_colonia ='';
		LET Vcp = '';	 	  LET Vdir_municipio ='';	  LET Vnum_estado = 0;	  LET Vdir_estado ='';	  LET Vnum_cd_coppel= 0;
		LET Vcd_coppel ='';	  LET Vnum_cd_banco = 0;	  LET  Vcd_banco ='';	  LET Vtel1 ='';	  LET  Vtel2 ='';
		LET Vtel3 ='';	  LET Vext ='';	 	  LET Vref_coppel ='';	  LET Vficiencia = 0;	  LET Vmeses_historia = 0;
		LET Vhit ='';	  LET Vsecc1 = '';	  LET Vsecc2 = 0;	LET cMotivo = '';
		
		LET VsaldoCapital			= 0;	LET VintVenc28	= 0;
		LET VsaldoTrasp				= 0;	LET VintVenc29	= 0;
		LET VvenciNoExig			= 0;	LET VintVenc30	= 0;
		LET VvenciExig				= 0;	LET VintVenc31	= 0;
		LET VintVigente				= 0;
		LET VintVencido				= 0;
		
    END FOREACH;	
--SET DEBUG FILE TO "prueba12052017-1.out";
--TRACE ON;	
--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	--let cruta = '/informix/jorger/pruebas/';
	--let cruta = '/aplicacion/Jorge/Adendum_Reporte_Cartera/Nuevo/';
	let cnombre = 'Cartera_Total';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pfechacorte,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.txt';
	 
	let cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = " select * from bdicred:sd_carteral_ppyr ";
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	
	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL; 
	
	LET	Vnumcte           	    = '';
	LET  sPaso = 0;		

	--segundo archivo
	--CREAR  ARCHIVO
	LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' ||to_char(pfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivo ='cartera_reestructura_prestamo'||to_char(pfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivoNvo ='cartera_reestructura_prestamo'||to_char(pfechacorte,'%d%m%Y')||'_Ant.txt';
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' || TRIM(cruta) ||'Pagos1.unl' || ' DELIMITER ' || '''|'''  ||
	' select * from sd_pagosydisposicionescrd_cartera;'||
	' " > '|| TRIM(cruta) || 'Pagosydisposiciones2crd.sql';

	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicred ' || TRIM(cruta) || 'Pagosydisposiciones2crd.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) || 'Pagos1.unl >' || TRIM(cruta) || trim(cNombreArchivo);
	SYSTEM cSql;

	let cSql = '';

	LET cSql = "rm " || TRIM(cruta) || 'Pagos1.unl ' || TRIM(cruta) || 'Pagosydisposiciones2crd.sql';
	SYSTEM cSql;

	-- para Generar el archvio de Cifras.
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' || TRIM(cruta) || 'DirectorioCifrasControlRegistros.unl'|| ' DELIMITER ' || '''|'''  ||
	' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), fechacorte FROM bdicred:sd_pagosydisposicionescrd_cartera group by fechacorte ' ||
	' " > '|| TRIM(cruta) || 'DirectorioCifrasControlQuerys.sql';

	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicred ' || TRIM(cruta) ||'DirectorioCifrasControlQuerys.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) ||'DirectorioCifrasControlRegistros.unl > '|| TRIM(cruta) || trim(cNombreArchivo2);
	SYSTEM cSql;

	let cSql = '';
	LET cSql = "rm " || TRIM(cruta) ||'DirectorioCifrasControlRegistros.unl ' || TRIM(cruta) ||'DirectorioCifrasControlQuerys.sql';
	SYSTEM cSql;
	
	LET cSql = '';
	LET cSql = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 -d '|' " || TRIM(cruta) || trim(cNombreArchivo) || ' >' || TRIM(cruta) || trim(cNombreArchivoNvo);
	SYSTEM cSql;
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03') returning cCod_ret2;
	RETURN cCod_ret;
	
END;
END PROCEDURE;