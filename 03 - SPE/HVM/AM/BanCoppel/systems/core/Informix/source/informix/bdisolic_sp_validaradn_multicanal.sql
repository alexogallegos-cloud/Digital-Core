CREATE PROCEDURE "informix".sp_validaradn_multicanal (pNumCel  CHAR(20), pSaldo DECIMAL (18,2), pCanal CHAR(1))
RETURNING CHAR(5),          -- Codigo de Retorno
          VARCHAR(160);      -- Mensaje de Retorno

DEFINE cCodRet CHAR(6);
DEFINE cMenRet VARCHAR(160);
DEFINE cNombre CHAR(26);

DEFINE iSqlErr  INTEGER;
DEFINE tpId     INTEGER;
DEFINE cCredBloq   INTEGER;

DEFINE cCanal  CHAR(1);

DEFINE dMontoMax DECIMAL(18,2);

LET cCodRet = '00000';
LET cMenRet = '';
LET cNombre = '';

LET cCanal = '';

LET iSqlErr = 0;
LET tpId    = 0;
LET cCredBloq  = 0;

LET dMontoMax = 0;


BEGIN
ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
      LET cCodRet = iSqlErr;
      RETURN TRIM(cCodRet), cMenRet;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	 
 	--SET DEBUG FILE TO '/home/e90317801/sp_validaradn_multicanal.out';
    --TRACE ON;

IF NVL(pNumCel,'') = '' OR NVL(pSaldo,'') = '' THEN
	RETURN  '00001',cMenRet;
END IF;

 -- SE OBTIENE EL TIPO DE RESPUESTA DEACUERDO AL CANAL DE ENTRADA
SELECT tp_id
INTO tpId
FROM bdisolic:ss_canal_tiporespuesta
WHERE empresa = '001'
AND canal = pCanal;

-- CONSULTA LOS MONTOS MAXIMOS QUE SE PUEDEN OTROGAR EN ANTICIPO DE NOMINA
SELECT monto_max_cred 
INTO dMontoMax
FROM bdicred:"informix".sd_definicion 
WHERE num_producto = '7800';

SELECT a.canal_sol, c.nombre1, NVL(d.id_unidad_prod,0)
INTO cCanal, cNombre, cCredBloq
FROM  bdisolic:ss_solicitudes a, bdisolic:ss_adn_solicitudcuenta b, bdinteg:si_cliente c, bdicred:sd_maecred d
WHERE b.movil_cuenta  = pNumCel
AND b.num_solicitud = a.num_solicitud
AND a.num_solicitud = d.num_credito
AND a.numcte = c.numcte
AND a.empresa = '001';

-- VALICACION PARA SABER SI QUIEN PIDE LA DISPOSICION ES EX-EMPLEADO
IF cCredBloq = 3 THEN
    SELECT cod_return, mensaje
    INTO cCodRet, cMenRet
    FROM bdisolic:ss_catalogo_mensajes
    WHERE empresa = '001'
    AND cod_msj = 'ADN_15';
    -- Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta.
    RETURN cCodRet, cMenRet;
END IF;

-- VALIDACIÃN DE CANAL NULO PS: Falta asignar codigo controlado y si llevara descripciÃ³n.
IF cCanal IS NULL OR cCanal = '' THEN
    SELECT cod_return, mensaje
    INTO cCodRet, cMenRet
    FROM bdisolic:ss_catalogo_mensajes
    WHERE empresa = '001'
    AND cod_msj = 'ADN_15';
    -- Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta.
    RETURN cCodRet, cMenRet;
END IF;

-- VALIDA QUE NO EL MONTO SOLICITADO NO SEA MAYOR A 5 DIGITOS O QUE PIDA MAS DE MONTO MAXIMO
IF pSaldo > dMontoMax THEN

    IF tpId = 1 THEN
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('1' , 'ADN_SMS','ADN_SMS_19', '000000000','', '','1', TRIM(cNombre), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0,current, current) INTO cCodRet;
        --(Nombre), tu solicitud de Anticipo de Nomina no fue procesada. Verifica que la cantidad no exceda el limite de credito y vuelve a intentar.

        IF cCodRet = '000' THEN
            LET cCodRet = '00000';
        END IF;

        RETURN cCodRet, cMenRet;
    ELIF tpId = 2 THEN
        SELECT cod_return, mensaje
        INTO cCodRet, cMenRet
        FROM bdisolic:ss_catalogo_mensajes
        WHERE empresa = '001'
        AND cod_msj = 'ADN_19';

        RETURN cCodRet, (TRIM(cNombre)||cMenRet);
    ELSE
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('1' , 'ADN_SMS','ADN_SMS_19', '000000000','', '','1', TRIM(cNombre), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0,current, current) INTO cCodRet;
        --(Nombre), tu solicitud de Anticipo de Nomina no fue procesada. Verifica que la cantidad no exceda el limite de credito y vuelve a intentar.

        SELECT cod_return, mensaje
        INTO cCodRet, cMenRet
        FROM bdisolic:ss_catalogo_mensajes
        WHERE empresa = '001'
        AND cod_msj = 'ADN_19';
        
        RETURN cCodRet, (TRIM(cNombre)||cMenRet);
    END IF;
END IF;

IF cCanal IN ('3','5') THEN
    LET cCanal = '1';
END IF;

IF pCanal != cCanal THEN

    IF tpId = 1 THEN
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('1' , 'ADN_SMS','ADN_SMS_18', '000000000','', '','1', TRIM(cNombre), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0,current, current) INTO cCodRet;
        --(Nombre del cliente) tu anticipo de nomina no puede ser procesado via SMS, realiza tu solicitud desde la App BanCoppel http://bit.ly/35gTZpT

        IF cCodRet = '000' THEN
            LET cCodRet = '00000';
        END IF;

        RETURN cCodRet, cMenRet;
    ELIF tpId = 2 THEN
        SELECT cod_return, mensaje
        INTO cCodRet, cMenRet
        FROM bdisolic:ss_catalogo_mensajes
        WHERE empresa = '001'
        AND cod_msj = 'ADN_18';

        RETURN cCodRet, (TRIM(cNombre)||cMenRet);
    ELSE
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('1' , 'ADN_SMS','ADN_SMS_18', '000000000','', '','1', TRIM(cNombre), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0,current, current) INTO cCodRet;
        --(Nombre del cliente) tu anticipo de nomina no puede ser procesado via SMS, realiza tu solicitud desde la App BanCoppel http://bit.ly/35gTZpT

        SELECT cod_return, mensaje
        INTO cCodRet, cMenRet
        FROM bdisolic:ss_catalogo_mensajes
        WHERE empresa = '001'
        AND cod_msj = 'ADN_18';
        
        RETURN cCodRet, (TRIM(cNombre)||cMenRet);
    END IF;
END IF;

EXECUTE PROCEDURE sp_validaradn(pNumCel, pSaldo) INTO cCodRet, cMenRet;

RETURN cCodRet, cMenRet;

END
END PROCEDURE
