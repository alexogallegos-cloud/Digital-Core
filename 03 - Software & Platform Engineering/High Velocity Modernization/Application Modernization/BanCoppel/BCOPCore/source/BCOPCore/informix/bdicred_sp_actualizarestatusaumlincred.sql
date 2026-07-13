CREATE PROCEDURE "informix".sp_actualizarestatusaumlincred(pEmpresa    CHAR(3), 
														   pSolicitud  CHAR(20), 
														   pEjecutivo  CHAR(10), 
														   pEstatus    CHAR(3), 
														   pCausa      CHAR(3), 
														   pComentario CHAR(200))
							
							
RETURNING CHAR(6)  AS codret, 
		  CHAR(80) AS mensaje;			

DEFINE cod_ret     CHAR(6);
DEFINE vCont       SMALLINT;
DEFINE vMen        CHAR(80);
DEFINE sql_err     INTEGER;
DEFINE iIsamErr    SMALLINT;
DEFINE cErrorInfo  CHAR(80);
DEFINE vFecha      DATE;

LET cod_ret        = "000000";
LET vCont          = 0;
LET vMen           = "El proceso se ejecuto correctamente";
LET sql_err        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = "";
LET vFecha         = DATE(1);

BEGIN
ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
    IF sql_err != 0 THEN
        LET cod_ret = sql_err;
        LET vMen= cErrorInfo;
        RETURN cod_ret, vMen;	
    END IF;
END EXCEPTION;
	
-- SET DEBUG FILE TO '/home/sp_ActualizarEstatusAumLinCred.out';
-- TRACE ON ;
	
IF (NVL(pSolicitud,"") = "" OR NVL(pEmpresa,"") = "" OR NVL(pEstatus,"") = "") THEN	
    LET cod_ret = "000002";
    LET vMen    = "Falta parametro obligatorio";
    RETURN cod_ret, vMen;
END IF;
	
SELECT fecha_hoy 
  INTO vFecha 
  FROM bdicred:sd_fechas
 WHERE empresa = pEmpresa;

UPDATE bdicred:sd_prospectos_aumlincred 
   SET status        = pEstatus, 
       fecha_status  = vFecha, 
       comentario    = pComentario 
 WHERE num_solicitud = pSolicitud 
   AND empresa       = pEmpresa;

LET vCont = DBINFO("sqlca.sqlerrd2");

IF vCont = 0 THEN
    LET cod_ret = "000001";
    LET vMen    = "No se encuentra la solicitud";
    RETURN cod_ret, vMen;
END IF;

RETURN cod_ret, vMen;
	
END;
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para actualizar',
'los estatus para el proceso de aumento de',
'linea de crédito',
'AUTOR : Nubia Janeth Montoya Medina ',
'FECHA : 05/JULIO/2010',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_corrige_aumlincred(pEmpresa CHAR(3))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;          
          
DEFINE cEmpresa            CHAR(3);
DEFINE cNumCte             CHAR(20);
DEFINE cNum_cred           CHAR(20);
DEFINE cRiesgo      	   CHAR(02);
DEFINE dMontoOtor          DECIMAL(18,2);
DEFINE dMontoReserva       DECIMAL(18,2);
DEFINE pNum_Vencidos	   INTEGER;
DEFINE p_FechaHoy		   DATE;
DEFINE p_FechaAnt3m		   DATE;
DEFINE p_FechaAnt6m		   DATE;
DEFINE p_FechaAnt12m	   DATE;
DEFINE FechaAnt		 	   DATE;
DEFINE dtfechains		   DATE;
DEFINE cCodRet             CHAR(6); 
DEFINE cMensajeRet         CHAR(80);
DEFINE cComentario         CHAR(80);
DEFINE iSqlErr      	   INTEGER;
DEFINE iIsamErr            INTEGER;
DEFINE cErrorInfo          CHAR(80);
DEFINE LinUtil80		   DECIMAL(18,2);
DEFINE valorsm			   DECIMAL(18,2);
DEFINE cantidadsm		   DECIMAL(18,2);
DEFINE valorsmzonac		   DECIMAL(18,2);
DEFINE cSuc				   CHAR(4);
DEFINE Incprev             SMALLINT;
DEFINE Incprev6m           SMALLINT;
DEFINE utili               DECIMAL(18,2);
DEFINE vStatus			   CHAR(2);
DEFINE cStatus			   CHAR(2);
DEFINE vCausa			   CHAR(3);
DEFINE valorlinutilcred    DECIMAL(18,2);
DEFINE valorreserva        DECIMAL(18,2);
DEFINE valor_reserva       DECIMAL(18,2);
DEFINE diasvigencia        INTEGER;
DEFINE regvigentes         INTEGER;
DEFINE numprod        	   CHAR(4);
DEFINE cUser        	   CHAR(20);
DEFINE sCommit             SMALLINT;
DEFINE contador_commit     INTEGER;
DEFINE sDiasMinimosAper    SMALLINT;
DEFINE sLineaCreditoMin    SMALLINT;
DEFINE sLineaCredito       SMALLINT;
DEFINE sNumIncremPrevios SMALLINT;
DEFINE sLineaUtilizacion SMALLINT;
DEFINE sNumVencidos SMALLINT;
DEFINE pFechaHoyAumlincred DATE;

LET cEmpresa               = "";
LET cNumCte                = "";
LET cNum_cred              = "";
LET cRiesgo                = "";
LET dMontoOtor             = 0;
LET dMontoReserva          = 0;
LET pNum_Vencidos		   = 0;
LET p_FechaHoy			   = DATE(1);
LET dtfechains			   = DATE(1);
LET p_FechaAnt3m		   = DATE(1);
LET p_FechaAnt6m		   = DATE(1);
LET p_FechaAnt12m		   = DATE(1);
LET FechaAnt			   = DATE(1);
LET LinUtil80			   = 0;
--LET paramsm				   = "013";
--LET paramcantsm			   = "012";
--LET paramlinutilcred	   = "019";
--LET paramvigencia	       = "011";
--LET paramreserva	       = "018";
LET valorsm				   = 0;
LET cantidadsm			   = 0;
LET valorlinutilcred	   = 0;
LET cSuc			       = "";
LET Incprev			       = 0;
LET Incprev6m			   = 0;
LET utili			       = 0;
LET vStatus                = "";
LET cStatus                = "";
LET vCausa                 = "";
LET valorreserva	       = 0;
LET valor_reserva	       = 0;
LET diasvigencia	       = 0;
LET regvigentes		       = 0;
LET cComentario            = "";
LET numprod                = "";
LET cUser                  = USER;
LET iSqlErr                = 0;
LET iIsamErr               = 0;
LET cErrorInfo             = "";
LET cCodRet                = "000000";
LET cMensajeRet            = "Se realizó la consulta correctamente";
LET sCommit                = 0;
LET contador_commit        = 0;
LET sDiasMinimosAper       = 0;
LET sLineaCreditoMin       = 0;
LET sLineaCredito      = 0;
LET sNumIncremPrevios = 0;
LET sLineaUtilizacion = 0;
LET sNumVencidos = 0;

--SET DEBUG FILE TO 'sp_corrige_aumlincred.out';
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    LET cCodRet= iSqlErr;
--    LET cMensajeRet= cErrorInfo;
    IF (sCommit = -1) THEN
        rollback work;
    END IF;
    RETURN cCodRet, cMensajeRet;
END EXCEPTION;

--SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT 3;

SELECT pri_dia_mes 
  INTO pFechaHoyAumlincred
  FROM "informix".sd_fechas
 WHERE empresa = pEmpresa;
	  
IF NVL(pEmpresa,"") = "" THEN
    LET cCodRet     = "000011";
	LET cMensajeRet = "Parámetro requerido esta vacío";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtener el valor del salario minimo de la zona C
SELECT valor 
  INTO valorsm
  FROM "informix".sd_param 
 WHERE cod_param = '013'
   AND empresa   = pEmpresa;

-- validacion de los parametros.
IF NVL(valorsm,"")  = "" THEN
    LET cCodRet     = "000001";
	LET cMensajeRet = "Error al obtener el parámetro del valor del salario mínimo";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtener el valor de la cantidad de salarios minimos zona C =1.27
SELECT valor 
  INTO cantidadsm
  FROM "informix".sd_param 
 WHERE cod_param = '012'
   AND empresa   = pEmpresa;

-- validacion de los parametros.
IF NVL(cantidadsm,"") = "" THEN
    LET cCodRet     = "000002";
	LET cMensajeRet = "Error al obtener el parámetro de la cantidad de salarios mínimos";
	RETURN cCodRet, cMensajeRet;
END IF;

-- posteriormente multiplicarlo para obtener la cantidad a numeros reales
LET valorsmzonac = (valorsm * 30.42) * cantidadsm;

-- obtener el valor del procentaje de utilizacion para los créditos
SELECT valor 
  INTO valorlinutilcred
  FROM "informix".sd_param 
 WHERE cod_param = '019'
   AND empresa   = pEmpresa;

-- validacion de los parametros.
IF NVL(valorlinutilcred,"") = "" THEN
    LET cCodRet     = "000003";
	LET cMensajeRet = "Error al obtener el parámetro de la cantidad de utilización de la línea de crédito";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtener el valor del de la reserva
SELECT valor 
  INTO valor_reserva
  FROM "informix".sd_param 
 WHERE cod_param = '018'
   AND empresa = pEmpresa;

-- validacion de los parametros.
IF NVL(valor_reserva,"") = "" THEN
    LET cCodRet     = "000007";
	LET cMensajeRet = "Error al obtener el parámetro del monto de reserva";
	RETURN cCodRet, cMensajeRet;
END IF;

LET valorreserva = (valor_reserva * valorsm) * 30.42;

-- obtener el valor de los dias de vigencia de los créditos
SELECT valor 
  INTO diasvigencia
  FROM "informix".sd_param 
 WHERE cod_param = '011'
   AND empresa = pEmpresa ;

-- validación de los parametros.
IF NVL(diasvigencia,"") = "" THEN
    LET cCodRet     = "000008";
	LET cMensajeRet = "Error al obtener el parámetro de los días de vigencia del crédito";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Días mínimos de apertura de créditos
SELECT valor 
  INTO sDiasMinimosAper
  FROM "informix".sd_param 
 WHERE cod_param = '021'
   AND empresa = pEmpresa ;

IF NVL(sDiasMinimosAper,"") = "" THEN
    LET cCodRet     = "000009";
	LET cMensajeRet = "Error al obtener los días mínimos de apertura de créditos";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Línea de crédito mínimo para incrementos de línea
SELECT valor 
  INTO sLineaCreditoMin
  FROM "informix".sd_param 
 WHERE cod_param = '022'
   AND empresa = pEmpresa ;

IF NVL(sLineaCreditoMin,"") = "" THEN
    LET cCodRet     = "000010";
	LET cMensajeRet = "Error al obtener la línea de crédito mínima para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Compara créd con lín créd MN para increm línea
SELECT valor 
  INTO sLineaCredito
  FROM "informix".sd_param 
 WHERE cod_param = '023'
   AND empresa = pEmpresa ;

IF NVL(sLineaCredito,"") = "" THEN
    LET cCodRet     = "000011";
	LET cMensajeRet = "Error al obtener la línea de crédito a comparar para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Número incrementos previos para increm línea
SELECT valor 
  INTO sNumIncremPrevios
  FROM "informix".sd_param 
 WHERE cod_param = '024'
   AND empresa = pEmpresa ;

IF NVL(sNumIncremPrevios,"") = "" THEN
    LET cCodRet     = "000012";
	LET cMensajeRet = "Error al obtener el número incrementos previos para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;

 -- Número de vencidos 
SELECT valor 
  INTO slineautilizacion
  FROM "informix".sd_param 
 WHERE cod_param = '025'
   AND empresa = pEmpresa ;

IF NVL(slineautilizacion,"") = "" THEN
    LET cCodRet     = "000013";
	LET cMensajeRet = "Error al obtener el número de vencidos para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;


--LET FechaAnt = p_FechaHoy - diasvigencia UNITS DAY;
LET FechaAnt = pFechaHoyAumlincred - diasvigencia UNITS DAY;

--CALL bdicred:monthadd(p_FechaHoy,-6)  RETURNING p_FechaAnt6m;
--CALL bdicred:monthadd(p_FechaHoy,-12) RETURNING p_FechaAnt12m;
CALL bdicred:monthadd(pFechaHoyAumlincred,-3)  RETURNING p_FechaAnt3m;
CALL bdicred:monthadd(pFechaHoyAumlincred,-6)  RETURNING p_FechaAnt6m;
CALL bdicred:monthadd(pFechaHoyAumlincred,-12) RETURNING p_FechaAnt12m;

-- Foreach que obtiene créditos al corriente de pagos
FOREACH WITH HOLD
--Cuenta los incrementos que ha tenido el crédito
     SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_bitacora_fhinsert)} num_solicitud,numcte,status
       INTO cNum_cred,cNumCte,cStatus
       FROM "informix".sd_bitacora_aumlincred 
      WHERE empresa = pEmpresa
        AND fecha_insert = pFechaHoyAumlincred
        AND status IN ('AT','BC')
        AND lincred_actual >= 2100
--        AND lincred_sugerida < 10000
--and num_solicitud in (select num_solicitud from temp_solicitudes)

    IF (sCommit = 0) THEN
        BEGIN WORK;
        LET contador_commit = 0;
        LET sCommit = -1;
    END IF; 

--Se hace commit y update statistics a los 7000 registros insertados en tablas
    IF (contador_commit >= 7000) THEN
       COMMIT WORK;
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_bitacora_aumlincred;
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_autorizacion_aumlincred;
       LET contador_commit = 0;
       BEGIN WORK;
    END IF;

    LET contador_commit = contador_commit  + 1;

     SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_bitacora_status)} nvl(count(status),0)
       INTO Incprev
       FROM "informix".sd_bitacora_aumlincred 
      WHERE numcte  = cNumCte
        AND empresa = pEmpresa
        AND status = 'AP';

--Cuenta con más de 3 incrementos previos
--     IF (Incprev > 3) THEN 
     IF (Incprev > sNumIncremPrevios) THEN 
--Se busca si el crédito tiene una utilización de la línea igual o mayor al 80% en los últimos 12 meses
        SELECT COUNT(num_credito) 
          INTO utili
          FROM "informix".sd_hist_reserva
         WHERE empresa     = pEmpresa
           AND num_credito = cNum_cred
           AND fecha_cierre BETWEEN p_FechaAnt12m AND pFechaHoyAumlincred
           AND porcentaje_uso >= valorlinutilcred;
-- Línea utilización del 80% 
--       IF (utili > 1) THEN
/*
       IF (utili > sLineaUtilizacion) THEN
          LET vStatus     = "PC";
          LET cComentario = "Alta de cliente prospecto";
          INSERT INTO informix.sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,          fecha_status, hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert) 
               VALUES(pEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,                0,           0,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred);
          INSERT INTO informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_insert, revision_cac) 
               VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser,pFechaHoyAumlincred, 0);
          CONTINUE FOREACH;											    		
       ELSE
*/

            IF (utili < sLineaUtilizacion) THEN
               LET vStatus = "RT";
               LET vCausa  = "RUL";
                UPDATE "informix".sd_bitacora_aumlincred 
                   SET status           = vStatus,
                       causa_status     = vCausa,
                       fecha_status     = today,
                       hora_status      = current
                 WHERE fecha_insert    = pFechaHoyAumlincred
                   AND numcte          = cNumCte
                   AND num_solicitud   = cNum_cred
                   AND empresa         = pEmpresa;

                update "informix".sd_autorizacion_aumlincred 
                   SET status           = vStatus,
                       causa_status     = vCausa
                 WHERE fecha_insert    = pFechaHoyAumlincred
                   AND status           = cStatus --'AT'
                   AND num_solicitud   = cNum_cred
                   AND empresa         = pEmpresa;

		let cStatus = '';

               CONTINUE FOREACH;
            END IF;
--       END IF;	

     ELSE
       SELECT COUNT(num_credito) 
         INTO utili
         FROM "informix".sd_hist_reserva
        WHERE empresa        = pEmpresa
          AND num_credito    = cNum_cred
          AND fecha_cierre BETWEEN p_FechaAnt6m AND pFechaHoyAumlincred
          AND porcentaje_uso >= valorlinutilcred;
/*
--        IF (utili >= 1) THEN
        IF (utili >= sLineaUtilizacion) THEN
           LET vStatus     = "PC";
           LET cComentario = "Alta de cliente prospecto";
           INSERT INTO informix.sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status, hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert) 
                VALUES(pEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,    current,      cSuc,     dMontoOtor,                0,           0,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred);
           INSERT INTO informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_insert, revision_cac) 
                VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser,pFechaHoyAumlincred, 0);
           CONTINUE FOREACH;										    		
        ELSE
*/
        IF (utili < sLineaUtilizacion) THEN
           LET vStatus = "RT";
           LET vCausa  = "RUL";
            UPDATE "informix".sd_bitacora_aumlincred 
               SET status           = vStatus,
                   causa_status     = vCausa,
                   fecha_status     = today,
                   hora_status      = current
             WHERE fecha_insert    = pFechaHoyAumlincred
               AND numcte          = cNumCte
               AND num_solicitud   = cNum_cred
               AND empresa         = pEmpresa;

            update "informix".sd_autorizacion_aumlincred 
               SET status           = vStatus,
                   causa_status     = vCausa
             WHERE fecha_insert    = pFechaHoyAumlincred
               AND status           = cStatus --'AT'
               AND num_solicitud   = cNum_cred
               AND empresa         = pEmpresa;

             let cStatus = '';

           CONTINUE FOREACH;
        END IF;

     END IF;

END FOREACH;

  IF sCommit = -1 THEN
     COMMIT WORK;
  END IF;
  LET sCommit = 0;

  UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_bitacora_aumlincred;
  UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_autorizacion_aumlincred;

  LET cMensajeRet            = "Se realizó la consulta correctamente";

  RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener clientes prospectos para incremento de linea de crédito',
'de acuerdo a las validaciones propias de la empresa',
'AUTOR : ',
'FECHA : ',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cantidadadicionales(pNumeroCuenta char(13), pNumeroClienteAdic char(20))
	-- DATOS A REGRESAR

	RETURNING
	char(5),	-- Codigo de retorno
	char(3);
	-- Declaracion de variables

	DEFINE vCodRet		char(5);
	DEFINE vCanReg		char(3);

	-- Se Inicializan las Variables

	LET vCodRet  = "00000";
	LET vCanReg = "000";

	BEGIN
		 -- Se verifica que exista el número de cuenta
		IF EXISTS (SELECT num_credito from bdicred:sd_tarjeta WHERE empresa = '001' and num_credito = pnumerocuenta) THEN

			SELECT COUNT(num_credito)
				INTO vCanReg
				FROM bdicred:sd_tarjeta
				WHERE empresa = '001' and num_credito = pnumerocuenta AND tipo_tarjeta='A' AND status_tar = 'A';

			IF vCanReg IS NULL OR vCanReg = 0 THEN

				LET vCanReg ="001";
				LET vCodRet = "00000";

			ELSE

				IF (vCanReg = 1) THEN

					LET vCanReg ="002";
					LET vCodRet = "00000";
				ELSE
					LET vCanReg ="003";
					LET vCodRet = "00000";
				END IF;
			END IF;

			IF EXISTS (SELECT num_credito from bdicred:sd_tarjeta WHERE empresa = '001' and num_credito = pnumerocuenta AND tipo_tarjeta='A' AND status_tar = 'A'  AND numcte = pNumeroClienteAdic) THEN
				LET vCodRet = "00110";
			END IF;

		ELSE  --Cuenta No existe

			LET vCodRet = "100";
			LET vCanReg ="";
		END IF;
		RETURN vCodRet , vCanReg;
	END;

END PROCEDURE

DOCUMENT
"Elaboro : Adrian Acosta Solis",
"FECHA : 16/Marzo/2007",
"Ver.  : 1.1",
"BD    : bdicred",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_consultar_param(pCod_param CHAR(3))

RETURNING CHAR(6)       AS codigo_error,
          CHAR(80)      AS mensaje_error,
          CHAR(100)     AS periodo;

DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      CHAR(80);
DEFINE cValor           CHAR(100);

--INICIALIZO VARIABLES
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "";
LET cMensajeRet     = "Exito";


 --SET DEBUG FILE TO "sp_consultar_param.out";
 --TRACE ON;

set isolation to dirty read;
set lock mode to wait 3;

BEGIN

  ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
          RETURN cCodRet, cMensajeRet, cValor;
       END IF;
  END EXCEPTION; 

   LET cCodRet = "000000";

   SELECT valor
     INTO cValor
	 FROM "informix".sd_param
	WHERE cod_param = pCod_param
          and empresa = '001';

IF cValor  IS NULL THEN
    LET cCodRet     = '000002';
    LET cMensajeRet = 'Parámetro no existe';
END IF;

RETURN cCodRet, cMensajeRet, cValor;

END;
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'el valor de un parámetro dentro de la tabla sd_param',
'AUTOR : Roque Enrique Solis C.',
'FECHA : 17/Diciembre/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultarcausastatus_perm(p_Status CHAR(2),p_area SMALLINT)
RETURNING
	CHAR(5) AS COD_RET,
	CHAR(2) AS STATUS,
	VARCHAR(40) AS DESC_STA,
	CHAR(3) AS CAUSA,
	VARCHAR(100) AS DESC_CAUSA; 

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE sStatus				CHAR(2);
	DEFINE sDescStatus			VARCHAR(40);
	DEFINE sCausa				CHAR(3);
	DEFINE sDescCausa			VARCHAR(100);
	
	
	---INICIALIZACIONES
	LET v_cod_ret = '00000';
	LET sStatus				= "";
	LET sCausa				= "";
	LET sDescStatus			= "";
	LET sDescCausa			= "";
	

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret, NULL, NULL, NULL, NULL;
    END EXCEPTION;

	
	---SET DEBUG FILE TO "/tmp/has/sp_consultarcausastatus.out";
	---TRACE ON;

	IF p_Status IS NULL THEN
		LET v_cod_ret = "00001";
		RETURN v_cod_ret, NULL, NULL, NULL, NULL;
	END IF
	
	IF p_Status = "" THEN

        IF p_area = 1 THEN
            FOREACH
                SELECT status_solicitud, descripcion, "", ""
                  INTO sStatus, sDescStatus, sCausa, sDescCausa 
                  FROM bdisolic: ss_status_sol 
                 WHERE activa_reporte = "1"
                   and status_solicitud = 'RT'

                ORDER BY status_solicitud

                RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa WITH RESUME;
            END FOREACH
        ELSE
            FOREACH
                SELECT status_solicitud, descripcion, "", ""
                  INTO sStatus, sDescStatus, sCausa, sDescCausa 
                  FROM bdisolic: ss_status_sol 
                 WHERE activa_reporte = "1"
                   and status_solicitud IN ('EE','CE','OS','OA','AT')
                ORDER BY status_solicitud

                RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa WITH RESUME;
            END FOREACH
        END IF

	ELIF p_Status = "#"THEN
        
            FOREACH
                SELECT t2.status_solicitud, t2.causa_solicitud, t2.causa_solicitud ||' ' || t2.descripcion
                  INTO sStatus, sCausa, sDescCausa
                  FROM bdisolic: ss_causas_sol t2
                 WHERE activa_reporte = "1"
                   --AND tipo_auto = "2"
--                    and status_solicitud = 'RT'

                RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa WITH RESUME;
            END FOREACH
/*      ELSE      
            FOREACH 
                SELECT status_solicitud, "", causa_solicitud, causa_solicitud || ' ' || descripcion
                  INTO sStatus, sDescStatus, sCausa, sDescCausa
                  FROM bdisolic: ss_causas_sol
                 WHERE status_solicitud = TRIM(p_Status)
                   AND activa_reporte = "1"
                   AND tipo_auto = "2"

                RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa WITH RESUME;
            END FOREACH
*/
	END IF
END;

END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para consultar los estatus y causas asociadas',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan';

CREATE PROCEDURE "informix".sp_consultarpermisocambiostatuscac(p_Empresa CHAR(3), p_Area CHAR(2))
RETURNING
	CHAR(5) AS COD_RET, 
	CHAR(2) AS AREA,
	CHAR(2) AS STATUS,
	VARCHAR(40) AS DESC_STA,
	CHAR(3) AS CAUSA,
	VARCHAR(100) AS DESC_CAUSA;
	
	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE sStatus				CHAR(2);
	DEFINE sCausa				CHAR(3);
	DEFINE sDescStatus			VARCHAR(40);
	DEFINE sDescCausa			VARCHAR(100);

	---INICIALIZACIONES
	LET v_cod_ret				= '00000';
	LET sStatus					= "";
	LET sCausa					= "";
	LET sDescStatus				= "";
	LET sDescCausa				= "";


BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL;
		
    END EXCEPTION;
	
	---SET DEBUG FILE TO "/tmp/has/sp_consultarpermisocambiostatuscac.out";
	---TRACE ON;

	--- VALIDA QUE EL LA EMPRESA NI EL AREA SEAN CORRECTAS
	IF (p_Empresa = "") OR (p_Empresa IS NULL) OR  (p_Area = "") OR (p_Area IS NULL) THEN
		LET v_cod_ret = "00001";
		RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL;
	END IF
	
	FOREACH
		SELECT t1.status, t2.descripcion as desc_status, t1.causa, t3.descripcion as desc_causa
		INTO sStatus, sDescStatus, sCausa, sDescCausa
		FROM sd_criterios_status_causa_cac t1
		INNER JOIN  bdisolic: ss_status_sol t2 ON (t1.status = t2.status_solicitud)
		LEFT OUTER JOIN bdisolic: ss_causas_sol t3 ON t1.causa = t3.causa_solicitud
		WHERE t1.id_area = p_Area AND t1.empresa = p_Empresa
		ORDER BY t1.status
	
		RETURN v_cod_ret, p_Area, sStatus, sDescStatus, NVL(sCausa,''), NVL(sDescCausa,'') WITH RESUME;
	END FOREACH

END;

END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para consultar los estatus y causas definidas previamente para',
			  'CAC y MC',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan'
;

CREATE PROCEDURE "informix".sp_consultarpermisoscac(p_Empresa CHAR(3), p_Area CHAR(2), p_Tipo CHAR(1))
RETURNING
	CHAR(5) AS COD_RET, 
	CHAR(2) AS AREA,
	CHAR(2) AS TIPO_CRITERIO,
	DECIMAL(5,2) AS VALOR1,
	DECIMAL(5,2) AS VALOR2,
	CHAR(3) AS CONDICION,
	CHAR(2) AS STATUS,
	CHAR(3) AS CAUSA;
	
	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE sValor1				DECIMAL(5,2);
	DEFINE sValor2				DECIMAL(5,2);
	DEFINE Condicion1			CHAR(3);
	DEFINE sTipo_Criterio		CHAR(2);
	DEFINE sStatus				CHAR(2);
	DEFINE sCausa				CHAR(3);

	---INICIALIZACIONES
	LET v_cod_ret				= '00000';

	LET sValor1					= 0.0;
	LET sValor2					= 0.0;
	LET Condicion1				= "";
	LET sTipo_Criterio		= "";
	LET sStatus				= "";
	LET sCausa				= "";

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/hass/sp_consultarpermisoscac.out";
	--TRACE ON;

	--- VALIDA QUE EL LA EMPRESA NI EL AREA SEAN CORRECTAS
	IF (p_Empresa = "") OR (p_Empresa IS NULL) OR  (p_Area = "") OR (p_Area IS NULL) OR (p_Tipo = "") OR (p_Tipo IS NULL) THEN
		LET v_cod_ret = "00001";
		RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
	END IF
	
	IF p_Tipo = "1" THEN
		--- VALIDA QUE EXISTAN CRITERIOS EN EL CATALOGO DE PERMISOS PARA EL AREA EN CUESTION
		IF NOT EXISTS(SELECT id_area FROM bdicred: sd_criterios_consulta_cac WHERE id_area = p_Area AND empresa = p_Empresa) THEN
			LET v_cod_ret = "00002";
			RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		END IF
		
		FOREACH
			SELECT tpo_criterio, valor1, valor2, condicion
			INTO sTipo_Criterio, sValor1, sValor2, Condicion1
			FROM bdicred: sd_criterios_consulta_cac 
			WHERE id_area = p_Area AND empresa = p_Empresa
			ORDER BY tpo_criterio
		
			RETURN v_cod_ret, p_Area, sTipo_Criterio, sValor1, sValor2, Condicion1, NULL, NULL WITH RESUME;
		END FOREACH
	ELIF p_Tipo = "2" THEN
		IF NOT EXISTS(SELECT status FROM sd_criterios_status_causa_cac WHERE id_area = p_Area AND empresa = p_Empresa) THEN
			LET v_cod_ret = "00003";
			RETURN v_cod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		END IF
		
		FOREACH
			SELECT status, causa 
			INTO sStatus, sCausa
			FROM sd_criterios_status_causa_cac 
			WHERE id_area = p_Area AND empresa = p_Empresa
			ORDER BY status
		
			RETURN v_cod_ret, p_Area, NULL, NULL, NULL, NULL, sStatus, sCausa WITH RESUME;
		END FOREACH
	
	END IF
END;

END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para obtener los permisos establecidos para CAC y MC',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan'
;

CREATE PROCEDURE "informix".sp_generarinforeportecac(p_Empresa CHAR(3))
RETURNING CHAR(6)   AS retorno,
          CHAR(200) AS mensaje_ret;

-- CONTROL DE CAMBIOS:

-- Modificó: Viridiana Osobampo
-- Descripción: Se genera información respecto al número de solicitudes que se 
--              se encuentran en Catalogo en Estudio (CE) y su respectivo porcentaje.
-- Fecha modificación: 15-Sep-2010
-- Petición: RQM 09 154-2


	---DECLARACIONES
        DEFINE v_cod_ret            CHAR(6);
        DEFINE iSqlErr              INTEGER;
        DEFINE iSamErr              INTEGER;
        DEFINE cErrorInfo           CHAR(200);

	DEFINE Fecha			DATE;	
        DEFINE cMensaje                 CHAR(200);
        DEFINE sExiste                  SMALLINT;
        DEFINE cSolicitud               CHAR(20);
        DEFINE iRevision                INTEGER;
        DEFINE cStatusAnt               CHAR(2);
        DEFINE cStatusNvo               CHAR(2);
        DEFINE SolAnalizadasCAC         INTEGER;
        DEFINE SolAnalizadasMC          INTEGER;
        DEFINE SolRechazadasCAC         INTEGER;
        DEFINE SolRechazadasMC          INTEGER;
        DEFINE SolEstEE_CAC             INTEGER;
        DEFINE SolEstEE_MC              INTEGER;
        DEFINE SolAut_CAC               INTEGER;
        DEFINE SolAut_MC                INTEGER;
        DEFINE iRegistros               INTEGER;
        DEFINE dPorcSolRT_CAC           DECIMAL(5,2);
        DEFINE dPorcSolEE_CAC           DECIMAL(5,2);
        DEFINE dPorcSolAT_CAC           DECIMAL(5,2);
        DEFINE dPorcSolRT_MC            DECIMAL(5,2);
        DEFINE dPorcSolEE_MC            DECIMAL(5,2);
        DEFINE dPorcSolAT_MC            DECIMAL(5,2);        
        DEFINE iSolEnProceso_CAC        INTEGER;
        DEFINE iSolEnProceso_MC         INTEGER;
        DEFINE dPorcSolEnProc_CAC       DECIMAL(5,2);
        DEFINE dPorcSolEnProc_MC        DECIMAL(5,2);
        DEFINE cArea_CAC                CHAR(2);
        DEFINE cArea_MC                 CHAR(2);

        DEFINE SolCE_CAC                INTEGER;
        DEFINE SolCE_MC                 INTEGER;
        DEFINE dPorcSolCE_CAC           DECIMAL(5,2);
        DEFINE dPorcSolCE_MC            DECIMAL(5,2);

	
	---INICIALIZACIONES
	LET v_cod_ret               = '00000';
        LET iSqlErr                 = 0;
        LET iSamErr                 = 0;
        LET cErrorInfo              = "";
	LET Fecha                   = DATE(1);
        LET cMensaje                = "El proceso se realizó con éxito.";
        LET sExiste                 = 0;
        LET cSolicitud              = ""; 
        LET iRevision               = 0; 
        LET cStatusAnt              = "";
        LET cStatusNvo              = "";
        LET SolAnalizadasCAC        = 0;
        LET SolAnalizadasMC         = 0;
        LET SolRechazadasCAC        = 0;
        LET SolRechazadasMC         = 0;
        LET SolEstEE_CAC            = 0;
        LET SolEstEE_MC             = 0;
        LET SolAut_CAC              = 0;
        LET SolAut_MC               = 0;
        LET iRegistros              = 0;
        LET dPorcSolRT_CAC          = 0;
        LET dPorcSolEE_CAC          = 0;
        LET dPorcSolAT_CAC          = 0;
        LET dPorcSolRT_MC           = 0;
        LET dPorcSolEE_MC           = 0;
        LET dPorcSolAT_MC           = 0;
        LET iSolEnProceso_CAC       = 0;
        LET iSolEnProceso_MC        = 0;
        LET dPorcSolEnProc_CAC      = 0;
        LET dPorcSolEnProc_MC       = 0;
        LET cArea_CAC               = "01";
        LET cArea_MC                = "02";

        LET SolCE_CAC               = 0;
        LET SolCE_MC                = 0;
        LET dPorcSolCE_CAC          = 0;
        LET dPorcSolCE_MC           = 0;

BEGIN

    ON EXCEPTION
        SET iSqlErr, iSamErr,cErrorInfo
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
            LET cMensaje = cErrorInfo;
        END IF;		
        RETURN v_cod_ret,cMensaje;		
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	 --SET DEBUG FILE TO "/tmp/hass/sp_generarinforeportecac.out";
	 --TRACE ON;

    IF NVL(p_Empresa,"") = "" THEN
        LET v_cod_ret = "000001";
        LET cMensaje = "Es necesario que se proporcione información de la empresa.";
        RETURN v_cod_ret,cMensaje;
    END IF;

    SELECT COUNT(empresa)   
      INTO sExiste
      FROM bdinteg:si_empresas
     WHERE empresa = p_Empresa;

     IF sExiste = 0 THEN
        LET v_cod_ret = "000002";
        LET cMensaje = "La empresa indicada no existe.";
        RETURN v_cod_ret,cMensaje;
     END IF;

	SELECT fecha_hoy
	INTO Fecha
	FROM bdicred: sd_fechas;


FOREACH

        SELECT s.num_solicitud, a.revision_cac, ae.status_ant, ae.status_nvo
          INTO cSolicitud, iRevision, cStatusAnt, cStatusNvo
          FROM bdisolic:ss_solicitudes s
        INNER JOIN bdisolic:"informix".ss_autorizacion a ON(a.num_solicitud = s.num_solicitud
                                                             AND a.empresa = s.empresa
                                                             AND a.status_solicitud = s.status_solicitud
                                                             AND a.fecha_entrada = (SELECT MAX(aut.fecha_entrada)
                                                                                      FROM bdisolic:ss_autorizacion aut
                                                                                     WHERE aut.empresa = s.empresa
                                                                                       AND aut.num_solicitud = s.num_solicitud
                                                                                       AND aut.status_solicitud = s.status_solicitud)
                                                             AND a.ejecutivo_auto = a.ejecutivo_auto
                                                             AND a.revision_cac IN (4,5))

        INNER JOIN bdisolic:"informix".ss_autorizacion_especial ae ON(ae.empresa = s.empresa
                                                                       AND ae.num_solicitud = s.num_solicitud
                                                                       AND ae.numcte = s.numcte
                                                                       AND ae.secuencia = (SELECT NVL(MAX(esp.secuencia),0)
                                                                                             FROM bdisolic:ss_autorizacion_especial esp
                                                                                            WHERE esp.empresa = s.empresa
                                                                                              AND esp.num_solicitud = s.num_solicitud
                                                                                              AND esp.numcte = s.numcte)
                                                                       AND ae.status_nvo = s.status_solicitud
                                                                       AND ae.fecha_modif = Fecha)


         IF iRevision = 4 THEN
            
            LET SolAnalizadasCAC = SolAnalizadasCAC + 1;

                IF cStatusNvo = "RT" THEN
                    LET SolRechazadasCAC = SolRechazadasCAC + 1;
                ELIF cStatusAnt = "RT" AND cStatusNvo = "EE" THEN
                    LET SolEstEE_CAC = SolEstEE_CAC + 1;
                ELIF cStatusAnt = "RT" AND cStatusNvo = "AT" THEN
                    LET SolAut_CAC = SolAut_CAC + 1;
                ELIF cStatusAnt = "CE" AND cStatusNvo = "CE" THEN
                    LET SolCE_CAC = SolCE_CAC + 1;
                END IF;            
            
         ELIF iRevision = 5 THEN

            LET SolAnalizadasMC = SolAnalizadasMC + 1;

                IF cStatusNvo = "RT" THEN
                    LET SolRechazadasMC = SolRechazadasMC + 1;
                ELIF cStatusAnt = "RT" AND cStatusNvo = "EE" THEN
                    LET SolEstEE_MC = SolEstEE_MC + 1;
                ELIF cStatusAnt = "RT" AND cStatusNvo = "AT" THEN
                    LET SolAut_MC = SolAut_MC + 1;
                ELIF cStatusAnt = "CE" AND cStatusNvo = "CE" THEN
                    LET SolCE_MC = SolCE_MC + 1;
                END IF; 

         END IF;
        
END FOREACH;

LET iRegistros = DBINFO("sqlca.sqlerrd2");

IF iRegistros = 0 THEN
    LET v_cod_ret = "000003";
    LET cMensaje = "No se encontraron solicitudes atendidas por CAC y MC  el dia de hoy.";
    RETURN v_cod_ret, cMensaje;
END IF;

	IF NVL(SolAnalizadasCAC,0) > 0 THEN
		LET dPorcSolRT_CAC =  (SolRechazadasCAC * 100) / SolAnalizadasCAC;
		LET dPorcSolEE_CAC =  (SolEstEE_CAC * 100) / SolAnalizadasCAC;
		LET dPorcSolAT_CAC =  (SolAut_CAC * 100) / SolAnalizadasCAC;
		LET dPorcSolCE_CAC =  (SolCE_CAC * 100) / SolAnalizadasCAC;
	END IF;

    
	IF NVL(SolAnalizadasMC,0) > 0 THEN
		LET dPorcSolRT_MC = (SolRechazadasMC * 100) / SolAnalizadasMC;
	    LET dPorcSolEE_MC = (SolEstEE_MC * 100)/ SolAnalizadasMC;
	    LET dPorcSolAT_MC = (SolAut_MC * 100) / SolAnalizadasMC;
	    LET dPorcSolCE_MC = (SolCE_MC * 100) / SolAnalizadasMC;
	END IF;
    
    LET sExiste = 0;

    SELECT COUNT(area)
      INTO sExiste
      FROM bdicred: sd_cifras_operaciones
     WHERE empresa = p_Empresa 
       AND fecha = Fecha;

	--- BORRA LOS REGISTROS DE LA ANTERIOR CORRIDA DEL MISMO DIA

      IF sExiste > 0 THEN
           DELETE bdicred: sd_cifras_operaciones 
            WHERE empresa = p_Empresa 
              AND fecha = Fecha;
      END IF;


    --- INSERTA EL RESUMEN DE LAS SOLICITUDES ATENDIDAS POR EL CAC

    INSERT INTO sd_cifras_operaciones (empresa,area,fecha,solicitudes_analizadas,solicitudes_rechazadas,porcentaje_rechazadas,
			solicitudes_ee,porcentaje_ee,solicitudes_autorizadas,porcentaje_at,solicitudes_ce, porcentaje_ce,
                        solicitudes_en_proceso,porcentaje_en_proceso) 
         VALUES (p_Empresa,cArea_CAC, Fecha, SolAnalizadasCAC,SolRechazadasCAC,dPorcSolRT_CAC,
                 SolEstEE_CAC,dPorcSolEE_CAC,SolAut_CAC,dPorcSolAT_CAC,SolCE_CAC,dPorcSolCE_CAC,
                 iSolEnProceso_CAC,dPorcSolEnProc_CAC);

    --- INSERTA EL RESUMEN DE LAS SOLICITUDES ATENDIDAS POR MESA DE CONTROL
    INSERT INTO sd_cifras_operaciones (empresa,area,fecha,solicitudes_analizadas,solicitudes_rechazadas,porcentaje_rechazadas,
			solicitudes_ee,porcentaje_ee,solicitudes_autorizadas,porcentaje_at,solicitudes_ce, porcentaje_ce,
                        solicitudes_en_proceso,porcentaje_en_proceso) 
         VALUES(p_Empresa,cArea_MC, Fecha,SolAnalizadasMC,SolRechazadasMC,dPorcSolRT_MC,
                SolEstEE_MC,dPorcSolEE_MC,SolAut_MC,dPorcSolAT_MC,SolCE_MC,dPorcSolCE_MC,
                iSolEnProceso_MC,dPorcSolEnProc_MC);

RETURN v_cod_ret, cMensaje;

END 
END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para generar información de reportes para CAC y MC',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan'
;

CREATE PROCEDURE "informix".sp_guardarpermisoscac
(
p_Empresa CHAR(3),
p_Area CHAR(2), 
p_Tipo_criterio CHAR(2), 
p_Valor DECIMAL(5,2), 
p_Valor2 DECIMAL(5,2), 
p_Condicion CHAR(3), 
p_Status CHAR(2), 
p_Causa CHAR(3),
p_Tipo CHAR(1)
)

-- Modificación: Se omite asignar una causa en blanco cuando el área a la cual se le guardarán los persmisos sea MC.
-- Autor Modificación: Viridiana Osobampo Aguilar
-- Fecha modificación:  24-01-2011

RETURNING
	CHAR(5) AS CODIGO_RETORNO,
        CHAR(200) AS MENSAJE_RET;

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE iSecuencia           INTEGER;
    DEFINE dMinEfic             DECIMAL(5,2);
    DEFINE dMaxEfic             DECIMAL(5,2);
    DEFINE dMinHist             DECIMAL(5,2);
    DEFINE dMaxHist             DECIMAL(5,2);
    DEFINE dMinScor             DECIMAL(5,2);
    DEFINE dMaxScor             DECIMAL(5,2);
    DEFINE sExiste              SMALLINT;
    DEFINE cMensaje             CHAR(200);


---INICIALIZACIONES
LET v_cod_ret = '00000';
LET iSecuencia		= 0;

LET dMinEfic            = -2;
LET dMaxEfic            = 101;
LET dMinHist            = -1;
LET dMaxHist            = 999;
LET dMinScor            = -1;
LET dMaxScor            = 999;
LET sExiste             = 0; 
LET cMensaje            = "";

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret,cMensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/hass/sp_guardarpermisoscac.out";
	--TRACE ON;
	
    IF NVL(p_Empresa,"") = "" THEN
        LET v_cod_ret = "000001";
        LET cMensaje  = "La información de empresa no es válida.";
        RETURN v_cod_ret,cMensaje;  
    END IF;
	
    SELECT COUNT(empresa)
     INTO sExiste
     FROM bdinteg:si_empresas
    WHERE empresa = p_Empresa;

    IF sExiste = 0 THEN
        LET v_cod_ret = "000002";
        LET cMensaje = "La empresa indicada no existe.";
        RETURN v_cod_ret,cMensaje;  
    END IF;

    IF NVL(p_Area,"") = "" THEN
        LET v_cod_ret = "000003";
        LET cMensaje = "Es necesario indicar el área que realiza el proceso.";
        RETURN v_cod_ret,cMensaje;
    END IF;

    IF p_Valor = 0 AND p_Valor2 <> 0 AND p_Condicion = "<" THEN
        LET p_Valor = DECODE(p_Tipo_criterio,"01",dMinEfic,"02",dMinHist,"03",dMinScor,p_valor);
    END IF;

    IF p_Valor <> 0 AND p_Valor2 = 0 AND p_Condicion = "=" THEN
        LET p_Valor2 = DECODE(p_Tipo_criterio,"01",dMaxEfic,"02",dMaxHist,"03",dMaxScor,p_valor2);
    END IF;

    IF p_Valor = 0 AND p_Valor2 = 0 AND p_Condicion = "TOD" THEN
        LET p_Valor  = DECODE(p_Tipo_criterio,"01",dMinEfic,"02",dMinHist,"03",dMinScor,p_valor);
        LET p_Valor2 = DECODE(p_Tipo_criterio,"01",dMaxEfic,"02",dMaxHist,"03",dMaxScor,p_valor2);
    END IF;

	IF p_Tipo = "9" THEN
		--- INICIALIZA LAS TABLAS DE PERMISOS PUNTUACIONES
		DELETE bdicred: sd_criterios_consulta_cac WHERE id_area = p_Area AND empresa = p_Empresa;
		--- INICIALIZA LAS TABLAS DE PERMISOS STATUS CAUSAS
		DELETE bdicred: sd_criterios_status_causa_cac WHERE id_area = p_Area AND empresa = p_Empresa;
	ELIF p_Tipo = "1" THEN
                SELECT COUNT(id_area )
                  INTO sExiste
                  FROM sd_criterios_consulta_cac 
                 WHERE empresa = p_Empresa 
                   AND id_area = p_Area 
                   AND tpo_criterio = p_Tipo_criterio 
                   AND condicion = p_Condicion;

		IF sExiste > 0 THEN
			LET v_cod_ret = "00004";
                        LET cMensaje = "La condición que se desea insertar ya existe para ese mismo criterio.";
			RETURN v_cod_ret,cMensaje;
		END IF
		
		INSERT INTO bdicred: sd_criterios_consulta_cac 
		(empresa, id_area, tpo_criterio, valor1, valor2, condicion, user_insert, fecha_insert) 
		VALUES (p_Empresa, p_Area, p_Tipo_criterio, p_Valor, p_Valor2, p_Condicion, USER, CURRENT);
		
	ELIF p_Tipo = "2" THEN

                INSERT INTO bdicred: sd_criterios_status_causa_cac 
                (empresa, id_area, status, causa, user_insert, fecha_insert) 
                VALUES (p_Empresa, p_Area, p_Status, p_Causa, USER, CURRENT);	
		
	END IF

	RETURN v_cod_ret,cMensaje;
END;

END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para almacenar los criterios de consulta definidos para',
			  'CAC y MC',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan'
;

CREATE PROCEDURE "informix".sp_valida_criterios_area(pEmpresa CHAR(3),
                                                     pIdArea  CHAR(2))
RETURNING CHAR(6)  AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(80);

DEFINE cEmpresa      CHAR(2);
DEFINE cIdArea       CHAR(2);

LET iSqlErr          = 0;
LET iIsamErr         = 0;
LET cErrorInfo       = "";
LET cCodRet          = "000000";
LET cMensajeRet      = "El area indicada si cuenta con criterios definidos";

LET cEmpresa         = "";
LET cIdArea          = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/home/sysifx/paulq/sp_valida_criterios_area.out";
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
  INTO cEmpresa
  FROM bdinteg:"informix".si_empresas
 WHERE empresa = pEmpresa;

IF cEmpresa IS NULL THEN
   LET cCodRet     = "000001";
   LET cMensajeRet = "La empresa indicada no es valida";
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT id_area
  INTO cIdArea 
  FROM "informix".sd_areas_cac
 WHERE id_area = pIdArea
   AND empresa = pEmpresa;

IF cIdArea IS NULL THEN 
   LET cCodRet     = "000002";
   LET cMensajeRet = "El area indicada no es valida";
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT LIMIT 1 1
  INTO cIdArea
  FROM "informix".sd_criterios_consulta_cac
 WHERE id_area = pIdArea
   AND empresa = pEmpresa;

IF cIdArea IS NULL THEN 
   LET cCodRet     = "000003";
   LET cMensajeRet = "No hay criterios de consulta";
   RETURN cCodRet, cMensajeRet;
END IF;

RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para consultar',
'si el area de consulta tiene definido',
'sus criterios correspondientes',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 12/JULIO/2010',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_validarpermisousuariocac(p_Ejecutivo CHAR(8))
RETURNING
	CHAR(5); ---cod_ret

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	---INICIALIZACIONES
	LET v_cod_ret = '00000';

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret;
    END EXCEPTION;

	
	---SET DEBUG FILE TO "/tmp/has/sp_validarpermisousuariocac.out";
	---TRACE ON;

	IF p_Ejecutivo = "" OR p_Ejecutivo IS NULL THEN
		LET v_cod_ret = "00001";
		RETURN v_cod_ret;
	END IF
	
	IF NOT EXISTS(SELECT ejecutivo FROM bdinteg: si_perfil_ejecut WHERE ejecutivo = p_Ejecutivo AND sistema = "06")  THEN
		LET v_cod_ret = "00002";
		RETURN v_cod_ret;
	END IF
	
	IF NOT EXISTS(SELECT empleado FROM bdicred: sd_super_cancred WHERE empleado = p_Ejecutivo AND status = 1 AND aplicativo = "CCONCAC.EXE") THEN
		LET v_cod_ret = "00003";
		RETURN v_cod_ret;
	END IF
	

	RETURN v_cod_ret;
END;

END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para validar los permisos de usuarios',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan'
;

CREATE PROCEDURE "informix".sp_marca1()
RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_cuenta char(20);
   DEFINE sql_err,isam_err int; 

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_cuenta    = "";



BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;

--SET DEBUG FILE TO '/tmp/img_sol_rec';
--TRACE ON;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

        FOREACH WITH HOLD
            SELECT num_credito
            INTO v_cuenta
            FROM paso_cred_marca1

            BEGIN WORK;

            update bdicred:sd_encabezado_edocta set insertos = '100000000000000' where fecha_emision = today - 3 and num_credito = v_cuenta;

            COMMIT WORK;

        END FOREACH;
END;    

RETURN v_codret;

END PROCEDURE;