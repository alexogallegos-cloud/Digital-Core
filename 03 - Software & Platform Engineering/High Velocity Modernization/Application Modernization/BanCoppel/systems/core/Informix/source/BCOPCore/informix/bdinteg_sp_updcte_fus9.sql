CREATE PROCEDURE "informix".sp_updcte_fus9() 
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
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), 'informix', '10/10/2010');

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO "/tmp/sp_updcte_fus9.out";
--    TRACE ON;


SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} DISTINCT TRIM(cliente_tit),TRIM(cliente_tras) INTO pClienteTitular,pClienteTraspasaCtas FROM log_fusionclientes WHERE cliente_tit<>'' AND cliente_tras<>''

--**************************************INICIA TRASPASO DE TABLA CB_COMPAC ********************************************************************
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(*) INTO iExiste FROM bdicobranza:cb_compac WHERE numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN

        FOREACH
            SELECT numcuenta INTO vc_Cuenta FROM bdicobranza:cb_compac WHERE numcliente=pClienteTraspasaCtas
            LET vc_proceso='COMPAC COBRANZA';
            LET vc_tabla = "cb_compac";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', '10/10/2010');

            INSERT INTO bdinteg:si_fuscompac
            SELECT * FROM bdicobranza:cb_compac WHERE numcuenta=vc_Cuenta AND numcliente=pClienteTraspasaCtas;

            UPDATE bdicobranza:cb_compac SET numcliente = pClienteTitular where numcuenta=vc_Cuenta AND numcliente=pClienteTraspasaCtas;
        END FOREACH;  

    END IF;
--**********************************************************************************************************
	
--**************************************INICIA TRASPASO DE TABLA CB_COMPAC_HIS ********************************************************************
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(*) INTO iExiste FROM bdicobranza:cb_compac_his WHERE numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN

        FOREACH
            SELECT numcuenta INTO vc_Cuenta FROM bdicobranza:cb_compac_his WHERE numcliente=pClienteTraspasaCtas
            LET vc_proceso='COMPAC COBRANZA HIS';
            LET vc_tabla = "cb_compac_his";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', '10/10/2010');

            INSERT INTO bdinteg:si_fuscompac_his 
            SELECT * FROM bdicobranza:cb_compac_his WHERE numcuenta=vc_Cuenta AND numcliente=pClienteTraspasaCtas;

            UPDATE bdicobranza:cb_compac_his SET numcliente = pClienteTitular where numcuenta=vc_Cuenta AND numcliente=pClienteTraspasaCtas;
        END FOREACH;  

    END IF;

--**********************************************************************************************************

--**************************************INICIA TRASPASO DE TABLA CB_CAT_DIRECTORIO_CTE ********************************************************************
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(*) INTO iExiste FROM bdicobranza:cb_cat_directorio_cte WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN

        FOREACH
            SELECT num_credito INTO vc_Cuenta FROM bdicobranza:cb_cat_directorio_cte WHERE numcte=pClienteTraspasaCtas
            LET vc_proceso='DIRECTORIO COBRANZA';
            LET vc_tabla = "cb_cat_directorio_cte";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', '10/10/2010');

            INSERT INTO bdinteg:si_fuscat_directorio_cte
            SELECT * FROM bdicobranza:cb_cat_directorio_cte WHERE num_credito=vc_Cuenta AND numcte=pClienteTraspasaCtas;

            UPDATE bdicobranza:cb_cat_directorio_cte SET numcte = pClienteTitular where num_credito=vc_Cuenta AND numcte=pClienteTraspasaCtas;
        END FOREACH;  

    END IF;
--**********************************************************************************************************


--**************************************INICIA TRASPASO DE TABLA CB_CAT_DIRECTORIO_CTE_HIST ********************************************************************
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(*) INTO iExiste FROM bdicobranza:cb_cat_directorio_cte_his WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN

        FOREACH
            SELECT num_credito INTO vc_Cuenta FROM bdicobranza:cb_cat_directorio_cte_his WHERE numcte=pClienteTraspasaCtas
            LET vc_proceso='DIRECTORIO COBRANZA HIS';
            LET vc_tabla = "cb_cat_directorio_cte_his";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', '10/10/2010');

            INSERT INTO bdinteg:si_fuscat_directorio_cte_his
            SELECT * FROM bdicobranza:cb_cat_directorio_cte_his WHERE num_credito=vc_Cuenta AND numcte=pClienteTraspasaCtas;

            UPDATE bdicobranza:cb_cat_directorio_cte_his SET numcte = pClienteTitular where num_credito=vc_Cuenta AND numcte=pClienteTraspasaCtas;
        END FOREACH;  

    END IF;
--**********************************************************************************************************
	
	
--**************************************INICIA TRASPASO DE TABLA CB_COMPAC_ERROR ********************************************************************
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} COUNT(*) INTO iExiste FROM bdicobranza:cb_compac_error WHERE numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN

        FOREACH
            SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} numcuenta INTO vc_Cuenta FROM bdicobranza:cb_compac_error WHERE numcliente=pClienteTraspasaCtas
            LET vc_proceso='COMPAC COBRANZA ERROR';
            LET vc_tabla = "cb_compac_error";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', '10/10/2010');

            INSERT INTO bdinteg:si_fuscompac_error
            SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)}* FROM bdicobranza:cb_compac_error WHERE numcuenta=vc_Cuenta AND numcliente=pClienteTraspasaCtas;

            UPDATE {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} bdicobranza:cb_compac_error SET numcliente = pClienteTitular where numcuenta=vc_Cuenta AND numcliente=pClienteTraspasaCtas;
        END FOREACH;  

    END IF;
--**********************************************************************************************************
	
END FOREACH;  

    IF vc_CodRet = "00000" THEN
        RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE;