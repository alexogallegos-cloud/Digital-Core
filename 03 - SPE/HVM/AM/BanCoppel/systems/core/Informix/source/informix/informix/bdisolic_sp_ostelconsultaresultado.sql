CREATE PROCEDURE "informix".sp_ostelconsultaresultado( pEmpresa char(3), pSolicitud char(20))
RETURNING CHAR(5),CHAR(1), Char(1), CHAR(1);
--20/01/2009
--Walber Castro
--Consulta el resultado final de OS Telefónica.
---Modificó : Jesús Manuel Aguilar Heredia
--Fecha: 03-11-2010
--Se modifico una consulta para agregarle una condicion sobre el campo generar_os ='V' en la tabla ss_osclientesupervisartel 
    DEFINE cVarDataErr    VARCHAR(64);
    DEFINE iSqlERr        INTEGER;
    DEFINE iSamErr        INTEGER;

    DEFINE vCteResTelCasa     CHAR(1); --Respuesta General del Telefono de Casa del Cte
    DEFINE vCteResTelCelular  CHAR(1);
    DEFINE vCteResTelTrabajo  CHAR(1); --Respuesta General del Telefono de Trabajo del Cte

    DEFINE vRefResTelCasa     CHAR(1); --Respuesta General del Telefono de Casa de la Referencia
    DEFINE vRefResTelCelular  CHAR(1); --Respuesta General del Telefono de Celular de la Referencia
    DEFINE vRefResTelTrabajo  CHAR(1); --Respuesta General del Telefono de Trabajo de la Referencia

    DEFINE vSecuencia            INTEGER;     --Variable que guarda la secuencia de referencia por cada iteración del For Each.
    DEFINE vDestino              CHAR(1); --Variable que guarda el destino por cada iteración del For Each.
    DEFINE vRespsuptel_llamada   CHAR(1); --Variable que guarda la respuesta de marcado por cada iteración del For Each.
    DEFINE vRespsuptel_gestion   CHAR(1); --Variable que guarda la respuesta de gestión por cada iteración del For Each.

    DEFINE vCodRet              CHAR(5);
    DEFINE vResultado           CHAR(1); --Variable que guarda el Resultado Final que va regresar el SP.
    DEFINE vResIndividual       CHAR(1); --Variable que guarda el Resultado Individual obtenido de la matriz por cada telefono.
    DEFINE vResRefencia         CHAR(1); --Variable que guarda el Resultado general para la Referencia sin importar si son n referencias.
--    DEFINE vGeneraSupervision   CHAR(1); --Variable que guarda la bandera de generación de supervisión de acuerdo a la matriz general.

    DEFINE C_CLIENTE    CHAR(1);
    DEFINE C_REFERENCIA CHAR(1);
    DEFINE vEntidad CHAR(1); --Variable que guarda que entidad esta siendo procesada en la iteración del For Each, esto es Cliente o Referencia.

    DEFINE vResRefObtenida  CHAR(1); --Para saber cuando ya se tiene un resultado valido para una referencia, esto es por ejemplo,
    DEFINE vGenerada char(1); -- para saber si se generó o se obtuba el resultado global de la OS Telefonica
    DEFINE vEnviada char(1); -- para saber si se envió la OS Telefonica al CAT.
    DEFINE vRespondioCAT char(1); -- PARA SABER SI YA RESPONDIO EL CAT.

    --SE VERIFICA QUE TIPO DE CIUDAD ES
    DEFINE vCiudadantigua CHAR(1);
    --SE VERIFICA SI ES CTE NUEVO
    DEFINE vCteNuevo CHAR(1);
    --SE VERIFICA SI ES CTE BANCOPPEL CAPTACIÓN
    DEFINE vCteBanCap CHAR(1);
    --SE VERIFICA SI ES CTE BANCOPPEL CRÉDITO >= 13 MESES (CIUDAD antigua)
    DEFINE vCteBanCredMayorIgual13Mes CHAR(1);
    --SE VERIFICA SI ES CTE COPPEL < 13 MESES (CIUDAD ANTIGUA)
    DEFINE vCteCopMenor13Mes CHAR(1);
    --SE VERIFICA SI ES CTE BANCOPPEL CRÉDITO (CIUDAD ANTIGUA)
    DEFINE vCteBanCred CHAR(1);
    --SE VERIFICA SI ES CTE COPPEL >= 13 MESES (CIUDAD ANTIGUA)
    DEFINE vCteCopMayorIgual13Mes CHAR(1);

    DEFINE vMesesHistoria INTEGER; --Variable que guarda los meses de historia del cte.
    DEFINE vFuente CHAR(1);    --Variable que guarda la fuente del cte.
    DEFINE vBandera CHAR(1);   --Variable de comodin para consultas k solo regresaran un 1 o 0
    DEFINE vCliente CHAR(20);  --Variable que guarda el número de cte.
    DEFINE iSecuenciaOTel INTEGER;
    DEFINE cEmpresaMatriz char(3);
    DEFINE cTipo_solicitud char(1);
    DEFINE cSucursal char(4);
    DEFINE cAutomatico char(1);

    --INICIALIZACION DE VARIABLES--
    LET vCodRet              = '000';
    LET vResultado           = '';
    LET vResIndividual       = '';
    LET vResRefencia         = '';

    LET vCteResTelCasa     = '';
    LET vCteResTelCelular  = '';
    LET vCteResTelTrabajo  = '';

    LET vSecuencia            = 0;
    LET vDestino              = '';
    LET vRespsuptel_llamada   = '';
    LET vRespsuptel_gestion   = '';

    LET C_CLIENTE    = 'C';
    LET C_REFERENCIA = 'R';
    LET vEntidad = '';

    LET vCiudadantigua = '';
    LET vCteNuevo = '';
    LET vCteBanCap = '';
    LET vCteBanCredMayorIgual13Mes = '';
    LET vCteCopMenor13Mes = '';
    LET vCteBanCred = '';
    LET vCteCopMayorIgual13Mes = '';

    LET vMesesHistoria = 0;
    LET vFuente = '';
    LET vBandera = '';
    LET vCliente = '';
--    LET vGeneraSupervision = '';

    LET iSecuenciaOTel = '';
    LET cEmpresaMatriz = '';
    LET cTipo_solicitud = '';
    LET vGenerada = 'F';
    LET cSucursal = '';
    LET vEnviada = '0';
    LET vRespondioCAT = '';
    LET cAutomatico = '';

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET vCodRet=iSqlErr;
            RETURN vCodRet, vResultado, vGenerada, vEnviada;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/tmp/Bernardo/sp_OStelConsultaResultado.out';
    --TRACE ON;

    IF pSolicitud IS NOT NULL AND cEmpresaMatriz IS NOT NULL THEN
    --VALIDAR QUE LA OS NO TENGA RESULTADO FINAL CALCULADO

        --SE TOMA LA SECUENCIA MAXIMA QUE PERTENECE A LA OS TELEFONICA
        SELECT {+INDEX(bdisolic:ss_ostelrefsolicitud secuenciaostel_idx)} MAX(secuenciaostel)
        INTO iSecuenciaOTel
        FROM bdisolic:ss_ostelrefsolicitud
        WHERE num_solicitud = pSolicitud;

        --SE OBTIENE NUMCTE.
        /*SELECT numcte, tipo_solicitud
        INTO vCliente, cTipo_solicitud
        FROM bdisolic:ss_solicitudes
        WHERE empresa = pEmpresa
        AND num_solicitud = pSolicitud;

        IF cTipo_solicitud = 'T' THEN
            LET cEmpresaMatriz = 'BAN';
        END IF;

        IF cTipo_solicitud = 'C' THEN
            LET cEmpresaMatriz = 'COP';
        END IF;

        SELECT sucursal
                INTO cSucursal
                FROM bdisolic:ss_solicitudes
                WHERE empresa = pEmpresa
                AND num_solicitud = pSolicitud;*/
                --se modifico para agregar validacion al campo generar_os 03/03/2010
            IF exists(select secuenciaostel from ss_osclientesupervisartel where secuenciaostel = iSecuenciaOTel AND generar_os ='V') then
                LET vGenerada = 'V';
            else
                LET vGenerada = 'F';                
            end if

                IF vGenerada IS NULL THEN
                    let vGenerada = 'F';
                END IF;

        --CHECA SI LA OS FUE ENVIADA AL CAT
        SELECT LIMIT 1 enviada 
        INTO vEnviada
        FROM bdisolic:ss_osclientesupervisartel
        WHERE secuenciaostel = iSecuenciaOTel;
        
        SELECT {+INDEX(bdisolic:ss_ostelrefsolicitud secuenciaostel_idx)} LIMIT 1 nvl(resultadofinal,''), nvl(automatico,0)
        INTO vResultado, cAutomatico
        FROM bdisolic:ss_ostelrefsolicitud
        WHERE secuenciaostel = iSecuenciaOTel and num_solicitud = pSolicitud;

        IF vEnviada = '0' OR vEnviada IS NULL THEN
            LET vEnviada = '0';
            IF cAutomatico = '1' THEN
                LET vResultado = 'S';
            ELSE
                LET vResultado = '';
            END IF;
            RETURN vCodRet, vResultado, vGenerada, vEnviada;
        END IF;

        /*IF vResultado = '' OR vResultado IS NULL THEN
            SELECT LIMIT 1 '1' 
            INTO vRespondioCAT
            FROM SS_OSTELTELEFONOS 
            WHERE secuenciaostel = iSecuenciaOTel
            AND RESPSUPTEL_LLAMADA <> '-';

            IF vRespondioCAT = '' OR vRespondioCAT IS NULL THEN
                    IF cAutomatico = '1' THEN
                        LET vResultado = 'S';
                    ELSE
                        LET vResultado = '';
                    END IF;
                RETURN vCodRet, vResultado, vGenerada, vEnviada;
            END IF;

            /*FOREACH
                SELECT secuencia, destino, respsuptel_llamada, respsuptel_gestion
                INTO vSecuencia, vDestino, vRespsuptel_llamada, vRespsuptel_gestion
                FROM bdisolic:ss_osteltelefonos
                WHERE secuenciaostel = iSecuenciaOTel
                AND (respsuptel_llamada <> '-' AND respsuptel_llamada IS NOT NULL) AND (respsuptel_gestion <> '-' AND respsuptel_gestion IS NOT NULL)
                ORDER BY secuenciaostel,secuencia,secuenciatelefono

                IF vSecuencia = 0 THEN                  --Cliente
                    LET vEntidad = C_CLIENTE;
                ELSE
                    LET vEntidad = C_REFERENCIA;
                    LET vRefResTelCasa     = '';
                    LET vRefResTelCelular  = '';
                    LET vRefResTelTrabajo  = '';
                END IF;

                SELECT LIMIT 1 resultado
                INTO vResIndividual
                FROM bdisolic:ss_ostelmatrizindividual
                WHERE empresamatriz = cEmpresaMatriz
                AND entidad = vEntidad
                AND restelefono = vRespsuptel_llamada
                AND resdireccion = vRespsuptel_gestion;

                IF vDestino = 1 THEN
                    IF vEntidad = C_CLIENTE THEN
                        LET vCteResTelCasa = vResIndividual;
                    ELSE
                        LET vRefResTelCasa = vResIndividual;
                    END IF;
                ELIF vDestino = 2 THEN
                    IF vEntidad = C_CLIENTE THEN
                        LET vCteResTelCelular = vResIndividual;
                    ELSE
                        LET vRefResTelCelular = vResIndividual;
                    END IF;
                ELIF vDestino = 3 THEN
                    IF vEntidad = C_CLIENTE THEN
                        LET vCteResTelTrabajo = vResIndividual;
                    ELSE
                        LET vRefResTelTrabajo = vResIndividual;
                    END IF;
                END IF;

                IF vSecuencia > 0 THEN
                    IF ( vRefResTelCasa <> '' AND vRefResTelCasa IS NOT NULL ) OR ( vRefResTelCelular <> '' AND vRefResTelCelular IS NOT NULL ) OR ( vRefResTelTrabajo <> '' AND vRefResTelTrabajo IS NOT NULL ) THEN     --Valida para no grabar la prime
                        IF vRefResTelCasa = 'V' OR vRefResTelCelular = 'V' OR vRefResTelTrabajo = 'V' THEN      --Por lo menos uno fue valido
                            LET vResRefencia = 'V';
                        ELIF vRefResTelCasa = 'P' OR vRefResTelCelular = 'P' OR vRefResTelTrabajo = 'P' THEN    --No hubo ninguno valido pero por lo menos uno p
                            IF vResRefencia <> 'V' THEN                             --Valida que el resultado anterior no sea de mayor prioridad que el nuevo re
                                LET vResRefencia = 'P';
                            END IF;
                        ELSE                        -- Todos fueron inválidos
                            IF vResRefencia <> 'V' AND vResRefencia <> 'P' THEN     --Valida que el resultado anterior no sea de mayor prioridad que el nuevo re
                                LET vResRefencia = 'I';
                            END IF;
                        END IF;
                    END IF;
                END IF;

            END FOREACH;

            --SE VERIFICA QUE TIPO DE CIUDAD ES
            
            SELECT ciudadantigua
            INTO vCiudadantigua
            FROM bdisolic:ss_osclientesupervisartel
            WHERE secuenciaostel = iSecuenciaOTel;


            --SE TOMAN LOS MESES DE HISTORIA Y LA FUENTE DEL CLIENTE
            SELECT LIMIT 1 NVL(meses_historia,0), NVL(fuente,'')
            INTO vMesesHistoria, vFuente
            FROM bdisolic:ss_resum_scor_fin
            WHERE empresa = pEmpresa
            AND num_solicitud = pSolicitud;

            --SE VERIFICA SI ES CTE NUEVO
            IF vMesesHistoria = 0 OR vMesesHistoria IS NULL THEN
                LET vCteNuevo = '1';
            END IF;

            --SE VERIFICA SI ES CTE BANCOPPEL CAPTACIÓN
            SELECT LIMIT 1 '1'
            INTO vBandera
            FROM bdinvers:sv_maeinv
            WHERE empresa = pEmpresa
            AND num_cte = vCliente;

            IF vBandera = '' OR vBandera IS NULL THEN
                SELECT LIMIT 1 '1'
                INTO vBandera
                FROM bdicheq:sc_maechq
                WHERE empresa = pEmpresa
                AND num_cte = vCliente;
            END IF;

            IF vBandera = '1' THEN
                let vCteBanCap = '1';
            END IF;

            LET vBandera = '';

            --SE ACTIVA BANDERA PARA SABER SI TIENE CREDITO BANCOPPEL
            SELECT LIMIT 1 '1'
            INTO vBandera
            FROM bdicred:sd_maecred
            WHERE empresa = pEmpresa
            AND numcte = vCliente;

            IF vBandera = '1' THEN
                let vCteBanCred = '1'; --SE MARCA QUE SI ES CTE BANCOPPEL CRÉDITO (CIUDAD ANTIGUA)
                IF vMesesHistoria >= 13 THEN
                    let vCteBanCredMayorIgual13Mes = '1'; --SE MARCA QUE SI ES CTE BANCOPPEL CRÉDITO >= 13 MESES (CIUDAD antigua)
                END IF;
            END IF;

            --SE VERIFICA SI ES CTE COPPEL < 13 MESES (CIUDAD ANTIGUA)
            IF vFuente = 'T' AND vMesesHistoria < 13 THEN
                LET vCteCopMenor13Mes = '1';
            END IF;

            --SE VERIFICA SI ES CTE COPPEL >= 13 MESES (CIUDAD ANTIGUA)
            IF vFuente = 'T' AND vMesesHistoria >= 13 THEN
                LET vCteCopMayorIgual13Mes = '1';
            END IF;

            IF (vResRefencia IS NULL) OR (vResRefencia = '') THEN
                LET vResRefencia = '-';
            END IF;
            IF (vCteResTelTrabajo IS NULL) OR (vCteResTelTrabajo = '') THEN
                LET vCteResTelTrabajo = '-';
            END IF;
            IF (vCteResTelCasa IS NULL) OR (vCteResTelCasa = '') THEN
                LET vCteResTelCasa = '-';
            END IF;
            IF (vCteResTelCelular IS NULL) OR (vCteResTelCelular = '') THEN
                LET vCteResTelCelular = '-';
            END IF;

            --SE CONSULTA LA RESPUESTA FINAL
            IF vCteNuevo = '1' THEN
                SELECT LIMIT 1 resultado, generasupervision
                INTO vResultado, vGeneraSupervision
                FROM bdisolic:ss_ostelmatrizgeneral
                WHERE empresamatriz = cEmpresaMatriz
                AND ciudadantigua = vCiudadantigua
                AND resreferencia = vResRefencia
                AND restrabajo = vCteResTelTrabajo
                AND (rescasaocelular = vCteResTelCasa OR rescasaocelular = vCteResTelCelular )
                AND clientenuevo = 'S';
            ELIF vCteBanCap = '1' THEN
                SELECT LIMIT 1 resultado, generasupervision
                INTO vResultado, vGeneraSupervision
                FROM bdisolic:ss_ostelmatrizgeneral
                WHERE empresamatriz = cEmpresaMatriz
                AND ciudadantigua = vCiudadantigua
                AND resreferencia = vResRefencia
                AND restrabajo = vCteResTelTrabajo
                AND ( rescasaocelular = vCteResTelCasa OR rescasaocelular = vCteResTelCelular )
                AND clientecaptacion = 'S';
            ELIF vCteBanCredMayorIgual13Mes = '1' THEN
                SELECT LIMIT 1 resultado, generasupervision
                INTO vResultado, vGeneraSupervision
                FROM bdisolic:ss_ostelmatrizgeneral
                WHERE empresamatriz = cEmpresaMatriz
                AND ciudadantigua = vCiudadantigua
                AND resreferencia = vResRefencia
                AND restrabajo = vCteResTelTrabajo
                AND ( rescasaocelular = vCteResTelCasa OR rescasaocelular = vCteResTelCelular )
                AND clientebancocredmayorigual13meses = 'S';
            ELIF vCteCopMenor13Mes = '1' THEN
                SELECT LIMIT 1 resultado, generasupervision
                INTO vResultado, vGeneraSupervision
                FROM bdisolic:ss_ostelmatrizgeneral
                WHERE empresamatriz = cEmpresaMatriz
                AND ciudadantigua = vCiudadantigua
                AND resreferencia = vResRefencia
                AND restrabajo = vCteResTelTrabajo
                AND ( rescasaocelular = vCteResTelCasa OR rescasaocelular = vCteResTelCelular )
                AND clientecoppelmenor13meses = 'S';
            ELIF vCteBanCred = '1' THEN
                SELECT LIMIT 1 resultado, generasupervision
                INTO vResultado, vGeneraSupervision
                FROM bdisolic:ss_ostelmatrizgeneral
                WHERE empresamatriz = cEmpresaMatriz
                AND ciudadantigua = vCiudadantigua
                AND resreferencia = vResRefencia
                AND restrabajo = vCteResTelTrabajo
                AND ( rescasaocelular = vCteResTelCasa OR rescasaocelular = vCteResTelCelular )
                AND clientebancocredito = 'S';
            ELIF vCteCopMayorIgual13Mes = '1' THEN
                SELECT LIMIT 1 resultado, generasupervision
                INTO vResultado, vGeneraSupervision
                FROM bdisolic:ss_ostelmatrizgeneral
                WHERE empresamatriz = cEmpresaMatriz
                AND ciudadantigua = vCiudadantigua
                AND resreferencia = vResRefencia
                AND restrabajo = vCteResTelTrabajo
                AND ( rescasaocelular = vCteResTelCasa OR rescasaocelular = vCteResTelCelular )
                AND clientecoppelmayorigual13meses = 'S';
            END IF;            

            IF vResultado IS NULL OR vResultado = '' THEN
                LET vResultado = 'V';
            END IF;

            IF vGeneraSupervision <> '' AND vGeneraSupervision IS NOT NULL THEN
                LET vResultado = 'S';
            END IF;

            IF vResultado <> '' AND vResultado IS NOT NULL THEN
               --ACTUALIZAR CAMPO RESULTADO FINAL DE LA TABLA ss_osclientesupervisartel
                UPDATE bdisolic:ss_ostelrefsolicitud
                SET resultadofinal = vResultado
                WHERE secuenciaostel = iSecuenciaOTel and num_solicitud = pSolicitud;

                DELETE FROM bdisolic:ss_ostelrefsolicitud_pendientes
                WHERE secuenciaostel = iSecuenciaOTel AND num_solicitud = pSolicitud;

            END IF;

            --SELECT resultadofinal INTO vResultado FROM ss_ostelrefsolicitud

        END IF;*/

    ELSE
        LET vCodRet        = '001';   --Falta algún parámetro
    END IF;
    --if vGeneraSupervision <> '' AND vGeneraSupervision IS NOT NULL THEN
    --    LET vResultado = vGeneraSupervision;
    --END IF;
   -- if vResultado is NULL or vResultado = '' then
    --    let vResultado = 'V';
    --end if;
			
	IF vResultado = 'A' then
		LET vResultado = 'V';
	ElIF vResultado = '0' then
		LET vResultado = 'S';
	END IF;
	
	IF cAutomatico = '1' THEN
        LET vResultado = 'S';
    END IF;

    RETURN vCodRet, vResultado, vGenerada, vEnviada;

END;
END PROCEDURE;