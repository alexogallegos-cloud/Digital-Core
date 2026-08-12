CREATE PROCEDURE "informix".sp_cat_graba_telefono_adicional(pEmpresa             CHAR(3),
                                                            pOrigen              SMALLINT,
                                                            pNumcte              CHAR(20), 
                                                            pTipo_telefono       SMALLINT, 
                                                            pTelefono            CHAR(13),  
                                                            pExtension           CHAR(5), 
                                                            pParentesco          CHAR(1), 
                                                            pResultado_gestion   INTEGER, 
                                                            pEjecutivo           CHAR(8))
RETURNING
CHAR(6) AS  cCodRespuesta;

DEFINE sIsam_err        SMALLINT;
DEFINE sSql_err         SMALLINT;
DEFINE cCod_ret         CHAR(6);
DEFINE wcod_ret         CHAR(6);
DEFINE cError_info      CHAR(100);
DEFINE cEmpresa         CHAR(3);
DEFINE cNumcte          CHAR(20); 
DEFINE cEjecutivo       CHAR(8);
DEFINE cTelefono        CHAR(13);
DEFINE dFecha_hoy       DATE;
DEFINE vtipored         CHAR(1);
DEFINE vnumero_carrier  SMALLINT;

LET sIsam_err       = 0;
LET cCod_ret        = "000000";
LET cError_info     = "";
LET sSql_err        = 0;
LET cEmpresa        = "";
LET cNumcte         = "";
LET cEjecutivo      = '';
LET dFecha_hoy      = DATE(1);

BEGIN
ON EXCEPTION SET sSql_err,sIsam_err,cError_info
   LET cCod_ret = sSql_err;
   RETURN cCod_ret;
END EXCEPTION;

-- SET DEBUG FILE TO '/tmp/sp_cat_graba_telefono_adicional.out';
-- TRACE ON;
   
-- Se valida que los adatos de entrada sean validos.
IF NVL(pEmpresa,"") = "" THEN
   LET cCod_ret = "102005";
   RETURN cCod_ret;
END IF;

SELECT empresa
  INTO cEmpresa 
  FROM bdinteg:si_empresas
 WHERE empresa = pEmpresa;
       
IF NVL(cEmpresa,"")= "" then
    LET cCod_ret = "102003";
    RETURN cCod_ret;
END IF;

IF NVL(pNumcte,"") = "" THEN
   LET cCod_ret = "102006";
   RETURN cCod_ret;
END IF;

SELECT numcte
  INTO cNumcte 
  FROM bdinteg:si_cliente
 WHERE empresa = pEmpresa
   AND numcte  = pNumcte;

IF NVL(cNumcte ,"") = "" THEN
   LET cCod_ret = "102007";
   RETURN cCod_ret;
END IF; 
      
IF NVL(pEjecutivo,"") = "" THEN
   LET cCod_ret = "102008";
   RETURN cCod_ret;
END IF;
/*
SELECT ejecutivo
  INTO cEjecutivo
  FROM bdinteg:si_ejecut
 WHERE empresa   = pEmpresa
   AND ejecutivo = pEjecutivo;

IF NVL(cEjecutivo,"")= "" THEN
   LET cCod_ret = "102009";
   RETURN cCod_ret;
END IF;*/
     
IF pOrigen NOT IN(1,2,3,5) THEN
   LET cCod_ret = "102010";
   RETURN cCod_ret;
END IF;

IF NVL(pTelefono ,"")= "" THEN
    let cCod_ret = "102011";
    RETURN cCod_ret;
END IF;

-- // Valida que el teléfono sea numerico (válido)
IF bdinteg:val_num(pTelefono) = 'f' THEN
    LET cCod_ret = "30001";
    RETURN cCod_ret;
END IF

-- Se la valida que el telefono no exista 
IF NOT EXISTS (SELECT telefono 
             FROM bdicobranza:cb_telefonos
             WHERE numcte   = pNumcte
             AND telefono = pTelefono
             AND tipo_telefono  = pTipo_telefono) THEN


    SELECT fecha_hoy
    INTO dFecha_hoy
    FROM bdicred:sd_fechas
    WHERE empresa = pEmpresa;

    ---EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (pEmpresa, pTelefono) 
    --INTO wCod_ret , vtipored , vnumero_carrier;
/*
        INSERT INTO bdicobranza:cb_telefonos(empresa,origen,numcte,telefono,tipo_telefono,
                                     extension, tipored, quiencontestouc,estatus,codigo_resultado,
                                     fecha_insert,user_insert, numero_carrier)
        VALUES(pEmpresa,pOrigen,pNumcte,pTelefono,pTipo_telefono,
            pExtension, vtipored, pParentesco,'AC',pResultado_gestion,
            dFecha_hoy,pEjecutivo, vnumero_carrier);  
*/---MAJF Insercion de Telefonos Abril 2012

    execute procedure bdinteg:"informix".sp_registra_telefonos (pEmpresa, pNumcte, pTelefono, pTipo_telefono, pExtension,1, 2, user  )
    into cCod_ret ;

      If cCod_ret = '000' then Let cCod_ret ='00000'; end if;

    --LET cCod_ret = "102012";
    RETURN cCod_ret;
END IF;
   
  RETURN cCod_ret;

END
END PROCEDURE
DOCUMENT
'Descrpcion: Graba un nuevo teléfono proporcionado a la cobranza telefónica',
'Autor:Leonardo Arellano',
'Fecha: 30-09-2010',
'Version:20100927.1300',
'Bdicobranza',
'Autor: Marco A. Campos',
'Modificación: 2012-03-01. Agregar el origen 5 (Buró) en validación de pOrigen';

CREATE PROCEDURE "informix".sp_cat_consulta_saldostc(pEmpresa      CHAR(3),
                                                     pCliente      CHAR(20),
                                                     pNumRegistros INTEGER)

RETURNING CHAR(6)        AS codigo_respuesta, 
          CHAR(2)        AS tipo_producto,
          CHAR(40)       AS producto,
          CHAR(20)       AS num_credito,
          CHAR(20)       AS num_tarjeta,
          DATE           AS Fecha_ult_cargo,
          DECIMAL(18,2)  AS imp_sdo_total,
          DECIMAL(18,2)  AS imp_int_moratorio,
          DECIMAL(18,2)  AS sdo_venc_int_mora,
          DECIMAL(18,2)  AS imp_siguiente_pagomin,
          DECIMAL(18,2)  AS imp_mensual,
          DECIMAL(18,2)  AS imp_vencido,
          SMALLINT       AS num_pagos_vencidos,
          DATE           AS fecha_ultimo_pago,
          DECIMAL(18,2)  AS imp_ultimo_pago,
          SMALLINT       AS tipo_convenio,
          DECIMAL(18,2)  AS importe_min,
          DATE           AS prox_fecha_pago;


DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cEmpresa         CHAR(3);
DEFINE cNumCte          CHAR(20);
DEFINE cEjecutivo       CHAR(10);
DEFINE iRegistros       INTEGER;
DEFINE cMensaje         CHAR(80);
DEFINE cNumCredito      CHAR(20);
DEFINE cNomProducto     CHAR(40);
DEFINE cNumTarjeta      CHAR(20);
DEFINE cNomCte          CHAR(150);
DEFINE iIntAux          INTEGER;
DEFINE cCharAux         CHAR(80);
DEFINE dDecAux          DECIMAL(18,2);
DEFINE dtDateAux        DATE;
DEFINE dImpSdoTotal     DECIMAL(18,2);
DEFINE dImpMensual      DECIMAL(18,2);
DEFINE dImpVdo          DECIMAL(18,2);
DEFINE dImpVdoT         DECIMAL(18,2);
DEFINE dImpIntMora      DECIMAL(18,2);
DEFINE dSdoVdoIntMora   DECIMAL(18,2);
DEFINE dImpSigPagoMin   DECIMAL(18,2);
DEFINE sNumPagosVdos    SMALLINT;
DEFINE dtFechaUltPago   DATE;
DEFINE dtFechaProxPago   DATE;
DEFINE dImpUltPago      DECIMAL(18,2);
DEFINE dtFechaHoy       DATE;
DEFINE sTpoConvenio     SMALLINT;
DEFINE iContador        INTEGER;
DEFINE cTipCred         CHAR(2);
DEFINE cTipCredAux      CHAR(2);
DEFINE dtUltFechaCargo  DATE;
DEFINE cint_vdo         DECIMAL(18,2);
DEFINE civa_int_vdo     DECIMAL(18,2);
DEFINE civa_int_mor     DECIMAL(18,2);
DEFINE dImporte      	DECIMAL(18,2);
DEFINE iMaximo_vencido  INTEGER;
DEFINE dPagoMinimoAux	DECIMAL(18,2);
DEFINE vPorcentaje      DECIMAL(18,2);
DEFINE tipo             char (4);
DEFINE vnumproducto     char (4);
DEFINE vexistenum       char (20);
DEFINE dfecha_insert    DATE;
DEFINE cTipProd6001     CHAR(2);
DEFINE cTipProd6300     CHAR(2);
DEFINE cTipProd6011     CHAR(2);
DEFINE cTipProd6400     CHAR(2);


LET iSqlErr          = 0;
LET iIsamErr         = 0;
LET cErrorInfo       = "";
LET cCodRet          = "000000";
LET cEmpresa         = "";
LET cNumCte          = "";
LET cEjecutivo       = "";
LET iRegistros       = 0;
LET cMensaje         = "";
LET cNumCredito      = "";
LET cNomProducto     = "";
LET cNumTarjeta      = "";
LET cNomCte          = "";
LET iIntAux          = 0;
LET cCharAux         = "";
LET dDecAux          = 0;
LET dtDateAux        = DATE(1);
LET dImpSdoTotal     = 0;
LET dImpMensual      = 0;
LET dImpVdo          = 0;
LET dImpVdoT         = 0;
LET dImpIntMora      = 0;
LET dSdoVdoIntMora   = 0;
LET dImpSigPagoMin   = 0;
LET sNumPagosVdos    = 0;
LET dtFechaUltPago   = DATE(1);
LET dtFechaProxPago  = DATE(1);
LET dImpUltPago      = 0;
LET dtFechaHoy       = DATE(1);
LET sTpoConvenio     = 0;
LET iContador        = 0;
LET cTipCred         = "TV";
LET cTipCredAux      = "";
LET cint_vdo         = 0;
LET civa_int_vdo     = 0;
LET civa_int_mor    = 0;
LET dtUltFechaCargo = DATE(1);
LET dImporte        = 0;
LET iMaximo_vencido = 0;
LET dPagoMinimoAux  = 0;
LET vPorcentaje     = 0;
LET tipo            = '';
LET vnumproducto    = '';
LET vexistenum      = '';
LET cTipProd6001    = '';
LET cTipProd6300    = '';
LET cTipProd6011    = '';
LET cTipProd6400    = '';

--SET DEBUG FILE TO "/tmp/sp_cat_consulta_saldostc.out";
--TRACE ON;

BEGIN  
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;
            RETURN cCodRet, NVL(cTipCred,""), NVL(cNomProducto,""), NVL(cNumCredito,""), NVL(cNumTarjeta,""), NVL(dtUltFechaCargo,0),
                 NVL(dImpSdoTotal,0), NVL(dImpIntMora,0), NVL(dSdoVdoIntMora,0), NVL(dImpSigPagoMin,0), NVL(dImpMensual,0),
                NVL(dImpVdoT,0), NVL(sNumPagosVdos,0), NVL(dtFechaUltPago,DATE(1)), NVL(dImpUltPago,0), NVL(sTpoConvenio,0),NVL(dImporte,0), nvl(dtFechaProxPago, date(1));
        END IF;
    END EXCEPTION;
 

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- Se validan los parámetros de ejecución
    SELECT empresa
        INTO cEmpresa
        FROM bdinteg:"informix".si_empresas
        WHERE empresa= pEmpresa;

    IF cEmpresa IS NULL THEN
        LET cCodRet = "101001";
        RETURN cCodRet, NVL(cTipCred,""), NVL(cNomProducto,""), NVL(cNumCredito,""), NVL(cNumTarjeta,""), NVL(dtUltFechaCargo,0),
             NVL(dImpSdoTotal,0), NVL(dImpIntMora,0), NVL(dSdoVdoIntMora,0), NVL(dImpSigPagoMin,0), NVL(dImpMensual,0),
             NVL(dImpVdoT,0), NVL(sNumPagosVdos,0), NVL(dtFechaUltPago,DATE(1)), NVL(dImpUltPago,0), NVL(sTpoConvenio,0),NVL(dImporte,0), nvl(dtFechaProxPago, date(1));
    END IF;

    SELECT numcte
        INTO cNumCte
        FROM bdinteg:"informix".si_cliente
        WHERE numcte= pCliente;

    IF cNumCte IS NULL THEN
        LET cCodRet = "101003";
        RETURN cCodRet, NVL(cTipCred,""), NVL(cNomProducto,""), NVL(cNumCredito,""), NVL(cNumTarjeta,""), NVL(dtUltFechaCargo,0),
                 NVL(dImpSdoTotal,0), NVL(dImpIntMora,0), NVL(dSdoVdoIntMora,0), NVL(dImpSigPagoMin,0), NVL(dImpMensual,0),
                 NVL(dImpVdoT,0), NVL(sNumPagosVdos,0), NVL(dtFechaUltPago,DATE(1)), NVL(dImpUltPago,0), NVL(sTpoConvenio,0),NVL(dImporte,0), nvl(dtFechaProxPago, date(1));
    END IF;

    IF NVL(pNumRegistros,0) <= 0 THEN
        LET cCodRet = "101006";
        RETURN cCodRet, NVL(cTipCred,""), NVL(cNomProducto,""), NVL(cNumCredito,""), NVL(cNumTarjeta,""), NVL(dtUltFechaCargo,0),
             NVL(dImpSdoTotal,0), NVL(dImpIntMora,0), NVL(dSdoVdoIntMora,0), NVL(dImpSigPagoMin,0), NVL(dImpMensual,0),
             NVL(dImpVdoT,0), NVL(sNumPagosVdos,0), NVL(dtFechaUltPago,DATE(1)), NVL(dImpUltPago,0), NVL(sTpoConvenio,0),NVL(dImporte,0), nvl(dtFechaProxPago, date(1));
    ELSE
        LET iRegistros = pNumRegistros;
    END IF;

    -- Se obtiene la fecha hoy del sistema
    SELECT {+INDEX(bdicred:sd_fechas idx_sdfechas)} fecha_hoy
        INTO dtFechaHoy
        FROM bdicred:"informix".sd_fechas
        WHERE empresa = cEmpresa;

    -- Obtiene los tipos de producto dependiente del numero de producto        
    SELECT valor_alfabetico INTO cTipProd6001 FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
        AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro = 1 AND valor_numerico = 6001;

    --- Obtiene datos del registro marcado en sp sp_cat_consulta_disponibilidad_cliente 
    SELECT first 1 tipo_cobranza, fecha_insert, num_producto, num_credito  
        INTO tipo, dfecha_insert, vnumproducto, cNumCredito
        FROM bdicobranza:"informix". cb_cat_directorio_cte
        WHERE empresa = pempresa
        AND numcte = pCliente 
        AND cobranza_aux_direct = '1';

    IF (nvl(vnumproducto,'') ='') THEN
        SELECT first 1 tipo_cobranza, fecha_insert, num_producto, num_credito
            INTO tipo, dfecha_insert, vnumproducto, cNumCredito
            FROM bdicobranza:"informix".cb_cat_directorio_cte
            WHERE empresa = pempresa
            AND numcte = pCliente;
    END IF;
  
    IF NVL(vnumproducto,'') = '' THEN
        LET vnumproducto = '6001';
    END IF;
  
/*  select first 1 tipo_cobranza into tipo
    from bdicobranza:cb_cat_directorio_cte
    where empresa = pEmpresa
    and numcte = pCliente;

    IF (tipo IN ('R','E')) THEN
        select  num_producto into vnumproducto
		from bdicred:sd_maecredcrd
			where empresa = pempresa and num_credito =
			(select num_credito from bdicobranza:cb_cat_directorio_cte where tipo_cobranza = tipo and  numcte=pCliente);
    ELSE
        select  num_producto into vnumproducto
            from bdicred:sd_maecred
            where empresa = pempresa and num_credito =
                (select num_credito from bdicobranza:cb_cat_directorio_cte where tipo_cobranza = tipo and  numcte=pCliente);
    END IF;
*/
    IF vnumproducto = '6011' THEN
        SELECT valor_alfabetico INTO cTipProd6011 
            FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
            AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro = 3 AND valor_numerico = 6011;

        LET cTipCred = cTipProd6011;

    ELIF vnumproducto = '6300' THEN
        SELECT valor_alfabetico INTO cTipProd6300 
            FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
            AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro = 2 AND valor_numerico = 6300;

        LET cTipCred = cTipProd6300;

    ELIF vnumproducto = '6400' THEN 
        SELECT valor_alfabetico INTO cTipProd6400 
            FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
            AND grupo_parametro = 'TIPOCOBCAT' AND num_parametro = 4 AND valor_numerico = 6400;

        LET cTipCred = cTipProd6400;

    ELSE
        LET cTipCred = cTipProd6001;
        LET vnumproducto = '6001'; 
    END IF

    FOREACH
        -- Se obtienen los datos generales del cliente  
        EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(cEmpresa,cNumCte,cNumCredito,"","","",vnumproducto)
                    INTO cCodRet, cMensaje, cNumCredito, cNumCte, cNomProducto, cNumTarjeta, cNomCte
        IF cCodRet <> "000000" THEN
            LET cCodRet = "101007"; -- Ocurrió un error al ejecutar la consulta de datos general
            RETURN cCodRet, NVL(cTipCred,""), NVL(cNomProducto,""), NVL(cNumCredito,""), NVL(cNumTarjeta,""), NVL(dtUltFechaCargo,0),
                 NVL(dImpSdoTotal,0), NVL(dImpIntMora,0), NVL(dSdoVdoIntMora,0), NVL(dImpSigPagoMin,0), NVL(dImpMensual,0),
                 NVL(dImpVdo,0), NVL(sNumPagosVdos,0), NVL(dtFechaUltPago,DATE(1)), NVL(dImpUltPago,0), NVL(sTpoConvenio,0),NVL(dImporte,0), nvl(dtFechaProxPago, date(1));
        END IF;

        IF tipo in ('R','E') THEN  -- Obtiene el numero de cuenta para tipo cobranza = R  en la variable de Num Tarjeta
            SELECT num_cta INTO cNumTarjeta
                FROM bdicred:sd_ctascarg WHERE num_credito = cNumCredito AND naturaleza= 'A';
        END IF

        IF iContador > iRegistros THEN
            EXIT FOREACH;
        END IF;
        
        -- Se obtienen los datos generales del crédito
        EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(cEmpresa,cNumCredito)
                    INTO cCodRet,cMensaje,cCharAux,cTipCredAux,dtDateAux,dtDateAux,dImpMensual,dtFechaUltPago,
                         iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dImpVdo,dImpVdoT,dDecAux,
                         dDecAux,dDecAux,cint_vdo,dImpIntMora,dDecAux,dDecAux,dDecAux,civa_int_vdo,civa_int_mor,dDecAux,
                         dDecAux,dDecAux,dDecAux,dDecAux,dImpSdoTotal,dDecAux,dDecAux,dDecAux,sNumPagosVdos,cCharAux,
                         iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,cCharAux,cCharAux,iIntAux,
                         cCharAux;


        IF cCodRet <> "000000" THEN
            LET cCodRet = "101005"; -- Ocurrió un error al ejecutar la consulta de saldos general
            RETURN cCodRet, NVL(cTipCred,""), NVL(cNomProducto,""), NVL(cNumCredito,""), NVL(cNumTarjeta,""), NVL(dtUltFechaCargo,0),
                 NVL(dImpSdoTotal,0), NVL(dImpIntMora,0), NVL(dSdoVdoIntMora,0), NVL(dImpSigPagoMin,0), NVL(dImpMensual,0),
                 NVL(dImpVdoT,0), NVL(sNumPagosVdos,0), NVL(dtFechaUltPago,DATE(1)), NVL(dImpUltPago,0), NVL(sTpoConvenio,0),NVL(dImporte,0), nvl(dtFechaProxPago, date(1));
        END IF;
        LET dImpVdoT    = dImpVdoT + dImpVdo; 
        LET dImpIntMora = dImpIntMora + civa_int_mor;
        --calcular el monto nimimo a negociar
		SELECT MAX(Meses_vencido)
            INTO iMaximo_vencido
            FROM bdicobranza:cb_compac_montomin;

        IF sNumPagosVdos > iMaximo_vencido THEN
            LET sNumPagosVdos = iMaximo_vencido;
        END IF;

		LET dPagoMinimoAux = ROUND(dImpMensual);

		SELECT Porcentaje
            INTO vPorcentaje
			FROM bdicobranza:cb_compac_montomin
			WHERE Meses_vencido = sNumPagosVdos
			AND Monto_vencido_min <= dPagoMinimoAux
			AND Monto_vencido_max >= dPagoMinimoAux;

        LET dImporte = (vPorcentaje * dImpMensual)/100;

        -- Se calcula el importe de saldo vencido de interes moratorio
        LET dSdoVdoIntMora = dImpMensual;

        --- calculo de intereses
        LET dImpIntMora = dImpIntMora+ cint_vdo + civa_int_vdo;
        -- Calculo del Saldo correspondiente del mes MAJF Julio 2011
        LET dImpMensual = dImpMensual - (dImpVdot +  dImpIntMora );

        -- Se calcula el importe de pago minimo siguiente
        LET dImpSigPagoMin = dSdoVdoIntMora + dImpMensual;

        SELECT num_credito
            INTO vexistenum
			FROM bdicred:"informix".sd_maecred
			WHERE num_credito = cNumCredito;

        IF (vexistenum = cNumCredito) THEN

            -- Se calcula el importe del último pago realizado en base al día en que se realizó
            IF dtFechaUltPago = dtFechaHoy THEN
                SELECT NVL(SUM(monto),0)
                    INTO dImpUltPago
                    FROM bdicred:sd_movdia
                    WHERE empresa     = cEmpresa
                    AND fecha_mov   = dtFechaUltPago
                    AND num_credito = cNumCredito
                    AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual)
                    AND codigo_ref =1
                    AND reversado = "N";
            ELSE
                SELECT NVL(SUM(monto),0)
                    INTO dImpUltPago
                    FROM bdicred:sd_movhis
                    WHERE empresa     = cEmpresa
                    AND fecha_mov   = dtFechaUltPago
                    AND num_credito = cNumCredito
                    AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual)
                    AND codigo_ref =1
                    AND reversado = "N";
            END IF;

            -- Se obtiene la fecha del último cargo realizado
            SELECT MAX(fecha_mov)
                INTO dtUltFechaCargo
                FROM bdicred:sd_movdia
                WHERE empresa = cEmpresa
                AND num_credito = cNumCredito
                AND codigo_fun ='002'
                AND codigo_ref = 37
                AND reversado = 'N';

            -- Obtener ultima fecha de disposiciones
            IF NVL(dtUltFechaCargo,DATE(1)) = DATE(1) THEN
                SELECT MAX(fecha_mov)
                    INTO dtUltFechaCargo
                    FROM bdicred:sd_movdia
                    WHERE empresa = cEmpresa
                    AND num_credito = cNumCredito
                    AND codigo_fun = '002'
                    AND codigo_ref IN (50,30,40,41,42)
                    AND reversado='N';
            END IF;

            IF NVL(dtUltFechaCargo,DATE(1)) = DATE(1) THEN
                SELECT MAX(fecha_mov)
                    INTO dtUltFechaCargo
                    FROM bdicred:sd_movhis
                    WHERE empresa = cEmpresa
                    AND num_credito = cNumCredito
                    AND codigo_fun ='002'
                    AND codigo_ref = 37
                    AND reversado = 'N';

                IF NVL(dtUltFechaCargo,DATE(1)) = DATE(1) THEN
                    SELECT MAX(fecha_mov)
                        INTO dtUltFechaCargo
                        FROM bdicred:sd_movhis
                        WHERE empresa = cEmpresa
                        AND num_credito = cNumCredito
                        AND codigo_fun = '002'
                        AND codigo_ref IN (50,30,40,41,42)
                        AND reversado='N';
                END IF;
            END IF;
            select prox_fecha_pago into dtFechaProxPago
              from bdicred:sd_maecredanexo
             where empresa = cEmpresa
               AND num_credito = cNumCredito;
        ELSE -- SI NO SE BUSCA EN LA MOVDIACRD

            -- Se calcula el importe del último pago realizado en base al día en que se realizó
            IF dtFechaUltPago = dtFechaHoy THEN
                SELECT NVL(SUM(monto),0)
                    INTO dImpUltPago
                    FROM bdicred:sd_movdiacrd
                    WHERE empresa     = cEmpresa
                    AND fecha_mov   = dtFechaUltPago
                    AND num_credito = cNumCredito
                    AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanualcrd)
                    AND codigo_ref =1
                    AND reversado = "N";
            ELSE
                SELECT NVL(SUM(monto),0)
                    INTO dImpUltPago
                    FROM bdicred:sd_movhiscrd
                    WHERE empresa     = cEmpresa
                    AND fecha_mov   = dtFechaUltPago
                    AND num_credito = cNumCredito
                    AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanualcrd)
                    AND codigo_ref =1
                    AND reversado = "N";
            END IF;

            -- Se obtiene la fecha del último cargo realizado
            SELECT MAX(fecha_mov)
                INTO dtUltFechaCargo
                FROM bdicred:sd_movdiacrd
                WHERE empresa = cEmpresa
                AND num_credito = cNumCredito
                AND codigo_fun ='002'
                AND codigo_ref = 37
                AND reversado = 'N';

            -- Obtener ultima fecha de disposiciones
            IF NVL(dtUltFechaCargo,DATE(1)) = DATE(1) THEN
                SELECT MAX(fecha_mov)
                INTO dtUltFechaCargo
                FROM bdicred:sd_movdiacrd
                WHERE empresa = cEmpresa
                AND num_credito = cNumCredito
                AND codigo_fun = '002'
                AND codigo_ref IN (50,30,40,41,42)
                AND reversado='N';
            END IF;

            IF NVL(dtUltFechaCargo,DATE(1)) = DATE(1) THEN
                SELECT MAX(fecha_mov)
                    INTO dtUltFechaCargo
                    FROM bdicred:sd_movhiscrd
                    WHERE empresa = cEmpresa
                    AND num_credito = cNumCredito
                    AND codigo_fun ='002'
                    AND codigo_ref = 37
                    AND reversado = 'N';

                IF NVL(dtUltFechaCargo,DATE(1)) = DATE(1) THEN
                    SELECT MAX(fecha_mov)
                        INTO dtUltFechaCargo
                        FROM bdicred:sd_movhiscrd
                        WHERE empresa = cEmpresa
                        AND num_credito = cNumCredito
                        AND codigo_fun = '002'
                        AND codigo_ref IN (50,30,40,41,42)
                        AND reversado='N';
                END IF;
            END IF;
             select prox_fecha_pago into dtFechaProxPago
              from bdicred:sd_maecredanexocrd
             where empresa = cEmpresa
               AND num_credito = cNumCredito;
        END IF;

        IF sNumPagosVdos <= 2 THEN
            LET sTpoConvenio = 1; -- Compromiso
        ELSE
            LET sTpoConvenio = 2; -- Acuerdo
        END IF;

        LET iContador = iContador + 1 ;

    END FOREACH;

    -- Elimina marca en el registro que se esta actualizando.
    UPDATE bdicobranza:"informix". cb_cat_directorio_cte
        SET cobranza_aux_direct = ''
        WHERE empresa       = pempresa
        AND numcte          = pCliente
        AND fecha_insert    = dfecha_insert
        AND tipo_cobranza   = tipo;


    RETURN cCodRet, NVL(cTipCred,""), NVL(cNomProducto,""), NVL(cNumCredito,""), NVL(cNumTarjeta,""), NVL(dtUltFechaCargo,DATE(1)),
             NVL(dImpSdoTotal,0), NVL(dImpIntMora,0), NVL(dSdoVdoIntMora,0), NVL(dImpSigPagoMin,0), NVL(dImpMensual,0),
             NVL(dImpVdoT,0), NVL(sNumPagosVdos,0), NVL(dtFechaUltPago,DATE(1)), NVL(dImpUltPago,0), NVL(sTpoConvenio,0),NVL(dImporte,0), nvl(dtFechaProxPago, date(1));

END
END PROCEDURE
DOCUMENT
'Función para consultar saldos en línea',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 29/SEPT/2010',
'BD    : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_migra_evaluacion_objetiva(pFecha date)
       RETURNING char(6), char(80);
 
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info	CHAR(150);
DEFINE	cMensaje		CHAR(80);
DEFINE	cCod_ret		CHAR(6);
DEFINE  vvcCod_ret  CHAR(6);

DEFINE vcantReg		  SMALLINT;
DEFINE pEmpresa     CHAR(3);
DEFINE vtoday       date; 
DEFINE cProceso     CHAR(4); 

DEFINE c_sucursal       CHAR(4);
DEFINE d_fecha_insert  	DATE;
DEFINE c_usuario       	CHAR(8);
DEFINE c_num_credito   	CHAR(20);
DEFINE d_pago_min      	DECIMAL(14,2);
DEFINE d_saldo_vencido 	DECIMAL(14,2);
DEFINE d_pago_realizado	DECIMAL(14,2);
DEFINE d_pct_cump_pm   	DECIMAL(5,2);
DEFINE d_pct_cump_sv   	DECIMAL(5,2);
DEFINE c_folio_suc     	CHAR(16);
DEFINE c_reversado     	CHAR(1);
DEFINE c_folio_suc_2    CHAR(16);
 
DEFINE c_transacc_suc  	CHAR(4);
DEFINE c_codigo_fun     CHAR(3);
DEFINE dt_hora_mov    	DATETIME HOUR to FRACTION(3);  
DEFINE b_migrac_ok      CHAR(1); 
DEFINE i_result         INTEGER;
 
LET cCod_ret      = '000000';
LET sql_err       = 0;
LET isam_err      = 0;
LET error_info    = '';
LET cMensaje      = 'PROCESO EXITOSO';	
LET pEmpresa      = '001';
LET vtoday        = date(1);
LET vvcCod_ret    = '';
LET cProceso      = '0672'; 
LET c_sucursal       ='';
LET d_fecha_insert   = date(1);
LET c_usuario        = '';
LET c_num_credito    = '';
LET d_pago_min       = 0;
LET d_saldo_vencido  = 0;
LET d_pago_realizado = 0;
LET d_pct_cump_pm    = 0;
LET d_pct_cump_sv    = 0;
LET c_folio_suc      = '';
LET c_reversado      = '';
LET c_folio_suc_2    = '';
LET c_transacc_suc   = '';
LET c_codigo_fun     = '';
LET b_migrac_ok      = 'N';  
LET i_result         = 0;
  --SET DEBUG FILE TO '/informix/macf/sp_graba_indicador.trc';
  --TRACE ON;

	
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			      --insert into bdicobranza:cb_bitacora (mensaje) values  (error_info);
            CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensaje, '02') returning vvcCod_ret;
            		
            RETURN cCod_ret, cMensaje;
        END EXCEPTION;		
        
		SET LOCK MODE TO WAIT 3;		
    --select fecha_hoy into vtoday from bdicred:sd_fechas where empresa = '001';
    LET vtoday = pFecha;
  CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensaje, '01')
            RETURNING vvcCod_ret;  


   FOREACH WITH HOLD
      select empresa, sucursal, fecha_insert, usuario, num_credito, pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
             folio_suc, reversado, hora_mov, transacc_suc, codigo_fun 
        into pEmpresa, c_sucursal, d_fecha_insert, c_usuario, c_num_credito, d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,   
             c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun    
        from bdicobranza:cb_evaluacion_objetiva
        where fecha_insert = vtoday
          AND folio_suc not in( select folio_suc 
                                  from bdicobranza:cb_evaluacion_objetiva_his 
                                 where fecha_insert = vtoday)
        
        begin;
            INSERT INTO bdicobranza:cb_evaluacion_objetiva_his(empresa, sucursal, fecha_insert, usuario, num_credito, pago_min, saldo_vencido, pago_realizado, 
                                                           pct_cump_pm, pct_cump_sv, folio_suc, reversado, hora_mov, transacc_suc, codigo_fun) 
            VALUES(pEmpresa, c_sucursal, d_fecha_insert, c_usuario, c_num_credito, d_pago_min, d_saldo_vencido, d_pago_realizado, 
                  d_pct_cump_pm, d_pct_cump_sv, c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun);
        commit;   
        
        LET i_result = i_result + 1; 
        
        --LET b_migrac_ok = 'S';
  END FOREACH;

  LET cMensaje = trim(cMensaje) || '...Número de registros migrados: [ ' || i_result || ' ]';
  
  --CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensaje, '03')
  --          RETURNING vvcCod_ret;
  
  IF i_result > 0 THEN
    BEGIN;  TRUNCATE bdicobranza:cb_evaluacion_objetiva; COMMIT;
  END IF;
  
  begin;
    INSERT INTO bdicobranza:cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(pEmpresa, cProceso, vtoday, cCod_ret, cMensaje, user, today,  current);
  commit;
  
  RETURN cCod_ret, cMensaje;
  
  
 END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Migra la tabla de evaluación objetiva (datos de pago mínimo, saldo vencido y pago realizado para los creds prod. 6001) a histórica de manera diaria.',
'AUTOR : Marco A. Campos. 20140918',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_ctbcpl_gen_arctelefonos(pEmpresa         CHAR(3),
                                                       pTipoCobranza    CHAR(1),
                                                       pFechaGenCartera DATE,
                                                       pStatusTel       CHAR(2))
RETURNING CHAR(6) AS COD_RET;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: Martha A Hernandez
-- Fecha: Noviembre 2011
-- Modificacion: Se modifica proceso para que tome en cuenta tambien el tipo de cobranza R
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: Elizabeth Anzures
-- Fecha: Marzo 2012
-- Modificacion: Se modifica proceso para que no tome clientes con estatus en AT
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: Abrham Lopez L.
-- Fecha: 10 Diciembre 2012
-- Modificacion: Se modifica consulta principal para que a los tipotelefono = 2 les ponga el tipored = 'M'
-- execute procedure sp_ctbcpl_gen_arctelefonos ('001','A','01-20-2015','01');
-----------------------------------------------------------------------------------------------------------------------------------------------------

-- DECLARACIONES
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cCodRet              CHAR(6);
DEFINE cMensaje 		    CHAR(80);
DEFINE cRuta                CHAR(100);
DEFINE cNomArchivo          CHAR(100);
DEFINE cNomArchivoAux       CHAR(100);
DEFINE cNomArchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(100);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cEmpresa             CHAR(3);
DEFINE cDelimitador         CHAR(1);
DEFINE cTipoCampania        CHAR(1);
DEFINE cCodRetIB            CHAR(6);
DEFINE vnumparametro        SMALLINT;

-- INICIALIZACIONES
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cCodRet                 = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET cRuta                   = "";
LET cNomArchivo             = "";
LET cNomArchivoAux          = "";
LET cNomArchivoEjecSql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cEmpresa                = "000";
LET cDelimitador            = "";
LET cTipoCampania           = "";
LET cCodRetIB               = "000000";


BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, error_info
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cMensaje = error_info;
           -- EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02")  INTO cCodRetIB;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    -- DIRECTIVA PARA TENER LECTURA LECTURA DE TABLAS AUNQUE ESTEN BLOQUEADAS
    SET ISOLATION TO DIRTY READ;
    -- DIRECTIVA PARA QUE EXISTA UNA ESPERA DE TRES SEGUNDOS AL ACCESO 
    SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO "/tmp/sp_ctbcpl_gen_arctelefonos.out";
-- TRACE ON;

    --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028","","","01")INTO cCodRetIB;
    
    -- VALIDA LOS PARAMETROS DE ENTRADA   
    IF NVL(pEmpresa,"") = "" OR NVL(pTipoCobranza,"") = "" OR NVL(pFechaGenCartera,"")= "" OR NVL(pStatusTel,"") = "" THEN
        LET cCodRet = "104001";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02")INTO cCodRetIB;
        RETURN cCodRet;
    END IF
    
    LET vnumparametro  =14; 
    IF (pTipoCobranza='A' OR pTipoCobranza='P'  ) THEN  LET vnumparametro  =14; END IF;
    IF (pTipoCobranza='E' OR pTipoCobranza='R'  ) THEN  LET vnumparametro  =16; END IF;

    SELECT empresa INTO cEmpresa
        FROM bdinteg: si_empresas
        WHERE empresa= pEmpresa;

    IF NVL(cEmpresa,'') = '' THEN
        LET cCodRet = "104002";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

       -- EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02")INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    SELECT tipo_cobranza INTO cTipoCampania
        FROM bdicobranza:cb_cat_campania
        WHERE empresa         = pEmpresa
            AND tipo_cobranza = pTipoCobranza
            AND modulo_cob    = 3;

    IF NVL(cTipoCampania,'') = '' THEN
        LET cCodRet = "104003";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
                AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02")INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
   
    -- OBTIENE EL CARACTER SEPARADOR
    SELECT TRIM(valor_alfabetico) INTO cDelimitador
        FROM bdicobranza:cb_param_campania 
        WHERE empresa       = pEmpresa 
        AND tipo_campania   = 1 
        AND grupo_parametro = "ARCHIVOS" 
        AND num_parametro   = 2;
    
    -- VALIDA QUE EXISTA EL CARACTER
    IF NVL(cDelimitador,"") = "" THEN
        LET cCodRet = "104004";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
              AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02") INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    -- OBTIENE LA RUTA DESTINO DEL ARCHIVO
    SELECT TRIM(valor_alfabetico) INTO cRuta
        FROM bdicobranza:cb_param_campania 
        WHERE empresa = pEmpresa
            AND tipo_campania   = 1 
            AND grupo_parametro = "ARCHIVOS" 
            AND num_parametro   = 3;
    
    -- VALIDA QUE EXISTA LA CARPETA
    IF NVL(cRuta,"") = "" THEN
        LET cCodRet = "104005";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02")INTO cCodRetIB;
        RETURN cCodRet;
    END IF

    -- OBTIENE EL NOMBRE DEL ARCHIVO
    SELECT TRIM(valor_alfabetico) INTO cNomArchivo
        FROM bdicobranza:cb_param_campania 
        WHERE empresa         = pEmpresa 
            AND tipo_campania   = 1
            AND grupo_parametro = "ARCHIVOS" 
            AND num_parametro   = vnumparametro;
    
    -- VALIDA QUE EXISTA EL NOMBRE DEL ARCHIVO
    IF NVL(cNomArchivo,"") = "" THEN
        LET cCodRet = "104006";
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

       -- EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028",cCodRet,cMensaje,"02") INTO cCodRetIB;
        RETURN cCodRet;
    END IF
	
	let pFechaGenCartera = date(1);		
	SELECT MAX(fecha_insert) INTO pFechaGenCartera
	FROM bdicobranza:cb_cat_directorio_cte
	WHERE empresa = pempresa
	AND tipo_cobranza = ptipocobranza;

	LET cFechaGenArchivo = TRIM(LPAD(DAY(pFechaGenCartera),2,'0') || LPAD(MONTH(pFechaGenCartera),2,'0') || YEAR(pFechaGenCartera));

    LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'.txt';
    LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '.txt';
    LET cNomArchivoEjecSql = 'Ejecuta_GenArchivoTelefonos_'|| pTipoCobranza || '.sql';
--LET cRuta = '/informix/Elizabeth/';---PRUEBAAAAAA
    LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchivoAux) || " DELIMITER '" || cDelimitador || "' ";

    LET cSQL2 = " SELECT tel.numcte, tel.tipo_tel, 0, substr(tel.telefono,length(tel.telefono)-9,10),  "
                || " tel.extension, decode(tel.tipo_tel,1,'F',2,'M','M'), date(1) fultimocontacto,"  -- A.L.L. Se modifica en los 2 de 'F' a 'M'
                || " '' quiencontestouc, tel.fecha_hora,tel.carrier , tel.secuencia, decode(tel.status_tel,'A',0,1) "
                || " FROM bdicobranza:cb_cat_directorio_cte dir ,bdinteg:si_telefonos_actual tel "
                || " WHERE dir.tipo_cobranza = '" || pTipoCobranza || "' " 
                || " AND dir.fecha_insert = '" || pFechaGenCartera || "' "
                || " AND dir.tipo_logica > 0 "                
                || " AND dir.status_cliente NOT IN ('NT', 'EX') "        		
                || " AND tel.numcte  = dir.numcte "
				|| " AND tel.tipo_tel in (1,2,3) "
                || " AND tel.cofetel= 'V' ";

    LET cSQL3 = ' " > '|| TRIM(cRuta) || cNomArchivoEjecSql;
    
    LET cSQL1 = TRIM(cSQL1);
    LET cSQL3 = TRIM(cSQL3);

    LET cSQL = cSQL1 || cSQL2 || cSQL3;

    -- Verifica que no este vacia la consulta.
    IF ( cSQL <> '' ) THEN 
        SYSTEM cSQL;
        -- Permiso para la creacion de archivo.
        LET cSQL = '' ;
        LET cSQL = 'chmod 666 ' || TRIM(cRuta) || cNomArchivoEjecSql ;
        LET cSQL = '' ;
        LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || cNomArchivoEjecSql ;
        SYSTEM cSQL;
		
		--A.L.L Se le dan permisos al archivo que se genera con el .sql con chmod 777
		LET cSQL = '';
		LET cSQL = 'chmod 666 '|| TRIM(cRuta) || TRIM(cNomArchivoAux);
		SYSTEM cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
        SYSTEM cSql;
		
		--A.L.L Se le dan permisos al archivo final con el chmod 777
		LET cSQL = '';
		LET cSQL = 'chmod 666 '|| TRIM(cRuta) || TRIM(cNomArchivo);
		SYSTEM cSQL;
 
        -- Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cRuta) || cNomArchivoEjecSql || '  ' || TRIM(cRuta) || TRIM(cNomArchivoAux);
        SYSTEM cSQL;

        -- Operacion exitosa "Archivo Generado".
        --EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0028","","","03") INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para generar el archivo de Teléfonos del cliente', 
'AUTOR: Mohamed Carreón ',
'VERSION: 20101109.1545';

CREATE PROCEDURE "informix".sp_migra_tablas_smsmail()
       RETURNING CHAR(6), CHAR(80);

--DEClaracion de variables
-- execute procedure "informix".sp_migra_reporte_smsmail();
------------------------------------------------------------
DEFINE sql_err 			    INTEGER;
DEFINE isam_err 		    INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cMensaje 		    CHAR(100);
define P_MENSAJE			CHAR(80);
DEFINE cCod_ret             CHAR(6);
define v_fecha_hoy			DATE;

----------------------------------------------------------------------
DEFINE vproceso				CHAR(4);
DEFINE Vempresa				CHAR(3);
DEFINE Vnum_campana			SMALLINT;
DEFINE vcliente             CHAR(20);
DEFINE vcredito             CHAR(20);
DEFINE Vproducto			CHAR(4);
DEFINE VfechaEnvio			DATE;
DEFINE vciudad              CHAR(10);
DEFINE vestado              CHAR(10);
DEFINE vt_celular           CHAR(13);
DEFINE cNombre1				CHAR(26);
DEFINE cNombre2				CHAR(26);
DEFINE cApellPat			CHAR(26);
DEFINE cApellMat			CHAR(26);
DEFINE vMora				SMALLINT;
DEFINE vsdo_venc_int_mora   DEC(18,2);
DEFINE vpago_min            DEC(18,2);
DEFINE vpago_min_sin_vdo    DEC(18,2); 
DEFINE vpago_venc           DEC(18,2); 
DEFINE vpago_req_sms		DEC(18,2);
DEFINE vCosto				DEC(18,2);
DEFINE vResultadoEntrega	CHAR(15);
DEFINE vPagoDia1			DEC(18,2);
DEFINE vPagoDia2			DEC(18,2);
DEFINE vPagoDia3			DEC(18,2);
DEFINE vPagoDia4			DEC(18,2);
DEFINE vPagoDia5			DEC(18,2);
DEFINE vPagoNdias			DEC(18,2);
DEFINE vEstatusResultado	CHAR(02);
DEFINE vFechaCambioEstatus  DATE;
DEFINE vResultadoMora		SMALLINT;
DEFINE vFechaApertura		DATE;
DEFINE vFechaPrimerConsumo  DATE;
DEFINE vLineaCredito		DEC(18,2);
DEFINE vTipoTransaccion		CHAR(30);
DEFINE vMontoTransaccion	DEC(18,2);
DEFINE vPorcentaje_uso      DEC(18,2);
DEFINE vCorreoElec			CHAR(100);
DEFINE vPagoReqEmail		DEC(18,2);
DEFINE vCount				INTEGER;
DEFINE vCount1				INTEGER;
DEFINE iCuentasProcesadas     integer; 
DEFINE iCuentasInsertadas     integer; 
DEFINE iCuentasEliminadas     integer; 
DEFINE iCuentasExcluidasXMail integer;
DEFINE iOtrasExclusiones 	  integer;
DEFINE iCuentasExcluidasXCel  INTEGER;
  

--------------------------------------------
LET Vempresa 			= '';
LET Vnum_campana 		= 0;
LET vcliente         	= '';
LET vcredito        	= '';
LET Vproducto 			= '';
LET VfechaEnvio 		= '';
LET vciudad          = '';
LET vestado          = '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET vMora				= 0;
LET vCosto				= 0;
LET vResultadoEntrega	= '';
LET vPagoDia1			= 0;
LET vPagoDia2			= 0;
LET vPagoDia3			= 0;
LET vPagoDia4			= 0;
LET vPagoDia5			= 0;
LET vPagoNdias			= 0;
LET vEstatusResultado	= '';
LET vFechaCambioEstatus = '';
LET vResultadoMora		= 0;
LET vFechaApertura		= '';
LET vFechaPrimerConsumo = '';
LET vLineaCredito		= 0;
LET vTipoTransaccion	= '';
LET vMontoTransaccion	= 0;
LET vPorcentaje_uso		= 0;
LET vCorreoElec			= '';
LET vPagoReqEmail		= 0;
LET vpago_req_sms		= 0;
let vCount1 			= 0;
let iCuentasProcesadas     = 0;
let iCuentasInsertadas     = 0;
let iCuentasEliminadas     = 0; 

let iCuentasExcluidasXMail  = 0;
let iCuentasExcluidasXCel = 0;
---------------------------------------

--SET DEBUG FILE TO 'sp_migra_reporte_smsmail.out';
--TRACE ON;

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	  LET P_MENSAJE      = 'El proceso de MIGRACION DE TABLAS SMSs MAILs se realizó correctamente.';
	  LET vproceso		= '0119';
      --LET pUsuario      = user;
	  let v_fecha_hoy = DATE(1);
 

	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET P_MENSAJE = error_info;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret; 
	        LET cCod_ret = sql_err;
    		RETURN cCod_ret, P_MENSAJE;
		END EXCEPTION;
     
--------------------------------------------------------------------------
--    SELECT fecha_hoy INTO v_fecha_hoy FROM bdinteg:si_fechas;
--------------------------------------------------------------------------

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret; 


        --se obtiene la informacion
		SET ISOLATION TO dirty READ;
        SET LOCK MODE TO WAIT 3;

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
FOREACH with hold
            SELECT empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,num_celular,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_sms,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso 
			INTO Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vt_celular,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vpago_req_sms,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso
            FROM bdicobranza:cb_rep_resultado_sms
			
			--A.L.L.	
			let iCuentasProcesadas = iCuentasProcesadas + 1;
			
---------------SE INCERTAN DATOS GENERADOS----------------------------------------------------------

             BEGIN WORK;
			 INSERT INTO cb_rep_resultado_sms_hist (
                empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,num_celular,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_sms,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso)
			  VALUES(Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vt_celular,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vpago_req_sms,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso);

            let iCuentasInsertadas = iCuentasInsertadas + 1;

			--A.L.L. Borramos los clientes de la tabla cb_rep_resultado_sms 	
			delete bdicobranza:cb_rep_resultado_sms where empresa = Vempresa and num_campana = Vnum_campana and num_credito = vcredito and fecha_envio = VfechaEnvio;

			let iCuentasEliminadas = iCuentasEliminadas +1;
			
			COMMIT WORK;
END FOREACH;

--Genera cifras de control
	    if iCuentasProcesadas > 0 then
	       let cMensaje = 'TOTAL cuentas PROCESADAS SMSs : ' || iCuentasProcesadas;
	       let cMensaje = trim(cMensaje) ||'    TOTAL cuentas INSERTADAS SMSs a histórica : ' || iCuentasInsertadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	       let cMensaje = 'TOTAL cuentas ELIMINADAS SMSs : ' || iCuentasEliminadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	    end if;
--Genera cifras de control
		let iCuentasProcesadas = 0;
		let iCuentasInsertadas = 0;
		let iCuentasEliminadas = 0;
--begin work;
-----------------------------------------------INSERTAR----CB_MAIL_CLIENTE_HIS------------------------------------
	FOREACH with hold
	
		select  empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,correo_elec,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_email,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso
		into 	Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vCorreoElec,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vPagoReqEmail,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso
		from bdicobranza:cb_rep_resultado_mail
		
		let vCount = vCount1 +1;
		--A.L.L.	
		let iCuentasProcesadas = iCuentasProcesadas + 1;
		
        BEGIN WORK;
		insert into bdicobranza:"informix".cb_rep_resultado_mail_hist(
	        empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,correo_elec,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_email,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso)
		values(Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vCorreoElec,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vPagoReqEmail,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso);

		let iCuentasInsertadas = iCuentasInsertadas + 1;
				
		--A.L.L. Borramos los clientes de la tabla cb_mail_cliente 
		delete bdicobranza:cb_rep_resultado_mail where empresa = Vempresa and num_campana = Vnum_campana and num_credito = vcredito and fecha_envio = VfechaEnvio;

		let iCuentasEliminadas = iCuentasEliminadas + 1;

        COMMIT WORK;
	end FOREACH;

	--Genera cifras de control
	    if iCuentasProcesadas > 0 then
	       let cMensaje = 'TOTAL cuentas PROCESADAS MAILs : ' || iCuentasProcesadas;
	       let cMensaje = trim(cMensaje) ||'    TOTAL cuentas INSERTADAS MAILs a histórica : ' || iCuentasInsertadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	       let cMensaje = 'TOTAL cuentas ELIMINADAS MAILs : ' || iCuentasEliminadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	    end if;
--Genera cifras de control

    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_sms;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_sms_hist;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_mail;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_mail_hist;
	

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '03')RETURNING cCod_ret; 
	RETURN cCod_ret, P_MENSAJE;

END;
END PROCEDURE;