CREATE PROCEDURE "informix".sp_traspasocuentas(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE vd_FechaHoy      DATE;
DEFINE vc_AnioMes       CHAR(6);
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
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vc_Cuenta        CHAR(20);
DEFINE vc_Credito        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_num_tarjeta   CHAR(20);
DEFINE vc_rfc_ori       CHAR(13);
DEFINE vc_numsolic      CHAR(20);
DEFINE vc_statusolic    CHAR(2);
DEFINE vi_MaxSec        INTEGER;
DEFINE vi_SecTit        INTEGER;
DEFINE vc_NumCteDirec   CHAR(20);
DEFINE vi_SecDirec      INTEGER;
DEFINE vd_FechaSolic    DATE;
DEFINE vc_TipoDir       CHAR(1);
DEFINE vc_estado       CHAR(1);
DEFINE vtransaccion integer;

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET vd_FechaHoy = "";
LET vc_AnioMes = "";
LET vi_num_serial = 0;
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
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_detalle_mov2 = "";
LET vc_Cuenta = "";
LET vc_Credito = "";
LET vi_secuencia = 0;
LET vc_num_tarjeta = "";
LET vc_rfc_ori = "";
LET vc_numsolic = "";
LET vc_statusolic = "";
LET vi_MaxSec = 0;
LET vi_SecTit = 0;
LET vc_NumCteDirec = "";
LET vi_SecDirec = 0;
LET vd_FechaSolic = "";
LET vc_TipoDir = "";
LET vtransaccion = 0;

--*************DATOS DE ELABORACIÓN*************
--ELABORO: AYMME OSUNA PERAZA
--SOLICITO: ING. GERARDO VILLAR
--FECHA: 02-12-2008
--DESCRIPCION: PROCESO QUE SE ENCARGA DE EFECTUAR EL TRASPASO DE CUENTAS ENTRE CLIENTES BANCOPPEL.
--**********************************************

set isolation to dirty read;
set lock mode to wait 3;

    BEGIN WORK;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            ROLLBACK WORK;
            let vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;






--INICIALIZACION DE TABLAS
--    DELETE bdinteg:si_fusmaechq;
--    DELETE bdinteg:si_fustarjetadeb;
--    DELETE bdinteg:si_fusmaecred;
--   DELETE bdinteg:si_fusdirecciones;
--    DELETE bdinteg:si_fusmovefec;
--    DELETE bdinteg:si_fussolicitudes;
--    DELETE bdinteg:si_fustarjetacred;
--    DELETE bdinteg:si_fusmaeinv;
--    DELETE bdinteg:si_fusexpediente;
--    DELETE bdinteg:si_fuspagoprog;
--    DELETE bdinteg:si_fusdomautorizaciones;
--    DELETE bdinteg:si_fussq_envios;
--    DELETE bdinteg:si_fusencabezado_edocta;
--    DELETE bdinteg:si_fusseguimientocrd;
    --DELETE bdinteg:si_fusmaecredrevcrd;
--    DELETE bdinteg:si_fusmaecredcrd;
--    DELETE bdinteg:si_fusmaecredcontcrd;
    --DELETE bdinteg:si_fusencabezado_edoctacrd;
DELETE {+AVOID_FULL (bdinteg:"informix".fusdirecciones)} bdinteg:fusdirecciones;


	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_traspasocuentas.out";
	--TRACE ON;

    IF pClienteTitular IS NULL OR pClienteTitular = "" OR pClienteTraspasaCtas IS NULL OR pClienteTraspasaCtas = "" THEN
        LET vc_CodRet = "99999";
        LET vc_Mensaje = "PARAMETROS INVALIDOS";
    END IF;
    --VERIFICAR SI UNO DE LOS CLIENTES ES PERSONA MORAL
    --IF EXISTS (SELECT {+INDEX (bdinteg:si_cliente ix_cliente)} numcte FROM bdinteg:si_cliente WHERE (numcte = pClienteTitular AND tpo_persona = "02") OR (numcte = pClienteTraspasaCtas AND tpo_persona = "02")) THEN
    IF EXISTS (SELECT numcte FROM bdinteg:si_cliente WHERE (numcte = pClienteTitular AND tpo_persona = "02") OR (numcte = pClienteTraspasaCtas AND tpo_persona = "02")) THEN
        LET vc_CodRet = "00100"; --Cliente persona moral no se puede realizar traspaso
        LET vc_Mensaje = "CLIENTE PERSONA MORAL NO SE PUEDE REALIZAR EL TRASPASO DE CUENTAS";
        COMMIT WORK;
        RETURN vc_CodRet, vc_Mensaje;
    END IF;

    --VERIFICAR SI EL CLIENTE QUE TRASPASA SUS CUENTAS TIENE ALGÚN ADEUDO DEL IDE
    --IF EXISTS (SELECT {+INDEX (bdilide:sl_retlide pk_slcte)} num_cte FROM bdilide:sl_retlide WHERE num_cte = pClienteTraspasaCtas AND pendiente = "S") THEN
    IF EXISTS (SELECT num_cte FROM bdilide:sl_retlide WHERE num_cte = pClienteTraspasaCtas AND pendiente = "S") THEN
        LET vc_CodRet = "00200"; --Cliente con adeudo en IDE no se puede realizar el traspaso de cuentas
        LET vc_Mensaje = "CLIENTE CON ADEUDO EN IDE, IMPOSIBLE REALIZAR TRASPASO DE CUENTAS";
        COMMIT WORK;
        RETURN vc_CodRet,vc_Mensaje;
    END IF;
    --VERIFICAR SI EL CLIENTE QUE TRASPASA SUS CUENTAS TIENE BANCA POR INTERNET
    --IF EXISTS (SELECT {+INDEX (bdinteg:si_bpiusuarios idx_bpi)} numcte FROM bdinteg:si_bpiusuarios WHERE numcte in(pClienteTitular,pClienteTraspasaCtas) and empresa='001') THEN
    IF EXISTS (SELECT numcte FROM bdinteg:si_bpiusuarios WHERE numcte in(pClienteTitular,pClienteTraspasaCtas) and empresa='001') THEN
    --IF EXISTS (SELECT numcte FROM bdinteg:si_bpiusuarios WHERE numcte = pClienteTitular OR numcte = pClienteTraspasaCtas) THEN
        LET vc_CodRet = "00300"; --Cliente con banca por Internet
        LET vc_Mensaje = "CLIENTE CON BANCA POR INTERNET, IMPOSIBLE REALIZAR TRASPASO DE CUENTAS";
        COMMIT WORK;
        RETURN vc_CodRet,vc_Mensaje;
    END IF;

    --IF EXISTS (SELECT {+INDEX (bdinteg:si_cliente ix_cliente)} numcte FROM bdinteg:si_cliente WHERE (numcte = pClienteTitular AND status_cte="FU") OR (numcte = pClienteTraspasaCtas AND status_cte="FU") and empresa='001') THEN
    IF EXISTS (SELECT numcte FROM bdinteg:si_cliente WHERE (numcte = pClienteTitular AND status_cte="FU") OR (numcte = pClienteTraspasaCtas AND status_cte="FU")) THEN
        LET vc_CodRet = "00400"; --Cliente fusionado
        LET vc_Mensaje = "CLIENTE FUSIONADO NO SE PUEDE REALIZAR EL TRASPASO DE CUENTAS";
        COMMIT WORK;
        RETURN vc_CodRet, vc_Mensaje;
    END IF;

    --OBTENER LA FECHA DEL DIA
    SELECT {+AVOID_FULL (bdinteg:"informix".si_fechas)} fecha_hoy INTO vd_FechaHoy FROM bdinteg:si_fechas;
    LET vc_AnioMes = SUBSTRING(vd_FechaHoy from 7 for 10) || SUBSTRING(vd_FechaHoy  from 1 for 2);

   
    --******************INICIA TRASPASO DE CUENTAS DE CHEQUES***********************************
    --******************************************************************************************
    --IF EXISTS (SELECT {+INDEX (bdicheq:sc_maechq mae1)} num_cte FROM bdicheq:sc_maechq WHERE num_cte = pClienteTraspasaCtas and empresa='001') THEN
    IF EXISTS (SELECT num_cte FROM bdicheq:sc_maechq WHERE num_cte = pClienteTraspasaCtas) THEN
        --Inserta en el log
        
        SET ISOLATION TO DIRTY READ;
        FOREACH
            --SELECT {+INDEX (bdicheq:sc_maechq mae1)} cuenta INTO vc_Cuenta FROM bdicheq:sc_maechq WHERE num_cte = pClienteTraspasaCtas and empresa='001'
            SELECT cuenta INTO vc_Cuenta FROM bdicheq:sc_maechq WHERE num_cte = pClienteTraspasaCtas
            LET vc_tabla = "bdicheq:sc_maechq";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fusmaechq 
            --SELECT {+INDEX (bdicheq:sc_maechq mae1)} * FROM bdicheq:sc_maechq WHERE cuenta = vc_Cuenta and empresa='001';     
            SELECT * FROM bdicheq:sc_maechq WHERE cuenta = vc_Cuenta;     
        END FOREACH;  
         
        let vc_proceso="bitacora";
        let vc_tabla="sc_maechq";

        UPDATE bdicheq:sc_maechq SET num_cte = pClienteTitular WHERE num_cte = pClienteTraspasaCtas; 
         
    END IF;

    UPDATE bdicheq:sc_beneficiario SET numcte = pClienteTitular WHERE numcte = pClienteTraspasaCtas;

    IF EXISTS (SELECT {+INDEX (bdicheq:sc_tarjeta ix_tarjeta3)} numcte FROM bdicheq:sc_tarjeta WHERE numcte = pClienteTraspasaCtas) THEN
        
        SET ISOLATION TO DIRTY READ;
        FOREACH            
            SELECT {+INDEX (bdicheq:sc_tarjeta ix_tarjeta3)} cuenta, secuencia, num_tarjeta INTO vc_Cuenta, vi_secuencia, vc_num_tarjeta
            FROM bdicheq:sc_tarjeta
            WHERE numcte = pClienteTraspasaCtas

            LET vc_tabla = "bdicheq:sc_tarjeta";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia||'|'||TRIM(vc_num_tarjeta);

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fustarjetadeb
            SELECT {+INDEX (bdicheq:sc_tarjeta ix_tarjeta2)} * FROM bdicheq:sc_tarjeta WHERE num_tarjeta = vc_num_tarjeta AND empresa='001';

            let vc_proceso="bitacora";
            let vc_tabla="sc_tarjeta";


            UPDATE bdicheq:sc_tarjeta SET numcte = pClienteTitular WHERE num_tarjeta = vc_num_tarjeta AND empresa='001';
        END FOREACH;                    
        
    END IF;
    --*********************************************************************************************
        --                  INICIA EL TRASPASO DE INVERSIONES
    --*********************************************************************************************
    --IF EXISTS (SELECT {+INDEX (bdinvers:sv_maeinv mai3)} num_cte FROM bdinvers:sv_maeinv WHERE num_cte = pClienteTraspasaCtas and empresa='001') THEN
    IF EXISTS (SELECT num_cte FROM bdinvers:sv_maeinv WHERE num_cte = pClienteTraspasaCtas) THEN
        
        SET ISOLATION TO DIRTY READ;
        FOREACH            
            SELECT cuenta, secuencia INTO vc_Cuenta, vi_secuencia FROM bdinvers:sv_maeinv WHERE num_cte = pClienteTraspasaCtas
            LET vc_tabla = "bdinvers:sv_maeinv";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia;

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fusmaeinv
            SELECT * FROM bdinvers:sv_maeinv WHERE cuenta = vc_Cuenta AND secuencia = vi_secuencia AND empresa = '001';

            let vc_proceso="bitacora";
            let vc_tabla="sv_maeinv";

            UPDATE bdinvers:sv_maeinv SET num_cte = pClienteTitular WHERE cuenta = vc_Cuenta AND secuencia = vi_secuencia AND empresa = '001';
        END FOREACH;        
    END IF;
    --*********************************************************************************************
        --                  INICIA EL TRASPASO DE HUELLA
    --*********************************************************************************************
    IF NOT EXISTS (SELECT numcte FROM bdinteg:si_cte_huella WHERE numcte = pClienteTitular) THEN
        
        SET ISOLATION TO DIRTY READ;
        FOREACH            
            SELECT numcte, secuencia, estado INTO vc_Cuenta, vi_secuencia, vc_estado FROM bdinteg:si_cte_huella WHERE numcte = pClienteTraspasaCtas
            
            LET vc_tabla = "bdinteg:si_cte_huella";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia||'|'||vc_estado;

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fushuellacte
            SELECT * FROM bdinteg:si_cte_huella WHERE numcte = pClienteTraspasaCtas AND secuencia = vi_secuencia;

            let vc_proceso="bitacora";
            let vc_tabla="si_cte_huella";


            UPDATE bdinteg:si_cte_huella SET numcte = pClienteTitular WHERE numcte = pClienteTraspasaCtas AND secuencia = vi_secuencia;
        END FOREACH;        
    END IF;
    --***************************************************************************************************
                            --INICIA EL TRASPASO DE INFORMACION IDE
    --***************************************************************************************************
    IF EXISTS (SELECT num_cte FROM bdilide:sl_movefec WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas) THEN
        
        SELECT rfc INTO vc_rfc FROM bdinteg:si_cliente WHERE numcte = pClienteTitular;
        SET ISOLATION TO DIRTY READ;
        FOREACH         
            SELECT num_serial, rfc, ref_ret, tipo_cta, sucursal, num_cta, fecha_mov, imp_tot_dep, imp_ide, user_insert, fecha_insert
            INTO   vi_num_serial, vc_rfc_ori, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert
            FROM bdilide:sl_movefec
            WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas
         
            INSERT INTO bdinteg:si_fusmovefec
            SELECT * FROM bdilide:sl_movefec WHERE num_serial = vi_num_serial AND aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas;
         
            INSERT INTO bdilide:sl_movefec(aniomes, num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,imp_tot_dep,imp_ide,user_insert,fecha_insert)
            VALUES (vc_AnioMes, pClienteTitular,vi_num_serial, vc_rfc, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert);
            
            LET vc_tabla = "bdilide:sl_movefec";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vd_fecha_mov||'|'||vm_imp_tot_dep;
          
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
          
        END FOREACH;
        DELETE FROM bdilide:sl_movefec WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas;
    END IF;
    --*********************************************************************************************************
                                        --INICIA TRASPASO DE SOLICITUDES
    --*********************************************************************************************************
    IF EXISTS (SELECT {+INDEX (bdisolic:ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:ss_solicitudes WHERE numcte = pClienteTraspasaCtas AND (status_solicitud = "AT" OR status_solicitud = "AP") and empresa='001') THEN
        
        SET ISOLATION TO DIRTY READ;
        FOREACH           
            SELECT {+INDEX (bdisolic:ss_solicitudes idx_numctesolic)} num_solicitud, status_solicitud, fecha_insert INTO vc_numsolic, vc_statusolic, vd_FechaSolic
            FROM bdisolic:ss_solicitudes
            WHERE numcte = pClienteTraspasaCtas and empresa='001'

            IF vc_statusolic = "AT" OR vc_statusolic = "AP" THEN
                 INSERT INTO bdinteg:si_fussolicitudes
                 SELECT {+INDEX (bdisolic:ss_solicitudes empsol)} * FROM bdisolic:ss_solicitudes WHERE num_solicitud = vc_numsolic AND empresa = '001';

                 LET vc_tabla = "bdisolic:ss_solicitudes";
                 LET vc_detalle_mov = TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_numsolic)||'|'||TRIM(vc_statusolic)||'|'||vd_FechaSolic;

                 INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
                 VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);         

                let vc_proceso="bitacora";
                let vc_tabla="ss_solicitudes";

                UPDATE bdisolic:ss_solicitudes SET numcte = pClienteTitular WHERE num_solicitud = vc_numsolic AND empresa = '001';

                let vc_proceso="bitacora";
                let vc_tabla="ss_refpersonales|numcte";

                UPDATE {+INDEX(bdisolic:ss_refpersonales idx_ss_refpersonales)} bdisolic:ss_refpersonales SET numcte = pClienteTitular WHERE num_solicitud = vc_numsolic AND empresa = '001';

                let vc_proceso="bitacora";
                let vc_tabla="ss_refpersonales|numcte_ref";

                UPDATE {+INDEX(bdisolic:ss_refpersonales idx_ss_refpersonales)} bdisolic:ss_refpersonales SET numcte_ref = pClienteTitular WHERE num_solicitud = vc_numsolic AND numcte_ref = pClienteTraspasaCtas AND empresa = '001';
            END IF;
        END FOREACH;        
    END IF;
    --**********************************************************************************************************
                                -- INICIA TRASPASO DE PAGOS PROGRAMADOS
    --**********************************************************************************************************
    IF EXISTS (SELECT {+INDEX (bdiprog:pp_pagoprog idxpp_num_cte)} num_cte FROM bdiprog:pp_pagoprog WHERE num_cte = pClienteTraspasaCtas) THEN
        
        SET ISOLATION TO DIRTY READ;
        FOREACH            
            SELECT {+INDEX (bdiprog:pp_pagoprog idxpp_num_cte)} cuenta_origen, cve_pagoprog INTO vc_Cuenta, vi_secuencia FROM bdiprog:pp_pagoprog WHERE num_cte = pClienteTraspasaCtas

            LET vc_tabla = "bdiprog:pp_pagoprog";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia;

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fuspagoprog
            SELECT {+INDEX (bdiprog:pp_pagoprog 107_12)} * FROM bdiprog:pp_pagoprog WHERE cve_pagoprog = vi_secuencia and cuenta_origen = vc_Cuenta;

            let vc_proceso="bitacora";
            let vc_tabla="pp_pagoprog";

            UPDATE {+AVOID_FULL (bdiprog:"informix".pp_pagoprog)} bdiprog:pp_pagoprog SET num_cte = pClienteTitular WHERE cuenta_origen = vc_Cuenta AND cve_pagoprog = vi_secuencia;
        END FOREACH;        
    END IF;
    --**********************************************************************************************************
                                -- INICIA TRASPASO DE DOMICILIACIONES
    --**********************************************************************************************************
    IF EXISTS (SELECT {+INDEX (bdidomi:dom_autorizaciones dom_auto_2)} num_cte FROM bdidomi:dom_autorizaciones WHERE num_cte = pClienteTraspasaCtas) THEN
        
        SET ISOLATION TO DIRTY READ;
        FOREACH            
            SELECT {+INDEX (bdidomi:dom_autorizaciones dom_auto_2)} cuenta INTO vc_Cuenta FROM bdidomi:dom_autorizaciones WHERE num_cte = pClienteTraspasaCtas

            LET vc_tabla = "bdidomi:dom_autorizaciones";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas); 

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fusdomautorizaciones
            SELECT {+INDEX (bdidomi:dom_autorizaciones dom_auto_2)} * FROM bdidomi:dom_autorizaciones WHERE cuenta= vc_Cuenta;

            let vc_proceso="bitacora";
            let vc_tabla="dom_autorizaciones";

            UPDATE bdidomi:dom_autorizaciones SET num_cte = pClienteTitular WHERE num_cte = pClienteTraspasaCtas;
        END FOREACH;        
    END IF;
    --**********************************************************************************************************
                                -- INICIA TRASPASO DE CHEQUERAS
    --**********************************************************************************************************
    IF EXISTS (SELECT numcte FROM bdicntchq:sq_envios WHERE numcte = pClienteTraspasaCtas) THEN
        
        SET ISOLATION TO DIRTY READ;
        FOREACH            
            SELECT num_cuenta INTO vc_Cuenta FROM bdicntchq:sq_envios WHERE numcte = pClienteTraspasaCtas

            LET vc_tabla = "bdicntchq:sq_envios";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas); 

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fussq_envios
            SELECT * FROM bdicntchq:sq_envios WHERE num_cuenta= vc_Cuenta;
 
            let vc_proceso="bitacora";
            let vc_tabla="sq_envios";

            UPDATE bdicntchq:sq_envios SET numcte = pClienteTitular WHERE numcte = pClienteTraspasaCtas;
        END FOREACH;        
    END IF;
    --********************************************************************************************
                            --INICIA EL TRASPASO DE CUENTAS DE CREDITO
    --********************************************************************************************

--    IF EXISTS (SELECT {+INDEX (bdicred:sd_maecred idx_11a)} numcte FROM bdicred:sd_maecred WHERE numcte = pClienteTraspasaCtas) THEN
    IF EXISTS (SELECT numcte FROM bdicred:sd_maecred WHERE numcte = pClienteTraspasaCtas and empresa='001') THEN
        
        SET ISOLATION TO DIRTY READ;
FOREACH 
                     
            SELECT num_credito INTO vc_Credito FROM bdicred:sd_maecred WHERE numcte = pClienteTraspasaCtas and empresa='001'

            LET vc_tabla = "bdicred:sd_maecred";
            LET vc_detalle_mov = TRIM(vc_Credito)||'|'||TRIM(pClienteTraspasaCtas);

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas,vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fusmaecred
            SELECT * FROM bdicred:sd_maecred WHERE num_credito = vc_Credito and empresa='001';

            UPDATE bdicred:sd_maecred SET numcte = pClienteTitular WHERE num_credito = vc_Credito and empresa='001';

     IF EXISTS (SELECT numcte FROM bdicred:sd_tarjeta WHERE numcte=pClienteTraspasaCtas) THEN
        

     FOREACH 
           SELECT {+INDEX (bdicred:sd_tarjeta idx_sd_tarjeta1)} num_credito, secuencia, num_tarjeta INTO vc_Cuenta, vi_secuencia, vc_num_tarjeta
           FROM bdicred:sd_tarjeta WHERE numcte=pClienteTraspasaCtas            

           LET vc_tabla = "bdicred:sd_tarjeta";
           LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia||'|'||TRIM(vc_num_tarjeta);
       
           INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
           VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

           INSERT INTO bdinteg:si_fustarjetacred
           SELECT * FROM bdicred:sd_tarjeta where num_tarjeta = vc_num_tarjeta and empresa='001';

            let vc_proceso="bitacora";
            let vc_tabla="sd_tarjeta";

           UPDATE bdicred:sd_tarjeta SET numcte = pClienteTitular WHERE num_tarjeta = vc_num_tarjeta AND empresa = '001'; 

            let vc_proceso="bitacora";
            let vc_tabla="intercard:tarjeta";

           UPDATE intercard:tarjeta SET numcliente= pClienteTitular WHERE numtarjeta = vc_num_tarjeta; 
     END FOREACH;
     END IF;

     IF EXISTS (SELECT {+AVOID_FULL (intercard:"informix".solicitudtarjeta)} numcliente FROM intercard:solicitudtarjeta WHERE numcliente=pClienteTraspasaCtas) THEN
		FOREACH 
			SELECT 
			{+AVOID_FULL (intercard:"informix".solicitudtarjeta)}
			idsolicitud, numcuenta
			INTO vi_secuencia, vc_Cuenta
			FROM intercard:solicitudtarjeta 
			WHERE numcliente=pClienteTraspasaCtas
			
			LET vc_tabla = "intercard:solicitudtarjeta";
			LET vc_detalle_mov = vi_secuencia||'|'||TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);

			INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
			VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
			
			UPDATE intercard:solicitudtarjeta SET numcliente = pClienteTitular 
			WHERE idsolicitud = vi_secuencia
			AND numcliente = pClienteTraspasaCtas
			AND numcuenta = vc_Cuenta; 
		
		END FOREACH;
     END IF;

    --**********************************************************************************************************
                                -- INICIA TRASPASO DE CREDITO
    --**********************************************************************************************************
    IF EXISTS (SELECT num_credito FROM bdicred:sd_encabezado_edocta WHERE num_tarjeta = vc_num_tarjeta) THEN   

        LET vc_tabla = "bdicred:sd_encabezado_edocta";
        LET vc_detalle_mov = TRIM(vc_num_tarjeta)||'|'||TRIM(pClienteTraspasaCtas); 

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fusencabezado_edocta
            SELECT * FROM bdicred:sd_encabezado_edocta WHERE num_tarjeta= vc_num_tarjeta;

            let vc_proceso="bitacora";
            let vc_tabla="sd_encabezado_edocta";


            UPDATE bdicred:sd_encabezado_edocta SET numcte = pClienteTitular WHERE num_tarjeta= vc_num_tarjeta;

    END IF;
    --**********************************************************************************************************
                                -- INICIA TRASPASO DE REESTRUCTURA
    --**********************************************************************************************************
    IF EXISTS (SELECT num_credito FROM bdicred:sd_seguimientocrd WHERE num_credito = vc_Credito and empresa='001') THEN
        LET vc_tabla = "bdicred:sd_seguimientocrd";
        LET vc_detalle_mov = TRIM(vc_Credito)||'|'||TRIM(pClienteTraspasaCtas); 

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fusseguimientocrd
            SELECT * FROM bdicred:sd_seguimientocrd WHERE num_credito= vc_Credito and empresa='001';

            let vc_proceso="bitacora";
            let vc_tabla="sd_seguimientocrd";

            UPDATE bdicred:sd_seguimientocrd SET numcte = pClienteTitular WHERE num_credito= vc_Credito and empresa='001';

    END IF;
     --**********************************************************************************************************
    IF EXISTS (SELECT num_credito FROM bdicred:sd_maecredrevcrd WHERE num_credito = vc_Credito) THEN
        LET vc_tabla = "bdicred:sd_maecredrevcrd";
        LET vc_detalle_mov = TRIM(vc_Credito)||'|'||TRIM(pClienteTraspasaCtas); 

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fusmaecredrevcrd
            SELECT * FROM bdicred:sd_maecredrevcrd WHERE num_credito= vc_Credito;

            let vc_proceso="bitacora";
            let vc_tabla="sd_maecredrevcrd";

            UPDATE {+AVOID_FULL (bdicred:"informix".sd_maecredrevcrd)} bdicred:sd_maecredrevcrd SET numcte = pClienteTitular WHERE num_credito= vc_Credito;
            
    END IF;
     --**********************************************************************************************************
    IF EXISTS (SELECT num_credito FROM bdicred:sd_maecredcrd WHERE num_credito = vc_Credito and empresa='001') THEN
        LET vc_tabla = "bdicred:sd_maecredcrd";
        LET vc_detalle_mov = TRIM(vc_Credito)||'|'||TRIM(pClienteTraspasaCtas); 

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fusmaecredcrd
            SELECT * FROM bdicred:sd_maecredcrd WHERE num_credito = vc_Credito and empresa='001';

            let vc_proceso="bitacora";
            let vc_tabla="sd_maecredcrd";

            UPDATE bdicred:sd_maecredcrd SET numcte = pClienteTitular WHERE num_credito = vc_Credito and empresa='001';

    END IF;
     --**********************************************************************************************************
    IF EXISTS (SELECT num_credito FROM bdicred:sd_maecredcontcrd WHERE num_credito = vc_Credito and empresa='001') THEN
        LET vc_tabla = "bdicred:sd_maecredcontcrd";
        LET vc_detalle_mov = TRIM(vc_Credito)||'|'||TRIM(pClienteTraspasaCtas); 

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            INSERT INTO bdinteg:si_fusmaecredcontcrd
            SELECT {+AVOID_FULL (bdicred:"informix".sd_maecredcontcrd)} * FROM bdicred:sd_maecredcontcrd WHERE num_credito = vc_Credito and empresa='001';

            let vc_proceso="bitacora";
            let vc_tabla="sd_maecredcontcrd";

            UPDATE {+AVOID_FULL (bdicred:"informix".sd_maecredcontcrd)} bdicred:sd_maecredcontcrd SET numcte = pClienteTitular WHERE num_credito = vc_Credito and empresa='001';

    END IF;
     --**********************************************************************************************************
--    IF EXISTS (SELECT numcte FROM bdicred:sd_encabezado_edoctacrd WHERE numcte = pClienteTraspasaCtas) THEN
--        LET vc_tabla = "bdicred:sd_encabezado_edoctacrd";
--        SET ISOLATION TO DIRTY READ;
--        FOREACH            
--            SELECT num_credito INTO vc_Cuenta FROM bdicred:sd_encabezado_edoctacrd WHERE numcte = pClienteTraspasaCtas
--
--            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas); 
--
--            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
--            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
--
--            INSERT INTO bdinteg:si_fusencabezado_edoctacrd
--            SELECT * FROM bdicred:sd_encabezado_edoctacrd WHERE num_credito= vc_Cuenta;
--
--            UPDATE bdicred:sd_encabezado_edoctacrd SET numcte = pClienteTitular WHERE numcte = pClienteTraspasaCtas;
--        END FOREACH;        
--    END IF;
END FOREACH;        
END IF;
    --**********************************************************************************************************
                                -- INICIA TRASPASO DE DOMICILIOS
    --**********************************************************************************************************
    IF EXISTS (SELECT numcte FROM bdinteg:si_direcciones WHERE numcte = pClienteTraspasaCtas) THEN
        SELECT nvl(MAX(secuencia),0) INTO vi_MaxSec FROM bdinteg:si_direcciones WHERE numcte = pClienteTraspasaCtas;
    END IF;
    IF vi_MaxSec <> 0 THEN
        SET ISOLATION TO DIRTY READ;
        INSERT INTO fusdirecciones
        SELECT numcte as numcte, (secuencia + vi_MaxSec) as secuencia, tipo_dir as tipo_dir, calle as calle, colonia as colonia, entre_calles as entre_calles, pais as pais, estado as estado, ciudad as ciudad, municipio as municipio, cod_postal as cod_postal, apart_postal as apart_postal,  tipo_telef1 as tipo_telef1, telefono1 as telefono1,
               tipo_telef2 as tipo_telef2, telefono2 as telefono2, tipo_telef3 as tipo_telef3, telefono3 as telefono3, extension as extension, estado_inegi as estado_inegi, municipio_inegi as municipio_inegi, localidad_inegi as localidad_inegi, numerociudad as numerociudad, numeroextcalle as numeroextcalle,
               numerointcalle as numerointcalle, departamento as departamento, numerocalle as numerocalle, numerocolonia as numerocolonia, puntocardinal as puntocardinal, unidadhabitac as unidadhabitac, manzana as manzana, otros as otros, andador as andador, etapa as etapa, lote as lote, edificio as edificio, 
               entrada as entrada, observaciones as observaciones, user_insert as user_insert, fecha_insert as fecha_insert, ind_cofeteltel1 as ind_cofeteltel1, ind_cofeteltel2 as ind_cofeteltel2, ind_cofeteltel3 as ind_cofeteltel3
        FROM bdinteg:si_direcciones
        WHERE numcte = pClienteTitular;

        INSERT INTO fusdirecciones
        SELECT pClienteTitular as numcte, secuencia as secuencia, tipo_dir as tipo_dir, calle as calle, colonia as colonia, entre_calles as entre_calles, pais as pais, estado as estado, ciudad as ciudad, municipio as municipio, cod_postal as cod_postal, apart_postal as apart_postal,  tipo_telef1 as tipo_telef1, telefono1 as telefono1,
               tipo_telef2 as tipo_telef2, telefono2 as telefono2, tipo_telef3 as tipo_telef3, telefono3 as telefono3, extension as extension, estado_inegi as estado_inegi, municipio_inegi as municipio_inegi, localidad_inegi as localidad_inegi, numerociudad as numerociudad, numeroextcalle as numeroextcalle,
               numerointcalle as numerointcalle, departamento as departamento, numerocalle as numerocalle, numerocolonia as numerocolonia, puntocardinal as puntocardinal, unidadhabitac as unidadhabitac, manzana as manzana, otros as otros, andador as andador, etapa as etapa, lote as lote, edificio as edificio,
               entrada as entrada, observaciones as observaciones, user_insert as user_insert, fecha_insert as fecha_insert, ind_cofeteltel1 as ind_cofeteltel1, ind_cofeteltel2 as ind_cofeteltel2, ind_cofeteltel3 as ind_cofeteltel3    
        FROM bdinteg:si_direcciones
        WHERE numcte = pClienteTraspasaCtas; 

        INSERT INTO bdinteg:si_fusdirecciones
        SELECT numcte as numcte, secuencia as secuencia, tipo_dir as tipo_dir, calle as calle, colonia as colonia, entre_calles as entre_calles, pais as pais, estado as estado, ciudad as ciudad, municipio as municipio, cod_postal as cod_postal, apart_postal as apart_postal,  tipo_telef1 as tipo_telef1, telefono1 as telefono1,
               tipo_telef2 as tipo_telef2, telefono2 as telefono2, tipo_telef3 as tipo_telef3, telefono3 as telefono3, extension as extension, estado_inegi as estado_inegi, municipio_inegi as municipio_inegi, localidad_inegi as localidad_inegi, numerociudad as numerociudad, numeroextcalle as numeroextcalle,
               numerointcalle as numerointcalle, departamento as departamento, numerocalle as numerocalle, numerocolonia as numerocolonia, puntocardinal as puntocardinal, unidadhabitac as unidadhabitac, manzana as manzana, otros as otros, andador as andador, etapa as etapa, lote as lote, edificio as edificio,
               entrada as entrada, observaciones as observaciones, user_insert as user_insert, fecha_insert as fecha_insert, ind_cofeteltel1 as ind_cofeteltel1, ind_cofeteltel2 as ind_cofeteltel2, ind_cofeteltel3 as ind_cofeteltel3    
        FROM bdinteg:si_direcciones
        WHERE numcte = pClienteTraspasaCtas; 

       DELETE FROM bdinteg:si_direcciones WHERE numcte = pClienteTitular;

        INSERT INTO bdinteg:si_direcciones
        SELECT numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,  tipo_telef1, telefono1,
               tipo_telef2, telefono2, tipo_telef3, telefono3, extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle,
               numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio,
               entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1 as ind_cofeteltel1, ind_cofeteltel2 as ind_cofeteltel2, ind_cofeteltel3 as ind_cofeteltel3    
        FROM fusdirecciones
        WHERE numcte = pClienteTitular;
        --DROP TABLE direcciones;
    END IF;
    LET vc_tabla = "bdinteg:si_direcciones";
    SET ISOLATION TO DIRTY READ;
    FOREACH
        SELECT numcte, secuencia, tipo_dir INTO vc_NumCteDirec, vi_SecDirec, vc_TipoDir FROM bdinteg:si_direcciones WHERE numcte = pClienteTraspasaCtas
        
        LET vc_detalle_mov = TRIM(vc_NumCteDirec)||'|'||vi_SecDirec||'|'||TRIM(vc_TipoDir);

        INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
        VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT); 

        DELETE FROM bdinteg:si_direcciones WHERE numcte = pClienteTraspasaCtas AND secuencia = vi_SecDirec AND tipo_dir = vc_TipoDir;
    END FOREACH;
    --*********************************************************************************************************************   
    IF vc_CodRet = "00000" THEN

        let vc_proceso="bitacora";
        let vc_tabla="si_cliente|status_cte";

        UPDATE bdinteg:si_cliente SET status_cte = "FU" WHERE numcte = pClienteTraspasaCtas and empresa='001';

        let vc_proceso="bitacora";
        let vc_tabla="si_cliente|tipo_cliente";

        UPDATE bdinteg:si_cliente SET tipo_cliente = "1" WHERE numcte = pClienteTitular and empresa='001';
        COMMIT WORK;
        RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE;