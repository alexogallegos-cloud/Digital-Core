CREATE PROCEDURE "informix".sp_consultatotrevisioncacaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE)
		RETURNING CHAR(5) AS codret,
				  INTEGER AS totalRegistros;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE iTotalRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRetorno = '';
	LET iTotalRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistros;
		END EXCEPTION;
		ON EXCEPTION IN (-206)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatotrevisioncacaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechainicial = '' OR pFechaFinal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegistros;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistros;
		END IF;
		
		DROP TABLE tme_consultaincrementos;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_rep_revisioncac_total(pFechainicial, pFechaFinal)
			INTO cCodRetSp, cMensajeRetorno, iTotalRegistros 
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_rep_revisioncac_total';
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00388'; --PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA
				RETURN cCodRet, iTotalRegistros;
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros;
			ELSE
				RETURN cCodRet, iTotalRegistros;
			END IF;
		END FOREACH;
		
		IF iTotalRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iTotalRegistros;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 04/09/2014',
'DESCRIPCION: Consulta que obtiene el total de registros de información para hacer el llendo del grid MC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultatotgralstatusaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE, pOrigen CHAR(2))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS totalRegistros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE iTotalRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRetorno = '';
	LET iTotalRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistros;
		END EXCEPTION;
		ON EXCEPTION IN (-206)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatotgralstatusaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial = '' OR pFechaFinal = '' OR pOrigen = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistros;
		END IF;
		
		DROP TABLE tme_consultaincrementos;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_rep_gral_status_total(pFechainicial, pFechaFinal, pOrigen)
			INTO cCodRetSp, cMensajeRetorno, iTotalRegistros
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_rep_gral_status_total';
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros;
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00388'; 			--PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA
				RETURN cCodRet, iTotalRegistros;
			ELIF iCodRetSp = 000003 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros;
			ELSE
				RETURN cCodRet, iTotalRegistros;
			END IF;
		END FOREACH;
		
		IF iTotalRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iTotalRegistros;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 04/09/2014',
'DESCRIPCION: Consulta que obtiene el total de registros de información para hacer el llendo del grid Status',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultatotexcepcionesaumlincred(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE,
		pExcepcion CHAR(3))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS totalRegistros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRetorno  CHAR(80);
	DEFINE iTotalRegistros  INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRetorno  = '';
	LET iTotalRegistros  = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistros;
		END EXCEPTION;
		ON EXCEPTION IN (-206)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatotexcepcionesaumlincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechainicial = '' OR pFechaFinal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegistros;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistros;
		END IF;
		DROP TABLE tme_consultaincrementos;
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_rep_excepciones_tot(pFechainicial, pFechaFinal, pExcepcion)
			INTO cCodRetSp, cMensajeRetorno, iTotalRegistros
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_rep_excepciones_tot';
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00388'; --PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA');
				RETURN cCodRet, iTotalRegistros;
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros;
			ELIF iCodRetSp = 000000 THEN
				RETURN cCodRet, iTotalRegistros;
			END IF;
		END FOREACH;
		
		IF iTotalRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iTotalRegistros;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 08/09/2014',
'cDescripcion: Consulta el total de registros para el llenado del grid de excepciones',
'BD: bdicnweb';

CREATE PROCEDURE "informix".inserta_rel_cte_emp(
	p_empresa      CHAR(3),
	p_numcte_banco CHAR(20),
	p_num_empleado CHAR(10),
	p_status_emp   CHAR(1),
	p_observacion1 CHAR(50),
	p_observacion2 CHAR(50),
	p_observacion3 CHAR(50),
	p_observacion4 CHAR(50),
	p_observacion5 CHAR(50))

RETURNING CHAR(5),CHAR(1), VARCHAR(80);
--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
DEFINE v_codret				VARCHAR(8);
DEFINE v_mensaje            VARCHAR(80);
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           VARCHAR(80);
DEFINE v_num_cliente_banco	VARCHAR(20);
DEFINE v_num_empleado		VARCHAR(10);
DEFINE v_status_emp			VARCHAR(1);
DEFINE v_fecha_alta   		DATE;
DEFINE v_fecha_baja   		DATE;
DEFINE v_fecha_modif  		DATE;
DEFINE v_observacion1		VARCHAR(50);
DEFINE v_observacion2		VARCHAR(50);
DEFINE v_observacion3		VARCHAR(50);
DEFINE v_observacion4		VARCHAR(50);
DEFINE v_observacion5		VARCHAR(50);
DEFINE i_contador			INTEGER ;

----- ACTIVA/INACTIVA LOG PARA VALIDAR EL PROCESO
--SET DEBUG FILE TO  '/informix/resplogifx/inserta_rel_cte_emp.out';
--TRACE ON;

--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************
/* 
codigos de retorno (v_codret) y mensajes (v_mensaje) de salida
	v_codret = '00001';	v_mensaje = 'PARAMETRO -EMPRESA- VACIO';
	v_codret = '00002';	v_mensaje = 'PARAMETRO -NUMERO CLIENTE- VACIO';
	v_codret = '00003';	v_mensaje = 'PARAMETRO -NUMERO EMPLEADO- VACIO';
	v_codret = '00004'; v_mensaje = 'PARAMETRO -STATUS EMPLEADO- INCORRECTO';
p_status_emp = 1 (ALTA / REGISTRA)
	v_codret = '00000'; v_mensaje = 'EL REGISTRO SE INSERTA CORRECTAMENTE';
	v_codret = '00005'; v_mensaje = 'EL REGISTRO YA EXISTE, VALIDAR';
p_status_emp = 2 (MODIFICA / INACTIVA)
	v_codret = '00000'; v_mensaje = 'EL REGISTRO SE INACTIVA CORRECTAMENTE';
	v_codret = '00006'; v_mensaje = 'EL REGISTRO YA ESTA INACTIVO, VALIDAR';
	v_codret = '00007'; v_mensaje = 'EL REGISTRO NO EXISTE, VALIDAR';
p_status_emp = 3 (MODIFICA / ACTIVA)
	v_codret = '00000'; v_mensaje = 'EL REGISTRO SE INACTIVA CORRECTAMENTE';
	v_codret = '00008'; v_mensaje = 'EL REGISTRO YA ESTA ACTIVO, VALIDAR';
	v_codret = '00009'; v_mensaje = 'EL REGISTRO NO EXISTE, VALIDAR';
*/
LET v_codret = '00000';
LET i_contador = 0;
LET v_fecha_alta  = '';
LET v_fecha_baja  = '';
LET v_fecha_modif = '';
LET v_status_emp = '';
LET v_observacion1 = p_observacion1;
LET v_observacion2 = p_observacion2;
LET v_observacion3 = p_observacion3;
LET v_observacion4 = p_observacion4;
LET v_observacion5 = p_observacion5;

--*****************************************************
-- INICIA PROCESO
--*****************************************************
BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
         LET v_codret    = sql_err;
         LET v_mensaje  = error_info;
	    RETURN v_codret,v_status_emp, v_mensaje;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
		--- Se validan los parametros de entrada con los cuales se ejecuta en SP
	--- Se valida parametro de EMPRESA
	IF p_empresa IS NULL OR p_empresa = '' THEN
			LET v_codret = '00001';	LET v_mensaje = 'PARAMETRO -EMPRESA- VACIO';
	
		--- Se valida parametro de NUMERO CLIENTE
		ELIF p_numcte_banco IS NULL OR p_numcte_banco = '' THEN
			LET v_codret = '00002';	LET v_mensaje = 'PARAMETRO -NUMERO CLIENTE- VACIO';
		
		--- Se valida parametro de NUMERO EMPLEADO
		ELIF p_num_empleado IS NULL OR p_num_empleado = '' THEN
			LET v_codret = '00003';	LET v_mensaje = 'PARAMETRO -NUMERO EMPLEADO- VACIO';
			
		--- Se valida parametro de STATUS EMPLEADO
		ELIF p_status_emp NOT IN ('1','2','3') THEN
			LET v_codret = '00004'; LET v_mensaje = 'PARAMETRO -STATUS EMPLEADO- INCORRECTO';
		ELSE
		--   Se valida la existencia la relacion cliente banco y numero de empleado
		
		SELECT status_emp
		INTO v_status_emp
		FROM   bdinteg:"informix".si_rel_cte_empleado
		WHERE  empresa = p_empresa
		AND numcte_banco = p_numcte_banco
		AND num_empleado = p_num_empleado;
		
		IF p_status_emp = 1 THEN
			---- ALTA / REGISTRA
				IF v_status_emp IS NULL THEN
						---- Si el registro NO existe se inserta en tabla con los valores indicados en los parámetros de entrada
						LET v_status_emp = '1';
						
						SELECT fecha_hoy
						INTO v_fecha_alta
						FROM bdicred:"informix".sd_fechas
						WHERE empresa = p_empresa;
										
						INSERT INTO bdinteg:"informix".si_rel_cte_empleado(empresa,numcte_banco,num_empleado,status_emp,fecha_alta,fecha_baja,
						fecha_modif,observacion1,observacion2,observacion3,observacion4,observacion5)
						VALUES (p_empresa,p_numcte_banco,p_num_empleado,v_status_emp, v_fecha_alta, v_fecha_baja, v_fecha_modif,
						v_observacion1,v_observacion2,v_observacion3,v_observacion4,v_observacion5);
						
						LET v_codret = '00000'; LET v_mensaje = 'EL REGISTRO SE INSERTA CORRECTAMENTE';
					ELSE 
						LET v_codret = '00005'; LET v_mensaje = 'EL REGISTRO YA EXISTE, VALIDAR';
				END IF
			---- MODIFICA / INACTIVA registro	
			ELIF p_status_emp = 2 THEN
				IF v_status_emp = 1 THEN
						LET v_status_emp = '0';
						
						SELECT fecha_hoy
						INTO v_fecha_baja
						FROM bdicred:"informix".sd_fechas
						WHERE empresa = p_empresa;
							
						UPDATE bdinteg:"informix".si_rel_cte_empleado
						SET status_emp = v_status_emp, fecha_baja = v_fecha_baja, observacion1 = p_observacion1
						WHERE  empresa = p_empresa
						AND numcte_banco = p_numcte_banco
						AND num_empleado = p_num_empleado;
					
						LET v_codret = '00000'; LET v_mensaje = 'EL REGISTRO SE INACTIVA CORRECTAMENTE';
					ELIF v_status_emp = 0 THEN
						LET v_codret = '00006'; LET v_mensaje = 'EL REGISTRO YA ESTA INACTIVO, VALIDAR';
					ELSE 
						LET v_codret = '00007'; LET v_mensaje = 'EL REGISTRO NO EXISTE, VALIDAR';
				END IF
			---- MODIFICA / ACTIVA registro
			ELIF p_status_emp = 3 THEN
				IF v_status_emp = 0 THEN
						LET v_status_emp = '1';
						
						SELECT fecha_hoy
						INTO v_fecha_modif
						FROM bdicred:"informix".sd_fechas
						WHERE empresa = p_empresa;
							
						UPDATE bdinteg:"informix".si_rel_cte_empleado
						SET status_emp = v_status_emp, fecha_modif = v_fecha_modif, observacion2 = p_observacion2
						WHERE  empresa = p_empresa
						AND numcte_banco = p_numcte_banco
						AND num_empleado = p_num_empleado;
					
						LET v_codret = '00000'; LET v_mensaje = 'EL REGISTRO SE ACTIVA CORRECTAMENTE';
					ELIF v_status_emp = 1 THEN
						LET v_codret = '00008'; LET v_mensaje = 'EL REGISTRO YA ESTA ACTIVO, VALIDAR';
					ELSE 
						LET v_codret = '00009'; LET v_mensaje = 'EL REGISTRO NO EXISTE, VALIDAR';
				END IF
		END IF
	END IF
    RETURN v_codret,v_status_emp, v_mensaje;
END
--*****************************************************
-- TERMINA PROCESO
--*****************************************************
END PROCEDURE;