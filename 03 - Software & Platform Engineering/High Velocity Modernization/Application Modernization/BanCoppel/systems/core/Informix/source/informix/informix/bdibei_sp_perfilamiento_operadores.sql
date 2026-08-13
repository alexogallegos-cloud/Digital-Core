CREATE PROCEDURE "informix".sp_perfilamiento_operadores() RETURNING CHAR(5) AS codigo, CHAR(300) AS mensaje;

-- *******************************************************************************************************************
-- DESCRIPCION: SP temporal para ejecutar un perfilamiento del modulo de cancelaciones de empresanet para aquellas 
--              empresas que tengan perfilado Consulta de Reportes de Ordenes de pago, bajo las siguientes reglas:
--              * Se registraran solo aquellos que tengan consulta de reportes
--              * El operador perfilado debe estar asociado con un perfil de estatus activo, al igual que el usuario
--              * La cuenta perfilada para el operador debe ser valida y estatus activa
--              * La cuenta debe estar asociada a un cliente con estatus activo 
--              * Los modulos actuales de cancelaciones asociados a una cuenta y operadaror(perfil) debe omitirse 
--                  el insert para evitar duplicaciones
-- Autor: Marco Tinajero
-- FECHA : 17/03/2021
-- SOLICITO : Armando Barrientos
-- ESQUEMA DE BD: bdibei
-- *******************************************************************************************************************

    -- VARIABLES DE CONTROL
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE iDescErr             CHAR(300);
    DEFINE cCodRet              CHAR(5);
    DEFINE cCodRet2             CHAR(5);
    DEFINE cMensaje             CHAR(300);
    DEFINE cMensajeLog          CHAR(300);
    DEFINE iTransaccion         INTEGER;
    DEFINE cCodSPGuardarOper    CHAR(5);
    DEFINE iClaveSPGuardarOper  INTEGER;

    -- VARIABLES DE SELECT INTO
    DEFINE cClaveOperativa        CHAR(10);
    DEFINE iClaveMenuOperativa    INTEGER;
    DEFINE iClavePerfil           INTEGER;
    DEFINE cNumCuenta             CHAR(16);
    DEFINE dMontoMin              DECIMAL(16,2);
    DEFINE dMontoMax              DECIMAL(16,2);
    DEFINE cMancomunidad          CHAR(5);
    DEFINE iClavePerfilAdmin      INTEGER;

    -- VARIABLES DE EJECUCION
    DEFINE iClaveRelMenuOperCancelacion             INTEGER;
    DEFINE cEstatusMancomunidad                     CHAR(1);
    DEFINE iBanderaExisteCancelacion                INTEGER;

    LET iSqlErr		    = 0;
    LET iIsamErr	    = 0;
    LET iDescErr	    = '';
    LET cCodRet         = '00000';
    LET cCodRet2        = '';
    LET cMensaje        = '';
    LET cMensajeLog     = '';
    LET iTransaccion    = 0;
    LET cCodSPGuardarOper   = '00000';
    LET iClaveSPGuardarOper = 0;

    LET iClaveRelMenuOperCancelacion    = 69;
    LET cEstatusMancomunidad            = '';
    LET iBanderaExisteCancelacion       = 0;

    LET cClaveOperativa      = '';
    LET iClaveMenuOperativa  = 0;
    LET iClavePerfil         = 0;
    LET cNumCuenta           = '';
    LET dMontoMin            = 0;
    LET dMontoMax            = 0;
    LET cMancomunidad        = 'F';
    LET iClavePerfilAdmin    = 0;

    --SET DEBUG FILE TO "/home/informix/BereniceOut/sp_perfilamiento_operadores.out";
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr
            SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_perfilamiento_operadores.err";
            TRACE ON;

            IF iSqlErr != 0 THEN
                LET cCodRet = '00003';
                LET cCodRet2 = iIsamErr;
                LET cMensaje = 'OCURRIO UN ERROR NO CONTROLADO - SqlErr: ' || iSqlErr;

                IF iTransaccion = 1 THEN
                    ROLLBACK WORK;
                END IF;

                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        BEGIN WORK;

            FOREACH WITH HOLD 
                SELECT  
                        tblPerfilamientoOper.id_oper, 
                        tblPerfilamientoOper.id_menu_oper, 
                        tblPerfilamientoOper.id_perfil, 
                        tblPerfilamientoOper.num_cta, 
                        tblPerfilamientoOper.monto_min, 
                        tblPerfilamientoOper.monto_max, 
                        tblPerfilamientoOper.mancomunado, 
                        tblPerfilamientoOper.createdby,
                        (SELECT COUNT(1) FROM bdibei:bei_operaciones WHERE id_perfil = tblPerfilamientoOper.id_perfil AND num_cta = tblPerfilamientoOper.num_cta AND id_menu_oper = iClaveRelMenuOperCancelacion) AS flgExisteCancelacion
                    INTO 
                        cClaveOperativa,
                        iClaveMenuOperativa,
                        iClavePerfil,
                        cNumCuenta,
                        dMontoMin,
                        dMontoMax,
                        cMancomunidad,
                        iClavePerfilAdmin,
                        iBanderaExisteCancelacion
                FROM bdibei:bei_operaciones tblPerfilamientoOper
                    INNER JOIN bdibei:bei_usuario_perfil tblUsrPerfil ON tblUsrPerfil.id_perfil = tblPerfilamientoOper.id_perfil
                    INNER JOIN bdibei:bei_usuario tblUsr ON tblUsr.id_usuario = tblUsrPerfil.id_usuario
                    INNER JOIN bdibei:bei_perfil tblPerfil ON tblPerfil.id_perfil = tblUsrPerfil.id_perfil
                    INNER JOIN bdicheq:sc_maechq tblCuenta ON tblCuenta.cuenta = tblPerfilamientoOper.num_cta
                    INNER JOIN bdinteg:si_cliente tblCliente ON tblCliente.numcte = tblCuenta.num_cte
                WHERE tblPerfilamientoOper.id_menu_oper = 44 --59 
                    AND tblUsr.id_status = 30 
                    AND tblPerfil.activo = 't' 
                    AND tblCuenta.status_cta = '1' 
                    AND tblCliente.status_cte = 'AL'
                ORDER BY tblPerfilamientoOper.id_oper

                LET iTransaccion = 1;
                LET cMensajeLog = 'ID-' || cClaveOperativa || ' Tiene Cancelacion: ' || iBanderaExisteCancelacion;

                TRACE 'ITERACION: ' || cMensajeLog;

                -- Obtener bandera de mancomunidad y cambiar por letra boleana T o F
                LET cEstatusMancomunidad = 'f';
                IF cMancomunidad = 'T' THEN
                    LET cEstatusMancomunidad = 't';
                END IF;

                -- Solo se tomaran los registros que no tengan asociado un modulo de cancelacion por usuario y cuenta
                IF iBanderaExisteCancelacion = 0 THEN
                    TRACE 'EXECUTE PROCEDURE bdibei:"informix".sp_guarda_oper_bei(' || iClavePerfil || ',' || iClaveRelMenuOperCancelacion || ',' || cNumCuenta || ','|| dMontoMin || ','|| dMontoMax || ','|| cEstatusMancomunidad || ',' || iClavePerfilAdmin ||')';

                    -- Ejecutar el SP de guardado de la operacion de perfilamiento por usuario y cuenta
                    EXECUTE PROCEDURE bdibei:"informix".sp_guarda_oper_bei(
                        iClavePerfil,
                        iClaveRelMenuOperCancelacion,
                        cNumCuenta,
                        dMontoMin,
                        dMontoMax,
                        cEstatusMancomunidad,
                        iClavePerfilAdmin
                    ) INTO cCodSPGuardarOper, iClaveSPGuardarOper;
                END IF;

                -- Validar salida del SP sp_guarda_oper_bei
                IF cCodSPGuardarOper != '00000' THEN
                    LET cMensajeLog = cMensajeLog || ' - ERROR INSERT';

                    EXIT FOREACH;
                END IF;

                LET iTransaccion = 0;

            END FOREACH;

            -- Si ocurriese un error y siguiera corriendo el SP, se debe ejecutar un rollback a toda la operacion
            IF iTransaccion = 1 THEN
                LET cCodRet = '00002';
                LET cMensaje = 'ERROR, SE REALIZA ROLLBACK POR INSERT DEL REGISTRO: ' || cMensajeLog;
                ROLLBACK WORK;

                RETURN cCodRet, cMensaje;
            END IF;

        COMMIT WORK;

      LET cMensaje = 'PROCESO EJECUTADO CORRECTAMENTE';

    RETURN cCodRet, cMensaje;
    END;

END PROCEDURE;