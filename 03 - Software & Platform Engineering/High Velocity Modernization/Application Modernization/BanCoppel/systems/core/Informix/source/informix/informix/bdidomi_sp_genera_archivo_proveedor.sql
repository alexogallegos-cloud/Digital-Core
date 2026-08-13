CREATE PROCEDURE "informix".sp_genera_archivo_proveedor( p_tipo CHAR(1), p_nombArch CHAR(20), p_numcte CHAR(20),
										p_fecha_ini CHAR(8), p_fecha_fin CHAR(8))
	 returning char(5);
	--ElaborÃ³: Alejandro Osuna Iza
	--Actividad:Genera los archivos de cliente.
	--Solicito: Hector Casanova
	--Fecha: 13 de julio de 2009
	--------------------------------------------
	--Modifico: CÃ©sar Valdez Figueroa
	--Actividad: Se Modifico Procedimiento para que al formar el archivo reversos filtrara por la fehca_cargo, ademas
	--		se elimino la validacion de la fecha que se reciben por parametros la cual no es necesaria.
	--Solicito: Hector Casanova
	--Fecha: 21 de Agosto de 2009
	--Version: 20090821.1052

	DEFINE	v_cod_ret 		CHAR(5);
	DEFINE	sql_err 		INTEGER;
	DEFINE v_ruta 			CHAR(100);
	DEFINE vsSQL 			CHAR(450);
	DEFINE vsSQL1 			CHAR(150);
	DEFINE vsSQL2 			CHAR(150);
	DEFINE vsSQL3 			CHAR(150);
	DEFINE v_cRespSP		CHAR(5);
	DEFINE v_cExiste		integer;
	DEFINE v_snombre_nw 	CHAR(20);
	DEFINE v_fecha_sis		DATE;
	DEFINE v_consecutivo	CHAR(6);
	DEFINE v_oper_en_paso	CHAR(8);

	--declaracion de varibales del encabezado
	DEFINE lv_encabezado		lvarchar(65);
	DEFINE v_snombre_archE 		CHAR(20);
	DEFINE v_ffecha_envioE 		DATE;
	DEFINE v_stpo_regisE 		CHAR(1);
	DEFINE v_sNum_cteE 			CHAR(20);
	DEFINE v_sCuenta_abonoE		CHAR(20);
	DEFINE v_snum_operaE		CHAR(8);
	DEFINE v_sFecha_iniE		CHAR(8);
	DEFINE v_sFecha_finE		CHAR(8);

	--declaracion de varibales del detalle
	DEFINE lv_detalle			lvarchar(342);
	DEFINE v_stpo_regisD 		CHAR(1);
	DEFINE v_sConsecD			CHAR(6);
	DEFINE v_sfech_cargD		CHAR(8);
	DEFINE v_sfech_abonD		CHAR(8);
	DEFINE v_stpo_cta_caD		CHAR(2);
	DEFINE v_scve_ban_caD		CHAR(3);
	DEFINE v_scuenta_carD		CHAR(20);
	DEFINE v_srfc_cargoD		CHAR(13);
	DEFINE v_snombre_carD		CHAR(50);
	DEFINE v_scuenta_aboD		CHAR(20);
	DEFINE v_simp_operaD		CHAR(15);
	DEFINE v_simp_ivaD			CHAR(15);
	DEFINE v_sref_numD			CHAR(7);
	DEFINE v_sref_leyD			CHAR(40);
	DEFINE v_sref_servD			CHAR(40);
	DEFINE v_sref_tit_servD		CHAR(40);
	DEFINE v_saccionD			CHAR(1);
	DEFINE v_sreint_cuentaD		CHAR(1);
	DEFINE v_sestatusD			CHAR(2);
	DEFINE v_scausa_rechazD		CHAR(50);



	--declaracion de variables del sumario.
	DEFINE lv_sumario			lvarchar(105);
	DEFINE v_stpo_regisS 		CHAR(1);
	DEFINE v_snum_operS			CHAR(8);
	DEFINE v_simp_operS			CHAR(18);
	DEFINE v_snum_oper_penS		CHAR(8);
	DEFINE v_simp_oper_penS		CHAR(18);
	DEFINE v_snum_oper_aplS		CHAR(8);
	DEFINE v_simp_oper_aplS		CHAR(18);
	DEFINE v_snum_oper_recS		CHAR(8);
	DEFINE v_simp_oper_recS		CHAR(18);

	DEFINE cHora				CHAR(8);
	DEFINE cFechaArchivoOUT		CHAR(15);
	DEFINE iPaso				SMALLINT;
	
	BEGIN
		on exception set sql_err
		    IF sql_err <> 0 then
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret;
		    END IF;
		END EXCEPTION;

		ON EXCEPTION IN(-668) SET sql_err
			IF iPaso NOT IN(4,5,6) THEN 
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret;
			END IF;
		END EXCEPTION WITH RESUME;

		--inicializacion de variables globales
		LET v_cod_ret 			= "00000";
		LET v_ruta 				= "";
		LET v_cRespSP			= "";
		LET v_cExiste			= 0;
		LET v_snombre_nw 		= "";
		LET v_consecutivo		= "000000";
		LET v_oper_en_paso      = "";
		--inicializacion de variables del encabezado
		LET lv_encabezado   	= "";
		LET v_snombre_archE		= "";
		LET v_stpo_regisE 		= "";
		LET v_sNum_cteE			= "";
		LET v_sCuenta_abonoE	= "";
		LET v_snum_operaE		= "";
		LET v_sFecha_iniE		= "";
		LET v_sFecha_finE		= "";

		--inicializacion de variables del detalle
		LET lv_detalle			= "";
		LET v_stpo_regisD		= "";
		LET v_sConsecD			= "";
		LET v_sfech_cargD		= "";
		LET v_sfech_abonD		= "";
		LET v_stpo_cta_caD		= "";
		LET v_scve_ban_caD		= "";
		LET v_scuenta_carD		= "";
		LET v_srfc_cargoD		= "";
		LET v_snombre_carD		= "";
		LET v_scuenta_aboD		= "";
		LET v_simp_operaD		= "";
		LET v_simp_ivaD			= "";
		LET v_sref_numD			= "";
		LET v_sref_leyD			= "";
		LET v_sref_servD		= "";
		LET v_sref_tit_servD	= "";
		LET v_saccionD			= "";
		LET v_sreint_cuentaD	= "";
		LET v_sestatusD			= "";
		LET v_scausa_rechazD	= "";

		--inicializacion de variables del sumario.
		LET lv_sumario			= "";
		LET v_stpo_regisS		= "";
		LET v_snum_operS		= "";
		LET v_simp_operS		= "";
		LET v_snum_oper_penS	= "";
		LET v_simp_oper_penS	= "";
		LET v_snum_oper_aplS	= "";
		LET v_simp_oper_aplS	= "";
		LET v_snum_oper_recS	= "";
		LET v_simp_oper_recS	= "";

		LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
		LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
		LET iPaso				= 0;
		
		--SET DEBUG FILE TO "/home/sysdomi/sp_genera_proveedor.out";
		--TRACE ON;

		IF (p_tipo = "N") OR (p_tipo = "R") THEN
		ELSE
			LET v_cod_ret = "02300";
			return v_cod_ret;
		END IF;
		--se genera el archivo de respuesta.
		IF p_tipo = "N" THEN
			--se valida que el nombre del archivo venga en blanco o se a null
			IF (p_nombArch = "" ) OR (p_nombArch IS NULL)  THEN
				LET v_cod_ret = "02301";
				return v_cod_ret;
			END IF;

			--se borra la tabla de paso
			DELETE bdidomi:dom_proveedor_paso;
			IF EXISTS(SELECT tipo_registro FROM bdidomi:dom_cte_encabezado
					WHERE nombre_arch = p_nombArch) THEN

				--SE TOMAN LOS DATOS DE LA TABLA DE ENCABEZADO
				SELECT tipo_registro, num_cte, cuenta_abono, num_operaciones, fecha_inicial, fecha_final
				INTO  v_stpo_regisE, v_sNum_cteE, v_sCuenta_abonoE, v_snum_operaE, v_sFecha_iniE, v_sFecha_finE
				FROM bdidomi:dom_cte_encabezado
				WHERE nombre_arch = p_nombArch;

				--se forma el campo a insertar
				LET lv_encabezado = v_stpo_regisE || v_sNum_cteE || v_sCuenta_abonoE || v_snum_operaE ||
									v_sFecha_iniE || v_sFecha_finE;
				INSERT INTO bdidomi:dom_proveedor_paso(campo)
				VALUES(lv_encabezado);
				--se valida que exista en la tabla de don_cte_detalle
				IF EXISTS(SELECT fecha_cargo FROM bdidomi:dom_cte_detalle
						WHERE nombre_arch = p_nombArch)THEN
					FOREACH
						--SE TOMAN LOS DATOS DE LA TABLA DE DETALLE
						SELECT tipo_registro, consecutivo, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo,
								rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
								ref_titular_serv, accion, reintentar_cuenta, estatus, causa_rechazo
						INTO	v_stpo_regisD,v_sConsecD,v_sfech_cargD,v_sfech_abonD,v_stpo_cta_caD,v_scve_ban_caD,v_scuenta_carD,
								v_srfc_cargoD,v_snombre_carD,v_scuenta_aboD,v_simp_operaD,v_simp_ivaD,v_sref_numD,v_sref_leyD,v_sref_servD,
								v_sref_tit_servD,v_saccionD,v_sreint_cuentaD,v_sestatusD,v_scausa_rechazD
						FROM bdidomi:dom_cte_detalle
						WHERE nombre_arch = p_nombArch
						ORDER BY consecutivo
						--LET v_scausa_rechazD = lpad(TRIM(v_scausa_rechazD::char(50)),50,' ');
						LET lv_detalle = v_stpo_regisD || v_sConsecD || v_sfech_cargD || v_sfech_abonD || v_stpo_cta_caD || v_scve_ban_caD ||
										v_scuenta_carD || v_srfc_cargoD || v_snombre_carD || v_scuenta_aboD || v_simp_operaD || v_simp_ivaD ||
										v_sref_numD || v_sref_leyD || v_sref_servD || v_sref_tit_servD || v_saccionD || v_sreint_cuentaD ||
										v_sestatusD || v_scausa_rechazD;
						--LET v_scausa_rechazD = lpad(TRIM(v_scausa_rechazD::char(50)),50,' ');
						INSERT INTO bdidomi:dom_proveedor_paso(campo)
						VALUES(lv_detalle);

					END FOREACH;

					--SE VALIDA LOS DATOS DEL SUMARIO
					IF EXISTS(SELECT tipo_registro FROM bdidomi:dom_cte_sumario
							WHERE nombre_arch = p_nombArch )THEN
						--se toman los datos de la sumario
						SELECT 	tipo_registro, num_operaciones, imp_operaciones, num_oper_pend, imp_oper_pend,
								num_oper_apli, imp_oper_apli, num_oper_rech, imp_oper_rech
						INTO	v_stpo_regisS,v_snum_operS,v_simp_operS,v_snum_oper_penS, v_simp_oper_penS,
								v_snum_oper_aplS,v_simp_oper_aplS,v_snum_oper_recS,v_simp_oper_recS
						FROM bdidomi:dom_cte_sumario WHERE nombre_arch = p_nombArch;

						LET lv_sumario = v_stpo_regisS || v_snum_operS || v_simp_operS || v_snum_oper_penS || v_simp_oper_penS ||
								v_snum_oper_aplS || v_simp_oper_aplS || v_snum_oper_recS || v_simp_oper_recS;
						INSERT INTO bdidomi:dom_proveedor_paso(campo)
						VALUES(lv_sumario);

						--se arma el archivo y se deposita en la ruta de respuesta:
						SELECT valor INTO v_ruta FROM bdidomi:dom_parametros
						WHERE cod_param = '02' AND descripcion = 'RUTA ARCHIVO RESPUESTA';
						LET v_ruta = TRIM(v_ruta);
						
						LET iPaso = 1;
						LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(v_ruta) || cFechaArchivoOUT||'.unl' || ' DELIMITER ' || '''?''';
						LET vsSQL2 = ' select campo::lvarchar(342) from bdidomi:dom_proveedor_paso order by keyx;' ;
                        LET vsSQL3 = ' " > '|| TRIM(v_ruta) || cFechaArchivoOUT||'.sql';
						LET vsSQL1 = TRIM(vsSQL1);
						LET vsSQL3 = TRIM(vsSQL3);
						LET vsSQL2 = TRIM(vsSQL2);
						LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

						IF ( vsSQL <> '' ) THEN
							SYSTEM vsSQL;
							--Permiso para la creacion de archivo.							
							--LET vsSQL = 'chmod 666 ' || TRIM(v_ruta) || 'tmp.sql' ;
							
							LET iPaso = 2;
							--Produccion
							LET vsSQL = '/ifxsif01/bin/dbaccess bdidomi ' || TRIM(v_ruta) || cFechaArchivoOUT||'.sql > '||TRIM(v_ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';

							--Desarrollo
							--LET vsSQL = '/informix/bin/dbaccess bdidomi ' || TRIM(v_ruta) || cFechaArchivoOUT||'.sql > '||TRIM(v_ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
							SYSTEM vsSQL ;
							
							--Borra el archivo de control.							
							LET v_snombre_nw = "S" || substr(p_nombArch,2,20);

							--Elimina el caracter delimitador '?'.
							LET iPaso = 3;
							LET vsSQL =  "sed 's/?$//g' " || TRIM(v_ruta) || cFechaArchivoOUT||'.unl' || " > " || TRIM(v_ruta) ||
							TRIM (v_snombre_nw);
							SYSTEM vsSQL;
							
							--Borra el archivo de  paso.
							LET iPaso = 4;
							LET vsSQL = 'rm ' || TRIM(v_ruta) || cFechaArchivoOUT||'.sql';
							SYSTEM vsSQL;
							
							LET iPaso = 5;
							LET vsSQL = 'rm ' || TRIM(v_ruta) || cFechaArchivoOUT||'.unl';
							SYSTEM vsSQL;

							LET iPaso = 6;
							LET vsSQL = 'rm ' || TRIM(v_ruta) || cFechaArchivoOUT||'.out';
							SYSTEM vsSQL;
							
						End IF;
					--No existe en la tabla de dom_cte_SUMARIO
					ELSE
						LET v_cod_ret = "02235";
						return v_cod_ret;
					END IF;

				--No existe en la tabla de dom_cte_DETALLE
				ELSE
					LET v_cod_ret = "02204";
					return v_cod_ret;
				END IF;
			--No existe en la tabla de dom_cte_encabezado
			ELSE
				LET v_cod_ret = "02303";
				return v_cod_ret;
			END IF;
		END IF;
		--se genera el archivo de reversos.
		IF p_tipo = "R" THEN

			--se valida que el numero de cliente venga en blanco o se a null
			IF (p_numcte = "" ) OR (p_numcte IS NULL)  THEN
				LET v_cod_ret = "02302";
				return v_cod_ret;
			END IF;
			--se valida que al fecha inicio venga en blanco o se a null
			IF (p_fecha_ini = "" ) OR (p_fecha_ini IS NULL)  THEN
				LET v_cod_ret = "02306";
				return v_cod_ret;
				--SE VALIDA LA ESTRUCTURA Y SI ES HABIL O NO
			/*
			--se elimino esta validacionya que no en necesario siempre recibe una becha bien formateada y no importa que sea inabil
			ELSE
				execute procedure bdidomi:sp_valida_fecha(p_fecha_ini) into v_cRespSP;
				IF v_cRespSP <> "00000" THEN
					LET v_cod_ret = "02306";
					return v_cod_ret;
				END IF;*/
			END IF;
			--se valida que al fecha fin venga en blanco o se a null
			IF (p_fecha_fin = "" ) OR (p_fecha_fin IS NULL)  THEN
				LET v_cod_ret = "02307";
				return v_cod_ret;
				--SE VALIDA LA ESTRUCTURA Y SI ES HABIL O NO
			/*
			--se elimino esta validacionya que no en necesario siempre recibe una becha bien formateada y no importa que sea inabil
			ELSE
				execute procedure bdidomi:sp_valida_fecha(p_fecha_fin) into v_cRespSP;
				IF v_cRespSP <> "00000" THEN
					LET v_cod_ret = "02307";
					return v_cod_ret;
				END IF;
			*/
			END IF;
			--se toma la fecha hoy de la bdicheq:sc_fechas
			SELECT fecha_hoy INTO v_fecha_sis FROM bdicheq:sc_fechas;
			--se borra la tabla de paso
			DELETE bdidomi:dom_proveedor_paso;
			DELETE bdidomi:dom_cte_encabezado_paso;
			DELETE bdidomi:dom_cte_detalle_paso;
			DELETE bdidomi:dom_cte_sumario_paso;
			--se forma el nombre del reverso
			LET v_snombre_nw = "R" || substr(p_numcte,12,9) || "D" || LPAD(DAY(v_fecha_sis),2,'0') || LPAD(MONTH(v_fecha_sis),2,'0')
								|| Substr(YEAR(v_fecha_sis),3,2) || "." || "01";
			IF EXISTS(SELECT tipo_registro FROM bdidomi:dom_cte_encabezado
					WHERE num_cte = p_numcte) THEN

				FOREACH
					--SE TOMAN LOS DATOS DE LA TABLA DE ENCABEZADO
					SELECT nombre_arch,fecha_envio,cuenta_abono
					INTO  v_snombre_archE,v_ffecha_envioE,v_sCuenta_abonoE
					FROM bdidomi:dom_cte_encabezado
					WHERE num_cte = p_numcte


					--se valida que exista en la tabla de don_cte_detalle
					IF EXISTS(SELECT fecha_cargo FROM bdidomi:dom_cte_detalle
							WHERE nombre_arch = v_snombre_archE AND fecha_envio = v_ffecha_envioE)THEN
						FOREACH
							--SE TOMAN LOS DATOS DE LA TABLA DE DETALLE
							SELECT tipo_registro, consecutivo, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo,
									rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
									ref_titular_serv, accion, reintentar_cuenta, estatus, causa_rechazo
							INTO	v_stpo_regisD,v_sConsecD,v_sfech_cargD,v_sfech_abonD,v_stpo_cta_caD,v_scve_ban_caD,v_scuenta_carD,
									v_srfc_cargoD,v_snombre_carD,v_scuenta_aboD,v_simp_operaD,v_simp_ivaD,v_sref_numD,v_sref_leyD,v_sref_servD,
									v_sref_tit_servD,v_saccionD,v_sreint_cuentaD,v_sestatusD,v_scausa_rechazD
							FROM bdidomi:dom_cte_detalle
							WHERE nombre_arch = v_snombre_archE
							AND fecha_envio = v_ffecha_envioE
							AND estatus = "03"
							AND fecha_cargo between (substr(p_fecha_ini,7,2) || substr(p_fecha_ini,5,2) || substr(p_fecha_ini,1,4) )
											AND (substr(p_fecha_fin,7,2) || substr(p_fecha_fin,5,2) || substr(p_fecha_fin,1,4))
							ORDER BY consecutivo

							IF v_stpo_regisD = "" THEN
								LET v_cod_ret = "02308";
								return v_cod_ret;
							END IF;
							LET v_consecutivo = v_consecutivo + 1;
							LET v_consecutivo =  lpad(TRIM((v_consecutivo::integer)::char(6)),6,'0');
							INSERT INTO bdidomi:dom_cte_detalle_paso(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo, fecha_abono,
																	tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono,
																	imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv,
																	accion, reintentar_cuenta, estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce,
																	tipo_registro_cce, numero_secuencia_cce, comision_cobrada,iva_cobrado,user_insert, fecha_insert)
							values(v_snombre_nw,v_fecha_sis,v_stpo_regisD,v_consecutivo,v_sfech_cargD,v_sfech_abonD,
									v_stpo_cta_caD,v_scve_ban_caD,v_scuenta_carD,v_srfc_cargoD,v_snombre_carD,v_scuenta_aboD,
									v_simp_operaD,v_simp_ivaD,v_sref_numD,v_sref_leyD,v_sref_servD,v_sref_tit_servD,
									v_saccionD,v_sreint_cuentaD,v_sestatusD,v_scausa_rechazD,"","",
									"","","","","INFORMIX",CURRENT);
						END FOREACH;
					--No existe en la tabla de dom_cte_DETALLE
					ELSE
						LET v_cod_ret = "02204";
						return v_cod_ret;
					END IF;
				END FOREACH;
				IF v_stpo_regisD = "" THEN
					LET v_cod_ret = "02308";
					return v_cod_ret;
				END IF;
				SELECT COUNT(nombre_arch) into v_oper_en_paso FROM bdidomi:dom_cte_detalle_paso;
				LET v_oper_en_paso = lpad(TRIM((v_oper_en_paso::integer)::char(8)),8,'0');
				--se inserta en la encabeza paso
				insert into bdidomi:dom_cte_encabezado_paso(nombre_arch,fecha_envio,tipo_registro, num_cte,cuenta_abono,num_operaciones,
															fecha_inicial,fecha_final,user_insert,fecha_insert)
				values (v_snombre_nw,v_fecha_sis,"E",p_numcte,v_sCuenta_abonoE,v_oper_en_paso,
						p_fecha_ini , p_fecha_fin,"INFORMIX",CURRENT);

				SELECT SUM(imp_operacion::integer) into v_simp_operS FROM bdidomi:dom_cte_detalle_paso;

				LET v_simp_operS		= lpad(TRIM((v_simp_operS::integer)::char(18)),18,'0');
				LET v_snum_oper_penS	= lpad(TRIM((v_snum_oper_penS)::char(8)),8,'0');
				LET v_simp_oper_penS	= lpad(TRIM((v_simp_oper_penS)::char(18)),18,'0');
				LET v_snum_oper_aplS	= lpad(TRIM((v_snum_oper_aplS)::char(8)),8,'0');
				LET v_simp_oper_aplS	= lpad(TRIM((v_simp_oper_aplS)::char(18)),18,'0');
				LET v_snum_oper_recS	= lpad(TRIM((v_snum_oper_recS)::char(8)),8,'0');
				LET v_simp_oper_recS	= lpad(TRIM((v_simp_oper_recS)::char(18)),18,'0');

				--se inserta en la sumario paso
				insert into bdidomi:dom_cte_sumario_paso (nombre_arch, fecha_envio, tipo_registro, num_operaciones, imp_operaciones,
													num_oper_pend, imp_oper_pend, num_oper_apli, imp_oper_apli, num_oper_rech,
													imp_oper_rech, user_insert, fecha_insert)
				values (v_snombre_nw,v_fecha_sis,"S",v_oper_en_paso,v_simp_operS,
						v_snum_oper_penS,v_simp_oper_penS,v_snum_oper_aplS,v_simp_oper_aplS,v_snum_oper_recS,
						v_simp_oper_recS,"INFORMIX",CURRENT);


				---se suben las datos a la tabla de paso
				--SE TOMAN LOS DATOS DE LA TABLA DE ENCABEZADO
				SELECT tipo_registro, num_cte, cuenta_abono, num_operaciones, fecha_inicial, fecha_final
				INTO  v_stpo_regisE, v_sNum_cteE, v_sCuenta_abonoE, v_snum_operaE, v_sFecha_iniE, v_sFecha_finE
				FROM bdidomi:dom_cte_encabezado_paso
				WHERE nombre_arch = v_snombre_nw;

				--se forma el campo a insertar
				LET lv_encabezado = v_stpo_regisE || v_sNum_cteE || v_sCuenta_abonoE || v_snum_operaE ||
									v_sFecha_iniE || v_sFecha_finE;
				INSERT INTO bdidomi:dom_proveedor_paso(campo)
				VALUES(lv_encabezado);

				FOREACH
					--SE TOMAN LOS DATOS DE LA TABLA DE DETALLE
					SELECT tipo_registro, consecutivo, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo,
							rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
							ref_titular_serv, accion, reintentar_cuenta, estatus, causa_rechazo
					INTO	v_stpo_regisD,v_sConsecD,v_sfech_cargD,v_sfech_abonD,v_stpo_cta_caD,v_scve_ban_caD,v_scuenta_carD,
							v_srfc_cargoD,v_snombre_carD,v_scuenta_aboD,v_simp_operaD,v_simp_ivaD,v_sref_numD,v_sref_leyD,v_sref_servD,
							v_sref_tit_servD,v_saccionD,v_sreint_cuentaD,v_sestatusD,v_scausa_rechazD
					FROM bdidomi:dom_cte_detalle_paso
					WHERE nombre_arch = v_snombre_nw
					ORDER BY consecutivo

					LET lv_detalle = v_stpo_regisD || v_sConsecD || v_sfech_cargD || v_sfech_abonD || v_stpo_cta_caD || v_scve_ban_caD ||
									v_scuenta_carD || v_srfc_cargoD || v_snombre_carD || v_scuenta_aboD || v_simp_operaD || v_simp_ivaD ||
									v_sref_numD || v_sref_leyD || v_sref_servD || v_sref_tit_servD || v_saccionD || v_sreint_cuentaD ||
									v_sestatusD || v_scausa_rechazD;
					INSERT INTO bdidomi:dom_proveedor_paso(campo)
					VALUES(lv_detalle);
				END FOREACH;

				--se toman los datos de la sumario
				SELECT 	tipo_registro, num_operaciones, imp_operaciones, num_oper_pend, imp_oper_pend,
						num_oper_apli, imp_oper_apli, num_oper_rech, imp_oper_rech
				INTO	v_stpo_regisS,v_snum_operS,v_simp_operS,v_snum_oper_penS, v_simp_oper_penS,
						v_snum_oper_aplS,v_simp_oper_aplS,v_snum_oper_recS,v_simp_oper_recS
				FROM bdidomi:dom_cte_sumario_paso
				WHERE nombre_arch = v_snombre_nw;

				LET lv_sumario = v_stpo_regisS || v_snum_operS || v_simp_operS || v_snum_oper_penS || v_simp_oper_penS ||
								v_snum_oper_aplS || v_simp_oper_aplS || v_snum_oper_recS || v_simp_oper_recS;
				INSERT INTO bdidomi:dom_proveedor_paso(campo)
				VALUES(lv_sumario);

				--se arma el archivo y se deposita en la ruta de respuesta:
				SELECT valor INTO v_ruta FROM bdidomi:dom_parametros
				WHERE cod_param = '02' AND descripcion = 'RUTA ARCHIVO RESPUESTA';
				LET v_ruta = TRIM(v_ruta);
				
				LET iPaso = 1;
				LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(v_ruta) || cFechaArchivoOUT||'.unl' || ' DELIMITER ' || '''?''';
				LET vsSQL2 = ' select campo::lvarchar(342) from bdidomi:dom_proveedor_paso order by keyx;' ;
                LET vsSQL3 = ' " > '|| TRIM(v_ruta) || cFechaArchivoOUT||'.sql';
				LET vsSQL1 = TRIM(vsSQL1);
				LET vsSQL3 = TRIM(vsSQL3);
				LET vsSQL2 = TRIM(vsSQL2);
				LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

				IF ( vsSQL <> '' ) THEN
					SYSTEM vsSQL;
					--Permiso para la creacion de archivo.
					LET iPaso = 2;
					--Produccion
					LET vsSQL = '/ifxsif01/bin/dbaccess bdidomi ' || TRIM(v_ruta) || cFechaArchivoOUT||'.sql > '||TRIM(v_ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
					
					--Desarrollo
					--LET vsSQL = '/informix/bin/dbaccess bdidomi ' || TRIM(v_ruta) || cFechaArchivoOUT||'.sql > '||TRIM(v_ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
					SYSTEM vsSQL ;
					
					--Borra el archivo de control.
					LET iPaso = 3;
					--LET v_snombre_nw = "S" || substr(p_nombArch,2,20);
					--Elimina el caracter delimitador '?'.
					LET vsSQL =  "sed 's/?$//g' " || TRIM(v_ruta) || cFechaArchivoOUT||'.unl' || " > " || TRIM(v_ruta) ||
					TRIM (v_snombre_nw);
					SYSTEM vsSQL;
					
					--Borra el archivo de  paso.
					LET iPaso = 4;
					LET vsSQL = 'rm ' || TRIM(v_ruta) || cFechaArchivoOUT||'.sql';
					SYSTEM vsSQL;
					
					LET iPaso = 5;
					LET vsSQL = 'rm ' || TRIM(v_ruta) || cFechaArchivoOUT||'.unl';
					SYSTEM vsSQL;

					LET iPaso = 6;
					LET vsSQL = 'rm ' || TRIM(v_ruta) || cFechaArchivoOUT||'.out';
					SYSTEM vsSQL;
					
				End IF;

			--No existe en la tabla de dom_cte_encabezado
			ELSE
				LET v_cod_ret = "02303";
				return v_cod_ret;
			END IF;

		END IF;

		return v_cod_ret;
	END;
END PROCEDURE;