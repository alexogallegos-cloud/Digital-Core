CREATE PROCEDURE "informix".sp_envia_sms_bm() 
RETURNING CHAR(3)   AS vCodRet1,     --- Codigo de Retorno
          CHAR(60)  AS vEmail,       --- Email Banco
          CHAR(70)  AS vClave,       --- Password Banco
          CHAR(5)   AS vCliente,     --- Cliente Banco
          CHAR(3)   AS vTipoMensaje, --- Tipo de Mensaje
          CHAR(16)  AS vFechaHora,   --- Fecha y hora del envío
          CHAR(10)  AS vTelefono,    --- Telefono Cliente
          CHAR(160) AS vMensaje,     --- Informacion General
          CHAR(1)   AS vRestanSolic; --- Solicitudes Pendientes  
    
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    
    DEFINE vCliente             CHAR(5);
    DEFINE vClave               CHAR(70);
    DEFINE vEmail               CHAR(60);
    DEFINE vTelefono            CHAR(10);
    DEFINE vTipoMensaje         CHAR(3);
    DEFINE vMensaje             CHAR(160);
    DEFINE vRestanSolic         CHAR(1);
    DEFINE vStatus              CHAR(2);
    DEFINE vStatusNvo           CHAR(2);
    DEFINE vNumCte              CHAR(20);
    DEFINE vexiste_solicitudes  SMALLINT;
    DEFINE vFecha               CHAR(10);
    DEFINE vHora                CHAR(5);
    DEFINE vFechaHora           CHAR(16);
        
    LET Sql_Err	 = 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = '';
    
    LET vCliente = '';
    LET vClave = '';
    LET vEmail = '';
    LET vTelefono = '';
    LET vTipoMensaje = '';
    LET vMensaje = '';
    LET vRestanSolic = '0';
    LET vStatus = '';
    LET vStatusNvo = '';
    LET vNumCte = '';
    LET vexiste_solicitudes = 0;
    LET vFecha = '';
    LET vHora = '';
    LET vFechaHora = '';
    
    BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_envia_sms_bm.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, vEmail, vClave, vCliente, vTipoMensaje, vFechaHora, vTelefono, vMensaje, vRestanSolic;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_envia_sms_bm.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE PARAMETROS PARA ENVIO    
    SELECT valor 
      INTO vCliente --- CLIENTE BANCOPPEL
      FROM bdinteg:"informix".si_param
     WHERE cod_param = 80
       AND empresa = '001';
     
    SELECT valor 
      INTO vClave --- CLAVE BANCOPPEL 
      FROM bdinteg:"informix".si_param
     WHERE cod_param = 81
       AND empresa = '001';
     
    SELECT valor 
      INTO vEmail --- EMAIL BANCOPPEL
      FROM bdinteg:"informix".si_param
     WHERE cod_param = 82
       AND empresa = '001';
     
    SELECT valor 
      INTO vTipoMensaje --- TIPO DE MENSAJE
      FROM bdinteg:"informix".si_param
     WHERE cod_param = 83
       AND empresa = '001';
     
    SELECT valor 
      INTO vMensaje --- MENSAJE
      FROM bdinteg:"informix".si_param
     WHERE cod_param = 84
       AND empresa = '001';
     
    -- // VALIDA PARAMETROS DE ENVIO
    IF (vCliente is null OR vCliente = '') OR
       (vClave is null OR vClave = '') OR
       (vEmail is null OR vEmail = '') OR
       (vTipoMensaje is null OR vTipoMensaje = '') OR
       (vMensaje is null OR vMensaje = '') THEN
        LET vCodRet1 = '111';
        LET vEmail = '';
        LET vClave = '';
        LET vCliente = '';
        LET vTipoMensaje = '';
        LET vFechaHora = '';
        LET vTelefono = '';
        LET vMensaje = '';
        LET vRestanSolic = '0';
        RETURN vCodRet1, vEmail, vClave, vCliente, vTipoMensaje, vFechaHora, vTelefono, vMensaje, vRestanSolic;
    END IF;
    
    -- // OBTENE LA FECHA Y HORA DEL ENVÍO
    LET vFecha = CURRENT::DATE;
    LET vHora  = CURRENT HOUR TO MINUTE;
    LET vFechaHora = SUBSTR(vFecha,4,2)||'/'||SUBSTR(vFecha,1,2)||'/'||SUBSTR(vFecha,7,4)||'/'||SUBSTR(vHora,1,2)||'/'||SUBSTR(vHora,4,2);
    
    -- // VALIDA SI EXISTEN SOLICITUDES POR ENVIAR
    SELECT COUNT(*)
      INTO vexiste_solicitudes
      FROM bdinteg:"informix".si_bm_usuarios
     WHERE id_status IN('10','15');
     
    IF vexiste_solicitudes > 0 THEN
        -- // OBTIENE DATOS DEL USUARIO
        SELECT LIMIT 1 numcel, id_status, numcte
          INTO vTelefono, vStatus, vNumCte
          FROM bdinteg:"informix".si_bm_usuarios
         WHERE id_status IN('10','15');
         
        IF vStatus = '10' THEN
            LET vStatusNvo = '20';
        ELIF vStatus = '15' THEN
            LET vStatusNvo = '30';
        END IF;
        
        -- // ACTUALIZA STATUS DEL USUARIO
        UPDATE bdinteg:"informix".si_bm_usuarios
           SET id_status = vStatusNvo
         WHERE numcel = vTelefono;
         
        -- // REGISTRA CAMBIO DE STATUS
        INSERT INTO bdinteg:"informix".si_bm_camestcte(numcte, id_statant, id_statact, numcel, fecha_mod, suc_mod, user_mod)
        VALUES(vNumCte, vStatus, vStatusNvo, vTelefono, current, '5002', 'informix');
        
        -- // ELIMINA SOLICITUD DE ENVIO DE MENSAJE
        DELETE FROM bdinteg:"informix".si_bm_envsolmsn
         WHERE numcel = vTelefono;
        
        IF vexiste_solicitudes > 1 THEN
            LET vRestanSolic = '1';
        END IF;
    ELSE
        LET vCodRet1 = '999';
    END IF;
    
    END;
    
    RETURN vCodRet1, vEmail, vClave, vCliente, vTipoMensaje, vFechaHora, vTelefono, vMensaje, vRestanSolic;
    
END PROCEDURE;