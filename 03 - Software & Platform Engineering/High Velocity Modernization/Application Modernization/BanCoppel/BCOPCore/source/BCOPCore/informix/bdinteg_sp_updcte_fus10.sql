CREATE PROCEDURE "informix".sp_updcte_fus10() 
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
DEFINE vc_numsolic        CHAR(20);
DEFINE vc_Cuenta2        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_aniomes       CHAR(6);
DEFINE pCte        CHAR(20);
DEFINE vi_num_serial    INTEGER;
DEFINE vd_fecha_mov     DATE;
DEFINE iExiste     INTEGER;
DEFINE vc_statusolic    CHAR(2);
DEFINE vd_FechaSolic    DATE;
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
LET vc_numsolic = "";
LET vc_aniomes="";
LET vc_Cuenta2="";
LET pCte="";
LET vi_num_serial=0;
LET vd_fecha_mov = "";
LET iExiste=0;
LET vc_statusolic = "";
LET vd_FechaSolic = "";


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

--    SET DEBUG FILE TO "/tmp/sp_updcte_fus10.out";
--    TRACE ON;


SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} DISTINCT TRIM(cliente_tit),TRIM(cliente_tras) INTO pClienteTitular,pClienteTraspasaCtas FROM log_fusionclientes WHERE cliente_tit<>'' AND cliente_tras<>''

--**************************************INICIA TRASPASO DE TABLA SS SOLICITUDES ********************************************************************
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdisolic:ss_solicitudes idx_numctempresa)} COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes WHERE numcte=pClienteTraspasaCtas and empresa='001';
    IF iExiste>0 THEN

        FOREACH
            SELECT {+INDEX (bdisolic:ss_solicitudes idx_numctempresa)} num_solicitud, status_solicitud, fecha_insert INTO vc_numsolic, vc_statusolic, vd_FechaSolic FROM bdisolic:ss_solicitudes WHERE numcte=pClienteTraspasaCtas and empresa='001'
            LET vc_proceso='TRASPASO DE SOLICITUDES';
            LET vc_tabla = "ss_solicitudes";
            LET vc_detalle_mov = TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_numsolic)||'|'||TRIM(vc_statusolic)||'|'||vd_FechaSolic;
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', DATE("10/10/2010"));

            INSERT INTO bdinteg:si_fussolicitudes
            SELECT {+INDEX (bdisolic:ss_solicitudes idx_numctempresa)} * FROM bdisolic:ss_solicitudes WHERE num_solicitud=vc_numsolic AND numcte=pClienteTraspasaCtas and empresa='001';

            UPDATE {+INDEX (bdisolic:ss_solicitudes idx_numctempresa)} bdisolic:ss_solicitudes SET numcte = pClienteTitular where num_solicitud=vc_numsolic AND numcte=pClienteTraspasaCtas and empresa='001';
        END FOREACH;  

    END IF;
--**********************************************************************************************************
	
END FOREACH;  

    IF vc_CodRet = "00000" THEN
        RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE;