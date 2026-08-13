CREATE PROCEDURE "informix".sp_updcte_ide() 
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
DEFINE vc_rfc           CHAR(13);
DEFINE vc_ref_ret       CHAR(20);
DEFINE vc_tipo_cta      CHAR(1);
DEFINE vc_sucursal      CHAR(4);
DEFINE vc_num_cta       CHAR(20);
DEFINE vd_fecha_mov     DATE;
DEFINE vm_imp_tot_dep   MONEY(10,2);
DEFINE vm_imp_ide       MONEY(10,2);
DEFINE vc_user_insert   CHAR(8);
DEFINE vd_fecha_insert  DATE;
DEFINE cAniomes     CHAR (4);
DEFINE vc_rfc_ori       CHAR(13);
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
LET vc_rfc = "";
LET vc_ref_ret = "";
LET vc_tipo_cta = "";
LET vc_sucursal = "";
LET vc_num_cta = "";
LET vd_fecha_mov = "";
LET vm_imp_tot_dep = 0;
LET vm_imp_ide = 0;
LET vc_user_insert = "";
LET vd_fecha_insert = "";
LET cAniomes="";
LET vc_rfc_ori = "";





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

    --SET DEBUG FILE TO "/informix/VH/decli/sp_updcte_ide.out";
    --TRACE ON;

        SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:si_fusclientes_ide idxtraside)} trim(cliente_tit),trim(cliente_tras) INTO pClienteTitular,pClienteTraspasaCtas FROM si_fusclientes_ide
        SET ISOLATION TO DIRTY READ;
        FOREACH

            SELECT NVL(aniomes,"") INTO vc_AnioMes FROM bdilide:sl_movefec WHERE aniomes >='201201' AND num_cte =pClienteTraspasaCtas
                SELECT rfc INTO vc_rfc FROM bdinteg:si_cliente WHERE numcte = pClienteTitular;
                SET ISOLATION TO DIRTY READ;
                FOREACH         
                    SELECT num_serial, rfc, ref_ret, tipo_cta, sucursal, num_cta, fecha_mov, imp_tot_dep, imp_ide, user_insert, fecha_insert
                    INTO   vi_num_serial, vc_rfc_ori, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert
                    FROM bdilide:sl_movefec
                    WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas

                    LET vc_tabla = "sl_movefec";
                    LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vd_fecha_mov||'|'||vm_imp_tot_dep;
                    LET vc_proceso='INFORMACION IDE';           

                    INSERT INTO bdinteg:si_fusmovefec
                    SELECT * FROM bdilide:sl_movefec WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas;

                    INSERT INTO bdilide:sl_movefec(aniomes, num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,imp_tot_dep,imp_ide,user_insert,fecha_insert)
                    VALUES (vc_AnioMes, pClienteTitular,vi_num_serial, vc_rfc, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert);

                    INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
                    VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);


                   DELETE FROM bdilide:sl_movefec WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas;

                END FOREACH;

        END FOREACH;  



    SET ISOLATION TO DIRTY READ;
    FOREACH
        SELECT {+INDEX (bdinteg:si_fusclientes_ide idxtraside)} trim(cliente_tit),trim(cliente_tras) INTO pClienteTitular,pClienteTraspasaCtas FROM si_fusclientes_ide

          SET ISOLATION TO DIRTY READ;
          SELECT rfc INTO vc_rfc FROM bdinteg:si_cliente WHERE numcte = pClienteTitular;

           INSERT INTO bdinteg:si_fusdetlide
           SELECT * FROM bdilide:sl_detlide WHERE aniomes>='201201' AND num_cte = pClienteTraspasaCtas;

           UPDATE bdilide:sl_detlide SET num_cte = pClienteTitular,rfc=vc_rfc
           WHERE aniomes>='201201' AND num_cte=pClienteTraspasaCtas;

           INSERT INTO bdinteg:si_fusretlide
           SELECT * FROM bdilide:sl_retlide WHERE aniomes>='201201' AND num_cte = pClienteTraspasaCtas;

           UPDATE bdilide:sl_retlide SET num_cte = pClienteTitular,rfc=vc_rfc
           WHERE aniomes>='201201' AND num_cte=pClienteTraspasaCtas;

    END FOREACH;  


END FOREACH;

END;
END PROCEDURE;