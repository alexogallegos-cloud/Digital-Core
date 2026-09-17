CREATE PROCEDURE "informix".sp_bloqueocuenta (
																pEmpresa 	CHAR(3), 
																pNumCuenta 	CHAR(20), 
																cCveBloqueo	INTEGER,
																pCveCausa 	CHAR(2), 
																pEjecutivo 	CHAR(8),
																pTipo		INTEGER,
																pArea       VARCHAR(150,1),  
																pJustificacion VARCHAR(150,1)
															  )
RETURNING
	CHAR(6) AS CODIGO,
	CHAR(80) AS MENSAJECOD;
    
--Definicion de variables
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(80);
DEFINE vFecha        DATE;
DEFINE vCveExistente INTEGER;
DEFINE vCodSP        CHAR(6);
DEFINE vStatusCred   CHAR(2);
DEFINE pClaveBloqueo INTEGER;
DEFINE iCveAnte      INTEGER;
DEFINE cCausa        CHAR(2);
DEFINE dcSdoCapital  DECIMAL(18,2);

--Set debug file to '/home/sysifx/has/sp_bloqueocuenta.out';
--trace on;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  LET cMensajeRet= cErrorInfo;
		  RETURN 
			   cCodRet,
			   cMensajeRet;  
	   END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
--Inicializar Variables--
LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = '';
LET cCodRet        = '000000';
LET cMensajeRet    = '';

LET vFecha         = date(1);
LET vCveExistente  = 0;
LET vCodSP         = '';
LET vStatusCred    = '';
LET pClaveBloqueo  = 0;
LET iCveAnte       = 0;
LET cCausa		   = '';
LET dcSdoCapital   = 0;
        

	IF pEmpresa IS NULL OR pNumCuenta IS NULL OR cCveBloqueo IS NULL OR pCveCausa IS NULL OR pEjecutivo IS NULL OR pTipo IS NULL THEN
		LET cCodRet = '000001';    --Faltan Valores
		LET cMensajeRet = 'Faltan valores para ejecutar el procedimiento.'; 
	ELSE
		IF NOT EXISTS( SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'La empresa no válida';
		ELSE
			IF NOT EXISTS(SELECT clave FROM bdicred:"informix".sd_bloqueoscuenta WHERE clave = cCveBloqueo) THEN
				LET cCodRet = '000003';
				LET cMensajeRet = 'La clave del bloqueo no es válida';
			ELSE
				IF NOT EXISTS(SELECT cod_causa FROM bdicred:"informix".sd_causa_bloqueo WHERE empresa = pEmpresa and cod_causa = pCveCausa) THEN
					LET cCodRet = '000004';
					LET cMensajeRet = 'La clave de la causa del bloqueo no es válida';
				ELSE
					IF NOT EXISTS(SELECT ejecutivo FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pEjecutivo) THEN
						LET cCodRet = '000005';
						LET cMensajeRet = 'La clave de la causa del bloqueo no es válida';
					ELSE
						IF pTipo NOT IN (1,2) THEN
							LET cCodRet = '000006';
							LET cMensajeRet = 'El tipo de bloqueo no es válido';
						ELSE
							EXECUTE PROCEDURE bdicred:"informix".sp_validacredito (pEmpresa, pNumCuenta) 
							INTO vCodSP;
							IF vCodSP::INTEGER <> 0 THEN
								LET cCodRet = '000007';    --No existe el credito en la base de datos
								LET cMensajeRet = 'La cuenta ' || pNumCuenta || ' no existe.'; 
							ELSE    
								SELECT NVL(id_unidad_prod, 0), status_Cred, cod_caract_2
								  INTO vCveExistente, vStatusCred, cCausa
								  FROM "informix".sd_maecred
								 WHERE empresa = pEmpresa 
								   AND num_credito = pNumCuenta;
								
								IF (vCveExistente = 0 AND cCausa IS NOT NULL) OR (vCveExistente > 0 AND cCausa IS NULL) THEN
									LET cCodRet = '000008';
									LET cMensajeRet = 'Crédito bloqueado manualmente favor de verificar'; 
								ELSE
									IF vCveExistente > 0 AND cCausa IS NOT NULL THEN
									   LET cCodRet = '000009';
									   LET cMensajeRet = 'El crédito ya se encuentra bloqueado';  
									ELSE                    
										IF vCveExistente >= 0 THEN
											IF vStatusCred='FC' THEN
												LET cCodRet = '000012';
												LET cMensajeRet = 'La cuenta ' || pNumCuenta || ' está cancelada.';
											ELIF vStatusCred ='CV' THEN
												LET cCodRet = '000010';
												LET cMensajeRet = 'La cuenta ' || pNumCuenta || ' está en cartera vendida.'; 
											ELSE
												SELECT fecha_hoy
												INTO vFecha
												FROM "informix".sd_fechas
												WHERE empresa = pEmpresa;

												SELECT sdo_cap_insoluto
  												  INTO dcSdoCapital
                                                  FROM "informix".sd_maesdos
                                                 WHERE num_credito = pNumCuenta 
                                                   AND empresa = pEmpresa;
												
												INSERT INTO "informix".sd_bitacorabloqueocta 
												(cuenta, cve_bloqueo,cve_causa,cve_bloqueAnterior,cve_causa_anterior, ejecutivo, fecha, tipo_bloqueo, tipo_movimiento, area_solicita, justificacion, saldo_capital)
												VALUES (pNumCuenta, cCveBloqueo,pCveCausa, NULL, NULL, pEjecutivo, vFecha, pTipo, 'B', NVL(pArea,''), NVL(pJustificacion,''), NVL(dcSdoCapital,0));

												UPDATE "informix".sd_maecred
												SET id_unidad_prod = cCveBloqueo, Cod_caract_2 = pCveCausa
												WHERE empresa = pEmpresa
												AND num_credito = pNumCuenta;
												   
												LET cMensajeRet = 'La cuenta ' ||  Trim(pNumCuenta) || ' se ha bloqueado.';
												
												IF vCveExistente > 0 THEN
												   LET cCodRet = '000011';  --El bloque se actualizo
												   LET cMensajeRet = 'Se actualizó el bloqueo de la cuenta ' || pNumCuenta; 
												END IF;
											END IF;
										END IF;
									END IF;
								END IF;
							END IF;
						END IF
					END IF
				END IF
			END IF
		END IF
	END IF;
        
	RETURN cCodRet,cMensajeRet;  
        
END;
    
END PROCEDURE

DOCUMENT
'Autor: Abraham Ayala Aguilar',
'Descripcion: Bloquea una cuenta e inserta un registro en la tabla sd_bitacorabloqueocta. Bloqueo Cuentas',
'Fecha: 08/01/2009',
'Cambio: se quito la restriccion de cuando ya estaba bloqueada la cuenta y se actualiza  cCveBloqueo   pClaveBloqueo',
'Modifico: Roque Enrique Solis ',
'Cambio: Se cambio el parametro clave del parametro por la descripcion del parametro',
		'Se agrego el parametro del bloqueo anterior para que se inserte el la bitacora',
		'Se agrego el campo para conocer la causa del bloque',
'Modifico: Roque Enrique Solis',
'Cambio: Se agrega de tipo bloqueo (manual o masivo), además se cambias las clave del bloqueo por su descripcion',
		'tipo_bloqueo  1 = Manual, 2 = Masivo',
'Modifico: Mohamed Carreón, Abigail Vasavilbazo Cañedo',
'Version: 20120104.1048';

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

CREATE FUNCTION "informix".sp817_random() RETURNING FLOAT
   DEFINE GLOBAL seed DECIMAL(10) DEFAULT NULL;
   DEFINE d DECIMAL(20,0);
   DEFINE x1 FLOAT;
   DEFINE x2 FLOAT;
   IF seed is NULL THEN
      EXECUTE PROCEDURE sp817_SetRandomSeed();
   END IF;   
   LET d = (seed * 1103515245) + 12345;
   LET seed = d - 4294967296 * TRUNC(d / 4294967296);
   LET x1 = MOD(TRUNC(seed / 65536), 32768);
   LET d = (seed * 1103515245) + 12345;
   LET seed = d - 4294967296 * TRUNC(d / 4294967296);
   LET x2 = MOD(TRUNC(seed / 65536), 32768);
   IF x1 > x2 then
      RETURN x2/x1;
   ELSE
      RETURN x1/x2;
   END IF;
END FUNCTION;

CREATE PROCEDURE "informix".sp_consultarcausastatus(p_Status CHAR(2))
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
	LET v_cod_ret 			= '00000';
	LET iSqlErr				= 0;
	LET iSamErr				= 0;
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
		
		RETURN v_cod_ret, "", "", "", "";
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	-- SET DEBUG FILE TO "/home/sysifx/vlv/sp_consultarcausastatus.out";
	-- TRACE ON;
	
	IF p_Status = "" THEN
	
		FOREACH
			SELECT status_solicitud, descripcion, "", ""
			INTO sStatus, sDescStatus, sCausa, sDescCausa 
			FROM bdisolic:"informix".ss_status_sol 
			WHERE activa_reporte = "1"
			AND status_solicitud NOT IN('PC','AN')
			ORDER BY status_solicitud

			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
		
	ELIF p_Status = "IN" THEN
	
		FOREACH
			SELECT status_solicitud, descripcion, "", ""
			INTO sStatus, sDescStatus, sCausa, sDescCausa 
			FROM bdisolic:"informix".ss_status_sol 
			WHERE activa_reporte = "1"
			  AND status_solicitud IN('AT','RT','CN','EE','CE','OA','BC','CC','OS')
			ORDER BY status_solicitud

			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
		
	ELIF p_Status = "FN" THEN
	
		FOREACH
			SELECT status_solicitud, descripcion, "", ""
			INTO sStatus, sDescStatus, sCausa, sDescCausa 
			FROM bdisolic:"informix".ss_status_sol 
			WHERE activa_reporte = "1"
			  AND status_solicitud IN('AT','RT','CM','EE')
			ORDER BY status_solicitud

			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
		
	ELIF p_Status = "#" THEN

		FOREACH
			SELECT t2.status_solicitud, t2.causa_solicitud, t2.causa_solicitud ||' ' || t2.descripcion
			INTO sStatus, sCausa, sDescCausa
			FROM bdisolic:"informix".ss_causas_sol t2
			WHERE activa_reporte = "1"
			
			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
		
	ELIF p_Status = "RT" THEN -- REPORTE POR TIPO DE RECHAZO.
	
		FOREACH 
			SELECT status_solicitud, "", causa_solicitud, descripcion
			INTO sStatus, sDescStatus, sCausa, sDescCausa
			FROM bdisolic:"informix".ss_causas_sol
			WHERE status_solicitud = TRIM(p_Status)
			--AND causa_solicitud NOT IN('RSC','RMC')
			AND activa_reporte = "1"
			AND tipo_auto = "2"
			
			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
		
	ELSE -- REPORTE POR ESTATUS SOLICITADO.
		FOREACH 
			SELECT status_solicitud, "", causa_solicitud, descripcion
			INTO sStatus, sDescStatus, sCausa, sDescCausa
			FROM bdisolic:"informix".ss_causas_sol
			WHERE status_solicitud = TRIM(p_Status)
			AND activa_reporte = "1"
			AND tipo_auto = "2"
			
			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
	END IF
	
	IF v_cod_ret <> "00000" THEN
		RETURN v_cod_ret, "", "", "", "";
	END IF
END;

END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para consultar los estatus y causas asociadas',
'Fecha: 07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan',
'Descripcion: Se le agrego que al momento de generar el reporte por TIPO DE RECHAZO no muestre las causas RMC y RSC ,',
'			  tambien que al momento de consultar por estatus muestra los diferente estatus separados. INICIAL Y FINAL',
'Fecha: 03/Diciembre/2012',
'BD: bdicred',
'Modifico: Valentin Lopez';

CREATE PROCEDURE "informix".provisionlineacred(pEmpresa      CHAR(3))
    RETURNING CHAR(5);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE CodRet     CHAR(5);
   DEFINE sql_err    SMALLINT;
   DEFINE isam_err   SMALLINT;
   DEFINE error_info CHAR(40);
   DEFINE vMensaje   VARCHAR(200,1);

   DEFINE FechaHoy   DATE;
   DEFINE FechaAnt   DATE;

   DEFINE vStProc    CHAR(1);
   DEFINE vErrores   INTEGER;
   DEFINE rLog       SMALLINT;
   DEFINE cSql       CHAR(200);
   DEFINE vconrador  integer;
   DEFINE pprocesos     SMALLINT;
   DEFINE pcuenta       INTEGER;
   DEFINE pcuenta_aux3  INTEGER;
   DEFINE pcontador     SMALLINT;
   DEFINE cred_ini      CHAR(20);
   DEFINE cred_fin      CHAR(20);
   DEFINE prango        CHAR(50);
   DEFINE pparametro    CHAR(3);
   DEFINE pparametro2	CHAR(3);


   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      LET vMensaje = isam_err;
      CALL log_cierre (pEmpresa, '', CodRet, FechaHoy,
                       TRIM(error_info))
      RETURNING rLog;

      IF rLog > 0 THEN
          UPDATE sd_contproc
             SET status_proc = 'C',
                 hora_fin    = CURRENT,
                 cod_ret     = CodRet,
                 mensaje     = vMensaje
           WHERE empresa     = pEmpresa
            AND proceso     = 'CierreCred'
            AND fecha       = FechaHoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = 'C',
                 hora_fin    = CURRENT,
                 codret      = CodRet
           WHERE empresa = pEmpresa
            AND proceso  = 'CierreCred'
            AND fecha    = FechaHoy;

          RETURN CodRet;
      END IF

      RETURN CodRet;

   END EXCEPTION WITH RESUME;


  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

--   SET DEBUG FILE TO "provisionlinea.out";
--   TRACE ON;
--temporal solo para pruebas   TRACE OFF;

   SET ISOLATION TO DIRTY READ;

   LET CodRet     = '000';
   LET sql_err    = 0;
   LET isam_err   = 0;
   LET error_info = '';
   LET FechaHoy   = null;
   LET FechaAnt   = null;
   LET vMensaje   = "";
   LET vStProc    = "";
   LET vErrores   = 0;
   LET rLog       = 0;
   LET vconrador  = 1;
   LET pprocesos    = 0;
   LET pcuenta      = 0;
   LET pcuenta_aux3 = 0;
   LET pcontador    = 0;
   LET cred_ini     = ''; 
   LET cred_fin     = '';
   LET prango       = '';
   LET pparametro   = '';
   LET pparametro2	= '';

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

--lee fecha de proceso
      SELECT fecha_hoy, fecha_ant
        INTO FechaHoy, FechaAnt
        FROM sd_fechas
       WHERE empresa = pEmpresa;
	   

--      let FechaHoy = today;
--temporal solo para pruebas
--      let FechaHoy = today-1;--mdy('08','21','2011');
--temporal solo para pruebas

      IF FechaHoy IS NULL THEN
         LET CodRet = "110";
         RETURN CodRet;
      END IF;


-- INI    REALIZA SEGMENTACION DE CREDITOS
           SELECT nvl(valor::integer,0)
             INTO pprocesos
             FROM bdicred:sd_param
            WHERE cod_param = '950';

            SELECT ROUND(COUNT(*) / pprocesos,0)
              INTO pcuenta
              FROM bdicred:sd_maecredanexo 
             WHERE empresa = pEmpresa 
               AND fecha_proceso = FechaHoy;
				
				
               LET pcuenta_aux3 = pcuenta;

              FOR pcontador = 1 TO  pprocesos
                   FOREACH
                       SELECT SKIP pcuenta_aux3 FIRST 1 nvl(num_credito,'')
                         INTO cred_fin
                         FROM bdicred:sd_maecredanexo 
                        WHERE empresa = pEmpresa
                          AND fecha_proceso = FechaHoy
                          ORDER BY num_credito
                   END FOREACH
       
                    IF pcontador = 1 THEN
                        LET prango = '000000000000'||'-'|| trim(nvl(cred_fin,''));
                        LET cred_ini = cred_fin;
                        LET pparametro = '951';
						LET pparametro2 = '981';
                    ELSE
                        IF pcontador = pprocesos THEN
                            LET prango = trim(nvl(cred_ini,''))||'-'|| '999999999999';
                        ELSE    
                            LET prango = trim(nvl(cred_ini,''))||'-'|| trim(nvl(cred_fin,''));
                            LET cred_ini = cred_fin;
                        END IF;

                        LET pparametro = (pparametro::integer + 1)::varchar(3); 
						LET pparametro2 = (pparametro2::integer + 1)::varchar(3);  
                    END IF;

                        LET pcuenta_aux3 = pcuenta_aux3 + pcuenta;
                   
                       UPDATE bdicred:sd_param 
                          SET valor = prango
                        WHERE empresa = pEmpresa
                          AND cod_param = pparametro;
						
					--	Inserta parametros TRIAD					
						UPDATE bdicred:sd_param 
                          SET valor = prango
                        WHERE empresa = pEmpresa
                          AND cod_param = pparametro2;	  
						  
               END FOR;              
-- FIN    REALIZA SEGMENTACION DE CREDITOS

-- Pregunta por Control de procesos
    SELECT status_proc INTO vStProc
      FROM sd_contproc
     WHERE empresa = pEmpresa
       AND proceso = "CierreCred"
       AND fecha = FechaHoy;

        IF vStProc IS NULL THEN
            INSERT INTO sd_contproc (empresa, proceso, fecha, status_proc, ejecutivo,hora_inicio, hora_fin, cod_ret, mensaje)
            VALUES (pEmpresa, 'CierreCred', FechaHoy, 'I', USER,CURRENT, NULL, NULL, NULL);

            INSERT INTO bdinteg:sx_contproc (empresa, proceso, fecha, sistema, status_proc,ejecutivo, hora_ini, hora_fin, codret)
            VALUES (pEmpresa, 'CierreCred', FechaHoy, '06', 'I',USER, CURRENT, NULL, '000');

            SELECT COUNT(*)
              INTO vErrores
              FROM sd_valcierre;

            IF vErrores > 0 THEN
               INSERT INTO sd_valcierrehist
               SELECT FechaAnt, * 
                 FROM sd_valcierre;
            END IF

            TRUNCATE sd_valcierre;
        ELIF vStProc = "F" THEN
            RETURN CodRet;
        END IF;

        update sd_fechas set ind_cierre = '0' where empresa = pEmpresa;

/*-- Se elimina esta parte para la generaciÃÂ³n de hilos por CTL-M
        LET cSql = '';
--executa procesos en segundo plano
        TRACE ON;

        -- Actualiza estatus del cierre a iniciado JOM
        update sd_fechas set ind_cierre = '0' where empresa = pEmpresa;

        LET cSQL = '/resplogifx/archivoscartera/cierre/eje_provisionlineacred_parte.sh';
        SYSTEM cSql;

        TRACE OFF;

   WHILE vconrador > 0

        TRACE ON;
        SELECT count(*)
          INTO vconrador
          FROM sd_maecred a, sd_maecredanexo b
         WHERE a.empresa = pEmpresa
           AND a.status_cred NOT IN ("FF", "CC", "FC","CV")
           AND NVL(id_unidad_prod,0) <> 1
           AND b.num_credito = a.num_credito
           AND b.empresa = a.empresa
           AND b.fecha_proceso = FechaHoy;
         
        TRACE OFF;
        IF vconrador > 0 THEN
            LET cSql = '';
    --se espera 10 minutos
            LET cSQL = 'sleep 300';
            SYSTEM cSql;
        END IF;

   END WHILE;
   
   --update statistics medium for table sd_movdia;

    IF CodRet <> "000" THEN
            UPDATE sd_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   cod_ret     = CodRet,
                   mensaje     = vMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'CierreCred'
               AND fecha       = FechaHoy;

            UPDATE bdinteg:sx_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   codret      = CodRet
             WHERE empresa = pEmpresa
               AND proceso  = 'CierreCred'
               AND fecha    = FechaHoy;

    ELSE
          LET vMensaje = "Proceso Concluido";
            UPDATE sd_contproc
               SET status_proc = 'F',
                   hora_fin    = CURRENT,
                   cod_ret     = CodRet,
                   mensaje     = vMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'CierreCred'
               AND fecha       = FechaHoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = 'F',
                 hora_fin    = CURRENT,
                 codret      = CodRet
           WHERE empresa = pEmpresa
            AND proceso  = 'CierreCred'
            AND fecha    = FechaHoy;


        -- Actualiza estatus del cierre a finalizado JOM
          update sd_fechas set ind_cierre = '1' where empresa = pEmpresa;

          LET cSql = '';
    END IF;
*/-- Se elimina esta parte para la generaciÃÂ³n de hilos por CTL-M

   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Procedimiento para la provision y traspaso a cartera ',
'vencida para creditos tipo tarjeta',
'AUTOR : Antonio Ruiz',
'FECHA : 30/Diciembre/2006',
'VERSION: 1.00.006',
'BD    : BDICRED'
;

CREATE PROCEDURE  "informix".sp_obtenproductocredito()

RETURNING CHAR(6) AS Codigo_de_Retorno,
		  CHAR(6) AS Numero_de_Producto,
		  CHAR(50) AS Nombre_Producto,
		  CHAR(1) AS Tp_Solicitud

--definicion de variables
	DEFINE sql_err 			INTEGER;
	DEFINE cCodret 			CHAR(6);
	DEFINE cNum_Producto	CHAR(6);
	DEFINE cNombre_Producto	CHAR(50);
	DEFINE cTipo 			CHAR(1);
--Asignacion de variables
    LET sql_err 			= 0;
	LET cCodret				= "000000";
	LET cNum_Producto		= "";
	LET cNombre_Producto	= "";
	LET cTipo 				= "";
	BEGIN
			--Manejo de excepciones (errores)
			ON EXCEPTION SET sql_err
				IF sql_err <> 0 THEN
					let cCodret = sql_err;
					RETURN cCodret, "","","";
				END IF;
			END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

			--SET DEBUG FILE TO "/tmp/sp_ObtenProductoCredito.out";
			--TRACE ON;
			--Este Procedimiento se utiliza en CARATARJ.exe para Obtener los productos de crédito que se podrá imprimir la reimpresion
			FOREACH
				SELECT a.num_producto,a.nombre_prod,b.tp_solicitud  
				INTO cNum_Producto, cNombre_Producto, cTipo
				FROM bdicred:sd_definicion a 
				LEFT JOIN  bdisolic:ss_solic_producto b ON(a.num_producto = b.num_producto) 
				WHERE a.maneja_pago_sost = 'N'
				RETURN cCodret,cNum_Producto,cNombre_Producto,cTipo WITH RESUME;
			END FOREACH;
	END;

END PROCEDURE
DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Es procedimiento obtiene los productos de credito manejados por el banco',
'FECHA      : 12-10-2009',
'VERSION    : 20091012.1745',
'BD         : BDICRED',
'AUTOR      : Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Modificación se agrego el retorno del tipo de producto para la reeimpresion de caratula',
'FECHA      : 08-12-2009',
'VERSION    : 20091208.1617',
'BD         : BDICRED';

CREATE PROCEDURE "informix".libera_retenido_forzado()
RETURNING CHAR(5);       -- Codigo de Retorno

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

   DEFINE CodRet        CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE vFOlio	CHAR(16);
   DEFINE vFecha	DATE;
   DEFINE vDiasRet	SMALLINT;
   DEFINE vMonto	DECIMAL(14,2);
   DEFINE vMontoLib     DECIMAL(14,2);
   DEFINE vDIas		SMALLINT;
   DEFINE vNumCredito char(20);
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   ON EXCEPTION SET sql_err
      LET CodRet = sql_err;
      ROLLBACK WORK;
      RETURN CodRet;
   END EXCEPTION

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET CodRet    = '000';
   LET vFolio    = "??????";
   LET vFecha    = " ";
   LET vDiasRet  = 0;
   LET vMonto    = 0;
   LET vMontoLib = 0;
   LET vDias     = 0;
   LEt vNumCredito = '';

 -- **************************************************************************
 -- *                      PROGRAMA PRINCIPAL                                *
 -- **************************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--SET DEBUG FILE TO "/informix/miguel/libera_retenido_forzado.out";
	--TRACE ON;
	
	FOREACH WITH HOLD
        SELECT a.folio_suc, a.fecha_hora, a.num_credito, a.monto
          into vFolio, vFecha, vNumCredito, vMontoLib
		  FROM bdicred:sd_retenidolibera a,
               bdicred:sd_maeretenido b
		 WHERE empresa = '001'
		   AND estatus in ("P","S")
           AND a.num_credito = b.num_credito
           AND a.folio_suc = b.folio_suc
       
		SELECT sdo_retenido INTO vMonto FROM bdicred:sd_maesdos WHERE num_credito = vNumCredito;
		
		IF vMontoLib<= vMonto THEN
           begin work;

                UPDATE bdicred:sd_maeretenido
                   SET estatus = "S"
                 WHERE empresa = '001'
                   AND num_credito = vNumCredito
                   AND folio_suc = vFolio
                   AND fecha = vFecha;
				
                UPDATE sd_maesdos 
					SET sdo_retenido  = sdo_retenido - vMontoLib 
				WHERE num_credito = vNumCredito;

            commit work;
		END IF;

	END FOREACH


	RETURN CodRet;

END PROCEDURE;