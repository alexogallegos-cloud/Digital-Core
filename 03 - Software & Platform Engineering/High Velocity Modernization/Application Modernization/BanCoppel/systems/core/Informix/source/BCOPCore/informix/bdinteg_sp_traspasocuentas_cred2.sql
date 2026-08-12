CREATE PROCEDURE "informix".sp_traspasocuentas_cred2(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
RETURNING CHAR(5), CHAR(80);

--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vi_MaxSec        INTEGER;
DEFINE iExiste      SMALLINT;

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_detalle_mov2 = "";
LET vi_MaxSec = 0;
LET iExiste=0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            LET vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
			
							
			 IF EXISTS(SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_si_refclienteTraspasaCtas')THEN
				DROP TABLE tmp_si_refclienteTraspasaCtas;
			END IF;
			
			 IF EXISTS(SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sirefdireccionesCliente')THEN
				DROP TABLE tmp_sirefdireccionesCliente;
			END IF;
			
            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/JesusBueno/sp_traspasocuentas_cred2.out";
--TRACE ON;

	 --**INICIA TRASPASO DE COBRANZA
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(num_credito) INTO iExiste FROM bdicobranza:cb_rep_cart_quebrantar WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN	
	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT 'CART_QUEBRANTAR',"cb_rep_cart_quebrantar",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_rep_cart_quebrantar  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fusrep_cart_quebrantar (num_credito,numcte,apellido1,apellido2,nombre1,nombre2,fechanac,rfc,curp,sexo,edocivil,apellidocasada,nacionalidad,actividad,tipoidentificacion,numidentificacion,email,numestado,numciudad,poblacion,numcolonia,numcalle,numexterior,numinterior,codpostal,puntocardinal,manzana,andador,etapa,lote,edificio,entrada,departamento,complemento,entrecalles,antigdomic,telefono,otros,situacionesp,causasitesp,sector,lugartrabajo,antigtrab,puesto,ingresomensual,numestadotrab,numciudadtrab,poblaciontrab,numcoloniatrab,numcalletrab,numexteriortrab,numinteriortrab,codpostaltrab,puntocardinaltrab,manzanatrab,andadortrab,etapatrab,lotetrab,edificiotrab,entradatrab,departamentotrab,complementotrab,entrecallestrab,otrostrab,teltrab,exttrab,sucursal,fecha_ult_disp,monto_ult_disp,monto_comi_ult_disp,abono_mensual_al_qub,int_capit,iva_int_capit,sdo_mes_ant,sdo_actual,sdo_vencido,sdo_no_exig,fecha_ult_mov,tipo_ult_mov,monto_ult_mov,int_vencido,iva_int_vencido,int_mora_ordi,iva_int_mora_ordi,int_mora_cope,iva_int_mora_cope,meses_vencidos,numero_tarjeta,referenciacoppel,fechareporte)
	    SELECT num_credito,numcte,apellido1,apellido2,nombre1,nombre2,fechanac,rfc,curp,sexo,edocivil,apellidocasada,nacionalidad,actividad,tipoidentificacion,numidentificacion,email,numestado,numciudad,poblacion,numcolonia,numcalle,numexterior,numinterior,codpostal,puntocardinal,manzana,andador,etapa,lote,edificio,entrada,departamento,complemento,entrecalles,antigdomic,telefono,otros,situacionesp,causasitesp,sector,lugartrabajo,antigtrab,puesto,ingresomensual,numestadotrab,numciudadtrab,poblaciontrab,numcoloniatrab,numcalletrab,numexteriortrab,numinteriortrab,codpostaltrab,puntocardinaltrab,manzanatrab,andadortrab,etapatrab,lotetrab,edificiotrab,entradatrab,departamentotrab,complementotrab,entrecallestrab,otrostrab,teltrab,exttrab,sucursal,fecha_ult_disp,monto_ult_disp,monto_comi_ult_disp,abono_mensual_al_qub,int_capit,iva_int_capit,sdo_mes_ant,sdo_actual,sdo_vencido,sdo_no_exig,fecha_ult_mov,tipo_ult_mov,monto_ult_mov,int_vencido,iva_int_vencido,int_mora_ordi,iva_int_mora_ordi,int_mora_cope,iva_int_mora_cope,meses_vencidos,numero_tarjeta,referenciacoppel,fechareporte
		FROM bdicobranza:"informix".cb_rep_cart_quebrantar WHERE numcte=pClienteTraspasaCtas;

        UPDATE bdicobranza:"informix".cb_rep_cart_quebrantar SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
    END IF;
    --**
	--***INICIA TRASPASO DE TABLA SS_SOLICITUDES_MC
    SET ISOLATION TO DIRTY READ; 
     SELECT {+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)} COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_mc WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
   
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)}  'SOLICITUDES_MC',"ss_solicitudes_mc",pClienteTitular,pClienteTraspasaCtas,TRIM(num_solicitud)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdisolic:"informix".ss_solicitudes_mc  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fussolicitudes_mc  (empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,tipo_movimiento,motivo_os,revalua,ostel,tipo_alta) 
        SELECT {+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)} empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,tipo_movimiento,motivo_os,revalua,ostel,tipo_alta
		FROM bdisolic:"informix".ss_solicitudes_mc WHERE numcte=pClienteTraspasaCtas;

        UPDATE{+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)} bdisolic:"informix".ss_solicitudes_mc SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
	
	END IF;
    
	--***INICIA TRASPASO DE TABLA SS_SOLICITUDES_SIC
    
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)}  COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_sic WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
			
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)}  'SOLICITUDES_SIC',"ss_solicitudes_sic",pClienteTitular,pClienteTraspasaCtas,TRIM(num_solicitud)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdisolic:"informix".ss_solicitudes_sic  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fussolicitudes_sic (empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic) 
		SELECT {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)} empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic
		FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)} bdisolic:"informix".ss_solicitudes_sic SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
 
    END IF;
    --***
    --***INICIA TRASPASO DE TABLA SS_SOLICITUDES_CAC
    SET ISOLATION TO DIRTY READ; 
       SELECT {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_cac WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
   	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  'SOLICITUDES_CAC',"ss_solicitudes_cac",pClienteTitular,pClienteTraspasaCtas,TRIM(num_solicitud)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdisolic:"informix".ss_solicitudes_cac  WHERE numcte= pClienteTraspasaCtas;
		
		INSERT INTO bdinteg:"informix".si_fussolicitudes_cac (empresa,num_solicitud,numcte,sucursal,num_producto,status,ejecutivo_atiende,ejecutivo_autoriza,comprobante_valido,observaciones,os,linea_determinada_sistema,fecha_insert,hora_insert,fecha_determinacion,ingreso_cac,compromisos_cac,comprobante_valido_cac,revisado)
		SELECT {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  empresa,num_solicitud,numcte,sucursal,num_producto,status,ejecutivo_atiende,ejecutivo_autoriza,comprobante_valido,observaciones,os,linea_determinada_sistema,fecha_insert,hora_insert,fecha_determinacion,ingreso_cac,compromisos_cac,comprobante_valido_cac,revisado
		FROM bdisolic:"informix".ss_solicitudes_cac WHERE numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  bdisolic:"informix".ss_solicitudes_cac SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;
    
	--***INICIA TRASPASO DE TABLA
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)} COUNT(num_credito) INTO iExiste FROM bdicred:sd_camp_inactiv_nuncas WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
			
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)}  'CAMPAÑAS INACTIVAS',"sd_camp_inactiv_nuncas",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM "informix".sd_camp_inactiv_nuncas  WHERE numcte= pClienteTraspasaCtas;
		
		INSERT INTO bdinteg:"informix".si_fuscamp_inactiv_nuncas (empresa,fecha_gen_campania,fecha_ejecucion,fecha_entreg_desde,fecha_entreg_hasta,tipo_campania,tipo_logica,num_sub_campania,grupo,num_credito,numcte,monto_otorgado,fecha_apertura,prioridad,status_cte,ap_paterno,ap_materno,primer_nombre,segundo_nombre,sexo,estado_civil,email,estado,ciudad,fecha_ultima_compra,fecha_ultimo_pago)
		SELECT {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)} empresa,fecha_gen_campania,fecha_ejecucion,fecha_entreg_desde,fecha_entreg_hasta,tipo_campania,tipo_logica,num_sub_campania,grupo,num_credito,numcte,monto_otorgado,fecha_apertura,prioridad,status_cte,ap_paterno,ap_materno,primer_nombre,segundo_nombre,sexo,estado_civil,email,estado,ciudad,fecha_ultima_compra,fecha_ultimo_pago
		FROM bdicred:"informix".sd_camp_inactiv_nuncas WHERE numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)}  bdicred:"informix".sd_camp_inactiv_nuncas SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;

	--***INICIA TRASPASO DE TABLA CB_COMPAC
    SET ISOLATION TO DIRTY READ; 
  SELECT {+INDEX (bdicobranza:cb_compac idx_compac2)}  COUNT(numcuenta) INTO iExiste FROM bdicobranza:cb_compac WHERE empresa ='001' AND  numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN
    
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdicobranza:cb_compac idx_compac2)}  'COMPAC COBRANZA',"cb_compac",pClienteTitular,pClienteTraspasaCtas,TRIM(numcuenta)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_compac  WHERE empresa ='001' AND  numcliente= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscompac (empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo )
		SELECT {+INDEX (bdicobranza:cb_compac idx_compac2)} empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo
		FROM bdicobranza:"informix".cb_compac WHERE empresa ='001' AND numcliente=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdicobranza:cb_compac idx_compac2)} bdicobranza:"informix".cb_compac SET numcliente = pClienteTitular where empresa ='001' AND  numcliente=pClienteTraspasaCtas;

    END IF;

	--***INICIA TRASPASO DE TABLA CB_COMPAC_HIS
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(numcuenta) INTO iExiste FROM bdicobranza:cb_compac_his WHERE numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN
	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT 'COMPAC COBRANZA HIS',"cb_compac_his",pClienteTitular,pClienteTraspasaCtas,TRIM(numcuenta)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_compac_his  WHERE numcliente= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscompac_his (empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,tipo_movto,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo)
		SELECT empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,tipo_movto,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo
		FROM bdicobranza:"informix".cb_compac_his WHERE  numcliente=pClienteTraspasaCtas;

        UPDATE bdicobranza:"informix".cb_compac_his SET numcliente = pClienteTitular where   numcliente=pClienteTraspasaCtas;

    END IF;
	
	--***INICIA TRASPASO DE TABLA CB_CAT_DIRECTORIO_CTE
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)}  COUNT(num_credito) INTO iExiste FROM bdicobranza:cb_cat_directorio_cte WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT  {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)}  'DIRECTORIO COBRANZA',"cb_cat_directorio_cte",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_cat_directorio_cte  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscat_directorio_cte (empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica,situacion,causa,pago_minimo,estado,ciudad,excepcion,saldo_total,apell_paterno,apell_materno,nombre1,nombre2,codigo_resultado,fecha_ultimo_contacto,intento_llamada,monto_vencido,moratorio,pagomin_total,fecha_ult_pago,pago_una_mora,num_pagos,monto_pagos,interes_iva,mto_venc_trasp)
        SELECT {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)} empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica,situacion,causa,pago_minimo,estado,ciudad,excepcion,saldo_total,apell_paterno,apell_materno,nombre1,nombre2,codigo_resultado,fecha_ultimo_contacto,intento_llamada,monto_vencido,moratorio,pagomin_total,fecha_ult_pago,pago_una_mora,num_pagos,monto_pagos,interes_iva,mto_venc_trasp
		FROM bdicobranza:"informix".cb_cat_directorio_cte WHERE numcte=pClienteTraspasaCtas;
		
        UPDATE {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)} bdicobranza:"informix".cb_cat_directorio_cte SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;
	--***
	--***INICIA TRASPASO DE TABLA CB_CAT_DIRECTORIO_CTE_HIST
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(num_credito) INTO iExiste FROM bdicobranza:cb_cat_directorio_cte_his WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT 'DIRECTORIO COBRANZA HIS',"cb_cat_directorio_cte_his",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_cat_directorio_cte_his  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscat_directorio_cte_his (empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica)
		SELECT empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica
		FROM bdicobranza:"informix".cb_cat_directorio_cte_his WHERE numcte=pClienteTraspasaCtas;
		
        UPDATE bdicobranza:"informix".cb_cat_directorio_cte_his SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;
	
	--***INICIA TRASPASO DE TABLA CB_COMPAC_ERROR
    SET ISOLATION TO DIRTY READ; 
   SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} COUNT(numcuenta) INTO iExiste FROM bdicobranza:cb_compac_error WHERE numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} 'COMPAC COBRANZA ERROR',"cb_compac_error",pClienteTitular,pClienteTraspasaCtas,TRIM(numcuenta)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_compac_error  WHERE  empresa ='001'  AND numcliente= pClienteTraspasaCtas;
		
		INSERT INTO bdinteg:"informix".si_fuscompac_error (empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,codigo_error,canal)
		SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,codigo_error,canal 
		FROM bdicobranza:"informix".cb_compac_error WHERE numcliente=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} bdicobranza:"informix".cb_compac_error SET numcliente = pClienteTitular where numcliente=pClienteTraspasaCtas;

    END IF;
	--***INICIA TRASPASO DE TABLA ADICOPPEL
    SET ISOLATION TO DIRTY READ; 
   SELECT {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel2)} COUNT(numcte) INTO iExiste FROM bdinteg:si_adiccoppel WHERE empresa ='001' AND numcte=pClienteTraspasaCtas;
	    IF iExiste>0 THEN

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		-- BD -- SELECT  {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel)}  'ADICIONAL COPPEL',"si_adiccoppel",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(tipotar),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_adiccoppel   WHERE empresa='001' AND numcte= pClienteTraspasaCtas;
		SELECT 'ADICIONAL COPPEL',"si_adiccoppel",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(tipotar),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_adiccoppel   WHERE empresa='001' AND numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fusadiccoppel(empresa,numctecoppel,secuencia,sucursal,numtarcoppel,numcte,tipotar,status,parentesco,fechamov,user_insert)
	    SELECT {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel2)} empresa,numctecoppel,secuencia,sucursal,numtarcoppel,numcte,tipotar,status,parentesco,fechamov,user_insert
		FROM bdinteg:"informix".si_adiccoppel WHERE empresa='001' AND numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel2)} bdinteg:"informix".si_adiccoppel SET numcte = pClienteTitular WHERE empresa ='001'  AND numcte=pClienteTraspasaCtas;
    
    END IF;
	
--***INICIA TRASPASO DE TABLA REFDIRECCIONES
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(numcte) INTO iExiste FROM bdinteg:si_refdirecciones WHERE numcte=pClienteTraspasaCtas;

	IF iExiste > 0  THEN
			
			SELECT MAX(secuencia)  INTO vi_MaxSec FROM bdinteg:"informix".si_refdirecciones WHERE numcte=pClienteTitular;
			
			IF vi_MaxSec >0  THEN 
				
				CREATE TEMP TABLE tmp_sirefdireccionesCliente 
				  (
					posicion_secuencia serial,
					numcte CHAR(20) NOT NULL ,
					secuencia INTEGER ,
					tipo_dir CHAR(1),
					calle CHAR(40),
					colonia CHAR(60),
					entre_calles CHAR(40),
					pais CHAR(3),
					estado CHAR(2),
					ciudad CHAR(3),
					municipio CHAR(5),
					cod_postal CHAR(5),
					apart_postal CHAR(11),
					tipo_telef1 CHAR(1),
					telefono1 CHAR(13),
					tipo_telef2 CHAR(1),
					telefono2 CHAR(13),
					tipo_telef3 CHAR(1),
					telefono3 CHAR(13),
					extension CHAR(5),
					estado_inegi CHAR(2),
					municipio_inegi CHAR(3),
					localidad_inegi CHAR(4),
					numerociudad SMALLINT,
					numeroextcalle CHAR(10),
					numerointcalle CHAR(10),
					departamento CHAR(6),
					numerocalle INTEGER,
					numerocolonia INTEGER,
					puntocardinal CHAR(1),
					unidadhabitac CHAR(1),
					manzana SMALLINT,
					otros SMALLINT,
					andador SMALLINT,
					etapa SMALLINT,
					lote SMALLINT,
					edificio SMALLINT,
					entrada SMALLINT,
					observaciones CHAR(80),
					numcte_banco CHAR(20),
					user_insert CHAR(8),
					fecha_insert DATE,
					ind_cofeteltel1 CHAR(1) 
						DEFAULT 'F',
					ind_cofeteltel2 CHAR(1) 
						DEFAULT 'F',
					ind_cofeteltel3 CHAR(1) 
						DEFAULT 'F',
					movil_fijo1 CHAR(1) 
						DEFAULT '0',
					status_stel1 CHAR(1) 
						DEFAULT '',
					movil_fijo2 CHAR(1) 
						DEFAULT '0',
					status_stel2 CHAR(1) 
						DEFAULT '',
					movil_fijo3 CHAR(1) 
						DEFAULT '0',
					status_stel3 CHAR(1) 
						DEFAULT ''
				  );
				
				
				INSERT INTO tmp_sirefdireccionesCliente(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana	,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert	,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
				SELECT numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana	,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert	,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM bdinteg:"informix".si_refdirecciones
				WHERE  numcte = pClienteTraspasaCtas;

				
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'REFERENCIAS DIRECCIONES',"si_refdirecciones",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(tipo_dir),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM tmp_sirefdireccionesCliente  WHERE numcte= pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_fusrefdirecciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
				SELECT numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM tmp_sirefdireccionesCliente
				WHERE numcte=pClienteTraspasaCtas;
				
				INSERT INTO bdinteg: si_refdirecciones (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
				SELECT pClienteTitular,vi_MaxSec+posicion_secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM tmp_sirefdireccionesCliente
				WHERE numcte=pClienteTraspasaCtas;
				
				DROP TABLE tmp_sirefdireccionesCliente;
				DELETE FROM bdinteg:"informix".si_refdirecciones WHERE numcte=pClienteTraspasaCtas;			
			
		ELSE 
			
				INSERT INTO bdinteg:"informix".si_fusrefdirecciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
									
				SELECT numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM  bdinteg:"informix".si_refdirecciones
				WHERE numcte=pClienteTraspasaCtas;

				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'REFERENCIAS DIRECCIONES',"si_refdirecciones",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas)||"|"||secuencia||"|"||TRIM(tipo_dir),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_refdirecciones  WHERE numcte= pClienteTraspasaCtas;
							
				UPDATE  bdinteg:"informix".si_refdirecciones SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
			END IF;	
 END IF;

--**********INICIA TRASPASO DE TABLA REFCLIENTES 
	
	SET ISOLATION TO DIRTY READ; 
	SELECT COUNT(numcte) INTO iExiste FROM bdinteg:si_refclientes WHERE numcte=pClienteTraspasaCtas;
		
	IF iExiste > 0 THEN 
						SELECT MAX(secuencia)  INTO vi_MaxSec FROM bdinteg:"informix".si_refclientes  WHERE numcte=pClienteTitular;
			IF vi_MaxSec> 0  THEN
				
				CREATE TEMP TABLE tmp_si_refclienteTraspasaCtas 
				  (	
					posicion_secuencia serial,
					empresa CHAR(3),
					num_solicitud CHAR(20) 
						DEFAULT '' NOT NULL ,
					numcte CHAR(20),
					sucursal CHAR(4),
					secuencia INTEGER ,
					apell_paterno CHAR(26),
					apell_materno CHAR(26),
					nombre1 CHAR(26),
					nombre2 CHAR(26),
					rfc CHAR(13),
					fecha_nac DATE,
					curp CHAR(20),
					sexo CHAR(1),
					estado_civil CHAR(2),
					nacionalidad CHAR(3),
					no_fm3 CHAR(18),
					codidentifi CHAR(2),
					numidentifi CHAR(30) 
						DEFAULT '',
					pers_domicilio CHAR(2),
					email CHAR(60),
					parentesco CHAR(2),
					apellido_cas CHAR(26),
					numcte_ref CHAR(20),
					numcte_banco CHAR(20),
					user_insert CHAR(8),
					fecha_insert DATE
				  );
				
				INSERT INTO tmp_si_refclienteTraspasaCtas (empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
				SELECT empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM bdinteg:"informix".si_refclientes
				WHERE  numcte = pClienteTraspasaCtas;
				

				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'REFERENCIAS CLIENTES',"si_refclientes",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(num_solicitud),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM tmp_si_refclienteTraspasaCtas  WHERE numcte= pClienteTraspasaCtas;
				
				
				INSERT INTO bdinteg:si_fusrefclientes(empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
				SELECT empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM tmp_si_refclienteTraspasaCtas
				WHERE numcte=pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_refclientes (empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
				
				SELECT empresa,num_solicitud,pClienteTitular,sucursal,vi_MaxSec+posicion_secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM tmp_si_refclienteTraspasaCtas
				WHERE numcte=pClienteTraspasaCtas;
				
				
				DROP TABLE tmp_si_refclienteTraspasaCtas;
				DELETE {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} FROM bdinteg:"informix".si_refclientes WHERE numcte=pClienteTraspasaCtas;
			
		ELSE 
			
				INSERT INTO bdinteg:si_fusrefclientes(empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
									
				SELECT empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM  bdinteg:si_refclientes
				WHERE numcte=pClienteTraspasaCtas;

				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'REFERENCIAS CLIENTES',"si_refclientes",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(num_solicitud),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:si_refclientes  WHERE numcte= pClienteTraspasaCtas;
				
				UPDATE {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} bdinteg:si_refclientes SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
		END IF;
	END IF;

	--******INICIA TRASPASO DE TABLA INGRESOS 
	SET ISOLATION TO DIRTY READ; 
	SELECT COUNT(numcte) INTO iExiste FROM bdinteg:si_ingresos WHERE numcte=pClienteTraspasaCtas;
	    IF iExiste>0 THEN
		SELECT COUNT(*) INTO iExiste FROM bdinteg:si_ingresos WHERE numcte=pClienteTitular;
			
			LET vc_tabla = "si_ingresos";
            LET vc_proceso='INGRESOS';
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'INGRESOS',"si_ingresos",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||sec_ingreso||"|"||TRIM(tipo_ingreso),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_ingresos   WHERE numcte= pClienteTraspasaCtas;
			
            INSERT INTO bdinteg:"informix".si_fusingresos (empresa,numcte,sec_ingreso,tipo_ingreso,nombre_empresa,puesto,puesto_esp,antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual,user_insert,fecha_insert,clavepuesto,claveopcionpuesto,clavesubopcionpuesto,sis_cotiza,num_emp_lab,periosidad,tipo_ingreso_ext)
			SELECT {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} empresa,numcte,sec_ingreso,tipo_ingreso,nombre_empresa,puesto,puesto_esp,antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual,user_insert,fecha_insert,clavepuesto,claveopcionpuesto,clavesubopcionpuesto,sis_cotiza,num_emp_lab,periosidad,tipo_ingreso_ext
			FROM bdinteg:"informix".si_ingresos WHERE numcte=pClienteTraspasaCtas;
				
			IF iExiste=0 THEN
					UPDATE {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} bdinteg:"informix".si_ingresos SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas ;
				ELSE
					DELETE {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} FROM bdinteg:"informix".si_ingresos WHERE numcte=pClienteTraspasaCtas;
			END IF;		
    END IF;	   
    IF vc_CodRet = "00000" THEN
		RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE
DOCUMENT
'Folio: 1447',
'Autor: 95347143 ',
'Fecha: 22/07/2014',
'Descripción: Optmizar sp sp_traspasocuentas_cred para reducir tiempos y costos de ejecución. Se secciono el sp, la segunda parte se llama',
'sp_traspasocuentas_cred2. Se eliminaron selec *, se eliminaron ciclos foreach (lo mas posible) y hacer uso de indices. ',
'Sustento: Analisis RQI64012 Optimizacion de proceso de fusion automatica.pdf',
'Solicita: Jose Angel Lopez Adams',
'BD: bdicred',
'----------------------------------------------',
'AUTOR: Rocio Karina Márquez Coronel',
'FECHA: 14/04/2015',
'DESCRIPCION: Se modificó estructuras de la fusión ya que se agregó un campo nuevo a la tabla cb_compac_his',
'SUSTENTO: RQI 64 081',
'SOLICITA: Jose Angel Lopez Adams',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_guardar_rostro_cte(pEmpresa CHAR(3), pSucursal CHAR(4), pNumCliente CHAR(20), pTemplate CHAR(9000), pOperador CHAR(8),pOpcion SMALLINT,pParte SMALLINT, pTemplate_procesado CHAR(1), pMac CHAR(17), pIp CHAR(15))
	RETURNING CHAR(5) AS CodigoRetorno;

-- *	DEFINICION DE VARIABLES		  
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(5);
	DEFINE iSecuencia			INTEGER;
	DEFINE dFechahoy			DATE; 
	DEFINE dTime 				DATETIME HOUR TO SECOND;
	DEFINE dFecha				CHAR(23);
	DEFINE cAux1                CHAR(10);
-- *	ASIGNACION DE VARIABLES
	LET	iSqlErr 		= 0;
	LET cCodRet 		= '00000';
	LET iSecuencia 		= 0;
	LET dFechahoy 		= '';
	LET dFecha	 		= '';
	LET dTime           = CURRENT HOUR TO SECOND;
	LET cAux1           ='';
-- *	CONTROL DE ERRORES
BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_guardar_rostro_cte.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	--VALIDAR PARÁMETROS VACÍOS O NULOS
	IF pOpcion <> 3 THEN
		IF NVL(TRIM(pEmpresa),'') = '' OR NVL(TRIM(pSucursal),'') = '' OR NVL(TRIM(pNumCliente),'') = '' 
			OR NVL(TRIM(pTemplate),'') = '' OR NVL(TRIM(pOperador),'') = '' OR pOpcion IS NULL OR pParte IS NULL THEN
			LET cCodRet = '00002';
		END IF;
	ELSE
		IF NVL(TRIM(pEmpresa),'') = '' OR NVL(TRIM(pSucursal),'') = '' OR NVL(TRIM(pNumCliente),'') = '' 
			OR NVL(TRIM(pOperador),'') = '' OR pOpcion IS NULL THEN
			LET cCodRet = '00002';
		END IF;
	END IF;
		SELECT fecha_hoy
		INTO dFechaHoy
		FROM bdinteg: "informix".si_fechas
		WHERE empresa = pEmpresa;
		
		IF dbinfo('sqlca.sqlerrd2') = 0 THEN 		
				LET cCodRet = '00003';				
		END IF;
		LET cAux1 = dFechaHoy ::CHAR(10);
		
		LET dFecha = SUBSTR(TRIM(cAux1), 7, 4)|| '-'|| SUBSTR(TRIM(cAux1), 1, 2) || '-'||SUBSTR(TRIM(cAux1), 4, 2) || ' '||dTime;	IF cCodRet = '00000' THEN
		
		SELECT MAX(secuencia)  
		INTO iSecuencia
		FROM bdinteg:"informix".si_cte_rostro 
		WHERE empresa = pEmpresa 
		AND numcte = LPAD(TRIM(pNumCliente),9,'0')
		AND estado = 'C'
		AND fecha_alta = dFechaHoy;
		
		IF NVL(iSecuencia,0) = 0 THEN
			LET iSecuencia = 1;
		END IF;
		
		IF pOpcion = 1 THEN
		
			
		
				
				IF NVL(pParte,0) = 1 THEN 
					INSERT INTO bdinteg:"informix".si_cte_rostro(empresa, sucursal, numcte,secuencia, estado, rmapa, rmapa2,rmapa3, usuario,template_procesado, mac, ip, fecha_alta, usuario_camb, fecha_camb, fech_ult_camb)
					VALUES(pEmpresa, pSucursal,LPAD(TRIM(pNumCliente),9,'0'), iSecuencia,'C', pTemplate, '','', pOperador, '','','',dFechaHoy, pOperador, dFechaHoy, dFecha);			
					LET cCodRet = '00000';
				ELIF NVL(pParte,0) = 2 THEN 
					UPDATE bdinteg:"informix".si_cte_rostro
					SET rmapa2 = pTemplate, usuario_camb = pOperador, fecha_camb = dFechaHoy, fech_ult_camb = dFecha
					WHERE empresa = pEmpresa 
					  AND numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND fecha_alta = dFechaHoy;
					LET cCodRet = '00000';
				ELIF NVL(pParte,0) = 3 THEN 
					UPDATE bdinteg:"informix".si_cte_rostro
					SET rmapa3 = pTemplate, usuario_camb = pOperador, fecha_camb = dFechaHoy, fech_ult_camb = dFecha
					WHERE empresa = pEmpresa 
					  AND numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND fecha_alta = dFechaHoy;
				
					LET cCodRet = '00000';
				ELIF NVL(pParte,0) = 4 THEN 
					LET iSecuencia = iSecuencia + 1;
					INSERT INTO bdinteg:"informix".si_cte_rostro(empresa, sucursal, numcte,secuencia, estado, rmapa, rmapa2,rmapa3, usuario,template_procesado, mac, ip, fecha_alta, usuario_camb, fecha_camb, fech_ult_camb)
					VALUES(pEmpresa, pSucursal,LPAD(TRIM(pNumCliente),9,'0'), iSecuencia,'C', pTemplate, '','', pOperador, '','','',dFechaHoy, pOperador, dFechaHoy, dFecha);			
					
					LET cCodRet = '00000';
				ELIF NVL(pParte,0) = 5 THEN 
					UPDATE bdinteg:"informix".si_cte_rostro
					SET rmapa2 = pTemplate, usuario_camb = pOperador, fecha_camb = dFechaHoy, fech_ult_camb = dFecha
					WHERE empresa = pEmpresa 
					  AND numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND secuencia = iSecuencia
					  AND fecha_alta = dFechaHoy;
					LET cCodRet = '00000';
				ELIF NVL(pParte,0) = 6 THEN 
					UPDATE bdinteg:"informix".si_cte_rostro
					SET rmapa3 = pTemplate, usuario_camb = pOperador, fecha_camb = dFechaHoy, fech_ult_camb = dFecha
					WHERE empresa = pEmpresa 
					  AND numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND secuencia = iSecuencia
					  AND fecha_alta = dFechaHoy;
					LET cCodRet = '00000';
				END IF;
		
		ELIF pOpcion = 2 THEN
		
			UPDATE bdinteg:"informix".si_cte_rostro 
			SET estado = 'C' 
			WHERE empresa = pEmpresa 
			AND numcte = LPAD(TRIM(pNumCliente),9,'0') 
			AND estado = 'A';
					
		/*	IF NVL(pParte,0) = 1 THEN
				LET iSecuencia = iSecuencia +1;
			END IF;*/
				
			INSERT INTO bdinteg:"informix".si_cte_rostro(empresa, sucursal, numcte,secuencia, estado, rmapa, rmapa2,rmapa3, usuario,template_procesado, mac, ip, fecha_alta, usuario_camb, fecha_camb, fech_ult_camb)
			VALUES(pEmpresa, pSucursal,LPAD(TRIM(pNumCliente),9,'0'), '1','A', pTemplate, '','', pOperador, '','','',dFechaHoy, pOperador, dFechaHoy, dFecha);				
						
			LET cCodRet = '00000';
			
		ELIF pOpcion = 3 THEN
		
			UPDATE bdinteg:"informix".si_cliente SET tpo_biometria = '1' WHERE numcte = LPAD(TRIM(pNumCliente),9,'0');
				
			
			UPDATE  bdinteg:"informix".si_cte_rostro 
			SET estado ='A', template_procesado = pTemplate_procesado, mac = pMac, ip = pIp
			WHERE  empresa = pEmpresa 
					  AND numcte = LPAD(TRIM(pNumCliente),9,'0')
					  AND estado = 'C'
					  AND fecha_alta = dFechaHoy;
			LET cCodRet = '00000';
		
		END IF;
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio.........: 1433-Reconocimiento_Facial',
'Autor.........: 94565457 - Jose Angel Gaxiola Gaxiola',
'Fecha.........: 09/05/2014',
'Descripcion...: Se crea procedimiento para validar si hay registro en la tabla "si_cte_rostro", e insertar informacion.',
'Solicita......: Daniel Zambada',
'BD............: bdinteg',
'Folio.........: 77-Alta de Rostros',
'Autor.........: 96674555- Carolina Verdugo',
'Fecha.........: 28/06/2016',
'Descripcion...: Se Agregan Ip, Mac y template_procesado como parametros de entrada, Se modifican los campos de los insert, se modifica la opcion 1, y se agrega update en la opcion 3 .',
'BD............: bdinteg';

CREATE PROCEDURE "informix".sp_consulta_param_rostros(pEmpresa CHAR(3), pSucursal CHAR(4), pCodigo CHAR(20),pOpcion CHAR(1),pEjecucion SMALLINT)
RETURNING CHAR(6) AS cCodRet, CHAR(3) AS cEmpresa, CHAR(4) AS cSucursal, CHAR(20) AS cCodigo, VARCHAR(100) AS cValor, CHAR(30) AS cDescripcion;
--DECLARACION DE VARIABLES
DEFINE cCodRet       	CHAR(6);
DEFINE iSqlErr        INTEGER;
DEFINE cCodigo        CHAR(20);
DEFINE cValor         VARCHAR(100);
DEFINE cDescripcion   CHAR(30);
DEFINE cEmpresa       CHAR(3);
DEFINE cSucursal      CHAR(4);
DEFINE vcont  SMALLINT;

--INICIALIZACION DE VARIABLES
LET cCodRet="000000"; --CÃ³digo exitoso
LET iSqlErr=0;
LET cCodigo='';
LET cValor ='';
LET cDescripcion='';
LET cEmpresa='';
LET cSucursal='';
LET vcont  = 0;

  BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			LET cCodigo='';
			LET cValor ='';
			LET cDescripcion='';
			LET cEmpresa='';
			LET cSucursal='';
            RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
        END IF;
    END EXCEPTION;
	
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO wait 3;
	
	--SET DEBUG FILE TO '/respaldosbd/Leslie/08022016/sp2.out';
	--TRACE ON;
	
		IF TRIM(NVL(pEmpresa,''))<>'' AND TRIM(NVL(pSucursal,''))<>''  AND TRIM(NVL(pOpcion,''))<>'' THEN
			IF TRIM(NVL(pOpcion,''))='1'  THEN
				IF TRIM(NVL(pCodigo,''))<>'' THEN
					SELECT empresa,sucursal,codigo,valor, descripcion 
					INTO   cEmpresa,cSucursal,cCodigo,cValor, cDescripcion
					FROM bdinteg:"informix".si_sucservicios_rostro
					WHERE empresa=pEmpresa
					AND sucursal=pSucursal 
					AND codigo=pCodigo;
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodret = '000002'; --No se encontraron registros
						RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
					ELSE
						RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
					END IF
				ELSE
					LET cCodret = '000001'; --ParÃ¡metros de entrada vacÃ­os
					RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
				END IF
			ELSE 
				FOREACH
					SELECT {+INDEX ( bdinteg:"informix".si_sucservicios_rostro idx_si_sucservicios_rostro)}  empresa,sucursal,codigo,valor, descripcion 
					INTO   cEmpresa,cSucursal,cCodigo,cValor, cDescripcion
					FROM bdinteg:"informix".si_sucservicios_rostro
					WHERE empresa=pEmpresa
					AND sucursal=pSucursal
					
	    			if vcont < pEjecucion then
						 LET vcont = vcont + 1;
						 continue foreach;
					end if
     				LET vcont = vcont + 1;
					  
					RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion) WITH RESUME;
				END FOREACH;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '000002'; --No se encontraron registros
					RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
				END IF
			END IF;
		ELSE
			LET cCodret = '000001'; --ParÃ¡metros de entrada vacÃ­os
			RETURN cCodRet,cEmpresa,cSucursal,TRIM(cCodigo), TRIM(cValor),TRIM(cDescripcion);
		END IF;
	END;
END PROCEDURE
DOCUMENT
' DESCRIPCION:	Se crea procedimiento para realizar consultas a la tabla si_sucservicios_rostro', 
' PROYECTO: 77.1 Biometria facial bancoppel alta de rostro', 
' MODIFICO : Leslie RendÃ³n',			
' FECHA : 2016/06/30',
' BD:  bdinteg ';

CREATE PROCEDURE "informix".sp_genera_archivosbatch_situaciones(pEmpresa CHAR(3), pFechaAct DATE) 
RETURNING CHAR(6);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumTienda CHAR(4);
DEFINE cCveMov CHAR(1);
DEFINE cNumCte CHAR(20);
DEFINE cNumcteCoppel CHAR(20);
DEFINE cNumSol CHAR(20);
DEFINE cCveStatusSolicitante CHAR(1);
DEFINE iIdSituacion INTEGER;
DEFINE iNumEmp INTEGER;
DEFINE dFechaMov DATE;
DEFINE iNumCentro SMALLINT;
DEFINE iCveOrigen SMALLINT;
DEFINE cCvePuntualidadCte CHAR(1);
DEFINE iNumMotivoResp SMALLINT;
DEFINE iNumPersonaResp SMALLINT;
DEFINE cDesCtas CHAR(1);
DEFINE sSQL LVARCHAR (32000);
DEFINE iNumSec INTEGER;
DEFINE dFechaHoy DATE;
DEFINE cStatus CHAR(2);
DEFINE dtFechaHoraMax DATETIME  YEAR TO SECOND;
DEFINE dtFechaHora DATETIME  YEAR TO SECOND;
DEFINE cSitEsp CHAR(1);
DEFINE iCausaSitEsp SMALLINT;
DEFINE cFecha CHAR(10);

LET iSqlErr = 0;
LET cCodRet = '00005';
LET cNumTienda = '';
LET cCveMov = 'M';
LET cNumCte = '0';
LET cNumcteCoppel = '0';
LET cNumSol = '0';
LET cCveStatusSolicitante = '';
LET iIdSituacion = 0;
LET iNumEmp = 0;
LET dFechaMov  = DATE(1);
LET iNumCentro = 0;
LET iCveOrigen = 9;
LET cCvePuntualidadCte = '';
LET iNumMotivoResp = 0;
LET iNumPersonaResp = 0;
LET cDesCtas = '';
LET sSQL = '';
LET iNumSec = 0;
LET dFechaHoy  = DATE(1);
LET cStatus = '';
LET dtFechaHoraMax = CURRENT;
LET dtFechaHora = CURRENT;
LET cSitEsp = '';
LET iCausaSitEsp = 0;
LET cFecha = '';

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		rollback work;
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	
--  SET DEBUG FILE TO '/RESPALDOS/sp_genera_archivosbatch_situaciones_pba.out';
--  TRACE ON;

	IF NVL(pFechaAct,MDY(1,1,1900)) <> MDY(1,1,1900) AND NVL(pEmpresa,'') <> ''THEN
		SELECT fecha_hoy INTO dFechaHoy FROM "informix".si_fechas;
		IF NVL(dFechaHoy,MDY(1,1,1900)) <> MDY(1,1,1900) THEN
			UPDATE STATISTICS MEDIUM FOR TABLE si_archivoscopdiario_sitesp;
			SELECT NVL(secuencia_max,0) INTO iNumSec FROM "informix".si_archivosecuenciamax_sitesp;		
			--LET iNumSec = iNumSec + 1;
		
			FOREACH WITH HOLD

				SELECT DISTINCT NVL(sss.num_solicitud,''),NVL(sss.numcte,''),NVL(ssa.fecha_entrada,DATE(1)),
				NVL(sss.sucursal,'0'),NVL(sss.user_insert,0),NVL(ssa.status_solicitud,''),NVL(ssa.fecha_hora,'')
				INTO cNumSol,cNumCte,dFechaMov,cNumTienda,iNumEmp,cStatus,dtFechaHora
				FROM bdisolic:"informix".ss_autorizacion ssa,
				bdisolic:"informix".ss_solicitudes sss
				WHERE sss.num_solicitud = ssa.num_solicitud
				AND sss.empresa = ssa.empresa			
				AND ssa.status_solicitud = sss.status_solicitud
				AND ssa.fecha_entrada = pFechaAct
				AND sss.num_producto = '6500'
				AND ssa.status_solicitud IN('RT','AP')
				AND sss.sucursal=sss.sucursal
				AND sss.fecha_insert=sss.fecha_insert

				SELECT cliente
				INTO cNumcteCoppel
				FROM bdinteg:"informix".si_relacion_ctebcplcpl 
				WHERE  empresa = pEmpresa AND numcte_banco = cNumCte AND tipo_relacion <> 0 AND cliente_prosp <> '1';
				
				IF cStatus = 'RT' THEN
					LET cCveStatusSolicitante = 'R';
					LET cCvePuntualidadCte = '';
					LET iCveOrigen = 12;
					SELECT NVL(situacion_especial,''),NVL(causa_sitesp,0) INTO cSitEsp,iCausaSitEsp FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = cNumSol;
					IF (NVL(cSitEsp,'') = '' AND NVL(iCausaSitEsp,0) = 0) THEN
						CONTINUE FOREACH;
					ELSE
						SELECT {+INDEX (bdinteg:"informix".si_relacionsituacionescausasbcpl_cpl idx_relsitespbcpl_cpl)} NVL(relsit.idu_situacion,0) INTO iIdSituacion 
						FROM bdinteg:"informix".si_relacionsituacionescausasbcpl_cpl relsit, bdisolic:"informix".ss_nuevo_parametrico ctesup
						WHERE relsit.clv_situacion = ctesup.situacion_especial
						AND relsit.num_causasituacion = ctesup.causa_sitesp
						AND ctesup.num_solicitud = cNumSol;
					END IF;
				ELSE
					IF cStatus = 'AP' THEN
						LET cCveStatusSolicitante = '';
					ELSE
						LET cCveStatusSolicitante = '';
						LET iCveOrigen = 9;
					END IF;
					
					LET cCvePuntualidadCte = 'N';
					
					SELECT NVL(relsit.idu_situacion,0) INTO iIdSituacion 
					FROM bdinteg:"informix".si_relacionsituacionescausasbcpl_cpl relsit, bdisolic:"informix".ss_os_solautdirecta solaut
					WHERE relsit.clv_situacion = solaut.situacionespecial
					AND relsit.num_causasituacion = solaut.causa
					AND solaut.situacionespecial='S' 
					AND solaut.causa=50 
					AND solaut.status='S'
					AND solaut.num_solicitud = cNumSol;
					
					
			END IF;
			
				IF cNumcteCoppel <> '' THEN
					LET cNumSol = '0';
				END IF;
			
				LET cFecha = YEAR(dFechaMov) || "/" || LPAD(MONTH(dFechaMov),2,'0') || "/" || LPAD(DAY(dFechaMov),2,'0');
				
				LET sSQL = TRIM(NVL(cNumTienda,'0'))||"|"||TRIM(cCveMov)||"|"||TRIM(NVL(cNumcteCoppel,'0'))||"|"||TRIM(NVL(cNumSol,'0'))||"|"||
				TRIM(NVL(cCveStatusSolicitante,''))||"|"||NVL(iIdSituacion,0)||"|"||NVL(iNumEmp,0)||"|"||cFecha||"|"||
				iNumCentro||"|"||iCveOrigen||"|"||TRIM(NVL(cCvePuntualidadCte,''))||"|"||iNumMotivoResp||"|"||iNumPersonaResp||"|"||TRIM(cDesCtas);
	
				begin work;
				
					INSERT INTO "informix".si_archivoscopdiario_sitesp(empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
					VALUES (pEmpresa, iNumSec, cNumTienda, sSQL, cCveMov, pFechaAct);
					
					LET iNumSec = iNumSec + 1;
				
					UPDATE "informix".si_archivosecuenciamax_sitesp SET secuencia_max = iNumSec;
						
				commit work;
				
			END FOREACH;
			
			LET cCodRet = '00000';
		ELSE
			LET cCodRet = '00002';
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'AUTOR: MIREYA REYES',
'FOLIO: 1739',
'DESCRIPCION: Se crea procedimiento almacenado para que inserte los movimientos de situaciones en la tabla: si_archivoscopdiario_sitesp',
'FECHA: 06/07/2015',
'VERSION: 20150706.1740',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_total_bitsmstelsms_bpi(pNumCliente CHAR(9))
   returning CHAR(5);
   
	-- Se clona stored procedure sp_total_bitsmstelsms para contabilizar las oportunidades de solicitud de clave nueva por sms pero en la tabla si_bitsmstelsms_bpi
	-- AUTOR : Keevyn Adrian Gil Valenzuela
	-- FECHA : 20/12/2016
	-- BD    : bdinteg

    DEFINE sql_err INTEGER ;
    DEFINE cCodRet CHAR(5);
	DEFINE iContador INTEGER;
	
	LET cCodRet='00000';
	
  --SET DEBUG FILE TO "/tmp/sp_total_bitsmstelsms_bpi.out";
  --TRACE ON;
  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
            RETURN cCodRet;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT COUNT(numcte) 
	INTO iContador 
	FROM bdinteg:"informix".si_bitsmstelsms_bpi 
	WHERE numcte =pNumCliente AND DATE(fecha)=DATE(CURRENT);
	IF iContador>=10 THEN
		LET cCodRet='00001';
	ELSE
		LET cCodRet='00000';
	END IF;

	RETURN cCodRet;
	
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1616?BPI-ValidaNumeroCelular',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 30-11-2015',
'MODIFICACIÓN..: Se crea stored procedure para contabilizar las oportunidades de solicitud de clave nueva por sms',
'SOLICITA......: Walber Castro',
'BD............: BDINTEG',
'FOLIO.........: 1631-BPILogin',
'AUTOR.........: Edgar Alarcon',
'FECHA.........: 12-02-2016',
'MODIFICACIÓN..: Se verifica si es id de usuario o numero de cliente',
'SOLICITA......: Walber Castro',
'BD............: BDINTEG';

CREATE PROCEDURE "informix".sp_claveasocia_cta_cel(pNumCel CHAR(10))
											  
-- Genera una clave de confirmación para validar el número de celular que se desea asociar a una cuenta.
-- AUTOR : Keevyn Adrian Gil Valenzuela
-- FECHA : 16/11/2016
-- BD    : bdinteg

RETURNING
    CHAR(6);        -- CodigoRetorno
	

	-- Declarar variables 
	DEFINE cCodRet 		CHAR(6);
	DEFINE iSql_err 	INTEGER;
	
	DEFINE cUno			CHAR(2);
	DEFINE cDos			CHAR(2);
	DEFINE cTres		CHAR(2);
	DEFINE dHora        DATETIME HOUR TO SECOND;
	
	
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			let cCodRet = iSql_err;
            RETURN cCodRet;
		END IF;
	END EXCEPTION ;
	
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/respaldosbd/Keevyn/sp_claveasocia_cta_cel.out";
	--TRACE ON;
	
	LET dHora = current hour to fraction;
	LET cUno = SUBSTR(pNumCel,3,2);
	LET cDos = SUBSTR(pNumCel,7,2);
	LET cTres = SUBSTR(dHora, 7,2);
	LET cCodRet = cUno || cDos || cTres;
	
		
	RETURN cCodRet;
	
END 
END PROCEDURE;