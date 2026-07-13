CREATE PROCEDURE "informix".sp_traspaso_firmantes() 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE pClienteTitular        CHAR(20);
DEFINE pClienteTraspasaCtas        CHAR(20);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_Cuenta        CHAR(20);
DEFINE vi_secuencia     INTEGER;
--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_secuencia = 0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET pClienteTitular="";
LET pClienteTraspasaCtas="";
LET vc_detalle_mov2 = "";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_Cuenta = "";



set isolation to dirty read;
set lock mode to wait 3;

    --BEGIN WORK;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
      --      ROLLBACK WORK;
            let vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/ids10_uc9/VH/170611/sp_traspaso_firmantes.out";
    --TRACE ON;

    --******************INICIA TRASPASO DE BENEFICIARIOS****************************************
    --******************************************************************************************
SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} DISTINCT cliente_tit,cliente_tras into pClienteTitular,pClienteTraspasaCtas FROM log_fusionclientes where cliente_tit<>'' and cliente_tras<>''
    
    SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT cuenta, secuencia INTO vc_Cuenta,vi_secuencia FROM bdicheq:sc_beneficiario WHERE numcte = pClienteTraspasaCtas

            let vc_proceso='BENEFICIARIO';
            LET vc_tabla = "sc_beneficiario";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||vi_secuencia||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusbeneficiario 
            SELECT * FROM bdicheq:sc_beneficiario WHERE cuenta = vc_Cuenta and empresa='001' AND secuencia=vi_secuencia;     
		
            UPDATE bdicheq:sc_beneficiario SET numcte = pClienteTitular WHERE cuenta = vc_Cuenta and empresa='001' AND secuencia=vi_secuencia; 
        END FOREACH;  
END FOREACH;  


    --******************INICIA TRASPASO DE FIRMANTES********************************************
    --******************************************************************************************
SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} DISTINCT cliente_tit,cliente_tras into pClienteTitular,pClienteTraspasaCtas FROM log_fusionclientes where cliente_tit<>'' and cliente_tras<>''
    
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT cuenta, secuencia INTO vc_Cuenta,vi_secuencia FROM bdicheq:sc_firmantes WHERE numcte = pClienteTraspasaCtas

            let vc_proceso='FIRMANTES';
            LET vc_tabla = "sc_firmantes";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||vi_secuencia||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusfirmantes 
            SELECT * FROM bdicheq:sc_firmantes WHERE cuenta = vc_Cuenta and empresa='001' AND secuencia=vi_secuencia;     
		
            UPDATE bdicheq:sc_firmantes SET numcte = pClienteTitular WHERE cuenta = vc_Cuenta and empresa='001' AND secuencia=vi_secuencia; 
        END FOREACH;  


END FOREACH;  


    IF vc_CodRet = "00000" THEN
        --COMMIT WORK;
        RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE;