CREATE PROCEDURE "informix".sp_tef_valida_datos(psNombreArchivo CHAR(20), psFecha_Presentacion CHAR(8),psTipoArchivo CHAR(1), piNumArchivo INTEGER,psRol CHAR(1),psNomProceso CHAR(20))

RETURNING CHAR(5), CHAR (2);

--****************************************************************************************************
-- DESCRIPCION:  PROCEDIMIENTO PARA VALIDAR LOS DATOS EN LAS TABLAS DE PASO.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 15/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

DEFINE vsFlagNumSecuencia CHAR(5);
DEFINE vsFlagFechaAplicacion CHAR(5);
DEFINE vsFlagNombreOrdenante CHAR(5);
DEFINE v_iCodReSP2 INTEGER;
DEFINE v_iDigVeSP2 INTEGER;
DEFINE vsFlagNumCtaReceptor CHAR(5);
DEFINE vsFlagNombreReceptor CHAR(5);
DEFINE vsFlagRef_Serv CHAR(5);

DEFINE	nom_arch CHAR(20);
DEFINE	fec_presen CHAR(8);
DEFINE	vsCodRet CHAR(5);
DEFINE  v_nivel CHAR(2);
DEFINE	sql_err INTEGER;
DEFINE v_contusoba INTEGER;
DEFINE v_ciclo  INTEGER;
DEFINE v_bancorev char(3);
DEFINE v_ini INTEGER;
DEFINE v_bancComa CHAR(1);
DEFINE v_BancoCoppel	CHAR(3);
DEFINE v_f_ENC CHAR(8);
DEFINE i_importe INTEGER;
DEFINE i_Valormax INTEGER;
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
DEFINE	e_fut_banco CHAR(370);

DEFINE vsFlagValUsoFuturo CHAR(5);
DEFINE vsFlagValUsoFuturoBanco CHAR(5);


--Se declaran las variables para utilizar en Detalle
DEFINE vsFlagImporte CHAR(5);
DEFINE vsFechaAplica CHAR(5);
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
DEFINE	d_nombre_rec CHAR(10);
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
DEFINE	d_futuro_banco CHAR(11);

DEFINE	d_Solicitud_Confirmacion CHAR(1);
DEFINE	d_Ref_COnfirmacion CHAR(30);
DEFINE	d_Uso_Futuro_Cce CHAR(1);
DEFINE	d_Tasa_Tiie_Prom CHAR(7);
DEFINE	d_Dias_Retraso CHAR(1);
DEFINE	d_Imp_Tot_Int CHAR(15);

--No se ocupa para la generacion del archivo
DEFINE	vscve_estatus CHAR(2);
DEFINE	vsfolio_suc CHAR(16);

--Se declaran las variables para utilizar en Sumario de bloque
DEFINE	s_tpo_reg CHAR(2);
DEFINE	s_num_secu CHAR(7);
DEFINE	s_cod_oper CHAR(2);
DEFINE	s_num_bloq CHAR(7);
DEFINE	s_num_oper CHAR(7);
DEFINE	s_imp_oper CHAR(18);
DEFINE	s_uso_fut_ccen CHAR(40);
DEFINE	s_uso_fut_banco CHAR(364);

---Variables a utilizar para validaciones de amarre
DEFINE v_sPriNomb CHAR(1);
DEFINE v_cRespSP  CHAR(5);
DEFINE v_dFechaSp DATE;
DEFINE v_sRetCodSP CHAR(5);
DEFINE v_dFechaReSp DATE;
DEFINE v_secu_bANDera CHAR(7);
DEFINE v_secu_max CHAR(7);
DEFINE v_fecha_dia CHAR(2);
DEFINE v_fecha_mes CHAR(2);
DEFINE v_fecha_ano CHAR(4);
DEFINE v_sValorMax CHAR(15);
DEFINE v_dFechaProce DATE;
DEFINE v_LogTarDeb	INTEGER;
DEFINE v_BancTar 	CHAR(3);
DEFINE v_iCodReSP INTEGER;
DEFINE v_iDigVeSP INTEGER;
DEFINE v_iNombre	INTEGER;
DEFINE v_iBanNume	INTEGER;
DEFINE v_fec_40		CHAR(8);
DEFINE v_iCont_blo	INTEGER;
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
DEFINE v_counBloc	INTEGER;
DEFINE v_contaBlco	char(2);


LET vsFlagNumSecuencia = '';
LET vsFlagFechaAplicacion = '';
LET vsFlagNombreOrdenante = '';
LET v_iCodReSP2 = 0;
LET v_iDigVeSP2 = 0;
LET vsFlagNumCtaReceptor = '';
LET vsFlagNombreReceptor = '';
LET vsFlagRef_Serv = '';



LET nom_arch = '';
LET	fec_presen = '';
let	vsCodRet ='00000';
LET v_nivel = '00';
LET v_NombrePruBlo = '';
LET v_contaBlco = '';
LET v_ciclo = 0;
let v_bancorev = '';
let v_ini = 0;
LET v_bancComa = '';
LET v_BancoCoppel = '';
LET v_f_ENC = '';
LET no_cod_oper = '';

--Se Inicializan las variables para utilizar  en las validaciones del bloque
--LET	e_fec_pres = '';
LET	e_tpo_reg = '';
LET	e_num_secu = '';
LET	e_cod_oper = '';
LET	e_cve_ban = '';
LET	e_sentido = '';
LET	e_servicio = '';
LET	e_num_bloq = '';
LET	e_cod_divi = '';
LET	e_cve_rech_bl = '';
LET	e_modalidad = '';
LET	e_fut_ccen = '';
LET	e_fut_banco = '';
LET vsFlagValUsoFuturo = '';
LET vsFlagValUsoFuturoBanco = '';


--Se Inicializan las variables para utilizar en Detalle
LET vsFlagImporte = '';
LET vsFechaAplica = '';

LET	d_tpo_reg = '';
LET	d_num_secu = '';
LET	d_cod_oper = '';
LET	d_cod_divi = '';
LET	d_fec_trans = '';
LET	d_ban_pres = '';
LET	d_ban_rece = '';
LET	d_importe = '';
LET	d_futuro_ccen  = '';
LET	d_tpo_opera = '';
LET	d_fec_aplica = '';
LET	d_tpo_cta_ord = '';
LET	d_num_cta_ord = '';
LET	d_nombre_ord = '';
LET	d_rfc_ord = '';
LET	d_tpo_cta_rec = '';
LET	d_num_cta_rec = '';
LET	d_nombre_rec = '';
LET	d_rfc_rec = '';

LET	d_ref_serv = '';
LET	d_nom_tit_serv = '';
LET	d_imp_iva = '';
LET	d_ref_nume = '';
LET	d_ref_leyen = '';
LET	d_cve_rast = '';
LET	d_motivo_dev = '';
LET	d_fec_pres_ini = '';
LET d_futuro_banco = '';

LET d_Solicitud_Confirmacion = '';
LET d_Ref_COnfirmacion = '';
LET d_Uso_Futuro_Cce = '';
LET d_Tasa_Tiie_Prom = '';
LET d_Dias_Retraso = '';
LET d_Imp_Tot_Int = '';


LET vscve_estatus = '';
LET	vsfolio_suc = '';


--Se Inicializan las variables para utilizar en sumario de bloque
LET	s_tpo_reg = '';
LET	s_num_secu = '';
LET	s_cod_oper = '';
LET	s_num_bloq = '';
LET	s_num_oper = '';
LET	s_imp_oper = '';
LET s_uso_fut_ccen = '';
LET s_uso_fut_banco = '';

--Se valida que los datos no vengan en blancos o null

---SE inicializan las variables que se utlizan para validacion especiales
LET v_cRespSP = '';
LET v_sRetCodSP = '';
LET v_secu_bANDera = '0000002';
LET v_fecha_ano = '';
LET v_fecha_mes = '';
LET v_fecha_dia = '';
LET v_sValorMax = '';
LET v_fec_40 = '';
LET v_cRechBlo = '';
LET cCicloFech = 'S';
LET cBancNom = '';
LET cDiaNom = '';
LET cAnoNom = '';
LET cMesNom = '';
LET cConseNom = '';
LET cNomFecha = '';
LET v_cuenta_sp = '';
LET v_bancoNomb = '';
LET v_dianombre = '';
LET v_dFechaProce = CURRENT;  --'01/01/1900';


--SET DEBUG FILE TO "/dbexport/TEF/trace/TRACEsp_tef_valida_datos.sql";
--SET DEBUG FILE TO "/tmp/Cesar/1221/TEF/TRACEsp_tef_valida_datos.sql";
--TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vsCodRet = sql_err;
			RETURN vsCodRet,v_nivel;
		END IF;
	END EXCEPTION;
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--VALIDA LA FECHA
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(psFecha_Presentacion,'N') INTO v_cRespSP;
	
	IF (NVL(psTipoArchivo, '') NOT IN ('E','S','R')) THEN --VALIDA EL TIPO DE ARCHIVO
		LET vsCodRet = '00601';
	ELIF (TRIM(NVL(psNombreArchivo, '')) = '') THEN --VALIDA KE NO ESTE EN BLANCO
		LET vsCodRet = '00602';
	ELIF ((v_cRespSP <> '00000') OR (TRIM(NVL(psFecha_Presentacion, '')) = '')) THEN --VALIDA LA FECHA
		LET vsCodRet = '00603';
	ELIF (NVL(piNumArchivo, '') NOT IN ('10','11','60','61','62','63')) THEN --VALIDA EL NUMERO DE ARCHIVO
		--LET vsCodRet = '00618';
		LET vsCodRet = '00604';
	ELIF (NVL(psRol, '') NOT IN ('P','R')) THEN --VALIDA EL EL ROL 
		--LET vsCodRet = '00619';
		LET vsCodRet = '00605';
	ELIF(NOT EXISTS (SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Encabezado_Paso WHERE nombre_arch = psNombreArchivo AND fecha_presentacion = psFecha_Presentacion)) THEN --NO EXISTE EL REGISTRO DEL ENCABEZADO
		LET vsCodRet = '00606';
	ELIF (NOT EXISTS (SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE nombre_arch = psNombreArchivo AND fecha_presentacion = psFecha_Presentacion)) THEN --NO EXISTE EL REGISTRO DEL DETALLE
		LET vsCodRet = '00607';
	ELIF (NOT EXISTS (SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Sumario_Paso WHERE nombre_arch = psNombreArchivo AND fecha_presentacion = psFecha_Presentacion)) THEN --NO EXISTE EL REGISTRO DEL SUMARIO
		LET vsCodRet = '00608';
	ELSE -- OK EXISNTEN REGISTROS EN LA 3 TABLAS PARA EL MISMO NOMBRE DE ARCHIVO
		
		LET v_nivel = '02';
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--OBTIENE LOS DATOS DEL ENCABEZADO
		SELECT FIRST 1 fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio,
		num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco
		INTO v_fecha_prese,e_tpo_reg, e_num_secu,e_cod_oper,e_cve_ban,e_sentido,e_servicio,
		e_num_bloq,e_cod_divi,e_cve_rech_bl,e_modalidad,e_fut_ccen,e_fut_banco
		FROM BdiTef:"informix".Tef_Cce_Encabezado_Paso 
		WHERE nombre_arch = psNombreArchivo 
		AND fecha_presentacion = psFecha_Presentacion;
		
		
		--OBTIENEN LA CLAVE DE BANCO
		SELECT FIRST 1 Valor INTO v_BancoCoppel FROM BdiTef:"informix".Tef_Parametros WHERE cod_param = '75';
		
		--VALIDA LA FECHA
		EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(e_num_bloq,'N') INTO vsCodRet;
		
		--8--SE VALIDA LA FECHA DE PRESENTACION
		EXECUTE PROCEDURE BdiTef:"informix".sp_valida_fecha(v_fecha_prese) INTO v_cRespSP;
		
		--12--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO
		EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(e_fut_ccen,'B') INTO vsFlagValUsoFuturo;
		--13--VALIDA QUE LOS CAMPOS DE USO FUTURO BANCO VENGAN EN BLANCO
		EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(e_fut_banco,'B') INTO vsFlagValUsoFuturoBanco;
		
		
		IF (vsCodRet <> '00000') THEN -- FECHA NO VALIDA
			LET vsCodRet = '00609';
		ELIF (e_tpo_reg <> '01') THEN --1--VALIDACION DEL TIPO DE REGISTRO
			LET vsCodRet = '00610';
		ELIF (e_num_secu <> '0000001') THEN --2--SE VALIDA EN NUMERO DE SECUENCIA
			LET vsCodRet = '00611';
		ELIF (((SUBSTR(psNombreArchivo,11,2) <> e_cod_oper) AND (SUBSTR(psNombreArchivo,14,2) <> e_cod_oper) ) 
			OR (NOT EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Codigo_Oper  WHERE cod_operacion = e_cod_oper )))  THEN --3--SE VALIDA EL CODIGO DE OPERACION (10,11,60,61,62,63)
			LET vsCodRet = '00612';
		ELIF (SUBSTR(psNombreArchivo,(DECODE(LENGTH(TRIM(psNombreArchivo)),16,4,2)),3) <> v_BancoCoppel)  THEN  ---4--VALIDACION DEL BANCO  ARCHIVO - NOMARCHIVO -BD
			--Ebbbddmmyyyy.oocc 
			--S01137A2.A6121098
			--E13720042011.6001
			LET vsCodRet = '00613';
		ELIF ((e_sentido NOT IN ('S','E','R')) OR (SUBSTR(psNombreArchivo,1,1) NOT IN ('S','E','R'))) THEN --5--VALIDACION DEL SENTIDO    ---VALIDACION DE LA PRIMERA LETRA DEL NOMBRE CON EL SENTIDO
			LET vsCodRet = '00614';
		ELIF (e_servicio <> '2') THEN --6--SE VALIDA EL SERVICIO
			LET vsCodRet = '00615';
		ELIF (SUBSTR(psNombreArchivo,(DECODE(LENGTH(TRIM(psNombreArchivo)),16,15,5)),2) <> SUBSTR(e_num_bloq, (LENGTH(e_num_bloq)-1),2)) THEN --7 ----SE VALIDA QUE EL DIA DEL BLOKE SEA EL MISMO DEL ARCHIVO.
			LET vsCodRet = '00616';
			
		--COMENTADO A PETICION DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN
		--PERMITIR EL PROCESO DE ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
		/*
		ELIF ((v_cRespSP <> '00000') 
		OR (psFecha_Presentacion <> v_fecha_prese) 
		OR (NOT EXISTS (SELECT Fecha_proceso FROM BdiTef:"informix".Tef_Procesos 
			WHERE Cve_Proceso  = psNomProceso 
			AND Fecha_Proceso = (SUBSTR(psFecha_Presentacion,5,2) || '/' || SUBSTR(psFecha_Presentacion,7,2) || '/' || SUBSTR(psFecha_Presentacion,1,4)))) 
			) THEN --8--SE VALIDA LA FECHA DE PRESENTACION
			LET vsCodRet = '00617';
		*/
			
		ELIF (e_cod_divi <> '01') THEN --9-- VALIDA EL CODIGO DE DIVISAS
			LET vsCodRet = '00618';
		ELIF (e_cve_rech_bl <> '00') OR (NOT EXISTS(SELECT descripcion FROM  BdiTef:"informix".Tef_Cat_Rechazos WHERE cve_rechazo = e_cve_rech_bl)) THEN --10--VALIDA LA CAUSA DE RECHAZO DE BLOQUE
			LET vsCodRet = '00619';
		ELIF (e_modalidad <> '2') THEN --11--VALIDA LA MODALIDAD
			LET vsCodRet = '00620';
		ELIF (vsFlagValUsoFuturo <> '00000') THEN --12--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO
			LET vsCodRet = '00621';
		ELIF (vsFlagValUsoFuturoBanco <> '00000') THEN --13--VALIDA QUE LOS CAMPOS DE USO FUTURO BANCO VENGAN EN BLANCO
			LET vsCodRet = '00622';
		ELSE -- ENCABEZADO OK
			
			LET v_nivel = '03';
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--15--VALIDACION DEL NUMERO DE SECUENCIA
			SELECT MAX(num_secuencia) INTO v_secu_max FROM   BdiTef:"informix".Tef_Cce_Detalle_Paso
			WHERE nombre_arch = psNombreArchivo AND fecha_presentacion = psFecha_Presentacion;
			
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--SE TOMA EL VALOR MAXIMO VALOR PERMITIDO ($$$) PARA TRANSACCIONES
			SELECT FIRST 1 Valor INTO v_sValorMax FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '80';
			
			
			--15--VALIDACION DEL NUMERO DE SECUENCIA
			SELECT COUNT(num_secuencia) INTO v_secu_max FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
			WHERE nombre_arch = psNombreArchivo AND fecha_presentacion = psFecha_Presentacion;
			
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--OBTIENE LOS REGISTROS DEL DETALLE
			FOREACH
				SELECT tipo_registro, num_secuencia, cod_operacion, cod_divisa, fecha_trans, banco_presentador, banco_receptor,
						importe, uso_futuro_ccen, tipo_operacion, fecha_aplica, tipo_cta_ord, num_cta_ord, nombre_ord, rfc_ord, tipo_cta_rec, num_cta_rec, nombre_rec,
						rfc_rec, ref_servicio, nombre_titular_serv, importe_iva, ref_numerica, ref_leyenda, clave_rastreo, motivo_dev, fecha_pres_ini, 
						uso_futuro_banco,
						Solicitud_Confirmacion, Ref_COnfirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, Imp_Tot_Int,
						cve_Status, folio_suc
				INTO 	d_tpo_reg,d_num_secu,d_cod_oper,d_cod_divi,d_fec_trans,d_ban_pres,d_ban_rece,
						d_importe,d_futuro_ccen,d_tpo_opera,d_fec_aplica,d_tpo_cta_ord,d_num_cta_ord,d_nombre_ord,d_rfc_ord,d_tpo_cta_rec,d_num_cta_rec,d_nombre_rec,
						d_rfc_rec,d_ref_serv,d_nom_tit_serv,d_imp_iva,d_ref_nume,d_ref_leyen,d_cve_rast,d_motivo_dev,d_fec_pres_ini,
						d_futuro_banco,
						d_Solicitud_Confirmacion, d_Ref_COnfirmacion, d_Uso_Futuro_Cce, d_Tasa_Tiie_Prom, d_Dias_Retraso, d_Imp_Tot_Int,
						vscve_estatus,vsfolio_suc
				FROM  BdiTef:"informix".Tef_Cce_Detalle_Paso
				WHERE nombre_arch = psNombreArchivo
				AND fecha_presentacion = psFecha_Presentacion
				ORDER BY num_secuencia
				
				--15--VALIDA LA SECUENCIA
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_num_secu,'N') INTO vsFlagNumSecuencia;
				
				--18-- VALIDA LA FECHA DE TRANSFERENCIA
				IF piNumArchivo <> 10 THEN
				  EXECUTE PROCEDURE BdiTef:"informix".sp_valida_fecha(d_fec_trans) INTO v_cRespSP;
				END IF;
				
				--21--VALIDA EL IMPORTE D_IMPORTE
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_importe,'N') INTO vsFlagImporte;
				
				--22--VALIDA QUE LOS CAMPOS DE USO FUTURO CCE VENGA EN BLANCO
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_futuro_ccen,'B') INTO vsFlagValUsoFuturo;
				
				--24-- VALIDA LA FECHA DE APLICACON
				EXECUTE PROCEDURE BdiTef:"informix".sp_valida_fecha(d_fec_aplica) INTO vsFlagFechaAplicacion;
				
				--26-- VALIDA EL DIGITO VERIFICADOR -ORDENANTE
				IF piNumArchivo <> 10 THEN
					EXECUTE PROCEDURE BdiSpei:"informix".sp_validadv(SUBSTR(d_num_cta_ord,3,18)) INTO v_iCodReSP, v_iDigVeSP;
				END IF;
				--27-- VALIDA QUE EL NOMBRE CONTENGA CARACTERES VALIDOS
				IF piNumArchivo <> 10 THEN
					EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_nombre_ord,'T') INTO vsFlagNombreOrdenante;
				END IF;
				--30--SE VALIDA  EL NUMERO DE CUENTA DEL RECEPTOR
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_num_cta_rec,'N') INTO vsFlagNumCtaReceptor;
				
				--30-- VALIDA EL DIGITO VERIFICADOR -RECEPTOR
				EXECUTE PROCEDURE BdiSpei:"informix".sp_validadv(SUBSTR(d_num_cta_rec,3,18)) INTO v_iCodReSP2, v_iDigVeSP2;
				
				--31-- VALIDA QUE EL NOMBREDEL RECEPTOR NO VENGA VACIO
				--EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_nombre_rec,'T') INTO vsFlagNombreReceptor;
				
				--33--VALIDA LA REFERENCIA DEL SERVICIO CON EL EMISOR
				--EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_ref_serv,'T') INTO vsFlagRef_Serv;
				
				
				IF (d_tpo_reg <> '02') THEN --- 14--VALIDA EL TIPO DE REGISTRO DE DETALLE
					LET vsCodRet = '00622';
				ELIF ((vsFlagNumSecuencia <> '00000') AND (NOT(d_num_secu::INTEGER BETWEEN 2 AND (v_secu_max::INTEGER + 1))))  THEN --15 VALIDA EL NUMERO DE SECUENCIA
					LET vsCodRet = '00623';
				ELIF (e_cod_oper <>  d_cod_oper) THEN --16-- VALIDA QUE EL CODIGO DE OPERACION SEA IGUAL AL ENCABEZADO
					LET vsCodRet = '00624';
				ELIF (e_cod_divi <> d_cod_divi) THEN --17--VALIDA QUE EL CODIGO DE DIVISA SEA IGUAL AL ENCABEZADO
					LET vsCodRet = '00625';
				ELIF ((v_cRespSP = '00001') OR (v_cRespSP = '00002')) THEN --18-- VALIDA LA FECHA DE TRANSFERENCIA
					LET vsCodRet = '00626';
				ELIF ((EXISTS(SELECT descripcion FROM BdInteg:"informix".Si_Bancos WHERE banco = d_ban_pres AND flg_tef_r =  '0'  AND flg_tef_p = '0' ))
						OR ((SUBSTR(psNombreArchivo,1,1) = 'S') AND (d_ban_pres = v_BancoCoppel))/*receptor*/ 
						OR ((SUBSTR(psNombreArchivo,1,1) = 'E') AND (d_ban_pres <> v_BancoCoppel)) /*presentador*/) THEN  --19--SE VALIDA QUE EL BANCO SEA EL MISMO QUE EL DEL ENCABEZADO
					LET vsCodRet = '00627';
				ELIF ((EXISTS(SELECT descripcion FROM BdInteg:"informix".Si_Bancos WHERE banco = d_ban_rece AND flg_tef_r = '0'  AND flg_tef_p = '0' ))
						OR (d_ban_rece = d_ban_pres) 
						OR ((SUBSTR(psNombreArchivo,1,1) = 'S') AND (d_ban_rece <> v_BancoCoppel)) 
						OR ((SUBSTR(psNombreArchivo,1,1) = 'E') AND (d_ban_rece = v_BancoCoppel))) THEN ---20--VALIDACION DEL BANCO RECEPTOR
					LET vsCodRet = '00628';
				ELIF ((vsFlagImporte <> '00000') --ES NUMERICO
						OR ((piNumArchivo IN ('10', '11')) AND (d_importe::INTEGER <> 0)) --VERIFICACION DE CU8ENTAS DEBE DE SER 0
						OR ((piNumArchivo IN ('60','61','62','63')) AND (d_importe::INTEGER = 0)) -- MOVIMIENTO, DEBE DE SER DIFERENNTE DE 0
						OR(((d_importe::INTEGER)/100) > v_sValorMax::INTEGER)) --VALIDA QUE NO SOBREPASE EL VALOR MAXIMO PERMITIDO
						THEN --21 VALIDA EL IMPORTE D_IMPORTE
					LET vsCodRet = '00629';
				ELIF (vsFlagValUsoFuturo <> '00000') THEN --22--VALIDA QUE LOS CAMPOS DE USO FUTURO CCE VENGA EN BLANCO
					LET vsCodRet = '00630';
				ELIF ((piNumArchivo <> 10) and (NOT EXISTS (SELECT Cod_Operacion FROM BdiTef:"informix".Tef_Codigo_Oper WHERE Cod_Operacion = d_cod_oper))) THEN -- 23 VALIDA EL TIPO DE OPERACION
					LET vsCodRet = '00631';
				--ELIF ((vsFlagFechaAplicacion = '00001') OR (vsFlagFechaAplicacion = '00002')) THEN --24-- VALIDA LA FECHA DE APLICACON
				ELIF (vsFlagFechaAplicacion <> '00000') THEN --24-- VALIDA LA FECHA DE APLICACON
				LET vsCodRet = '00632';
				ELIF ((piNumArchivo <> 10) AND (NOT EXISTS(SELECT  descripcion  FROM BdiTef:"informix".Tef_Tipo_Cta WHERE  tipo_cta = d_tpo_cta_ord))) THEN --25--VALIDA EL TIPO DE CUENTA DEL ORDENANTE
					LET vsCodRet = '00633';
				ELIF (((piNumArchivo <> 10) AND ((d_tpo_cta_ord IN ('03', '05')) AND (LENGTH(TRIM(SUBSTR(d_num_cta_ord,5,20))) <> 16))) --VALIDA LA LONGITUD QUE DEBE DE SER DE 16 CARACTERES --tarjeta
						OR ((d_tpo_cta_ord ='40') 
						AND ((LENGTH(TRIM(SUBSTR(d_num_cta_ord,3,20))) <> 18) --VALIDA LA LONGITUD QUE DEBE DE SER DE 18 CARACTERES --cuenta
						OR ((piNumArchivo IN ('11', '61', '62', '63')) AND ((SUBSTR(d_num_cta_ord,3,3) <> d_ban_rece)  --EL BANCO DE LA CUENTA CLABE NO ES EL MISMO BANCO
						OR (NOT EXISTS(SELECT descripcion FROM BdInteg:"informix".Si_Bancos WHERE banco = SUBSTR(d_num_cta_ord,3,3) )) --NO EXISTE EL BANCO 
						--OR ((v_iCodReSP <> 0) OR (v_iDigVeSP <> 1))
						) ))) OR (d_num_cta_ord = '00000000000000000000') and  (piNumArchivo <> '10')) --DIGITO VERIFICADOR INVALIDO
						THEN -- 26 VALIDA EL DIGITO VERIFICADOR
					LET vsCodRet = '00634';
				ELIF ((piNumArchivo <> 10) AND ((LENGTH(TRIM(d_nombre_ord)) = 0) OR (vsFlagNombreOrdenante <> '00000')))  THEN --27-- VALIDA QUE EL NOMBRE NO VENGA VACIO   -- MENOS EL ARCHIVOS 10
					LET vsCodRet = '00635';
				--ELIF ((piNumArchivo <> 10) AND (TRIM(NVL(d_rfc_ord, '')) = '')) THEN --28--VALIDA EL RFC DEL ORDENANDTE    -- MENOS EL ARCHIVOS 10
					--LET vsCodRet = '00636';--01/07/211			
				ELIF (NOT EXISTS(SELECT descripcion  FROM BdiTef:"informix".Tef_Tipo_Cta WHERE  tipo_cta = d_tpo_cta_rec)) THEN --29--VALIDA EL TIPO DE CUENTA DEL RECEPTOR
					LET vsCodRet = '00637';
				ELIF ((vsFlagNumCtaReceptor <> '00000') -- VALIDA KE CONTENGA NUMEROS
						--OR ((d_tpo_cta_rec = '03') AND (LENGTH(TRIM(SUBSTR(d_num_cta_rec,5,20))) <> 16)) --VALIDA LA LONGITUD QUE DEBE DE SER DE 18 CARACTERES --tarjeta
						--OR ((d_tpo_cta_rec = '40') 
						--AND ((LENGTH(TRIM(SUBSTR(d_num_cta_rec,3,18/*20*/))) <> 18) --VALIDA LA LONGITUD QUE DEBE DE SER DE 18 CARACTERES --cuenta
						--OR ((piNumArchivo IN ('11','61','62','63'))  AND (SUBSTR(d_num_cta_rec,3,3) <> d_ban_pres)) --EL BANCO DE LA CUENTA CLABE NO ES EL MISMO BANCO
						--OR (NOT EXISTS(SELECT descripcion FROM BdInteg:"informix".Si_Bancos WHERE banco = SUBSTR(d_num_cta_rec,3,3))) --NO EXISTE EL BANCO
						------OR ((v_iCodReSP2 <> 0) OR (v_iDigVeSP2 <> 1)) --DIGITO VERIFICADOR INVALIDO
						--))
						) THEN --30--VALIDA  EL NUMERO DE CUENTA DEL RECEPTOR
					LET vsCodRet = '00638';
				--ELIF (LENGTH(TRIM(d_nombre_rec)) = 0) OR (vsFlagNombreReceptor <> '00000')  THEN --31-- VALIDA QUE EL NOMBREDEL RECEPTOR NO VENGA VACIO
					--LET vsCodRet = '00639';
				--ELIF (NVL(d_rfc_rec, '') = '') THEN --32--SE VALIDA EL RFC DEL RECEPTOR
				--	LET vsCodRet = '00640';
				--ELIF ((piNumArchivo <> 10) AND ((LENGTH(TRIM(NVL(d_ref_serv, ''))) = 0) OR (vsFlagRef_Serv <> '00000') )) THEN --33--VALIDA LA REFERENCIA DEL SERVICIO CON EL EMISOR
					--LET vsCodRet = '00641';   --01/07/211
				ELSE --OTRAS VALIDACIONES
					
					LET v_cRespSP = '';
					LET vsCodRet = '00000';
					
					--34--VALIDA EL NOMBRE DEL TITULAR
					--EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_nom_tit_serv,'T') INTO v_cRespSP;--01/07/211
					
					--IF ((vsCodRet = '00000') AND ((v_cRespSP <> '00000') OR (LENGTH(TRIM(d_nom_tit_serv)) = 0) )) THEN --34--VALIDA EL NOMBRE DEL TITULAR
						--LET vsCodRet = '00642';
					--END IF;--01/07/211
					
					--35--VALIDA EL IMPORTE DEL IVA DE LA OPERACION
					/*EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_imp_iva,'N') INTO v_cRespSP;
					
					IF ((vsCodRet = '00000') AND ((v_cRespSP <> '00000') OR (d_imp_iva::FLOAT < 0.0 ) )) THEN --35--VALIDA EL IMPORTE DEL IVA DE LA OPERACION
						LET vsCodRet = '00643';
					END IF;*/
					
					--36--VALIDA LA REFERENCIA NUMERICA DEL ORDENATNE
					IF piNumArchivo <> 10 THEN
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_ref_nume,'N') INTO v_cRespSP;
						
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --36--VALIDA LA REFERENCIA NUMERICA DEL ORDENATNE
							LET vsCodRet = '00644';
						END IF;
					END IF;
					
					--37-- VALIDA LA REFERENCIA LEYENDA DEL ORDENANTE
					IF piNumArchivo <> 10 THEN
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_ref_leyen,'T') INTO v_cRespSP;
						
						IF ((vsCodRet = '00000') AND ((v_cRespSP <> '00000') OR (LENGTH(TRIM(d_ref_leyen)) = 0) )) THEN --37-- VALIDA LA REFERENCIA LEYENDA DEL ORDENANTE
							LET vsCodRet = '00645';
						END IF;
					END IF;
					
					--38--VALIDA LA CLAVE DE RASTREO
					EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_cve_rast,'T') INTO v_cRespSP;
					
					IF ((vsCodRet = '00000') AND ((v_cRespSP <> '00000') OR (LENGTH(TRIM(d_cve_rast)) = 0) )) THEN --38--VALIDA LA CLAVE DE RASTREO
						LET vsCodRet = '00646';
					END IF;
					
					--39--VALIDA EL MOTIVO DE DEVOLUCION
					EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_motivo_dev,'N') INTO v_cRespSP;
					
					IF ((vsCodRet = '00000') AND ((v_cRespSP <> '00000') OR (LENGTH(TRIM(d_motivo_dev)) = 0) 
						OR (NOT EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Cat_Devoluciones WHERE motivo_dev = d_motivo_dev))) 
						OR (((piNumArchivo = 61) OR (piNumArchivo = 63)) AND (d_motivo_dev = '00'))) THEN --39--VALIDA EL MOTIVO DE DEVOLUCION
						LET vsCodRet = '00647';
					END IF;
					
					--40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
					EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_fec_pres_ini,'N') INTO v_cRespSP;
					
					IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
						LET vsCodRet = '00648';
					END IF;
					
					--40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
					EXECUTE PROCEDURE BdiTef:"informix".sp_valida_fecha(d_fec_pres_ini) INTO v_cRespSP;
					IF ((vsCodRet = '00000') AND ((v_cRespSP = '00001') OR (v_cRespSP = '00002'))) THEN --40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
						LET vsCodRet = '00648';
					END IF;
					
					--40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
					IF ((vsCodRet = '00000') AND((piNumArchivo = 60) AND (psFecha_Presentacion <> d_fec_pres_ini))) THEN --40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
						LET vsCodRet = '00648';
					END IF;
					
					--41--VALIDA SOLICITUD DE CONFIRMACION
					IF ((vsCodRet = '00000') AND (d_Solicitud_Confirmacion NOT IN (' ', '1'))) THEN --36--VALIDA LA REFERENCIA NUMERICA DEL ORDENATNE
						LET vsCodRet = '00649';
					END IF;
					
					--42--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO -11-
					EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_futuro_banco,'B') INTO v_cRespSP;
					IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --42--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO -11-
						LET vsCodRet = '00650';
					END IF;
					
					IF (piNumArchivo = 62) THEN 
						--42--VALIDA REFERENCIA CONFIRMACION
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_Ref_COnfirmacion,'T') INTO v_cRespSP;
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --42--VALIDA REFERENCIA CONFIRMACION
							--LET vsCodRet = '00651';
						END IF;
						
						--43--VALIDA QUE LOS CAMPOS DE USO FUTURO CEE VENGAN EN BLANCO -1-
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_Uso_Futuro_Cce,'B') INTO v_cRespSP;
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --43--VALIDA QUE LOS CAMPOS DE USO FUTURO CEE VENGAN EN BLANCO -1-
							LET vsCodRet = '00652';
						END IF;
					
					ELIF (piNumArchivo = 63) THEN 
						
						--49--VALIDA TASA TIIE PROMEDIO
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_Tasa_Tiie_Prom,'N') INTO v_cRespSP;
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --49--VALIDA TASA TIIE PROMEDIO
							LET vsCodRet = '00653';
						END IF;
						
						--50--VALIDA DIAS DE RETRASO
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_Dias_Retraso,'N') INTO v_cRespSP;
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --50--VALIDA DIAS DE RETRASO
							LET vsCodRet = '00654';
						END IF;
						
						--51--VALIDA IMPORTE TOTAL INTERES
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_Imp_Tot_Int,'N') INTO v_cRespSP;
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --51--VALIDA IMPORTE TOTAL INTERES
							LET vsCodRet = '00655';
						END IF;
						
					END IF;
					
					
				END IF;
				
				IF (vsCodRet <> '00000') THEN -- INDICA EL ERROR Y TERMINA LA VALIDACION DEL ARCHIVO
					RETURN vsCodRet, v_nivel;
				END IF;
				
			END FOREACH;
			
			LET v_nivel = '04';
			IF (vsCodRet = '00000') THEN 
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				----OBTIENE EL REGISTRO DEL SUMARIO DE LA TEF_CCE_SUMARIO
				SELECT tipo_registro, num_secuencia, cod_operacion, num_bloque, num_operaciones, imp_operaciones,uso_futuro_ccen, uso_futuro_banco
				INTO s_tpo_reg,s_num_secu,s_cod_oper,s_num_bloq,s_num_oper,s_imp_oper,s_uso_fut_ccen,s_uso_fut_banco
				FROM BdiTef:"informix".Tef_Cce_Sumario_Paso
				WHERE nombre_arch = psNombreArchivo
				AND fecha_presentacion = psFecha_Presentacion;
				
				--46--VALIDA QUE EL NUMERO TOTAL DE OPERACIONES EN EL BLOQUE CORRESPONDA CON LAS DEL DETALLE
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(s_num_oper,'N') INTO v_cRespSP;
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				--47--VALIDA QUE EL IMPORTE TOTAL DE OPERACIOENS 
				SELECT SUM(importe::BIGINT) INTO v_SumOper
				FROM BdiTef:"informix".Tef_Cce_Detalle_Paso  
				WHERE nombre_arch = psNombreArchivo 
				AND fecha_presentacion = psFecha_Presentacion;
				
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(s_imp_oper,'N') INTO v_cRespSP;
				
				--48--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(s_uso_fut_ccen,'B') INTO vsFlagValUsoFuturo;
				
				--49--VALIDA QUE LOS CAMPOS DE USO FUTURO BANCO VENGAN EN BLANCO
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(s_uso_fut_banco,'B') INTO vsFlagValUsoFuturoBanco;
				
				
				IF (s_tpo_reg <> '09') THEN --42 -- VALIDA EL TIPO DE REIGISTRO DE SUMARIO
					LET vsCodRet = '00656';
				ELIF (s_num_secu::INTEGER <> (v_secu_max::INTEGER + 2)) THEN --43--VALIDA QUE CONCUERDE EL NUMERO DE SECUENCIA CON EL CONSECUTIVO
					LET vsCodRet = '00657';
				ELIF (s_cod_oper <> e_cod_oper) THEN --44--VALIDA QUE LOS CODIGOS DE OPERACION SEAN IGUALES
					LET vsCodRet = '00658';
				ELIF (s_num_bloq <> e_num_bloq) THEN --45--VALIDA QUE EL NUMERO DE BLOQUE SEA IGUAL AL ENCABEZADO
					LET vsCodRet = '00659';
				ELIF ((v_cRespSP <> '00000') OR (s_num_oper::INTEGER <> v_secu_max::INTEGER)) THEN --46--VALIDA QUE EL NUMERO TOTAL DE OPERACIONES EN EL BLOQUE CORRESPONDA CON LAS DEL DETALLE
					LET vsCodRet = '00660';
				ELIF ((LENGTH(s_imp_oper) <> 18) OR (s_imp_oper::BIGINT <> v_SumOper) ) THEN --47--SE VALIDA QUE EL IMPORTE TOTAL DE OPERACIOENS SEA MENOR DE 18 DIGITOS Y CORRESPONDA A LA SUMATORIA DE LIOS IMPORTES DEL BLOQUE DE DETALLE
					LET vsCodRet = '00661';
				ELIF (vsFlagValUsoFuturo <> '00000') THEN --48--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO
					LET vsCodRet = '00662';
				ELIF (vsFlagValUsoFuturoBanco <> '00000') THEN --49--VALIDA QUE LOS CAMPOS DE USO FUTURO BANCO VENGAN EN BLANCO
					LET vsCodRet = '00663';
				END IF;
				
			END IF;
			
		END IF;
		
		--Ebbbddmmyyyy.oocc  --17
		--E01bbbAs.tffddcc --16
		
	END IF;
	
	RETURN vsCodRet,v_nivel;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCEDIMIENTO PARA VALIDAR LOS DATOS EN LAS TABLAS DE PASO.',
'Fecha: 2011/03/15',
'Version: 20110315.1220',
'BD: BdiTef', 
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: SE OMITIERON LA VALIDACION 00635 Y 00636 PARA LOS ARCHIVOS 10 DEBIDO A QUE NO SON OBLIGATORIOS PARA ESTE ARCHIVO.',
'Fecha: 2011/06/29',
'Version: 20110629.1200',
'BD: BdiTef',
'',
'Modificado: Casanova Edeza HÃÂ©ctor Juan',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: MODIFICADO A PETICION DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN.',
'Fecha: 2011/09/29',
'Version: 20110929.1534',
'BD: BdiTef';

create procedure "informix".cal_fechapre(
                       pempresa         char(3),
                       pcvebanco   	char(3),
                       pnumcuenta   	char(20),
                       pnumcheque   	char(7),
                       pfechaofi	date)
                       RETURNING char(5),date;  

   DEFINE v_codret 	char(5);
   DEFINE v_fechapre 	date;
   DEFINE v_horacheque 	char(5);
   DEFINE v_paramhora  	char(5);
   DEFINE v_esferiadox 	char(1);
   DEFINE sql_err,isam_err int;   
   DEFINE inumcheque INTEGER;
   DEFINE inumcuenta DECIMAL(20,0);


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_fechapre    = "";
   let inumcheque = 0;
   let inumcuenta = 0;

   let v_horacheque = '';

   let v_paramhora  = '';
   let v_esferiadox = '';
   let sql_err      = 0;
   let isam_err     = 0;   


BEGIN

   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret,v_fechapre;
      end if;
   end exception;

  --set debug file to "/resplogifx/conciliachq/cal_fechapre.txt";
  --trace on;

set isolation to dirty read;
set lock mode to wait 3;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    --let pempresa = '001';

	IF  pempresa    	is null or
		pcvebanco       is null or
		pnumcuenta      is null or
		pnumcheque      is null or
		pfechaofi	    is null THEN
	
	   -- datos de entrada incompletos
	   
	   LET v_codret = 210; 
	   RETURN v_codret, v_fechapre; 
	END IF;


-- obtener el parametro de la hora tope t+1
	
	select valor
	into v_paramhora
	from cce_param
	where empresa = pempresa
	and cod_param=1;

	IF v_paramhora is null THEN
	   -- no existe el parametro en cce_param
	   LET v_codret = 220; 
	   RETURN v_codret, v_fechapre; 	
	END IF;


-- obtener la hora de presentacion del cheque
	let pcvebanco = pcvebanco;
	let pnumcuenta = pnumcuenta;
	let pnumcheque = pnumcheque;
	let pfechaofi = pfechaofi;
    
    let inumcheque = pnumcheque;
    let inumcuenta = pnumcuenta;
	
	IF pcvebanco <> '137'THEN
	
		-- MOHA
		select {+INDEX(bdicheq:sc_docret_sbc idx_docret5)} to_char(fech_hor,'%H:%M')
		into v_horacheque
		from bdicheq:sc_docret_sbc  --MOHA
		where empresa=pempresa
		and banco = pcvebanco
		and numcuenta = inumcuenta
		and num_chq = inumcheque
		and cancelado = "T"
		and fecha_alta = pfechaofi;
	

		IF v_horacheque is null THEN
			-- no existe el cheque en central
			LET v_codret = 230; 
			RETURN v_codret, v_fechapre; 	
		END IF;
		
	END IF;	

-- validar feriado, sab o dom

	select "1"
	into v_esferiadox
	from bdinteg:si_feriado
	where fecha=pfechaofi;
	
	IF v_esferiadox is null THEN
		LET v_esferiadox = "0";
	END IF


	
	-- cuando es feriado, sab, dom o fuera de horario se pasa al sig habil
	
	IF v_esferiadox ="1" 
	   or to_char(pfechaofi,"%A") = "Saturday" 
	   or to_char(pfechaofi,"%A") = "Sunday" 
	   or v_horacheque > v_paramhora THEN
	   
		-- calcular la fecha correcta
		call cal_fecha_pre_fh(pfechaofi)
		returning v_codret,v_fechapre;	
		RETURN v_codret,v_fechapre;
		
	END IF

	LET v_fechapre = pfechaofi;	

END;    

RETURN v_codret,v_fechapre;

END PROCEDURE;