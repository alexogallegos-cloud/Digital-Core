CREATE PROCEDURE "informix".sp_traspasocuentas_cap_soc(pClienteTitular CHAR(20),pClienteTraspasaCtas CHAR(20),pUsuario CHAR(8))
	RETURNING CHAR(5),CHAR(80);
	
	DEFINE vc_CodRet    CHAR(5);
	DEFINE vi_SqlErr    INTEGER;
	DEFINE vi_iSAMErr   INTEGER;
	DEFINE vi_iSAMData  CHAR(80);
	DEFINE vc_Mensaje   CHAR(80);
	DEFINE vd_FechaHoy  DATE;
	DEFINE vc_AnioMes   CHAR(6);
	DEFINE vc_rfc      	CHAR(13);
	DEFINE vc_proceso   CHAR(50);
	DEFINE vc_tabla     CHAR(30);
	DEFINE vc_detalle_mov  CHAR(200);
	DEFINE vc_detalle_mov2 CHAR(200);
	DEFINE vc_Cuenta    CHAR(20);
	DEFINE vcont 		INTEGER;
	DEFINE dtFechaInsercion DATETIME HOUR TO FRACTION;
	DEFINE iSecuencia	INTEGER;
	DEFINE cSucursal 	CHAR(4);
	DEFINE dFecha_alta 	DATE;
	DEFINE cDmapa , cImapa CHAR(942);
	DEFINE cIpHost	CHAR(15);
	DEFINE cUsuario	CHAR(8);
	DEFINE cNumcte_ref CHAR(20);
	DEFINE  cTipoCliente, cSexo CHAR(1);
	DEFINE iContador INTEGER;
	DEFINE iConth INTEGER;
	DEFINE iMaxsec INTEGER;
	DEFINE iConhc INTEGER;
	DEFINE iSecuenciahr INTEGER;
	DEFINE isecdecode INTEGER;
	
	DEFINE cDetalle_mov CHAR(41);
	
	LET vc_CodRet = "00000";
	LET vi_SqlErr = 0;
	LET vi_iSAMErr= 0;
	LET vi_iSAMData="";
	LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
	LET vd_FechaHoy = "";
	LET vc_AnioMes = "";
	LET vc_rfc = "";
	LET vc_proceso = "FusionClientes";
	LET vc_tabla = "";
	LET vc_detalle_mov = "";
	LET vc_detalle_mov2 = "";
	LET vc_Cuenta = "";
	LET vcont=0;
	LET iContador = 0;
	LET iConth = 0;
	LET iMaxsec = 0;
	LET iConhc = 0;
	LET iSecuenciahr = 0;
	LET isecdecode = 0;
	
	LET cDetalle_mov="";
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_traspasocuentas_cap_soc.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		--BEGIN WORK;
		BEGIN
		
		ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
			IF vi_SqlErr <> 0 THEN
				LET vc_CodRet = vi_SqlErr;
				LET vc_Mensaje = "ERROR NO CONTROLADO";
				--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
				LET dtFechaInsercion=CURRENT;
				--ROLLBACK WORK;
				LET vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData;
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES (vc_proceso,vc_tabla,pClienteTitular,pClienteTraspasaCtas,vc_detalle_mov2,dtFechaInsercion,pUsuario,dtFechaInsercion::DATE);
				RETURN vc_CodRet,vc_Mensaje;
			END IF;
		END EXCEPTION;
		
		DELETE {+INDEX (bdinteg:fusdirecciones idxdircte)} bdinteg:fusdirecciones
		WHERE numcte IS NOT NULL;
		
		SELECT fecha_hoy
		INTO vd_FechaHoy
		FROM bdinteg:si_fechas
		WHERE empresa='001';
		
		--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
		LET dtFechaInsercion=CURRENT;
		
		LET vc_AnioMes = SUBSTRING(vd_FechaHoy from 7 for 10)||SUBSTRING(vd_FechaHoy from 1 for 2);
		

		SELECT {+INDEX (bdinteg:si_cliente 224_479)} empresa,numcte,status_cte,sucursal,ejecutivo,tpo_persona,tipo_cliente,apell_paterno,apell_materno,nombre1,nombre2,razon_social,
			rfc,sector,segmento,actividad_princ,grupo,subgrupo,residencia,fecha_alta,apell_casada,distrito,numcte_ref,string1,string2,numeric1,
			numeric2,money1,date1,puesto_ppes,familiar_ppes,actividad_esp,ejecut_autoriza,user_insert,fecha_insert,rfc_alterno, tpo_biometria, cliente_pros
		FROM informix.si_cliente
		WHERE numcte = pClienteTraspasaCtas
		INTO TEMP tmp_si_cliente WITH NO LOG;

		INSERT INTO bdinteg:si_fuscliente(empresa,numcte,status_cte,sucursal,ejecutivo,tpo_persona,tipo_cliente,apell_paterno,apell_materno,nombre1,nombre2,razon_social,
		rfc,sector,segmento,actividad_princ,grupo,subgrupo,residencia,fecha_alta,apell_casada,distrito,numcte_ref,string1,string2,numeric1,
		numeric2,money1,date1,puesto_ppes,familiar_ppes,actividad_esp,ejecut_autoriza,user_insert,fecha_insert,rfc_alterno, tpo_biometria, cliente_pros)
		SELECT empresa,numcte,status_cte,sucursal,ejecutivo,tpo_persona,tipo_cliente,apell_paterno,apell_materno,nombre1,nombre2,razon_social,
		rfc,sector,segmento,actividad_princ,grupo,subgrupo,residencia,fecha_alta,apell_casada,distrito,numcte_ref,string1,string2,numeric1,
		numeric2,money1,date1,puesto_ppes,familiar_ppes,actividad_esp,ejecut_autoriza,user_insert,fecha_insert,rfc_alterno, tpo_biometria, cliente_pros
		FROM informix.tmp_si_cliente;

		DROP TABLE tmp_si_cliente;
		
		SELECT {+INDEX (bdinteg:si_ctepf 225_483)} empresa,numcte,fecha_nac,lugar_nac,nacionalidad,no_fm3,estado_civil,regim_matrimonio,profesion,sexo,
		       curp,codidentifi,numidentifi,no_imss,dependientes,tutor,nom_conyuge,seguro_defunc,escolaridad,habita_en,anios_habita,nombre_prop,imp_hipo_renta,
			   actividadogiro,numeroife,numerotutor,numeroconyuge,string1,string2,numeric1,numeric2,money1,date1,user_insert,fecha_insert,sms_cel, hora_insert,validacurp,id_pais
		FROM bdinteg:si_ctepf
		WHERE numcte = pClienteTraspasaCtas
		INTO TEMP tmp_si_ctepf WITH NO LOG;
		
		INSERT INTO bdinteg:si_fusctepf (empresa,numcte,fecha_nac,lugar_nac,nacionalidad,no_fm3,estado_civil,regim_matrimonio,profesion,sexo,
					curp,codidentifi,numidentifi,no_imss,dependientes,tutor,nom_conyuge,seguro_defunc,escolaridad,habita_en,anios_habita,nombre_prop,imp_hipo_renta,
					actividadogiro,numeroife,numerotutor,numeroconyuge,string1,string2,numeric1,numeric2,money1,date1,user_insert,fecha_insert,sms_cel,hora_insert,validacurp,id_pais)
		SELECT empresa,numcte,fecha_nac,lugar_nac,nacionalidad,no_fm3,estado_civil,regim_matrimonio,profesion,sexo,
		       curp,codidentifi,numidentifi,no_imss,dependientes,tutor,nom_conyuge,seguro_defunc,escolaridad,habita_en,anios_habita,nombre_prop,imp_hipo_renta,
			   actividadogiro,numeroife,numerotutor,numeroconyuge,string1,string2,numeric1,numeric2,money1,date1,user_insert,fecha_insert,sms_cel, hora_insert,validacurp,id_pais
		FROM tmp_si_ctepf;	   

		DROP TABLE tmp_si_ctepf;
		
		SELECT {+INDEX (bdicheq:sc_maechq mae1)} COUNT(*)
		INTO iContador
		FROM bdicheq:sc_maechq
		WHERE num_cte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_tabla ='sc_maechq';
			LET vc_proceso='CUENTAS DE CHEQUES';
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			
			FOREACH 			
			SELECT {+INDEX (bdicheq:sc_maechq mae1)} cuenta INTO vc_Cuenta FROM bdicheq:sc_maechq WHERE num_cte = pClienteTraspasaCtas
				
				LET vc_Cuenta = TRIM(vc_Cuenta);
				
				SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(vc_Cuenta)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_maechq 
				WHERE cuenta = vc_Cuenta AND empresa = '001'
				INTO TEMP tmp_sc_maechq_log WITH NO LOG;			
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_maechq_log;
				
				DROP TABLE tmp_sc_maechq_log;

				
				SELECT {+INDEX (bdicheq:sc_maechq 174_183)} empresa,cuenta,sucursal,plaza,producto,num_cte,status_cta,motivo,ult_chq,colateral,fec_ult_mov,fec_cancelac,lim_chq_sbc,imp_chq_sbc,fech_alta_sbc,
					fech_venc_sbc,lim_chq_rem,imp_chq_rem,fech_alta_rem,fech_venc_rem,lim_sbg_ccc,imp_sbg_ccc,tipo_linea,fec_alta_ccc,fech_venc_ccc,imp_int_ccc,sdo_retenido,
					chq_exp_mes,chq_dev,monto_dev,chq_dev_obco,sdo_cong,num_cgos_mes,imp_cgos_mes,num_abonos_mes,imp_abonos_mes,sdo_actual,sdo_dia_ant,marca_ret,direcc_envio,
					com_pendiente,imp_chq_sbg,imp_int_sbg,fecha_proceso,cuenta_rel,saldo_sbc,fecultdep,fecultret,ultpagocap,ultpagoint,plazo,cobraisr,proced_aperturacta,
					proced_mantenercta,monto_mensual,depositos_cantidad,depositos_monto,retiros_cantidad,retiros_monto,cuenta_clabe
				FROM bdicheq:sc_maechq
				WHERE cuenta = vc_Cuenta
				INTO TEMP tmp_sc_maechq WITH NO LOG;
				
				INSERT INTO bdinteg:si_fusmaechq(empresa,cuenta,sucursal,plaza,producto,num_cte,status_cta,motivo,ult_chq,colateral,fec_ult_mov,fec_cancelac,lim_chq_sbc,imp_chq_sbc,fech_alta_sbc,
					fech_venc_sbc,lim_chq_rem,imp_chq_rem,fech_alta_rem,fech_venc_rem,lim_sbg_ccc,imp_sbg_ccc,tipo_linea,fec_alta_ccc,fech_venc_ccc,imp_int_ccc,sdo_retenido,
					chq_exp_mes,chq_dev,monto_dev,chq_dev_obco,sdo_cong,num_cgos_mes,imp_cgos_mes,num_abonos_mes,imp_abonos_mes,sdo_actual,sdo_dia_ant,marca_ret,direcc_envio,
					com_pendiente,imp_chq_sbg,imp_int_sbg,fecha_proceso,cuenta_rel,saldo_sbc,fecultdep,fecultret,ultpagocap,ultpagoint,plazo,cobraisr,proced_aperturacta,
					proced_mantenercta,monto_mensual,depositos_cantidad,depositos_monto,retiros_cantidad,retiros_monto,cuenta_clabe)
					SELECT empresa,cuenta,sucursal,plaza,producto,num_cte,status_cta,motivo,ult_chq,colateral,fec_ult_mov,fec_cancelac,lim_chq_sbc,imp_chq_sbc,fech_alta_sbc,
					fech_venc_sbc,lim_chq_rem,imp_chq_rem,fech_alta_rem,fech_venc_rem,lim_sbg_ccc,imp_sbg_ccc,tipo_linea,fec_alta_ccc,fech_venc_ccc,imp_int_ccc,sdo_retenido,
					chq_exp_mes,chq_dev,monto_dev,chq_dev_obco,sdo_cong,num_cgos_mes,imp_cgos_mes,num_abonos_mes,imp_abonos_mes,sdo_actual,sdo_dia_ant,marca_ret,direcc_envio,
					com_pendiente,imp_chq_sbg,imp_int_sbg,fecha_proceso,cuenta_rel,saldo_sbc,fecultdep,fecultret,ultpagocap,ultpagoint,plazo,cobraisr,proced_aperturacta,
					proced_mantenercta,monto_mensual,depositos_cantidad,depositos_monto,retiros_cantidad,retiros_monto,cuenta_clabe
				FROM tmp_sc_maechq;
				
				DROP TABLE tmp_sc_maechq;

				--	
				UPDATE {+INDEX (bdicheq:sc_maechq 174_183)} bdicheq:sc_maechq
				SET num_cte = pClienteTitular
				WHERE cuenta = vc_Cuenta
				AND empresa='001';
				
				SELECT {+INDEX (bdicheq:sc_maehis idx_maehis2)} COUNT(*)
				INTO iContador
				FROM bdicheq:sc_maehis 
				WHERE cuenta  = vc_Cuenta;
				
				IF ( iContador >= 1 ) THEN
				
					LET vc_proceso='ESTADO DE CUENTA';
					LET vc_tabla = "sc_maehis";
					
					--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
					LET dtFechaInsercion=CURRENT;
						
					SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(vc_Cuenta)||"|"||TRIM(aniomes)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_maehis 
					WHERE empresa = '001' AND cuenta = vc_Cuenta
					INTO TEMP tmp_sc_maehis_log WITH NO LOG;			
					
					INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_maehis_log;	
					
					DROP TABLE tmp_sc_maehis_log;
------------------					
					
					SELECT {+INDEX (bdicheq:sc_maehis maehis2)} empresa,aniomes,cuenta,fechaini,fechafin,cuenta_clabe,num_tarjeta,sucursal,producto,num_cte,status_cta,
						motivo,fec_cancelac,sdo_retenido,sdo_cong,sdo_actual,envio_direcc,direcc_envio,sdo_mes_ant,acum_sdo_pos,dia_sdo_pos,acum_sdo_int,dias_acum_int,
						tasabruta,ret_mes_ant,cong_mes_ant,limccc_fin_mes,impccc_fin_mes,impsbg_fin_mes,impsbc_fin_mes,int_acum,isr_acum,totdepositos,totretiros,
						totintpag,totcomcobrada,totivacobrado,totisrcobrado,totretirosefec,tototroscargos,gat, gat_real
					FROM bdicheq:sc_maehis
					WHERE empresa='001'
					AND cuenta IN (SELECT {+INDEX (bdicheq:sc_maechq 174_183)} cuenta FROM bdicheq:sc_maechq WHERE num_cte = pClienteTitular and cuenta = vc_Cuenta)
					INTO TEMP tmp_sc_maehis WITH NO LOG;
					
					INSERT INTO bdinteg:si_fusmaehis(empresa,aniomes,cuenta,fechaini,fechafin,cuenta_clabe,num_tarjeta,sucursal,producto,num_cte,status_cta,
					motivo,fec_cancelac,sdo_retenido,sdo_cong,sdo_actual,envio_direcc,direcc_envio,sdo_mes_ant,acum_sdo_pos,dia_sdo_pos,acum_sdo_int,dias_acum_int,
					tasabruta,ret_mes_ant,cong_mes_ant,limccc_fin_mes,impccc_fin_mes,impsbg_fin_mes,impsbc_fin_mes,int_acum,isr_acum,totdepositos,totretiros,
					totintpag,totcomcobrada,totivacobrado,totisrcobrado,totretirosefec,tototroscargos,gat, gat_real)
					SELECT empresa,aniomes,cuenta,fechaini,fechafin,cuenta_clabe,num_tarjeta,sucursal,producto,num_cte,status_cta,
						motivo,fec_cancelac,sdo_retenido,sdo_cong,sdo_actual,envio_direcc,direcc_envio,sdo_mes_ant,acum_sdo_pos,dia_sdo_pos,acum_sdo_int,dias_acum_int,
						tasabruta,ret_mes_ant,cong_mes_ant,limccc_fin_mes,impccc_fin_mes,impsbg_fin_mes,impsbc_fin_mes,int_acum,isr_acum,totdepositos,totretiros,
						totintpag,totcomcobrada,totivacobrado,totisrcobrado,totretirosefec,tototroscargos,gat, gat_real
					FROM tmp_sc_maehis;
					
					DROP TABLE tmp_sc_maehis;
					
------------------------					
					--Se modifico el INSERT y el UPDATE, para realizarlos por cuenta
					UPDATE {+INDEX (bdicheq:sc_maehis maehis2)} bdicheq:sc_maehis
					SET num_cte = pClienteTitular
					WHERE empresa='001'
					AND cuenta = vc_Cuenta;
					
				END IF;
			END FOREACH;
		END IF;
		
		SELECT {+INDEX (bdicheq:sc_beneficiario idx_cte_benef)} COUNT(*)
		INTO iContador		
		FROM bdicheq:sc_beneficiario
		WHERE numcte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='BENEFICIARIO';
			LET vc_tabla ='sc_beneficiario';
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			
				SELECT vc_proceso as proceso,vc_tabla as tabla,pClienteTitular as cliente_tit,pClienteTraspasaCtas as cliente_tras,TRIM(cuenta)||"|"||secuencia||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,pUsuario as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_beneficiario 
				WHERE numcte = pClienteTraspasaCtas
				INTO TEMP tmp_sc_beneficiario_log WITH NO LOG;			
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_beneficiario_log;
			
				DROP TABLE tmp_sc_beneficiario_log;
			
			SELECT {+INDEX (bdicheq:sc_beneficiario idx_cte_benef)} empresa,cuenta,secuencia,nombre,parentesco,porcentaje,numcte
			FROM bdicheq:sc_beneficiario WHERE numcte = pClienteTraspasaCtas
			INTO TEMP tmp_sc_beneficiario WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusbeneficiario(empresa,cuenta,secuencia,nombre,parentesco,porcentaje,numcte)
			SELECT empresa,cuenta,secuencia,nombre,parentesco,porcentaje,numcte
			FROM tmp_sc_beneficiario;

			DROP TABLE tmp_sc_beneficiario;
			
			UPDATE {+INDEX (bdicheq:sc_beneficiario idx_cte_benef)} bdicheq:sc_beneficiario
			SET numcte = pClienteTitular
			WHERE numcte = pClienteTraspasaCtas;
		END IF;

		SELECT {+INDEX (bdicheq:sc_firmantes fir2)} COUNT(*)
		INTO iContador		
		FROM bdicheq:sc_firmantes 
		WHERE numcte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='FIRMANTES';
			LET vc_tabla ='sc_firmantes';
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			
			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta)||"|"||secuencia||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_firmantes 
			WHERE numcte = pClienteTraspasaCtas
			INTO TEMP tmp_sc_firmantes_log WITH NO LOG;			
			
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_firmantes_log;
			
			DROP TABLE tmp_sc_firmantes_log;
			
			SELECT {+INDEX (bdicheq:sc_firmantes fir2)} empresa,cuenta,secuencia,numcte,apellidos,nombre,reg_firma,tipo_firma,combinacion,parentesco
			FROM bdicheq:sc_firmantes
			WHERE numcte = pClienteTraspasaCtas
			INTO TEMP tmp_sc_firmantes WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusfirmantes(empresa,cuenta,secuencia,numcte,apellidos,nombre,reg_firma,tipo_firma,combinacion,parentesco)
			SELECT empresa,cuenta,secuencia,numcte,apellidos,nombre,reg_firma,tipo_firma,combinacion,parentesco
			FROM tmp_sc_firmantes;

			DROP TABLE tmp_sc_firmantes;
			
			UPDATE {+INDEX (bdicheq:sc_firmantes fir2)} bdicheq:sc_firmantes
			SET numcte = pClienteTitular
			WHERE numcte = pClienteTraspasaCtas;
			
		END IF;
		
		SELECT {+INDEX (bdicheq:sc_tarjeta ix_tarjeta3)} COUNT(*)
		INTO iContador
		FROM bdicheq:sc_tarjeta
		WHERE numcte = pClienteTraspasaCtas AND cuenta IS NOT NULL;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='TARJETAS';
			LET vc_tabla ='sc_tarjeta';
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
						
			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta)||"|"||TRIM(pClienteTraspasaCtas)||"|"||secuencia||"|"||TRIM(num_tarjeta) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_tarjeta 
			WHERE numcte = pClienteTraspasaCtas AND cuenta IS NOT NULL
			INTO TEMP tmp_sc_tarjeta_log WITH NO LOG;			
			
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_tarjeta_log;

			DROP TABLE tmp_sc_tarjeta_log;
			
			LET vc_proceso='INTERCARD';
			LET vc_tabla = "intercard";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
						
			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta)||"|"||TRIM(pClienteTraspasaCtas)||"|"||secuencia||"|"||TRIM(num_tarjeta) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_tarjeta 
			WHERE numcte = pClienteTraspasaCtas AND cuenta IS NOT NULL
			INTO TEMP tmp_sc_tarjeta_log2 WITH NO LOG;			
				
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_tarjeta_log2;
			
			DROP TABLE tmp_sc_tarjeta_log2;
			
			--Se agregan los campo: bandera_cobro,bandera_bonificacion,cobro_tarjeta,iva_cobrotar,fecha_insert

			
			SELECT {+INDEX (bdicheq:sc_tarjeta ix_tarjeta3)} empresa,cuenta,secuencia,num_tarjeta,numcte,prodtarjeta,expiracion,tipo_tarjeta,nombre,status_tar,limite_aut,
				disp_mes,motivo,tipo_asignacion,cobro_comision,gerente_autoriza,bandera_cobro,bandera_bonificacion,cobro_tarjeta,iva_cobrotar,fecha_insert
			FROM bdicheq:sc_tarjeta
			WHERE numcte = pClienteTraspasaCtas
			AND cuenta IS NOT NULL
			INTO TEMP tmp_si_fustarjetadeb WITH NO LOG;
			
			INSERT INTO bdinteg:si_fustarjetadeb(empresa,cuenta,secuencia,num_tarjeta,numcte,prodtarjeta,expiracion,tipo_tarjeta,nombre,status_tar,limite_aut,
			disp_mes,motivo,tipo_asignacion,cobro_comision,gerente_autoriza,bandera_cobro,bandera_bonificacion,cobro_tarjeta,iva_cobrotar,fecha_insert)
			SELECT empresa,cuenta,secuencia,num_tarjeta,numcte,prodtarjeta,expiracion,tipo_tarjeta,nombre,status_tar,limite_aut,
			disp_mes,motivo,tipo_asignacion,cobro_comision,gerente_autoriza,bandera_cobro,bandera_bonificacion,cobro_tarjeta,iva_cobrotar,fecha_insert
			FROM tmp_si_fustarjetadeb;	
			
			DROP TABLE tmp_si_fustarjetadeb;
										
			SELECT {+INDEX (intercard:tarjeta idx_numcte)} numtarjeta,codstatustarjeta,codproductotarjeta,numcliente,titular,a.nombre,direccion,coldeleg,ciudad,estado,codpostal,telcasa,teloficina,fechaexp,
				sefabricaplastico,seimprimenip,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,
				acummenscompraposnac,acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,acumcomcompraposnac,acumcomcompraposint,
				acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,contcomretatmnac,
				contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,
				conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,contmaxtranretatmdiarias,contmaxtrancompraposdiarias,
				contmaxtranconsatmmens,contmaxtranretatmmens,contmaxtrancompraposmens,numerolote,contmaxtranretatmnachd,contmaxtrancompraposnachd,contmaxtranretatminthd,
				contmaxtrancompraposinthd,usuarioultmodif,fechaultmodif,acumretatmnachd,acumretatminthd,acumcompraposnachd,acumcompraposinthd,numreporte,enrenovacion,
				fechaexprenovacion,numtarjetasustituta,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,acumcomretatmpropio,acumcomrevatmpropio,
				contcomconsatmpropio,contcomretatmpropio,contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,
				contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,contmaxtranretatmpropiohd,acumretatmpropiohd,nombrecorto,
				fechanacimiento,nombrepromotor,cobracomreexptrj,cobracomreimpnip,idpaq,codstatusasignada,fechaasignacion,acumdiariocashbacknac,acummenscashbacknac,
				acumdiariocashadvancenac,acummenscashadvancenac,conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,
				contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,soportetranatmcajerored,contnipinvalido,
				acumdiarioretatmconvenio,acummensualretatmconvenio,acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,
				contcomretatmconvenio,contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,contmaxtranconsatmdconveniodiarias,
				contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,contmaxtranretatmconveniomens,soportatranatmcajerointernacional,limitemenscompraposnac,
				limitemenscompraposint,numeroguia,acumdiarioqps,acumdiariocat,acumdiariomotovoz,acumdiariomotoint,acummensualmotovoz,acummensualmotoint,conttransmotovozdiario,
				conttransmotointdiario,conttransmotovozmensual,conttransmotointmensual
			FROM intercard:tarjeta a, bdicheq:sc_tarjeta b
			WHERE a.numcliente = pClienteTraspasaCtas
			AND a.numcliente = b.numcte
			AND a.numtarjeta = b.num_tarjeta
			INTO TEMP tmp_si_fusintercardtarjeta WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusintercardtarjeta(numtarjeta, codstatustarjeta, codproductotarjeta, numcliente, titular, nombre, direccion, coldeleg, ciudad, estado, codpostal, telcasa, teloficina, fechaexp,
			sefabricaplastico, seimprimenip, acumdiarioretatmnac, acumdiarioretatmint, acummensretatmnac, acummensretatmint, acumdiariocompraposnac, acumdiariocompraposint,
			acummenscompraposnac, acummenscompraposint, acumcomconsatmnac, acumcomconsatmint, acumcomretatmnac, acumcomretatmint, acumcomcompraposnac, acumcomcompraposint,
			acumcomrevatmnac, acumcomrevatmint, acumcomrevposnac, acumcomrevposint, acumcomfzdaposnac, acumcomfzdaposint, contcomconsatmnac, contcomconsatmint, contcomretatmnac,
			contcomretatmint, contcomcompraposnac, contcomcompraposint, contcomrevatmnac, contcomrevatmint, contcomrevposnac, contcomrevposint, contcomfzdaposnac, contcomfzdaposint,
			conttranconsatmlibres, conttranretatmlibres, conttrancompraposlibres, contmaxtranconsatmdiarias, contmaxtranretatmdiarias, contmaxtrancompraposdiarias,
			contmaxtranconsatmmens, contmaxtranretatmmens, contmaxtrancompraposmens, numerolote, contmaxtranretatmnachd, contmaxtrancompraposnachd, contmaxtranretatminthd,
			contmaxtrancompraposinthd, usuarioultmodif, fechaultmodif, acumretatmnachd, acumretatminthd, acumcompraposnachd, acumcompraposinthd, numreporte, enrenovacion,
			fechaexprenovacion, numtarjetasustituta, acumdiarioretatmpropio, acummensretatmpropio, acumcomconsatmpropio, acumcomretatmpropio, acumcomrevatmpropio,
			contcomconsatmpropio, contcomretatmpropio, contcomrevatmpropio, conttranconsatmlibrespropio, conttranretatmlibrespropio, contmaxtranconsatmdiariopropio,
			contmaxtranretatmdiariaspropio, contmaxtranconsatmmenspropio, contmaxtranretatmmenspropio, contmaxtranretatmpropiohd, acumretatmpropiohd, nombrecorto,
			fechanacimiento, nombrepromotor, cobracomreexptrj, cobracomreimpnip, idpaq, codstatusasignada, fechaasignacion, acumdiariocashbacknac, acummenscashbacknac,
			acumdiariocashadvancenac, acummenscashadvancenac, conttrancashbacklibres, conttrancashadvancelibres, contmaxtrancashbackdiarias, contmaxtrancashadvancediarias,
			contmaxtrancashbackmens, contmaxtrancashadvancemens, soportatranatmcajeropropio, soportatranatmcajeroconvenio, soportetranatmcajerored, contnipinvalido,
			acumdiarioretatmconvenio, acummensualretatmconvenio, acumcomconsatmconvenio, acumcomretatmconvenio, acumcomrevatmconvenio, contcomconsatmconvenio,
			contcomretatmconvenio, contcomrevatmconvenio, conttranconsatmconveniolibres, conttranretatmconveniolibres, contmaxtranconsatmdconveniodiarias,
			contmaxtranretatmconveniodiarias, contmaxtranconsatmconveniomens, contmaxtranretatmconveniomens, soportatranatmcajerointernacional, limitemenscompraposnac,
			limitemenscompraposint, numeroguia, acumdiarioqps, acumdiariocat, acumdiariomotovoz, acumdiariomotoint, acummensualmotovoz, acummensualmotoint, conttransmotovozdiario,
			conttransmotointdiario, conttransmotovozmensual, conttransmotointmensual)
			SELECT numtarjeta,codstatustarjeta,codproductotarjeta,numcliente,titular,nombre,direccion,coldeleg,ciudad,estado,codpostal,telcasa,teloficina,fechaexp,
				sefabricaplastico,seimprimenip,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,
				acummenscompraposnac,acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,acumcomcompraposnac,acumcomcompraposint,
				acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,contcomretatmnac,
				contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,
				conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,contmaxtranretatmdiarias,contmaxtrancompraposdiarias,
				contmaxtranconsatmmens,contmaxtranretatmmens,contmaxtrancompraposmens,numerolote,contmaxtranretatmnachd,contmaxtrancompraposnachd,contmaxtranretatminthd,
				contmaxtrancompraposinthd,usuarioultmodif,fechaultmodif,acumretatmnachd,acumretatminthd,acumcompraposnachd,acumcompraposinthd,numreporte,enrenovacion,
				fechaexprenovacion,numtarjetasustituta,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,acumcomretatmpropio,acumcomrevatmpropio,
				contcomconsatmpropio,contcomretatmpropio,contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,
				contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,contmaxtranretatmpropiohd,acumretatmpropiohd,nombrecorto,
				fechanacimiento,nombrepromotor,cobracomreexptrj,cobracomreimpnip,idpaq,codstatusasignada,fechaasignacion,acumdiariocashbacknac,acummenscashbacknac,
				acumdiariocashadvancenac,acummenscashadvancenac,conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,
				contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,soportetranatmcajerored,contnipinvalido,
				acumdiarioretatmconvenio,acummensualretatmconvenio,acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,
				contcomretatmconvenio,contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,contmaxtranconsatmdconveniodiarias,
				contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,contmaxtranretatmconveniomens,soportatranatmcajerointernacional,limitemenscompraposnac,
				limitemenscompraposint,numeroguia,acumdiarioqps,acumdiariocat,acumdiariomotovoz,acumdiariomotoint,acummensualmotovoz,acummensualmotoint,conttransmotovozdiario,
				conttransmotointdiario,conttransmotovozmensual,conttransmotointmensual
			FROM tmp_si_fusintercardtarjeta;
			
			DROP TABLE tmp_si_fusintercardtarjeta;
			--AND numtarjeta IN (SELECT num_tarjeta FROM bdicheq:sc_tarjeta WHERE numcte = pClienteTraspasaCtas);
			
			UPDATE {+INDEX (intercard:tarjeta idx_numcte)} intercard:tarjeta
			SET numcliente = pClienteTitular
			WHERE numcliente = pClienteTraspasaCtas
			AND numtarjeta IN (SELECT {+INDEX (bdicheq:sc_tarjeta ix_tarjeta3)} num_tarjeta FROM bdicheq:sc_tarjeta WHERE numcte = pClienteTraspasaCtas);
			
			UPDATE {+INDEX (bdicheq:sc_tarjeta ix_tarjeta3)} bdicheq:sc_tarjeta
			SET numcte = pClienteTitular
			WHERE numcte = pClienteTraspasaCtas
			AND cuenta IS NOT NULL;
			
		END IF;
		
		SELECT {+INDEX (bdinvers:sv_maeinv mai3)} COUNT(*)
		INTO iContador		
		FROM bdinvers:sv_maeinv
		WHERE num_cte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='INVERSIONES';
			LET vc_tabla = "sv_maeinv";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
						
			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta)||"|"||TRIM(pClienteTraspasaCtas)||"|"||secuencia as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinvers:sv_maeinv 
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_sv_maeinv_log WITH NO LOG;			
				
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sv_maeinv_log;
				
			DROP TABLE tmp_sv_maeinv_log;	
	
			SELECT {+INDEX (bdinvers:sv_maeinv mai3)}
				empresa,cuenta,secuencia,cod_instrum,num_cte,status_cta,motivo,fec_ult_mov,fec_cancelac,fec_reinversion,capital,sdo_retenido,sdo_cong,plazo,fecha_venc,
				opcion_retiro,intereses,isr,tasa,sobretasa,dia_sdo_pos,acum_sdo_pos,sdo_prom_mesant,sdo_mes_ant,sdo_dia_ant,sdo_ult_corte,adicionado,fecha_alta,fecha_val,
				modificado,fecha_mod,cta_cheques,sucursal,plaza,promotor,tipo_banca,reg_firmas,envio,direcc_envio,cobraisr,per_acred_int
			FROM bdinvers:sv_maeinv
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_si_fusmaeinv WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusmaeinv(empresa,cuenta,secuencia,cod_instrum,num_cte,status_cta,motivo,fec_ult_mov,fec_cancelac,fec_reinversion,capital,sdo_retenido,sdo_cong,plazo,fecha_venc,
			opcion_retiro,intereses,isr,tasa,sobretasa,dia_sdo_pos,acum_sdo_pos,sdo_prom_mesant,sdo_mes_ant,sdo_dia_ant,sdo_ult_corte,adicionado,fecha_alta,fecha_val,
			modificado,fecha_mod,cta_cheques,sucursal,plaza,promotor,tipo_banca,reg_firmas,envio,direcc_envio,cobraisr,per_acred_int)
			SELECT empresa,cuenta,secuencia,cod_instrum,num_cte,status_cta,motivo,fec_ult_mov,fec_cancelac,fec_reinversion,capital,sdo_retenido,sdo_cong,plazo,fecha_venc,
			opcion_retiro,intereses,isr,tasa,sobretasa,dia_sdo_pos,acum_sdo_pos,sdo_prom_mesant,sdo_mes_ant,sdo_dia_ant,sdo_ult_corte,adicionado,fecha_alta,fecha_val,
			modificado,fecha_mod,cta_cheques,sucursal,plaza,promotor,tipo_banca,reg_firmas,envio,direcc_envio,cobraisr,per_acred_int
			FROM tmp_si_fusmaeinv;
				
			DROP TABLE tmp_si_fusmaeinv;	
				
			UPDATE {+INDEX (bdinvers:sv_maeinv mai3)} bdinvers:sv_maeinv
			SET num_cte = pClienteTitular
			WHERE num_cte = pClienteTraspasaCtas;
		END IF;
		
		SELECT {+INDEX (bdinteg:si_cte_huella ix_huellanew)} COUNT(*)
		INTO iContador		
		FROM bdinteg:si_cte_huella
		WHERE numcte = pClienteTitular AND secuencia IS NOT NULL;
		
		IF ( iContador <= 0 ) THEN
		
			LET vc_proceso='TRASPASO DE HUELLA';
			LET vc_tabla = "si_cte_huella";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;

			--"SELECT '"||vc_proceso||"','"||vc_tabla||"','"||pClienteTitular||"','"||pClienteTraspasaCtas||"',TRIM(numcte)||"||"'|'"||"||TRIM('"||pClienteTraspasaCtas||"')||"||"'|'"||"||secuencia||"||"'|'"||"||TRIM(estado), '"||
			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(pClienteTraspasaCtas)||"|"||secuencia||"|"||TRIM(estado) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_cte_huella 
			WHERE numcte = pClienteTraspasaCtas
			INTO TEMP tmp_si_cte_huella_log WITH NO LOG;			
				
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_cte_huella_log;
					
			DROP TABLE tmp_si_cte_huella_log;
					
			SELECT {+INDEX (bdinteg:si_cte_huella ix_huellanew)}
				numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,usuario_camb,fecha_camb,fech_ult_camb
			FROM bdinteg:si_cte_huella
			WHERE numcte = pClienteTraspasaCtas
			AND secuencia IS NOT NULL
			INTO TEMP tmp_si_fushuellacte WITH NO LOG;
			
			INSERT INTO bdinteg:si_fushuellacte(numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,usuario_camb,fecha_camb,fech_ult_camb)
			SELECT numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,usuario_camb,fecha_camb,fech_ult_camb
			FROM tmp_si_fushuellacte;
			
			DROP TABLE tmp_si_fushuellacte;
			
			UPDATE {+INDEX (bdinteg:si_cte_huella ix_huellanew)} bdinteg:si_cte_huella
			SET numcte = pClienteTitular
			WHERE numcte = pClienteTraspasaCtas
			AND secuencia IS NOT NULL;
		ELSE
			LET vc_proceso='RESPALDO DE HUELLA';
			LET vc_tabla = "si_cte_huella";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
						
			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(pClienteTraspasaCtas)||"|"||secuencia||"|"||TRIM(estado) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_cte_huella 
			WHERE numcte = pClienteTraspasaCtas
			INTO TEMP tmp_si_cte_huella_log2 WITH NO LOG;			
				
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_cte_huella_log2;
					
			DROP TABLE tmp_si_cte_huella_log2;		
			
			SELECT {+INDEX (bdinteg:si_cte_huella ix_huellanew)} numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,usuario_camb,fecha_camb,fech_ult_camb
			FROM bdinteg:si_cte_huella
			WHERE numcte = pClienteTraspasaCtas
			AND secuencia IS NOT NULL
			INTO TEMP tmp_si_fushuellacte2 WITH NO LOG;
			
			INSERT INTO bdinteg:si_fushuellacte(numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,usuario_camb,fecha_camb,fech_ult_camb)
			SELECT  numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,usuario_camb,fecha_camb,fech_ult_camb
			FROM bdinteg:tmp_si_fushuellacte2;
			
			DROP TABLE tmp_si_fushuellacte2;
			
			SELECT {+INDEX (bdinteg:ix_si_cte_huella_resp)} COUNT(*) 
			INTO iConth 
			FROM si_cte_huella_resp 
			WHERE numcte = pClienteTraspasaCtas;
			
			IF iConth >=1 THEN
			
			    SELECT {+INDEX (bdinteg:si_cte_huella ix_huellanew)} COUNT(*)
				INTO iConhc
				FROM si_cte_huella WHERE  numcte = pClienteTraspasaCtas;
				
				IF iConhc >=1 THEN
			
					SELECT {+INDEX (bdinteg:si_cte_huella ix_huellanew)} NVL(MAX(secuencia),0)
					INTO iMaxsec
					FROM si_cte_huella 
					WHERE  numcte = pClienteTraspasaCtas;
					
						DROP TABLE  IF EXISTS tmp_si_cte_huella_resp_paso;
					
					SELECT {+INDEX (bdinteg:ix_si_cte_huella_resp)} NVL(secuencia,0) AS secuencia
					FROM si_cte_huella_resp 
					WHERE numcte = pClienteTraspasaCtas
					INTO TEMP tmp_si_cte_huella_resp_paso;
					
					FOREACH 
						SELECT secuencia INTO iSecuenciahr FROM tmp_si_cte_huella_resp_paso ORDER BY secuencia DESC
						
							UPDATE {+INDEX (bdinteg:ix_si_cte_huella_resp)} si_cte_huella_resp 
							SET secuencia = secuencia + iMaxsec
							WHERE numcte = pClienteTraspasaCtas AND secuencia = iSecuenciahr;

					END FOREACH;
					
				END IF;
			END IF;

			DELETE {+INDEX (bdinteg:si_cte_huella ix_huellanew)} FROM bdinteg:si_cte_huella
			WHERE numcte = pClienteTraspasaCtas
			AND secuencia IS NOT NULL;
		END IF;

		LET vc_proceso='TRASPASO DE HUELLA LINEA';
		LET vc_tabla = "si_huella_linea";
		--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
		LET dtFechaInsercion=CURRENT;
		
		SELECT {+INDEX (bdinteg:si_huella_linea 5751_2596)} COUNT(*)
		INTO iContador		
		FROM bdinteg:si_huella_linea 
		WHERE numcte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			SELECT {+INDEX (bdinteg:si_huella_linea 5751_2596)} COUNT(*)
			INTO iContador		
			FROM bdinteg:si_huella_linea 
			WHERE numcte = pClienteTitular;
			
			--Ambos clientes existen				
			IF ( iContador >= 1 ) THEN
			
				--Se mueven resultados de comparacion a las tablas de respaldo
				
				SELECT {+AVOID_FULL ("informix".si_huella_linea_resultado)} estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa
				FROM bdinteg:si_huella_linea_resultado
				WHERE ticket IN(SELECT {+AVOID_FULL ("informix".si_huella_linea)} ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas)
				INTO TEMP tmp_si_fushuella_linea_resultado WITH NO LOG;

				INSERT INTO bdinteg:si_fushuella_linea_resultado(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa) 
				SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa
				FROM tmp_si_fushuella_linea_resultado;
				
				DROP TABLE tmp_si_fushuella_linea_resultado;
				
				LET vc_tabla = "si_huella_linea_resultado";
				
				SELECT {+AVOID_FULL ("informix".si_huella_linea_resultado)} TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_resultado 
				WHERE ticket IN(SELECT {+AVOID_FULL ("informix".si_huella_linea)} ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas)
				INTO TEMP tmp_si_huella_linea_resultado_log WITH NO LOG;			
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_resultado_log;
				
				DROP TABLE tmp_si_huella_linea_resultado_log;
				
				SELECT {+INDEX (bdinteg:si_huella_linea_resultado_hist idx_huellalinea_resulhist2)} estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl
				FROM bdinteg:si_huella_linea_resultado_hist
				WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist WHERE numcte = pClienteTraspasaCtas)
				INTO TEMP tmp_si_fushuella_linea_resultado_hist WITH NO LOG;
				
				INSERT INTO bdinteg:si_fushuella_linea_resultado_hist(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciaspl) 
				SELECT  estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl
				FROM tmp_si_fushuella_linea_resultado_hist;
				
				DROP TABLE tmp_si_fushuella_linea_resultado_hist;
				
				LET vc_tabla = "si_huella_linea_resultado_hist";				
				
				SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_resultado_hist 
				WHERE ticket IN(SELECT ticket FROM bdinteg:si_huella_linea_hist WHERE numcte = pClienteTraspasaCtas)
				INTO TEMP tmp_si_huella_linea_resultado_log2 WITH NO LOG;			
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_resultado_log2;	
				
				DROP TABLE tmp_si_huella_linea_resultado_log2;
				
				SELECT {+INDEX (bdinteg:si_huella_linea_resultado_hist_chl idx_huellalinea_resultados_hist_chl_01)} estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov
				FROM bdinteg:si_huella_linea_resultado_hist_chl
				WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist_chl WHERE numcte = pClienteTraspasaCtas)
				INTO TEMP tmp_si_fushuella_linea_resultado_hist_chl WITH NO LOG;

				INSERT INTO bdinteg:si_fushuella_linea_resultado_hist_chl(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov)
				SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov
				FROM tmp_si_fushuella_linea_resultado_hist_chl;
				
				DROP TABLE tmp_si_fushuella_linea_resultado_hist_chl;
				
				LET vc_tabla = "si_huella_linea_resultado_hist_chl";
				

				SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_resultado_hist_chl 
				WHERE ticket IN(SELECT ticket FROM bdinteg:si_huella_linea_hist_chl WHERE numcte = pClienteTraspasaCtas)
				INTO TEMP tmp_si_huella_linea_resultado_hist_chl_log WITH NO LOG;			
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_resultado_hist_chl_log;		

				DROP TABLE tmp_si_huella_linea_resultado_hist_chl_log;
				
				--Se elimina  informacion de resultados de comparacion
				DELETE {+AVOID_FULL ("informix".si_huella_linea_resultado)} FROM bdinteg:si_huella_linea_resultado
				WHERE ticket IN(SELECT {+AVOID_FULL ("informix".si_huella_linea)} ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas);
				
				DELETE {+INDEX (bdinteg:si_huella_linea_resultado_hist idx_huellalinea_resulhist2)} FROM bdinteg:si_huella_linea_resultado_hist
				WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist WHERE numcte = pClienteTraspasaCtas);
				
				DELETE {+INDEX (bdinteg:si_huella_linea_resultado_hist_chl idx_huellalinea_resultados_hist_chl_01)} FROM bdinteg:si_huella_linea_resultado_hist_chl
				WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist_chl WHERE numcte = pClienteTraspasaCtas);
				
				--Se mueven solicitudes de comparacion de huella a tablas de respaldo
				
				SELECT {+INDEX (bdinteg:si_huella_linea 5751_2596)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
				FROM bdinteg:si_huella_linea
				WHERE numcte = pClienteTraspasaCtas
				INTO TEMP tmp_si_fushuella_linea WITH NO LOG;

				INSERT INTO bdinteg:si_fushuella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert) 
				SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
				FROM tmp_si_fushuella_linea;
				
				DROP TABLE tmp_si_fushuella_linea;
				
				LET vc_tabla = "si_huella_linea";
				
				SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea 
				WHERE numcte = pClienteTraspasaCtas
				INTO TEMP tmp_si_huella_linea_log WITH NO LOG;			
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_log;
				
				DROP TABLE tmp_si_huella_linea_log;
				
				SELECT {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
				FROM bdinteg:si_huella_linea_hist
				WHERE numcte = pClienteTraspasaCtas
				INTO TEMP tmp_si_fushuella_linea_hist WITH NO LOG;

				INSERT INTO bdinteg:si_fushuella_linea_hist(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601) 
				SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
				FROM tmp_si_fushuella_linea_hist;
				
				DROP TABLE tmp_si_fushuella_linea_hist;
				
				LET vc_tabla = "si_huella_linea_hist";

				SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_hist 
				WHERE numcte = pClienteTraspasaCtas
				INTO TEMP tmp_si_huella_linea_hist_log WITH NO LOG;			
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_hist_log;
				
				DROP TABLE tmp_si_huella_linea_hist_log;
				
				SELECT {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov
				FROM bdinteg:si_huella_linea_hist_chl
				WHERE numcte = pClienteTraspasaCtas
				INTO TEMP tmp_si_fushuella_linea_hist_chl WITH NO LOG;
				
				INSERT INTO bdinteg:si_fushuella_linea_hist_chl(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov) 
				SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov
				FROM tmp_si_fushuella_linea_hist_chl;
				
				DROP TABLE tmp_si_fushuella_linea_hist_chl;
				
				LET vc_tabla = "si_huella_linea_hist_chl";
				
				SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_hist_chl 
				WHERE numcte = pClienteTraspasaCtas
				INTO TEMP tmp_si_huella_linea_hist_chl_log WITH NO LOG;			
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_hist_chl_log;
				
				DROP TABLE tmp_si_huella_linea_hist_chl_log;	
				
				--Se elimina  informacion de solicitudes de comparacion de huella
				DELETE {+INDEX (bdinteg:si_huella_linea 5751_2596)} FROM bdinteg:si_huella_linea
				WHERE numcte = pClienteTraspasaCtas;
				
				DELETE {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} FROM bdinteg:si_huella_linea_hist
				WHERE numcte = pClienteTraspasaCtas;
				
				DELETE {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} FROM bdinteg:si_huella_linea_hist_chl
				WHERE numcte = pClienteTraspasaCtas;
			ELSE --Solo existe cliente incorrecto
				SELECT {+INDEX (bdinteg:si_cte_huella ix_huellanew)} secuencia, sucursal, fecha_alta, dmapa, imapa, usuario
				INTO iSecuencia, cSucursal, dFecha_alta, cDmapa, cImapa, cUsuario
				FROM bdinteg:si_cte_huella
				WHERE numcte = pClienteTitular
				AND estado = 'A'
				AND secuencia = (SELECT {+INDEX (bdinteg:si_cte_huella ix_huellanew)} MAX(secuencia) FROM bdinteg:si_cte_huella WHERE numcte = pClienteTitular);
				
				IF DBINFO ('sqlca.sqlerrd2') <> 0 THEN --El cliente correcto tiene huella
				
					SELECT {+INDEX (bdinteg:si_huella_linea 5751_2596)} COUNT(*)
					INTO iContador				
					FROM bdinteg:si_huella_linea 
					WHERE numcte = pClienteTraspasaCtas AND secuencia = iSecuencia 
					AND sucursal = cSucursal AND fecha_alta_huella = dFecha_alta 
					AND dmapa = cDmapa AND imapa = cImapa;
									
					IF ( iContador >= 1 ) THEN									
									
						--Se mueven solicitudes de comparacion de huella a tablas de respaldo
						
						SELECT {+INDEX (bdinteg:si_huella_linea 5751_2596)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
						FROM bdinteg:si_huella_linea
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_fushuella_linea WITH NO LOG;
						
						INSERT INTO bdinteg:si_fushuella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert) 
						SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
						FROM tmp_si_fushuella_linea;
						
						DROP TABLE tmp_si_fushuella_linea;
						
						LET vc_tabla = "si_huella_linea";
						
						SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea 
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_huella_linea_log WITH NO LOG;			
				
						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_log;
				
						DROP TABLE tmp_si_huella_linea_log;
						
						SELECT {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
						FROM bdinteg:si_huella_linea_hist
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_fushuella_linea_hist WITH NO LOG;
						
						INSERT INTO bdinteg:si_fushuella_linea_hist(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601) 
						SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
						FROM tmp_si_fushuella_linea_hist;
						
						DROP TABLE tmp_si_fushuella_linea_hist;
						
						LET vc_tabla = "si_huella_linea_hist";

						SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_hist 
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_huella_linea_hist_log WITH NO LOG;			
				
						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_hist_log;
				
						DROP TABLE tmp_si_huella_linea_hist_log;
						
						SELECT {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov
						FROM bdinteg:si_huella_linea_hist_chl
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_fushuella_linea_hist_chl WITH NO LOG;
						
						INSERT INTO bdinteg:si_fushuella_linea_hist_chl(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov) 
						SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov
						FROM tmp_si_fushuella_linea_hist_chl;
						
						DROP TABLE tmp_si_fushuella_linea_hist_chl;

						LET vc_tabla = "si_huella_linea_hist_chl";
						
						SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_hist_chl 
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_huella_linea_hist_chl_log WITH NO LOG;			
				
						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_hist_chl_log;
						
						DROP TABLE tmp_si_huella_linea_hist_chl_log;
						
						UPDATE {+INDEX (bdinteg:si_huella_linea 5751_2596)} bdinteg:si_huella_linea
						SET numcte = pClienteTitular
						WHERE numcte = pClienteTraspasaCtas;
						
						UPDATE {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} bdinteg:si_huella_linea_hist
						SET numcte = pClienteTitular
						WHERE numcte = pClienteTraspasaCtas;
						
						UPDATE {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} bdinteg:si_huella_linea_hist_chl
						SET numcte = pClienteTitular
						WHERE numcte = pClienteTraspasaCtas;
					ELSE
						--Se mueven resultados de comparacion a las tablas de respaldo
						
						SELECT {+AVOID_FULL ("informix".si_huella_linea_resultado)} estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa
						FROM bdinteg:si_huella_linea_resultado
						WHERE ticket IN(SELECT {+AVOID_FULL ("informix".si_huella_linea)} ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas)
						INTO TEMP tmp_si_fushuella_linea_resultado WITH NO LOG;
						
						INSERT INTO bdinteg:si_fushuella_linea_resultado(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa) 
						SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa
						FROM tmp_si_fushuella_linea_resultado;
						
						DROP TABLE tmp_si_fushuella_linea_resultado;
						
						LET vc_tabla = "si_huella_linea_resultado";

						SELECT {+AVOID_FULL ("informix".si_huella_linea_resultado)} TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_resultado 
						WHERE ticket IN(SELECT {+AVOID_FULL ("informix".si_huella_linea)} ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas)
						INTO TEMP tmp_si_huella_linea_resultado_log WITH NO LOG;			
				
						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_resultado_log;
						
						DROP TABLE tmp_si_huella_linea_resultado_log;						
						
						SELECT {+INDEX (bdinteg:si_huella_linea_resultado_hist idx_huellalinea_resulhist2)} estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl
						FROM bdinteg:si_huella_linea_resultado_hist
						WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist WHERE numcte = pClienteTraspasaCtas)
						INTO TEMP tmp_si_huella_linea_resultado_hist WITH NO LOG;

						INSERT INTO bdinteg:si_fushuella_linea_resultado_hist(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciaspl) 
						SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl
						FROM tmp_si_huella_linea_resultado_hist;
						
						DROP TABLE tmp_si_huella_linea_resultado_hist;
						
						LET vc_tabla = "si_huella_linea_resultado_hist";

						SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_resultado_hist 
						WHERE ticket IN(SELECT ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas)
						INTO TEMP tmp_si_huella_linea_resultado_hist_log WITH NO LOG;			
				
						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_resultado_hist_log;
						
						DROP TABLE tmp_si_huella_linea_resultado_hist_log;				
						
						SELECT {+INDEX (bdinteg:si_huella_linea_resultado_hist_chl idx_huellalinea_resultados_hist_chl_01)} estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov
						FROM bdinteg:si_huella_linea_resultado_hist_chl
						WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist_chl WHERE numcte = pClienteTraspasaCtas)
						INTO TEMP tmp_si_fushuella_linea_resultado_hist_chl WITH NO LOG;
						
						INSERT INTO bdinteg:si_fushuella_linea_resultado_hist_chl(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov)
						SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov
						FROM tmp_si_fushuella_linea_resultado_hist_chl;
						
						DROP TABLE tmp_si_fushuella_linea_resultado_hist_chl;
						
						LET vc_tabla = "si_huella_linea_resultado_hist_chl";
						

						SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_resultado_hist_chl 
						WHERE ticket IN(SELECT ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas)
						INTO TEMP tmp_si_huella_linea_resultado_hist_chl_log WITH NO LOG;			
				
						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_resultado_hist_chl_log;
						
						DROP TABLE tmp_si_huella_linea_resultado_hist_chl_log;
						
						--Se elimina  informacion de resultados de comparacion
						DELETE {+AVOID_FULL ("informix".si_huella_linea_resultado)} FROM bdinteg:si_huella_linea_resultado
						WHERE ticket IN(SELECT {+AVOID_FULL ("informix".si_huella_linea)} ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas);
						
						DELETE {+INDEX (bdinteg:si_huella_linea_resultado_hist idx_huellalinea_resulhist2)} FROM bdinteg:si_huella_linea_resultado_hist
						WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist WHERE numcte = pClienteTraspasaCtas);
						
						DELETE {+INDEX (bdinteg:si_huella_linea_resultado_hist_chl idx_huellalinea_resultados_hist_chl_01)} FROM bdinteg:si_huella_linea_resultado_hist_chl
						WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist_chl WHERE numcte = pClienteTraspasaCtas);
						
						--Se mueven solicitudes de comparacion de huella a tablas de respaldo
						
						
						SELECT {+INDEX (bdinteg:si_huella_linea 5751_2596)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
						FROM bdinteg:si_huella_linea
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_fushuella_linea WITH NO LOG;
						
						INSERT INTO bdinteg:si_fushuella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert) 
						SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
						FROM tmp_si_fushuella_linea;
						
						DROP TABLE tmp_si_fushuella_linea;

						LET vc_tabla = "si_huella_linea";
						

						SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea 
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_huella_linea_log WITH NO LOG;			
				
						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_log;
						
						DROP TABLE tmp_si_huella_linea_log;
						
						SELECT {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
						FROM bdinteg:si_huella_linea_hist
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_fushuella_linea_hist WITH NO LOG;
						
						INSERT INTO bdinteg:si_fushuella_linea_hist(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601) 
						SELECT  numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
						FROM tmp_si_fushuella_linea_hist;
						
						DROP TABLE tmp_si_fushuella_linea_hist;
						
						LET vc_tabla = "si_huella_linea_hist";
						

						SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_hist 
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_huella_linea_hist_log WITH NO LOG;			
				
						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_hist_log;
						
						DROP TABLE tmp_si_huella_linea_hist_log;
						
						SELECT {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov
						FROM bdinteg:si_huella_linea_hist_chl
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_fushuella_linea_hist_chl WITH NO LOG;
						
						INSERT INTO bdinteg:si_fushuella_linea_hist_chl(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov) 
						SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov
						FROM tmp_si_fushuella_linea_hist_chl;
						
						DROP TABLE tmp_si_fushuella_linea_hist_chl;
						
						LET vc_tabla = "si_huella_linea_hist_chl";
						

						SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_hist_chl 
						WHERE numcte = pClienteTraspasaCtas
						INTO TEMP tmp_si_huella_linea_hist_chl_log WITH NO LOG;			
				
						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_hist_chl_log;
						
						DROP TABLE tmp_si_huella_linea_hist_chl_log;

						--Se elimina  informacion de solicitudes de comparacion de huella
						DELETE {+INDEX (bdinteg:si_huella_linea 5751_2596)} FROM bdinteg:si_huella_linea
						WHERE numcte = pClienteTraspasaCtas;
						
						DELETE {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} FROM bdinteg:si_huella_linea_hist
						WHERE numcte = pClienteTraspasaCtas;
						
						DELETE {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} FROM bdinteg:si_huella_linea_hist_chl
						WHERE numcte = pClienteTraspasaCtas;
						
						--Obtiene datos para generar registro de solicitud de comparacion para el cliente correcto
						SELECT {+INDEX (bdinteg:si_cliente 224_479)} a.numcte_ref, a.tipo_cliente, b.sexo
						INTO cNumcte_ref, cTipoCliente, cSexo
						FROM bdinteg:si_cliente a, bdinteg:si_ctepf b 
						WHERE a.numcte = b.numcte
						AND a.numcte = pClienteTitular;
						
						SELECT SUBSTR(TRIM(hostname),1,15)
						INTO cIpHost
						FROM  sysmaster:syssqlhosts 
						WHERE dbsvrnm in (SELECT DBSERVERNAME FROM systables where tabid = 1);
						
						--Se genera registro en si_huella_linea para cliente correcto
						LET isecdecode = DECODE(iSecuencia,1,1,2);
						
						INSERT INTO
						"informix".si_huella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
								empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, 								respuesta_msj601)
						VALUES	(pClienteTitular, CURRENT::DATE, iSecuencia, cSexo, cSucursal, dFecha_alta, cIpHost, isecdecode,
								cUsuario, '2',	cDmapa, cImapa, 'A', cNumcte_ref, dFecha_alta, cTipoCliente, 0, '', '0', '');
								
						IF iSecuencia > 1 THEN
							INSERT INTO bdisitesp:se_sitespctetmp(empresa,numcte,situacion,causa,sucursal,proceso_origen,operador,fecha,fechamovto)
							VALUES('001',pClienteTitular,'U','61',cSucursal,'4',cUsuario,CURRENT,CURRENT);
						END IF;

					END IF;
				ELSE --cliente correcto no tiene huella 
					
					
					SELECT {+AVOID_FULL ("informix".si_huella_linea_resultado)} estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa
					FROM bdinteg:si_huella_linea_resultado
					WHERE ticket IN(SELECT {+AVOID_FULL ("informix".si_huella_linea)} ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas)
					INTO TEMP tmp_si_fushuella_linea_resultado WITH NO LOG;

					INSERT INTO bdinteg:si_fushuella_linea_resultado(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa) 
					SELECT  estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa
					FROM tmp_si_fushuella_linea_resultado;
					
					DROP TABLE tmp_si_fushuella_linea_resultado;
					
					LET vc_tabla = "si_huella_linea_resultado";
					

					SELECT {+AVOID_FULL ("informix".si_huella_linea_resultado)} TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_resultado 
					WHERE ticket IN(SELECT {+AVOID_FULL ("informix".si_huella_linea)} ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas)
					INTO TEMP tmp_si_huella_linea_resultado_log WITH NO LOG;			
			
					INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_resultado_log;
					
					DROP TABLE tmp_si_huella_linea_resultado_log;
					
					SELECT {+INDEX (bdinteg:si_huella_linea_resultado_hist idx_huellalinea_resulhist2)} estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl
					FROM bdinteg:si_huella_linea_resultado_hist
					WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist WHERE numcte = pClienteTraspasaCtas)
					INTO TEMP tmp_si_fushuella_linea_resultado_hist WITH NO LOG;
					
					INSERT INTO bdinteg:si_fushuella_linea_resultado_hist(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciaspl) 
					SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl
					FROM tmp_si_fushuella_linea_resultado_hist;
					
					DROP TABLE tmp_si_fushuella_linea_resultado_hist;
					
					LET vc_tabla = "si_huella_linea_resultado_hist";
					
			
					SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_resultado_hist 
					WHERE ticket IN(SELECT ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas)
					INTO TEMP tmp_si_huella_linea_resultado_hist_log WITH NO LOG;			
			
					INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_resultado_hist_log;
					
					DROP TABLE tmp_si_huella_linea_resultado_hist_log;
					
					SELECT {+INDEX (bdinteg:si_huella_linea_resultado_hist_chl idx_huellalinea_resultados_hist_chl_01)} estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov
					FROM bdinteg:si_huella_linea_resultado_hist_chl
					WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist_chl WHERE numcte = pClienteTraspasaCtas)
					INTO TEMP tmp_si_fushuella_linea_resultado_hist_chl WITH NO LOG;

					INSERT INTO bdinteg:si_fushuella_linea_resultado_hist_chl(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov)
					SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov
					FROM tmp_si_fushuella_linea_resultado_hist_chl;
					
					DROP TABLE tmp_si_fushuella_linea_resultado_hist_chl;
					
					LET vc_tabla = "si_fushuella_linea_resultado_hist_chl";
					

					SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_fushuella_linea_resultado_hist_chl 
					WHERE ticket IN(SELECT ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas)
					INTO TEMP tmp_si_fushuella_linea_resultado_hist_chl_log WITH NO LOG;			
			
					INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_fushuella_linea_resultado_hist_chl_log;
					
					DROP TABLE tmp_si_fushuella_linea_resultado_hist_chl_log;

					--Se elimina  informacion de resultados de comparacion
					DELETE {+AVOID_FULL ("informix".si_huella_linea_resultado)} FROM bdinteg:si_huella_linea_resultado
					WHERE ticket IN(SELECT {+AVOID_FULL ("informix".si_huella_linea)} ticket FROM bdinteg:si_huella_linea WHERE numcte = pClienteTraspasaCtas);
					
					DELETE {+INDEX (bdinteg:si_huella_linea_resultado_hist idx_huellalinea_resulhist2)} FROM bdinteg:si_huella_linea_resultado_hist
					WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist WHERE numcte = pClienteTraspasaCtas);
					
					DELETE {+INDEX (bdinteg:si_huella_linea_resultado_hist_chl idx_huellalinea_resultados_hist_chl_01)} FROM bdinteg:si_huella_linea_resultado_hist_chl
					WHERE ticket IN (SELECT {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} DISTINCT ticket FROM bdinteg:si_huella_linea_hist_chl WHERE numcte = pClienteTraspasaCtas);
					
					--Se mueven solicitudes de comparacion de huella a tablas de respaldo
					
					SELECT {+AVOID_FULL ("informix".si_huella_linea)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
					FROM bdinteg:si_huella_linea
					WHERE numcte = pClienteTraspasaCtas 
					INTO TEMP tmp_si_fushuella_linea WITH NO LOG;
					
					INSERT INTO bdinteg:si_fushuella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert) 
					SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
					FROM tmp_si_fushuella_linea;
					
					DROP TABLE tmp_si_fushuella_linea;
					
					LET vc_tabla = "si_huella_linea";
					
					SELECT {+AVOID_FULL ("informix".si_huella_linea)} TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea 
					WHERE numcte = pClienteTraspasaCtas
					INTO TEMP tmp_si_huella_linea_log WITH NO LOG;			
			
					INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_log;
					
					DROP TABLE tmp_si_huella_linea_log;

					SELECT {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
					FROM bdinteg:si_huella_linea_hist
					WHERE numcte = pClienteTraspasaCtas
					INTO TEMP tmp_si_fushuella_linea_hist WITH NO LOG;
					
					INSERT INTO bdinteg:si_fushuella_linea_hist(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601) 
					SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
					FROM tmp_si_fushuella_linea_hist;

					DROP TABLE tmp_si_fushuella_linea_hist;
					
					LET vc_tabla = "si_huella_linea_hist";

					
					SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_hist 
					WHERE numcte = pClienteTraspasaCtas
					INTO TEMP tmp_si_huella_linea_hist_log WITH NO LOG;			
			
					INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_hist_log;
					
					DROP TABLE tmp_si_huella_linea_hist_log;
					
					SELECT {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov
					FROM bdinteg:si_huella_linea_hist_chl
					WHERE numcte = pClienteTraspasaCtas
					INTO TEMP tmp_si_fushuella_linea_hist_chl WITH NO LOG;
					
					INSERT INTO bdinteg:si_fushuella_linea_hist_chl(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov) 
					SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov
					FROM tmp_si_fushuella_linea_hist_chl;
					
					DROP TABLE tmp_si_fushuella_linea_hist_chl;

					LET vc_tabla = "si_huella_linea_hist_chl";
					
					SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,secuencia||"|"||TRIM(ticket)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinteg:si_huella_linea_hist_chl 
					WHERE numcte = pClienteTraspasaCtas
					INTO TEMP tmp_si_huella_linea_hist_chl_log WITH NO LOG;			
			
					INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_si_huella_linea_hist_chl_log;
					
					DROP TABLE tmp_si_huella_linea_hist_chl_log;
					
					--Se elimina  informacion de solicitudes de comparacion de huella
					DELETE {+INDEX (bdinteg:si_huella_linea 5751_2596)} FROM bdinteg:si_huella_linea
					WHERE numcte = pClienteTraspasaCtas;
					
					DELETE {+INDEX (bdinteg:si_huella_linea_hist i550_1453)} FROM bdinteg:si_huella_linea_hist
					WHERE numcte = pClienteTraspasaCtas;
					
					DELETE {+INDEX (bdinteg:si_huella_linea_hist_chl idx_huellalinea_hist_chl_01)} FROM bdinteg:si_huella_linea_hist_chl
					WHERE numcte = pClienteTraspasaCtas;				
				END IF;
			END IF;
		ELSE
		
			SELECT {+INDEX (bdinteg:si_huella_linea 5751_2596)} COUNT(*)
			INTO iContador		
			FROM bdinteg:si_huella_linea 
			WHERE numcte = pClienteTitular; --No existe ninguno de los clientes
			
			IF ( iContador <= 0 ) THEN

				SELECT {+INDEX (bdinteg:si_cte_huella ix_huellanew)} secuencia, sucursal, fecha_alta, dmapa, imapa, usuario
				INTO iSecuencia, cSucursal, dFecha_alta, cDmapa, cImapa, cUsuario
				FROM bdinteg:si_cte_huella
				WHERE numcte = pClienteTitular
				AND estado = 'A'
				AND secuencia = (SELECT {+INDEX (bdinteg:si_cte_huella ix_huellanew)} MAX(secuencia) FROM bdinteg:si_cte_huella WHERE numcte = pClienteTitular);
				
				IF DBINFO ('sqlca.sqlerrd2') <> 0 THEN --El cliente correcto tiene huella
				
					SELECT {+INDEX (bdinteg:si_cliente 224_479)} a.numcte_ref, a.tipo_cliente, b.sexo
					INTO cNumcte_ref, cTipoCliente, cSexo
					FROM bdinteg:si_cliente a, bdinteg:si_ctepf b 
					WHERE a.numcte = b.numcte
					AND a.numcte = pClienteTitular;
					
					SELECT SUBSTR(TRIM(hostname),1,15)
					INTO cIpHost
					FROM  sysmaster:syssqlhosts 
					WHERE dbsvrnm in (SELECT DBSERVERNAME FROM systables where tabid = 1);
					
					--Se genera registro en si_huella_linea para cliente correcto
					LET isecdecode = DECODE(iSecuencia,1,1,2);
					
					INSERT INTO
					"informix".si_huella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, 
							empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601)
					VALUES	(pClienteTitular, CURRENT::DATE, iSecuencia, cSexo, cSucursal, dFecha_alta, cIpHost, isecdecode,
							cUsuario, '2',	cDmapa, cImapa, 'A', cNumcte_ref, dFecha_alta, cTipoCliente, 0, '', '0', '');
							
					IF iSecuencia > 1 THEN
						INSERT INTO bdisitesp:se_sitespctetmp(empresa,numcte,situacion,causa,sucursal,proceso_origen,operador,fecha,fechamovto)
						VALUES('001',pClienteTitular,'U','61',cSucursal,'4',cUsuario,CURRENT,CURRENT);
					END IF;
				END IF;
			END IF;
		END IF;
		
		SELECT {+INDEX (bdilide:sl_movefec 156_319)} COUNT(*)
		INTO iContador		
		FROM bdilide:sl_movefec 
		WHERE aniomes =vc_AnioMes AND num_cte =pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='INFORMACION IDE';
			LET vc_tabla = "sl_movefec";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(aniomes)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdilide:sl_movefec 
			WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_sl_movefec_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sl_movefec_log;
			
			DROP TABLE tmp_sl_movefec_log;
			
			SELECT rfc
			INTO vc_rfc
			FROM bdinteg:si_cliente
			WHERE numcte = pClienteTitular;
			
			
			SELECT {+INDEX (bdilide:sl_movefec 156_319)} aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert
			FROM bdilide:sl_movefec
			WHERE aniomes = vc_AnioMes
			AND num_cte = pClienteTraspasaCtas
			AND num_serial IS NOT NULL
			INTO TEMP tmp_si_fusmovefec WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusmovefec(aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert)
			SELECT aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert
			FROM tmp_si_fusmovefec;
					
			DROP TABLE tmp_si_fusmovefec;		
					
			SELECT aniomes,pClienteTitular as num_cte,num_serial,vc_rfc as rfc,
			ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert
			FROM bdilide:sl_movefec 
			WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_sl_movefec_log WITH NO LOG;			
	
			INSERT INTO bdilide:sl_movefec(aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert)
			SELECT aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert 
			FROM tmp_sl_movefec_log;
			
			DROP TABLE tmp_sl_movefec_log;

			DELETE {+INDEX (bdilide:sl_movefec 156_319)} FROM bdilide:sl_movefec
			WHERE aniomes = vc_AnioMes
			AND num_cte = pClienteTraspasaCtas
			AND num_serial IS NOT NULL;
		END IF;
		
		SELECT {+INDEX (bdilide:sl_movefec_his 171_350)} COUNT(*)
		INTO iContador		
		FROM bdilide:sl_movefec_his 
		WHERE aniomes =vc_AnioMes AND num_cte =pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='INFORMACION IDE';
			LET vc_tabla = "sl_movefec_his";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			
			SELECT rfc INTO vc_rfc FROM bdinteg:si_cliente WHERE numcte = pClienteTitular;
			
			
			SELECT {+INDEX (bdilide:sl_movefec_his 171_350)} aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert
			FROM bdilide:sl_movefec_his
			WHERE aniomes = vc_AnioMes
			AND num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_si_fusmovefec_his WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusmovefec_his(aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert)
			SELECT aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert
			FROM tmp_si_fusmovefec_his;
			
			DROP TABLE tmp_si_fusmovefec_his;

			SELECT aniomes,pClienteTitular as num_cte,num_serial,vc_rfc as rfc,
			ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert
			FROM bdilide:sl_movefec_his 
			WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_sl_movefec_his_log WITH NO LOG;			
	
			INSERT INTO bdilide:sl_movefec(aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert)
			SELECT aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert 
			FROM tmp_sl_movefec_his_log;
			
			DROP TABLE tmp_sl_movefec_his_log;
			
			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(aniomes)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdilide:sl_movefec_his 
			WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_sl_movefec_his_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sl_movefec_his_log;
				
			DROP TABLE tmp_sl_movefec_his_log;	
				
			DELETE {+INDEX (bdilide:sl_movefec_his 171_350)} FROM bdilide:sl_movefec_his WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas;
		END IF;
		
		SELECT {+INDEX (bdisolic:ss_solicitudes idx_numctempresa)} COUNT(*)
		INTO iContador		
		FROM bdisolic:ss_solicitudes 
		WHERE numcte = pClienteTraspasaCtas AND empresa='001';
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='TRASPASO DE SOLICITUDES';
			LET vc_tabla = "ss_solicitudes";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			
			SELECT {+INDEX (bdisolic:ss_solicitudes idx_numctempresa)} empresa,num_solicitud,numcte,co_numcte,cod_funcion,regional,plaza,sucursal,tipo_solicitud,status_solicitud,
				num_producto,tipo_prestamo,monto_solicitado,periodo_plazo,plazo,divisa,tipo_calculo,cod_tasa_base,sobretasa,factor_sobretasa,tasa_interes,tasa_fija_o_var,
				rev_tasa_var_per,dia_para_revisar,tasa_mora_adic,cod_tasa_mora,fact_sobret_mora,sobretasa_mora,tasa_moratorios,factor_moratorio,periodo_pag_cap,periodo_pag_int,
				gracia_cap,diferimiento_int,tp_gen_planpago,individualizable,con_integrantes,fecha_apert_prop,fecha_venc_prop,ajuste_de_cuota,ajuste_venc_int,envio_coppel,
				envio_parametrico,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,capacidad_pres,monto_autorizado,
				user_insert,fecha_insert,fecha_hora
			FROM bdisolic:ss_solicitudes
			WHERE numcte = pClienteTraspasaCtas
			AND empresa='001'
			INTO TEMP tmp_si_fussolicitudes WITH NO LOG;
			
			INSERT INTO bdinteg:si_fussolicitudes(empresa,num_solicitud,numcte,co_numcte,cod_funcion,regional,plaza,sucursal,tipo_solicitud,status_solicitud,
			num_producto,tipo_prestamo,monto_solicitado,periodo_plazo,plazo,divisa,tipo_calculo,cod_tasa_base,sobretasa,factor_sobretasa,tasa_interes,tasa_fija_o_var,
			rev_tasa_var_per,dia_para_revisar,tasa_mora_adic,cod_tasa_mora,fact_sobret_mora,sobretasa_mora,tasa_moratorios,factor_moratorio,periodo_pag_cap,periodo_pag_int,
			gracia_cap,diferimiento_int,tp_gen_planpago,individualizable,con_integrantes,fecha_apert_prop,fecha_venc_prop,ajuste_de_cuota,ajuste_venc_int,envio_coppel,
			envio_parametrico,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,capacidad_pres,monto_autorizado,
			user_insert,fecha_insert,fecha_hora)
			SELECT empresa,num_solicitud,numcte,co_numcte,cod_funcion,regional,plaza,sucursal,tipo_solicitud,status_solicitud,
			num_producto,tipo_prestamo,monto_solicitado,periodo_plazo,plazo,divisa,tipo_calculo,cod_tasa_base,sobretasa,factor_sobretasa,tasa_interes,tasa_fija_o_var,
			rev_tasa_var_per,dia_para_revisar,tasa_mora_adic,cod_tasa_mora,fact_sobret_mora,sobretasa_mora,tasa_moratorios,factor_moratorio,periodo_pag_cap,periodo_pag_int,
			gracia_cap,diferimiento_int,tp_gen_planpago,individualizable,con_integrantes,fecha_apert_prop,fecha_venc_prop,ajuste_de_cuota,ajuste_venc_int,envio_coppel,
			envio_parametrico,tasa_base_piso,sobretasa_piso,factor_piso,tasa_piso,tasa_base_techo,sobretasa_techo,factor_techo,capacidad_pres,monto_autorizado,
			user_insert,fecha_insert,fecha_hora
			FROM tmp_si_fussolicitudes;
			
			DROP TABLE tmp_si_fussolicitudes;
			
			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(pClienteTraspasaCtas)||"|"||TRIM(num_solicitud)||"|"||TRIM(status_solicitud)||"|"||fecha_insert as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdisolic:ss_solicitudes 
			WHERE numcte = pClienteTraspasaCtas AND empresa ='001'
			INTO TEMP tmp_ss_solicitudes_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_ss_solicitudes_log;
				
			DROP TABLE tmp_ss_solicitudes_log;	
			
			UPDATE {+INDEX (bdisolic:ss_solicitudes idx_numctempresa)} bdisolic:ss_solicitudes
			SET numcte = pClienteTitular
			WHERE numcte = pClienteTraspasaCtas
			AND empresa ='001';
			
			UPDATE {+INDEX(bdisolic:ss_refpersonales idx_refper)} bdisolic:ss_refpersonales
			SET numcte = pClienteTitular
			WHERE numcte = pClienteTraspasaCtas
			AND empresa ='001';
		END IF;
		
		SELECT {+INDEX(bdisolic:ss_refpersonales  idx_ss_refpersonales01)} COUNT(*)
		INTO iContador		
		FROM bdisolic:ss_refpersonales
		WHERE numcte_ref = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 AND pClienteTraspasaCtas!='' AND pClienteTraspasaCtas IS NOT NULL) THEN

			LET vc_proceso='TRASPASO DE REFERENCIAS';
			LET vc_tabla = "bdisolic:ss_refpersonales";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT {+INDEX(bdisolic:ss_refpersonales idx_ss_refpersonales01)} empresa, num_solicitud, numcte, numcte_ref, parentesco, tipo_relacion, nombre_ref, telefono_ref
			FROM bdisolic:ss_refpersonales 
			WHERE numcte_ref = pClienteTraspasaCtas
			INTO TEMP tmp_si_fusrefpersonales WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusrefpersonales (empresa, num_solicitud, numcte, numcte_ref, parentesco, tipo_relacion, nombre_ref, telefono_ref)
			SELECT empresa, num_solicitud, numcte, numcte_ref, parentesco, tipo_relacion, nombre_ref, telefono_ref
			FROM tmp_si_fusrefpersonales;
												
			DROP TABLE tmp_si_fusrefpersonales;
/*												
			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(pClienteTraspasaCtas)||"|"||TRIM(num_solicitud) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdisolic:ss_refpersonales 
			WHERE empresa = '001' AND num_solicitud IS NOT NULL AND numcte IS NOT NULL AND numcte_ref= pClienteTraspasaCtas
			INTO TEMP tmp_ss_refpersonales_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_ss_refpersonales_log;
			
			DROP TABLE tmp_ss_refpersonales_log;
*/
			FOREACH
				SELECT TRIM(pClienteTraspasaCtas)||"|"||TRIM(num_solicitud) INTO cDetalle_mov FROM bdisolic:ss_refpersonales 
				WHERE empresa = '001' AND num_solicitud IS NOT NULL AND numcte IS NOT NULL AND numcte_ref= pClienteTraspasaCtas	
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES (TRIM(vc_proceso),TRIM(vc_tabla),TRIM(pClienteTitular),TRIM(pClienteTraspasaCtas),cDetalle_mov,dtFechaInsercion,TRIM(pUsuario),CURRENT::DATE);
				
				UPDATE {+INDEX(bdisolic:ss_refpersonales idx_ss_refpersonales01)} bdisolic:ss_refpersonales 
				SET numcte_ref = pClienteTitular
				WHERE numcte_ref = pClienteTraspasaCtas;
				
			END FOREACH;
			
		END IF;
		
		SELECT {+INDEX (bdiprog:pp_pagoprog idxpp_num_cte)} COUNT(*)
		INTO iContador		
		FROM bdiprog:pp_pagoprog 
		WHERE num_cte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='PAGOS PROGRAMADOS';
			LET vc_tabla = "pp_pagoprog";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta_origen)||"|"||TRIM(pClienteTraspasaCtas)||"|"||TRIM(cve_pagoprog) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdiprog:pp_pagoprog 
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_pp_pagoprog_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_pp_pagoprog_log;
			
			DROP TABLE tmp_pp_pagoprog_log;

			SELECT {+INDEX (bdiprog:pp_pagoprog idxpp_num_cte)} cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,
				banco_destino,referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,fecha_fin,
				cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,cve_dia,cve_canal,cve_notifica,
				ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,mensaje,cve_estado,user_insert,fecha_insert,
				user_cancela,fecha_cancela,canal_cancela
			FROM bdiprog:pp_pagoprog
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_si_fuspagoprog WITH NO LOG;
			
			INSERT INTO bdinteg:si_fuspagoprog(cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,
			banco_destino,referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,fecha_fin,
			cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,cve_dia,cve_canal,cve_notifica,
			ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,mensaje,cve_estado,user_insert,fecha_insert,
			user_cancela,fecha_cancela,canal_cancela)
			SELECT cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,
			banco_destino,referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,fecha_fin,
			cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,cve_dia,cve_canal,cve_notifica,
			ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,mensaje,cve_estado,user_insert,fecha_insert,
			user_cancela,fecha_cancela,canal_cancela
			FROM tmp_si_fuspagoprog;
			
			DROP TABLE tmp_si_fuspagoprog;
			
			UPDATE {+INDEX (bdiprog:pp_pagoprog idxpp_num_cte)} bdiprog:pp_pagoprog
			SET num_cte = pClienteTitular
			WHERE num_cte = pClienteTraspasaCtas;
			
			
		END IF;
		
		SELECT {+INDEX (bdidomi:dom_autorizaciones dom_auto_2)} COUNT(*)
		INTO iContador		
		FROM bdidomi:dom_autorizaciones 
		WHERE num_cte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN		
		
			LET vc_proceso='DOMICILIACIONES';
			LET vc_tabla = "dom_autorizaciones";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdidomi:dom_autorizaciones 
			WHERE num_cte = pClienteTraspasaCtas INTO TEMP tmp_dom_autorizaciones_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_dom_autorizaciones_log;
			
			DROP TABLE tmp_dom_autorizaciones_log;

			SELECT {+INDEX (bdidomi:dom_autorizaciones dom_auto_2)} cuenta,rfc,num_cte,cve_canal,imp_maximo,num_rechazos,cve_sucursal,cve_estatus,fecha_estatus,user_estatus,cve_causa,user_insert,fecha_insert,
				cve_domiciliar_tc,imp_fijo_tc,tipo_cuenta_cargo,cuenta_cargo,cve_banco_cargo
			FROM bdidomi:dom_autorizaciones
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_si_fusdomautorizaciones WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusdomautorizaciones(cuenta,rfc,num_cte,cve_canal,imp_maximo,num_rechazos,cve_sucursal,cve_estatus,fecha_estatus,user_estatus,cve_causa,user_insert,fecha_insert,
			cve_domiciliar_tc,imp_fijo_tc,tipo_cuenta_cargo,cuenta_cargo,cve_banco_cargo)
			SELECT cuenta,rfc,num_cte,cve_canal,imp_maximo,num_rechazos,cve_sucursal,cve_estatus,fecha_estatus,user_estatus,cve_causa,user_insert,fecha_insert,
			cve_domiciliar_tc,imp_fijo_tc,tipo_cuenta_cargo,cuenta_cargo,cve_banco_cargo
			FROM tmp_si_fusdomautorizaciones;
			
			DROP TABLE tmp_si_fusdomautorizaciones;
			
			UPDATE {+INDEX (bdidomi:dom_autorizaciones dom_auto_2)} bdidomi:dom_autorizaciones
			SET num_cte = pClienteTitular
			WHERE num_cte = pClienteTraspasaCtas;
			
			
		END IF;
		
		SELECT {+INDEX (bdicntchq:sq_envios idx_sqncte)} COUNT(*)
		INTO iContador
		FROM bdicntchq:sq_envios 
		WHERE numcte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='TRASPASO DE CHEQUERAS';
			LET vc_tabla = "sq_envios";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(num_cuenta)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicntchq:sq_envios 
			WHERE numcte = pClienteTraspasaCtas
			INTO TEMP tmp_sq_envios_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sq_envios_log;
			
			DROP TABLE tmp_sq_envios_log;
			
			SELECT {+INDEX (bdicntchq:sq_envios idx_sqncte)}
			folio_chequera,num_cuenta,numcte,cliente_origen,cliente_destino,tipo_envio,peso,no_factura,no_guia,fecha_envio,comentarios,fecha_resp,resp_msg
			FROM bdicntchq:sq_envios
			WHERE numcte = pClienteTraspasaCtas
			INTO TEMP tmp_sq_envios WITH NO LOG;
			
			INSERT INTO bdinteg:si_fussq_envios(folio_chequera,num_cuenta,numcte,cliente_origen,cliente_destino,tipo_envio,peso,no_factura,no_guia,fecha_envio,comentarios,fecha_resp,resp_msg)
			SELECT folio_chequera,num_cuenta,numcte,cliente_origen,cliente_destino,tipo_envio,peso,no_factura,no_guia,fecha_envio,comentarios,fecha_resp,resp_msg
			FROM tmp_sq_envios;
			
			DROP TABLE tmp_sq_envios;
			
			UPDATE {+INDEX (bdicntchq:sq_envios idx_sqncte)} bdicntchq:sq_envios
			SET numcte = pClienteTitular
			WHERE numcte = pClienteTraspasaCtas;
		END IF;

		SELECT {+INDEX (bdicheq:sc_histsbg idx_histsbg2)} COUNT(*)
		INTO iContador
		FROM bdicheq:sc_histsbg
		WHERE empresa='001' AND num_cte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN		
		
			LET vc_proceso='SOBREGIROS';
			LET vc_tabla = "sc_histsbg";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;

			
			SELECT
			{+AVOID_FULL (bdicheq:"informix".sc_histsbg)}
			TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_histsbg 
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_sc_histsbg_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_histsbg_log;
				
			DROP TABLE tmp_sc_histsbg_log;	
			
			SELECT {+INDEX (bdicheq:sc_histsbg idx_histsbg2)} empresa,sucursal,cuenta,fecha_sbg,tipo_linea,legal,lin_aut,num_cte,sdo_disp_dia_ant,cargos,abonos,sdo_actual,
				sdo_disponible,int_dia,int_acum,tasa,dias,retroactivo
			FROM bdicheq:sc_histsbg
			WHERE empresa='001'
			AND num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_si_fushistsbg WITH NO LOG;
			
			INSERT INTO bdinteg:si_fushistsbg(empresa,sucursal,cuenta,fecha_sbg,tipo_linea,legal,lin_aut,num_cte,sdo_disp_dia_ant,cargos,abonos,sdo_actual,
			sdo_disponible,int_dia,int_acum,tasa,dias,retroactivo)
			SELECT empresa,sucursal,cuenta,fecha_sbg,tipo_linea,legal,lin_aut,num_cte,sdo_disp_dia_ant,cargos,abonos,sdo_actual,
			sdo_disponible,int_dia,int_acum,tasa,dias,retroactivo
			FROM tmp_si_fushistsbg;
			
			DROP TABLE tmp_si_fushistsbg;
			
			UPDATE {+INDEX (bdicheq:sc_histsbg idx_histsbg2)} bdicheq:sc_histsbg
			SET num_cte = pClienteTitular
			WHERE empresa='001'
			AND num_cte = pClienteTraspasaCtas;
		END IF;
		
		SELECT {+INDEX (bdicheq:sc_proac idxproac_13)} COUNT(*)
		INTO iContador		
		FROM bdicheq:sc_proac 
		WHERE num_cte = pClienteTraspasaCtas AND cuenta IS NOT NULL;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='PROAC';
			LET vc_tabla = "sc_proac";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;

			SELECT 
			{+INDEX (bdicheq:sc_proac idxproac_13)}
			TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cta_eje)||"|"||TRIM(cuenta)||"|"||secuencia||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_proac 
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_sc_proac_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_proac_log;
				
			DROP TABLE tmp_sc_proac_log;

			SELECT {+INDEX (bdicheq:sc_proac idxproac_13)}
			cuenta,num_cte,cta_eje,secuencia,status_cta,fecha_alta,fecha_canc,sucursal,saldo,prem_proac
			FROM bdicheq:sc_proac
			WHERE num_cte = pClienteTraspasaCtas
			AND cuenta IS NOT NULL
			INTO TEMP tmp_si_fusproac WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusproac(cuenta,num_cte,cta_eje,secuencia,status_cta,fecha_alta,fecha_canc,sucursal,saldo,prem_proac)
			SELECT cuenta,num_cte,cta_eje,secuencia,status_cta,fecha_alta,fecha_canc,sucursal,saldo,prem_proac
			FROM tmp_si_fusproac;

			DROP TABLE tmp_si_fusproac;
			
			UPDATE {+INDEX (bdicheq:sc_proac idxproac_13)} bdicheq:sc_proac
			SET num_cte = pClienteTitular
			WHERE num_cte = pClienteTraspasaCtas;
			
		END IF;
		
		SELECT {+INDEX (bdicheq:sc_portabilidad 1361_566)} COUNT(*)
		INTO iContador		
		FROM bdicheq:sc_portabilidad 
		WHERE numcte = pClienteTraspasaCtas AND empresa='001';
		
		IF ( iContador >= 1 ) THEN		
		
			LET vc_proceso='PORTABILIDAD NOMINA';
			LET vc_tabla = "sc_portabilidad";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT
			{+AVOID_FULL (bdicheq:"informix".sc_portabilidad )}
			TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_portabilidad 
			WHERE numcte = pClienteTraspasaCtas
			INTO TEMP tmp_sc_portabilidad_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_portabilidad_log;
							
			DROP TABLE tmp_sc_portabilidad_log;
			
			SELECT {+INDEX (bdicheq:sc_portabilidad 1361_566)} empresa,numcte,cuenta,bancoreferencia,cuentareferencia,fecha_deposita_nomina
			FROM bdicheq:sc_portabilidad
			WHERE numcte = pClienteTraspasaCtas
			AND empresa ='001'
			INTO TEMP tmp_si_fusportabilidad WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusportabilidad(empresa,numcte,cuenta,bancoreferencia,cuentareferencia,fecha_deposita_nomina)
			SELECT empresa,numcte,cuenta,bancoreferencia,cuentareferencia,fecha_deposita_nomina
			FROM tmp_si_fusportabilidad;
			
			DROP TABLE tmp_si_fusportabilidad;
			
			UPDATE {+INDEX (bdicheq:sc_portabilidad 1361_566)} bdicheq:sc_portabilidad
			SET numcte = pClienteTitular
			WHERE numcte = pClienteTraspasaCtas
			AND empresa ='001';
			
		END IF;
		
		SELECT {+INDEX (bdicheq:sc_encabezado_edocta_factelect idx_encabezado_cte)} COUNT(*)
		INTO iContador		
		FROM bdicheq:sc_encabezado_edocta_factelect 
		WHERE num_cte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='FACTURA ELECTRONICA';
			LET vc_tabla = "sc_encabezado_edocta_factelect";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(num_cuenta)||"|"||TRIM(pClienteTraspasaCtas)||"|"||idreg||"|"||fechafinal as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_encabezado_edocta_factelect 
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_sc_encabezado_edocta_factelect_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_encabezado_edocta_factelect_log;
			
			DROP TABLE tmp_sc_encabezado_edocta_factelect_log;
			
			SELECT {+INDEX (bdicheq:sc_encabezado_edocta_factelect idx_encabezado_cte)}
				idreg,fecha_emision,num_cuenta,num_cte,num_tarjeta,nombre_cte,
				direccion_cte,direccion_col,direccion_del,edo_cd,cve_ruta,sucursal_nombre,rfc,cp,cve_ahorro,clabe,curp,fechaalta,fechainicio,mensajeproducto,
				inserto,fechafinal,sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc
			FROM bdicheq:sc_encabezado_edocta_factelect
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_si_fusencabezado_edocta_factelect WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusencabezado_edocta_factelect(idreg,fecha_emision,num_cuenta,num_cte,num_tarjeta,nombre_cte,
			direccion_cte,direccion_col,direccion_del,edo_cd,cve_ruta,sucursal_nombre,rfc,cp,cve_ahorro,clabe,curp,fechaalta,fechainicio,mensajeproducto,
			inserto,fechafinal,sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc)
			SELECT
				idreg,fecha_emision,num_cuenta,num_cte,num_tarjeta,nombre_cte,
				direccion_cte,direccion_col,direccion_del,edo_cd,cve_ruta,sucursal_nombre,rfc,cp,cve_ahorro,clabe,curp,fechaalta,fechainicio,mensajeproducto,
				inserto,fechafinal,sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc
			FROM tmp_si_fusencabezado_edocta_factelect;
			
			DROP TABLE tmp_si_fusencabezado_edocta_factelect;
			
			UPDATE {+INDEX (bdicheq:sc_encabezado_edocta_factelect idx_encabezado_cte)} bdicheq:sc_encabezado_edocta_factelect
			SET num_cte = pClienteTitular
			WHERE num_cte = pClienteTraspasaCtas;
			
		END IF;

		SELECT {+INDEX (bdinvers:sv_benefic idx_numcteempresa)} COUNT(*)
		INTO iContador
		FROM bdinvers:sv_benefic 
		WHERE numcte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='BENEFICIARIOS INVERSION';
			LET vc_tabla = "sv_benefic";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			
			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinvers:sv_benefic 
			WHERE numcte = pClienteTraspasaCtas  AND empresa='001'
			INTO TEMP tmp_sv_benefic_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sv_benefic_log;
			
			DROP TABLE tmp_sv_benefic_log;
			
			SELECT {+INDEX (bdinvers:sv_benefic idx_numcteempresa)} empresa,cuenta,numero,nombre,parentesco,porcentaje,numcte
			FROM bdinvers:sv_benefic
			WHERE numcte = pClienteTraspasaCtas
			AND empresa='001'
			INTO TEMP tmp_si_fusbenefic_inv WITH NO LOG;
			
			INSERT INTO bdinteg:si_fusbenefic_inv(empresa,cuenta,numero,nombre,parentesco,porcentaje,numcte)
			SELECT empresa,cuenta,numero,nombre,parentesco,porcentaje,numcte
			FROM tmp_si_fusbenefic_inv;
			
			DROP TABLE tmp_si_fusbenefic_inv;
			
			UPDATE {+INDEX (bdinvers:sv_benefic idx_numcteempresa)} bdinvers:sv_benefic
			SET numcte = pClienteTitular
			WHERE numcte = pClienteTraspasaCtas
			AND empresa='001';
			
		END IF;
		
		SELECT {+INDEX (bdinvers:sv_cotitular idx_sv_cotitular)} COUNT(*)
		INTO iContador		
		FROM bdinvers:sv_cotitular 
		WHERE cuenta IS NOT NULL AND numcte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='AUTORIZADOS INVERSION';
			LET vc_tabla = "sv_cotitular";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT 
			{+AVOID_FULL (bdinvers:"informix".sv_cotitular)}
			TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdinvers:sv_cotitular 
			WHERE cuenta IS NOT NULL AND numcte = pClienteTraspasaCtas
			INTO TEMP tmp_sv_cotitular_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sv_cotitular_log;

			DROP TABLE tmp_sv_cotitular_log;
			
			SELECT {+INDEX (bdinvers:sv_cotitular idx_sv_cotitular)}
			empresa,cuenta,numero,nombre,parentesco,numcte
			FROM bdinvers:sv_cotitular
			WHERE cuenta IS NOT NULL
			AND numcte = pClienteTraspasaCtas
			INTO TEMP tmp_si_fuscotitular_inv WITH NO LOG;
			
			INSERT INTO bdinteg:si_fuscotitular_inv(empresa,cuenta,numero,nombre,parentesco,numcte)
			SELECT empresa,cuenta,numero,nombre,parentesco,numcte
			FROM tmp_si_fuscotitular_inv;
			
			DROP TABLE tmp_si_fuscotitular_inv;
			
			UPDATE {+INDEX (bdinvers:sv_cotitular idx_sv_cotitular)} bdinvers:sv_cotitular
			SET numcte = pClienteTitular
			WHERE cuenta IS NOT NULL 
			AND numcte = pClienteTraspasaCtas;
			
		END IF;
		
		SELECT {+INDEX (bdicheq:sc_cuenta_telefono 32800_33285)} COUNT(*)
		INTO iContador		
		FROM bdicheq:sc_cuenta_telefono 
		WHERE num_cte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN
		
			LET vc_proceso='CUENTA-TELEFONO';
			LET vc_tabla = "sc_cuenta_telefono";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(cuenta)||"|"||TRIM(telefono)||"|"||TRIM(pClienteTraspasaCtas) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicheq:sc_cuenta_telefono 
			WHERE num_cte= pClienteTraspasaCtas
			INTO TEMP tmp_sc_cuenta_telefono_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sc_cuenta_telefono_log;

			DROP TABLE tmp_sc_cuenta_telefono_log;
			
			SELECT {+INDEX (bdicheq:sc_cuenta_telefono 32800_33285)} num_cte, cuenta, telefono, canal, es_transfer, user_insert, fecha_hora_insert
			FROM bdicheq:sc_cuenta_telefono
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_si_fuscuenta_telefono WITH NO LOG;
			
			INSERT INTO bdinteg:si_fuscuenta_telefono(num_cte, cuenta, telefono, canal, es_transfer, user_insert, fecha_hora_insert)
			SELECT num_cte, cuenta, telefono, canal, es_transfer, user_insert, fecha_hora_insert
			FROM tmp_si_fuscuenta_telefono;
			
			DROP TABLE tmp_si_fuscuenta_telefono;
			
			UPDATE {+INDEX (bdicheq:sc_cuenta_telefono 32800_33285)} bdicheq:sc_cuenta_telefono
			SET num_cte = pClienteTitular
			WHERE num_cte = pClienteTraspasaCtas;
			
		END IF;
		
		SELECT {+INDEX (bdicred:sd_promocion_credito indx_cte)} COUNT(*)
		INTO iContador		
		FROM bdicred:sd_promocion_credito
		WHERE num_cte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN		
		
			LET vc_proceso='PROMOCION CREDITO';
			LET vc_tabla = "sd_promocion_credito";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(folio_suc)||"|"||TRIM(num_credito)||"|"||TRIM(num_tarjeta) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicred:sd_promocion_credito 
			WHERE num_cte= pClienteTraspasaCtas
			INTO TEMP tmp_sd_promocion_credito_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sd_promocion_credito_log;

			DROP TABLE tmp_sd_promocion_credito_log;

			SELECT {+INDEX (bdicred:sd_promocion_credito indx_cte)} empresa, sistema, num_promo, fecha,
			ejecutivo, num_cte, num_credito, num_tarjeta, plazo, folio_suc, monto_actual, monto_int_iva, mensualidad, status,
			nombre_promo, sucursal, num_sol_prestamo, num_pro_prestamo, folio_movto, folio_suc_mov_crd
			FROM bdicred:sd_promocion_credito
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_si_fuspromocion_credito WITH NO LOG;
			
			INSERT INTO bdinteg:si_fuspromocion_credito( empresa, sistema, num_promo, fecha, ejecutivo, num_cte, num_credito, 
			num_tarjeta, plazo, folio_suc, monto_actual, monto_int_iva, mensualidad, status, nombre_promo, sucursal, num_sol_prestamo,
			num_pro_prestamo, folio_movto, folio_suc_mov_crd)
			SELECT empresa, sistema, num_promo, fecha,
			ejecutivo, num_cte, num_credito, num_tarjeta, plazo, folio_suc, monto_actual, monto_int_iva, mensualidad, status,
			nombre_promo, sucursal, num_sol_prestamo, num_pro_prestamo, folio_movto, folio_suc_mov_crd
			FROM tmp_si_fuspromocion_credito;
			
			DROP TABLE tmp_si_fuspromocion_credito;
			
			UPDATE {+INDEX (bdicred:sd_promocion_credito indx_cte)} bdicred:sd_promocion_credito
			SET num_cte = pClienteTitular
			WHERE num_cte = pClienteTraspasaCtas;		
		
		END IF;
		
		SELECT {+INDEX (bdicred:sd_promocion_credito_rev inx_cte)} COUNT(*)
		INTO iContador		
		FROM bdicred:sd_promocion_credito_rev
		WHERE num_cte = pClienteTraspasaCtas;
		
		IF ( iContador >= 1 ) THEN		
		
			LET vc_proceso='PROMOCION CREDITO RV';
			LET vc_tabla = "sd_promocion_credito_rev";
			--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			LET dtFechaInsercion=CURRENT;
			

			SELECT TRIM(vc_proceso) as proceso,TRIM(vc_tabla) as tabla,TRIM(pClienteTitular) as cliente_tit,TRIM(pClienteTraspasaCtas) as cliente_tras,TRIM(folio_suc)||"|"||TRIM(num_credito)||"|"||TRIM(num_tarjeta) as detalle_mov,dtFechaInsercion as fecha_hora,TRIM(pUsuario) as user_insert,CURRENT::DATE as fecha_insert FROM bdicred:sd_promocion_credito_rev 
			WHERE num_cte= pClienteTraspasaCtas
			INTO TEMP tmp_sd_promocion_credito_rev_log WITH NO LOG;			
	
			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert FROM tmp_sd_promocion_credito_rev_log;

			DROP TABLE tmp_sd_promocion_credito_rev_log;
			
			SELECT {+INDEX (bdicred:sd_promocion_credito_rev inx_cte)} empresa, sistema, num_promo, 
			fecha, ejecutivo, num_cte, num_credito, num_tarjeta, plazo, folio_suc, monto_actual, monto_int_iva, mensualidad, 
			status, nombre_promo, sucursal, num_sol_prestamo, num_pro_prestamo, folio_movto, folio, folio_suc_mov_crd
			FROM bdicred:sd_promocion_credito_rev
			WHERE num_cte = pClienteTraspasaCtas
			INTO TEMP tmp_si_fuspromocion_credito_rev WITH NO LOG;
			
			INSERT INTO bdinteg:si_fuspromocion_credito_rev( empresa, sistema, num_promo, fecha, ejecutivo, num_cte, num_credito, 
			num_tarjeta, plazo, folio_suc, monto_actual, monto_int_iva, mensualidad, status, nombre_promo, sucursal, num_sol_prestamo, 
			num_pro_prestamo, folio_movto, folio, folio_suc_mov_crd )
			SELECT empresa, sistema, num_promo, 
			fecha, ejecutivo, num_cte, num_credito, num_tarjeta, plazo, folio_suc, monto_actual, monto_int_iva, mensualidad, 
			status, nombre_promo, sucursal, num_sol_prestamo, num_pro_prestamo, folio_movto, folio, folio_suc_mov_crd
			FROM tmp_si_fuspromocion_credito_rev;
			
			DROP TABLE tmp_si_fuspromocion_credito_rev;
			
			UPDATE {+INDEX (bdicred:sd_promocion_credito_rev inx_cte)} bdicred:sd_promocion_credito_rev
			SET num_cte = pClienteTitular
			WHERE num_cte = pClienteTraspasaCtas;					
			
		END IF;
		
		--Ejecutar SP sp_traspasocuentas_cap_2
		EXECUTE PROCEDURE bdinteg:sp_traspasocuentas_cap_2(pClienteTitular,pClienteTraspasaCtas,pUsuario) INTO vc_CodRet, vc_Mensaje;
		IF vc_CodRet = "00000" THEN
			--COMMIT WORK;
			RETURN vc_CodRet,vc_Mensaje;
		ELSE
			SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} LIMIT 1 proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert
			INTO vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, dtFechaInsercion, pUsuario
			FROM bdinteg:log_fusionclientes
			WHERE fecha_insert = today AND cliente_tit = pClienteTitular AND cliente_tras = pClienteTraspasaCtas
			AND detalle_mov LIKE '%'||TRIM(vc_CodRet)||'%';
		--Si el segundo SP devuelve un codigo de Retorno diferente de '00000', siginfica que fallo y hara un ROLLBACK de todo el proceso
			--ROLLBACK WORK;
			
			INSERT INTO bdinteg:log_fusionclientes( proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
			VALUES ( vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, dtFechaInsercion, pUsuario, dtFechaInsercion::DATE);
			
			RETURN vc_CodRet,vc_Mensaje;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR:Jose Cristobal Hernandez Fierro',
'FECHA:22/SEP/2014',
'MODIFICACION: Se agregaron los campos: bandera_cobro,bandera_bonificacion,cobro_tarjeta,iva_cobrotar,fecha_insert a las tablas sc_tarjeta y si_fustarjetadeb',
'SUSTENTO: RQI 64 044',
'SOLICITA: Jose Angel Lopez Adams',
'----------------------------------------------',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 17/OCT/2014',
'DESCRIPCION: Se agrega el proceso para fusionar lso registros de la tabla bdisolic:ss_refpersonales cuando el cliente incorrecto se encuentre como referencia (numcte_ref)',
'SUSTENTO: RQI 64 047',
'SOLICITA: Jose Angel Lopez Adams/Paul Quintero',
'----------------------------------------------',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 27/ENE/2015',
'DESCRIPCION: Se agrega el proceso para fusionar los registros de la tabla bdicheq:sc_cuenta_telefono y para que contemple el campo tp_biometria al pasar la informacion a si_fuscliente',
'SUSTENTO: RQI 64 068',
'SOLICITA: Jose Angel Lopez Adams',
'----------------------------------------------',
'AUTOR: Rocio Karina Marquez Coronel',
'FECHA: 14/ABR/2015',
'DESCRIPCION: Se modificaron estructuras de la fusion ya que agregaron campos nuevos a las tablas sc_maehis, sc_encabezado_edocta_factelect',
'SUSTENTO: RQI 64 081',
'SOLICITA: Jose Angel Lopez Adams',
'----------------------------------------------',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 23/JUL/2015',
'DESCRIPCION: Se agrega el proceso para fusionar los registros de la tabla bdinteg:si_huella_linea, bdinteg:si_huella_linea_hist y bdinteg:si_huella_linea_hist_chl',
'SUSTENTO: RQI 64 105',
'SOLICITA: Jaime Gonzalez',
'----------------------------------------------',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 07/05/2020',
'MODIFICACION: Se realiza clonacion de spl para eliminar BEGIN/COMMIT (error de transaccion desde SOC).',
'----------------------------------------------',
'AUTOR: Juan Francisco Ponce Damian',
'FECHA: 13/06/2023',
'MODIFICACION: Se agrega validacion para que no consulte datos vacios en las consulta a la tabla bdisolic:ss_refpersonales';

CREATE PROCEDURE "informix".sp_exportarcatalogocalles_web(pCatalogo CHAR(1), pFechaAct DATE, pSeparador CHAR(1), pEjecucion CHAR(1))
RETURNING  CHAR(6), CHAR(80);
    
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);
DEFINE cCadena                          CHAR (3000);
DEFINE vFechaArch                       DATE;
DEFINE vNomArch                         CHAR(30);
DEFINE vNomArchAux                      CHAR(40);
DEFINE vPath                            CHAR(50);
------------------------------------------------------------

-- Creado: JosÃ¯Â¿Â½ de JesÃ¯Â¿Â½s Almeida Inzunza
-- Fecha: 19 de octubre de 2009
-- Crear en BDINTEG
-- Se crea con el objetivo de exportar el total o una parcialidad de las zonas del catalogo

-- Modificado por: MACF
-- Fecha: 07/06/2010
-- Agregar parÃ¯Â¿Â½metro pEjecucion para determinar si es AutmÃ¯Â¿Â½tica o Manual

LET cCod_ret      = '00000';
LET sql_err       = 0;
LET cMensaje      = '';
LET cCadena       = '';
LET vNomArch      = 'si_catcalles_web';
LET vNomArchAux   = 'si_catcalles_web_Aux';
LET vPath         = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

--SET DEBUG FILE TO "/informix/vic/sp_ExportarCatalogoCallesWeb.out";
--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
    INTO   vFechaArch
    FROM   bdinteg:si_fechas WHERE empresa = '001';
    
    if pEjecucion = 'A' then
        select trim(valor) into vPath 
        from bdinteg:si_param_dom 
        where cod_param = 24; ---CAMBIAR PARAMETRO A NUMERO CORRECTO EN PRODUCCION
    else
        select trim(valor) || '/tmp/' into vPath 
        from bdinteg:si_param_dom 
        where cod_param = 24; ---CAMBIAR PARAMETRO A NUMERO CORRECTO EN PRODUCCION
    end if;
    LET vPath = TRIM(vPath);

    LET vNomArchAux = TRIM(vNomArchAux) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArchAux = TRIM(vNomArchAux);
    LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArch = TRIM(vNomArch);

IF (pCatalogo = 1) THEN
        
          				
		  LET cCadena = 'echo " unload to ' || trim(vPath) || trim(vNomArchAux)  || ' DELIMITER ''' || pSeparador || ''' SELECT a.numerocalle, limpia_cadenaweb(a.nombrecalle) '                
                || ' FROM BDINTEG:si_catcalles a '
                --|| ', BDINTEG:si_catsepomex b, BDINTEG:si_estados c, BDINTEG:si_ciudades d  '
				--|| ' where c.estado = d.estado and lpad(a.codigopostalzona,5,''0'') = b.d_codigo and c.estado = b.c_estado and a.numerociudad = d.ciudad_coppel '
                --|| ' and TRIM(a.nomzona_spmx) = b.d_asenta and TRIM(a.mnpio_spmx) = b.d_mnpio and d.ciudad_coppel > 0 and d.elegir IS NULL and nvl(a.nomzona_spmx,'''') <> '''' and nvl(a.pobzona_spmx,'''')<>'''' '
                --|| ' and nvl(a.mnpio_spmx,'''') <>'''' ' VALIDACION SEPOMEX
		    	|| '" >' || trim(vPath) ||'corre_si_catcalles_web.sql'; 
				
				
          System cCadena;

          let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catcalles_web.sql';
          System cCadena;

		  
          LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
          SYSTEM cCadena;

          let cCadena = 'rm ' || trim(vPath) || 'corre_si_catcalles_web.sql';
          System cCadena;    
          let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
          System cCadena; 
    
    
ELIF (pCatalogo = 0) THEN
     
LET cCadena = 'echo " unload to ' || trim(vPath) || trim(vNomArchAux)  || ' DELIMITER ''' || pSeparador || ''' SELECT a.numerocalle, limpia_cadenaweb(a.nombrecalle) '                                
				|| ' FROM BDINTEG:si_catcalles a '
				--|| ', BDINTEG:si_catsepomex b, BDINTEG:si_estados c, BDINTEG:si_ciudades d  '
				--|| ' where c.estado = d.estado and lpad(a.codigopostalzona,5,''0'') = b.d_codigo and c.estado = b.c_estado and a.numerociudad = d.ciudad_coppel '
                --|| ' and TRIM(a.nomzona_spmx) = b.d_asenta and TRIM(a.mnpio_spmx) = b.d_mnpio and d.ciudad_coppel > 0 and d.elegir IS NULL and nvl(a.nomzona_spmx,'''') <> '''' and nvl(a.pobzona_spmx,'''')<>'''' '
                --|| ' and nvl(a.mnpio_spmx,'''') <>'''' ' VALIDACION SEPOMEX
                || '  where f_inserta >= ''' || pFechaAct || ''''
				|| '" >' || trim(vPath) ||'corre_si_catcalles_web.sql'; 
				
				
          System cCadena;

          let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catcalles_web.sql';
          System cCadena;

		  
          LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
          SYSTEM cCadena;

          let cCadena = 'rm ' || trim(vPath) || 'corre_si_catcalles_web.sql';
          System cCadena;    
          let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
          System cCadena; 

   
ELSE

    LET cCod_ret = '00001';
    LET cMensaje = 'Parametro de Catalogo Invalido';    
    RETURN cCod_ret, cMensaje;
   
END IF;    

LET cMensaje = TRIM(vNomArch);
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Victor D. Vazquez',
'FECHA: 2023/06/12',
'DESCRIPCION: Se modifica para agregar la depuracion de caracteres especiales en algunos campos para SIWEB',
'BD: bdinteg',
'VERSION:20230612.100';

CREATE PROCEDURE "informix".sp_genera_reporte_tipo_cte()
RETURNING 
CHAR(5) AS CodRet;

----------------DEFINE VARIABLES----------------------
DEFINE sFechaEjecucion    CHAR(10);
DEFINE cCodRet        	  CHAR(5);
DEFINE cCodRetC           CHAR(5);
DEFINE iSqlErr	       	  INTEGER;
DEFINE cDesc          	  CHAR(50);
DEFINE iCtesTotl		  INTEGER;
DEFINE iCtesNorm		  INTEGER;
DEFINE iCtesECpl		  INTEGER;
DEFINE iCtesEBpl		  INTEGER;
DEFINE iCtesVip 		  INTEGER;
DEFINE iCtesRel 		  INTEGER;
DEFINE iEstatusSnRes 	  INTEGER;
DEFINE iEstatusCteNA 	  INTEGER;
DEFINE iEstatusReus 	  INTEGER;
DEFINE iEstatusDerArc 	  INTEGER;
DEFINE iEstatusVip   	  INTEGER;

DEFINE sDescMes           CHAR(10);   
DEFINE svt_fecha_hoy      DATE;
DEFINE svt_fecha_udia     DATE;
DEFINE sUdia              CHAR(2);
DEFINE sDiaP              CHAR(2);
DEFINE sMesP              CHAR(2);
DEFINE sAnoP              CHAR(4);

DEFINE iAcumuladoNorm     INTEGER;
DEFINE iAcumulaEbcp       INTEGER;
DEFINE iAcumulaEcpl       INTEGER;
DEFINE iAcumulaRel        INTEGER;
DEFINE iAcumulaVip        INTEGER;
DEFINE iAcumulaEsinRes    INTEGER;
DEFINE iAcumulaEcteNA     INTEGER;
DEFINE iAcumulaReus       INTEGER;
DEFINE iAcumulaDerArc     INTEGER;
DEFINE iAcumulaEstVip     INTEGER;

DEFINE iContador     	  INTEGER;
DEFINE cNumcte 		 	  CHAR(20);
DEFINE bEnTransaccion 	  BOOLEAN;
DEFINE cStatus_cred	  CHAR(2);

----------------INICIALIZA VARIABLES------------------
LET sFechaEjecucion     = '';
LET cCodRet             ='00000';
LET cCodRetC            ='00000';
LET iSqlErr	            = 0;
LET cDesc               ='';
LET iCtesTotl           = 0;
LET iCtesNorm           = 0;
LET iCtesECpl           = 0;
LET iCtesEBpl           = 0;
LET iCtesVip            = 0;
LET iCtesRel            = 0;
LET iEstatusSnRes       = 0;
LET iEstatusCteNA       = 0;
LET iEstatusReus        = 0;
LET iEstatusDerArc      = 0;
LET iEstatusVip         = 0;

LET sDescMes            ='';
LET svt_fecha_hoy       ='';
LET sUdia               ='';
LET sDiaP               ='';
LET sMesP               ='';
LET sAnoP               ='';

LET iAcumuladoNorm      = 0;
LET iAcumulaEbcp        = 0;
LET iAcumulaEcpl        = 0;
LET iAcumulaRel         = 0;
LET iAcumulaVip         = 0;
LET iAcumulaEsinRes     = 0;
LET iAcumulaEcteNA      = 0;
LET iAcumulaReus        = 0;
LET iAcumulaDerArc      = 0;
LET iAcumulaEstVip      = 0;

LET iContador 			= 0;
LET cNumcte 			= '';
LET bEnTransaccion 		= 'f';
LET cStatus_cred       = '00';

BEGIN

    ----------ERRORES DE INFORMIX-------------------------
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cDesc='Error no controlado';
			IF bEnTransaccion = 't' THEN
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet;
        END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/OMC/sp_genera_reporte_tipo_cte.out";
	--TRACE ON;
    
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-------------------------------------OBTIENE FECHA-------------------------------------------
	SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} add_months(fecha_hoy,-1) INTO svt_fecha_hoy
	FROM bdinteg:si_fechas
	WHERE empresa = '001';

    LET sDiaP = SUBSTR(svt_fecha_hoy,4,2);
    LET sMesP = SUBSTR(svt_fecha_hoy,0,2);
    LET sAnoP = SUBSTR(svt_fecha_hoy,7,4);
	
	SELECT LAST_DAY(mdy(sMesP,sDiaP,sAnoP)) INTO svt_fecha_udia
	FROM systables WHERE tabid = 1;
	
	LET sUdia = SUBSTR(svt_fecha_udia,4,2);
	---------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'si_tipo_prom_paso') THEN
		DROP TABLE "informix".si_tipo_prom_paso;
	END IF;
			
	CREATE TABLE "informix".si_tipo_prom_paso(
	numcte CHAR(20)
	);
	
	--set pdqpriority 5;

	--begin;
		CREATE INDEX "informix".idx_numcte_tipo_promo_paso
		ON "informix".si_tipo_prom_paso(numcte) using btree in datos00 online;
	--commit;

	--set pdqpriority 0;

	update statistics medium for table "informix".si_tipo_prom_paso;
	--IFRS Se contemplan los nuevos estatus por Etapas
	BEGIN WORK;
		LET bEnTransaccion = 't';
		FOREACH WITH HOLD
		
			SELECT {+INDEX (bdicred:"informix".sd_maecred idx_sd_maecred4)}	numcte,status_cred
			INTO cNumcte, cStatus_cred
				from bdicred:sd_maecred 
				where empresa = '001' 
				and num_producto in ('6600','6500','7000','8100','6001')
				
			 
			IF(cStatus_cred)in ('AA','BA','BT','E1','E2','E3') THEN
			
			INSERT INTO si_tipo_prom_paso(numcte) VALUES (cNumcte);
			LET iContador = iContador+1;
			
			END IF;
			
			IF(iContador == 1000) THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF;
		
		END FOREACH;
	COMMIT WORK;
	LET bEnTransaccion = 'f';
	------------------------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES TOTAL-------------------------------------------
	SELECT {+INDEX (bdinteg:"informix".si_tipo_prom_paso idx_numcte_tipo_promo_paso)} COUNT(DISTINCT a.numcte) 
	INTO iCtesTotl
	FROM si_cliente a
		INNER JOIN si_tipo_prom_paso c
				ON a.numcte = c.numcte
	WHERE empresa = '001' AND tpo_persona = 01;

	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES NORMALES-------------------------------------------
	SELECT {+INDEX (bdinteg:"informix".si_tipo_prom_paso idx_numcte_tipo_promo_paso)} COUNT(*) 
	INTO iCtesNorm
	FROM si_cliente a 
		INNER JOIN si_calificacion_cliente b
				ON a.numcte = b.numcte
		INNER JOIN si_tipo_prom_paso c
				ON b.numcte = c.numcte
	WHERE a.empresa = '001' AND a.tpo_persona = 01
	AND b.calificacion_cliente = 0;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES EMPLEADO COPPEL-------------------------------------------
	SELECT COUNT(*) 
	INTO iCtesECpl
	FROM si_calificacion_cliente 	
	WHERE calificacion_cliente = 1;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES EMPLEADO BANCOPPEL-------------------------------------------
	SELECT COUNT(*) 
	INTO iCtesEBpl
	FROM si_calificacion_cliente 	
	WHERE calificacion_cliente = 2;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES VIP-------------------------------------------
	SELECT COUNT(*) 
	INTO iCtesVip
	FROM si_calificacion_cliente 	
	WHERE calificacion_cliente = 3;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES RELACIONADOS-------------------------------------------
	SELECT COUNT(*) 
	INTO iCtesRel
	FROM si_calificacion_cliente 	
	WHERE calificacion_cliente = 4;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES SIN RESTRICCIONES-------------------------------------------
	SELECT COUNT(*) 
	INTO iEstatusSnRes
	FROM si_calificacion_cliente 	
	WHERE estatus_cliente = 1;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES NO ACEPTAN-------------------------------------------
	SELECT COUNT(*) 
	INTO iEstatusCteNA
	FROM si_calificacion_cliente 	
	WHERE estatus_cliente = 2;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES REUS-------------------------------------------
	SELECT COUNT(*) 
	INTO iEstatusReus
	FROM si_calificacion_cliente 	
	WHERE estatus_cliente = 3;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES DERECHOS ARCO-------------------------------------------
	SELECT COUNT(*) 
	INTO iEstatusDerArc
	FROM si_calificacion_cliente 	
	WHERE estatus_cliente = 4;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES ESTATUS VIP-------------------------------------------
	SELECT COUNT(*) 
	INTO iEstatusVip
	FROM si_calificacion_cliente 	
	WHERE estatus_cliente = 5;
	--------------------------------------------------------------------------------
	
	-----------------------------------VALIDA CIFRAS---------------------------------	
	SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)}
	SUBSTR(LOWER(DECODE(MONTH(svt_fecha_hoy),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(svt_fecha_hoy)),0,3)
	||'-'|| SUBSTR(sAnoP,3,2)
	INTO sDescMes  
	FROM bdinteg:si_fechas
	WHERE empresa = '001';			
			
	IF(iCtesNorm = '' OR iCtesNorm IS NULL) THEN
		LET iCtesNorm=0;
	END IF;
	
	IF(iCtesEBpl = '' OR iCtesEBpl IS NULL) THEN
		LET iCtesEBpl=0;
	END IF;
	
	IF(iCtesECpl = '' OR iCtesECpl IS NULL) THEN
		LET iCtesECpl=0;
	END IF;
	
	IF(iCtesRel = '' OR iCtesRel IS NULL) THEN
		LET iCtesRel=0;
	END IF;
	
	IF(iCtesVip = '' OR iCtesVip IS NULL) THEN
		LET iCtesVip=0;
	END IF;
	
	IF(iEstatusSnRes = '' OR iEstatusSnRes IS NULL) THEN
		LET iEstatusSnRes=0;
	END IF;
	
	IF(iEstatusCteNA = '' OR iEstatusCteNA IS NULL) THEN
		LET iEstatusCteNA=0;
	END IF;
	
	IF(iEstatusReus = '' OR iEstatusReus IS NULL) THEN
		LET iEstatusReus=0;
	END IF;
	
	IF(iEstatusDerArc = '' OR iEstatusDerArc IS NULL) THEN
		LET iEstatusDerArc=0;
	END IF;
	
	IF(iEstatusVip = '' OR iEstatusVip IS NULL) THEN
		LET iEstatusVip=0;
	END IF;
	
	LET iCtesNorm = iCtesTotl - iCtesNorm;

	---------------------------------------------------------------------------------		
	--INSERT INTO "informix".si_reporte_tipo_cliente(mes, norm, ebcp, ecop, rel, vip, sin_restricciones, cliente_no_acepta, reus, derechos_arco, estatus_vip) 
    --VALUES(sDescMes, iCtesNorm, iCtesEBpl, iCtesECpl, iCtesRel, iCtesVip, iEstatusSnRes, iEstatusCteNA, iEstatusReus, iEstatusDerArc, iEstatusVip);
    --------------------------------------------------------------------------------
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'NORM',iCtesNorm, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'EBCP',iCtesEBpl, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'ECOP',iCtesECpl, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'REL',iCtesRel, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'VIP',iCtesVip, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'SIN RESTRICCIONES',iEstatusSnRes, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'CLIENTE NO ACEPTA',iEstatusCteNA, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
	VALUES(sDescMes, 'REUS',iEstatusReus, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'DERECHOS ARCO',iEstatusDerArc, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'ESTATUS VIP',iEstatusVip, 0);
	
	LET iAcumuladoNorm = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'NORM');
	LET iAcumulaEbcp = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'EBCP');
	LET iAcumulaEcpl = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'ECOP');
	LET iAcumulaRel = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'REL');
	LET iAcumulaVip = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'VIP');
	
	LET iAcumulaEsinRes = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'SIN RESTRICCIONES');
	LET iAcumulaEcteNA = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'CLIENTE NO ACEPTA');
	LET iAcumulaReus = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'REUS');
	LET iAcumulaDerArc = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'DERECHOS ARCO');
	LET iAcumulaEstVip = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'ESTATUS VIP');
	
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumuladoNorm WHERE tipo = 'NORM';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaEbcp WHERE tipo = 'EBCP';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaEcpl WHERE tipo = 'ECOP';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaRel WHERE tipo = 'REL';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaVip WHERE tipo = 'VIP';
	
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaEsinRes WHERE tipo = 'SIN RESTRICCIONES';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaEcteNA WHERE tipo = 'CLIENTE NO ACEPTA';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaReus WHERE tipo = 'REUS';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaDerArc WHERE tipo = 'DERECHOS ARCO';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaEstVip WHERE tipo = 'ESTATUS VIP';
	
	LET cDesc= 'PROCESO EXITOSO';
	RETURN cCodRet;
END 
END PROCEDURE;