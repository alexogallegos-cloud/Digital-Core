CREATE PROCEDURE "informix".sp_domi_valida_datos(p_cNombreArc CHAR(20), p_cfec_presen CHAR(8),p_cTipArch CHAR(1),p_cNumArchi integer,p_cRol CHAR(1),p_nomproceso CHAR(20))

 returning char(5), CHAR (2);
	--ElaborÃÂÃÂ³: Alejandro Osuna Iza
	--Actividad: Valida los datos en las tablas de paso
	--Solicito: Hector Casanova
	--Fecha: 13 de julio de 2009
	--NOTA.-14/09/2009
		--Se quito la validacion en las cuentas que vengan rellenadas con 0 a la izquierda, solo se valida los digitos de la cuenta cuendo es un tipo 03 se valida del 5 al 20, cuando sea un tipo 40 se valdia del 3 al 20 del dato.
		--Solicito jaime gonzales.

	DEFINE	nom_arch CHAR(20);
	DEFINE	fec_presen CHAR(8);
	DEFINE	v_cod_ret CHAR(5);
	DEFINE  v_nivel CHAR(2);
	DEFINE	sql_err INTEGER;
	DEFINE v_contusoba INTEGER;
	DEFINE v_ciclo  integer;
	DEFINE v_bancorev char(3);
	DEFINE v_ini INTEGER;
	DEFINE v_bancComa CHAR(1);
	DEFINE v_BancoCoppel	CHAR(3);
	DEFINE v_f_ENC CHAR(8);
	DEFINE i_importe Integer;
	DEFINE i_valormax integer;
	DEFINE	no_cod_oper CHAR(2);
	--Se declaran las variables para utilizar en  las validaciones del bloque

	DEFINE	e_tpo_reg CHAR(2);
	DEFINE	e_num_secu CHAR(7);
	DEFINE	e_cod_oper CHAR(2);
	DEFINE	e_cve_ban CHAR(3);
	DEFINE	e_sentido CHAR(1);
	DEFINE	e_servicio CHAR(1);
	DEFINE	e_num_bloq CHAR(7);
	DEFINE v_fecha_prese	CHAR(8);
	DEFINE	e_cod_divi CHAR(2);
	DEFINE	e_cve_rech_bl CHAR(2);
	DEFINE	e_modalidad CHAR(1);
	DEFINE	e_fut_ccen CHAR(41);
	DEFINE	e_fut_banco CHAR(345);

	--Se declaran las variables para utilizar en Detalle
	--nombre_arch CHAR(20),

	DEFINE	d_tpo_reg CHAR(2);
	DEFINE	d_num_secu CHAR(7);
	DEFINE	d_cod_oper CHAR(2);
	DEFINE	d_cod_divi CHAR(2);
	DEFINE	d_fec_trans CHAR(8);
	DEFINE	d_ban_pres CHAR(3);
	DEFINE	d_ban_rece CHAR(3);
	DEFINE	d_importe CHAR(15);
	DEFINE	d_futuro_ccen CHAR(16);
	DEFINE	d_tpo_opera CHAR(2);
	DEFINE	d_fec_aplica CHAR(8);
	DEFINE	d_tpo_cta_ord CHAR(2);
	DEFINE	d_num_cta_ord CHAR(20);
	DEFINE	d_nombre_ord CHAR(40);
	DEFINE	d_rfc_ord CHAR(18);
	DEFINE	d_tpo_cta_rec CHAR(2);
	DEFINE	d_num_cta_rec CHAR(20);
	DEFINE	d_nombre_rec CHAR(40);
	DEFINE	d_rfc_rec CHAR(18);
	--no vienen en la descripcion, pero si en el manual de cecoban
    DEFINE	d_ref_serv CHAR(40);
	DEFINE	d_nom_tit_serv CHAR(40);
	DEFINE	d_imp_iva CHAR(15);
	DEFINE	d_ref_nume CHAR(7);
	DEFINE	d_ref_leyen CHAR(40);
	DEFINE	d_cve_rast CHAR(30);
	--Si vienen
	DEFINE	d_motivo_dev CHAR(2);
	DEFINE	d_fec_pres_ini CHAR(8);
	DEFINE	d_futuro_banco CHAR(12);
	--No se ocupa para la generacion del archivo
	DEFINE	cve_estatus CHAR(2);
	DEFINE	folio_suc CHAR(16);

	--Se declaran las variables para utilizar en Sumario de bloque
	DEFINE	s_tpo_reg CHAR(2);
	DEFINE	s_num_secu CHAR(7);
	DEFINE	s_cod_oper CHAR(2);
	DEFINE	s_num_bloq CHAR(7);
	DEFINE	s_num_oper CHAR(7);
	DEFINE	s_imp_oper CHAR(18);
	DEFINE	s_uso_fut_ccen CHAR(40);
	DEFINE	s_uso_fut_banco CHAR(339);

	---Variables a utilizar para validaciones de amarre
	DEFINE v_sPriNomb CHAR(1);
	DEFINE v_cRespSP  CHAR(5);
	DEFINE v_dFechaSp DATE;
	DEFINE v_sRetCodSP CHAR(5);
	DEFINE v_dFechaReSp DATE;
	DEFINE v_secu_bandera CHAR(7);
	DEFINE v_secu_max CHAR(7);
	DEFINE v_fecha_dia CHAR(2);
	DEFINE v_fecha_mes CHAR(2);
	DEFINE v_fecha_ano CHAR(4);
	DEFINE v_sValorMax CHAR(15);
	DEFINE v_dFechaProce DATE;
	DEFINE v_LogTarDeb	Integer;
	DEFINE v_BancTar 	CHAR(3);
	DEFINE v_iCodReSP INTEGER;
	DEFINE v_iDigVeSP INTEGER;
	DEFINE v_iNombre	integer;
	DEFINE v_iBanNume	integer;
	DEFINE v_fec_40		CHAR(8);
	DEFINE v_iCont_blo	integer;
	DEFINE v_SumOper	CHAR(20);
	DEFINE v_cRechBlo	CHAR(3);
	DEFINE dFechaSis 	DATE;
	DEFINE cCicloFech CHAR(1);
	DEFINE cBancNom CHAR(3);
	DEFINE cDiaNom CHAR(2);
	DEFINE cAnoNom CHAR(4);
	DEFINE cMesNom CHAR(2);
	DEFINE cConseNom CHAR(2);
	DEFINE cNomFecha CHAR(20);
	DEFINE cCeroTar  CHAR(16);
	DEFINE cCeroClabe  CHAR(18);
	DEFINE v_cuenta_sp CHAR(18);
	DEFINE v_bancoNomb	CHAR(3);
	DEFINE v_diablokNomb	CHAR(2);
	DEFINE v_dianombre		CHAR(2);
	DEFINE v_cfec_presen DATE;
	DEFINE v_NombrePruBlo CHAR(20);
	DEFINE v_counBloc	integer;
	DEFINE v_contaBlco	char(2);



	begin
	

		
		on exception set sql_err
		    if sql_err <> 0 then
				let v_cod_ret = sql_err;
				return v_cod_ret,v_nivel;
		    end if;
		end exception;

        SET ISOLATION DIRTY READ;
        SET LOCK MODE TO wait 3;

		LET nom_arch = "";
		LET	fec_presen = "";
		let	v_cod_ret ="00000";
		LET v_nivel = "00";
		LET v_NombrePruBlo = "";
		LET v_contaBlco = "";
		LET v_ciclo = 0;
		let v_bancorev = "";
		let v_ini = 0;
		LET v_bancComa = "";
		LET v_BancoCoppel = "";
		LET v_f_ENC = "";
		LET no_cod_oper = "";

		--Se Inicializan las variables para utilizar  en las validaciones del bloque
	 	--LET	e_fec_pres = "";
		LET	e_tpo_reg = "";
		LET	e_num_secu = "";
		LET	e_cod_oper = "";
		LET	e_cve_ban = "";
		LET	e_sentido = "";
		LET	e_servicio = "";
		LET	e_num_bloq = "";
		LET	e_cod_divi = "";
		LET	e_cve_rech_bl = "";
		LET	e_modalidad = "";
		LET	e_fut_ccen = "";
		LET	e_fut_banco = "";

		--Se Inicializan las variables para utilizar en Detalle
		LET	d_tpo_reg = "";
		LET	d_num_secu = "";
		LET	d_cod_oper = "";
		LET	d_cod_divi = "";
		LET	d_fec_trans = "";
		LET	d_ban_pres = "";
		LET	d_ban_rece = "";
		LET	d_importe = "";
		LET	d_futuro_ccen  = "";
		LET	d_tpo_opera = "";
		LET	d_fec_aplica = "";
		LET	d_tpo_cta_ord = "";
		LET	d_num_cta_ord = "";
		LET	d_nombre_ord = "";
		LET	d_rfc_ord = "";
		LET	d_tpo_cta_rec = "";
		LET	d_num_cta_rec = "";
		LET	d_nombre_rec = "";
		LET	d_rfc_rec = "";

	    LET	d_ref_serv = "";
		LET	d_nom_tit_serv = "";
		LET	d_imp_iva = "";
		LET	d_ref_nume = "";
		LET	d_ref_leyen = "";
		LET	d_cve_rast = "";
		LET	d_motivo_dev = "";
		LET	d_fec_pres_ini = "";
		LET d_futuro_banco = "";
		LET cve_estatus = "";
		LET	folio_suc = "";


		--Se Inicializan las variables para utilizar en sumario de bloque
		LET	s_tpo_reg = "";
		LET	s_num_secu = "";
		LET	s_cod_oper = "";
		LET	s_num_bloq = "";
		LET	s_num_oper = "";
		LET	s_imp_oper = "";
		LET s_uso_fut_ccen = "";
		LET s_uso_fut_banco = "";

		--Se valida que los datos no vengan en blancos o null

		---SE inicializan las variables que se utlizan para validacion especiales
		LET v_cRespSP = "";
		LET v_sRetCodSP = "";
		LET v_secu_bandera = "0000002";
		LET v_fecha_ano = "";
		LET v_fecha_mes = "";
		LET v_fecha_dia = "";
		LET v_sValorMax = "";
		LET v_fec_40 = "";
		LET v_cRechBlo = "";
		LET cCicloFech = "S";
		LET cBancNom = "";
		LET cDiaNom = "";
		LET cAnoNom = "";
		LET cMesNom = "";
		LET cConseNom = "";
		LET cNomFecha = "";
		LET v_cuenta_sp = "";
		LET v_bancoNomb = "";
		LET v_dianombre = "";
		LET v_dFechaProce = "01-01-1900";
		
			--SET DEBUG FILE TO "/RESPALDOSNEW/depuraremesas/sp_valida_datos.out";
	        --TRACE ON;

		IF (p_cTipArch = "") OR (p_cTipArch is NULL) THEN
			LET v_cod_ret = "00601";
			return v_cod_ret,v_nivel;
		ELSE
			IF  (p_cTipArch = "S")  OR ( p_cTipArch = "E") OR ( p_cTipArch = "R")  THEN
			ELSE
				LET v_cod_ret = "00601";
				return v_cod_ret,v_nivel;
			END IF;
		END IF;

		IF (p_cNombreArc = "") OR (p_cNombreArc is NULL) THEN
			LET v_cod_ret = "00602";
			return v_cod_ret,v_nivel;
		END IF;

		IF (p_cfec_presen = "") OR (p_cfec_presen is NULL) THEN
			LET v_cod_ret = "00603";
			return v_cod_ret,v_nivel;
		ELSE
			execute PROCEDURE bdidomi:sp_valida_cadena(p_cfec_presen,'N') INTO v_cRespSP;
			IF v_cRespSP <> "00000" THEN
				LET v_cod_ret = "00603";
				return v_cod_ret,v_nivel;
			END IF;
		END IF;
		IF (p_cNumArchi	 = "") OR (p_cNumArchi	 is NULL) THEN
			LET v_cod_ret = "00618";
			return v_cod_ret,v_nivel;
		ELSE
			IF (p_cNumArchi = "10") OR (p_cNumArchi = "11") OR (p_cNumArchi = "30") OR (p_cNumArchi = "31") OR
				(p_cNumArchi = "32") OR (p_cNumArchi = "34") OR (p_cNumArchi = "36")  THEN
			ELSE
				LET v_cod_ret = "00618";
				return v_cod_ret,v_nivel;
			END IF;
		END IF;
		IF (p_cRol = "") OR (p_cRol is NULL) THEN
			LET v_cod_ret = "00619";
			return v_cod_ret,v_nivel;
		ELSE
			IF  (p_cRol = "R")  OR ( p_cRol = "P") THEN
			ELSE
				LET v_cod_ret = "00619";
				return v_cod_ret,v_nivel;
			END IF;
		END IF;
		SELECT valor INTO v_BancoCoppel from bdidomi:dom_parametros where cod_param = "05" and descripcion = 'CLAVE BANCARIA BANCOPPEL';
		--Se valida que exista el nombre de archivo y los registros en dom_cce_encabezado
		IF EXISTS (SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = p_cNombreArc AND fecha_presentacion = p_cfec_presen) THEN
			LET v_nivel = "02";
			SELECT fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio,num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco
			INTO v_fecha_prese,e_tpo_reg, e_num_secu,e_cod_oper,e_cve_ban,e_sentido,e_servicio,e_num_bloq,e_cod_divi,e_cve_rech_bl,e_modalidad,e_fut_ccen,e_fut_banco
			FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = p_cNombreArc AND fecha_presentacion = p_cfec_presen;

			--1--Validacion del tipo de registro
			IF e_tpo_reg <> "01" THEN
				LET v_cod_ret = "28";
				return v_cod_ret,v_nivel;
			END IF;
			--2--Se valida en numero de secuencia
			IF e_num_secu <> "0000001" THEN
				LET v_cod_ret = "102";
				return v_cod_ret,v_nivel;
			END IF;

			--3--Se valida el codigo de operacion
			IF NOT EXISTS(SELECT descripcion FROM bdidomi:dom_codigo_oper  WHERE cod_operacion = e_cod_oper ) THEN
				LET v_cod_ret = "125";
				return v_cod_ret,v_nivel;
			ELSE
				LET v_sPriNomb = substr(p_cNombreArc,1,1);
				IF v_sPriNomb = "S" THEN
					--LET v_bancoNomb = substr(p_cNombreArc,4,3);
					LET no_cod_oper = substr(p_cNombreArc,11,2);
				END IF;
				IF v_sPriNomb = "E" THEN
					LET no_cod_oper = substr(p_cNombreArc,14,2);
				END IF;

				
				IF p_cNumArchi <> "36" THEN ---si archivo codigo 36 continua
					IF e_cod_oper <> no_cod_oper THEN 
						LET v_cod_ret = "125";
						return v_cod_ret,v_nivel;
					END IF;
				END IF;
			END IF;

			---4--Validacion del banco pendiente(faltan parametros)
			LET v_sPriNomb = substr(p_cNombreArc,1,1);
			IF v_sPriNomb = "S" THEN
				LET v_bancoNomb = substr(p_cNombreArc,4,3);
			END IF;
			IF v_sPriNomb = "E" THEN
				LET v_bancoNomb = substr(p_cNombreArc,2,3);
			END IF;
			--se valida que el banco sea bancoppel
			IF v_bancoNomb <> v_BancoCoppel THEN
				LET v_cod_ret = "122";
				return v_cod_ret,v_nivel;
			END IF;
			--se valida que el banco del encabezado sea bancoppel
			IF v_sPriNomb = "E" THEN
				IF e_cve_ban <> v_bancoNomb  THEN
					LET v_cod_ret = "122";
					return v_cod_ret,v_nivel;
				END IF;
			END IF;

			IF p_cRol = "R" THEN
				IF NOT EXISTS(select descripcion from bdinteg:si_bancos where banco = e_cve_ban AND flg_domi_r = '1' ) THEN
					LET v_cod_ret = "122";
					return v_cod_ret,v_nivel;
				END IF;
			END IF;
			IF p_cRol = "P" THEN
				IF NOT EXISTS(select descripcion from bdinteg:si_bancos where banco = e_cve_ban AND flg_domi_p = '1' ) THEN
					LET v_cod_ret = "122";
					return v_cod_ret,v_nivel;
				END IF;
			END IF;
			--5--Validacion del sentido
			IF (e_sentido = "S") OR (e_sentido = "E") OR (e_sentido = "R") THEN
			ELSE
				LET v_cod_ret = "103";
				return v_cod_ret,v_nivel;
			END IF;

			---Validacion de la primera letra del nombre con el sentido
			LET v_sPriNomb = substr(p_cNombreArc,1,1);
			IF v_sPriNomb = "S" THEN
				IF NOT e_sentido = "S" THEN
					--Nombre no concuerda con sentido
					LET v_cod_ret = "103";
					return v_cod_ret,v_nivel;
				END IF;
			END IF;
			IF v_sPriNomb = "E" THEN
				IF NOT e_sentido = "E" THEN
					--Nombre no concuerda con sentido
					LET v_cod_ret = "103";
					return v_cod_ret,v_nivel;
				END IF;
			END IF;
			IF v_sPriNomb = "R" THEN
				IF NOT e_sentido = "R" THEN
					--Nombre no concuerda con sentido
					LET v_cod_ret = "103";
					return v_cod_ret,v_nivel;
				END IF;
			END IF;
			--6--se valida el servicio
			IF e_servicio <> "2" THEN
				LET v_cod_ret = "124";
				return v_cod_ret,v_nivel;
			END IF;
			--7---Se vaida la cadena del numero de bloque
			Execute procedure bdidomi:sp_valida_cadena(e_num_bloq,"N") INTO v_cRespSP;
			LET v_diablokNomb = substr(e_num_bloq,1,2);
			IF e_sentido = "S"  OR e_sentido = "R"  THEN
				LET v_dianombre = substr(p_cNombreArc,13,2);
			ELSE
				LET v_dianombre = substr(p_cNombreArc,5,2);
			END IF;
			--se valida que el dia del bloke sea el mismo del archivo.
			IF v_diablokNomb <> v_dianombre THEN
				LET v_cod_ret = "00620";
				return v_cod_ret,v_nivel;
			END IF;
			LET v_counBloc = LENGTH(p_cNombreArc);
			LET v_counBloc = v_counBloc - 2;
			LET v_contaBlco = substr(p_cNombreArc,v_counBloc,2);
			LET v_contaBlco = v_contaBlco - 1;
			LET v_NombrePruBlo = substr(p_cNombreArc,1,v_counBloc) ||  lpad(TRIM((v_contaBlco::integer)::char(2)),2,'0');

			IF v_cRespSP = "00000" THEN
				IF EXISTS(SELECT tpo_registro FROM bdidomi:dom_cce_encabezado WHERE nombre_arch = v_NombrePruBlo
													AND fecha_presentacion = p_cfec_presen AND servicio = e_servicio AND cve_banco = e_cve_ban
													AND e_cod_oper = e_cod_oper AND modalidad = e_modalidad and cod_divisa = e_cod_divi) THEN
					LET v_cod_ret = "105";
					return v_cod_ret,v_nivel;
				END IF;
			ELSE
				LET v_cod_ret = v_cRespSP;
				return v_cod_ret,v_nivel;
			END IF;
			--8--se valida la fecha de presentacion
			execute procedure bdidomi:sp_valida_fecha(v_fecha_prese) into v_cRespSP;
			IF v_cRespSP <> "00000" THEN
				LET v_cod_ret = "126";
				return v_cod_ret,v_nivel;
			END IF;
			LET v_cfec_presen = Substr(p_cfec_presen,5,2) || "/" || Substr(p_cfec_presen,7,2) || "/" || Substr(p_cfec_presen,1,4);
			SELECT limit 1 fecha_proceso INTO v_dFechaProce FROM  bdidomi:dom_procesos
			WHERE cve_proceso  = p_nomproceso and fecha_proceso = v_cfec_presen;
			IF (v_dFechaProce is null) THEN
				LET v_cod_ret = "126";
				return v_cod_ret,v_nivel;
			END IF;
			LET v_dFechaSp = Substr(v_fecha_prese,5,2) || "/" || Substr(v_fecha_prese,7,2) || "/" || Substr(v_fecha_prese,1,4);
			IF v_dFechaProce <> v_dFechaSp THEN
				LET v_cod_ret = "126";
				return v_cod_ret,v_nivel;
			END IF;
			--9--se valida el codigo de divisas
			IF e_cod_divi <> '01' THEN
				LET v_cod_ret = "128";
				return v_cod_ret,v_nivel;
			END IF;
			--10--se valida la causa de rechazo de bloque
			IF (p_cNumArchi = 30) OR (p_cNumArchi = 10 ) THEN
				IF e_cve_rech_bl <> "00" THEN
					LET v_cod_ret = "00621";
					return v_cod_ret,v_nivel;
				END IF;
			ELSE
				IF e_cve_rech_bl <> "00" THEN
					IF NOT EXISTS(SELECT descripcion FROM  bdidomi:dom_cat_rechazos WHERE cve_rechazo = e_cve_rech_bl) THEN
						LET v_cod_ret = "00621";
						return v_cod_ret,v_nivel;
					END IF;
				END IF;
			END IF;

			--11--se valida la modalidad
			IF e_modalidad <> "2" THEN
				LET v_cod_ret = "129";
				return v_cod_ret,v_nivel;
			END IF;
			--12--Se valida que los campos de uso futuro vengan en blanco
			LET v_cRespSP = "";
			execute PROCEDURE bdidomi:sp_valida_cadena(e_fut_ccen,'B') INTO v_cRespSP;
			IF v_cRespSP <> "00000" THEN
				LET v_cod_ret = v_cRespSP;
				return v_cod_ret,v_nivel;
			END IF;
			LET v_cRespSP = "";
			--13--Se valida que los campos de uso futuro banco vengan en blanco
			execute PROCEDURE bdidomi:sp_valida_cadena(e_fut_banco,'B') INTO v_cRespSP;
			IF v_cRespSP <> "00000" THEN
				LET v_cod_ret = v_cRespSP;
				return v_cod_ret,v_nivel;
			END IF;
			----Se valida que exista el nombre de archivo y los registros en dom_cce_detalle
			IF EXISTS (SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = p_cNombreArc AND fecha_presentacion = p_cfec_presen) THEN
				LET v_nivel = '03';
				FOREACH
					SELECT tipo_registro, num_secuencia, cod_operacion, cod_divisa, fecha_trans, banco_presentador, banco_receptor,
							importe, uso_futuro_ccen, tipo_operacion, fecha_aplica, tipo_cta_ord, num_cta_ord, nombre_ord, rfc_ord, tipo_cta_rec, num_cta_rec, nombre_rec,
							rfc_rec, ref_servicio, nombre_titular_serv, importe_iva, ref_numerica, ref_leyenda, clave_rastreo, motivo_dev, fecha_pres_ini, uso_futuro_banco,
							cve_estatus, folio_suc
					INTO 	d_tpo_reg,d_num_secu,d_cod_oper,d_cod_divi,d_fec_trans,d_ban_pres,d_ban_rece,
							d_importe,d_futuro_ccen,d_tpo_opera,d_fec_aplica,d_tpo_cta_ord,d_num_cta_ord,d_nombre_ord,d_rfc_ord,d_tpo_cta_rec,d_num_cta_rec,d_nombre_rec,
							d_rfc_rec,d_ref_serv,d_nom_tit_serv,d_imp_iva,d_ref_nume,d_ref_leyen,d_cve_rast,d_motivo_dev,d_fec_pres_ini,d_futuro_banco,
							cve_estatus,folio_suc
					FROM  bdidomi:dom_cce_detalle_paso
					WHERE nombre_arch = p_cNombreArc
					AND fecha_presentacion = p_cfec_presen
					ORDER BY num_secuencia
					
					
					--- 14--validacion del tipo de registro
					IF d_tpo_reg <> "02" THEN
						LET v_cod_ret = "28";
						return v_cod_ret,v_nivel;
					END IF;

					
					IF p_cNumArchi <> "36" THEN ---si archivo codigo 36 continua
						IF NOT v_secu_bandera = d_num_secu THEN
						--UPDATE  bdidomi:dom_cce_detalle_paso SET
							LET v_cod_ret = "29";
							return v_cod_ret,v_nivel;
						END IF;
					END IF;
					LET v_secu_bandera = v_secu_bandera + 1;
					LET v_secu_bandera =  lpad(TRIM((v_secu_bandera::integer)::char(7)),7,'0');
					--16--Se valida que el codigo de operacion sea igual al encabezado
					IF e_cod_oper <>  d_cod_oper THEN
						LET v_cod_ret = "30";
						return v_cod_ret,v_nivel;
					ELSE
						IF p_cNumArchi = 32 THEN
							IF EXISTS(SELECT tpo_registro FROM bdidomi:dom_cce_encabezado WHERE nombre_arch = p_cNombreArc
													AND fecha_presentacion = p_cfec_presen) THEN
									SELECT cve_rechazo_bl INTO v_cRechBlo FROM bdidomi:dom_cce_encabezado WHERE nombre_arch = p_cNombreArc
													AND fecha_presentacion = p_cfec_presen;
									IF 	v_cRechBlo = "00" THEN
										LET v_cod_ret = "38";
										return v_cod_ret,v_nivel;
									ELSE
										LET v_cod_ret = "41";
										return v_cod_ret,v_nivel;
									END	IF;
							END IF;
						END IF;
					END IF;
					--17--se valida que el cadigo de divisa sea igual al encabezado
					IF e_cod_divi <> d_cod_divi THEN
						LET v_cod_ret = "90";
						return v_cod_ret,v_nivel;
					END IF;
					--18--Se valida la fecha de transferencia				
					IF p_cnumarchi <> 10 THEN
						execute procedure bdidomi:sp_valida_fecha(d_fec_trans) into v_cRespSP;
						IF v_cRespSP = "00001" THEN
							LET v_cod_ret = "31";
							return v_cod_ret,v_nivel;
						END IF;
						IF v_cRespSP = "00002" THEN
							LET v_cod_ret = "32";
							return v_cod_ret,v_nivel;
						END IF;
					END IF;					


					--19--se valida que el banco sea el mismo que el del encabezado
					LET v_sPriNomb = substr(p_cNombreArc,1,1);

					IF p_cNumArchi <> "36" THEN ---si archivo codigo 36 continua
						IF v_sPriNomb = "S" THEN
							IF d_ban_pres = v_BancoCoppel THEN
								LET v_cod_ret = "34";
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
					END IF; -----------------------------------------------------
					
					IF v_sPriNomb = "E" THEN
						IF d_ban_pres <> v_BancoCoppel THEN
							LET v_cod_ret = "34";
							return v_cod_ret,v_nivel;
						END IF;
					END IF;
					IF  EXISTS(select descripcion from bdinteg:si_bancos
									where banco = d_ban_pres AND flg_domi_r =  "0"  AND flg_domi_p = "0" ) THEN
						LET v_cod_ret = "34";
						return v_cod_ret,v_nivel;
					END IF;

					---20--Validacion del banco
					IF  EXISTS(select descripcion from bdinteg:si_bancos
									where banco = d_ban_rece AND flg_domi_r = "0"  AND flg_domi_p = "0" ) THEN
						LET v_cod_ret = "36";
						return v_cod_ret,v_nivel;
					END IF;
					IF d_ban_rece = d_ban_pres THEN
						LET v_cod_ret = "67";
						return v_cod_ret,v_nivel;
					END IF;

					IF p_cNumArchi <> "36" THEN ---si archivo codigo 36 continua
						IF v_sPriNomb = "S" THEN
							IF d_ban_rece <> v_BancoCoppel THEN
								LET v_cod_ret = "36";
								return v_cod_ret,v_nivel;
							END IF;

						END IF;
					END IF;					

					IF v_sPriNomb = "E" THEN
						IF d_ban_rece = v_BancoCoppel THEN
							LET v_cod_ret = "36";
							return v_cod_ret,v_nivel;
						END IF;
					END IF;

					--21--se valida el importe d_importe
					--primero se valida que sea numerico la cadena

					execute PROCEDURE bdidomi:sp_valida_cadena(d_importe,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "37";
						return v_cod_ret,v_nivel;
					ELSE
						--si es verificacion de cuentas debe de ser 0 el valor de lo contrario tiene k ser diferente de 0
						IF (p_cNumArchi = 10) or (p_cNumArchi = 11) THEN
							LET d_importe = d_importe::integer;
							IF d_importe <> "0" THEN
								LET v_cod_ret = "37";
								return v_cod_ret,v_nivel;
							END IF;
						ELSE
							LET d_importe = d_importe::integer;
							--LET i_importe = d_importe::integer;
							IF d_importe = 0 THEN
								LET v_cod_ret = "37";
								return v_cod_ret,v_nivel;
							END IF;
							--se toma el valor maximo valor permitido
							SELECT valor INTO v_sValorMax FROM bdidomi:dom_parametros where cod_param = '10';
							LET d_importe = d_importe/100;
							LET i_importe = d_importe::integer;
							LET i_valormax = v_sValorMax::integer;
							IF i_valormax < i_importe THEN
								LET v_cod_ret = "37";
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
					END IF;
					---22--Se valida que el dato usu_futuro_ccen no contenga datos
					execute PROCEDURE bdidomi:sp_valida_cadena(d_futuro_ccen,'B') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = v_cRespSP;
						return v_cod_ret,v_nivel;
					END IF;
					--23--se validael tipo de operacion
					IF p_cnumarchi <> 10 THEN
						IF d_tpo_opera = "51" OR d_tpo_opera = "01" THEN
								  ELSE
							LET v_cod_ret = '85';
							return v_cod_ret,v_nivel;
						END IF;
					END IF;
			
					--24--Se valida la fecha de aplicacon
					execute procedure bdidomi:sp_valida_fecha(d_fec_aplica) into v_cRespSP;
					IF v_cRespSP = "00001" THEN
						LET v_cod_ret = "39";
						return v_cod_ret,v_nivel;
					END IF;
					IF v_cRespSP = "00002" THEN
						LET v_cod_ret = "68";
						return v_cod_ret,v_nivel;
					END IF;
					--25--Se valida el tipo de cuenta del ordenante
					/*IF NOT EXISTS(SELECT  descripcion  FROM bdidomi:dom_tipo_cta WHERE  tipo_cta = d_tpo_cta_ord) THEN
						LET v_cod_ret = "40";
						return v_cod_ret,v_nivel;
					END IF;*/
					--26--Se valida  el numero de cuenta del ordenante
				/*IF p_cnumarchi <> 10 THEN
					execute PROCEDURE bdidomi:sp_valida_cadena(d_num_cta_ord,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = v_cRespSP;
						return v_cod_ret,v_nivel;
					ELSE
						--Tarjeta de debito
						IF d_tpo_cta_ord = "03" THEN
							--Se valida la longitud que debe de ser de 16 caracteres
							LET cCeroTar = substr(d_num_cta_ord,5,20);
							LET cCeroTar = TRIM(cCeroTar);
							LET v_LogTarDeb = LENGTH(cCeroTar);
							IF v_LogTarDeb <> 16 THEN
							--IF cCeroTar <> "0000" THEN
								LET v_cod_ret = "97";
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
						--se valida cuadno es por cuenta clave
						IF d_tpo_cta_ord = "40" THEN
							LET  cCeroClabe = Substr(d_num_cta_ord,3,20);
							LET cCeroClabe = TRIM(cCeroClabe);
							LET v_LogTarDeb = LENGTH(cCeroClabe);
							
							--se valida que la longitud sea diferente de la establecida
							IF v_LogTarDeb <> 18 THEN
							--IF cCeroClabe <> "00" THEN
								LET v_cod_ret = "96";
								return v_cod_ret,v_nivel;
							ELSE
								--el banco de la cuenta clabe no es el mismo banco
								LET v_BancTar = substr(d_num_cta_ord,3,3);
								IF (p_cNumArchi = 11) OR (p_cNumArchi = 31) OR (p_cNumArchi = 32) OR (p_cNumArchi = 34) THEN
									IF v_BancTar <> d_ban_rece THEN
										LET v_cod_ret = "98";
										return v_cod_ret,v_nivel;
									ELSE
										--el banco no es exite
										IF NOT EXISTS(select descripcion from bdinteg:si_bancos
														where banco = v_BancTar ) THEN
											LET v_cod_ret = "97";
											return v_cod_ret,v_nivel;
										END IF;
										--se valida el digito verificador
										LET v_cuenta_sp = substr(d_num_cta_ord,3,18);
										EXECUTE PROCEDURE bdispei:sp_validadv(v_cuenta_sp) INTO v_iCodReSP, v_iDigVeSP;
										IF  (v_iCodReSP = 0)  AND (v_iDigVeSP = 1) THEN
										ELSE
											LET v_cod_ret = "88";
											return v_cod_ret,v_nivel;
										END IF;
									END IF;
								
								ELSE
									IF v_BancTar <> d_ban_pres THEN
										LET v_cod_ret = "98";
										return v_cod_ret,v_nivel;
									ELSE
										--el banco no es exite
										IF NOT EXISTS(select descripcion from bdinteg:si_bancos
														where banco = v_BancTar ) THEN
											LET v_cod_ret = "97";
											return v_cod_ret,v_nivel;
										END IF;
										--se valida el digito verificador
										LET v_cuenta_sp = substr(d_num_cta_ord,3,18);
										EXECUTE PROCEDURE bdispei:sp_validadv(v_cuenta_sp) INTO v_iCodReSP, v_iDigVeSP;
										IF  (v_iCodReSP = 0)  AND (v_iDigVeSP = 1) THEN
										ELSE
											LET v_cod_ret = "88";
											return v_cod_ret,v_nivel;
										END IF;
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;*/
					--27--se valida que el nombre no venga vacio	
					IF p_cnumarchi <> 10 THEN					
						LET v_iNombre = LENGTH(d_nombre_ord);
						IF v_iNombre = 0 THEN
							LET v_cod_ret = "74";
							return v_cod_ret,v_nivel;
						ELSE
							execute PROCEDURE bdidomi:sp_valida_cadena(d_nombre_ord,'T') INTO v_cRespSP;
							IF v_cRespSP <> "00000" THEN
								LET v_cod_ret = '74';
								return v_cod_ret,v_nivel;
							END IF;
						END IF;			
					END IF;
					--28--se valida el rfc del ordenandte	
					IF p_cnumarchi <> 10 THEN
						IF (d_rfc_ord = "") OR (d_rfc_ord is null) THEN
							LET v_cod_ret = '75';
							return v_cod_ret,v_nivel;
						END IF;
					END IF;					
						/*EXECUTE PROCEDURE "informix".sp_validarfc(d_rfc_ord,"M") INTO v_cRespSP;
						IF v_cRespSP <> "00000" THEN
							LET v_cod_ret = '75';
							return v_cod_ret,v_nivel;
						END IF;*/ 


					--29--se valida el tipo de cuenta del receptor
					IF NOT EXISTS(SELECT  descripcion  FROM bdidomi:dom_tipo_cta WHERE  tipo_cta = d_tpo_cta_rec) THEN
						LET v_cod_ret = "45";
						return v_cod_ret,v_nivel;
					END IF;

					--30--Se valida  el numero de cuenta del receptor
					execute PROCEDURE bdidomi:sp_valida_cadena(d_num_cta_rec,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = v_cRespSP;
						return v_cod_ret,v_nivel;
					ELSE
						--Tarjeta de debito
						IF d_tpo_cta_rec = "03" THEN
							--Se valida la longitud que debe de ser de 16 caracteres
							LET cCeroTar = Substr(d_num_cta_rec,5,20);
							LET cCeroTar = TRIM(cCeroTar);
							LET v_LogTarDeb = LENGTH(cCeroTar);
							
							IF v_LogTarDeb <> 16 THEN
						--	IF cCeroTar <> "0000" THEN
								LET v_cod_ret = "97";
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
						--se valida cuadno es por cuenta clave
						IF d_tpo_cta_rec = "40" THEN
							LET cCeroClabe = Substr(d_num_cta_rec,3,20);
							LET cCeroClabe= TRIM(cCeroClabe);
							LET v_LogTarDeb = LENGTH(cCeroClabe);
							--se valida que la longitud sea diferente de la establecida
							IF v_LogTarDeb <> 18 THEN
							--IF cCeroClabe <> "00" THEN
								LET v_cod_ret = "97";
								return v_cod_ret,v_nivel;
							ELSE
								--el banco de la cuenta clabe no es el mismo banco
								LET v_BancTar = substr(d_num_cta_rec,3,3);
								IF (p_cNumArchi = 11) OR (p_cNumArchi = 31) OR (p_cNumArchi = 32) OR (p_cNumArchi = 34) THEN
									IF v_BancTar <> d_ban_pres THEN
										LET v_cod_ret = "99";
										return v_cod_ret,v_nivel;
									ELSE
										--el banco no es exite
										IF NOT EXISTS(select descripcion from bdinteg:si_bancos where banco = v_BancTar) THEN
											LET v_cod_ret = "96";
											return v_cod_ret,v_nivel;
										END IF;
										--se valida el digito verificador
										LET v_cuenta_sp = substr(d_num_cta_rec,3,18);
										EXECUTE PROCEDURE bdispei:sp_validadv(v_cuenta_sp) INTO v_iCodReSP, v_iDigVeSP;
										IF  (v_iCodReSP = 0)  AND (v_iDigVeSP = 1) THEN
										ELSE
											LET v_cod_ret = "89";
											return v_cod_ret,v_nivel;
										END IF;
									END IF;
								ELSE
									IF v_BancTar <> d_ban_rece THEN
										LET v_cod_ret = "99";
										return v_cod_ret,v_nivel;
									ELSE
										--el banco no es exite
										IF NOT EXISTS(select descripcion from bdinteg:si_bancos where banco = v_BancTar) THEN
											LET v_cod_ret = "96";
											return v_cod_ret,v_nivel;
										END IF;
										--se valida el digito verificador
										LET v_cuenta_sp = substr(d_num_cta_rec,3,18);
										EXECUTE PROCEDURE bdispei:sp_validadv(v_cuenta_sp) INTO v_iCodReSP, v_iDigVeSP;
										IF  (v_iCodReSP = 0)  AND (v_iDigVeSP = 1) THEN
										ELSE
											LET v_cod_ret = "89";
											return v_cod_ret,v_nivel;
										END IF;
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
					--31--se valida que el nombredel receptor no venga vacio
-- SE QUITA VALIDACION POR SER CAMPO OPCIONAL . JGP. 18/02/2014
/*					LET v_iNombre = LENGTH(d_nombre_rec);
					IF v_iNombre = 0 THEN
						LET v_cod_ret = "77";
						return v_cod_ret,v_nivel;
					ELSE
						execute PROCEDURE bdidomi:sp_valida_cadena(d_nombre_rec,'T') INTO v_cRespSP;
						IF v_cRespSP <> "00000" THEN
							LET v_cod_ret = '77';
							return v_cod_ret,v_nivel;
						END IF;
					END IF; */
					--32--se valida el rfc del receptor
-- SE QUITA VALIDACION POR SER CAMPO OPCIONAL . JGP. 30/10/2009
/*					IF (d_rfc_rec = "") OR  (d_rfc_rec is null) THEN
						LET v_cod_ret = '78';
						return v_cod_ret,v_nivel;
					END IF; */
					/*
					EXECUTE PROCEDURE "informix".sp_validarfc(d_rfc_rec,"F") INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = '78';
						return v_cod_ret,v_nivel;
					END IF;*/

					--33--se valida la referencia del servicio con el emisor ,
					IF p_cnumarchi <> 10 THEN					
						LET v_iNombre = LENGTH(d_ref_serv);
						IF v_iNombre = 0 THEN
							LET v_cod_ret = "79";
							return v_cod_ret,v_nivel;
						ELSE
							execute PROCEDURE bdidomi:sp_valida_cadena(d_ref_serv,'T') INTO v_cRespSP;
							IF v_cRespSP <> "00000" THEN
								LET v_cod_ret = '79';
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
					END IF;					

-- SE QUITA VALIDACION POR SER CAMPO OPCIONAL . JGP. 18/02/2014
/*						--34--se valida el nombre del titular
					LET v_iNombre = LENGTH(d_nom_tit_serv);
					IF v_iNombre = 0 THEN
						LET v_cod_ret = "80";
						return v_cod_ret,v_nivel;
					ELSE
						execute PROCEDURE bdidomi:sp_valida_cadena(d_nom_tit_serv,'T') INTO v_cRespSP;
						IF v_cRespSP <> "00000" THEN
							LET v_cod_ret = '80';
							return v_cod_ret,v_nivel;
						END IF;
					END IF; */
					--35--SE VALIDA EL IMPORTE DEL IVA DE LA OPERACION					
					/*execute PROCEDURE bdidomi:sp_valida_cadena(d_imp_iva,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = '81';
						return v_cod_ret,v_nivel;
					ELSE
						if d_imp_iva < "0" then
							LET v_cod_ret = '81';
							return v_cod_ret,v_nivel;
						end if;
					END IF;*/
				
					--36--SE VALIDA LA REFERENCIA NUMERICA DEL ORDENATNE
					IF p_cnumarchi <> 10 THEN
						execute PROCEDURE bdidomi:sp_valida_cadena(d_ref_nume,'N') INTO v_cRespSP;
						IF v_cRespSP <> "00000" THEN
							LET v_cod_ret = '48';
							return v_cod_ret,v_nivel;
							--se kita la sigueinte validacion por peticion en el correo del 28082009 por emdio de jaime gonzales
						/*ELSE
							LET v_iBanNume =  d_ref_nume + 1;
							IF v_iBanNume = 1 THEN
								LET v_cod_ret = '48';
								return v_cod_ret,v_nivel;
							END IF;*/
						END IF;
					END IF;
					--37--se valida la referencia leyenda del ordenante
					IF p_cnumarchi <> 10 THEN
						LET v_iNombre = LENGTH(d_ref_leyen);
						IF v_iNombre = 0 THEN
							LET v_cod_ret = "49";
							return v_cod_ret,v_nivel;
						ELSE
							execute PROCEDURE bdidomi:sp_valida_cadena(d_ref_leyen,'T') INTO v_cRespSP;
							IF v_cRespSP <> "00000" THEN
								LET v_cod_ret = '49';
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
					END IF;
					--38--se valida la clave de rastreo
					LET v_iNombre = LENGTH(d_cve_rast);
					IF v_iNombre = 0 THEN
						LET v_cod_ret = "50";
						return v_cod_ret,v_nivel;
					ELSE
						execute PROCEDURE bdidomi:sp_valida_cadena(d_cve_rast,'T') INTO v_cRespSP;
						IF v_cRespSP <> "00000" THEN
							LET v_cod_ret = '50';
							return v_cod_ret,v_nivel;
						END IF;
					END IF;
					--39--se valida el motivo de devolucion
					--se valida que sea numerico
					execute PROCEDURE bdidomi:sp_valida_cadena(d_motivo_dev,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = '51';
						return v_cod_ret,v_nivel;
					ELSE
						--se valida que para los siguietnes numeros de archivos sea diferente de 00
						IF (p_cNumArchi = 34)THEN
							IF d_motivo_dev <> "13" THEN
								LET v_cod_ret = '51';
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
						IF (p_cNumArchi = 10) OR (p_cNumArchi = 30) 
							/*se kita esta vlidacion por pedido de jaime gonzales el 28082009 OR (p_cNumArchi = 32)   OR (p_cNumArchi = 11)*/ THEN
							IF d_motivo_dev <> "00" THEN
								LET v_cod_ret = '51';
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
						IF (p_cNumArchi = 11) THEN
							IF d_motivo_dev = "00" THEN
								LET v_cod_ret = '51';
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
						--se valida que no contengan 00
						IF (p_cNumArchi = 31) THEN
							IF d_motivo_dev =  "00" THEN
								LET v_cod_ret = '51';
								return v_cod_ret,v_nivel;
							ELSE
								--se valida que exita en el cataloga de devolucion
								IF NOT EXISTS(select descripcion  from bdidomi:dom_Cat_devoluciones where motivo_dev = d_motivo_dev) THEN
									LET v_cod_ret = '51';
									return v_cod_ret,v_nivel;
								END IF;
							END IF;
						END IF;
					END IF
					--40--se valida la fecha de presentacion inicial  v_fec_40, d_fec_pres_ini
					--se valida que sea numerico
					execute PROCEDURE bdidomi:sp_valida_cadena(d_fec_pres_ini,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = '52';
						return v_cod_ret,v_nivel;
					ELSE
						execute procedure bdidomi:sp_valida_fecha(d_fec_pres_ini) into v_cRespSP;
						IF v_cRespSP = "00001" THEN
							LET v_cod_ret = "52";
							return v_cod_ret,v_nivel;
						END IF;
						IF v_cRespSP = "00002" THEN
							LET v_cod_ret = "70";
							return v_cod_ret,v_nivel;
						END IF;
						IF (p_cNumArchi = 31) OR  (p_cNumArchi = 32) THEN
							SELECT fecha_hoy INTO dFechaSis FROM bdicheq:sc_fechas;
							--LET dFechaSis = dFechaSis - 1;
							WHILE cCicloFech = "S"
								LET dFechaSis = dFechaSis - 1;
/*
		--	20110322 - I
		Se llama al SP bdinteg:'sp_valfecha_banca' para que valide dias feriados bancarios.
								EXECUTE FUNCTION bdinteg:splvalfecha('001', dFechaSis, 0 ) INTO v_sRetCodSP,v_dFechaReSp;
		--	20110322 - F
*/
								EXECUTE FUNCTION bdinteg:sp_valfecha_banca('001', dFechaSis, 0 ) INTO v_sRetCodSP,v_dFechaReSp;
								IF dFechaSis = v_dFechaReSp THEN
									LET cCicloFech = "N";
								END IF;
							END  WHILE;
							IF p_cTipArch = "S" THEN
								LET cBancNom = substr(p_cNombreArc,4,3); -- 137
								LET cDiaNom = LPAD(DAY(dFechaSis),2,'0'); -- 22
								LET cAnoNom = YEAR(dFechaSis); -- 2011
								LET cMesNom  =  LPAD(month(dFechaSis),2,'0'); --03
								LET cConseNom = substr(p_cNombreArc,15,2);
								LET cConseNom = (99 - cConseNom);
								LET cConseNom = lpad(TRIM((cConseNom::integer)::char(2)),2,'0');
								LET v_f_ENC = YEAR(dFechaSis) || LPAD(month(dFechaSis),2,'0') || LPAD(DAY(dFechaSis),2,'0');
								LET cNomFecha = "E" || cBancNom || cDiaNom || cMesNom || cAnoNom || "." || "30" || cConseNom;
								IF NOT EXISTS (SELECT tpo_registro FROM bdidomi:dom_cce_encabezado WHERE nombre_arch = cNomFecha
													AND fecha_presentacion = v_f_ENC) THEN

									LET v_cod_ret = "71";
									return v_cod_ret,v_nivel;
								END IF;
							END IF;
						END IF;
						IF (p_cNumArchi = 30) THEN
							IF p_cfec_presen <> d_fec_pres_ini THEN
								LET v_cod_ret = "71";
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
					END IF;
					--se vladia d_futuro_banco
					--41--se valida la referencia leyenda del ordenante
					execute PROCEDURE bdidomi:sp_valida_cadena(d_futuro_banco,'B') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = v_cRespSP;
						return v_cod_ret,v_nivel;
					END IF;
					LET cCicloFech = "S";
				END FOREACH;
				----Se valida que exista el nombre de archivo y los registros en dom_cce_sumario
				IF EXISTS (SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = p_cNombreArc AND fecha_presentacion = p_cfec_presen) THEN
					LET v_nivel = "04";
					SELECT  tipo_registro, num_secuencia, cod_operacion, num_bloque, num_operaciones, imp_operaciones,
							uso_futuro_ccen, uso_futuro_banco
					INTO 	s_tpo_reg,s_num_secu,s_cod_oper,s_num_bloq,s_num_oper,s_imp_oper,
							s_uso_fut_ccen,s_uso_fut_banco
					FROM bdidomi:dom_cce_sumario_paso
					WHERE nombre_arch = p_cNombreArc
					AND fecha_presentacion = p_cfec_presen;
					--42--se valida que el tipo de regitro sea 09
					IF s_tpo_reg <> "09" THEN
						LET v_cod_ret = "28";
						return v_cod_ret,v_nivel;
					END IF;
					
					--15--Validacion del numero de secuencia
					SELECT MAX(num_secuencia) INTO v_secu_max FROM   bdidomi:dom_cce_detalle_paso
					WHERE nombre_arch = p_cNombreArc AND fecha_presentacion = p_cfec_presen;
					
					--43--se valida que concuerde el numero de secuencia con el consecutivo
					LET v_secu_max = v_secu_max + 1;
					LET v_secu_max =  lpad(TRIM((v_secu_max::integer)::char(7)),7,'0');
					
					IF p_cNumArchi <> "36" THEN ---si archivo codigo 36 continua
						IF v_secu_max <> s_num_secu THEN
							LET v_cod_ret = "108";
							return v_cod_ret,v_nivel;
						END IF;
					END IF;						
					--44--se valida que los codigos de operacion sean iguales
					IF s_cod_oper <> e_cod_oper THEN
						LET v_cod_ret = "125";
						return v_cod_ret,v_nivel;
					END IF;
					--45--se valida que el numero de bloque sea igual al encabezado
					IF s_num_bloq <> e_num_bloq THEN
						LET v_cod_ret = "131";
						return v_cod_ret,v_nivel;
					END IF;
					SELECT COUNT(nombre_arch) INTO v_iCont_blo
					FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = p_cNombreArc AND fecha_presentacion = p_cfec_presen;
					--46--se valida que el numero total de operaciones en el bloque es el numero de operaciones
					execute PROCEDURE bdidomi:sp_valida_cadena(s_num_oper,'N') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = "109";
						return v_cod_ret,v_nivel;
					END IF;
					IF (v_iCont_blo <> (s_num_oper::integer)) THEN
						LET v_cod_ret = "109";
						return v_cod_ret,v_nivel;
					END IF;
					--47--se valida que el importe total de operacioens sea menor de 18 digitos y corresponda a la sumatoria de lios importes del bloque de detalle
					IF p_cnumarchi <> 10 THEN					
						SELECT sum(importe::BIGINT)  INTO v_SumOper
						FROM bdidomi:dom_cce_detalle_paso  WHERE nombre_arch = p_cNombreArc AND fecha_presentacion = p_cfec_presen;
						execute PROCEDURE bdidomi:sp_valida_cadena(s_imp_oper,'N') INTO v_cRespSP;
						IF v_cRespSP <> "00000" THEN
							LET v_cod_ret = "110";
							return v_cod_ret,v_nivel;
						END IF;
						IF(LENGTH(v_SumOper) > 18 )THEN
							LET v_cod_ret = "110";
							return v_cod_ret,v_nivel;
						ELSE
							IF v_SumOper <> (s_imp_oper::BIGINT) THEN
								LET v_cod_ret = "110";
								return v_cod_ret,v_nivel;
							END IF;
						END IF;
					END IF;					
					--48--se valida que el campo uso futuro CCEN no contenga caracteres
					execute PROCEDURE bdidomi:sp_valida_cadena(s_uso_fut_ccen,'B') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						LET v_cod_ret = v_cRespSP;
						return v_cod_ret,v_nivel;
					END IF;
					--49--se valida que el campo uso futuro BANCO no contenga caracteres
					execute PROCEDURE bdidomi:sp_valida_cadena(s_uso_fut_banco,'B') INTO v_cRespSP;
					IF v_cRespSP <> "00000" THEN
						--IF p_cNumArchi <> 30 THEN
						--	LET v_cod_ret = '00622';
						--	return v_cod_ret,v_nivel;
						--ELSE
							LET v_contusoba = length(s_uso_fut_banco);
							IF v_contusoba >= 3 then
								WHILE (v_ciclo < v_contusoba)
									LET v_ini = 1;
									LET v_bancorev = TRIM(substr(s_uso_fut_banco,v_ini,3));
									execute PROCEDURE bdidomi:sp_valida_cadena(v_bancorev,'N') INTO v_cRespSP;
									IF v_cRespSP <> "00000" THEN
										LET v_cod_ret = '00622';
										return v_cod_ret,v_nivel;
									END IF;
									LET v_ini = v_ini + 3;
									IF v_ini < v_contusoba THEN
										LET v_bancComa = substr(s_uso_fut_banco,v_ini,1);
										IF v_bancComa <> "," THEN
											LET v_cod_ret = '00622';
											return v_cod_ret,v_nivel;
										END IF;
									END IF;
									LET v_ini = v_ini + 1;
									LET v_ciclo = v_ciclo + 4;
								END WHILE;
							ELSE
								LET v_cod_ret = '00622';
								return v_cod_ret,v_nivel;
							END IF;
						--END IF;
					END IF;
				ELSE
					LET v_cod_ret = "99006";
					return v_cod_ret,v_nivel;
				END IF;
			ELSE
				LET v_cod_ret = "99005";
				return v_cod_ret,v_nivel;
			END IF;
		ELSE
			LET v_cod_ret = "99004";
			return v_cod_ret,v_nivel;
		END IF;
			LET v_cod_ret = "00000";
			LET v_nivel = "00";
			return v_cod_ret,v_nivel;
	END;
END PROCEDURE ;