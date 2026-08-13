create procedure "informix".sp_cargamovtosnvasfunc(pEmpresa CHAR(3), pNumCredito CHAR(20))

RETURNING
          CHAR(6)        AS resultado,
          CHAR(120)      AS mensaje,
          CHAR(20)       AS Numcte,
          CHAR(4)        AS Sucursal,
          CHAR(2)        AS StatusCred,
          INTEGER        AS Plazo,
          DATE           AS FechaApertura,
          DATE           AS FechaVencimiento,
          DECIMAL(9,6)   AS TasaInteres,
          DECIMAL(9,6)   AS TasaMoratorios,
          DECIMAL(18,2)  AS SdoRetenido,
          DECIMAL(18,2)  AS SdoNoExig,
          DECIMAL(18,2)  AS SdoContabMora,
          DECIMAL(18,2)  AS SdoCapital,
          DECIMAL(18,2)  AS SdoCapInsoluto,
          DECIMAL(18,2)  AS SdoMtoVdo,
          DECIMAL(18,2)  AS MtoVdoTrasp,
          DECIMAL(18,2)  AS MtoFinanciado,
          DECIMAL(18,2)  AS MtoOtorgado,
          DECIMAL(18,2)  AS CapTrasNoVdo,
          DECIMAL(18,2)  AS MtoVdoInt,
          DECIMAL(18,2)  AS MtoVdoTrasInt,
          DECIMAL(18,2)  AS IntTraNoExig,
          CHAR(60)       AS DescTpoCart,
          CHAR(2)        AS CodTpoCred,
          DECIMAL(5,3)   AS PorcIva,
          DECIMAL(18,2)  AS Moratorio,
          DECIMAL(18,2)  AS IvaMoratorio,
          DECIMAL(18,2)  AS IvaIntVenc,
          DECIMAL(18,2)  AS InteresMes,
          DECIMAL(18,2)  AS IvaMes,
          DECIMAL(18,2)  AS TotalLiquidacion,
          DECIMAL(18,2)  AS IntMoraCope,
          DECIMAL(18,2)  AS IvaIntMoraCope,
          DECIMAL(18,2)  AS IntMoraBase,
          DECIMAL(18,2)  AS IvaIntMoraBase,
          DECIMAL(18,2)  AS IvaIntMoraCopeBase,
          DECIMAL(18,2)  AS CapitalTotal,
          DECIMAL(18,2)  AS InteresVigente,
          DECIMAL(18,2)  AS IvaInteresVigente;
		  
		    
-- Autor: David Uriel Prieto Hurtado
-- Fecha de Modificación: 01/06/2009
-- Observaciones: Se realiza  procedimiento para realizar la cansulta al maestro de saldo , asi como a las amortizaciones del credito.

--Fecha: 16/07/2009
--Modicacion: Se cambiaron los status de como obtener el interes vigente y el interes vencido
--Autor: Roque Enrique Solis C.   

DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(6);
DEFINE cMensajeRet       CHAR(120);
DEFINE sNumRegCons       SMALLINT;

DEFINE dtFechaHoy        DATE;
DEFINE cNumcte           CHAR(20);
DEFINE cSucursal         CHAR(4);
DEFINE cStatusCred       CHAR(2);
DEFINE iPlazo            INTEGER;
DEFINE dtFechaAper       DATE;
DEFINE dtFechaVenc       DATE;
DEFINE dTasaInteres      DECIMAL(9,6);
DEFINE dTasaMoratorios   DECIMAL(9,6);
DEFINE dSdoRetenido      DECIMAL(18,2);
DEFINE dSdoNoExig        DECIMAL(18,2);
DEFINE dSdoContabMora    DECIMAL(18,2);
DEFINE dSdoCapital       DECIMAL(18,2);
DEFINE dSdoCapInsoluto   DECIMAL(18,2);
DEFINE dSdoMtoVdo        DECIMAL(18,2);
DEFINE dMtoVdoTrasp      DECIMAL(18,2);
DEFINE dMtoFinanciado    DECIMAL(18,2);
DEFINE dMtoOtorgado      DECIMAL(18,2);
DEFINE dCapTrasNoVdo     DECIMAL(18,2);
DEFINE dMtoVdoInt        DECIMAL(18,2);
DEFINE dMtoVdoTrasInt    DECIMAL(18,2);
DEFINE dIntTraNoExig     DECIMAL(18,2);
DEFINE cDescTpoCart      CHAR(60);
DEFINE cCodTpoCred       CHAR(2);

DEFINE dIntVig             DECIMAL(18,2);
DEFINE dIvaIntVig          DECIMAL(18,2);
DEFINE dPorcIva            DECIMAL(5,3);
DEFINE dMoratorio          DECIMAL(18,2);
DEFINE dIvaMoratorio       DECIMAL(18,2);
DEFINE dIvaIntVenc         DECIMAL(18,2);
DEFINE dInteresMes         DECIMAL(18,2);
DEFINE dIvaMes             DECIMAL(18,2);
DEFINE dTotalLiquidacion   DECIMAL(18,2);

DEFINE dIntMoraCope        DECIMAL(18,2);
DEFINE dIvaIntMoraCope     DECIMAL(18,2);
DEFINE dIntMoraBase        DECIMAL(18,2);
DEFINE dIvaIntMoraBase     DECIMAL(18,2);
DEFINE dIvaIntMoraCopeBase DECIMAL(18,2);

DEFINE dCapitalTotal       DECIMAL(18,2);
DEFINE dtFechaComparacion  DATE;


LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = '';
LET cCodRet              = '000000';
LET cMensajeRet          = 'Se realizó consulta correctamente';
LET sNumRegCons          = 0;

LET dtFechaHoy           = DATE(1);
LET cNumcte              = '';
LET cSucursal            = '';
LET cStatusCred          = '';
LET iPlazo               = 0;
LET dtFechaAper          = DATE(1);
LET dtFechaVenc          = DATE(1);
LET dTasaInteres         = 0;
LET dTasaMoratorios      = 0;
LET dSdoRetenido         = 0;
LET dSdoNoExig           = 0;
LET dSdoContabMora       = 0;
LET dSdoCapital          = 0;
LET dSdoCapInsoluto      = 0;
LET dSdoMtoVdo           = 0;
LET dMtoVdoTrasp         = 0;
LET dMtoFinanciado       = 0;
LET dMtoOtorgado         = 0;
LET dCapTrasNoVdo        = 0;
LET dMtoVdoInt           = 0;
LET dMtoVdoTrasInt       = 0;
LET dIntTraNoExig        = 0;
LET cDescTpoCart         = '';
LET cCodTpoCred          = '';

LET dIntVig              = 0;
LET dIvaIntVig           = 0;
LET dPorcIva             = 0;
LET dMoratorio           = 0;
LET dIvaMoratorio        = 0;
LET dIvaIntVenc          = 0;
LET dInteresMes          = 0;
LET dIvaMes              = 0;
LET dTotalLiquidacion    = 0;

LET dIntMoraCope         = 0;
LET dIvaIntMoraCope      = 0;
LET dIntMoraBase         = 0;
LET dIvaIntMoraBase      = 0;
LET dIvaIntMoraCopeBase  = 0;


LET dCapitalTotal        = 0;
LET dtFechaComparacion   = DATE(1);



IF TRIM(nvl(pEmpresa,'')) = '' THEN
  LET pEmpresa = NULL;
END IF;

IF TRIM(nvl(pNumCredito,'')) = '' THEN
  LET pNumCredito = NULL;
END IF;

IF pEmpresa IS NULL OR pNumCredito IS NULL THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'No hay datos por consultar';
 RETURN cCodRet, cMensajeRet, NVL(cNumcte,''), NVL(cSucursal,''), NVL(cStatusCred, ''), NVL(iPlazo,0), NVL(dtFechaAper, DATE(1)), NVL(dtFechaVenc,DATE(1)),
         NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dSdoRetenido,0), NVL(dSdoNoExig,0), NVL(dSdoContabMora,0), NVL(dSdoCapital,0),
         NVL(dSdoCapInsoluto,0), NVL(dSdoMtoVdo,0), NVL(dMtoVdoTrasp,0), NVL(dMtoFinanciado,0), NVL(dMtoOtorgado,0), NVL(dCapTrasNoVdo,0),
         NVL(dMtoVdoInt,0), NVL(dMtoVdoTrasInt,0), NVL(dIntTraNoExig,0), NVL(cDescTpoCart,''), NVL(cCodTpoCred,''), NVL(dPorcIva,0),
         NVL(dMoratorio,0), NVL(dIvaMoratorio,0), NVL(dIvaIntVenc,0), NVL(dInteresMes,0), NVL(dIvaMes,0), NVL(dTotalLiquidacion,0),
         NVL(dIntMoraCope,0), NVL(dIvaIntMoraCope,0), NVL(dIntMoraBase,0), NVL(dIvaIntMoraBase,0), NVL(dIvaIntMoraCopeBase,0), NVL(dCapitalTotal,0),
         NVL(dIntVig,0), NVL(dIvaIntVig,0);
END IF;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= 'Ocurrió error en el procedimiento (sp_cargamovtosnvasfunc): ' || cErrorInfo;
   RETURN cCodRet, cMensajeRet, NVL(cNumcte,''), NVL(cSucursal,''), NVL(cStatusCred, ''), NVL(iPlazo,0), NVL(dtFechaAper, DATE(1)), NVL(dtFechaVenc,DATE(1)),
         NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dSdoRetenido,0), NVL(dSdoNoExig,0), NVL(dSdoContabMora,0), NVL(dSdoCapital,0),
         NVL(dSdoCapInsoluto,0), NVL(dSdoMtoVdo,0), NVL(dMtoVdoTrasp,0), NVL(dMtoFinanciado,0), NVL(dMtoOtorgado,0), NVL(dCapTrasNoVdo,0),
         NVL(dMtoVdoInt,0), NVL(dMtoVdoTrasInt,0), NVL(dIntTraNoExig,0), NVL(cDescTpoCart,''), NVL(cCodTpoCred,''), NVL(dPorcIva,0),
         NVL(dMoratorio,0), NVL(dIvaMoratorio,0), NVL(dIvaIntVenc,0), NVL(dInteresMes,0), NVL(dIvaMes,0), NVL(dTotalLiquidacion,0),
         NVL(dIntMoraCope,0), NVL(dIvaIntMoraCope,0), NVL(dIntMoraBase,0), NVL(dIvaIntMoraBase,0), NVL(dIvaIntMoraCopeBase,0), NVL(dCapitalTotal,0),
         NVL(dIntVig,0), NVL(dIvaIntVig,0);
   END IF;
END EXCEPTION;


--SET DEBUG FILE TO "/tmp/sp_cargamovtosnvasfuncXX";
--TRACE ON;

-- Se obtiene la fecha hoy del sistema
SELECT fecha_hoy
  INTO dtFechaHoy
  FROM "informix".sd_fechas
 WHERE empresa= pEmpresa;
 
 -- Identifica el tipo de amortizacion a realizar
IF DAY(dtFechaHoy) <= 20 THEN
    LET dtFechaComparacion = MDY(MONTH(dtFechaHoy - 1 UNITS MONTH),20, YEAR(dtFechaHoy));
ELSE
    LET dtFechaComparacion = MDY(MONTH(dtFechaHoy),20, YEAR(dtFechaHoy));
END IF;

-- Se realiza la consulta general
SELECT a.numcte,
       a.sucursal,
       a.status_cred,
       a.plazo,
       a.fecha_apertura,
       a.fecha_vencim,
       a.tasa_interes,
       a.tasa_moratorios,
       b.sdo_retenido,
       b.sdo_no_exig,
       b.sdo_contab_mora,
       b.sdo_capital,
       b.sdo_cap_insoluto,
       b.monto_vencido,
       b.mto_venc_trasp,
       nvl(b.monto_financiado,0) as monto_financiado,
       nvl(b.monto_otorgado,0) as monto_otorgado,
       b.cap_tras_no_venci,
       b.mto_venc_int,
       b.mto_venc_tra_int,
       b.int_tra_no_exig,
       c.descripcion tp_cartera,
       DECODE(d.cod_tipcred,'01','365','04','365','360') diascalc
  INTO cNumcte,
       cSucursal,
       cStatusCred,
       iPlazo,
       dtFechaAper,
       dtFechaVenc,
       dTasaInteres,
       dTasaMoratorios,
       dSdoRetenido,
       dSdoNoExig,
       dSdoContabMora,
       dSdoCapital,
       dSdoCapInsoluto,
       dSdoMtoVdo,
       dMtoVdoTrasp,
       dMtoFinanciado,
       dMtoOtorgado,
       dCapTrasNoVdo,
       dMtoVdoInt,
       dMtoVdoTrasInt,
       dIntTraNoExig,
       cDescTpoCart,
       cCodTpoCred
  FROM "informix".sd_maecred a,
       "informix".sd_maesdos b,
       "informix".sd_tipocartera c,
       "informix".sd_definicion d
 WHERE b.num_credito = a.num_credito
   AND b.empresa = a.empresa
   AND c.status_cred = a.status_cred
   AND c.empresa = a.empresa
   AND d.num_producto = a.num_producto
   AND d.empresa = a.empresa
   AND a.num_credito = pNumCredito
   AND a.empresa = pEmpresa;

   LET sNumRegCons = dbinfo("sqlca.sqlerrd2");

   IF(sNumRegCons = 0) THEN
      LET cCodRet = '000002';
      LET cMensajeRet = 'El número de cuenta no es válido ';

   RETURN cCodRet, cMensajeRet, NVL(cNumcte,''), NVL(cSucursal,''), NVL(cStatusCred, ''), NVL(iPlazo,0), NVL(dtFechaAper, DATE(1)), NVL(dtFechaVenc,DATE(1)),
         NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dSdoRetenido,0), NVL(dSdoNoExig,0), NVL(dSdoContabMora,0), NVL(dSdoCapital,0),
         NVL(dSdoCapInsoluto,0), NVL(dSdoMtoVdo,0), NVL(dMtoVdoTrasp,0), NVL(dMtoFinanciado,0), NVL(dMtoOtorgado,0), NVL(dCapTrasNoVdo,0),
         NVL(dMtoVdoInt,0), NVL(dMtoVdoTrasInt,0), NVL(dIntTraNoExig,0), NVL(cDescTpoCart,''), NVL(cCodTpoCred,''), NVL(dPorcIva,0),
         NVL(dMoratorio,0), NVL(dIvaMoratorio,0), NVL(dIvaIntVenc,0), NVL(dInteresMes,0), NVL(dIvaMes,0), NVL(dTotalLiquidacion,0),
         NVL(dIntMoraCope,0), NVL(dIvaIntMoraCope,0), NVL(dIntMoraBase,0), NVL(dIvaIntMoraBase,0), NVL(dIvaIntMoraCopeBase,0), NVL(dCapitalTotal,0),
         NVL(dIntVig,0), NVL(dIvaIntVig,0);
   END IF;


-- Se obtiene el interes vigente e iva de interes vigente correspondiente
    --IF DAY(dtFechaHoy) <= 20 THEN
        SELECT sum((interes_debe - interes_pagado)), sum((iva_debe - iva_pagado))
          INTO dIntVig, dIvaIntVig
          FROM "informix".sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = pNumCredito
           AND capital_status = '1'
           and fecha_cuota <=dtFechaComparacion;
    /*ELSE
        SELECT (interes_debe - interes_pagado), (iva_debe - iva_pagado)
          INTO dIntVig, dIvaIntVig
          FROM bdicred:sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = pNumCredito
           --AND capital_status = '7'
           AND capital_status <> '2'
           and fecha_cuota =  MDY(MONTH(dtFechaComparacion),20, YEAR(dtFechaComparacion));
    END IF;*/
    
  /*SELECT sdo_no_exig
    INTO dIntVig
    FROM "informix".sd_maesdos
   WHERE empresa=pEmpresa
     AND  num_credito = pNumCredito;*/
   
-- Se obtiene iva de la sucursal
   SELECT iva
     INTO dPorcIva
     FROM bdinteg:si_sucursales
    WHERE empresa = pEmpresa
      AND sucursal = cSucursal;

-- Se calcula el interes moratorio.
    SELECT (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) +
            SUM(mora_sdo_cope+mora_provi_cope-mora_sdo_cope_pag))
      INTO dMoratorio
      FROM "informix".sd_amortiza_credito
     WHERE empresa = pEmpresa
       AND num_credito = pNumCredito
       AND capital_status IN ("2","7","6");

    IF dMoratorio IS NULL OR dMoratorio < 0 THEN
      LET dMoratorio = 0;
    END IF;

-- Se calcula el iva de interes moratorio
   SELECT SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * dPorcIva)-mora_iva_pagado)
     INTO dIvaMoratorio
     FROM "informix".sd_amortiza_credito
    WHERE empresa = pEmpresa
      AND num_credito = pNumCredito
      AND capital_status IN ("2","7","6")
      AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * dPorcIva)) > 0;

     IF  dIvaMoratorio  IS NULL OR  dIvaMoratorio < 0 THEN
            LET dIvaMoratorio = 0;
     END IF;

-- Se Calcula el iva de interes vencido
   SELECT NVL(SUM(iva_debe - iva_pagado),0)
	 INTO dIvaIntVenc
	 FROM "informix".sd_amortiza_credito
	WHERE empresa = pEmpresa
      AND num_credito = pNumCredito
	  --AND capital_status = '2';
      AND capital_status IN ('2','7','6');

   SELECT NVL(SUM(b.interes_debe - b.interes_pagado),0)
     INTO dInteresMes
     FROM "informix".sd_amortiza_credito b
    WHERE b.empresa = pEmpresa
      AND b.num_credito = pNumCredito
      AND capital_status = '1';

   SELECT nvl(SUM(b.iva_debe - b.iva_pagado),0)
     INTO dIvaMes
     FROM "informix".sd_amortiza_credito b
    WHERE b.empresa = pEmpresa
      AND b.num_credito = pNumCredito
      AND capital_status = '1';

       IF cStatusCred IN ('BT','E2','E3') THEN
          IF dIntTraNoExig>0 THEN
            LET dIntTraNoExig = dIntTraNoExig - dInteresMes;
          END IF;
          --IF ( dIntTraNoExig > 0 ) THEN
           -- LET dIvaIntVenc = dIvaIntVenc - dIvaMes;
         -- END IF;
       --ELSE
         -- LET dIntTraNoExig = 0;
         --LET dIvaIntVenc = 0;
       END IF;

-- Se calcula el total por liquidar
  LET dTotalLiquidacion = dSdoCapInsoluto + dMoratorio + dIvaMoratorio + dIntTraNoExig + dIvaIntVenc;


-- Se calculan los interes moratorio copete e interes moratorio base
SELECT nvl(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0),
       nvl(SUM((mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) * (select valor::decimal(18,2) from bdinteg:si_param where empresa=pEmpresa and cod_param=47)),0),
       nvl(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0),
       nvl(SUM((mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag)  * (select valor::decimal(18,2) from bdinteg:si_param where empresa=pEmpresa and cod_param=47)),0),
       nvl(((SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag)+ SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag)) * (select valor::decimal(18,2) from bdinteg:si_param where empresa='001' and cod_param=47))::decimal(18,2),0)
    INTO dIntMoraCope,
       dIvaIntMoraCope,
       dIntMoraBase,
       dIvaIntMoraBase,
       dIvaIntMoraCopeBase
  FROM "informix".sd_amortiza_credito
 WHERE empresa = pEmpresa
   AND num_credito = pNumCredito
   AND capital_status IN (2,7,6);



--  LET dIvaIntMoraCopeBase= dIvaIntMoraCope + dIvaIntMoraBase;
  LET dCapitalTotal= dSdoCapital + dSdoMtoVdo + dMtoVdoTrasp + dCapTrasNoVdo;


  RETURN cCodRet, cMensajeRet, NVL(cNumcte,''), NVL(cSucursal,''), NVL(cStatusCred, ''), NVL(iPlazo,0), NVL(dtFechaAper, DATE(1)), NVL(dtFechaVenc,DATE(1)),
         NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dSdoRetenido,0), NVL(dSdoNoExig,0), NVL(dSdoContabMora,0), NVL(dSdoCapital,0),
         NVL(dSdoCapInsoluto,0), NVL(dSdoMtoVdo,0), NVL(dMtoVdoTrasp,0), NVL(dMtoFinanciado,0), NVL(dMtoOtorgado,0), NVL(dCapTrasNoVdo,0),
         NVL(dMtoVdoInt,0), NVL(dMtoVdoTrasInt,0), NVL(dIntTraNoExig,0), NVL(cDescTpoCart,''), NVL(cCodTpoCred,''), NVL(dPorcIva,0),
         NVL(dMoratorio,0), NVL(dIvaMoratorio,0), NVL(dIvaIntVenc,0), NVL(dInteresMes,0), NVL(dIvaMes,0), NVL(dTotalLiquidacion,0),
         NVL(dIntMoraCope,0), NVL(dIvaIntMoraCope,0), NVL(dIntMoraBase,0), NVL(dIvaIntMoraBase,0), NVL(dIvaIntMoraCopeBase,0), NVL(dCapitalTotal,0),
         NVL(dIntVig,0), NVL(dIvaIntVig,0);

------------------ capitales
-- sicrSaldoActual1  sdo_capital -- dSdoCapital -- 13
-- sicrSaldoActual2  monto_vencido -- dSdoMtoVdo -- 15
-- sicrSaldoActual3  mto_venc_trasp -- dMtoVdoTrasp -- 16
-- sicrSaldoActual4  cap_tras_no_venci -- dCapTrasNoVdo -- 19
-- sicrSaldoActual5.value =  dCapitalTotal -- 37
------------------ Intereses Vigente
-- sicrSaldoActual6.value= (interes_debe - interes_pagado), dIntVig -- 38
-- sicrSaldoActual7.value= (iva_debe - iva_pagado), dIvaIntVig -- 39
------------------ Intereses Vencido
-- sicrSaldoActual8.value= (dIntTraNoExig), dIntTraNoExig   --22
-- sicrSaldoActual9.value= (iva_debe - iva_pagado) status_cred "2" y "7" , (dIvaIntVenc), --28
------------------ Intereses Moratorios
-- sicrSaldoActual10.value= (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag)) dIntMoraBase --34
-- sicrSaldoActual11.value= (SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) dIntMoraCope -- 32
-- sicrSaldoActual12.value=  nvl(SUM((mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) * 0.15),0) +
--                           nvl(SUM((mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) * 0.15),0), dIvaIntMoraCopeBase) -- 36

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para consultar',
'el maestro de movimientos de un créto',
'determinado',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 11/MAYO/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cartareest_catpromo(pEmpresa char(3))
returning
          char(06) as resultado,
          char(80) as mensaje;

-- MAHR Agosto 2012. Se parametriza ruta destino: /resplogifx/archivoscartera/
--GEV Junio 2013 Se unen los archivos enviados al CAT en uno solo, se hace la union del nombre en un solo campo,
--se unen los telefonos,se acote a cuentas con atraso entre 3 a 5 meses de atraso y adeudo mayor a $2,000 pesos. 
--AAME INC 27 067 Se modifica el tipo de dato de smallint a entero del campo vregistros debido a que el parametro 
--de registros aumento su valor.
define Sql_error Integer;
define cSql char(20000);
define cCodRet char(06);
define iCodRet integer;
define cMensajeRet CHAR(80);
define dHoy date;
define dFCorte date;
define vDia  char(2);
define vMes  char(2);
define vAnio char(4);
define cNombreArchivo char(50);
define cTasa decimal (9,6);
define cFTasa decimal (9,6);
Define cRutaArch CHAR (50);
define sPaso	smallint;
define iTotalRegistros   integer;
define vregistros	integer; --smallint
define cProceso		char(4);
define vvalor integer;
define vcontador integer;
define cNumCte char(20);
define cNumCred	char(20);				
define vnombre char(10);
define viPrioridad      integer;
define cdelimitador         CHAR(1);
define VlDescripcion    char(50); 
define vlValorAlfa      char(50);
define vlValorAlfabetico char(50); 
define vlCteDuplicado char(20);
define viMinVencdo  Integer; 
define viMaxVencdo  Integer; 

let cCodRet = '000000';
let iCodRet = 0;
let cMensajeRet = 'El proceso de REPORTES DE REESTRUCTURAS se realizó correctamente';
let sPaso = 0;
let cProceso = '0101';
let vcontador = 0;
let cNumCte = '';
let cNumCred = '';				
let vnombre = '';
LET viPrioridad     = 0;
let cdelimitador            = "";
let VlDescripcion   = '';
let vlValorAlfabetico = '';
let vlCteDuplicado = '';
let viMinVencdo = 0; 
let viMaxVencdo = 0; 

BEGIN
    on exception set iCodRet, Sql_error, cMensajeRet
            if iCodRet <> 0 then
--            execute procedure sp_obtener_hora() into vhora_fin;
            let cCodRet = iCodRet;
           -- let cMensajeRet ='Error al generar los REPORTES DE REESTRUCTURAS ';
			  CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, cMensajeRet, '02')
				RETURNING cCodRet;
            return cCodRet,cMensajeRet ;
        end if;
    end exception;

--Set debug file to "/informix/janeth/reporte_reestructura/sp_cartareest_catpromo.out";
--Trace on;

let dHoy  = '';
let vDia  = '';
let vMes  = '';
let vAnio = '';
let cNombreArchivo = '';

let dHoy  = date((Select fecha_hoy from bdicred:sd_fechas)) ;
let dFCorte = date((Select fecha_ant from bdicred:sd_fechas)) ;
let vDia = lpad(day(dHoy),2,'0');
let vMes = lpad(month(dHoy),2,'0');
let vAnio = lpad(year(dHoy),4,'0');

Let cTasa = 1+.754;
Let cFTasa = 0;
Let  cSql = '';
Let iTotalRegistros = 0;
let vregistros = 0;
let vvalor = 0;
/*
select a.valor
  into vlvalor
from bdinteg:si_fechavalor a
where a.empresa = '001'
  and a.tasa='CRDREEST'
  and a.fecha = (SELECT MAX(r.fecha)
                 FROM bdinteg:si_fechavalor r
                WHERE r.empresa = '001' AND r.tasa = a.tasa);
*/
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, cMensajeRet, '01')
	RETURNING cCodRet;

SET ISOLATION TO dirty READ;

SELECT valor INTO cRutaArch FROM bdinteg:"informix".si_param WHERE cod_param = 137;

--LET cRutaArch = '/INFORMIXDUMP/';--PRUEBAS GEV
SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
        AND tipo_campania = 61 AND grupo_parametro = 'ARCHIVOSEP' AND num_parametro = 336;

truncate table bdinteg:"informix".si_carta_reestructura;

-----TABLA--------------
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'sd_temp_invitacion_reest';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_temp_invitacion_reest;
            END IF;

	CREATE TABLE sd_temp_invitacion_reest
	(
	tipo_promocion char(3),
	tipo_logica smallint,
	fecha date,
	num_credito1 char(20),
	sucursal char(4),
	numcte1 char(20),
	ult_4dig char(4),
	status smallint,
	prioridad integer,--smallint,--serial,
	apell_p char(30),
	apell_m char(30),
	nombre1 char(30),
	nombre2 char(30),
	sexo char(2),
	estado_civil char(2),
	correo char(60),
	estado char(30),
	municipio char(30),
	num_credito3 char(20),
	numcte char(20),
	meses_vencidos smallint,
	monto_vencido decimal(18,2),
	plazo6 decimal(18,2),
	plazo12 decimal(18,2),
	plazo18 decimal(18,2),
	plazo24 decimal(18,2),
	plazo36 decimal(18,2),
	monto_bonificacion decimal(18,2),
	monto_total decimal(18,2),
	pago_minimo decimal(18,2),
	telefono1            CHAR(13),
    telefono2            CHAR(13),
    telefono3            CHAR(13),
	telefono4            CHAR(13),
    extension            CHAR(05));
    create index ix_tmp_invrest on sd_temp_invitacion_reest (numcte1, num_credito1);

-----------------------------------------
select valor_numerico into vregistros
from bdicobranza:cb_param_campania
where tipo_campania = 50 and num_parametro= 51;

-- Obtiene los parametros que indican el min y maximo de vencidos para reestructuras. Se cambia de (3 a 5) a  (2 a 5)
SELECT valor::INTEGER INTO viMinVencdo FROM bdicred:sd_param WHERE empresa = '001' AND cod_param = '111';
SELECT valor::INTEGER INTO viMaxVencdo FROM bdicred:sd_param WHERE empresa = '001' AND cod_param = '169';


--from bdicred:sd_maecred a ,bdinteg:si_cliente c, bdicred:sd_maesdos a1  , bdinteg:si_direcciones_actual d, bdicred:sd_tarjeta b ,

select a.numcte, a.sucursal , a1.*
 from bdicred:sd_maecred a , bdicred:sd_maesdos a1
--bdinteg:si_telefonos_actual tel
where a.empresa = '001'  
    and a.empresa = a1.empresa
    and a.num_credito = a1.num_credito
	--and tel.numcte = a.numcte
    and a.status_cred IN ('BT','E2','E3')
    and a1.sdo_cap_insoluto >= 2000
    and a.campo_trab3 = ''
	--and a1.mto_fin_ven_trasp between 3 and 5
    and a1.mto_fin_ven_trasp between viMinVencdo and viMaxVencdo -- mahr Cambio de meses vencidos de (3 a 5) a (2 a 5)
	--and tel.contacto = 1
	into temp CreditoTmp with no log;
	create index ix_CreditoTemp on  CreditoTmp (numcte);
	update statistics medium for table CreditoTmp;

    FOREACH 
      SELECT numcte
       into vlCteDuplicado
      from CreditoTmp
      group by numcte
      having count(*) >1

      delete from CreditoTmp where numcte = vlCteDuplicado and sdo_cap_insoluto = (select max(sdo_cap_insoluto) from CreditoTmp where numcte = vlCteDuplicado);
    END FOREACH;

	select dir.* from bdinteg:si_direcciones_actual dir, CreditoTmp cred where dir.numcte = cred.numcte and dir.tipo_dir = 1
	into temp TempDirecciones with no log;
	create index ix_Direcciones on  TempDirecciones (numcte, tipo_dir);
	update statistics medium for table TempDirecciones;

select
   dfCorte fecha,
   a1.numcte, -- numero de cliente
   a1.num_credito, -- numero de credito
   b.num_tarjeta, -- numero de tarjeta
   a1.sucursal, --Sucursal
   --d.telefono1,
   --d.telefono2,
   --d.telefono3,
   --d.extension,
   tel1.telefono  telefono1,
   tel2.telefono  telefono2,
   tel3.telefono  telefono3,
   tel4.telefono  telefono4,
   tel3.extension extension,
   a1.mto_fin_ven_trasp,
   --trim(c.apell_paterno)||' '||trim(c.apell_materno)||' '||trim(c.nombre1)||' '||trim(c.nombre2) nombre,
   Trim(c.nombre1) nombre1,
   Trim(c.nombre2) nombre2,
   Trim(c.apell_paterno) apell_paterno,
   Trim(c.apell_materno) apell_materno,  -- nombre cliente
   trim(e.nombrecalle) nombrecalle,
   Trim(d.numeroextcalle) numeroextcalle,
   trim(replace(d.numerointcalle, '|','')) numerointcalle, -- direccion CN
   f.nombrezona,  -- direccion_col
   g.nombreciudad,   -- direccion_del
   h.nombre,  -- edo_cd
   d.cod_postal,  -- codigo_postal
   d.entre_calles,  --entre_calles
   d.observaciones ,  --observaciones
   LPAD(d.numerociudad ,4,'0') numerociudad,
   LPAD(f.centro,6,'0') centro,
   LPAD(f.jefegrupozona,8,'0') jefegrupozona,
   LPAD(f.supervisorzona,8,'0') supervisorzona,
   LPAD(d.numerocolonia,4,'0') numerocolonia,
   LPAD(d.numerocalle,6,'0') numerocalle,
   LPAD(TRIM(d.numeroextcalle),5,'0')numeroextccalle  ,
   monto_financiado  +
   (select sum(interes_debe - interes_pagado + iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where a1.empresa = empresa and a1.num_credito = num_credito and capital_status in ('2','7','6')) +
    case when(select sum(mora_provi_ordi + mora_provi_cope + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag ) from bdicred:sd_amortiza_credito where empresa = '001' and a1.num_credito = num_credito and capital_status in ('2','7','6'))  > 0
	          then round((select sum(mora_provi_ordi + mora_provi_cope + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag ) from bdicred:sd_amortiza_credito where empresa = '001' and a1.num_credito = num_credito and capital_status in ('2','7','6')) * (1+ i.iva),2)
	     else 0
	end  pago_minimo ,
	( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
     ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
     ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
                                                     NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
                        from bdicred:sd_amortiza_credito
                        where empresa = '001' and num_credito = a1.num_credito
                        and capital_status in ('2','7','6') ) *(1+ i.iva)) )/6, 2)) Pago6 ,
    ( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
     ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
     ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
                                                     NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
                        from bdicred:sd_amortiza_credito
                        where empresa = '001' and num_credito = a1.num_credito
                        and capital_status in ('2','7','6') ) *(1+ i.iva)) )/12, 2)) Pago12 ,
    ( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
     ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
     ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
                                                     NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
                        from bdicred:sd_amortiza_credito
                        where empresa = '001' and num_credito = a1.num_credito
                        and capital_status in ('2','7','6') ) *(1+ i.iva)) )/18, 2)) Pago18 ,
    ( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
     ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
     ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
                                                     NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
                        from bdicred:sd_amortiza_credito
                        where empresa = '001' and num_credito = a1.num_credito
                        and capital_status in ('2','7','6') ) *(1+ i.iva)) )/24, 2)) Pago24 ,
    ( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
     ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
     ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
                                                     NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
                        from bdicred:sd_amortiza_credito
                        where empresa = '001' and num_credito = a1.num_credito
                        and capital_status in ('2','7','6') ) *(1+ i.iva)) )/36, 2)) Pago36 ,

    case when (select sum(mora_provi_cope + mora_sdo_cope - mora_sdo_cope_pag ) from bdicred:sd_amortiza_credito where empresa = '001' and a1.num_credito = num_credito and capital_status in ('2','7','6'))  > 0
	          then round((select sum(mora_provi_cope +  mora_sdo_cope - mora_sdo_cope_pag ) from bdicred:sd_amortiza_credito where empresa = '001' and a1.num_credito = num_credito and capital_status in ('2','7','6')) * (1+ i.iva),2)
		 else 0
    end  intereses_moratorios,  -- intereses moratorios

    ( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
     ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
     ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
                                                     NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
                        from bdicred:sd_amortiza_credito

                        where empresa = '001' and num_credito = a1.num_credito
                        and capital_status in ('2','7','6') ) *(1+ i.iva)) ),2)  )
	deuda_total

  from CreditoTmp a1
	join bdinteg:si_cliente c 		on (a1.numcte = c.numcte )
	join TempDirecciones d on (a1.numcte = d.numcte  and d.tipo_dir = '1' )
	join bdicred:sd_tarjeta b   	on (a1.empresa = b.empresa   and a1.num_credito = b.num_credito  and  b.tipo_tarjeta='T'   
									and b.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where a1.empresa = empresa and a1.num_credito = num_credito and tipo_tarjeta='T') )
	join  bdinteg:si_sucursales  i 	on (a1.sucursal = i.sucursal)
	join  bdinteg:si_catcalles   e  on (d.numerocalle = e.numerocalle)
	join  bdinteg:si_catzonas    f  on (d.numerociudad = f.numerociudad   and d.numerocolonia = f.numerocolonia)
	join  bdinteg:si_catciudades g  on (d.numerociudad= g.numerociudad )
	join  bdinteg:si_estados  h 	on (d.estado= h.estado)
	left join bdinteg:si_telefonos_actual tel1  on (tel1.empresa = '001' and tel1.numcte= a1.numcte and tel1.tipo_tel = 1 and tel1.cofetel ='V')
	left join bdinteg:si_telefonos_actual tel2  on (tel2.empresa = '001' and tel2.numcte= a1.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V')
	left join bdinteg:si_telefonos_actual tel3  on (tel3.empresa = '001' and tel3.numcte= a1.numcte and tel3.tipo_tel = 3 and tel3.cofetel ='V')
	left join bdinteg:si_telefonos_actual tel4  on (tel4.empresa = '001' and tel4.numcte= a1.numcte and tel4.tipo_tel = 4 and tel4.cofetel ='V')

  into temp pros_reestructura with no log;

  create index inx_pros_reestructura on pros_reestructura( num_credito );

  update statistics high for table pros_reestructura;

  insert into bdinteg:"informix".si_carta_reestructura
  ( fecha, numcte, num_credito, num_tarjeta, sucursal, nombre1, nombre2, apell_paterno, apell_materno, calle, numeroextcalle, numerointcalle,
    colonia, ciudad, estado, codigopostal, entrecalles, observaciones, numerociudad, num_centro, num_jefe, num_supervisor, num_coloniacte,
	num_callecte, num_casacte, telefono_casa, telefono_celular, telefono_trabajo, extension_trabajo, meses_vencidos, monto_vencido,
	pago_minimo,pago_6, pago_12, pago_18, pago_24, pago_36, intereses_moratorio, deuda_total )

  select fecha, numcte,num_credito, num_tarjeta, sucursal, nombre1, nombre2, apell_paterno, apell_materno, replace(nombrecalle,'|',''), replace(numeroextcalle,'|',''), replace(numerointcalle,'|',''),
  nombrezona, nombreciudad, nombre, cod_postal,
  nvl ( replace ( replace( entre_calles , '|' , ' ' ), '\' , ' ' ), ' ' ),
  nvl ( replace ( replace( observaciones , '|' , ' ' ), '\' , ' ' ), ' ' ),
  numerociudad, centro, jefegrupozona, supervisorzona, numerocolonia,numerocalle,
  numeroextccalle,
  nvl ( replace ( replace( telefono1 , '|' , ' ' ), '\' , ' ' ), ' ' ),
  nvl ( replace ( replace( telefono2 , '|' , ' ' ), '\' , ' ' ), ' ' ),
  nvl ( replace ( replace( telefono3 , '|' , ' ' ), '\' , ' ' ), ' ' ),
  nvl ( replace ( replace( extension , '|' , ' ' ), '\' , ' ' ), ' ' ),
  mto_fin_ven_trasp, pago_minimo, pago_minimo,pago6, pago12, pago18, pago24, pago36, intereses_moratorios,
  deuda_total
  from pros_reestructura res
  where (select count(*) from bdicred:sd_amortiza_credito
         --where empresa = '001' and res.num_credito = num_credito and capital_status in ('2','7','6')) >= 3
         where empresa = '001' and res.num_credito = num_credito and capital_status in ('2','7','6')) >= viMinVencdo    -- mahr Cambio de vencidos de (3 a 5) a (2 a 5)
           and res.num_credito not in ( select numcred from bdisitesp:se_ctessitespcred_his
		                                where res.numcte =numcte
										  and res.num_credito = numcred and situacion = 'P' and causa = 35);


  -- Se eliminan cliente con situacion especial 61
  DELETE FROM si_carta_reestructura WHERE num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred
                                                          WHERE situacion = 'P' AND causa = 61);


	INSERT INTO  sd_temp_invitacion_reest (tipo_promocion,tipo_logica ,fecha ,num_credito1 ,sucursal ,numcte1 ,ult_4dig,status ,prioridad ,
	apell_p ,apell_m ,nombre1 ,nombre2 ,sexo ,estado_civil ,correo ,estado ,municipio ,num_credito3 ,
	numcte ,meses_vencidos ,monto_vencido ,plazo6 ,plazo12 ,plazo18 ,plazo24 ,plazo36 ,monto_bonificacion,monto_total,
	pago_minimo,telefono1,telefono2,telefono3,telefono4,extension)
	select 'RES' tipopromocion, 2 tipologica, a.fecha,a.num_credito,a.sucursal, a.numcte, substr(a.num_tarjeta,13)
			,0 statusprom,			
				0 prioridad,				
			a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2
			,cte.sexo,cte.estado_civil,co.correo_elec,a.estado,a.ciudad
			,a.num_credito, a.numcte,a.meses_vencidos, a.pago_minimo,a.pago_6, a.pago_12, a.pago_18, a.pago_24
			,a.pago_36, a.intereses_moratorio,  a.deuda_total, a.pago_minimo,/*a.telefono_casa,
        a.telefono_celular, a.telefono_trabajo, a.extension_trabajo*/
		b.telefono1, b.telefono2, b.telefono3, b.telefono4, extension
	from bdinteg:"informix".si_carta_reestructura a
	join pros_reestructura b on (b.num_credito = a.num_credito)	
	left join bdinteg:si_ctepf cte on (cte.numcte = a.numcte)
	left join bdinteg:si_correos co on (co.empresa  = '001' and co.numcte = a.numcte and status_correo ='A'
						and co.secuencia = (select max(secuencia) from bdinteg:si_correos 
											where empresa  = '001' and numcte = a.numcte and status_correo ='A'));



	update sd_temp_invitacion_reest 
		set telefono4 = nvl(substr(telefono4,length(telefono4)-9,10),''),
			telefono1 = nvl(substr(telefono1,length(telefono1)-9,10),''), 
			telefono2 = nvl(substr(telefono2,length(telefono2)-9,10),''),
			telefono3 = nvl(substr(telefono3,length(telefono3)-9,10),''); 
		
		
		delete from sd_temp_invitacion_reest  where nvl(telefono1,'') ='' and nvl(telefono2,'')='' and nvl(telefono3,'')='' 
		and nvl(telefono4,'')='';

	update sd_temp_invitacion_reest set telefono2 = ''
	where nvl(telefono1,'')= nvl(telefono2,'');

	update sd_temp_invitacion_reest set telefono3 = ''
	where nvl(telefono3,'')= nvl(telefono2,'') or nvl(telefono3,'')= nvl(telefono1,'');

	update sd_temp_invitacion_reest set telefono4 = ''
	where nvl(telefono1,'')= nvl(telefono4,'') or nvl(telefono2,'')= nvl(telefono4,'') or nvl(telefono3,'')= nvl(telefono4,''); 
	
	update sd_temp_invitacion_reest 
		set telefono4 = nvl(telefono4,'') ,
			telefono1 = nvl(telefono1,''), 
			telefono2 = nvl(telefono2,''),
			telefono3 = nvl(telefono3,'');
			
		update sd_temp_invitacion_reest 
		set telefono4 =  case when val_num(telefono4) then telefono4 else '' end ,
			telefono1 = case when val_num(telefono1) then telefono1 else '' end , 
			telefono2 = case when val_num(telefono2) then telefono2 else '' end ,
			telefono3 = case when val_num(telefono3) then telefono3 else '' end ;
      
      
	update sd_temp_invitacion_reest 
		set telefono4 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono4,1,2) in ('55','33','81')  then 
									SUBSTR(telefono4,1,2) else SUBSTR(telefono4,1,3) end 
						   AND a.serie = case when SUBSTR(telefono4,1,2) in ('55','33','81')  then SUBSTR(telefono4,3,4) else SUBSTR(telefono4,4,3) end 
						   AND (SUBSTR(telefono4,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono4,7,4)*1)*1 <= a.numeracion_final ),'')||telefono4 ,
			telefono1 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono1,1,2) in ('55','33','81')  then 
									SUBSTR(telefono1,1,2) else SUBSTR(telefono1,1,3) end 
						   AND a.serie = case when SUBSTR(telefono1,1,2) in ('55','33','81')  then SUBSTR(telefono1,3,4) else SUBSTR(telefono1,4,3) end 
						   AND (SUBSTR(telefono1,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono1,7,4)*1)*1 <= a.numeracion_final ),'')||telefono1 ,		 
			telefono2 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono2 ,1,2) in ('55','33','81')  then 
									SUBSTR(telefono2 ,1,2) else SUBSTR(telefono2 ,1,3) end 
						   AND a.serie = case when SUBSTR(telefono2 ,1,2) in ('55','33','81')  then SUBSTR(telefono2 ,3,4) else SUBSTR(telefono2,4,3) end 
						   AND (SUBSTR(telefono2,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono2,7,4)*1)*1 <= a.numeracion_final ),'')||telefono2 ,
			telefono3 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono3,1,2) in ('55','33','81')  then 
									SUBSTR(telefono3,1,2) else SUBSTR(telefono3,1,3) end 
						   AND a.serie = case when SUBSTR(telefono3,1,2) in ('55','33','81')  then SUBSTR(telefono3,3,4) else SUBSTR(telefono3,4,3) end 
						   AND (SUBSTR(telefono3,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono3,7,4)*1)*1 <= a.numeracion_final ),'')||telefono3; 
			
		update sd_temp_invitacion_reest
		set telefono4 = decode(telefono4,'',null, telefono4),
			telefono1 = decode(telefono1,'',null, telefono1), 
			telefono2 = decode(telefono2,'',null, telefono2),
			telefono3 = decode(telefono3,'',null, telefono3);								   
			
	-- Actualiza el orden de prioridad de acuerdo a la fecha de vigencia de la solicitud
	 LET viPrioridad = 1;

    FOREACH
        SELECT numcte1, num_credito1 INTO cNumCte, cNumCred 
        FROM sd_temp_invitacion_reest WHERE tipo_promocion = 'RES'
        --ORDER BY meses_vencidos desc,monto_total desc

        UPDATE sd_temp_invitacion_reest SET prioridad = viPrioridad 
            WHERE numcte1 = cNumCte AND num_credito1 = cNumCred;
        
        LET viPrioridad = viPrioridad + 1;
    END FOREACH;

	select count(*) into iTotalRegistros from sd_temp_invitacion_reest;
	
	INSERT INTO bdicred:sd_totalcte_campania(empresa, fecha_insert, tipocampania, total)
	VALUES('001', dHoy , 'CARTA_REEST', iTotalRegistros);
 
-------------------------- Archivo Promociones -------------------------------------------------

let cNombreArchivo = trim('Reestructuras_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');

let cSql = 'echo " Set Isolation to dirty read; Unload to ' ||  trim(cRutaArch) || 'archivo_promociones.unl' || ' delimiter ' || '''|''' ||
' select tipo_promocion,tipo_logica,num_credito1,numcte1,sucursal,prioridad,'||
'TRIM(apell_p)||'||''' '''||'||TRIM(apell_m)||'||''' '''||'||TRIM(nombre1)||'||''' '''||'||TRIM(nombre2),sexo ,estado_civil ,correo ,estado,'||
'meses_vencidos ,monto_vencido ,plazo6 ,plazo12 ,plazo18 ,plazo24 ,plazo36 ,monto_bonificacion,monto_total,pago_minimo, ' ||
--'telefono2, telefono3,telefono4, extension '||
'telefono1,telefono2,telefono3,telefono4 ,extension '||
'from sd_temp_invitacion_reest order by prioridad" ' ||
' > ' || trim(cRutaArch) || 'Archivo_Promociones.sql' ;


system cSql;
let cSql='';
let cSql = 'dbaccess bdinteg ' || trim(cRutaArch) || 'Archivo_Promociones.sql';
system cSql;

let cSql='';
let csql = 'echo "Tipo_Promocion'|| cdelimitador || 'Tipo_Logica'|| cdelimitador || 'Numero_de_Credito'|| cdelimitador || 'Numero_de_Cliente'|| cdelimitador || 'Sucursal'|| cdelimitador || 'Prioridad'|| cdelimitador ||
             'Nombre'|| cdelimitador ||'sexo' || cdelimitador || 'Estado_Civil' || cdelimitador || 'email' || cdelimitador || 'Estado'|| cdelimitador || 'Meses_Vencidos' || cdelimitador ||'Monto_Vencido' ||
             cdelimitador || 'Pago_Plazo_6'|| cdelimitador || 'Pago_Plazo_12' || cdelimitador || 'Pago_Plazo_18' || cdelimitador || 'Pago_Plazo_24' || cdelimitador || 'Pago_Plazo_36' || cdelimitador || 'Monto_Bonificacion' ||
             cdelimitador || 'Monto_Total' || cdelimitador || 'Pago_Minimo' || cdelimitador || 'Tel_cons_tipo_1' || cdelimitador || 'Tel_cons_tipo_2' || cdelimitador || 'Tel_cons_tipo_3' || cdelimitador || 'Tel_cons_tipo_4' || cdelimitador ||
			 'Extension' ||
             ' " > ' || trim(cRutaArch) || cNombreArchivo;
system csql;


let cSql='';
let cSql = "sed 's/|$//g' " || trim(cRutaArch) || "archivo_promociones.unl >> " || trim(cRutaArch) ||  cNombreArchivo;
system cSql;

let cSql='';
let cSql = 'rm ' || trim(cRutaArch) || 'Archivo_Promociones.sql';
system cSql;

let cSql='';
let cSql = 'rm ' || trim(cRutaArch) || 'archivo_promociones.unl';
system cSql;



-------------------- Última carta--------------------------------------

let cNombreArchivo = trim('Carta_Invitacion_Reest' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
let cSql = 'echo " Set Isolation to dirty read; Unload to ' || trim(cRutaArch) || cNombreArchivo || ' delimiter ' || '''|''' ||

--|| "''"/"''" || ' ||

' select  fecha, (Trim(nombre1) || ' || ' "''" "''" || Trim(nombre2) || ' || ' "''" "''" || Trim(apell_paterno) || ' || ' "''" "''" || Trim(apell_materno)) nombre_cliente, ' ||
'        trim(calle) || ' || ' "''" "''" || Trim(numeroextcalle)|| ' || ' "''" "''" || Trim(numerointcalle) direccion , ' ||
'        colonia, ciudad,estado, codigopostal, entrecalles, observaciones, ' ||
' LPAD(numerociudad ,4,''0'') || "''"/"''" || ' ||
' LPAD(num_centro,6,''0'') || "''"/"''" || ' ||
' LPAD(num_jefe,8,''0'') || "''"/"''" || ' ||
' LPAD(num_supervisor,8,''0'')|| "''"/"''" || ' ||
' LPAD(num_coloniacte,4,''0'') || "''"/"''" || ' ||
' LPAD(num_callecte,6,''0'') || "''"/"''" || ' ||
' LPAD(TRIM(num_casacte),5,''0'') clave_ruta, ' ||
' pago_minimo, pago_12, pago_18, pago_24, pago_36, intereses_moratorio,num_credito,num_tarjeta,numcte ' ||
' from si_carta_reestructura ' ||
' where numerociudad in  (4,10,14,17,24,26,31,32,38,40,41,44,46,47,48,54,55,57,58,59,62,66,70,78,80,87,89,91,92,97,107,121,124,164,167,'||
                       ' 168,169,170,174,175,179,181,182,183,184,191,208,282,283,286,289,294,295,298,308,310,311,312,315,335,340,361,364)" '||
'> ' || trim(cRutaArch) || 'Archivo_UltimaCarta.sql ';

system cSql;
let cSql='';
let cSql = 'dbaccess bdinteg ' || trim(cRutaArch) || 'Archivo_UltimaCarta.sql';
system cSql;

let cSql='';
let cSql = 'rm ' || trim(cRutaArch) || 'Archivo_UltimaCarta.sql';
system cSql;

	select valor_numerico into vvalor
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 58;

	--INSERT INTO bdicobranza:cb_administativa_latinia--(num_campania,numcte,telefono,tarjeta ,apellido_pat,fecha)
    select limit vvalor  a.numcte,a.num_credito, SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10) telefono,
						CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||
															TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1)))
						ELSE SUBSTR(a.nombre1,1,10) END nombre,a.fecha
	from bdinteg:"informix".si_carta_reestructura a
	join bdinteg:si_telefonos_actual tel2 on (tel2.empresa = '001' and tel2.numcte= a.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual
                                                 where numcte = a.numcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A'))
	where tel2.telefono is not null and tel2.telefono <> '' into temp catpromo_reest;

    create index ix_tmp_cat_prom on catpromo_reest (numcte,num_credito);
	
	{
	select count(*) into vcontador from catpromo_reest;
		
	if (vcontador >= 1) then 
	FOREACH
		select numcte,num_credito, nombre
			into cNumCte, cNumCred,vnombre
		from catpromo_reest
	
		call bdimnsj:"informix".sp_registra_evento (2, 'INV_REEST' , cNumCte, cNumCred,'', 2,
										vnombre,'','','','',0,0,0,0,0, '', '')RETURNING cCodRet;
	
	END FOREACH;
		--CALL bdicobranza:"informix".sp_sms_reporte(2,0,0,0) RETURNING 	cCodRet;
	end if;
	
	FOREACH
		select descripcion,  trim(valor_alfabetico)
		  into VlDescripcion, vlValorAlfabetico
		  from bdicred:sd_param_campania 
		 where tipo_campania = 60  
		   AND GRUPO_PARAMETRO = 'TELSMSFIJO'
		   and num_parametro in (1,2,3,5,6)
		   
		select numcte,num_credito
		  into cNumCte,cNumCred
		  from bdicred:sd_maecred
		 where num_credito  = vlValorAlfabetico; --in ('600109267697','600030001041','600109267432')
		 
		 select CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1))) ELSE
																					SUBSTR(a.nombre1,1,10) END nombre into vnombre
    from bdinteg:si_cliente a where numcte = cNumCte; 
							
    call bdimnsj:"informix".sp_registra_evento (2, 'INV_REEST' , cNumCte, cNumCred,'', 2,
										vnombre,'','','','',0,0,0,0,0, '', '')RETURNING cCodRet;
          
          	
    END FOREACH;}
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, cMensajeRet, '03')RETURNING cCodRet;
return cCodRet,cMensajeRet ;
end;
end procedure;