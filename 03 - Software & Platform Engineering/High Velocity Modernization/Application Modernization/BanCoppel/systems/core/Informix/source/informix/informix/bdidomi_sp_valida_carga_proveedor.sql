CREATE PROCEDURE "informix".sp_valida_carga_proveedor(p_nombre_arc CHAR(20), p_fecha_envio DATE)
	returning char(5);
	--ElaborÃ?Â³: Alejandro Osuna Iza
	--Actividad: Valida los datos de la carga manual del proveedor
	--Solicito: Hector Casanova
	--Fecha: 06 de Agosto de 2009

	--DECLARACION DE VARIABLES GLOBALES
	DEFINE	v_cod_ret 		CHAR(5);
	DEFINE	sql_err 		INTEGER;
	DEFINE 	v_cRespSP 		CHAR(5);
	DEFINE 	v_sFec_E_sp 	CHAR(8);
	DEFINE v_secu_bandera 	CHAR(7);
	DEFINE v_secu_max 		CHAR(7);
	DEFINE v_sfech_cargL	CHAR(8);
	DEFINE v_sfech_abonL	CHAR(8);
	DEFINE v_sLonCuenta		INTEGER;
	DEFINE cCeroTar  		CHAR(4);
	DEFINE v_sBancoCuent	CHAR(3);
	DEFINE v_iCodReSP 		INTEGER;
	DEFINE v_iDigVeSP 		INTEGER;
	DEFINE v_slongrfc		INTEGER;
	DEFINE v_scuentaband	CHAR(20);
	DEFINE cCeroClabe		CHAR(2);
	DEFINE v_fecha_sp		DATE;
	DEFINE v_TotalOpe_De	CHAR(18);
	DEFINE iContadorRepetidas	INTEGER;
	DEFINE dTipoFecha		INTEGER;
	

	DEFINE v_sDia_carL CHAR(2);

	--DECLARACION DE VARIABLES ENCABEZADO
	DEFINE v_snombre_archE 		CHAR(20);
	DEFINE v_ffecha_envioE 		DATE;
	DEFINE v_stpo_regisE 		CHAR(1);
	DEFINE v_sNum_cteE 			CHAR(20);
	DEFINE v_sCuenta_abonoE		CHAR(20);
	DEFINE v_snum_operaE		CHAR(8);
	DEFINE v_sFecha_iniE		CHAR(8);
	DEFINE v_sFecha_finE		CHAR(8);

	----DECLARACION DE VARIABLES DETALLE
	DEFINE v_snombre_archeD 	CHAR(20);
	DEFINE v_ffecha_envioD 		DATE;
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
	DEFINE v_snom_arc_cceD		CHAR(20);
	DEFINE v_sfec_prese_cceD	CHAR(8);
	DEFINE v_stpo_regi_cceD		CHAR(2);
	DEFINE v_num_sec_cceD		CHAR(7);

	----DECLARACION DE VARIABLES SUMARIO
	DEFINE v_snombre_archeS 	CHAR(20);
	DEFINE v_ffecha_envioS 		DATE;
	DEFINE v_stpo_regisS 		CHAR(1);
	DEFINE v_snum_operS			CHAR(8);
	DEFINE v_simp_operS			CHAR(18);
	DEFINE v_snum_oper_penS		CHAR(8);
	DEFINE v_simp_oper_penS		CHAR(18);
	DEFINE v_snum_oper_aplS		CHAR(8);
	DEFINE v_simp_oper_aplS		CHAR(18);
	DEFINE v_snum_oper_recS		CHAR(8);
	DEFINE v_simp_oper_recS		CHAR(18);


	BEGIN
		ON EXCEPTION SET sql_err
		    IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret;
		    END IF;
		END EXCEPTION;

		--INICIALIZACION DE VARIABLES GLOBALES
		LET v_cod_ret 			= "";
		LET v_cRespSP 			= "00000";
		LET v_secu_bandera 		= "000001";
		LET v_sfech_cargL		= "";
		LET v_sfech_abonL		= "";
		LET v_sBancoCuent 		= "";
		LET cCeroTar 			= "";
		LET v_scuentaband		= "";
		LET cCeroClabe			= "";
		LET v_sDia_carL			= "";
		LET v_TotalOpe_De		= "";
		LET iContadorRepetidas = 0;

		--INICIALIZACION DE VARIABLES ENCABEZADO
		LET v_snombre_archE 	= "";
		LET v_stpo_regisE 		= "";
		LET v_sNum_cteE			= "";
		LET v_sCuenta_abonoE	= "";
		LET v_snum_operaE		= "";
		LET v_sFecha_iniE		= "";
		LET v_sFecha_finE		= "";

		----INICIALIZACIONDE VARIABLES DETALLE
		LET v_snombre_archeD	= "";
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
		LET v_snom_arc_cceD		= "";
		LET v_sfec_prese_cceD 	= "";
		LET v_stpo_regi_cceD	= "";
		LET v_num_sec_cceD		= "";

		----INICIALIZACIONDE VARIABLES SUMARIO
		LET v_snombre_archeS	= "";
		LET v_stpo_regisS		= "";
		LET v_snum_operS		= "";
		LET v_simp_operS		= "";
		LET v_snum_oper_penS	= "";
		LET v_simp_oper_penS	= "";
		LET v_snum_oper_aplS	= "";
		LET v_simp_oper_aplS	= "";
		LET v_snum_oper_recS	= "";
		LET v_simp_oper_recS	= "";
		
		LET dTipoFecha = 0;

--SET DEBUG FILE TO "/tmp/sp_valida_carga.out";
	--RACE ON;

		---Empieza el programa
		--se valida que los datos de entrada no venga en blanco o NULL
		IF (p_nombre_arc = "")  OR (p_nombre_arc IS NULL) THEN
			LET v_cod_ret = "02200";
			RETURN v_cod_ret;
		END IF;

		IF (p_fecha_envio = "") OR (p_fecha_envio IS NULL) THEN
			LET v_cod_ret = "02201";
			RETURN v_cod_ret;
		END IF;
		--se valida que exista en la tabla de don_cte_encabezado
		IF EXISTS(SELECT tipo_registro FROM bdidomi:dom_cte_encabezado
					WHERE nombre_arch = p_nombre_arc AND fecha_envio = p_fecha_envio) THEN

			--SE TOMAN LOS DATOS DE LA TABLA DE ENCABEZADO
			SELECT tipo_registro, num_cte, cuenta_abono, num_operaciones, fecha_inicial, fecha_final
			INTO  v_stpo_regisE, v_sNum_cteE, v_sCuenta_abonoE, v_snum_operaE, v_sFecha_iniE, v_sFecha_finE
			FROM bdidomi:dom_cte_encabezado
			WHERE nombre_arch = p_nombre_arc AND fecha_envio = p_fecha_envio;

			-- 01- Se valida que el tipo de registro no sea diferente de "E"
			IF v_stpo_regisE <> "E" THEN
				LET v_cod_ret = "02203";
				RETURN v_cod_ret;
			END IF;
			--02-- SE  VALIDA QUE EL NUMERO DE CLIENTE SEA NUMERICO
			EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_sNum_cteE,"N") INTO v_cRespSP;
			IF v_cRespSP <> "00000" THEN
				LET v_cod_ret = "02204";
				RETURN v_cod_ret;
			END IF;
			IF v_sNum_cteE <> LPAD(SUBSTR(p_nombre_arc,2,9),20,'0') THEN
				LET v_cod_ret = "02250";
				RETURN v_cod_ret;
			END IF;
			--03-- SE VALIDA LA CUENTA DE ABONO
			EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_sCuenta_abonoE,"N") INTO v_cRespSP;
			IF v_cRespSP <> "00000" THEN
				LET v_cod_ret = "02205";
				RETURN v_cod_ret;
			END IF;
			LET v_sLonCuenta = LENGTH(v_sCuenta_abonoE);
			LET  cCeroClabe = Substr(v_sCuenta_abonoE,1,2);
			--se valida que la longitud sea diferente de la establecida
			--IF v_sLonCuenta <> 18 THEN
			IF cCeroClabe <> "00" THEN
				LET v_cod_ret = "02205";
				RETURN v_cod_ret;
			ELSE
				LET v_scuentaband = substr(v_sCuenta_abonoE,3,18);
				LET v_sLonCuenta = LENGTH(v_scuentaband);
				IF v_sLonCuenta <> 18 THEN
					LET v_cod_ret = "02205";
					RETURN v_cod_ret;
				END IF;
				--el banco de la cuenta clabe no es el mismo banco
				LET v_sBancoCuent = substr(v_sCuenta_abonoE,3,3);
				IF v_sBancoCuent <> "137" THEN
					LET v_cod_ret = "02205";
					RETURN v_cod_ret;
				ELSE
					--se valida el digito verificador
					EXECUTE PROCEDURE bdispei:sp_validadv(v_scuentaband) INTO v_iCodReSP, v_iDigVeSP;
					IF  (v_iCodReSP = 0)  AND (v_iDigVeSP = 1) THEN
					ELSE
						LET v_cod_ret = "02205";
						RETURN v_cod_ret;
					END IF;
				END IF;
			END IF;

			--04-- SE VALIDA EL NUMERO DE OPERACIONES
			EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_snum_operaE,"N") INTO v_cRespSP;
			IF v_cRespSP <> "00000" THEN
				LET v_cod_ret = "02206";
				RETURN v_cod_ret;
			END IF;
			--05-- SE VALIDA LA FECHA INICIAL
			IF (v_sFecha_iniE = "") OR (v_sFecha_iniE IS NULL) THEN
			ELSE
				--LET v_sFec_E_sp = substr(v_sFecha_iniE,5,4) || substr(v_sFecha_iniE,3,2) || substr(v_sFecha_iniE,1,2);
				EXECUTE PROCEDURE bdidomi:sp_valida_fecha(v_sFecha_iniE) into v_cRespSP;
				IF v_cRespSP <> "00000" THEN
					LET v_cod_ret = "02207";
					RETURN v_cod_ret;
				END IF;
			END IF;

			--06-- SE VALIDA LA FECHA FINAL
			IF (v_sFecha_finE = "") OR (v_sFecha_finE IS NULL) THEN
			ELSE
			--	LET v_sFec_E_sp = substr(v_sFecha_finE,5,4) || substr(v_sFecha_finE,3,2) || substr(v_sFecha_finE,1,2);
				EXECUTE PROCEDURE bdidomi:sp_valida_fecha(v_sFecha_finE) into v_cRespSP;
				IF v_cRespSP <> "00000" THEN
					LET v_cod_ret = "02208";
					RETURN v_cod_ret;
				END IF;
			END IF;
			--se valida que exista en la tabla de dom_cte_detalle
			IF EXISTS(SELECT fecha_cargo FROM bdidomi:dom_cte_detalle
						WHERE nombre_arch = p_nombre_arc AND fecha_envio = p_fecha_envio)THEN
				
				--BUSCA INSTRUCCIONES DE BAJA Y VERIFICA QUE LAS FECHAS SEAN VALIDAS Y QUE TENGAN INSTRUCCION DE ALTA CORRESPONDIENTE
				FOREACH
					SELECT Det.nombre_arch, Det.consecutivo, Det.fecha_cargo, Det.cuenta_cargo, Det.rfc_cargo, Det.cve_banco_cargo, Det.imp_operacion, Det.ref_servicio
					INTO   v_snombre_archeD, v_sConsecD, v_sfech_cargD, v_scuenta_carD, v_srfc_cargoD, v_scve_ban_caD, v_simp_operaD, v_sref_servD
					FROM bdidomi:dom_cte_detalle AS Det  
					WHERE Det.nombre_arch = p_nombre_arc
					AND Det.fecha_envio = p_fecha_envio
					AND Det.accion = 'B'
					
					IF MDY(SUBSTR(v_sfech_cargD,5,2)::INTEGER,SUBSTR(v_sfech_cargD,7,2)::INTEGER,SUBSTR(v_sfech_cargD,1,4)::INTEGER) < p_fecha_envio THEN
						LET v_cod_ret = "02252";
						RETURN v_cod_ret;
					ELSE					
						IF NOT EXISTS(SELECT 1 FROM bdidomi:dom_cte_encabezado AS Enc INNER JOIN bdidomi:dom_cte_detalle AS Det  ON (Enc.nombre_arch  = Det.nombre_arch)
										WHERE Det.fecha_cargo = v_sfech_cargD
										AND Det.cuenta_cargo = v_scuenta_carD
										AND Det.rfc_cargo = v_srfc_cargoD
										AND Det.cve_banco_cargo = v_scve_ban_caD
										AND Det.imp_operacion = v_simp_operaD
										AND Det.ref_servicio = v_sref_servD
										AND Enc.num_cte = v_sNum_cteE
										AND Det.accion = 'A'
										AND Det.estatus = 'EP') THEN
										
							LET v_cod_ret = "02253";
							RETURN v_cod_ret; 
						END IF;
					END IF;
				END FOREACH;

				FOREACH
					--SE TOMAN LOS DATOS DE LA TABLA DE DETALLE
					SELECT tipo_registro, consecutivo, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo,
							rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
							ref_titular_serv, accion, reintentar_cuenta, estatus, causa_rechazo
					INTO	v_stpo_regisD,v_sConsecD,v_sfech_cargD,v_sfech_abonD,v_stpo_cta_caD,v_scve_ban_caD,v_scuenta_carD,
							v_srfc_cargoD,v_snombre_carD,v_scuenta_aboD,v_simp_operaD,v_simp_ivaD,v_sref_numD,v_sref_leyD,v_sref_servD,
							v_sref_tit_servD,v_saccionD,v_sreint_cuentaD,v_sestatusD,v_scausa_rechazD
					FROM bdidomi:dom_cte_detalle
					WHERE nombre_arch = p_nombre_arc AND fecha_envio = p_fecha_envio
					ORDER BY consecutivo
					--07--SE VALIDA EL REGISTRO QUE NO SEA D
					IF v_stpo_regisD <> "D" THEN
						LET v_cod_ret = "02209";
						RETURN v_cod_ret;
					END IF;
					--08--SE VALIDA EL CONSECUTIVO
					IF v_secu_bandera <> v_sConsecD THEN
						LET v_cod_ret = "02210";
						RETURN v_cod_ret;
					END IF;
					LET v_secu_bandera = v_secu_bandera + 1;
					LET v_secu_bandera =  lpad(TRIM((v_secu_bandera::integer)::char(6)),6,'0');

					
					--09--se valida la fecha de cargo
					EXECUTE PROCEDURE bdidomi:sp_valida_fecha(v_sfech_cargD) into v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02211";
						RETURN v_cod_ret;
					END IF;
					
					--LET v_sFec_E_sp = substr(v_sfech_cargD,5,9) || substr(v_sfech_cargD,3,2) || substr(v_sfech_cargD,1,2);
					IF MDY(SUBSTR(v_sfech_cargD,5,2)::INTEGER,SUBSTR(v_sfech_cargD,7,2)::INTEGER,SUBSTR(v_sfech_cargD,1,4)::INTEGER) < p_fecha_envio THEN
						LET v_cod_ret = "02211";
						RETURN v_cod_ret;
					END IF;
					
					--10--se valida la fecha de ABONO
					--LET v_sFec_E_sp = substr(v_sfech_abonD,5,9) || substr(v_sfech_abonD,3,2) || substr(v_sfech_abonD,1,2);
					EXECUTE PROCEDURE bdidomi:sp_valida_fecha(v_sfech_abonD) into v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02212";
						RETURN v_cod_ret;
					END IF;
					/*LET v_sDia_carL = lpad(((substr(v_sfech_cargD,7,2) + 1)::char(2)),2,0);
					LET v_sDia_carL = lpad(trim(v_sDia_carL),2,'0');
					LET v_sfech_cargL = v_sDia_carL || substr(v_sfech_cargD,1,2) || substr(v_sfech_cargD,5,4);
					--LET v_sfech_cargL = lpad(((substr(v_sfech_cargD,1,2) + 1)::char(2)),2,0) || substr(v_sfech_cargD,3,2) || substr(v_sfech_cargD,5,4);
					LET v_fecha_sp = substr(v_sfech_cargL,3,2) || "/" || substr(v_sfech_cargL,1,2) || "/" || substr(v_sfech_cargL,5,4);*/
					--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_fecha_sp, 0 ) INTO v_cRespSP,v_fecha_sp;
					--LET v_sfech_cargL = YEAR(v_fecha_sp) || lpad((MONTH(v_fecha_sp)),2,0) || lpad((DAY(v_fecha_sp)),2,0);
					--LET v_sfech_cargL = YEAR(v_fecha_sp) || lpad((MONTH(v_fecha_sp)),2,0) || lpad((DAY(v_fecha_sp)),2,0);
					--IF v_sfech_abonD <>  v_fecha_sp THEN
						--LET v_cod_ret = "02212";
						--RETURN v_cod_ret;
					--END IF;

					--11--SE VALIDA EL TIPO DE CUENTA DE CARGO
					IF NOT EXISTS(SELECT  descripcion  FROM bdidomi:dom_tipo_cta WHERE  tipo_cta = v_stpo_cta_caD) THEN
						LET v_cod_ret = "02213";
						RETURN v_cod_ret;
					END IF;

					IF (SUBSTR(p_nombre_arc,11,1)) = 'D' THEN
					--12--SE  que el banco sea diferente a bancoppel
						IF v_scve_ban_caD = "137" THEN
							LET v_cod_ret = "02214";
							RETURN v_cod_ret;
						END IF;
					ELIF (SUBSTR(p_nombre_arc,11,1)) = 'B' THEN
						IF v_scve_ban_caD <> "137" THEN
							LET v_cod_ret = "02214";
							RETURN v_cod_ret;
						END IF;
					END IF;

					IF NOT EXISTS(select descripcion from bdinteg:si_bancos where banco = v_scve_ban_caD ) THEN
						LET v_cod_ret = "02214";
						RETURN v_cod_ret;
					END IF;
					--13--se valida la cuenta cargo
					EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_scuenta_carD,"N") INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02246";
						RETURN v_cod_ret;
					END IF;
					--Tarjeta de debito
					IF v_stpo_cta_caD = "03" THEN
						--Se valida la longitud que debe de ser de 16 caracteres
						LET v_sLonCuenta = LENGTH(v_scuenta_carD);
						LET cCeroTar = substr(v_scuenta_carD,1,4);
						--IF v_sLonCuenta <> 16 THEN
						IF cCeroTar <> "0000" THEN
							LET v_cod_ret = "02215";
							RETURN v_cod_ret;
						ELSE
							LET v_scuentaband = substr(v_scuenta_carD,5,16);
							LET v_sLonCuenta = LENGTH(v_scuentaband);
							IF v_sLonCuenta <> 16 THEN
								LET v_cod_ret = "02215";
								RETURN v_cod_ret;
							END IF;
						END IF;
					END IF;
					--se valida cuadno es por cuenta clave
					IF v_stpo_cta_caD = "40" THEN
						LET v_sLonCuenta = LENGTH(v_scuenta_carD);
						LET  cCeroClabe = Substr(v_scuenta_carD,1,2);
						--se valida que la longitud sea diferente de la establecida
						--IF v_sLonCuenta <> 18 THEN
						IF cCeroClabe <> "00" THEN
							LET v_cod_ret = "02215";
							RETURN v_cod_ret;
						ELSE
							LET v_scuentaband = substr(v_scuenta_carD,3,18);
							LET v_sLonCuenta = LENGTH(v_scuentaband);
							IF v_sLonCuenta <> 18 THEN
								LET v_cod_ret = "02215";
								RETURN v_cod_ret;
							END IF;
							--el banco de la cuenta clabe no es el mismo banco
							LET v_sBancoCuent = substr(v_scuenta_carD,3,3);
							IF v_sBancoCuent <> v_scve_ban_caD THEN
								LET v_cod_ret = "02216";
								RETURN v_cod_ret;
							ELSE
								--se valida el digito verificador
								EXECUTE PROCEDURE bdispei:sp_validadv(v_scuentaband) INTO v_iCodReSP, v_iDigVeSP;
								IF  (v_iCodReSP = 0)  AND (v_iDigVeSP = 1) THEN
								ELSE
									LET v_cod_ret = "02217";
									RETURN v_cod_ret;
								END IF;
							END IF;
						END IF;
					END IF;
					--14-- SE VALIDA EL RFC CARGP
					--LET v_slongrfc = LENGTH(v_srfc_cargoD);
					--IF v_slongrfc = 0 THEN
					--	LET v_cod_ret = "02218";
					--	RETURN v_cod_ret;
					--END IF;
					--15--SE VALIDA EL NOMBRE CARGO
					EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_snombre_carD,'T') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02219";
						RETURN v_cod_ret;
					END IF;
					--16--SE VALIDA LA CUENTA ABONO v_scuenta_aboD
					EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_scuenta_aboD,"N") INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02205";
						RETURN v_cod_ret;
					END IF;
					LET v_sLonCuenta = LENGTH(v_scuenta_aboD);
					LET  cCeroClabe = Substr(v_scuenta_aboD,1,2);
					--se valida que la longitud sea diferente de la establecida
					--IF v_sLonCuenta <> 18 THEN
					IF cCeroClabe <> "00" THEN
						LET v_cod_ret = "02220";
						RETURN v_cod_ret;
					ELSE
						LET v_scuentaband = substr(v_scuenta_aboD,3,18);
						LET v_sLonCuenta = LENGTH(v_scuentaband);
						IF v_sLonCuenta <> 18 THEN
							LET v_cod_ret = "02220";
							RETURN v_cod_ret;
						END IF;
						--el banco de la cuenta clabe no es el mismo banco
						LET v_sBancoCuent = substr(v_scuenta_aboD,3,3);
						IF v_sBancoCuent <> "137" THEN
							LET v_cod_ret = "02221";
							RETURN v_cod_ret;
						ELSE
							--se valida el digito verificador
							EXECUTE PROCEDURE bdispei:sp_validadv(v_scuentaband) INTO v_iCodReSP, v_iDigVeSP;
							IF  (v_iCodReSP = 0)  AND (v_iDigVeSP = 1) THEN
							ELSE
								LET v_cod_ret = "02222";
								RETURN v_cod_ret;
							END IF;
						END IF;
					END IF;
					--17--SE VALIDA QUE EL IMPORTE DE LA OPERACION SEA CORRECTO
					EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_simp_operaD,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02223";
						RETURN v_cod_ret;
					END IF;
					IF	((v_simp_operaD::integer)/100)  < 1 THEN
						LET v_cod_ret = "02224";
						RETURN v_cod_ret;
					END IF;
					--18--SE VALIDA QUE EL IMPORTE DEL IVA
					EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_simp_ivaD,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02225";
						RETURN v_cod_ret;
					END IF;
					IF	((v_simp_operaD::integer)/100) < 0 THEN
						LET v_cod_ret = "02226";
						RETURN v_cod_ret;
					END IF;
					--19--SE VALIDA LA REFERENCIA NUMERICA
					EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_sref_numD,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02227";
						RETURN v_cod_ret;
					END IF;
					--20--SE VALIDA LA REFERENCIA LEYENDA
					EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_sref_leyD,'T') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02228";
						RETURN v_cod_ret;
					END IF;
					--21--SE VALIDA LA REFERENCIA SERVICIO
					EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_sref_servD,'T') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02229";
						RETURN v_cod_ret;
					END IF;
					--22--SE VALIDA LA REFERENCIA TITULAR SERVICIO
					EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_sref_tit_servD,'T') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02230";
						RETURN v_cod_ret;
					END IF;
					--23--SE VALIDA LA ACCION
					IF (v_saccionD = "A") OR (v_saccionD = "B") THEN
					ELSE
						LET v_cod_ret = "02231";
						RETURN v_cod_ret;
					END IF;
					--24--SE VALIDA REINTETAR CUENTA+
					IF (v_sreint_cuentaD = "N") OR (v_sreint_cuentaD = "S") THEN
					ELSE
						LET v_cod_ret = "02232";
						RETURN v_cod_ret;
					END IF;
					/*EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_sreint_cuentaD,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02232";
						RETURN v_cod_ret;
					END IF;*/
					--25--SE VALIDA EL ESTATUS
					IF NOT EXISTS(SELECT descripcion FROM bdidomi:dom_status_pago WHERE cve_status =  v_sestatusD ) THEN
						LET v_cod_ret = "02233";
						RETURN v_cod_ret;
					END IF;
					--37--SE VALIDA QUE EL ESTATUS NO SEA DISTINTO A EP
					IF v_sestatusD <> 'EP' THEN
						LET v_cod_ret = "02251";
						RETURN v_cod_ret;
					END IF;
					--26--SE VALIDA LA CAUSA DE RECHAZO
					EXECUTE PROCEDURE bdidomi:sp_valida_cadena(v_scausa_rechazD,'B') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "02234";
						RETURN v_cod_ret;
					END IF;
				END FOREACH;
				--SE VALIDA LOS DATOS DEL SUMARIO
				IF EXISTS(SELECT tipo_registro FROM bdidomi:dom_cte_sumario
						WHERE nombre_arch = p_nombre_arc AND fecha_envio = p_fecha_envio)THEN
					--se toman los datos de la sumario
					SELECT 	tipo_registro, num_operaciones, imp_operaciones, num_oper_pend, imp_oper_pend,
							num_oper_apli, imp_oper_apli, num_oper_rech, imp_oper_rech
					INTO	v_stpo_regisS,v_snum_operS,v_simp_operS,v_snum_oper_penS, v_simp_oper_penS,
							v_snum_oper_aplS,v_simp_oper_aplS,v_snum_oper_recS,v_simp_oper_recS
					FROM bdidomi:dom_cte_sumario WHERE nombre_arch =p_nombre_arc AND fecha_envio = p_fecha_envio;

					--27--SE VALIDA EL TIPO DE REGISTRO
					IF v_stpo_regisS <> "S" THEN
						LET v_cod_ret = "02236";
						RETURN v_cod_ret;
					END IF;
					--28-- se valida el numero de operacion
					IF v_snum_operS <> v_snum_operaE THEN
						LET v_cod_ret = "02237";
						RETURN v_cod_ret;
					END IF;
					--29-- se valida el IMPORTE de operacion
					SELECT SUM(imp_operacion::integer) into v_TotalOpe_De FROM bdidomi:dom_cte_detalle
					WHERE nombre_arch = p_nombre_arc AND fecha_envio = p_fecha_envio;
					LET v_TotalOpe_De =  lpad(TRIM((v_TotalOpe_De::integer)::char(18)),18,'0');
					IF v_simp_operS <> v_TotalOpe_De THEN
						LET v_cod_ret = "02238";
						RETURN v_cod_ret;
					END IF;
					--se cambio esta validacion por peticion de carlos blanquet el dia 22 de Octubre, dado que se tiene k ser igual la sumatorio del importe del detalle al dato que trae el sumario
					/*IF v_simp_operS <> "000000000000000000" THEN
						LET v_cod_ret = "02238";
						RETURN v_cod_ret;
					END IF;*/
					--30-- se valida el numero de operacion pendientes
					IF v_snum_oper_penS <> "00000000" THEN
						LET v_cod_ret = "02239";
						RETURN v_cod_ret;
					END IF;
					--31-- se valida el IMPORTE de operacion pendientes
					IF v_simp_oper_penS <> "000000000000000000" THEN
						LET v_cod_ret = "02240";
						RETURN v_cod_ret;
					END IF;
					--32-- se valida el numero de operacion aplicadas
					IF v_snum_oper_aplS <> "00000000" THEN
						LET v_cod_ret = "02241";
						RETURN v_cod_ret;
					END IF;
					--33-- se valida el IMPORTE de operacion aplicadas
					IF v_simp_oper_aplS <> "000000000000000000" THEN
						LET v_cod_ret = "02242";
						RETURN v_cod_ret;
					END IF;
					--34-- se valida el numero de operacion rechazadas
					IF v_snum_oper_recS <> "00000000" THEN
						LET v_cod_ret = "02243";
						RETURN v_cod_ret;
					END IF;
					--35-- se valida el IMPORTE de operacion  rechazadas
					IF v_simp_oper_recS <> "000000000000000000" THEN
						LET v_cod_ret = "02244";
						RETURN v_cod_ret;
					END IF;

				--No existe en la tabla de dom_cte_SUMARIO
				ELSE
					LET v_cod_ret = "02235";
					RETURN v_cod_ret;
				END IF;
			--No existe en la tabla de dom_cte_DETALLE
			ELSE
				LET v_cod_ret = "02235";
				RETURN v_cod_ret;
			END IF;

		--No existe en la tabla de dom_cte_encabezado
		ELSE
			LET v_cod_ret = "02202";
			RETURN v_cod_ret;
		END IF;

		--FIN DEL PROCESO
		LET v_cod_ret = "00000";
		RETURN v_cod_ret;
	END;
END PROCEDURE
DOCUMENT
'MODIFICACION:Se modifica para buscar instrucciones de baja para verificar que las fechas sean validas y que tengan instruccion de alta correspondiente r.265',
'            :Se valida que la fecha cargo NO sea menor a la fecha actual r. 320)', 
'            :Se modifica para validar el numero de banco cargo, en relacion al tipo de archivo recibido (cargo a cuentas bancoppel u otros bancos r. 357)',
'            :Se omite restriccion de RFC cargo obligatorio, ya que segÃºn lo especificado en el manual DOMI, este dato es opcional r. 430)',
'FECHA: 2016/08/25',
'VERSION: 20160825.0959',
'BD: bdidomi',
'EJECUTADO POR: bdidomi:sp_domi_cargaarchivomanualproveedor';

CREATE PROCEDURE "informix".sp_domi_cargaarchivomanualproveedor(pNombre_Archivo CHAR(20), pNumCte CHAR(20),pUsert_Insert CHAR(8))
	RETURNING CHAR(5),CHAR(95),CHAR(20),INTEGER,MONEY(18,2),INTEGER,MONEY(18,2);


---- VARIABLES  GENERALES---
DEFINE cSqlerr			 INTEGER;
DEFINE cCodret      	 CHAR(5);
DEFINE cCodretSAP      	 CHAR(5);
DEFINE cCodretVCP      	 CHAR(5);
DEFINE cCodretVAP      	 CHAR(5);
DEFINE cMensajeError     CHAR(95);
DEFINE cCuenta_Abono 	 CHAR(20);
DEFINE iTotalAltas 		 INTEGER;
DEFINE mTotalImporteAltas MONEY(18,2);
DEFINE iTotalBajas 		 INTEGER;
DEFINE mTotalImporteBajas MONEY(18,2);
DEFINE cConsecutivo		 INTEGER;
DEFINE pFechaEnvio DATE;

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET cCodretSAP = '00000';
LET cCodretVCP = '00000';
LET cMensajeError = 'Procedimiento se ejecuto correctamente';
LET cCuenta_Abono = '';
LET iTotalAltas = 0 ;
LET mTotalImporteAltas = 0.00;
LET iTotalBajas = 0;
LET mTotalImporteBajas = 0.00;
LET cConsecutivo		 = '';
LET pFechaEnvio = CURRENT;
--LET pFechaEnvio = CURRENT::DATE - 1;
--SET debug FILE TO "/tmp/domi/Sp_Domi_CargaArchivoManualProveedor.out";
--Trace ON;

BEGIN
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;
            RETURN cCodret, cMensajeError, cCuenta_Abono, iTotalAltas, mTotalImporteAltas, iTotalBajas, mTotalImporteBajas;
        END IF;
	END EXCEPTION;
	---validar si el archivo ya fue procesado
	IF EXISTS (SELECT nombre_arch FROM dom_cte_archivos  WHERE nombre_arch = pNombre_Archivo AND fecha_envio = pFechaEnvio) THEN
		--ARCHIVO YA FUE PROCESADO
		LET cCodret = '99907';
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError(cCodret) INTO cCodret,cMensajeError;
		RETURN cCodret, cMensajeError, cCuenta_Abono, iTotalAltas, mTotalImporteAltas, iTotalBajas, mTotalImporteBajas;
	END IF;
	--validar el consecutivo del archivo
	SELECT COUNT(nombre_arch) + 1 INTO cConsecutivo FROM dom_cte_archivos  WHERE SUBSTR(nombre_arch,1,18) = SUBSTR(pNombre_Archivo,1,18) AND num_cte = pNumCte AND fecha_envio = pFechaEnvio;
	let cMensajeError = LPAD(cConsecutivo,2,'0')||'**'||SUBSTR(pNombre_Archivo,19,2);
	IF LPAD(cConsecutivo,2,'0') <> SUBSTR(pNombre_Archivo,19,2) THEN
		--EL CONSECUTIVO DEL ARCHIVO NO ES EL CORRECTO
		LET cCodret = '99906';
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError(cCodret) INTO cCodret,cMensajeError;
		RETURN cCodret, cMensajeError, cCuenta_Abono, iTotalAltas, mTotalImporteAltas, iTotalBajas, mTotalImporteBajas;
	END IF;
	--subir el archivo a las tablas para validarlo
	EXECUTE PROCEDURE bdidomi:sp_Domi_SubirArchivosProveedor (pNombre_Archivo, pFechaEnvio,pNumCte,pFechaEnvio,'01',pUsert_Insert) INTO cCodretSAP, cMensajeError;
	IF cCodretSAP <> 0 THEN
		--Borrar las tablas
		DELETE FROM dom_cte_sumario WHERE nombre_arch = pNombre_Archivo;
		DELETE FROM dom_cte_detalle WHERE nombre_arch = pNombre_Archivo;
		DELETE FROM dom_cte_encabezado WHERE nombre_arch = pNombre_Archivo;
		DELETE FROM dom_cte_archivos WHERE nombre_arch = pNombre_Archivo;
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError(cCodretSAP) INTO cCodret,cMensajeError;
		RETURN cCodret, cMensajeError, cCuenta_Abono, iTotalAltas, mTotalImporteAltas, iTotalBajas, mTotalImporteBajas;
	END IF;
	--validacion del archivo del provedor estructura etc.etc.
	EXECUTE PROCEDURE sp_valida_carga_proveedor(pNombre_Archivo, pFechaEnvio) INTO cCodretVCP;
	IF cCodretVCP <> 0 THEN
		--Borrar las tablas
		DELETE FROM dom_cte_sumario WHERE nombre_arch = pNombre_Archivo;
		DELETE FROM dom_cte_detalle WHERE nombre_arch = pNombre_Archivo;
		DELETE FROM dom_cte_encabezado WHERE nombre_arch = pNombre_Archivo;
		DELETE FROM dom_cte_archivos WHERE nombre_arch = pNombre_Archivo;
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError(cCodretVCP) INTO cCodret,cMensajeError;
		RETURN cCodret, cMensajeError, cCuenta_Abono, iTotalAltas, mTotalImporteAltas, iTotalBajas, mTotalImporteBajas;
	END IF;
	--validacion del archivo del provedor estructura etc.etc.
	EXECUTE PROCEDURE Sp_Domi_ValidaArchivoProveedor(pNombre_Archivo, pFechaEnvio) INTO cCodretVAP;
	IF cCodretVAP <> 0 THEN
		--Borrar las tablas
		DELETE FROM dom_cte_sumario WHERE nombre_arch = pNombre_Archivo;
		DELETE FROM dom_cte_detalle WHERE nombre_arch = pNombre_Archivo;
		DELETE FROM dom_cte_encabezado WHERE nombre_arch = pNombre_Archivo;
		DELETE FROM dom_cte_archivos WHERE nombre_arch = pNombre_Archivo;
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError(cCodretVAP) INTO cCodret,cMensajeError;
		RETURN cCodret, cMensajeError, cCuenta_Abono, iTotalAltas, mTotalImporteAltas, iTotalBajas, mTotalImporteBajas;
	END IF;
	---------------OBTENER LOS DATOS  la cuenta abono,TOTAL DE ALTAS, IMPORTE DE LAS ALTAS,  TOTAL DE BAJAS, IMPORTE DE LAS BAJAS,
	--selecciona la cuenta abono
	SELECT cuenta_abono INTO cCuenta_Abono FROM dom_cte_encabezado WHERE nombre_arch = pNombre_Archivo;
	--seleccionar cuantos son altasCOUNT(accion),
	SELECT COUNT(accion), SUM((imp_operacion::money)/100) INTO iTotalAltas, mTotalImporteAltas FROM dom_cte_detalle
	WHERE nombre_arch = pNombre_Archivo AND accion = 'A';
	SELECT COUNT(accion), SUM((imp_operacion::money)/100) INTO iTotalBajas, mTotalImporteBajas FROM dom_cte_detalle
	WHERE nombre_arch = pNombre_Archivo AND accion = 'B';

	LET cMensajeError = 'Procedimiento se ejecuto correctamente';

	RETURN cCodret, cMensajeError, cCuenta_Abono, NVL(iTotalAltas,0), NVL(mTotalImporteAltas,0), NVL(iTotalBajas,0), NVL(mTotalImporteBajas,0);
END
END PROCEDURE
DOCUMENT
'AUTOR :CÃ?Â©sar ValdÃ?Â©z Figueroa',
'DESCRIPCION: Este Procediemiento en el principal para la carga manual de archivo del proveedor, mandando a ejecutar los procedimientos que ',
'	validan y realizan la carga de archivo, a demas que si el archivo de carga bien regresa unos totales que e requieren en la aplicacion	',
'FECHA : Agosto de 2009',
'BD    : BDIDOMI',
'VERSION: 20090810.1200';

CREATE PROCEDURE "informix".sp_domi_generador_presentador(psNombreArchivo CHAR(20),psNumEmpleado CHAR (8))

RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE DOMICILIACION -- RECEPTOR
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 23/07/2009
-- BD: BdiDomi
-- SISTEMA : Domiciliacion
-- 14Jun2010 - FRG --> Se agrega el llamado al 'sp_domi_generaarchivoproveedor.sql' para DOMI TDC
--****************************************************************************************************

--DEFINICION DE VARIABLES.
DEFINE vsFlagTipoProceso 		CHAR(1);
DEFINE vsNomProceso 			CHAR(20);
DEFINE vsDescripcionProceso 	CHAR(60);
DEFINE sGENERANDO 				CHAR(1);
DEFINE sFINALIZADO				CHAR(1);
DEFINE sERROR 					CHAR(1);
DEFINE visqlerr 				INTEGER;
DEFINE vsNomArchivo 			CHAR(20);
DEFINE vsFechaPresentacion 		CHAR(8);
DEFINE vsFechaPresentacion1		CHAR(8);
DEFINE vsCodRetorno 			CHAR(5);
DEFINE vsCodRetorno2 			CHAR(5);
DEFINE vdtFecha 				DATE;
DEFINE vdtFechaInsert 			DATE;
DEFINE vsMensajeRespuesta 		CHAR (100);
DEFINE viContador 				INTEGER;
DEFINE viTipoArchivo 			INTEGER;
DEFINE vsDia 					CHAR(2);
DEFINE vsMes 					CHAR(2);
DEFINE vsAno 					CHAR(4);
DEFINE vsSpLlamado 				CHAR(24);
DEFINE vsCveBanc 				CHAR(3);
DEFINE cNumCteCoppel			CHAR(20);
DEFINE cCuentaAbono_Prov		CHAR(20);
DEFINE dFecha_hoy				DATE;
DEFINE cNom_Arch_Salida			CHAR(20);
DEFINE cCodret 					CHAR(5);
DEFINE dFechaArchivo_salida		DATE;
DEFINE cCodSpFecha				CHAR(5);

--INICIALIZACION DE VARIABLES.
LET vsFlagTipoProceso			= '';
LET vsNomProceso				= '';
LET vsDescripcionProceso		= '';
LET sGENERANDO					= '0';
LET sFINALIZADO					= '1';
LET sERROR						= '3';
LET visqlerr					= 0;
LET vsNomArchivo				= '';
LET vsFechaPresentacion			= '';
LET vsFechaPresentacion1		= '';
LET vsCodRetorno				= '';
LET vsCodRetorno2				= '';
LET vdtFecha					= CURRENT::DATE;
LET vdtFechaInsert				= CURRENT::DATE;
LET vsMensajeRespuesta			= '';
LET viContador					= 0;
LET viTipoArchivo				= 0;
LET vsDia						= '';
LET vsMes						= '';
LET vsAno						= '';
LET vsSpLlamado					= '';
LET vsCveBanc					= '';
LET cNumCteCoppel 				= '';
LET cCuentaAbono_Prov			= '';
LET dFecha_hoy 					= '';
LET cNom_Arch_Salida 			= '';
LET cCodret 					= '00000';
LET cCodSpFecha  				= '';



BEGIN

ON EXCEPTION SET visqlerr --Control de errores.
	EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
	sERROR, visqlerr, psNumEmpleado, 'ERROR NO CONTROLADO', TRIM(vsNomArchivo), vsFechaPresentacion, '11') INTO vsCodRetorno;
	LET vsMensajeRespuesta = 'ERROR NO CONTROLADO(' || visqlerr || ') ARCHIVO: ' || TRIM(vsNomArchivo) || ' PROCESO: ' || TRIM(vsDescripcionProceso) ;
	RETURN  vsNomArchivo, visqlerr, vsMensajeRespuesta;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/josea/10211/sp_domi_generador_presentador.trace";
--TRACE ON;

-- FRG_I  -------> Se agrega el proceso "bdidomi:"informix".sp_domi_generaarchivoproveedor" para DOMI TDC
LET vsDescripcionProceso = 'Proceso carga informacion DOMI TDC';
EXECUTE PROCEDURE bdidomi:sp_domi_generaarchivoproveedor(psNumEmpleado) INTO vsCodRetorno;
LET vsCodRetorno				= '';

LET vsDescripcionProceso = 'Validacion de numero de empleado.';
EXECUTE PROCEDURE BdiDomi:Sp_Valida_Cadena(TRIM(psNumEmpleado),'N') INTO vsCodRetorno;

LET vsDescripcionProceso = 'Validacion de parametros.';
SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;
IF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01') THEN -- Valida que exista el parametro RUTA ARCHIVO PROCESAR.
	LET vsCodRetorno = '02100';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '02') THEN -- Valida que exista el parametro RUTA ARCHIVO RESPUESTA.
	LET vsCodRetorno = '02101';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '03') THEN -- Valida que exista el parametro RUTA ARCHIVOS PROCESADOS.
	LET vsCodRetorno = '02102';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '04') THEN -- Valida que exista el parametro RUTA ARCHIVOS ERRONEOS.
	LET vsCodRetorno = '02103';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '05') THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL.
	LET vsCodRetorno = '02104';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '06') THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO.
	LET vsCodRetorno = '02105';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '43') THEN -- Valida que exista el nuevo parametro BIN CORRESPONDIENTE TARJETA DEBITO.
	LET vsCodRetorno = '02105'; 
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '07') THEN -- Valida que exista el parametro SUCURSAL CONTABLE DOMI.
	LET vsCodRetorno = '02106';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '08') THEN -- Valida que exista el parametro TRANSACCION DE CARGO POR DOMI.
	LET vsCodRetorno = '02107';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '09') THEN -- Valida que exista el parametro TRANSACCION DE ABONO.
	LET vsCodRetorno = '02108';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '10') THEN -- Valida que exista el parametro IMPORTE MAXIMO CECOBAN.
	LET vsCodRetorno = '02109';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '11') THEN -- Valida que exista el parametro MAXIMO DE RECHAZOS PERMITIDOS.
	LET vsCodRetorno = '02110';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '12') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI.
	LET vsCodRetorno = '02111';
--ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '13') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI.
--	LET vsCodRetorno = '02112';
ELIF NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:Sc_Fechas) THEN -- Valida que exista el parametro de la fecha actual.
	LET vsCodRetorno = '02113';
ELIF (TRIM(psNumEmpleado) = '') THEN --NUMERO DE EMPLEADO VACIO.
	LET vsCodRetorno = '02114';
ELIF (LENGTH(TRIM(psNumEmpleado)) < 8 ) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS.
	LET vsCodRetorno = '02115';
ELIF (vsCodRetorno <> '00000') THEN --ERROR EL NUMERO DE EMPLEADO CONTIENE  CARACTERES INVALIDOS.
	LET vsCodRetorno = '02116';
ELIF NOT EXISTS(SELECT ejecutivo FROM bdinteg:si_ejecut WHERE ejecutivo = psNumEmpleado)THEN --EL NUM EMPLEADO NO EXISTE EN SI_EJECUT
	LET vsCodRetorno = '02117';
ELSE
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--Se obtiene la fecha del dia actual.
	SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:Sc_Fechas;
	--Valida que la fecha actual sea dia laboral.
	EXECUTE PROCEDURE BdiDomi:Sp_Valida_Fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRetorno;
		--Valida si el codigo de retorno es diferente a '00000' el dia es no laboral.
		IF(vsCodRetorno <> '00000') THEN
			--El dia no es laboral.
			LET vsCodRetorno = '02112';
		ELSE --DIA LABORAL.
			LET vsCodRetorno = '00000';
		END IF;
END IF;

--Valida si todos los parametros existen y si la fecha con la que se generaran los archivos corresponde a un dia habil.
IF(vsCodRetorno = '00000')THEN
	--Se inicializa contador en cero para realizar procedimiento automatico 3 veces archivo 10,30 y 34 tambien se marca con 'A' de automatico el tipoflag.
	LET viContador = 0;
	LET vsFlagTipoProceso = 'A';
	--Se guarda en variable la clave bancaria correspondiente con la que se generaran archivos.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsCveBanc FROM bdidomi:dom_parametros  WHERE cod_param = '05';
	--Mientras el contador sea menor a 3 y el flagproceso sea 'A' automatico.
	WHILE ((viContador < 2) AND (vsFlagTipoProceso = 'A'))
		LET vsDescripcionProceso = 'Obtencion de nombre de archivo';
		--Valida que el nombre del archivo se recibe en blanco.
		IF(TRIM(psNombreArchivo) = '') THEN
			--Se arma la fecha dia mes y aÃ±o para el armado completo del nombre de archivo.
			LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
			LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
			LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
			LET vsFechaPresentacion = vsAno || vsMes || vsDia;
			IF(viContador = 0)THEN
				LET viTipoArchivo = 10;
			ELIF(viContador = 1)THEN
				LET viTipoArchivo = 30;
			ELSE --NINGUN TIPO DEFINIDO
					LET viTipoArchivo = 0;
			END IF;
			-- Se asigna a variable el nombre completo del archivo.
			LET vsNomArchivo = 'E' --CONSTANTE
									|| TRIM(vsCveBanc)--CONSTANTE
									|| vsDia
									|| vsMes
									|| vsAno
									|| '.' --CONSTANTE
									|| viTipoArchivo::CHAR(2)
									|| '01'; --SECUENCIA DEL ARCHIVO 98 PARA AUTOMATICO
		ELIF(TRIM(psNombreArchivo) <> '')THEN
			--Se marca el proceso como manual.
			LET vsFlagTipoProceso = 'M';
			LET vsNomArchivo = psNombreArchivo;
			LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
			LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
			LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
			LET vsFechaPresentacion = vsAno || vsMes || vsDia;
			IF( SUBSTRING (TRIM(vsNomArchivo) FROM 14 FOR 2) = '10' ) THEN --ARCHIVO 10
				LET viTipoArchivo = 10;
			ELIF( SUBSTRING (TRIM(vsNomArchivo) FROM 14 FOR 2) = '30' ) THEN --ARCHIVO 30
				LET viTipoArchivo = 30;
			--Archivo no valido.
			ELSE
				LET viTipoArchivo = 0;
			END IF;
		END IF;
		--Valida que el nombre del archivo posea la extension adecuada.
		IF (LENGTH (TRIM(vsNomArchivo)) >= 16)THEN
				LET vsNomProceso = 'GENARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || SUBSTRING (TRIM(vsNomArchivo) FROM 16 FOR 2);
		--Error de longitud del archivo archivo no reconocido.
		ELSE
				LET vsNomProceso = 'GENARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || '00';
		END IF ;

		LET vsDescripcionProceso = 'Validacion nombre archivo.';
		--Valida la integridad del nombre de archivo.
		EXECUTE PROCEDURE BdiDomi:sp_domi_validarnombrearchivos(viTipoArchivo, 'E', vsNomArchivo) INTO vsCodRetorno;
		--Valida si el nombre del archivo fue integro.
		IF(vsCodRetorno = '00000')THEN
			LET vsDescripcionProceso = 'Validacion de generaciones previas.';
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			IF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sFINALIZADO ) THEN  --EL ARCHIVO FUE GENERADO PREVIAMENTE
				LET vsCodRetorno = '02118';
				EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
				INSERT INTO BdiDomi:Dom_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Domi_Generador_Presentador', vsMensajeRespuesta, psNumEmpleado, CURRENT);
			ELIF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ) THEN  --EL ARCHIVO SE ENCUENTRA GENERANDO
				LET vsCodRetorno = '02119';
				EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
				INSERT INTO BdiDomi:Dom_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Domi_Generador_Presentador', vsMensajeRespuesta, psNumEmpleado, CURRENT);
			ELIF NOT EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sERROR ) THEN  --EL ARCHIVO FUE GENERADO CON ERROR
				--Crea registro de generacion de archivo.
				LET vsDescripcionProceso = 'Registro de generacion del archivo.';
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
				sGENERANDO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Generador_Presentador', TRIM(vsNomArchivo), vsFechaPresentacion, '11') INTO vsCodRetorno2;
				LET vsCodRetorno = '00000';
			ELSE
				LET vsDescripcionProceso = 'Registro de regeneracion del archivo.';
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
				sGENERANDO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Generador_Presentador', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
				LET vsCodRetorno = '00000';
			END IF;
				IF(vsCodRetorno = '00000')THEN
					LET vsDescripcionProceso = 'Borrado de tablas de paso.';
					--Limpia las tablas de paso para generar el nuevo archivo.
					EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), '', 'B') INTO vsCodRetorno;
					--Valida que las tablas se limpiaron correctamente.
					IF(vsCodRetorno = '00000')THEN
						LET vsDescripcionProceso = 'Generar informacion a tablas de paso.';
						IF(viTipoArchivo = 10)THEN
							EXECUTE PROCEDURE BdiDomi:sp_domi_generarArchivo10(vsNomArchivo, psNumEmpleado) INTO vsCodRetorno;
							LET vsSpLlamado = 'sp_domi_generarArchivo10';
						ELIF(viTipoArchivo = 30)THEN
							EXECUTE PROCEDURE BdiDomi:sp_domi_generarArch30(vsNomArchivo, psNumEmpleado) INTO vsCodRetorno;
							LET vsSpLlamado = 'sp_domi_generarArch30';
						END IF;
						--Valida que se genero la informacion correctamente.
						IF(vsCodRetorno = '00000') THEN
							LET vsDescripcionProceso = 'Verificar existencia de registros.';
							IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
								IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
									IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
										LET vsDescripcionProceso = 'Descargar archivo a repositorio.';
										SET LOCK MODE TO WAIT 3;
										SET ISOLATION TO DIRTY READ;
										SELECT Fecha_Presentacion INTO vsFechaPresentacion1 FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE nombre_arch = TRIM(vsNomArchivo) ;
										EXECUTE PROCEDURE BdiDomi:sp_Domi_GeneraArchivo(vsNomArchivo, vsFechaPresentacion1, '01') INTO vsCodRetorno;
										--Verifica si se genero el archivo correctamente.
										IF (vsCodRetorno = '00000')THEN
											LET vsDescripcionProceso = 'Guardar en ccearchivos.';
											EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (psNumEmpleado, TRIM (vsNomArchivo), vsFechaPresentacion, '01') INTO vsCodRetorno;
											--Verifica si guardo en ccearchivos correctamente.
											IF (vsCodRetorno = '00000')THEN
												--Verifica si es un archivo 30 el que se genero, en ese caso se actualiza la tabla cte detalle.
												IF(viTipoArchivo = 30)THEN
													EXECUTE PROCEDURE BdiDomi:sp_domi_actualizar_cte_detalle(vsNomArchivo, vsFechaPresentacion) INTO vsCodRetorno;
													IF(vsCodRetorno <> '00000')THEN
														LET vsCodRetorno = '02120';
														EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
														sERROR, vsCodRetorno, psNumEmpleado, 'sp_domi_actualizar_cte_detalle', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
													ELSE
														LET vsCodRetorno = '00000';
													END IF;
												END IF;
													LET vsDescripcionProceso = 'Guardar historico.';
													EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), vsFechaPresentacion1, 'T') INTO vsCodRetorno;
													--Vallida que se paso informacion a historico correctamente.
													IF (vsCodRetorno = '00000')THEN
														--Guarda bitacora exito.
														LET vsDescripcionProceso = 'Generacion de archivo exitosa.';
														EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
														sFINALIZADO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Generador_Presentador', TRIM(vsNomArchivo) , vsFechaPresentacion, '02') INTO vsCodRetorno2;
													--Error al guardar informacion a tablas historico.
													ELSE
														LET vsCodRetorno = '02129';
														EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
														sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_MoverRegistrosHist', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
													END IF;
											--Error al descargar archivo a repositorio.
											ELSE
												LET vsCodRetorno = '02128';
												EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
												sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_GuardarCCEArchivos', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
											END IF;
										ELSE
											LET vsCodRetorno = '02127';
											EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
											sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_GeneraArchivo', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
										END IF;
									--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla sumario.
									ELSE
										LET vsCodRetorno = '02126';
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
										sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
									END IF;
								--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla detalle.
								ELSE
									LET vsCodRetorno = '02125';
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
									sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
								END IF;
							--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla encabezado.
							ELSE
								LET vsCodRetorno = '02124';
								EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
								sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
							END IF;
						--Error al generar informacion a tablas de paso.
						ELSE
							LET vsCodRetorno = '02123';
							EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
							sERROR, vsCodRetorno, psNumEmpleado, vsSpLlamado, TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
						END IF;
					--Error al limpiar las tablas de paso.
					ELSE
						LET vsCodRetorno = '02122';
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
						sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_MoverRegistrosHist', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
					END IF;
				--El archivo ya fue generado previamente o el archivo se encuentra generando.
				END IF;
		--Error al validar la integridad del nombre del archivo.
		ELSE
			LET vsCodRetorno = '02121';
			EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
			sERROR, vsCodRetorno, psNumEmpleado, 'sp_domi_validarnombrearchivos', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
		END IF;
		IF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ) THEN  --EL ARCHIVO SE ENCUENTRA GENERANDO
			IF(vsCodRetorno <> '02119') THEN --VALIDA SI EL ERROR ES DISTINTO DE 'GENERANDO'
				UPDATE BdiDomi:Dom_Procesos SET Estatus = sERROR WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ;
			END IF;
		END IF;
		
		/*IF viContador = 1 THEN		
			--SE OBTIENE NUMERO DE CLIENTE COPPEL
			SELECT TRIM(valor) 
			INTO cNumCteCoppel FROM dom_parametros
			WHERE cod_param = '45';
			
			--SE OBTIENE NUMERO DE CUENTA COPPEL
			SELECT TRIM(valor) 
			INTO cCuentaAbono_Prov FROM dom_parametros
			WHERE cod_param = '46';			
		
			EXECUTE FUNCTION bdinteg:splvalfecha('001',(vdtFecha) + 1 ,0)INTO cCodSpFecha,dFechaArchivo_salida; --a qui ya tengo el dias siguiente habil
			
			LET cNom_Arch_Salida = 	'S'||
									TRIM(cNumCteCoppel)||
									'D'||
									LPAD(DAY(dFechaArchivo_salida),2,'0') || 	LPAD(MONTH(dFechaArchivo_salida),2,'0') || SUBSTR(YEAR(dFechaArchivo_salida)::CHAR(4),3,2)||
									'.'||
									'01';
									
			IF EXISTS(SELECT 1 FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida) THEN
				
				INSERT INTO dom_cte_archivos(nombre_arch, fecha_envio, num_cte, fecha_carga, cve_status, user_insert, fecha_insert)
				VALUES (cNom_Arch_Salida, dFechaArchivo_salida, cNumCteCoppel, vdtFecha, '01', psNumEmpleado, CURRENT::DATE);
				
				LET cNumCteCoppel = LPAD(TRIM(cNumCteCoppel), 20,'0');
				
				INSERT INTO dom_cte_encabezado(nombre_arch, fecha_envio, tipo_registro, num_cte, cuenta_abono, 
							num_operaciones, 
							fecha_inicial, fecha_final, user_insert, fecha_insert)
				SELECT LIMIT 1 nombre_arch, dFechaArchivo_salida, 'E', cNumCteCoppel, LPAD(TRIM(cCuentaAbono_Prov),20,'0'), 
					   LPAD((SELECT COUNT(*)	FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida),8,'0'),
					   (SELECT MIN(fecha_cargo) FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida),
					   (SELECT MAX(fecha_cargo) FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida),
					   psNumEmpleado, CURRENT::DATE
				FROM dom_cte_detalle 
				WHERE nombre_arch = cNom_Arch_Salida;
				
				INSERT INTO dom_cte_sumario(nombre_arch, fecha_envio, tipo_registro, num_operaciones, imp_operaciones, num_oper_pend, imp_oper_pend, num_oper_apli, 
							imp_oper_apli, num_oper_rech, imp_oper_rech, user_insert, fecha_insert)
				SELECT LIMIT 1 nombre_arch, dFechaArchivo_salida, 'S', LPAD((SELECT COUNT(*)	FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida),8,'0'),
				(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida),
				LPAD ((SELECT COUNT (*) FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo = 'PR'),8, '0'), 
				(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo = 'PR'),
				LPAD ((SELECT COUNT (*) FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida AND estatus = '01'),8, '0'), 
				(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida AND estatus = '01'),
				LPAD ((SELECT COUNT (*) FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo <> 'PR'),8, '0'),
				(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo <> 'PR'),
				psNumEmpleado, CURRENT::DATE
				FROM dom_cte_detalle 
				WHERE nombre_arch = cNom_Arch_Salida;			
			
				--EXECUTE PROCEDURE "informix".sp_domi_cop_generaarchivo(cNom_Arch_Salida, '02') INTO cCodret;	
				
			END IF;		
		END IF;*/
		
		EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
		
		RETURN vsNomArchivo, vsCodRetorno, vsMensajeRespuesta WITH RESUME;
		LET viContador = viCOntador + 1;
	END WHILE;
		
--Error en la validacion de parametros.
ELSE
	LET vsCodRetorno = vsCodRetorno;
	EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
	RETURN 'GENERAL', vsCodRetorno, vsMensajeRespuesta;
END IF;

END
END PROCEDURE;