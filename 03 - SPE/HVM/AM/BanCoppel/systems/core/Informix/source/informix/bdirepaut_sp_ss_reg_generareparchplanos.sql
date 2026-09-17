CREATE PROCEDURE "informix".sp_ss_reg_generareparchplanos(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pRuta CHAR(100), pTrama CHAR(250))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	DEFINE cAutoridad CHAR(8);
	DEFINE cReporte CHAR(35);
	DEFINE cDescripcion CHAR(100);
	DEFINE cStatus CHAR(1);
	DEFINE cDescStatus CHAR(10);
	
	DEFINE iSerial INTEGER;
	DEFINE cRespMensaje CHAR(45);
	
	DEFINE cIdAutoridad CHAR(8); 
	DEFINE cEmpresa_df CHAR(3); 
	DEFINE cCveReporte CHAR(10); 
	DEFINE iFormSalida SMALLINT; 
	DEFINE iNumCampo SMALLINT; 
	DEFINE cDescCampo CHAR(50);
	DEFINE cTipoDato CHAR(1); 
	DEFINE iLongitud SMALLINT; 
	DEFINE iDecimales SMALLINT; 
	DEFINE cTipoAcceso CHAR(1); 
	DEFINE iDepRenglon SMALLINT; 
	DEFINE iNumColumna INTEGER; 
	DEFINE cFormato CHAR(20); 
	
	DEFINE cIdentAutoridad CHAR(8);
	DEFINE cClaveReporte CHAR(10);
	DEFINE cEmpresa_rf CHAR(3);
	DEFINE iNumeroRenglon INTEGER;
	DEFINE cDescripCuenta CHAR(100);
	DEFINE cDescripRenglon CHAR(100);
	DEFINE iRenglonAutoridad INTEGER;
	DEFINE cClavePeriodicidad CHAR(2);
	DEFINE dSaldocolumna1 DECIMAL(18,2);
	DEFINE dSaldocolumna2 DECIMAL(18,2);
	DEFINE dSaldocolumna3 DECIMAL(18,2);
	DEFINE dSaldocolumna4 DECIMAL(18,2);
	DEFINE dSaldocolumna5 DECIMAL(18,2);
	DEFINE dSaldocolumna6 DECIMAL(18,2);
	DEFINE dSaldocolumna7 DECIMAL(18,2);
	DEFINE dSaldocolumna8 DECIMAL(18,2);
	DEFINE dSaldocolumna9 DECIMAL(18,2);
	DEFINE dSaldocolumna10 DECIMAL(18,2);
	DEFINE dSaldocolumna11 DECIMAL(18,2);
	DEFINE dSaldocolumna12 DECIMAL(18,2);
	DEFINE dSaldocolumna13 DECIMAL(18,2);
	DEFINE dSaldocolumna14 DECIMAL(18,2);
	DEFINE dSaldocolumna15 DECIMAL(18,2);
	DEFINE dSaldocolumna16 DECIMAL(18,2);
	DEFINE dSaldocolumna17 DECIMAL(18,2);
	DEFINE dSaldocolumna18 DECIMAL(18,2);
	DEFINE dSaldocolumna19 DECIMAL(18,2);
	DEFINE dSaldocolumna20 DECIMAL(18,2);
	DEFINE dSaldocolumna21 DECIMAL(18,2);
	DEFINE dSaldocolumna22 DECIMAL(18,2);
	DEFINE dSaldocolumna23 DECIMAL(18,2);
	DEFINE dSaldocolumna24 DECIMAL(18,2);
	DEFINE dSaldocolumna25 DECIMAL(18,2);
	
	DEFINE iRegistros INTEGER;
	DEFINE iGraba INTEGER;
	DEFINE iFormatoAnt INTEGER;
	DEFINE cDato CHAR(25);
	DEFINE cDatoFormat CHAR(20);
	DEFINE cRenglon CHAR(255);
	DEFINE cFormat CHAR(11);
	DEFINE cSeleccion CHAR(255);
	DEFINE cQuery CHAR(255);
	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE iCountRep INTEGER;
	DEFINE iProcesaRep INT;
	DEFINE iArmaReporte INT;
	
	DEFINE cArchivoCP CHAR(45);
	DEFINE cCmdQuery CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	LET cAutoridad = '';
	LET cReporte = '';
	LET cDescripcion = '';
	LET cStatus = '';
	LET cDescStatus = '';
	
	LET iSerial = 0;
	LET cRespMensaje = '';
	
	LET cIdAutoridad = ''; 
	LET cEmpresa_df = ''; 
	LET cCveReporte = ''; 
	LET iFormSalida = 0; 
	LET iNumCampo = 0;  
	LET cDescCampo = '';
	LET cTipoDato = ''; 
	LET iLongitud = 0;  
	LET iDecimales = 0;  
	LET cTipoAcceso = '';
	LET iDepRenglon = 0;  
	LET iNumColumna = 0;  
	LET cFormato = '';
	
	LET cIdentAutoridad = '';
	LET cClaveReporte = '';
	LET cEmpresa_rf = '';
	LET iNumeroRenglon = 0;
	LET cDescripCuenta = '';
	LET cDescripRenglon = '';
	LET iRenglonAutoridad = 0;
	LET cClavePeriodicidad = '';
	LET dSaldocolumna1 = 0.00;
	LET dSaldocolumna2 = 0.00;
	LET dSaldocolumna3 = 0.00;
	LET dSaldocolumna4 = 0.00;
	LET dSaldocolumna5 = 0.00;
	LET dSaldocolumna6 = 0.00;
	LET dSaldocolumna7 = 0.00;
	LET dSaldocolumna8 = 0.00;
	LET dSaldocolumna9 = 0.00;
	LET dSaldocolumna10 = 0.00;
	LET dSaldocolumna11 = 0.00;
	LET dSaldocolumna12 = 0.00;
	LET dSaldocolumna13 = 0.00;
	LET dSaldocolumna14 = 0.00;
	LET dSaldocolumna15 = 0.00;
	LET dSaldocolumna16 = 0.00;
	LET dSaldocolumna17 = 0.00;
	LET dSaldocolumna18 = 0.00;
	LET dSaldocolumna19 = 0.00;
	LET dSaldocolumna20 = 0.00;
	LET dSaldocolumna21 = 0.00;
	LET dSaldocolumna22 = 0.00;
	LET dSaldocolumna23 = 0.00;
	LET dSaldocolumna24 = 0.00;
	LET dSaldocolumna25 = 0.00;
	
	LET iRegistros = 0;
	LET iGraba = 0;
	LET iFormatoAnt = 0;
	LET cDato = '';
	LET cDatoFormat = '';
	LET cRenglon = '';
	LET cFormat = '';
	LET cSeleccion = '';
	LET cQuery = '';
	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/informix/bin/';
	LET iCountRep = 0;
	LET iProcesaRep = 0;
	LET iArmaReporte = 0;

	LET cArchivoCP = '';
	LET cCmdQuery = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				IF ven_transacc = 1 THEN
					ROLLBACK WORK; --		
				END IF;
				
				SET LOCK MODE TO WAIT 3;
				UPDATE bdirepaut:"informix".sw_reg_statusproceso
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535,-255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ss_reg_generareparchplanos.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdirepaut:"informix".sw_reg_statusproceso WHERE usuario = TRIM(pUsuario);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3; 
		INSERT INTO bdirepaut:"informix".sw_reg_statusproceso(usuario,status,path_file,nombre_file,error_proceso,error)
		VALUES(pUsuario,'I',TRIM(pRuta),'','',TRIM(cCodRet));  
		
		IF pFecha IS NULL OR pRuta = '' OR pTrama = '' THEN
			LET cCodRet = '00003';
			SET LOCK MODE TO WAIT 3;
			UPDATE bdirepaut:"informix".sw_reg_statusproceso
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		--IF cCodRet <> '00000' THEN
			--SET LOCK MODE TO WAIT 3;
			--UPDATE bdicnweb:"informix".sw_reg_statusproceso
			--SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			--RETURN cCodRet;
		--END IF;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos WHERE usuario_proceso = TRIM(pUsuario);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
			LET ven_transacc = 1;
		
			FOREACH
				
					EXECUTE PROCEDURE bdirepaut:"informix".sp_split_cadena(pTrama, '|')
					INTO iIdRegistro
					
					SELECT autoridad,reporte,descripcion,desc_status
					INTO cAutoridad,cReporte,cDescripcion,cDescStatus
					FROM bdirepaut:"informix".sw_reg_reparchivosplanos
					WHERE usuario_proceso = pUsuario AND fecha_proceso = pFecha
					AND id_serial = iIdRegistro;
					
					IF NVL(cReporte,'') = 'R242411' THEN
					
						LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
						
						LET cCmd1 ="";
						LET cCmd1 ="SELECT numreg,clavereporte,registro";
						LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r24a WHERE identautoridad = 'CNBV' AND empresa = '001'";
						LET cCmd1 =""||TRIM(cCmd1)||" AND clavereporte IN ('R242411','R242412') ORDER BY numreg;";
						LET cCmd1 =" "||TRIM(cCmd1);
				
						LET cSql = '';
						LET cSql = 'echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''\t'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
						SYSTEM TRIM(cSql);
						
						LET cSql = '';
						LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
						SYSTEM TRIM(cSql);
						
						LET cSql = '';
						--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
						LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
						SYSTEM TRIM(cSql);  
						
						-- Eliminamos el archivo query.sql
						LET cSql = '';
						LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
						SYSTEM TRIM(cSql);

						-- Se manipula el archivo para agregar el salto de línea
						LET cSql = '';
						LET cSql = 'chmod 777 '||TRIM(cRutaGral);
						SYSTEM TRIM(cSql);
						
						LET cSql = '';
						LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
						SYSTEM TRIM(cSql);
						
						-- Eliminamos el archivo original
						LET cSql = '';
						LET cSql = "rm -rf "||TRIM(cRutaGral);
						SYSTEM TRIM(cSql);
						
						LET cSql = '';
						LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
						SYSTEM TRIM(cSql);
						
						-- Eliminamos el caracter delimitador '\t'.
						LET cSql = '';
						LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
						SYSTEM TRIM(cSql);

						-- Se manipula el archivo para agregar el salto de línea
						LET cSql = '';
						LET cSql = 'chmod 777 '||TRIM(cRutaGral);
						SYSTEM TRIM(cSql);

						LET cSql = '';
						LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
						SYSTEM TRIM(cSql);
						
						-- Se renombra el archivo temporal por el nombre original
						LET cSql = '';
						LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
						SYSTEM TRIM(cSql);
							
						LET iCountRep = iCountRep + 1;
						INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
						VALUES(TRIM(cReporte)||'.txt',pUsuario,pFecha);
					
					ELSE
					
						IF NVL(cReporte,'') = 'R040434MN' THEN
					
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							LET iSerial = iSerial + 1;
						
							LET cCmd1 ="";
							LET cCmd1 ="SELECT '434' AS clave,'"|| iSerial ||"' AS secuencia,TRIM(fecha_apertura),tipo_cred,";
							LET cCmd1 =""||TRIM(cCmd1)||" catg_cred,tipo_tasa_int,TRIM(interv_monto_otorgado),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(num_creditos),ROUND(monto_otorgado),ROUND(sdo_cap_insoluto_ini),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(comision_aper_cred),ROUND(cargo_nvas_disp),ROUND(cargo_inter_deven),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(cargo_com_periodicas),ROUND(cagro_com_anual),ROUND(abono_pago_realiza),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(abono_bon_qui_des_cas),ROUND(abono_venta_cartera),ROUND(abono_reestructura),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(monto_pago_exg),tasa_interes_prom_pon,tasa_interes_min_api,";
							LET cCmd1 =""||TRIM(cCmd1)||" tasa_interes_max_api,ROUND(sdo_cap_insoluto_fin),ROUND(plazo_vecn_prom_pon),";
							LET cCmd1 =""||TRIM(cCmd1)||" prce_fina_val_bien::DECIMAL(6,2),ROUND(respon_total),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(per_atraso_men_30),ROUND(sdo_cap_atraso_men_30),ROUND(per_atraso_30),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(sdo_cap_atraso_30),ROUND(per_atraso_60),ROUND(sdo_cap_atraso_60),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(per_atraso_90),ROUND(sdo_cap_atraso_90),ROUND(per_atraso_120),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(sdo_cap_atraso_120),ROUND(per_atraso_150),ROUND(sdo_cap_atraso_150),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(no_pago_fec_lim),ROUND(sdo_no_pago_fec_lim),ROUND(pago_inf_min_exg),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(sdo_pago_inf_min_exg),ROUND(pag_igusupmin_infint),ROUND(sdo_pag_igusupmin_infint),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(pag_igusu_nogenint),ROUND(sdo_pag_igusu_nogenint),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(cred_baja_restructura),ROUND(cred_venta_cartera),ROUND(cred_fin_cancel_contra),";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(cred_baja_quit_cas)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r04B0434 ORDER BY 1,2,3,4,5;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R040435MN' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							LET iSerial = iSerial + 1;
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT '435' AS clave,'"|| iSerial ||"' AS secuencia,TRIM(localidad_inegi),tipo_cred,situacion_cred,num_creditos,";
							LET cCmd1 =""||TRIM(cCmd1)||" ROUND(monto_otorgado),ROUND(sdo_prin_ini_per),ROUND(sdo_prin_fin_per)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r04b0435 ORDER BY situacion_cred,localidad_inegi;";
							LET cCmd1 =" "||TRIM(cCmd1);
						
							LET iProcesaRep = 1;
							
						ELIF NVL(cReporte,'') = 'R24B2421' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT '2421' AS clave,TRIM(municipio),estado,tipo_prud,tipo_mod,moneda,TRIM(num_cuentas),saldo_prud";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r24b2421 ORDER BY estado,municipio,tipo_prud;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R24B2422' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT formulario,municipio,estado,tipo_inf_oper,num_total";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r24b2422 ORDER BY estado,municipio,tipo_inf_oper;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R24B2423' THEN					
						
							--R24B2423
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT '2423' AS clave_formulario,contador,numcte,cod_postal,tporelpgtia,tpoprocapt,modalidad,moneda,sdofinper";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".r24b2423;";
							LET cCmd1 =" "||TRIM(cCmd1);

							LET cSql = '';
							LET cSql = 'echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);  
							
							-- Eliminamos el archivo query.sql
							LET cSql = '';
							LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el archivo original
							LET cSql = '';
							LET cSql = "rm -rf "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el caracter delimitador ';'.
							LET cSql = '';
							LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Se renombra el archivo temporal por el nombre original
							LET cSql = '';
							LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
							VALUES(TRIM(cReporte)||'.txt',pUsuario,pFecha);
							
							--COD_POST
							LET cReporte = 'COD_POST';
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(DISTINCT(NVL(cod_postal,''))) AS cod_postal";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".r24b2423;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R24C2431' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(nombre_form),TRIM(persona),TRIM(rfc_persona),per_juridica,tip_relac_ent,tip_oper_bala,clase_oper_rel,tipo_moneda,ROUND(importe)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r24c2431";
							LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha = '"|| TRIM(pFecha) ||"';";
							LET cCmd1 =" "||TRIM(cCmd1);

							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R24D2441' THEN
							
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(nombre_form),TRIM(tip_cta_transac),TRIM(can_transa),TRIM(tip_ope_rli_usu),ROUND(monto_ope),num_ope,num_cli";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r24D2441;";
							LET cCmd1 =" "||TRIM(cCmd1);

							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R24D2442' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(nombre_form),TRIM(tip_cta_transac),TRIM(can_transa),TRIM(tip_ope_rli_usu),TRIM(frecuencia),num_cli";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r24D2442;";
							LET cCmd1 =" "||TRIM(cCmd1);

							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R24E2450' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT formulario,producto,tpo_cte,personal,dato";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".r24e2450;";
							LET cCmd1 =" "||TRIM(cCmd1);

							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R24E2451' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(fomulario),TRIM(prodoserv),TRIM(moneda),TRIM(tipoinstrumento),TRIM(tipoinformacion),TRIM(dato)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r24e2451;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R24E2452' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(fomulario),TRIM(prodoserv),TRIM(estado),TRIM(municipio),TRIM(tipo_dato),SUM(dato::INTEGER) AS dato";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r24e2452";
							LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY fomulario,prodoserv,estado,municipio,tipo_dato";
							LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY prodoserv,estado,municipio;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R15B1521' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(nombre_form),TRIM(periodo),per_juridica,serv_banca,TRIM(tip_usuario),num_contratos,num_pers_fact,num_usu_opr_mor,niv_cta,TRIM(tip_ope_rea),num_operacines,ROUND(monto_tot)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r15b1521";
							LET cCmd1 =""||TRIM(cCmd1)||" WHERE nombre_form = '1521';";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R15B1522' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(nombre_form),TRIM(periodo),TRIM(tip_usuario),serv_banca,num_usu_opr_mor,TRIM(tip_ope_rea),num_operacines,ROUND(monto_tot)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r15b1521";
							LET cCmd1 =""||TRIM(cCmd1)||" WHERE nombre_form = '1522';";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'R026' THEN
						
							--11C
							LET cCmd1 ="";
							LET cCmd1 ="SELECT FIRST 1 TRIM(fecha_periodo),TRIM(clave_entidad)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r026_11 ORDER BY num_secuencia ASC;";
							LET cCmd1 =" "||TRIM(cCmd1);
						
							LET cSql = '';
							LET cSql = 'echo "UNLOAD TO '||TRIM(pRuta)||'R02611C.txt'||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);  
							
							-- Eliminamos el archivo query.sql
							LET cSql = '';
							LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el archivo original
							LET cSql = '';
							LET cSql = "rm -rf "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el caracter delimitador ';'.
							LET cSql = '';
							LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Se renombra el archivo temporal por el nombre original
							LET cSql = '';
							LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
							VALUES('R02611C.txt',pUsuario,pFecha);

							--11D
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(clave_formulario),num_secuencia,TRIM(op_admin),TRIM(id_admin),TRIM(rfc_admin),TRIM(tipo_movimiento),";
							LET cCmd1 =""||TRIM(cCmd1)||" TRIM(id),TRIM(nombre),TRIM(rfc),TRIM(per_juridica),TRIM(operacion_contratada),TRIM(causa_baja)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r026_11 ORDER BY num_secuencia ASC;";
							LET cCmd1 =" "||TRIM(cCmd1);
						
							LET cSql = '';
							LET cSql = 'echo "UNLOAD TO '||TRIM(pRuta)||'R02611D.txt'||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);  
							
							-- Eliminamos el archivo query.sql
							LET cSql = '';
							LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);	
							
							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el archivo original
							LET cSql = '';
							LET cSql = "rm -rf "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el caracter delimitador ';'.
							LET cSql = '';
							LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Se renombra el archivo temporal por el nombre original
							LET cSql = '';
							LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
							VALUES('R02611D.txt',pUsuario,pFecha);
							
							--12C
							LET cCmd1 ="";
							LET cCmd1 ="SELECT FIRST 1 TRIM(fecha_periodo),TRIM(clave_entidad)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r026_12 ORDER BY num_secuencia ASC;";
							LET cCmd1 =" "||TRIM(cCmd1);
						
							LET cSql = '';
							LET cSql = 'echo "UNLOAD TO '||TRIM(pRuta)||'R02612C.txt'||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);  
							
							-- Eliminamos el archivo query.sql
							LET cSql = '';
							LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);

							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el archivo original
							LET cSql = '';
							LET cSql = "rm -rf "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el caracter delimitador ';'.
							LET cSql = '';
							LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Se renombra el archivo temporal por el nombre original
							LET cSql = '';
							LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
							VALUES('R02612C.txt',pUsuario,pFecha);						
							
							--12D
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(clave_formulario),num_secuencia,TRIM(id_comisionista),TRIM(rfc_comisionista),TRIM(tipo_movimiento),";
							LET cCmd1 =""||TRIM(cCmd1)||" TRIM(clave_establecimiento),TRIM(localidad_inegi),TRIM(causa_baja)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r026_12 ORDER BY num_secuencia ASC;";
							LET cCmd1 =" "||TRIM(cCmd1);
						
							LET cSql = '';
							LET cSql = 'echo "UNLOAD TO '||TRIM(pRuta)||'R02612D.txt'||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);  
							
							-- Eliminamos el archivo query.sql
							LET cSql = '';
							LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);	
						
							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el archivo original
							LET cSql = '';
							LET cSql = "rm -rf "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el caracter delimitador ';'.
							LET cSql = '';
							LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Se renombra el archivo temporal por el nombre original
							LET cSql = '';
							LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
							VALUES('R02612D.txt',pUsuario,pFecha);
						
							--13C
							LET cCmd1 ="";
							LET cCmd1 ="SELECT FIRST 1 TRIM(fecha_periodo),TRIM(clave_entidad),ROUND(captacion_mensual_pro),ROUND(saldo_ctas_moviles),TRIM(num_ctas_moviles_aperturadas)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r026_13 ORDER BY num_secuencia ASC;";
							LET cCmd1 =" "||TRIM(cCmd1);
						
							LET cSql = '';
							LET cSql = 'echo "UNLOAD TO '||TRIM(pRuta)||'R02613C.txt'||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);  
							
							-- Eliminamos el archivo query.sql
							LET cSql = '';
							LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);	
							
							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el archivo original
							LET cSql = '';
							LET cSql = "rm -rf "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el caracter delimitador ';'.
							LET cSql = '';
							LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Se renombra el archivo temporal por el nombre original
							LET cSql = '';
							LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
							VALUES('R02613C.txt',pUsuario,pFecha);
							
							--13D
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(clave_formulario),num_secuencia,TRIM(id_admin),TRIM(id_comisionista),TRIM(clave_establecimiento),TRIM(localidad_inegi),";
							LET cCmd1 =""||TRIM(cCmd1)||" TRIM(tipo_operacion),medio_pago_utilizado,ROUND(monto_operaciones_realizadas),num_operaciones,num_clientes_operaciones";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r026_13 ORDER BY num_secuencia ASC;";
							LET cCmd1 =" "||TRIM(cCmd1);
						
							LET cSql = '';
							LET cSql = 'echo "UNLOAD TO '||TRIM(pRuta)||'R02613D.txt'||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);  
							
							-- Eliminamos el archivo query.sql
							LET cSql = '';
							LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);	
							
							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el archivo original
							LET cSql = '';
							LET cSql = "rm -rf "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el caracter delimitador ';'.
							LET cSql = '';
							LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Se renombra el archivo temporal por el nombre original
							LET cSql = '';
							LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
							VALUES('R02613D.txt',pUsuario,pFecha);
							
							--ModulosSinAlta
							LET cReporte = 'R026ModulosSinAlta';
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(sucursal) FROM bdicheq:""informix"".sc_movs_corresp";
							LET cCmd1 =""||TRIM(cCmd1)||" WHERE MONTH(fecha)||YEAR(fecha) = MONTH(CURRENT) -1||YEAR(CURRENT)";
							LET cCmd1 =""||TRIM(cCmd1)||" AND sucursal NOT IN (SELECT clave FROM bdirepaut:""informix"".sp_r026_establecimiento AS a WHERE causa_baja <> 1";
							LET cCmd1 =""||TRIM(cCmd1)||" AND a.periodo_afectacion = (SELECT MAX(b.periodo_afectacion)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r026_establecimiento AS b WHERE a.clave =  b.clave))";
							LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY sucursal";
							LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY sucursal;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
							
						ELIF NVL(cReporte,'') = 'R027' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(clave_formulario),num_secuencia_ope,TRIM(folio_reclamacion),TRIM(fecha_reclamacion),TRIM(fechasuceso),";
							LET cCmd1 =""||TRIM(cCmd1)||" TRIM(num_cuenta_tdc_tdd_tpb),producto,canal,motivo_reclamacion,importe_reclamado,estado_reclamacion,";
							LET cCmd1 =""||TRIM(cCmd1)||" resolucion,TRIM(fecha_resolucion),causa_resolucion,importe_abonado_cliente,TRIM(fecha_abono_cliente),";
							LET cCmd1 =""||TRIM(cCmd1)||" importe_recuperado,quebranto_institucion";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r027";
							LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY num_secuencia_ope;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET cSql = '';
							LET cSql = 'echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);  
							
							-- Eliminamos el archivo query.sql
							LET cSql = '';
							LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);	
							
							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el archivo original
							LET cSql = '';
							LET cSql = "rm -rf "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el caracter delimitador ';'.
							LET cSql = '';
							LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);

							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Se renombra el archivo temporal por el nombre original
							LET cSql = '';
							LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
							VALUES(TRIM(cReporte)||'.txt',pUsuario,pFecha);
							
							--R027_Inconsistencias
							IF EXISTS(SELECT COUNT(folio_reclamacion) FROM bdirepaut:"informix".sp_r027_inconsistencias) THEN
								
								LET cReporte = TRIM(cReporte)||'_Inconsistencias';
								LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
								
								LET cCmd1 ="";
								LET cCmd1 ="SELECT TRIM(clave_formulario),num_secuencia_ope,TRIM(folio_reclamacion),TRIM(fecha_reclamacion),TRIM(fechasuceso),";
								LET cCmd1 =""||TRIM(cCmd1)||" TRIM(num_cuenta_tdc_tdd_tpb),producto,canal,motivo_reclamacion,importe_reclamado,estado_reclamacion,";
								LET cCmd1 =""||TRIM(cCmd1)||" resolucion,TRIM(fecha_resolucion),causa_resolucion,importe_abonado_cliente,TRIM(fecha_abono_cliente),";
								LET cCmd1 =""||TRIM(cCmd1)||" importe_recuperado,quebranto_institucion,TRIM(descrip_inc)";
								LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r027_inconsistencias";
								LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY num_secuencia_ope;";
								LET cCmd1 =" "||TRIM(cCmd1);
								
								LET iProcesaRep = 1;
								
							ELSE
								--LET cRespMensaje = 'No Existe Registros con Errores.';
								LET iProcesaRep = 0;
							END IF;
						
						ELIF NVL(cReporte,'') = 'R28A2811' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(fecha_concurr),TRIM(fecha_registro),TRIM(fecha_contable),TRIM(num_evento_sen),TRIM(num_evento_mul),";
							LET cCmd1 =""||TRIM(cCmd1)||" TRIM(riesgo_ope),monto_perdida,monto_gasto,monto_recuper,linea_negocio,TRIM(cat_linea_neg),";
							LET cCmd1 =""||TRIM(cCmd1)||" mayor_impacto,TRIM(cat_may_impct),prod_afectado,TRIM(cat_prod_afec),TRIM(canal),TRIM(causa),TRIM(reg_contable)";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_r28a2811";
							LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY fecha_concurr;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
						
						ELIF NVL(cReporte,'') = 'ANEXO43' THEN
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT 2,TO_CHAR(fecha,'%Y%m%d'),TRIM(descripcuenta),";
							LET cCmd1 =""||TRIM(cCmd1)||" LPAD(ROUND(saldocolumna1),19,'0'),LPAD(ROUND(saldocolumna2),19,'0'),LPAD(ROUND(saldocolumna3),19,'0'),LPAD(ROUND(saldocolumna1+saldocolumna2+saldocolumna3),19,'0')";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_resumenfiltro_anexo";
							LET cCmd1 =""||TRIM(cCmd1)||" WHERE clavereporte = 'ANEXO43'";
							LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY fecha,renglonautoridad;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							LET iProcesaRep = 1;
							
						ELIF NVL(cReporte,'') = 'ANEX43PREV' THEN	
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';					
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT clave,fecha,descripcuenta,saldo1,saldo2,saldo3,saldo4 FROM ";
							LET cCmd1 =""||TRIM(cCmd1)||" (SELECT 1 clave,MAX(TO_CHAR(fecha,'%Y%m%d'))fecha,TRIM(descripcuenta)descripcuenta,renglonautoridad,";
							LET cCmd1 =""||TRIM(cCmd1)||" LPAD(ROUND(SUM(saldocolumna1)),19,'0')saldo1,LPAD(ROUND(SUM(saldocolumna2)),19,'0')saldo2,LPAD(ROUND(SUM(saldocolumna3)),19,'0')saldo3,LPAD(ROUND(SUM(saldocolumna1+saldocolumna2+saldocolumna3)),19,'0')saldo4";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:sp_resumenfiltro_anexo";
							LET cCmd1 =""||TRIM(cCmd1)||" WHERE clavereporte = 'ANEX43PREV'";
							LET cCmd1 =""||TRIM(cCmd1)||" GROUP BY descripcuenta,renglonautoridad)A";
							LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY renglonautoridad;";
							LET cCmd1 =" "||TRIM(cCmd1);	
							
						/*ELIF NVL(cReporte,'') = 'ANEX43PREV' THEN				
						
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(clavereporte),fecha,TRIM(descripcuenta),TRIM(descriprenglon),renglonautoridad,";
							LET cCmd1 =""||TRIM(cCmd1)||" saldocolumna1,saldocolumna2,saldocolumna3,saldocolumna4";
							LET cCmd1 =""||TRIM(cCmd1)||" FROM bdirepaut:""informix"".sp_resumenfiltro_anexo";
							LET cCmd1 =""||TRIM(cCmd1)||" WHERE clavereporte = 'ANEX43PREV'";
							LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY fecha,renglonautoridad;";
							LET cCmd1 =" "||TRIM(cCmd1);*/
							
							LET iProcesaRep = 1;
						
						ELSE
							LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
							-- SE CREAN TABLAS TEMPORALES
							IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'reg_formato_tmp') THEN
								DROP TABLE bdirepaut:"informix".reg_formato_tmp;
							END IF;
							
							-- SE CREAN TABLAS TEMPORALES
							CREATE TABLE bdirepaut:"informix".reg_formato_tmp(
																			   id_serial SERIAL NOT NULL,
																			   linea CHAR(2500),
																			   PRIMARY KEY (id_serial)
																			);
																			
							
							FOREACH
						
								--RS1
								SELECT identautoridad,clavereporte,empresa,numerorenglon,
								descripcuenta,descriprenglon,renglonautoridad,claveperiodicidad,
								saldocolumna1,saldocolumna2,saldocolumna3,saldocolumna4,saldocolumna5,
								saldocolumna6,saldocolumna7,saldocolumna8,saldocolumna9,saldocolumna10,
								saldocolumna11,saldocolumna12,saldocolumna13,saldocolumna14,saldocolumna15,
								saldocolumna16,saldocolumna17,saldocolumna18,saldocolumna19,saldocolumna20,
								saldocolumna21,saldocolumna22,saldocolumna23,saldocolumna24,saldocolumna25
								INTO cIdentAutoridad,cClaveReporte,cEmpresa_rf,iNumeroRenglon,
								cDescripCuenta,cDescripRenglon,iRenglonAutoridad,cClavePeriodicidad,
								dSaldocolumna1,dSaldocolumna2,dSaldocolumna3,dSaldocolumna4,dSaldocolumna5,
								dSaldocolumna6,dSaldocolumna7,dSaldocolumna8,dSaldocolumna9,dSaldocolumna10,
								dSaldocolumna11,dSaldocolumna12,dSaldocolumna13,dSaldocolumna14,dSaldocolumna15,
								dSaldocolumna16,dSaldocolumna17,dSaldocolumna18,dSaldocolumna19,dSaldocolumna20,
								dSaldocolumna21,dSaldocolumna22,dSaldocolumna23,dSaldocolumna24,dSaldocolumna25
								FROM bdirepaut:"informix".sp_resumenfiltro
								WHERE identautoridad = cAutoridad AND clavereporte = cReporte
								AND empresa = '001' AND descripcuenta <> '000000000000'
								ORDER BY numerorenglon
								
								--Si Existe Formato Prosigue
								IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
									
									--Obtiene los datos de Resumen Filtro que se Procesaran
									LET iRegistros = 0;
									--LET cRenglon = '';
									
									FOREACH
									
										--RS2
										SELECT identautoridad,empresa,clavereporte,formatosalida,numerocampo,descripcampo,
										tipodato,longitud,decimales,tipoacceso,dep_renglon,numerocolumna,formato
										INTO cIdAutoridad,cEmpresa_df,cCveReporte,iFormSalida,iNumCampo,cDescCampo,
										cTipoDato,iLongitud,iDecimales,cTipoAcceso,iDepRenglon,iNumColumna,cFormato 
										FROM bdirepaut:"informix".sp_dformato 
										WHERE identautoridad = cAutoridad
										AND empresa = '001'
										AND clavereporte = cReporte
										ORDER BY formatosalida,numerocampo
										
										--Aplica el formato para cada renglon del resumen filtro 
										IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
										
											IF iFormatoAnt <> iFormSalida THEN
											
												IF TRIM(cRenglon) <> '' THEN
													INSERT INTO bdirepaut:"informix".reg_formato_tmp(linea)
													VALUES(TRIM(cRenglon));
												END IF;
												
												LET iGraba = 0;
												LET iFormatoAnt = iFormSalida;
												LET cRenglon = '';
											END IF;
										
											LET iArmaReporte = 1; --> CONTROLA INICIO REPORTE
											--LET iProcesaRep = 0 + 1; --> CONTROLA FIN REPORTE
										
											LET iRegistros = 1;
											--LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
											
											--LET iGraba = 0;
											--LET iFormatoAnt = iFormSalida;
											----LET cRenglon = '';
											LET cDato = '';
											
											IF NVL(cTipoAcceso,'') = 'K' THEN
											
												LET cDato = TRIM(cFormato);	
											
											ELIF NVL(cTipoAcceso,'') = 'C' THEN
											
												IF NVL(iNumColumna,'') = 1 THEN
													LET cDato = dSaldocolumna1;	
												ELIF NVL(iNumColumna,'') = 2 THEN
													LET cDato = dSaldocolumna2;	
												ELIF NVL(iNumColumna,'') = 3 THEN
													LET cDato = dSaldocolumna3;	
												ELIF NVL(iNumColumna,'') = 4 THEN
													LET cDato = dSaldocolumna4;	
												ELIF NVL(iNumColumna,'') = 5 THEN
													LET cDato = dSaldocolumna5;	
												ELIF NVL(iNumColumna,'') = 6 THEN
													LET cDato = dSaldocolumna6;	
												ELIF NVL(iNumColumna,'') = 7 THEN
													LET cDato = dSaldocolumna7;	
												ELIF NVL(iNumColumna,'') = 8 THEN
													LET cDato = dSaldocolumna8;	
												ELIF NVL(iNumColumna,'') = 9 THEN
													LET cDato = dSaldocolumna9;	
												ELIF NVL(iNumColumna,'') = 10 THEN
													LET cDato = dSaldocolumna10;	
												ELIF NVL(iNumColumna,'') = 11 THEN
													LET cDato = dSaldocolumna11;	
												ELIF NVL(iNumColumna,'') = 12 THEN
													LET cDato = dSaldocolumna12;	
												ELIF NVL(iNumColumna,'') = 13 THEN
													LET cDato = dSaldocolumna13;	
												ELIF NVL(iNumColumna,'') = 14 THEN
													LET cDato = dSaldocolumna14;	
												ELIF NVL(iNumColumna,'') = 15 THEN
													LET cDato = dSaldocolumna15;	
												ELIF NVL(iNumColumna,'') = 16 THEN
													LET cDato = dSaldocolumna16;	
												ELIF NVL(iNumColumna,'') = 17 THEN
													LET cDato = dSaldocolumna17;	
												ELIF NVL(iNumColumna,'') = 18 THEN
													LET cDato = dSaldocolumna18;
												ELIF NVL(iNumColumna,'') = 19 THEN
													LET cDato = dSaldocolumna19;
												ELIF NVL(iNumColumna,'') = 20 THEN
													LET cDato = dSaldocolumna20;
												ELIF NVL(iNumColumna,'') = 21 THEN
													LET cDato = dSaldocolumna21;
												ELIF NVL(iNumColumna,'') = 22 THEN
													LET cDato = dSaldocolumna22;
												ELIF NVL(iNumColumna,'') = 23 THEN
													LET cDato = dSaldocolumna23;
												ELIF NVL(iNumColumna,'') = 24 THEN
													LET cDato = dSaldocolumna24;
												ELIF NVL(iNumColumna,'') = 25 THEN
													LET cDato = dSaldocolumna25;
												ELSE
													LET cDato = 0;
												END IF;
												
												IF (NVL(cDato,0)::DECIMAL(20,2)) <> 0 THEN
													LET iGraba = 1;
												END IF;
											
											ELIF NVL(cTipoAcceso,'') = 'S' THEN
											
												--LET cDato = EjecutaQuery(cSQL, RS2!formatosalida, RS2!numerocampo, RS1!numerorenglon, "S")
												--LET cDato = SELECT descripcuenta FROM sp_resumenfiltro;
												
												SELECT seleccion INTO cSeleccion
												FROM bdirepaut:"informix".sp_cformato
												WHERE identautoridad = TRIM(cIdentAutoridad)
												AND empresa = '001'
												AND clavereporte = TRIM(cClaveReporte)
												AND formatosalida = iFormSalida
												AND numerocampo = iNumCampo;
											
												--LET cSeleccion = REPLACE(LOWER(TRIM(cSeleccion)), 'FROM ', 'FROM bdirepaut:"informix".');
												--LET cSeleccion = REPLACE(UPPER(TRIM(cSeleccion)), 'FROM ', 'FROM bdirepaut:"informix".');
												
												 IF (TRIM(cSeleccion) LIKE ('%FROM%')) THEN                                               --Cambio
														LET cSeleccion = REPLACE(TRIM(cSeleccion), 'FROM ', 'FROM bdirepaut:"informix".'); 
													ELIF (TRIM(cSeleccion) LIKE ('%from%')) THEN                                             
														LET cSeleccion = REPLACE(TRIM(cSeleccion), 'from ', 'FROM bdirepaut:"informix".'); 
												END IF; 
												
												LET cCmd1 ="";
												LET cCmd1 =""||TRIM(cCmd1)||TRIM(cSeleccion)||";";
												--SYSTEM TRIM(cCmd1);
											
												PREPARE stmtId FROM TRIM(cCmd1);
												DECLARE selectQryCur CURSOR FOR stmtId;
												OPEN selectQryCur;
												FETCH selectQryCur INTO cQuery;
												
												CLOSE selectQryCur;
												FREE selectQryCur;
												FREE stmtId;
												
												LET cCmd1 = '';
												LET cDato = TRIM(cQuery);
											
											ELIF NVL(cTipoAcceso,'') = 'D' THEN
											
												--LET cDato = EjecutaQuery(cSQL, RS2!formatosalida, RS2!numerocampo, RS1!numerorenglon, "D")
												--LET cDato = SELECT descripcuenta FROM sp_resumenfiltro;
												
												SELECT seleccion INTO cSeleccion
												FROM bdirepaut:"informix".sp_cformato
												WHERE identautoridad = TRIM(cIdentAutoridad)
												AND empresa = '001'
												AND clavereporte = TRIM(cClaveReporte)
												AND formatosalida = iFormSalida
												AND numerocampo = iNumCampo;
												
												--LET cSeleccion = REPLACE(LOWER(TRIM(cSeleccion)), 'FROM ', 'FROM bdirepaut:"informix".');
												--LET cSeleccion = REPLACE(UPPER(TRIM(cSeleccion)), 'FROM ', 'FROM bdirepaut:"informix".');
												
												 IF (TRIM(cSeleccion) LIKE ('%FROM%')) THEN                                               --Cambio
														LET cSeleccion = REPLACE(TRIM(cSeleccion), 'FROM ', 'FROM bdirepaut:"informix".'); 
													ELIF (TRIM(cSeleccion) LIKE ('%from%')) THEN                                             
														LET cSeleccion = REPLACE(TRIM(cSeleccion), 'from ', 'FROM bdirepaut:"informix".'); 
												END IF; 
												
												LET cCmd1 ="";
												LET cCmd1 =""||TRIM(cCmd1)||TRIM(cSeleccion);
												LET cCmd1 =""||TRIM(cCmd1)||" WHERE identautoridad = '"|| TRIM(cIdentAutoridad) ||"'";
												LET cCmd1 =""||TRIM(cCmd1)||" AND empresa = '001' AND clavereporte = '"|| TRIM(cClaveReporte) ||"'";
												LET cCmd1 =""||TRIM(cCmd1)||" AND numerorenglon = '"|| iNumeroRenglon ||"';";
												--SYSTEM TRIM(cCmd1);
											
												PREPARE stmtId FROM TRIM(cCmd1);
												DECLARE selectQryCur CURSOR FOR stmtId;
												OPEN selectQryCur;
												FETCH selectQryCur INTO cQuery;
												
												CLOSE selectQryCur;
												FREE selectQryCur;
												FREE stmtId;
												
												LET cCmd1 = '';
												LET cDato = TRIM(cQuery);
												
											END IF;
											
											--Formatea el dato si es Número o Float
											IF NVL(cTipoDato,'') IN ('N','Z') THEN
											
												LET cFormat = '';
												IF NVL(iDecimales,0) > 0 THEN
													LET cFormat = '0.'||NVL(iDecimales,'0'); --ADD
												END IF;
											
												IF (NVL(iDecimales,0) + 1) < NVL(iLongitud,0) THEN
													
													IF NVL(cTipoDato,'') = 'Z' THEN 
														--LET cFormat = TO_CHAR(NVL(iLongitud,0) - NVL(iDecimales,0) - 1)||TRIM(cFormat);
														LET cFormat = NVL((NVL(iLongitud,0) - NVL(iDecimales,0) - 1),'0')||TRIM(cFormat); --Cambio
													ELSE
														--LET cFormat = TO_CHAR(NVL(iLongitud,0) - NVL((NVL(iDecimales,0) - 1),0))||TRIM(cFormat);
														LET cFormat = NVL((NVL(iLongitud,0) - NVL(iDecimales,0) - 1),'')||TRIM(cFormat); --Cambio
													END IF;
													
												END IF;
												
												IF TRIM(cDato) <> ';' THEN
												
													IF (NVL(cDato,0)::DECIMAL(20,2)) < 0 THEN
														--LET cFormat = '-'||SUBSTR(cFormat,1,2);
														LET cFormat = '-'||SUBSTR(cFormat,2); --Cambio
														LET cDato = ((NVL(cDato,0)::DECIMAL(20,2)) * -1);
													END IF;
													
													IF (NVL(cDato,0)::DECIMAL(20,2)) = 0 AND NVL(iDecimales,0) = 0 THEN
														--LET cDato = Format$(CDbl(cDato), cFormat) & "0";
														LET cDato = LPAD(TRIM(cDato),cFormat::INTEGER,'0');
														LET cDato = REPLACE(TRIM(cDato), '.', '0')||'0';
													ELSE
														--LET cDato = Format$(CDbl(cDato), cFormat);
														LET cDatoFormat = TRIM(cDato);
														LET cDato = cDatoFormat::BIGINT;
														LET cDato = LPAD(TRIM(cDato),cFormat::INTEGER,'0');
													END IF;
													
												END IF;
												
												IF NVL(cTipoDato,'') = 'N' THEN
													IF NVL(iDecimales,0) > 0 THEN
														LET cDato = SPACE(NVL(iLongitud,0) - (LENGTH(TRIM(cDato)) + 1)) || TRIM(cDato);	--ADD
													ELSE
														LET cDato = SPACE(NVL(iLongitud,0) - LENGTH(TRIM(cDato))) || TRIM(cDato); --ADD
													END IF;
												END IF;
												
												IF TRIM(cFormato) = 'S' OR TRIM(cFormato) = 's' THEN
													LET cDato = TRIM(cDato);
												END IF;
											
											--Formatea el dato si es Cadena
											ELIF NVL(cTipoDato,'') = 'C' THEN
											
												IF NVL(cCveReporte,'') <> 'R15A1511pm' THEN
													--LET cDato = LEFT(cDato & Space(NVL(iLongitud,0), NVL(iLongitud,0);
													LET cDato = LEFT(TRIM(cDato)||SPACE(NVL(iLongitud,0)), NVL(iLongitud,0)); --ADD
												END IF;
											
											--Formatea el dato si es Fecha
											ELIF NVL(cTipoDato,'') = 'F' THEN
												LET cDato = TO_DATE(TRIM(cDato),'%d/%m/%Y'); --ADD
											END IF;
										
											LET cRenglon = TRIM(cRenglon)||TRIM(cDato);
										
											--IF iFormatoAnt <> iFormSalida THEN
											--	LET iGraba = 0;
											--	LET iFormatoAnt = iFormSalida;
											--	LET cRenglon = '';
											--	
											--	INSERT INTO bdicnweb:"informix".reg_formato_tmp(linea)
											--	VALUES(cRenglon);
											--END IF;
											
											LET iProcesaRep = iProcesaRep + 1;
										
										ELSE			
											--IF iArmaReporte = 0; --> NO INICIO REPORTE
											--IF iArmaReporte = 1; --> SI INICIO REPORTE
											LET iProcesaRep = 0; --YA NO HAY MÁS REGISTROS
										END IF;
										
										--IF NVL(iRegistros,0) = 1 THEN
										--	--Cierra El Archivo del Reporte
										--END IF;
									
									END FOREACH;
									
									INSERT INTO bdirepaut:"informix".reg_formato_tmp(linea)
									VALUES(TRIM(cRenglon));
							
									LET cRenglon = '';
								END IF;
							
							END FOREACH;
							
							LET cCmd1 ="";
							LET cCmd1 ="SELECT TRIM(linea) FROM bdirepaut:""informix"".reg_formato_tmp;";
							LET cCmd1 =" "||TRIM(cCmd1);
							
							--Entró e inició armado de reporte
							--IF NVL(iArmaReporte,0) = 1 AND NVL(iProcesaRep,0) > 0 THEN
							
								LET cSql = '';
								--LET cSql = 'echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
								LET cSql = 'echo "UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
								SYSTEM TRIM(cSql);
								
								LET cSql = '';
								LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
								SYSTEM TRIM(cSql);
								
								LET cSql = '';
								--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
								LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
								--SYSTEM TRIM(cSql);
								COMMIT WORK;
								SYSTEM TRIM(cSql);
								BEGIN WORK;
								
								-- Eliminamos el archivo query.sql
								LET cSql = '';
								LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
								SYSTEM TRIM(cSql);
								
								-- Se manipula el archivo para agregar el salto de línea
								LET cSql = '';
								LET cSql = 'chmod 777 '||TRIM(cRutaGral);
								SYSTEM TRIM(cSql);
								
								LET cSql = '';
								LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
								SYSTEM TRIM(cSql);
								
								-- Eliminamos el archivo original
								LET cSql = '';
								LET cSql = "rm -rf "||TRIM(cRutaGral);
								SYSTEM TRIM(cSql);
								
								LET cSql = '';
								LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
								SYSTEM TRIM(cSql);
								
								--DELIMITADOR--
								
								-- Eliminamos el caracter delimitador ';'.
								LET cSql = '';
								LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
								SYSTEM TRIM(cSql);
								
								-- Se manipula el archivo para agregar el salto de línea
								LET cSql = '';
								LET cSql = 'chmod 777 '||TRIM(cRutaGral);
								SYSTEM TRIM(cSql);
								
								LET cSql = '';
								LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
								SYSTEM TRIM(cSql);
								
								--COPIA--
								
								-- Se realiza la copia de los registros a un archivo nuevo	
								LET cArchivoCP = TRIM(pRuta)||TRIM(cReporte)||"_cp.tmp";
								
								LET cCmdQuery = '';
								LET cCmdQuery = 'cat '||TRIM(cRutaGral)||".tmp"||' >> '||TRIM(cArchivoCP);
								SYSTEM TRIM(cCmdQuery);
								
								-- Eliminamos el archivo .tmp
								LET cSql = '';
								LET cSql = 'rm -rf '||TRIM(cRutaGral)||".tmp";
								SYSTEM TRIM(cSql);
							
							--END IF;
							
							-- Se renombra el archivo temporal por el nombre original
							LET cSql = '';
							LET cSql = "mv "||TRIM(cArchivoCP)||" "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							--LET iCountRep = iCountRep + 1;
							INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
							VALUES(TRIM(cReporte)||'.txt',pUsuario,pFecha);
						
							LET iProcesaRep = 0;
							
						END IF;		
			
						IF iProcesaRep = 1 THEN
						
							LET cSql = '';
							LET cSql = 'echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							--LET cSql = TRIM(cRutaInformix)||'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							LET cSql = 'dbaccess bdirepaut '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);  
							
							-- Eliminamos el archivo query.sql
							LET cSql = '';
							LET cSql = 'rm -rf '||TRIM(pRuta)||'query.sql';
							SYSTEM TRIM(cSql);
							
							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							-- Eliminamos el archivo original
							LET cSql = '';
							LET cSql = "rm -rf "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							--
							
							-- Eliminamos el caracter delimitador ';'.
							LET cSql = '';
							LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							-- Se manipula el archivo para agregar el salto de línea
							LET cSql = '';
							LET cSql = 'chmod 777 '||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							LET cSql = '';
							LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
							SYSTEM TRIM(cSql);
							
							--
							
							-- Se renombra el archivo temporal por el nombre original
							LET cSql = '';
							LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
							SYSTEM TRIM(cSql);
							
							--LET iCountRep = iCountRep + 1;
							INSERT INTO bdirepaut:"informix".sw_reg_ctrlgeneracionarchivos(nom_reporte,usuario_proceso,fecha_proceso)
							VALUES(TRIM(cReporte)||'.txt',pUsuario,pFecha);
						
							LET iProcesaRep = 0;
							
						END IF;
						
					END IF;
			
			END FOREACH;
		
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		UPDATE bdirepaut:"informix".sw_reg_statusproceso
		SET status = 'T', error_proceso = 'N', path_file = TRIM(pRuta), nombre_file = '' WHERE usuario = TRIM(pUsuario);   
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
