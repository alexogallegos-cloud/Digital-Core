CREATE PROCEDURE "informix".sp_generaconsumo(pMes smallint, pAnio smallint)

    RETURNING CHAR (6), CHAR(80)

    --Declaracion de variables
    DEFINE v_codret             CHAR(6);
    DEFINE v_sqlerr             INTEGER;
    DEFINE v_isam_err           INTEGER;
    DEFINE v_error_info         CHAR(80);
    DEFINE v_mensaje            CHAR(80);
    DEFINE cNum_Credito         CHAR(20);
    DEFINE cEmpresa             CHAR(3);
    DEFINE cId_conceptom        CHAR(3);
    DEFINE dSaldoPromedio       DECIMAL(18,2);
    DEFINE dMontoOtorgado       DECIMAL(18,2);
    DEFINE vConsumo             DECIMAL(18,2);
    
    DEFINE cNombreProceso CHAR(30);
    DEFINE cMesAnioEjecucion CHAR(20);

    --SET DEBUG FILE TO "/tmp/sp_generaconsumo.out";
    --TRACE ON; 
    
    --Inicializacion de variables
    LET v_codret          = '11111';
    LET v_mensaje         = 'PROCESO INICIALIZADO';
    LET v_sqlerr          = 0;
    LET v_error_info      = '';
    LET v_isam_err        = 0;
    LET dSaldoPromedio    = 0;
    LET cEmpresa          = '';
    LET cId_conceptom     = '220';
    LET dMontoOtorgado    = 0;
    LET vConsumo          = 0;
    
    LET cNombreProceso = 'Genera Consumo';
    LET cMesAnioEjecucion = TO_CHAR(MDY(pMes,1,pAnio),'%m-%Y');

    ---------------------------------------------------------
    --23-02-2009
    --Realizo:
    --Bernardo Carlos Baez Gonzalez
    --Generar indicadores de consumo de linea de credito para
    --un mes y año determinado
    
    --02-04-2009
    --Modifico:
    --Abraham Ayala
    --Se modifico el Sp para que este programado de acuerdo a como el CU lo especifica.
    
    --Modificó: Lorenzo Ibarra Garcia
    --Fecha: 08-10-2009
    --Se agregó la inserción a la tabla de la bitacora.
    ---------------------------------------------------------

    BEGIN
        ON EXCEPTION SET v_sqlerr, v_isam_err, v_error_info
            IF v_sqlerr != 0 THEN
                ROLLBACK WORK;
                LET v_codret = v_sqlerr;
                LET v_mensaje = v_error_info;
                
                --insertar control de procesos
                INSERT INTO mc_bitacora_eje (proceso, cod_ret, mensaje, user_insert, fecha_insert, mes_ano_ejecutado, hora_insert) 
                VALUES(cNombreProceso, v_codret, v_mensaje, USER, (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals),
                cMesAnioEjecucion, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
                
                RETURN v_codret, v_mensaje;
            END IF;
        END EXCEPTION;
        
        IF pMes < 1 OR pMes > 12 OR pMes IS NULL OR pMes = '' OR pAnio IS NULL OR pAnio = '' THEN
            LET v_codret = '99999';
            LET v_mensaje = 'Parametros no validos';
            RETURN v_codret, v_mensaje;
        END IF;
        
        --insertar control de procesos
        INSERT INTO mc_bitacora_eje (proceso, cod_ret, mensaje, user_insert, fecha_insert, mes_ano_ejecutado, hora_insert) 
        VALUES(cNombreProceso, v_codret, v_mensaje, USER, (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals),
        cMesAnioEjecucion, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
        
        SET ISOLATION DIRTY READ;
        BEGIN WORK;

        FOREACH
            SELECT empresa, num_credito
            INTO cEmpresa, cNum_Credito
            FROM bdimonitorcob:mc_masterestad
            GROUP BY empresa, num_credito

            SELECT NVL(sdo_acum_mes_cap, 0) + NVL(cap_tras_no_venci, 0) / CASE WHEN dias_acum_int = 0 THEN 1 ELSE dias_acum_int END
            INTO dSaldoPromedio
            FROM bdicred:sd_maesdoshist
            WHERE YEAR(fecha) = pAnio
                AND MONTH(fecha) = pMes
                AND empresa = cEmpresa
                AND num_credito = cNum_Credito;

            SELECT monto_otorgado
            INTO dMontoOtorgado
            FROM bdicred:sd_maesdos b
            WHERE empresa = cEmpresa
                AND num_credito = cNum_Credito;

            LET vConsumo = NVL((dSaldoPromedio / dMontoOtorgado * 100), 0);

            IF EXISTS (SELECT num_credito FROM bdimonitorcob:mc_detestadmes WHERE empresa = cEmpresa AND id_conceptom = cId_conceptom
                AND num_credito = cNum_Credito AND anio = pAnio) THEN

                IF pMes = 1 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET ene = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 2 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET feb = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 3 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET mar = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 4 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET abr = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 5 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET may = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 6 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET jun = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 7 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET jul = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 8 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET ago = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 9 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET sep = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 10 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET oct = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 11 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET nov = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                ELIF pMes = 12 THEN
                    UPDATE bdimonitorcob:mc_detestadmes SET dic = vConsumo WHERE empresa = cEmpresa
                        AND anio = pAnio AND id_conceptom = cId_conceptom AND num_credito = cNum_Credito;
                END IF;
            ELSE
                IF pMes = 1 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, ene)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 2 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, feb)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 3 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, mar)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 4 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, abr)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 5 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, may)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 6 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, jun)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 7 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, jul)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 8 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, ago)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 9 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, sep)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 10 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, oct)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 11 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, nov)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                ELIF pMes = 12 THEN
                    INSERT INTO bdimonitorcob:mc_detestadmes (empresa, id_conceptom, num_credito, anio, dic)
                        VALUES (cEmpresa, cId_conceptom, cNum_Credito, pAnio, vConsumo);
                END IF;
            END IF;
        END FOREACH;
        
        COMMIT WORK;  

        LET v_codret = '00000';
        LET v_mensaje = 'PROCESO EXITOSO';
        --insertar control de procesos
        INSERT INTO mc_bitacora_eje (proceso, cod_ret, mensaje, user_insert, fecha_insert, mes_ano_ejecutado, hora_insert) 
        VALUES(cNombreProceso, v_codret, v_mensaje, USER, (SELECT DBINFO('utc_to_datetime', sh_curtime) from sysmaster:sysshmvals),
        cMesAnioEjecucion, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
        
        RETURN v_codret, v_mensaje;
    END
END PROCEDURE;