CREATE PROCEDURE "informix".sp_registra_crecta_cobroaut(
	p_empresa		CHAR(3),	---- Empresa
	p_num_producto	CHAR(4),	---- Numero producto
	p_num_credito	CHAR(20),	---- Numero de credito
	p_num_cuenta	CHAR(20),	---- Numero de cuenta para cargo
	p_status_cobaut	CHAR(1),	---- Estatus del registro (0 = Inactivo, 1 = Activo)
	p_opcion		CHAR(1))	---- Opcion de ejecucion (1 = Alta , 2 = Modifica/Inactiva , 3 = Modifica/Activa, 4 = Modifica/Cuenta, 5 = Consulta)

RETURNING CHAR(5),VARCHAR(80);
--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
DEFINE v_codret				VARCHAR(8);
DEFINE v_mensaje            VARCHAR(80);
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           VARCHAR(80);
DEFINE v_fecha_alta   		DATE;
DEFINE v_fecha_baja   		DATE;
DEFINE v_fecha_modif  		DATE;
DEFINE i_contador			INTEGER ;
DEFINE v_activo				VARCHAR(1);
DEFINE v_inactivo			VARCHAR(1);
DEFINE v_cobroaut			VARCHAR(1);
DEFINE v_num_cta			VARCHAR(20);
DEFINE f_parametro			VARCHAR(1);
DEFINE v_valor			DECIMAL (10,2);
DEFINE v_puntos_tasa_pref			DECIMAL (10,2);
DEFINE v_id_tasa_pref			INTEGER ;

----- ACTIVA/INACTIVA LOG PARA VALIDAR EL PROCESO
--SET DEBUG FILE TO  '/informix/resplogifx/sp_registra_crecta_cobroaut.out';
--TRACE ON;

--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************
/* 
Validación de parámetros de entrada
	v_codret = '00001';	v_mensaje = 'PARAMETRO EMPRESA VACIO';
	v_codret = '00002';	v_mensaje = 'PARAMETRO NUMERO PRODUCTO VACIO';
	v_codret = '00002';	v_mensaje = 'PARAMETRO NUMERO CREDITO VACIO';
	v_codret = '00004';	v_mensaje = 'PARAMETRO STATUS COBRO VACIO';
	v_codret = '00005'; v_mensaje = 'OPCION DE PROCESO INCORRECTA';

Valores para el mensaje (v_mensaje) dependiendo de codigo de retorno (v_codret) y la opción de proceso (p_opcion): 

p_opcion = '1' - 'OPCION DE REGISTRO DEL CREDITO'
	v_codret = '00000';	v_mensaje = 'EL REGISTRO DE INSERTA CORRECTAMENTE'; 
	v_codret = '00006';	v_mensaje = 'NO ES POSIBLE INSERTAR REGISTRO ACTIVO SIN INFORMAR CUENTA';
	v_codret = '00007';	v_mensaje = 'EL REGISTRO YA EXISTE VALIDAR';

p_opcion = '2' - 'OPCION DE MODIFICACION STATUS / INACTIVACION'
	v_codret = '00000';	v_mensaje = 'EL REGISTRO SE INACTIVA CORRECTAMENTE';
	v_codret = '00008'; v_mensaje = 'PARAMETRO STATUS COBRO INCORRECTO';
	v_codret = '00009'; v_mensaje = 'EL REGISTRO NO EXISTE VALIDAR';
	v_codret = '00010'; v_mensaje = 'EL REGISTRO YA SE ENCUENTRA INACTIVO';

p_opcion = '3' - 'OPCION DE MODIFICACION STATUS / ACTIVACION';

	v_codret = '00000'; v_mensaje = 'EL REGISTRO SE ACTIVA CORRECTAMENTE';
	v_codret = '00003';	v_mensaje = 'LA CUENTA SE DEBE INFORMAR PARA ACTIVAR EL REGISTRO';
	v_codret = '00011'; v_mensaje = 'PARAMETRO STATUS COBRO INCORRECTO';
	v_codret = '00012'; v_mensaje = 'EL REGISTRO NO EXISTE VALIDAR';
	v_codret = '00013'; v_mensaje = 'EL REGISTRO YA SE ENCUENTRA ACTIVO';

p_opcion = '4' THEN ---'OPCION DE MODIFICACION CUENTA';
	v_codret = '00000'; v_mensaje = 'VALIDAR, SE ACTUALIZA CUENTA DE REGISTRO INACTIVO ';	
	v_codret = '00000'; v_mensaje = 'LA CUENTA DEL REGISTRO SE ACTUALIZA CORRECTAMENTE';
	v_codret = '00014';	v_mensaje = 'LA CUENTA SE DEBE INFORMAR PARA ACTUALIZAR EL REGISTRO';
	v_codret = '00015';	v_mensaje = 'EL REGISTRO NO EXISTE VALIDAR';
	v_codret = '00016';	v_mensaje = 'LA CUENTA DEBE SER DIFERENTE PARA ACTUALIZAR EL REGISTRO';
*/

LET v_codret		= '00000';
LET v_fecha_alta	= '';
LET v_fecha_baja	= '';
LET v_fecha_modif	= '';
LET v_activo		= '1';
LET v_inactivo		= '0';
LET f_parametro		= '0';
LET v_cobroaut		= '';
LET v_num_cta		= '';
LET v_valor = 0;
LET v_puntos_tasa_pref = 0;
LET v_id_tasa_pref = 0;

--*****************************************************
-- INICIA PROCESO
--*****************************************************
BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
         LET v_codret    = sql_err;
         LET v_mensaje  = error_info;
	    RETURN v_codret, v_mensaje;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--- Se validan los parametros de entrada con los cuales se ejecuta en SP
	--- Se valida parametro de EMPRESA
	IF p_empresa IS NULL OR p_empresa = '' THEN
			LET v_codret = '00001';	LET v_mensaje = 'PARAMETRO EMPRESA VACIO';
	
		--- Se valida parametro de NUMERO CREDITO
		ELIF p_num_producto IS NULL OR p_num_producto = '' AND p_opcion NOT in ('5') THEN
			LET v_codret = '00002';	LET v_mensaje = 'PARAMETRO NUMERO PRODUCTO VACIO';
			
		--- Se valida parametro de NUMERO CREDITO
		ELIF p_num_credito IS NULL OR p_num_credito = '' THEN
			LET v_codret = '00002';	LET v_mensaje = 'PARAMETRO NUMERO CREDITO VACIO';
		
		--- Se valida parametro de STATUS COBRO
		ELIF p_status_cobaut IS NULL OR p_status_cobaut = '' AND p_opcion NOT in ('4') THEN
			LET v_codret = '00004';	LET v_mensaje = 'PARAMETRO STATUS COBRO VACIO';
			
		--- Se valida parametro de OPCION PROCESO
		ELIF p_opcion NOT IN ('1','2','3','4','5') THEN
			LET v_codret = '00005'; LET v_mensaje = 'OPCION DE PROCESO INCORRECTA';
		ELSE			
			
			SELECT id_cobroaut, num_cta
			INTO v_cobroaut, v_num_cta
			FROM   bdicred:"informix".sd_ctascarg
			WHERE  empresa = p_empresa
			AND num_credito = p_num_credito;
			
			SELECT a.id_tasa_pref, a.puntos_tasa_pref, b.valor
			INTO v_id_tasa_pref, v_puntos_tasa_pref, v_valor
			FROM bdicred:"informix".sd_definicion a, bdinteg:"informix".si_fechavalor b
			WHERE a.empresa = p_empresa
			AND a.num_producto = p_num_producto
			AND b.tasa = a.cod_tasa_base
			AND b.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
							WHERE r.empresa = p_empresa
							AND r.tasa = a.cod_tasa_base);
							
			IF p_opcion = '1' THEN ---'OPCION DE REGISTRO DEL CREDITO';
					IF v_cobroaut is null THEN --- 'EL REGISTRO NO EXISTE SE DEBE INSERTAR';
							IF p_num_cuenta IS NULL OR p_num_cuenta = '' AND p_status_cobaut = '1' THEN
									LET v_codret = '00006';	LET v_mensaje = 'NO ES POSIBLE INSERTAR REGISTRO ACTIVO SIN INFORMAR CUENTA';
								ELSE
									SELECT fecha_hoy
									INTO v_fecha_alta
									FROM sd_fechas
									WHERE empresa = p_empresa;
								
									INSERT INTO bdicred:"informix".sd_ctascarg (empresa,numero,con_cap_inte,naturaleza,num_credito,tipo_cta,num_cta,num_nomina,num_producto,id_cobroaut,fecha_alta,fecha_baja,fecha_modif)
									VALUES (p_empresa,0,'','A',p_num_credito,'',p_num_cuenta,'',p_num_producto,p_status_cobaut,v_fecha_alta,v_fecha_baja,v_fecha_modif);
										
									LET v_codret = '00000';	LET v_mensaje = 'EL REGISTRO DE INSERTA CORRECTAMENTE';
									
									IF v_id_tasa_pref = 1 THEN 
										LET v_valor = v_valor - v_puntos_tasa_pref;
										
										UPDATE bdicred:"informix".sd_maecred
										SET tasa_interes =  v_valor
										WHERE empresa = p_empresa
										AND num_credito = p_num_credito;
										
									END IF
									
							END IF
						ELIF v_cobroaut is not null THEN
							
							-- Se realiza cambio por INC 25 254
						
							SELECT fecha_hoy
									INTO v_fecha_modif
									FROM bdicred:"informix".sd_fechas
									WHERE empresa = p_empresa;
							
									UPDATE bdicred:"informix".sd_ctascarg 
									SET id_cobroaut = '1', num_cta = p_num_cuenta, fecha_modif = v_fecha_modif
									WHERE  empresa = p_empresa
									AND num_credito = p_num_credito;
									
							--LET v_codret = '00007';	LET v_mensaje = 'EL REGISTRO YA EXISTE VALIDAR';									
							LET v_codret = '00000';	LET v_mensaje = 'EL REGISTRO SE ACTUALIZO CORRECTAMENTE';
						--
					END IF

				ELIF p_opcion = '2' THEN --'OPCION DE MODIFICACION STATUS / INACTIVAR';						
					IF p_status_cobaut = '1' THEN
							LET v_codret = '00008'; LET v_mensaje = 'PARAMETRO STATUS COBRO INCORRECTO';
						ELIF v_cobroaut = '1' THEN --- 'EL REGISTRO SE DEBE INACTIVAR';
								
							SELECT fecha_hoy
							INTO v_fecha_baja
							FROM sd_fechas
							WHERE empresa = p_empresa;
								
							UPDATE bdicred:"informix".sd_ctascarg 
							SET id_cobroaut = v_inactivo, fecha_baja = v_fecha_baja, fecha_modif = v_fecha_modif
							WHERE  empresa = p_empresa
							AND num_credito = p_num_credito
							AND id_cobroaut = v_activo; ---- 1
							
							UPDATE bdicred:"informix".sd_maecred
							SET tasa_interes =  v_valor
							WHERE empresa = p_empresa
							AND num_credito = p_num_credito;
								
							LET v_codret = '00000';	LET v_mensaje = 'EL REGISTRO SE INACTIVA CORRECTAMENTE';
						ELIF v_cobroaut IS NULL THEN
							LET v_codret = '00009'; LET v_mensaje = 'EL REGISTRO NO EXISTE VALIDAR';
						ELSE 
							LET v_codret = '00010'; LET v_mensaje = 'EL REGISTRO YA SE ENCUENTRA INACTIVO';
						END IF		
					
				ELIF p_opcion = '3' THEN ---'OPCION DE MODIFICACION STATUS / ACTIVAR';
					IF p_status_cobaut = '0' THEN
							LET v_codret = '00011'; LET v_mensaje = 'PARAMETRO STATUS COBRO INCORRECTO';
						ELIF v_cobroaut = '0' THEN --- 'EL REGISTRO SE DEBE ACTIVAR';
							IF p_num_cuenta IS NULL OR p_num_cuenta = '' THEN
									LET v_codret = '00003';	LET v_mensaje = 'LA CUENTA SE DEBE INFORMAR PARA ACTIVAR EL REGISTRO';
								ELSE 
										
									SELECT fecha_hoy
									INTO v_fecha_modif
									FROM bdicred:"informix".sd_fechas
									WHERE empresa = p_empresa;
							
									UPDATE bdicred:"informix".sd_ctascarg 
									SET id_cobroaut = '1', num_cta = p_num_cuenta, fecha_modif = v_fecha_modif
									WHERE  empresa = p_empresa
									AND num_credito = p_num_credito
									AND id_cobroaut = v_inactivo; --- 0
									
									IF v_id_tasa_pref = 1 THEN 
										LET v_valor = v_valor - v_puntos_tasa_pref;
										
										UPDATE bdicred:"informix".sd_maecred
										SET tasa_interes =  v_valor
										WHERE empresa = p_empresa
										AND num_credito = p_num_credito;
										
									END IF
									
									
									LET v_codret = '00000';	LET v_mensaje = 'EL REGISTRO SE ACTIVA CORRECTAMENTE';
							END IF	
						ELIF v_cobroaut IS NULL THEN 
							LET v_codret = '00012'; LET v_mensaje = 'EL REGISTRO NO EXISTE VALIDAR';
						ELSE
							LET v_codret = '00013'; LET v_mensaje = 'EL REGISTRO YA SE ENCUENTRA ACTIVO';
					END IF		
				
				ELIF p_opcion = '4' THEN ---'OPCION DE MODIFICACION CUENTA';
					IF p_num_cuenta IS NULL OR p_num_cuenta = '' THEN
							LET v_codret = '00014';	LET v_mensaje = 'LA CUENTA SE DEBE INFORMAR PARA ACTUALIZAR EL REGISTRO';
							
						ELIF v_cobroaut IS NULL THEN 
							LET v_codret = '00015';	LET v_mensaje = 'EL REGISTRO NO EXISTE VALIDAR';
							
						ELIF TRIM(v_num_cta) = TRIM(p_num_cuenta) THEN
							LET v_codret = '00016';	LET v_mensaje = 'LA CUENTA DEBE SER DIFERENTE PARA ACTUALIZAR EL REGISTRO';
						ELSE
						
							SELECT fecha_hoy
							INTO v_fecha_modif
							FROM sd_fechas
							WHERE empresa = p_empresa;
							
							UPDATE bdicred:"informix".sd_ctascarg 
							SET num_cta = p_num_cuenta, fecha_modif = v_fecha_modif
							WHERE  empresa = p_empresa
							AND num_credito = p_num_credito;
								
							LET v_codret = '00000';	
								
							IF v_cobroaut = '0' THEN
									LET v_mensaje = 'VALIDAR, SE ACTUALIZA CUENTA DE REGISTRO INACTIVO ';	
								ELSE  
									LET v_mensaje = 'LA CUENTA DEL REGISTRO SE ACTUALIZA CORRECTAMENTE';									
							END IF 	
					END IF	
				
				ELIF p_opcion = '5' THEN ---'OPCION DE CONSULTA DE REGISTRO';
					IF v_cobroaut IS NULL THEN 
							LET v_codret = '00017';	LET v_mensaje = 'EL REGISTRO NO EXISTE';

						ELIF v_cobroaut = '0' THEN
									LET v_codret = '00018';	LET v_mensaje = 'EL REGISTRO EXISTE CON STATUS INACTIVO';	
									
						ELIF v_cobroaut = '1' THEN
									LET v_codret = '00019';	LET v_mensaje = 'EL REGISTRO EXISTE CON STATUS ACTIVO';									
					END IF	
	
			END IF
	END IF
		
    RETURN v_codret, v_mensaje;
END
--*****************************************************
-- TERMINA PROCESO
--*****************************************************
END PROCEDURE;