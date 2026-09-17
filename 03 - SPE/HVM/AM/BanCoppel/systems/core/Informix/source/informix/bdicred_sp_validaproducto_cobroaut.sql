CREATE PROCEDURE "informix".sp_validaproducto_cobroaut(
	p_empresa		CHAR(3),	---- Empresa
	p_num_credito	CHAR(20),	---- Numero de credito
	p_num_cuenta	CHAR(20),	---- Numero de cuenta para cargo
	p_num_producto	CHAR(4))	---- Numero de producto

RETURNING CHAR(5),VARCHAR(80);
--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
DEFINE v_codret				VARCHAR(8);
DEFINE v_mensaje			VARCHAR(80);
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			VARCHAR(80);
DEFINE f_parametro			CHAR(1);
DEFINE v_status				CHAR (1);
DEFINE v_opcion				CHAR (1);
DEFINE c_id_domiciliacion 	CHAR(1);

----- ACTIVA/INACTIVA LOG PARA VALIDAR EL PROCESO
--SET DEBUG FILE TO  '/informix/resplogifx/sp_validaproducto_cobroaut.sql.out';
--TRACE ON;

--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************
/* 
Valores para el mensaje (v_mensaje) dependiendo de codigo de retorno (v_codret): 

v_codret = '00000'; v_mensaje = 'EL PROCESO SE REALIZA CORRECTAMENTE'
v_codret = '00001'; v_mensaje = 'PARAMETRO EMPRESA VACIO'
v_codret = '00002'; v_mensaje = 'PARAMETRO NUMERO CREDITO VACIO'
v_codret = '00003'; v_mensaje = 'PARAMETRO NUMERO CUENTA VACIO'
v_codret = '00004'; v_mensaje = 'PARAMETRO NUMERO PRODUCTO VACIO'
v_codret = '00005'; v_mensaje = 'CAMPO DOMICILIACION NO CAPTURADO EN PRODUCTO'
*/
LET v_mensaje = '';
LET v_codret	= '00000';
LET f_parametro	= '0';
LET c_id_domiciliacion = '';
LET v_status = '1';
LET v_opcion = '1';

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
			LET v_codret = '00001'; LET v_mensaje = 'PARAMETRO -EMPRESA- INCORRECTO';
	
		--- Se valida parametro de NUMERO CREDITO
		ELIF p_num_credito IS NULL OR p_num_credito = '' THEN
			LET v_codret = '00002'; LET v_mensaje = 'PARAMETRO -NUMERO CREDITO- INCORRECTO';
											
		--- Se valida parametro de NUMERO CUENTA
		ELIF c_id_domiciliacion = '1' AND p_num_cuenta IS NULL OR p_num_cuenta = '' THEN
			LET v_codret = '00003';	LET v_mensaje = 'PARAMETRO -NUMERO CUENTA- INCORRECTO';
		
		--- Se valida parametro de NUMERO PRODUCTO
		ELIF p_num_producto IS NULL OR p_num_producto = '' THEN
			LET v_codret = '00004'; LET v_mensaje = 'PARAMETRO -NUMERO PRODUCTO- INCORRECTO';
		ELSE
			SELECT id_domiciliacion
			INTO c_id_domiciliacion
			FROM bdicred:sd_definicion 
			WHERE empresa = p_empresa 
			AND num_producto = p_num_producto;
			
			--- Se valida la bandera de domiciliacion y cuenta como consulta para indicar que SI permite o requiere DOMICILIACION
			IF c_id_domiciliacion = '1' AND p_num_cuenta = '0' THEN
					LET v_codret = '00000';
					LET v_mensaje = 'PRODUCTO SI PERMITE DOMICILIACION';
					
				--- Se valida la bandera de domiciliacion y cuenta como consulta para indicar que NO permite o NO requiere DOMICILIACION	
				ELIF c_id_domiciliacion = '0' AND p_num_cuenta = '0' THEN
					LET v_codret = '10001';
					LET v_mensaje = 'PRODUCTO NO PERMITE DOMICILIACION';
				
				--- Se valida la bandera de domiciliacion para indicar en el producto no se indica valor correcto
				ELIF c_id_domiciliacion IS NULL OR c_id_domiciliacion = '' THEN
						LET v_codret = '00005';
						LET v_mensaje = 'CAMPO DOMICILIACION NO CAPTURADO EN DEFINICION';
								
				--- Se valida la bandera de domiciliacion y parametro cuenta para registrar en tabla de cobro automatico
				ELIF c_id_domiciliacion = '1' AND p_num_cuenta <> '0'  THEN
					EXECUTE PROCEDURE "informix".sp_registra_crecta_cobroaut(p_empresa, p_num_producto ,p_num_credito, p_num_cuenta, v_status, v_opcion)
					INTO v_codret, v_mensaje;
							
					IF v_codret = '00000' THEN
						LET v_mensaje = 'EL PROCESO SE REALIZA CORRECTAMENTE';
					END IF
					
				--- Se valida la bandera de domiciliacion y parametro cuenta indicar que NO permite o NO requiere DOMICILIACION
				ELIF c_id_domiciliacion = '0' AND p_num_cuenta <> '0' THEN
					LET v_codret = '10001';
					LET v_mensaje = 'PRODUCTO NO PERMITE DOMICILIACION';
			END IF
			
	END IF

    RETURN v_codret, v_mensaje;
END
--*****************************************************
-- TERMINA PROCESO
--*****************************************************
END PROCEDURE;