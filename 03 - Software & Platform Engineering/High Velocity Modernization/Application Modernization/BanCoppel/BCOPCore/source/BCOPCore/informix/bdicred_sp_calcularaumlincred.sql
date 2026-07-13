CREATE PROCEDURE "informix".sp_calcularaumlincred(pEmpresa CHAR(3))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;

DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE dLineaSugerida   DECIMAL(18,2);
DEFINE cNumCte          CHAR(20);
DEFINE cNum_cred        CHAR(20);
DEFINE dAum1            DECIMAL(18,2);
DEFINE dAum2            DECIMAL(18,2);
DEFINE paramsm			CHAR(3);
DEFINE paramcantsm		CHAR(3);
DEFINE paramcantsmburo	CHAR(3);
DEFINE paramporc1		CHAR(3);
DEFINE paramporc2		CHAR(3);
DEFINE valorsm			DECIMAL(18,2);
DEFINE cantidadsm		DECIMAL(18,2);
DEFINE param6sm			DECIMAL(18,2);
DEFINE valorsmzonac		DECIMAL(18,2);
DEFINE valorburo 		DECIMAL(18,2);
DEFINE vstatus          CHAR(2);
DEFINE smblinsug		DECIMAL(18,2);
DEFINE p_FechaHoy		DATE;
DEFINE vCont            INTEGER;
DEFINE cUser            CHAR(10);
DEFINE valorcac 		DECIMAL(18,2); 
DEFINE cac 		        DECIMAL(18,2);
DEFINE paramcantscac	CHAR(3);
DEFINE cOrigen          CHAR(1);
DEFINE numprod          CHAR(4);
DEFINE vCausa           CHAR(3);
DEFINE cSuc             CHAR(4);
DEFINE dMontoOtor       DECIMAL(18,2);
DEFINE cRiesgo      	CHAR(02);
DEFINE dMontoReserva    DECIMAL(18,2);
DEFINE sCommit          SMALLINT;
DEFINE contador_commit  INTEGER;
DEFINE sLineaCredito    SMALLINT;
DEFINE sLineaCreditoBC  SMALLINT;
DEFINE sLineaCreditoCAC INTEGER;
DEFINE cIncreAuto       CHAR(1);
DEFINE cPregunta        CHAR(200);
DEFINE dFechaCob        DATE;
DEFINE pFechaHoyAumlincred DATE;
DEFINE sCteDirtyBehav   SMALLINT;
DEFINE dMontoIncrem     DECIMAL(18,2);
DEFINE vstatus_prev     CHAR(2);
DEFINE sNumIncremOtor   SMALLINT;
DEFINE sNumIncrOtor1    SMALLINT;
DEFINE sNumIncrOtor2    SMALLINT;
DEFINE sNumDecartIncr   SMALLINT;
DEFINE sMinScoreCteDir   SMALLINT;

LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la consulta correctamente";
LET vproceso            = '0508';
LET cCod_RetIB          = '';
LET cComentario         = "";
LET dLineaSugerida  	= 0;
LET cNumCte             = "";
LET cNum_cred           = "";
LET dAum1  		 		= 0;
LET dAum2 				= 0;
--LET paramsm				     = "013";
--LET paramcantsm			     = "012";
--LET paramcantsmburo		     = "014";
--LET paramporc1			     = "017";
--LET paramporc2			     = "016";
--LET paramcantscac            = "015";
LET valorsm				= 0;
LET cantidadsm			= 0;
LET smblinsug			= 0;
LET param6sm			= 0;
LET p_FechaHoy			= DATE(1);
LET vCont               = 0;
LET cUser               = USER;
LET valorcac            = 0;
LET cac			        = 0;
LET cOrigen			    = "";
LET cUser			    = "";
LET numprod             = "";
LET vCausa              = "";
LET cSuc				= "";
LET dMontoOtor          =0;
LET cRiesgo             = "";
LET dMontoReserva       =0;
LET sCommit             = 0;
LET contador_commit     = 0;
LET sLineaCredito       = 0;
LET sLineaCreditoBC     = 0;
LET sLineaCreditoCAC    = 0;
LET cIncreAuto          = "";
LET cPregunta           = "";
LET pFechaHoyAumlincred = DATE(1);
LET sCteDirtyBehav      = 0;
LET dMontoIncrem        = 0;
LET vstatus_prev        = '';
LET sNumIncremOtor      = 0;
LET sNumIncrOtor1       = 0;
LET sNumIncrOtor2       = 0;
LET sNumDecartIncr      = 0;
LET sMinScoreCteDir     = 0;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;
            --      LET cMensajeRet= cErrorInfo;
            IF (sCommit = -1) THEN
                rollback work;
            END IF;
            CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCod_RetIB;
            RETURN cCodRet, cMensajeRet;
        END IF;
    END EXCEPTION;

--SET DEBUG FILE TO 'sp_calcularaumlincred.out';
--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    -- obtener la fecha
    /*
    SELECT fecha_hoy 
      INTO p_FechaHoy
      FROM "informix".sd_fechas
     WHERE empresa = pEmpresa;	

    IF NVL(pEmpresa,"") = "" THEN
        LET cCodRet      = "000011";
        LET cMensajeRet  = "parametro requerido esta vacio";
        RETURN cCodRet, cMensajeRet;
    END IF;
    */

    SELECT fecha_hoy 
        INTO pFechaHoyAumlincred
        FROM bdicred:"informix".sd_fechas_aumlincred
        WHERE empresa = pEmpresa;

    -- obtener el valor del salario minimo de la zona C
    SELECT valor 
      INTO valorsm
      FROM "informix".sd_param 
     WHERE empresa   = pEmpresa 
       AND cod_param = '013';

    -- validacion de los parametros.
    IF NVL(valorsm,"") = "" THEN
        LET cCodRet      = "000001";
        LET cMensajeRet  = "Error al obtener el parametro del valor del salario minimo";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- obtener el valor de la cantidad de salarios minimos zona C =1.27
    SELECT valor 
      INTO cantidadsm
      FROM "informix".sd_param 
     WHERE empresa   = pEmpresa 
       AND cod_param = '012';

    -- validacion de los parametros.
    IF NVL(cantidadsm,"") = "" THEN
        LET cCodRet     = "000002";
        LET cMensajeRet = "Error al obtener el parametro de la cantidad de salarios minimos";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- posteriormente multiplicarlo para obtener la cantidad a numeros reales
    LET valorsmzonac = (valorsm * 30.42) * cantidadsm;

    -- obtencion de la cantidad de salarios minimos para pasar a buro "6sm"
    SELECT valor 
      INTO param6sm
      FROM "informix".sd_param 
     WHERE empresa   = pEmpresa 
       AND cod_param = '014';

    -- validacion de los parametros.
    IF NVL(param6sm,"") = "" THEN
        LET cCodRet     = "000004";
        LET cMensajeRet = "Error al obtener el parametro de la cantidad de salarios minimos para ir a buro de credito";
        RETURN cCodRet, cMensajeRet;
    END IF;

    LET valorburo = (valorsm * 30.42) * param6sm;

    -- obtencion del porcentaje para calcuar la linea de clientes con su linea actual menor a 1.27 sm 
    SELECT valor 
      INTO dAum2
      FROM "informix".sd_param 
     WHERE empresa   = pEmpresa 
       AND cod_param = '017';	

    -- validacion de los parametros.
    IF NVL(dAum2,"") = "" THEN
        LET cCodRet     = "000005";
        LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos menores a 1.27";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- obtencion del porcentaje para calcular la linea de clientes con su linea actual mayor o igual a 1.27 sm 
    SELECT valor 
      INTO dAum1
      FROM "informix".sd_param 
     WHERE empresa = pEmpresa 
       AND cod_param = '016';

    -- validacion de los parametros.
    IF NVL(dAum1,"") = "" THEN
        LET cCodRet     = "000006";
        LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos mayores a 1.27";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- obtención para el parámetro para ser consultado por el CAC
    SELECT valor 
      INTO cac
      FROM "informix".sd_param 
     WHERE empresa = pEmpresa 
       AND cod_param = '015';

    --validacion de los parametros.
    IF NVL(cac,"") = "" THEN
        LET cCodRet     = "000007";
        LET cMensajeRet = "Error al obtener el parametro de la cantidad de salarios minimos para ir a CAC";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- Compara créd con lín créd MN para increm línea
    SELECT valor 
      INTO sLineaCredito
      FROM "informix".sd_param 
     WHERE cod_param = '023'
       AND empresa = pEmpresa ;

    IF NVL(sLineaCredito,"") = "" THEN
        LET cCodRet     = "000008";
        LET cMensajeRet = "Error al obtener la línea de crédito a comparar para incrementos de línea";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- Compara línea crédito para enviar a BC 
    SELECT valor 
      INTO sLineaCreditoBC
      FROM "informix".sd_param 
     WHERE cod_param = '027'
       AND empresa = pEmpresa ;

    IF NVL(sLineaCreditoBC,"") = "" THEN
        LET cCodRet     = "000009";
        LET cMensajeRet = "Error al obtener la línea crédito para enviar a BC para incrementos de línea";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- Compara línea crédito para enviar aL CAC 
    SELECT valor 
      INTO sLineaCreditoCAC
      FROM "informix".sd_param 
     WHERE cod_param = '028'
       AND empresa = pEmpresa ;

    IF NVL(sLineaCreditoCAC,"") = "" THEN
        LET cCodRet     = "000010";
        LET cMensajeRet = "Error al obtener la línea crédito para enviar al CAC para incrementos de línea";
        RETURN cCodRet, cMensajeRet;
    END IF;

    LET valorcac = (valorsm * 30.42) * cac;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, 'Inicia foreach actualizacion status', '02') Returning cCod_RetIB;

    --se modifica la consulta principal para obtener el valor  que indica si el cliente cuenta con incremento automatico activo.
    FOREACH WITH HOLD
        SELECT a.empresa, a.num_solicitud, a.numcte, a.num_producto, a.sucursal, a.lincred_actual, a.lincred_sugerida, 
               a.smb_lincred, a.grado_riesgo, a.monto_reserva, a.origen, a.user_insert,b.ajuste_de_cuota
               INTO pEmpresa, cNum_cred, cNumCte, numprod, cSuc, dMontoOtor, dLineaSugerida,
               smblinsug, cRiesgo, dMontoReserva, cOrigen, cUser,cIncreAuto
         FROM "informix".sd_bitacora_aumlincred a
         INNER JOIN bdisolic:"informix".ss_solicitudes b on b.empresa = a.empresa AND b.num_solicitud = a.num_solicitud 
         WHERE a.fecha_insert = pFechaHoyAumlincred
           AND a.origen       = "C"
           AND a.status       = "PC"
           AND a.empresa      = pEmpresa 

        LET cMensajeRet = cNum_cred || '  calculo_aumento_linea';

        IF (sCommit = 0) THEN
            BEGIN WORK;
            LET contador_commit = 0;
            LET sCommit = -1;
        END IF; 

        -- Identifica si el cliente es un Cliente marcado como Dirty en el proceso Behavior
        LET sCteDirtyBehav = 0;
        SELECT count(*) INTO sCteDirtyBehav FROM bdicred:"informix".sd_clientes_dirty_behavior 
            WHERE month(fecha_reporte) = month(pFechaHoyAumlincred) AND year(fecha_reporte) = year(pFechaHoyAumlincred)
            AND num_credito = cNum_cred;


        -- se modificara posteriormente para que sea parametrizable(dato SM para que no sea fijo desde una tabla )  
        --Si la línea de crédito actual es menor a 2100 MN (1.27 SM zona C aproximadamente), se autoriza el incremento por parte del banco y queda pendiente la autorización del cliente
        --	IF (dMontoOtor < 2100) THEN --se compara en pesos y no en salarios mínimos
        IF (dMontoOtor < sLineaCredito) THEN --se compara en pesos y no en salarios mínimos
            LET dLineaSugerida  = round(dMontoOtor + (dMontoOtor * dAum2),-2);
            LET vstatus     = "AT";
            LET cComentario = "Requiere autorización del cliente para su aplicación";
            LET dFechaCob = pFechaHoyAumlincred;
        ELSE
            LET dLineaSugerida = round(dMontoOtor + (dMontoOtor * dAum1),-2);
            --Si la línea sugerida es mayor a 10,000 (6 SM zona C aproximadamente) se va a consultar a Buró de Crédito
            -- IF (dLineaSugerida >= 10000) THEN --se compara en pesos y no en salarios mínimos
            IF (dLineaSugerida >= sLineaCreditoBC) THEN --se compara en pesos y no en salarios mínimos
                LET vstatus     = "BC";
                LET cComentario = "En consulta de Buró de Crédito";
                LET dFechaCob   = DATE(1);
            ELSE
                --Si la línea sugerida es mayor a 21,000 (12 SM zona C aproximadamente) se va a consultar al CAC
                -- IF (dLineaSugerida >= 21000) THEN --se compara en pesos y no en salarios mínimos
                IF (dLineaSugerida >= sLineaCreditoCAC) THEN --se compara en pesos y no en salarios mínimos
                    LET vstatus     = "AC";
                    LET cComentario = "En análisis por el CAC";
                    LET dFechaCob   = DATE(1);
                ELSE
                    LET vstatus     = "AT";
                    LET cComentario = "Requiere Autorización del cliente para su aplicación";
                    LET dFechaCob = pFechaHoyAumlincred;
                END IF;
            END IF;				
        END IF;

        LET smblinsug = dLineaSugerida / (30.42 * valorsm);

        UPDATE "informix".sd_bitacora_aumlincred
           SET lincred_sugerida = dLineaSugerida,
               smb_lincred      = smblinsug,
               status           = vstatus,
               fecha_status     = pFechaHoyAumlincred,
               hora_status      = current,
               dfecha_cobranza  = dFechaCob 
         WHERE fecha_insert    = pFechaHoyAumlincred
           AND numcte          = cNumCte
           AND num_solicitud   = cNum_cred
           AND empresa         = pEmpresa;

        INSERT INTO informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);

        --se agrega validacion para ver si el cliente cuenta con incrementos automaticos, si es asi se manda llamar al procedimiento sp_registrarrespuestacte para simular la respuesta de autorizacion del cliente.
        -- En incrementos automaticos no los realizará si el Cliente esta marcado como Dirty en el proceso Behavior (sd_clientes_dirty_behavior)
        IF cIncreAuto ='S' AND vstatus= "AT" AND sCteDirtyBehav = 0 THEN
            LET cPregunta= "Autorizo expresamente a BanCoppel a incrementar mi linea de crédito a $" ||dLineaSugerida|| ", así mismo, acepto las nuevas condiciones y términos aplicables a partir de esta fecha.";
            EXECUTE PROCEDURE "informix".sp_registrarrespuestacte(pEmpresa,cNum_cred,'1',cPregunta,cSuc,'sistema')
							INTO cCodRet, cMensajeRet;
			IF cCodRet <> "00000" THEN
                RETURN cCodRet, cMensajeRet;
			END IF;	
        END IF;
	
        LET contador_commit = contador_commit  + 1;

        IF (contador_commit >= 7000) THEN
            COMMIT WORK;
            UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_bitacora_aumlincred;
            LET contador_commit = 0;
            BEGIN WORK;
        END IF;

    END FOREACH;
    /*		
    LET vCont = DBINFO("sqlca.sqlerrd2");
    IF vCont = 0 THEN
        LET cCodRet     = "000008";
        LET cMensajeRet = "No se encontraron registros";
        RETURN cCodRet, cMensajeRet;
    END IF;
    */
    IF sCommit = -1 THEN
        COMMIT WORK;
    END IF;
    LET sCommit = 0;
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_bitacora_aumlincred;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, 'Termina e inicia discriminacion de creditos dirty', '02') Returning cCod_RetIB;

    -- Elimina (rechaza) el incremento de LCR a los clientes que esten marcados como Dirty en el proceso Behavior
    SELECT trim(valor)::SMALLINT INTO sMinScoreCteDir FROM bdicred:sd_param WHERE cod_param = 106; --Nivel de riesgo a procesar (score minimo para descartar)

    FOREACH WITH HOLD
        SELECT a.num_solicitud, a.numcte, a.lincred_actual, a.lincred_sugerida, a.user_insert, a.status
          INTO cNum_cred, cNumCte, dMontoOtor, dLineaSugerida, cUser, vstatus_prev
          FROM bdicred:"informix".sd_bitacora_aumlincred a JOIN bdicred:"informix".sd_clientes_clean_behavior ctes
                 ON (month(a.fecha_insert) = month(ctes.fecha_reporte) AND year(a.fecha_insert) = year(ctes.fecha_reporte) AND a.num_solicitud = ctes.num_credito)
         WHERE a.empresa      = pEmpresa 
           AND a.fecha_insert = pFechaHoyAumlincred
           AND a.origen       = 'C'
           AND a.status   IN ('AT','BC','AC','IN','AP')
           --AND ctes.score >= sMinScoreCteDir


        LET dMontoIncrem = dLineaSugerida - dMontoOtor;
        --LET vstatus = 'RT';
        --LET vCausa  = 'RDB';
        --LET cComentario = 'Se rechaza incremento por ser Cliente Dirty en proceso Behavior';

        -- Cancela el incremento
        /*UPDATE bdicred:"informix".sd_bitacora_aumlincred
            SET status          = vstatus,
                causa_status    = vCausa,
                hora_status     = current,
                dfecha_cobranza = DATE(1)
            WHERE empresa  = pEmpresa
                AND fecha_insert  = pFechaHoyAumlincred
                AND numcte        = cNumCte
                AND num_solicitud = cNum_cred;

        -- Registra el movimiento de la cancelacion.
        INSERT INTO bdicred:informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNum_cred, vstatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
*/
        -- Obtiene el numero de incrementos otorgados al credito previamente.
        LET sNumIncremOtor = 0;    LET sNumIncrOtor1 = 0;    LET sNumIncrOtor2 = 0;
        
        SELECT count(num_solicitud) INTO sNumIncrOtor1 FROM bdicred:"informix".sd_bitacora_aumlincred 
            WHERE num_solicitud = cNum_cred AND status = 'AP';
        SELECT count(num_solicitud) INTO sNumIncrOtor2 FROM bdicred:"informix".sd_bitacora_aumlincred_hist 
            WHERE num_solicitud = cNum_cred AND status = 'AP';

        LET sNumIncremOtor = sNumIncrOtor1 + sNumIncrOtor2;

        -- Obtiene el numero de veces que ha sido descartado el incremento para el credito.
        LET sNumDecartIncr      = 0;
        SELECT count(num_credito) INTO sNumDecartIncr  FROM bdicred:"informix".sd_clientes_clean_behavior
            WHERE num_credito = cNum_cred AND status_bit IS NOT NULL;
        LET sNumDecartIncr = sNumDecartIncr + 1; -- Suma 1, ya que toma como 1 el proceso que se esta ejecutando.

        -- Actualiza informacion de cliente Dirty-clean en la tabla que almacena estos clientes.
        UPDATE bdicred:"informix".sd_clientes_clean_behavior
            SET status_bit = vstatus_prev,
                monto_lcr_original = dMontoOtor,
                incremento_sugerido = dMontoIncrem,
                increm_otorgados_actual = sNumIncremOtor,
                num_descartes_increm = sNumDecartIncr,
                candidato_buro = ( case when vstatus_prev = 'BC' then 'SI' else 'NO' end )
            WHERE month(fecha_reporte) = month(pFechaHoyAumlincred) AND year(fecha_reporte) = year(pFechaHoyAumlincred)
              AND num_credito = cNum_cred;

    END FOREACH;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, 'Termina e inicia delete', '02') Returning cCod_RetIB;

    -- Elimina los creditos que no fueron considerados para el incremento de lcr (el proceso normal de incrementos los rechazo)
    --DELETE FROM bdicred:"informix".sd_clientes_dirty_behavior WHERE month(fecha_reporte) = month(pFechaHoyAumlincred) 
    --  AND year(fecha_reporte) = year(pFechaHoyAumlincred) AND status_bit IS NULL;

	-- SE ELIMINA PARA EL NUEVO PROCESO INCREMENTO DE LINEA  RQI 21 154 INICIO
	/*
    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, 'Inicia reporte ctes Dirty', '02') Returning cCod_RetIB;

    -- Obtiene el Reporte de Exclusion de Incrementos de Línea.
    EXECUTE PROCEDURE bdicred:"informix".sp_rep_excluidos_ctesclean_behavior( pEmpresa ) INTO cCodRet, cMensajeRet;
	*/
	-- SE ELIMINA PARA EL NUEVO PROCESO INCREMENTO DE LINEA  RQI 21 154 FIN	

    LET cMensajeRet = "Se realizó la consulta correctamente";

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para calcular la nueva linea de crédito para los clientes prospectos',
'para incremento de linea de crédito',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 09/JUNIO/2010',
'BD    : BDICRED',
'Se modifica para contemplar la nueva funcionalidad de incrementos automáticos para clientes que tengan activa esta opcion',
'MODIFICO : Jesús Manuel Aguilar Heredia',
'FECHA : 14/MARZO/2011',
'BD    : BDICRED',
'VERSION:20110314.1630';

CREATE PROCEDURE  "informix".sp_envia_promocion_producto(o_empresa CHAR(3), o_Num_producto CHAR(4))
RETURNING CHAR(5)       AS cod_ret,
          CHAR(4)       AS num_promo,
          CHAR(50)      AS nombre_promo,
          DATE	        AS fecha_inicio,
          DATE          AS fecha_fin,
          INTEGER	    AS plazo,
          DECIMAL(10,2)	AS tasa;
		  

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************		  
DEFINE scod_ret     	  	CHAR(5);
DEFINE vsqlerr      	  	INTEGER;
DEFINE s_num_promo	 	  	CHAR(4);
DEFINE s_nombre_promo  	  	CHAR(50);
DEFINE s_fechaini   	  	DATE;
DEFINE s_fechafin  	    	DATE;
DEFINE s_plazo				INTEGER;
DEFINE s_tasa     	  		DECIMAL(10,2);
DEFINE vfecha_hoy   	  	DATE;
DEFINE s_flagtarjeta   	  	INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret          	= "00000";
LET vsqlerr           	= 0;
LET s_num_promo       	= "";
LET s_nombre_promo     	= "";
LET s_fechaini        	= "";
LET s_fechafin      	= "";
LET s_plazo        		= 0;
LET s_tasa          	= 0.0;
LET vfecha_hoy        	= "";
LET s_flagtarjeta       = 0;

		  
		  
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, s_num_promo, s_nombre_promo, s_fechaini, s_fechafin, s_plazo, s_tasa;
   END IF;
END EXCEPTION;

 --SET DEBUG FILE TO "/informix/miguel/envia_promocion_producto.out";
 --TRACE ON;
 
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy
    INTO vfecha_hoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = o_empresa;
	
	SELECT count(*)
	INTO s_flagtarjeta
	FROM bdicred:"informix".sd_definicion
	WHERE num_producto = o_Num_producto
	AND edocta_param = 'tdc';
	
	IF s_flagtarjeta = 0 THEN
		LET scod_ret = '00001';
		LET s_nombre_promo = 'Este producto no es Tarjeta de Credito';
		RETURN scod_ret, s_num_promo, s_nombre_promo, s_fechaini, s_fechafin, s_plazo, s_tasa;
	END IF;
	 
	 
	FOREACH
		select a.num_promo, a.nombre_promo, a.fechaini_promo ,a.fechafin_promo, b.plazo,b.tasa
		INTO s_num_promo, s_nombre_promo, s_fechaini, s_fechafin, s_plazo, s_tasa
		from bdicred:sd_promocion  a
		inner join  bdicred:sd_tasa_plazo b on a.num_promo = b.num_promo 
		WHERE vfecha_hoy between a.fechaini_promo and a.fechafin_promo
		and a.activo = b.plazo_activo
		and a.num_producto = b.num_producto
		and a.activo = b.plazo_activo
		and a.empresa = b.empresa
		and a.empresa = o_empresa
		and a.simulacred_act = 1
		and a.activo =1
		AND a.num_producto = o_Num_producto
		
		RETURN scod_ret, s_num_promo, s_nombre_promo, s_fechaini, s_fechafin, s_plazo, s_tasa WITH RESUME;
	END FOREACH;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene las promociones vigentes y activas para apagos fijos por producto de TDC"',
'CREATE :  Miguel Angel MartÃ­nez GalvÃ¡n',
'FECHA : 20/09/2018';

CREATE FUNCTION "informix".sp817_getrandomseed() RETURNING DECIMAL(10)
   DEFINE GLOBAL seed DECIMAL(10) DEFAULT NULL;
   RETURN seed;
END FUNCTION;