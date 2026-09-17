CREATE PROCEDURE "informix".sp_updcte_fus8() 
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
DEFINE vd_fecha_mov     DATE;
DEFINE iExiste     INTEGER;
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
LET vd_fecha_mov = "";
LET iExiste=0;




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

    --SET DEBUG FILE TO "/tmp/sp_updcte_fus8.out";
    --TRACE ON;


SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} DISTINCT TRIM(cliente_tit),TRIM(cliente_tras) INTO pClienteTitular,pClienteTraspasaCtas FROM log_fusionclientes WHERE cliente_tit<>'' AND cliente_tras<>''

--**************************************INICIA TRASPASO DE TABLA SS_SOLICITUDES_MC ********************************************************************
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_mc WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN

        FOREACH
            SELECT num_solicitud INTO vc_Cuenta FROM bdisolic:ss_solicitudes_mc WHERE numcte=pClienteTraspasaCtas
            LET vc_proceso='SOLICITUDES_MC';
            LET vc_tabla = "ss_solicitudes_mc";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fussolicitudes_mc 
            SELECT * FROM bdisolic:ss_solicitudes_mc WHERE num_solicitud=vc_Cuenta AND numcte=pClienteTraspasaCtas;

            UPDATE bdisolic:ss_solicitudes_mc SET numcte = pClienteTitular where num_solicitud=vc_Cuenta AND numcte=pClienteTraspasaCtas;
        END FOREACH;  

    END IF;
    --**********************************************************************************************************

    --**************************************INICIA TRASPASO DE TABLA SS_SOLICITUDES_SIC ********************************************************************
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_sic WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
        FOREACH
            SELECT num_solicitud INTO vc_Cuenta FROM bdisolic:ss_solicitudes_sic WHERE numcte=pClienteTraspasaCtas
            LET vc_proceso='SOLICITUDES_SIC';
            LET vc_tabla = "ss_solicitudes_sic";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fussolicitudes_sic 
            SELECT * FROM bdisolic:ss_solicitudes_sic WHERE num_solicitud=vc_Cuenta AND numcte=pClienteTraspasaCtas;

            UPDATE bdisolic:ss_solicitudes_sic SET numcte = pClienteTitular where num_solicitud=vc_Cuenta AND numcte=pClienteTraspasaCtas;
        END FOREACH;  
    END IF;
    --**********************************************************************************************************

    --**************************************INICIA TRASPASO DE TABLA SS_SOLICITUDES_CAC ********************************************************************
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_cac WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
        FOREACH 
            SELECT num_solicitud INTO vc_Cuenta FROM bdisolic:ss_solicitudes_cac WHERE numcte=pClienteTraspasaCtas
            LET vc_proceso='SOLICITUDES_CAC';
            LET vc_tabla = "ss_solicitudes_cac";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fussolicitudes_cac 
            SELECT * FROM bdisolic:ss_solicitudes_cac WHERE num_solicitud=vc_Cuenta AND numcte=pClienteTraspasaCtas;

            UPDATE bdisolic:ss_solicitudes_cac SET numcte = pClienteTitular where num_solicitud=vc_Cuenta AND numcte=pClienteTraspasaCtas;
        END FOREACH;  
    END IF;
    --**********************************************************************************************************

END FOREACH;  


    IF vc_CodRet = "00000" THEN
        RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE;