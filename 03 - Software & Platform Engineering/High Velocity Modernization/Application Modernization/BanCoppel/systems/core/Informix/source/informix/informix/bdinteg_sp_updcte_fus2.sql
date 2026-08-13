CREATE PROCEDURE "informix".sp_updcte_fus2() 
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
DEFINE vc_Cuenta2        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_aniomes       CHAR(6);
DEFINE pCte        CHAR(20);
DEFINE vi_num_serial    INTEGER;
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
LET vc_aniomes="";
LET vc_Cuenta2="";
LET pCte="";
LET vi_num_serial=0;




set isolation to dirty read;
set lock mode to wait 3;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            LET vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/ids10_uc9/VH/sp_updcte_fus.out";
    --TRACE ON;


SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} DISTINCT TRIM(cliente_tit),TRIM(cliente_tras) INTO pClienteTitular,pClienteTraspasaCtas FROM bdinteg:log_fusionclientes WHERE cliente_tit<>'' AND cliente_tras<>'' and cliente_tit not in ('003080156','008401386')
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} trim(num_solicitud) INTO vc_Cuenta FROM bdicred:sd_bitacora_aumlincred WHERE empresa='001' and numcte=pClienteTraspasaCtas and status is not null

            LET vc_proceso='AUMENTO LINEA CRED';
            LET vc_tabla = "sd_bitacora_aumlincred";
            LET vc_detalle_mov = TRIM(pClienteTitular)||'|'||TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusbitacora_aumlincred 
            SELECT {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} * FROM bdicred:sd_bitacora_aumlincred WHERE empresa='001' and numcte=pClienteTraspasaCtas and status is not null and num_solicitud=vc_Cuenta;
		
            UPDATE {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} bdicred:sd_bitacora_aumlincred SET numcte = pClienteTitular WHERE empresa='001' and numcte=pClienteTraspasaCtas and status is not null and num_solicitud=vc_Cuenta; 
        END FOREACH;  

        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (intercard:tarjeta idx_numcte)} trim(numtarjeta) INTO vc_Cuenta2 FROM intercard:tarjeta WHERE numcliente=pClienteTraspasaCtas

            LET vc_proceso='INTERCARD';
            LET vc_tabla = "intercard";
            LET vc_detalle_mov = TRIM(pClienteTitular)||'|'||TRIM(vc_Cuenta2)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusintercardtarjeta
            SELECT * FROM intercard:tarjeta where numcliente=pClienteTraspasaCtas and numtarjeta = vc_Cuenta2;
		
            UPDATE intercard:tarjeta SET numcliente= pClienteTitular WHERE numcliente=pClienteTraspasaCtas and numtarjeta = vc_Cuenta2;
        END FOREACH;  
END FOREACH;


    IF vc_CodRet = "00000" THEN
        RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE;