Create procedure "informix".sp_domi_archcopia(p_nombreArc Char(20),pCodigo CHAR(2))
	RETURNING CHAR(5),Char(100); --Codigo de retorno
	--declaracion de variables generales
	DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
	DEFINE v_f_dia				CHAR(2);
	DEFINE v_f_ano				CHAR(4);
	DEFINE v_f_mes				CHAR(2);
	DEFINE v_ruta				CHAR(100);
	DEFINE v_fecha_hoy			DATE;
	DEFINE v_codSp 				CHAR(5);
	DEFINE v_sMensaje			CHAR(100);
	DEFINE v_sFechAplica		DATE;
	--declaracion de variables  del nombre entrante
	DEFINE v_n_Sentido 			CHAR(1);
	DEFINE v_n_banco 			CHAR(3);
	DEFINE v_n_dia	 			CHAR(2);
	DEFINE v_n_mes	 			CHAR(2);
	DEFINE v_n_ano	 			CHAR(4);
	DEFINE v_n_punto 			CHAR(1);
	DEFINE v_n_codigo			CHAR(2);
	DEFINE v_n_consec 			CHAR(2);
	--declaracion de variables  del nombre nuevo copia
	DEFINE v_c_Sentido 			CHAR(1);
	DEFINE v_c_banco 			CHAR(3);
	DEFINE v_c_dia	 			CHAR(2);
	DEFINE v_c_mes	 			CHAR(2);
	DEFINE v_c_ano	 			CHAR(4);
	DEFINE v_c_punto 			CHAR(1);
	DEFINE v_c_codigo			CHAR(2);
	DEFINE v_c_consec 			CHAR(2);
	DEFINE v_c_nombreArc 		Char(20);

	---- VARIABLES ENCABEZADO -----
	DEFINE cNombre_archE CHAR(20);
	DEFINE cFecha_presentacionE CHAR(8);
	DEFINE cTpo_registro CHAR(2);
	DEFINE cNum_secuenciaE CHAR(7);
	DEFINE cCod_operacionE CHAR(2);
	DEFINE cCve_banco CHAR(3);
	DEFINE cSentido CHAR(1);
	DEFINE cServicio CHAR(1);
	DEFINE cNum_bloque CHAR(7);
	DEFINE cCod_divisaE CHAR(2);
	DEFINE cCve_rechazo_bl CHAR(2);
	DEFINE cModalidad CHAR(1);
	DEFINE cUso_futuro_ccenE CHAR(41);
	DEFINE cUso_futuro_bancoE CHAR(345);
	DEFINE cUser_insertE CHAR(8);
	DEFINE dFecha_insertE date;

	---- VARIABLES DETALLE -----
	DEFINE cNombre_archD CHAR(20);
	DEFINE cFecha_presentacionD CHAR(8);
	DEFINE cTipo_registro CHAR(2);
	DEFINE cNum_secuenciaD CHAR(7);
	DEFINE cCod_operacionD CHAR(2);
	DEFINE cCod_divisaD CHAR(2);
	DEFINE cFecha_trans CHAR(8);
	DEFINE cBanco_presentador CHAR(3);
	DEFINE cBanco_receptor CHAR(3);
	DEFINE cImporte CHAR(15);
	DEFINE cUso_futuro_ccenD CHAR(16);
	DEFINE cTipo_operacion CHAR(2);
	DEFINE cFecha_aplica CHAR(8);
	DEFINE cTipo_cta_ord CHAR(2);
	DEFINE cNum_cta_ord CHAR(20);
	DEFINE cNombre_ord CHAR(40);
	DEFINE cRfc_ord CHAR(18);
	DEFINE cTipo_cta_rec CHAR(2);
	DEFINE cNum_cta_rec CHAR(20);
	DEFINE cNombre_rec CHAR(10);
	DEFINE cRfc_rec CHAR(18);
	DEFINE cRef_servicio CHAR(40);
	DEFINE cNombre_titular_serv CHAR(40);
	DEFINE cImporte_iva CHAR(15);
	DEFINE cRef_numerica CHAR(7);
	DEFINE cRef_leyenda CHAR(40);
	DEFINE cClave_rastreo CHAR(30);
	DEFINE cMotivo_dev CHAR(2);
	DEFINE cFecha_pres_ini CHAR(8);
	DEFINE cUsu_futuro_bancoD CHAR(12);
	DEFINE cCve_estatus CHAR(2);
	DEFINE cFolio_suc CHAR(16);
	DEFINE cUser_insertD CHAR(8);
	DEFINE dFecha_insertD DATE;

	---- VARIABLES SUMARIO -----
	DEFINE cNombre_archS CHAR(20);
	DEFINE cFecha_presentacionS CHAR(8);
	DEFINE cTipo_registroS CHAR(2);
	DEFINE cNum_secuenciaS CHAR(7);
	DEFINE cCod_operacionS CHAR(2);
	DEFINE cNum_bloqueS CHAR(7);
	DEFINE cNum_operaciones CHAR(7);
	DEFINE cImp_operaciones CHAR(18);
	DEFINE cUso_futuro_ccenS CHAR(40);
	DEFINE cUso_futuro_bancoS CHAR(339);
	DEFINE cUser_insertS CHAR(8);
	DEFINE dFecha_insertS DATE;

	DEFINE cCve_status CHAR(2);
	DEFINE iTot_registros INTEGER;
	DEFINE iContadorfilas INTEGER;
	DEFINE cCiclo CHAR(1);
	--DEFINE cContaDele Integer;
	DEFINE cDeleMax integer;
	DEFINE cDeleMin integer;
	DEFINE iInicio	integer;
	DEFINE iFin	integer;
	DEFINE dFechaSis DATE;
	DEFINE iRangoFin integer;
	DEFINE iFilas integer;
	DEFINE cCicloDele CHAR(1);
	DEFINE cNivel char(1);
	DEFINE cErrorNiv	CHAR(1);

	--inicializacion de variables generales
	LET v_cod_ret = "";
	LET v_ruta = "";
	LET v_f_dia = "";
	LET v_f_mes = "";
	LET v_f_ano = "";
	LET v_c_nombreArc = "";
	----inicilizacion de variables  del nombre entrante
	LET v_n_Sentido	= "";
	LET v_n_banco = "";
	LET v_n_dia = "";
	LET v_n_mes = "";
	LET v_n_ano	= "";
	LET v_n_punto = "";
	LET v_n_codigo = "";
	LET v_n_consec = "";
	--declaracion de variables  del nombre nuevo copia
	LET v_c_Sentido	= "";
	LET v_c_banco = "";
	LET v_c_dia = "";
	LET v_c_mes = "";
	LET v_c_ano	= "";
	LET v_c_punto = "";
	LET v_c_codigo = "";
	LET v_c_consec = "";
	LET v_c_nombreArc = "";


	----INICIALIZAR  VARIABLES ENCABEZADO -----
	LET cNombre_archE ='';
	LET cFecha_presentacionE='';
	LET cTpo_registro ='';
	LET cNum_secuenciaE ='';
	LET cCod_operacionE ='';
	LET cCve_banco ='';
	LET cSentido ='';
	LET cServicio ='';
	LET cNum_bloque ='';
	LET cCod_divisaE ='';
	LET cCve_rechazo_bl ='';
	LET cModalidad ='';
	LET cUso_futuro_ccenE ='';
	LET cUso_futuro_bancoE ='';
	LET cUser_insertE ='';
	LET dFecha_insertE ='';

	---INICIALIZAR VARIABLES DETALLE
	LET cNombre_archD ='';
	LET cFecha_presentacionD ='';
	LET cTipo_registro ='';
	LET cNum_secuenciaD ='';
	LET cCod_operacionD ='';
	LET cCod_divisaD ='';
	LET cFecha_trans ='';
	LET cBanco_presentador ='';
	LET cBanco_receptor ='';
	LET cImporte ='';
	LET cUso_futuro_ccenD ='';
	LET cTipo_operacion ='';
	LET cFecha_aplica ='';
	LET cTipo_cta_ord ='';
	LET cNum_cta_ord ='';
	LET cNombre_ord ='';
	LET cRfc_ord ='';
	LET cTipo_cta_rec ='';
	LET cNum_cta_rec ='';
	LET cNombre_rec ='';
	LET cRfc_rec ='';
	LET cRef_servicio ='';
	LET cNombre_titular_serv ='';
	LET cImporte_iva ='';
	LET cRef_numerica ='';
	LET cRef_leyenda ='';
	LET cClave_rastreo ='';
	LET cMotivo_dev ='';
	LET cFecha_pres_ini ='';
	LET cUsu_futuro_bancoD ='';
	LET cCve_estatus ='';
	LET cFolio_suc ='';
	LET cUser_insertD ='';
	LET dFecha_insertD ='';

	----INICIALIZAR VARIABLES SUMARIO -----
	LET cNombre_archS='';
	LET cFecha_presentacionS ='';
	LET cTipo_registroS ='';
	LET cNum_secuenciaS ='';
	LET cCod_operacionS ='';
	LET cNum_bloqueS ='';
	LET cNum_operaciones ='';
	LET cImp_operaciones ='';
	LET cUso_futuro_ccenS ='';
	LET cUso_futuro_bancoS ='';
	LET cUser_insertS ='';
	--LET dFecha_insertS ='';


	--SET DEBUG FILE TO "/tmp/sp_domi_archcopia.out";
	--TRACE ON;
	BEGIN
		ON EXCEPTION
	        SET iSqlErr
	        IF iSqlErr <> 0 THEN
				--SE BORRA EL ARCHIVO QUE SE INSERTO
				DELETE  bdidomi:Dom_cce_archivos WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionE;
				--SE BORRA LAS TEMPORALES (DE PASO)
				DELETE  bdidomi:Dom_cce_encabezado_paso WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionE;
				DELETE  bdidomi:dom_cce_detalle_paso WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionD;
				DELETE  bdidomi:Dom_cce_sumario_paso WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionS;
				LET v_c_nombreArc = "ERROR DE INFORMIX";
	            LET v_cod_ret = iSqlErr;
	        END IF;

			RETURN v_cod_ret,v_c_nombreArc;
		END EXCEPTION;

		---Se toma la ruta donde va a caer el archivo
		SELECT Valor INTO v_ruta FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01';
		LET v_ruta = TRIM(v_ruta);

		--SE valida la longitud del archivo
		IF LENGTH(trim(p_nombreArc)) <> 17 THEN	--- VALIDA LA LONGITUD DEL NOMBRE
			LET v_sMensaje = "NOMBRE DEL ARCHIVO INVALIDO";
			LET v_cod_ret = "00001";
			RETURN v_cod_ret,v_sMensaje;
		END IF;
		--Se toma la fecha
		SELECT LIMIT 1 Fecha_Hoy INTO v_fecha_hoy FROM BdiCheq:Sc_Fechas;
		--Se valida la fecha del archivo con la fecha de hoy
		LET v_f_dia =  LPAD (DAY(v_fecha_hoy), 2, '0');
		LET v_f_mes = LPAD (MONTH(v_fecha_hoy), 2, '0');
		LET v_f_ano = LPAD (YEAR(v_fecha_hoy), 4, '0');
		--se toman las variables del archivo
		LET v_n_dia = substr(p_nombreArc,5,2);
		LET v_n_mes = substr(p_nombreArc,7,2);
		LET v_n_ano	= substr(p_nombreArc,9,4);

		--Realiza la validacion que el archivo sea del mismo dia
		IF (v_f_dia = v_n_dia) AND (v_n_mes = v_f_mes) AND (v_n_ano = v_f_ano) THEN
		ELSE
			LET v_cod_ret = "00002";
			LET v_sMensaje = "LA FECHA DEL ARCHIVO NO ES DEL DIA DE HOY";
			RETURN v_cod_ret,v_sMensaje;
		END IF;
		--Se valida la estructura del nombre
		LET v_n_Sentido	= substr(p_nombreArc,1,2);
		LET v_n_banco = substr(p_nombreArc,2,3);
		LET v_n_punto = substr(p_nombreArc,13,1);
		LET v_n_codigo = substr(p_nombreArc,14,2);
		LET v_n_consec = substr(p_nombreArc,16,2);
		--se valida que el sentido sea E
		IF v_n_Sentido <> "E" THEN
			LET v_sMensaje = "EL SENTIDO NO ES EL CORRECTO";
			LET v_cod_ret = "00003";
			RETURN v_cod_ret,v_sMensaje;
		END IF;
		--se valida que el banco sea bancoppel
		IF v_n_banco <> "137" THEN
			LET v_sMensaje = "BANCO NO ES BANCOPPEL";
			LET v_cod_ret = "00004";
			RETURN v_cod_ret,v_sMensaje;
		END IF;
		--se valida el .
		IF v_n_punto <> "." THEN
			LET v_sMensaje = "PUNTO INVALIDO";
			LET v_cod_ret = "00005";
			RETURN v_cod_ret,v_sMensaje;
		END IF;
		--se valida que el codigo de operacion sea permitido
		IF (v_n_codigo = "30") OR (v_n_codigo = "10")  OR (v_n_codigo = "34") THEN
		ELSE
			LET v_sMensaje = "CODIGO DE OPERACION INVALIDO";
			LET v_cod_ret = "00006";
			RETURN v_cod_ret,v_sMensaje;
		END IF;
		--se valida el consecutivo
		IF (v_n_consec >= "01") OR (v_n_consec <= "99") THEN
		ELSE
			LET v_sMensaje = "CONSECUTIVO INVALIDO";
			LET v_cod_ret = "00006";
			RETURN v_cod_ret,v_sMensaje;
		END IF;
		--Se inicializan las varibles del nombre nuevo
		LET v_c_Sentido	= v_n_Sentido;
		LET v_c_banco = v_n_banco;
		LET v_c_dia = v_n_dia;
		LET v_c_mes = v_n_mes;
		LET v_c_ano	= v_n_ano;
		LET v_c_punto = v_n_punto;
		LET v_c_codigo = v_n_codigo;
		LET v_n_consec = v_n_consec + 1;
		LET v_c_consec =  lpad(TRIM((v_n_consec::integer)::char(2)),2,'0');
		--LET v_c_consec = LPAD ((v_n_consec + 1), 2, '0');

		LET v_c_nombreArc = v_n_Sentido || v_n_banco || v_n_dia || v_n_mes || v_n_ano || v_n_punto || v_n_codigo || v_c_consec;

		--se valida que exita el archivo en la tabla de archivos
		IF EXISTS(select fecha_presentacion from bdidomi:dom_cce_encabezado where nombre_arch = p_nombreArc) THEN
			--SE valida que el archivo copia no exista en las tablas temporales
			IF NOT EXISTS(select fecha_presentacion from bdidomi:dom_cce_encabezado where nombre_arch = v_c_nombreArc) THEN
				--Se toman los datos de la tabla de archivos
				SELECT fecha_presentacion,fecha_aplicacion,cve_status,tot_registros ,user_insert,fecha_insert
				INTO cFecha_presentacionE,v_sFechAplica,cCve_status,iTot_registros,cUser_insertE,dFecha_insertE
				FROM bdidomi:Dom_cce_archivos
				WHERE nombre_arch = p_nombreArc;

				--insertar en las dom_cce_archivos
				INSERT INTO bdidomi:Dom_cce_archivos(nombre_arch,fecha_presentacion,fecha_aplicacion, cve_status,tot_registros ,user_insert ,fecha_insert )
				VALUES(v_c_nombreArc,cFecha_presentacionE,v_sFechAplica,cCve_status, iTot_registros,cUser_insertE,dFecha_insertE);

				--SE toman lso datos del registro original de la tabla de encabezado
				SELECT   Nombre_arch, Fecha_presentacion, Tpo_registro, Num_secuencia, Cod_operacion, Cve_banco, Sentido, Servicio, Num_bloque,
					Cod_divisa, Cve_rechazo_bl, Modalidad, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert
				INTO    cNombre_archE, cFecha_presentacionE, cTpo_registro, cNum_secuenciaE, cCod_operacionE, cCve_banco, cSentido, cServicio, cNum_bloque,
					cCod_divisaE, cCve_rechazo_bl, cModalidad, cUso_futuro_ccenE, cUso_futuro_bancoE, cUser_insertE, dFecha_insertE
				FROM bdidomi:Dom_cce_encabezado WHERE nombre_arch = p_nombreArc;

				--se insertan el nuevo registro
				INSERT INTO bdidomi:Dom_cce_encabezado_paso( Nombre_arch, Fecha_presentacion, Tpo_registro, Num_secuencia, Cod_operacion, Cve_banco, Sentido, Servicio,
				        Num_bloque, Cod_divisa, Cve_rechazo_bl, Modalidad, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert)
				Values( v_c_nombreArc, cFecha_presentacionE, cTpo_registro, cNum_secuenciaE, cCod_operacionE, cCve_banco, cSentido, cServicio, cNum_bloque,
					cCod_divisaE, cCve_rechazo_bl, cModalidad, cUso_futuro_ccenE, cUso_futuro_bancoE, cUser_insertE, dFecha_insertE);

				--Se toman lso datos de la tabla de detalle
				FOREACH WITH HOLD
					SELECT   Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Cod_divisa,
						Fecha_trans, Banco_presentador, Banco_receptor, Importe, Uso_futuro_ccen, Tipo_operacion, Fecha_aplica, Tipo_cta_ord,
						Num_cta_ord, Nombre_ord, Rfc_ord, Tipo_cta_rec, Num_cta_rec, Nombre_rec, Rfc_rec, Ref_servicio, Nombre_titular_serv,
						Importe_iva, Ref_numerica, Ref_leyenda, Clave_rastreo, Motivo_dev, Fecha_pres_ini, Uso_futuro_banco, Cve_estatus,
						Folio_suc, User_insert, Fecha_insert
					INTO    cNombre_archD, cFecha_presentacionD, cTipo_registro, cNum_secuenciaD, cCod_operacionD, cCod_divisaD,
						cFecha_trans, cBanco_presentador, cBanco_receptor, cImporte, cUso_futuro_ccenD, cTipo_operacion, cFecha_aplica, cTipo_cta_ord,
						cNum_cta_ord, cNombre_ord, cRfc_ord, cTipo_cta_rec, cNum_cta_rec, cNombre_rec, cRfc_rec, cRef_servicio, cNombre_titular_serv,
						cImporte_iva, cRef_numerica, cRef_leyenda, cClave_rastreo, cMotivo_dev, cFecha_pres_ini, cUsu_futuro_bancoD, cCve_estatus,
						cFolio_suc, cUser_insertD, dFecha_insertD
					FROM bdidomi:Dom_cce_detalle WHERE nombre_arch = p_nombreArc

					---Insert a la tabla Detalle
					INSERT INTO bdidomi:dom_cce_detalle_paso(Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion,
									Cod_divisa, Fecha_trans, Banco_presentador, Banco_receptor, Importe, Uso_futuro_ccen,
									Tipo_operacion, Fecha_aplica, Tipo_cta_ord, Num_cta_ord, Nombre_ord, Rfc_ord, Tipo_cta_rec,
									Num_cta_rec, Nombre_rec, Rfc_rec, Ref_servicio, Nombre_titular_serv, Importe_iva, Ref_numerica,
									Ref_leyenda, Clave_rastreo, Motivo_dev, Fecha_pres_ini, Uso_futuro_banco, Cve_estatus, Folio_suc,
									User_insert, Fecha_insert)
					Values (v_c_nombreArc, cFecha_presentacionD, cTipo_registro, cNum_secuenciaD, cCod_operacionD, cCod_divisaD,
						cFecha_trans, cBanco_presentador, cBanco_receptor, cImporte, cUso_futuro_ccenD, cTipo_operacion, cFecha_aplica,
						cTipo_cta_ord,cNum_cta_ord, cNombre_ord, cRfc_ord, cTipo_cta_rec, cNum_cta_rec, cNombre_rec, cRfc_rec,
						cRef_servicio, cNombre_titular_serv,cImporte_iva, cRef_numerica, cRef_leyenda, cClave_rastreo, cMotivo_dev,
						cFecha_pres_ini, cUsu_futuro_bancoD, cCve_estatus, cFolio_suc, cUser_insertD, dFecha_insertD);
				END FOREACH;

				--Se toman los dos de la tabla de sumario
				SELECT Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Num_bloque, Num_operaciones,
					   Imp_operaciones, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert
				INTO   cNombre_archS, cFecha_presentacionS, cTipo_registroS, cNum_secuenciaS, cCod_operacionS, cNum_bloqueS, cNum_operaciones,
					   cImp_operaciones, cUso_futuro_ccenS, cUso_futuro_bancoS, cUser_insertS, dFecha_insertS
				FROM bdidomi:Dom_cce_sumario WHERE nombre_arch = p_nombreArc;

				---Insert a la tabla sumario maestra
				INSERT INTO bdidomi:Dom_cce_sumario_paso( Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Num_bloque,
					        Num_operaciones, Imp_operaciones, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert)
				VALUES( v_c_nombreArc, cFecha_presentacionS, cTipo_registroS, cNum_secuenciaS, cCod_operacionS, cNum_bloqueS, cNum_operaciones,
							cImp_operaciones, cUso_futuro_ccenS, cUso_futuro_bancoS, cUser_insertS, dFecha_insertS);

				EXECUTE PROCEDURE "informix".sp_Domi_GeneraArchivo(v_c_nombreArc,cFecha_presentacionS,'01') INTO v_codSp;

				IF v_codSp <> '00000' THEN
					--SE BORRA EL ARCHIVO QUE SE INSERTO
					DELETE  bdidomi:Dom_cce_archivos WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionE;
					--SE BORRA LAS TEMPORALES (DE PASO)
					DELETE  bdidomi:Dom_cce_encabezado_paso WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionE;
					DELETE  bdidomi:dom_cce_detalle_paso WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionD;
					DELETE  bdidomi:Dom_cce_sumario_paso WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionS;
					LET v_sMensaje = "ERROR AL GENERAR EL ARCHIVO";
					LET v_cod_ret = v_codSp;
					RETURN v_cod_ret,v_sMensaje;
				END IF;
				--se pasa los datos a las historicas
				EXECUTE PROCEDURE "informix".sp_Domi_MoverRegistrosHist(v_c_nombreArc,cFecha_presentacionS, "T") INTO v_codSp;
				IF v_codSp <> '00000' THEN
					--SE BORRA EL ARCHIVO QUE SE INSERTO
					DELETE  bdidomi:Dom_cce_archivos WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionE;
					--SE BORRA LAS TEMPORALES (DE PASO)
					DELETE  bdidomi:Dom_cce_encabezado_paso WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionE;
					DELETE  bdidomi:dom_cce_detalle_paso WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionD;
					DELETE  bdidomi:Dom_cce_sumario_paso WHERE nombre_arch = v_c_nombreArc AND fecha_presentacion = cFecha_presentacionS;
					LET v_sMensaje = "ERROR AL GENERAR EL ARCHIVO";
					LET v_cod_ret = v_codSp;
					RETURN v_cod_ret,v_sMensaje;
				END IF;

			ELSE
				LET v_sMensaje = "EL ARCHIVO A COPIAR YA TIENE SU CONSECUTIVO";
				LET v_cod_ret = "00008";
				RETURN v_cod_ret,v_sMensaje;

			END IF;
		--se manda el erro de que no existe el archivo
		ELSE
			LET v_sMensaje = "EL ARCHIVO A COPIAR NO EXISTE";
			LET v_cod_ret = "00007";
			RETURN v_cod_ret,v_sMensaje;
		END IF;

		LET v_sMensaje = "EL ARCHIVO FUE COPIADO SATISFACTORIAMENTE";
		LET v_cod_ret = "00000";
		RETURN v_cod_ret,v_sMensaje;
	END;
END PROCEDURE;