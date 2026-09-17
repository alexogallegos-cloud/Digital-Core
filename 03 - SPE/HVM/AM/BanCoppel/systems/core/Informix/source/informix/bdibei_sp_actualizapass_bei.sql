CREATE PROCEDURE "informix".sp_actualizapass_bei(
    pEmpresa char(3), 
    pNumCte char(20), 
    pPass char(50), 
    pIp char (15), 
    pSucVirtual char (4), 
    pUsuVirtual char(8),
    pIdUsuario integer
)
returning char(5);

   --Modificó: SOLSER
   --Actividad: activa el usuario y registra el cambio de status
   --Fecha: 09-07-2013

    DEFINE cCod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE iStatus smallint ;

   LET cCod_ret  = "00000";
   LET iStatus = 0;   
        BEGIN
            ON EXCEPTION SET sql_err                
                IF sql_err <> 0 THEN
                    LET cCod_ret = sql_err;
                    RETURN cCod_ret;
                END IF ;
            END EXCEPTION ;

            SELECT id_status
            INTO iStatus
            FROM bei_usuario
            WHERE id_usuario = pIdUsuario;

            IF (iStatus IS NULL) THEN
                LET cCod_ret = '00001'; --NO EXISTE CLIENTE
                RETURN cCod_ret;
            END IF;

            SET LOCK MODE TO WAIT 4;
            SET ISOLATION DIRTY READ ;

            UPDATE "informix".bei_usuario
            SET pass3 = pass2, pass2 = pass1, pass1 = pass, f_pass3 = f_pass2,
                f_pass2 = f_pass1, f_pass1 = f_pass, pass = pPass, 
                f_pass = current, f_actualizacion = current
            WHERE id_usuario = pIdUsuario;


            IF (iStatus = 40 OR  iStatus = 90) THEN
                INSERT INTO "informix".bei_cambiostusuario(
                    id_usuario, numcliente, 
                    id_statusanterior, id_statusactual, 
                    ipusuario, fecha_cambio, 
                    suc_cambio, usuario_cambio, 
                    pidentadmin) 
                VALUES(
                    pIdUsuario, pNumCte, 
                    iStatus, 30, 
                    pIp, CURRENT, 
                    pSucVirtual, pUsuVirtual, 
                    NULL);

                UPDATE "informix".bei_usuario
                    SET id_status = 30, f_status = current 
                WHERE id_usuario = pIdUsuario;

            END IF;

            INSERT INTO "informix".bei_cambiostusuario(
                    id_usuario, numcliente, 
                    id_statusanterior, id_statusactual, 
                    ipusuario, fecha_cambio, 
                    suc_cambio, usuario_cambio, 
                    pidentadmin) 
                VALUES(
                    pIdUsuario, pNumCte, 
                    30, iStatus,
                    pIp, CURRENT, 
                    pSucVirtual, pUsuVirtual, 
                    NULL);		

            RETURN cCod_ret;
        END    
END PROCEDURE ;