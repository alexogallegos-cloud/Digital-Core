CREATE PROCEDURE "informix".sp_traspasocuentas_cred_soc(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
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

    --BEGIN WORK;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            --ROLLBACK WORK;
            let vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO bdinteg:log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/jagl/bdicred/sp_traspasocuentas_cred_soc.out";
	--TRACE ON;


    --***INICIA EL TRASPASO DE CUENTAS DE CREDITO
   
	SET ISOLATION TO DIRTY READ;
	
	LET pClienteTraspasaCtas = TRIM(pClienteTraspasaCtas);
	LET pClienteTitular = TRIM(pClienteTitular);
    
	SELECT COUNT (num_credito) INTO iExiste FROM sd_maecred WHERE numcte = pClienteTraspasaCtas AND empresa='001';
	
	IF iExiste > 0 THEN
		
		FOREACH
			
			SELECT num_credito INTO vc_Credito FROM sd_maecred WHERE numcte = pClienteTraspasaCtas AND empresa='001'
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecredcont maecredcont1)} 'SD_MAECREDCONT',"sd_maecredcont",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||'|'|| pClienteTraspasaCtas, CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecredcont WHERE  fecha IS NOT NULL AND num_credito = vc_Credito AND empresa='001' ;
			
			INSERT INTO bdinteg:"informix".si_fusmaecredcont(fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT {+INDEX (bdicred:sd_maecredcont maecredcont1)}  fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecredcont WHERE fecha IS NOT NULL AND num_credito = vc_Credito AND empresa='001' ;

			UPDATE  "informix".sd_maecredcont SET numcte = pClienteTitular WHERE  fecha IS NOT NULL AND num_credito = vc_Credito AND empresa='001' ;
		
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'CUENTAS DE CREDITO','sd_maecred',pClienteTitular,pClienteTraspasaCtas,
			TRIM(num_credito)||'|'|| pClienteTraspasaCtas, CURRENT HOUR TO FRACTION(3), TRIM(pUsuario),CURRENT::DATE 
			FROM bdicred: "informix".sd_maecred WHERE   num_credito = vc_Credito AND empresa='001';
		
			INSERT INTO bdinteg:"informix".si_fusmaecred (empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT   empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecred  WHERE  num_credito = vc_Credito AND empresa='001';
            
			UPDATE   "informix".sd_maecred SET numcte = pClienteTitular WHERE  num_credito = vc_Credito AND empresa='001';
		
		END FOREACH;			
		
		SET ISOLATION TO DIRTY READ;
		IF EXISTS (SELECT {+INDEX (bdicred:sd_bitacora_aumlincred idx_bitacora_status)} num_solicitud FROM "informix".sd_bitacora_aumlincred WHERE numcte=pClienteTraspasaCtas AND status IS NOT NULL AND empresa='001') THEN
		
					INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					SELECT  'AUMENTO LINEA CRED',"sd_bitacora_aumlincred",pClienteTitular,pClienteTraspasaCtas,
					pClienteTitular||'|'||TRIM(num_solicitud)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
					FROM "informix".sd_bitacora_aumlincred WHERE numcte= pClienteTraspasaCtas AND status IS NOT NULL AND empresa='001';

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
						LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'|| pClienteTraspasaCtas||'|'||vi_secuencia||'|'||TRIM(vc_num_tarjeta);
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
						LET vc_detalle_mov = TRIM(vc_num_tarjeta)||'|'|| pClienteTraspasaCtas||'|'||vc_Cuenta; 
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
				SELECT 'SD_MAECREDCRD',"sd_maecredcrd",pClienteTitular, pClienteTraspasaCtas,TRIM(num_credito)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_maecredcrd WHERE numcte= pClienteTraspasaCtas;
	
				INSERT INTO bdinteg:"informix".si_fusmaecredcrd (empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4 )
				SELECT {+INDEX (bdicred:sd_maecredcrd idx_1x)} empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4 
				FROM "informix".sd_maecredcrd WHERE numcte = pClienteTraspasaCtas;

				UPDATE {+INDEX (bdicred:sd_maecredcrd idx_1x)} "informix".sd_maecredcrd SET numcte = pClienteTitular WHERE numcte = pClienteTraspasaCtas;
				--**
		
		IF EXISTS (SELECT num_credito FROM "informix".sd_maecredrevcrd WHERE numcte = pClienteTraspasaCtas) THEN
		
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'SD_MAECREDREVCRD',"sd_maecredrevcrd",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE
				FROM "informix".sd_maecredrevcrd WHERE numcte= pClienteTraspasaCtas;
						
				INSERT INTO bdinteg:"informix".si_fusmaecredrevcrd(empresa,folio,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4)
				SELECT {+INDEX (bdicred:sd_maecredrevcrd idx_sd_maecredrevcrd)}  empresa,folio,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
				FROM "informix".sd_maecredrevcrd WHERE numcte= pClienteTraspasaCtas;

				UPDATE {+INDEX (bdicred:sd_maecredrevcrd idx_sd_maecredrevcrd)}  "informix".sd_maecredrevcrd SET numcte = pClienteTitular WHERE numcte= pClienteTraspasaCtas;
		END IF;
		--****
		IF EXISTS (SELECT num_credito  FROM "informix".sd_maecredcontcrd WHERE numcte=pClienteTraspasaCtas) THEN
		
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT {+INDEX (bdicred:sd_maecredcontcrd idx_sd_maecredcontcrd)}  'SD_MAECREDCONTCRD',"sd_maecredcontcrd",pClienteTitular, pClienteTraspasaCtas,TRIM(num_credito)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_maecredcontcrd WHERE numcte= pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_fusmaecredcontcrd (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4)
				SELECT {+INDEX (bdicred:sd_maecredcontcrd idx_sd_maecredcontcrd)}  fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
				FROM "informix".sd_maecredcontcrd WHERE numcte=pClienteTraspasaCtas;

				UPDATE {+INDEX (bdicred:sd_maecredcontcrd idx_sd_maecredcontcrd)}  "informix".sd_maecredcontcrd SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
					 
		END IF;
		
		IF EXISTS (SELECT  num_credito FROM "informix".sd_seguimientocrd WHERE numcte = pClienteTraspasaCtas) THEN
				
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT  'SD_SEGUIMIENTOCRD',"sd_seguimientocrd",pClienteTitular, pClienteTraspasaCtas,TRIM(num_credito)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_seguimientocrd WHERE numcte= pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_fusseguimientocrd (empresa,id_tipo,id_campania,num_credito,fecha_corte,sucursal,numcte,nombre_cliente,tel_casa,tel_celular,tel_oficina,num_extension,nombre_referencia1,telefono_referencia1,nombre_referencia2,telefono_referencia2,fecha_reestruc,monto_reestruc,fecha_prox_pago,monto_prox_pago,saldo_corte) 
				SELECT empresa,id_tipo,id_campania,num_credito,fecha_corte,sucursal,numcte,nombre_cliente,tel_casa,tel_celular,tel_oficina,num_extension,nombre_referencia1,telefono_referencia1,nombre_referencia2,telefono_referencia2,fecha_reestruc,monto_reestruc,fecha_prox_pago,monto_prox_pago,saldo_corte
				FROM "informix".sd_seguimientocrd WHERE numcte= pClienteTraspasaCtas;

				UPDATE  "informix".sd_seguimientocrd SET numcte = pClienteTitular WHERE  numcte= pClienteTraspasaCtas;
		
		END IF;
		
		IF EXISTS (SELECT
					{+AVOID_FULL ("informix".sd_encabezado_edoctacrd)}
					num_credito FROM "informix".sd_encabezado_edoctacrd WHERE numcte = pClienteTraspasaCtas) THEN
		
				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT  
				{+AVOID_FULL ("informix".sd_encabezado_edoctacrd)}
				'SD_ENCABEZADO_EDOCTACRD',"sd_encabezado_edoctacrd",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
				FROM "informix".sd_encabezado_edoctacrd WHERE numcte= pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_fusencabezado_edoctacrd (fecha_emision,num_credito,num_cta_efec,num_producto,numcte,nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,cl_cobra,sucursal_numero,sucursal_nombre,sucursal_gerente,rfc,sucursal_tel,cp,ruta,entre_calles,observaciones,insertos) 
				SELECT  
				{+AVOID_FULL ("informix".sd_encabezado_edoctacrd)}
				fecha_emision,num_credito,num_cta_efec,num_producto,numcte,nombre_cte,direccion_cn,direccion_col,direccion_del,edo_cd,cl_cobra,sucursal_numero,sucursal_nombre,sucursal_gerente,rfc,sucursal_tel,cp,ruta,entre_calles,observaciones,insertos
				FROM "informix".sd_encabezado_edoctacrd WHERE numcte= pClienteTraspasaCtas;
		
				UPDATE 
				{+AVOID_FULL ("informix".sd_encabezado_edoctacrd)}
				"informix".sd_encabezado_edoctacrd SET numcte = pClienteTitular WHERE numcte = pClienteTraspasaCtas;
				
		END IF;
		
    END IF;   
     
	IF EXISTS (SELECT num_credito  FROM "informix".sd_grupo_credito WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'GRUPO_CREDITO',"sd_grupo_credito",pClienteTitular,pClienteTraspasaCtas,pClienteTitular ||'|'||TRIM(num_credito)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_grupo_credito WHERE numcte= pClienteTraspasaCtas;
	
            INSERT INTO bdinteg:"informix".si_fusgrupo_credito (empresa,num_producto,num_credito,numcte,grupo,tipo,status_cliente,fecha_status,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,meses_sinusolin,user_insert,fecha_insert)
			SELECT  empresa,num_producto,num_credito,numcte,grupo,tipo,status_cliente,fecha_status,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,meses_sinusolin,user_insert,fecha_insert
			FROM "informix".sd_grupo_credito WHERE numcte= pClienteTraspasaCtas;
			
            UPDATE "informix".sd_grupo_credito SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
			
    END IF;
     
	IF EXISTS (SELECT num_credito  FROM "informix".sd_grupo_credito_his WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT  'GRUPO_CREDITO_HIS',"sd_grupo_credito_his",pClienteTitular,pClienteTraspasaCtas,pClienteTitular ||'|'||TRIM(num_credito)||'|'||pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_grupo_credito_his WHERE numcte= pClienteTraspasaCtas;
			
            INSERT INTO bdinteg:"informix".si_fusgrupo_credito_his (empresa,num_producto,num_credito,numcte,fecha_status,grupo,tipo,status_cliente,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,user_insert,fecha_insert,motivo)
			SELECT  empresa,num_producto,num_credito,numcte,fecha_status,grupo,tipo,status_cliente,status_cred,monto_autorizado,porcentaje_uso,num_historia_efic,user_insert,fecha_insert,motivo
			FROM "informix".sd_grupo_credito_his WHERE numcte=pClienteTraspasaCtas;

            UPDATE "informix".sd_grupo_credito_his SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
        
    END IF;
    
	IF EXISTS (SELECT numcte  FROM "informix".sd_grupo_cliente WHERE numcte=pClienteTraspasaCtas) THEN
  
        LET vc_tabla = "sd_grupo_cliente";
        LET vc_detalle_mov = pClienteTraspasaCtas; 
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
			SELECT {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   'CARTERA VENDIDA',"sd_maecred_vendida",pClienteTitular,pClienteTraspasaCtas,pClienteTitular ||'|'||TRIM(num_credito)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecred_vendida WHERE numcte= pClienteTraspasaCtas;
					
            INSERT INTO bdinteg:"informix".si_fusmaecred_vendida (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT   {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecred_vendida WHERE numcte=pClienteTraspasaCtas;

            UPDATE {+INDEX (bdicred:sd_maecred_vendida idx_maecredvendida)}   "informix".sd_maecred_vendida SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;          
	
	END IF;
     --***
	 
	IF EXISTS (SELECT  num_credito  FROM "informix".sd_maecredcont_apoyo WHERE numcte=pClienteTraspasaCtas) THEN
    
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'CREDITO APOYO',"sd_maecredcont_apoyo",pClienteTitular,pClienteTraspasaCtas,pClienteTitular ||'|'||TRIM(num_credito)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE
			FROM "informix".sd_maecredcont_apoyo WHERE numcte= pClienteTraspasaCtas;
		
            INSERT INTO bdinteg:"informix".si_fusmaecredcont_apoyo (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
			SELECT fecha,empresa,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecredcont_apoyo WHERE numcte=pClienteTraspasaCtas;

            UPDATE  "informix".sd_maecredcont_apoyo SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
    
	END IF;
     --***
	
	IF EXISTS (SELECT {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   num_credito FROM "informix".sd_maecredcrd_vendida WHERE numcte=pClienteTraspasaCtas) THEN
    		
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   'CRD VENDIDA',"sd_maecredcrd_vendida",pClienteTitular,pClienteTraspasaCtas,pClienteTitular ||'|'||TRIM(num_credito)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecredcrd_vendida WHERE numcte= pClienteTraspasaCtas;
		
            INSERT INTO bdinteg:"informix".si_fusmaecredcrd_vendida (fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4)
            SELECT  {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   fecha,empresa,num_credito,num_producto,ejecutivo,numcte,aval_cte,aval_linea,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,tasa_preferencial,sobretasa_preferencial,factor_preferencial,valor_preferencial,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,actividad,tipo_calculo,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,credito_externo,califica_riesgo,cod_agricola,pagos_sostenidos,campo_trab1,campo_trab2,campo_trab3,campo_trab4
			FROM   "informix".sd_maecredcrd_vendida where numcte=pClienteTraspasaCtas;

            UPDATE  {+INDEX (bdicred:sd_maecredcrd_vendida idx_maecredcrdvendida)}   "informix".sd_maecredcrd_vendida SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
    
	END IF;
    --***
	
	IF EXISTS (SELECT {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}  num_credito FROM "informix".sd_maecredrev WHERE numcte=pClienteTraspasaCtas) THEN
	
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}   'SD_MAECREDREV',"sd_maecredrev",pClienteTitular,pClienteTraspasaCtas,TRIM(folio)||'|'||TRIM(num_credito)||'|'|| pClienteTraspasaCtas,CURRENT HOUR TO FRACTION(3),TRIM(pUsuario),CURRENT::DATE 
			FROM "informix".sd_maecredrev WHERE numcte= pClienteTraspasaCtas;
			
            INSERT INTO bdinteg:"informix".si_fusmaecredrev (empresa,folio,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2)
           SELECT  {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}   empresa,folio,num_credito,num_producto,ejecutivo,numcte,divisa,sucursal,id_origen,origen,cod_tipo_linea,cod_linea,porc_rec_prop,status_cred,bandera_renovac,bandera_prorroga,periodo_plazo,plazo,fecha_apertura,fecha_vencim,period_pago_cap,period_pag_int,dias_trasp_cap,dias_trasp_int,tasa_fija_o_var,cod_tasa_base,factor_sobretasa,sobretasa,tasa_interes,cod_tasa_mora,sobretasa_mora,fact_sobret_mora,tasa_moratorios,fecha_pago_cap,fecha_pago_int,es_fisica,bandera_fi_fo,codigo_pro,superficie,actividad,cal_edos_fin,tipo_calculo,admite_tlp,rel_garcred,id_unidad_prod,num_aper_ant,rev_tasa_var_per,dia_para_revisar,cod_prod,bandera_ministra,num_fideicomiso,credito_externo,gracia_capital,diferimiento_int,fecha_fin_prorrateo,campo_trab1,campo_trab2,campo_trab3,campo_trab4,calificacion_riesgo,cod_agricola,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,tasa_techo,cod_caract,cod_caract_2
			FROM "informix".sd_maecredrev WHERE numcte=pClienteTraspasaCtas;

            UPDATE  {+INDEX (bdicred:sd_maecredrev idx_sd_maecredrev)}    "informix".sd_maecredrev SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
    
	END IF;
    
	EXECUTE PROCEDURE bdicred:"informix".sp_traspasocuentas_cred2(pClienteTitular, pClienteTraspasaCtas, pUsuario) INTO vc_CodRet, vc_Mensaje;
	
    IF vc_CodRet = "00000" THEN
		--COMMIT WORK;
		RETURN vc_CodRet,vc_Mensaje;
	ELSE
	--Si el segundo SP devuelve un código de retorno diferente de '00000',  hará un ROLLBACK de todo el proceso
		--ROLLBACK WORK;
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
'----------------------------------------------',
'AUTOR: L. Montserrat León Amador',
'FECHA: 07/05/2020',
'MODIFICACION: Se realiza clonación de spl para eliminar BEGIN/COMMIT (error de transacción desde SOC).',
'BD: bdicred';

CREATE PROCEDURE "informix".cobraintvencido_quitas(e_fcuota DATE,
                                            e_IvaInt DECIMAL(14,2),
                                            e_Int    DECIMAL(14,2),
											g_Remanente_cq MONEY(14,2))
   RETURNING CHAR(5);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE g_Empresa       CHAR(3);
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto   CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL vIndProceso     CHAR(1)     DEFAULT ' ';    
   --DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
--   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
--   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
--   DEFINE GLOBAL g_TpPago        SMALLINT    DEFAULT 0;

   DEFINE g_ManejaLinea          CHAR(1);
   DEFINE GLOBAL g_IntVencCob    MONEY(14,2) DEFAULT 0;
--   DEFINE GLOBAL g_SdoVencInt    MONEY(14,2) DEFAULT 0;
--   DEFINE GLOBAL g_SdoVencTraInt MONEY(14,2) DEFAULT 0;
   --DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;

   DEFINE vCobro7                LIKE sd_pagocapit.monto_cuota;
   DEFINE vCobro2                LIKE sd_pagocapit.monto_cuota;
   DEFINE vCapCobrado            LIKE sd_pagocapit.monto_cuota;
   DEFINE vFechaCuota            LIKE sd_paginter.fecha_cuota;
   DEFINE vIntVenc               LIKE sd_paginter.monto_cuota;
   DEFINE vIvaVenc               LIKE sd_paginter.monto_cuota;
   DEFINE vCuotaRec              LIKE sd_paginter.cuota_rec;
   DEFINE vMontoCuota            LIKE sd_paginter.monto_cuota;
   DEFINE vMontoRealPag          LIKE sd_paginter.monto_real_pag;
   DEFINE vMontoFinanc           LIKE sd_paginter.monto_financiado;
   DEFINE vStatusCuota           LIKE sd_paginter.status_cuota;
   DEFINE vIntCob                LIKE sd_paginter.monto_cuota;
   DEFINE vIntFinan              LIKE sd_paginter.monto_cuota;
   DEFINE vIntCob7               LIKE sd_paginter.monto_cuota;
   DEFINE vIvaCob7               LIKE sd_paginter.monto_cuota;
   DEFINE vIvaCob2               LIKE sd_paginter.monto_cuota;
   DEFINE vIntCob2               LIKE sd_paginter.monto_cuota;
   DEFINE vIntdebe               LIKE sd_paginter.monto_cuota;
   DEFINE vIntIva                LIKE sd_paginter.monto_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vStatus                LIKE sd_paginter.status_cuota;
   DEFINE vStatusAnt             LIKE sd_paginter.status_cuota;
   DEFINE v_IvaIntaux            DECIMAL(14,2);
   DEFINE vStatusIva             LIKE sd_paginter.status_cuota;
   DEFINE dIvaIntVencCob         MONEY(14,2);
   DEFINE vIntVencTran           DECIMAL(14,2);
   DEFINE vIvaVencTran           DECIMAL(14,2);
   
	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "CobraIntVencido.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET CodRet = sql_err;
		RETURN CodRet;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET g_Empresa = '001';
	LET vIntCob   = 0;
	LET vIntFinan = 0;
	LET vIntCob7  = 0;
	LET vIntCob2  = 0;
	LET vIvaCob7  = 0;
	LET vIvaCob2  = 0;
	LET dIvaIntVencCob = 0;
	LET CodRet    = '000';
	LET vIntVenc  = 0;
	LET vCobro7   = 0;
	LET vCobro2   = 0;
	LET vIntdebe  = 0;
	LET vIntIva   = 0;
	LET vCapCobrado= 0;
	LET vStatus   = '';
	LET vStatusAnt= '';
	LET vCuotaRec = '';
	LET e_IvaInt  = e_IvaInt;
	LET e_Int     = e_Int;
	LET v_IvaIntaux=e_IvaInt;
	LET vReferencia = 1;
	LET vIntVencTran = 0;
	LET vIvaVencTran  = 0;
	LET g_ManejaLinea = 'S';

		IF e_IvaInt > 0  THEN
			FOREACH
				SELECT fecha_cuota,sum(iva_debe  - iva_pagado) ,iva_status,capital_status,iva_status_ant
				INTO vFechaCuota,vIntIva,vStatusIva,vStatus,vStatusAnt
				FROM "informix".sd_amortiza_credito
				WHERE empresa = g_Empresa             
				AND	num_credito = g_NumCredito      
				AND capital_status not in ('1','5') 
				AND interes_status in ('3')         
				AND nvl(iva_debe,0) - nvl(iva_pagado,0) > 0
				GROUP BY 1,3,4,5
				ORDER BY 1
				
				--LET vIntIva = vIntIva - (vIntIva * v_IntVencPorc); --Para escenario de quitas
				--LET vIvaVencTran = vIvaVencTran + vIntIva;
				
				IF v_IvaIntaux > 0 THEN
					IF (v_IvaIntaux >= vIntIva) THEN
						LET g_Remanente_cq = g_Remanente_cq - vIntIva;
						LET v_IvaIntaux = v_IvaIntaux - vIntIva;
						LET vStatusAnt = vStatusIva;
						LET vStatusIva = '5';
					ELSE
						LET vIntIva=v_IvaIntaux;
						LET v_IvaIntaux=0;
						LET g_Remanente_cq = g_Remanente_cq-vIntIva;
					END IF;

					UPDATE "informix".sd_amortiza_credito
					SET iva_pagado = iva_pagado + vIntIva,
					iva_status     = vStatusIva,
					iva_status_ant = vStatusAnt,
					iva_fecha_pago = e_fcuota
					WHERE empresa  = g_empresa    
					AND num_credito = g_NumCredito 
					AND fecha_cuota = vFechaCuota;
				END IF;
				
			END FOREACH;
			
			--Se genera transaccion para el IVA de Intereses Vencidos
			/*IF vIndProceso = 'Q' THEN
				LET vReferencia = 5;
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,'111', e_fcuota, e_IvaInt, g_Folio,g_Sucursal, g_Divisa, '8382') 
				RETURNING  CodRet, Mensaje;
				
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
					LET e_IvaInt = e_IvaInt - e_IvaInt;				
				END IF;
			END IF;*/
				 --**Movimientos Contables Por La Proporcion **--
		    --- ESTE VA AL FINAL
			--IF g_TRansacc NOT IN ('7795','7796') THEN
				/*IF vStatus = '2' THEN
					--LET vReferencia = 6640;   -- Iva Vencido Traspasado
					LET vReferencia = 1;   --Iva vencido Traspasado
					
					--g_Empresa, g_NumCredito, g_NumProducto,vReferencia,'138', e_fcuota, e_IvaInt, g_Folio,g_Sucursal, g_Divisa, '8392'
					CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,g_CodigoFun, g_Fecha, vIvaVencTran, g_Folio,g_Sucursal, g_Divisa, g_Transacc) RETURNING
					CodRet, Mensaje;
					
					IF (CodRet <> "00000") THEN
						RETURN CodRet;
					ELSE
						LET CodRet = "000";
						LET e_IvaInt = e_IvaInt - e_IvaInt;
					END IF;
					
				ELIF vStatus = '7' THEN
					--LET vReferencia = 6641;   --Iva vencido no traspasado
					LET vReferencia = 1;   --Iva vencido no traspasado
					
					CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,g_CodigoFun, g_Fecha, vIvaVencTran, g_Folio,g_Sucursal, g_Divisa, g_Transacc) RETURNING
					CodRet, Mensaje;
					
					IF (CodRet <> "00000") THEN
						RETURN CodRet;
					ELSE
						LET CodRet = "000";
						LET e_IvaInt = e_IvaInt - e_IvaInt;
					END IF;
				END IF;*/
			--END IF;
		END IF
		IF e_Int > 0 THEN

			IF (g_ManejaLinea <> 'S') THEN
				UPDATE "informix".sd_maesdos
				SET sdo_exig_int     = sdo_exig_int - e_Int,
				mto_venc_int     = mto_venc_int - e_Int,
				mto_venc_tra_int = mto_venc_tra_int - e_Int
				WHERE empresa = g_Empresa 
				AND num_credito = g_NumCredito;
			ELSE
				UPDATE "informix".sd_maesdos
				SET int_tra_no_exig = int_tra_no_exig - e_Int --original
				--SET int_tra_no_exig = 0, sdo_exig_int = 0, mto_venc_int = 0, mto_venc_tra_int = 0
				WHERE empresa     = g_Empresa 
				AND num_credito = g_NumCredito;
			END IF
			
			FOREACH				
				SELECT fecha_cuota,sum(interes_debe  - interes_pagado) ,interes_status
				INTO vFechaCuota,vIntdebe,vStatus
				FROM "informix".sd_amortiza_credito
				WHERE empresa = g_Empresa             
				AND num_credito = g_NumCredito      
				AND capital_status not in ('1','5') 
				AND interes_status in ('3')         
				AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0
				GROUP BY 1,3
				ORDER BY 1
				--LET g_Remanente = g_Remanente - e_Int;
				
				--LET vIntdebe = vIntdebe - (vIntdebe * v_IntVencPorc); --Para escenario de quitas
				--LET vIntVencTran =  vIntVencTran + vIntdebe;
				IF e_Int > 0 THEN
					--**Movimientos Contables Por La Proporcion **--
					IF g_Remanente_cq > 0 THEN
						IF vStatus = '3' THEN
							IF (g_Remanente_cq >= vIntdebe) THEN
								LET g_Remanente_cq = g_Remanente_cq - vIntdebe;
								LET vCobro2 = vCobro2 + vIntdebe;
								LET vCuotaRec = vStatus;
								LET vStatus = '5';
							ELSE
								let vCapCobrado  = vCapCobrado;
								Let g_Remanente_cq = g_Remanente_cq;
								LET vCobro2 = vCobro2;
								LET vCobro2 = vCobro2 + g_Remanente_cq;
								LET g_Remanente_cq = 0;
							END IF;
							
							LET vCapCobrado = vCapCobrado + vCobro2;

							UPDATE "informix".sd_amortiza_credito
							SET interes_pagado     = interes_pagado + vCapCobrado, --original
							interes_status     = vStatus,
							interes_status_ant = vCuotaRec,
							interes_fecha_pago = e_fcuota
							WHERE empresa     = g_empresa    
							AND num_credito = g_NumCredito 
							AND fecha_cuota = vFechaCuota;

							LET g_IntVencCob = g_IntVencCob + vCobro2;
							LET vCapCobrado = 0;
							LET vCobro2 = 0;

						END IF;
					END IF;
				END IF;
			END FOREACH;
			

			--LET vReferencia = 5;   -- Interes Vencido Traspasado
			
			--Se genera transaccion para los Intereses Vencidos
			/*IF vIndProceso = 'Q' THEN
				LET vReferencia = 4;
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,'111', e_fcuota, e_Int, g_Folio,g_Sucursal, g_Divisa, '8381') RETURNING
				CodRet, Mensaje;
				
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;*/

		--ELSE --** Pago Normal Sin Porcentaje **--
			/*FOREACH
				SELECT fecha_cuota,(interes_debe - interes_pagado),interes_status,(iva_debe - iva_pagado)
				INTO vFechaCuota, vIntVenc, vStatusCuota, vIvaVenc
				FROM "informix".sd_amortiza_credito
				WHERE empresa = g_Empresa
				AND num_credito = g_NumCredito
				AND fecha_cuota < (SELECT MIN(fecha_cuota)
									FROM "informix".sd_amortiza_credito
									WHERE empresa = g_Empresa
									AND num_credito = g_NumCredito
									AND capital_status = "1")
				AND interes_status in ('3')
				AND capital_status not in ("1",'5')  ---MOD  CAS
				AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0
				ORDER BY fecha_cuota

				IF g_TpPago = "2" AND vFechaCuota <> e_fcuota THEN
					CONTINUE FOREACH;
				END IF*/
			
				--LET vStatus = vStatusCuota;

				/*IF (g_Remanente > 0) THEN

					-- Cobra Iva
					IF (g_Remanente >= vIvaVenc) THEN
						LET g_Remanente = g_Remanente - vIvaVenc;
						
						IF (vStatusCuota = '7') THEN
							LET vIvaCob7 = vIvaCob7 + vIvaVenc;
						ELSE
							LET vIvaCob2 = vIvaCob2 + vIvaVenc;
						END IF;
						
						LET vCuotaRec = vStatusCuota;
						LET vStatusCuota = '5';
					ELSE
						LET vIvaVenc = g_Remanente;
						LET g_Remanente = 0;
						
						IF (vStatusCuota = '7') THEN
							LET vIvaCob7 = vIvaCob7 + vIvaVenc;
						ELSE
							LET vIvaCob2 = vIvaCob2 + vIvaVenc;
						END IF;

						LET vStatusCuota = vStatus;
					END IF;

					UPDATE "informix".sd_amortiza_credito
					SET iva_status_ant = vCuotaRec,
					iva_pagado     = iva_pagado + vIvaVenc,
					iva_status     = vStatusCuota,
					iva_fecha_pago = g_fecha
					WHERE empresa = g_empresa
					AND num_credito = g_NumCredito
					AND fecha_cuota = vFechaCuota;


					-- Cobra Intereses
					IF (g_Remanente >= vIntVenc) THEN
						LET g_Remanente = g_Remanente - vIntVenc;
						
						IF (vStatusCuota = '7') THEN
							LET vIntCob7 = vIntCob7 + vIntVenc;
						ELSE
							LET vIntCob2 = vIntCob2 + vIntVenc;
						END IF;
						
						LET vCuotaRec = vStatusCuota;
						LET vStatusCuota = '5';
					ELSE
						LET vIntVenc = g_Remanente;
						LET g_Remanente = 0;
						
						IF (vStatusCuota = '7') THEN
							LET vIntCob7 = vIntCob7 + vIntVenc;
						ELSE
							LET vIntCob2 = vIntCob2 + vIntVenc;
						END IF;

						LET vStatusCuota = vStatus;

					END IF;

					UPDATE "informix".sd_amortiza_credito
					SET interes_status_ant = vCuotaRec,
					interes_pagado     = interes_pagado + vIntVenc,
					interes_status     = vStatusCuota,
					interes_fecha_pago = g_fecha
					WHERE empresa = g_empresa
					AND num_credito = g_NumCredito
					AND fecha_cuota = vFechaCuota;

				END IF;
				IF (g_Remanente = 0) THEN
					EXIT FOREACH;
				END IF;
			END FOREACH;*/

			-- *****************************
			-- *         TARJETA           *
			-- *****************************
			/*IF (g_ManejaLinea <> 'S') THEN

				UPDATE "informix".sd_maesdos
				SET sdo_exig_int = sdo_exig_int - vIntCob7 - vIntCob2,
				mto_venc_int = mto_venc_int - vIntCob7,
				mto_venc_tra_int = mto_venc_tra_int - vIntCob2
				WHERE empresa = g_Empresa
				AND num_credito = g_NumCredito;

			ELSE
				UPDATE "informix".sd_maesdos
				SET int_tra_no_exig = int_tra_no_exig - vIntCob2
				WHERE empresa = g_Empresa
				AND num_credito = g_NumCredito;

			END IF*/

			/*IF (vIntCob7 > 0) AND g_Transacc NOT IN ('7795','7796') THEN
				LET vReferencia = 3;   --Interes vencido no traspasado
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIntCob7, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;*/

			/*IF (vIntCob2 > 0) AND g_Transacc NOT IN ('7795','7796') THEN

				LET vReferencia = 5;   -- Interes Vencido Traspasado
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIntCob2, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;*/
		   
			--LET g_IntVencCob = g_IntVencCob + (vIntCob7 + vIntCob2);

			/*IF (g_IntVencCob > 0) AND g_Transacc IN ('7795','7796') THEN
				-- 21062018 AAME RQM 06590 y RQM 06 591 Se contemplan los productos oro y Platino, se agrega TDC GC
				IF g_NumProducto IN ("6001","7000","8100","8500") THEN
				 
					LET vReferencia = 5;
									 
				END IF;
				 
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, g_IntVencCob, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;*/
		   
			/*IF (vIvaCob7 > 0) AND g_Transacc NOT IN ('7795','7796') THEN
				LET vReferencia = 6641;   --Iva vencido no traspasado
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIvaCob7, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;*/
		   
			/*IF (vIvaCob2 > 0) AND g_Transacc NOT IN ('7795','7796') THEN

				LET vReferencia = 6640;   -- Iva Vencido Traspasado
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, vIvaCob2, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;*/

		    --LET dIvaIntVencCob =  dIvaIntVencCob + (vIvaCob7 + vIvaCob2);
		   
			/*IF (dIvaIntVencCob > 0) AND g_Transacc IN ('7795','7796') THEN
			-- 21062018 AAME RQM 06590 y RQM 06 591 Se contemplan los productos oro y Platino, se agrega TDC GC
				IF g_NumProducto IN ("6001","7000","8100","8500") THEN
				 
					LET vReferencia = 6;

				END IF;
				 
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
									   g_CodigoFun, g_Fecha, dIvaIntVencCob, g_Folio,
									   g_Sucursal, g_Divisa, g_Transacc) RETURNING
									   CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET CodRet = "000";
				END IF;
			END IF;*/
		END IF;
	RETURN CodRet;
END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de intereses vencidos, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'VERSION:1.00.00.003',
'BD    : BDICRED',
'MODIFICACION: Se agragan transacciones 7795 y 7796 (condonacion y condonacion por fallecimiento),',
' 			   se implementan reglas de informix ',
'AUTOR : Mireya Gpe. Reyes Vargs',
'FECHA : 03-01-2014',
'VERSION :20140103.1557',
'FOLIO: 1395 - Condonacion de intereses vencidos y moratorios.',
'BD    : BDICRED';

CREATE PROCEDURE "informix".carga_movhis_edoctacrd_exp(fecha_hoy DATE, pnum_producto CHAR(4))
RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE numcredito       CHAR(20);
DEFINE icontador        INTEGER;
--
DEFINE p_empresa     	CHAR(3);
DEFINE p_secuencia   	integer;
DEFINE p_fecha_mov   	DATE ;
DEFINE p_hora_mov    	DATETIME HOUR to FRACTION(3);
DEFINE p_sucursal    	CHAR(4);
DEFINE p_num_credito 	CHAR(20);
DEFINE p_plaza       	CHAR(3);
DEFINE p_transacc_suc	CHAR(4);
DEFINE p_usuario     	CHAR(8);
DEFINE p_monto       	DECIMAL(18,2);
DEFINE p_codigo_fun  	CHAR(3);
DEFINE p_codigo_ref  	INTEGER;
DEFINE p_divisa      	CHAR(2);
DEFINE p_reversado   	CHAR(1);
DEFINE p_folio_suc   	CHAR(16);
DEFINE p_num_producto	CHAR(4);
DEFINE p_nro_tarjeta 	VARCHAR(20,1);
DEFINE p_referencia  	VARCHAR(80,1);
DEFINE p_tipo_cambio 	DECIMAL(14,6);
DEFINE p_monto_dls   	DECIMAL(14,2);
DEFINE p_suc_origen  	VARCHAR(4,1);
DEFINE p_rfc_comer   	VARCHAR(20,1);
DEFINE p_referencia23	VARCHAR(23,1);
DEFINE cBanBegin        CHAR(1);
DEFINE p_descripcion    VARCHAR(100,1);
DEFINE p_naturaleza     CHAR(1);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret   = "000";
LET vsqlerr    = 0;
LET numcredito = "";
LET icontador  = 1;
LET cBanBegin  = 'N';
LET p_descripcion = "";
LET p_naturaleza  = "";

-- Autor: Jose de Jesus Almeida
-- Fecha: 2009/07/23
-- ModificaciÃ³n: Se realiza modificaciÃ³n con la finalidad de agregar un parÃ¡metro
--               para identificar si sera la obtencion de los datos para la generaciÃ³n
--               de estados de cuenta para tarjetas de crÃ©dito o para crÃ©ditos otorgados
--               de forma reestructurada, la solicitud del cambio fue solicitada en el
--               anexo incluido en el RQM 10 105 (Edo.Cta Reestructura)

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
   	  IF cBanBegin= 'S' THEN
	     ROLLBACK WORK;
	  END IF;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "carga_movhis_edocta.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	-- ************************************************************
	-- Datos de MAEDCRED QUE DEBEN BORRARSE DE SD_AMORTIZA_CREDTO *
	-- ************************************************************

  set isolation to dirty read;
  
  	--------------------------------
	-- Se eliminan tablas temporales
	--drop table temp_movhiscrd;
	DROP TABLE IF EXISTS temp_movhiscrd;

  select * from "informix".sd_movhiscrd 
  where fecha_mov between  fecha_hoy - 1 UNITS MONTH and fecha_hoy
    and num_credito in (select num_credito from "informix".sd_maecredcrd where num_producto = pnum_producto)
	into temp temp_movhiscrd with no log;

  create index inx1_temp_movhiscrd on temp_movhiscrd(codigo_fun, codigo_ref);
  create index inx2_temp_movhiscrd on temp_movhiscrd(fecha_mov, num_producto, reversado);
  update statistics medium for table temp_movhiscrd;

  FOREACH WITH HOLD


                SELECT a.empresa,			a.secuencia,			   a.fecha_mov,
                       a.hora_mov,			a.sucursal,                a.num_credito,
                       a.plaza,				a.transacc_suc,			   a.usuario,
                       a.monto,             a.codigo_fun,			   a.codigo_ref,
                       a.divisa,			a.reversado,			   a.folio_suc,
                       a.num_producto,      a.nro_tarjeta,			   a.referencia,
                       a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
                       a.rfc_comer,			a.referencia23,     TRIM(b.descripcion),
                       c.naturaleza
                  INTO
                       p_empresa,           p_secuencia,               p_fecha_mov,
                       p_hora_mov,          p_sucursal,                p_num_credito,
                       p_plaza,             p_transacc_suc,            p_usuario,
                       p_monto,             p_codigo_fun,              p_codigo_ref,
                       p_divisa,            p_reversado,               p_folio_suc,
                       p_num_producto,      p_nro_tarjeta,             p_referencia,
                       p_tipo_cambio,       p_monto_dls,               p_suc_origen,
                       p_rfc_comer,         p_referencia23,            p_descripcion,
                       p_naturaleza
                 FROM temp_movhiscrd a,"informix".sd_transfun b, bdinteg:si_transacc  c
                WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
                  AND c.numero = b.transacc AND c.se_emite_edocta = "S"
                  AND fecha_mov >= case
                  WHEN date(fecha_hoy - 1 UNITS MONTH) = (select fecha_apertura from bdicred:sd_maecredcrd where a.empresa = empresa  and a.num_credito = num_credito)
                  THEN date(fecha_hoy - 1 UNITS MONTH)
                  ELSE date(fecha_hoy - 1 UNITS MONTH + 1 units day) end
                  AND fecha_mov <= fecha_hoy
                  AND a.reversado = "N"
                  AND c.se_emite_edocta = "S"
				  AND c.sistema ="06" --Se agrega el sistema 06 a la validacion
                  AND a.num_producto = pnum_producto

          BEGIN WORK;
                INSERT INTO "informix".sd_movhisedoctacrd
                     VALUES (p_empresa, p_secuencia, p_fecha_mov, p_hora_mov, p_sucursal, p_num_credito, p_plaza, p_transacc_suc, p_usuario, p_monto, p_codigo_fun, p_codigo_ref, p_divisa, p_reversado, p_folio_suc, p_num_producto, p_nro_tarjeta, p_referencia, p_tipo_cambio, p_monto_dls, p_suc_origen, p_rfc_comer, p_referencia23,p_descripcion,p_naturaleza);
          COMMIT WORK;

  END FOREACH
	
  UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_movhisedoctacrd;

  RETURN scod_ret;
END
END PROCEDURE;