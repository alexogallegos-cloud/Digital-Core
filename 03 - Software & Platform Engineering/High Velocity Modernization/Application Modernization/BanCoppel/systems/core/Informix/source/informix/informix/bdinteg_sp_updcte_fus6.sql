CREATE PROCEDURE "informix".sp_updcte_fus6() 
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
set lock mode to wait 10;

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

    --SET DEBUG FILE TO "/ids10_uc9/VH/sp_updcte_fus6.out";
    --TRACE ON;


FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes idx_fctetit)} trim(cliente_tit),trim(cliente_tras) INTO pClienteTitular,pClienteTraspasaCtas FROM log_fusionclientes where detalle_mov like '%-236%'
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdinteg:si_fusbitacora_aumlincred2 idx_fusbitacora_status2)} trim(num_solicitud) INTO vc_Cuenta FROM si_fusbitacora_aumlincred2 WHERE empresa='001' and numcte=pClienteTraspasaCtas

            LET vc_proceso='AUMENTO LINEA CRED';
            LET vc_tabla = "sd_bitacora_aumlincred";
            LET vc_detalle_mov = TRIM(pClienteTitular)||'|'||TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);
            
            update bdicred:sd_bitacora_aumlincred set numcte=pClienteTitular where empresa='001' and numcte=pClienteTraspasaCtas and status is not null;
        END FOREACH;  
END FOREACH;

INSERT INTO "informix".si_fusbitacora_aumlincred 
SELECT * FROM "informix".si_fusbitacora_aumlincred2;

DROP TABLE "informix".si_fusbitacora_aumlincred2;

    IF vc_CodRet = "00000" THEN
        RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE;