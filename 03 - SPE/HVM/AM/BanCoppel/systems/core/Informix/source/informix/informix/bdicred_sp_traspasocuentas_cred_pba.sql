CREATE PROCEDURE "informix".sp_traspasocuentas_cred_pba(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
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
DEFINE vc_Cuenta        CHAR(20);
DEFINE vc_Credito        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_num_tarjeta   CHAR(20);
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
LET vc_Cuenta = "";
LET vc_Credito = "";
LET vi_secuencia = 0;
LET vc_num_tarjeta = "";
LET iExiste=0;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN WORK;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            ROLLBACK WORK;
            let vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/JesusBueno/1449/sp_traspasocuentas_cred.out";
--TRACE ON;

    --***INICIA EL TRASPASO DE CUENTAS DE CREDITO
   
   SET ISOLATION TO DIRTY READ;
    
	SELECT COUNT (num_credito) INTO iExiste FROM sd_maecred WHERE numcte = pClienteTraspasaCtas AND empresa='001';
	
	IF iExiste > 0 THEN
		
		FOREACH
			
			SELECT num_credito INTO vc_Credito FROM sd_maecred WHERE numcte = pClienteTraspasaCtas AND empresa='001'
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecredcont maecredcont1)} 'SD_MAECREDCONT',"sd_maecredcont",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas), CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecredcont WHERE  fecha IS NOT NULL AND num_credito = vc_Credito AND empresa='001' ;
			
			INSERT INTO bdinteg:"informix".si_fusmaecredcont(fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT {+INDEX (bdicred:sd_maecredcont maecredcont1)}  fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecredcont WHERE fecha IS NOT NULL AND num_credito = vc_Credito AND empresa='001' ;

			UPDATE  "informix".sd_maecredcont SET numcte = pClienteTitular WHERE  fecha IS NOT NULL AND num_credito = vc_Credito AND empresa='001' ;
		
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'CUENTAS DE CREDITO','sd_maecred',TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),
			TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas), CURRENT HOUR TO FRACTION(3), TRIM(pUsuario),CURRENT::DATE 
			FROM bdicred: "informix".sd_maecred WHERE   num_credito = vc_Credito AND empresa='001';
		
			INSERT INTO bdinteg:"informix".si_fusmaecred (empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT   empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecred  WHERE  num_credito = vc_Credito AND empresa='001';
            
			UPDATE   "informix".sd_maecred SET numcte = pClienteTitular WHERE  num_credito = vc_Credito AND empresa='001';
		
		END FOREACH;			
		
		SET ISOLATION TO DIRTY READ;
		IF EXISTS (SELECT {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} num_solicitud FROM "informix".sd_bitacora_aumlincred WHERE numcte=pClienteTraspasaCtas AND status IS NOT NULL AND empresa='001') THEN
		
					INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					SELECT  'AUMENTO LINEA CRED',"sd_bitacora_aumlincred",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),
					TRIM(pClienteTitular)||'|'||TRIM(num_solicitud)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
					FROM "informix".sd_bitacora_aumlincred WHERE numcte= TRIM(pClienteTraspasaCtas) AND status IS NOT NULL AND empresa='001';

					INSERT INTO bdinteg:"informix".si_fusbitacora_aumlincred (empresa,num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,smb_lincred,grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert,dfecha_cobranza,num_inc_prev,num_per_porutimay_806,num_per_porutimay_8012,medio_res,cte_noestit_p,cte_noestit_v,porc_uso,int_cred_ven,may_porc_uso6,revisioncac,numcte_cop,antiguedad,puntualidad,eficienciapago,montovencido,abonomensual,lincred_solicitada,comp_ingreso,antecedentes_buro,antecedentes_circulo,pago_minimo,situacion,causa,compromisos_bco,compromisos_hip,ingreso_idp)
					SELECT {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} empresa,num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,smb_lincred,grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert,dfecha_cobranza,num_inc_prev,num_per_porutimay_806,num_per_porutimay_8012,medio_res,cte_noestit_p,cte_noestit_v,porc_uso,int_cred_ven,may_porc_uso6,revisioncac,numcte_cop,antiguedad,puntualidad,eficienciapago,montovencido,abonomensual,lincred_solicitada,comp_ingreso,antecedentes_buro,antecedentes_circulo,pago_minimo,situacion,causa,compromisos_bco,compromisos_hip,ingreso_idp
					FROM "informix".sd_bitacora_aumlincred WHERE numcte=pClienteTraspasaCtas AND status IS NOT NULL AND empresa='001';

					UPDATE {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} "informix".sd_bitacora_aumlincred SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas AND status IS NOT NULL AND empresa='001';               
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		IF EXISTS (SELECT {+INDEX (bdicred:sd_tarjeta idx_sd_tarjeta1)} num_tarjeta  FROM "informix".sd_tarjeta WHERE numcte=pClienteTraspasaCtas) THEN
	  			FOREACH 
						SELECT {+INDEX (bdicred:sd_tarjeta idx_sd_tarjeta1)}  num_credito, secuencia, num_tarjeta INTO vc_Cuenta, vi_secuencia, vc_num_tarjeta
						FROM "informix".sd_tarjeta WHERE numcte=pClienteTraspasaCtas  

						LET vc_tabla = "sd_tarjeta";
						LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia||'|'||TRIM(vc_num_tarjeta);
						LET vc_proceso='TARJETAS CREDITO';

						INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
						VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
						
						INSERT INTO bdinteg:"informix".si_fustarjetacred (empresa,num_credito,secuencia,num_tarjeta,numcte,prodtarjeta,expiracion,tipo_tarjeta,nombre,status_tar,limite_aut,disp_mes,motivo,tipo_asignacion,cobro_comision,gerente_autoriza, folio_canc)
					   
						SELECT  empresa,num_credito,secuencia,num_tarjeta,numcte,prodtarjeta,expiracion,tipo_tarjeta,nombre,status_tar,limite_aut,disp_mes,motivo,tipo_asignacion,cobro_comision,gerente_autoriza, folio_canc
						FROM "informix".sd_tarjeta WHERE num_tarjeta = vc_num_tarjeta AND empresa='001';
						
						UPDATE  "informix".sd_tarjeta SET numcte = pClienteTitular WHERE num_tarjeta = vc_num_tarjeta; 
 
						LET vc_tabla = "intercard";
						LET vc_proceso='INTERCARD';

						INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
						VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
						
						INSERT INTO bdinteg:"informix".si_fusintercardtarjeta (numtarjeta,codstatustarjeta,codproductotarjeta,numcliente,titular,nombre,direccion,coldeleg,ciudad,estado,codpostal,telcasa,teloficina,fechaexp,sefabricaplastico,seimprimenip,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,contmaxtrancompraposmens,numerolote,contmaxtranretatmnachd,contmaxtrancompraposnachd,contmaxtranretatminthd,contmaxtrancompraposinthd,usuarioultmodif,fechaultmodif,acumretatmnachd,acumretatminthd,acumcompraposnachd,acumcompraposinthd,numreporte,enrenovacion,fechaexprenovacion,numtarjetasustituta,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,contmaxtranretatmpropiohd,acumretatmpropiohd,nombrecorto,fechanacimiento,nombrepromotor,cobracomreexptrj,cobracomreimpnip,idpaq,codstatusasignada,fechaasignacion,acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,soportetranatmcajerored,contnipinvalido,acumdiarioretatmconvenio,acummensualretatmconvenio,acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,contcomretatmconvenio,contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,contmaxtranconsatmdconveniodiarias,contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,contmaxtranretatmconveniomens,soportatranatmcajerointernacional,limitemenscompraposnac,limitemenscompraposint,numeroguia,acumdiarioqps,acumdiariocat,acumdiariomotovoz,acumdiariomotoint,acummensualmotovoz,acummensualmotoint,conttransmotovozdiario,conttransmotointdiario,conttransmotovozmensual,conttransmotointmensual) 
						SELECT numtarjeta,codstatustarjeta,codproductotarjeta,numcliente,titular,nombre,direccion,coldeleg,ciudad,estado,codpostal,telcasa,teloficina,fechaexp,sefabricaplastico,seimprimenip,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,contmaxtrancompraposmens,numerolote,contmaxtranretatmnachd,contmaxtrancompraposnachd,contmaxtranretatminthd,contmaxtrancompraposinthd,usuarioultmodif,fechaultmodif,acumretatmnachd,acumretatminthd,acumcompraposnachd,acumcompraposinthd,numreporte,enrenovacion,fechaexprenovacion,numtarjetasustituta,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,contmaxtranretatmpropiohd,acumretatmpropiohd,nombrecorto,fechanacimiento,nombrepromotor,cobracomreexptrj,cobracomreimpnip,idpaq,codstatusasignada,fechaasignacion,acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,soportetranatmcajerored,contnipinvalido,acumdiarioretatmconvenio,acummensualretatmconvenio,acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,contcomretatmconvenio,contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,contmaxtranconsatmdconveniodiarias,contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,contmaxtranretatmconveniomens,soportatranatmcajerointernacional,limitemenscompraposnac,limitemenscompraposint,numeroguia,acumdiarioqps,acumdiariocat,acumdiariomotovoz,acumdiariomotoint,acummensualmotovoz,acummensualmotoint,conttransmotovozdiario,conttransmotointdiario,conttransmotovozmensual,conttransmotointmensual
						FROM intercard:"informix".tarjeta where numcliente=pClienteTraspasaCtas AND numtarjeta = vc_num_tarjeta;

						UPDATE  intercard:"informix".tarjeta SET numcliente= pClienteTitular WHERE numtarjeta = vc_num_tarjeta; 
						
						LET vc_tabla = "sd_encabezado_edocta";
						LET vc_detalle_mov = TRIM(vc_num_tarjeta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||vc_Cuenta; 
						LET vc_proceso='SD_ENCABEZADO_EDOCTA';

						INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
						VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
					   
						INSERT INTO bdinteg:"informix".si_fusencabezado_edocta (fecha_emision,num_credito,num_producto,numcte,num_tarjeta,nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,sucursal_nombre,sucursal_gerente,sucursal_tel,fecha_corte,cp,cl_cobra,rfc,ruta,entre_calles,observaciones,insertos,sucursal)
						
						SELECT {+INDEX (bdicred:sd_encabezado_edocta idx_encabezado_numcte)} fecha_emision,num_credito,num_producto,numcte,num_tarjeta,nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,sucursal_nombre,sucursal_gerente,sucursal_tel,fecha_corte,cp,cl_cobra,rfc,ruta,entre_calles,observaciones,insertos,sucursal
						FROM "informix".sd_encabezado_edocta WHERE  num_tarjeta= vc_num_tarjeta;
						
						UPDATE  {+INDEX (bdicred:sd_encabezado_edocta idx_encabezado_numcte)} "informix".sd_encabezado_edocta SET numcte = pClienteTitular WHERE num_tarjeta= vc_num_tarjeta;
					   
					END FOREACH;
        END IF;

    END IF;
    --***INICIA TRASPASO DE REESTRUCTURA
    SET ISOLATION TO DIRTY READ;
	
	IF EXISTS  (SELECT COUNT(num_credito) FROM sd_maecredcrd WHERE numcte =pClienteTraspasaCtas AND empresa='001') THEN
	
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'SD_MAECREDCRD',"sd_maecredcrd",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_maecredcrd WHERE numcte= TRIM(pClienteTraspasaCtas);
	
				INSERT INTO bdinteg:"informix".si_fusmaecredcrd (empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4 )
				SELECT {+INDEX (bdicred:sd_maecredcrd idx_1x)} empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4 
				FROM "informix".sd_maecredcrd WHERE numcte = pClienteTraspasaCtas;

				UPDATE {+INDEX (bdicred:sd_maecredcrd idx_1x)} "informix".sd_maecredcrd SET numcte = pClienteTitular WHERE numcte = pClienteTraspasaCtas;
				--**
		
		IF EXISTS (SELECT num_credito FROM "informix".sd_maecredrevcrd WHERE numcte = pClienteTraspasaCtas) THEN
		
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'SD_MAECREDREVCRD',"sd_maecredrevcrd",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE
				FROM "informix".sd_maecredrevcrd WHERE numcte= TRIM(pClienteTraspasaCtas);
						
				INSERT INTO bdinteg:"informix".si_fusmaecredrevcrd(empresa,folio,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4)
				SELECT {+INDEX (bdicred:sd_maecredrevcrd idx_sd_maecredrevcrd)}  empresa,folio,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
				FROM "informix".sd_maecredrevcrd WHERE numcte= pClienteTraspasaCtas;

				UPDATE {+INDEX (bdicred:sd_maecredrevcrd idx_sd_maecredrevcrd)}  "informix".sd_maecredrevcrd SET numcte = pClienteTitular WHERE numcte= pClienteTraspasaCtas;
		END IF;
		--****
		IF EXISTS (SELECT num_credito  FROM "informix".sd_maecredcontcrd WHERE numcte=pClienteTraspasaCtas) THEN
		
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT {+INDEX (bdicred:sd_maecredcontcrd idx_sd_maecredcontcrd)}  'SD_MAECREDCONTCRD',"sd_maecredcontcrd",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_maecredcontcrd WHERE numcte= pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_fusmaecredcontcrd (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4)
				SELECT {+INDEX (bdicred:sd_maecredcontcrd idx_sd_maecredcontcrd)}  fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
				FROM "informix".sd_maecredcontcrd WHERE numcte=pClienteTraspasaCtas;

				UPDATE {+INDEX (bdicred:sd_maecredcontcrd idx_sd_maecredcontcrd)}  "informix".sd_maecredcontcrd SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
					 
		END IF;
		
		IF EXISTS (SELECT  num_credito FROM "informix".sd_seguimientocrd WHERE numcte = pClienteTraspasaCtas) THEN
				
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT  'SD_SEGUIMIENTOCRD',"sd_seguimientocrd",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_seguimientocrd WHERE numcte= TRIM(pClienteTraspasaCtas);
				
				INSERT INTO bdinteg:"informix".si_fusseguimientocrd (empresa,id_tipo,id_campania,num_credito,fecha_corte,sucursal,numcte,nombre_cliente,tel_casa,tel_celular,tel_oficina,num_extension,nombre_referencia1,telefono_referencia1,nombre_referencia2,telefono_referencia2,fecha_reestruc,monto_reestruc,fecha_prox_pago,monto_prox_pago,saldo_corte) 
				SELECT empresa,id_tipo,id_campania,num_credito,fecha_corte,sucursal,numcte,nombre_cliente,tel_casa,tel_celular,tel_oficina,num_extension,nombre_referencia1,telefono_referencia1,nombre_referencia2,telefono_referencia2,fecha_reestruc,monto_reestruc,fecha_prox_pago,monto_prox_pago,saldo_corte
				FROM "informix".sd_seguimientocrd WHERE numcte= pClienteTraspasaCtas;

				UPDATE  "informix".sd_seguimientocrd SET numcte = pClienteTitular WHERE  numcte= pClienteTraspasaCtas;
		
		END IF;
		
		IF EXISTS (SELECT num_credito FROM "informix".sd_encabezado_edoctacrd WHERE numcte = pClienteTraspasaCtas) THEN
		
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT  'SD_ENCABEZADO_EDOCTACRD',"sd_encabezado_edoctacrd",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_encabezado_edoctacrd WHERE numcte= TRIM(pClienteTraspasaCtas);
				
				INSERT INTO bdinteg:"informix".si_fusencabezado_edoctacrd (fecha_emision,num_credito,num_cta_efec,num_producto,numcte,nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,cl_cobra,sucursal_numero,sucursal_nombre,sucursal_gerente,rfc,sucursal_tel,cp,ruta,entre_calles,observaciones,insertos) 
				SELECT  fecha_emision,num_credito,num_cta_efec,num_producto,numcte,nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,cl_cobra,sucursal_numero,sucursal_nombre,sucursal_gerente,rfc,sucursal_tel,cp,ruta,entre_calles,observaciones,insertos
				FROM "informix".sd_encabezado_edoctacrd WHERE numcte= pClienteTraspasaCtas;
		
				UPDATE "informix".sd_encabezado_edoctacrd SET numcte = pClienteTitular WHERE numcte = pClienteTraspasaCtas;
				
		END IF;
		
    END IF;   
     
	IF EXISTS (SELECT num_credito  FROM "informix".sd_grupo_credito WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'GRUPO_CREDITO',"sd_grupo_credito",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(pClienteTitular)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_grupo_credito WHERE numcte= TRIM(pClienteTraspasaCtas);
	
            INSERT INTO bdinteg:"informix".si_fusgrupo_credito (empresa,num_producto,num_credito,numcte,grupo,tipo,status_cliente,fecha_status,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,meses_sinusolin,user_insert,fecha_insert)
			SELECT  empresa,num_producto,num_credito,numcte,grupo,tipo,status_cliente,fecha_status,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,meses_sinusolin,user_insert,fecha_insert
			FROM "informix".sd_grupo_credito WHERE numcte= pClienteTraspasaCtas;
			
            UPDATE "informix".sd_grupo_credito SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
			
    END IF;
     
	IF EXISTS (SELECT num_credito  FROM "informix".sd_grupo_credito_his WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT  'GRUPO_CREDITO_HIS',"sd_grupo_credito_his",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(pClienteTitular)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_grupo_credito_his WHERE numcte= TRIM(pClienteTraspasaCtas);
			
            INSERT INTO bdinteg:"informix".si_fusgrupo_credito_his (empresa,num_producto,num_credito,numcte,fecha_status,grupo,tipo,status_cliente,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,user_insert,fecha_insert,motivo)
			SELECT  empresa,num_producto,num_credito,numcte,fecha_status,grupo,tipo,status_cliente,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,user_insert,fecha_insert,motivo
			FROM "informix".sd_grupo_credito_his WHERE numcte=pClienteTraspasaCtas;

            UPDATE "informix".sd_grupo_credito_his SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
        
    END IF;
    
	IF EXISTS (SELECT numcte  FROM "informix".sd_grupo_cliente WHERE numcte=pClienteTraspasaCtas) THEN
  
        LET vc_tabla = "sd_grupo_cliente";
        LET vc_detalle_mov = TRIM(pClienteTraspasaCtas); 
        LET vc_proceso='GRUPO_CLIENTE';

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
        VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
		
        INSERT INTO bdinteg:"informix".si_fusgrupo_cliente (empresa,numcte,grupo,user_insert,fecha_insert)
        SELECT empresa,numcte,grupo,user_insert,fecha_insert
		FROM "informix".sd_grupo_cliente 
		WHERE numcte=pClienteTraspasaCtas;

        DELETE FROM "informix".sd_grupo_cliente WHERE numcte=pClienteTraspasaCtas;

    END IF;
    --***
	IF EXISTS (SELECT  {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   num_credito FROM "informix".sd_maecred_vendida WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   'CARTERA VENDIDA',"sd_maecred_vendida",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(pClienteTitular)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecred_vendida WHERE numcte= TRIM(pClienteTraspasaCtas);
					
            INSERT INTO bdinteg:"informix".si_fusmaecred_vendida (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT   {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecred_vendida WHERE numcte=pClienteTraspasaCtas;

            UPDATE {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   "informix".sd_maecred_vendida SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;          
	
	END IF;
     --***
	 
	IF EXISTS (SELECT  num_credito  FROM "informix".sd_maecredcont_apoyo WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'CREDITO APOYO',"sd_maecredcont_apoyo",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(pClienteTitular)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE
			FROM "informix".sd_maecredcont_apoyo WHERE numcte= TRIM(pClienteTraspasaCtas);
		
            INSERT INTO bdinteg:"informix".si_fusmaecredcont_apoyo (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecredcont_apoyo WHERE numcte=pClienteTraspasaCtas;

            UPDATE  "informix".sd_maecredcont_apoyo SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
    
	END IF;
     --***
	
	IF EXISTS (SELECT {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   num_credito FROM "informix".sd_maecredcrd_vendida WHERE numcte=pClienteTraspasaCtas) THEN
    		
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   'CRD VENDIDA',"sd_maecredcrd_vendida",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(pClienteTitular)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecredcrd_vendida WHERE numcte= TRIM(pClienteTraspasaCtas);
		
            INSERT INTO bdinteg:"informix".si_fusmaecredcrd_vendida (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4)
            SELECT  {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
			FROM   "informix".sd_maecredcrd_vendida where numcte=pClienteTraspasaCtas;

            UPDATE  {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   "informix".sd_maecredcrd_vendida SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
    
	END IF;
    --***
	
	IF EXISTS (SELECT {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}  num_credito FROM "informix".sd_maecredrev WHERE numcte=pClienteTraspasaCtas) THEN
	
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}   'SD_MAECREDREV',"sd_maecredrev",TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),TRIM(folio)||'|'||TRIM(num_credito)||'|'||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecredrev WHERE numcte= TRIM(pClienteTraspasaCtas);
			
            INSERT INTO bdinteg:"informix".si_fusmaecredrev (empresa,folio,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
           SELECT  {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}   empresa,folio,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecredrev WHERE numcte=pClienteTraspasaCtas;

            UPDATE  {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}    "informix".sd_maecredrev SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
    
	END IF;
    
	EXECUTE PROCEDURE bdicred:"informix".sp_traspasocuentas_cred2(pClienteTitular, pClienteTraspasaCtas, pUsuario) INTO vc_CodRet, vc_Mensaje;
	
    IF vc_CodRet = "00000" THEN
		COMMIT WORK;
		RETURN vc_CodRet,vc_Mensaje;
	ELSE
	--Si el segundo SP devuelve un código de retorno diferente de '00000',  hará un ROLLBACK de todo el proceso
		ROLLBACK WORK;
		RETURN vc_CodRet,vc_Mensaje;
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
'BD: bdicred';

CREATE PROCEDURE "informix".sp_cargoref_tdc_general(pEmpresa  CHAR(3),
												 pSucursal CHAR(4),
												 pUsuario  CHAR(8),
												 pTarjeta  CHAR(20),
												 pMonto    DECIMAL(14,2),
												 pTransuc  CHAR(4),
												 pFolioSuc  CHAR(16),
												 pReferencia  CHAR(40))
RETURNING CHAR(5)     AS codigo_retorno,
          CHAR(4)     AS terminacion_tarjeta,
          CHAR(60)    AS nombre_cte,
          MONEY(16,2) AS monto_cargo,
		  MONEY(16,2) AS monto_comision,
		  MONEY(16,2) AS iva_comision;
		  
DEFINE nrows              INTEGER;
DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE vCodRet            CHAR(5);	  

DEFINE cod_ret            CHAR(5);
DEFINE v_codparam	   	  CHAR(4);
DEFINE v_fecha            DATE;
DEFINE Saldo              MONEY(14,2);
DEFINE MtoCgo		  	  MONEY(14,2);
DEFINE cod_ret2           CHAR(5);
DEFINE SaldoCom           MONEY(14,2);
DEFINE MtoCom		   	  MONEY(12,2);
DEFINE v_num_credito      CHAR(20);
DEFINE v_divisa           CHAR(2);
DEFINE vsucorig           CHAR(4);
DEFINE vNumCte            CHAR(20);
DEFINE vNombreCte         CHAR(60);
DEFINE vTerminacion       CHAR(4);
DEFINE vIvaCom            MONEY(16,2);

LET nrows                 = 0;
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = '';
LET vCodRet               = '000';

LET cod_ret               = "000";
LET v_codparam	   	      = "";
LET v_fecha               = DATE(1);
LET Saldo                 = 0;
LET MtoCgo		  	      = 0;
LET cod_ret2              = "";
LET SaldoCom              = 0;
LET MtoCom		   	      = 0;
LET v_num_credito         = "";
LET v_divisa              = "";
LET vsucorig              = "";
LET vNumCte               = "";
LET vNombreCte            = "";
LET vTerminacion          = "";
LET vIvaCom               = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
		LET vCodRet = iSqlErr;
		RETURN cod_ret, vTerminacion, vNombreCte, MtoCgo, MtoCom, vIvaCom;
    END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/informix/paulq/cargoref_tdc_general.out";
-- TRACE ON;
	  
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT a.num_credito, b.divisa, b.sucursal, b.numcte
  INTO v_num_credito, v_divisa, vsucorig, vNumCte
  FROM bdicred:"informix".sd_tarjeta a,
       bdicred:"informix".sd_maecred b
 WHERE a.empresa     = pEmpresa
   AND a.num_tarjeta = pTarjeta
   AND b.empresa     = a.empresa
   AND b.num_credito = a.num_credito;

IF v_num_credito IS NULL THEN
	LET cod_ret = "8";
	RETURN cod_ret, vTerminacion, vNombreCte, MtoCgo, MtoCom, vIvaCom;
END IF

SELECT TRIM(NVL(razon_social, ' ')) ||
TRIM(nombre1) || " " ||
--TRIM(NVL(nombre2, ' ')) || " " ||
TRIM(apell_paterno)
--TRIM(apell_materno)
INTO vNombreCte
FROM bdinteg:"informix".si_cliente
WHERE numcte = vNumCte;

LET vTerminacion = SUBSTR(pTarjeta,LENGTH(pTarjeta)-3,LENGTH(pTarjeta));
		
EXECUTE PROCEDURE bdicred:"informix".cargo_ref_cel(pTarjeta, pSucursal, pUsuario,
					                               pTransuc, pTransuc, pFolioSuc,
												   v_num_credito, 1, pMonto, 0,
												   " ", " ", v_divisa, pReferencia,  
												   pSucursal, pUsuario, "",
												   "", "", v_num_credito,
												   1, 0, v_divisa, " ", "2",
												   "F"," ", " ", " ", 0, 0, " ", " ")
	INTO cod_ret, v_codparam, v_fecha, Saldo, MtoCgo, 
	     cod_ret2, v_codparam, v_fecha, SaldoCom, MtoCom;
		 
    LET vIvaCom = MtoCgo - pMonto - MtoCom;
		
RETURN cod_ret, vTerminacion, vNombreCte, MtoCgo, MtoCom, vIvaCom;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para la realización del cargo',
'por retiro de efectivo TDC desde alguna plataforma',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 08/09/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consulta_retiro_tdc(pEmpresa     CHAR(3),
												   pSucursal    CHAR(4),
												   pCuenta      CHAR(20),
												   pNumTarjeta  CHAR(20),
												   pMonto       DECIMAL(14,2),
												   pDivisa      CHAR(2))
RETURNING CHAR(5)         AS codigo_retorno,
          DECIMAL(14,2)   AS importe_retiro,
		  DECIMAL(14,2)   AS importe_comision,
		  DECIMAL(14,2)   AS importe_iva_comision;
									
DEFINE nrows              INTEGER;
DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE vCodRet            CHAR(5);

DEFINE vNumCte            CHAR(20);
DEFINE vEmpresa           CHAR(3);
DEFINE vSucursal          CHAR(4);
DEFINE vDivisa            CHAR(2);
DEFINE vNumProducto       CHAR(4);
DEFINE vStatusCred        CHAR(2);
DEFINE vSaldo             MONEY(16,2);
DEFINE vTipoCredito       CHAR(2);
DEFINE vTasaIva           DECIMAL(5,3);
DEFINE vFechaHoy          DATE;
DEFINE vSdoPos            DECIMAL(14,2);
DEFINE vBloqueo           INTEGER;
DEFINE vCodCaracter       CHAR(2);
DEFINE v_codparam         CHAR(4);
DEFINE v_faplica          CHAR(1);
DEFINE vMtoComDisp        DECIMAL(14,2);
DEFINE v_factor           DECIMAL(9,6);
DEFINE v_rangos           CHAR(1);
DEFINE v_rmax             MONEY(14,2);
DEFINE vMtoComDisp_iva    DECIMAL(14,2);
DEFINE vIva               DECIMAL(14,2);

LET nrows                 = 0;
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = '';
LET vCodRet               = '000';

LET vNumCte               = '';
LET vEmpresa              = '';
LET vSucursal             = '';
LET vDivisa               = '';
LET vNumProducto          = '';
LET vStatusCred           = '';
LET vSaldo                = 0;
LET vTipoCredito          = '';
LET vTasaIva              = 0;
LET vFechaHoy             = DATE(1);
LET vSdoPos               = 0;
LET vBloqueo              = 0;
LET vCodCaracter          = '';
LET v_codparam            = '';
LET v_faplica             = '';
LET vMtoComDisp           = 0;
LET v_factor              = 0;
LET v_rangos              = '';
LET v_rmax                = 0;
LET vMtoComDisp_iva       = 0;
LET vIva                  = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
		LET vCodRet = iSqlErr;
		RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/paulq/sp_consulta_retiro_tdc.out';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

IF NOT EXISTS( SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
	LET vCodRet = "1070";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF NOT EXISTS(SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = pEmpresa AND sucursal = pSucursal) THEN
	LET vCodRet = "1077";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF NOT EXISTS(SELECT divisa FROM bdinteg:"informix".si_divisas where divisa = pDivisa) THEN
	LET vCodRet = "1078";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF NVL(pMonto,0) <= 0 THEN
	LET vCodRet = "1079";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF TRIM(NVL(pNumTarjeta,'')) = '' AND TRIM(NVL(pCuenta,'')) = '' THEN
	LET vCodRet = "1076";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF TRIM(NVL(pCuenta,'')) = '' THEN 
	SELECT num_credito
	  INTO pCuenta
	  FROM bdicred:"informix".sd_tarjeta
	 WHERE empresa = pEmpresa
	   AND num_tarjeta = pNumTarjeta
	   AND tipo_tarjeta = "T"
	   AND status_tar = "A";

	IF pCuenta IS NULL THEN
		LET vCodRet = "8";
		RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
	END IF
END IF;

SELECT a.empresa, a.sucursal, a.divisa, a.num_producto, a.status_cred,
	   b.monto_otorgado - (b.sdo_cap_insoluto + sdo_retenido),
       c.cod_tipcred, d.iva, e.fecha_proceso,
       CASE WHEN sdo_capital < 0 THEN  sdo_capital * -1 ELSE 0 END,
       a.id_unidad_prod, numcte,Cod_caract_2
  INTO vEmpresa, vSucursal, vDivisa, vNumProducto, vStatusCred,
	   vSaldo, vTipoCredito, vTasaIva, vFechaHoy, vSdoPos,
	   vBloqueo, vNumCte, vCodCaracter
  FROM "informix".sd_maecred a, "informix".sd_maesdos b, "informix".sd_definicion c, "informix".sd_maecredanexo e,
       bdinteg:"informix".si_sucursales d
 WHERE a.num_credito = pCuenta
   AND a.empresa = pEmpresa
   AND b.num_credito = a.num_credito
   AND a.empresa = b.empresa
   AND c.num_producto = a.num_producto
   AND e.num_credito = a.num_credito
   AND e.empresa = a.empresa
   AND d.empresa = a.empresa
   AND d.sucursal = pSucursal;
   
	IF vNumCte IS NULL THEN
			LET vCodRet = "100";
			RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
	END IF
   
SELECT valor
  INTO v_codparam
  FROM "informix".sd_param
 WHERE empresa = '001'
   AND cod_param = "334";

SELECT form_aplica, monto, apli_factor, consi_rango, monto_max
  INTO v_faplica, vMtoComDisp, v_factor, v_rangos, v_rmax
  FROM "informix".sd_tpcomis
 WHERE empresa = '001'
   AND cod_comis = v_codparam;
   
IF v_faplica = 2 THEN
	LET vMtoComDisp = pMonto * (v_factor/100);
END IF
   
IF v_rangos = "1" THEN
	IF vMtoComDisp < v_rmax THEN
		LET vMtoComDisp = v_rmax;
	END IF
END IF;

LET vMtoComDisp_iva = vMtoComDisp * vTasaIva;
LET vIva = vMtoComDisp_iva;

RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);

END
END PROCEDURE
DOCUMENT
'Se realiza el calculo de la comisión',
'por retiro de efectivo TDC',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 08/09/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cac_rep_perfil_usuario(pFechaIni CHAR (10), pFechaFin CHAR(10))
RETURNING CHAR(6)                         AS codigo_retorno,
          CHAR(80)                        AS mensaje_retorno,
		  CHAR(8)                         AS Numempleado,
		  CHAR(45)                        AS Nombre,
		  CHAR (25)                       AS Perfil_Puesto,
		  INTEGER                         AS Atendidas,
		  DECIMAL(18,2)                   AS PorcAtendidas,
		  INTEGER                         AS Canceladas,
		  DECIMAL(18,2)                   AS PorcCanceladas,
		  INTEGER                         AS Rechazadas,
		  DECIMAL(18,2)                   AS PorcRechazadas,
		  INTEGER                         AS Autorizadas,
		  DECIMAL(18,2)                   AS PorcAutorizadas,
		  
		  INTEGER                         AS TotalAtendidas,
		  DECIMAL(18,2)                   AS TotalPorcAtendidas,
		  INTEGER                         AS TotalCanceladas,
		  DECIMAL(18,2)                   AS TotalPorcCanceladas,
		  INTEGER                         AS TotalRechazadas,
		  DECIMAL(18,2)                   AS TotalPorcRechazadas,
		  INTEGER                         AS TotalAutorizadas,
		  DECIMAL(18,2)                   AS TotalPorcAutorizadas;

---DECLARACIONES   
DEFINE cCodRet              CHAR(6); 
DEFINE cMensajeRet          CHAR(80);
DEFINE iSqlErr      	    INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE dPorcAtendidas		DECIMAL(18,2);	
DEFINE dPorcCanceladas		DECIMAL(18,2);
DEFINE dPorcRechazadas		DECIMAL(18,2);
DEFINE dPorcAutorizados	    DECIMAL(18,2);
DEFINE cDescripcion 		CHAR(25);
DEFINE cNombre				CHAR(45);
DEFINE cBandera 			CHAR(1);
DEFINE iCanceladas			INTEGER;
DEFINE iAutorizadas	     	INTEGER;
DEFINE iRechazadas		    INTEGER;
DEFINE cEjecutivo           CHAR(8);
DEFINE cPuesto 				CHAR(2);
DEFINE cRangoAutorizacion	CHAR(2);
DEFINE iTotalReg 			INTEGER;
DEFINE iTotalPerfil			INTEGER;

DEFINE dTotalPorcAtendidas		DECIMAL(18,2);	
DEFINE dTotalPorcCanceladas		DECIMAL(18,2);
DEFINE dTotalPorcRechazadas		DECIMAL(18,2);
DEFINE dTotalPorcAutorizados	    DECIMAL(18,2);

DEFINE iTotalTotalPerfil			INTEGER;
DEFINE iTotalCanceladas			INTEGER;
DEFINE iTotalAutorizadas	     	INTEGER;
DEFINE iTotalRechazadas		    INTEGER;
---INICIALIZACIONES

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Se realizó la consulta correctamente";
LET dPorcAtendidas		     = 0;
LET dPorcCanceladas		     = 0;
LET dPorcRechazadas		     = 0;
LET dPorcAutorizados	     = 0;
LET iCanceladas		     	 = 0;
LET iAutorizadas	     	 = 0;
LET iRechazadas		     	 = 0;
LET cEjecutivo				 = "";
LET cPuesto 				 = "";
LET cRangoAutorizacion		 = "";
LET iTotalReg				 = 0;
LET cDescripcion			 = "";
LET cNombre 				 = "";
LET cBandera				 = "";
LET iTotalPerfil			 = 0;

LET dTotalPorcAtendidas		     = 0;
LET dTotalPorcCanceladas		     = 0;
LET dTotalPorcRechazadas		     = 0;
LET dTotalPorcAutorizados	     = 0;

LET iTotalTotalPerfil			 = 0;
LET iTotalCanceladas		     	 = 0;
LET iTotalAutorizadas	     	 = 0;
LET iTotalRechazadas		     	 = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
    LET cCodRet= iSqlErr;
	LET cMensajeRet=cErrorInfo;
       RETURN cCodRet, cMensajeRet, NVL(cEjecutivo,' '), NVL(cNombre,' '), NVL(cDescripcion,' '), NVL(iTotalPerfil,0), NVL(dPorcAtendidas,0), NVL(iCanceladas,0), NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
		NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
   END IF;
END EXCEPTION;

	--set debug file to "/informix/jesus/sp_cac_rep_perfil_usuario.out";
	--trace on;

--se validan los parametros de entrada.
IF NVL(pFechaini,"") = "" OR NVL(pFechaFin,"")="" THEN
	LET cCodRet = "000001";
	LET cMensajeRet = "Falta un parámetro de fecha requerido para realizar  la consulta";
	RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
		NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
----se obtiene el total de registros de solicitudes atendidas.
			
	SELECT {+INDEX (bdicred:sd_historica_cac_aumlincred idx1_sd_historica_cac_aumlincred)} COUNT( b.num_solicitud) --total atendidas 
	INTO iTotalReg
	FROM  bdicred:"informix".sd_historica_cac_aumlincred h ,
	bdicred:"informix".sd_bitacora_aumlincred b			  
	WHERE  h.empresa = b.empresa 
	AND h.solicitud  = b.num_solicitud
	AND h.fecha_insert between  b.fecha_insert and b.fecha_status
	AND b.fecha_insert >= pFechaIni
	AND b.fecha_insert <= pFechaFin
	AND b.origen = "S";
	
	
	IF iTotalReg = 0 THEN
		LET cCodRet = "000003";
		LET cMensajeRet =  "No hay información con el rango de fechas solicitado";		
		RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
			NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
	END IF;	
	--Ciclo para obtener la cantidad de solicitudes atendidas por puesto y ejecutivo
	FOREACH WITH HOLD	
		SELECT {+INDEX (bdicred:sd_historica_cac_aumlincred idx1_sd_historica_cac_aumlincred)} h.puesto,h.ejecutivo,COUNT( b.num_solicitud), --total atendidas por usuario	
		SUM(CASE WHEN b.status='CM' THEN 1 ELSE 0 END),--Canceladas
		SUM(CASE WHEN b.status='RT' THEN 1 ELSE 0 END),--Rechazadas
		SUM(CASE WHEN b.status in ('AT','AP','IN') THEN 1 ELSE 0 END)--Autorizadas
		INTO cPuesto,cEjecutivo,iTotalPerfil,iCanceladas,iRechazadas,iAutorizadas
		FROM bdicred:"informix".sd_bitacora_aumlincred b, bdicred:"informix".sd_historica_cac_aumlincred h
		WHERE  h.empresa = b.empresa 
		AND h.solicitud  = b.num_solicitud
		AND h.fecha_insert between  b.fecha_insert and b.fecha_status
		AND b.fecha_insert >= pFechaIni
		AND b.fecha_insert <= pFechaFin
		AND b.origen = "S"
		GROUP BY h.puesto,h.ejecutivo
		ORDER BY h.puesto,h.ejecutivo		
			
			LET dPorcCanceladas	=0;
			LET dPorcRechazadas	=0;
			LET dPorcAutorizados=0;
			LET dPorcAtendidas  =0;
			
			--Se obtiene el nombre del ejecutivo
			SELECT nombre
			INTO cNombre
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo=cEjecutivo;
			--Se obtiene la descripcion del puesto del ejecutivo
			SELECT descripcion_puesto
			INTO cDescripcion
			FROM bdicred:"informix".sd_puestos_cac_aumlincred
			WHERE puesto=cPuesto;
			
			--Calculo para obtener los porcentajes de las solicitudes atendidas,  canceladas, rechazadas y autorizadas. 
			IF NVL(iTotalPerfil,0) <> 0 THEN
			LET dPorcAtendidas = ((iTotalPerfil * 100) / iTotalReg);
			--Total
			LET iTotalTotalPerfil = iTotalTotalPerfil + iTotalPerfil;
			
			END IF;
			IF NVL(iCanceladas,0) <> 0 THEN
				LET dPorcCanceladas = ((iCanceladas * 100) / iTotalPerfil);
				--Total
				LET iTotalCanceladas = iTotalCanceladas + iCanceladas;
				
			END IF;
			IF NVL(iRechazadas,0) <> 0 THEN
				LET dPorcRechazadas	= ((iRechazadas * 100) / iTotalPerfil);
				--Total
				LET iTotalRechazadas = iTotalRechazadas + iRechazadas;
				
			END IF;
			IF NVL(iAutorizadas,0) <> 0 THEN
				LET dPorcAutorizados =((iAutorizadas * 100) / iTotalPerfil);
				--Total
				LET iTotalAutorizadas = iTotalAutorizadas + iAutorizadas;
				
			END IF;						
			
			LET dTotalPorcAtendidas = ((iTotalTotalPerfil * 100) / iTotalTotalPerfil); 
			LET dTotalPorcCanceladas = ((iTotalCanceladas * 100) / iTotalTotalPerfil);
			LET dTotalPorcRechazadas = ((iTotalRechazadas * 100) / iTotalTotalPerfil); 
			LET dTotalPorcAutorizados = ((iTotalAutorizadas * 100) / iTotalTotalPerfil);
			
			RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
				NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0) WITH RESUME;
		
	END FOREACH;	
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros para el reporte por perfil de usuario en un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111021.0902',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agregan los totales de las atendidas, autorizadas, canceladas y rechazadas',
'Fecha de modificación: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------';

create procedure "informix".sp_depura_incrementos()
--execute procedure sp_depura_incrementos()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;
			
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);	

DEFINE vnum_credito        	CHAR(12);	
DEFINE vnum_cte     		VARCHAR(20);	
DEFINE vstatus				CHAR(2);	
DEFINE fh_inicio			char(19);DEFINE fh_fin				char(19);DEFINE vfecha				DATE;

LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET vnum_credito			="";
LET vnum_cte				="";
LET vstatus					="";
LET fh_inicio				=date(1);
LET fh_fin					=date(1);
LET vfecha					=date(1);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
END EXCEPTION;


--SET DEBUG FILE TO "/RESPALDOS/ipcb/pruebas/sp_depura_incrementos.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

SELECT num_solicitud,fecha_insert
FROM bdicred:sd_bitacora_aumlincred 
WHERE status = 'RT' AND fecha_insert = mdy('12','10','2015') AND origen = 'C' 
INTO TEMP tot_creditos  WITH NO LOG;

CREATE INDEX idx_totcreditos ON tot_creditos (num_solicitud);	
update statistics medium for table tot_creditos;		

select first 1 today||" "||current HOUR TO SECOND   INTO fh_inicio
from systables;

  foreach with hold
    SELECT num_solicitud,fecha_insert INTO  vnum_credito, vfecha
	FROM tot_creditos

    begin;
		DELETE FROM "informix".sd_autorizacion_aumlincred WHERE num_solicitud = vnum_credito  AND fecha_insert  = vfecha;
		DELETE FROM "informix".sd_clientes_clean_behavior WHERE fecha_reporte  = vfecha AND num_credito = vnum_credito;
		DELETE FROM "informix".sd_bitacora_aumlincred WHERE empresa="001" AND num_solicitud = vnum_credito AND status = "RT" AND fecha_insert  = vfecha;
	commit;	
  END FOREACH

select first 1 today||" "||current HOUR TO SECOND   INTO fh_fin
from systables;

LET cCodRet     = "00000";
LET cMensajeRet = "DEPURA INCREMENTOS INICIO:"||fh_inicio ||" FIN:"||fh_fin;

RETURN cCodRet, cMensajeRet; 
END;
END PROCEDURE;