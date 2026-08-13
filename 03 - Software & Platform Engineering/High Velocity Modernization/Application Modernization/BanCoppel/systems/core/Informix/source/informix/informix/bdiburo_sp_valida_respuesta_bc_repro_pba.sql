CREATE PROCEDURE "informix".sp_valida_respuesta_bc_repro_pba(pEmpresa CHAR(3),pFechaHoyAumlincred DATE)

RETURNING CHAR(6), 	 -- Codigo de Retorno
		  VARCHAR(255);  -- Descripcion del error

--------------------------------------------------------------------------------
-- Autor: Jesús Manuel Aguilar Heredia
-- Se valida la respuesta de buro de crédito para los clientes que  fueron prospectos a un incremento en su linea de crédito.
-- Fecha de Creación: Junio-2010
-- Proyecto: Aumento de lineas de credito folio 1159
--------------------------------------------------------------------------------
-- Autor: Jesús Manuel Aguilar Heredia
-- Modificación: Se modifica para contemplar los incrementos automaticos para clientes que tengan activa esta opcion, 
-- Fecha de modificación: 04-03-2011
-- Proyecto: 1229-IncrementosAutLinCredTDC
----------------------------------------------------------------------------------
-- Autor: Jesús Manuel Aguilar Heredia
-- Modificación: Se modifica para activar la opcion de envio a supervicion cac  a clientes que requieran ser consultados
-- Fecha de modificación: 28-09-2011
-- Proyecto: 1286-IncrementoLinCredSIF
----------------------------------------------------------------------------------
-- Autor: Josué Remberto Zazueta Acosta
-- Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían, Se implementan reglas de informix
-- Fecha de modificación: 02/Octubre/2012
-- BD : bdicred
----------------------------------------------------------------------------------

--****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret      CHAR(5);
DEFINE cCodRet       CHAR(6); 
DEFINE vsqlerr       INTEGER;
DEFINE sql_err       SMALLINT;
DEFINE isam_err      SMALLINT;

DEFINE error_info    CHAR(100);
DEFINE s_califica    CHAR(1);
DEFINE s_compromisos DECIMAL(14,2);
DEFINE vStatus	     CHAR(2);
DEFINE cUser         CHAR(10);

DEFINE vStatusAnt    CHAR(2);
DEFINE vMensaje      VARCHAR(255);
DEFINE vCuantos      SMALLINT;
DEFINE vMoneda       CHAR(2);

DEFINE vMonto        DECIMAL(14,2);
DEFINE vMontoUdis    DECIMAL(14,2);
DEFINE vCodUdi       CHAR(2);
DEFINE vCodUs        CHAR(2);
DEFINE vClase        CHAR(1);

DEFINE vTpCambioUdi  DECIMAL(14,6);
DEFINE vTpCambioUs   DECIMAL(14,6);
DEFINE vMaxMtoUdi    DECIMAL(14,2);
DEFINE vTl11         CHAR(1);
DEFINE vTl16         DATE;
DEFINE vTl17         DATE;
DEFINE vfecha        DATE;
--DEFINE vFechaHoy     DATE;

DEFINE vTl26         CHAR(2);
DEFINE vTl27		CHAR(24);
DEFINE vTl30         CHAR(2);
define vRespuesta    INTEGER;
DEFINE cTpSolicitud     CHAR(1);
define vDescripcion_status char(40);
define i            integer;
define vmesescon    integer;
define vmescuenta   integer;
define v_sc01       varchar(04);
DEFINE sCommit                       SMALLINT;
DEFINE contador_commit               INTEGER;
DEFINE 	cNumcliente		 CHAR(20);
DEFINE 	cNumcred		     CHAR(20);
DEFINE cstatus           CHAR(2);
DEFINE vCausa			 CHAR(3);
DEFINE cComentario       CHAR(80);
DEFINE vSC01         CHAR(4);
DEFINE sLineaCreditoCAC      INTEGER;
DEFINE dLineaSugerida        DECIMAL(18,2);
DEFINE cIncreAuto CHAR(1);
DEFINE cSucursal CHAR(4);
DEFINE cPregunta CHAR(200);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret      = "00000";
LET cCodRet       = "000000";
LET vsqlerr       = 0;
LET s_califica    = "X";
LET s_compromisos = 0;

LET vStatus       = "";
LET vStatusAnt    = "";
LET vMontoUdis    = 0;
LET vTpCambioUs    = 0;
LET cTpSolicitud  = "";
let vDescripcion_status = "";
let v_sc01       = "";
--LET vFechaHoy     = DATE(1);
LET vClase       = "";
LET sCommit                 = 0;
LET contador_commit         = 0;
LET	cNumcliente	= "";
LET	cNumcred		= "";
LET	cstatus     = "";
LET	vCausa		= "";
LET	cComentario = "";
LET vSC01       = "";
LET cUser                    = USER;
LET sLineaCreditoCAC  = 0;
LET dLineaSugerida  		 = 0;
LET cIncreAuto  		 = "";
LET cSucursal  		 = "";
LET cPregunta  		 = "";

--SET DEBUG FILE TO "sp_valida_respuesta_bc_prueba.out";
--TRACE ON;

SELECT TRIM(valor)::integer
  INTO vmesescon
  FROM bdiburo:"informix".br_param
 WHERE cod_param = 12;

   IF vmesescon IS NULL THEN
      LET vmesescon=12;
   END IF;

      -- *****************************************

      --       Extrae Tipo de Cmabio Divisa      *
      -- *****************************************
SELECT TRIM(valor) 
  INTO vCodUdi
  FROM bdinteg:"informix".si_param
 WHERE empresa = pEmpresa
   AND cod_param = 16;

SELECT TRIM(valor) 
  INTO vCodUs
  FROM bdinteg:"informix".si_param
 WHERE empresa = pEmpresa
   AND cod_param = 17;

SELECT valor 
  INTO sLineaCreditoCAC
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '028'
   AND empresa = pEmpresa ;


      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
      SELECT TRIM(valor) INTO vClase
	    FROM bdicred:"informix".sd_param
       WHERE empresa = pEmpresa
	     AND cod_param = "336";

    EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, pFechaHoyAumlincred,vCodUdi,vClase,'0')
    INTO scod_ret,vTpCambioUdi;

    IF scod_ret<>'00000' THEN
      RETURN scod_ret, "NO SE ENCONTRO VALOR DE UDI";
    END IF;

    EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, pFechaHoyAumlincred,vCodUs,vClase,'1')
    INTO scod_ret,vTpCambioUs;

    IF scod_ret<>'00000' THEN
      RETURN scod_ret, "NO SE ENCONTRO VALOR DE USA";
    END IF;

SELECT valor 
  INTO vMaxMtoUdi
  FROM bdisolic:ss_param
 WHERE empresa = pEmpresa
   AND secuencia = "309";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
--      SET DEBUG FILE TO "CargoLineaCredito.err";
      LET scod_ret = sql_err;

      IF (sCommit = -1) THEN
          rollback work;
      END IF;

      RETURN scod_ret, vMensaje;
   END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

-- ***********************************************
-- Ini Caja Unica
-- ***********************************************

LET vMensaje      = "";
--se modifica la consulta principal para obtener el valor de la sucursal deonde se origino el credito y el valor que indica si tiene activo los incrementos automaticos.
FOREACH WITH HOLD
    SELECT a.numcte, a.num_solicitud,b.ajuste_de_cuota,b.sucursal,a.institucion
		INTO cNumcliente, cNumcred ,cIncreAuto,cSucursal, vDescripcion_status
	FROM bdiburo:"informix".br_respuesta_bc a
    INNER JOIN bdisolic:"informix".ss_solicitudes b on b.empresa = '001' AND b.num_solicitud = a.num_solicitud 
	 WHERE a.institucion='BC' 
       AND a.fecha_insert = pFechaHoyAumlincred

    LET s_califica  = "X";
    LET vMensaje = cNumcred || ' VALIDA_RESPUESTA_BURÓ';

    IF EXISTS (SELECT num_solicitud FROM bdicred:"informix".sd_bitacora_aumlincred WHERE fecha_insert = pFechaHoyAumlincred AND num_solicitud = cNumcred AND empresa = pEmpresa AND status = "RT" AND origen = "C") THEN CONTINUE FOREACH; END IF; 

    SELECT lincred_sugerida INTO dLineaSugerida 
    FROM bdicred:"informix".sd_bitacora_aumlincred 
    WHERE empresa = pEmpresa
    AND num_solicitud = cNumcred 
    AND status = "BC"
    AND fecha_insert = pFechaHoyAumlincred 
    AND origen = "C";

    IF dLineaSugerida IS NULL or dLineaSugerida = '' THEN CONTINUE FOREACH; END IF; 

--Se cancelan las solicitudes cuya respuesta de Buró hayan sido por error
    IF cNumcliente IS NULL THEN
		LET s_califica = "1";
		LET vMensaje = 'SOLICITUD CON ERROR EN BURÓ DE CRÉDITO';

		LET cstatus     = "CN";
		LET vCausa      = "CEV";
		LET cComentario = "CANCELADO POR EVENTUALIDADES";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

       CONTINUE FOREACH;
	END IF


    IF (sCommit = 0) THEN
        BEGIN WORK;
        LET contador_commit = 0;
        LET sCommit = -1;
    END IF; 

     LET contador_commit = contador_commit  + 1;

     IF (contador_commit >= 7000) THEN
        COMMIT WORK;
--        UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_bitacora_aumlincred;
        LET contador_commit = 0;
        BEGIN WORK;
     END IF;

	LET vCuantos = 0;
	LET vMensaje = "CREDITOS CON ANTECEDENTES EN "|| trim(vDescripcion_status)|| ":" ;
	FOREACH
            SELECT tl11, 
                   NVL(tl26,''), 
                   NVL(substr(NVL(tl27,''),1,vmesescon),''),
                   round(CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (NVL(b.tl24,0) * factor)/vTpCambioUdi
                              WHEN tl08 = 'US'                THEN ((NVL(b.tl24,0) * vTpCambioUs) * factor) /vTpCambioUdi
                              WHEN tl08 = 'UD'                THEN   NVL(b.tl24,0) * factor
                              ELSE NVL(b.tl24,0) * factor
                          END,2),
                   tl16,tl17,fecha
              INTO vTl11, vTl26, vTl27, vMontoUdis,vTl16,vTl17,vfecha
          	  FROM bdiburo:"informix".br_tl_bc b, bdisolic:"informix".ss_circulo_frecpag c
         	 WHERE b.numcte  = cNumcliente
          	   AND NVL(tl26,'') <> ''
               AND b.tl11=c.tipo
             ORDER BY tl26 DESC
-- MOP ACTUAL

        IF vMontoUdis >= vMaxMtoUdi AND vTl26 = '03' THEN -- Solo aplica para MOP 02
            LET vCuantos = 1;
            LET vMensaje = trim(vMensaje)||"Mto Max Udi:" || vMaxMtoUdi ||"Mto Udi Cte MOP_03:" || vMontoUdis;
            EXIT FOREACH;
        END IF

       IF NOT EXISTS(SELECT codigo
                       FROM bdiburo:br_tlmop
                      WHERE codigo = vTl26
                        AND status_cons IN (0,2,3)) THEN
          LET vCuantos = 1;
          LET vMensaje = TRIM(vMensaje) || ' P:' || TRIM(vTl26);

          EXIT FOREACH;
       END IF;

-- MOP HISTORICO

       let i = 0;
      
       IF vTl17 IS NOT NULL AND vfecha IS NOT NULL THEN
          LET vmescuenta = ROUND((vfecha-vTl17)/30,0);
           IF vmescuenta > vmesescon THEN
              LET vmescuenta = -1;
           ELSE
              LET vmescuenta = vmesescon - vmescuenta;
           END IF;
       END IF;

       for i = 1 TO LENGTH(TRIM(vTl27))  -- se revisan los últimos 12 meses
          let vTl26 = SUBSTR(vTl27,i,1);

          IF NOT EXISTS(SELECT codigo FROM bdiburo:"informix".br_tlphp
                          WHERE codigo=vTl26
                            AND status_cons in (-1,0,2,3)) THEN
                 IF vTl26 = 4 THEN
                    IF i <= vmescuenta AND vTl17 IS NULL AND vMontoUdis >= vMaxMtoUdi THEN
                         LET vCuantos = 1;
                         LET vMensaje = TRIM(vMensaje) || ' P:' || TRIM(vTl26);
                         EXIT FOREACH;
                    END IF;
                 ELSE
                     LET vCuantos = 1;
                     LET vMensaje = TRIM(vMensaje) || ' P:' || TRIM(vTl26);
                     EXIT FOREACH;
                 END IF;
           END IF;
       END FOR;

	END FOREACH;

	IF vCuantos > 0 THEN
		LET s_califica = "1";
		LET vMensaje = trim(vMensaje);

		LET cstatus     = "RT";
		LET vCausa      = "RBC";
		LET cComentario = "Rechazado Por Buro de Crédito";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

         CONTINUE FOREACH;
	END IF

	-- *******************+*******************************************
	-- Determina si el Cliente tiene claves de exclusion eb BC-SCORE *
	-- ***************************************************************

	LET vCuantos = 0;
--	LET vMensaje = "Rechazo por malos antecedentes en Buro de Credito";

    select sc01
      into v_sc01
      from bdiburo:"informix".br_sc_bc
     where numcte = cNumcliente;

    IF ( v_sc01 is not null ) then
         IF EXISTS(SELECT codigo
                     FROM bdiburo:"informix".br_scvsc
                    WHERE codigo = v_sc01
                      AND status_cons = 1) THEN
            LET vCuantos = 1;
         END IF;
    END IF;

	IF vCuantos > 0 THEN
		LET s_califica = "1";
		LET vMensaje = "RECHAZO POR MALOS ANTECEDENTES " || trim(vDescripcion_status) || ":" || vMensaje;

		LET cstatus     = "RT";
		LET vCausa      = "RBC";
		LET cComentario = "RECHAZADO POR BURO DE CRÉDITO";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

         CONTINUE FOREACH;
	END IF
	-- *******************+*********************************
	-- Determina si el Cliente tiene creditos inaceptables *
	-- *****************************************************
   LET vCuantos = 0;
  --LET vMensaje = "Creditos con Claves de Prevencion:";
   FOREACH 
      SELECT b.tl30 
        INTO vStatus
        FROM bdisolic:"informix".ss_circulo_status a, bdiburo:"informix".br_tl_bc b
       WHERE b.numcte  = cNumcliente
         AND a.status = b.tl30
         AND a.rango_rechazo = "1"

       LET vCuantos = vCuantos + 1;

       IF vStatus <> vStatusAnt THEN
           LET vMensaje = TRIM(vMensaje) || ' ' || TRIM(vStatus);
           LET vStatusAnt = vStatus;
       END IF
   END FOREACH

   IF vCuantos > 0 THEN
       LET s_califica = "1";
	   LET vMensaje = "CREDITOS CON CLAVES DE PREVENCION " || trim(vDescripcion_status) || ":" || vMensaje;

		LET cstatus     = "RT";
		LET vCausa      = "RBC";
		LET cComentario = "RECHAZADO POR BURO DE CRÉDITO";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

        CONTINUE FOREACH;
   END IF

    -- *****************************************************
    -- Determina si el Cliente tiene creditos inaceptables *
    -- por status de circulo de credito	               *
    -- *****************************************************
   LET vCuantos = 0;
   LET vMensaje = "";

   FOREACH 
     SELECT tl11,tl26, tl30 
       INTO vTl11,vTl26, vTl30
       FROM bdiburo:"informix".br_tl_bc b
      WHERE b.numcte  = cNumcliente
 --        AND NVL(tl11,'') <> '' -- finalidad de descartar los creditos de los cuales requiere una
        AND NVL(tl26,'') <> '' -- una autorizacion del analista

       LET vRespuesta = 0;
       SELECT count(status)
         INTO vRespuesta
         FROM bdisolic:"informix".ss_circulo_status 
        WHERE status = vTl30              -- se agrega la validacion del status
          AND rango_rechazo IN ('2','3'); --  y el rango de rechazo sea diferente de 2 con la

       IF vRespuesta IS NULL OR vRespuesta = 0 THEN
           IF NOT EXISTS(SELECT status 
                           FROM bdisolic:"informix".ss_circulo_exceppago
                          WHERE empresa=pEmpresa
                            AND status <> 0
                            AND frecpago = vTl11
                            AND perpago = vTl26) THEN

                   LET vCuantos = vCuantos + 1;
                   LET vMensaje = TRIM(vMensaje)
                               || ' F:' || TRIM(vTl11)
                               || ' P:' || TRIM(vTl26);
           END IF;
       END IF;
   END FOREACH

   IF vCuantos > 0 THEN
       LET s_califica = "1";
	   LET vMensaje = "CREDITOS CON ANTECEDENTES " || trim(vDescripcion_status) || ":" || vMensaje;
		LET cstatus     = "RT";
		LET vCausa      = "RBC";
		LET cComentario = "RECHAZADO POR BURO DE CRÉDITO";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

        CONTINUE FOREACH;
   END IF
    -- *******************+**************************************
    -- Determina si el Cliente tiene creditos con los cuales se *
    -- requiera una autorizacion de analista		    *
    -- *******************+***************************************
   LET vCuantos = 0;
   LET vMensaje = "";
   FOREACH 
     SELECT b.tl30 
       INTO vStatus -- SELECT b.tl07 INTO vStatus
       FROM bdisolic:"informix".ss_circulo_status a, bdiburo:"informix".br_tl_bc b
      WHERE b.numcte  = cNumcliente
        AND a.status = b.tl30 -- se modifica a.status = b.tl07
        AND a.rango_rechazo = "2"

       LET vCuantos = vCuantos + 1;
       IF vStatus <> VstatusAnt THEN
           LET vMensaje = TRIM(vMensaje) || ' ' || TRIM(vStatus);
           LET vStatusAnt = vStatus;
       END IF
   END FOREACH

   IF vCuantos > 0 THEN
       LET s_califica = "2";
	   LET vMensaje = "CREDITOS CON ANTECEDENTES " || trim(vDescripcion_status) || ":" || vMensaje;
   END IF

    -- **************************************************************
    -- Determina crediitos que se encuentren en status con rango de *
    -- rechazo 3 y no excedan del monto en udis determinado		*
    -- **************************************************************
   LET vCuantos = 0;
   LET vMensaje = "";
    --- se modifica el FOREACH en el campo vMonto para la condicion de la sumatoria

        SELECT ROUND(SUM(CASE WHEN b.tl30 <> 'CV' AND tl08 = 'N$' OR tl08 = 'MX' THEN ((NVL(b.tl36,0) + NVL(b.tl24,0)) * factor)/vTpCambioUdi
                                ELSE CASE WHEN b.tl36 <> 0.00 AND tl08 = 'N$' OR tl08 = 'MX' THEN (NVL(b.tl36,0)* factor)/vTpCambioUdi
                                           ELSE CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN (NVL(b.tl21,0)* factor)/vTpCambioUdi 
                                                      ELSE 0 END END
                           END +
                           CASE WHEN b.tl30 <> 'CV' AND tl08 = 'US' THEN (((NVL(b.tl36,0) + NVL(b.tl24,0))* vTpCambioUs) * factor) /vTpCambioUdi
                                ELSE CASE WHEN b.tl36 <> 0.00 AND tl08 = 'US' THEN (NVL(b.tl36,0) * vTpCambioUs) * factor/vTpCambioUdi
                                          ELSE CASE WHEN tl08 = 'US' THEN (NVL(b.tl21,0) * vTpCambioUs) * factor/vTpCambioUdi 
                                                    ELSE 0 END END
                           END +
                           CASE WHEN b.tl30 <> 'CV' AND tl08 = 'UD' THEN (NVL(b.tl36,0) + NVL(b.tl24,0)) * factor
                                ELSE CASE WHEN b.tl36 <> 0.00 AND tl08 = 'UD' THEN NVL(b.tl36,0) * factor
                                           ELSE CASE WHEN tl08 = 'UD' THEN NVL(b.tl21,0) * factor 
                                                     ELSE 0 END END  
                           END),2)
        INTO vMontoUdis 
        FROM bdisolic:"informix".ss_circulo_status a, bdiburo:"informix".br_tl_bc b, bdisolic:"informix".ss_circulo_frecpag c 
        WHERE b.numcte  = cNumcliente
        AND a.status = b.tl30  -- se modifica a.status = b.tl07
        AND b.tl11 = c.tipo
        AND a.rango_rechazo = "3"
        AND tl02 <> 'SIC';

   IF vMontoUdis IS NULL OR vMontoUdis = '' THEN LET vMontoUdis = 0; END IF;

   IF vMontoUdis > vMaxMtoUdi THEN
       LET s_califica = "1";
		LET vMensaje = "Creditos con Antecedentes " || trim(vDescripcion_status) || ":" ||  "Mto Max Udi:" || vMaxMtoUdi ||
       				"Mto Udi Cte:" || vMontoUdis;

		LET cstatus     = "RT";
		LET vCausa      = "RBC";
		LET cComentario = "Rechazado Por Buro de Crédito";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

         CONTINUE FOREACH;
   END IF

   IF vCuantos > 0 AND s_califica = "2" THEN
       LET s_califica = "4";
   ELIF vCuantos > 0 AND s_califica = "0" THEN
       LET s_califica = "3";
   END IF

    SELECT round(NVL(sum(case when tl08 = 'N$' or tl08 = 'MX'  then tl12 * b.factor  else 0 end),0) +
           NVL(sum(case when tl08 = 'UD' then (tl12 * b.factor) * vTpCambioUdi else 0 end),0) +
           NVL(sum(case when tl08 = 'US' then (tl12 * b.factor) * vTpCambioUs else 0 end),0),2),
           count(numcte)
    INTO s_compromisos, vCuantos
    FROM bdiburo:"informix".br_tl_bc a, bdisolic:"informix".ss_circulo_frecpag b
    WHERE a.tl11 = b.tipo
    AND numcte = cNumcliente 
    AND tl02 <> 'SIC'; 

   IF s_compromisos IS NULL THEN
      LET s_compromisos = 0;
   END IF

   IF vCuantos > 0 AND s_califica = "X" THEN
       LET s_califica = "0";
   END IF

   IF s_califica = "0" THEN
		LET vMensaje ="BUEN COMPORTAMIENTO " || trim(vDescripcion_status);
   ELIF s_califica = "X" THEN
		LET vMensaje ="COMPORTAMIENTO NULO EN SIC";
   END IF
/*
    SELECT lincred_sugerida INTO dLineaSugerida 
    FROM bdicred:"informix".sd_bitacora_aumlincred 
    WHERE empresa = pEmpresa
    AND num_solicitud = cNumcred 
    AND status = "BC"
    AND fecha_insert = pFechaHoyAumlincred 
    AND origen = "C";
*/
--Determina si la solicitud se va al CAC para análisis o se autoriza
--temporalmente se autorizan todas las solicitudes hasta que se genere la pantalla de determinación de línea del CAC
   IF (dLineaSugerida > sLineaCreditoCAC) THEN --se compara en pesos y no en salarios mínimos
      LET cstatus     = "AC";      LET vCausa      = "";
      LET cComentario = "En análisis por el CAC";	
   ELSE
      LET cstatus     = "AT";
      LET vCausa      = "";
      LET cComentario = "Requiere Autorización del cliente para su aplicación";
   END IF;

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

	--se agrega validacion para ver si el cliente cuenta con incrementos automaticos, si es asi se manda llamar al procedimiento sp_registrarrespuestacte para simular la respuesta de autorizacion del cliente.
	IF cIncreAuto ='S' AND  cstatus= "AT" THEN
	
		LET cPregunta= "Autorizo expresamente a BanCoppel a incrementar mi linea de crédito a $" ||dLineaSugerida|| ", así mismo, acepto las nuevas condiciones y términos aplicables a partir de esta fecha.";
		EXECUTE PROCEDURE bdicred:"informix".sp_registrarrespuestacte(pEmpresa,cNumcred,'1',cPregunta,cSucursal,'sistema') INTO scod_ret, vMensaje;
		
		IF scod_ret <> "00000" THEN
			LET scod_ret = "00001";
			LET vMensaje = "Error al realizar incremento automático de línea para el crédito  " || cNumcred;
			
			RETURN scod_ret, vMensaje;
		END IF;	
	END IF;
	
	LET cstatus     = "";
	LET vCausa      = "";
	LET cComentario = "";
    LET vMensaje    = "";
    LET dLineaSugerida = 0;

END FOREACH;

  IF sCommit = -1 THEN
     COMMIT WORK;
  END IF;
  LET sCommit = 0;

  LET vMensaje     = "Se realizó la consulta correctamente";

END
    LET cCodRet = "000000";
    RETURN cCodRet, vMensaje;
END PROCEDURE;