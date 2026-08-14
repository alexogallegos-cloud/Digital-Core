CREATE PROCEDURE "informix".sp_traspasocuentas_cred(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
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

--SET DEBUG FILE TO "/informix/ALAN/Sps/Nuevacarpeta/sp_traspasocuentas_cred.out";
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

					INSERT INTO bdinteg:"informix".si_fusbitacora_aumlincred (empresa,num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,smb_lincred,grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert,dfecha_cobranza,num_inc_prev,num_per_porutimay_806,num_per_porutimay_8012,medio_res,cte_noestit_p,cte_noestit_v,porc_uso,int_cred_ven,may_porc_uso6,revisioncac,numcte_cop,antiguedad,puntualidad,eficienciapago,montovencido,abonomensual,lincred_solicitada,comp_ingreso,antecedentes_buro,antecedentes_circulo,pago_minimo,situacion,causa,compromisos_bco,compromisos_hip,ingreso_idp,prom_porc_uso12)
					SELECT {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} empresa,num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,smb_lincred,grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert,dfecha_cobranza,num_inc_prev,num_per_porutimay_806,num_per_porutimay_8012,medio_res,cte_noestit_p,cte_noestit_v,porc_uso,int_cred_ven,may_porc_uso6,revisioncac,numcte_cop,antiguedad,puntualidad,eficienciapago,montovencido,abonomensual,lincred_solicitada,comp_ingreso,antecedentes_buro,antecedentes_circulo,pago_minimo,situacion,causa,compromisos_bco,compromisos_hip,ingreso_idp,prom_porc_uso12
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

create procedure "informix".fixedocta(pempresa char (3))
returning char(5);


DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);

DEFINE sql_err          INTEGER;
DEFINE cod_ret	CHAR(5);
DEFINE cod_ret2         char(5);
DEFINE cod_ret3         char(5);
DEFINE cod_ret4         char(5);

DEFINE v_fecha 	        DATE;

LET v_fecha 	= "/03/20/2008";
LET v_empresa 	= pempresa;
LET v_num_credito 	= "";
--SET DEBUG FILE TO "FixEdo.out";
--TRACE ON;
BEGIN
ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;

            RETURN cod_ret;
        END IF
   END EXCEPTION;

        -------------------------------------------------------
        --SE INICIALIZA TABLA PARA EDOCTAS
        ------------------------------------------------------
        IF EXISTS (select  tabname  from systables where tabname = "sd_movhisedocta" and tabid > 99 and tabtype="T")
        THEN
        DROP TABLE SD_MOVHISEDOCTA;
        END IF;
        --------------------------------------------------------
        CREATE TABLE sd_movhisedocta
          (
            empresa char(3) not null ,
            secuencia serial not null ,
            fecha_mov date not null ,
            hora_mov datetime hour to fraction(3) not null ,
            sucursal char(4),
            num_credito char(20) not null ,
            plaza char(3) not null ,
            transacc_suc char(4) not null ,
            usuario char(8) not null ,
            monto decimal(18,2) not null ,
            codigo_fun char(3) not null ,
            codigo_ref integer not null ,
            divisa char(2) not null ,
            reversado char(1) not null ,
            folio_suc char(16) not null ,
            num_producto char(4) not null ,
            nro_tarjeta varchar(20,1),
            referencia varchar(40,1),
            tipo_cambio decimal(14,6),
            monto_dls decimal(14,2),
            suc_origen varchar(4,1),
            rfc_comer varchar(20,1),
            referencia23 varchar(23,1),
            primary key (fecha_mov,num_credito,sucursal,hora_mov,secuencia,empresa)
          );
        revoke all on sd_movhisedocta from "public";

        create index inx_arrmovhis on sd_movhisedocta
            (folio_suc,codigo_fun,codigo_ref) using btree;
        create unique index inx_movedocta on sd_movhisedocta
            (empresa,num_credito,fecha_mov,reversado,secuencia) using
            btree;
        create unique index inx_movhisedocta on sd_movhisedocta
            (empresa,num_credito,codigo_fun,codigo_ref,fecha_mov,reversado,
            secuencia) using btree;
        create index numcrededocta on sd_movhisedocta
            (num_credito) using btree;

        ------------------------------------------------------
        --PREPARA LA TABLA  PARA EDOCTAS
        -------------------------------------------------------
        INSERT INTO sd_movhisedocta
                select a.empresa,a.secuencia,a.fecha_mov,a.hora_mov,a.sucursal,
                       a.num_credito,a.plaza,a.transacc_suc,a.usuario,a.monto,
                       a.codigo_fun,a.codigo_ref,a.divisa,a.reversado,a.folio_suc,a.num_producto,
                       a.nro_tarjeta,a.referencia,a.tipo_cambio,a.monto_dls,a.suc_origen,
                       a.rfc_comer,a.referencia23
                from sd_movhis a, sd_transfun b , bdinteg:si_transacc  c
                where a.empresa = "001"
                and  a.codigo_fun = b.codigo_fun
                and a.codigo_ref  = b.codigo_ref
                and c.numero = b.transacc
				and c.sistema ="06"
                and c.se_emite_edocta = "S"
                and fecha_mov > "02/20/2008"
                and fecha_mov <= "03/20/2008"
                and reversado <> "S";
	
        UPDATE STATISTICS HIGH FOR TABLE sd_movhisedocta;

	--------------------------------------------------------
	--SE CREA LA TABLA DE PASO
	--------------------------------------------------------
	IF EXISTS (select  tabname  from systables where tabname = "cred21" and tabid > 99 and tabtype="T")
	THEN
        DROP TABLE cred21;
	END IF;

	CREATE TABLE cred21(
	num_credito char(20) not null
	); 
	revoke all on cred21 from "public";
	--------------------------------------------------------
        --SE OBTIENEN LOS CREDITOS QUE NOS INTERESAN
	---------------------------------------------------------
	insert into cred21
        select unique num_credito from sd_movhisedocta
	where fecha_mov = "02/21/2008";
	----------------------------------------------------
	--SE BORRAN LOS CREDITOS21 PARA INSERTALOS NUEVAMENTE
	delete from sd_encabezado2_edocta
	where num_credito in (select num_credito from cred21)
        and fecha_emision = "03/20/2008";
	
        delete from sd_detalle_edocta
	where num_credito in (select num_credito from cred21)
        and fecha_emision = "03/20/2008";
	
        delete from sd_pie_edocta
	where num_credito in (select num_credito from cred21)
        and fecha_emision = "03/20/2008";
        --------------------------------------------------------
	--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
	-------------------------------------------------------
	FOREACH SELECT num_credito
		INTO v_num_credito
 		FROM cred21
        
	LET cod_ret = "000";

    	EXECUTE PROCEDURE informix.uencabezado2layout_edocuenta(v_empresa,v_num_credito,v_fecha) INTO cod_ret2;
    	IF cod_ret =  "000"  THEN
    	LET cod_ret =cod_ret2;
    	END IF
	EXECUTE PROCEDURE informix.udetallelayout_edocuenta(v_empresa,v_num_credito,v_fecha) INTO cod_ret3;
    	IF cod_ret =  "000"  THEN
    	LET cod_ret =cod_ret3;
    	END IF
	EXECUTE PROCEDURE informix.upielayout_edocuenta(v_empresa,v_num_credito,v_fecha) INTO cod_ret4;
    	IF cod_ret =  "000"  THEN
    	LET cod_ret =cod_ret4;
    	END IF


 	END FOREACH;

END;
	RETURN cod_ret;
END PROCEDURE;